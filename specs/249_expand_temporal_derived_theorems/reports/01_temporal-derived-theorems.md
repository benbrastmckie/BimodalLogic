# Research Report: Expand Temporal Derived Theorems

**Task**: 249 -- expand_temporal_derived_theorems
**Date**: 2026-06-02
**Status**: Research complete

## 1. Current Inventory of Temporal Derived Theorems

### Remaining in TemporalDerived.lean (8 sorry-free definitions + 2 duplicates)

| # | Name | Statement | Type | Steps |
|---|------|-----------|------|-------|
| 1 | `G_distribution` | `G(phi -> psi) -> (G phi -> G psi)` | K-dist derived from BX3 | ~12 |
| 2 | `H_distribution` | `H(phi -> psi) -> (H phi -> H psi)` | K-dist via duality | ~15 |
| 3 | `G_transitivity` | `G phi -> G(G phi)` | 4-axiom from BX3+BX6 | ~15 |
| 4 | `H_transitivity` | `H phi -> H(H phi)` | 4-axiom via duality | ~20 |
| 5 | `connect_future_thm` | `phi -> G(P phi)` | Direct BX4 | 1 |
| 6 | `connect_past_thm` | `phi -> H(F phi)` | Direct BX4' | 1 |
| 7 | `G_implies_G_id` | `G a -> G(a -> a)` | Propositional | 3 |
| 8 | `until_implies_some_future` | `(phi U psi) -> F psi` | Direct BX10 | 1 |
| 9 | `since_implies_some_past` | `(phi S psi) -> P psi` | Direct BX10' | 1 |
| 10 | `until_imp_F` | `(phi U psi) -> F psi` | Duplicate of #8 | 1 |
| 11 | `since_imp_P` | `(phi S psi) -> P psi` | Duplicate of #9 | 1 |
| 12 | `contrapositive` | `(A -> B) -> (neg B -> neg A)` | Pure propositional | ~5 |
| 13 | `formula_or_comm` | `(A or B) -> (B or A)` | Pure propositional | ~8 |

**Effective temporal theorems**: 8 unique (removing duplicates and propositional helpers).

### Removed (Task 173): 27 definitions

Archived to `Boneyard/OpenGuardInvalid/`. These were invalid under open guard (t,s) semantics:
- BX9-dependent (10): bot_until_bot_absurd, bot_since_bot_absurd, bot_until_elim, bot_since_elim, until_imp_or, since_imp_or, bot_until_id, bot_since_id, until_unfold_thm, since_unfold_thm
- BX8-dependent (3): psi_imp_until, psi_imp_since, G_implies_topUntil
- Reflexive order (2): refl_F, refl_P
- Seriality (2): G_bot_absurd, H_bot_absurd
- Density (2): density_derivable, past_density_derivable
- Transitive dependents (8): or_until_imp, or_since_imp, until_unfold_wrapped, since_unfold_wrapped, until_intro, since_intro, until_F_expansion, since_P_expansion

### Related Temporal Content in Other Files

- **Perpetuity/Helpers.lean**: `box_to_future` (box phi -> G phi), `box_to_past` (box phi -> H phi), `box_to_present` (box phi -> phi)
- **GeneralizedNecessitation.lean**: `past_necessitation`, `past_k_dist`, `generalized_temporal_k`, `generalized_past_k`
- **Combinators.lean**: `temp_future_derived` (box phi -> G(box phi))

## 2. Available Temporal Axioms and Operators

### Temporal Operators (from Formula.lean)

