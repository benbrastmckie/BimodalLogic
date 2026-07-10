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
3. **`bracketEndChar_kvE2_complete_two_prior`** (task 335 Phase 2) — the ⇐ (completeness) half of
   the k=2 gate, UNCONDITIONAL (no interiority hypothesis); consumes the landed task-337 engine
   `kvE2_sepBody_holds_of_honest`. Plus its two char-formula bridges `bracketEndChar_kvE2_hcb`/
   `bracketEndChar_kvE2_hck`.
4. **⇒ soundness (`bracketEndChar_kvE2_sound_two_prior`) — NOT delivered, BLOCKED.** See the
   "Phases 3-5 — BLOCKED" note at the end of this file: the multi-owner soundness `hgate`
   forward-zone conjunct is underdetermined by the faithful carrier's realized content (landed
   O4 CRUX RECORD, `SharedWitness.lean:6566-6659`); the faithful repair requires a carrier
   REDEFINITION outside this task's additive scope.
5. **Assembled `bracketEndChar_kvE2_correct_two_prior` — NOT delivered** (depends on 4).

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

/-! ## Phase 2 — ⇐ completeness half: consume `kvE2_sepBody_holds_of_honest`

The reverse (mpr) direction of the k=2 gate: an honest depth-2 evaluation of `qnf` at the bracket
witness `w` (with `x < w < t` recovered from the atom layer) forces the carrier body `.holds`. This
is a **consumption** of the landed task-337 completeness engine `kvE2_sepBody_holds_of_honest`
(`SharedWitness.lean:9262`) — no new engine, no interiority hypothesis. The gate `hg` is discharged
by the landed `kvE2_sepGate_holds_of_honest` (`SharedWitness.lean:2666`); the two char-formula
bridges `hcb`/`hck` are built from `nf_depth0_char_formula_correct` (KampTranslation:141) and
`P.correct` (the `ExistProviders` correctness field) with the `Fin 0` env collapse. -/

/-- **⇐ completeness bridge for the char-base layer** (task 335 Phase 2): the standard-instantiation
    depth-0 characteristic formula is truth-equivalent to the arity-1 evaluation. Extracted from the
    landed `nf_char2_atom_layer` proof (`Base.lean:58`), specialized to the plain arity-1 iff. -/
theorem bracketEndChar_kvE2_hcb {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (M : OrderedMonadicStructure sig) (χ : NormalForm sig 0 1) (u : M.carrier) :
    temporal_truth M atomMap u (nf_depth0_char_formula atomMap h_surj χ) ↔
      nf_eval_nf M 0 1 (fun _ => u) χ := by
  rw [Separation.nf_depth0_char_formula_correct]
  simp only [nf_eval_nf]
  constructor
  · intro h a
    obtain ⟨p, rfl⟩ := atomKind_arity1_is_pred a
    simp only [atom_eval]
    exact h p
  · intro h p
    have hp := h (.pred p ⟨0, by omega⟩)
    simpa only [atom_eval] using hp

/-- **⇐ completeness bridge for the provider layer** (task 335 Phase 2): the depth-1 existential
    provider formula `P.existF 0 χ` is truth-equivalent to the arity-1 depth-1 evaluation, via the
    `ExistProviders.correct` field at `n = 0` and the `Fin 0 → M.carrier` env collapse
    (`insertEnv` on the empty env is `fun _ => u`). -/
theorem bracketEndChar_kvE2_hck {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (P : ExistProviders sig atomMap 1)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (χ : NormalForm sig 1 1) (u : M.carrier) :
    temporal_truth M atomMap u (P.existF 0 χ) ↔ nf_eval_nf M 1 1 (fun _ => u) χ := by
  rw [P.correct 0 χ M h_UZ h_SZ u]
  constructor
  · rintro ⟨env, henv⟩
    have heq : insertEnv env u = (fun _ => u) := by
      funext i
      simp only [insertEnv]
      rw [dif_neg (by omega)]
    rwa [heq] at henv
  · intro h
    exact ⟨Fin.elim0, by rw [insertEnv_zero]; exact h⟩

/-- **⇐ completeness half of the k=2 gate** (task 335 Phase 2, UNCONDITIONAL — no `hL`/`hLR`).
    An honest depth-2 evaluation at bracket witness `w` forces the carrier body `.holds`, by
    consuming the landed completeness engine `kvE2_sepBody_holds_of_honest` (SW:9262). The order
    hypotheses are the standard six `BracketCarrierCorrectVPrior` atom-layer conditions; `w`'s
    interval position `x < w < t` is recovered from `qnf`'s own atom layer under those hypotheses
    (bracket range, NOT a chain — LITMUS-clean). -/
theorem bracketEndChar_kvE2_complete_two_prior {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (P : ExistProviders sig atomMap 1)
    (qnf : NormalForm sig 2 3)
    (h_xy : qnf.atom_assgn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.atom_assgn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf.atom_assgn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf.atom_assgn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf.atom_assgn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf.atom_assgn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (x t : M.carrier) :
    (∃ w : M.carrier, nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) →
      (bracketEndChar_kvE2 atomMap h_surj P qnf).holds M atomMap x t := by
  rintro ⟨w, h⟩
  -- Recover `x < w` and `w < t` from `qnf`'s atom layer (env `[w, x, t]`).
  have hxw : x < w := by
    have := (h.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))).mpr h_xy
    simpa only [atom_eval, Fin.cons_zero, Fin.cons_succ] using this
  have hwt : w < t := by
    have := (h.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide))).mpr h_yt
    simpa only [atom_eval, Fin.cons_zero, Fin.cons_succ] using this
  -- Gate from the landed honest-gate lemma.
  have hg : kvE2_sepGate qnf := kvE2_sepGate_holds_of_honest qnf M w x t hxw hwt h
  -- Land on the live carrier and apply the completeness engine.
  rw [bracketEndChar_kvE2_two_eq]
  exact kvE2_sepBody_holds_of_honest (nf_depth0_char_formula atomMap h_surj)
    (fun χ => P.existF 0 χ) qnf hg M atomMap w x t hxw hwt h
    (fun χ u => bracketEndChar_kvE2_hcb atomMap h_surj M χ u)
    (fun χ u => bracketEndChar_kvE2_hck atomMap P M h_UZ h_SZ χ u)

