# Teammate C Findings: Tuple-Based Construction and U/S Contribution

**Task**: 83 -- Close Restricted Coherence Sorries
**Round**: 31
**Date**: 2026-04-07
**Focus**: Tuple-Based Construction mapping + Until/Since cost-benefit analysis

---

## Part 1: Tuple-Based Construction -- Precise Mapping to Quasimodel Concepts

### 1.1 Concept Correspondence Table

| Tuple Construction | Standard Quasimodel | Codebase Term | File |
|--------------------|--------------------|--------------|----|
| Tuple | Type / Atom (maximal consistent subset of closure) | `SetMaximalConsistent M` restricted to `subformulaClosure` | `Core/MaximalConsistent.lean` |
| Task | Defect / Request (unfulfilled eventuality) | `F(ψ) ∈ M` with no witness yet | `DeterministicFMCS.lean:64` |
| Timeline | Run / Realization (sequence of types over ℤ) | `deterministic_chain M₀ : ℤ → Set Formula` | `DeterministicChain.lean:61` |
| Duration resolution | Realization function (mapping types to time indices) | `iterate_x_content` / `iterate_y_content` | `DeterministicChain.lean:49-56` |
| Constraint satisfaction | Coherence (all defects resolved) | `forward_F` + `backward_P` | `DeterministicFMCS.lean:64-74` |

### 1.2 What the Tuple Construction Adds

The tuple-based construction (analyzed in Report 30 by Teammate C) is essentially a reinvention of the quasimodel approach with three potentially novel elements:

**1. Explicit separation of existential and universal concerns.**

The standard deterministic chain is "push-based": `chain(n+1) = x_content(chain(n))`. F-resolution is "pull-based": we need a witness at some future position. The tuple construction proposes building the chain *witness-first* (place witnesses, then fill in between).

**Codebase evidence**: The existing `temporal_theory_witness_with_g_exists` (referenced in Report 24, section 1.2, line 99) already provides pull-based F-witnesses -- it finds an MCS W with `ψ ∈ W` and `g_content(M) ⊆ W`. The problem is that this W lives in a DIFFERENT chain, not in `deterministic_chain M₀`.

**2. Constraint satisfaction framing (Bellman-Ford).**

The proposal models F/P obligations as difference constraints: `t_j - t_i ≥ 1` for F, `t_i - t_j ≥ 1` for P. Since the F-constraint graph is a DAG (F goes from formula to strict subformula), there are no positive cycles, so Bellman-Ford confirms satisfiability.

**Limitation confirmed by Report 30**: This handles EXISTENTIAL constraints (F/P witness placement) but NOT universal constraints (G/H propagation). The system `∀ s > t, φ ∈ chain(s)` is not a difference constraint. This is exactly the forward_F gap.

**3. The gap the construction does NOT close.**

The tuple construction does not resolve the circularity identified in Report 24 Section 1.3:
- `forward_F(ψ)` at chain(t) requires ψ at some chain(s) with s > t
- To derive `G(¬ψ) ∈ chain(t)` (the contrapositive of F(ψ) ∉ chain(t)), we need: for all s > t, `¬ψ ∈ chain(s)` implies `G(¬ψ) ∈ chain(t)` -- this is `temporal_backward_G_with_fwd_F`, which takes `forward_F` as a hypothesis

The tuple/witness-first philosophy correctly identifies WHERE the gap is but does not provide a mechanism to close it within the deterministic chain architecture.

### 1.3 Does it resolve the forward_F circularity?

**No.** The circularity is structural to any approach that:
1. Uses a single deterministic chain per family
2. Needs to prove that MCS membership reflects semantic truth for ALL formulas including G/H

The tuple construction shares property (1) -- placing witnesses along a single ℤ-indexed timeline. The truth lemma requirement (2) creates the circular dependency regardless of how the chain is constructed.

