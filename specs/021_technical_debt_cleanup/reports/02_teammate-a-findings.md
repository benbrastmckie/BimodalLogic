# Axiom Semantic Validity Analysis

**Teammate A - Semantic Validity Focus**
**Date**: 2026-03-21
**Scope**: All `axiom` declarations in `Theories/Bimodal/` added or relevant to tasks 9-20

---

## Summary

A total of **10 `axiom` declarations** were found in the Bimodal theories. Of these:
- **2 are DERIVABLE** (critical debt): `F_top_propagates` and `P_top_propagates` — provable immediately from existing theorems
- **3 are VALID-SEMANTIC** (acceptable with qualification): the deferral seed consistency axioms in `SuccExistence.lean` — semantically sound but require proof machinery not yet developed
- **2 are UNJUSTIFIED** (critical debt): `succ_chain_forward_F_axiom` and `succ_chain_backward_P_axiom` — genuine dovetailing gaps with no documented proof path
- **2 are VALID-FRAME**: `discreteImmediateSuccSeed_consistent_axiom` and `discreteImmediateSucc_covers_axiom` — established patterns documented in task 991
- **1 is VALID-SEMANTIC**: `canonicalR_irreflexive_axiom` — modal non-definability result
- **1 is VALID-SEMANTIC** (qualified debt): `discrete_Icc_finite_axiom` — documented as debt from task 979, planned for removal by task 19

The most urgent finding is that `F_top_propagates` and `P_top_propagates` (task 14) are **immediately derivable** from the existing `SetMaximalConsistent.contains_F_top` and `contains_P_top` theorems already present in the same file, making them trivial technical debt requiring only a one-line proof substitution.

---

## Axiom Inventory

### Axiom 1: `F_top_propagates`

- **File**: `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean:150`
- **Statement**: If `M` and `M'` are MCSes with `Succ M M'`, and `F_top ∈ M`, then `F_top ∈ M'`
- **Introduced by**: Task 14
- **Semantic Justification**: The claim is semantically true, but the proof is trivial by a different route: `F_top` is a theorem of the logic (proven by `F_top_theorem` at line 96 of the same file). Therefore `F_top ∈ M'` follows directly from `SetMaximalConsistent.contains_F_top` (line 118), which requires only `h_mcs' : SetMaximalConsistent M'`. The hypothesis `h_succ : Succ M M'` and `h_F_top : F_top ∈ M` are entirely unused.
- **Derivability Assessment**: Immediately provable. Proof: `exact SetMaximalConsistent.contains_F_top h_mcs'`
- **Classification**: DERIVABLE
- **Recommendation**: Replace axiom with one-line proof. All usages (only `ForwardChainElement.next` at line 158) should also be simplified by using `contains_F_top` directly.

---

### Axiom 2: `P_top_propagates`

- **File**: `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean:206`
- **Statement**: If `M` and `M'` are MCSes with `Succ M' M`, and `P_top ∈ M`, then `P_top ∈ M'`
- **Introduced by**: Task 14
- **Semantic Justification**: Same analysis as `F_top_propagates`. `P_top` is a theorem (`P_top_theorem` at line 107), so every MCS contains it via `SetMaximalConsistent.contains_P_top` (line 124). The premises `h_pred : Succ M' M` and `h_P_top : P_top ∈ M` are unused in any valid proof.
- **Derivability Assessment**: Immediately provable. Proof: `exact SetMaximalConsistent.contains_P_top h_mcs'`
- **Classification**: DERIVABLE
- **Recommendation**: Replace axiom with one-line proof. Usage at `BackwardChainElement.prev` (line 214) should similarly use `contains_P_top` directly.

---

### Axiom 3: `succ_chain_forward_F_axiom`

