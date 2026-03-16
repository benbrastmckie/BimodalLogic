# Research Report: Task #922 - Mosaic Method Evaluation and Cross-Pollination Analysis

**Task**: Strategy study for forward_F/backward_P completeness blockers
**Date**: 2026-02-24
**Focus**: Evaluate the mosaic method from research-010 against the findings in research-001, investigate hybrid approaches
**Session**: sess_1771956719_88860c

---

## Summary

This report evaluates whether the mosaic method (explored in Task 916 research-010) or other alternative methods could be improved to overcome the "linear chain topology constraint" identified in research-001. The analysis finds that the mosaic method and the Canonical Quotient share the same mathematical core -- both give each F-obligation its own fresh Lindenbaum witness -- but differ in formalization strategy. The Canonical Quotient remains the superior approach because it leverages an existing Mathlib theorem (`Order.embedding_from_countable_to_dense`) for the hardest step and has a simpler proof structure. A mosaic-quotient hybrid offers no advantages over the pure Canonical Quotient. Other methods from research-010 (normal form reduction, AliveF seed) are confirmed as either irrelevant or strictly inferior.

---

## 1. Recap of Key Findings from Prior Research

### 1.1 The Fundamental Obstruction (Research-001)

Research-001 identified the **linear chain topology constraint** as the root cause of all 12 failed plan revisions:

> Every failed approach builds a chain `chain : Nat -> Set Formula` where `chain(n+1) = Lindenbaum(seed(chain(n)))`, then tries to prove forward_F. The linear topology forces all F-obligations to share a single future sequence, creating inter-obligation interference.

The obstruction has three corollaries:
1. **Sequential dependency**: Each chain position depends on the previous one
2. **Shared seed space**: GContent propagation "contaminates" seeds with choices from other obligations
3. **Fixed topology**: The time domain (Int) is fixed before witnesses are assigned

### 1.2 The Mosaic / Deferred Concretization Method (Research-010)

Research-010 proposed the "Deferred Concretization" approach (Section 5), drawing on three literature sources:
- **Mosaic Method** (Marx, Mikulas, Reynolds 2000): Decompose models into locally consistent fragments, then assemble globally
- **Step-by-Step Construction** (Gabbay, Hodkinson, Reynolds): Build a linearly ordered set of MCSes incrementally, inserting new points to cure defects
- **Completeness-by-Construction** (Reynolds 2003): Grow the frame as obligations are resolved

The approach builds a witness graph (Phase 1) and then embeds it into Int (Phase 2).

### 1.3 The Canonical Quotient (Research-001, Approach A)

Research-001 recommended the **Canonical Quotient**: build the canonical model (worlds = all MCSes, relation = GContent inclusion), prove forward_F trivially, then quotient/embed into Int. Estimated effort: 20-34 hours with 75-85% confidence.

---

## 2. Structural Comparison: Mosaic vs. Canonical Quotient

### 2.1 Both Approaches Share the Same Core Insight

The fundamental insight is identical in both approaches: **give each F-obligation its own fresh Lindenbaum witness**. This is what the WitnessGraph.lean infrastructure already does (3113 lines, with `witnessGraph_forward_F_local` proven sorry-free). Both approaches:

1. Use `forward_temporal_witness_seed_consistent` to prove `{psi} union GContent(M)` is consistent
2. Apply `set_lindenbaum` to get a fresh MCS containing `psi` and `GContent(M)`
3. Obtain a local witness that does not interfere with other obligations
4. Must then somehow linearize the resulting structure into `Int`

### 2.2 Where They Diverge: Linearization Strategy

| Aspect | Mosaic Method | Canonical Quotient |
|--------|---------------|-------------------|
| **Phase 1 output** | Witness graph (explicit DAG) | Canonical frame (abstract relation) |
| **Linearization** | Topological sort of DAG, embed into Int | Prove linearity from axioms, embed into Int |
| **Linearity proof** | Show DAG is acyclic + embed partial order | Show GContent-relation is linear (from temp_a) |
| **GContent transitivity** | Must prove along paths in DAG | Follows from 4-axiom (already proven) |
| **Infrastructure reuse** | WitnessGraph.lean (3113 lines) | forward_temporal_witness_seed_consistent + set_lindenbaum |
| **New infrastructure** | Partial order embedding into Int | Linear order embedding + linearity proof |

### 2.3 The Critical Divergence: What Must Be Proven About Order

