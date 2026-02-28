# Research Report: Task #951 (research-003) -- Root Cause Analysis of F-Formula Non-Persistence

**Task**: 951 - Implement sorry-free completeness via CanonicalMCS domain
**Started**: 2026-02-27
**Session**: sess_1740672400_r951c
**Effort**: High (deep analysis of implementation blocker + all prior approaches)
**Dependencies**: research-001, research-002, implementation summary, 8 archived task 945 reports
**Sources/Inputs**: CanonicalChain.lean (857 lines), CanonicalFMCS.lean, CanonicalFrame.lean, DovetailingChain.lean, CanonicalEmbedding.lean (Boneyard), CanonicalReachable.lean (Boneyard), CanonicalQuotient.lean (Boneyard), TemporalContent.lean, FMCSDef.lean, TemporalCoherentConstruction.lean, Representation.lean, Validity.lean
**Artifacts**: This report
**Standards**: report-format.md

---

## 1. Executive Summary

The Phase 3 blocker in the CanonicalChain implementation is **confirmed as correctly diagnosed**: F-formula non-persistence through GContent seeds is the fundamental obstacle that makes `forward_F` unprovable for ANY linear chain construction over Int. This is not a limitations of tactics or proof strategy -- it is a mathematical impossibility inherent to the chain topology.

However, the claimed resolution path (canonical quotient/embedding into Int) has a critical gap: the **Boneyard CanonicalReachable approach was archived precisely because backward_P witnesses are not future-reachable**. The embedding approach works for forward_F but reopens the backward_P problem in a different form.

After thorough analysis, four viable solution paths emerge. The recommended approach is **Solution Path C: Bidirectional Reachable Fragment**, which constructs a full (forward AND backward) reachable fragment from the root, proves it is linearly ordered via the linearity axiom, and embeds it into Int. This avoids both the F-persistence problem (by operating at the CanonicalMCS level) and the backward_P reachability problem (by including past-reachable elements in the domain).

---

## 2. Root Cause Analysis: Why F-Formulas Don't Persist

### 2.1 The Mathematical Definition

```
GContent(M) = { phi | G(phi) in M }       -- "things true at all future times"
F(phi)      = neg(G(neg(phi)))             -- "phi at some future time"
```

GContent extracts exactly the formulas `phi` where `G(phi)` (the universal future quantifier) is in M. This is semantically "what must be true at every future time." The existential future operator `F(phi) = neg(G(neg(phi)))` is a NEGATION of a universal, so it has fundamentally different persistence behavior.

### 2.2 Why GContent Propagation Kills F-Formulas

When we build `chain(n+1) = Lindenbaum({witness} union GContent(chain(n)))`:

1. The seed contains GContent(chain(n)) = { phi | G(phi) in chain(n) }
2. Lindenbaum extends this to an MCS by adding formulas until maximal
3. During Lindenbaum extension, for any formula psi, either psi or neg(psi) is added
4. In particular, for formula `G(neg(phi))`, Lindenbaum may choose to add it
5. If `G(neg(phi))` is in chain(n+1), then `neg(G(neg(phi))) = F(phi)` is NOT in chain(n+1)

The key insight: **Lindenbaum extension is non-deterministic with respect to F-formulas**. The seed (GContent + witness) constrains which G-formulas must be in the result, but says nothing about which F-formulas survive. The Lindenbaum lemma gives you A maximal consistent extension, but you cannot control WHICH one you get.

### 2.3 Why the Linearity Axiom Does Not Fix This

The linearity axiom is:
```
F(phi) /\ F(psi) -> F(phi /\ psi) \/ F(phi /\ F(psi)) \/ F(F(phi) /\ psi)
```

This constrains the ORDERING of F-witnesses: if both F(phi) and F(psi) hold at M, then there exist witnesses that can be linearly ordered. But it does NOT constrain Lindenbaum extensions:

- The linearity axiom is about the MEMBERSHIP of F-formulas in a single MCS
- Lindenbaum extension creates a NEW MCS from a seed
- The seed (GContent) does not contain F-formulas, so the linearity axiom cannot prevent the new MCS from losing them

