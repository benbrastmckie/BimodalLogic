/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.BLTruth
import FormalSystem.Semantics.DurationClassification

/-!
# DF and DN semantic lemmas, and their past-duals

The four semantic facts consumed by both `Metalogic/SpWitness.lean` (the (Sp) validity witness)
and `Metalogic/BaseLanguageSoundness.lean`'s `bl_soundness_discrete_succ` — the shared
mathematical core of the TM-completeness task (report §4.1 Lemmas B and C, plus §6.1's
past-dual obligation).

## The two axiom shapes, pinned

`BaseLanguage.Axiom.df φ : Axiom (((φ.allPast.and φ).and BLFormula.top.someFuture).imp
φ.allPast.someFuture)` — **DF**, `(Hφ ∧ φ ∧ F⊤) → F(Hφ)`. `BaseLanguage.Axiom.dn φ :
Axiom (φ.allFuture.allFuture.imp φ.allFuture)` — **DN**, `GGφ → Gφ`. Every lemma below states
truth of exactly these formula expressions (not through the `Axiom` type, which is
proof-relevant and indexed by the formula rather than a function producing one), so that the
association is checked by elaboration against `BaseLanguage/Axioms.lean`'s own definitions.

## Main Results

- `df_valid_of_isLeast_pos` — **Lemma B, least-positive form**: if `F.Duration` has a least
  strictly positive element, DF is true everywhere.
- `df_valid_of_succOrder` — **Lemma B, `SuccOrder` form**: the `[SuccOrder F.Duration]` corollary,
  via `DurationClassification.isLeast_pos_succ_zero`.
- `dn_valid_of_denselyOrdered` — **Lemma C**: if `F.Duration` is densely ordered, DN is true
  everywhere.
- `swapBL_df_valid_of_predOrder` — **the past-dual of Lemma B**: `swapBL (Axiom.df φ)` —
  `(Gφ ∧ φ ∧ P⊤) → P(Gφ)` — is true everywhere under `[PredOrder F.Duration]`.

## References

* `specs/495_determine_tm_completeness_status_over_task_frames/reports/01_tm-completeness-status.md`
  §4.1 (Lemmas B and C), §6.1 (the past-dual obligation)
* `FormalSystem/BaseLanguage/Axioms.lean` — `Axiom.df`, `Axiom.dn`
* `FormalSystem/Semantics/DurationClassification.lean` — `isLeast_pos_succ_zero`
-/

namespace FormalSystem.Semantics

open FormalSystem.BaseLanguage

variable {F : TaskFrame}

/-! ## Lemma B — DF -/

/--
**Lemma B, least-positive form.** If `F.Duration` has a least strictly positive element `d`,
then DF — `(Hφ ∧ φ ∧ F⊤) → F(Hφ)` — is true at every model, history and time.

