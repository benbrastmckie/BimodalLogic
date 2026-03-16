# Research Report: Task 974 - Current Standing Post-DurationTransfer Fix

**Task**: 974 - prove_discrete_timeline_succorder_predorder
**Session**: sess_1773689666_k4m8n
**Date**: 2026-03-16
**Focus**: Verify build status post-DurationTransfer fix, analyze 3 sorries, recommend plan updates

---

## Executive Summary

The DurationTransfer.lean API fix from task 977 Phase 0 has been successfully applied. However, **DiscreteTimeline.lean has a new structural error** that was introduced at some point: the type definitions use Lean's `variable` binding which auto-binds parameters as implicit, but the instance declarations try to apply these types with explicit arguments.

**Key Findings**:

1. **DurationTransfer.lean**: Fixed and compiles successfully
2. **DiscreteTimeline.lean**: 7 new structural errors (type/function mismatch), blocking compilation
3. **3 Original Sorries**: Cannot be analyzed until structural errors are fixed
4. **Task 973 Pattern**: Not directly applicable (different construction approach)

**Recommendation**: Add a Phase 6.5 to the plan to fix the structural type errors before proceeding to Phase 7 (the actual sorry resolution).

---

## Part I: Build Verification

### DurationTransfer.lean Status

**Result: FIXED**

The DurationTransfer.lean file has been updated with proper imports and compiles successfully:

```lean
import Mathlib.Algebra.Order.Ring.Rat
import Mathlib.Algebra.Order.Group.Int
import Mathlib.Data.Rat.Encodable
```

The `IsOrderedAddMonoid` instantiation pattern has been corrected. The file now builds without errors.

### DiscreteTimeline.lean Status

**Result: NEW ERRORS (7 structural errors)**

Running `lake build Bimodal.Metalogic.Domain.DiscreteTimeline` reveals:

| Line | Error | Root Cause |
|------|-------|------------|
| 245 | "Function expected at DiscreteTimelineQuot" | Type used as function |
| 259 | "Function expected at DiscreteTimelineQuot" | Type used as function |
| 286 | "Function expected at DiscreteTimelineQuot" | Type used as function |
| 312 | "Function expected at DiscreteTimelineQuot" | Type used as function |
| 334 | "Function expected at DiscreteTimelineQuot" | Type used as function |
| 373 | "Unknown identifier `TaskFrame`" | Missing import/namespace |
| 377 | "Function expected at DiscreteTimelineQuot" | Type used as function |

**Root Cause Analysis**:

The file uses `variable (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs)` with explicit `()` binding, but the type definitions:

```lean
def DiscreteTimelineQuot : Type :=
  Antisymmetrization (DiscreteTimelineElem root_mcs root_mcs_proof) (· ≤ ·)
```

are compiled with the variables auto-bound as **implicit** parameters. This means:
- `DiscreteTimelineQuot : Type` (not a function)
- Variables `root_mcs`, `root_mcs_proof` are implicit parameters

But the instance declarations try to use them as explicit functions:

```lean
instance : PredOrder (DiscreteTimelineQuot root_mcs root_mcs_proof) where
--                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
--                    Error: Function expected, but Type given
```

**Comparison with Task 973**:

The `ConstructiveQuotient` from CanonicalSerialFrameInstance.lean is explicitly parameterized:
```lean
ConstructiveQuotient (M₀ : Set Formula) (h_mcs₀ : SetMaximalConsistent M₀) : Type
```

This is a function that takes arguments and returns a Type.

---

## Part II: Sorry Status Analysis

Due to the structural errors, the 3 sorries cannot be properly analyzed with `lean_goal`. The MCP tool returns `sorry` as the goal type because earlier elaboration failures corrupt the proof state.

### Sorry Inventory (from source code analysis)

| Line | Sorry | Description | Planned Approach |
|------|-------|-------------|------------------|
| 193 | `discrete_timeline_lt_succFn` | `a < LinearLocallyFiniteOrder.succFn a` | Local finiteness via staged construction |
| 251 | `discrete_timeline_predFn_lt` | `discretePredFn a < a` | Symmetric to succFn |
| 296 | `IsSuccArchimedean.exists_succ_iterate_of_le` | Finite reachability | LocallyFiniteOrder derivation |

### Proof Approach (Unchanged from Plan v3)

The plan's Phase 7 approach remains valid:
1. Prove `LocallyFiniteOrder` on the quotient (intervals are finite due to staged construction)
2. Derive `discrete_timeline_lt_succFn` from finiteness (GLB is minimum)
3. Derive `discrete_timeline_predFn_lt` symmetrically
4. Derive `IsSuccArchimedean` from `LinearLocallyFiniteOrder.instIsSuccArchimedean`

However, this cannot proceed until the structural errors are fixed.

---

## Part III: Plan Review and Updates

### Current Plan Status

| Phase | Status | Notes |
|-------|--------|-------|
| 1-3 | [COMPLETED] | v1: Restructured SuccOrder/PredOrder |
| 4 | [COMPLETED] | v3: Defined discreteStagedBuild |
| 5 | [COMPLETED] | v3: Proved DN-free has_future (actually uses DN, see note) |
| 6 | [BLOCKED] | Was blocked on DurationTransfer, now blocked on structural errors |
| 7 | [NOT STARTED] | Prove local finiteness, resolve 3 sorries |
| 8 | [NOT STARTED] | Final verification |

### Recommended Plan Updates

**Insert Phase 6.5: Fix Structural Type Errors**

- **Goal**: Fix the `variable` binding issue so types are properly parameterized
- **Approach**: One of three options:
  1. **Option A (Recommended)**: Remove explicit arguments from instance declarations - use bare `DiscreteTimelineQuot` since variables are in scope
  2. **Option B**: Change definitions to be explicit functions: `def DiscreteTimelineQuot (root_mcs : ...) (proof : ...) : Type`
  3. **Option C**: Use `@` to apply implicit arguments explicitly

