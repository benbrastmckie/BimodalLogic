# Critical Path Review: Sorry-Free Completeness via Algebraic Perspective

## Research Report 001 — Multi-Agent Analysis

**Date**: 2026-03-25
**Scope**: Audit TODO.md critical path tasks (58-60), evaluate accuracy, identify gaps, and propose algebraic strategies to overcome remaining obstacles.
**Method**: Four parallel investigation teams covering: (A) algebraic path status, (B) SuccChain sorries, (C) completeness wiring, (D) STSA algebraic perspective.

---

## 1. Executive Summary

The critical path to sorry-free completeness is **closer than the ROADMAP suggests** but faces a single deep mathematical obstacle: constructing a **temporally coherent BFMCS** from an arbitrary MCS. The ROADMAP claims 98 sorries across 24 files, but the actual count is now **25 sorries across 12 files** — significant progress has been made since the ROADMAP was written. The TODO.md task ordering (58 → 59 → 60) is **mostly accurate** but has stale dependency information and underestimates the centrality of the temporal coherence gap.

The algebraic perspective — specifically the STSA (Shift-Closed Tense S5 Algebra) framework — offers the most promising path to resolving the temporal coherence obstacle, not by explicit chain construction but by working at the level of the Lindenbaum algebra's Stone space.

---

## 2. Actual Sorry Inventory (Corrected)

The ROADMAP's sorry count of 98 is **stale**. Current actual sorry count: **25**.

| Category | Count | Files | Status |
|----------|-------|-------|--------|
| Examples/pedagogical | 12 | Demo, ModalProofs, ModalProofStrategies, TemporalProofs | Expected (exercises) |
| Soundness frame-specific | 5 | Soundness.lean:572,576,579,582,602 | Task 59 |
| FrameConditions completeness | 3 | FrameConditions/Completeness.lean:108,151,170 | Task 58 |
| FMP truth preservation | 2 | TruthPreservation.lean:263,281 | Task 998 (independent) |
| SuccChainTruth singleton | 1 | SuccChainTruth.lean:311 | Intentional documentation |
| Perpetuity bridge | 0 | Bridge.lean, Principles.lean | **ALL RESOLVED** |
| SuccChainFMCS | 0 | SuccChainFMCS.lean | **ALL REMOVED** (task 56) |
| **Publication-path total** | **9** | 2 files | Tasks 58+59 |

**Key correction**: The SuccChainFMCS.lean file has been cleaned up (task 56, 2026-03-24). The 24 "CRITICAL PATH" sorries from the ROADMAP have been removed — the FALSE theorems (`f_nesting_is_bounded`, `restricted_single_step_forcing`, etc.) were deleted (~2055 lines of dead code). The file now contains only the restricted chain infrastructure with mathematically correct bounded F-nesting for RestrictedMCS.

The perpetuity bridge lemmas (P1-P6) are now **all fully proven** with zero sorries.

---

## 3. TODO.md Task Accuracy Audit

### Task 58: Wire Completeness to FrameConditions — ACCURATE but UNDERSTATED

**Description accuracy**: Correct. Three sorries at the stated locations.
**Dependency on Task 55**: Correct (task 55 is complete).
**Status "RESEARCHED"**: Correct.

**What's understated**: The description says "wires the sorry-free algebraic path through to the final completeness statements," but the actual blocker is not mere wiring — it requires a **temporally coherent BFMCS construction**. The `construct_bfmcs` function in UltrafilterChain.lean:1853 exists but is **deprecated** because its temporal coherence proof depends on the false `f_nesting_is_bounded` assumption. The wiring itself is straightforward once a correct `construct_bfmcs` is available.

**Recommendation**: Reframe this task as "Provide a correct temporally coherent BFMCS construction and wire it to FrameConditions completeness."

### Task 59: Prove Frame-Specific Soundness Axioms — ACCURATE and INDEPENDENT

**Description accuracy**: Correct. Five sorries at the stated locations.
**Dependency on Task 58**: **Questionable**. These soundness proofs are logically independent of completeness wiring. They require frame-specific instances (`DenselyOrdered`, `SuccOrder`, `NoMaxOrder`, `NoMinOrder`) which exist in Mathlib but need appropriate proof patterns. This could be done in parallel with task 58.

