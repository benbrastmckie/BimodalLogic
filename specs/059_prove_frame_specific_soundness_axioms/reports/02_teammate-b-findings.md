# Teammate B Findings: Related Tasks and Conservative Extension Analysis

**Task**: 59 - Prove frame-specific soundness axioms
**Focus Area**: Related tasks and conservative extension context
**Date**: 2026-03-31

## Key Findings

### Related Tasks: Strict Temporal Extensions Track (Tasks 74-76, 998)

The TODO.md documents a new "Strict Temporal Extensions Research" track directly relevant to task 59:

| Task | Status | Description | Dependency |
|------|--------|-------------|------------|
| **74** | NOT STARTED | Research strict vs reflexive temporal semantics | None |
| **75** | NOT STARTED | Research G'/H' operator extension design | Depends on 74 |
| **76** | NOT STARTED | Research unified density/discreteness completeness | Depends on 74, 75 |
| **998** | RESEARCHING | FMP redesign for strict temporal | Parallel to 75 |

### The G'/H' Conservative Extension Concept

From `specs/reviews/review-20260331.md` and task 75 description:

**Proposed Extension**:
- G' (strict future): `forall s > t, phi(s)` - excludes present
- H' (strict past): `forall s < t, phi(s)` - excludes present
- Relationship: `G <-> (phi /\ G')`, `H <-> (phi /\ H')`

**Conservative Extension Strategy** (two options documented):
1. **Definitional**: `G' phi := G phi /\ neg phi` (strict future excludes present)
2. **Primitive**: Add G'/H' as new primitives with axioms, prove equivalence

### Why Strict Semantics Matters for Density

The density axiom (`GG phi -> G phi`) has different validity conditions:

| Semantics | Density Validity | Reason |
|-----------|-----------------|--------|
| **Reflexive** (current) | Trivially valid | `G phi` at t means phi(t), self-witness via `le_rfl` |
| **Strict** | Requires `DenselyOrdered D` | `G' G' phi` at t means phi holds at all s > t, density needed to find intermediate point |

From `Axioms.lean` documentation (lines 351-378): The density axiom is documented with strict semantics notes, indicating the theoretical framework expects strict operators for non-trivial density.

### Existing Codebase State for G'/H'

**Searched for G'/H' definitions**: No existing G'/H' operators found in codebase. The strict temporal operators are currently only in research/planning phases.

**Current operators** (from `Validity.lean` and `Soundness.lean`):
- `all_future` (G): `forall s >= t, phi(s)` - reflexive
- `all_past` (H): `forall s <= t, phi(s)` - reflexive
- `some_future` (F): derived as `neg G neg`
- `some_past` (P): derived as `neg H neg`

### Task 59 Research Findings (01_frame-soundness-research.md)

The existing research report for task 59 found:

| Line | Axiom | Status | Under Reflexive Semantics |
|------|-------|--------|---------------------------|
| 572 | `density` | Fillable | Trivially valid via `le_rfl` |
| 576 | `discreteness_forward` | Fillable | Trivially valid via `le_rfl` |
| 579 | `seriality_future` | Fillable | Trivially valid via `le_rfl` |
| 582 | `seriality_past` | Fillable | Trivially valid via `le_rfl` |
| 602 | `temporal_duality` | Blocked | Requires `[DenselyOrdered D] [Nontrivial D]` |

**Key insight**: Under reflexive semantics, the density/seriality axioms become trivially valid because the present time `t` always satisfies `t >= t` (or `t <= t`), providing a witness without needing the actual frame property.

## Recommended Approach

### Task 59 Should Proceed as Scoped (Option A)

**Rationale**:
1. Task 59 is already correctly scoped to fill 4 of 5 sorries using reflexive semantics proofs
2. The 5th sorry (temporal_duality) has a documented blocker unrelated to strict semantics
3. The strict temporal extension (tasks 74-76) is a separate research track that doesn't block task 59

**However**, the research should document:
- The proofs work because reflexive semantics trivializes the frame conditions
- Under strict semantics, these axioms would require actual `DenselyOrdered`/`SuccOrder` constraints
- This is a known limitation captured in the strict temporal research track

### Dependencies Between Task 59 and Strict Extensions

| Relationship | Description |
|--------------|-------------|
| **No blocking dependency** | Task 59 can complete independently using reflexive semantics |
| **Future work** | Tasks 74-76 may revisit soundness if strict operators are added |
| **Documentation** | Task 59 should note the reflexive vs strict distinction |

### Should Task 59 Be Revised?

**No revision needed**, but the implementation summary should document:

1. The 4 filled sorries use the reflexive semantics pattern (`le_rfl` witnesses)
2. This approach is valid under current TM logic design (reflexive G/H)
3. The strict temporal extension track (74-76) may introduce G'/H' that would have non-trivial density/seriality proofs

## Evidence/Examples

### TODO.md Task Order Section (lines 34-44)

```
### 0. Strict Temporal Extensions Research (new track, parallel)

- **74** [NOT STARTED] - Research strict vs reflexive temporal semantics
- **75** [NOT STARTED] - Research G'/H' operator extension design (depends on 74)
- **76** [NOT STARTED] - Research unified density/discreteness completeness (depends on 74, 75)
- **998** [RESEARCHING] - FMP redesign for strict temporal (parallel to 75)
```

### Task 75 Description (lines 158-184)

Documents the G'/H' design options:
- **Option A**: Add G'/H' as new primitives in Formula type
- **Option B**: Define G'/H' as derived operators (`G' phi := G phi /\ neg phi`)

### Compatibility.lean Note (line 35)

```lean
Total: 19 axioms (2 T-axioms removed under strict semantics)
```

This confirms the codebase already anticipates strict semantics changes.

### Review File Key Insight (lines 28-30)

```markdown
1. The `temp_t_future` (Gphi -> phi) and `temp_t_past` (Hphi -> phi) axioms are ONLY valid under reflexive semantics
2. The density axiom documentation references strict semantics (s > t, s < t)
3. The seriality axioms (Gphi -> Fphi, Hphi -> Pphi) are formulated for strict semantics
```

## Confidence Level

**HIGH** confidence in these findings:

1. The TODO.md explicitly documents the strict temporal extension track (tasks 74-76, 998)
2. The task 59 research report already analyzed the reflexive vs strict distinction
3. The codebase comments in `Compatibility.lean` and `Axioms.lean` acknowledge strict semantics
4. No code changes are needed to task 59's scope - it correctly uses reflexive semantics proofs
5. The strict extension is a parallel research track, not a blocker

## Summary

Task 59 is correctly scoped and can proceed with the reflexive semantics approach documented in its research report. The strict temporal extension (G'/H' operators) is a separate, parallel research track (tasks 74-76) that will address non-trivial density/seriality proofs under strict semantics. Task 59 should document the reflexive vs strict distinction in its implementation summary but does not need to wait for the strict extension research to complete.
