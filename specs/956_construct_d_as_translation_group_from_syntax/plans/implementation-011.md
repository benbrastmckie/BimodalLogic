# Implementation Plan: D Construction from Canonical Timeline

- **Task**: 956 - Construct D as translation group from syntax
- **Status**: [PARTIAL]
- **Effort**: 12-18 hours
- **Dependencies**: None
- **Research Inputs**: research-029.md (goal decomposition), research-020/021/023 (strategy analysis)
- **Artifacts**: plans/implementation-011.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true
- **Supersedes**: implementation-010.md (v010 incorrectly pursued relational completeness)

## Critical Constraint

**IMPORTING Int OR Rat IS STRICTLY FORBIDDEN.**

Everything must be constructed from pure syntax:
- **D** must emerge from the temporal axioms, not be imported
- **Density** of D must emerge from the density axioms (DN)
- **task_rel** must encode the actual displacement structure, not be trivial

## v011 Correction: NO RELATIONAL COMPLETENESS

**v010 Error**: Phase 2 aimed to "establish relational completeness WITHOUT TaskFrame". This is INCORRECT.

**Correction**: We do NOT need relational completeness. Validity over `<W, R>` (relational frames) is IRRELEVANT to our aims. The goal is to BUILD a correct D with the needed properties. The completeness we care about is TaskFrame completeness, which we already have infrastructure for.

**Correct Pipeline**:
1. Build canonical timeline T from MCS reachability (existing infrastructure)
2. Prove T has properties: countable, dense, no endpoints (from axioms)
3. Apply Cantor isomorphism: T ≅ Q (discovered, not imported)
4. Define D = (Q, +) via the isomorphism (D emerges from syntax)
5. Define task_rel as displacement: task_rel(d)(w) = e⁻¹(e(w) + d)
6. Build TaskFrame using D
7. Prove completeness using existing TaskFrame infrastructure

There is NO relational frame infrastructure to build. The MCS/CanonicalR infrastructure already exists and provides the canonical timeline T.

## Overview

Task 956 explored multiple approaches over 28 research reports. This revision corrects v010's misunderstanding: we don't need to prove completeness for relational frames. We need to:

1. **Update ROAD_MAP.md** to correct the K-Relational strategy description
2. **Archive Int/Rat approaches** (if not already done)
3. **Prove canonical timeline properties** directly from existing MCS infrastructure
4. **Apply Cantor isomorphism** to discover D
5. **Build TaskFrame** with syntactically-derived D
6. **Complete representation theorem** using existing completeness infrastructure

## Goals & Non-Goals

**Goals**:
- Correct ROAD_MAP.md: remove relational completeness framing
- Construct D from canonical timeline via Cantor
- Build TaskFrame with non-trivial task_rel
- Complete representation theorem with pure syntax foundations

**Non-Goals**:
- Relational frame completeness (IRRELEVANT)
- Proving validity over <W, R> (IRRELEVANT)
- Using D=Int or D=Rat directly (FORBIDDEN)
- Using `task_rel = True` (defeats purpose)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Density proof from axioms blocked | HIGH | MEDIUM | Research-015/024 analyzed paths; seriality axioms provide NoMax/NoMin |
| Cantor isomorphism construction hard | HIGH | MEDIUM | Mathlib has Cantor's theorem infrastructure |
| Existing MCS infrastructure insufficient | MEDIUM | LOW | CanonicalR and existence lemma already proven |

## Implementation Phases

### Phase 0: ROAD_MAP.md Corrections [COMPLETED]

- **Dependencies**: None
- **Goal**: Correct the K-Relational strategy description; remove relational completeness framing

**Tasks**:
- [ ] Update "Strategy: K-Relational Completeness with Syntactic D":
  - Remove step 1 "Relational frame completeness (no D or task_rel)"
  - Clarify that relational completeness is NOT needed
  - Update to reflect direct D construction path
- [ ] Update "Decision: K-Relational Strategy":
  - Remove mention of relational frame infrastructure
  - Clarify the goal is D construction, not relational validity
