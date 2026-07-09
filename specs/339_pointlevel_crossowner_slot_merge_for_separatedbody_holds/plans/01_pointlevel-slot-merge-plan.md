# Implementation Plan: Point-level cross-owner slot merge for separated-body holds

- **Task**: 339 - Point-level cross-owner slot merge for separated-body holds
- **Status**: [NOT STARTED]
- **Effort**: 12-16 hours (5 phases; foundational faithful-transcription, quality over speed)
- **Dependencies**: 338 (COMPLETED — enriched weak-order carrier with merged-chain rank)
- **Research Inputs**:
  - reports/01_pointlevel-slot-merge-research.md (spawn analysis)
  - specs/337_.../reports/04_honest-case-blocker-verification.md (adversarial verification)
  - specs/337_.../reports/02_coincident-order-and-weakorder-scope.md (Rabinovich faithfulness)
  - specs/338_.../summaries/01_weakorder-crossowner-enrichment-summary.md (338 deliverable)
- **Artifacts**: plans/01_pointlevel-slot-merge-plan.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/lean4.md
- **Type**: lean4
- **Mode**: HARD (skill-planner-hard; H3 reference grounding, H8 phase sizing, postmortem constraints)

## Overview

Task 338 enriched `KvE2SepWeakOrder` with a cross-owner merged-chain RANK (`ℕ`) and rewired
`kvE2_sepBody` to consume it, but implemented `kvE2_sepSlotsLOf`/`kvE2_sepSlotsROf`
(`SharedWitness.lean:869-876`) as a per-owner BLOCK `flatMap` over `kvE2_sepOrderOwners`
(`SW:861-863`): the rank permutes whole owner blocks, keeping each owner's points contiguous.
`IntervalPattern.holds` / `holds_eq_succ` (`ExistsForallNF.lean:106-132, 188-204`) demands ONE
globally strictly-monotone witness `witnesses : Fin (n+1) → M.carrier` over the FULL concatenated
slot list, which block ordering structurally cannot supply for interleaving honest models —
proven rank-independent by report 04's five `lean_run_code` experiments. This plan redesigns
`kvE2_sepSlotsLOf`/`kvE2_sepSlotsROf` into a genuine POINT-LEVEL cross-owner merge — every owner's
individual slot entries interleaved into ONE globally value-sorted chain keyed by
(merged-chain rank, intra-owner region rank) — faithful to Rabinovich Def 3.1's single global
chain over the UNION of points (md:65-74), then re-establishes the dependent task-338 lemmas
against the new def.

**Definition of done**: `kvE2_sepSlotsLOf`/`ROf` are a point-level merge (not block flatMap);
`kvE2_sepBody`, `kvE2_sepBody_holds_iff`, `kvE2_sepBody_nonvacuous`, `kvE2_sepBody_extract`,
`kvE2_sepDisjunct_extract` all sorry-free against it; the enriched 338 weak-order TYPE and the
no-collapse property preserved; `kvE2_sepCoincidentOrder_mem_arr'` (SW:1733) unchanged and holds;
`lean_verify` axiom-clean (`{propext, Classical.choice, Quot.sound}`, no `sorryAx`); full
`lake build` green; F1-F7 preserved (esp. F5 and the LITMUS at `NavigatedSpine.lean:437`).

### Research Integration

- Report 04 supplies the binding negative result (block order is structurally insufficient,
  rank-independent) and the positive target: a merge keyed by each slot's merged-chain position,
  aligned to the `k1v_sorted_realizationK` engine's boundary-linked merged-anchor interface
  (`SubBracket2V.lean:633`, `interleaveK` output `Pairwise (· < ·)`).
- Report 02 supplies the Rabinovich faithfulness constraint (single global chain over the UNION
  of points; coincidence first-class).
- Task 338 summary supplies the preserved carrier (`List (NormalForm sig 1 4 ×
  KvE2SepSpikeOrderType × ℕ)`) and the invariants that must not regress.

### Source-to-Implementation Mapping (H3, Tier 1 — literature-backed)

