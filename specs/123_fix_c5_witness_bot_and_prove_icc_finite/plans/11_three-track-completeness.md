# Implementation Plan: Z1 Gap Elimination for Discrete Completeness (v16)

- **Task**: 123 - fix_c5_witness_bot_and_prove_icc_finite
- **Status**: [IN PROGRESS]
- **Effort**: 6-10 hours (Phases 1-2 completed; Phases 3-5 estimated 5-8 hours)
- **Dependencies**: None (Z1 axiom and soundness already completed)
- **Research Inputs**:
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/11_team-research.md (primary)
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/09_prior-uz-issucc-analysis.md
  - All prior reports from rounds 04-14 (integrated in plans v4-v15)
- **Artifacts**: plans/11_three-track-completeness.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/lean4.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close the remaining `sorry` in `succ_cofinal` (ChronicleToCountermodel.lean:1869) by handling two distinct cases: (1) Z1 Doets maximum principle for the non-constant-MCS case, and (2) a construction-level impossibility argument for the constant-MCS case. Phases 1-2 (imports, Z1 axiom + soundness) are already completed. This plan redesigns the gap elimination work into two focused phases for the two cases, followed by verification and cleanup.

### Research Integration

**Reports integrated in this plan version (v16):**
- `11_team-research.md` (newly integrated -- four-teammate synthesis on gap elimination strategy)
- `09_prior-uz-issucc-analysis.md` (integrated in v15 -- Prior-UZ requires IsSuccArchimedean, Z1 not derivable)
- All reports from v4-v14 preserved

