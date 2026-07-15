import Bimodal.Metalogic.WeakCanonical.PriorDefs
import Mathlib.Order.Basic
import Mathlib.Order.SuccPred.Basic
import Mathlib.Order.SuccPred.Archimedean

/-! # Intended model class — does `semantic_prior_UZ` already exclude `(ℚ,<)`?

Throwaway research probe for report `04_intended-model-class.md`. Touches NO production file.

## The question this settles

All three seam refutations (reports/02, reports/03) rest on ONE non-vacuity witness: an
order-homogeneous model such as `(ℚ,<)` lying inside the seam's free `∀ M : OrderedMonadicStructure`
range, where an anchor-fixing automorphism transports the completeness biconditional between two
distinct renders.

The top-level target `kamp_prior_expressive_completeness` (`KampPrior.lean:648`) does NOT quantify
over a free `∀ M`: it carries `semantic_prior_UZ` / `semantic_prior_SZ`
(`PriorDefs.lean:22-28`, `:33-39`). `PriorExpressiveness.lean:337` describes these as the proof
being "relativized from Dedekind completeness to `semantic_prior_UZ/SZ`".

CONTESTED CLAIM (a research sub-agent asserted this from that doc comment):
  "UZ/SZ are the *definable*-first-occurrence surrogate; they are satisfiable on ℚ, so they do
   NOT exclude dense flows."

If that were true, Route C (restrict the model class) would be a genuine narrowing of the theorem.
This probe refutes it OUTRIGHT, and the refutation is interpretation-independent.

## Mechanism

`semantic_prior_UZ` quantifies over ALL `ψ : Formula`, including a TAUTOLOGY. Since
`Formula.neg φ = φ.imp bot` (`Syntax/Formula.lean:115`) and
`temporal_truth _ _ _ .bot = False` (`Table.lean:187`), instantiating `ψ := ⊤` makes the
"`ψ.neg` holds strictly between" clause collapse to `False`, so the postulated first occurrence
`s` must have EMPTY open interval `(t,s)` — i.e. `s` is an IMMEDIATE SUCCESSOR of `t`.

Hence `semantic_prior_UZ ⟹ discreteness`, for EVERY `atomMap` — no interpretation can rescue a
dense order. `(ℚ,<)` is densely ordered with no maximum, so it fails `semantic_prior_UZ` outright.
-/

namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax

/-- The always-true formula `⊥ → ⊥`. -/
private def taut : Formula := Formula.bot.neg

