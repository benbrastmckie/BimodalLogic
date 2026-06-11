# Implementation Plan: Nested buildRight Formula for P2(k+1) Backward Direction (v20)

- **Task**: 273 - chronicle_gap_contradiction_proof
- **Status**: [IMPLEMENTING]
- **Effort**: 16 hours
- **Dependencies**: Plan v18 phases 1-2 (COMPLETED), plan v19 phase 3 partial (P1/P2 base + P1(k+1) + P2(k+1) forward sorry-free)
- **Research Inputs**:
  - specs/273_chronicle_gap_contradiction_proof/reports/08_team-research.md
  - specs/273_chronicle_gap_contradiction_proof/reports/09_negation-closure-research.md
  - specs/273_chronicle_gap_contradiction_proof/handoffs/phase-3-handoff-20260611f.md
  - specs/273_chronicle_gap_contradiction_proof/handoffs/phase-3-handoff-20260611g.md
- **Artifacts**: plans/20_nested-buildright-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4

## Overview

Replace the unprovable `nf_exist_formula` backward direction at depth k+1 (NegationClosure.lean:427) with a **nested buildRight formula** that encodes the full 2-var NF `sub_nf` -- including its quantifier part `sub_nf.2` -- using k+1 levels of Until/Since nesting. The current formula encodes only atom compatibility and the depth-(k+1) 1-var NF of witness x, which is insufficient because the 2-var NF is not determined by the 1-var NFs of endpoints alone (proved false at all depths >= 1 in handoff 20260611g).

Plan v19's P2_n arity generalization approach has been ruled out due to a type-level flaw: temporal formulas are 1-variable objects evaluated at a single point, so P2 for n > 1 parent variables cannot directly produce a temporal formula. The nested buildRight design avoids this by encoding multi-variable quantifier conditions as nested temporal operators within a single-variable formula.

### Literature Alignment

The nested buildRight formula implements a Prior-structure specialization of Rabinovich 2014. The mapping is:

| This plan | Rabinovich 2014 | Notes |
|-----------|-----------------|-------|
| Nested buildRight formula definition | Notation 5.2 (bracket notation) + Prop 3.5 (temporal translation) | Bracket notation [alpha_0, beta_1, ..., beta_n, alpha_n](z_0, z_1) encodes interval patterns; Prop 3.5 converts to nested Until/Since |
| Per-level forward lemma | Prop 3.5 correctness (witnesses -> formula) | Straightforward: given interval decomposition, the nested Until/Since chain holds |
| Per-level backward lemma | Section 5 proof machinery: Lemma 5.1 (3-case decomposition), Lemma 5.3 (infimum/base case), Corollary 5.4 (bounded existential reduction) | On Prior structures, first occurrences are ATTAINED (Prior-UZ/SZ), eliminating the K+ disjunct from INF formula (Notation 5.2). This simplifies Lemma 5.3 -- the infimum is always an actual point, not a limit |
| Depth-0 base case | Immediate: at depth 0, all n-var NFs are atoms (predicates + positions) | No quantifier conditions to encode; existing `nf_exist_formula` suffices |
| Recursive nesting structure | Prop 4.3 structural induction + Lemma 3.2 (closure properties) | The depth-(k+1) quantifier part sub_nf.2 : NF(k, 3) -> Bool references 3-var NFs at depth k. Each 3-var NF's quantifier part references 4-var NFs at depth k-1, etc. The recursion terminates at depth 0 |