**What WOULD resolve it**: A construction that does NOT require the truth lemma to hold for G/H formulas in the same inductive step as F/P resolution. The quasimodel eliminative fixpoint (GHR 1994) does this by building the type graph first and eliminating types with unresolvable defects, so that by the time the truth lemma is proved, all defects are already resolved. But this requires a NON-deterministic type graph, which conflicts with the existing codebase architecture.

---

## Part 2: Until/Since Contribution to the Representation Theorem

### 2.1 What Role Do U/S Play in Completeness Proofs?

In the standard GHR (1994) quasimodel construction for temporal logic with Until/Since:

1. **Defects** are defined as unfulfilled Until formulas: `φ U ψ ∈ type(t)` with no witness position s > t where ψ ∈ type(s)
2. **Elimination** proceeds by induction on Until-nesting depth: defects of lower nesting depth are resolved first, then higher depths
3. **Until Induction axiom** provides the well-founded measure: it guarantees that if `G(ψ → χ) ∧ G(φ ∧ X(χ) → χ)` then `(φ U ψ) → X(χ)` -- essentially, Until obligations decrease

**Critical question**: Does this mechanism REQUIRE U to be in the object language?

**Answer: In principle, NO.** The GHR construction uses U primarily to *track* eventuality obligations. The same tracking can be done meta-theoretically: instead of `F(ψ) → ⊤ U ψ` in the object language (which is the unsound F_until_equiv), one can track `{ψ : F(ψ) ∈ M₀}` as a meta-level set and resolve them by structural induction on the subformula closure.

### 2.2 Can Completeness Be Proven WITHOUT U/S in the Language?

**Yes, in principle. The logic Kt + S5 + linearity axioms over ℤ is complete without U/S.**

Here is the argument:

**The base logic**: atom, bot, imp, box, G, H (6 constructors instead of 8). Derived: F = ¬G¬, P = ¬H¬. The axioms are the 18 base axioms (all `isBase = True` in Axioms.lean:873-899): prop_k, prop_s, ex_falso, peirce, modal_t/4/b/5_collapse/k_dist, temp_k_dist, temp_4, temp_t_future, temp_t_past, temp_a, temp_a_dual, temp_l, modal_future, temp_future, temp_linearity.

**What changes in the completeness proof**:

1. **Formula type**: Remove `untl` and `snce` constructors. 6 constructors instead of 8.
2. **Truth definition**: Remove the `untl` and `snce` cases from `truth_at`. 6 cases instead of 8.
3. **Subformula closure**: Becomes smaller (no Until/Since deferrals). `SubformulaClosure.lean` simplifies.
4. **Axiom type**: Remove 14 axiom constructors: until_unfold, until_intro, until_induction, until_linearity, since_unfold, since_intro, since_induction, since_linearity, until_connectedness, since_connectedness, F_until_equiv, P_since_equiv, next_implies_some_future, and the X/Y axioms (x_k_dist, x_det, y_k_dist, y_det, yx_identity, xy_identity). That is 20 fewer constructors.
5. **Truth lemma**: No `untl`/`snce` cases needed. The `h_uc : B.until_since_coherent` parameter disappears entirely from `ParametricTruthLemma.lean`.
6. **Forward_F sorry**: Still exists. The forward_F problem is about F (= ¬G¬), not about Until. **Dropping U/S does not resolve the forward_F blocker.**
7. **Soundness**: The `F_until_equiv_valid` sorry disappears. All base axiom soundness proofs are already sorry-free (Soundness.lean).

**Key insight**: The forward_F problem is NOT a U/S problem. It is a G/H problem: converting meta-level "ψ ∉ chain(s) for all s > t" to object-level "G(¬ψ) ∈ chain(t)". This problem exists with or without Until/Since.

### 2.3 What Challenges Does INCLUDING U/S Present?

I catalogued every Until/Since-related sorry and structural cost in the codebase:

**Sorries directly caused by U/S**:

| Sorry | File | Line | Cause |
|-------|------|------|-------|
| `F_until_equiv_valid` | Soundness.lean | 770 | Unsound under mixed semantics |
| `P_since_equiv_valid` | Soundness.lean | 786 | Unsound under mixed semantics |
| forward Until in `usc` | DeterministicFMCS.lean | 483 | Depends on forward_F |
| forward Since in `usc` | DeterministicFMCS.lean | 495 | Depends on backward_P |

