# Teammate D Findings: Task 93 Round 15 — Horizons Research

**Date**: 2026-04-14
**Role**: Teammate D — Horizons Researcher
**Focus**: Strategic alignment, literature fit, architectural concerns, publication readiness

---

## 1. Strategic Analysis

### 1.1 Where We Actually Are

The active-path sorry situation has been clarified by reading the current code and handoffs:

- **ROAD_MAP.md reports 1 sorry** at `Completeness.lean:154`, but the actual code shows the sorry is now dispersed across **6 sites in `RootScopedChain.lean`** (lines that, after the Phase 1 implementation, are approximately 790, 816, 823, 876, 881, 886 in the current file).
- `Completeness.lean` itself now compiles via `dd_countermodel`, which delegates to `RootScopedChain.lean`.
- `CanonicalModel.lean` has 5 additional sorry sites (lines 518, 525, 614, 619, 649, 655) that are labeled DEAD CODE or BLOCKED but still present.

The architectural flow has evolved significantly:
```
bx_completeness (Completeness.lean — sorry-free)
  -> dd_countermodel (RootScopedChain.lean)
     -> dd_bfmcs_restricted_tc (SORRY line ~876)
     -> dd_bfmcs_restricted_buc (SORRY line ~881)
     -> dd_bfmcs_restricted_fuc (SORRY line ~886)
        -> dd_fmcs_forward_F (SORRY line ~816, t<0 case)
           -> rr_fwd_chain_forward_F (SORRY line ~790)
        -> dd_fmcs_backward_P (SORRY line ~823)
```

### 1.2 Alignment with ROAD_MAP Trajectory

The current plan (v14) aligns well with the roadmap's stated goals:

- **ROAD_MAP goal**: "1 sorry blocking `bx_completeness`" — the current approach will close all 6 remaining sorries in `RootScopedChain.lean`, which transitively closes the roadmap's stated sorry.
- **Task 95** (`#print axioms` audit): The ordered defect-discharge approach uses only the existing BX axioms and Lindenbaum/Zorn infrastructure. No new axioms are introduced. The `#print axioms` audit should pass cleanly.
- **Publication path**: The approach matches Burgess 1984's original construction (see Section 2 below), which makes the proof strategy both mathematically sound and recognizable to reviewers familiar with that literature.

### 1.3 Sunk Cost Assessment

After 14 rounds of research and one partial implementation:

**What has been accomplished that is reusable and correct** (zero sorry):
- `OrderedSeedConsistency.lean`: The key theorem `enriched_resolving_seed_consistent` is proved. This is the mathematical heart of why the ordered defect-discharge chain works.
- `RootScopedChain.lean` lines 1–684: All library lemmas (FF_imp_F, F_mono, F-conjunction, BX11 at MCS level, enriched fold infrastructure, chain definitions, g_content/h_content propagation, box stability) are proved.
- `Quasimodel/Construction.lean`, `Realization.lean`, `Frame.lean`: 673 lines sorry-free; Until/Since eventuality resolution closed.

**What needs to change**: Only the `rr_fwd_chain` forward-F claim and the six downstream sorries. The plan is NOT to redo the quasimodel infrastructure or the whole chain — just to restructure the `discharge_fwd_step` to use the ordered target.

**Sunk cost verdict**: The investment has been productive. 2,289 lines of sorry-free infrastructure plus `OrderedSeedConsistency.lean` are genuine mathematical progress. The only wasted work was the several attempts to prove `rr_fwd_chain_forward_F` using the round-robin disjunction, which is a documented dead end (handoff 15). This is NOT dead end #13 — the ordered defect-discharge approach is distinct from all 12 documented anti-patterns.

---

## 2. Literature Findings

### 2.1 The Burgess-Xu Approach (Primary Reference)

**Burgess (1982/1984)** and **Xu (1988)** give the completeness proof for the Since-Until tense logic over all reflexive linear orderings. From the Stanford Encyclopedia of Philosophy (Burgess-Xu supplementary entry):

