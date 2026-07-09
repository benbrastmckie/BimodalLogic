# Research Report: Post-342 Revision Strategy for Task 337 (Joint Multi-Owner Disjunct `.holds` Builder)

- **Task**: 337 - build_joint_multiowner_disjunct_bracketholds_engine_for_kve2_sepdisjunct
- **Started**: 2026-07-09T00:05:00Z
- **Completed**: 2026-07-09T01:10:00Z
- **Effort**: ~1 hour (research dispatch)
- **Dependencies**: task 342 (COMPLETED — primary input), tasks 334/336/338/339/340 (landed carrier chain)
- **Sources/Inputs**:
  - Code (single source of truth for all declaration claims): `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` (7845 lines, post-342 HEAD `cbf812606`), `.../SubBracket2V.lean:633` (`k1v_sorted_realizationK`), `.../OuterGate.lean`, `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean`
  - Task 342 artifacts: `specs/342_.../summaries/02_task-342-completion-summary.md`, `specs/342_.../reports/01_rabinovich-fidelity-audit.md`
  - Task 337 artifacts: `plans/01..04`, `reports/01..07` (two `07_` files)
  - Sibling artifacts: `specs/335_.../plans/01_outer-gate-assembly.md`, `specs/333_.../summaries/01_bit-compat-carrier-redefinition-summary.md`, `specs/309_.../plans/07_offdiag-fi-chain-plan.md`, `specs/321_*` (plan/report listing), `specs/state.json` descriptions for 309/321/333/335/337/341
- **Artifacts**: `specs/337_.../reports/08_post-342-revision-strategy.md` (this file)
- **Standards**: report-format.md, status-markers.md, artifact-management.md, tasks.md, lean4.md (literature-fidelity-policy.md; 342 D1/D2/D7 citation discipline applied throughout)

## Executive Summary

- **Task 337 is UNBLOCKED post-342.** The unblocking declaration is `kvE2_sepBody_complete_holds'` (SharedWitness.lean:6158, hereafter SW:): it pins the exact remaining obligation as its `hdisj` hypothesis — the `.holds` of the GROUPED disjunct `kvE2_sepDisjunct'` over `kvE2_sepTieGroupedL/R (kvE2_sepHonestOrder' …)` — with NO `hLR` (deleted by 342; unsatisfiability certified by `kvE2_sepHonest_hLR_absurd`, SW:5730). Every prior blocker (flat-arrangement non-realizability, block-granularity, per-slot value order, hLR vacuity, strict-tie unrealizability) is dissolved by the landed 338/340/342 chain.
- **Roughly half of 337's pipeline is already landed in the file**: the engine-input bundle `kvE2_sepHonest_engineInputs` (SW:4803, plan-04 Phase 1), the engine invocation + stitched monotone witness chain `kvE2_sepHonest_witnesses` (SW:4992, plan-04 Phase 2), the generic N-slot bracket constructor `kvE2_sepBracketN_construct` (SW:5357, private, same file), and 342's Phase-8 endpoint/pivot honesty pack (`kvE2_sepEpL/PtW/EpR_eval_of_honest`, SW:7663/7724/7789). What remains open is the per-tie-class witness/point-type/segment match (see Findings §2).
- **Artifact triage**: plans 01/02/03 OBSOLETE; plan 04 SUPERSEDED-but-salvageable (its Phases 1-2 are landed assets; its Phase 3-4 target must be retargeted from the flat to the grouped disjunct). Reports 03/04/05/06/07-spawn OBSOLETE (spawn analyses and blocker verifications consumed by tasks 338/339/340); report 01 STILL-VALID (literature verdict), report 02 and report 07-hlr SUPERSEDED-but-salvageable (Rabinovich content valid; all carrier claims stale). Net over the 12 artifacts (4 plans + 8 reports): 8 obsolete, 3 superseded-but-salvageable, 1 still-valid — detailed table in Findings §1.
- **The task description is stale in five places** (target formula, hLR/FILE-SAFETY note, steps 1-2 and 4 already landed, input-lemma list, bundle names) — precise rewrite list in Findings §3.
- **Siblings**: 335 remains gated on 337 but its ⇒-soundness phase may now be dispatchable independently (all inputs landed); 321's remaining scope and 333's deliverables rest on DELETED declarations (both effectively obsoleted — recommend close/re-scope); 309 unchanged (different arm; repoint its GO-gate dependency to 335); 341 unchanged in intent but its metrics are stale and it has NO specs/ directory (confirmed).

