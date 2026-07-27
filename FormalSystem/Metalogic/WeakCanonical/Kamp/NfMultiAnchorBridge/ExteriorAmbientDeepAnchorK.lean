/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorFiberDeepAnchorK
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfDepth0Generalized

/-! # Ambient EF-closure deep-anchor guard (production home)

The rows-5/6/10-13 interface repair, one layer OVER the `kvE_deepOnFiber` fiber-side guard: a
model-independent guard anchoring the ambient's deep marking `qnf.2` under the top-two-slot
swap — the fresh-rotation EF-closure that the two general-m blocker countermodels
(CM-A deep-incomplete, CM-B doppelgänger) both violate, invisibly to every profile-level
reader (`igPtW`/`igFoldBit`).

Promoted verbatim from the Phase-1/2/3/4 probe leaf
(`ExteriorAmbientDeepAnchorProbe358K.lean`, GO verdict: rejects CM-A and CM-B, accepts every
realized ambient over its own tail, survives the depth-2 hereditary doppelgänger AND the
content-copying plant; zero redesign loops consumed). The probe leaf remains the permanent
regression record and now certifies against THIS definition (its `kvE_ambientDeepAnchorV0`
name is a thin compatibility alias for `kvE_ambientDeepAnchor`).

## The guard

`kvE_ambientDeepAnchor qnf` (σ-INDEPENDENT — a `Bool` of `qnf` alone, unlike 367's per-σ
`kvE_deepOnFiber qnf σ`):
- ambient-depth ≤ 2 (the m = 0 binder instance): `true` (inert, `kvE_ambientDeepAnchor_zero`,
  `rfl`) — so the frozen m = 0 supply layer and k ≤ 1 rungs discharge the restated
  binders unchanged and the guard-false residue rows are m = 0-VACUOUS.
- ambient-depth ≥ 3 (m ≥ 1): every marked sub `τ`'s every marked deep element `ρ`
  re-appears, under the top-two-slot swap `swapNF01`, as a marked deep element of SOME marked
  sub `σ'` — the fresh-rotation EF-closure `∀τ (marked) ∀ρ (τ-marked) ∃σ' (marked),
  σ'.2 (swapNF01 ρ)`.

## Why this separates fake from honest

Honest (`kvE_ambientDeepAnchor_of_realized`): if `qnf` is realized at `env`, realization
supplies for each marked `τ` a fresh point `x1` (τ realized at `cons x1 env`) and for each
τ-marked `ρ` a fresh `x2` (ρ realized at `cons x2 (cons x1 env)`). The **fresh-rotation mate**
`σ' := char (cons x2 env)` is marked (at the fresh point `x2`) and its deep marking covers
`swapNF01 ρ = char (cons x1 (cons x2 env))` (`swapNF01_char` + `cons2_comp_swap01`). Fully
general — no countermodel obstructs.

Fake: CM-A's deep-incomplete marking drops a bucket-mate whose inner fiber's swap is covered
by NO marked sub (`kvE_probe368_cmA_ambient_rejected`); CM-B's doppelgänger marking carries a
planted R-point fiber whose swap is jointly unrealizable over both the real and the fake tail
(`kvE_probe368_cmB_ambient_rejected`). The depth-2 hereditary doppelgänger is rejected the same
way one layer down (`kvE_probe368_depth2_ambient_rejected`); a content-copying plant collapses
to the honest ambient through the row/anchoring clause
(`kvE_probe368_ambient_copyPlant_collapses`).

## Consumption map

* **Rows 5, 6** (`_hreal`/`_hexcl`, `EndIntervalConsumerK.lean`; mirrored in
  `bracketEndChar_kvExt_correct_prior` and `kampPrior_site_rungK_gate_match`): each gains the
  σ-independent antecedent `kvE_ambientDeepAnchor qnf = true`. CM-B fails the guard, so its
  row-5 refutation is outside the (guard-restricted) obligation population.
* **Rows 10, 11** (`_hexclSlicePast`/`_hexclSliceFut`): gain the same antecedent.
* **Rows 12, 13** (`_hexclDeepPast`/`_hexclDeepFut`): gain the same antecedent. CM-A fails the
  guard, dissolving its row-13 refutation.
