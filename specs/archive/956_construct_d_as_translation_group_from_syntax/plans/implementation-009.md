# Implementation Plan: ROAD_MAP.md Updates + Goal A Completeness

- **Task**: 956 - Construct D as translation group from syntax
- **Status**: [NOT STARTED]
- **Effort**: 10-14 hours
- **Dependencies**: None
- **Research Inputs**: research-029.md (motives analysis, three-goal decomposition, ROAD_MAP.md update plan)
- **Artifacts**: plans/implementation-009.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true
- **Supersedes**: implementation-008.md (v008 was Goal A work but lacked ROAD_MAP.md context)

## Overview

This plan addresses the goal conflation identified in research-029. Task 956 has drifted through 28 research reports and 8 plans, conflating three independent goals:

- **Goal A**: Sorry-free standard completeness with D=Int (achievable now)
- **Goal B**: D constructed from pure syntax (original task intent, deferred)
- **Goal C**: Non-trivial task_rel encoding displacement (depends on Goal B, deferred)

This revision prioritizes **ROAD_MAP.md updates** (Phase 0) to document the exploration journey, then continues with **Goal A completeness** (Phases 1-6) using the canonical Int-indexed FMCS architecture from v008.

### Three-Goal Decomposition

| Goal | Description | Status | This Plan |
|------|-------------|--------|-----------|
| **A** | Sorry-free completeness with D=Int | Priority | Phases 1-6 |
| **B** | D emerges from temporal axioms | Deferred | Future task |
| **C** | task_rel encodes displacement | Deferred | Depends on Goal B |

### Why ROAD_MAP.md First

Research-029 identified that ROAD_MAP.md has no mention of task 956 despite 28 research reports exploring 4+ dead ends and making key architectural decisions. Without documentation, future work will re-explore these dead ends.

## Goals & Non-Goals

**Goals**:
- Document task 956's exploration journey in ROAD_MAP.md
- Add 4 dead ends discovered during task 956
- Record architectural decisions (irreflexive semantics, seriality axioms, etc.)
- Archive irrelevant/misguided elements to Boneyard
- Complete Goal A: sorry-free standard completeness with D=Int

**Non-Goals**:
- Goal B: Constructing D from pure syntax (deferred to future task)
- Goal C: Non-trivial task_rel (depends on Goal B)
- K-Relational strategy (identified as closest to Goal B, but not this plan)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Chain F-persistence unprovable | HIGH | MEDIUM | Try all three design options (bounded step, omega-squared, reactive) |
| Archival breaks imports | MEDIUM | LOW | Phase 1 verifies build before continuing |
| ROAD_MAP.md update conflicts | LOW | LOW | Single comprehensive update, no parallel edits |
| Lean proof blocked | HIGH | MEDIUM | If stuck >2 hours on any proof, mark [BLOCKED] for user review |

## Implementation Phases

### Phase 0: ROAD_MAP.md Updates [NOT STARTED]

- **Dependencies**: None
- **Goal**: Document task 956 exploration in ROAD_MAP.md before implementation

**Tasks**:
- [ ] Add new Strategy entry for task 956 documenting exploration (28 reports, 8 plans)
- [ ] Add new Ambition: "Syntactically-Derived Duration Domain" (Goal B as long-term)
- [ ] Add Dead End: "Product Domain Temporal Trivialization" (RestrictedQuotient x Q with constant-MCS)
- [ ] Add Dead End: "TranslationGroup Holder's Theorem Chain" (freeness, homogeneity, Archimedean blockers)
- [ ] Add Dead End: "Fragment Chain F-Persistence" (fragmentChainFMCS jump-over problem)
- [ ] Add Dead End: "Reflexive G/H Semantics Switch" (does NOT solve truth lemma, collateral damage)
- [ ] Add Architectural Decisions table entry: Irreflexive G/H semantics
- [ ] Add Architectural Decisions table entry: Seriality axioms F(neg bot)/P(neg bot)
- [ ] Add Architectural Decisions table entry: bmcs_truth_at planned for archival
- [ ] Add Architectural Decisions table entry: task_rel = True accepted for Goal A
- [ ] Add Three-Goal Decomposition to Proof Economy section
- [ ] Update "Last Updated" date

