# Implementation Plan: Enrich separated-body weak-order with cross-owner anchor order

- **Task**: 338 - Enrich separated-body weak-order with cross-owner anchor order
- **Status**: [NOT STARTED]
- **Effort**: 6-8 hours
- **Dependencies**: None (task 334 and 336 both COMPLETED; their results are verified inputs)
- **Research Inputs**:
  - reports/01_weakorder-enrichment-research.md (spawn analysis, impacted-defs scope)
  - specs/337_.../reports/01_rabinovich-witness-ordering-faithfulness.md (Option A faithfulness)
  - specs/337_.../reports/02_coincident-order-and-weakorder-scope.md (Q1-Q4 impacted-defs table)
- **Artifacts**: plans/01_weakorder-crossowner-enrichment.md (this file)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/plan-format-enforcement.md
  - .claude/rules/lean4.md (literature fidelity, blocked MCP tools, build discipline)
- **Type**: lean4
- **Mode**: HARD (H3 reference grounding, H8 phase sizing, postmortem constraints, wave map)

## Overview

The task-334 weak-order carrier `KvE2SepWeakOrder := List (NormalForm sig 1 4 ×
KvE2SepSpikeOrderType)` (SharedWitness.lean:694-695) records only a **per-owner** placement tag
relative to the shared point `w`; two owners whose fresh anchors interleave differently
(`x1_σ < x1_τ` vs `x1_τ < x1_σ`) are **indistinguishable** to it. Rabinovich's merged disjuncts
(Lemma 3.2(1), p. of md:77) each pin a **single global order over the union of both owners'
points**, and witness/reference coincidence (`r_0 = z_0`, Lemma 5.3, md:145-152) is a first-class
disjunct. This task enriches `KvE2SepSpikeOrderType`/`KvE2SepWeakOrder` to carry a genuine
cross-owner order on the merged anchor multiset, threads that enrichment through the enumeration
and validity bodies, rewires `kvE2_sepBody` (SW:821-837, esp. 835-836) to **consume** the
weak-order value `_wo` it currently discards, and re-proves the downstream carrier lemmas. It
unblocks task 337's `.holds` builder, which needs a weak-order value carrying cross-owner data.

**Definition of done**: sorry-free; axiom-clean (`lean_verify` → `{propext, Classical.choice,
Quot.sound}` only, no `sorryAx`); full `lake build` green; all seven faithfulness invariants F1-F7
preserved, especially F5 (no open/closed zone-key conflation) and the LITMUS test at
NavigatedSpine.lean:437 (witness bounds from the bracket range, never an `x1 < e_i`
relative-position literal on a raw chain).

**Baseline (verified this planning session)**: SharedWitness.lean is currently sorry-free (the 7
`sorry` string hits at lines 1041/1323/1392/1591/2299/2482/2563 are all in comments/docstrings)
and was left axiom-clean by task 336 Phase 4. This is the no-regress baseline.

### Research Integration

Reports 01 (spawn), 337/01 (witness ordering: Option A = model-order merge is faithful, Option B =
Lean artifact), and 337/02 (Q1-Q4 impacted-defs table with verified line numbers) are integrated.
Report 337/02's verdict is decisive: cross-owner enrichment is faithful AND mandatory; coincidence
must remain first-class; strict `kvE2_sepModelOrder` is a genuine Rabinovich `r_0=z_0`
non-provability, not a bug.

### Preserved Assets

The following task-334/336 work is complete, sorry-free, axiom-clean, and MUST NOT regress.
"Statement preserved" = conclusion/signature unchanged, proof may re-run. "May extend" =
statement survives but strengthens.

