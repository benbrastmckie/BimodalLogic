/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Embed
import FormalSystem.Metalogic.Decidability.WitnessFamily.Sharing.Specialize

/-!
# Non-Vacuity of the Time-Sliced Certificate Class

This module is the sliced class's **non-vacuity record**: an exhibited, closed-term inhabitant of
`PlusSlicedCertificate.Certifies` at a non-empty closure with a live `untl` obligation, proved by
the kernel's own evaluation of `decidableCertifies`. It exists because a condition set that is
only ever *satisfiable* certifies nothing: a vacuously satisfiable set of clauses type-checks
indefinitely, and the one defect this programme exists to remove — a clause that collapsed to a
triviality under a reflexive guard — survived undetected for exactly as long as no non-trivial
inhabitant had been written down.

## The vocabulary, and where it comes from

The words are those of Beer, Ben-David, Eisner and Rodeh, *Efficient Detection of Vacuity in
Temporal Model Checking* (Formal Methods in System Design 18(2), 2001). A formula is satisfied
**vacuously** in a model when some sub-formula does not *affect* it — when it could be replaced by
anything without changing the verdict; the propositional special case, a conditional whose
antecedent is never true, is **antecedent failure**; and an **interesting witness** is a model
that satisfies the formula non-vacuously. Their notion is post hoc and model-relative, so no
algorithm of theirs is ported here. What transfers is the criterion: a witness counts only if it
does not satisfy the condition for a degenerate reason.

Read at a certificate class, the degenerate reason is an empty closure. `Complete.lean`'s
`Probe.exists_certifying_triv` sits at the empty context, where every closure-guarded clause of
`Certifies` quantifies over nothing — it is the class's **antecedent failure**, useful for showing
the completeness headline's hypothesis set is consistent and for nothing else. The witness below
is the **interesting** one: `Embedded.evTarget` is `p U q`, so the closure carries an `untl`
obligation, the embedded lasso genuinely labels it and genuinely discharges it, and negating the
`untl` clause's body at that position would flip the verdict. That is the sense in which the
clause *affects* `Certifies` here and not at `triv`.

## The sharing class, for the same reason

`SharingWitnessFamily.Certifies` had no closed-term inhabitant either: every certifying family in
the tree is a deterministic `WitnessFamily`. `Sharing/Specialize.lean`'s `certifies_toSharing`
lifts one in a single line, and the lifted witness is recorded beside the sliced one so that every
certifying predicate under `Decidability/` carries an exhibited interesting witness.

## Main Results

- `WitnessFamily.Embedded.liveFamily_sliced_certifies` — **the sliced class's interesting
  witness**: the embedded certificate of the live family certifies, by `decide`
- `WitnessFamily.Embedded.liveFamily_toSharing_certifies` — the sharing class's interesting
  witness, lifted from `liveFamily_certifies`

## Tags

plus-language · certificate · time-sliced · non-vacuity · interesting witness
-/

namespace FormalSystem.Metalogic.Decidability

namespace WitnessFamily

namespace Embedded

/-- **The sliced class's interesting witness.** The embedded certificate of `liveFamily` — slice
width `1`, six window times, target `p U q` at time `-1` — satisfies all nine clauses of
`Certifies`, at a closure that carries an `untl` obligation the lasso discharges. Compare
`Probe.exists_certifying_triv`, the class's antecedent failure at the empty closure. -/
theorem liveFamily_sliced_certifies : (liveFamily.sliced (-1)).Certifies := by decide

/-- **The sharing class's interesting witness**, lifted from the deterministic one: the
branching bundle at the diagonal is inhabited at the same closure and the same time. -/
theorem liveFamily_toSharing_certifies : liveFamily.toSharing.Certifies (-1) :=
  certifies_toSharing _ liveFamily_certifies

end Embedded

end WitnessFamily

end FormalSystem.Metalogic.Decidability
