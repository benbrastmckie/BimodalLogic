# Implementation Plan: Literature-Faithful Kamp Completion via GHR94 Separation (v24)

- **Task**: 273 - chronicle_gap_contradiction_proof
- **Status**: [NOT STARTED]
- **Effort**: 16 hours
- **Dependencies**: Plans v17-v22 (phases 1-4 COMPLETED), plan v23 (Phase 0 COMPLETED, Phases 5-7 BLOCKED)
- **Research Inputs**:
  - specs/273_chronicle_gap_contradiction_proof/reports/24_blocker-research.md (round 24)
  - specs/273_chronicle_gap_contradiction_proof/reports/23_team-research.md (round 23)
  - specs/273_chronicle_gap_contradiction_proof/reports/13_team-research.md (round 13)
  - specs/273_chronicle_gap_contradiction_proof/reports/11_divergence-audit.md (postmortem constraints)
  - specs/273_chronicle_gap_contradiction_proof/reports/10_literature-transcription.md (literature grounding)
- **Artifacts**: plans/24_literature-faithful-kamp-completion.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v23 failed because its key assumption ("arity never exceeds 2 during structural induction") was incorrect. The NF-specific Prop 4.3 bypass requires Lemma 3.2.2 (VecEA decomposition) at arity >= 3 for depth k >= 1, which is quarantined. Research round 24 confirmed that ALL approaches -- Kamp/Rabinovich composition, Stavi/EF-games, NF-specific bypass, and 5 alternative proof strategies -- converge on the same root blocker: the Feferman-Vaught composition lemma for NormalForms at depth >= 1.

This plan abandons the Rabinovich composition path (Sections 3-5 of Rabinovich 2014) and instead follows Gabbay-Hodkinson-Reynolds 1994, Chapter 10, Section 10.2: the **syntactic separation approach for discrete time**. This approach proves {U,S} expressive completeness by eliminating nested temporal connectives, entirely avoiding the Feferman-Vaught composition lemma. The key mathematical content is Lemma 10.2.3 (8 elimination cases) and the junction depth induction (Lemma 10.2.8), both specific to discrete (integer) time.

The plan produces a sorry-free proof of `kamp_prior_expressive_completeness` (KampPrior.lean:149) by:
1. Implementing the GHR94 separation eliminations for discrete time
2. Deriving P1(k) for all k as a consequence of separation + expressive completeness
3. Filling the sorry at KampPrior.lean:149 using the derived P1
4. Filling chronicle_gap_contradiction using the sorry-free model surgery pipeline

### Research Integration

**Round 24** (primary): Confirmed the root blocker is the Feferman-Vaught composition lemma (Finding 5). All five alternative approaches verified non-viable (Finding 3). The OLD PROOF of chronicle_gap_contradiction is 95% complete and requires only Kamp at k >= 1 (Finding 1). The contemp_equiv at k=0 triviality is verified (Finding 3/adversarial check 3). `reynolds_model_surgery_core` depends on Kamp transitively (Finding 2). Case B (constant MCS) remains an open investigation question (Finding 7).

**Round 23**: VecEADecomposition.lean confirmed dead code. `neg_2var_vec_ea` sorry-free but insufficient for arity > 2. Phase 0 check revealed arity grows to k+2 during induction.

### Why the GHR94 Separation Approach

The Rabinovich composition approach (Prop 4.3) and the Stavi/EF-game approach (GHR93 Theorem 9.3.1) both require the Feferman-Vaught composition lemma -- determining a depth-k 3-variable NF from 2-variable NF projections. This is the mathematical difficulty that has blocked 23 plan versions and 5 NfComposition.lean attempts.

The GHR94 Chapter 10.2 separation approach works entirely differently:
- It operates SYNTACTICALLY on temporal formulas, not on NormalForm evaluations
- It uses the DISCRETE STRUCTURE (integer time) to justify elimination equivalences
- It produces separation -> expressive completeness via the Chapter 9 bridge
- It has been fully proved in the published literature (Gabbay 1989, GHR94 Chapter 10.2)

The 8 elimination lemmas (Lemma 10.2.3) are all proved by direct semantic argument over integer time. They do not involve normal forms, composition, or existential transfer. The junction depth induction (Lemma 10.2.8) is a straightforward induction on formula nesting depth.

### Prior Plan Reference

