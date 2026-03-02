# Research Report #021: Mapping the Ideals and Cataloging Best Approaches
## Task 951 — Sorry-Free Completeness via CanonicalMCS Domain

**Date**: 2026-03-02
**Session**: sess_1772431881_00276f
**Mode**: Team Research — 3 Opus-4.6 teammates in parallel
**Teammates**: A (Ideals + Catalog), B (Critical Gap Analysis), C (Outside-the-Box Alternatives)
**Sources**: research-001 through research-020, plans v1–v4, all handoffs, Lean source files, Mathlib searches, literature survey

---

## Executive Summary

After 20+ research reports, 4 implementation plans (all blocked), and one partial implementation, this synthesis maps the mathematical ideals, catalogs the best ideas, identifies critical gaps and "cheap" elements, and presents fresh alternatives. The core finding: **the project has been fighting the wrong battle**. The main sorry is not a missing proof but an architectural mismatch, and the solution has been identified correctly in multiple reports but never executed.

Three sorries remain, all tracing to `fully_saturated_bfmcs_exists_int`. The resolution must combine temporally coherent families (sorry-free at the BidirectionalFragment level) with modally saturated families (which currently have no temporal coherence).

---

## Part 1: The Ideals

### 1.1 What an Elegant Sorry-Free Completeness Proof Looks Like

An elegant completeness proof for TM would decompose into four clean, independently verifiable layers:

1. **Syntactic layer**: From a consistent formula φ, extend {¬φ} to an MCS M₀ via Lindenbaum's lemma.
2. **Canonical frame layer**: From M₀, construct a temporally structured set of MCSes whose ordering reflects the syntactic G/H operators. This time domain *emerges* from the formula structure via CanonicalR (GContent inclusion), not from external commitment to D = ℤ.
3. **Model layer**: Construct a full model (TaskFrame, TaskModel, WorldHistories, Ω) with truth at the canonical world refuting φ.
4. **Algebraic bridge**: Connect the syntactically-derived time domain to the semantic requirement that D satisfies `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`.

Properties a publishable proof would exhibit:
- **G/H duality visible**: The time domain is defined symmetrically from both G (future) and H (past) via the proven duality bridges.
- **F/P witness closure trivial**: Temporal coherence follows directly from the domain definition.
- **Modal saturation separate**: The modal (Box/Diamond) layer factors cleanly from the temporal (G/H/F/P) layer.
- **Truth lemma agnostic**: Works for any `[Preorder D]`, not requiring AddCommGroup. (Already true: `bmcs_truth_lemma` in TruthLemma.lean.)
- **Extensible to frame correspondence**: Adding discreteness axioms → D ≅ ℤ; density axioms → D embeds in ℚ; base TM → general linear order.
- **Non-trivial task_rel** (desirable): `task_rel w d u` should have genuine semantic content.

A *merely working* proof would set D = ℤ from the start, use trivial task_rel, fight F-persistence, and achieve sorry-free status through brute-force engineering. A *publishable* proof would derive D's structure from the frame's order-theoretic properties.

### 1.2 The Fundamental Mathematical Fact

All 20 reports circle around one inescapable fact: **a bare linear order does not determine a group**. The canonical frame's linear order structure IS derived from syntax (this is proven, elegant, 5000+ lines sorry-free). The additive group structure must be externally imposed via embedding. This is a mathematical necessity, not a deficiency — analogous to how a manifold's differentiable structure is imposed via charts into ℝⁿ, not derived from its point-set topology.

The resolution: accept that
1. The canonical frame's **linear order** is intrinsic (derived from G/H operators and linearity axiom) ✓
2. The **additive group structure** is extrinsic (imposed via embedding into ℤ or ℚ) — this is okay
3. The choice of embedding target (ℤ, ℚ) is a proof artifact, not a semantic commitment
4. A completeness statement using `satisfiable_abs` hides the choice of D

---

## Part 2: Best Ideas Catalog — 20 Reports Ranked

### Tier 1: Foundational Insights (Preserved, Build On These)

