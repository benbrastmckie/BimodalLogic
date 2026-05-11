# Implementation Plan: Prove limitDomSubtype_Icc_finite

- **Task**: 121 - prove_limit_dom_interval_finite
- **Status**: [NOT STARTED]
- **Effort**: 15-25 hours
- **Dependencies**: None (this is the blocking sorry for discrete completeness)
- **Research Inputs**:
  - specs/121_prove_limit_dom_interval_finite/reports/01_team-research.md
  - specs/121_prove_limit_dom_interval_finite/reports/02_team-research.md
- **Artifacts**: plans/02_interval-finiteness.md (this file)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/lean4.md
  - .claude/rules/plan-compliance.md
- **Type**: lean4

## Overview

Prove `limitDomSubtype_Icc_finite` at `ChronicleToCountermodel.lean:1064`: for `a <= b` in `LimitDomSubtype`, the set `{x | a <= x /\ x <= b}` is `Set.Finite`. This is the single blocking sorry for the discrete branch of BX completeness. Research (two rounds, 8 teammates total) established that: (1) Reynolds 1994's bypass is architecturally incompatible; (2) abstract order theory alone is insufficient (ω+ω\* counterexample); (3) the proof MUST use construction-specific properties of the omega chain, specifically the C5 permanent-closure property for U(⊤,⊥). Definition of done: the sorry at line 1064 is replaced by a complete proof that type-checks with `lake build`.

### Research Integration

- Round 1 (01_team-research.md): Established Icc_finite cannot be bypassed architecturally; identified convergence, stage-counting, and omega-chain approaches.
- Round 2 (02_team-research.md): Reynolds 1994 analysis confirmed bypass is not viable; identified that abstract order theory is insufficient; C5 permanent-closure is the key construction-specific property.

## Goals & Non-Goals

**Goals:**
- Replace the sorry at `ChronicleToCountermodel.lean:1064` with a complete, type-checked proof
- Add any necessary helper lemmas in the same file or nearby
- Ensure `limitDomSubtype_isSuccArchimedean` (line 1074) continues to type-check
- Ensure full `lake build` passes

**Non-Goals:**
- Proving the non-dense sorry at line 836 (`dd_countermodel_chronicle_nondense_sorry`) — separate task (122)
- Refactoring existing SuccOrder/PredOrder infrastructure
- Adding new Mathlib imports beyond what is strictly necessary

## Risks & Mitigations

- **Risk: Abstract order theory is insufficient.** A subset of ℚ isomorphic to ω+ω\* satisfies SuccOrder, PredOrder, NoMax, NoMin but has infinite bounded intervals. Mitigation: The proof must use construction-specific properties — C5 permanent closure, counterexample enumeration, `dom_new_unique`.

- **Risk: The convergence approach (real analysis) has a gap when L ∉ limit_dom.** Two infinite chains converging to the same non-limit_dom point is consistent with all abstract properties. Mitigation: Phase 2 attempts the convergence approach but the plan includes Fallback A (stage stabilization) if the gap cannot be closed.

- **Risk: Stage stabilization is hard to formalize directly.** Showing that insertions eventually stop in [a,b] requires tracking which counterexamples affect the interval. Mitigation: Phase 3 uses the C5 permanent-closure lemma (once U(⊤,⊥) witness is placed, no future stage inserts between x and witness) to bound the number of open gaps.

- **Risk: Build time increase from new Mathlib imports.** Mitigation: Check transitive imports before adding new ones; prefer minimal imports.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Succ/Pred Chain Helper Lemmas [NOT STARTED]

**Goal:** Establish key properties of succ/pred iteration chains needed for the main proof.

**Tasks:**
- [ ] Use `lean_goal` at line 1064 to inspect the exact proof state
- [ ] Use `lean_multi_attempt` to test whether simple approaches (simp, omega, direct Mathlib lemmas) make progress
- [ ] Search Mathlib for existing results about finiteness of bounded sets in discrete orders (`lean_leansearch`, `lean_loogle`)
- [ ] Prove `succ_chain_strictly_increasing`: `Order.succ^[n] a < Order.succ^[n+1] a` when `Order.succ^[n] a < b` (from `Order.lt_succ` given `NoMaxOrder`)
- [ ] Prove `succ_chain_bounded`: if `Order.succ^[n] a < b` for all n, then the chain stays in `[a, b]`
- [ ] Prove `pred_chain_strictly_decreasing`: `Order.pred^[j+1] b < Order.pred^[j] b` when `Order.pred^[j] b > a`
- [ ] Prove `chains_meeting_reaches_b`: if `Order.succ^[n+1] a = Order.pred^[j] b` for some n, j, then `Order.succ^[n+j+1] a = b` (by induction using `Order.succ_pred`)
- [ ] Verify `Order.pred_succ` and `Order.succ_pred` hold for `LimitDomSubtype` (from Mathlib given `NoMaxOrder`/`NoMinOrder`)

**Timing:** 4-6 hours

**Depends on:** none

### Phase 2: Convergence Infrastructure and Real Embedding [NOT STARTED]

**Goal:** Attempt the convergence-based proof using real number embedding. If this approach fails to close the gap, document findings and proceed to Phase 3 with the stage-stabilization fallback.

