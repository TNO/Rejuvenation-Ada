with Ada.Environment_Variables; use Ada.Environment_Variables;

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

end Rejuvenation.Environment_Variables;