**Mosaic / Witness Graph approach** must prove:
1. The witness graph is a DAG (no cycles in the constraint ordering)
2. The DAG can be completed to a total order
3. The total order can be embedded into Int preserving GContent propagation
4. **GContent propagation is transitive along paths** (not just along immediate edges)

**Canonical Quotient approach** must prove:
1. The GContent-inclusion relation on the reachable canonical fragment is **linear** (total)
2. The reachable fragment is countable
3. Any countable linear order embeds into a densely ordered set (Mathlib: `Order.embedding_from_countable_to_dense`)
4. **GContent propagation is transitive** (same as mosaic, but follows from existing `GContent_path_propagates`)

### 2.4 Key Difference: Linearity vs. Partial Order Completion

The mosaic method produces a **partial order** that must be completed to a total order. This is non-trivial because:
- The witness graph has forward edges (node i -> witness node j for F-obligations) and backward edges (witness node k -> node i for P-obligations)
- A partial order embedding into Int requires showing the partial order is countable and has no infinite antichains that block linearization
- **Lean 4 does not have a readily available theorem** for embedding arbitrary countable partial orders into Int

The canonical quotient produces a structure that is **already linearly ordered** (if the linearity proof from temp_a succeeds). This is a strictly simpler algebraic situation because:
- Mathlib provides `Order.embedding_from_countable_to_dense`: any countable linear order embeds into any dense linear order (like Rat)
- Rat embeds into Int (via floor/ceiling with appropriate spacing)
- No partial-order-to-total-order completion is needed

---

## 3. Detailed Analysis: Can the Mosaic Method Avoid the Linear Chain Topology Constraint?

### 3.1 Does the Mosaic Method Avoid the Obstruction?

**Yes.** The mosaic method avoids the linear chain topology constraint because:

1. **No sequential dependency**: Each witness node is constructed from the source node directly, not from an intermediate chain position
2. **No shared seed space**: Each F-obligation gets its own Lindenbaum seed `{psi} union GContent(M)`, uncontaminated by other obligations
3. **Topology is determined by construction**: The DAG topology emerges from the witness creation process, not imposed a priori

This is exactly the same analysis as for the canonical quotient. The mosaic method does escape the obstruction.

### 3.2 But the Mosaic Linearization Step Re-introduces Problems

Research-001 identified that WitnessGraph.lean's Phase 5 failure was specifically at the **linearization step**: embedding the witness graph into a linear chain. Research-010 (Section 3.6) noted the same concern:

> "The challenge is ensuring that GContent propagation holds not just along immediate edges but for all pairs (t, t') with t < t'."

The existing WitnessGraph.lean implementation (Phase 5 in v011) attempted to embed the graph by building a new linear chain -- which reverted to the same topology that was the root cause of failure.

The mosaic method needs a different linearization strategy. Two options exist:

**Option A: Prove the witness graph is linearizable directly.** Show that the edge relation defines a partial order, then use a partial-order-to-linear-order completion theorem. This requires:
- Acyclicity proof (non-trivial: F-witness at node j might have a P-obligation creating a backward witness at node i, potentially creating cycles through long chains)
- Partial order completion (no ready-made Mathlib theorem)
- Preservation of GContent propagation through the completion

**Option B: Show the witness graph inherits linearity from the axiom system.** Use temp_a to prove that any two MCSes in the graph are comparable. This is essentially the canonical quotient linearity argument applied to the witness graph.

**Option B makes the mosaic method collapse into the canonical quotient.** If the linearity argument works for the witness graph, it works for the full canonical frame. And if it works for the full canonical frame, the witness graph is unnecessary -- we can use the canonical frame directly.

### 3.3 Verdict on Mosaic Method

The mosaic method is **mathematically correct** but **formalization-redundant**: it solves the same problem as the canonical quotient with more moving parts. The witness graph is an intermediate structure that provides no advantage over the canonical frame, because:

1. The canonical frame already gives each F-obligation its own witness (same as the witness graph)
2. The canonical frame's linearity (if proven from temp_a) eliminates the need for DAG linearization
3. The canonical frame leverages `Order.embedding_from_countable_to_dense` directly

The mosaic method would be preferred only if the linearity proof from temp_a fails -- in that case, having an explicit DAG with a partial order structure might provide more flexibility. But research-001 assessed the linearity proof at 85% confidence.

---

## 4. Cross-Pollination: Insights from Each Approach

### 4.1 What the Canonical Quotient Gains from Mosaic Analysis

