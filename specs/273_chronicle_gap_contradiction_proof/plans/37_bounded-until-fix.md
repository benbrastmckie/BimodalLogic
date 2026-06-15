# Implementation Plan: Bounded-Until Architectural Fix for KampBypass

- **Task**: 273 - chronicle_gap_contradiction_proof
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: None (Phase 1 already completed; all mathematical infrastructure sorry-free)
- **Research Inputs**: specs/273_chronicle_gap_contradiction_proof/reports/36_literature-bracket-proof.md, specs/273_chronicle_gap_contradiction_proof/reports/35_team-research.md
- **Artifacts**: plans/37_bounded-until-fix.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Replace the broken `BracketFormula`/`IntervalPattern` machinery in `enriched_vecEA2_until` with per-SSN bounded Until formulas, following the paper's approach (Rabinovich 2014, Proposition 3.5 / Corollary 5.4). The current architecture extracts independent witnesses from `h_eval_quant` and tries to place them into a flat `IntervalPattern.holds` requiring strictly increasing witnesses -- a design flaw that makes the backward direction unprovable when `pos_between.length >= 2`. The fix replaces the multi-witness bracket with a conjunction of individually-bounded Untils (`seg_guard Until (char_y(ssn_i) AND (seg_guard Until char_1(nf_x)))`), each constraining one witness to `(t, x)` independently. The Since case (`enriched_bypass_since`) receives a parallel fix, replacing unbounded `Formula.untl char_y Formula.top` with properly bounded Since formulas. Definition of done: all 4 depth-0 sorries in KampBypass.lean closed; `existPart_succ_n1_bypass_k0` sorry-free by `lean_verify`.

### Research Integration

Report 36 (literature analysis) established the definitive fix: the paper NEVER faces the ordering problem because Proposition 3.5 constructs witnesses one-at-a-time via nested Until formulas. The correct Lean encoding is Approach C -- per-SSN bounded Until formulas that independently constrain each witness to `(t, x)`. No BracketFormula, no IntervalPattern, no ordering between witnesses needed.

Report 35 (team research) confirmed: (1) conjunction-of-existentials with `Formula.untl char_y Formula.top` is UNSOUND because it loses the `y < x` bound. (2) `enriched_bypass_since` has the same unbounded problem for positive between_xt SSNs. (3) The Since case is independent of the bracket flaw but needs its own VecEA2-level fix. (4) The k>0 sorry at L2396 is a scoping issue requiring a separate IH argument.

### Prior Plan Reference

Plan v34 (5 phases, 6 hours) attempted direct sorry closure with the existing BracketFormula architecture. Key lessons learned: (1) Phase 1 (eq case) was completed successfully -- the `unfold atom_eval + exact h` technique and zone bridge dispatch pattern are validated and reusable. (2) Phases 2-3 were BLOCKED by the BracketFormula ordering flaw -- this is a definitional problem, not a proof difficulty, confirming that the architecture must change. (3) The Since case soundness concern was identified but not investigated. (4) Effort estimates for Phase 1 (1.5h actual) calibrate subsequent estimates. (5) Anti-pattern guards from v34 remain critical: no sub-sorry decomposition, no analysis-only outputs, no stale worktrees.

### Roadmap Alignment

- Advances: Kamp chain closure (`kamp_prior_expressive_completeness` -> `US_expressively_complete_over_prior`) -- one of two independent sorry chains blocking `completeness_discrete`
- The Stavi chain through `stavi_expressive_completeness` feeds into `US_expressively_complete_over_prior` via the generalized existential transfer
- The other chain (succ_cofinal via Reynolds k-equivalence bypass, task 202) is independent
- `chronicle_gap_contradiction` depends on `US_expressively_complete_over_prior` being sorry-free

## Goals & Non-Goals

