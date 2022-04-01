with AUnit.Reporter.Text;
with AUnit.Run;
with Workshop_Suite; use Workshop_Suite;

procedure Test_Workshop is
   procedure Runner is new AUnit.Run.Test_Runner (Suite);
   Reporter : AUnit.Reporter.Text.Text_Reporter;
begin
   Runner (Reporter);
end Test_Workshop;
