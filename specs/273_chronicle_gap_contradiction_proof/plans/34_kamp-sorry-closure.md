# Implementation Plan: Close 4 Depth-0 KampBypass Sorries

- **Task**: 273 - chronicle_gap_contradiction_proof
- **Status**: [IN PROGRESS]
- **Effort**: 6 hours
- **Dependencies**: None (all mathematical infrastructure is sorry-free)
- **Research Inputs**: specs/273_chronicle_gap_contradiction_proof/reports/33_team-research.md
- **Artifacts**: plans/34_kamp-sorry-closure.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close the 4 remaining depth-0 sorries in KampBypass.lean (L974, L1579, L1637, L1749) to make `existPart_succ_n1_bypass_k0` sorry-free, which flows through `kamp_prior_expressive_completeness` and `US_expressively_complete_over_prior` to unblock `chronicle_gap_contradiction`. Three prior implementation cycles failed due to analysis-paralysis (writing skeletons instead of closing goals), worktree confusion (3 stale worktrees with divergent state), and the decomposition anti-pattern (splitting sorries into sub-sorries which INCREASED the sorry count from 4 to 7). This plan addresses those failure modes by mandating direct sorry closure with no sub-decomposition, working exclusively on main branch, and sequencing by risk (highest-confidence first).

### Research Integration

Report 33 (team research, 4 teammates, 2026-06-15) confirmed all 4 depth-0 sorries are provable as stated. Key findings: (1) Root cause of 3 failed cycles is analysis-paralysis, not mathematical difficulty. (2) The bracket sorry (L1579) requires a `bracket_holds_of_uniform_segments` helper (~60-80 lines) because `h_eval_quant` provides witnesses in arbitrary order but `IntervalPattern.holds` requires strictly increasing witnesses. (3) A validated proof recipe for the eq case (L974) exists in `handoffs/eq-case-recipe-20260614.md` with tested tactic sequences. (4) `enriched_bypass_since` soundness for positive between_xt SSNs MUST be verified before attempting the Since proof (L1749). (5) The depth >= 2 sorry (L1837) may be unnecessary via the classical existence path through `nf_characterizable_temporal_prior_classical`.

### Prior Plan Reference

Plan v32 (5 phases, 8 hours estimated) attempted all 5 sorries (4 depth-0 + 1 depth >= 2) in fully sequential phases. Key lessons: (1) The `unfold atom_eval + exact h` technique resolves Fin.cons/Fin.cases proof-term mismatch after subst. (2) Zone extraction helpers compose ZoneBridge theorems with `nf_depth0_char_formula_correct`. (3) Line numbers in v32 were outdated (L753/1284/1503/1615 vs actual L974/1579/1637/1749). (4) V32 bundled the eq and since cases into Phase 1, but these have very different risk profiles (eq=HIGH confidence, since=MEDIUM requiring soundness verification). (5) Postmortem bindings from v32 remain valid: do NOT extract NF data from formula truth, do NOT use wrong-depth characteristic formulas.

### Roadmap Alignment

- Advances: Kamp chain closure (`kamp_prior_expressive_completeness` -> `US_expressively_complete_over_prior`) -- one of two independent sorry chains blocking `completeness_discrete`
- The other chain (succ_cofinal via Reynolds k-equivalence bypass, task 202) is independent
- `chronicle_gap_contradiction` depends on `US_expressively_complete_over_prior` being sorry-free

## Goals & Non-Goals

**Goals**:
- Fill the 4 remaining depth-0 sorries in KampBypass.lean (L974, L1579, L1637, L1749)
- Make `existPart_succ_n1_bypass_k0` sorry-free (verified via `lean_verify`)
- Verify the downstream chain: `kamp_prior_expressive_completeness` and `US_expressively_complete_over_prior` sorry status
- Verify whether `chronicle_gap_contradiction` is unblocked