**Goals**:
- Replace `enriched_vecEA2_until` with conjunction-of-bounded-Untils (no BracketFormula/IntervalPattern)
- Close the backward sorry at L2081 via the new per-SSN Until proofs
- Close the forward sorry at L2151 via individual Until unwinding
- Fix `enriched_bypass_since` to use properly bounded Since formulas
- Close the Since sorry at L2308
- Make `existPart_succ_n1_bypass_k0` sorry-free (verified via `lean_verify`)
- Verify downstream chain status (`kamp_prior_expressive_completeness`, `US_expressively_complete_over_prior`)

**Non-Goals**:
- Closing the k>0 sorry at L2396 -- requires separate depth-IH argument, out of scope
- Closing `nf_2var_exist_formula_prior` (NfCharFormula.lean:610) -- bypassed by the Kamp pipeline
- File splitting of KampBypass.lean -- defer to post-closure cleanup
- Proving succ_cofinal (task 202, Reynolds bypass)
- Modifying ExistsForallNF.lean BracketFormula/IntervalPattern definitions (unused after this fix, but not deleted)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Formula.untl semantics mismatch: `untl event guard` vs `guard Until event` confusion | H | M | Verify at Phase 2 start: check `temporal_truth` unfolding for `Formula.untl` to confirm which argument is event vs guard. The Lean definition (Truth.lean:128) uses `untl phi psi` = `exists s, t < s AND psi@s AND forall r in (t,s), phi@r`, so `phi` = guard, `psi` = event. |
| seg_guard proof for intermediate segments: showing seg_guard holds on (t, y_i) and (y_i, x) from nf_eval | M | M | The negative SSN conditions in nf_eval ensure that for all z in (t, x), negative SSN char_y formulas are false. This covers (t, y_i) and (y_i, x) as subintervals. Factor the segment guard lemma as a reusable helper. |
| Since direction symmetry breaks: the `enriched_bypass_since` structure differs significantly from Until | M | H | Phase 4 begins with structural inspection. The Since formula uses `Formula.snce` (mirror of `untl`). Zone labels swap (between_xt instead of between_tx, below_x instead of above_x, etc.). Build the Since fix as an explicit mirror rather than trying to reuse Until code. |
| Analysis-paralysis recurrence | H | M | Each phase has mandatory sorry-closing output. Use `lean_multi_attempt` to test tactics before editing. No sub-sorry decomposition allowed. |
| Heartbeat budget exhaustion in KampBypass.lean (already 800000-1600000) | M | M | Factor per-SSN bounded Until proofs into small helper lemmas outside the main proof. Use `set_option maxHeartbeats` locally if needed. |
| Line number drift during implementation | L | H | Re-verify sorry locations via `grep -n 'sorry' KampBypass.lean` at start of each phase. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 4 | 2 |
| 4 | 5 | 3, 4 |

Phases 3 and 4 can execute in parallel (Until backward/forward proof and Since fix are independent).

---

### Phase 1: Eq Case Preservation + Architecture Verification [COMPLETED]

**Goal**: Confirm Phase 1 (eq case) from plan v34 remains sorry-free. Verify the current sorry inventory and line numbers. This phase requires zero code changes -- it is a verification checkpoint.

**Tasks**:
- [x] Verify eq case is sorry-free: `lean_verify` on the eq case theorem
- [x] Confirm current sorry locations: L2081 (bracket backward), L2151 (forward), L2308 (Since), L2396 (k>0)
- [x] Verify `Formula.untl` semantics: confirm `Formula.untl phi psi` means "phi is guard, psi is event" from Truth.lean

**Timing**: 0.5 hours

**Depends on**: none

**Files to modify**:
- None (verification only)

**Verification**:
- grep confirms 4 sorry sites at expected lines
- `Formula.untl` semantics confirmed

---

### Phase 2: Replace enriched_vecEA2_until with Conjunction-of-Bounded-Untils [NOT STARTED]

**Goal**: Rewrite the `enriched_vecEA2_until` definition (L444-492) to produce a conjunction of per-SSN bounded Until formulas instead of a `BracketFormula n`/`VecEA2`. Also update `enriched_bypass_until` (L497-511) to use the new construction. This is a definitional change -- no proof work yet.

