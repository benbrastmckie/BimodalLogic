# Research Report: Task 956 Motives, Drift Analysis, and ROAD_MAP.md Update Plan

**Task**: 956 - Construct D as translation group from syntax
**Date**: 2026-03-09
**Session**: sess_1773118591_25188
**Run**: 029
**Mode**: Team Research (2 teammates)
**Effort**: High
**Dependencies**: research-001 through research-028 (complete trajectory), ROAD_MAP.md
**Sources/Inputs**: All 28+ research reports, 8 implementation plans, ROAD_MAP.md, codebase
**Artifacts**: This report
**Standards**: report-format.md, return-metadata-file.md

## Executive Summary

- The **original goal** of task 956 -- constructing D as a translation group that EMERGES from the temporal axioms -- has been entirely lost. Implementation plan v008 explicitly returns to `D = Int` (the very thing task 956 was created to supersede).

- The root cause of 28 reports of drift is a **conflation of three distinct goals**: (A) sorry-free completeness with D=Int, (B) D constructed from pure syntax, and (C) non-trivial task_rel. These have been treated as one goal but are mathematically independent.

- **Plan v008 is a regression**: it uses `D = Int` with `CanonicalConstruction.lean` -- predating task 956 -- and focuses on resolving a sorry that existed before task 956 was created. This is Goal A (sorry elimination), not Goal B (D from syntax).

- **ROAD_MAP.md has no mention of task 956** and documents none of its explorations. It needs significant updates to provide guardrails against future drift.

- The **proposed ROAD_MAP.md update** decomposes the goals, documents the dead ends discovered by task 956, records architectural decisions, and declares Goal A as the current priority with Goals B/C as longer-term ambitions.

## Team Contributions

| Teammate | Focus | Confidence |
|----------|-------|------------|
| A | Primary motives analysis -- traced original intent and drift across all 28 reports | High |
| B | ROAD_MAP.md gap analysis and detailed update plan | High |

No conflicts between teammates. Both confirm the same core finding: goal conflation is the root cause.

---

## Part 1: Original Task Intent (Teammate A Synthesis)

### The Philosophical Goal

Task 956 was conceived as a **foundational replacement** for hardcoded `D = Int`. The original intent (research-001) is a 10-step pipeline:

```
Consistent set
  → MCS origin w₀ (Lindenbaum)
  → Linear order T of reachable MCSs (existence lemma)
  → D = Aut+(T) (translation group)
  → eval₀ : D ≅ T (origin bijection, group action)
  → Linearly ordered abelian group
  → task_rel = group action (non-trivial)
  → Canonical model
  → Truth lemma
  → Completeness
```

The philosophical claim: "from syntax" means D's structure is a **theorem about the axioms**, not an assumption. Change the temporal axioms, get a different D. For TM with density, D should be Q. For TM with discreteness, D should be Z. The construction **derives** D; it does not assume it.

### Why "Supersedes D = Int"

The task explicitly supersedes Tasks 954/955 because:
1. Int brings algebraic structure from outside the logic
2. `task_rel := True` means D's group structure is never exercised
3. The translation group would be **intrinsic** -- D's structure would be a theorem

### The Drift (28 Reports, 8 Plans)

| Phase | Reports | What Happened |
|-------|---------|---------------|
| Immediate discovery | 3-4 | Freeness of Aut+(T) fails for general linear orders (Q counterexample) |
| Exploration | 5-14 | TranslationGroup.lean, discreteness axioms, HomogeneousTimeline -- each deferring the hard parts |
| Infrastructure blockers | 15-20 | DenselyOrdered has 4 sorries, Countable BidirectionalQuotient is FALSE |
| Pragmatic pivots | 21-28 | K-Relational, seriality axioms, product domain, canonical Int pipeline |
| **Current (v008)** | - | **Return to D = Int** -- the pre-task-956 status quo |

### What Has Been Lost

1. **D emerges from syntax** -- Completely lost. v008 uses D = Int.
2. **task_rel as group action** -- Completely lost. Trivial task_rel remains.
3. **Torsor structure** (T as D-torsor) -- Completely lost.
4. **eval₀ bijection** (D ≅ T via origin) -- Completely lost.
5. **Philosophical narrative** -- Lost; recent plans are purely tactical sorry-elimination.
6. **D derived from axioms** (discrete vs dense is a theorem, not assumption) -- Completely lost.

---

## Part 2: ROAD_MAP.md Gap Analysis (Teammate B Synthesis)

### What ROAD_MAP.md Currently Lacks

1. **No mention of task 956** by number, title, or goal
2. **No articulation of "D from syntax"** -- the phrase appears only in TODO.md
3. **No documentation of task 956's dead ends** -- 4+ conclusively abandoned approaches
4. **No distinction between Goals A/B/C** -- sorry-free completeness vs D construction vs task_rel
5. **No record of key architectural decisions** -- irreflexive semantics, seriality axioms, bmcs_truth_at archival

### Proposed ROAD_MAP.md Updates

#### New: Three-Goal Decomposition

The ROAD_MAP.md should explicitly document:

**Goal A: Sorry-Free Standard Completeness**
- Prove `valid phi → derivable phi` with zero sorries
- Blocker: `fully_saturated_bfmcs_exists_int` (3 sorries in chain construction)
- D used: Int (imported)
- task_rel: Trivial
- **Current priority** -- achievable independently of Goals B/C

**Goal B: D Constructed from Syntax**
- D emerges from axioms as ordered abelian group
- Blocker: Holder's theorem chain (freeness, homogeneity, Archimedean)
- All candidate constructions (Aut+(T), K-Relational, formal displacements) face hard obstacles
- **Longer-term ambition** -- does not block Goal A

