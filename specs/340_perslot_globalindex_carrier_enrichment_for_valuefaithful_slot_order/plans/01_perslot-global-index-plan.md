# Implementation Plan: Per-slot global-index carrier enrichment for value-faithful slot order

- **Task**: 340 - Per-slot global-index carrier enrichment for value-faithful slot order
- **Status**: [IMPLEMENTING]
- **Effort**: ~16-22 hours (6 phases)
- **Dependencies**: 339 (COMPLETED), 338 (COMPLETED), 336, 334 — carrier surface built by these tasks is read and extended, not re-derived
- **Research Inputs**: reports/01_perslot-global-index-research.md (blocker analysis, verified via report 06 three `lean_run_code` experiments)
- **Artifacts**: plans/01_perslot-global-index-plan.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/lean4.md
  - .claude/context/contracts/anti-analysis.md (H2)
  - .claude/context/contracts/reference-grounding.md (H3)
- **Type**: lean4
- **Mode**: --hard (foundational faithful-transcription, terminal carrier layer)

## Overview

Task 339 sorts the joint cross-owner slot lists (`kvE2_sepSlotsLOf/ROf`) with a 2-level key
(`kvE2_sepSlotMergeLe`, SW:880-885): intra-owner REGION rank primary, per-owner merged-chain rank
secondary. Report 06 proved (three `lean_run_code` experiments) this key is unconditionally
value-infaithful for cross-region interleaving: an owner σ's `lUW` witness `u` is constrained only
by `x1_σ < u < w` (`kvE2_sepHonestBundleL`, SW:1415-1419) and may honestly land BELOW another
owner τ's anchor `b = x1_τ` (the `a < u' < b` case). Because region rank is primary and static, the
merge always places τ's region-1 anchor before σ's region-2 `lUW` regardless of owner-rank choice
(Experiment C rank-independence), making the monotone witness 337's `.holds` builder needs
`omega`-unsatisfiable.

This task replaces the derived 2-level key with a single PER-SLOT GLOBAL INDEX reflecting model
value order — a total order on the full slot multiset (not a region×owner product), a linear
extension of each owner's own region partial order. This closes both the above-anchor case (report
04, already handled) and the below-anchor case (report 06, newly proved unhandled), establishing
340 as the TERMINAL carrier layer: no fifth carrier layer is needed. Definition of done:
sorry-free, axiom-clean (`{propext, Classical.choice, Quot.sound}` only), full `lake build` green,
F1-F7 invariants preserved (F5 zone-key non-conflation; LITMUS at NavigatedSpine.lean — no
`x1 < e_i` literal), no load-bearing 334/336/338/339 result destroyed.

**Terminality gate**: Phase 1 is a design gate (analysis-permitted, mirroring 339's Phase 1) that
must PROVE ON PAPER, before any Lean edit, that the chosen per-slot index representation reproduces
the exact honest value order for the `a < u' < b` case and is faithful to Rabinovich Def 3.1's
single global chain. Implementation phases (2-6) must not begin until the gate passes, and each
produces Lean code ending at a compiling (green), sorry-tracked checkpoint.

### Research Integration

- reports/01_perslot-global-index-research.md — integrated in plan version 1 (2026-07-08). Supplies
  the verified blocker (region-primary key omega-refutable for `a < u' < b`), the exact SW change
  map (report 06 §5), the must-preserve list, and the terminality requirement.

### Preserved Assets

The following work is complete and must not regress (verified: on `main` at commit 1ae7e9bf1):

