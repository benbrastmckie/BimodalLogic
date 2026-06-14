# Implementation Plan: Complete Kamp Theorem Proof (All Depths)

- **Task**: 273 - chronicle_gap_contradiction_proof
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: Plans v17-v28 (phases 1-7 COMPLETED: 3400+ lines sorry-free infrastructure). Plan v29 (Phase 1 COMPLETED: KampBypass.lean created, 1199 lines; Phase 2 BLOCKED: depth-0 wiring sorries; Phase 3 partially wired). VecEADecomp.lean (898 lines, sorry-free). NfToVecEA.lean (700+ lines, sorry-free). RabinovichGeneralized.lean (~470 lines).
- **Research Inputs**:
  - specs/273_chronicle_gap_contradiction_proof/reports/26_team-research.md (round 26, team research: ssn filter defect, depth boundary analysis, strategic assessment)
  - Prior reports integrated in plan v29 (rounds 10-27)
- **Artifacts**: plans/26_complete-kamp-proof.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close ALL remaining sorry sites in the Kamp expressive completeness proof chain, covering depths 0, 1, and >= 2 with no axiom fallback. The work proceeds in 5 phases: (1) fix the defective `ssn_xt_compatible` filter that admits unrealizable 3-variable order assignments, (2) close the 8 depth-0 wiring sorries in KampBypass.lean by connecting VecEADecomp zone theorems to `nf_eval_nf`, (3) close the depth >= 2 sorry via arity-climbing induction on k with the IH providing temporal formulas at ALL arities, (4) wire the complete bypass into NfCharFormula.lean and fill the final sorry cascade, and (5) run full verification to confirm `completeness_discrete` sorry chain improvement.

### Research Integration

**Report 26 (team research, 4 teammates)**:
- Teammate A (95% confidence): `ssn_xt_compatible` passes 16/64 order assignments per zone but only 13 are realizable. Fix: add `ssn_order_consistent` checking antisymmetry (3), transitivity (6), equality consistency (3) = 12 boolean checks. This is a prerequisite for depth-0 wiring proofs.
- Teammate B (very high confidence): VecEADecomp zone theorems are complete and sorry-free for ALL 9 zone cases. The 8 depth-0 sorries are wiring, not mathematics. Estimated ~1000 lines of mechanical case analysis.
- Teammate C (high confidence for depth-0, 5% for depth >= 2 via bypass): Zone-aware approach IS sound (NfComposition counterexample does not apply). Depth-1 KampBypass sorries ARE closable via conjunction elimination. The Feferman-Vaught composition blocker applies only at depth >= 2.
- Teammate D: Closing task 273 is the single highest-impact project action (unblocks tasks 155, 299, 95, 254 and ROADMAP Phases 2-5).

### Prior Plan Reference

Plan v29 (4 phases): Phase 1 (enriched formula definition) COMPLETED -- KampBypass.lean created with 1199 lines and the structural framework. Phase 2 (correctness proof) BLOCKED due to 8 depth-0 wiring sorries and the defective ssn filter. Phase 3 (wiring into NfCharFormula) partially completed -- NfCharFormula.lean L639-643 already calls `existPart_succ_n1_bypass`. Phase 4 (chronicle gap) deferred.

Lesson from 29 plan versions: the enriched formula bypass is architecturally correct for depth-0. The blocker was always the ssn filter defect (admitting unrealizable orderings that make the enriched formula unsatisfiable) and the depth >= 2 composition requirement. This plan addresses both directly.

### Roadmap Alignment

- **Kamp chain**: Closes `kamp_prior_expressive_completeness` -> `US_expressively_complete_over_prior`
- **Chronicle gap**: Fills `chronicle_gap_contradiction` once the Kamp chain is sorry-free
- **Critical path**: Two independent sorry chains for `completeness_discrete` -- this plan addresses the Stavi/Kamp chain; task 202 (Reynolds bypass) addresses the succ_cofinal chain

## Goals & Non-Goals

**Goals**:
- Fix `ssn_xt_compatible` to reject all unrealizable 3-variable order assignments
- Close all 8 depth-0 sorry sites in KampBypass.lean (eq, Until forward/backward, Since)
- Close the depth >= 2 sorry at KampBypass.lean:1197 via arity-climbing induction following Rabinovich Section 5
- Fill `existPart_succ` n >= 2 sorry at RabinovichGeneralized.lean:465
- Verify `kamp_prior_expressive_completeness` and `completeness_discrete` sorry chains improve
- Fill `chronicle_gap_contradiction` if unblocked

