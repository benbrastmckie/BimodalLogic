# Teammate B Findings: ROAD_MAP.md Update Plan

**Task**: 956 - Construct D as translation group from syntax
**Date**: 2026-03-09
**Session**: sess_1773118591_25188
**Role**: Teammate B -- ROAD_MAP.md update plan

---

## Current ROAD_MAP.md Analysis

### What It Says About Task 956

The ROAD_MAP.md does not mention task 956 by number anywhere. It has no dedicated section, ambition, or strategy entry for the "D from syntax" goal. The closest related content:

1. **Strategy: Indexed MCS Family Approach** (ACTIVE) -- discusses using FMCS indexed by time, but frames it in terms of temporal coherence, not in terms of constructing D from syntax.

2. **Sorry Debt Status** -- lists 3 sorries in `fully_saturated_bfmcs_exists_int` and `DovetailingChain.lean`, which are the technical blockers task 956 has been cycling around.

3. **Ambition: Proof Economy** -- mentions the 3 remaining sorries and the goal of sorry-free standard completeness. This is the closest to stating task 956's goal, but it frames the problem as "eliminate sorries" rather than "construct D from syntax."

4. **Dead Ends** -- documents 8 dead ends, several of which relate to task 956's explorations (constant witness family, single-family BFMCS, non-standard validity, CanonicalReachable). However, these were documented BEFORE task 956 began its own trajectory of explorations (product domain, TranslationGroup, K-Relational, canonical pipeline).

### What It Lacks

1. **No articulation of what "D from syntax" means** -- The phrase appears only in TODO.md's task title. ROAD_MAP.md never defines what the philosophical/mathematical goal is, what "from syntax" entails, or why it matters beyond sorry elimination.

2. **No documentation of task 956's own dead ends** -- The task has generated 28 research reports exploring at least 6 distinct approaches, several of which have been conclusively abandoned. None of these are in ROAD_MAP.md's Dead Ends section.

3. **No distinction between "completeness" and "D construction"** -- ROAD_MAP.md treats sorry-free completeness as the goal. Task 956's title suggests a different, more ambitious goal: constructing D as a group that EMERGES from syntax. These are potentially different goals, and the conflation has caused drift.

4. **No documentation of the `bmcs_truth_at` vs `truth_at` resolution** -- Research-028 conclusively established that `canonical_truth_lemma` (using `truth_at` directly) is the correct path and `bmcs_truth_at` should be archived. This architectural decision is not reflected in ROAD_MAP.md.

5. **No documentation of the reflexive-vs-irreflexive semantics decision** -- The switch to irreflexive semantics was a fundamental architectural decision, documented only in Truth.lean comments and research-024/026. ROAD_MAP.md does not record this or its consequences.

6. **No documentation of the seriality axiom addition** -- Research-024 recommended and Phase 0 implemented adding `seriality_future` and `seriality_past` axioms. This changed the axiom system but is not in ROAD_MAP.md.

---

## Proposed Updates

### Section 1: New Strategy Entry for Task 956

Add after the existing "Algebraic Verification Path" strategy:

```markdown
### Strategy: Duration Group from Syntax (Task 956)

**Status**: ACTIVE
**Started**: 2026-03-06
**Hypothesis**: The temporal duration group D can be constructed entirely from the syntactic canonical model as the automorphism group of the canonical timeline, without assuming D = Int or D = Q as primitives.

*Rationale*: The current completeness proof uses D = Int with `task_rel = True` (trivial). While this achieves completeness, it "imports" the algebraic structure of Int rather than deriving it from the logic. A syntactically-derived D would demonstrate that the temporal structure is a consequence of the axioms, not an assumption.

**Approach**:
Multiple approaches have been explored:
1. TranslationGroup (Aut+(T)) -- AddGroup proven, but AddCommGroup requires Holder's theorem chain (freeness + Archimedean), both hard
2. K-Relational (Cantor characterization) -- prove canonical timeline is countable dense without endpoints, then apply Cantor's theorem for Q-isomorphism
3. Canonical Int pipeline -- use existing `canonical_truth_lemma` with Int-indexed FMCS, resolve `fully_saturated_bfmcs_exists_int` sorry
4. Product domain (Q x RestrictedQuotient) -- abandoned, constant-MCS histories cause temporal trivialization

Current focus is approach 3 (canonical Int pipeline), per implementation-008.

**Outcomes**:
- TranslationGroup.lean: AddGroup proven sorry-free (281 lines), but AddCommGroup/LinearOrder/AddTorsor deferred and confirmed hard
- Seriality axioms (`F(neg bot)`, `P(neg bot)`) added to axiom system
- Product domain approach conclusively abandoned (temporal trivialization)
- `bmcs_truth_at` identified as redundant, archival planned
- `canonical_truth_lemma` confirmed as correct truth lemma (sorry-free)

**References**:
- [TranslationGroup.lean](Theories/Bimodal/Metalogic/Bundle/TranslationGroup.lean) - Aut+(T) construction
- [CanonicalConstruction.lean](Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean) - Sorry-free truth lemma
- [Task 956 reports](specs/956_construct_d_as_translation_group_from_syntax/reports/) - 28+ research reports
- [implementation-008.md](specs/956_construct_d_as_translation_group_from_syntax/plans/implementation-008.md) - Current plan

---
```