## Context & Scope

Task 337 must deliver the completeness-side `.holds` realization for the joint multi-owner disjunct bracket of the kvE2_sep separated body. It has four plan versions and eight reports without convergence; the recurring failure mode of earlier rounds was reasoning over declarations that did not exist or had been renamed. Accordingly, **every Lean name cited in this report was verified by `grep -n` against the current `SharedWitness.lean` (7845 lines) or the named file, with line numbers given**. Task 342 (completed at `cbf812606`) rewrote the arrangement carrier: interior-restricted owner index (`kvE2_sepPosI`), tie-admitting weak orders with strict-quotient grouped disjuncts, deletion of `hLR` from all four completeness theorems, and the tie-reporting honest order with its primary completeness statement `kvE2_sepBody_complete_holds'`. This report determines how 342 changes 337's problem statement and the correct revised approach, and assesses siblings 335/321/309/333/341.

Throughout, three registers are kept separate: **(a)** what the Lean source contains today (cited with `SW:` line numbers), **(b)** what Rabinovich 2014 actually prints (per the 342 fidelity audit's PDF-page citations; the 342 D1/D2/D7 discipline is binding — tie collapse is *forced by Def 3.1 (p.4)*; *Lemma 3.2(1) states the closure without printed proof*; the k=m split (p.7) is corroboration only; anchor-anchor tie exclusion is a Lean-side `nf_eval_unique` pruning with no paper counterpart), and **(c)** what prior 337 artifacts merely asserted.

## Findings

### 1. Artifact triage (Output 1)

Every classification below was checked against the current file. "Phantom check" flags names an artifact relies on that do NOT exist today.

| Artifact | Classification | Basis (verified against SW today) |
|---|---|---|
| `plans/01_joint-disjunct-bracket-holds.md` | **OBSOLETE** | Targets the flat `kvE2_sepDisjunct … (kvE2_sepSlotsL qnf) (kvE2_sepSlotsR qnf)` with `hLR`. The fixed flatMap arrangement was refuted by its own Phase-1 blocker; `hLR` deleted by 342. Its line refs are 3 generations stale (`kvE2_sepDisjunct_extract` cited at :1865, now SW:6187). Only its literature framing survives — via report 01, not the plan. |
| `plans/02_model-order-merge-bracket-holds.md` | **OBSOLETE** | Targets `.holds` for the strict `kvE2_sepModelOrder` arrangement plus a `kvE2_sepBody` carrier rewire. `kvE2_sepModelOrder` still exists (SW:1476) but the strict-tag route was established not-honestly-provable (report 02 / task 334 finding), the carrier rewire landed differently (task 338), and `hLR` is gone. Phase 1 blocked, never resumed. |
| `plans/03_rank-ordered-coincidence-holds-builder.md` | **OBSOLETE** (one landed asset preserved) | Built on task 338's block-rank carrier; Phase 2 blocked on the block-vs-merged granularity mismatch, dissolved by task 340's per-slot index, then 342. Its Phase-1 asset `kvE2_sepCoincidentOrder_mem_arr'` LANDED and survives (SW:3286, restated hLR-free by 342 Phase 5) — the asset is live; the plan is not. |
| `plans/04_joint-disjunct-holds-codesign.md` | **SUPERSEDED-but-salvageable** | Phases 1-2 landed and remain the banked pipeline front end: `kvE2_sepHonest_engineInputs` (SW:4803), `kvE2_sepHonest_witnesses` (SW:4992), plus the Phase-3 structural core `kvE2_sepBracketN_construct` (SW:5357). Phase 3 was blocked by the `hLR` inconsistency — RESOLVED by 342. NOT salvageable as-is: its Phase 3/4 target (flat `kvE2_sepDisjunct` over `kvE2_sepSlotsLOf/ROf wo`, hypotheses including `hLR`, corollary via the old `kvE2_sepBody_complete_holds`) must be retargeted to the grouped disjunct of `kvE2_sepBody_complete_holds'` (SW:6158). Its Phase-3 "SECONDARY design caution" (same-value slots make one-point-per-SLOT unrealizable) is precisely what 342's tie classes fix — the caution is now the design, not a risk. Line refs stale throughout (file grew 4174 → 7845). |
| `reports/01_rabinovich-witness-ordering-faithfulness.md` | **STILL-VALID** (with citation caveat) | Its two verdicts — the witness is one strict model-order chain (Def 3.1, p.4); enumeration lives at the formula level, never `List.mem_permutations` at `.holds` — remain binding and are embodied in the current architecture (`kvE2_sepArr'` SW:1776; `IntervalPattern.holds` untouched). Caveat: it cites the `.md` paraphrase; under 342's D6 finding the `.md` is unusable for load-bearing claims — any reuse must re-cite to PDF pages per the 342 audit. |
| `reports/02_coincident-order-and-weakorder-scope.md` | **SUPERSEDED-but-salvageable** | The Rabinovich findings survive (coincidence is a first-class disjunct; no genericity assumption). ALL carrier claims are stale: "kvE2_sepBody discards `_wo`" and every SW line ref describe the pre-338 file. Salvage = the literature sections only. |
| `reports/03_spawn-analysis-weakorder-enrichment.md` | **OBSOLETE** | Spawn analysis whose proposal became task 338 (completed). Fully consumed; historical record. |
| `reports/04_honest-case-blocker-verification.md` | **OBSOLETE** | Adversarial verification that the pre-338 block-concatenation blocker was genuine. Correct at the time; the carrier it examined no longer exists. Consumed by 338→340. |
| `reports/05_spawn-analysis-pointlevel-slot-merge.md` | **OBSOLETE** | Spawn analysis that led to task 339/340. Consumed. |
| `reports/06_residual-granularity-verdict.md` | **OBSOLETE** | Verdict "task 340 required" — 340 landed (per-slot value-faithful index, `kvE2_sepSlotHonestGIdx` SW:3799 and successors). Consumed. |
| `reports/07_hlr-inconsistency-coincidence-merge.md` | **SUPERSEDED-but-salvageable** | The direct design input to task 342; its §4 target shape became `kvE2_sepBody_complete_holds'` (SW:6146 docstring says "report 07 §4 shape"). Its hLR root-cause analysis remains the authoritative record. Two caveats: (i) its Lemma 3.2(1) mechanism claim must now be read through 342's D1 correction — the mechanism is *forced by Def 3.1 (p.4)*; *Lemma 3.2(1) states the closure without printed proof* — never "per the proof of Lemma 3.2(1)"; (ii) everything it proposed is now IMPLEMENTED, so it is background, not a spec. |
| `reports/07_spawn-analysis-perslot-global-index.md` | **OBSOLETE** | Spawn analysis that created task 340. Consumed. |

Count: **8 OBSOLETE** (plans 01/02/03; reports 03/04/05/06/07-spawn), **3 SUPERSEDED-but-salvageable** (plan 04; reports 02, 07-hlr), **1 STILL-VALID** (report 01).

### 2. Concrete revised approach (Output 2)

#### 2.1 The exact target

`kvE2_sepBody_complete_holds'` (SW:6158-6170) is proven and takes `hdisj` as its single delegated hypothesis. 337 must discharge exactly that hypothesis from honest inputs. Recommended new theorem (in `SharedWitness.lean`, placed AFTER the Phase-8 honesty pack, i.e. after SW:7789, since it consumes those lemmas):

```
theorem kvE2_sepDisjunct'_holds_of_honest {sig : MonadicSignature}
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
        (kvE2_sepTieGroupedR (kvE2_sepHonestOrder' qnf M w x t h))).2.holds M atomMap x t
```

The `hcb`/`hck` char-semantics hypotheses are copied verbatim from the Phase-8 pack (SW:7669-7672) — they are the abstract `nfPred_correct` shape and will be instantiable at the standard `nf_depth0_char_formula` instantiation downstream. Corollary (the object task 335 consumes):

```
theorem kvE2_sepBody_holds_of_honest … (hg : kvE2_sepGate qnf) … :
    (kvE2_sepBody charBase charK qnf).holds M atomMap x t
```
proved as `kvE2_sepBody_complete_holds' … (kvE2_sepDisjunct'_holds_of_honest …)` (SW:6158).

`.2.holds` for this `Σ n, VecEA2 n` decomposes as the triple ⟨`kvE2_sepEpL` eval at `x`, `kvE2_sepEpR` eval at `t`, bracket `.holds`⟩ — exactly as `kvE2_sepDisjunct_extract` destructures it (`obtain ⟨hepL, hepR, hbr⟩ := h`, SW:6207).

#### 2.2 Verified lemma inventory (all names confirmed to exist; line = declaration line in SharedWitness.lean unless noted)

Carrier/target layer (342):
- `kvE2_sepPosI` :211 (+ `_mem` :217, `_subset` :224, `_zone` :230, `_nodup` :238)
- `kvE2_sepTieGroupedL` :2054 / `kvE2_sepTieGroupedR` :2059 (+ `_flatten` :2064/:2069, `_ne_nil` :2074/:2079, `_of_nodup` :2084/:2090); run structure `kvE2_sepTieRuns` :1971 (+ `_shape` :1980, `_flatten` :1991, `_ne_nil` :2008, `_of_nodup` :2031)
- `kvE2_sepClassType` :2109 (+ `_eval_iff` :2116, `_eval_mem` :2133, `_singleton_eval` :2144); `kvE2_sepSegsG` :2167; `kvE2_sepDisjunct'` :2204
- `kvE2_sepHonestOrder'` :5966 (+ `_mem_orderTypes` :5977, `_anchorDistinct` :5999, `_tieRead` :6042, `_mem_arr'` :6112)
- `kvE2_sepBody_complete_holds'` :6158 (PRIMARY hand-off); singleton variant `kvE2_sepBody_complete_holds` :5697; `kvE2_sepBody_holds_iff` :2372; guard `kvE2_sepHonest_hLR_absurd` :5730

Honest value layer (340/342):
- `kvE2_sepSlotValue` :3528 (per-slot honest value; anchors = `kvE2_sepAnchorVal` :3337 with `_spec` :3345); value specs `kvE2_sepSlotValue_lX1` :3548, `_rX1` :3554, `_lXU_spec` :3561, `_lUW_spec` :3577, `_rWX1_spec` :3593, `_rX1T_spec` :3609, `_lWT_spec` :3625, `_rXW_spec` :3642; `kvE2_sepSlotValue_region_rank_mono` :3662; `kvE2_sepSlotValue_anchorSlot` :5897; `kvE2_sepSlotValue_baseType_spec` :5909
- Tie-reporting payload: `kvE2_sepSlotV` :5803 (+ `_get` :5810), `kvE2_sepSlotHonestVIdx` :5823 (+ `_mono` :5834, **payload law `_eq_iff` :5857** — equal indices exactly where honest values coincide), `kvE2_sepConsistentBlock_honestV` :5879

Discharge/honesty packs (342 Phase 8):
- `kvE2_sepEpL_eval_of_honest` :7663, `kvE2_sepPtW_eval_of_honest` :7724, `kvE2_sepEpR_eval_of_honest` :7789 (endpoints + pivot — plan-04 Phase 4's endpoint obligation is LANDED)
- `kvE2_sepProjFresh_eval` :6992 (public); `kvE2_sepClosedLeafAt_discharge` :3142, `_discharge_honest` :3360, `kvE2_sepTieRead_of_discharge` :3191 (foreign-base CLOSED-key reads for tie members — F5-compliant)

Banked 337 pipeline (plan-04 Phases 1-2 + structural core):
- `kvE2_sepHonest_engineInputs` :4803; `kvE2_sepHonest_witnesses` :4992 (both consume `k1v_sorted_realizationK`, SubBracket2V.lean:633 — verified present)
- `kvE2_sepBracketN_construct` :5357 (**private**, but usable: 337 adds code to the SAME file below it) — takes `usL/usR` witness lists, length equalities, combined strict sortedness, range in `(x,t)`, per-index point-type evals, `ptW` at the pivot, and the three segment-gap families in `IntervalPattern.holds_eq_succ` shapes, and produces `(kvE2_sepBracketN lL ptW lR segs).holds`
- `kvE2_sepBracketN_holds_congr` :5450 (private), `kvE2_sepDisjunct'_map_singleton_iff` :5531, `kvE2_sepDisjunct'_singleton_iff` :5587

Soundness-side inputs (unchanged, verified): `kvE2_sepDisjunct_extract` :6187, `kvE2_sepBody_extract` :6348, `kvE2_sepArr'_sound` :6938, `kvE2_sepBody_complete` :3235 (restated hLR-free by 342), `kvE2_sepGate_holds_of_honest` :2666. Private per-owner bundles `kvE2_sepHonestBundleL` :2739 / `kvE2_sepHonestBundleR` :2791 still exist (private).

#### 2.3 Proof route (recommended: value-direct per-class witnesses)

The tie classes of `kvE2_sepTieGroupedL/R (kvE2_sepHonestOrder' …)` are maximal runs of slots with EQUAL `kvE2_sepSlotHonestVIdx`, and the payload law `kvE2_sepSlotHonestVIdx_eq_iff` (:5857) converts equal indices to equal honest `kvE2_sepSlotValue`s. So each tie class has one well-defined honest value, and the natural bracket witness list is `usL/usR := classes.map (class-head slot value)` (heads exist by `kvE2_sepTieRuns_ne_nil` :2008 / `kvE2_sepTieGroupedL_ne_nil` :2074). This route feeds `kvE2_sepBracketN_construct` directly and uses 342's Phase-9 machinery as designed. The banked engine route (`kvE2_sepHonest_witnesses`) remains available as a fallback, but its stitched chain enumerates anchors + per-gap engine realizer points, which is a different multiset from the per-class values — aligning it to the grouped classes is extra "halign" work the value-direct route avoids.

Genuinely open obligations (this is the actual remaining task; none of these exist in the file today):

- **O1 — class witness order and range.** Strict cross-class monotonicity of the combined list `usL ++ w :: usR` (cross-class strictness from `kvE2_sepSlotHonestVIdx_mono` :5834 + the run structure; left-class values `< w <` right-class values and everything in `(x,t)` from the per-slot value specs :3548-3661). Watch items the planner must size: the cross-region slots (`.rXW` in the LEFT list of a right-interior owner, `.lWT` in the RIGHT list of a left-interior owner — see `kvE2_sepSlotValue_rXW_spec` :3642 / `_lWT_spec` :3625 for the exact realized bounds) and the base-value-equals-anchor collisions, which are now legal ties (non-singleton classes) rather than obstructions.
- **O2 — class point types.** `(kvE2_sepClassType c).eval_at` at the class value, via `kvE2_sepClassType_eval_iff` :2116 reducing to each member: base slots by `kvE2_sepSlotValue_baseType_spec` :5909 + `hcb`; anchor slots by `kvE2_sepSlotValue_anchorSlot` :5897 + `kvE2_sepAnchorVal_spec` :3345 + `hck` and the fresh-projection content `kvE2_sepProjFresh_eval` :6992; foreign-base-at-anchor members by `kvE2_sepClosedLeafAt_discharge_honest` :3360 (F5: CLOSED key only). Pivot from `kvE2_sepPtW_eval_of_honest` :7724.
- **O3 — segments (the largest open piece).** `kvE2_sepSegsG` (:2167) dispatches grouped cut `i` to the flat per-cut conjunctions `kvE2_sepSegLAt`/`kvE2_sepSegRAt` (:1156/:1163) over `kvE2_sepSegLForSub'`/`kvE2_sepSegRForSub'` (:6805/:6884). The obligation: for every `y` strictly between consecutive class witnesses (plus the `x`-, `w`-, and `t`-boundary gaps), every owner's segment contribution evaluates at `y`. **No banked completeness-direction segment-eval lemma exists** — `kvE2_sepSegLForSub'_at_sound` :6827 / `kvE2_sepSegRForSub'_at_sound` :6908 are definitional shape lemmas, and `kvE2_sepSegForm_excludes` :6543 is the exclusion reading, not an honest-eval discharge. This needs a new "honest segment evaluation" lemma family reading the owners' universal (β) layer out of `h` via `kvE2_sepSegForm` :184 + `hcb`, likely following/generalizing the private honest bundles :2739/:2791. Expect this to dominate the line budget.
- **O4 — assembly arithmetic.** Length equalities (`(gL.map kvE2_sepClassType).length = usL.length` by construction) and the grouped-cut/flat-cut reindexing (`kvE2_sepTieGroupedL_flatten` :2064, `(gL.take i).flatten.length` arithmetic inside `kvE2_sepSegsG`), then the final triple with the Phase-8 endpoints.

Faithfulness constraints unchanged and all machine-anchored: strict Def-3.1 bracket only (one slot per tie class — ties are index data, `IntervalPattern.holds` untouched; forced by Def 3.1 (p.4), Lemma 3.2(1) stating the closure without printed proof); F5 CLOSED-key reads for tie discharges; LITMUS (NavigatedSpine.lean:437) — all witness/segment bounds from the bracket range `x`/`w`/`t` and per-slot value specs, never an `x1 < e_i` owner-chain literal; baseline caps 107 `kvE_sub2_` open-key markers and 73 `x1 <` occurrences (342 exit-gate numbers).

### 3. Blocked-status verdict (Output 3)

**Task 337's recorded status at dispatch time was `[BLOCKED]`. This research finds the blocking conditions are now dissolved.** The verdict rests on independently verified declarations, all present and sorry-free with axioms `{propext, Classical.choice, Quot.sound}` per 342's exit gate: `kvE2_sepBody_complete_holds'` (SW:6158) pins the exact residual obligation as its `hdisj` hypothesis; `kvE2_sepHonestOrder'_mem_arr'` (SW:6112) discharges the carrier membership 337 no longer needs to prove; the Phase-8 honesty pack (SW:7663/7724/7789) discharges the old step (4) outright; and `kvE2_sepHonest_hLR_absurd` (SW:5730) certifies that the old `hLR` blocker was unsatisfiable rather than merely undischarged. What remains (O1-O4 above) is genuine new proof construction, not a missing prerequisite; no new spawn is needed. Recommended status move: [BLOCKED] -> [RESEARCHED], and thence to /plan.

The task DESCRIPTION must be rewritten in these five places:

1. **Target formula**: replace `(kvE2_sepDisjunct charBase charK qnf (kvE2_sepSlotsL qnf) (kvE2_sepSlotsR qnf)).2.holds` with the grouped target of §2.1 (`kvE2_sepDisjunct'` over `kvE2_sepTieGroupedL/R (kvE2_sepHonestOrder' …)`); deliverable = `hdisj` of `kvE2_sepBody_complete_holds'` plus the body corollary.
2. **FILE-SAFETY NOTE**: delete entirely. The "hLR-generalized `kvE2_sepBody_complete` signature" it instructs verifying is gone — 342 DELETED `hLR` from all four completeness theorems (`kvE2_sepHonest_hLR_absurd` :5730 certifies the hypothesis was unsatisfiable; exactly one `(hLR :` binder remains file-wide, inside the guard).
3. **Steps (1)-(2)**: mark LANDED (`kvE2_sepHonest_engineInputs` :4803, `kvE2_sepHonest_witnesses` :4992). **Step (4)**: mark LANDED (Phase-8 pack). Step (3) is the open core, restated over tie classes per §2.3.
4. **Verified-INPUT list**: `kvE2_sepBody_complete` was RESTATED by 342 (hLR-free, :3235); add the 342 inputs (`kvE2_sepBody_complete_holds'`, `kvE2_sepHonestOrder'` family, `kvE2_sepClassType_eval_iff`, tie-grouping lemmas, Phase-8 pack, `kvE2_sepProjFresh_eval`, `kvE2_sepSlotHonestVIdx_eq_iff`).
5. **Bundle naming**: `kvE2_sepHonestBundleL/R` are private and no longer the interface — the honest inputs flow through `kvE2_sepSlotValue`/`kvE2_sepAnchorVal` specs and the banked Phase-1/2 lemmas.

### 4. Sibling-task forward assessment (Output 4)

| Task | 342 effect | Evidence | Minimal revision |
|---|---|---|---|
| **335** outer gate assembly (blocked) | **PARTIALLY UNBLOCKS; still gated on 337 for ⇐** | `OuterGate.lean` Phase 1 landed (`bracketEndChar_kvE2` + `_two_eq`); its header R-A note already describes the 342 interior-restricted carrier. Phases 2-4 blocker text still cites the stale FLAT target `(… (kvE2_sepSlotsL qnf) (kvE2_sepSlotsR qnf)).2.holds`. ⇒-soundness inputs are ALL landed today: `kvE2_sepBody_extract` :6348, `kvE2_sepDisjunct_extract` :6187, `kvE2_sepArr'_sound` :6938. | Retarget Phase 3 (⇐) to consume 337's `kvE2_sepBody_holds_of_honest` via `kvE2_sepBody_complete_holds'`; re-audit Phase 2 (⇒) for dispatch BEFORE 337 completes — its blocker note conflates the two directions, and the soundness direction does not need 337's builder. |
| **321** corrected k2 carrier / F4 (partial) | **OBSOLETES remaining scope** | The fragment-scope residue rests on deleted declarations: `kvE2_sepSingleton_coverage_left` / `kvE2_sepBody_singleton_complete_left` — grep over `Theories/` returns NOTHING, and SharedWitness has 0 code sorries (342 exit gate). The additive-filter layer they lived in was deleted by task 334 (`kvE2_sepArrL/R` replaced by `kvE2_sepArr'`, SW:1774 docstring). The multi-positive completeness it deferred is now the 334→342 carrier + 337's builder. | Close or re-scope to ONLY the surviving deliverable — the F4 Z adversarial GO/NO-GO verdict record for 309 — explicitly consuming the 335 gate; recommend `[ABANDONED]`-with-successor or fold the verdict phase into 335. Requires user review (terminal-state change). |
| **309** offdiag two-anchor fi chain (blocked) | **LEAVES UNCHANGED** | Different arm and files: KampPrior.lean:351/:354 sorries verified still present; plan v7 Phases 1-13.35 done, 13.4/14 `[NOT STARTED]` waiting on a corrected-k2-carrier GO. 342 touched only SharedWitness (+ a reverted OuterGate doc edit). | One-line repoint: Phase 13.4's dispatch condition should reference the 335 assembled-gate deliverable (which now embodies the 334/342 carrier) instead of task 321's retired v6/v7 GO gate. |
| **333** kvE2_sepArr bit-compat carrier redefinition (partial) | **OBSOLETES** | Deliverable (1) redefines `kvE2_sepArrL/R` — deleted (only comment mentions remain: SW:1041/:1453/:1774/:2335/:5336). Deliverable (2) discharges the two 321 sorries — deleted (see 321 row). The bit-compatibility GOAL is realized by `kvE2_sepDisjValid` :1767 / `kvE2_sepArr'` :1776 + 342's grouped validity conjuncts. Its four compat leaves DID land and survive re-hosted as strict-disjunct validators (`kvE2_sepSlotChi` :919, `kvE2_sepFreshZoneBefore` :936, `kvE2_sepFreshZoneAfter` :945, `kvE2_sepCompat` :960; survival audit at SW:6847-6859). | Recommend `[ABANDONED]` (deliverables consumed or superseded) after confirming its staged `handoffs/phase1-switch-and-repairs.patch` contains nothing left to salvage (its content targets the deleted filter). Requires user review. |
| **341** structural refactor of the carrier layer (not_started) | **LEAVES UNCHANGED in intent; description metrics stale** | CONFIRMED: NO `specs/341_*` directory exists (only the state.json entry). Description says SharedWitness ~3540 lines; it is 7845 today. 342 added whole new seams the split should respect: tie-grouping/`kvE2_ordRank` kernel (~SW:1900-2200), honest value/order layer (~3300-4400), engine-inputs/witness layer (~4400-5100), grouped-disjunct + completeness layer (~5300-6200), honesty packs (~6948-7810). | When eventually planned: refresh line counts and the module-seam list; keep the sequencing constraint (run only after 337 and 335 land) — it is still correct and now concrete. |

## Decisions

- **Recommend the value-direct per-class witness route** (§2.3) over re-aligning the banked engine chain: it consumes 342's Phase-9 payload law (`kvE2_sepSlotHonestVIdx_eq_iff` :5857) exactly as designed and avoids the deferred "halign" alignment debt. The engine route stays banked as fallback; nothing is deleted.
- **Place the new builder after SW:7789** (below the Phase-8 pack) so all honesty lemmas and the private `kvE2_sepBracketN_construct` are in scope; the task remains strictly ADDITIVE to `SharedWitness.lean`.
- **Do not spawn any new prerequisite task** — all prerequisites are landed; O1-O4 are 337's own proof work.
- **Plan version 05 should be authored fresh** against §2 (not by patching plan 04): the target statement, hypothesis package, and phase decomposition all change; only plan 04's landed-asset inventory carries over.

## Recommendations

1. **/revise or /plan 337 (next step, owner: planner)** — produce `plans/05_*` implementing §2: Phase A = O1 (class witness function + order/range), Phase B = O2 (class point types), Phase C = O3 (honest segment evaluation — size this largest, possibly two phases: the new segment-eval lemma family, then the gap discharge), Phase D = O4 + endpoints + the two public theorems + axiom/faithfulness gate. Rewrite the task description per Findings §3 in the same dispatch.
2. **335 (owner: orchestrator)** — after 337's plan lands, re-audit whether its ⇒-soundness phase can dispatch immediately (inputs verified landed); update its Phase 2-4 blocker notes to the grouped target.
3. **321 and 333 (owner: user review)** — both have remaining scopes grounded in deleted declarations; surface for close/abandon decisions rather than further dispatches.
4. **309 (owner: reviser, one line)** — repoint Phase 13.4's gate dependency to 335's deliverable.
5. **341 (owner: whoever plans it, later)** — refresh metrics/seams; no action now.

## Risks & Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| O3 (honest segment evaluation) exceeds one dispatch | H | Size it as its own phase(s); land the segment-eval lemma family as standalone green lemmas before the gap discharge; never a `sorry` or vacuous placeholder. |
| Cross-region slot values (`.rXW`/`.lWT`) break the naive "left values < w < right values" ordering claim | M | The exact realized bounds are in `kvE2_sepSlotValue_rXW_spec` :3642 / `_lWT_spec` :3625 — the planner must read these two signatures (via `lean_hover_info`) before fixing O1's statement; if a left-list slot value can honestly exceed `w`, the class-order argument must ride `kvE2_sepSlotHonestVIdx_mono` + the merged-list sortedness (`kvE2_sepSlotsLOf_honest_valueSorted` :4157) rather than zone bounds. |
| Reusing stale line numbers from plans 01-04 | M | This report's inventory (§2.2) is the refreshed reference; every implementation phase should still open with a `grep -n` re-confirmation (the file will grow as phases land). |
| Citation drift on Lemma 3.2(1) | L | Use only the sanctioned D1 phrasing (forced by Def 3.1 (p.4); Lemma 3.2(1) states the closure without printed proof; k=m split (p.7) + Def 7.5 (p.13) corroboration; `kvE2_sepAnchorDistinct` is a Lean-side `nf_eval_unique` pruning with no paper counterpart). |

## Appendix

- Current HEAD at research time: `cbf812606` (task 342 orchestration complete); SharedWitness.lean = 7845 lines, 0 code sorries, axiom set `{propext, Classical.choice, Quot.sound}` on all public 342 deliverables (342 exit-gate record).
- Task 337 artifact census: 4 plans (`01..04`), 8 reports (`01..07` with two `07_` files); this report is `08`.
- Sibling spec directories verified: `specs/309_*`, `specs/321_*`, `specs/333_*`, `specs/335_*` exist; `specs/341_*` does NOT exist.
- Literature source of record: `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf` (PDF pages; the companion `.md` is not citable for load-bearing claims per 342 audit D6).
