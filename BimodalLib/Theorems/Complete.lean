/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem
import BimodalLib.Theorems.Boolean.Base
import BimodalLib.Theorems.Enumerated.Base
import BimodalLib.Theorems.ModalBoolean.Base
import BimodalLib.Theorems.ModalTemporalBoolean.Base
import BimodalLib.Theorems.TemporalBoolean.Base
import BimodalLib.Theorems.TemporalBoolean.Dense
import BimodalLib.Theorems.TemporalBoolean.RTime
import BimodalLib.Theorems.TemporalBoolean.ZTime
import BimodalLib.ProofFragment
import BimodalLib.Subsumption
import BimodalLib.Registry.Complete

/-!
# The registry is complete

This module runs the registration check over the published library. It imports the root
`FormalSystem`, so that every module under `FormalSystem/Theorems/` is in scope, and every
registration module. It fails to build when a closed derivation declared under
`FormalSystem/Theorems/`, outside its `ProofMode/` directory, has no `register_theorem` line.

It then runs the proof-fragment check: the module fails to build when a registered theorem whose
reference proof leaves the cell of its statement has neither a proved conservativity edge out of
that cell nor a reason recorded with `record_proof_fragment`.

Finally it runs the non-redundancy check over the machine-generated entries, which is a build
invariant for them and only for them -- see the comment at the wiring site below.
-/

assert_registry_complete

assert_proof_fragments_recorded

-- The PREFIX IS DELIBERATE and the check must not be "completed" by deleting it. Scoped to
-- `BimodalLib.Theorems.Enumerated`, the invariant reads: every machine-generated entry is
-- non-redundant against every row in scope. Only the CANDIDATE side is scoped; the comparison
-- side still ranges over the whole registry, so a generated entry that duplicates a
-- hand-curated law is still caught, which is the property the pipeline's ADMISSION rule asks
-- for. Unscoped, the same command reports 26 of the 190 live rows as substitution instances of
-- another row, and those 26 are deliberate named laws rather than defects --
-- `Combinators.topThm : ⊤` is `Combinators.identity` at `⊥` and its own proof term is literally
-- `identity Formula.bot`; `Propositional.em : A ∨ ¬A` unfolds to `(A → ⊥) → (A → ⊥)`, an
-- instance of `A → A`. The reference manual cites them, so they are out of scope here rather
-- than exempted: there is no baseline file and no ledger row for them anywhere.
assert_no_subsumed_entries BimodalLib.Theorems.Enumerated
