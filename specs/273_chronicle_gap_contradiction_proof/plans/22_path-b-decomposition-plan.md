# Implementation Plan: Path B Decomposition for Kamp's Theorem (v22)

- **Task**: 273 - chronicle_gap_contradiction_proof
- **Status**: [IMPLEMENTING]
- **Effort**: 16 hours
- **Dependencies**: Plans v17-v21 (phases 1-4 COMPLETED, phase 5 BLOCKED on P1/P2 circularity)
- **Research Inputs**:
  - specs/273_chronicle_gap_contradiction_proof/reports/13_team-research.md (primary authority, round 13)
  - specs/273_chronicle_gap_contradiction_proof/reports/12_team-research.md (round 12, confirmed `p2_from_p1_succ` orphaned)
  - specs/273_chronicle_gap_contradiction_proof/reports/11_divergence-audit.md (postmortem constraints)
  - specs/273_chronicle_gap_contradiction_proof/reports/10_literature-transcription.md (literature grounding)
- **Artifacts**: plans/22_path-b-decomposition-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Replaces the BLOCKED Phase 5 from plan v21 with a three-sub-phase Path B architecture based on Rabinovich 2014. The core insight is that the P1/P2 mutual induction circularity (confirmed by both round 12 and round 13 research: `nf_char_kp1_from_2var` uses BOTH directions of P2(k) at lines 270, 272, 286, 289) cannot be resolved by restructuring the existing induction. Instead, Path B sidesteps the induction entirely: Lemma 3.2.2 decomposes n-var EA formulas into conjunctions of 2-var EA formulas (general linear order result), Prop 4.3 proves every FOMLO formula has a V-EA equivalent via structural induction on `MonadicFormula` (Prior-specific), and the bridge wiring closes all three active sorries via Prop 4.3 + Prop 3.5 + `nf_to_formula_correct`. Phases 1-4 from v21 are preserved (all COMPLETED and sorry-free). The definition of done is `lake build` clean with no sorryAx in `US_expressively_complete_over_prior`, `kamp_prior_expressive_completeness`, and `gap_prior_UZ_contradiction`.

### Research Integration

**Round 13** (primary): Confirmed both P2(k) directions used (ruling out two-phase shortcut), discovered `nf_to_formula` bridge already exists (NormalForm.lean:705-719, sorry-free), designed three-layer CSLib-quality architecture (general/Prior/Kamp), estimated 425-580 new lines across VecEADecomposition.lean + Prop43.lean + wiring.

**Round 12**: Confirmed `p2_from_p1_succ` at FoToVecEA.lean:156 is sorry-free but orphaned (nothing imports it). Confirmed `kamp_prior_expressive_completeness` has 6+ callsites in GoodStructuresModelSurgery.lean. Task 273 is prerequisite for task 202.

### Prior Plan Reference

Plan v21 established the complete vec-EA infrastructure (phases 1-4, ~2400 lines, all sorry-free). Phase 5 was BLOCKED due to the P1/P2 circularity -- the full Prop 4.3 structural induction requires Lemma 3.2.2 for the negation case on 3+ free variable formulas, which was not formalized. Key lessons: (1) effort estimates from v21 were accurate for phases 1-4; (2) the `VecEAFormula.holds` gap (no evaluation for general `VecEAFormula m n`) must be addressed before Lemma 3.2.2 can be stated; (3) postmortem constraints from report 11 remain binding.

### Roadmap Alignment

This plan advances the following ROADMAP.md items:
- **Stavi sorry chain**: Close `nf_2var_existential_transfer` root sorry, making `stavi_expressive_completeness` sorry-free
- **Critical path**: Task 273 -> Task 202 (Reynolds bypass) -> sorry-free `completeness_discrete`
- **US_expressively_complete_over_prior**: Depends on `kamp_prior_expressive_completeness` which depends on our three sorry closures

## Goals & Non-Goals