| Report | Key Insight | Elegance | Status |
|--------|------------|----------|--------|
| research-003 | F-formula non-persistence through GContent is a **mathematical impossibility** (existential vs. universal). Closes DovetailingChain approach definitively. | 10/10 | Foundational |
| research-003 §5 | BidirectionalFragment (forward AND backward from M₀) is **the right domain definition**. Fixes backward_P gap. | 10/10 | Implemented (832 lines, sorry-free) |
| research-002 | Times are **equivalence classes of MCSes** within maximal chains (Antisymmetrization quotient). Correct conceptual framework. | 9/10 | Framework for all subsequent work |
| research-010 | Derive AddCommGroup from intrinsic successor structure via `orderIsoIntOfLinearSuccPredArch` + `Equiv.addCommGroup`. NOT "assuming D = ℤ" — PROVING D ≅ ℤ. | 9/10 | Blocked (coverness fails) |
| research-014 | **Definitive construction via Fragment Enumeration**: compose order-preserving enumeration `ℤ → BidirectionalFragment` with fragmentFMCS. Sidesteps F-persistence entirely. Clearest conceptual decomposition. | 9/10 | Conceptual only, never implemented |

### Tier 2: Viable Approaches (Partially Explored, High Potential)

| Report | Key Insight | Elegance | Status |
|--------|------------|----------|--------|
| research-013 | Archimedean dichotomy: canonical model is inherently discrete (Lindenbaum builds one MCS at a time). D = ℤ is correct choice, not arbitrary. | 8/10 | Foundational clarification |
| research-007 | Changing `valid` (Approach A) breaks MF/TF soundness. Approach B (embed into ℤ) is the only sound path. Definitive. | 8/10 | Definitive |
| research-020 | Parametric completeness via `zmultiplesHom`: prove for D = ℤ first, transfer to any D via `zmultiplesHom : ℤ →+o D`. Strongest theorem statement. | 8/10 | Never implemented |
| research-005 | Embed FPClosure into ℚ via `Order.embedding_from_countable_to_dense`. Uses Mathlib. Accommodates any fragment structure. | 7/10 | Never attempted |
| research-018 §8 | **Chain-based task_rel**: define `task_rel w d u := ∃ i, chain(i) = w ∧ chain(i+d) = u`. Avoids both SuccOrder coverness AND quotientSucc_pred_inverse blockers. | 7/10 | Proposed only |

### Tier 3: Explored and Definitively Ruled Out

| Report | Why Blocked | Certainty |
|--------|------------|-----------|
| DovetailingChain (research-001/002/008) | F-persistence through GContent is mathematically impossible | 100% |
| SuccOrder on BidirectionalQuotient (plan v3) | Coverness fails: Lindenbaum creates intermediate elements | 100% |
| quotientSucc/Pred inverse (plan v4) | Requires G(φ)→H(φ), semantically invalid (3-point countermodel) | 100% |
| Fragment automorphisms → AddCommGroup (research-006) | Fragment has trivial automorphism group | 100% |
| Grothendieck on bare linear order (research-009) | No monoid structure to feed construction | 100% |
| Changing `valid` definition (research-007) | Breaks MF/TF soundness | 100% |
| Constant FMCS families (research-001) | F(ψ) in M does not imply ψ in M | 100% |

**Note**: Plans v3 and v4 should be marked PERMANENTLY ABANDONED, not merely BLOCKED. Both hit the same mathematical obstruction (Lindenbaum non-constructivity prevents algebraic regularity on the quotient), dressed in different language (SuccOrder vs. Grothendieck).

### Tier 4: Brilliant Partial Ideas — Never Fully Developed

These ideas appeared in the research but were never implemented and deserve serious attention:

1. **Fragment-based witness families with independent chains** (implicit in research-014, research-020): Each Diamond(ψ) witness gets its own BidirectionalFragment rooted at the witness MCS, with its own sorry-free fragmentFMCS. The chain for each witness family need not be surjective globally — only onto the witnesses needed for *that* family's truth lemma. This could avoid the F-persistence problem entirely.

