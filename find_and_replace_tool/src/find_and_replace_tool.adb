with Ada.Text_IO;                    use Ada.Text_IO;
with Libadalang.Common;              use Libadalang.Common;
with Rejuvenation;                   use Rejuvenation;
with Rejuvenation.Find_And_Replacer; use Rejuvenation.Find_And_Replacer;
with Rejuvenation.Patterns;          use Rejuvenation.Patterns;
with Rejuvenation.Simple_Factory;    use Rejuvenation.Simple_Factory;
with String_Vectors;                 use String_Vectors;

procedure Find_And_Replace_Tool is
   Find_Pattern : constant Pattern :=
     Make_Pattern ("$S_F ($S_Arg1, $S_Arg2);", Call_Stmt_Rule);

   --  Swap arguments - of course resulting in illegal program ;-)
   Replace_Pattern : constant Pattern :=
     Make_Pattern ("$S_F ($S_Arg2, $S_Arg1);", Call_Stmt_Rule);

   Project_Name : constant String := "C:\path\to\your.gpr";
   Files : constant String_Vectors.Vector :=
     Get_Ada_Source_Files_From_Project (Project_Name);
begin
   for File of Files loop
      if Find_And_Replace (File, Find_Pattern, Replace_Pattern) then
         Put_Line ("Changed - " & File);
      end if;
   end loop;
end Find_And_Replace_Tool;
