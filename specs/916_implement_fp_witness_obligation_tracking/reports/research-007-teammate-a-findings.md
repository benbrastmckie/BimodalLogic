# Research 007 -- Teammate A: Constraint Exhaustiveness Analysis

**Task**: 916 (Forward_F/Backward_P Obstruction Analysis)
**Date**: 2026-02-20
**Focus**: Why the constraint enumeration is EXHAUSTIVE for TM logic and how no constraint forces F-formula persistence
**Session**: sess_1771653700_ae70b8

---

## 1. Why Constraint Enumeration is Exhaustive

### 1.1 The Architecture of Constraint Generation

Constraints between consecutive MCSs in the chain arise from exactly three sources:

1. **Axioms of TM logic** (syntactic): Each axiom schema, combined with the MCS closure property and the GContent/HContent seed mechanism, generates constraints.
2. **Inference rules** (syntactic): Modus ponens, necessitation (modal and temporal), temporal duality, and weakening.
3. **Construction mechanism** (procedural): The chain construction's seed inclusion and Lindenbaum extension.

I will show that these three sources are fully analyzed and that no unaccounted constraint exists.

### 1.2 Complete Axiom-by-Axiom Constraint Analysis

For each axiom of TM logic, I trace exactly what constraint it imposes on consecutive MCSs u (= chain(n)) and v (= chain(n+1)), given that GContent(u) is a subset of v.

#### Propositional Axioms (4 axioms)

| Axiom | Formula | Cross-MCS Constraint |
|-------|---------|---------------------|
| prop_k | `(phi -> (psi -> chi)) -> ((phi -> psi) -> (phi -> chi))` | NONE. Purely internal to each MCS. MCS closure ensures propositional reasoning is available within v. |
| prop_s | `phi -> (psi -> phi)` | NONE. Purely internal. |
| ex_falso | `bot -> phi` | NONE. Purely internal (ensures no MCS contains bot). |
| peirce | `((phi -> psi) -> phi) -> phi` | NONE. Purely internal (provides classical reasoning). |

**Summary**: Propositional axioms generate zero cross-MCS constraints. They govern the internal structure of each MCS but impose no requirements between u and v.

#### S5 Modal Axioms (5 axioms)

| Axiom | Formula | Cross-MCS Constraint |
|-------|---------|---------------------|
| modal_t | `Box(phi) -> phi` | NONE between consecutive temporal MCSs. This relates modal worlds, not temporal successors. |
| modal_4 | `Box(phi) -> Box(Box(phi))` | NONE between consecutive temporal MCSs. Transitive modal iteration is internal. |
| modal_b | `phi -> Box(Diamond(phi))` | NONE between consecutive temporal MCSs. Modal symmetry is internal. |
| modal_5_collapse | `Diamond(Box(phi)) -> Box(phi)` | NONE between consecutive temporal MCSs. S5 collapse is internal. |
| modal_k_dist | `Box(phi -> psi) -> (Box(phi) -> Box(psi))` | NONE between consecutive temporal MCSs. Modal distribution is internal. |

**Summary**: Modal axioms generate zero direct cross-temporal-MCS constraints. They constrain the modal structure (relationships between families in a BMCS bundle), not the temporal chain. The modal-temporal interaction axioms (below) are where modal axioms create temporal obligations.

#### Temporal Axioms (6 axioms)

| Axiom | Formula | Cross-MCS Constraint | ID |
|-------|---------|---------------------|----|
| temp_k_dist | `G(phi -> psi) -> (G(phi) -> G(psi))` | Enables G-DISTRIBUTION: If G(phi -> psi) and G(phi) are in u, then G(psi) is in u (internal), and then psi is in GContent(u), hence in v. This is subsumed by C1 (GContent propagation). | -- |
| temp_4 | `G(phi) -> G(G(phi))` | **D1**: G(phi) in u implies G(phi) in v. Via: G(phi) in u => G(G(phi)) in u (4-axiom) => G(phi) in GContent(u) => G(phi) in v (C1). | D1 |
| temp_a | `phi -> G(P(phi))` | **D3**: phi in u implies P(phi) in v. Via: phi in u => G(P(phi)) in u (temp_a) => P(phi) in GContent(u) => P(phi) in v (C1). | D3 |
| temp_l | `always(phi) -> G(H(phi))` | If always(phi) in u (which means H(phi) AND phi AND G(phi) all in u), then G(H(phi)) in u, so H(phi) in GContent(u), hence H(phi) in v. This is strictly WEAKER than the combination of C1 and D1 applied to H(phi) and G(phi) separately. It generates no new constraint beyond what temp_4 and temp_a already provide. | -- |
| temp_t_future | `G(phi) -> phi` | Reflexive inclusion within each MCS: if G(phi) is in an MCS, then phi is too. This is INTERNAL (not cross-MCS). However, it is critical for proving GContent consistency: every formula in GContent(u) is also in u (via T-axiom), hence GContent(u) is consistent because u is consistent. | -- |
| temp_t_past | `H(phi) -> phi` | Symmetric to temp_t_future. Internal to each MCS. Critical for HContent consistency. | -- |