| Component | Line | Status | Preservation contract |
|-----------|------|--------|----------------------|
| `kvE2_sepCoincidentAnchor_discharge` | 1361 | [COMPLETED task 336] | STATEMENT PRESERVED — reused verbatim as LEFT closed-bit discharge; do not touch |
| `kvE2_sepCoincidentAnchor_discharge_R` | 1508 | [COMPLETED task 336] | STATEMENT PRESERVED — reused verbatim as RIGHT closed-bit discharge; do not touch |
| `kvE2_sepClosedLeafStub` (placement-generic) | 738 | [COMPLETED task 336] | STATEMENT PRESERVED — the F5-safe CLOSED-key forward read (task 336 phases 1-3); keep both branches reading CLOSED keys |
| `kvE2_sepCoincidentOwner_valid_left` | 1465 | [COMPLETED task 336 hLR relax] | STATEMENT PRESERVED — reused as-is as per-owner component of enriched coincidence validity |
| `kvE2_sepCoincidentOwner_valid_right` | 1539 | [COMPLETED task 336] | STATEMENT PRESERVED — reused as-is (right mirror) |
| `kvE2_sepHonestBundleL` | 1222 | [COMPLETED task 334] | STATEMENT PRESERVED — raw per-owner anchor-bound data `x1_σ ∈ (x,w)`; reused/extended to establish cross-owner order |
| `kvE2_sepHonestBundleR` | 1274 | [COMPLETED task 334] | STATEMENT PRESERVED — right mirror; reused/extended |
| `kvE2_sepBody_complete` conclusion (`.disjuncts ≠ []`) | 1592 | [COMPLETED task 334 P8] | STATEMENT PRESERVED — routes through `kvE2_sepCoincidentOrder` membership + per-owner coincidence validity; proof re-run |
| `kvE2_sepBody_gate_fail` | 840 | [COMPLETED] | STATEMENT PRESERVED — re-proved against new body |
| `kvE2_sepBody_holds_iff` | 855 | [COMPLETED] | STATEMENT PRESERVED — re-proved against new body |
| `kvE2_sep_zWT3_ne_zXW3` | 724 | [COMPLETED] | STATEMENT PRESERVED |
| `kvE2_sepSpikeOrderTypes_complete` (exhaustiveness) | 698 | [COMPLETED] | May extend — re-proved for enriched constructor set |
| `kvE2_sepModelOrder_mem_orderTypes` / `_mem_aux` | 791 / 774 | [COMPLETED] | May extend — statement survives, proof re-run against new enumeration body |
| `kvE2_sepCoincidentOrder_mem_orderTypes` / `_mem_aux` | 1456 / 1439 | [COMPLETED] | May extend — statement survives, proof re-run against new enumeration body |
| `kvE2_sepArr'_mem_modelOrder` | 800 | [COMPLETED, dead completeness path] | May extend — hypothesis reshapes; remains a TRUE CONDITIONAL, not revived; nothing usable rests on it |
| `kvE2_sepArr'_sound` conclusion | 2594 | [COMPLETED task 334] | MAY EXTEND (strengthens) — gains a cross-owner consistency conjunct |
| Spike-realization block (`kvE2_sepSpikeDisjValid` etc.) | 2336-2500 | [COMPLETED] | May extend — pattern matches on constructors; re-proved |

**Genuinely invalidated, load-bearing: NONE.** The FALSE flatMap scaffolds
`kvE2_sepSlotsL_valid`/`_valid` were already deleted in task-334 Phase 6 (SW:1038-1044 comment:
"the identity interleaving of the flat union … need not be cross-σ compat"). The strict
`kvE2_sepModelOrder` completeness route was already known honestly non-dischargeable (SW:1421-1429).

### Source-to-Implementation Mapping (H3, Tier 1 — Rabinovich 2014)

| Source | Prop/Location | Lean Identifier | Type Signature (target) | Status |
|--------|---------------|-----------------|-------------------------|--------|
| Rabinovich 2014 | Def 3.1, md:63-74 (strict chain `x_0<…<x_n` within a disjunct) | `KvE2SepSpikeOrderType` (enriched) | inductive carrying cross-owner relative order | transcribed (P1) |
| Rabinovich 2014 | Lemma 3.2(1), md:77 (conjunction ≡ disjunction over the union) | `KvE2SepWeakOrder` (enriched), `kvE2_sepOrderTypes` | `List (KvE2SepWeakOrder sig)` = order-consistent global interleavings | transcribed (P1/P2) |
| Rabinovich 2014 | Insight #2, md:213-219 ("for ALL positions i") | `kvE2_sepDisjValid` cross-owner conjunct | `NormalForm sig 2 3 → KvE2SepWeakOrder sig → Bool` | transcribed (P2) |
| Rabinovich 2014 | Lemma 5.3, md:145-152 (`r_0=z_0` coincidence first-class) | `kvE2_sepCoincidentOrder` | `KvE2SepWeakOrder sig` (all-coincidence global order) | transcribed (P2/P3) |
| Rabinovich 2014 | §5 meet channel, md:168-173 (CLOSED `P_1(r_0)` bit) | `kvE2_sepClosedLeafStub` (preserved) | `NormalForm sig 1 4 → Bool` | transcribed (preserved) |
| Rabinovich 2014 | Def 3.1 realization "true model order" (Option A, report 337/01) | `kvE2_sepBody` consuming `wo` | `VVecEA2` (carrier side only; `.holds` engine deferred to task 337) | transcribed (P4) |

