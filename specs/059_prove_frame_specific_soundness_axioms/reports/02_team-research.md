# Research Report: Task #59 — Strict Semantics Impact on Soundness Axioms

**Task**: 59 - Prove frame-specific soundness axioms
**Date**: 2026-03-31
**Mode**: Team Research (2 teammates)
**Session**: sess_1774994572_64eed3

## Summary

The current codebase uses **reflexive temporal semantics** (`≤` instead of `<`) for G and H operators, which makes the density, seriality_future, and seriality_past axioms **trivially valid** without requiring frame-specific type class constraints. The `DenselyOrdered` constraint is declared but never used in density proofs — the reflexive witness `t ≤ t` (`le_rfl`) suffices. A separate "Strict Temporal Extensions" research track (tasks 74-76, 998) plans to introduce G'/H' operators with strict semantics where these axioms would have non-trivial proofs. Task 59 can proceed independently.

## Key Findings

### 1. Reflexive Semantics Makes Density/Seriality Trivial (Teammate A)

**Truth.lean:124-125** defines temporal operators with `≤`:
```lean
| Formula.all_past φ => ∀ (s : D), s ≤ t → truth_at M Omega τ s φ
| Formula.all_future φ => ∀ (s : D), t ≤ s → truth_at M Omega τ s φ
```

Under this definition, the density axiom `GGφ → Gφ` is proven without using `DenselyOrdered`:
- **SoundnessLemmas.lean:810-821**: `exact h_GG s hts s le_rfl` — takes `r = s` as witness
- The `[DenselyOrdered D]` typeclass in the signature is **vacuously declared but unused**

| Semantics | G Definition | Density Proof Strategy |
|-----------|-------------|----------------------|
| **Strict** (`<`) | `∀s > t, φ(s)` | Requires intermediate `r` with `t < r < s` — genuinely needs DenselyOrdered |
| **Reflexive** (`≤`) | `∀s ≥ t, φ(s)` | Take `r = s`, then `s ≥ s` gives `φ(s)` directly via `le_rfl` |

The same trivial pattern applies to seriality axioms (SoundnessLemmas.lean:845-862).

### 2. Impact on Task 59's Five Sorries (Teammate A)

| Line | Axiom | Under Reflexive Semantics | Proof Pattern |
|------|-------|--------------------------|---------------|
| 572 | `density` | Trivially valid | `h_GG s hts s le_rfl` |
| 576 | `discreteness_forward` | Requires SuccOrder analysis | Different — genuinely uses structure |
| 579 | `seriality_future` | Trivially valid | Self-witness `t` via `le_rfl` |
| 582 | `seriality_past` | Trivially valid | Self-witness `t` via `le_rfl` |
| 602 | `temporal_duality` | Requires type constraints | Needs `[DenselyOrdered D] [Nontrivial D]` from `derivable_implies_swap_valid` |

**Key distinction**: Lines 572, 579, 582 follow the trivial pattern. Line 576 (discreteness) and 602 (duality) require different analysis.

### 3. Strict Temporal Extensions Track (Teammate B)

Tasks 74-76 and 998 form a parallel research track:

| Task | Status | Description | Dependency |
|------|--------|-------------|------------|
| 74 | NOT STARTED | Research strict vs reflexive temporal semantics | None |
| 75 | NOT STARTED | Research G'/H' operator extension design | 74 |
| 76 | NOT STARTED | Research unified density/discreteness completeness | 74, 75 |
| 998 | RESEARCHING | FMP redesign for strict temporal | Parallel to 75 |

**G'/H' design options** (from task 75 description):
- **Option A**: Add G'/H' as new primitives in `Formula` type with strict semantics
- **Option B**: Define as derived operators: `G' φ := G φ ∧ ¬φ`

Under strict semantics with G'/H', density would require actual `DenselyOrdered` constraints, making the proofs non-trivial. The Compatibility.lean file already anticipates this: "Total: 19 axioms (2 T-axioms removed under strict semantics)".

### 4. Historical Design Decision

Truth.lean:16-18 documents:
> A previous version used strict semantics (<) which required an axiom for canonicalR irreflexivity. The current version uses reflexive semantics to eliminate this axiom and simplify the metalogic.

The switch to reflexive semantics was intentional to simplify completeness proofs.

## Synthesis

### Conflicts Resolved

**No conflicts** between teammates. Findings were complementary:
- Teammate A provided detailed code-level analysis of the semantics impact
- Teammate B provided cross-task context and scoping recommendations

### Gaps Identified

1. **discreteness_forward (line 576)**: Neither teammate fully analyzed this sorry. Prior research suggests it uses `and_of_not_imp_not` with `le_rfl`, but the exact proof strategy needs verification during implementation.
2. **temporal_duality (line 602)**: The blocker is architectural — the main `soundness` theorem doesn't carry the `[DenselyOrdered D] [Nontrivial D]` constraints needed by `derivable_implies_swap_valid`. Resolution options:
   - Inline the proof directly (if possible under reflexive semantics)
   - Leave as intentional sorry (soundness for duality proven in `soundness_dense`)
   - Restructure soundness into frame-class variants

### Recommendations

1. **Task 59 should proceed as scoped** — fill the 4 straightforward sorries using reflexive semantics proofs
2. **Document the reflexive vs strict distinction** in the implementation summary
3. **For temporal_duality**: investigate whether it can be inlined under reflexive semantics without frame constraints. If not, document as intentional gap addressed by `soundness_dense`
4. **Do NOT block on tasks 74-76** — the strict extension track is parallel research
5. **Consider**: the implementation plan should note that the "unused DenselyOrdered" pattern is a known design artifact of reflexive semantics, not a bug

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Strict vs reflexive semantics impact | completed | high |
| B | Related tasks and conservative extension | completed | high |

## References

- `Theories/Bimodal/Semantics/Truth.lean:118-125` — Temporal operator definitions
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean:810-862` — Existing density/seriality proofs
- `Theories/Bimodal/ProofSystem/Axioms.lean:350-377` — Axiom definitions
- `Theories/Bimodal/Metalogic/Soundness.lean:572-602` — Sorry locations
- `specs/TODO.md:34-44` — Strict temporal extensions track
