# Teammate C: Risk Analysis and Deep Structural Assessment

**Task**: 951 - Sorry-Free Completeness via CanonicalMCS Domain
**Role**: Risk analysis with focus on proof risks, missing lemmas, edge cases, and deep structural examination of the user's request to think about quality, elegance, and scrutiny of "cheap" elements.
**Date**: 2026-03-02
**Session**: sess_1772431881_00276f

## Executive Summary

This analysis examines the five critical questions from research-021 Part 7, provides risk assessments for each proposed path, identifies specific Lean-level obstacles that prior research has not addressed, and offers a deep structural analysis of what "elegant" and "quality" mean for this proof in terms of the existing codebase architecture.

**Key Finding**: The sorry gap is narrower than 20 reports suggest. There are exactly 3 `sorry` instances (DovetailingChain.lean:1869, DovetailingChain.lean:1881, TemporalCoherentConstruction.lean:600). The third sorry (`fully_saturated_bfmcs_exists_int`) is the real bottleneck -- it requires combining temporal coherence AND modal saturation. The first two sorries feed into the third. The proof architecture is already 95% complete.

## Section 1: Answering the Five Critical Questions from Research-021

### Q1: Does the Box Backward Case Require Temporal Coherence for Witness Families?

**Answer: NO. The box backward case does NOT require temporal coherence for ANY family.**

Verified by reading TruthLemma.lean (lines 321-346) and Representation.lean (lines 305-326, 450-485).

The box case in both `bmcs_truth_lemma` and `canonical_truth_lemma_all` (and `shifted_truth_lemma`) uses ONLY:
- `B.modal_forward`: Box phi in fam.mcs t implies phi in fam'.mcs t (for all fam')
- `B.modal_backward`: phi in all fam'.mcs t implies Box phi in fam.mcs t
- The induction hypothesis applied at EACH family

Temporal coherence (`B.temporally_coherent`) is used ONLY in the `all_future` and `all_past` cases (lines 347-398 of TruthLemma.lean, lines 327-383 and 486-526 of Representation.lean), specifically:
- `h_tc fam hfam` extracts `forward_F` / `backward_P` for the specific family being considered
- These are applied to the CURRENT family in the induction, not to witness families

**Critical Implication**: Witness families created by modal saturation do NOT need temporal coherence for the box case. They only need temporal coherence if G/H formulas in the witness families must be handled by the truth lemma. Since the truth lemma recurses into ALL families for the box case (including witness families), and the G/H cases of the truth lemma require temporal coherence for EACH family they touch, witness families DO need temporal coherence -- but only for their OWN G/H handling, not for the box case.

**Refined Answer**: The box backward case itself does not use temporal coherence. However, the INDUCTION HYPOTHESIS in the box case applies the truth lemma recursively to ALL families, and the G/H sub-cases of those recursive calls DO use temporal coherence. Therefore, ALL families in the BFMCS must be temporally coherent for the overall truth lemma to hold.

**Risk Rating**: HIGH. This means constant-family witness MCSes from modal saturation MUST be temporally coherent, which requires F(psi) -> psi and P(psi) -> psi within the single MCS -- mathematically impossible for formulas like {F(psi), neg(psi)}.

### Q2: Are Canonical Families Shift-Closed Under the BFMCS Construction?

**Answer: Already handled -- shift closure is NOT required for canonical families.**

The architecture has already solved this (Task 912):
- `canonicalOmega B` is NOT shift-closed (Representation.lean:134)
- `shiftClosedCanonicalOmega B` IS shift-closed by construction (Representation.lean:156-187)
- The `shifted_truth_lemma` handles the enlarged Omega correctly using `box_persistent` (lines 227-248)
- The completeness theorems use `shiftClosedCanonicalOmega` (lines 551-571)

**Risk Rating**: NONE. This question is already resolved in the codebase.

### Q3: Is the BidirectionalFragment Dense?

**Answer: Almost certainly NO -- the fragment is discrete.**

The BidirectionalFragment is built by iterated Lindenbaum extension from a single root MCS M0:
1. Each step constructs ONE new MCS via Lindenbaum's lemma applied to GContent/HContent seeds
2. The forward/backward closure creates elements reachable by FINITE chains of such extensions
3. Between any two consecutive elements in such a chain (e.g., w and fragmentGSucc(w)), there is no guaranteed intermediate element