**Recommendation**: Mark as parallelizable with task 58, not dependent on it.

### Task 60: Remove discrete_Icc_finite_axiom — ACCURATE

**Description accuracy**: Correct. Custom axiom at line 187 of FrameConditions/Completeness.lean.
**Dependency on Task 59**: Correct structurally, though this is a localized axiom elimination task.

### Missing from Critical Path

The TODO.md critical path `58 → 59 → 60` omits:

1. **The temporal coherence construction itself** — This is the actual hard problem. It's mentioned obliquely in task 58's description but deserves its own task or should be the central focus of task 58.

2. **SuccChainTruth.lean:311 sorry** — The singleton-Omega sorry in succ_chain_truth_forward (Box backward case). This documents why bundling is necessary. It propagates through SuccChainCompleteness. While it's documented as intentional, any completeness path must either resolve it or bypass it.

3. **ROADMAP "Class A" sorries** — The ROADMAP identified "solvable via DNE" sorries (Class A), but these were part of the deleted false code. The Class A/B distinction from the ROADMAP is now **moot** — the SuccChain approach was abandoned, not fixed.

---

## 4. The Central Mathematical Obstacle

### 4.1 The Problem

The entire sorry-free algebraic path (10/11 modules, ~5300 lines) reduces to a single callback:

```lean
construct_bfmcs : (M : Set Formula) → SetMaximalConsistent M →
    Σ' (B : BFMCS D) (h_tc : B.temporally_coherent)
       (fam : FMCS D) (hfam : fam ∈ B.families) (t : D),
       M = fam.mcs t
```

Given an arbitrary MCS M, produce:
- A bundle B of FMCS families over domain D
- **Proof that B is temporally coherent** (the hard part)
- A distinguished family containing M at some time t

**Temporal coherence** means every family satisfies:
- **forward_F**: `F(φ) ∈ fam.mcs(t)` implies `∃ s > t, φ ∈ fam.mcs(s)`
- **backward_P**: `P(φ) ∈ fam.mcs(t)` implies `∃ s < t, φ ∈ fam.mcs(s)`

### 4.2 Why the SuccChain Approach Failed

The SuccChain approach tried to build FMCS by explicit forward/backward enumeration:
1. Start with MCS M₀ at position 0
2. For each step, extract G-content and extend to next MCS via Lindenbaum
3. Claim: F-obligations at step k are satisfied at step k+1

**The false claim**: `f_nesting_is_bounded` — that F-nesting depth is bounded for arbitrary MCS. Counterexample: an MCS can consistently contain `{Fⁿ(p) | n ∈ ℕ}`, which is satisfiable on integers (point 0, with p true at position n for each n).

For **restricted** MCS (within deferralClosure), F-nesting IS bounded. But the chain construction needs arbitrary MCS at each step (Lindenbaum extensions escape the closure).

### 4.3 What's Left in SuccChainFMCS.lean

After task 56 cleanup, the file contains:
- `DeferralRestrictedSerialMCS` structure
- `restricted_forward_chain` construction (correct, sorry-free)
- `restricted_forward_chain_forward_F` (forward F coherence for restricted chains)
- F/P-nesting boundedness for RestrictedMCS (correct)

**Open items** (documented at end of file):
1. `constrained_predecessor_restricted` (symmetric backward construction)
2. `restricted_backward_chain`
3. `restricted_succ_chain_fam` combining forward and backward
4. Full P-nesting coherence proofs

---

## 5. Algebraic Perspective: STSA as the Resolution Path

### 5.1 What Exists

The STSA (Shift-Closed Tense S5 Algebra) infrastructure is **fully formalized**:

| Component | File | Lines | Status |
|-----------|------|-------|--------|
| STSA typeclass | TenseS5Algebra.lean | 350 | Sorry-free |
| LindenbaumAlg instance | TenseS5Algebra.lean:310 | — | Sorry-free |
| Boolean algebra | BooleanStructure.lean | 447 | Sorry-free |
| Interior operators (□,G,H) | InteriorOperators.lean | 191 | Sorry-free |
| Ultrafilter-MCS bijection | UltrafilterMCS.lean | 882 | Sorry-free |
| σ (temporal duality) | LindenbaumQuotient.lean | — | Sorry-free |
| Parametric canonical TaskFrame | ParametricCanonical.lean | 244 | Sorry-free |
| Parametric truth lemma | ParametricTruthLemma.lean | 458 | Sorry-free |
| Parametric representation | ParametricRepresentation.lean | 300 | Sorry-free (conditional) |
| Box-class modal backward | UltrafilterChain.lean:1678 | — | Sorry-free |