2. **Parametric completeness via zsmul transfer** (research-020): Once `satisfiable ℤ φ` is proved by any means, transfer to arbitrary D via `zmultiplesHom`. Gives `∀ D, consistent φ → satisfiable D φ` — the strongest possible theorem. The transfer machinery is mathematically sound but unimplemented.

3. **D = ℚ via Cantor's theorem** (mentioned in research-005, C.3 in teammate-c findings): If the BidirectionalFragment is dense (plausible), it is order-isomorphic to ℚ by Cantor's theorem for countable dense linear orders without endpoints. This would entirely bypass the SuccOrder blocker. Requires investigating whether the fragment is dense.

---

## Part 3: Critical Gaps and "Cheap" Elements

### 3.1 The Most Critical Gap: The Transfer Theorem Has Never Been Proven

Every report from research-016 onward assumes that bridging from `bmcs_truth_at` (Preorder D) to `truth_at` (AddCommGroup D) is "structural induction" — but no one has verified this in Lean. The two functions have **different type signatures**, different recursion structures, and different treatment of:

- Domain predicates in WorldHistory
- The Ω bijection (canonical families vs. all shift-closed histories)
- The `ShiftClosed Ω` requirement

The box case is particularly dangerous: `truth_at` quantifies over ALL shift-closed Ω, while `bmcs_truth_at` quantifies over bundle families. These are different sets, and no report verifies the ShiftClosed property for the canonical Ω.

**Verdict**: This is a potentially fatal gap in every approach that relies on the "trivial task frame trick." The transfer theorem must be fully sketched in Lean before any plan based on it can be trusted.

### 3.2 The ShiftClosed Gap

`valid` requires `ShiftClosed Ω`. For the canonical construction, Ω = {canonicalHistory B fam hfam | fam ∈ B.families}. Time-shifting a canonical history by Δ produces a history with states(t) = fam.mcs(t - Δ), which corresponds to a DIFFERENT family — possibly not in B.families.

For Ω to be shift-closed, B.families must be shift-closed: for every family fam and shift Δ, the shifted family (mapping t ↦ fam.mcs(t + Δ)) must also be in B.families. The Zorn's-lemma-based modal saturation has no mechanism to preserve this.

**Nobody has checked whether the BFMCS construction produces shift-closed families.** This is a genuine unexamined gap.

### 3.3 The Trivial task_rel Keeps Re-Emerging

The user explicitly banned `task_rel := fun _ _ _ => True`. Yet research-016 through research-020 all propose this exact approach, reframed as the "trivial task frame trick." This is intellectually dishonest. The justification — "the task_rel only constrains WorldHistories, not truth" — is precisely why it was banned.

**The deeper mathematical finding**: TM's axioms say NOTHING about task durations. No temporal axiom mentions the duration parameter. The group structure is an artifact of the TaskFrame formalism, not the logic. Therefore, the canonical task_rel is necessarily trivial — **TM is too weak to determine a unique non-trivial task relation in the canonical model**. This is not a proof failure; it is a theorem about the logic's expressiveness.

If the trivial task_rel is used, this finding should be stated explicitly as a theorem, not hidden as an implementation detail.

### 3.4 The Two-Layer Architecture Was Identified But Never Implemented

Research-015 correctly diagnosed: "The root cause is an architectural mismatch, not a missing lemma." The BFMCS layer needs only `[Preorder D]`; the semantic layer needs `[AddCommGroup D]`. This was confirmed by three independent teammates in that session.

Research-016/017 specified the minimal hierarchy precisely. Research-020 mentions it approvingly. Yet **all four implementation plans (v1–v4) try to force D through the EXISTING architecture requiring AddCommGroup at the semantic layer**. The round peg is being forced through the square hole while the square peg is held in the other hand.

The two-layer refactor would:
- Eliminate the AddCommGroup requirement on the canonical D
- Make the sorry-free fragmentFMCS directly usable for completeness
- Reduce sorry count from 3 to 0 via refactoring, not new proofs
- Properly separate temporal structure (Preorder) from algebraic structure (AddCommGroup)