**Sorries NOT caused by U/S (would persist without them)**:

| Sorry | File | Line | Cause |
|-------|------|------|-------|
| `deterministic_forward_F` | DeterministicFMCS.lean | 67 | The core blocker (G/H issue) |
| `deterministic_backward_P` | DeterministicFMCS.lean | 74 | Symmetric to forward_F |

**Structural costs of U/S**:

1. **Formula type**: 2 extra constructors (untl, snce) requiring 8→8 pattern matches in EVERY function on Formula (complexity, modalDepth, temporalDepth, countImplications, atoms, swap_temporal, beq_refl, eq_of_beq, needsPositiveHypotheses)
2. **Axiom type**: 20 extra constructors (12 Until/Since axioms + 8 X/Y axioms) requiring pattern matches in EVERY function on Axiom (isBase, isDenseCompatible, isDiscreteCompatible, frameClass, Substitution)
3. **Soundness**: 20 extra validity lemmas (most are sorry in the discrete case due to the bulk sorry in lines 1182-1206)
4. **Truth lemma**: 2 extra cases requiring `until_since_coherent` hypothesis
5. **Chain construction**: Until/Since persistence lemmas (DeterministicChain.lean:~150 lines), witness seed consistency (WitnessSeed.lean:~200 lines), backward Until/Since induction (DeterministicFMCS.lean:~200 lines)
6. **Subformula closure**: `deferralClosure` definition and pigeonhole infrastructure (FiniteDeferral.lean:~150 lines)

**Estimated total U/S-specific code**: ~2000-3000 lines across the codebase.

### 2.4 What U/S Were Supposed to Help With

The user said: "I have only included U/S to HELP establish the representation theorem." The intended mechanism was:

1. `F(ψ) → ⊤ U ψ` (F_until_equiv) converts F-obligations to Until obligations
2. `until_persists_chain` tracks Until persistence through the chain
3. By pigeonhole on `deferralClosure`, a cycle must appear
4. The cycle with unresolved `⊤ U ψ` contradicts `until_induction`

This is the finite deferral argument (FiniteDeferral.lean). It is the ONLY place in the codebase where U/S provide something that G/H alone do not.

**Why it fails**: Step 1 uses the unsound axiom `F_until_equiv`. Even if that were fixed, Step 4 requires deriving `G(¬ψ)` at the cycle start from the meta-level cycling of restricted theories -- which is the same forward_F gap in disguise.

### 2.5 Does Until Induction Provide Something Essential?

**Until Induction** (Axiom `until_induction`):
```
G(ψ → χ) ∧ G(φ ∧ X(χ) → χ) → ((φ U ψ) → X(χ))
```

This axiom provides **well-founded induction along the successor chain from the current time to the Until witness**. It is used in two places:

1. **WitnessSeed.lean:449**: To prove `until_witness_seed_consistent` -- that `{ψ} ∪ g_content(M)` is consistent when `φ U ψ ∈ M`. This is used in the canonical frame construction.

2. **FiniteDeferral.lean** (conceptually): The finite deferral argument relies on Until Induction to derive a contradiction from a cycle.

**Can it be replaced?** For use (1), the consistency of `{ψ} ∪ g_content(M)` when `F(ψ) ∈ M` can be proved directly from temporal duality: if `{ψ} ∪ g_content(M)` were inconsistent, then `G(¬ψ) ∈ M`, but `F(ψ) ∈ M` and `G(¬ψ) ∈ M` contradict MCS consistency (since `F(ψ) = ¬G(¬ψ)`). This is exactly `forward_temporal_witness_seed_consistent` in WitnessSeed.lean:250 -- it does NOT use Until Induction.

For use (2), the finite deferral approach is already blocked for independent reasons.

**Verdict**: Until Induction is not providing something that cannot be achieved through G/H mechanisms for the completeness proof.