**Tasks**:
- [ ] Define `bounded_until_witness` helper: for a single positive SSN, construct `Formula.untl (char_y(ssn).and (Formula.untl char_1_nfx seg_guard_f)) seg_guard_f`. Verify the nesting matches the semantic intent: "seg_guard holds until we reach y_i where char_y(ssn_i) holds, then seg_guard holds until x where char_1(nf_x) holds."
- [ ] Rewrite `enriched_vecEA2_until` to return a conjunction of `bounded_until_witness` formulas (one per positive between_tx SSN) combined with the endpoint left/right conditions. The return type changes from `Sigma n, VecEA2 n` to just `Formula`. Alternatively, keep the Sigma type but with n=0 bracket (no witnesses) + the conjunction folded into endpointLeft.
- [ ] Update `enriched_bypass_until` to work with the new return type. If the return type changed from `VecEA2` to `Formula`, simplify the `VVecEA2.translateLeft` call.
- [ ] Update `backward_holdsLeft_of_nf_eval` signature to match new construction (L1934+)
- [ ] Update `forward_nf_eval_of_holdsLeft` signature to match new construction (L2083+)
- [ ] Update `existPart_succ_n1_bypass_k0_until` (L2156+) to use the new formulas
- [ ] Verify `lake build` compiles (with sorry placeholders at proof sites)

**Timing**: 2 hours (~120-160 lines modified/rewritten)

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- rewrite L444-511 (definitions), update L1934-2160 (proof signatures)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampBypass` compiles (with expected sorry sites)
- New `bounded_until_witness` definition type-checks
- `enriched_bypass_until` unfolds to a disjunction of per-nf_x conjunctions of per-SSN bounded Untils

---

### Phase 3: Close Backward and Forward Sorries (Until Direction) [NOT STARTED]

**Goal**: Prove both the backward direction (nf_eval -> temporal formula) and forward direction (temporal formula -> nf_eval) for the new bounded-Until construction. Closes the sorries at L2081 and L2151.

**Tasks**:
- [ ] **Backward direction** (nf_eval -> formula): For each positive between_tx SSN ssn_i, extract witness y_i from `h_eval_quant ssn_i` with `y_i in (t, x)`. Show: (a) `char_y(ssn_i)` holds at y_i (from `nf_depth0_char_formula_correct`). (b) `seg_guard` holds on `(t, y_i)` (from negative SSN conditions: for all z in (t, y_i) subset (t, x), no negative SSN is satisfied). (c) Inner Until: `seg_guard` holds on `(y_i, x)` (same argument) and `char_1(nf_x)` holds at x (from `char_1_correct`). (d) Hence the bounded Until holds at t for this SSN. Take conjunction.
- [ ] **Forward direction** (formula -> nf_eval): For each positive between_tx SSN ssn_i, unwinding the bounded Until at t gives: exists y_i > t with `char_y(ssn_i)` at y_i and `seg_guard` on `(t, y_i)`, and exists x_i > y_i with `char_1(nf_x)` at x_i and `seg_guard` on `(y_i, x_i)`. The key insight: all disjuncts share the same nf_x via the outer disjunction, so the x is the same for all SSNs. From `char_y(ssn_i)` at y_i, reconstruct `h_eval_quant ssn_i`. From `char_1(nf_x)` at x, reconstruct the nf_x part.
- [ ] Factor segment guard helper: `seg_guard_on_subinterval` -- if seg_guard holds on `(t, x)` and `(t, y) subset (t, x)`, then seg_guard holds on `(t, y)`. This is trivial by universal quantifier restriction.
- [ ] Verify both sorry sites are closed: grep for sorry in the backward/forward theorem bodies

**Timing**: 2.5 hours (~200-300 lines of proof code)

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- close sorries at L2081 and L2151

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampBypass` compiles
- grep shows 2 remaining sorries (Since L2308, k>0 L2396)
- `lean_verify` on `backward_holdsLeft_of_nf_eval` and `forward_nf_eval_of_holdsLeft` shows no sorryAx