1. **WitnessGraph.lean validates the mathematical approach**: The 3113 lines of witness graph infrastructure prove that the "fresh witness per obligation" strategy is implementable in Lean 4. `witnessGraph_forward_F_local` is a sorry-free proof that local forward_F holds. This is strong evidence that `canonical_forward_F` (the Approach A version) will also go through easily.

2. **GContent transitivity is already proven**: `GContent_path_propagates` in DovetailingChain.lean proves that GContent propagates along chains of MCSes. This lemma is directly reusable in the canonical frame setting.

3. **The linearization is the hard part**: The witness graph's Phase 5 failure confirms that the linearization (embedding into Int) is where effort should be focused. The canonical quotient's linearity argument is the critical path.

### 4.2 What Mosaic Analysis Gains from the Canonical Quotient

1. **Temp_a is the key to linearity**: The canonical quotient identifies `temp_a` (`phi -> G(P(phi))`) as the axiom that forces linearity. If linearity fails, it is because the temp_a argument does not work as expected -- and this would also affect mosaic linearization.

2. **The interface is the constraint, not the construction**: Research-001's reframing ("construct any BFMCS Int satisfying the TemporalCoherentFamily interface") applies equally to mosaics. The mosaic method's output must eventually be an `BFMCS Int`, which requires the same embedding step.

### 4.3 What a Mosaic-Quotient Hybrid Would Look Like

A hybrid approach would:
1. Build the witness graph (Phase 1, using existing WitnessGraph.lean)
2. Prove linearity of the witness graph nodes using temp_a (from canonical quotient)
3. Embed the linearly ordered nodes into Int using `Order.embedding_from_countable_to_dense`

This is strictly more complex than the pure canonical quotient because it requires:
- All of WitnessGraph.lean's infrastructure
- The same linearity proof from temp_a
- The same embedding theorem
- Plus: connecting the witness graph structure to the canonical frame's linearity

**Verdict: The hybrid offers no advantage.** It combines the complexity of both approaches without eliminating any steps from either.

---

## 5. Re-evaluation of Other Methods from Research-010

### 5.1 Normal Form Reduction (Research-010, Approach 2)

Research-010 concluded (Section 4.9): "Normal form reduction does not address the root cause. The problem is not identifying F-obligations but satisfying them in a linear chain."

Research-001 reinforces this: the obstruction is the linear chain topology, not the formula structure. Normal form knowledge provides no leverage for either the canonical quotient or the mosaic method.

**Verdict: Confirmed irrelevant.** No re-evaluation needed.

### 5.2 AliveF Seed Preservation (Research-010, Section 6.2)