- **File**: `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean:417`
- **Statement**: If `F(φ) ∈ succ_chain_fam M0 n`, then there exists `m > n` with `φ ∈ succ_chain_fam M0 m`
- **Introduced by**: Task 14
- **Semantic Justification**: This is the existential F-witness coherence property for `TemporalCoherentFamily`. Semantically, this should follow from the Succ-chain construction: if `F(φ)` is in world `n`, then the deferral seed at step `n` ensures `φ ∨ F(φ)` is in world `n+1`. If `φ ∈ (n+1)`, done. If `F(φ) ∈ (n+1)`, continue inductively. The chain never terminates (the backward_chain is infinite by construction). However, this inductive argument requires showing that `F(φ)` cannot be deferred indefinitely — which requires a well-foundedness or König's lemma argument. The Succ relation only guarantees that F-obligations are either resolved or deferred at each step; it does not guarantee they are eventually resolved. This is the genuine "dovetailing gap": without an omega-level construction that interleaves which F-obligations to resolve, the linear Succ-chain construction cannot guarantee that every F-obligation is eventually satisfied.
- **Derivability Assessment**: Not provable from current definitions without a dovetailing construction. The standard approach (Henkin/Lindenbaum with priority queue for F-obligations) is documented in the literature (Goldblatt 1992) but not implemented. This is a genuine infrastructure gap.
- **Classification**: UNJUSTIFIED (no proof path currently documented in the codebase)
- **Recommendation**: Keep as axiom only if accompanied by a formal statement of what additional construction would be needed to prove it. Ideally, implement the dovetailing construction (omega-squared enumeration of F-obligations) to eliminate this axiom. This is the core technical debt of the discrete Succ-chain approach.

---

### Axiom 4: `succ_chain_backward_P_axiom`

- **File**: `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean:427`
- **Statement**: If `P(φ) ∈ succ_chain_fam M0 n`, then there exists `m < n` with `φ ∈ succ_chain_fam M0 m`
- **Introduced by**: Task 14
- **Semantic Justification**: Symmetric dual of `succ_chain_forward_F_axiom`. Same analysis applies: the backward chain provides predecessors indefinitely, but the Pred relation (backward Succ) only defers P-obligations, not resolves them. Proving resolution requires a symmetric dovetailing construction for P-obligations.
- **Derivability Assessment**: Not provable from current definitions for the same reasons as `succ_chain_forward_F_axiom`.
- **Classification**: UNJUSTIFIED (no proof path currently documented in the codebase)
- **Recommendation**: Same as `succ_chain_forward_F_axiom` — requires dovetailing construction or separate infrastructure.

---

### Axiom 5: `successor_deferral_seed_consistent_axiom`

- **File**: `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean:266`
- **Statement**: If `u` is an MCS with `F(⊤) ∈ u`, then `successor_deferral_seed u` is consistent
- **Introduced by**: Task 12
- **Semantic Justification**: The docstring provides a three-part semantic argument:
  1. Seriality guarantees `u` has strict successors (where `g_content(u)` is satisfied)
  2. Any strict successor satisfies all `g_content(u)` elements by CanonicalR definition
  3. Deferral disjunctions `φ ∨ F(φ)` are satisfiable because F-obligations are either resolved or deferred

  This argument is mathematically sound under discrete temporal semantics. The obstacle to a Lean proof is that under strict semantics, `g_content(M) ⊈ M` (the T-axiom is invalid), so the Lindenbaum argument cannot be directly formalized. The proof would require constructing a witness MCS satisfying both g_content and the deferral disjunctions simultaneously — this requires the full Lindenbaum lemma applied to a potentially infinite seed, which involves classical logic infrastructure that may not yet be in scope.
- **Derivability Assessment**: Mathematically derivable in principle (the semantic argument is complete), but the Lean formalization requires additional proof machinery. Not currently provable in the existing infrastructure.
- **Classification**: VALID-SEMANTIC (the semantic justification is complete and convincing; axiomatization is temporary)
- **Recommendation**: Keep for now. Document a clear path to proof: the seed is finitely satisfiable by any seriality witness, so finite consistency follows from the satisfiability argument. The Lean proof would use the compactness argument from MCSProperties.

