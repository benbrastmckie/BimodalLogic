/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.NfEFold

/-! # Depth-graded fiber-consistency guard (production home; mate check strengthened in place)

The D7 interface repair (research approach (b)): a model-independent, depth-recursive
fiber-consistency guard that reads the depth-≥1 inner `.2` marking — the layer NO existing
fiber-marking channel reads (`nfkDropFresh`/`nfkZoneSpec` are depth-0, `nfkProjFresh` is an
arity-1 prefix collapse), which is exactly what the doppelgänger-tail fake fiber `s*` of
`ExteriorPinnedProbeM1K.lean` exploits.

Promoted verbatim from the Phase-1 probe module (`ExteriorFiberConsistencyProbeK.lean`, GO
verdict: rejects `s*`/`m1sigma`, accepts every honest probe fiber, general-m-feasible).

## Mate-check strengthening (restated IN PLACE)

The original mate check was atom-row-only and was machine-refuted by the route-R2 probe
(`kvE_probe358_eP_atomMate_present`, `ExteriorPinnedProbe358K.lean`): the adversary PLANTS the
missing row as an unrealizable fiber `mate := (mergeNF e_P.atomAssgn ⟨1,_⟩, fun _ => false)`
— vacuously elem-consistent, interior-zoned, hence invisible — restoring the m = 1
doppelgänger countermodel one layer deeper. The strengthening adds ONE new mate-check
conjunct: the mate `s'` must be CO-REALIZED with the ambient `σ` in some model
(`∃ M env u, σ` realized at `env ∧ s'` realized at `Fin.cons u env`). This is the
literature-faithful reading of the content channel (Rabinovich Def 4.1, PDF p.5: every
E[Σ]-atom of the canonical expansion is interpreted as `{a ∈ M | M, a ⊨ A}` — point content IS
realization content). Name, signature, the depth-0 arm, `_zero` inertness, and the
`_of_realized` lemma statements are all byte-stable; honest preservation gains exactly one
witness (`⟨M, env, u, hσ, nf_characteristic_satisfies⟩`). Why this rejects the plant — and
EVERY adapted re-plant that keeps `s*` plus one honest fiber marked: `s*` forces an interior
`P`-point through its marked witness `e_P`, while every honest fiber's quant layer is decided
in the probe model (where `P ∩ (15,18) = ∅`), so the ambient admits NO joint realization at
all (`kvE_probe364_sstar_honest_unrealizable`, `ExteriorFiberConsistencyProbe364K.lean` — the
Gate-3a universal certificate). Candidate adjudication record (why syntactic content
comparison and standalone realizability were both rejected) lives in the probe leaf's module
docstring.

## Consumption map

* **Exterior leg (G2)**: `kvEFiberElemConsistent σ s` is a NEW conjunct inside conjunct 2 of
  `kvEFutAdmissible` (`ExteriorNegationK.lean`) and `kvEPastAdmissible`
  (`ExteriorNegationPastK.lean`) — every marked fiber must be on-fiber AND elem-consistent.
  The guard is direction-agnostic (realization-based honest preservation never reads the
  anchor order), so the SAME predicate serves both mirrors.
* **Interior leg (G1)**: `kvEFiberConsistent σ` is the NEW rows-5-6 antecedent
  (`EndIntervalConsumerK.lean` `_hfiberCons` binder + per-σ antecedent on `_hreal`/`_hexcl`;
  mirrored in `kampPrior_site_rungK_gate_match`).
* **m = 0 inertness**: at fiber depth 0 both guards are constantly `true`
  (`kvE_fiberElemConsistent_zero` / `kvE_fiberConsistent_zero`), so the frozen m = 0 slice
  supply layer and the k ≤ 1 rungs are untouched.

## Why this separates fake from honest

If `σ` is realized at `env` and its fiber `s` at `Fin.cons xs env`, every marked inner `e` is
realized at `Fin.cons u (Fin.cons xs env)`; dropping slot 1 (the `xs` coordinate — `mergeNF`
at position 1) leaves `Fin.cons u env`, whose characteristic is a `σ`-marked fiber with
EXACTLY the dropped atom row (`kvE_fiberElemConsistent_of_realized`). The fake `s*` (honest
type of the walk point over the DOPPELGÄNGER tail `[25,15,2,21]`) marks the inner 6-type of
the `P`-point `20`, whose dropped row demands a `σ`-marked mate realized at
`[x, 25, 15, 2, 18]` with `P x ∧ 15 < x < 18` — impossible for `P = {0, 10, 20}`. -/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical

/-- **Per-fiber depth-graded consistency** of a fiber `s` within an ambient `σ` marking it:
    every inner form marked by `s` (i) has a mate among `σ`'s marked fibers that matches its
    dropped atom layer (`s`'s fresh slot, position 1 of the inner arity, removed) AND is
    co-realized with `σ` in some model (the mate-check strengthening — an atom-row plant with
    no grounding in any joint realization of the ambient no longer qualifies), and (ii) is
    recursively fiber-consistent within `s`. Trivially `true` at fiber depth 0 (no inner
    marking) — the m = 0 inertness guard rail. Model-independent (the realization existential
    is internal; there is no model parameter). -/
noncomputable def kvEFiberElemConsistent {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] :
    {k n : Nat} → NormalForm sig (k + 1) n → NormalForm sig k (n + 1) → Bool
  | 0, _, _, _ => true
  | (j + 1), n, σ, s =>
    ((Finset.univ.toList (α := NormalForm sig j (n + 2))).all fun e =>
      !(s.2 e) ||
        ((Finset.univ.toList (α := NormalForm sig (j + 1) (n + 1))).any fun s' =>
          σ.2 s' && @decide (mergeNF (m := n + 1) (e.atomAssgn)
              (⟨1, Nat.succ_lt_succ (Nat.succ_pos n)⟩ : Fin (n + 2)) = s'.atomAssgn)
              (Classical.dec _) &&
            @decide (∃ (M : OrderedMonadicStructure sig) (env : Fin n → M.carrier)
                (u : M.carrier),
                NfEvalNf M (j + 2) n env σ ∧
                NfEvalNf M (j + 1) (n + 1) (Fin.cons u env) s')
              (Classical.dec _))) &&
    ((Finset.univ.toList (α := NormalForm sig j (n + 2))).all fun e =>
      !(s.2 e) || kvEFiberElemConsistent s e)

/-- **σ-level fiber-consistency guard**: every `σ`-marked fiber is elem-consistent. The shape
    of the interior rows-5-6 antecedent (and the aggregate the exterior conjunct enforces
    fiber-wise inside admissibility conjunct 2). -/
noncomputable def kvEFiberConsistent {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k n : Nat}
    (σ : NormalForm sig (k + 1) n) : Bool :=
  (Finset.univ.toList (α := NormalForm sig k (n + 1))).all fun s =>
    !(σ.2 s) || kvEFiberElemConsistent σ s

/-- Depth-0 inertness, per-fiber: at fiber depth 0 the guard is constantly `true`. -/
theorem kvE_fiberElemConsistent_zero {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {n : Nat}
    (σ : NormalForm sig 1 n) (s : NormalForm sig 0 (n + 1)) :
    kvEFiberElemConsistent σ s = true := rfl

/-- Depth-0 inertness, σ-level: at fiber depth 0 the guard is constantly `true` — the m = 0
    layers (the frozen m = 0 supply, k ≤ 1 rungs) see a vacuous conjunct. -/
theorem kvE_fiberConsistent_zero {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {n : Nat}
    (σ : NormalForm sig 1 n) : kvEFiberConsistent σ = true := by
  rw [kvEFiberConsistent, List.all_eq_true]
  intro s _
  rw [kvE_fiberElemConsistent_zero σ s, Bool.or_true]

/-- Universal-list membership at SYMBOLIC signature (instantiating `Finset.mem_univ` directly
    at a concrete signature triggers unbounded instance evaluation; routing through this
    symbolic helper keeps elaboration cheap). -/
theorem kvE_nf_mem_univ_toList {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {k n : Nat}
    (s : NormalForm sig k n) :
    s ∈ (Finset.univ.toList : List (NormalForm sig k n)) :=
  Finset.mem_toList.mpr (Finset.mem_univ s)

/-- Environment bookkeeping for the mate check: dropping slot 1 from the doubly-extended
    tuple `[u, xs, env]` leaves `[u, env]`. -/
private theorem cons_cons_skipOne {α : Type _} {n : Nat} (u xs : α) (env : Fin n → α)
    (i : Fin (n + 1)) :
    (Fin.cons u (Fin.cons xs env) : Fin (n + 2) → α) (skipFin ⟨1, by omega⟩ i) =
      (Fin.cons u env : Fin (n + 1) → α) i := by
  rcases i with ⟨iv, hi⟩
  cases iv with
  | zero =>
    have hs : skipFin (⟨1, by omega⟩ : Fin (n + 2)) ⟨0, hi⟩ = ⟨0, by omega⟩ := by
      simp only [skipFin]
      rw [dif_pos (by omega)]
    rw [hs]
    rfl
  | succ m =>
    have hs : skipFin (⟨1, by omega⟩ : Fin (n + 2)) ⟨m + 1, hi⟩ =
        Fin.succ (Fin.succ (⟨m, by omega⟩ : Fin n)) := by
      simp only [skipFin]
      rw [dif_neg (by omega)]
      rfl
    have hr : (⟨m + 1, hi⟩ : Fin (n + 1)) = Fin.succ (⟨m, by omega⟩ : Fin n) := rfl
    rw [hs, hr, Fin.cons_succ, Fin.cons_succ, Fin.cons_succ]

/-- **Realized fibers are elem-consistent** (honest preservation, per-fiber): if `σ` is
    realized at `env` and its fiber `s` at `Fin.cons xs env`, then `s` passes the guard.
    The mate witness for a marked inner `e` (realized at `Fin.cons u (Fin.cons xs env)`) is
    the characteristic of the dropped tuple `Fin.cons u env` — `σ`-marked by realization,
    atom-matching by construction, and co-realized with `σ` by the very hypotheses
    in scope. Induction on the fiber depth (the recursion arm is the inductive hypothesis one
    level down). -/
theorem kvE_fiberElemConsistent_of_realized {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) :
    ∀ {k n : Nat} (env : Fin n → M.carrier) (xs : M.carrier)
      (σ : NormalForm sig (k + 1) n) (s : NormalForm sig k (n + 1)),
      NfEvalNf M (k + 1) n env σ →
      NfEvalNf M k (n + 1) (Fin.cons xs env) s →
      kvEFiberElemConsistent σ s = true := by
  intro k
  induction k with
  | zero => intro n env xs σ s _ _; rfl
  | succ j ih =>
    intro n env xs σ s hσ hs
    rw [kvEFiberElemConsistent, Bool.and_eq_true]
    constructor
    · -- mate check
      rw [List.all_eq_true]
      intro e _
      rw [Bool.or_eq_true]
      by_cases hbe : s.2 e = true
      · refine Or.inr ?_
        obtain ⟨u, hu⟩ := (hs.2 e).mpr hbe
        rw [List.any_eq_true]
        refine ⟨nfCharacteristic M (j + 1) (n + 1) (Fin.cons u env),
          Finset.mem_toList.mpr (Finset.mem_univ _), ?_⟩
        rw [Bool.and_eq_true, Bool.and_eq_true]
        refine ⟨⟨(hσ.2 _).mp ⟨u, nf_characteristic_satisfies M (j + 1) (n + 1) _⟩, ?_⟩,
          -- joint co-realization: the hypotheses in scope ARE the witness
          @decide_eq_true
            (∃ (M0 : OrderedMonadicStructure sig) (env0 : Fin n → M0.carrier)
              (u0 : M0.carrier),
              NfEvalNf M0 (j + 2) n env0 σ ∧
              NfEvalNf M0 (j + 1) (n + 1) (Fin.cons u0 env0)
                (nfCharacteristic M (j + 1) (n + 1) (Fin.cons u env)))
            (Classical.dec _)
            ⟨M, env, u, hσ, nf_characteristic_satisfies M (j + 1) (n + 1) _⟩⟩
        refine @decide_eq_true _ (Classical.dec _) ?_
        funext a
        -- LHS: the dropped atom row of `e`; RHS: the characteristic's atom row
        have hatoms : ∀ a' : AtomKind sig (n + 2),
            AtomEval M (Fin.cons u (Fin.cons xs env)) a' ↔ e.atomAssgn a' = true :=
          nf_eval_nf_atom_layer M _ e hu
        have hchar : (nfCharacteristic M (j + 1) (n + 1) (Fin.cons u env)).atomAssgn a =
            @decide (AtomEval M (Fin.cons u env) a) (Classical.dec _) := rfl
        rw [hchar]
        -- reduce the merged read to an AtomEval over the dropped tuple
        cases a with
        | pred p i =>
          have hL := hatoms (.pred p (skipFin ⟨1, by omega⟩ i))
          simp only [AtomEval, cons_cons_skipOne] at hL
          change e.atomAssgn (.pred p (skipFin ⟨1, by omega⟩ i)) = _
          cases hb : e.atomAssgn (.pred p (skipFin ⟨1, by omega⟩ i)) with
          | true =>
            exact (@decide_eq_true (AtomEval M (Fin.cons u env) (.pred p i))
              (Classical.dec _) (hL.mpr hb)).symm
          | false =>
            refine (@decide_eq_false (AtomEval M (Fin.cons u env) (.pred p i))
              (Classical.dec _) ?_).symm
            intro hev
            exact absurd (hL.mp hev) (by rw [hb]; exact Bool.false_ne_true)
        | order i j' hne =>
          have hL := hatoms (.order (skipFin ⟨1, by omega⟩ i) (skipFin ⟨1, by omega⟩ j')
            ((skipFin_injective _).ne hne))
          simp only [AtomEval, cons_cons_skipOne] at hL
          change e.atomAssgn (.order (skipFin ⟨1, by omega⟩ i) (skipFin ⟨1, by omega⟩ j')
            ((skipFin_injective _).ne hne)) = _
          cases hb : e.atomAssgn (.order (skipFin ⟨1, by omega⟩ i) (skipFin ⟨1, by omega⟩ j')
              ((skipFin_injective _).ne hne)) with
          | true =>
            exact (@decide_eq_true (AtomEval M (Fin.cons u env) (.order i j' hne))
              (Classical.dec _) (hL.mpr hb)).symm
          | false =>
            refine (@decide_eq_false (AtomEval M (Fin.cons u env) (.order i j' hne))
              (Classical.dec _) ?_).symm
            intro hev
            exact absurd (hL.mp hev) (by rw [hb]; exact Bool.false_ne_true)
      · exact Or.inl (by rw [Bool.not_eq_true] at hbe; rw [hbe]; rfl)
    · -- depth recursion
      rw [List.all_eq_true]
      intro e _
      rw [Bool.or_eq_true]
      by_cases hbe : s.2 e = true
      · obtain ⟨u, hu⟩ := (hs.2 e).mpr hbe
        exact Or.inr (ih (Fin.cons xs env) u s e hs hu)
      · exact Or.inl (by rw [Bool.not_eq_true] at hbe; rw [hbe]; rfl)

/-- **Realized slices are fiber-consistent** (honest preservation, σ-level): any σ realized
    at any env in any model passes the guard — the obligation the strengthened
    `kvE_futRealizer_admissible` (and its past mirror) discharges for the new conjunct, and
    the reconstruction key for the restated interior `_hexcl`. -/
theorem kvE_fiberConsistent_of_realized {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) {k n : Nat} (env : Fin n → M.carrier)
    (σ : NormalForm sig (k + 1) n)
    (hσ : NfEvalNf M (k + 1) n env σ) :
    kvEFiberConsistent σ = true := by
  rw [kvEFiberConsistent, List.all_eq_true]
  intro s _
  rw [Bool.or_eq_true]
  by_cases hb : σ.2 s = true
  · obtain ⟨xs, hxs⟩ := (hσ.2 s).mpr hb
    exact Or.inr (kvE_fiberElemConsistent_of_realized M env xs σ s hσ hxs)
  · exact Or.inl (by rw [Bool.not_eq_true] at hb; rw [hb]; rfl)

end FormalSystem.Metalogic.WeakCanonical.Kamp
