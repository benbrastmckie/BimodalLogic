# Research Report: Task #588

**Task**: Complete Truth Lemma in Metalogic_v2
**Date**: 2026-01-18
**Focus**: Prove `necessitation_lemma` and identify all sorries in TruthLemma.lean

## Summary

Task 588 requires completing the Truth Lemma in Metalogic_v2 by filling the sorry in `necessitation_lemma` (line 160 of TruthLemma.lean). Research confirms this is the **only sorry** in TruthLemma.lean. The proof requires a key infrastructure lemma `set_mcs_closed_under_derivation` which exists in the old Metalogic but has not been ported to Metalogic_v2.

## Findings

### Current State of TruthLemma.lean

**File**: `Theories/Bimodal/Metalogic_v2/Representation/TruthLemma.lean`

**Sorry Count**: 1

| Lemma | Line | Status | Description |
|-------|------|--------|-------------|
| `necessitation_lemma` | 155-160 | **SORRY** | If `[] |- phi`, then `box phi in w.carrier` |
| `canonical_modus_ponens` | 167-170 | Proven | Uses `mcs_modus_ponens` |
| `canonical_complete` | 177-179 | Proven | Uses `mcs_contains_or_neg` |

**Current `necessitation_lemma` Statement**:
```lean
theorem necessitation_lemma (w : CanonicalWorldState) {φ : Formula}
    (h_derivable : ContextDerivable [] φ) : (Formula.box φ) ∈ w.carrier := by
  -- If [] ⊢ φ, then by necessitation rule, [] ⊢ □φ
  -- Since every MCS extends [], and MCS is deductively closed, □φ ∈ w.carrier
  -- This requires the deductive closure property
  sorry
```

### Proof Strategy Analysis

The proof requires establishing: if `[] |- phi`, then `box phi in w.carrier` for any canonical world `w`.

**Step-by-step approach**:

1. **Unwrap `ContextDerivable`**: `ContextDerivable [] phi` is `Nonempty (DerivationTree [] phi)` by definition (Provability.lean line 44)

2. **Apply Necessitation Rule**: `DerivationTree.necessitation : DerivationTree [] phi -> DerivationTree [] (Formula.box phi)` (Derivation.lean line 108-109)

3. **Bridge to MCS Membership**: Need to show that any theorem (derivable from `[]`) is in every maximal consistent set

### Missing Infrastructure

**Key Lemma Needed**: A set-based version of MCS closure under derivation

**Exists in Old Metalogic** (Completeness.lean line 577):
```lean
lemma set_mcs_closed_under_derivation {S : Set Formula} {φ : Formula}
    (h_mcs : SetMaximalConsistent S)
    (L : List Formula) (h_sub : ∀ ψ ∈ L, ψ ∈ S)
    (h_deriv : DerivationTree L φ) : φ ∈ S
```

**Not Present in Metalogic_v2**: Confirmed via grep search - this lemma needs to be ported or its equivalent created.

**Simpler Alternative for Theorems**: For the specific case of theorems (L = []), we need:
```lean
theorem theorem_in_mcs {S : Set Formula} {φ : Formula}
    (h_mcs : SetMaximalConsistent S)
    (h_deriv : DerivationTree [] φ) : φ ∈ S
```

This is a special case where `L = []`, so `h_sub : ∀ ψ ∈ [], ψ ∈ S` is trivially true.

### Related Infrastructure in Metalogic_v2

**Available in Core/MaximalConsistent.lean**:
- `SetMaximalConsistent` (def, line 90-95)
- `SetConsistent` (def, line 81-88)
- `set_mcs_finite_subset_consistent` (lemma, line 400-403)
- `maximal_consistent_closed` (theorem, line 423): For list-based MCS, not set-based

**Available in Representation/CanonicalModel.lean**:
- `mcs_modus_ponens` (theorem, line 274): Proven
- `mcs_contains_or_neg` (theorem, line 231): Proven
- `extract_neg_derivation` (lemma, line 180): Helper for MCS proofs

### Proof Dependencies

The full proof chain for `necessitation_lemma`:

```
ContextDerivable [] φ
    ↓ (unfold definition)
Nonempty (DerivationTree [] φ)
    ↓ (DerivationTree.necessitation)
DerivationTree [] (Formula.box φ)
    ↓ (set_mcs_closed_under_derivation with L = [])
Formula.box φ ∈ S  where S = w.carrier and SetMaximalConsistent S
    ↓ (CanonicalWorldState definition)
Formula.box φ ∈ w.carrier
```

### Downstream Dependencies

If `necessitation_lemma` is completed:

1. **TruthLemma.lean**: Becomes sorry-free
2. **RepresentationTheorem.lean**: Already sorry-free (imports TruthLemma)
3. **ContextProvability.lean**: Already sorry-free (imports from old Metalogic)

## Recommendations

### Option A: Port `set_mcs_closed_under_derivation` (Recommended)

1. Copy the proof from `Metalogic/Completeness.lean` (lines 577-654)
2. Place in `Metalogic_v2/Core/MaximalConsistent.lean` or `Representation/CanonicalModel.lean`
3. This is reusable for other MCS closure proofs

**Estimated effort**: 30-60 minutes

### Option B: Prove Specialized `theorem_in_mcs`

1. Prove directly for the case L = [] (simpler than full generality)
2. The proof simplifies since `∀ ψ ∈ [], ψ ∈ S` is trivially true

**Core argument**: If `S` is SetMaximalConsistent and `[] |- phi`, then by contradiction:
- Assume `phi not in S`
- By maximality, `insert phi S` is inconsistent
- But `[] |- phi` and `[] subseteq S` means any inconsistency in `insert phi S` contradicts `S` being consistent

**Estimated effort**: 20-40 minutes

### Option C: Direct Inline Proof

Prove `necessitation_lemma` directly by:
1. Unfold definitions
2. Show that theorems cannot be absent from an MCS without contradiction
3. Uses only existing Metalogic_v2 infrastructure

**Estimated effort**: 40-60 minutes

## Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| Deduction theorem dependency | Low | Already proven in Metalogic_v2 |
| Set vs List type mismatch | Medium | Existing bridge lemmas available |
| Circular import issues | Low | Place new lemma in MaximalConsistent.lean |

## References

### Lean Files
- `Theories/Bimodal/Metalogic_v2/Representation/TruthLemma.lean`
- `Theories/Bimodal/Metalogic_v2/Core/MaximalConsistent.lean`
- `Theories/Bimodal/Metalogic_v2/Core/Provability.lean`
- `Theories/Bimodal/Metalogic_v2/Representation/CanonicalModel.lean`
- `Theories/Bimodal/Metalogic/Completeness.lean` (source for porting)
- `Theories/Bimodal/ProofSystem/Derivation.lean` (necessitation rule)

### Key Definitions
- `ContextDerivable` (Provability.lean:44): `Nonempty (DerivationTree Gamma phi)`
- `SetMaximalConsistent` (MaximalConsistent.lean:90-95): Consistency + maximality
- `DerivationTree.necessitation` (Derivation.lean:108): `[] |- phi -> [] |- box phi`

## Next Steps

1. **Choose implementation approach**: Option B (specialized lemma) is fastest
2. **Implement the lemma**: Add `theorem_in_mcs` or equivalent
3. **Complete `necessitation_lemma`**: Use the new lemma
4. **Verify**: Run `lake build` to confirm TruthLemma.lean is sorry-free
5. **Proceed to task 589**: Complete RepresentationTheorem using sorry-free TruthLemma