This is explicitly confirmed in the Boneyard CanonicalEmbedding.lean (lines 67-78):
```
-- **Linearity doesn't fix persistence**: The temp_linearity axiom constrains
-- models semantically but does not prevent Lindenbaum from making choices that
-- kill F-obligations.
```

### 2.4 The Structural Nature of the Problem

The problem is not about a specific proof technique failing. It is structural:

- A linear chain `chain(0), chain(1), chain(2), ...` where `GContent(chain(n)) subset chain(n+1)` is a **monotone sequence under CanonicalR**
- CanonicalR is defined as GContent inclusion, which only tracks G-formulas
- F-formulas are existential (negations of universal), so they are NOT monotone under GContent
- Therefore, NO property of F-formulas can be derived from the chain's ordering invariant alone

The enriched chain construction (Phase 2) adds witness formulas to the seed. The `enrichedForwardStep_witness_placed` theorem proves: if `F(phi) in chain(n)` and `decodeFormula(n) = some phi`, then `phi in chain(n+1)`. But this only works at step n where phi is decoded. There is no mechanism to ensure `F(phi)` survives from its origin time `t` to the decoding step `encodeFormula(phi)`.

### 2.5 Why Prior Approaches Failed (Summary)

All 12+ chain-based attempts in DovetailingChain.lean failed for the same root cause. Documented non-starters include:

| Approach | Why It Fails |
|----------|-------------|
| Enriched linear chain | F-formulas don't persist through GContent seeds |
| Witness-graph-guided chain | DAG has local GContent propagation only, not universal |
| Constant family oracle | F(psi) in M doesn't imply psi in M |
| Two-timeline embedding | Nodes reachable by both directions conflict |
| Tree unraveling | Destroys inverse relation for past operators |
| Omega-squared chain (same topology) | Same GContent propagation, same F-kill problem |

---

## 3. Analysis of the Proposed Resolution Path

### 3.1 What Was Proposed

The implementation summary proposes:
1. Use `canonicalMCS_forward_F` (trivially sorry-free at CanonicalMCS level)
2. Use `canonical_reachable_linear` (linearity of the reachable fragment)
3. Embed the linearly-ordered reachable fragment into Int
4. Pull back the FMCS to get FMCS Int with forward_F

### 3.2 The Backward_P Gap

This proposal has a critical gap that caused the CanonicalReachable approach to be archived in the first place (Task 933):

- **CanonicalReachable** is the set of MCSes `W` where `CanonicalR M_0 W` (future-reachable from root)
- `canonical_backward_P` gives a witness `W` where `CanonicalR_past M W` (i.e., `HContent(M) subset W`)
- For W to be in CanonicalReachable, we need `CanonicalR M_0 W` (i.e., `GContent(M_0) subset W`)
- There is NO derivation from `HContent(M) subset W` to `GContent(M_0) subset W`
- The G and H modalities are independent: `G(phi) in M_0` does NOT imply `H(phi) in M`

This is why `CanonicalReachable.lean`, `CanonicalQuotient.lean`, and `CanonicalEmbedding.lean` were all archived to the Boneyard under Task 933.

### 3.3 Is This Gap Fixable?

The gap is fixable by expanding the domain from "future-reachable from M_0" to "bidirectionally reachable from M_0" (forward OR backward). See Solution Path C below.

---

## 4. Why CanonicalFMCS.lean Works (and What It Cannot Do)

### 4.1 What Works

`CanonicalFMCS.lean` provides sorry-free temporal coherence over **all MCSes** (the `CanonicalMCS` type):

```lean
-- Forward F: trivially, the witness MCS is in CanonicalMCS by construction
theorem canonicalMCS_forward_F (w : CanonicalMCS) (phi : Formula)
    (h_F : F(phi) in canonicalMCS_mcs w) :
    exists s : CanonicalMCS, w <= s /\ phi in canonicalMCS_mcs s

-- Backward P: symmetric
theorem canonicalMCS_backward_P ...
```

