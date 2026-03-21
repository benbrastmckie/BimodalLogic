# Research Report: Task #21

**Task**: Technical debt cleanup (tasks 9-20 metalogic refactoring track)
**Date**: 2026-03-21
**Mode**: Team Research (3 teammates)

---

## Summary

Three teammates investigated the axioms and technical debt introduced by tasks 9-20 from complementary angles: semantic validity (Teammate A), proof dependency tracing and derivation paths (Teammate B), and frame condition theory / proof system axiom analysis (Teammate C). The findings converge strongly on a clear prioritized action plan.

The headline finding from all three teammates: **`F_top_propagates` and `P_top_propagates` are trivially eliminable right now** — they are provable in one line from theorems already in the same file, making them immediate technical debt to eliminate. Beyond that, the axioms divide cleanly into: (1) dead-code path axioms (the dovetailing gap — not on the active completeness path), (2) semantically justified but unproven axioms (medium effort to eliminate), and (3) one permanently justified axiom (`canonicalR_irreflexive_axiom` — modally non-definable).

---

## Key Findings

### Primary Approach (from Teammate A — Semantic Validity)

All 10 Lean `axiom` declarations were analyzed for semantic justification:

- **2 DERIVABLE**: `F_top_propagates` and `P_top_propagates` — trivially proven since F(⊤) and P(⊤) are theorems of the logic. Already proved at lines 118 and 124 of the same file via `contains_F_top`/`contains_P_top`. No hypotheses about `Succ` are needed at all.

- **2 UNJUSTIFIED**: `succ_chain_forward_F_axiom` and `succ_chain_backward_P_axiom` — genuine dovetailing gaps. The Succ-chain can indefinitely defer F/P obligations without resolving them. No proof path exists without an omega-level dovetailing construction.

- **5 VALID-SEMANTIC**: The three deferral seed consistency axioms (SuccExistence.lean) and `canonicalR_irreflexive_axiom` (modally non-definable) and `discrete_Icc_finite_axiom` (documented task-19 debt). All have sound semantic justifications.

- **2 VALID-FRAME**: `discreteImmediateSuccSeed_consistent_axiom` and `discreteImmediateSucc_covers_axiom` (old pipeline, task-19 scope).

Teammate A also identified a subtle circularity concern in `predecessor_f_step_axiom`'s docstring — the justification appeals to `Succ v u` to prove the F-step condition, but the axiom is used to establish that very Succ relation. The axiom is semantically correct but the proof documentation should be corrected.

### Alternative Approaches (from Teammate B — Proof Dependencies)

Teammate B traced all downstream dependencies and found a critical structural insight:

**The dovetailing gap axioms (succ_chain_forward_F_axiom, succ_chain_backward_P_axiom) are on dead-code paths.** Neither `SuccChainWorldHistory.lean` nor `SuccChainTaskFrame.lean` has any downstream importers. The active completeness proof goes through `ClosedFlagIntBFMCS.lean` → `DiscreteInstantiation.lean`, which does NOT depend on the Succ-chain temporal coherence path.

Key derivation assessments from Teammate B:
- `successor_deferral_seed_consistent_axiom`: Derivable with medium effort using a "weakening" lemma (S ∪ {ψ} consistent implies S ∪ {ψ ∨ χ} consistent) plus induction over finitely many F-obligations
- `predecessor_deferral_seed_consistent_axiom`: Low incremental effort after predecessor axiom is proved (symmetric argument)
- `predecessor_f_step_axiom`: Medium effort using g/h duality lemmas already in codebase
- `canonicalR_irreflexive_axiom`: Not derivable — modally non-definable, retain permanently

### Risks and Blockers (from Teammate C — Frame Condition Theory)

Teammate C provided the broadest frame, analyzing all 19 ProofSystem axiom schemata plus the 10 Lean `axiom` declarations:

**All 19 ProofSystem axiom schemata are legitimate** — propositional tautologies, standard modal (S5) frame conditions, or temporal frame conditions (linearity, density, discreteness, seriality). Notable findings:
- `temp_linearity` was not in the original TM axiom set but is a legitimate permanent addition (linearity is not derivable from the other axioms — branching-time frames satisfy all others). This should be documented as a permanent axiom, not debt.
- `density (DN)` and `discreteness_forward (DF)` are incompatible frame conditions — no frame can satisfy both. The system correctly separates them into distinct axiom classes.
- DP (backward discreteness) is correctly derived from DF via temporal duality, not axiomatized.

For the Lean `axiom` declarations, Teammate C classifies them into: (a) semantically justified canonical model properties (6 axioms), (b) dovetailing gaps (4 axioms including the trivially-derivable F/P top pair), and (c) one pre-approved technical debt item (`discrete_Icc_finite_axiom`).

Teammate C's priority order for elimination differs slightly from Teammate B: Teammate C ranks the dovetailing F/P top pair as higher priority than the deferral seed axioms. This is reconciled below.

---

## Synthesis

### Conflicts Resolved

**Conflict 1: Classification of `F_top_propagates` / `P_top_propagates`**

- Teammate A classified these as DERIVABLE
- Teammate B confirmed: trivially derivable (one-liner using `contains_F_top`/`contains_P_top`)
- Teammate C classified these as "DOVETAILING GAP" (infrastructure for Int-indexed chains)