**Tasks:**
- [ ] Identify minimal Mathlib import for monotone bounded convergence of ℚ-sequences in ℝ (try `lean_leansearch "monotone bounded sequence converges"`)
- [ ] Prove `succ_chain_val_converges`: when `Order.succ^[n] a < b` for all n, the sequence `n ↦ ((Order.succ^[n] a).val : ℝ)` converges to some `L ≤ b.val`
- [ ] Prove `pred_chain_val_converges`: the pred chain converges to some `L' ≥ a.val`
- [ ] Prove `limits_equal`: `L = L'` when both chains exist and are separated
- [ ] Prove `limit_not_in_limit_dom`: if `L = L'` and L is rational and in limit_dom, then `pred(L)` exists, but the succ chain has elements between `pred(L)` and `L` — contradiction
- [ ] Attempt to close the gap when L ∉ limit_dom: show no limit_dom points exist between the chains, then derive that `succ` of a chain element must hit the other chain
- [ ] **Decision point**: If the L ∉ limit_dom gap cannot be closed, document findings and pivot to Phase 3's stage-stabilization approach

**Timing:** 5-8 hours

**Depends on:** 1

### Phase 3: Construction-Specific Proof (C5 Permanent Closure) [NOT STARTED]

**Goal:** If the convergence approach from Phase 2 succeeds, integrate it. If not, prove Icc_finite using the stage-stabilization approach with C5 permanent closure.

**Tasks (Stage Stabilization — primary approach):**
- [ ] Prove `c5_permanent_closure`: In the discrete case, once C5 for U(⊤,⊥) at x fires with witness y at stage n, no domain point is inserted between x.val and y.val at any stage m > n. The argument: any new point w between x and y would need `⊥ ∈ f(w)`, but ⊥ is never in any MCS.
- [ ] Prove `limit_adj_stable`: For x, y ∈ limit_dom with `succ_limit(x) = y`, there exists stage N such that for all n ≥ N, `dom(n) ∩ (x.val, y.val) = ∅`. This follows from `c5_permanent_closure`.
- [ ] Prove `interval_stabilizes`: For a, b ∈ limit_dom with a ≤ b, there exists N such that `limit_dom ∩ [a.val, b.val] = dom(N) ∩ [a.val, b.val]`. Strategy: by well-founded induction, show that each adjacent pair in [a,b] eventually stabilizes, and there are finitely many such pairs at any stage.
- [ ] Conclude `limitDomSubtype_Icc_finite`: since `limit_dom ∩ [a.val, b.val] ⊆ dom(N)` and `dom(N) : Finset Rat`, the set is finite.

**Tasks (Alternative — direct counting):**
- [ ] If `interval_stabilizes` is too hard: prove that `first_stage : limit_dom → Nat` (mapping x to min n with x ∈ dom(n)) restricted to [a.val, b.val] has finite image, using the bound on counterexample insertions per interval.

**Timing:** 5-8 hours

**Depends on:** 2

### Phase 4: Assembly and Validation [NOT STARTED]

**Goal:** Replace the sorry, validate the build, ensure downstream lemmas type-check.

**Tasks:**
- [ ] Replace `sorry` at line 1064 with the complete proof
- [ ] Run `lake build Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel`
- [ ] Verify `limitDomSubtype_isSuccArchimedean` (line 1074) still type-checks
- [ ] Verify `discrete_iso` (line 1124) and downstream definitions still type-check
- [ ] Run full `lake build` to check for regressions
- [ ] Clean up auxiliary lemmas (mark `private` if only used locally)

**Timing:** 2-3 hours

**Depends on:** 3

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel` succeeds with no errors
- [ ] `lean_goal` at line 1064 shows "no goals" (proof complete)
- [ ] `lean_verify` on `limitDomSubtype_Icc_finite` confirms no axiom issues
- [ ] `lean_verify` on `limitDomSubtype_isSuccArchimedean` confirms the sorry is fully resolved
- [ ] Full `lake build` passes with no regressions

## Artifacts & Outputs

- **Plan**: `specs/121_prove_limit_dom_interval_finite/plans/02_interval-finiteness.md` (this file)
- **Modified file**: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (sorry replaced)
- **Summary**: `specs/121_prove_limit_dom_interval_finite/summaries/02_interval-finiteness-summary.md`

## Rollback/Contingency

If the convergence approach (Phase 2) proves intractable:

1. **Fallback A: Stage stabilization** (Phase 3 primary). Show `limit_dom ∩ [a.val, b.val]` equals `dom(N) ∩ [a.val, b.val]` for finite N, using C5 permanent closure and counterexample enumeration surjectivity.

2. **Fallback B: Well-founded induction on unresolved gaps.** Define a measure on "open gaps" in `dom(N) ∩ [a.val, b.val]` and show it decreases. Each C5 processing permanently closes one gap.

3. **Fallback C: Direct IsSuccArchimedean.** Bypass Icc_finite entirely — prove `IsSuccArchimedean` directly from construction properties by tracking C5 counterexamples for U(⊤,⊥).

To rollback: `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`

## Implementer Guidance

**The proof is genuinely difficult.** Abstract order theory does NOT suffice — a subset of ℚ isomorphic to ω+ω\* satisfies all the same abstract properties but has infinite bounded intervals. The proof MUST use construction-specific properties.

**Recommended first step**: Before writing any proof code, use `lean_goal` at line 1064 to inspect the proof state, then search Mathlib for existing results about finiteness of bounded sets in discrete orders. Try `lean_leansearch "bounded interval finite discrete"` and `lean_loogle "SuccOrder → Set.Finite"`.

**Critical files:**
- `ChronicleToCountermodel.lean` — sorry location, succ/pred infrastructure
- `ChronicleConstruction.lean` — omega chain, limit_dom definition, counterexample processing
- `CounterexampleElimination.lean` — dom_new_unique, counterexample elimination mechanics
- `ChronicleTypes.lean` — Chronicle structure, dom : Finset Rat, Adjacent
