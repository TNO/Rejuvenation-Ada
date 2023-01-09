with Rejuvenation.Finder;         use Rejuvenation.Finder;
with Rejuvenation.Match_Patterns; use Rejuvenation.Match_Patterns;
with Rejuvenation.Node_Locations; use Rejuvenation.Node_Locations;
with Rejuvenation.Patterns;       use Rejuvenation.Patterns;
with Rejuvenation.Text_Rewrites;  use Rejuvenation.Text_Rewrites;

package Rejuvenation.Find_And_Replacer is

   procedure Find_And_Replace
     (TR : in out Text_Rewrite'Class; Node : Ada_Node'Class;
      Find_Pattern, Replace_Pattern :        Pattern;
      Accept_Match                  :        not null access function
        (M_P : Match_Pattern) return Boolean :=
        Accept_Every_Match'Access;
      Before, After : Node_Location := No_Trivia);

   function Find_And_Replace
     (File_Path    : String; Find_Pattern, Replace_Pattern : Pattern;
      Accept_Match : not null access function
        (M_P : Match_Pattern) return Boolean :=
        Accept_Every_Match'Access;
      Before, After : Node_Location := No_Trivia) return Boolean;
   --  Find instances of the given pattern and
   --  for each accepted match replaces using the given replacement pattern.
   --  Placeholder names defined in the find pattern that occur
   --  in the replacement pattern are replaced
   --  by the matching string at the placeholder.
   --  Return value indicates whether any match was found and accepted
   --  Note: When a match is found and accepted, the file will be changed
   --
   --  Note: When find-and-replacing all instances of a particular warning
   --  detected by your favorite linter, such as GNATcheck and CodePeer,
   --  you don't have to reimplement the semantic check of that warning, since
   --  you can just check whether the location of the found instance occurs
   --  in the list of reported locations by the linter.

end Rejuvenation.Find_And_Replacer;