Second corroborating source for the load-bearing coincidence/strict split: report 337/02 Q1 +
report 337/01 §2 (independent confirmation that Option B is a Lean artifact, not Rabinovich's
mathematics), plus the task-334 in-file deletion note (SW:1038-1044). No single-passage conclusion.

### Transient Strategic-Sorry Scaffold (NOT deferred; discharged in-plan)

The type-level change to `KvE2SepSpikeOrderType`/`KvE2SepWeakOrder` cascades to ~15 downstream
proofs simultaneously; a "type change only, green" phase is impossible because the old proof bodies
stop type-checking. Rather than accept a multi-phase RED (broken build) window, Phase 1 keeps
`lake build` **GREEN** by inserting a bounded, enumerated set of transient `sorry` placeholders in
the **proof layer only** (never in a `def`/type body — a sorried definition is a vacuous-definition
violation per lean4.md). Consequences and rules:

- **No RED window.** `sorry` is a warning, not an error, so `lake build` compiles at every phase
  boundary. Each phase's done-criterion is "`lake build` green AND transient sorry count strictly
  less than the previous phase."
- **Monotone burn-down.** Phase 1 is the ONLY phase that introduces transient sorries. Phases 2-5
  strictly reduce the count; Phase 5 reaches ZERO.
- **Bounded inventory.** The transient sorries live only in: the membership re-proofs
  (`kvE2_sepModelOrder_mem_aux/_mem_orderTypes`, `kvE2_sepCoincidentOrder_mem_aux/_mem_orderTypes`,
  `kvE2_sepArr'_mem_modelOrder`), the coincidence-validity/completeness re-proofs
  (`kvE2_sepCoincidentOwner_valid_left/right`, `kvE2_sepBody_complete`), the structural body lemmas
  (`kvE2_sepBody_gate_fail`, `kvE2_sepBody_holds_iff`, `kvE2_sepBody_extract`), `kvE2_sepArr'_sound`,
  and the spike-realization re-proofs (2336-2500). The implementer records the exact
  file/line/statement of each in the H9 sorry inventory at Phase 1 end.
- **Not a Stage-4a skeleton.** These are internal scaffolding fully discharged by this plan's own
  phases; there are NO follow-up tasks and NO deferred division points. Therefore
  `plan_metadata.skeleton = false`, `follow_up_tasks = []`, and there is NO `## Planned Strategic
  Sorries` table. Any sorry that survives into Phase 5 without a discharge path is a plan deviation
  and must be flagged, not silently accepted.

## Goals & Non-Goals

- **Goals**:
  - Enrich `KvE2SepSpikeOrderType` + `KvE2SepWeakOrder` to encode cross-owner relative order on the
    merged anchor multiset `{x1_σ, x1_τ, …, w}`.
  - Enumerate order-consistent global interleavings in `kvE2_sepOrderTypes` (not the independent
    cartesian `3^|pos|` product).
  - Add a cross-owner consistency conjunct to `kvE2_sepDisjValid`; strengthen `kvE2_sepArr'_sound`.
  - Rewire `kvE2_sepBody` to CONSUME `wo` for each disjunct's cross-owner slot order.
  - Keep coincidence a first-class disjunct alongside strict cross-owner interleavings.
  - End sorry-free, axiom-clean, `lake build` green, F1-F7 preserved.
