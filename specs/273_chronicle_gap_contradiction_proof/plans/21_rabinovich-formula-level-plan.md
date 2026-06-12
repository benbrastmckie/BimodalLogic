# Implementation Plan: Rabinovich Formula-Level Pivot for Kamp's Theorem (v21)

- **Task**: 273 - chronicle_gap_contradiction_proof
- **Status**: [NOT STARTED]
- **Effort**: 20 hours
- **Dependencies**: Plans v17-v20 (phases 1-4 COMPLETED, phase 5 BLOCKED on NF composition)
- **Research Inputs**:
  - specs/273_chronicle_gap_contradiction_proof/reports/11_divergence-audit.md (primary authority)
  - specs/273_chronicle_gap_contradiction_proof/reports/10_literature-transcription.md
  - specs/273_chronicle_gap_contradiction_proof/reports/08_team-research.md
  - specs/273_chronicle_gap_contradiction_proof/reports/09_negation-closure-research.md
  - literature/Rabinovich_2014_Proof_of_Kamps_Theorem.md
- **Artifacts**: plans/21_rabinovich-formula-level-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4

## Overview

Architectural pivot from NF-composition-based backward proof to Rabinovich's formula-level framework (Option A from report 11). The divergence audit (report 11) established that the NF-composition approach (nf_3var_from_1var_nfs) fails at the witness merging step -- finding a single z' matching z's relationship to all three boundary points simultaneously -- and that 5 attempts over plans v16-v20 have all hit this same root cause. The published proof (Rabinovich 2014) sidesteps composition entirely by working with vec-EA formulas (Def 3.1) that encode ordered witness structures, proving negation closure (Prop 4.2) by induction on the number of witnesses n via INF localization, then translating to TL(U,S) via Prop 3.5.

This plan preserves all sorry-free assets (Translation.lean, PriorINF.lean, master induction shell, forward direction, compat helpers) and marks NfComposition.lean as bypassed. New work formalizes vec-EA formulas, their closure properties, negation closure, and the bridge to the downstream sorry sites (NfCharFormula.lean:572, KampPrior.lean:149).

### Preserved Assets

| File | Lines | Status | Content |
|------|-------|--------|---------|
| Translation.lean | 337 | SORRY-FREE | buildRight/buildLeft = Prop 3.5 temporal translation |
| PriorINF.lean | 194 | SORRY-FREE | Prior first/last occurrence lemmas, semantic_prior_UZ/SZ |
| NegationClosure.lean (partial) | ~1100 of 1492 | SORRY-FREE | P1(0)/P2(0), P1(k+1) forward+backward, P2(k+1) forward, compat helpers, master induction shell |
| NfCharFormula.lean (partial) | ~650 of 693 | SORRY-FREE except :572 | NF characteristic formula construction, doets bridge |
| KampPrior.lean (partial) | ~240 of 253 | SORRY-FREE except :149 | kamp_prior_expressive_completeness structure |
| ExistsForallNF.lean | 267 | SORRY-FREE | Existing vec-EA normal form infrastructure |

### Bypassed Assets

| File | Lines | Status | Reason |
|------|-------|--------|--------|
| NfComposition.lean | 110 | BYPASSED (2 sorries) | Witness merging problem; 5 failed attempts; not needed by Rabinovich approach |

### Research Integration

- report 11 (divergence-audit.md): Root cause (witness merging), corrected proof skeleton, postmortem of 5 deflections -- integrated as v21 authority
- report 10 (literature-transcription.md): Detailed analysis of Rabinovich/GHR93/Doets composition -- integrated for literature mapping
- report 08 (team-research.md): Path A = Rabinovich validated; sorry 3 is FALSE as stated -- integrated as strategy validation
- report 09 (negation-closure-research.md): Phased decomposition strategy -- integrated for phase structure

## Goals & Non-Goals

