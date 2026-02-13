# Teammate B Findings: Alternative Approaches and Prior Art for Modal Saturation

**Task**: 881 - Construct modally saturated BMCS to eliminate `fully_saturated_bmcs_exists` axiom
**Date**: 2026-02-13
**Focus**: Alternative approaches, prior art analysis, Mathlib patterns, failed approach post-mortem

## Key Findings

### 1. Three Distinct Axioms Must Be Eliminated

The codebase currently contains **three** related axioms for modal saturation (all in active Theories/ code):

| Axiom | File | Purpose |
|-------|------|---------|
| `fully_saturated_bmcs_exists` | TemporalCoherentConstruction.lean:773 | Combined temporal+modal BMCS |
| `saturated_extension_exists` | CoherentConstruction.lean:871 | CoherentBundle saturation extension |
| `singleFamily_modal_backward_axiom` | Construction.lean:219 | Single-family modal backward (known FALSE) |

Additionally, `weak_saturated_extension_exists` in WeakCoherentBundle.lean:826 is another axiom variant.

**Important**: `singleFamily_modal_backward_axiom` is documented as mathematically FALSE (see TemporalCoherentConstruction.lean:706-746). The other axioms are mathematically correct but unproven. `fully_saturated_bmcs_exists` subsumes both `saturated_extension_exists` and `singleFamily_modal_backward_axiom`.

### 2. The EvalCoherentBundle Approach Is the Most Promising Near-Complete Path

The `EvalCoherentBundle` construction in CoherentConstruction.lean (lines 1094-1336) is the most developed path. It:

- **Has working witness addition**: `EvalCoherentBundle.addWitness` (line 1217) adds a single witness family preserving EvalCoherent invariant
- **Has proven key lemma**: `diamond_boxcontent_consistent_constant` (line 249) proves WitnessSeed consistency for constant families
- **Has enumeration infrastructure**: `addWitnessesForList` (line 1284) iterates over a list of Diamond formulas
- **Has the right architecture**: EvalCoherent only cares about BoxContent of the fixed eval_family, avoiding the Lindenbaum control problem

**Gap**: The bridge from `EvalCoherentBundle` + `EvalSaturated` to a full `BMCS` with `is_modally_saturated` is incomplete. The `toEvalBMCS` conversion (line 1119) produces an `EvalBMCS` (weaker structure), not a full `BMCS`.

### 3. Prior Art in Boneyard: The FDSM Approach Failed Due to MCS-Tracking

The Boneyard/FDSM/ModalSaturation.lean (1577 lines) represents the most extensive prior attempt. It:

- **Proved witness set consistency** (`witness_set_consistent`, line 123) -- a complete proof
- **Proved witness history models psi** (`buildWitnessHistory_models_psi`, line 527) -- complete
- **Built fuel-based saturation** (`saturate_with_fuel`, line 659) -- working iteration
- **Built MCS-tracked saturation** (`tracked_saturate_with_fuel`, line 1197) -- enhanced version

**Why it was abandoned**:
1. The `mcsTrackedHistory_finite` sorry (line 977) blocks the tracked approach -- proving that `MCSTrackedHistory` is finite requires showing the `history` field determines the structure, which is not injective in general
2. The `fixed_point_is_saturated` theorem (line 870) has a sorry because it requires linking world states back to MCS to invoke the witness builder
3. The `projectTrackedHistories_modal_saturated` sorry (line 1450) requires relating world state `toSet` membership back to MCS membership
4. The FDSM construction is specific to finite closure-based models, while the current BMCS uses unrestricted Set Formula

**Salvageable parts**: The witness set consistency proof and the generalized modal K argument are reusable. The fuel-based iteration pattern with monotone cardinality is correct.

### 4. The Lindenbaum Control Problem is the Central Obstacle

Every approach in the codebase has hit the same fundamental obstacle:

> When extending a seed `{psi} union BoxContent` to a full MCS via Lindenbaum, the resulting MCS may contain new Box formulas. These new boxes propagate coherence obligations to ALL other families, but those families were already constructed and cannot be modified.

The different approaches handle this differently:

| Approach | Handling Strategy | Outcome |
|----------|-------------------|---------|
| CoherentBundle (full) | Require all families share UnionBoxContent | Fails: Lindenbaum adds uncontrolled boxes |
| WeakCoherentBundle | Only require BoxClosure(core) | Better: Core is fixed, but axiom remains |
| EvalCoherentBundle | Only require BoxContent(eval) | Best: eval_family is fixed permanently |
| FDSM (Boneyard) | MCS-tracked histories | Fails: Finiteness sorry, world-state-to-MCS gap |
| RecursiveSeed | Pre-place all witnesses before Lindenbaum | Incomplete: Only handles formula-structural witnesses |

**The EvalCoherentBundle approach avoids the problem entirely** because:
- `BoxContent(eval_family)` is fixed at construction time
- New Box formulas in witness families do NOT create obligations for other families
- Only the eval_family needs modal_backward; other families just need to exist

### 5. Mathlib Patterns Available for Saturation Termination

Relevant Mathlib lemmas verified via `lean_local_search`:

| Lemma | Location | Relevance |
|-------|----------|-----------|
| `Nat.stabilises_of_monotone` | Mathlib.Order.Monotone.Basic | Proves bounded monotone sequences stabilize |
| `zorn_subset_nonempty` | Mathlib.Order.Zorn | For maximal consistent set extension |
| `Group.card_pow_eq_card_pow_card_univ_aux` | Mathlib | Same stabilization pattern |
| `OmegaCompletePartialOrder.fixedPoints.iterateChain` | Mathlib | Iterate monotone function to fixed point |

For the EvalCoherentBundle approach, termination is NOT the main issue because we enumerate Diamond formulas from the eval_family (which is an MCS with a fixed formula set). The issue is proving the resulting bundle satisfies `is_modally_saturated` as defined for BMCS.

### 6. Alternative Architecture: Single-Pass Modal+Temporal Construction

The current architecture separates temporal and modal construction:
1. Build temporal coherent family (DovetailingChain)
2. Add modal witnesses (saturation step)

An alternative single-pass approach would:
1. Enumerate ALL formulas in the starting MCS
2. Process each formula based on its type (Box/Diamond/G/H/F/P)
3. Create families AND time witnesses simultaneously

This is essentially what RecursiveSeed.lean attempts. The challenge is that RecursiveSeed only handles structural witnesses (from the formula tree), not Lindenbaum-added witnesses.

### 7. Countable Enumeration Approach for MCS Diamond Witnesses

For a set-theoretic MCS M (uncountable in general), enumerating all Diamond formulas is problematic. However:

- **The Formula type is countable** (built from countable atoms, finite constructors)
- **Diamond formulas in M form a subset of all formulas**
- **We can use Choice to select witnesses** -- no constructive enumeration needed

The key insight is that we do NOT need to iterate. We can use a **single-step construction**:

```
For every formula psi such that Diamond(psi) in M:
  Let M_psi = Lindenbaum({psi} union BoxContent(M))
  Let fam_psi = constantWitnessFamily(M_psi)
```

Then the BMCS families = {base} union {fam_psi | Diamond(psi) in base.mcs t}.

This works because:
- `diamond_boxcontent_consistent_constant` proves each seed is consistent
- Each witness family contains BoxContent(base) by Lindenbaum extension
- No iteration needed -- all witnesses are independent

The challenge: proving this is `is_modally_saturated` requires showing `psi in fam_psi.mcs t`, which follows from Lindenbaum extension of {psi} union BoxContent(M).

## Alternative Approaches Analysis

### Approach A: Direct Zorn-Based Maximal Saturated Extension

**Idea**: Define the set of all CoherentBundles extending the initial bundle, ordered by family inclusion. Apply `zorn_subset_nonempty` to get a maximal element. Prove maximality implies saturation.

**Pros**:
- Clean mathematical argument
- Mathlib's `zorn_subset_nonempty` is available and verified

**Cons**:
- Proving the chain upper bound preserves mutual coherence is hard
- Union of infinitely many families may not preserve MutuallyCoherent
- Maximality -> saturation requires showing we can always extend non-saturated bundles

**Assessment**: Medium difficulty. The chain bound argument is the main gap.

### Approach B: Single-Step Family Set Construction (RECOMMENDED)

**Idea**: Build all witness families at once, non-iteratively:
1. Start with constant base family from Lindenbaum(Gamma)
2. For each neg(Box phi) in base.mcs t, construct witness family via Lindenbaum({neg phi} union BoxContent(base))
3. The BMCS families = {base} union {all witnesses}

**Pros**:
- No iteration or termination argument needed
- BoxContent(base) is fixed, so Lindenbaum control problem doesn't apply
- `diamond_boxcontent_consistent_constant` already proves seed consistency
- Witness families are independent of each other

**Cons**:
- Produces an `EvalBMCS` (eval-centered), not full BMCS
- For full BMCS `is_modally_saturated`, need Diamond witnesses for ALL families, not just base
- Witness families may introduce new Diamond formulas without witnesses

**Assessment**: High feasibility for EvalBMCS. For full `is_modally_saturated`, witness families also need their own witnesses (recursive/iterative).

### Approach C: Eval-Centered BMCS with Relaxed Saturation

**Idea**: Instead of full `is_modally_saturated` (all families), prove a weaker condition that still implies `fully_saturated_bmcs_exists`:
- Only require modal saturation at the eval_family
- Other families only need modal_forward (which follows from EvalCoherent)
- Modify `fully_saturated_bmcs_exists` to return an EvalBMCS instead

**Pros**:
- Avoids the recursive witness problem entirely
- All infrastructure exists in EvalCoherentBundle
- Sufficient for completeness theorem (truth lemma evaluates at eval_family)

**Cons**:
- Requires modifying how the BMCS is used downstream
- May need to change the BMCS structure or add an alternative path in Completeness.lean

**Assessment**: High feasibility but requires downstream refactoring.

### Approach D: Countable Iteration with Stabilization