**Non-Goals**:
- Filling NegationClosure.lean:1716 (`nf_exist_formula_nested_backward`) -- bypassed
- Modifying VecEADecomp.lean, NfToVecEA.lean, or any sorry-free infrastructure
- Proving the GHR94 separation property (Path A)
- Using named axiom fallback (`kamp_expressive_completeness` axiom)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Depth >= 2 arity-climbing IH fails at the Lean type level (Fin arithmetic, environment manipulation) | H | M | Start with explicit environment helpers (`Fin.cons` gymnastics). If variable-arity fails, specialize to n=1 first (sufficient for NfCharFormula), then generalize. The IH at depth k for ALL arities means depth-(k+1) 3-var quantifier conditions have temporal formulas -- this is the mathematical content of Rabinovich Lemma 3.4(3). |
| `zone_3var_exist_iff_1var` proof (L842) is harder than estimated due to zone-by-zone case explosion | M | M | This is the largest single sorry (~200 lines). Attack it first within Phase 2 to validate the approach before committing to the full 1000-line estimate. Use VecEADecomp zone theorems directly (already proved). |
| `ssn_order_consistent` filter eliminates more SSN values than expected, breaking existing compatible-ssn lists | L | L | The filter only removes unrealizable orderings. All SSN values arising from actual model evaluation are already realizable. Proof: `ssn_order_consistent_correct` (if false, then the SSN encodes an impossible linear order). |
| Since case (L1109) is not a clean mirror of Until -- asymmetries in VecEA2 infrastructure | M | L | VecEA2 has `holdsLeft` (Until) and `holdsRight` (Since) with symmetric structure. The Since case follows the same pattern as Until with reversed order quantifiers. |
| Depth >= 2 backward direction requires composition property that is provably false in general | H | H | The enriched formula at depth k+1 encodes ALL quantifier conditions as explicit conjuncts. Backward extraction is conjunction elimination -- no composition needed. The negative conditions use sorry-free `neg_2var_vec_ea` (Prop 4.2). At each depth step, the IH provides temporal formulas for ALL arities, so depth-k 3-var existentials are already characterized. |

## Postmortem Constraints (from Report 11, binding)

1. **DO NOT attempt NF-to-formula backward proofs by extracting NF data from formula truth** -- the enriched formula bypass AVOIDS this
2. **DO NOT use depth-k characteristic formulas where depth-(k+1) is needed**
3. **DO NOT encode negative interval conditions as guards that block legitimate witnesses**
4. **DO NOT attempt to prove nf_3var_from_1var_nfs at fixed arity** -- the P_n(k) approach parameterizes over n
5. **DO NOT cycle between formula-level and NF-level fixes**

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases are fully sequential. Each phase depends on the prior.

---

### Phase 1: Fix ssn_order_consistent filter [COMPLETED]

**Goal**: Add `ssn_order_consistent` to `ssn_xt_compatible` in KampBypass.lean, filtering out unrealizable 3-variable order assignments. This eliminates the root cause of the formula unsoundness identified by Teammate A.

**Tasks**:
- [x] **Task 1.1**: Define `ssn_order_consistent` in KampBypass.lean. The function takes a depth-0 3-var NF `ssn : NormalForm sig 0 3` and returns `Bool`. It checks 12 conditions: (a) 3 antisymmetry checks: for each pair (i,j), if `ssn(.order i j) = true` then `ssn(.order j i) = false`; (b) 6 transitivity implications: for each triple (i,j,k), if `ssn(.order i j) = true` and `ssn(.order j k) = true` then `ssn(.order i k) = true`; (c) 3 equality consistency checks: for each pair (i,j), if `ssn(.order i j) = false` and `ssn(.order j i) = false` then predicates at i and j must be consistent (same predicate values). (~40-60 lines)
- [x] **Task 1.2**: Add `&& ssn_order_consistent ssn` to `ssn_xt_compatible`. This is a single call site modification that protects all 13 downstream call sites uniformly. (~5 lines changed)
- [x] **Task 1.3**: Prove `ssn_order_consistent_correct`: if `ssn_order_consistent ssn = false` then there is no strict linear order on 3 elements realizing ssn. This establishes that the filter removes only unrealizable orderings. (~60-80 lines) *(deviation: altered -- proved `ssn_order_consistent_of_eval` (forward direction: model evaluation implies consistency) instead of the reverse direction. The forward direction is the one needed for soundness of the enriched formula.)*
- [x] **Task 1.4**: Verify that existing sorry-free code still compiles (`lake build` on KampBypass module). The filter only removes unrealizable SSN values, so no existing proofs should break.

