import Logos.Core.Frame
import Logos.Core.Syntax

/-!
# Logos Core - Intensional Extension Layer

This module exports the Core Extension for Logos, providing
task-based intensional semantics with modal, temporal, and counterfactual operators.

## Overview

The Core Extension provides:
- Temporal structure (totally ordered abelian group)
- Task relation with mereological constraints
- State modality concepts (possible, compatible, maximal, world-state)
- World-history structures for temporal evaluation
- (Upcoming) Modal, temporal, and counterfactual operators

## Submodules

- `Core.Frame`: Core frame with task relation and state modality
- `Core.Syntax`: Core formula type (Phase 5)
- `Core.Truth`: Truth evaluation (Phase 6)

## Usage

```lean
import Logos.Core

open Logos.Core

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