Plan v23: Phases 1-4 COMPLETED (sorry-free vec-EA infrastructure, ~2700 lines). Phase 0 COMPLETED (precondition verification + quarantine). Phase 5 BLOCKED (NF-specific Prop 4.3 fails because arity exceeds 2 at depth k >= 1). Phases 6-7 NOT STARTED (blocked by Phase 5).

This plan preserves all completed phases 1-4 and phase 0. The vec-EA infrastructure remains valuable: `neg_2var_vec_ea` (Prop 4.2) and the translation machinery (Prop 3.5) can serve as lemmas within the new approach if needed, though the separation approach does not require them.

### Roadmap Alignment

- **Kamp chain**: Close `kamp_prior_expressive_completeness` sorry chain via GHR94 separation
- **Chronicle gap**: Fill `chronicle_gap_contradiction` via sorry-free model surgery pipeline
- **Critical path**: Closes two of the remaining sorry chains for `completeness_discrete`

## Goals & Non-Goals

**Goals**:
- Implement the GHR94 Chapter 10.2 separation eliminations for discrete time as Lean definitions and theorems
- Prove the separation theorem for {U,S} over discrete time (Theorem 10.2.9)
- Derive {U,S} expressive completeness over Prior structures from separation (Theorem 10.2.10 + Reynolds Theorem 5)
- Fill sorry at KampPrior.lean:149 (`nf_characterizable_temporal_prior` succ k case)
- Fill sorry at chronicle_gap_contradiction (ChronicleToCountermodel.lean:537)
- Pass `lake build` with zero new sorries on the critical path to `completeness_discrete`

**Non-Goals**:
- Proving the Feferman-Vaught composition lemma (the plan explicitly avoids this)
- Proving general Prop 4.3 for all arities (not needed with separation approach)
- Fixing VecEADecomposition.lean sorries (dead code, quarantined)
- Fixing StaviCompleteness.lean sorries (the separation approach bypasses these)
- Modifying existing sorry-free infrastructure (phases 1-4 files)
- Implementing the Dedekind-complete separation (Section 10.3) -- only discrete (Section 10.2) is needed

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| GHR94 elimination lemmas require discrete successor/predecessor semantics that don't map to the abstract Prior structure formulation | H | M | Phase 1 validates the formulation with a single test case (Case 1 of Lemma 10.2.3) before committing to all 8 cases. Prior-UZ/SZ encode exactly the discrete structure properties needed. |
| Separation theorem produces `StaviFormula` or extended `Formula` type, not compatible with `temporal_truth` | M | L | The separation eliminations operate on the existing `Formula` type with `Until`/`Since` connectives. The output is a `Formula` in separated form, directly evaluated by `temporal_truth`. |
| Junction depth induction is more complex in Lean than in the paper due to formula recursion | M | M | Phase 2 implements the induction carefully, using well-founded recursion on junction depth. The GHR94 proof structure (Lemma 10.2.4 -> 10.2.5 -> 10.2.6 -> 10.2.7 -> 10.2.8) decomposes cleanly into small steps. |
| Bridge from separation to P1(k) requires additional NF infrastructure | M | M | Phase 3 bridges via: separation -> expressive completeness -> each NF has a temporal formula (since nf_to_formula is a MonadicFormula, its temporal equivalent is the desired P1(k) result). |
| Chronicle OLD PROOF has deeper issues than the k >= 1 fix and Case B | M | L | Round 24 Finding 1 verified the OLD PROOF is 95% complete. Case A needs ~30 lines beyond existing code. Case B is deferred to a separate task if not vacuously impossible. |

## Postmortem Constraints (from Report 11, Section 5)

These remain binding:

1. **DO NOT attempt NF-to-formula backward proofs by extracting NF data from formula truth** (Deflection 1). The separation approach operates on formulas directly, not NFs.
2. **DO NOT use depth-k characteristic formulas where depth-(k+1) is needed** (Deflection 2).
3. **DO NOT encode negative interval conditions as guards that block legitimate witnesses** (Deflection 3).
4. **DO NOT attempt to prove nf_3var_from_1var_nfs or any variant of the witness merging problem** (Deflection 4). The separation approach avoids this entirely.
5. **DO NOT cycle between formula-level and NF-level fixes** (Deflection 5). This plan commits to the formula-level (GHR94 separation) approach exclusively.

## Lemma-to-Literature Mapping

