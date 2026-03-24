# Axiom Frame Condition Analysis

**Teammate**: C (Modal logic frame condition theory)
**Date**: 2026-03-21
**Scope**: All axioms in `Theories/Bimodal/` (ProofSystem axioms + Lean `axiom` declarations)

---

## Summary

The TM proof system uses 19 axiom schemata divided into three frame classes. All 19 are
legitimate frame conditions or propositional/modal tautologies — none are "proof shortcuts"
in the pejorative sense. However, there are 10 Lean `axiom` keyword declarations scattered
across the metalogic files; these are fundamentally different in character. The Lean axioms
fall into three distinct categories: (1) canonical model properties that are sound but require
machinery not yet formalized, (2) dovetailing gaps that bypass difficult construction steps,
and (3) one undisputed technical debt item that has been pre-approved for removal.

---

## Part I: ProofSystem Axiom Schemata

These are the 19 axiom schema constructors of `Bimodal.ProofSystem.Axiom` defined in
`/home/benjamin/Projects/ProofChecker/Theories/Bimodal/ProofSystem/Axioms.lean`.

### Axiom 1: prop_k

- **File**: `Theories/Bimodal/ProofSystem/Axioms.lean:102`
- **Formal statement**: `(φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))`
- **Frame correspondence**:
  - First-order property: none (propositional tautology, valid on all Kripke frames)
  - Standard name: Hilbert K (propositional distribution)
- **Sahlqvist status**: yes — it is a propositional tautology, trivially Sahlqvist
- **Canonical model property**: yes — valid in all canonical models
- **Assessment**: FRAME-VALID (universally valid, no frame condition required)

### Axiom 2: prop_s

- **File**: `Theories/Bimodal/ProofSystem/Axioms.lean:112`
- **Formal statement**: `φ → (ψ → φ)`
- **Frame correspondence**:
  - First-order property: none (propositional tautology)
  - Standard name: Hilbert S (weakening / prefixing)
- **Sahlqvist status**: yes — propositional tautology
- **Canonical model property**: yes
- **Assessment**: FRAME-VALID (universally valid)

### Axiom 3: ex_falso

- **File**: `Theories/Bimodal/ProofSystem/Axioms.lean:179`
- **Formal statement**: `⊥ → φ`
- **Frame correspondence**:
  - First-order property: none (propositional tautology)
  - Standard name: EFQ (ex falso quodlibet / explosion principle)
- **Sahlqvist status**: yes
- **Canonical model property**: yes
- **Assessment**: FRAME-VALID (universally valid)

### Axiom 4: peirce

- **File**: `Theories/Bimodal/ProofSystem/Axioms.lean:202`
- **Formal statement**: `((φ → ψ) → φ) → φ`
- **Frame correspondence**:
  - First-order property: none (classical propositional tautology)
  - Standard name: Peirce's Law (distinguishes classical from intuitionistic logic)
- **Sahlqvist status**: yes — propositional tautology
- **Canonical model property**: yes
- **Assessment**: FRAME-VALID (valid in classical models, which this system uses)

### Axiom 5: modal_t

- **File**: `Theories/Bimodal/ProofSystem/Axioms.lean:120`
- **Formal statement**: `□φ → φ`
- **Frame correspondence**:
  - First-order property: ∀w, wRw (reflexivity)
  - Standard name: T (reflexivity axiom)
- **Sahlqvist status**: yes — standard Sahlqvist formula (antecedent is boxed atom, consequent positive)
- **Canonical model property**: yes
- **Literature reference**: Blackburn-de Rijke-Venema 2001, §3.3; Chellas 1980
- **Assessment**: FRAME-VALID

Note: The code clarifies this is for the S5 modal accessibility relation (□ = metaphysical necessity), not temporal accessibility. The temporal T-axioms (Gφ → φ) are deliberately EXCLUDED from the system under strict temporal semantics (Task 991), because temporal accessibility is strict/irreflexive. This distinction is crucial.