- **Non-Goals**:
  - Building the `.holds` realization engine (joint sorted-realization generalizing
    `k1v_sorted_realizationK`) — that is TASK 337's charter, explicitly out of scope here.
  - Making strict `kvE2_sepModelOrder` honestly provable — it is a genuine Rabinovich `r_0=z_0`
    semantic non-provability and stays a true conditional.
  - Re-enumerating permutations at the `.holds` level (Option B) — a Lean artifact per report 337/01.
  - Editing any file other than SharedWitness.lean (file_scope is a single file).

## Risks & Mitigations

- **Risk**: The enriched-type design forces reshaping the honest-bundle plumbing.
  **Mitigation**: `kvE2_sepHonestBundleL/R` already extract exactly the per-owner anchor bounds
  `x1 ∈ (x,w)` needed to build a cross-owner order; reuse them, do not rewrite.
- **Risk**: Phase 1 exceeds the H8 ~300-line bound (type + all constructor-consumer bodies +
  skeleton). **Mitigation**: split into sub-phases 1.1 (types + direct constructor-consumer
  re-typecheck + skeleton) and 1.2 (any remaining body typecheck) per the Splitting Rule below.
- **Risk**: F5 zone-key conflation when adding cross-owner semantics (mixing OPEN `zXU`/`zUW` with
  CLOSED `zAtX1L`/`zAtX1R`). **Mitigation**: strict tags MUST read OPEN bits, coincident tags MUST
  read CLOSED bits — inherited from `kvE2_sepClosedLeafStub`; Phase 5 F5 audit is a hard gate.
- **Risk**: Accidentally collapsing the carrier to coincidence-only (breaks task 337 soundness) or
  forcing strict-only (breaks `kvE2_sepBody_complete`). **Mitigation**: postmortem constraint,
  verified in Phase 5 by confirming BOTH a strict disjunct and the coincident disjunct are members.
- **Risk**: Reintroducing the deleted FALSE flatMap `kvE2_sepSlotsL/R` validity in the rewire.
  **Mitigation**: postmortem constraint; the rewire derives slot order from `wo`, never asserts the
  concatenation is monotone-valid.

## Postmortem Constraints

Binding rules for all implementation dispatches, derived from task 337's two stalled plan versions
and the task-334/336 findings.

**Do NOT**:
- Discard `_wo` in `kvE2_sepBody` and pin disjuncts to the fixed concatenation
  `kvE2_sepSlotsL/R qnf` — this is the exact root bug (SW:835-836) that blocked task 337 plans
  01/02 at their Phase-1 structural block. The rewire MUST consume `wo`.
- Build the `.holds` realization against a fixed concatenation slot order (the stall in 337). The
  `.holds` engine is not built in this task at all.
- Re-enumerate permutations at the `.holds` level (Option B / `List.mem_permutations`) — a Lean
  artifact duplicating the carrier's already-faithful order-type enumeration (report 337/01 §2).
- Reintroduce `kvE2_sepSlotsL_valid`/`_valid` or any "the flat union interleaving is cross-σ
  compatible" claim — deleted as FALSE in task-334 Phase 6.
- Attempt to make strict `kvE2_sepModelOrder` honestly valid, or "fix away" the
  `kvE2_sepDisjValid qnf (kvE2_sepModelOrder qnf)` non-provability (SW:1421-1429).
- Conflate open/closed zone keys (F5): never let a strict tag read a CLOSED bit or a coincident tag
  read an OPEN bit; never introduce an `x1 < e_i` relative-position literal on a raw chain
  (LITMUS, NavigatedSpine.lean:437).
- Put a `sorry` inside any `def`/type body or use a vacuous placeholder (`:= True`/`trivial`) — a
  Zero-Debt violation; transient sorries are permitted ONLY in proof (`theorem`/`lemma`) bodies and
  ONLY as scaffolding discharged before Phase 5 ends.
- Call `lean_diagnostic_messages` or `lean_file_outline` (blocked MCP tools, lean4.md).
- Edit any file other than SharedWitness.lean.

**MUST preserve**:
- Every row of the Preserved Assets table (statements/axiom-cleanliness of the task-334/336 base).
- The sorry-free, axiom-clean baseline (no permanent new sorries; no new axioms beyond
  `{propext, Classical.choice, Quot.sound}`).
