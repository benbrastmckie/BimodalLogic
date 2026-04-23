# Research Report: Task #107

**Task**: Chain design diagnostics for representation theorem
**Date**: 2026-04-23
**Mode**: Team Research (4 teammates)
**Session**: sess_1776976327_97c127

## Summary

Four research agents investigated the chain construction obstacle from complementary angles: primary approaches (A), alternative architectures (B), critical analysis of prior conclusions (C), and strategic direction (D). This round produced three major corrections to prior research, one verified new theorem, and a converging recommendation on the most promising path forward.

**Three critical corrections**:
1. The FMP/filtration recommendation from Round 1 is wrong — both technically (FMP proves membership, not truth; the same temporal coherence gap reappears) and by project policy (ROADMAP explicitly excludes filtration for the representation theorem)
2. The omega-squared ruling was based on an incorrect premise — `preserving_fwd_step` DOES preserve F-obligations disjunctively; the unanalyzed question is convergence, not preservation
3. The literature (Burgess 1982, Xu 1988, Verbrugge 2004) was never consulted despite containing the answer to the exact problem being faced

**One verified result**: The derived Until guard theorem `F(phi) ∧ G(psi) → (psi U phi)` compiles in Lean with zero sorries (Teammate A, verified via `lean_run_code`).

**Converging recommendation**: All four teammates independently converge on a family of approaches that share a key insight — build FINITE witness chains (bounded by |Sigma|) for each F-obligation rather than proving F-propagation on an infinite chain. The specific variants (Burgess finite unravelling, dJVV constructive insertion, quasimodel oracle chain) differ in assembly strategy but share this core architecture.

## Key Findings

### 1. FMP/Filtration Path Is Definitively Ruled Out (HIGH confidence)

**Prior recommendation (Round 1)**: "Abandon chain construction; use filtration-based completeness via sorry-free FMP infrastructure."

**Correction**: This recommendation is wrong on two independent grounds:

*Technical*: The FMP infrastructure (`Decidability/FMP/`) proves `mcs_finite_model_property` — if phi is not provable, there exists a ClosureMCS not containing phi. This is a MEMBERSHIP result, not a TRUTH result. Bridging to `truth_at` on a TaskModel requires a truth lemma for the filtered model, which faces the SAME temporal coherence obligations as the chain construction (Teammates B, C independently confirmed). The "20-40 hour estimate" from Round 1 was severely underestimated.

*Policy*: The ROADMAP explicitly states: "Decidability-based completeness is explicitly excluded as a path to the representation theorem." The structural MCS ↔ worlds correspondence IS the scientific contribution. Switching to filtration would orphan ~5,200 lines of sorry-free infrastructure (Teammate D).

### 2. Omega-Squared Was Dismissed for the Wrong Reason (MEDIUM confidence)

**Prior conclusion**: "Omega-squared FAILS. F-obligations lost at discharge step."

**Correction** (Teammate C): The existing `resolving_enriched_fwd_exists` (RootScopedChain.lean:368) proves that the enriched BX11 fold step preserves ALL F-obligations disjunctively (each chi ∈ sigma_list gets chi ∈ M' OR F(chi) ∈ M') while resolving at least one formula directly. F-obligations are NOT lost.

The actual open question is **convergence**: does the resolved formula eventually rotate through all defects? The BX11 fold resolves some witness `w` at each step, but `w` can be the same formula perpetually (BX11 perpetual deferral, confirmed in Round 1). However, the convergence question was never independently analyzed. Re-analysis with the preserving step is warranted.

### 3. Literature Gap Is the Biggest Missed Opportunity (HIGH confidence)

Two rounds of 24 Lean diagnostics were run without studying how Burgess, Xu, Goldblatt, or Verbrugge actually prove the result. The problem (F-resolution on linear MCS chains for Until/Since tense logic) has been solved in the mathematical literature since at least 1982. Specifically:

- **Burgess 1982**: "Axioms for tense logic. I. 'Since' and 'until'" — original proof
- **Xu 1988**: "On some U, S-tense logics" — extension to bimodal setting
- **Verbrugge et al.**: "Completeness by construction for tense logics of linear time" — constructive method
- **GHR 1994**: *Temporal Logic: Mathematical Foundations* — textbook treatment

Studying these papers (estimated 5-10 hours) should be the FIRST action before any further diagnostics.

