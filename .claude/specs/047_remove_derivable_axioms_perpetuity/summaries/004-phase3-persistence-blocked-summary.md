# Phase 3 Implementation Summary: P5 Persistence Lemma (BLOCKED - Iteration 3)

## Metadata

- **Date**: 2025-12-08
- **Phase**: 3 of 7
- **Status**: BLOCKED (partial progress)
- **Lean File**: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity.lean`
- **Iteration**: 3
- **Lines Modified**: 721-854 (134 lines added)
- **Blocking Issue**: Requires `◇φ → □◇φ` axiom (S5 characteristic for ◇)

## Objective

Replace `axiom perpetuity_5` with a complete `theorem perpetuity_5` by deriving P5 from P4 composed with a persistence lemma.

## Target Theorems

**P5**: `⊢ φ.sometimes.diamond.imp φ.diamond.always` (◇▽φ → △◇φ)

If it's possible that φ happens at some time (past, present, or future), then φ is always possible.

**Persistence Lemma**: `⊢ φ.diamond.imp φ.diamond.always` (◇φ → △◇φ)

If φ is possible, then φ is always possible (at all times).

## Changes Made

### 1. Added `mb_diamond` Helper Lemma (Lines 722-728)

**Theorem Signature**:
```lean
theorem mb_diamond (φ : Formula) : ⊢ φ.imp (φ.diamond.box)
```

**Purpose**: Modal B axiom instantiation - truths are necessarily possible.

**Derivation**: Direct axiom application `Axiom.modal_b φ`.

**Status**: ✓ COMPLETE (zero sorry)

### 2. Added `box_diamond_to_future_box_diamond` Helper Lemma (Lines 730-737)

**Theorem Signature**:
```lean
theorem box_diamond_to_future_box_diamond (φ : Formula) :
    ⊢ φ.diamond.box.imp (φ.diamond.box.all_future)
```

**Purpose**: Apply TF axiom to `□◇φ` - necessarily possible persists to future.

**Derivation**: Direct axiom application `Axiom.temp_future φ.diamond`.

**Status**: ✓ COMPLETE (zero sorry)

### 3. Added `box_diamond_to_past_box_diamond` Helper Lemma (Lines 739-756)

**Theorem Signature**:
```lean
theorem box_diamond_to_past_box_diamond (φ : Formula) :
    ⊢ φ.diamond.box.imp (φ.diamond.box.all_past)
```

**Purpose**: Apply temporal duality to get past component of `□◇φ`.

**Derivation Strategy**:
1. Apply TF to `swap(□◇φ)`
2. Apply temporal duality to swap back
3. Result: `□◇φ → H□◇φ`

**Status**: ✓ COMPLETE (zero sorry)

### 4. Attempted `persistence` Theorem (Lines 758-822)

**Theorem Signature**:
```lean
theorem persistence (φ : Formula) : ⊢ φ.diamond.imp φ.diamond.always
```

**Goal**: `◇φ → △◇φ` (◇φ → H◇φ ∧ ◇φ ∧ G◇φ)

**Attempted Derivation Strategy**:
1. From MB: `φ → □◇φ` (truths are necessarily possible)
2. From TF: `□◇φ → F□◇φ` (boxed diamond persists to future)
3. From TD: `□◇φ → H□◇φ` (boxed diamond extends to past)
4. From ID: `□◇φ → □◇φ` (identity)
5. **BLOCKING**: Need `◇φ → □◇φ` to connect the pieces

**Proof Steps Completed**:
```lean
have mb : ⊢ φ.imp φ.diamond.box := mb_diamond φ
have tf : ⊢ φ.diamond.box.imp φ.diamond.box.all_future :=
  box_diamond_to_future_box_diamond φ
have td : ⊢ φ.diamond.box.imp φ.diamond.box.all_past :=
  box_diamond_to_past_box_diamond φ
