# Handoff: Phase 2 Resume for Task 107

**Date**: 2026-05-03
**From**: lean-implementation-agent (aborted)
**To**: Next agent

## Current State

- **Task**: 107 - Burgess chronicle construction for BX representation theorem
- **Plan**: `specs/107_chain_design_diagnostics_for_representation_theorem/plans/53_implementation-plan.md`
- **Phase**: 2 (Complete D0 Seed Consistency - Inconsistent Case)
- **Status**: IN PROGRESS (not yet complete)
- **Metadata**: `specs/107_chain_design_diagnostics_for_representation_theorem/.return-meta.json` shows status "in_progress"

## Sorry Sites in PointInsertion.lean

| Line | Location | Task | Description |
|------|----------|------|-------------|
| 1411 | `d0_a_event_list_mem` | 2.1 | Extract α' from `snce(beta', alpha') ∈ L`, prove α' ∈ A |
| 1858 | `h_ev_b` in `burgess_D0_finite_subset_consistent_incons` | 2.2 | Prove `event → b` |
| 1859 | `h_ev_untl` in `burgess_D0_finite_subset_consistent_incons` | 2.3 | Prove `event → untl(b, γ_hat)` |

## Key Reference: Burgess 1982 Paper

**CRITICAL**: The Burgess 1982 paper at `/home/benjamin/Projects/ProofChecker/literature/Burgess_1982_Axioms_for_tense_logic_Since_and_Until.md` provides the WORKING solution. 

- **Section 2.6 (p. 170)**: Lemma 2.6 - D0 seed consistency (what Phase 2 implements)
- The inconsistent case (β.neg ∈ B) is SEPARATE from consistent case
- Follow Burgess literally - do NOT try alternative approaches

## Phase 2 Tasks (from plan)

### Task 2.1: Complete `d0_a_event_list_mem` (line 1411)
- Use pattern matching instead of `Classical.choose`
- Extract α' from `snce(beta', alpha') ∈ L`
- Prove `α' ∈ A` directly via `d0_a_event_list_α_mem` helper

### Task 2.2: Restructure `h_ev_b` derivation (line 1858)
- The enrichment provides `event → γ_hat`, but proof requires `event → b`
- Strategy: Use `collect_guards_mem_of_B` to show `b ∈ collect_guards output`
- Then `list_conj_implies_elem` gives `b_list → b`
- By transitivity with `event → b_list` (via BX13 enrichment), get `event → b`

### Task 2.3: Restructure `h_ev_untl` derivation (line 1859)
- Need `event → untl(b, γ_hat)`
- From BX5 (`self_accum_until_mcs`): `untl(b ∧ untl(b, γ_hat), γ_hat) ∈ A`
- Event contains `b ∧ untl(b, γ_hat)` in its guard (via BX13 enrichment)
- So `event → untl(b ∧ untl(b, γ_hat), γ_hat)`
- Apply `untl_left_mono_deriv` with `b → b` (refl) and `untl(b, γ_hat) → untl(b, γ_hat)` (from guard)
- Use `untl_right_mono_deriv` with `γ_hat → γ_hat` (refl)

### Task 2.4: Verify complete proof
- Ensure `burgess_D0_finite_subset_consistent_incons` compiles sorry-free

### Task 2.5: Run `lake build`
- Verify no regressions in existing sorry-free lemmas

## Files to Modify

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`

## Verification Criteria

- `burgess_D0_finite_subset_consistent_incons` compiles sorry-free
- `burgess_D0_seed_consistent` remains sorry-free
- PointInsertion.lean sorry count: 1 (Phase 3: `lemma_2_7_seed_consistent`)
- `lake build` succeeds

## Next Steps After Phase 2

1. Update plan file: Change Phase 2 status to `[COMPLETED]`
2. Use Edit tool on plan file: `### Phase 2: ... [IN PROGRESS]` → `### Phase 2: ... [COMPLETED]`
3. Move to Phase 3 (Lemma 2.7 with BX7 Chain)
4. Continue through Phase 4a, 4b, 4c, 4d, 4e, 5a, 5b, 5c
5. Create handoff BEFORE running out of context

## Agent Instructions

1. **Read the Burgess paper** Section 2.6 carefully before starting
2. **Use lean_goal** before and after each tactic
3. **Run lake build** after completing Phase 2
4. **Update phase status** in plan file using Edit tool
5. **Create handoff** when reaching ~80% context or completing a phase
6. **Write metadata** to `.return-meta.json` when done

## Definition of Done for Full Task

`#print axioms dd_countermodel_chronicle` shows no `sorryAx`; `lake build` succeeds; `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` returns only comments.