These are sorry-free because in the all-MCS domain, EVERY MCS is a valid domain element. The witness from `canonical_forward_F` is automatically in the domain.

### 4.2 What It Cannot Do

The standard validity definition requires `D` to be a `LinearOrderedAddCommGroup`:

```lean
def valid (phi : Formula) : Prop :=
  forall (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] ...
```

`CanonicalMCS` with its `CanonicalR` Preorder:
- Is NOT a group (no additive structure)
- Is NOT linearly ordered (only reachable MCSes from a common root are comparable)
- Is NOT even a partial order (CanonicalR is reflexive and transitive but not antisymmetric)

Therefore, `CanonicalMCS` cannot directly instantiate the `valid` definition. Any completeness proof must ultimately produce an `FMCS Int` (or similar group-time family) to bridge to standard validity.

### 4.3 The Two-Level Structure

The codebase has a clear two-level architecture:
1. **CanonicalMCS level**: Temporal coherence is trivial (forward_F, backward_P sorry-free)
2. **Int level**: Standard validity requires `FMCS Int`, which needs a chain construction (forward_F/backward_P are the blocking sorries)

The challenge is TRANSFERRING sorry-free coherence from level 1 to level 2.

---

## 5. Viable Solution Paths

### Solution Path A: Fix the Enriched Chain (REJECTED)

**Idea**: Modify the enriched chain construction so F-formulas persist.

**Why it fails**: F-formula persistence through GContent seeds is a mathematical impossibility, not a proof gap. No modification of the chain construction can fix this while maintaining the `CanonicalR chain(n) chain(n+1)` ordering invariant, because CanonicalR IS GContent inclusion, and GContent does not include F-formulas.

**Verdict**: Mathematically impossible. Do not attempt.

### Solution Path B: Generalize `valid` to Preorder (RISKY)

**Idea**: Define `valid_preorder` that quantifies over `[Preorder D]` instead of `[LinearOrderedAddCommGroup D]`, then prove completeness for CanonicalMCS as D.

**Analysis**:
- Soundness for Preorder time: The T-axiom (`G phi -> phi`) requires reflexivity (Preorder has it). The 4-axiom (`G phi -> GG phi`) requires transitivity (Preorder has it). The F-axiom definition just uses negation. So far, so good.
- BUT: The `time_shift_preserves_truth` lemma in Soundness uses `AddCommGroup` for the shift operation (`time_shift tau d`). The `ShiftClosed Omega` condition also requires additive group structure. This would break.
- The TF/MF modal-temporal interaction axioms (`Box phi -> G(Box phi)`) require that the modal accessibility relation is time-invariant. In a Preorder model, this holds by construction but the time-shift machinery needed for soundness relies on group structure.

**Risk**: High. Would require restructuring the soundness proof, which is currently sorry-free. Changing `valid` affects the entire system's foundational definitions.

**Verdict**: Not recommended without extensive soundness analysis first. Would change the paper specification.

### Solution Path C: Bidirectional Reachable Fragment (RECOMMENDED)

**Idea**: Instead of using only future-reachable MCSes (which excludes backward_P witnesses), use the **bidirectional reachable fragment**: all MCSes reachable from M_0 via any finite chain of CanonicalR steps in either direction.

**Construction**:

1. Define `BidirectionalReachable(M_0)` as the set of MCSes W where there exists a finite chain:
   ```
   M_0 = N_0, N_1, ..., N_k = W
   ```
   where each consecutive pair satisfies CanonicalR(N_i, N_{i+1}) OR CanonicalR(N_{i+1}, N_i).

   Equivalently: the transitive-symmetric-reflexive closure of CanonicalR, restricted to start from M_0.

2. Prove `BidirectionalReachable(M_0)` is linearly ordered under CanonicalR:
   - All elements are related to M_0 via a path
   - The linearity axiom ensures that any two elements reachable from a common ancestor are comparable (`canonical_reachable_linear` from CanonicalEmbedding.lean)
   - Need to extend this: elements reachable via past-then-future paths are also comparable (this requires careful argument using the linearity axiom for past-direction elements too)

