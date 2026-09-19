/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Deterministic.Validity
import FormalSystem.Metalogic.Deterministic.Erasure
import FormalSystem.Metalogic.Deterministic.Engines
import FormalSystem.Metalogic.Deterministic.System
import FormalSystem.Metalogic.Deterministic.Soundness
import FormalSystem.Metalogic.Deterministic.Collapse
import FormalSystem.Metalogic.Deterministic.Completeness

/-!
# `Metalogic/Deterministic/` — the deterministic metatheory of TM⁺

Aggregator for the subtree carrying the deterministic-frame metatheory of TM⁺: the validity
notions restricted to `TaskFrame.Deterministic`, the determinism of the completeness engines'
own countermodel frames, the `⊡`-erasure and the semantic collapse, the extended system
TM⁺ + *Determined*, and the deterministic completeness theorem with the coincidence corollary.

**General (nondeterministic) TM⁺ completeness is not here, and is not stated anywhere in this
tree.** For the current axiom set it is false at `.Base`
(`Metalogic/Independence/PlusIncompleteness.lean`); for any extension it is open. The nearest
literature results are Reynolds (2003) and Zanardo (1991).
-/
