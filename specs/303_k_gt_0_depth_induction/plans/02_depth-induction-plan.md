# Implementation Plan: Task #303

- **Task**: 303 - k_gt_0_depth_induction
- **Status**: [IMPLEMENTING]
- **Effort**: 8 hours
- **Dependencies**: None (k=0 infrastructure is sorry-free)
- **Research Inputs**: reports/01_team-research.md
- **Artifacts**: plans/02_depth-induction-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close the SOLE remaining sorry blocking `completeness_discrete`: the `succ k'` branch of `existPart_succ_n1_bypass` at `KampBypass.lean:104`. The approach is a mutual induction on depth k following Rabinovich 2014 Section 5 Lemma 5.1, using the archived `RabinovichGeneralized.lean` as a structural template. The boneyard file contains the complete scaffold (CharPart/ExistPart definitions, base cases, step cases, combined induction, and sorry-filling connector) -- all sorry-free EXCEPT the `existPart_succ` step case which delegates to the same `existPart_succ_n1_bypass` sorry. The plan revives this scaffold in live code and fills the k>0 sorry by generalizing the k=0 zone dispatch pattern (4446 lines across KampBypassCore/Until/Since) to use depth-k characteristic formulas instead of depth-0 atomic formulas.

### Research Integration

Key findings integrated from the team research (4 teammates):

1. **Sole sorry confirmed**: `KampBypass.lean:104` is the only `sorryAx` in the `completeness_discrete` call chain. The Stavi chain is dead code (bypassed via `PriorExpressiveness.lean:338-340`).
2. **Boneyard template is valid**: `RabinovichGeneralized.lean` contains the complete mutual induction scaffold with CharPart/ExistPart definitions, sorry-free base and CharPart step cases, and the connector `nf_2var_exist_formula_prior_filled` that fills the NfCharFormula dispatch.
3. **Core mathematical obstacle**: At k>0, the 3-var quantifier conditions involve depth-(k'+1) NFs with their own quantifier component (4-var existentials at depth k'). The base environment mismatch (`Fin.cons x (fun _ => t)` vs `(fun _ => t)`) is bridged by Rabinovich's negation closure argument using Prior-UZ/SZ.
4. **Line estimate**: 400-1500 lines. The mutual induction scaffold itself is ~200-400 lines (template from boneyard). The core new work is the k>0 zone dispatch in the `existPart_succ_n1_bypass` step case.
5. **`nf_exist_backward_prior` is dead code**: The sorry at `NfCharFormula.lean:542` is irrelevant -- not called by live dispatch.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This plan directly advances the critical path item in ROADMAP.md:
- **Discrete completeness**: "Task 303 (k>0 depth induction via Rabinovich Section 5 Lemma 5.1) -> sorry-free `completeness_discrete`"
- Closing this sorry unblocks the entire discrete completeness pipeline through `existPart_succ_n1_bypass -> nf_2var_exist_formula_prior -> nf_characterizable_temporal_prior_classical -> kamp_prior_expressive_completeness -> US_expressively_complete_over_prior -> no_gaps_discrete_model_surgery -> limitdom_is_good -> countermodel_discrete_reynolds_v2 -> completeness_discrete`.

## Goals & Non-Goals

**Goals**:
- Close the sorry at `KampBypass.lean:104` (`existPart_succ_n1_bypass`, `succ k'` branch)
- Achieve this via mutual induction on depth k following Rabinovich Section 5
- Revive the boneyard's `RabinovichGeneralized.lean` scaffold into live code
- Maintain all existing sorry-free infrastructure (no regressions)

