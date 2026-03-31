/-!
# Bundle-Level Temporal Coherence (ARCHIVED REFERENCE)

**STATUS: SEMANTICALLY INSUFFICIENT FOR TM TASK SEMANTICS**

This file is a reference copy of the bundle-level temporal coherence constructs
from UltrafilterChain.lean. The original code remains in place because it is
used by Completeness.lean (with an isolated sorry that bridges the semantic gap).

## Why This Approach Is Wrong

Bundle-level coherence allows F/P witnesses in DIFFERENT families (histories).
TM task semantics requires witnesses in the SAME history:

- `F(phi)` means "phi at some future time IN THE SAME HISTORY"
- Bundle-level: witness can be in family fam' != fam (WRONG)
- Family-level: witness must be in family fam (CORRECT)

See: Truth.lean:118-125 for TM semantics, ROADMAP.md:158-160 for "dead end" note.

## Constructs (copied from UltrafilterChain.lean ~5400-5820)

The following constructs are documented here for reference but NOT independently
compilable (they have deep dependencies on UltrafilterChain infrastructure).

### Predicates

- `bundle_forward_F`: F(phi) implies witness in SOME family (line 5411)
- `bundle_backward_P`: P(phi) implies witness in SOME family (line 5421)
- `BundleTemporallyCoherent`: all families satisfy both (line 5429)

### Key Theorems

- `boxClassFamilies_bundle_forward_F`: boxClassFamilies is bundle-F-coherent (line 5518)
- `boxClassFamilies_bundle_backward_P`: boxClassFamilies is bundle-P-coherent (line 5563)
- `boxClassFamilies_bundle_temporally_coherent`: combined bundle coherence (line 5605)

### Structure

- `BFMCS_Bundle`: Bundle with temporal fields (line 5633)
- `BFMCS_Bundle.reflexivity`: Box phi implies phi (line 5665)
- `BFMCS_Bundle.diamond_witness`: Diamond phi implies phi in SOME family (line 5672)

### Constructor

- `construct_bfmcs_bundle`: Build bundle from MCS (line 5728)
- `construct_bfmcs_bundle_eval_at_zero`: eval_family.mcs(0) = M0 (line 5744)
- `construct_bfmcs_bundle_temporally_coherent`: bundle is coherent (line 5750)

## The Gap

Completeness.lean uses `bundle_to_bfmcs` to convert `BFMCS_Bundle` to `BFMCS`,
then needs to prove `B.temporally_coherent` (family-level coherence).

The theorem `bfmcs_from_mcs_temporally_coherent` has a sorry PRECISELY because
bundle-level coherence does not imply family-level coherence.

## Correct Path

SuccChainFMCS with family-level forward_F/backward_P is the correct approach.
The sorries there are in the "fuel exhaustion" branch of bounded witness proofs,
which is a Class B hard case requiring a termination metric argument.

## References

- `UltrafilterChain.lean:5400-5820` - Original bundle code
- `Completeness.lean:220-226` - Where the sorry gap appears
- `Truth.lean:118-125` - TM semantics showing single-history temporal quantification
- `ROADMAP.md:158-160` - Documents bundle as "dead end"
- `reports/06_semantic-correction.md` - Full correction analysis
-/

-- This file is documentation only; the actual code remains in UltrafilterChain.lean
-- because Completeness.lean depends on it.