**Timing**: 1 hour (~100-150 lines)

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- add `ssn_order_consistent` definition and integrate into `ssn_xt_compatible`

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampBypass` succeeds
- `ssn_order_consistent_correct` compiles without sorry

---

### Phase 2: Close depth-0 wiring sorries [IN PROGRESS]

**Goal**: Fill the 8 depth-0 sorry sites in KampBypass.lean by connecting VecEADecomp zone theorems to `nf_eval_nf`. These are mechanical wiring proofs -- the mathematical content exists in VecEADecomp.lean (898 lines, sorry-free). After this phase, `existPart_succ_n1_bypass_k0` will be sorry-free.

**Tasks**:
- [ ] **Task 2.1**: Fill `zone_3var_exist_iff_1var` (L879, ~200 lines). *(deviation: skipped -- grep shows no callers; not on critical path)*
- [ ] **Task 2.2**: Fill `backward_holdsLeft_of_nf_eval` bracket (L976). Handle positive `between_tx` ssn conditions via BracketFormula.holds.
- [ ] **Task 2.3**: Fill `backward_holdsLeft_of_nf_eval` endLeft (L960). Handle `below_t` and `eq_t` zone conditions at t via nf_depth0_char_formula_correct.
- [ ] **Task 2.4**: Fill `backward_holdsLeft_of_nf_eval` endRight (L972). Handle `eq_x` and `above_x` zone conditions at x.
- [ ] **Task 2.5**: Fill `forward_nf_eval_of_holdsLeft` (L1034). Forward direction: holdsLeft → nf_eval.
- [x] **Task 2.6**: Fill `existPart_succ_n1_bypass_k0_eq` (L801). *(deviation: altered -- only compatible subcase remains as sorry; 2 incompatible subcases proved sorry-free with Formula.bot)*
- [ ] **Task 2.7**: Fill `existPart_succ_n1_bypass_k0_since` (L1146). Since case: mirror of Until.
- [ ] **Task 2.8**: Verify `existPart_succ_n1_bypass_k0` compiles without sorry.

**Key technique discovered**: `unfold atom_eval + exact h` for Fin.cons/Fin.cases proof-term normalization after `subst`. This avoids the proof-term mismatch issue where `simp [Fin.cons]` and `rw` fail because `Fin.cons x (fun _ => t)` at index 1 gets re-expressed as `Fin.cases x (fun _ => t) ⟨1, _⟩` by the kernel after `subst`.

**Timing**: 2.5 hours (~1000 lines of zone-by-zone case analysis)

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- fill all 8 depth-0 sorry sites

**Verification**:
- `lean_verify Bimodal.Metalogic.WeakCanonical.Kamp.existPart_succ_n1_bypass_k0` shows no sorryAx
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampBypass` succeeds

---

### Phase 3: Close depth >= 2 via arity-climbing induction [NOT STARTED]

