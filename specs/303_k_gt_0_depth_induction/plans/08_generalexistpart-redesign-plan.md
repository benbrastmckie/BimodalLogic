# Implementation Plan: Redesign GeneralExistPart with 1-var NF Parameters and Zone Decomposition

- **Task**: 303 - k_gt_0_depth_induction
- **Status**: [NOT STARTED]
- **Effort**: 12 hours
- **Dependencies**: None (all k=0 infrastructure is sorry-free)
- **Research Inputs**: reports/07_literature-construction.md, reports/06_generalexistpart-redesign.md
- **Artifacts**: plans/08_generalexistpart-redesign-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v8 for closing the 2 remaining sorries in KampBypass.lean (lines 636, 688) that block `completeness_discrete`. Plans v2-v7 all failed. Plan v7 failed because GeneralExistPart was implemented with a full r-var NF precondition (`env_nf : NormalForm sig (k+1) r`) and Formula.top/bot construction, which is provably circular at the sorry sites: the precondition IS the goal being proved. The fix, confirmed by literature-first research (reports 06 and 07), is to redesign GeneralExistPart with individual 1-var NF parameters (`env_nfs : Fin r -> NormalForm sig (k+1) 1`) and actual temporal formula construction via zone decomposition per Rabinovich Prop 3.5. This plan rewrites GeneralExistPart.lean entirely, modifies the ih_general_exist plumbing in KampBypass.lean and KampMutualInduction.lean, then enriches the Until/Since formulas to close the sorries.

### Research Integration

Report 07 (literature-construction.md) established:
1. Rabinovich Prop 3.5: V-EA formula with one free variable -> TL(Until, Since) via nested Until/Since construction. Zone decomposition maps interval positions to temporal subformulas.
2. The redesigned GeneralExistPart precondition `forall i, nf_eval_nf M (k+1) 1 (fun _ => e i) (env_nfs i)` IS satisfiable from h_x_agree/h_t_agree at the sorry sites, breaking the circularity.
3. Formula.top/bot is provably insufficient (NfComposition.lean counterexample: Z with [0,2] vs [0,1] have same 1-var NFs but different 2-var NFs).
4. Induction structure: GeneralExistPart'(k+1) uses CharPart(k+1) + GeneralExistPart'(k), depth decreases, no circularity.
5. Estimated 890-1460 lines total.

Report 06 (generalexistpart-redesign.md) established:
1. Current GeneralExistPart is provably unusable at sorry sites (circular precondition).
2. The 1-var NF parameter redesign is the correct fix.
3. Zone decomposition is required (not Formula.top/bot).
4. The third mutual induction conjunct dependency graph has no cycles.

### Prior Plan Reference

Plan v7 completed Phases 1-3 (GeneralExistPart definition with Formula.top/bot, inductive step, KampMutualInduction plumbing). Phase 4 BLOCKED because the Formula.top/bot formulas carry no information and the full r-var NF precondition is circular. Lessons learned:
- The ih_general_exist plumbing in KampBypass.lean and KampMutualInduction.lean is already in place; only the type signature changes.
- The eq-zone case (KampBypass.lean:705-844) is sorry-free and provides the template for quantifier conjunction construction.
- generalExistPart_all (proved via simple cases, not mutual induction) works because the old Formula.top/bot proof is self-contained at each depth. The redesigned version WILL need mutual induction because zone decomposition at depth k+1 uses GeneralExistPart(k).
- Effort calibration: Phases 1-3 of v7 took about 5 hours; the redesign is more complex due to zone decomposition.

### Roadmap Alignment

Advances: "Task 303 (k>0 depth induction via Rabinovich Section 5 Lemma 5.1) -> sorry-free completeness_discrete" -- the SOLE remaining blocker on the critical path.

## Goals & Non-Goals

**Goals**:
- Rewrite GeneralExistPart.lean: change parameter from `env_nf : NormalForm sig (k+1) r` to `env_nfs : Fin r -> NormalForm sig (k+1) 1` (individual 1-var NFs)
- Implement actual temporal formula construction via zone decomposition (Rabinovich Prop 3.5)
- Prove GeneralExistPart(0) with zone-aware temporal formulas (not Formula.top/bot)
- Prove GeneralExistPart(k+1) from CharPart(k+1) + GeneralExistPart(k)
- Update ih_general_exist plumbing in KampBypass.lean and KampMutualInduction.lean to match new signature
- Enrich Until/Since formulas with quantifier conjuncts from redesigned GeneralExistPart
- Close the 2 sorries at KampBypass.lean:636 and :688
- Verify the completeness chain through `completeness_discrete` is sorry-free from the Kamp path