- [ ] Update "Ambition: Syntactically-Derived Duration Domain":
  - Remove "Relational completeness proven without D" criterion
  - Keep focus on canonical timeline → Cantor → D → TaskFrame
- [ ] Add "Dead End: Relational Completeness Detour":
  - Document that pursuing relational completeness was a misdirection
  - The goal is D construction, not validity over <W, R>

**Timing**: 1 hour

**Verification**:
- ROAD_MAP.md does NOT mention relational completeness as a goal
- K-Relational strategy describes direct D construction path
- No references to proving validity over relational frames

---

### Phase 1: Boneyard Archival (if needed) [COMPLETED]

- **Dependencies**: Phase 0
- **Goal**: Archive Int/Rat-dependent approaches

**Note**: This may already be done by v010 Phase 1. Check status first.

**Tasks**:
- [ ] Verify `Theories/Bimodal/Boneyard/Task956_IntRat/` exists with archived files
- [ ] If not, create and move:
  - `Metalogic/CanonicalConstruction.lean` (if uses D=Int)
  - `Metalogic/CanonicalCompleteness.lean` (if uses D=Int)
  - Any file with hardcoded `D := Int` or `D := Rat`
- [ ] Run `lake build` to verify remaining codebase compiles

**Timing**: 0.5-1.5 hours (depending on prior state)

**Verification**:
- `lake build` passes
- No hardcoded D=Int/Rat in active Metalogic/ files

---

### Phase 2: Canonical Timeline Properties [BLOCKED]

- **Dependencies**: Phase 1
- **Goal**: Prove canonical timeline T has properties required for Cantor

The canonical timeline T is the set of MCSs reachable from an origin via CanonicalR. This infrastructure ALREADY EXISTS. We need to prove:

**Properties to prove**:
1. **Linear order**: T with CanonicalR is a linear order (already done via Antisymmetrization)
2. **Countable**: T is countable (formulas countable → MCS countable)
3. **No endpoints**: NoMaxOrder and NoMinOrder (from seriality axioms)
4. **Dense**: DenselyOrdered (from density axiom DN)

**Tasks**:
- [ ] Locate existing canonical timeline definition (likely in Canonical/ or Bundle/)
- [ ] Prove `Countable CanonicalTimeline` (via formula countability)
- [ ] Prove `NoMaxOrder CanonicalTimeline` (from seriality F(¬⊥))
- [ ] Prove `NoMinOrder CanonicalTimeline` (from seriality P(¬⊥))
- [ ] Prove `DenselyOrdered CanonicalTimeline` (from density axiom DN)
  - KEY step: between any w₁ < w₂, density axiom forces intermediate w

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Canonical/CanonicalTimeline.lean` (new or existing)

**Verification**:
- All four properties proven sorry-free
- `lake build` passes

**Escape Valve**: If DenselyOrdered proof blocked after 2 hours, document obstacle and mark [BLOCKED]

---

### Phase 3: Cantor Isomorphism [NOT STARTED]

- **Dependencies**: Phase 2
- **Goal**: Apply Cantor's theorem to get T ≅ Q

Cantor's theorem: every countable dense linear order without endpoints is isomorphic to Q.

**Tasks**:
- [ ] Find Mathlib's Cantor theorem (search for `Rat` + `OrderIso` + `Countable` + `DenselyOrdered`)
- [ ] Apply to CanonicalTimeline to get `e : CanonicalTimeline ≃o ℚ`
- [ ] Prove `e` is unique up to order-automorphism (Cantor uniqueness)

**Timing**: 1.5 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/Canonical/CantorIsomorphism.lean`

**Verification**:
- `canonicalTimeline_iso_rat : CanonicalTimeline ≃o ℚ` proven
- Uses Mathlib infrastructure, not ad-hoc proof

---

### Phase 4: D Emerges from Syntax [NOT STARTED]

- **Dependencies**: Phase 3
- **Goal**: Define D as the group discovered from the canonical timeline

**Key Insight**: D is NOT imported. D is the additive group that naturally acts on T via translation. Because T ≅ Q, we have D = (Q, +).