* **Gate-formula strengthening** (`bracketEndChar_kvExt`, `ExteriorGateAssembleK.lean`): the
  enriched gate conjoins the guard so that `.holds → kvE_ambientDeepAnchor qnf = true`, letting
  the ⇒-reconstruction discharge the guard antecedents of the ⇒-side rows; the ⇐-side
  re-establishes the guard conjunct from realization via `kvE_ambientDeepAnchor_of_realized`.
* **Rows 8-9** (`_hslicePast`/`_hsliceFut`): ambient-REALIZATION-guarded already
  (`nf_eval_nf … qnf` antecedent), so a syntactic ambient guard only strengthens their
  effective population — BYTE-STABLE, no restatement.
* **m = 0 inertness**: `kvE_ambientDeepAnchor_zero` is `rfl`; the frozen m = 0 slice supply
  and the k ≤ 1 rungs are untouched.

## Routing rule (NEVER unfold)

Discharge ONLY via the byte-stable lemmas here (`kvE_ambientDeepAnchor_of_realized`,
`kvE_ambientDeepAnchor_zero`, `kvE_ambientDeepAnchor_iff`) — never by unfolding
`kvE_ambientDeepAnchor`, `kvE_deepOnFiber`, `kvE_fiberElemConsistent`, or the admissibility
predicates outside their home modules. -/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical

/-- **Top-two-slot swap** on a depth-`K`, arity-`(N+2)` normal form: the sanctioned
    depth/arity-preserving reindex by the involution `Equiv.swap 0 1` (from
    `NfDepth0Generalized.renameNF`). NOT a slot-drop — it permutes the two most-recently-bound
    variables and is its own inverse. -/
