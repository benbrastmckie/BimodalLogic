# Implementation Plan: Purely Syntactic D Construction

- **Task**: 956 - Construct D as translation group from syntax
- **Status**: [NOT STARTED]
- **Effort**: 15-25 hours
- **Dependencies**: None
- **Research Inputs**: research-029.md (goal decomposition), research-020/021/023 (K-Relational strategy)
- **Artifacts**: plans/implementation-010.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true
- **Supersedes**: implementation-009.md (v009 accepted D=Int for "Goal A"; this plan rejects that)

## Critical Constraint

**IMPORTING Int OR Rat IS STRICTLY FORBIDDEN.**

Everything must be constructed from pure syntax:
- **D** must emerge from the temporal axioms, not be imported
- **Density** of D must emerge from the density axioms (DN)
- **Discreteness** of D would emerge from discreteness axioms (DP/DF) if added
- **task_rel** must encode the actual displacement structure, not be trivial

This plan abandons the "Goal A vs Goal B" framing from v009. There is only ONE acceptable goal: **D from pure syntax with non-trivial task_rel**.

## Overview

Task 956 explored multiple approaches over 28 research reports. Every approach that imports Int or Rat has failed to meet the task's original intent. This revision:

1. **Updates ROAD_MAP.md** to document that Int/Rat imports are forbidden
2. **Archives ALL approaches** that depend on Int, Rat, or trivial task_rel
3. **Constructs D from pure syntax** using the K-Relational strategy
4. **Constructs non-trivial task_rel** as the actual displacement in the canonical timeline

### The K-Relational Strategy (research-020/021/023)

The viable path forward:
1. Prove relational completeness WITHOUT TaskFrame (avoiding D entirely)
2. Show canonical timeline T is countable dense without endpoints (from seriality + density axioms)
3. Apply Cantor's theorem: every countable dense linear order without endpoints is isomorphic to Q
4. **D emerges as (Q, +)** from the isomorphism - discovered, not imported
5. **task_rel(d)(w) = e⁻¹(e(w) + d)** where e : T → Q is the Cantor isomorphism

D is "Q" only because the axioms FORCE T to have that structure. Change the axioms (add discreteness), and D would be "Z" - both emerge from syntax.

## Goals & Non-Goals

**Goals**:
- Enforce "no Int/Rat imports" constraint in ROAD_MAP.md
- Archive ALL Int-dependent and Rat-dependent completeness approaches
- Construct D as the group that emerges from canonical timeline
- Construct task_rel as actual displacement (non-trivial)
- Complete representation theorem with purely syntactic foundations

**Non-Goals**:
- Using D=Int or D=Rat directly (FORBIDDEN)
- Using `task_rel = True` (defeats purpose)
- Hardcoding algebraic structure from outside the logic

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Density proof from axioms blocked | HIGH | MEDIUM | Research-015/024 analyzed paths; seriality axioms provide NoMax/NoMin |
| Cantor isomorphism construction hard | HIGH | MEDIUM | Mathlib has Cantor's theorem infrastructure |
| Archival breaks too much | MEDIUM | LOW | Verify build after each archival step |
| K-Relational has hidden obstacles | MEDIUM | MEDIUM | Research-020/021/023 identified single blocker: density proof |

## Implementation Phases

### Phase 0: ROAD_MAP.md Updates [NOT STARTED]

- **Dependencies**: None
- **Goal**: Document the strict "no Int/Rat imports" constraint and archive decisions

**Tasks**:
- [ ] Add Strategy entry documenting task 956's exploration and the STRICT FORBIDDEN conclusion
- [ ] Add Ambition: "Syntactically-Derived Duration Domain" as PRIMARY goal (not deferred)
- [ ] Add Dead End: "All Int/Rat Import Approaches" (covers v008/v009 Goal A, CanonicalConstruction with D=Int)
- [ ] Add Dead End: "Product Domain Temporal Trivialization"
- [ ] Add Dead End: "TranslationGroup Holder's Theorem Chain"
- [ ] Add Dead End: "Fragment Chain F-Persistence"
- [ ] Add Dead End: "Reflexive G/H Semantics Switch"
- [ ] Add Architectural Decisions:
  - "D must emerge from syntax" - NO Int/Rat imports
  - "Irreflexive G/H semantics" - supports density proof architecture
  - "Seriality axioms F(¬⊥)/P(¬⊥)" - derive NoMaxOrder/NoMinOrder
  - "K-Relational strategy" - relational completeness + Cantor iso
- [ ] Update Proof Economy section: D-from-syntax is the ONLY acceptable path
- [ ] Update status header: "Standard Completeness IN PROGRESS (pure syntax constraint)"

**Timing**: 2.5 hours

**Verification**:
- ROAD_MAP.md explicitly states Int/Rat imports are forbidden
- All 5 dead ends documented with lessons
- K-Relational identified as the forward path

---

### Phase 1: Comprehensive Boneyard Archival [NOT STARTED]

- **Dependencies**: Phase 0
- **Goal**: Archive ALL approaches that use Int, Rat, or trivial task_rel

