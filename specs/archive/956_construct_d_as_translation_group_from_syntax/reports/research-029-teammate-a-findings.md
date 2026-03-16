# Teammate A Findings: Primary Motives Analysis

**Task**: 956 - Construct D as translation group from syntax
**Session**: sess_1773118591_25188
**Run**: 029
**Date**: 2026-03-09
**Role**: Primary motives analysis -- trace original intent and drift

---

## Original Task Intent

### The Philosophical Goal

Task 956 was conceived as a **foundational replacement** for the hardcoded `D = Int` approach used in Tasks 951/954/955. The original intent, articulated in research-001 with extraordinary clarity, is a **10-step pipeline** where the duration group D is not assumed or imported but **emerges from pure syntax**:

```
Consistent set -> MCS origin (Lindenbaum) -> Timeline T of reachable MCSs
-> D = Aut+(T) (translations) -> eval_0 : D ~ T (origin bijection)
-> Linearly ordered abelian group -> task_rel = group action
-> Canonical model -> Truth lemma -> Completeness
```

The core philosophical claim (research-001, Section 7) is that the old `D = Int` approach creates three interlocking problems:

1. **The dovetailing chain problem**: Building a Z-indexed chain of MCSs requires F-persistence (F-formula witnesses surviving through Lindenbaum extensions), which is fundamentally hard.
2. **The successor problem**: Proving coverness (no gaps) on the BidirectionalQuotient is unprovable because Lindenbaum creates intermediate MCSs.
3. **The artificial mismatch**: With D = Int imposed externally, one must separately construct a chain matching Z's structure, then bridge via `task_rel` -- fighting a mismatch between the imposed algebraic structure and the natural syntactic structure.

The translation group approach claims to resolve ALL three: T is not a step-by-step chain but a completed totality; D is not defined via successor/predecessor but via composition of bijections; there is no mismatch because D IS the translation group of T.

### Why "Supersedes Hardcoded D = Int"

The task description explicitly says it supersedes Task 954 ("hardcoded Int refactor") and Task 955 ("CanonicalR task_rel"). The motivation is that:

- **Int is an external import**: It brings algebraic structure (AddCommGroup, LinearOrder) from outside the logic, rather than deriving it from the temporal axioms.
- **task_rel was trivial**: The existing `task_rel := fun _ _ _ => True` means D's group structure is never exercised in proofs -- it exists only to satisfy the `TaskFrame` type signature.
- **The translation group is intrinsic**: D = Aut+(T) would mean D's structure is a THEOREM about the canonical model, not an assumption fed into it.

### What "Translation Group from Syntax" Actually Means

The phrase means: starting from the axioms and derivation rules of TM (the bimodal temporal-modal logic), construct ALL the algebraic infrastructure (group, order, abelianness, torsor) through purely syntactic arguments. Specifically:

1. Lindenbaum extends a consistent set to an MCS (pure logic)
2. The existence lemma populates the timeline with MCSs reachable via F/P-witnesses (pure logic)
3. The temporal axioms force this timeline to be a connected linear order (axiom consequences)
4. The automorphism group of this order IS the duration group (mathematical construction on a syntactically-derived object)
5. The origin bijection makes D a linearly ordered abelian group (mathematical theorem)
6. task_rel is the group action -- not imposed, but discovered

The critical philosophical point: "from syntax" means that if you change the temporal axioms, you get a DIFFERENT D. For TM with density, D should be Q. For TM with discreteness, D should be Z. The construction derives D; it does not assume it.

---

## Drift Analysis

### Phase 1: Immediate Discovery of Hard Obstacles (research-003 through research-004)

The drift begins almost immediately. By research-003, it is established that:

- **CanonicalR is NOT antisymmetric** -- the preorder on MCSs must be quotiented via Antisymmetrization.
- The timeline T must be `BidirectionalQuotient`, not raw MCSs.

By research-004, a CRITICAL discovery is made:

