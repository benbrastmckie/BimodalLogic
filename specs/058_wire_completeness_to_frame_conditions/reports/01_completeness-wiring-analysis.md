# Research Report: Wiring Completeness to FrameConditions

## Task 58: Wire completeness to FrameConditions

**Session**: sess_1774418331_1b0fea
**Date**: 2026-03-24
**Status**: BLOCKED - Cannot be wired with current infrastructure

## Executive Summary

The three sorries in `FrameConditions/Completeness.lean` (lines 108, 151, 170) **cannot be eliminated** with the current infrastructure. The algebraic path (`construct_bfmcs`) is deprecated due to mathematically false temporal coherence dependencies, and no alternative sorry-free completeness path exists that provides the required `Nonempty ([] |- phi)` proof.

## 1. Target Sorries Analysis

### Location: `/Theories/Bimodal/FrameConditions/Completeness.lean`

| Line | Theorem | Goal | Status |
|------|---------|------|--------|
| 108 | `dense_completeness_fc` | `Nonempty ([] |- phi)` given dense validity | BLOCKED |
| 151 | `discrete_completeness_fc` | `Nonempty ([] |- phi)` given discrete validity | BLOCKED |
| 170 | `completeness_over_Int` | `Nonempty ([] |- phi)` given Int validity | BLOCKED |

All three require proving **provability** from **validity** - the completeness direction.

## 2. Algebraic Path Analysis

### 2.1 What Task 63 Solved

Task 63 confirmed that `boxClassFamilies_modal_backward` (UltrafilterChain.lean:1678) is **sorry-free**. This theorem proves the modal backward direction for the BFMCS bundle construction.

The modal completeness path is complete:
- `boxClassFamilies_modal_backward` -> sorry-free
- `parametric_canonical_truth_lemma` uses `B.modal_backward`
- Box forward/backward in the truth lemma: sorry-free

### 2.2 The Temporal Coherence Blocker

**`construct_bfmcs`** (UltrafilterChain.lean:1852) is **deprecated** and uses `sorryAx`:

```
construct_bfmcs
  -> boxClassFamilies_temporally_coherent
  -> SuccChainTemporalCoherent
  -> succ_chain_forward_F
  -> f_nesting_boundary
  -> f_nesting_is_bounded  <- MATHEMATICALLY FALSE
```

The `f_nesting_is_bounded` theorem claims every MCS has bounded F-nesting. This is **proven false**: the set `{F^n(p) | n in Nat}` is finitely consistent and extends to an MCS with unbounded F-nesting.

### 2.3 What Would Be Needed

To wire `parametric_algebraic_representation_conditional` (ParametricRepresentation.lean:252), we need:

```lean
construct_bfmcs : (M : Set Formula) -> SetMaximalConsistent M ->
  Sigma' (B : BFMCS D) (h_tc : B.temporally_coherent)
         (fam : FMCS D) (hfam : fam ∈ B.families) (t : D),
         M = fam.mcs t
```

The **temporal coherence** (`h_tc : B.temporally_coherent`) requirement demands:
- `forward_F`: If `F(phi) ∈ fam.mcs t`, then exists `s > t` with `phi ∈ fam.mcs s`
- `backward_P`: If `P(phi) ∈ fam.mcs t`, then exists `s < t` with `phi ∈ fam.mcs s`

These are blocked by the false nesting theorems.

## 3. Alternative Paths Examined

### 3.1 SuccChainCompleteness Path

`succ_chain_completeness` (SuccChainCompleteness.lean:131) provides:
```lean
(not formula_provable phi) ->
  exists M0, not truth_at succ_chain_model ... phi
```

**Problems**:
1. Uses `sorryAx` via `succ_chain_truth_forward` -> `succ_chain_truth_lemma` Box backward sorry
2. Proves relative completeness (countermodel in specific model), not absolute completeness
3. Does NOT provide `valid_over D phi -> Nonempty ([] |- phi)`

### 3.2 FMP Path

