# Teammate A Findings: Prerequisite Analysis for Reflexive Switch

**Date**: 2026-03-22
**Angle**: What must happen before the switch, and task-by-task impact analysis

---

## Executive Summary

The switch from strict to reflexive G/H semantics (Task 29) has a cascading but mostly
**positive** effect on the open task landscape. The most critical finding is that
**Task 26 is entirely superseded by Task 29**, and **Task 24 becomes simpler but not
fully eliminated**. The switch does NOT meaningfully affect the sorry structure in the
dense completeness pipeline (Tasks 18, 997), because those sorries stem from termination
and modal saturation issues that are semantics-independent.

The single most important prerequisite question is ordering: Task 29 **can and should
proceed first** because it eliminates one axiom (canonicalR_irreflexive_axiom), makes
another provable (discreteImmediateSuccSeed_consistent_axiom), and creates a cleaner
foundation for Tasks 18 and 997 to complete against. The main risk is that Task 29
changes FMCS field signatures (FMCSDef.lean: `t < t'` to `t ≤ t'`), which propagates
through all downstream proofs; this breakage must be repaired as part of Task 29 itself.

---

## Task-by-Task Impact Analysis

### Task 18: Dense Representation Theorem

**Recommendation**: AFTER (but not blocked)

**Reasoning**:
Task 18 targets sorries in `DovetailedTimelineQuot.lean` (lines 295, 806, 878, 959, 1028)
and in building the multi-family BFMCS over `DovetailedTimelineQuot`. The plan v4 is
explicit that phases 1 and 2 are complete (CantorPrereqs.lean and DovetailedCoverage.lean),
and the remaining work is:

1. **j>0 termination sorries** (lines 806, 878, 959): These are pure termination/
   well-foundedness arguments in `forward_F_chain_witness` and `backward_P_chain_witness`.
   The reflexive switch does NOT help or hinder these — they depend on a lexicographic
   measure over (build_stage, formula_depth), which is entirely independent of whether
   G quantifies over `< t` or `≤ t`.

2. **Density intermediate sorry** (line 295 in `instDenselyOrderedDovetailedTimelineQuot`):
   This sorry uses `canonicalR_irreflexive` to prove strict ordering of density witnesses.
   Under reflexive semantics, `canonicalR_irreflexive` becomes `canonicalR_reflexive`
   (CanonicalR M M holds) and `canonicalR_antisymmetric` (mutual CanonicalR implies M = N).
   The density proof needs strict ordering: `p < c < q`. Under reflexive semantics, the
   proof would need to use antisymmetry to establish `p ≠ c` and `c ≠ q`. The existing
   sorry can be discharged using either approach, but the proof structure changes slightly
   with reflexive semantics. **This sorry is in the dependency chain for DenselyOrdered,
   which feeds Cantor.** Task 18 cannot completely finish until this is resolved, whether
   before or after Task 29.

3. **Multi-family BFMCS construction** (Phase 4 of Task 18): The FMCS structure itself
   changes when Task 29 changes `forward_G` and `backward_H` signatures from `t < t'`
   to `t ≤ t'`. If Task 18 builds against the old signatures, its work will need a
   repair pass after Task 29. If Task 29 runs first, Task 18 builds against the correct
   final API.

**Conclusion**: Task 18 should proceed AFTER Task 29 to avoid rebuilding against changed
FMCS signatures. The semantic change does not fundamentally alter what Task 18 must prove,
but removes the need to handle irreflexivity explicitly in the density sorry.

---

### Task 22: Direct Multi-Family Bundle

**Recommendation**: AFTER (lower priority, partially done)