| Operator | Definition | Notation |
|----------|-----------|----------|
| `some_future phi` (F) | `untl phi top` | Future eventuality |
| `some_past phi` (P) | `snce phi top` | Past eventuality |
| `all_future phi` (G) | `neg(some_future(neg phi))` | Always future |
| `all_past phi` (H) | `neg(some_past(neg phi))` | Always past |
| `next phi` (X) | `untl phi bot` | Immediate successor |
| `prev phi` (Y) | `snce phi bot` | Immediate predecessor |
| `always phi` (triangle) | `H phi and (phi and G phi)` | Omnitemporal |
| `sometimes phi` | `neg(always(neg phi))` | Sometime |
| `weak_future phi` (G') | `phi and G phi` | Reflexive future |
| `weak_past phi` (H') | `phi and H phi` | Reflexive past |

### Available BX Axioms for Derived Theorems

| Axiom | Statement | Use for Derived Theorems |
|-------|-----------|--------------------------|
| BX1/BX1' | seriality: top -> F(top) / top -> P(top) | F/P are non-vacuous |
| BX2G/BX2H | left_mono_until_G/since_H: G(phi->chi) -> (psi U phi -> psi U chi) | Guard monotonicity |
| BX3/BX3' | right_mono_until/since: G(phi->psi) -> (phi U chi -> psi U chi) | Event monotonicity (KEY) |
| BX4/BX4' | connect_future/past: phi -> G(P phi) / phi -> H(F phi) | Temporal connectedness |
| BX5/BX5' | self_accum_until/since | Self-accumulation |
| BX6/BX6' | absorb_until/since | Absorption (for transitivity) |
| BX7/BX7' | linear_until/since | Linearity |
| BX10/BX10' | until_F/since_P: (phi U psi) -> F psi | Eventuality extraction |
| BX11/BX11' | temp_linearity/past | F-linearity |
| BX12/BX12' | F_until_equiv/P_since_equiv: F phi -> U(phi, top) | F/P-to-Until/Since bridge |
| BX13/BX13' | enrichment_until/since | Until-Since enrichment |
| MF | modal_future: box phi -> box(G phi) | Modal-temporal interaction |

### Inference Rules Available

1. `modus_ponens`: If `Gamma |- phi -> psi` and `Gamma |- phi` then `Gamma |- psi`
2. `temporal_necessitation`: If `|- phi` then `|- G phi`
3. `temporal_duality`: If `|- phi` then `|- swap_temporal phi` (swaps U/S, F/P, G/H)
4. `necessitation`: If `|- phi` then `|- box phi`

### Key Derived Infrastructure Already Available

- `imp_trans`: Transitivity of implication
- `mp`: Modus ponens helper
- `contraposition` / `contrapose_imp`: Contraposition
- `b_combinator`: Function composition
- `theorem_flip`: Argument flip
- `pairing`: Conjunction introduction
- `lce_imp` / `rce_imp`: Conjunction elimination (implication form)
- `combine_imp_conj`: Combine two implications into conjunction
- `double_negation`: DNE
- `dni`: DNI
- `classical_merge`: Case analysis
- `past_necessitation`: If `|- phi` then `|- H phi`
- `past_k_dist`: `|- H(A -> B) -> (HA -> HB)`

## 3. Proposed New Temporal Derived Theorems (20 theorems)

### Category A: G/H Distribution Variants (4 theorems)

These distribute G/H over connectives. Each replaces multiple primitive steps.

**A1. `G_and_intro`**: `G phi -> G psi -> G(phi and psi)`
- Derivation: From `G phi` and `G psi`, derive `G(phi and psi)`.
- Use temporal necessitation on `pairing phi psi` to get `G(phi -> psi -> phi and psi)`.
- Apply G_distribution twice.
- Steps saved: ~5 primitive steps per application.
- Computable: Yes (uses only computable infrastructure).

**A2. `H_and_intro`**: `H phi -> H psi -> H(phi and psi)`
- Derivation: Mirror of A1 via temporal duality (or directly via past_k_dist and past_necessitation).
- Steps saved: ~5 primitive steps.

**A3. `G_imp_trans`**: `G(phi -> psi) -> G(psi -> chi) -> G(phi -> chi)`
- Derivation: From G-distribution and imp_trans lifted through G.
- Temporal necessitate `b_combinator` to get `G((psi -> chi) -> (phi -> psi) -> (phi -> chi))`.
- Apply G_distribution twice.
- Steps saved: ~8 primitive steps per chain.

**A4. `H_imp_trans`**: `H(phi -> psi) -> H(psi -> chi) -> H(phi -> chi)`
- Derivation: Mirror of A3 via temporal duality.
- Steps saved: ~8 primitive steps.

### Category B: Temporal Monotonicity (4 theorems)

These are monotonicity lemmas for F, P, G, H as single-step derived rules.

**B1. `F_mono`**: `G(phi -> psi) -> (F phi -> F psi)`
- Derivation: Direct from BX3 with chi := top.
- `G(phi -> psi) -> (untl(phi, top) -> untl(psi, top))` = `G(phi -> psi) -> (F phi -> F psi)`.
- Steps saved: 1 BX3 instantiation step packaged as reusable rule.
- Computable: Yes (single axiom instantiation).

**B2. `P_mono`**: `H(phi -> psi) -> (P phi -> P psi)`
- Derivation: Direct from BX3' with chi := top.
- Steps saved: 1 BX3' instantiation.

**B3. `G_mono`**: `G(phi -> psi) -> (G phi -> G psi)`
- Derivation: This is exactly `G_distribution`. Alias for discoverability.
- Already exists but under different name; aliasing improves usability.

**B4. `H_mono`**: `H(phi -> psi) -> (H phi -> H psi)`
- Derivation: This is exactly `H_distribution`. Alias for discoverability.

### Category C: Temporal Contraposition (4 theorems)

Contraposition lifted through temporal operators.

**C1. `G_contrapose`**: `G(phi -> psi) -> G(neg psi -> neg phi)`
- Derivation: Temporal necessitate `contrapose_imp phi psi` to get `G((phi -> psi) -> (neg psi -> neg phi))`.
  Apply G_distribution.
- Steps saved: ~4 primitive steps.
- Computable: Yes.

**C2. `H_contrapose`**: `H(phi -> psi) -> H(neg psi -> neg phi)`
- Derivation: Mirror of C1 via temporal duality.
- Steps saved: ~4 primitive steps.

**C3. `F_contrapose`**: `G(phi -> psi) -> (F phi -> F psi)` [same as B1 -- so instead:]
  `neg(F phi) -> G(neg phi)` (F/G duality as derived theorem)
- Derivation: `neg(F phi) = neg(untl(phi, top)) = G(neg phi)` by definition. This is definitional but useful as an explicit rewrite lemma.
- Actually F/G duality is definitional: `G phi = neg(F(neg phi))`, so `neg(F phi) = G(neg phi)` directly by definition of `all_future`. This is propositional -- not needed as a theorem per se.

**C3 (revised). `F_neg_G`**: `F(neg phi) -> neg(G phi)` (the semantically useful direction)
- Derivation: `F(neg phi) = untl(neg phi, top)` and `G phi = neg(untl(neg phi, top))`.
  So `F(neg phi) -> neg(G phi)` is `X -> neg(neg X)` = DNI applied to `F(neg phi)`.
  Use `dni` specialized to `F(neg phi)`.
- Steps saved: ~3 steps.

**C4. `P_neg_H`**: `P(neg phi) -> neg(H phi)`
- Derivation: Mirror of C3 via temporal duality.
- Steps saved: ~3 steps.

### Category D: Future-Past Interaction (4 theorems)

These connect future and past operators, using BX4/BX4' (temporal connectedness).

**D1. `G_to_GP`**: `G phi -> G(P phi)` (if phi always holds in the future, then P(phi) does too)
- Derivation: From connect_future (`phi -> G(P phi)`), temporal necessitate to get `G(phi -> G(P phi))`.
  Apply G_distribution to get `G phi -> G(G(P phi))`. But we want `G phi -> G(P phi)`.
  Alternative: Apply BX3 to connect_future. Actually `G phi -> G(P phi)` follows from
  `G(phi -> G(P phi))` and `G phi -> G(G(P phi))`, then use... hmm this gives GG(P phi).
  Better: use `G(phi -> G(P phi))` and two applications of G_distribution.
  Wait: `G(phi -> G(P phi)) -> (G phi -> G(G(P phi)))` via G_distribution. Then we need
  `G(G(P phi)) -> G(P phi)` which is the density axiom or... Actually we don't have
  `GG phi -> G phi` in general at Base frame class! That's the density axiom.
  
  Revised approach: Use BX4 directly: `phi -> G(P phi)`. We want `G phi -> G(P phi)`.
  From `phi -> G(P phi)`, temporal necessitate: `G(phi -> G(P phi))`.
  G_distribution: `G phi -> G(G(P phi))`. But we need `G phi -> G(P phi)`.
  We need `G(G(P phi)) -> G(P phi)` which is density -- not available at Base.
  
  So this is NOT derivable at Base. Only at Dense frame class.
  
  **Revised D1**: Work with F instead. `F phi -> F(phi and P phi)` using enrichment.
  Actually let me reconsider.

**D1 (revised). `FG_to_G_via_connect`**: `phi -> G(P phi)` and `G(P phi) -> G(phi or ...)`
  This is getting complex. Let me instead focus on simpler, clearly derivable theorems.

**D1 (final). `connect_future_G`**: `G phi -> G(G(P phi))` (G phi implies G-permanently G(P phi))
- Derivation: Temporal necessitate `connect_future` to get `G(phi -> G(P phi))`.
  Apply G_distribution: `G phi -> G(G(P phi))`.
- Steps saved: ~4 steps.
- Computable: Yes.

**D2. `connect_past_H`**: `H phi -> H(H(F phi))` (H phi implies H-permanently H(F phi))
- Derivation: Mirror of D1 via temporal duality.
- Steps saved: ~4 steps.

**D3. `PG_interaction`**: `phi -> H(F phi)` (already exists as `connect_past_thm`)
  Instead: `G phi -> phi.weak_future` = `G phi -> phi and G phi`
  Hmm, that requires reflexive G which we don't have (irreflexive semantics).
  
  **D3 (final). `F_imp_FP`**: `F phi -> F(P phi)` (every future phi has a past from its perspective)
  - Derivation: From connect_past `phi -> H(F phi)`. Take contrapositive: `neg H(F phi) -> neg phi`,
    i.e., `P(neg(F phi)) -> neg phi`. This isn't what we want.
    
    Alternative: From BX4' (`phi -> H(F phi)`), and BX3 (event monotonicity):
    `G(phi -> H(F phi)) -> (F phi -> F(H(F phi)))` via BX3.
    Then temporal necessitate `phi -> H(F phi)` to get `G(phi -> H(F phi))`.
    So `F phi -> F(H(F phi))`.
    
    Actually what we want is simpler. `phi -> G(P phi)` via BX4. 
    Temporal necessitate: `G(phi -> G(P phi))`. BX3: `G(phi -> G(P phi)) -> (F phi -> F(G(P phi)))`.
    So: `F phi -> F(G(P phi))`.
    
    Hmm, getting complicated. Let me focus on the simpler ones.

**D3 (final). `FH_bridge`**: `F phi -> F(H(F phi) and phi)` 
  This requires enrichment (BX13). Actually let me just pick useful simple ones.

**D3 (truly final). `connect_future_chain`**: `phi -> G(P phi)` composed with `P phi -> H(F(P phi))`
  to get `phi -> G(H(F(P phi)))`. This is `connect_past applied to P phi` composed with
  `connect_future`.
  - Derivation: `P phi -> H(F(P phi))` (BX4' at `P phi`). Then from `phi -> G(P phi)`,
    temporal necessitate `P phi -> H(F(P phi))` to get `G(P phi -> H(F(P phi)))`.
    G_distribution: `G(P phi) -> G(H(F(P phi)))`.
    Compose: `phi -> G(P phi) -> G(H(F(P phi)))`.
  - Steps saved: ~6 steps. Demonstrates chained temporal reasoning.

**D4. `connect_past_chain`**: `phi -> H(F phi) -> H(G(P(F phi)))` (mirror)
  - Derivation: Mirror of D3 via temporal duality.
  - Steps saved: ~6 steps.

### Category E: Until/Since Structural Lemmas (4 theorems)

**E1. `until_mono_guard`**: `G(phi -> chi) -> ((psi U phi) -> (psi U chi))`
- Derivation: Direct from BX2G axiom (left_mono_until_G).
- Why useful: Common pattern when strengthening/weakening Until guards.
- Steps saved: 1 axiom instantiation as reusable rule (but importantly names the pattern).
- Computable: Yes.

**E2. `since_mono_guard`**: `H(phi -> chi) -> ((psi S phi) -> (psi S chi))`
- Derivation: Direct from BX2H axiom (left_mono_since_H).
- Steps saved: 1 axiom instantiation.

**E3. `until_mono_event`**: `G(phi -> psi) -> ((phi U chi) -> (psi U chi))`
- Derivation: Direct from BX3 axiom (right_mono_until).
- Why useful: Common pattern when strengthening/weakening Until events.
- Steps saved: 1 axiom instantiation.

**E4. `since_mono_event`**: `H(phi -> psi) -> ((phi S chi) -> (psi S chi))`
- Derivation: Direct from BX3' axiom (right_mono_since).
- Steps saved: 1 axiom instantiation.

## 4. Proof Compression Analysis

### Highest Compression Value (top 8)

| Rank | Theorem | Steps Saved Per Use | Frequency Estimate |
|------|---------|--------------------|--------------------|
| 1 | `G_imp_trans` (A3) | 8 | High (chaining G-implications) |
| 2 | `H_imp_trans` (A4) | 8 | High (chaining H-implications) |
| 3 | `G_and_intro` (A1) | 5 | Very High (combining G-facts) |
| 4 | `H_and_intro` (A2) | 5 | Very High (combining H-facts) |
| 5 | `G_contrapose` (C1) | 4 | High (temporal negation reasoning) |
| 6 | `H_contrapose` (C2) | 4 | High (temporal negation reasoning) |
| 7 | `connect_future_chain` (D3) | 6 | Medium (deep temporal chaining) |
| 8 | `connect_past_chain` (D4) | 6 | Medium (deep temporal chaining) |

### Importance for BimodalHarness

The current ProofStepExport registry has 310 entries with 7 TemporalDerived source theorems (of 36 total originals = 19.4%). However, only 3 of those 7 are non-trivial multi-step proofs (connect_future, connect_past, G_implies_G_id -- the rest are single-axiom wrappers).

Adding 20 new temporal derived theorems would:
- Increase unique temporal source theorems from 7 to 27 (75% of originals)
- Add ~60 registry entries (original + G-wrapped + H-wrapped)
- Provide significantly more temporal-specific proof patterns for training
- Each multi-step theorem (A1-A4, C1-C2, D3-D4) adds genuinely new proof patterns combining temporal and propositional reasoning

## 5. Computability Assessment

### Computable (suitable for ProofStepExport registry)

All 20 proposed theorems are computable because they use only:
- `DerivationTree.axiom` (computable)
- `DerivationTree.modus_ponens` (computable)
- `DerivationTree.temporal_necessitation` (computable)
- `DerivationTree.temporal_duality` (computable)
- Existing computable combinators (`imp_trans`, `mp`, `b_combinator`, `pairing`, etc.)

**Critical constraint**: Theorems using `noncomputable def` (like `G_distribution`, `H_distribution`, `G_transitivity`, `H_transitivity`) CANNOT be registered in ProofStepExport. The new theorems should avoid `noncomputable` where possible.

**Noncomputability source**: The existing `temp_k_dist_derived` and `temp_4_derived` are `noncomputable` because they use `contraposition` which uses `contrapose_imp` which is built from pure combinators -- but somewhere in the chain `noncomputable` propagates. This needs investigation.

Actually, looking more carefully: `G_distribution` is `noncomputable` because it calls `temp_k_dist_derived` which is `noncomputable`. The source of noncomputability is likely the use of `by` tactic blocks or certain classical principles.

**Recommendation**: Where possible, build the new theorems as `def` (not `noncomputable def`) using explicit DerivationTree term construction rather than tactic mode. This ensures they can be registered in ProofStepExport.

For theorems that depend on `G_distribution` or `H_distribution` (Categories A, C), they will inherit `noncomputable`. This is acceptable for the proof system but means they cannot be directly registered in ProofStepExport. For the registry, we would instead register their BX3-based equivalents as multi-step proof chains.

### Computability Classification

| Category | Computable? | Reason |
|----------|-------------|--------|
| A1-A4 (G/H distribution variants) | noncomputable | Depend on G/H_distribution |
| B1-B4 (F/P/G/H monotonicity) | computable | Direct axiom wrappers |
| C1-C2 (G/H contrapose) | noncomputable | Use G_distribution |
| C3-C4 (F/P neg duality) | computable | Use dni (computable) |
| D1-D2 (connect chain) | noncomputable | Use G_distribution |
| D3-D4 (deep connect chain) | noncomputable | Use G_distribution |
| E1-E4 (Until/Since structural) | computable | Direct axiom wrappers |

**Total computable**: 8 (B1-B4, C3-C4, E1-E4)
**Total noncomputable**: 12 (A1-A4, C1-C2, D1-D4)

For ProofStepExport, the 8 computable theorems can be directly registered. The 12 noncomputable ones contribute proof library value but must be registered via alternative constructions or omitted from the registry.

## 6. Integration Plan with ProofStepExport Registry

### Phase 1: Computable Single-Step Wrappers (E1-E4, B1-B2)

Add 6 computable `def` definitions that wrap single BX axiom instantiations:
- `until_mono_guard`, `since_mono_guard` (BX2G/BX2H)
- `until_mono_event`, `since_mono_event` (BX3/BX3')
- `F_mono`, `P_mono` (BX3/BX3' specialized)

Each generates 1 proof step but provides a named, reusable pattern. Register all 6 in ProofStepExport with G-wrapped and H-wrapped variants (6 * 3 = 18 registry entries).

### Phase 2: Computable Duality Lemmas (C3-C4)

Add 2 computable `def` definitions using `dni`:
- `F_neg_G`: `F(neg phi) -> neg(G phi)` via DNI
- `P_neg_H`: `P(neg phi) -> neg(H phi)` via duality

Register with G/H variants (2 * 3 = 6 registry entries).

### Phase 3: Noncomputable Distribution Variants (A1-A4, C1-C2)

Add 6 `noncomputable def` definitions:
- `G_and_intro`, `H_and_intro`
- `G_imp_trans`, `H_imp_trans`
- `G_contrapose`, `H_contrapose`

These serve the proof library but cannot be directly registered. For the registry, construct equivalent multi-step proofs using computable infrastructure.

### Phase 4: Noncomputable Chain Theorems (D1-D4)

Add 4 `noncomputable def` definitions:
- `connect_future_G`, `connect_past_H`
- `connect_future_chain`, `connect_past_chain`

Same registry treatment as Phase 3.

### ProofStepExport Changes

Add to `ProofStepExport.lean`:

```lean
-- Phase 1: Computable temporal monotonicity (6 base + 12 wrapped = 18)
mkEntry "until_mono_guard" (TemporalDerived.until_mono_guard p q r),
mkEntry "since_mono_guard" (TemporalDerived.since_mono_guard p q r),
mkEntry "until_mono_event" (TemporalDerived.until_mono_event p q r),
mkEntry "since_mono_event" (TemporalDerived.since_mono_event p q r),
mkEntry "F_mono" (TemporalDerived.F_mono p q),
mkEntry "P_mono" (TemporalDerived.P_mono p q),
-- + G-wrapped, H-wrapped, GG-wrapped variants

-- Phase 2: Computable duality (2 base + 4 wrapped = 6)
mkEntry "F_neg_G" (TemporalDerived.F_neg_G p),
mkEntry "P_neg_H" (TemporalDerived.P_neg_H p),
-- + G-wrapped, H-wrapped variants
```

**Estimated new registry entries**: 24-36 (depending on wrapping depth).

## 7. Recommended Implementation Approach and Ordering

### Implementation Order

1. **Phase 1** (easiest, highest value per effort): E1-E4, B1-B2
   - These are single axiom wrappers -- trivial to implement
   - Immediately boost temporal coverage in ProofStepExport
   - All computable

2. **Phase 2** (easy, useful duality lemmas): C3-C4
   - Use `dni` which is computable
   - Demonstrate F/G and P/H duality patterns

3. **Phase 3** (medium, requires G/H_distribution): A1-A4, C1-C2
   - Build on existing G_distribution and H_distribution
   - Noncomputable but high proof compression value
   - Most useful for manual proof construction

4. **Phase 4** (medium-complex, compositional): D1-D4
   - Chain multiple temporal axioms together
   - Demonstrate deep temporal reasoning patterns
   - Noncomputable

### File Organization

All 20 new theorems should be added to `Theories/Bimodal/Theorems/TemporalDerived.lean` to maintain the existing organization. Group by category with section markers matching the categories above.

### Testing Strategy

1. Each theorem should compile without `sorry`
2. `lake build` must pass after all additions
3. Computable theorems should be verifiable by adding to ProofStepExport registry

### Risk Assessment

- **Low risk**: Categories B and E (single axiom wrappers)
- **Low-medium risk**: Categories C3-C4 (simple DNI application)
- **Medium risk**: Categories A, C1-C2 (depend on noncomputable G/H_distribution but proof pattern is well-established)
- **Medium risk**: Category D (composition of multiple temporal axioms, more complex proof terms)

### Naming Conventions

Follow existing patterns:
- Future/Past mirror pairs: same base name, G/H or F/P prefix
- Monotonicity: `X_mono` where X is the operator
- Distribution: `X_Y_intro` for distributing X over connective Y
- Chains: descriptive names like `connect_future_chain`

## 8. Final Proposed Theorem List (20 Theorems)

| # | Name | Statement | Category | Computable |
|---|------|-----------|----------|------------|
| 1 | `G_and_intro` | `G phi -> G psi -> G(phi and psi)` | A | No |
| 2 | `H_and_intro` | `H phi -> H psi -> H(phi and psi)` | A | No |
| 3 | `G_imp_trans` | `G(phi -> psi) -> G(psi -> chi) -> G(phi -> chi)` | A | No |
| 4 | `H_imp_trans` | `H(phi -> psi) -> H(psi -> chi) -> H(phi -> chi)` | A | No |
| 5 | `F_mono` | `G(phi -> psi) -> (F phi -> F psi)` | B | Yes |
| 6 | `P_mono` | `H(phi -> psi) -> (P phi -> P psi)` | B | Yes |
| 7 | `G_mono` | `G(phi -> psi) -> (G phi -> G psi)` | B | Alias |
| 8 | `H_mono` | `H(phi -> psi) -> (H phi -> H psi)` | B | Alias |
| 9 | `G_contrapose` | `G(phi -> psi) -> G(neg psi -> neg phi)` | C | No |
| 10 | `H_contrapose` | `H(phi -> psi) -> H(neg psi -> neg phi)` | C | No |
| 11 | `F_neg_G` | `F(neg phi) -> neg(G phi)` | C | Yes |
| 12 | `P_neg_H` | `P(neg phi) -> neg(H phi)` | C | Yes |
| 13 | `connect_future_G` | `G phi -> G(G(P phi))` | D | No |
| 14 | `connect_past_H` | `H phi -> H(H(F phi))` | D | No |
| 15 | `connect_future_chain` | `phi -> G(H(F(P phi)))` | D | No |
| 16 | `connect_past_chain` | `phi -> H(G(P(F phi)))` | D | No |
| 17 | `until_mono_guard` | `G(phi -> chi) -> (psi U phi -> psi U chi)` | E | Yes |
| 18 | `since_mono_guard` | `H(phi -> chi) -> (psi S phi -> psi S chi)` | E | Yes |
| 19 | `until_mono_event` | `G(phi -> psi) -> (phi U chi -> psi U chi)` | E | Yes |
| 20 | `since_mono_event` | `H(phi -> psi) -> (phi S chi -> psi S chi)` | E | Yes |

**Computable for ProofStepExport**: 8 unique + 2 aliases = 10
**Total proof library additions**: 20 theorems
**Estimated new ProofStepExport entries**: 24-36 (with G/H/GG wrapping)

## 9. Blockers

None identified. All proposed theorems are derivable from the existing BX axiom system under open guard semantics. No axiom soundness concerns.
