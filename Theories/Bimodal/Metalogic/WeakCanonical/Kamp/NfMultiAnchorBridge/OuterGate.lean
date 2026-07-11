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

/-! ## Phase A — single-positive-sub fragment predicate + `_frag` statement surgery (task 335 v5)

The plan-v4 unconditional four-family discharge is REFUTED (report 04): over an arbitrary `qnf`
the fold's FORWARD gate conjunct `(∃ v, zoneHolds … zs v ∧ nf_eval χ) → σ.2 (nf0_assemble zs χ σ.1)
= true` is false in a rich model (`σ.2` need not mark every realizable `(zs, χ)`). Task 321 verdict
N2 re-scopes the 309 Phase 13.4 / `KampPrior.lean:351` deliverable to the **single-positive-sub
fragment**, where the O4 CRUX RECORD (`SharedWitness.lean:6785-6791`) states the cross-σ residue
VANISHES: with one interior positive there are no cross-σ slot points, so every witness is σ0's own
bit-true 1-type or a literal/segment-covered self-zone point.

`kvE2_sepFragment qnf` is a pure `qnf`-domain restriction (positivity + interior zone of the sole
positive sub); it depends ONLY on `qnf`, never on `M`/`atomMap`/`P`/a realized type. It is the sole
sanctioned hypothesis beyond the provider shape — NOT a provider-conditional family. -/

/-- **Single-positive-sub fragment predicate** (task 335 v5 Phase A). `qnf`'s positive-sub list is
    exactly the singleton `[σ0]` and `σ0` is interior-zoned (`x < x1 < w` or `w < x1 < t`). This is
    the qnf-domain narrowing task 321 verdict N2 sanctions: it collapses the fold's four
    provider-conditional families to the residue-vanish case (O4 record SW:6785-6791). Depends only
    on `qnf` (its positivity + zone structure), never on a model or provider.

    VACUITY NOTE (task 335 report 07, 2026-07-11 — UNREALIZABILITY FLAGGED, pending successor
    verification): the GLOBAL singleton demand (`kvE2_sepPos qnf = [σ0]` filters `Finset.univ`,
    SW:193) is flagged unrealizable — `nf_exists_unique` (NormalForm.lean:276) realizes a
    characteristic depth-1 form at every point, and with `x < w < t` the characteristic forms at
    `x1 := w/x/t` are pairwise distinct, so any REALIZED `qnf` carries ≥3 positive bits. The
    intended N2 fragment is plausibly the INTERIOR-restricted singleton (`kvE2_sepPosI`, SW:211).
    Do NOT build on this predicate before the successor carrier task re-examines it; see
    specs/335_outer_gate_assembly_engine_kvE2_body/reports/07_hexcl-enrichment-derivability.md. -/
def kvE2_sepFragment {sig : MonadicSignature} (qnf : NormalForm sig 2 3) : Prop :=
  ∃ σ0 : NormalForm sig 1 4,
    kvE2_sepPos qnf = [σ0] ∧
    (nf0_zoneSpec σ0.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ0.1 = kvE2_sep_zWT3)

/-! ## Phase B — ⇒ soundness half over the pin-anchored fold `kvE2_outer_fold_frag` (task 335 v5)

Task 345 landed the SYMMETRIC gate (Rabinovich Cor 5.4, clause (v)): the RIGHT inner-consistency is
now a gate consequence, so the former `hInnerR` obligation is dissolved, and the pin-anchored fold
`kvE2_outer_fold_frag` (`SharedWitness.lean:12529`, tasks 344/345) takes only `hfrag` + `hcorrK` +
`hexcl` beyond the provider shape. This SUPERSEDES the pre-345 four-family blocker: the interior
gates `hgateL`/`hgateR` and the non-interior `hbdry` are now internal to the fold — discharged inside
`kvE2_sepBody_kit_sound_frag` (SW:12487) under `hfrag`, where the sole interior positive `σ0`
collapses the non-interior class (O4 SW:6785-6791) and each LEFT/RIGHT branch is served by the
pin-anchored gate producers `kvE2_sepGateAtPin_fragL`/`_fragR`.

What remains for 335 to discharge at `charK := fun χ => P.existF 0 χ`:
- `hcorrK` — the provider correctness bridge `(⟨charK (nfk_projFresh σ)⟩).eval_at M atomMap a →
  nf_eval_nf M 1 1 (fun _ => a) (nfk_projFresh σ)`. Discharged HERE inline from the Phase-2 provider
  bridge `bracketEndChar_kvE2_hck` (`.mp`; `TemporalPred.eval_at` unfolds to `temporal_truth`).
- `hexcl` — the negative-sub exclusion family. Threaded as a hypothesis here (the Phase C GO/NO-GO
  probe proves it under `hfrag`; Phase D removes it from the assembled gate).

The fragment hypothesis `hfrag : kvE2_sepFragment qnf` is definitionally the fold's
`kvE2_sepFragment_frag qnf` (identical body, SW:10219); the six order bits unify defeq
`qnf.atom_assgn = qnf.1` at depth 2 (`NormalForm.atom_assgn` `_ + 1` case). No `SharedWitness.lean`
edit — the fold and its kit are verified INPUTS, applied not re-proved (341 frozen-file gate intact).
Rabinovich cited by PDF page: the symmetric gate is Cor 5.4 (task 345); the depth-2 assembly follows
Def 3.1 (p.4) and the §5 bracket assembly (pp.7-9). -/

/-- **⇒ soundness half of the k=2 fragment gate** (task 335 v5 Phase B). Consumes the pin-anchored
    symmetric-gate fold `kvE2_outer_fold_frag` (SW:12529). `hcorrK` is discharged inline from the
    provider bridge `bracketEndChar_kvE2_hck` (`.mp`); `hfrag` is the qnf-domain restriction task
    321-N2 sanctions; `hexcl` (negative-sub exclusion) is threaded as a hypothesis, proved by the
    Phase C probe and removed at Phase D assembly. No `SharedWitness.lean` edit.

    VACUITY NOTE (task 335 report 07, 2026-07-11 — DO NOT CONSUME, pending successor verification):
    the `hfrag` hypothesis (see the VACUITY NOTE on `kvE2_sepFragment` above) is flagged
    unrealizable for any realized `qnf`, making this theorem's premise set unsatisfiable and the
    theorem vacuous AS STATED. The derivation itself (fold application, `hcorrK` discharge) is a
    genuine proof from its hypotheses and is expected to survive a fragment-predicate repair
    (interior-singleton via `kvE2_sepPosI`), but task 309 / `KampPrior.lean:351` MUST NOT consume
    this statement before the 321-N2 successor carrier task re-grounds it. Phase C additionally
    machine-confirmed `hexcl` is NOT dischargeable under any fold-interface enrichment
    (reports/07, two independent refutations incl. `bracketEndChar_kv_factors`). -/
theorem bracketEndChar_kvE2_sound_two_prior_frag {sig : MonadicSignature}
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
    (x t : M.carrier)
    (hfrag : kvE2_sepFragment qnf)
    (hexcl : ∀ w : M.carrier, x < w → w < t →
      (kvE2_sepPtW (nf_depth0_char_formula atomMap h_surj) (fun χ => P.existF 0 χ) qnf).eval_at
        M atomMap w →
      ∀ σ : NormalForm sig 1 4, qnf.2 σ = false →
        ∀ x1 : M.carrier,
          ¬ nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    (bracketEndChar_kvE2 atomMap h_surj P qnf).holds M atomMap x t →
      ∃ w : M.carrier, nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf := by
  intro h_holds
  rw [bracketEndChar_kvE2_two_eq] at h_holds
  exact kvE2_outer_fold_frag atomMap h_surj (fun χ => P.existF 0 χ) qnf
    h_xy h_yt h_xt h_yx h_ty h_tx M x t h_holds hfrag
    (fun σ a hσa => (bracketEndChar_kvE2_hck atomMap P M h_UZ h_SZ (nfk_projFresh σ) a).mp hσa)
    hexcl


end Bimodal.Metalogic.WeakCanonical.Kamp