The completeness proof uses a canonical model built from maximal consistent sets. The key technical issue — how to handle F-obligations (formulas of the form F(ψ) that must eventually be witnessed) — is addressed in Burgess's construction by building a chain where each F-obligation is discharged at some finite future step. The ordering of which obligation to discharge first is determined by the linear order axiom (what the codebase calls BX11, `temp_linearity`).

The construction in the current codebase matches this description:
- BX11 (`temp_linearity_mcs`) provides the pairwise ordering of F-witnesses.
- `enriched_resolving_seed_consistent` (`OrderedSeedConsistency.lean`) proves the seed is consistent when the earliest-witness formula is isolated.
- The ordered defect-discharge chain iterates this, resolving one defect per step.

**The F-persistence problem in Burgess**: Burgess handles F-persistence by including the "F-carry" in the seed indirectly through the BX11 compound, not by directly adding F(ψ) formulas to the resolving seed. This is exactly what the current approach does via `enriched_fwd_fold`. The seed is `{psi_j, compound_F} ∪ g_content(M)` where `compound_F` packages all other F-obligations. The key theorem guarantees consistency of this seed.

**Confidence that the approach matches Burgess**: HIGH. The ordered seed consistency theorem (`enriched_resolving_seed_consistent`) is the Lean formalization of the key consistency lemma that makes Burgess's construction work.

### 2.2 The Verbrugge-de Jongh-Veltman "Completeness by Construction" Method

The 2004 paper "Completeness by construction for tense logics of linear time" (ILLC, Amsterdam) applies the Amsterdam constructive method to tense logics for structures consisting of copies of Z (integer-indexed chains). This is directly relevant because:
- The codebase uses `Int`-indexed chains (`dd_fmcs`).
- The constructive method builds the canonical model step by step, resolving eventuality obligations at each step.
- The paper covers linear discrete structures, which include Z.

The "constructive method" they describe contrasts with the Henkin method: instead of enriching the language with witness constants, the construction builds the model directly from MCS chains. This matches the current approach (no Henkin witness closure, no enriched language).

**Key difference from current approach**: The Amsterdam constructive method typically uses a single infinite chain where obligations are discharged one at a time over the natural numbers. The current implementation does the same (discharge for sigma_list.length steps, then identity tail). The match is good.

### 2.3 Venema (1993) and Reynolds (1994/1996/2003)

Venema (1993) showed that the strict and reflexive variants of Since-Until admit complete axiomatizations over different classes of orderings. His axioms for the reflexive case include all the BX axioms. His completeness proof uses canonical models, and the F-eventuality discharge in Venema's proof follows the same pattern as Burgess: BX11 provides the order, defects are discharged in witness-earliest order.

Reynolds (1994/1996) extended these results. Reynolds (2003) gave an axiomatization for Ockhamist validity, but the full proof "has never appeared in print" (SEP, temporal logic entry). This is NOT relevant to the current task — the current logic is the standard since-until tense logic, not Ockhamist branching-time logic.

### 2.4 Existing Lean 4 Formalizations

Searching for relevant Lean 4 formalizations:

- **LeanearTemporalLogic** (GitHub, mrigankpawagi): Formalizes LTL syntax and semantics. Does NOT cover completeness — only the semantics and basic lemmas.
- **Lentil** (GitHub, verse-lab): TLA in Lean 4. No completeness proofs for temporal operators.
- **Foundation** (FormalizedFormalLogic): Covers classical logic and modal logic completeness. The modal completeness infrastructure (Lindenbaum, MCS machinery) is similar to what is already built in this codebase. No temporal logic completeness proofs found.

**Assessment**: There are NO known Lean 4 formalizations of completeness for Since-Until temporal logic. This project is apparently the first, which increases publication value but also means there are no reference implementations to compare against. The mathematical approach must be validated against the paper literature rather than existing formalizations.

### 2.5 The F-Persistence Problem in Literature

No published paper explicitly names "F-persistence" as a problem — it appears implicitly in every completeness proof for Since-Until logic. The standard solution is always some variant of the BX11 witness ordering:

1. Burgess (1982): Uses temporal linearity to order F-obligations.
2. Xu (1988): Simplifies the axioms but uses the same ordering argument.
3. Goldblatt (1992): "Logics of Time and Computation" treats tense logic completeness, following Burgess's chain construction for the Since-Until case.
4. Verbrugge et al. (2004): Uses the constructive method, same ordering.

The current codebase has now proved the key ordering theorem (`enriched_resolving_seed_consistent`) and has the BX11 machinery in place. The gap is only in the Lean formalization of how to apply this theorem iteratively to define the chain and prove termination.

---

## 3. Creative and Unconventional Approaches

### 3.1 Could We Bypass FMCS/BFMCS Entirely?

The current architecture goes: BXPoint canonical frame → FMCS (Int-indexed chain) → BFMCS (family of FMCS) → parametric representation theorem → TaskModel.

An alternative: bypass the Int-indexed FMCS entirely and construct the TaskModel directly from BXPoints. The BXPoint canonical frame (in `Frame.lean`) is already sorry-free, and the truth lemma for BXPoints holds. If we could directly embed BXPoints into a TaskModel without going through the FMCS/BFMCS machinery, the forward_F / backward_P / until-coherence obligations would be handled by the existing quasimodel infrastructure.

**Assessment**: This is the "constant history" approach that was rejected as dead end #1 in the anti-pattern list. Constant histories make G(α) ≡ α, destroying the temporal content. However, a non-constant embedding using BXPoint CHAINS (not constant histories) is exactly what the quasimodel/Realization.lean already does for the Until/Since eventuality resolution in Frame.lean. The question is whether we can extend that infrastructure to the full TaskModel.

**Problem**: The quasimodel chains in `Realization.lean` are finite (they discharge a single Until-defect). The FMCS/BFMCS requires an infinite Int-indexed chain. The bridge from finite quasimodel chains to infinite Int-indexed chains is the exact problem that has not been solved.

**Verdict**: Unconventional but not viable without solving the same forward_F problem in a different form.

### 3.2 Well-Founded Recursion on Defect Sets (Alternative Termination)

The plan uses a fixed-length chain (`Nat.rec` for `sigma_list.length` steps). An alternative is to use Lean's `WellFoundedRelation` machinery with a decreasing measure on a suitable set.

The correct measure for the ordered defect-discharge chain is:

```
measure(M, sigma_list) = {chi in sigma_list | F(chi) in M, chi not_in M, chi NOT YET RESOLVED}
```

where "not yet resolved" is tracked by a separate counter or a "resolved set" parameter. This avoids the non-monotonicity issue (a chi can re-become a defect after being resolved, but can only be "newly resolved" once per round).

**Assessment**: More complex to formalize than the fixed-length approach. The fixed-length chain is safer for Lean — `Nat.rec` with explicit termination is cleaner than well-founded recursion with custom measures. Recommend sticking with the plan's approach.

### 3.3 Defer Backward Until Coherence via Logical Weakening

The `restricted_buc` sorry is the HARDEST one (50% confidence in report 14, FATAL warning from Teammate C). A creative approach:

**Observation**: The truth lemma for Until requires the FORWARD direction of Until coherence (`restricted_fuc`) and the BACKWARD direction (`restricted_buc`). But looking at the semantics:

```lean
| Formula.untl φ ψ => ∃ s : D, t ≤ s ∧ truth_at M Omega τ s ψ ∧
    ∀ r : D, t ≤ r → r < s → truth_at M Omega τ r φ
```

The backward Until coherence is needed for the `⊇` direction of the truth lemma: if `(φ U ψ) ∈ MCS(t)` in the model, then the model satisfies `φ U ψ` at time `t`. This requires finding the witness `s` and verifying the guard on `[t, s)`.

The existing `bx_until_eventuality_resolution` in `Frame.lean` (proved by the quasimodel/Realization infrastructure) already gives the witness `s` with `ψ ∈ MCS(s)`. The guard condition requires `φ ∈ MCS(r)` for all `r ∈ [t, s)` in the chain. For the BXPoint chain used in the truth lemma, this comes from BX5 (`self_accum_until`): if `φ U ψ ∈ MCS(r)` and `ψ ∉ MCS(r)`, then `φ ∈ MCS(r)`.

