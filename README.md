[![vote for Rejuvenation-Ada as The 2022 Ada Crate Of The Year](https://user-images.githubusercontent.com/18348654/191469254-1ca1f4a0-6242-43fa-94a2-f39f55817fdc.jpg)](https://github.com/AdaCore/Ada-SPARK-Crate-Of-The-Year/issues/15)

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

## placeholders in find patterns

A find pattern might contain multiple different placeholders.

A find pattern might contain the same placeholder multiple times.
This adds a constraint to the find process:
A match will only be found when all occurrences of the same placeholder are identical.
In analogy with [Regular Expressions](https://en.wikipedia.org/wiki/Regular_expression), 
the term [backreference](https://en.wikipedia.org/wiki/Regular_expression#backreferences) is used to denote a placeholder that reoccurs.

The placeholder `$S_Dest` in the following find pattern
```ada
if $S_Cond then
   $S_Dest := True;
else
   $S_Dest := False;
end if;
```
ensures that the same destination is used in both branches of the if statement.

## placeholders in replace patterns

A placeholder in a replace pattern always refers to that placeholder in the find pattern.
A placeholder in a replace pattern that does not occur in the find pattern is thus an error.
A placeholder in the replace pattern will be replaced by the value of that placeholder in the match of the find pattern.
In analogy with [Regular Expressions](https://en.wikipedia.org/wiki/Regular_expression), 
all placeholders in a replace pattern can be called [backreference](https://en.wikipedia.org/wiki/Regular_expression#backreferences).

The following replace pattern 
```ada
$S_Dest := $S_Cond;
```
simplifies the code found with the previous find pattern using the backreferences `$S_Cond` and `$S_Dest`.

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
When migrating code from earlier versions of Ada to Ada 2012 or beyond, the code should use these [quantified expressions](http://www.ada-auth.org/standards/12rat/html/Rat12-3-4.html).
Furthermore, not all programming languages support [quantified expressions](http://www.ada-auth.org/standards/12rat/html/Rat12-3-4.html). 
Hence, programmers educated in other languages might not be aware of [quantified expressions](http://www.ada-auth.org/standards/12rat/html/Rat12-3-4.html).

The following find pattern will detect all code that is equivalent to returning a `for all` expression
```ada
for $S_Element of $S_Elements loop 
    if $S_Condition then return false; end if; 
end loop;
return true;
```
The following replace pattern will change the found code to use the `for all` expression
```ada
return (for all $S_Element of $S_Elements => not ($S_Condition));
```

## Real World

With the previous two find and replace patterns code found in the [semantic versioning](
https://github.com/alire-project/semantic_versioning) project:

[<img src="https://user-images.githubusercontent.com/18348654/189627879-93b787b0-853f-4943-b536-98b8fe8f41ac.png" width="350"/>](
https://github.com/alire-project/semantic_versioning/blob/cc69201134c0a8d695b767a1fd1bf4fd8f6f3880/src/semantic_versioning-basic.adb#L81-L87])

could be automatically simplified into
```ada
 return (for all R of VS => Satisfies (V, R));
```

## More Examples

See 
the [examples](examples), 
the [workshop](workshop), and 
the [tests](tests)
for inspiration to use the Rejuvenation Library.

# Design

## Dependencies

The rejuvenation crate exploits the power of the abstract syntax as provided by [Libadalang](https://adaco.re/libadalang), 
making the analysis and manipulation insensitive for layout and the presence of comments. 
Yet, its interface does not expose [Libadalang](https://adaco.re/libadalang)'s abstract syntax. 
Instead, its interface is almost identical to the concrete syntax of the Ada programming language. 

The Rejuvenation-Ada library delegates the actual pretty-printing to `gnatpp` from the [libadalang-tools](https://github.com/AdaCore/libadalang-tools).
The Rejuvenation-Ada library assumes that `gnatpp` is accessable on your system `PATH`.
`gnatpp` can be installed using [Alire](https://alire.ada.dev/docs/#installation) using the command `alr get --build libadalang_tools`.

## Usage
Starting points for using the Rejuvenation-Ada library include:
* find and replace based on concrete patterns using [`Rejuvenation.Finder`](src/rejuvenation-finder.ads) and [`Rejuvenation.Find_And_Replacer`](src/rejuvenation-find_and_replacer.ads);
* programmatically analyze and manipulate using [`Rejuvenation.Text_Rewrites`](src/rejuvenation-text_rewrites.ads) to manipulate text and [`Rejuvenation.Match_Patterns`](src/rejuvenation-match_patterns.ads) to inspect a found match;
* select the part, e.g. text, file, directory, or project, for analysis and manipulation using [`Rejuvenation.Simple_Factory`](src/rejuvenation-simple_factory.ads) and [`Rejuvenation.Factory`](src/rejuvenation-factory.ads); and
* pretty print the manipulated code only, using [`Rejuvenation.Pretty_Print`](src/rejuvenation-pretty_print.ads).

# Tools made using Rejuvenation
* [Find Tool](find_tool) finds a pattern in a given project
* [Find And Replace Tool](find_and_replace_tool) finds a pattern and replaces it with another in a given project

[![Alire](https://img.shields.io/endpoint?url=https://alire.ada.dev/badges/rejuvenation.json)](https://alire.ada.dev/crates/rejuvenation.html)
