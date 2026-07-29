/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.NEquivalence

/-!
# Back-and-forth systems and `≡ₖ`

The Ehrenfeucht-Fraïssé characterization of `k`-equivalence for monadic structures over linear
orders: `M ≡ₖ N` **iff** Duplicator has a depth-`k` back-and-forth strategy between `M` and `N`.

## Why this module exists

`NEquivalence.lean` already carries out both halves of this argument, but only *inside* the
ordered-sum proof and only for a *shared* index set:

* `BiCompat` (`NEquivalence.lean:194`) is a back-and-forth relation specialized to two ordered
  sums over one index type, and `sum_nf_lift_gen` (`NEquivalence.lean:831`) converts it to
  normal-form agreement. Inspection of that proof shows the index structure is never used: the
  `_h_comp` argument is threaded through the induction and never consumed. The content is
  the generic EF lemma, wearing an ordered-sum costume.
* `component_extend_fwd` / `component_extend_bwd` (`NEquivalence.lean:221`, `:242`) are the
  converse direction — normal-form agreement at depth `K+1` yields a matching witness with
  normal-form agreement at depth `K` — stated for a summand pair `ms j`, `ms' j` but proved
  using nothing about summands.

Both directions are re-stated here for **arbitrary pairs of structures**, which is what a
*two-index* argument needs: there the witness on one side is matched at a *different* index on
the other, so nothing can be phrased through a single `I`. `BackForth` is the relation, and
`kEquiv_iff_backForth` is the characterization.

## Main results

* `BackForth` — the depth-indexed back-and-forth relation on environments.
* `nfAgree_of_backForth` — a depth-`d` strategy gives depth-`d` normal-form agreement.
* `backForth_of_nfAgree` — and conversely.
* `kEquiv_iff_backForth` — the sentence-level (`n = 0`) characterization of `KEquiv`.
* `backForth_mono` — a strategy for a longer game restricts to a shorter one.

## References
- Doets 1989, Section 1 (n-characteristics and the game): `literature/Doets_1989_Monadic_Pi11_Theories.md`
- Ehrenfeucht-Fraïssé: the standard equivalence of `≡ₖ` with the depth-`k` game
-/

namespace FormalSystem.Metalogic.WeakCanonical

/-! ## The back-and-forth relation -/

/--
**Duplicator has a depth-`d` strategy** from the matched pair of environments `eM`, `eN`.

At depth `0` there is nothing left to play, so the relation is `True`; the *winning* condition
(atom agreement) is carried as a separate hypothesis by the lemmas below rather than folded in
here, matching `BiCompat`'s shape in `NEquivalence.lean`.

At depth `d + 1`, Spoiler may move in either structure and Duplicator answers with a point that
(i) preserves every atom of the extended environments and (ii) leaves a depth-`d` strategy.
-/
def BackForth (sig : MonadicSignature) :
    Nat → (n : Nat) → (M N : OrderedMonadicStructure sig) →
    (Fin n → M.carrier) → (Fin n → N.carrier) → Prop
  | 0, _, _, _, _, _ => True
  | d + 1, n, M, N, eM, eN =>
    (∀ b : N.carrier, ∃ a : M.carrier,
      (∀ ak : AtomKind sig (n + 1),
        AtomEval M (Fin.cons a eM) ak ↔ AtomEval N (Fin.cons b eN) ak) ∧
      BackForth sig d (n + 1) M N (Fin.cons a eM) (Fin.cons b eN)) ∧
    (∀ a : M.carrier, ∃ b : N.carrier,
      (∀ ak : AtomKind sig (n + 1),
        AtomEval M (Fin.cons a eM) ak ↔ AtomEval N (Fin.cons b eN) ak) ∧
      BackForth sig d (n + 1) M N (Fin.cons a eM) (Fin.cons b eN))

