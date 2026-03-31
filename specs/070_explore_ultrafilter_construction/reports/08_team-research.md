# Research Report: Task #70 - Seed Consistency Corner Case Resolution

**Task**: Explore ultrafilter-based construction for temporal coherence
**Date**: 2026-03-30
**Mode**: Team Research (2 teammates)
**Focus**: Resolve sorries in ultrafilter_F_resolution and ultrafilter_P_resolution seed consistency proofs

## Summary

Both teammates converge on a clear conclusion: the corner case `phi in L_no_phi but phi not_in G_seed` is **genuinely reachable** (not impossible), so Option 2 (prove it impossible via MCS properties) is ruled out. The fix requires restructuring the proof to handle multiple phi-occurrences. Two viable approaches were identified:

1. **Strong induction on `L.count phi`** (Teammate A) - mathematically clean but adds complexity
2. **Filter-deduction-contraction** (Teammate B) - uses existing codebase infrastructure, no induction needed

**Recommendation**: Use the **filter approach** (Option 2) as it leverages existing patterns from MCSProperties.lean and avoids introducing a strong induction scheme.

## Key Findings

### The Corner Case IS Reachable (Teammate B)

Concrete example:
- Let `phi not_in G_seed` (i.e., `G(phi) not_in U`)
- Let `L = [phi, phi]`, valid since `L subset seed = G_seed union {phi}`
- After splitting at first occurrence: `L_no_phi = [phi]`
- Now `phi in L_no_phi` but `phi not_in G_seed`

This definitively rules out proving impossibility. The current proof structure is fundamentally wrong in trying to establish `forall psi in L_no_phi, psi in G_seed`.

### Solution: Filter-Deduction-Contraction (Recommended)

The fix restructures the `phi in L` branch in `h_seed_cons`:

1. **Filter**: Define `L_filt = L_no_phi.filter (fun y => decide (y != phi))` removing ALL phi-occurrences
2. **Prove `L_filt subset G_seed`**: Since every element of L_filt is in seed and is not phi, it must be in G_seed
3. **Prove `L_filt derives neg_phi`** using:
   - `cons_filter_neq_perm` (MCSProperties.lean:37): shows `phi :: L_filt` has same set membership as `L_no_phi`
   - `derivation_exchange` (MCSProperties.lean:61): converts derivation between iso-membership contexts
   - `deduction_theorem`: gets `L_filt derives phi.imp phi.neg`
   - Contraction: from `phi -> (phi -> bot)` derive `phi -> bot`
4. **Continue with existing fold argument** using `L_filt` instead of `L_no_phi`

### Contraction Lemma

Both teammates identify the same key sub-lemma: `derives (phi -> phi -> bot) -> (phi -> bot)`

Teammate B provides a concrete construction using EXISTING combinators:
```lean
-- contraction: derives (phi -> neg_phi) -> neg_phi
-- Using: prop_k phi phi bot : derives (phi -> phi -> bot) -> (phi -> phi) -> (phi -> bot)
-- After flip: derives (phi -> phi) -> (phi -> phi -> bot) -> (phi -> bot)
-- With identity phi : derives phi -> phi
-- By mp: derives (phi -> phi -> bot) -> (phi -> bot)
Combinators.mp
  (Combinators.identity phi)
  (Combinators.theorem_flip
    (DerivationTree.axiom [] _ (Axiom.prop_k phi phi Formula.bot)))
```

**Note**: Teammate A identifies the same contraction principle but mentions `prop_k` is actually `prop_s` (the S combinator `(A -> B -> C) -> (A -> B) -> (A -> C)`). Cross-checking: `Axiom.prop_k` in this codebase is actually the **S combinator** (not K), per `ProofSystem/Axioms.lean:103`. Both teammates use this correctly.

### Strong Induction Alternative (Teammate A)

If the filter approach hits difficulties, strong induction on `L.count phi` is a fallback:
- **Base case** (count = 0): All elements in G_seed, existing fold argument applies directly
- **Inductive step** (count = n+1): Apply deduction theorem to remove one phi, contraction to get `L.erase phi derives neg_phi` with strictly fewer phi-occurrences
- Uses `List.count_erase_self` and `Nat.strong_rec_on`

This is mathematically clean but more complex to formalize.

## Synthesis

### Conflicts Resolved

| Issue | Teammate A | Teammate B | Resolution |
|-------|-----------|-----------|------------|
| Is corner case impossible? | Not explicitly ruled out | Proved reachable with counterexample | Reachable (B's counterexample is definitive) |
| Approach | Strong induction | Filter + exchange | Filter preferred (uses existing patterns) |
| Contraction proof | Via new standalone lemma | Via existing combinators inline | Existing combinators (no new lemma needed) |

### Key Existing Infrastructure

| Tool | Location | Purpose |
|------|----------|---------|
| `cons_filter_neq_perm` | Core/MCSProperties.lean:37 | `A :: L'.filter(!=A)` has same membership as `L'` |
| `derivation_exchange` | Core/MCSProperties.lean:61 | Convert derivation between iso-membership contexts |
| `deduction_theorem` | Core/DeductionTheorem.lean:336 | Remove hypothesis from context |
| `Combinators.identity` | Theorems/Combinators.lean:108 | `derives A -> A` |
| `Combinators.theorem_flip` | Theorems/Combinators.lean:148 | `derives (A -> B -> C) -> (B -> A -> C)` |
| `Combinators.mp` | Theorems/Combinators.lean:97 | `derives A, derives A -> B, then derives B` |
| `Axiom.prop_k` | ProofSystem/Axioms.lean:103 | S combinator: `(A -> B -> C) -> (A -> B) -> (A -> C)` |
| `fold_le_of_derives` | Algebraic/UltrafilterMCS.lean:551 | `L derives psi implies fold(L) <= [psi]` |

### Recommended Implementation Steps

1. Restructure the `h_phi_in_L` branch in `ultrafilter_F_resolution` (line ~1080-1155):
   - Replace `L_no_phi` with `L_filt = L_no_phi.filter (fun y => decide (y != phi))`
   - Prove `L_filt subset G_seed` (straightforward since all elements != phi)
   - Prove `L_filt derives neg_phi` via exchange + deduction + contraction
   - Continue existing fold argument with `L_filt`

2. Apply symmetric fix to `ultrafilter_P_resolution` (line ~1290-1365):
   - Same restructuring with `H_seed` replacing `G_seed`

3. No new lemmas needed - all required infrastructure exists.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Strong induction approach | completed | high (85%) |
| B | MCS impossibility / filter approach | completed | high |

## References

- Teammate A findings: specs/070_explore_ultrafilter_construction/reports/08_teammate-a-findings.md
- Teammate B findings: specs/070_explore_ultrafilter_construction/reports/08_teammate-b-findings.md
- UltrafilterChain.lean lines 1080-1155 (F_resolution), 1290-1365 (P_resolution)
- MCSProperties.lean lines 37, 61, 96-111 (existing filter+exchange pattern)