Estimated effort: 20–30 hours refactoring + 10–15 hours new proofs. Risk: regressions in existing sorry-free code.

### 3.5 The Constant Witness Family Problem Is Deeper Than Acknowledged

Zorn's lemma (used in modal saturation) has no mechanism to guarantee temporal coherence of witness families. Research-014 discovered that constant witness families (fam(t) = M for all t) are NOT temporally coherent because `F ψ ∈ M ⇏ ψ ∈ M` in general. The proposed mitigation — "use fragment-based witness families" — was never verified to actually compose correctly with the rest of the construction.

Specific unverified claims:
1. That different fragment-based families can be consistently indexed by the same D = ℤ
2. That the families share compatible indexing when different witnesses are rooted at different MCSes
3. That the truth lemma still works when different families come from different fragments

### 3.6 "D = Int is Justified" Argument Is Mathematically Correct but Lazy

Research-019 argues: "Using D = ℤ is a choice of witness, not a restriction on the logic." This is true but avoids the user's actual question: what D does the logic's proof theory *naturally produce*? Research-010/011 came closest to answering this via the BidirectionalQuotient, but research-016+ abandoned this line in favor of the "just use ℤ" shortcut.

---

## Part 4: Outside-the-Box Alternatives

### 4.1 Fragment-Based Witness Families with Independent Chains (Highest Priority New Idea)

Each Diamond(ψ) obligation at world w gets its own BidirectionalFragment rooted at the witness MCS M_ψ. This fragment has sorry-free fragmentFMCS via `forward_F_stays_in_fragment` / `backward_P_stays_in_fragment`. The fragment is embedded into ℤ via its own chain — **the chain only needs to hit the witnesses needed for M_ψ's truth lemma**, not globally surject onto everything.

Why this could break the circularity: the witness family's temporal coherence is established BEFORE modal saturation, not after. Each fragment is independently sorry-free. The global BFMCS is assembled from independently-coherent pieces.

**Critical question to verify**: Does the box backward case of the truth lemma require temporal coherence for witness families, or only the eval family? If only the eval family, this approach immediately solves the problem.

### 4.2 D = ℚ (Dense Time) to Bypass SuccOrder

If the BidirectionalFragment is densely ordered (which is plausible — Lindenbaum extensions can always create intermediate MCSes given density-like axioms), then by Cantor's theorem for countable dense linear orders without endpoints, the fragment is order-isomorphic to ℚ. Mathlib has `Order.Iso.toRat` and related infrastructure. ℚ has `[AddCommGroup ℚ] [LinearOrder ℚ] [IsOrderedAddMonoid ℚ]`, so it satisfies all requirements.

This would entirely bypass the SuccOrder blocker (which only affects discrete time) and the DovetailingChain F-persistence problem (which requires integer indexing).

**Requires verifying**: Is the BidirectionalFragment dense? (Between any two fragment elements, is there a third?) This is a mathematical question about Lindenbaum extensions that has not been investigated.

### 4.3 The Pruning/Decision Procedure Route (Long-Term, High Reward)

Doczkal and Smolka proved completeness for K* (basic tense logic with G, H, F, P operators) in Coq using a pruning-based decision procedure. K* is closely related to TM's temporal fragment. Their approach gives:
- Completeness as a corollary of decidability
- Finite model property for free (no Int-indexed families needed)
- No temporal coherence problem (finite models are constructed directly)

TM adds S5-style modal operators and task_rel to K*. If TM has the finite model property (uninvestigated), the pruning approach directly applies. Even if the full FMP fails, the pruning technique could handle the temporal fragment while modal saturation uses the existing Zorn approach.

This is a multi-month project but would be a transformative result: decidability implies completeness implies correct implementation.

### 4.4 The Algebraic Path (Already Started, Abandoned at Task 700)