/-- `AtomKind sig 0` is empty: no predicate atom (no variable to apply it to) and no order atom
(no pair of distinct variables). Restates `NEquivalence.lean`'s private `atomKind_zero_elim`. -/
theorem atomKind_zero_isEmpty {sig : MonadicSignature} (a : AtomKind sig 0) : False :=
  match a with
  | .pred _ i => Fin.elim0 i
  | .order i _ _ => Fin.elim0 i

/-! ## From a strategy to normal-form agreement

This is `sum_nf_lift_gen` (`NEquivalence.lean:831`) with the ordered-sum specifics removed. The
induction is on the depth, with the number of variables generalized: each quantifier step spends
one unit of depth and gains one variable.
-/

/-- **A depth-`d` strategy yields depth-`d` normal-form agreement.** -/
theorem nfAgree_of_backForth (sig : MonadicSignature) :
    ∀ (d n : Nat) (M N : OrderedMonadicStructure sig)
      (eM : Fin n → M.carrier) (eN : Fin n → N.carrier),
      (∀ ak : AtomKind sig n, AtomEval M eM ak ↔ AtomEval N eN ak) →
      BackForth sig d n M N eM eN →
      ∀ nf : NormalForm sig d n, NfEvalNf M d n eM nf ↔ NfEvalNf N d n eN nf := by
  intro d
  induction d with
  | zero =>
    intro n M N eM eN h_atoms _ nf
    simp only [NfEvalNf]
    exact ⟨fun hM a => (h_atoms a).symm.trans (hM a),
           fun hN a => (h_atoms a).trans (hN a)⟩
  | succ d ih =>
    intro n M N eM eN h_atoms h_bf nf
    obtain ⟨atom_assgn, quant_assgn⟩ := nf
    obtain ⟨h_fwd, h_bwd⟩ := h_bf
    simp only [NfEvalNf]
    constructor
    · rintro ⟨hM_at, hM_qt⟩
      refine ⟨fun a => (h_atoms a).symm.trans (hM_at a), fun sub_nf => ?_⟩
      rw [← hM_qt sub_nf]
      constructor
      · rintro ⟨b, hb⟩
        obtain ⟨a, hat, hbf⟩ := h_fwd b
        exact ⟨a, (ih (n + 1) M N _ _ hat hbf sub_nf).mpr hb⟩
      · rintro ⟨a, ha⟩
        obtain ⟨b, hat, hbf⟩ := h_bwd a
        exact ⟨b, (ih (n + 1) M N _ _ hat hbf sub_nf).mp ha⟩
    · rintro ⟨hN_at, hN_qt⟩
      refine ⟨fun a => (h_atoms a).trans (hN_at a), fun sub_nf => ?_⟩
      rw [← hN_qt sub_nf]
      constructor
      · rintro ⟨a, ha⟩
        obtain ⟨b, hat, hbf⟩ := h_bwd a
        exact ⟨b, (ih (n + 1) M N _ _ hat hbf sub_nf).mp ha⟩
      · rintro ⟨b, hb⟩
        obtain ⟨a, hat, hbf⟩ := h_fwd b
        exact ⟨a, (ih (n + 1) M N _ _ hat hbf sub_nf).mpr hb⟩

/-! ## From normal-form agreement to a strategy

`extend_fwd` / `extend_bwd` restate `component_extend_fwd` / `component_extend_bwd`
(`NEquivalence.lean:221`, `:242`) for an arbitrary pair of structures. The proofs are the
originals verbatim with `ms j`, `ms' j` replaced by `M`, `N`: they use only
`nf_characteristic_satisfies`, `nf_eval_unique` and `nf_agreement_from_shared_nf`, none of
which knows about summands.
-/

