# Implementation Plan: Interval-Based P2_n(k) Formula for Prior Structures (v19)

- **Task**: 273 - chronicle_gap_contradiction_proof
- **Status**: [IMPLEMENTING]
- **Effort**: 20 hours
- **Dependencies**: Plan v18 phases 1-2 (COMPLETED), v18 phase 3 partial (P1/P2 base + P1(k+1) + P2(k+1) forward sorry-free)
- **Research Inputs**:
  - specs/273_chronicle_gap_contradiction_proof/reports/09_negation-closure-research.md
  - specs/273_chronicle_gap_contradiction_proof/reports/08_team-research.md
  - specs/273_chronicle_gap_contradiction_proof/handoffs/phase-3-handoff-20260611f.md
- **Artifacts**: plans/19_interval-formula-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4

## Overview

Replace the unprovable `nf_exist_formula` backward direction at depth k+1 (NegationClosure.lean:404) with an **interval-based formula** that explicitly encodes the full arity-2 NF including its quantifier part (sub_nf.2). The current formula only encodes atom compatibility and the 1-var NF of the witness x, which is insufficient because the "composition theorem" (2-var NF determined by 1-var NFs + order) is FALSE at all depths >= 1 on Prior structures.

The fix generalizes P2 to all arities P2_n(k) and uses nested Until/Since chains (buildRight/buildLeft from Translation.lean) to place interval witnesses whose types encode the quantifier conditions of sub_nf.2. The dependency chain P2_2(k+1) <- P2_3(k) <- P2_4(k-1) <- ... <- P2_{k+3}(0) terminates at depth 0 where all arities reduce to atoms.

### Literature Alignment

The approach synthesizes ideas from four sources:

1. **Doets 1989, Lemma 1.1** (NF finiteness by induction on quantifier rank and arity): The arity chain P2_n(k) follows the same depth/arity structure that underlies Doets's finiteness proof. At depth 0, there are finitely many n-variable NFs determined by atom assignments (disjunctive normal forms over atomic formulas). At depth k+1, the NF adds quantifier conditions that reference depth-k NFs with one more variable -- in Doets's proof (lines 87-91 of the extract), at rank n+1 one forms DNFs over "atoms" forall x_k phi and exists x_k phi where phi has rank n in variables x_0, ..., x_k. The extra variable x_k is consumed by the quantifier, so the free variable count stays at k, but the sub-formulas phi range over k+1 variables. This is exactly the NormalForm structure in the codebase: NF(k+1, n) has a quantifier part that is a function NF(k, n+1) -> Bool. The plan's P2_gen uses this structure to prove temporal expressibility (not just finiteness), which is a stronger result than Doets's lemma but relies on the same NF architecture.

2. **Rabinovich 2014, Section 5 (proof of Proposition 4.2)**: The construction of `nf_exist_formula_interval` and the proof of its backward direction draw on the proof techniques from Section 5, which proves Proposition 4.2 ("the negation of exists-forall formulas with at most two free variables is equivalent over Dedekind complete chains to a disjunction of exists-forall formulas"). Note: Prop 4.2 is a single structural claim about negation closure, not a biconditional with forward/backward directions. Our backward direction uses the *proof machinery* of Section 5 -- specifically Lemma 5.1 (the full negation closure with 3-case decomposition), Lemma 5.3 (base case where all beta_i are True, proved by induction on n using the infimum construction), and Corollary 5.4 (bounded existential reduction). For Prior structures, the INF formula (Notation 5.2) simplifies because first occurrences are ATTAINED (Prior-UZ/SZ), eliminating the K+ disjunct.

3. **Rabinovich 2014, Proposition 3.5** (exists-forall to temporal via nested Until/Since): The buildRight/buildLeft infrastructure in Translation.lean already implements this. The interval formula construction extends it to encode quantifier conditions as witness types.

4. **Libkin 2004, Lemma 3.7** (composition lemma for linear orders): The composition principle -- "the rank-(k-1) type of (L, a) is determined by the rank-k types of L^{<=a} and L^{>=a}" -- provides the model-theoretic intuition. Note the rank drop: equiv_k of parts gives equiv_{k-1} of the whole, which corresponds to our P2_n(k+1) depending on P2_{n+1}(k). Our failed "composition theorem" was an incorrect stronger claim (2-var NF from 1-var NFs alone); the correct composition operates at the level of interval decompositions, not endpoint NFs alone. Thomas 1997 provides the general Feferman-Vaught framework.

