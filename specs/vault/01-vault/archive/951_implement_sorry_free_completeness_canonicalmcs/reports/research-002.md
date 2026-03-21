# Research Report: Task #951 (research-002) -- Antisymmetrization Approach

**Task**: 951 - Implement sorry-free completeness via CanonicalMCS domain
**Started**: 2026-02-27
**Session**: sess_1740672100_r951b
**Effort**: High (deep analysis of 8 archived reports + codebase + Mathlib infrastructure)
**Dependencies**: Task 945 research (8 reports), CanonicalFMCS.lean, CanonicalFrame.lean, DovetailingChain.lean, TemporalCoherentConstruction.lean, Representation.lean, Validity.lean
**Sources/Inputs**: All 8 archived task 945 reports (research-001 through research-006, teammate-a, teammate-b), codebase analysis, Mathlib Antisymmetrization API
**Artifacts**: This report
**Standards**: report-format.md, return-metadata-file.md

---

## Executive Summary

- The user rejects the "trivial all-MCS domain" recommendation from research-001 as dishonest, requesting instead the **antisymmetrization approach** documented in task 945's research-003 and research-004.
- After thorough analysis of all 8 archived reports, the antisymmetrization approach emerges as a **conceptually correct framework** for understanding the canonical model, but faces specific obstacles that prior research already identified.
- The core mathematical idea: CanonicalMCS elements (MCSes) are **world-states**, not times. Times emerge as **equivalence classes within maximal chains** under the CanonicalR preorder. The `Antisymmetrization` quotient of a chain yields a `LinearOrder`, representing the time structure.
- The **fundamental obstacle** (identified in research-004 Section 2.4): an arbitrary Lindenbaum witness for an F-obligation is not guaranteed to lie within a pre-existing maximal chain. This blocks the naive "take a maximal chain, antisymmetrize" approach.
- The **resolution path** (from research-003 Section 9-13): instead of taking an arbitrary maximal chain via Zorn, **construct the chain incrementally** by dovetailing F/P-witness insertions. Each witness is an independent Lindenbaum MCS that is added to the chain without modifying existing elements. The linearity axiom ensures mutual comparability of witnesses from the same MCS.
- This "dovetailing over CanonicalMCS" approach avoids the GContent-corruption failure mode of the Int-indexed DovetailingChain (research-001 Section 3), because each chain element is a fixed, independent MCS.
- **Feasibility assessment**: The approach is mathematically viable and provides a non-trivial time representation. The main risk is that the linearity axiom may not guarantee comparability of witnesses from DIFFERENT chain elements (research-003 Section 9). This requires careful analysis and potentially an enriched seed construction.
- **Mathlib infrastructure**: `Antisymmetrization`, `IsMaxChain`, `instPartialOrderAntisymmetrization` all exist. The `LinearOrder` instance for Antisymmetrization of a total preorder requires `DecidableLE` (resolvable via `Classical.dec`).

---

## 1. Analysis of Task 945 Reports

### 1.1 Report Progression

The 8 reports tell a clear story of progressive refinement:

| Report | Key Contribution |
|--------|-----------------|
| research-001 (synthesis) | Identified the single blocking sorry (`fully_saturated_bfmcs_exists_int`). Recommended FMP bypass. |
| teammate-a | Deep sorry inventory. Identified the IH cross-dependency forcing temporal coherence on ALL families. |
| teammate-b | Structural analysis: sequential vs parallel witness construction. Proposed (and rejected) selection function approach. |
| research-002 | User rejects FMP bypass. Analyzed bottom-up recursive unraveling and top-down canonical MCS approaches. |
| research-003 | **Key report**: Introduced the antisymmetrization idea. Distinguished times from states. Proposed dovetailing over CanonicalMCS. |
| research-004 | Detailed evaluation of Antisymmetrization approach. Identified the witness-inclusion problem. Concluded that Antisymmetrization is conceptually correct but operationally superseded by dovetailing. |
| research-005 | Fresh start from first principles. Established that D = Z is correct for completeness. Step-by-step construction method. |
| research-006 | Proved `bmcs_truth_at` is redundant; direct `truth_at` proof is cleaner. Identified that `task_rel` does not appear in `truth_at`. |

