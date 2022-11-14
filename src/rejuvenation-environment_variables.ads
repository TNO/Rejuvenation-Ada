with String_Maps; use String_Maps;

package Rejuvenation.Environment_Variables is

   procedure Set (Map : String_Maps.Map);
   --  Set all environment variables
   --  according to the key value pairs in the map

   procedure Set_Alire_Project (Project_Directory : String);
   --  Set all environment variables
   --  according to alire

end Rejuvenation.Environment_Variables;
