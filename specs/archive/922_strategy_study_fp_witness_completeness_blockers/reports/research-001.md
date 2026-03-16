# Research Report: Task #922 - Strategy Study for forward_F/backward_P Completeness Blockers

**Task**: Meta-analysis of 16 research reports and 12 plan versions for the forward_F/backward_P completeness challenge
**Date**: 2026-02-24
**Focus**: Pattern analysis of failed approaches, creative reframing, novel approach generation
**Session**: sess_1771955427_570711

---

## Summary

This strategy study analyzes the complete history of 16 research reports, 12 implementation plans, and multiple implementation attempts for Task 916 (forward_F/backward_P witness construction). The study identifies the precise mathematical property that all failed approaches lacked, diagnoses the cognitive trap that led to 12 successive plan revisions, and proposes 4 genuinely novel approaches that escape the "bottom-up chain construction" pattern. The primary recommendation is the **Canonical Quotient** approach, which builds the BFMCS using the full canonical model and then embeds it into Int via an order-preserving quotient. This approach has the highest feasibility because forward_F becomes trivial in the canonical model and the remaining work is purely order-theoretic.

---

## Part I: Lessons Learned -- The Precise Mathematical Property All Failed Approaches Lacked

### 1.1 The Obstruction Stated Precisely

Every failed approach attempted some variation of the following pattern:

> Build a chain `chain : Nat -> Set Formula` where `chain(n+1) = Lindenbaum(seed(chain(n)))`, then prove `forward_F`: if `F(psi) in chain(n)`, then exists `m > n` with `psi in chain(m)`.

The **precise mathematical property** that all such approaches lack is:

**Freedom of witness selection**: In the canonical model, each F-obligation `F(psi) in M` gets its OWN independently-constructed witness MCS `W_psi = Lindenbaum({psi} union GContent(M))`. Different F-obligations get DIFFERENT witnesses. The linear chain forces ALL F-obligations to share a single future sequence, and the witness for one obligation can destroy another.

More formally: Let `M` be an MCS with `F(psi_1), F(psi_2) in M`. The canonical model provides:
- `W_1 = Lindenbaum({psi_1} union GContent(M))` with `psi_1 in W_1`
- `W_2 = Lindenbaum({psi_2} union GContent(M))` with `psi_2 in W_2`

These are generally DIFFERENT MCSes. `W_1` might contain `G(neg(psi_2))`, which kills `F(psi_2)`. In a linear chain, this is fatal because `W_1` comes BEFORE the time where `psi_2` must appear. In the canonical model, this is irrelevant because `W_2` is a separate world.

### 1.2 Why "Lindenbaum Opacity" Is NOT a Fundamental Barrier

The term "Lindenbaum opacity" (used throughout the research reports) refers to the fact that Lindenbaum extension via Zorn's lemma makes non-constructive choices that cannot be controlled. However, this is a misleading framing.

**Lindenbaum opacity is not the real barrier.** The real barrier is the **linear chain topology**. In the canonical model (where ALL MCSes are worlds), Lindenbaum is used in exactly the same way, but forward_F is trivial because:

1. `F(psi) in M` implies `{psi} union GContent(M)` is consistent (proven as `forward_temporal_witness_seed_consistent`)
2. Lindenbaum extends this to an MCS `W` with `psi in W` and `GContent(M) subset W`
3. Define `M R W` (since `GContent(M) subset W`), so `W` is a future world
4. Done -- `W` witnesses `F(psi)`, and we never need to worry about other F-obligations

The "opacity" only becomes a problem when we REUSE a Lindenbaum-constructed MCS to also satisfy other obligations. The canonical model avoids reuse entirely.

### 1.3 The Hidden Assumption: "We Must Build a Single Linear Chain"

Every approach from research-001 through research-016 and plans v001 through v012 shares this hidden assumption:

> We must construct a function `chain : Int -> Set Formula` by building MCSes one at a time, where each MCS is determined by Lindenbaum extension of a seed derived from previously-built MCSes.

This assumption has three corollaries, all of which contribute to failure:

**Corollary 1: Sequential dependency**. Each `chain(n+1)` depends on `chain(n)`. This creates a single point of failure: if `chain(n+1)` kills `F(psi)`, there is no recovery path because `chain(n+2)` depends on `chain(n+1)`.