| Source | Prop/Location | Lean Identifier | Type Signature (target) | Status |
|--------|---------------|-----------------|--------------------------|--------|
| Rabinovich Def 3.1 | Single global chain over UNION of points, md:65-74 | `kvE2_sepSlotsLOf` (redesign) | `KvE2SepWeakOrder sig → List (KvE2SepSlot sig)` (point-level merge) | pending |
| Rabinovich Def 3.1 | md:65-74 (right mirror) | `kvE2_sepSlotsROf` (redesign) | `KvE2SepWeakOrder sig → List (KvE2SepSlot sig)` (point-level merge) | pending |
| Rabinovich Lemma 3.2(1) | Order-type disjunction, md:77 | `kvE2_sepBody_holds_iff` | statement-preserved (references defs by name) | transcribed (re-verify) |
| Rabinovich Prop 4.2 | Non-vacuity, md:100-101 | `kvE2_sepBody_nonvacuous` | statement-preserved | pending |
| Rabinovich Def 3.1 / Cor 5.4 | Monotone enumeration / region-rank, PDF p.4; md:154-157 | `kvE2_sepDisjunct_extract` | parametric over `lL lR` — statement AND proof preserved | transcribed (re-verify) |
| Rabinovich Lemma 5.1 | Shared-`w` bracket / per-σ bundles, md:72, md:168-173 | `kvE2_sepBody_extract` | statement-preserved (`hpairL`/`hpairR` kept as hypotheses); internal `hmemL`/`hmemR` re-derived | pending |
| Engine interface | `k1v_sorted_realizationK`, boundary-linked merged-anchor, SubBracket2V.lean:633 | (design reference only) | `List.Chain'` link + `hpos` + `interleaveK` `Pairwise (· < ·)` | reference |

Exact PDF page numbers for each `md:` line reference are pinned by the Phase 1 design gate.

### Preserved Assets

The following task-334/336/337/338 work is complete and MUST NOT regress. Statements may extend
or strengthen (per 338's precedent), never invalidate.

| Component | File / Location | Status | Verified |
|-----------|-----------------|--------|----------|
| Enriched weak-order TYPE `KvE2SepWeakOrder := List (NormalForm sig 1 4 × KvE2SepSpikeOrderType × ℕ)` | SharedWitness.lean (338) | [COMPLETED] | 2026-07-08 (338 P5) |
| No-collapse: `kvE2_sepModelOrder_mem_orderTypes` | SW:835 | [COMPLETED] | 2026-07-08 |
| No-collapse: `kvE2_sepCoincidentOrder_mem_orderTypes` | SW:1555 | [COMPLETED] | 2026-07-08 |
| Task-337 Phase-1: `kvE2_sepCoincidentOrder_mem_arr'` | SW:1733 | [COMPLETED] | 2026-07-08 |
| `kvE2_sepDisjValid` / `kvE2_sepArr'` / `kvE2_sepArr'_sound` (ranks-Nodup conjunct) | SW | [COMPLETED] | 2026-07-08 |
| Coincidence discharges `kvE2_sepCoincidentAnchor_discharge`/`_R`, per-owner validators | SW:1566-1609 | [COMPLETED] | 2026-07-08 |
| Spike-realization block | SW:2336-2571 | [COMPLETED] | 2026-07-08 |
| Per-owner block pairwise `kvE2_sepSlotsLFor`/`RFor` Pairwise | SW:1113, 1144 | [COMPLETED] | 2026-07-08 |
| `kvE2_sepDisjunct_extract` (parametric over `lL lR`) | SW:2015 | [COMPLETED] | 2026-07-08 |

## Postmortem Constraints

Binding rules for all implementation dispatches. Derived from task-338's under-delivery
(a correct-but-wrong-layer fix), report 04's adversarial verdict, and the lean4 zero-debt gate.

**Do NOT**:
- Do NOT ship a block-level reordering again. `kvE2_sepSlotsLOf`/`ROf` must interleave INDIVIDUAL
  owner slot entries into one global chain. A def that keeps each owner's points contiguous
  (any `(...).flatMap kvE2_sepSlotsLFor` shape) is the exact failure report 04 proved
  rank-independent — reject it at design review (Phase 1 gate) before writing proofs.
- Do NOT skip the Phase 1 design gate. Task 338 delivered a correct cross-owner ORDER at the
  wrong GRANULARITY because it did not first pin the exact `.holds` slot-list shape. Phase 1
  MUST validate the merge against `IntervalPattern.holds` (ExistsForallNF.lean:106-204) BEFORE
  any def edit. Implementation phases do not start until the gate passes.
- Do NOT put a `sorry` in any DEFINITION body, ever. Vacuous placeholders (`def X := True`,
  `:= Unit`, `:= trivial`) are prohibited (lean4.md) and count as `sorry`. Transient `sorry`
  is permitted ONLY in the PROOF layer, must be logged in the sorry inventory, must strictly
  decrease each phase, and must be ZERO by Phase 5.
- Do NOT introduce an `x1 < e_i` relative-position literal on a raw chain (LITMUS,
  NavigatedSpine.lean:437). All slot positioning must ride the arrangement/merge INDEX, never a
  model relative-position literal. This is F4/LITMUS and is checked in Phase 5.
- Do NOT conflate open and closed zone keys (F5). The strict tags read the OPEN `zXU`/`zUW` bits;
  the coincidence tag reads the CLOSED `zAtX1L`/`zAtX1R` self-zone bits. The merge reorders slots
  only; it must not touch which bit `kvE2_sepDisjValidOwner`/`kvE2_sepClosedLeafStub` reads.
- Do NOT re-derive or re-open the 338 cross-owner ORDER (the merged-chain rank on
  `KvE2SepWeakOrder`). It is the KEY the merge sorts by, consumed as-is.
- Do NOT expand scope to task 337's `.holds` BUILDER (the ⇐ / `mpr` construction of the global
  monotone witness). 339 delivers the merged CARRIER and the ⇒ EXTRACTION lemmas; 337 consumes it.