**Resolution**: Teammates A and B are correct. These are DERIVABLE, not dovetailing gaps. The key insight is that F(⊤) is a theorem of the logic (proven in the same file via the seriality axiom), so every MCS contains F(⊤) regardless of any Succ relationship. The dovetailing description in Teammate C's analysis applied to the broader Succ-chain infrastructure, but the specific `F_top_propagates` axiom is separately trivially provable.

**Conflict 2: Priority of succ_chain_forward_F / backward_P axioms**

- Teammate A called these UNJUSTIFIED (highest priority to address)
- Teammate B noted these are on dead-code paths (lower priority, consider deleting the dead files instead)

**Resolution**: Teammate B's structural analysis is conclusive — the dovetailing gap axioms serve no live completeness purpose. The recommended action is **not to prove them** but to mark `SuccChainTemporalCoherent` as incomplete (or delete the dead-end files) and accept that the Succ-chain approach does not fully implement `TemporalCoherentFamily` without dovetailing. This is clean technical honesty rather than leaving unjustified axioms silently in place.

### Gaps Identified

1. **`predecessor_f_step_axiom` circularity** (identified by Teammate A): The docstring justification is circular. Needs correction regardless of whether the axiom is eventually proved.

2. **`temp_linearity` documentation gap** (identified by Teammate C): This axiom should be explicitly documented as a permanent addition to TM (not derivable from other axioms, added to enforce linear-time semantics). Currently it lacks this documentation.

3. **`SuccChainTemporalCoherent` completeness status**: The object is defined but its two axiom-backed fields represent incomplete proofs. This should be marked with a comment indicating the dovetailing gap.

### Recommendations

**Immediate actions (zero proof effort)**:
1. Replace `F_top_propagates` with `exact SetMaximalConsistent.contains_F_top h_mcs'`
2. Replace `P_top_propagates` with `exact SetMaximalConsistent.contains_P_top h_mcs'`
3. Simplify `ForwardChainElement.next.has_F_top` and `BackwardChainElement.prev.has_P_top` to call `contains_F_top`/`contains_P_top` directly
4. Correct the circularity note in `predecessor_f_step_axiom`'s docstring

**Short-term (medium proof effort, task 21 scope)**:
5. Prove `successor_deferral_seed_consistent_axiom` using the weakening + compactness argument: `{ψ} ∪ g_content(u)` consistent (proven) → `{ψ ∨ F(ψ)} ∪ g_content(u)` consistent (by propositional weakening) → full seed consistent (by finite compactness + induction)
6. Prove `predecessor_deferral_seed_consistent_axiom` symmetrically (low incremental effort)
7. Prove `predecessor_f_step_axiom` using g/h duality (medium effort)
8. Add documentation to `temp_linearity` noting it is a permanent axiom of TM

**Deferred (task 19 scope)**:
9. Address `discrete_Icc_finite_axiom` as part of DiscreteTimeline deprecation
10. Address `discreteImmediateSuccSeed_consistent_axiom` and `discreteImmediateSucc_covers_axiom` as part of old pipeline deprecation

**Architecture decision (dovetailing gap)**:
11. Mark `SuccChainTemporalCoherent` in `SuccChainFMCS.lean` with a comment explaining the dovetailing gap — the F/P witness existence is not provable from the current chain construction and would require an omega-level dovetailed enumeration
12. Consider deleting `SuccChainWorldHistory.lean` and `SuccChainTaskFrame.lean` which have no downstream importers (or move to Boneyard) — they are dead-end files that serve no live purpose

---

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Semantic validity analysis of all 10 Lean axiom declarations | completed | high |
| B | Proof dependency tracing and derivation path analysis | completed | high |
| C | Frame condition theory — ProofSystem axioms + Lean axiom classifications | completed | high |

---

## Classification Summary (Reconciled)

| Category | Axioms | Action |
|----------|--------|--------|
| Trivially derivable (immediate) | `F_top_propagates`, `P_top_propagates` | Replace with one-liners now |
| Derivable with medium effort | `successor_deferral_seed_consistent_axiom`, `predecessor_deferral_seed_consistent_axiom`, `predecessor_f_step_axiom` | Eliminate in task 21 implementation |
| Dovetailing gap on dead-code path | `succ_chain_forward_F_axiom`, `succ_chain_backward_P_axiom` | Mark incomplete; consider deleting dead files |
| Pre-approved technical debt (task 19) | `discrete_Icc_finite_axiom`, `discreteImmediateSuccSeed_consistent_axiom`, `discreteImmediateSucc_covers_axiom` | Defer to task 19 |
| Permanently justified (non-derivable) | `canonicalR_irreflexive_axiom` | Retain; document non-derivability |

---

## References

- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` — contains F/P top propagation axioms and dovetailing gap axioms
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` — contains deferral seed consistency axioms
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` — contains irreflexivity axiom
- `Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean` — contains old pipeline axioms
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` — contains discrete_Icc_finite_axiom
- `Theories/Bimodal/ProofSystem/Axioms.lean` — all 19 ProofSystem axiom schemata (all legitimate)
- Goldblatt 1992, *Logics of Time and Computation* — dovetailing construction reference
- Blackburn-de Rijke-Venema 2001, *Modal Logic* §3.3 — irreflexivity non-definability
- Gabbay 1981 — Irreflexibility Lemma
- `specs/021_technical_debt_cleanup/reports/01_tech-debt-audit.md` — prior debt audit
