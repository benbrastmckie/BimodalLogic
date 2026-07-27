/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.VecEAFormula

/-!
# The Prop 4.2 vacuity guard

**Read this before treating `neg_2var_vec_ea` (`EANegationClosure.lean:722`) as a proved
asset.** It is not. Its conclusion says nothing about negation, and this file proves that
mechanically.

## What is refuted

`neg_2var_vec_ea` concludes

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

This file does not claim `neg_2var_vec_ea` is broken, unproved, or unsound. It is sorry-free,
its axiom set is clean, and it builds green. **Those facts are all true and all beside the
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
(`Boneyard/NegationIndep.lean:315`) already has this shape structurally, and its forward
direction (`_correct`, `:319`) is contentful and proved.

Cite Rabinovich by PDF page only. The companion `.md` conversion is corrupt (it drops
displayed equations and inverts `k ≠ m` to `k = m`).

## Why this file exists

This vacuity has been independently discovered, written down in-tree, and then re-mis-read as
a proved asset **at least twice**:

* `Prop43.lean:120-129` records it directly: *"the per-model existential statement is
  vacuous ... This is the same vacuity that the codebase's `neg_2var_vec_ea` / `neg_vec_ea_m`
  carry — their conclusion `∃ v', v'.holds env` is likewise closed by `⟨tt, tt_holds⟩`."*
* `Boneyard/NegationIndep.lean:357-364` then adopts `neg_2var_vec_ea` as a "PRE-AUTHORIZED
  model-DEPENDENT interim" supplying the negation case for Prop 4.3, reasoning that it
  "introduces no new sorry or axiom" — the exact inference this file refutes.

Both records were dated, correct, and unread. The second sits in `Boneyard/`, which is **not
reachable** from `FormalSystem.lean` and therefore is not compiled, not checked, and not
surfaced by anything. Prose in an unreachable file protects nothing.

This file is reachable from the root (the import edge is landed in
`NfMultiAnchorBridge.lean`), so CI compiles it. If someone ever repairs `neg_2var_vec_ea`
into the contentful shape above, this guard will still compile — it constrains nothing — but
its docstring is the record of what the old shape did and did not establish.

## Live declarations still presenting the vacuous shape

Annotated in place; **deliberately not deleted** (they are consumed live):

* `neg_2var_vec_ea` (`EANegationClosure.lean:722`) — the origin.
* `reflatten_neg_step` (`NfMultiAnchorBridge/NavigatedSpine.lean:178`) — re-exports it
  verbatim, and so re-exports the vacuity.
-/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical

/-- **The conclusion of `neg_2var_vec_ea` (`EANegationClosure.lean:722`), proved from NOTHING.**

    This takes no `HasAttainedINF`, no input formula `v`, no `h_neg : ¬v.holds …`, and no
    `h_lt : z0 < z1` — yet it derives `neg_2var_vec_ea`'s exact conclusion. The all-`⊤` block
    witnesses it at any `z0`, `z1` in any structure.

    Therefore `neg_2var_vec_ea`'s hypotheses are inert and its conclusion carries no content
    about negation. It is **not** Rabinovich's Proposition 4.2 (2014, PDF p.6), which requires
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
  · simp [TemporalPred.eval_at, TemporalPred.top, Formula.top, temporal_truth]
  · simp [TemporalPred.eval_at, TemporalPred.top, Formula.top, temporal_truth]
  · exact (BracketFormula.trivial_holds M atomMap TemporalPred.top z0 z1).mpr
      (fun y _ _ => by
        simp [TemporalPred.eval_at, TemporalPred.top, Formula.top, temporal_truth])

end FormalSystem.Metalogic.WeakCanonical.Kamp