```lean
-- D is discovered via Cantor, not imported
def D := ℚ  -- Notation convenience; the CONTENT comes from T ≅ Q

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

### Phase 5: TaskFrame from Syntax [NOT STARTED]

- **Dependencies**: Phase 4
- **Goal**: Build TaskFrame using syntactically-derived D and task_rel

**Tasks**:
- [ ] Define `SyntacticTaskFrame` using D and task_rel from Phase 4
- [ ] Prove TaskFrame axioms satisfied (linearly ordered abelian group, etc.)
- [ ] Connect to existing TaskFrame infrastructure

**Timing**: 2 hours

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/Canonical/SyntacticTaskFrame.lean`

**Verification**:
- TaskFrame uses D discovered from syntax
- task_rel is the actual displacement, not trivial

---

### Phase 6: Complete Representation Theorem [NOT STARTED]

- **Dependencies**: Phase 5
- **Goal**: Prove completeness with purely syntactic foundations

This phase connects SyntacticTaskFrame to the existing completeness infrastructure.

**Tasks**:
- [ ] Prove truth lemma for SyntacticTaskFrame
- [ ] Prove `syntactic_weak_completeness : valid φ → ⊢ φ`
- [ ] Verify NO sorries in completeness proof chain
- [ ] Verify NO Int/Rat imports outside Cantor application
- [ ] Create implementation summary

**Timing**: 2 hours

**Verification**:
- `lake build` passes
- `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/ --include="*.lean" | grep -v Boneyard` returns empty (or documented)
- Completeness uses D discovered from syntax

---

## Testing & Validation

- [ ] `lake build` passes at each phase
- [ ] D emerges from Cantor isomorphism applied to canonical timeline
- [ ] task_rel is displacement via Cantor, not trivial
- [ ] ROAD_MAP.md corrected: no relational completeness framing
- [ ] No Int/Rat imports in active completeness chain (except via Cantor discovery)
- [ ] Completeness theorem sorry-free with pure syntax foundations

## Artifacts & Outputs

- Updated `specs/ROAD_MAP.md` with corrected strategy
- `Theories/Bimodal/Metalogic/Canonical/CanonicalTimeline.lean` - timeline properties
- `Theories/Bimodal/Metalogic/Canonical/CantorIsomorphism.lean` - T ≅ Q
- `Theories/Bimodal/Metalogic/Canonical/DFromSyntax.lean` - D and task_rel
- `Theories/Bimodal/Metalogic/Canonical/SyntacticTaskFrame.lean` - TaskFrame from D
- Implementation summary

## Estimated Total

| Phase | Hours |
|-------|-------|
| Phase 0 (ROAD_MAP.md corrections) | 1 |
| Phase 1 (Archival) | 0.5-1.5 |
| Phase 2 (Timeline properties) | 3 |
| Phase 3 (Cantor) | 1.5 |
| Phase 4 (D emerges) | 2 |
| Phase 5 (TaskFrame) | 2 |
| Phase 6 (Completeness) | 2 |
| **Total** | **12-14** |

## Rollback/Contingency

If Phase 2 (density proof) is blocked:
1. Document the specific obstacle
2. Consider whether discreteness axioms (D=Z path) is more tractable as interim
3. Research alternative density proof strategies

If Cantor application fails:
1. Verify Mathlib has required lemmas
2. Consider building Cantor infrastructure if missing

## Appendix: Why This Is Different from v010

v010 included "Phase 2: Relational Frame Infrastructure" with the goal to "establish relational completeness WITHOUT TaskFrame". This was a misdirection.

**The user clarified**:
- Relational completeness (validity over <W, R>) is IRRELEVANT
- The goal is to BUILD D with the right properties
- We don't need a separate relational completeness theorem
- TaskFrame completeness (which we have infrastructure for) is what matters

**v011 removes the relational completeness phase entirely** and focuses directly on:
1. Canonical timeline properties (from existing MCS infrastructure)
2. Cantor isomorphism (discovering D)
3. TaskFrame construction (using discovered D)
4. Completeness (using existing TaskFrame infrastructure)

This is a shorter, more focused plan that correctly addresses the task's actual requirements.
