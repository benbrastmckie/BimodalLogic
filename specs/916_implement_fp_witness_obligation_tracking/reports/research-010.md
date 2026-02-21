# Research Report: Task #916 (Constraint-Based and Normal Form Approaches)

**Task**: Close forward_F and backward_P sorries in DovetailingChain.lean
**Date**: 2026-02-21
**Focus**: Evaluate two novel approaches: (1) Constraint-Based Family Construction, (2) Normal Form Reduction
**Session**: sess_1771713181_5174b1

---

## 1. Executive Summary

This report evaluates two novel approaches proposed for resolving the 2 remaining sorries (forward_F, backward_P) in `DovetailingChain.lean`. Both approaches are analyzed against the root cause established in prior research (research-008, research-009): the linear chain construction cannot guarantee F-formula persistence through Lindenbaum extensions because F-formulas are invisible to the GContent seed mechanism.

**Verdict**: The constraint-based approach (Approach 1) is the more promising of the two and connects to established techniques in the literature (mosaic methods, step-by-step constructions). The normal form approach (Approach 2) does not address the fundamental problem. A refined variant of Approach 1 -- the "Deferred Concretization" pattern -- is identified as the most viable path forward. However, all approaches require significant architectural changes to the current BFMCS construction.

---

## 2. Background: The Exact Problem

### 2.1 The Two Sorries

Lines 1753-1761 of `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean`:

```lean
-- forward_F:
forall t : Int, forall phi : Formula,
  Formula.some_future phi in (buildDovetailingChainFamily Gamma h_cons).mcs t ->
    exists s : Int, t < s /\ phi in (buildDovetailingChainFamily Gamma h_cons).mcs s

-- backward_P (symmetric):
forall t : Int, forall phi : Formula,
  Formula.some_past phi in (buildDovetailingChainFamily Gamma h_cons).mcs t ->
    exists s : Int, s < t /\ phi in (buildDovetailingChainFamily Gamma h_cons).mcs s
```

### 2.2 Root Cause Recap

The root cause (research-008) has two independent sub-problems:

**Sub-problem A (Persistence)**: F(psi) at step n must survive to step k = encodeFormula(psi). Lindenbaum extensions at intermediate steps can kill F(psi) because it is NOT in the GContent seed.

**Sub-problem B (Past-encoding)**: If encodeFormula(psi) < n, the witness step fired in the past. Even with perfect persistence, psi enters the chain at step encodeFormula(psi) + 1, which is NOT strictly future relative to n.

Research-009 identified the AliveF seed preservation approach as promising (resolves Sub-problem A at non-witness steps) but noted a residual gap at witness steps where F-obligations can be killed.

### 2.3 What Is Already Proven

The codebase has ~1800 lines of sorry-free infrastructure including:
- forward_G and backward_H (fully proven, including cross-sign propagation)
- Witness seed consistency (`forward_temporal_witness_seed_consistent`, `past_temporal_witness_seed_consistent`)
- GContent/HContent duality lemmas
- Witness placement and coverage lemmas
- F/P dichotomy and persistence lemmas
- Six derivation-theoretic structural lemmas

---

## 3. Approach 1: Constraint-Based Family Construction

### 3.1 The Proposal

Instead of building MCS families indexed by integers with a concrete linear chain, build families where:
- Members include a total ordering of their MCS members
- F(phi) and P(phi) create MCS witnesses that are CONSTRAINED to be later/earlier than the MCS where they occur
- Constraints are accumulated (like "this MCS must come after that one")
- A separate theorem establishes that for any constraints arising from unpacking a consistent sentence, there exists at least one concrete way of satisfying all constraints

### 3.2 Connection to Existing Literature

This proposal has significant connections to established techniques in temporal logic completeness proofs:

**The Mosaic Method** (Marx, Mikulas, Reynolds 2000): Decomposes models into small overlapping fragments ("mosaics") that are locally consistent, then shows that a globally consistent model can be assembled from a satisfying set of mosaics. The defect/cure mechanism in the mosaic method directly parallels the constraint accumulation idea: a mosaic has a "defect" when an F-formula is present without a witness, and curing the defect creates constraints on what can appear in adjacent mosaics.