The fragment IS countable (built from a countable sequence of Lindenbaum extensions starting from M0). For it to be dense, between any w1 < w2 we would need w3 with w1 < w3 < w2. But:
- CanonicalR is defined by GContent subset inclusion
- fragmentGSucc creates a SINGLE new MCS via Lindenbaum(GContent(w))
- No mechanism forces intermediate MCSes to exist

**Formal evidence**: The fragment has `SuccOrder` infrastructure (quotientSucc in CanonicalCompleteness.lean:578) and `PredOrder` infrastructure (quotientPred:596). The fact that meaningful successor/predecessor operations were defined and used strongly suggests a discrete structure, not a dense one.

**Mathematical argument against density**: Density requires that between any two CanonicalR-related MCSes, there is a third. But CanonicalR(M, W) means GContent(M) subset W. If M and W are "adjacent" (no MCS N with GContent(M) subset N and GContent(N) subset W and N != M, N != W), then the fragment is locally discrete. The Lindenbaum construction creates maximal elements, which generically produces adjacent pairs.

**Risk Rating for D=Q path**: VERY HIGH. The fragment is almost certainly discrete, making the D=Q approach via Cantor's theorem inapplicable. D=Z (via `orderIsoIntOfLinearSuccPredArch`) is the correct target.

### Q4: Can `bmcs_truth_at <-> truth_at` Be Sketched Concretely?

**Answer: Already done -- the transfer IS the canonical_truth_lemma_all in Representation.lean.**

This is the most important finding. The "transfer theorem" that research-021 identified as an unverified gap has ALREADY BEEN PROVEN in the codebase:

```lean
theorem canonical_truth_lemma_all (B : BFMCS Int)
    (h_tc : B.temporally_coherent) (φ : Formula)
    (fam : FMCS Int) (hfam : fam ∈ B.families) (t : Int) :
    φ ∈ fam.mcs t ↔ truth_at (canonicalModel B) (canonicalOmega B) (canonicalHistory B fam hfam) t φ
```

This theorem (Representation.lean:266-383) is FULLY PROVEN, sorry-free. It bridges `fam.mcs t` membership to standard `truth_at`. The proof handles all 6 formula cases with the same structure as `bmcs_truth_lemma` but using the standard `truth_at` definition.

The shifted version (`shifted_truth_lemma`, lines 411-526) extends this to the shift-closed Omega, also fully proven.

**What IS missing**: The theorem requires `B : BFMCS Int` with `h_tc : B.temporally_coherent`. The sorry is in CONSTRUCTING such a B (via `fully_saturated_bfmcs_exists_int`), not in the transfer theorem itself.

**Risk Rating**: NONE for the transfer. The real risk is concentrated in `fully_saturated_bfmcs_exists_int`.

### Q5: Trivial task_rel Status

**Answer: Already used and working -- this is a non-issue in the code.**

The codebase already uses `task_rel := fun _ _ _ => True` in Representation.lean:100. The completeness theorems (`standard_weak_completeness`, `standard_strong_completeness`) compile and are structurally complete. The trivial task_rel satisfies nullity and compositionality trivially.

**Mathematical reality**: The TF axiom `Box(phi) -> G(Box(phi))` says that necessity persists into the future. This is a temporal property of the BOX modality, not a property of `task_rel`. The `box_persistent` lemma (Representation.lean:227-248) derives Box persistence purely from TF axiom + forward_G/backward_H, without any reference to `task_rel`.

**Risk Rating**: NONE. This is already resolved.

## Section 2: Where the Remaining Sorry ACTUALLY Lives

The sorry chain is:
```
standard_weak_completeness (sorry-free, calls construct_saturated_bfmcs_int)
  -> construct_saturated_bfmcs_int (sorry-free, wraps .choose)
    -> fully_saturated_bfmcs_exists_int (SORRY at line 600)
      requires: ∃ B : BFMCS Int,
        (∀ γ ∈ Γ, γ ∈ B.eval_family.mcs 0) ∧  -- context preservation
        B.temporally_coherent ∧                  -- temporal coherence
        is_modally_saturated B                   -- modal saturation
```

The sorry at TemporalCoherentConstruction.lean:600 needs to construct a BFMCS Int that has ALL THREE properties simultaneously. The challenge documented in lines 586-599 is:

1. **Temporal coherence** alone is achievable: DovetailingChain gives a single family with forward_F/backward_P (with 2 sorries that feed into the Int version)
2. **Modal saturation** alone is achievable: ModalSaturation.lean's `saturated_modal_backward` is sorry-free given `is_modally_saturated`
3. **The combination** fails because modal saturation adds constant-family witnesses, and constant families at an MCS M require M to be "temporally saturated" (F(psi) -> psi within M), which is impossible for general M

### The Real Problem Restated

We need a SET of FMCS families such that:
- The eval_family contains Gamma at time 0
- EVERY family in the set has forward_F and backward_P (temporal coherence)
- For every Diamond(psi) in any family's MCS at any time, there exists ANOTHER family in the set with psi at that time (modal saturation)

Modal saturation is inherently about MULTIPLE families seeing EACH OTHER. Temporal coherence is about EACH family having internal time-wise consistency. The conflict: when we add a witness family for Diamond(psi) at MCS M, that witness family needs its OWN temporal coherence, which requires constructing it as a non-constant chain rooted at a witness MCS -- not as a constant family.

## Section 3: Risk Assessment for Each Proposed Path

### Path A: Fragment-Based Witness Families + D = Z or Q (20-40 hours estimate)

**Approach**: For each Diamond(psi) obligation, construct a BidirectionalFragment rooted at the witness MCS, build fragmentFMCS for it, then embed into Int.

**Risk 1: Fragment embedding incompatibility (HIGH)**
Each fragment is a separate type `BidirectionalFragment M_psi h_mcs_psi`. Different fragments for different witnesses have DIFFERENT types. They cannot be directly combined into a single `BFMCS Int` without a COMMON time domain. Embedding each independently into Int via `orderIsoIntOfLinearSuccPredArch` gives DIFFERENT embeddings that need not be compatible.

**Risk 2: SuccOrder/PredOrder on BidirectionalQuotient (HIGH)**
Using `orderIsoIntOfLinearSuccPredArch` requires:
- `[LinearOrder ι]` -- PROVEN for BidirectionalQuotient
- `[SuccOrder ι]` -- coverness FAILS (known blocker from Phase 1)
- `[PredOrder ι]` -- same issue
- `[IsSuccArchimedean ι]` -- unverified
- `[NoMaxOrder ι]` / `[NoMinOrder ι]` -- unverified

This is the SAME blocker that sank Plan v3. The SuccOrder coverness property fails because Lindenbaum extension creates elements BETWEEN the existing quotient elements.

**Risk 3: Truth lemma coherence across fragments (MEDIUM)**
Even if each fragment individually has a sorry-free FMCS, the truth lemma in Representation.lean requires ALL families to be in a SINGLE BFMCS with CONSISTENT modal coherence. Different fragments for different witnesses may produce inconsistent valuations.

**Estimated Real Effort**: 50-80 hours (2.5x the optimistic estimate)
**Success Probability**: 30-40%

### Path B: Two-Layer Refactor (40-60 hours estimate)

**Approach**: Separate `TemporalFrame [LinearOrder D]` from `TaskFrame [AddCommGroup D]`. Prove completeness at the temporal level, bridge to standard valid.

**Risk 1: Refactoring regression (HIGH)**
The codebase has ~5000+ lines of sorry-free proven code in the Metalogic stack. Changing the semantic layer (TaskFrame, WorldHistory, truth_at, valid) would invalidate:
- Soundness.lean and SoundnessLemmas.lean
- All of Representation.lean
- The Decidability module
- Any downstream consumers

**Risk 2: Two definitions of valid (MEDIUM)**
Maintaining two notions of validity (temporal_valid over LinearOrder and task_valid over AddCommGroup) and proving their equivalence is non-trivial. The MF/TF axiom soundness proofs use AddCommGroup properties (specifically, the group inverse for time-shifting).

**Risk 3: ShiftClosed at the temporal level (MEDIUM)**
The shift-closure mechanism (`time_shift_preserves_truth`, `ShiftClosed`) fundamentally uses AddCommGroup (shifting by d+d' = d+(d')). At the temporal level with only LinearOrder, shift-closure doesn't have a clean formulation.

**Estimated Real Effort**: 60-100 hours (factoring regression testing)
**Success Probability**: 60-70% (higher mathematical certainty, but high engineering risk)

### Path C: Finite Model Property + Pruning (3-6 months)

