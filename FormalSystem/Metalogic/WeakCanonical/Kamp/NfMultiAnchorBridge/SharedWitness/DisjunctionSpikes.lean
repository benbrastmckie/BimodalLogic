/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness.Soundness

/-! # Shared-Interior-Witness Joint Carrier — per-order-type validity

Module G of the `SharedWitness` tower. Per-order-type validity — each disjunct reads the
fold bit appropriate to ITS arrangement: strict disjuncts consume σ's OPEN `zXU`/`zUW`
bits, the coincidence disjunct σ's CLOSED `zAtX1L` bit (Rabinovich Lemma 3.2(1), PDF p.3;
§5 meet-typed shared point, PDF p.5) — plus `kvE2_sepProjFresh_eval` and the
disjunction-spike machinery. -/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.WeakCanonical.Separation
  (nfDepth0CharFormula nf_depth0_char_formula_correct
   formulaConjList formula_conjList_iff)

-- NOTE: `KvE2SepSpikeOrderType` and `kvE2SepSpikeOrderTypes` were RELOCATED
-- above the carrier (`## Order-type-disjunction index (RELOCATED above the carrier)`), so
-- `kvE2SepBody`
-- can reference `kvE2SepArr'`. The Phase-1 spike theorems below still consume them.

/-- **Per-order-type validity** (the faithful replacement of the additive `kvE2_sepValid`): each
    disjunct reads the fold bit appropriate to ITS arrangement. Strict disjuncts consume σ's OPEN
    `zXU`/`zUW` bits (the surviving compat-leaf reads, `kvE2_sepCompat_lX1_eq`/`_after_eq`);
    the coincidence disjunct consumes σ's CLOSED `zAtX1L` bit fed by
    `kvE2_sepCoincidentAnchor_discharge` (the §5 meet channel). No disjunct conflates open and
    closed keys — the crux the additive filter structurally could not express (handoff 05). -/
def kvE2SepSpikeDisjValid {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) (χ : NormalForm sig 0 1) :
    KvE2SepSpikeOrderType → Bool
  | .strictBefore => kvE2SepBits σ kvESub2ZXU χ
  | .strictAfter  => kvE2SepBits σ kvESub2ZUW χ
  | .coincident   => kvE2SepBits σ kvE2SepZAtX1L χ

/-- The filtered valid order-type disjuncts (the faithful analog of `kvE2_sepArrL`, per-order-type
    rather than an additive filter over a flat slot union). -/
def kvE2SepSpikeArr {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) (χ : NormalForm sig 0 1) : List KvE2SepSpikeOrderType :=
  kvE2SepSpikeOrderTypes.filter (kvE2SepSpikeDisjValid σ χ)

/-- **CONTRAST — the plan-02 RED baseline.** The additive OPEN-zone-only filter (reading solely
    the `zXU`/`zUW` bits, never the closed one) is EMPTY on the exact handoff-05 scenario. This is
    precisely the obligation `kvE2_sepBody_nonvacuous` made FALSE: no strict disjunct survives when
    the coincidence forces both open bits to `false`. -/
theorem kvE2_sepSpike_additiveOpenOnly_vacuous {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) (χ : NormalForm sig 0 1)
    (hzXU : kvE2SepBits σ kvESub2ZXU χ = false)
    (hzUW : kvE2SepBits σ kvESub2ZUW χ = false) :
    ([KvE2SepSpikeOrderType.strictBefore, KvE2SepSpikeOrderType.strictAfter].filter
      (kvE2SepSpikeDisjValid σ χ)) = [] := by
  have h1 : kvE2SepSpikeDisjValid σ χ KvE2SepSpikeOrderType.strictBefore = false := hzXU
  have h2 : kvE2SepSpikeDisjValid σ χ KvE2SepSpikeOrderType.strictAfter = false := hzUW
  simp [h1, h2]