- Coincidence AND strict cross-owner interleavings BOTH as members of the enriched enumeration.

**Design decisions are SETTLED** (do not re-open without a concrete counterexample):
- Cross-owner enrichment is REQUIRED, not optional (report 337/02 Q2 refutes "a per-owner tag
  suffices").
- Option A (model-order merge) is the faithful witness direction; Option B is rejected (report
  337/01 recommendation).
- Coincidence is a first-class disjunct on equal footing with strict interior placement (report
  337/02 Q1, Lemma 5.3 `r_0=z_0`; there is NO genericity/distinctness assumption in Rabinovich).
- The `.holds` realization engine belongs to task 337, not 338 (report 01 rationale: 338 is the
  additive carrier prerequisite; 337 is the builder that consumes it).

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Fully sequential. Phases 2 and 3 are logically distinct proof clusters (enumeration/membership vs
coincidence-validity/completeness) and could in principle be developed in parallel, but they mutate
the SAME file (SharedWitness.lean, the entire file_scope). Per H7 territory contracts, concurrent
dispatch requires disjoint file ownership, which is unavailable here — so no parallel wave exists.
Each wave is a single phase = a single agent run.

### Phase 1: Enriched types + compiling sorry-skeleton [COMPLETED]
- **Goal:** Redefine `KvE2SepSpikeOrderType` (SW:679-686) and `KvE2SepWeakOrder` (SW:694-695) to
  carry cross-owner relative order on the merged anchor multiset; adapt every DIRECT
  constructor-consumer body just enough to type-check; insert the bounded transient sorry-skeleton
  in the breaking proofs so `lake build` stays green.
- **Reference:** Rabinovich Def 3.1 (md:63-74) strict interior chain + Lemma 3.2(1) (md:77) global
  order over the union — the enriched type is the Lean encoding of one global order per disjunct.
- **Tasks:**
  - [ ] Design + write the enriched `KvE2SepSpikeOrderType` and `KvE2SepWeakOrder` so a value fixes
    the cross-owner order (e.g. rank/position of each owner's anchor in the merged ascending chain,
    with coincidence as a first-class tie), keeping the coincident tag reachable.
  - [ ] Re-type-check direct consumers so they compile (may retain placeholder per-owner semantics
    to be enriched in Phase 2): `kvE2_sepSpikeOrderTypes` (690), `kvE2_sepModelTag` (714),
    `kvE2_sepModelOrder` (719), `kvE2_sepClosedLeafStub` (738, preserve F5 CLOSED-key behavior),
    `kvE2_sepDisjValidOwner` (748), `kvE2_sepDisjValid` (757), `kvE2_sepCoincidentOrder` (1433),
    `kvE2_sepOrderTypes` (706), `kvE2_sepArr'` (763) + decidable instance (768).
  - [ ] Insert transient `sorry` in the enumerated breaking PROOFS only (see Transient Scaffold
    list). No `sorry` in any `def`/type body.
  - [ ] Re-prove `kvE2_sepSpikeOrderTypes_complete` (698) for the new constructor set (small, keep
    green without sorry if trivial).
  - [ ] Record the exact transient sorry inventory (file/line/statement) in the H9 handoff.
- **Timing:** 1.5-2 hours
- **Depends on:** none
- **Done when:** `lake build` green (warnings/sorries only); enriched types + all direct-consumer
  defs type-check; transient sorry inventory recorded; Preserved Assets statements untouched.
- **Splitting Rule (H8):** if this exceeds ~300 lines of output or the bounded-unit test, split into
  1.1 (types + `kvE2_sepSpikeOrderTypes`/`kvE2_sepModelTag`/`kvE2_sepModelOrder`/`kvE2_sepClosedLeafStub`/
  `kvE2_sepDisjValidOwner`/`kvE2_sepDisjValid` + skeleton) and 1.2 (`kvE2_sepOrderTypes` enumeration
  re-typecheck + `kvE2_sepCoincidentOrder` + `kvE2_sepArr'` + decidable instance).

### Phase 2: Cross-owner semantics in the body layer [COMPLETED]
- **Goal:** Install the genuine cross-owner semantics in the definition bodies (not just
  typechecking): `kvE2_sepOrderTypes` enumerates order-consistent global interleavings;
  `kvE2_sepDisjValid` gains a cross-owner consistency conjunct; `kvE2_sepModelOrder` /
  `kvE2_sepCoincidentOrder` encode the strict / all-coincidence GLOBAL orders in the enriched type.
- **Reference:** Rabinovich Insight #2 (md:213-219, "for ALL positions i" = full interleaving) and
  Lemma 3.2(1) (md:77).
- **Tasks:**
  - [ ] `kvE2_sepOrderTypes` (706): from independent cartesian `3^|pos|` to enumeration of
    order-consistent global interleavings of the merged anchor multiset.
  - [ ] `kvE2_sepDisjValid` (757): add the cross-owner consistency conjunct on the global order
    (keep per-owner `kvE2_sepDisjValidOwner` reads intact; conjoin the cross-owner check).
  - [ ] `kvE2_sepModelOrder` (719): strict cross-owner global order (remains an
    honestly-undischargeable conditional disjunct).
  - [ ] `kvE2_sepCoincidentOrder` (1433): the all-coincidence GLOBAL order in the enriched type.
  - [ ] Discharge any transient sorries whose obligations close at the body level (e.g. the
    `_mem_aux` structural memberships if the new enumeration makes them `decide`/`induction`-able).
- **Timing:** 1.5-2 hours
- **Depends on:** 1
- **Done when:** `lake build` green; the body semantics are cross-owner (verified by a local
  `#eval`/`example` that two differently-interleaving models yield DISTINCT weak orders — the
  under-specification that motivated the task); transient sorry count strictly less than Phase 1.

### Phase 3: Downstream proof repair (membership, coincidence validity, completeness) [COMPLETED]
- **Goal:** Discharge the enumeration/membership and coincidence-validity/completeness transient
  sorries against the enriched bodies.
- **Reference:** Rabinovich Lemma 5.3 (md:145-152) coincidence branch; §5 meet channel (md:168-173).
- **Tasks:**
  - [ ] `kvE2_sepModelOrder_mem_aux` (774) / `_mem_orderTypes` (791); `kvE2_sepArr'_mem_modelOrder`
    (800) — re-prove against the new enumeration (remains a true conditional; do not revive it).
  - [ ] `kvE2_sepCoincidentOrder_mem_aux` (1439) / `_mem_orderTypes` (1456) — re-prove membership.
  - [ ] `kvE2_sepCoincidentOwner_valid_left` (1465) / `_valid_right` (1539) — reuse the PRESERVED
    per-owner closed-bit discharges; add a cross-owner-consistency add-on lemma if the enriched
    `kvE2_sepDisjValid` requires it for the coincidence disjunct.
  - [ ] `kvE2_sepBody_complete` (1592) — re-prove `.disjuncts ≠ []` via `kvE2_sepCoincidentOrder`
    membership + coincidence validity (conclusion unchanged).
  - [ ] Spike-realization re-proofs (2336-2500) as needed.
- **Timing:** 1.5-2 hours
- **Depends on:** 2
- **Done when:** `lake build` green; all membership + coincidence + completeness sorries gone;
  BOTH a strict disjunct and the coincident disjunct confirmed to be enumeration members;
  transient sorry count strictly less than Phase 2.

### Phase 4: Central `kvE2_sepBody` rewire to consume `wo` + structural repair [IN PROGRESS]
- **Goal:** Rewire `kvE2_sepBody` (821-837) so each disjunct realizes its OWN cross-owner slot order
  derived from `wo`, replacing the discarded `_wo` + fixed `kvE2_sepSlotsL/R qnf`; repair the
  structural lemmas and strengthen `kvE2_sepArr'_sound`.
- **Reference:** Rabinovich Def 3.1 realization in true model order (Option A carrier side, report
  337/01); the `.holds` engine itself is DEFERRED to task 337.
- **Tasks:**
  - [ ] Define a `wo`-driven slot-ordering (order the per-owner region blocks `kvE2_sepSlotsLFor`/
    `RFor`, 292-311, by the cross-owner order carried in `wo`); do NOT assert flat-union validity.
  - [ ] Rewire the `(kvE2_sepArr' qnf).map fun _wo => …` (835-836) to consume `wo`.
  - [ ] Re-prove `kvE2_sepBody_gate_fail` (840), `kvE2_sepBody_holds_iff` (855),
    `kvE2_sepBody_extract` (2013) against the new body.
  - [ ] Strengthen `kvE2_sepArr'_sound` (2594) conclusion with the cross-owner consistency conjunct
    now that `kvE2_sepDisjValid` carries it.
- **Timing:** 1.5-2 hours
- **Depends on:** 3
- **Done when:** `lake build` green; `kvE2_sepBody` consumes `wo` (no `_wo` discard, no fixed
  concatenation pin); structural lemmas re-proved; `kvE2_sepArr'_sound` strengthened; transient
  sorry count strictly less than Phase 3.

### Phase 5: Verification — axiom gate + F1-F7 audit + full build [NOT STARTED]
- **Goal:** Discharge any residual transient sorry, then verify sorry-free + axiom-clean + full
  green + faithfulness.
- **Tasks:**
  - [ ] Discharge any remaining transient sorries (target: already zero after Phase 4; this phase
    is the hard gate).
  - [ ] `lean_verify` on the enriched carrier symbols (`kvE2_sepBody`, `kvE2_sepArr'`,
    `kvE2_sepArr'_sound`, `kvE2_sepBody_complete`, `kvE2_sepDisjValid`) → axioms must be EXACTLY
    `{propext, Classical.choice, Quot.sound}`, NO `sorryAx`.
  - [ ] F1-F7 audit, especially F5 (no open/closed zone-key conflation: strict tags read OPEN
    `zXU`/`zUW`, coincident tags read CLOSED `zAtX1L`/`zAtX1R`).
  - [ ] LITMUS check (NavigatedSpine.lean:437): confirm no `x1 < e_i` relative-position literal on a
    raw chain was introduced; witness bounds come from the bracket range.
  - [ ] Confirm the no-collapse invariant: BOTH strict and coincident disjuncts remain members.
  - [ ] Full `lake build` green.
- **Timing:** 1 hour
- **Depends on:** 4
- **Done when:** zero sorries; `lean_verify` axiom-clean on all enriched symbols; F1-F7 preserved;
  full `lake build` green; Preserved Assets confirmed non-regressed.

## Testing & Validation
- [ ] `lake build` green at every phase boundary (sorries permitted transiently in phases 1-4 only).
- [ ] Transient sorry count strictly decreasing per phase; zero at end of Phase 5.
- [ ] `lean_verify` → `{propext, Classical.choice, Quot.sound}` only on all enriched carrier symbols.
- [ ] Cross-owner distinguishability check: two models with `x1_σ<x1_τ` vs `x1_τ<x1_σ` yield
  distinct weak orders (the fix's defining property).
- [ ] Both strict and coincident disjuncts are enumeration members (no-collapse invariant).
- [ ] F5 zone-key non-conflation audit; LITMUS NavigatedSpine:437.
- [ ] Preserved Assets statements/axiom-cleanliness confirmed non-regressed.

## Artifacts & Outputs
- plans/01_weakorder-crossowner-enrichment.md (this file)
- summaries/01_weakorder-crossowner-enrichment-summary.md (on completion)
- Modified: Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean

## Rollback/Contingency
- Each phase commits at its green boundary (per-green-substep mandate). If a phase cannot reach its
  done-criterion, mark it [PARTIAL], leave the transient sorry-skeleton compiling (green build), and
  the next `/implement` resumes from the incomplete phase.
- If the enriched-type DESIGN proves unworkable mid-Phase-1 (e.g. cannot both carry cross-owner
  order and keep coincidence first-class in a `decide`-able finite enumeration), STOP and escalate
  with the goal state — do NOT force strict-only or coincidence-only (both violate settled design
  decisions). This is a design blocker, not a proof blocker.
- Before any destructive git rollback on a dirty tree, run `.claude/scripts/git-snapshot.sh` first
  (git-workflow.md). Fix-forward is preferred over rollback (recovery ladder).