The project has `Theories/Bimodal/Metalogic/Algebraic/` with LindenbaumQuotient.lean, BooleanStructure.lean, UltrafilterMCS.lean (with sorries), and InteriorOperators.lean. The Jonsson-Tarski representation theorem says every Boolean algebra with operators is represented by an algebra of sets on a relational structure. Applied to TM:
- The Lindenbaum algebra is a BAO with G, H as operators
- Its Stone space (ultrafilters = MCSes) carries a Kripke structure
- Accessibility = CanonicalR
- Completeness follows from representation

This avoids Int-indexed families and temporal coherence entirely — it works globally with the full MCS set. The algebraic path is mathematically the most elegant but requires completing the Algebraic/ infrastructure.

### 4.5 Investigating the Finite Model Property

The adequate set method (Solovay 1973) restricts MCSes to a finite subformula closure. For weak completeness (single formula), this gives a finite model construction that avoids all Int-indexed family machinery. Whether TM has FMP has never been investigated. If it does, a large class of proof complications simply disappear.

---

## Part 5: Synthesis and Recommended Paths

### 5.1 Conflict Resolution Between Teammates

**Conflict 1: Trivial task_rel — banned vs. mathematically natural**

- Teammate B: The trivial task_rel keeps re-emerging and is an engineering dodge, but notes it may be mathematically unavoidable.
- Teammate C: TM's axioms say nothing about task durations; trivial task_rel is the *correct* canonical one.
- **Resolution**: Both are right. If the trivial task_rel is used, it must be presented honestly as a mathematical theorem ("TM does not determine canonical task durations") rather than an implementation shortcut. The user's ban on trivial task_rel may need to be revisited in light of this finding.

**Conflict 2: Two-layer refactor vs. direct construction**

- Teammate A: Recommends Fragment Enumeration into ℤ/ℚ as immediate path.
- Teammate B: Recommends two-layer refactor as the "right" solution.
- Teammate C: Recommends fragment-based witness families as the cleanest engineering fix.
- **Resolution**: All three are compatible. The two-layer refactor is the long-term correct architecture. Fragment-based witness families is the mechanism for achieving it. D = ℚ is the embedding target if density holds.

**Conflict 3: Transfer theorem difficulty**

- Teammate A: Estimates 15–25 hours for Fragment Enumeration.
- Teammate B: Notes that transfer theorem has never been proven; box case will be particularly hard; real estimate is 80–120 hours total.
- **Resolution**: Teammate B's critique is correct. The transfer theorem difficulty is the most under-estimated risk. Any plan that relies on `bmcs_truth_at ↔ truth_at` must prototype this transfer first.

### 5.2 Recommended Path (Ordered by Priority)

**Immediate Investigation (before committing to any plan):**

1. **Verify whether the truth lemma box backward case requires temporal coherence for witness families.** Read the proof tree at TruthLemma.lean and CanonicalCompleteness.lean. If only the eval family needs TC (i.e., the box case uses modal_backward which is a separate property), fragment-based witnesses immediately work.

2. **Investigate whether the BidirectionalFragment is dense.** A short Lean experiment: given two fragment elements w₁ < w₂, does Lindenbaum extension always produce an element strictly between them? If yes, D = ℚ unlocks.

3. **Prototype the ShiftClosed verification.** Check whether canonical families are shift-closed. This is non-negotiable if the trivial task frame approach is used.

**Path A (Most Pragmatic, 20–40 hours):**
Fragment-based witness families + D = ℤ or ℚ + restricted truth lemma (eval family TC only if box case allows it). This is the minimum change to eliminate the 3 sorries without architectural refactoring.

**Path B (Most Correct Architecture, 40–60 hours):**
Two-layer refactor separating `TemporalFrame [LinearOrder D]` from `TaskFrame [AddCommGroup D]`. Prove completeness at the temporal level using the BidirectionalFragment directly. Bridge to standard `valid` via a single embedding lemma. This is the architecturally sound solution.

**Path C (Most Ambitious, 3–6 months):**
Investigate finite model property + pruning/decision procedure à la Doczkal-Smolka. If successful, this is a publishable research result that makes completeness a corollary of decidability.