---

### Phase 4: Fix enriched_bypass_since + Close Since Sorry [NOT STARTED]

**Goal**: Apply the same bounded-formula fix to the Since direction. The current `enriched_bypass_since` (L515-594) uses `Formula.untl char_y Formula.top` for positive between_xt SSNs, which is unbounded (Report 35 confirmed this as unsound). Replace with bounded Since formulas: `Formula.snce (char_y(ssn_i).and (Formula.snce char_1_nfx seg_guard_f)) seg_guard_f`. Close the sorry at L2308.

**Tasks**:
- [ ] **Inspect Since semantics**: Verify `Formula.snce phi psi` means `exists s < t, psi@s AND forall r in (s, t), phi@r` (phi = guard, psi = event, mirror of Until). Check zone labels for Since: between_xt means x < y < t.
- [ ] **Define bounded_since_witness**: For a single positive between_xt SSN, construct `Formula.snce (char_y(ssn_i).and (Formula.snce char_1_nfx seg_guard_f)) seg_guard_f`. This says "seg_guard holds going back from t until y_i where char_y(ssn_i) holds, then seg_guard holds going further back from y_i until x where char_1(nf_x) holds."
- [ ] **Rewrite enriched_bypass_since**: Replace the current flat encoding with a conjunction of `bounded_since_witness` formulas for positive between_xt SSNs, combined with other zone conditions. Key changes: (a) Remove `Formula.untl char_y Formula.top` for positive between_xt SSNs. (b) Replace with `bounded_since_witness`. (c) Keep pre_at_t conditions for y > t and y = t zones. (d) Keep pt_x conditions for y = x and y < x zones.
- [ ] **Prove backward direction** (nf_eval -> Since formula): For each positive between_xt SSN, extract witness y_i from `h_eval_quant ssn_i` with `x < y_i < t`. Show bounded Since holds at t.
- [ ] **Prove forward direction** (Since formula -> nf_eval): Unwinding bounded Since gives witness y_i in (x, t) with `char_y(ssn_i)`. Reconstruct `h_eval_quant`.
- [ ] Close the sorry at L2308

**Timing**: 2 hours (~180-250 lines: ~50 definitional, ~130-200 proof)

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- rewrite L515-594 (enriched_bypass_since), close sorry at L2308

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampBypass` compiles
- grep shows 1 remaining sorry (k>0 at L2396)
- `lean_verify existPart_succ_n1_bypass_k0` shows no sorryAx

---

### Phase 5: Chain Verification and Chronicle Gap [NOT STARTED]

**Goal**: Verify the downstream Kamp chain is sorry-free at depth 0 (k>0 sorry quarantined). Check whether `chronicle_gap_contradiction` is unblocked. Document final sorry inventory.

**Tasks**:
- [ ] Verify `lean_verify existPart_succ_n1_bypass_k0` -- should show no sorryAx
- [ ] Verify `lean_verify existPart_succ_n1_bypass` -- should show sorryAx from k>0 only
- [ ] Verify `lean_verify kamp_prior_expressive_completeness` -- check if k>0 sorry propagates through or is quarantined by the classical existence path
- [ ] Verify `lean_verify US_expressively_complete_over_prior` -- check sorry status
- [ ] Verify `lean_verify chronicle_gap_contradiction` -- check if unblocked. The dependency chain: `chronicle_gap_contradiction` -> `gap_contradicts_prior` -> `US_expressively_complete_over_prior` -> `kamp_prior_expressive_completeness`
- [ ] If chain remains blocked by k>0: investigate whether `nf_characterizable_temporal_prior_classical` bootstraps from depth 1 without needing depth >= 2 bypass. Document findings.
- [ ] Run `lake build` on full project to verify no regressions
- [ ] Document final sorry inventory for the Kamp module

**Timing**: 1 hour (verification + documentation)

**Depends on**: 3, 4

**Files to modify**:
- Potentially `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- fill `chronicle_gap_contradiction` if unblocked and sorry count is small
- No other files modified in this phase