**Key insight**: `restricted_buc` might not be needed at all if the truth lemma proof uses `bx_until_eventuality_resolution` directly. The truth lemma path goes through the quasimodel infrastructure, not through FMCS/BFMCS. Looking at `TruthLemma.lean`:

From ROAD_MAP.md: "TruthLemma.lean: Sorry-free, proved by formula induction. All cases (`atom`, `bot`, `imp`, `box`, `G`, `H`, `U`, `S`) are sorry-free."

But `TruthLemma.lean` is for the BXPoint canonical frame, NOT for the parametric representation theorem that `dd_countermodel` uses. The parametric truth lemma (in `Algebraic/ParametricTruthLemma.lean`) is separate and does require the BFMCS coherence properties.

**Assessment**: This alternative requires deeply understanding whether `restricted_buc` and `restricted_fuc` are truly needed for the parametric representation theorem, or whether a specialized embedding could bypass them. This is worth investigating as a fallback but should not block Phase 1-3 implementation.

### 3.4 Scoped Spawning of Task 95 Dependency

Task 95 (`#print axioms` audit) depends on Task 93. If backward Until coherence (`restricted_buc`) remains blocked after Phases 1-3 are complete, one option is:

1. Mark `dd_bfmcs_restricted_buc` with a `sorry` and a detailed mathematical justification comment.
2. Complete the other 5 sorries (Phases 1-3 of the v14 plan).
3. Spawn a task 96 for `restricted_buc` specifically.
4. Allow task 95 to proceed on the partial closure.

This is the "pragmatic partial closure" approach. The `#print axioms` audit would report that `dd_bfmcs_restricted_buc` uses `sorry`, which is honest. The remaining 5 sorries would be clean.

**Assessment**: Viable as a FALLBACK only. The primary effort should attempt to close all 6 sorries.

---

## 4. Recommendations for Long-Term Direction

### 4.1 Primary Recommendation: Execute Plan v14, Phase 1 First

The ordered defect-discharge chain is the correct mathematical approach. Report 14's 4-teammate consensus is well-founded. The implementation plan (v14) is well-specified. The key recommendation is:

**Execute Phase 1 (ordered discharge chain definition + proof that target is direct) before anything else.** This is the highest-leverage step — it unblocks all 5 of the other sorries that depend on `rr_fwd_chain_forward_F`.

The critical Lean proof step is `target_stays_direct_in_fold`: when the BX11 fold processes formulas with the earliest-witness formula as target, cases 1 or 2 always fire (not case 3). The semantic argument is airtight (linear order on witnesses), but formalizing it in Lean requires accessing the right instance of `temp_linearity_mcs`.

### 4.2 Termination: Use Fixed-Length Chain, Not Well-Founded Recursion

For Lean formalization, the fixed-length chain with `Nat.rec` for exactly `sigma_list.length` steps is cleaner and avoids the non-monotonicity complications. The identity tail (chain(t) = terminal for t > N) handles the case where n ≥ sigma_list.length.