/-- **MAKE-OR-BREAK SPIKE.** On the exact 2-owner coincidence the additive
    filter made FALSE (handoff 05) — σ a left-interior owner realized at `[x1,w,x,t]` with the
    foreign owner τ's base type `χ` realized AT σ's fresh anchor `x1` and NO χ-witness strictly in
    `(x,x1)` or `(x1,w)` (so σ's OPEN bits are `false`) — the faithful order-type-disjunction
    filter is NON-VACUOUS: the coincidence disjunct is admitted via the CLOSED `zAtX1L` bit fed by
    the preserved, axiom-clean `kvE2_sepCoincidentAnchor_discharge`.

    This proves the faithful architecture COMPOSES on the make-or-break obligation: the closed
    channel ROUTES into per-order-type validity (Lemma 3.2(1) coincidence disjunct, PDF p.3;
    §5 meet-type, PDF p.6), where the additive open-only filter could not (type-mismatch,
    handoff 05). Faithfulness invariants exercised: F2 (non-vacuity, coincidence direction),
    F5 (closed vs open key discrimination — the crux), F1 (QF types via the preserved brick). -/
theorem kvE2_sepSpike_twoOwner_coincidence_nonvacuous {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) (M : OrderedMonadicStructure sig)
    (x1 w x t : M.carrier) (hxx1 : x < x1) (hx1w : x1 < w) (hwt : w < t)
    (hσ : NfEvalNf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (χ : NormalForm sig 0 1)
    (hp : NfEvalNf M 0 1 (fun _ => x1) χ)
    -- The handoff-05 OPEN-zone FALSE pins (no χ-witness strictly in `(x,x1)` or `(x1,w)`); kept as
    -- scenario fidelity — non-vacuity of the FULL faithful arr needs only the coincidence disjunct,
    -- while `kvE2_sepSpike_additiveOpenOnly_vacuous` shows these make the open-only filter empty.
    (_hzXU : kvE2SepBits σ kvESub2ZXU χ = false)
    (_hzUW : kvE2SepBits σ kvESub2ZUW χ = false) :
    kvE2SepSpikeArr σ χ ≠ [] := by
  -- The CLOSED-zone bit is discharged TRUE by the preserved axiom-clean coincidence brick.
  have hclosed : kvE2SepBits σ kvE2SepZAtX1L χ = true :=
    kvE2_sepCoincidentAnchor_discharge σ M x1 w x t hxx1 hx1w hwt hσ χ hp
  -- The coincidence disjunct is therefore VALID and present in the filtered order-type list,
  -- so the faithful arrangement set is non-empty — the exact obligation the additive filter failed.
  apply List.ne_nil_of_mem (a := KvE2SepSpikeOrderType.coincident)
  unfold kvE2SepSpikeArr
  rw [List.mem_filter]
  refine ⟨by decide, ?_⟩
  simpa [kvE2SepSpikeDisjValid] using hclosed

-- NOTE: the Phase-2 order-type index cluster (KvE2SepWeakOrder,
-- kvE2SepOrderTypes, kvE2SepModelTag/Order, kvE2SepClosedLeafStub, kvE2SepDisjValidOwner,
-- kvE2SepDisjValid, kvE2SepArr', kvE2SepArr'Decidable, kvE2_sepModelOrder_mem_*,
-- kvE2_sepArr'_mem_modelOrder) was RELOCATED above the carrier so kvE2SepBody can enumerate
-- kvE2SepArr'. See "## Order-type-disjunction index (RELOCATED above the carrier)".

/-! ## Closed-zone compat leaf + three-way segment-meet cut (LEFT)

The 5th, closed-zone compat leaf (`kvE2_sepCompat_zAtX1L_eq`) re-hosts the Phase-2 forward stub
`kvE2SepClosedLeafStub` (which read σ's OWN fresh type `nf0ProjFresh σ.1`) over a FOREIGN owner's
base type `χ`: at a coincidence tie the disjunct's closed-zone validity is discharged TRUE by the
preserved axiom-clean `kvE2_sepCoincidentAnchor_discharge` (§5 meet channel, PDF p.6). The
three-way segment cut (`kvE2SepSegLForSub'`) supersedes the binary before/after cut
`kvE2SepSegLForSub` (`:561`) with a before/**at**/after cut whose "at" case sets the LEFT-interior
segment type to the MEET `A_i^- ∧ A_i^+` (the §5 splitting `A_i = A_i^- ∧ A_i^+`, PDF p.6) — the
conjunction of σ's `(x,x1)` before-exclusion (`kvESub2ZXU`) and `(x1,w)` after-exclusion
(`kvESub2ZUW`), i.e. universal β over the whole shared interval around the closed anchor.

Faithfulness invariants exercised: **F2** (meet, not vacuity — the "at" case discriminates via a
genuine two-sided exclusion, never `Formula.top`), **F5** (the coincidence disjunct reads the CLOSED
`zAtX1L` key; strict disjuncts read the OPEN `zXU`/`zUW` keys — never conflated), **F1** (the meet
type is quantifier-free over Σ — a `Formula.and` of two `charBase`-fold segment forms), **F6** (the
per-bracket F-chain is unaffected — this is a per-owner segment contribution, combined ABOVE the
chain by the cross-owner `kvE2SepPos`-map conjunction in `kvE2SepSegLAt`).

The binary `kvE2SepSegLForSub` is left in place (additive build; its removal/rewiring is Phase 6);
the two LEFT compat leaves `kvE2_sepCompat_lX1_eq`/`kvE2_sepCompat_lX1_after_eq` survive unchanged
as
the strict-disjunct validators (see the survival note below). -/

/-- **5th closed-zone compat leaf** (Phase 4, re-host of `kvE2SepClosedLeafStub` over foreign base
    types). At a coincidence tie — a foreign owner's base type `χ` realized AT σ's fresh anchor `x1`
    (`NfEvalNf M 0 1 (fun _ => x1) χ`) under `x < x1 < w < t` — the coincidence disjunct's
    validity `kvE2SepSpikeDisjValid σ χ .coincident` is TRUE, discharged by the preserved
    axiom-clean `kvE2_sepCoincidentAnchor_discharge`. Definitionally the disjunct read is
    `kvE2SepBits σ kvE2SepZAtX1L χ` (the CLOSED self-zone key, F5), so this leaf establishes the
    §5 meet-typed shared point (PDF p.6) over a FOREIGN owner's type — the generalization of the
    stub's own-type read `kvE2SepBits σ kvE2SepZAtX1L (nf0ProjFresh σ.1)`. F2 (meet, not
    vacuity): the tie is a first-class DISCHARGED disjunct, never a refuted inequality. -/
theorem kvE2_sepCompat_zAtX1L_eq {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) (M : OrderedMonadicStructure sig)
    (x1 w x t : M.carrier) (hxx1 : x < x1) (hx1w : x1 < w) (hwt : w < t)
    (hσ : NfEvalNf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (χ : NormalForm sig 0 1)
    (hp : NfEvalNf M 0 1 (fun _ => x1) χ) :
    kvE2SepSpikeDisjValid σ χ KvE2SepSpikeOrderType.coincident = true := by
  -- The disjunct read `kvE2SepSpikeDisjValid σ χ .coincident` is definitionally the CLOSED
  -- `zAtX1L` bit; the preserved brick discharges it TRUE for the foreign type `χ` at the tie.
  change kvE2SepBits σ kvE2SepZAtX1L χ = true
  exact kvE2_sepCoincidentAnchor_discharge σ M x1 w x t hxx1 hx1w hwt hσ χ hp

/-- **Three-way LEFT segment cut** (Phase 4, supersedes the binary `kvE2SepSegLForSub`, `:561`).
    σ's exclusion contribution to a LEFT-region refined sub-interval, keyed by σ's placement tag on
    the merged anchor set (the order-type disjunct). Branches on `nf0ZoneSpec σ.1`:
    * a LEFT-interior owner (`zXW3`, `x < x1_σ < w`) gets the three-way before/**at**/after cut:
      - `strictBefore` → LEFT β: the `(x, x1)` before-exclusion `kvESub2ZXU`;
      - `coincident`   → the **MEET** `A_i^- ∧ A_i^+` (§5 splitting, PDF p.6): `Formula.and` of the
        `(x,x1)` and `(x1,w)` exclusions — universal β over the whole shared interval, the closed
        anchor's two-sided content (F1 QF meet, F2 non-vacuous);
      - `strictAfter`  → RIGHT β: the `(x1, w)` after-exclusion `kvESub2ZUW`;
    * a RIGHT-interior owner (`zWT3`) contributes its uniform `(x,w)` exclusion (`kvESub2ZXU`),
      as in the binary cut — no tie on the left region for a right-interior owner;
    * a non-interior σ contributes `Formula.top` (its content rides its endpoint literal).
    Additive: the binary `kvE2SepSegLForSub` is retained; Phase 6 rewires the assembly onto
    this. -/
noncomputable def kvE2SepSegLForSub' {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (σ : NormalForm sig 1 4) (tag : KvE2SepSpikeOrderType) : Formula :=
  if nf0ZoneSpec σ.1 = kvE2SepZXW3 then
    match tag with
    | .strictBefore => kvE2SepSegForm charBase σ kvESub2ZXU
    | .coincident   =>
        Formula.and (kvE2SepSegForm charBase σ kvESub2ZXU)
          (kvE2SepSegForm charBase σ kvESub2ZUW)
    | .strictAfter  => kvE2SepSegForm charBase σ kvESub2ZUW
  else if nf0ZoneSpec σ.1 = kvE2SepZWT3 then
    kvE2SepSegForm charBase σ kvESub2ZXU
  else Formula.top

/-- **"At"-case soundness** (Phase 4, Risk R2 core content). For a LEFT-interior owner σ
    (`nf0ZoneSpec σ.1 = kvE2SepZXW3`), the coincidence ("at") case of the three-way cut IS the
    §5 meet `A_i = A_i^- ∧ A_i^+` (PDF p.6): the `Formula.and` of σ's `(x,x1)` before-exclusion and
    `(x1,w)` after-exclusion. This is the faithful universal-β-over-the-shared-interval type — σ
    excludes every foreign χ it excludes on EITHER open sub-interval, i.e. over the whole interval
    `(x,w) ∖ {x1}` around the closed anchor. Sound (not vacuity, F2): the meet is a genuine
    two-sided `charBase`-fold conjunction, never `Formula.top`; QF (F1). Axiom-clean (definitional
    reduction — no `sorryAx`). -/
theorem kvE2_sepSegLForSub'_at_sound {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (σ : NormalForm sig 1 4) (hzone : nf0ZoneSpec σ.1 = kvE2SepZXW3) :
    kvE2SepSegLForSub' charBase σ KvE2SepSpikeOrderType.coincident
      = Formula.and (kvE2SepSegForm charBase σ kvESub2ZXU)
          (kvE2SepSegForm charBase σ kvESub2ZUW) := by
  simp only [kvE2SepSegLForSub', hzone, if_pos]

/-! ## Three-way segment-meet cut (RIGHT)

The RIGHT mirror of Phase 4. The §5 splitting `A_i = A_i^- ∧ A_i^+` (PDF p.6) with the right
sub-interval `A_i^+(z,z_1)` (PDF p.6) is realized on the RIGHT region: the tie now belongs to a
RIGHT-interior owner (`zWT3`, `w < x1_σ < t`), whose two open sub-intervals are the `(w, x1)`
before-exclusion (`kvE2SepZWX1`) and the `(x1, t)` after-exclusion (`kvESub2ZWT`). The three-way
before/**at**/after cut sets the "at" (coincidence) case to the MEET of those two, i.e. universal β
over the whole shared interval `(w,t) ∖ {x1}` around the closed anchor. A LEFT-interior owner
(`zXW3`) on the RIGHT region contributes its uniform `(w,t)` exclusion (`kvESub2ZWT`), exactly as
in the binary cut `kvE2SepSegRForSub` (`:574`) — no tie on the right region for a left-interior
owner.

Compat-leaf survival audit:
  * All FOUR strict-disjunct compat leaves SURVIVE unchanged, re-hosted as strict-disjunct
    validators (their statements are untouched; only their ROLE changed from bits of the abandoned
    additive filter to per-order-type strict validators):
      - `kvE2_sepCompat_lX1_eq`        (:409) — LEFT `strictBefore`, open key `kvESub2ZXU`;
      - `kvE2_sepCompat_lX1_after_eq`  (:422) — LEFT `strictAfter`,  open key `kvESub2ZUW`;
      - `kvE2_sepCompat_rX1_eq`        (:434) — RIGHT `strictBefore`, open key `kvE2SepZWX1`;
      - `kvE2_sepCompat_rX1_after_eq`  (:446) — RIGHT `strictAfter`,  open key `kvESub2ZWT`.
    NONE is replaced.
  * ONE new closed-zone leaf was ADDED in Phase 4: `kvE2_sepCompat_zAtX1L_eq` (:2505), reading the
    CLOSED `zAtX1L` key; it serves the coincidence disjunct on BOTH sides (the closed anchor
    `x1_σ` is the same §5 meet-typed shared point whether σ is left- or right-interior), so no
    separate right-side closed leaf is needed.

Faithfulness invariants exercised: **F2** (the "at" case is the genuine two-sided meet, never
`Formula.top` — no weakening to vacuity), **F5** (the coincidence disjunct reads the CLOSED
`zAtX1L` key via `kvE2_sepCompat_zAtX1L_eq`; the strict disjuncts read the OPEN `zWX1`/`zWT` keys —
never conflated), **F1** (the meet type is quantifier-free over Σ — a `Formula.and` of two
`charBase`-fold segment forms), **F6** (per-bracket F-chain unaffected — a per-owner segment
contribution combined ABOVE the chain).

The binary `kvE2SepSegRForSub` is left in place (additive build; its removal/rewiring is Phase
6). -/

/-- **Three-way RIGHT segment cut** (Phase 5, supersedes the binary `kvE2SepSegRForSub`, `:574`).
    σ's exclusion contribution to a RIGHT-region refined sub-interval, keyed by σ's placement tag on
    the merged anchor set (the order-type disjunct). Branches on `nf0ZoneSpec σ.1`:
    * a LEFT-interior owner (`zXW3`) contributes its uniform `(w,t)` exclusion (`kvESub2ZWT`),
      as in the binary cut — no tie on the right region for a left-interior owner;
    * a RIGHT-interior owner (`zWT3`, `w < x1_σ < t`) gets the three-way before/**at**/after cut:
      - `strictBefore` → the `(w, x1)` before-exclusion `kvE2SepZWX1`;
      - `coincident`   → the **MEET** `A_i^- ∧ A_i^+` (§5 splitting, PDF p.6; right sub-interval
        `A_i^+(z,z_1)`, PDF p.6): `Formula.and` of the `(w,x1)` and `(x1,t)` exclusions — universal
        β over the whole shared interval, the closed anchor's two-sided content (F1 QF meet, F2
        non-vacuous);
      - `strictAfter`  → the `(x1, t)` after-exclusion `kvESub2ZWT`;
    * a non-interior σ contributes `Formula.top` (its content rides its endpoint literal).
    Additive: the binary `kvE2SepSegRForSub` is retained; Phase 6 rewires the assembly onto
    this. -/
noncomputable def kvE2SepSegRForSub' {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (σ : NormalForm sig 1 4) (tag : KvE2SepSpikeOrderType) : Formula :=
  if nf0ZoneSpec σ.1 = kvE2SepZXW3 then
    kvE2SepSegForm charBase σ kvESub2ZWT
  else if nf0ZoneSpec σ.1 = kvE2SepZWT3 then
    match tag with
    | .strictBefore => kvE2SepSegForm charBase σ kvE2SepZWX1
    | .coincident   =>
        Formula.and (kvE2SepSegForm charBase σ kvE2SepZWX1)
          (kvE2SepSegForm charBase σ kvESub2ZWT)
    | .strictAfter  => kvE2SepSegForm charBase σ kvESub2ZWT
  else Formula.top

/-- **"At"-case soundness** (Phase 5, Risk R2 core content — RIGHT mirror of
    `kvE2_sepSegLForSub'_at_sound`). For a RIGHT-interior owner σ
    (`nf0ZoneSpec σ.1 = kvE2SepZWT3`), the coincidence ("at") case of the three-way cut IS the
    §5 meet `A_i = A_i^- ∧ A_i^+` (PDF p.6; right sub-interval `A_i^+(z,z_1)`, PDF p.6): the
    `Formula.and` of σ's `(w,x1)` before-exclusion (`kvE2SepZWX1`) and `(x1,t)` after-exclusion
    (`kvESub2ZWT`). This is the faithful universal-β-over-the-shared-interval type — σ excludes
    every foreign χ it excludes on EITHER open sub-interval, i.e. over the whole interval
    `(w,t) ∖ {x1}` around the closed anchor. Sound (not vacuity, F2): the meet is a genuine
    two-sided `charBase`-fold conjunction, never `Formula.top`; QF (F1). Axiom-clean (definitional
    reduction — no `sorryAx`). -/
theorem kvE2_sepSegRForSub'_at_sound {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (σ : NormalForm sig 1 4) (hzone : nf0ZoneSpec σ.1 = kvE2SepZWT3) :
    kvE2SepSegRForSub' charBase σ KvE2SepSpikeOrderType.coincident
      = Formula.and (kvE2SepSegForm charBase σ kvE2SepZWX1)
          (kvE2SepSegForm charBase σ kvESub2ZWT) := by
  unfold kvE2SepSegRForSub'
  rw [if_neg (fun h => kvE2_sep_zWT3_ne_zXW3 (hzone.symm.trans h)), if_pos hzone]

/-! ## Lemma 3.2(1) ⇒ (soundness) over the order-type disjunction

The ⇒ half of Lemma 3.2(1) (PDF p.3): a HELD (selected) order-type disjunct implies the joint
conjunction — i.e. every per-owner placement in the held weak order is admitted by that owner's
arrangement-appropriate zone bit (F2, ⇒ realized, not vacuity). Each disjunct reads the bit
appropriate to ITS arrangement: a strict placement reads σ's OPEN `zXU`/`zUW` bit (via the surviving
compat leaves, and its segment content is the binary before/after cut refined by the
three-way `kvE2SepSegLForSub'`/`kvE2SepSegRForSub'` at the meet, Phases 4/5); the coincidence
placement reads σ's CLOSED `zAtX1L` bit (the §5 meet channel discharged by the axiom-clean
`kvE2_sepCoincidentAnchor_discharge`; re-hosted as `kvE2_sepCompat_zAtX1L_eq`, PDF p.6). No
disjunct conflates open and closed keys (F5). -/

/-- **Lemma 3.2(1) ⇒ (soundness), order-type level**: a valid disjunct
    `wo ∈ kvE2SepArr' qnf` carries the JOINT conjunction of its per-owner arrangement bits — every
    placement `(σ, tag)` in the held weak order is admitted by `kvE2SepDisjValidOwner σ tag`
    (`= true`). This is the ⇒ half of Lemma 3.2(1) (PDF p.3) at the per-order-type validity level: a
    HELD disjunct (one consistent arrangement) implies the conjunction of the zone-bit conditions
    its arrangement selects — strict placements the OPEN `zXU`/`zUW` bits, the coincidence placement
    the CLOSED `zAtX1L` bit (F5), never vacuously (F2). The realized segment/point content of each
    held disjunct is supplied by `kvE2_sepBody_extract` (the O3 bundle) and the three-way meet cuts
    (`kvE2_sepSegLForSub'_at_sound`/`kvE2_sepSegRForSub'_at_sound`). -/
theorem kvE2_sepArr'_sound {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) {wo : KvE2SepWeakOrder sig}
    (hwo : wo ∈ kvE2SepArr' qnf) :
    (∀ p ∈ wo, kvE2SepDisjValidOwner p.1 p.2.1 = true) ∧
      kvE2SepAnchorDistinct wo = true ∧ kvE2SepTieRead wo = true := by
  have hv : kvE2SepDisjValid qnf wo = true := (List.mem_filter.mp hwo).2
  rw [kvE2SepDisjValid, Bool.and_eq_true, Bool.and_eq_true, Bool.and_eq_true] at hv
  obtain ⟨⟨⟨hall, _hcons⟩, hanch⟩, htie⟩ := hv
  exact ⟨fun p hp => (List.all_eq_true.mp hall) p hp, hanch, htie⟩

/-! ## Honest non-interior evaluation pack

The endpoint/pivot honesty lemmas: from an honest evaluation `h`, the EXISTING literal
conjunctions `kvE2SepEpL`/`kvE2SepPtW`/`kvE2SepEpR` evaluate at their fixed points
`x`/`w`/`t`. These are the obligations previously hidden behind `hLR`'s vacuity
(`kvE2_sepHonest_hLR_absurd`): every honest `qnf` has positive owners in non-interior
classes, and their content rides the endpoint/pivot literals — never the interleaving.
Grounding: Rabinovich §5 (p.7) — the ψ0/ψ1/φ split routes non-interior positive witnesses
to atomic E[Σ] endpoint literals via Prop 3.5 (pp.5,7); this section realizes exactly that
routing in Lean. NO new literal machinery: every case below discharges an EXISTING literal
family of the Part-I predicates. The char-semantics hypotheses `hcb`/`hck`
are the abstract form of the concrete `nfDepth0CharFormula` correctness
(`nfPred_correct`) that the k1v template consumed (`CarrierK1V.lean:1672`). Witness bounds
come from realized zone membership (the arity-4 zoneHolds cons-iff helper,
`SubBracket2.lean:538`) and the honest realization's own order channel — never a chain
(LITMUS). -/

/-- Bool bridge: an order iff against `b = true` computes the `decide`. -/
private theorem kvE2_sep_decide_eq_of_iff {p : Prop} [Decidable p] {b : Bool}
    (h : p ↔ b = true) : decide p = b := by
  cases b with
  | true => exact decide_eq_true (h.mpr rfl)
  | false => exact decide_eq_false (fun hp => Bool.noConfusion (h.mp hp))

/-- Prefix-restriction evaluation (depth 0): a realized arity-`n` depth-0 NF restricts to
    a realized arity-`m` NF along `Fin.castLE` (the `nfkTake` atom channel is exactly the
    cast-atom read). -/
private theorem kvE2_sep_nfk_take_eval {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) {m n : Nat} (hmn : m ≤ n)
    (env : Fin n → M.carrier) (sub : NormalForm sig 0 n)
    (hs : NfEvalNf M 0 n env sub) :
    NfEvalNf M 0 m (fun i => env (Fin.castLE hmn i)) (nfkTake hmn sub) := by
  intro a
  match a with
  | .pred p i => exact hs (.pred p (Fin.castLE hmn i))
  | .order i j hne =>
    exact hs (.order (Fin.castLE hmn i) (Fin.castLE hmn j)
      (fun he => hne (Fin.castLE_injective hmn he)))

/-- **Depth-1 fresh-projection factor**): a realized depth-1 owner
    factors through its fresh depth-1 arity-1 projection at the witness point — the depth-1
    analog of `nf_eval_nf0_cons_factor`'s monadic channel (Def 4.1, PDF p.5: the E[Σ]-atom
    channel read at depth 1). The quant layer transports through `nfCharacteristic` +
    `nf_eval_unique` (NormalForm.lean:215/245) and the prefix restriction. -/
theorem kvE2_sepProjFresh_eval {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) {n : Nat}
    (env : Fin n → M.carrier) (v : M.carrier)
    (σ : NormalForm sig 1 (n + 1))
    (hσ : NfEvalNf M 1 (n + 1) (Fin.cons v env) σ) :
    NfEvalNf M 1 1 (fun _ => v) (nfkProjFresh σ) := by
  have henv : ∀ u : M.carrier,
      (fun i => (Fin.cons u (Fin.cons v env) : Fin (n + 2) → M.carrier)
        (Fin.castLE (Nat.succ_le_succ (Nat.succ_le_succ (Nat.zero_le n))) i))
      = (Fin.cons u (fun _ => v) : Fin 2 → M.carrier) := by
    intro u
    funext i
    match i with
    | ⟨0, _⟩ => rfl
    | ⟨1, _⟩ => rfl
  refine ⟨?_, ?_⟩
  · -- Atom layer: the fresh predicate channel (arity-1 order atoms are uninhabited).
    intro a
    match a with
    | .pred p i =>
      have hi : i = 0 := Subsingleton.elim i 0
      subst hi
      exact hσ.1 (.pred p 0)
    | .order i j hne => exact absurd (Subsingleton.elim i j) hne
  · -- Quant layer: characteristic + uniqueness transport along the prefix restriction.
    intro sub
    simp only [decide_eq_true_eq]
    constructor
    · rintro ⟨u, hu⟩
      have hchar := nf_characteristic_satisfies M 0 (n + 2) (Fin.cons u (Fin.cons v env))
      have hbit : σ.2 (nfCharacteristic M 0 (n + 2) (Fin.cons u (Fin.cons v env))) = true :=
        (hσ.2 _).mp ⟨u, hchar⟩
      have htake := kvE2_sep_nfk_take_eval M
        (Nat.succ_le_succ (Nat.succ_le_succ (Nat.zero_le n)))
        (Fin.cons u (Fin.cons v env)) _ hchar
      rw [henv u] at htake
      exact ⟨_, hbit, nf_eval_unique M 0 2 (Fin.cons u (fun _ => v)) _ _ htake hu⟩
    · rintro ⟨sub', hbit, rfl⟩
      obtain ⟨u, hu⟩ := (hσ.2 sub').mpr hbit
      have htake := kvE2_sep_nfk_take_eval M
        (Nat.succ_le_succ (Nat.succ_le_succ (Nat.zero_le n)))
        (Fin.cons u (Fin.cons v env)) sub' hu
      rw [henv u] at htake
      exact ⟨u, htake⟩

/-- Characteristic-type zone computation: the depth-1 arity-4 characteristic of the env
    `[v, w, x, t]` has fresh ordering channel given coordinatewise by the decidable order
    facts of `v` against `[w, x, t]` (Def 3.1 ordering channel, PDF p.4). -/
private theorem kvE2_sepCharZone3 {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (v w x t : M.carrier)
    (p0 p1 p2 : Bool × Bool)
    (h0l : (v < w) ↔ p0.1 = true) (h0r : (w < v) ↔ p0.2 = true)
    (h1l : (v < x) ↔ p1.1 = true) (h1r : (x < v) ↔ p1.2 = true)
    (h2l : (v < t) ↔ p2.1 = true) (h2r : (t < v) ↔ p2.2 = true) :
    nf0ZoneSpec (nfCharacteristic M 1 4
        (Fin.cons v (Fin.cons w (Fin.cons x (fun _ => t))))).1
      = (Fin.cons p0 (Fin.cons p1 (fun _ => p2)) : ZoneSpec 3) := by
  have hco : ∀ (i : Fin 3) (pi : Bool × Bool),
      ((v < (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) i) ↔ pi.1 = true) →
      (((Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) i < v) ↔ pi.2 = true) →
      nf0ZoneSpec (nfCharacteristic M 1 4
          (Fin.cons v (Fin.cons w (Fin.cons x (fun _ => t))))).1 i = pi := by
    intro i pi hl hr
    refine Prod.ext (@kvE2_sep_decide_eq_of_iff _ (Classical.dec _) _ ?_)
      (@kvE2_sep_decide_eq_of_iff _ (Classical.dec _) _ ?_)
    · simpa only [AtomEval, Fin.cons_zero, Fin.cons_succ] using hl
    · simpa only [AtomEval, Fin.cons_zero, Fin.cons_succ] using hr
  funext i
  match i with
  | ⟨0, hlt⟩ => exact hco ⟨0, hlt⟩ p0 h0l h0r
  | ⟨1, hlt⟩ => exact hco ⟨1, hlt⟩ p1 h1l h1r
  | ⟨2, hlt⟩ => exact hco ⟨2, hlt⟩ p2 h2l h2r

/-- Coordinate projection evaluation (arity 4): σ's depth-0 coordinate-`k` 1-type is
    realized at the env's `k`-th point (reads σ's realized atom layer only). -/
private theorem kvE2_sepProj4_eval {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (env : Fin 4 → M.carrier)
    (σ : NormalForm sig 1 4)
    (hσa : ∀ a : AtomKind sig 4, AtomEval M env a ↔ σ.1 a = true)
    (k : Fin 4) :
    NfEvalNf M 0 1 (fun _ => env k) (kvE2SepProj4 σ k) := by
  intro a
  match a with
  | .pred p i => exact hσa (.pred p k)
  | .order i j hne => exact absurd (Subsingleton.elim i j) hne

/-- Coordinate projection evaluation (arity 3, joint base): `qnf.1`'s coordinate-`k`
    1-type is realized at the env's `k`-th point. -/
private theorem kvE2_sepProj3_eval {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (env : Fin 3 → M.carrier)
    (r : NormalForm sig 0 3)
    (hr : ∀ a : AtomKind sig 3, AtomEval M env a ↔ r a = true)
    (k : Fin 3) :
    NfEvalNf M 0 1 (fun _ => env k) (kvE2SepProj3 r k) := by
  intro a
  match a with
  | .pred p i => exact hr (.pred p k)
  | .order i j hne => exact absurd (Subsingleton.elim i j) hne

/-- Ordering-channel fact (positive left bit): a realized owner's fresh witness sits
    BELOW env point `i` when its zone bit says so. -/
private theorem kvE2_sepZoneFact_lt {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (a w x t : M.carrier)
    (σ : NormalForm sig 1 4)
    (hσa : ∀ at4 : AtomKind sig 4,
      AtomEval M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) at4 ↔ σ.1 at4 = true)
    (i : Fin 3) (hbit : (nf0ZoneSpec σ.1 i).1 = true) :
    a < (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) i := by
  have h1 := hσa (.order 0 i.succ (Fin.succ_ne_zero i).symm)
  simp only [AtomEval, Fin.cons_zero, Fin.cons_succ] at h1
  exact h1.mpr hbit

/-- Ordering-channel fact (positive right bit): the fresh witness sits ABOVE env point
    `i`. -/
private theorem kvE2_sepZoneFact_gt {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (a w x t : M.carrier)
    (σ : NormalForm sig 1 4)
    (hσa : ∀ at4 : AtomKind sig 4,
      AtomEval M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) at4 ↔ σ.1 at4 = true)
    (i : Fin 3) (hbit : (nf0ZoneSpec σ.1 i).2 = true) :
    (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) i < a := by
  have h1 := hσa (.order i.succ 0 (Fin.succ_ne_zero i))
  simp only [AtomEval, Fin.cons_zero, Fin.cons_succ] at h1
  exact h1.mpr hbit

/-- Ordering-channel fact (negative left bit): the fresh witness is NOT below env point
    `i` (self-zone/boundary extraction seed). -/
private theorem kvE2_sepZoneFact_not_lt {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (a w x t : M.carrier)
    (σ : NormalForm sig 1 4)
    (hσa : ∀ at4 : AtomKind sig 4,
      AtomEval M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) at4 ↔ σ.1 at4 = true)
    (i : Fin 3) (hbit : (nf0ZoneSpec σ.1 i).1 = false) :
    ¬ a < (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) i := by
  have h1 := hσa (.order 0 i.succ (Fin.succ_ne_zero i).symm)
  simp only [AtomEval, Fin.cons_zero, Fin.cons_succ] at h1
  exact fun hc => Bool.noConfusion ((h1.mp hc).symm.trans hbit)

/-- Ordering-channel fact (negative right bit): the fresh witness is NOT above env point
    `i`. -/
private theorem kvE2_sepZoneFact_not_gt {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (a w x t : M.carrier)
    (σ : NormalForm sig 1 4)
    (hσa : ∀ at4 : AtomKind sig 4,
      AtomEval M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) at4 ↔ σ.1 at4 = true)
    (i : Fin 3) (hbit : (nf0ZoneSpec σ.1 i).2 = false) :
    ¬ (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) i < a := by
  have h1 := hσa (.order i.succ 0 (Fin.succ_ne_zero i))
  simp only [AtomEval, Fin.cons_zero, Fin.cons_succ] at h1
  exact fun hc => Bool.noConfusion ((h1.mp hc).symm.trans hbit)

/-- `kvE2SepHasPos` introduction from an honest realization: a point `s` realizing the
    depth-1 arity-1 type `χ` whose characteristic owner lands in outer class `zs` marks the
    class bit positive (the σ-level literal driver, completeness direction). -/
private theorem kvE2_sepHasPos_of_realized {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig)
    (w x t s : M.carrier)
    (h : NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (zs : ZoneSpec 3)
    (hzs : nf0ZoneSpec (nfCharacteristic M 1 4
        (Fin.cons s (Fin.cons w (Fin.cons x (fun _ => t))))).1 = zs)
    (χ : NormalForm sig 1 1)
    (hχ : NfEvalNf M 1 1 (fun _ => s) χ) :
    kvE2SepHasPos qnf zs χ = true := by
  have hreal := nf_characteristic_satisfies M 1 4
    (Fin.cons s (Fin.cons w (Fin.cons x (fun _ => t))))
  have hbit : qnf.2 (nfCharacteristic M 1 4
      (Fin.cons s (Fin.cons w (Fin.cons x (fun _ => t))))) = true :=
    (h.2 _).mp ⟨s, hreal⟩
  have hproj : nfkProjFresh (nfCharacteristic M 1 4
      (Fin.cons s (Fin.cons w (Fin.cons x (fun _ => t))))) = χ :=
    nf_eval_unique M 1 1 (fun _ => s) _ _
      (kvE2_sepProjFresh_eval M _ s _ hreal) hχ
  rw [kvE2SepHasPos, List.any_eq_true]
  refine ⟨_, ?_, decide_eq_true hproj⟩
  rw [kvE2SepPosIn, List.mem_filter]
  refine ⟨?_, decide_eq_true hzs⟩
  rw [kvE2SepPos, List.mem_filter]
  exact ⟨Finset.mem_toList.mpr (Finset.mem_univ _), hbit⟩

/-- `kvE2SepHasPos` elimination under an honest realization: a positive class bit yields
    a realized owner in that class whose fresh projection IS `χ`, realized at the owner's
    honest witness point. -/
private theorem kvE2_sepHasPos_witness {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig)
    (w x t : M.carrier)
    (h : NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (zs : ZoneSpec 3) (χ : NormalForm sig 1 1)
    (hb : kvE2SepHasPos qnf zs χ = true) :
    ∃ (σ : NormalForm sig 1 4) (s : M.carrier),
      nf0ZoneSpec σ.1 = zs ∧
      NfEvalNf M 1 4 (Fin.cons s (Fin.cons w (Fin.cons x (fun _ => t)))) σ ∧
      NfEvalNf M 1 1 (fun _ => s) χ := by
  rw [kvE2SepHasPos, List.any_eq_true] at hb
  obtain ⟨σ, hσmem, hproj⟩ := hb
  have hzone : nf0ZoneSpec σ.1 = zs :=
    of_decide_eq_true (List.mem_filter.mp hσmem).2
  have hbit : qnf.2 σ = true :=
    (List.mem_filter.mp (List.mem_filter.mp hσmem).1).2
  obtain ⟨s, hs⟩ := (h.2 σ).mpr hbit
  refine ⟨σ, s, hzone, hs, ?_⟩
  have hpf := kvE2_sepProjFresh_eval M _ s σ hs
  rwa [of_decide_eq_true hproj] at hpf

/-! ### σ-level (outer-class) literal honesty — the five `kvE2SepHasPos` families

Positive bits discharge by exhibiting the class owner's honest witness (the σ_w route of
`kvE2_sepHonest_hLR_absurd`, now an obligation instead of a contradiction); negative bits
discharge because a witness would force the class characteristic positive
(`kvE2_sepHasPos_of_realized`), contradicting the bit. Prop 3.5 (pp.5,7): `Since`/`Until`
navigation rides the fixed endpoint as evaluation point — LITMUS-clean. -/

/-- `zPastX3` Since-literal honesty at `x`. -/
private theorem kvE2_sepHasPosLit_zPastX3 {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      TemporalTruth M atomMap u (charK χ) ↔ NfEvalNf M 1 1 (fun _ => u) χ)
    (χ : NormalForm sig 1 1) :
    TemporalTruth M atomMap x
      (kvE2SepLit (kvE2SepHasPos qnf kvE2SepZPastX3 χ)
        (Formula.snce (charK χ) Formula.top)) := by
  cases hb : kvE2SepHasPos qnf kvE2SepZPastX3 χ with
  | true =>
    change TemporalTruth M atomMap x (Formula.snce (charK χ) Formula.top)
    obtain ⟨σ, s, hzone, hs, hχs⟩ := kvE2_sepHasPos_witness qnf M w x t h _ χ hb
    obtain ⟨hσ_atom, -, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
    have hsx := kvE2_sepZoneFact_lt M s w x t σ hσ_atom ⟨1, by omega⟩
      (by rw [congrFun hzone ⟨1, by omega⟩]; decide)
    exact ⟨s, hsx, (hck χ s).mpr hχs, fun r _ _ hf => hf⟩
  | false =>
    change TemporalTruth M atomMap x (Formula.snce (charK χ) Formula.top).neg
    rintro ⟨s, hsx, hsχ, -⟩
    have hz := kvE2_sepCharZone3 M s w x t (true, false) (true, false) (true, false)
      (iff_of_true (hsx.trans hxw) rfl)
      (iff_of_false (lt_asymm (hsx.trans hxw)) (by decide))
      (iff_of_true hsx rfl) (iff_of_false (lt_asymm hsx) (by decide))
      (iff_of_true (hsx.trans (hxw.trans hwt)) rfl)
      (iff_of_false (lt_asymm (hsx.trans (hxw.trans hwt))) (by decide))
    have hpos := kvE2_sepHasPos_of_realized qnf M w x t s h kvE2SepZPastX3 hz χ
      ((hck χ s).mp hsχ)
    rw [hb] at hpos
    exact Bool.noConfusion hpos

/-- `zAtX3` at-literal honesty at `x`. -/
private theorem kvE2_sepHasPosLit_zAtX3 {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      TemporalTruth M atomMap u (charK χ) ↔ NfEvalNf M 1 1 (fun _ => u) χ)
    (χ : NormalForm sig 1 1) :
    TemporalTruth M atomMap x
      (kvE2SepLit (kvE2SepHasPos qnf kvE2SepZAtX3 χ) (charK χ)) := by
  cases hb : kvE2SepHasPos qnf kvE2SepZAtX3 χ with
  | true =>
    change TemporalTruth M atomMap x (charK χ)
    obtain ⟨σ, s, hzone, hs, hχs⟩ := kvE2_sepHasPos_witness qnf M w x t h _ χ hb
    obtain ⟨hσ_atom, -, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
    have hnsx := kvE2_sepZoneFact_not_lt M s w x t σ hσ_atom ⟨1, by omega⟩
      (by rw [congrFun hzone ⟨1, by omega⟩]; decide)
    have hnxs := kvE2_sepZoneFact_not_gt M s w x t σ hσ_atom ⟨1, by omega⟩
      (by rw [congrFun hzone ⟨1, by omega⟩]; decide)
    have hseq : s = x := le_antisymm (not_lt.mp hnxs) (not_lt.mp hnsx)
    exact (hck χ x).mpr (hseq ▸ hχs)
  | false =>
    change TemporalTruth M atomMap x (charK χ).neg
    intro hch
    have hz := kvE2_sepCharZone3 M x w x t (true, false) (false, false) (true, false)
      (iff_of_true hxw rfl) (iff_of_false (lt_asymm hxw) (by decide))
      (iff_of_false (lt_irrefl x) (by decide)) (iff_of_false (lt_irrefl x) (by decide))
      (iff_of_true (hxw.trans hwt) rfl)
      (iff_of_false (lt_asymm (hxw.trans hwt)) (by decide))
    have hpos := kvE2_sepHasPos_of_realized qnf M w x t x h kvE2SepZAtX3 hz χ
      ((hck χ x).mp hch)
    rw [hb] at hpos
    exact Bool.noConfusion hpos

/-- `zAtW3` at-literal honesty at the shared pivot `w`. -/
private theorem kvE2_sepHasPosLit_zAtW3 {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      TemporalTruth M atomMap u (charK χ) ↔ NfEvalNf M 1 1 (fun _ => u) χ)
    (χ : NormalForm sig 1 1) :
    TemporalTruth M atomMap w
      (kvE2SepLit (kvE2SepHasPos qnf kvE2SepZAtW3 χ) (charK χ)) := by
  cases hb : kvE2SepHasPos qnf kvE2SepZAtW3 χ with
  | true =>
    change TemporalTruth M atomMap w (charK χ)
    obtain ⟨σ, s, hzone, hs, hχs⟩ := kvE2_sepHasPos_witness qnf M w x t h _ χ hb
    obtain ⟨hσ_atom, -, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
    have hnsw := kvE2_sepZoneFact_not_lt M s w x t σ hσ_atom ⟨0, by omega⟩
      (by rw [congrFun hzone ⟨0, by omega⟩]; decide)
    have hnws := kvE2_sepZoneFact_not_gt M s w x t σ hσ_atom ⟨0, by omega⟩
      (by rw [congrFun hzone ⟨0, by omega⟩]; decide)
    have hseq : s = w := le_antisymm (not_lt.mp hnws) (not_lt.mp hnsw)
    exact (hck χ w).mpr (hseq ▸ hχs)
  | false =>
    change TemporalTruth M atomMap w (charK χ).neg
    intro hch
    have hz := kvE2_sepCharZone3 M w w x t (false, false) (false, true) (true, false)
      (iff_of_false (lt_irrefl w) (by decide)) (iff_of_false (lt_irrefl w) (by decide))
      (iff_of_false (lt_asymm hxw) (by decide)) (iff_of_true hxw rfl)
      (iff_of_true hwt rfl) (iff_of_false (lt_asymm hwt) (by decide))
    have hpos := kvE2_sepHasPos_of_realized qnf M w x t w h kvE2SepZAtW3 hz χ
      ((hck χ w).mp hch)
    rw [hb] at hpos
    exact Bool.noConfusion hpos

/-- `zAtT3` at-literal honesty at `t`. -/
private theorem kvE2_sepHasPosLit_zAtT3 {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      TemporalTruth M atomMap u (charK χ) ↔ NfEvalNf M 1 1 (fun _ => u) χ)
    (χ : NormalForm sig 1 1) :
    TemporalTruth M atomMap t
      (kvE2SepLit (kvE2SepHasPos qnf kvE2SepZAtT3 χ) (charK χ)) := by
  cases hb : kvE2SepHasPos qnf kvE2SepZAtT3 χ with
  | true =>
    change TemporalTruth M atomMap t (charK χ)
    obtain ⟨σ, s, hzone, hs, hχs⟩ := kvE2_sepHasPos_witness qnf M w x t h _ χ hb
    obtain ⟨hσ_atom, -, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
    have hnst := kvE2_sepZoneFact_not_lt M s w x t σ hσ_atom ⟨2, by omega⟩
      (by rw [congrFun hzone ⟨2, by omega⟩]; decide)
    have hnts := kvE2_sepZoneFact_not_gt M s w x t σ hσ_atom ⟨2, by omega⟩
      (by rw [congrFun hzone ⟨2, by omega⟩]; decide)
    have hseq : s = t := le_antisymm (not_lt.mp hnts) (not_lt.mp hnst)
    exact (hck χ t).mpr (hseq ▸ hχs)
  | false =>
    change TemporalTruth M atomMap t (charK χ).neg
    intro hch
    have hz := kvE2_sepCharZone3 M t w x t (false, true) (false, true) (false, false)
      (iff_of_false (lt_asymm hwt) (by decide)) (iff_of_true hwt rfl)
      (iff_of_false (lt_asymm (hxw.trans hwt)) (by decide))
      (iff_of_true (hxw.trans hwt) rfl)
      (iff_of_false (lt_irrefl t) (by decide)) (iff_of_false (lt_irrefl t) (by decide))
    have hpos := kvE2_sepHasPos_of_realized qnf M w x t t h kvE2SepZAtT3 hz χ
      ((hck χ t).mp hch)
    rw [hb] at hpos
    exact Bool.noConfusion hpos

/-- `zFutT3` Until-literal honesty at `t`. -/
private theorem kvE2_sepHasPosLit_zFutT3 {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      TemporalTruth M atomMap u (charK χ) ↔ NfEvalNf M 1 1 (fun _ => u) χ)
    (χ : NormalForm sig 1 1) :
    TemporalTruth M atomMap t
      (kvE2SepLit (kvE2SepHasPos qnf kvE2SepZFutT3 χ)
        (Formula.untl (charK χ) Formula.top)) := by
  cases hb : kvE2SepHasPos qnf kvE2SepZFutT3 χ with
  | true =>
    change TemporalTruth M atomMap t (Formula.untl (charK χ) Formula.top)
    obtain ⟨σ, s, hzone, hs, hχs⟩ := kvE2_sepHasPos_witness qnf M w x t h _ χ hb
    obtain ⟨hσ_atom, -, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
    have hts := kvE2_sepZoneFact_gt M s w x t σ hσ_atom ⟨2, by omega⟩
      (by rw [congrFun hzone ⟨2, by omega⟩]; decide)
    exact ⟨s, hts, (hck χ s).mpr hχs, fun r _ _ hf => hf⟩
  | false =>
    change TemporalTruth M atomMap t (Formula.untl (charK χ) Formula.top).neg
    rintro ⟨s, hts, hsχ, -⟩
    have hz := kvE2_sepCharZone3 M s w x t (false, true) (false, true) (false, true)
      (iff_of_false (lt_asymm (hwt.trans hts)) (by decide))
      (iff_of_true (hwt.trans hts) rfl)
      (iff_of_false (lt_asymm (hxw.trans (hwt.trans hts))) (by decide))
      (iff_of_true (hxw.trans (hwt.trans hts)) rfl)
      (iff_of_false (lt_asymm hts) (by decide)) (iff_of_true hts rfl)
    have hpos := kvE2_sepHasPos_of_realized qnf M w x t s h kvE2SepZFutT3 hz χ
      ((hck χ s).mp hsχ)
    rw [hb] at hpos
    exact Bool.noConfusion hpos

/-! ### Per-owner (inner-zone) literal honesty — the six `kvE2SepBits` families

Each positive bit yields a genuine zone witness through the owner's realized fold channel
(`nf_eval_depth1_fold_iff`); each negative bit refutes the literal because a witness would
force the bit positive through the same channel. All zones here are placement-generic
boundary/exterior zones — the OPEN interior keys never appear (F5 stays confined to the
strict placements of conjunct (i)). -/

/-- Marker-clean private clone of the arity-4 zoneHolds cons-iff helper
    (`SubBracket2.lean:538`), byte-identical in content: `zoneHolds` over the anchor env
    `[a, w, x, t]` at a pointwise `Fin.cons` zone spec, unfolded to its four coordinate
    biconditionals (Def 3.1 ordering channel, PDF p.4). Cloned so the endpoint-honesty
    pack references no identifier carrying the open-key marker prefix — the F5 count
    guard stays mechanical. -/
-- Module-public (was file-private): consumed by later modules of the SharedWitness tower (H).
theorem kvE2_sepZone4_iff {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (e0 e1 e2 e3 v : M.carrier)
    (p0 p1 p2 p3 : Bool × Bool) :
    zoneHolds M (Fin.cons e0 (Fin.cons e1 (Fin.cons e2 (fun _ => e3))) : Fin 4 → M.carrier)
      (Fin.cons p0 (Fin.cons p1 (Fin.cons p2 (fun _ => p3))) : ZoneSpec 4) v ↔
    (((v < e0) ↔ p0.1 = true) ∧ ((e0 < v) ↔ p0.2 = true)) ∧
    (((v < e1) ↔ p1.1 = true) ∧ ((e1 < v) ↔ p1.2 = true)) ∧
    (((v < e2) ↔ p2.1 = true) ∧ ((e2 < v) ↔ p2.2 = true)) ∧
    (((v < e3) ↔ p3.1 = true) ∧ ((e3 < v) ↔ p3.2 = true)) := by
  constructor
  · intro h
    have h0 := h ⟨0, by omega⟩
    have h1 := h ⟨1, by omega⟩
    have h2 := h ⟨2, by omega⟩
    have h3 := h ⟨3, by omega⟩
    simp only [Fin.cons] at h0 h1 h2 h3
    exact ⟨h0, h1, h2, h3⟩
  · rintro ⟨h0, h1, h2, h3⟩ i
    match i with
    | ⟨0, _⟩ => exact h0
    | ⟨1, _⟩ => exact h1
    | ⟨2, _⟩ => exact h2
    | ⟨3, _⟩ => exact h3

/-- `zPastX4` Since-literal honesty at `x` (per interior owner). -/
private theorem kvE2_sepOwnerLit_zPastX4 {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (σ : NormalForm sig 1 4) (a w x t : M.carrier)
    (hxa : x < a) (hxw : x < w) (hxt : x < t)
    (hs : NfEvalNf M 1 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      TemporalTruth M atomMap u (charBase χ) ↔ NfEvalNf M 0 1 (fun _ => u) χ)
    (χ : NormalForm sig 0 1) :
    TemporalTruth M atomMap x
      (kvE2SepLit (kvE2SepBits σ kvE2SepZPastX4 χ)
        (Formula.snce (charBase χ) Formula.top)) := by
  obtain ⟨-, h_zone, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
  cases hb : kvE2SepBits σ kvE2SepZPastX4 χ with
  | true =>
    change TemporalTruth M atomMap x (Formula.snce (charBase χ) Formula.top)
    obtain ⟨v, hz, hv⟩ := (h_zone kvE2SepZPastX4 χ).mpr hb
    obtain ⟨h0, h1, h2, h3⟩ := (kvE2_sepZone4_iff M a w x t v
      (true, false) (true, false) (true, false) (true, false)).mp hz
    exact ⟨v, h2.1.mpr rfl, (hcb χ v).mpr hv, fun r _ _ hf => hf⟩
  | false =>
    change TemporalTruth M atomMap x (Formula.snce (charBase χ) Formula.top).neg
    rintro ⟨s, hsx, hsχ, -⟩
    have hz : zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t))))
        kvE2SepZPastX4 s := by
      refine (kvE2_sepZone4_iff M a w x t s
        (true, false) (true, false) (true, false) (true, false)).mpr ?_
      exact ⟨⟨iff_of_true (hsx.trans hxa) rfl,
          iff_of_false (lt_asymm (hsx.trans hxa)) (by decide)⟩,
        ⟨iff_of_true (hsx.trans hxw) rfl,
          iff_of_false (lt_asymm (hsx.trans hxw)) (by decide)⟩,
        ⟨iff_of_true hsx rfl, iff_of_false (lt_asymm hsx) (by decide)⟩,
        ⟨iff_of_true (hsx.trans hxt) rfl,
          iff_of_false (lt_asymm (hsx.trans hxt)) (by decide)⟩⟩
    have hbit : kvE2SepBits σ kvE2SepZPastX4 χ = true :=
      (h_zone kvE2SepZPastX4 χ).mp ⟨s, hz, (hcb χ s).mp hsχ⟩
    rw [hb] at hbit
    exact Bool.noConfusion hbit

/-- `zAtX4` at-literal honesty at `x` (per interior owner). -/
private theorem kvE2_sepOwnerLit_zAtX4 {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (σ : NormalForm sig 1 4) (a w x t : M.carrier)
    (hxa : x < a) (hxw : x < w) (hxt : x < t)
    (hs : NfEvalNf M 1 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      TemporalTruth M atomMap u (charBase χ) ↔ NfEvalNf M 0 1 (fun _ => u) χ)
    (χ : NormalForm sig 0 1) :
    TemporalTruth M atomMap x
      (kvE2SepLit (kvE2SepBits σ kvE2SepZAtX4 χ) (charBase χ)) := by
  obtain ⟨-, h_zone, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
  cases hb : kvE2SepBits σ kvE2SepZAtX4 χ with
  | true =>
    change TemporalTruth M atomMap x (charBase χ)
    obtain ⟨v, hz, hv⟩ := (h_zone kvE2SepZAtX4 χ).mpr hb
    obtain ⟨h0, h1, h2, h3⟩ := (kvE2_sepZone4_iff M a w x t v
      (true, false) (true, false) (false, false) (true, false)).mp hz
    have hveq : v = x := le_antisymm
      (not_lt.mp (fun hc => Bool.noConfusion (h2.2.mp hc)))
      (not_lt.mp (fun hc => Bool.noConfusion (h2.1.mp hc)))
    exact (hcb χ x).mpr (hveq ▸ hv)
  | false =>
    change TemporalTruth M atomMap x (charBase χ).neg
    intro hch
    have hz : zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t))))
        kvE2SepZAtX4 x := by
      refine (kvE2_sepZone4_iff M a w x t x
        (true, false) (true, false) (false, false) (true, false)).mpr ?_
      exact ⟨⟨iff_of_true hxa rfl, iff_of_false (lt_asymm hxa) (by decide)⟩,
        ⟨iff_of_true hxw rfl, iff_of_false (lt_asymm hxw) (by decide)⟩,
        ⟨iff_of_false (lt_irrefl x) (by decide), iff_of_false (lt_irrefl x) (by decide)⟩,
        ⟨iff_of_true hxt rfl, iff_of_false (lt_asymm hxt) (by decide)⟩⟩
    have hbit : kvE2SepBits σ kvE2SepZAtX4 χ = true :=
      (h_zone kvE2SepZAtX4 χ).mp ⟨x, hz, (hcb χ x).mp hch⟩
    rw [hb] at hbit
    exact Bool.noConfusion hbit

