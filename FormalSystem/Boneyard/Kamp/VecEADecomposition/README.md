# VecEADecomposition (Archived)

**Archived**: Task 301 (completeness cleanup)
**Original location**: `FormalSystem/Metalogic/WeakCanonical/Kamp/VecEADecomposition.lean`

Syntactic VBracketFormula negation and Prop 4.3 support. Quarantined as dead code
by task 273 (plan v23). The two remaining sorries (`neg_bracket_syn_iff` soundness
Case C, `neg_vecEA2_syn_iff`) are bypassed by the NF-specific Prop 4.3 approach
(KampPrior.lean + NfCharFormula.lean + NegationClosure.lean master_induction).

Not on any live call path to `completeness_discrete`.

## Files

| File | Lines | Path before consolidation | Live origin before archival |
|------|------:|---------------------------|------------------------------|
| `VecEADecomposition.lean` | 334 | `FormalSystem/Boneyard/VecEADecomposition/VecEADecomposition.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/VecEADecomposition.lean` |

Nothing in this directory is compiled. It is outside the `lakefile.lean` import closure and no
live module imports it. Its imports are still checked -- C11 in
`scripts/check-module-invariants.sh` requires every one to resolve to a file on disk or be waived
in `scripts/boneyard-import-waivers.txt`.

Last verified: 2026-08-24
