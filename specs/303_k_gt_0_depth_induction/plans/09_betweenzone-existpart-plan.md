# Implementation Plan: Eliminate ih_general_exist via Enriched Quantifier Encoding

- **Task**: 303 - k_gt_0_depth_induction
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: None (k=0 infrastructure is sorry-free)
- **Research Inputs**: reports/09_interval-splitting-mapping.md
- **Artifacts**: plans/09_betweenzone-existpart-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v9 eliminates the false `GeneralExistPartOrdered` third mutual induction conjunct and removes `ih_general_exist` from `existPart_succ_n1_bypass`. Research report 09 proved GeneralExistPartOrdered is FALSE at all depths (Z counterexample). Extended analysis during planning revealed that BetweenZoneExistPart (report 09's Option K1) is ALSO FALSE for the same reason: on Z with constant predicates, translation homogeneity makes all temporal formulas evaluate identically at every point, yet between-zone existentials depend on gap size. Any formulation that tries to characterize non-constant-env existentials via a single temporal formula at one evaluation point is false on translation-homogeneous structures. The fix is to restructure the k>0 case of `existPart_succ_n1_bypass` to encode quantifier conditions via `generalExistPart_from_classical` (which uses the full 2-var NF precondition and IS proved) with a self-bootstrapping backward proof that establishes the 2-var NF eval from formula-encoded truth values.

### Research Integration

Report 09 (interval-splitting-mapping.md) established:
1. GeneralExistPartOrdered is FALSE at ALL depths via Z translation homogeneity
2. Both sorry sites (GeneralExistPart.lean:174, 207) are IMPOSSIBLE to prove
3. The existing KampBypass proof for k>0 is vacuously true from a false hypothesis (ih_general_exist has an unsatisfiable type)
4. k=0 infrastructure (~4400 lines) is UNCHANGED and sorry-free

**Planning-phase finding (extends report 09)**: BetweenZoneExistPart (Option K1) is also FALSE. On Z with constant predicates: env [0,2] has between-zone witness y=1 (existential TRUE), env [0,1] has no between-zone witness (existential FALSE). Formula evaluated at x=2 vs x=1 must differ, but Z's translation homogeneity forces temporal_truth Z n A = temporal_truth Z m A for all n, m and all formulas A. No temporal formula can distinguish these cases. The fundamental issue: characterizing a 2-free-variable condition (depending on both x and t) via a 1-free-variable formula (evaluated at x only) is not guaranteed by the Kamp theorem, which handles only 1-free-variable formulas.

### Prior Plan Reference

Plan v8 Phase 1 BLOCKED because GeneralExistPartOrdered is FALSE. The completed Phases 3-4 demonstrated that the ih_general_exist plumbing and enriched formula structure in KampBypass.lean work correctly -- the issue is solely that ih_general_exist has an unprovable type. The eq-zone case (false/false branch, lines 922-1060) is fully sorry-free and provides the correct template: it uses ih_exist (constant-env ExistPart) for quantifier conditions, bypassing ih_general_exist entirely. Key lesson: the k>0 Until/Since zones need the same approach -- use ih_exist (not ih_general_exist) for quantifier encoding by leveraging `generalExistPart_from_classical`.

### Roadmap Alignment

Advances: "Task 303 (k>0 depth induction via Rabinovich Section 5 Lemma 5.1) -> sorry-free completeness_discrete" -- the SOLE remaining blocker on the critical path.

## Goals & Non-Goals

**Goals**:
- Remove GeneralExistPartOrdered from the mutual induction (revert to 2-conjunct: CharPart + ExistPart)
- Remove ih_general_exist parameter from existPart_succ_n1_bypass
- Restructure the k>0 Until/Since zones in existPart_succ_n1_bypass to encode quantifier conditions using `generalExistPart_from_classical` (full 2-var NF precondition, already proved)
- Close the sorry at GeneralExistPart.lean:174 and :207 by deleting the false definitions
- Verify the completeness chain through completeness_discrete

**Non-Goals**:
- Modifying the k=0 case (existPart_succ_n1_bypass_k0 is sorry-free)
- Modifying the eq-zone case (false/false branch is sorry-free)
- Proving BetweenZoneExistPart (it is also FALSE)
- Modifying k=0 infrastructure (KampBypassCore/Until/Since, ~4400 lines)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Self-bootstrapping backward proof creates circularity: need 2-var NF to use generalExistPart_from_classical, need generalExistPart_from_classical to establish 2-var NF | H | H | The enriched formula encodes quantifier truth values as temporal conjuncts. Extracting x from Until gives truth values directly. Use these truth values to CONSTRUCT the 2-var NF eval (atoms from h_atom_agree, quantifiers from formula-encoded values). The construction is direct, not via generalExistPart_from_classical. |
| Removing ih_general_exist requires major restructuring of 500+ lines of k>0 proof | H | M | The restructuring follows the eq-zone template (lines 922-1060), which already handles quantifier conditions without ih_general_exist. The Until/Since zones need analogous treatment. Estimate 200-300 lines modified. |
| New quantifier encoding approach exceeds heartbeat limits | M | M | Factor into private helpers. Use set_option maxHeartbeats as needed. The eq-zone case demonstrates the pattern at 140 lines. |
| Backward proof direction fails: formula-encoded truth values don't suffice to reconstruct nf_eval | H | M | The enriched formula encodes ALL quantifier conditions (one conjunct per ssn : NF(k'+1, 3)). Combined with atom agreement, this fully determines nf_eval_nf at the 2-var level. If reconstruction fails, investigate whether additional conjuncts are needed in the enriched formula. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Remove GeneralExistPartOrdered and Simplify Mutual Induction [COMPLETED]

