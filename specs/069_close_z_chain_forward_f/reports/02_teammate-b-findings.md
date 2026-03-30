# Research Report: Saturation Strategies Before Lindenbaum

**Task**: 69 - close_z_chain_forward_f
**Focus**: Alternative saturation strategies to preserve F-formulas BEFORE Lindenbaum extension
**Agent**: Teammate B (logic-research-agent)
**Date**: 2026-03-30

## Executive Summary

The current construction uses Lindenbaum extension with seed `{phi} U G_theory(M) U box_theory(M)`, which can add `G(neg psi)` even when `F(psi)` was present in an earlier chain step. This report analyzes four alternative saturation strategies to address this gap.

**Key Finding**: The most promising approach is **Strategy B (F-Formula Closure)** - pre-saturating with an F-closure that explicitly excludes incompatible G-formulas from the Lindenbaum extension.

## Context: The Problem

### Current Construction Flow

1. `omega_step_forward M phi h_F` builds a witness for F(phi) in M
2. Calls `temporal_theory_witness_exists` with seed `{phi} U G_theory(M) U box_theory(M)`
3. Uses `set_lindenbaum` to extend the seed to a maximal consistent set (MCS)
4. **Gap**: Lindenbaum can add `G(neg psi)` for any psi where F(psi) was in the previous chain step but psi is NOT in the current seed

### Why This Breaks F-Persistence

At step n, suppose F(psi) is in chain(n) but psi is not selected for resolution (another formula phi was selected). The seed for the witness is `{phi} U G_theory U box_theory`. Since:

- F(psi) is NOT in the seed
- G(neg psi) is NOT explicitly excluded

Lindenbaum may add G(neg psi) if it's consistent with the seed. Once G(neg psi) enters chain(n+1):

- F(psi) = neg(G(neg psi)) is NOT in chain(n+1)
- psi can never appear in subsequent steps
- The F-obligation is "lost"

## Analysis of Saturation Strategies

### Strategy A: Add F-formulas to Lindenbaum Seed

**Approach**: Modify seed to include all F-formulas from current MCS:
```
seed = {phi} U G_theory(M) U box_theory(M) U F_theory(M)
```
where `F_theory(M) = { F(a) | F(a) in M }`.

**Pros**:
- Directly preserves all F-obligations
- Minimal change to existing construction

**Cons**:
- **Consistency Problem**: The extended seed may be inconsistent
- F(psi) and G(neg psi) could both be in the seed (from different formulas)
- No guarantee that `{phi} U G_theory U box_theory U F_theory` is consistent even if `{phi} U G_theory U box_theory` is

**Feasibility**: LOW - The consistency proof for `temporal_theory_witness_consistent` relies on the G-lift argument which does NOT extend to F-formulas (F lacks the 4-axiom property that G has).

**Confidence**: Low

### Strategy B: F-Formula Closure (Pre-Saturation)

**Approach**: Before Lindenbaum, explicitly exclude G(neg psi) for all F(psi) in M:
```
excluded_set = { G(neg psi) | F(psi) in M }
modified_lindenbaum(seed, excluded_set) - extends seed to MCS while avoiding excluded_set
```

**Implementation Sketch**:
```lean
def temporal_theory_witness_F_preserving (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi in M) :
    exists W : Set Formula, SetMaximalConsistent W /\ phi in W /\
      (forall a, Formula.all_future a in M -> Formula.all_future a in W) /\
      box_class_agree M W /\
      (forall psi, Formula.some_future psi in M -> Formula.all_future (Formula.neg psi) notin W) := by
  -- Build seed avoiding G(neg psi) explicitly
  sorry
```

**Pros**:
- Directly addresses the gap
- Preserves all existing F-obligations
- The exclusion is well-founded: F(psi) and G(neg psi) are contradictory

**Cons**:
- Requires a modified Lindenbaum lemma that respects an exclusion set
- Need to prove the modified Lindenbaum preserves consistency
- More complex construction

**Key Lemma Needed**: If S is consistent and `excluded` is a set where each element contradicts something in S, then there exists MCS W extending S that avoids `excluded`.

**Feasibility**: MEDIUM-HIGH - The exclusion is well-motivated (F(psi) excludes G(neg psi) by consistency), and Lindenbaum-style constructions can be guided to avoid specific inconsistent additions.

**Confidence**: Medium

### Strategy C: F-Aware Lindenbaum (Different Extension Order)

**Approach**: Modify Lindenbaum to prioritize F-formulas before potentially conflicting G-formulas:

1. Enumerate formulas as usual
2. When considering adding G(neg psi), check if F(psi) is already in the partial extension
3. If yes, skip G(neg psi); if no, add as usual