/-- `zAtT4` at-literal honesty at `t` (per interior owner). -/
private theorem kvE2_sepOwnerLit_zAtT4 {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (σ : NormalForm sig 1 4) (a w x t : M.carrier)
    (hat : a < t) (hwt : w < t) (hxt : x < t)
    (hs : NfEvalNf M 1 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      TemporalTruth M atomMap u (charBase χ) ↔ NfEvalNf M 0 1 (fun _ => u) χ)
    (χ : NormalForm sig 0 1) :
    TemporalTruth M atomMap t
      (kvE2SepLit (kvE2SepBits σ kvE2SepZAtT4 χ) (charBase χ)) := by
  obtain ⟨-, h_zone, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
  cases hb : kvE2SepBits σ kvE2SepZAtT4 χ with
  | true =>
    change TemporalTruth M atomMap t (charBase χ)
    obtain ⟨v, hz, hv⟩ := (h_zone kvE2SepZAtT4 χ).mpr hb
    obtain ⟨h0, h1, h2, h3⟩ := (kvE2_sepZone4_iff M a w x t v
      (false, true) (false, true) (false, true) (false, false)).mp hz
    have hveq : v = t := le_antisymm
      (not_lt.mp (fun hc => Bool.noConfusion (h3.2.mp hc)))
      (not_lt.mp (fun hc => Bool.noConfusion (h3.1.mp hc)))
    exact (hcb χ t).mpr (hveq ▸ hv)
  | false =>
    change TemporalTruth M atomMap t (charBase χ).neg
    intro hch
    have hz : zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t))))
        kvE2SepZAtT4 t := by
      refine (kvE2_sepZone4_iff M a w x t t
        (false, true) (false, true) (false, true) (false, false)).mpr ?_
      exact ⟨⟨iff_of_false (lt_asymm hat) (by decide), iff_of_true hat rfl⟩,
        ⟨iff_of_false (lt_asymm hwt) (by decide), iff_of_true hwt rfl⟩,
        ⟨iff_of_false (lt_asymm hxt) (by decide), iff_of_true hxt rfl⟩,
        ⟨iff_of_false (lt_irrefl t) (by decide), iff_of_false (lt_irrefl t) (by decide)⟩⟩
    have hbit : kvE2SepBits σ kvE2SepZAtT4 χ = true :=
      (h_zone kvE2SepZAtT4 χ).mp ⟨t, hz, (hcb χ t).mp hch⟩
    rw [hb] at hbit
    exact Bool.noConfusion hbit

