/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.Translation
import FormalSystem.Metalogic.WeakCanonical.Kamp.Prop35ExistsForall
import FormalSystem.Metalogic.WeakCanonical.Kamp.VeeExistsForall

/-!
# Proposition 3.5: the Until/Since chain (Rabinovich 2014, PDF p.5)

Completes Proposition 3.5 — every `∃∀`-formula with one free variable (Def 3.1, p.4) is
equivalent to a `TL(Until, Since)` formula — on the Phase-3 `ExistsForallFormula` object, using
the atomic layer (`unaryToFormula`, `Prop35ExistsForall.lean`) and the **already-proved**,
signature-generic Until/Since chain translator `Kamp.translateEF1` / `Kamp.translateEF1_correct`
(`Translation.lean`).

## Key structural observation

`translateEF1 n k alpha beta` (`Translation.lean`) already builds *exactly* the chain Prop 3.5
needs: `alpha_k` at the free variable, a rightward `Until`-chain through `alpha_{k+1},…,alpha_n`
capped by an **unbounded** `G(beta_{n+1})` (the `buildRight` `[]`-case, "henceforth"), and the
`Since`-mirror leftward capped by an unbounded `H(beta_0)`. This is the *literal* shape of
`efSat`'s witness/interval clauses with the free variable pinned at an *interior* point
`x_{pin 0}` — the `[]`-base cases of `buildRight_spec`/`buildLeft_spec` (proved already in
`Translation.lean`) are precisely the unbounded terminal caps the Phase-5 handoff called out as
new content. What remains — and is proved here — is the bridge between `translateEF1`'s
`List.finRange`-indexed recursive chain spec and `efSat`'s `StrictMono`-witness-function
formulation.

## Contents

- `buildRight_spec_iff_chain` / `buildLeft_spec_iff_chain`: generic Nat-indexed bridging lemmas
  connecting `buildRight_spec` / `buildLeft_spec` on a `List.finRange`-derived pair list to a
  strictly monotone/antitone witness chain with an unbounded terminal cap.

## References

- Rabinovich, *A Proof of Kamp's Theorem* (2014), Proposition 3.5 (p.5). Cited by PDF page; the
  companion markdown transcription is corrupt.
- `Translation.lean`: `translateEF1`, `translateEF1_correct`, `buildRight_spec`, `buildLeft_spec`.
- `Prop35ExistsForall.lean`: `unaryToFormula`, `unaryToFormula_correct`.
- `ExistsForallFormula.lean`: `ExistsForallFormula`, `efSat`.
-/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax (Formula)
open FormalSystem.Metalogic.WeakCanonical

/-! ## 1. Generic rightward chain bridge -/