**MUST preserve**:
- Every row of the Preserved Assets table above (verbatim statements; proofs may re-run).
- The enriched 338 weak-order TYPE and the `kvE2_sepDisjValid` ranks-Nodup conjunct.
- The no-collapse property: BOTH `kvE2_sepModelOrder` and `kvE2_sepCoincidentOrder` remain
  machine-checked members of the enumeration.
- `kvE2_sepCoincidentOrder_mem_arr'` (SW:1733) unchanged (feeds task 337's membership half).

**Design decisions are SETTLED** (do not re-open without a concrete counterexample):
- The block flatMap is structurally insufficient (report 04, experiments 1-5, rank-independent).
  This is not re-litigated; the point-level merge is the mandated fix.
- "Coincidence" is SELF-coincidence (a placement TAG selecting which bit is read), NOT cross-owner
  anchor sharing. Owners keep DISTINCT `zipIdx` ranks; interleaving honest inputs are real
  (report 04 §"Why the coincidence subtlety does NOT dissolve"). The merge must handle
  interleaving, not assume anchor collapse.
- `kvE2_sepDisjunct_extract` (SW:2015) is PARAMETRIC over `lL lR` and takes `hmemL`/`hpairL` as
  hypotheses — it never mentions `kvE2_sepSlotsLOf`. Its statement and proof are preserved; only
  its Phase-5 axiom re-verification against the new caller is required (confirmed by source read).
- `kvE2_sepBody_extract` keeps `hpairL`/`hpairR` (Pairwise `kvE2_sepSlotLe` over `kvE2_sepSlotsLOf
  wo`) as HYPOTHESES. Discharging that pairwise for the merged chain is task 337's builder-side
  obligation, NOT re-litigated here — 339 keeps `kvE2_sepBody_extract` parametric in those facts.
  (Phase 1 confirms/overrides this boundary; if it overrides, the change is flagged as may-extend.)

## Goals & Non-Goals

- **Goals**:
  - Redesign `kvE2_sepSlotsLOf`/`kvE2_sepSlotsROf` (SW:869-876) into a point-level cross-owner
    merge keyed by merged-chain position, per Rabinovich Def 3.1.
  - Re-establish `kvE2_sepBody`, `kvE2_sepBody_holds_iff`, `kvE2_sepBody_nonvacuous`,
    `kvE2_sepBody_extract`, `kvE2_sepDisjunct_extract` sorry-free against the new def.
  - Preserve all Preserved-Assets rows and the no-collapse property.
  - Axiom-clean + F1-F7 audit + full `lake build` green.
- **Non-Goals**:
  - Task 337's `.holds` BUILDER (⇐ construction of the global monotone witness) — out of scope.
  - Discharging `kvE2_sepBody_extract`'s `hpairL`/`hpairR` for the merged chain — 337-side.
  - Any change to the 338 weak-order TYPE, the rank field, or the validity predicate.
  - Any change to zone-bit selection (F5) or the spike-realization block.

## Risks & Mitigations

- **Risk**: Merge def keeps owner points contiguous (accidental block behaviour). **Mitigation**:
  Phase 1 gate + a Phase 5 F-audit check that constructs an interleaving 2-owner example and
  confirms the merged chain interleaves individual slots (not blocks).
- **Risk**: `kvE2_sepBody_extract`'s internal `hmemL`/`hmemR` re-derivation (per-owner slot ∈ merged
  chain) is harder than the block flatMap version. **Mitigation**: Phase 1 designs the merge as a
  permutation of the block-flatMap union (mergeSort of tagged slots), so membership follows from
  `List.mergeSort_perm` + the existing per-owner `kvE2_sepSlotsLFor` membership lemmas
  (SW:1960-1969) — the same technique 338 used for `kvE2_sepMem_orderOwners` (SW:910).