| Component | File (SW = SharedWitness.lean) | Status | Verified |
|-----------|--------------------------------|--------|----------|
| `mergeSort_perm` membership route `kvE2_sepSlotsLOf_mem` / `ROf_mem` | SW:954-971 | [COMPLETED] (339) | 2026-07-08 |
| Same-owner `rank<rank ⟹ index<index` (`kvE2_sep_index_lt_of_rank_lt` via `kvE2_sepSlotLe`) | SW:2015-2029, 455-461 | [COMPLETED] (334) | 2026-07-08 |
| No-collapse: `kvE2_sepModelOrder`, `kvE2_sepCoincidentOrder` proven members of `kvE2_sepArr'` | SW:846-851, 1804-1832 | [COMPLETED] (334/337-P1) | 2026-07-08 |
| Task 337 Phase-1 `kvE2_sepCoincidentOrder_mem_arr'` | SW:1804-1832 | [COMPLETED] (337-P1) | 2026-07-08 |
| Structural enumeration lemmas `kvE2_sepOrderTypes_mem_aux` / `_owners_aux` / `_owners` / `kvE2_sepMem_orderOwners` | SW:810-945 | [COMPLETED] (338) | 2026-07-08 |
| Honest extractors `kvE2_sepHonestBundleL/R`, `kvE_subBracket2_complete_extract` (do-not-edit extractor) | SW:1408-1441, 1460+ | [COMPLETED] (334) | 2026-07-08 |
| F5 zone-key discipline: `kvE2_sepClosedLeafStub`, `kvE2_sepDisjValidOwner` (open→OPEN, coincident→CLOSED) | SW:759-792 | [COMPLETED] (336) | 2026-07-08 |

These lemmas are re-proved (their statements largely preserved) after the carrier type change, but
their FACTS must survive. The permutation-based membership route and the same-owner monotonicity
property are the two load-bearing invariants the ⇒-extraction (`kvE2_sepDisjunct_extract`, SW:2086)
consumes; they must hold verbatim under the new key.

### Source-to-Implementation Mapping (H3, Tier: literature — faithful transcription)

| Load-bearing decision | Source | Implementation site |
|-----------------------|--------|---------------------|
| Single global chain over the union of points (not region×owner product) | Rabinovich Def 3.1 (PDF p.4); Lemma 3.2(1), md:77 | New `kvE2_sepSlotMergeLe` single-level compare; enriched `KvE2SepWeakOrder` |
| Index must be a linear extension of each owner's region order (`lXU<lX1<lUW` left; mirror right) | Lemma 3.2(1) "one consistent global order over the union", md:77; region structure Def 3.1 exterior/interior β, md:66-74 | New consistency conjunct in `kvE2_sepDisjValid`; preserved `kvE2_sepSlotRank` (SW:245-253) region ordering |
| `a < u' < b` (σ's `lUW` below τ's anchor) must be expressible and admitted | report 06 Experiments A/B/C; honest bound `x1_σ < u < w` only (`kvE2_sepHonestBundleL`, SW:1415-1419) | Enriched enumeration ranges over order-consistent global interleavings; Phase 1 gate proof |
| Completeness witness supplies index consistent with MODEL value order (not just any linear extension) | Lemma 3.2(1) ⇐ honest arrangement, md:77 | Extended `kvE2_sepHonestBundleL/R` yielding cross-owner value order; `kvE2_sepCoincidentOrder`/`kvE2_sepBody_complete` |
| No relative-position literal / open-closed non-conflation | LITMUS (NavigatedSpine.lean); F4/F5 | Index is abstract ℕ, reads no zone bit; validity keeps CLOSED-only coincidence read |

## Postmortem Constraints

Binding rules for all implementation dispatches. Derived from report 06's verified findings, 339's
residual-granularity note, and known carrier-refactor failure modes.

**Do NOT**:
- Reintroduce or retain a region-rank-PRIMARY (or any 2-level region×owner lex) merge key. Report
  06 Experiment C proved it rank-independent-insufficient for `a < u' < b`; the whole task exists to
  remove it.
- Encode the cross-owner order as per-OWNER-only rank data. Per-owner ranks cannot express
  "σ's region-2 slot below τ's region-1 slot"; the enrichment must carry per-SLOT (per region-rank)
  index data.
- Expose any `x1 < e_i` relative-position literal (LITMUS, F4). The global index is an abstract ℕ
  read structurally off the arrangement, never a model-order comparison of a fresh anchor against a
  slot index.
- Conflate OPEN and CLOSED zone keys (F5). Strict placements read OPEN `zXU`/`zUW`; the coincidence
  tie reads the CLOSED `zAtX1L/R` self-zone bit only. The consistency conjunct reads NO zone bit.
- Attempt the type change + full re-prove as one monolithic edit that leaves the file RED for an
  entire dispatch (the task-305 unbounded-attempt failure mode). Land the behavior-preserving type
  migration (Phase 2) green FIRST, then activate the new semantics incrementally (Phases 3-6).
- Use `simp`/`omega`/`aesop` to bypass a Def 3.1 / Lemma 3.2(1) step the literature handles
  explicitly (lean4.md Literature Fidelity).