| Phase | Lean Definition/Lemma | GHR94 Ch10 / Reynolds 94 | Section | Notes |
|-------|----------------------|--------------------------|---------|-------|
| 1 | neg_until, neg_since | Lemma 10.2.2 | p. 12 | Negation of Until/Since over integer time |
| 1 | elim_case_1 through elim_case_8 | Lemma 10.2.3 (Cases 1-8) | pp. 12-14 | The 8 elimination equivalences |
| 2 | separation_single_U | Lemma 10.2.5 | p. 14 | Single U(A,B) under S |
| 2 | separation_multi_U | Lemma 10.2.6 | p. 15 | Multiple U(A_i, B_i) under S |
| 2 | separation_nested_U | Lemma 10.2.7 | p. 15 | Nested U under S |
| 2 | separation_theorem | Lemma 10.2.8 / Theorem 10.2.9 | pp. 15-16 | Full separation theorem |
| 3 | US_expressively_complete_discrete | Theorem 10.2.10 | p. 16 | Expressive completeness from separation |
| 3 | US_expressively_complete_prior | Reynolds Theorem 5 | p. 123-124 | Prior structures via U' = bot |
| 4 | KampPrior.lean:149 fill | -- | -- | Wire separation-based expressive completeness |
| 5 | chronicle_gap_contradiction fill | Reynolds Lemmas 6-13 | Sec 7 | Via reynolds_model_surgery_core |

### Preserved Assets (from v21/v22/v23 phases 0-4)

| File | Lines | Status | Content |
|------|-------|--------|---------|
| VecEAFormula.lean | ~600 | SORRY-FREE | Vec-EA types + evaluation |
| VecEAClosure.lean | ~400 | SORRY-FREE | Closure properties |
| VecEATranslation.lean | ~350 | SORRY-FREE | V-EA to temporal translation |
| NegationClosure5.lean | ~800 | SORRY-FREE | Section 5 lemmas |
| NegationClosureProp42.lean | ~350 | SORRY-FREE | Prop 4.2 negation closure |
| FoToVecEA.lean | ~200 | SORRY-FREE | Bridge theorems |
| Translation.lean | ~337 | SORRY-FREE | Prop 3.5 temporal translation |
| PriorINF.lean | ~194 | SORRY-FREE | Prior first/last occurrence |
| GoodStructuresModelSurgery.lean | ~2000 | SORRY-FREE | Reynolds model surgery core |

### Quarantined Assets

| File | Lines | Status | Reason |
|------|-------|--------|--------|
| VecEADecomposition.lean | ~310 | QUARANTINED | Dead code, not on critical path |
| NfComposition.lean | ~110 | QUARANTINED | Witness merging, 5 failed attempts |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |

Phases are fully sequential. Each phase builds on the prior.

---

### Phase 1: Separation Eliminations (GHR94 Lemmas 10.2.2-10.2.3) [NOT STARTED]

**Goal**: Implement the core elimination equivalences for {U,S} over discrete (integer) time. These are the 8 cases of pulling U out from under S, plus their duals (pulling S out from under U). Also implement the negation lemmas for Until/Since (Lemma 10.2.2).

**Literature**: Gabbay-Hodkinson-Reynolds 1994, Chapter 10, Lemmas 10.2.1, 10.2.2, 10.2.3.

**Tasks**:
- [ ] **Task 1.1**: Create `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/SeparationDiscrete.lean`. Define helper predicates: `is_syntactically_separated`, `junction_depth`, and the notion of an atom being "pure past" or "pure future" in the formula tree. Import existing Formula infrastructure.
- [ ] **Task 1.2**: Prove Lemma 10.2.2 (negation of Until/Since over integer time):
  - `neg_until : neg(U(A,B)) <-> G(neg(A)) \/ U(neg(A) /\ neg(B), neg(A))`
  - `neg_since : neg(S(A,B)) <-> H(neg(A)) \/ S(neg(A) /\ neg(B), neg(A))`
  These require the discrete property (no gaps between consecutive points). In the codebase, discrete = Prior-UZ + Prior-SZ with `SuccOrder` + `NoMaxOrder` + `NoMinOrder`.