**Implementation Sketch**:
```lean
noncomputable def F_aware_lindenbaum_step (S : Set Formula) (h_cons : SetConsistent S)
    (F_obligations : Set Formula) -- the set { psi | F(psi) in original MCS }
    (f : Formula) : { S' : Set Formula // SetConsistent S' /\ S subset S' } :=
  if Formula.all_future (Formula.neg psi) = f /\ psi in F_obligations then
    -- Skip this G(neg psi) to preserve F(psi)
    ⟨S, h_cons, Set.Subset.refl S⟩
  else
    -- Standard Lindenbaum step
    standard_lindenbaum_step S h_cons f
```

**Pros**:
- Clean integration with existing Lindenbaum infrastructure
- Explicit control over extension order
- Preserves F-obligations by construction

**Cons**:
- Requires proving the modified procedure still produces MCS
- Skipping G(neg psi) might not be sufficient (other formulas could force it)
- Maximality proof becomes more complex

**Key Challenge**: Proving maximality when we skip certain formulas. Need to show that skipping G(neg psi) doesn't prevent the set from being maximal.

**Feasibility**: MEDIUM - The idea is sound but the maximality proof is non-trivial.

**Confidence**: Medium

### Strategy D: Two-Phase Extension (Temporal then Modal)

**Approach**: Build the witness in two phases:

1. **Phase 1 (Temporal Closure)**: Start from seed, close under temporal operators while preserving F-formulas
2. **Phase 2 (Modal Extension)**: Apply standard Lindenbaum to the temporally-closed set

**Implementation Sketch**:
```lean
def temporal_closure (S : Set Formula) : Set Formula :=
  -- Close S under:
  -- - G(a) in S implies a in S (by temp_t_future)
  -- - F(a) in S implies F(F(a)) in S (by F-4 axiom: F(a) -> F(F(a)))
  -- - Explicitly include neg(G(neg psi)) for each F(psi) in S
  sorry

def two_phase_witness (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi in M) :
    { W : Set Formula // SetMaximalConsistent W /\ phi in W /\ ... } := by
  -- Phase 1: temporal closure of seed
  let S1 := temporal_closure ({phi} U G_theory M U box_theory M)
  have h_S1_cons : SetConsistent S1 := sorry
  -- Phase 2: standard Lindenbaum
  obtain ⟨W, h_ext, h_mcs⟩ := set_lindenbaum S1 h_S1_cons
  sorry
```

**Pros**:
- Conceptually clean separation of temporal and modal concerns
- Temporal phase can enforce F-preservation invariants
- Reuses existing Lindenbaum for modal extension

**Cons**:
- Need to define and prove properties of temporal closure
- Two-phase proof is more complex
- F-4 axiom (F(a) -> F(F(a))) doesn't hold in our logic! We have G-4 but not F-4.

**Critical Issue**: The temporal logic lacks `F(a) -> F(F(a))`. We have `G(a) -> G(G(a))` (temp_4) but NOT the dual. This means temporal closure cannot iterate F-formulas.

**Feasibility**: LOW - The lack of F-4 axiom undermines the temporal closure idea.

**Confidence**: Low

## Recommended Approach

### Primary Recommendation: Strategy B (F-Formula Closure)

**Rationale**:
1. Directly addresses the gap without requiring axioms we don't have
2. The exclusion is justified by logical consistency (F(psi) and G(neg psi) are contradictory)
3. Can be implemented as a modified Lindenbaum that takes an exclusion set

### Implementation Plan for Strategy B

1. **Define F-exclusion set**: `excluded M = { G(neg psi) | F(psi) in M }`

2. **Prove consistency of exclusion**: If M is MCS and S = seed extending M, then S U excluded M is inconsistent (each G(neg psi) contradicts some formula derivable from S).

3. **Define excluded Lindenbaum**: A variant of `set_lindenbaum` that takes an exclusion set and builds MCS avoiding it:
   ```lean
   theorem set_lindenbaum_avoiding (S : Set Formula) (h_cons : SetConsistent S)
       (excluded : Set Formula)
       (h_excluded : forall f in excluded, SetConsistent (S U {f}) -> False) :
       exists W, SetMaximalConsistent W /\ S subset W /\
         forall f in excluded, f notin W
   ```

4. **Use in witness construction**: Replace `set_lindenbaum` with `set_lindenbaum_avoiding` in `temporal_theory_witness_exists`.

5. **Prove F-persistence**: With the new construction, F(psi) in chain(n) implies either phi in chain(n+1) OR F(psi) in chain(n+1).

### Fallback: Bundle-Level Coherence

If Strategy B proves too complex, the fallback is already implemented: `boxClassFamilies_bundle_forward_F` provides bundle-level temporal coherence. The trade-off:

- **Bundle-level**: Works, but witness may be in a DIFFERENT family
- **Family-level**: Needed for the truth lemma, which requires witnesses in the SAME family chain

The truth lemma can potentially be refactored to use bundle-level witnesses with additional machinery to translate between families.

## Detailed Analysis: Why Each Strategy Works or Fails

### Strategy A Failure Mode