/-- Given depth-`(K+1)` agreement at `r` variables and a point `b` of `N`, produce a point `a`
of `M` such that the extended environments agree at depth `K` on `r + 1` variables. -/
theorem extend_fwd {sig : MonadicSignature} {K r : Nat}
    (M N : OrderedMonadicStructure sig)
    (eM : Fin r → M.carrier) (eN : Fin r → N.carrier)
    (h : ∀ nf : NormalForm sig (K + 1) r,
      NfEvalNf M (K + 1) r eM nf ↔ NfEvalNf N (K + 1) r eN nf)
    (b : N.carrier) :
    ∃ a : M.carrier, ∀ nf : NormalForm sig K (r + 1),
      NfEvalNf M K (r + 1) (Fin.cons a eM) nf ↔
      NfEvalNf N K (r + 1) (Fin.cons b eN) nf := by
  have hM := nf_characteristic_satisfies M (K + 1) r eM
  have hN := nf_characteristic_satisfies N (K + 1) r eN
  have heq := nf_eval_unique N (K + 1) r eN _ _ ((h _).mp hM) hN
  obtain ⟨_, hMq⟩ := hM; obtain ⟨_, hNq⟩ := heq ▸ hN
  set ch := nfCharacteristic N K (r + 1) (Fin.cons b eN)
  obtain ⟨a, ha⟩ := ((hMq ch).trans (hNq ch).symm).mpr
    ⟨b, nf_characteristic_satisfies ..⟩
  exact ⟨a, nf_agreement_from_shared_nf _ _ _ _ ch ha
    (nf_characteristic_satisfies ..)⟩

/-- Symmetric counterpart of `extend_fwd`: find `b` in `N` given `a` in `M`. -/
theorem extend_bwd {sig : MonadicSignature} {K r : Nat}
    (M N : OrderedMonadicStructure sig)
    (eM : Fin r → M.carrier) (eN : Fin r → N.carrier)
    (h : ∀ nf : NormalForm sig (K + 1) r,
      NfEvalNf M (K + 1) r eM nf ↔ NfEvalNf N (K + 1) r eN nf)
    (a : M.carrier) :
    ∃ b : N.carrier, ∀ nf : NormalForm sig K (r + 1),
      NfEvalNf M K (r + 1) (Fin.cons a eM) nf ↔
      NfEvalNf N K (r + 1) (Fin.cons b eN) nf := by
  have hM := nf_characteristic_satisfies M (K + 1) r eM
  have hN := nf_characteristic_satisfies N (K + 1) r eN
  have heq := nf_eval_unique N (K + 1) r eN _ _ ((h _).mp hM) hN
  obtain ⟨_, hMq⟩ := hM; obtain ⟨_, hNq⟩ := heq ▸ hN
  set ch := nfCharacteristic M K (r + 1) (Fin.cons a eM)
  obtain ⟨b, hb⟩ := ((hMq ch).trans (hNq ch).symm).mp
    ⟨a, nf_characteristic_satisfies ..⟩
  exact ⟨b, nf_agreement_from_shared_nf _ _ _ _ ch
    (nf_characteristic_satisfies ..) hb⟩

/-- **Depth-`d` normal-form agreement yields a depth-`d` strategy.**

The strategy is *read off* the normal forms: `extend_fwd` supplies the answering point and the
agreement one depth down, and `atom_agreement_from_nf` extracts the winning condition from that
same agreement. -/
theorem backForth_of_nfAgree (sig : MonadicSignature) :
    ∀ (d n : Nat) (M N : OrderedMonadicStructure sig)
      (eM : Fin n → M.carrier) (eN : Fin n → N.carrier),
      (∀ nf : NormalForm sig d n, NfEvalNf M d n eM nf ↔ NfEvalNf N d n eN nf) →
      BackForth sig d n M N eM eN := by
  intro d
  induction d with
  | zero => intro n M N eM eN _; trivial
  | succ d ih =>
    intro n M N eM eN h
    refine ⟨fun b => ?_, fun a => ?_⟩
    · obtain ⟨a, ha⟩ := extend_fwd M N eM eN h b
      exact ⟨a, fun ak => atom_agreement_from_nf M _ N _ ha ak,
        ih (n + 1) M N _ _ ha⟩
    · obtain ⟨b, hb⟩ := extend_bwd M N eM eN h a
      exact ⟨b, fun ak => atom_agreement_from_nf M _ N _ hb ak,
        ih (n + 1) M N _ _ hb⟩