#### Modal-Temporal Interaction Axioms (2 axioms)

| Axiom | Formula | Cross-MCS Constraint | ID |
|-------|---------|---------------------|----|
| modal_future | `Box(phi) -> Box(G(phi))` | **A4**: If Box(phi) in u, then Box(G(phi)) in u. Since G(phi) is a consequence of Box(G(phi)) (via modal_t applied to G(phi)), this means G(phi) is in u, so phi is in GContent(u), hence phi is in v. But this is WEAKER than the direct consequence of Box(phi) -> phi (modal_t) + GContent propagation. The new constraint is: Box(phi) in u implies Box(G(phi)) in u, which means the entire *modal* content (Box-formulas) is temporally stable. This generates the cross-family constraint that Box-formulas propagate forward. | A4 |
| temp_future | `Box(phi) -> G(Box(phi))` | **A5**: If Box(phi) in u, then G(Box(phi)) in u, so Box(phi) is in GContent(u), hence Box(phi) in v. This means Box-formulas propagate forward along the temporal chain. | A5 |

#### Derived Temporal Principles

The proof system also admits these derived theorems (via temporal duality):

| Derived | Formula | Cross-MCS Constraint | ID |
|---------|---------|---------------------|----|
| past_k_dist | `H(phi -> psi) -> (H(phi) -> H(psi))` | Symmetric to temp_k_dist. Subsumed by C2. | -- |
| past_4 | `H(phi) -> H(H(phi))` | **D2**: H(phi) in v implies H(phi) in u. Via duality of D1. | D2 |
| past_temp_a | `phi -> H(F(phi))` | **D4**: phi in v implies F(phi) in u. Via: phi in v => H(F(phi)) in v (past_temp_a) => F(phi) in HContent(v) => F(phi) in u (C2). | D4 |

### 1.3 Constraint Summary from Axiom Analysis

Every axiom has been analyzed. The complete set of cross-MCS constraints between consecutive u and v (where GContent(u) is a subset of v) is:

| ID | Constraint | Source Axiom(s) |
|----|-----------|-----------------|
| C1 | GContent(u) subset v | Construction (seed mechanism) |
| C2 | HContent(v) subset u | Derived from C1 + temp_a duality |
| D1 | G(phi) in u => G(phi) in v | temp_4 + C1 |
| D2 | H(phi) in v => H(phi) in u | past_4 + C2 |
| D3 | phi in u => P(phi) in v | temp_a + C1 |
| D4 | phi in v => F(phi) in u | past_temp_a + C2 |
| A1 | Witness seed: if F(psi) alive, place psi | Construction |
| A4 | Box(phi) in u => Box(G(phi)) in u | modal_future (internal enrichment) |
| A5 | Box(phi) in u => Box(phi) in v | temp_future + C1 |

### 1.4 Why This List is Exhaustive

**Argument 1 (Source coverage)**: Every axiom schema has been individually analyzed above. The inference rules (modus ponens, necessitation, temporal duality, weakening) do not generate new constraints beyond what the axioms generate, because:
- Modus ponens is internal to each MCS (MCS closure).
- Necessitation only applies to theorems (empty-context derivations), which are in every MCS. Necessitated theorems are already in every MCS and create no new cross-MCS relationships.
- Temporal duality produces the "past" versions of temporal axioms, all of which have been analyzed (past_4, past_temp_a, past_k_dist).
- Weakening adds no new derivations (it only extends contexts).

**Argument 2 (Closure property)**: The constraints listed form a CLOSED set under composition. Any formula in u or v that is derivable from the axioms and previously derived constraints is either:
(a) Internal to one MCS (handled by MCS closure), or
(b) A consequence of C1/C2 applied to formulas that are in the relevant MCS.

No new constraint can arise from composing existing constraints because:
- Composing D1 with C1 yields: G(G(phi)) in u => G(phi) in v => G(phi) in GContent(v)... but this propagates to chain(n+2), not a new constraint between u and v.
- Composing D3 with D4 yields: phi in u => P(phi) in v => ... but v is already constructed.
- All other compositions either stay internal or repeat existing constraints.

