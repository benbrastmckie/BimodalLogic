# LEAN 4 Syntax

## Overview
This file covers advanced LEAN 4 syntax relevant to expert users, focusing on metaprogramming, tactics, and custom notation.

## Key Syntactic Features

### Metaprogramming
LEAN 4's metaprogramming framework allows for writing custom tactics and manipulating expressions at compile time.

- **`MetaM` Monad**: The core of LEAN 4's metaprogramming, providing access to the compiler's internals.
- **`Expr`**: The data structure representing LEAN 4 expressions.
- **`Lean.Elab`**: The namespace for elaboration, the process of converting surface syntax into `Expr`.

### Tactic Framework
The tactic framework is used to write custom proof automation.

- **`TacticM` Monad**: A specialized version of `MetaM` for writing tactics.
- **`Lean.Parser.Tactic`**: The namespace for parsing tactic syntax.
- **`liftM`**: Lifts a `MetaM` computation into `TacticM`.

### Custom Notation
LEAN 4 allows for defining custom notation to make code more readable.

- **`notation`**: The command for defining new notation.
- **`infix`, `prefix`, `postfix`**: Keywords for defining the type of notation.

## Examples

### Custom Tactic
```lean
import Lean

open Lean Elab Tactic

elab "my_tactic" : tactic => do
  let goal ← getMainGoal
  goal.withContext do
    let target ← getMainTarget
    logInfo m!"Current target: {target}"
```

### Custom Notation
```lean
notation:50 a " ⊕ " b => a + b
```
