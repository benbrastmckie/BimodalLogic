# Research Report: Task #1004 - Teammate A Findings

**Task**: Mathematical Theory and Literature Analysis for F/P Witness Persistence
**Date**: 2026-03-19
**Focus**: Deep mathematical analysis of WHY F-formulas fail to persist, literature review, alternative constructions

## Key Findings

### 1. The Fundamental Mathematical Problem

**Why F-formulas fail to persist through Lindenbaum extensions**:

The core issue is a fundamental incompatibility between:
1. **Lindenbaum's Lemma** - which extends any consistent set to an MCS by adding formulas
2. **The F/G duality** - where F(phi) = ~G(~phi)

When building position n+1 from position n via Lindenbaum extension of g_content(MCS_n):

1. The seed `g_content(MCS_n)` is consistent (proven via `g_content_consistent`)
2. Lindenbaum may add ANY formula not already decided by the seed
3. In particular, Lindenbaum may add G(~phi) if neither G(~phi) nor ~G(~phi) is determined
4. If G(~phi) is added to MCS_{n+1}, then ~G(~phi) = F(phi) is NOT in MCS_{n+1}

**The Chain of Non-Persistence**:
```
F(phi) in MCS_n
    |
    v
Does g_content(MCS_n) decide G(~phi)?
    |
    +-- YES (G(~phi) in g_content or ~G(~phi) derivable): persistence preserved
    |
    +-- NO: Lindenbaum is FREE to add G(~phi) to MCS_{n+1}
             => F(phi) = ~G(~phi) is NOT in MCS_{n+1}
```

**Key Insight**: F-formula membership is NOT a "hereditary" property of MCSes along CanonicalR. While g_content propagates transitively (via the 4_G axiom: G(phi) -> G(G(phi))), f_content does NOT.

### 2. Mathematical Analysis: The Temporal 4 Axiom Asymmetry

The temporal 4 axiom `G(phi) -> G(G(phi))` ensures that G-content propagates:
- If G(phi) in MCS_t, then G(G(phi)) in MCS_t by modus ponens
- Therefore G(phi) in g_content(MCS_t)
- Therefore G(phi) in any MCS_{t+k} built from g_content

**But there is NO corresponding axiom for F**:
- `F(phi) -> G(F(phi))` is NOT valid in temporal logic
- Semantically: "phi will happen" does not imply "at all future times, phi will still be coming"
- The witness for F(phi) might be BEFORE position t+k

This is the **fundamental asymmetry** that makes linear chain constructions fail:
- G-content: automatically propagates forward
- F-content: requires witnesses that may be "passed over" by the chain construction

### 3. Literature Insights

#### Goldblatt (1992) - "Logics of Time and Computation"

Goldblatt's canonical model construction for tense logics uses **all maximal consistent sets** as the domain (exactly as implemented in `CanonicalFMCS.lean`). This is referenced in the codebase at `CanonicalFrame.lean` line 42-43.

**Key technique**: Each F-obligation `F(psi) in M` gets its own independent witness via Lindenbaum extension of `{psi} union g_content(M)`. The witness is automatically in the domain (all MCSes).

**Why this works**: The canonical frame relation `CanonicalR M M' iff g_content(M) subset M'` ensures:
1. `canonical_forward_F` constructs a fresh witness W for each F-obligation
2. W is an MCS, so W is in the domain
3. No inter-obligation interference

#### Blackburn, de Rijke, Venema (2001) - "Modal Logic" Chapter 4

Their treatment of completeness emphasizes that **canonicity can fail** for temporal logics and dynamic logics. The key issue is that frame properties required for completeness (density, linearity) may not be first-order definable, making canonical model constructions subtle.

Relevant insight: "When canonicity fails, completeness-via-canonicity must be replaced by filtration or other techniques."

The codebase's approach (using all MCSes with non-total preorder) sidesteps canonicity failure by not requiring totality/linearity at the CanonicalMCS level.

#### Hughes & Cresswell (1996) - "A New Introduction to Modal Logic"