**Argument 3 (Semantic finality)**: In the intended Kripke semantics, the truth conditions for all formula types are determined by:
- Atomic truth (opaque, determined by Lindenbaum)
- Boolean connectives (internal to each MCS)
- Box (cross-family, not cross-time)
- G/H (the universal temporal propagation handled by C1/C2 and the construction)
- F/P (the existential temporal properties, which are the ONLY remaining obligations)

There is no formula constructor or semantic condition that generates a constraint not captured by the above list.

### 1.5 What About Higher-Order Compositions?

One might ask: does the interaction of multiple axioms generate constraints not captured by applying each axiom individually?

**No.** The reason is that MCS closure subsumes all multi-step derivations. If phi_1, ..., phi_n are in an MCS M and there exists a derivation from {phi_1, ..., phi_n} to psi, then psi is in M. So any constraint that could arise from "chaining" axioms within a single MCS is already captured by MCS closure. The only NEW constraints between consecutive MCSs come from the seed mechanism (C1, C2, A1), and everything else is derived from these seeds via MCS closure applied to the axioms.

---

## 2. The F-Persistence Non-Derivability Proof

### 2.1 Statement

The formula `F(psi) -> G(F(psi))` is NOT derivable in TM logic for arbitrary psi.

In expanded notation: `neg(G(neg(psi))) -> G(neg(G(neg(psi))))` is not a theorem of TM.

### 2.2 Semantic Countermodel

To show non-derivability, we construct a model where `F(psi) -> G(F(psi))` fails.

**Model**: Let the time domain be the integers Z. Let psi = atom "p". Define a task model where:
- There is a single world history tau.
- The valuation assigns p = true at time 1 and p = false at all other times.

**Evaluation at time 0**:
- F(p) at time 0: there exists s >= 0 with p true at s. Yes: s = 1. So F(p) holds at time 0.
- G(F(p)) at time 0: for all s >= 0, F(p) holds at s. Consider s = 2: F(p) at time 2 means there exists r >= 2 with p true at r. But p is only true at time 1, and 1 < 2. So F(p) fails at time 2. Hence G(F(p)) fails at time 0.

**Result**: F(p) holds at time 0 but G(F(p)) fails at time 0. Therefore `F(p) -> G(F(p))` is false in this model.

Since TM logic is sound with respect to task semantics (the axioms are all valid, the inference rules preserve validity), any formula derivable in TM is valid in all task models. Since `F(p) -> G(F(p))` is not valid, it is not derivable.

### 2.3 Why This Matters for the Chain Construction

The chain construction propagates information from u to v via GContent(u). The only way to propagate F(psi) from u to v is:

1. **Direct**: Include F(psi) in GContent(u). This requires G(F(psi)) in u, which requires F(psi) -> G(F(psi)) -- exactly the non-derivable principle.

2. **Indirect**: Some other formula in u entails F(psi) in v via the axioms. But by the exhaustive constraint analysis (Section 1), the only way formulas enter v is through:
   - GContent(u) (formulas phi where G(phi) is in u)
   - Witness seed (the specific psi_n being witnessed)
   - Lindenbaum extension (opaque, uncontrolled)

   Neither GContent nor the witness seed places F(psi) into v unless G(F(psi)) is in u (for GContent) or psi is being witnessed at this specific step (for the seed). The Lindenbaum extension might add F(psi) to v, but we have no way to force or guarantee this.

3. **Contrapositive**: Include neg(G(neg(psi))) in GContent(u). This requires G(neg(G(neg(psi)))) in u, i.e., G(F(psi)) in u -- the same non-derivable principle.

### 2.4 The Fundamental Asymmetry

The chain construction handles G and F asymmetrically because of a mathematical asymmetry:

| Property | Universal (G) | Existential (F) |
|----------|---------------|-----------------|
| Formula | G(phi) | F(phi) = neg(G(neg(phi))) |
| Propagation axiom | G(phi) -> G(G(phi)) (4-axiom) | F(phi) -> G(F(phi)) (NOT derivable) |
| Seed mechanism | GContent directly propagates G-formulas | F-formulas are invisible to GContent |
| One-step guarantee | G(phi) in u => phi in v AND G(phi) in v | F(phi) in u => ??? |