The key property to prove: after `sigma_list.length` steps, the terminal MCS has no F-defects in sigma_list. Proof approach:
- At each step, the earliest-witness defect is resolved (not disjunctive — directly in M').
- A defect can be re-introduced at a later step only if it was non-defective at M (chi in M) and chi fell out of the Lindenbaum extension. But the fold includes ALL sigma formulas, so chi is either direct or F-wrapped. F-wrapped chi is still a defect at M', but F(chi) is in M' (not a new defect in the set sense, since F-formulas are invariant by `no_new_f_defects`).
- After at most sigma_list.length steps, every formula in sigma_list has been the target at least once and its F-obligation discharged. Since F-defects cannot re-appear (F-formulas are invariant), the terminal is defect-free.

This argument requires formalizing: "after |sigma_list| steps, every formula with F(psi) in chain(0) has been the target at some step." This is a pigeonhole argument on a finite list — straightforward in Lean.

### 4.3 Backward Until: Approach Path C with Fallback to Spawn

For `restricted_buc`, the recommended approach (from report 14) is Path C: extend the seed consistency proof to include Until formulas. Specifically:

Given `(phi U psi) in M` and `psi in chain(s)` and `phi in chain(r)` for all `r in [t, s)`:
- `F(psi) in chain(t)` (by BX10 from `(phi U psi) in chain(t)`)
- `psi in chain(s)` (by `forward_F`, Phase 2)
- `(phi U psi) in chain(t)` is already given as a hypothesis

The backward direction: we need `(phi U psi) in chain(t)` when given the semantic witness. But `(phi U psi) in chain(t)` is the HYPOTHESIS (it's in the MCS at time t), not the conclusion. The truth lemma's backward direction says: if the model satisfies `phi U psi` at t, then `(phi U psi) ∈ chain(t)`. This is HARDER — it requires syntactically proving that the MCS at time t contains the Until formula.

This may require a fundamentally different argument for the backward Until direction. If Path C fails, spawn a separate task 96 and close the other 5 sorries.

### 4.4 Post-Task 93 Work

Once Task 93 is closed:
- **Task 95** (`#print axioms` audit): Can proceed immediately. The axiom trace should show only the BX axioms and standard Lean/Mathlib dependencies.
- **Publication preparation**: The completeness proof is structurally sound and matches the published literature. The quasimodel infrastructure (2,289 lines, sorry-free) plus the ordered defect-discharge chain will constitute a substantial and publishable Lean 4 formalization of BX completeness — apparently the first such formalization.
- **Dense time completeness**: A separate roadmap item. The current architecture (reflexive linear orderings) would need to be generalized.

---

## 5. Confidence Assessment

| Area | Confidence | Basis |
|------|------------|-------|
| Phase 1 (ordered discharge chain definition) | HIGH (90%) | Mathematical argument is airtight; Lean infrastructure exists |
| Phase 2 (forward_F proof) | HIGH (85%) | Depends on Phase 1; defect-free terminal proof straightforward by counting |
| Phase 3 (backward_P, restricted_tc, restricted_fuc) | HIGH (80%) | Symmetric to Phase 2 or follows from forward_F + BX axioms |
| Phase 4 (restricted_buc) | MEDIUM (45%) | Genuine architectural obstacle; no known syntactic proof |
| Literature alignment | HIGH (95%) | Approach matches Burgess/Xu/Goldblatt construction directly |
| Publication readiness (for 5-of-6 sorries closed) | HIGH (90%) | First Lean 4 formalization of BX completeness; significant contribution |
| Sunk cost assessment | CLEAR | Investment is productive; no dead end #13 risk |

---

## Sources

- [Temporal Logic — Supplement: Burgess-Xu Axiomatic System](https://seop.illc.uva.nl/entries/logic-temporal/burgess-xu.html)
- [Completeness by Construction for Tense Logics of Linear Time (Verbrugge, de Jongh, Veltman)](https://festschriften.illc.uva.nl/D65/verbrugge.pdf)
- [Axioms for Tense Logic: Since and Until (Burgess 1982)](https://www.researchgate.net/publication/38355634_Axioms_for_tense_logic_I_Since''_and_until'')
- [Temporal Logic — Stanford Encyclopedia of Philosophy](https://plato.stanford.edu/entries/logic-temporal/)
- [Chapter 10: Temporal Logic (Venema)](https://staff.science.uva.nl/y.venema/papers/TempLog.pdf)
- [Logics of Time and Computation (Goldblatt, CSLI)](https://web.stanford.edu/group/cslipublications/cslipublications/site/0937073946.shtml)
- [LeanearTemporalLogic (Lean 4 LTL formalization)](https://github.com/mrigankpawagi/LeanearTemporalLogic)
- [Foundation: Formalization of Mathematical Logic in Lean 4](https://github.com/FormalizedFormalLogic/Foundation)