def swapNF01 {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {K N : Nat}
    (ρ : NormalForm sig K (N + 2)) : NormalForm sig K (N + 2) :=
  renameNF (⇑(Equiv.swap (0 : Fin (N + 2)) 1)) (⇑(Equiv.swap (0 : Fin (N + 2)) 1)) ρ

/-- `swapNF01` of a characteristic is the characteristic of the swapped environment. The only
    property the exclusion gates consume — via `renameNF_eval_iff` (satisfaction transports
    across the reindex) + `nf_eval_unique` (the swapped char is the unique NF satisfied there).
    No guard unfolding, no slot-drop. -/
theorem swapNF01_char {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) {K N : Nat}
    (E : Fin (N + 2) → M.carrier) :
    swapNF01 (nfCharacteristic M K (N + 2) E)
      = nfCharacteristic M K (N + 2) (E ∘ ⇑(Equiv.swap (0 : Fin (N + 2)) 1)) := by
  apply nf_eval_unique M K (N + 2) (E ∘ ⇑(Equiv.swap (0 : Fin (N + 2)) 1))
  · exact (renameNF_eval_iff M (⇑(Equiv.swap (0 : Fin (N + 2)) 1))
      (⇑(Equiv.swap (0 : Fin (N + 2)) 1)) E (E ∘ ⇑(Equiv.swap (0 : Fin (N + 2)) 1))
      (fun _ => rfl)
      (fun i => by simp only [Function.comp_apply, Equiv.swap_apply_self])
      (fun i => Equiv.swap_apply_self _ _ i)
      (fun i => Equiv.swap_apply_self _ _ i)
      (nfCharacteristic M K (N + 2) E)).mpr (nf_characteristic_satisfies M K (N + 2) E)
  · exact nf_characteristic_satisfies M K (N + 2) (E ∘ ⇑(Equiv.swap (0 : Fin (N + 2)) 1))

/-- **Ambient EF-closure deep-anchor guard**. σ-independent decidable syntax over
    the NF fintype. `k = 0` (m = 0 binder): `true` (inert, `rfl`). `k + 1` (m ≥ 1): every
    marked sub's every deep element re-appears, under the top-two-slot swap, as a deep element
    of a marked sub — the fresh-rotation EF-closure both CM-A and CM-B violate. -/
noncomputable def kvEAmbientDeepAnchor {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] :
    {k n : Nat} → NormalForm sig (k + 2) n → Bool
  | 0, _, _ => true
  | k + 1, n, qnf =>
    (Finset.univ.toList (α := NormalForm sig (k + 2) (n + 1))).all fun τ =>
      !qnf.2 τ ||
      (Finset.univ.toList (α := NormalForm sig (k + 1) (n + 2))).all fun ρ =>
        !τ.2 ρ ||
        (Finset.univ.toList (α := NormalForm sig (k + 2) (n + 1))).any fun σ' =>
          qnf.2 σ' && σ'.2 (swapNF01 ρ)

/-- **m = 0 inertness**: at the m = 0 binder instance (`qnf : NormalForm sig 2 n`) the guard is
    DEFINITIONALLY `true` (`rfl`). The guard rail that keeps the frozen m = 0 supply layer, the
    k ≤ 1 rungs, and any m = 0 residue rows untouched/vacuous — the ambient-guard analog of
    `kvE_deepOnFiber_zero`. -/
theorem kvE_ambientDeepAnchor_zero {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {n : Nat}
    (qnf : NormalForm sig 2 n) : kvEAmbientDeepAnchor qnf = true := rfl

/-- **Readback for the deep arm** (`k ≥ 1`, ambient depth `k + 3`). Unpack/repack the
    fresh-rotation EF-closure into the ∀-marked-sub / ∀-marked-deep / ∃-marked-mate proposition
    every consumer routes through. The ambient-guard analog of `kvE_deepOnFiber_iff` — the guard
    is never unfolded outside this readback. -/
theorem kvE_ambientDeepAnchor_iff {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k n : Nat}
    (qnf : NormalForm sig (k + 3) n) :
    kvEAmbientDeepAnchor qnf = true ↔
      ∀ τ : NormalForm sig (k + 2) (n + 1), qnf.2 τ = true →
        ∀ ρ : NormalForm sig (k + 1) (n + 2), τ.2 ρ = true →
          ∃ σ' : NormalForm sig (k + 2) (n + 1),
            qnf.2 σ' = true ∧ σ'.2 (swapNF01 ρ) = true := by
  change ((Finset.univ.toList (α := NormalForm sig (k + 2) (n + 1))).all (fun τ =>
      !qnf.2 τ ||
      (Finset.univ.toList (α := NormalForm sig (k + 1) (n + 2))).all (fun ρ =>
        !τ.2 ρ ||
        (Finset.univ.toList (α := NormalForm sig (k + 2) (n + 1))).any (fun σ' =>
          qnf.2 σ' && σ'.2 (swapNF01 ρ))))) = true ↔ _
  rw [List.all_eq_true]
  constructor
  · intro h τ hτ ρ hρ
    have hτ' := h τ (kvE_nf_mem_univ_toList _)
    rw [hτ, Bool.not_true, Bool.false_or, List.all_eq_true] at hτ'
    have hρ' := hτ' ρ (kvE_nf_mem_univ_toList _)
    rw [hρ, Bool.not_true, Bool.false_or, List.any_eq_true] at hρ'
    obtain ⟨σ', -, hσ'⟩ := hρ'
    rw [Bool.and_eq_true] at hσ'
    exact ⟨σ', hσ'.1, hσ'.2⟩
  · intro h τ _
    cases hτ : qnf.2 τ with
    | false => rfl
    | true =>
      rw [Bool.not_true, Bool.false_or, List.all_eq_true]
      intro ρ _
      cases hρ : τ.2 ρ with
      | false => rfl
      | true =>
        rw [Bool.not_true, Bool.false_or, List.any_eq_true]
        obtain ⟨σ', hmk, hcov⟩ := h τ hτ ρ hρ
        exact ⟨σ', kvE_nf_mem_univ_toList _, by rw [Bool.and_eq_true]; exact ⟨hmk, hcov⟩⟩

/-- The top-two-slot swap of a doubly-`cons`'d environment swaps the two fresh points. The
    general (arity-`n + 2`) env identity `swapNF01_char` composes with in `_of_realized` — no
    concrete `fin_cases` (the general `n` is arbitrary). -/
private theorem cons2_comp_swap01 {α : Type*} {n : Nat} (a b : α) (g : Fin n → α) :
    (Fin.cons a (Fin.cons b g)) ∘ ⇑(Equiv.swap (0 : Fin (n + 2)) 1)
      = Fin.cons b (Fin.cons a g) := by
  funext i
  simp only [Function.comp_apply]
  refine Fin.cases ?_ (fun j => ?_) i
  · rw [Equiv.swap_apply_left, Fin.cons_one, Fin.cons_zero, Fin.cons_zero]
  · refine Fin.cases ?_ (fun j' => ?_) j
    · rw [Fin.succ_zero_eq_one', Equiv.swap_apply_right, Fin.cons_zero, Fin.cons_one,
        Fin.cons_zero]
    · have hne0 : Fin.succ (Fin.succ j') ≠ (0 : Fin (n + 2)) := Fin.succ_ne_zero _
      have hne1 : Fin.succ (Fin.succ j') ≠ (1 : Fin (n + 2)) := by
        rw [← Fin.succ_zero_eq_one']
        exact fun h => Fin.succ_ne_zero j' (Fin.succ_injective _ h)
      rw [Equiv.swap_apply_of_ne_of_ne hne0 hne1, Fin.cons_succ, Fin.cons_succ,
        Fin.cons_succ, Fin.cons_succ]

/-- **Honest preservation — the load-bearing crux** (the `kvE_deepOnFiber_of_realized` template
    one layer up). If `qnf` is realized at `env` (a GENERAL `OrderedMonadicStructure`), then it
    passes the guard. `k = 0` (m = 0 binder): inert (`rfl`). `k + 1` (m ≥ 1): the ∀τ∀ρ∃σ'
    closure is satisfied — realization supplies the fresh-rotation mate `σ' := char (cons x2 env)`
    (marked at the witness point `x2`; its deep content covers `swapNF01 ρ = char (cons x1 (cons
    x2 env))` at the fresh point `x1`). Fully general — no countermodel obstructs. This is the
    discharge route the re-keyed general-m supply uses: `_of_realized` alone, `_iff` for
    extraction, ZERO guard unfoldings. -/
theorem kvE_ambientDeepAnchor_of_realized {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) :
    ∀ {k n : Nat} (env : Fin n → M.carrier) (qnf : NormalForm sig (k + 2) n),
      NfEvalNf M (k + 2) n env qnf →
      kvEAmbientDeepAnchor qnf = true := by
  intro k
  match k with
  | 0 =>
    intro n env qnf _
    rfl
  | k + 1 =>
    intro n env qnf hqnf
    rw [kvE_ambientDeepAnchor_iff]
    intro τ hτmark ρ hρmark
    obtain ⟨x1, hx1⟩ := (hqnf.2 τ).mpr hτmark
    obtain ⟨x2, hx2⟩ := (hx1.2 ρ).mpr hρmark
    refine ⟨nfCharacteristic M (k + 2) (n + 1) (Fin.cons x2 env), ?_, ?_⟩
    · exact (hqnf.2 _).mp
        ⟨x2, nf_characteristic_satisfies M (k + 2) (n + 1) (Fin.cons x2 env)⟩
    · have hσ'real : NfEvalNf M (k + 2) (n + 1) (Fin.cons x2 env)
          (nfCharacteristic M (k + 2) (n + 1) (Fin.cons x2 env)) :=
        nf_characteristic_satisfies M (k + 2) (n + 1) (Fin.cons x2 env)
      refine (hσ'real.2 (swapNF01 ρ)).mp ⟨x1, ?_⟩
      have hρeq : ρ = nfCharacteristic M (k + 1) (n + 2) (Fin.cons x2 (Fin.cons x1 env)) :=
        nf_eval_unique M (k + 1) (n + 2) (Fin.cons x2 (Fin.cons x1 env)) _ _ hx2
          (nf_characteristic_satisfies M (k + 1) (n + 2) (Fin.cons x2 (Fin.cons x1 env)))
      rw [hρeq, swapNF01_char M, cons2_comp_swap01]
      exact nf_characteristic_satisfies M (k + 1) (n + 2) (Fin.cons x1 (Fin.cons x2 env))

end FormalSystem.Metalogic.WeakCanonical.Kamp
