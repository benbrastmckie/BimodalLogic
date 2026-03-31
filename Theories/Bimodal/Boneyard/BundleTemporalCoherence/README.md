# Bundle-Level Temporal Coherence (ARCHIVED)

**Archived**: 2026-03-31
**Reason**: Semantically wrong for TM task semantics
**Reference Copy Only**: Original code remains in UltrafilterChain.lean (used by Completeness.lean)

## Status: SEMANTICALLY INSUFFICIENT

This directory documents **why bundle-level temporal coherence is semantically wrong** for TM task semantics, even though the code compiles and proves what it claims.

## The Semantic Issue

### TM Task Semantics (from Truth.lean)

```lean
def truth_at (M : TaskModel F) (Omega : Set (WorldHistory F))
    (τ : WorldHistory F) (t : D) : Formula → Prop
  | Formula.all_future φ => ∀ (s : D), t ≤ s → truth_at M Omega τ s φ
  | Formula.box φ => ∀ (σ : WorldHistory F), σ ∈ Omega → truth_at M Omega σ t φ
```

**The critical distinction**:
- **Temporal operators (G, H)**: Keep the SAME world history `τ`, vary only time `s`
- **Modal operator (Box)**: Keep the SAME time `t`, vary world history `σ`

### Why Bundle-Level Coherence Is Wrong

**Bundle-level coherence** (what `BFMCS_Bundle` provides):
- `F(phi)` at `(fam, t)` implies phi exists at `(fam', s)` for some `fam'` in the bundle, `s > t`
- The witness family `fam'` may be DIFFERENT from `fam`

**Family-level coherence** (what the truth lemma requires):
- `F(phi)` at `(fam, t)` implies phi exists at `(fam, s)` for `s > t`
- The witness must be in the SAME family `fam`

In TM semantics, `F(phi)` means "phi holds at some FUTURE time in the SAME world history." Bundle-level coherence allows the witness in a DIFFERENT history, which is semantically wrong.

### ROADMAP.md Documentation (lines 158-160)

> **Bundle-level temporal coherence**: Insufficient for truth lemma. G/H operators are intrinsically single-history; a witness in a different family uses a different history, invalidating the semantic argument for `temporal_backward_G`.

## What Is Archived Here

This directory contains a **reference copy** of the bundle temporal coherence code from `UltrafilterChain.lean`. The original code remains in place because it's used by `Completeness.lean` with an isolated sorry (`bfmcs_from_mcs_temporally_coherent`).

### Constructs (still in UltrafilterChain.lean)

| Construct | Lines | Description |
|-----------|-------|-------------|
| `bundle_forward_F` | ~5411 | Bundle-level F-coherence predicate |
| `bundle_backward_P` | ~5421 | Bundle-level P-coherence predicate |
| `BundleTemporallyCoherent` | ~5429 | Combined bundle coherence |
| `boxClassFamilies_bundle_forward_F` | ~5518 | Bundle F-coherence for boxClassFamilies |
| `boxClassFamilies_bundle_backward_P` | ~5563 | Bundle P-coherence for boxClassFamilies |
| `BFMCS_Bundle` | ~5633 | Bundle structure with temporal fields |
| `construct_bfmcs_bundle` | ~5728 | Constructor from MCS |
| `construct_bfmcs_bundle_eval_at_zero` | ~5744 | Evaluation property |
| `construct_bfmcs_bundle_temporally_coherent` | ~5750 | Bundle coherence theorem |

## The Correct Path: SuccChainFMCS

Family-level temporal coherence requires proving that F/P-obligations are resolved WITHIN the same SuccChainFMCS, not merely somewhere in the bundle.

**What is sorry-free** (from SuccChainFMCS):
- `succ_chain_forward_G`: G(phi) at t implies phi at all t' > t (same family)
- `succ_chain_backward_H`: H(phi) at t implies phi at all t' < t (same family)

**What has sorries** (Class B hard case):
- `forward_F`: F(phi) at t implies exists t' >= t with phi at t' (same family)
- `backward_P`: P(phi) at t implies exists t' <= t with phi at t' (same family)

The sorries are in the "fuel exhaustion" branch of bounded witness proofs.

## Why This Code Still Exists

The bundle code compiles and is used by `Completeness.lean`:

1. `construct_bfmcs_bundle` builds a bundle from an MCS
2. `bundle_to_bfmcs` converts it to a plain `BFMCS`
3. The completeness proof uses this with an isolated sorry for `temporally_coherent`

The sorry (`bfmcs_from_mcs_temporally_coherent`) exists PRECISELY because bundle-level coherence doesn't imply family-level coherence.

## References

- **Truth.lean:118-125** - TM semantics definition showing single-history temporal quantification
- **ROADMAP.md:158-160** - Documents bundle approach as a "dead end"
- **ROADMAP.md:167-198** - Describes the correct SuccChainFMCS approach
- **reports/06_semantic-correction.md** - Full correction report