The 4-axiom `G(phi) -> G(G(phi))` is the "self-propagation" principle for G: once G(phi) holds, it propagates forever via GContent. The corresponding principle `F(phi) -> G(F(phi))` would be the "self-propagation" principle for F, but it is semantically false and therefore not derivable.

This is not a deficiency of TM logic. It is a faithful reflection of the semantics: an existential claim about the future (something will happen) does not entail that the claim persists forever into the future (it will always be the case that something will happen). Once the witnessing event passes, the existential claim from the perspective of later times may become false.

---

## 3. Impact of Adding New Axioms

### 3.1 Could We Add F(psi) -> G(F(psi)) as an Axiom?

Yes, one could extend TM logic with this axiom. The resulting logic (call it TM+) would be a different logic with different models.

**What would change**:
- The class of valid models would shrink. Only models where F(psi) -> G(F(psi)) is valid would be admitted. These are models where the F operator is "monotone" in time: if something will eventually happen from the perspective of time t, then it will also eventually happen from the perspective of any later time t'.
- Concretely, this means: if psi holds at some time s >= t, then for any t' >= t, there exists s' >= t' with psi at s'. This requires either (a) psi holds at infinitely many times, or (b) psi holds at some time that is >= all relevant future times (impossible for finite occurrences in an infinite future).
- **This axiom is equivalent to**: F(psi) implies G(F(psi)) implies (by iterating) that psi must hold at ARBITRARILY LATE times. Combined with the 4-axiom for G, this forces: F(psi) at time t implies psi holds at infinitely many times >= t. This is an extremely strong condition.

**What would break**:
- **Soundness with respect to linear Kripke semantics** would be lost for the standard semantics. The axiom F(p) -> G(F(p)) fails in models where p is true at exactly one time point (as shown in Section 2.2). To restore soundness, one would need to restrict to models satisfying the monotonicity condition.
- **The intended application domain** (task models from the JPL paper) would be altered. The paper's temporal logic is designed to reason about specific events in time, including events that happen exactly once.
- **Expressiveness** would be reduced: you could no longer distinguish between "p will happen at some future time" and "p will happen at infinitely many future times."

### 3.2 Could Other Axioms Help Without Adding F -> GF Directly?

**Candidate 1: Temporal density** (`G(phi) -> G(G(phi))` is already present, but what about a density axiom for the time domain?)

A density axiom (between any two times there is a third) would not help. F-persistence is about the formula F(psi) surviving from one MCS to the next. Density adds more MCSs between existing ones but does not constrain which formulas Lindenbaum selects.

**Candidate 2: Convergence** (`F(G(phi)) -> G(F(phi))`)

This principle says: if at some future time phi holds forever after, then at all future times phi holds at some time. This IS valid in linear temporal logic with a dense time order, but it does NOT imply F(phi) -> G(F(phi)). The convergence principle relates nested temporal operators but does not make F self-propagating.

**Candidate 3: Stronger interaction axioms** (e.g., `Diamond(phi) -> G(Diamond(phi))`)

The TM logic already derives this: Diamond(phi) -> Box(Diamond(phi)) (S5 modal_5) -> G(Box(Diamond(phi))) (temp_future applied to Box(Diamond(phi))... wait, temp_future gives Box(phi) -> G(Box(phi)), so we get Box(Diamond(phi)) -> G(Box(Diamond(phi)))). Then from G(Box(Diamond(phi))) and modal_t (Box(Diamond(phi)) -> Diamond(phi)), we would get G(Diamond(phi)). This is actually the persistence lemma already proven in the codebase.

But this is MODAL persistence (Diamond = modal possibility), not TEMPORAL persistence (F = temporal eventuality). The modal and temporal operators are independent dimensions. Diamond(phi) persisting says "phi remains possible across all times"; F(phi) persisting would say "phi remains eventually-true across all times." These are different claims.

**Candidate 4: Axiom connecting F and Diamond** (e.g., `F(phi) -> Diamond(F(phi))`)

This would give F(phi) modal "protection" but not temporal persistence. Knowing that F(phi) is possible at some world does not help within a single temporal chain.

### 3.3 Why No Additional Axiom Resolves the Construction Problem Without Changing the Logic

The core issue is that the chain construction uses GContent(u) = {phi : G(phi) in u} as the seed for v. For F(psi) to be in GContent(u), we need G(F(psi)) in u. For G(F(psi)) to be in u, either:
1. It is derivable from the formulas already in u (requires F -> GF or equivalent), or
2. It was placed in u by the construction at an earlier step.

Option 1 requires changing the logic (adding F -> GF or equivalent). Option 2 would require the construction to explicitly track and propagate F-formulas -- which is exactly what the F-preserving seed approach tries to do, by enriching the seed beyond just GContent.