/-- `zFutT4` Until-literal honesty at `t` (per interior owner). -/
private theorem kvE2_sepOwnerLit_zFutT4 {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (σ : NormalForm sig 1 4) (a w x t : M.carrier)
    (hat : a < t) (hwt : w < t) (hxt : x < t)
    (hs : NfEvalNf M 1 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      TemporalTruth M atomMap u (charBase χ) ↔ NfEvalNf M 0 1 (fun _ => u) χ)
    (χ : NormalForm sig 0 1) :
    TemporalTruth M atomMap t
      (kvE2SepLit (kvE2SepBits σ kvE2SepZFutT4 χ)
        (Formula.untl (charBase χ) Formula.top)) := by
  obtain ⟨-, h_zone, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
  cases hb : kvE2SepBits σ kvE2SepZFutT4 χ with
  | true =>
    change TemporalTruth M atomMap t (Formula.untl (charBase χ) Formula.top)
    obtain ⟨v, hz, hv⟩ := (h_zone kvE2SepZFutT4 χ).mpr hb
    obtain ⟨h0, h1, h2, h3⟩ := (kvE2_sepZone4_iff M a w x t v
      (false, true) (false, true) (false, true) (false, true)).mp hz
    exact ⟨v, h3.2.mpr rfl, (hcb χ v).mpr hv, fun r _ _ hf => hf⟩
  | false =>
    change TemporalTruth M atomMap t (Formula.untl (charBase χ) Formula.top).neg
    rintro ⟨s, hts, hsχ, -⟩
    have hz : zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t))))
        kvE2SepZFutT4 s := by
      refine (kvE2_sepZone4_iff M a w x t s
        (false, true) (false, true) (false, true) (false, true)).mpr ?_
      exact ⟨⟨iff_of_false (lt_asymm (hat.trans hts)) (by decide),
          iff_of_true (hat.trans hts) rfl⟩,
        ⟨iff_of_false (lt_asymm (hwt.trans hts)) (by decide),
          iff_of_true (hwt.trans hts) rfl⟩,
        ⟨iff_of_false (lt_asymm (hxt.trans hts)) (by decide),
          iff_of_true (hxt.trans hts) rfl⟩,
        ⟨iff_of_false (lt_asymm hts) (by decide), iff_of_true hts rfl⟩⟩
    have hbit : kvE2SepBits σ kvE2SepZFutT4 χ = true :=
      (h_zone kvE2SepZFutT4 χ).mp ⟨s, hz, (hcb χ s).mp hsχ⟩
    rw [hb] at hbit
    exact Bool.noConfusion hbit