- Introduce any vacuous definition (`def X := True`, `theorem X := trivial`) to force a green build
  (lean4.md Vacuous Definitions).

**MUST preserve**:
- The `mergeSort_perm` membership route: `kvE2_sepSlotsLOf_mem` / `kvE2_sepSlotsROf_mem` (SW:954-971)
  must re-prove via `List.mergeSort_perm` + `kvE2_sepMem_orderOwners`, unchanged in shape.
- The same-owner `rank<rank ⟹ index<index` property the ⇒-extraction relies on
  (`kvE2_sep_index_lt_of_rank_lt`, SW:2015-2029; `hpairL/hpairR` obligations).
- The no-collapse property: `kvE2_sepModelOrder` AND `kvE2_sepCoincidentOrder` remain proven members
  of `kvE2_sepArr'`.
- Task 337 Phase-1's `kvE2_sepCoincidentOrder_mem_arr'` (SW:1804).
- Every completed 334/336/338/339 result (Preserved Assets table).

**Design decisions are SETTLED** (do not re-open without a concrete Lean counterexample):
- The key is a single per-slot global index; region-primary lex is dropped. (report 06 §5)
- The index is a linear extension of each owner's region partial order. (Lemma 3.2(1), md:77)
- 340 is the TERMINAL carrier layer; no fifth carrier layer is planned. (report 06 §5, gated by
  Phase 1)
- The task stays confined to `SharedWitness.lean`; 337's `.holds` builder is out of scope.

## Goals & Non-Goals

- **Goals**:
  - Replace the 2-level `kvE2_sepSlotMergeLe` with a single-level per-slot global-index compare.
  - Enrich `KvE2SepWeakOrder` / `kvE2_sepOrderTypes` to carry a per-slot global index; add the
    linear-extension consistency conjunct to `kvE2_sepDisjValid`.
  - Make the enumeration contain, and validity admit, the `a < u' < b` cross-region interleaving.
  - Thread the honest bundle's cross-owner value order into the completeness index supply.
  - Preserve every load-bearing 334/336/338/339 fact; keep sorry-free and axiom-clean.
- **Non-Goals**:
  - Building 337's monotone `.holds` witness sequence (`kvE2_sepBody_holds_iff.mpr` construction) —
    that is task 337, unblocked by this task's carrier.
  - Any change outside `SharedWitness.lean`.
  - Any new axiom, `sorry`, or vacuous placeholder.

## Risks & Mitigations