**Reasoning**:
Task 22 is in RESEARCHED state and proposes replacing `ClosedFlagIntBFMCS` with a direct
`DirectMultiFamilyBFMCS` construction. The `AlgebraicBaseCompleteness.lean` already
imports `DirectMultiFamilyBFMCS` (Task 22's product) via `construct_bfmcs_from_mcs_Int_v4`.

The reflexive switch affects Task 22 in one important way: the FMCS structure's
`forward_G` and `backward_H` conditions change from strict (`t < t'`) to reflexive
(`t ≤ t'`). This means:
- The Int-indexed chain in `DirectMultiFamilyBFMCS` must satisfy `G phi ∈ mcs(t) → phi ∈ mcs(t')` for ALL `t' ≥ t`, including `t' = t` itself
- Under reflexive semantics, this is actually EASIER to satisfy: G phi at t now implies phi at t (T-axiom), so the chain just needs to carry phi forward via g_content inclusion for `t' > t`, and phi at t itself for `t' = t`
- The sorry about `intFMCS_forward_F` (F witness existence) and `intFMCS_backward_P` are not affected by the strict/reflexive distinction — they concern existence of future witnesses, which is a seriality/completeness matter

**Conclusion**: Task 22 is not urgent (its partial product is already used), and should
proceed AFTER Task 29 to avoid the FMCS signature breakage.

---

### Task 24: Discrete Axiom Removal Cleanup

**Recommendation**: AFTER (partially resolved by Task 29)

**Reasoning**:
Task 24 proposes removing three axioms:
1. `discrete_Icc_finite_axiom` — Task 29 has NO effect on this axiom. It concerns
   finiteness of intervals in the discrete timeline quotient, which is a combinatorial
   property of the discrete order, not of G/H semantics. This axiom remains as technical
   debt regardless.

2. `discreteImmediateSuccSeed_consistent_axiom` — **Task 29 directly enables proving this**.
   The plan (Phase 6) explains: under reflexive semantics, `g_content(M) ⊆ M` holds by
   the T-axiom (since `G(φ) ∈ M` implies `φ ∈ M`). This eliminates the difficulty in
   Case 2 of `discreteImmediateSuccSeed_consistent`, where the seed includes blocking
   formulas `¬ψ ∨ ¬G(ψ)` for `¬G(ψ) ∈ M`. The proof no longer needs to show joint
   satisfiability of `g_content(M)` and blocking formulas at a successor — it can use
   `g_content(M) ⊆ M` directly and the T-axiom closure. **Task 29 Phase 6 handles this.**

3. `discreteImmediateSucc_covers_axiom` — This axiom (covering property) states that no
   MCS exists strictly between M and its discrete immediate successor. The semantic
   justification in the code comment says "Under strict semantics, the direct proof is
   complex because g_content(M) ⊈ M." Under reflexive semantics with T-axiom,
   `g_content(M) ⊆ M` holds, simplifying the covering argument. Whether the covering
   axiom becomes provable via T-axiom is less clear — covering is a combinatorial property
   of the blocking formula construction. The Task 29 plan does NOT claim to prove this
   axiom. Task 24 likely still needs to handle it.

**Conclusion**: Task 24 is partially superseded. `discreteImmediateSuccSeed_consistent_axiom`
should be handled in Task 29 Phase 6. The remaining discrete axioms (`discrete_Icc_finite`
and `discreteImmediateSucc_covers`) remain for Task 24. Task 24 should run AFTER Task 29.

---

### Task 26: Remove/Justify canonicalR_irreflexive_axiom

**Recommendation**: IRRELEVANT (completely superseded by Task 29)

**Reasoning**:
Task 26 was researched with the conclusion that three paths exist: (A) reflexive T-axiom
proof, (B) Gabbay IRR rule, (C) accept as axiom with documentation. The research
(report 02_synthesis.md) explicitly identifies Path A as: "Prove via Reflexive T-axiom
(if available)" with effort "Low."

**Task 29 IS Path A.** The plan for Task 29:
- Phase 5 explicitly removes `canonicalR_irreflexive_axiom` from `CanonicalIrreflexivity.lean`
- Adds `canonicalR_reflexive` (CanonicalR M M holds via T-axiom, since `g_content(M) ⊆ M`)
- Adds `canonicalR_antisymmetric` (mutual CanonicalR implies M = N via IRR machinery)
- Updates all 16 downstream usage sites (identified in Task 26 research)

The 1170-line proof infrastructure in `CanonicalIrreflexivity.lean` already contains the
complete proof for the reflexive case. The docstring in `CanonicalIrreflexivityAxiom.lean`
even describes the proof: it uses T-axiom (step 7: "Apply T-axiom: H(¬p) → ¬p") to derive
a contradiction from `CanonicalR(M, M)`.

**Conclusion**: Task 26 should be marked ABANDONED or EXPANDED (absorbed into Task 29).
There is no independent work to do in Task 26. Task 29 Phase 5 subsumes it entirely.

---

### Task 997: Wire Algebraic Base Completeness

**Recommendation**: AFTER (not blocked on Task 29, but benefits from it)

**Reasoning**:
Task 997 is in IMPLEMENTING state and focuses on the validity bridge between
`satisfies_at` (FlagBFMCS) and `truth_at` (TaskFrame). The plan v2 targets 2 sorries
in `AlgebraicBaseCompleteness.lean` (lines 115 and 142), both marked DEPRECATED.
The actual `algebraic_base_completeness` theorem (line 257) is proof-complete modulo
the sorries inside `construct_bfmcs_from_mcs_Int` (via `construct_bfmcs_from_mcs_Int_v4`
from `DirectMultiFamilyBFMCS`).

The reflexive switch affects Task 997 as follows:
- **FMCS signature change**: When Task 29 changes `forward_G` and `backward_H` from
  strict to reflexive, the `ParametricCanonicalTaskModel` and all FMCS instances in
  `AlgebraicBaseCompleteness.lean` must be updated. This is a mechanical change but
  requires a repair pass.
- **T-axiom in truth lemma**: `ParametricTruthLemma.lean` must handle the `s = t` case
  for G/H (Task 29 Phase 4). The `parametric_shifted_truth_lemma` used in the
  completeness proof at line 270 depends on this. If Task 29 Phase 4 is done first,
  Task 997 builds on a correct truth lemma.
- **The BFMCS sorries themselves** (in forward_F, backward_P, modal_backward for t≠0)
  are fundamentally about temporal witness existence and S5 modal saturation. These are
  NOT affected by strict vs. reflexive semantics.

**Conclusion**: Task 997's core blocking issue (the validity bridge and sorries in
DirectMultiFamilyBFMCS) is independent of the reflexive switch. However, the FMCS
signature changes from Task 29 will require a repair pass in the files Task 997 touches.
Task 997 should proceed AFTER Task 29 to avoid that breakage.

