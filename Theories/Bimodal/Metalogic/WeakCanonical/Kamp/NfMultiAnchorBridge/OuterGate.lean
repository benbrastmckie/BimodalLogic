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
   LEFT-INTERIOR owner class (`hL`-guarded; see scope note below).
5. **`bracketEndChar_kvE2_correct_two_prior_leftInterior`** — the assembled `k = 2`
   `BracketCarrierCorrectVPrior`-shaped correctness theorem for the left-interior class.

## Scope decisions (recorded in the file, resolved in the plan)

- **R-A (⇐ generality) → LEFT-INTERIOR ONLY.** `kvE2_sepBody_complete` requires the hypothesis
  `hL : ∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zXW3` (all positive owners
  left-interior). Extending the validity channel (`kvE2_sepDisjValidOwner`) to the
  placement-generic self-zone / right-interior class would touch the verified carrier INPUT and is
  deferred to **task 336**. This task therefore proves the gate for the left-interior owner class
  only, exposing the restriction as an EXPLICIT `hL` hypothesis rather than a hidden assumption
  (additive, zero-debt).
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

end Bimodal.Metalogic.WeakCanonical.Kamp
