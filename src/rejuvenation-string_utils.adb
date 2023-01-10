package body Rejuvenation.String_Utils with
   SPARK_Mode => On
is

   function Replace_Prefix
     (String_With_Prefix : String; Prefix, New_Prefix : String) return String
   is
   begin
      return
        New_Prefix &
        Tail (String_With_Prefix, String_With_Prefix'Length - Prefix'Length);
   end Replace_Prefix;

   function Replace_All (Source, Pattern, Replacement : String) return String
   is
      Location : constant Natural :=
        Index (Source => Source, Pattern => Pattern);
   begin
      return
        (if Location = 0 then Source
         else Source (Source'First .. Location - 1) & Replacement &
           Replace_All
             (Source (Location + Pattern'Length .. Source'Last), Pattern,
              Replacement));
   end Replace_All;

end Rejuvenation.String_Utils;