**Non-Goals**:
- Filling the depth >= 2 sorry (L1837) -- may be unnecessary via classical existence path; evaluate after depth-0 closure
- Filling NfCharFormula.lean:542 (`nf_exist_backward_prior`) -- bypassed by the Kamp pipeline
- File splitting of KampBypass.lean -- recommended but optional; defer to post-closure cleanup
- Filling StaviCompleteness.lean sorries (separate chain)
- Proving succ_cofinal (task 202, Reynolds bypass)
- Cleaning up stale worktrees (housekeeping, not blocking)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Analysis-paralysis recurrence: agents produce analysis/skeletons instead of closing goals | H | M | Each phase has a MANDATORY output requirement: sorry-free proof code. No sub-decomposition allowed. Use `lean_multi_attempt` to test tactics before editing. |
| Bracket witness ordering: IntervalPattern.holds requires strictly increasing witnesses but h_eval_quant gives arbitrary order | M | M | Extract `bracket_holds_of_uniform_segments` helper that sorts witnesses using Classical.choose + Finset.sort on the model's DecidableLinearOrder. nf_y_proj injectivity ensures distinctness. |
| enriched_bypass_since soundness: positive between_xt SSNs may not correctly bound witnesses to (x,t) | H | M | Phase 4 BEGINS with soundness verification. If unsound, the Since case must use VecEA2 brackets (analogous to Until). Plan includes contingency. |
| Line number drift between plan writing and implementation | L | H | Plan references current sorry lines (L974, L1579, L1637, L1749) verified on main branch as of 2026-06-15. Implementer must re-verify via grep before each phase. |
| Heartbeat budget exhaustion in KampBypass.lean (already 800000-1600000) | M | M | Factor proofs into small private helper lemmas. Use `set_option maxHeartbeats` locally if needed. Keep proof terms compact. |
| Forward direction (L1637) complexity: zone-by-zone reconstruction is the hardest depth-0 sorry | M | L | Mirror the backward direction structure (L1432-1576 are sorry-free). Use `.mp` direction of zone bridges (backward used `.mpr`). |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |

Phases 2 and 3 can execute in parallel (bracket and forward are independent sorries).

---

### Phase 1: Eq Case (L974) [COMPLETED]

**Goal**: Close the `existPart_succ_n1_bypass_k0` compatible subcase sorry at KampBypass.lean:974. This is the highest-confidence sorry with a validated proof recipe. Establishes the proof pattern for subsequent phases.

**Tasks**:
- [x] Re-verify sorry location via `grep -n 'sorry' KampBypass.lean` (line numbers may have shifted)
- [x] Implement backward direction (mpr): Use validated recipe from `handoffs/eq-case-recipe-20260614.md`. Key steps: `witness_eq_t_of_no_order` forces x=t via subst. `nf_characteristic` + `nf_characteristic_satisfies` provide nf_x. `simp only [enriched_bypass_eq]` + `rw [formula_disjList_iff]` opens the goal. Prove membership via `Fintype.complete`. Prove truth via `char_1_correct` + zone-by-zone conjuncts using `eq_case_zone_{below,above,eq}.mpr`. *(deviation: altered -- factored into eq_case_iff helper theorem with backward direction using all 6 zone cases)*
- [x] Implement forward direction (mp): Extract nf_x from disjunction via `formula_disjList_iff`. Use `char_1_correct` to get `nf_eval_nf M 1 1 [t] nf_x`. Reconstruct `nf_eval_nf M 1 2 [t,t] sub_nf` from nf_x + h_atoms + zone bridges (mp direction). *(deviation: altered -- added by_cases on ssn_compat to handle unrealizable 3-var sub-NFs with sub_nf.2=true. Forward direction uses zone bridges for compatible ssn and h_ssn_compat assumption for incompatible case. Added by_cases h_ssn_compat in existPart_succ_n1_bypass_k0_eq with Bot fallback.)*
- [x] Verify `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampBypass` passes with 4 remaining sorries reduced to 3 *(deviation: altered -- build exits code 1 due to remaining sorry declarations, but no kernel errors and eq case sorry is gone. Sorry count reduced from 5 to 4.)*

