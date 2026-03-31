# Research Report: Semantic Correction for Task #72

**Task**: Wire completeness through fully coherent BFMCS construction
**Date**: 2026-03-31
**Session**: sess_1774982772_191c5d
**Type**: Critical Correction

## Executive Summary

Previous research (reports 01-05) contained a fundamental semantic error. The claim that "bundle-level coherence suffices for completeness" and "matches standard Kripke completeness proofs" is **WRONG** for TM task semantics. The ROADMAP.md (lines 158-160) already identifies this as a dead end, but prior reports incorrectly recommended pursuing it.

This report corrects the record and identifies what should be archived vs preserved.

## The Semantic Mistake

### The Erroneous Claim

From `05_team-research.md` and `05_teammate-a-findings.md`:

> "The bundle approach is mathematically correct -- standard Kripke completeness proofs allow witnesses in any accessible world, not just in the same 'timeline'"
>
> "This matches standard modal logic completeness proofs (Segerberg, Goldblatt)"

### Why This Is Wrong

**TM Task Semantics** (Truth.lean:118-125):
```lean
def truth_at (M : TaskModel F) (Omega : Set (WorldHistory F))
    (τ : WorldHistory F) (t : D) : Formula → Prop
  | Formula.all_future φ => ∀ (s : D), t ≤ s → truth_at M Omega τ s φ
  | Formula.box φ => ∀ (σ : WorldHistory F), σ ∈ Omega → truth_at M Omega σ t φ
```

The critical distinction:
- **Temporal operators (G, H)**: Keep the SAME world history `τ`, vary only time `s`
- **Modal operator (Box)**: Keep the SAME time `t`, vary world history `σ`

Therefore:
- `G(phi)` at `(τ, t)` = "phi at `(τ, s)` for all `s >= t`" -- SAME timeline
- `F(phi)` = `neg(G(neg phi))` = "exists `s >= t` such that phi at `(τ, s)`" -- SAME timeline
- `Box(phi)` at `(τ, t)` = "phi at `(σ, t)` for all `σ`" -- DIFFERENT histories

This is fundamentally different from standard Kripke semantics where temporal operators quantify over accessible WORLDS (points in a Kripke frame), not over times within a fixed history.

### ROADMAP.md Already Documents This

From ROADMAP.md (lines 158-160):

> **Bundle-level temporal coherence**: Insufficient for truth lemma. G/H operators are intrinsically single-history; a witness in a different family uses a different history, invalidating the semantic argument for `temporal_backward_G`.

The ROADMAP correctly identifies bundle-level coherence as a dead end. The previous research reports (01-05) contradict this established finding.

## Scope of Affected Code

### What Is Semantically Wrong (68 occurrences across 4 files)

| File | Occurrences | Key Constructs |
|------|-------------|----------------|
| `UltrafilterChain.lean` | 51 | `BFMCS_Bundle`, `bundle_forward_F`, `bundle_backward_P`, `construct_bfmcs_bundle`, `BundleTemporallyCoherent` |
| `Completeness.lean` | 14 | `bundle_to_bfmcs`, conversion theorems |
| `RestrictedTruthLemma.lean` | 2 | References to `BFMCS_Bundle` strategy |
| `CanonicalConstruction.lean` | 1 | Bundle documentation |

### Analysis by File

**UltrafilterChain.lean (~51 occurrences)**:
- Lines 5617-5751: `BFMCS_Bundle` structure and related theorems
- Lines 5506-5600: `boxClassFamilies_bundle_forward_F`, `boxClassFamilies_bundle_backward_P`
- Lines 5750-5876: `construct_bfmcs_bundle` and completeness infrastructure
- The code IS technically sorry-free, but provides the WRONG coherence property

**Completeness.lean (~14 occurrences)**:
- Lines 162-192: `bundle_to_bfmcs` conversion
- Lines 194-226: Comments explaining the "gap" between bundle-level and family-level
- Lines 220-226: `bfmcs_from_mcs_temporally_coherent` with isolated sorry

**RestrictedTruthLemma.lean (~2 occurrences)**:
- Lines 392-397: Comments suggesting `construct_bfmcs_bundle` as strategy

### What Should NOT Be Archived

The following constructs are semantically correct and remain useful:

1. **`boxClassFamilies`** (UltrafilterChain.lean): Correct for modal coherence (Box case)
2. **`boxClassFamilies_modal_forward/backward`**: Sorry-free, correct
3. **Modal saturation infrastructure**: Correct for S5 modal accessibility
4. **`BFMCS` structure** (BFMCS.lean): Correct; the issue is with `BFMCS_Bundle` variant
5. **`BFMCS.temporally_coherent`**: Correct predicate (family-level, same-history)