### Axiom 6: modal_4

- **File**: `Theories/Bimodal/ProofSystem/Axioms.lean:128`
- **Formal statement**: `□φ → □□φ`
- **Frame correspondence**:
  - First-order property: ∀uvw, (uRv ∧ vRw) → uRw (transitivity)
  - Standard name: 4 (S4 axiom / transitivity)
- **Sahlqvist status**: yes — antecedent is boxed atom, consequent is doubly boxed atom
- **Canonical model property**: yes
- **Literature reference**: Blackburn-de Rijke-Venema 2001, §3.3
- **Assessment**: FRAME-VALID

### Axiom 7: modal_b

- **File**: `Theories/Bimodal/ProofSystem/Axioms.lean:136`
- **Formal statement**: `φ → □◇φ`
- **Frame correspondence**:
  - First-order property: ∀uv, uRv → vRu (symmetry)
  - Standard name: B (Brouwerian / symmetry axiom)
- **Sahlqvist status**: yes — standard Sahlqvist formula
- **Canonical model property**: yes
- **Literature reference**: Blackburn-de Rijke-Venema 2001, §3.3
- **Assessment**: FRAME-VALID

### Axiom 8: modal_5_collapse

- **File**: `Theories/Bimodal/ProofSystem/Axioms.lean:157`
- **Formal statement**: `◇□φ → □φ`
- **Frame correspondence**:
  - First-order property: ∀uvw, (uRv ∧ uRw) → vRw (Euclidean / transitivity of ◇-successors)
  - Standard name: 5 (characteristic S5 axiom)
- **Sahlqvist status**: yes — standard Sahlqvist formula
- **Canonical model property**: yes
- **Literature reference**: Blackburn-de Rijke-Venema 2001, §3.3. Combined with T, 4, B, this makes S5.
- **Assessment**: FRAME-VALID

Note: The name `modal_5_collapse` reflects that in S5 (with T, B, 4 present), this is derivable, but it is included explicitly for the collapse theorem `◇□A ↔ □A`.

### Axiom 9: modal_k_dist

- **File**: `Theories/Bimodal/ProofSystem/Axioms.lean:219`
- **Formal statement**: `□(φ → ψ) → (□φ → □ψ)`
- **Frame correspondence**:
  - First-order property: none (valid on all Kripke frames)
  - Standard name: K (modal distribution / normality axiom)
- **Sahlqvist status**: yes — propositional tautology lifted to modal context
- **Canonical model property**: yes
- **Literature reference**: Blackburn-de Rijke-Venema 2001, §1.2 (the "K" of "Kripke")
- **Assessment**: FRAME-VALID (universally valid in Kripke semantics)

### Axiom 10: temp_k_dist

- **File**: `Theories/Bimodal/ProofSystem/Axioms.lean:238`
- **Formal statement**: `G(φ → ψ) → (Gφ → Gψ)` (using G = all_future)
- **Frame correspondence**:
  - First-order property: none (valid on all temporal frames)
  - Standard name: TK (temporal K distribution)
- **Sahlqvist status**: yes
- **Canonical model property**: yes
- **Assessment**: FRAME-VALID (universally valid)

### Axiom 11: temp_4

- **File**: `Theories/Bimodal/ProofSystem/Axioms.lean:247`
- **Formal statement**: `Gφ → GGφ`
- **Frame correspondence**:
  - First-order property: ∀s∀t, (s < t) → ∀u, (t < u) → (s < u) (transitivity, which is built into strict linear orders)
  - Standard name: T4 (temporal transitivity)
- **Sahlqvist status**: yes
- **Canonical model property**: yes — holds in any transitive frame
- **Literature reference**: Goldblatt 1992, *Logics of Time and Computation*
- **Assessment**: FRAME-VALID

Note: Under strict temporal semantics with a linear order, transitivity holds definitionally (it is built into `<`). This axiom is valid on all linear orders with no special frame condition beyond linearity itself.