**Lemma-to-literature mapping** (new lemmas):

| Lean lemma | Literature source |
|------------|-------------------|
| `P2_gen atomMap k n` | Uses NF structure from Doets 1989 Lemma 1.1; proves temporal expressibility by induction on (k, n) |
| `nf_exist_formula_interval` | Temporal encoding (via Prop 3.5 Until/Since translation) of the interval pattern from Rabinovich 2014 Section 5 Notation 5.2, specialized to Prior structures |
| `P2_gen_base` (P2_n(0)) | Doets 1989 Lemma 1.1 base case (disjunctive normal forms over atomic formulas) |
| `nf_exist_formula_interval_forward` | Straightforward direction: given witnesses, show the nested Until/Since chain holds (Rabinovich Prop 3.5 correctness) |
| `nf_exist_formula_interval_backward` | Uses proof techniques from Rabinovich 2014 Section 5 (Lemma 5.1 case decomposition, Lemma 5.3 infimum construction, Cor 5.4 bounded existential) to extract witnesses from formula truth |
| `interval_decomposition` | Rabinovich 2014 Lemma 5.1 interval decomposition; philosophically related to Libkin Lemma 3.7 / Feferman-Vaught composition |

### Research Integration

- Handoff phase-3-handoff-20260611f.md: Root cause analysis of the backward direction blocker. Composition theorem proved FALSE. Validated the interval-based formula approach with arity generalization. Estimated ~750 lines.
- Report 09 (negation-closure-research): Phased decomposition, nf_to_formula bridge strategy.
- Report 08 (team-research): Path A (Rabinovich bypass) primary; sorry 3 confirmed FALSE.

## Goals & Non-Goals

**Goals**:
- Replace nf_exist_formula at depth k+1 with an interval-based formula encoding the full sub_nf (atoms + quantifiers)
- Generalize P2 to P2_n(k) for arbitrary arity n >= 2
- Prove both forward and backward directions of the generalized formula
- Eliminate the sorry at NegationClosure.lean:404
- Fill the dependent sorry in NfCharFormula.lean:572 (nf_2var_exist_formula_prior)
- Fill the sorry in KampPrior.lean:149 (nf_characterizable_temporal_prior k+1)
- Achieve sorry_count=0 for `US_expressively_complete_over_prior` and `kamp_prior_expressive_completeness`

**Non-Goals**:
- VEF closure lemmas (closed_conj, closed_ex) -- bypassed by NfCharFormula approach
- Dedekind-complete instantiation of HasDefinableINF/SUP
- General Kamp theorem for non-Prior structures
- Modifying type signatures of US_expressively_complete_over_prior or kamp_prior_expressive_completeness

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Arity generalization adds significant complexity to the induction structure (nested Nat.rec on both depth and arity) | H | M | Start with P2_2(k+1) backward using P2_3(k), verify the pattern compiles, then generalize. The base case P2_n(0) is always trivial (atoms only). |
| buildRight/buildLeft correctness proofs need adaptation for quantifier-encoding witness types | M | M | Translation.lean already has buildRight_correct/buildLeft_correct; extend rather than rewrite. The main new content is encoding sub_nf.2 entries as interval conditions. |
| Ordering enumeration over interval witnesses creates combinatorial blowup | M | L | Prior structures with UZ/SZ guarantee attained first occurrences with gaps, eliminating the K+ disjunct. Take disjunction over all orderings (finitely many). |
| Phase 5 (backward direction) is the hardest and may exceed dispatch capacity | H | M | Budget 300 lines. Allow splitting into sub-dispatches (5a: Until case, 5b: Since case, 5c: identity case). |
| Type-level friction between generalized P2_n and the existing master_induction P2 | L | M | P2_2(k) is exactly the existing P2(k). Wire the generalized version to produce P2 as a special case. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 0 | 1, 2 | -- (already COMPLETED) |
| 1 | 3 | -- |
| 2 | 4 | 3 |
| 3 | 5 | 4 |
| 4 | 6 | 5 |
| 5 | 7 | 6 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Translation Correctness (Proposition 3.5) [COMPLETED]

**Goal**: Prove `translateEF1_correct` -- that the Until/Since chain translation of a 1-variable exists-forall formula is semantically correct.