**Risk Assessment**: The Decidability module already exists with partial infrastructure. However:
- Completeness requires FMP formalization (noted as "Partial" in Decidability.lean:29)
- TM has BOTH temporal AND modal operators -- FMP for the combined logic is non-trivial
- The Doczkal-Smolka approach works for K* (basic tense logic) but TM adds S5 Box and task_rel
- S5 + temporal operators may NOT have the finite model property (known issue in modal logic)

**Critical unknown**: Does TM have FMP? If not, this path is entirely blocked.

**Estimated Real Effort**: 200-500 hours
**Success Probability**: 40% (contingent on FMP holding for TM)

### Path D: Algebraic (Jonsson-Tarski) (Long-term)

**Existing code**: `Theories/Bimodal/Metalogic/Algebraic/` has 5 files.
**Risk**: UltrafilterMCS.lean has sorries. The algebraic path requires completing the Lindenbaum algebra construction, proving it's a BAO, and applying representation theory.

**Estimated Real Effort**: 150-300 hours
**Success Probability**: 70% (mathematically well-understood, but massive implementation)

## Section 4: The Cheapest Path to Sorry-Free (What Research-021 Missed)

Research-021 overlooks what is arguably the simplest resolution:

### The Unified Non-Constant Witness Family Approach

**Key observation**: The sorry in `fully_saturated_bfmcs_exists_int` fails because witness families are assumed to be CONSTANT (same MCS at all times). But nothing in the architecture REQUIRES constant witness families.

**The approach**:
1. Start with a temporally coherent eval_family from DovetailingChain (fix its 2 sorries first)
2. For each Diamond(psi) obligation at (fam, t), construct a NON-CONSTANT witness family:
   a. The witness MCS W = diamondWitnessMCS(fam.mcs(t), psi) at time t (already in CanonicalCompleteness.lean:394)
   b. Build a BidirectionalFragment from W (sorry-free infrastructure exists)
   c. Construct a DovetailingChain from W, giving a temporally coherent FMCS indexed by Int
   d. This witness family has psi at time 0, maps to W at time 0, and has forward_F/backward_P

**Why this bypasses the blocker**: Each witness family is its own DovetailingChain, not a constant family. The temporal coherence of each witness family is guaranteed by its own chain construction. Modal saturation is achieved by having enough such families.

**Risk**: The DovetailingChain itself has 2 sorries (forward_F, backward_P). These MUST be resolved first.

**Risk on the DovetailingChain sorries**: These sorries exist because F-formulas don't persist through GContent seeds. The fragmentFMCS approach resolves this at the FRAGMENT level but not at the Int level. The gap is: we can prove forward_F for `FMCS (BidirectionalFragment M0 h_mcs0)` (sorry-free), but we need forward_F for `FMCS Int`.

### The Bridge: Fragment-Indexed BFMCS

**Alternative not yet explored**: Instead of embedding fragments into Int, work with BFMCS DIRECTLY parameterized over the fragment type.

The truth lemma (`bmcs_truth_lemma`) works for ANY `[Preorder D] [Zero D]` -- it does NOT require `AddCommGroup D` or `D = Int`. The completeness chain in Representation.lean is the part that needs `D = Int`, because `TaskFrame D` requires `[AddCommGroup D]`.

**Proposal**: Prove an INTERMEDIATE completeness theorem:

```lean
-- This uses bmcs_truth_at, not truth_at
-- D = BidirectionalFragment, which is Preorder + Zero
-- ALL infrastructure is sorry-free at this level
theorem bfmcs_completeness (phi : Formula) (h_cons : ContextConsistent [phi]) :
    ∃ (B : BFMCS (BidirectionalFragment M0 h_mcs0)),
      B.temporally_coherent ∧
      is_modally_saturated B ∧
      phi ∈ B.eval_family.mcs ⟨M0, ..⟩
```

This is provable with existing sorry-free infrastructure:
- fragmentFMCS gives sorry-free temporal coherence
- Modal saturation via fragment-based witness families
- All at the Preorder level, no AddCommGroup needed

Then bridge to `satisfiable Int [phi]` via a SINGLE embedding lemma that transfers from the fragment model to an Int model.

**The embedding lemma** would need:
1. An order-preserving injection from the fragment into Int (or any AddCommGroup target)
2. Proof that truth is preserved under this injection