---

## Axiom-by-Axiom Impact Analysis

### SuccChainFMCS Axioms (from Task 23)

**`succ_chain_fam_p_step`** (line 335 of SuccChainFMCS.lean):
```
p_content(succ_chain_fam M0 (n+1)) ⊆ succ_chain_fam M0 n ∪ p_content(succ_chain_fam M0 n)
```
This axiom concerns P-step propagation for the entire succ_chain (including forward
chains). Under reflexive semantics, P-step becomes: `P(φ) ∈ mcs(n) → φ ∈ mcs(m)` for
some `m ≤ n` (inclusive). This is slightly weaker in requirement — the witness can now
be at the same time. The axiom itself (about content propagation) is not directly
affected by `<` vs `≤`, since it's about the relationship between consecutive MCSs
in the chain. **Not eliminated by Task 29; remains as axiom.**

**`f_nesting_boundary`** (line 583 of SuccChainFMCS.lean):
```
F(phi) ∈ M → ∃ d ≥ 1, iter_F d phi ∈ M ∧ iter_F (d+1) phi ∉ M
```
This axiom claims that F-nesting must eventually stop in an MCS. Under reflexive
semantics, F(phi) = ¬G(¬phi), and G is now reflexive. The semantic justification
(infinite F-nesting would require infinitely many distinct future worlds) remains valid
under reflexive semantics (reflexivity adds worlds but doesn't make the frame finite).
**Not eliminated by Task 29; remains as axiom.**

**`p_nesting_boundary`** (line 695 of SuccChainFMCS.lean):
Symmetric to f_nesting_boundary. **Same analysis — not eliminated by Task 29.**

### SuccExistence Axioms

**`successor_deferral_seed_consistent_axiom`** (line 266 of SuccExistence.lean):
The deferral seed is `g_content(u) ∪ {φ ∨ F(φ) | F(φ) ∈ u}`. Under reflexive
semantics, `g_content(u) ⊆ u` (T-axiom), so this seed is a subset of `u ∪ deferral_disjunctions`.
The consistency proof becomes: take any extension of u and add the disjunctions; since
each `φ ∨ F(φ)` is derivable from `F(φ) ∈ u` (right-disjunction introduction), and
`g_content(u) ⊆ u` is consistent, the joint seed is consistent. **Potentially provable
after Task 29** via T-axiom, though this is more complex than discreteImmediateSuccSeed.
Task 29 plan does not explicitly target this axiom.

**`predecessor_deferral_seed_consistent_axiom`** (line 311 of SuccExistence.lean):
Symmetric. Same analysis as above.

**`predecessor_f_step_axiom`** (line 516 of SuccExistence.lean):
```
f_content(predecessor_from_deferral_seed u) ⊆ u ∪ f_content u
```
This is the F-step condition for the predecessor construction (Succ(v, u) where v is
built as predecessor of u). Under reflexive semantics, FMCS forward_G now includes
the `t' = t` case, which means `g_content(v) ⊆ u` is the primary constraint on Succ(v, u),
and the f_content condition is additionally required. The T-axiom does not directly
simplify this axiom. **Not eliminated by Task 29.**

### DiscreteSuccSeed Axioms

**`discreteImmediateSuccSeed_consistent_axiom`** (line 284 of DiscreteSuccSeed.lean):
**Provable after Task 29.** The plan explicitly targets this in Phase 6. The proof:
- Under reflexive semantics, `g_content(M) ⊆ M` (T-axiom: G(φ) ∈ M → φ ∈ M)
- The seed is `g_content(M) ∪ blockingFormulas(M)`
- For Case 2 (L contains a blocking formula `¬ψ ∨ ¬G(ψ)` with `¬G(ψ) ∈ M`):
  - By MCS consistency of M: ψ ∉ M or G(ψ) ∉ M. Since `¬G(ψ) ∈ M`, we have `G(ψ) ∉ M`
  - By T-axiom: `g_content(M) ⊆ M`, so ψ might be in M
  - The blocking formula `¬ψ ∨ ¬G(ψ)` is derivable from `¬G(ψ) ∈ M` alone
  - The consistency proof uses: the seed formulas are all satisfiable in M's direct
    reflexive successor (which contains g_content(M) and satisfies blocking conditions)

**`discreteImmediateSucc_covers_axiom`** (line 414 of DiscreteSuccSeed.lean):
The covering property: no MCS K exists strictly between M and discreteImmediateSucc M.
The comment says "Under strict semantics, the direct proof is complex because
g_content(M) ⊈ M." Under reflexive semantics with T-axiom, `g_content(M) ⊆ M`.
This changes the proof structure:
- Under reflexive semantics, `CanonicalR(M, K)` means `g_content(M) ⊆ K`
- Since `g_content(M) ⊆ M`, M is a reflexive lower bound
- The covering proof must show: any K with `M ≤ K ≤ discreteImmediateSucc M` equals M or the successor

Whether this becomes provable depends on whether `g_content(M) ⊆ M` enables the
blocking formula argument to close. **Possibly provable after Task 29**, but the plan
does not claim to prove it. Task 24 should assess this after Task 29 completes.

---

## Sorry Impact Analysis

### DovetailedTimelineQuot.lean (sorries at lines 295, 788, 878)

**Line 295** (`instDenselyOrderedDovetailedTimelineQuot`): The density proof needs
`canonicalR_strict` to establish that the density intermediate `c` is strictly between
`p` and `q`. Under reflexive semantics, the relevant lemma becomes `canonicalR_antisymmetric`
(if CanonicalR(X,Y) and CanonicalR(Y,X) then X = Y). The proof structure changes slightly:
instead of `canonicalR_strict p.1.mcs c.mcs h_Rpc` to get `¬CanonicalR c.mcs p.1.mcs`,
we use antisymmetry: if `CanonicalR(p, c)` and `CanonicalR(c, p)`, then `p.mcs = c.mcs`.
The sorry can be discharged with either approach. **Reflexive switch makes this sorry
neither harder nor easier — both approaches work.**

**Lines 788, 878** (j>0 termination sorries): These are pure termination/well-foundedness
issues with no connection to temporal semantics. **Not affected by reflexive switch.**

### DovetailedCoverageReach.lean (sorries at lines 164, 182, 220, 223)

These sorries in `DovetailedCoverageReach` concern edge cases in the CanonicalR chain
reachability proof (`process_step = 0` cases). These are structural edge cases in the
dovetailed build indexing. **Not affected by the reflexive switch.**

### ClosureSaturation.lean (sorries at lines 698, 703, 718, 780)

- **Lines 698, 703** (`timelineQuotFMCS_forward_F`): The forward F coherence for the
  non-dovetailed TimelineQuot. The comments identify the architectural gap: the staged
  construction may not have added witnesses for ALL F-formulas in late-stage MCSs. The
  T-axiom under reflexive semantics would give `G(φ) ∈ M → φ ∈ M` but does NOT help
  establish that a FUTURE witness for F(φ) is in the timeline. **Not affected by switch.**

- **Line 718** (`timelineQuotFMCS_backward_P`): Symmetric to forward_F. **Not affected.**

- **Line 780** (`timelineQuotSingletonBFMCS` modal_backward): The docstring is explicit
  that this sorry is **provably impossible** — it requires `φ ∈ MCS → □φ ∈ MCS`, the
  converse of the T-axiom. This sorry represents a deprecated construction and will never
  be filled. **Not affected by reflexive switch; already documented as impossible.**

---

## Recommended Prerequisites

In order of dependency, the following ordering is recommended:

**1. Task 29 FIRST** (no prerequisites among open tasks)
- Eliminates `canonicalR_irreflexive_axiom` (enables Task 26 to be closed)
- Proves `discreteImmediateSuccSeed_consistent_axiom` (removes axiom debt from Task 24)
- Changes FMCS signatures to reflexive (all downstream tasks build against the final API)
- Adds T-axioms to proof system (enables simpler downstream proofs)
- Enables a cleaner proof of `canonicalR_antisymmetric` needed by DovetailedTimelineQuot

**2. Task 26 CLOSE/ABANDON** (after Task 29 completes Phase 5)
- Task 26's research is absorbed into Task 29 Phase 5
- No independent implementation needed

**3. Task 24 AFTER Task 29**
- `discreteImmediateSuccSeed_consistent_axiom` will already be proven (Task 29 Phase 6)
- Assess whether `discreteImmediateSucc_covers_axiom` becomes provable under reflexive semantics
- `discrete_Icc_finite_axiom` remains; may require additional research

**4. Task 18 AFTER Task 29**
- Build against final FMCS signatures (t ≤ t')
- j>0 termination sorries are semantics-independent; can proceed concurrently with Task 29
- Density sorry (line 295) benefits from having antisymmetry lemmas from Task 29

**5. Task 997 AFTER Task 29**
- FMCS signature repair needed
- Core blocking sorries (modal saturation, F/P witnesses) are unaffected by semantics
- May benefit from cleaner T-axiom machinery in truth lemma

**6. Task 22 LOW PRIORITY** (already partially deployed)
- `construct_bfmcs_from_mcs_Int_v4` is already imported in AlgebraicBaseCompleteness.lean
- Wait for Task 29 to stabilize FMCS API before further work

---

## Confidence Level

**High** for the task-ordering recommendations and axiom elimination analysis.
The evidence base is strong:
- The plan for Task 29 is detailed and matches the existing proof infrastructure
- The 1170-line proof in CanonicalIrreflexivity.lean explicitly documents the reflexive proof
- The CanonicalIrreflexivityAxiom.lean docstring confirms the T-axiom proof strategy
- The DiscreteSuccSeed.lean comment explicitly identifies T-axiom as the missing piece

**Medium** for whether `discreteImmediateSucc_covers_axiom` and the SuccExistence axioms
become provable under reflexive semantics. The semantic argument is sound but the Lean
formalization path requires additional investigation.

**Low** for whether the j>0 termination sorries in DovetailedTimelineQuot can be eliminated
by Task 18 — these are complex well-foundedness arguments with an identified termination
issue (the recursion measure is not obviously bounded).
