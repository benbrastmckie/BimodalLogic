import Logos.SubTheories.Explanatory.Frame
import Logos.SubTheories.Explanatory.Syntax
import Logos.SubTheories.Explanatory.Truth

/-!
# Logos Explanatory Extension Layer

This module exports the Explanatory Extension for Logos, providing
task-based intensional semantics with modal, temporal, and counterfactual operators.

## Overview

The Explanatory Extension provides:
- Temporal structure (totally ordered abelian group)
- Task relation with mereological constraints
- State modality concepts (possible, compatible, maximal, world-state)
- World-history structures for temporal evaluation
- Modal, temporal, and counterfactual operators

## Submodules

- `Explanatory.Frame`: Frame with task relation and state modality
- `Explanatory.Syntax`: Formula type
- `Explanatory.Truth`: Truth evaluation

## Usage

```lean
import Logos.SubTheories.Explanatory

open Logos.SubTheories.Explanatory

-- Use state modality concepts
variable {T : Type*} [LinearOrderedAddCommGroup T]
variable {F : CoreFrame T}
variable (s : F.State)

#check CoreFrame.possible s      -- s ⇒_0 s
#check CoreFrame.world_state s   -- maximal possible state
```

## References

- Logos/Documentation/Research/RECURSIVE_SEMANTICS.md - Full specification
- Logos/Documentation/Research/LAYER_EXTENSIONS.md - Extension architecture
-/