- **Risk**: A dependent proof cannot be closed in its phase. **Mitigation**: transient proof-layer
  `sorry` (inventory-tracked, strictly decreasing), NEVER in a def body; escalate per lean4.md if a
  phase cannot reduce the count.
- **Risk**: The merge breaks F5 / LITMUS by reading a relative-position literal. **Mitigation**:
  the merge sorts by an abstract ℕ composite key (rank, region-rank via `kvE2_sepSlotRank`), never
  a model position — mirrors 338's rank being ℕ-to-ℕ only. Verified Phase 5.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Fully sequential: all phases edit the single file `SharedWitness.lean` and the proofs are tightly
coupled to the def shape settled in Phase 1, so there is no safe parallel territory (H7 not
applicable — single file, one owner). Each phase is one agent run ending at its stated milestone.

### Phase 1: Design specification gate — `.holds`-shape validation (no code edits) [COMPLETED]
- **Goal:** Pin the EXACT slot-list shape `IntervalPattern.holds` requires, confirm the proposed
  point-level merge produces it and is Rabinovich-faithful, and write the target signatures +
  downstream-lemma classification. This gate MUST pass before any def edit (the 338-under-delivery
  lesson). Analysis is EXPLICITLY sanctioned for this phase only (overrides H2 anti-analysis),
  because it is the anti-under-delivery mechanism the task mandates.