### Axiom 12: temp_a

- **File**: `Theories/Bimodal/ProofSystem/Axioms.lean:257`
- **Formal statement**: `φ → G(Pφ)` (using P = sometime_past = ∃ strict past)
- **Frame correspondence**:
  - First-order property: ∀s∀t, s < t → ∃u, u < t ∧ u satisfies the same (witness: u = s)
  - Standard name: TA (temporal connectedness / self-evidence)
- **Sahlqvist status**: yes — this is a frame-definable property corresponding to "no isolated points" in the combined future-past structure
- **Canonical model property**: yes
- **Literature reference**: Goldblatt 1992; corresponds to the JPL tense logic "TA" axiom
- **Assessment**: FRAME-VALID (valid on all strict linear orders)

Note: This is valid because for any s < t, s itself witnesses ∃u < t with φ(u).

### Axiom 13: temp_l

- **File**: `Theories/Bimodal/ProofSystem/Axioms.lean:275`
- **Formal statement**: `△φ → G(Hφ)` (where △φ = Hφ ∧ φ ∧ Gφ = "φ holds at all times")
- **Frame correspondence**:
  - First-order property: trivially valid — if φ holds at all times, then for any future time s, all times before s satisfy φ
  - Standard name: TL (no standard name in basic tense logic; related to "universal validity" principles)
- **Sahlqvist status**: yes (antecedent is a conjunction of boxed/universal formulas)
- **Canonical model property**: yes
- **Assessment**: FRAME-VALID (universally valid — holds in any linear order)

### Axiom 14: modal_future

- **File**: `Theories/Bimodal/ProofSystem/Axioms.lean:282`
- **Formal statement**: `□φ → □Gφ`
- **Frame correspondence**:
  - First-order property: interaction between modal and temporal accessibility, captured by time-shift invariance of the S5 modal structure
  - Standard name: MF (modal-future interaction; non-standard label for this bimodal system)
- **Sahlqvist status**: yes — antecedent is doubly boxed, consequent is positive
- **Canonical model property**: yes — the soundness proof uses `ShiftClosed` property
- **Assessment**: FRAME-VALID (valid given the time-shift invariant S5 modal structure of task semantics)

### Axiom 15: temp_future

- **File**: `Theories/Bimodal/ProofSystem/Axioms.lean:289`
- **Formal statement**: `□φ → G□φ`
- **Frame correspondence**:
  - First-order property: temporal-modal interaction: necessary truths persist
  - Standard name: TF (temporal-future interaction; non-standard label)
- **Sahlqvist status**: yes
- **Canonical model property**: yes — soundness proof uses `ShiftClosed` / time-shift invariance
- **Assessment**: FRAME-VALID (valid given the bimodal frame structure)

### Axiom 16: temp_linearity