3. Forward_F within BidirectionalReachable:
   - Given W in BidirectionalReachable and F(phi) in W, `canonical_forward_F` gives witness W' with CanonicalR(W, W')
   - W' is bidirectionally reachable from M_0 (via: M_0 reaches W, then W reaches W')
   - So W' is in the domain

4. Backward_P within BidirectionalReachable:
   - Given W in BidirectionalReachable and P(phi) in W, `canonical_backward_P` gives witness W' with CanonicalR_past(W, W')
   - By duality, CanonicalR(W', W), so W' is reachable from W in the backward direction
   - W is reachable from M_0, so W' is bidirectionally reachable from M_0
   - So W' is in the domain

5. The BidirectionalReachable fragment has a total Preorder (from step 2). Apply `Antisymmetrization` to get a `LinearOrder`. This linear order is countable (the fragment is generated from a countable set of formulas).

6. Embed the countable linear order into Int. Use Mathlib's `Order.embedding_from_countable_to_dense` to embed into Q, then transfer to Int (or use a direct countable-to-Int embedding for discrete orders).

7. Pull back the FMCS along the embedding to get `FMCS Int` with forward_F and backward_P.

**Key technical challenge**: Proving that BidirectionalReachable is totally ordered. The existing `canonical_reachable_linear` (Boneyard CanonicalEmbedding.lean, lines 290-383) proves that any two elements reachable via CanonicalR from a COMMON ROOT are comparable. For the bidirectional fragment, we need a stronger result: elements reachable via mixed forward/backward paths from M_0 are also comparable.

**Why this should work**: The linearity axiom constrains the temporal frame to be linear. In the standard completeness proof (Goldblatt 1992), the canonical model for the linearity axiom has a linearly ordered frame. The bidirectional reachable fragment from any world in a linear frame is itself linear.

**Estimated effort**: 40-60 hours.

**Infrastructure available**:
- `canonical_reachable_linear` (Boneyard, proven, 94 lines) - needs generalization to bidirectional
- `canonical_forward_F`, `canonical_backward_P` (CanonicalFrame.lean, proven)
- `canonicalMCS_forward_F`, `canonicalMCS_backward_P` (CanonicalFMCS.lean, proven)
- `Antisymmetrization` (Mathlib, full API)
- `CanonicalReachable`, `CanonicalQuotient` (Boneyard, proven infrastructure to adapt)

**Infrastructure needed**:
- `BidirectionalReachable` type definition
- Totality proof for bidirectional fragment (generalize `canonical_reachable_linear`)
- Countability proof for the fragment
- Embedding into Int (via Mathlib)
- FMCS pullback along embedding
- BFMCS construction combining temporal coherence + modal saturation

### Solution Path D: Direct CanonicalMCS Completeness with Domain Reindexing

**Idea**: Prove completeness at the CanonicalMCS level (where everything is sorry-free), then reindex to Int.

**Construction**:

1. Build `BFMCS CanonicalMCS` using `canonicalMCSBFMCS` as the eval family, with modal saturation via constant witness families (each diamond witness gets a constant family at its MCS).

2. Prove the truth lemma for `BFMCS CanonicalMCS`:
   ```
   phi in fam.mcs w <-> truth_at_preorder model omega tau w phi
   ```
   where `truth_at_preorder` is a version of `truth_at` that uses Preorder semantics (G = forall s >= w, H = forall s <= w).

3. Define a reindexing map `f : Int -> CanonicalMCS` that is order-preserving. The bidirectional reachable fragment (from Solution Path C) provides this via the embedding.

4. Pull back the `BFMCS CanonicalMCS` along f to get `BFMCS Int`.

5. The truth lemma transfers along the pullback.

**Analysis**: This is essentially Solution Path C but decomposed differently. The core challenge (embedding a countable linear fragment of CanonicalMCS into Int) is the same. The advantage is that the truth lemma at the CanonicalMCS level might be simpler to state and prove.

**Disadvantage**: Requires defining `truth_at_preorder` and showing it agrees with standard `truth_at` when D has group structure. This adds significant infrastructure.

**Verdict**: Viable but more complex than Solution Path C. The extra abstraction layer (Preorder truth) adds work without clear benefit.

### Solution Path E: Monotone Enumeration Chain (Novel Approach)

**Idea**: Instead of a linear chain where GContent propagates, construct a chain where EACH STEP explicitly enumerates and resolves ALL pending F/P obligations from ALL prior steps. This is an "eager" rather than "lazy" witness placement.

**Construction**:

1. Start with root M_0 = Lindenbaum(Gamma).
2. At step n+1 (forward direction):
   - Collect ALL pending F-obligations: `{ F(phi) | F(phi) in chain(k) for some k <= n, phi not yet witnessed }`
   - For each pending obligation, include the witness formula in the seed
   - The seed is: `{phi_1, ..., phi_m} union GContent(chain(n))` where phi_1,...,phi_m are the witnesses for pending obligations
   - Prove seed consistency (requires: the conjunction of all witness formulas with GContent is consistent)

3. The critical challenge: proving that the seed `{phi_1,...,phi_m} union GContent(chain(n))` is consistent when m > 1. The `forward_temporal_witness_seed_consistent` lemma only handles ONE witness at a time.

**Analysis of seed consistency**:
- Each individual `{phi_i} union GContent(M)` is consistent (by `forward_temporal_witness_seed_consistent`, using `F(phi_i) in M`)
- But `{phi_1, phi_2} union GContent(M)` requires `F(phi_1) in M AND F(phi_2) in M`
- The linearity axiom gives us: `F(phi_1 /\ phi_2) \/ F(phi_1 /\ F(phi_2)) \/ F(F(phi_1) /\ phi_2)` is in M
- In the first case, `{phi_1, phi_2} union GContent(M)` is a SUBSET of `{phi_1 /\ phi_2} union GContent(M)`, which is consistent
- In other cases, the argument is more complex but follows from case analysis on the linearity disjunction

**Problem**: As the chain grows, the number of pending obligations grows unboundedly. At step n, there could be O(n) pending obligations. The seed consistency argument requires handling arbitrarily many simultaneous witnesses, which the linearity axiom does not directly support for more than 2 at a time.

**Potential fix**: Use induction on the number of witnesses. The linearity axiom handles pairs; iterate to handle finite sets. This is the standard "step-by-step" construction from Goldblatt (1992).

**Risk**: The inductive consistency argument for finite sets of witnesses may require auxiliary lemmas about F-formula conjunction that don't exist in the codebase.

**Estimated effort**: 30-50 hours (if the multi-witness seed consistency can be proven).

**Verdict**: Promising but untested. The multi-witness seed consistency is the key technical challenge. If it works, this avoids the embedding machinery of Solution Path C entirely.

---

## 6. Recommended Approach: Solution Path C (Bidirectional Reachable Fragment)

### 6.1 Justification

Solution Path C is recommended because:

1. **Mathematically principled**: It operates at the CanonicalMCS level where forward_F and backward_P are trivially sorry-free, then transfers to Int via a well-understood embedding.

2. **Avoids the root cause**: By not using a chain construction for forward_F/backward_P, it completely avoids the GContent F-kill problem.

3. **Builds on existing infrastructure**: The Boneyard contains proven infrastructure (`canonical_reachable_linear`, `CanonicalReachable`, `CanonicalQuotient`, `Antisymmetrization` usage) that can be adapted.

4. **Fixes the known gap**: The backward_P reachability problem (which killed the original CanonicalReachable approach) is solved by using bidirectional reachability.

5. **Standard mathematical technique**: The step-by-step construction for linear tense logic via bidirectional reachability is standard (Goldblatt 1992, Chapter 4; Gabbay, Hodkinson, Reynolds 1994).

### 6.2 Implementation Outline

**Phase A: Bidirectional Reachable Fragment**
- Define `BidirectionalReachable M_0` as the reflexive-transitive-symmetric closure of CanonicalR from M_0
- Prove basic properties: M_0 is in the fragment, forward_F/backward_P witnesses stay in the fragment
- Resurrect and adapt `CanonicalReachable` infrastructure from Boneyard
- Estimated: 8-12 hours

**Phase B: Linearity of Bidirectional Fragment**
- Prove that any two elements in `BidirectionalReachable M_0` are CanonicalR-comparable
- Key lemma: generalize `canonical_reachable_linear` to handle mixed forward/backward paths
- This requires: for elements W1, W2 both reachable from M_0 via bidirectional paths, prove CanonicalR(W1, W2) or CanonicalR(W2, W1)
- The proof strategy: trace back through the paths to find a common ancestor, then apply linearity
- Estimated: 10-15 hours (this is the hardest phase)

**Phase C: Quotient and Embedding**
- Apply `Antisymmetrization` to get LinearOrder on the quotient
- Prove countability (fragment generated from countable formula set)
- Embed into Int via Mathlib
- Estimated: 8-12 hours

**Phase D: FMCS Int Construction**
- Define `FMCS Int` via pullback along embedding
- Transfer forward_G, backward_H, forward_F, backward_P from CanonicalMCS to Int
- Estimated: 6-8 hours

**Phase E: BFMCS and Modal Saturation**
- Build BFMCS Int combining temporal coherent eval family with modally saturated witness families
- Each diamond witness family uses the same construction (bidirectional fragment + embedding)
- Eliminate `fully_saturated_bfmcs_exists_int` sorry
- Estimated: 8-12 hours

**Phase F: Bridge and Verification**
- Verify standard completeness theorems are sorry-free
- Update module exports
- Estimated: 3-5 hours

**Total estimate**: 43-64 hours

### 6.3 Key Technical Risk

The main risk is in Phase B: proving linearity of the bidirectional fragment. The existing `canonical_reachable_linear` proves comparability for elements reachable via FORWARD paths from a common root. The bidirectional case requires handling elements where one is reached by going backward from M_0:

Consider: M_0 reaches W1 via forward path, and M_0 reaches W2 via backward-then-forward path. We need W1 and W2 to be comparable. This should follow from the linearity axiom applied at the branching point, but the proof may require non-trivial case analysis.

**Mitigation**: Prototype Phase B before committing to full implementation. If the linearity proof fails, fall back to Solution Path E.

---

## 7. Implementation Implications

### 7.1 Impact on Existing Code

- `CanonicalChain.lean` (Phases 1-2): Remains valid infrastructure. The chain construction provides forward_G/backward_H and the enriched chain is useful for other purposes.
- `DovetailingChain.lean`: Forward_F and backward_P sorries remain (dead code once Solution Path C completes).
- `TemporalCoherentConstruction.lean`: The `fully_saturated_bfmcs_exists_int` sorry would be replaced.
- `Representation.lean`: No changes needed (already sorry-free given sorry-free BFMCS input).
- `Validity.lean`: No changes.

### 7.2 New Files Needed

- `Theories/Bimodal/Metalogic/Bundle/BidirectionalReachable.lean` - Fragment definition + linearity
- `Theories/Bimodal/Metalogic/Bundle/CanonicalEmbedding.lean` - Embedding into Int (resurrect + extend from Boneyard)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalCompleteness.lean` - BFMCS construction + sorry elimination

### 7.3 Boneyard Resurrection Candidates

The following Boneyard files contain proven infrastructure that should be resurrected and adapted:

| File | Key Content | What to Adapt |
|------|-------------|---------------|
| `CanonicalEmbedding.lean` | `canonical_reachable_linear`, `mcs_F_linearity`, `F_implies_G_P_F` | Generalize linearity to bidirectional; import proven lemmas |
| `CanonicalReachable.lean` | `CanonicalReachable` type, comparability, forward_F_strict | Extend to bidirectional reachability |
| `CanonicalQuotient.lean` | `Antisymmetrization` usage, `LinearOrder` instance | Adapt for bidirectional quotient |

---

## 8. Alternative: Solution Path E as Fallback

If Solution Path C fails at the linearity proof (Phase B), Solution Path E (monotone enumeration chain) provides a fallback. The key difference:

- Path C avoids chains entirely, operating at the abstract CanonicalMCS level
- Path E fixes the chain by resolving ALL obligations eagerly at each step

Path E requires proving multi-witness seed consistency:
```
{ phi_1, ..., phi_m } union GContent(M) is consistent
when F(phi_1), ..., F(phi_m) are all in M
```

This follows from the linearity axiom by induction on m, using the fact that the linearity axiom allows us to order witnesses and combine them. This argument is standard in the literature but would need to be formalized.

---

## 9. Decisions

1. **Root cause confirmed**: F-formula non-persistence through GContent seeds is the correct diagnosis. It is a mathematical impossibility, not a proof technique limitation.

2. **Proposed resolution has a gap**: The CanonicalReachable embedding approach fails for backward_P (past witnesses are not future-reachable). This was the reason for the original archival (Task 933).

3. **Bidirectional reachability resolves the gap**: Using the full bidirectional reachable fragment (forward AND backward from M_0) keeps all witnesses in the domain.

4. **Recommended approach**: Solution Path C (Bidirectional Reachable Fragment) with Solution Path E as fallback.

5. **Implementation plan needs revision**: The current plan's Phases 3-7 should be replaced with the Phase A-F outline from Section 6.2.

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Bidirectional linearity proof fails | Medium | High | Prototype Phase B first; fall back to Solution Path E |
| Embedding into Int is non-trivial for non-discrete orders | Medium | Medium | Use Mathlib's countable embedding infrastructure |
| Backward_P witnesses break linearity in bidirectional fragment | Low | High | Standard argument from Goldblatt 1992 should apply |
| Modal saturation requires temporal coherence for ALL families | Medium | Medium | Each family uses same bidirectional construction |
| Multi-witness seed consistency (Path E) is hard to formalize | Medium | Medium | Induction on linearity axiom; standard in literature |
| Integration with existing Representation.lean | Low | Low | Only need sorry-free `fully_saturated_bfmcs_exists_int` |

---

## Open Questions

1. **Bidirectional linearity**: Is `canonical_reachable_linear` straightforwardly generalizable to elements reached via mixed forward/backward paths? The existing proof uses `canonical_F_of_mem_successor` which requires a CanonicalR relationship to the common root. For backward-reachable elements, the relationship is CanonicalR in the opposite direction.

2. **Countability of the bidirectional fragment**: Is the bidirectional reachable fragment from M_0 countable? Since formulas are countable and MCSes are determined by their formula membership, this should follow from the countability of formulas.

3. **Order type of the bidirectional fragment**: Is the quotient order discrete (like Z), dense (like Q), or mixed? This affects which Mathlib embedding theorem to use.

4. **The past linearity axiom**: Does the logic include a past-direction linearity axiom (`P(phi) /\ P(psi) -> ...`) or does the future linearity axiom suffice for bidirectional linearity?

---

## Appendix: Sorry Inventory (Current State)

| File | Line | Theorem | Status |
|------|------|---------|--------|
| `TemporalCoherentConstruction.lean` | 580 | `fully_saturated_bfmcs_exists_int` | TARGET: eliminate via Solution Path C |
| `DovetailingChain.lean` | 1868 | `buildDovetailingChainFamily_forward_F` | Will become dead code |
| `DovetailingChain.lean` | 1880 | `buildDovetailingChainFamily_backward_P` | Will become dead code |

All downstream theorems (`standard_weak_completeness`, `standard_strong_completeness`, `canonical_truth_lemma`) are themselves sorry-free -- they only inherit sorry through `fully_saturated_bfmcs_exists_int`.