**Files modified**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Translation.lean`

**Verification**: `lake build Bimodal.Metalogic.WeakCanonical.Kamp.Translation` succeeds, sorry-free.

---

### Phase 2: Abstract INF Hypothesis, Prior Instantiation [COMPLETED]

**Goal**: Define abstract first/last-occurrence hypotheses `HasDefinableINF`/`HasDefinableSUP`, prove Prior instantiation, create NfCharFormula.lean with master induction architecture.

**Files modified**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorINF.lean`, `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfCharFormula.lean`

**Verification**: `lake build` on both files succeeds.

---

### Phase 3: Generalized P2_n(k) Definition and Base Cases [BLOCKED]

**BLOCKER** (Phase 3):
- **What failed**: The P2(k+1) backward direction at NegationClosure.lean:447 (sorry). The current formula `nf_exist_formula` omits `sub_nf.2` (quantifier part). Three alternative approaches were exhaustively analyzed and all failed.
- **What was tried**:
  1. NF-transfer (good_forall): define good(nf_t) = "in ALL Prior models with NF nf_t, existential holds". Forward direction requires showing nf_t is good, i.e., transferring the existential to all models with the same NF. This is the "composition theorem" which is FALSE at depth k >= 1 (two points with the same depth-(k+1) 1-var NF can disagree on depth-(k+1) 2-var existentials because the 2-var existential has monadic FO depth k+2, exceeding the k+1 NF depth).
  2. Classical existence (good_exists): define good(nf_t) = "SOME Prior model witnesses". Forward is trivial but backward requires the same NF-transfer (need to transfer from the witnessing model to the current model).
  3. P2_n arity generalization: P2 handles arity 2 (1 parent + 1 new). The quantifier conditions in sub_nf.2 involve arity 3 (2 parents + 1 new). But temporal formulas are 1-variable objects, so P2_n for n > 2 parent variables cannot directly produce a temporal formula evaluated at a single point.
- **Why it's stuck**: The formula `nf_exist_formula` is the WRONG formula. It encodes only atoms + depth-(k+1) 1-var NF of the witness x, but the 2-var existential additionally requires depth-k 3-var quantifier conditions (sub_nf.2). No amount of clever proof can fix the backward direction with the wrong formula.
- **What is needed**: Replace `nf_exist_formula` at depth k+1 with a nested buildRight formula that encodes sub_nf.2 using k+1 levels of Until/Since nesting. At level j, witnesses are characterized by `char_{k+1-j}` formulas. At the bottom level (depth 0), conditions reduce to atoms (predicates + positions). This is a ~400-700 line implementation consisting of: (a) recursive formula definition, (b) forward direction proof, (c) backward direction proof using Prior-UZ/SZ at each nesting level.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder.

**Goal**: Define P2_n(k) for arbitrary arity n >= 2 and prove the base case P2_n(0) for all n. Define the interval-based existence formula that encodes the full NF (atoms + quantifier part) using nested Until/Since chains with buildRight/buildLeft.

**Literature**: Follows the NF structure from Doets 1989 Lemma 1.1 -- base case (disjunctive normal forms over atomic formulas at depth 0) and induction structure (depth k+1 adds quantifier conditions referencing depth-k NFs with one more variable, the extra variable being consumed by quantification). Uses Rabinovich 2014 Section 5 Notation 5.2 (bracket notation for interval patterns) and Proposition 3.5 (Until/Since encoding) for the temporal formula structure.

**Tasks**:
- [ ] In `Kamp/NegationClosure.lean`, define `P2_gen atomMap k n` for n >= 2: for each depth-k arity-n NF, the existential "exists x, nf_eval_nf M k n (Fin.cons x vars) sub_nf" has a temporal equivalent conditioned on the parent variables' atom assignments. This uses the NF structure from Doets 1989 Lemma 1.1 (finiteness of rank-k n-variable types) but proves a stronger result (temporal expressibility on Prior structures, not just finiteness).
- [ ] Define `nf_exist_formula_interval`: the interval-based temporal formula replacing `nf_exist_formula` at depth k+1. The formula is a temporal encoding (via Prop 3.5 Until/Since translation) of the interval pattern from Rabinovich Section 5 Notation 5.2:
  - For the Until case (sub_nf says t < x, corresponding to z_0 < z_1 in Notation 5.2): encode sub_nf.2 by partitioning sub-sub-NFs ssn by the order of the new variable y relative to x and t:
    - y > x or y = x: conditions absorbed into nf_x compatibility (endpoint types)
    - y in (t,x): interval witnesses, encoded as nested Until chain following the bracket notation [alpha_0, beta_1, alpha_1, ..., beta_n, alpha_n](z_0, z_1) from Notation 5.2, translated to temporal formulas via buildRight (Prop 3.5)
    - y = t or y < t: conditions absorbed into parent atom compatibility
  - Construct nested Until chains for positive interval witnesses using buildRight (Rabinovich Prop 3.5, already proved in Translation.lean as buildRight_correct)
  - Guards for negative interval conditions: forall y in (t,x), not char_k(tau_forbidden)(y) -- the interval types beta_j from Notation 5.2
  - Take disjunction over compatible nf_x values and orderings of positive interval witnesses (finitely many since NF types are finite by Doets Lemma 1.1)