**Step-by-Step Construction** (Gabbay, Hodkinson, Reynolds): Builds a linearly ordered set of MCSs in stages. At each stage, a new point is inserted to cure a defect. The key insight: the frame is constructed incrementally, and at each stage the construction is a linearly ordered set satisfying local coherence conditions. After all stages, the resulting structure satisfies all temporal coherence conditions globally.

**Completeness-by-Construction** (Reynolds 2003): Proves completeness for tense logics of linear time by constructing the frame in stages where each stage resolves one outstanding obligation. The frame is not fixed upfront -- it grows as obligations are resolved.

### 3.3 How It Would Interact with BFMCS

The current BFMCS structure requires `mcs : D -> Set Formula` where D = Int. A constraint-based approach would need to restructure this in one of two ways:

**Option A: Abstract Time Domain**

Define a new type `ConstraintTime` that records both a time position and accumulated constraints:

```
ConstraintTime := {
  positions : Finset Label,        -- abstract positions
  order : Label -> Label -> Prop,  -- partial order (to be refined to total)
  mcs_at : Label -> Set Formula,   -- MCS at each position
  constraints : List (Label x Label)  -- "a must come before b"
}
```

The construction would:
1. Start with a single position (the base MCS containing Gamma)
2. For each F(psi) at position p, create a new position q with constraint q > p and mcs_at(q) extending {psi} union GContent(mcs_at(p))
3. For each P(psi) at position p, create a new position r with constraint r < p and mcs_at(r) extending {psi} union HContent(mcs_at(p))
4. After all obligations are resolved, embed the result into Int

**Problem**: Step 4 is the crux. The resulting partial order must be embeddable into Int as a total order. This requires:
- The partial order is countable (yes, since Formula is countable)
- The partial order has no infinite ascending or descending chains (not guaranteed -- F-obligations can create chains of witnesses that create further obligations)
- The partial order is consistent (no cycles)

The consistency requirement is non-trivial: when we create a witness for F(psi) at position p, the new MCS at position q might contain new F-obligations that require further witnesses, creating a potentially infinite chain of constraints.

**Option B: Direct Int Construction with Deferred Concretization**

Keep D = Int but build the chain in two phases:
1. **Phase 1 (Abstract)**: Build an abstract graph of MCS positions with ordering constraints, resolving all F/P obligations
2. **Phase 2 (Concretization)**: Embed the abstract graph into Int

This is essentially Option A with an explicit embedding step.

### 3.4 The Constraint Language

The constraint language would need to express:
- `later(p, q)`: position q is strictly after position p
- `earlier(p, q)`: position q is strictly before position p
- `gcontent_extends(p, q)`: GContent(mcs_at(p)) subset mcs_at(q) (ensures forward_G)
- `hcontent_extends(p, q)`: HContent(mcs_at(p)) subset mcs_at(q) (ensures backward_H)
- `witness(p, psi, q)`: psi is in mcs_at(q) and later(p, q) (satisfies F(psi) at p)