Witness `F(Hφ)` at `s := t + d`: `t < s` since `0 < d`; and every `u < s` satisfies `u ≤ t`
(else `0 < u - t < d`, contradicting `d`'s minimality), so `Hφ` (giving `φ` at every `u < t`) or
`φ` itself (at `u = t`) supplies `φ(u)` in both sub-cases.
-/
theorem df_valid_of_isLeast_pos {d : F.Duration} (hd : IsLeast {x : F.Duration | 0 < x} d)
    (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (φ : BLFormula) :
    BLTruthAt M τ t
      (((φ.allPast.and φ).and BLFormula.top.someFuture).imp φ.allPast.someFuture) := by
  simp only [BLTruth.imp_iff, BLTruth.and_iff, BLTruth.someFuture_iff, BLTruth.past_iff]
  rintro ⟨⟨hHφ, hφ⟩, -⟩
  refine ⟨t + d, lt_add_of_pos_right t hd.1, ?_⟩
  intro u hu
  rcases lt_trichotomy u t with hut | hut | hut
  · exact hHφ u hut
  · rw [hut]; exact hφ
  · exfalso
    have h1 : 0 < u - t := sub_pos.mpr hut
    have h2 : d ≤ u - t := hd.2 h1
    have h3 : u - t < d := sub_lt_iff_lt_add.mpr (by rw [add_comm]; exact hu)
    exact absurd (lt_of_le_of_lt h2 h3) (lt_irrefl d)

/--
**Lemma B, `SuccOrder` form.** The same conclusion under `[SuccOrder F.Duration]`, obtained from
the least-positive form via `DurationClassification.isLeast_pos_succ_zero` — `Order.succ 0` is a
least strictly positive element, so this is a corollary rather than a second direct proof.

**Documented exception: neither this nor `df_valid_of_isLeast_pos` can be replaced by transporting
a BL⁺ theorem across `tr`.** `tr` is exact only on `□, G, H, →, ⊥`; on `someFuture` it is not.
`tr φ.someFuture` is `(Formula.allFuture (tr φ).neg).neg`, a different constructor tree from
`Formula.someFuture (tr φ)` — recorded by proof as `tr_someFuture_ne`
(`BaseLanguage/Translation.lean`). Both DF statements have `F⊤` and `F(Hφ)` in them, so the
transfer theorems in `Metalogic/BaseLanguageSoundness.lean` do not reach them, and both proofs
stay native. Do not delete either as a duplicate of a BL⁺ result.
-/
theorem df_valid_of_succOrder [SuccOrder F.Duration] [Nontrivial F.Duration]
    (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (φ : BLFormula) :
    BLTruthAt M τ t
      (((φ.allPast.and φ).and BLFormula.top.someFuture).imp φ.allPast.someFuture) :=
  df_valid_of_isLeast_pos (isLeast_pos_succ_zero (D := F.Duration)) M τ t φ

/-! ## Lemma C — DN -/

/--
**Lemma C.** If `F.Duration` is densely ordered, DN — `GGφ → Gφ` — is true at every model,
history and time.

**Kept as a direct proof, deliberately.** DN mentions only `G` and `→`, on which `tr` *is* exact,
so this statement is in principle `Metalogic/Soundness.lean`'s `density_valid` transported across
`blValidOnFrames_iff_validOnFrames_tr`. It is not derived that way, because the transport would
require `Semantics/BLSchemaValidity.lean` to import `Metalogic/Soundness.lean` — inverting the
`Semantics/` → `Metalogic/` layering that the whole development rests on, to replace a five-line
self-contained proof. The two statements agree; that they are proved independently is a feature
here, not duplication to be collapsed.

Given `GGφ` at `t` and `t < s`, density supplies `t < r < s`; apply `GGφ` at `r` (giving `Gφ` at
`r`) then at `s`.
-/
theorem dn_valid_of_denselyOrdered [DenselyOrdered F.Duration]
    (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (φ : BLFormula) :
    BLTruthAt M τ t (φ.allFuture.allFuture.imp φ.allFuture) := by
  simp only [BLTruth.imp_iff, BLTruth.future_iff]
  intro hGG s hs
  obtain ⟨r, htr, hrs⟩ := exists_between hs
  exact hGG r htr s hrs

/-! ## The past-dual of Lemma B -/

/--
**The greatest strictly negative element, under `[PredOrder D]`.** The `Order.pred`/past mirror
of `DurationClassification.isLeast_pos_succ_zero`, proved locally here rather than added to
`DurationClassification.lean` (this task's Phase 1/Phase 3 territory split keeps the two files
disjoint): `Order.pred 0` is the greatest element below `0`.

`Order.pred_lt` gives membership (`Order.pred 0 < 0`; unconditional here because `D` is a
nontrivial ordered abelian group, hence has no minimum, exactly as `Order.lt_succ` is
unconditional in `isLeast_pos_succ_zero` because `D` has no maximum); `Order.le_pred_of_lt`
gives the upper-boundedness of the negative cone.
-/
private theorem isGreatest_neg_pred_zero {D : Type} [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] [PredOrder D] [Nontrivial D] :
    IsGreatest {y : D | y < 0} (Order.pred (0 : D)) :=
  ⟨Order.pred_lt (0 : D), fun _ hy => Order.le_pred_of_lt hy⟩

/--
**The past-dual of Lemma B.** Under `[PredOrder F.Duration]`, `swapBL (Axiom.df φ)` — which
unfolds to `(Gφ ∧ φ ∧ P⊤) → P(Gφ)`, the `H`/`G` and `F`/`P` interchange of DF — is true at every
model, history and time.

The `Order.pred` mirror of `df_valid_of_isLeast_pos`: witness `P(Gφ)` at `s := t + d` where
`d := Order.pred 0 < 0`, i.e. `s < t`; every `u > s` satisfies `u ≥ t` (else `u - t < 0` would be
`≤ d`, while `s < u` forces `d < u - t`, contradicting `d`'s maximality among negative elements),
so `Gφ` (future of `t`) or `φ` itself (at `u = t`) supplies `φ(u)`.
-/
theorem swapBL_df_valid_of_predOrder [PredOrder F.Duration] [Nontrivial F.Duration]
    (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (φ : BLFormula) :
    BLTruthAt M τ t
      (((φ.allFuture.and φ).and BLFormula.top.somePast).imp φ.allFuture.somePast) := by
  simp only [BLTruth.imp_iff, BLTruth.and_iff, BLTruth.somePast_iff, BLTruth.future_iff]
  rintro ⟨⟨hGφ, hφ⟩, -⟩
  set d := Order.pred (0 : F.Duration) with hd_def
  have hd : IsGreatest {y : F.Duration | y < 0} d := isGreatest_neg_pred_zero
  have hlt : t + d < t := by have := add_lt_add_left hd.1 t; simpa using this
  refine ⟨t + d, hlt, ?_⟩
  intro u hu
  rcases lt_trichotomy u t with hut | hut | hut
  · exfalso
    have h1 : u - t < 0 := sub_neg_of_lt hut
    have h2 : u - t ≤ d := hd.2 h1
    have h3 : d < u - t := lt_sub_iff_add_lt.mpr (by rw [add_comm]; exact hu)
    exact absurd (lt_of_le_of_lt h2 h3) (lt_irrefl (u - t))
  · rw [hut]; exact hφ
  · exact hGφ u hut

end FormalSystem.Semantics