**Goal**: Delete the false GeneralExistPartOrdered definition, its sorry proofs, and revert kamp_mutual_induction to a 2-conjunct form (CharPart + ExistPart).

**Tasks**:
- [x] In GeneralExistPart.lean: delete `GeneralExistPartOrdered` abbrev (lines 57-80), `generalExistPartOrdered_zero` theorem (lines 121-182), and `generalExistPartOrdered_succ` theorem (lines 191-207). Keep `GeneralExistPart` abbrev and `generalExistPart_from_classical` (both are correct and proved).
- [x] In KampMutualInduction.lean: remove the `GeneralExistPart` import if no longer needed, or keep it for `generalExistPart_from_classical`. Change `kamp_mutual_induction` return type from `CharPart ∧ ExistPart ∧ GeneralExistPartOrdered` to `CharPart ∧ ExistPart`. Remove `ih_general_exist_ordered` from `existPart_succ` parameter and its corresponding argument in the call. Remove `generalExistPartOrdered_succ` / `generalExistPartOrdered_zero` from induction cases. *(deviation: altered -- also removed GeneralExistPart import entirely since no symbol from that file is needed)*
- [x] In KampMutualInduction.lean: update `existPart_succ` to remove `ih_general_exist_ordered` parameter. The call to `existPart_succ_n1_bypass` will temporarily fail (parameter removed in Phase 2). *(deviation: altered -- also removed ih_general_exist from KampBypass.lean and fixed NfCharFormula.lean call site so full build passes with sorry at Until/Since zones)*
- [x] Verify: `lake build GeneralExistPart` succeeds (no sorry in remaining code)

**Notes**: Also fixed `nf_2var_exist_formula_prior_filled` extractor from `.2.1` to `.2` for 2-conjunct form. Fixed NfCharFormula.lean call from 3 sorry args to 2 sorry args. Full `lake build` passes.

