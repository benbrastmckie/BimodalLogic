/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.WitnessFamily.Compression.Extract
import FormalSystem.Metalogic.Decidability.WitnessFamily.Agreement
import FormalSystem.Semantics.IntTransfer

/-!
# The Compression Theorem

Every ℤ-time countermodel of `φ` compresses to a `WitnessFamily [] [φ]` that certifies the
refutation, with every lasso's three segments bounded by `compressionBound [] [φ]`, with at most
`|closure| + 1` lassos, and with a box guess of the **canonical, enumerable** form
`fun χ => decide (χ ∈ S)` for an explicit `S ⊆ closureOf ([] ++ [φ])`.

## The enumerability trap, and how the canonical form escapes it

`WitnessFamily.bx` is a function on the **infinite** type `Formula`, so a family is not naively
enumerable — the identical trap `BiLasso/Assembly.lean` records for `IntPresentation.val`, where
it is fatal. Here it is not, because `bx` is read **only** at `χ` with
`Formula.box χ ∈ closureOf (Γ ++ Del)`: in `LocalCoherentLab`'s box clause, in `BoxFaithful`, and
nowhere else.

So the escape is to fix the guess's *shape* in the compression theorem's own statement, not to
patch it afterwards. The guess is

```
S := (boxedPart C).filter (fun χ => ∀ σ v, TruthAt M σ v χ)      -- with `Classical.dec`
bx := fun χ => decide (χ ∈ S)
```

and the point of the construction is that **`S` is a genuine `Finset`**, so the guess
`fun χ => decide (χ ∈ S)` computes and is enumerated, even though the filter predicate does not
compute. The compression
builds its lassos against the unguarded truth oracle `fun χ => decide (∀ σ v, TruthAt M σ v χ)` —
which is what `exists_labelledLasso_of_history` demands and which is *not* of the canonical form,
since it is `true` at globally true formulas outside the closure — and then transports local
coherence onto the canonical guess by `localCoherentSeqLab_congr_bx`, the two agreeing exactly on
the guarded `χ`.

## The lasso list

`main :: (one per boxed closure member the guess sets false)`. The main lasso carries the
refutation; each witness lasso carries a position at which its `χ` fails, which is what makes
`BoxFaithful`'s reverse direction true rather than merely consistent. Hence the count bound
`W.lassos.length ≤ (closureOf ([] ++ [φ])).card + 1`, which `Enumerate.lean` consumes.

## The bound is a grid, not a magnitude

The three segment bounds are stated as **upper** bounds and `Enumerate.lean` sweeps every triple
in `[0, B]³`. A bound alone does **not** transfer to a consumer that folds `back`/`mid`/`fwd`
bounds by exact modulus: such a search at bound `n` represents exactly the periods dividing `n`,
so representability, not magnitude, is what the folding decides.

## Main Definitions

- `Formula.boxArg?` — the argument of a boxed formula, as a partial function
- `boxedPart` — the `χ` whose box lies in a given finite set

## Main Results

- `mem_boxedPart` — membership in `boxedPart` is boxed membership in the set
- `boxedPart_subset_closureOf` — the boxed part of a closure is inside that closure
- `exists_witnessFamily_of_not_validZTime` — **the compression theorem**
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax
open FormalSystem.Semantics

/-! ## The boxed part of a finite set -/

/-- The argument of a boxed formula, as a partial function. No such projection exists in the
tree; this is its first use site. -/
def Formula.boxArg? : Formula → Option Formula
  | Formula.box χ => some χ
  | _ => none

@[simp] theorem Formula.boxArg?_box (χ : Formula) :
    Formula.boxArg? (Formula.box χ) = some χ := rfl

theorem Formula.boxArg?_eq_some {f χ : Formula} :
    Formula.boxArg? f = some χ ↔ f = Formula.box χ := by
  cases f <;> simp [Formula.boxArg?]

/-- The `χ` for which `□χ` lies in `C`. Every value the box guess is ever read at lies here. -/
def boxedPart (C : Finset Formula) : Finset Formula :=
  C.biUnion (fun ψ => (Formula.boxArg? ψ).toFinset)

theorem mem_boxedPart {C : Finset Formula} {χ : Formula} :
    χ ∈ boxedPart C ↔ Formula.box χ ∈ C := by
  simp only [boxedPart, Finset.mem_biUnion, Option.mem_toFinset, Option.mem_def,
    Formula.boxArg?_eq_some]
  constructor
  · rintro ⟨ψ, hψ, rfl⟩
    exact hψ
  · intro h
    exact ⟨Formula.box χ, h, rfl⟩

/-- The boxed part of a set-level closure lies inside that closure. -/
theorem boxedPart_subset_closureOf (S : Context) :
    boxedPart (closureOf S) ⊆ closureOf S := by
  intro χ hχ
  exact closureOf_box (mem_boxedPart.mp hχ)

