# Implementation Summary: Task 275 — Surface R/WU/T/WS Bimodal Interaction

## Overview

Task 275 surfaces four existing derived temporal operators (Release R, Weak Until WU, Trigger T, Weak Since WS) into the automation layer. These operators were defined in `Formula.lean` but invisible to `hasBimodalInteraction`, `Formula.complexity`, and the formula enumerator.

## Changes Made

### Phase 1: Formula.complexity Pattern-Matching [COMPLETED]

**File**: `Theories/Bimodal/Syntax/Formula.lean`

Added 4 pattern-match cases to `Formula.complexity`:

- `WU(φ, ψ)` → `1 + φ.complexity + ψ.complexity`
- `WS(φ, ψ)` → `1 + φ.complexity + ψ.complexity`
- `R(φ, ψ)` → `1 + φ.complexity + ψ.complexity`
- `T(φ, ψ)` → `1 + φ.complexity + ψ.complexity`

**Ordering**: WU/WS placed before G/H to prevent shadowing; R/T placed after G/H because `release φ bot` and `trigger φ bot` are structurally identical to `G φ` and `H φ` respectively.

**Verification**: `#eval` smoke tests confirm complexity = 3 for atomic operands (was 8-9).

### Phase 2: hasDerivedTemporal / hasBimodalInteraction Extension [COMPLETED]

**File**: `Theories/Bimodal/Automation/FormulaEnumerator.lean`

Extended `hasDerivedTemporal` with 4 new pattern branches:
- WU pattern: `imp (imp (untl _ _) bot) (imp (untl (imp _ bot) (imp bot bot)) bot)`
- WS pattern: `imp (imp (snce _ _) bot) (imp (snce (imp _ bot) (imp bot bot)) bot)`
- R pattern: `untl (imp _ bot) (imp _ bot)` inside `imp inner bot`
- T pattern: `snce (imp _ bot) (imp _ bot)` inside `imp inner bot`

**Verification**: `hasBimodalInteraction (box (release p q))` returns `true`.

### Phase 3: Enumerator Sampling Integration [COMPLETED]

**File**: `Theories/Bimodal/Automation/FormulaEnumerator.lean`

1. **`enumExactHelper`**: Added R/WU/T/WS generation in the binary temporal section alongside `untl`/`snce`.

2. **`sampleOne`**: 
   - Fixed stale F/P overhead from `sizeBudget - 4` → `sizeBudget - 1`
   - Fixed stale G/H overhead from `sizeBudget - 8` → `sizeBudget - 1`
   - Added new derived temporal binary branch with R/WU/T/WS generation

3. **`sampleOneRandom`**: 
   - Added `hasDerivedTemporalBinary` flag and new choice branch
   - Added R/WU/T/WS generation with random sub-choice selection

4. **`randomSubFormula`**: 
   - Fixed stale F/P overhead from `maxSize - 4` → `maxSize - 1`
   - Fixed stale G/H overhead from `maxSize - 8` → `maxSize - 1`
   - Added new choice branch (9) for R/WU/T/WS generation

### Phase 4: Testing & Dataset Validation [COMPLETED]

**File**: `Tests/BimodalTest/Syntax/FormulaPropertyTest.lean`

Added 4 complexity property tests:
- `(Formula.release p q).complexity = 1 + p.complexity + q.complexity`
- `(Formula.weak_until p q).complexity = 1 + p.complexity + q.complexity`
- `(Formula.trigger p q).complexity = 1 + p.complexity + q.complexity`
- `(Formula.weak_since p q).complexity = 1 + p.complexity + q.complexity`

**Dataset validation**:
- Baseline bimodal count (pre-change): 2616
- Post-change bimodal count: 6072
- Increase: ~2.3x (substantial increase, though slightly below the 3x target due to structural constraints in the enumeration)

## Build Status

- `lake build` passes with 1685 jobs (no new errors)
- `#eval` smoke tests in `Formula.lean` pass
- `#eval` smoke tests in `FormulaEnumerator.lean` pass
- `Tests/BimodalTest/Syntax/FormulaPropertyTest.lean` tests compile (test suite has pre-existing unrelated failures in `Generators.lean`)

## Risks Addressed

- **Pattern-match shadowing**: WU/WS placed before G/H; R/T placed after G/H
- **Stale overhead constants**: All F/P/G/H overheads updated to 1
- **No proof breakage**: Changes confined to automation layer (no proof system or semantics touched)

## Files Modified

1. `Theories/Bimodal/Syntax/Formula.lean` — 4 new complexity cases + smoke tests
2. `Theories/Bimodal/Automation/FormulaEnumerator.lean` — `hasDerivedTemporal`, `enumExactHelper`, `sampleOne`, `sampleOneRandom`, `randomSubFormula`
3. `Tests/BimodalTest/Syntax/FormulaPropertyTest.lean` — 4 complexity property tests

## Verification Checklist

- [x] `lake build` succeeds across all modified files
- [x] Complexity property tests for R, WU, T, WS compile
- [x] `#eval` smoke tests on `Formula.lean` return expected values (complexity = 3 for atomic operands)
- [x] `#eval` smoke tests on `FormulaEnumerator.lean` confirm `hasBimodalInteraction (box (release p q)) = true`
- [x] C5 dataset regeneration completes without errors
- [x] Bimodal formula count increased from 2616 to 6072 (~2.3x)