- [ ] **Task 1.3**: Prove the 8 elimination cases (Lemma 10.2.3). Each case converts `S(X, Y)` where X or Y contains `U(A,B)` into an equivalent formula where U(A,B) is no longer under S. The 8 cases are:
  1. `S(a /\ U(A,B), q)` -- U witness in the guard, past witness from S
  2. `S(a /\ neg(U(A,B)), q)` -- negated U in the guard
  3. `S(a, q \/ U(A,B))` -- U witness in the event
  4. `S(a, q \/ neg(U(A,B)))` -- negated U in the event
  5. `S(a /\ U(A,B), q \/ U(A,B))` -- U in both positions
  6. `S(a /\ neg(U(A,B)), q \/ U(A,B))` -- negated guard, positive event
  7. `S(a /\ U(A,B), q \/ neg(U(A,B)))` -- positive guard, negated event
  8. `S(a /\ neg(U(A,B)), q \/ neg(U(A,B)))` -- negated in both
  Each proven by direct semantic argument over discrete time. The dual (U under S -> U above S) follows by symmetry.
- [ ] **Task 1.4**: Validate Case 1 compiles and is correct. This is the gate check: if Case 1 works, the remaining 7 follow the same pattern. If Case 1 reveals fundamental type-level issues, STOP and report before proceeding.

**Timing**: 5 hours (~400-500 lines)

**Depends on**: none

**Files to create**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/SeparationDiscrete.lean` (NEW)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.SeparationDiscrete` succeeds
- Case 1 is sorry-free with correct semantics verified by `lean_verify`
- All 8 cases + duals sorry-free

**Implementation Notes**:
- The elimination equivalences are valid specifically over integer (discrete) time. In the codebase, the relevant structures satisfy `SuccOrder`, `PredOrder`, `NoMaxOrder`, `NoMinOrder`, and `semantic_prior_UZ`/`semantic_prior_SZ`. The proofs use: (a) every point has an immediate successor and predecessor, (b) U(T, bot) = "next" is definable, (c) Prior-UZ/SZ provide first-witness properties.
- The paper's "atoms" are propositional variables. In our codebase, these correspond to `Formula.atom a`. The elimination lemmas work at the formula level, not the MonadicFormula level.
- The formula `G(neg(A))` is defined as `neg(U(T, neg(neg(A))))` = `neg(U(T, A))`. Similarly `H(neg(A))` = `neg(S(T, A))`.
- Cases 2, 3, 6, 8 reduce to other cases + Lemma 10.2.2. Cases 1, 4, 5, 7 are the core semantic arguments.

---

### Phase 2: Separation Theorem (GHR94 Lemmas 10.2.4-10.2.8) [NOT STARTED]

**Goal**: Build up from the elimination cases to the full separation theorem: every formula in {U,S} is equivalent to a syntactically separated formula over discrete time.

**Literature**: GHR94 Chapter 10, Lemmas 10.2.4-10.2.8, Theorem 10.2.9.

**Tasks**:
- [ ] **Task 2.1**: Prove Lemma 10.2.4 (single-connective separation): `S(C, F)` where C and F contain at most `U(A,B)` (not nested under S) can be separated. Uses the 8 cases from Phase 1.
- [ ] **Task 2.2**: Prove Lemma 10.2.5 (single U(A,B) with arbitrary S-nesting): induction on the maximum depth of S above U(A,B). Uses Lemma 10.2.4.
- [ ] **Task 2.3**: Prove Lemma 10.2.6 (multiple U(A_i, B_i)): induction on n (number of distinct U-subformulas). Uses atom replacement technique and Lemma 10.2.5.
- [ ] **Task 2.4**: Prove Lemma 10.2.7 (nested U under S but no S under U): induction on the maximum depth of U-nesting under S. Reduces to Lemma 10.2.6 by flattening.
- [ ] **Task 2.5**: Prove Lemma 10.2.8 (the full separation lemma): induction on junction depth (alternation depth of U/S nesting). Uses Lemma 10.2.7 and the dual argument for S under U.
- [ ] **Task 2.6**: State Theorem 10.2.9 (Separation Theorem): every formula is equivalent to a separated formula over discrete time. Immediate corollary of Lemma 10.2.8.