- **Freeness of Aut+(T) fails for general linear orders** -- the example `x -> 2x` on Q fixes 0 but is not the identity.
- **Transitivity (homogeneity) is non-trivial** -- it requires showing T is isomorphic to Z or Q.
- Research-004 already recommends abandoning Aut+(T) in favor of a "direct torsor construction."

**Assessment**: The original Aut+(T) approach was mathematically elegant but based on a mistaken assumption about freeness. The project discovered this within its first 4 research reports but did not fully abandon the approach.

### Phase 2: Exploration of Alternatives (research-005 through research-014)

Over reports 5-14, the project explores multiple paths:

- Discreteness axioms (DP/DF) to make T isomorphic to Z (research-009, 010)
- HomogeneousTimeline typeclass to defer the Z-vs-Q choice (research-009)
- Back-and-forth arguments for homogeneity (research-010)
- TranslationGroup.lean is created with `D = Additive(T ≃o T)`, proving `AddGroup` but deferring `AddCommGroup`, `LinearOrder`, and `AddTorsor` (the three hardest items)

**Key drift**: The project moves from "D emerges from syntax via Aut+(T)" to "D is defined as Aut+(T), but we defer proving most of its required properties." The deferral list grows:
- AddCommGroup (requires Holder's theorem)
- LinearOrder on D (requires freeness)
- AddTorsor (requires homogeneity)

Each of these deferred items IS the original task. Deferring them all means the task is not progressing -- it is being subdivided into the same unsolved problems.

### Phase 3: Infrastructure Blockers (research-015 through research-020)

Reports 15-20 discover progressively more severe blockers:

- **DenselyOrdered on BidirectionalQuotient has 4 sorries** (research-017): Lindenbaum collapse prevents constructing intermediate MCSs.
- **Countable BidirectionalQuotient is FALSE** (research-018): CanonicalR edges reach uncountably many MCSs.
- **Freeness is likely false for full Aut+(T)** (research-021 teammate A): Non-identity order automorphisms CAN have fixed points.

By research-019, a "strategic reassessment" acknowledges that the approach requires solving 5+ hard problems (countability, density, Holder, freeness, homogeneity), and recommends either:
- Strategy E: Set D = Q directly (rejected as "importing" D)
- Strategy K-Relational: Prove completeness for relational frames, then characterize D via Cantor's theorem

### Phase 4: Pragmatic Pivots (research-021 through research-028)

The project pivots multiple times:

1. **Strategy K-Relational** (research-020/021): Prove relational completeness, use Cantor's theorem. Not fully pursued.
2. **Seriality axioms** (research-024): Add `F(neg bot)` and `P(neg bot)` as axioms to prevent endpoint collapse.
3. **Product domain `RestrictedQuotient x Q`** (research-025, plan v007): Sidestep the G-closed MCS singleton problem by "bulldozing" with Q. This introduces Q as a component of the domain.
4. **Canonical Int-indexed FMCS** (research-028, plan v008): Return to `D = Int` with non-constant families, focusing on resolving `fully_saturated_bfmcs_exists_int`.

**The final drift**: Plan v008 explicitly says "This plan abandons the product domain approach and returns to the canonical Int-indexed FMCS architecture from CanonicalConstruction.lean." This is a return to `D = Int` -- the very thing task 956 was created to supersede.

---

## Lost Elements

### 1. D Emerges from Syntax (Completely Lost)

The foundational claim of task 956 -- that D should emerge from the temporal axioms rather than being imported -- has been entirely abandoned by plan v008. The plan uses `D = Int` with the same `CanonicalConstruction.lean` infrastructure that predates task 956. The only change from the pre-task-956 state is the addition of seriality axioms and some archival.

### 2. task_rel as Group Action (Completely Lost)

Research-001 describes task_rel as "the group action of D on T" -- where `task_rel(d)(w) = d(w)` maps each duration to the corresponding translation of the timeline. This was supposed to replace `task_rel := fun _ _ _ => True`. Neither plan v007 nor v008 constructs a non-trivial task_rel. The trivial task_rel remains.

### 3. The Torsor Structure (Completely Lost)

Research-001 describes T as a torsor for D, with the origin w_0 providing the identification D ~ T. This rich algebraic structure -- the "group that forgot its identity" becoming a group again via the designated origin -- is absent from all recent plans.

### 4. The eval_0 Bijection (Completely Lost)

The origin bijection `eval_0 : D -> T` defined by `eval_0(d) = d(w_0)` was supposed to be the key bridge making D a concrete group. No recent plan attempts to construct this map.

### 5. The Philosophical Narrative (Completely Lost)

The original task told a coherent mathematical story: consistent set -> MCS -> timeline -> translation group -> ordered abelian group -> canonical model -> completeness. Each step was motivated and each piece emerged from the previous. The recent plans are purely tactical: "resolve this sorry," "archive that file," "change D from Q to Int."

### 6. The Independence from Discreteness/Density (Partially Lost)

Research-001 envisions D as arising from WHATEVER the temporal axioms produce -- discrete, dense, or otherwise. Research-010 established that this generality is impossible (only Z or Q are homogeneous countable linear orders without endpoints), but the choice between them was supposed to be a THEOREM, not an assumption. With `D = Int` hardcoded in plan v008, discreteness is assumed, not derived.

---

## Key Insights

- **The original task was mathematically ambitious but flawed in its central assumption**: freeness of Aut+(T) does not hold for general linear orders, and was discovered to fail by research-004. Everything after that is scrambling for alternatives.

- **The fundamental tension is between TaskFrame's type constraints and the canonical model's natural structure**: `truth_at` requires `AddCommGroup D`, `LinearOrder D`, `IsOrderedAddMonoid D`. The canonical model naturally lives over `CanonicalMCS` (all MCSs), which has none of these. Every approach either imports algebraic structure (D = Int, D = Q) or tries to derive it (Aut+(T), translation group) -- and the latter has been shown to face multiple hard blockers.

- **Plan v008 is a regression to the pre-task-956 status quo**: It uses `D = Int`, `CanonicalConstruction.lean`, and the same F-persistence sorry. The only improvements over the starting point are: (a) seriality axioms added, (b) some infrastructure archived. These are housekeeping, not the task's objective.

- **The user's observation that plan v008 is "on completely the wrong track" is correct**: It does not attempt to construct D from syntax. It uses hardcoded `D = Int` and focuses on resolving a sorry that existed before task 956 was created.

- **The original research-001 pipeline remains mathematically correct IN PRINCIPLE**: The issue is that Steps 4-7 (Aut+(T), eval_0, pullback order, abelianness) are each hard theorems. The project gave up on them individually but never articulated a single coherent alternative that preserves the "D from syntax" goal.

- **The closest approach to the original intent was Strategy K-Relational** (research-020/021): prove relational completeness without TaskFrame, then DISCOVER that the canonical model is Q-isomorphic via Cantor's theorem, and inherit Q's algebraic structure. This preserves the "D is discovered, not imported" narrative while sidestepping all the Aut+(T) blockers. But it was never pursued to completion.

- **The "G-closed MCS" problem (research-025) is real but orthogonal**: G-closed MCSs cause singleton fragments, but this is a problem for ANY approach, not just the translation group. The seriality axioms were a valid fix.

- **28 research reports and 8 plan versions have been produced without resolving the original objective**. The task has accumulated enormous amounts of analysis but has been continuously diverted by tactical obstacles, each leading to a pivot that moves further from the original goal.

## Confidence Level: high

The analysis is based on direct reading of all 28+ research reports, 8 plan versions, and the original task description. The drift pattern is clear and well-documented in the reports themselves. The mathematical obstacles (freeness, homogeneity, Holder) are genuine and well-established. The conclusion that recent plans abandon the original intent is straightforward.