**Corollary 2: Shared seed space**. The seed for `chain(n+1)` must include `GContent(chain(n))` for forward_G. This GContent is "contaminated" by choices made for other F-obligations, creating inter-obligation interference.

**Corollary 3: Fixed topology**. The time domain is fixed as Int (or Nat) from the start. The construction must fit all witnesses into this pre-determined linear order, rather than letting the witness construction determine the order.

### 1.4 The Cognitive Trap: "Almost There" Syndrome

The 12 successive plan revisions each believed their approach would work because of a systematic cognitive pattern:

1. **Correct local insight**: Each approach correctly identifies that `{psi} union GContent(M)` is consistent (proven lemma).
2. **Underestimation of interaction effects**: Each approach correctly handles ONE F-obligation but fails to account for how processing that obligation affects OTHER obligations.
3. **Incremental optimism**: Each revision adds a small fix (omega-squared nesting, immediate processing, FPreservingSeed) to the previous approach, believing the fix is sufficient. But the fundamental topology is unchanged.
4. **Sunk cost reinforcement**: 3000+ lines of chain infrastructure (DovetailingChain.lean, WitnessGraph.lean) create pressure to "make the chain approach work" rather than abandoning it.
5. **Success of forward_G**: The chain construction handles forward_G perfectly, creating the impression that forward_F should be "similarly achievable with a small modification."

The trap is: forward_G and forward_F are fundamentally different. G is UNIVERSAL (holds at ALL future times), so it propagates automatically through GContent seeds. F is EXISTENTIAL (holds at SOME future time), so it requires witness selection, and witness selection in a linear chain creates interference between obligations.

---

## Part II: Analysis of All Approaches

### 2.1 Taxonomy of Failed Approaches

| # | Approach | Plans | Key Idea | Failure Mode |
|---|----------|-------|----------|--------------|
| 1 | Linear chain + GContent seed | v001-v003 | Process F at encoding step | Past-encoding gap + persistence failure |
| 2 | Fair enumeration (repeated processing) | v004 | Process each F infinitely often | Persistence failure between processings |
| 3 | FPreservingSeed | v005 | Include FContent in seed | Provably inconsistent (counterexample) |
| 4 | Omega-squared directed limit | v004, v006 | Nested chain iteration | Generalized seed consistency is FALSE |
| 5 | Derivation surgery | v005, v007 | Cut-and-paste proof arguments | Counterexample refutes conjecture |
| 6 | Controlled Lindenbaum | v008 | Priority-augmented Lindenbaum | Necessary killings still occur |
| 7 | AliveF seed preservation | v009 | Preserve F at non-witness steps | Gap at witness steps |
| 8 | Witness-graph-guided chain | v010, v011 | Embed DAG into linear chain | Local vs universal GContent gap |
| 9 | Two-timeline embedding | v011 | Split forward/backward timelines | Cross-timeline coherence fails |
| 10 | Tree unraveling | v011 | Unravel DAG to tree | Destroys inverse relation (P/H) |
| 11 | Omega-squared immediate | v012 | Process F before any Lindenbaum | Same persistence problem at inner level |
| 12 | Constant family oracle | v011 | Use rootMCS everywhere | F(psi) in M does not imply psi in M |

### 2.2 The Common Thread

All 12 approaches share the assumption stated in Section 1.3: they attempt to build a single linear chain of MCSes, one at a time, using Lindenbaum extension. The specific innovations (nesting, scheduling, seed augmentation) are attempts to work around the fundamental topology problem within the linear chain framework.

### 2.3 What the WitnessGraph Infrastructure DID Accomplish

WitnessGraph.lean (3113 lines) correctly implements the step-by-step construction:
- Each F/P obligation gets its own fresh MCS via Lindenbaum
- Local forward_F is proven (`witnessGraph_forward_F_local`)
- GContent propagates along edges

The failure occurred at **Phase 5**: embedding the witness graph into a linear chain (Int-indexed BFMCS). The embedding reverted to building a chain step-by-step, losing the per-obligation independence that made the witness graph work.

**Key insight**: The WitnessGraph infrastructure is architecturally sound. The problem is exclusively in the linearization step.