**Timing**: 4 hours (~300-400 lines)

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/SeparationDiscrete.lean` -- continuation

**Verification**:
- `lake build` succeeds for SeparationDiscrete.lean with 0 sorries
- The separation theorem statement matches GHR94 Theorem 10.2.9

**Implementation Notes**:
- The junction depth induction (Lemma 10.2.8) requires well-founded recursion on a natural number (junction depth of the formula). Lean's built-in Nat well-foundedness suffices.
- The atom replacement technique in Lemma 10.2.6 (replacing U(A_i, B_i) with fresh atoms q_i) must be formalized as a formula substitution. This requires a substitution function on `Formula` that replaces specific subformulas with atoms.
- The "dual" arguments (S under U) are symmetric to U under S. Implement one direction and derive the other by a duality lemma if possible, or prove both directly.

---

### Phase 3: Expressive Completeness Bridge [NOT STARTED]

**Goal**: Derive {U,S} expressive completeness over Prior structures from the separation theorem, and produce P1(k) for all k as a consequence. This bridges the separation-based proof to the `kamp_prior_expressive_completeness` interface.

**Literature**: GHR94 Theorem 10.2.10, Reynolds 1994 Theorem 5, and the connection to Doets' Lemma (Chapter 9 separation -> expressive completeness bridge).

**Tasks**:
- [ ] **Task 3.1**: Prove {U,S} expressive completeness over discrete linear orders. The argument: by the separation theorem, every temporal formula is a Boolean combination of pure future, pure past, and present formulas. By Chapter 9 (specifically Doets' Lemma / the NF bridge), this implies every monadic FO formula with one free variable has a temporal equivalent. This step may use the existing `doets_lemma_1_1` or `nf_to_formula` + `nf_to_formula_correct` infrastructure.
- [ ] **Task 3.2**: Prove Reynolds Theorem 5 (US expressive completeness over Prior structures). The argument: (a) {U,S,U',S'} expressive completeness holds for all linear structures (this is `stavi_expressive_completeness` in the codebase, but we can also derive it from the separation approach for discrete time since Prior structures are discrete); (b) over Prior structures, U'(A,B) is always False (because Prior-UZ blocks definable gaps); (c) therefore {U,S} suffices.
  - Alternative simpler argument: Since Prior structures with the standard axioms model discrete linear orders, and the separation theorem gives {U,S} expressive completeness for discrete time directly, we can bypass the Stavi connectives entirely.
- [ ] **Task 3.3**: Derive `nf_characterizable_temporal_prior` for all k from expressive completeness. Given P1_all: "for all MonadicFormula sig 1 psi, there exists Formula A equivalent over Prior structures", we obtain P1(k) by applying P1_all to `nf_to_formula nf` for each `nf : NormalForm sig k 1`.
- [ ] **Task 3.4**: Construct a `kamp_prior_expressive_completeness`-compatible term from the separation-derived expressive completeness.

**Timing**: 3 hours (~200-300 lines)

**Depends on**: 2

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/SeparationDiscrete.lean` -- expressive completeness theorems
- OR a new file `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/SeparationBridge.lean` if SeparationDiscrete grows too large

**Verification**:
- The derived `nf_characterizable_temporal_prior` for all k is sorry-free
- The type signature matches KampPrior.lean:131-138

**Implementation Notes**:
- The key challenge in Task 3.1 is the bridge from "separation holds" to "expressive completeness." In GHR94, this uses Chapter 9's results on the connection between separation and expressive completeness. The codebase may have this bridge partially available via the Doets lemma infrastructure.
- Task 3.2 alternative is simpler: since Prior structures satisfy the discrete axioms (SuccOrder, PredOrder, etc.), the separation theorem applies directly to them. We don't need U'/S' at all.
- Task 3.3 uses `nf_to_formula_correct` (NormalForm.lean:719) which provides: `eval M env (nf_to_formula nf) <-> nf_eval_nf M k n env nf`. Combined with expressive completeness (every `MonadicFormula sig 1` has a temporal equivalent), this gives: for each `nf`, `nf_to_formula nf` has a temporal equivalent, which is semantically equivalent to `nf_eval_nf`.

---

### Phase 4: Fill KampPrior.lean:149 [NOT STARTED]

**Goal**: Replace the sorry at KampPrior.lean:149 with the separation-derived proof.

**Tasks**:
- [ ] **Task 4.1**: Fill the `succ k` case of `nf_characterizable_temporal_prior` using the result from Phase 3 Task 3.3. The argument: for any `nf : NormalForm sig (k+1) 1`, apply the separation-derived NF characterization to get `{A : Formula // ...}`.
- [ ] **Task 4.2**: Verify the downstream chain: `kamp_prior_expressive_completeness` -> `US_expressively_complete_over_prior` -> all consumers. Run `lean_verify` on key theorems.
- [ ] **Task 4.3**: Verify `nf_2var_exist_formula_prior` (NfCharFormula.lean:572) is resolved. If KampPrior:149 is closed, check whether the downstream sorry fills automatically via `master_induction` or `p2_from_p1_succ`. If not, provide a direct fill using `p2_from_p1_succ` with the now-sorry-free `kamp_prior_expressive_completeness`.

