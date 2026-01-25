# Research Report: temporal_swap_strategy_for_truth_lean_supports_tasks_129_130

**Project**: #154  
**Date**: 2025-12-23  
**Research Type**: comprehensive

## Research Question

Should we introduce a semantic time-reversal lemma (`is_valid φ ↔ is_valid φ.swap_past_future`) to close the remaining `Truth.lean` sorries, or refactor the temporal-duality soundness proof to avoid needing such a strong lemma by restructuring `derivable_implies_swap_valid` with weaker helpers? Assess impacts on `Truth.lean`/`Soundness.lean` tests and outline next steps for Tasks 129 (temporal swap lemmas) and 130 (domain extension lemmas).

## Sources Consulted

- Internal code: `Logos/Core/Semantics/Truth.lean` (TemporalDuality section, sorries at `truth_swap_of_valid_at_triple` imp/past/future cases; `valid_swap_of_valid`; `derivable_implies_swap_valid` temporal_duality case)
- Internal code: existing time-shift transport lemmas (`TimeShift.time_shift_preserves_truth`, `swap_axiom_*_valid` family) used by MF/TF proofs

## Key Findings

### Technologies and Frameworks

- Lean 4 proofs with custom semantics for temporal logic (`WorldHistory`, `TaskFrame`, time-shift machinery).
- Existing derivation-indexed soundness approach is already in place for temporal duality; the remaining sorries come from attempting a global semantic swap lemma rather than from missing transport infrastructure.

### Design Patterns and Best Practices

- Derivation-indexed proofs (induction on `DerivationTree`) are safer for temporal duality than formula-level validity because they avoid needing `is_valid φ → is_valid φ.swap` for arbitrary `φ`.
- Time-shift transport lemmas (`time_shift_preserves_truth`) already provide the semantic machinery needed for MF/TF and likely for weaker helper lemmas, without requiring a global time-reversal axiom.

### Implementation Strategies

1. **Do NOT pursue a global semantic time-reversal lemma**
   - The imp case in `truth_swap_of_valid_at_triple` is unprovable without extra frame assumptions: `is_valid (ψ → χ)` does not imply `is_valid (ψ.swap → χ.swap)` because validity is extensional in subformulas, not structure-preserving under swap.
   - Past/Future cases require unbounded (bi-infinite) history domains to lift `is_valid (Past ψ)` to `is_valid ψ`; this is not guaranteed by `LinearOrderedAddCommGroup` + arbitrary `WorldHistory` domain.
   - Adding such an axiom would either be false over current models or would force stronger frame/domain invariants, risking regressions in `TruthTest`/`SoundnessTest` and narrowing semantics.

2. **Refactor temporal-duality soundness to avoid `valid_swap_of_valid` entirely**
   - Recast `derivable_implies_swap_valid` so the temporal_duality rule uses the IH result directly (goal is `is_valid (ψ.swap)`, IH on premise `ψ` already yields that). Remove the detour through `(ψ.swap).swap` and `valid_swap_of_valid`.
   - Option: strengthen the induction to produce both `is_valid φ` and `is_valid φ.swap` (or a mutual lemma) so the temporal_duality case closes by involution without any global semantic swap lemma.
   - This keeps proofs within the derivable fragment, matching the intended Approach D and avoiding new semantic obligations.

3. **Targeted weaker helpers instead of global reversal**
   - If needed, add local lemmas that move between times under domain witnesses (e.g., "if `τ.domain t` and `s < t`, then `truth_at M τ t (past φ)` gives `truth_at M τ s φ`"), leveraging existing `TimeShift` transport. These are confined to specific proof steps and do not require global validity equivalence.

## Relevant Resources

- `Logos/Core/Semantics/Truth.lean` — TemporalDuality section (sorries) and time-shift lemmas
- `Logos/Core/Metalogic/Soundness.lean` — consumes `derivable_implies_swap_valid`
- Existing lemmas: `TimeShift.time_shift_preserves_truth`, `swap_axiom_*_valid`, `mp_preserves_swap_valid`, `temporal_k_preserves_swap_valid`

## Recommendations

- **Primary path**: Refactor the derivation-inductive proof to remove reliance on `valid_swap_of_valid` / `truth_swap_of_valid_at_triple`. Use IH directly in the temporal_duality case or introduce a mutual/paired induction that yields `is_valid φ` and `is_valid φ.swap` together. This keeps semantics unchanged and should unblock Tasks 129/130 without new axioms.
- **Avoid** introducing a global `is_valid φ ↔ is_valid φ.swap` lemma unless the frame/domain assumptions are strengthened (bi-infinite domains, symmetric valuations). This would be a semantics change and risks test regressions; not recommended for current model class.
- **Add** small transport/helper lemmas only as needed (e.g., domain-witnessed past/future extraction) using existing time-shift machinery; keep them local to the derivation proof.

## Further Research Needed

- Verify the revised induction closes all cases in `derivable_implies_swap_valid` and that `Soundness.lean` still compiles without `valid_swap_of_valid`.
- If any helper lemmas are added, ensure they are stated with explicit domain witnesses (no global domain extension axiom) and covered by tests.

## Specialist Reports

- Web Research: n/a (internal code analysis)

## Next Steps (Tasks 129 & 130)

1) **Task 129 (temporal swap lemmas)**
- Refactor `derivable_implies_swap_valid` temporal_duality case to use IH directly (goal `is_valid ψ.swap` is already provided by IH on premise `ψ`). Remove `truth_swap_of_valid_at_triple` and `valid_swap_of_valid` sorries if no longer used.
- If needed, introduce a mutual induction variant returning both `is_valid φ` and `is_valid φ.swap` to handle double-swap cleanly.

2) **Task 130 (domain extension lemmas)**
- Add narrowly-scoped transport lemmas that move truth from time `t` to `s` when a domain witness is available, reusing `TimeShift.time_shift_preserves_truth` rather than assuming bi-infinite domains.
- Re-run `TruthTest`/`SoundnessTest` to confirm MF/TF and temporal_duality cases remain stable after the refactor.

## Summary

The global semantic time-reversal lemma is not derivable with current frame assumptions and would require semantics changes (bi-infinite domains / symmetry). The safer path is to refactor the derivation-indexed proof: drop the global swap-of-validity attempt, restructure the temporal_duality induction case (or use mutual induction) so the IH already provides `is_valid ψ.swap`. Add only local transport lemmas with explicit domain witnesses. This approach should unblock Tasks 129/130 while preserving existing semantics and test expectations.