### 2.6 Cost-Benefit Analysis

| Factor | With U/S | Without U/S |
|--------|----------|-------------|
| Formula constructors | 8 | 6 |
| Axiom constructors | 35 | 15 |
| Soundness sorries | 2 unsound (F_until_equiv, P_since_equiv) + 20 bulk-sorry discrete | 0 specific to U/S |
| Truth lemma parameters | `h_tc` + `h_uc` | `h_tc` only |
| Forward_F blocker | Present | Present (unchanged) |
| Finite deferral strategy | Available but blocked | Not available |
| Pattern-match burden | Every function on Formula/Axiom needs 2/20 extra cases | Reduced |
| Total U/S-specific code | ~2000-3000 lines | 0 |

**The forward_F blocker persists regardless of U/S.** Until/Since do not help close it, and they introduce the only confirmed unsoundness in the system (F_until_equiv).

### 2.7 Path to Completeness WITHOUT U/S

For the base logic Kt + S5 + linearity over ℤ (without U/S):

1. **The forward_F problem remains**: F(ψ) ∈ chain(t) implies ∃ s > t, ψ ∈ chain(s). This is fundamentally about G/H and the deterministic chain.

2. **Approach A: Direct saturation argument**. Prove that if F(ψ) ∈ chain(t) and ψ ∉ chain(s) for all s > t, then by pigeonhole on the subformula closure restriction, a cycle appears in `{chain(n) ∩ subformulaClosure(root) | n > t}`. From the cycle, derive G(¬ψ) ∈ chain(t), contradicting F(ψ) ∈ chain(t). This is essentially the finite deferral argument without U -- the cycle contradiction comes from the pigeonhole principle + MCS properties directly, without needing Until Induction.

3. **Approach B: Quasimodel/eliminative fixpoint**. Build a non-deterministic type graph, eliminate types with unfulfillable F-obligations, extract a ℤ-realization. This avoids the circularity entirely but requires ~3000-5000 lines of new infrastructure.

4. **Approach C: Global canonical model**. Use a single canonical model with ℤ-many MCSes, where the model construction explicitly resolves all F-obligations at construction time. Similar to Approach B but formalized differently.

**Key point for Approach A**: The cycle → G(¬ψ) derivation is the SAME gap as the finite deferral step 4 with U/S. Without U/S, we need to show that if `restricted_theory(chain(i)) = restricted_theory(chain(j))` for `i < j`, then `¬ψ ∈ chain(n)` for all `n ≥ i` implies `G(¬ψ) ∈ chain(i)`. This is still the meta-to-object conversion gap. **Dropping U/S does not close the gap but does not make it harder either.**

### 2.8 Path to Completeness WITH U/S (If Kept)

If U/S are retained, the path requires:

1. **Fix F_until_equiv soundness** (MANDATORY). Options from Report 30:
   - (a) Make Until reflexive: `∃ s ≥ t, ψ(s) ∧ ∀ r ∈ (t,s), φ(r)` -- aligns with reflexive G/H
   - (b) Make G/H strict: s > t / s < t -- standard strict temporal semantics
   - (c) Drop F_until_equiv and find alternative
   - (d) Add stronger seriality axiom: `F(ψ) → X(F(ψ) ∨ ψ)` -- cheapest fix

2. **Close forward_F** using the (now sound) finite deferral argument:
   - F(ψ) → ⊤ U ψ (via fixed F_until_equiv)
   - ⊤ U ψ persists until ψ appears (via until_persists)
   - Pigeonhole on deferralClosure gives a cycle
   - Cycle + until_induction gives contradiction
   - **Gap**: Deriving the until_induction premise `G(ψ → χ)` still requires the meta-to-object conversion

3. **Close the Until/Since forward coherence** (DeterministicFMCS.lean:483, 495)

---

## Part 3: Concrete Recommendation

### Recommendation: DROP U/S (Confidence: 75%)

**Reasoning**:

1. **U/S do not resolve the forward_F blocker.** The core obstacle (meta-to-object G conversion) exists identically with or without U/S.