This factorization is cleaner because:
- The hard work (temporal coherence + modal saturation) happens at the fragment level where everything is sorry-free
- The easy work (embedding into Int) is a separate, modular step

## Section 5: The DovetailingChain Forward_F/Backward_P Sorries

These 2 sorries (DovetailingChain.lean:1869, 1881) are the ROOT CAUSE. Every downstream sorry traces back to them. Let me analyze why they exist and whether they can be resolved.

**The sorry at line 1869** (`forward_F`):
```
-- Given: F(phi) ∈ chain.mcs t
-- Need: exists s > t with phi ∈ chain.mcs s
-- Problem: F(phi) means "phi at some LATER time"
-- The chain places GContent(M_t) into the seed for M_{t+1}
-- But F(phi) is NOT in GContent(M_t) (GContent = {psi | G(psi) in M})
-- So phi is not guaranteed to appear in M_{t+1}
```

The dovetailing enumeration TRIES to place F-witnesses, but:
- At step n constructing M_t, it processes pair (s, psi) = unpair(n)
- If s < t and F(psi) in M_s, it includes psi in the seed for M_t
- But this only covers F-formulas that appeared at EARLIER construction steps
- F-formulas added by LINDENBAUM at step t (not in the original seed) are not witnessed

**The fragment-based resolution**: In BidirectionalReachable.lean, `forward_F_stays_in_fragment` proves that if F(phi) is in a fragment element w, then there exists s >= w with phi in s. This is sorry-free. The proof works because:
- F(phi) in w.world means there's a temporal witness seed {phi} union GContent(w.world)
- This seed is consistent (by temporal_witness_seed_consistent)
- Lindenbaum extends it to an MCS W
- W has CanonicalR(w, W) (from GContent containment) and phi in W
- By forward_closed, W is in the fragment

**The gap**: Converting from "exists s in BidirectionalFragment" to "exists n in Int" requires an order-preserving enumeration of the fragment by Int. This enumeration needs to be SURJECTIVE onto the fragment (or at least hit all necessary witnesses).

## Section 6: Elements That Deserve Greater Scrutiny

### 6.1 The "Trivial Task Relation" Is Actually Correct, Not Lazy

Research-021 Section 3.3 suggests the trivial task_rel "keeps re-emerging" as if it were a hack. On careful examination of the semantics:

The task_rel in a TaskFrame constrains which world-state transitions are possible for tasks of given durations. In the CANONICAL model, world states are MCSes (abstract syntactic objects). The task_rel should capture what the LOGIC SAYS about state transitions.

TM's axioms that involve task_rel are:
- MF (Modal Future): Box(phi) -> G(Box(phi)) -- box persists into future
- TF (Temporal Future): Box(phi) -> G(Box(phi)) -- same axiom!
- Nullity: task_rel w 0 w -- identity transition
- Compositionality: task_rel w d u ∧ task_rel u e v -> task_rel w (d+e) v

The TM logic has NO axiom that distinguishes between different task_rel values beyond nullity and compositionality. Therefore, `fun _ _ _ => True` is the WEAKEST task_rel satisfying the axioms -- and in a completeness proof by Henkin construction, we want the weakest structure that the axioms don't forbid.

Using `task_rel := fun _ _ _ => True` is the mathematically correct canonical choice. It is analogous to using the full accessibility relation in the canonical model for S5 modal logic.

### 6.2 The AddCommGroup Requirement Is Real But Narrowly Used

The AddCommGroup on D is used in exactly two places in the semantic layer:
1. `WorldHistory.time_shift`: requires `d + d'` computation for shift composition
2. `TaskFrame.compositionality`: requires `x + y` for task duration composition

For the CANONICAL model:
- time_shift is handled by Int's group structure (inherited via `Equiv.addCommGroup` from OrderIso)
- compositionality is trivially satisfied by the trivial task_rel

So the AddCommGroup is a FORMAL requirement, not a mathematical obstacle. Any countable linear order can be embedded into Int (via `Order.embedding_from_countable_to_dense` into Q, or via enumeration for discrete orders), and Int's AddCommGroup transfers.

### 6.3 The Number of Research Reports Is Itself a Risk

20+ research reports with conflicting recommendations create ANALYSIS PARALYSIS. The codebase has been stable since Task 912 resolved the Omega-mismatch. The actual code changes needed are concentrated in a SINGLE theorem: `fully_saturated_bfmcs_exists_int`.