**Files to Archive** (to `Theories/Bimodal/Boneyard/Task956_IntRat/`):
- [ ] `Metalogic/CanonicalConstruction.lean` - uses D=Int
- [ ] `Metalogic/CanonicalCompleteness.lean` - uses D=Int
- [ ] `Bundle/FragmentCompleteness.lean` - Int-indexed chain
- [ ] `Bundle/TemporalCoherentConstruction.lean` - uses BFMCS Int
- [ ] `Bundle/TemporalDomain.lean` - product domain with Q
- [ ] `Bundle/TranslationGroup.lean` - if exists
- [ ] `Bundle/BFMCSTruth.lean` - if uses Int
- [ ] Any file with `FMCS Int` or `BFMCS Int` that won't be refactored

**Tasks**:
- [ ] Create `Theories/Bimodal/Boneyard/Task956_IntRat/`
- [ ] Audit each file in Metalogic/ for Int/Rat dependency
- [ ] Move Int/Rat-dependent files to Boneyard
- [ ] Update imports in remaining files
- [ ] Create README.md explaining "Int/Rat imports are FORBIDDEN"
- [ ] Run `lake build` to verify remaining codebase compiles

**Timing**: 2.5 hours

**Verification**:
- `lake build` passes
- `grep -rn "D := Int" Theories/Bimodal/Metalogic/ --include="*.lean"` returns empty
- `grep -rn "FMCS Int\|BFMCS Int" Theories/Bimodal/Metalogic/ --include="*.lean" | grep -v Boneyard` returns empty or refactorable

---

### Phase 2: Relational Frame Infrastructure [NOT STARTED]

- **Dependencies**: Phase 1
- **Goal**: Establish relational completeness WITHOUT TaskFrame

**Tasks**:
- [ ] Define `RelationalFrame` (just W with R, no D or task_rel)
- [ ] Define `relational_valid` for formulas in RelationalFrame
- [ ] Prove relational soundness (temporal axioms valid in relational frames)
- [ ] Define canonical relational frame from MCS with CanonicalR
- [ ] Prove relational truth lemma: `phi ∈ MCS ↔ relational_satisfies MCS phi`

This establishes completeness relative to relational frames, BEFORE introducing D.

**Timing**: 3 hours

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/Relational/RelationalFrame.lean`
- `Theories/Bimodal/Metalogic/Relational/RelationalSoundness.lean`
- `Theories/Bimodal/Metalogic/Relational/RelationalCompleteness.lean`

**Verification**:
- `relational_weak_completeness : relational_valid φ → ⊢ φ` proven (or equivalent)
- No D or task_rel in relational frame definitions

---

### Phase 3: Canonical Timeline Properties [NOT STARTED]

- **Dependencies**: Phase 2
- **Goal**: Prove canonical timeline T has required properties for Cantor

**Properties to prove**:
1. **Linear order**: T = CanonicalMCS with CanonicalR is a linear order (already done via antisymmetrization)
2. **Countable**: T is countable (formulas are countable → MCS are countable)
3. **No endpoints**: T has no maximum or minimum (from seriality axioms)
4. **Dense**: T is dense (from density axiom DN)

**Tasks**:
- [ ] Prove `Countable CanonicalTimeline` (via formula countability)
- [ ] Prove `NoMaxOrder CanonicalTimeline` (from seriality F(¬⊥))
- [ ] Prove `NoMinOrder CanonicalTimeline` (from seriality P(¬⊥))
- [ ] Prove `DenselyOrdered CanonicalTimeline` (from density axiom DN)
  - This is the KEY step; research-015/024 analyzed approaches
  - Use: between any two MCS w₁ < w₂, the density axiom forces existence of intermediate w

**Timing**: 4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Canonical/CanonicalTimeline.lean` (new or existing)

**Verification**:
- All four properties proven sorry-free
- `lake build` passes

**Escape Valve**: If DenselyOrdered proof blocked after 3 hours, document specific obstacle and mark [BLOCKED]

---

### Phase 4: Cantor Isomorphism [NOT STARTED]

- **Dependencies**: Phase 3
- **Goal**: Apply Cantor's theorem to get T ≅ Q

**Tasks**:
- [ ] Find Mathlib's Cantor theorem (`Order.Countable.denselyOrdered_noMinOrder_noMaxOrder_iso_rat` or similar)
- [ ] Apply to CanonicalTimeline to get `e : CanonicalTimeline ≃o Q`
- [ ] Prove `e` is unique up to order-automorphism (Cantor uniqueness)

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Canonical/CantorIsomorphism.lean`

**Verification**:
- `canonicalTimeline_iso_rat : CanonicalTimeline ≃o ℚ` proven
- Uses Mathlib infrastructure, not ad-hoc proof

---

### Phase 5: D Emerges from Syntax [NOT STARTED]

- **Dependencies**: Phase 4
- **Goal**: Define D as the group discovered from the canonical timeline

**Key Insight**: D is NOT imported. D is defined as:
```lean
def D := ℚ  -- The additive group of rationals
-- But ℚ is DISCOVERED via Cantor, not imported as D=Rat
```

More precisely:
```lean
-- D is the additive group of displacements in T (equivalently, Q)
-- The Cantor iso e : T ≃o Q gives us the group structure
def D := ℚ  -- Notation convenience; the CONTENT comes from T's structure