## The Correct Path Forward

Per ROADMAP.md "Working Approach" (lines 167-198):

### SuccChainFMCS with Separate-Direction Witnesses

**What is sorry-free**:
- `succ_chain_forward_G`: G(phi) at t implies phi at all t' > t -- SAME family
- `succ_chain_backward_H`: H(phi) at t implies phi at all t' < t -- SAME family

**What has sorries** (Class B, genuinely hard):
- `forward_F`: F(phi) at t implies exists t' >= t with phi at t' in SAME family
- `backward_P`: P(phi) at t implies exists t' <= t with phi at t' in SAME family

These sorries are in the "fuel exhaustion" branch of bounded witness proofs. The semantic claim (phi eventually appears in the chain) is correct; the proof is not yet closed.

### Why Bundle Approach Cannot Help

`BFMCS_Bundle.bundle_forward_F` provides:
- "F(phi) at t in fam implies exists fam' and s > t with phi in fam'.mcs(s)"

But truth lemma backward direction needs:
- "F(phi) at t in fam implies exists s > t with phi in fam.mcs(s)" -- SAME family

The bundle property allows `fam' != fam`, which semantically uses a DIFFERENT world history. In TM semantics, F(phi) quantifies over times in the SAME history, not over other histories.

## Recommendations

### 1. Archive Bundle-Level Temporal Infrastructure

Move to `Boneyard/` with explanation:

```
Theories/Bimodal/Boneyard/BundleTemporalCoherence/
├── README.md              -- Explains why this approach is semantically wrong
├── BFMCS_Bundle.lean      -- Extract from UltrafilterChain.lean
└── BundleInfrastructure.lean
```

Constructs to archive:
- `BFMCS_Bundle` structure
- `BundleTemporallyCoherent` definition
- `boxClassFamilies_bundle_forward_F`
- `boxClassFamilies_bundle_backward_P`
- `construct_bfmcs_bundle`
- `construct_bfmcs_bundle_temporally_coherent`
- Related theorems (reflexivity, diamond_witness for bundles)

### 2. Update Research Reports

Add errata to reports 01-05:
- Reference this correction report
- Explicitly mark the "bundle truth lemma" recommendation as WRONG
- Point to ROADMAP.md "Dead Ends" section

### 3. Focus on SuccChainFMCS Path

The remaining sorries in `forward_F`/`backward_P` are in the bounded witness fuel argument. Per ROADMAP.md Class B analysis, this is the genuine hard case requiring:
- Either: prove fuel=0 branch is unreachable (termination metric)
- Or: weaken the theorem to "eventually in chain" rather than "at step k+1"

### 4. Clean Up Completeness.lean

Remove bundle references from Completeness.lean since `bundle_to_bfmcs` converts to a structure that requires the very property (`temporally_coherent`) that bundles don't provide.

## Estimated Cleanup Scope

| Category | Lines | Files | Effort |
|----------|-------|-------|--------|
| Archive bundle constructs | ~250 | 1 (UC) -> 2 (Boneyard) | Medium |
| Remove Completeness refs | ~50 | 1 | Small |
| Add errata to reports | ~20 | 5 | Small |
| Update ROADMAP if needed | ~10 | 1 | Small |
| **Total** | **~330** | **9** | **Medium** |

## Impact on Dependent Tasks

| Task | Impact | Action |
|------|--------|--------|
| 58 (wire completeness) | High | Focus on SuccChainFMCS path |
| 67 (prove bundle validity) | High | Task description is based on wrong path |
| 68 (if exists) | TBD | Review for bundle dependencies |
| 70 (ultrafilter construction) | Medium | Preserved; ultrafilter chains useful for modal case |

## Key Distinction Summary

| Property | Standard Kripke | TM Task Semantics |
|----------|-----------------|-------------------|
| Temporal quantification | Over accessible WORLDS | Over times in SAME history |
| F(phi) witness | Can be in ANY accessible world | Must be at SAME history, later time |
| Bundle-level coherence | Sufficient | **INSUFFICIENT** |
| Family-level coherence | N/A | **REQUIRED** |

## References

### Definitive Sources
- `Truth.lean:118-125` - TM semantics definition
- `ROADMAP.md:158-160` - Bundle dead end documented
- `ROADMAP.md:167-198` - Working approach (SuccChainFMCS)

### Affected Reports
- `reports/01_team-research.md` - Initial research (bundle approach recommended)
- `reports/05_team-research.md` - Follow-up research (bundle approach reinforced)
- `reports/05_teammate-a-findings.md` - Contains "standard Kripke" error
- `reports/05_teammate-b-findings.md` - Contains bundle path recommendation
