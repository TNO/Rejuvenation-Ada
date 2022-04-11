with AUnit.Reporter.Text;
with AUnit.Run;
with Workshop_Suite; use Workshop_Suite;

with GNAT.OS_Lib;

procedure Test_Workshop is
   use type AUnit.Status;

   function Runner is new AUnit.Run.Test_Runner_With_Status (Suite);
   Reporter : AUnit.Reporter.Text.Text_Reporter;
begin
   if Runner (Reporter) /= AUnit.Success then
      GNAT.OS_Lib.OS_Exit (1);
   end if;
end Test_Workshop;