**Non-Goals**:
- Closing `nf_exist_backward_prior` (dead code, not on critical path)
- Closing Stavi chain sorries (dead code, bypassed)
- Closing `existPart_succ` n>=2 sorry in boneyard (handled automatically by the mutual induction -- once n=1 at all depths is closed, n>=2 follows from the existing `Classical.em + bool_eq_of_iff_same` pattern)
- Modifying zone infrastructure (KampBypassCore/Until/Since) -- these are sorry-free and complete
- Generalizing beyond Prior structures

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| 3-var quantifier encoding at depth k needs new zone infrastructure | H | M | Start with the zone dispatch pattern from k=0; the key insight is that at k>0 we have `char_kp1` formulas for depth-(k+1) 1-var NFs which replace the depth-0 `nf_depth0_char_formula`. If zone-level changes are needed, scope to minimal helpers. |
| Base environment mismatch (`Fin.cons x (fun _ => t)` vs `(fun _ => t)`) blocks backward direction | H | M | Rabinovich's approach: on Prior structures, temporal truth at t + position of x relative to t determines existential properties. Use Prior-UZ/SZ to find first/last occurrences. The k=0 infrastructure already proves this for depth-0 conditions. |
| n>=2 arity-climbing requires more infrastructure than expected | M | L | The boneyard pattern shows n>=2 reduces to n=1 via constant-base projection + `bool_eq_of_iff_same`. This pattern is already sorry-free at depth 0. At depth k>0, the quantifier projection lemma may need new work, but it's the same mathematical argument. |
| `lake build` regression from new file imports | M | L | Build incrementally after each phase. The new file only imports existing modules plus the boneyard's definitions (which compiled when active). |
| Heartbeat/timeout issues in zone dispatch proofs | M | M | Use `set_option maxHeartbeats` as in existing KampBypass files (3200000 is the current max). Factor large proofs into private helper theorems. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

### Phase 1: Revive Mutual Induction Scaffold [COMPLETED]

**Goal**: Create `KampMutualInduction.lean` with the CharPart/ExistPart definitions, base cases, and sorry-free step cases from the boneyard, adapted to compile in the live codebase.