/-- `zAtWL` pivot-literal honesty at `w` (LEFT-interior owner, `a < w`). -/
private theorem kvE2_sepOwnerLit_zAtWL {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (σ : NormalForm sig 1 4) (a w x t : M.carrier)
    (haw : a < w) (hxw : x < w) (hwt : w < t)
    (hs : NfEvalNf M 1 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      TemporalTruth M atomMap u (charBase χ) ↔ NfEvalNf M 0 1 (fun _ => u) χ)
    (χ : NormalForm sig 0 1) :
    TemporalTruth M atomMap w
      (kvE2SepLit (kvE2SepBits σ kvE2SepZAtWL χ) (charBase χ)) := by
  obtain ⟨-, h_zone, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
  cases hb : kvE2SepBits σ kvE2SepZAtWL χ with
  | true =>
    change TemporalTruth M atomMap w (charBase χ)
    obtain ⟨v, hz, hv⟩ := (h_zone kvE2SepZAtWL χ).mpr hb
    obtain ⟨h0, h1, h2, h3⟩ := (kvE2_sepZone4_iff M a w x t v
      (false, true) (false, false) (false, true) (true, false)).mp hz
    have hveq : v = w := le_antisymm
      (not_lt.mp (fun hc => Bool.noConfusion (h1.2.mp hc)))
      (not_lt.mp (fun hc => Bool.noConfusion (h1.1.mp hc)))
    exact (hcb χ w).mpr (hveq ▸ hv)
  | false =>
    change TemporalTruth M atomMap w (charBase χ).neg
    intro hch
    have hz : zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t))))
        kvE2SepZAtWL w := by
      refine (kvE2_sepZone4_iff M a w x t w
        (false, true) (false, false) (false, true) (true, false)).mpr ?_
      exact ⟨⟨iff_of_false (lt_asymm haw) (by decide), iff_of_true haw rfl⟩,
        ⟨iff_of_false (lt_irrefl w) (by decide), iff_of_false (lt_irrefl w) (by decide)⟩,
        ⟨iff_of_false (lt_asymm hxw) (by decide), iff_of_true hxw rfl⟩,
        ⟨iff_of_true hwt rfl, iff_of_false (lt_asymm hwt) (by decide)⟩⟩
    have hbit : kvE2SepBits σ kvE2SepZAtWL χ = true :=
      (h_zone kvE2SepZAtWL χ).mp ⟨w, hz, (hcb χ w).mp hch⟩
    rw [hb] at hbit
    exact Bool.noConfusion hbit