The key constraint is that `gcontent_extends(p, q)` and `later(p, q)` together imply forward_G holds along the p-q edge. The challenge is ensuring that the GLOBAL forward_G property holds for ALL pairs (t, t') with t < t', not just adjacent pairs.

### 3.5 Lindenbaum Interaction

In the constraint-based approach, each new MCS is still created via Lindenbaum extension of a seed. The difference is that:
- The seed for a witness position q (witnessing F(psi) at p) is `{psi} union GContent(mcs_at(p))` -- this is already proven consistent
- The resulting MCS is not required to be on a pre-existing linear chain
- Different F-obligations at the same position p get DIFFERENT witness positions (each with its own Lindenbaum extension)

This is conceptually similar to the standard canonical model approach (research-008, Section 3.4) but adapted to produce an embeddable-into-Int structure rather than an arbitrary set of MCSs.

### 3.6 Feasibility Assessment

**What the approach solves**:
- Sub-problem A (Persistence): Each F-obligation gets its own fresh Lindenbaum extension, so there is no persistence issue. F-obligations are not "killed" because they are not competing for the same MCS.
- Sub-problem B (Past-encoding): Witness positions are created on-demand, not at pre-determined enumeration steps.

**What the approach requires**:
1. A theory of partially ordered sets of MCSs with ordering constraints (~20 hours)
2. Proof that the constraint system is consistent (no cycles) (~10 hours)
3. Proof that the partial order is embeddable into Int as a total order (~15 hours)
4. Proof that the embedding preserves GContent/HContent propagation (~15 hours)
5. Integration with existing BFMCS infrastructure (~10 hours)

**Obstacles**:
- **Transitivity of GContent propagation**: In the current chain, GContent propagation is proven step-by-step (GContent(M_n) subset M_{n+1}) and then extended by induction. In the constraint graph, GContent must propagate along ALL forward edges, not just immediate successors.
- **Infinite obligation chains**: F(psi) at position p creates witness q. If the MCS at q contains new F-obligations, those require new witnesses, potentially ad infinitum. The constraint graph could be infinite.
- **Int embedding**: Embedding a countably infinite partial order into Int while preserving the temporal coherence conditions is non-trivial. It requires showing that the partial order is order-isomorphic to a subset of Int (or can be completed to such).

**Critical question**: Does the constraint system terminate? If F(psi) at position p creates a witness at q, and F(chi) at q creates a witness at r, and so on, does this process eventually stabilize?

**Answer**: In the standard canonical model construction, this process generates countably many MCSs (since Formula is countable and each MCS is determined by its contents). The process does not need to "terminate" -- it generates an omega-chain of witnesses, which can be embedded into Int as a monotone function from Nat to Int. This is the standard step-by-step construction from the literature.

### 3.7 Literature Precedent

The constraint-based approach is well-established in the literature under various names:
- "Step-by-step construction" (Gabbay et al.): Build the model incrementally, resolving defects one at a time
- "Mosaic method" (Marx, Mikulas, Reynolds): Decompose into locally consistent fragments and assemble
- "Completeness by construction" (Reynolds 2003): Build frame structure as obligations are resolved

The specific formalization of this approach for reflexive tense logic with G/H/F/P over linear integer time has been proven correct in the mathematical literature (Burgess 1982, Reynolds 2003), but has not (to my knowledge) been formalized in Lean or similar theorem provers.

### 3.8 Verdict on Approach 1

**Feasibility**: Moderate to High. The mathematical machinery exists in the literature. The challenge is formalizing it in Lean 4 and integrating it with the existing BFMCS architecture.

**Effort estimate**: 60-90 hours (new construction replacing the current dovetailing chain)

**Risk**: The main risk is that the Int embedding step may be technically difficult in Lean 4, requiring careful handling of the well-ordering and transfinite construction.

**Key insight**: The constraint-based approach is essentially the standard canonical model approach (from research-008 Section 3.4) reframed to produce a structure embeddable into Int. The "constraints" are the ordering and inclusion requirements that the canonical relation imposes.

---

## 4. Approach 2: Normal Form Reduction

### 4.1 The Proposal

Start by reducing the consistent sentence to a normal form where witness-generating content (F/P formulas) is exposed:
1. First unravel the witness-generating content (F/P formulas)
2. Then work through the rest of the normal form
3. Build the model construction around this exposed structure

### 4.2 Normal Forms for Temporal Logic

There are several established normal forms for temporal logics:

**Gabbay's Separation Theorem**: Every formula of past-future temporal logic is equivalent to a Boolean combination of pure past and pure future formulas. This "separates" past and future content.

**Fisher's Separated Normal Form (SNF)**: Transforms temporal formulas into a set of clauses of the form:
- `start => alpha` (initial conditions)
- `G(alpha => X beta)` (step rules, where X is "next time")
- `G(alpha => F beta)` (sometime rules, where F is "eventually")

These sometime rules directly expose F-obligations. The SNF is used primarily for discrete temporal logics with a "next" operator, which does not directly apply to the dense/integer time setting of this codebase.

**Kamp's Theorem**: Over continuous linear orders, every temporal property expressible in first-order logic can be expressed using Since and Until. This provides a normal form in terms of S and U operators.

### 4.3 Applicability to TM Logic

The TM logic in this codebase has the following operators:
- Propositional: imp, bot (with neg = phi.imp bot)
- Modal: box (S5)
- Temporal: all_future (G), all_past (H)
- Derived: some_future (F) = neg(G(neg phi)), some_past (P) = neg(H(neg phi)), diamond = neg(box(neg phi))

**Key difference from LTL**: TM does not have a "next" operator (X). The temporal operators G and H quantify over all future/past times, not just the next time step. This means Fisher's SNF does not directly apply.

**Key difference from standard temporal logics**: TM has a MODAL dimension (Box/Diamond for S5) in addition to the temporal dimension (G/H/F/P). Normal forms for bimodal logics are less studied.

### 4.4 What a Normal Form Would Look Like for TM

A hypothetical normal form for TM formulas would need to expose:
1. The F-obligations: formulas of the form F(psi) that require future witnesses
2. The P-obligations: formulas of the form P(psi) that require past witnesses
3. The G-constraints: formulas of the form G(phi) that constrain all future times
4. The H-constraints: formulas of the form H(phi) that constrain all past times
5. The modal content: formulas involving Box/Diamond

A separated normal form might look like:
```
phi equiv  (propositional part)
         AND (G-constraints: AND_i G(alpha_i))
         AND (H-constraints: AND_j H(beta_j))
         AND (F-obligations: AND_k F(gamma_k))
         AND (P-obligations: AND_l P(delta_l))
         AND (modal part: Box(...))
```

### 4.5 Why Normal Form Does Not Address the Root Cause

The root cause of the sorry gap is NOT that F-obligations are hidden inside complex formulas. The root cause is that the linear chain construction cannot simultaneously satisfy multiple F-obligations because:
1. Each chain step extends GContent of the previous step
2. F-formulas are invisible to GContent
3. Lindenbaum extensions at each step can kill F-formulas

Reducing a formula to normal form exposes which F-obligations exist, but does NOT change the fundamental dynamics of the chain construction. The chain still faces the same challenge: for each F(psi) at time t, it must place psi at some strictly future time s > t, and the placement must be consistent with all other obligations.

**Specifically**: Even if we know upfront that the formula phi has F-obligations F(gamma_1), ..., F(gamma_k), the chain construction still needs to:
1. Build an MCS at each time point
2. Ensure GContent propagation (for forward_G)
3. Ensure each F(gamma_i) at time t has a witness s > t with gamma_i at s

Normal form knowledge does not help with step 3 because the problem is not IDENTIFYING the obligations but SATISFYING them in a linear chain.

### 4.6 Potential Indirect Benefits

While normal form reduction does not solve the root cause, it could provide indirect benefits for certain approaches:

**Benefit 1: Finite witness set**. If the formula phi has only finitely many F-sub-formulas (which is always true since phi is finite), then there are only finitely many distinct F-obligations to satisfy. This is already implicitly used in the current construction (Formula is countable, so obligations can be enumerated).

**Benefit 2: Pre-allocation of witness positions**. Knowing the F-obligations upfront allows pre-allocating witness positions in the chain. For example, if phi has F-obligations F(gamma_1), ..., F(gamma_k), the chain could reserve positions t+1, t+2, ..., t+k for the witnesses. However, this does not account for NEW F-obligations that arise from the witness MCSs themselves.

**Benefit 3: Stratification**. If the F-obligations can be ordered by complexity (e.g., by the complexity of the sub-formula), they could be resolved in order, with simpler obligations resolved first. This is related to the "defect repair" strategy in the mosaic method.

### 4.7 Interaction with the Modal (Box) Dimension

The Box operator in TM quantifies over ALL histories at the same time. In the BMCS construction, this is handled by building multiple BFMCS families and quantifying over them. The forward_F/backward_P obligations are WITHIN a single family -- they do not interact with the Box dimension.

A normal form that separates modal and temporal content could simplify the analysis, but the temporal obligations remain the same regardless of the modal structure.

### 4.8 Existing Work on Normal Forms for Bimodal Logics

Normal forms for bimodal logics are less studied than for unimodal temporal logics. The main reference is the separation principle (Hodkinson and Reynolds), which shows that formulas can be separated into past and future components. However:
- The separation procedure has non-elementary blow-up in formula size
- It applies to the temporal dimension only, not the modal dimension
- It does not directly produce a form useful for witness construction

### 4.9 Verdict on Approach 2

**Feasibility**: Low. Normal form reduction does not address the root cause of the sorry gap. It provides a way to identify F-obligations but not to satisfy them in a linear chain.

**Effort estimate**: 20-30 hours to implement normal form reduction, with no direct benefit for closing the sorries.

**Risk**: High risk of wasted effort with no payoff.

**Recommendation**: Do not pursue normal form reduction as a standalone approach. The indirect benefits (finite witness set, pre-allocation) are already implicitly available in the current construction.

---

## 5. Synthesis: The Deferred Concretization Approach

### 5.1 Combining the Best of Both Approaches

The most promising path combines the constraint-based approach (Section 3) with insights from the normal form analysis (Section 4):

**Deferred Concretization**: Build the BFMCS family in two phases:

**Phase 1 (Witness Graph Construction)**: Build a countable directed graph where:
- Nodes are MCSs (created via Lindenbaum)
- Edges encode temporal ordering constraints (GContent propagation)
- Each F-obligation at a node has a dedicated witness node
- Each P-obligation at a node has a dedicated past-witness node

This phase uses the ALREADY-PROVEN `forward_temporal_witness_seed_consistent` and `past_temporal_witness_seed_consistent` lemmas to create each witness. No persistence problem arises because each witness is a fresh Lindenbaum extension.

**Phase 2 (Int Embedding)**: Embed the witness graph into Int:
- Show the graph is a countable partial order with no cycles
- Embed into Int using a standard order-embedding theorem
- Prove that the embedding preserves GContent/HContent propagation

### 5.2 Phase 1 in Detail

Start with the consistent context Gamma. Build:

```
Step 0: M_0 = Lindenbaum(Gamma)  [base MCS]

Step 1: For each F(psi) in M_0:
  Create W_psi = Lindenbaum({psi} union GContent(M_0))
  Add edge M_0 -> W_psi  [constraint: W_psi is after M_0]

Step 2: For each P(psi) in M_0:
  Create V_psi = Lindenbaum({psi} union HContent(M_0))
  Add edge V_psi -> M_0  [constraint: V_psi is before M_0]

Step 3: Repeat for all new nodes created in steps 1-2.
```

The key properties of each witness creation:
- W_psi extends {psi} union GContent(M_0), so psi in W_psi (witness satisfied)
- GContent(M_0) subset W_psi, so forward_G holds along the M_0 -> W_psi edge
- By GContent/HContent duality (already proven), HContent(W_psi) subset M_0

### 5.3 Phase 2 in Detail

The witness graph is a countable partial order (since Formula is countable, there are countably many F/P obligations, and the graph grows by at most one node per obligation).

**Embedding into Int**: Use the standard result that any countable linear order can be embedded into the rationals (and hence into Int for discrete time). The specific embedding strategy:

1. Topologically sort the witness graph (it is a DAG since the ordering constraints are acyclic)
2. Assign integer positions by traversal order
3. Prove that the assignment preserves the ordering constraints

**The challenge**: Ensuring that GContent propagation holds not just along immediate edges but for all pairs (t, t') with t < t'. In the linear chain, this follows by induction on the chain length. In the witness graph, it requires showing that GContent is transitive through paths.

**GContent transitivity**: If GContent(A) subset B and GContent(B) subset C, does GContent(A) subset C? Not directly -- we need G(phi) in A implies G(phi) in B, which means G(phi) in GContent(A) (i.e., G(G(phi)) in A). By the 4-axiom (G(phi) -> G(G(phi))), this is guaranteed if G(phi) in A. So yes, GContent propagation is transitive through the witness graph, using the 4-axiom.

This matches the existing proof structure in DovetailingChain.lean (see `dovetailForwardChain_G_propagates`, which uses exactly this argument).

### 5.4 Comparison with Existing Construction

| Property | Current (Dovetailing Chain) | Deferred Concretization |
|----------|---------------------------|------------------------|
| Index set | Int (fixed upfront) | Witness graph, then Int |
| F-witness mechanism | One-shot enumeration at encode step | On-demand fresh Lindenbaum |
| F-persistence | Not guaranteed (root cause) | Not needed (each witness is fresh) |
| GContent propagation | Step-by-step induction | Transitive via 4-axiom |
| forward_G proof | Proven (sorry-free) | Would need re-proving |
| backward_H proof | Proven (sorry-free) | Would need re-proving |
| forward_F proof | SORRY | Direct from construction |
| backward_P proof | SORRY | Direct from construction |

**Key trade-off**: The deferred concretization approach would eliminate the forward_F/backward_P sorries but requires re-proving forward_G and backward_H in the new framework. The re-proofs should be straightforward (following the same argument as the current code) but represent significant effort.

### 5.5 Formalization Challenges in Lean 4

1. **Defining the witness graph**: Need an inductive/coinductive type for the graph, or a well-founded recursion on obligations.

2. **Termination of the construction**: The obligation processing in Phase 1 is not obviously well-founded. Each witness can create new obligations. Need to show that:
   - The graph is countable (follows from countability of Formula)
   - The construction can be indexed by Nat (via an enumeration of all obligation-position pairs)

3. **Int embedding**: Lean's `Finset` and `Fintype` infrastructure might not suffice for countably infinite graphs. May need to work with `Set` or `Stream` types.

4. **Preserving existing infrastructure**: The current TruthLemma, BMCSTruth, and Completeness modules assume BFMCS with specific properties. The new construction must produce a BFMCS that satisfies all these properties.

---

## 6. Recommendations

### 6.1 Primary Recommendation: Deferred Concretization (Approach 1 Variant)

The constraint-based approach, in its "deferred concretization" variant, is the most mathematically sound path to closing the forward_F/backward_P sorries. It:
- Directly addresses both sub-problems (persistence and past-encoding)
- Has strong literature precedent
- Reuses existing proven infrastructure (witness seed consistency)
- Produces a standard BFMCS at the end

**Estimated effort**: 60-90 hours (new module, not modifying DovetailingChain.lean)
**Risk**: Medium (well-understood mathematics, non-trivial formalization)

### 6.2 Secondary Recommendation: AliveF Seed Approach (from Research-009)

As a lower-risk alternative, the AliveF seed approach from research-009 Section 6.3 remains viable for resolving Sub-problem A. Combined with fair scheduling, it addresses Sub-problem B as well. The residual gap (F-obligation killing at witness steps) may be solvable with careful analysis.

**Estimated effort**: 30-50 hours (modifying DovetailingChain.lean)
**Risk**: Medium-High (residual gap at witness steps may not close)

### 6.3 Do Not Pursue: Normal Form Reduction (Approach 2)

Normal form reduction does not address the root cause and would not lead to closing the sorries. It provides no benefit beyond what is already implicit in the current construction.

### 6.4 Documentation of Sorry Debt

Regardless of which approach is pursued, the 2 sorries represent technical debt that blocks transitive sorry-freedom of the completeness theorem. They are:
- Localized to 2 specific lemmas in DovetailingChain.lean (lines 1753-1761)
- Mathematically sound (the properties hold in the intended semantics)
- Tolerated during development but block publication
- Inherited by `temporal_coherent_family_exists_theorem` and transitively by the completeness proof chain

---

## 7. Answers to Specific Research Questions

### 7.1 Constraint-Based Approach Questions

**Q1: How would this interact with the existing BFMCS structure?**
The constraint-based approach would produce a standard BFMCS (function `Int -> Set Formula`) as its final output. The construction would replace `buildDovetailingChainFamily` with a two-phase construction: first build a witness graph, then embed it into Int. The BFMCS structure itself does not change.

**Q2: What constraint language would be needed?**
Ordering constraints (`later`, `earlier`) and inclusion constraints (`gcontent_extends`, `hcontent_extends`). See Section 3.4 for details.

**Q3: How would Lindenbaum extension interact with constraint accumulation?**
Each witness position gets a fresh Lindenbaum extension with a proven-consistent seed ({psi} union GContent(M) or {psi} union HContent(M)). Constraint accumulation determines the ordering between positions but does not affect individual Lindenbaum extensions.

**Q4: Is there precedent in the literature for constraint-based canonical model constructions?**
Yes, substantial precedent: mosaic methods (Marx, Mikulas, Reynolds 2000), step-by-step constructions (Gabbay et al.), and completeness-by-construction (Reynolds 2003). See Section 3.7.

### 7.2 Normal Form Approach Questions

**Q1: What would such a normal form look like for this temporal logic?**
A separation into propositional, G-constraint, H-constraint, F-obligation, P-obligation, and modal components. See Section 4.4.

**Q2: Does the TM logic have useful normal forms that expose F/P content?**
TM does not have a "next" operator, so Fisher's SNF does not directly apply. Gabbay's separation theorem applies but has non-elementary blow-up and does not help with the witness construction problem.

**Q3: How would normal form interact with the modal (Box) dimension?**
The Box dimension is orthogonal to the temporal F/P witness problem. Box is handled by the BMCS bundle structure (multiple BFMCS families), not by the temporal chain within a single family.

**Q4: Is there existing work on normal forms for bimodal logics?**
Limited. The separation principle (Hodkinson and Reynolds) addresses temporal separation but not modal-temporal interaction. Normal forms for product logics exist but are complex and not directly applicable.

---

## 8. Key Findings

### 8.1 The Constraint-Based Approach Is Viable and Literature-Supported

The constraint-based approach (Approach 1) connects to well-established techniques (mosaic methods, step-by-step constructions) and directly addresses both root causes of the sorry gap. The deferred concretization variant is the most promising formalization strategy.

### 8.2 Normal Form Reduction Is Not Useful for This Problem

The normal form approach (Approach 2) does not address the root cause. The problem is not identifying F-obligations but satisfying them within a linear chain. Normal form knowledge provides no leverage for the witness construction.

### 8.3 All Viable Approaches Require Significant Architectural Changes

Both the deferred concretization approach (60-90 hours) and the AliveF seed approach (30-50 hours) require substantial new code. The sorries cannot be closed by small modifications to the existing DovetailingChain.lean.

### 8.4 The Mathematical Core Is Well-Understood

The mathematical argument for completeness of reflexive tense logic over linear integer time is well-established (Burgess, Venema, Reynolds). The challenge is purely formalization: fitting the proof into Lean 4 within the existing BFMCS architecture.

---

## 9. References

### Project Files
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` -- Chain construction (2 sorries at lines 1753-1761)
- `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` -- BFMCS structure definition
- `Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean` -- GContent/HContent definitions
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- TM axiom system (16 axioms)
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` -- TemporalCoherentFamily

### Prior Research
- `specs/916_.../reports/research-008.md` -- Root cause analysis (Sub-problems A and B)
- `specs/916_.../reports/research-009.md` -- AliveF seed approach, canonical model feasibility

### External References
- Marx, M., Mikulas, S., Reynolds, M. (2000). "The Mosaic Method for Temporal Logics." TABLEAUX 2000. [SpringerLink](https://link.springer.com/chapter/10.1007/10722086_26)
- Reynolds, M. (2003). "Completeness by construction for tense logics of linear time." [ResearchGate](https://www.researchgate.net/publication/252750536_Completeness_by_construction_for_tense_logics_of_linear_time)
- Fisher, M. (1997). "A Normal Form for Temporal Logics and its Applications in Theorem-Proving and Execution." [Oxford Academic](https://academic.oup.com/logcom/article-abstract/7/4/429/1080874)
- Hodkinson, I. and Reynolds, M. "Separation -- past, present, and future." [PDF](https://www.doc.ic.ac.uk/~imh/papers/sep.pdf)
- Burgess, J.P. (1982). "Axioms for tense logic." *Notre Dame Journal of Formal Logic*.
- Goldblatt, R. (1992). *Logics of Time and Computation*. CSLI Publications.
- Venema, Y. "Temporal Logic." Chapter 10 in *Handbook of Modal Logic*. [PDF](https://staff.science.uva.nl/y.venema/papers/TempLog.pdf)
- Sickert, S. et al. (2024). "Efficient Normalization of Linear Temporal Logic." [ACM](https://dl.acm.org/doi/10.1145/3651152)

### Key Lemma Locations in Codebase
- `forward_temporal_witness_seed_consistent` -- DovetailingChain.lean line 398 (proven, sorry-free)
- `past_temporal_witness_seed_consistent` -- DovetailingChain.lean line 303 (proven, sorry-free)
- `GContent_subset_implies_HContent_reverse` -- DovetailingChain.lean line 692 (proven, sorry-free)
- `HContent_subset_implies_GContent_reverse` -- DovetailingChain.lean line 722 (proven, sorry-free)
- `set_lindenbaum` -- MaximalConsistent.lean (proven, Zorn's lemma)