**Non-Goals**:
- Closing NfCharFormula.lean:542/651 sorries (dead code, not on critical path)
- Modifying k=0 infrastructure (KampBypassCore/Until/Since are sorry-free, ~4400 lines)
- Proving the false transfer theorem (prior_nonconstenv_2var_agree)
- Deleting PriorComposition.lean (already disconnected, can be done separately)
- Generalizing beyond what is needed to close the 2 sorry sites

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Zone decomposition at arbitrary arity r is too complex for Lean's heartbeat limits | H | M | Start with r=2 (the immediate need at the sorry site). If general r proves intractable, specialize to r=2 as a separate lemma and use it directly. The sorry sites only need r=2 with env_nfs = [nf_x0, nf_t0]. |
| Lean termination checker rejects the recursion (depth k decreases, arity r increases) | M | L | Use structural recursion on Nat (depth k). Arity r is universally quantified in each conjunct, not a recursive parameter. If needed, use well-founded recursion with `Nat.lt_wfRel`. |
| Zone formula correctness requires Prior-UZ/SZ in a way that creates new circularity | H | L | Report 07 verified: the Rabinovich navigational pattern (nested Until/Since) uses Prior-UZ/SZ as semantic hypotheses (available from the sorry site's context), not as proof targets. The k=0 zone bridge infrastructure already works this way. |
| Modifying ih_general_exist signature breaks existing plumbing | M | L | The existing plumbing (from v7 Phase 3) only needs type signature update. The call site in existPart_succ (line 311) passes `generalExistPart_all` which will be updated to match. The call in NfCharFormula.lean is dead code with a sorry argument. |
| GeneralExistPart(0) zone decomposition is substantially more work than estimated | M | M | The k=0 zone bridge infrastructure (enriched_vecEA2_until/since in KampBypassUntil/Since.lean) provides a working template for the 2-variable case. The general-r extension involves nested Until/Since per Rabinovich Prop 3.5, which is a finite case analysis on zone position. If the fully general proof exceeds 500 lines, factor into a separate ZoneDecomp.lean file. |
| The enriched Until/Since formula exceeds Lean's heartbeat limits | M | M | Factor proofs into small private helpers. The eq-zone case (KampBypass.lean:705-844, ~140 lines) provides the model for factorization. Use `set_option maxHeartbeats` as in existing files. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel.

### Phase 1: Rewrite GeneralExistPart Definition and Base Case (k=0) [IN PROGRESS]
*(dispatch 2: implementing GeneralExistPartIndiv definition + base/inductive step with sorry)*

**Analysis (dispatch 1)**: Thorough analysis confirmed:
1. The 2-var NF transfer from individual 1-var NF agreements is FALSE even on Prior structures (Z counterexample with uniform predicate: [0,2] vs [0,1] have same 1-var NFs but different 2-var NFs due to gap between 0 and 1)
2. The current GeneralExistPart produces Formula.top/Formula.bot via classical satisfiability, which carries NO information when embedded in an enriched formula
3. A redesigned GeneralExistPartIndiv with individual 1-var NF parameters AND actual temporal formula construction (zone decomposition) is REQUIRED
4. The quantifier conjunction from top/bot formulas is trivially true and cannot close the sorry
5. The zone decomposition approach (Rabinovich Prop 3.5) is the ONLY viable path

**Goal**: Replace the current GeneralExistPart.lean entirely. Define the new GeneralExistPart with individual 1-var NF parameters. Prove `generalExistPart_zero` using zone decomposition with actual temporal formulas.

**Mathematical content**: The new GeneralExistPart(k) states: for all r >= 1, given depth-k char formulas, r individual depth-(k+1) 1-var NF types `env_nfs`, and a depth-k (r+1)-var sub-NF `ssn`, there exists a temporal formula A such that for any Prior structure M and any environment e where each e(i) has the matching 1-var NF type, `temporal_truth M atomMap (e 0) A <-> exists y, nf_eval_nf M k (r+1) (Fin.cons y e) ssn`.

At depth 0, `nf_eval_nf M 0 (r+1) (Fin.cons y e) ssn` is purely atomic: it specifies predicates at y, predicates at each e(i) (guaranteed by hypothesis), and all pairwise orders. The existential decomposes by y's zone relative to {e(0), ..., e(r-1)}:
- Equality zones (y = e(i)): check atom compatibility at e(i) directly from env_nfs
- Between zones (e(i) < y < e(j)): encode using Until/Since and char_0 formulas
- Boundary zones (y < min or y > max): encode using Since/Until from nearest ref point

The formula is a disjunction over compatible zones and 1-var NF types for y, built via nested Until/Since per Rabinovich Prop 3.5.

**Tasks**:
- [ ] Delete all existing content of GeneralExistPart.lean (207 lines)
- [ ] Define new `GeneralExistPart` abbrev with `env_nfs : Fin r -> NormalForm sig (k+1) 1` parameter and precondition `forall i, nf_eval_nf M (k+1) 1 (fun _ => e i) (env_nfs i)`
- [ ] Define zone classification helpers: given ssn's atom part, classify y's position relative to the environment elements
- [ ] Build the temporal formula for each zone at depth 0 using nested Until/Since (Rabinovich Prop 3.5 pattern)
- [ ] Prove `generalExistPart_zero` forward: from nf_eval_nf extract zone and predicate type of y, build temporal truth of the zone-specific formula
- [ ] Prove `generalExistPart_zero` backward: from temporal truth extract zone, use Prior-UZ/SZ to find witness y, reconstruct nf_eval_nf
- [ ] Verify: `lake build GeneralExistPart` succeeds with no sorry

**Timing**: 2.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/GeneralExistPart.lean` -- full rewrite (definition + k=0 proof)

**Verification**:
- `lake build GeneralExistPart` succeeds
- `lean_verify generalExistPart_zero` shows no sorryAx

---

### Phase 2: Prove GeneralExistPart Inductive Step (k+1) [NOT STARTED]

**Goal**: Prove `generalExistPart_succ`: GeneralExistPart(k+1) from CharPart(k+1) + GeneralExistPart(k).

**Mathematical content**: At depth k+1, `nf_eval_nf M (k+1) (r+1) (Fin.cons y e) ssn` decomposes into:
1. Atom part: predicates and orders at y relative to e -- determines tau_y (1-var NF type) and zone position
2. Quantifier part: for each sub : NF(k, r+2), `(exists z, nf_eval_nf M k (r+2) (Fin.cons z (Fin.cons y e)) sub) <-> ssn.2 sub = true`

The atom part is handled like Phase 1 (zone decomposition + char formulas from CharPart(k+1)). The quantifier part is handled by GeneralExistPart(k) at arity r+1 with env_nfs = [tau_y, env_nfs(0), ..., env_nfs(r-1)]. Each quantifier condition becomes a temporal conjunct. The enriched point guard for each zone is: `char_{k+1}(tau_y) AND quant_conj`, where quant_conj is a conjunction over sub : NF(k, r+2) of either the GeneralExistPart(k) formula or its negation, depending on ssn.2(sub). Depth decreases from k+1 to k, so recursion terminates.

**Tasks**:
- [ ] Prove `generalExistPart_succ` taking `ih_char_succ : CharPart atomMap (k+1)` and `ih_general_exist_k : GeneralExistPart atomMap k` as hypotheses
- [ ] Handle zone classification (same as Phase 1 but with char_{k+1} formulas)
- [ ] Build quantifier conjunction from GeneralExistPart(k) at arity r+1
- [ ] Prove forward: from nf_eval_nf extract atom part + quantifier conditions, build temporal truth
- [ ] Prove backward: from temporal truth extract zone + quantifier conjuncts, use GeneralExistPart(k) backward to reconstruct nf_eval_nf
- [ ] Verify: `lake build GeneralExistPart` succeeds with no sorry in the inductive step

**Timing**: 2.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/GeneralExistPart.lean` -- add inductive step

**Verification**:
- `lake build GeneralExistPart` succeeds
- `lean_verify generalExistPart_succ` shows no sorryAx

---

### Phase 3: Update Mutual Induction and ih_general_exist Plumbing [NOT STARTED]

**Goal**: Update `kamp_mutual_induction` to include GeneralExistPart as a third conjunct. Update the ih_general_exist parameter signature in `existPart_succ_n1_bypass` and its call sites.

**Mathematical content**: The mutual induction becomes `forall k, CharPart(k) AND ExistPart(k) AND GeneralExistPart(k)`. Base: charPart_zero + existPart_zero + generalExistPart_zero. Step: CharPart(k+1) from CharPart(k) + ExistPart(k), ExistPart(k+1) from CharPart(k+1) + ExistPart(k) + GeneralExistPart(k), GeneralExistPart(k+1) from CharPart(k+1) + GeneralExistPart(k). Unlike v7 (where GeneralExistPart was self-contained at each depth), the redesigned version REQUIRES GeneralExistPart(k) in the inductive step, making mutual induction necessary.

**Tasks**:
- [ ] Update `kamp_mutual_induction` return type to `CharPart(k) AND ExistPart(k) AND GeneralExistPart(k)`
- [ ] Update the base case to include `generalExistPart_zero`
- [ ] Update the inductive step: pass `ih.2.2` (GeneralExistPart(k)) to `generalExistPart_succ` and to `existPart_succ` (which passes it to `existPart_succ_n1_bypass`)
- [ ] Update `ih_general_exist` parameter type in `existPart_succ_n1_bypass` (KampBypass.lean) from `env_nf : NormalForm sig (k+1) r` to `env_nfs : Fin r -> NormalForm sig (k+1) 1`, matching the new GeneralExistPart definition
- [ ] Update `existPart_succ` in KampMutualInduction.lean to pass GeneralExistPart(k) (from `ih.2.2`) to the bypass
- [ ] Update the call site in `existPart_succ` for n>=2 case (lines 323-325) to match new signature
- [ ] Update NfCharFormula.lean call site (dead code) with a sorry argument matching new signature
- [ ] Verify: `lake build KampMutualInduction` succeeds (sorry still present in KampBypass, but plumbing works)

**Timing**: 2 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampMutualInduction.lean` -- add third conjunct, update plumbing
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- update ih_general_exist parameter type
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfCharFormula.lean` -- update dead-code call site

**Verification**:
- `lake build KampMutualInduction` succeeds
- The sorry count in KampBypass.lean remains at 2 (not increased)

---

### Phase 4: Enrich Until/Since Formulas and Close Sorries [NOT STARTED]

**Goal**: Replace the sorry at KampBypass.lean:636 and :688 with proofs using the redesigned GeneralExistPart.

**Mathematical content**: At the sorry site (line 636, Until zone), the goal is:
```
forall ssn : NormalForm sig (k'+1) 3,
  (exists y, nf_eval_nf M (k'+1) 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) <->
  sub_nf.2 ssn = true
```

With redesigned `ih_general_exist` (= GeneralExistPart(k'+1)) available with 1-var NF parameters, instantiate at r=2 with env_nfs = ![nf_x0, nf_t0] and depth-k' char formulas. For each ssn, GeneralExistPart gives a formula A_ssn such that:
```
(forall i, nf_eval_nf M (k'+2) 1 (fun _ => e i) (env_nfs i)) ->
temporal_truth M atomMap (e 0) A_ssn <->
exists y, nf_eval_nf M (k'+1) 3 (Fin.cons y e) ssn
```
evaluated at e = Fin.cons x (fun _ => t), so e(0) = x.

The precondition `forall i, nf_eval_nf M (k'+2) 1 (fun _ => e i) (env_nfs i)` becomes h_x_eval (i=0) and h_t_eval (i=1), both of which are AVAILABLE from the enriched formula extraction.

The enriched Until formula changes from `char_kp1(nf_t0) AND (char_kp1(nf_x0) Until top)` to `char_kp1(nf_t0) AND (enriched_x_type Until top)`, where:
```
enriched_x_type = char_kp1(nf_x0) AND quant_conj
quant_conj = conjList(NF(k'+1,3).list.map fun ssn =>
  if sub_nf.2 ssn then A_ssn else A_ssn.neg)
```

Backward proof at line 636: extract x from Until, extract quant_conj truth at x, apply GeneralExistPart backward (preconditions h_x_eval and h_t_eval are available) to get the iff for each ssn. Forward proof: from nf_eval at [x,t], build temporal truth of enriched formula using GeneralExistPart forward.

The Since zone (line 688) is the mirror with reversed order.

**Tasks**:
- [ ] Build the quant_conj from ih_general_exist at r=2 with env_nfs = ![nf_x0, nf_t0], following the eq-zone quantifier conjunction pattern (KampBypass.lean lines ~700-716)
- [ ] Replace Until formula construction (line 598) with enriched version including quant_conj inside Until's left operand
- [ ] Prove backward direction (line 636): extract quant conjuncts from Until witness x, verify GeneralExistPart preconditions (h_x_eval, h_t_eval), apply GeneralExistPart backward to get the iff for each ssn
- [ ] Handle the evaluation-point subtlety: GeneralExistPart formula is evaluated at e(0) = x (Until witness), and quant_conj must be inside the Until's left operand (evaluated at x), not at the top level (evaluated at t)
- [ ] Prove forward direction: from nf_eval at [x,t], build temporal truth of enriched formula using GeneralExistPart forward
- [ ] Mirror for Since zone (line 688): replace Since formula, prove backward/forward
- [ ] Verify: `lake build KampBypass` succeeds with 0 sorry

**Timing**: 2.5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- enrich formula, close sorry at lines 636 and 688

**Verification**:
- `lake build KampBypass` succeeds with 0 sorry
- `lean_verify existPart_succ_n1_bypass` shows no sorryAx
- `lean_verify kamp_mutual_induction` shows no sorryAx

---

### Phase 5: Completeness Verification and Cleanup [NOT STARTED]

**Goal**: Verify the full completeness chain is sorry-free from the Kamp path and clean up.

**Tasks**:
- [ ] Run `lean_verify completeness_discrete` -- confirm no sorryAx from Kamp path
- [ ] Run full `lake build` -- confirm no regressions
- [ ] Verify NfCharFormula.lean:542/651 remain dead code (not imported by completeness chain)
- [ ] Remove PriorComposition.lean if still present (contains false theorems, disconnected from imports)
- [ ] Update lakefile if PriorComposition.lean was removed
- [ ] Write implementation summary to `specs/303_k_gt_0_depth_induction/summaries/`

**Timing**: 1.5 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- delete (if present)
- Implementation summary -- create

**Verification**:
- `lean_verify completeness_discrete` shows no sorryAx from Kamp path
- `lake build` succeeds with no regressions
- Summary written

## Testing & Validation

- [ ] After Phase 1: `lake build GeneralExistPart` succeeds; `lean_verify generalExistPart_zero` clean
- [ ] After Phase 2: `lake build GeneralExistPart` succeeds; `lean_verify generalExistPart_succ` clean
- [ ] After Phase 3: `lake build KampMutualInduction` succeeds; plumbing verified; sorry count unchanged
- [ ] After Phase 4: `lake build KampBypass` succeeds with 0 sorry; `lean_verify existPart_succ_n1_bypass` clean; `lean_verify kamp_mutual_induction` clean
- [ ] After Phase 5: `lean_verify completeness_discrete` clean; full `lake build` clean

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/GeneralExistPart.lean` -- rewritten (new definition + k=0 zone decomposition + k+1 inductive step)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampMutualInduction.lean` -- modified (third conjunct, updated plumbing)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- modified (updated ih_general_exist signature, enriched Until/Since formulas, sorry closed)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfCharFormula.lean` -- modified (dead code call site updated)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- deleted (if present)
- `specs/303_k_gt_0_depth_induction/plans/08_generalexistpart-redesign-plan.md` -- this plan
- `specs/303_k_gt_0_depth_induction/summaries/08_generalexistpart-summary.md` -- implementation summary

## Rollback/Contingency

1. **Phase 1 fails (zone decomposition at arbitrary arity too complex)**: Specialize GeneralExistPart to r=2 only. The sorry sites only need r=2 (env = [x, t]). Prove `generalExistPart_r2_zero` and `generalExistPart_r2_succ` as standalone lemmas. This sacrifices generality but closes the sorry. If the inductive step (Phase 2) then needs r=3, add `generalExistPart_r3_*` as a second specialized lemma.

2. **Phase 2 fails (inductive step too complex)**: Try unrolling one level: prove GeneralExistPart(1) directly using the k=0 zone infrastructure, then handle k+1 via GeneralExistPart(k) at k >= 1. This doubles the code but avoids the fully general recursive case.

3. **Phase 3 fails (plumbing breaks existing proofs)**: The modification is structurally parallel to v7 Phase 3 (which completed successfully). If `.1`/`.2` projections break, systematically update all uses to `.1`/`.2.1`/`.2.2` for the triple conjunction. Use `grep -rn "kamp_mutual_induction\|ih_char\|ih_exist" Theories/` to find all call sites.

4. **Phase 4 fails (enriched formula too complex)**: Factor the enriched formula and its proof into a dedicated helper file (`KampBypassEnriched.lean`). The eq-zone case (140 lines) provides the factorization model.

5. **Any phase**: `git revert` phase commits to restore pre-attempt state. The task has 7 prior plan versions documenting what does NOT work; do not re-attempt Formula.top/bot or full r-var NF precondition approaches.
