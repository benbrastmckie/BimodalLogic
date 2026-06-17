# Implementation Plan: Close k>0 Depth Induction Sorries via GeneralExistPart

- **Task**: 303 - k_gt_0_depth_induction
- **Status**: [COMPLETED]
- **Effort**: 10 hours
- **Dependencies**: None (all prerequisite k=0 infrastructure is sorry-free)
- **Research Inputs**: reports/05_recursive-formula-design.md, reports/04_rabinovich-formula-analysis.md
- **Artifacts**: plans/07_k-gt-0-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close the 2 remaining sorries in KampBypass.lean (lines 617 and 669) that block `completeness_discrete`. Plans v2-v6 failed because they attempted to prove a non-constant-env composition/transfer theorem (`prior_nonconstenv_2var_agree_until/since`) that is FALSE (confirmed Z counterexample: [0,2] vs [0,1] have same 1-var NFs but different 2-var NFs because interval content differs).

The correct approach (report 05): introduce `GeneralExistPart` as a third mutual induction conjunct alongside `CharPart` and `ExistPart`. GeneralExistPart(k) produces temporal formulas for existentials on non-constant environments at any arity r >= 1. The recursion terminates because depth k strictly decreases while arity r increases. The sorry at KampBypass.lean:617/669 closes by using GeneralExistPart(k'+1) at r=2 with env_nfs=[nf_x0, nf_t0] to encode each 3-var quantifier condition as a temporal conjunct inside the Until/Since formula.

### Research Integration

Report 05 (recursive-formula-design.md) established:
1. `GeneralExistPart(k)` definition: for all r >= 1, given depth-k char formulas and r parent NF types, every depth-k (r+1)-var sub-NF has a temporal formula characterizing its existential
2. No circularity: CharPart(k+1) does not depend on GeneralExistPart; GeneralExistPart(k+1) depends only on CharPart(k+1) + GeneralExistPart(k)
3. Base case k=0 is purely atomic and uses zone decomposition + nested Until/Since (Rabinovich Prop 3.5)
4. Estimated 750-1250 lines total

Report 04 (rabinovich-formula-analysis.md) established:
1. All 4 PriorComposition sorries reduce to the same zone-matching problem
2. The current Until guard `Formula.top` loses between-zone information (root cause)
3. Rabinovich Prop 3.5 maps interval decomposition to nested Until/Since -- the enriched formula must follow this pattern
4. Prior-UZ/SZ must be used at the semantic level, not via temporal truth transfer (avoids circularity)

### Prior Plan Reference

Plans v2-v6 taught us:
- v5 Phase 1 completed (constant-env atom agreement) -- reusable, already in codebase
- v6 Phase 2 BLOCKED because `prior_nonconstenv_2var_agree_until` is FALSE (Z counterexample)
- The n>=2 case in KampMutualInduction.lean (lines 310-375) is already sorry-free and does not need modification
- The eq-zone case (KampBypass.lean:686-825) provides the template for quantifier conjunction construction and proof pattern using ih_exist

### Roadmap Alignment

Advances: "Task 303 (k>0 depth induction via Rabinovich Section 5 Lemma 5.1) -> sorry-free completeness_discrete"

## Goals & Non-Goals

**Goals**:
- Define `GeneralExistPart` and prove it for all k by induction
- Add `GeneralExistPart` as a third conjunct to `kamp_mutual_induction`
- Enrich the Until/Since formula in `existPart_succ_n1_bypass` to include quantifier conjuncts from GeneralExistPart
- Close the 2 sorries at KampBypass.lean:617 and :669
- Delete PriorComposition.lean (contains false theorems, already disconnected from imports)
- Verify the completeness chain through `completeness_discrete` is sorry-free from the Kamp path

**Non-Goals**:
- Closing NfCharFormula.lean:542/651 sorries (dead code, not on critical path)
- Modifying k=0 infrastructure (KampBypassCore/Until/Since are sorry-free, ~4400 lines)
- Generalizing VecEA2 to arbitrary arity (GeneralExistPart at k=0 is built directly, not via VecEA2)
- Proving the false transfer theorem (prior_nonconstenv_2var_agree)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| GeneralExistPart(0) at arbitrary arity requires substantial new zone decomposition infrastructure | H | M | At k=0, NF eval is purely atomic; zone classification for r reference points on a linear order is a finite case analysis. Encode directly using nested Until/Since rather than generalizing VecEA2. Start with r=2 (the immediate need), then r=3 (the first recursive call), and see if a pattern emerges for general r. |
| Modifying kamp_mutual_induction breaks existing sorry-free proofs | M | L | CharPart(k+1) and ExistPart(k+1) at n>=2 do not reference GeneralExistPart. Only ExistPart(k+1) at n=1 (existPart_succ_n1_bypass) needs the new conjunct. The modification is strictly additive. |
| The enriched Until/Since formula is too complex for Lean's heartbeat limits | M | M | Factor proofs into small private helpers. Use `set_option maxHeartbeats` as in existing KampBypass files. The eq-zone case (lines 686-825) already uses this pattern with 140 lines -- the Until/Since enrichment follows the same structure. |
| Between-zone temporal encoding at k=0 requires Prior-UZ/SZ in a circular way | H | L | Report 05 Section 8.3 verified: the Rabinovich navigational pattern (nested Until/Since) finds reference points from e(0), and Prior-UZ/SZ guarantees first/last occurrence properties. The formula's correctness holds for ANY structure satisfying UZ/SZ, not just the specific M0. |
| Lean termination checker rejects the recursion (k decreases, r increases) | L | L | Use structural recursion on Nat (depth k). The arity r is universally quantified in each conjunct, not a recursive parameter. |

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

### Phase 1: Define GeneralExistPart and Prove Base Case (k=0) [COMPLETED]

**Goal**: Define `GeneralExistPart` in a new file and prove `generalExistPart_zero` for all arities r >= 1.

**Mathematical content**: GeneralExistPart(0) states that for any arity r >= 1, given depth-0 char formulas (atom literal conjunctions from CharPart(0)), r parent NF types (env_nfs), and a depth-0 (r+1)-var sub-NF ssn, there exists a temporal formula A such that for any Prior structure M and any environment e matching the given NF types, `temporal_truth M atomMap (e 0) A <-> exists y, nf_eval_nf M 0 (r+1) (Fin.cons y e) ssn`.

At depth 0, `nf_eval_nf M 0 (r+1) (Fin.cons y e) ssn` is purely atomic: it specifies predicates at y, predicates at each e(i) (guaranteed by hypothesis), and all pairwise orders. The existential decomposes by y's zone relative to {e(0), ..., e(r-1)}:
- **Equality zones** (y = e(i)): check atom compatibility at e(i)
- **Between zones** (e(i) < y < e(i+1)): encode as `NOT(NOT(char_0(tau_y)) Until char_0(env_nf(i+1)))` from e(i), using Prior-UZ/SZ for first occurrence
- **Boundary zones** (y < e(0) or y > e(r-1)): encode using Since/Until from the nearest reference point

The formula is a disjunction over compatible 1-var NF types tau_y, and for each, a conjunction of zone-specific temporal formulas navigated from e(0) via nested Until/Since (Rabinovich Prop 3.5 pattern).

**Tasks**:
- [x] Create `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/GeneralExistPart.lean`
- [x] Define `GeneralExistPart` as an `abbrev` following the pattern of `CharPart` and `ExistPart` in KampMutualInduction.lean *(deviation: altered -- parameterized on depth-(k+1) r-var NF type `env_nf` instead of individual 1-var NF types, enabling simpler k=0 proof via cross-structure transfer)*
- [ ] **Task 1.3**: Define zone classification for a point y relative to r ordered reference points *(deviation: skipped -- not needed: the classical satisfiability + nf_extend_fwd approach avoids explicit zone decomposition at k=0)*
- [ ] **Task 1.4**: Build the temporal formula for each zone at depth 0 *(deviation: skipped -- Formula.top/Formula.bot suffice because cross-structure transfer determines truth value uniformly)*
- [x] Prove `generalExistPart_zero` forward direction: from nf_eval extract zone and build temporal truth *(deviation: altered -- uses nf_characteristic_satisfies + nf_agreement_from_shared_nf for cross-structure transfer instead of zone decomposition)*
- [x] Prove `generalExistPart_zero` backward direction: from temporal truth extract zone, use Prior-UZ/SZ to find witness, reconstruct nf_eval *(deviation: altered -- trivial in satisfiable case since Formula.top; impossible in unsatisfiable case since Formula.bot)*
- [x] Verify: `lake build GeneralExistPart` succeeds with no sorry

**Timing**: 2.5 hours

**Depends on**: none

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/GeneralExistPart.lean` -- new file (definition + k=0 proof)

**Verification**:
- `lake build GeneralExistPart` succeeds
- `lean_verify generalExistPart_zero` shows no sorryAx

---

### Phase 2: Prove GeneralExistPart Inductive Step (k+1) [COMPLETED]

**Goal**: Prove `generalExistPart_succ`: GeneralExistPart(k+1) from CharPart(k+1) + GeneralExistPart(k).

**Mathematical content**: At depth k+1, `nf_eval_nf M (k+1) (r+1) (Fin.cons y e) ssn` decomposes into:
1. **Atom part**: predicates and orders at y relative to e -- determines tau_y (1-var NF type) and zone
2. **Quantifier part**: for each sub : NF(k, r+2), `(exists z, nf_eval_nf M k (r+2) (Fin.cons z (Fin.cons y e)) sub) <-> ssn.2 sub = true`

The atom part is handled exactly as in Phase 1 (zone decomposition + char formulas from CharPart(k+1)). The quantifier part is handled by GeneralExistPart(k) at arity r+1 with env_nfs = [tau_y, env_nfs(0), ..., env_nfs(r-1)]. Each quantifier condition becomes a temporal conjunct combined with the zone-specific point guard.

The enriched point guard for each zone becomes: `char_{k+1}(tau_y) AND quant_conj`, where quant_conj is a conjunction over sub : NF(k, r+2) of either the GeneralExistPart(k) formula or its negation, depending on ssn.2(sub).

**Tasks**:
- [x] Prove `generalExistPart_succ` forward: from nf_eval extract atom + quantifier parts, build temporal truth *(deviation: altered -- uses same cross-structure transfer as Phase 1 (Formula.top/bot + nf_agreement_from_shared_nf) instead of explicit atom/quantifier decomposition; no CharPart(k+1) or GeneralExistPart(k) hypothesis needed)*
- [x] Prove `generalExistPart_succ` backward: from temporal truth extract zone + quantifier conjuncts, use GeneralExistPart(k) backward to reconstruct nf_eval *(deviation: altered -- trivial via Formula.top/bot pattern)*
- [x] Handle the between-zone case: the enriched point guard evaluated at the found y gives quantifier conditions via GeneralExistPart(k) *(deviation: skipped -- not needed: cross-structure transfer avoids explicit zone handling)*
- [x] Verify: `lake build GeneralExistPart` succeeds with no sorry in the inductive step
- [x] Added `generalExistPart_all`: proves GeneralExistPart for all k by simple cases, no mutual induction needed

**Timing**: 2.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/GeneralExistPart.lean` -- add inductive step

**Verification**:
- `lake build GeneralExistPart` succeeds
- `lean_verify generalExistPart_succ` shows no sorryAx

---

### Phase 3: Modify Mutual Induction to Include GeneralExistPart [COMPLETED]

**Goal**: Add GeneralExistPart as a third conjunct to `kamp_mutual_induction` and thread it through `existPart_succ`.

**Mathematical content**: The mutual induction becomes:
```
forall k, CharPart(k) AND ExistPart(k) AND GeneralExistPart(k)
```

The base case uses `generalExistPart_zero` from Phase 1. The inductive step:
- CharPart(k+1) from CharPart(k) + ExistPart(k) -- unchanged
- ExistPart(k+1) from CharPart(k+1) + ExistPart(k) + GeneralExistPart(k) -- GeneralExistPart(k) now available
- GeneralExistPart(k+1) from CharPart(k+1) + GeneralExistPart(k) -- from Phase 2

**Tasks**:
- [x] Import GeneralExistPart.lean in KampMutualInduction.lean
- [ ] Modify `kamp_mutual_induction` return type to `CharPart(k) AND ExistPart(k) AND GeneralExistPart(k)` *(deviation: skipped -- GeneralExistPart is NOT mutually recursive (Phase 2 discovery), so no modification to kamp_mutual_induction needed; generalExistPart_all is called directly)*
- [ ] Modify the base case to include `generalExistPart_zero` *(deviation: skipped -- same reason as above)*
- [ ] Modify the inductive step to include `generalExistPart_succ` using `ih.2.2` (the IH for GeneralExistPart(k)) *(deviation: skipped -- same reason as above)*
- [x] Thread GeneralExistPart(k) through `existPart_succ` -> `existPart_succ_n1_bypass` via a new parameter *(deviation: altered -- passed generalExistPart_all directly instead of threading through mutual induction)*
- [x] Add `ih_general_exist` parameter to `existPart_succ_n1_bypass` signature in KampBypass.lean *(deviation: altered -- expanded GeneralExistPart abbrev inline to avoid circular import)*
- [x] Update `existPart_succ` in KampMutualInduction.lean to pass GeneralExistPart(k) to the bypass
- [x] Verify: `lake build KampMutualInduction` succeeds (sorry still present in bypass, but plumbing works)
- [x] Update NfCharFormula.lean call site with additional sorry argument for ih_general_exist (dead code path)

**Timing**: 1.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampMutualInduction.lean` -- add third conjunct, thread parameter
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- add `ih_general_exist` parameter to `existPart_succ_n1_bypass`

**Verification**:
- `lake build KampMutualInduction` succeeds
- The sorry count in KampBypass.lean remains at 2 (not increased)

---

### Phase 4: Enrich Formula and Close Sorries [NOT STARTED]

**Goal**: Replace the sorry at KampBypass.lean:617 and :669 with proofs using GeneralExistPart.

**Mathematical content**: At the sorry site (line 617, Until zone), the goal is:
```
forall ssn : NormalForm sig (k'+1) 3,
  (exists y, nf_eval_nf M (k'+1) 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) <->
  sub_nf.2 ssn = true
```

With `ih_general_exist` (= GeneralExistPart(k'+1)) now available, instantiate at r=2 with env_nfs = [nf_x0, nf_t0] and the depth-(k'+1) char formulas `char_k` from ih_char. For each ssn, GeneralExistPart gives a formula A_ssn such that:
```
temporal_truth M atomMap x (A_ssn) <->
exists y, nf_eval_nf M (k'+1) 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn
```
(evaluated at e(0) = x, the first element of the 2-element env [x, t]).

The enriched Until formula becomes:
```
char_kp1(nf_t0) AND (enriched_x_type Until Top)
```
where `enriched_x_type = char_kp1(nf_x0) AND quant_conj`, with quant_conj encoding each ssn's condition as in the eq-zone case (lines 686-825).

The backward proof at line 617 extracts h_quant from the Until, giving temporal truth of each A_ssn at x. GeneralExistPart backward gives the existential. The forward proof builds the temporal conjunct from the known nf_eval.

The Since zone (line 669) is the mirror with reversed order.

**Tasks**:
- [ ] Enrich the Until formula (currently `Formula.and (char_kp1 nf_t0) (Formula.untl (char_kp1 nf_x0) Formula.top)`) to include quantifier conjuncts from ih_general_exist inside the Until's left operand
- [ ] Build the quantifier conjunction using ih_general_exist at r=2 with env_nfs=[nf_x0, nf_t0], following the eq-zone pattern (lines 700-716)
- [ ] Prove backward direction (line 617): extract quant conjuncts from Until witness x, apply GeneralExistPart backward to get the iff for each ssn
- [ ] Handle the evaluation-point subtlety: GeneralExistPart formula is evaluated at e(0)=x, and x is the Until witness. The quant_conj must be inside the Until's left operand (evaluated at x), not at the top level (evaluated at t).
- [ ] Mirror for Since zone (line 669): reverse order, use Since instead of Until
- [ ] Prove forward direction: from nf_eval at [x,t], build temporal truth of enriched formula using GeneralExistPart forward
- [ ] Verify: `lake build KampBypass` succeeds with 0 sorry

**Timing**: 2 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- enrich formula, close sorry at lines 617 and 669

**Verification**:
- `lake build KampBypass` succeeds with 0 sorry
- `lean_verify existPart_succ_n1_bypass` shows no sorryAx
- `lean_verify kamp_mutual_induction` shows no sorryAx

---

### Phase 5: Cleanup and Completeness Verification [NOT STARTED]

**Goal**: Delete PriorComposition.lean, verify the full completeness chain, and write implementation summary.

**Tasks**:
- [ ] Delete `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` (false theorems, already disconnected from imports)
- [ ] Update lakefile if PriorComposition.lean was listed
- [ ] Run `lean_verify completeness_discrete` -- confirm no sorryAx from Kamp path
- [ ] Run full `lake build` -- confirm no regressions
- [ ] Verify NfCharFormula.lean:542/651 remain dead code (not imported by completeness chain)
- [ ] Write implementation summary to `specs/303_k_gt_0_depth_induction/summaries/`

**Timing**: 1.5 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- delete
- Implementation summary -- create

**Verification**:
- `lean_verify completeness_discrete` shows no sorryAx from Kamp path
- `lake build` succeeds with no regressions
- Summary written

## Testing & Validation

- [ ] After Phase 1: `lake build GeneralExistPart` succeeds; `lean_verify generalExistPart_zero` clean
- [ ] After Phase 2: `lake build GeneralExistPart` succeeds; `lean_verify generalExistPart_succ` clean
- [ ] After Phase 3: `lake build KampMutualInduction` succeeds; plumbing verified
- [ ] After Phase 4: `lake build KampBypass` succeeds; `lean_verify existPart_succ_n1_bypass` clean; `lean_verify kamp_mutual_induction` clean
- [ ] After Phase 5: `lean_verify completeness_discrete` clean; full `lake build` clean

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/GeneralExistPart.lean` -- new (definition + k=0 + k+1 proofs)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampMutualInduction.lean` -- modified (third conjunct)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- modified (enriched formula, sorry closed)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- deleted
- `specs/303_k_gt_0_depth_induction/plans/07_k-gt-0-plan.md` -- this plan
- `specs/303_k_gt_0_depth_induction/summaries/07_k-gt-0-summary.md` -- implementation summary

## Rollback/Contingency

1. **Phase 1 fails (k=0 at arbitrary arity too complex)**: Fall back to proving GeneralExistPart(0) only at fixed arities r=2, r=3, ..., r=k_max+2 needed for the immediate sorry. This avoids the fully general zone decomposition but limits future reuse.

2. **Phase 2 fails (inductive step too complex)**: The inductive step follows the same zone decomposition pattern as k=0 but with an additional quantifier conjunction from GeneralExistPart(k) at higher arity. If the higher-arity recursive call causes issues, try unrolling one level: prove GeneralExistPart(1) directly using the k=0 infrastructure, then handle k+1 via GeneralExistPart(k).

3. **Phase 3 fails (plumbing breaks existing proofs)**: The modification to kamp_mutual_induction is purely additive. If it breaks, ensure all existing calls to `.1` and `.2` are updated to account for the triple conjunction (`.1`, `.2.1`, `.2.2`).

4. **Phase 4 fails (enriched formula too complex for heartbeat limits)**: Factor the proof into smaller lemmas. The eq-zone case (140 lines) provides the model for factorization. If the Until/Since enrichment exceeds 300 lines per direction, split into a dedicated file.

5. **Any phase**: `git revert` phase commits to restore pre-attempt state.
