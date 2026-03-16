# Research 006 - Teammate A: LocallyFiniteOrder Mathlib Patterns

**Task**: 974 - Prove SuccOrder/PredOrder/IsSuccArchimedean in DiscreteTimeline.lean
**Focus**: LocallyFiniteOrder patterns in Mathlib
**Date**: 2026-03-16

## Key Findings

### 1. Critical Discovery: Two Distinct Paths to IsSuccArchimedean

The research reveals **two fundamentally different approaches** to proving `IsSuccArchimedean`:

#### Path A: LocallyFiniteOrder -> IsSuccArchimedean (FORWARD)
From `Mathlib.Order.SuccPred.LinearLocallyFinite`:
```lean
instance (priority := 100) [LocallyFiniteOrder ι] [SuccOrder ι] : IsSuccArchimedean ι
```
**Requires**: First prove `LocallyFiniteOrder`, then get `IsSuccArchimedean` automatically.

#### Path B: IsSuccArchimedean -> LocallyFiniteOrder is NOT needed
From `Mathlib.Order.SuccPred.LinearLocallyFinite` line 378:
```lean
noncomputable def orderIsoIntOfLinearSuccPredArch [NoMaxOrder ι] [NoMinOrder ι] [hι : Nonempty ι] :
    ι ≃o ℤ
```
**Key Insight**: If we prove `IsSuccArchimedean` directly, we get `ι ≃o Z` without needing `LocallyFiniteOrder`!

### 2. LocallyFiniteOrder Construction Methods

Three main approaches found:

#### 2a. `LocallyFiniteOrder.ofFiniteIcc` (line 627)
```lean
noncomputable def LocallyFiniteOrder.ofFiniteIcc (h : forall a b : alpha, (Set.Icc a b).Finite) :
    LocallyFiniteOrder alpha
```
**Usage**: Prove `Set.Icc a b` is finite for all `a b`, then construct LocallyFiniteOrder.
**Verification**: `lean_local_search` confirmed existence of `Set.finite_Icc` theorem.

#### 2b. `LocallyFiniteOrder.ofIcc` (line 168)
```lean
def LocallyFiniteOrder.ofIcc (alpha : Type*) [PartialOrder alpha] [DecidableEq alpha]
    (finsetIcc : alpha -> alpha -> Finset alpha)
    (mem_Icc : forall a b x, x in finsetIcc a b <-> a <= x and x <= b) :
    LocallyFiniteOrder alpha
```
**Usage**: Directly provide a function `finsetIcc` computing the Finset.

#### 2c. Transfer via OrderIso (from LinearLocallyFinite.lean)
Since `DiscreteTimelineQuot ≃o Z` (via `orderIsoIntOfLinearSuccPredArch`), and Z has LocallyFiniteOrder, we could transfer it back if needed.

### 3. The succFn Pattern in LinearLocallyFinite

From `Mathlib.Order.SuccPred.LinearLocallyFinite`:
```lean
noncomputable def succFn (i : iota) : iota :=
  (exists_glb_Ioi i).choose

theorem succFn_spec (i : iota) : IsGLB (Set.Ioi i) (succFn i) :=
  (exists_glb_Ioi i).choose_spec

theorem le_succFn (i : iota) : i <= succFn i
```

**Critical for sorry #1** (`discrete_timeline_lt_succFn`):
- The code already uses `LinearLocallyFiniteOrder.succFn`
- Need to prove `a < succFn a` (strict, not just `a <= succFn a`)
- This requires proving the order is NOT dense at `a`

### 4. The Core Technical Challenge

From line 123-135 of LinearLocallyFinite.lean:
```lean
theorem isMax_of_succFn_le [LocallyFiniteOrder iota] (i : iota) (hi : succFn i <= i) : IsMax i := by
  refine fun j _ => not_lt.mp fun hij_lt => ?_
  have h_succFn_eq : succFn i = i := le_antisymm hi (le_succFn i)
  -- Uses Finset.Ioc finiteness to derive contradiction
```