- **Tasks:**
  - [ ] (a) Read `ExistsForallNF.lean:106-204` and state concretely what the slot list must supply:
    one `witnesses : Fin (n+1) → M.carrier` GLOBALLY strictly-monotone (`∀ i j, i < j → wᵢ < wⱼ`,
    line 117 / holds_eq_succ:194), each slot's point type realized at its witness, and the
    α/β segment obligations — i.e. the concatenated slot-list ORDER is the witness index order.
  - [ ] (b) Confirm the point-level merge (all owners' individual slots interleaved into ONE
    value-sorted chain keyed by (merged-chain rank, intra-owner `kvE2_sepSlotRank`)) produces
    exactly that shape AND is faithful to Rabinovich Def 3.1 (single global chain over the UNION
    of points, md:65-74) and the `k1v_sorted_realizationK` boundary-linked merged-anchor interface
    (SubBracket2V.lean:633). Use up to ~5 `lean_multi_attempt`/`lean_run_code` scratch checks
    (mirroring report 04's method) to VALIDATE — not to prove — the shape.
  - [ ] (c) Write the target signatures of `kvE2_sepSlotsLOf`/`ROf` (redesigned) and enumerate every
    downstream lemma with a statement-preserved vs may-extend classification and the precise reason,
    reconciling with the SETTLED decisions in Postmortem Constraints:
    `kvE2_sepBody` (statement-preserved — maps by name); `kvE2_sepBody_holds_iff` (statement- and
    proof-preserved — shallow `simp/dif_pos`); `kvE2_sepBody_nonvacuous` (statement-preserved —
    `List.mem_map` by name); `kvE2_sepDisjunct_extract` (parametric — preserved); `kvE2_sepBody_extract`
    (statement-preserved; internal `hmemL`/`hmemR` re-derived). Flag any override of the boundary
    decisions (esp. whether `kvE2_sepOrderOwners`/`kvE2_sepMem_orderOwners` are repurposed or kept).
  - [ ] Record the merge design as a mergeSort-of-tagged-slots (permutation of the block-flatMap
    union) so membership/preservation follow from `List.mergeSort_perm`, and confirm F5/LITMUS
    (abstract ℕ key only) up front.
- **Timing:** 2-4 hours.
- **Depends on:** none.
- **Done when:** design spec captured (answers (a),(b),(c) with the target signatures written out
  and every downstream lemma classified), the merge shape validated against the `holds_eq_succ`
  target by scratch checks, and no design constraint (block-contiguity, F5, LITMUS) violated. The
  spec is recorded in the implementation summary / a short design note under this task's `reports/`;
  NO source file is edited in this phase.

### Phase 2: Point-level merge defs + shallow dependent lemmas [NOT STARTED]
- **Goal:** Replace the block flatMap with the point-level merge and re-establish the two shallow
  dependent lemmas, ending at a compiling file.
- **Tasks:**
  - [ ] Redesign `kvE2_sepSlotsLOf`/`kvE2_sepSlotsROf` (SW:869-876) as the point-level merge from
    Phase 1: tag each positive owner's `kvE2_sepSlotsLFor`/`RFor` slots with the composite key
    (owner merged-chain rank from `wo`, intra-owner `kvE2_sepSlotRank`), collect ALL tagged slots
    across owners, `mergeSort` by the composite key, map back to `List (KvE2SepSlot sig)`. NO
    `sorry` in the def body; not vacuous.
  - [ ] Add the structural membership helper: `∀ σ ∈ kvE2_sepPos qnf, ∀ s ∈ kvE2_sepSlotsLFor σ,
    s ∈ kvE2_sepSlotsLOf wo` (and the RFor/ROf mirror) for `wo ∈ kvE2_sepOrderTypes qnf`, via
    `List.mergeSort_perm` + `kvE2_sepOrderTypes_owners` (SW:902) + the per-owner slot-membership
    lemmas (SW:1960+) — the same permutation technique as `kvE2_sepMem_orderOwners` (SW:910).
  - [ ] Re-verify `kvE2_sepBody` (SW:933) type-checks consuming the new defs (statement unchanged).
  - [ ] Re-prove `kvE2_sepBody_holds_iff` (SW:970) — expected proof-preserved (`simp only
    [kvE2_sepBody]; rw [dif_pos hg]; ...`); confirm green.
  - [ ] Re-prove `kvE2_sepBody_nonvacuous` (SW:1512) — `List.mem_map.mpr` with
    `kvE2_sepArr'_mem_modelOrder` against the renamed-but-same slot functions; confirm green.
- **Timing:** 3-4 hours.
- **Depends on:** 1.
- **Done when:** `lake build` compiles; the merge defs are non-vacuous point-level merges;
  `kvE2_sepBody_holds_iff` and `kvE2_sepBody_nonvacuous` sorry-free; sorry count ≤ 1 and confined to
  the `kvE2_sepBody_extract` proof only (inventory-logged), everything else green. Commit at green.

### Phase 3: Re-verify `kvE2_sepDisjunct_extract` against the merged caller [NOT STARTED]
- **Goal:** Confirm the parametric extraction lemma still holds and its index-reads
  (`kvE2_sep_index_lt_of_rank_lt`, SW:1944) are unaffected by the merge.
- **Tasks:**
  - [ ] Confirm `kvE2_sepDisjunct_extract` (SW:2015) is unchanged: it is parametric over `lL lR`
    and consumes `hmemL`/`hpairL`/`hmemR`/`hpairR` as hypotheses; it never references
    `kvE2_sepSlotsLOf`. Re-run its proof to green (expected no edit).
  - [ ] If Phase 1's classification found a genuine may-extend (e.g. the merged chain requires a
    different pairwise key than `kvE2_sepSlotLe`), realize that extension here: adjust the
    `hpairL`/`hpairR` predicate and re-prove `kvE2_sep_index_lt_of_rank_lt`-style index reads
    accordingly, flagging the statement extension in the summary. Otherwise this is a re-verify.
  - [ ] `lean_verify` `kvE2_sepDisjunct_extract` sorry-free and axiom-clean.
- **Timing:** 2-3 hours.
- **Depends on:** 2.
- **Done when:** `kvE2_sepDisjunct_extract` sorry-free and green; any statement extension flagged;
  sorry count unchanged or reduced. Commit at green.

### Phase 4: Re-prove `kvE2_sepBody_extract` (per-owner membership re-derivation) [NOT STARTED]
- **Goal:** Close the one lemma whose internal `hmemL`/`hmemR` derivation depends on the merged
  slot-list shape, reaching sorry-count zero.
- **Tasks:**
  - [ ] Re-prove `kvE2_sepBody_extract` (SW:2163): keep `hpairL`/`hpairR` as hypotheses (SETTLED
    boundary), route through `kvE2_sepBody_holds_iff` (Phase 2) + `kvE2_sepDisjunct_extract`
    (Phase 3), and supply the internal `hmemL`/`hmemR` (`∀ σ ∈ kvE2_sepPos, ∀ s ∈
    kvE2_sepSlotsLFor σ, s ∈ kvE2_sepSlotsLOf wo`) from the Phase 2 membership helper.
  - [ ] Remove the last transient `sorry` (if any remained from Phase 2); confirm inventory = 0.
  - [ ] `lean_verify` `kvE2_sepBody_extract` sorry-free and axiom-clean.