**Total sorry-free algebraic infrastructure**: ~5,300 lines across 10 modules.

### 5.2 The STSA Representation Theorem (Research Report 992)

The STSA analysis (01_stsa-algebraic-analysis.md) identifies a four-stage representation:

1. **Stone Space** (Boolean layer): `Spec(A) = ultrafilters = MCSs` — COMPLETE
2. **Relational Frame** (Jónsson-Tarski layer): Interior operators induce canonical relations R_□, R_G, R_H on Spec(A) — COMPLETE
3. **Temporal Structuring** (FMCS layer): R_G restricted within R_□-classes gives linear preorders; FMCS = maximal R_G-chains — **THIS IS THE GAP**
4. **Full Representation** (TaskFrame layer): Complex algebra embedding with truth lemma — COMPLETE (conditional on Stage 3)

### 5.3 Key Algebraic Insights

**Insight 1: The □-fixed points form a G-invariant subalgebra.** The combined interaction inequality `□a ≤ □(G(a)) ⊓ G(□(a))` means that R_□-equivalence classes are time-invariant. This is shift-closure at the algebraic level, and it's already proven.

**Insight 2: Temporal duality σ is a time-reversal automorphism.** On Spec(A), σ reverses temporal order: R_G(U,V) iff R_H(σU, σV). If h : D → Spec(A) is an FMCS, then t ↦ σ(h(-t)) is also an FMCS. This means backward chain construction is FREE once forward construction is done.

**Insight 3: The algebra doesn't enumerate F-obligations.** The SuccChain approach fails because it tries to satisfy F-obligations one at a time, hitting unbounded nesting. The algebraic approach works at the level of the entire algebra — ultrafilters automatically satisfy all formulas coherently because they are maximal filters of a Boolean algebra with the right properties.

**Insight 4: G normality implies R_G is a preorder on Spec(A).** G preserves finite meets (from TK + monotonicity), making R_G = {(U,V) : {a : G(a) ∈ U} ⊆ V} a reflexive transitive relation. Within each R_□-class, linearity makes it a total preorder.

### 5.4 The Algebraic Path to Temporal Coherence

The obstacle is building a function `D → MCS` (an FMCS) from the algebraic data. Two algebraic strategies:

#### Strategy A: Zorn's Lemma on R_G-Chains

Within a fixed R_□-equivalence class [M₀], the R_G relation is a total preorder. Consider maximal R_G-chains through M₀. By Zorn's lemma, these exist. The question is whether they can be indexed by D.

**Challenge**: The chain may have the "wrong" order type. For D = ℤ, we need a chain isomorphic to (ℤ, ≤). The seriality axioms (F⊤, P⊤) guarantee no endpoints, and linearity gives totality, but matching the exact order type of ℤ or ℚ requires careful argument.

**Algebraic tool**: The TA axiom (`a ≤ G(Pa)`) is temporal connectedness — every point has both future and past accessible points. Combined with seriality (NoMaxOrder/NoMinOrder), this gives an unbounded chain. For discrete D, the SuccOrder structure on D combined with the restricted chain construction (which IS sorry-free) may suffice.

#### Strategy B: Temporal Shift Automorphism (Task 992 approach)

Define a temporal shift automorphism τ on the Lindenbaum algebra:
```
τ([φ]) = [G⁻¹(φ)]  -- "shift φ one step forward"
```

If τ is well-defined and an automorphism, then for any ultrafilter U:
```
fam.mcs(t) := τᵗ(U)  -- shift U by t steps
```

gives an FMCS where temporal coherence follows algebraically from τ's properties.

