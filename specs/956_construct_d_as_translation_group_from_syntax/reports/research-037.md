# Research Report: Task 956 Remaining Work Assessment

- **Task**: 956 - Construct D as translation group from syntax
- **Started**: 2026-03-12T00:00:00Z
- **Completed**: 2026-03-12T00:30:00Z
- **Effort**: 0.5 hours
- **Domain Override**: logic (assessing remaining mathematical logic work)
- **Sources/Inputs**:
  - Task 957 completion summary (`implementation-summary-20260310c.md`)
  - Task 958 status (abandoned)
  - Task 959 completion summary (`implementation-summary-20260311.md`)
  - Task 956 current state (`implementation-summary-20260310f.md`, `implementation-015.md`)
  - `CantorApplication.lean` current sorries
  - `ROAD_MAP.md` D-from-syntax status
- **Artifacts**: `specs/956_construct_d_as_translation_group_from_syntax/reports/research-037.md` (this file)
- **Session**: sess_1773326386_106b8b

## Executive Summary

In light of tasks 957 (completed), 958 (abandoned), and 959 (completed), task 956 remains with **one clear blocker** at Phase 6. The density frame condition theorem (957) unblocked Phase 5. Task 958's abandonment is a non-issue (the theorem was unused). Task 959's cleanup work clarified the path forward. What remains is to resolve the **quotient strictness gap** in Phase 6, then complete Phases 7-8.

**Remaining work**: 7-8 hours to sorry-free standard completeness.

## Related Task Status

### Task 957: density_frame_condition (COMPLETED)