---

## Part III: Novel Approaches

### Approach A: Canonical Quotient (RECOMMENDED)

**Core idea**: Do NOT build a chain. Instead, construct the canonical model (worlds = all MCSes, relation = GContent inclusion), prove forward_F trivially, then quotient/embed into Int.

**Why this is different from all previous approaches**: It inverts the construction order. Previous approaches: "Build linear chain, then prove forward_F." This approach: "Prove forward_F in an easy setting, then obtain linearity."

**Construction**:

1. **Canonical Frame**: Define `W = { M : Set Formula | SetMaximalConsistent M }` with relation `R(M, M') iff GContent(M) subset M'`.

2. **forward_F is trivial**: Given `F(psi) in M`, use `forward_temporal_witness_seed_consistent` to get that `{psi} union GContent(M)` is consistent. Apply Lindenbaum to get `M'` with `psi in M'` and `GContent(M) subset M'`. Then `R(M, M')` and `psi in M'`. Done.

3. **forward_G is trivial**: If `G(phi) in M` and `R(M, M')`, then `phi in GContent(M) subset M'`.

4. **backward_H and backward_P**: Symmetric using HContent.

5. **Linearity of R**: Prove that for any two MCSes M, M' in the canonical frame accessible from a common root, either `R(M, M')` or `R(M', M)` or `M = M'`. This follows from the `temp_a` axiom (temporal connectedness: `phi -> G(P(phi))`).

6. **Embedding into Int**: Any countable linear order embeds into Int. The canonical frame restricted to MCSes reachable from the root is countable (Formula is countable, each MCS is determined by its theory, and the reachable fragment is countable). Use a standard order-embedding theorem.

7. **Produce BFMCS Int**: Compose the embedding with the canonical MCS assignment to get `mcs : Int -> Set Formula`.

**What existing infrastructure is reused**:
- `forward_temporal_witness_seed_consistent` (proven) -- core of forward_F
- `past_temporal_witness_seed_consistent` (proven) -- core of backward_P
- `set_lindenbaum` (proven) -- Lindenbaum extension
- `GContent_mono` (proven, Task 916 Phase 2) -- GContent monotonicity
- `GContent_path_propagates` (proven, Task 916 Phase 2) -- path propagation
- `set_mcs_all_future_all_future` (proven) -- 4-axiom for G persistence
- All MCS property lemmas in MCSProperties.lean

**What must be newly developed**:
1. Canonical frame definition and basic properties (~4-6 hours)
2. Linearity proof from temp_a axiom (~8-12 hours) -- this is the hardest part
3. Countable linear order embedding into Int (~4-8 hours)
4. BFMCS Int construction from embedding (~2-4 hours)
5. Integration with existing completeness chain (~2-4 hours)

**Feasibility assessment**: HIGH (75-85% confidence)
- The mathematics is standard (textbook canonical model construction)
- The hardest part (linearity from temp_a) is well-studied in the literature
- forward_F/backward_P are trivial once the canonical frame is defined
- The embedding into Int is a standard order-theory result
- Reuses substantial existing infrastructure

**Estimated effort**: 20-34 hours

**Risk**: The linearity proof from temp_a requires careful handling. The axiom `phi -> G(P(phi))` (temporal connectedness) needs to be used to show that any two MCSes reachable from the root are comparable. This may require showing that the GContent-inclusion relation on the reachable fragment forms a linear preorder, which involves non-trivial MCS reasoning.

**Critical advantage over all previous approaches**: forward_F is proven BEFORE linearity, not after. This completely avoids the witness persistence problem because each F-obligation gets its own fresh witness MCS.

---

### Approach B: Enumerate-and-Insert (Fresh Witness Insertion into Existing Chain)

**Core idea**: Build the chain normally (with GContent seeds), then for each unsatisfied F-obligation, INSERT a fresh witness MCS between two existing chain positions. The chain grows dynamically to accommodate witnesses.

**Why this is different**: Previous approaches tried to place witnesses at pre-determined positions. This approach allows the chain to grow on demand.

**Construction**:

1. Build initial chain `chain_0 : Nat -> Set Formula` using GContent seeds (this is the existing DovetailingChain).
2. For each `F(psi) in chain_0(n)`:
   a. Construct `W = Lindenbaum({psi} union GContent(chain_0(n)))` (proven consistent)
   b. Insert `W` between positions `n` and `n+1` in the chain
3. Repeat: the inserted MCS may contain new F-obligations, requiring further insertions.
4. After omega iterations, the chain has countably many positions.
5. Re-index to Int.

**Key challenge**: After inserting `W` between positions `n` and `n+1`, we need:
- `GContent(chain_0(n)) subset W` (ensured by construction)
- `GContent(W) subset chain_0(n+1)` (NOT ensured -- W is fresh)

This means forward_G breaks at the insertion point.

**Resolution**: Instead of inserting between existing positions, append `W` at position `n+1` and shift everything else right. But this changes all indices and breaks inductive proofs.

**Alternative resolution**: Use a dense order (like rationals) as the intermediate index set, then embed into Int.

**Feasibility assessment**: MEDIUM (50-60% confidence)
- The insertion-and-shift mechanics are complex in Lean 4
- Maintaining forward_G across insertions requires careful argument
- The dense order intermediate step adds complexity
- Less existing infrastructure to reuse

**Estimated effort**: 40-60 hours

**Risk**: The forward_G maintenance across insertions is the key difficulty. When a fresh witness MCS is inserted, its GContent might not be a subset of the next chain position. This requires either (a) re-extending subsequent positions or (b) using a more sophisticated insertion strategy.

---

### Approach C: Compactness-Based Existence (Avoid Explicit Construction)

**Core idea**: Instead of CONSTRUCTING a BFMCS Int, prove its EXISTENCE using a compactness argument. Define the set of all "local coherence constraints" and show they are finitely satisfiable, then invoke compactness to get a global model.

**Why this is different**: All previous approaches are constructive (they build the BFMCS). This approach is non-constructive at a higher level, avoiding the chain construction entirely.

**Construction**:

1. For each finite subset S of temporal coherence constraints (forward_F, backward_P, forward_G, backward_H for specific formulas and time indices), show that there exists a BFMCS Int satisfying S. This uses the existing chain construction (which works for finitely many F-obligations).

2. Apply compactness (or Zorn's lemma) to obtain a BFMCS Int satisfying ALL constraints.

**Key challenge**: The temporal coherence constraints are not first-order sentences over a fixed language. They are second-order conditions on the MCS assignment function. Standard compactness does not directly apply.

**Resolution**: Encode the constraints as a first-order theory over a suitable signature. The time domain is Int (fixed), formulas are countable (fixed), and MCS membership is a binary predicate `In(t, phi)`. The constraints become:
- `forall t t' phi, (t < t' /\ In(t, G(phi))) -> In(t', phi)` (forward_G)
- `forall t phi, In(t, F(phi)) -> exists s > t, In(s, phi)` (forward_F)
- etc.
- Plus MCS axioms: `forall t phi, In(t, phi) \/ In(t, neg(phi))`, consistency, closure under derivation

This is a first-order theory over the signature `(Int, Formula, In, <, derivation)`. By standard first-order compactness, if every finite fragment is satisfiable, the whole theory is satisfiable.

**Feasibility assessment**: LOW-MEDIUM (35-50% confidence)
- First-order compactness is available in Mathlib
- BUT encoding MCS constraints as first-order sentences is complex
- The encoding may require significant new infrastructure
- The resulting proof would be highly non-constructive (Compactness + Zorn + Lindenbaum)

**Estimated effort**: 30-50 hours

**Risk**: The encoding step may be technically difficult. MCS properties (closure under derivation, maximality) are second-order in nature and may not encode cleanly into first-order logic over a fixed signature.

---

### Approach D: Two-Phase Construction (GContent Chain + Witness Grafting)

**Core idea**: Build the chain in two phases. Phase 1 builds a chain satisfying forward_G and backward_H only (the existing DovetailingChain, which is sorry-free for these). Phase 2 proves forward_F/backward_P by showing that the chain can be MODIFIED to add witnesses, or by proving that the existing chain already has witnesses (by a counting/pigeonhole argument).

**Why this is different**: Instead of trying to build forward_F into the chain construction, accept the chain as-is and prove forward_F as a PROPERTY of Lindenbaum-extended chains.

**Construction -- Phase 2a (Probabilistic argument that witnesses exist)**:

Consider `F(psi) in chain(n)`. The set `{psi} union GContent(chain(n))` is consistent. By Lindenbaum, some MCS `W` extends it. Now: does `W` coincide with ANY `chain(m)` for `m > n`?

NOT NECESSARILY. But consider: `chain(m)` for all `m > n` are Lindenbaum extensions of seeds containing `GContent(chain(n))`. Since `{psi} union GContent(chain(n))` is consistent, and `psi` is either provable or unprovable from `GContent(chain(n))`:

- If `GContent(chain(n))` derives `psi`, then `psi in chain(n+1)` and we are done.
- If `GContent(chain(n))` does not derive `psi`, then `psi` is undecided by the seed. The Lindenbaum extension MIGHT include `psi` or `neg(psi)`. We have no control.

**Phase 2b (Semantic/model-theoretic argument)**:

The DovetailingChain already satisfies forward_G, backward_H, and MCS properties. By soundness (which is proven), any formula provable in TM is true in ALL models, including the DovetailingChain model. Now:

- Can we prove forward_F as a THEOREM of TM? No -- forward_F is a semantic property, not a syntactic one.
- But we CAN argue: if the DovetailingChain model did NOT satisfy forward_F, then we could derive a contradiction with the completeness of the LOGIC (not the completeness proof we're constructing). This is circular.

**Feasibility assessment**: LOW (25-35% confidence)
- Phase 2a does not work (Lindenbaum choices are uncontrolled)
- Phase 2b is circular
- The "grafting" idea (modifying the chain to add witnesses) faces the same forward_G maintenance issues as Approach B

**Estimated effort**: Not recommended

---

## Part IV: Feasibility Comparison and Recommendation

### 4.1 Comparison Matrix

| Criterion | A: Canonical Quotient | B: Enumerate-Insert | C: Compactness | D: Two-Phase |
|-----------|----------------------|--------------------|-----------------|----|
| **Mathematical soundness** | Proven (textbook) | Plausible | Proven (in principle) | Partially circular |
| **forward_F difficulty** | Trivial | Medium | Embedded in constraints | Unsolved |
| **forward_G difficulty** | Trivial | Hard (maintenance) | Embedded | Already proven |
| **Linearity/Int difficulty** | Medium (embedding) | Hard (re-indexing) | Embedded | N/A |
| **Infrastructure reuse** | High | Medium | Low | High |
| **Confidence** | 75-85% | 50-60% | 35-50% | 25-35% |
| **Effort (hours)** | 20-34 | 40-60 | 30-50 | N/R |
| **Risk-adjusted effort** | 24-45 | 67-120 | 60-143 | N/R |

### 4.2 Ranked Recommendation

**1. Approach A: Canonical Quotient** -- STRONGLY RECOMMENDED

This is the standard mathematical approach (Goldblatt 1992, Blackburn et al. 2001, Venema). It has the highest confidence, lowest effort, and reuses the most existing infrastructure. forward_F and backward_P become trivial. The remaining challenge (linearity + Int embedding) is well-studied and does not involve the Lindenbaum opacity issue that blocked all chain approaches.

**Decision criteria for choosing Approach A**:
- Does the codebase have `forward_temporal_witness_seed_consistent`? YES (proven)
- Does the codebase have `set_lindenbaum`? YES (proven)
- Is the temp_a axiom available? YES (in Axioms.lean)
- Is Formula countable? YES (derives Countable)

All prerequisites are met.

**2. Approach B: Enumerate-and-Insert** -- FALLBACK ONLY

Only pursue if Approach A encounters unexpected obstacles with the linearity proof or Int embedding. The forward_G maintenance across insertions is a significant engineering challenge.

**3. Approach C: Compactness-Based** -- NOT RECOMMENDED

The encoding overhead is too high and the resulting proof would be difficult to maintain or extend.

**4. Approach D: Two-Phase** -- NOT RECOMMENDED

Contains a circular argument and does not actually solve the problem.

### 4.3 Decision Criteria for Implementation

Approach A should be implemented if ALL of the following hold:
1. The linearity proof from temp_a can be sketched on paper within 2 hours
2. Mathlib has a countable linear order embedding theorem (or one can be constructed within 4 hours)
3. The BFMCS structure can accept a non-Int time domain temporarily (for the canonical model intermediate step)

If any of these fail, fall back to Approach B.

---

## Part V: Detailed Implementation Sketch for Approach A

### Phase 1: Canonical Frame (4-6 hours)

Define the canonical frame:

```lean
/-- The canonical temporal relation: M R M' iff GContent(M) subset M' -/
def CanonicalR (M M' : Set Formula) : Prop :=
  GContent M ⊆ M'

/-- In the canonical frame, forward_F holds trivially -/
theorem canonical_forward_F (M : Set Formula) (hM : SetMaximalConsistent M)
    (phi : Formula) (hF : Formula.some_future phi ∈ M) :
    ∃ M' : Set Formula, SetMaximalConsistent M' ∧ CanonicalR M M' ∧ phi ∈ M' := by
  -- {phi} union GContent(M) is consistent
  have h_cons := forward_temporal_witness_seed_consistent M hM phi hF
  -- Extend to MCS
  obtain ⟨M', hM', hext⟩ := set_lindenbaum _ h_cons
  exact ⟨M', hM', subset_trans (Set.subset_union_right) hext,
         hext (Set.mem_union_left _ (Set.mem_singleton phi))⟩
```

### Phase 2: Linearity (8-12 hours)

Prove that the canonical frame restricted to the reachable fragment from the root MCS forms a linear order. This uses:
- `temp_a`: `phi -> G(P(phi))` (at the root, every truth persists as a past-truth at all future times)
- MCS properties: maximality, consistency, closure under derivation

The key lemma: for two MCSes M, M' both GContent-reachable from root, either `GContent(M) subset M'` or `GContent(M') subset M`.

This follows from: in any MCS M reachable from root, for any formula phi, either `G(phi) in M` or `G(neg(phi)) in M` or `F(phi) and F(neg(phi)) in M`. The temporal axioms (linearity axiom if present, or derivable from temp_a + other axioms) force one of the first two cases for the reachable fragment.

### Phase 3: Embedding into Int (4-8 hours)

Standard result: any countable dense linear order without endpoints is isomorphic to Q, and any countable linear order embeds into Q. Since Int and Q are both countable, any countable linear order embeds into Int (with possible gaps).

The key Lean formalization: use `Countable` + `LinearOrder` to construct an injection from the reachable canonical frame into Int that preserves the order.

### Phase 4: BFMCS Construction (2-4 hours)

Compose the embedding with the canonical MCS assignment:

```lean
noncomputable def canonicalBFMCS (root : Set Formula) (hroot : SetMaximalConsistent root) :
    BFMCS Int where
  mcs t := canonicalMCSAt (embedding.invFun t)
  is_mcs t := ...
  forward_G t t' phi ht hG := ...  -- from canonical_R transitivity
  backward_H t t' phi ht hH := ... -- symmetric
```

### Phase 5: Integration (2-4 hours)

Replace `temporal_coherent_family_exists_theorem` with the canonical quotient proof.

---

## Part VI: Why Previous Research Missed This Approach

### 6.1 The Canonical Model WAS Identified But Rejected

Research-008 (Section 3.4) explicitly describes the canonical model approach and estimates 40-80 hours. Research-010 (Section 5) describes the "Deferred Concretization" variant. Research-014 (Section 3) identifies WitnessGraph as the step-by-step construction from the literature.

These reports correctly identified the mathematical approach but made two errors:

1. **Overestimated the embedding difficulty**: The estimates (40-80 hours) assumed rebuilding the entire completeness proof from scratch. In fact, the existing BFMCS interface only requires `mcs : Int -> Set Formula` with forward_G, backward_H, and MCS properties. The canonical model provides all of these; only the Int embedding needs new work.

2. **Conflated "canonical model" with "full rebuild"**: The canonical model does NOT require changing the TruthLemma, BMCSTruth, or Completeness modules. It only requires providing a new construction of `temporal_coherent_family_exists_Int` that satisfies the same interface. The downstream proof chain is completely unchanged.

### 6.2 Why the Chain Approach Was Persisted With

The sunk cost of ~5000 lines of chain infrastructure (DovetailingChain.lean + WitnessGraph.lean) created institutional momentum. Each new research report started from the premise "how do we make the existing chain work?" rather than "what is the simplest construction that satisfies the interface?"

### 6.3 The Key Reframing

The problem is NOT:
> "Prove forward_F for a chain"

The problem IS:
> "Construct any BFMCS Int satisfying the TemporalCoherentFamily interface"

This reframing immediately opens the door to canonical model approaches, because the interface does not require that the construction be a chain.

---

## Part VII: Confidence Assessment

| Claim | Confidence | Basis |
|-------|------------|-------|
| All chain-based approaches are blocked | 99% | 12 plan versions + mathematical analysis |
| FPreservingSeed is refuted | 95% | Counterexample in research-005 |
| Canonical Quotient approach is mathematically sound | 95% | Standard textbook result |
| Canonical Quotient is implementable in 20-34 hours | 70% | Depends on linearity proof difficulty |
| Linearity from temp_a is provable | 85% | Standard result, well-studied |
| Int embedding of countable linear order exists | 90% | Standard order theory |
| Existing downstream proofs unchanged | 95% | Only interface must be satisfied |
| Zero-sorry completeness achievable via Approach A | 75-85% | Product of above probabilities |

---

## References

### Literature
- Goldblatt, R. (1992). *Logics of Time and Computation*. CSLI Publications.
- Blackburn, P., de Rijke, M., Venema, Y. (2001). *Modal Logic*. Cambridge University Press.
- Reynolds, M. (2003). "Completeness by construction for tense logics of linear time."
- Venema, Y. "Temporal Logic." Chapter 10 in *Handbook of Modal Logic*.
- Marx, M., Mikulas, S., Reynolds, M. (2000). "The Mosaic Method for Temporal Logics." TABLEAUX 2000.
- de Jongh, D., Veltman, F., Verbrugge, R. (2004). "Completeness by construction for tense logics of linear time."
- Burgess, J.P. (1982). "Axioms for tense logic." *Notre Dame Journal of Formal Logic*.
- [LeanLTL: A Unifying Framework for Linear Temporal Logics in Lean](https://drops.dagstuhl.de/entities/document/10.4230/LIPIcs.ITP.2025.37)
- [Formalized Formal Logic Project](https://formalizedformallogic.github.io/Book/)

### Key Codebase Files
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` -- 2 sorries (forward_F, backward_P)
- `Theories/Bimodal/Metalogic/Bundle/WitnessGraph.lean` -- 3113 lines of witness infrastructure
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` -- interface definition
- `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` -- BFMCS structure
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` -- uses TemporalCoherentFamily
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` -- final completeness theorem
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- temp_a axiom (connectedness)

### Task 916 Research Reports (16 total)
- research-001 through research-016 in `specs/916_implement_fp_witness_obligation_tracking/reports/`
- Key reports: research-008 (root cause analysis), research-014 (path forward synthesis), research-015 (implementation blocker analysis), research-016 (witness-graph-guided definitively blocked)

### Task 916 Plans (12 versions)
- implementation-001 through implementation-012 in `specs/916_implement_fp_witness_obligation_tracking/plans/`
- Key plans: v005 (FPreservingSeed counterexample), v012 (omega-squared, Phase 3 blocked)

### Task 916 Handoff Documents
- `phase-3-blocker-analysis-20260224.md` -- crystallizes the obstruction
- `phase-5B-handoff-20260224.md` -- WitnessGraph infrastructure assessment

---

## Next Steps

1. **Validate linearity from temp_a**: Before committing to Approach A, sketch the linearity proof on paper. Specifically: given MCSes M, M' both accessible from root via GContent inclusion, prove `GContent(M) subset M'` or `GContent(M') subset M`. This is the highest-risk step.

2. **Check Mathlib for order embedding**: Search Mathlib for a theorem embedding countable linear orders into Int (or Z). If none exists, assess the effort to prove one.

3. **Define canonical frame in Lean**: Create `CanonicalFrame.lean` with the basic definitions and trivial forward_F proof.

4. **Prove linearity**: Formalize the linearity argument using temp_a and MCS properties.

5. **Prove embedding and construct BFMCS Int**: Complete the construction and wire into the existing interface.