**Challenge**: G is not invertible in general (it's deflationary: G(a) ≤ a). The "shift" must be constructed differently — perhaps using the successor relation on R_G-chains rather than an algebraic inverse.

**Existing infrastructure**: `swap_temporal` (σ) is already lifted to the quotient as `sigma_quot`. The shift automorphism would be a different operation — temporal translation rather than temporal reversal.

#### Strategy C: Restricted Chain + Dovetailing (Most Concrete)

The restricted chain construction in SuccChainFMCS.lean is sorry-free for forward F-coherence. The open items are:
1. Backward chain construction (use σ-duality — Insight 2)
2. Combining forward and backward into a single FMCS over ℤ
3. Proving the combined chain is temporally coherent

**Algebraic advantage**: σ-duality means backward construction is a mirror of forward construction. If `restricted_forward_chain` is sorry-free, then `restricted_backward_chain` should be derivable by applying σ to the forward chain and reversing the index.

**This is likely the shortest path** — it builds on the most concrete existing infrastructure and uses the algebraic duality to halve the remaining work.

---

## 6. Recommended Next Steps

### Priority 1: Complete Task 58 via Strategy C

1. **Build `restricted_backward_chain`** using σ-duality on the sorry-free `restricted_forward_chain`. The temporal duality `sigma_quot` is proven; apply it to mirror the forward construction.

2. **Combine into `restricted_succ_chain_fam`** — dovetail forward and backward chains into a single FMCS over ℤ.

3. **Wire to `construct_bfmcs`** — use the box-class families construction (sorry-free `boxClassFamilies_modal_backward`) with the new temporally coherent chain.

4. **Plug into `parametric_algebraic_representation_conditional`** — this immediately gives the three completeness sorries in FrameConditions/Completeness.lean.

### Priority 2: Task 59 (Parallelizable)

The five soundness sorries are independent. Each requires instantiating frame-specific Mathlib typeclasses:
- `density`: Use `DenselyOrdered.dense` from Mathlib
- `discreteness_forward`: Use `SuccOrder.succ_le_iff`
- `seriality_future/past`: Use `NoMaxOrder.exists_gt` / `NoMinOrder.exists_lt`
- `temporal_duality`: Wire to existing `SoundnessLemmas.axiom_swap_valid`

Estimated effort: 3-5 hours, no blockers.

### Priority 3: Task 60

Once discrete completeness works (task 58), proving `discrete_Icc_finite_axiom` or restructuring to avoid it. The restricted chain approach with finite deferralClosure may provide the finiteness argument directly.

### Deferred: Task 992 (STSA Representation)

The STSA typeclass and LindenbaumAlg instance are already complete. What remains for the full STSA representation theorem is restructuring ParametricRepresentation into a unified form. This is elegant but not on the critical path — it's a reorganization of existing sorry-free code into a cleaner algebraic framework.

---

## 7. Challenges and Risk Assessment

| Risk | Severity | Mitigation |
|------|----------|------------|
| σ-duality backward chain doesn't compose cleanly with forward | Medium | The restricted chain uses concrete MCS operations; σ operates on formulas. Bridge may need careful construction. |
| Dovetailing forward+backward loses temporal coherence | Medium | The join point (at position 0) must be the original MCS M₀. Forward and backward chains already start from M₀. |
| RestrictedMCS F-nesting bounds don't survive Lindenbaum extension | Low | The restricted chain is specifically designed to work within deferralClosure. Extensions stay within the closure by construction. |
| FrameConditions completeness needs dense/discrete specialization | Low | The parametric representation is D-polymorphic. Instantiate D=ℤ for discrete, D=ℚ for dense. |
| discrete_Icc_finite_axiom is genuinely hard | Medium | May require proving DiscreteTimelineQuot intervals are finite, or restructuring to avoid. Could be deferred. |

---

## 8. ROADMAP Corrections Needed

1. **Sorry count**: 98 → 25 (12 are examples/exercises)
2. **SuccChain sorries**: 24 → 0 (all removed in task 56)
3. **Perpetuity bridge**: 16 → 0 (all proven)
4. **Class A/B distinction**: Moot — the SuccChain approach was abandoned
5. **Publication-path sorries**: 24 → 9 (tasks 58+59 only)
6. **The "key question"** about temporal shift automorphism: Partially answered — σ exists on the quotient, but temporal translation (as opposed to reversal) remains open
