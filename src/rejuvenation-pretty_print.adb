with Ada.Assertions;              use Ada.Assertions;
with Ada.Text_IO;                 use Ada.Text_IO;
with GNAT.OS_Lib;                 use GNAT.OS_Lib;
with Interfaces.C;                use Interfaces.C;
with Rejuvenation.File_Utils;     use Rejuvenation.File_Utils;
with Rejuvenation.Indentation;    use Rejuvenation.Indentation;
with Rejuvenation.Navigation;     use Rejuvenation.Navigation;
with Rejuvenation.Nested;         use Rejuvenation.Nested;
with Rejuvenation.Node_Locations; use Rejuvenation.Node_Locations;
with Rejuvenation.String_Utils;   use Rejuvenation.String_Utils;

package body Rejuvenation.Pretty_Print is
   function Sys (Arg : char_array) return Integer;
   pragma Import (C, Sys, "system");

   procedure Surround_Node_By_Pretty_Print_Section
     (T_R : in out Text_Rewrite'Class; Node : Ada_Node'Class)
   is
      Ctx : constant Ada_Node :=
        Get_Reflexive_Ancestor (Node, Node_On_Separate_Lines'Access);
   begin
      T_R.Prepend (Ctx, Pretty_Print_On, Before => Trivia_On_Same_Line);
      T_R.Append (Ctx, Pretty_Print_Off, After => Trivia_On_Same_Line);
   end Surround_Node_By_Pretty_Print_Section;

   procedure Turn_Pretty_Printing_Initially_Off
     (T_R : in out Text_Rewrite_Unit)
   is
      Unit : constant Analysis_Unit := T_R.Get_Unit;
   begin
      T_R.Prepend (Unit.Root, Pretty_Print_Off, All_Trivia, Unit.Get_Charset);
   end Turn_Pretty_Printing_Initially_Off;

   procedure Turn_Pretty_Printing_Initially_Off (Filename : String) is
      Original_Content : constant String := Get_String_From_File (Filename);
   begin
      Write_String_To_File (Pretty_Print_Off & Original_Content, Filename);
   end Turn_Pretty_Printing_Initially_Off;

   procedure Remove_Cr_Cr_Lf (Filename : String);
   procedure Remove_Cr_Cr_Lf (Filename : String)
      --  repair gnatpp screwed up
      --  see https://gt3-prod-1.adacore.com/#/tickets/U617-042
      is
      Contents       : constant String := Get_String_From_File (Filename);
      Final_Contents : constant String :=
        Replace_All
          (Contents, ASCII.CR & ASCII.CR & ASCII.LF, ASCII.CR & ASCII.LF);
   begin
      Write_String_To_File (Final_Contents, Filename);
   end Remove_Cr_Cr_Lf;

   procedure Remove_Nested_Pretty_Print_Flags (Filename : String);
   procedure Remove_Nested_Pretty_Print_Flags (Filename : String) is
      Contents       : constant String := Get_String_From_File (Filename);
      Final_Contents : constant String :=
        Remove_Nested_Flags (Contents, Pretty_Print_On, Pretty_Print_Off, 1);
   begin
      Write_String_To_File (Final_Contents, Filename);
   end Remove_Nested_Pretty_Print_Flags;

   procedure Pretty_Print_Sections_Options
     (Filename : String; Options : String);
   procedure Pretty_Print_Sections_Options
     (Filename : String; Options : String)
   is
      Command : constant String :=
        "gnatpp" & Options & " --pp-on=" & Flag_On & " --pp-off=" & Flag_Off &
        " " & Filename;
   begin
      Remove_Nested_Pretty_Print_Flags (Filename);
      declare
         Original_Content : constant String := Get_String_From_File (Filename);
         Original_Last_Char : constant Character :=
           Original_Content (Original_Content'Last);
         Ret_Val : constant Integer := Sys (To_C (Command));
      begin
         Assert
           (Check   => Ret_Val = 0,
            Message => "System call to gnatpp returned " & Ret_Val'Image);
         declare
            Current_Content : constant String :=
              Get_String_From_File (Filename);
            Current_Last_Char : constant Character :=
              Current_Content (Current_Content'Last);
         begin
            if Current_Last_Char /= Original_Last_Char then
               --  correct GNATPP bug (additional LF at end of file)
               Write_String_To_File
                 (Current_Content
                    (Current_Content'First .. Current_Content'Last - 1),
                  Filename);
            end if;
         end;
      end;
      Remove_Cr_Cr_Lf (Filename);
   end Pretty_Print_Sections_Options;

   procedure Pretty_Print_Sections (Filename : String) is
   begin
      Pretty_Print_Sections_Options (Filename, "");
   end Pretty_Print_Sections;

   procedure Pretty_Print_Sections (Filename : String; Projectname : String) is
   begin
      Pretty_Print_Sections_Options (Filename, " -P " & Projectname);
   end Pretty_Print_Sections;

   procedure Remove_Pretty_Print_Flags (Filename : String) is
      Contents     : constant String := Get_String_From_File (Filename);
      New_Contents : constant String :=
        Replace_All
          (Replace_All
             (Replace_All
                (Replace_All (Contents, Pretty_Print_On, ""),
                 Alt_Pretty_Print_On, ""),
              Pretty_Print_Off, ""),
           Alt_Pretty_Print_Off, "");
   begin
      Write_String_To_File (New_Contents, Filename);
   end Remove_Pretty_Print_Flags;

   procedure Enforce_GNATPP_In_Environment;
   procedure Enforce_GNATPP_In_Environment is
      Command : constant String  := "gnatpp --version";
      Ret_Val : constant Integer := Sys (To_C (Command));
   begin
      if Ret_Val /= 0 then
         Put_Line
           (Standard_Error,
            "System call to gnatpp returned " & Ret_Val'Image & ".");
         Put_Line
           (Standard_Error, "Probably, gnatpp not present on your PATH.");
         Put_Line
           (Standard_Error,
            "Please, install gnatpp using " &
            "`alr get --build libadalang_tools`" & " on your PATH");
         OS_Exit (99);
      end if;
   end Enforce_GNATPP_In_Environment;

begin
   Enforce_GNATPP_In_Environment;
end Rejuvenation.Pretty_Print;