**Timing**: 1 hour (~30-50 lines)

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- fill sorry at line 149
- Possibly `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfCharFormula.lean` -- fill sorry at line 572

**Verification**:
- `lean_verify nf_characterizable_temporal_prior` shows no sorryAx
- `lean_verify kamp_prior_expressive_completeness` shows no sorryAx
- `lean_verify US_expressively_complete_over_prior` shows no sorryAx
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior` succeeds with 0 sorries

---

### Phase 5: Chronicle Gap Contradiction [NOT STARTED]

**Goal**: Fill the `chronicle_gap_contradiction` sorry at ChronicleToCountermodel.lean:537 using the now-sorry-free model surgery pipeline.

**Literature**: Reynolds 1994, Section 7 (Lemmas 6-13), implemented in GoodStructuresModelSurgery.lean.

**Tasks**:
- [ ] **Task 5.1**: Activate and fix the OLD PROOF block (ChronicleToCountermodel.lean:539-813). The OLD PROOF has two cases:
  - **Case A** (limit_f(a) != limit_f(b)): 95% complete. Fix the k=0 -> k >= 1 issue at line 792. Use k=1 (or any fixed k >= 1) for `contemp_equiv`. Prove `neg contemp_equiv sig 1 M a b` using the distinguishing formula psi at depth 1: the 1-var NF at a includes psi while at b it doesn't (or vice versa), giving depth-1 NF disagreement. Apply `gap_contradicts_prior` with semantic_prior_UZ/SZ (proved at lines 687-754). Estimated ~30 lines new code.
  - **Case B** (limit_f(a) = limit_f(b)): The symmetric case at line 812. Two sub-options: (a) prove Case B is vacuously impossible in Prior structures (research Finding 7 suggests this may hold but needs investigation), or (b) provide a direct chronicle-specific argument. If Case B requires a separate deep investigation, mark it as a sub-sorry with a comment and create a follow-up task.
- [ ] **Task 5.2**: Fix the symmetric case (line 812). The proof structure mirrors Case A but with the roles of a and b swapped (or ψ and ¬ψ swapped). Estimated ~50 lines if filling directly, or ~5 lines if using a lemma that handles both directions.
- [ ] **Task 5.3**: Fix the stale header comment at ChronicleToCountermodel.lean:65-77 to accurately reflect the current status.

**Timing**: 2 hours (~100-150 lines modification)

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- activate OLD PROOF, fill sorries, fix header

**Verification**:
- `lean_verify chronicle_gap_contradiction` shows no sorryAx
- `lake build Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel` succeeds

**Implementation Notes**:
- `chronicle_gap_contradiction` calls `gap_contradicts_prior` which depends on `US_expressively_complete_over_prior` via the model surgery pipeline. Phase 4 must be complete first.
- The OLD PROOF's semantic_prior_UZ/SZ proofs (lines 621-754) are independent of Kamp and are sorry-free. They build the OrderedMonadicStructure on LimitDomSubtype and prove Prior-UZ/SZ using the chronicle's C4/C5 coherence.
- ChronicleToCountermodel.lean:218 and :374 (`succ_reaches_dom_N` boundary sorries) are dead code -- do NOT attempt to fill them.

---

### Phase 6: Full Build Verification and Cleanup [NOT STARTED]

**Goal**: End-to-end verification that the critical path to `completeness_discrete` is closed (modulo Task 202 succ_cofinal chain).

**Tasks**:
- [ ] Run `lake build` (full project) -- must succeed with 0 errors
- [ ] Verify `#print axioms kamp_prior_expressive_completeness` shows no sorryAx
- [ ] Verify `#print axioms US_expressively_complete_over_prior` shows no sorryAx
- [ ] Verify `#print axioms chronicle_gap_contradiction` shows no sorryAx
- [ ] Verify `#print axioms completeness_discrete` -- remaining sorryAx should trace ONLY through Task 202 chain
- [ ] Mark NegationClosure.lean:1371 (`nf_exist_formula_nested_backward`) as bypassed dead code
- [ ] Mark NfComposition.lean as bypassed dead code
- [ ] Update ROADMAP.md: mark Kamp chain complete, chronicle gap filled

