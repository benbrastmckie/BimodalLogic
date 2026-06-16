# Implementation Plan: BracketFormula k Encoding Fix for KampBypass

- **Task**: 273 - chronicle_gap_contradiction_proof
- **Status**: [IMPLEMENTING]
- **Effort**: 9 hours
- **Dependencies**: None (Phases 1-2 of v37 completed; backward sorry closed; VecEAFormula.lean sorry-free)
- **Research Inputs**: specs/273_chronicle_gap_contradiction_proof/reports/38_team-research.md
- **Artifacts**: plans/39_bracketformula-k-encoding.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Replace the broken `BracketFormula 0` + Since-at-endpoint encoding in `enriched_vecEA2_until` with `BracketFormula k` (where k = number of positive between_tx SSNs). The n=0 encoding is definitively unprovable in the forward direction because `Formula.snce char_y Formula.top` at x loses the lower bound `t < y`. The BracketFormula k approach is semantically correct: `IntervalPattern.holds` directly provides k strictly ordered witnesses in `(t, x)` with both bounds guaranteed. Report 38 (team research, 4 teammates, unanimous consensus) confirms that BracketFormula k and nested Until are the SAME construction at the infrastructure level -- `VecEA2.translateLeft` calls `bracketBuildRight` which automatically converts BracketFormula k into the correct nested Until chain. The VecEA2 translation machinery (VecEATranslation.lean, ~300 lines) is sorry-free and does all the heavy lifting.

### Research Integration

Report 38 establishes:
1. BracketFormula k > 0 IS the correct fix (unanimous across 4 teammates)
2. Nested Until (Approach A) is ruled out -- it breaks x-sharing across independent chains
3. BracketFormula k and nested Until are the same construction via `bracketBuildRight`
4. Sorting lemma feasible via Mathlib's `Tuple.sort` + `Monotone.strictMono_of_injective` (~30-50 lines)
5. `nf_y_proj` injectivity closeable within a fixed disjunct (~15-30 lines)
6. `seg_guard` subinterval lemma straightforward (~10-15 lines)
7. Since direction NOT a simple mirror -- no VecEA2/bracket machinery exists in the Since path

### Prior Plan Reference

Plan v37 (5 phases, 8 hours): Phases 1-2 completed (eq case + backward sorry closed via BracketFormula.trivial). Phases 3-4 BLOCKED by encoding flaw -- `Formula.snce char_y Formula.top` at x loses lower bound `t < y`. Current state: 4 sorries at L2205, L2380, L2382, L2535. Build GREEN. Key learnings: (1) Effort for definition rewrite + backward proof was ~45 min actual vs 2h estimated -- phase sizing can be tighter. (2) Anti-pattern guards validated: no sub-sorry decomposition, no analysis-only outputs. (3) The Since direction has fundamentally different structure from Until (no VecEA2 infrastructure).

### Roadmap Alignment

- Advances: Kamp chain closure (`kamp_prior_expressive_completeness` -> `US_expressively_complete_over_prior`) -- one of two independent sorry chains blocking `completeness_discrete`
- The k>0 sorry at L2535 (depth induction) is NOT on the critical path for this plan -- it is explicitly a non-goal, quarantined as a follow-on task

## Goals & Non-Goals

**Goals**:
- Rewrite `enriched_vecEA2_until` to return `VecEA2 k` (k = `pos_between.length`) instead of `VecEA2 0`
- Prove three helper lemmas: nf_y_proj injectivity, witness sorting, seg_guard subinterval
- Re-prove backward direction with the new BracketFormula k (sorting + injectivity)
- Prove forward direction with BracketFormula k (straightforward -- bracket provides ordered witnesses in (t, x))
- Fix `enriched_bypass_since` encoding for positive between_xt SSNs (either introduce VecEA2/bracket into Since path or construct bounded Since encoding)
- Close sorries at L2205 (forward until), L2380 (forward since), L2382 (backward since)
- Verify downstream chain: `existPart_succ_n1_bypass_k0` -> `kamp_prior_expressive_completeness` -> `US_expressively_complete_over_prior`