/-! ## The empty-premise consequence bridge -/

/-- `closureOf` at the single-conclusion target is the single-formula closure. -/
theorem closureOf_nil_singleton (φ : Formula) :
    closureOf ([] ++ [φ]) = subformulaClosure φ := by
  simp [closureOf]

/-- With no premises, semantic consequence in a frame class is validity in it. -/
theorem semanticConsequenceIn_nil_iff (fc : ProofSystem.FrameClass) (φ : Formula) :
    SemanticConsequenceIn fc [] φ ↔ ValidIn fc φ := by
  constructor
  · intro h F hF M τ t
    exact h F hF M τ t (by intro γ hγ; exact absurd hγ (List.not_mem_nil))
  · intro h F hF M τ t _
    exact h F hF M τ t

/-! ## The compression theorem -/

/--
**The compression theorem**: every ℤ-time countermodel compresses to a bounded, canonically
guessed witness family that certifies the refutation.

The four side conditions riding along with `Certifies` are exactly the four `Enumerate.lean`
consumes: the three segment bounds, the lasso-count bound, the canonical-`bx` form, and the
target time's own bound. None is decoration — a family failing any one of them is not a member
of the candidate list.

The proof is the composition of everything below it:

1. `validZTime_iff_validInt` normalises the countermodel's carrier to ℤ. This is compression
   step 0 and it is free.
2. `exists_labelledLasso_of_history_realized` compresses the refuting history at the refuting
   time into the **main** lasso, and each history witnessing a false box guess into one further
   lasso.
3. `localCoherentSeqLab_congr_bx` transports local coherence from the truth oracle onto the
   canonical guess.
4. `BoxFaithful`'s forward direction is `S`'s defining property carried through `typeAtM` — this
   is what the `realized` conjunct is for — and its reverse is the witness lasso, which fails its
   own `χ` at the position the compression marked.