**Path D (Most Elegant Long-Term):**
Complete the algebraic path (LindenbaumAlg → Stone space → Jonsson-Tarski representation). Bypasses all family/temporal coherence issues. Most mathematically natural for a logic text.

### 5.3 What Should Be Abandoned

The following should be marked PERMANENTLY ABANDONED (not just blocked) in the task artifacts:

- Plan v3 (SuccOrder on BidirectionalQuotient): coverness is mathematically impossible
- Plan v4 (Grothendieck construction): quotientSucc_pred_inverse is semantically invalid
- DovetailingChain FMCS: F-persistence is mathematically impossible through GContent
- Fragment automorphism → AddCommGroup: trivial automorphism group
- Changing the `valid` definition: breaks soundness

---

## Part 6: What the Current Sorry-Free Infrastructure Provides

Despite the blockers, approximately 5000+ lines of proven sorry-free Lean code is available:

| Module | Lines | Key Content |
|--------|-------|-------------|
| BidirectionalReachable.lean | ~830 | Fragment, totality, F/P closure, LinearOrder on quotient |
| CanonicalCompleteness.lean | ~660 | fragmentFMCS, enriched seeds, quotientSucc/Pred infrastructure |
| CanonicalFrame.lean | ~400 | CanonicalR, reflexivity, transitivity, forward_F/backward_P |
| CanonicalFMCS.lean | ~300 | FMCS over CanonicalMCS |
| TruthLemma.lean | ~350 | bmcs_truth_lemma (all 6 formula cases) |
| ModalSaturation.lean | ~200 | saturated_modal_backward |
| Representation.lean | ~600 | Completeness chain (sorry-free GIVEN sorry-free input) |

The 3 remaining sorries all reduce to `fully_saturated_bfmcs_exists_int`. If this single theorem is proven, `standard_weak_completeness` and `standard_strong_completeness` become sorry-free immediately via the existing chain.

---

## Part 7: The Questions That Must Be Answered Before the Next Plan

Before writing implementation plan v5, the following must be settled:

1. **Box backward case**: Does it require temporal coherence for witness families, or only for the eval family? (Read TruthLemma.lean lines 280–300.)

2. **ShiftClosed verification**: Are canonical families shift-closed under the existing BFMCS construction? (Read WorldHistory.lean / Validity.lean definitions.)

3. **Fragment density**: Is the BidirectionalFragment dense? (Mathematical investigation of Lindenbaum extensions.)

4. **Transfer theorem sketch**: Can `bmcs_truth_at ↔ truth_at` be sketched concretely for each formula case? (Prototype in Lean before committing to this approach.)

5. **Trivial task_rel status**: Is the user willing to accept trivial task_rel if it is presented as a mathematical theorem about TM's expressiveness rather than an engineering shortcut?

Answering these 5 questions will narrow the viable paths from 4 to 1 or 2, enabling a confident implementation plan.

---

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| teammate-a | Mapped ideals, cataloged 20 reports by elegance | Completed | High |
| teammate-b | Critical gap analysis (5 gaps, 4 "cheap" elements, 5 underthought areas) | Completed | High |
| teammate-c | Outside-the-box alternatives (pruning, algebraic, D=ℚ, lazy witnesses) | Completed | High |

**Conflicts resolved**: 3 (trivial task_rel status, two-layer vs. direct, transfer theorem difficulty). All resolved with nuanced synthesis.

**Gaps identified**: 5 critical unverified claims (transfer theorem, ShiftClosed, witness family independence, box case TC requirement, fragment density).

---

## References

- Doczkal-Smolka CTL/K* Coq: https://link.springer.com/chapter/10.1007/978-3-319-08970-6_15
- comp-dec-modal (Coq K*): https://github.com/coq-community/comp-dec-modal
- From: Synthetic Completeness (CPP 2025): https://dl.acm.org/doi/10.1145/3703595.3705882
- Bentzen S5 Lean: https://github.com/bbentzen/mpl
- Jonsson-Tarski BAO Representation (1951/52)
- Goldblatt: Logics of Time and Computation (1992)
- Solovay adequate set method (1973)