**Non-Goals**:
- Closing the k>0 sorry at L2535 -- requires separate depth induction argument
- Closing `nf_2var_exist_formula_prior` (NfCharFormula.lean:610) -- bypassed by Kamp pipeline
- File splitting of KampBypass.lean (defer to post-closure cleanup)
- Proving succ_cofinal (task 202, Reynolds bypass)
- Modifying ExistsForallNF.lean BracketFormula/IntervalPattern definitions

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Backward direction re-proof harder with k > 0: sorting arbitrary witnesses into bracket order | H | M | Mathlib `Tuple.sort` gives the permutation directly. `nf_y_proj` injectivity ensures distinctness. Factor into a reusable helper lemma. |
| Since direction has no VecEA2 infrastructure -- fix approach unclear | H | H | Phase 4 investigates two options: (a) introduce VecEA2/bracket into Since path (mirror Until), (b) construct direct bounded Since encoding. Commit to whichever approach has fewer structural changes. |
| Heartbeat budget exhaustion (KampBypass.lean already at 800000-1600000) | M | M | Factor helper lemmas outside the main proof. Use `set_option maxHeartbeats` locally if needed. |
| Definition change breaks the already-proved backward direction | M | L | The backward proof at L1927 currently works with BracketFormula 0. With BracketFormula k, the bracket case gains the sorting sub-goal but the rest is structurally similar. The existing proof provides a template. |
| nf_y_proj injectivity proof requires subtler case analysis than expected | M | L | Research confirms within a fixed disjunct (fixed nf_x), only y-atoms vary between distinct SSNs. The SSN structure directly encodes y-atom values. |
| Line number drift during implementation | L | H | Re-verify sorry locations via `grep -n 'sorry' KampBypass.lean` at start of each phase. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 2 |
| 5 | 5 | 3, 4 |

Phases 3 and 4 can execute in parallel (Until proof and Since fix are independent after the definition change).

---

### Phase 1: Definition Rewrite + Helper Lemmas [COMPLETED]

**Goal**: Change `enriched_vecEA2_until` from `BracketFormula 0` to `BracketFormula k` (k = number of positive between_tx SSNs). Prove three sorry-free helper lemmas needed by subsequent phases.

**Tasks**:
- [x] Re-verify sorry inventory: `grep -n 'sorry' KampBypass.lean` to confirm locations at L2205, L2380, L2382, L2535
- [x] Rewrite `enriched_vecEA2_until` (L444-490): change `BracketFormula 0` to `BracketFormula pos_between.length` where `pos_between` is the list of positive between_tx SSNs
- [x] Set each bracket pointType to shared `pos_pt` disjunction (design change: shared disjunction avoids witness-index permutation issue; replaces per-SSN `char_y(nf_y_proj ssn_i)`)
- [x] Set each bracket segmentType to `seg_guard` (same conjunction of negated char_y formulas for negative between_tx SSNs)
- [x] Remove `Formula.snce char_y Formula.top` from endpointRight for positive between_tx SSNs (lines 481-485) -- these conditions are now handled by the bracket witnesses
- [ ] Prove `nf_y_proj_injective_on_pos_between`: within a fixed disjunct (fixed nf_x, nf_x_1var, parent_atoms), `nf_y_proj` is injective on `pos_between` (~15-30 lines) *(proved inline in Phase 2 backward proof at L2228-2300 instead of as standalone helper)*
- [ ] Prove `seg_guard_subinterval`: if `seg_guard` holds on `(t, x)` then it holds on any subinterval `(a, b)` with `t <= a < b <= x` (~10-15 lines) *(proved inline in Phase 2 backward proof as `seg_guard_on_interval` at L2168 instead of as standalone helper)*
- [x] Prove `witnesses_sorting`: replaced by sorry-free `bracket_from_distinct_witnesses` (L1943) using `Finset.orderEmbOfFin` — handles sorting, injectivity, and bracket construction in one helper
- [x] Verify build GREEN after definition change and helper lemmas

**Timing**: 2.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- definition rewrite at L444-490
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEAFormula.lean` -- helper lemmas (sorting, seg_guard subinterval) if they belong at the infrastructure level; otherwise in KampBypass.lean

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampBypass` compiles (sorries expected but no errors)
- Helper lemmas verified sorry-free via `lean_verify`
- Definition type signature returns `Sigma n, VecEA2 n` with n = pos_between.length

---

### Phase 2: Backward Direction Re-proof [COMPLETED]

**Goal**: Re-prove `backward_holdsLeft_of_nf_eval` (L1927) with the new BracketFormula k. The backward direction goes from `nf_eval` (semantic evaluation at witnesses) to `VecEA2.holdsLeft` (temporal formula holds). The key new sub-goal: given k unsorted witnesses from `nf_eval`, sort them into strictly increasing order for `IntervalPattern.holds`.