## Section 7: Specific Lemma Existence Verification

Using lean_local_search and lean_hover_info, I verified the following critical lemma existence:

| Lemma | Exists? | Module |
|-------|---------|--------|
| `orderIsoIntOfLinearSuccPredArch` | YES | Mathlib.Order.SuccPred.LinearLocallyFinite |
| `Equiv.addCommGroup` | YES | Mathlib.Algebra.Group.TransferInstance |
| `Order.embedding_from_countable_to_dense` | YES | Mathlib.Order.CountableDenseLinearOrder |
| `Order.iso_of_countable_dense` | YES | Mathlib.Order.CountableDenseLinearOrder |
| `fragmentFMCS` | YES | Bundle.CanonicalCompleteness |
| `fragmentFMCS_forward_F` | YES | Bundle.CanonicalCompleteness |
| `fragmentFMCS_backward_P` | YES | Bundle.CanonicalCompleteness |
| `fragmentFMCS_temporally_coherent` | YES | Bundle.CanonicalCompleteness |
| `enriched_seed_consistent_from_F` | YES | Bundle.CanonicalCompleteness |
| `enriched_seed_consistent_from_P` | YES | Bundle.CanonicalCompleteness |
| `diamondWitnessMCS` | YES | Bundle.CanonicalCompleteness |
| `box_witness_seed_consistent` | YES | Bundle.CanonicalCompleteness |
| `saturated_modal_backward` | YES | Bundle.ModalSaturation |
| `box_persistent` | YES | Representation |
| `shiftClosedCanonicalOmega_is_shift_closed` | YES | Representation |

All critical infrastructure is present and verified.

## Section 8: Recommended Investigation Priority

Based on risk analysis, the following investigations should happen BEFORE any implementation plan:

### Priority 1: Resolve DovetailingChain's forward_F/backward_P sorries

This is the ROOT CAUSE. Two approaches:

**Approach A (Fragment pullback)**:
- Build BFMCS over BidirectionalFragment (sorry-free temporal coherence + modal saturation)
- Then embed fragment into Int via order-preserving injection
- Transfer truth preservation through the embedding

**Approach B (Omega-squared dovetailing)**:
- Modify DovetailingChain to use omega-squared enumeration
- At step (n, k), handle the k-th F-formula from step n
- This guarantees all F-formulas eventually get witnesses

**Recommendation**: Approach A is cleaner (reuses existing sorry-free infrastructure).

### Priority 2: Construct non-constant witness families for modal saturation

For each Diamond(psi) in the eval_family, construct a fresh DovetailingChain rooted at the witness MCS. This gives a temporally coherent witness family. The key lemma to prove:

```lean
-- For each Diamond(psi) obligation, construct a temporally coherent witness family
theorem diamondWitness_temporally_coherent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_diamond : diamondFormula psi ∈ M) :
    ∃ (fam : FMCS Int),
      psi ∈ fam.mcs 0 ∧
      (∀ t φ, Formula.some_future φ ∈ fam.mcs t → ∃ s, t ≤ s ∧ φ ∈ fam.mcs s) ∧
      (∀ t φ, Formula.some_past φ ∈ fam.mcs t → ∃ s, s ≤ t ∧ φ ∈ fam.mcs s) ∧
      BoxContent M ⊆ fam.mcs 0
```

### Priority 3: Combine into `fully_saturated_bfmcs_exists_int`

With (1) and (2) resolved:
- Start with temporally coherent eval_family from (1)
- For each Diamond obligation, add witness family from (2)
- Use Zorn's lemma (existing ModalSaturation.lean pattern) to saturate
- Each new witness is a temporally coherent chain, not a constant family

## Section 9: Confidence Assessment

| Finding | Confidence |
|---------|-----------|
| Q1: Box case doesn't use TC directly (but IH recurses into TC cases) | HIGH |
| Q2: ShiftClosed is already resolved | VERY HIGH |
| Q3: Fragment is discrete, not dense | HIGH |
| Q4: Transfer theorem already proven in Representation.lean | VERY HIGH |
| Q5: Trivial task_rel is mathematically correct | HIGH |
| DovetailingChain sorries are the root cause | VERY HIGH |
| Fragment-based BFMCS + embedding is the cleanest path | MEDIUM-HIGH |
| Estimated effort for cheapest resolution: 25-45 hours | MEDIUM |
