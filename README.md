# Rejuvenation

The Rejuvenation library enables analysis and manipulation of Ada code based on concrete patterns.
Analysis and manipulation is based on the [AST](https://en.wikipedia.org/wiki/Abstract_syntax_tree)
of Ada and hence is insensitive for layout and the presence of comments.
Both find- and replace-functionality are specified in concrete Ada patterns extended with Placeholders.

## placeholders

There are two types of placeholders, those starting with "$S_" and those starting with "$M_".
Any alphanumeric string is allowed to follow after those prefixes.

"$S_" placeholders allow one to match a single AST node, be that a single expression, a single statement, a single argument, or anything else.
As long as Ada parses it to a single AST node, the "$S_" placeholders can match it.

"$M_" placeholders allow one to match a list of AST nodes, i.e., zero or more nodes.

Note that the current implementation is greedy with respect to placeholders.
Whenever one could proceed to the next placeholder this will happen.
So all matches in the current implementation of `$M_X; $S_T;` will always have an empty list for `$M_X`.
We want to improve this behaviour soon. See https://github.com/TNO/Renaissance-Ada/issues/21.

### placeholders in find patterns

A find pattern might contain multiple different placeholders.

A find pattern might contain the same placeholder multiple times.
This add a constraint to the find process:
A match will only be found when all occurrence of the same placeholder are identical.
Note that universities are still researching what the best definition of identical is.
In analogy with [Regular Expressions](https://en.wikipedia.org/wiki/Regular_expression), 
the term backreference is used to denote a placeholder that reoccurs.

### placeholders in replace patterns

A placeholder in a replace pattern always refers to that placeholder in the find pattern.
A placeholder in a replace pattern that does not occur in the find pattern is thus an error.
A placeholder in the replace pattern will be replaced by the value of that placeholder in the match of the find pattern.
In analogy with [Regular Expressions](https://en.wikipedia.org/wiki/Regular_expression), 
all placeholders in a replace pattern can be called backreferences.

# Examples
See 
the [examples](examples), 
the [workshop](workshop), and 
the [tests](tests)
for inspiration to use the Rejuvenation Library.

# Tools made using Rejuvenation Library
* [Find Tool](find_tool) finds a pattern in a given project
* [Find And Replace Tool](find_and_replace_tool) finds a pattern and replaces it with another in a given project