/-- **Rightward chain bridge.** `buildRight_spec` on the `List.finRange d`-derived pair list
(`alpha_ i, beta_ i` for `i < d`), evaluated at `t0`, holds iff there is a `Nat`-indexed chain
`x : Nat → M.carrier` with `x 0 = t0`, strictly increasing on `[0, d]`, realizing `alpha_ i` at
`x (i+1)`, `beta_ i` on the open segment `(x i, x (i+1))`, and the unbounded cap `rightmost`
holding everywhere past `x d`. This is the bridge between `translateEF1`'s recursive chain
formula and a witness-function (`efSat`-style) formulation; the `d = 0` base case is exactly the
unbounded "henceforth" terminal cap (`buildRight_spec`'s `[]`-case). -/
theorem buildRight_spec_iff_chain {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) :
    ∀ (d : Nat) (alpha_ beta_ : Nat → TemporalPred) (rightmost : TemporalPred) (t0 : M.carrier),
      buildRight_spec M atomMap
        ((List.finRange d).map fun i => (alpha_ i.val, beta_ i.val)) rightmost t0 ↔
      ∃ x : Nat → M.carrier, x 0 = t0 ∧
        (∀ i j, i < j → j ≤ d → x i < x j) ∧
        (∀ i, i < d → (alpha_ i).eval_at M atomMap (x (i + 1))) ∧
        (∀ i, i < d → ∀ y, x i < y → y < x (i + 1) → (beta_ i).eval_at M atomMap y) ∧
        (∀ y, x d < y → rightmost.eval_at M atomMap y) := by
  intro d
  induction d with
  | zero =>
    intro alpha_ beta_ rightmost t0
    simp only [List.finRange_zero, List.map_nil]
    unfold buildRight_spec
    constructor
    · intro h
      exact ⟨fun _ => t0, rfl, by intro i j hij hjd; omega, by intro i hi; omega,
        by intro i hi; omega, h⟩
    · rintro ⟨x, hx0, _, _, _, hlast⟩
      rw [hx0] at hlast
      exact hlast
  | succ d' ih =>
    intro alpha_ beta_ rightmost t0
    rw [List.finRange_succ, List.map_cons, List.map_map]
    unfold buildRight_spec
    constructor
    · rintro ⟨x1, hlt, halpha0, hbeta0, hrest⟩
      obtain ⟨x', hx'0, hx'mono, hx'alpha, hx'beta, hx'last⟩ :=
        (ih (fun n => alpha_ (n + 1)) (fun n => beta_ (n + 1)) rightmost x1).mp hrest
      set X : Nat → M.carrier := fun m => match m with | 0 => t0 | m' + 1 => x' m' with hXdef
      have hX0 : X 0 = t0 := rfl
      have hXsucc : ∀ m, X (m + 1) = x' m := fun _ => rfl
      refine ⟨X, hX0, ?_, ?_, ?_, ?_⟩
      · intro i j hij hjd
        rcases i with _ | i'
        · rcases j with _ | j'
          · omega
          · rw [hX0, hXsucc]
            rcases j' with _ | j''
            · rw [hx'0]; exact hlt
            · have hstep : x' 0 < x' (j'' + 1) := hx'mono 0 (j'' + 1) (by omega) (by omega)
              have h1 : t0 < x' 0 := hx'0 ▸ hlt
              exact lt_trans h1 hstep
        · rcases j with _ | j'
          · omega
          · rw [hXsucc, hXsucc]
            exact hx'mono i' j' (by omega) (by omega)
      · intro i hi
        rcases i with _ | i'
        · rw [hXsucc, hx'0]
          exact halpha0
        · rw [hXsucc]
          exact hx'alpha i' (by omega)
      · intro i hi y hy1 hy2
        rcases i with _ | i'
        · rw [hX0] at hy1
          rw [hXsucc, hx'0] at hy2
          exact hbeta0 y hy1 hy2
        · rw [hXsucc] at hy1
          rw [hXsucc] at hy2
          exact hx'beta i' (by omega) y hy1 hy2
      · intro y hy
        rw [hXsucc] at hy
        exact hx'last y hy
    · rintro ⟨x, hx0, hmono, halpha, hbeta, hlast⟩
      refine ⟨x 1, ?_, ?_, ?_, ?_⟩
      · have h01 : x 0 < x 1 := hmono 0 1 (by omega) (by omega)
        rw [hx0] at h01
        exact h01
      · exact halpha 0 (by omega)
      · intro r hr1 hr2
        have hr1' : x 0 < r := by rw [hx0]; exact hr1
        exact hbeta 0 (by omega) r hr1' hr2
      · refine (ih (fun n => alpha_ (n + 1)) (fun n => beta_ (n + 1)) rightmost (x 1)).mpr
          ⟨fun n => x (n + 1), rfl, ?_, ?_, ?_, ?_⟩
        · intro i j hij hjd
          exact hmono (i + 1) (j + 1) (by omega) (by omega)
        · intro i hi
          exact halpha (i + 1) (by omega)
        · intro i hi y hy1 hy2
          exact hbeta (i + 1) (by omega) y hy1 hy2
        · exact hlast

/-! ## 2. Generic leftward chain bridge (Since mirror) -/

/-- **Leftward chain bridge.** Mirror of `buildRight_spec_iff_chain` for `buildLeft_spec`: the
witness chain is strictly *antitone* as the index grows, and the unbounded cap holds everywhere
*before* `x d` (the "H(leftmost)" base case). -/
theorem buildLeft_spec_iff_chain {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) :
    ∀ (d : Nat) (alpha_ beta_ : Nat → TemporalPred) (leftmost : TemporalPred) (t0 : M.carrier),
      buildLeft_spec M atomMap
        ((List.finRange d).map fun i => (alpha_ i.val, beta_ i.val)) leftmost t0 ↔
      ∃ x : Nat → M.carrier, x 0 = t0 ∧
        (∀ i j, i < j → j ≤ d → x j < x i) ∧
        (∀ i, i < d → (alpha_ i).eval_at M atomMap (x (i + 1))) ∧
        (∀ i, i < d → ∀ y, x (i + 1) < y → y < x i → (beta_ i).eval_at M atomMap y) ∧
        (∀ y, y < x d → leftmost.eval_at M atomMap y) := by
  intro d
  induction d with
  | zero =>
    intro alpha_ beta_ leftmost t0
    simp only [List.finRange_zero, List.map_nil]
    unfold buildLeft_spec
    constructor
    · intro h
      exact ⟨fun _ => t0, rfl, by intro i j hij hjd; omega, by intro i hi; omega,
        by intro i hi; omega, h⟩
    · rintro ⟨x, hx0, _, _, _, hlast⟩
      rw [hx0] at hlast
      exact hlast
  | succ d' ih =>
    intro alpha_ beta_ leftmost t0
    rw [List.finRange_succ, List.map_cons, List.map_map]
    unfold buildLeft_spec
    constructor
    · rintro ⟨x1, hlt, halpha0, hbeta0, hrest⟩
      obtain ⟨x', hx'0, hx'mono, hx'alpha, hx'beta, hx'last⟩ :=
        (ih (fun n => alpha_ (n + 1)) (fun n => beta_ (n + 1)) leftmost x1).mp hrest
      set X : Nat → M.carrier := fun m => match m with | 0 => t0 | m' + 1 => x' m' with hXdef
      have hX0 : X 0 = t0 := rfl
      have hXsucc : ∀ m, X (m + 1) = x' m := fun _ => rfl
      refine ⟨X, hX0, ?_, ?_, ?_, ?_⟩
      · intro i j hij hjd
        rcases i with _ | i'
        · rcases j with _ | j'
          · omega
          · rw [hX0, hXsucc]
            rcases j' with _ | j''
            · rw [hx'0]; exact hlt
            · have hstep : x' (j'' + 1) < x' 0 := hx'mono 0 (j'' + 1) (by omega) (by omega)
              have h1 : x' 0 < t0 := hx'0 ▸ hlt
              exact lt_trans hstep h1
        · rcases j with _ | j'
          · omega
          · rw [hXsucc, hXsucc]
            exact hx'mono i' j' (by omega) (by omega)
      · intro i hi
        rcases i with _ | i'
        · rw [hXsucc, hx'0]
          exact halpha0
        · rw [hXsucc]
          exact hx'alpha i' (by omega)
      · intro i hi y hy1 hy2
        rcases i with _ | i'
        · rw [hXsucc, hx'0] at hy1
          rw [hX0] at hy2
          exact hbeta0 y hy1 hy2
        · rw [hXsucc] at hy1
          rw [hXsucc] at hy2
          exact hx'beta i' (by omega) y hy1 hy2
      · intro y hy
        rw [hXsucc] at hy
        exact hx'last y hy
    · rintro ⟨x, hx0, hmono, halpha, hbeta, hlast⟩
      refine ⟨x 1, ?_, ?_, ?_, ?_⟩
      · have h01 : x 1 < x 0 := hmono 0 1 (by omega) (by omega)
        rw [hx0] at h01
        exact h01
      · exact halpha 0 (by omega)
      · intro r hr1 hr2
        have hr2' : r < x 0 := by rw [hx0]; exact hr2
        exact hbeta 0 (by omega) r hr1 hr2'
      · refine (ih (fun n => alpha_ (n + 1)) (fun n => beta_ (n + 1)) leftmost (x 1)).mpr
          ⟨fun n => x (n + 1), rfl, ?_, ?_, ?_, ?_⟩
        · intro i j hij hjd
          exact hmono (i + 1) (j + 1) (by omega) (by omega)
        · intro i hi
          exact halpha (i + 1) (by omega)
        · intro i hi y hy1 hy2
          exact hbeta (i + 1) (by omega) y hy1 hy2
        · exact hlast

end FormalSystem.Metalogic.WeakCanonical.Kamp
