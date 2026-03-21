# Handoff: Task 956 Phase 6a - Strict Density (Iteration 5 - FINAL)

**Session**: sess_1773353508_f76726
**Timestamp**: 2026-03-12T22:00:00Z
**Status**: PARTIAL - 13 sorries remain, requires proof restructure

## Summary of Iteration 5 Work

Added M-reflexivity case splits at key sorry locations:
1. Lines 860/865 in `density_frame_condition_strict` (Case A, V sees M back)
2. Lines 921/923 in `density_frame_condition_strict` (Case A, W₁ sees M back)

### Key Lemma Proven

When M is NOT reflexive, ANY forward witness W from M (with CanonicalR M W) automatically satisfies ¬CanonicalR W M.

**Proof sketch**:
- M not reflexive: ∃ phi with G(phi) ∈ M and phi ∉ M
- By T4: G(G(phi)) ∈ M, so G(phi) ∈ GContent(M)
- CanonicalR M W means GContent(M) ⊆ W, so G(phi) ∈ W
- phi ∈ GContent(W)
- If CanonicalR W M (i.e., GContent(W) ⊆ M), then phi ∈ M
- Contradiction with phi ∉ M!

This eliminates the M non-reflexive cases - they now derive `exfalso` from the contradiction.

## Remaining Sorries (13 total)

### Category 1: Case B1 (M' reflexive, G(delta) ∈ M) - 9 sorries
Lines: 486, 490, 492, 585, 589, 591, 641, 646, 653

**Why hard**: When M' is reflexive, any W that sees M' is also seen by M'. So `¬CanonicalR M' W` is impossible for any intermediate W that sees M'.

### Category 2: Case A with M reflexive - 2 sorries
Lines: 865, 923

**Why hard**: When M is reflexive, the iteration produces witnesses equivalent to M indefinitely. Need termination measure.

### Category 3: non_reflexive_target with M reflexive - 2 sorries
Lines: 1668, 1753

**Why hard**: Same as Category 2. M reflexive traps all density witnesses in M's equivalence class.

## Mathematical Analysis

### The Fundamental Issue

When M is reflexive:
- GContent(M) ⊆ M (by reflexivity)
- Any density witness W from M has GContent(M) ⊆ W
- For W to see M back, need GContent(W) ⊆ M
- By T4, GContent(W) ⊇ GContent(M), so if GContent(W) ⊆ M, we have GContent(W) = GContent(M)
- This means W ~ M in the quotient ordering

The iteration `density(M, M') → W₁ → density(W₁, M') → W₂ → ...` keeps producing witnesses equivalent to M.

### Why Impossibility Fails

In the "W ~ M" case, we CANNOT derive a contradiction:
- M ~ W is consistent with M < M' strictly
- The quotient order [M] < [M'] has [W] = [M]
- W is strictly below M' but equivalent to M

This is NOT a contradiction - it just means W is not a strict intermediate.

### Termination Approach Required

The proof needs well-founded recursion on a termination measure:

**Option A**: Subformula count of distinguishing formula
- Each iteration uses a distinguishing formula from GContent(M') \ M'
- The construction might "use up" candidates

**Option B**: Cardinality of candidate set
- Define candidates = {phi | G(phi) ∈ M' and could witness strict gap}
- Show each iteration reduces this set

**Option C**: Direct construction
- Find a formula phi such that adding G(phi) to the density seed breaks equivalence to M
- This requires understanding exactly which formulas the Lindenbaum extension adds

## What NOT to Try

1. **Direct contradiction in W ~ M case**: This is mathematically consistent
2. **Using gamma to prove W doesn't see M**: G(gamma) ∉ W doesn't imply W doesn't see M when M is reflexive
3. **Infinite iteration without termination**: Must prove eventually escapes M's equivalence class

## Proof Restructure Required

The current proof structure cannot handle M-reflexive cases. Need one of:

1. **Well-founded recursion**: Add fuel parameter and prove decreasing
2. **Alternative distinguishing formula**: Find phi that M has but W doesn't
3. **Show M-reflexive case contradicts hypotheses**: Unlikely given analysis

## Files Modified

- `Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean`

## Next Steps for Future Iteration

1. Implement well-founded recursion with termination measure
2. Or: Prove M being reflexive is impossible in the presence of strict M < M' (if true)
3. Or: Find alternative construction that doesn't iterate

## References

- Plan: `specs/956_construct_d_as_translation_group_from_syntax/plans/implementation-022.md`
- Previous handoff: `specs/956_construct_d_as_translation_group_from_syntax/handoffs/phase-6a-handoff-20260312-iter4.md`
- Progress: `specs/956_construct_d_as_translation_group_from_syntax/progress/phase-6a-progress.json`
