# Implementation Plan: Rabinovich via Disjunction Construction (Task #305 v29)

- **Task**: 305 - rabinovich_ea_formula_implementation
- **Status**: [NOT STARTED]
- **Effort**: 7 hours
- **Dependencies**: None (all required sorry-free infrastructure exists)
- **Research Inputs**: reports/14_faithfulness-audit.md, reports/24_z-completeness-rabinovich.md
- **Artifacts**: plans/29_disjunction-construction.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v29 replaces the stale v28 plan after the post-Boneyard codebase cleanup. Eight files (2350 lines) have been moved to Boneyard/, including FOToVEA.lean, NfExistTL.lean, and EndpointNegation.lean. Plan v28's Phase 1 is obsolete (references boneyarded files) and Phase 2 is confirmed [BLOCKED] (segment-type decomposition is structurally unprovable at VBracketFormula level).

The new approach builds Rabinovich's three-case disjunction syntactically at the V-EA formula level, bypassing the blocked model-independent biconditional entirely. The key insight from the lifting research fork: the model-dependent `neg_interval_formula` in EANegationClosure.lean uses `by_cases` on model state, but Rabinovich's actual construction builds ALL three case formulas and takes their disjunction `(Cond_A /\ Form_A) \/ (Cond_B1 /\ Form_B1) \/ (Cond_B2 /\ Form_B2)`. Each condition is a V-EA formula describing WHEN that case holds, and the cases are exhaustive by construction. This is a different abstraction layer from the blocked biconditional approach -- it works at VVecEA2 level where universal quantification is not needed.

### Research Integration

**From reports/14_faithfulness-audit.md**:
- Arity tower is not in Rabinovich; it is an artifact of NF-depth induction
- Three coexisting strategies identified; model-dependent (Strategy B) is sorry-free
- Rabinovich's chain: structural formula induction (Prop 4.3), not NF-depth

**From reports/24_z-completeness-rabinovich.md**:
- Z-transfer (Path C) ruled out
- Rabinovich chain (Path A) is sole viable route
- 800-1500 lines estimated across sub-tasks

**From lifting research fork (2026-06-23)**:
- Model-dependent `neg_interval_formula` uses `by_cases` on model state
- Trivial non-constructive lift does not work (different V-bracket per model)
- Rabinovich's actual construction: build all three case formulas, take disjunction
- Conditions are expressible as V-EA formulas; cases are exhaustive
- Estimated ~400-600 lines for `neg_interval_formula_indep`

### H3 Reference Grounding Table