**Timing**: 2 hours

**Files to modify**:
- `specs/ROAD_MAP.md`

**Verification**:
- All 4 dead ends documented with lessons learned
- Architectural Decisions table present
- Three-goal decomposition explains A/B/C distinction
- Strategy entry references research-029.md

---

### Phase 1: Boneyard Archival [NOT STARTED]

- **Dependencies**: Phase 0
- **Goal**: Remove distracting dead-end definitions from active codebase

**Tasks**:
- [ ] Create Boneyard directory: `Theories/Bimodal/Boneyard/Task956/`
- [ ] Move `Bundle/TemporalDomain.lean` to `Boneyard/Task956/TemporalDomain.lean`
- [ ] Move `Bundle/TranslationGroup.lean` to `Boneyard/Task956/TranslationGroup.lean`
- [ ] Move `Bundle/BFMCSTruth.lean` to `Boneyard/Task956/BFMCSTruth.lean` (if not already archived)
- [ ] Move `Bundle/TruthLemma.lean` to `Boneyard/Task956/TruthLemma.lean` (if bmcs_truth_at based)
- [ ] Update imports in `Bundle/` and `Representation.lean` to remove archived dependencies
- [ ] Update `Metalogic.lean` to remove archived imports
- [ ] Run `lake build` to verify nothing breaks
- [ ] Add README.md to Boneyard/Task956/ explaining archival rationale

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/` (move files)
- `Theories/Bimodal/Boneyard/Task956/` (create)
- `Theories/Bimodal/Metalogic/Metalogic.lean` (update imports)

**Verification**:
- `lake build` passes
- Archived files no longer imported by active Metalogic modules
- README.md in Boneyard/Task956/ documents task 956 dead ends

---

### Phase 2: Consolidate Truth Lemma Infrastructure [NOT STARTED]

- **Dependencies**: Phase 1
- **Goal**: Make `Representation.lean` use `canonical_truth_lemma` directly

**Tasks**:
- [ ] Add import of `CanonicalConstruction` to `Representation.lean` if not present
- [ ] Remove duplicate `canonical_truth_lemma_all` from `Representation.lean` (line ~269 if present)
- [ ] Update `shifted_truth_lemma` to reference `canonical_truth_lemma`
- [ ] Verify proof still works
- [ ] Run `lake build`

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation.lean`

**Verification**:
- `lake build` passes
- No duplicate truth lemmas in active codebase
- `grep -rn "canonical_truth_lemma" Theories/Bimodal/Metalogic/` shows single definition

---

### Phase 3: Analyze Chain F-Persistence Problem [NOT STARTED]

- **Dependencies**: Phase 2
- **Goal**: Understand why `fragmentChainFMCS_forward_F` has sorry

**Tasks**:
- [ ] Read `FragmentCompleteness.lean` chain construction
- [ ] Trace through `buildFragmentChain` step by step
- [ ] Identify specific jump-over scenario (where F-witnesses can be missed)
- [ ] Document findings in research note or code comments
- [ ] Evaluate Option A: Bounded step size (adjacent chain steps)
- [ ] Evaluate Option B: Omega-squared indexing (process all F-obligations per level)
- [ ] Evaluate Option C: Reactive processing (process before jump)
- [ ] Select approach and document rationale

**Timing**: 2 hours

**Files to examine**:
- `Theories/Bimodal/Metalogic/Bundle/FragmentCompleteness.lean`
- `Theories/Bimodal/Metalogic/Bundle/CanonicalCompleteness.lean`

**Verification**:
- Written analysis of jump-over problem with concrete counterexample
- Selected design approach with rationale

**Escape Valve**: If analysis reveals fundamental obstacle after 2 hours, mark [BLOCKED] with `review_reason: "F-persistence requires mathematical insight beyond current approach"`

---