**Sorry budget**: 0 new sorry (deleting sorry code)

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/GeneralExistPart.lean` -- delete false definitions
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampMutualInduction.lean` -- simplify to 2-conjunct

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.GeneralExistPart` succeeds
- No sorry in GeneralExistPart.lean
- KampMutualInduction.lean may have temporary errors (expected, fixed in Phase 2)

---

### Phase 2: Remove ih_general_exist from existPart_succ_n1_bypass [NOT STARTED]

**Goal**: Remove the ih_general_exist parameter from existPart_succ_n1_bypass and restructure the k>0 Until/Since/Eq zones to encode quantifier conditions without it.

**Approach**: The k>0 case (lines 493-1067) currently uses ih_general_exist in the Until zone (true/false, lines 592-773) and Since zone (false/true, lines 774-920) to build quant_conj. The eq zone (false/false, lines 921-1060) already uses ih_exist instead of ih_general_exist. The restructuring makes Until/Since zones follow the eq-zone pattern:

For the Until zone (t < x), each 3-var existential `exists y, nf_eval_nf M (k'+1) 3 [y,x,t] ssn` is encoded using `generalExistPart_from_classical` at arity 2 with env_nf = sub_nf. The key change: instead of using ge_formula/ge_correct (from ih_general_exist with weak preconditions), use gep_formula/gep_correct (from generalExistPart_from_classical with full 2-var NF precondition).

**Forward direction** (exists x -> temporal): We have nf_eval_nf M (k'+2) 2 [x,t] sub_nf. This satisfies the full 2-var NF precondition. So gep_correct applies directly: temporal truth at x iff existential.

**Backward direction** (temporal -> exists x): We extract x from Until. We need nf_eval_nf M (k'+2) 2 [x,t] sub_nf to use gep_correct. We build this from:
1. Atoms: h_atom_agree (from 1-var NF agreement + known order t < x)
2. Quantifiers: each ssn truth value is encoded in quant_conj. Extract from formula, use the truth value to produce the quantifier part directly via Iff.intro with the known Boolean value.

The crucial insight: we don't need gep_correct for the backward direction. The quant_conj already encodes the truth values. We BUILD nf_eval_nf by providing both the atom part (from h_atom_agree) and the quantifier part (from formula-extracted truth values). Once nf_eval_nf is established, we have the goal.

Wait -- the goal IS `exists x, nf_eval_nf M (k'+2) 2 [x,t] sub_nf`. We need to produce x and show nf_eval_nf. x comes from Until. nf_eval_nf requires atoms + quantifiers. Atoms: from agreement. Quantifiers: we need `(exists y, nf_eval [y,x,t] ssn) <-> sub_nf.2 ssn` for each ssn.

The formula-encoded truth values tell us whether `temporal_truth M x (gep_formula ssn)` holds. But gep_formula was built via classical satisfiability on M0. gep_formula = top iff M0 has the existential. We need: does M have the existential?

If gep_formula = top (M0 satisfiable): temporal_truth M x top = True. We need exists y in M. But M might not have the existential (Z counterexample). So this fails.

If gep_formula = bot (M0 unsatisfiable): temporal_truth M x bot = False. We need NOT exists y in M. If M unsatisfiable: correct. But M might be satisfiable. Again fails.

THE CIRCULARITY REMAINS. The formula (top/bot) does not carry enough information.

**Alternative approach**: Instead of top/bot, use ih_exist (ExistPart at depth k'+1 with constant env) to build formulas for each ssn. But ih_exist requires constant env, and the existential has non-constant env [x,t].

**Zone decomposition of each ssn**: For each ssn : NF(k'+1, 3), decompose `exists y, nf_eval [y,x,t] ssn` by y's zone:
- ssn says y=x: exists y=x with nf_eval [x,x,t] ssn. Since var0=var1, this simplifies to a constant-env condition at x plus conditions involving t. Use ih_exist for the constant-env part.
- ssn says y=t: similar.
- ssn says y>x: constant-env at x, use Until.
- ssn says y<t: constant-env at t, use Since.
- ssn says t<y<x: between-zone. THIS IS THE HARD CASE.
- ssn says x<y<t: mirror.

For the between-zone case, the existential is "exists y strictly between t and x with depth-(k'+1) conditions". At depth k'+1, this involves quantifier sub-conditions at depth k'. The sub-conditions are constant-env when y is the only variable (the sub-existential has env [y] -- constant), or involve [z,y,x,t] (4-var).

Actually, the depth-k'+1 NF eval at [y,x,t] has:
- Atom part: predicates at y,x,t + all pairwise orders (determined by zone + 1-var NFs)
- Quantifier part: for each chi : NF(k', 4), (exists z, nf_eval [z,y,x,t] chi) <-> ssn.2 chi

Each sub-existential `exists z, nf_eval [z,y,x,t] chi` has 3 free variables (y,x,t). This is even worse.

This recursive structure suggests we need induction on BOTH depth k AND some measure of the existential. Rabinovich uses induction on the bracket depth (number of witnesses), which decreases with each application of Lemma 5.1.

Given this deep structural issue, the correct implementation approach may be significantly more involved than initially estimated. Let me outline what IS achievable.

**Tasks**:
- [ ] Remove ih_general_exist parameter from existPart_succ_n1_bypass signature
- [ ] For the Until zone (true/false): restructure using generalExistPart_from_classical. Build quant_conj where each ge_formula(ssn) comes from generalExistPart_from_classical at arity 2 with env_nf = sub_nf. Forward direction: provide nf_eval_nf [x,t] sub_nf as precondition to get temporal iff existential. Backward direction: extract x from Until, establish nf_eval_nf [x,t] sub_nf by combining atom agreement + formula-encoded quantifier truth values, then the goal follows.
- [ ] For the Since zone (false/true): mirror of Until restructuring
- [ ] Update existPart_succ in KampMutualInduction.lean to call existPart_succ_n1_bypass without ih_general_exist_ordered
- [ ] Verify: `lake build KampBypass` succeeds (sorry count may change temporarily)

**Critical design question**: The backward direction needs to establish `nf_eval_nf M (k'+2) 2 [x,t] sub_nf` WITHOUT using generalExistPart_from_classical (circular). The approach: encode the quantifier truth values in the enriched formula (via ih_exist for constant-env sub-problems), extract them in the backward direction, and construct nf_eval_nf directly from atoms + extracted quantifier values.

For this to work, each 3-var existential `exists y, nf_eval [y,x,t] ssn` must be encoded as a temporal formula at x that is CORRECT (not just top/bot). The constant-env sub-problems (y=x, y=t, y>x, y<t) CAN be encoded correctly via ih_exist. The between-zone case (t<y<x, x<y<t) requires additional handling.

**Between-zone encoding via Since/Until**: "exists y in (t,x) with depth-0 atomic conditions" IS encodable via `char_pred(y) Since char(t)` at x (for the Until zone where t < x). At depth 0, this works because the atomic conditions on y are independent of the gap size -- the Since formula finds y if and only if a point with matching predicates exists between t and x. At depth k'+1, the between-zone involves quantifier conditions, which recurse to depth k'. By induction, the depth-k' conditions are encodable.

This IS the BetweenZoneExistPart idea, but now I realize the issue with the Z counterexample was wrong. Let me re-examine:

On Z with constant predicates: "exists y in (0,2) with pred(y)=true" IS true. "exists y in (0,1) with pred(y)=true" IS false. The Since formula `(pred Since char(t))` at x: at x=2, this asks "exists y<2 where pred holds and char(t) holds at some z<=y with pred holding from z to 2". Since pred is always true and char(t) is always true, this asks "exists y<2 and z<=y". Yes: y=1, z=0. So temporal_truth Z 2 (pred Since char(t)) = True. Good, matches the existential.

At x=1, "pred Since char(t)" asks "exists y<1 and z<=y with conditions". y=0, z=0 works (pred(0)=true, char(t) at 0=true). So temporal_truth Z 1 (pred Since char(t)) = True. But the existential "exists y in (0,1)" is False!

The Since formula is TOO WEAK: it finds witnesses OUTSIDE the interval (t,x). The formula `pred Since char(t)` finds y between z and x (where z satisfies char(t)), but doesn't constrain y to be in (t,x) specifically.

To constrain y to (t,x), we'd need a formula like `pred Since (char(t) AND NOT pred_before_t)` where pred_before_t captures "this is the SPECIFIC t we care about". But on Z with constant predicates, there's no formula that identifies t uniquely.

THIS is why Rabinovich uses a fundamentally different approach (bracket formulas + V-EA negation closure) rather than trying to express between-zone existentials directly.

Given this deep analysis, the correct implementation requires following Rabinovich's approach more faithfully. This is beyond the scope of a simple plan phase.

**Revised approach for Phase 2**: Add sorry at the between-zone quantifier encoding sites, with detailed blocker documentation. The non-between zones (y=x, y=t, y>x, y<t) CAN be handled via ih_exist. Document the between-zone case as requiring Rabinovich Lemma 5.1 negation closure.

**Sorry budget**: 2 sorry (one for Until between-zone quantifier encoding, one for Since mirror). This replaces the existing 2 sorry at GeneralExistPart.lean:174, 207 with sorry at more precise locations.

**Timing**: 2.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- remove ih_general_exist, restructure k>0 zones
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampMutualInduction.lean` -- update call site

**Verification**:
- `lake build KampBypass` succeeds
- Sorry count: 2 (at precise between-zone sites, replacing 2 in GeneralExistPart.lean)

---

### Phase 3: Research and Design V-EA Negation Closure [NOT STARTED]

**Goal**: Research Rabinovich's V-EA negation closure (Lemma 5.1) and design the Lean formalization needed to close the between-zone sorry from Phase 2.

**Context**: The between-zone existential "exists y in (t,x) with depth-k conditions on [y,x,t]" cannot be characterized by a single temporal formula evaluated at x. Rabinovich handles this via Lemma 5.1: the NEGATION of a bracket formula (exists-forall with multiple witnesses) reduces to a V-EA formula (disjunction of exists-forall formulas) on shorter intervals. The reduction uses:
1. INF formula: identify the nearest future point where a condition holds (using Prior-UZ/SZ = Dedekind completeness)
2. Interval splitting: at the INF point, split the interval into two sub-intervals
3. Sub-interval bracket formulas: each sub-interval has FEWER witnesses (induction terminates)

**Tasks**:
- [ ] Study Rabinovich Lemma 5.1 in detail: identify exactly which steps need Lean formalization
- [ ] Map the V-EA negation closure to the existing codebase: which infrastructure exists (VecEADecomp, ZoneBridge, KampForward) and what is missing
- [ ] Design the Lean type signature for a negation-closure lemma that suffices for the between-zone case
- [ ] Estimate effort for implementing the negation-closure lemma
- [ ] Write a research report with the design and effort estimate
- [ ] If the design shows the between-zone case is tractable (< 500 lines), proceed to Phase 4. Otherwise, document the blocker.

**Sorry budget**: 0 (research only)

**Timing**: 2 hours

**Depends on**: 2

**Files to modify**:
- `specs/303_k_gt_0_depth_induction/reports/` -- research report on V-EA negation closure design

**Verification**:
- Research report written with clear design recommendation
- Effort estimate for Phase 4

---

### Phase 4: Implement Between-Zone Quantifier Encoding and Close Sorry [NOT STARTED]

**Goal**: Implement the V-EA negation closure mechanism from Phase 3's design to close the between-zone sorry from Phase 2. Verify the full completeness chain.

**Tasks**:
- [ ] Implement the negation-closure lemma per Phase 3's design
- [ ] Replace the sorry at the between-zone quantifier encoding sites in KampBypass.lean
- [ ] Verify: `lake build KampBypass` with 0 sorry
- [ ] Verify: `lean_verify existPart_succ_n1_bypass` shows no sorryAx
- [ ] Verify: `lean_verify kamp_mutual_induction` shows no sorryAx
- [ ] Verify: `lean_verify completeness_discrete` shows no sorryAx from Kamp path
- [ ] Run full `lake build` for regression check

**Sorry budget**: 0 (target: all sorry closed)

**Timing**: 2 hours (contingent on Phase 3 design showing tractability)

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- close between-zone sorry
- Possibly new file for negation-closure infrastructure

**Verification**:
- `lake build` succeeds with 0 sorry in Kamp pipeline
- `lean_verify completeness_discrete` clean

## Testing & Validation

- [ ] After Phase 1: `lake build GeneralExistPart` succeeds; no sorry in remaining code
- [ ] After Phase 2: `lake build KampBypass` succeeds; sorry count = 2 (at between-zone sites only)
- [ ] After Phase 3: Research report written with actionable design
- [ ] After Phase 4: `lake build` succeeds; `lean_verify existPart_succ_n1_bypass` clean; `lean_verify completeness_discrete` clean

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/GeneralExistPart.lean` -- simplified (false definitions deleted)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampMutualInduction.lean` -- simplified to 2-conjunct
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- restructured k>0 zones
- `specs/303_k_gt_0_depth_induction/plans/09_betweenzone-existpart-plan.md` -- this plan
- `specs/303_k_gt_0_depth_induction/reports/` -- V-EA negation closure research (Phase 3)

## Rollback/Contingency

1. **Phase 2 restructuring breaks k=0 case**: The k=0 case does not use ih_general_exist (it calls existPart_succ_n1_bypass_k0 directly). The restructuring only touches the `| succ k' =>` branch. Rollback: `git revert`.

2. **Phase 3 research shows between-zone case requires > 500 lines**: Document as a separate task. The Phase 2 sorry at precise between-zone sites is a strictly better state than the current sorry at GeneralExistPartOrdered (which is FALSE and blocks all progress). The between-zone sorry blocks only the non-constant-env quantifier conditions, not the entire mutual induction.

3. **Phase 4 implementation exceeds heartbeat limits**: Factor negation-closure proof into a separate file (e.g., VEANegationClosure.lean). Use set_option maxHeartbeats liberally.

4. **Any phase**: `git revert` to restore pre-attempt state. The task has 8 prior plan versions; do NOT re-attempt GeneralExistPartOrdered or BetweenZoneExistPart (both are FALSE).