**Goal C: Non-Trivial task_rel**
- task_rel encodes actual displacement structure
- Depends on Goal B
- **Longer-term ambition** -- depends on Goals A and B

#### New: Dead Ends from Task 956

Four dead ends to add to ROAD_MAP.md:

1. **Product Domain Temporal Trivialization**
   - `TemporalDomain = RestrictedQuotient × Q` with constant-MCS histories
   - Fails: G(phi) collapses to phi (same problem as Constant Witness Family)
   - Lesson: Non-constant families essential for temporal semantics

2. **TranslationGroup Holder's Theorem Chain**
   - Aut+(T) with AddGroup proven (281 lines, sorry-free)
   - Fails: Freeness, homogeneity, Archimedean are interleaved hard requirements
   - Lesson: Automorphism group approach requires homogeneity = AddTorsor requirement

3. **Canonical Int-Indexed FMCS via Fragment Chain (F-Persistence)**
   - `fragmentChainFMCS : FMCS Int` from monotone chain
   - Fails: Chain may "jump over" F-witnesses; 2 sorries in FragmentCompleteness.lean
   - Lesson: Embedding uncountable fragment into Int via single chain cannot guarantee witness visits

4. **Reflexive G/H Semantics Switch**
   - Investigated whether `≤` instead of `<` would resolve truth lemma
   - Fails: Does NOT solve backward direction; severe collateral damage (density axiom trivializes, etc.)
   - Lesson: Reflexive vs irreflexive is a logic-level architectural decision, not a proof strategy

#### New: Architectural Decisions Table

| Decision | Date | Rationale |
|----------|------|-----------|
| Irreflexive G/H semantics | ~2026-02 | Supports density proof architecture |
| Seriality axioms added | 2026-03-09 | Replaces T-axioms for NoMaxOrder/NoMinOrder under irreflexive semantics |
| `canonical_truth_lemma` as primary | 2026-03-09 | Direct `truth_at` connection; bmcs_truth_at redundant |
| `bmcs_truth_at` planned for archival | 2026-03-09 | Creates unnecessary indirection |
| `task_rel = True` accepted for Goal A | 2026-03-09 | Non-trivial task_rel requires Goal B |

---

## Part 3: Synthesis and Recommendations

### Conflict Analysis

No conflicts between teammates. Both independently conclude:
1. Plan v008 is a regression (returns to pre-task-956 status quo)
2. Three goals need explicit separation
3. ROAD_MAP.md needs updating before further implementation

### Recommendation 1: Update ROAD_MAP.md First

Before any further implementation:
1. Add the three-goal decomposition (Goals A/B/C)
2. Add the four dead ends from task 956
3. Add the architectural decisions table
4. Declare Goal A as current priority

This is a **prerequisite** for the next plan revision, per the user's instruction.

### Recommendation 2: Revise Plan v008 AFTER ROAD_MAP.md Update

Once ROAD_MAP.md is updated and goals are clear, decide:

**If pursuing Goal A (recommended, shorter-term)**:
- Plan v008 is acceptable in CONCEPT but needs to acknowledge it is NOT "D from syntax"
- The F-persistence problem is the correct technical focus
- Describe the task as "sorry-free completeness with D=Int" not "D from syntax"

**If pursuing Goal B (ambitious, longer-term)**:
- Abandon the canonical Int pipeline entirely
- Return to K-Relational strategy (research-020/021/023)
- Prove canonical timeline is countable dense without endpoints, apply Cantor
- This preserves "D is discovered" narrative while sidestepping Aut+(T) blockers

### Recommendation 3: Do NOT Continue Implementing Plan v008

The plan is working on the wrong thing (sorry elimination in `D=Int` architecture) when the task is supposed to be about constructing D from syntax. Either:
- Revise the task description to make Goal A explicit, then continue with v008
- Or pursue Goal B with a new plan

### Closest Path to Original Intent

Teammate A identifies **Strategy K-Relational** (research-020/021/023) as the closest path to the original task intent:
1. Prove relational completeness without TaskFrame
2. Show canonical timeline is countable dense without endpoints (from seriality + density axioms)
3. Apply Cantor's theorem: every countable dense linear order without endpoints is isomorphic to Q
4. Inherit Q's algebraic structure for D
5. D is "discovered" from the axioms, not imported

This preserves "D from syntax" while bypassing the Aut+(T) blockers. It requires a density proof for the canonical timeline (hard but principled).

---

## Decisions

- **D1**: Goals A, B, C must be separated. They are independent; conflating them causes drift.
- **D2**: ROAD_MAP.md must be updated before further implementation.
- **D3**: Plan v008 is acceptable for Goal A but is NOT pursuing Goal B.
- **D4**: If the intention is Goal B, K-Relational strategy is the closest viable path.
- **D5**: Implementation-008 Phase 0 (archival) and Phase 1 (consolidation) are valid regardless of which goal is pursued.

## Next Steps

1. **Update ROAD_MAP.md** with proposed content from Teammate B
2. **Clarify with user**: Is the current session pursuing Goal A or Goal B?
3. **Revise plan** accordingly:
   - Goal A → Rename task, keep v008, fix F-persistence
   - Goal B → New plan based on K-Relational strategy

## Confidence Assessment

| Finding | Confidence | Notes |
|---------|------------|-------|
| Goals A/B/C are distinct | High | Mathematically independent |
| Plan v008 is Goal A (not B) | High | Uses D=Int explicitly |
| Original task was Goal B | High | Research-001 is unambiguous |
| K-Relational closest to Goal B | Medium | Never fully pursued; obstacles may emerge |
| ROAD_MAP.md needs updating | High | No task 956 content present |