- [ ] Prove `P2_gen_base`: P2_n(0) for all n >= 2. At depth 0, all arities reduce to pure atom assignment + order (Doets base case), so the existing nf_exist_formula pattern works (no quantifier conditions to encode).
- [ ] Verify the arity chain structure compiles: P2_2(k+1) depends on P2_3(k), P2_3(k) on P2_4(k-1), etc., terminating at P2_{k+3}(0). This chain reflects the NormalForm structure: NF(k+1, n) has a quantifier part NF(k, n+1) -> Bool. In Doets's terms, rank-(k+1) formulas in n free variables are DNFs over "forall x phi" and "exists x phi" where phi has rank k in n+1 variables (the extra variable being consumed by quantification).

**Timing**: 4 hours (~200 lines: type definitions, formula construction, base case proofs)

**Depends on**: none (existing infrastructure in Translation.lean and NegationClosure.lean)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure.lean` -- add P2_gen, nf_exist_formula_interval, base cases

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NegationClosure` succeeds
- Base case P2_n(0) sorry-free for all n

---

### Phase 4: P2_n(k+1) Forward Direction [NOT STARTED]

**Goal**: Prove the forward direction of P2_n(k+1): if the existential holds (there exists a witness x with the correct arity-n NF), then the interval-based formula evaluates to true.

**Literature**: The forward direction corresponds to showing that a concrete interval decomposition (the witness configuration) satisfies the temporal formula. Given witnesses x_0 < ... < x_n with the right types, the nested Until/Since chain evaluates to true by construction (Rabinovich Proposition 3.5, buildRight_correct/buildLeft_correct from Translation.lean). This is straightforward and does not require the negation closure machinery from Section 5.

**Tasks**:
- [ ] Prove `nf_exist_formula_interval_forward`: given a witness x with nf_eval_nf M (k+1) n (Fin.cons x vars) sub_nf = true, show the interval formula holds at the evaluation point. This follows the pattern of `nf_exist_formula_forward` but additionally:
  - Extracts the quantifier conditions from sub_nf.2 (which sub-sub-NFs are realized)
  - For each positive interval condition (sub-sub-NF ssn with sub_nf.2(ssn) = true and y in the interval), uses the model-level witness y to show the corresponding buildRight/buildLeft chain holds (Prop 3.5 + buildRight_correct from Translation.lean)
  - For negative interval conditions (sub_nf.2(ssn) = false), shows the forbidden type is absent from the interval -- the interval guard from Notation 5.2
  - Uses P1(k+1) char formulas (from the inductive hypothesis) to characterize witness types at the formula level
- [ ] Verify the forward direction composes correctly with the arity chain: forward at arity n uses P2_{n+1}(k) forward (inductive hypothesis from lower depth) for the sub-sub-NF conditions

**Timing**: 3 hours (~150 lines)

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure.lean` -- add forward direction proof

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NegationClosure` succeeds
- Forward direction sorry-free

---

### Phase 5: P2_n(k+1) Backward Direction [NOT STARTED]

**Goal**: Prove the backward direction of P2_n(k+1): if the interval-based formula evaluates to true, then the existential holds. This is the core content corresponding to Rabinovich's proof of Proposition 4.2 (negation closure for 2-free-variable EF formulas), and the hardest phase.

