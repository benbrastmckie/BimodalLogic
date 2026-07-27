/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.CarrierKv

/-! Extracted from NfMultiAnchorBridge.lean lines 4988-5076.
Protected prior interface (byte-identical, token edits NONE): `ExistProviders`,
`BracketCarrierCorrectVPrior`, `bracketEndChar_kv_correct_zero_prior`,
`bracketEndChar_kv_correct_one_prior`. -/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.WeakCanonical.Separation
  (nfDepth0CharFormula nf_depth0_char_formula_correct
   formulaConjList formula_conjList_iff)

/-! ## R3b statement surgery: `ExistProviders` + `BracketCarrierCorrectVPrior` + relativized k≤1
lifts

The corrected R3b interface (report 05 Pillar 1; **v6 amendment A1, report 05 §d**): after
F1/F2 refuted the *unconditional* depth-`k` correctness of the fiber-projected carrier at
k ≥ 2, the correctness TARGET is amended — the predicate gains the Prior hypotheses
`semantic_prior_UZ`/`semantic_prior_SZ` (PriorDefs:22/:33) and provider conditionality (an
`ExistProviders` bundle), exactly the hypotheses the `:351` consumer carries (F-A,
KampPrior:216-223). This amends the TARGET STATEMENT only, not G6's carrier shape; the
unconditional `BracketCarrierCorrectV` (:1873) remains valid and landed at k ≤ 1. The ∀k
quantifier is NOT restated here: it lives in KampPrior's `Nat.rec` (F-A).

Bracket framing citation (rule N1 split): the two-fixed-endpoint `(z_0, z_1)` framing is
**Lemma 3.2(2) (PDF p.4) + the §5 bracket notation `[α_0, …, α_n](z_0, z_1)` (PDF p.7)**;
**Prop 3.5 (PDF p.5)** is cited ONLY for the one-free-variable ∃-witness→Until/Since folding
mechanism. -/

/-- **Provider bundle** (report 05 Pillar 1, amendment A1 §d):
single-anchor existential converters at depth `k`, all arities, correct on Prior (UZ/SZ)
structures — what the outer recursion supplies at KampPrior:351 (recursive converters at all
depths ≤ k, the KampPrior:273 pattern). Per-round provider threading per **Cor 5.4** (the
`F_i` are TL formulas, PDF p.7/p.9); the UZ/SZ-conditional correctness field mirrors the
landed `nf_succ_char_formula_correct` hypothesis pattern (KampPrior:81 — template, read-only). -/
structure ExistProviders (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (k : Nat) where
  /-- The single-anchor existential converter: at each arity `n + 1` it turns a depth-`k`
  normal form into a temporal formula. Correctness on Prior structures is the `correct` field. -/
  existF : (n : Nat) → NormalForm sig k (n + 1) → Formula
  correct : ∀ (n : Nat) (sub : NormalForm sig k (n + 1)) (M : OrderedMonadicStructure sig)
      (_h_UZ : SemanticPriorUZ M atomMap) (_h_SZ : SemanticPriorSZ M atomMap)
      (t : M.carrier),
      TemporalTruth M atomMap t (existF n sub) ↔
        ∃ env : Fin n → M.carrier, NfEvalNf M k (n + 1) (insertEnv env t) sub

/-- **UZ/SZ-relativized carrier correctness — the corrected R3b target** (report 05 Pillar 1,
**amendment A1 §d**). The Prior-relativized variant of
`BracketCarrierCorrectV` (:1873, untouched — kept for the landed k ≤ 1 statements): the
carrier's `VVecEA2.holds` at the FIXED anchor pair `(x, t)` is equivalent to a bracket
witness `w` realizing the arity-3 depth-`k` evaluation, for every Prior (UZ/SZ) structure and
every `qnf` in the `x < w' < t` bracket zone (the six atom-layer order hypotheses, k0-mirror
form :1586-1595, stated uniformly via `NormalForm.atom_assgn` — defeq to `qnf` at `k = 0` and
to `qnf.1` at successor depth). `{x, t}` are the FIXED endpoints (Lemma 3.2(2), PDF p.4 + §5
bracket notation, PDF p.7 — rule N1 split; Prop 3.5, PDF p.5, cited only for the
∃-witness→Until/Since folding mechanism); `w` is a bracket witness (G4, G6 as amended).
Provider conditionality enters at USE sites: the k ≥ 2 carrier (`bracketEndChar_kvE`,
Phase 13.2) is parameterized by an `ExistProviders` bundle, so this predicate applied to it
is provider-conditional in exactly the A1 sense. -/
def BracketCarrierCorrectVPrior {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] (atomMap : Formula → sig.preds)
    {k : Nat} (carrier : BracketEndCharCarrierV sig k) : Prop :=
  ∀ (qnf : NormalForm sig k 3)
    (h_xy : qnf.atomAssgn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.atomAssgn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf.atomAssgn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf.atomAssgn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf.atomAssgn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf.atomAssgn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig)
    (h_UZ : SemanticPriorUZ M atomMap) (h_SZ : SemanticPriorSZ M atomMap)
    (x t : M.carrier),
    (carrier qnf).holds M atomMap x t ↔
      ∃ w : M.carrier, NfEvalNf M k 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf

/-- **`k = 0` relativized lift**. Weakening of the landed unconditional
`bracketEndChar_kv_correct_zero` (:3788 — lifted, NOT re-proved): an unconditional `↔` implies
the UZ/SZ-conditional one, so the proof just drops `h_UZ`/`h_SZ`. At `k = 0` the
`NormalForm.atom_assgn` order hypotheses are definitionally the landed `qnf (.order …)` ones.
Citations ride the consumed lemma (rule N1 split there); no chain step is shortcut (G5). -/
theorem bracketEndChar_kv_correct_zero_prior {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula) :
    BracketCarrierCorrectVPrior atomMap (bracketEndCharKv atomMap h_surj charF 0) :=
  fun qnf h_xy h_yt h_xt h_yx h_ty h_tx M _h_UZ _h_SZ x t =>
    bracketEndChar_kv_correct_zero atomMap h_surj charF qnf
      h_xy h_yt h_xt h_yx h_ty h_tx M x t

/-- **`k = 1` relativized lift**. Weakening of the landed
`bracketEndChar_kv_correct_one` (:3816 — lifted, NOT re-proved), dropping `h_UZ`/`h_SZ`; the
depth-0 provider agreement `h0` (satisfied by the Phase-14 instantiation by construction,
KampPrior:397 at depth 0) is retained. At `k = 1` the `NormalForm.atom_assgn` order hypotheses
are definitionally the landed `qnf.1 (.order …)` ones. Citations ride the consumed lemma
(rule N1 split there); no chain step is shortcut (G5). -/
theorem bracketEndChar_kv_correct_one_prior {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (h0 : charF 0 = nfDepth0CharFormula atomMap h_surj) :
    BracketCarrierCorrectVPrior atomMap (bracketEndCharKv atomMap h_surj charF 1) :=
  fun qnf h_xy h_yt h_xt h_yx h_ty h_tx M _h_UZ _h_SZ x t =>
    bracketEndChar_kv_correct_one atomMap h_surj charF h0 qnf
      h_xy h_yt h_xt h_yx h_ty h_tx M x t

end FormalSystem.Metalogic.WeakCanonical.Kamp