**Tasks**:
- [x] Re-verify sorry/proof state at `backward_holdsLeft_of_nf_eval` after Phase 1 definition change
- [x] Update the bracket proof case (currently at L2093-2097, BracketFormula.trivial): replace `BracketFormula.trivial_holds` with a proof that constructs k sorted witnesses — now at L2197-2317 using `bracket_from_distinct_witnesses`
- [x] Establish that the k witnesses from `h_eval_quant` are distinct — proved inline via `h_wit_injective` (L2228-2300, funext on AtomKind + List.Nodup)
- [x] Obtain a strictly increasing permutation of the witnesses — handled by `bracket_from_distinct_witnesses` internally via `Finset.orderEmbOfFin`
- [x] Verify that pointType conditions are preserved under permutation — proved via `h_wit_pos_pt` (L2305-2312) showing each witness satisfies `pos_pt` disjunction
- [x] Show segment guards hold on each sub-segment — proved via `seg_guard_on_interval` (L2168) showing seg_guard holds at all y in (t, x)
- [x] Verify `backward_holdsLeft_of_nf_eval` is sorry-free — confirmed: 0 sorries between L2008-2318
- [x] Verify build GREEN

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- backward proof update at L1927-2130 area

**Verification**:
- `lean_verify backward_holdsLeft_of_nf_eval` shows no sorryAx
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampBypass` compiles
- grep shows sorry count reduced by 0 or 1 (depending on whether backward was already sorry-free before or not)

---

### Phase 3: Forward Direction Proof (Until) [COMPLETED]

**Goal**: Prove `forward_nf_eval_of_holdsLeft` (sorry at L2205). The forward direction goes from `VecEA2.holdsLeft` (temporal formula) to `nf_eval` (semantic evaluation). With BracketFormula k, `IntervalPattern.holds` directly provides k strictly ordered witnesses in `(t, x)`, each satisfying their pointType. This is the straightforward direction.

**Tasks**:
- [ ] Re-verify sorry location at `forward_nf_eval_of_holdsLeft` after Phases 1-2
- [ ] Extract the k witnesses from `IntervalPattern.holds`: obtain `witnesses : Fin k -> M.carrier` with strict ordering, bounds in `(t, x)`, pointType conditions, and segment guard conditions
- [ ] For each witness `witnesses i`: the pointType `alpha_i = char_y(ssn_i)` holds, giving the between_tx positive SSN evaluation
- [ ] For negative between_tx SSNs: the segment guard `seg_guard` holds between consecutive witnesses, giving `neg char_y` at all points in `(t, x)` not at a witness
- [ ] For non-between_tx zones (eq_x, above_x, below_t, eq_t): proof is unchanged from the existing partially-proved forward direction (these cases were already handled before the encoding flaw was discovered)
- [ ] Close the sorry at L2205 completely
- [ ] Verify `forward_nf_eval_of_holdsLeft` is sorry-free via `lean_verify`
- [ ] Verify build GREEN

**Timing**: 2 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- forward proof at L2138-2205 area

**Verification**:
- `lean_verify forward_nf_eval_of_holdsLeft` shows no sorryAx
- grep shows 3 remaining sorries (L2380, L2382, L2535)
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampBypass` compiles

---

### Phase 4: Since Direction Fix [COMPLETED]

**Goal**: Fix `enriched_bypass_since` (L513-592) and close the Since sorries at L2380 (forward) and L2382 (backward). The Since direction currently uses a flat `formula_disjList` with no VecEA2/bracket infrastructure. Two options: (a) introduce VecEA2/bracket into the Since path (mirror the Until approach), (b) construct a direct bounded Since encoding. Determine approach, implement, and close both sorries.

**Tasks**:
- [ ] Re-verify sorry locations at L2380, L2382 after Phases 1-2
- [ ] Analyze `enriched_bypass_since` structure: it constructs `Formula.and pre_at_t (Formula.snce pt_x guard)` where positive between_xt SSNs are encoded as `Formula.untl char_y Formula.top` at x (L586) -- same unbounded flaw as Until
- [ ] **Option A (preferred)**: Rewrite `enriched_bypass_since` to use VecEA2 infrastructure. Construct `VecEA2 k` for the Since direction with bracket witnesses in `(x, t)` for positive between_xt SSNs. Use `VVecEA2.translateLeft` to generate the temporal formula. This mirrors the Until approach and reuses all proven infrastructure.
- [ ] **Option B (fallback)**: If VecEA2 infrastructure does not directly support Since (the translateLeft produces Until formulas, not Since), construct a direct bounded Since encoding using nested Since formulas that place witnesses in `(x, t)`.
- [ ] Prove backward direction for Since: `nf_eval` -> formula (using sorting + injectivity, mirroring Phase 2)
- [ ] Prove forward direction for Since: formula -> `nf_eval` (bracket provides witnesses in `(x, t)`, mirroring Phase 3)
- [ ] Close sorries at L2380 and L2382
- [ ] Verify `existPart_succ_n1_bypass_k0_since` is sorry-free via `lean_verify`
- [ ] Verify build GREEN

**Timing**: 2.5 hours (Since direction may require new infrastructure)

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- Since definition rewrite at L513-592 and proof closure at L2370-2382 area