**Idea**: Use `Nat.stabilises_of_monotone` pattern:
1. Start with singleton EvalCoherentBundle
2. At each step, add witnesses for all unsatisfied Diamond formulas across ALL current families
3. New witnesses may introduce new Diamond formulas
4. Each step increases the total formula count; bounded by countability of Formula
5. Prove stabilization using Mathlib's monotone stabilization lemma

**Pros**:
- Achieves full `is_modally_saturated`
- Clean termination argument

**Cons**:
- Need to maintain EvalCoherent at each step (proved: `addWitness_preserves_EvalCoherent`)
- New witness families may have Diamond formulas that require FURTHER witnesses
- The iteration may not terminate in finite steps (Formula is countable but infinite)
- Need omega-indexed construction or transfinite argument

**Assessment**: Theoretically sound but technically challenging in Lean.

## Prior Art Analysis: What Failed and Why

### Attempt 1: Pre-Coherent Bundle (Pre-Task-844)
- **What**: Product of families satisfying local property P
- **Why failed**: Local properties cannot enforce global agreement
- **Lesson**: Bundle construction must BUILD agreement into the construction process

### Attempt 2: CoherentBundle + Zorn (Task 851-853)
- **What**: Mutually coherent families, Zorn for maximal extension
- **Why stalled**: Multi-family UnionWitnessSeed consistency unproven; Lindenbaum adds uncontrolled boxes
- **Lesson**: UnionBoxContent grows when adding families, creating circular dependency

### Attempt 3: WeakCoherentBundle (Post-Task-853)
- **What**: Core/witness separation, BoxClosure instead of UnionBoxContent
- **Why stalled**: Still has `weak_saturated_extension_exists` axiom
- **Lesson**: Separation helps but doesn't fully resolve the extension problem

### Attempt 4: FDSM Tracked Saturation (Task 825)
- **What**: Finite dynamical system model with MCS-tracked histories
- **Why abandoned**: `mcsTrackedHistory_finite` sorry, world-state-to-MCS gap
- **Lesson**: Tracking MCS origin is useful but type-level finiteness is hard

### Attempt 5: RecursiveSeed (Task 864/880)
- **What**: Pre-place all witnesses from formula structure before Lindenbaum
- **Why incomplete**: Only handles formula-structural witnesses, not Lindenbaum-added ones
- **Lesson**: Pre-placement avoids cross-sign propagation but is incomplete for F/P witnesses

## Evidence: Verified Lemma Names

All lemma names below verified via `lean_local_search`:

| Name | File | Status |
|------|------|--------|
| `diamond_boxcontent_consistent_constant` | CoherentConstruction.lean | Proven (no sorry) |
| `constructCoherentWitness` | CoherentConstruction.lean | Defined |
| `addWitness_preserves_EvalCoherent` | CoherentConstruction.lean | Proven (no sorry) |
| `EvalCoherentBundle.addWitness` | CoherentConstruction.lean | Defined |
| `EvalCoherentBundle.toEvalBMCS` | CoherentConstruction.lean | Defined |
| `saturated_modal_backward` | ModalSaturation.lean | Proven (no sorry) |
| `CoherentBundle.toBMCS` | CoherentConstruction.lean | Defined (no sorry) |
| `witness_set_consistent` | FDSM/ModalSaturation.lean | Proven (no sorry) |
| `neg_box_to_diamond_neg` | CoherentConstruction.lean | Proven (no sorry) |
| `zorn_subset_nonempty` | Mathlib.Order.Zorn | Available in Mathlib |
| `Nat.stabilises_of_monotone` | Mathlib.Order.Monotone.Basic | Available in Mathlib |

## Confidence Level

**Overall**: Medium-High

**Approach B (Single-Step)**: High confidence for EvalBMCS path. The key lemma (`diamond_boxcontent_consistent_constant`) is already proven and the EvalCoherentBundle infrastructure is solid.

**Full `is_modally_saturated`**: Medium confidence. Achieving full saturation (witnesses for ALL families, not just eval) requires either:
1. Showing single-step is sufficient (witness families don't introduce unsatisfied Diamonds), or
2. An iterative/transfinite construction

**Risk**: The biggest risk is that achieving full `is_modally_saturated` is not needed. If the completeness proof only needs EvalBMCS-level properties, then the simpler path suffices and the `fully_saturated_bmcs_exists` axiom can be replaced with a weaker statement.

## Recommendations

1. **Prioritize Approach B + C**: Build the single-step EvalCoherentBundle saturation first, then assess if full `is_modally_saturated` is actually needed downstream.

2. **Audit downstream usage**: Check how `fully_saturated_bmcs_exists` is used in the completeness proof. If only eval_family properties are needed, the axiom can be weakened significantly.

3. **Reuse proven infrastructure**: The `diamond_boxcontent_consistent_constant`, `constructCoherentWitness`, and `addWitness_preserves_EvalCoherent` lemmas are solid foundations.

4. **Consider two-phase elimination**: Phase 1: Replace axiom with EvalBMCS-based construction. Phase 2: (if needed) Strengthen to full BMCS with iterative saturation.

5. **Do NOT attempt the Zorn approach for full MutuallyCoherent saturation** -- the Lindenbaum control problem makes this fundamentally harder than the eval-centered approach.