**Timing**: 1.5 hours (~150-250 lines)

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- replace sorry at ~L974

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampBypass` succeeds
- grep shows 3 remaining sorries (bracket ~L1579, forward ~L1637, since ~L1749; plus depth >= 2 ~L1837)

---

### Phase 2: Bracket Helper + Bracket Sorry (L1579) [BLOCKED]

**Goal**: Close the bracket case sorry at KampBypass.lean:2096. First extract a `bracket_holds_of_uniform_segments` helper lemma that proves `BracketFormula.holds` when all segment types are uniform. Then apply it.

**BLOCKER** (Phase 2):
- **What failed**: `enriched_vecEA2_until` constructs a `BracketFormula n` where `n = pos_between.length` and `pointTypes i = nfPred ... (nf_y_proj (pos_between[i]))`. The `IntervalPattern.holds` definition requires strictly increasing witnesses `w_0 < w_1 < ... < w_{n-1}` where `w_i` satisfies `pointTypes i`. For the backward direction, `h_eval_quant` provides witnesses for each positive between_tx SSN in `(t, x)`, but these witnesses may not be in the order prescribed by `pos_between` (which follows `Fintype.elems.val.toList.filter` ordering, unrelated to the model's linear order).
- **What was tried**:
  1. Direct proof via `split` on the `IntervalPattern.holds` match — produces HEq goals that are hard to work with, and the n+1 case has the ordering mismatch.
  2. Permutation argument for uniform-segment patterns — reordering witnesses to be increasing also permutes the alpha indices, producing the wrong pointType at each position.
  3. `chainHolds` approach — recursively finding witnesses in pos_between order requires that for each SSN, there exists a witness ABOVE all previously chosen witnesses, which is not guaranteed.
  4. Analysis of whether n >= 2 can occur — confirmed: with `sig.preds >= 2`, pos_between can have 2+ elements with arbitrary model witness orderings.
- **Why stuck**: The `enriched_vecEA2_until` definition has a design flaw: `pos_between` is ordered by `Fintype.elems` (implementation-dependent, model-independent), but `IntervalPattern.holds` requires witnesses in the model's linear order matching the `pos_between` index order. For n >= 2 with adversarial models (e.g., exactly n witness points in (t,x) in reverse pos_between order), the backward direction `∃ x, nf_eval → holdsLeft` is unprovable.
- **What is needed**: Fix `enriched_vecEA2_until` to sort `pos_between` by model-dependent witness ordering. Since the definition is `noncomputable`, the model is not available at definition time — the fix requires either (a) a different VecEA2 encoding that does not depend on witness ordering (e.g., conjunction of individual existentials for the between_tx zone), or (b) a permutation-invariance lemma for `IntervalPattern.holds` with uniform segment types (which does not hold as stated). Option (a) is the correct architectural fix: replace the single bracket with a conjunction `Formula.untl (nfPred ssn_0) top ∧ Formula.untl (nfPred ssn_1) top ∧ ...` for the between_tx zone, similar to how above_x and eq_x zones are handled.
- **Prohibited**: Do NOT use sorry, def X := True, or vacuous placeholder.

**Tasks**:
- [ ] Extract `bracket_holds_of_uniform_segments` helper (~60-80 lines). *(deviation: blocked — enriched_vecEA2_until witness ordering bug, see BLOCKER above)*
- [ ] Close bracket sorry: for n=0 positive between_tx SSNs, bracket holds trivially (no witnesses needed, only segment guard). For n >= 1, apply `bracket_holds_of_uniform_segments` with witnesses from `h_eval_quant`. *(deviation: blocked — n >= 1 case requires architectural fix)*
- [ ] Verify `lake build` passes

**Timing**: 1.5 hours (~100-150 lines)

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- add helper lemma, replace sorry at ~L1579

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampBypass` succeeds
- grep shows 2 remaining in-scope sorries (forward ~L1637, since ~L1749; plus depth >= 2 ~L1837)

---

### Phase 3: Forward Direction (L2151) [PARTIAL]

**Goal**: Close the `forward_nf_eval_of_holdsLeft` sorry at KampBypass.lean:2151.