### 1.2 The Antisymmetrization Idea (research-003 Sections 4-7)

The core mathematical framework:

1. **CanonicalMCS elements are world-states, not times.** An MCS describes "what the world looks like" -- a maximal consistent description. A time is a position in a linear ordering.

2. **Maximal chains in CanonicalMCS under CanonicalR represent temporal unfoldings.** A chain C = {M_alpha} is a totally preordered subset where `GContent(M_alpha) subset M_beta` for alpha <= beta.

3. **The Antisymmetrization quotient T_C = Antisymmetrization C CanonicalR** produces equivalence classes of mutually CanonicalR-accessible MCSes. Within a chain, this quotient has a `LinearOrder` (by Mathlib).

4. **MCSes in the same equivalence class** agree on all G-formulas but may differ on other formulas. These represent different world-states at the same time -- this is the **modal diversity** that the bundle captures.

5. **The linearity axiom** (`F(phi) /\ F(psi) -> F(phi /\ psi) \/ F(phi /\ F(psi)) \/ F(F(phi) /\ psi)`) ensures that F-witnesses from any single MCS are mutually comparable, preventing branching within chains.

### 1.3 Why "Trivial All-MCS" Is Not Honest

The user's critique is that research-001's recommendation (use CanonicalMCS as the time domain directly) conflates two fundamentally different concepts:

- **CanonicalMCS as a Preorder** works for the BFMCS machinery (which only needs `[Preorder D] [Zero D]`).
- **Standard validity** requires `D` to be a `LinearOrderedAddCommGroup`.
- Using CanonicalMCS as the time domain sidesteps the problem rather than solving it: the identity family `fam.mcs(w) = w.world` gives "temporal coherence" only because the time-state coupling makes the coherence conditions definitionally trivial. But this makes modal saturation impossible (research-004 Section 5).

The honest approach is to construct a non-trivial temporal ordering where times are DISTINCT from world-states, and world-histories are functions from times to states. The antisymmetrization framework provides exactly this conceptual structure.

---

## 2. Mathematical Foundation: How Antisymmetrization Creates Non-Trivial Time

### 2.1 The Quotient Construction

Given a maximal chain C in (CanonicalMCS, CanonicalR):

```
T_C := Antisymmetrization C (fun x y => x <= y)
```