**Literature**: This phase uses the proof techniques from Rabinovich 2014 Section 5, specialized to Prior structures. The relevant results from Section 5:
- **Lemma 5.3** (base case: all beta_i = True): Proved by induction on n using the infimum construction -- "let r_0 = inf{z in (z_0, z_1) | P_1(z)}" with the INF formula (Notation 5.2). On Prior structures, this simplifies because first occurrences are ATTAINED (Prior-UZ), so r_0 satisfies P_1 directly (no K+ disjunct needed). Our formalization uses the guard formula (forall y in interval, not P(y)) to encode the absence conditions that Lemma 5.3 establishes.
- **Corollary 5.4** (bounded existential): Defines F_n := alpha_n, F_{i-1} := alpha_{i-1} AND (beta_i Until F_i), reducing bounded existentials to TL formulas via buildRight. This is the template for how our interval formula chains nested Until operators.
- **Lemma 5.1** (full negation closure): 3-case decomposition on which sub-interval condition fails (Case 1: endpoint failure, Case 2: guard succeeds but no witness, Case 3: guard fails at some interior point). The backward direction of our formula corresponds to showing that when the formula holds, the interval witnesses extracted from the Until chain satisfy the full NF conditions.
- The composition intuition (Libkin 2004 Lemma 3.7 / Feferman-Vaught): inserting a new point z splits the interval, and the rank-k types of sub-intervals determine the rank-(k-1) type of the whole. This motivates the arity chain but is not directly applied in the proof.

**Tasks**:
- [ ] Prove `nf_exist_formula_interval_backward`: given formula truth, extract witnesses and show the full arity-n NF is satisfied. Decompose by order case:
  - **Until case** (t < x): Follows the interval pattern of Rabinovich Section 5 with z_0 = t, z_1 = x. The formula is a disjunction over compatible nf_x values and orderings (Notation 5.2: alpha_i at witness points, beta_j along sub-intervals). From the satisfied disjunct, extract: (a) the main witness x via the outermost Until, (b) interval witnesses y_1, ..., y_m from nested Until chains (corresponding to the existentially chosen points x_0 < ... < x_n in Notation 5.2), (c) verify atom assignments from P1(k+1) characterizations. Use Prior-UZ (`semantic_prior_UZ`) to guarantee attained first occurrences (as in Lemma 5.3, but with the infimum always attained on Prior structures). Show all sub-sub-NF conditions of sub_nf.2 are met: non-interval conditions from nf_x compatibility, positive interval conditions from extracted witnesses, negative interval conditions from the guard.
  - **Since case** (x < t): Symmetric using buildLeft and `semantic_prior_SZ`. Same structure as Until with reversed order.
  - **Identity case** (x = t): No interval conditions; reduces to atom + quantifier matching.
- [ ] The backward direction at arity n uses P2_{n+1}(k) backward (lower depth, higher arity) to handle the sub-sub-NF conditions involving interval witnesses. This is where the arity chain terminates: each quantifier condition at depth k+1 with n variables references NFs at depth k with n+1 variables (the extra variable being the interval witness, consumed by the existential quantifier).
- [ ] Key lemma: `interval_decomposition` -- given the formula's nested Until chain, decompose the interval (t, x) into segments with witnesses at the right positions, each satisfying their characterization formula. Use Prior-UZ/SZ to ensure gap-free placement. This follows Rabinovich's bracket notation decomposition: [alpha_0, beta_1, ..., beta_n, alpha_n](z_0, z_1) with z_0 = t, z_1 = x.

**Timing**: 6 hours (~300 lines: ~120 Until case, ~120 Since case, ~30 identity case, ~30 integration)

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure.lean` -- add backward direction proof

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NegationClosure` succeeds
- Backward direction sorry-free
- `lean_verify` on the backward lemma shows no sorryAx

---

### Phase 6: Integration into Master Induction [NOT STARTED]

**Goal**: Wire the generalized P2_n(k) into the existing master_induction structure, replacing both the formula and the sorry in the k+1 case. Fill the downstream sorries in NfCharFormula.lean and KampPrior.lean.

**Tasks**:
- [ ] In NegationClosure.lean, replace `nf_exist_formula` at line 399 with `nf_exist_formula_interval` in the P2(k+1) case of master_induction. The current formula is the WRONG formula (it omits sub_nf.2); the sorry at line 404 is unprovable with it. Both the formula and its backward proof must be replaced together.
- [ ] Replace the `sorry` at NegationClosure.lean:404 with the P2_2(k+1) backward proof, extracting it from the generalized P2_gen induction. The existing master_induction P2 is exactly P2_gen at arity 2; wire the generalized backward direction.
- [ ] Replace the sorry in NfCharFormula.lean:572 (`nf_2var_exist_formula_prior`) with `nf_2var_exist_formula_prior_fill` from NegationClosure.lean (already wired, becomes sorry-free once master_induction is sorry-free).
- [ ] Fill the sorry in KampPrior.lean:149 (`nf_characterizable_temporal_prior` k+1 case) via the `nf_to_formula`/`nf_to_formula_correct` bridge (~10 lines).
- [ ] Run `lake build` (scoped to Kamp modules).