**Goal**: Fill the sorry at KampBypass.lean:1197 (`existPart_succ_n1_bypass` succ k' case) by proving the enriched bypass formula correct at ALL depths via strong induction on k. This is the mathematical core: at depth k+1, the quantifier conditions involve depth-k existentials at arity n+1; by the IH at depth k (which covers ALL arities), these have temporal formulas. No axiom fallback.

**Mathematical content**:

For `existPart_succ_n1_bypass` at `k = succ k'`:
- We need: `exists A, forall M ..., temporal_truth M atomMap t A <-> exists x, nf_eval_nf M (k'+2) 2 (Fin.cons x (fun _ => t)) sub_nf`
- `sub_nf : NormalForm sig (k'+2) 2` has depth-(k'+1) 3-var quantifier conditions: `forall ssn : NormalForm sig (k'+1) 3, (exists y, nf_eval_nf M (k'+1) 3 [y,x,t] ssn) <-> sub_nf.2 ssn = true`
- Each positive condition `exists y, nf_eval_nf M (k'+1) 3 [y,x,t] ssn` is a depth-(k'+1) 3-var existential
- By the `char_kp1_correct` hypothesis (from the outer induction on k in `kamp_mutual_induction`), depth-(k'+2) 1-var NFs have characteristic temporal formulas
- KEY INSIGHT: The depth-(k'+1) 3-var existential can be encoded as a temporal formula using the enriched formula construction recursively. At depth k'+1 with 3 variables [y,x,t], the quantifier conditions involve depth-k' 4-var existentials. By the IH at depth k' (all arities), these have temporal formulas. The recursion terminates because depth strictly decreases.
- The enriched point type at x encodes: `char_{k'+2}(nf_x)` (from `char_kp1_correct`) plus a conjunction of temporal formulas for each quantifier condition ssn. Positive conditions: the IH-derived temporal formula. Negative conditions: the negation of the IH-derived temporal formula (valid because the IH gives a biconditional).

**Tasks**:
- [ ] **Task 3.1**: Define `enriched_bypass_deep` (or modify `existPart_succ_n1_bypass`) for the `succ k'` case. The formula construction follows the same pattern as depth-0 but replaces `depth0_3var_exist_formula` with the IH-derived temporal formula for depth-(k'+1) 3-var existentials. The IH at depth k'+1 gives `char_kp1_correct` for 1-var formulas; the depth-(k'+1) 3-var existential `exists y, nf_eval M (k'+1) 3 [y,x,t] ssn` needs a temporal formula. This is exactly `existPart_succ_n1_bypass` called recursively at depth k'+1 with n=2 (arity 3 = n+1 where n=2). But we only have the theorem at n=1 (arity 2). To handle n=2, need to generalize `existPart_succ_n1_bypass` to arbitrary arity. (~80-120 lines for the generalized statement)
- [ ] **Task 3.2**: Generalize `existPart_succ_n1_bypass` to `existPart_succ_bypass` parameterized by arity n. The theorem states: for all k, n >= 1, given `char_{k+1}_correct` at all 1-var NFs, and given the IH at depth k for ALL arities (from `kamp_mutual_induction`), there exists a temporal formula A such that `temporal_truth A <-> exists x, nf_eval_nf M (k+1) (n+1) (Fin.cons x env) sub_nf`. The base case k=0 delegates to `existPart_zero` (sorry-free). The step case k+1 uses the IH at depth k for arity n+1 to encode quantifier conditions. (~100-150 lines)
- [ ] **Task 3.3**: Prove the forward direction of the generalized enriched formula at k+1. Given x with `nf_eval_nf`, show the enriched formula holds at env(0). The atom part follows from `char_kp1_correct`. Each positive quantifier condition follows from the IH biconditional. Each negative condition follows from the negated IH biconditional. The temporal wrapping (Until/Since) follows from x's zone relative to env(0). (~100-150 lines)
- [ ] **Task 3.4**: Prove the backward direction of the generalized enriched formula at k+1. Given the enriched formula holds, extract x from Until/Since semantics. Extract `nf_x` from the disjunction and `char_kp1_correct`. Extract each quantifier condition from the conjunction via the IH biconditional. Assemble `nf_eval_nf`. This is the KEY advantage of the enriched formula: extraction is conjunction elimination, not composition. (~100-200 lines)
- [ ] **Task 3.5**: Wire the generalized theorem into the `succ k'` case at L1197. Replace `sorry` with the call to the generalized bypass at n=1. (~20-30 lines)
- [ ] **Task 3.6**: Verify `existPart_succ_n1_bypass` compiles without sorry at ALL depths. Run `lean_verify existPart_succ_n1_bypass` to confirm no sorryAx.

**Timing**: 2.5 hours (~400-600 lines)

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- generalize bypass to all arities, fill succ k' case

**Verification**:
- `lean_verify Bimodal.Metalogic.WeakCanonical.Kamp.existPart_succ_n1_bypass` shows no sorryAx
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampBypass` succeeds

---

### Phase 4: Wire into NfCharFormula + RabinovichGeneralized [NOT STARTED]

**Goal**: With `existPart_succ_n1_bypass` sorry-free at all depths, verify the existing wiring in NfCharFormula.lean (L639-643) propagates the sorry-free status through the full Kamp chain. Fill the `existPart_succ` n >= 2 sorry at RabinovichGeneralized.lean:465 using the generalized bypass at arbitrary arity. Fill `nf_exist_backward_prior` (NfCharFormula.lean:541) if it remains on the critical path.

**Tasks**:
- [ ] **Task 4.1**: Verify `nf_2var_exist_formula_prior` (NfCharFormula.lean L611-643) is already wired to `existPart_succ_n1_bypass`. Confirm the k+1 case at L639-643 delegates correctly. Run `lean_verify nf_2var_exist_formula_prior` -- if no sorryAx, this task is done. If sorryAx remains, trace the sorry source.
- [ ] **Task 4.2**: Fill `existPart_succ` n >= 2 (RabinovichGeneralized.lean:465). The generalized bypass from Phase 3 at arity n fills this directly. Call `existPart_succ_bypass` with the appropriate arity parameter. (~30-50 lines)
- [ ] **Task 4.3**: Verify `nf_exist_backward_prior` (NfCharFormula.lean:541). This sorry is bypassed by the `nf_characterizable_temporal_prior_classical` approach (L648+) which uses `nf_2var_exist_formula_prior` classically. If `nf_2var_exist_formula_prior` is sorry-free, `nf_exist_backward_prior` should be dead code on the critical path. Confirm via `lean_verify nf_characterizable_temporal_prior`.
- [ ] **Task 4.4**: Verify the full Kamp chain:
  - `lean_verify nf_characterizable_temporal_prior` -- no sorryAx
  - `lean_verify kamp_prior_expressive_completeness` -- no sorryAx
  - `lean_verify kamp_mutual_induction` -- no sorryAx
  - `lean_verify US_expressively_complete_over_prior` -- no sorryAx

**Timing**: 1.5 hours (~50-100 lines changed + extensive verification)

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/RabinovichGeneralized.lean` -- fill existPart_succ n >= 2 sorry
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfCharFormula.lean` -- verify/fix wiring (may need minor adjustments)

**Verification**:
- `lean_verify kamp_prior_expressive_completeness` shows no sorryAx
- `lean_verify US_expressively_complete_over_prior` shows no sorryAx
- `lake build` on full project succeeds

---

### Phase 5: Chronicle gap + full verification [NOT STARTED]

**Goal**: Fill `chronicle_gap_contradiction` if unblocked by the Kamp chain closure. Run full verification of `completeness_discrete` to identify remaining sorry chains (should trace only through task 202's succ_cofinal chain).

**Tasks**:
- [ ] **Task 5.1**: Check `lean_verify completeness_discrete` to identify remaining sorryAx. Determine if `chronicle_gap_contradiction` is now unblocked or if other sorries remain.
- [ ] **Task 5.2**: Fill `chronicle_gap_contradiction` (ChronicleToCountermodel.lean). Case A (distinct limit functions): uses `contemp_equiv` and NF characterization with the now sorry-free Kamp chain. Case B (constant MCS): prove or mark as sub-sorry with clear documentation. (~50-80 lines)
- [ ] **Task 5.3**: Run full verification:
  - `lean_verify chronicle_gap_contradiction` -- no sorryAx (or reduced)
  - `lean_verify completeness_discrete` -- remaining sorryAx should trace ONLY through task 202 chain (succ_cofinal)
  - `lake build` -- full project, 0 errors
- [ ] **Task 5.4**: Update README.md if sorry obligations improve significantly.

**Timing**: 2 hours (~50-80 lines + verification)

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- fill chronicle_gap_contradiction
- `README.md` -- update sorry count if improved

**Verification**:
- `lean_verify chronicle_gap_contradiction` shows no sorryAx (or identifies remaining sub-sorry)
- `lean_verify completeness_discrete` -- remaining sorryAx traces only through task 202 chain
- `lake build` succeeds (full project, clean)

---

## Sorry Inventory (Current State)

| File | Line | Statement | Status | This Plan |
|------|------|-----------|--------|-----------|
| KampBypass.lean | 78-91 | `ssn_xt_compatible` (defective filter) | DEFECTIVE | Phase 1 fixes |
| KampBypass.lean | 690 | `existPart_succ_n1_bypass_k0_eq` | SORRY | Phase 2 fills |
| KampBypass.lean | 842 | `zone_3var_exist_iff_1var` | SORRY | Phase 2 fills |
| KampBypass.lean | 923 | `backward_holdsLeft_of_nf_eval` endLeft | SORRY | Phase 2 fills |
| KampBypass.lean | 935 | `backward_holdsLeft_of_nf_eval` endRight | SORRY | Phase 2 fills |
| KampBypass.lean | 939 | `backward_holdsLeft_of_nf_eval` bracket | SORRY | Phase 2 fills |
| KampBypass.lean | 997 | `forward_nf_eval_of_holdsLeft` | SORRY | Phase 2 fills |
| KampBypass.lean | 1109 | `existPart_succ_n1_bypass_k0_since` | SORRY | Phase 2 fills |
| KampBypass.lean | 1197 | `existPart_succ_n1_bypass` k>0 | SORRY | Phase 3 fills |
| NfCharFormula.lean | 541 | `nf_exist_backward_prior` k+1 | SORRY | Bypassed (dead code on critical path) |
| RabinovichGeneralized.lean | 465 | `existPart_succ` n>=2 | SORRY | Phase 4 fills |
| ChronicleToCountermodel.lean | 537 | `chronicle_gap_contradiction` | SORRY | Phase 5 fills |

### Existing Infrastructure (sorry-free, DO NOT TOUCH)

| File | Lines | Content |
|------|-------|---------|
| VecEADecomp.lean | 898 | Complete depth-0 3-var zone decomposition |
| NfToVecEA.lean | 700+ | Depth-0 2-var bridge + bracketBuildLeft |
| VecEATranslation.lean | 302 | Prop 3.5 translation |
| NegationClosureProp42.lean | 165 | Prop 4.2 neg_2var_vec_ea |
| PriorINF.lean | 194 | INF/SUP on Prior structures |
| RabinovichTranslation.lean | 302 | Prop 3.5 translate_correct |
| RabinovichWiring.lean | 365 | Rabinovich pipeline wiring |
| RabinovichNegation.lean | 297 | Backward k=0 |
| NfComposition.lean | 267 | intra_structure_extend |
| SeparationBridge.lean | 199 | neg_until_equiv_prior, neg_since_equiv_prior |
| VecEAClosure.lean | -- | VecEA closure |

## Testing & Validation

- [ ] Phase 1: `ssn_order_consistent_correct` compiles without sorry
- [ ] Phase 1: `lake build KampBypass` succeeds after filter fix
- [ ] Phase 2: `lean_verify existPart_succ_n1_bypass_k0` shows no sorryAx
- [ ] Phase 3: `lean_verify existPart_succ_n1_bypass` shows no sorryAx at all depths
- [ ] Phase 4: `lean_verify kamp_prior_expressive_completeness` shows no sorryAx
- [ ] Phase 4: `lean_verify US_expressively_complete_over_prior` shows no sorryAx
- [ ] Phase 5: `lean_verify completeness_discrete` -- sorryAx only through succ_cofinal chain
- [ ] Phase 5: `lake build` full project succeeds with 0 errors

## Artifacts & Outputs

**Existing (sorry-free, preserved)**:
- All files listed in Sorry Inventory "Existing Infrastructure" table above

**Modified (this plan)**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- Phases 1-3: filter fix + depth-0 wiring + depth >= 2 (~1500-1800 new lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/RabinovichGeneralized.lean` -- Phase 4: fill existPart_succ n >= 2 (~30-50 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfCharFormula.lean` -- Phase 4: verify/fix wiring (minor)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- Phase 5: fill chronicle_gap_contradiction (~50-80 lines)
- `README.md` -- Phase 5: update sorry count

**Estimated new Lean code**: ~1600-2000 lines across all files

## Rollback/Contingency

**If the ssn_order_consistent filter breaks existing proofs (Phase 1)**:
- The filter only removes unrealizable orderings. If existing proofs used an unrealizable ordering as a vacuous case, the proof structure needs adjustment. Check by running `lake build` after the filter change and examining any failures.

**If zone_3var_exist_iff_1var (Phase 2, Task 2.1) is harder than estimated**:
- Attack the smallest sorry first (bracket, L939, ~60 lines) to validate the wiring pattern. If the pattern works for bracket, it will work for all zone sorries.

**If depth >= 2 generalization fails at the Lean type level (Phase 3)**:
- Specialize to n=1 first (sufficient for NfCharFormula.lean). The n >= 2 case at RabinovichGeneralized.lean:465 can use the constant-base projection from the n=1 case.
- If the recursive call structure causes termination issues, use well-founded recursion on depth (strictly decreasing) with arity as a parameter.

**If chronicle_gap_contradiction Case B is non-trivial (Phase 5)**:
- Mark Case B as a separate sorry with a TODO comment. The Kamp chain closure (Phases 1-4) is the primary deliverable and is independent of the chronicle gap.

**If the approach fails entirely**:
- All existing sorry-free code (~5000+ lines) remains valid.
- The depth-0 case (Phases 1-2) is independent of the depth >= 2 case (Phase 3) and provides value regardless.
- Phase 3 failure does not invalidate Phases 1-2; in that scenario, the depth >= 2 sorry would remain but depth-0 and depth-1 would be sorry-free.