**Key findings from team research:**
- Constant-MCS gap is genuine -- confirmed against Axioms.lean:377-378 (Burgess `untl(event, guard)` convention)
- Prior-UZ does NOT contradict constant-MCS (Teammate D's claim was wrong -- Until argument order reversed)
- Non-constant-MCS case tractable with Z1 Doets (~80 lines, 65% confidence)
- Constant-MCS case requires construction-level argument (~60 lines, 50% confidence)
- Doets Henkin approach avoids both cases entirely but is 1400-2500 lines (future task)
- Discrete completeness without IsSuccArchimedean: ruled out
- Stage induction: dead end for this problem

### Prior Plan Reference

Plan v15 (12_semantic-z1-gap.md) established the correct approach: Z1 as axiom (not derived), soundness on IsSuccArchimedean frames, Doets maximum principle for gap elimination. Phases 1-2 were completed successfully. Phase 3 was marked BLOCKED because it combined both the non-constant and constant MCS cases into a single phase without sufficient clarity on the two distinct proof strategies. This plan splits Phase 3 into two focused phases (3 and 4) with separate strategies for each case, informed by the team research findings.

**Effort calibration from v15**: Phases 1-2 completed in approximately 4 hours total, consistent with the 3-4 hour estimate. The gap elimination work (old Phase 3) was estimated at 2-4 hours but proved more complex, motivating the split.

### Roadmap Alignment

This plan advances the following ROADMAP.md items:
- Close `succ_cofinal` sorry -- sorry-free discrete pipeline
- Unblocks: `limitDomSubtype_isSuccArchimedean`, `succ_embed_surjective`, `dd_countermodel_chronicle_discrete`
- Prerequisite for task 122 (nondense BFMCS) and full `bx_completeness`

## Goals & Non-Goals

**Goals:**
- Close the sorry in `succ_cofinal` (ChronicleToCountermodel.lean:1869)
- Handle non-constant-MCS case via Z1 Doets maximum principle argument
- Handle constant-MCS case via construction-level impossibility argument
- Make `limitDomSubtype_isSuccArchimedean` sorry-free
- Make `dd_countermodel_chronicle_discrete` sorry-free
- Full `lake build` passes with no regressions
- Scope the Doets Henkin approach as a follow-up task

**Non-Goals:**
- Splitting DiscreteTemporalFrame into discrete + integer hierarchy (task 126)
- Deriving Z1 syntactically (confirmed impossible -- Z1 is not a theorem)
- Fixing stage-induction boundary cases (confirmed blocked, dead end)
- Fixing nondense/mixed sorry stubs (task 122)
- Reynolds contemporaneous equivalence approach (unnecessary if Z1 works)
- Implementing the full Doets Henkin module (separate task, 3-6 weeks)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Non-constant MCS: discriminating formula extraction fails to find a formula with the right orbit properties | H | M | Use `Classical.choice` on MCS symmetric difference. If orbit points don't all share the formula, refine using `negation_complete` to get a formula holding at all orbit points from some index onward. Finiteness of sub-formula closure guarantees eventual stabilization. |
| Constant-MCS: construction-level argument is harder than expected | H | M | Fallback 1: attempt direct Z-construction bypassing limit domain (500-800 lines, 55% confidence). Fallback 2: leave sorry with Z1 infrastructure in place and create task for Doets Henkin approach. |
| Z1 modus tollens step requires formulas not in sub-formula closure | M | L | The Z1 argument operates on formulas already in the MCS, which is closed under sub-formulas. The `implication_property` and `negation_complete` APIs handle modus ponens and case splits within MCS. |
| `backward_G` needs formula truth at ALL points above x (including beyond the gap) | M | M | This is the core difficulty noted at line 1865-1868. For the non-constant case: the discriminating formula phi satisfies `phi at all orbit points` and `G(neg phi)` at some pred-chain point. `backward_G` from an orbit point only needs phi at all later limit_dom points -- orbit points have phi by choice, and `limit_forward_G` from the pred-chain point propagates G(neg phi) downward. The interplay between these two is what Z1 resolves. |
| Both gap cases fail, blocking task 123 entirely | H | L | Create task for Doets Henkin canonical model (Track 3). This is the "right" long-term approach and avoids both gap cases entirely. Task 123 remains partial with Z1 infrastructure as a contribution. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 3, 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Imports and Order.succ Equality [COMPLETED]

**Goal**: Add Mathlib imports and prove `Order.succ` equals `limitDomSubtype_succ`.

**Tasks**:
- [x] Add Mathlib imports (lines 11-12)
- [x] Prove `order_succ_eq` (line 1006, `rfl`)
- [x] Prove `order_pred_eq` (line 1017, `rfl`)

**Timing**: Completed
**Depends on**: none
**Completed**: 2026-05-11

---

### Phase 2: Z1 Axiom, Soundness, and Pattern Match Updates [COMPLETED]

**Goal**: Add Z1 as a new axiom constructor and prove it sound on IsSuccArchimedean frames. Update all axiom pattern matches.

**Tasks**:
- [x] Add `z1` constructor to `Axiom` inductive (Axioms.lean:397)
- [x] Update axiom classification predicates (`isDenseCompatible`, `isDiscreteCompatible`, `isBase`, `frameClass`)
- [x] Prove `z1_is_valid` (backward induction with `exists_succ_iterate`)
- [x] Prove `z1_past_is_valid` (temporal dual)
- [x] Update all 11 pattern matches in SoundnessLemmas.lean and Soundness.lean
- [x] Replace `z1_derivation` sorry with axiom-based derivation
- [x] `lake build` passes

**Timing**: Completed
**Depends on**: Phase 1
**Completed**: 2026-05-12

---

### Phase 3: Non-Constant MCS Gap Elimination via Z1 Doets [NOT STARTED]

**Goal**: Close the sorry in `succ_cofinal` for the case where NOT all limit_dom points have identical MCS labels. This is the tractable case (~80 lines, 65% confidence).

**Strategy**: Extract a discriminating formula from the MCS symmetric difference between orbit and pred-chain points. Apply the Z1 maximum principle to derive a contradiction: the "maximum phi-point" must be an orbit point (by `orbit_below_L`), but `forward_G` gives `neg phi` at its successor, contradicting `phi` at all orbit points.

**Tasks**:
- [ ] Add a case split at the sorry site (line 1869) on whether all limit_dom MCS labels in the gap region are identical
- [ ] **Non-constant case**: Extract discriminating formula `phi` such that `phi` holds at some orbit point but fails at some pred-chain point (via `Classical.choice` on MCS symmetric difference)
- [ ] Establish `F(phi)` at an early orbit point (via `backward_F` from the orbit point where `phi` holds)
- [ ] Establish `FG(neg phi)` at the same orbit point (via `backward_F` composed with `backward_G` from the pred-chain region where `neg phi` holds at all later points)
- [ ] Apply Z1 via `z1_in_mcs`: `G(G(neg phi) -> neg phi) -> (FG(neg phi) -> G(neg phi))` gives that either `G(neg phi)` holds at the orbit point (contradicting `F(phi)`) or there exists a "maximum" point where the implication `G(neg phi) -> neg phi` fails
- [ ] The Z1 contrapositive: `not G(neg phi)` and `FG(neg phi)` at the orbit point yields `not G(G(neg phi) -> neg phi)`, i.e., `F(G(neg phi) AND phi)` -- use `limit_F_resolution` to extract a witness `k` with both `phi` and `G(neg phi)` at `k`
- [ ] Show `k` is an orbit point (by `orbit_below_L`, since `k > orbit_point` and `k.val < L`)
- [ ] `G(neg phi)` at `k` propagated via `limit_forward_G` gives `neg phi` at `succ(k)`
- [ ] `succ(k)` is also an orbit point (successor of orbit point below L is orbit)
- [ ] **Key step**: show `phi` holds at `succ(k)` -- either by choice of `phi` (all orbit points satisfy `phi`) or by refining `phi` to ensure this
- [ ] Contradiction: `phi` and `neg phi` both at `succ(k)`, violating MCS consistency

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- gap elimination logic at line 1869

**Timing**: 2-3 hours
**Depends on**: Phase 2

**Verification**:
- The non-constant case branch of the sorry is closed
- `lean_goal` at the remaining sorry shows only the constant-MCS case

**Implementation guidance**:

The critical subtlety is in the "key step": showing `phi` holds at `succ(k)`. The discriminating formula `phi` is chosen from the symmetric difference of two MCS labels, meaning `phi in limit_f(orbit_point)` but `phi notin limit_f(pred_chain_point)` (or vice versa). This does NOT automatically mean `phi` holds at ALL orbit points.

Two approaches to resolve this:
1. **Refine phi**: Instead of arbitrary symmetric difference, find phi such that phi holds at ALL orbit points (or all sufficiently late ones). The MCS labels on orbit points form a sequence in a finite set (sub-formula closure of A), so they must eventually stabilize. After stabilization, ALL orbit formulas are shared, and any formula in the symmetric difference with a pred-chain point holds at all late orbit points.
2. **Use the maximum directly**: The witness `k` from `limit_F_resolution` satisfies `phi AND G(neg phi)` at `k`. Since `G(neg phi)` at `k` gives `neg phi` at ALL later points, and `k` is an orbit point, `neg phi` holds at `succ(k)`. But `succ(k)` being an orbit point with `neg phi` means `phi` is NOT universally true at orbit points -- the argument must use the specific position of `k` relative to the stabilization threshold.

The recommended path: prove orbit MCS labels stabilize (by Bolzano-Weierstrass on the finite set of possible MCS labels), then pick `phi` from the symmetric difference between the stabilized orbit MCS and a pred-chain MCS. After stabilization, `phi` holds at all late orbit points, and `succ(k)` (being a late orbit point) has `phi`, giving the contradiction.

---

### Phase 4: Constant-MCS Gap Impossibility [NOT STARTED]

**Goal**: Close the sorry in `succ_cofinal` for the case where all limit_dom points in the gap region have identical MCS labels. This requires showing the omega-chain construction cannot produce this configuration (~60 lines, 50% confidence).

**Strategy**: Show that the constant-MCS scenario is impossible by analyzing the counterexample enumeration process. The omega-chain enumerates ALL (point, formula) pairs as potential counterexamples. When a counterexample at a gap-region point is resolved, the elimination process introduces a witness with a specific MCS label determined by `BurgessR3Maximal`. If all existing points have MCS label A, the witness placement for certain counterexample types (specifically C5-type involving Until) must introduce a point with a DIFFERENT MCS label, contradicting the constant-MCS assumption.

**Tasks**:
- [ ] Analyze the `eliminate_potential_counterexample` function for the C5 (Until) case to understand what MCS labels witnesses receive
- [ ] Show that when the guard formula of an Until counterexample is `bot` (or more generally, when the event formula is not in A), the witness point must have a different MCS label
- [ ] Alternatively, show that the `BurgessR3Maximal` construction applied to a temporally-saturated constant set A produces g-labels that absorb all guards, forcing a specific non-A MCS at the witness
- [ ] Handle the case where A is fully temporally saturated (all G(phi) -> phi implications hold) -- show this leads to A being the MCS of a point on Z, contradicting the gap geometry
- [ ] If the construction-level argument proves intractable within 2 hours: pivot to the alternative approach below
- [ ] Close the constant-MCS case in `succ_cofinal`

**Alternative approach (if construction-level argument fails)**:
- [ ] Prove that constant-MCS with the gap geometry directly contradicts `NoMinOrder` on the limit domain -- the pred-chain {pred^k(pb)} is an infinite strictly decreasing sequence with values >= L, but all limit_dom points below L are orbit points (by `orbit_below_L`), creating an accumulation point that must be in limit_dom but cannot be (it would be between orbit and pred-chain)
- [ ] Or: show that `backward_G` at any orbit point gives `G(phi)` for ALL `phi in A` (since all points above have MCS = A, so `phi` holds everywhere above). Then `G(phi) in A` for all `phi in A`. Since `G(phi) -> phi` is derivable when `phi in A` and `G(phi) in A`, and Z1 gives `FG(phi) -> G(phi)`, the set A is "temporally complete" in a way that forces the limit domain to be isomorphic to Z -- contradicting the gap

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- constant-MCS case at line 1869
- Possibly `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- if construction analysis is needed

**Timing**: 2-4 hours
**Depends on**: Phase 3 (the case split structure must be in place)

**Verification**:
- The sorry at line 1869 is fully closed
- `lean_goal` at `succ_cofinal` shows no remaining goals
- `limitDomSubtype_isSuccArchimedean` is sorry-free

---

### Phase 5: Verification and Cleanup [NOT STARTED]

**Goal**: Verify full compilation, sorry elimination, and clean up dead code and obsolete comments.

**Tasks**:
- [ ] `lake build` passes (full project, no regressions)
- [ ] `lean_verify` on `succ_cofinal` -- no sorry
- [ ] `lean_verify` on `limitDomSubtype_isSuccArchimedean` -- no sorry
- [ ] `lean_verify` on `succ_embed_surjective` -- no sorry
- [ ] `lean_verify` on `dd_countermodel_chronicle_discrete` -- no sorry
- [ ] Grep for `sorry` confirms only nondense/mixed stubs remain (line 831, 836 etc.)
- [ ] Remove dead code: old stage-induction attempts, convergence analysis comments
- [ ] Clean up gap analysis comments at lines 1779-1868 (replace with concise documentation of the Z1 argument)
- [ ] Remove obsolete `z1_derivation` and `z1_formula` if superseded by direct axiom usage
- [ ] Update module docstring (lines 1-50) to reflect sorry-free status of discrete case

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- cleanup

**Timing**: 0.5-1 hour
**Depends on**: Phase 3, Phase 4

**Verification**:
- Clean `lake build` with no warnings
- Sorry count matches expected (nondense/mixed stubs only)

---

## Testing & Validation

- [ ] `lake build` passes (full project)
- [ ] `lean_verify` on `succ_cofinal` -- no sorry
- [ ] `lean_verify` on `limitDomSubtype_isSuccArchimedean` -- no sorry
- [ ] `lean_verify` on `succ_embed_surjective` -- no sorry
- [ ] `lean_verify` on `dd_countermodel_chronicle_discrete` -- no sorry
- [ ] Grep for sorry shows only nondense and mixed stubs
- [ ] No new axioms beyond Z1 (verify with `lean_verify --axioms`)
- [ ] No regressions in existing sorry-free theorems (soundness, FMP, dense)

## Artifacts & Outputs

- **Plan**: `specs/123_fix_c5_witness_bot_and_prove_icc_finite/plans/11_three-track-completeness.md` (this file, v16)
- **Modified files**:
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- gap elimination, sorry closure
  - Possibly `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- construction analysis for constant-MCS
- **Summary**: `specs/123_fix_c5_witness_bot_and_prove_icc_finite/summaries/11_three-track-completeness-summary.md`

## Rollback/Contingency

The Z1 axiom infrastructure (Phases 1-2) is already committed and non-destructive. Rollback of Phases 3-4 is straightforward: revert changes to `ChronicleToCountermodel.lean` at the sorry site.

**If Phase 3 (non-constant MCS) fails:**
- The orbit MCS stabilization argument is mathematically sound but may be complex to formalize. Fallback: leave non-constant case sorry'd, document the proof sketch, proceed to Phase 4.

**If Phase 4 (constant MCS) fails:**
- Primary fallback: attempt direct Z-construction bypassing limit domain (500-800 lines, 55% confidence, would be a new phase).
- Secondary fallback: leave sorry with Z1 infrastructure in place and create a follow-up task (task 127 or similar) for the Doets Henkin canonical model approach. The Doets Henkin construction (1400-2500 lines, 3-6 weeks, based on Doets 1987 and Reynolds 1994) avoids both gap cases entirely by building a model where each point IS a distinct MCS, living in `Metalogic/DoetsCanonical/`.
- The Z1 axiom + soundness infrastructure is independently useful regardless of gap elimination outcome.

**If both Phase 3 and Phase 4 fail:**
- Task 123 closes as PARTIAL with Phases 1-2 as contributions.
- Create follow-up task for the Doets Henkin canonical model approach.
- Existing `bx_completeness` remains blocked by 1 sorry until Doets or alternative approach succeeds.
