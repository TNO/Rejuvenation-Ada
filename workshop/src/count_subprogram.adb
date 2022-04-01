package body Count_Subprogram is

   procedure P2A (x, y : Integer) is null;
   procedure P2B (x : Integer; y : Integer) is null;

   procedure P4A (k, l, m, n : Integer) is null;
   procedure P4B (k : Integer; l : Integer; m : Integer; n : Integer) is null;

   procedure P3A (x, y, z : Integer) is null;
   procedure P3B (x, y : Integer; z : Integer) is null;
   procedure P3C (x : Integer; y, z : Integer) is null;
   procedure P3D (x : Integer; y : Integer; z : Integer) is null;

   procedure P3G
     (x : Integer := 0; y : Integer := 1; z : Integer := 2) is null;
   procedure P3H (x, y, z : Integer := 0) is null;

   --  STYLE_CHECK
   --  gnatyI: 'check mode IN keywords.'
   --  Mode in (the default mode) is not allowed to be given explicitly.
   --  in out is fine, but not in on its own.
   pragma Style_Checks (Off);
   procedure P3I (x, y, z : in Integer) is null;
   pragma Style_Checks (On);
   procedure P3J (x, y, z : in out Integer) is null;
   procedure P3K (x, y, z : out Integer) is null;

   --  Formal parameter is not referenced
   --  1. pragma Unreferenced (x, y, z); can't be placed in the right scope
   --  2. aspect is only associated with last parameter
   --     see https://gt3-prod-1.adacore.com/#/tickets/V401-014
   pragma Extensions_Allowed (On);
   procedure P3N (x : Element_T with Unreferenced;
                  y : Element_T with Unreferenced;
                  z : Element_T with Unreferenced)
   is null;
   pragma Extensions_Allowed (Off);

   --  Formal parameter is not referenced
   --  pragma Unreferenced (x, y, z); can't be placed in the right scope
   pragma Extensions_Allowed (On);
   procedure P3O (x : Element_T with Unreferenced;
                  y : Element_T with Unreferenced;
                  z : Element_T with Unreferenced)
   is null;
   pragma Extensions_Allowed (Off);

   procedure S1 (Call_Back : access procedure (x, y, z : Integer)) is null;
   procedure S2
     (Call_Back : access procedure
        (x : Integer; y : Integer; z : Integer)) is null;

   function F3C (x, y, z : Integer) return Integer is (x + y + z);
   function F3D (x : Integer; y : Integer; z : Integer) return Integer is
     (x + y + z);

end Count_Subprogram;