`fmp_contrapositive` (FMP/FMP.lean:206) provides:
```lean
(forall S : ClosureMCSBundle phi, phi ∈ S.carrier) -> Nonempty ([] |- phi)
```

**Problems**:
1. Works at MCS membership level, not semantic validity level
2. No bridge from `valid_over D phi` to "phi is in all closure MCS"
3. The FMP truth preservation has sorries (TruthPreservation.lean:263, 281)

### 3.3 Direct Validity-to-Provability

No direct theorem exists connecting:
- `valid_over D phi` (semantic validity over D)
- `Nonempty ([] |- phi)` (syntactic provability)

This IS the completeness theorem we need to prove.

## 4. Architecture Gap

### What Exists (Sorry-Free)

| Component | File | Status |
|-----------|------|--------|
| `boxClassFamilies_modal_backward` | UltrafilterChain.lean:1678 | Sorry-free |
| `parametric_shifted_truth_lemma` | ParametricTruthLemma.lean | Sorry-free (modal) |
| `parametric_algebraic_representation_conditional` | ParametricRepresentation.lean:252 | Sorry-free (given `construct_bfmcs`) |

### What Is Blocked

| Component | File | Blocker |
|-----------|------|---------|
| `construct_bfmcs` | UltrafilterChain.lean:1852 | `f_nesting_is_bounded` (FALSE) |
| `boxClassFamilies_temporally_coherent` | UltrafilterChain.lean:1809 | Same |
| `succ_chain_truth_lemma` Box backward | SuccChainTruth.lean:311 | Singleton Omega (unprovable) |

### The Missing Piece

A **sorry-free temporal coherence construction** that:
1. Given MCS M, builds FMCS family over Int (or parametric D)
2. Satisfies forward_F and backward_P
3. Places M at some time t in the family

## 5. Recommended Resolution

### Option A: Mark Tasks BLOCKED (Recommended)

Leave the three sorries as **documented technical debt**:
- Dense completeness: Blocked by SuccChain temporal coherence
- Discrete completeness: Blocked by same + `discrete_Icc_finite_axiom`
- Int completeness: Inherits discrete blocker

Update docstrings to reference this analysis.

### Option B: Per-Obligation Witness Architecture (Future Work)

The ROADMAP.md suggests a per-obligation witness approach:
1. Instead of building full FMCS chains, build witnesses for each F/P obligation
2. Use restricted MCS closures to bound the construction
3. Compose witnesses into a coherent BFMCS

This is a significant research effort, not implementable in a single task.

### Option C: Direct Algebraic Construction

An alternative algebraic approach mentioned in ROADMAP.md:
1. Define temporal shift automorphism on Lindenbaum algebra
2. Use Stone-space unraveling to construct FMCS
3. Avoid explicit F-enumeration

This requires new infrastructure not currently present.

## 6. Verification

### Axiom Check

```bash
grep -n "^axiom\|:= sorry\|sorry$" Theories/Bimodal/FrameConditions/Completeness.lean
```
Output:
```
108:  sorry
151:  sorry
170:  sorry
187:axiom discrete_Icc_finite_axiom  # Documented debt
```

### Lake Build

The project builds successfully with these sorries. They are contained technical debt.

## 7. Conclusion

**Task 58 cannot be completed** with current infrastructure. The three sorries in `FrameConditions/Completeness.lean` require temporal coherence from the BFMCS construction, which depends on mathematically false theorems that have been removed.

### Immediate Blockers

1. `construct_bfmcs` is deprecated (uses `sorryAx`)
2. `SuccChainTemporalCoherent` was removed (false dependencies)
3. No alternative temporal coherence construction exists

### What Would Unblock

A new approach to temporal coherence that:
- Does not assume bounded F/P-nesting
- Handles arbitrary MCS extensions
- Provides the `B.temporally_coherent` proof required by the parametric representation

This is substantial research work tracked in ROADMAP.md as the primary completeness gap.
