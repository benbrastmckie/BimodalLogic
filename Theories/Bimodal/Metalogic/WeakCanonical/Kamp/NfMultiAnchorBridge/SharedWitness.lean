/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness.Soundness

/-! # Shared-Interior-Witness Joint Carrier (O1 + O1b + O2)

The ONE unbuilt object named by the SubBracket2V API banner (`SubBracket2V.lean:25-27`):
the shared-interior-witness conjunction `∃ w, ⋀_σ (per-σ realization at that same w)`,
built as a concrete, model-independent joint carrier `kvE2_sepBody` (Candidate A staged via
Candidate C, per the v7 faithful-separate-bracket design route and its consolidated
faithful-route analysis §2.2).

Every disjunct is a single FLAT bracket (Rabinovich 2014, `md:` refs to the Literature chunk):

- ONE shared `ptW` slot + per positive interior σ one `charK (nfk_projFresh σ)` E[Σ]-atom
  slot plus σ's per-region interior-positive `charBase χ` slots — quantifier-free /
  E[Σ]-atom point types ONLY (**Lemma 5.1**, PDF p.3: "alpha_j, beta_j are quantifier-free
  formulas over Sigma"); no chain predicate in any point-type position (FM-merge), no
  bracket-in-bracket (no-nesting, `NavigatedSpine.lean:43-48`).
- Disjuncts enumerate the JOINT interleavings of every positive interior σ's slot sequence
  between the fixed endpoints `x`, the shared `w` slot, and `t` (**Lemma 3.2(1)**, PDF p.3:
  "Conjunction of exists-forall formulas is equivalent to a disjunction of exists-forall
  formulas") — realized as permutations of the tagged slot union filtered by the per-σ
  region order (`XU* < x1 < UW*` resp. `WX1* < x1 < X1T*`).
- Refined segment types = conjunction of EVERY interior σ's exclusion content on that
  refined sub-interval (**Cor 5.4**, PDF p.5), keyed per arrangement by the position of
  each σ's fresh-witness slot.
- `epL`/`epR`/`ptW` carry (i) `qnf.1`'s endpoint 1-types, (ii) each interior σ's
  exterior/boundary `charBase` literals (per-σ `epL`/`epR` content, `SubBracket2V.lean:183-192`),
  and (iii) the σ-LEVEL navigation literals for the five non-interior outer placements —
  `Since`/`Until` `charK`-atom literals at the fixed endpoints (**Prop 3.5**, PDF p.3: the
  reconstruction rides the temporal evaluation point; LITMUS: no `x1 < e_i` literal).
- Gate-failure branch `{ disjuncts := [] }` under the depth-2 gate: outer off-fiber falsity,
  outer seven-zone consistency (the joint witness self-zone `zAtW3` included — nine-zone
  lesson one level up, `SubBracket2V.lean:160-166`), inner off-fiber for every positive σ,
  and the inner NINE-zone consistency (verbatim `SubBracket2V.lean:1400-1408` pattern set,
  including both witness self-zones `zAtX1`/`zAtW`) for left-interior positives.

**Recorded scope decision (Phase 7).** Positive subs are classified by their OUTER zone
`nf0_zoneSpec σ.1` (x1 relative to `[w,x,t]`; the enumeration device of the quarantined
`kvE2_body` reused as a *pattern*, never imported). The two interior classes (`zXW3`,
`zWT3`) receive slot groups; the five non-interior classes ride the σ-level endpoint
literals that the landed joint dischargers (`NavigatedSpine.lean:257-383`) serve. The inner
nine-zone gate clause is stated for the LEFT-interior class (the class the landed per-σ kit
`kvE_subBracket2V_correctness_pair` serves); extending it to the mirrored right-interior
class is deferred to the phase that consumes it (Phases 8-10 arbitration).

DO-NOT-EDIT discipline: this module is purely additive; it consumes only public
`SubBracket2V`/`NavigatedSpine`/sibling-Kamp assets and rebuilds nothing landed. -/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation
  (nf_depth0_char_formula nf_depth0_char_formula_correct
   formula_conjList formula_conjList_iff)

-- NOTE: `KvE2SepSpikeOrderType` and `kvE2_sepSpikeOrderTypes` were RELOCATED
-- above the carrier (`## Order-type-disjunction index (RELOCATED above the carrier)`), so
-- `kvE2_sepBody`
-- can reference `kvE2_sepArr'`. The Phase-1 spike theorems below still consume them.

/-- **Per-order-type validity** (the faithful replacement of the additive `kvE2_sepValid`): each
    disjunct reads the fold bit appropriate to ITS arrangement. Strict disjuncts consume σ's OPEN
    `zXU`/`zUW` bits (the surviving compat-leaf reads, `kvE2_sepCompat_lX1_eq`/`_after_eq`,
    SW:409/422); the coincidence disjunct consumes σ's CLOSED `zAtX1L` bit fed by
    `kvE2_sepCoincidentAnchor_discharge` (the §5 meet channel). No disjunct conflates open and
    closed keys — the crux the additive filter structurally could not express (handoff 05). -/
def kvE2_sepSpikeDisjValid {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) (χ : NormalForm sig 0 1) :
    KvE2SepSpikeOrderType → Bool
  | .strictBefore => kvE2_sepBits σ kvE_sub2_zXU χ
  | .strictAfter  => kvE2_sepBits σ kvE_sub2_zUW χ
  | .coincident   => kvE2_sepBits σ kvE2_sep_zAtX1L χ

/-- The filtered valid order-type disjuncts (the faithful analog of `kvE2_sepArrL`, per-order-type
    rather than an additive filter over a flat slot union). -/
def kvE2_sepSpikeArr {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) (χ : NormalForm sig 0 1) : List KvE2SepSpikeOrderType :=
  kvE2_sepSpikeOrderTypes.filter (kvE2_sepSpikeDisjValid σ χ)

/-- **CONTRAST — the plan-02 RED baseline.** The additive OPEN-zone-only filter (reading solely
    the `zXU`/`zUW` bits, never the closed one) is EMPTY on the exact handoff-05 scenario. This is
    precisely the obligation `kvE2_sepBody_nonvacuous` made FALSE: no strict disjunct survives when
    the coincidence forces both open bits to `false`. -/
theorem kvE2_sepSpike_additiveOpenOnly_vacuous {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) (χ : NormalForm sig 0 1)
    (hzXU : kvE2_sepBits σ kvE_sub2_zXU χ = false)
    (hzUW : kvE2_sepBits σ kvE_sub2_zUW χ = false) :
    ([KvE2SepSpikeOrderType.strictBefore, KvE2SepSpikeOrderType.strictAfter].filter
      (kvE2_sepSpikeDisjValid σ χ)) = [] := by
  have h1 : kvE2_sepSpikeDisjValid σ χ KvE2SepSpikeOrderType.strictBefore = false := hzXU
  have h2 : kvE2_sepSpikeDisjValid σ χ KvE2SepSpikeOrderType.strictAfter = false := hzUW
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
    (hσ : nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (χ : NormalForm sig 0 1)
    (hp : nf_eval_nf M 0 1 (fun _ => x1) χ)
    -- The handoff-05 OPEN-zone FALSE pins (no χ-witness strictly in `(x,x1)` or `(x1,w)`); kept as
    -- scenario fidelity — non-vacuity of the FULL faithful arr needs only the coincidence disjunct,
    -- while `kvE2_sepSpike_additiveOpenOnly_vacuous` shows these make the open-only filter empty.
    (_hzXU : kvE2_sepBits σ kvE_sub2_zXU χ = false)
    (_hzUW : kvE2_sepBits σ kvE_sub2_zUW χ = false) :
    kvE2_sepSpikeArr σ χ ≠ [] := by
  -- The CLOSED-zone bit is discharged TRUE by the preserved axiom-clean coincidence brick.
  have hclosed : kvE2_sepBits σ kvE2_sep_zAtX1L χ = true :=
    kvE2_sepCoincidentAnchor_discharge σ M x1 w x t hxx1 hx1w hwt hσ χ hp
  -- The coincidence disjunct is therefore VALID and present in the filtered order-type list,
  -- so the faithful arrangement set is non-empty — the exact obligation the additive filter failed.
  apply List.ne_nil_of_mem (a := KvE2SepSpikeOrderType.coincident)
  unfold kvE2_sepSpikeArr
  rw [List.mem_filter]
  refine ⟨by decide, ?_⟩
  simpa [kvE2_sepSpikeDisjValid] using hclosed

-- NOTE: the Phase-2 order-type index cluster (KvE2SepWeakOrder,
-- kvE2_sepOrderTypes, kvE2_sepModelTag/Order, kvE2_sepClosedLeafStub, kvE2_sepDisjValidOwner,
-- kvE2_sepDisjValid, kvE2_sepArr', kvE2_sepArr'_decidable, kvE2_sepModelOrder_mem_*,
-- kvE2_sepArr'_mem_modelOrder) was RELOCATED above the carrier so kvE2_sepBody can enumerate
-- kvE2_sepArr'. See "## Order-type-disjunction index (RELOCATED above the carrier)".

/-! ## Closed-zone compat leaf + three-way segment-meet cut (LEFT)

The 5th, closed-zone compat leaf (`kvE2_sepCompat_zAtX1L_eq`) re-hosts the Phase-2 forward stub
`kvE2_sepClosedLeafStub` (which read σ's OWN fresh type `nf0_projFresh σ.1`) over a FOREIGN owner's
base type `χ`: at a coincidence tie the disjunct's closed-zone validity is discharged TRUE by the
preserved axiom-clean `kvE2_sepCoincidentAnchor_discharge` (§5 meet channel, PDF p.6). The
three-way segment cut (`kvE2_sepSegLForSub'`) supersedes the binary before/after cut
`kvE2_sepSegLForSub` (`:561`) with a before/**at**/after cut whose "at" case sets the LEFT-interior
segment type to the MEET `A_i^- ∧ A_i^+` (the §5 splitting `A_i = A_i^- ∧ A_i^+`, PDF p.6) — the
conjunction of σ's `(x,x1)` before-exclusion (`kvE_sub2_zXU`) and `(x1,w)` after-exclusion
(`kvE_sub2_zUW`), i.e. universal β over the whole shared interval around the closed anchor.

Faithfulness invariants exercised: **F2** (meet, not vacuity — the "at" case discriminates via a
genuine two-sided exclusion, never `Formula.top`), **F5** (the coincidence disjunct reads the CLOSED
`zAtX1L` key; strict disjuncts read the OPEN `zXU`/`zUW` keys — never conflated), **F1** (the meet
type is quantifier-free over Σ — a `Formula.and` of two `charBase`-fold segment forms), **F6** (the
per-bracket F-chain is unaffected — this is a per-owner segment contribution, combined ABOVE the
chain by the cross-owner `kvE2_sepPos`-map conjunction in `kvE2_sepSegLAt`).

The binary `kvE2_sepSegLForSub` is left in place (additive build; its removal/rewiring is Phase 6);
the two LEFT compat leaves `kvE2_sepCompat_lX1_eq`/`kvE2_sepCompat_lX1_after_eq` survive unchanged
as
the strict-disjunct validators (see the survival note below). -/

/-- **5th closed-zone compat leaf** (Phase 4, re-host of `kvE2_sepClosedLeafStub` over foreign base
    types). At a coincidence tie — a foreign owner's base type `χ` realized AT σ's fresh anchor `x1`
    (`nf_eval_nf M 0 1 (fun _ => x1) χ`) under `x < x1 < w < t` — the coincidence disjunct's
    validity `kvE2_sepSpikeDisjValid σ χ .coincident` is TRUE, discharged by the preserved
    axiom-clean `kvE2_sepCoincidentAnchor_discharge`. Definitionally the disjunct read is
    `kvE2_sepBits σ kvE2_sep_zAtX1L χ` (the CLOSED self-zone key, F5), so this leaf establishes the
    §5 meet-typed shared point (PDF p.6) over a FOREIGN owner's type — the generalization of the
    stub's own-type read `kvE2_sepBits σ kvE2_sep_zAtX1L (nf0_projFresh σ.1)`. F2 (meet, not
    vacuity): the tie is a first-class DISCHARGED disjunct, never a refuted inequality. -/
theorem kvE2_sepCompat_zAtX1L_eq {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) (M : OrderedMonadicStructure sig)
    (x1 w x t : M.carrier) (hxx1 : x < x1) (hx1w : x1 < w) (hwt : w < t)
    (hσ : nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (χ : NormalForm sig 0 1)
    (hp : nf_eval_nf M 0 1 (fun _ => x1) χ) :
    kvE2_sepSpikeDisjValid σ χ KvE2SepSpikeOrderType.coincident = true := by
  -- The disjunct read `kvE2_sepSpikeDisjValid σ χ .coincident` is definitionally the CLOSED
  -- `zAtX1L` bit; the preserved brick discharges it TRUE for the foreign type `χ` at the tie.
  change kvE2_sepBits σ kvE2_sep_zAtX1L χ = true
  exact kvE2_sepCoincidentAnchor_discharge σ M x1 w x t hxx1 hx1w hwt hσ χ hp

/-- **Three-way LEFT segment cut** (Phase 4, supersedes the binary `kvE2_sepSegLForSub`, `:561`).
    σ's exclusion contribution to a LEFT-region refined sub-interval, keyed by σ's placement tag on
    the merged anchor set (the order-type disjunct). Branches on `nf0_zoneSpec σ.1`:
    * a LEFT-interior owner (`zXW3`, `x < x1_σ < w`) gets the three-way before/**at**/after cut:
      - `strictBefore` → LEFT β: the `(x, x1)` before-exclusion `kvE_sub2_zXU`;
      - `coincident`   → the **MEET** `A_i^- ∧ A_i^+` (§5 splitting, PDF p.6): `Formula.and` of the
        `(x,x1)` and `(x1,w)` exclusions — universal β over the whole shared interval, the closed
        anchor's two-sided content (F1 QF meet, F2 non-vacuous);
      - `strictAfter`  → RIGHT β: the `(x1, w)` after-exclusion `kvE_sub2_zUW`;
    * a RIGHT-interior owner (`zWT3`) contributes its uniform `(x,w)` exclusion (`kvE_sub2_zXU`),
      as in the binary cut — no tie on the left region for a right-interior owner;
    * a non-interior σ contributes `Formula.top` (its content rides its endpoint literal).
    Additive: the binary `kvE2_sepSegLForSub` is retained; Phase 6 rewires the assembly onto
    this. -/
noncomputable def kvE2_sepSegLForSub' {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (σ : NormalForm sig 1 4) (tag : KvE2SepSpikeOrderType) : Formula :=
  if nf0_zoneSpec σ.1 = kvE2_sep_zXW3 then
    match tag with
    | .strictBefore => kvE2_sepSegForm charBase σ kvE_sub2_zXU
    | .coincident   =>
        Formula.and (kvE2_sepSegForm charBase σ kvE_sub2_zXU)
          (kvE2_sepSegForm charBase σ kvE_sub2_zUW)
    | .strictAfter  => kvE2_sepSegForm charBase σ kvE_sub2_zUW
  else if nf0_zoneSpec σ.1 = kvE2_sep_zWT3 then
    kvE2_sepSegForm charBase σ kvE_sub2_zXU
  else Formula.top

/-- **"At"-case soundness** (Phase 4, Risk R2 core content). For a LEFT-interior owner σ
    (`nf0_zoneSpec σ.1 = kvE2_sep_zXW3`), the coincidence ("at") case of the three-way cut IS the
    §5 meet `A_i = A_i^- ∧ A_i^+` (PDF p.6): the `Formula.and` of σ's `(x,x1)` before-exclusion and
    `(x1,w)` after-exclusion. This is the faithful universal-β-over-the-shared-interval type — σ
    excludes every foreign χ it excludes on EITHER open sub-interval, i.e. over the whole interval
    `(x,w) ∖ {x1}` around the closed anchor. Sound (not vacuity, F2): the meet is a genuine
    two-sided `charBase`-fold conjunction, never `Formula.top`; QF (F1). Axiom-clean (definitional
    reduction — no `sorryAx`). -/
theorem kvE2_sepSegLForSub'_at_sound {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (σ : NormalForm sig 1 4) (hzone : nf0_zoneSpec σ.1 = kvE2_sep_zXW3) :
    kvE2_sepSegLForSub' charBase σ KvE2SepSpikeOrderType.coincident
      = Formula.and (kvE2_sepSegForm charBase σ kvE_sub2_zXU)
          (kvE2_sepSegForm charBase σ kvE_sub2_zUW) := by
  simp only [kvE2_sepSegLForSub', hzone, if_pos]

/-! ## Three-way segment-meet cut (RIGHT)

The RIGHT mirror of Phase 4. The §5 splitting `A_i = A_i^- ∧ A_i^+` (PDF p.6) with the right
sub-interval `A_i^+(z,z_1)` (PDF p.6) is realized on the RIGHT region: the tie now belongs to a
RIGHT-interior owner (`zWT3`, `w < x1_σ < t`), whose two open sub-intervals are the `(w, x1)`
before-exclusion (`kvE2_sep_zWX1`) and the `(x1, t)` after-exclusion (`kvE_sub2_zWT`). The three-way
before/**at**/after cut sets the "at" (coincidence) case to the MEET of those two, i.e. universal β
over the whole shared interval `(w,t) ∖ {x1}` around the closed anchor. A LEFT-interior owner
(`zXW3`) on the RIGHT region contributes its uniform `(w,t)` exclusion (`kvE_sub2_zWT`), exactly as
in the binary cut `kvE2_sepSegRForSub` (`:574`) — no tie on the right region for a left-interior
owner.

Compat-leaf survival audit:
  * All FOUR strict-disjunct compat leaves SURVIVE unchanged, re-hosted as strict-disjunct
    validators (their statements are untouched; only their ROLE changed from bits of the abandoned
    additive filter to per-order-type strict validators):
      - `kvE2_sepCompat_lX1_eq`        (:409) — LEFT `strictBefore`, open key `kvE_sub2_zXU`;
      - `kvE2_sepCompat_lX1_after_eq`  (:422) — LEFT `strictAfter`,  open key `kvE_sub2_zUW`;
      - `kvE2_sepCompat_rX1_eq`        (:434) — RIGHT `strictBefore`, open key `kvE2_sep_zWX1`;
      - `kvE2_sepCompat_rX1_after_eq`  (:446) — RIGHT `strictAfter`,  open key `kvE_sub2_zWT`.
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

The binary `kvE2_sepSegRForSub` is left in place (additive build; its removal/rewiring is Phase
6). -/

/-- **Three-way RIGHT segment cut** (Phase 5, supersedes the binary `kvE2_sepSegRForSub`, `:574`).
    σ's exclusion contribution to a RIGHT-region refined sub-interval, keyed by σ's placement tag on
    the merged anchor set (the order-type disjunct). Branches on `nf0_zoneSpec σ.1`:
    * a LEFT-interior owner (`zXW3`) contributes its uniform `(w,t)` exclusion (`kvE_sub2_zWT`),
      as in the binary cut — no tie on the right region for a left-interior owner;
    * a RIGHT-interior owner (`zWT3`, `w < x1_σ < t`) gets the three-way before/**at**/after cut:
      - `strictBefore` → the `(w, x1)` before-exclusion `kvE2_sep_zWX1`;
      - `coincident`   → the **MEET** `A_i^- ∧ A_i^+` (§5 splitting, PDF p.6; right sub-interval
        `A_i^+(z,z_1)`, PDF p.6): `Formula.and` of the `(w,x1)` and `(x1,t)` exclusions — universal
        β over the whole shared interval, the closed anchor's two-sided content (F1 QF meet, F2
        non-vacuous);
      - `strictAfter`  → the `(x1, t)` after-exclusion `kvE_sub2_zWT`;
    * a non-interior σ contributes `Formula.top` (its content rides its endpoint literal).
    Additive: the binary `kvE2_sepSegRForSub` is retained; Phase 6 rewires the assembly onto
    this. -/
noncomputable def kvE2_sepSegRForSub' {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (σ : NormalForm sig 1 4) (tag : KvE2SepSpikeOrderType) : Formula :=
  if nf0_zoneSpec σ.1 = kvE2_sep_zXW3 then
    kvE2_sepSegForm charBase σ kvE_sub2_zWT
  else if nf0_zoneSpec σ.1 = kvE2_sep_zWT3 then
    match tag with
    | .strictBefore => kvE2_sepSegForm charBase σ kvE2_sep_zWX1
    | .coincident   =>
        Formula.and (kvE2_sepSegForm charBase σ kvE2_sep_zWX1)
          (kvE2_sepSegForm charBase σ kvE_sub2_zWT)
    | .strictAfter  => kvE2_sepSegForm charBase σ kvE_sub2_zWT
  else Formula.top

/-- **"At"-case soundness** (Phase 5, Risk R2 core content — RIGHT mirror of
    `kvE2_sepSegLForSub'_at_sound`). For a RIGHT-interior owner σ
    (`nf0_zoneSpec σ.1 = kvE2_sep_zWT3`), the coincidence ("at") case of the three-way cut IS the
    §5 meet `A_i = A_i^- ∧ A_i^+` (PDF p.6; right sub-interval `A_i^+(z,z_1)`, PDF p.6): the
    `Formula.and` of σ's `(w,x1)` before-exclusion (`kvE2_sep_zWX1`) and `(x1,t)` after-exclusion
    (`kvE_sub2_zWT`). This is the faithful universal-β-over-the-shared-interval type — σ excludes
    every foreign χ it excludes on EITHER open sub-interval, i.e. over the whole interval
    `(w,t) ∖ {x1}` around the closed anchor. Sound (not vacuity, F2): the meet is a genuine
    two-sided `charBase`-fold conjunction, never `Formula.top`; QF (F1). Axiom-clean (definitional
    reduction — no `sorryAx`). -/
theorem kvE2_sepSegRForSub'_at_sound {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (σ : NormalForm sig 1 4) (hzone : nf0_zoneSpec σ.1 = kvE2_sep_zWT3) :
    kvE2_sepSegRForSub' charBase σ KvE2SepSpikeOrderType.coincident
      = Formula.and (kvE2_sepSegForm charBase σ kvE2_sep_zWX1)
          (kvE2_sepSegForm charBase σ kvE_sub2_zWT) := by
  unfold kvE2_sepSegRForSub'
  rw [if_neg (fun h => kvE2_sep_zWT3_ne_zXW3 (hzone.symm.trans h)), if_pos hzone]

/-! ## Lemma 3.2(1) ⇒ (soundness) over the order-type disjunction

The ⇒ half of Lemma 3.2(1) (PDF p.3): a HELD (selected) order-type disjunct implies the joint
conjunction — i.e. every per-owner placement in the held weak order is admitted by that owner's
arrangement-appropriate zone bit (F2, ⇒ realized, not vacuity). Each disjunct reads the bit
appropriate to ITS arrangement: a strict placement reads σ's OPEN `zXU`/`zUW` bit (via the surviving
compat leaves, and its segment content is the binary before/after cut refined by the
three-way `kvE2_sepSegLForSub'`/`kvE2_sepSegRForSub'` at the meet, Phases 4/5); the coincidence
placement reads σ's CLOSED `zAtX1L` bit (the §5 meet channel discharged by the axiom-clean
`kvE2_sepCoincidentAnchor_discharge`; re-hosted as `kvE2_sepCompat_zAtX1L_eq`, PDF p.6). No
disjunct conflates open and closed keys (F5). -/

/-- **Lemma 3.2(1) ⇒ (soundness), order-type level**: a valid disjunct
    `wo ∈ kvE2_sepArr' qnf` carries the JOINT conjunction of its per-owner arrangement bits — every
    placement `(σ, tag)` in the held weak order is admitted by `kvE2_sepDisjValidOwner σ tag`
    (`= true`). This is the ⇒ half of Lemma 3.2(1) (PDF p.3) at the per-order-type validity level: a
    HELD disjunct (one consistent arrangement) implies the conjunction of the zone-bit conditions
    its arrangement selects — strict placements the OPEN `zXU`/`zUW` bits, the coincidence placement
    the CLOSED `zAtX1L` bit (F5), never vacuously (F2). The realized segment/point content of each
    held disjunct is supplied by `kvE2_sepBody_extract` (the O3 bundle) and the three-way meet cuts
    (`kvE2_sepSegLForSub'_at_sound`/`kvE2_sepSegRForSub'_at_sound`). -/
theorem kvE2_sepArr'_sound {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) {wo : KvE2SepWeakOrder sig}
    (hwo : wo ∈ kvE2_sepArr' qnf) :
    (∀ p ∈ wo, kvE2_sepDisjValidOwner p.1 p.2.1 = true) ∧
      kvE2_sepAnchorDistinct wo = true ∧ kvE2_sepTieRead wo = true := by
  have hv : kvE2_sepDisjValid qnf wo = true := (List.mem_filter.mp hwo).2
  rw [kvE2_sepDisjValid, Bool.and_eq_true, Bool.and_eq_true, Bool.and_eq_true] at hv
  obtain ⟨⟨⟨hall, _hcons⟩, hanch⟩, htie⟩ := hv
  exact ⟨fun p hp => (List.all_eq_true.mp hall) p hp, hanch, htie⟩

/-! ## Honest non-interior evaluation pack

The endpoint/pivot honesty lemmas: from an honest evaluation `h`, the EXISTING literal
conjunctions `kvE2_sepEpL`/`kvE2_sepPtW`/`kvE2_sepEpR` evaluate at their fixed points
`x`/`w`/`t`. These are the obligations previously hidden behind `hLR`'s vacuity
(`kvE2_sepHonest_hLR_absurd`): every honest `qnf` has positive owners in non-interior
classes, and their content rides the endpoint/pivot literals — never the interleaving.
Grounding: Rabinovich §5 (p.7) — the ψ0/ψ1/φ split routes non-interior positive witnesses
to atomic E[Σ] endpoint literals via Prop 3.5 (pp.5,7); this section realizes exactly that
routing in Lean. NO new literal machinery: every case below discharges an EXISTING literal
family of the Part-I predicates (SW:886-946). The char-semantics hypotheses `hcb`/`hck`
are the abstract form of the concrete `nf_depth0_char_formula` correctness
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
    a realized arity-`m` NF along `Fin.castLE` (the `nfk_take` atom channel is exactly the
    cast-atom read). -/
private theorem kvE2_sep_nfk_take_eval {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) {m n : Nat} (hmn : m ≤ n)
    (env : Fin n → M.carrier) (sub : NormalForm sig 0 n)
    (hs : nf_eval_nf M 0 n env sub) :
    nf_eval_nf M 0 m (fun i => env (Fin.castLE hmn i)) (nfk_take hmn sub) := by
  intro a
  match a with
  | .pred p i => exact hs (.pred p (Fin.castLE hmn i))
  | .order i j hne =>
    exact hs (.order (Fin.castLE hmn i) (Fin.castLE hmn j)
      (fun he => hne (Fin.castLE_injective hmn he)))

/-- **Depth-1 fresh-projection factor**): a realized depth-1 owner
    factors through its fresh depth-1 arity-1 projection at the witness point — the depth-1
    analog of `nf_eval_nf0_cons_factor`'s monadic channel (Def 4.1, PDF p.5: the E[Σ]-atom
    channel read at depth 1). The quant layer transports through `nf_characteristic` +
    `nf_eval_unique` (NormalForm.lean:215/245) and the prefix restriction. -/
theorem kvE2_sepProjFresh_eval {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) {n : Nat}
    (env : Fin n → M.carrier) (v : M.carrier)
    (σ : NormalForm sig 1 (n + 1))
    (hσ : nf_eval_nf M 1 (n + 1) (Fin.cons v env) σ) :
    nf_eval_nf M 1 1 (fun _ => v) (nfk_projFresh σ) := by
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
      have hbit : σ.2 (nf_characteristic M 0 (n + 2) (Fin.cons u (Fin.cons v env))) = true :=
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
    nf0_zoneSpec (nf_characteristic M 1 4
        (Fin.cons v (Fin.cons w (Fin.cons x (fun _ => t))))).1
      = (Fin.cons p0 (Fin.cons p1 (fun _ => p2)) : ZoneSpec 3) := by
  have hco : ∀ (i : Fin 3) (pi : Bool × Bool),
      ((v < (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) i) ↔ pi.1 = true) →
      (((Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) i < v) ↔ pi.2 = true) →
      nf0_zoneSpec (nf_characteristic M 1 4
          (Fin.cons v (Fin.cons w (Fin.cons x (fun _ => t))))).1 i = pi := by
    intro i pi hl hr
    refine Prod.ext (@kvE2_sep_decide_eq_of_iff _ (Classical.dec _) _ ?_)
      (@kvE2_sep_decide_eq_of_iff _ (Classical.dec _) _ ?_)
    · simpa only [atom_eval, Fin.cons_zero, Fin.cons_succ] using hl
    · simpa only [atom_eval, Fin.cons_zero, Fin.cons_succ] using hr
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
    (hσa : ∀ a : AtomKind sig 4, atom_eval M env a ↔ σ.1 a = true)
    (k : Fin 4) :
    nf_eval_nf M 0 1 (fun _ => env k) (kvE2_sepProj4 σ k) := by
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
    (hr : ∀ a : AtomKind sig 3, atom_eval M env a ↔ r a = true)
    (k : Fin 3) :
    nf_eval_nf M 0 1 (fun _ => env k) (kvE2_sepProj3 r k) := by
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
      atom_eval M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) at4 ↔ σ.1 at4 = true)
    (i : Fin 3) (hbit : (nf0_zoneSpec σ.1 i).1 = true) :
    a < (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) i := by
  have h1 := hσa (.order 0 i.succ (Fin.succ_ne_zero i).symm)
  simp only [atom_eval, Fin.cons_zero, Fin.cons_succ] at h1
  exact h1.mpr hbit

/-- Ordering-channel fact (positive right bit): the fresh witness sits ABOVE env point
    `i`. -/
private theorem kvE2_sepZoneFact_gt {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (a w x t : M.carrier)
    (σ : NormalForm sig 1 4)
    (hσa : ∀ at4 : AtomKind sig 4,
      atom_eval M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) at4 ↔ σ.1 at4 = true)
    (i : Fin 3) (hbit : (nf0_zoneSpec σ.1 i).2 = true) :
    (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) i < a := by
  have h1 := hσa (.order i.succ 0 (Fin.succ_ne_zero i))
  simp only [atom_eval, Fin.cons_zero, Fin.cons_succ] at h1
  exact h1.mpr hbit

/-- Ordering-channel fact (negative left bit): the fresh witness is NOT below env point
    `i` (self-zone/boundary extraction seed). -/
private theorem kvE2_sepZoneFact_not_lt {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (a w x t : M.carrier)
    (σ : NormalForm sig 1 4)
    (hσa : ∀ at4 : AtomKind sig 4,
      atom_eval M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) at4 ↔ σ.1 at4 = true)
    (i : Fin 3) (hbit : (nf0_zoneSpec σ.1 i).1 = false) :
    ¬ a < (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) i := by
  have h1 := hσa (.order 0 i.succ (Fin.succ_ne_zero i).symm)
  simp only [atom_eval, Fin.cons_zero, Fin.cons_succ] at h1
  exact fun hc => Bool.noConfusion ((h1.mp hc).symm.trans hbit)

/-- Ordering-channel fact (negative right bit): the fresh witness is NOT above env point
    `i`. -/
private theorem kvE2_sepZoneFact_not_gt {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (a w x t : M.carrier)
    (σ : NormalForm sig 1 4)
    (hσa : ∀ at4 : AtomKind sig 4,
      atom_eval M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) at4 ↔ σ.1 at4 = true)
    (i : Fin 3) (hbit : (nf0_zoneSpec σ.1 i).2 = false) :
    ¬ (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) i < a := by
  have h1 := hσa (.order i.succ 0 (Fin.succ_ne_zero i))
  simp only [atom_eval, Fin.cons_zero, Fin.cons_succ] at h1
  exact fun hc => Bool.noConfusion ((h1.mp hc).symm.trans hbit)

/-- `kvE2_sepHasPos` introduction from an honest realization: a point `s` realizing the
    depth-1 arity-1 type `χ` whose characteristic owner lands in outer class `zs` marks the
    class bit positive (the σ-level literal driver, completeness direction). -/
private theorem kvE2_sepHasPos_of_realized {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig)
    (w x t s : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (zs : ZoneSpec 3)
    (hzs : nf0_zoneSpec (nf_characteristic M 1 4
        (Fin.cons s (Fin.cons w (Fin.cons x (fun _ => t))))).1 = zs)
    (χ : NormalForm sig 1 1)
    (hχ : nf_eval_nf M 1 1 (fun _ => s) χ) :
    kvE2_sepHasPos qnf zs χ = true := by
  have hreal := nf_characteristic_satisfies M 1 4
    (Fin.cons s (Fin.cons w (Fin.cons x (fun _ => t))))
  have hbit : qnf.2 (nf_characteristic M 1 4
      (Fin.cons s (Fin.cons w (Fin.cons x (fun _ => t))))) = true :=
    (h.2 _).mp ⟨s, hreal⟩
  have hproj : nfk_projFresh (nf_characteristic M 1 4
      (Fin.cons s (Fin.cons w (Fin.cons x (fun _ => t))))) = χ :=
    nf_eval_unique M 1 1 (fun _ => s) _ _
      (kvE2_sepProjFresh_eval M _ s _ hreal) hχ
  rw [kvE2_sepHasPos, List.any_eq_true]
  refine ⟨_, ?_, decide_eq_true hproj⟩
  rw [kvE2_sepPosIn, List.mem_filter]
  refine ⟨?_, decide_eq_true hzs⟩
  rw [kvE2_sepPos, List.mem_filter]
  exact ⟨Finset.mem_toList.mpr (Finset.mem_univ _), hbit⟩

/-- `kvE2_sepHasPos` elimination under an honest realization: a positive class bit yields
    a realized owner in that class whose fresh projection IS `χ`, realized at the owner's
    honest witness point. -/
private theorem kvE2_sepHasPos_witness {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig)
    (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (zs : ZoneSpec 3) (χ : NormalForm sig 1 1)
    (hb : kvE2_sepHasPos qnf zs χ = true) :
    ∃ (σ : NormalForm sig 1 4) (s : M.carrier),
      nf0_zoneSpec σ.1 = zs ∧
      nf_eval_nf M 1 4 (Fin.cons s (Fin.cons w (Fin.cons x (fun _ => t)))) σ ∧
      nf_eval_nf M 1 1 (fun _ => s) χ := by
  rw [kvE2_sepHasPos, List.any_eq_true] at hb
  obtain ⟨σ, hσmem, hproj⟩ := hb
  have hzone : nf0_zoneSpec σ.1 = zs :=
    of_decide_eq_true (List.mem_filter.mp hσmem).2
  have hbit : qnf.2 σ = true :=
    (List.mem_filter.mp (List.mem_filter.mp hσmem).1).2
  obtain ⟨s, hs⟩ := (h.2 σ).mpr hbit
  refine ⟨σ, s, hzone, hs, ?_⟩
  have hpf := kvE2_sepProjFresh_eval M _ s σ hs
  rwa [of_decide_eq_true hproj] at hpf

/-! ### σ-level (outer-class) literal honesty — the five `kvE2_sepHasPos` families

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
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      temporal_truth M atomMap u (charK χ) ↔ nf_eval_nf M 1 1 (fun _ => u) χ)
    (χ : NormalForm sig 1 1) :
    temporal_truth M atomMap x
      (kvE2_sepLit (kvE2_sepHasPos qnf kvE2_sep_zPastX3 χ)
        (Formula.snce (charK χ) Formula.top)) := by
  cases hb : kvE2_sepHasPos qnf kvE2_sep_zPastX3 χ with
  | true =>
    change temporal_truth M atomMap x (Formula.snce (charK χ) Formula.top)
    obtain ⟨σ, s, hzone, hs, hχs⟩ := kvE2_sepHasPos_witness qnf M w x t h _ χ hb
    obtain ⟨hσ_atom, -, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
    have hsx := kvE2_sepZoneFact_lt M s w x t σ hσ_atom ⟨1, by omega⟩
      (by rw [congrFun hzone ⟨1, by omega⟩]; decide)
    exact ⟨s, hsx, (hck χ s).mpr hχs, fun r _ _ hf => hf⟩
  | false =>
    change temporal_truth M atomMap x (Formula.snce (charK χ) Formula.top).neg
    rintro ⟨s, hsx, hsχ, -⟩
    have hz := kvE2_sepCharZone3 M s w x t (true, false) (true, false) (true, false)
      (iff_of_true (hsx.trans hxw) rfl)
      (iff_of_false (lt_asymm (hsx.trans hxw)) (by decide))
      (iff_of_true hsx rfl) (iff_of_false (lt_asymm hsx) (by decide))
      (iff_of_true (hsx.trans (hxw.trans hwt)) rfl)
      (iff_of_false (lt_asymm (hsx.trans (hxw.trans hwt))) (by decide))
    have hpos := kvE2_sepHasPos_of_realized qnf M w x t s h kvE2_sep_zPastX3 hz χ
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
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      temporal_truth M atomMap u (charK χ) ↔ nf_eval_nf M 1 1 (fun _ => u) χ)
    (χ : NormalForm sig 1 1) :
    temporal_truth M atomMap x
      (kvE2_sepLit (kvE2_sepHasPos qnf kvE2_sep_zAtX3 χ) (charK χ)) := by
  cases hb : kvE2_sepHasPos qnf kvE2_sep_zAtX3 χ with
  | true =>
    change temporal_truth M atomMap x (charK χ)
    obtain ⟨σ, s, hzone, hs, hχs⟩ := kvE2_sepHasPos_witness qnf M w x t h _ χ hb
    obtain ⟨hσ_atom, -, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
    have hnsx := kvE2_sepZoneFact_not_lt M s w x t σ hσ_atom ⟨1, by omega⟩
      (by rw [congrFun hzone ⟨1, by omega⟩]; decide)
    have hnxs := kvE2_sepZoneFact_not_gt M s w x t σ hσ_atom ⟨1, by omega⟩
      (by rw [congrFun hzone ⟨1, by omega⟩]; decide)
    have hseq : s = x := le_antisymm (not_lt.mp hnxs) (not_lt.mp hnsx)
    exact (hck χ x).mpr (hseq ▸ hχs)
  | false =>
    change temporal_truth M atomMap x (charK χ).neg
    intro hch
    have hz := kvE2_sepCharZone3 M x w x t (true, false) (false, false) (true, false)
      (iff_of_true hxw rfl) (iff_of_false (lt_asymm hxw) (by decide))
      (iff_of_false (lt_irrefl x) (by decide)) (iff_of_false (lt_irrefl x) (by decide))
      (iff_of_true (hxw.trans hwt) rfl)
      (iff_of_false (lt_asymm (hxw.trans hwt)) (by decide))
    have hpos := kvE2_sepHasPos_of_realized qnf M w x t x h kvE2_sep_zAtX3 hz χ
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
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      temporal_truth M atomMap u (charK χ) ↔ nf_eval_nf M 1 1 (fun _ => u) χ)
    (χ : NormalForm sig 1 1) :
    temporal_truth M atomMap w
      (kvE2_sepLit (kvE2_sepHasPos qnf kvE2_sep_zAtW3 χ) (charK χ)) := by
  cases hb : kvE2_sepHasPos qnf kvE2_sep_zAtW3 χ with
  | true =>
    change temporal_truth M atomMap w (charK χ)
    obtain ⟨σ, s, hzone, hs, hχs⟩ := kvE2_sepHasPos_witness qnf M w x t h _ χ hb
    obtain ⟨hσ_atom, -, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
    have hnsw := kvE2_sepZoneFact_not_lt M s w x t σ hσ_atom ⟨0, by omega⟩
      (by rw [congrFun hzone ⟨0, by omega⟩]; decide)
    have hnws := kvE2_sepZoneFact_not_gt M s w x t σ hσ_atom ⟨0, by omega⟩
      (by rw [congrFun hzone ⟨0, by omega⟩]; decide)
    have hseq : s = w := le_antisymm (not_lt.mp hnws) (not_lt.mp hnsw)
    exact (hck χ w).mpr (hseq ▸ hχs)
  | false =>
    change temporal_truth M atomMap w (charK χ).neg
    intro hch
    have hz := kvE2_sepCharZone3 M w w x t (false, false) (false, true) (true, false)
      (iff_of_false (lt_irrefl w) (by decide)) (iff_of_false (lt_irrefl w) (by decide))
      (iff_of_false (lt_asymm hxw) (by decide)) (iff_of_true hxw rfl)
      (iff_of_true hwt rfl) (iff_of_false (lt_asymm hwt) (by decide))
    have hpos := kvE2_sepHasPos_of_realized qnf M w x t w h kvE2_sep_zAtW3 hz χ
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
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      temporal_truth M atomMap u (charK χ) ↔ nf_eval_nf M 1 1 (fun _ => u) χ)
    (χ : NormalForm sig 1 1) :
    temporal_truth M atomMap t
      (kvE2_sepLit (kvE2_sepHasPos qnf kvE2_sep_zAtT3 χ) (charK χ)) := by
  cases hb : kvE2_sepHasPos qnf kvE2_sep_zAtT3 χ with
  | true =>
    change temporal_truth M atomMap t (charK χ)
    obtain ⟨σ, s, hzone, hs, hχs⟩ := kvE2_sepHasPos_witness qnf M w x t h _ χ hb
    obtain ⟨hσ_atom, -, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
    have hnst := kvE2_sepZoneFact_not_lt M s w x t σ hσ_atom ⟨2, by omega⟩
      (by rw [congrFun hzone ⟨2, by omega⟩]; decide)
    have hnts := kvE2_sepZoneFact_not_gt M s w x t σ hσ_atom ⟨2, by omega⟩
      (by rw [congrFun hzone ⟨2, by omega⟩]; decide)
    have hseq : s = t := le_antisymm (not_lt.mp hnts) (not_lt.mp hnst)
    exact (hck χ t).mpr (hseq ▸ hχs)
  | false =>
    change temporal_truth M atomMap t (charK χ).neg
    intro hch
    have hz := kvE2_sepCharZone3 M t w x t (false, true) (false, true) (false, false)
      (iff_of_false (lt_asymm hwt) (by decide)) (iff_of_true hwt rfl)
      (iff_of_false (lt_asymm (hxw.trans hwt)) (by decide))
      (iff_of_true (hxw.trans hwt) rfl)
      (iff_of_false (lt_irrefl t) (by decide)) (iff_of_false (lt_irrefl t) (by decide))
    have hpos := kvE2_sepHasPos_of_realized qnf M w x t t h kvE2_sep_zAtT3 hz χ
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
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      temporal_truth M atomMap u (charK χ) ↔ nf_eval_nf M 1 1 (fun _ => u) χ)
    (χ : NormalForm sig 1 1) :
    temporal_truth M atomMap t
      (kvE2_sepLit (kvE2_sepHasPos qnf kvE2_sep_zFutT3 χ)
        (Formula.untl (charK χ) Formula.top)) := by
  cases hb : kvE2_sepHasPos qnf kvE2_sep_zFutT3 χ with
  | true =>
    change temporal_truth M atomMap t (Formula.untl (charK χ) Formula.top)
    obtain ⟨σ, s, hzone, hs, hχs⟩ := kvE2_sepHasPos_witness qnf M w x t h _ χ hb
    obtain ⟨hσ_atom, -, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
    have hts := kvE2_sepZoneFact_gt M s w x t σ hσ_atom ⟨2, by omega⟩
      (by rw [congrFun hzone ⟨2, by omega⟩]; decide)
    exact ⟨s, hts, (hck χ s).mpr hχs, fun r _ _ hf => hf⟩
  | false =>
    change temporal_truth M atomMap t (Formula.untl (charK χ) Formula.top).neg
    rintro ⟨s, hts, hsχ, -⟩
    have hz := kvE2_sepCharZone3 M s w x t (false, true) (false, true) (false, true)
      (iff_of_false (lt_asymm (hwt.trans hts)) (by decide))
      (iff_of_true (hwt.trans hts) rfl)
      (iff_of_false (lt_asymm (hxw.trans (hwt.trans hts))) (by decide))
      (iff_of_true (hxw.trans (hwt.trans hts)) rfl)
      (iff_of_false (lt_asymm hts) (by decide)) (iff_of_true hts rfl)
    have hpos := kvE2_sepHasPos_of_realized qnf M w x t s h kvE2_sep_zFutT3 hz χ
      ((hck χ s).mp hsχ)
    rw [hb] at hpos
    exact Bool.noConfusion hpos

/-! ### Per-owner (inner-zone) literal honesty — the six `kvE2_sepBits` families

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
    (hs : nf_eval_nf M 1 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (χ : NormalForm sig 0 1) :
    temporal_truth M atomMap x
      (kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zPastX4 χ)
        (Formula.snce (charBase χ) Formula.top)) := by
  obtain ⟨-, h_zone, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
  cases hb : kvE2_sepBits σ kvE2_sep_zPastX4 χ with
  | true =>
    change temporal_truth M atomMap x (Formula.snce (charBase χ) Formula.top)
    obtain ⟨v, hz, hv⟩ := (h_zone kvE2_sep_zPastX4 χ).mpr hb
    obtain ⟨h0, h1, h2, h3⟩ := (kvE2_sepZone4_iff M a w x t v
      (true, false) (true, false) (true, false) (true, false)).mp hz
    exact ⟨v, h2.1.mpr rfl, (hcb χ v).mpr hv, fun r _ _ hf => hf⟩
  | false =>
    change temporal_truth M atomMap x (Formula.snce (charBase χ) Formula.top).neg
    rintro ⟨s, hsx, hsχ, -⟩
    have hz : zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t))))
        kvE2_sep_zPastX4 s := by
      refine (kvE2_sepZone4_iff M a w x t s
        (true, false) (true, false) (true, false) (true, false)).mpr ?_
      exact ⟨⟨iff_of_true (hsx.trans hxa) rfl,
          iff_of_false (lt_asymm (hsx.trans hxa)) (by decide)⟩,
        ⟨iff_of_true (hsx.trans hxw) rfl,
          iff_of_false (lt_asymm (hsx.trans hxw)) (by decide)⟩,
        ⟨iff_of_true hsx rfl, iff_of_false (lt_asymm hsx) (by decide)⟩,
        ⟨iff_of_true (hsx.trans hxt) rfl,
          iff_of_false (lt_asymm (hsx.trans hxt)) (by decide)⟩⟩
    have hbit : kvE2_sepBits σ kvE2_sep_zPastX4 χ = true :=
      (h_zone kvE2_sep_zPastX4 χ).mp ⟨s, hz, (hcb χ s).mp hsχ⟩
    rw [hb] at hbit
    exact Bool.noConfusion hbit

/-- `zAtX4` at-literal honesty at `x` (per interior owner). -/
private theorem kvE2_sepOwnerLit_zAtX4 {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (σ : NormalForm sig 1 4) (a w x t : M.carrier)
    (hxa : x < a) (hxw : x < w) (hxt : x < t)
    (hs : nf_eval_nf M 1 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (χ : NormalForm sig 0 1) :
    temporal_truth M atomMap x
      (kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zAtX4 χ) (charBase χ)) := by
  obtain ⟨-, h_zone, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
  cases hb : kvE2_sepBits σ kvE2_sep_zAtX4 χ with
  | true =>
    change temporal_truth M atomMap x (charBase χ)
    obtain ⟨v, hz, hv⟩ := (h_zone kvE2_sep_zAtX4 χ).mpr hb
    obtain ⟨h0, h1, h2, h3⟩ := (kvE2_sepZone4_iff M a w x t v
      (true, false) (true, false) (false, false) (true, false)).mp hz
    have hveq : v = x := le_antisymm
      (not_lt.mp (fun hc => Bool.noConfusion (h2.2.mp hc)))
      (not_lt.mp (fun hc => Bool.noConfusion (h2.1.mp hc)))
    exact (hcb χ x).mpr (hveq ▸ hv)
  | false =>
    change temporal_truth M atomMap x (charBase χ).neg
    intro hch
    have hz : zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t))))
        kvE2_sep_zAtX4 x := by
      refine (kvE2_sepZone4_iff M a w x t x
        (true, false) (true, false) (false, false) (true, false)).mpr ?_
      exact ⟨⟨iff_of_true hxa rfl, iff_of_false (lt_asymm hxa) (by decide)⟩,
        ⟨iff_of_true hxw rfl, iff_of_false (lt_asymm hxw) (by decide)⟩,
        ⟨iff_of_false (lt_irrefl x) (by decide), iff_of_false (lt_irrefl x) (by decide)⟩,
        ⟨iff_of_true hxt rfl, iff_of_false (lt_asymm hxt) (by decide)⟩⟩
    have hbit : kvE2_sepBits σ kvE2_sep_zAtX4 χ = true :=
      (h_zone kvE2_sep_zAtX4 χ).mp ⟨x, hz, (hcb χ x).mp hch⟩
    rw [hb] at hbit
    exact Bool.noConfusion hbit

/-- `zAtT4` at-literal honesty at `t` (per interior owner). -/
private theorem kvE2_sepOwnerLit_zAtT4 {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (σ : NormalForm sig 1 4) (a w x t : M.carrier)
    (hat : a < t) (hwt : w < t) (hxt : x < t)
    (hs : nf_eval_nf M 1 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (χ : NormalForm sig 0 1) :
    temporal_truth M atomMap t
      (kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zAtT4 χ) (charBase χ)) := by
  obtain ⟨-, h_zone, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
  cases hb : kvE2_sepBits σ kvE2_sep_zAtT4 χ with
  | true =>
    change temporal_truth M atomMap t (charBase χ)
    obtain ⟨v, hz, hv⟩ := (h_zone kvE2_sep_zAtT4 χ).mpr hb
    obtain ⟨h0, h1, h2, h3⟩ := (kvE2_sepZone4_iff M a w x t v
      (false, true) (false, true) (false, true) (false, false)).mp hz
    have hveq : v = t := le_antisymm
      (not_lt.mp (fun hc => Bool.noConfusion (h3.2.mp hc)))
      (not_lt.mp (fun hc => Bool.noConfusion (h3.1.mp hc)))
    exact (hcb χ t).mpr (hveq ▸ hv)
  | false =>
    change temporal_truth M atomMap t (charBase χ).neg
    intro hch
    have hz : zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t))))
        kvE2_sep_zAtT4 t := by
      refine (kvE2_sepZone4_iff M a w x t t
        (false, true) (false, true) (false, true) (false, false)).mpr ?_
      exact ⟨⟨iff_of_false (lt_asymm hat) (by decide), iff_of_true hat rfl⟩,
        ⟨iff_of_false (lt_asymm hwt) (by decide), iff_of_true hwt rfl⟩,
        ⟨iff_of_false (lt_asymm hxt) (by decide), iff_of_true hxt rfl⟩,
        ⟨iff_of_false (lt_irrefl t) (by decide), iff_of_false (lt_irrefl t) (by decide)⟩⟩
    have hbit : kvE2_sepBits σ kvE2_sep_zAtT4 χ = true :=
      (h_zone kvE2_sep_zAtT4 χ).mp ⟨t, hz, (hcb χ t).mp hch⟩
    rw [hb] at hbit
    exact Bool.noConfusion hbit

/-- `zFutT4` Until-literal honesty at `t` (per interior owner). -/
private theorem kvE2_sepOwnerLit_zFutT4 {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (σ : NormalForm sig 1 4) (a w x t : M.carrier)
    (hat : a < t) (hwt : w < t) (hxt : x < t)
    (hs : nf_eval_nf M 1 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (χ : NormalForm sig 0 1) :
    temporal_truth M atomMap t
      (kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zFutT4 χ)
        (Formula.untl (charBase χ) Formula.top)) := by
  obtain ⟨-, h_zone, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
  cases hb : kvE2_sepBits σ kvE2_sep_zFutT4 χ with
  | true =>
    change temporal_truth M atomMap t (Formula.untl (charBase χ) Formula.top)
    obtain ⟨v, hz, hv⟩ := (h_zone kvE2_sep_zFutT4 χ).mpr hb
    obtain ⟨h0, h1, h2, h3⟩ := (kvE2_sepZone4_iff M a w x t v
      (false, true) (false, true) (false, true) (false, true)).mp hz
    exact ⟨v, h3.2.mpr rfl, (hcb χ v).mpr hv, fun r _ _ hf => hf⟩
  | false =>
    change temporal_truth M atomMap t (Formula.untl (charBase χ) Formula.top).neg
    rintro ⟨s, hts, hsχ, -⟩
    have hz : zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t))))
        kvE2_sep_zFutT4 s := by
      refine (kvE2_sepZone4_iff M a w x t s
        (false, true) (false, true) (false, true) (false, true)).mpr ?_
      exact ⟨⟨iff_of_false (lt_asymm (hat.trans hts)) (by decide),
          iff_of_true (hat.trans hts) rfl⟩,
        ⟨iff_of_false (lt_asymm (hwt.trans hts)) (by decide),
          iff_of_true (hwt.trans hts) rfl⟩,
        ⟨iff_of_false (lt_asymm (hxt.trans hts)) (by decide),
          iff_of_true (hxt.trans hts) rfl⟩,
        ⟨iff_of_false (lt_asymm hts) (by decide), iff_of_true hts rfl⟩⟩
    have hbit : kvE2_sepBits σ kvE2_sep_zFutT4 χ = true :=
      (h_zone kvE2_sep_zFutT4 χ).mp ⟨s, hz, (hcb χ s).mp hsχ⟩
    rw [hb] at hbit
    exact Bool.noConfusion hbit

/-- `zAtWL` pivot-literal honesty at `w` (LEFT-interior owner, `a < w`). -/
private theorem kvE2_sepOwnerLit_zAtWL {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (σ : NormalForm sig 1 4) (a w x t : M.carrier)
    (haw : a < w) (hxw : x < w) (hwt : w < t)
    (hs : nf_eval_nf M 1 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (χ : NormalForm sig 0 1) :
    temporal_truth M atomMap w
      (kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zAtWL χ) (charBase χ)) := by
  obtain ⟨-, h_zone, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
  cases hb : kvE2_sepBits σ kvE2_sep_zAtWL χ with
  | true =>
    change temporal_truth M atomMap w (charBase χ)
    obtain ⟨v, hz, hv⟩ := (h_zone kvE2_sep_zAtWL χ).mpr hb
    obtain ⟨h0, h1, h2, h3⟩ := (kvE2_sepZone4_iff M a w x t v
      (false, true) (false, false) (false, true) (true, false)).mp hz
    have hveq : v = w := le_antisymm
      (not_lt.mp (fun hc => Bool.noConfusion (h1.2.mp hc)))
      (not_lt.mp (fun hc => Bool.noConfusion (h1.1.mp hc)))
    exact (hcb χ w).mpr (hveq ▸ hv)
  | false =>
    change temporal_truth M atomMap w (charBase χ).neg
    intro hch
    have hz : zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t))))
        kvE2_sep_zAtWL w := by
      refine (kvE2_sepZone4_iff M a w x t w
        (false, true) (false, false) (false, true) (true, false)).mpr ?_
      exact ⟨⟨iff_of_false (lt_asymm haw) (by decide), iff_of_true haw rfl⟩,
        ⟨iff_of_false (lt_irrefl w) (by decide), iff_of_false (lt_irrefl w) (by decide)⟩,
        ⟨iff_of_false (lt_asymm hxw) (by decide), iff_of_true hxw rfl⟩,
        ⟨iff_of_true hwt rfl, iff_of_false (lt_asymm hwt) (by decide)⟩⟩
    have hbit : kvE2_sepBits σ kvE2_sep_zAtWL χ = true :=
      (h_zone kvE2_sep_zAtWL χ).mp ⟨w, hz, (hcb χ w).mp hch⟩
    rw [hb] at hbit
    exact Bool.noConfusion hbit

/-- `zAtWR` pivot-literal honesty at `w` (RIGHT-interior owner, `w < a`). -/
private theorem kvE2_sepOwnerLit_zAtWR {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (σ : NormalForm sig 1 4) (a w x t : M.carrier)
    (hwa : w < a) (hxw : x < w) (hwt : w < t)
    (hs : nf_eval_nf M 1 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (χ : NormalForm sig 0 1) :
    temporal_truth M atomMap w
      (kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zAtWR χ) (charBase χ)) := by
  obtain ⟨-, h_zone, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
  cases hb : kvE2_sepBits σ kvE2_sep_zAtWR χ with
  | true =>
    change temporal_truth M atomMap w (charBase χ)
    obtain ⟨v, hz, hv⟩ := (h_zone kvE2_sep_zAtWR χ).mpr hb
    obtain ⟨h0, h1, h2, h3⟩ := (kvE2_sepZone4_iff M a w x t v
      (true, false) (false, false) (false, true) (true, false)).mp hz
    have hveq : v = w := le_antisymm
      (not_lt.mp (fun hc => Bool.noConfusion (h1.2.mp hc)))
      (not_lt.mp (fun hc => Bool.noConfusion (h1.1.mp hc)))
    exact (hcb χ w).mpr (hveq ▸ hv)
  | false =>
    change temporal_truth M atomMap w (charBase χ).neg
    intro hch
    have hz : zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t))))
        kvE2_sep_zAtWR w := by
      refine (kvE2_sepZone4_iff M a w x t w
        (true, false) (false, false) (false, true) (true, false)).mpr ?_
      exact ⟨⟨iff_of_true hwa rfl, iff_of_false (lt_asymm hwa) (by decide)⟩,
        ⟨iff_of_false (lt_irrefl w) (by decide), iff_of_false (lt_irrefl w) (by decide)⟩,
        ⟨iff_of_false (lt_asymm hxw) (by decide), iff_of_true hxw rfl⟩,
        ⟨iff_of_true hwt rfl, iff_of_false (lt_asymm hwt) (by decide)⟩⟩
    have hbit : kvE2_sepBits σ kvE2_sep_zAtWR χ = true :=
      (h_zone kvE2_sep_zAtWR χ).mp ⟨w, hz, (hcb χ w).mp hch⟩
    rw [hb] at hbit
    exact Bool.noConfusion hbit

/-- **Left-endpoint honesty**): under an honest evaluation `h`, the
    EXISTING joint left endpoint predicate `kvE2_sepEpL` evaluates at the fixed `x`.
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
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      temporal_truth M atomMap u (charK χ) ↔ nf_eval_nf M 1 1 (fun _ => u) χ) :
    (kvE2_sepEpL charBase charK qnf).eval_at M atomMap x := by
  simp only [kvE2_sepEpL, TemporalPred.eval_at]
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
    have hσzone : nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3 := by
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
    EXISTING shared interior-witness point type `kvE2_sepPtW` evaluates at the pivot `w`.
    The `zAtW3` class and the per-owner `zAtWL`/`zAtWR` self-zone literals are the pivot's
    boundary content (Rabinovich §5, p.7, via Prop 3.5, pp.5,7); positive bits are the σ_w
    route of `kvE2_sepHonest_hLR_absurd`, now an obligation instead of a contradiction. -/
theorem kvE2_sepPtW_eval_of_honest {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      temporal_truth M atomMap u (charK χ) ↔ nf_eval_nf M 1 1 (fun _ => u) χ) :
    (kvE2_sepPtW charBase charK qnf).eval_at M atomMap w := by
  simp only [kvE2_sepPtW, TemporalPred.eval_at]
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
      have hzone : nf0_zoneSpec σ.1 = kvE2_sep_zXW3 :=
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
    have hzone : nf0_zoneSpec σ.1 = kvE2_sep_zWT3 :=
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
    right endpoint predicate `kvE2_sepEpR` evaluates at the fixed `t`. `zAtT3`/`zFutT3`
    classes and per-owner `zAtT4`/`zFutT4` content ride the at-`t` and `Until` literals
    (Rabinovich §5, p.7, via Prop 3.5, pp.5,7). -/
theorem kvE2_sepEpR_eval_of_honest {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      temporal_truth M atomMap u (charK χ) ↔ nf_eval_nf M 1 1 (fun _ => u) χ) :
    (kvE2_sepEpR charBase charK qnf).eval_at M atomMap t := by
  simp only [kvE2_sepEpR, TemporalPred.eval_at]
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
    have hσzone : nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3 := by
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

/-! ### Primed tie-reporting order bridge + value-sortedness

The target `.holds` builder consumes the GROUPED tie-classes of the PRIMED order
`kvE2_sepHonestOrder'`, whose payload is the tie-REPORTING value-only rank
`kvE2_sepSlotHonestVIdx` (vs the unprimed order's tie-BREAKING `kvE2_sepSlotHonestGIdx`).
The banked value-sortedness (`kvE2_sepSlotsLOf_honest_valueSorted`, SW:4157) is stated for the
unprimed order only. These lemmas re-establish the merge-key bridge, monotonicity, and
value-nondecreasing sortedness for the PRIMED slot lists, mirroring SW:3995/4047/4157 verbatim
with the VIdx payload. Additive; no landed asset touched. -/

/-- **Primed halign bridge**: under the tie-reporting honest order
    `kvE2_sepHonestOrder'`, the mergeSort key reader `kvE2_sepSlotGIdx` coincides with the
    tie-reporting value-only index `kvE2_sepSlotHonestVIdx` on every slot of every positive
    owner's block. Verbatim mirror of `kvE2_sepSlotGIdx_honestOrder` (SW:3995) with the VIdx
    payload. -/
theorem kvE2_sepSlotGIdx_honestOrder' {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf)
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2_sepSlotBlock σ) :
    kvE2_sepSlotGIdx (kvE2_sepHonestOrder' qnf M w x t h) s
      = kvE2_sepSlotHonestVIdx qnf M w x t h s := by
  have hsub : kvE2_sepSlotSub s = σ := kvE2_sepSlotSub_of_mem_block hs
  have hfind : (kvE2_sepHonestOrder' qnf M w x t h).find?
        (fun p => decide (p.1 = kvE2_sepSlotSub s))
      = some (σ, KvE2SepSpikeOrderType.coincident,
          (kvE2_sepSlotBlock σ).map (kvE2_sepSlotHonestVIdx qnf M w x t h)) := by
    rw [hsub, kvE2_sepHonestOrder', List.find?_map]
    have hex : ∃ q ∈ (kvE2_sepPosI qnf).zipIdx,
        ((fun p => decide (p.1 = σ)) ∘
          (fun p : NormalForm sig 1 4 × ℕ =>
            (p.1, KvE2SepSpikeOrderType.coincident,
              (kvE2_sepSlotBlock p.1).map (kvE2_sepSlotHonestVIdx qnf M w x t h)))) q = true := by
      have hm : σ ∈ (kvE2_sepPosI qnf).zipIdx.map Prod.fst := by
        rw [List.zipIdx_map_fst]; exact kvE2_sepMem_posI_of_slot hσ hs
      obtain ⟨q, hq, hq1⟩ := List.mem_map.mp hm
      exact ⟨q, hq, by simp [Function.comp, hq1]⟩
    obtain ⟨q, hq, hqp⟩ := hex
    cases hf : (kvE2_sepPosI qnf).zipIdx.find?
        ((fun p => decide (p.1 = σ)) ∘
          (fun p : NormalForm sig 1 4 × ℕ =>
            (p.1, KvE2SepSpikeOrderType.coincident,
              (kvE2_sepSlotBlock p.1).map (kvE2_sepSlotHonestVIdx qnf M w x t h)))) with
    | none =>
      rw [List.find?_eq_none] at hf
      exact absurd hqp (by simpa using hf q hq)
    | some r =>
      have hr := List.find?_some hf
      simp only [Function.comp, decide_eq_true_eq] at hr
      simp [hr]
  unfold kvE2_sepSlotGIdx
  rw [hfind]
  simp only [Option.map_some, Option.getD_some]
  have hidx : kvE2_sepBlockPos s = (kvE2_sepSlotBlock σ).idxOf s := by
    rw [kvE2_sepBlockPos, hsub]
  rw [hidx]
  have hlt : (kvE2_sepSlotBlock σ).idxOf s < (kvE2_sepSlotBlock σ).length :=
    List.idxOf_lt_length_of_mem hs
  rw [List.getD_eq_getElem?_getD, List.getElem?_map, List.getElem?_eq_getElem hlt]
  simp only [Option.map_some, Option.getD_some]
  congr 1
  exact List.idxOf_get hlt

/-- **Primed halign monotonicity**: on the tie-reporting
    order the mergeSort key `kvE2_sepSlotGIdx` is strictly monotone in the slot value. Mirror of
    `kvE2_sepSlotGIdx_honestOrder_mono` (SW:4047) via the primed bridge +
    `kvE2_sepSlotHonestVIdx_mono`. -/
theorem kvE2_sepSlotGIdx_honestOrder'_mono {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {σ τ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf) (hτ : τ ∈ kvE2_sepPos qnf)
    {a b : KvE2SepSlot sig} (ha : a ∈ kvE2_sepSlotBlock σ) (hb : b ∈ kvE2_sepSlotBlock τ)
    (hlt : kvE2_sepSlotValue qnf M w x t h a < kvE2_sepSlotValue qnf M w x t h b) :
    kvE2_sepSlotGIdx (kvE2_sepHonestOrder' qnf M w x t h) a
      < kvE2_sepSlotGIdx (kvE2_sepHonestOrder' qnf M w x t h) b := by
  rw [kvE2_sepSlotGIdx_honestOrder' qnf M w x t h hσ ha,
      kvE2_sepSlotGIdx_honestOrder' qnf M w x t h hτ hb]
  exact kvE2_sepSlotHonestVIdx_mono qnf M w x t h
    (kvE2_sepMem_allSlots qnf hσ ha) (kvE2_sepMem_allSlots qnf hτ hb) hlt

/-- **Value-sortedness of the joint LEFT list on the tie-reporting order**: the primed
    merged LEFT slot list is `Pairwise` value-nondecreasing. Mirror of
    `kvE2_sepSlotsLOf_honest_valueSorted` (SW:4157) using the primed bridge/monotonicity. -/
theorem kvE2_sepSlotsLOf_honestOrder'_valueSorted {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    (kvE2_sepSlotsLOf (kvE2_sepHonestOrder' qnf M w x t h)).Pairwise
      (fun a b => kvE2_sepSlotValue qnf M w x t h a ≤ kvE2_sepSlotValue qnf M w x t h b) := by
  have hwo : (kvE2_sepHonestOrder' qnf M w x t h).map Prod.fst = kvE2_sepPosI qnf := by
    rw [kvE2_sepHonestOrder', List.map_map]
    exact List.zipIdx_map_fst 0 _
  refine (kvE2_sepSlotsLOf_mergeSorted _).imp_of_mem ?_
  intro a b ha hb hab
  obtain ⟨σ, hσ, haσ⟩ := kvE2_sepSlotsLOf_mem_block hwo ha
  obtain ⟨τ, hτ, hbτ⟩ := kvE2_sepSlotsLOf_mem_block hwo hb
  rw [kvE2_sepSlotMergeLe, decide_eq_true_eq] at hab
  by_contra hlt
  rw [not_le] at hlt
  exact absurd hab (not_le.mpr (kvE2_sepSlotGIdx_honestOrder'_mono qnf M w x t h
    (kvE2_sepPosI_subset hτ) (kvE2_sepPosI_subset hσ) hbτ haσ hlt))

/-- **Value-sortedness of the joint RIGHT list on the tie-reporting order** (mirror). -/
theorem kvE2_sepSlotsROf_honestOrder'_valueSorted {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    (kvE2_sepSlotsROf (kvE2_sepHonestOrder' qnf M w x t h)).Pairwise
      (fun a b => kvE2_sepSlotValue qnf M w x t h a ≤ kvE2_sepSlotValue qnf M w x t h b) := by
  have hwo : (kvE2_sepHonestOrder' qnf M w x t h).map Prod.fst = kvE2_sepPosI qnf := by
    rw [kvE2_sepHonestOrder', List.map_map]
    exact List.zipIdx_map_fst 0 _
  refine (kvE2_sepSlotsROf_mergeSorted _).imp_of_mem ?_
  intro a b ha hb hab
  obtain ⟨σ, hσ, haσ⟩ := kvE2_sepSlotsROf_mem_block hwo ha
  obtain ⟨τ, hτ, hbτ⟩ := kvE2_sepSlotsROf_mem_block hwo hb
  rw [kvE2_sepSlotMergeLe, decide_eq_true_eq] at hab
  by_contra hlt
  rw [not_le] at hlt
  exact absurd hab (not_le.mpr (kvE2_sepSlotGIdx_honestOrder'_mono qnf M w x t h
    (kvE2_sepPosI_subset hτ) (kvE2_sepPosI_subset hσ) hbτ haσ hlt))

/-- **Tie-class key constancy**: every element of a single
    `kvE2_sepTieRuns` class shares the class key. A run only extends when the new head's key
    equals the current run head's, so class members carry one key — unconditionally (no
    sortedness needed). Structural induction mirroring `kvE2_sepTieRuns_ne_nil` (SW:2008). -/
theorem kvE2_sepTieRuns_key_const {α : Type*} (key : α → ℕ) :
    ∀ (l : List α), ∀ c ∈ kvE2_sepTieRuns key l, ∀ u ∈ c, ∀ v ∈ c, key u = key v
  | [] => by simp [kvE2_sepTieRuns]
  | [a] => by
      intro c hc u hu v hv
      rw [kvE2_sepTieRuns] at hc
      simp only [List.mem_singleton] at hc
      subst hc
      simp only [List.mem_singleton] at hu hv
      subst hu; subst hv; rfl
  | a :: b :: rest => by
      have ih := kvE2_sepTieRuns_key_const key (b :: rest)
      obtain ⟨tl, cs, heq⟩ := kvE2_sepTieRuns_shape key rest b
      intro c hc u hu v hv
      rw [kvE2_sepTieRuns, heq] at hc
      by_cases hk : key a = key b
      · simp only [if_pos hk] at hc
        rcases List.mem_cons.mp hc with rfl | hmem
        · have hbrun : ∀ z ∈ (b :: tl), key z = key b := fun z hz =>
            ih (b :: tl) (by rw [heq]; exact List.mem_cons_self) z hz b List.mem_cons_self
          have hall : ∀ z ∈ (a :: b :: tl), key z = key b := by
            intro z hz
            rcases List.mem_cons.mp hz with rfl | hz
            · exact hk
            · exact hbrun z hz
          rw [hall u hu, hall v hv]
        · exact ih c (by rw [heq]; exact List.mem_cons_of_mem _ hmem) u hu v hv
      · simp only [if_neg hk] at hc
        rcases List.mem_cons.mp hc with rfl | hmem
        · simp only [List.mem_singleton] at hu hv
          subst hu; subst hv; rfl
        · exact ih c (by rw [heq]; exact hmem) u hu v hv

/-- **Tie-class key strict monotonicity** (report 14 Q2): on a
    key-sorted list, `kvE2_sepTieRuns` yields runs whose keys STRICTLY increase across distinct
    classes — every member of an earlier class has a strictly smaller key than every member of a
    later class. The maximal-adjacent-run construction plus key-sortedness force the strict jump
    at each class boundary. Structural induction mirroring `kvE2_sepTieRuns_key_const`. -/
theorem kvE2_sepTieRuns_key_strictMono {α : Type*} (key : α → ℕ) :
    ∀ (l : List α), l.Pairwise (fun a b => key a ≤ key b) →
      (kvE2_sepTieRuns key l).Pairwise
        (fun c₁ c₂ => ∀ u ∈ c₁, ∀ v ∈ c₂, key u < key v)
  | [], _ => by simp [kvE2_sepTieRuns]
  | [a], _ => by simp [kvE2_sepTieRuns]
  | a :: b :: rest, hsort => by
      obtain ⟨t, cs, heq⟩ := kvE2_sepTieRuns_shape key rest b
      have hcons := List.pairwise_cons.mp hsort
      have ha : ∀ z ∈ b :: rest, key a ≤ key z := hcons.1
      have hbrest : (b :: rest).Pairwise (fun a b => key a ≤ key b) := hcons.2
      have ih := kvE2_sepTieRuns_key_strictMono key (b :: rest) hbrest
      rw [heq] at ih
      have ihcons := List.pairwise_cons.mp ih
      have hb_le : ∀ z ∈ b :: rest, key b ≤ key z := by
        intro z hz
        rcases List.mem_cons.mp hz with rfl | hz
        · exact le_refl _
        · exact (List.pairwise_cons.mp hbrest).1 z hz
      have hflat : ((b :: t) :: cs).flatten = b :: rest := by
        rw [← heq]; exact kvE2_sepTieRuns_flatten key (b :: rest)
      have hmem_brest : ∀ d ∈ (b :: t) :: cs, ∀ v ∈ d, v ∈ b :: rest := by
        intro d hd v hv
        rw [← hflat]
        exact List.mem_flatten.mpr ⟨d, hd, hv⟩
      rw [kvE2_sepTieRuns, heq]
      by_cases hk : key a = key b
      · simp only [if_pos hk]
        rw [List.pairwise_cons]
        refine ⟨?_, ihcons.2⟩
        intro d hd u hu v hv
        rcases List.mem_cons.mp hu with rfl | hu
        · have hbv : key b < key v := ihcons.1 d hd b List.mem_cons_self v hv
          omega
        · exact ihcons.1 d hd u hu v hv
      · simp only [if_neg hk]
        rw [List.pairwise_cons]
        refine ⟨?_, ih⟩
        intro d hd u hu v hv
        rw [List.mem_singleton] at hu
        have hvmem : v ∈ b :: rest := hmem_brest d hd v hv
        have hab : key a < key b := lt_of_le_of_ne (ha b List.mem_cons_self) hk
        rw [hu]
        exact lt_of_lt_of_le hab (hb_le v hvmem)

/-- **Tie-class index order from strict key order** (Route A, (a)): on a key-sorted
    list, members of distinct tie classes with strictly ordered keys sit in strictly ordered
    classes — the index-level read that replaces the refuted flat-list
    `kvE2_sep_index_lt_of_rank_lt` route for grouped disjuncts. Trichotomy: equal indices are
    refuted by within-class key constancy (`kvE2_sepTieRuns_key_const`), reversed indices by
    cross-class strict key monotonicity (`kvE2_sepTieRuns_key_strictMono` through
    `List.pairwise_iff_getElem`). -/
theorem kvE2_sepTieRuns_classIdx_lt {α : Type*} (key : α → ℕ) (l : List α)
    (hs : l.Pairwise (fun x y => key x ≤ key y))
    {i j : ℕ} (hi : i < (kvE2_sepTieRuns key l).length)
    (hj : j < (kvE2_sepTieRuns key l).length)
    {a b : α} (ha : a ∈ (kvE2_sepTieRuns key l)[i]) (hb : b ∈ (kvE2_sepTieRuns key l)[j])
    (hab : key a < key b) : i < j := by
  rcases Nat.lt_trichotomy i j with hlt | heq | hgt
  · exact hlt
  · exfalso
    subst heq
    have hconst := kvE2_sepTieRuns_key_const key l ((kvE2_sepTieRuns key l)[i])
      (List.getElem_mem hi) a ha b hb
    omega
  · exfalso
    have hstrict := kvE2_sepTieRuns_key_strictMono key l hs
    have hba := List.pairwise_iff_getElem.mp hstrict j i hj hi hgt b hb a ha
    omega

/-- **Route-A tie-admitting grouped extraction**; the grouped analog
    of the flat template `kvE2_sepDisjunct_extract`): from a realized GROUPED disjunct of
    any valid weak order `wo ∈ kvE2_sepArr' qnf`, extract both joint endpoint realizations,
    the ONE shared witness `w` (the `ptW` slot at class position `|gL|`; `x < w < t` from
    the bracket's own range — FM-x1t), and at that same `w` the per-σ witness bundle for
    every positive interior σ of either class. Every point is read through the meet-folded
    class type (`kvE2_sepClassType_eval_mem`: a realized class point realizes EACH member's
    slot type — Def 3.1 conjunction semantics, Rabinovich 2014, p.4), so ties never obstruct
    the read: cross-owner ties merely enlarge a class's meet. Same-owner anchor/base
    separation needs NO cross-owner hypothesis — the strict same-owner key order
    `kvE2_sep_gidx_lt_of_rank_lt` (conjunct (ii) via `kvE2_sepArr'_consistent`) forces the
    `lXU`/`rWX1` slot into a STRICTLY earlier tie class than the `lX1`/`rX1` anchor
    (`kvE2_sepTieRuns_classIdx_lt` at the merge-sorted key order), and bracket monotonicity
    places its witness strictly below the fresh witness. Witness positions are read
    structurally off class indices (Def 3.1 monotone enumeration; §5 interleaving,
    Rabinovich 2014, p.7) — never an `x1 < e_i` literal (LITMUS). -/
theorem kvE2_sepDisjunct'_extract {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    {wo : KvE2SepWeakOrder sig} (hwo : wo ∈ kvE2_sepArr' qnf)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (x t : M.carrier)
    (h : (kvE2_sepDisjunct' charBase charK qnf
        (kvE2_sepTieGroupedL wo) (kvE2_sepTieGroupedR wo)).2.holds M atomMap x t) :
    (kvE2_sepEpL charBase charK qnf).eval_at M atomMap x ∧
    (kvE2_sepEpR charBase charK qnf).eval_at M atomMap t ∧
    ∃ w : M.carrier, x < w ∧ w < t ∧
      (kvE2_sepPtW charBase charK qnf).eval_at M atomMap w ∧
      (∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zXW3 →
        kvE2_sepBundleL charBase charK σ M atomMap w x) ∧
      (∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zWT3 →
        kvE2_sepBundleR charBase charK σ M atomMap w t) := by
  obtain ⟨hepL, hepR, hbr⟩ := h
  refine ⟨hepL, hepR, ?_⟩
  -- Shared wo facts: enumeration membership, owner projection, merge-key sortedness
  -- (Bool merge key → Prop key order, the `simpa`-level bridge).
  have hwo' : wo ∈ kvE2_sepOrderTypes qnf := (List.mem_filter.mp hwo).1
  have howners : wo.map Prod.fst = kvE2_sepPosI qnf := kvE2_sepOrderTypes_owners qnf hwo'
  have hksortL : (kvE2_sepSlotsLOf wo).Pairwise
      (fun a b => kvE2_sepSlotGIdx wo a ≤ kvE2_sepSlotGIdx wo b) := by
    refine (kvE2_sepSlotsLOf_mergeSorted wo).imp ?_
    intro a b hab; rw [kvE2_sepSlotMergeLe, decide_eq_true_eq] at hab; exact hab
  have hksortR : (kvE2_sepSlotsROf wo).Pairwise
      (fun a b => kvE2_sepSlotGIdx wo a ≤ kvE2_sepSlotGIdx wo b) := by
    refine (kvE2_sepSlotsROf_mergeSorted wo).imp ?_
    intro a b hab; rw [kvE2_sepSlotMergeLe, decide_eq_true_eq] at hab; exact hab
  -- Destructure the realized grouped N-slot bracket (Def 3.1 monotone enumeration, p.4;
  -- skeleton transposed from the flat template).
  simp only [kvE2_sepDisjunct', kvE2_sepBracketN, BracketFormula.holds,
    BracketFormula.toIntervalPattern] at hbr
  rw [IntervalPattern.holds_eq_succ M atomMap _ _ x t
    (show ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length + 1
        + ((kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK)).length
      = ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length
        + ((kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK)).length + 1
      by omega)] at hbr
  obtain ⟨ws, hmono, hrange, hpt, -, -, -⟩ := hbr
  -- Canonical point-type reads (defeq re-typing; flat-template pattern).
  have hpt' : ∀ (i : Nat)
      (hi : i < ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length
        + ((kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK)).length + 1),
      (((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)
          ++ kvE2_sepPtW charBase charK qnf
            :: (kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK))[i]'(by
        simp only [List.length_append, List.length_cons]; omega)).eval_at M atomMap
        (ws ⟨i, hi⟩) := fun i hi => hpt ⟨i, hi⟩
  refine ⟨ws ⟨((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length,
      by omega⟩,
    (hrange _).1, (hrange _).2, ?_, ?_, ?_⟩
  · -- The shared `ptW` realization at class position `|gL|` (§5 bracket, p.7).
    have h1 := hpt'
      ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length (by omega)
    rwa [kvE2_sep_getElem_mid] at h1
  · -- LEFT-interior bundles: σ's fresh slot lies in some LEFT tie class.
    intro σ hσpos hzone
    have hσI : σ ∈ kvE2_sepPosI qnf :=
      (kvE2_sepPosI_mem qnf σ).mpr ⟨hσpos, Or.inl hzone⟩
    have hσp : σ ∈ wo.map Prod.fst := by rw [howners]; exact hσI
    obtain ⟨p, hpwo, hp1⟩ := List.mem_map.mp hσp
    have hpe : (σ, p.2.1, p.2.2) ∈ wo := by rw [← hp1]; exact hpwo
    have hmemX1 : (KvE2SepSlot.lX1 σ) ∈ kvE2_sepSlotsLOf wo :=
      kvE2_sepSlotsLOf_mem qnf hwo' hσI (kvE2_sep_lX1_mem_slotsLFor hzone)
    rw [← kvE2_sepTieGroupedL_flatten wo] at hmemX1
    obtain ⟨c, hc, hsc⟩ := List.mem_flatten.mp hmemX1
    obtain ⟨iσ, hiσ, hgetiσ⟩ := List.mem_iff_getElem.mp hc
    have hiσm : iσ
        < ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length := by
      simp only [List.length_map]; omega
    refine ⟨ws ⟨iσ, by omega⟩, (hrange _).1,
      hmono _ _ (Fin.mk_lt_mk.mpr hiσm), ?_, ?_⟩
    · -- σ's folded fresh point type through the class meet (Def 3.1 conjunction, p.4).
      have h1 := hpt' iσ (by omega)
      rw [kvE2_sep_getElem_left _ _ _ iσ hiσm, List.getElem_map, hgetiσ] at h1
      exact kvE2_sepClassType_eval_mem charBase charK M atomMap _ h1 hsc
    · -- Every `zXU`-positive 1-type strictly below the fresh witness: strict same-owner
      -- key order → strictly earlier tie class → bracket monotonicity.
      intro χ hbit
      have hmemU : (KvE2SepSlot.lXU σ χ) ∈ kvE2_sepSlotsLOf wo :=
        kvE2_sepSlotsLOf_mem qnf hwo' hσI (kvE2_sep_lXU_mem_slotsLFor hzone hbit)
      rw [← kvE2_sepTieGroupedL_flatten wo] at hmemU
      obtain ⟨d, hd, hsd⟩ := List.mem_flatten.mp hmemU
      obtain ⟨jχ, hjχ, hgetjχ⟩ := List.mem_iff_getElem.mp hd
      have hkey : kvE2_sepSlotGIdx wo (KvE2SepSlot.lXU σ χ)
          < kvE2_sepSlotGIdx wo (KvE2SepSlot.lX1 σ) :=
        kvE2_sep_gidx_lt_of_rank_lt qnf hwo hpe
          (by rw [kvE2_sepSlotBlock]
              exact List.mem_append_left _ (kvE2_sep_lXU_mem_slotsLFor hzone hbit))
          (by rw [kvE2_sepSlotBlock]
              exact List.mem_append_left _ (kvE2_sep_lX1_mem_slotsLFor hzone))
          rfl Nat.zero_lt_one
      have hain : (KvE2SepSlot.lXU σ χ) ∈ (kvE2_sepTieGroupedL wo)[jχ]'hjχ := by
        rw [hgetjχ]; exact hsd
      have hbin : (KvE2SepSlot.lX1 σ) ∈ (kvE2_sepTieGroupedL wo)[iσ]'hiσ := by
        rw [hgetiσ]; exact hsc
      have hji : jχ < iσ := kvE2_sepTieRuns_classIdx_lt (kvE2_sepSlotGIdx wo)
        (kvE2_sepSlotsLOf wo) hksortL hjχ hiσ hain hbin hkey
      have hjχm : jχ
          < ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length := by
        simp only [List.length_map]; omega
      refine ⟨ws ⟨jχ, by omega⟩, (hrange _).1,
        hmono _ _ (Fin.mk_lt_mk.mpr hji), ?_⟩
      have h1 := hpt' jχ (by omega)
      rw [kvE2_sep_getElem_left _ _ _ jχ hjχm, List.getElem_map, hgetjχ] at h1
      exact kvE2_sepClassType_eval_mem charBase charK M atomMap _ h1 hsd
  · -- RIGHT-interior bundles (mirrored): σ's fresh slot lies in some RIGHT tie class.
    intro σ hσpos hzone
    have hσI : σ ∈ kvE2_sepPosI qnf :=
      (kvE2_sepPosI_mem qnf σ).mpr ⟨hσpos, Or.inr hzone⟩
    have hσp : σ ∈ wo.map Prod.fst := by rw [howners]; exact hσI
    obtain ⟨p, hpwo, hp1⟩ := List.mem_map.mp hσp
    have hpe : (σ, p.2.1, p.2.2) ∈ wo := by rw [← hp1]; exact hpwo
    have hmemX1 : (KvE2SepSlot.rX1 σ) ∈ kvE2_sepSlotsROf wo :=
      kvE2_sepSlotsROf_mem qnf hwo' hσI (kvE2_sep_rX1_mem_slotsRFor hzone)
    rw [← kvE2_sepTieGroupedR_flatten wo] at hmemX1
    obtain ⟨c, hc, hsc⟩ := List.mem_flatten.mp hmemX1
    obtain ⟨jσ, hjσ, hgetjσ⟩ := List.mem_iff_getElem.mp hc
    have hjσm : jσ
        < ((kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK)).length := by
      simp only [List.length_map]; omega
    refine ⟨ws ⟨((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length
        + 1 + jσ, by omega⟩,
      hmono _ _ (Fin.mk_lt_mk.mpr (by omega)), (hrange _).2, ?_, ?_⟩
    · have h1 := hpt'
        (((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length + 1 + jσ)
        (by omega)
      rw [kvE2_sep_getElem_right _ _ _ jσ hjσm, List.getElem_map, hgetjσ] at h1
      exact kvE2_sepClassType_eval_mem charBase charK M atomMap _ h1 hsc
    · intro χ hbit
      have hmemU : (KvE2SepSlot.rWX1 σ χ) ∈ kvE2_sepSlotsROf wo :=
        kvE2_sepSlotsROf_mem qnf hwo' hσI (kvE2_sep_rWX1_mem_slotsRFor hzone hbit)
      rw [← kvE2_sepTieGroupedR_flatten wo] at hmemU
      obtain ⟨d, hd, hsd⟩ := List.mem_flatten.mp hmemU
      obtain ⟨j', hj', hgetj'⟩ := List.mem_iff_getElem.mp hd
      have hkey : kvE2_sepSlotGIdx wo (KvE2SepSlot.rWX1 σ χ)
          < kvE2_sepSlotGIdx wo (KvE2SepSlot.rX1 σ) :=
        kvE2_sep_gidx_lt_of_rank_lt qnf hwo hpe
          (by rw [kvE2_sepSlotBlock]
              exact List.mem_append_right _ (kvE2_sep_rWX1_mem_slotsRFor hzone hbit))
          (by rw [kvE2_sepSlotBlock]
              exact List.mem_append_right _ (kvE2_sep_rX1_mem_slotsRFor hzone))
          rfl Nat.zero_lt_one
      have hain : (KvE2SepSlot.rWX1 σ χ) ∈ (kvE2_sepTieGroupedR wo)[j']'hj' := by
        rw [hgetj']; exact hsd
      have hbin : (KvE2SepSlot.rX1 σ) ∈ (kvE2_sepTieGroupedR wo)[jσ]'hjσ := by
        rw [hgetjσ]; exact hsc
      have hji : j' < jσ := kvE2_sepTieRuns_classIdx_lt (kvE2_sepSlotGIdx wo)
        (kvE2_sepSlotsROf wo) hksortR hj' hjσ hain hbin hkey
      have hj'm : j'
          < ((kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK)).length := by
        simp only [List.length_map]; omega
      refine ⟨ws ⟨((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length
          + 1 + j', by omega⟩,
        hmono _ _ (Fin.mk_lt_mk.mpr (by omega)),
        hmono _ _ (Fin.mk_lt_mk.mpr (by omega)), ?_⟩
      have h1 := hpt'
        (((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length + 1 + j')
        (by omega)
      rw [kvE2_sep_getElem_right _ _ _ j' hj'm, List.getElem_map, hgetj'] at h1
      exact kvE2_sepClassType_eval_mem charBase charK M atomMap _ h1 hsd

/-- **O3 at carrier level — the hypothesis-free Route-A body extraction** (step (d)):
    extraction from any realized `kvE2_sepBody`, with NO universal
    side-conditions — every needed fact derives from the realized disjunct's own carrier
    membership `wo ∈ kvE2_sepArr' qnf` (no gate hypothesis — the gate-failure branch is the
    empty disjunction, whose `holds` is `False`). Routes through the O2 membership collapse
    `kvE2_sepBody_holds_iff` and the tie-admitting grouped extraction
    `kvE2_sepDisjunct'_extract`, which reads per-class witnesses through
    `kvE2_sepClassType_eval_mem` on the GROUPED disjunct — matching the tie-admitting
    carrier design the repair installed (base-base ties deliberately representable).
    The former tie-free singleton-conversion route and its universal `hpairL`/`hpairR`/`hnd`
    side-conditions (FALSE for general `qnf` — the R2 blocker record) are
    eliminated. Def 3.1 single strict witness chain (Rabinovich 2014, p.4); §5 interleaving
    (p.7). -/
theorem kvE2_sepBody_extract {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (x t : M.carrier)
    (h : (kvE2_sepBody charBase charK qnf).holds M atomMap x t) :
    (kvE2_sepEpL charBase charK qnf).eval_at M atomMap x ∧
    (kvE2_sepEpR charBase charK qnf).eval_at M atomMap t ∧
    ∃ w : M.carrier, x < w ∧ w < t ∧
      (kvE2_sepPtW charBase charK qnf).eval_at M atomMap w ∧
      (∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zXW3 →
        kvE2_sepBundleL charBase charK σ M atomMap w x) ∧
      (∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zWT3 →
        kvE2_sepBundleR charBase charK σ M atomMap w t) := by
  by_cases hg : kvE2_sepGate qnf
  · rw [kvE2_sepBody_holds_iff charBase charK qnf hg M atomMap x t] at h
    obtain ⟨wo, hwo, hd⟩ := h
    exact kvE2_sepDisjunct'_extract charBase charK qnf hwo M atomMap x t hd
  · rw [kvE2_sepBody_gate_fail charBase charK qnf hg] at h
    simp [VVecEA2.holds] at h

/-- **One value per LEFT tie class**: all slots of a single
    tie class of the primed grouped LEFT list carry EQUAL honest slot value. Equal keys within
    the class (`kvE2_sepTieRuns_key_const`) become equal honest values through the primed bridge
    + the tie-reporting payload law `kvE2_sepSlotHonestVIdx_eq_iff` (SW:5857). -/
theorem kvE2_sepTieGroupedL_value_const {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {c : List (KvE2SepSlot sig)}
    (hc : c ∈ kvE2_sepTieGroupedL (kvE2_sepHonestOrder' qnf M w x t h))
    {u : KvE2SepSlot sig} (hu : u ∈ c) {v : KvE2SepSlot sig} (hv : v ∈ c) :
    kvE2_sepSlotValue qnf M w x t h u = kvE2_sepSlotValue qnf M w x t h v := by
  have hwo : (kvE2_sepHonestOrder' qnf M w x t h).map Prod.fst = kvE2_sepPosI qnf := by
    rw [kvE2_sepHonestOrder', List.map_map]; exact List.zipIdx_map_fst 0 _
  rw [kvE2_sepTieGroupedL] at hc
  have hkey : kvE2_sepSlotGIdx (kvE2_sepHonestOrder' qnf M w x t h) u
      = kvE2_sepSlotGIdx (kvE2_sepHonestOrder' qnf M w x t h) v :=
    kvE2_sepTieRuns_key_const _ _ c hc u hu v hv
  have huf : u ∈ kvE2_sepSlotsLOf (kvE2_sepHonestOrder' qnf M w x t h) := by
    rw [← kvE2_sepTieGroupedL_flatten (kvE2_sepHonestOrder' qnf M w x t h)]
    rw [kvE2_sepTieGroupedL]
    exact List.mem_flatten.mpr ⟨c, hc, hu⟩
  have hvf : v ∈ kvE2_sepSlotsLOf (kvE2_sepHonestOrder' qnf M w x t h) := by
    rw [← kvE2_sepTieGroupedL_flatten (kvE2_sepHonestOrder' qnf M w x t h)]
    rw [kvE2_sepTieGroupedL]
    exact List.mem_flatten.mpr ⟨c, hc, hv⟩
  obtain ⟨σ, hσ, huσ⟩ := kvE2_sepSlotsLOf_mem_block hwo huf
  obtain ⟨τ, hτ, hvτ⟩ := kvE2_sepSlotsLOf_mem_block hwo hvf
  rw [kvE2_sepSlotGIdx_honestOrder' qnf M w x t h (kvE2_sepPosI_subset hσ) huσ,
      kvE2_sepSlotGIdx_honestOrder' qnf M w x t h (kvE2_sepPosI_subset hτ) hvτ] at hkey
  exact (kvE2_sepSlotHonestVIdx_eq_iff qnf M w x t h
    (kvE2_sepMem_allSlots qnf (kvE2_sepPosI_subset hσ) huσ)
    (kvE2_sepMem_allSlots qnf (kvE2_sepPosI_subset hτ) hvτ)).mp hkey

/-- **One value per RIGHT tie class** (mirror of `kvE2_sepTieGroupedL_value_const`). -/
theorem kvE2_sepTieGroupedR_value_const {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {c : List (KvE2SepSlot sig)}
    (hc : c ∈ kvE2_sepTieGroupedR (kvE2_sepHonestOrder' qnf M w x t h))
    {u : KvE2SepSlot sig} (hu : u ∈ c) {v : KvE2SepSlot sig} (hv : v ∈ c) :
    kvE2_sepSlotValue qnf M w x t h u = kvE2_sepSlotValue qnf M w x t h v := by
  have hwo : (kvE2_sepHonestOrder' qnf M w x t h).map Prod.fst = kvE2_sepPosI qnf := by
    rw [kvE2_sepHonestOrder', List.map_map]; exact List.zipIdx_map_fst 0 _
  rw [kvE2_sepTieGroupedR] at hc
  have hkey : kvE2_sepSlotGIdx (kvE2_sepHonestOrder' qnf M w x t h) u
      = kvE2_sepSlotGIdx (kvE2_sepHonestOrder' qnf M w x t h) v :=
    kvE2_sepTieRuns_key_const _ _ c hc u hu v hv
  have huf : u ∈ kvE2_sepSlotsROf (kvE2_sepHonestOrder' qnf M w x t h) := by
    rw [← kvE2_sepTieGroupedR_flatten (kvE2_sepHonestOrder' qnf M w x t h)]
    rw [kvE2_sepTieGroupedR]
    exact List.mem_flatten.mpr ⟨c, hc, hu⟩
  have hvf : v ∈ kvE2_sepSlotsROf (kvE2_sepHonestOrder' qnf M w x t h) := by
    rw [← kvE2_sepTieGroupedR_flatten (kvE2_sepHonestOrder' qnf M w x t h)]
    rw [kvE2_sepTieGroupedR]
    exact List.mem_flatten.mpr ⟨c, hc, hv⟩
  obtain ⟨σ, hσ, huσ⟩ := kvE2_sepSlotsROf_mem_block hwo huf
  obtain ⟨τ, hτ, hvτ⟩ := kvE2_sepSlotsROf_mem_block hwo hvf
  rw [kvE2_sepSlotGIdx_honestOrder' qnf M w x t h (kvE2_sepPosI_subset hσ) huσ,
      kvE2_sepSlotGIdx_honestOrder' qnf M w x t h (kvE2_sepPosI_subset hτ) hvτ] at hkey
  exact (kvE2_sepSlotHonestVIdx_eq_iff qnf M w x t h
    (kvE2_sepMem_allSlots qnf (kvE2_sepPosI_subset hσ) huσ)
    (kvE2_sepMem_allSlots qnf (kvE2_sepPosI_subset hτ) hvτ)).mp hkey

/-- **O1 cross-class strict value monotonicity, LEFT** (report 14 Q5):
    the primed grouped LEFT tie classes carry STRICTLY increasing honest values across distinct
    classes — every member of an earlier class has strictly smaller value than every member of a
    later class. Assembles five landed Phase-1 assets: value-sortedness (`≤` between classes via
    `List.pairwise_flatten`), key strict monotonicity across runs
    (`kvE2_sepTieRuns_key_strictMono`), the primed bridge (`kvE2_sepSlotGIdx_honestOrder'`), and
    the tie-reporting payload law (`kvE2_sepSlotHonestVIdx_eq_iff`, giving `≠` from key-distinct).
    `≤` ∧ `≠` ⟹ `<`. Faithful to Rabinovich Lemma 5.3's strict inter-point chain (the merge
    absorbs ties, the order is not weakened). -/
theorem kvE2_sepTieGroupedL_strictMono {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    (kvE2_sepTieGroupedL (kvE2_sepHonestOrder' qnf M w x t h)).Pairwise
      (fun c₁ c₂ => ∀ u ∈ c₁, ∀ v ∈ c₂,
        kvE2_sepSlotValue qnf M w x t h u < kvE2_sepSlotValue qnf M w x t h v) := by
  set wo := kvE2_sepHonestOrder' qnf M w x t h with hwo_def
  have hwo : wo.map Prod.fst = kvE2_sepPosI qnf := by
    rw [hwo_def, kvE2_sepHonestOrder', List.map_map]; exact List.zipIdx_map_fst 0 _
  have hksort : (kvE2_sepSlotsLOf wo).Pairwise
      (fun a b => kvE2_sepSlotGIdx wo a ≤ kvE2_sepSlotGIdx wo b) := by
    refine (kvE2_sepSlotsLOf_mergeSorted wo).imp ?_
    intro a b hab; rw [kvE2_sepSlotMergeLe, decide_eq_true_eq] at hab; exact hab
  have hkey := kvE2_sepTieRuns_key_strictMono (kvE2_sepSlotGIdx wo)
    (kvE2_sepSlotsLOf wo) hksort
  have hvsorted := kvE2_sepSlotsLOf_honestOrder'_valueSorted qnf M w x t h
  rw [← hwo_def, ← kvE2_sepTieGroupedL_flatten wo, List.pairwise_flatten] at hvsorted
  have hvle := hvsorted.2
  rw [List.pairwise_iff_forall_sublist] at hkey hvle ⊢
  intro c₁ c₂ hsub u hu v hv
  have hle := hvle hsub u hu v hv
  have hklt := hkey hsub u hu v hv
  refine lt_of_le_of_ne hle ?_
  intro hval
  have hc1 : c₁ ∈ kvE2_sepTieGroupedL wo := hsub.subset (by simp)
  have hc2 : c₂ ∈ kvE2_sepTieGroupedL wo := hsub.subset (by simp)
  have hufl : u ∈ kvE2_sepSlotsLOf wo := by
    rw [← kvE2_sepTieGroupedL_flatten wo]; exact List.mem_flatten.mpr ⟨c₁, hc1, hu⟩
  have hvfl : v ∈ kvE2_sepSlotsLOf wo := by
    rw [← kvE2_sepTieGroupedL_flatten wo]; exact List.mem_flatten.mpr ⟨c₂, hc2, hv⟩
  obtain ⟨σ, hσ, huσ⟩ := kvE2_sepSlotsLOf_mem_block hwo hufl
  obtain ⟨τ, hτ, hvτ⟩ := kvE2_sepSlotsLOf_mem_block hwo hvfl
  have hkeq : kvE2_sepSlotGIdx wo u = kvE2_sepSlotGIdx wo v := by
    rw [hwo_def, kvE2_sepSlotGIdx_honestOrder' qnf M w x t h (kvE2_sepPosI_subset hσ) huσ,
        kvE2_sepSlotGIdx_honestOrder' qnf M w x t h (kvE2_sepPosI_subset hτ) hvτ]
    exact (kvE2_sepSlotHonestVIdx_eq_iff qnf M w x t h
      (kvE2_sepMem_allSlots qnf (kvE2_sepPosI_subset hσ) huσ)
      (kvE2_sepMem_allSlots qnf (kvE2_sepPosI_subset hτ) hvτ)).mpr hval
  omega

/-- **O1 cross-class strict value monotonicity, RIGHT** (mirror of
`kvE2_sepTieGroupedL_strictMono`). -/
theorem kvE2_sepTieGroupedR_strictMono {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    (kvE2_sepTieGroupedR (kvE2_sepHonestOrder' qnf M w x t h)).Pairwise
      (fun c₁ c₂ => ∀ u ∈ c₁, ∀ v ∈ c₂,
        kvE2_sepSlotValue qnf M w x t h u < kvE2_sepSlotValue qnf M w x t h v) := by
  set wo := kvE2_sepHonestOrder' qnf M w x t h with hwo_def
  have hwo : wo.map Prod.fst = kvE2_sepPosI qnf := by
    rw [hwo_def, kvE2_sepHonestOrder', List.map_map]; exact List.zipIdx_map_fst 0 _
  have hksort : (kvE2_sepSlotsROf wo).Pairwise
      (fun a b => kvE2_sepSlotGIdx wo a ≤ kvE2_sepSlotGIdx wo b) := by
    refine (kvE2_sepSlotsROf_mergeSorted wo).imp ?_
    intro a b hab; rw [kvE2_sepSlotMergeLe, decide_eq_true_eq] at hab; exact hab
  have hkey := kvE2_sepTieRuns_key_strictMono (kvE2_sepSlotGIdx wo)
    (kvE2_sepSlotsROf wo) hksort
  have hvsorted := kvE2_sepSlotsROf_honestOrder'_valueSorted qnf M w x t h
  rw [← hwo_def, ← kvE2_sepTieGroupedR_flatten wo, List.pairwise_flatten] at hvsorted
  have hvle := hvsorted.2
  rw [List.pairwise_iff_forall_sublist] at hkey hvle ⊢
  intro c₁ c₂ hsub u hu v hv
  have hle := hvle hsub u hu v hv
  have hklt := hkey hsub u hu v hv
  refine lt_of_le_of_ne hle ?_
  intro hval
  have hc1 : c₁ ∈ kvE2_sepTieGroupedR wo := hsub.subset (by simp)
  have hc2 : c₂ ∈ kvE2_sepTieGroupedR wo := hsub.subset (by simp)
  have hufl : u ∈ kvE2_sepSlotsROf wo := by
    rw [← kvE2_sepTieGroupedR_flatten wo]; exact List.mem_flatten.mpr ⟨c₁, hc1, hu⟩
  have hvfl : v ∈ kvE2_sepSlotsROf wo := by
    rw [← kvE2_sepTieGroupedR_flatten wo]; exact List.mem_flatten.mpr ⟨c₂, hc2, hv⟩
  obtain ⟨σ, hσ, huσ⟩ := kvE2_sepSlotsROf_mem_block hwo hufl
  obtain ⟨τ, hτ, hvτ⟩ := kvE2_sepSlotsROf_mem_block hwo hvfl
  have hkeq : kvE2_sepSlotGIdx wo u = kvE2_sepSlotGIdx wo v := by
    rw [hwo_def, kvE2_sepSlotGIdx_honestOrder' qnf M w x t h (kvE2_sepPosI_subset hσ) huσ,
        kvE2_sepSlotGIdx_honestOrder' qnf M w x t h (kvE2_sepPosI_subset hτ) hvτ]
    exact (kvE2_sepSlotHonestVIdx_eq_iff qnf M w x t h
      (kvE2_sepMem_allSlots qnf (kvE2_sepPosI_subset hσ) huσ)
      (kvE2_sepMem_allSlots qnf (kvE2_sepPosI_subset hτ) hvτ)).mpr hval
  omega

/-- **O1 below-pivot range, per owner (LEFT)**: every LEFT-region slot
    of a positive owner has honest value strictly inside `(x, w)` — the below-pivot bracket half
    (Rabinovich Figure 1, PDF p.9). For a left-interior owner the `.lXU`/`.lX1`/`.lUW` slots nest
    inside `(x, x1_σ) < x1_σ < (x1_σ, w)`; for a right-interior owner the `.rXW` slots sit in
    `(x, w)` by the landed Phase-2 below-pivot bound. Supplies the `usL`-last `< w` pivot fact O1
    needs (per-slot value specs, NOT value-sortedness — plan 12 line 140 mis-mitigation
    retracted). -/
theorem kvE2_sepSlotsLFor_value_bound {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf)
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2_sepSlotsLFor σ) :
    x < kvE2_sepSlotValue qnf M w x t h s
      ∧ kvE2_sepSlotValue qnf M w x t h s < w := by
  rw [kvE2_sepSlotsLFor] at hs
  by_cases hz1 : nf0_zoneSpec σ.1 = kvE2_sep_zXW3
  · rw [if_pos hz1, List.mem_append] at hs
    rcases hs with hs | hs
    · obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp hs
      have hspec := kvE2_sepSlotValue_lXU_spec qnf M w x t hxw hwt h σ hσ hz1 χ hχ
      have hanch := (kvE2_sepHonestAnchorBundleL qnf M w x t hxw hwt h σ hσ hz1).2.1
      exact ⟨hspec.1, lt_trans hspec.2.1 hanch⟩
    · rw [List.mem_cons] at hs
      rcases hs with rfl | hs
      · have hanch := kvE2_sepHonestAnchorBundleL qnf M w x t hxw hwt h σ hσ hz1
        rw [kvE2_sepSlotValue_lX1]
        exact ⟨hanch.1, hanch.2.1⟩
      · obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp hs
        have hspec := kvE2_sepSlotValue_lUW_spec qnf M w x t hxw hwt h σ hσ hz1 χ hχ
        have hanch := (kvE2_sepHonestAnchorBundleL qnf M w x t hxw hwt h σ hσ hz1).1
        exact ⟨lt_trans hanch hspec.1, hspec.2.1⟩
  · by_cases hz2 : nf0_zoneSpec σ.1 = kvE2_sep_zWT3
    · rw [if_neg hz1, if_pos hz2] at hs
      obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp hs
      have hspec := kvE2_sepSlotValue_rXW_spec qnf M w x t h σ hσ χ hχ
      exact ⟨hspec.1, hspec.2.1⟩
    · rw [if_neg hz1, if_neg hz2] at hs
      exact absurd hs (by simp)

/-- **O1 above-pivot range, per owner (RIGHT)** (mirror of `kvE2_sepSlotsLFor_value_bound`): every
    RIGHT-region slot of a positive owner has honest value strictly inside `(w, t)` — the
    above-pivot bracket half. Supplies the `w < usR`-first pivot fact. -/
theorem kvE2_sepSlotsRFor_value_bound {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf)
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2_sepSlotsRFor σ) :
    w < kvE2_sepSlotValue qnf M w x t h s
      ∧ kvE2_sepSlotValue qnf M w x t h s < t := by
  rw [kvE2_sepSlotsRFor] at hs
  by_cases hz1 : nf0_zoneSpec σ.1 = kvE2_sep_zXW3
  · rw [if_pos hz1] at hs
    obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp hs
    have hspec := kvE2_sepSlotValue_lWT_spec qnf M w x t h σ hσ χ hχ
    exact ⟨hspec.1, hspec.2.1⟩
  · by_cases hz2 : nf0_zoneSpec σ.1 = kvE2_sep_zWT3
    · rw [if_neg hz1, if_pos hz2, List.mem_append] at hs
      rcases hs with hs | hs
      · obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp hs
        have hspec := kvE2_sepSlotValue_rWX1_spec qnf M w x t hxw hwt h σ hσ hz2 χ hχ
        have hanch := (kvE2_sepHonestAnchorBundleR qnf M w x t hxw hwt h σ hσ hz2).2.1
        exact ⟨hspec.1, lt_trans hspec.2.1 hanch⟩
      · rw [List.mem_cons] at hs
        rcases hs with rfl | hs
        · have hanch := kvE2_sepHonestAnchorBundleR qnf M w x t hxw hwt h σ hσ hz2
          rw [kvE2_sepSlotValue_rX1]
          exact ⟨hanch.1, hanch.2.1⟩
        · obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp hs
          have hspec := kvE2_sepSlotValue_rX1T_spec qnf M w x t hxw hwt h σ hσ hz2 χ hχ
          have hanch := (kvE2_sepHonestAnchorBundleR qnf M w x t hxw hwt h σ hσ hz2).1
          exact ⟨lt_trans hanch hspec.1, hspec.2.1⟩
    · rw [if_neg hz1, if_neg hz2] at hs
      exact absurd hs (by simp)

/-- **O1 below-pivot range, merged LEFT list**: every slot of the
    primed merged LEFT list has honest value strictly inside `(x, w)`. The list-level pivot/range
    fact the Phase-7 assembly reads for `usL`-last `< w` and the global `x < · < t` range. -/
theorem kvE2_sepSlotsLOf_honestOrder'_value_bound {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2_sepSlotsLOf (kvE2_sepHonestOrder' qnf M w x t h)) :
    x < kvE2_sepSlotValue qnf M w x t h s
      ∧ kvE2_sepSlotValue qnf M w x t h s < w := by
  have hwo : (kvE2_sepHonestOrder' qnf M w x t h).map Prod.fst = kvE2_sepPosI qnf := by
    rw [kvE2_sepHonestOrder', List.map_map]; exact List.zipIdx_map_fst 0 _
  rw [kvE2_sepSlotsLOf] at hs
  obtain ⟨σ, hσ, hsσ⟩ := List.mem_flatMap.mp ((List.mergeSort_perm _ _).mem_iff.mp hs)
  have hσpos : σ ∈ kvE2_sepPos qnf :=
    kvE2_sepPosI_subset (kvE2_sepOrderOwners_mem_pos hwo hσ)
  exact kvE2_sepSlotsLFor_value_bound qnf M w x t hxw hwt h hσpos hsσ

/-- **O1 above-pivot range, merged RIGHT list** (mirror of
`kvE2_sepSlotsLOf_honestOrder'_value_bound`):
    every slot of the primed merged RIGHT list has honest value strictly inside `(w, t)`. -/
theorem kvE2_sepSlotsROf_honestOrder'_value_bound {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2_sepSlotsROf (kvE2_sepHonestOrder' qnf M w x t h)) :
    w < kvE2_sepSlotValue qnf M w x t h s
      ∧ kvE2_sepSlotValue qnf M w x t h s < t := by
  have hwo : (kvE2_sepHonestOrder' qnf M w x t h).map Prod.fst = kvE2_sepPosI qnf := by
    rw [kvE2_sepHonestOrder', List.map_map]; exact List.zipIdx_map_fst 0 _
  rw [kvE2_sepSlotsROf] at hs
  obtain ⟨σ, hσ, hsσ⟩ := List.mem_flatMap.mp ((List.mergeSort_perm _ _).mem_iff.mp hs)
  have hσpos : σ ∈ kvE2_sepPos qnf :=
    kvE2_sepPosI_subset (kvE2_sepOrderOwners_mem_pos hwo hσ)
  exact kvE2_sepSlotsRFor_value_bound qnf M w x t hxw hwt h hσpos hsσ

/-! ### O2: class point-type realization at the honest class value

The grouped bracket's LEFT/RIGHT point-type lists are `gL.map kvE2_sepClassType` /
`gR.map (…)`. `kvE2_sepBracketN_construct`'s `hptL`/`hptR` obligations require each class type to
evaluate at that class's honest witness value. Via `kvE2_sepClassType_eval_iff` this reduces to
every class MEMBER's slot type realizing at the (shared) class value; since one value per class
(`kvE2_sepTieGroupedL/R_value_const`), the class value is each member's OWN honest value, so the
obligation is the per-slot point-type discharge below. Base slots ride `hcb` + the banked value
specs; anchor slots ride the fresh-projection channel (`kvE2_sepProjFresh_eval` + `hck`) and the
CLOSED self-zone literal reads (`kvE2_sepOwnerLit_zAtX1L/R`). F5: only CLOSED `zAtX1L`/`zAtX1R`
keys enter; LITMUS-clean (all bounds ride `x`/`w`/`t`). -/

/-- `zAtX1L` self-zone literal honesty at a LEFT-interior owner's anchor value `a` (`x < a < w`):
    mirror of `kvE2_sepOwnerLit_zAtWL` reading the fresh-witness self-zone `v = a` instead of the
    pivot. -/
private theorem kvE2_sepOwnerLit_zAtX1L {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (σ : NormalForm sig 1 4) (a w x t : M.carrier)
    (hxa : x < a) (haw : a < w) (hwt : w < t)
    (hs : nf_eval_nf M 1 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (χ : NormalForm sig 0 1) :
    temporal_truth M atomMap a
      (kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zAtX1L χ) (charBase χ)) := by
  obtain ⟨-, h_zone, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
  cases hb : kvE2_sepBits σ kvE2_sep_zAtX1L χ with
  | true =>
    change temporal_truth M atomMap a (charBase χ)
    obtain ⟨v, hz, hv⟩ := (h_zone kvE2_sep_zAtX1L χ).mpr hb
    obtain ⟨h0, h1, h2, h3⟩ := (kvE2_sepZone4_iff M a w x t v
      (false, false) (true, false) (false, true) (true, false)).mp hz
    have hveq : v = a := le_antisymm
      (not_lt.mp (fun hc => Bool.noConfusion (h0.2.mp hc)))
      (not_lt.mp (fun hc => Bool.noConfusion (h0.1.mp hc)))
    exact (hcb χ a).mpr (hveq ▸ hv)
  | false =>
    change temporal_truth M atomMap a (charBase χ).neg
    intro hch
    have hat : a < t := haw.trans hwt
    have hz : zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t))))
        kvE2_sep_zAtX1L a := by
      refine (kvE2_sepZone4_iff M a w x t a
        (false, false) (true, false) (false, true) (true, false)).mpr ?_
      exact ⟨⟨iff_of_false (lt_irrefl a) (by decide), iff_of_false (lt_irrefl a) (by decide)⟩,
        ⟨iff_of_true haw rfl, iff_of_false (lt_asymm haw) (by decide)⟩,
        ⟨iff_of_false (lt_asymm hxa) (by decide), iff_of_true hxa rfl⟩,
        ⟨iff_of_true hat rfl, iff_of_false (lt_asymm hat) (by decide)⟩⟩
    have hbit : kvE2_sepBits σ kvE2_sep_zAtX1L χ = true :=
      (h_zone kvE2_sep_zAtX1L χ).mp ⟨a, hz, (hcb χ a).mp hch⟩
    rw [hb] at hbit
    exact Bool.noConfusion hbit

/-- `zAtX1R` self-zone literal honesty at a RIGHT-interior owner's anchor value `a` (`w < a < t`):
    mirror of `kvE2_sepOwnerLit_zAtX1L`. -/
private theorem kvE2_sepOwnerLit_zAtX1R {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (σ : NormalForm sig 1 4) (a w x t : M.carrier)
    (hwa : w < a) (hat : a < t) (hxw : x < w)
    (hs : nf_eval_nf M 1 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (χ : NormalForm sig 0 1) :
    temporal_truth M atomMap a
      (kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zAtX1R χ) (charBase χ)) := by
  have hxa : x < a := hxw.trans hwa
  obtain ⟨-, h_zone, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
  cases hb : kvE2_sepBits σ kvE2_sep_zAtX1R χ with
  | true =>
    change temporal_truth M atomMap a (charBase χ)
    obtain ⟨v, hz, hv⟩ := (h_zone kvE2_sep_zAtX1R χ).mpr hb
    obtain ⟨h0, h1, h2, h3⟩ := (kvE2_sepZone4_iff M a w x t v
      (false, false) (false, true) (false, true) (true, false)).mp hz
    have hveq : v = a := le_antisymm
      (not_lt.mp (fun hc => Bool.noConfusion (h0.2.mp hc)))
      (not_lt.mp (fun hc => Bool.noConfusion (h0.1.mp hc)))
    exact (hcb χ a).mpr (hveq ▸ hv)
  | false =>
    change temporal_truth M atomMap a (charBase χ).neg
    intro hch
    have hz : zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t))))
        kvE2_sep_zAtX1R a := by
      refine (kvE2_sepZone4_iff M a w x t a
        (false, false) (false, true) (false, true) (true, false)).mpr ?_
      exact ⟨⟨iff_of_false (lt_irrefl a) (by decide), iff_of_false (lt_irrefl a) (by decide)⟩,
        ⟨iff_of_false (lt_asymm hwa) (by decide), iff_of_true hwa rfl⟩,
        ⟨iff_of_false (lt_asymm hxa) (by decide), iff_of_true hxa rfl⟩,
        ⟨iff_of_true hat rfl, iff_of_false (lt_asymm hat) (by decide)⟩⟩
    have hbit : kvE2_sepBits σ kvE2_sep_zAtX1R χ = true :=
      (h_zone kvE2_sep_zAtX1R χ).mp ⟨a, hz, (hcb χ a).mp hch⟩
    rw [hb] at hbit
    exact Bool.noConfusion hbit

/-- **LEFT anchor point-type honesty** (Phase 4): a LEFT-interior owner σ's folded fresh point
    type `kvE2_sepPtX1L` evaluates at its own honest anchor value. Head = the `charK`-projected
    fresh type (`kvE2_sepProjFresh_eval` + `hck`); the base literals ride the CLOSED `zAtX1L`
    self-zone reads (`kvE2_sepOwnerLit_zAtX1L`). -/
theorem kvE2_sepPtX1L_eval_of_honest {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      temporal_truth M atomMap u (charK χ) ↔ nf_eval_nf M 1 1 (fun _ => u) χ)
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf)
    (hz : nf0_zoneSpec σ.1 = kvE2_sep_zXW3) :
    (kvE2_sepPtX1L charBase charK σ).eval_at M atomMap
      (kvE2_sepAnchorVal qnf M w x t h σ) := by
  have hbσ : qnf.2 σ = true := (List.mem_filter.mp hσ).2
  have hspec := kvE2_sepAnchorVal_spec qnf M w x t h σ hbσ
  have hbundle := kvE2_sepHonestAnchorBundleL qnf M w x t hxw hwt h σ hσ hz
  simp only [kvE2_sepPtX1L, TemporalPred.eval_at]
  rw [formula_conjList_iff]
  intro f hf
  rcases List.mem_cons.mp hf with rfl | hf
  · exact (hck _ _).mpr (kvE2_sepProjFresh_eval M _ _ σ hspec)
  · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
    exact kvE2_sepOwnerLit_zAtX1L charBase M atomMap σ _ w x t hbundle.1 hbundle.2.1 hwt hspec hcb χ

/-- **RIGHT anchor point-type honesty** (Phase 4, mirror of `kvE2_sepPtX1L_eval_of_honest`). -/
theorem kvE2_sepPtX1R_eval_of_honest {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      temporal_truth M atomMap u (charK χ) ↔ nf_eval_nf M 1 1 (fun _ => u) χ)
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf)
    (hz : nf0_zoneSpec σ.1 = kvE2_sep_zWT3) :
    (kvE2_sepPtX1R charBase charK σ).eval_at M atomMap
      (kvE2_sepAnchorVal qnf M w x t h σ) := by
  have hbσ : qnf.2 σ = true := (List.mem_filter.mp hσ).2
  have hspec := kvE2_sepAnchorVal_spec qnf M w x t h σ hbσ
  have hbundle := kvE2_sepHonestAnchorBundleR qnf M w x t hxw hwt h σ hσ hz
  simp only [kvE2_sepPtX1R, TemporalPred.eval_at]
  rw [formula_conjList_iff]
  intro f hf
  rcases List.mem_cons.mp hf with rfl | hf
  · exact (hck _ _).mpr (kvE2_sepProjFresh_eval M _ _ σ hspec)
  · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
    exact kvE2_sepOwnerLit_zAtX1R charBase M atomMap σ _ w x t hbundle.1 hbundle.2.1 hxw hspec hcb χ

/-- **Per-slot point-type honesty** (Phase 4): every slot of a positive owner's block realizes
    its slot point type AT its own honest slot value. Base slots ride `hcb` + the banked value
    specs; anchor slots ride the folded fresh point types above. -/
theorem kvE2_sepSlotType_eval_at_value {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      temporal_truth M atomMap u (charK χ) ↔ nf_eval_nf M 1 1 (fun _ => u) χ)
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf)
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2_sepSlotBlock σ) :
    (kvE2_sepSlotType charBase charK s).eval_at M atomMap
      (kvE2_sepSlotValue qnf M w x t h s) := by
  rw [kvE2_sepMem_slotBlock] at hs
  by_cases hz1 : nf0_zoneSpec σ.1 = kvE2_sep_zXW3
  · rw [kvE2_sepSlotsLFor, kvE2_sepSlotsRFor, if_pos hz1, if_pos hz1] at hs
    rcases hs with hL | hR
    · rcases List.mem_append.mp hL with h1 | h1
      · obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp h1
        simp only [kvE2_sepSlotType, TemporalPred.eval_at]
        exact (hcb χ _).mpr
          (kvE2_sepSlotValue_lXU_spec qnf M w x t hxw hwt h σ hσ hz1 χ hχ).2.2
      · rcases List.mem_cons.mp h1 with rfl | h1
        · rw [kvE2_sepSlotValue_lX1]
          exact kvE2_sepPtX1L_eval_of_honest charBase charK qnf M atomMap w x t hxw hwt h
            hcb hck hσ hz1
        · obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp h1
          simp only [kvE2_sepSlotType, TemporalPred.eval_at]
          exact (hcb χ _).mpr
            (kvE2_sepSlotValue_lUW_spec qnf M w x t hxw hwt h σ hσ hz1 χ hχ).2.2
    · obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp hR
      simp only [kvE2_sepSlotType, TemporalPred.eval_at]
      exact (hcb χ _).mpr
        (kvE2_sepSlotValue_lWT_spec qnf M w x t h σ hσ χ hχ).2.2
  · by_cases hz2 : nf0_zoneSpec σ.1 = kvE2_sep_zWT3
    · rw [kvE2_sepSlotsLFor, kvE2_sepSlotsRFor, if_neg hz1, if_neg hz1,
        if_pos hz2, if_pos hz2] at hs
      rcases hs with hL | hR
      · obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp hL
        simp only [kvE2_sepSlotType, TemporalPred.eval_at]
        exact (hcb χ _).mpr
          (kvE2_sepSlotValue_rXW_spec qnf M w x t h σ hσ χ hχ).2.2
      · rcases List.mem_append.mp hR with h1 | h1
        · obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp h1
          simp only [kvE2_sepSlotType, TemporalPred.eval_at]
          exact (hcb χ _).mpr
            (kvE2_sepSlotValue_rWX1_spec qnf M w x t hxw hwt h σ hσ hz2 χ hχ).2.2
        · rcases List.mem_cons.mp h1 with rfl | h1
          · rw [kvE2_sepSlotValue_rX1]
            exact kvE2_sepPtX1R_eval_of_honest charBase charK qnf M atomMap w x t hxw hwt h
              hcb hck hσ hz2
          · obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp h1
            simp only [kvE2_sepSlotType, TemporalPred.eval_at]
            exact (hcb χ _).mpr
              (kvE2_sepSlotValue_rX1T_spec qnf M w x t hxw hwt h σ hσ hz2 χ hχ).2.2
    · rw [kvE2_sepSlotsLFor, kvE2_sepSlotsRFor, if_neg hz1, if_neg hz1,
        if_neg hz2, if_neg hz2] at hs
      simp only [List.not_mem_nil, or_self] at hs

/-- **LEFT class point-type honesty** (Phase 4 / O2): a primed grouped LEFT tie class realizes
    its meet-folded class type at the honest value of any of its members (all members share the
    value, `kvE2_sepTieGroupedL_value_const`). Feeds the `hptL` obligation of
    `kvE2_sepBracketN_construct`. -/
theorem kvE2_sepTieGroupedL_classType_eval {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      temporal_truth M atomMap u (charK χ) ↔ nf_eval_nf M 1 1 (fun _ => u) χ)
    {c : List (KvE2SepSlot sig)}
    (hc : c ∈ kvE2_sepTieGroupedL (kvE2_sepHonestOrder' qnf M w x t h))
    {s0 : KvE2SepSlot sig} (hs0 : s0 ∈ c) :
    (kvE2_sepClassType charBase charK c).eval_at M atomMap
      (kvE2_sepSlotValue qnf M w x t h s0) := by
  set wo := kvE2_sepHonestOrder' qnf M w x t h with hwo_def
  have hwo : wo.map Prod.fst = kvE2_sepPosI qnf := by
    rw [hwo_def, kvE2_sepHonestOrder', List.map_map]; exact List.zipIdx_map_fst 0 _
  rw [kvE2_sepClassType_eval_iff]
  intro s hs
  rw [kvE2_sepTieGroupedL_value_const qnf M w x t h hc hs0 hs]
  have hsf : s ∈ kvE2_sepSlotsLOf wo := by
    rw [← kvE2_sepTieGroupedL_flatten wo]; exact List.mem_flatten.mpr ⟨c, hc, hs⟩
  obtain ⟨σ, hσ, hsσ⟩ := kvE2_sepSlotsLOf_mem_block hwo hsf
  exact kvE2_sepSlotType_eval_at_value charBase charK qnf M atomMap w x t hxw hwt h hcb hck
    (kvE2_sepPosI_subset hσ) hsσ

/-- **RIGHT class point-type honesty** (Phase 4 / O2, mirror of
    `kvE2_sepTieGroupedL_classType_eval`). -/
theorem kvE2_sepTieGroupedR_classType_eval {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      temporal_truth M atomMap u (charK χ) ↔ nf_eval_nf M 1 1 (fun _ => u) χ)
    {c : List (KvE2SepSlot sig)}
    (hc : c ∈ kvE2_sepTieGroupedR (kvE2_sepHonestOrder' qnf M w x t h))
    {s0 : KvE2SepSlot sig} (hs0 : s0 ∈ c) :
    (kvE2_sepClassType charBase charK c).eval_at M atomMap
      (kvE2_sepSlotValue qnf M w x t h s0) := by
  set wo := kvE2_sepHonestOrder' qnf M w x t h with hwo_def
  have hwo : wo.map Prod.fst = kvE2_sepPosI qnf := by
    rw [hwo_def, kvE2_sepHonestOrder', List.map_map]; exact List.zipIdx_map_fst 0 _
  rw [kvE2_sepClassType_eval_iff]
  intro s hs
  rw [kvE2_sepTieGroupedR_value_const qnf M w x t h hc hs0 hs]
  have hsf : s ∈ kvE2_sepSlotsROf wo := by
    rw [← kvE2_sepTieGroupedR_flatten wo]; exact List.mem_flatten.mpr ⟨c, hc, hs⟩
  obtain ⟨σ, hσ, hsσ⟩ := kvE2_sepSlotsROf_mem_block hwo hsf
  exact kvE2_sepSlotType_eval_at_value charBase charK qnf M atomMap w x t hxw hwt h hcb hck
    (kvE2_sepPosI_subset hσ) hsσ

/-! ### O3(a): honest segment-evaluation family (standalone)

No banked completeness-direction segment-eval lemma exists, so these are NEW. The core reads the
owners' universal (β) layer of `h`: a per-σ exclusion segment `kvE2_sepSegForm σ zs` holds at any
interior point `y` that sits in σ's zone `zs` (relative to σ's honest anchor value), because a
bit-FALSE 1-type realized there would force the fold bit TRUE (contradiction). Everything is
generic in `y` and its zone position (Cor 5.4, PDF p.5: exclusion throughout every realized
refined sub-interval). LITMUS-clean: all bounds ride `x`/`w`/`t` + the anchor value, never an
owner-to-owner chain. -/

/-- **Segment-exclusion honesty (core)** (Phase 5): under an honest owner realization at
    `[a, w, x, t]`, if `y` lies in σ's zone `zs`, then σ's exclusion segment
    `kvE2_sepSegForm σ zs` is realized at `y` — every bit-FALSE 1-type is excluded there. -/
theorem kvE2_sepSegForm_eval_of_honest {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (σ : NormalForm sig 1 4) (a w x t : M.carrier)
    (hspec : nf_eval_nf M 1 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (zs : ZoneSpec 4) (y : M.carrier)
    (hy : zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs y) :
    temporal_truth M atomMap y (kvE2_sepSegForm charBase σ zs) := by
  obtain ⟨-, h_zone, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hspec
  simp only [kvE2_sepSegForm]
  rw [formula_conjList_iff]
  intro f hf
  obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
  cases hbit : kvE2_sepBits σ zs χ with
  | true =>
    change temporal_truth M atomMap y Formula.top
    exact temporal_truth_top M atomMap y
  | false =>
    change temporal_truth M atomMap y (charBase χ).neg
    simp only [Formula.neg, temporal_truth]
    intro hch
    have hbt : kvE2_sepBits σ zs χ = true :=
      (h_zone zs χ).mp ⟨y, hy, (hcb χ y).mp hch⟩
    rw [hbit] at hbt
    exact Bool.noConfusion hbt

/-- **LEFT refined-segment honesty at a cut** (Phase 5): the LEFT-region refined-conjunction
    segment `kvE2_sepSegLAt lL i` is realized at any interior `y ∈ (x, w)` whose position relative
    to each left-interior owner's honest anchor matches the cut's structural read (`hbridge`).
    Right-interior owners contribute the uniform `(x, w)` (`kvE_sub2_zXU`) exclusion, discharged
    internally from `w < a`. Generic in `y` and `hbridge`; Phase 6 supplies the bridge from the
    class order. -/
theorem kvE2_sepSegLAt_eval_of_honest {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (lL : List (KvE2SepSlot sig)) (i : Nat) (y : M.carrier) (hxy : x < y) (hyw : y < w)
    (hbridge : ∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zXW3 →
      ((lL.take i).contains (.lX1 σ) = true → kvE2_sepAnchorVal qnf M w x t h σ < y) ∧
      ((lL.take i).contains (.lX1 σ) = false → y < kvE2_sepAnchorVal qnf M w x t h σ)) :
    (kvE2_sepSegLAt charBase qnf lL i).eval_at M atomMap y := by
  have hyt : y < t := hyw.trans hwt
  simp only [kvE2_sepSegLAt, TemporalPred.eval_at]
  rw [formula_conjList_iff]
  intro f hf
  obtain ⟨σ, hσ, rfl⟩ := List.mem_map.mp hf
  have hbσ : qnf.2 σ = true := (List.mem_filter.mp hσ).2
  have hspec := kvE2_sepAnchorVal_spec qnf M w x t h σ hbσ
  simp only [kvE2_sepSegLForSub]
  by_cases hz1 : nf0_zoneSpec σ.1 = kvE2_sep_zXW3
  · rw [if_pos hz1]
    have hbr := hbridge σ hσ hz1
    by_cases hcon : (lL.take i).contains (.lX1 σ) = true
    · rw [if_pos hcon]
      have hay := hbr.1 hcon
      apply kvE2_sepSegForm_eval_of_honest charBase M atomMap σ _ w x t hspec hcb
      refine (kvE2_sepZone4_iff M (kvE2_sepAnchorVal qnf M w x t h σ) w x t y
        (false, true) (true, false) (false, true) (true, false)).mpr ?_
      exact ⟨⟨iff_of_false (lt_asymm hay) (by decide), iff_of_true hay rfl⟩,
        ⟨iff_of_true hyw rfl, iff_of_false (lt_asymm hyw) (by decide)⟩,
        ⟨iff_of_false (lt_asymm hxy) (by decide), iff_of_true hxy rfl⟩,
        ⟨iff_of_true hyt rfl, iff_of_false (lt_asymm hyt) (by decide)⟩⟩
    · rw [if_neg hcon]
      have hya := hbr.2 (Bool.eq_false_iff.mpr hcon)
      apply kvE2_sepSegForm_eval_of_honest charBase M atomMap σ _ w x t hspec hcb
      refine (kvE2_sepZone4_iff M (kvE2_sepAnchorVal qnf M w x t h σ) w x t y
        (true, false) (true, false) (false, true) (true, false)).mpr ?_
      exact ⟨⟨iff_of_true hya rfl, iff_of_false (lt_asymm hya) (by decide)⟩,
        ⟨iff_of_true hyw rfl, iff_of_false (lt_asymm hyw) (by decide)⟩,
        ⟨iff_of_false (lt_asymm hxy) (by decide), iff_of_true hxy rfl⟩,
        ⟨iff_of_true hyt rfl, iff_of_false (lt_asymm hyt) (by decide)⟩⟩
  · by_cases hz2 : nf0_zoneSpec σ.1 = kvE2_sep_zWT3
    · rw [if_neg hz1, if_pos hz2]
      have hbnd := kvE2_sepHonestAnchorBundleR qnf M w x t hxw hwt h σ hσ hz2
      have hya : y < kvE2_sepAnchorVal qnf M w x t h σ := hyw.trans hbnd.1
      apply kvE2_sepSegForm_eval_of_honest charBase M atomMap σ _ w x t hspec hcb
      refine (kvE2_sepZone4_iff M (kvE2_sepAnchorVal qnf M w x t h σ) w x t y
        (true, false) (true, false) (false, true) (true, false)).mpr ?_
      exact ⟨⟨iff_of_true hya rfl, iff_of_false (lt_asymm hya) (by decide)⟩,
        ⟨iff_of_true hyw rfl, iff_of_false (lt_asymm hyw) (by decide)⟩,
        ⟨iff_of_false (lt_asymm hxy) (by decide), iff_of_true hxy rfl⟩,
        ⟨iff_of_true hyt rfl, iff_of_false (lt_asymm hyt) (by decide)⟩⟩
    · rw [if_neg hz1, if_neg hz2]
      exact temporal_truth_top M atomMap y

/-- **RIGHT refined-segment honesty at a cut** (Phase 5, mirror of `kvE2_sepSegLAt_eval_of_honest`):
    the RIGHT-region segment `kvE2_sepSegRAt lR j` is realized at any interior `y ∈ (w, t)` whose
    position relative to each right-interior owner's honest anchor matches the cut's structural
    read (`hbridge`). Left-interior owners contribute the uniform `(w, t)` (`kvE_sub2_zWT`)
    exclusion, discharged internally from `a < w`. -/
theorem kvE2_sepSegRAt_eval_of_honest {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (lR : List (KvE2SepSlot sig)) (j : Nat) (y : M.carrier) (hwy : w < y) (hyt : y < t)
    (hbridge : ∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zWT3 →
      ((lR.take j).contains (.rX1 σ) = true → kvE2_sepAnchorVal qnf M w x t h σ < y) ∧
      ((lR.take j).contains (.rX1 σ) = false → y < kvE2_sepAnchorVal qnf M w x t h σ)) :
    (kvE2_sepSegRAt charBase qnf lR j).eval_at M atomMap y := by
  have hxy : x < y := hxw.trans hwy
  simp only [kvE2_sepSegRAt, TemporalPred.eval_at]
  rw [formula_conjList_iff]
  intro f hf
  obtain ⟨σ, hσ, rfl⟩ := List.mem_map.mp hf
  have hbσ : qnf.2 σ = true := (List.mem_filter.mp hσ).2
  have hspec := kvE2_sepAnchorVal_spec qnf M w x t h σ hbσ
  simp only [kvE2_sepSegRForSub]
  by_cases hz1 : nf0_zoneSpec σ.1 = kvE2_sep_zXW3
  · rw [if_pos hz1]
    have hbnd := kvE2_sepHonestAnchorBundleL qnf M w x t hxw hwt h σ hσ hz1
    have hay : kvE2_sepAnchorVal qnf M w x t h σ < y := hbnd.2.1.trans hwy
    apply kvE2_sepSegForm_eval_of_honest charBase M atomMap σ _ w x t hspec hcb
    refine (kvE2_sepZone4_iff M (kvE2_sepAnchorVal qnf M w x t h σ) w x t y
      (false, true) (false, true) (false, true) (true, false)).mpr ?_
    exact ⟨⟨iff_of_false (lt_asymm hay) (by decide), iff_of_true hay rfl⟩,
      ⟨iff_of_false (lt_asymm hwy) (by decide), iff_of_true hwy rfl⟩,
      ⟨iff_of_false (lt_asymm hxy) (by decide), iff_of_true hxy rfl⟩,
      ⟨iff_of_true hyt rfl, iff_of_false (lt_asymm hyt) (by decide)⟩⟩
  · by_cases hz2 : nf0_zoneSpec σ.1 = kvE2_sep_zWT3
    · rw [if_neg hz1, if_pos hz2]
      have hbr := hbridge σ hσ hz2
      by_cases hcon : (lR.take j).contains (.rX1 σ) = true
      · rw [if_pos hcon]
        have hay := hbr.1 hcon
        apply kvE2_sepSegForm_eval_of_honest charBase M atomMap σ _ w x t hspec hcb
        refine (kvE2_sepZone4_iff M (kvE2_sepAnchorVal qnf M w x t h σ) w x t y
          (false, true) (false, true) (false, true) (true, false)).mpr ?_
        exact ⟨⟨iff_of_false (lt_asymm hay) (by decide), iff_of_true hay rfl⟩,
          ⟨iff_of_false (lt_asymm hwy) (by decide), iff_of_true hwy rfl⟩,
          ⟨iff_of_false (lt_asymm hxy) (by decide), iff_of_true hxy rfl⟩,
          ⟨iff_of_true hyt rfl, iff_of_false (lt_asymm hyt) (by decide)⟩⟩
      · rw [if_neg hcon]
        have hya := hbr.2 (Bool.eq_false_iff.mpr hcon)
        apply kvE2_sepSegForm_eval_of_honest charBase M atomMap σ _ w x t hspec hcb
        refine (kvE2_sepZone4_iff M (kvE2_sepAnchorVal qnf M w x t h σ) w x t y
          (true, false) (false, true) (false, true) (true, false)).mpr ?_
        exact ⟨⟨iff_of_true hya rfl, iff_of_false (lt_asymm hya) (by decide)⟩,
          ⟨iff_of_false (lt_asymm hwy) (by decide), iff_of_true hwy rfl⟩,
          ⟨iff_of_false (lt_asymm hxy) (by decide), iff_of_true hxy rfl⟩,
          ⟨iff_of_true hyt rfl, iff_of_false (lt_asymm hyt) (by decide)⟩⟩
    · rw [if_neg hz1, if_neg hz2]
      exact temporal_truth_top M atomMap y

/-! ### O3(b): gap discharge (the class-order bridge)

The Phase-5 segment family (`kvE2_sepSegLAt_eval_of_honest` / `…RAt…`) takes a per-owner
position bridge as a hypothesis. Phase 6 supplies that bridge from the class value order
(Phase 3): for a point `y` strictly between consecutive grouped-class witnesses, the anchor
slot `.lX1 σ` of a same-region owner sits in the flat prefix of the first `n` classes iff its
honest anchor value is below `y`. Reindexing `gL.flatten.take FC` to `(gL.take n).flatten`
(`kvE2_sep_take_flatten_prefix`) plus prefix/suffix value separation (`kvE2_sep_flatten_sep`)
reduce the bridge to two value-comparison hypotheses (`hprefix`/`hsuffix`) discharged in the
Phase-7 assembly from the gap bounds. LITMUS-clean: all bounds ride the anchor value and `y`,
never an owner-to-owner chain. -/

/-- Generic: the flat prefix of the first `n` sublists equals `flatten.take` at the prefix's
    own flattened length (whole-sublist cut alignment). -/
-- Module-public (was file-private): consumed by later modules of the SharedWitness tower (I,J).
theorem kvE2_sep_take_flatten_prefix {α : Type*} (L : List (List α)) (n : Nat) :
    (L.take n).flatten = L.flatten.take ((L.take n).flatten.length) := by
  induction L generalizing n with
  | nil => simp
  | cons a rest ih =>
    cases n with
    | zero => simp
    | succ m =>
      simp only [List.take_succ_cons, List.flatten_cons, List.length_append]
      rw [List.take_append, List.take_of_length_le (Nat.le_add_right _ _),
        Nat.add_sub_cancel_left, ← ih m]

/-- Generic: on a list of sublists whose blocks are strictly `R`-separated across the list
    (`Pairwise` of the cross-block order), every element of the first-`n` prefix relates by `R`
    to every element of the drop-`n` suffix. The value-separation kernel for the bridge. -/
private theorem kvE2_sep_flatten_sep {α : Type*} (R : α → α → Prop) (L : List (List α))
    (hmono : L.Pairwise (fun c₁ c₂ => ∀ u ∈ c₁, ∀ v ∈ c₂, R u v)) (n : Nat) :
    ∀ s ∈ (L.take n).flatten, ∀ s' ∈ (L.drop n).flatten, R s s' := by
  intro s hs s' hs'
  obtain ⟨c₁, hc₁, hsc₁⟩ := List.mem_flatten.mp hs
  obtain ⟨c₂, hc₂, hs'c₂⟩ := List.mem_flatten.mp hs'
  have hpw : (L.take n ++ L.drop n).Pairwise (fun c₁ c₂ => ∀ u ∈ c₁, ∀ v ∈ c₂, R u v) := by
    rw [List.take_append_drop]; exact hmono
  exact (List.pairwise_append.mp hpw).2.2 c₁ hc₁ c₂ hc₂ s hsc₁ s' hs'c₂

/-- **LEFT gap discharge** (Phase 6 / O3(b)): the LEFT grouped segment at grouped cut `n` is
    realized at any interior `y ∈ (x, w)` whose relation to the class values is fixed by the two
    gap hypotheses `hprefix` (first-`n` classes' slot values below `y`) and `hsuffix` (later
    classes' slot values above `y`). Builds the Phase-5 bridge for `kvE2_sepSegLAt_eval_of_honest`
    from those two facts. -/
theorem kvE2_sepSegLAt_gap_eval {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (_charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (n : Nat) (y : M.carrier) (hxy : x < y) (hyw : y < w)
    (hprefix : ∀ s ∈ ((kvE2_sepTieGroupedL (kvE2_sepHonestOrder' qnf M w x t h)).take n).flatten,
      kvE2_sepSlotValue qnf M w x t h s < y)
    (hsuffix : ∀ s ∈ ((kvE2_sepTieGroupedL (kvE2_sepHonestOrder' qnf M w x t h)).drop n).flatten,
      y < kvE2_sepSlotValue qnf M w x t h s) :
    (kvE2_sepSegLAt charBase qnf
        (kvE2_sepTieGroupedL (kvE2_sepHonestOrder' qnf M w x t h)).flatten
        (((kvE2_sepTieGroupedL (kvE2_sepHonestOrder' qnf M w x t h)).take n).flatten.length)
      ).eval_at M atomMap y := by
  set wo := kvE2_sepHonestOrder' qnf M w x t h with hwo_def
  set gL := kvE2_sepTieGroupedL wo with hgL_def
  apply kvE2_sepSegLAt_eval_of_honest charBase qnf M atomMap w x t hxw hwt h hcb
    gL.flatten ((gL.take n).flatten.length) y hxy hyw
  intro σ hσ hz
  rw [← kvE2_sep_take_flatten_prefix gL n]
  have hval : kvE2_sepSlotValue qnf M w x t h (.lX1 σ) = kvE2_sepAnchorVal qnf M w x t h σ :=
    kvE2_sepSlotValue_lX1 qnf M w x t h σ
  refine ⟨fun hc => ?_, fun hc => ?_⟩
  · have hmem : (KvE2SepSlot.lX1 σ) ∈ (gL.take n).flatten := List.contains_iff_mem.mp hc
    rw [← hval]; exact hprefix _ hmem
  · have hnmem : (KvE2SepSlot.lX1 σ) ∉ (gL.take n).flatten := by
      intro hm; rw [List.contains_iff_mem.mpr hm] at hc; exact Bool.noConfusion hc
    have hallmem : (KvE2SepSlot.lX1 σ) ∈ gL.flatten := by
      rw [hgL_def, kvE2_sepTieGroupedL_flatten]
      exact kvE2_sepSlotsLOf_mem qnf (kvE2_sepHonestOrder'_mem_orderTypes qnf M w x t h)
        ((kvE2_sepPosI_mem qnf σ).mpr ⟨hσ, Or.inl hz⟩) (kvE2_sep_lX1_mem_slotsLFor hz)
    have hsplit : gL.flatten = (gL.take n).flatten ++ (gL.drop n).flatten := by
      rw [← List.flatten_append, List.take_append_drop]
    rw [hsplit, List.mem_append] at hallmem
    rw [← hval]; exact hsuffix _ (hallmem.resolve_left hnmem)

/-- **RIGHT gap discharge** (Phase 6 / O3(b), mirror of `kvE2_sepSegLAt_gap_eval`): the RIGHT
    grouped segment at grouped cut `n` is realized at any interior `y ∈ (w, t)` fixed by the
    two RIGHT gap hypotheses. -/
theorem kvE2_sepSegRAt_gap_eval {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (_charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (n : Nat) (y : M.carrier) (hwy : w < y) (hyt : y < t)
    (hprefix : ∀ s ∈ ((kvE2_sepTieGroupedR (kvE2_sepHonestOrder' qnf M w x t h)).take n).flatten,
      kvE2_sepSlotValue qnf M w x t h s < y)
    (hsuffix : ∀ s ∈ ((kvE2_sepTieGroupedR (kvE2_sepHonestOrder' qnf M w x t h)).drop n).flatten,
      y < kvE2_sepSlotValue qnf M w x t h s) :
    (kvE2_sepSegRAt charBase qnf
        (kvE2_sepTieGroupedR (kvE2_sepHonestOrder' qnf M w x t h)).flatten
        (((kvE2_sepTieGroupedR (kvE2_sepHonestOrder' qnf M w x t h)).take n).flatten.length)
      ).eval_at M atomMap y := by
  set wo := kvE2_sepHonestOrder' qnf M w x t h with hwo_def
  set gR := kvE2_sepTieGroupedR wo with hgR_def
  apply kvE2_sepSegRAt_eval_of_honest charBase qnf M atomMap w x t hxw hwt h hcb
    gR.flatten ((gR.take n).flatten.length) y hwy hyt
  intro σ hσ hz
  rw [← kvE2_sep_take_flatten_prefix gR n]
  have hval : kvE2_sepSlotValue qnf M w x t h (.rX1 σ) = kvE2_sepAnchorVal qnf M w x t h σ :=
    kvE2_sepSlotValue_rX1 qnf M w x t h σ
  refine ⟨fun hc => ?_, fun hc => ?_⟩
  · have hmem : (KvE2SepSlot.rX1 σ) ∈ (gR.take n).flatten := List.contains_iff_mem.mp hc
    rw [← hval]; exact hprefix _ hmem
  · have hnmem : (KvE2SepSlot.rX1 σ) ∉ (gR.take n).flatten := by
      intro hm; rw [List.contains_iff_mem.mpr hm] at hc; exact Bool.noConfusion hc
    have hallmem : (KvE2SepSlot.rX1 σ) ∈ gR.flatten := by
      rw [hgR_def, kvE2_sepTieGroupedR_flatten]
      exact kvE2_sepSlotsROf_mem qnf (kvE2_sepHonestOrder'_mem_orderTypes qnf M w x t h)
        ((kvE2_sepPosI_mem qnf σ).mpr ⟨hσ, Or.inr hz⟩) (kvE2_sep_rX1_mem_slotsRFor hz)
    have hsplit : gR.flatten = (gR.take n).flatten ++ (gR.drop n).flatten := by
      rw [← List.flatten_append, List.take_append_drop]
    rw [hsplit, List.mem_append] at hallmem
    rw [← hval]; exact hsuffix _ (hallmem.resolve_left hnmem)

/-! ### O4: assembly (per-class witness list + the two public theorems)

The generic list helpers below build the per-class honest value list `usL`/`usR`
(one value per tie class, via `attach`+`head`), giving length, getElem, membership, and
prefix/suffix value-separation from the class strict order. They isolate the `attach`/`getElem`
mechanics from the model content so the bracket assembly reads at the class level. -/

/-- Generic: `gL[k] ∈ gL.drop k`. -/
private theorem kvE2_sep_getElem_mem_drop {α : Type*} (gL : List (List α)) (k : Nat)
    (hk : k < gL.length) : gL[k]'hk ∈ gL.drop k := by
  rw [List.drop_eq_getElem_cons hk]; exact List.mem_cons_self

/-- Generic: length of the per-class value list built by `attach`+`head`. -/
private theorem kvE2_sep_usOf_length {α β : Type*} (gL : List (List α)) (hne : ∀ c ∈ gL, c ≠ [])
    (Vf : α → β) :
    (gL.attach.map (fun p => Vf (p.1.head (hne p.1 p.2)))).length = gL.length := by
  rw [List.length_map, List.length_attach]

/-- Generic: the `k`-th per-class value is `Vf` of the `k`-th class's head. -/
private theorem kvE2_sep_usOf_getElem {α β : Type*} (gL : List (List α)) (hne : ∀ c ∈ gL, c ≠ [])
    (Vf : α → β) (k : Nat)
    (hk : k < (gL.attach.map (fun p => Vf (p.1.head (hne p.1 p.2)))).length) :
    (gL.attach.map (fun p => Vf (p.1.head (hne p.1 p.2))))[k]'hk
      = Vf ((gL[k]'(by simpa using hk)).head (hne _ (List.getElem_mem _))) := by
  rw [List.getElem_map, List.getElem_attach]

/-- Generic: every value of the per-class list is `Vf` of a member of some class. -/
private theorem kvE2_sep_usOf_mem {α β : Type*} (gL : List (List α)) (hne : ∀ c ∈ gL, c ≠ [])
    (Vf : α → β) {b : β} (hb : b ∈ gL.attach.map (fun p => Vf (p.1.head (hne p.1 p.2)))) :
    ∃ c ∈ gL, ∃ s ∈ c, b = Vf s := by
  obtain ⟨p, _, hpb⟩ := List.mem_map.mp hb
  exact ⟨p.1, p.2, p.1.head (hne p.1 p.2), List.head_mem _, hpb.symm⟩

/-- Generic prefix value bound: on a class-strictly-`<`-ordered list, all slots of the first `n`
    classes have `Vf` below `y`, given the `(n-1)`-th (boundary) class does. -/
private theorem kvE2_sep_take_flatten_lt {α β : Type*} [Preorder β] (Vf : α → β)
    (gL : List (List α))
    (hmono : gL.Pairwise (fun c₁ c₂ => ∀ u ∈ c₁, ∀ v ∈ c₂, Vf u < Vf v))
    (hne : ∀ c ∈ gL, c ≠ [])
    (n : Nat) (hn1 : 1 ≤ n) (hn : n ≤ gL.length) (y : β)
    (hbnd : ∀ s ∈ gL[n - 1]'(by omega), Vf s < y) :
    ∀ s ∈ (gL.take n).flatten, Vf s < y := by
  intro s hs
  have hsplit : (gL.take n).flatten = (gL.take (n-1)).flatten ++ gL[n-1]'(by omega) := by
    rw [show gL.take n = gL.take (n-1) ++ [gL[n-1]'(by omega)] from by
      conv_lhs => rw [show n = (n-1)+1 by omega]
      rw [List.take_add_one]; congr 1; rw [List.getElem?_eq_getElem (by omega)]; rfl]
    rw [List.flatten_append]; simp
  rw [hsplit, List.mem_append] at hs
  rcases hs with hs | hs
  · have hbmem : gL[n-1]'(by omega) ∈ gL.drop (n-1) := kvE2_sep_getElem_mem_drop gL (n-1) (by omega)
    have hs0 : (gL[n-1]'(by omega)).head (hne _ (List.getElem_mem _)) ∈ gL[n-1]'(by omega) :=
      List.head_mem _
    have hlt := kvE2_sep_flatten_sep (fun a b => Vf a < Vf b) gL hmono (n-1) s hs _
      (List.mem_flatten.mpr ⟨_, hbmem, hs0⟩)
    exact lt_trans hlt (hbnd _ hs0)
  · exact hbnd s hs

/-- Generic suffix value bound: on a class-strictly-`<`-ordered list, all slots of the classes from
    `n` onward have `Vf` above `y`, given the `n`-th (boundary) class does. -/
private theorem kvE2_sep_drop_flatten_gt {α β : Type*} [Preorder β] (Vf : α → β)
    (gL : List (List α))
    (hmono : gL.Pairwise (fun c₁ c₂ => ∀ u ∈ c₁, ∀ v ∈ c₂, Vf u < Vf v))
    (hne : ∀ c ∈ gL, c ≠ [])
    (n : Nat) (hn : n < gL.length) (y : β)
    (hbnd : ∀ s ∈ gL[n]'hn, y < Vf s) :
    ∀ s ∈ (gL.drop n).flatten, y < Vf s := by
  intro s hs
  have hsplit : gL.drop n = gL[n]'hn :: gL.drop (n+1) := by rw [List.drop_eq_getElem_cons hn]
  rw [hsplit, List.flatten_cons, List.mem_append] at hs
  rcases hs with hs | hs
  · exact hbnd s hs
  · have hbmem : gL[n]'hn ∈ gL.take (n+1) := by
      have h1 : (gL.take (n+1))[n]'(by rw [List.length_take]; omega) = gL[n]'hn := by
        rw [List.getElem_take]
      rw [← h1]; exact List.getElem_mem _
    have hs0 : (gL[n]'hn).head (hne _ (List.getElem_mem _)) ∈ gL[n]'hn := List.head_mem _
    have hlt := kvE2_sep_flatten_sep (fun a b => Vf a < Vf b) gL hmono (n+1) _
      (List.mem_flatten.mpr ⟨_, hbmem, hs0⟩) s hs
    exact lt_trans (hbnd _ hs0) hlt

/-- **Grouped bracket realization under honesty** (Phase 7 / O4): the meet-folded grouped bracket
    of the primed honest order is realized on `(x, t)`. Builds the per-class honest witness lists
    `usL`/`usR` (one value per tie class), discharges the strict order (O1), range, point types
    (O2), and per-gap segments (O3) into the private N-slot engine `kvE2_sepBracketN_construct`. -/
theorem kvE2_sepBracket_holds_of_honest {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      temporal_truth M atomMap u (charK χ) ↔ nf_eval_nf M 1 1 (fun _ => u) χ) :
    (kvE2_sepBracketN
        ((kvE2_sepTieGroupedL (kvE2_sepHonestOrder' qnf M w x t h)).map
          (kvE2_sepClassType charBase charK))
        (kvE2_sepPtW charBase charK qnf)
        ((kvE2_sepTieGroupedR (kvE2_sepHonestOrder' qnf M w x t h)).map
          (kvE2_sepClassType charBase charK))
        (kvE2_sepSegsG charBase qnf
          (kvE2_sepTieGroupedL (kvE2_sepHonestOrder' qnf M w x t h))
          (kvE2_sepTieGroupedR (kvE2_sepHonestOrder' qnf M w x t h)))
      ).holds M atomMap x t := by
  set wo := kvE2_sepHonestOrder' qnf M w x t h with hwo_def
  set gL := kvE2_sepTieGroupedL wo with hgL_def
  set gR := kvE2_sepTieGroupedR wo with hgR_def
  set Vf := kvE2_sepSlotValue qnf M w x t h with hVf_def
  have hneL : ∀ c ∈ gL, c ≠ [] := kvE2_sepTieGroupedL_ne_nil wo
  have hneR : ∀ c ∈ gR, c ≠ [] := kvE2_sepTieGroupedR_ne_nil wo
  have hmonoL : gL.Pairwise (fun c₁ c₂ => ∀ u ∈ c₁, ∀ v ∈ c₂, Vf u < Vf v) :=
    kvE2_sepTieGroupedL_strictMono qnf M w x t h
  have hmonoR : gR.Pairwise (fun c₁ c₂ => ∀ u ∈ c₁, ∀ v ∈ c₂, Vf u < Vf v) :=
    kvE2_sepTieGroupedR_strictMono qnf M w x t h
  have hbndL : ∀ s ∈ gL.flatten, x < Vf s ∧ Vf s < w := fun s hs =>
    kvE2_sepSlotsLOf_honestOrder'_value_bound qnf M w x t hxw hwt h
      (by rw [← kvE2_sepTieGroupedL_flatten wo]; exact hs)
  have hbndR : ∀ s ∈ gR.flatten, w < Vf s ∧ Vf s < t := fun s hs =>
    kvE2_sepSlotsROf_honestOrder'_value_bound qnf M w x t hxw hwt h
      (by rw [← kvE2_sepTieGroupedR_flatten wo]; exact hs)
  have hUL_len : (gL.attach.map (fun p => Vf (p.1.head (hneL p.1 p.2)))).length = gL.length :=
    kvE2_sep_usOf_length gL hneL Vf
  have hUR_len : (gR.attach.map (fun p => Vf (p.1.head (hneR p.1 p.2)))).length = gR.length :=
    kvE2_sep_usOf_length gR hneR Vf
  have huslen : (gL.attach.map (fun p => Vf (p.1.head (hneL p.1 p.2))) ++ w ::
      gR.attach.map (fun p => Vf (p.1.head (hneR p.1 p.2)))).length = gL.length + gR.length +
          1 := by
    rw [List.length_append, List.length_cons, hUL_len, hUR_len]; omega
  -- LEFT segment discharger from boundary class values
  have segL : ∀ (n : Nat) (hn : n ≤ gL.length) (yv : M.carrier) (hxy : x < yv) (hyw : yv < w),
      (∀ (_ : 0 < n), ∀ s ∈ gL[n-1]'(by omega), Vf s < yv) →
      (∀ (hlt : n < gL.length), ∀ s ∈ gL[n]'hlt, yv < Vf s) →
      (kvE2_sepSegsG charBase qnf gL gR n).eval_at M atomMap yv := by
    intro n hn yv hxy hyw hpre hsuf
    rw [kvE2_sepSegsG, if_pos hn]
    apply kvE2_sepSegLAt_gap_eval charBase charK qnf M atomMap w x t hxw hwt h hcb n yv hxy hyw
    · rcases Nat.eq_zero_or_pos n with h0 | hpos
      · subst h0; intro s hs; simp only [List.take_zero, List.flatten_nil, List.not_mem_nil] at hs
      · exact kvE2_sep_take_flatten_lt Vf gL hmonoL hneL n hpos hn yv (hpre hpos)
    · rcases Nat.lt_or_ge n gL.length with hlt | hge
      · exact kvE2_sep_drop_flatten_gt Vf gL hmonoL hneL n hlt yv (hsuf hlt)
      · have hEq : n = gL.length := le_antisymm hn hge
        subst hEq; intro s hs
        rw [List.drop_length, List.flatten_nil] at hs; exact absurd hs List.not_mem_nil
  -- RIGHT segment discharger from boundary class values
  have segR : ∀ (n : Nat) (hn : n ≤ gR.length) (yv : M.carrier) (hwy : w < yv) (hyt : yv < t),
      (∀ (_ : 0 < n), ∀ s ∈ gR[n-1]'(by omega), Vf s < yv) →
      (∀ (hlt : n < gR.length), ∀ s ∈ gR[n]'hlt, yv < Vf s) →
      (kvE2_sepSegsG charBase qnf gL gR (gL.length + 1 + n)).eval_at M atomMap yv := by
    intro n hn yv hwy hyt hpre hsuf
    rw [kvE2_sepSegsG, if_neg (by omega), show gL.length + 1 + n - gL.length - 1 = n by omega]
    apply kvE2_sepSegRAt_gap_eval charBase charK qnf M atomMap w x t hxw hwt h hcb n yv hwy hyt
    · rcases Nat.eq_zero_or_pos n with h0 | hpos
      · subst h0; intro s hs; simp only [List.take_zero, List.flatten_nil, List.not_mem_nil] at hs
      · exact kvE2_sep_take_flatten_lt Vf gR hmonoR hneR n hpos hn yv (hpre hpos)
    · rcases Nat.lt_or_ge n gR.length with hlt | hge
      · exact kvE2_sep_drop_flatten_gt Vf gR hmonoR hneR n hlt yv (hsuf hlt)
      · have hEq : n = gR.length := le_antisymm hn hge
        subst hEq; intro s hs
        rw [List.drop_length, List.flatten_nil] at hs; exact absurd hs List.not_mem_nil
  refine kvE2_sepBracketN_construct M atomMap _ _ _ _ x w t
    (gL.attach.map (fun p => Vf (p.1.head (hneL p.1 p.2))))
    (gR.attach.map (fun p => Vf (p.1.head (hneR p.1 p.2))))
    (by rw [hUL_len, List.length_map]) (by rw [hUR_len, List.length_map])
    ?hsort ?hrange ?hptL ?hptW ?hptR ?hseg0 ?hsegmid ?hseglast
  case hsort =>
    refine List.pairwise_append.mpr ⟨?_, ?_, ?_⟩
    · rw [List.pairwise_iff_getElem]
      intro a b ha hb hab
      have haL : a < gL.length := by rw [hUL_len] at ha; exact ha
      have hbL : b < gL.length := by rw [hUL_len] at hb; exact hb
      rw [kvE2_sep_usOf_getElem gL hneL Vf a ha, kvE2_sep_usOf_getElem gL hneL Vf b hb]
      exact List.pairwise_iff_getElem.mp hmonoL a b haL hbL hab _ (List.head_mem _) _
          (List.head_mem _)
    · rw [List.pairwise_cons]
      refine ⟨fun b hb => ?_, ?_⟩
      · obtain ⟨c, hc, s, hs, rfl⟩ := kvE2_sep_usOf_mem gR hneR Vf hb
        exact (hbndR s (List.mem_flatten.mpr ⟨c, hc, hs⟩)).1
      · rw [List.pairwise_iff_getElem]
        intro a b ha hb hab
        have haR : a < gR.length := by rw [hUR_len] at ha; exact ha
        have hbR : b < gR.length := by rw [hUR_len] at hb; exact hb
        rw [kvE2_sep_usOf_getElem gR hneR Vf a ha, kvE2_sep_usOf_getElem gR hneR Vf b hb]
        exact List.pairwise_iff_getElem.mp hmonoR a b haR hbR hab _ (List.head_mem _) _
          (List.head_mem _)
    · intro a ha b hb
      obtain ⟨c, hc, s, hs, rfl⟩ := kvE2_sep_usOf_mem gL hneL Vf ha
      have haw : Vf s < w := (hbndL s (List.mem_flatten.mpr ⟨c, hc, hs⟩)).2
      rw [List.mem_cons] at hb
      rcases hb with rfl | hb
      · exact haw
      · obtain ⟨c', hc', s', hs', rfl⟩ := kvE2_sep_usOf_mem gR hneR Vf hb
        exact haw.trans (hbndR s' (List.mem_flatten.mpr ⟨c', hc', hs'⟩)).1
  case hrange =>
    intro u hu
    rw [List.mem_append, List.mem_cons] at hu
    rcases hu with hu | (rfl | hu)
    · obtain ⟨c, hc, s, hs, rfl⟩ := kvE2_sep_usOf_mem gL hneL Vf hu
      have hb := hbndL s (List.mem_flatten.mpr ⟨c, hc, hs⟩)
      exact ⟨hb.1, hb.2.trans hwt⟩
    · exact ⟨hxw, hwt⟩
    · obtain ⟨c, hc, s, hs, rfl⟩ := kvE2_sep_usOf_mem gR hneR Vf hu
      have hb := hbndR s (List.mem_flatten.mpr ⟨c, hc, hs⟩)
      exact ⟨hxw.trans hb.1, hb.2⟩
  case hptL =>
    intro i hi
    have hiL : i < gL.length := by rw [List.length_map] at hi; exact hi
    rw [List.getElem_map, List.getElem_map, List.getElem_attach]
    exact kvE2_sepTieGroupedL_classType_eval charBase charK qnf M atomMap w x t hxw hwt h hcb hck
      (List.getElem_mem hiL) (List.head_mem _)
  case hptW =>
    exact kvE2_sepPtW_eval_of_honest charBase charK qnf M atomMap w x t hxw hwt h hcb hck
  case hptR =>
    intro j hj
    have hjR : j < gR.length := by rw [List.length_map] at hj; exact hj
    rw [List.getElem_map, List.getElem_map, List.getElem_attach]
    exact kvE2_sepTieGroupedR_classType_eval charBase charK qnf M atomMap w x t hxw hwt h hcb hck
      (List.getElem_mem hjR) (List.head_mem _)
  case hseg0 =>
    intro y hxy hy0
    apply segL 0 (Nat.zero_le _) y hxy ?_ ?_ ?_
    · rcases Nat.eq_zero_or_pos gL.length with h0 | hpos
      · rw [List.getElem_append_right (by rw [hUL_len]; omega)] at hy0
        simp only [hUL_len] at hy0
        rw [getElem_congr_idx (show (0 : Nat) - gL.length = 0 by omega),
          List.getElem_cons_zero] at hy0
        exact hy0
      · rw [List.getElem_append_left (by rw [hUL_len]; exact hpos), List.getElem_map,
          List.getElem_attach] at hy0
        exact lt_trans hy0
          (hbndL _ (List.mem_flatten.mpr ⟨_, List.getElem_mem hpos, List.head_mem _⟩)).2
    · intro hcontra; exact absurd hcontra (lt_irrefl 0)
    · intro hpos s hs
      rw [List.getElem_append_left (by rw [hUL_len]; exact hpos), List.getElem_map,
        List.getElem_attach] at hy0
      simp only [hVf_def]
      rw [kvE2_sepTieGroupedL_value_const qnf M w x t h (List.getElem_mem hpos) hs
        (List.head_mem _)]
      exact hy0
  case hsegmid =>
    intro i hi y hlo hhi
    rw [huslen] at hi
    rcases Nat.lt_or_ge i gL.length with hiL | hiG
    · -- LEFT gap
      rw [List.getElem_append_left (by rw [hUL_len]; exact hiL), List.getElem_map,
        List.getElem_attach] at hlo
      have hxlt : x < y := lt_trans
        (hbndL _ (List.mem_flatten.mpr ⟨_, List.getElem_mem hiL, List.head_mem _⟩)).1 hlo
      apply segL (i + 1) (by omega) y hxlt ?_ ?_ ?_
      · rcases Nat.lt_or_ge (i + 1) gL.length with hi1 | hi1
        · rw [List.getElem_append_left (by rw [hUL_len]; exact hi1), List.getElem_map,
            List.getElem_attach] at hhi
          exact lt_trans hhi
            (hbndL _ (List.mem_flatten.mpr ⟨_, List.getElem_mem hi1, List.head_mem _⟩)).2
        · rw [List.getElem_append_right (by rw [hUL_len]; omega)] at hhi
          simp only [hUL_len] at hhi
          rw [getElem_congr_idx (show i + 1 - gL.length = 0 by omega),
            List.getElem_cons_zero] at hhi
          exact hhi
      · intro _ s hs
        simp only [hVf_def]
        rw [kvE2_sepTieGroupedL_value_const qnf M w x t h
          (List.getElem_mem (show i < gL.length by omega)) hs (List.head_mem _)]
        exact hlo
      · intro hi1 s hs
        rw [List.getElem_append_left (by rw [hUL_len]; exact hi1), List.getElem_map,
          List.getElem_attach] at hhi
        simp only [hVf_def]
        rw [kvE2_sepTieGroupedL_value_const qnf M w x t h (List.getElem_mem hi1) hs
          (List.head_mem _)]
        exact hhi
    · -- RIGHT gap
      rw [show i + 1 = gL.length + 1 + (i - gL.length) by omega]
      rcases lt_or_eq_of_le hiG with hig | hie
      · -- i > gL.length
        apply segR (i - gL.length) (by omega) y ?_ ?_ ?_ ?_
        · rw [List.getElem_append_right (by rw [hUL_len]; omega)] at hlo
          simp only [hUL_len] at hlo
          rw [getElem_congr_idx (show i - gL.length = (i - gL.length - 1) + 1 by omega),
            List.getElem_cons_succ, List.getElem_map, List.getElem_attach] at hlo
          exact lt_trans
            (hbndR _ (List.mem_flatten.mpr ⟨_, List.getElem_mem
              (show i - gL.length - 1 < gR.length by omega), List.head_mem _⟩)).1 hlo
        · rw [List.getElem_append_right (by rw [hUL_len]; omega)] at hhi
          simp only [hUL_len] at hhi
          rw [getElem_congr_idx (show i + 1 - gL.length = (i - gL.length) + 1 by omega),
            List.getElem_cons_succ, List.getElem_map, List.getElem_attach] at hhi
          exact lt_trans hhi
            (hbndR _ (List.mem_flatten.mpr ⟨_, List.getElem_mem
              (show i - gL.length < gR.length by omega), List.head_mem _⟩)).2
        · intro _ s hs
          rw [List.getElem_append_right (by rw [hUL_len]; omega)] at hlo
          simp only [hUL_len] at hlo
          rw [getElem_congr_idx (show i - gL.length = (i - gL.length - 1) + 1 by omega),
            List.getElem_cons_succ, List.getElem_map, List.getElem_attach] at hlo
          simp only [hVf_def]
          rw [kvE2_sepTieGroupedR_value_const qnf M w x t h
            (List.getElem_mem (show i - gL.length - 1 < gR.length by omega)) hs (List.head_mem _)]
          exact hlo
        · intro hlt s hs
          rw [List.getElem_append_right (by rw [hUL_len]; omega)] at hhi
          simp only [hUL_len] at hhi
          rw [getElem_congr_idx (show i + 1 - gL.length = (i - gL.length) + 1 by omega),
            List.getElem_cons_succ, List.getElem_map, List.getElem_attach] at hhi
          simp only [hVf_def]
          rw [kvE2_sepTieGroupedR_value_const qnf M w x t h (List.getElem_mem hlt) hs
            (List.head_mem _)]
          exact hhi
      · -- i = gL.length (pivot on the left of the gap)
        rw [show i - gL.length = 0 by omega]
        apply segR 0 (Nat.zero_le _) y ?_ ?_ ?_ ?_
        · rw [List.getElem_append_right (by rw [hUL_len]; omega)] at hlo
          simp only [hUL_len] at hlo
          rw [getElem_congr_idx (show i - gL.length = 0 by omega), List.getElem_cons_zero] at hlo
          exact hlo
        · rw [List.getElem_append_right (by rw [hUL_len]; omega)] at hhi
          simp only [hUL_len] at hhi
          rw [getElem_congr_idx (show i + 1 - gL.length = 0 + 1 by omega),
            List.getElem_cons_succ, List.getElem_map, List.getElem_attach] at hhi
          exact lt_trans hhi
            (hbndR _ (List.mem_flatten.mpr ⟨_, List.getElem_mem
              (show 0 < gR.length by omega), List.head_mem _⟩)).2
        · intro hcontra; exact absurd hcontra (lt_irrefl 0)
        · intro hgRpos s hs
          rw [List.getElem_append_right (by rw [hUL_len]; omega)] at hhi
          simp only [hUL_len] at hhi
          rw [getElem_congr_idx (show i + 1 - gL.length = 0 + 1 by omega),
            List.getElem_cons_succ, List.getElem_map, List.getElem_attach] at hhi
          simp only [hVf_def]
          rw [kvE2_sepTieGroupedR_value_const qnf M w x t h (List.getElem_mem hgRpos) hs
            (List.head_mem _)]
          exact hhi
  case hseglast =>
    intro y hlast hyt
    rw [huslen]
    simp only [huslen, Nat.add_sub_cancel] at hlast
    rw [show gL.length + gR.length + 1 = gL.length + 1 + gR.length by omega]
    rcases Nat.eq_zero_or_pos gR.length with h0 | hpos
    · -- gR empty: the last witness is the pivot `w`
      rw [List.getElem_append_right (by rw [hUL_len]; omega)] at hlast
      simp only [hUL_len] at hlast
      rw [getElem_congr_idx (show gL.length + gR.length - gL.length = 0 by omega),
        List.getElem_cons_zero] at hlast
      apply segR gR.length (le_refl _) y hlast hyt ?_ ?_
      · intro hcontra; exact absurd (h0 ▸ hcontra) (lt_irrefl 0)
      · intro hlt; exact absurd hlt (lt_irrefl _)
    · -- gR nonempty: last witness is the last right class value
      rw [List.getElem_append_right (by rw [hUL_len]; omega)] at hlast
      simp only [hUL_len] at hlast
      rw [getElem_congr_idx (show gL.length + gR.length - gL.length = (gR.length - 1) + 1 by omega),
        List.getElem_cons_succ, List.getElem_map, List.getElem_attach] at hlast
      apply segR gR.length (le_refl _) y ?_ hyt ?_ ?_
      · exact lt_trans
          (hbndR _ (List.mem_flatten.mpr ⟨_, List.getElem_mem
            (show gR.length - 1 < gR.length by omega), List.head_mem _⟩)).1 hlast
      · intro _ s hs
        simp only [hVf_def]
        rw [kvE2_sepTieGroupedR_value_const qnf M w x t h
          (List.getElem_mem (show gR.length - 1 < gR.length by omega)) hs (List.head_mem _)]
        exact hlast
      · intro hlt; exact absurd hlt (lt_irrefl _)

/-- **The §2.1 target: grouped multi-owner disjunct `.holds` builder**:
    under an honest evaluation of `qnf` at `[w, x, t]`, the meet-folded grouped joint disjunct of
    the tie-reporting primed order `kvE2_sepHonestOrder'` is realized on `(x, t)`. Assembles the
    two endpoints (Phase-8 pack) and the grouped bracket (`kvE2_sepBracket_holds_of_honest`) into
    the `VecEA2.holds` triple. Consumes the PRIMED order at the target site (tie-admitting). -/
theorem kvE2_sepDisjunct'_holds_of_honest {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      temporal_truth M atomMap u (charK χ) ↔ nf_eval_nf M 1 1 (fun _ => u) χ) :
    (kvE2_sepDisjunct' charBase charK qnf
        (kvE2_sepTieGroupedL (kvE2_sepHonestOrder' qnf M w x t h))
        (kvE2_sepTieGroupedR (kvE2_sepHonestOrder' qnf M w x t h))).2.holds M atomMap x t := by
  refine ⟨?_, ?_, ?_⟩
  · exact kvE2_sepEpL_eval_of_honest charBase charK qnf M atomMap w x t hxw hwt h hcb hck
  · exact kvE2_sepEpR_eval_of_honest charBase charK qnf M atomMap w x t hxw hwt h hcb hck
  · exact kvE2_sepBracket_holds_of_honest charBase charK qnf M atomMap w x t hxw hwt h hcb hck

/-- **Body corollary** (consumed downstream): the joint-disjunct body
    formula `kvE2_sepBody` is realized on `(x, t)` under honesty, by feeding the §2.1 builder into
    the target completeness statement `kvE2_sepBody_complete_holds'` (which consumes the PRIMED
    tie-grouped disjunct). -/
theorem kvE2_sepBody_holds_of_honest {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (hg : kvE2_sepGate qnf)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      temporal_truth M atomMap u (charK χ) ↔ nf_eval_nf M 1 1 (fun _ => u) χ) :
    (kvE2_sepBody charBase charK qnf).holds M atomMap x t :=
  kvE2_sepBody_complete_holds' charBase charK qnf hg M atomMap w x t hxw hwt h
    (kvE2_sepDisjunct'_holds_of_honest charBase charK qnf M atomMap w x t hxw hwt h hcb hck)

/-! ## Phase 3 — Per-σ kit application: bundles → sound kit → owner `nf_eval`

Thread the per-σ bundles produced by the hypothesis-free `kvE2_sepBody_extract` (Phase 2)
through the `_parts` reducers into the closer `kvE_subBracket2V_sound_of_parts`
(`SubBracket2V.lean:1290`, consume-only) to obtain each positive owner's `nf_eval`. This is a
kit APPLICATION, not a bit-proof: every `σ.2 (nf0_assemble … χ σ.1) = true` occurrence below
is the *antecedent* of a per-owner `bit ⟹ witness` implication carried by that owner's OWN
enumeration `σ.2` — self-owned, never a cross-σ goal (plan v4 Postmortem Constraints; the
deleted plan-02 R3 stays deleted). `hgate` is the explicit outer-gate hypothesis threaded
verbatim (the Amendment F3 pattern of `kvE_subBracket2V_sound_of_outer`,
`SubBracket2V.lean:1481`) — never assumed, never discharged vacuously here; its carrier-side
derivable pieces live in the Phase 9 (O4) section above and its assembly is downstream
Rabinovich 2014: Notation 5.2 bracket bundles (pp.7-8), Cor 5.4
bounded interior placement (p.9). -/

/-- **LEFT-interior kit application** (Phase 3): a realized left-class bundle at the shared
    witness, under `w < t`, yields the owner's depth-1 `nf_eval` at env `[x1, w, x, t]` by
    feeding the EXACT `kvE_subBracket2V_sound_of_parts` input 5-tuple produced by
    `kvE2_sepBundleL_parts` into the closer, `hgate` threaded verbatim (Amendment F3 — the
    `kvE_subBracket2V_sound_of_outer` composition pattern, `SubBracket2V.lean:1514-1517`).
    Instantiated at the standard `charBase = nf_depth0_char_formula atomMap h_surj`, under
    which the bundle's below-anchor witnesses unify with the closer's expected shapes with no
    coercion. Bounds ride the bracket's own ordering (FM-x1t; never a fresh-witness/slot
    relative-position formula literal — LITMUS). -/
theorem kvE2_sepBundleL_sound {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier) (hwt : w < t)
    (h : kvE2_sepBundleL (nf_depth0_char_formula atomMap h_surj) charK σ M atomMap w x)
    (hgate : ∀ a : M.carrier, x < a → a < t →
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap a →
      a < w ∧ w < t ∧
      nf_eval_nf M 0 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1 ∧
      (∀ τ : NormalForm sig 0 5, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false) ∧
      (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1),
        (∃ v : M.carrier,
          zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ) →
        σ.2 (nf0_assemble zs χ σ.1) = true) ∧
      (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1), zs ≠ kvE_sub2_zXU →
        σ.2 (nf0_assemble zs χ σ.1) = true →
        ∃ v : M.carrier,
          zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ)) :
    ∃ x1 : M.carrier,
      nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  obtain ⟨x1, hxx1, hx1t, hanchor, hbelow⟩ :=
    kvE2_sepBundleL_parts (nf_depth0_char_formula atomMap h_surj) charK σ M atomMap hwt h
  exact kvE_subBracket2V_sound_of_parts atomMap h_surj charK σ M w x t x1 hxx1 hx1t hanchor
    hbelow hgate

/-- **RIGHT-interior kit application** (Phase 3 — the plan-v4 MEDIUM-risk residual,
    discharged by the anticipated kit-application lemma). The landed closer
    `kvE_subBracket2V_sound_of_parts` (`SubBracket2V.lean:1290`) does NOT serve this class
    directly — three signature facts, each read off HEAD source:
    (a) its `hgate` conclusion opens with `a < w` (`SubBracket2V.lean:1305`), but
    `kvE2_sepBundleR` supplies the anchor with `w < x1`, so a truthful gate can never be fed
    the right bundle's anchor;
    (b) `kvE2_sepBundleR_parts` (SW above) deliberately drops the below-clause — no `hbelow`
    in the closer's `kvE_sub2_zXU` shape exists for this class (for a RIGHT-interior σ that
    pattern reads `x < v < w`, the zone-constant header above);
    (c) the bundle's witnesses live in the right-interior middle region `kvE2_sep_zWX1`
    (`w < v < x1`), a zone the left closer's gate-backward clause does not exempt.
    This lemma is the geometry-correct mirror, proved from scratch against the same engine
    (`nf_eval_depth1_fold_iff`, `CarrierKv.lean:466`): the gate's backward clause exempts
    `kvE2_sep_zWX1` (instead of `kvE_sub2_zXU`), whose witnesses the bundle supplies. The
    left closer's `a < w ∧ w < t` head conjuncts are NOT mirrored: in the right geometry the
    corresponding order facts (`w < a`, `a < t`) are already the gate's own antecedents, and
    `x < w` is this lemma's hypothesis. The bit `σ.2 (nf0_assemble kvE2_sep_zWX1 χ σ.1)` is
    consumed as the antecedent of the bundle's own `bit ⟹ witness` implication — self-owned,
    never a goal. NO filter weakened; `hgate` an explicit threaded hypothesis (Amendment F3),
    never assumed. Bounds ride the model order (`x < w < u < x1 < t`), never a formula
    literal (LITMUS). Rabinovich 2014: Notation 5.2 mirrored slot group (pp.7-8), Cor 5.4
    bounded interior placement (p.9). -/
theorem kvE2_sepBundleR_sound {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier) (hxw : x < w)
    (h : kvE2_sepBundleR (nf_depth0_char_formula atomMap h_surj) charK σ M atomMap w t)
    (hgate : ∀ a : M.carrier, w < a → a < t →
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap a →
      nf_eval_nf M 0 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1 ∧
      (∀ τ : NormalForm sig 0 5, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false) ∧
      (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1),
        (∃ v : M.carrier,
          zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ) →
        σ.2 (nf0_assemble zs χ σ.1) = true) ∧
      (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1), zs ≠ kvE2_sep_zWX1 →
        σ.2 (nf0_assemble zs χ σ.1) = true →
        ∃ v : M.carrier,
          zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ)) :
    ∃ x1 : M.carrier,
      nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  obtain ⟨x1, hwx1, hx1t, hpt, hbelow⟩ := h
  have hanchor :=
    kvE2_sepPtX1R_anchor (nf_depth0_char_formula atomMap h_surj) charK σ M atomMap x1 hpt
  obtain ⟨h_atom, h_off, h_fwd, h_bwd⟩ := hgate x1 hwx1 hx1t hanchor
  refine ⟨x1, ?_⟩
  rw [nf_eval_depth1_fold_iff]
  refine ⟨h_atom, ?_, h_off⟩
  intro zs χ
  refine ⟨fun hex => h_fwd zs χ hex, ?_⟩
  intro hbit
  by_cases hzs : zs = kvE2_sep_zWX1
  · -- Right-interior middle region `zWX1 = (w < v < x1)`: the bundle's own below-witness
    -- clause supplies a witness strictly between `w` and the anchor `x1` (Def 3.1, PDF p.4).
    subst hzs
    obtain ⟨u, hwu, hux1, hu⟩ := hbelow χ hbit
    refine ⟨u, ?_, (nfPred_correct M atomMap h_surj χ u).mp hu⟩
    -- `u` lies in `zWX1` relative to env `[x1, w, x, t]` under `x < w < u < x1 < t`.
    have hxu : x < u := hxw.trans hwu
    have hut : u < t := hux1.trans hx1t
    intro i
    match i with
    | ⟨0, _⟩ => exact ⟨iff_of_true hux1 rfl, iff_of_false (lt_asymm hux1) (by decide +revert)⟩
    | ⟨1, _⟩ => exact ⟨iff_of_false (lt_asymm hwu) (by decide +revert), iff_of_true hwu rfl⟩
    | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxu) (by decide +revert), iff_of_true hxu rfl⟩
    | ⟨3, _⟩ => exact ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by decide +revert)⟩
  · -- Every other zone: the gate's backward direction (analog of `kvE_gate` honesty).
    exact h_bwd zs χ hzs hbit

/-- **Per-σ kit application over a realized body** (Phase 3 terminus — the Phase 4 input
    shape): from any realized `kvE2_sepBody` (whose held disjunct rides an arbitrary
    `wo ∈ kvE2_sepArr' qnf` inside the hypothesis-free `kvE2_sepBody_extract`) and per-class
    gate families at the extracted shared pivot, EVERY positive interior owner's depth-1
    `nf_eval` is realized at that pivot: left class via `kvE2_sepBundleL_parts` →
    `kvE_subBracket2V_sound_of_parts` (`kvE2_sepBundleL_sound`), right class via the mirrored
    `kvE2_sepBundleR_sound`. The gate families quantify over the pivot because the extraction
    produces `w` existentially; each gate stays an explicit threaded hypothesis (Amendment F3
    — never assumed). All bits consumed are self-owned enumeration antecedents. -/
theorem kvE2_sepBody_kit_sound {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig)
    (x t : M.carrier)
    (h : (kvE2_sepBody (nf_depth0_char_formula atomMap h_surj) charK qnf).holds M atomMap x t)
    (hgateL : ∀ w : M.carrier, x < w → w < t →
      (kvE2_sepPtW (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap w →
      ∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zXW3 →
      ∀ a : M.carrier, x < a → a < t →
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap a →
      a < w ∧ w < t ∧
      nf_eval_nf M 0 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1 ∧
      (∀ τ : NormalForm sig 0 5, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false) ∧
      (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1),
        (∃ v : M.carrier,
          zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ) →
        σ.2 (nf0_assemble zs χ σ.1) = true) ∧
      (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1), zs ≠ kvE_sub2_zXU →
        σ.2 (nf0_assemble zs χ σ.1) = true →
        ∃ v : M.carrier,
          zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ))
    (hgateR : ∀ w : M.carrier, x < w → w < t →
      (kvE2_sepPtW (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap w →
      ∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zWT3 →
      ∀ a : M.carrier, w < a → a < t →
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap a →
      nf_eval_nf M 0 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1 ∧
      (∀ τ : NormalForm sig 0 5, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false) ∧
      (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1),
        (∃ v : M.carrier,
          zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ) →
        σ.2 (nf0_assemble zs χ σ.1) = true) ∧
      (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1), zs ≠ kvE2_sep_zWX1 →
        σ.2 (nf0_assemble zs χ σ.1) = true →
        ∃ v : M.carrier,
          zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ)) :
    (kvE2_sepEpL (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap x ∧
    (kvE2_sepEpR (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap t ∧
    ∃ w : M.carrier, x < w ∧ w < t ∧
      (kvE2_sepPtW (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap w ∧
      (∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zXW3 →
        ∃ x1 : M.carrier,
          nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) ∧
      (∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zWT3 →
        ∃ x1 : M.carrier,
          nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) := by
  obtain ⟨hEpL, hEpR, w, hxw, hwt, hptW, hL, hR⟩ :=
    kvE2_sepBody_extract (nf_depth0_char_formula atomMap h_surj) charK qnf M atomMap x t h
  refine ⟨hEpL, hEpR, w, hxw, hwt, hptW, ?_, ?_⟩
  · intro σ hσ hz
    exact kvE2_sepBundleL_sound atomMap h_surj charK σ M w x t hwt (hL σ hσ hz)
      (hgateL w hxw hwt hptW σ hσ hz)
  · intro σ hσ hz
    exact kvE2_sepBundleR_sound atomMap h_surj charK σ M w x t hxw (hR σ hσ hz)
      (hgateR w hxw hwt hptW σ hσ hz)

/-! ## Phase 4 — Outer depth-2 fold `kvE2_outer_fold` (R4, the make-or-break)

Reassemble `∃ w, nf_eval_nf M 2 3 [w,x,t] qnf` from the per-σ realizations delivered by
`kvE2_sepBody_kit_sound` (Phase 3). There is NO landed depth-2 quant-layer fold engine
(`nf_quant_layer_fold_iff`, `NfEFold.lean:391`, folds depth-0 inner subs; the k=2 quant layer
ranges over depth-1 subs), so this theorem IS the assembly: it derives the outer atom layer
from the carrier's own endpoint/witness point types (`kvE2_sepEpL`/`kvE2_sepEpR`/`kvE2_sepPtW`
head conjuncts through `nfPred_correct`) plus the six outer order bits, zone-classifies the
positive subs through the extracted membership, discharges the two INTERIOR classes via the
Phase-3 kit, and threads the two genuinely provider-conditional residual families as explicit
hypotheses in the Amendment-F3 style (`kvE_subBracket2V_sound_of_outer` composition pattern):

- `hbdry` — realization of the five NON-interior positive placement classes
  (`zPastX3`/`zAtX3`/`zAtW3`/`zAtT3`/`zFutT3`). Their carrier content rides the σ-level
  `charK` E[Σ]-atom literals of `kvE2_sepEpL`/`kvE2_sepPtW`/`kvE2_sepEpR`, whose typing into
  arity-4 depth-1 evaluations is exactly the `ExistProviders.correct` step (c) of the
  navigated sub-chain sketch (`NavigatedSpine.lean:445`) — discharged downstream at the
  provider instantiation `charK := P.existF 0`, never assumed here.
- `hexcl` — the outer forward (exclusion) clause: negative subs are unrealized. The depth-2
  carrier pins per-σ content only up to (outer zone, projected 1-type) — the machine-checked
  information-loss record `bracketEndChar_kv_factors` (`CarrierKv.lean:422`) — so this clause
  is provider-conditional in exactly the A1 sense (`PriorInterface.lean:47-59`) and is
  threaded verbatim, never assumed and never discharged vacuously here.

Both families quantify over the pivot `w` because the extraction produces `w` existentially
(the same quantification pattern as `kvE2_sepBody_kit_sound`'s gate families). All bits
consumed remain self-owned enumeration antecedents; no filter is weakened; no `hgate` is
assumed. Rabinovich 2014: Def 3.1 (p.4) ordering/point-type split for the outer atom layer;
Lemma 3.2(2) anchor cap — the statement rides the two fixed anchors `(x,t)` (p.4); §5
bracket assembly with quantifier-free point types (pp.7-9). -/

/-- **Outer depth-2 fold**: from a realized `kvE2_sepBody`, the six
    outer order bits of `qnf.1` (the `BracketCarrierCorrectVPrior` bracket-zone hypotheses,
    `PriorInterface.lean:62-68` — the shape the planned `bracketEndChar_kvE2_sound_two_prior`
    consumer supplies), the two per-class interior gate families (verbatim
    `kvE2_sepBody_kit_sound` shapes: left 6-conjunct excluding `kvE_sub2_zXU`, right
    4-conjunct excluding `kvE2_sep_zWX1` — the two geometries differ), the non-interior
    realization family `hbdry`, and the exclusion family `hexcl`, the depth-2 evaluation
    `∃ w, nf_eval_nf M 2 3 [w,x,t] qnf` is assembled at the extracted shared pivot.

    The proof derives (never assumes): the pivot and its bounds from the Phase-3 kit; the
    outer PREDICATE atom bits at each of `w`/`x`/`t` from the head conjuncts of
    `kvE2_sepPtW`/`kvE2_sepEpL`/`kvE2_sepEpR` through `formula_conjList_iff` +
    `nfPred_correct` (Def 3.1 point-type channel, p.4); the outer ORDER atom bits from
    `x < w < t` against the six order hypotheses; the positive-sub zone classification from
    `kvE2_sepPos` membership; and the interior realizations from the Phase-3 kit. Bounds ride
    the model order — never a fresh-witness relative-position formula literal (LITMUS). -/
theorem kvE2_outer_fold {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    (h_xy : qnf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig)
    (x t : M.carrier)
    (h : (kvE2_sepBody (nf_depth0_char_formula atomMap h_surj) charK qnf).holds M atomMap x t)
    (hgateL : ∀ w : M.carrier, x < w → w < t →
      (kvE2_sepPtW (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap w →
      ∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zXW3 →
      ∀ a : M.carrier, x < a → a < t →
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap a →
      a < w ∧ w < t ∧
      nf_eval_nf M 0 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1 ∧
      (∀ τ : NormalForm sig 0 5, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false) ∧
      (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1),
        (∃ v : M.carrier,
          zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ) →
        σ.2 (nf0_assemble zs χ σ.1) = true) ∧
      (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1), zs ≠ kvE_sub2_zXU →
        σ.2 (nf0_assemble zs χ σ.1) = true →
        ∃ v : M.carrier,
          zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ))
    (hgateR : ∀ w : M.carrier, x < w → w < t →
      (kvE2_sepPtW (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap w →
      ∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zWT3 →
      ∀ a : M.carrier, w < a → a < t →
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap a →
      nf_eval_nf M 0 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1 ∧
      (∀ τ : NormalForm sig 0 5, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false) ∧
      (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1),
        (∃ v : M.carrier,
          zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ) →
        σ.2 (nf0_assemble zs χ σ.1) = true) ∧
      (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1), zs ≠ kvE2_sep_zWX1 →
        σ.2 (nf0_assemble zs χ σ.1) = true →
        ∃ v : M.carrier,
          zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ))
    (hbdry : ∀ w : M.carrier, x < w → w < t →
      (kvE2_sepPtW (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap w →
      ∀ σ ∈ kvE2_sepPos qnf,
        ¬ (nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3) →
        ∃ x1 : M.carrier,
          nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexcl : ∀ w : M.carrier, x < w → w < t →
      (kvE2_sepPtW (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap w →
      ∀ σ : NormalForm sig 1 4, qnf.2 σ = false →
        ∀ x1 : M.carrier,
          ¬ nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    ∃ w : M.carrier,
      nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf := by
  obtain ⟨hEpL, hEpR, w, hxw, hwt, hptW, hLreal, hRreal⟩ :=
    kvE2_sepBody_kit_sound atomMap h_surj charK qnf M x t h hgateL hgateR
  -- Coordinate 1-types at the three outer points, extracted from the carrier's own
  -- point-type head conjuncts (Def 3.1 point-type channel, PDF p.4).
  have hprojW : nf_eval_nf M 0 1 (fun _ => w) (kvE2_sepProj3 qnf.1 ⟨0, by omega⟩) := by
    have h1 := hptW
    simp only [kvE2_sepPtW, TemporalPred.eval_at] at h1
    exact (nfPred_correct M atomMap h_surj _ w).mp
      ((formula_conjList_iff M atomMap w _).mp h1 _ List.mem_cons_self)
  have hprojX : nf_eval_nf M 0 1 (fun _ => x) (kvE2_sepProj3 qnf.1 ⟨1, by omega⟩) := by
    have h1 := hEpL
    simp only [kvE2_sepEpL, TemporalPred.eval_at] at h1
    exact (nfPred_correct M atomMap h_surj _ x).mp
      ((formula_conjList_iff M atomMap x _).mp h1 _ List.mem_cons_self)
  have hprojT : nf_eval_nf M 0 1 (fun _ => t) (kvE2_sepProj3 qnf.1 ⟨2, by omega⟩) := by
    have h1 := hEpR
    simp only [kvE2_sepEpR, TemporalPred.eval_at] at h1
    exact (nfPred_correct M atomMap h_surj _ t).mp
      ((formula_conjList_iff M atomMap t _).mp h1 _ List.mem_cons_self)
  refine ⟨w, ?_, ?_⟩
  · -- Outer atom layer at `[w,x,t]`: PREDICATE bits from the three coordinate 1-types,
    -- ORDER bits from `x < w < t` against the six order hypotheses.
    intro a
    match a with
    | .pred p ⟨0, _⟩ =>
      have h1 := hprojW (.pred p ⟨0, by omega⟩)
      exact h1
    | .pred p ⟨1, _⟩ =>
      have h1 := hprojX (.pred p ⟨0, by omega⟩)
      exact h1
    | .pred p ⟨2, _⟩ =>
      have h1 := hprojT (.pred p ⟨0, by omega⟩)
      exact h1
    | .order ⟨0, _⟩ ⟨1, _⟩ hne =>
      refine iff_of_false ?_ (fun hc => Bool.false_ne_true (h_yx.symm.trans hc))
      simp only [atom_eval]
      exact lt_asymm hxw
    | .order ⟨0, _⟩ ⟨2, _⟩ hne =>
      refine iff_of_true ?_ h_yt
      simp only [atom_eval]
      exact hwt
    | .order ⟨1, _⟩ ⟨0, _⟩ hne =>
      refine iff_of_true ?_ h_xy
      simp only [atom_eval]
      exact hxw
    | .order ⟨1, _⟩ ⟨2, _⟩ hne =>
      refine iff_of_true ?_ h_xt
      simp only [atom_eval]
      exact hxw.trans hwt
    | .order ⟨2, _⟩ ⟨0, _⟩ hne =>
      refine iff_of_false ?_ (fun hc => Bool.false_ne_true (h_ty.symm.trans hc))
      simp only [atom_eval]
      exact lt_asymm hwt
    | .order ⟨2, _⟩ ⟨1, _⟩ hne =>
      refine iff_of_false ?_ (fun hc => Bool.false_ne_true (h_tx.symm.trans hc))
      simp only [atom_eval]
      exact lt_asymm (hxw.trans hwt)
    | .order ⟨0, _⟩ ⟨0, _⟩ hne => exact absurd rfl hne
    | .order ⟨1, _⟩ ⟨1, _⟩ hne => exact absurd rfl hne
    | .order ⟨2, _⟩ ⟨2, _⟩ hne => exact absurd rfl hne
  · -- Outer quant layer: forward via the exclusion family, backward via zone
    -- classification (interior classes through the Phase-3 kit, the rest through the
    -- non-interior realization family).
    intro σ
    constructor
    · rintro ⟨x1, hx1⟩
      by_contra hne
      exact hexcl w hxw hwt hptW σ (Bool.eq_false_iff.mpr hne) x1 hx1
    · intro hbit
      have hmem : σ ∈ kvE2_sepPos qnf := by
        simp only [kvE2_sepPos, List.mem_filter]
        exact ⟨Finset.mem_toList.mpr (Finset.mem_univ σ), hbit⟩
      by_cases hzL : nf0_zoneSpec σ.1 = kvE2_sep_zXW3
      · exact hLreal σ hmem hzL
      by_cases hzR : nf0_zoneSpec σ.1 = kvE2_sep_zWT3
      · exact hRreal σ hmem hzR
      exact hbdry w hxw hwt hptW σ hmem (by tauto)

-- ============================================================================
-- PIN-ANCHORED FRAGMENT FOLD  (ADDITIVE-ONLY — zero existing decls modified)
--   Grounding: the fragment-extractor derivability analysis (GO: pin-anchored _frag).
--   Deliverables: kvE2_sepGateAtPin_fragL / kvE2_sepGateAtPin_fragR /
--                 kvE2_sepBody_kit_sound_frag / kvE2_outer_fold_frag.
--   REFUTED (never attempt): the ∀-anchor segment-coverage extractor.
--   Consumer: bracketEndChar_kvE2_correct_two_prior_frag (OuterGate.lean).
--   GATE re-diff: everything below this banner is new; nothing above is touched.
-- ============================================================================

/-- **Single-positive-sub fragment predicate** (local restatement of
    `OuterGate.kvE2_sepFragment`, `OuterGate.lean:191`). Restated here rather than imported
    because `OuterGate` imports `SharedWitness` (importing back would create a cycle); the two
    definitions are byte-identical and `OuterGate`'s definitional `rfl` bridges them at the 335
    consumption site. `qnf`'s positive-sub list is exactly the singleton `[σ0]` with `σ0`
    interior-zoned. Depends only on `qnf`, never on a model or provider. -/
def kvE2_sepFragment_frag {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) : Prop :=
  ∃ σ0 : NormalForm sig 1 4,
    kvE2_sepPosI qnf = [σ0] ∧
    (nf0_zoneSpec σ0.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ0.1 = kvE2_sep_zWT3)

/-- **Nodup-list unique-filter singleton**. A `DecidableEq`-only
    replacement for the `List.filter_eq`/`List.count` replicate route (unavailable here: the
    `→ Bool` function space in `NormalForm sig 1 4` admits no `BEq`, only `DecidableEq`). If a
    duplicate-free list `l` contains `a`, and a boolean predicate `p` is true on `l` at exactly
    the point `a`, then `l.filter p = [a]`. Structural induction; the `Nodup` head-fresh fact
    forces the tail's filter to be `[]`. -/
private theorem kvE2_nodup_filter_unique {α : Type*} [DecidableEq α] {p : α → Bool} {a : α}
    (hp : ∀ x, p x = true ↔ x = a) :
    ∀ {l : List α}, l.Nodup → a ∈ l → l.filter p = [a]
  | [], _, ha => by simp at ha
  | b :: t, hnd, ha => by
    rw [List.nodup_cons] at hnd
    by_cases hb : b = a
    · subst hb
      rw [List.filter_cons_of_pos ((hp b).mpr rfl)]
      have ht : t.filter p = [] := by
        rw [List.filter_eq_nil_iff]
        intro x hx hpx
        exact hnd.1 (((hp x).mp hpx) ▸ hx)
      rw [ht]
    · rw [List.filter_cons_of_neg (by
        intro h; exact hb ((hp b).mp h))]
      exact kvE2_nodup_filter_unique hp hnd.2
        ((List.mem_cons.mp ha).resolve_left (fun h => hb h.symm))

/-- **Interior-singleton realizability witness**. Exhibits a concrete
    `qnf : NormalForm sig 2 3` for which the interior-restricted positive-sub list
    `kvE2_sepPosI qnf` is exactly the singleton `[σ0]` with `σ0` LEFT-interior
    (`nf0_zoneSpec σ0.1 = kvE2_sep_zXW3`), so `kvE2_sepFragment_frag qnf`
    (byte-defeq `OuterGate.kvE2_sepFragment`) holds. This is the non-vacuity ground the
    re-stated soundness half (Phase 5) cites, DIRECTLY REFUTING the old VACUITY NOTE.

    The witness qnf carries FOUR positive subs: the interior `σ0` PLUS the three forced
    characteristic positives at the at-point zones `zAtX3`/`zAtW3`/`zAtT3` (report 07 Refutation 1
    / H4 #1 shape `x < w < t`). The global list `kvE2_sepPos qnf` therefore has FOUR elements — so
    the OLD global-singleton predicate (`kvE2_sepPos qnf = [σ0]`) FAILS for this qnf — while the
    interior filter (`kvE2_sepPosI`) excludes exactly the three at-point positives (each fails the
    `zXW3 ∨ zWT3` interiority test, discharged by `decide`), leaving the single strictly-interior
    `σ0`. This is precisely the RE-SCOPE verdict made concrete: interior-singleton is realizable
    where global-singleton is not. Purely `qnf`-domain (no model / provider), matching the
    predicate's own dependency; each zone is pinned via `nf0_zoneSpec_assemble` (`NfEFold:197`). -/
theorem kvE2_sepFragment_realizable {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] :
    ∃ qnf : NormalForm sig 2 3, kvE2_sepFragment_frag qnf := by
  classical
  let σ0 : NormalForm sig 1 4 :=
    (nf0_assemble kvE2_sep_zXW3 (fun _ => false) (fun _ => false), fun _ => false)
  let σX : NormalForm sig 1 4 :=
    (nf0_assemble kvE2_sep_zAtX3 (fun _ => false) (fun _ => false), fun _ => false)
  let σW : NormalForm sig 1 4 :=
    (nf0_assemble kvE2_sep_zAtW3 (fun _ => false) (fun _ => false), fun _ => false)
  let σT : NormalForm sig 1 4 :=
    (nf0_assemble kvE2_sep_zAtT3 (fun _ => false) (fun _ => false), fun _ => false)
  have hz0 : nf0_zoneSpec σ0.1 = kvE2_sep_zXW3 :=
    nf0_zoneSpec_assemble kvE2_sep_zXW3 (fun _ => false) (fun _ => false)
  have hzX : nf0_zoneSpec σX.1 = kvE2_sep_zAtX3 :=
    nf0_zoneSpec_assemble kvE2_sep_zAtX3 (fun _ => false) (fun _ => false)
  have hzW : nf0_zoneSpec σW.1 = kvE2_sep_zAtW3 :=
    nf0_zoneSpec_assemble kvE2_sep_zAtW3 (fun _ => false) (fun _ => false)
  have hzT : nf0_zoneSpec σT.1 = kvE2_sep_zAtT3 :=
    nf0_zoneSpec_assemble kvE2_sep_zAtT3 (fun _ => false) (fun _ => false)
  refine ⟨(fun _ => false, fun σ => decide (σ = σ0 ∨ σ = σX ∨ σ = σW ∨ σ = σT)), σ0, ?_, Or.inl hz0⟩
  simp only [kvE2_sepPosI, kvE2_sepPos, List.filter_filter]
  refine kvE2_nodup_filter_unique ?_ (Finset.nodup_toList _)
    (Finset.mem_toList.mpr (Finset.mem_univ σ0))
  intro x
  -- `simp only [kvE2_sepPosI, …]` above already does what this `dsimp only` used to,
  -- so it now reports "no progress"
  rw [Bool.and_eq_true]
  constructor
  · rintro ⟨hint, hmem⟩
    rw [decide_eq_true_eq] at hmem hint
    rcases hmem with h | h | h | h
    · exact h
    · rw [h, hzX] at hint; exact absurd hint (by decide)
    · rw [h, hzW] at hint; exact absurd hint (by decide)
    · rw [h, hzT] at hint; exact absurd hint (by decide)
  · rintro rfl
    exact ⟨by rw [decide_eq_true_eq]; exact Or.inl hz0,
           by rw [decide_eq_true_eq]; exact Or.inl rfl⟩

/-- **LEFT-interior parts closer at the PIN** (the continuation-inlining
    wrapper). Inlines `kvE_subBracket2V_sound_of_parts`'s continuation
    (`SubBracket2V.lean:1324-1345`)
    with the four gate conjuncts supplied AT the specific pin `x1` (`x < x1 < w`), NOT as a ∀-anchor
    over `(x,t)` (whose universal form is REFUTED, report §1). The gate producer
    (`kvE2_sepGateAtPin_fragL`) extracts `x1` from the body and derives the four conjuncts at THAT
    pin, then calls this closer — the pin-specific forward conjunct (`h_fwd`) is never demanded at
    an
    arbitrary anchor. Additive; consumes `nf_eval_depth1_fold_iff`/`nfPred_correct` unchanged. -/
theorem kvE2_sepBundleL_sound_frag {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier) (hwt : w < t)
    (x1 : M.carrier) (hx1w : x1 < w)
    (hbelow : ∀ χ : NormalForm sig 0 1,
      σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true →
      ∃ u : M.carrier, x < u ∧ u < x1 ∧
        (⟨nf_depth0_char_formula atomMap h_surj χ⟩ : TemporalPred).eval_at M atomMap u)
    (h_atom : nf_eval_nf M 0 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1)
    (h_off : ∀ τ : NormalForm sig 0 5, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false)
    (h_fwd : ∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1),
      (∃ v : M.carrier,
        zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
        nf_eval_nf M 0 1 (fun _ => v) χ) →
      σ.2 (nf0_assemble zs χ σ.1) = true)
    (h_bwd : ∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1), zs ≠ kvE_sub2_zXU →
      σ.2 (nf0_assemble zs χ σ.1) = true →
      ∃ v : M.carrier,
        zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
        nf_eval_nf M 0 1 (fun _ => v) χ) :
    ∃ x1' : M.carrier,
      nf_eval_nf M 1 4 (Fin.cons x1' (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  refine ⟨x1, ?_⟩
  rw [nf_eval_depth1_fold_iff]
  refine ⟨h_atom, ?_, h_off⟩
  intro zs χ
  refine ⟨fun hex => h_fwd zs χ hex, ?_⟩
  intro hbit
  by_cases hzs : zs = kvE_sub2_zXU
  · subst hzs
    obtain ⟨u, hxu, hux1, hu⟩ := hbelow χ hbit
    refine ⟨u, ?_, (nfPred_correct M atomMap h_surj χ u).mp hu⟩
    have huw : u < w := hux1.trans hx1w
    have hut : u < t := huw.trans hwt
    intro i
    match i with
    | ⟨0, _⟩ => exact ⟨iff_of_true hux1 rfl, iff_of_false (lt_asymm hux1) (by decide +revert)⟩
    | ⟨1, _⟩ => exact ⟨iff_of_true huw rfl, iff_of_false (lt_asymm huw) (by decide +revert)⟩
    | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxu) (by decide +revert), iff_of_true hxu rfl⟩
    | ⟨3, _⟩ => exact ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by decide +revert)⟩
  · exact h_bwd zs χ hzs hbit

/-- **RIGHT-interior parts closer at the PIN** (mirror of
    `kvE2_sepBundleL_sound_frag`). Inlines `kvE2_sepBundleR_sound`'s continuation (`SW:9750-9776`)
    with the four gate conjuncts supplied at the specific pin `x1` (`w < x1 < t`), backward
    exception
    zone `kvE2_sep_zWX1`. The `x < w` head is this lemma's hypothesis. Additive. -/
theorem kvE2_sepBundleR_sound_frag {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier) (hxw : x < w)
    (x1 : M.carrier) (_hwx1 : w < x1) (hx1t : x1 < t)
    (hbelow : ∀ χ : NormalForm sig 0 1,
      σ.2 (nf0_assemble kvE2_sep_zWX1 χ σ.1) = true →
      ∃ u : M.carrier, w < u ∧ u < x1 ∧
        (⟨nf_depth0_char_formula atomMap h_surj χ⟩ : TemporalPred).eval_at M atomMap u)
    (h_atom : nf_eval_nf M 0 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1)
    (h_off : ∀ τ : NormalForm sig 0 5, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false)
    (h_fwd : ∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1),
      (∃ v : M.carrier,
        zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
        nf_eval_nf M 0 1 (fun _ => v) χ) →
      σ.2 (nf0_assemble zs χ σ.1) = true)
    (h_bwd : ∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1), zs ≠ kvE2_sep_zWX1 →
      σ.2 (nf0_assemble zs χ σ.1) = true →
      ∃ v : M.carrier,
        zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
        nf_eval_nf M 0 1 (fun _ => v) χ) :
    ∃ x1' : M.carrier,
      nf_eval_nf M 1 4 (Fin.cons x1' (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  refine ⟨x1, ?_⟩
  rw [nf_eval_depth1_fold_iff]
  refine ⟨h_atom, ?_, h_off⟩
  intro zs χ
  refine ⟨fun hex => h_fwd zs χ hex, ?_⟩
  intro hbit
  by_cases hzs : zs = kvE2_sep_zWX1
  · subst hzs
    obtain ⟨u, hwu, hux1, hu⟩ := hbelow χ hbit
    refine ⟨u, ?_, (nfPred_correct M atomMap h_surj χ u).mp hu⟩
    have hxu : x < u := hxw.trans hwu
    have hut : u < t := hux1.trans hx1t
    intro i
    match i with
    | ⟨0, _⟩ => exact ⟨iff_of_true hux1 rfl, iff_of_false (lt_asymm hux1) (by decide +revert)⟩
    | ⟨1, _⟩ => exact ⟨iff_of_false (lt_asymm hwu) (by decide +revert), iff_of_true hwu rfl⟩
    | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxu) (by decide +revert), iff_of_true hxu rfl⟩
    | ⟨3, _⟩ => exact ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by decide +revert)⟩
  · exact h_bwd zs χ hzs hbit

/-- **Point-location among strictly-monotone bracket witnesses** (the
    combinatorial core of the pin-anchored forward-zone derivation). For a strictly monotone
    finite witness family `ws : Fin (k+1) → M.carrier`, any point `v` is EITHER one of the
    witnesses, OR below the first, OR strictly between two consecutive witnesses, OR above the
    last — exactly the four segment regions of `IntervalPattern.holds_eq_succ`
    (`ExistsForallNF.lean:197-203`). Model-general (rides `M.carrier`'s `LinearOrder`); carries
    no fold/bracket content. This converts an arbitrary model point of an interior forward-zone
    into the region whose landed segment/witness channel closes it. Additive. -/
theorem kvE2_sep_locate_witness {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) {k : Nat}
    (ws : Fin (k + 1) → M.carrier)
    (v : M.carrier) :
    (∃ i : Fin (k + 1), v = ws i) ∨
    (v < ws ⟨0, Nat.succ_pos k⟩) ∨
    (∃ i : Fin k, ws ⟨i.val, Nat.lt_succ_of_lt i.isLt⟩ < v ∧
      v < ws ⟨i.val + 1, Nat.succ_lt_succ i.isLt⟩) ∨
    (ws ⟨k, Nat.lt_succ_self k⟩ < v) := by
  classical
  by_cases hex : ∃ i : Fin (k + 1), v = ws i
  · exact Or.inl hex
  · push Not at hex
    have htri : ∀ i : Fin (k + 1), ws i < v ∨ v < ws i := by
      intro i
      rcases lt_trichotomy (ws i) v with h | h | h
      · exact Or.inl h
      · exact absurd h.symm (hex i)
      · exact Or.inr h
    by_cases hlow : v < ws ⟨0, Nat.succ_pos k⟩
    · exact Or.inr (Or.inl hlow)
    · have h0 : ws ⟨0, Nat.succ_pos k⟩ < v := (htri ⟨0, Nat.succ_pos k⟩).resolve_right hlow
      have hSne : (Finset.univ.filter (fun i : Fin (k + 1) => ws i < v)).Nonempty :=
        ⟨⟨0, Nat.succ_pos k⟩, Finset.mem_filter.mpr ⟨Finset.mem_univ _, h0⟩⟩
      set m := (Finset.univ.filter (fun i : Fin (k + 1) => ws i < v)).max' hSne with hmdef
      have hmS := (Finset.univ.filter (fun i : Fin (k + 1) => ws i < v)).max'_mem hSne
      have hmv : ws m < v := (Finset.mem_filter.mp hmS).2
      by_cases hmk : m.val = k
      · right; right; right
        have hme : m = ⟨k, Nat.lt_succ_self k⟩ := Fin.ext hmk
        rwa [hme] at hmv
      · right; right; left
        have hmlt : m.val < k := lt_of_le_of_ne (Nat.lt_succ_iff.mp m.isLt) hmk
        refine ⟨⟨m.val, hmlt⟩, ?_, ?_⟩
        · have hme : (⟨m.val, Nat.lt_succ_of_lt hmlt⟩ : Fin (k + 1)) = m := Fin.ext rfl
          rw [hme]; exact hmv
        · have hnext : (⟨m.val + 1, Nat.succ_lt_succ hmlt⟩ : Fin (k + 1)) ∉
              Finset.univ.filter (fun i : Fin (k + 1) => ws i < v) := by
            intro hc
            have hle := Finset.le_max' _ _ hc
            rw [← hmdef] at hle
            have : m.val + 1 ≤ m.val := Fin.le_def.mp hle
            omega
          have hnv : ¬ (ws ⟨m.val + 1, Nat.succ_lt_succ hmlt⟩ < v) := fun hc =>
            hnext (Finset.mem_filter.mpr ⟨Finset.mem_univ _, hc⟩)
          exact (htri ⟨m.val + 1, Nat.succ_lt_succ hmlt⟩).resolve_left hnv

/-- **Zone-spec determinacy** (shared closer for the pin-anchored forward
    derivation). `zoneHolds` characterizes each zone-spec coordinate as a biconditional against
    `v`'s order relation to the fixed env points; on a `LinearOrder` carrier those relations are
    determined, so at most one zone spec can hold at a given point. Model-general, additive; the
    forward zone case (`h_fwd`) uses it to convert `v`'s realized zone into the specific
    `kvE_sub2_z*`/`kvE2_sep_z*` spec whose segment/endpoint channel excludes it. -/
theorem zoneHolds_unique {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) {n : Nat}
    (env : Fin n → M.carrier) (v : M.carrier) (za zb : ZoneSpec n)
    (ha : zoneHolds M env za v) (hb : zoneHolds M env zb v) : za = zb := by
  funext i
  obtain ⟨ha1, ha2⟩ := ha i
  obtain ⟨hb1, hb2⟩ := hb i
  exact Prod.ext (Bool.eq_iff_iff.mpr (ha1.symm.trans hb1))
    (Bool.eq_iff_iff.mpr (ha2.symm.trans hb2))

/-- Generic list fact (mid-segment pin bookkeeping): in a `Nodup`-flatten
    list of groups, an element `a` known to occur in group `k` occurs in the first `n` groups'
    flatten iff `k < n`. Resolves the `kvE2_sepSegLForSub`/`kvE2_sepSegRForSub` pin-`contains`
    guard from the pin's group index against `v`'s witness position. -/
theorem kvE2_sep_pin_mem_take_flatten_iff {α : Type*} (gL : List (List α))
    (hnd : gL.flatten.Nodup) (a : α) (k : ℕ) (hk : k < gL.length) (hak : a ∈ gL[k]'hk) (n : ℕ) :
    a ∈ (gL.take n).flatten ↔ k < n := by
  rw [List.nodup_flatten] at hnd
  obtain ⟨_, hdisj⟩ := hnd
  rw [List.pairwise_iff_getElem] at hdisj
  constructor
  · intro hmem
    rw [List.mem_flatten] at hmem
    obtain ⟨grp, hgrp, hin⟩ := hmem
    obtain ⟨j, hjlen, hgetj⟩ := List.mem_iff_getElem.mp hgrp
    have hjmin : j < min n gL.length := by simpa [List.length_take] using hjlen
    have hjn : j < n := lt_of_lt_of_le hjmin (Nat.min_le_left _ _)
    have hjL : j < gL.length := lt_of_lt_of_le hjmin (Nat.min_le_right _ _)
    have hgrp_eq : grp = gL[j]'hjL := by rw [← hgetj]; simp [List.getElem_take]
    have haj : a ∈ gL[j]'hjL := hgrp_eq ▸ hin
    have hjk : j = k := by
      by_contra hne
      rcases Nat.lt_or_gt_of_ne hne with hlt | hlt
      · exact List.disjoint_left.mp (hdisj j k hjL hk hlt) haj hak
      · exact List.disjoint_left.mp (hdisj k j hk hjL hlt) hak haj
    omega
  · intro hkn
    rw [List.mem_flatten]
    refine ⟨gL[k]'hk, ?_, hak⟩
    have hlt : k < (gL.take n).length := by rw [List.length_take]; omega
    have hmm := List.getElem_mem hlt
    rwa [List.getElem_take] at hmm

/-- Extract the two per-owner LEFT-endpoint literals (`zPastX4` Since-literal, `zAtX4`
    at-literal) for an interior owner `σ` from a realized `kvE2_sepEpL` at `x`
    (exterior/boundary forward exclusion). -/
theorem kvE2_sepEpL_owner_lits {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (x : M.carrier) (σ : NormalForm sig 1 4) (hσ : σ ∈ kvE2_sepPosIn qnf kvE2_sep_zXW3)
    (hep : (kvE2_sepEpL charBase charK qnf).eval_at M atomMap x) (χ : NormalForm sig 0 1) :
    temporal_truth M atomMap x
        (kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zPastX4 χ) (Formula.snce (charBase χ) Formula.top))
      ∧ temporal_truth M atomMap x
        (kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zAtX4 χ) (charBase χ)) := by
  have hep' : temporal_truth M atomMap x (kvE2_sepEpL charBase charK qnf).formula := hep
  simp only [kvE2_sepEpL] at hep'
  have hall := (formula_conjList_iff M atomMap x _).mp hep'
  have hσsrc : σ ∈ kvE2_sepPosIn qnf kvE2_sep_zXW3 ++ kvE2_sepPosIn qnf kvE2_sep_zWT3 :=
    List.mem_append.mpr (Or.inl hσ)
  have hχu : χ ∈ (Finset.univ.toList : List (NormalForm sig 0 1)) :=
    Finset.mem_toList.mpr (Finset.mem_univ _)
  refine ⟨hall _ (List.mem_append.mpr (Or.inr (List.mem_flatMap.mpr ⟨σ, hσsrc, ?_⟩))),
    hall _ (List.mem_append.mpr (Or.inr (List.mem_flatMap.mpr ⟨σ, hσsrc, ?_⟩)))⟩
  · exact List.mem_cons.mpr (Or.inr (List.mem_append.mpr (Or.inl
      (List.mem_map.mpr ⟨χ, hχu, rfl⟩))))
  · exact List.mem_cons.mpr (Or.inr (List.mem_append.mpr (Or.inr
      (List.mem_map.mpr ⟨χ, hχu, rfl⟩))))

/-- Extract the two per-owner RIGHT-endpoint literals (`zAtT4` at-literal, `zFutT4`
    Until-literal) for an interior owner `σ` from a realized `kvE2_sepEpR` at `t` (mirror of
    `kvE2_sepEpL_owner_lits`). -/
theorem kvE2_sepEpR_owner_lits {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (t : M.carrier) (σ : NormalForm sig 1 4) (hσ : σ ∈ kvE2_sepPosIn qnf kvE2_sep_zXW3)
    (hep : (kvE2_sepEpR charBase charK qnf).eval_at M atomMap t) (χ : NormalForm sig 0 1) :
    temporal_truth M atomMap t
        (kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zAtT4 χ) (charBase χ))
      ∧ temporal_truth M atomMap t
        (kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zFutT4 χ)
            (Formula.untl (charBase χ) Formula.top)) := by
  have hep' : temporal_truth M atomMap t (kvE2_sepEpR charBase charK qnf).formula := hep
  simp only [kvE2_sepEpR] at hep'
  have hall := (formula_conjList_iff M atomMap t _).mp hep'
  have hσsrc : σ ∈ kvE2_sepPosIn qnf kvE2_sep_zXW3 ++ kvE2_sepPosIn qnf kvE2_sep_zWT3 :=
    List.mem_append.mpr (Or.inl hσ)
  have hχu : χ ∈ (Finset.univ.toList : List (NormalForm sig 0 1)) :=
    Finset.mem_toList.mpr (Finset.mem_univ _)
  refine ⟨hall _ (List.mem_append.mpr (Or.inr (List.mem_flatMap.mpr ⟨σ, hσsrc, ?_⟩))),
    hall _ (List.mem_append.mpr (Or.inr (List.mem_flatMap.mpr ⟨σ, hσsrc, ?_⟩)))⟩
  · exact List.mem_cons.mpr (Or.inr (List.mem_append.mpr (Or.inl
      (List.mem_map.mpr ⟨χ, hχu, rfl⟩))))
  · exact List.mem_cons.mpr (Or.inr (List.mem_append.mpr (Or.inr
      (List.mem_map.mpr ⟨χ, hχu, rfl⟩))))

/-- Extract the per-owner `zAtWL` at-`w` literal for an interior owner `σ` from a realized
    `kvE2_sepPtW` at `w` (witness case — the `j = |gL|` AT-`w` sub-case;
    mirror of `kvE2_sepEpL_owner_lits`). -/
theorem kvE2_sepPtW_owner_lit {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w : M.carrier) (σ : NormalForm sig 1 4) (hσ : σ ∈ kvE2_sepPosIn qnf kvE2_sep_zXW3)
    (hep : (kvE2_sepPtW charBase charK qnf).eval_at M atomMap w) (χ : NormalForm sig 0 1) :
    temporal_truth M atomMap w
      (kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zAtWL χ) (charBase χ)) := by
  have hep' : temporal_truth M atomMap w (kvE2_sepPtW charBase charK qnf).formula := hep
  simp only [kvE2_sepPtW] at hep'
  have hall := (formula_conjList_iff M atomMap w _).mp hep'
  have hχu : χ ∈ (Finset.univ.toList : List (NormalForm sig 0 1)) :=
    Finset.mem_toList.mpr (Finset.mem_univ _)
  exact hall _ (List.mem_cons.mpr (Or.inr (List.mem_append.mpr (Or.inl
    (List.mem_append.mpr (Or.inr (List.mem_flatMap.mpr ⟨σ, hσ,
      List.mem_cons.mpr (Or.inr (List.mem_map.mpr ⟨χ, hχu, rfl⟩))⟩)))))))

/-- Extract the per-owner `zAtX1L` at-`x1` literal for owner `σ` from a realized
    `kvE2_sepPtX1L` at the pin `x1` (witness case — the `j = iσ` AT-`x1`
    sub-case; mirror of `kvE2_sepEpL_owner_lits`). -/
theorem kvE2_sepPtX1L_owner_lit {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (x1 : M.carrier)
    (hep : (kvE2_sepPtX1L charBase charK σ).eval_at M atomMap x1) (χ : NormalForm sig 0 1) :
    temporal_truth M atomMap x1
      (kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zAtX1L χ) (charBase χ)) := by
  have hep' : temporal_truth M atomMap x1 (kvE2_sepPtX1L charBase charK σ).formula := hep
  simp only [kvE2_sepPtX1L] at hep'
  have hall := (formula_conjList_iff M atomMap x1 _).mp hep'
  have hχu : χ ∈ (Finset.univ.toList : List (NormalForm sig 0 1)) :=
    Finset.mem_toList.mpr (Finset.mem_univ _)
  exact hall _ (List.mem_cons.mpr (Or.inr (List.mem_map.mpr ⟨χ, hχu, rfl⟩)))

/-- **LEFT pin-anchored gate producer**. From a realized
    `kvE2_sepBody` in the SINGLE-positive fragment (`hfrag`) with the sole positive sub `σ0`
    left-interior (`hz`), plus provider-correctness `hcorrK` at the pin (the
    `ExistProviders.correct`
    step 335 owns), the `kvE2_sepBody_kit_sound` conclusion is assembled by re-running the joint
    bracket extraction INLINE (keeping the segment components `holds_eq_succ` 4/5/6 discarded by
    `kvE2_sepBody_extract`), then deriving the four pin conjuncts and calling the landed
    `kvE2_sepBundleL_sound_frag`. Every conjunct is derived AT the extracted pin `x1` (`x < x1 <
    w`),
    NEVER at an arbitrary ∀-anchor (report §1 refutation). Additive; `hcorrK` an explicit
    hypothesis, never discharged. -/
theorem kvE2_sepGateAtPin_fragL {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    (h_xy : qnf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig)
    (x t : M.carrier)
    (σ0 : NormalForm sig 1 4)
    (hfrag : kvE2_sepPos qnf = [σ0])
    (hz : nf0_zoneSpec σ0.1 = kvE2_sep_zXW3)
    (hcorrK : ∀ (σ : NormalForm sig 1 4) (a : M.carrier),
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap a →
      nf_eval_nf M 1 1 (fun _ => a) (nfk_projFresh σ))
    (h : (kvE2_sepBody (nf_depth0_char_formula atomMap h_surj) charK qnf).holds M atomMap x t) :
    (kvE2_sepEpL (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap x ∧
    (kvE2_sepEpR (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap t ∧
    ∃ w : M.carrier, x < w ∧ w < t ∧
      (kvE2_sepPtW (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap w ∧
      (∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zXW3 →
        ∃ x1 : M.carrier,
          nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) ∧
      (∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zWT3 →
        ∃ x1 : M.carrier,
          nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) := by
  set charBase := nf_depth0_char_formula atomMap h_surj with hcb
  by_cases hg : kvE2_sepGate qnf
  · rw [kvE2_sepBody_holds_iff charBase charK qnf hg M atomMap x t] at h
    obtain ⟨wo, hwo, hd⟩ := h
    obtain ⟨hepL, hepR, hbr⟩ := hd
    have hwo' : wo ∈ kvE2_sepOrderTypes qnf := (List.mem_filter.mp hwo).1
    have howners : wo.map Prod.fst = kvE2_sepPosI qnf := kvE2_sepOrderTypes_owners qnf hwo'
    have hksortL : (kvE2_sepSlotsLOf wo).Pairwise
        (fun a b => kvE2_sepSlotGIdx wo a ≤ kvE2_sepSlotGIdx wo b) := by
      refine (kvE2_sepSlotsLOf_mergeSorted wo).imp ?_
      intro a b hab; rw [kvE2_sepSlotMergeLe, decide_eq_true_eq] at hab; exact hab
    simp only [kvE2_sepDisjunct', kvE2_sepBracketN, BracketFormula.holds,
      BracketFormula.toIntervalPattern] at hbr
    rw [IntervalPattern.holds_eq_succ M atomMap _ _ x t
      (show ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length + 1
          + ((kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK)).length
        = ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length
          + ((kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK)).length + 1
        by omega)] at hbr
    obtain ⟨ws, hmono, hrange, hpt, hseg0, hsegMid, hsegLast⟩ := hbr
    have hpt' : ∀ (i : Nat)
        (hi : i < ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length
          + ((kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK)).length + 1),
        (((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)
            ++ kvE2_sepPtW charBase charK qnf
              :: (kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK))[i]'(by
          simp only [List.length_append, List.length_cons]; omega)).eval_at M atomMap
          (ws ⟨i, hi⟩) := fun i hi => hpt ⟨i, hi⟩
    have hwidx : ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length
        < ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length
          + ((kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK)).length + 1 := by omega
    set w := ws ⟨((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length,
      hwidx⟩ with hwdef
    have hxw : x < w := (hrange _).1
    have hwt : w < t := (hrange _).2
    have hptW : (kvE2_sepPtW charBase charK qnf).eval_at M atomMap w := by
      have h1 := hpt' _ hwidx
      rwa [kvE2_sep_getElem_mid] at h1
    -- σ0's pin and bundle (single-positive: σ0 is the sole owner; no cross-σ slots)
    have hσ0pos : σ0 ∈ kvE2_sepPos qnf := by rw [hfrag]; exact List.mem_singleton_self _
    have hσ0true : qnf.2 σ0 = true := by
      have := hσ0pos; simp only [kvE2_sepPos, List.mem_filter] at this; exact this.2
    have hσI : σ0 ∈ kvE2_sepPosI qnf := (kvE2_sepPosI_mem qnf σ0).mpr ⟨hσ0pos, Or.inl hz⟩
    have hσp : σ0 ∈ wo.map Prod.fst := by rw [howners]; exact hσI
    obtain ⟨pp, hpwo, hp1⟩ := List.mem_map.mp hσp
    have hpe : (σ0, pp.2.1, pp.2.2) ∈ wo := by rw [← hp1]; exact hpwo
    have hmemX1 : (KvE2SepSlot.lX1 σ0) ∈ kvE2_sepSlotsLOf wo :=
      kvE2_sepSlotsLOf_mem qnf hwo' hσI (kvE2_sep_lX1_mem_slotsLFor hz)
    rw [← kvE2_sepTieGroupedL_flatten wo] at hmemX1
    obtain ⟨c, hc, hsc⟩ := List.mem_flatten.mp hmemX1
    obtain ⟨iσ, hiσ, hgetiσ⟩ := List.mem_iff_getElem.mp hc
    have hiσm : iσ < ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length := by
      simp only [List.length_map]; omega
    set x1 := ws ⟨iσ, by omega⟩ with hx1def
    have hxx1 : x < x1 := (hrange _).1
    have hx1w : x1 < w := hmono _ _ (Fin.mk_lt_mk.mpr hiσm)
    -- pin point type (folded through the class meet) and the charK anchor at the pin
    have hpin_raw := hpt' iσ (by omega)
    rw [kvE2_sep_getElem_left _ _ _ iσ hiσm, List.getElem_map, hgetiσ] at hpin_raw
    have hpt_pin := kvE2_sepClassType_eval_mem charBase charK M atomMap _ hpin_raw hsc
    have hanchor : (⟨charK (nfk_projFresh σ0)⟩ : TemporalPred).eval_at M atomMap x1 :=
      kvE2_sepPtX1L_anchor charBase charK σ0 M atomMap x1 hpt_pin
    -- below-witness clause: every zXU-positive 1-type strictly below the pin
    have hbelow : ∀ χ : NormalForm sig 0 1,
        σ0.2 (nf0_assemble kvE_sub2_zXU χ σ0.1) = true →
        ∃ u : M.carrier, x < u ∧ u < x1 ∧
          (⟨charBase χ⟩ : TemporalPred).eval_at M atomMap u := by
      intro χ hbit
      have hmemU : (KvE2SepSlot.lXU σ0 χ) ∈ kvE2_sepSlotsLOf wo :=
        kvE2_sepSlotsLOf_mem qnf hwo' hσI (kvE2_sep_lXU_mem_slotsLFor hz hbit)
      rw [← kvE2_sepTieGroupedL_flatten wo] at hmemU
      obtain ⟨d, hd, hsd⟩ := List.mem_flatten.mp hmemU
      obtain ⟨jχ, hjχ, hgetjχ⟩ := List.mem_iff_getElem.mp hd
      have hkey : kvE2_sepSlotGIdx wo (KvE2SepSlot.lXU σ0 χ)
          < kvE2_sepSlotGIdx wo (KvE2SepSlot.lX1 σ0) :=
        kvE2_sep_gidx_lt_of_rank_lt qnf hwo hpe
          (by rw [kvE2_sepSlotBlock]
              exact List.mem_append_left _ (kvE2_sep_lXU_mem_slotsLFor hz hbit))
          (by rw [kvE2_sepSlotBlock]
              exact List.mem_append_left _ (kvE2_sep_lX1_mem_slotsLFor hz))
          rfl Nat.zero_lt_one
      have hain : (KvE2SepSlot.lXU σ0 χ) ∈ (kvE2_sepTieGroupedL wo)[jχ]'hjχ := by
        rw [hgetjχ]; exact hsd
      have hbin : (KvE2SepSlot.lX1 σ0) ∈ (kvE2_sepTieGroupedL wo)[iσ]'hiσ := by
        rw [hgetiσ]; exact hsc
      have hji : jχ < iσ := kvE2_sepTieRuns_classIdx_lt (kvE2_sepSlotGIdx wo)
        (kvE2_sepSlotsLOf wo) hksortL hjχ hiσ hain hbin hkey
      have hjχm : jχ < ((kvE2_sepTieGroupedL wo).map
          (kvE2_sepClassType charBase charK)).length := by
        simp only [List.length_map]; omega
      refine ⟨ws ⟨jχ, by omega⟩, (hrange _).1,
        hmono _ _ (Fin.mk_lt_mk.mpr hji), ?_⟩
      have h1 := hpt' jχ (by omega)
      rw [kvE2_sep_getElem_left _ _ _ jχ hjχm, List.getElem_map, hgetjχ] at h1
      exact kvE2_sepClassType_eval_mem charBase charK M atomMap _ h1 hsd
    refine ⟨hepL, hepR, w, hxw, hwt, hptW, ?_, ?_⟩
    · intro σ hσ hzσ
      have hσeq : σ = σ0 := by rw [hfrag] at hσ; exact List.mem_singleton.mp hσ
      subst hσeq
      have h_off : ∀ τ : NormalForm sig 0 5, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false :=
        kvE2_sepHgate_offFiber qnf hg σ hσ0true
      -- gate clause (i): a positive sub's env-restriction equals `qnf.1`
      have hdrop : nf0_dropFresh σ.1 = qnf.1 := by
        by_contra hne
        rw [hg.1 σ hne] at hσ0true
        exact absurd hσ0true (by decide)
      -- the three outer points realize `qnf.1`'s coordinate 1-types (endpoint/point heads)
      have hprojW : nf_eval_nf M 0 1 (fun _ => w) (kvE2_sepProj3 qnf.1 ⟨0, by omega⟩) := by
        have h1 := hptW
        simp only [kvE2_sepPtW, TemporalPred.eval_at] at h1
        exact (nfPred_correct M atomMap h_surj _ w).mp
          ((formula_conjList_iff M atomMap w _).mp h1 _ List.mem_cons_self)
      have hprojX : nf_eval_nf M 0 1 (fun _ => x) (kvE2_sepProj3 qnf.1 ⟨1, by omega⟩) := by
        have h1 := hepL
        simp only [TemporalPred.eval_at] at h1
        exact (nfPred_correct M atomMap h_surj _ x).mp
          ((formula_conjList_iff M atomMap x _).mp h1 _ List.mem_cons_self)
      have hprojT : nf_eval_nf M 0 1 (fun _ => t) (kvE2_sepProj3 qnf.1 ⟨2, by omega⟩) := by
        have h1 := hepR
        simp only [TemporalPred.eval_at] at h1
        exact (nfPred_correct M atomMap h_surj _ t).mp
          ((formula_conjList_iff M atomMap t _).mp h1 _ List.mem_cons_self)
      have h_atom : nf_eval_nf M 0 4
          (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1 := by
        -- reconstruct σ.1 from its three Def-3.1 channels via per-atom congrFun bridges
        -- (the `nf0_assemble` order case does NOT simp-reduce — nested `Fin.cases` with motive —
        -- so we rewrite each σ.1 bit to a CLOSED qnf.1/zXW3 value before deciding it)
        have hpf : (nfk_projFresh σ).1 = nf0_projFresh σ.1 := by
          funext a
          match a with
          | .pred p i =>
            have hi : i = ⟨0, by omega⟩ := Subsingleton.elim i _
            subst hi; rfl
          | .order i j hij => exact absurd (Subsingleton.elim i j) hij
        obtain ⟨hc0a, -⟩ := hcorrK σ x1 hanchor
        -- normalize each raw σ.1 bit to a CLOSED value via congrFun on hdrop/hz
        -- (the `.succ` forms from mergeNF/zoneSpec are reduced back to Fin literals by
        --  `Fin.succ_mk` + `Nat.reduceAdd`, so the rewrites match the matched atom)
        intro a
        match a with
        | .pred p ⟨0, _⟩ =>
          have h1 := hc0a (.pred p ⟨0, by omega⟩)
          exact h1
        | .pred p ⟨1, _⟩ =>
          have e := congrFun hdrop (AtomKind.pred p ⟨0, by omega⟩)
          simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ, Fin.succ_mk, Nat.reduceAdd] at e
          rw [e]
          have h1 := hprojW (.pred p ⟨0, by omega⟩)
          exact h1
        | .pred p ⟨2, _⟩ =>
          have e := congrFun hdrop (AtomKind.pred p ⟨1, by omega⟩)
          simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ, Fin.succ_mk, Nat.reduceAdd] at e
          rw [e]
          have h1 := hprojX (.pred p ⟨0, by omega⟩)
          exact h1
        | .pred p ⟨3, _⟩ =>
          have e := congrFun hdrop (AtomKind.pred p ⟨2, by omega⟩)
          simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ, Fin.succ_mk, Nat.reduceAdd] at e
          rw [e]
          have h1 := hprojT (.pred p ⟨0, by omega⟩)
          exact h1
        | .order ⟨0, _⟩ ⟨1, _⟩ hne =>
          have hbit : σ.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ hne) = true := by
            exact congrArg Prod.fst (congrFun hz ⟨0, by omega⟩)
          rw [hbit]; simp only [atom_eval]
          exact iff_of_true hx1w (by decide)
        | .order ⟨0, _⟩ ⟨2, _⟩ hne =>
          have hbit : σ.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ hne) = false := by
            exact congrArg Prod.fst (congrFun hz ⟨1, by omega⟩)
          rw [hbit]; simp only [atom_eval]
          exact iff_of_false (lt_asymm hxx1) (by decide)
        | .order ⟨0, _⟩ ⟨3, _⟩ hne =>
          have hbit : σ.1 (.order ⟨0, by omega⟩ ⟨3, by omega⟩ hne) = true := by
            exact congrArg Prod.fst (congrFun hz ⟨2, by omega⟩)
          rw [hbit]; simp only [atom_eval]
          exact iff_of_true (hx1w.trans hwt) (by decide)
        | .order ⟨1, _⟩ ⟨0, _⟩ hne =>
          have hbit : σ.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ hne) = false := by
            exact congrArg Prod.snd (congrFun hz ⟨0, by omega⟩)
          rw [hbit]; simp only [atom_eval]
          exact iff_of_false (lt_asymm hx1w) (by decide)
        | .order ⟨2, _⟩ ⟨0, _⟩ hne =>
          have hbit : σ.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ hne) = true := by
            exact congrArg Prod.snd (congrFun hz ⟨1, by omega⟩)
          rw [hbit]; simp only [atom_eval]
          exact iff_of_true hxx1 (by decide)
        | .order ⟨3, _⟩ ⟨0, _⟩ hne =>
          have hbit : σ.1 (.order ⟨3, by omega⟩ ⟨0, by omega⟩ hne) = false := by
            exact congrArg Prod.snd (congrFun hz ⟨2, by omega⟩)
          rw [hbit]; simp only [atom_eval]
          exact iff_of_false (lt_asymm (hx1w.trans hwt)) (by decide)
        | .order ⟨1, _⟩ ⟨2, _⟩ hne =>
          have e := congrFun hdrop (AtomKind.order ⟨0, by omega⟩ ⟨1, by omega⟩
            (Fin.ne_of_val_ne (show (0 : ℕ) ≠ 1 by decide)))
          simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ, Fin.succ_mk, Nat.reduceAdd,
            h_yx] at e
          rw [e]; simp only [atom_eval]
          exact iff_of_false (lt_asymm (hxx1.trans hx1w)) (by decide)
        | .order ⟨2, _⟩ ⟨1, _⟩ hne =>
          have e := congrFun hdrop (AtomKind.order ⟨1, by omega⟩ ⟨0, by omega⟩
            (Fin.ne_of_val_ne (show (1 : ℕ) ≠ 0 by decide)))
          simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ, Fin.succ_mk, Nat.reduceAdd,
            h_xy] at e
          rw [e]; simp only [atom_eval]
          exact iff_of_true (hxx1.trans hx1w) (by decide)
        | .order ⟨1, _⟩ ⟨3, _⟩ hne =>
          have e := congrFun hdrop (AtomKind.order ⟨0, by omega⟩ ⟨2, by omega⟩
            (Fin.ne_of_val_ne (show (0 : ℕ) ≠ 2 by decide)))
          simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ, Fin.succ_mk, Nat.reduceAdd,
            h_yt] at e
          rw [e]; simp only [atom_eval]
          exact iff_of_true hwt (by decide)
        | .order ⟨3, _⟩ ⟨1, _⟩ hne =>
          have e := congrFun hdrop (AtomKind.order ⟨2, by omega⟩ ⟨0, by omega⟩
            (Fin.ne_of_val_ne (show (2 : ℕ) ≠ 0 by decide)))
          simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ, Fin.succ_mk, Nat.reduceAdd,
            h_ty] at e
          rw [e]; simp only [atom_eval]
          exact iff_of_false (lt_asymm hwt) (by decide)
        | .order ⟨2, _⟩ ⟨3, _⟩ hne =>
          have e := congrFun hdrop (AtomKind.order ⟨1, by omega⟩ ⟨2, by omega⟩
            (Fin.ne_of_val_ne (show (1 : ℕ) ≠ 2 by decide)))
          simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ, Fin.succ_mk, Nat.reduceAdd,
            h_xt] at e
          rw [e]; simp only [atom_eval]
          exact iff_of_true (hxx1.trans (hx1w.trans hwt)) (by decide)
        | .order ⟨3, _⟩ ⟨2, _⟩ hne =>
          have e := congrFun hdrop (AtomKind.order ⟨2, by omega⟩ ⟨1, by omega⟩
            (Fin.ne_of_val_ne (show (2 : ℕ) ≠ 1 by decide)))
          simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ, Fin.succ_mk, Nat.reduceAdd,
            h_tx] at e
          rw [e]; simp only [atom_eval]
          exact iff_of_false (lt_asymm (hxx1.trans (hx1w.trans hwt))) (by decide)
        | .order ⟨0, _⟩ ⟨0, _⟩ hne => exact absurd rfl hne
        | .order ⟨1, _⟩ ⟨1, _⟩ hne => exact absurd rfl hne
        | .order ⟨2, _⟩ ⟨2, _⟩ hne => exact absurd rfl hne
        | .order ⟨3, _⟩ ⟨3, _⟩ hne => exact absurd rfl hne
      have h_fwd : ∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1),
          (∃ v : M.carrier,
            zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
            nf_eval_nf M 0 1 (fun _ => v) χ) →
          σ.2 (nf0_assemble zs χ σ.1) = true := by
        rintro zs χ ⟨v, hzv, hχv⟩
        by_contra hbit
        rw [Bool.not_eq_true] at hbit
        have hχbase : (⟨charBase χ⟩ : TemporalPred).eval_at M atomMap v := by
          rw [hcb]; exact (nfPred_correct M atomMap h_surj χ v).mpr hχv
        have hws_le : ∀ (a b : ℕ) (ha : a < _) (hb : b < _), a ≤ b →
            ws ⟨a, ha⟩ ≤ ws ⟨b, hb⟩ := by
          intro a b ha hb hab
          rcases eq_or_lt_of_le hab with h | h
          · exact le_of_eq (congrArg ws (Fin.ext h))
          · exact le_of_lt (hmono _ _ (Fin.mk_lt_mk.mpr h))
        have hlenL : (kvE2_sepTieGroupedL wo).length
            = (List.map (kvE2_sepClassType charBase charK) (kvE2_sepTieGroupedL wo)).length := by
          rw [List.length_map]
        have hndL : (kvE2_sepTieGroupedL wo).flatten.Nodup := by
          rw [kvE2_sepTieGroupedL_flatten]; exact kvE2_sepSlotsLOf_nodup qnf hwo'
        have hsc' : (KvE2SepSlot.lX1 σ) ∈ (kvE2_sepTieGroupedL wo)[iσ]'hiσ := by
          rw [hgetiσ]; exact hsc
        have hσIn : σ ∈ kvE2_sepPosIn qnf kvE2_sep_zXW3 :=
          List.mem_filter.mpr ⟨hσ0pos, by simp only [decide_eq_true_eq]; exact hz⟩
        rcases kvE2_sep_locate_witness M ws v with ⟨j, hjv⟩ | hlow | ⟨i, hi1, hi2⟩ | hhigh
        · -- WITNESS case: `v = ws j` is a bracket point; its point type forces the χ-bit ON,
          -- contradicting `hbit`. `j`'s class index vs the pin `iσ` and `|gL|` fixes v's zone.
          subst hjv
          have hxv : x < ws j := (hrange j).1
          have hvt : ws j < t := (hrange j).2
          -- frag: every arrangement owner is σ, so every joint slot is one of σ's own slots
          have howner_eq : ∀ τ, τ ∈ kvE2_sepOrderOwners wo → τ = σ := by
            intro τ hτ
            have hτpos := ((kvE2_sepPosI_mem qnf τ).mp
              (kvE2_sepOrderOwners_mem_pos howners hτ)).1
            rw [hfrag] at hτpos; exact List.mem_singleton.mp hτpos
          have hLmem : ∀ s, s ∈ (kvE2_sepTieGroupedL wo).flatten → s ∈ kvE2_sepSlotsLFor σ := by
            intro s hs
            rw [kvE2_sepTieGroupedL_flatten, kvE2_sepSlotsLOf] at hs
            obtain ⟨τ, hτo, hsτ⟩ := List.mem_flatMap.mp ((List.mergeSort_perm _ _).mem_iff.mp hs)
            rw [howner_eq τ hτo] at hsτ; exact hsτ
          have hRmem : ∀ s, s ∈ (kvE2_sepTieGroupedR wo).flatten → s ∈ kvE2_sepSlotsRFor σ := by
            intro s hs
            rw [kvE2_sepTieGroupedR_flatten, kvE2_sepSlotsROf] at hs
            obtain ⟨τ, hτo, hsτ⟩ := List.mem_flatMap.mp ((List.mergeSort_perm _ _).mem_iff.mp hs)
            rw [howner_eq τ hτo] at hsτ; exact hsτ
          -- base-type uniqueness at `ws j` (nf_eval_unique): any realized `charBase χ'` is χ
          have hχeq : ∀ χ' : NormalForm sig 0 1,
              (⟨charBase χ'⟩ : TemporalPred).eval_at M atomMap (ws j) → χ' = χ := by
            intro χ' hb
            have hnf : nf_eval_nf M 0 1 (fun _ => ws j) χ' :=
              (nfPred_correct M atomMap h_surj χ' (ws j)).mp hb
            exact nf_eval_unique M 0 1 _ χ' χ hnf hχv
          rcases Nat.lt_trichotomy j.val (kvE2_sepTieGroupedL wo).length with hjm | hjm | hjm
          · -- LEFT group: point type is `classType gL[j]`; a member slot forces the bit
            have hjmap : j.val < (List.map (kvE2_sepClassType charBase charK)
                (kvE2_sepTieGroupedL wo)).length := by omega
            have hptj := hpt' j.val j.isLt
            rw [kvE2_sep_getElem_left _ _ _ j.val hjmap, List.getElem_map] at hptj
            have hne : (kvE2_sepTieGroupedL wo)[j.val]'hjm ≠ [] :=
              kvE2_sepTieGroupedL_ne_nil wo _ (List.getElem_mem hjm)
            obtain ⟨s, hsmem⟩ : ∃ s, s ∈ (kvE2_sepTieGroupedL wo)[j.val]'hjm :=
              ⟨_, List.head_mem hne⟩
            have hslotty := kvE2_sepClassType_eval_mem charBase charK M atomMap _ hptj hsmem
            have hsflat : s ∈ (kvE2_sepTieGroupedL wo).flatten :=
              List.mem_flatten.mpr ⟨_, List.getElem_mem hjm, hsmem⟩
            have hsF := hLmem s hsflat
            rw [kvE2_sepSlotsLFor, if_pos hz] at hsF
            rcases List.mem_append.mp hsF with hSX | hrest
            · -- s = .lXU σ χ' → zXU zone (j < iσ by gidx), bit true, contradiction
              obtain ⟨χ', hχ'S, rfl⟩ := List.mem_map.mp hSX
              have hχ'eq : χ' = χ := hχeq χ' hslotty
              rw [hχ'eq] at hχ'S hsmem
              have hbitXU : kvE2_sepBits σ kvE_sub2_zXU χ = true := (List.mem_filter.mp hχ'S).2
              have hkey : kvE2_sepSlotGIdx wo (KvE2SepSlot.lXU σ χ)
                  < kvE2_sepSlotGIdx wo (KvE2SepSlot.lX1 σ) :=
                kvE2_sep_gidx_lt_of_rank_lt qnf hwo hpe
                  (by rw [kvE2_sepSlotBlock]
                      exact List.mem_append_left _ (kvE2_sep_lXU_mem_slotsLFor hz hbitXU))
                  (by rw [kvE2_sepSlotBlock]
                      exact List.mem_append_left _ (kvE2_sep_lX1_mem_slotsLFor hz))
                  rfl Nat.zero_lt_one
              have hji : j.val < iσ := kvE2_sepTieRuns_classIdx_lt (kvE2_sepSlotGIdx wo)
                (kvE2_sepSlotsLOf wo) hksortL hjm hiσ hsmem hsc' hkey
              have hvx1 : ws j < x1 := by
                rw [hx1def]; exact hmono _ _ (Fin.mk_lt_mk.mpr hji)
              have hvw : ws j < w := hvx1.trans hx1w
              have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                  kvE_sub2_zXU (ws j) := by
                intro k
                match k with
                | ⟨0, _⟩ => exact ⟨iff_of_true hvx1 rfl, iff_of_false (lt_asymm hvx1)
                    (by decide +revert)⟩
                | ⟨1, _⟩ => exact ⟨iff_of_true hvw rfl, iff_of_false (lt_asymm hvw)
                    (by decide +revert)⟩
                | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxv) (by decide +revert), iff_of_true hxv
                    rfl⟩
                | ⟨3, _⟩ => exact ⟨iff_of_true hvt rfl, iff_of_false (lt_asymm hvt)
                    (by decide +revert)⟩
              have hzeq : zs = kvE_sub2_zXU := zoneHolds_unique M _ (ws j) zs _ hzv hpos
              rw [hzeq] at hbit
              simp only [kvE2_sepBits] at hbitXU
              exact Bool.false_ne_true (hbit.symm.trans hbitXU)
            · rcases List.mem_cons.mp hrest with rfl | hUW
              · -- s = .lX1 σ → j = iσ (pin uniqueness), ws j = x1, AT-x1 via ptX1L
                have hjeq : j.val = iσ := by
                  rcases Nat.lt_trichotomy j.val iσ with h | h | h
                  · exfalso
                    have hstrict := kvE2_sepTieRuns_key_strictMono (kvE2_sepSlotGIdx wo)
                      (kvE2_sepSlotsLOf wo) hksortL
                    have hlt := List.pairwise_iff_getElem.mp hstrict j.val iσ hjm hiσ h
                      (KvE2SepSlot.lX1 σ) hsmem (KvE2SepSlot.lX1 σ) hsc'
                    omega
                  · exact h
                  · exfalso
                    have hstrict := kvE2_sepTieRuns_key_strictMono (kvE2_sepSlotGIdx wo)
                      (kvE2_sepSlotsLOf wo) hksortL
                    have hlt := List.pairwise_iff_getElem.mp hstrict iσ j.val hiσ hjm h
                      (KvE2SepSlot.lX1 σ) hsc' (KvE2SepSlot.lX1 σ) hsmem
                    omega
                have hjx1 : ws j = x1 := by
                  rw [hx1def]; exact congrArg ws (Fin.ext hjeq)
                have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                    kvE2_sep_zAtX1L (ws j) := by
                  intro k
                  match k with
                  | ⟨0, _⟩ => exact ⟨iff_of_false (by rw [hjx1]; exact lt_irrefl x1)
                      (by decide +revert),
                      iff_of_false (by rw [hjx1]; exact lt_irrefl x1) (by decide +revert)⟩
                  | ⟨1, _⟩ => exact ⟨iff_of_true (by rw [hjx1]; exact hx1w) rfl,
                      iff_of_false (by rw [hjx1]; exact lt_asymm hx1w) (by decide +revert)⟩
                  | ⟨2, _⟩ => exact ⟨iff_of_false (by rw [hjx1]; exact lt_asymm hxx1)
                      (by decide +revert),
                      iff_of_true (by rw [hjx1]; exact hxx1) rfl⟩
                  | ⟨3, _⟩ => exact ⟨iff_of_true (by rw [hjx1]; exact hx1w.trans hwt) rfl,
                      iff_of_false (by rw [hjx1]; exact lt_asymm (hx1w.trans hwt))
                          (by decide +revert)⟩
                have hzeq : zs = kvE2_sep_zAtX1L := zoneHolds_unique M _ (ws j) zs _ hzv hpos
                have hlit := kvE2_sepPtX1L_owner_lit charBase charK σ M atomMap (ws j) hslotty χ
                have hbitX1 : kvE2_sepBits σ kvE2_sep_zAtX1L χ = false := by
                  rw [hzeq] at hbit; exact hbit
                rw [hbitX1] at hlit
                simp only [kvE2_sepLit, Bool.false_eq_true, if_false] at hlit
                exact hlit hχbase
              · -- s = .lUW σ χ' → zUW zone (iσ < j by gidx), bit true, contradiction
                obtain ⟨χ', hχ'S, rfl⟩ := List.mem_map.mp hUW
                have hχ'eq : χ' = χ := hχeq χ' hslotty
                rw [hχ'eq] at hχ'S hsmem
                have hbitUW : kvE2_sepBits σ kvE_sub2_zUW χ = true := (List.mem_filter.mp hχ'S).2
                have hkey : kvE2_sepSlotGIdx wo (KvE2SepSlot.lX1 σ)
                    < kvE2_sepSlotGIdx wo (KvE2SepSlot.lUW σ χ) :=
                  kvE2_sep_gidx_lt_of_rank_lt qnf hwo hpe
                    (by rw [kvE2_sepSlotBlock]
                        exact List.mem_append_left _ (kvE2_sep_lX1_mem_slotsLFor hz))
                    (by rw [kvE2_sepSlotBlock]
                        exact List.mem_append_left _ (kvE2_sep_lUW_mem_slotsLFor hz hbitUW))
                    rfl Nat.one_lt_two
                have hji : iσ < j.val := kvE2_sepTieRuns_classIdx_lt (kvE2_sepSlotGIdx wo)
                  (kvE2_sepSlotsLOf wo) hksortL hiσ hjm hsc' hsmem hkey
                have hx1v : x1 < ws j := by
                  rw [hx1def]; exact hmono _ _ (Fin.mk_lt_mk.mpr hji)
                have hvw : ws j < w := by
                  rw [hwdef]; exact hmono _ _ (Fin.mk_lt_mk.mpr hjmap)
                have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                    kvE_sub2_zUW (ws j) := by
                  intro k
                  match k with
                  | ⟨0, _⟩ => exact ⟨iff_of_false (lt_asymm hx1v) (by decide +revert), iff_of_true
                      hx1v rfl⟩
                  | ⟨1, _⟩ => exact ⟨iff_of_true hvw rfl, iff_of_false (lt_asymm hvw)
                      (by decide +revert)⟩
                  | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxv) (by decide +revert), iff_of_true
                      hxv rfl⟩
                  | ⟨3, _⟩ => exact ⟨iff_of_true hvt rfl, iff_of_false (lt_asymm hvt)
                      (by decide +revert)⟩
                have hzeq : zs = kvE_sub2_zUW := zoneHolds_unique M _ (ws j) zs _ hzv hpos
                rw [hzeq] at hbit
                simp only [kvE2_sepBits] at hbitUW
                exact Bool.false_ne_true (hbit.symm.trans hbitUW)
          · -- j = |gL| : ws j = w, AT-w case via ptW
            have hjw : ws j = w := by
              rw [hwdef]; exact congrArg ws (Fin.ext (hjm.trans hlenL))
            have hlit := kvE2_sepPtW_owner_lit charBase charK qnf M atomMap w σ hσIn hptW χ
            have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                kvE2_sep_zAtWL (ws j) := by
              intro k
              match k with
              | ⟨0, _⟩ => exact ⟨iff_of_false (by rw [hjw]; exact lt_asymm hx1w)
                  (by decide +revert),
                  iff_of_true (by rw [hjw]; exact hx1w) rfl⟩
              | ⟨1, _⟩ => exact ⟨iff_of_false (by rw [hjw]; exact lt_irrefl w) (by decide +revert),
                  iff_of_false (by rw [hjw]; exact lt_irrefl w) (by decide +revert)⟩
              | ⟨2, _⟩ => exact ⟨iff_of_false (by rw [hjw]; exact lt_asymm hxw) (by decide +revert),
                  iff_of_true (by rw [hjw]; exact hxw) rfl⟩
              | ⟨3, _⟩ => exact ⟨iff_of_true (by rw [hjw]; exact hwt) rfl,
                  iff_of_false (by rw [hjw]; exact lt_asymm hwt) (by decide +revert)⟩
            have hzeq : zs = kvE2_sep_zAtWL := zoneHolds_unique M _ (ws j) zs _ hzv hpos
            have hbitW : kvE2_sepBits σ kvE2_sep_zAtWL χ = false := by
              rw [hzeq] at hbit; exact hbit
            rw [hbitW] at hlit
            simp only [kvE2_sepLit, Bool.false_eq_true, if_false] at hlit
            exact hlit (by rw [← hjw]; exact hχbase)
          · -- RIGHT group: point type `classType gR[j']`; only `.lWT` slots → zWT zone
            set jr := j.val - (kvE2_sepTieGroupedL wo).length - 1 with hjrdef
            have hlenR : (kvE2_sepTieGroupedR wo).length =
                (List.map (kvE2_sepClassType charBase charK)
                (kvE2_sepTieGroupedR wo)).length := by rw [List.length_map]
            have hjlt : j.val < (List.map (kvE2_sepClassType charBase charK)
                  (kvE2_sepTieGroupedL wo)).length
                + (List.map (kvE2_sepClassType charBase charK) (kvE2_sepTieGroupedR wo)).length +
                    1 :=
              j.isLt
            have hjrR : jr < (kvE2_sepTieGroupedR wo).length := by omega
            have hjrRmap : jr < (List.map (kvE2_sepClassType charBase charK)
                (kvE2_sepTieGroupedR wo)).length := by omega
            have hK : (List.map (kvE2_sepClassType charBase charK) (kvE2_sepTieGroupedL wo)).length
                  + 1 + jr < (List.map (kvE2_sepClassType charBase charK)
                    (kvE2_sepTieGroupedL wo)).length
                + (List.map (kvE2_sepClassType charBase charK) (kvE2_sepTieGroupedR wo)).length +
                    1 :=
              by omega
            have hptj := hpt' ((List.map (kvE2_sepClassType charBase charK)
              (kvE2_sepTieGroupedL wo)).length + 1 + jr) hK
            rw [kvE2_sep_getElem_right _ _ _ jr hjrRmap, List.getElem_map] at hptj
            have hKeq : (List.map (kvE2_sepClassType charBase charK)
                (kvE2_sepTieGroupedL wo)).length + 1 + jr = j.val := by omega
            have hpteq : (ws ⟨(List.map (kvE2_sepClassType charBase charK)
                (kvE2_sepTieGroupedL wo)).length + 1 + jr, hK⟩ : M.carrier) = ws j :=
              congrArg ws (Fin.ext hKeq)
            rw [hpteq] at hptj
            have hne : (kvE2_sepTieGroupedR wo)[jr]'hjrR ≠ [] :=
              kvE2_sepTieGroupedR_ne_nil wo _ (List.getElem_mem hjrR)
            obtain ⟨s, hsmem⟩ : ∃ s, s ∈ (kvE2_sepTieGroupedR wo)[jr]'hjrR :=
              ⟨_, List.head_mem hne⟩
            have hslotty := kvE2_sepClassType_eval_mem charBase charK M atomMap _ hptj hsmem
            have hsflat : s ∈ (kvE2_sepTieGroupedR wo).flatten :=
              List.mem_flatten.mpr ⟨_, List.getElem_mem hjrR, hsmem⟩
            have hsF := hRmem s hsflat
            rw [kvE2_sepSlotsRFor, if_pos hz] at hsF
            obtain ⟨χ', hχ'S, rfl⟩ := List.mem_map.mp hsF
            have hχ'eq : χ' = χ := hχeq χ' hslotty
            rw [hχ'eq] at hχ'S
            have hbitWT : kvE2_sepBits σ kvE_sub2_zWT χ = true := (List.mem_filter.mp hχ'S).2
            have hwv : w < ws j := by
              rw [hwdef]; exact hmono _ _ (Fin.mk_lt_mk.mpr (by omega))
            have hx1v : x1 < ws j := hx1w.trans hwv
            have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                kvE_sub2_zWT (ws j) := by
              intro k
              match k with
              | ⟨0, _⟩ => exact ⟨iff_of_false (lt_asymm hx1v) (by decide +revert), iff_of_true hx1v
                  rfl⟩
              | ⟨1, _⟩ => exact ⟨iff_of_false (lt_asymm hwv) (by decide +revert), iff_of_true hwv
                  rfl⟩
              | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxv) (by decide +revert), iff_of_true hxv
                  rfl⟩
              | ⟨3, _⟩ => exact ⟨iff_of_true hvt rfl, iff_of_false (lt_asymm hvt)
                  (by decide +revert)⟩
            have hzeq : zs = kvE_sub2_zWT := zoneHolds_unique M _ (ws j) zs _ hzv hpos
            rw [hzeq] at hbit
            simp only [kvE2_sepBits] at hbitWT
            exact Bool.false_ne_true (hbit.symm.trans hbitWT)
        · -- hlow : v < ws 0
          rcases lt_or_ge x v with hxv | hvx
          · -- x < v < ws 0 ⊆ (x, x1) : zXU
            have hvx1 : v < x1 := by
              rcases Nat.eq_zero_or_pos iσ with h0 | hpos0
              · have hx1e : x1 = ws ⟨0, by omega⟩ := by rw [hx1def]; exact congrArg ws (Fin.ext h0)
                rw [hx1e]; exact hlow
              · exact hlow.trans (hmono _ _ (Fin.mk_lt_mk.mpr hpos0))
            have hvw : v < w := hvx1.trans hx1w
            have hvt : v < t := hvw.trans hwt
            have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                kvE_sub2_zXU v := by
              intro i
              match i with
              | ⟨0, _⟩ => exact ⟨iff_of_true hvx1 rfl, iff_of_false (lt_asymm hvx1)
                  (by decide +revert)⟩
              | ⟨1, _⟩ => exact ⟨iff_of_true hvw rfl, iff_of_false (lt_asymm hvw)
                  (by decide +revert)⟩
              | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxv) (by decide +revert), iff_of_true hxv
                  rfl⟩
              | ⟨3, _⟩ => exact ⟨iff_of_true hvt rfl, iff_of_false (lt_asymm hvt)
                  (by decide +revert)⟩
            have hzeq : zs = kvE_sub2_zXU := zoneHolds_unique M _ v zs kvE_sub2_zXU hzv hpos
            have hsegF : (⟨kvE2_sepSegForm charBase σ kvE_sub2_zXU⟩ : TemporalPred).eval_at M
                atomMap v := by
              have hh := hseg0 v hxv hlow
              simp only [kvE2_sepSegsG, kvE2_sepSegLAt, hfrag, List.map_cons, List.map_nil,
                List.take_zero, List.flatten_nil, List.length_nil, 
                kvE2_sepSegLForSub, hz, List.contains_nil, Nat.zero_le,
                Bool.false_eq_true, if_false, if_true] at hh
              exact (formula_conjList_iff M atomMap v _).mp hh _ List.mem_cons_self
            have hbitX : kvE2_sepBits σ kvE_sub2_zXU χ = false := by rw [hzeq] at hbit; exact hbit
            exact kvE2_sepSegForm_excludes charBase σ kvE_sub2_zXU χ M atomMap v hsegF hbitX hχbase
          · -- v ≤ x : boundary/exterior via hepL
            rcases lt_or_eq_of_le hvx with hvltx | hveqx
            · -- v < x : zPastX4, hepL Since-literal
              have hvx1 : v < x1 := hvltx.trans hxx1
              have hvw : v < w := hvltx.trans hxw
              have hvt : v < t := hvltx.trans (hxw.trans hwt)
              have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                  kvE2_sep_zPastX4 v := by
                intro k
                match k with
                | ⟨0, _⟩ => exact ⟨iff_of_true hvx1 rfl, iff_of_false (lt_asymm hvx1)
                    (by decide +revert)⟩
                | ⟨1, _⟩ => exact ⟨iff_of_true hvw rfl, iff_of_false (lt_asymm hvw)
                    (by decide +revert)⟩
                | ⟨2, _⟩ => exact ⟨iff_of_true hvltx rfl, iff_of_false (lt_asymm hvltx)
                    (by decide +revert)⟩
                | ⟨3, _⟩ => exact ⟨iff_of_true hvt rfl, iff_of_false (lt_asymm hvt)
                    (by decide +revert)⟩
              have hzeq : zs = kvE2_sep_zPastX4 := zoneHolds_unique M _ v zs _ hzv hpos
              have hbitP : kvE2_sepBits σ kvE2_sep_zPastX4 χ = false := by rw [hzeq] at hbit; exact
                  hbit
              have hlit := (kvE2_sepEpL_owner_lits charBase charK qnf M atomMap x σ hσIn hepL χ).1
              rw [hbitP] at hlit
              simp only [kvE2_sepLit, Bool.false_eq_true, if_false] at hlit
              exact hlit ⟨v, hvltx, hχbase, fun r _ _ hf => hf⟩
            · -- v = x : zAtX4, hepL at-x literal
              have hvx1 : v < x1 := by rw [hveqx]; exact hxx1
              have hvw : v < w := by rw [hveqx]; exact hxw
              have hvt : v < t := by rw [hveqx]; exact hxw.trans hwt
              have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                  kvE2_sep_zAtX4 v := by
                intro k
                match k with
                | ⟨0, _⟩ => exact ⟨iff_of_true hvx1 rfl, iff_of_false (lt_asymm hvx1)
                    (by decide +revert)⟩
                | ⟨1, _⟩ => exact ⟨iff_of_true hvw rfl, iff_of_false (lt_asymm hvw)
                    (by decide +revert)⟩
                | ⟨2, _⟩ => exact ⟨iff_of_false (by rw [hveqx]; exact lt_irrefl x)
                    (by decide +revert),
                    iff_of_false (by rw [hveqx]; exact lt_irrefl x) (by decide +revert)⟩
                | ⟨3, _⟩ => exact ⟨iff_of_true hvt rfl, iff_of_false (lt_asymm hvt)
                    (by decide +revert)⟩
              have hzeq : zs = kvE2_sep_zAtX4 := zoneHolds_unique M _ v zs _ hzv hpos
              have hbitA : kvE2_sepBits σ kvE2_sep_zAtX4 χ = false := by rw [hzeq] at hbit; exact
                  hbit
              have hlit := (kvE2_sepEpL_owner_lits charBase charK qnf M atomMap x σ hσIn hepL χ).2
              rw [hbitA] at hlit
              simp only [kvE2_sepLit, Bool.false_eq_true, if_false] at hlit
              rw [hveqx] at hχbase
              exact hlit hχbase
        · -- mid : ws ⟨i⟩ < v < ws ⟨i+1⟩
          have hsm := hsegMid i v hi1 hi2
          have hxv : x < v := lt_trans (hrange _).1 hi1
          by_cases hcut : (i : ℕ) + 1 ≤ (kvE2_sepTieGroupedL wo).length
          · -- left cut: v ∈ (x, w); zone zXU or zUW by pin index
            rw [kvE2_sepSegsG, if_pos hcut] at hsm
            simp only [kvE2_sepSegLAt, hfrag, List.map_cons, List.map_nil] at hsm
            have hseg1 := (formula_conjList_iff M atomMap v _).mp hsm _ List.mem_cons_self
            rw [kvE2_sepSegLForSub, if_pos hz, ← kvE2_sep_take_flatten_prefix] at hseg1
            have hvw : v < w := by
              rw [hwdef]; exact lt_of_lt_of_le hi2 (hws_le _ _ _ _ (by omega))
            have hvt : v < t := hvw.trans hwt
            by_cases hpin : iσ ≤ (i : ℕ)
            · -- pin ≤ i → v > x1 → zUW
              have hx1v : x1 < v := by
                rw [hx1def]; exact lt_of_le_of_lt (hws_le _ _ _ _ hpin) hi1
              have hmem : (KvE2SepSlot.lX1 σ) ∈ ((kvE2_sepTieGroupedL wo).take
                  ((i : ℕ) + 1)).flatten :=
                (kvE2_sep_pin_mem_take_flatten_iff _ hndL _ iσ hiσ hsc' _).mpr (by omega)
              rw [if_pos (List.contains_iff_mem.mpr hmem)] at hseg1
              have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                  kvE_sub2_zUW v := by
                intro k
                match k with
                | ⟨0, _⟩ => exact ⟨iff_of_false (lt_asymm hx1v) (by decide +revert), iff_of_true
                    hx1v rfl⟩
                | ⟨1, _⟩ => exact ⟨iff_of_true hvw rfl, iff_of_false (lt_asymm hvw)
                    (by decide +revert)⟩
                | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxv) (by decide +revert), iff_of_true hxv
                    rfl⟩
                | ⟨3, _⟩ => exact ⟨iff_of_true hvt rfl, iff_of_false (lt_asymm hvt)
                    (by decide +revert)⟩
              have hzeq : zs = kvE_sub2_zUW := zoneHolds_unique M _ v zs kvE_sub2_zUW hzv hpos
              have hbitU : kvE2_sepBits σ kvE_sub2_zUW χ = false := by rw [hzeq] at hbit; exact hbit
              exact kvE2_sepSegForm_excludes charBase σ kvE_sub2_zUW χ M atomMap v hseg1 hbitU
                  hχbase
            · -- pin > i → v < x1 → zXU
              have hvx1 : v < x1 := by
                rw [hx1def]; exact lt_of_lt_of_le hi2 (hws_le _ _ _ _ (by omega))
              have hnmem : (KvE2SepSlot.lX1 σ) ∉
                  ((kvE2_sepTieGroupedL wo).take ((i : ℕ) + 1)).flatten := by
                intro hc
                exact absurd ((kvE2_sep_pin_mem_take_flatten_iff _ hndL _ iσ hiσ hsc' _).mp hc)
                    (by omega)
              rw [if_neg (fun hc => hnmem (List.contains_iff_mem.mp hc))] at hseg1
              have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                  kvE_sub2_zXU v := by
                intro k
                match k with
                | ⟨0, _⟩ => exact ⟨iff_of_true hvx1 rfl, iff_of_false (lt_asymm hvx1)
                    (by decide +revert)⟩
                | ⟨1, _⟩ => exact ⟨iff_of_true hvw rfl, iff_of_false (lt_asymm hvw)
                    (by decide +revert)⟩
                | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxv) (by decide +revert), iff_of_true hxv
                    rfl⟩
                | ⟨3, _⟩ => exact ⟨iff_of_true hvt rfl, iff_of_false (lt_asymm hvt)
                    (by decide +revert)⟩
              have hzeq : zs = kvE_sub2_zXU := zoneHolds_unique M _ v zs kvE_sub2_zXU hzv hpos
              have hbitX : kvE2_sepBits σ kvE_sub2_zXU χ = false := by rw [hzeq] at hbit; exact hbit
              exact kvE2_sepSegForm_excludes charBase σ kvE_sub2_zXU χ M atomMap v hseg1 hbitX
                  hχbase
          · -- right cut: v ∈ (w, t) → zWT
            rw [kvE2_sepSegsG, if_neg hcut] at hsm
            simp only [kvE2_sepSegRAt, hfrag, List.map_cons, List.map_nil] at hsm
            have hseg1 := (formula_conjList_iff M atomMap v _).mp hsm _ List.mem_cons_self
            rw [kvE2_sepSegRForSub, if_pos hz] at hseg1
            have hwv : w < v := by
              rw [hwdef]; exact lt_of_le_of_lt (hws_le _ _ _ _ (by omega)) hi1
            have hvt : v < t := lt_trans hi2 (hrange _).2
            have hx1v : x1 < v := by
              rw [hx1def]; exact lt_of_le_of_lt (hws_le _ _ _ _ (by omega)) hi1
            have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                kvE_sub2_zWT v := by
              intro k
              match k with
              | ⟨0, _⟩ => exact ⟨iff_of_false (lt_asymm hx1v) (by decide +revert), iff_of_true hx1v
                  rfl⟩
              | ⟨1, _⟩ => exact ⟨iff_of_false (lt_asymm hwv) (by decide +revert), iff_of_true hwv
                  rfl⟩
              | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxv) (by decide +revert), iff_of_true hxv
                  rfl⟩
              | ⟨3, _⟩ => exact ⟨iff_of_true hvt rfl, iff_of_false (lt_asymm hvt)
                  (by decide +revert)⟩
            have hzeq : zs = kvE_sub2_zWT := zoneHolds_unique M _ v zs kvE_sub2_zWT hzv hpos
            have hbitW : kvE2_sepBits σ kvE_sub2_zWT χ = false := by rw [hzeq] at hbit; exact hbit
            exact kvE2_sepSegForm_excludes charBase σ kvE_sub2_zWT χ M atomMap v hseg1 hbitW hχbase
        · -- hhigh : ws ⟨last⟩ < v
          have hwv : w < v :=
            lt_of_le_of_lt (by rw [hwdef]; exact hws_le _ _ _ _ (by omega)) hhigh
          have hxv : x < v := lt_trans hxw hwv
          have hx1v : x1 < v := lt_trans hx1w hwv
          rcases lt_or_ge v t with hvltt | htlev
          · -- w < v < t → zWT via hsegLast
            have hsm := hsegLast v hhigh hvltt
            rw [kvE2_sepSegsG, if_neg (show ¬ _ from by simp only [hlenL]; omega)] at hsm
            simp only [kvE2_sepSegRAt, hfrag, List.map_cons, List.map_nil] at hsm
            have hseg1 := (formula_conjList_iff M atomMap v _).mp hsm _ List.mem_cons_self
            rw [kvE2_sepSegRForSub, if_pos hz] at hseg1
            have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                kvE_sub2_zWT v := by
              intro k
              match k with
              | ⟨0, _⟩ => exact ⟨iff_of_false (lt_asymm hx1v) (by decide +revert), iff_of_true hx1v
                  rfl⟩
              | ⟨1, _⟩ => exact ⟨iff_of_false (lt_asymm hwv) (by decide +revert), iff_of_true hwv
                  rfl⟩
              | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxv) (by decide +revert), iff_of_true hxv
                  rfl⟩
              | ⟨3, _⟩ => exact ⟨iff_of_true hvltt rfl, iff_of_false (lt_asymm hvltt)
                  (by decide +revert)⟩
            have hzeq : zs = kvE_sub2_zWT := zoneHolds_unique M _ v zs kvE_sub2_zWT hzv hpos
            have hbitW : kvE2_sepBits σ kvE_sub2_zWT χ = false := by rw [hzeq] at hbit; exact hbit
            exact kvE2_sepSegForm_excludes charBase σ kvE_sub2_zWT χ M atomMap v hseg1 hbitW hχbase
          · -- t ≤ v : boundary/exterior via hepR
            rcases lt_or_eq_of_le htlev with htltv | hteqv
            · -- t < v : zFutT4, hepR Until-literal
              have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                  kvE2_sep_zFutT4 v := by
                intro k
                match k with
                | ⟨0, _⟩ => exact ⟨iff_of_false (lt_asymm hx1v) (by decide +revert), iff_of_true
                    hx1v rfl⟩
                | ⟨1, _⟩ => exact ⟨iff_of_false (lt_asymm hwv) (by decide +revert), iff_of_true hwv
                    rfl⟩
                | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxv) (by decide +revert), iff_of_true hxv
                    rfl⟩
                | ⟨3, _⟩ => exact ⟨iff_of_false (lt_asymm htltv) (by decide +revert), iff_of_true
                    htltv rfl⟩
              have hzeq : zs = kvE2_sep_zFutT4 := zoneHolds_unique M _ v zs _ hzv hpos
              have hbitF : kvE2_sepBits σ kvE2_sep_zFutT4 χ = false := by rw [hzeq] at hbit; exact
                  hbit
              have hlit := (kvE2_sepEpR_owner_lits charBase charK qnf M atomMap t σ hσIn hepR χ).2
              rw [hbitF] at hlit
              simp only [kvE2_sepLit, Bool.false_eq_true, if_false] at hlit
              exact hlit ⟨v, htltv, hχbase, fun r _ _ hf => hf⟩
            · -- v = t : zAtT4, hepR at-t literal
              have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                  kvE2_sep_zAtT4 v := by
                intro k
                match k with
                | ⟨0, _⟩ => exact ⟨iff_of_false (lt_asymm hx1v) (by decide +revert), iff_of_true
                    hx1v rfl⟩
                | ⟨1, _⟩ => exact ⟨iff_of_false (lt_asymm hwv) (by decide +revert), iff_of_true hwv
                    rfl⟩
                | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxv) (by decide +revert), iff_of_true hxv
                    rfl⟩
                | ⟨3, _⟩ => exact ⟨iff_of_false (by rw [← hteqv]; exact lt_irrefl t)
                    (by decide +revert),
                    iff_of_false (by rw [← hteqv]; exact lt_irrefl t) (by decide +revert)⟩
              have hzeq : zs = kvE2_sep_zAtT4 := zoneHolds_unique M _ v zs _ hzv hpos
              have hbitAT : kvE2_sepBits σ kvE2_sep_zAtT4 χ = false := by rw [hzeq] at hbit; exact
                  hbit
              have hlit := (kvE2_sepEpR_owner_lits charBase charK qnf M atomMap t σ hσIn hepR χ).1
              rw [hbitAT] at hlit
              simp only [kvE2_sepLit, Bool.false_eq_true, if_false] at hlit
              rw [← hteqv] at hχbase
              exact hlit hχbase
      have h_bwd : ∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1), zs ≠ kvE_sub2_zXU →
          σ.2 (nf0_assemble zs χ σ.1) = true →
          ∃ v : M.carrier,
            zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
            nf_eval_nf M 0 1 (fun _ => v) χ := by
        intro zs χ hzsne hbit
        have hσIn : σ ∈ kvE2_sepPosIn qnf kvE2_sep_zXW3 :=
          List.mem_filter.mpr ⟨hσ0pos, by simp only [decide_eq_true_eq]; exact hz⟩
        have tonf : ∀ (v : M.carrier),
            temporal_truth M atomMap v (charBase χ) → nf_eval_nf M 0 1 (fun _ => v) χ := by
          intro v hv; rw [hcb] at hv; exact (nfPred_correct M atomMap h_surj χ v).mp hv
        -- classify: a true bit forces `zs` among the nine inner-consistent zones (gate clause iv)
        have hcons : kvE2_sepInnerConsistentL zs := by
          by_contra hncons
          rw [hg.2.2.2.1 σ hσ0true hz zs χ hncons] at hbit
          exact absurd hbit (by decide)
        rcases hcons with h | h | h | h | h | h | h | h | h
        · -- zPastX4  (v < x)
          have hzp : zs = kvE2_sep_zPastX4 := h
          rw [hzp] at hbit ⊢
          have hbitT : kvE2_sepBits σ kvE2_sep_zPastX4 χ = true := hbit
          have hlit := (kvE2_sepEpL_owner_lits charBase charK qnf M atomMap x σ hσIn hepL χ).1
          rw [hbitT] at hlit
          simp only [kvE2_sepLit, if_true] at hlit
          obtain ⟨s, hsx, hχs, -⟩ := hlit
          have hsx1 : s < x1 := hsx.trans hxx1
          have hsw : s < w := hsx.trans hxw
          have hst : s < t := hsx.trans (hxw.trans hwt)
          refine ⟨s, ?_, tonf _ hχs⟩
          intro k
          match k with
          | ⟨0, _⟩ => exact ⟨iff_of_true hsx1 rfl, iff_of_false (lt_asymm hsx1) (by decide +revert)⟩
          | ⟨1, _⟩ => exact ⟨iff_of_true hsw rfl, iff_of_false (lt_asymm hsw) (by decide +revert)⟩
          | ⟨2, _⟩ => exact ⟨iff_of_true hsx rfl, iff_of_false (lt_asymm hsx) (by decide +revert)⟩
          | ⟨3, _⟩ => exact ⟨iff_of_true hst rfl, iff_of_false (lt_asymm hst) (by decide +revert)⟩
        · -- zAtX4  (v = x)
          have hzx : zs = kvE2_sep_zAtX4 := h
          rw [hzx] at hbit ⊢
          have hbitT : kvE2_sepBits σ kvE2_sep_zAtX4 χ = true := hbit
          have hlit := (kvE2_sepEpL_owner_lits charBase charK qnf M atomMap x σ hσIn hepL χ).2
          rw [hbitT] at hlit
          simp only [kvE2_sepLit, if_true] at hlit
          refine ⟨x, ?_, tonf _ hlit⟩
          intro k
          match k with
          | ⟨0, _⟩ => exact ⟨iff_of_true hxx1 rfl, iff_of_false (lt_asymm hxx1) (by decide +revert)⟩
          | ⟨1, _⟩ => exact ⟨iff_of_true hxw rfl, iff_of_false (lt_asymm hxw) (by decide +revert)⟩
          | ⟨2, _⟩ => exact ⟨iff_of_false (lt_irrefl x) (by decide +revert),
              iff_of_false (lt_irrefl x) (by decide +revert)⟩
          | ⟨3, _⟩ => exact ⟨iff_of_true (hxw.trans hwt) rfl,
              iff_of_false (lt_asymm (hxw.trans hwt)) (by decide +revert)⟩
        · -- zXU  (excluded by hypothesis)
          exact absurd h hzsne
        · -- zAtX1L  (v = x1)
          have hzx1 : zs = kvE2_sep_zAtX1L := h
          rw [hzx1] at hbit ⊢
          have hbitT : kvE2_sepBits σ kvE2_sep_zAtX1L χ = true := hbit
          have hlit := kvE2_sepPtX1L_owner_lit charBase charK σ M atomMap x1 hpt_pin χ
          rw [hbitT] at hlit
          simp only [kvE2_sepLit, if_true] at hlit
          refine ⟨x1, ?_, tonf _ hlit⟩
          intro k
          match k with
          | ⟨0, _⟩ => exact ⟨iff_of_false (lt_irrefl x1) (by decide +revert),
              iff_of_false (lt_irrefl x1) (by decide +revert)⟩
          | ⟨1, _⟩ => exact ⟨iff_of_true hx1w rfl, iff_of_false (lt_asymm hx1w) (by decide +revert)⟩
          | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxx1) (by decide +revert), iff_of_true hxx1 rfl⟩
          | ⟨3, _⟩ => exact ⟨iff_of_true (hx1w.trans hwt) rfl,
              iff_of_false (lt_asymm (hx1w.trans hwt)) (by decide +revert)⟩
        · -- zUW  (x1 < v < w) : mirror of `hbelow`, with the `.lUW` slot above the pin
          have hzuw : zs = kvE_sub2_zUW := h
          rw [hzuw] at hbit ⊢
          have hbitT : σ.2 (nf0_assemble kvE_sub2_zUW χ σ.1) = true := hbit
          have hmemU : (KvE2SepSlot.lUW σ χ) ∈ kvE2_sepSlotsLOf wo :=
            kvE2_sepSlotsLOf_mem qnf hwo' hσI (kvE2_sep_lUW_mem_slotsLFor hz hbitT)
          rw [← kvE2_sepTieGroupedL_flatten wo] at hmemU
          obtain ⟨d, hd, hsd⟩ := List.mem_flatten.mp hmemU
          obtain ⟨jχ, hjχ, hgetjχ⟩ := List.mem_iff_getElem.mp hd
          have hkey : kvE2_sepSlotGIdx wo (KvE2SepSlot.lX1 σ)
              < kvE2_sepSlotGIdx wo (KvE2SepSlot.lUW σ χ) :=
            kvE2_sep_gidx_lt_of_rank_lt qnf hwo hpe
              (by rw [kvE2_sepSlotBlock]
                  exact List.mem_append_left _ (kvE2_sep_lX1_mem_slotsLFor hz))
              (by rw [kvE2_sepSlotBlock]
                  exact List.mem_append_left _ (kvE2_sep_lUW_mem_slotsLFor hz hbitT))
              rfl Nat.one_lt_two
          have hain : (KvE2SepSlot.lUW σ χ) ∈ (kvE2_sepTieGroupedL wo)[jχ]'hjχ := by
            rw [hgetjχ]; exact hsd
          have hbin : (KvE2SepSlot.lX1 σ) ∈ (kvE2_sepTieGroupedL wo)[iσ]'hiσ := by
            rw [hgetiσ]; exact hsc
          have hij : iσ < jχ := kvE2_sepTieRuns_classIdx_lt (kvE2_sepSlotGIdx wo)
            (kvE2_sepSlotsLOf wo) hksortL hiσ hjχ hbin hain hkey
          have hjχm : jχ < ((kvE2_sepTieGroupedL wo).map
              (kvE2_sepClassType charBase charK)).length := by
            simp only [List.length_map]; omega
          have hjtot : jχ < ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length
              + ((kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK)).length + 1 := by
                  omega
          have hx1v : x1 < ws ⟨jχ, hjtot⟩ := by
            rw [hx1def]; exact hmono _ _ (Fin.mk_lt_mk.mpr hij)
          have hvw : ws ⟨jχ, hjtot⟩ < w := by
            rw [hwdef]; exact hmono _ _ (Fin.mk_lt_mk.mpr hjχm)
          have hxv : x < ws ⟨jχ, hjtot⟩ := (hrange _).1
          have hvt : ws ⟨jχ, hjtot⟩ < t := (hrange _).2
          have hchar := hpt' jχ hjtot
          rw [kvE2_sep_getElem_left _ _ _ jχ hjχm, List.getElem_map, hgetjχ] at hchar
          have hcharχ := kvE2_sepClassType_eval_mem charBase charK M atomMap _ hchar hsd
          refine ⟨ws ⟨jχ, hjtot⟩, ?_, tonf _ hcharχ⟩
          intro k
          match k with
          | ⟨0, _⟩ => exact ⟨iff_of_false (lt_asymm hx1v) (by decide +revert), iff_of_true hx1v rfl⟩
          | ⟨1, _⟩ => exact ⟨iff_of_true hvw rfl, iff_of_false (lt_asymm hvw) (by decide +revert)⟩
          | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxv) (by decide +revert), iff_of_true hxv rfl⟩
          | ⟨3, _⟩ => exact ⟨iff_of_true hvt rfl, iff_of_false (lt_asymm hvt) (by decide +revert)⟩
        · -- zAtWL  (v = w)
          have hzw : zs = kvE2_sep_zAtWL := h
          rw [hzw] at hbit ⊢
          have hbitT : kvE2_sepBits σ kvE2_sep_zAtWL χ = true := hbit
          have hlit := kvE2_sepPtW_owner_lit charBase charK qnf M atomMap w σ hσIn hptW χ
          rw [hbitT] at hlit
          simp only [kvE2_sepLit, if_true] at hlit
          refine ⟨w, ?_, tonf _ hlit⟩
          intro k
          match k with
          | ⟨0, _⟩ => exact ⟨iff_of_false (lt_asymm hx1w) (by decide +revert), iff_of_true hx1w rfl⟩
          | ⟨1, _⟩ => exact ⟨iff_of_false (lt_irrefl w) (by decide +revert),
              iff_of_false (lt_irrefl w) (by decide +revert)⟩
          | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxw) (by decide +revert), iff_of_true hxw rfl⟩
          | ⟨3, _⟩ => exact ⟨iff_of_true hwt rfl, iff_of_false (lt_asymm hwt) (by decide +revert)⟩
        · -- zWT  (w < v < t) : right-group slot machinery
          have hzwt : zs = kvE_sub2_zWT := h
          rw [hzwt] at hbit ⊢
          have hbitT : σ.2 (nf0_assemble kvE_sub2_zWT χ σ.1) = true := hbit
          have hlWT : (KvE2SepSlot.lWT σ χ) ∈ kvE2_sepSlotsRFor σ := by
            rw [kvE2_sepSlotsRFor, if_pos hz]
            exact List.mem_map_of_mem (List.mem_filter.mpr ⟨by simp, hbitT⟩)
          have hmemR : (KvE2SepSlot.lWT σ χ) ∈ kvE2_sepSlotsROf wo :=
            kvE2_sepSlotsROf_mem qnf hwo' hσI hlWT
          rw [← kvE2_sepTieGroupedR_flatten wo] at hmemR
          obtain ⟨d, hd, hsd⟩ := List.mem_flatten.mp hmemR
          obtain ⟨jr, hjr, hgetjr⟩ := List.mem_iff_getElem.mp hd
          have hjrRmap : jr < ((kvE2_sepTieGroupedR wo).map
              (kvE2_sepClassType charBase charK)).length := by
            simp only [List.length_map]; omega
          have hK : ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length + 1 +
              jr
              < ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length
                + ((kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK)).length + 1 := by
            simp only [List.length_map] at hjrRmap ⊢; omega
          have hchar := hpt' (((kvE2_sepTieGroupedL wo).map
              (kvE2_sepClassType charBase charK)).length
            + 1 + jr) hK
          rw [kvE2_sep_getElem_right _ _ _ jr hjrRmap, List.getElem_map] at hchar
          have hain : (KvE2SepSlot.lWT σ χ) ∈ (kvE2_sepTieGroupedR wo)[jr]'hjr := by
            rw [hgetjr]; exact hsd
          have hcharχ := kvE2_sepClassType_eval_mem charBase charK M atomMap _ hchar hain
          set v := ws ⟨((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length + 1
              + jr,
            hK⟩ with hvdef
          have hwv : w < v := by
            rw [hwdef, hvdef]; exact hmono _ _ (Fin.mk_lt_mk.mpr (by omega))
          have hvt : v < t := (hrange _).2
          have hx1v : x1 < v := hx1w.trans hwv
          have hxv : x < v := hxw.trans hwv
          refine ⟨v, ?_, tonf _ hcharχ⟩
          intro k
          match k with
          | ⟨0, _⟩ => exact ⟨iff_of_false (lt_asymm hx1v) (by decide +revert), iff_of_true hx1v rfl⟩
          | ⟨1, _⟩ => exact ⟨iff_of_false (lt_asymm hwv) (by decide +revert), iff_of_true hwv rfl⟩
          | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxv) (by decide +revert), iff_of_true hxv rfl⟩
          | ⟨3, _⟩ => exact ⟨iff_of_true hvt rfl, iff_of_false (lt_asymm hvt) (by decide +revert)⟩
        · -- zAtT4  (v = t)
          have hzt : zs = kvE2_sep_zAtT4 := h
          rw [hzt] at hbit ⊢
          have hbitT : kvE2_sepBits σ kvE2_sep_zAtT4 χ = true := hbit
          have hlit := (kvE2_sepEpR_owner_lits charBase charK qnf M atomMap t σ hσIn hepR χ).1
          rw [hbitT] at hlit
          simp only [kvE2_sepLit, if_true] at hlit
          refine ⟨t, ?_, tonf _ hlit⟩
          intro k
          match k with
          | ⟨0, _⟩ => exact ⟨iff_of_false (lt_asymm (hx1w.trans hwt)) (by decide +revert),
              iff_of_true (hx1w.trans hwt) rfl⟩
          | ⟨1, _⟩ => exact ⟨iff_of_false (lt_asymm hwt) (by decide +revert), iff_of_true hwt rfl⟩
          | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm (hxw.trans hwt)) (by decide +revert),
              iff_of_true (hxw.trans hwt) rfl⟩
          | ⟨3, _⟩ => exact ⟨iff_of_false (lt_irrefl t) (by decide +revert),
              iff_of_false (lt_irrefl t) (by decide +revert)⟩
        · -- zFutT4  (t < v)
          have hzf : zs = kvE2_sep_zFutT4 := h
          rw [hzf] at hbit ⊢
          have hbitT : kvE2_sepBits σ kvE2_sep_zFutT4 χ = true := hbit
          have hlit := (kvE2_sepEpR_owner_lits charBase charK qnf M atomMap t σ hσIn hepR χ).2
          rw [hbitT] at hlit
          simp only [kvE2_sepLit, if_true] at hlit
          obtain ⟨u, htu, hχu, -⟩ := hlit
          have hu_x1 : x1 < u := (hx1w.trans hwt).trans htu
          have hu_w : w < u := hwt.trans htu
          have hu_x : x < u := (hxw.trans hwt).trans htu
          refine ⟨u, ?_, tonf _ hχu⟩
          intro k
          match k with
          | ⟨0, _⟩ => exact ⟨iff_of_false (lt_asymm hu_x1) (by decide +revert), iff_of_true hu_x1
              rfl⟩
          | ⟨1, _⟩ => exact ⟨iff_of_false (lt_asymm hu_w) (by decide +revert), iff_of_true hu_w rfl⟩
          | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hu_x) (by decide +revert), iff_of_true hu_x rfl⟩
          | ⟨3, _⟩ => exact ⟨iff_of_false (lt_asymm htu) (by decide +revert), iff_of_true htu rfl⟩
      exact kvE2_sepBundleL_sound_frag atomMap h_surj σ M w x t hwt x1 hx1w hbelow
        h_atom h_off h_fwd h_bwd
    · intro σ hσ hzσ
      have hσeq : σ = σ0 := by rw [hfrag] at hσ; exact List.mem_singleton.mp hσ
      subst hσeq
      rw [hz] at hzσ
      exact absurd hzσ (by decide)
  · rw [kvE2_sepBody_gate_fail charBase charK qnf hg] at h
    simp [VVecEA2.holds] at h

-- ============================================================================
-- R2: RIGHT pin-anchored fragment gate producer + fold.
--   Resolution R2: kvE2_sepGateAtPin_fragR takes an extra explicit hypothesis
--   hInnerR (the zWT3 analog of gate clause iv), threaded through
--   kvE2_sepBody_kit_sound_frag and kvE2_outer_fold_frag — an undischarged
--   obligation for the downstream provider (which lands the discharge machinery). Additive-only.
-- ============================================================================

/-- A right-interior σ's `(x,w)`-region `.rXW` slot is in its canonical LEFT block. -/
theorem kvE2_sep_rXW_mem_slotsLFor {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    {σ : NormalForm sig 1 4} (hzone : nf0_zoneSpec σ.1 = kvE2_sep_zWT3)
    {χ : NormalForm sig 0 1} (hbit : σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true) :
    (.rXW σ χ : KvE2SepSlot sig) ∈ kvE2_sepSlotsLFor σ := by
  unfold kvE2_sepSlotsLFor
  rw [hzone, if_neg kvE2_sep_zWT3_ne_zXW3, if_pos rfl]
  exact List.mem_map_of_mem (List.mem_filter.mpr ⟨by simp, hbit⟩)

/-- A right-interior σ's `(x1,t)`-region `.rX1T` slot is in its canonical RIGHT block. -/
theorem kvE2_sep_rX1T_mem_slotsRFor {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    {σ : NormalForm sig 1 4} (hzone : nf0_zoneSpec σ.1 = kvE2_sep_zWT3)
    {χ : NormalForm sig 0 1} (hbit : σ.2 (nf0_assemble kvE_sub2_zWT χ σ.1) = true) :
    (.rX1T σ χ : KvE2SepSlot sig) ∈ kvE2_sepSlotsRFor σ := by
  unfold kvE2_sepSlotsRFor
  rw [hzone, if_neg kvE2_sep_zWT3_ne_zXW3, if_pos rfl]
  exact List.mem_append.mpr (Or.inr (List.mem_cons.mpr
    (Or.inr (List.mem_map_of_mem (List.mem_filter.mpr ⟨by simp, hbit⟩)))))

/-- RIGHT-owner variant of `kvE2_sepEpL_owner_lits` (`hσ` ranges over the `zWT3` positive list;
    the only change is the `Or.inr` at the `hσsrc` append). -/
theorem kvE2_sepEpL_owner_lits_R {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (x : M.carrier) (σ : NormalForm sig 1 4) (hσ : σ ∈ kvE2_sepPosIn qnf kvE2_sep_zWT3)
    (hep : (kvE2_sepEpL charBase charK qnf).eval_at M atomMap x) (χ : NormalForm sig 0 1) :
    temporal_truth M atomMap x
        (kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zPastX4 χ) (Formula.snce (charBase χ) Formula.top))
      ∧ temporal_truth M atomMap x
        (kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zAtX4 χ) (charBase χ)) := by
  have hep' : temporal_truth M atomMap x (kvE2_sepEpL charBase charK qnf).formula := hep
  simp only [kvE2_sepEpL] at hep'
  have hall := (formula_conjList_iff M atomMap x _).mp hep'
  have hσsrc : σ ∈ kvE2_sepPosIn qnf kvE2_sep_zXW3 ++ kvE2_sepPosIn qnf kvE2_sep_zWT3 :=
    List.mem_append.mpr (Or.inr hσ)
  have hχu : χ ∈ (Finset.univ.toList : List (NormalForm sig 0 1)) :=
    Finset.mem_toList.mpr (Finset.mem_univ _)
  refine ⟨hall _ (List.mem_append.mpr (Or.inr (List.mem_flatMap.mpr ⟨σ, hσsrc, ?_⟩))),
    hall _ (List.mem_append.mpr (Or.inr (List.mem_flatMap.mpr ⟨σ, hσsrc, ?_⟩)))⟩
  · exact List.mem_cons.mpr (Or.inr (List.mem_append.mpr (Or.inl
      (List.mem_map.mpr ⟨χ, hχu, rfl⟩))))
  · exact List.mem_cons.mpr (Or.inr (List.mem_append.mpr (Or.inr
      (List.mem_map.mpr ⟨χ, hχu, rfl⟩))))

/-- RIGHT-owner variant of `kvE2_sepEpR_owner_lits`. -/
theorem kvE2_sepEpR_owner_lits_R {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (t : M.carrier) (σ : NormalForm sig 1 4) (hσ : σ ∈ kvE2_sepPosIn qnf kvE2_sep_zWT3)
    (hep : (kvE2_sepEpR charBase charK qnf).eval_at M atomMap t) (χ : NormalForm sig 0 1) :
    temporal_truth M atomMap t
        (kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zAtT4 χ) (charBase χ))
      ∧ temporal_truth M atomMap t
        (kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zFutT4 χ)
            (Formula.untl (charBase χ) Formula.top)) := by
  have hep' : temporal_truth M atomMap t (kvE2_sepEpR charBase charK qnf).formula := hep
  simp only [kvE2_sepEpR] at hep'
  have hall := (formula_conjList_iff M atomMap t _).mp hep'
  have hσsrc : σ ∈ kvE2_sepPosIn qnf kvE2_sep_zXW3 ++ kvE2_sepPosIn qnf kvE2_sep_zWT3 :=
    List.mem_append.mpr (Or.inr hσ)
  have hχu : χ ∈ (Finset.univ.toList : List (NormalForm sig 0 1)) :=
    Finset.mem_toList.mpr (Finset.mem_univ _)
  refine ⟨hall _ (List.mem_append.mpr (Or.inr (List.mem_flatMap.mpr ⟨σ, hσsrc, ?_⟩))),
    hall _ (List.mem_append.mpr (Or.inr (List.mem_flatMap.mpr ⟨σ, hσsrc, ?_⟩)))⟩
  · exact List.mem_cons.mpr (Or.inr (List.mem_append.mpr (Or.inl
      (List.mem_map.mpr ⟨χ, hχu, rfl⟩))))
  · exact List.mem_cons.mpr (Or.inr (List.mem_append.mpr (Or.inr
      (List.mem_map.mpr ⟨χ, hχu, rfl⟩))))

/-- RIGHT-owner variant of `kvE2_sepPtW_owner_lit`. -/
theorem kvE2_sepPtW_owner_lit_R {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w : M.carrier) (σ : NormalForm sig 1 4) (hσ : σ ∈ kvE2_sepPosIn qnf kvE2_sep_zWT3)
    (hep : (kvE2_sepPtW charBase charK qnf).eval_at M atomMap w) (χ : NormalForm sig 0 1) :
    temporal_truth M atomMap w
      (kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zAtWR χ) (charBase χ)) := by
  have hep' : temporal_truth M atomMap w (kvE2_sepPtW charBase charK qnf).formula := hep
  simp only [kvE2_sepPtW] at hep'
  have hall := (formula_conjList_iff M atomMap w _).mp hep'
  have hχu : χ ∈ (Finset.univ.toList : List (NormalForm sig 0 1)) :=
    Finset.mem_toList.mpr (Finset.mem_univ _)
  exact hall _ (List.mem_cons.mpr (Or.inr (List.mem_append.mpr (Or.inr
    (List.mem_flatMap.mpr ⟨σ, hσ,
      List.mem_cons.mpr (Or.inr (List.mem_map.mpr ⟨χ, hχu, rfl⟩))⟩)))))

/-- Extract the per-owner `zAtX1R` at-`x1` literal for owner `σ` from a realized `kvE2_sepPtX1R`
    at the pin `x1` (mirror of `kvE2_sepPtX1L_owner_lit`). -/
theorem kvE2_sepPtX1R_owner_lit {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (x1 : M.carrier)
    (hep : (kvE2_sepPtX1R charBase charK σ).eval_at M atomMap x1) (χ : NormalForm sig 0 1) :
    temporal_truth M atomMap x1
      (kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zAtX1R χ) (charBase χ)) := by
  have hep' : temporal_truth M atomMap x1 (kvE2_sepPtX1R charBase charK σ).formula := hep
  simp only [kvE2_sepPtX1R] at hep'
  have hall := (formula_conjList_iff M atomMap x1 _).mp hep'
  have hχu : χ ∈ (Finset.univ.toList : List (NormalForm sig 0 1)) :=
    Finset.mem_toList.mpr (Finset.mem_univ _)
  exact hall _ (List.mem_cons.mpr (Or.inr (List.mem_map.mpr ⟨χ, hχu, rfl⟩)))

/-- **RIGHT pin-anchored gate producer** (R2 mirror of
    `kvE2_sepGateAtPin_fragL`). Sole positive `σ0` is RIGHT-interior (`hz : … = kvE2_sep_zWT3`),
    pin `x1` with `w < x1 < t` extracted from the RIGHT group, backward-exception zone
    `kvE2_sep_zWX1`, closer `kvE2_sepBundleR_sound_frag`. The `h_bwd` zone classification is
    recovered from gate clause (v) (`hg.2.2.2.2`, the zWT3 mirror of clause iv) — dissolving
    the former free `hInnerR` obligation into this gate consequence. Additive;
    `hcorrK` explicit, never discharged here. -/
theorem kvE2_sepGateAtPin_fragR {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    (h_xy : qnf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig)
    (x t : M.carrier)
    (σ0 : NormalForm sig 1 4)
    (hfrag : kvE2_sepPos qnf = [σ0])
    (hz : nf0_zoneSpec σ0.1 = kvE2_sep_zWT3)
    (hcorrK : ∀ (σ : NormalForm sig 1 4) (a : M.carrier),
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap a →
      nf_eval_nf M 1 1 (fun _ => a) (nfk_projFresh σ))
    (h : (kvE2_sepBody (nf_depth0_char_formula atomMap h_surj) charK qnf).holds M atomMap x t) :
    (kvE2_sepEpL (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap x ∧
    (kvE2_sepEpR (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap t ∧
    ∃ w : M.carrier, x < w ∧ w < t ∧
      (kvE2_sepPtW (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap w ∧
      (∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zXW3 →
        ∃ x1 : M.carrier,
          nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) ∧
      (∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zWT3 →
        ∃ x1 : M.carrier,
          nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) := by
  set charBase := nf_depth0_char_formula atomMap h_surj with hcb
  by_cases hg : kvE2_sepGate qnf
  · rw [kvE2_sepBody_holds_iff charBase charK qnf hg M atomMap x t] at h
    obtain ⟨wo, hwo, hd⟩ := h
    obtain ⟨hepL, hepR, hbr⟩ := hd
    have hwo' : wo ∈ kvE2_sepOrderTypes qnf := (List.mem_filter.mp hwo).1
    have howners : wo.map Prod.fst = kvE2_sepPosI qnf := kvE2_sepOrderTypes_owners qnf hwo'
    have hksortR : (kvE2_sepSlotsROf wo).Pairwise
        (fun a b => kvE2_sepSlotGIdx wo a ≤ kvE2_sepSlotGIdx wo b) := by
      refine (kvE2_sepSlotsROf_mergeSorted wo).imp ?_
      intro a b hab; rw [kvE2_sepSlotMergeLe, decide_eq_true_eq] at hab; exact hab
    simp only [kvE2_sepDisjunct', kvE2_sepBracketN, BracketFormula.holds,
      BracketFormula.toIntervalPattern] at hbr
    rw [IntervalPattern.holds_eq_succ M atomMap _ _ x t
      (show ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length + 1
          + ((kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK)).length
        = ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length
          + ((kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK)).length + 1
        by omega)] at hbr
    obtain ⟨ws, hmono, hrange, hpt, hseg0, hsegMid, hsegLast⟩ := hbr
    have hpt' : ∀ (i : Nat)
        (hi : i < ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length
          + ((kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK)).length + 1),
        (((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)
            ++ kvE2_sepPtW charBase charK qnf
              :: (kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK))[i]'(by
          simp only [List.length_append, List.length_cons]; omega)).eval_at M atomMap
          (ws ⟨i, hi⟩) := fun i hi => hpt ⟨i, hi⟩
    have hwidx : ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length
        < ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length
          + ((kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK)).length + 1 := by omega
    set w := ws ⟨((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length,
      hwidx⟩ with hwdef
    have hxw : x < w := (hrange _).1
    have hwt : w < t := (hrange _).2
    have hxt : x < t := hxw.trans hwt
    have hptW : (kvE2_sepPtW charBase charK qnf).eval_at M atomMap w := by
      have h1 := hpt' _ hwidx
      rwa [kvE2_sep_getElem_mid] at h1
    have hσ0pos : σ0 ∈ kvE2_sepPos qnf := by rw [hfrag]; exact List.mem_singleton_self _
    have hσ0true : qnf.2 σ0 = true := by
      have := hσ0pos; simp only [kvE2_sepPos, List.mem_filter] at this; exact this.2
    have hσI : σ0 ∈ kvE2_sepPosI qnf := (kvE2_sepPosI_mem qnf σ0).mpr ⟨hσ0pos, Or.inr hz⟩
    have hσp : σ0 ∈ wo.map Prod.fst := by rw [howners]; exact hσI
    obtain ⟨pp, hpwo, hp1⟩ := List.mem_map.mp hσp
    have hpe : (σ0, pp.2.1, pp.2.2) ∈ wo := by rw [← hp1]; exact hpwo
    -- pin extraction (RIGHT group)
    have hmemX1 : (KvE2SepSlot.rX1 σ0) ∈ kvE2_sepSlotsROf wo :=
      kvE2_sepSlotsROf_mem qnf hwo' hσI (kvE2_sep_rX1_mem_slotsRFor hz)
    rw [← kvE2_sepTieGroupedR_flatten wo] at hmemX1
    obtain ⟨c, hc, hsc⟩ := List.mem_flatten.mp hmemX1
    obtain ⟨irσ, hirσ, hgetirσ⟩ := List.mem_iff_getElem.mp hc
    have hirσm : irσ < ((kvE2_sepTieGroupedR wo).map
        (kvE2_sepClassType charBase charK)).length := by
      simp only [List.length_map]; omega
    have hpinK : ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length + 1 + irσ
        < ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length
          + ((kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK)).length + 1 := by
      simp only [List.length_map] at hirσm ⊢; omega
    set x1 := ws ⟨((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length + 1 +
        irσ,
      hpinK⟩ with hx1def
    have hxx1 : x < x1 := (hrange _).1
    have hwx1 : w < x1 := by
      rw [hwdef]; exact hmono _ _ (Fin.mk_lt_mk.mpr (by omega))
    have hx1t : x1 < t := (hrange _).2
    have hpin_raw := hpt' (((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length
      + 1 + irσ) hpinK
    rw [kvE2_sep_getElem_right _ _ _ irσ hirσm, List.getElem_map, hgetirσ] at hpin_raw
    have hpt_pin := kvE2_sepClassType_eval_mem charBase charK M atomMap _ hpin_raw hsc
    have hanchor : (⟨charK (nfk_projFresh σ0)⟩ : TemporalPred).eval_at M atomMap x1 :=
      kvE2_sepPtX1R_anchor charBase charK σ0 M atomMap x1 hpt_pin
    -- below-witness clause: every zWX1-positive 1-type strictly between w and the pin
    have hbelow : ∀ χ : NormalForm sig 0 1,
        σ0.2 (nf0_assemble kvE2_sep_zWX1 χ σ0.1) = true →
        ∃ u : M.carrier, w < u ∧ u < x1 ∧
          (⟨charBase χ⟩ : TemporalPred).eval_at M atomMap u := by
      intro χ hbit
      have hmemU : (KvE2SepSlot.rWX1 σ0 χ) ∈ kvE2_sepSlotsROf wo :=
        kvE2_sepSlotsROf_mem qnf hwo' hσI (kvE2_sep_rWX1_mem_slotsRFor hz hbit)
      rw [← kvE2_sepTieGroupedR_flatten wo] at hmemU
      obtain ⟨d, hd, hsd⟩ := List.mem_flatten.mp hmemU
      obtain ⟨jr, hjr, hgetjr⟩ := List.mem_iff_getElem.mp hd
      have hkey : kvE2_sepSlotGIdx wo (KvE2SepSlot.rWX1 σ0 χ)
          < kvE2_sepSlotGIdx wo (KvE2SepSlot.rX1 σ0) :=
        kvE2_sep_gidx_lt_of_rank_lt qnf hwo hpe
          (by rw [kvE2_sepSlotBlock]
              exact List.mem_append_right _ (kvE2_sep_rWX1_mem_slotsRFor hz hbit))
          (by rw [kvE2_sepSlotBlock]
              exact List.mem_append_right _ (kvE2_sep_rX1_mem_slotsRFor hz))
          rfl Nat.zero_lt_one
      have hain : (KvE2SepSlot.rWX1 σ0 χ) ∈ (kvE2_sepTieGroupedR wo)[jr]'hjr := by
        rw [hgetjr]; exact hsd
      have hbin : (KvE2SepSlot.rX1 σ0) ∈ (kvE2_sepTieGroupedR wo)[irσ]'hirσ := by
        rw [hgetirσ]; exact hsc
      have hji : jr < irσ := kvE2_sepTieRuns_classIdx_lt (kvE2_sepSlotGIdx wo)
        (kvE2_sepSlotsROf wo) hksortR hjr hirσ hain hbin hkey
      have hjrm : jr < ((kvE2_sepTieGroupedR wo).map
          (kvE2_sepClassType charBase charK)).length := by
        simp only [List.length_map]; omega
      have hjtot : ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length + 1 + jr
          < ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length
            + ((kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK)).length + 1 := by
        simp only [List.length_map] at hjrm ⊢; omega
      refine ⟨ws ⟨((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length + 1 + jr,
        hjtot⟩, ?_, ?_, ?_⟩
      · rw [hwdef]; exact hmono _ _ (Fin.mk_lt_mk.mpr (by omega))
      · rw [hx1def]; exact hmono _ _ (Fin.mk_lt_mk.mpr (by omega))
      · have h1 := hpt' (((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length
          + 1 + jr) hjtot
        rw [kvE2_sep_getElem_right _ _ _ jr hjrm, List.getElem_map, hgetjr] at h1
        exact kvE2_sepClassType_eval_mem charBase charK M atomMap _ h1 hsd
    refine ⟨hepL, hepR, w, hxw, hwt, hptW, ?_, ?_⟩
    · -- clause 1 (zXW3 owners): vacuous — σ0 is zWT3
      intro σ hσ hzσ
      have hσeq : σ = σ0 := by rw [hfrag] at hσ; exact List.mem_singleton.mp hσ
      subst hσeq
      rw [hz] at hzσ
      exact absurd hzσ (by decide)
    · -- clause 2 (zWT3 owners): full derivation at the RIGHT pin
      intro σ hσ hzσ
      have hσeq : σ = σ0 := by rw [hfrag] at hσ; exact List.mem_singleton.mp hσ
      subst hσeq
      have h_off : ∀ τ : NormalForm sig 0 5, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false :=
        kvE2_sepHgate_offFiber qnf hg σ hσ0true
      have hdrop : nf0_dropFresh σ.1 = qnf.1 := by
        by_contra hne
        rw [hg.1 σ hne] at hσ0true
        exact absurd hσ0true (by decide)
      have hprojW : nf_eval_nf M 0 1 (fun _ => w) (kvE2_sepProj3 qnf.1 ⟨0, by omega⟩) := by
        have h1 := hptW
        simp only [kvE2_sepPtW, TemporalPred.eval_at] at h1
        exact (nfPred_correct M atomMap h_surj _ w).mp
          ((formula_conjList_iff M atomMap w _).mp h1 _ List.mem_cons_self)
      have hprojX : nf_eval_nf M 0 1 (fun _ => x) (kvE2_sepProj3 qnf.1 ⟨1, by omega⟩) := by
        have h1 := hepL
        simp only [TemporalPred.eval_at] at h1
        exact (nfPred_correct M atomMap h_surj _ x).mp
          ((formula_conjList_iff M atomMap x _).mp h1 _ List.mem_cons_self)
      have hprojT : nf_eval_nf M 0 1 (fun _ => t) (kvE2_sepProj3 qnf.1 ⟨2, by omega⟩) := by
        have h1 := hepR
        simp only [TemporalPred.eval_at] at h1
        exact (nfPred_correct M atomMap h_surj _ t).mp
          ((formula_conjList_iff M atomMap t _).mp h1 _ List.mem_cons_self)
      have h_atom : nf_eval_nf M 0 4
          (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1 := by
        have hpf : (nfk_projFresh σ).1 = nf0_projFresh σ.1 := by
          funext a
          match a with
          | .pred p i =>
            have hi : i = ⟨0, by omega⟩ := Subsingleton.elim i _
            subst hi; rfl
          | .order i j hij => exact absurd (Subsingleton.elim i j) hij
        obtain ⟨hc0a, -⟩ := hcorrK σ x1 hanchor
        intro a
        match a with
        | .pred p ⟨0, _⟩ =>
          have h1 := hc0a (.pred p ⟨0, by omega⟩)
          exact h1
        | .pred p ⟨1, _⟩ =>
          have e := congrFun hdrop (AtomKind.pred p ⟨0, by omega⟩)
          simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ, Fin.succ_mk, Nat.reduceAdd] at e
          rw [e]
          have h1 := hprojW (.pred p ⟨0, by omega⟩)
          exact h1
        | .pred p ⟨2, _⟩ =>
          have e := congrFun hdrop (AtomKind.pred p ⟨1, by omega⟩)
          simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ, Fin.succ_mk, Nat.reduceAdd] at e
          rw [e]
          have h1 := hprojX (.pred p ⟨0, by omega⟩)
          exact h1
        | .pred p ⟨3, _⟩ =>
          have e := congrFun hdrop (AtomKind.pred p ⟨2, by omega⟩)
          simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ, Fin.succ_mk, Nat.reduceAdd] at e
          rw [e]
          have h1 := hprojT (.pred p ⟨0, by omega⟩)
          exact h1
        | .order ⟨0, _⟩ ⟨1, _⟩ hne =>
          have hbit : σ.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ hne) = false := by
            exact congrArg Prod.fst (congrFun hz ⟨0, by omega⟩)
          rw [hbit]; simp only [atom_eval]
          exact iff_of_false (lt_asymm hwx1) (by decide)
        | .order ⟨0, _⟩ ⟨2, _⟩ hne =>
          have hbit : σ.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ hne) = false := by
            exact congrArg Prod.fst (congrFun hz ⟨1, by omega⟩)
          rw [hbit]; simp only [atom_eval]
          exact iff_of_false (lt_asymm hxx1) (by decide)
        | .order ⟨0, _⟩ ⟨3, _⟩ hne =>
          have hbit : σ.1 (.order ⟨0, by omega⟩ ⟨3, by omega⟩ hne) = true := by
            exact congrArg Prod.fst (congrFun hz ⟨2, by omega⟩)
          rw [hbit]; simp only [atom_eval]
          exact iff_of_true hx1t (by decide)
        | .order ⟨1, _⟩ ⟨0, _⟩ hne =>
          have hbit : σ.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ hne) = true := by
            exact congrArg Prod.snd (congrFun hz ⟨0, by omega⟩)
          rw [hbit]; simp only [atom_eval]
          exact iff_of_true hwx1 (by decide)
        | .order ⟨2, _⟩ ⟨0, _⟩ hne =>
          have hbit : σ.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ hne) = true := by
            exact congrArg Prod.snd (congrFun hz ⟨1, by omega⟩)
          rw [hbit]; simp only [atom_eval]
          exact iff_of_true hxx1 (by decide)
        | .order ⟨3, _⟩ ⟨0, _⟩ hne =>
          have hbit : σ.1 (.order ⟨3, by omega⟩ ⟨0, by omega⟩ hne) = false := by
            exact congrArg Prod.snd (congrFun hz ⟨2, by omega⟩)
          rw [hbit]; simp only [atom_eval]
          exact iff_of_false (lt_asymm hx1t) (by decide)
        | .order ⟨1, _⟩ ⟨2, _⟩ hne =>
          have e := congrFun hdrop (AtomKind.order ⟨0, by omega⟩ ⟨1, by omega⟩
            (Fin.ne_of_val_ne (show (0 : ℕ) ≠ 1 by decide)))
          simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ, Fin.succ_mk, Nat.reduceAdd,
            h_yx] at e
          rw [e]; simp only [atom_eval]
          exact iff_of_false (lt_asymm hxw) (by decide)
        | .order ⟨2, _⟩ ⟨1, _⟩ hne =>
          have e := congrFun hdrop (AtomKind.order ⟨1, by omega⟩ ⟨0, by omega⟩
            (Fin.ne_of_val_ne (show (1 : ℕ) ≠ 0 by decide)))
          simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ, Fin.succ_mk, Nat.reduceAdd,
            h_xy] at e
          rw [e]; simp only [atom_eval]
          exact iff_of_true hxw (by decide)
        | .order ⟨1, _⟩ ⟨3, _⟩ hne =>
          have e := congrFun hdrop (AtomKind.order ⟨0, by omega⟩ ⟨2, by omega⟩
            (Fin.ne_of_val_ne (show (0 : ℕ) ≠ 2 by decide)))
          simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ, Fin.succ_mk, Nat.reduceAdd,
            h_yt] at e
          rw [e]; simp only [atom_eval]
          exact iff_of_true hwt (by decide)
        | .order ⟨3, _⟩ ⟨1, _⟩ hne =>
          have e := congrFun hdrop (AtomKind.order ⟨2, by omega⟩ ⟨0, by omega⟩
            (Fin.ne_of_val_ne (show (2 : ℕ) ≠ 0 by decide)))
          simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ, Fin.succ_mk, Nat.reduceAdd,
            h_ty] at e
          rw [e]; simp only [atom_eval]
          exact iff_of_false (lt_asymm hwt) (by decide)
        | .order ⟨2, _⟩ ⟨3, _⟩ hne =>
          have e := congrFun hdrop (AtomKind.order ⟨1, by omega⟩ ⟨2, by omega⟩
            (Fin.ne_of_val_ne (show (1 : ℕ) ≠ 2 by decide)))
          simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ, Fin.succ_mk, Nat.reduceAdd,
            h_xt] at e
          rw [e]; simp only [atom_eval]
          exact iff_of_true hxt (by decide)
        | .order ⟨3, _⟩ ⟨2, _⟩ hne =>
          have e := congrFun hdrop (AtomKind.order ⟨2, by omega⟩ ⟨1, by omega⟩
            (Fin.ne_of_val_ne (show (2 : ℕ) ≠ 1 by decide)))
          simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ, Fin.succ_mk, Nat.reduceAdd,
            h_tx] at e
          rw [e]; simp only [atom_eval]
          exact iff_of_false (lt_asymm hxt) (by decide)
        | .order ⟨0, _⟩ ⟨0, _⟩ hne => exact absurd rfl hne
        | .order ⟨1, _⟩ ⟨1, _⟩ hne => exact absurd rfl hne
        | .order ⟨2, _⟩ ⟨2, _⟩ hne => exact absurd rfl hne
        | .order ⟨3, _⟩ ⟨3, _⟩ hne => exact absurd rfl hne
      have h_fwd : ∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1),
          (∃ v : M.carrier,
            zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
            nf_eval_nf M 0 1 (fun _ => v) χ) →
          σ.2 (nf0_assemble zs χ σ.1) = true := by
        rintro zs χ ⟨v, hzv, hχv⟩
        by_contra hbit
        rw [Bool.not_eq_true] at hbit
        have hχbase : (⟨charBase χ⟩ : TemporalPred).eval_at M atomMap v := by
          rw [hcb]; exact (nfPred_correct M atomMap h_surj χ v).mpr hχv
        have hws_le : ∀ (a b : ℕ) (ha : a < _) (hb : b < _), a ≤ b →
            ws ⟨a, ha⟩ ≤ ws ⟨b, hb⟩ := by
          intro a b ha hb hab
          rcases eq_or_lt_of_le hab with h | h
          · exact le_of_eq (congrArg ws (Fin.ext h))
          · exact le_of_lt (hmono _ _ (Fin.mk_lt_mk.mpr h))
        have hlenL : (kvE2_sepTieGroupedL wo).length
            = (List.map (kvE2_sepClassType charBase charK) (kvE2_sepTieGroupedL wo)).length := by
          rw [List.length_map]
        have hlenR : (kvE2_sepTieGroupedR wo).length
            = (List.map (kvE2_sepClassType charBase charK) (kvE2_sepTieGroupedR wo)).length := by
          rw [List.length_map]
        have hndR : (kvE2_sepTieGroupedR wo).flatten.Nodup := by
          rw [kvE2_sepTieGroupedR_flatten]; exact kvE2_sepSlotsROf_nodup qnf hwo'
        have hzWT3ne : nf0_zoneSpec σ.1 ≠ kvE2_sep_zXW3 := by rw [hz]; exact kvE2_sep_zWT3_ne_zXW3
        have hsc' : (KvE2SepSlot.rX1 σ) ∈ (kvE2_sepTieGroupedR wo)[irσ]'hirσ := by
          rw [hgetirσ]; exact hsc
        have hσIn : σ ∈ kvE2_sepPosIn qnf kvE2_sep_zWT3 :=
          List.mem_filter.mpr ⟨hσ0pos, by simp only [decide_eq_true_eq]; exact hz⟩
        rcases kvE2_sep_locate_witness M ws v with ⟨j, hjv⟩ | hlow | ⟨i, hi1, hi2⟩ | hhigh
        · -- WITNESS case: v = ws j is a bracket point
          subst hjv
          have hxv : x < ws j := (hrange j).1
          have hvt : ws j < t := (hrange j).2
          have howner_eq : ∀ τ, τ ∈ kvE2_sepOrderOwners wo → τ = σ := by
            intro τ hτ
            have hτpos := ((kvE2_sepPosI_mem qnf τ).mp
              (kvE2_sepOrderOwners_mem_pos howners hτ)).1
            rw [hfrag] at hτpos; exact List.mem_singleton.mp hτpos
          have hLmem : ∀ s, s ∈ (kvE2_sepTieGroupedL wo).flatten → s ∈ kvE2_sepSlotsLFor σ := by
            intro s hs
            rw [kvE2_sepTieGroupedL_flatten, kvE2_sepSlotsLOf] at hs
            obtain ⟨τ, hτo, hsτ⟩ := List.mem_flatMap.mp ((List.mergeSort_perm _ _).mem_iff.mp hs)
            rw [howner_eq τ hτo] at hsτ; exact hsτ
          have hRmem : ∀ s, s ∈ (kvE2_sepTieGroupedR wo).flatten → s ∈ kvE2_sepSlotsRFor σ := by
            intro s hs
            rw [kvE2_sepTieGroupedR_flatten, kvE2_sepSlotsROf] at hs
            obtain ⟨τ, hτo, hsτ⟩ := List.mem_flatMap.mp ((List.mergeSort_perm _ _).mem_iff.mp hs)
            rw [howner_eq τ hτo] at hsτ; exact hsτ
          have hχeq : ∀ χ' : NormalForm sig 0 1,
              (⟨charBase χ'⟩ : TemporalPred).eval_at M atomMap (ws j) → χ' = χ := by
            intro χ' hb
            have hnf : nf_eval_nf M 0 1 (fun _ => ws j) χ' :=
              (nfPred_correct M atomMap h_surj χ' (ws j)).mp hb
            exact nf_eval_unique M 0 1 _ χ' χ hnf hχv
          rcases Nat.lt_trichotomy j.val (kvE2_sepTieGroupedL wo).length with hjm | hjm | hjm
          · -- LEFT group: single rXW slot → zone kvE_sub2_zXU (x < ws j < w)
            have hjmap : j.val < (List.map (kvE2_sepClassType charBase charK)
                (kvE2_sepTieGroupedL wo)).length := by omega
            have hptj := hpt' j.val j.isLt
            rw [kvE2_sep_getElem_left _ _ _ j.val hjmap, List.getElem_map] at hptj
            have hne : (kvE2_sepTieGroupedL wo)[j.val]'hjm ≠ [] :=
              kvE2_sepTieGroupedL_ne_nil wo _ (List.getElem_mem hjm)
            obtain ⟨s, hsmem⟩ : ∃ s, s ∈ (kvE2_sepTieGroupedL wo)[j.val]'hjm :=
              ⟨_, List.head_mem hne⟩
            have hslotty := kvE2_sepClassType_eval_mem charBase charK M atomMap _ hptj hsmem
            have hsflat : s ∈ (kvE2_sepTieGroupedL wo).flatten :=
              List.mem_flatten.mpr ⟨_, List.getElem_mem hjm, hsmem⟩
            have hsF := hLmem s hsflat
            rw [kvE2_sepSlotsLFor, if_neg hzWT3ne, if_pos hz] at hsF
            obtain ⟨χ', hχ'S, rfl⟩ := List.mem_map.mp hsF
            have hχ'eq : χ' = χ := hχeq χ' hslotty
            rw [hχ'eq] at hχ'S
            have hbitXW : kvE2_sepBits σ kvE_sub2_zXU χ = true := (List.mem_filter.mp hχ'S).2
            have hvjw : ws j < w := by rw [hwdef]; exact hmono _ _ (Fin.mk_lt_mk.mpr hjmap)
            have hvjx1 : ws j < x1 := hvjw.trans hwx1
            have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                kvE_sub2_zXU (ws j) := by
              intro k
              match k with
              | ⟨0, _⟩ => exact ⟨iff_of_true hvjx1 rfl, iff_of_false (lt_asymm hvjx1)
                  (by decide +revert)⟩
              | ⟨1, _⟩ => exact ⟨iff_of_true hvjw rfl, iff_of_false (lt_asymm hvjw)
                  (by decide +revert)⟩
              | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxv) (by decide +revert), iff_of_true hxv
                  rfl⟩
              | ⟨3, _⟩ => exact ⟨iff_of_true hvt rfl, iff_of_false (lt_asymm hvt)
                  (by decide +revert)⟩
            have hzeq : zs = kvE_sub2_zXU := zoneHolds_unique M _ (ws j) zs _ hzv hpos
            rw [hzeq] at hbit
            simp only [kvE2_sepBits] at hbitXW
            exact Bool.false_ne_true (hbit.symm.trans hbitXW)
          · -- j = |gL| : ws j = w, AT-w case via ptW (zAtWR)
            have hjw : ws j = w := by
              rw [hwdef]; exact congrArg ws (Fin.ext (hjm.trans hlenL))
            have hlit := kvE2_sepPtW_owner_lit_R charBase charK qnf M atomMap w σ hσIn hptW χ
            have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                kvE2_sep_zAtWR (ws j) := by
              intro k
              match k with
              | ⟨0, _⟩ => exact ⟨iff_of_true (by rw [hjw]; exact hwx1) rfl,
                  iff_of_false (by rw [hjw]; exact lt_asymm hwx1) (by decide +revert)⟩
              | ⟨1, _⟩ => exact ⟨iff_of_false (by rw [hjw]; exact lt_irrefl w) (by decide +revert),
                  iff_of_false (by rw [hjw]; exact lt_irrefl w) (by decide +revert)⟩
              | ⟨2, _⟩ => exact ⟨iff_of_false (by rw [hjw]; exact lt_asymm hxw) (by decide +revert),
                  iff_of_true (by rw [hjw]; exact hxw) rfl⟩
              | ⟨3, _⟩ => exact ⟨iff_of_true (by rw [hjw]; exact hwt) rfl,
                  iff_of_false (by rw [hjw]; exact lt_asymm hwt) (by decide +revert)⟩
            have hzeq : zs = kvE2_sep_zAtWR := zoneHolds_unique M _ (ws j) zs _ hzv hpos
            have hbitW : kvE2_sepBits σ kvE2_sep_zAtWR χ = false := by
              rw [hzeq] at hbit; exact hbit
            rw [hbitW] at hlit
            simp only [kvE2_sepLit, Bool.false_eq_true, if_false] at hlit
            exact hlit (by rw [← hjw]; exact hχbase)
          · -- RIGHT group: rWX1 / rX1(pin) / rX1T slots
            set jr := j.val - (kvE2_sepTieGroupedL wo).length - 1 with hjrdef
            have hjlt : j.val < (List.map (kvE2_sepClassType charBase charK)
                  (kvE2_sepTieGroupedL wo)).length
                + (List.map (kvE2_sepClassType charBase charK) (kvE2_sepTieGroupedR wo)).length +
                    1 :=
              j.isLt
            have hjrR : jr < (kvE2_sepTieGroupedR wo).length := by omega
            have hjrRmap : jr < (List.map (kvE2_sepClassType charBase charK)
                (kvE2_sepTieGroupedR wo)).length := by omega
            have hK : (List.map (kvE2_sepClassType charBase charK) (kvE2_sepTieGroupedL wo)).length
                  + 1 + jr < (List.map (kvE2_sepClassType charBase charK)
                    (kvE2_sepTieGroupedL wo)).length
                + (List.map (kvE2_sepClassType charBase charK) (kvE2_sepTieGroupedR wo)).length +
                    1 :=
              by omega
            have hptj := hpt' ((List.map (kvE2_sepClassType charBase charK)
              (kvE2_sepTieGroupedL wo)).length + 1 + jr) hK
            rw [kvE2_sep_getElem_right _ _ _ jr hjrRmap, List.getElem_map] at hptj
            have hKeq : (List.map (kvE2_sepClassType charBase charK)
                (kvE2_sepTieGroupedL wo)).length + 1 + jr = j.val := by omega
            have hpteq : (ws ⟨(List.map (kvE2_sepClassType charBase charK)
                (kvE2_sepTieGroupedL wo)).length + 1 + jr, hK⟩ : M.carrier) = ws j :=
              congrArg ws (Fin.ext hKeq)
            rw [hpteq] at hptj
            have hne : (kvE2_sepTieGroupedR wo)[jr]'hjrR ≠ [] :=
              kvE2_sepTieGroupedR_ne_nil wo _ (List.getElem_mem hjrR)
            obtain ⟨s, hsmem⟩ : ∃ s, s ∈ (kvE2_sepTieGroupedR wo)[jr]'hjrR :=
              ⟨_, List.head_mem hne⟩
            have hslotty := kvE2_sepClassType_eval_mem charBase charK M atomMap _ hptj hsmem
            have hsflat : s ∈ (kvE2_sepTieGroupedR wo).flatten :=
              List.mem_flatten.mpr ⟨_, List.getElem_mem hjrR, hsmem⟩
            have hsF := hRmem s hsflat
            rw [kvE2_sepSlotsRFor, if_neg hzWT3ne, if_pos hz] at hsF
            rcases List.mem_append.mp hsF with hWX1 | hrest
            · -- s = .rWX1 σ χ' → zWX1 zone (jr < pin irσ), bit true, contradiction
              obtain ⟨χ', hχ'S, rfl⟩ := List.mem_map.mp hWX1
              have hχ'eq : χ' = χ := hχeq χ' hslotty
              rw [hχ'eq] at hχ'S hsmem
              have hbitWX1 : kvE2_sepBits σ kvE2_sep_zWX1 χ = true := (List.mem_filter.mp hχ'S).2
              have hkey : kvE2_sepSlotGIdx wo (KvE2SepSlot.rWX1 σ χ)
                  < kvE2_sepSlotGIdx wo (KvE2SepSlot.rX1 σ) :=
                kvE2_sep_gidx_lt_of_rank_lt qnf hwo hpe
                  (by rw [kvE2_sepSlotBlock]
                      exact List.mem_append_right _ (kvE2_sep_rWX1_mem_slotsRFor hz hbitWX1))
                  (by rw [kvE2_sepSlotBlock]
                      exact List.mem_append_right _ (kvE2_sep_rX1_mem_slotsRFor hz))
                  rfl Nat.zero_lt_one
              have hji : jr < irσ := kvE2_sepTieRuns_classIdx_lt (kvE2_sepSlotGIdx wo)
                (kvE2_sepSlotsROf wo) hksortR hjrR hirσ hsmem hsc' hkey
              have hvx1 : ws j < x1 := by
                rw [hx1def]; exact hmono _ _ (Fin.mk_lt_mk.mpr (by omega))
              have hwv : w < ws j := by
                rw [hwdef]; exact hmono _ _ (Fin.mk_lt_mk.mpr (by omega))
              have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                  kvE2_sep_zWX1 (ws j) := by
                intro k
                match k with
                | ⟨0, _⟩ => exact ⟨iff_of_true hvx1 rfl, iff_of_false (lt_asymm hvx1)
                    (by decide +revert)⟩
                | ⟨1, _⟩ => exact ⟨iff_of_false (lt_asymm hwv) (by decide +revert), iff_of_true hwv
                    rfl⟩
                | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxv) (by decide +revert), iff_of_true hxv
                    rfl⟩
                | ⟨3, _⟩ => exact ⟨iff_of_true hvt rfl, iff_of_false (lt_asymm hvt)
                    (by decide +revert)⟩
              have hzeq : zs = kvE2_sep_zWX1 := zoneHolds_unique M _ (ws j) zs _ hzv hpos
              rw [hzeq] at hbit
              simp only [kvE2_sepBits] at hbitWX1
              exact Bool.false_ne_true (hbit.symm.trans hbitWX1)
            · rcases List.mem_cons.mp hrest with rfl | hX1T
              · -- s = .rX1 σ → j at pin, ws j = x1, AT-x1 via ptX1R
                have hjeqr : jr = irσ := by
                  rcases Nat.lt_trichotomy jr irσ with h | h | h
                  · exfalso
                    have hstrict := kvE2_sepTieRuns_key_strictMono (kvE2_sepSlotGIdx wo)
                      (kvE2_sepSlotsROf wo) hksortR
                    have hlt := List.pairwise_iff_getElem.mp hstrict jr irσ hjrR hirσ h
                      (KvE2SepSlot.rX1 σ) hsmem (KvE2SepSlot.rX1 σ) hsc'
                    omega
                  · exact h
                  · exfalso
                    have hstrict := kvE2_sepTieRuns_key_strictMono (kvE2_sepSlotGIdx wo)
                      (kvE2_sepSlotsROf wo) hksortR
                    have hlt := List.pairwise_iff_getElem.mp hstrict irσ jr hirσ hjrR h
                      (KvE2SepSlot.rX1 σ) hsc' (KvE2SepSlot.rX1 σ) hsmem
                    omega
                have hjeq : (List.map (kvE2_sepClassType charBase charK)
                    (kvE2_sepTieGroupedL wo)).length + 1 + irσ = j.val := by omega
                have hjx1 : ws j = x1 := by
                  rw [hx1def]; exact congrArg ws (Fin.ext hjeq.symm)
                have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                    kvE2_sep_zAtX1R (ws j) := by
                  intro k
                  match k with
                  | ⟨0, _⟩ => exact ⟨iff_of_false (by rw [hjx1]; exact lt_irrefl x1)
                      (by decide +revert),
                      iff_of_false (by rw [hjx1]; exact lt_irrefl x1) (by decide +revert)⟩
                  | ⟨1, _⟩ => exact ⟨iff_of_false (by rw [hjx1]; exact lt_asymm hwx1)
                      (by decide +revert),
                      iff_of_true (by rw [hjx1]; exact hwx1) rfl⟩
                  | ⟨2, _⟩ => exact ⟨iff_of_false (by rw [hjx1]; exact lt_asymm hxx1)
                      (by decide +revert),
                      iff_of_true (by rw [hjx1]; exact hxx1) rfl⟩
                  | ⟨3, _⟩ => exact ⟨iff_of_true (by rw [hjx1]; exact hx1t) rfl,
                      iff_of_false (by rw [hjx1]; exact lt_asymm hx1t) (by decide +revert)⟩
                have hzeq : zs = kvE2_sep_zAtX1R := zoneHolds_unique M _ (ws j) zs _ hzv hpos
                have hlit := kvE2_sepPtX1R_owner_lit charBase charK σ M atomMap (ws j) hslotty χ
                have hbitX1 : kvE2_sepBits σ kvE2_sep_zAtX1R χ = false := by
                  rw [hzeq] at hbit; exact hbit
                rw [hbitX1] at hlit
                simp only [kvE2_sepLit, Bool.false_eq_true, if_false] at hlit
                exact hlit hχbase
              · -- s = .rX1T σ χ' → kvE_sub2_zWT zone (pin < jr), bit true, contradiction
                obtain ⟨χ', hχ'S, rfl⟩ := List.mem_map.mp hX1T
                have hχ'eq : χ' = χ := hχeq χ' hslotty
                rw [hχ'eq] at hχ'S hsmem
                have hbitX1T : kvE2_sepBits σ kvE_sub2_zWT χ = true := (List.mem_filter.mp hχ'S).2
                have hkey : kvE2_sepSlotGIdx wo (KvE2SepSlot.rX1 σ)
                    < kvE2_sepSlotGIdx wo (KvE2SepSlot.rX1T σ χ) :=
                  kvE2_sep_gidx_lt_of_rank_lt qnf hwo hpe
                    (by rw [kvE2_sepSlotBlock]
                        exact List.mem_append_right _ (kvE2_sep_rX1_mem_slotsRFor hz))
                    (by rw [kvE2_sepSlotBlock]
                        exact List.mem_append_right _ (kvE2_sep_rX1T_mem_slotsRFor hz hbitX1T))
                    rfl Nat.one_lt_two
                have hji : irσ < jr := kvE2_sepTieRuns_classIdx_lt (kvE2_sepSlotGIdx wo)
                  (kvE2_sepSlotsROf wo) hksortR hirσ hjrR hsc' hsmem hkey
                have hx1v : x1 < ws j := by
                  rw [hx1def]; exact hmono _ _ (Fin.mk_lt_mk.mpr (by omega))
                have hwv : w < ws j := hwx1.trans hx1v
                have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                    kvE_sub2_zWT (ws j) := by
                  intro k
                  match k with
                  | ⟨0, _⟩ => exact ⟨iff_of_false (lt_asymm hx1v) (by decide +revert), iff_of_true
                      hx1v rfl⟩
                  | ⟨1, _⟩ => exact ⟨iff_of_false (lt_asymm hwv) (by decide +revert), iff_of_true
                      hwv rfl⟩
                  | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxv) (by decide +revert), iff_of_true
                      hxv rfl⟩
                  | ⟨3, _⟩ => exact ⟨iff_of_true hvt rfl, iff_of_false (lt_asymm hvt)
                      (by decide +revert)⟩
                have hzeq : zs = kvE_sub2_zWT := zoneHolds_unique M _ (ws j) zs _ hzv hpos
                rw [hzeq] at hbit
                simp only [kvE2_sepBits] at hbitX1T
                exact Bool.false_ne_true (hbit.symm.trans hbitX1T)
        · -- hlow : v < ws 0
          rcases lt_or_ge x v with hxv | hvx
          · -- x < v < ws0 ⊆ (x, w) : kvE_sub2_zXU via hseg0
            have hvw : v < w := by
              rw [hwdef]; exact lt_of_lt_of_le hlow (hws_le _ _ _ _ (Nat.zero_le _))
            have hvx1 : v < x1 := hvw.trans hwx1
            have hvt : v < t := hvw.trans hwt
            have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                kvE_sub2_zXU v := by
              intro k
              match k with
              | ⟨0, _⟩ => exact ⟨iff_of_true hvx1 rfl, iff_of_false (lt_asymm hvx1)
                  (by decide +revert)⟩
              | ⟨1, _⟩ => exact ⟨iff_of_true hvw rfl, iff_of_false (lt_asymm hvw)
                  (by decide +revert)⟩
              | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxv) (by decide +revert), iff_of_true hxv
                  rfl⟩
              | ⟨3, _⟩ => exact ⟨iff_of_true hvt rfl, iff_of_false (lt_asymm hvt)
                  (by decide +revert)⟩
            have hzeq : zs = kvE_sub2_zXU := zoneHolds_unique M _ v zs kvE_sub2_zXU hzv hpos
            have hsegF : (⟨kvE2_sepSegForm charBase σ kvE_sub2_zXU⟩ : TemporalPred).eval_at M
                atomMap v := by
              have hh := hseg0 v hxv hlow
              simp only [kvE2_sepSegsG, kvE2_sepSegLAt, hfrag, List.map_cons, List.map_nil,
                List.take_zero, List.flatten_nil, List.length_nil] at hh
              have hh1 := (formula_conjList_iff M atomMap v _).mp hh _ List.mem_cons_self
              rwa [kvE2_sepSegLForSub, if_neg hzWT3ne, if_pos hz] at hh1
            have hbitX : kvE2_sepBits σ kvE_sub2_zXU χ = false := by rw [hzeq] at hbit; exact hbit
            exact kvE2_sepSegForm_excludes charBase σ kvE_sub2_zXU χ M atomMap v hsegF hbitX hχbase
          · -- v ≤ x : boundary via hepL
            rcases lt_or_eq_of_le hvx with hvltx | hveqx
            · -- v < x : zPastX4, hepL Since-literal
              have hvx1 : v < x1 := hvltx.trans hxx1
              have hvw : v < w := hvltx.trans hxw
              have hvt : v < t := hvltx.trans hxt
              have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                  kvE2_sep_zPastX4 v := by
                intro k
                match k with
                | ⟨0, _⟩ => exact ⟨iff_of_true hvx1 rfl, iff_of_false (lt_asymm hvx1)
                    (by decide +revert)⟩
                | ⟨1, _⟩ => exact ⟨iff_of_true hvw rfl, iff_of_false (lt_asymm hvw)
                    (by decide +revert)⟩
                | ⟨2, _⟩ => exact ⟨iff_of_true hvltx rfl, iff_of_false (lt_asymm hvltx)
                    (by decide +revert)⟩
                | ⟨3, _⟩ => exact ⟨iff_of_true hvt rfl, iff_of_false (lt_asymm hvt)
                    (by decide +revert)⟩
              have hzeq : zs = kvE2_sep_zPastX4 := zoneHolds_unique M _ v zs _ hzv hpos
              have hbitP : kvE2_sepBits σ kvE2_sep_zPastX4 χ = false := by rw [hzeq] at hbit; exact
                  hbit
              have hlit := (kvE2_sepEpL_owner_lits_R charBase charK qnf M atomMap x σ hσIn hepL χ).1
              rw [hbitP] at hlit
              simp only [kvE2_sepLit, Bool.false_eq_true, if_false] at hlit
              exact hlit ⟨v, hvltx, hχbase, fun r _ _ hf => hf⟩
            · -- v = x : zAtX4, hepL at-x literal
              have hvx1 : v < x1 := by rw [hveqx]; exact hxx1
              have hvw : v < w := by rw [hveqx]; exact hxw
              have hvt : v < t := by rw [hveqx]; exact hxt
              have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                  kvE2_sep_zAtX4 v := by
                intro k
                match k with
                | ⟨0, _⟩ => exact ⟨iff_of_true hvx1 rfl, iff_of_false (lt_asymm hvx1)
                    (by decide +revert)⟩
                | ⟨1, _⟩ => exact ⟨iff_of_true hvw rfl, iff_of_false (lt_asymm hvw)
                    (by decide +revert)⟩
                | ⟨2, _⟩ => exact ⟨iff_of_false (by rw [hveqx]; exact lt_irrefl x)
                    (by decide +revert),
                    iff_of_false (by rw [hveqx]; exact lt_irrefl x) (by decide +revert)⟩
                | ⟨3, _⟩ => exact ⟨iff_of_true hvt rfl, iff_of_false (lt_asymm hvt)
                    (by decide +revert)⟩
              have hzeq : zs = kvE2_sep_zAtX4 := zoneHolds_unique M _ v zs _ hzv hpos
              have hbitA : kvE2_sepBits σ kvE2_sep_zAtX4 χ = false := by rw [hzeq] at hbit; exact
                  hbit
              have hlit := (kvE2_sepEpL_owner_lits_R charBase charK qnf M atomMap x σ hσIn hepL χ).2
              rw [hbitA] at hlit
              simp only [kvE2_sepLit, Bool.false_eq_true, if_false] at hlit
              rw [hveqx] at hχbase
              exact hlit hχbase
        · -- mid : ws ⟨i⟩ < v < ws ⟨i+1⟩
          have hsm := hsegMid i v hi1 hi2
          have hxv : x < v := lt_trans (hrange _).1 hi1
          by_cases hcut : (i : ℕ) + 1 ≤ (kvE2_sepTieGroupedL wo).length
          · -- left cut: v ∈ (x, w) → zone kvE_sub2_zXU (single, no pin)
            rw [kvE2_sepSegsG, if_pos hcut] at hsm
            simp only [kvE2_sepSegLAt, hfrag, List.map_cons, List.map_nil] at hsm
            have hseg1 := (formula_conjList_iff M atomMap v _).mp hsm _ List.mem_cons_self
            rw [kvE2_sepSegLForSub, if_neg hzWT3ne, if_pos hz] at hseg1
            have hvw : v < w := by
              rw [hwdef]; exact lt_of_lt_of_le hi2 (hws_le _ _ _ _ (by omega))
            have hvx1 : v < x1 := hvw.trans hwx1
            have hvt : v < t := hvw.trans hwt
            have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                kvE_sub2_zXU v := by
              intro k
              match k with
              | ⟨0, _⟩ => exact ⟨iff_of_true hvx1 rfl, iff_of_false (lt_asymm hvx1)
                  (by decide +revert)⟩
              | ⟨1, _⟩ => exact ⟨iff_of_true hvw rfl, iff_of_false (lt_asymm hvw)
                  (by decide +revert)⟩
              | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxv) (by decide +revert), iff_of_true hxv
                  rfl⟩
              | ⟨3, _⟩ => exact ⟨iff_of_true hvt rfl, iff_of_false (lt_asymm hvt)
                  (by decide +revert)⟩
            have hzeq : zs = kvE_sub2_zXU := zoneHolds_unique M _ v zs kvE_sub2_zXU hzv hpos
            have hbitX : kvE2_sepBits σ kvE_sub2_zXU χ = false := by rw [hzeq] at hbit; exact hbit
            exact kvE2_sepSegForm_excludes charBase σ kvE_sub2_zXU χ M atomMap v hseg1 hbitX hχbase
          · -- right cut: v ∈ (w, t) → zone zWX1 or kvE_sub2_zWT via the pin
            rw [kvE2_sepSegsG, if_neg hcut] at hsm
            simp only [kvE2_sepSegRAt, hfrag, List.map_cons, List.map_nil] at hsm
            have hseg1 := (formula_conjList_iff M atomMap v _).mp hsm _ List.mem_cons_self
            rw [kvE2_sepSegRForSub, if_neg hzWT3ne, if_pos hz,
              ← kvE2_sep_take_flatten_prefix] at hseg1
            have hwv : w < v := by
              rw [hwdef]; exact lt_of_le_of_lt (hws_le _ _ _ _ (by omega)) hi1
            have hvt : v < t := lt_trans hi2 (hrange _).2
            have hxvr : x < v := hxw.trans hwv
            by_cases hpin : irσ < (i : ℕ) - (kvE2_sepTieGroupedL wo).length
            · -- pin in take → v > x1 → kvE_sub2_zWT
              have hx1v : x1 < v := by
                rw [hx1def]; exact lt_of_le_of_lt (hws_le _ _ _ _ (by omega)) hi1
              have hmem : (KvE2SepSlot.rX1 σ) ∈ ((kvE2_sepTieGroupedR wo).take
                  ((i : ℕ) + 1 - (kvE2_sepTieGroupedL wo).length - 1)).flatten :=
                (kvE2_sep_pin_mem_take_flatten_iff _ hndR _ irσ hirσ hsc' _).mpr (by omega)
              rw [if_pos (List.contains_iff_mem.mpr hmem)] at hseg1
              have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                  kvE_sub2_zWT v := by
                intro k
                match k with
                | ⟨0, _⟩ => exact ⟨iff_of_false (lt_asymm hx1v) (by decide +revert), iff_of_true
                    hx1v rfl⟩
                | ⟨1, _⟩ => exact ⟨iff_of_false (lt_asymm hwv) (by decide +revert), iff_of_true hwv
                    rfl⟩
                | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxvr) (by decide +revert), iff_of_true
                    hxvr rfl⟩
                | ⟨3, _⟩ => exact ⟨iff_of_true hvt rfl, iff_of_false (lt_asymm hvt)
                    (by decide +revert)⟩
              have hzeq : zs = kvE_sub2_zWT := zoneHolds_unique M _ v zs kvE_sub2_zWT hzv hpos
              have hbitW : kvE2_sepBits σ kvE_sub2_zWT χ = false := by rw [hzeq] at hbit; exact hbit
              exact kvE2_sepSegForm_excludes charBase σ kvE_sub2_zWT χ M atomMap v hseg1 hbitW
                  hχbase
            · -- pin not in take → v < x1 → zWX1
              have hvx1 : v < x1 := by
                rw [hx1def]; exact lt_of_lt_of_le hi2 (hws_le _ _ _ _ (by omega))
              have hnmem : (KvE2SepSlot.rX1 σ) ∉ ((kvE2_sepTieGroupedR wo).take
                  ((i : ℕ) + 1 - (kvE2_sepTieGroupedL wo).length - 1)).flatten := by
                intro hc
                exact absurd ((kvE2_sep_pin_mem_take_flatten_iff _ hndR _ irσ hirσ hsc' _).mp hc)
                    (by omega)
              rw [if_neg (fun hc => hnmem (List.contains_iff_mem.mp hc))] at hseg1
              have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                  kvE2_sep_zWX1 v := by
                intro k
                match k with
                | ⟨0, _⟩ => exact ⟨iff_of_true hvx1 rfl, iff_of_false (lt_asymm hvx1)
                    (by decide +revert)⟩
                | ⟨1, _⟩ => exact ⟨iff_of_false (lt_asymm hwv) (by decide +revert), iff_of_true hwv
                    rfl⟩
                | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxvr) (by decide +revert), iff_of_true
                    hxvr rfl⟩
                | ⟨3, _⟩ => exact ⟨iff_of_true hvt rfl, iff_of_false (lt_asymm hvt)
                    (by decide +revert)⟩
              have hzeq : zs = kvE2_sep_zWX1 := zoneHolds_unique M _ v zs kvE2_sep_zWX1 hzv hpos
              have hbitW : kvE2_sepBits σ kvE2_sep_zWX1 χ = false := by rw [hzeq] at hbit; exact
                  hbit
              exact kvE2_sepSegForm_excludes charBase σ kvE2_sep_zWX1 χ M atomMap v hseg1 hbitW
                  hχbase
        · -- hhigh : ws ⟨last⟩ < v
          have hwv : w < v :=
            lt_of_le_of_lt (by rw [hwdef]; exact hws_le _ _ _ _ (by omega)) hhigh
          have hxv : x < v := lt_trans hxw hwv
          rcases lt_or_ge v t with hvltt | htlev
          · -- w < v < t : v > x1 (pin ≤ last) → kvE_sub2_zWT via hsegLast
            have hx1v : x1 < v :=
              lt_of_le_of_lt (by rw [hx1def]; exact hws_le _ _ _ _ (by omega)) hhigh
            have hsm := hsegLast v hhigh hvltt
            rw [kvE2_sepSegsG, if_neg (show ¬ _ from by simp only [hlenL]; omega)] at hsm
            simp only [kvE2_sepSegRAt, hfrag, List.map_cons, List.map_nil] at hsm
            have hseg1 := (formula_conjList_iff M atomMap v _).mp hsm _ List.mem_cons_self
            rw [kvE2_sepSegRForSub, if_neg hzWT3ne, if_pos hz,
              ← kvE2_sep_take_flatten_prefix] at hseg1
            have hmem : (KvE2SepSlot.rX1 σ) ∈ ((kvE2_sepTieGroupedR wo).take
                ((List.map (kvE2_sepClassType charBase charK) (kvE2_sepTieGroupedL wo)).length
                  + (List.map (kvE2_sepClassType charBase charK) (kvE2_sepTieGroupedR wo)).length +
                      1
                  - (kvE2_sepTieGroupedL wo).length - 1)).flatten :=
              (kvE2_sep_pin_mem_take_flatten_iff _ hndR _ irσ hirσ hsc' _).mpr (by
                simp only [List.length_map] at hirσm ⊢; omega)
            rw [if_pos (List.contains_iff_mem.mpr hmem)] at hseg1
            have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                kvE_sub2_zWT v := by
              intro k
              match k with
              | ⟨0, _⟩ => exact ⟨iff_of_false (lt_asymm hx1v) (by decide +revert), iff_of_true hx1v
                  rfl⟩
              | ⟨1, _⟩ => exact ⟨iff_of_false (lt_asymm hwv) (by decide +revert), iff_of_true hwv
                  rfl⟩
              | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxv) (by decide +revert), iff_of_true hxv
                  rfl⟩
              | ⟨3, _⟩ => exact ⟨iff_of_true hvltt rfl, iff_of_false (lt_asymm hvltt)
                  (by decide +revert)⟩
            have hzeq : zs = kvE_sub2_zWT := zoneHolds_unique M _ v zs kvE_sub2_zWT hzv hpos
            have hbitW : kvE2_sepBits σ kvE_sub2_zWT χ = false := by rw [hzeq] at hbit; exact hbit
            exact kvE2_sepSegForm_excludes charBase σ kvE_sub2_zWT χ M atomMap v hseg1 hbitW hχbase
          · -- t ≤ v : boundary via hepR
            have hx1v : x1 < v := lt_of_lt_of_le hx1t htlev
            rcases lt_or_eq_of_le htlev with htltv | hteqv
            · -- t < v : zFutT4, hepR Until-literal
              have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                  kvE2_sep_zFutT4 v := by
                intro k
                match k with
                | ⟨0, _⟩ => exact ⟨iff_of_false (lt_asymm hx1v) (by decide +revert), iff_of_true
                    hx1v rfl⟩
                | ⟨1, _⟩ => exact ⟨iff_of_false (lt_asymm hwv) (by decide +revert), iff_of_true hwv
                    rfl⟩
                | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxv) (by decide +revert), iff_of_true hxv
                    rfl⟩
                | ⟨3, _⟩ => exact ⟨iff_of_false (lt_asymm htltv) (by decide +revert), iff_of_true
                    htltv rfl⟩
              have hzeq : zs = kvE2_sep_zFutT4 := zoneHolds_unique M _ v zs _ hzv hpos
              have hbitF : kvE2_sepBits σ kvE2_sep_zFutT4 χ = false := by rw [hzeq] at hbit; exact
                  hbit
              have hlit := (kvE2_sepEpR_owner_lits_R charBase charK qnf M atomMap t σ hσIn hepR χ).2
              rw [hbitF] at hlit
              simp only [kvE2_sepLit, Bool.false_eq_true, if_false] at hlit
              exact hlit ⟨v, htltv, hχbase, fun r _ _ hf => hf⟩
            · -- v = t : zAtT4, hepR at-t literal
              have hpos : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
                  kvE2_sep_zAtT4 v := by
                intro k
                match k with
                | ⟨0, _⟩ => exact ⟨iff_of_false (lt_asymm hx1v) (by decide +revert), iff_of_true
                    hx1v rfl⟩
                | ⟨1, _⟩ => exact ⟨iff_of_false (lt_asymm hwv) (by decide +revert), iff_of_true hwv
                    rfl⟩
                | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxv) (by decide +revert), iff_of_true hxv
                    rfl⟩
                | ⟨3, _⟩ => exact ⟨iff_of_false (by rw [← hteqv]; exact lt_irrefl t)
                    (by decide +revert),
                    iff_of_false (by rw [← hteqv]; exact lt_irrefl t) (by decide +revert)⟩
              have hzeq : zs = kvE2_sep_zAtT4 := zoneHolds_unique M _ v zs _ hzv hpos
              have hbitAT : kvE2_sepBits σ kvE2_sep_zAtT4 χ = false := by rw [hzeq] at hbit; exact
                  hbit
              have hlit := (kvE2_sepEpR_owner_lits_R charBase charK qnf M atomMap t σ hσIn hepR χ).1
              rw [hbitAT] at hlit
              simp only [kvE2_sepLit, Bool.false_eq_true, if_false] at hlit
              rw [← hteqv] at hχbase
              exact hlit hχbase
      have h_bwd : ∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1), zs ≠ kvE2_sep_zWX1 →
          σ.2 (nf0_assemble zs χ σ.1) = true →
          ∃ v : M.carrier,
            zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
            nf_eval_nf M 0 1 (fun _ => v) χ := by
        intro zs χ hzsne hbit
        have hσIn : σ ∈ kvE2_sepPosIn qnf kvE2_sep_zWT3 :=
          List.mem_filter.mpr ⟨hσ0pos, by simp only [decide_eq_true_eq]; exact hz⟩
        have tonf : ∀ (v : M.carrier),
            temporal_truth M atomMap v (charBase χ) → nf_eval_nf M 0 1 (fun _ => v) χ := by
          intro v hv; rw [hcb] at hv; exact (nfPred_correct M atomMap h_surj χ v).mp hv
        -- classify: a true bit forces `zs` among the nine RIGHT inner-consistent zones
        -- (gate clause v — the zWT3 mirror of clause iv, recovered from `hg`)
        have hcons : kvE2_sepInnerConsistentR zs := by
          by_contra hncons
          rw [hg.2.2.2.2 σ hσ0true hz zs χ hncons] at hbit
          exact absurd hbit (by decide)
        rcases hcons with h | h | h | h | h | h | h | h | h
        · -- zPastX4  (v < x)
          have hzp : zs = kvE2_sep_zPastX4 := h
          rw [hzp] at hbit ⊢
          have hbitT : kvE2_sepBits σ kvE2_sep_zPastX4 χ = true := hbit
          have hlit := (kvE2_sepEpL_owner_lits_R charBase charK qnf M atomMap x σ hσIn hepL χ).1
          rw [hbitT] at hlit
          simp only [kvE2_sepLit, if_true] at hlit
          obtain ⟨s, hsx, hχs, -⟩ := hlit
          have hsx1 : s < x1 := hsx.trans hxx1
          have hsw : s < w := hsx.trans hxw
          have hst : s < t := hsx.trans hxt
          refine ⟨s, ?_, tonf _ hχs⟩
          intro k
          match k with
          | ⟨0, _⟩ => exact ⟨iff_of_true hsx1 rfl, iff_of_false (lt_asymm hsx1) (by decide +revert)⟩
          | ⟨1, _⟩ => exact ⟨iff_of_true hsw rfl, iff_of_false (lt_asymm hsw) (by decide +revert)⟩
          | ⟨2, _⟩ => exact ⟨iff_of_true hsx rfl, iff_of_false (lt_asymm hsx) (by decide +revert)⟩
          | ⟨3, _⟩ => exact ⟨iff_of_true hst rfl, iff_of_false (lt_asymm hst) (by decide +revert)⟩
        · -- zAtX4  (v = x)
          have hzx : zs = kvE2_sep_zAtX4 := h
          rw [hzx] at hbit ⊢
          have hbitT : kvE2_sepBits σ kvE2_sep_zAtX4 χ = true := hbit
          have hlit := (kvE2_sepEpL_owner_lits_R charBase charK qnf M atomMap x σ hσIn hepL χ).2
          rw [hbitT] at hlit
          simp only [kvE2_sepLit, if_true] at hlit
          refine ⟨x, ?_, tonf _ hlit⟩
          intro k
          match k with
          | ⟨0, _⟩ => exact ⟨iff_of_true hxx1 rfl, iff_of_false (lt_asymm hxx1) (by decide +revert)⟩
          | ⟨1, _⟩ => exact ⟨iff_of_true hxw rfl, iff_of_false (lt_asymm hxw) (by decide +revert)⟩
          | ⟨2, _⟩ => exact ⟨iff_of_false (lt_irrefl x) (by decide +revert),
              iff_of_false (lt_irrefl x) (by decide +revert)⟩
          | ⟨3, _⟩ => exact ⟨iff_of_true hxt rfl,
              iff_of_false (lt_asymm hxt) (by decide +revert)⟩
        · -- zXW = kvE_sub2_zXU  (x < v < w) : left-group rXW slot machinery
          have hzxw : zs = kvE_sub2_zXU := h
          rw [hzxw] at hbit ⊢
          have hbitT : σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true := hbit
          have hrXW : (KvE2SepSlot.rXW σ χ) ∈ kvE2_sepSlotsLFor σ :=
            kvE2_sep_rXW_mem_slotsLFor hz hbitT
          have hmemL : (KvE2SepSlot.rXW σ χ) ∈ kvE2_sepSlotsLOf wo :=
            kvE2_sepSlotsLOf_mem qnf hwo' hσI hrXW
          rw [← kvE2_sepTieGroupedL_flatten wo] at hmemL
          obtain ⟨d, hd, hsd⟩ := List.mem_flatten.mp hmemL
          obtain ⟨jl, hjl, hgetjl⟩ := List.mem_iff_getElem.mp hd
          have hjlm : jl < ((kvE2_sepTieGroupedL wo).map
              (kvE2_sepClassType charBase charK)).length := by
            simp only [List.length_map]; omega
          have hchar := hpt' jl (by omega)
          rw [kvE2_sep_getElem_left _ _ _ jl hjlm, List.getElem_map, hgetjl] at hchar
          have hcharχ := kvE2_sepClassType_eval_mem charBase charK M atomMap _ hchar hsd
          set v := ws ⟨jl, by omega⟩ with hvdef
          have hxv : x < v := (hrange _).1
          have hvw : v < w := by
            rw [hwdef, hvdef]; exact hmono _ _ (Fin.mk_lt_mk.mpr hjlm)
          have hvx1 : v < x1 := hvw.trans hwx1
          have hvt : v < t := hvw.trans hwt
          refine ⟨v, ?_, tonf _ hcharχ⟩
          intro k
          match k with
          | ⟨0, _⟩ => exact ⟨iff_of_true hvx1 rfl, iff_of_false (lt_asymm hvx1) (by decide +revert)⟩
          | ⟨1, _⟩ => exact ⟨iff_of_true hvw rfl, iff_of_false (lt_asymm hvw) (by decide +revert)⟩
          | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxv) (by decide +revert), iff_of_true hxv rfl⟩
          | ⟨3, _⟩ => exact ⟨iff_of_true hvt rfl, iff_of_false (lt_asymm hvt) (by decide +revert)⟩
        · -- zAtWR  (v = w)
          have hzw : zs = kvE2_sep_zAtWR := h
          rw [hzw] at hbit ⊢
          have hbitT : kvE2_sepBits σ kvE2_sep_zAtWR χ = true := hbit
          have hlit := kvE2_sepPtW_owner_lit_R charBase charK qnf M atomMap w σ hσIn hptW χ
          rw [hbitT] at hlit
          simp only [kvE2_sepLit, if_true] at hlit
          refine ⟨w, ?_, tonf _ hlit⟩
          intro k
          match k with
          | ⟨0, _⟩ => exact ⟨iff_of_true hwx1 rfl, iff_of_false (lt_asymm hwx1) (by decide +revert)⟩
          | ⟨1, _⟩ => exact ⟨iff_of_false (lt_irrefl w) (by decide +revert),
              iff_of_false (lt_irrefl w) (by decide +revert)⟩
          | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxw) (by decide +revert), iff_of_true hxw rfl⟩
          | ⟨3, _⟩ => exact ⟨iff_of_true hwt rfl, iff_of_false (lt_asymm hwt) (by decide +revert)⟩
        · -- zWX1  (excluded by hypothesis)
          exact absurd h hzsne
        · -- zAtX1R  (v = x1)
          have hzx1 : zs = kvE2_sep_zAtX1R := h
          rw [hzx1] at hbit ⊢
          have hbitT : kvE2_sepBits σ kvE2_sep_zAtX1R χ = true := hbit
          have hlit := kvE2_sepPtX1R_owner_lit charBase charK σ M atomMap x1 hpt_pin χ
          rw [hbitT] at hlit
          simp only [kvE2_sepLit, if_true] at hlit
          refine ⟨x1, ?_, tonf _ hlit⟩
          intro k
          match k with
          | ⟨0, _⟩ => exact ⟨iff_of_false (lt_irrefl x1) (by decide +revert),
              iff_of_false (lt_irrefl x1) (by decide +revert)⟩
          | ⟨1, _⟩ => exact ⟨iff_of_false (lt_asymm hwx1) (by decide +revert), iff_of_true hwx1 rfl⟩
          | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxx1) (by decide +revert), iff_of_true hxx1 rfl⟩
          | ⟨3, _⟩ => exact ⟨iff_of_true hx1t rfl, iff_of_false (lt_asymm hx1t) (by decide +revert)⟩
        · -- zX1T = kvE_sub2_zWT  (x1 < v < t) : right-group rX1T slot machinery above the pin
          have hzwt : zs = kvE_sub2_zWT := h
          rw [hzwt] at hbit ⊢
          have hbitT : σ.2 (nf0_assemble kvE_sub2_zWT χ σ.1) = true := hbit
          have hrX1T : (KvE2SepSlot.rX1T σ χ) ∈ kvE2_sepSlotsRFor σ :=
            kvE2_sep_rX1T_mem_slotsRFor hz hbitT
          have hmemR : (KvE2SepSlot.rX1T σ χ) ∈ kvE2_sepSlotsROf wo :=
            kvE2_sepSlotsROf_mem qnf hwo' hσI hrX1T
          rw [← kvE2_sepTieGroupedR_flatten wo] at hmemR
          obtain ⟨d, hd, hsd⟩ := List.mem_flatten.mp hmemR
          obtain ⟨jr, hjr, hgetjr⟩ := List.mem_iff_getElem.mp hd
          have hkey : kvE2_sepSlotGIdx wo (KvE2SepSlot.rX1 σ)
              < kvE2_sepSlotGIdx wo (KvE2SepSlot.rX1T σ χ) :=
            kvE2_sep_gidx_lt_of_rank_lt qnf hwo hpe
              (by rw [kvE2_sepSlotBlock]
                  exact List.mem_append_right _ (kvE2_sep_rX1_mem_slotsRFor hz))
              (by rw [kvE2_sepSlotBlock]
                  exact List.mem_append_right _ (kvE2_sep_rX1T_mem_slotsRFor hz hbitT))
              rfl Nat.one_lt_two
          have hain : (KvE2SepSlot.rX1T σ χ) ∈ (kvE2_sepTieGroupedR wo)[jr]'hjr := by
            rw [hgetjr]; exact hsd
          have hbin : (KvE2SepSlot.rX1 σ) ∈ (kvE2_sepTieGroupedR wo)[irσ]'hirσ := by
            rw [hgetirσ]; exact hsc
          have hij : irσ < jr := kvE2_sepTieRuns_classIdx_lt (kvE2_sepSlotGIdx wo)
            (kvE2_sepSlotsROf wo) hksortR hirσ hjr hbin hain hkey
          have hjrm : jr < ((kvE2_sepTieGroupedR wo).map
              (kvE2_sepClassType charBase charK)).length := by
            simp only [List.length_map]; omega
          have hK : ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length + 1 +
              jr
              < ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length
                + ((kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK)).length + 1 := by
            simp only [List.length_map] at hjrm ⊢; omega
          have hchar := hpt' (((kvE2_sepTieGroupedL wo).map
              (kvE2_sepClassType charBase charK)).length
            + 1 + jr) hK
          rw [kvE2_sep_getElem_right _ _ _ jr hjrm, List.getElem_map, hgetjr] at hchar
          have hcharχ := kvE2_sepClassType_eval_mem charBase charK M atomMap _ hchar hsd
          set v := ws ⟨((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length + 1
              + jr,
            hK⟩ with hvdef
          have hx1v : x1 < v := by
            rw [hx1def, hvdef]; exact hmono _ _ (Fin.mk_lt_mk.mpr (by omega))
          have hvt : v < t := (hrange _).2
          have hwv : w < v := hwx1.trans hx1v
          have hxv : x < v := hxx1.trans hx1v
          refine ⟨v, ?_, tonf _ hcharχ⟩
          intro k
          match k with
          | ⟨0, _⟩ => exact ⟨iff_of_false (lt_asymm hx1v) (by decide +revert), iff_of_true hx1v rfl⟩
          | ⟨1, _⟩ => exact ⟨iff_of_false (lt_asymm hwv) (by decide +revert), iff_of_true hwv rfl⟩
          | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxv) (by decide +revert), iff_of_true hxv rfl⟩
          | ⟨3, _⟩ => exact ⟨iff_of_true hvt rfl, iff_of_false (lt_asymm hvt) (by decide +revert)⟩
        · -- zAtT4  (v = t)
          have hzt : zs = kvE2_sep_zAtT4 := h
          rw [hzt] at hbit ⊢
          have hbitT : kvE2_sepBits σ kvE2_sep_zAtT4 χ = true := hbit
          have hlit := (kvE2_sepEpR_owner_lits_R charBase charK qnf M atomMap t σ hσIn hepR χ).1
          rw [hbitT] at hlit
          simp only [kvE2_sepLit, if_true] at hlit
          refine ⟨t, ?_, tonf _ hlit⟩
          intro k
          match k with
          | ⟨0, _⟩ => exact ⟨iff_of_false (lt_asymm hx1t) (by decide +revert),
              iff_of_true hx1t rfl⟩
          | ⟨1, _⟩ => exact ⟨iff_of_false (lt_asymm hwt) (by decide +revert), iff_of_true hwt rfl⟩
          | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxt) (by decide +revert),
              iff_of_true hxt rfl⟩
          | ⟨3, _⟩ => exact ⟨iff_of_false (lt_irrefl t) (by decide +revert),
              iff_of_false (lt_irrefl t) (by decide +revert)⟩
        · -- zFutT4  (t < v)
          have hzf : zs = kvE2_sep_zFutT4 := h
          rw [hzf] at hbit ⊢
          have hbitT : kvE2_sepBits σ kvE2_sep_zFutT4 χ = true := hbit
          have hlit := (kvE2_sepEpR_owner_lits_R charBase charK qnf M atomMap t σ hσIn hepR χ).2
          rw [hbitT] at hlit
          simp only [kvE2_sepLit, if_true] at hlit
          obtain ⟨u, htu, hχu, -⟩ := hlit
          have hu_x1 : x1 < u := hx1t.trans htu
          have hu_w : w < u := hwt.trans htu
          have hu_x : x < u := hxt.trans htu
          refine ⟨u, ?_, tonf _ hχu⟩
          intro k
          match k with
          | ⟨0, _⟩ => exact ⟨iff_of_false (lt_asymm hu_x1) (by decide +revert), iff_of_true hu_x1
              rfl⟩
          | ⟨1, _⟩ => exact ⟨iff_of_false (lt_asymm hu_w) (by decide +revert), iff_of_true hu_w rfl⟩
          | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hu_x) (by decide +revert), iff_of_true hu_x rfl⟩
          | ⟨3, _⟩ => exact ⟨iff_of_false (lt_asymm htu) (by decide +revert), iff_of_true htu rfl⟩
      exact kvE2_sepBundleR_sound_frag atomMap h_surj σ M w x t hxw x1 hwx1 hx1t hbelow
        h_atom h_off h_fwd h_bwd
  · rw [kvE2_sepBody_gate_fail charBase charK qnf hg] at h
    simp [VVecEA2.holds] at h

/-- **Pin-anchored per-σ kit application** (the `_frag` variant of
    `kvE2_sepBody_kit_sound`; interior-singleton REPAIR).

    Under the interior-singleton fragment predicate (`kvE2_sepFragment_frag` now keys on
    `kvE2_sepPosI qnf = [σ0]`) the sole INTERIOR positive is `σ0`, but the
    GLOBAL positive list `kvE2_sepPos qnf` additionally carries the ≥3 boundary positives that
    `nf_exists_unique` forces on every realized `qnf` (335 report 07 Refutation 1). The former
    dispatch to `kvE2_sepGateAtPin_fragL`/`_fragR` is therefore UNAVAILABLE: those frozen
    producers demand the GLOBAL singleton `kvE2_sepPos qnf = [σ0]`, which is unrealizable under
    the swap (`kvE2_sepPosI qnf = [σ0] ⇏ kvE2_sepPos qnf = [σ0]`, Phase 1 triage). They remain
    green but genuinely inapplicable in the new regime.

    The two interior realization clauses of the conclusion range over the interior zones
    `zXW3`/`zWT3`; every such σ is provider-realized. Following the Phase-3 architecture
    (`hexcl`/`hexclExt` split — the deferred obligation is a NAMED hypothesis carried by the
    caller, discharged downstream at the provider instantiation, never assumed
    in-carrier), the per-positive realization is threaded as `hreal`. The endpoint/witness
    facts (`kvE2_sepEpL`/`kvE2_sepEpR`/`kvE2_sepPtW` at `x`/`t`/`w`) are extracted from the
    realized body via the frozen `kvE2_sepBody_extract`. `hreal ∧ hexcl ∧ hexclExt` (the fold's
    full interface) together equal the honest "positives realized, negatives excluded" content;
    no logical strength is silently dropped and no sorry sits on any live path. -/
theorem kvE2_sepBody_kit_sound_frag {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig)
    (x t : M.carrier)
    (h : (kvE2_sepBody (nf_depth0_char_formula atomMap h_surj) charK qnf).holds M atomMap x t)
    -- R1 realization channel: per-positive realization at the extracted
    -- pivot `w`, the completeness dual of `hexcl`. Provider-discharged, never assumed
    -- in-carrier — the carrier records σ's bits but does not itself witness boundary σ's zone
    -- content (design note SW:10027-10032). Interior positives collapse to σ0 under `hfrag`;
    -- boundary positives ride their `charK` endpoint literals at the caller.
    (hreal : ∀ w : M.carrier, x < w → w < t →
      (kvE2_sepPtW (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap w →
      ∀ σ ∈ kvE2_sepPos qnf,
        ∃ x1 : M.carrier,
          nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    (kvE2_sepEpL (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap x ∧
    (kvE2_sepEpR (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap t ∧
    ∃ w : M.carrier, x < w ∧ w < t ∧
      (kvE2_sepPtW (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap w ∧
      (∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zXW3 →
        ∃ x1 : M.carrier,
          nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) ∧
      (∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zWT3 →
        ∃ x1 : M.carrier,
          nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) := by
  obtain ⟨hEpL, hEpR, w, hxw, hwt, hptW, -, -⟩ :=
    kvE2_sepBody_extract (nf_depth0_char_formula atomMap h_surj) charK qnf M atomMap x t h
  exact ⟨hEpL, hEpR, w, hxw, hwt, hptW,
    fun σ hσ _hz => hreal w hxw hwt hptW σ hσ,
    fun σ hσ _hz => hreal w hxw hwt hptW σ hσ⟩

/-- **R1 interior-slice order-atom discharge** (report 01 §7 R1,
    `NormalForm.lean:201-202`; Rabinovich Notation 5.2 strictly-interior witnesses).
    A strictly-exterior `x1` (outside the closed cone `x ≤ x1 ≤ t`) falsifies any
    interior-marked σ (`nf0_zoneSpec σ.1 ∈ {kvE2_sep_zXW3, kvE2_sep_zWT3}`) directly
    from the depth-0 atom clause, with NO residue. Both interior zones assert BOTH
    `x < x1` (bit `(nf0_zoneSpec σ.1 ⟨1⟩).2`, atom `.order 2 0`) AND `x1 < t` (bit
    `(nf0_zoneSpec σ.1 ⟨2⟩).1`, atom `.order 0 3`) over the env `[x1,w,x,t]`; a realized
    σ would therefore force `x < x1 ∧ x1 < t`, contradicting the exterior guard. This is
    the order-atom-only core of R1: the interior slice of the monolithic `hexclExt`
    obligation carries no genuine content, so the deferred residue is exterior-marked σ
    only (report 01 §7 R1 / C1: "hexclExt = phantom" for the interior slice). The `omega`/
    `exact` closer on the falsified `.order` literal is the sanctioned move (no
    `simp`/`decide` over the whole `nf_eval_nf`, per plan Postmortem Constraints). -/
theorem kvE2_sepInterior_exterior_notRealizable {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (x1 w x t : M.carrier)
    (σ : NormalForm sig 1 4)
    (hzone : nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3)
    (hguard : ¬ (x ≤ x1 ∧ x1 ≤ t)) :
    ¬ nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  intro hnf
  obtain ⟨hσ_atom, _⟩ := hnf
  -- Both interior zones assert `x < x1` (index-1 `.2` bit) and `x1 < t` (index-2 `.1` bit);
  -- the zone-spec components ARE σ.1's fresh-coupling order bits (`nf0_zoneSpec` def).
  have hbit_xx1 : (nf0_zoneSpec σ.1 ⟨1, by omega⟩).2 = true := by
    rcases hzone with hz | hz <;> rw [congrFun hz ⟨1, by omega⟩] <;> decide
  have hbit_x1t : (nf0_zoneSpec σ.1 ⟨2, by omega⟩).1 = true := by
    rcases hzone with hz | hz <;> rw [congrFun hz ⟨2, by omega⟩] <;> decide
  -- Transfer the bits to real order facts through the realized depth-0 atom layer.
  have hxx1 : x < x1 := by
    have h1 := hσ_atom (.order (Fin.succ ⟨1, by omega⟩) 0 (Fin.succ_ne_zero ⟨1, by omega⟩))
    simp only [atom_eval, Fin.cons] at h1
    exact h1.mpr hbit_xx1
  have hx1t : x1 < t := by
    have h1 := hσ_atom (.order 0 (Fin.succ ⟨2, by omega⟩) (Fin.succ_ne_zero ⟨2, by omega⟩).symm)
    simp only [atom_eval, Fin.cons] at h1
    exact h1.mpr hbit_x1t
  exact hguard ⟨le_of_lt hxx1, le_of_lt hx1t⟩

/-- **Pin-anchored outer fold** (the `_frag` variant of `kvE2_outer_fold`;
    interior-singleton REPAIR). The outer atom layer is assembled from the carrier's endpoint/
    witness point types; the depth-1 quant layer is closed by the honest realize/exclude
    interface `hreal` (backward: every positive σ realized at the pivot `w`) + `hexcl`/`hexclExt`
    (forward: negatives excluded on the cone / exterior — the Phase-3 R1 split).

    Under the interior-singleton predicate swap (Phase 1) `kvE2_sepPos qnf` carries the sole
    interior owner σ0 PLUS the boundary positives `nf_exists_unique` forces; the former
    `hfrag`-driven `exfalso` (backward branch "unreachable" because the GLOBAL singleton left no
    non-interior positive) is retired — boundary positives are now admissible and are REALIZED
    via `hreal`, not refuted. `hreal ∧ hexcl ∧ hexclExt` is the honest depth-1 fold interface,
    provider-discharged downstream (the Prop-4.3 exterior successor), never assumed
    in-carrier (design note SW:10027-10032). Delivered to
    `bracketEndChar_kvE2_correct_two_prior_frag` (OuterGate.lean). -/
theorem kvE2_outer_fold_frag {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    (h_xy : qnf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig)
    (x t : M.carrier)
    (h : (kvE2_sepBody (nf_depth0_char_formula atomMap h_surj) charK qnf).holds M atomMap x t)
    -- R1 realization channel: the completeness dual of `hexcl`/`hexclExt`.
    -- Every positive sub `σ` is realized at the extracted pivot `w`. Under the interior-singleton
    -- swap (Phase 1) `kvE2_sepPos qnf` carries the sole interior owner σ0 PLUS the ≥3 boundary
    -- positives; the former `hfrag`-driven `exfalso` (boundary unreachable under the GLOBAL
    -- singleton) is retired because those boundary positives are now admissible and must be
    -- realized. Provider-discharged downstream (Prop-4.3 successor), never assumed
    -- in-carrier (design note SW:10027-10032) — the mirror of the Phase-3 `hexclExt` split.
    (hreal : ∀ w : M.carrier, x < w → w < t →
      (kvE2_sepPtW (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap w →
      ∀ σ ∈ kvE2_sepPos qnf,
        ∃ x1 : M.carrier,
          nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexcl : ∀ w : M.carrier, x < w → w < t →
      (kvE2_sepPtW (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap w →
      ∀ σ : NormalForm sig 1 4, qnf.2 σ = false →
        ∀ x1 : M.carrier, x ≤ x1 → x1 ≤ t →
          ¬ nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    -- R1: the exterior residue of the former single-`hexcl` exclusion clause.
    -- `hexcl` above is boundary-restricted to the interior+boundary cone `x ≤ x1 ≤ t`
    -- (dischargeable
    -- by the landed endpoint/witness literals); `hexclExt` isolates the STRICTLY-EXTERIOR case
    -- (`¬ (x ≤ x1 ∧ x1 ≤ t)`), the outer-forward completeness obligation carried by the caller.
    -- R1 (report 01 §7): `hexclExt` is now further NARROWED to EXTERIOR-MARKED σ only
    -- (`¬ (nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ = kvE2_sep_zWT3)`). The interior-marked slice
    -- (`zXW3`/`zWT3`) of the strictly-exterior case carries NO genuine content — it is discharged
    -- in-line at the fold body via the Phase-1 order-atom lemma
    -- `kvE2_sepInterior_exterior_notRealizable` (a strictly-exterior `x1` falsifies an interior σ's
    -- `.order` atoms directly). The remaining deferred obligation is the EXTERIOR-ARRANGEMENT
    -- residue
    -- only, whose faithful mechanism is the Prop-4.3 re-flatten / Lemma 7.6 adjacency successor
    -- (report 01 §7 R2; NOT exterior-exclusion on this bracket — that framing is retired).
    -- Splitting-and-narrowing rather than dropping keeps this fold a genuine, sorry-free
    -- conditional
    -- theorem whose cone + interior-exterior halves are independently consumable.
    (hexclExt : ∀ w : M.carrier, x < w → w < t →
      (kvE2_sepPtW (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap w →
      ∀ σ : NormalForm sig 1 4, qnf.2 σ = false →
        ¬ (nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3) →
        ∀ x1 : M.carrier, ¬ (x ≤ x1 ∧ x1 ≤ t) →
          ¬ nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    ∃ w : M.carrier,
      nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf := by
  obtain ⟨hEpL, hEpR, w, hxw, hwt, hptW, -, -⟩ :=
    kvE2_sepBody_kit_sound_frag atomMap h_surj charK qnf M x t h hreal
  have hprojW : nf_eval_nf M 0 1 (fun _ => w) (kvE2_sepProj3 qnf.1 ⟨0, by omega⟩) := by
    have h1 := hptW
    simp only [kvE2_sepPtW, TemporalPred.eval_at] at h1
    exact (nfPred_correct M atomMap h_surj _ w).mp
      ((formula_conjList_iff M atomMap w _).mp h1 _ List.mem_cons_self)
  have hprojX : nf_eval_nf M 0 1 (fun _ => x) (kvE2_sepProj3 qnf.1 ⟨1, by omega⟩) := by
    have h1 := hEpL
    simp only [kvE2_sepEpL, TemporalPred.eval_at] at h1
    exact (nfPred_correct M atomMap h_surj _ x).mp
      ((formula_conjList_iff M atomMap x _).mp h1 _ List.mem_cons_self)
  have hprojT : nf_eval_nf M 0 1 (fun _ => t) (kvE2_sepProj3 qnf.1 ⟨2, by omega⟩) := by
    have h1 := hEpR
    simp only [kvE2_sepEpR, TemporalPred.eval_at] at h1
    exact (nfPred_correct M atomMap h_surj _ t).mp
      ((formula_conjList_iff M atomMap t _).mp h1 _ List.mem_cons_self)
  refine ⟨w, ?_, ?_⟩
  · intro a
    match a with
    | .pred p ⟨0, _⟩ =>
      have h1 := hprojW (.pred p ⟨0, by omega⟩)
      exact h1
    | .pred p ⟨1, _⟩ =>
      have h1 := hprojX (.pred p ⟨0, by omega⟩)
      exact h1
    | .pred p ⟨2, _⟩ =>
      have h1 := hprojT (.pred p ⟨0, by omega⟩)
      exact h1
    | .order ⟨0, _⟩ ⟨1, _⟩ hne =>
      refine iff_of_false ?_ (fun hc => Bool.false_ne_true (h_yx.symm.trans hc))
      simp only [atom_eval]
      exact lt_asymm hxw
    | .order ⟨0, _⟩ ⟨2, _⟩ hne =>
      refine iff_of_true ?_ h_yt
      simp only [atom_eval]
      exact hwt
    | .order ⟨1, _⟩ ⟨0, _⟩ hne =>
      refine iff_of_true ?_ h_xy
      simp only [atom_eval]
      exact hxw
    | .order ⟨1, _⟩ ⟨2, _⟩ hne =>
      refine iff_of_true ?_ h_xt
      simp only [atom_eval]
      exact hxw.trans hwt
    | .order ⟨2, _⟩ ⟨0, _⟩ hne =>
      refine iff_of_false ?_ (fun hc => Bool.false_ne_true (h_ty.symm.trans hc))
      simp only [atom_eval]
      exact lt_asymm hwt
    | .order ⟨2, _⟩ ⟨1, _⟩ hne =>
      refine iff_of_false ?_ (fun hc => Bool.false_ne_true (h_tx.symm.trans hc))
      simp only [atom_eval]
      exact lt_asymm (hxw.trans hwt)
    | .order ⟨0, _⟩ ⟨0, _⟩ hne => exact absurd rfl hne
    | .order ⟨1, _⟩ ⟨1, _⟩ hne => exact absurd rfl hne
    | .order ⟨2, _⟩ ⟨2, _⟩ hne => exact absurd rfl hne
  · intro σ
    constructor
    · rintro ⟨x1, hx1⟩
      by_contra hne
      -- R1: the realizing witness `x1` may be interior/boundary OR strictly
      -- exterior; the boundary-restricted `hexcl` covers the cone `x ≤ x1 ≤ t`.
      -- R1 (report 01 §7): for the strictly-exterior case `¬ (x ≤ x1 ∧ x1 ≤ t)` we split by
      -- σ-zone. The interior-marked slice (`zXW3`/`zWT3`) is discharged directly by the Phase-1
      -- order-atom lemma `kvE2_sepInterior_exterior_notRealizable` (NO residue); only the
      -- exterior-marked residue is carried by the narrowed `hexclExt` (Prop-4.3 re-flatten
      -- successor).
      by_cases hcone : x ≤ x1 ∧ x1 ≤ t
      · exact hexcl w hxw hwt hptW σ (Bool.eq_false_iff.mpr hne) x1 hcone.1 hcone.2 hx1
      · by_cases hzone : nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3
        · exact kvE2_sepInterior_exterior_notRealizable M x1 w x t σ hzone hcone hx1
        · exact hexclExt w hxw hwt hptW σ (Bool.eq_false_iff.mpr hne) hzone x1 hcone hx1
    · intro hbit
      have hmem : σ ∈ kvE2_sepPos qnf := by
        simp only [kvE2_sepPos, List.mem_filter]
        exact ⟨Finset.mem_toList.mpr (Finset.mem_univ σ), hbit⟩
      -- R1 realization: every positive σ is realized at the extracted pivot
      -- `w` via the provider-discharged `hreal` — the sole interior owner σ0 (`zXW3`/`zWT3`) and
      -- the boundary positives (`zAtX3`/`zAtW3`/`zAtT3`, un-vacuated by the `kvE2_sepPosI` swap)
      -- alike. The former `exfalso` (boundary unreachable under the GLOBAL singleton `hfrag`) is
      -- retired: boundary positives are now admissible and are REALIZED, not refuted.
      exact hreal w hxw hwt hptW σ hmem

end Bimodal.Metalogic.WeakCanonical.Kamp
