# Rejuvenation-Ada

The Rejuvenation-Ada library enables analysis and manipulation of Ada code based on concrete patterns.
Analysis and manipulation is based on the [AST](https://en.wikipedia.org/wiki/Abstract_syntax_tree)
of Ada and hence is insensitive for layout and the presence of comments.
Both find- and replace-functionality are specified using an extended version of the well-known concrete syntax of Ada.

The Rejuvenation-Ada library is part of the [Renaissance-Ada project](https://github.com/TNO/Renaissance-Ada)
that develops tooling for analysis and manipulation of Ada code.

# Basic Analysis and Manipulation

With the Rejuvenation-Ada library, you can analyze, for occurrences of the code pattern
```ada
ready; set; go;
```
and you would find the following occurrences (when they appear in your Ada project)
```ada
ready; set; go;
```
```ada
ready; 
set; 
go;
```
```ada
ready;   -- first signal to prepare action

set;     -- second signal to acquire resources

go;      -- take action
```
Note that the analysis is insensitive for layout and the presence of comments.

Furthermore, you can manipulate all found occurrences by replacing them with the code pattern
```ada
start;
```

# Powerful Analysis and Manipulation using Placeholders

Since Ada's concrete syntax can be easily extended by using characters, such as `$`, that are illegal in the Ada programming language (except inside character and string literals), the Rejuvenation-Ada library is able to make the analysis and manipulation of Ada code more powerful, by adding just one extension to Ada's concrete syntax: Placeholders. 

There are two types of placeholders, those starting with "$S_" and those starting with "$M_".
Any alphanumeric string is allowed to follow after those prefixes.

"$S_" placeholders allow one to match a single AST node, be that a single expression, a single statement, a single argument, or anything else.
As long as Ada parses it to a single AST node, the "$S_" placeholders can match it.

"$M_" placeholders allow one to match a list of AST nodes, i.e., zero or more nodes.

Note that the current implementation is greedy with respect to placeholders.
Whenever one could proceed to the next placeholder this will happen.
So all matches in the current implementation of `$M_X; $S_T;` will always have an empty list for `$M_X`.
We want to improve this behaviour soon. See https://github.com/TNO/Renaissance-Ada/issues/21.

## placeholders in find patterns

A find pattern might contain multiple different placeholders.

A find pattern might contain the same placeholder multiple times.
This adds a constraint to the find process:
A match will only be found when all occurrences of the same placeholder are identical.
In analogy with [Regular Expressions](https://en.wikipedia.org/wiki/Regular_expression), 
the term backreference is used to denote a placeholder that reoccurs.


## placeholders in replace patterns

A placeholder in a replace pattern always refers to that placeholder in the find pattern.
A placeholder in a replace pattern that does not occur in the find pattern is thus an error.
A placeholder in the replace pattern will be replaced by the value of that placeholder in the match of the find pattern.
In analogy with [Regular Expressions](https://en.wikipedia.org/wiki/Regular_expression), 
all placeholders in a replace pattern can be called backreferences.

# Examples

## Double Negation

Find pattern for double negation
```ada
not (not $S_Condition)
```
Replace pattern to remove double negation
```ada
$S_Condition
```

## For All

Ada 2012 has [quantified expressions](http://www.ada-auth.org/standards/12rat/html/Rat12-3-4.html).

Find pattern for code that is equivalent to returning a `for all` expression
```ada
for $S_Element of $S_Elements loop 
    if $S_Condition then return false; end if; 
end loop;
return true;
```
Replace pattern to change the code to use the `for all` expression
```ada
return (for all $S_Element of $S_Elements => not ($S_Condition));
```

## Real World

With the previous two find and replace patterns code found in the [semantic versioning](
https://github.com/alire-project/semantic_versioning) project:

[<img src="https://user-images.githubusercontent.com/18348654/189627879-93b787b0-853f-4943-b536-98b8fe8f41ac.png" width="350"/>](
https://github.com/alire-project/semantic_versioning/blob/cc69201134c0a8d695b767a1fd1bf4fd8f6f3880/src/semantic_versioning-basic.adb#L81-L87])

could be simplified into
```ada
 return (for all R of VS => Satisfies (V, R));
```

See 
the [examples](examples), 
the [workshop](workshop), and 
the [tests](tests)
for inspiration to use the Rejuvenation Library.

# Tools made using Rejuvenation
* [Find Tool](find_tool) finds a pattern in a given project
* [Find And Replace Tool](find_and_replace_tool) finds a pattern and replaces it with another in a given project

[![Alire](https://img.shields.io/endpoint?url=https://alire.ada.dev/badges/rejuvenation.json)](https://alire.ada.dev/crates/rejuvenation.html)
