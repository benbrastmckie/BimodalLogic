/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.VecEAFormula

/-!
# The Prop 4.2 vacuity guard

**This file is the record of a deleted declaration.** `neg_2var_vec_ea` and its sole consumer
`reflatten_neg_step` are no longer in the tree. Read this before reinstating anything of that
shape, or before treating a statement of that shape as a proved asset: it is not one. Its
conclusion said nothing about negation, and this file proves that mechanically.

## What is refuted

The deleted `neg_2var_vec_ea` concluded

```
∃ v' : VVecEA2, v'.holds M atomMap z0 z1
```

from `h_INF`, `v`, `h_lt : z0 < z1`, and `h_neg : ¬v.holds M atomMap z0 z1`. That conclusion
asserts **no relation whatsoever** between the produced `v'` and the negated input `v`. `v`
does not occur in it. So the statement cannot express "the negation of `v` is a `VVecEA2`" —
it expresses only "some `VVecEA2` holds at `(z0, z1)`", which is true unconditionally,
witnessed by the all-`⊤` block.

`prop42_conclusion_is_vacuous` below proves exactly that conclusion from **nothing**: no
`h_INF`, no `v`, no `h_neg`, no `h_lt`. Since the conclusion is derivable with none of the
hypotheses, the hypotheses carry no weight, and neither does the theorem.

## What this does NOT say

This file does not claim `neg_2var_vec_ea` was broken, unproved, or unsound. It was sorry-free,
its axiom set was clean, and it built green. **Those facts are all true and all beside the
point.** None of them test whether the statement says anything. A vacuous statement is
perfectly provable — that is what makes this failure mode invisible to every check the build
performs. Do not read a green build as evidence against this file.

## The contentful target

Rabinovich's actual Proposition 4.2 (Rabinovich 2014, *Proof of Kamp's Theorem*, **PDF p.6**)
asserts that the negation of a vec-EA formula **is itself expressible** as a vec-EA formula.
Faithfully rendered, the witness must be tied to the input:

```
∃ v', ∀ z0 z1, z0 < z1 → (v'.holds M atomMap z0 z1 ↔ ¬v.holds M atomMap z0 z1)
```

with `v'` a function of `v` alone. The biconditional and the `∀ z0 z1` are what make the
statement contentful; dropping either recovers the vacuous form. `neg_2var_vec_ea_indep`
(in `Boneyard/`, `NegationIndep.lean`) already has this shape structurally, and its forward
direction `neg_2var_vec_ea_indep_correct` in the same file is contentful and proved.

Cite Rabinovich by PDF page only. The companion `.md` conversion is corrupt (it drops
displayed equations and inverts `k ≠ m` to `k = m`).

## Why this file exists

This vacuity has been independently discovered, written down in-tree, and then re-mis-read as
a proved asset **at least twice**:

* `Prop43.lean` (in `Boneyard/`) records it directly: *"the per-model existential statement is
  vacuous ... This is the same vacuity that the codebase's `neg_2var_vec_ea` / `neg_vec_ea_m`
  carry — their conclusion `∃ v', v'.holds env` is likewise closed by `⟨tt, tt_holds⟩`."*
* `NegationIndep.lean` (in `Boneyard/`) then adopts `neg_2var_vec_ea` as a "PRE-AUTHORIZED
  model-DEPENDENT interim" supplying the negation case for Prop 4.3, reasoning that it
  "introduces no new sorry or axiom" — the exact inference this file refutes.

Both records were dated, correct, and unread. The second sits in `Boneyard/`, which is **not
reachable** from `FormalSystem.lean` and therefore is not compiled, not checked, and not
surfaced by anything. Prose in an unreachable file protects nothing.

This file is reachable from the root (the import edge is landed in
`NfMultiAnchorBridge.lean`), so CI compiles it. If someone ever builds the contentful shape
above, this guard will still compile — it constrains nothing — but its docstring is the record
of what the deleted shape did and did not establish.

## Declarations deleted for presenting the vacuous shape

Both are **gone from the tree**. They were quarantined rather than load-bearing:
`neg_2var_vec_ea` had exactly one consumer, `reflatten_neg_step`, and that consumer had none.
Deleting the pair therefore cost nothing and ended the standing risk of either being re-read
as a landed Prop 4.2.

* `neg_2var_vec_ea` (was in `EANegationClosure.lean`) — the origin.
* `reflatten_neg_step` (was in `NfMultiAnchorBridge/NavigatedSpine.lean`) — re-exported it
  verbatim, and so re-exported the vacuity.

Nothing downstream broke, because nothing downstream consumed either. Do not reinstate the
shape; build the contentful target above instead.
-/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical

/-- **The conclusion of the deleted `neg_2var_vec_ea`, proved from NOTHING.**

    This takes no `HasAttainedINF`, no input formula `v`, no `h_neg : ¬v.holds …`, and no
    `h_lt : z0 < z1` — yet it derives that theorem's exact conclusion. The all-`⊤` block
    witnesses it at any `z0`, `z1` in any structure.

    Therefore `neg_2var_vec_ea`'s hypotheses were inert and its conclusion carried no content
    about negation. It was **not** Rabinovich's Proposition 4.2 (2014, PDF p.6), which requires
    the witness to be tied to the negated input by a biconditional. See this file's module
    docstring for the contentful target. -/
theorem prop42_conclusion_is_vacuous {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (z0 z1 : M.carrier) :
    ∃ v' : VVecEA2, v'.holds M atomMap z0 z1 := by
  refine ⟨⟨[⟨0, { endpointLeft := TemporalPred.top,
                   endpointRight := TemporalPred.top,
                   bracket := BracketFormula.trivial TemporalPred.top }⟩]⟩,
          ⟨0, _⟩, List.mem_singleton.mpr rfl, ?_, ?_, ?_⟩
  · simp [TemporalPred.EvalAt, TemporalPred.top, Formula.top, TemporalTruth]
  · simp [TemporalPred.EvalAt, TemporalPred.top, Formula.top, TemporalTruth]
  · exact (BracketFormula.trivial_holds M atomMap TemporalPred.top z0 z1).mpr
      (fun y _ _ => by
        simp [TemporalPred.EvalAt, TemporalPred.top, Formula.top, TemporalTruth])

end FormalSystem.Metalogic.WeakCanonical.Kamp