- **Risk**: Carrier type change ripples through ~25 lemmas, leaving the file RED across a whole
  dispatch (task-305 failure mode). **Mitigation**: Phase 2 lands a behavior-PRESERVING type
  migration (index field added, merge still reproduces 339's order) so the whole file is green and
  sorry-free before any semantic change; Phases 3-6 activate new behavior incrementally, each green.
- **Risk**: The chosen index representation makes `DecidableEq` / `Nodup` / `decide` intractable
  (e.g. a function-valued index field). **Mitigation**: Phase 1 gate must pick a finite,
  `DecidableEq` representation (a per-owner monotone assignment over the ≤3 region ranks, encoded as
  concrete data, not `KvE2SepSlot → ℕ`); the gate deliverable includes a compiling scratch `example`
  confirming `decide`-ability and the `a < u' < b` distinguishability.
- **Risk**: `hpairL/hpairR` (same-owner region-order pairwise) fails under the new sort.
  **Mitigation**: the consistency conjunct forces the index to extend region order, so `mergeSort`
  restricted to same-owner slots respects `kvE2_sepSlotRank`; re-prove via the linear-extension
  property in Phase 3.
- **Risk**: Phase 5 (honest-bundle cross-owner order) requires genuine model reasoning and may
  exceed one agent run. **Mitigation**: pre-declared sub-phase split 5.1 (extend bundles L/R, green)
  / 5.2 (thread into completeness/coincident/model, green); reuse the do-not-edit extractor
  `kvE_subBracket2_complete_extract`, no new model reasoning beyond ordering the already-extracted
  witnesses.
- **Risk**: An axiom leak (`sorryAx`) hides behind a `decide`. **Mitigation**: Phase 6 runs
  `lean_verify` on every touched top-level theorem and asserts the axiom set equals
  `{propext, Classical.choice, Quot.sound}`.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |

Fully sequential: each phase mutates the shared carrier surface the next phase depends on, so no two
phases can run in parallel. (Phase 5's internal sub-phases 5.1→5.2 are likewise sequential.)

### Phase 1: Design gate — value-faithfulness + terminality proof (analysis) [COMPLETED]

**GATE PASSED** (2026-07-08, scratch validation via `lean_run_code`, all checks green).

Chosen representation: per-owner payload `ℕ` → `ℕ × ℕ × ℕ` = `(i₀,i₁,i₂)` global indices of the
owner's region-rank-0/1/2 slots. Carrier `KvE2SepWeakOrder = List (NormalForm sig 1 4 ×
KvE2SepSpikeOrderType × (ℕ × ℕ × ℕ))`. Per-slot reader `giOf wo s = tuple(owner s).get(rank s)`;
single-level merge `decide (giOf a ≤ giOf b)`. Consistency conjunct: per-owner `i₀<i₁<i₂` (Bool)
AND all used indices `Nodup` (genuine total order on the full multiset).

Seven proofs (all validated on paper + scratch):
1. `a<u'<b` expressible: σ=(0,2,3), τ=(1,4,5) ⟹ σ.lUW idx 3 < τ.lX1 idx 4 (below-anchor), with
   τ.lXU idx 1 between σ.lXU idx 0 and σ.lX1 idx 2 (genuine cross-region interleaving). The exact
   tuple the a<u'<b honest case needs is exhibited concretely.
2. Consistency (i₀<i₁<i₂) ⟹ same-owner rank<rank⟹index<index (giOf monotone in region rank).
3. mergeSort_perm membership: `kvE2_sepSlotsLOf_mem`/`ROf_mem` use only `List.mergeSort_perm`,
   comparator-agnostic — survive verbatim.
4. Faithful to Def 3.1 single global chain: the Nodup index is a total order on the full slot
   multiset extending each owner's per-region partial order (Lemma 3.2(1), md:77).
5. Terminality: a total order on the full multiset subsumes both above- and below-anchor
   interleavings ⟹ NO fifth carrier layer needed.
6. Placeholder tuple `(k, n+k, 2n+k)` (n=|pos|) reproduces 339's region-primary order EXACTLY
   (giOf = rank·n + k), enabling the behavior-preserving Phase 2 migration.
7. DecidableEq + Bool-decidability of the enriched entry confirmed via `inferInstance`/`decide`.

- **Goal:** Prove ON PAPER, before any Lean edit, that a concrete per-slot global-index
  representation (a) reproduces the exact honest value order for the `a < u' < b` cross-region case
  that broke 339, (b) is a faithful linear extension of Rabinovich Def 3.1's single global chain,
  (c) preserves the two load-bearing invariants (mergeSort_perm membership; same-owner
  rank<rank⟹index<index), and (d) establishes 340 as the terminal carrier layer (no fifth layer).
- **Tasks:**
  - [ ] Fix the exact enriched `KvE2SepWeakOrder` representation: choose a FINITE, `DecidableEq`,
        `decide`-able per-owner index encoding over the ≤3 left and ≤3 right region ranks (e.g. a
        monotone `(ℕ × ℕ × ℕ)` or bounded index list per side), NOT a `KvE2SepSlot → ℕ` function.
        Record the per-slot index reader `giOf : wo → KvE2SepSlot → ℕ` derived from it.
  - [ ] Write the single-level `kvE2_sepSlotMergeLe wo a b := decide (giOf wo a ≤ giOf wo b)` shape.
  - [ ] Prove on paper: the enumeration ranges over all order-consistent global interleavings, so the
        order realizing `a < u' < b` (σ.lUW index strictly below τ.lX1 index) IS enumerated and
        passes validity; exhibit the concrete index tuple.
  - [ ] Prove on paper: the consistency conjunct (index extends each owner's region order) ⟹
        same-owner `rank<rank ⟹ index<index`, so `hpairL/hpairR` survive.
  - [ ] Prove on paper: `mergeSort` by `giOf` is still a permutation of the block union, so
        `kvE2_sepSlotsLOf_mem` route is intact.
  - [ ] Faithfulness to Def 3.1 single global chain (Lemma 3.2(1), md:77): the index is a total order
        on the full slot multiset extending the per-owner partial orders — cite the mapping.
  - [ ] Terminality argument: the total-order-on-full-multiset index subsumes every honest
        interleaving (above- and below-anchor), so no further carrier layer is required.
  - [ ] Optional de-risking: a standalone compiling `example` (scratch) confirming the representation
        is `decide`-able and distinguishes the two interleavings.
- **Done when:** A written design spec (in the phase's git commit message / phase summary) states the
  chosen representation and the seven proofs above; the `a < u' < b` index tuple is exhibited
  concretely; the gate PASSES (terminality established). No `sorry`, no red build (analysis-only, or
  scratch `example` compiles). If the gate CANNOT be passed, mark [BLOCKED] and stop — do not begin
  Phase 2.
- **Estimated output:** ~150-250 lines design spec (+ optional <40-line scratch example). Analysis
  permitted (this is the required terminality proof; every subsequent phase produces Lean code).
- **Timing:** 2-4 hours
- **Depends on:** none

### Phase 2: Carrier type migration — enriched index field, behavior-preserving (green) [NOT STARTED]
- **Goal:** Land the enriched `KvE2SepWeakOrder` / `kvE2_sepOrderTypes` type carrying the per-slot
  global index, with the merge key TEMPORARILY defined to reproduce 339's exact order, so the WHOLE
  file compiles sorry-free before any behavioral change. This isolates mechanical type-plumbing from
  semantic change (avoids the all-at-once RED-for-a-dispatch failure mode).
- **Tasks:**
  - [ ] Redefine `KvE2SepWeakOrder` (SW:701-702) and `kvE2_sepOrderTypes` (SW:730-737) to carry the
        Phase-1 index encoding; keep the enumeration finite/`decide`-able.
  - [ ] Update the two distinguishability `example`s (SW:715-719) to the new tuple shape.
  - [ ] Re-prove the structural enumeration lemmas: `kvE2_sepOrderTypes_mem_aux` (SW:810),
        `kvE2_sepOrderTypes_owners_aux` (SW:908), `kvE2_sepOrderTypes_owners` (SW:930),
        `kvE2_sepMem_orderOwners` (SW:938).
  - [ ] Update `kvE2_sepModelTag`/`kvE2_sepModelOrder` (SW:740-750), `kvE2_sepCoincidentOrder`
        (SW:1619-1621) to supply a placeholder-but-valid index (e.g. region-order-consistent
        default); re-prove `kvE2_sepModelOrder_mem_orderTypes` (SW:835), `kvE2_sepCoincidentOrder_mem_orderTypes`
        (SW:1626).
  - [ ] Define `giOf` (per-slot index reader) and redefine `kvE2_sepSlotMergeLe` (SW:880-885) so it
        still yields 339's region-primary order for the placeholder index (behavior-preserving);
        keep `kvE2_sepOwnerRank` (SW:868) available if referenced.
  - [ ] Fix every remaining direct field-read site to compile (`kvE2_sepOrderOwners` sort key, etc.).
- **Done when:** `lake build` green, sorry-free; `lean_verify` on `kvE2_sepBody` axiom-clean; the
  slot lists produced are order-identical to 339 (behavior preserved). Commit as a green milestone.
- **Estimated output:** ~300-450 lines churn (mechanical type plumbing across the enumeration block).
  If it exceeds ~500 or fails the one-unit test, split into 2.1 (type + enumeration lemmas) / 2.2
  (model/coincident + merge-key plumbing), each green.
- **Timing:** 3-4 hours
- **Depends on:** 1

### Phase 3: Activate single-level merge key + re-sort + membership + pairwise (green) [NOT STARTED]
- **Goal:** Switch `kvE2_sepSlotMergeLe` to the true single-level per-slot-index compare, re-sort
  `kvE2_sepSlotsLOf/ROf`, and re-prove the membership and same-owner pairwise obligations under the
  new order.
- **Tasks:**
  - [ ] Collapse `kvE2_sepSlotMergeLe` (SW:880-885) to `decide (giOf wo a ≤ giOf wo b)`; drop the
        region-primary lex entirely.
  - [ ] Confirm `kvE2_sepSlotsLOf/ROf` (SW:896-904) still `mergeSort` the block union by the new key;
        re-prove `kvE2_sepSlotsLOf_mem` / `kvE2_sepSlotsROf_mem` (SW:954-971) via `List.mergeSort_perm`
        + `kvE2_sepMem_orderOwners` (route UNCHANGED — must-preserve).
  - [ ] Re-prove the point-level interleaving `example` (SW:982-988) for the new key, now including
        the `a < u' < b` cross-region case (σ.lUW index below τ.lX1 index).
  - [ ] Re-establish the `hpairL/hpairR` same-owner region-order pairwise facts consumed by
        `kvE2_sepDisjunct_extract` (SW:2091-2094) from the linear-extension property (index extends
        region order ⟹ same-owner slots stay in `kvE2_sepSlotRank` order); keep
        `kvE2_sep_index_lt_of_rank_lt` (SW:2015) usable.
- **Done when:** `lake build` green, sorry-free; `kvE2_sepSlotsLOf_mem`/`ROf_mem` and the interleaving
  `example` (with the `a < u' < b` case) both prove. Commit green milestone.
- **Estimated output:** ~150-300 lines.
- **Timing:** 2-4 hours
- **Depends on:** 2

### Phase 4: Validity consistency conjunct + carrier-membership re-proofs (green) [NOT STARTED]
- **Goal:** Add the linear-extension-of-region-order consistency conjunct to `kvE2_sepDisjValid`,
  and re-prove that the model, coincidence, and honest witnesses remain valid members of
  `kvE2_sepArr'`.
- **Tasks:**
  - [ ] Extend `kvE2_sepDisjValid` (SW:790-792) / `kvE2_sepDisjValidOwner` (SW:777-781): keep the
        per-owner F5 zone read AND replace/extend the `Nodup` owner-rank conjunct with the per-slot
        index CONSISTENCY conjunct (each owner's index assignment extends `lXU<lX1<lUW` left, mirror
        right; the cross-owner indices form a genuine total order). Read NO zone bit in the conjunct.
  - [ ] Re-prove `kvE2_sepArr'_mem_modelOrder` (SW:846) and `kvE2_sepModelOrder_mem_orderTypes` chain.
  - [ ] Re-prove `kvE2_sepBody_complete` (SW:1764) and task-337-P1 `kvE2_sepCoincidentOrder_mem_arr'`
        (SW:1804) — the no-collapse + 337-P1 must-preserve facts — under the new validity.
  - [ ] Re-prove `kvE2_sepCoincidentOwner_valid_left/right` (SW:1637+) if the validity signature moved.
- **Done when:** `lake build` green, sorry-free; both `kvE2_sepModelOrder` and
  `kvE2_sepCoincidentOrder` prove members of `kvE2_sepArr'`; `kvE2_sepCoincidentOrder_mem_arr'`
  proves. Commit green milestone.
- **Estimated output:** ~150-250 lines.
- **Timing:** 2-4 hours
- **Depends on:** 3

### Phase 5: Honest-bundle cross-owner order + completeness index consistency (green) [NOT STARTED]
- **Goal:** Extend `kvE2_sepHonestBundleL/R` to yield the cross-owner value order of the extracted
  witnesses, and thread that total order into the completeness index supply so the completeness
  witness's global index is consistent with the MODEL value order (the substantive value-faithful
  discharge, not merely a structural linear extension).
- **Tasks (sub-phase 5.1 — bundles, green):**
  - [ ] Extend `kvE2_sepHonestBundleL` (SW:1408-1441) and `kvE2_sepHonestBundleR` (SW:1460+) to
        additionally yield the cross-owner value order of the extracted witnesses (currently only
        per-owner `(x, x1_σ, w)` bounds). Reuse the do-not-edit extractor
        `kvE_subBracket2_complete_extract` (SubBracket2.lean:606); order already-extracted witnesses,
        introduce NO new model reasoning and NO `x1 < e_i` literal (LITMUS).
  - [ ] `lake build` green checkpoint after 5.1.
- **Tasks (sub-phase 5.2 — thread into completeness, green):**
  - [ ] Update `kvE2_sepCoincidentOrder` (SW:1619) / `kvE2_sepModelOrder` (SW:748) index supply and
        `kvE2_sepBody_complete` (SW:1764) so the honest completeness witness carries the global index
        consistent with the bundle's cross-owner value order.
  - [ ] Re-prove `kvE2_sepBody_complete` and `kvE2_sepCoincidentOrder_mem_arr'` with the model-value-
        consistent index.
- **Done when:** `lake build` green, sorry-free after each sub-phase; the completeness witness's
  index provably matches the honest cross-owner value order (including `a < u' < b`). Commit green
  milestones (5.1, then 5.2).
- **Estimated output:** ~200-400 lines total (5.1 ~120-200, 5.2 ~120-200). This is the riskiest
  phase; the pre-declared 5.1/5.2 split keeps each within one agent run.
- **Timing:** 4-6 hours
- **Depends on:** 4

### Phase 6: Final re-verification, axiom-clean, faithfulness audit (green) [NOT STARTED]
- **Goal:** Close out the remaining re-proofs, run the full build, assert axiom-cleanliness, and
  audit F1-F7 / LITMUS.
- **Tasks:**
  - [ ] Re-prove/confirm `kvE2_sepBody` (SW:1004), `kvE2_sepBody_holds_iff` (SW:1041),
        `kvE2_sepBody_nonvacuous` (SW:1583), `kvE2_sepBody_extract` (SW:2234),
        `kvE2_sepDisjunct_extract` (SW:2086) all green under the new carrier.
  - [ ] Full `lake build` green, project-wide (confirm no downstream file regressed).
  - [ ] `lean_verify` on `kvE2_sepBody`, `kvE2_sepBody_extract`, `kvE2_sepBody_complete`,
        `kvE2_sepCoincidentOrder_mem_arr'`, `kvE2_sepDisjunct_extract`: axiom set MUST equal
        `{propext, Classical.choice, Quot.sound}` — NO `sorryAx`.
  - [ ] F1-F7 audit: F5 zone-key non-conflation (open vs closed) intact; LITMUS
        (NavigatedSpine.lean:437) — grep/confirm no `x1 < e_i` relative-position literal introduced;
        F4 index-is-abstract-ℕ confirmed.
  - [ ] Confirm no load-bearing 334/336/338/339 result (Preserved Assets table) was destroyed.
- **Done when:** Full `lake build` green, sorry-free, axiom-clean; F1-F7/LITMUS audit passes;
  Preserved Assets all still proven. Commit as completion.
- **Estimated output:** ~100-200 lines (mostly confirmation + any residual proof repair).
- **Timing:** 2-3 hours
- **Depends on:** 5

## Testing & Validation

- [ ] `lake build` green at the end of every phase (Phase 1 analysis-only or scratch-example green).
- [ ] `lean_verify` axiom set = `{propext, Classical.choice, Quot.sound}` for all touched top-level
      theorems (Phase 6); no `sorryAx`.
- [ ] `kvE2_sepSlotsLOf_mem` / `kvE2_sepSlotsROf_mem` prove via the unchanged `mergeSort_perm` route.
- [ ] The `a < u' < b` interleaving `example` (Phase 3) proves — the blocker case is now expressible.
- [ ] `kvE2_sepModelOrder` and `kvE2_sepCoincidentOrder` both proven members of `kvE2_sepArr'`.
- [ ] `kvE2_sepCoincidentOrder_mem_arr'` (337-P1) still proves.
- [ ] No `x1 < e_i` relative-position literal introduced (LITMUS grep); F5 open/closed keys not
      conflated.

## Artifacts & Outputs

- plans/01_perslot-global-index-plan.md (this file)
- summaries/01_perslot-global-index-summary.md (on completion)
- Modified: Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean

## Rollback/Contingency

- Each phase commits at a green, sorry-free checkpoint (git-workflow.md commit-per-green-substep
  mandate), so any phase can be reverted independently to the prior green state.
- If Phase 1 gate fails (representation cannot be shown value-faithful/terminal), mark task
  [BLOCKED] with the design obstruction; do NOT begin Phase 2. This is the terminality safeguard.
- If a phase leaves the file RED and cannot be fixed forward within the dispatch, revert to the
  prior phase's green commit (snapshot first per git-workflow.md); never discard uncommitted work to
  reach a passing build, and never insert a vacuous/`sorry` placeholder to force green.
- If Phase 5 model reasoning stalls, fall back to the 5.1/5.2 split and land 5.1 (bundle extension)
  green independently before attempting 5.2.