**Timing**: 1 hour

**Depends on**: 5

**Verification**:
- `lake build` succeeds (full project, clean)
- `#print axioms completeness_discrete` shows no Kamp/chronicle chain sorryAx

---

## Testing & Validation

- [x] Phase 1 (v21): Vec-EA type definitions compile, universe-correct (DONE)
- [x] Phase 2 (v21): Closure lemmas sorry-free (DONE)
- [x] Phase 3 (v21): Translation correctness sorry-free (DONE)
- [x] Phase 4 (v22): All negation closure sub-phases sorry-free (DONE)
- [x] Phase 0 (v23): Preconditions verified, VecEADecomposition quarantined (DONE)
- [ ] Phase 1 (v24): All 8 elimination cases + duals sorry-free
- [ ] Phase 2 (v24): Separation theorem sorry-free
- [ ] Phase 3 (v24): Expressive completeness bridge sorry-free, P1(k) derived
- [ ] Phase 4 (v24): KampPrior.lean:149 sorry-free, downstream chain closed
- [ ] Phase 5 (v24): chronicle_gap_contradiction sorry-free (or sorry only in Case B with justification)
- [ ] Phase 6 (v24): `lake build` clean, axiom checks pass

## Artifacts & Outputs

**Existing (phases 1-4 from v21/v22, sorry-free)**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEAFormula.lean` (~600 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEAClosure.lean` (~400 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEATranslation.lean` (~350 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure5.lean` (~800 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosureProp42.lean` (~350 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/FoToVecEA.lean` (~200 lines)

**New (v24)**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/SeparationDiscrete.lean` (~700-1200 lines) -- separation eliminations + theorem + bridge

**Modified (v24)**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- fill sorry at :149 (~30-50 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- activate OLD PROOF, fill sorries (~100-150 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure.lean` -- bypass comment at :1371 (~3 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfComposition.lean` -- bypass header (~5 lines)

**Estimated new Lean code**: ~700-1200 lines in SeparationDiscrete.lean + ~130-200 lines modifications to existing files

## Rollback/Contingency

**If Phase 1 Case 1 validation fails (elimination lemmas don't formalize for Prior structures)**:
- Investigate whether the discrete semantics in the codebase (SuccOrder + PredOrder + Prior-UZ/SZ) match the GHR94 integer-time assumptions. If not, the gap may require bridging lemmas between the two formulations.
- Fallback: implement the separation only for `IsSuccArchimedean` structures (which are the ones that matter for chronicle_gap_contradiction). This is a weaker but sufficient assumption.

**If Phase 2 junction depth induction is impractical (formula substitution too complex)**:
- Simplify: instead of the full separation theorem for all formulas, prove separation only for the specific formulas that arise from `nf_to_formula`. Since NormalForm formulas have bounded structure, the separation may be simpler.
- Fallback: prove P1(k) directly by induction on k, using the separation eliminations to handle the negation case at each depth, without proving the general separation theorem.

**If Phase 3 bridge from separation to P1(k) is blocked**:
- The bridge requires "every MonadicFormula has a temporal equivalent." If the full separation -> expressive completeness chain is too complex, try the shortcut: prove P2(k) directly using the elimination lemmas (the eliminationsexpress "exists x" as temporal when the body is already temporal), then use `nf_char_kp1_from_2var` to get P1(k+1).
- This alternative avoids the general expressive completeness theorem and proves only P1+P2 by induction, using elimination lemmas for the P2 backward direction.

**If Phase 5 Case B (constant MCS) is genuinely non-trivial**:
- Mark Case B as a separate sorry with a TODO comment
- Create a follow-up task for Case B investigation (is it vacuously impossible in Prior structures?)
- The rest of the chain (Case A + model surgery) still advances the critical path significantly

**If the approach fails entirely**:
- All existing sorry-free code (phases 1-4, ~2700 lines) remains valid
- The GHR94 separation machinery, if partially implemented, is independently valuable for other proofs
- Consider escalating to the user with a precise description of the mathematical gap: "the Feferman-Vaught composition lemma for NormalForms at depth >= 1 over discrete linear orders" with citations to the exact literature statements