/-! ## The characterization at sentence level -/

/-- **`M ≡ₖ N` follows from a depth-`k` strategy on the empty environments.** -/
theorem kEquiv_of_backForth {sig : MonadicSignature} (k : Nat)
    (M N : OrderedMonadicStructure sig)
    (h : BackForth sig k 0 M N Fin.elim0 Fin.elim0) : KEquiv sig k M N := by
  unfold KEquiv kTypeOf
  funext nf
  simp only [decide_eq_decide]
  exact nfAgree_of_backForth sig k 0 M N Fin.elim0 Fin.elim0
    (fun a => (atomKind_zero_isEmpty a).elim) h nf

/-- **`M ≡ₖ N` supplies a depth-`k` strategy on the empty environments.** -/
theorem backForth_of_kEquiv {sig : MonadicSignature} (k : Nat)
    (M N : OrderedMonadicStructure sig)
    (h : KEquiv sig k M N) : BackForth sig k 0 M N Fin.elim0 Fin.elim0 := by
  refine backForth_of_nfAgree sig k 0 M N Fin.elim0 Fin.elim0 (fun nf => ?_)
  unfold KEquiv kTypeOf at h
  have h_pt := congr_fun h nf
  simp only [decide_eq_decide] at h_pt
  exact h_pt

/-- **The Ehrenfeucht-Fraïssé characterization of `k`-equivalence.** -/
theorem kEquiv_iff_backForth {sig : MonadicSignature} (k : Nat)
    (M N : OrderedMonadicStructure sig) :
    KEquiv sig k M N ↔ BackForth sig k 0 M N Fin.elim0 Fin.elim0 :=
  ⟨backForth_of_kEquiv k M N, kEquiv_of_backForth k M N⟩

/-! ## Monotonicity -/

/-- A strategy for the `(d+1)`-move game restricts to one for the `d`-move game. -/
theorem backForth_succ (sig : MonadicSignature) :
    ∀ (d n : Nat) (M N : OrderedMonadicStructure sig)
      (eM : Fin n → M.carrier) (eN : Fin n → N.carrier),
      BackForth sig (d + 1) n M N eM eN → BackForth sig d n M N eM eN := by
  intro d
  induction d with
  | zero => intro n M N eM eN _; trivial
  | succ d ih =>
    intro n M N eM eN h
    obtain ⟨h_fwd, h_bwd⟩ := h
    refine ⟨fun b => ?_, fun a => ?_⟩
    · obtain ⟨a, hat, hbf⟩ := h_fwd b
      exact ⟨a, hat, ih (n + 1) M N _ _ hbf⟩
    · obtain ⟨b, hat, hbf⟩ := h_bwd a
      exact ⟨b, hat, ih (n + 1) M N _ _ hbf⟩

/-- A strategy for a longer game restricts to any shorter one. -/
theorem backForth_mono {sig : MonadicSignature} {d d' n : Nat}
    {M N : OrderedMonadicStructure sig}
    {eM : Fin n → M.carrier} {eN : Fin n → N.carrier}
    (hdd : d ≤ d') (h : BackForth sig d' n M N eM eN) : BackForth sig d n M N eM eN := by
  obtain ⟨e, rfl⟩ : ∃ e, d' = d + e := ⟨d' - d, by omega⟩
  clear hdd
  induction e with
  | zero => exact h
  | succ e ih =>
    refine ih (backForth_succ sig (d + e) n M N eM eN ?_)
    have hsucc : d + (e + 1) = (d + e) + 1 := by omega
    exact hsucc ▸ h

end FormalSystem.Metalogic.WeakCanonical