Consider M with:
- F(p) in M (so neg(G(neg p)) in M)
- F(neg p) in M (so neg(G(neg neg p)) = neg(G(p)) in M)

Then F_theory(M) = {F(p), F(neg p)}. But the seed:
```
{phi, G(a) | G(a) in M, Box(b)/neg(Box(b)), F(p), F(neg p)}
```
may be inconsistent if phi = p:
- p in seed
- F(neg p) in seed, which means neg(G(neg neg p)) = neg(G(p)) in seed
- So we have p and neg(G(p)) = F(neg p)
- These are consistent! So no immediate contradiction...

Actually, the issue is more subtle. The problem is that adding F_theory doesn't HELP preserve F-formulas through Lindenbaum, because Lindenbaum can still add formulas that make subsequent F-obligations impossible.

### Strategy B Key Insight

The key insight for Strategy B is that we don't need to ADD anything to the seed. We need to EXCLUDE things during Lindenbaum:

- Standard Lindenbaum: enumerate all formulas, add each if consistent
- Excluding Lindenbaum: enumerate all formulas, add each if (a) consistent AND (b) not in excluded set

The excluded set `{ G(neg psi) | F(psi) in M }` ensures that once F(psi) is in the original MCS, G(neg psi) never enters any chain extension.

### Strategy C vs Strategy B

Strategy C (F-aware extension order) and Strategy B (explicit exclusion) are essentially equivalent. The difference is implementation:

- Strategy B: Define excluded set upfront, use in modified Lindenbaum
- Strategy C: Check exclusion condition during each Lindenbaum step

Strategy B is cleaner because it separates concerns.

## Existing Codebase Patterns

### G_theory Pattern (to replicate for exclusion)

From UltrafilterChain.lean (lines 959-976):
```lean
def G_theory (M : Set Formula) : Set Formula :=
  { f | exists a, f = Formula.all_future a /\ Formula.all_future a in M }

theorem G_theory_subset_mcs (M : Set Formula) :
    G_theory M subset M := ...
```

We can define `F_excluded_theory` similarly:
```lean
def F_excluded_theory (M : Set Formula) : Set Formula :=
  { f | exists psi, f = Formula.all_future (Formula.neg psi) /\
                    Formula.some_future psi in M }
```

### some_future_excludes_all_future_neg (lines 1083-1098)

This existing theorem is the foundation for the exclusion:
```lean
theorem some_future_excludes_all_future_neg {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi in M) :
    Formula.all_future (Formula.neg phi) notin M := ...
```

This proves that F(phi) and G(neg phi) cannot coexist in an MCS.

### Lindenbaum Extension Point (Core/MaximalConsistent.lean)

The `set_lindenbaum` theorem is the extension point. We need a variant:
```lean
theorem set_lindenbaum_avoiding (S : Set Formula) (h_cons : SetConsistent S)
    (avoid : Set Formula)
    (h_avoid : forall f in avoid, not SetConsistent (S U {f})) :
    exists W, SetMaximalConsistent W /\ S subset W /\ (forall f in avoid, f notin W)
```

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Modified Lindenbaum may not preserve MCS properties | High | Prove that skipping inconsistent formulas doesn't affect maximality |
| F-excluded set may be infinite | Medium | Use finitary approximation or prove excluded formulas are countable |
| Strategy B may require major refactoring | Medium | Implement as wrapper around existing Lindenbaum |
| Alternative strategies may have hidden gaps | High | Thorough analysis before implementation |

## Conclusion

**Recommended Strategy**: B (F-Formula Closure / Excluding Lindenbaum)

**Confidence Level**: Medium-High

**Key Insight**: The gap is NOT in the dovetailed enumeration but in the Lindenbaum extension step. Fixing the extension to respect F-formula constraints closes the gap.

**Next Steps**:
1. Define `F_excluded_theory` predicate
2. Implement `set_lindenbaum_avoiding` variant
3. Modify `temporal_theory_witness_exists` to use avoiding Lindenbaum
4. Prove F-persistence lemma
5. Close `omega_true_dovetailed_forward_F_resolution`

## References

### Codebase Files
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - Main construction
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Core/MaximalConsistent.lean` - Lindenbaum lemma
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean` - Modal saturation pattern

### Literature
- [Temporal Logic - Stanford Encyclopedia of Philosophy](https://plato.stanford.edu/entries/logic-temporal/)
- [Completeness by construction for tense logics of linear time](https://festschriften.illc.uva.nl/D65/verbrugge.pdf)
- [Temporal Logic - Yde Venema](https://staff.science.uva.nl/y.venema/papers/TempLog.pdf)
- [Lindenbaum's Lemma - Open Logic Project](https://builds.openlogicproject.org/content/normal-modal-logic/completeness/lindenbaums-lemma.pdf)
- [Canonical models for normal logics](https://www.doc.ic.ac.uk/~mjs/teaching/ModalTemporal499/CanonicalNormal_499_v0809_2up.pdf)