- **Timing:** 3-4 hours.
- **Depends on:** 3.
- **Done when:** `kvE2_sepBody_extract` sorry-free and green; total transient sorry count = 0 across
  all touched declarations. Commit at green.

### Phase 5: Verification gate — axiom-cleanliness + F1-F7 audit + full build [NOT STARTED]
- **Goal:** Prove the whole redesign is faithful and debt-free.
- **Tasks:**
  - [ ] `lean_verify` (fully-qualified) each touched declaration — `kvE2_sepSlotsLOf`,
    `kvE2_sepSlotsROf`, the merge/membership helpers, `kvE2_sepBody`, `kvE2_sepBody_holds_iff`,
    `kvE2_sepBody_nonvacuous`, `kvE2_sepDisjunct_extract`, `kvE2_sepBody_extract` — confirming the
    axiom set ⊆ `{propext, Classical.choice, Quot.sound}` with NO `sorryAx`.
  - [ ] Zero-sorry census on `SharedWitness.lean` (sorry count 0); zero vacuous defs; zero new axioms.
  - [ ] F1-F7 audit, with explicit attention to: F5 (no open/closed zone-key conflation — the merge
    touches slot ORDER only, never bit selection) and the LITMUS at `NavigatedSpine.lean:437` (no
    `x1 < e_i` relative-position literal; the merge key is abstract ℕ only).
  - [ ] No-collapse regression check: `kvE2_sepModelOrder_mem_orderTypes` (SW:835) and
    `kvE2_sepCoincidentOrder_mem_orderTypes` (SW:1555) still green; a self-contained `example`
    that an interleaving 2-owner input produces a merged chain interleaving individual slots
    (not contiguous owner blocks) — the defining property of this redesign.
  - [ ] Preservation check: `kvE2_sepCoincidentOrder_mem_arr'` (SW:1733) unchanged and green; all
    Preserved-Assets rows still hold.
  - [ ] Full `lake build` green (whole project; external consumers unaffected).
- **Timing:** 2-3 hours.
- **Depends on:** 4.
- **Done when:** all `lean_verify` axiom-clean, sorry census 0, F1-F7 audit passes (F5 + LITMUS
  explicit), no-collapse + preservation checks pass, full `lake build` green. Commit at green;
  write the implementation summary.

## Testing & Validation

- [ ] `lake build` green after each of Phases 2-5 (scoped `lake build` on the module during phases,
  full project in Phase 5).
- [ ] `lean_verify` axiom set ⊆ `{propext, Classical.choice, Quot.sound}`, no `sorryAx`, on every
  touched declaration (Phase 5).
- [ ] Sorry inventory strictly decreasing across phases, zero at Phase 5.
- [ ] Interleaving 2-owner `example` demonstrates point-level (not block) interleaving.
- [ ] F5 and LITMUS (NavigatedSpine.lean:437) checks explicit in the Phase 5 audit.
- [ ] No-collapse members + `kvE2_sepCoincidentOrder_mem_arr'` (SW:1733) unchanged.

## Artifacts & Outputs

- plans/01_pointlevel-slot-merge-plan.md (this file)
- reports/02_holds-shape-design-spec.md (Phase 1 design note; optional — may be folded into summary)
- Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean (edited)
- summaries/01_pointlevel-slot-merge-summary.md (Phase 5)

## Rollback/Contingency

- Single-file change (`SharedWitness.lean`); revert = `git checkout` that file to the pre-Phase-2
  commit. Each phase commits at green, so rollback granularity is per-phase.
- If Phase 1 concludes the point-level merge cannot supply the `holds_eq_succ` shape without a
  deeper carrier change than `kvE2_sepSlotsLOf`/`ROf` (e.g. the `KvE2SepSlot` type itself must
  carry a merged-chain index), STOP and escalate: mark the task [BLOCKED] with the design finding
  and spawn a scoped carrier-type task rather than forcing an under-delivering def (the 338 lesson).
- If a dependent proof cannot reach sorry-zero in its phase, keep the transient sorry
  inventory-logged and mark the phase [PARTIAL]; do NOT discard uncommitted work to force a green
  build (recovery ladder: fix forward → strategic-sorry skeleton → snapshot-then-rollback).