/-- `zAtWR` pivot-literal honesty at `w` (RIGHT-interior owner, `w < a`). -/
private theorem kvE2_sepOwnerLit_zAtWR {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (σ : NormalForm sig 1 4) (a w x t : M.carrier)
    (hwa : w < a) (hxw : x < w) (hwt : w < t)
    (hs : NfEvalNf M 1 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      TemporalTruth M atomMap u (charBase χ) ↔ NfEvalNf M 0 1 (fun _ => u) χ)
    (χ : NormalForm sig 0 1) :
    TemporalTruth M atomMap w
      (kvE2SepLit (kvE2SepBits σ kvE2SepZAtWR χ) (charBase χ)) := by
  obtain ⟨-, h_zone, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
  cases hb : kvE2SepBits σ kvE2SepZAtWR χ with
  | true =>
    change TemporalTruth M atomMap w (charBase χ)
    obtain ⟨v, hz, hv⟩ := (h_zone kvE2SepZAtWR χ).mpr hb
    obtain ⟨h0, h1, h2, h3⟩ := (kvE2_sepZone4_iff M a w x t v
      (true, false) (false, false) (false, true) (true, false)).mp hz
    have hveq : v = w := le_antisymm
      (not_lt.mp (fun hc => Bool.noConfusion (h1.2.mp hc)))
      (not_lt.mp (fun hc => Bool.noConfusion (h1.1.mp hc)))
    exact (hcb χ w).mpr (hveq ▸ hv)
  | false =>
    change TemporalTruth M atomMap w (charBase χ).neg
    intro hch
    have hz : zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t))))
        kvE2SepZAtWR w := by
      refine (kvE2_sepZone4_iff M a w x t w
        (true, false) (false, false) (false, true) (true, false)).mpr ?_
      exact ⟨⟨iff_of_true hwa rfl, iff_of_false (lt_asymm hwa) (by decide)⟩,
        ⟨iff_of_false (lt_irrefl w) (by decide), iff_of_false (lt_irrefl w) (by decide)⟩,
        ⟨iff_of_false (lt_asymm hxw) (by decide), iff_of_true hxw rfl⟩,
        ⟨iff_of_true hwt rfl, iff_of_false (lt_asymm hwt) (by decide)⟩⟩
    have hbit : kvE2SepBits σ kvE2SepZAtWR χ = true :=
      (h_zone kvE2SepZAtWR χ).mp ⟨w, hz, (hcb χ w).mp hch⟩
    rw [hb] at hbit
    exact Bool.noConfusion hbit

