# Research Report: Task #981 - Covering Proof Analysis (Math Domain)

**Task**: 981 - remove_axiom_technical_debt_from_task_979
**Mode**: Team Research (2 teammates, math domain override)
**Started**: 2026-03-17
**Session**: sess_1773757253_327a81
**Artifacts**:
- Teammate A: `research-007-teammate-a-findings.md` (covering proof gap analysis)
- Teammate B: `research-007-teammate-b-findings.md` (alternative approaches survey)
- This synthesis: `research-007.md`

---

## Executive Summary

After seven research runs spanning tasks 979 and 981, this report synthesizes all findings
and resolves the question of what approach can actually eliminate `discrete_Icc_finite_axiom`.

**Core result**: The covering proof (`discreteImmediateSucc_covers`) is **equivalent** to the
DF frame condition, which cannot be extracted from DF axiom membership in MCSes through
syntactic/algebraic reasoning alone. All approaches tried so far operate at the wrong level.

**Primary recommendation**: **Incremental staged construction** using
`discreteImmediateSuccSeed` (with blocking formulas) in place of
`forward_temporal_witness_seed` in `discreteStagedBuild`. This is the one approach that:
1. Has not been blocked by a mathematical impossibility
2. Is supported by the literature (Segerberg/Verbrugge)
3. Makes covering hold BY CONSTRUCTION rather than by proof

**Secondary recommendation**: Research the DF frame condition extraction path more carefully,
specifically the "bidirectional symmetry" property proved below.

---

## Known Equivalences (Confirmed)

From `DiscreteTimeline.lean` and prior research, the following are **equivalent**:

| Equivalent Claim | Status |
|-----------------|--------|
| `discrete_Icc_finite_axiom` (interval finiteness) | AXIOM (technical debt) |
| Covering lemma `discreteImmediateSucc_covers` | 3 SORRIES |
| DF frame condition (immediate successors exist) | UNPROVABLE at MCS level (so far) |
| `LocallyFiniteOrder DiscreteTimelineQuot` | BLOCKED |
| `WellFoundedLT (Ioi M)` for any M | BLOCKED |

Proving **any one** of these eliminates the axiom.

---

## Confirmed Dead Ends (Summary)

The following approaches are confirmed dead ends or blocked:

| Approach | Verdict | Evidence |
|----------|---------|----------|
| Blocking formula covering proof (3 sorries) | UNFILLABLE with current approach | Research-005, DiscreteTimeline.lean task 979 history |
| Well-founded minimal successor (plan v5) | INCORRECT (orders independent) | Implementation session 1773756442 |
| `WellFoundedLT DiscreteTimelineQuot` | FALSE (has NoMinOrder) | Teammate B |
| Stage-bounding for interval finiteness | DEAD END | ROAD_MAP.md |
| h_content duality chain alone | INSUFFICIENT | DiscreteTimeline.lean task 979 history, Teammate A |
| Direct density template inversion | STRUCTURAL ASYMMETRY | DiscreteTimeline.lean comment |
| `SuccOrder.ofLinearWellFoundedLT` | BLOCKED (WellFoundedLT false) | Teammates A+B |

---

## New Analysis: The Duality Symmetry

### The Four-Way Duality Chain

This research identifies a complete **bidirectional symmetry** in the canonical relations
not previously fully stated, derived from `WitnessSeed.lean`:

**Theorem 1** (`g_content_subset_implies_h_content_reverse`):
```
g_content(M) ⊆ K → h_content(K) ⊆ M
```
Uses: `temp_a`: `φ → G(P(φ))`

**Theorem 2** (`h_content_subset_implies_g_content_reverse`):
```
h_content(M) ⊆ K → g_content(K) ⊆ M
```
Uses: `past_temp_a`: `φ → H(F(φ))`

**Corollary**: `CanonicalR M K ↔ CanonicalR_past K M`

This means: **M sees K in the future if and only if K sees M in the past.** The canonical
future and past accessibility relations are exact converses of each other.

### The Duality Chain Applied to Covering

