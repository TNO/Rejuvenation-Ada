with Ada.Directories;           use Ada.Directories;
with Ada.Environment_Variables; use Ada.Environment_Variables;
with Ada.Text_IO;               use Ada.Text_IO;
with GNAT.Regpat;               use GNAT.Regpat;
with Interfaces.C;              use Interfaces.C;
with Rejuvenation.File_Utils;   use Rejuvenation.File_Utils;

package body Rejuvenation.Environment_Variables is

   procedure Set (Map : String_Maps.Map) is

      procedure Set_Position (Position : Cursor);
      --  Set individual key value pair at position
      procedure Set_Position (Position : Cursor) is
      begin
         Set (Name => Key (Position), Value => Element (Position));
      end Set_Position;

   begin
      Map.Iterate (Set_Position'Access);
   end Set;

   procedure Set_Alire_Project (Project_Directory : String) is
      function Sys (Arg : char_array) return Integer;
      pragma Import (C, Sys, "system");

      Output_File : constant String :=
        Compose (Project_Directory, "temp.alr.printenv", "txt");
      Alr_Command : constant String :=
        "cd """ & Project_Directory & """ && alr printenv > """ & Output_File &
        """";
      Alr_RetVal : constant Integer := Sys (To_C (Alr_Command));
   begin
      if Alr_RetVal /= 0 then
         Put_Line
           (Standard_Error,
            "System call to alr returned " & Alr_RetVal'Image & ".");
         Put_Line (Standard_Error, "Is alr installed and on the path?");
         Put_Line
           (Standard_Error,
            "Does '" & Project_Directory & "' contain an alire.toml file?");
      else
         declare
            Content : constant String := Get_String_From_File (Output_File);
            Current : Natural         := Content'First;

            Export_Matcher : constant Pattern_Matcher :=
              Compile ("export ([A-Z_]+)=""([^""]*)""");
            Matches : Match_Array (0 .. 2);
            Found   : Boolean;
         begin
            loop
               Match (Export_Matcher, Content, Matches, Current);
               Found := Matches (0) /= No_Match;
               exit when not Found;

               Current := Matches (0).Last;
               --  Set environment variable
               declare
                  Name : constant String :=
                    Content (Matches (1).First .. Matches (1).Last);
                  Value : constant String :=
                    Content (Matches (2).First .. Matches (2).Last);
               begin
                  Set (Name => Name, Value => Value);
               end;
            end loop;
         end;
      end if;

      declare
         Del_Command : constant String  := "del """ & Output_File & """";
         Del_RetVal  : constant Integer := Sys (To_C (Del_Command));
      begin
         if Del_RetVal /= 0 then
            Put_Line
              (Standard_Error,
               "Removal of  " & Output_File & " failed with " &
               Del_RetVal'Image & ".");
         end if;
      end;
   end Set_Alire_Project;

end Rejuvenation.Environment_Variables;
