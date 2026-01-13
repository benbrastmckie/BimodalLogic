/-!
# Boneyard: Duration Construction (DEPRECATED)

This file documents the deprecated Duration-based time construction that exists in
`Bimodal/Metalogic/Completeness.lean`.

## Status: DEPRECATED

**DO NOT USE** for new development. Use FiniteTime from FiniteCanonicalModel.lean instead.

## Why This Approach Was Deprecated

The Duration construction attempted to create an "agnostic" time type that wouldn't
impose discreteness, density, or continuity assumptions. The approach failed because:

1. **Excessive complexity**: The Grothendieck group construction added significant
   mathematical machinery without corresponding proof benefits.

2. **15+ sorry gaps in basic properties**:
   - `PositiveDuration.zero_add`, `add_zero`, `add_assoc`, `add_comm` - all sorries
   - `Duration.le_antisymm`, `le_total` - sorries in order properties
   - `canonical_compositionality` - sorries in mixed-sign duration cases
   - `concat_respects_equiv` - sorry in concatenation equivalence

3. **The agnostic property was unnecessary**: The finite model property shows that
   for any formula, we only need bounded time domains. `FiniteTime k` (= Fin(2*k+1))
   is simpler and sufficient.

4. **Build complexity**: Duration is the Grothendieck group completion of PositiveDuration,
   which is a quotient of chain segments under order-type equivalence. This requires
   imports from advanced Mathlib modules (GrothendieckGroup, Cardinal.Basic, etc.).

## Location of Deprecated Code

The Duration construction is in `Bimodal/Metalogic/Completeness.lean`:

### Type Definitions (lines 1416-1983)

| Definition | Line | Description | Status |
|------------|------|-------------|--------|
| `TemporalChain` | ~1451 | Maximal linear suborder | Used by Duration |
| `ChainSegment` | ~1472 | Convex subset of chain | Used by Duration |
| `ChainSegmentSigma` | ~1482 | Sigma type for quotient | Used by Duration |
| `orderTypeEquiv` | ~1501 | Equivalence relation | Has sorry in transitivity |
| `PositiveDuration` | ~1541 | Quotient of segments | Core type |
| `Duration` | ~1812 | Grothendieck completion | Core type |
| `CanonicalTime` | ~1983 | Abbreviation for Duration | Used by canonical_frame |

### Monoid/Group Properties (lines 1559-1941)

| Property | Line | Status |
|----------|------|--------|
| `PositiveDuration.zero` | ~1594 | Defined |
| `PositiveDuration.add` | ~1660 | Defined, respects_equiv has sorry |
| `PositiveDuration.zero_add` | ~1674 | SORRY |
| `PositiveDuration.add_zero` | ~1689 | SORRY |
| `PositiveDuration.add_assoc` | ~1702 | SORRY |
| `PositiveDuration.add_comm` | ~1726 | SORRY |
| `AddCommMonoid PositiveDuration` | ~1754 | Instance (using sorried lemmas) |
| `IsLeftCancelAdd PositiveDuration` | ~1787 | SORRY |
| `Duration.le_antisymm` | ~1880 | SORRY |
| `Duration.le_total` | ~1889 | SORRY |

### Canonical Model Using Duration (lines 1983-3500)

| Definition | Line | Description | Status |
|------------|------|-------------|--------|
| `canonical_task_rel` | ~2055 | Task relation using Duration | Has sorries in compositionality |
| `canonical_frame` | ~2435 | TaskFrame with Duration | Uses Duration |
| `canonical_model` | ~2695 | TaskModel | Uses Duration |
| `forward_extension` | ~2522 | Existence lemma | Has sorry |
| `backward_extension` | ~2638 | Existence lemma | Has sorry |
| `canonical_history` | ~3397 | WorldHistory | Has compositionality sorry |

## Axioms in Deprecated Code

```lean
axiom someWorldState_exists : ∃ S : Set Formula, SetMaximalConsistent S
```

This axiom is used to bootstrap the Duration construction. It's correct mathematically
but should not be needed in a complete proof.

## Replacement: Finite Time Approach

The working approach is in `FiniteCanonicalModel.lean`:

- **FiniteTime k**: Time domain `Fin (2 * k + 1)` representing integers from -k to +k
- **temporalBound phi**: Sets k = temporalDepth phi (sufficient for any formula)
- **SemanticCanonicalFrame**: Uses FiniteTime, not Duration
- **semantic_weak_completeness**: Proven without Duration

### Why FiniteTime Works

1. **Finite Model Property**: For any formula phi, if phi is satisfiable, there exists
   a finite model that satisfies it. The bound is determined by temporal and modal depth.

2. **Simpler Mathematics**: `Fin n` has decidable equality, finite enumeration, and
   well-understood Mathlib support.

3. **No Quotient Complexity**: FiniteTime is just a finite ordinal, not a quotient of
   equivalence classes.

4. **Proven Completeness**: The semantic approach using FiniteTime achieves completeness
   without the sorry gaps in Duration.

## Historical Context

- **Task 446**: Duration construction (this deprecated code)
- **Task 458**: Research identifying completeness gaps
- **Task 473**: SemanticWorldState using FiniteTime (the fix)
- **Task 487**: This Boneyard documentation

## Mathlib Imports for Duration

The Duration construction requires these imports (lines 9-15 of Completeness.lean):

```lean
import Mathlib.Order.Hom.Basic
import Mathlib.Order.Preorder.Chain
import Mathlib.GroupTheory.MonoidLocalization.GrothendieckGroup
import Mathlib.Algebra.Order.Group.Defs
import Mathlib.Tactic.Abel
import Mathlib.SetTheory.Cardinal.Basic
```

These add significant compile-time overhead for deprecated functionality.

## Summary

The Duration construction was an interesting mathematical approach but proved impractical:

- **Too complex**: Grothendieck groups, quotients of segments, order-type equivalence
- **Too many sorries**: 15+ gaps in basic algebraic properties
- **Unnecessary**: Finite model property makes bounded time sufficient

Use `FiniteTime` and `SemanticCanonicalFrame` from FiniteCanonicalModel.lean instead.

---

*This file is documentation only. The deprecated code remains in Completeness.lean.*
*Archived: 2026-01-13*
-/

-- This file is documentation only - no executable code
-- The deprecated code remains in Completeness.lean for reference
-- To avoid breaking the build, the Duration code has not been extracted