**Implication**: The proof that `succFn` is strict relies on `LocallyFiniteOrder` (specifically, that `Finset.Ioc i j` is finite and thus has a GLB that's actually in the set).

### 5. IsSuccArchimedean Instance Pattern

From line 166-193:
```lean
instance (priority := 100) [LocallyFiniteOrder iota] [SuccOrder iota] : IsSuccArchimedean iota where
  exists_succ_iterate_of_le := by
    intro i j hij
    -- Uses Finite.exists_ne_map_eq_of_infinite to show iteration must terminate
    -- Key: uses finiteness of Finset.Icc i j
```

**The pigeonhole argument**: If `succ^[n] i < j` for all n, then infinitely many distinct elements map into finite `Finset.Icc i j`, contradiction.

## Recommended Approach

### Option 1: Direct LocallyFiniteOrder (RECOMMENDED)

1. **Prove `LocallyFiniteOrder` on `DiscreteTimelineQuot`**:
   - Use `LocallyFiniteOrder.ofFiniteIcc`
   - Prove `(Set.Icc a b).Finite` using the staged construction properties
   - The staged construction adds finitely many MCSs per stage
   - Between any two quotient elements, finitely many stages separate them

2. **Then get all instances for free**:
   - `SuccOrder` from `LinearLocallyFiniteOrder.succOrder`
   - `PredOrder` from `LinearLocallyFiniteOrder.predOrder`
   - `IsSuccArchimedean` from the existing instance

### Option 2: Direct IsSuccArchimedean (Alternative)

If LocallyFiniteOrder is hard to prove directly:

1. Prove `IsSuccArchimedean` by showing any two comparable elements have finite gap
2. Use `orderIsoIntOfLinearSuccPredArch` to get `T ≃o Z`
3. But this still requires proving the sorries for `SuccOrder` first

### Why Option 1 is Better

The current code structure has:
- `SuccOrder` defined using `LinearLocallyFiniteOrder.succFn`
- But `succFn` properties like `succFn_le_of_lt` require `LocallyFiniteOrder`

Without `LocallyFiniteOrder`, the current approach cannot work - `succFn_le_of_lt` has signature:
```lean
theorem succFn_le_of_lt (i j : iota) (hij : i < j) : succFn i <= j
```

## Evidence (Verified Lemmas)

All verified via `lean_local_search`:

| Lemma | File | Purpose |
|-------|------|---------|
| `LocallyFiniteOrder` | `Mathlib/Order/Interval/Finset/Defs.lean` | Base class |
| `LocallyFiniteOrder.ofFiniteIcc` | `Mathlib/Order/Interval/Finset/Defs.lean` | Constructor from interval finiteness |
| `Set.finite_Icc` | `Mathlib/Order/Interval/Finset/Defs.lean` | Interval finiteness in LocallyFiniteOrder |
| `LinearLocallyFiniteOrder.succFn` | `Mathlib/Order/SuccPred/LinearLocallyFinite.lean` | Successor function |
| `LinearLocallyFiniteOrder.succFn_le_of_lt` | `Mathlib/Order/SuccPred/LinearLocallyFinite.lean` | Key SuccOrder property |
| `IsSuccArchimedean` | `Mathlib/Order/SuccPred/Archimedean.lean` | Target class |
| `Int.instIsSuccArchimedean` | (from leanfinder) | Z is IsSuccArchimedean |

## Confidence Level

**HIGH confidence** that `LocallyFiniteOrder` approach is correct:
- Clear Mathlib precedent for the pattern
- All necessary lemmas exist and are verified
- The current code structure already imports `LinearLocallyFinite.lean`
- The approach matches the documented intent in DiscreteTimeline.lean comments

**MEDIUM confidence** on proving `Set.Icc a b` finiteness:
- Requires understanding staged construction cardinality
- May need additional lemmas about `buildDiscreteStagedTimeline`
- The algebraic structure (quotient of MCS) may complicate counting

## Next Steps for Implementation

1. Add `LocallyFiniteOrder` instance to `DiscreteTimelineQuot`
2. Prove interval finiteness using staged construction properties
3. Remove custom `succFn`/`predFn` definitions (use Mathlib's)
4. The three sorries will be resolved by the automatic instances

## Files Referenced

- `/home/benjamin/Projects/ProofChecker/.lake/packages/mathlib/Mathlib/Order/SuccPred/LinearLocallyFinite.lean`
- `/home/benjamin/Projects/ProofChecker/.lake/packages/mathlib/Mathlib/Order/Interval/Finset/Defs.lean`
- `/home/benjamin/Projects/ProofChecker/.lake/packages/mathlib/Mathlib/Order/SuccPred/Archimedean.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean`