/-- **Left-endpoint honesty**): under an honest evaluation `h`, the
    EXISTING joint left endpoint predicate `kvE2SepEpL` evaluates at the fixed `x`.
    Rabinovich §5 (p.7): the ψ0/ψ1/φ split routes non-interior positive witnesses
    (`zPastX3`/`zAtX3` classes and the per-owner `zPastX4`/`zAtX4` exterior/boundary
    content) to atomic E[Σ] endpoint literals via Prop 3.5 (pp.5,7) — this lemma is that
    routing's completeness half, previously hidden behind `hLR`'s vacuity. `Since`
    navigation rides the fixed endpoint as evaluation point (LITMUS-clean); `hcb`/`hck`
    are the abstract char-semantics correctness hypotheses (`nfPred_correct` shape). -/
theorem kvE2_sepEpL_eval_of_honest {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      TemporalTruth M atomMap u (charBase χ) ↔ NfEvalNf M 0 1 (fun _ => u) χ)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      TemporalTruth M atomMap u (charK χ) ↔ NfEvalNf M 1 1 (fun _ => u) χ) :
    (kvE2SepEpL charBase charK qnf).EvalAt M atomMap x := by
  simp only [kvE2SepEpL, TemporalPred.EvalAt]
  rw [formula_conjList_iff]
  intro f hf
  rcases List.mem_append.mp hf with hf | hf
  · rcases List.mem_append.mp hf with hf | hf
    · rcases List.mem_cons.mp hf with rfl | hf
      · -- Joint head: `qnf.1`'s x-coordinate 1-type at `x`.
        have hp := kvE2_sepProj3_eval M (Fin.cons w (Fin.cons x (fun _ => t))) qnf.1 h.1
          ⟨1, by omega⟩
        exact (hcb _ x).mpr hp
      · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
        exact kvE2_sepHasPosLit_zPastX3 charK qnf M atomMap w x t hxw hwt h hck χ
    · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
      exact kvE2_sepHasPosLit_zAtX3 charK qnf M atomMap w x t hxw hwt h hck χ
  · obtain ⟨σ, hσmem, hfσ⟩ := List.mem_flatMap.mp hf
    have hσpos : qnf.2 σ = true := by
      rcases List.mem_append.mp hσmem with hσm | hσm <;>
        exact (List.mem_filter.mp (List.mem_filter.mp hσm).1).2
    have hσzone : nf0ZoneSpec σ.1 = kvE2SepZXW3 ∨ nf0ZoneSpec σ.1 = kvE2SepZWT3 := by
      rcases List.mem_append.mp hσmem with hσm | hσm
      · exact Or.inl (of_decide_eq_true (List.mem_filter.mp hσm).2)
      · exact Or.inr (of_decide_eq_true (List.mem_filter.mp hσm).2)
    obtain ⟨a, hs⟩ := (h.2 σ).mpr hσpos
    obtain ⟨hσ_atom, -, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
    have hxa : x < a := by
      rcases hσzone with hzone | hzone
      · have hgt := kvE2_sepZoneFact_gt M a w x t σ hσ_atom ⟨1, by omega⟩
          (by rw [congrFun hzone ⟨1, by omega⟩]; decide)
        exact hgt
      · have hgt := kvE2_sepZoneFact_gt M a w x t σ hσ_atom ⟨0, by omega⟩
          (by rw [congrFun hzone ⟨0, by omega⟩]; decide)
        exact hxw.trans hgt
    rcases List.mem_append.mp hfσ with hfσ | hfσ
    · rcases List.mem_cons.mp hfσ with rfl | hfσ
      · -- σ's own x-coordinate 1-type at `x`.
        have hp := kvE2_sepProj4_eval M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t))))
          σ hσ_atom ⟨2, by omega⟩
        exact (hcb _ x).mpr hp
      · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hfσ
        exact kvE2_sepOwnerLit_zPastX4 charBase M atomMap σ a w x t hxa hxw
          (hxw.trans hwt) hs hcb χ
    · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hfσ
      exact kvE2_sepOwnerLit_zAtX4 charBase M atomMap σ a w x t hxa hxw
        (hxw.trans hwt) hs hcb χ

