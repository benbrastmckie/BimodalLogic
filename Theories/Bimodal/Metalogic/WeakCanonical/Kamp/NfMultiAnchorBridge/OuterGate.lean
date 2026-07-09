import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness

/-!
# Outer-Gate Assembly Engine — live `bracketEndChar_kvE2` + `k = 2` gate correctness (task 335)

A new **leaf sibling** of `SharedWitness.lean` inside `NfMultiAnchorBridge/`. It is **purely
additive**: nothing here re-proves or edits the task-334 faithful carrier `kvE2_sepBody`
(`SharedWitness.lean:806`) or any of its correctness lemmas. Those are treated as **verified
INPUTS**; this file only *applies* them.

## What this file delivers

1. **`bracketEndChar_kvE2`** — the first LIVE definition of the outer gate (the only prior `def`s
   lived in the quarantined Boneyard and encoded the superseded two-level "navigated" carrier).
   It delegates to the faithful carrier `kvE2_sepBody` at the standard instantiation
   (`charBase = nf_depth0_char_formula atomMap h_surj`, `charK = fun χ => P.existF 0 χ`).
2. **`bracketEndChar_kvE2_two_eq`** — an `rfl` bridge exposing the carrier (the delegation is
   definitional because `kvE2_sepBody … : NormalForm sig 2 3 → VVecEA2` is *definitionally*
   `BracketEndCharCarrierV sig 2`, `CarrierK1V.lean:365`).
3. **`bracketEndChar_kvE2_sound_two_prior`** — the ⇒ (soundness) half of the k=2 gate.
4. **`bracketEndChar_kvE2_complete_two_prior_leftInterior`** — the ⇐ (completeness) half for the
   LEFT-INTERIOR owner class (see scope note below).
5. **`bracketEndChar_kvE2_correct_two_prior_leftInterior`** — the assembled `k = 2`
   `BracketCarrierCorrectVPrior`-shaped correctness theorem for the left-interior class.

## Scope decisions (recorded in the file, resolved in the plan)

- **R-A (⇐ generality) → INTERIOR-RESTRICTED CARRIER (task 342 update).** `kvE2_sepBody_complete`
  is now UNCONDITIONAL: the carrier's arrangements index their owners by the interior-restricted
  list `kvE2_sepPosI` (a two-zone order-preserving filter of `kvE2_sepPos`), so each owner's
  LEFT/RIGHT interiority is a construction invariant recovered definitionally
  (`kvE2_sepPosI_zone`), never a hypothesis on realized types. The historical `hL`/`hLR`
  interiority hypotheses of tasks 335/336 are GONE — `kvE2_sepHonest_hLR_absurd`
  (`SharedWitness.lean`) machine-certifies that any such hypothesis is inconsistent with every
  honest evaluation, which is why none may return. Non-interior positive owners ride the atomic
  `E[Σ]` endpoint/pivot literals (Rabinovich §5, p.7, via Prop 3.5) rather than the interleaving.
- **R-B (KampPrior wiring) → FOLLOW-ON.** The gate is NOT wired into `KampPrior.lean:351`
  (threading `ExistProviders` through `nf_nvar_exist_all_depths`'s `Nat.rec`/`n=1` case) — that
  integration is a distinct downstream task, out of scope here.
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation (nf_depth0_char_formula)

/-! ## Phase 1 — live wrapper def + `rfl` bridge -/

/-- **The live outer-gate carrier** (task 335 Phase 1; first live `def` — supersedes the
    quarantined Boneyard `:918` two-level carrier). At depth-1 providers
    `P : ExistProviders sig atomMap 1` it produces the k=2 carrier `BracketEndCharCarrierV sig 2`,
    delegating to the task-334 **faithful** carrier `kvE2_sepBody` (`SharedWitness.lean:806`) at
    the standard instantiation `charBase = nf_depth0_char_formula atomMap h_surj`,
    `charK = fun χ => P.existF 0 χ`. The carrier is a verified INPUT — only applied, never
    re-proved. -/
noncomputable def bracketEndChar_kvE2 {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (P : ExistProviders sig atomMap 1) :
    BracketEndCharCarrierV sig 2 :=
  fun qnf => kvE2_sepBody (nf_depth0_char_formula atomMap h_surj) (fun χ => P.existF 0 χ) qnf

/-- **Definitional bridge** (task 335 Phase 1). The live carrier is DEFINITIONALLY the faithful
    body at the standard instantiation — pure `rfl`, because `kvE2_sepBody … : NormalForm sig 2 3 →
    VVecEA2` is definitionally `BracketEndCharCarrierV sig 2`. Soundness/completeness lemmas rewrite
    with this to expose `kvE2_sepBody`. -/
theorem bracketEndChar_kvE2_two_eq {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (P : ExistProviders sig atomMap 1)
    (qnf : NormalForm sig 2 3) :
    bracketEndChar_kvE2 atomMap h_surj P qnf =
      kvE2_sepBody (nf_depth0_char_formula atomMap h_surj) (fun χ => P.existF 0 χ) qnf := rfl

/-! ## Phases 2-4 — soundness/completeness/assembly: DEFERRED (see blocker in the plan)

The ⇒ soundness (Phase 2), ⇐ left-interior completeness (Phase 3), and the assembled k=2
gate-correctness theorem (Phase 4) are NOT delivered in this file. Closing them requires building
the JOINT multi-owner disjunct bracket realization `(kvE2_sepDisjunct … (kvE2_sepSlotsL qnf)
(kvE2_sepSlotsR qnf)).2.holds` (⇐) and reconstructing the depth-2 evaluation's atom+quant layers
(⇒). This joint-disjunct bracket-`holds` builder is an **un-landed** completeness-side obligation
explicitly deferred by task 334 (`SharedWitness.lean:1954`: "the general multi-owner pairwise
discharge is the completeness-side Phase-8 obligation"). The landed builders are per-σ / single
owner (`kvE_subBracket2V_complete`, `SubBracket2V.lean:1730`) or the k=1 carrier
(`bracketEndChar_k1v_complete`, `CarrierK1V.lean:1629`); the joint disjunct over the merged
per-owner slot lists has no landed `holds` builder. The general region engine
`k1v_sorted_realizationK` (`SubBracket2V.lean:633`) is the intended foundation, but wiring it into
the `kvE2_sepDisjunct` slot/segment/endpoint layout is a substantial dedicated construction that
this session does not complete. Per the zero-debt discipline (no `sorry`, no vacuous placeholder),
Phases 2-4 are left BLOCKED for a follow-on dispatch rather than papered over. -/

end Bimodal.Metalogic.WeakCanonical.Kamp