### Phase 4: Implement Refined Chain Construction [NOT STARTED]

- **Dependencies**: Phase 3
- **Goal**: Implement chain construction that proves `forward_F/backward_P` without sorry

**Tasks**:
- [ ] Implement chosen chain construction from Phase 3 design
- [ ] Prove `fragmentChainFMCS_forward_F` without sorry
- [ ] Prove `fragmentChainFMCS_backward_P` without sorry
- [ ] Run `lake build`
- [ ] `grep -n "\bsorry\b" FragmentCompleteness.lean` to verify

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FragmentCompleteness.lean`

**Verification**:
- `lake build` passes
- `grep -n "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/FragmentCompleteness.lean` returns empty or unrelated sorries only

**Escape Valve**: If proof stuck >2 hours, mark [BLOCKED] with specific stuck point documented

---

### Phase 5: Construct BFMCS Int Without Sorry [NOT STARTED]

- **Dependencies**: Phase 4
- **Goal**: Prove `fully_saturated_bfmcs_exists_int` without sorry

**Tasks**:
- [ ] Use `fragmentChainFMCS` as eval family for each diamond obligation
- [ ] For each Diamond(psi) obligation, construct witness `fragmentChainFMCS` rooted at witness MCS
- [ ] Prove temporal coherence for all families (uses Phase 4 results)
- [ ] Prove modal saturation (multi-family witnesses Box satisfaction)
- [ ] Complete `fully_saturated_bfmcs_exists_int` proof
- [ ] Run `lake build`

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean`

**Verification**:
- `grep -n "fully_saturated_bfmcs_exists_int" Theories/Bimodal/Metalogic/ | grep -v ".lean:" | grep sorry` returns empty
- `lake build` passes

**Escape Valve**: If modal saturation proof stuck, mark [BLOCKED] with current proof state

---

### Phase 6: Verify Standard Completeness + Final Validation [NOT STARTED]

- **Dependencies**: Phase 5
- **Goal**: Confirm completeness theorem is sorry-free and document completion

**Tasks**:
- [ ] Verify `standard_weak_completeness` in Representation.lean has no sorry dependency
- [ ] Verify `standard_strong_completeness` in Representation.lean has no sorry dependency
- [ ] Run `lake build` on full project
- [ ] Run `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/` for full audit (exclude Boneyard)
- [ ] Create implementation summary: `specs/956_construct_d_as_translation_group_from_syntax/summaries/implementation-summary-{DATE}.md`
- [ ] Update state.json and TODO.md with completion status

**Timing**: 1.5 hours

**Files to create**:
- `specs/956_construct_d_as_translation_group_from_syntax/summaries/implementation-summary-{DATE}.md`

**Verification**:
- `lake build` passes
- Standard completeness theorems have no sorry dependencies
- `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/ --include="*.lean" | grep -v Boneyard` returns empty or acceptable sorries only

---

## Testing & Validation

- [ ] `lake build` passes at each phase
- [ ] No new sorries introduced
- [ ] ROAD_MAP.md contains all 4 dead ends from task 956
- [ ] ROAD_MAP.md contains Architectural Decisions table
- [ ] ROAD_MAP.md contains three-goal decomposition
- [ ] Archived files in Boneyard/Task956/
- [ ] `fully_saturated_bfmcs_exists_int` resolved (Goal A)
- [ ] Standard completeness theorems sorry-free

## Artifacts & Outputs

- Updated `specs/ROAD_MAP.md` with task 956 documentation
- `Theories/Bimodal/Boneyard/Task956/` directory with archived files
- Sorry-free standard completeness (Goal A achieved)
- Implementation summary documenting the resolution

## Appendix: ROAD_MAP.md Update Content

### New Strategy Entry (for Strategies section)

```markdown
### Strategy: Task 956 D-from-Syntax Exploration

**Status**: CONCLUDED (Goal A selected)
**Started**: 2026-02-XX
**Hypothesis**: D can be constructed from the temporal axioms rather than imported (Goal B).