| Source (Rabinovich 2014) | Lean Identifier | Status | Phase Target |
|--------------------------|-----------------|--------|-------------|
| Def 3.1 (EA formula) | VecEAFormula, BracketFormula, VecEA2 | sorry-free | -- |
| Def 3.3 (V-EA formula) | VBracketFormula, VVecEA2 | sorry-free | -- |
| Lemma 3.2.1 (conj closure) | conj_to_bracket_exists | sorry-free | -- |
| Lemma 3.2.2 (arity reduction) | (needed in existential case of Prop 4.3) | missing/implicit | Phase 3 |
| Lemma 3.4 (V-EA closure) | conj_holds_vvecEA2 + disj | sorry-free | -- |
| Prop 3.5 (V-EA 1-var -> TL) | translate_correct | sorry-free | Phase 4 (wiring) |
| Notation 5.2 | BracketFormula.holds | sorry-free | -- |
| INF formula (eq 5.2) | inf_bracket_formula, prior_hasAttainedINF | sorry-free | -- |
| Lemma 5.3 (all-betas-True) | neg_orderedPointsExist_is_vbracket | sorry-free | -- |
| Cor 5.4 forward | neg_partialBracketExist_sufficient | sorry-free | -- |
| Cor 5.4 backward (n+1) | neg_partialBracketExist_is_vbracket:1235 | SORRY (non-critical) | -- |
| Lemma 5.1 model-dep | neg_interval_formula | sorry-free | -- |
| Lemma 5.1 model-indep | neg_interval_formula_indep (NEW) | missing | Phase 2 |
| Lemma 5.1 VecEA2-level (biconditional) | neg_bracket_is_vbracket:1084 | SORRY (non-critical) | -- |
| A_i^-/A_i^+ decomposition | leftPart, rightPart, splitAt_combine | sorry-free | -- |
| Prop 4.2 model-dep | neg_2var_vec_ea | sorry-free | -- |
| Prop 4.2 model-indep | neg_2var_vec_ea_indep (NEW) | missing | Phase 2 |
| Prop 4.3 (FO -> V-EA) | fo_to_vea (NEW) | missing | Phase 3 |
| Thm 4.4 (Kamp's theorem) | kamp_prior_expressive_completeness | sorry at succ case | Phase 4 |

### Rabinovich's Chain (Ground Truth)

```
Def 3.1 -> Lemma 3.2 -> Lemma 3.4 -> Prop 3.5
                                        |
Lemma 5.3 -> Cor 5.4 -> Lemma 5.1 -> Prop 4.2 -> Prop 4.3 -> Thm 4.4
```

### Reusable Infrastructure (all sorry-free)

| File | Lines | Key Identifiers | Role |
|------|-------|-----------------|------|
| VecEAFormula.lean | 769 | VecEA2, VVecEA2, bracket formulas | 2-var EA types and semantics |
| VecEAClosure.lean | 386 | conj_holds_vvecEA2, conj_struct | Conjunction/existential closure for 2-var |
| VecEADecomp.lean | 898 | depth-0 zone decomposition | Depth-0 V-EA decomposition |
| NfToVecEA.lean | 766 | nf_2var_exist_depth0_tl | NF -> VecEA mapping |
| EANegation.lean | 1237 | neg_orderedPointsExist_is_vbracket | Lemma 5.3 (sorry-free), Cor 5.4 forward |
| EANegationClosure.lean | 567 | neg_2var_vec_ea, neg_interval_formula | Model-dep Lemma 5.1 / Prop 4.2 |
| PriorINF.lean | 245 | HasAttainedINF, inf_bracket_formula | INF formula infrastructure |
| RabinovichTranslation.lean | 302 | translate_correct | Prop 3.5: V-EA 1-var -> TL |
| VecEATranslation.lean | 297 | translateLeft, translateLeft_correct | VVecEA2 -> temporal Formula |
| ExistsForallNF.lean | 339 | nf_exists_unique, doets_lemma_1_1 | NF infrastructure |
| KampPrior.lean | 264 | kamp_prior_expressive_completeness | Main theorem (1 sorry) |

### Sorry Inventory (Pre-Plan)

| File | Line | Statement | Critical Path? | Plan Action |
|------|------|-----------|---------------|-------------|
| KampPrior.lean | 160 | succ case sorry | YES | Phase 4: replace with Prop 4.3 + Prop 3.5 |
| EANegation.lean | 1084 | neg_bracket_is_vbracket beta_0 | NO | Leave as-is (non-critical) |
| EANegation.lean | 1235 | neg_partialBracketExist backward n+1 | NO | Leave as-is (non-critical) |

## Goals & Non-Goals

**Goals**:
- Eliminate the critical-path sorry at KampPrior.lean:160
- Build model-independent `neg_interval_formula_indep` via Rabinovich's three-case disjunction
- Build model-independent Prop 4.2 (`neg_2var_vec_ea_indep`) using `neg_interval_formula_indep`
- Implement Prop 4.3 (`fo_to_vea`) via structural formula induction on MonadicFormula
- Rewire KampPrior.lean to use Prop 4.3 + Prop 3.5 instead of NF-depth chain
- Achieve sorry-free `kamp_prior_expressive_completeness`
- Maintain `lake build` success after every phase
- Clean up stale references to boneyarded files

**Non-Goals**:
- Fixing the two non-critical sorry in EANegation.lean (1084, 1235) -- these are documented as inherent VBracketFormula-level limitations
- Restoring FOToVEA.lean or NfExistTL.lean from Boneyard -- the NF-depth chain is superseded
- Building the model-independent biconditional at BracketFormula level (confirmed unprovable)
- Addressing the Stavi chain (confirmed dead)
- Fixing any Boneyard/ files

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Three-case disjunction conditions may not be expressible as V-EA formulas | H | L | Case A condition is "pointTypes(0).neg holds everywhere in (z0,z1)" which is a zero-witness BracketFormula.trivial. Case B conditions involve INF-style existential witnesses. All building blocks exist in PriorINF.lean and VecEAFormula.lean. |
| Exhaustiveness of three cases may be hard to prove in Lean | M | M | The cases are: (A) pointTypes(0) does not occur, (B1) pointTypes(0) occurs and seg0 holds on prefix, (B2) pointTypes(0) occurs and seg0 fails on prefix. This is a direct exhaustive `by_cases` on two decidable propositions. The model-dependent version already proves it. |
| Lemma 3.2.2 (arity reduction to 2-var) may not exist as a standalone lemma | M | L | Check if VecEADecomp.lean or VecEAClosure.lean already contains this implicitly. If not, build it as part of Phase 3 (~50-100 lines). It projects each EA formula onto pairs of variables and forms a conjunction. |
| Structural formula induction on MonadicFormula for Prop 4.3 may require additional closure lemmas | M | L | VecEAClosure.lean already has conjunction and disjunction closure (Lemma 3.4). The only cases are atomic (trivial), disjunction (Lemma 3.4), negation (Prop 4.2), existential (Lemma 3.4 + Lemma 3.2.2). All building blocks exist or are built in Phase 3. |
| Rewiring KampPrior.lean may require rethinking the NF-to-Formula bridge | M | M | The current proof uses NF -> characteristic formula -> temporal. The new chain goes MonadicFormula -> V-EA (Prop 4.3) -> temporal (Prop 3.5). The NF infrastructure (`doets_lemma_1_1`, `nf_exists_unique`) is still used to show NF-agreement transfers psi-agreement. The bridge is at the `nf_characterizable_temporal_prior` level, not at the top-level theorem. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

All phases are sequential. Phase 1 is lightweight cleanup. Phases 2-4 form a strict dependency chain (each builds on the previous).

---

### Phase 1: Comment Cleanup and Archival Hygiene [NOT STARTED]

**Goal**: Remove stale references to boneyarded files (FOToVEA.lean, NfExistTL.lean, EndpointNegation.lean) from active Kamp/ files. Update documentation to reflect the post-Boneyard state and the new disjunction-construction approach. Verify the codebase builds cleanly.

**Tasks**:
- [ ] **Task 1.1**: Update KampPrior.lean module docstring and inline comments
  - Remove references to FOToVEA.lean, NfExistTL.lean, `nf_exist_to_temporal_aux`
  - Remove references to NF-depth mutual induction, arity tower
  - Update the "Proof Architecture" docstring to describe the Rabinovich chain via disjunction construction
  - Update the TODO comment at line 156-159 to reference v29 plan approach
  - Remove stale imports if any reference boneyarded modules
- [ ] **Task 1.2**: Update EANegationClosure.lean documentation
  - Add note that this file provides the model-dependent foundation for the model-independent version
  - Document that `neg_interval_formula` is the model-dependent Lemma 5.1, and `neg_interval_formula_indep` (Phase 2) will be the model-independent version
- [ ] **Task 1.3**: Clean up stale imports across active Kamp/ files
  - Check all 12 active files for imports of boneyarded modules
  - Remove any stale imports
- [ ] **Task 1.4**: Verify `lake build` succeeds after cleanup
- [ ] **Task 1.5**: Run sorry audit to confirm pre-plan inventory matches expectations:
  ```
  grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ --include="*.lean" | grep -v Boneyard
  ```
  Expected: exactly 3 sorry (KampPrior:160, EANegation:1084, EANegation:1235)

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- docstring and comment cleanup (~30 lines changed)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegationClosure.lean` -- documentation additions (~10 lines)

**Verification**:
- `lake build` succeeds
- Sorry audit matches inventory (3 sorry in active files)
- No imports reference boneyarded modules

---

### Phase 2: Model-Independent Negation Closure via Disjunction Construction [NOT STARTED]

**Goal**: Build `neg_interval_formula_indep` -- a model-independent version of Lemma 5.1 -- by constructing Rabinovich's three-case disjunction syntactically. Then build `neg_2var_vec_ea_indep` (model-independent Prop 4.2) using it. This is the core technical contribution that unblocks the entire chain.

**Approach**: The model-dependent `neg_interval_formula` (EANegationClosure.lean:237-313) uses `by_cases` on model-specific predicates:
- Case A: pointTypes(0) does NOT occur in (z0, z1) --> trivial BracketFormula with negated point type
- Case B1: pointTypes(0) occurs AND segmentTypes(0) holds on prefix --> IH on tail
- Case B2: pointTypes(0) occurs AND segmentTypes(0) fails on prefix --> INF formula

The model-independent version constructs ALL three V-bracket formulas and takes their disjunction:
```
neg_interval_formula_indep(n, bf) =
  Form_A(bf) \/ Form_B1(bf, IH) \/ Form_B2(bf)
```

Each form is a VVecEA2 formula that holds EXACTLY when the corresponding case applies AND the bracket is negated. The disjunction covers all models because the three cases are exhaustive.

**Key construction details**:
- `Form_A`: A VVecEA2 with a zero-witness BracketFormula asserting pointTypes(0).neg holds everywhere in (z0, z1). This is `BracketFormula.trivial pointTypes(0).neg`.
- `Form_B1`: A VVecEA2 constructed by prepending the first-occurrence witness (via INF infrastructure) to the IH result on the tail. Uses `BracketFormula.prepend` and induction on witness count n.
- `Form_B2`: A VVecEA2 using the INF formula (`inf_bracket_formula`) to assert pointTypes(0) occurs in (z0, z1).

**Correctness**: For any model M and any z0 < z1 where the bracket fails, exactly one case applies, so the disjunction holds. The forward direction of each case is proved by the corresponding model-dependent case from `neg_interval_formula`. The key insight: we do not need the backward direction of any individual case -- only that the forward direction covers all models.

**Tasks**:
- [ ] **Task 2.1**: Create `NegationIndep.lean` with module header and imports
  - Import EANegationClosure, PriorINF, VecEAClosure, VecEAFormula
  - Document the three-case disjunction approach
- [ ] **Task 2.2**: Build `neg_interval_formula_indep` (model-independent Lemma 5.1)
  - Type signature: `(n : Nat) -> (bf : BracketFormula n) -> VVecEA2` (returns formula, not existential)
  - Base case (n = 0): construct the disjunction of Case A and Case B2 formulas
  - Inductive case (n + 1): construct the disjunction of Case A, Case B1 (using IH), and Case B2 formulas
  - Prove correctness: for all M with HasAttainedINF, z0 < z1, and bracket negated, the constructed VVecEA2 holds
  - Target: ~250-350 lines
- [ ] **Task 2.3**: Build VVecEA2 disjunction combinator if not already available
  - Check if VVecEA2 has a `disj` operation (combine disjunct lists)
  - If not, build it: concatenate disjunct lists, prove holds iff either side holds
  - Target: ~30-50 lines if needed
- [ ] **Task 2.4**: Build `neg_vecEA2_indep` (model-independent single-conjunct negation)
  - Lift from `neg_interval_formula_indep` using endpoint case analysis (same structure as model-dep `neg_vecEA2`)
  - Three sub-cases: endpoint-left fails, endpoint-right fails, both hold + bracket negated
  - Target: ~50-80 lines
- [ ] **Task 2.5**: Build `neg_2var_vec_ea_indep` (model-independent Prop 4.2)
  - Iterate `neg_vecEA2_indep` over disjunct list with conjunction closure
  - Same structure as model-dep `neg_2var_vec_ea` but using indep sub-lemmas
  - Target: ~60-100 lines
- [ ] **Task 2.6**: Verify sorry-freedom of all new definitions
  - `lean_verify` on `neg_interval_formula_indep_correct`
  - `lean_verify` on `neg_2var_vec_ea_indep`
- [ ] **Task 2.7**: Verify `lake build` succeeds

**Timing**: 3 hours

**Depends on**: 1

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationIndep.lean` -- NEW (~400-550 lines)

**Verification**:
- `neg_interval_formula_indep_correct` sorry-free (`lean_verify`)
- `neg_2var_vec_ea_indep` sorry-free (`lean_verify`)
- `lake build` succeeds
- No new sorry introduced

---

### Phase 3: Prop 4.3 -- Structural Formula Induction (FO -> V-EA) [NOT STARTED]

**Goal**: Implement Prop 4.3 via structural induction on MonadicFormula: every first-order monadic formula is equivalent to a V-EA formula on Prior structures. This is the core theorem that connects the negation closure (Phase 2) to the translation (Phase 4).

**Approach**: Structural induction on `MonadicFormula sig n`:
- **Atomic** (`pred p i`): A single predicate is trivially a VVecEA2 -- a zero-witness bracket with the predicate as a segment type.
- **Negation** (`neg phi`): By IH, phi is V-EA. Apply model-independent Prop 4.2 (`neg_2var_vec_ea_indep` from Phase 2).
- **Disjunction** (`disj phi psi`): By IH, both are V-EA. Apply Lemma 3.4 disjunction closure (`VVecEA2.disj_holds` from VecEAClosure.lean).
- **Existential** (`ex phi`): By IH, phi at arity (n+1) is V-EA. Apply Lemma 3.2.2 (arity reduction) to reduce to 2-var, then Lemma 3.4 existential closure.

**Lemma 3.2.2 dependency**: Check whether arity reduction from m-variable EA to 2-variable EA exists in VecEADecomp.lean or VecEAClosure.lean. If not, build it. For the special case needed here (MonadicFormula at arity 1 -> temporal), the existential case has arity 2, which IS 2-variable -- so Lemma 3.2.2 may not be needed at all. The formula induction at arity 1 produces: atomic at arity 1, negation at arity 1, disjunction at arity 1, and existential which takes arity-2 sub-formula. The IH gives a VVecEA2 for the arity-2 sub-formula, and then we need to quantify out one variable to get back to arity 1. This is exactly what `translate_correct` (Prop 3.5) does for the final step, but for intermediate steps we may need the existential closure from VecEAClosure.lean.

**Tasks**:
- [ ] **Task 3.1**: Analyze the MonadicFormula constructors at arity 1
  - Determine exact type signatures for each constructor case
  - Check whether existential case at arity 1 produces arity-2 sub-formula
  - Determine if Lemma 3.2.2 is needed or if existing closure lemmas suffice
- [ ] **Task 3.2**: Build Lemma 3.2.2 if needed
  - If the existential case requires arity reduction beyond what VecEAClosure provides
  - Target: ~50-100 lines if needed
- [ ] **Task 3.3**: Create `Prop43.lean` with the structural induction
  - Define `fo_to_vea : MonadicFormula sig 1 -> VVecEA2` (returns the V-EA formula)
  - Prove `fo_to_vea_correct`: for all Prior M, `v.holds M atomMap z0 z1 <-> eval M env phi` 
  - Handle each constructor case using the building blocks above
  - Target: ~200-350 lines
- [ ] **Task 3.4**: Verify sorry-freedom
  - `lean_verify` on `fo_to_vea_correct`
- [ ] **Task 3.5**: Verify `lake build` succeeds

**Timing**: 2 hours

**Depends on**: 2

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop43.lean` -- NEW (~250-400 lines)

**Verification**:
- `fo_to_vea_correct` sorry-free (`lean_verify`)
- `lake build` succeeds
- No new sorry introduced

---

### Phase 4: Wire into KampPrior.lean + Final Verification [NOT STARTED]

**Goal**: Replace the sorry at KampPrior.lean:160 (`nf_characterizable_temporal_prior` succ case) using the Rabinovich chain: Prop 4.3 (FO -> V-EA) composed with Prop 3.5 (V-EA 1-var -> TL). Verify the full chain is sorry-free. Run complete sorry audit.

**Approach**: The current `nf_characterizable_temporal_prior` at succ k has `sorry`. The new proof:
1. Given NF `nf : NormalForm sig (k+1) 1`, convert to MonadicFormula via `nf_to_formula` (sorry-free)
2. Apply Prop 4.3 (`fo_to_vea`) to get a VVecEA2 formula
3. Apply Prop 3.5 (`translate_correct`) to convert VVecEA2 to temporal Formula
4. Bridge the correctness: `nf_to_formula_correct` + `fo_to_vea_correct` + `translate_correct` gives the required temporal characterization

The NF infrastructure (`doets_lemma_1_1`, `nf_exists_unique`) and the disjunction over good NFs in `kamp_prior_expressive_completeness` remain unchanged -- only the sorry at line 160 is replaced.

**Tasks**:
- [ ] **Task 4.1**: Add imports for Prop43.lean and NegationIndep.lean to KampPrior.lean
- [ ] **Task 4.2**: Replace sorry at `nf_characterizable_temporal_prior` succ case
  - Convert NF to MonadicFormula: `nf_to_formula nf`
  - Apply Prop 4.3: `fo_to_vea (nf_to_formula nf)`
  - Apply Prop 3.5: `translate_correct ...`
  - Bridge correctness via `nf_to_formula_correct`
  - May need to restructure the proof term to handle the arity/variable matching between NF evaluation and MonadicFormula evaluation
- [ ] **Task 4.3**: Verify `kamp_prior_expressive_completeness` is sorry-free
  - `lean_verify` on the fully qualified name
- [ ] **Task 4.4**: Run `lake build` (full project)
- [ ] **Task 4.5**: Run sorry audit on the Kamp directory:
  ```
  grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ --include="*.lean" | grep -v Boneyard | grep -v "sorry-free\|-- sorry\|/- sorry"
  ```
  Expected: exactly 2 non-critical sorry remaining (EANegation.lean:1084, EANegation.lean:1235). Zero critical-path sorry.
- [ ] **Task 4.6**: Verify external API preserved
  - Type signature of `kamp_prior_expressive_completeness` unchanged
  - Any downstream consumers (PriorExpressiveness.lean, Completeness.lean) still build
- [ ] **Task 4.7**: Document final sorry inventory in orchestrator handoff

**Timing**: 1.5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- replace sorry, add imports (~50-100 lines changed)

**Verification**:
- `kamp_prior_expressive_completeness` sorry-free (`lean_verify`)
- `lake build` succeeds (all jobs)
- Sorry audit shows exactly 2 non-critical sorry in EANegation.lean
- External API unchanged

## Testing & Validation

- [ ] Phase 1: `lake build` succeeds after comment cleanup
- [ ] Phase 1: Sorry audit confirms 3 sorry in active files
- [ ] Phase 2: `neg_interval_formula_indep_correct` sorry-free (`lean_verify`)
- [ ] Phase 2: `neg_2var_vec_ea_indep` sorry-free (`lean_verify`)
- [ ] Phase 2: `lake build` succeeds
- [ ] Phase 3: `fo_to_vea_correct` sorry-free (`lean_verify`)
- [ ] Phase 3: `lake build` succeeds
- [ ] Phase 4: `kamp_prior_expressive_completeness` sorry-free (`lean_verify`)
- [ ] Phase 4: Sorry audit: 0 critical-path sorry, 2 non-critical sorry
- [ ] Phase 4: External API preserved (type signatures unchanged)
- [ ] Phase 4: Full `lake build` succeeds

## Artifacts & Outputs

- `specs/305_rabinovich_ea_formula_implementation/plans/29_disjunction-construction.md` -- this plan
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationIndep.lean` -- NEW (~400-550 lines, model-independent Lemma 5.1 + Prop 4.2 via disjunction construction)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop43.lean` -- NEW (~250-400 lines, structural formula induction)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- MODIFIED (sorry eliminated, imports and docs updated)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegationClosure.lean` -- MODIFIED (documentation only)

## Rollback/Contingency

- **Full rollback**: `git checkout -- Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` restores all files. Delete new files `NegationIndep.lean` and `Prop43.lean`.
- **Phase 2 blocked** (three-case disjunction harder than expected): The model-dependent chain in EANegationClosure.lean remains sorry-free. If the disjunction construction cannot express conditions as V-EA formulas, consider a non-constructive lifting argument using `Classical.choice` over the model-dependent construction. Specifically: use `Classical.choice` to select, for each model, the VVecEA2 witness from `neg_2var_vec_ea`, then show these witnesses are equal (since VVecEA2 is a pure syntactic type, the same formula works for all models).
- **Phase 3 blocked** (structural induction has unexpected case): MonadicFormula is a simple inductive type with pred, neg, disj, ex constructors. If the existential case is complex due to arity handling, introduce an intermediate lemma for arity-2 to arity-1 reduction.
- **Phase 4 blocked** (composition mismatch between Prop 4.3 and Prop 3.5): The types should align since Prop 4.3 produces VVecEA2 and Prop 3.5 translates VVecEA2 to temporal Formula. If there is a mismatch in free variable handling, use VecEATranslation.lean helpers for the bridge.
- **Partial value**: Even completing Phases 1-2 has independent value -- the model-independent negation closure is a clean result regardless of whether Phases 3-4 complete.