Paper: — (formalization-native; the paper's `cor:tm-decidability` is commented out and
carries no live label, and states nothing about the witness-family route)
-/
theorem exists_witnessFamily_of_not_validZTime (φ : Formula) (h : ¬ ValidZTime φ) :
    ∃ (W : WitnessFamily [] [φ]) (t : ℤ),
      (∀ Λ ∈ W.lassos,
        Λ.back.length ≤ compressionBound [] [φ] ∧
        Λ.mid.length ≤ compressionBound [] [φ] ∧
        Λ.fwd.length ≤ compressionBound [] [φ]) ∧
      W.lassos.length ≤ (closureOf ([] ++ [φ])).card + 1 ∧
      (∃ S : Finset Formula, S ⊆ closureOf ([] ++ [φ]) ∧ W.bx = fun χ => decide (χ ∈ S)) ∧
      0 ≤ t ∧ t ≤ (compressionBound [] [φ] : ℤ) ∧
      W.Certifies t := by
  classical
  -- ### Step 0: normalise the carrier to ℤ
  rw [validZTime_iff_validInt] at h
  simp only [ValidInt, not_forall] at h
  obtain ⟨F, hreg, M, τ, t₀, hfail⟩ := h
  set C : Finset Formula := closureOf (([] : Context) ++ [φ]) with hC
  set B : ℕ := compressionBound ([] : Context) [φ] with hB
  -- ### The two box guesses
  set bxTrue : Formula → Bool := fun χ =>
    @decide (∀ (σ : WorldHistory F.toTaskFrame) (v : ℤ), TruthAt M σ v χ) (Classical.dec _)
    with hbxTrueDef
  have hbxTrue : ∀ χ : Formula, bxTrue χ = true ↔
      ∀ (σ : WorldHistory F.toTaskFrame) (v : ℤ), TruthAt M σ v χ := by
    intro χ
    rw [hbxTrueDef]
    exact decide_eq_true_iff
  set S : Finset Formula :=
    @Finset.filter Formula (fun χ => ∀ (σ : WorldHistory F.toTaskFrame) (v : ℤ), TruthAt M σ v χ)
      (Classical.decPred _) (boxedPart C) with hSdef
  have hmemS : ∀ χ : Formula, χ ∈ S ↔
      (χ ∈ boxedPart C ∧ ∀ (σ : WorldHistory F.toTaskFrame) (v : ℤ), TruthAt M σ v χ) := by
    intro χ
    rw [hSdef]
    simp only [Finset.mem_filter]
  set bxC : Formula → Bool := fun χ => decide (χ ∈ S) with hbxCdef
  have hagree : ∀ χ : Formula, Formula.box χ ∈ C → bxTrue χ = bxC χ := by
    intro χ hχ
    rw [Bool.eq_iff_iff, hbxTrue χ]
    rw [hbxCdef]
    simp only [decide_eq_true_iff, hmemS χ]
    constructor
    · intro hg; exact ⟨mem_boxedPart.mpr hχ, hg⟩
    · intro hg; exact hg.2
  -- ### One lasso per formula: the main one, or a witness where the guess is false
  obtain ⟨Λ₀, i₀, hb₀, hm₀, hf₀, hi₀a, hi₀b, hlab₀, hloc₀, hful₀, hreal₀⟩ :=
    exists_labelledLasso_of_history_realized M ([] : Context) [φ] bxTrue hbxTrue τ t₀
  have hchoice : ∀ χ : Formula, ∃ Λ : LabelledLasso C,
      Λ.back.length ≤ B ∧ Λ.mid.length ≤ B ∧ Λ.fwd.length ≤ B ∧
      LocalCoherentSeqLab ([] : Context) [φ] bxTrue Λ.lab ∧ FulfillingSeqLab Λ.lab ∧
      (∀ j : ℤ, ∃ (σ : WorldHistory F.toTaskFrame) (u : ℤ),
        Λ.lab j = typeAtM M ([] : Context) [φ] σ u) ∧
      ((¬ ∀ (σ : WorldHistory F.toTaskFrame) (v : ℤ), TruthAt M σ v χ) →
        ∃ j : ℤ, χ ∉ Λ.lab j) := by
    intro χ
    by_cases hg : ∀ (σ : WorldHistory F.toTaskFrame) (v : ℤ), TruthAt M σ v χ
    · exact ⟨Λ₀, hb₀, hm₀, hf₀, hloc₀, hful₀,
        fun j => by obtain ⟨u, hu⟩ := hreal₀ j; exact ⟨τ, u, hu⟩,
        fun hcon => absurd hg hcon⟩
    · simp only [not_forall] at hg
      obtain ⟨σ₀, v₀, hv₀⟩ := hg
      obtain ⟨Λ, i, hb, hm, hf, -, -, hlab, hloc, hful, hreal⟩ :=
        exists_labelledLasso_of_history_realized M ([] : Context) [φ] bxTrue hbxTrue σ₀ v₀
      refine ⟨Λ, hb, hm, hf, hloc, hful,
        fun j => by obtain ⟨u, hu⟩ := hreal j; exact ⟨σ₀, u, hu⟩, fun _ => ⟨i, ?_⟩⟩
      rw [hlab]
      intro hmem
      exact hv₀ (mem_typeAtM.mp hmem).2
  choose wit hwitb hwitm hwitf hwitloc hwitful hwitreal hwitfail using hchoice
  -- ### The family
  obtain ⟨R, hR⟩ : ∃ R : Finset Formula, R = boxedPart C \ S := ⟨_, rfl⟩
  obtain ⟨L, hL⟩ : ∃ L : List (LabelledLasso C), L = Λ₀ :: R.toList.map wit := ⟨_, rfl⟩
  have hLne : L ≠ [] := by rw [hL]; simp
  -- every member of the list is the main lasso or a witness lasso
  have hLmem : ∀ Λ ∈ L, (Λ = Λ₀) ∨ ∃ χ ∈ R, Λ = wit χ := by
    intro Λ hΛ
    rw [hL] at hΛ
    rcases List.mem_cons.mp hΛ with rfl | hΛ'
    · exact Or.inl rfl
    · obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp hΛ'
      exact Or.inr ⟨χ, Finset.mem_toList.mp hχ, rfl⟩
  have hLbound : ∀ Λ ∈ L,
      Λ.back.length ≤ B ∧ Λ.mid.length ≤ B ∧ Λ.fwd.length ≤ B := by
    intro Λ hΛ
    rcases hLmem Λ hΛ with rfl | ⟨χ, -, rfl⟩
    · exact ⟨hb₀, hm₀, hf₀⟩
    · exact ⟨hwitb χ, hwitm χ, hwitf χ⟩
  have hLloc : ∀ Λ ∈ L, LocalCoherentSeqLab ([] : Context) [φ] bxC Λ.lab := by
    intro Λ hΛ
    refine localCoherentSeqLab_congr_bx (fun χ hχ => hagree χ hχ) ?_
    rcases hLmem Λ hΛ with rfl | ⟨χ, -, rfl⟩
    · exact hloc₀
    · exact hwitloc χ
  have hLful : ∀ Λ ∈ L, FulfillingSeqLab Λ.lab := by
    intro Λ hΛ
    rcases hLmem Λ hΛ with rfl | ⟨χ, -, rfl⟩
    · exact hful₀
    · exact hwitful χ
  have hLreal : ∀ Λ ∈ L, ∀ j : ℤ, ∃ (σ : WorldHistory F.toTaskFrame) (u : ℤ),
      Λ.lab j = typeAtM M ([] : Context) [φ] σ u := by
    intro Λ hΛ
    rcases hLmem Λ hΛ with rfl | ⟨χ, -, rfl⟩
    · exact fun j => by obtain ⟨u, hu⟩ := hreal₀ j; exact ⟨τ, u, hu⟩
    · exact hwitreal χ
  obtain ⟨W, hW⟩ : ∃ W : WitnessFamily ([] : Context) [φ],
      W = { bx := bxC, lassos := Λ₀ :: R.toList.map wit, lassos_ne := by simp } := ⟨_, rfl⟩
  have hWbx : W.bx = bxC := by rw [hW]
  have hWlas : W.lassos = L := by rw [hW, hL]
  have hWL : ∀ i : Fin W.lassos.length, W.L i = (W.lassos.get i).lab := fun _ => rfl
  have hWmemL : ∀ i : Fin W.lassos.length, W.lassos.get i ∈ L := by
    intro i
    rw [← hWlas]
    exact List.get_mem _ _
  -- ### The four certificate conditions
  have hcoh : W.LocalCoherentLab := by
    intro i t
    have h := hLloc _ (hWmemL i) t
    rw [hWbx]
    exact h
  have hfulW : W.FulfillingLab := by
    constructor
    · intro i t g e hmem
      exact (hLful _ (hWmemL i)).1 t g e hmem
    · intro i t g e hmem
      exact (hLful _ (hWmemL i)).2 t g e hmem
  have hboxW : W.BoxFaithful := by
    intro χ hχ
    rw [hWbx, hbxCdef]
    simp only [decide_eq_true_iff, hmemS χ]
    constructor
    · -- the guess is true: `χ` is globally true, hence in every realised type
      rintro ⟨-, hglob⟩ i t
      obtain ⟨σ, u, hu⟩ := hLreal _ (hWmemL i) t
      rw [hWL i, hu]
      exact mem_typeAtM.mpr ⟨closureOf_box hχ, hglob σ u⟩
    · -- the guess is false: the witness lasso for `χ` fails it somewhere
      intro hall
      refine ⟨mem_boxedPart.mpr hχ, ?_⟩
      by_contra hglob
      obtain ⟨j, hj⟩ := hwitfail χ hglob
      have hmemR : χ ∈ R := by
        rw [hR, Finset.mem_sdiff]
        exact ⟨mem_boxedPart.mpr hχ, fun hS => hj (by
          obtain ⟨-, hg⟩ := (hmemS χ).mp hS
          exact absurd hg hglob)⟩
      have hmemL : wit χ ∈ L := by
        rw [hL]
        exact List.mem_cons_of_mem _ (List.mem_map.mpr ⟨χ, Finset.mem_toList.mpr hmemR, rfl⟩)
      obtain ⟨k, hk⟩ : ∃ k : Fin W.lassos.length, W.lassos.get k = wit χ := by
        rw [hWlas]
        obtain ⟨k, hk⟩ := List.mem_iff_get.mp hmemL
        exact ⟨k, hk⟩
      exact hj (by rw [← hk, ← hWL k]; exact hall k j)
  have hmain : W.main = Λ₀.lab := by
    rw [hW]
    rfl
  have htgt : W.Target i₀ := by
    refine ⟨fun γ hγ => absurd hγ (List.not_mem_nil), fun σ hσ hmem => ?_⟩
    rcases List.mem_singleton.mp hσ with rfl
    rw [hmain, hlab₀] at hmem
    exact hfail (mem_typeAtM.mp hmem).2
  -- ### Assemble
  refine ⟨W, i₀, ?_, ?_, ⟨S, ?_, ?_⟩, hi₀a, ?_, hcoh, hfulW, hboxW, htgt⟩
  · intro Λ hΛ
    rw [hWlas] at hΛ
    exact hLbound Λ hΛ
  · rw [hWlas, hL]
    have hcard : R.card ≤ (closureOf (([] : Context) ++ [φ])).card := by
      rw [hR, hC]
      exact le_trans (Finset.card_le_card Finset.sdiff_subset)
        (Finset.card_le_card (boxedPart_subset_closureOf _))
    simp only [List.length_cons, List.length_map, Finset.length_toList]
    omega
  · rw [hSdef]
    exact le_trans (Finset.filter_subset _ _) (boxedPart_subset_closureOf _)
  · rw [hWbx, hbxCdef]
  · have hnm : Λ₀.nm = (Λ₀.mid.length : ℤ) := rfl
    have : (Λ₀.mid.length : ℤ) ≤ (B : ℤ) := by exact_mod_cast hm₀
    omega

end FormalSystem.Metalogic.Decidability