Research-010 recommended AliveF as a "lower-risk alternative" (30-50 hours, medium-high risk). Research-001 classifies all seed-modification approaches as variants of the "linear chain + modified seed" pattern (Taxonomy #7), with the same fundamental limitation.

**Key insight from research-001**: AliveF preserves F-formulas at non-witness steps but cannot prevent F-formula killing at witness steps. The witness step is where Lindenbaum makes its critical choice, and no seed modification can control that choice.

**Verdict: Strictly inferior to Canonical Quotient.** Higher risk, higher effort, lower confidence (40-50% vs 75-85%).

### 5.3 Deferred Concretization (Research-010, Section 5)

This is the mosaic/witness graph approach analyzed in detail in Sections 2-4 above. Research-010 estimated 60-90 hours with medium risk.

**Updated assessment**: Given the analysis above, Deferred Concretization:
- Solves the same problem as Canonical Quotient
- Requires the same hard step (linearization/linearity proof)
- Uses more infrastructure (WitnessGraph.lean + new embedding code)
- Has the same confidence level as Canonical Quotient once linearization is resolved

**Verdict: Dominated by Canonical Quotient** (same mathematical content, more formalization overhead).

---

## 6. The Linearity Argument: Detailed Assessment

Since both mosaic and canonical quotient approaches depend on the linearity argument, a detailed assessment is warranted.

### 6.1 What Must Be Proven

**Claim**: For any two MCSes M, M' in the reachable canonical fragment (both accessible from the root via GContent-inclusion chains), either `GContent(M) subset M'` or `GContent(M') subset M`.

### 6.2 The Argument from temp_a

The temp_a axiom states: `phi -> G(P(phi))`.

In MCS terms: if `phi in M`, then `G(P(phi)) in M`. By the T-axiom for G (`G(x) -> x`), `P(phi) in M`. And for any M' with `GContent(M) subset M'`, we get `P(phi) in M'` (since `G(P(phi)) in M` means `P(phi) in GContent(M) subset M'`).

Wait -- this gives `P(phi)` at future MCSes, not linearity. The linearity argument needs more structure.

### 6.3 Corrected Linearity Argument

The standard linearity argument for temporal logics with G, H, F, P over linear time uses these axioms:
- `temp_a`: `phi -> G(P(phi))` (connectedness: present is in the past of all futures)
- Contrapositive: `neg(G(P(phi))) -> neg(phi)`, i.e., `F(H(neg(phi))) -> neg(phi)`

For linearity of the canonical relation, we need: given MCSes M1, M2 both in the reachable fragment, either M1 R M2 or M2 R M1 (where R is the GContent-inclusion relation).

The standard argument:
1. Suppose M1 and M2 are both reachable from root M0 (via R-chains).
2. By temp_a in M1: for any phi in M1, `G(P(phi)) in M1`.
3. This means for any M3 with M1 R M3: `P(phi) in M3`, i.e., there exists M4 with M4 R_past M3 and `phi in M4`.

This does not directly give linearity. The linearity of R actually follows from a different argument.

### 6.4 Standard Linearity Argument (Venema/Goldblatt)

The canonical model for a tense logic over a linear order has the following property:

**R is a linear order on the reachable fragment** if and only if the logic proves:
- `F(phi) and F(psi) -> F(phi and psi) or F(phi and F(psi)) or F(psi and F(phi))`

This is the "future-linearity" axiom schema. Is it derivable from the TM axioms?

Actually, the standard approach is simpler. The canonical relation R is defined as: `M R M'` iff `GContent(M) subset M'`. To show linearity, we need: for any M1, M2 with both `M R M1` and `M R M2` (from common predecessor M), either `M1 R M2` or `M2 R M1`.

This follows from the **dichotomy principle**: for any formula phi and any two R-successors M1, M2 of M:
- Either `phi in M1` or `neg(phi) in M1` (by MCS)
- If `phi in M1` and `neg(phi) in M2`, then by temp_a applied in M1: `G(P(phi)) in M1`, so for all R-successors M3 of M1, `P(phi) in M3` -- meaning phi was true at some past point relative to M3.

This still does not directly give linearity. The actual linearity result requires additional axioms or a more sophisticated argument.

### 6.5 Risk Assessment for the Linearity Step

Research-001 assessed the linearity proof at 85% confidence. Upon closer examination, the argument is more subtle than the sketch in research-001 suggests. The temp_a axiom gives connectedness (`phi -> G(P(phi))`), but deriving **linearity** of the canonical R from this requires either:

1. A direct proof using temp_a + other TM axioms (e.g., temp_l, the 4-axiom for G and H)
2. A proof that the canonical frame for TM restricted to the reachable fragment is linear, using the full axiom set

The standard references (Goldblatt, Venema) prove this for the basic tense logic Kt.Li (tense logic of linear orders), which includes:
- K-axioms for G and H
- 4-axiom: `G(phi) -> G(G(phi))`
- T-axioms: `G(phi) -> phi` and `H(phi) -> phi`
- Connectedness: `phi -> G(P(phi))` and `phi -> H(F(phi))`
- **Linearity axiom**: `F(phi) and F(psi) -> F(phi and psi) or F(phi and F(psi)) or F(F(phi) and psi)`

The TM axiom system has `temp_a` which gives `phi -> G(P(phi))`. By contrapositive symmetry (and the fact that P is the past dual), the system likely derives `phi -> H(F(phi))` as well. The system has `temp_4` (`G(phi) -> G(G(phi))`), `temp_t_future/past`, and temporal K distribution.

**But the TM axiom system does NOT appear to have an explicit linearity axiom.** The axiom `temp_a` is the connectedness axiom, not the linearity axiom. These are related but distinct:
- Connectedness: the time order has no endpoints relative to reachable points
- Linearity: any two reachable points are comparable

In a reflexive connected transitive frame, linearity can fail if there are "branching" futures. The temp_a axiom prevents the future from being disconnected from the past, but does not prevent branching.

### 6.6 Updated Linearity Risk

This analysis raises the linearity risk from research-001's 85% to approximately **60-70%**. The key question is: **does the TM axiom system derive the linearity schema for the temporal dimension?**

If YES: The canonical quotient works with the estimated 20-34 hours.
If NO: The canonical frame is a partial order (not necessarily linear), and we need:
- Either an explicit linearity axiom added to TM (changes the axiom system -- potentially acceptable if sound)
- Or a partial order embedding strategy (back to the mosaic method's challenge)
- Or a proof that the existing axioms derive linearity (possible but requires careful analysis)

### 6.7 Mitigation: The "Reachable Fragment" Argument

Even if the full canonical frame is not linear, the **reachable fragment from a single root** might be linear. This is because:
- The root MCS M0 determines the GContent seed for all its R-successors
- All R-successors of M0 extend `GContent(M0)`
- For any two R-successors M1, M2 of M0, both contain `GContent(M0)`
- The question is whether `GContent(M1)` and `GContent(M2)` are comparable

In a **reflexive, transitive** frame (which the canonical frame is, by temp_4 and temp_t), the reachable fragment from M0 forms a connected preorder. If we can show this preorder is total (linear), we are done.

The totality argument may use: for any formula phi, either `G(phi) in M0` or `G(neg(phi)) in M0` or neither. If neither, then `F(neg(phi)) in M0` and `F(neg(neg(phi))) in M0`, which gives `F(phi) in M0`. So any formula is either G-forced or F-satisfiable from M0. This is a start, but does not immediately give linearity of the R-successors.

---

## 7. Updated Feasibility Comparison

| Criterion | Canonical Quotient | Mosaic (WitnessGraph) | Hybrid |
|-----------|-------------------|-----------------------|--------|
| **Mathematical soundness** | Standard (textbook) | Standard (textbook) | Standard |
| **forward_F proof** | Trivial | Trivial (already proven: `witnessGraph_forward_F_local`) | Trivial |
| **Linearity/embedding** | Must prove linearity from axioms | Must linearize DAG | Must prove linearity (same as CQ) |
| **Linearity confidence** | 60-70% | 40-50% (partial order harder) | 60-70% |
| **Infrastructure reuse** | High (seed consistency, lindenbaum, GContent) | High (WitnessGraph.lean) | Maximum but unnecessary |
| **New code needed** | Canonical frame + linearity + embedding | DAG linearization + embedding | Both |
| **Effort (hours)** | 20-34 (if linearity works), 40-50 (if not) | 60-90 | 70-100+ |
| **Confidence** | 60-75% (revised down from 75-85%) | 45-55% | 55-65% |

---

## 8. Recommendations

### 8.1 Primary Recommendation: Canonical Quotient (Unchanged, but with Linearity Risk Flagged)

The Canonical Quotient (research-001 Approach A) remains the best approach. Despite the linearity risk being higher than initially assessed, it is still the simplest and most direct path.

**Immediate next step**: Before committing to implementation, resolve the linearity question:
1. Attempt to derive the linearity schema `F(phi) and F(psi) -> F(phi and psi) or F(phi and F(psi)) or F(F(phi) and psi)` from the TM axioms
2. If derivable: proceed with Canonical Quotient (20-34 hours)
3. If not derivable: determine whether to add a linearity axiom to TM (sound by the intended semantics) or pursue alternative embedding

### 8.2 The Mosaic Method Is Not an Improvement

The mosaic method (Deferred Concretization) provides no advantage over the Canonical Quotient:
- Same mathematical core (fresh witness per obligation)
- Same hard step (linearization)
- More infrastructure overhead
- The WitnessGraph.lean code is valuable as validation but not as a building block for the final proof

### 8.3 The WitnessGraph.lean Infrastructure Has Residual Value

Although the WitnessGraph.lean code (3113 lines) is not directly needed for the Canonical Quotient, it provides:
- `witnessGraph_forward_F_local`: Proof template for canonical forward_F
- `GContent_mono`, `GContent_path_propagates`: Directly reusable lemmas
- Validation that Lindenbaum + seed consistency strategy works in Lean 4

### 8.4 If Linearity Fails: Fallback to Mosaic with Added Axiom

If the linearity proof from the existing TM axioms fails, the most pragmatic resolution is:
1. Add an explicit linearity axiom to TM (sound by the intended semantics over linear integer time)
2. This immediately makes both the canonical quotient and mosaic approaches work
3. The linearity axiom is a standard axiom in tense logics of linear time (Kt.Li)

Adding an axiom is technical debt, but it is **mathematically sound** (the intended semantics is linear integer time) and could be removed once a derivation from the existing axioms is found.

---

## 9. Answers to Specific Research Questions

### Q1: Can the mosaic method avoid the linear chain topology constraint?

**Yes.** The mosaic method avoids the constraint by giving each F-obligation its own fresh Lindenbaum witness, just like the canonical quotient. However, the linearization step (embedding the resulting structure into Int) is still required and is non-trivial.

### Q2: What insights from the Canonical Quotient could improve the mosaic approach?

The key insight is that **linearity should be proven from axioms, not constructed from the graph topology**. If the temp_a axiom (plus other TM axioms) derives linearity, then the witness graph is automatically linearly ordered, and the embedding into Int follows from `Order.embedding_from_countable_to_dense`.

### Q3: Could a mosaic-quotient hybrid achieve better confidence than either alone?

**No.** The hybrid combines the complexity of both approaches without eliminating any steps. It requires all of WitnessGraph.lean plus the linearity proof plus the embedding theorem. The pure canonical quotient is strictly simpler.

### Q4: Were there other promising methods in research-010 that deserve re-evaluation?

No. Normal form reduction (Section 4) was correctly assessed as irrelevant. AliveF seed preservation (Section 6.2) is strictly inferior to the canonical quotient. The Deferred Concretization (Section 5) is the mosaic method analyzed above.

---

## 10. Key Findings

### 10.1 Mosaic and Canonical Quotient Are Mathematically Equivalent

Both approaches give each F-obligation its own fresh witness MCS via Lindenbaum extension. The difference is purely in the formalization strategy for linearization. The canonical quotient is simpler because it leverages existing Mathlib infrastructure (`Order.embedding_from_countable_to_dense`).

### 10.2 The Linearity Proof Is the Critical Path for All Approaches

Whether using the mosaic method, canonical quotient, or any hybrid, the hardest step is proving that the resulting structure can be embedded into Int while preserving GContent propagation. The linearity of the canonical relation from the TM axioms is the key open question.

### 10.3 The Linearity Risk Is Higher Than Initially Assessed

Research-001 estimated 85% confidence for the linearity proof. This report revises the estimate to 60-70% based on closer analysis of the axiom system. The TM axiom system has connectedness (temp_a) but may not directly derive the linearity schema without additional work.

### 10.4 No Alternative Method Surpasses the Canonical Quotient

Of all methods examined across research-010 and research-001, the Canonical Quotient remains the most promising. It has the lowest effort, highest reuse of existing infrastructure, and directly addresses the root cause identified in research-001.

---

## 11. Next Steps

1. **Resolve the linearity question**: Determine whether `F(phi) and F(psi) -> F(phi and psi) or F(phi and F(psi)) or F(F(phi) and psi)` is derivable from TM axioms. This can be attempted as a focused Lean proof or paper sketch.

2. **If linearity is derivable**: Proceed with Canonical Quotient implementation (estimated 20-34 hours).

3. **If linearity is not derivable**: Evaluate adding a linearity axiom to TM. This is sound (the intended semantics is linear integer time) and would unblock both the canonical quotient and mosaic approaches.

4. **Preserve WitnessGraph.lean**: Do not delete the existing infrastructure. Even though it is not the final approach, its proven lemmas are valuable for the canonical frame construction.

---

## References

### Project Files
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` -- Chain construction (2 sorries at forward_F, backward_P)
- `Theories/Bimodal/Metalogic/Bundle/WitnessGraph.lean` -- 3113 lines, `witnessGraph_forward_F_local` proven
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` -- Interface definition (TemporalCoherentFamily)
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- TM axioms (16 total), including temp_a (connectedness)
- `Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean` -- GContent/HContent definitions

### Prior Research
- `specs/922_strategy_study_fp_witness_completeness_blockers/reports/research-001.md` -- Meta-analysis, Canonical Quotient recommendation
- `specs/916_implement_fp_witness_obligation_tracking/reports/research-010.md` -- Mosaic/Deferred Concretization evaluation

### Mathlib
- `Order.embedding_from_countable_to_dense` (Mathlib.Order.CountableDenseLinearOrder): Any countable linear order embeds into any nontrivial densely ordered linear order
- `Order.iso_of_countable_dense` (Mathlib.Order.CountableDenseLinearOrder): Cantor's isomorphism theorem for countable dense linear orders

### External Literature
- Marx, M., Mikulas, S., Reynolds, M. (2000). "The Mosaic Method for Temporal Logics." TABLEAUX 2000
- Reynolds, M. (2003). "Completeness by construction for tense logics of linear time."
- Goldblatt, R. (1992). *Logics of Time and Computation*. CSLI Publications
- Venema, Y. "Temporal Logic." Chapter 10 in *Handbook of Modal Logic*
- Blackburn, P., de Rijke, M., Venema, Y. (2001). *Modal Logic*. Cambridge University Press