### 4. Derived Until Guard Theorem Verified (HIGH confidence)

**NEW** (Teammate A, Lean-verified, zero sorries):

```
theorem F_and_G_to_until {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (phi psi : Formula) (h_F : Formula.some_future phi ∈ M)
    (h_G : Formula.all_future psi ∈ M) : Formula.untl psi phi ∈ M
```

Derivation: BX12 (`F(phi) → T U phi`) + BX2 left-monotonicity (`G(T→psi) → (T U phi → psi U phi)`) + G-monotonicity.

This converts `F(phi) + G(psi)` into the Until formula `(psi U phi)`. Useful as a building block for the Until-tracking approach (Path 2) but does NOT alone solve F-propagation since `(psi U phi)` itself does not propagate through g_content.

### 5. The Problem Is Precisely Scoped (HIGH confidence)

The sorry-free infrastructure above the chain layer is sound and complete (Teammate B). The ONLY gap is providing implementations of three predicates on the `dd_bfmcs` construction:

| Predicate | Sorries | Nature |
|-----------|---------|--------|
| `dd_bfmcs_restricted_tc` | #1, #2, #3 | F/P resolution (temporal coherence) |
| `dd_bfmcs_restricted_buc` | #4 | Backward Until/Since (step transfer) |
| `dd_bfmcs_restricted_fuc` | #5 | Forward Until/Since (guard condition) |

Everything above this (ParametricRepresentation, RestrictedParametricTruthLemma, Completeness) is sorry-free. Sorries 4-5 differ structurally from 1-3: they require a "step transfer" property for Until propagation, not just F/P resolution (Teammate B).

### 6. Quasimodel Approach Was Prematurely Abandoned (MEDIUM-HIGH confidence)

The Quasimodel directory is marked OFF-PATH but contains substantial useful infrastructure (Teammates A, B, C):

- `hintikka_step_for_sigma_sig` (sorry-free): step relation between sigma-signatures
- `sigma_signature` / `HintikkaPoint`: finite state space infrastructure
- `bx_until_step`, `bx_F_step` (sorry-free): one-step resolution lemmas
- `qm_oracle_seed_consistent`: oracle seed consistency (sorry-free)
- `DefectChain.lean`: defect tracking bounded by |Sigma|

The quasimodel faces the same Lindenbaum non-determinism at its 2 sorry sites, but its FRAMEWORK (finite chains with strong induction on defect count) avoids the infinite-chain F-propagation problem entirely. The forward direction step is sorry-free.

### 7. Backward Chain Lacks Basic Infrastructure (HIGH confidence)