**Verification**:
- `lean_verify` results for the full chain documented
- `lake build` full project succeeds
- Sorry inventory recorded
- `existPart_succ_n1_bypass_k0` is sorry-free

---

## Testing & Validation

- [ ] After Phase 1: grep confirms 4 sorry sites at expected locations
- [ ] After Phase 2: `lake build` compiles with same 4 sorry sites (architecture change, not proof change)
- [ ] After Phase 3: grep shows 2 remaining sorries (Since + k>0)
- [ ] After Phase 4: grep shows 1 remaining sorry (k>0 at ~L2396)
- [ ] After Phase 4: `lean_verify existPart_succ_n1_bypass_k0` shows no sorryAx
- [ ] After Phase 5: `lean_verify` chain results documented; `lake build` full project succeeds

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- 3 depth-0 sorries closed, `enriched_vecEA2_until` and `enriched_bypass_since` rewritten (~300-500 lines changed)
- `specs/273_chronicle_gap_contradiction_proof/plans/37_bounded-until-fix.md` -- this plan
- Potentially `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- `chronicle_gap_contradiction` filled if unblocked

## Rollback/Contingency

**If bounded-Until semantics mismatch (Phase 2)**: The `Formula.untl phi psi` semantics are pinned by Truth.lean:128. If the nested Until does not express the intended "seg_guard until (char_y AND (seg_guard until char_1))", reverse the argument order. The semantic content is correct -- only the Lean encoding order may need adjustment.

**If seg_guard subinterval proof is harder than expected (Phase 3)**: The seg_guard is a conjunction of negated char_y formulas. Showing it holds on a subinterval of `(t, x)` reduces to showing each conjunct holds on the subinterval, which follows from universal quantifier restriction. If the negation structure complicates things, factor into a dedicated helper with a clean statement.

**If enriched_bypass_since structure diverges too far (Phase 4)**: The Since encoding in L515-594 is substantially different from the Until encoding -- it does not use VecEA2 at all, just a flat `formula_disjList`. The fix may be simpler than Until (no BracketFormula to remove, just replace unbounded `Formula.untl char_y Formula.top` with bounded Since). If the structure is incompatible, rewrite enriched_bypass_since from scratch using the same conjunction-of-bounded-Sinces pattern.

**If k>0 blocks the chain (Phase 5)**: The 3 depth-0 closures are the primary deliverable. If the classical existence path does not bypass k>0, document the blocker. The k>0 sorry requires a separate inductive argument and could be a follow-on task.

**If the approach fails entirely**: Each phase is independently valuable. Phase 2 (architecture change) makes the code correct even with sorry placeholders. Phases 3 and 4 close individual sorry sites. All existing sorry-free code (eq case, 5/6 forward zones) remains valid.

## Anti-Pattern Guards

These anti-patterns caused 3 prior implementation failures and MUST NOT be repeated:

1. **Do NOT decompose sorries into sub-sorries** -- close them directly. The decomposition anti-pattern in earlier cycles INCREASED the sorry count.
2. **Do NOT produce analysis-only outputs** -- every implementation dispatch must produce sorry-free proof code that compiles.
3. **Do NOT use worktrees** -- work on main branch ONLY.
4. **Do NOT reference outdated line numbers without re-verifying** -- grep for `sorry` at the start of each phase.
5. **Do NOT write helper lemmas that defer the actual proof** -- helpers must be sorry-free and directly used in the same phase.
6. **Do NOT attempt the "disjunction pointTypes" approach (Report 35)** -- it has an unresolved nf_y_proj injectivity gap in the forward direction. Use per-SSN bounded Untils (Approach C from Report 36) exclusively.