*Rationale*: Task 954/955 used D=Int with `task_rel = True`, importing algebraic structure from outside the logic. Task 956 explored whether D's group structure could emerge from the axioms themselves.

**Approach**:
Explored multiple paths over 28 research reports and 8 implementation plans:
1. TranslationGroup/Aut+(T) - blocked by Holder's theorem requirements
2. Product domain RestrictedQuotient x Q - temporal trivialization
3. Fragment chain FMCS - F-persistence jump-over problem
4. K-Relational (Cantor on canonical timeline) - identified but not pursued

**Outcomes**:
- 4 dead ends documented (see Dead Ends section)
- Key architectural decisions recorded
- Three-goal decomposition: A (sorry-free D=Int), B (D from syntax), C (non-trivial task_rel)
- Goal A selected as current priority; Goals B/C deferred

**References**:
- [research-029.md](specs/956_construct_d_as_translation_group_from_syntax/reports/research-029.md) - Motives analysis
- [implementation-009.md](specs/956_construct_d_as_translation_group_from_syntax/plans/implementation-009.md) - Current plan
```

### New Ambition Entry (for Ambitions section)

```markdown
### Ambition: Syntactically-Derived Duration Domain (Goal B)

**Priority**: LOW
**Timeframe**: LONG-TERM

*Rationale*: The current D=Int architecture imports algebraic structure from outside the logic. Goal B would derive D's properties from the temporal axioms, making discrete vs. dense a theorem rather than an assumption.

**Success Criteria**:
- [ ] Canonical timeline T proven countable dense without endpoints (from axioms)
- [ ] Cantor's theorem applied: T isomorphic to Q
- [ ] D inherits Q's algebraic structure
- [ ] D is "discovered" from syntax, not imported

**Description**:
Construct D as the group of translations that emerges from the temporal axioms. The K-Relational strategy (research-020/021/023) is the closest viable path: prove relational completeness without TaskFrame, show canonical timeline is countable dense without endpoints, apply Cantor's theorem.

**Related Phases**: N/A (future work)
**References**:
- [Task 956 research](specs/956_construct_d_as_translation_group_from_syntax/reports/) - Exploration history
- [research-029.md](specs/956_construct_d_as_translation_group_from_syntax/reports/research-029.md) - Goal decomposition
```

### New Dead Ends (for Dead Ends section)

Four entries per research-029.md recommendations.

### New Architectural Decisions Table

| Decision | Date | Rationale |
|----------|------|-----------|
| Irreflexive G/H semantics | 2026-02 | Supports density proof architecture |
| Seriality axioms F(neg bot)/P(neg bot) | 2026-03-09 | Replaces T-axioms for NoMaxOrder/NoMinOrder under irreflexive semantics |
| `canonical_truth_lemma` as primary | 2026-03-09 | Direct `truth_at` connection; bmcs_truth_at redundant |
| `bmcs_truth_at` planned for archival | 2026-03-09 | Creates unnecessary indirection |
| `task_rel = True` accepted for Goal A | 2026-03-09 | Non-trivial task_rel requires Goal B |

## Estimated Total

| Phase | Hours |
|-------|-------|
| Phase 0 (ROAD_MAP.md) | 2 |
| Phase 1 (Archival) | 1.5 |
| Phase 2 (Consolidate) | 1 |
| Phase 3 (Analyze) | 2 |
| Phase 4 (Implement chain) | 3 |
| Phase 5 (BFMCS) | 2.5 |
| Phase 6 (Verify) | 1.5 |
| **Total** | **13.5** |

## Rollback/Contingency

If implementation fails at any phase:
1. Phases 0-1 (documentation/archival): These are non-destructive; no rollback needed
2. Phases 2-5 (code changes): Git revert to pre-phase state; archived files remain in Boneyard
3. Phase 6 (verification): If sorries remain, document remaining blockers and mark task [PARTIAL]

If Goal A proves unachievable:
- Document blockers in implementation summary
- Consider pivoting to K-Relational strategy (Goal B) in a new task
- Leave ROAD_MAP.md updates in place (they are valuable regardless)
