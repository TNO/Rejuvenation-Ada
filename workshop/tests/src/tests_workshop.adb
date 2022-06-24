with AUnit;               use AUnit;
with AUnit.Reporter.Text; use AUnit.Reporter.Text;
with AUnit.Run;           use AUnit.Run;
with GNAT.OS_Lib;         use GNAT.OS_Lib;
with Workshop_Suite;      use Workshop_Suite;

procedure Tests_Workshop is
   function Runner is new Test_Runner_With_Status (Suite);
   Reporter : Text_Reporter;
begin
   if Runner (Reporter) /= Success then
      OS_Exit (1);
   end if;
end Tests_Workshop;