private theorem truth_taut {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (t : M.carrier) :
    temporal_truth M atomMap t taut := by
  intro h; exact h

private theorem not_truth_taut_neg {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (t : M.carrier) :
    ¬ temporal_truth M atomMap t taut.neg := by
  intro h; exact h (truth_taut M atomMap t)

/-- **Result 1 — `semantic_prior_UZ` forces immediate successors (discreteness).**

For ANY `atomMap`: if `t` is not maximal, `t` has an immediate successor. Instantiating the
`∀ ψ` of `semantic_prior_UZ` at a tautology collapses the "between" clause to `False`. -/
theorem prior_UZ_forces_immediate_successor {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_UZ : semantic_prior_UZ M atomMap)
    (t : M.carrier) (hne : ∃ s : M.carrier, t < s) :
    ∃ s : M.carrier, t < s ∧ ∀ r : M.carrier, t < r → r < s → False := by
  obtain ⟨s0, hs0⟩ := hne
  obtain ⟨s, hts, _, hgap⟩ := h_UZ t taut ⟨s0, hs0, truth_taut M atomMap s0⟩
  exact ⟨s, hts, fun r hr1 hr2 => not_truth_taut_neg M atomMap r (hgap r hr1 hr2)⟩

/-- Dual: `semantic_prior_SZ` forces immediate predecessors. -/
theorem prior_SZ_forces_immediate_predecessor {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_SZ : semantic_prior_SZ M atomMap)
    (t : M.carrier) (hne : ∃ s : M.carrier, s < t) :
    ∃ s : M.carrier, s < t ∧ ∀ r : M.carrier, s < r → r < t → False := by
  obtain ⟨s0, hs0⟩ := hne
  obtain ⟨s, hst, _, hgap⟩ := h_SZ t taut ⟨s0, hs0, truth_taut M atomMap s0⟩
  exact ⟨s, hst, fun r hr1 hr2 => not_truth_taut_neg M atomMap r (hgap r hr1 hr2)⟩

/-- **Result 2 (DECISIVE) — no densely-ordered flow satisfies `semantic_prior_UZ`.**

Holds for EVERY `atomMap`: the exclusion is interpretation-independent. `(ℚ,<)` is densely
ordered with no maximum, so `(ℚ,<)` is OUTSIDE the model class of
`kamp_prior_expressive_completeness` / `US_expressively_complete_over_prior`. -/
theorem prior_UZ_fails_on_dense {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    [DenselyOrdered M.carrier] [NoMaxOrder M.carrier]
    (t : M.carrier) :
    ¬ semantic_prior_UZ M atomMap := by
  intro h_UZ
  obtain ⟨u, htu⟩ := exists_gt t
  obtain ⟨s, hts, hgap⟩ := prior_UZ_forces_immediate_successor M atomMap h_UZ t ⟨u, htu⟩
  obtain ⟨r, hr1, hr2⟩ := exists_between hts
  exact hgap r hr1 hr2

/-- Dual for `semantic_prior_SZ`. -/
theorem prior_SZ_fails_on_dense {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    [DenselyOrdered M.carrier] [NoMinOrder M.carrier]
    (t : M.carrier) :
    ¬ semantic_prior_SZ M atomMap := by
  intro h_SZ
  obtain ⟨u, hut⟩ := exists_lt t
  obtain ⟨s, hst, hgap⟩ := prior_SZ_forces_immediate_predecessor M atomMap h_SZ t ⟨u, hut⟩
  obtain ⟨r, hr1, hr2⟩ := exists_between hst
  exact hgap r hr1 hr2

/-- **Result 3 — the refutations' non-vacuity witness is NOT in the Prior model class.**

Packaged for the report: any model that is dense (the property `(ℚ,<)` is used for, supplying
both the second render `w'` and the anchor-fixing automorphism) CANNOT satisfy the `h_UZ`
hypothesis that `kamp_prior_expressive_completeness` (`KampPrior.lean:654`),
`bracketEndChar_kvExtFib_correct_prior` (`ExteriorGateAssembleK.lean:572`) and
`kampPrior_site_rungKFib_gate_match` (`KampPrior.lean:1071`) already carry. -/
theorem dense_witness_outside_prior_class {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    [DenselyOrdered M.carrier] [NoMaxOrder M.carrier]
    (t : M.carrier) :
    ¬ (semantic_prior_UZ M atomMap ∧ semantic_prior_SZ M atomMap) :=
  fun h => prior_UZ_fails_on_dense M atomMap t h.1

/-! ## Result 4 — the Route-C soundness result

`semantic_prior_UZ` alone kills DENSE flows (Result 2), but NOT every anchor-non-rigid flow:
`ℚ`-many `ℤ`-blocks is discrete (so it can satisfy UZ/SZ under a coarse interpretation) yet has
anchor-fixing automorphisms permuting interior blocks. So UZ/SZ alone does NOT suffice for
Route C.

The hypothesis that DOES suffice is the Archimedean discreteness bundle — which
`valid_discrete` (`Theories/Bimodal/Semantics/Validity.lean:180-186`) ALREADY carries
(`[SuccOrder D] [PredOrder D] [IsSuccArchimedean D] [IsPredArchimedean D]`), and which the sole
live instantiation (ℤ, `Transfer.lean:1221`) satisfies.

Under it, an order-automorphism fixing the anchor `x` fixes EVERY point above `x`. Hence no
`α` fixing `x,t` with `α w0 = w' ≠ w0` exists — the transport leg (`htransport`/`hSym`) that
every one of the three refutations rests on is UNSATISFIABLE. -/
theorem archimedean_forces_anchor_rigidity {α : Type}
    [LinearOrder α] [SuccOrder α] [IsSuccArchimedean α]
    (f : α ≃o α) (x : α) (hfx : f x = x) (y : α) (hxy : x ≤ y) : f y = y := by
  obtain ⟨n, rfl⟩ := exists_succ_iterate_of_le hxy
  induction n with
  | zero => simpa using hfx
  | succ m ih =>
      rw [Function.iterate_succ_apply', OrderIso.map_succ, ih (Order.le_succ_iterate m x)]

/-- Packaged: under Archimedean discreteness there is NO anchor-fixing automorphism moving a
render `w0` to a DISTINCT render `w'` above the anchor. This is exactly the `hSym` /
`htransport` hypothesis of `existentialSeam_refuted_of_render_symmetry`
(`reports/03_existential-w-probe.lean`) — it cannot be supplied. -/
theorem no_cross_render_automorphism_of_archimedean {α : Type}
    [LinearOrder α] [SuccOrder α] [IsSuccArchimedean α]
    (f : α ≃o α) (x : α) (hfx : f x = x)
    (w0 w' : α) (hxw0 : x ≤ w0) (hmove : f w0 = w') : w' = w0 :=
  hmove ▸ archimedean_forces_anchor_rigidity f x hfx w0 hxw0

#print axioms prior_UZ_forces_immediate_successor
#print axioms prior_UZ_fails_on_dense
#print axioms prior_SZ_fails_on_dense
#print axioms dense_witness_outside_prior_class
#print axioms archimedean_forces_anchor_rigidity
#print axioms no_cross_render_automorphism_of_archimedean

end Bimodal.Metalogic.WeakCanonical
