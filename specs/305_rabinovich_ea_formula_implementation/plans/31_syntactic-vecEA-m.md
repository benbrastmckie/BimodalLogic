# Implementation Plan: Syntactic VecEA_m Design (Task #305 v31)

- **Task**: 305 - rabinovich_ea_formula_implementation
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: None (all prerequisite sorry-free infrastructure exists; plan v30 Phase 1 completed)
- **Research Inputs**: reports/16_syntactic-vea-design.md, reports/15_arity-tower-deviation.md, reports/14_faithfulness-audit.md
- **Artifacts**: plans/31_syntactic-vecEA-m.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v31 replaces plan v30's blocked Phases 2-4 with a syntactic VecEA_m type design derived from report 16. Plan v30 Phase 1 (Boneyard archival of Prop43.lean, k=1 dependency inlining into KampPrior.lean) is COMPLETE and preserved. The semantic IsVEA predicate approach (ArityReduction.lean) failed because existential projections do not commute with negation at arity >= 3. The replacement design uses a syntactic type VecEA_m encoding a V-EA formula as a consecutive-pair product of VVecEA2 components plus endpoint predicates, directly encoding Rabinovich's Lemma 3.2(2). Negation operates via de Morgan on the conjunction of components, requiring only the forward direction of Prop 4.2 (already sorry-free) plus a provable backward direction. Estimated 950-1630 new lines across 2 new files, 2 modified files, and 1 archived file.

### Research Integration

**From reports/16_syntactic-vea-design.md (primary)**:
- Root cause confirmed: semantic IsVEA predicate fails because `neg(exists env, P(env)) = forall env, neg P(env)`, not `exists env, neg P(env)`, at arity >= 3
- Option (d) consecutive-pair decomposition chosen: VecEA_m is m-1 VVecEA2 components + m endpoint predicates
- Concrete type signatures for VecEA_m, VVecEA_m, holds, neg, conj, disj, existClosure provided
- Backward direction of Prop 4.2 assessed as straightforward case analysis (~100-150 lines)
- Existential closure identified as highest risk (absorbing first variable into endpoint predicate)
- H3 mapping table with 22 Rabinovich concepts -> Lean 4 types/functions
- Total estimate: 950-1630 lines

**From reports/15_arity-tower-deviation.md**:
- NF-depth induction creates depth-arity coupling absent from Rabinovich
- Structural formula induction at all arities simultaneously eliminates the tower

**From reports/14_faithfulness-audit.md**:
- Model-independent disjunction approach (NegationIndep.lean) is the correct strategy
- All other Rabinovich chain components are sorry-free and faithful

### Prior Plan Reference

