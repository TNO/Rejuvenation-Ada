with Ada.Strings;           use Ada.Strings;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Strings.Equal_Case_Insensitive;
with GNATCOLL.GMP.Integers; use GNATCOLL.GMP.Integers;
with Langkit_Support.Text;  use Langkit_Support.Text;

package body Rejuvenation.Utils is

   -- Raw signature --------

   function Raw_Signature
     (Node : Ada_Node'Class; Before, After : Node_Location := No_Trivia)
      return String
   is
   begin
      if Node.Is_Null then
         return "";
      else
         declare
            First    : constant Positive      := Start_Offset (Node, Before);
            Last     : constant Natural       := End_Offset (Node, After);
            Unit     : constant Analysis_Unit := Node.Unit;
            Node_Str : constant String        :=
              Encode (Unit.Text (First .. Last), Unit.Get_Charset);
         begin
            return Node_Str;
         end;
      end if;
   end Raw_Signature;

   function Raw_Signature
     (Token : Token_Reference; Charset : String) return String is
     (if Token = No_Token then "" else Encode (Text (Token), Charset));

   function Raw_Signature
     (First_Node, Last_Node : Ada_Node'Class;
      Before, After         : Node_Location := No_Trivia) return String
   is
      First : constant Positive      := Start_Offset (First_Node, Before);
      Last  : constant Natural       := End_Offset (Last_Node, After);
      Unit  : constant Analysis_Unit := First_Node.Unit;
      Str   : constant String        :=
        Encode (Unit.Text (First .. Last), Unit.Get_Charset);
   begin
      return Str;
   end Raw_Signature;

   function Are_Equal_As_Raw_Signature
     (Node1, Node2 : Ada_Node'Class) return Boolean
   is
   begin
      return Raw_Signature (Node1) = Raw_Signature (Node2);
   end Are_Equal_As_Raw_Signature;

   function Are_Equal_Case_Insensitive_As_Raw_Signature
     (Node1, Node2 : Ada_Node'Class) return Boolean
   is
   begin
      return
        Equal_Case_Insensitive (Raw_Signature (Node1), Raw_Signature (Node2));
   end Are_Equal_Case_Insensitive_As_Raw_Signature;

   function Are_Equal_In_Ada (Node1, Node2 : Ada_Node'Class) return Boolean is
      function Ensure_Ada_Token
        (Iterator : Token_Iterator; Token : Token_Reference)
         return Token_Reference;
      --  If token is NOT an Ada token (i.e. trivia)
      --  move it to an Ada Token
      --  Note: No_Token is considered an Ada token.
      function Ensure_Ada_Token
        (Iterator : Token_Iterator; Token : Token_Reference)
         return Token_Reference
      is
      begin
         if Token = No_Token
           or else Kind (Data (Token)) not in Ada_Comment | Ada_Whitespace
         then
            return Token;
         else
            return Ensure_Ada_Token (Iterator, Next_Token (Iterator, Token));
         end if;
      end Ensure_Ada_Token;

      Iterator1 : constant Token_Iterator := Node1.Token_Range;
      Iterator2 : constant Token_Iterator := Node2.Token_Range;

      Token1 : Token_Reference :=
        Ensure_Ada_Token (Iterator1, First_Token (Iterator1));
      Token2 : Token_Reference :=
        Ensure_Ada_Token (Iterator2, First_Token (Iterator2));
   begin
      loop
         declare
            type Count_Type is range 0 .. 2;
            Number_At_End : constant Count_Type :=
              (if Has_Element (Iterator1, Token1) then 0 else 1) +
              (if Has_Element (Iterator2, Token2) then 0 else 1);
         begin
            case Number_At_End is
               when 2 =>
                  return True;
               when 1 =>
                  return False;
               when 0 =>
                  if Is_Equivalent (Token1, Token2) then
                     Token1 :=
                       Ensure_Ada_Token
                         (Iterator1, Next_Token (Iterator1, Token1));
                     Token2 :=
                       Ensure_Ada_Token
                         (Iterator2, Next_Token (Iterator2, Token2));
                  else
                     return False;
                  end if;
            end case;
         end;
      end loop;
   end Are_Equal_In_Ada;

   --  Package (Distributed over files) functionality

   function In_Same_Package (Unit1, Unit2 : Analysis_Unit) return Boolean is
      Unit1_Filename : constant String := Unit1.Get_Filename;
      Unit2_Filename : constant String := Unit2.Get_Filename;
   begin
      --  TODO: should the comparison be case insensitive?
      return
        Unit1_Filename (Unit1_Filename'First .. Unit1_Filename'Last - 1) =
        Unit2_Filename (Unit2_Filename'First .. Unit2_Filename'Last - 1);
   end In_Same_Package;

   -- Image --------

   function Image (Node_List_Vector : Node_List.Vector) return String is
   begin
      if Node_List_Vector.Length = 0 then
         return "[]";
      else
         declare
            Str : Unbounded_String :=
              To_Unbounded_String (Node_List_Vector.First_Element.Image);
         begin
            for Index in
              Node_List_Vector.First_Index + 1 .. Node_List_Vector.Last_Index
            loop
               Str :=
                 Str & ", " &
                 Node_List_Vector.Element (Positive (Index)).Image;
            end loop;
            return "[" & To_String (Str) & "]";
         end;
      end if;
   end Image;

   -- Get trivia tokens --------

   function Get_Trivia_Before (Node : Ada_Node'Class) return Token_List.Vector
   is
   begin
      return Get_Trivia_Before (Node.Token_Start);
   end Get_Trivia_Before;

   function Get_Trivia_Before
     (Token : Token_Reference) return Token_List.Vector
   is
      Results       : Token_List.Vector;
      Running_Token : Token_Reference := Previous (Token);
   begin
      while Is_Trivia (Running_Token) loop
         Token_List.Prepend (Results, Running_Token);
         Running_Token := Previous (Running_Token);
      end loop;
      return Results;
   end Get_Trivia_Before;

   function Get_Trivia_After (Node : Ada_Node'Class) return Token_List.Vector
   is
   begin
      return Get_Trivia_After (Node.Token_End);
   end Get_Trivia_After;

   function Get_Trivia_After (Token : Token_Reference) return Token_List.Vector
   is
      Results       : Token_List.Vector;
      Running_Token : Token_Reference := Next (Token);
   begin
      while Is_Trivia (Running_Token) loop
         Token_List.Append (Results, Running_Token);
         Running_Token := Next (Running_Token);
      end loop;
      return Results;
   end Get_Trivia_After;

   function Get_Tokens (Node : Ada_Node'Class) return Token_List.Vector is
      Results       : Token_List.Vector;
      Running_Token : Token_Reference := Node.Token_Start;
   begin
      while Running_Token /= Node.Token_End loop
         Token_List.Append (Results, Running_Token);
         Running_Token := Next (Running_Token);
      end loop;
      Token_List.Append (Results, Running_Token);
      return Results;
   end Get_Tokens;

end Rejuvenation.Utils;