---

### Axiom 6: `predecessor_deferral_seed_consistent_axiom`

- **File**: `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean:311`
- **Statement**: If `u` is an MCS with `P(⊤) ∈ u`, then `predecessor_deferral_seed u` is consistent
- **Introduced by**: Task 12
- **Semantic Justification**: Exactly symmetric to `successor_deferral_seed_consistent_axiom`, using `h_content` and past seriality. The same semantic argument applies by temporal duality.
- **Derivability Assessment**: Same status as axiom 5 — derivable in principle, requires same proof machinery.
- **Classification**: VALID-SEMANTIC
- **Recommendation**: Keep for now with same path to proof as axiom 5.

---

### Axiom 7: `predecessor_f_step_axiom`

- **File**: `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean:516`
- **Statement**: `f_content(predecessor_from_deferral_seed u) ⊆ u ∪ f_content(u)`
- **Introduced by**: Task 12
- **Semantic Justification**: This asserts the Succ F-step condition for the constructed predecessor `v` relative to `u` (i.e., `Succ v u`). The docstring claims this follows by temporal duality from the P-deferral seed construction. Specifically:
  - The seed contains `h_content(u)` (P-persistence)
  - The Lindenbaum extension `v` satisfies `h_content(u) ⊆ v`
  - By g/h duality: `g_content(v) ⊆ u` (Succ condition 1, proven at line 494)
  - For condition 2 (`f_content(v) ⊆ u ∪ f_content(u)`): this requires that F-obligations in `v` are either in `u` directly or can be further deferred. This is less obvious than the g_content case.

  The semantic argument is: if `F(φ) ∈ v`, then since `Succ v u`, the F-obligation must resolve or defer at `u`. Resolving means `φ ∈ u`. Deferring means `F(φ) ∈ u`, i.e., `φ ∈ f_content(u)`. This argument would work if we already knew `Succ v u`, but the axiom is used to establish `Succ v u`. This creates a circular dependency concern — the axiom is used to construct the very Succ relation it appeals to for justification.
- **Derivability Assessment**: The justification in the docstring is partially circular. The correct proof path would be to show directly from the seed structure that F-obligations in the Lindenbaum extension of the predecessor seed satisfy the subset condition. This requires careful analysis of what F-formulas can appear in the Lindenbaum extension given the seed structure. The seed contains `h_content(u)` (which has no F-formulas directly) and `pastDeferralDisjunctions` (which have the form `φ ∨ P(φ)`, also no F-formulas). So F-formulas in `v = predecessor_from_deferral_seed` come only from the Lindenbaum completion, not from the seed. A proper proof would show these F-obligations must correspond to F-obligations already in `u`.
- **Classification**: VALID-SEMANTIC (the semantic content is correct, but the proof requires deeper analysis of Lindenbaum completion properties)
- **Recommendation**: Keep, but document the circular concern in the docstring. The correct proof requires: show that any F-formula in the Lindenbaum extension of a P-seed must reflect an F-obligation in the original MCS.

---

### Axiom 8: `canonicalR_irreflexive_axiom`

- **File**: `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean:1212`
- **Statement**: For all MCSes `M`, `¬CanonicalR M M`
- **Introduced by**: Pre-task-9 (task 991)
- **Semantic Justification**: The docstring is thorough and mathematically rigorous. Under strict temporal semantics (`G φ` means φ at all `s > t`), `CanonicalR M M` would require `g_content(M) ⊆ M`. But `G(φ) ∈ M` means φ holds at all strict futures of M's world, which cannot include M's own world (t > t is impossible). The modal non-definability result (van Benthem 1983, Blackburn-de Rijke-Venema 2001) explains why no syntactic derivation can establish this: irreflexivity is not modally definable, so the Henkin proof technique cannot produce it directly. Referenced reports in specs/991 provide the full formal justification. A 1000+ line proof attempt is present in the file showing the irreflexivity through the naming set construction, which ultimately requires the axiom at the key step.
- **Derivability Assessment**: Not provable from TM axioms alone (modal non-definability). This is a genuine limitation of the proof system, not implementation debt.
- **Classification**: VALID-SEMANTIC (irreflexivity is semantically correct under strict semantics; unprovability is a known meta-theorem)
- **Recommendation**: Keep. The axiom is justified by modal non-definability. Consider adding a brief reference to the meta-theorem that formalizes this impossibility.