**From plan v30 (structural-induction-refactor.md)**:
- Phase 1 completed: Prop43.lean archived, k=1 deps inlined into KampPrior.lean (~150 lines changed)
- Phase 2 blocked: IsVEA predicate negation closure fails at arity >= 3 (correlated existentials, VVecEA2 biconditional missing)
- Lesson: predicate approach saves ~200-400 lines but fails structurally; a syntactic type is required
- Effort calibration: Phase 1 took ~1 hour as estimated; Phase 2 hit fundamental design blocker after ~2 hours of attempts
- Risk validated: "Lemma 3.2(2) existential closure harder than expected" materialized as the core problem was not existential closure but negation of existential projections

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Eliminate the sole critical-path sorry at KampPrior.lean:287 (succ succ k' case)
- Define syntactic VecEA_m and VVecEA_m types encoding V-EA formulas at arbitrary arity
- Prove backward direction of Prop 4.2 (neg_2var_vec_ea_indep_backward)
- Implement VecEA_m closure operations: neg, conj, disj, existClosure
- Implement Prop 4.3 (fo_to_vecEA_m): structural induction MonadicFormula -> VVecEA_m
- Specialize arity-1 VVecEA_m to interface with existing VVecEA2/Prop 3.5 translation
- Rewire KampPrior.lean: nf_to_formula -> fo_to_vecEA_m -> specialize to VVecEA2 -> translateLeft
- Achieve sorry-free `kamp_prior_expressive_completeness`
- Archive ArityReduction.lean (failed IsVEA predicate) to Boneyard
- Maintain `lake build` success after every phase
- Preserve all existing sorry-free code

**Non-Goals**:
- Fixing the two non-critical sorrys in EANegation.lean (1084, 1235)
- Building model-dependent VVecEA2 negation biconditional (not needed with de Morgan approach)
- Defining VecEA_m for arities m > 2 with full correctness proofs beyond what Prop 4.3 needs
- Addressing completeness_discrete or any sorry chain above KampPrior

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Existential closure (VecEA_m.existClosure) requires bounded existential over left endpoint, interfacing with VVecEA2 translation infrastructure | H | M | At arity 1 (the only case KampPrior needs), existential closure VecEA_m 2 -> VVecEA_m 1 absorbs one interval into an endpoint. This is the simplest case. If general existClosure is hard, implement arity-2-to-1 specialization only. |
| neg_2var_vec_ea_indep_backward requires case analysis on three-case construction; may surface subtleties in TemporalPred negation semantics | M | L | The construction has three clear cases (endpointLeft.neg, endpointRight.neg, bracket negation). Each case is a direct contradiction via TemporalPred.eval_at_neg'. Well-scoped at ~100-150 lines. |
| fo_to_vecEA_m atomic case requires constructing VecEA_m from MonadicFormula.atom, which places a predicate at a specific variable position | M | M | At arity 1, atom p 0 is just a temporal predicate -- a VecEA_m 1 with the predicate at position 0 and no interval components. At arity 2, atom p i places the predicate at endpoint i. The construction is straightforward once VecEA_m semantics are defined. |
| Type alignment between VVecEA_m 1 specialization and existing VVecEA2 used by Prop 3.5 translation | M | M | VVecEA_m 1 has zero interval components and one endpoint predicate. It should map directly to a temporal predicate Formula, not through VVecEA2. The Prop 3.5 path may need to be bypassed for the arity-1 case, going directly to temporal formula. Fallback: produce a trivial VVecEA2 wrapping the endpoint predicate. |
| VecEA_m.neg correctness proof may be complex due to de Morgan across endpoint and interval components | M | L | The de Morgan is exact (finite conjunction -> finite disjunction). Each negated component produces a VecEA_m with one component changed. The disjunction is VVecEA_m by definition. Follow report 16 construction exactly. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

All phases are strictly sequential. Each phase depends on the previous one.

---

### Phase 1: Backward Prop 4.2 + Cleanup [BLOCKED]

**Goal**: Prove the backward direction of Prop 4.2 (`neg_2var_vec_ea_indep_backward`) in NegationIndep.lean, archive ArityReduction.lean to Boneyard, and verify the build.

**BLOCKER** (Phase 1):
- **What failed**: `neg_2var_vec_ea_indep_backward` is unprovable with the current bracket negation construction.
- **What was tried**: Attempted case analysis on neg_vecEA2_indep disjuncts. Cases 1a (endpoint left neg) and 1b (endpoint right neg) give direct contradictions via TemporalPred.eval_at_neg'. Case 23 (bracket negation) requires showing that neg_interval_formula_indep disjuncts are disjoint from the original bracket formula. Case A (pt(0).neg everywhere) and B1 initial sub-case give contradictions. However, case B2 (inf_bracket_formula) is NOT disjoint from the original bracket: a concrete counterexample exists where both the original bracket and the INF bracket formula hold simultaneously on (z0, z1).
- **Counterexample**: Take bf with n=1, pt(0)=P, pt(1)=Q, all segments=top. On interval (0,10) with P holding only at 5, Q at 8: bf.holds with witnesses (5,8), and inf_bracket_formula(P) holds with witness 5 (P.neg on (0,5)). Both hold simultaneously.
- **Why it's stuck**: The codebase's case B.2 construction (inf_bracket_formula) only encodes "alpha_0 exists with alpha_0.neg before it", but Rabinovich's paper case B.2 encodes "alpha_0 exists with BOTH alpha_0.neg AND beta_0.neg before it". The codebase's construction is too weak for the biconditional -- it's sound (forward) but not complete (backward). Fixing this requires modifying neg_interval_formula_indep (currently sorry-free) and its forward correctness proof, which is a significant rewrite.
- **What is needed**: Either (1) modify neg_interval_formula_indep to encode beta_0 failure in case B.2, reproducing the full Rabinovich biconditional (requires rewriting ~100 lines of sorry-free forward proof + ~100 lines new backward proof), or (2) find an alternative proof architecture for Prop 4.3 that avoids the bracket negation biconditional entirely.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder.

**Tasks**:
- [ ] **Task 1.1**: Add `neg_2var_vec_ea_indep_backward` to NegationIndep.lean *(deviation: blocked -- see BLOCKER above)*
  - Statement: `(neg_2var_vec_ea_indep v).holds M atomMap z0 z1 -> not (v.holds M atomMap z0 z1)` on Prior structures
  - Proof by case analysis on which disjunct of `neg_2var_vec_ea_indep v` holds:
    - case1a: `endpointLeft.neg` holds -> contradicts `endpointLeft` in v.holds via `TemporalPred.eval_at_neg'`
    - case1b: `endpointRight.neg` holds -> contradicts `endpointRight` in v.holds via `TemporalPred.eval_at_neg'`
    - case23: `neg_interval_formula_indep` holds -> contradicts bracket component in v.holds
  - Requires `neg_interval_formula_indep_backward` (backward direction for the bracket negation case, also by case analysis on the construction in NegationIndep.lean lines 61-84)
  - Target: ~100-150 lines total
- [x] **Task 1.2**: Move `ArityReduction.lean` to `Boneyard/ArityReduction.lean` *(completed)*
  - No active imports reference ArityReduction
- [x] **Task 1.3**: Verify `lake build` succeeds *(completed -- build passes after archival)*
- [ ] **Task 1.4**: Sorry audit of NegationIndep.lean confirms zero sorry *(deviation: skipped -- NegationIndep.lean unchanged, already sorry-free)*

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationIndep.lean` -- add backward direction (~100-150 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ArityReduction.lean` -- move to Boneyard
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Boneyard/ArityReduction.lean` -- archived file
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- remove ArityReduction import if present

**Verification**:
- `lean_verify` on `neg_2var_vec_ea_indep_backward` shows no sorryAx
- `lake build` succeeds
- NegationIndep.lean remains sorry-free
- No active imports reference ArityReduction

---

### Phase 2: VecEA_m / VVecEA_m Types and Operations [NOT STARTED]

**Goal**: Define the syntactic VecEA_m and VVecEA_m types and implement all closure operations (neg, conj, disj, existClosure) with correctness proofs.

**Tasks**:
- [ ] **Task 2.1**: Create new file `VecEAGeneral.lean` with module header and imports
  - Import VecEAClosure, NegationIndep, VecEAFormula, ExistsForallNF, MonadicFO
  - Document the consecutive-pair product design and its relationship to Rabinovich Def 3.1/3.3
- [ ] **Task 2.2**: Define `VecEA_m` structure
  ```lean
  structure VecEA_m (m : Nat) where
    endpointPreds : Fin m -> TemporalPred
    intervalComponents : Fin (m - 1) -> VVecEA2
  ```
  - Define `VecEA_m.holds` semantics: env strictly increasing AND all endpoint predicates hold AND all interval components hold on consecutive pairs
  - Target: ~80-120 lines
- [ ] **Task 2.3**: Define `VVecEA_m` (disjunction wrapper)
  ```lean
  structure VVecEA_m (m : Nat) where
    disjuncts : List (VecEA_m m)
  ```
  - Define `VVecEA_m.holds` semantics: exists a disjunct that holds
  - Define `VVecEA_m.trivialTrue` and `VVecEA_m.trivialFalse` for base cases
  - Target: ~40-60 lines
- [ ] **Task 2.4**: Implement `VVecEA_m.disj` (disjunction closure, Lemma 3.4)
  - Concatenate disjunct lists
  - Correctness proof: trivial from list membership
  - Target: ~20-30 lines
- [ ] **Task 2.5**: Implement `VVecEA_m.conj` (conjunction closure, Lemma 3.4)
  - Cartesian product of disjunct lists, conjoining each pair pointwise
  - Each pair: conjoin endpoint predicates via `TemporalPred.conj`, conjoin interval components via `VVecEA2.conj_struct`
  - Correctness proof: from VVecEA2.conj_struct correctness
  - Target: ~60-100 lines
- [ ] **Task 2.6**: Implement `VecEA_m.neg` (single-conjunct negation via de Morgan + Prop 4.2)
  - Produce m endpoint-failure disjuncts (negate one endpoint, trivialize all others)
  - Produce m-1 interval-failure disjuncts (negate one interval component via `neg_2var_vec_ea_indep`, trivialize all others)
  - Result is a VVecEA_m
  - Target: ~100-180 lines including correctness
- [ ] **Task 2.7**: Implement `VVecEA_m.neg` (disjunction negation)
  - `not(d1 or d2 or ... or dk)` = `not d1 and not d2 and ... and not dk`
  - Fold with `VVecEA_m.conj` over negated disjuncts
  - Correctness proof: from VecEA_m.neg correctness + VVecEA_m.conj correctness
  - Target: ~50-80 lines
- [ ] **Task 2.8**: Implement `VecEA_m.existClosure` (Lemma 3.2(3) / Lemma 3.4)
  - `VecEA_m (m + 1) -> VVecEA_m m`
  - Absorb first variable: new endpoint(k) = old endpoint(k+1), new interval(k) = old interval(k+1)
  - The absorbed part (endpoint(0) + interval(0)) contributes existentially: `exists z0 < z1, endpoint(0)(z0) and interval(0).holds(z0, z1)` becomes a temporal condition at z1
  - This temporal condition is expressible via VVecEA2 infrastructure (Since modality or existsBounded)
  - Target: ~150-250 lines (highest complexity in this phase)
- [ ] **Task 2.9**: Verify sorry-freedom of all definitions and theorems
- [ ] **Task 2.10**: Verify `lake build` succeeds

**Timing**: 3.5 hours

**Depends on**: 1

**Files to create**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEAGeneral.lean` -- NEW (~500-820 lines)

**Verification**:
- All closure operations sorry-free (`lean_verify`)
- `lake build` succeeds
- No new sorry introduced

---

### Phase 3: Prop 4.3 Structural Induction + Arity-1 Specialization [NOT STARTED]

**Goal**: Implement Prop 4.3 (`fo_to_vecEA_m`): every MonadicFormula at arity m is equivalent to a VVecEA_m on Prior structures. Specialize arity-1 result for KampPrior interface.

**Tasks**:
- [ ] **Task 3.1**: Create new file `StructuralInduction.lean` (or add to VecEAGeneral.lean)
  - Import VecEAGeneral (Phase 2), NegationIndep, VecEAClosure, MonadicFO
  - Document Prop 4.3 and the structural induction approach
- [ ] **Task 3.2**: Implement `fo_to_vecEA_m` -- Prop 4.3 at all arities
  ```lean
  noncomputable def fo_to_vecEA_m
      {sig : MonadicSignature} {m : Nat}
      (atomMap : Formula -> sig.preds)
      (phi : MonadicFormula sig m) :
      { v : VVecEA_m m //
        forall (M : OrderedMonadicStructure sig)
          (h_UZ : semantic_prior_UZ M atomMap)
          (h_SZ : semantic_prior_SZ M atomMap)
          (env : Fin m -> M.carrier)
          (h_ord : forall i j : Fin m, i < j -> env i < env j),
          v.holds M atomMap env <-> eval M env phi }
  ```
  - Cases by structural induction on phi:
    - `.atom p i`: VecEA_m with predicate at position i, trivial elsewhere
    - `.lt i j`: VecEA_m trivially true (if i < j, ordering ensures truth) or trivially false
    - `.not alpha`: IH gives VVecEA_m for alpha; apply VVecEA_m.neg
    - `.and alpha beta`: IH gives VVecEA_m for both; apply VVecEA_m.conj
    - `.ex alpha`: IH at arity m+1 gives VVecEA_m (m+1) for alpha; apply existClosure
    - `.all alpha`: `all alpha = not (ex (not alpha))`; compose IH + neg + existClosure + neg
  - Target: ~200-350 lines
- [ ] **Task 3.3**: Implement arity-1 specialization
  - `VVecEA_m 1` has zero interval components per disjunct, only endpoint predicates
  - Extract a temporal Formula from VVecEA_m 1: disjunction of endpoint predicate formulas
  - Bridge correctness: `toTemporal_correct : temporal_truth M atomMap t A <-> v.holds M atomMap (fun _ => t)`
  - Target: ~80-150 lines
- [ ] **Task 3.4**: Implement arity-2 specialization (if needed for KampPrior bridge)
  - `VVecEA_m 2` has one interval component (a VVecEA2) per disjunct plus two endpoint predicates
  - Map to `VVecEA2` for use with existing `VVecEA2.translateLeft` (Prop 3.5)
  - This may not be needed if the arity-1 specialization handles the KampPrior case directly
  - Target: ~50-100 lines (conditional)
- [ ] **Task 3.5**: Verify sorry-freedom of `fo_to_vecEA_m` and specializations
- [ ] **Task 3.6**: Verify `lake build` succeeds

**Timing**: 2.5 hours

**Depends on**: 2

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/StructuralInduction.lean` -- NEW (~330-600 lines)

**Verification**:
- `fo_to_vecEA_m` sorry-free (`lean_verify`)
- Arity-1 specialization sorry-free (`lean_verify`)
- `lake build` succeeds
- No new sorry introduced

---

### Phase 4: KampPrior Rewiring + Final Verification [NOT STARTED]

**Goal**: Replace the sorry at KampPrior.lean:287 (succ succ k' case) using the Rabinovich chain: NF -> MonadicFormula -> VVecEA_m (Prop 4.3) -> temporal Formula (arity-1 specialization). Verify zero critical-path sorry. Full build pass.

**Tasks**:
- [ ] **Task 4.1**: Add imports for StructuralInduction.lean (and VecEAGeneral.lean) to KampPrior.lean
- [ ] **Task 4.2**: Replace sorry at line 287 (succ succ k' case)
  - The proof chain:
    1. `nf_to_formula nf : MonadicFormula sig 1` (existing, sorry-free)
    2. `fo_to_vecEA_m atomMap (nf_to_formula nf) : { v : VVecEA_m 1 // ... }` (Prop 4.3, Phase 3)
    3. `v.toTemporal : Formula` (arity-1 specialization, Phase 3)
    4. Compose correctness: `nf_to_formula_correct` + `fo_to_vecEA_m` correctness + `toTemporal_correct`
  - The result type: `{ A : Formula // forall M h_UZ h_SZ t, temporal_truth M atomMap t A <-> nf_eval_nf M k 1 (fun _ => t) nf }`
  - May need `semantic_prior_implies_hasAttainedINF` for Prior-structure hypotheses
  - Target: ~50-100 lines
- [ ] **Task 4.3**: Verify `kamp_prior_expressive_completeness` is sorry-free
  - `lean_verify Bimodal.Metalogic.WeakCanonical.Kamp.kamp_prior_expressive_completeness`
- [ ] **Task 4.4**: Run `lake build` (full project)
- [ ] **Task 4.5**: Run sorry audit on Kamp directory
  ```
  grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ --include="*.lean" | grep -v Boneyard | grep -v "sorry-free\|-- sorry\|/- sorry\|sorry_free\|sorryAx\|sorry_elim"
  ```
  Expected: exactly 2 non-critical sorry remaining (EANegation.lean:1084, EANegation.lean:1235). Zero critical-path sorry.
- [ ] **Task 4.6**: Verify external API preserved
  - Type signature of `kamp_prior_expressive_completeness` unchanged
  - Downstream consumers (PriorExpressiveness.lean, Completeness.lean) still build
- [ ] **Task 4.7**: Update orchestrator handoff JSON with completion status

**Timing**: 2 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- replace sorry, add imports (~50-100 lines changed)

**Verification**:
- `kamp_prior_expressive_completeness` sorry-free (`lean_verify`)
- `lake build` succeeds (all jobs)
- Sorry audit shows exactly 2 non-critical sorry in EANegation.lean
- External API unchanged (type signatures preserved)
- No new sorry introduced anywhere in codebase

## Testing & Validation

- [ ] Phase 1: `neg_2var_vec_ea_indep_backward` sorry-free (`lean_verify`)
- [ ] Phase 1: NegationIndep.lean remains sorry-free
- [ ] Phase 1: ArityReduction.lean archived, no active imports reference it
- [ ] Phase 1: `lake build` succeeds
- [ ] Phase 2: All VecEA_m/VVecEA_m closure operations sorry-free (`lean_verify`)
- [ ] Phase 2: `lake build` succeeds
- [ ] Phase 3: `fo_to_vecEA_m` sorry-free (`lean_verify`)
- [ ] Phase 3: Arity-1 specialization sorry-free (`lean_verify`)
- [ ] Phase 3: `lake build` succeeds
- [ ] Phase 4: `kamp_prior_expressive_completeness` sorry-free (`lean_verify`)
- [ ] Phase 4: Sorry audit: 0 critical-path sorry, 2 non-critical sorry (EANegation.lean)
- [ ] Phase 4: External API preserved (type signatures unchanged)
- [ ] Phase 4: Full `lake build` succeeds

## Artifacts & Outputs

- `specs/305_rabinovich_ea_formula_implementation/plans/31_syntactic-vecEA-m.md` -- this plan
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Boneyard/ArityReduction.lean` -- archived failed IsVEA predicate
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationIndep.lean` -- MODIFIED: backward direction added (~100-150 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEAGeneral.lean` -- NEW (~500-820 lines): VecEA_m/VVecEA_m types + closure operations
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/StructuralInduction.lean` -- NEW (~330-600 lines): Prop 4.3 + arity-1 specialization
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- MODIFIED: sorry eliminated (~50-100 lines changed)

## Rollback/Contingency

- **Full rollback**: `git checkout -- Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` restores all files. Delete new files `VecEAGeneral.lean` and `StructuralInduction.lean`. Move `Boneyard/ArityReduction.lean` back.
- **Phase 1 blocked** (backward Prop 4.2 harder than expected): The backward direction may require more detailed case analysis on `neg_interval_formula_indep`. If TemporalPred.eval_at_neg' is insufficient, try proving disjointness directly from the bracket formula construction. Budget 50 extra lines.
- **Phase 2 blocked** (existential closure too complex at general arity): Implement only the arity-2-to-1 case. Since KampPrior only needs arity 1, the existential case in fo_to_vecEA_m only goes from MonadicFormula sig 2 to VVecEA_m 1. This avoids the general existClosure and directly absorbs the single interval component into an endpoint predicate. Saves ~100 lines at the cost of not supporting arities > 2.
- **Phase 3 blocked** (atomic case at arbitrary arity is complex): For the KampPrior path, only arity 1 and arity 2 matter. Implement fo_to_vecEA_m only at these arities via mutual recursion rather than arbitrary-arity structural induction. This is a fallback that trades generality for tractability.
- **Phase 4 blocked** (type mismatch between VVecEA_m 1 and existing temporal Formula infrastructure): If toTemporal does not compose cleanly with `nf_to_formula_correct`, introduce an intermediate bridge lemma that directly converts VVecEA_m 1 semantics to temporal_truth semantics. The bridge should be ~30-50 lines since VVecEA_m 1 holds reduces to a disjunction of endpoint predicates.
- **Partial value**: Even Phases 1-2 alone have standalone value -- the VecEA_m type and backward Prop 4.2 are reusable infrastructure for any future formalization needing V-EA formulas at arbitrary arity.