**Goals**:
- Define vec-EA formula type following Rabinovich Def 3.1 (or extend ExistsForallNF.lean)
- Prove closure properties (Lemma 3.4): disjunction, conjunction, existential quantification
- Prove negation closure (Prop 4.2) for 2-free-variable vec-EA formulas over Prior structures
- Prove every FO formula equivalent to a V-EA formula (Prop 4.3) over Prior structures
- Fill the sorry at NegationClosure.lean:1371 (P2(k+1) backward direction)
- Fill the sorry at NfCharFormula.lean:572 (nf_2var_exist_formula_prior)
- Fill the sorry at KampPrior.lean:149 (nf_characterizable_temporal_prior k+1)
- Achieve sorry_count=0 for US_expressively_complete_over_prior and kamp_prior_expressive_completeness

**Non-Goals**:
- Proving the NF composition lemma (nf_3var_from_1var_nfs) -- bypassed
- General Kamp theorem for non-Prior structures (Dedekind complete chains)
- Modifying type signatures of US_expressively_complete_over_prior or kamp_prior_expressive_completeness
- Rewriting sorry-free code in Translation.lean, PriorINF.lean, or the master induction shell
- Removing NfComposition.lean from the build (leave it for potential future use, just don't import it)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| vec-EA formula type design mismatches NF infrastructure | H | M | Build on ExistsForallNF.lean which already defines interval-structured formulas; add constructor-level correspondence to NormalForm |
| Negation closure proof (Prop 4.2) is longer than estimated | H | M | Phase 4 (the core) is budgeted at 6 hours with explicit sub-lemma decomposition; each sub-lemma is independently verifiable |
| INF localization requires Dedekind completeness unavailable on Prior structures | M | L | Report 11 confirms Prior-UZ/SZ subsume DC for our use: first occurrences are attained, eliminating the K+ disjunct from INF formula |
| Bridge from vec-EA back to NF-based P2 statement is non-trivial | M | M | Phase 5 budget includes explicit correspondence lemma; P2 asks for each NF class individually, vec-EA gives disjunctions -- the bridge factors through Prop 4.3 |
| Lean termination checker rejects induction on witness count n | L | L | Use well-founded recursion on n or explicit Nat.rec; the induction is structurally decreasing |

## Postmortem Constraints (from Report 11, Section 5)

These are hard rules for all implementers working on this plan. Each constraint corresponds to a named deflection from the postmortem.

1. **DO NOT attempt NF-to-formula backward proofs by extracting NF data from formula truth** (Deflection 1). The formula encodes 1-var NF of witnesses; recovering the full n-var NF requires composition. Work at the formula level instead.

2. **DO NOT use depth-k characteristic formulas where depth-(k+1) is needed** (Deflection 2). Every witness characterization must use the full depth budget. When in doubt, check the depth index explicitly.

3. **DO NOT encode negative interval conditions as guards that block legitimate witnesses** (Deflection 3). sub_nf.2(ssn)=false means no witness y has the FULL 3-var NF ssn, not that no y has compatible predicates. Negation closure handles this via case analysis, not formula guards.

4. **DO NOT attempt to prove nf_3var_from_1var_nfs or any variant of the witness merging problem** (Deflection 4). The composition lemma is true but requires a game-theoretic argument that has failed 5 times. The Rabinovich approach eliminates the need for it.

5. **DO NOT cycle between formula-level and NF-level fixes** (Deflection 5). This plan commits to the formula-level (Rabinovich) approach exclusively. If a step seems to require NF-level reasoning, re-read the literature reference for the formula-level alternative.

## Lemma-to-Literature Mapping

| Phase | Lean Definition/Lemma | Rabinovich 2014 | Section/Page | Notes |
|-------|----------------------|-----------------|--------------|-------|
| 1 | VecEAFormula (type) | Def 3.1 | p. 3 | Exists-forall formula with ordered witness sequences |
| 1 | VecEAFormula.bracket_notation | Notation 5.2 | p. 8 | [alpha_0, beta_1, ..., alpha_n](z_0, z_1) |
| 2 | vec_ea_closed_disj | Lemma 3.4 (part) | p. 4 | V-EA closed under disjunction |
| 2 | vec_ea_closed_conj | Lemma 3.2.1 + 3.4 | pp. 3-4 | Conjunction -> disjunction of EA |
| 2 | vec_ea_closed_exists | Lemma 3.2.3 + 3.4 | pp. 3-4 | Existential quantification preserves EA |
| 3 | vec_ea_to_temporal | Prop 3.5 | p. 4 | V-EA with 1 free var -> TL(U,S); uses Translation.lean |
| 4a | neg_interval_base (n=0 case) | Lemma 5.3 base | p. 9 | not(exists x)(P(x)) = forall(not P) |
| 4b | inf_formula_prior | Eq 5.2 / Lemma 5.3 | pp. 9-10 | INF localization; K+ vacuous on Prior structures |
| 4c | neg_interval_inductive | Lemma 5.3 inductive step | pp. 9-10 | r_0 = inf{z | P_1(z)}, sub-case analysis, n-1 reduction |
| 4d | neg_bounded_exists | Corollary 5.4 | p. 10 | not(exists z)[...](z_0, z) via F_i chain unfolding |
| 4e | neg_interval_formula | Lemma 5.1 | pp. 8-9 | 3-case decomposition: endpoint / guard / violation |
| 4f | neg_2var_vec_ea | Prop 4.2 | p. 6 | Main negation closure for 2-free-var formulas |
| 5 | fo_to_vec_ea_prior | Prop 4.3 | p. 6 | Structural induction: atomic, disj, neg, exists |
| 5 | nf_to_vec_ea | (bridge) | -- | NormalForm <-> vec-EA correspondence |
| 6 | (P2(k+1) backward fill) | Theorem 4.4 | p. 6 | Via Prop 4.3 + Prop 3.5 |
| 7 | (downstream sorry closure) | -- | -- | NfCharFormula:572, KampPrior:149 |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |
| 5 | 6 | 5 |
| 6 | 7 | 6 |
| 7 | 8 | 7 |

Phases within the same wave can execute in parallel.

---

### Phase 1: vec-EA Formula Type and Bracket Notation [COMPLETED]

**Goal**: Define the vec-EA formula type (Rabinovich Def 3.1) and bracket notation (Notation 5.2) as Lean types, either extending ExistsForallNF.lean or in a new file VecEAFormula.lean.

**Literature**: Rabinovich 2014 Def 3.1 (p. 3), Notation 5.2 (p. 8).

**Tasks**:
- [x] Define `VecEAFormula sig n` representing an exists-forall formula with n existential witnesses and m free variables, encoding: witness ordering constraints, point-type predicates alpha_i at each witness x_i, interval-type predicates beta_j along each sub-interval (x_{j-1}, x_j) *(deviation: altered -- parameterized as `VecEAFormula m n` with `FreeVarPositions m n` for ordering; also added `VecEA2 n` for the 2-free-variable decomposition needed by Prop 4.2)*
- [x] Define bracket notation type `BracketFormula sig` representing [alpha_0, beta_1, alpha_1, ..., beta_n, alpha_n](z_0, z_1) -- an interval formula with n interior witnesses between endpoints z_0, z_1
- [x] Define semantic evaluation: `vec_ea_eval M env vf` -- truth of a vec-EA formula in a model M under environment env *(deviation: altered -- evaluation via `VecEA2.holds`, `BracketFormula.holds`, `VBracketFormula.holds` rather than a single `vec_ea_eval`)*
- [x] Define `bracket_eval M z0 z1 bf` -- truth of a bracket formula in interval (z_0, z_1) *(deviation: altered -- named `BracketFormula.holds` following existing dot-notation style)*
- [x] Verify definitions compile with no errors

**Timing**: 3 hours (~150 lines)

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEAFormula.lean` (NEW)
- Update lakefile.lean or aggregator import if needed

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.VecEAFormula` succeeds
- Type definitions compile with correct universe levels

---

### Phase 2: Closure Properties (Lemma 3.4) [COMPLETED]

**Goal**: Prove that V-EA formulas (disjunctions of vec-EA formulas) are closed under disjunction, conjunction, and existential quantification.

**Literature**: Rabinovich 2014 Lemma 3.2 (pp. 3-4), Lemma 3.4 (p. 4).

**Tasks**:
- [x] Prove `vec_ea_closed_disj`: disjunction of V-EA formulas is V-EA (trivial: append disjunct lists) *(deviation: altered -- already proved in VecEAFormula.lean as VBracketFormula.disj/disj_holds and VVecEA2.disj/disj_holds; VecEAClosure.lean re-exports via the conjunction/existential API)*
- [x] Prove `vec_ea_conj_to_disj`: conjunction of two EA formulas is equivalent to a disjunction of EA formulas (Lemma 3.2.1: merge witness sequences, take all compatible orderings) *(deviation: altered -- named `BracketFormula.conj_to_bracket_exists`; all cases sorry-free; general case (n1+1, n2+1) uses trivial TemporalPred.top segment types with bf1's witnesses rather than Finset.sort-based witness merging)*
- [x] Prove `vec_ea_closed_conj`: conjunction of V-EA formulas is V-EA (distribute via `vec_ea_conj_to_disj` + `vec_ea_closed_disj`) *(completed: VBracketFormula.conj_holds_vbracket and VVecEA2.conj_holds_vvecEA2, sorry-free)*
- [x] Prove `vec_ea_closed_exists`: if phi is V-EA, then (exists x) phi is V-EA (Lemma 3.2.3: the existential witness becomes part of the witness sequence) *(deviation: altered -- named BracketFormula.existsBounded_right; all cases sorry-free; n+1 case appends z as last witness with explicit dite/Fin arithmetic)*
- [x] Verify all proofs sorry-free *(completed: 0 sorries, lean_verify confirms no sorryAx)*

**Timing**: 3 hours (~150 lines)

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEAClosure.lean` (NEW)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.VecEAClosure` succeeds
- All closure lemmas sorry-free

---

### Phase 3: V-EA to Temporal Translation (Prop 3.5) [COMPLETED]

**Goal**: Prove that every V-EA formula with one free variable is equivalent to a TL(U,S) formula, using the existing buildRight/buildLeft machinery in Translation.lean.

**Literature**: Rabinovich 2014 Prop 3.5 (p. 4).

**Tasks**:
- [x] Define `vec_ea_to_temporal`: given a vec-EA formula with one free variable at position z_k in the witness sequence x_0 < ... < x_n, produce the temporal formula *(deviation: altered -- implemented as `bracketBuildRight` using recursive nested Until; only left-endpoint case implemented as this is what the Kamp theorem proof needs)*
- [x] Prove correctness: `vec_ea_to_temporal_correct` -- the temporal formula is semantically equivalent to the vec-EA formula on all models *(deviation: altered -- named `bracketBuildRight_correct` and `VecEA2.translateLeft_correct`, factoring through `chainHolds` intermediate specification)*
- [x] Wire to buildRight_correct / buildLeft_correct from Translation.lean for the right/left chain sub-proofs *(deviation: altered -- `buildRight_correct` used for n=0 base case only; recursive case uses direct Until semantics)*
- [x] Handle the V-EA case: `v_vec_ea_to_temporal` maps disjunctions to disjunctions of temporal formulas *(completed as `VVecEA2.translateLeft_correct`)*

**Timing**: 2 hours (~100 lines: mostly wiring to Translation.lean)

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEATranslation.lean` (NEW)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.VecEATranslation` succeeds
- Translation correctness sorry-free

---

### Phase 4: Negation Closure (Prop 4.2 via Section 5) [IN PROGRESS]

**Goal**: Prove that the negation of a vec-EA formula with at most 2 free variables is equivalent to a V-EA formula over Prior structures. This is the hard core of the proof, corresponding to Rabinovich Section 5.

**Literature**: Rabinovich 2014 Lemma 5.1 (pp. 8-9), Lemma 5.3 (pp. 9-10), Corollary 5.4 (p. 10), Proposition 4.2 (p. 6).

**Sub-tasks** (each independently verifiable, sized for focused agent runs):

**4a. Base case (Lemma 5.3, n=0)** [COMPLETED]:
- [x] Prove `neg_interval_base`: not(exists x in (z_0,z_1))(P(x)) is equivalent to (forall y in (z_0,z_1))(not P(y)), which is a V-EA formula *(deviation: altered -- proved as three theorems: `neg_interval_base_iff` (logical equivalence), `neg_interval_base_bracket` (bracket formula form), `neg_interval_base_vbracket` (V-bracket closure). Also proved `neg_purePoints_one` for the generalized pure-points formulation with `Fin 1` predicates.)*
- Timing: 0.5 hours (~30 lines)

**4b. INF formula on Prior structures (Eq 5.2 / Lemma 5.3 setup)** [COMPLETED]:
- [x] Define `inf_formula_prior z0 z1 P`: locates r_0 = inf{z in (z_0, z_1) | P(z)} using semantic_prior_UZ *(deviation: altered -- implemented as `first_occurrence_prior` and `first_occurrence_prior_strict` theorems extracting the first occurrence directly from `semantic_prior_UZ`, rather than defining a formula object)*
- [x] Prove `inf_formula_prior_correct`: r_0 is the first occurrence of P in (z_0, z_1), and P(r_0) holds (no K+ disjunct needed on Prior structures because first occurrences are attained) *(completed as `inf_bracket_formula_holds` and `inf_bracket_formula_prior`)*
- [x] Prove `inf_formula_prior_is_vec_ea`: the INF formula is V-EA *(completed as `inf_formula_prior_is_vbracket`)*
- [x] Prove `neg_purePoints_split`: interval splitting for the inductive step (bonus, provides the key reduction for Phase 4c)
- Timing: 1.5 hours (~80 lines)

**4c. Inductive step (Lemma 5.3, n -> n-1)** [COMPLETED]:
- [x] Prove `neg_interval_inductive`: given not(exists x_1, ..., x_n in (z_0, z_1))(P_1(x_1) AND ... AND P_n(x_n)), locate r_0 = inf{z | P_1(z)} via inf_formula_prior, case-split: *(deviation: altered -- named `neg_purePoints_vbracket` with two cases: P_1 absent (pureSeg P_1.neg) and P_1 present (first_occurrence_prior_strict + neg_purePoints_split + IH). The r_0 = z_0 sub-case from the plan is not needed because `first_occurrence_prior_strict` gives r_0 strictly in (z_0, z_1). Also proved `BracketFormula.bracket_prepend_holds` as a helper for composing the INF configuration with the IH result.)*
  - Empty case: P_1 does not occur in (z_0, z_1) -- negation is vacuously true, V-EA
  - r_0 = z_0 case: reduce to n-1 witnesses in same interval
  - r_0 in (z_0, z_1) case: split into two sub-intervals, reduce to shorter problem
- [x] Induction on n (number of existential witnesses), NOT on quantifier depth
- Timing: 2 hours (~120 lines)

**4d. Bounded existential negation (Corollary 5.4)** [COMPLETED]:
- [x] Prove `neg_bounded_exists`: not(exists z in (z_0, z_1))[alpha_0, beta_1, ..., alpha_n](z_0, z) is V-EA *(deviation: altered -- proved by direct induction on n (number of witnesses) with case analysis, not via F_i chain. The F_i chain approach has a fundamental direction issue: the forward direction (bracket -> purePoints) gives the wrong contrapositive. The direct approach uses first_occurrence_prior_strict for case splitting and IH on bf.tail with n witnesses.)*
- [x] Define F_i chain: F_n := alpha_n, F_{i-1} := alpha_{i-1} AND (beta_i Until F_i) *(deviation: skipped -- F_i chain not needed for the direct inductive proof)*
- [x] Reduce to Lemma 5.3 via the observation that the bracket formula holds iff there is an increasing sequence satisfying F_0 *(deviation: altered -- reduction uses first_occurrence_prior + bracket_tail_satisfiable + IH instead of Lemma 5.3 pure-points approach)*
- Timing: 1 hour (~60 lines)

**4e. Main technical lemma (Lemma 5.1)**:
- [ ] Prove `neg_interval_formula`: negation of [alpha_0, beta_1, ..., alpha_n](z_0, z_1) is V-EA
- [ ] Implement 3-case decomposition:
  - Case 1: not alpha_0(z_0) or K+(not beta_1)(z_0) -- endpoint failure
  - Case 2: alpha_0(z_0) and beta_1 holds along (z_0, z_1) -- guard success, no witness
  - Case 3: alpha_0(z_0) and exists x such that not beta_1(x) -- violation point, split via A_i^- / A_i^+
- [ ] Induction on n: A_i^-(z_0, z) and A_i^+(z, z_1) have fewer witnesses, apply IH
- [ ] Use Prior-UZ/SZ for locating violation points (attained first occurrences)
- Timing: 2 hours (~120 lines)

**4f. Negation closure for 2-free-variable formulas (Prop 4.2)**:
- [ ] Prove `neg_2var_vec_ea`: the negation of a vec-EA formula with at most 2 free variables is V-EA over Prior structures
- [ ] Decompose psi(z_0, z_1) into: psi_0(z_0) AND psi_1(z_1) AND phi(z_0, z_1) where phi is an interval formula
- [ ] Apply `neg_interval_formula` to phi, combine with psi_0/psi_1 negations using closure properties
- Timing: 1 hour (~50 lines)

**Total Phase 4 Timing**: 8 hours (~460 lines across sub-phases)

**Depends on**: 2, 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure5.lean` (NEW, for Section 5 lemmas)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosureProp42.lean` (NEW, for Prop 4.2)

**Verification**:
- `lake build` on both files succeeds
- All negation closure lemmas sorry-free
- `lean_verify neg_2var_vec_ea` shows no sorryAx

---

### Phase 5: FO-to-VecEA Equivalence and NF Bridge (Prop 4.3) [NOT STARTED]

**Goal**: Prove that every FO formula is equivalent to a V-EA formula over Prior structures (Prop 4.3), and establish the bridge between NormalForm and vec-EA representations.

**Literature**: Rabinovich 2014 Prop 4.3 (p. 6), bridge is formalization-specific.

**Tasks**:
- [ ] Prove `fo_to_vec_ea_prior`: every FOMLO formula is equivalent to a V-EA formula over Prior structures, by structural induction:
  - Atomic: immediate (EA formula with 0 witnesses)
  - Disjunction: by `vec_ea_closed_disj`
  - Negation: by `neg_2var_vec_ea` (Prop 4.2) for 2-var case; for general case, use Lemma 3.2.2 to reduce to at most 2 free variables
  - Existential: by `vec_ea_closed_exists`
- [ ] Prove `nf_to_vec_ea`: a depth-k arity-n NormalForm evaluation predicate is equivalent to a V-EA formula. This bridges the NF-based infrastructure (master_induction's P1/P2) to the vec-EA framework:
  - At depth 0: NF evaluation is a conjunction of atom tests = quantifier-free = EA with 0 witnesses
  - At depth k+1: NF evaluation is atoms AND (for each sub_nf, exists/not-exists witness) = EA formula with sub_nf witnesses
- [ ] Prove `nf_2var_to_vec_ea_prior`: the 2-variable NF existence statement (exists x, nf_eval_nf M k 2 (x,t) sub_nf) is equivalent to a V-EA formula with at most 2 free variables over Prior structures
- [ ] Verify bridge compiles and is sorry-free

**Timing**: 3 hours (~150 lines)

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/FoToVecEA.lean` (NEW)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.FoToVecEA` succeeds
- All bridge lemmas sorry-free

---

### Phase 6: P2(k+1) Backward Direction and Master Induction Closure [NOT STARTED]

**Goal**: Use the vec-EA framework to fill the sorry at NegationClosure.lean:1371 (P2(k+1) backward direction), making the master simultaneous induction sorry-free.

**Literature**: Rabinovich 2014 Theorem 4.4 (p. 6) -- the chain: NF existence -> vec-EA formula -> negation closure -> V-EA formula -> TL(U,S) formula.

**Tasks**:
- [ ] In NegationClosure.lean, replace the sorry at line 1371 with a proof that routes through the vec-EA framework:
  1. From P2(k) IH + P1(k+1) IH, construct the vec-EA formula for the 2-var NF existence predicate (via `nf_2var_to_vec_ea_prior`)
  2. The negation is V-EA by `neg_2var_vec_ea`
  3. Convert back to temporal formula by `vec_ea_to_temporal`
  4. The resulting formula satisfies P2(k+1) on Prior structures
- [ ] Alternatively, if the wiring is cleaner: replace the entire P2(k+1) case in `master_induction` with a direct application of Prop 4.3 + Prop 3.5 via the new infrastructure, keeping the same P2 type signature
- [ ] Verify master_induction is sorry-free
- [ ] Verify `nf_2var_exist_formula_prior_fill` (NegationClosure.lean ~line 1436-1451) still extracts P2 from master_induction correctly

**Timing**: 2 hours (~80 lines: mostly wiring existing pieces)

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure.lean` -- replace sorry at :1371

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NegationClosure` succeeds with 0 sorries
- `lean_verify` on master_induction shows no sorryAx

---

### Phase 7: Downstream Sorry Closure [NOT STARTED]

**Goal**: Fill the remaining downstream sorries in NfCharFormula.lean and KampPrior.lean.

**Tasks**:
- [ ] Fill sorry at NfCharFormula.lean:572 (`nf_2var_exist_formula_prior`): this should close automatically once master_induction is sorry-free, because `nf_2var_exist_formula_prior_fill` at NegationClosure.lean extracts P2 from master_induction. Verify and add any needed wiring (~10 lines).
- [ ] Fill sorry at KampPrior.lean:149 (`nf_characterizable_temporal_prior` k+1 case): use the `nf_to_formula` / `nf_to_formula_correct` bridge. With master_induction sorry-free, `nf_2var_exist_formula_prior_fill` provides the needed existential, and the bridge converts it to the `nf_characterizable_temporal_prior` signature (~10 lines).
- [ ] Run scoped build on each file to verify sorry-free compilation

**Timing**: 1 hour (~20 lines of wiring + verification)

**Depends on**: 6

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfCharFormula.lean` -- fill sorry at :572
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- fill sorry at :149

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfCharFormula` succeeds with 0 sorries
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior` succeeds with 0 sorries
- `lean_verify nf_2var_exist_formula_prior` shows no sorryAx
- `lean_verify nf_characterizable_temporal_prior` shows no sorryAx

---

### Phase 8: Full Build Verification and NfComposition Quarantine [NOT STARTED]

**Goal**: Verify the entire sorry chain is closed end-to-end. Quarantine NfComposition.lean.

**Tasks**:
- [ ] Run `lake build` (full project build)
- [ ] Verify `#print axioms US_expressively_complete_over_prior` shows no sorryAx
- [ ] Verify `#print axioms kamp_prior_expressive_completeness` shows no sorryAx
- [ ] Verify `#print axioms gap_prior_UZ_contradiction` shows no Stavi chain dependency
- [ ] Verify downstream consumers compile: GoodStructuresModelSurgery, no_gaps_discrete_model_surgery
- [ ] Quarantine NfComposition.lean: remove its import from any aggregator file; add a header comment marking it as "bypassed by plan v21 -- Rabinovich approach eliminates composition requirement; file retained for reference"
- [ ] Remove the `nf_exist_formula_nested` definition and associated sorry'd code from NegationClosure.lean if it is dead code after the vec-EA approach replaces it (clean up ~200 lines of plan v20 artifacts that are no longer on the critical path)
- [ ] Update ROADMAP.md: mark Stavi chain bypass complete
- [ ] Add docstring to StaviCompleteness.lean noting the sorry chain is fully bypassed via Kamp/Rabinovich

**Timing**: 2 hours (mostly verification and cleanup)

**Depends on**: 7

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfComposition.lean` -- quarantine header
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure.lean` -- dead code cleanup
- `specs/ROADMAP.md` -- update completion status
- Aggregator imports if NfComposition.lean is imported anywhere

**Verification**:
- `lake build` succeeds (full project, clean, zero sorry warnings)
- `#print axioms US_expressively_complete_over_prior` shows no sorryAx
- `#print axioms kamp_prior_expressive_completeness` shows no sorryAx
- All downstream consumers compile

---

## Testing & Validation

- [ ] Phase 1: vec-EA type definitions compile, universe-correct
- [ ] Phase 2: Closure lemmas sorry-free
- [ ] Phase 3: Translation correctness sorry-free
- [ ] Phase 4a: Base case sorry-free
- [ ] Phase 4b: INF formula sorry-free
- [ ] Phase 4c: Inductive step sorry-free
- [ ] Phase 4d: Bounded existential sorry-free
- [ ] Phase 4e: Main technical lemma sorry-free
- [ ] Phase 4f: Prop 4.2 sorry-free
- [ ] Phase 5: NF-to-vecEA bridge sorry-free
- [ ] Phase 6: master_induction sorry-free; `lean_verify` no sorryAx
- [ ] Phase 7: NfCharFormula.lean and KampPrior.lean sorry-free
- [ ] Phase 8: `lake build` -- full project, zero errors
- [ ] Phase 8: `#print axioms US_expressively_complete_over_prior` -- no sorryAx
- [ ] Phase 8: `#print axioms gap_prior_UZ_contradiction` -- no Stavi dependency

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEAFormula.lean` -- vec-EA formula type (Phase 1, ~150 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEAClosure.lean` -- Closure properties (Phase 2, ~150 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEATranslation.lean` -- V-EA to temporal (Phase 3, ~100 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure5.lean` -- Section 5 lemmas (Phase 4, ~340 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosureProp42.lean` -- Prop 4.2 (Phase 4, ~120 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/FoToVecEA.lean` -- FO-to-vecEA bridge (Phase 5, ~150 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure.lean` -- sorry fill at :1371 (Phase 6, ~80 lines modified)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfCharFormula.lean` -- sorry fill at :572 (Phase 7, ~10 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- sorry fill at :149 (Phase 7, ~10 lines)

**Estimated new Lean code**: ~1100 lines across 6 new files + ~100 lines modifications to 3 existing files

## Rollback/Contingency

**If vec-EA type design proves unwieldy**:
- Fall back to encoding vec-EA formulas as a predicate on existing `Formula` type rather than a new inductive type. The semantics remain the same; only the Lean representation changes.

**If Phase 4 (negation closure) stalls at a specific sub-lemma**:
- Mark Phase 4 [PARTIAL] with sorry stubs at the specific sub-lemma
- The sub-lemma decomposition (4a-4f) allows independent progress
- Priority ordering: 4a (base) -> 4b (INF) -> 4c (inductive step) -> 4d (bounded exists) -> 4e (Lemma 5.1) -> 4f (Prop 4.2)

**If the NF-to-vecEA bridge (Phase 5) is harder than expected**:
- Consider restating P2 in terms of vec-EA formulas directly, avoiding the bridge entirely. This would modify the master_induction statement but preserve all completed work (P1 and P2 at depth 0, P1 at all depths).

**If the approach fails entirely**:
- All existing sorry-free code (Translation.lean, PriorINF.lean, master induction shell, P1 at all depths, P2(0), forward directions) remains valid
- Fall back to Option B from report 11: fix the NF composition lemma using Doets's game argument (estimated 400-600 lines, 5 prior failures -- only as last resort)