---

### Axiom 9: `discreteImmediateSuccSeed_consistent_axiom`

- **File**: `Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean:284`
- **Statement**: If `M` is an MCS, then `discreteImmediateSuccSeed M` is consistent
- **Introduced by**: Task 991 (pre-existing, predates task 9-20 scope)
- **Semantic Justification**: Documented in the file: the seed consists of `g_content(M)` plus blocking formulas `¬ψ ∨ ¬G(ψ)`. Under strict semantics, seriality guarantees successors where `g_content(M)` holds. The blocking formulas are satisfiable at a strict successor because they prevent intermediate MCSes (covering property). The argument is sound, and the file documents the obstacle to formalization: under strict semantics, `g_content(M) ⊈ M`, so the direct proof doesn't transfer.
- **Derivability Assessment**: Same status as axioms 5 and 6 — the semantic argument is complete but requires strict-semantics Lindenbaum machinery.
- **Classification**: VALID-FRAME (the seed consistency is a frame property required for the covering construction in discrete tense logic)
- **Recommendation**: Keep. This is part of the established discrete track infrastructure. Task 19 (deprecation of DiscreteTimeline) may eventually eliminate the need for this.

---

### Axiom 10: `discreteImmediateSucc_covers_axiom`

- **File**: `Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean:414`
- **Statement**: If `CanonicalR M K` and `CanonicalR K (discreteImmediateSucc M)`, then `K = M ∨ K = discreteImmediateSucc M`
- **Introduced by**: Task 991 (pre-existing)
- **Semantic Justification**: The docstring explains this via the blocking formula construction (Segerberg/Verbrugge approach). The blocking formulas `¬ψ ∨ ¬G(ψ)` are designed precisely to eliminate intermediate MCSes between M and its discrete successor. This is a fundamental result in discrete tense logic completeness proofs. The obstacle to a Lean proof is again the strict-semantics issue where `g_content(M) ⊈ M`.
- **Derivability Assessment**: Same class as axiom 9. The covering property is a deep semantic result that requires the blocking formula lemma, which is the core of the Segerberg completeness proof technique.
- **Classification**: VALID-FRAME (covering is the defining property of discrete frames)
- **Recommendation**: Keep. This is foundational to discrete completeness. If task 19 deprecates the old discrete track, this axiom would be eliminated.

---

### Axiom 11: `discrete_Icc_finite_axiom`

- **File**: `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean:316`
- **Statement**: For all `a b : DiscreteTimelineQuot`, `(Set.Icc a b).Finite`
- **Introduced by**: Task 979 (pre-existing, documented debt)
- **Semantic Justification**: This asserts that intervals in the discrete timeline quotient are finite, which is a consequence of the quotient construction being a discrete linear order. Finite intervals follow from the `SuccOrder` structure (each element has an immediate successor) combined with the fact that intervals between elements with a finite chain of successors are finite. The proof would use `IsLocallyFiniteOrder` machinery combined with the `SuccOrder` instance.
- **Derivability Assessment**: Should be provable from the `SuccOrder` and `IsSuccArchimedean` instances that are constructed later in the same file. The axiom appears to be used to *bootstrap* the `LocallyFiniteOrder` instance (line 330) that then enables the `SuccOrder` machinery — creating a potential definitional circularity. This requires careful analysis of the instance dependency graph.
- **Classification**: VALID-SEMANTIC (interval finiteness is a true property of discrete linear orders; the axiom captures a genuine semantic fact)
- **Recommendation**: Documented for removal by task 19. No action needed now.