**What it achieved**: Proved the density frame condition theorem with zero sorries:
- For any MCSs M, M' with CanonicalR(M, M') and NOT CanonicalR(M', M), exists W with:
  - CanonicalR(M, W)
  - CanonicalR(W, M')

**Impact on 956**:
- Unblocked Phase 5 (DenseTimeline.lean is now complete with zero sorries)
- Provides the key `density_frame_condition` theorem for density insertion
- Also provided IRR soundness infrastructure (atoms function, DerivationTree.irr, truth independence lemma) for potential future use

**Elegant proof insight**: Case B (G(delta) in M but delta not in M) was resolved via a purely syntactic argument using reflexivity case splitting + double-density trick. NO IRR rule was needed in the final proof.

### Task 958: canonicalR_irreflexive (ABANDONED)

**Why abandoned**:
1. **UNUSED**: Irreflexivity on the canonical timeline is obtained for free via the strict `<` ordering on CanonicalMCS preorder. The standalone `canonicalR_irreflexive : NOT CanonicalR M M` theorem is never called.
2. **UNPROVABLE**: With String atoms, there's no mechanism to generate globally fresh atoms for the naming set construction that the IRR rule requires.

**Impact on 956**: NONE. The Phase 6 blocker is NOT about proving CanonicalR irreflexivity globally. It's about proving the *witnesses* are strictly ordered (not reflexively equivalent) in the antisymmetrized quotient.

### Task 959: Orientation Cleanup (COMPLETED)

**What it achieved**:
1. Marked deprecated files with DEPRECATED headers:
   - `DovetailingChain.lean` (Int-indexed, violates pure-syntax constraint)
   - `TemporalCoherentConstruction.lean` (Int-specialized)
   - `Representation.lean` (uses Int-indexed BFMCS)
2. Documented Task 958 status in `CanonicalIrreflexivity.lean`
3. Updated `ROAD_MAP.md` with:
   - D-from-syntax phase status table
   - Phase 6-8 roadmap with recommended strategies
   - Sorry debt categorization (11 total: 3 critical path, 4 deprecated, 4 isolated)

**Impact on 956**: Provides clear orientation and documented path forward for remaining phases.

## Task 956: What Remains

### Current Status

| Phase | Status | Notes |
|-------|--------|-------|
| 0-4 | COMPLETED | Zero sorries |
| 5 | COMPLETED | DenseTimeline.lean, zero sorries |
| 6 | **BLOCKED** | 3 sorries in CantorApplication.lean |
| 7 | NOT STARTED | Depends on Phase 6 |
| 8 | NOT STARTED | Depends on Phase 7 |

### Phase 6 Blocker: Quotient Strictness Gap

**The 3 sorries** (CantorApplication.lean:135, 143, 149):
1. `NoMaxOrder (TimelineQuot)`: Every quotient element has a strictly greater element
2. `NoMinOrder (TimelineQuot)`: Every quotient element has a strictly lesser element
3. `DenselyOrdered (TimelineQuot)`: Between any two elements there's another

**Root cause**: The `Antisymmetrization` quotient collapses elements where CanonicalR is bidirectional. The DenseTimeline witnesses provide CanonicalR witnesses (preorder `<=`), but not STRICT witnesses. If CanonicalR(p, q) AND CanonicalR(q, p), then `[p] = [q]` in the quotient.

**From the code** (CantorApplication.lean:127-134):
```
-- The issue: staged_timeline_has_future gives q with CanonicalR(p, q),
-- but possibly also CanonicalR(q, p). In that case, [p] = [q'] in the quotient.
--
-- We need a STRICT future: CanonicalR(p, q) and NOT CanonicalR(q, p).
-- The current dense_timeline_has_future doesn't guarantee strictness.
```

### Resolution Strategies for Phase 6

**Strategy C (Recommended by ROAD_MAP.md)**: Prove strict witnesses exist by using temporal linearity + formula choice.

For `NoMaxOrder`:
1. Given p in timeline, apply F-witness construction to get q with CanonicalR(p, q)
2. If also CanonicalR(q, p) (bidirectional), then apply F-witness again from q
3. By temporal linearity axiom + density axiom (F(phi) -> F(F(phi))), repeated application yields a genuinely strict successor

For `NoMinOrder`: Symmetric argument with H-witness (past direction).

For `DenselyOrdered`:
1. Given a < b in quotient, we have CanonicalR(a, b) and NOT CanonicalR(b, a)
2. Apply `density_frame_condition` to get W with CanonicalR(a, W) and CanonicalR(W, b)
3. The strictness of a < b ensures W is NOT equivalent to a (since if CanonicalR(W, a), transitivity would give CanonicalR(b, a) contradiction)
4. Similarly for b

**Key insight**: The density_frame_condition Case B1 (M' reflexive) returns W = M', but if M' is reflexive, then [M] != [M'] anyway (since CanonicalR(M, M') but not CanonicalR(M', M) given). So the quotient-level density holds.

**Estimated effort**: 3-4 hours

### Phases 7-8: Straightforward Once Phase 6 Done

**Phase 7: DFromSyntax.lean** (1.5 hours)
- Apply Cantor's theorem: `cantor_iso : TimelineQuot ≃o Q`
- Define `D := Q`
- Define `task_rel d w := e⁻¹(e(w) + d)` where e is the Cantor isomorphism
- Mathlib provides all needed infrastructure

**Phase 8: TaskFrameFromSyntax.lean** (2.5 hours)
- Construct `TaskFrame D` with task_rel
- Prove temporal axiom validity
- Integrate with truth lemma
- Prove `staged_completeness : valid phi -> ⊢ phi`

## Decisions and Recommendations

### Decision 1: Task 958 Abandonment is Correct

The `canonicalR_irreflexive` theorem was proven UNUSED (no call sites) and UNPROVABLE (String atom freshness limitation). This is NOT a blocker for task 956.

### Decision 2: Deprecated Files are Properly Marked

The Int/Rat-tainted files (`DovetailingChain.lean`, `TemporalCoherentConstruction.lean`, `Representation.lean`) are correctly marked as deprecated. They should not be modified or used for the D-from-syntax path.

### Decision 3: Task 957 Infrastructure Available

The IRR soundness infrastructure (atoms function, DerivationTree.irr, truth independence lemma, irr_sound_dense_at_domain) built in task 957 remains available for potential use in Phase 6 strictness proofs, though the recommended Strategy C may not require it.

### Recommendation: Proceed with Phase 6 Using Strategy C

**Next action**: Implement the quotient strictness proofs in CantorApplication.lean:
1. For `NoMaxOrder`: Prove F-witness is strictly greater (if reflexively equivalent, iterate)
2. For `NoMinOrder`: Prove H-witness is strictly lesser (symmetric argument)
3. For `DenselyOrdered`: Use density_frame_condition + quotient strictness from the a < b hypothesis

**If Strategy C fails**: Fall back to Strategy B (explicit witness distinctness proof) or explore whether the IRR infrastructure from task 957 enables a different approach.

## Summary

| Aspect | Status |
|--------|--------|
| Task 957 contribution | Unblocked Phase 5; provides density_frame_condition |
| Task 958 contribution | None (correctly abandoned) |
| Task 959 contribution | Orientation clarity; documented path forward |
| Remaining blocker | Phase 6 quotient strictness gap (3 sorries) |
| Remaining phases | 6, 7, 8 |
| Estimated remaining effort | 7-8 hours |
| Path to completion | Strategy C for Phase 6, then straightforward Phase 7-8 |

## Appendix: Sorry Inventory

### Critical Path (Task 956 Phase 6)
| File | Location | Issue |
|------|----------|-------|
| CantorApplication.lean | :135 | NoMaxOrder sorry |
| CantorApplication.lean | :143 | NoMinOrder sorry |
| CantorApplication.lean | :149 | DenselyOrdered sorry |

### Deprecated Path (4 sorries)
- DovetailingChain.lean: forward_F, backward_P (2 sorries)
- TemporalCoherentConstruction.lean: 2 sorries

### Isolated (4 sorries)
- Various isolated modules not on critical path

**Total**: 11 sorries (3 on D-from-syntax critical path)