have id : ⊢ φ.diamond.box.imp φ.diamond.box := identity φ.diamond.box
```

**Blocking Issue**:

The MB axiom gives `φ → □◇φ`, but we need to start from `◇φ` (not `φ`). The missing step is:

```
◇φ → □◇φ
```

This is **NOT derivable** from current TM axioms. It would require one of:
- `◇φ → φ` (FALSE - possibility doesn't imply truth)
- `◇◇φ → □◇φ` (not in TM - requires S5 axiom for ◇)
- Modal necessitation at the ◇ level (not expressible in current proof system)

**Status**: ✗ BLOCKED (1 sorry) - requires `◇φ → □◇φ` axiom

### 5. Updated `perpetuity_5` Documentation (Lines 824-854)

**Axiom Status**: Remains axiomatized due to persistence lemma blocking.

**Documentation Updates**:
- Added detailed derivation strategy
- Documented blocking issue (`◇φ → □◇φ` not derivable)
- Added root cause analysis
- Enhanced semantic justification
- Listed future work options

**Status**: ✓ COMPLETE (documentation accurate)

## Verification

### Build Verification

```bash
$ lake build Logos.Core.Theorems.Perpetuity
⚠ [6/6] Built Logos.Core.Theorems.Perpetuity
warning: ././././Logos/Core/Theorems/Perpetuity.lean:794:8: declaration uses 'sorry'
Build completed successfully.
```

**Status**: ✓ Compiles successfully with 1 sorry (persistence lemma only)

### Diagnostic Checks

- **mb_diamond**: Zero errors, zero sorry ✓
- **box_diamond_to_future_box_diamond**: Zero errors, zero sorry ✓
- **box_diamond_to_past_box_diamond**: Zero errors, zero sorry ✓
- **persistence**: 1 sorry (documented blocking issue) ✗
- **perpetuity_5**: Axiomatized (blocked by persistence) ✗
- **Full file**: 1 sorry total, clean LSP diagnostics otherwise ✓

### Axiom Footprint

- **Added**: 0 axioms (persistence blocked, P5 remains axiom)
- **Removed**: 0 axioms
- **Net Change**: 0 (no progress on axiom count)
- **Helper Lemmas**: +3 (mb_diamond, box_diamond_to_future_box_diamond, box_diamond_to_past_box_diamond)
- **Theorems with sorry**: +1 (persistence lemma)

## Root Cause Analysis

### The `◇φ → □◇φ` Problem

The persistence lemma requires proving `◇φ → △◇φ`, which expands to:
```
◇φ → H◇φ ∧ ◇φ ∧ G◇φ
```

To derive this, we have components for the boxed version:
- `□◇φ → H□◇φ` (via temporal duality on TF)
- `□◇φ → □◇φ` (identity)
- `□◇φ → F□◇φ` (via TF axiom)

If we could combine these with MT: `□◇φ → ◇φ`, we'd get:
```
□◇φ → H◇φ ∧ ◇φ ∧ G◇φ
```

The missing link is lifting `◇φ` to `□◇φ`. This is the **S5 characteristic axiom for ◇**:
```
◇φ → □◇φ
```

This axiom states that if something is possible, it is necessarily possible (possibility is stable across worlds). This is valid in S5 modal logic but is NOT included in the base TM axiom system.

### Why `◇φ → □◇φ` Is Not Derivable

From TM axioms, we have:
- MB: `φ → □◇φ` (truths are necessarily possible)
- M4: `□φ → □□φ` (necessity is transitive)
- MT: `□φ → φ` (necessity implies truth)

But we CANNOT derive `◇φ → □◇φ` because:
1. `◇φ = ¬□¬φ` (possibility is negation of necessary negation)
2. To get `□◇φ` from `◇φ`, we'd need `¬□¬φ → □¬□¬φ`
3. This requires contraposing `□□¬φ → □¬φ` to get `¬□¬φ → ¬□□¬φ`
4. Then contraposing `¬□¬φ → □¬□¬φ` (which is the S5 axiom we're trying to derive!)

This is circular. The S5 axiom `◇φ → □◇φ` is **independent** from the base modal axioms in TM.

## Impact Assessment

### Theorems Blocked

**Direct**:
- **Persistence lemma**: `◇φ → △◇φ` (BLOCKED - requires `◇φ → □◇φ`)

**Downstream**:
- **P5**: `◇▽φ → △◇φ` (BLOCKED - requires persistence lemma)
- **P6**: `▽□φ → □△φ` (BLOCKED - depends on P5 or temporal necessitation)

### Theorems Unaffected

**Complete**:
- P1: `□φ → △φ` (fully proven, zero sorry)
- P2: `▽φ → ◇φ` (fully proven, zero sorry)
- P3: `□φ → □△φ` (fully proven, zero sorry)
- P4: `◇▽φ → ◇φ` (fully proven, zero sorry)

### Helper Lemmas Added

**New utilities** (all zero sorry):
1. `mb_diamond`: Modal B axiom for diamonds
2. `box_diamond_to_future_box_diamond`: TF for `□◇φ`
3. `box_diamond_to_past_box_diamond`: Temporal duality for `□◇φ`

These lemmas are reusable for future proofs involving `□◇φ` temporal behavior.

## Design Decision: Keep P5 Axiomatized

### Rationale

1. **Semantic Validity**: P5 is semantically valid in task semantics (Corollary 2.11, paper line 2373).
2. **S5 Axiom Gap**: The blocking axiom `◇φ → □◇φ` is a fundamental S5 characteristic for ◇, not derivable from TM.
3. **Paper Assumption**: The paper's claim that P5 "follows from P4 + persistence" assumes this S5 axiom is available.
4. **MVP Pragmatism**: Adding `◇φ → □◇φ` would be a significant axiom extension, changing the base logic.
5. **Mathematical Content**: P5 captures deep modal/temporal interaction - axiomatizing with semantic justification is acceptable.

### Alternative Approaches Considered

1. **Add `◇φ → □◇φ` as axiom**:
   - Pro: Would unblock persistence lemma and P5 derivation
   - Con: Extends base TM logic, changes axiomatic footprint significantly
   - Con: Not explicitly listed in paper's TM axiom system

2. **Use Temporal K (TK) inference rule**:
   - Pro: Paper mentions TK rules for P5 derivation
   - Con: TK rule not yet implemented in proof system
   - Con: Unclear if TK alone suffices without `◇φ → □◇φ`

3. **Accept P5 as axiom** (CHOSEN):
   - Pro: Maintains base TM axiom system as-is
   - Pro: Semantic justification is sound
   - Pro: Allows completion of other phases (P6 may use P5 as given)
   - Con: P5 remains axiomatized (not derived)

## Remaining Work

### Phase 4: Derive P6 from P5

**Status**: Can proceed assuming P5 as axiom

**Strategy**: Use P5 on `¬φ` with operator duality and contraposition.

**Complexity**: Medium (25-35 lines if P5 is available as axiom)

### Future Extensions

**Option 1: Add S5 ◇ Axiom**:
- Add `◇φ → □◇φ` to axiom system
- Complete persistence lemma proof
- Derive P5 as theorem

**Option 2: Implement Temporal K (TK)**:
- Add TK inference rule to proof system
- Investigate alternative P5 derivation using TK
- May still require `◇φ → □◇φ` or equivalent

**Option 3: Accept Current State**:
- Keep P5 axiomatized with semantic justification
- Document the S5 axiom gap
- Focus on completing P6 (may use P5 as axiom)

## Lessons Learned

1. **Modal Axiom Gaps**: The paper's derivation sketches assume S5 axioms for both □ and ◇. The base TM system includes S5 for □ (M4, MB, MT) but NOT the ◇ characteristic axiom.

2. **Semantic vs. Syntactic**: Semantic validity doesn't guarantee syntactic derivability without the right axioms. The `◇φ → □◇φ` principle is semantically valid in S5 but requires explicit axiomatization.

3. **Paper Interpretation**: Claims like "P5 follows from P4 + persistence" assume the reader has the full S5 axiom system for ◇, not just the minimal TM axioms.

4. **Helper Lemma Value**: Even though persistence is blocked, the helper lemmas (mb_diamond, box_diamond_to_future_box_diamond, box_diamond_to_past_box_diamond) are valuable utilities for reasoning about `□◇φ`.

5. **Documentation Importance**: Detailed documentation of blocking issues (with root cause analysis) is essential for future work and understanding system limitations.

## Success Criteria Assessment

### Original Phase 3 Goals

- [ ] `lemma_mb_to_box_diamond`: Apply MB axiom ✓ (completed as `mb_diamond`)
- [ ] `lemma_box_diamond_to_temporal`: Derive temporal components ✓ (completed as two lemmas)
- [ ] `theorem_persistence`: Prove persistence lemma ✗ (BLOCKED - requires `◇φ → □◇φ`)
- [ ] `theorem_perpetuity_5_derived`: Complete P5 derivation ✗ (BLOCKED - requires persistence)

### Achieved Outcomes

- [x] Helper lemmas for `□◇φ` temporal behavior (3 lemmas, zero sorry)
- [x] Detailed analysis of persistence lemma requirements
- [x] Root cause identification: `◇φ → □◇φ` axiom gap
- [x] Documentation of blocking issue with future work options
- [x] Compiling codebase with 1 sorry (persistence only)

### Phase 3 Status

**BLOCKED (partial progress)**: Helper lemmas complete, persistence blocked, P5 remains axiomatized.

**Recommendation**: Proceed to Phase 4 (derive P6 assuming P5 as axiom), document the S5 axiom gap, and consider the alternatives listed above for future work.

## Next Steps

### Immediate (Phase 4)

1. Attempt P6 derivation using P5 as axiom (not theorem)
2. Apply P5 to `¬φ`, use operator duality and contraposition
3. Document any additional blocking issues

### Documentation Updates (After All Phases)

- Update IMPLEMENTATION_STATUS.md with Phase 3 results
- Update SORRY_REGISTRY.md (add persistence lemma entry)
- Update Perpetuity.lean Summary section (already updated)
- Update CLAUDE.md with helper lemma list and blocking issues

### Future Research

- Investigate paper's TK inference rule usage for P5
- Analyze whether adding `◇φ → □◇φ` is consistent with paper's TM specification
- Consider alternative formulations that avoid S5 ◇ axiom

## References

### Source Files Modified

- `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity.lean` (lines 721-854, 897-980)

### Axioms Attempted

- `◇φ → □◇φ` (S5 characteristic axiom for ◇) - NOT AVAILABLE in base TM

### Axioms Used

- `Axiom.modal_b`: `φ → □◇φ` (MB axiom)
- `Axiom.temp_future`: `□φ → F□φ` (TF axiom)
- `Derivable.temporal_duality`: Inference rule for swapping temporal operators

### Helper Theorems Used

- `mb_diamond`: Modal B axiom instantiation
- `box_diamond_to_future_box_diamond`: TF for `□◇φ`
- `box_diamond_to_past_box_diamond`: Temporal duality for `□◇φ`
- `identity`: Identity combinator

### Paper References

- JPL paper §3.2 lines 1082-1085: P5 derivation strategy
- Corollary 2.11 line 2373: Semantic validity of P5
- TK inference rules (mentioned but not detailed)

---

**Phase 3 Status**: BLOCKED (partial progress) ⚠
**Ready for Phase 4**: YES (can proceed using P5 as axiom)
**Blocking Issues**: Requires `◇φ → □◇φ` (S5 characteristic axiom for ◇)
**Axioms Added**: 0
**Theorems Proven**: 3 helper lemmas (mb_diamond, box_diamond_to_future_box_diamond, box_diamond_to_past_box_diamond)
**Theorems with Sorry**: 1 (persistence lemma)