/-- **Shared-pivot honesty**): under an honest evaluation `h`, the
    EXISTING shared interior-witness point type `kvE2SepPtW` evaluates at the pivot `w`.
    The `zAtW3` class and the per-owner `zAtWL`/`zAtWR` self-zone literals are the pivot's
    boundary content (Rabinovich §5, p.7, via Prop 3.5, pp.5,7); positive bits are the σ_w
    route of `kvE2_sepHonest_hLR_absurd`, now an obligation instead of a contradiction. -/
theorem kvE2_sepPtW_eval_of_honest {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      TemporalTruth M atomMap u (charBase χ) ↔ NfEvalNf M 0 1 (fun _ => u) χ)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      TemporalTruth M atomMap u (charK χ) ↔ NfEvalNf M 1 1 (fun _ => u) χ) :
    (kvE2SepPtW charBase charK qnf).EvalAt M atomMap w := by
  simp only [kvE2SepPtW, TemporalPred.EvalAt]
  rw [formula_conjList_iff]
  intro f hf
  rcases List.mem_append.mp hf with hf | hf
  · rcases List.mem_append.mp hf with hf | hf
    · rcases List.mem_cons.mp hf with rfl | hf
      · -- Joint head: `qnf.1`'s w-coordinate 1-type at `w`.
        have hp := kvE2_sepProj3_eval M (Fin.cons w (Fin.cons x (fun _ => t))) qnf.1 h.1
          ⟨0, by omega⟩
        exact (hcb _ w).mpr hp
      · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
        exact kvE2_sepHasPosLit_zAtW3 charK qnf M atomMap w x t hxw hwt h hck χ
    · -- LEFT-interior owner blocks (`zAtWL` self-zone key at the pivot).
      obtain ⟨σ, hσm, hfσ⟩ := List.mem_flatMap.mp hf
      have hσpos : qnf.2 σ = true :=
        (List.mem_filter.mp (List.mem_filter.mp hσm).1).2
      have hzone : nf0ZoneSpec σ.1 = kvE2SepZXW3 :=
        of_decide_eq_true (List.mem_filter.mp hσm).2
      obtain ⟨a, hs⟩ := (h.2 σ).mpr hσpos
      obtain ⟨hσ_atom, -, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
      have haw : a < w := by
        have hlt := kvE2_sepZoneFact_lt M a w x t σ hσ_atom ⟨0, by omega⟩
          (by rw [congrFun hzone ⟨0, by omega⟩]; decide)
        exact hlt
      rcases List.mem_cons.mp hfσ with rfl | hfσ
      · have hp := kvE2_sepProj4_eval M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t))))
          σ hσ_atom ⟨1, by omega⟩
        exact (hcb _ w).mpr hp
      · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hfσ
        exact kvE2_sepOwnerLit_zAtWL charBase M atomMap σ a w x t haw hxw hwt hs hcb χ
  · -- RIGHT-interior owner blocks (`zAtWR` self-zone key at the pivot; mirror).
    obtain ⟨σ, hσm, hfσ⟩ := List.mem_flatMap.mp hf
    have hσpos : qnf.2 σ = true :=
      (List.mem_filter.mp (List.mem_filter.mp hσm).1).2
    have hzone : nf0ZoneSpec σ.1 = kvE2SepZWT3 :=
      of_decide_eq_true (List.mem_filter.mp hσm).2
    obtain ⟨a, hs⟩ := (h.2 σ).mpr hσpos
    obtain ⟨hσ_atom, -, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
    have hwa : w < a := by
      have hgt := kvE2_sepZoneFact_gt M a w x t σ hσ_atom ⟨0, by omega⟩
        (by rw [congrFun hzone ⟨0, by omega⟩]; decide)
      exact hgt
    rcases List.mem_cons.mp hfσ with rfl | hfσ
    · have hp := kvE2_sepProj4_eval M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t))))
        σ hσ_atom ⟨1, by omega⟩
      exact (hcb _ w).mpr hp
    · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hfσ
      exact kvE2_sepOwnerLit_zAtWR charBase M atomMap σ a w x t hwa hxw hwt hs hcb χ

/-- **Right-endpoint honesty**, mirror of
    `kvE2_sepEpL_eval_of_honest`): under an honest evaluation `h`, the EXISTING joint
    right endpoint predicate `kvE2SepEpR` evaluates at the fixed `t`. `zAtT3`/`zFutT3`
    classes and per-owner `zAtT4`/`zFutT4` content ride the at-`t` and `Until` literals
    (Rabinovich §5, p.7, via Prop 3.5, pp.5,7). -/
theorem kvE2_sepEpR_eval_of_honest {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      TemporalTruth M atomMap u (charBase χ) ↔ NfEvalNf M 0 1 (fun _ => u) χ)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      TemporalTruth M atomMap u (charK χ) ↔ NfEvalNf M 1 1 (fun _ => u) χ) :
    (kvE2SepEpR charBase charK qnf).EvalAt M atomMap t := by
  simp only [kvE2SepEpR, TemporalPred.EvalAt]
  rw [formula_conjList_iff]
  intro f hf
  rcases List.mem_append.mp hf with hf | hf
  · rcases List.mem_append.mp hf with hf | hf
    · rcases List.mem_cons.mp hf with rfl | hf
      · -- Joint head: `qnf.1`'s t-coordinate 1-type at `t`.
        have hp := kvE2_sepProj3_eval M (Fin.cons w (Fin.cons x (fun _ => t))) qnf.1 h.1
          ⟨2, by omega⟩
        exact (hcb _ t).mpr hp
      · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
        exact kvE2_sepHasPosLit_zAtT3 charK qnf M atomMap w x t hxw hwt h hck χ
    · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
      exact kvE2_sepHasPosLit_zFutT3 charK qnf M atomMap w x t hxw hwt h hck χ
  · obtain ⟨σ, hσmem, hfσ⟩ := List.mem_flatMap.mp hf
    have hσpos : qnf.2 σ = true := by
      rcases List.mem_append.mp hσmem with hσm | hσm <;>
        exact (List.mem_filter.mp (List.mem_filter.mp hσm).1).2
    have hσzone : nf0ZoneSpec σ.1 = kvE2SepZXW3 ∨ nf0ZoneSpec σ.1 = kvE2SepZWT3 := by
      rcases List.mem_append.mp hσmem with hσm | hσm
      · exact Or.inl (of_decide_eq_true (List.mem_filter.mp hσm).2)
      · exact Or.inr (of_decide_eq_true (List.mem_filter.mp hσm).2)
    obtain ⟨a, hs⟩ := (h.2 σ).mpr hσpos
    obtain ⟨hσ_atom, -, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
    have hat : a < t := by
      rcases hσzone with hzone | hzone
      · have hlt := kvE2_sepZoneFact_lt M a w x t σ hσ_atom ⟨0, by omega⟩
          (by rw [congrFun hzone ⟨0, by omega⟩]; decide)
        exact lt_trans hlt hwt
      · have hlt := kvE2_sepZoneFact_lt M a w x t σ hσ_atom ⟨2, by omega⟩
          (by rw [congrFun hzone ⟨2, by omega⟩]; decide)
        exact hlt
    rcases List.mem_append.mp hfσ with hfσ | hfσ
    · rcases List.mem_cons.mp hfσ with rfl | hfσ
      · -- σ's own t-coordinate 1-type at `t`.
        have hp := kvE2_sepProj4_eval M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t))))
          σ hσ_atom ⟨3, by omega⟩
        exact (hcb _ t).mpr hp
      · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hfσ
        exact kvE2_sepOwnerLit_zAtT4 charBase M atomMap σ a w x t hat hwt
          (hxw.trans hwt) hs hcb χ
    · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hfσ
      exact kvE2_sepOwnerLit_zFutT4 charBase M atomMap σ a w x t hat hwt
        (hxw.trans hwt) hs hcb χ

end FormalSystem.Metalogic.WeakCanonical.Kamp