### Section 2: New Ambition Entry -- Clarifying the Goal

Add a new ambition that distinguishes the two goals:

```markdown
### Ambition: Syntactically-Derived Duration Domain

**Priority**: MEDIUM
**Timeframe**: LONG-TERM

*Rationale*: The temporal duration group D is currently imported as Int (or Q) rather than constructed from the logic's axioms. A syntactically-derived D would be a stronger mathematical result, demonstrating that the temporal structure is a theorem about the axiom system, not an assumption.

**Success Criteria**:
- [ ] D constructed as an ordered abelian group from canonical MCS structure
- [ ] D proven isomorphic to (Q, +, <) under density + seriality axioms
- [ ] Completeness theorem uses syntactically-derived D (not Int)
- [ ] task_rel is non-trivial (encodes actual displacement structure)

**Description**:
This ambition goes BEYOND sorry-free completeness (which can be achieved with D = Int and task_rel = True). It asks whether D can EMERGE from the axioms rather than being postulated. The key mathematical question is whether the canonical timeline of MCSes, ordered by CanonicalR, forms a structure whose automorphism group (or a characterized isomorphism target like Q) can serve as D with a meaningful task_rel.

**Relationship to Proof Economy**:
- Proof Economy asks: can we eliminate the 3 remaining sorries?
- This ambition asks: can we also make D non-imported?
- These are INDEPENDENT goals. Sorry-free completeness with D = Int is valuable even without syntactic D.
- Syntactic D is a mathematical elegance goal, not a sorry-elimination goal.

**Related Tasks**: Task 956
**References**:
- [TranslationGroup.lean](Theories/Bimodal/Metalogic/Bundle/TranslationGroup.lean) - Partial construction
- [research-021.md](specs/956_construct_d_as_translation_group_from_syntax/reports/research-021.md) - Holder/freeness/formal displacement analysis
- [research-023.md](specs/956_construct_d_as_translation_group_from_syntax/reports/research-023.md) - K-Relational pipeline

---
```

### Section 3: New Dead Ends from Task 956

Add these to the Dead Ends section:

```markdown
### Dead End: Product Domain Temporal Trivialization

**Status**: ABANDONED
**Tried**: 2026-03-08 to 2026-03-09
**Related Tasks**: Task 956 (implementation-007)

*Rationale*: Attempted to use `TemporalDomain := RestrictedQuotient x Q` as the duration domain, leveraging Q's algebraic structure while the quotient provides MCS-level detail.

**What We Tried**:
Constructed `CanonicalProductFrame : TaskFrame Q` with constant-MCS histories `tau(t) = ([M], t)` where the MCS component is fixed. Built `ShiftClosedProductOmega` for shift closure.

**Why It Failed**:
Constant-MCS histories cause temporal trivialization: `G(phi)` at `([M], q)` quantifies only over points `([M], q')` with `q' > q`, all of which have the SAME MCS `M`. So `G(phi)` reduces to `phi in M`, collapsing temporal semantics. This is structurally identical to the "Constant Witness Family" dead end but at the frame level rather than the BFMCS level.

**Evidence**:
- [research-028.md Finding 6](specs/956_construct_d_as_translation_group_from_syntax/reports/research-028.md) - Temporal trivialization analysis
- [TemporalDomain.lean](Theories/Bimodal/Metalogic/Bundle/TemporalDomain.lean) - Implementation (to be archived)

**Lesson**:
Any approach using constant-family or constant-MCS histories trivializes temporal operators. Non-constant families (where `fam.mcs t` varies with `t`) are essential for temporal semantics.

**Superseded By**: Canonical Int pipeline (implementation-008) using non-constant FMCS from CanonicalConstruction.lean

---

### Dead End: TranslationGroup Holder's Theorem Chain

**Status**: BLOCKED
**Tried**: 2026-03-06 to 2026-03-09
**Related Tasks**: Task 956

*Rationale*: Attempted to construct D = Additive(Aut+(T)) where T is the BidirectionalQuotient, proving it satisfies AddCommGroup via Holder's theorem for Archimedean ordered groups.

**What We Tried**:
Defined `TranslationGroup` as the additive group of order-preserving automorphisms of T. Proved `AddGroup` (281 lines, sorry-free). Attempted to prove `LinearOrder` (requires freeness), `Archimedean` (requires bounded displacement), and `AddCommGroup` (via Holder's theorem from Archimedean).

**Why It Failed**:
Four interleaved hard requirements, each confirmed as fundamental:
1. **Freeness**: Full Aut+(T) can have non-identity elements with fixed points. Restricting to translation subgroup makes freeness definitional but relocates the problem to transitivity.
2. **Transitivity/Homogeneity**: For Trans(T) to act transitively requires AddTorsor structure -- the hardest deferred item.
3. **Archimedean property**: Requires freeness + homogeneity together (measurement theory entanglement).
4. **AddCommGroup**: Holder's theorem gives this from Archimedean, but each prerequisite is independently hard.

Formal displacements (D = Free(F,P) / equivalence) reduce to the same mathematics with 500+ additional lines of overhead.

**Evidence**:
- [TranslationGroup.lean](Theories/Bimodal/Metalogic/Bundle/TranslationGroup.lean) - AddGroup proven, rest deferred
- [research-021.md](specs/956_construct_d_as_translation_group_from_syntax/reports/research-021.md) - Three-teammate analysis confirming blockers
- [research-022.md](specs/956_construct_d_as_translation_group_from_syntax/reports/research-022.md) - Homogeneous subgroup analysis

**Lesson**:
The automorphism group approach requires proving homogeneity of the canonical timeline, which is mathematically equivalent to the AddTorsor requirement. Freeness and homogeneity are entangled -- solving one does not help with the other.

**Superseded By**: K-Relational strategy (using Cantor characterization instead of automorphism group) or canonical Int pipeline (sidestepping D construction entirely)

---

### Dead End: Canonical Int-Indexed FMCS via Fragment Chain (F-Persistence)

**Status**: BLOCKED
**Tried**: 2026-02-25 to 2026-03-09
**Related Tasks**: Task 956 (Phases 2-4 of various plans)

*Rationale*: Attempted to build `FMCS Int` from the bidirectional fragment by mapping `Int -> BidirectionalFragment` via `buildFragmentChain`, then proving temporal coherence.

**What We Tried**:
`FragmentCompleteness.lean` builds `fragmentChainFMCS : FMCS Int` from a monotone chain `Int -> BidirectionalFragment`. The chain visits fragment elements in order, constructing an Int-indexed family.

**Why It Failed**:
The F-persistence problem: when `F(phi) in chain(t).world`, there exists a fragment element `w > chain(t)` with `phi in w.world` (from sorry-free `fragmentFMCS`). But `w` may not equal `chain(s)` for any `s > t` -- the Int chain may "jump over" the witness `w`. The 2 sorries in `FragmentCompleteness.lean` (`fragmentChainFMCS_forward_F`, `fragmentChainFMCS_backward_P`) encode this exact obstacle.

**Evidence**:
- [FragmentCompleteness.lean](Theories/Bimodal/Metalogic/Bundle/FragmentCompleteness.lean) - 2 sorries at lines 414, 471
- [research-028.md Finding 5](specs/956_construct_d_as_translation_group_from_syntax/reports/research-028.md) - Architecture analysis

**Lesson**:
Embedding an uncountable/rich fragment into Int via a single monotone chain cannot guarantee visiting all temporal witnesses. Alternative chain constructions (omega-squared, priority queues, or compactness arguments) may resolve this.

**Superseded By**: Active investigation in implementation-008 Phase 2

---

### Dead End: Reflexive G/H Semantics Switch

**Status**: ABANDONED
**Tried**: 2026-03-09
**Related Tasks**: Task 956 (research-026)

*Rationale*: Investigated whether switching from irreflexive (`<`) to reflexive (`<=`) temporal semantics would resolve the truth lemma blockers.

**What We Tried**:
Analyzed the full impact of changing `truth_at` to use `<=` instead of `<` for G/H operators.

**Why It Failed**:
Reflexive semantics does NOT solve the backward direction of the truth lemma (the actual blocker). Additionally, it causes severe collateral damage:
- Density axiom `F(phi) -> F(F(phi))` becomes trivially valid (loses frame-distinguishing content)
- temp_4 becomes redundant (derivable from transitivity alone)
- temp_a becomes trivially valid
- Seriality axioms (just added) become pointless
- 7+ soundness proofs need revision, 2 new axioms needed
- Contradicts the deliberate architectural decision for irreflexive semantics

**Evidence**:
- [research-026.md](specs/956_construct_d_as_translation_group_from_syntax/reports/research-026.md) - Complete consequence analysis

**Lesson**:
Reflexive vs irreflexive is a logic-level decision, not a proof-strategy decision. Switching semantics changes which LOGIC is being formalized. The truth lemma blocker is a construction problem (building adequate histories/families), not a semantics problem.

**Superseded By**: Continue with irreflexive semantics; solve truth lemma via construction

---
```

### Section 4: Architectural Decisions to Document

Add a new subsection under "Current State" or as a standalone section:

```markdown
### Key Architectural Decisions

| Decision | Date | Rationale | Reference |
|----------|------|-----------|-----------|
| Irreflexive G/H semantics | ~2026-02 | Supports density proof architecture; standard in modern temporal logic | Truth.lean header, research-024 |
| Seriality axioms added | 2026-03-09 | Replaces T-axioms for NoMaxOrder/NoMinOrder proofs under irreflexive semantics | research-024, implementation-006 |
| `canonical_truth_lemma` as primary truth lemma | 2026-03-09 | Direct `truth_at` connection; `bmcs_truth_at` identified as redundant | research-028 |
| `bmcs_truth_at` infrastructure planned for archival | 2026-03-09 | Redundant with `canonical_truth_lemma`; creates unnecessary indirection | research-028, implementation-008 Phase 0 |
| `task_rel = True` (trivial) accepted for now | 2026-03-09 | Non-trivial task_rel is a separate ambition from sorry-free completeness | research-021 Finding 1.5 |
```

### Section 5: Update Existing Content

#### 5a: Update Sorry Debt Status

The current sorry debt section lists 3 sorries. This needs updating to reflect the seriality axiom addition and current build state:

```markdown
### Sorry Debt Status

**Current State** (as of 2026-03-09): **3 sorries** in active Metalogic/ (excluding Boneyard)

| File | Count | Description |
|------|-------|-------------|
| Bundle/TemporalCoherentConstruction.lean:600 | 1 | `fully_saturated_bfmcs_exists_int` - combines temporal + modal saturation |
| Bundle/FragmentCompleteness.lean:414 | 1 | `fragmentChainFMCS_forward_F` - F-witness in Int chain |
| Bundle/FragmentCompleteness.lean:471 | 1 | `fragmentChainFMCS_backward_P` - P-witness in Int chain |

**Note**: DovetailingChain.lean sorries may have been subsumed by FragmentCompleteness.lean. Verify with `grep -rn "sorry" Theories/Bimodal/Metalogic --include="*.lean" | grep -v Boneyard`.

**Architecture note**: The 3 sorries are all in the Int-indexed FMCS construction. The `canonical_truth_lemma` (connecting MCS membership to `truth_at`) is sorry-free. The remaining gap is constructing the `BFMCS Int` that `canonical_truth_lemma` requires as input.
```

#### 5b: Update Ambition: Proof Economy

Add to the Proof Economy ambition:

```markdown
**Note (2026-03-09)**: Task 956 has been exploring whether the D construction itself could eliminate these sorries. The current assessment (implementation-008) is that the canonical Int pipeline with `CanonicalConstruction.lean`'s `canonical_truth_lemma` is the correct path. The remaining work is resolving the F-persistence problem in Int chain construction. The "D from syntax" goal (TranslationGroup, K-Relational) is a separate, longer-term ambition and is NOT required for sorry elimination.
```

#### 5c: Update Indexed MCS Family Strategy Status

```markdown
### Strategy: Indexed MCS Family Approach

**Status**: ACTIVE (refined)
...

**Updated Outcomes** (2026-03-09):
- `canonical_truth_lemma` proven sorry-free in `CanonicalConstruction.lean` (Task 945)
- `bmcs_truth_at` identified as redundant intermediate, archival planned
- Product domain approach (TemporalDomain.lean) abandoned due to temporal trivialization
- Seriality axioms added to support irreflexive semantics
- Remaining blocker: F-persistence in Int chain (`fragmentChainFMCS_forward_F`)
```

---

## Section 6: The ACTUAL Mathematical Goal -- Clarification

The ROAD_MAP.md should explicitly distinguish three related but distinct goals:

### Goal A: Sorry-Free Standard Completeness
- **What**: Prove `valid phi -> derivable phi` using standard `truth_at` semantics, with zero sorries
- **Current blocker**: `fully_saturated_bfmcs_exists_int` (constructing temporally coherent + modally saturated BFMCS over Int)
- **Status**: 3 sorries remain
- **Approach**: Canonical Int pipeline (implementation-008)
- **D used**: Int (imported, not constructed)
- **task_rel**: Trivial (`fun _ _ _ => True`)

### Goal B: D Constructed from Syntax
- **What**: Define D as an algebraic object (ordered abelian group) that EMERGES from the axiom system rather than being imported
- **Candidate constructions**: Aut+(T), Cantor isomorphism to Q, formal displacements
- **Current blockers**: Holder's theorem chain (freeness, homogeneity, Archimedean), density proof (4 sorries in DenseQuotient.lean)
- **Status**: Explored but unresolved; all approaches face fundamental obstacles
- **Independent from Goal A**: You can achieve sorry-free completeness without constructing D from syntax

### Goal C: Non-Trivial task_rel
- **What**: Define `task_rel` that encodes actual displacement structure (not `True`)
- **Depends on**: Both Goal A (completeness) and Goal B (knowing what D is)
- **Status**: Not started; requires Goal B as prerequisite
- **Significance**: Would make the TaskFrame formalization faithfully represent the intended temporal structure

The ROAD_MAP.md should make clear that **Goal A is the current priority** and that Goals B and C are separate, longer-term ambitions that do not block Goal A.

---

## Rationale

### Why These Updates Help

1. **Prevents drift**: By separating Goals A/B/C explicitly, future work sessions will not conflate sorry elimination with D construction. The current 28-report trajectory shows repeated drift between these goals.

2. **Documents dead ends**: Task 956 has explored product domain, TranslationGroup, K-Relational, reflexive semantics, and canonical Int pipeline approaches. Without documenting these in ROAD_MAP.md, future sessions may re-explore them.

3. **Records architectural decisions**: The irreflexive semantics choice, seriality axiom addition, and `bmcs_truth_at` archival decision are project-level decisions that belong in ROAD_MAP.md, not just in research reports.

4. **Clarifies the actual goal**: The task title "Construct D as translation group from syntax" suggests Goal B, but the actual urgency is Goal A (sorry-free completeness). Making this explicit prevents over-investment in the harder goal when the easier one is achievable.

5. **Provides guardrails**: Future work can check ROAD_MAP.md dead ends before exploring approaches that have already been conclusively abandoned. The current dead ends section does not cover task 956's explorations at all.

### What These Updates Do NOT Do

- They do not resolve any technical blockers
- They do not choose between approaches for Goal A
- They do not deprecate TranslationGroup.lean or other infrastructure (that is implementation work)

---

## Confidence Level: high

The analysis is based on reading all 28 research reports, the current ROAD_MAP.md, all 8 implementation plans, and the relevant codebase files. The proposed updates are conservative -- they document what has already been established rather than proposing new directions. The three-goal decomposition follows directly from the research trajectory and resolves the conflation that has caused repeated drift.