**Progress** (as of 2026-06-15):
- Build errors fixed (was 21 → 9 → 0). Build is GREEN.
- `h_t_compat` and `h_ssn_compat` parameters added to `forward_nf_eval_of_holdsLeft`
- `by_cases` on both conditions added to `existPart_succ_n1_bypass_k0_until` call site (Bot fallback for failures)
- Atom part: COMPLETE (pred atoms via h_compat/h_t_compat, order atoms via h_gt/h_lt/h_t_lt_x)
- Quant part: 5 of 6 zones proved (below_t, eq_t, eq_x, above_x, inconsistent)
- between_tx zone: BLOCKED by same BracketFormula design flaw as Phase 2 (bracket witness ordering)
- Incompatible-ssn case: COMPLETE (both directions)
- Neg-ssn-compat Bot case: COMPLETE

**Remaining blocker**: The between_tx zone forward direction requires extracting existentials from `BracketFormula.holds`, which depends on the same ordering issue as Phase 2. This sorry is consolidated with the bracket sorry at L2151.

**Tasks**:
- [x] Add `h_t_compat` parameter to `forward_nf_eval_of_holdsLeft`
- [x] Add `by_cases` on t_compat and ssn_compat in call site
- [x] Prove atom part (all 3 sub-cases)
- [x] Prove quant part for 5/6 zones
- [ ] Prove between_tx zone *(blocked by BracketFormula design flaw — same as Phase 2)*
- [x] Fix all build errors to green

**Timing**: 1.5 hours (~150-200 lines)

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- replace sorry at ~L1637

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampBypass` succeeds
- grep shows 1 remaining in-scope sorry (since ~L1749; plus depth >= 2 ~L1837)

---

### Phase 4: Since Case (L1749) [NOT STARTED]

**Goal**: Close `existPart_succ_n1_bypass_k0_since` sorry at KampBypass.lean:1749. CRITICAL: Phase begins with soundness verification of `enriched_bypass_since` for positive between_xt SSNs. If unsound, the approach pivots to VecEA2 brackets.

**Tasks**:
- [ ] **VERIFY enriched_bypass_since soundness**: Inspect the Since formula encoding for positive between_xt SSNs. Check whether `Formula.untl char_y Formula.top` correctly bounds witnesses to (x,t). Specifically: does the backward direction (formula true -> exists x, nf_eval) correctly reconstruct the interval bound? Use `lean_goal` and `lean_hover_info` to inspect types.
- [ ] If soundness verified: provide `enriched_bypass_since atomMap h_surj char_1 sub_nf parent_atoms` as witness. Prove biconditional from `formula_disjList_iff` + Since semantics + zone bridges. The Since case mirrors Until but with x < t and swapped zones.
- [ ] If soundness NOT verified: pivot to VecEA2 approach. Create `enriched_vecEA2_since` (mirroring `enriched_vecEA2_until`). Prove backward and forward using the same VecEA2 machinery with `Formula.snce` instead of `Formula.untl`.
- [ ] Verify `existPart_succ_n1_bypass_k0` is sorry-free: `lean_verify existPart_succ_n1_bypass_k0` should show no sorryAx at depth 0.
- [ ] Verify `lake build` passes

**Timing**: 1.5 hours (~150-200 lines)

**Depends on**: 2, 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- replace sorry at ~L1749

**Verification**:
- `lean_verify Bimodal.Metalogic.WeakCanonical.Kamp.existPart_succ_n1_bypass_k0` shows no sorryAx
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampBypass` succeeds
- Only `sorry` remaining in KampBypass.lean is the depth >= 2 (L1837)

---

### Phase 5: Chain Verification and Chronicle Gap [NOT STARTED]

**Goal**: Verify the downstream Kamp chain is sorry-free (depth >= 2 sorry quarantined). Check whether `chronicle_gap_contradiction` is unblocked. Verify whether depth >= 2 sorry is actually needed.

**Tasks**:
- [ ] Verify `lean_verify kamp_prior_expressive_completeness` -- check if the depth >= 2 sorry propagates through or is quarantined by the classical existence path
- [ ] Verify `lean_verify US_expressively_complete_over_prior` -- check sorry status
- [ ] Verify `lean_verify chronicle_gap_contradiction` -- check if it is unblocked now. The dependency chain is: `chronicle_gap_contradiction` -> `gap_contradicts_prior` -> `US_expressively_complete_over_prior` -> `kamp_prior_expressive_completeness`
- [ ] If the chain remains blocked by the depth >= 2 sorry: investigate whether `nf_characterizable_temporal_prior_classical` (which provides the classical existence path) bootstraps from depth 1 without needing the depth >= 2 bypass. Document findings.
- [ ] If `chronicle_gap_contradiction` is unblocked and has its own sorry: evaluate filling it (~50-80 lines using now-sorry-free model surgery + Kamp expressive completeness)
- [ ] Run `lake build` on full project to verify no regressions
- [ ] Document final sorry inventory for the Kamp module

