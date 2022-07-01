with Ada.Environment_Variables;   use Ada.Environment_Variables;
with Ada.Text_IO;                 use Ada.Text_IO;
with Langkit_Support.Text;        use Langkit_Support.Text;
with Libadalang.Analysis;         use Libadalang.Analysis;
with Libadalang.Common;           use Libadalang.Common;
with Rejuvenation.Patterns;       use Rejuvenation.Patterns;
with Rejuvenation.Simple_Factory; use Rejuvenation.Simple_Factory;
with Rejuvenation.Utils;          use Rejuvenation.Utils;

with Finder; use Finder;

procedure Find_Tool is
begin
   --  Settings for the project that will be analyzed.
   --
   --  For example:
   --  Set ("GPR_PROJECT_PATH", "C:\GNATPRO\22.1\share\gpr");
   --
   --  Note that settings of alire projects can be obtained
   --  using `alr printenv`
   Set ("YOUR_ENVIRONMENT_VARIABLE", "Your_Value");
   declare
      Units : constant Analysis_Units.Vector :=
        Analyze_Project ("C:\path\to\your.gpr");

      --  For more examples of find patterns, see
      --  https://github.com/TNO/Rejuvenation-Ada/blob/main/find_tool/README.md
      Find_Pattern : constant Pattern :=
        Make_Pattern
          ("if $S_Cond then " &
           "  $S_f ($M_before, $M_Designator => $S_Value1, $M_after); " &
           "else " &
           "  $S_f ($M_before, $M_Designator => $S_Value2, $M_after); " &
           "end if;",
           If_Stmt_Rule);

      Count : Natural := 0;
   begin
      for Unit of Units loop
         for Match of Find (Unit.Root, Find_Pattern) loop
            Count := Count + 1;
            Put_Line
              (Image (Match.Get_Nodes.First_Element.Full_Sloc_Image) &
               Raw_Signature
                 (Match.Get_Nodes.First_Element,
                  Match.Get_Nodes.Last_Element));
         end loop;
      end loop;
      Put_Line ("# Matches = " & Count'Image);
   end;
end Find_Tool;