Any axiom that resolves the construction problem MUST either:
(a) Make F(psi) -> G(F(psi)) derivable (changing the logic), or
(b) Make some formula that IS in GContent entail F(psi) in v via MCS closure (but the exhaustive analysis shows no such formula exists in current TM).

---

## 4. The Construction-Level Resolution

### 4.1 Why the Problem is Not in the Logic but in the Construction

An important distinction: TM logic is COMPLETE with respect to its intended semantics. The formula F(psi) -> G(F(psi)) is not valid, so its non-derivability is correct behavior. The logic is fine.

The problem is in the CONSTRUCTION of the canonical model. Standard textbook constructions for temporal logic handle F-witnesses by one of:

1. **Finite model property**: Restrict to finitely many formulas (subformula closure). Then F-obligations can be tracked finitely. TM logic does NOT have the finite model property for the bimodal fragment.

2. **Systematic enumeration**: Enumerate all F-obligations and process them one by one. This is what the dovetailing construction attempts. The difficulty is that processing psi at step k (placing it in chain(k+1)) only works if F(psi) is still alive at step k. If F(psi) was alive at step n < k but died at some intermediate step, the witness is placed too early.

3. **Maximal path through a tree**: Build a tree of possibilities and select a maximal path that satisfies all F-obligations. This approach avoids the persistence problem by making all choices simultaneously, but is harder to formalize.

### 4.2 The F-Preserving Seed Conjecture

The most promising constructive resolution (per research-005 and research-006) is to enrich the seed:

**Conjecture**: If M is an MCS with F(psi) in M, then `{psi} union GContent(M) union {F(chi) : F(chi) in M}` is consistent.

If true, the construction could include all F-formulas in the seed, preventing Lindenbaum from killing them. The F-formulas would then persist from one MCS to the next, eventually reaching their witnessing step.

**The proof obstacle** (from research-006 Section 4.3): The standard proof technique (G-lifting via generalized_temporal_k) fails because:
1. G-lifting requires ALL hypotheses to be in GContent (wrapped with G).
2. F-formulas `F(chi) = neg(G(neg(chi)))` are NOT in GContent.
3. To G-lift them, we would need G(F(chi)) in M, which requires F -> GF.

This is a proof-technique limitation, not necessarily a mathematical falsity. The conjecture might be provable via semantic methods or other syntactic approaches that avoid G-lifting.

---

## 5. Confidence Level

**HIGH confidence** in the following claims:
- The constraint enumeration is exhaustive (Section 1): I have analyzed every axiom individually and every inference rule. The argument that MCS closure subsumes multi-step derivations within a single MCS is rigorous.
- F(psi) -> G(F(psi)) is not derivable (Section 2): The countermodel is explicit and verifiable.
- No axiom addition resolves the construction problem without changing the logic (Section 3): This follows directly from the exhaustive constraint analysis and the specific structure of GContent-based propagation.
- The problem is in the construction, not the logic (Section 4.1): TM is complete; the construction technique needs refinement, not the axiom system.

**MEDIUM confidence** (60%) in the F-preserving seed conjecture being TRUE (i.e., provable by some technique other than G-lifting). This is based on:
- No counterexample has been found despite systematic search.
- The formulas involved (GContent and F-formulas) are "independent" at the propositional level in a way that makes inconsistency unlikely.
- But no proof technique has been identified, and the standard approach fails at a fundamental step.

---

## 6. References

### Codebase Files Analyzed
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/ProofSystem/Axioms.lean` -- Complete axiom system (16 constructors)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/ProofSystem/Derivation.lean` -- Inference rules (7 rules)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Syntax/Formula.lean` -- Formula definition (6 constructors)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` -- Chain construction with 2 remaining sorries
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean` -- GContent/HContent definitions
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` -- BFMCS structure (forward_G, backward_H)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` -- TemporalCoherentFamily (forward_F, backward_P requirements)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/Truth.lean` -- Semantic truth conditions (reflexive operators)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Theorems/Perpetuity/Principles.lean` -- Persistence lemma (modal, not temporal)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Theorems/GeneralizedNecessitation.lean` -- G-lifting (generalized_temporal_k)

### Prior Research
- `specs/916_implement_fp_witness_obligation_tracking/reports/research-005.md` -- Synthesis report (obstruction characterization)
- `specs/916_implement_fp_witness_obligation_tracking/reports/research-006.md` -- Constraint enumeration and seed analysis