**Timing**: 30 minutes

**Files to modify**: `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean`

### Updated Phase 6 Scope

After Phase 6.5, Phase 6 can proceed with the original goals:
- Redefine `DiscreteTimelineElem` to use `buildDiscreteStagedTimeline` (already done?)
- Update `NoMaxOrder` proof to use DN-free `discrete_staged_has_future`
- Update `NoMinOrder` proof to use DN-free `discrete_staged_has_past`
- Verify existing infrastructure compiles

---

## Part IV: Lessons from Task 973

### CanonicalSerialFrameInstance Pattern

Task 973 successfully proved `NoMaxOrder` and `NoMinOrder` on `ConstructiveQuotient` using:

1. **Seriality witnesses**: `SetMaximalConsistent.contains_seriality_future` / `contains_seriality_past`
2. **Forward/backward execution**: `executeForwardStep` / `executeBackwardStep`
3. **Strictness via irreflexivity**: `canonicalR_strict` to prove `w < w'` (not just `w <= w'`)

### Applicability to Task 974

**Not directly applicable**. The DiscreteTimeline.lean already has `NoMaxOrder` and `NoMinOrder` instances that compile (once structural errors are fixed). The 3 remaining sorries are about:

- `SuccOrder` discreteness (`a < succFn a`)
- `PredOrder` discreteness (`predFn a < a`)
- `IsSuccArchimedean` (finite reachability)

These are order-theoretic properties requiring `LocallyFiniteOrder`, not seriality/irreflexivity arguments.

However, the task 973 pattern **validates** that:
- The `canonicalR_strict` lemma works correctly
- Seriality witnesses are available in the staged construction
- The quotient structure (`Antisymmetrization`, `toAntisymmetrization`) works as expected

---

## Part V: Integration with Task 977

### Task 977 Current Status

Task 977 has completed Phases 0-2:
- **Phase 0**: DurationTransfer fix (7 API errors resolved)
- **Phase 1**: Documentation with 21 axioms, base/dense/discrete organization
- **Phase 2**: Derivation soundness theorem (6/8 inference rules proven)

### Coordination Points

1. **DurationTransfer**: Fixed by 977, unblocking 974's final pipeline
2. **Architecture**: 977's base/dense/discrete organization does not affect 974's internal proofs
3. **Discrete Completeness**: 977 Phase 6 (discrete completeness wiring) depends on 974 completion

### Sequencing Recommendation

```
974 Phase 6.5 (fix structural errors)     <- NEW
974 Phase 6 (NoMax/NoMin update)
974 Phase 7 (local finiteness, 3 sorries)
974 Phase 8 (verification)
977 Phase 3+ (continuing)
```

---

## Part VI: Technical Debt Notes

### DN Dependency in Discrete Construction

The `discrete_staged_has_future` proof in CantorPrereqs.lean uses `iterated_future_in_mcs` which invokes the density axiom DN. This contradicts the "DN-free" goal from research-003.md.

**Current state**: The proof works but uses DN.
**Impact**: The discrete construction is not truly DN-free as intended.
**Recommendation**: Document this as technical debt; true DN-free proofs would require MCS richness arguments.

### Reflexive Semantics Vacuity

DF under reflexive semantics uses `s = t` as witness (trivially valid). The discrete construction should only be used with irreflexive semantics. This is already enforced by the `canonicalR_irreflexive` axiom.

---

## Recommendations

### Immediate Actions

1. **Fix structural errors** (new Phase 6.5):
   - Remove explicit `root_mcs root_mcs_proof` arguments from instance declarations
   - Use bare type names since variables are in scope
   - Estimated time: 30 minutes

2. **Verify NoMax/NoMin compile** after structural fix:
   - Check `lake build Bimodal.Metalogic.Domain.DiscreteTimeline` succeeds with only 3 sorries

3. **Proceed to Phase 7** for sorry resolution:
   - Prove `LocallyFiniteOrder` from staged construction finiteness
   - Resolve 3 sorries as planned

### Plan Update Summary

| Change | Description |
|--------|-------------|
| Add Phase 6.5 | Fix structural type/function mismatch errors |
| Update Phase 6 dependency | Now depends on Phase 6.5 |
| Note on DN dependency | Document that discrete has_future still uses DN |

---

## Artifacts

- **This report**: `specs/974_prove_discrete_timeline_succorder_predorder/reports/research-005.md`
- **Key files analyzed**:
  - `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` - 7 structural errors, 3 sorries
  - `Theories/Bimodal/Metalogic/Domain/DurationTransfer.lean` - Fixed, compiles
  - `Theories/Bimodal/Metalogic/StagedConstruction/CantorPrereqs.lean` - DN dependency noted
  - `Theories/Bimodal/Metalogic/Canonical/CanonicalSerialFrameInstance.lean` - Task 973 pattern

---

## Appendix: Error Transcript

```
lake build Bimodal.Metalogic.Domain.DiscreteTimeline

error: Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean:245:41: Function expected at
  DiscreteTimelineQuot
but this term has type
  Type

error: Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean:259:36: Function expected at
  DiscreteTimelineQuot
but this term has type
  Type

error: Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean:286:30: Function expected at
  DiscreteTimelineQuot
but this term has type
  Type

error: Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean:312:23: Function expected at
  DiscreteTimelineQuot
but this term has type
  Type

error: Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean:334:23: Function expected at
  DiscreteTimelineQuot
but this term has type
  Type

error: Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean:373:5: Unknown identifier `TaskFrame`

error: Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean:377:21: Function expected at
  DiscreteTimelineQuot
but this term has type
  Type
```