---

## Classification Summary

| Classification | Count | Axioms |
|----------------|-------|--------|
| VALID-FRAME | 2 | `discreteImmediateSuccSeed_consistent_axiom`, `discreteImmediateSucc_covers_axiom` |
| VALID-SEMANTIC | 5 | `successor_deferral_seed_consistent_axiom`, `predecessor_deferral_seed_consistent_axiom`, `predecessor_f_step_axiom`, `canonicalR_irreflexive_axiom`, `discrete_Icc_finite_axiom` |
| DERIVABLE | 2 | `F_top_propagates`, `P_top_propagates` |
| UNJUSTIFIED | 2 | `succ_chain_forward_F_axiom`, `succ_chain_backward_P_axiom` |

---

## Key Findings

1. **Immediately eliminable debt (2 axioms)**: `F_top_propagates` and `P_top_propagates` in `SuccChainFMCS.lean` are trivially derivable because `F_top` and `P_top` are provable theorems of the logic, and every MCS contains all theorems. The axioms are unnecessary — `SetMaximalConsistent.contains_F_top h_mcs'` and `contains_P_top h_mcs'` (one line each) suffice. This is the easiest debt to eliminate in the entire codebase.

2. **Dovetailing gap (2 axioms)**: `succ_chain_forward_F_axiom` and `succ_chain_backward_P_axiom` represent the core limitation of the Succ-chain approach: a linear chain that defers F/P obligations step-by-step cannot guarantee eventual resolution without an explicit scheduling mechanism (dovetailing). These axioms are the deepest technical debt and require a separate construction (omega-squared Henkin-style completeness proof) to eliminate.

3. **Strict-semantics barrier (3 axioms)**: The three SuccExistence axioms (`successor_deferral_seed_consistent_axiom`, `predecessor_deferral_seed_consistent_axiom`, `predecessor_f_step_axiom`) are semantically sound but face a common obstacle: under strict temporal semantics, the T-axiom `G(φ) → φ` is invalid, preventing direct use of Lindenbaum completion arguments that assume g_content(M) ⊆ M. All three have complete semantic justifications but would require specialized proof machinery (compactness arguments, model theory of strict frames).

4. **Non-definability barrier (1 axiom)**: `canonicalR_irreflexive_axiom` is justified by modal non-definability — a meta-theorem from modal logic. This cannot be proven syntactically from TM axioms (by van Benthem's theorem). The axiom is as justified as it can be.

5. **Predecessor F-step circularity concern (1 axiom)**: `predecessor_f_step_axiom` has a subtle circularity in its stated justification — the docstring appeals to `Succ v u` to justify the F-step condition, but the axiom is used to *establish* `Succ v u`. The axiom is still semantically correct (the F-step condition holds for any Lindenbaum extension of a P-seed), but the proof documentation should be corrected.

6. **Task 19 scope**: `discrete_Icc_finite_axiom` and the two covering axioms in `DiscreteSuccSeed.lean` are on the deprecation path via task 19. No action needed now.

---

## Confidence Level

**High** — The analysis is based on direct reading of source code with complete access to:
- All axiom declarations and their docstrings
- The definitions of `F_top`, `P_top`, `contains_F_top`, `contains_P_top`
- The `Succ` relation definition (both conditions)
- The `TemporalCoherentFamily` interface (forward_F, backward_P obligations)
- The `discreteImmediateSuccSeed` construction and its blocking formula documentation

The finding about `F_top_propagates` and `P_top_propagates` being immediately derivable is based on the direct observation that these are theorems of the system (`F_top_theorem`, `P_top_theorem`) present in the same file, and that MCS closure under theorems is already proven. The classification of the dovetailing gap axioms as UNJUSTIFIED is based on understanding that the Succ relation only guarantees per-step deferral, not eventual resolution — a standard limitation documented in the tense logic literature.