**Tasks**:
- [x] Create `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampMutualInduction.lean`
- [x] Port `CharPart` and `ExistPart` type definitions from `RabinovichGeneralized.lean:88-127`
- [x] Port `bool_eq_of_iff_same` helper (lines 79-85)
- [x] Port `charPart_zero` (lines 132-152) -- delegates to `nf_depth0_char_formula`
- [x] Port `charPart_succ` (lines 156-177) -- delegates to `nf_characterizable_temporal_prior_classical`
- [x] Port `existPart_zero` (lines 190-364) -- sorry-free for all n, includes the n>=2 `Classical.em + bool_eq_of_iff_same` pattern *(deviation: altered -- uses `nf_2var_exist_formula_prior` instead of boneyard's `nf_2var_exist_formula_prior_neg` for n=1 case)*
- [x] Port `existPart_succ` skeleton (lines 399-471) -- n=1 delegates to `existPart_succ_n1_bypass`, n>=2 uses `sorry` (same as boneyard)
- [x] Port `kamp_mutual_induction` (lines 479-491) -- combined Nat.rec
- [x] Port `nf_2var_exist_formula_prior_filled` (lines 497-520) -- connector that fills NfCharFormula dispatch
- [x] Add `KampMutualInduction` to the module imports in the Kamp aggregator *(deviation: skipped -- no Kamp aggregator exists; modules import each other directly)*
- [x] Verify `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampMutualInduction` compiles with exactly the same sorry sites as the boneyard (2 sorries: `existPart_succ` n=1 k>0 and n>=2 k>0)

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampMutualInduction.lean` - NEW: mutual induction scaffold
- Module aggregator (if needed) - add import

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampMutualInduction` succeeds
- `lean_verify` on `kamp_mutual_induction` shows exactly `sorryAx` (from the existPart_succ step case)
- All other definitions compile without sorry

---

### Phase 2: Close the k>0 n=1 Sorry in existPart_succ_n1_bypass [PARTIAL]

**Goal**: Fill the `sorry` at `KampBypass.lean:104` (the `succ k'` branch) by generalizing the k=0 zone dispatch pattern to use depth-(k'+1) characteristic formulas. This is the core mathematical work of the task.

**Tasks**:
- [x] **Task 2.1**: Analyze the k=0 proof structure in `existPart_succ_n1_bypass_k0` (KampBypass.lean:35-74): it dispatches on x-t order (Until/Since/Eq zones) using depth-0 3-var zone decomposition
- [x] **Task 2.2**: For k>0 (`succ k'`), implement the same zone dispatch: match on `sub_nf.1 (.order ...)` to determine x > t, x < t, or x = t *(deviation: altered — added Classical.em satisfiability split before zone dispatch; unsatisfiable case closed with Formula.bot)*
- [x] **Task 2.3**: For each zone, construct the enriched temporal formula using `char_kp1` (the depth-(k'+1) characteristic formula function) instead of `nf_depth0_char_formula` *(deviation: altered — formula is `compat_disj` (disjunction of char_kp1(nf_x) for predicate-compatible nf_x) placed in Until/Since/at-t zone, without 3-var quantifier profile encoding)*
- [x] **Task 2.4**: Implement the forward direction (exists x -> formula truth): given witness x, construct the temporal formula truth from `nf_eval_nf` using zone-specific Until/Since/Eq encoding *(sorry remains at compat_of_eval for Fin arithmetic; structurally complete)*
- [ ] **Task 2.5**: Implement the backward direction (formula truth -> exists x): extract witness x from Until/Since semantics, verify atom conditions via `char_kp1`, verify quantifier conditions using the recursive ExistPart(k') at higher arity *(deviation: deferred — 3 zone-specific sorries remain; blocked by Prior type determination, see BLOCKER below)*
- [ ] **Task 2.6**: Handle the base environment mismatch: the quantifier conditions at depth k'+1 involve `∃ y, nf_eval_nf M (k'+1) 3 [y,x,t] ssn`. On Prior structures, temporal truth at t + zone position of x determines these existentials via Prior-UZ/SZ *(deviation: deferred — this IS the blocker; ExistPart only supports constant parent envs (fun _ => t), not [x,t])*
- [x] **Task 2.7**: If the proof is large (>500 lines), factor into helper files `KampBypassUntil_kgt0.lean` and `KampBypassSince_kgt0.lean` mirroring the k=0 factoring pattern *(deviation: skipped — proof is 125 lines, well under threshold)*

**BLOCKER** (Phase 2):
- **What failed**: Backward direction of existPart_succ_n1_bypass at k>0 — all 3 zone cases (Until/Since/Eq) require proving `nf_eval_nf M (k'+1+1) 2 [x,t] sub_nf` from `temporal_truth M atomMap x (char_kp1 nf_x)` + zone ordering. The atom part is proved; the quantifier part (`∀ ssn, (∃ y, nf_eval_nf M (k'+1) 3 [y,x,t] ssn) ↔ sub_nf.2 ssn`) cannot be established.
- **What was tried**: (1) ExistPart(k') at n=2 — environment mismatch: ExistPart evaluates at constant env `(fun _ => t)`, need `[x,t]`. (2) Model transfer via `nf_agreement_from_shared_nf` — circular: need 2-var type agreement to prove 2-var type agreement. (3) Direct zone encoding at higher depth — recursive, requires reformulated ExistPart with non-constant parent environments.
- **Why stuck**: The `ExistPart` definition quantifies over `parent_atoms : AtomKind sig 1 → Bool` and evaluates in env `Fin.cons x (fun _ => t)`, but the 3-var existential has parent env `[x, t]` (arity 2), not `[t, t]`. No existing lemma bridges this gap on Prior structures.
- **What is needed**: Either (A) a Prior compositionality theorem (Rabinovich Lemma 5.1: on Prior structures, the n-var depth-k type is determined by 1-var types + ordering), estimated 200-400 lines; or (B) reformulate ExistPart to accept arbitrary parent environments, which is a major structural change.
- **Prohibited**: Do NOT use sorry, def X := True, or vacuous placeholder

**Timing**: 3 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` - fill `sorry` at line 104
- Possibly new helper files if proof exceeds 500 lines

**Verification**:
- `lean_verify` on `existPart_succ_n1_bypass` shows NO `sorryAx`
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampBypass` succeeds
- The k=0 path remains unchanged and sorry-free

---

### Phase 3: Close n>=2 Sorry and Complete Mutual Induction [NOT STARTED]

**Goal**: With n=1 at all depths now sorry-free, close the n>=2 sorry in `existPart_succ` (from `KampMutualInduction.lean`) using the constant-base projection pattern from the boneyard.

**Tasks**:
- [ ] In `KampMutualInduction.lean`, replace the `sorry` in the `existPart_succ` n>=2 branch (the `succ n''` case) with the `Classical.em + bool_eq_of_iff_same + constant-base-projection` pattern from `existPart_zero` (depth-0 n>=2 case, lines 204-364 of boneyard)
- [ ] The key insight: when all base variables equal t, the (n''+3)-var existential projects to a 2-var existential. The atom part projects via `bool_eq_of_iff_same` (identical to depth-0). The quantifier part projects similarly because the (n''+4)-var depth-k existentials with constant base `(fun _ => t)` reduce to 3-var when redundant base variables are collapsed.
- [ ] Verify `lean_verify` on `kamp_mutual_induction` shows NO `sorryAx`
- [ ] Verify `lean_verify` on `nf_2var_exist_formula_prior_filled` shows NO `sorryAx`

**Timing**: 2 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampMutualInduction.lean` - fill n>=2 sorry in `existPart_succ`

**Verification**:
- `lean_verify` on `kamp_mutual_induction` shows NO `sorryAx`
- `lean_verify` on `existPart_succ` shows NO `sorryAx`
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampMutualInduction` succeeds with 0 sorries

---

### Phase 4: Wire Mutual Induction into NfCharFormula and Verify completeness_discrete [NOT STARTED]

**Goal**: Connect the sorry-free mutual induction to the live NfCharFormula dispatch, replacing the sorry-carrying `existPart_succ_n1_bypass` call path with the mutual induction's `nf_2var_exist_formula_prior_filled`. Verify the entire completeness chain is sorry-free.

**Tasks**:
- [ ] In `NfCharFormula.lean`, update the `k + 2` case (line 646-651) to use `nf_2var_exist_formula_prior_filled` from KampMutualInduction instead of `existPart_succ_n1_bypass`. Alternatively, if `existPart_succ_n1_bypass` itself is now sorry-free (from Phase 2), no NfCharFormula changes are needed -- verify this.
- [ ] Run `lean_verify` on `nf_2var_exist_formula_prior` (the function that `nf_characterizable_temporal_prior_classical` uses) to confirm no `sorryAx`
- [ ] Run `lean_verify` on `nf_characterizable_temporal_prior_classical` to confirm no `sorryAx`
- [ ] Run `lean_verify` on `kamp_prior_expressive_completeness` to confirm no `sorryAx`
- [ ] Run `lean_verify` on `US_expressively_complete_over_prior` to confirm no `sorryAx`
- [ ] Run `lean_verify` on `completeness_discrete` to confirm no `sorryAx` (or identify remaining sorry chains)
- [ ] Run full `lake build` to confirm no regressions across the entire project
- [ ] Clean up: remove the `#exit` from `RabinovichGeneralized.lean` boneyard file header comment, or add a note that the live version is in `KampMutualInduction.lean`

**Timing**: 1 hour

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfCharFormula.lean` - potentially update dispatch (only if needed)
- `Theories/Bimodal/Boneyard/RabinovichPath/RabinovichGeneralized.lean` - update archive comment

**Verification**:
- `lean_verify Bimodal.Metalogic.WeakCanonical.Kamp.kamp_mutual_induction` shows no `sorryAx`
- `lean_verify Bimodal.Metalogic.BXCanonical.Completeness.completeness_discrete` shows no `sorryAx` from this chain (or identifies remaining blockers in other chains)
- `lake build` succeeds with no new sorries introduced

## Testing & Validation

- [ ] `lean_verify` on `existPart_succ_n1_bypass` at all depths shows no `sorryAx`
- [ ] `lean_verify` on `kamp_mutual_induction` shows no `sorryAx`
- [ ] `lean_verify` on `nf_2var_exist_formula_prior_filled` shows no `sorryAx`
- [ ] `lean_verify` on `completeness_discrete` to assess remaining sorry count
- [ ] Full `lake build` with no regressions
- [ ] k=0 path (KampBypassCore/Until/Since) remains untouched and sorry-free

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampMutualInduction.lean` -- NEW: mutual induction scaffold (CharPart + ExistPart + combined induction + NfCharFormula connector)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- MODIFIED: sorry at line 104 filled
- Possibly `KampBypassUntil_kgt0.lean` / `KampBypassSince_kgt0.lean` -- NEW: factored k>0 zone proofs (only if Phase 2 exceeds 500 lines)
- `specs/303_k_gt_0_depth_induction/summaries/02_depth-induction-summary.md` -- implementation summary

## Rollback/Contingency

If the k>0 zone dispatch proves intractable (Risk 1 or 2 materializes):
1. The mutual induction scaffold (Phase 1) stands alone with the same sorry sites as the boneyard -- no regression.
2. `KampBypass.lean:104` sorry remains as-is -- the existing k=0 sorry-free infrastructure is untouched.
3. `git revert` any Phase 2+ commits to restore the pre-implementation state.
4. Escalation path: research a different approach to the base environment mismatch (e.g., generalizing ExistPart to arbitrary base environments instead of Rabinovich's negation closure).