**Timing**: 0.5-1 hours (verification + optional fill)

**Depends on**: 4

**Files to modify**:
- Potentially `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- fill `chronicle_gap_contradiction` if unblocked
- No other files modified in this phase

**Verification**:
- `lean_verify` results for the full chain documented
- `lake build` full project succeeds
- Sorry inventory recorded

---

## Testing & Validation

- [ ] After Phase 1: grep shows 3+1 remaining sorries in KampBypass.lean (bracket, forward, since + depth >= 2)
- [ ] After Phases 2+3: grep shows 1+1 remaining sorries (since + depth >= 2)
- [ ] After Phase 4: `lean_verify existPart_succ_n1_bypass_k0` shows no sorryAx
- [ ] After Phase 4: grep shows 0+1 remaining sorry in KampBypass.lean (only depth >= 2 at ~L1837)
- [ ] After Phase 5: `lean_verify kamp_prior_expressive_completeness` and `US_expressively_complete_over_prior` status documented
- [ ] After Phase 5: `lake build` full project succeeds with 0 errors

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- 4 depth-0 sorries filled (~550-800 new lines)
- `specs/273_chronicle_gap_contradiction_proof/plans/34_kamp-sorry-closure.md` -- this plan
- Potentially `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- `chronicle_gap_contradiction` filled if unblocked

## Rollback/Contingency

**If eq case (Phase 1) recipe fails**: The validated recipe was tested through to the zone-bridge dispatch point. If Lean version changes invalidated tactics, use `lean_goal` at each step to identify the exact divergence point. Adapt the recipe. The mathematical path is validated.

**If bracket helper (Phase 2) sorting argument is harder than expected**: Prove the n=0 and n=1 subcases first (n=0 is trivial, n=1 needs a single witness). If n >= 2 is rare/impossible for depth-0 NFs, add a sorry with targeted TODO and proceed.

**If forward direction (Phase 3) zone extraction is tedious**: Factor each zone case into a separate private helper. The backward direction (sorry-free at L1432-1576) validates the zone-bridge approach and provides the exact mirror structure. If a specific zone case is hard, sorry it with a targeted TODO and proceed.

**If enriched_bypass_since is unsound (Phase 4)**: Pivot to VecEA2 approach. This is architecturally identical to the Until case (which is sorry-free) with `Formula.snce` replacing `Formula.untl`. Estimated additional effort: +0.5 hours.

**If depth >= 2 blocks the chain (Phase 5)**: The 4 depth-0 closures are the primary deliverable. If the classical existence path does not bypass depth >= 2, document the blocker. The depth >= 2 sorry (~500 lines per research estimate) could be a follow-on task.

**If the approach fails entirely**: All existing sorry-free code remains valid. Each phase is independently valuable: Phase 1 alone validates the proof pattern, Phases 1-4 make all depth-0 sorries closed.

## Anti-Pattern Guards

These anti-patterns caused 3 prior implementation failures and MUST NOT be repeated:

1. **Do NOT decompose sorries into sub-sorries** -- close them directly. The decomposition anti-pattern in Cycle 4 INCREASED sorry count from 4 to 7.
2. **Do NOT produce analysis-only outputs** -- every implementation dispatch must produce sorry-free proof code that compiles.
3. **Do NOT use worktrees** -- work on main branch ONLY. Three stale worktrees (agent-a6741c7a21a3a3530, agent-a55505307ae3d4932, agent-a83818cfb35228c46) with divergent sorry counts caused confusion.
4. **Do NOT reference outdated line numbers without re-verifying** -- grep for `sorry` at the start of each phase.
5. **Do NOT write helper lemmas that defer the actual proof** -- helpers must be sorry-free and directly used in the same phase.
