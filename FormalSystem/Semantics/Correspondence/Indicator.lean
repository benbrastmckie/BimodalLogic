/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Correspondence.Galois

/-!
# Indicator exactness for the dense and paper-Discrete classes

`X⊤ = Formula.next Formula.top = U(⊤, ⊥)` says "the current time has an immediate successor". Its
truth clause unfolds to

```
∃ s, t < s ∧ True ∧ ∀ r, t < r → r < s → False
```

which mentions no atom: the valuation is never consulted, so `X⊤`'s frame-relative validity is a
pure order condition on the frame's duration group. Two of them, in fact, and they are the
*exact* order conditions:

* `F ⊨ ¬X⊤` iff `F.Duration` is densely ordered — `validOn_neg_nextTop_iff`;
* `F ⊨ X⊤` iff every point of `F.Duration` has an immediate successor —
  `validOn_nextTop_iff`, equivalently `F.IsDiscrete` by `validOn_nextTop_iff_isDiscrete`.

**No ordered-group homogeneity argument is involved.** `DenselyOrdered` is literally
`∀ a b, a < b → ∃ c, a < c ∧ c < b`, which is the falsity condition of `X⊤` on the nose; the
biconditional is not obtained by transporting a condition at `0` along translations.

Each of the two is an *indicator* in the sense of `Galois.galoisClosed_of_indicator`, so both
closure results below are single applications of its iff-shaped entry point
`galoisClosed_of_indicator_iff`, with no per-class argument.

## The closed and the not-closed, in one place

The two corollaries below are the **closed** half of a four-part picture; the other half lives in
`Metalogic/Independence/`, and the two halves are only intelligible together:

| Class | Closed? | Where |
|---|---|---|
| `FrameClass.Sat FrameClass.Dense` | yes | `galoisClosed_sat_dense`, below |
| `{F \| F.IsDiscrete}` (the paper's bare clause) | yes | `galoisClosed_isDiscrete`, below |
| `FrameClass.Sat FrameClass.Discrete` | **no** | `LexIntWitness.lean`'s `sat_discrete_ssubset_mod_axiomSet` |
| `FrameClass.Sat FrameClass.Dedekind` | **no** | `RationalWitness.lean`'s `sat_dedekind_ssubset_mod_axiomSet` |

### Why the Discrete row splits

`TaskFrame.IsDiscrete` — `def:frame-properties`' bare Discrete clause, guarded by `(∃ y, x < y)` —
is the class `X⊤` indicates, and it *is* Galois-closed (`galoisClosed_isDiscrete`).

`FrameClass.Sat FrameClass.Discrete` is `TaskFrame.IsSuccArchDiscrete`, `def:TMplus-f`'s Hölder
narrowing to ℤ-time. It is strictly stronger, and it is **not** Galois-closed —
`Metalogic/Independence/LexIntWitness.lean` exhibits a frame over `ℤ ×ₗ ℤ` inside
`Mod (AxiomSet .Discrete)` and outside it. Stating the closure corollary below over
`Sat .Discrete` would therefore contradict that witness. The corollary is over `{F | F.IsDiscrete}`
and must stay there.

The Dedekind row does not split the same way: `Sat .Dense` (the row that *is* closed) is the
paper's bare Dense clause, while `Sat .Dedekind` adds Dedekind completeness, which
`RationalWitness.lean`'s static frame over `ℚ` satisfies axiomatically without satisfying
semantically.

## Main results

* `validOn_neg_nextTop_iff` — IND-D: `¬X⊤` indicates density
* `validOn_nextTop_iff` — IND-F: `X⊤` indicates immediate successors
* `validOn_nextTop_iff_isDiscrete` — the same, against the paper's guarded predicate
* `galoisClosed_sat_dense` — `Sat .Dense` is Galois-closed
* `galoisClosed_isDiscrete` — `{F | F.IsDiscrete}` is Galois-closed
-/

namespace FormalSystem.Semantics

open FormalSystem.Syntax FormalSystem.ProofSystem

/-! ## Indicator exactness -/

/--
**IND-D.** `¬X⊤` is valid on `F` exactly when `F`'s duration group is densely ordered.

(⇐) is immediate: density fills every open interval, so the guard `∀ r ∈ (t, s), ⊥` can never be
met. (⇒) is the contrapositive: if some interval `(a, b)` is empty then `X⊤` is true at `a`, and
the model and history needed to witness that come from `TaskModel.allFalse` and
`TaskFrame.hF_nonempty_of_frameAxioms` — the latter wholly frame-intrinsic, so no side condition
leaks into the statement.
-/
theorem validOn_neg_nextTop_iff (F : TaskFrame) :
    F.ValidOn (Formula.next Formula.top).neg ↔ DenselyOrdered F.Duration := by
  constructor
  · intro h
    refine ⟨fun {a b} hab => ?_⟩
    by_contra hno
    obtain ⟨τ⟩ := TaskFrame.hF_nonempty_of_frameAxioms F
    exact h TaskModel.allFalse τ a ⟨b, hab, fun hb => hb, fun r hr1 hr2 => hno ⟨r, hr1, hr2⟩⟩
  · intro hd M τ t hc
    obtain ⟨s, hts, _, hg⟩ := hc
    obtain ⟨c, hc1, hc2⟩ := hd.dense t s hts
    exact hg c hc1 hc2

/--
**IND-F.** `X⊤` is valid on `F` exactly when every point of `F`'s duration group has an
immediate successor.

This is the raw order statement, without the paper's `(∃ y, x < y)` guard;
`validOn_nextTop_iff_isDiscrete` supplies the guarded form.
-/
theorem validOn_nextTop_iff (F : TaskFrame) :
    F.ValidOn (Formula.next Formula.top) ↔ ∀ x : F.Duration, ∃ y, IsLeast {z | x < z} y := by
  constructor
  · intro h x
    obtain ⟨τ⟩ := TaskFrame.hF_nonempty_of_frameAxioms F
    obtain ⟨s, hxs, _, hg⟩ := h TaskModel.allFalse τ x
    refine ⟨s, hxs, fun z hz => ?_⟩
    by_contra hlt
    exact hg z hz (not_le.mp hlt)
  · intro hdisc M τ t
    obtain ⟨y, hy1, hy2⟩ := hdisc t
    exact ⟨y, hy1, fun hb => hb, fun r hr1 hr2 => absurd (hy2 hr1) (not_le.mpr hr2)⟩

/--
**IND-F against the paper's predicate.** `X⊤` is valid on `F` exactly when `F.IsDiscrete`.

`TaskFrame.IsDiscrete` carries `def:frame-properties`' guard `(∃ y, x < y) →`, which
`validOn_nextTop_iff` does not. Discharging it is the one step past the raw statement, and it is
available because `Nontrivial` is a *field* of `TemporalOrder`: `TaskFrame.exists_pos_of_nontrivial`
supplies a positive duration `p`, so `x < x + p` witnesses the guard at every `x`. Without that
step the two conditions are inequivalent on a trivial carrier — which is exactly why the paper
writes the guard.
-/
theorem validOn_nextTop_iff_isDiscrete (F : TaskFrame) :
    F.ValidOn (Formula.next Formula.top) ↔ F.IsDiscrete := by
  rw [validOn_nextTop_iff]
  refine ⟨fun h x _ => h x, fun h x => h x ?_⟩
  obtain ⟨p, hp⟩ := TaskFrame.exists_pos_of_nontrivial (D := F.Duration.carrier)
  exact ⟨x + p, lt_add_of_pos_right x hp⟩

/-! ## The two closure corollaries -/

/--
**The dense class is Galois-closed**: `Mod (Th (Sat .Dense)) = Sat .Dense`.

One application of `galoisClosed_of_indicator_iff` at `φ := ¬X⊤`, handed
`validOn_neg_nextTop_iff` whole — the iff entry point absorbs the split into `hmem` and `hback`
that the two-argument form would need.

`Sat .Dense` unfolds to `TaskFrame.IsDense`, which is `DenselyOrdered F.Duration`, so no
translation between the two spellings is needed. Note that no proof theory enters: that `¬X⊤` is
also `Axiom.dense_indicator` (whose `minFrameClass` is `.Dense` by `rfl`) is rhetorically apt but
plays no role in the argument.
-/
theorem galoisClosed_sat_dense :
    GaloisClosed {F : TaskFrame | FrameClass.Sat FrameClass.Dense F} :=
  galoisClosed_of_indicator_iff _ validOn_neg_nextTop_iff

/--
**The paper-Discrete class is Galois-closed**: `Mod (Th {F | F.IsDiscrete}) = {F | F.IsDiscrete}`.

One application of `galoisClosed_of_indicator_iff` at `φ := X⊤`, handed
`validOn_nextTop_iff_isDiscrete` whole.

**This is `TaskFrame.IsDiscrete`, the paper's bare Discrete clause — NOT
`FrameClass.Sat FrameClass.Discrete`.** The latter is `TaskFrame.IsSuccArchDiscrete`, the ℤ-time
narrowing, and it is *not* Galois-closed: `Metalogic/Independence/LexIntWitness.lean` exhibits a
frame over `ℤ ×ₗ ℤ` that models every `.Discrete` axiom without being successor-Archimedean.
Restating this corollary over `Sat .Discrete` would contradict that witness.
-/
theorem galoisClosed_isDiscrete :
    GaloisClosed {F : TaskFrame | F.IsDiscrete} :=
  galoisClosed_of_indicator_iff _ validOn_nextTop_iff_isDiscrete

/-- Spot-check of the framing in `galoisClosed_sat_dense`'s docstring: `Axiom.dense_indicator`'s
`minFrameClass` really is `FrameClass.Dense`, by `rfl`. -/
example : Axiom.dense_indicator.minFrameClass = FrameClass.Dense := rfl

end FormalSystem.Semantics