2. **U/S introduce the only confirmed unsoundness.** F_until_equiv and P_since_equiv are sorry in soundness with confirmed semantic gap. Every approach that converts between F and Until is built on an unsound foundation.

3. **U/S add ~2000-3000 lines of complexity** for no proven benefit. Every function on Formula requires 2 extra pattern match cases. Every function on Axiom requires 20 extra cases.

4. **The finite deferral strategy is blocked regardless.** Even with sound F_until_equiv, the cycle→G(¬ψ) step has the same meta-to-object gap.

5. **Dropping U/S simplifies the path forward.** With 6 Formula constructors and 15 axiom constructors, every proof becomes shorter. The truth lemma loses the `h_uc` parameter. The subformula closure becomes smaller.

6. **Published completeness proofs for Kt + S5 exist without U/S.** Burgess (1984), Gabbay (1981) prove completeness for tense logics over various frame classes without Until.

### If U/S Are Kept

If the user decides to keep U/S, the FIRST action must be fixing F_until_equiv soundness. Option (a) -- making Until reflexive (∃ s ≥ t instead of s > t) -- is the cleanest fix because it aligns all temporal operators on the same reflexive semantics, matching the published GHR 1994 approach. Estimated cost: 1000-2000 lines to change Truth.lean Until/Since cases, re-prove soundness lemmas, and update dependent chain infrastructure.

### Either Way

The forward_F blocker requires one of:
- Direct saturation (Approach A): meta-to-object G conversion via cycle argument
- Quasimodel (Approach B): non-deterministic type graph with eliminative fixpoint
- Global canonical model (Approach C): explicit F-resolution at construction time

None of these approaches are helped or hindered by the presence of U/S in the object language.

---

## Appendix: Codebase Evidence

### Files That Would Change If U/S Are Removed

**Formula.lean**: Remove `untl`, `snce` constructors and all functions with their cases (~100 lines saved per function, ~800 lines total across complexity, modalDepth, temporalDepth, atoms, swap_temporal, beq_refl, eq_of_beq, needsPositiveHypotheses, plus derived operators next, prev)

**Axioms.lean**: Remove 20 constructors and all pattern-match cases (~400 lines saved)

**Truth.lean**: Remove 2 cases from truth_at (~10 lines)

**Soundness.lean**: Remove F_until_equiv_valid, P_since_equiv_valid sorries and 20 bulk-sorry cases (~100 lines)

**SubformulaClosure.lean**: Remove deferralClosure (~50 lines)

**FiniteDeferral.lean**: Entire file (~150 lines)

**WitnessSeed.lean**: Remove until_witness_seed_consistent, since_witness_seed_consistent (~250 lines)

**DeterministicChain.lean**: Remove until_persists_chain, since_persists_chain, mem_x_content_iff until cases (~150 lines)

**DeterministicFMCS.lean**: Remove backward_until_chain, backward_since_chain, forward Until/Since in usc, and simplify construct_bfmcs_callback (~300 lines)

**TemporalCoherence.lean**: Remove BFMCS.until_since_coherent definition (~50 lines)

**ParametricTruthLemma.lean**: Remove h_uc parameter and untl/snce cases (~100 lines)

**Substitution.lean**: Remove 20 Until/Since/X/Y axiom substitution cases (~100 lines)

**Total estimated savings**: ~2500 lines of code, 2 unsoundness sorries resolved, 2 completeness sorries simplified (usc forward cases eliminated).

### Key Sorry Dependency Chain

```
deterministic_forward_F (LEAF SORRY)
  ↓ used by
tc (temporal coherence)
  ↓ used by
parametric_canonical_truth_lemma (backward G case)
  ↓ used by
parametric_algebraic_representation_conditional
  ↓ used by
deterministic_representation
  ↓ used by
completeness_over_Int / discrete_completeness_fc
```

This chain is identical with or without U/S. The `h_uc` parameter adds a parallel dependency through the Until/Since truth lemma cases, but it does not create new leaf sorries beyond what `forward_F` / `backward_P` already require.