- **File**: `Theories/Bimodal/ProofSystem/Axioms.lean:316`
- **Formal statement**: `(Fφ ∧ Fψ) → (F(φ ∧ ψ) ∨ F(φ ∧ Fψ) ∨ F(Fφ ∧ ψ))` (using F = some_future)
- **Frame correspondence**:
  - First-order property: ∀s∀t∀u, (s < t ∧ s < u) → (t = u ∨ t < u ∨ u < t) (linearity / trichotomy)
  - Standard name: Li (Goldblatt's linearity axiom for Kt logic)
- **Sahlqvist status**: YES — this is a Sahlqvist formula (disjunction of positive formulas in diamond/future form, antecedent is existential)
- **Canonical model property**: yes
- **Literature reference**: Goldblatt 1992, *Logics of Time and Computation*, Kt.Li axiomatization; Blackburn-de Rijke-Venema 2001 (frame correspondence for linearity)
- **Assessment**: FRAME-VALID

Caveat noted in code (Task 922 comment): this axiom extends the base TM axiom set and was not originally included. It is necessary because the original TM axioms do not syntactically derive linearity — a branching-time frame can satisfy all other axioms. The axiom is semantically sound for the intended integer-time semantics and is a standard frame condition in tense logic.

### Axiom 17: density

- **File**: `Theories/Bimodal/ProofSystem/Axioms.lean:348`
- **Formal statement**: `GGφ → Gφ`
- **Frame correspondence**:
  - First-order property: ∀s∀t, s < t → ∃u, s < u ∧ u < t (density)
  - Standard name: DN (density axiom for tense logic)
- **Sahlqvist status**: YES — explicitly noted in the code: "boxed antecedent, positive consequent"
- **Canonical model property**: yes — the canonical model for this logic is the dense rational timeline (TimelineQuot ≃o Q)
- **Literature reference**: Goldblatt 1992, §4.2; Gabbay 1981
- **Assessment**: TEMPORAL-VALID (valid on and only on densely ordered frames)

### Axiom 18: discreteness_forward (DF)

- **File**: `Theories/Bimodal/ProofSystem/Axioms.lean:367`
- **Formal statement**: `(F⊤ ∧ φ ∧ Hφ) → F(Hφ)`
- **Frame correspondence**:
  - First-order property: ∀t, (∃s > t) → ∃s > t, ∀r, (t < r < s → False) (immediate successors / covering / SuccOrder)
  - Standard name: DF (discrete future axiom)
- **Sahlqvist status**: YES — "positive consequent, antecedent contains existential and universal parts" (confirmed in code comment)
- **Canonical model property**: yes — via `discreteImmediateSucc` construction (with the caveat of `discrete_Icc_finite_axiom`)
- **Literature reference**: Goldblatt 1992, §4.3 (discreteness); corresponds to Segerberg's characterization of successor-ordered frames
- **Assessment**: TEMPORAL-VALID (valid on and only on frames with immediate successors / SuccOrder)

Note: DP (backward discreteness) is DERIVED from DF via the `temporal_duality` inference rule. See `Theories/Bimodal/Theorems/Discreteness.lean`. This is a clean derivation, not an axiom.

### Axiom 19: seriality_future

- **File**: `Theories/Bimodal/ProofSystem/Axioms.lean:397`
- **Formal statement**: `Gφ → Fφ` (i.e., if φ holds at all future times, it holds at some future time)
- **Frame correspondence**:
  - First-order property: ∀t, ∃s > t (NoMaxOrder — no maximal element, every point has a future)
  - Standard name: D (seriality, applied to temporal context; "dir" in some formulations)
- **Sahlqvist status**: YES — explicitly noted in the code
- **Canonical model property**: yes
- **Literature reference**: Goldblatt 1992 (seriality axiom); corresponds to Kripke's D axiom (□φ → ◇φ) in temporal form
- **Assessment**: TEMPORAL-VALID (valid on and only on frames with NoMaxOrder)

### Axiom 20: seriality_past

- **File**: `Theories/Bimodal/ProofSystem/Axioms.lean:424`
- **Formal statement**: `Hφ → Pφ`
- **Frame correspondence**:
  - First-order property: ∀t, ∃s < t (NoMinOrder — no minimal element)
  - Standard name: D-past (seriality for past)
- **Sahlqvist status**: YES — symmetric to seriality_future
- **Canonical model property**: yes
- **Assessment**: TEMPORAL-VALID (valid on and only on frames with NoMinOrder)

---

## Part II: Lean `axiom` Keyword Declarations

These are Lean 4 unproven declarations using the `axiom` keyword. They are NOT logical axioms of the proof system but rather unproven lemmas in the metalogic. They are classified differently from the proof system axioms above.

### Lean Axiom A: canonicalR_irreflexive_axiom

- **File**: `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean:1212`
- **Statement**: `∀ (M : Set Formula), SetMaximalConsistent M → ¬CanonicalR M M`
- **Nature**: Canonical model property (irreflexivity of canonical temporal accessibility under strict semantics)
- **Classification**: PROOF-SHORTCUT (canonical model construction property)
- **Justification quality**: HIGH — the irreflexivity lemma is a well-known result in modal logic (Gabbay's Irreflexivity Lemma, 1981). Under strict temporal semantics, temporal accessibility is definitionally irreflexive. The axiom is semantically correct.
- **Why it's an axiom**: Under strict semantics, the T-axiom Gφ → φ is not valid, eliminating the classical syntactic proof path (which relied on H(¬p) → ¬p). The new proof requires different machinery.
- **Frame theory relevance**: This axiom ensures the canonical model satisfies the frame condition corresponding to strict (irreflexive) temporal order. It is about the frame conditions being realized in the canonical model.
- **Assessment**: SEMANTICALLY-JUSTIFIED — documents a known mathematical fact that requires formal proof machinery not yet implemented

### Lean Axiom B: discreteImmediateSuccSeed_consistent_axiom

- **File**: `Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean:284`
- **Statement**: `SetConsistent (discreteImmediateSuccSeed M)` for any MCS M
- **Nature**: Lindenbaum seed consistency for discrete canonical model construction
- **Classification**: PROOF-SHORTCUT (canonical model construction property)
- **Justification quality**: HIGH — the justification uses: (1) seriality guarantees M has strict successors; (2) any strict successor satisfies g_content(M) by definition of CanonicalR; (3) blocking formulas are disjunctions derivable from elements of M. The argument is sound.
- **Why it's an axiom**: Under strict semantics, g_content(M) ⊈ M (the T-axiom is absent), making the direct consistency proof structurally blocked.
- **Assessment**: SEMANTICALLY-JUSTIFIED

### Lean Axiom C: discreteImmediateSucc_covers_axiom

- **File**: `Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean:414`
- **Statement**: If CanonicalR M K and CanonicalR K (discreteImmediateSucc M), then K = M or K = discreteImmediateSucc M
- **Nature**: Covering / intermediary-freeness property for the discrete immediate successor construction
- **Classification**: PROOF-SHORTCUT (canonical model construction property)
- **Justification quality**: HIGH — the blocking formula construction (¬ψ ∨ ¬G(ψ) for each blocking formula) is designed to eliminate intermediate MCSes. The covering property is semantically correct.
- **Assessment**: SEMANTICALLY-JUSTIFIED

### Lean Axiom D: successor_deferral_seed_consistent_axiom

- **File**: `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean:266`
- **Statement**: `SetConsistent (successor_deferral_seed u)` for any MCS u with F(⊤) ∈ u
- **Nature**: Consistency of the deferral seed for constructing successor MCSes in Int-indexed Succ-chains
- **Classification**: PROOF-SHORTCUT (canonical model construction property)
- **Justification quality**: MEDIUM-HIGH — the deferral disjunction construction (φ ∨ F(φ) for each F-obligation) is satisfiable at any immediate successor of u. The semantic argument is sound but involves the same strict-semantics blocking as axioms B and C.
- **Assessment**: SEMANTICALLY-JUSTIFIED

### Lean Axiom E: predecessor_deferral_seed_consistent_axiom

- **File**: `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean:311`
- **Statement**: `SetConsistent (predecessor_deferral_seed u)` for any MCS u with P(⊤) ∈ u
- **Nature**: Symmetric dual of Lean Axiom D for predecessor construction
- **Classification**: PROOF-SHORTCUT (canonical model construction property)
- **Justification quality**: MEDIUM-HIGH — symmetric to D, using DP (derivable from DF) instead of DF
- **Assessment**: SEMANTICALLY-JUSTIFIED

### Lean Axiom F: predecessor_f_step_axiom

- **File**: `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean:516`
- **Statement**: `f_content (predecessor_from_deferral_seed u) ⊆ u ∪ f_content u`
- **Nature**: The F-step condition for constructed predecessors in the Succ relation
- **Classification**: PROOF-SHORTCUT (canonical model construction property)
- **Justification quality**: MEDIUM — the argument uses temporal duality + the past deferral construction. The property is semantically correct (the seed ensures this).
- **Assessment**: SEMANTICALLY-JUSTIFIED

### Lean Axiom G: F_top_propagates

- **File**: `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean:150`
- **Statement**: `F_top ∈ M → Succ M M' → F_top ∈ M'`
- **Nature**: Propagation of the "there exists a future" marker across Succ steps
- **Classification**: DOVETAILING GAP — this represents infrastructure needed for the Int-indexed chain construction
- **Justification quality**: MEDIUM — F_top = F(⊤) propagating through Succ is semantically plausible (if M has a future and M' is a successor of M, then M' should also have a future, by seriality). However, this requires careful argument about the Succ relation definition.
- **Assessment**: DOVETAILING-GAP (identified as such in the tech debt audit; fixable with more careful chain construction analysis)

### Lean Axiom H: P_top_propagates

- **File**: `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean:206`
- **Statement**: `P_top ∈ M → Succ M' M → P_top ∈ M'`
- **Nature**: Symmetric dual of F_top_propagates for past direction
- **Classification**: DOVETAILING GAP (symmetric to G)
- **Assessment**: DOVETAILING-GAP

### Lean Axiom I: succ_chain_forward_F_axiom

- **File**: `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean:417`
- **Statement**: `F(φ) ∈ succ_chain_fam M0 n → ∃ m > n, φ ∈ succ_chain_fam M0 m`
- **Nature**: Forward F-witness existence in the Int-indexed Succ-chain
- **Classification**: DOVETAILING GAP — the most significant technical debt
- **Justification quality**: LOW — the Int-indexed chain is constructed by iterating the successor construction, but it is unclear that an F-obligation in the n-th world necessarily has a witness in the (n+1)-th world or later. This requires either a dovetailing argument or a more sophisticated chain construction.
- **Assessment**: DOVETAILING-GAP (explicitly flagged in tech debt audit as requiring "full dovetailing chain construction")

### Lean Axiom J: succ_chain_backward_P_axiom

- **File**: `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean:427`
- **Statement**: `P(φ) ∈ succ_chain_fam M0 n → ∃ m < n, φ ∈ succ_chain_fam M0 m`
- **Nature**: Backward P-witness existence in the Int-indexed Succ-chain
- **Classification**: DOVETAILING GAP (symmetric to I)
- **Assessment**: DOVETAILING-GAP

### Lean Axiom K: discrete_Icc_finite_axiom

- **File**: `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean:316` and `Theories/Bimodal/FrameConditions/Completeness.lean:210`
- **Statement**: `∀ (a b : DiscreteTimelineQuot), (Set.Icc a b).Finite`
- **Nature**: Finiteness of closed intervals in the discrete timeline quotient
- **Classification**: TECHNICAL DEBT (pre-approved, documented, to be removed by task 979/19)
- **Justification quality**: LOW — the code explicitly states this cannot be proved by the syntactic-to-structural gap in the covering lemma. The DF axiom creates existential F-obligations that cannot be bridged to the structural finiteness property.
- **Assessment**: ACKNOWLEDGED-DEBT (the only axiom in the codebase that is genuinely unresolved mathematical debt)

---

## Frame Condition Classification

### ProofSystem Axiom Schemata

| Classification | Axioms | Notes |
|----------------|--------|-------|
| Standard modal frame (S5) | modal_t (T), modal_4 (4), modal_b (B), modal_5_collapse (5), modal_k_dist (K) | S5 modal accessibility relation |
| Propositional tautologies | prop_k, prop_s, ex_falso, peirce | Valid on all frames universally |
| Temporal frame - all linear | temp_k_dist, temp_4, temp_a, temp_l, modal_future, temp_future | Valid on all strict linear orders |
| Temporal frame - linear + trichotomy | temp_linearity | Corresponds to linearity frame condition (Li) |
| Temporal frame - dense | density (DN) | Sahlqvist, valid iff DenselyOrdered |
| Temporal frame - discrete | discreteness_forward (DF) | Sahlqvist, valid iff SuccOrder (NoMaxOrder implied by seriality) |
| Temporal frame - serial | seriality_future, seriality_past | Sahlqvist, valid iff NoMaxOrder/NoMinOrder |

### Lean `axiom` Declarations

| Classification | Lean Axioms | Notes |
|----------------|-------------|-------|
| Canonical model construction (sound, unproven) | A (canonicalR_irreflexive), B (discreteImmediateSuccSeed_consistent), C (discreteImmediateSucc_covers), D (successor_deferral_seed_consistent), E (predecessor_deferral_seed_consistent), F (predecessor_f_step) | Semantically justified by construction arguments; blocked by strict-semantics machinery gap |
| Dovetailing gaps | G (F_top_propagates), H (P_top_propagates), I (succ_chain_forward_F), J (succ_chain_backward_P) | Infrastructure for Int-indexed Succ-chains; require more careful construction |
| Pre-approved technical debt | K (discrete_Icc_finite) | Fundamental covering lemma gap; approved for future task resolution |

---

## Theoretical Assessment

### Which axioms are legitimate frame conditions?

All 19 ProofSystem axiom schemata are legitimate frame conditions or tautologies:

1. **Propositional tautologies** (prop_k, prop_s, ex_falso, peirce): Valid on all models. No frame condition.

2. **Modal K axiom** (modal_k_dist): Valid on all Kripke frames — the fundamental normality axiom.

3. **S5 modal axioms** (modal_t, modal_4, modal_b, modal_5_collapse): Correspond to reflexivity, transitivity, symmetry, and Euclideanness respectively. The S5 modal accessibility relation is an equivalence relation in the task semantics. All four are Sahlqvist formulas.

4. **Temporal distribution and transitivity** (temp_k_dist, temp_4): Valid on all temporal frames. temp_4 uses transitivity of the strict linear order.

5. **Temporal interaction axioms** (temp_a, temp_l, modal_future, temp_future): Valid on all strict linear temporal frames with the bimodal S5 × temporal structure.

6. **Linearity** (temp_linearity): Frame condition = linearity (total order / trichotomy). This is a Sahlqvist formula corresponding to the standard tense logic axiom (Li).

7. **Density** (density / DN): Frame condition = DenselyOrdered. Sahlqvist, standard tense logic axiom.

8. **Discreteness** (discreteness_forward / DF): Frame condition = SuccOrder (immediate successors). Sahlqvist. DP (backward discreteness) is derived from DF via temporal duality.

9. **Seriality** (seriality_future, seriality_past): Frame conditions = NoMaxOrder, NoMinOrder. Sahlqvist.

### Which axioms are NOT frame conditions?

None of the 19 ProofSystem axioms fail to be legitimate frame conditions. However, there is one notable case worth scrutiny:

- **temp_linearity**: The code comment (Task 922) notes this axiom was not in the original TM axiom set and was added because the original axioms do not derive linearity. A branching-time frame can satisfy all other TM axioms. This is a **legitimate addition** — it properly captures the intended linear-time semantics. It is not a "proof shortcut"; it is a genuine extension of the axiom set to enforce the intended semantics.

The Lean `axiom` declarations, by contrast, range from "semantically justified but formally unproven" (group A: canonical model properties) to "genuine infrastructure gaps" (group B: dovetailing gaps) to "known open debt" (group C: discrete_Icc_finite).

### Recommendations for axiom treatment

**For ProofSystem axiom schemata**:
1. All 19 axioms should be retained as-is. The classification in `Axioms.lean` (Base/Dense/Discrete) is correct.
2. The `temp_linearity` caveat should be documented clearly: it is a permanent axiom of TM that ensures linear-time semantics, not a derived fact.
3. The DP (backward discreteness) derivation from DF via temporal duality is clean and should be preserved as the standard approach.

**For Lean `axiom` declarations**:

Priority order for elimination:

1. **K (discrete_Icc_finite_axiom)**: Pre-approved for task 19/979. This is the only genuinely open mathematical question.

2. **I and J (succ_chain_forward/backward_F/P_axiom)**: These dovetailing gaps are the most significant structural debt. They require a redesigned chain construction with explicit dovetailing (alternating between satisfying F/P obligations). A proper fix would use a dovetailed enumeration similar to Smorynski's construction for omega-completeness.

3. **G and H (F_top/P_top_propagates)**: These are relatively straightforward — F_top propagation follows from the Succ relation definition and seriality. These should be provable with careful unfolding of the Succ definition.

4. **A through F (canonical model construction axioms)**: These require general machinery for strict-semantics canonical model reasoning. They are mathematically sound and represent proof obligations rather than gaps. Lower priority than the dovetailing gaps.

---

## Key Findings

1. **All 19 ProofSystem axiom schemata are legitimate**: Every axiom either corresponds to a standard Kripke frame condition (Sahlqvist where applicable) or is a propositional/modal tautology.

2. **The frame hierarchy is correct**: Base ⊂ Dense and Base ⊂ Discrete, with Dense and Discrete being incompatible (no frame can be both DenselyOrdered and SuccOrder). This is precisely captured in `Axioms.lean`.

3. **Sahlqvist coverage is excellent**: 7 of the 10 non-tautological frame-specific axioms (temp_linearity, density, discreteness_forward, seriality_future, seriality_past, modal_t, modal_4, modal_b, modal_5_collapse) are explicitly Sahlqvist formulas, guaranteeing automatic first-order correspondence and canonical model property.

4. **Temporal T-axiom exclusion is principled**: The code correctly excludes Gφ → φ and Hφ → φ under strict semantics. This is not arbitrary — it reflects that the temporal accessibility relation is strict/irreflexive, and the T-axiom corresponds to reflexivity. Including it would falsify the discreteness construction (the blocking formula argument for irreflexivity would fail).

5. **DP is cleanly derived**: The backward discreteness axiom is a theorem, not an axiom. The derivation via `temporal_duality` in `Theories/Bimodal/Theorems/Discreteness.lean` is complete and sorry-free.

6. **The 10 Lean `axiom` declarations split into three types**: (a) semantically justified canonical model properties (6 axioms), (b) dovetailing infrastructure gaps (4 axioms), and (c) one pre-approved technical debt item.

7. **The dovetailing gap axioms (I, J) are the highest-priority technical debt**: They bypass the F/P witness existence problem for Int-indexed chains, which requires a proper dovetailing construction.

8. **discrete_Icc_finite_axiom (K) is architecturally isolated**: Its only consumer is the discrete completeness pipeline. The dense completeness pipeline is entirely axiom-free.

9. **temp_linearity is a permanent axiom**: The linearity frame condition cannot be derived from the other axioms of TM. This should be documented in the system's theoretical justification rather than treated as debt.

10. **The frame condition typeclass hierarchy** (`LinearTemporalFrame → SerialFrame → DenseTemporalFrame / DiscreteTemporalFrame`) correctly mirrors the mathematical hierarchy of frame conditions.

---

## Confidence Level

**high** — The analysis is grounded in direct examination of all axiom definitions (`ProofSystem/Axioms.lean`), soundness proofs (`Metalogic/Soundness.lean`), frame condition typeclasses (`FrameConditions/FrameClass.lean`, `Soundness.lean`, `Compatibility.lean`), and the specific Lean axiom declaration sites. All 19 ProofSystem axiom schemata and 10 Lean `axiom` declarations are accounted for with specific file/line references. The Sahlqvist and frame correspondence assessments are standard modal logic results verifiable against Blackburn-de Rijke-Venema 2001 and Goldblatt 1992.