The backward chain uses plain `bwd_pred` with NO preserving backward step (Teammate C). The forward chain has `preserving_fwd_step` (sorry-free) but no symmetric `preserving_bwd_step` exists. Building this is a prerequisite for any backward P-resolution argument (sorries #2, #3).

## Synthesis

### Conflicts Resolved

| Conflict | Resolution |
|----------|------------|
| FMP as primary path (Round 1) vs chain-only (Rounds 2-3) | FMP ruled out both technically and by policy. Chain-based representation theorem is the only valid path. |
| Omega-squared dead (Round 1-2) vs re-openable (Teammate C) | Partially re-opened: F-preservation works, convergence is the open question. Demoted from "dead end" to "open question". |
| Path 2 (Until tracking) vs Burgess finite unravelling vs dJVV insertion | These are VARIANTS of the same core insight (finite witness chains). The specific assembly strategy differs but the mathematical content is shared. |
| All 9 dead ends airtight (Teammate A) vs omega-squared re-openable (Teammate C) | Dead ends 1-9 as originally stated are airtight. The omega-squared re-opening uses `preserving_fwd_step` (not plain `fwd_succ`), which is a DIFFERENT construction than what was tested. |

### Gaps Identified

1. **Literature review**: No prior round consulted the actual mathematical papers
2. **Backward preserving step**: Missing infrastructure for sorries #2-3
3. **BX6 cycle contradiction**: Critical test for Path 2 (Teammate A: Test 4) — determines if sigma-signature cycles with unresolved Until defects yield contradiction
4. **Step transfer for Until**: Structurally different from F/P resolution, needs separate analysis
5. **Oracle seed integration**: Quasimodel oracle seed approach never connected to the main chain

### Recommendations

**Highest-priority action**: Study Burgess 1982 / Verbrugge 2004 actual proof technique (5-10 hours). This is the single highest-value action because the problem has been solved in the literature.

**Primary implementation path**: Finite witness chains (Burgess/dJVV tradition). Build SEPARATE finite chains (bounded by |Sigma|) for each temporal obligation, then assemble them. This avoids proving F-propagation on an infinite chain entirely. The existing quasimodel infrastructure (`HintikkaPoint`, `sigma_signature`, `defect_count`, `hintikka_step`) provides the foundation.

**Secondary path**: Re-analyze omega-squared with preserving steps. The convergence question (does the resolved formula rotate?) is genuinely open and may be answerable via g_content accumulation arguments.

**Infrastructure prerequisites**:
1. Build `preserving_bwd_step` (symmetric to `preserving_fwd_step`) — 10-15 hours
2. Connect quasimodel oracle infrastructure to restricted coherence framework — 15-25 hours

**Do NOT pursue**: FMP/filtration, coinductive chains, Stone duality, game-theoretic framework (insufficient structural advantage).

### Concrete Diagnostic Tests for Implementation Phase

| Priority | Test | What It Determines |
|----------|------|--------------------|
| CRITICAL | Study Burgess/Verbrugge proof technique | How the literature handles F-resolution on linear chains |
| HIGH | Oracle seed Until persistence verification | Whether `qm_oracle_step` preserves Until defects within Sigma |
| HIGH | Sigma-signature defect monotonicity | Whether defect count is non-increasing within a sigma-signature |
| HIGH | Build `preserving_bwd_step` | Prerequisite for sorries #2-3 |
| MEDIUM | BX6 cycle contradiction (Test 4) | Whether sigma-signature cycles with unresolved Until defects yield contradiction via BX5/BX6 |
| MEDIUM | Finite state space cycling (pigeonhole) | That chain must revisit sigma-signatures within 2^|Sigma| steps |
| MEDIUM | Resolution target exhaustion | Whether G-formulas entering g_content eventually exclude all but one target |
| LOW | Backward chain P-preservation | Whether backward P-resolution has structural asymmetries worth exploiting |

## Teammate Contributions

| Teammate | Angle | Status | Key Contribution | Confidence |
|----------|-------|--------|------------------|------------|
| A | Primary | completed | Verified Until guard theorem in Lean; designed 7 diagnostic tests; confirmed all 9 dead ends | high |
| B | Alternatives | completed | FMP gap analysis; Burgess finite unravelling; sorry 4-5 structural difference; step transfer characterization | high |
| C | Critic | completed | Omega-squared re-opening; FMP recommendation refutation; literature gap identification; backward infrastructure gap | high |
| D | Horizons | completed | ROADMAP alignment; dJVV constructive insertion; scoping recommendation (one path deeply); Mathlib resource inventory | high |

## References

### Academic (to be studied)
- Burgess, J. P. (1982). "Axioms for tense logic. I. 'Since' and 'until'." *NDJFL* 23(4), 367-374.
- Xu, M. (1988). "On some U, S-tense logics." *JPL* 17, 181-202.
- Verbrugge, R. et al. "Completeness by construction for tense logics of linear time."
- Gabbay, D., Hodkinson, I., Reynolds, M. (1994). *Temporal Logic: Mathematical Foundations*. OUP.
- Hodkinson, I., Reynolds, M. (2006). "Temporal Logic." Ch. 11 in *Handbook of Modal Logic*, Elsevier.

### Codebase Files Referenced
- `RootScopedChain.lean` (5 sorries: lines 1143, 1170, 1177, 1185, 1192)
- `Completeness.lean` (sorry-free, calls `dd_countermodel`)
- `OracleInstantiation.lean` (2 sorries: lines 286, 422)
- `ParametricRepresentation.lean` (sorry-free)
- `RestrictedParametricTruthLemma.lean` (sorry-free)
- `TemporalCoherence.lean` (sorry-free, defines restricted_tc)
- `UntilSinceCoherence.lean` (sorry-free, defines step transfer)
- `Decidability/FMP/` (all sorry-free)
- `Quasimodel/` (2 sorry sites, substantial sorry-free infrastructure)
- `Filtration/DefectChain.lean`, `SigmaOrdering.lean` (sorry-free)