**Timing**: 2 hours (~50 lines of wiring + verification)

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure.lean` -- replace sorry with proof
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfCharFormula.lean` -- fill sorry (~10 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- fill sorry (~10 lines)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NegationClosure` succeeds with 0 sorries
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfCharFormula` succeeds with 0 sorries
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior` succeeds with 0 sorries

---

### Phase 7: Full Build Verification and Documentation [NOT STARTED]

**Goal**: Verify the entire chain is sorry-free end-to-end. Update ROADMAP.md with completion status.

**Tasks**:
- [ ] Run `lake build` (full project build)
- [ ] Verify `#print axioms US_expressively_complete_over_prior` shows no sorryAx
- [ ] Verify `#print axioms kamp_prior_expressive_completeness` shows no sorryAx
- [ ] Verify `#print axioms gap_prior_UZ_contradiction` shows no Stavi chain dependency
- [ ] Verify downstream consumers compile: GoodStructuresModelSurgery, no_gaps_discrete_model_surgery
- [ ] Update ROADMAP.md: mark Stavi chain bypass complete
- [ ] Add docstring to StaviCompleteness.lean noting the sorry chain is fully bypassed via Kamp/Rabinovich

**Timing**: 2 hours (mostly verification and documentation)

**Depends on**: 6

**Files to modify**:
- `specs/ROADMAP.md` -- update completion status
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` -- documentation update

**Verification**:
- `lake build` succeeds (full project, clean, zero sorry warnings)
- `#print axioms US_expressively_complete_over_prior` shows no sorryAx
- `#print axioms kamp_prior_expressive_completeness` shows no sorryAx
- Type signature of `US_expressively_complete_over_prior` unchanged
- All downstream consumers compile

---

## Testing & Validation

- [ ] Phase 3: P2_n(0) base case sorry-free for all n
- [ ] Phase 4: Forward direction sorry-free
- [ ] Phase 5: Backward direction sorry-free; `lean_verify` shows no sorryAx
- [ ] Phase 6: `lean_verify nf_2var_exist_formula_prior_fill` shows no sorryAx
- [ ] Phase 6: `lean_verify nf_characterizable_temporal_prior` shows no sorryAx
- [ ] Phase 7: `lake build` -- full project, zero errors
- [ ] Phase 7: `#print axioms US_expressively_complete_over_prior` -- no sorryAx
- [ ] Phase 7: `#print axioms gap_prior_UZ_contradiction` -- no Stavi chain dependency

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Translation.lean` -- buildRight/buildLeft correctness (Phase 1, COMPLETED, ~500 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorINF.lean` -- Prior first/last occurrence lemmas (Phase 2, COMPLETED, ~250 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfCharFormula.lean` -- NF characteristic formula construction (Phase 2, COMPLETED + Phase 6 sorry fill, ~250 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure.lean` -- P2_gen, interval formula, forward+backward proofs (Phases 3-6, ~750 lines new)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- sorry fill (~10 lines, Phase 6)

**Estimated new Lean code (Phases 3-7)**: ~750 lines in NegationClosure.lean + ~20 lines sorry fills

## Rollback/Contingency

**If the arity generalization is too complex**:
1. Try Prior-specific simplification: on Prior structures, first occurrences are ATTAINED (K+ disjunct vacuous). This eliminates half the case analysis in the interval decomposition. Implement the Prior-only version first, then generalize if time permits.

**If the backward direction blocks at a specific case**:
1. Mark Phase 5 [PARTIAL] with sorry stubs at the specific case (Until/Since/identity).
2. The forward direction (Phase 4) and base cases (Phase 3) are independently valuable.
3. Allow splitting Phase 5 into sub-dispatches (5a: Until, 5b: Since, 5c: identity).

**If the approach fails entirely**:
1. The existing code in NegationClosure.lean (393 lines) has value: P1(0)/P2(0) sorry-free, P1(k+1) sorry-free, P2(k+1) forward sorry-free.
2. Fall back to Path B from report 08: GHR-faithful adjacent-pair 2-var NF master lemma.
3. Translation.lean, PriorINF.lean remain reusable regardless of approach.