**Prior-structure simplifications** (explicit deviations from Rabinovich's general argument):
1. **Attained first occurrences**: Prior-UZ/SZ guarantee that first occurrences are actual points, not limits. This eliminates the K+(P) disjunct from INF(z_0, r_0, z_1, P) in Notation 5.2. Rabinovich's Lemma 5.3 must handle the case where inf{z | P(z)} is a limit point (P holds at K+(P)(r_0) but not at r_0); on Prior structures this case is vacuous.
2. **No Dedekind completeness needed**: The INF/SUP construction (Lemma 5.3) requires Dedekind completeness on general chains. Prior structures satisfy a stronger property: every temporal formula has an attained first occurrence or no occurrence at all. This means the `semantic_prior_UZ` and `semantic_prior_SZ` hypotheses subsume the Dedekind completeness requirement for our specific use.
3. **Negation closure scope**: Rabinovich proves Prop 4.2 for 2-free-variable exists-forall formulas over all Dedekind-complete chains. We only need closure for the specific formula `nf_exist_formula_nested` on Prior structures. The 3-case decomposition (Lemma 5.1) still applies structurally, but Case 1 (endpoint failure) and Case 3 (guard failure) simplify because first occurrences are attained.

### Research Integration

- Handoff phase-3-handoff-20260611g.md: Root cause confirmed -- nf_exist_formula omits sub_nf.2; three alternative approaches (NF-transfer, classical existence, P2_n generalization) all ruled out. Validated nested buildRight design with ~450 line estimate.
- Handoff phase-3-handoff-20260611f.md: Earlier analysis confirming composition theorem is FALSE at depth k >= 1; interval-based formula approach first proposed.
- Report 09 (negation-closure-research): Phased decomposition strategy, nf_to_formula bridge.
- Report 08 (team-research): Path A (Rabinovich) validated as primary approach; sorry 3 confirmed FALSE as stated.

## Goals & Non-Goals

**Goals**:
- Define a recursive nested buildRight formula `nf_exist_formula_nested` that encodes the full sub_nf (atoms + quantifier part sub_nf.2) using k+1 levels of Until/Since nesting
- Prove forward direction: existential witnesses -> formula truth (at each nesting level)
- Prove backward direction: formula truth -> existential (using Prior-UZ/SZ at each nesting level)
- Replace the formula and sorry at NegationClosure.lean:423-427 with the nested formula and its biconditional proof
- Fill the downstream sorry in NfCharFormula.lean:572 (nf_2var_exist_formula_prior)
- Fill the sorry in KampPrior.lean:149 (nf_characterizable_temporal_prior k+1)
- Achieve sorry_count=0 for `US_expressively_complete_over_prior` and `kamp_prior_expressive_completeness`

**Non-Goals**:
- VEF closure lemmas (closed_conj, closed_ex) -- bypassed by NfCharFormula approach
- Dedekind-complete instantiation of HasDefinableINF/SUP -- not needed for Prior structures
- General Kamp theorem for non-Prior structures
- Modifying type signatures of US_expressively_complete_over_prior or kamp_prior_expressive_completeness
- P2_n arity generalization (ruled out; nested buildRight supersedes it)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Recursive formula definition encounters Lean termination checker issues (nested Nat.rec on both depth and nesting level) | H | M | Use well-founded recursion on (k - j) where j is the nesting level. The nesting depth decreases from k+1 to 0. Alternatively, define as a mutual/nested induction with explicit fuel parameter. |
| Backward direction at a single nesting level is harder than estimated (extracting witnesses from nested Until chains is non-trivial) | H | M | Budget 200 lines for backward. Allow splitting into sub-dispatches per nesting level. The key simplification is Prior-UZ/SZ: first occurrences are attained, so the Until witness is an actual point. |
| Encoding sub_nf.2 entries as interval conditions creates combinatorial explosion (finitely many sub-sub-NFs, each requiring a nested chain) | M | M | Take disjunction over all compatible type assignments and orderings. Finiteness is guaranteed by Doets Lemma 1.1 (finitely many NFs at each depth/arity). Use `Fintype.elems` enumeration as in existing code. |
| Type-level mismatch between nested formula and master_induction's P2 signature | L | L | The nested formula still produces a single temporal Formula evaluated at point t, matching P2's signature exactly. The nesting is internal to the formula structure. |
| Interaction with existing nf_exist_formula_forward' breaks when formula changes | L | H | The forward direction proof must be rewritten for the new formula. The existing forward proof is not reusable. Budget time for this. |

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

### Phase 3: Nested buildRight Formula Definition [NOT STARTED]

**Goal**: Define the recursive function `nf_exist_formula_nested` that builds a k+1-level nested Until/Since formula encoding the full sub_nf (atoms + quantifier part sub_nf.2). This replaces `nf_exist_formula` from NfCharFormula.lean at depth k+1.

**Literature**: The formula implements a Prior-specialized version of Rabinovich's bracket notation (Notation 5.2) composed with the temporal translation (Prop 3.5). At level j (j = 0, ..., k), the formula places witnesses characterized by `char_{k+1-j}` formulas. At level k (the bottom), all conditions reduce to atoms (depth-0 NFs are determined by predicates and positions).

**Lemma-to-literature mapping**:

| Lean definition | Literature counterpart |
|-----------------|----------------------|
| `nf_exist_formula_nested atomMap h_surj k char_functions sub_nf` | Rabinovich Notation 5.2 [alpha_0, beta_1, ..., alpha_n](z_0, z_1) composed with Prop 3.5 temporal translation |
| Level-0 encoding (main witness x via Until/Since) | Prop 3.5: z_k position determines Until vs Since chain direction |
| Level-j encoding (interval witnesses at depth k+1-j) | Notation 5.2 bracket entries: alpha_i at witness points, beta_j along sub-intervals |
| Bottom-level (depth 0) atom encoding | Doets 1989 Lemma 1.1 base case: depth-0 NFs are pure atom assignments |

**Tasks**:
- [ ] Define a helper `nf_sub_conditions` that, given `sub_nf : NormalForm sig (k+1) 2`, extracts which sub-sub-NFs `ssn : NormalForm sig k 3` satisfy `sub_nf.2 ssn = true` and classifies each by the order of the third variable relative to the two parent variables (in the interval (t,x), at x, beyond x, at t, before t). This classification corresponds to the interval decomposition in Rabinovich Notation 5.2.
- [ ] Define `nf_exist_formula_nested` recursively on the nesting level:
  - **Base (nesting level = 0, depth = 0)**: Use the existing `nf_exist_formula` pattern -- atom compatibility + order direction (Until/Since/equality). At depth 0, sub_nf.2 is trivially empty (NormalForm sig 0 n has no quantifier part for the degenerate case), so no nesting is needed.
  - **Recursive (nesting level j+1, depth d+1)**: For the Until case (t < x), the formula is a disjunction over compatible nf_x values of:
    - `char_{d+1}(nf_x)` -- characterizes the witness x (from the IH P1)
    - AND a conjunction encoding sub_nf.2: for each ssn with sub_nf.2(ssn) = true and the interval witness y in (t, x): a nested Until formula placing y with `char_d(nf_y)` and recursively encoding ssn's quantifier part at nesting level j
    - AND for each ssn with sub_nf.2(ssn) = true but y outside the interval: conditions absorbed into nf_x or parent atom compatibility
    - AND guards for negative conditions: for each ssn with sub_nf.2(ssn) = false and y in (t, x): a Box(not char_d(nf_y)) guard (the beta_j from Notation 5.2 encoding forbidden types)
    - Wrapped in `Until(guard, event)` where event captures x and guard captures the interval conditions
  - The Since case is symmetric with buildLeft.
  - The identity case (x = t) has no interval, so only endpoint conditions apply.
- [ ] Verify the formula definition compiles and the recursion terminates. The nesting level decreases at each recursive call (from k+1 to 0), providing well-foundedness.
- [ ] Add docstring citing Rabinovich Notation 5.2 and Prop 3.5.

**Timing**: 4 hours (~120 lines: type analysis, recursive formula construction, order case splits)

**Depends on**: none (uses existing infrastructure from Translation.lean and NfCharFormula.lean)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure.lean` -- add nf_exist_formula_nested definition

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NegationClosure` succeeds (formula definition compiles)
- No new sorries introduced

---

### Phase 4: Forward Direction (Witnesses to Formula) [NOT STARTED]

**Goal**: Prove the forward direction of the nested buildRight formula: if there exists a witness x with the correct depth-(k+1) 2-var NF (including sub_nf.2), then the nested formula evaluates to true.

**Literature**: The forward direction is the "easy" direction corresponding to Rabinovich Prop 3.5 correctness. Given a concrete interval decomposition (witness configuration), the nested Until/Since chain holds by construction. This does not require the Section 5 negation closure machinery.

**Lemma-to-literature mapping**:

| Lean lemma | Literature counterpart |
|------------|----------------------|
| `nf_exist_formula_nested_forward` | Rabinovich Prop 3.5 (exists-forall formula -> temporal formula, given witnesses) |
| Per-level witness extraction | Direct: the model provides actual witnesses at each level |
| `buildRight_correct` (from Translation.lean) | Prop 3.5 Until chain correctness (already proved) |

**Tasks**:
- [ ] Prove `nf_exist_formula_nested_forward`: given `h_ex : exists x, nf_eval_nf M (k+1) 2 (Fin.cons x (fun _ => t)) sub_nf`, show the nested formula holds at t.
  - Extract witness x from h_ex.
  - From nf_eval_nf, obtain: atom compatibility of x with sub_nf, order relation between x and t, depth-(k+1) 1-var NF of x, and the quantifier conditions sub_nf.2.
  - For the main level (level 0): char_kp1(nf_x) holds at x (by P1(k+1) correctness). The Until/Since chain holds because x is a witness in the correct direction.
  - For each positive quantifier condition ssn with sub_nf.2(ssn) = true: from the model, there exists a witness y realizing ssn. If y is in the interval (t,x), the nested Until chain at level 1 holds using y. Use char_k(nf_y) correctness from P1(k) IH.
  - Recurse: at each deeper level j, the model provides witnesses for the deeper quantifier conditions. By induction on the nesting level, the nested chain holds.
  - For negative conditions: from nf_eval_nf with sub_nf.2(ssn) = false, no witness y exists with the forbidden type. The guard (Box not char_d(nf_y)) holds vacuously.
- [ ] The proof proceeds by induction on the nesting level (k+1 to 0), using `buildRight_correct` / `buildLeft_correct` from Translation.lean at each level.

**Timing**: 3 hours (~100 lines)

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure.lean` -- add forward direction proof

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NegationClosure` succeeds
- Forward direction sorry-free

---

### Phase 5: Backward Direction (Formula to Witnesses) [NOT STARTED]

**Goal**: Prove the backward direction: if the nested formula evaluates to true, then there exists a witness x with the correct depth-(k+1) 2-var NF. This is the hard direction, corresponding to the proof of Rabinovich Prop 4.2 via Section 5 machinery, specialized to Prior structures.

**Literature**: This phase uses the following results from Rabinovich 2014 Section 5, adapted for Prior structures:

| Lean lemma | Literature counterpart | Prior simplification |
|------------|----------------------|---------------------|
| `nf_exist_formula_nested_backward` | Section 5: proof of Prop 4.2 (negation closure) | Overall argument structure |
| Witness extraction from Until chain | Corollary 5.4: F_{i-1} := alpha_{i-1} AND (beta_i Until F_i) defines the chain | Unchanged from Rabinovich |
| First-occurrence extraction | Lemma 5.3: infimum construction r_0 = inf{z in (z_0, z_1) \| P_1(z)} using INF formula | Prior-UZ guarantees r_0 satisfies P_1 directly (attained first occurrence). The K+ disjunct in INF(z_0, r_0, z_1, P_1) is vacuous. |
| Interval decomposition | Lemma 5.1: 3-case decomposition (endpoint failure / guard success / guard failure) | Cases 1 and 3 simplify because first occurrences are attained |
| Recursive NF determination | Induction on nesting level: at level j, the (k+2-j)-var NF is determined by (a) the witness's depth-j 1-var NF from char_j, (b) the witness's position from buildRight, (c) deeper levels j+1..k | This is the novel argument specific to our NF architecture. The mathematical content follows Rabinovich's composition structure (inserting a point splits intervals, sub-interval types compose) but the formal statement uses our NF predicates |
| Depth-0 termination | At nesting level k (depth 0): the (k+2)-var NF is determined by predicates + positions (atoms only, no quantifier conditions) | Unchanged: Doets 1989 base case |

**Tasks**:
- [ ] Prove `nf_exist_formula_nested_backward`: given formula truth, extract witnesses and verify the full 2-var NF.
  - **Until case** (t < x, corresponding to z_0 < z_1 in Rabinovich):
    - From the outermost Until, extract the main witness x satisfying `char_kp1(nf_x)` (the event formula). By P1(k+1) correctness, x has the correct depth-(k+1) 1-var NF.
    - From the guard of the Until, x is the first occurrence of char_kp1(nf_x) after t (uses `semantic_prior_UZ` -- this is where Lemma 5.3's infimum construction is applied, simplified by Prior structure's attained first occurrences).
    - From the nested Until chains (level 1..k), extract interval witnesses y_1, ..., y_m in (t, x). Each y_i satisfies `char_{k}(nf_{y_i})`, giving its depth-k 1-var NF. The position of each y_i (order relative to t and x) is determined by the buildRight structure (Corollary 5.4).
    - Show atom compatibility: the atom assignments of x and the interval witnesses match sub_nf's atom part. This follows from the char formula correctness and the disjunct selection.
    - Show quantifier compatibility: for each ssn with sub_nf.2(ssn) = true:
      - If ssn places y in (t, x): one of the extracted interval witnesses y_i realizes ssn. The witness's 1-var NF is correct (from char_k), and the deeper quantifier conditions of ssn are verified recursively at nesting level j+1.
      - If ssn places y outside (t, x): absorbed into nf_x or parent compatibility (these conditions are encoded in the outermost event formula and the parent atom hypothesis).
    - Show negative conditions: for each ssn with sub_nf.2(ssn) = false and y in (t, x): the guard formula (Box not char_d(nf_y)) ensures no witness y exists in (t, x) with the forbidden type. This establishes sub_nf.2(ssn) = false directly.
    - Conclude: all components of nf_eval_nf M (k+1) 2 (Fin.cons x (fun _ => t)) sub_nf are satisfied.
  - **Since case** (x < t): Symmetric to Until using buildLeft and `semantic_prior_SZ`.
  - **Identity case** (x = t): No interval. Endpoint conditions only. Straightforward.
- [ ] Key auxiliary lemma: `nested_chain_witness_extraction` -- given a satisfied nested Until chain of depth j, extract the j witnesses and verify their characterization formulas hold. This is a direct induction on j, using `buildRight_correct` at each level. Corresponds to Corollary 5.4's recursive unfolding.
- [ ] Key auxiliary lemma: `nf_from_witnesses_and_positions` -- given witnesses at positions with known 1-var NFs and known relative order, determine the multi-variable NF. At depth 0 this is immediate (atoms only). At depth d+1, the quantifier part is determined by the deeper nesting levels. This is the formal content of the "recursive NF determination" argument from handoff 20260611g. Corresponds to Rabinovich's composition structure where inserting a point into an interval decomposes it (Lemma 5.1, A_i^- and A_i^+ splitting).

**Timing**: 5 hours (~200 lines: ~80 Until case, ~80 Since case, ~20 identity case, ~20 auxiliary lemmas)

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure.lean` -- add backward direction proof and auxiliary lemmas

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NegationClosure` succeeds
- Backward direction sorry-free
- `lean_verify` on the backward lemma shows no sorryAx

---

### Phase 6: Integration into Master Induction and Downstream Closure [NOT STARTED]

**Goal**: Wire the nested buildRight formula into master_induction, replacing the sorry at NegationClosure.lean:427. Fill downstream sorries in NfCharFormula.lean and KampPrior.lean.

**Tasks**:
- [ ] In NegationClosure.lean, replace the formula at line 423 (`nf_exist_formula atomMap h_surj (k + 1) char_kp1 parent_atoms sub_nf`) with `nf_exist_formula_nested atomMap h_surj k char_kp1 char_k parent_atoms sub_nf` (the nested formula built in Phase 3).
- [ ] Replace the `sorry` at line 427 with the backward direction proof from Phase 5, instantiated at the master_induction context. The proof receives `h_formula` (formula truth) and produces `exists x, nf_eval_nf M (k+1) 2 (Fin.cons x (fun _ => t)) sub_nf`.
- [ ] Replace the forward direction call at line 428-429 with `nf_exist_formula_nested_forward` from Phase 4.
- [ ] Fill the sorry in NfCharFormula.lean:572 (`nf_2var_exist_formula_prior`): this closes automatically once master_induction is sorry-free, because `nf_2var_exist_formula_prior_fill` at NegationClosure.lean:436-451 extracts P2 from master_induction.
- [ ] Fill the sorry in KampPrior.lean:149 (`nf_characterizable_temporal_prior` k+1 case): use the `nf_to_formula` / `nf_to_formula_correct` bridge. With master_induction sorry-free, `nf_2var_exist_formula_prior_fill` provides the needed existential, and the ~10-line bridge converts it to the `nf_characterizable_temporal_prior` signature.
- [ ] Run scoped build to verify each file compiles sorry-free.

**Timing**: 2 hours (~50 lines of wiring + verification)

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure.lean` -- replace formula + sorry with nested formula + proof
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfCharFormula.lean` -- fill sorry at line 572 (~10 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- fill sorry at line 149 (~10 lines)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NegationClosure` succeeds with 0 sorries
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfCharFormula` succeeds with 0 sorries
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior` succeeds with 0 sorries

---

### Phase 7: Full Build Verification and Documentation [NOT STARTED]

**Goal**: Verify the entire chain is sorry-free end-to-end. Confirm no regressions in downstream consumers.

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

## Lemma-to-Literature Mapping (Complete)

| Lean lemma / definition | Literature source | Section/Prop | Notes |
|--------------------------|-------------------|--------------|-------|
| `nf_exist_formula_nested` | Rabinovich 2014 | Notation 5.2 + Prop 3.5 | Bracket notation composed with temporal translation; Prior-specialized (no K+ disjunct) |
| `nf_exist_formula_nested_forward` | Rabinovich 2014 | Prop 3.5 correctness | Given witnesses, nested Until/Since chain holds |
| `nf_exist_formula_nested_backward` | Rabinovich 2014 | Section 5 (Lemma 5.1, 5.3, Cor 5.4) | Extract witnesses from formula truth; Prior-UZ/SZ for attained first occurrences |
| `nested_chain_witness_extraction` | Rabinovich 2014 | Corollary 5.4 | F_{i-1} := alpha_{i-1} AND (beta_i Until F_i) unfolding |
| `nf_from_witnesses_and_positions` | Rabinovich 2014 + Doets 1989 | Lemma 5.1 (composition) + Lemma 1.1 (NF base) | NF determined by 1-var NFs + positions; depth-0 base case is atoms only |
| `nf_char_kp1_from_2var` (existing) | Rabinovich 2014 | Prop 4.3 (induction step) | P1(k+1) from P1(k) + P2(k); already sorry-free |
| `buildRight_correct` (existing) | Rabinovich 2014 | Prop 3.5 (right chain) | Already proved in Translation.lean |
| `buildLeft_correct` (existing) | Rabinovich 2014 | Prop 3.5 (left chain) | Already proved in Translation.lean |
| `translateEF1_correct` (existing) | Rabinovich 2014 | Prop 3.5 (full biconditional) | Already proved in Translation.lean |
| Depth-0 base (all arities) | Doets 1989 | Lemma 1.1 base case | Depth-0 NFs are atoms; no quantifier conditions |

## Testing & Validation

- [ ] Phase 3: Nested formula definition compiles, no new sorries
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
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure.lean` -- nested buildRight formula, forward+backward proofs, master_induction integration (Phases 3-6, ~450 lines new)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- sorry fill (~10 lines, Phase 6)

**Estimated new Lean code (Phases 3-7)**: ~450 lines in NegationClosure.lean + ~20 lines sorry fills

## Rollback/Contingency

**If the recursive formula definition is too complex for Lean's termination checker**:
1. Flatten the recursion: define `nf_exist_formula_nested_at_level j k sub_nf char_functions` as a non-recursive function that dispatches based on (k - j). Use explicit pattern matching on Nat rather than well-founded recursion.
2. Alternatively, define the formula as a fold over a list of nesting levels (0..k), building the formula bottom-up.

**If the backward direction blocks at a specific nesting level**:
1. Mark Phase 5 [PARTIAL] with sorry stubs at the specific level.
2. Allow splitting Phase 5 into sub-dispatches: 5a (outermost level -- main witness extraction), 5b (inner levels -- interval witness extraction), 5c (identity case).
3. The forward direction (Phase 4) is independently valuable.

**If the approach fails entirely**:
1. The existing code in NegationClosure.lean (453 lines) retains value: P1(0)/P2(0) sorry-free, P1(k+1) sorry-free, P2(k+1) forward sorry-free.
2. Translation.lean and PriorINF.lean remain reusable regardless of approach.
3. Fall back to Path B from report 08: GHR-faithful adjacent-pair 2-var NF master lemma (would require a different encoding strategy).