-- task_rel(d)(w) = e⁻¹(e(w) + d)
def task_rel (d : D) (w : CanonicalTimeline) : CanonicalTimeline :=
  e.symm (e w + d)
```

**Tasks**:
- [ ] Define `D := ℚ` with comment explaining it's discovered via Cantor
- [ ] Define `task_rel` as displacement via Cantor isomorphism
- [ ] Prove `task_rel` is a group action: `task_rel 0 = id`, `task_rel (a + b) = task_rel a ∘ task_rel b`
- [ ] Prove `task_rel` respects order: `a < b → task_rel a w < task_rel b w`

**Timing**: 2 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/Canonical/DFromSyntax.lean`

**Verification**:
- D's group structure comes from Q, which comes from Cantor applied to T
- task_rel is non-trivial (displacement, not constant)

---

### Phase 6: TaskFrame from Syntax [NOT STARTED]

- **Dependencies**: Phase 5
- **Goal**: Build TaskFrame using syntactically-derived D and task_rel

**Tasks**:
- [ ] Define `SyntacticTaskFrame` using D and task_rel from Phase 5
- [ ] Prove TaskFrame axioms satisfied (linearly ordered abelian group, etc.)
- [ ] Prove truth lemma for SyntacticTaskFrame
- [ ] Connect to standard validity: `syntactic_valid φ ↔ valid φ`

**Timing**: 2.5 hours

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/Canonical/SyntacticTaskFrame.lean`
- `Theories/Bimodal/Metalogic/Representation.lean` (update to use SyntacticTaskFrame)

**Verification**:
- TaskFrame uses D discovered from syntax
- task_rel is the actual displacement, not trivial
- Truth lemma proven

---

### Phase 7: Complete Representation Theorem [NOT STARTED]

- **Dependencies**: Phase 6
- **Goal**: Prove completeness with purely syntactic foundations

**Tasks**:
- [ ] Prove `syntactic_weak_completeness : valid φ → ⊢ φ`
- [ ] Prove `syntactic_strong_completeness : (Γ ⊨ φ) → (Γ ⊢ φ)`
- [ ] Verify NO sorries in completeness proof chain
- [ ] Verify NO Int/Rat imports outside Cantor application
- [ ] Create implementation summary

**Timing**: 2 hours

**Verification**:
- `lake build` passes
- `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/ --include="*.lean" | grep -v Boneyard` returns empty
- Completeness uses D discovered from syntax

---

## Testing & Validation

- [ ] `lake build` passes at each phase
- [ ] No direct `D := Int` or `D := Rat` imports in active codebase
- [ ] D emerges from Cantor isomorphism applied to canonical timeline
- [ ] task_rel is displacement via Cantor, not trivial
- [ ] ROAD_MAP.md documents "Int/Rat imports FORBIDDEN"
- [ ] All Int/Rat-dependent approaches archived to Boneyard
- [ ] Completeness theorem sorry-free with pure syntax foundations

## Artifacts & Outputs

- Updated `specs/ROAD_MAP.md` with strict syntax constraint
- `Theories/Bimodal/Boneyard/Task956_IntRat/` with archived Int/Rat approaches
- `Theories/Bimodal/Metalogic/Relational/` - relational frame infrastructure
- `Theories/Bimodal/Metalogic/Canonical/` - Cantor-based D construction
- Sorry-free completeness with D from pure syntax

## Estimated Total

| Phase | Hours |
|-------|-------|
| Phase 0 (ROAD_MAP.md) | 2.5 |
| Phase 1 (Archival) | 2.5 |
| Phase 2 (Relational) | 3 |
| Phase 3 (Timeline properties) | 4 |
| Phase 4 (Cantor) | 1.5 |
| Phase 5 (D emerges) | 2 |
| Phase 6 (TaskFrame) | 2.5 |
| Phase 7 (Completeness) | 2 |
| **Total** | **20** |

## Rollback/Contingency

If Phase 3 (density proof) is blocked:
1. Document the specific obstacle
2. Research alternative density proof strategies
3. Consider whether discreteness axioms (D=Z path) is more tractable as interim

If Cantor application fails:
1. Verify Mathlib has required lemmas
2. Consider building Cantor infrastructure if missing
3. Document requirements for Mathlib PR if needed

## Appendix: Why This Is Different from v009

v009 treated "Goal A" (D=Int) as acceptable and deferred "Goal B" (D from syntax).

**This plan rejects that framing entirely.**

The user has clarified:
- Importing Int or Rat is **STRICTLY FORBIDDEN**
- D must emerge from the temporal axioms
- Density/discreteness must emerge from the axioms
- task_rel must be non-trivial

There is no "Goal A vs Goal B". There is only the original task intent: **D from pure syntax**.
