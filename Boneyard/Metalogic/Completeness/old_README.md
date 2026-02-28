# Completeness Theorem

This directory contains the completeness theorems for TM bimodal logic.

**IMPORTANT**: The theorems here establish completeness with respect to FMP-INTERNAL validity
(`semantic_truth_at_v2` on SemanticWorldStates). Bridging to general TaskModel validity
is blocked for modal/temporal operators. See task 810 research-005 for details.

## Modules

| Module | Purpose | Status |
|--------|---------|--------|
| `Completeness.lean` | Module root, re-exports hierarchy | Complete |
| `FiniteStrongCompleteness.lean` | Strong completeness for List-based contexts | 1 sorry (validity bridge) |

## Archived Modules (Task 809)

The following modules were archived to `Boneyard/Metalogic_v5/Completeness/` because they depended on the Representation approach which contained sorries:

| Module | Why Archived |
|--------|--------------|
| `WeakCompleteness.lean` | Depended on UniversalCanonicalModel with 30+ sorries |
| `InfinitaryStrongCompleteness.lean` | Depended on UniversalCanonicalModel with 30+ sorries |

For sorry-free completeness, use:
- `Bimodal.Metalogic.FMP.semantic_weak_completeness` (weak completeness with FMP-internal validity)

**Note**: `finite_strong_completeness` has 1 sorry for the validity bridge (general validity -> FMP-internal validity).
This is blocked for modal/temporal operators. The sorry-free result uses FMP-internal validity directly.

## Key Theorems

### Finite-Premise Strong Completeness (`FiniteStrongCompleteness.lean`)

```lean
theorem finite_strong_completeness (Gamma : Context) (phi : Formula) :
    semantic_consequence Gamma phi -> ContextDerivable Gamma phi

theorem context_provable_iff_entails (Gamma : Context) (phi : Formula) :
    ContextDerivable Gamma phi <-> semantic_consequence Gamma phi
```

Extends weak completeness to List-based contexts via the deduction theorem.

**Key Construction**:
- `impChain`: Builds implication chain from context to formula
- `impChain Gamma phi = psi1 -> (psi2 -> ... -> (psin -> phi)...)`

## Dependency Flowchart

```
    FMP/SemanticCanonicalModel.lean
    semantic_weak_completeness
              |
              v
  FiniteStrongCompleteness.lean
```

## Design Notes

### Why Two Levels?

1. **Weak completeness** establishes the fundamental result for formulas alone
2. **Finite-premise strong** handles proofs from finite assumption sets (practical reasoning)

For infinitary strong completeness (Set-based contexts), the Representation approach
in Boneyard/Metalogic_v5/ provides this, but with trusted axioms (30 sorries).

### Soundness Integration

The bidirectional equivalences (e.g., `provable_iff_valid`) use the soundness theorem from `../Soundness/`.

## Dependencies

- **FMP**: `semantic_weak_completeness` (the canonical completeness result)
- **Soundness**: `soundness` (derivability implies validity)
- **Core**: `deduction_theorem`, MCS properties

## Related Files

- `../Soundness/README.md` - Soundness theorem (used for iff statements)
- `../FMP/README.md` - Contains `semantic_weak_completeness`
- `../Core/README.md` - Deduction theorem and MCS foundations

## Architectural Limitation: Validity Bridge

The `weak_completeness` theorem in `FiniteStrongCompleteness.lean` has the signature:
```lean
theorem weak_completeness (phi : Formula) : valid phi -> ContextDerivable [] phi
```

This requires bridging:
- `valid phi` (truth in ALL TaskModels)
- FMP-internal validity (truth at all SemanticWorldStates)

This bridge is **BLOCKED** for modal and temporal operators because the FMP model construction
uses permissive task relations and constant histories that don't properly model modal accessibility
or temporal structure. See `FMP/ConsistentSatisfiable.lean` for detailed analysis.

**Workaround**: Use `semantic_weak_completeness` directly with FMP-internal validity as the
semantic notion. This is sorry-free and sufficient for most applications.

## References

- Modal Logic, Blackburn et al., Chapter 4 (Completeness via Canonical Models)
- Task 810 research-005: Validity bridge blockage analysis

---

*Last updated: 2026-02-02 (Task 810 documentation update)*
