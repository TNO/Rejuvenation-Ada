# Rejuvenation Find

Find matches of the given code snippet in your project.

We will refer to the given code snippet as the find pattern.

Find matches code based on their [AST](https://en.wikipedia.org/wiki/Abstract_syntax_tree).
So it is independent of layout and presence of comment.


## placeholders

There are two types of placeholders, those starting with "$S_" and those starting with "$M_".
Any alphanumeric string is allowed to follow after those prefixes.

"$S_" placeholders allow one to match a single AST node, be that a single expression, a single statement, a single argument, or anything else.
As long as Ada parses it to a single AST node, the "$S_" placeholders can match it.

"$M_" placeholders allow one to match a list of AST nodes, i.e., zero or more nodes.

## placeholders in find patterns

A find pattern might contain multiple different placeholders.

A find pattern might contain the same placeholder multiple times.
This add a constraint to the find process:
A match will only be found when all occurrence of the same placeholder are identical.
Note that universities are still researching what the best definition of identical is.
In analogy with [Regular Expressions](https://en.wikipedia.org/wiki/Regular_expression), 
the term backreference is used to denote a placeholder that reoccurs.

## Examples

### Double Negation

Find pattern for double negation
```ada
not (not $S_Condition)
```

### Type Definition

Find type definitions for access to procedures with a single parameter of type `Integer`.
```ada
type $S_P is access procedure ($S_I : Integer);
```

### For All

Ada 2012 has [quantified expressions](http://www.ada-auth.org/standards/12rat/html/Rat12-3-4.html).

Find pattern for code that is equivalent to returning a `for all` expression
```ada
for $S_Element of $S_Elements loop 
    if $S_Condition then return false; end if; 
end loop;
return true;
```

### Identical tail statement

Find pattern for if statement with an identical tail statement in the then- and else-branch.
```ada
   if $S_Cond then 
       $M_Stmts_True; $S_Tail;
   else 
       $M_Stmts_False; $S_Tail;
   end if;
```