Their completeness proofs use Henkin-style canonical models. For temporal logics with F/P, the standard approach is:
1. Define canonical frame over all MCSes
2. Prove Truth Lemma by induction on formula complexity
3. F case: use Lindenbaum's Lemma to construct witness MCS

This matches the `temporal_coherent_family_exists_CanonicalMCS` theorem which is sorry-free.

#### Step-Indexed and Omega-Squared Constructions

The "omega-squared" construction mentioned in documentation refers to a technique where:
1. At step (n, k), process the k-th obligation at position n
2. Use Cantor pairing: step_number = pair(n, k)
3. Every (position, formula) pair is eventually processed

This is exactly what the `Dovetailing.lean` infrastructure implements:
```lean
theorem forall_obligation_eventually_processed (p f : Nat) :
    exists n, obligationAtStep n = mkObligation p f
```

**Critical Gap in Current Implementation**: The dovetailing processes obligations, but the **witness MCS constructed at step s does not necessarily appear in the chain at position s**. The witness is a separate MCS that needs to be "inserted" at the right position.

### 4. The Witness Placement Problem

Even with dovetailing, a fundamental problem remains:

**Problem**: When processing F(phi) at position t (at dovetailing step s = pair(t, encode(phi))):
1. We construct witness W via `canonical_forward_F`
2. W satisfies CanonicalR(mcs(t), W) and phi in W
3. But where in the Int-indexed chain does W go?

**The interference issue**:
- W should go at some position t' > t
- But position t' may already have an MCS assigned (from earlier dovetailing steps)
- OR position t' may be assigned later with a different MCS (from later dovetailing steps)

**Proposed solutions from the codebase**:

1. **"Immediate resolution"** (mentioned in bfmcs-architecture.md): Resolve F(psi) at time s+1, the very next step. But this creates conflicts when multiple F-obligations compete for the same slot.

2. **"Saturated chain via Zorn"** (SaturatedChain.lean): Use Zorn's Lemma to construct a maximal chain that is F/P saturated by construction. The chain is guaranteed to contain all necessary witnesses.

3. **"All-MCS domain"** (CanonicalFMCS.lean): Abandon Int-indexing and use all MCSes as the domain. Witnesses are automatically present.

### 5. Why Saturated Chain via Zorn is Promising but Incomplete

The `SaturatedChain.lean` approach uses:
```lean
def ChainFSaturated (C : Set CanonicalMCS) : Prop :=
  forall w in C, forall phi,
    F(phi) in w.world -> exists v in C, w < v and phi in v.world
```

**Strengths**:
- Union of saturated chains is saturated (`ChainSaturated_sUnion`)
- Empty chain is saturated (`ChainSaturated_empty`)
- Zorn's lemma applies

**The Key Obstacle** (from SaturatedChain.lean lines 220-238):

> "The main technical obstacle is that the witness from `canonical_forward_F` is constructed via Lindenbaum's lemma and is NOT guaranteed to be comparable with all elements of an existing chain."

**Mathematical Analysis**: For witness W to join chain C:
1. W must be comparable with ALL elements of C (for C to remain a chain)
2. W has `CanonicalR mcs(t) W`, so mcs(t) < W
3. But for v in C with v > mcs(t), we need either v <= W or W <= v
4. This is NOT guaranteed by the construction

This is the **"witness comparability problem"** - a deep mathematical issue that prevents simple Zorn-based solutions.

### 6. Category-Theoretic Perspective

From a category-theoretic view, the problem is about **colimits**:

1. **MCSes form a category** with CanonicalR as morphisms (transitivity gives composition)
2. **A chain is a functor** from a linearly ordered set to this category
3. **F-witnesses require extending the chain** - but the extension may not exist in the category of chains

The **correct mathematical framework** might be:
- **Presheaves over CanonicalMCS** - function families indexed by all MCSes
- **TemporalCoherentFamily** - exactly what the codebase uses

The `temporal_coherent_family_exists_CanonicalMCS` theorem (lines 293-311 of CanonicalFMCS.lean) works because it uses this presheaf-like structure rather than trying to embed into Int.

### 7. Is This a Known Issue in the Literature?

**Yes, but it's often implicit**:

1. **Standard texts** (Goldblatt, Blackburn et al.) use all-MCS domains precisely because linear chain constructions have these problems. They don't explicitly discuss why chains fail.

2. **Henkin-style proofs** are designed around fresh witness construction - the witness doesn't need to be in any pre-existing chain.

3. **Filtration techniques** (mentioned by Blackburn et al.) are used when canonical models are too large - they quotient the model but preserve truth. This might be an alternative approach.

4. **Step-indexed models** in programming language semantics face similar "freshness" vs "composition" tensions when dealing with recursive types and logical relations.

## Recommended Approaches

### Approach A: Accept CanonicalMCS as Primary Domain (HIGH CONFIDENCE)

The `CanonicalFMCS` construction is **sorry-free** and mathematically sound. The codebase should:
1. Use `CanonicalMCS` as the primary domain for completeness proofs
2. The Int-indexed chain is useful for computational/decidability purposes but not for completeness
3. If Int is needed, transfer via embedding/retraction as secondary

**Implementation**: Already done in `CanonicalFMCS.lean`

### Approach B: Multi-Family Bundle with Per-Obligation Witnesses (MEDIUM CONFIDENCE)

Instead of a single chain, use a **bundle of chains** where each F/P obligation can spawn a new chain/family:

1. Primary family contains the original chain
2. Each F-obligation spawns a witness family containing the witness MCS
3. The BFMCS bundles all families together
4. Truth lemma works across families

**Implementation**: Partially supported by `ModalSaturation.lean`

### Approach C: Omega-Squared with Position Reservation (LOW CONFIDENCE)

Modify the dovetailing to **reserve positions** before constructing witnesses:

1. At step (n, k), reserve position t' = f(n, k) for the potential witness
2. Build chain incrementally, leaving gaps at reserved positions
3. When witness W is constructed, place it at its reserved position
4. Prove no collisions via dovetailing properties

**Challenge**: This requires significant new infrastructure and careful proof of collision-freedom.

## Confidence Level

**HIGH** for the mathematical analysis:
- The F-persistence failure is a genuine, deep mathematical issue
- The asymmetry between G and F in temporal logic is fundamental
- The "all-MCS" approach (CanonicalFMCS) is the mathematically correct solution

**MEDIUM** for recommended approaches:
- Approach A is already implemented and working
- Approach B aligns with existing ModalSaturation infrastructure
- Approach C is speculative and would require substantial new work

## Conclusion

The F-formula persistence problem in linear chain constructions is a **fundamental mathematical limitation**, not an implementation gap. The codebase already has the correct solution in `CanonicalFMCS.lean`. Tasks requiring Int-indexed domains should either:
1. Accept the sorries with documented understanding of the limitation
2. Use domain transfer from CanonicalMCS to Int (if bijection can be established)
3. Restructure to not require Int-indexed chains for completeness

The literature uniformly uses all-MCS domains for temporal/tense logic completeness proofs, validating the approach taken in `CanonicalFMCS.lean`.

## References

- [Goldblatt 1992 - Logics of Time and Computation](https://www.cambridge.org/core/books/modal-logic/completeness/7CF04A550F7C253C42C16007CB7A5554)
- [Blackburn, de Rijke, Venema 2001 - Modal Logic, Chapter 4: Completeness](https://www.cambridge.org/core/books/modal-logic/F7CDB0A265026BF05EAD1091A47FCF5B)
- [Hughes & Cresswell 1996 - A New Introduction to Modal Logic](https://www.routledge.com/A-New-Introduction-to-Modal-Logic/Cresswell-Hughes/p/book/9780415126007)
- [Open Logic Project - Completeness and Canonical Models](https://builds.openlogicproject.org/content/normal-modal-logic/completeness/completeness.pdf)
- [Venema - Temporal Logic (Handbook Chapter)](https://staff.science.uva.nl/y.venema/papers/TempLog.pdf)
- [Stanford Encyclopedia of Philosophy - Temporal Logic](https://plato.stanford.edu/entries/logic-temporal/)
- [CMU Lecture Notes on Modal Completeness](https://www.cs.cmu.edu/~fp/courses/15816-s10/lectures/20-complete.pdf)