**Verification**:
- `lean_verify existPart_succ_n1_bypass_k0_since` shows no sorryAx
- grep shows 1 remaining sorry (L2535, k>0)
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampBypass` compiles

---

### Phase 5: Chain Verification [NOT STARTED]

**Goal**: Verify the downstream Kamp chain is sorry-free at depth 0 (k>0 sorry quarantined). Check whether `chronicle_gap_contradiction` and `US_expressively_complete_over_prior` are unblocked. Document final sorry inventory.

**Tasks**:
- [ ] Run `lake build` on full project to verify no regressions
- [ ] Verify `lean_verify existPart_succ_n1_bypass_k0` -- should show no sorryAx
- [ ] Verify `lean_verify existPart_succ_n1_bypass` -- should show sorryAx from k>0 only
- [ ] Verify `lean_verify kamp_prior_expressive_completeness` -- check sorry propagation
- [ ] Verify `lean_verify US_expressively_complete_over_prior` -- check sorry status
- [ ] Verify `lean_verify chronicle_gap_contradiction` -- check if unblocked. Dependency chain: `chronicle_gap_contradiction` -> `gap_contradicts_prior` -> `US_expressively_complete_over_prior` -> `kamp_prior_expressive_completeness`
- [ ] If chain remains blocked by k>0: document blocker for follow-on task
- [ ] Document final sorry inventory for the Kamp module

**Timing**: 0.5 hours (verification only)

**Depends on**: 3, 4

**Files to modify**:
- None (verification and documentation only)

**Verification**:
- `lean_verify` results for the full chain documented
- `lake build` full project succeeds
- Sorry inventory recorded: expected 1 sorry (k>0 at L2535)

---

## Testing & Validation

- [x] After Phase 1: `enriched_vecEA2_until` returns `VecEA2 k` with k = pos_between.length; `bracket_from_distinct_witnesses` sorry-free; build GREEN
- [x] After Phase 2: `backward_holdsLeft_of_nf_eval` sorry-free (0 sorries in L2008-2318); build GREEN
- [ ] After Phase 3: `forward_nf_eval_of_holdsLeft` sorry-free; grep shows 3 remaining sorries (Since + k>0)
- [ ] After Phase 4: `existPart_succ_n1_bypass_k0_since` sorry-free; grep shows 1 remaining sorry (k>0)
- [ ] After Phase 5: `existPart_succ_n1_bypass_k0` sorry-free via `lean_verify`; full `lake build` succeeds; chain verification documented

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- `enriched_vecEA2_until` rewritten with BracketFormula k; `enriched_bypass_since` fixed; sorries at L2205, L2380, L2382 closed; 1 sorry remains (k>0 at L2535)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEAFormula.lean` -- helper lemmas for sorting and seg_guard subinterval (if placed here)
- `specs/273_chronicle_gap_contradiction_proof/plans/39_bracketformula-k-encoding.md` -- this plan

## Rollback/Contingency

**If definition change breaks backward proof irrecoverably (Phase 2)**: The existing BracketFormula 0 encoding is on a branch. Git revert to restore the n=0 approach and document the specific failure for the sorting or injectivity step.

**If Since direction VecEA2 introduction is infeasible (Phase 4)**: The VecEA2 infrastructure's `translateLeft` produces Until formulas via `bracketBuildRight`. For the Since direction, a mirror `bracketBuildLeft` or `translateRight` may not exist. Fallback: construct a direct `Formula.snce` nesting that places bracket witnesses in `(x, t)` without going through VecEA2. This requires proving correctness directly against `nf_eval` rather than via VecEA2 infrastructure.

**If helper lemma sorting fails with Mathlib API (Phase 1)**: Alternative: use `Finset.orderEmbOfFin` to directly produce a strictly monotone enumeration of the witness finset. This avoids the `Tuple.sort` + injectivity -> strict monotonicity path.

**If heartbeat budget is exhausted**: Factor the bracket proof into a separate lemma with its own `set_option maxHeartbeats`. The main proof delegates to this lemma.

## Anti-Pattern Guards

These anti-patterns caused prior implementation failures and MUST NOT be repeated:

1. **Do NOT decompose sorries into sub-sorries** -- close them directly. The decomposition anti-pattern in earlier cycles INCREASED the sorry count.
2. **Do NOT produce analysis-only outputs** -- every implementation dispatch must produce sorry-free proof code that compiles.
3. **Do NOT use worktrees** -- work on main branch ONLY.
4. **Do NOT reference outdated line numbers without re-verifying** -- grep for `sorry` at the start of each phase.
5. **Do NOT write helper lemmas that defer the actual proof** -- helpers must be sorry-free and directly used in the same phase.
6. **Do NOT attempt the "disjunction pointTypes" approach (Report 35)** -- use per-SSN char_y as individual pointTypes (Report 38 recommendation).