Given `CanonicalR M K`, `CanonicalR K W` (where `W = discreteImmediateSucc M`), we derive:

```
g_content(M) ⊆ K    (CanonicalR M K)
h_content(K) ⊆ M    (duality from above)
g_content(K) ⊆ W    (CanonicalR K W)
h_content(W) ⊆ K    (duality from above)
g_content(M) ⊆ W    (W contains seed ⊇ g_content(M))
h_content(W) ⊆ M    (duality from above)
```

These six inclusions completely constrain the "content transfer" between M, K, W.

### Why the Duality Alone Cannot Close the Proof

The duality chain creates a CYCLE:
- Applying duality to each inclusion recovers the others
- No new information is generated beyond these six inclusions
- An intermediate K satisfying all six inclusions IS consistent (not contradictory)

**Example of consistent intermediate**: Take K = M ∪ {φ} where φ ∈ M, ¬G(φ) ∈ M.
- g_content(M) ⊆ K ✓ (K extends M)
- h_content(K) ⊆ M ✓ (K's H-content goes to M by duality)
- g_content(K) ⊆ W ✓ (if G(φ) ∉ K, then φ ∉ g_content(K), consistent with ¬φ ∈ W)
- h_content(W) ⊆ K ✓ (W's H-content appears in K)
- All six inclusions satisfied with K ≠ M and K ≠ W

This confirms: **the duality chain alone cannot prove covering**.

---

## Why the Blocking Formula Proof Fails

The three sorries in `DiscreteSuccSeed.lean` represent a genuine mathematical gap:

### Sorry 525 (Line 525): `φ ∈ K, ¬G(φ) ∈ M, ¬φ ∈ W → ???`

Goal: Show this case is impossible (derive contradiction).

**From contrapositive of CanonicalR K W**: `¬φ ∈ W → φ ∉ W → G(φ) ∉ K`.

So `¬G(φ) ∈ K` (by MCS completeness of K).

Available facts: `{φ ∈ K, ¬G(φ) ∈ K, ¬G(φ) ∈ M, ¬φ ∈ W, g_content(M) ⊆ K, g_content(K) ⊆ W}`

**The gap**: `{φ, ¬G(φ)}` is consistent in the bimodal logic (holding φ now without it always
holding). No combination of these facts creates a contradiction. The sorry is **unfillable**
with the current approach.

### Sorry 562 (Line 562): `φ ∈ K, ¬G(φ) ∈ W, ¬G(φ) ∈ M, ¬G(φ) ∈ K → show φ ∈ W`

Goal: Show φ ∈ W given ¬G(φ) ∈ W (which by consistency means G(φ) ∉ W).

If G(φ) ∈ K: then φ ∈ g_content(K) ⊆ W ✓ (done!)
If G(φ) ∉ K (i.e., ¬G(φ) ∈ K): no path to φ ∈ W.

**The gap**: ¬G(φ) ∈ K with φ ∈ K and the inclusions don't force φ ∈ W.

### Sorry 595 (Line 595): Reverse direction `φ ∈ W → φ ∈ K` when ¬G(φ) ∈ M, ¬G(φ) ∈ W

This is the reverse set-inclusion direction. Same structural gap.

### Root Cause of All Three Sorries

**Information flow is one-directional**: CanonicalR propagates G-content FORWARD (M→K→W),
and the duality propagates H-content BACKWARD (W→K→M). But the blocking formula ¬φ ∨ ¬G(φ)
constrains W's G-commitment to φ, NOT K's membership of φ.

The fundamental issue: **There is no axiom in the TM system that forces K's arbitrary formula
membership to match W or M based on blocking formulas alone.**

---

## The Key Structural Gap: Semantic vs. Syntactic

From `DiscreteTimeline.lean` (documentation from task 979):

> "The gap is that F-obligations in M don't directly constrain which MCSes can be
> intermediate between M and a given witness W."
>
> "The full proof requires extracting the DF frame condition at the MCS level."

The DF axiom at the SEMANTIC level says: ∀x, if ∃y > x, then ∃z such that z is the
*immediate* successor of x. At the MCS/syntactic level, DF creates F(H(φ)) obligations,
but these F-obligations can be witnessed by ANY forward MCS, not necessarily by the
immediate successor.

This gap between the SEMANTIC frame condition and the SYNTACTIC MCS membership is the
fundamental obstacle.

---

## Most Promising New Direction: Modified Staged Construction

### The Core Insight

The incremental construction approach (Approach 1/C from both teammates) avoids the
semantic/syntactic gap by making covering hold **by construction**:

1. Instead of building ALL MCSs at once and trying to prove covering post-hoc
2. Build the timeline **incrementally**, where at each stage the immediate successor is
   defined as fresh (doesn't exist yet at that stage)
3. Covering holds because an "intermediate K" literally hasn't been constructed yet

### Why Phase 2 of Plan v4 was Blocked

`discreteStagedBuild` uses `forward_temporal_witness_seed = {φ} ∪ g_content(M)` at each stage.
This seed does NOT contain blocking formulas. So the "fresh" elements added at each stage
are F-witnesses, not immediate successors.

### The Fix: Change the Seed in the Staged Build

**Option A (Clean)**: Create a SEPARATE staged build that uses `discreteImmediateSuccSeed`:

```lean
-- New staged build using blocking formula seeds
def discreteStagedBuildImmediate (root : Set Formula) (h_root : SetMaximalConsistent root) :
    ℕ → Set StagedPoint :=
  -- At each stage, add immediate successors using discreteImmediateSuccSeed
  -- instead of forward_temporal_witness_seed
```

**Option B (Modified)**: Modify `processForwardObligation` in `StagedExecution.lean` to
use blocking formula seeds. Higher risk (touches existing infrastructure).

**Option C (Separate Timeline)**: Keep the existing staged build for completeness proofs
and create a PARALLEL `DiscreteTimelineImmediate` construction for the discrete timeline.
This avoids touching any existing code.

### Covering Holds by Construction in the New Build

With blocking formula seeds:
- At stage n: world M exists
- At stage n+1: add `discreteImmediateSucc M` (with blocking formula seed)
- **Covering is IMMEDIATE**: The successor is the ONLY new MCS added at stage n+1
- No intermediate K exists because K hasn't been added yet!

This is the Segerberg/Verbrugge approach from the literature.

### Effort Estimate

| Task | Effort | Risk |
|------|--------|------|
| Create `discreteStagedBuildImmediate` (Option A) | 6-8h | MEDIUM |
| Prove covering at each stage (trivial) | 2-3h | LOW |
| Prove colimit properties | 4-6h | MEDIUM |
| Delete axiom | 1h | LOW |
| **Total** | **13-18h** | **MEDIUM** |

---

## Alternative Direction: DF Frame Condition Direct Extraction

### The Bidirectional Symmetry as a Starting Point

The corollary above (CanonicalR M K ↔ CanonicalR_past K M) shows the canonical frame
has perfect symmetry. This property might enable a DIFFERENT proof:

**Proposed approach**: Use the DF axiom's F(H(φ)) obligations MORE CAREFULLY:

1. For any φ ∈ M: by `temp_a` (φ → G(P(φ))), we have G(P(φ)) ∈ M
2. So P(φ) ∈ g_content(M) ⊆ K, hence P(φ) ∈ K
3. P(φ) ∈ K means "sometimes in the past of K, φ held"
4. By `canonical_backward_P`: there exists N with CanonicalR_past K N and φ ∈ N
5. CanonicalR_past K N ↔ CanonicalR N K (by our symmetry corollary)
6. So: for any φ ∈ M, exists N with CanonicalR N K and φ ∈ N
7. The "past" of K contains witnesses for every φ ∈ M

**Can this force K = M?**: If the past witnesses N are uniquely determined to be M itself...

This requires: M is the UNIQUE "immediate predecessor" of K in some sense.
This is again the covering problem (in the backward direction), so it's circular.

**Assessment**: This direction doesn't bypass the problem, it just reformulates it.

---

## Decision Tree for Next Steps

```
1. Is DF frame condition extractable without the incremental construction?
   - Confirmed: Multiple attempts (h_content duality, DF membership, density inversion) all fail
   - Action: DO NOT pursue further direct extraction attempts

2. Can the blocking formula sorries be closed?
   - Confirmed: The sorry at 525 is unfillable with current approach
   - Action: DO NOT attempt to fill the sorries with minor modifications

3. Modified staged construction (Option A/C above)?
   - Status: NOT YET TRIED
   - Effort: 13-18h
   - Confidence: HIGH (literature-backed)
   - Recommendation: YES, pursue this

4. Accept axiom as documented debt?
   - Condition: Only if modified staged construction fails after full attempt
   - Status: LAST RESORT
```

---

## Recommendations

### Primary Recommendation: Modified Staged Construction

**Plan v6 should implement Option A**: Create `discreteStagedBuildImmediate` using blocking
formula seeds (not `forward_temporal_witness_seed`).

**Phases**:
1. [COMPLETED] Stage-indexed infrastructure (`IncrementalTimeline.lean`)
2. [NEW] Define `discreteStagedBuildImmediate` with blocking formula seed
3. [NEW] Prove `immediateSucc_at_stage`: immediate successor function at each stage
4. [NEW] Prove `covering_at_stage`: covering holds trivially (successor is fresh)
5. [NEW] Prove `colimit_iso_quot`: colimit isomorphic to `DiscreteTimelineQuot`
6. [NEW] Delete axiom, derive `LocallyFiniteOrder` from covering

**Key advantage**: No sorries expected — covering holds by freshness/construction, not by
a hard proof.

**Why this differs from plan v4 Phase 2 blocker**: Plan v4 tried to use `succ_at_stage`
derived from the EXISTING `discreteStagedBuild`. The new approach REPLACES that build
with a new one using blocking formula seeds, where each new element IS an immediate
successor by construction.

### Secondary Recommendation: Research the `discreteImmediateSuccSeed` Completeness

Before implementation, verify: does the `discreteStagedBuildImmediate` construction
produce ALL the same elements as `discreteStagedBuild`? This requires checking:
- Are all F/P-witnesses in the original build also in the new build?
- Does the new build still satisfy the truth lemma?

If not, a hybrid approach may be needed.

---

## References

- Segerberg (1970): Original incremental construction for discrete tense logic
- Verbrugge et al.: "Completeness by construction for tense logics of linear time"
- `WitnessSeed.lean`: `g_content_subset_implies_h_content_reverse` (Theorem 1)
- `WitnessSeed.lean`: `h_content_subset_implies_g_content_reverse` (Theorem 2)
- `DiscreteTimeline.lean`: Documentation of task 979 dead ends
- `DiscreteSuccSeed.lean`: Current blocking formula proof with 3 sorries (lines 525, 562, 595)
- `StagedExecution.lean`: `discreteStagedBuild` infrastructure to be adapted
- `research-001` through `research-006`: Previous task 981 research reports

---

## Teammate Contributions

| Teammate | Focus | Status | Confidence |
|----------|-------|--------|------------|
| A | Covering proof gap analysis | COMPLETED | HIGH |
| B | Alternative approaches survey | COMPLETED | MEDIUM |
| Lead (synthesis) | New duality analysis + recommendation | COMPLETED | HIGH |

### Conflicts Resolved

| Conflict | Resolution |
|----------|-----------|
| A recommends incremental as primary; B recommends blocking formula completion first | Resolved: blocking formula sorries are confirmed unfillable (sorry 525 analysis), incremental is primary |
| B rates "blocking formula completion" MEDIUM confidence | Resolved: 6+ research sessions and the task 979 codebase documentation confirm this is a dead end |

---

## Summary

The covering proof gap has been researched exhaustively across tasks 979 and 981. The
fundamental obstacle is structural: the DF frame condition (covering) cannot be extracted
from DF axiom membership in MCSes through algebraic/syntactic reasoning. The modified
staged construction (using `discreteImmediateSuccSeed` instead of
`forward_temporal_witness_seed`) is the one mathematically sound path that hasn't been
blocked. It should be the focus of the next implementation plan.