**Goals**:
- Prove Lemma 3.2.2: every n-var EA formula decomposes into conjunction of 2-var EA formulas (general linear order, CSLib-quality)
- Prove Prop 4.3: every FOMLO formula is equivalent to a V-EA formula over Prior structures (structural induction on `MonadicFormula`)
- Close sorry at KampPrior.lean:149 (`nf_characterizable_temporal_prior` k+1 case) via Prop 4.3 + Prop 3.5 + `nf_to_formula_correct`
- Close sorry at NfCharFormula.lean:572 (`nf_2var_exist_formula_prior`) via redirect to filled master_induction
- Mark NegationClosure.lean:1371 (`nf_exist_formula_nested_backward`) as bypassed dead code
- Achieve sorry_count=0 for `US_expressively_complete_over_prior` and `kamp_prior_expressive_completeness`
- Quarantine NfComposition.lean and clean up dead code from the master_induction P2(k+1) path

**Non-Goals**:
- Proving the NF composition lemma (`nf_3var_from_1var_nfs`) -- bypassed (5 failed attempts)
- General Kamp theorem for non-Prior structures (Dedekind complete chains)
- Modifying type signatures of `US_expressively_complete_over_prior` or `kamp_prior_expressive_completeness`
- Rewriting sorry-free code in Translation.lean, PriorINF.lean, VecEAFormula.lean, VecEAClosure.lean, VecEATranslation.lean, NegationClosure5.lean, or NegationClosureProp42.lean
- Removing NfComposition.lean from the build (leave for potential future use, just don't import it)
- Restructuring `master_induction` -- downstream consumers are closed directly

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `VecEAFormula.holds` evaluation function harder than expected | H | M | Start with minimal evaluation (ordered witness sequence + point/interval types), expand incrementally; if needed, use a different formulation of Lemma 3.2.2 directly on `BracketFormula` semantics |
| Lemma 3.2.2 segment decomposition requires complex Fin arithmetic | M | M | Use `segmentBracket` extraction with explicit interval boundaries; keep witness partition implicit from total ordering rather than constructive Fin manipulation |
| Prop 4.3 structural induction arity tracking under quantifiers | M | M | Going under exists increases arity by 1; track explicitly with `MonadicFormula sig (n+1)` and use well-founded recursion on `quantifier_depth` as fallback |
| Bridge wiring from Prop 4.3 to KampPrior.lean:149 requires unexpected type coercions | L | M | The `nf_to_formula` bridge already exists (sorry-free at NormalForm.lean:705-719); `nf_to_formula_correct` provides the exact semantic link needed |
| Dead code at NegationClosure.lean:1371 causes build issues when bypassed | L | L | Mark as bypassed with comment; do not delete the sorry (it's inside `master_induction` which has other sorry-free cases); the downstream consumers bypass it via direct Prop 4.3 application |

## Postmortem Constraints (from Report 11, Section 5)

These are hard rules for all implementers. Each constraint corresponds to a named deflection from the postmortem.

1. **DO NOT attempt NF-to-formula backward proofs by extracting NF data from formula truth** (Deflection 1). The formula encodes 1-var NF of witnesses; recovering the full n-var NF requires composition. Work at the formula level instead.

2. **DO NOT use depth-k characteristic formulas where depth-(k+1) is needed** (Deflection 2). Every witness characterization must use the full depth budget. When in doubt, check the depth index explicitly.

3. **DO NOT encode negative interval conditions as guards that block legitimate witnesses** (Deflection 3). sub_nf.2(ssn)=false means no witness y has the FULL 3-var NF ssn, not that no y has compatible predicates. Negation closure handles this via case analysis, not formula guards.

4. **DO NOT attempt to prove nf_3var_from_1var_nfs or any variant of the witness merging problem** (Deflection 4). The composition lemma is true but requires a game-theoretic argument that has failed 5 times. The Rabinovich approach eliminates the need for it.

5. **DO NOT cycle between formula-level and NF-level fixes** (Deflection 5). This plan commits to the formula-level (Rabinovich) approach exclusively. If a step seems to require NF-level reasoning, re-read the literature reference for the formula-level alternative.

## Lemma-to-Literature Mapping

| Phase | Lean Definition/Lemma | Rabinovich 2014 | Section/Page | Notes |
|-------|----------------------|-----------------|--------------|-------|
| 1 | VecEAFormula (type) | Def 3.1 | p. 3 | Exists-forall formula with ordered witness sequences (DONE) |
| 1 | BracketFormula / VecEA2 | Notation 5.2 | p. 8 | [alpha_0, beta_1, ..., alpha_n](z_0, z_1) (DONE) |
| 2 | vec_ea_closed_disj/conj/exists | Lemma 3.2.1 + 3.4 | pp. 3-4 | V-EA closed under disj, conj, exists (DONE) |
| 3 | bracketBuildRight / VecEA2.translateLeft | Prop 3.5 | p. 4 | V-EA with 1 free var -> TL(U,S) (DONE) |
| 4 | neg_2var_vec_ea | Prop 4.2 | p. 6 | Negation closure for 2-free-variable formulas (DONE) |
| 5a | VecEAFormula.holds | Def 3.1 (semantics) | p. 3 | General evaluation for n-var EA formulas (NEW) |
| 5a | vecEA_decomp_2var | Lemma 3.2.2 | p. 4 | n-var EA -> conjunction of 2-var EA (NEW) |
| 5b | fo_to_vec_ea_prior | Prop 4.3 | p. 6 | FOMLO -> V-EA by structural induction (NEW) |
| 5c | (KampPrior:149 fill) | Theorem 4.4 corollary | p. 6 | NF -> temporal via Prop 4.3 + Prop 3.5 + nf_to_formula_correct (NEW) |
| 5c | (NfCharFormula:572 fill) | (bridge) | -- | Redirect to filled kamp_prior (NEW) |
| 6 | (full build verification) | -- | -- | Quarantine NfComposition, dead code cleanup |

### Preserved Assets (from v21 phases 1-4)

| File | Lines | Status | Content |
|------|-------|--------|---------|
| VecEAFormula.lean | ~600 | SORRY-FREE | VecEAFormula, BracketFormula, VecEA2, VVecEA2 types + evaluation |
| VecEAClosure.lean | ~400 | SORRY-FREE | V-EA closed under disj, conj, exists |
| VecEATranslation.lean | ~350 | SORRY-FREE | bracketBuildRight, VecEA2.translateLeft, Prop 3.5 |
| NegationClosure5.lean | ~800 | SORRY-FREE | Lemma 5.1, 5.3, Corollary 5.4 (Section 5 machinery) |
| NegationClosureProp42.lean | ~350 | SORRY-FREE | Prop 4.2 negation closure for 2-var V-EA |
| FoToVecEA.lean | ~200 | SORRY-FREE | p2_from_p1_succ, nf_exist_iff_char_quant, nf_exist_iff_nf1_disjunction |
| Translation.lean | ~337 | SORRY-FREE | buildRight/buildLeft = Prop 3.5 temporal translation |
| PriorINF.lean | ~194 | SORRY-FREE | Prior first/last occurrence lemmas |
| NormalForm.lean:705-719 | -- | SORRY-FREE | nf_to_formula + nf_to_formula_correct |
| MonadicFO.lean | -- | SORRY-FREE | MonadicFormula sig n with eval semantics |

### Bypassed Assets

| File | Lines | Status | Reason |
|------|-------|--------|--------|
| NfComposition.lean | 110 | BYPASSED (2 sorries) | Witness merging problem; 5 failed attempts |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 1 |
| 4 | 4 | 2, 3 |
| 5 | 5a | 4 |
| 6 | 5b | 5a |
| 7 | 5c | 5b |
| 8 | 6 | 5c |

Phases within the same wave can execute in parallel.

---

### Phase 1: vec-EA Formula Type and Bracket Notation [COMPLETED]

**Goal**: Define the vec-EA formula type (Rabinovich Def 3.1) and bracket notation (Notation 5.2) as Lean types.

**Literature**: Rabinovich 2014 Def 3.1 (p. 3), Notation 5.2 (p. 8).

**Tasks**:
- [x] Define `VecEAFormula m n` with `FreeVarPositions m n` for ordering
- [x] Define `BracketFormula`, `VecEA2`, `VBracketFormula`, `VVecEA2` types
- [x] Define evaluation functions: `VecEA2.holds`, `BracketFormula.holds`, `VBracketFormula.holds`
- [x] Verify definitions compile with no errors

**Timing**: 3 hours (~600 lines)

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEAFormula.lean` -- vec-EA types and evaluation

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.VecEAFormula` succeeds
- 0 sorries

---

### Phase 2: Closure Properties (Lemma 3.4) [COMPLETED]

**Goal**: Prove V-EA formulas closed under disjunction, conjunction, and existential quantification.

**Literature**: Rabinovich 2014 Lemma 3.2 (pp. 3-4), Lemma 3.4 (p. 4).

**Tasks**:
- [x] Prove conjunction closure via `BracketFormula.conj_to_bracket_exists`
- [x] Prove `VBracketFormula.conj_holds_vbracket` and `VVecEA2.conj_holds_vvecEA2`
- [x] Prove existential closure via `BracketFormula.existsBounded_right`
- [x] Verify all proofs sorry-free

**Timing**: 3 hours (~400 lines)

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEAClosure.lean` -- closure properties

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.VecEAClosure` succeeds
- 0 sorries

---

### Phase 3: V-EA to Temporal Translation (Prop 3.5) [COMPLETED]

**Goal**: Prove every V-EA formula with one free variable is equivalent to a TL(U,S) formula.

**Literature**: Rabinovich 2014 Prop 3.5 (p. 4).

**Tasks**:
- [x] Implement `bracketBuildRight` using recursive nested Until
- [x] Prove `bracketBuildRight_correct` and `VecEA2.translateLeft_correct`
- [x] Wire to `buildRight_correct` from Translation.lean for base case

**Timing**: 2 hours (~350 lines)

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEATranslation.lean` -- translation to temporal

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.VecEATranslation` succeeds
- 0 sorries

---

### Phase 4: Negation Closure (Prop 4.2 via Section 5) [COMPLETED]

**Goal**: Prove negation of 2-free-variable vec-EA formulas is V-EA over Prior structures. This was the hard core of the proof, completed across sub-phases 4a-4f.

**Literature**: Rabinovich 2014 Lemma 5.1, 5.3, Corollary 5.4, Proposition 4.2 (pp. 6-10).

**Tasks**:
- [x] Phase 4a: Base case (`neg_interval_base_iff`, `neg_interval_base_bracket`, `neg_interval_base_vbracket`)
- [x] Phase 4b: INF formula on Prior (`first_occurrence_prior`, `inf_bracket_formula_holds`, `inf_formula_prior_is_vbracket`)
- [x] Phase 4c: Inductive step (`neg_purePoints_vbracket` with two cases: absent/present)
- [x] Phase 4d: Bounded existential negation by direct induction on n
- [x] Phase 4e: Main technical lemma `neg_interval_formula` via 2-level case split
- [x] Phase 4f: Prop 4.2 (`neg_vecEA2`, `neg_2var_vec_ea` for full `VVecEA2`)
- [x] Verify all proofs sorry-free

**Timing**: 8 hours (~1150 lines across two files)

**Depends on**: 2, 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure5.lean` -- Section 5 lemmas
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosureProp42.lean` -- Prop 4.2

**Verification**:
- `lake build` on both files succeeds
- `lean_verify neg_2var_vec_ea` shows no sorryAx

---

### Phase 5a: VecEADecomposition.lean -- Lemma 3.2.2 [IN PROGRESS]

**Goal**: Prove that every EA formula with n > 2 free variables is equivalent to a conjunction of EA formulas with at most 2 free variables. This is a general result for ANY linear order (no Prior assumption), yielding CSLib-quality infrastructure of independent mathematical value.

**Literature**: Rabinovich 2014, p. 4, Lemma 3.2(2). The key mathematical content: for an EA formula with ordered free variables z_0 < ... < z_{m-1} and existential witnesses x_0 < ... < x_k placed among the z_i's, the witness partition among segments (z_i, z_{i+1}) is deterministic (given by the total ordering), so point types and interval types are local to each segment.

**Tasks**:
- [ ] **Task 5a.1**: Add `VecEAFormula.holds` general evaluation function *(deviation: altered — replaced with syntactic neg_bracket_syn approach; general VecEAFormula.holds not needed because Prop 4.3 works via structural induction on MonadicFormula using pairwise VVecEA2 decomposition)*
- [ ] **Task 5a.2**: Define `segmentBracket` extraction *(deviation: altered — replaced with neg_bracket_syn/neg_vecEA2_syn which directly provides syntactic V-EA negation; segmentBracket extraction not needed)*
- [ ] **Task 5a.3**: Prove `vecEA_decomp_2var` semantic equivalence *(deviation: altered — replaced with neg_bracket_syn_iff which gives ¬bf.holds ↔ neg_bracket_syn.holds over Prior; combined with neg_vecEA2_syn_iff for full VVecEA2 negation)*
- [ ] **Task 5a.4**: Verify all definitions and proofs compile sorry-free *(in progress — VecEADecomposition.lean compiles with 3 sorries: neg_bracket_syn_sound, neg_bracket_syn_complete, neg_vecEA2_syn_iff)*

**Timing**: 4 hours (~250-350 lines in a new file)

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEADecomposition.lean` (NEW) -- Lemma 3.2.2

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.VecEADecomposition` succeeds
- `lean_verify vecEA_decomp_2var` shows no sorryAx

**Implementation Notes**:
- The `VecEAFormula.holds` function must handle: (1) existence of m ordered witnesses, (2) interleaving with n free variables respecting `FreeVarPositions`, (3) point-type predicates at each witness, (4) interval-type predicates along each sub-interval
- The decomposition is CONSTRUCTIVE: the total ordering on the carrier determines which witnesses fall in which segment, so no choice is needed
- Keep the Fin arithmetic minimal: define segment membership by `z_i < x_j < z_{i+1}` predicates rather than complex Fin embeddings
- General result -- do NOT use any Prior/Dedekind/discrete assumption

---

### Phase 5b: Prop43.lean -- FO to V-EA Structural Induction [NOT STARTED]

**Goal**: Prove that every FOMLO formula (MonadicFormula sig n) is equivalent to a V-EA formula over Prior structures, by structural induction on the formula. This is the central theorem that breaks the P1/P2 circularity by replacing NF-depth induction with formula-structure induction.

**Literature**: Rabinovich 2014, p. 6, Proposition 4.3. The proof proceeds by structural induction on `MonadicFormula`:
- Atomic: quantifier-free = EA with 0 witnesses (immediate)
- Disjunction: V-EA closed under disjunction (`vec_ea_closed_disj` from VecEAClosure.lean)
- Negation: Lemma 3.2.2 reduces to at most 2-var pieces, then Prop 4.2 negates each piece
- Existential: V-EA closed under existential quantification (`vec_ea_closed_exists`)

**Tasks**:
- [ ] Define the statement: for every `MonadicFormula sig n`, there exists a `VVecEA2` (or appropriate V-EA type) that is semantically equivalent over Prior structures (~20 lines)
- [ ] Prove the atomic case: an atomic predicate is trivially an EA formula with 0 witnesses (~15-25 lines)
- [ ] Prove the disjunction case: IH gives V-EA for both subformulas, apply `VVecEA2.disj_holds` (~10-15 lines)
- [ ] Prove the negation case: IH gives V-EA for subformula, apply Lemma 3.2.2 (`vecEA_decomp_2var`) to reduce each conjunct to 2-var, then apply Prop 4.2 (`neg_2var_vec_ea`) to negate, then apply closure under conjunction to recombine (~60-100 lines, this is the hard case)
- [ ] Prove the existential case: IH gives V-EA for body (at arity n+1), apply `vec_ea_closed_exists` to project out the bound variable (~15-25 lines)
- [ ] Verify the complete theorem compiles sorry-free

**Timing**: 3 hours (~200-250 lines in a new file)

**Depends on**: 5a

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop43.lean` (NEW) -- FO -> V-EA structural induction

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.Prop43` succeeds
- `lean_verify fo_to_vec_ea_prior` shows no sorryAx

**Implementation Notes**:
- Use structural induction on `MonadicFormula` (preferred) or well-founded recursion on `quantifier_depth` (fallback)
- The negation case is the core: Lemma 3.2.2 converts V-EA with potentially many variables to conjunction of 2-var pieces; Prop 4.2 negates each 2-var piece; closure under conjunction reassembles
- Arity tracking: going under exists takes `MonadicFormula sig n` to `MonadicFormula sig (n+1)`. The IH applies at arity n+1, then `vec_ea_closed_exists` projects back to arity n
- For the NF-specific case (`nf_to_formula` produces formulas with at most 2 free variables at each quantifier level), Lemma 3.2.2 is trivial (already 2-var). But we prove the general result for CSLib quality
- Ensure the evaluation semantics align: `MonadicFormula.eval` must match the V-EA holds semantics after conversion

---

### Phase 5c: Bridge Wiring -- Close All 3 Sorries [NOT STARTED]

**Goal**: Use Prop 4.3 + Prop 3.5 + `nf_to_formula_correct` to close KampPrior.lean:149 and NfCharFormula.lean:572, and mark NegationClosure.lean:1371 as bypassed. This makes `kamp_prior_expressive_completeness` and `US_expressively_complete_over_prior` sorry-free.

**Literature**: Rabinovich 2014 Theorem 4.4 (p. 6) -- the chain: NF -> MonadicFormula -> V-EA -> temporal.

**Tasks**:
- [ ] Close KampPrior.lean:149 (`nf_characterizable_temporal_prior` succ case):
  1. `nf_to_formula nf : MonadicFormula sig 1` (NormalForm.lean:705)
  2. Apply Prop 4.3: `fo_to_vec_ea_prior` gives V-EA equivalent over Prior
  3. Apply Prop 3.5: `VecEA2.translateLeft_correct` (or `VVecEA2.translateLeft_correct`) gives temporal formula
  4. Apply `nf_to_formula_correct` (NormalForm.lean:719): link back to `nf_eval_nf`
  (~15-20 lines)
- [ ] Close NfCharFormula.lean:572 (`nf_2var_exist_formula_prior`): With KampPrior:149 closed, `kamp_prior_expressive_completeness` is sorry-free, which means `nf_2var_exist_formula_prior_fill` at NegationClosure.lean extracts P2 from `master_induction`. Verify this fills automatically, add any needed wiring (~5-8 lines)
- [ ] Mark NegationClosure.lean:1371 (`nf_exist_formula_nested_backward`) as bypassed dead code: add a comment explaining that Path B (Prop 4.3 + Prop 3.5) bypasses this sorry via direct KampPrior closure. Do NOT delete the sorry (it's inside `master_induction` which has other sorry-free cases). The sorry becomes dead code because downstream consumers are closed directly via Prop 4.3 (~3 lines comment)
- [ ] Run scoped builds on KampPrior.lean and NfCharFormula.lean to verify sorry-free

**Timing**: 1.5 hours (~25-30 lines of modifications)

**Depends on**: 5b

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- fill sorry at :149
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfCharFormula.lean` -- fill sorry at :572
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure.lean` -- mark :1371 as bypassed

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior` succeeds with 0 sorries
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfCharFormula` succeeds with 0 sorries
- `lean_verify nf_characterizable_temporal_prior` shows no sorryAx
- `lean_verify nf_2var_exist_formula_prior` shows no sorryAx
- `lean_verify kamp_prior_expressive_completeness` shows no sorryAx

**Implementation Notes**:
- The KampPrior:149 fill is the critical path. The type signature asks for a temporal formula equivalent to `nf_eval_nf M (k+1) 1 (fun _ => t) nf`. The chain is: `nf_to_formula nf` is a `MonadicFormula` (NormalForm.lean:705), `nf_to_formula_correct` gives semantic equivalence with `nf_eval_nf` (NormalForm.lean:719), Prop 4.3 gives V-EA equivalent, Prop 3.5 gives temporal equivalent. Compose the equivalences.
- The NfCharFormula:572 fill should be nearly automatic once KampPrior:149 is closed. Trace the dependency: `nf_2var_exist_formula_prior` -> `nf_2var_exist_formula_prior_fill` -> `master_induction` P2 extraction. The key is that KampPrior.lean provides an INDEPENDENT proof of `kamp_prior_expressive_completeness` that does not route through `master_induction`, so the sorry at :1371 becomes irrelevant for the downstream chain.
- If the dependency chain from NfCharFormula.lean:572 runs through `master_induction` (which still has the sorry at :1371), an alternative wiring may be needed: prove `nf_2var_exist_formula_prior` DIRECTLY from Prop 4.3 (apply Prop 4.3 to `nf_to_formula` of the 2-var NF existence predicate, then extract P2). This alternative adds ~10-15 lines but avoids the `master_induction` dependency entirely.

---

### Phase 6: Full Build Verification and Cleanup [NOT STARTED]

**Goal**: Verify the entire sorry chain is closed end-to-end. Quarantine NfComposition.lean. Clean up dead code.

**Tasks**:
- [ ] Run `lake build` (full project build)
- [ ] Verify `#print axioms US_expressively_complete_over_prior` shows no sorryAx
- [ ] Verify `#print axioms kamp_prior_expressive_completeness` shows no sorryAx
- [ ] Verify `#print axioms gap_prior_UZ_contradiction` shows no Stavi chain dependency
- [ ] Verify downstream consumers compile: GoodStructuresModelSurgery.lean, no_gaps_discrete_model_surgery
- [ ] Quarantine NfComposition.lean: add header comment "bypassed by plan v22 -- Rabinovich Prop 4.3 + Lemma 3.2.2 eliminates composition requirement; file retained for reference"
- [ ] Remove dead code from NegationClosure.lean: `nf_exist_formula_nested` definition and associated sorry'd code (~200 lines of artifacts from plans v16-v20 that are no longer on the critical path) -- only if confirmed dead by import tracing
- [ ] Add docstring to StaviCompleteness.lean noting the sorry chain is fully bypassed via Kamp/Rabinovich
- [ ] Update ROADMAP.md: mark Stavi chain bypass complete

**Timing**: 1.5 hours (mostly verification and cleanup)

**Depends on**: 5c

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfComposition.lean` -- quarantine header
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure.lean` -- dead code cleanup (if safe)
- `Theories/Bimodal/Metalogic/WeakCanonical/StaviCompleteness.lean` -- docstring
- `specs/ROADMAP.md` -- update completion status

**Verification**:
- `lake build` succeeds (full project, clean)
- `#print axioms US_expressively_complete_over_prior` shows no sorryAx
- `#print axioms kamp_prior_expressive_completeness` shows no sorryAx
- `#print axioms gap_prior_UZ_contradiction` shows no Stavi chain dependency
- All downstream consumers compile

---

## Testing & Validation

- [x] Phase 1: vec-EA type definitions compile, universe-correct (DONE)
- [x] Phase 2: Closure lemmas sorry-free (DONE)
- [x] Phase 3: Translation correctness sorry-free (DONE)
- [x] Phase 4: All negation closure sub-phases (4a-4f) sorry-free (DONE)
- [ ] Phase 5a: `VecEAFormula.holds` compiles, `vecEA_decomp_2var` sorry-free
- [ ] Phase 5b: `fo_to_vec_ea_prior` sorry-free; `lean_verify` no sorryAx
- [ ] Phase 5c: KampPrior.lean sorry-free; NfCharFormula.lean sorry-free; `lean_verify kamp_prior_expressive_completeness` no sorryAx
- [ ] Phase 6: `lake build` -- full project, zero errors
- [ ] Phase 6: `#print axioms US_expressively_complete_over_prior` -- no sorryAx
- [ ] Phase 6: `#print axioms gap_prior_UZ_contradiction` -- no Stavi chain dependency

## Artifacts & Outputs

**Existing (phases 1-4, sorry-free)**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEAFormula.lean` -- vec-EA types (~600 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEAClosure.lean` -- Closure properties (~400 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEATranslation.lean` -- V-EA to temporal (~350 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure5.lean` -- Section 5 lemmas (~800 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosureProp42.lean` -- Prop 4.2 (~350 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/FoToVecEA.lean` -- Bridge theorems (~200 lines)

**New (phases 5a-5c)**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEADecomposition.lean` -- Lemma 3.2.2 (Phase 5a, ~250-350 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop43.lean` -- FO -> V-EA (Phase 5b, ~200-250 lines)

**Modified (phase 5c)**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- sorry fill at :149 (~15-20 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfCharFormula.lean` -- sorry fill at :572 (~5-8 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure.lean` -- bypass comment at :1371 (~3 lines)

**Estimated new Lean code**: ~475-630 lines across 2 new files + ~25-30 lines modifications to 3 existing files

## Rollback/Contingency

**If VecEAFormula.holds design proves unwieldy**:
- Alternative: state Lemma 3.2.2 directly in terms of `BracketFormula.holds` semantics, defining the n-var EA evaluation as a derived concept rather than a primitive. This avoids adding a new evaluation function but requires reformulating the decomposition statement.

**If Lemma 3.2.2 (Phase 5a) stalls on Fin arithmetic**:
- Simplify: prove the NF-specific case only (at most 2 free variables at each quantifier level, so Lemma 3.2.2 is trivial). This suffices for closing the sorries but sacrifices CSLib generality. The general version can be added later.

**If Prop 4.3 (Phase 5b) negation case is harder than expected**:
- Decompose: prove the negation case separately for each arity (n=1, n=2, n=3, ...) using strong induction. For our sorry closure, only n=1 is needed (since `nf_to_formula` produces 1-free-variable formulas). The general case can be added incrementally.

**If the bridge wiring (Phase 5c) reveals unexpected type mismatches**:
- Alternative wiring: instead of routing through `master_induction`, prove `kamp_prior_expressive_completeness` DIRECTLY from Prop 4.3 + Prop 3.5, bypassing the entire NF-depth induction framework. This would modify the proof structure of KampPrior.lean more extensively (~50-80 lines instead of ~15-20) but avoids any dependency on `master_induction`.

**If the approach fails entirely**:
- All existing sorry-free code (phases 1-4, ~2700 lines) remains valid
- Fall back to Path A: composition theorem via Feferman-Vaught for linear orders (estimated 300-500 lines, but 5 prior failures at the witness merging step -- only as last resort)