Two chain elements M, M' are identified iff `CanonicalR M.world M'.world` AND `CanonicalR M'.world M.world`, i.e., `GContent(M.world) subset M'.world` and `GContent(M'.world) subset M.world`. This means M and M' agree on all G-formulas.

Each equivalence class [M] in T_C represents a **moment in time**. Multiple MCSes in the same class represent different **possible world-states** at that moment. An FMCS over T_C assigns a representative MCS to each moment.

### 2.2 Why This Is Non-Trivial

Unlike the identity mapping over CanonicalMCS (where each "time" IS an MCS):

- **Different families can assign different MCSes to the same time-moment.** The eval family picks one representative per equivalence class; a witness family can pick a different one (as long as the choice satisfies coherence conditions).
- **The temporal ordering is genuinely linear**, arising from the chain structure plus linearity axiom, not from the subset ordering on formulas.
- **Forward_F creates genuine future times.** An F-witness W is a new MCS that may define a new equivalence class (a new moment not previously in the chain), rather than being identified with an existing moment.

### 2.3 The Group Structure Problem

T_C is a `LinearOrder` but NOT a group. The standard semantics requires `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`.

Research-004 analyzed this thoroughly (Section 3) and identified three options:
- **B1**: Give T_C group structure (not viable -- no natural addition on MCS equivalence classes)
- **B2**: Embed T_C into Q via `Order.embedding_from_countable_to_dense` (viable but complex)
- **B3**: Build BFMCS at the Preorder level, bridge to standard semantics separately (cleanest)

Research-005 resolved this definitively: **D = Z is correct for completeness.** The completeness theorem only needs to exhibit ONE model where a consistent formula is satisfied. A Z-indexed model suffices. The chain construction produces a countable structure naturally indexed by Z.

---

## 3. The Key Obstacle: Witness Inclusion

### 3.1 The Problem (research-004 Section 2.4)

Given a chain C and an MCS M in C with `F(phi) in M.world`:
- `canonical_forward_F` gives witness W with `CanonicalR M.world W` and `phi in W`.
- For `forward_F` over the Antisymmetrized chain, we need [W] >= [M] in T_C.
- This requires W to be in C (or at least comparable with all elements of C).
- An arbitrary Lindenbaum witness W is NOT guaranteed to be in C or comparable with all chain elements.

### 3.2 Why Zorn's Maximal Chains Don't Help

A maximal chain C (from Zorn's lemma) is maximal in the sense that no element can be added while maintaining the chain property. But this does NOT mean every CanonicalR-successor of a chain element is in C. If W is not comparable with some N in C (neither `CanonicalR W N` nor `CanonicalR N W`), then W cannot be added to C.

### 3.3 The Linearity Axiom's Scope

The linearity axiom ensures that F-witnesses from THE SAME MCS are mutually comparable. But it does NOT ensure:
- An arbitrary Lindenbaum witness is comparable with ALL chain elements
- F-witnesses from DIFFERENT chain elements are mutually comparable without additional construction

### 3.4 The Resolution: Construct the Chain to Include All Witnesses

Research-003 Section 9-13 proposes the solution: instead of taking an arbitrary maximal chain, **construct the chain incrementally** via dovetailing.

**Construction outline** (from research-003 Section 10):

1. Start with M_0 (root MCS from Lindenbaum extension of Gamma).
2. Process F-obligations from M_0: for each `F(phi) in M_0`, construct witness W via `canonical_forward_F`. Add W to the chain.
3. The linearity axiom ensures witnesses from M_0 are mutually comparable, so they form a chain.
4. Process F-obligations from each newly added MCS, recursively.
5. Process P-obligations backward from M_0 via `canonical_backward_P`.
6. Dovetail to ensure ALL obligations from ALL constructed MCSes are eventually witnessed.

**Why this avoids the DovetailingChain failure mode** (research-003 Section 10, research-004 Section 8):

The Int-indexed DovetailingChain fails because `M_{n+1}` is constructed by Lindenbaum from `GContent(M_n)`, and the Lindenbaum extension can introduce `G(neg(psi))` which kills the F-obligation `F(psi)` from M_n. In the CanonicalMCS-based chain:

- Each MCS is an **independent** Lindenbaum extension that is FIXED after construction.
- The chain grows by ADDING new MCSes, not by modifying existing ones.
- Previous F-witnesses are never corrupted because they are in fixed, immutable MCSes.
- The F-witness W for `F(phi) in M` is constructed from `{phi} union GContent(M)`, which is proven consistent by `forward_temporal_witness_seed_consistent`.

---

## 4. Codebase Infrastructure

### 4.1 Existing Sorry-Free Infrastructure

| Module | Key Content | Relevance |
|--------|-------------|-----------|
| `CanonicalFrame.lean` | `CanonicalR`, `canonical_forward_F`, `canonical_backward_P`, reflexivity, transitivity | Core witness existence (sorry-free) |
| `CanonicalFMCS.lean` | `canonicalMCSBFMCS`, `canonicalMCS_forward_F/backward_P`, `temporal_coherent_family_exists_CanonicalMCS` | Sorry-free single-family temporal coherence over all MCS |
| `TruthLemma.lean` | `bmcs_truth_lemma` | Sorry-free for all 6 cases (parametric in D) |
| `ModalSaturation.lean` | `saturated_modal_backward` | Sorry-free modal backward from saturation |
| `Representation.lean` | Standard completeness chain | Sorry-free given sorry-free BFMCS construction |

### 4.2 The Blocking Sorry

```lean
-- TemporalCoherentConstruction.lean:580-600
theorem fully_saturated_bfmcs_exists_int (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    exists (B : BFMCS Int),
      (forall gamma in Gamma, gamma in B.eval_family.mcs 0) /\
      B.temporally_coherent /\
      is_modally_saturated B := by
  sorry
```

### 4.3 Existing Antisymmetrization in Codebase

No existing usage of `Antisymmetrization` in the Lean source (`Theories/`). The concept appears only in archived research reports and the ROAD_MAP Dead End for CanonicalReachable/CanonicalQuotient.

The previous CanonicalQuotient attempt (Dead End) used `Antisymmetrization` on the FUTURE-REACHABLE subset, which failed because backward_P witnesses are not future-reachable. The proposed approach uses `Antisymmetrization` on a CONSTRUCTED chain that includes both forward and backward witnesses by design.

### 4.4 Mathlib Infrastructure

| Mathlib Entity | Module | Status |
|----------------|--------|--------|
| `Antisymmetrization alpha r` | `Mathlib.Order.Antisymmetrization` | Full API: `toAntisymmetrization`, `ofAntisymmetrization`, `ind`, `induction_on` |
| `instPartialOrderAntisymmetrization` | same | Provides `PartialOrder` on Antisymmetrization |
| LinearOrder instance | same | Available when `DecidableLE`, `DecidableLT`, `IsTotal` hold (use `Classical.dec`) |
| `IsMaxChain` | `Mathlib.Order.Preorder.Chain` | `isChain`, `not_superChain`, `bot_mem`, `top_mem` |
| `Order.embedding_from_countable_to_dense` | `Mathlib.Order.CountableDenseLinearOrder` | Countable linear order embeds into any dense nontrivial linear order |

---

## 5. Feasibility Assessment

### 5.1 What the Antisymmetrization Approach Provides

1. **Conceptual clarity**: Times are distinct from states. The time structure is a linear order derived from the chain structure of MCSes. This is mathematically principled.

2. **Non-trivial time representation**: Unlike the trivial all-MCS identity mapping, different families can assign different MCSes to the same time-moment, enabling modal diversity.

3. **Sorry-free temporal coherence pathway**: If the chain is constructed to include all F/P witnesses (via dovetailing), then forward_F and backward_P hold by construction.

4. **Compatibility with standard semantics**: The chain, once constructed, is indexed by Z (integers). The Antisymmetrization quotient is conceptual scaffolding; the operational construction directly produces a Z-indexed chain.

### 5.2 The Central Mathematical Question

**Can we prove that all constructed witnesses are mutually comparable (forming a chain)?**

For witnesses from the SAME MCS M:
- The linearity axiom `F(phi) /\ F(psi) -> F(phi /\ psi) \/ F(phi /\ F(psi)) \/ F(F(phi) /\ psi)` guarantees that witnesses for `F(phi)` and `F(psi)` can be ordered.
- Specifically, by case analysis on the linearity axiom, either both can be witnessed simultaneously, or one comes before the other.
- This is proven sound and the argument is standard (Goldblatt 1992, Venema 2001).

For witnesses from DIFFERENT MCSes in the chain:
- If M < N in the chain (i.e., CanonicalR M N) and W is a witness for `F(phi) in M`, we need W to be comparable with N.
- Since CanonicalR M W (by construction) and CanonicalR M N (by chain ordering), the question is whether W and N are CanonicalR-comparable.
- **This is NOT automatic from the linearity axiom alone.** It requires either:
  (a) An enriched seed construction where W is built to be compatible with N, or
  (b) A careful ordering of witness processing to ensure newly added witnesses respect existing chain structure.

### 5.3 Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Witnesses from different chain MCSes not comparable | Medium | High | Enriched seed including GContent of chain successors |
| Dovetailing over countably many obligations not terminating | Low | Medium | Standard omega-squared argument; each obligation processed in finite steps |
| Linearity axiom insufficient for full chain construction | Medium | High | This is the central open question; resolved positively in standard literature (Goldblatt, Venema) |
| Formalization complexity exceeds estimates | Medium | Medium | Prototype key lemmas before full construction |
| Modal saturation for non-identity families over constructed chain | Medium | High | Each diamond witness family is a separate dovetailed chain (same construction) |

### 5.4 Estimated Effort

Following the research-004 analysis (Section 8) and research-005:

- **Phase 1**: Construct the dovetailed chain over CanonicalMCS (Z-indexed), proving forward_G/backward_H and forward_F/backward_P: **15-25 hours**
- **Phase 2**: Multi-family construction for modal saturation (separate chains for diamond witnesses): **10-15 hours**
- **Phase 3**: Prove temporal coherence and modal saturation for the bundle: **5-10 hours**
- **Phase 4**: Eliminate the sorry in `fully_saturated_bfmcs_exists_int`: **5-10 hours**

**Total estimate**: 35-60 hours, success probability 55-70%.

---

## 6. Comparison with Alternatives

### 6.1 Trivial All-MCS Domain (research-001 recommendation, REJECTED)

- **What**: Use CanonicalMCS as D, identity family as eval family.
- **Temporal coherence**: Trivially sorry-free.
- **Modal saturation**: IMPOSSIBLE (Section 1.3 above, research-004 Section 5).
- **Standard validity**: Cannot instantiate `valid` at D = CanonicalMCS (not a group).
- **Verdict**: Mathematically incomplete. Does not produce a sorry-free `BFMCS Int`.

### 6.2 Antisymmetrization / Dovetailing over CanonicalMCS (THIS APPROACH)

- **What**: Construct Z-indexed chain through CanonicalMCS via dovetailing, using independent Lindenbaum witnesses.
- **Temporal coherence**: Proven via dovetailing (each F/P obligation eventually witnessed).
- **Modal saturation**: Via separate chains for diamond witnesses.
- **Standard validity**: Z-indexed chain maps directly to `BFMCS Int`.
- **Key advantage**: Avoids GContent-corruption failure mode of DovetailingChain.
- **Key risk**: Comparability of witnesses from different chain elements.
- **Verdict**: Most promising path to honest sorry-free completeness.

### 6.3 Int-Indexed DovetailingChain (current approach, 2 SORRIES)

- **What**: Build chain `M_0, M_1, M_{-1}, M_2, ...` where each step extends via GContent.
- **Temporal coherence**: 2 sorries (forward_F, backward_P) due to GContent truncation.
- **Modal saturation**: Combined with Zorn extension (separate sorry).
- **Standard validity**: Direct `BFMCS Int`.
- **Verdict**: Has structural obstacles that 12+ attempts failed to resolve.

### 6.4 FMP Strong Completeness via bigAnd (research-001 alternative)

- **What**: Extend sorry-free FMP weak completeness to strong completeness.
- **Status**: FMP infrastructure archived to Boneyard (Task 948) due to non-standard validity.
- **Verdict**: Would need resurrection and equivalence proof. Not the approach the user wants.

---

## 7. Recommended Implementation Path

### Step 1: Define the Dovetailed CanonicalMCS Chain

Define a new module (e.g., `CanonicalChain.lean`) that constructs a Z-indexed chain through CanonicalMCS:

```
chain(0) = M_0  (root MCS from Lindenbaum)
chain(n+1) = Lindenbaum({phi_n} union GContent(chain(n)))
   where phi_n is the next F-obligation to witness (via dovetailing enumeration)
chain(-n-1) = Lindenbaum({psi_n} union HContent(chain(-n)))
   where psi_n is the next P-obligation to witness
```

Key properties to prove:
- `CanonicalR chain(n) chain(n+1)` for all n >= 0 (by GContent inclusion in seed)
- `CanonicalR chain(-n-1) chain(-n)` for all n >= 0 (by HContent/GContent duality)
- `forward_F`: every F-obligation eventually witnessed (by dovetailing enumeration)
- `backward_P`: every P-obligation eventually witnessed (by dovetailing enumeration)
- Each `chain(n)` is an MCS (by Lindenbaum)

### Step 2: Prove the Chain Is Temporally Coherent

The chain defines an `FMCS Int` where `mcs(t) = chain(t).world`. Prove:
- `forward_G`: from `CanonicalR chain(t) chain(s)` for t <= s (transitivity of CanonicalR)
- `backward_H`: from GContent/HContent duality
- `forward_F`: from dovetailing enumeration
- `backward_P`: from dovetailing enumeration

### Step 3: Build Multi-Family Bundle

For each diamond obligation `Diamond(psi) in chain(t).world`:
1. Construct witness MCS W from `{psi} union BoxContent(chain(t).world)` via Lindenbaum.
2. Build a separate Z-indexed chain through W at position t (same dovetailing construction).
3. This witness chain is itself temporally coherent (same argument as eval family).

### Step 4: Prove Modal Saturation and Eliminate Sorry

Combine the eval family chain with all witness family chains into a `BFMCS Int`. Prove:
- `modal_forward`: from BoxContent inclusion in diamond witness seeds
- Modal saturation: by construction (every diamond obligation has a witness family)
- `modal_backward`: from `saturated_modal_backward` (already sorry-free)

This eliminates the sorry in `fully_saturated_bfmcs_exists_int`.

### Step 5: Antisymmetrization as Conceptual Documentation

The Antisymmetrization quotient is the mathematical EXPLANATION of why the construction works:
- The Z-indexed chain corresponds to a section of the Antisymmetrization quotient of its image in CanonicalMCS.
- Each integer time t corresponds to the equivalence class [chain(t)] in the quotient.
- The linear ordering on Z reflects the linear ordering on the quotient.

This should be documented in a conceptual overview but does NOT need to be formalized in Lean for the sorry elimination.

---

## 8. Connection to the User's Question

The user asked for "a better way to construct a non-trivial representation of time and the task relation in the canonical model" using the antisymmetrization approach.

The antisymmetrization framework provides this:

1. **Non-trivial time**: Times are not MCSes -- they are equivalence classes of mutually CanonicalR-accessible MCSes within a constructed chain. The time structure (Z) is genuinely linear, arising from the chain structure and the linearity axiom.

2. **Non-trivial task relation**: The task relation connects world-states across durations. In the Z-indexed chain, `task_rel(chain(s).world, t-s, chain(t).world)` holds because `CanonicalR chain(s).world chain(t).world` for s <= t.

3. **Modal diversity**: Different families assign different MCSes to the same time point. The eval family uses the chain's own MCSes; witness families use independently constructed chains rooted at diamond witnesses.

4. **The linearity axiom's role**: The axiom ensures that the constructed chain is totally ordered -- it prevents branching. Without it, two F-witnesses from the same MCS might be incomparable, and the chain construction would fail.

This is fundamentally different from the "trivial" approach where CanonicalMCS IS the time domain and every MCS maps to itself. In the antisymmetrization approach, time emerges from the structure of the canonical model rather than being imposed externally.

---

## Obstacles and Open Questions

### Open Question 1: Cross-Element Comparability

Can we prove that a Lindenbaum witness W for `F(phi) in chain(n).world` is comparable with `chain(m)` for all m in the existing chain?

This is the central technical question. If W is constructed from `{phi} union GContent(chain(n))`, then `CanonicalR chain(n) W`. For m > n, we need either `CanonicalR W chain(m)` or `CanonicalR chain(m) W`. The linearity axiom does not directly address this.

**Potential resolution**: Use an enriched seed. Instead of `{phi} union GContent(chain(n))`, construct W from `{phi} union GContent(chain(n)) union GContent(chain(n-1)) union ...` to ensure W is consistent with the entire chain below n. But this risks inconsistency.

**Alternative resolution**: Process witness obligations in the dovetailing order such that W is placed as the NEXT element in the chain, and all subsequent elements are built from W's GContent. This is essentially what the dovetailing construction does: chain(n+1) is built from chain(n), so CanonicalR chain(n) chain(n+1) by construction.

### Open Question 2: Backward Witness Comparability

P-witnesses (for `P(phi) in chain(n).world`) require a witness W with `CanonicalR_past chain(n) W` (i.e., `HContent(chain(n)) subset W`). The duality lemma `HContent_subset_implies_GContent_reverse` gives `CanonicalR W chain(n)`, so W <= chain(n). But W must also be comparable with chain elements below n.

This is handled by the dovetailing construction: P-witnesses are placed at negative indices, extending the chain backward. The chain structure ensures comparability.

### Open Question 3: Omega-Squared Argument

The dovetailing must process ALL obligations from ALL chain elements. Since each chain element may introduce new F/P obligations, and each witness may introduce more, the process is potentially infinite. The standard omega-squared argument (enumerate pairs (position, obligation) and process them in order) guarantees that every obligation is eventually addressed.

This is a standard technique (Goldblatt 1992, Chapter 4) and should be formalizable, but it adds complexity.

---

## Decisions

1. The antisymmetrization approach is **conceptually correct and provides the honest non-trivial time structure** the user seeks.

2. The operational implementation is a **dovetailed chain construction over CanonicalMCS**, which implicitly realizes the antisymmetrization structure while producing a directly Z-indexed FMCS.

3. The **central technical risk** is proving comparability of witnesses from different chain elements. The construction mitigates this by building each chain element as a direct successor (via GContent inclusion) of the previous one.

4. **D = Z is the correct time domain** for the completeness proof. The antisymmetrization quotient is conceptual scaffolding that explains WHY Z works.

5. The approach should be implemented as a replacement for the sorry in `fully_saturated_bfmcs_exists_int`, NOT as a separate completeness module.

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Cross-element comparability fails | Medium | High | Build chain sequentially so each element is a direct CanonicalR-successor of the previous |
| Dovetailing enumeration complexity | Low | Medium | Standard omega-squared technique; well-documented in literature |
| Modal saturation for witness families | Medium | Medium | Each witness family is a separate chain; same construction as eval family |
| Formalization exceeds 60 hours | Medium | Medium | Prototype the chain construction and comparability lemma first |
| Linearity axiom insufficient | Low | High | Linearity is proven sufficient for step-by-step construction in standard tense logic literature |

---

## Appendix: Literature Support

The step-by-step construction for linear tense logic completeness is standard:

1. **Goldblatt (1992)**, *Logics of Time and Computation*, Chapter 4: Canonical models for tense logics. The step-by-step method builds a linear frame incrementally.

2. **Venema (2001)**, "Temporal Logic" in *Handbook of Philosophical Logic*: Completeness of Lin (Kt + linearity) via step-by-step construction.

3. **Gabbay, Hodkinson, Reynolds (1994)**, *Temporal Logic: Mathematical Foundations*, Volume 1: Comprehensive treatment including step-by-step method for various frame classes.

The key insight from this literature: the linearity axiom ensures that within any MCS, F-witnesses can be linearly ordered. The step-by-step construction uses this to build a chain where each new element is placed consistently with existing elements.