/-! ## Phases 3-5 — ⇒ soundness + assembly: now-attemptable over task 333's LANDED fold

The ⇒ (soundness) half `.holds ⟹ ∃ w, nf_eval_nf M 2 3 [w,x,t] qnf` — and hence the assembled
`bracketEndChar_kvE2_correct_two_prior` — is **now-attemptable work**, NOT the blocked obligation
the prior note recorded. The two reasons that note gave are both now false:

1. *"No landed depth-2 soundness reassembly / no depth-2 quant-layer fold."* Task 333 LANDED exactly
   that: `kvE2_outer_fold` (`SharedWitness.lean:9897`, green, axiom-clean) IS the depth-2 assembly —
   it reassembles `∃ w, nf_eval_nf M 2 3 [w,x,t] qnf` from the carrier's realized content (there is
   still no generic quant-layer fold engine, but the bespoke `kvE2_outer_fold` supersedes the need
   for one on this path).
2. *"The O4 forward-zone conjunct is underdetermined; the faithful repair needs a carrier
   REDEFINITION of the (now-deleted) `kvE2_sepValid`/`kvE2_sepArrL`/`kvE2_sepArrR`."* The O4 crux is
   DISSOLVED (task 333 report 03, H4-verified): the forward-zone `hgate` conjunct is **antecedent-
   only** and the O4 crux record is inert. The named symbols no longer exist — task 334 replaced the
   carrier with the faithful `kvE2_sepArr'` + `kvE2_sepDisjValidOwner`, and task 342 added the
   interior-restricted owner index `kvE2_sepPosI`. No `SharedWitness.lean` redefinition is required.

**What the fold requires task 335 to construct (at `charK := fun χ => P.existF 0 χ`).** The landed
`kvE2_outer_fold` does NOT yield a thin `apply`; it takes four provider-conditional hypothesis
families that task 333 deliberately punted to the 335 provider instantiation (fold docstring
SW:9858-9878, "discharged downstream at the provider instantiation `charK := P.existF 0` (task 335),
never assumed here"):

- `hgateL` / `hgateR` (SW:9911 / 9929) — the interior LEFT/RIGHT per-σ gate families for the
  `kvE2_sep_zXW3` / `kvE2_sep_zWT3` zones. Built from the hypothesis-free `kvE2_sepBody_extract`
  (SW:8410) bundles + the per-σ kit `kvE2_sepBundleL/R_parts` (SW:5379 / 5396) →
  `kvE_subBracket2V_sound_of_parts` (`SubBracket2V.lean:1290`). [Phase 4a]
- `hbdry` (SW:9946) — non-interior positive realization. `hexcl` (SW:9952) — negative-sub exclusion,
  provider-conditional in the A1 sense (`PriorInterface.lean:47-59`). Discharged from
  `ExistProviders.correct` + `h_UZ`/`h_SZ` at `P.existF 0`. [Phase 4b — the genuine risk]

The completeness half (Phase 2, above) is delivered, green, and axiom-clean. Authorization for the ⇒
work is held (task 333 Territory Contract; 335 owns `OuterGate.lean` only — the fold and kit are
verified INPUTS, applied never re-proved). Per zero-debt discipline: NO `sorry`, NO vacuous
placeholder, NO assumed family, NO interiority hypothesis on any live path. Rabinovich cited by PDF
page only: the depth-2 assembly follows Def 3.1 (p.4) point-type/ordering split and the §5 bracket
assembly with quantifier-free point types (pp.7-9); Lemma 3.2(1) (p.4) states the closure without
printed proof. -/

end Bimodal.Metalogic.WeakCanonical.Kamp
