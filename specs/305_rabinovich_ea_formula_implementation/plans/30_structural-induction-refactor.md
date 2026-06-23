# Implementation Plan: Structural Induction Refactor (Task #305 v30)

- **Task**: 305 - rabinovich_ea_formula_implementation
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: None (all prerequisite sorry-free infrastructure exists from v29 Phases 1-3)
- **Research Inputs**: reports/15_arity-tower-deviation.md, reports/14_faithfulness-audit.md, reports/24_z-completeness-rabinovich.md
- **Artifacts**: plans/30_structural-induction-refactor.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v30 replaces the blocked NF-depth induction approach (arity tower at KampPrior.lean:154) with Rabinovich's actual proof architecture: structural formula induction on MonadicFormula at all arities simultaneously (Prop 4.3). The arity tower -- where depth-(k+1) arity-2 NF existentials require depth-k arity-3 NFs, and so on -- is an artifact of choosing NF-depth induction, not present in Rabinovich's proof. Rabinovich avoids arity growth entirely via Lemma 3.2(2): every m-variable EA formula decomposes into a conjunction of 2-variable EAs, creating a firewall that keeps the negation closure (Prop 4.2) operating at arity 2 regardless of how deep the formula nests quantifiers.

The plan builds four new components: (1) archive stale NF-depth infrastructure to Boneyard, (2) define a predicate-based V-EA property at arbitrary arity and implement Lemma 3.2(2) as the arity firewall, (3) implement Prop 4.3 via structural induction on MonadicFormula using Lemma 3.2(2) + Prop 4.2 + Lemma 3.4, (4) rewire KampPrior.lean to route through the MonadicFormula -> V-EA (Prop 4.3) -> temporal (Prop 3.5) chain. Estimated 700-1200 lines across 3-4 new or modified files.

### Research Integration

**From reports/15_arity-tower-deviation.md (primary)**:
- Root cause: NF-depth induction creates depth-arity coupling absent from Rabinovich
- Lemma 3.2(2) is the critical missing firewall -- reduces m-variable EA to conjunction of 2-variable EAs
- Structural formula induction at all arities simultaneously eliminates the tower
- Estimated 700-1200 lines for the full refactor

**From reports/14_faithfulness-audit.md (primary)**:
- H3 grounding table confirms: Prop 4.3 and Lemma 3.2(2) are the two missing pieces
- All other Rabinovich chain components are sorry-free and faithful
- Three coexisting strategies identified; model-independent disjunction (NegationIndep.lean) is the right one
- 700-1050 line estimate for the full chain

**From reports/24_z-completeness-rabinovich.md (primary)**:
- Z-transfer (Path C) ruled out by three independent blockers
- Stavi chain (Path B) confirmed dead (mathematically false)
- Rabinovich chain (Path A) is the sole viable route
- Prop 4.3 needs to handle all arities; arity-1-only is insufficient

### Prior Plan Reference

**From plan v29 (disjunction-construction.md)**:
- Phases 1-3 completed and sorry-free: comment cleanup, NegationIndep.lean (model-independent Lemma 5.1 + Prop 4.2, 328 lines), Prop43.lean (NF-depth infrastructure, 196 lines)
- Phase 4 blocked at arity tower: the k >= 2 case in `nf_characterizable_temporal_prior` requires arity > 2
- Lesson learned: disjunction construction successfully solved the model-independence problem but does not address arity growth
- Lesson learned: the depth-0/depth-1 cases work because arity stays at 2; the general case needs the arity firewall
- Lesson learned: existing NF-depth infrastructure (Prop43.lean) is correctly named for what it does (NF machinery) but misnamed relative to Rabinovich's Prop 4.3

### Roadmap Alignment

No ROADMAP.md items directly relevant to this plan.

## Goals & Non-Goals

**Goals**:
- Eliminate the sole critical-path sorry at KampPrior.lean:154 (`nf_characterizable_temporal_prior` succ succ k' case)
- Implement Lemma 3.2(2): m-variable EA formula -> conjunction of 2-variable EA formulas
- Implement Prop 4.3: structural formula induction proving every MonadicFormula is V-EA
- Rewire KampPrior.lean to use MonadicFormula -> V-EA (Prop 4.3) -> temporal (Prop 3.5) chain
- Achieve sorry-free `kamp_prior_expressive_completeness`
- Preserve all existing sorry-free code (NegationIndep.lean, k=0/k=1 cases, VecEA infrastructure)
- Maintain `lake build` success after every phase
- Archive stale NF-depth infrastructure to Boneyard

**Non-Goals**:
- Fixing the two non-critical sorrys in EANegation.lean (1084, 1235) -- documented inherent VBracketFormula-level limitations
- Restoring any boneyarded files -- the NF-depth chain is superseded
- Building the model-independent biconditional at BracketFormula level (confirmed unprovable)
- Defining a full concrete VecEA_m type (predicate approach is lighter and sufficient)
- Addressing completeness_discrete or any other sorry chain above KampPrior

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Generalized V-EA predicate at arbitrary arity m is harder to define than expected | H | M | Start with the simplest formulation: `is_VEA (phi : MonadicFormula sig m)` as a Prop asserting phi is equivalent to some VVecEA2 on all pairs of variables. Fall back to arity-2-only predicate if generalization is blocked. |
| Lemma 3.2(2) projection to variable pairs requires complex index arithmetic | M | M | Use `MonadicFormula.subst` and `Fin.castSucc`/`Fin.last` for variable renaming. The projection only needs to fix 2 variables and existentially quantify the rest. Keep the construction at MonadicFormula level rather than bracket level. |
| Structural induction on MonadicFormula at all arities simultaneously requires a strong IH | H | M | The IH is naturally available: Lean's structural recursion on MonadicFormula gives the IH for all sub-formulas regardless of arity. The challenge is that `ex` increases arity, which changes the V-EA target type. The predicate approach handles this because `is_VEA` works at any arity. |
| Negation case in Prop 4.3 requires Lemma 3.2(2) + Prop 4.2 composition, which may have type mismatches | M | L | NegationIndep.lean's `neg_2var_vec_ea_indep` operates on VVecEA2. The composition is: V-EA at arity m -> (Lemma 3.2(2)) -> conjunction of 2-var V-EAs -> (Prop 4.2 on each) -> V-EA. VVecEA2 conjunction closure is already in VecEAClosure.lean. |
| Rewiring KampPrior.lean may require restructuring `nf_characterizable_temporal_prior` | M | L | The succ succ k' case is a clean sorry site. The new proof converts the NF to MonadicFormula via `nf_to_formula` (sorry-free), applies Prop 4.3, then Prop 3.5. The NF infrastructure and k=0/k=1 cases are untouched. |

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

### Phase 1: Boneyard Archival and Documentation Update [COMPLETED]

**Goal**: Archive Prop43.lean to Boneyard (it implements NF-depth infrastructure, not Rabinovich's Prop 4.3). Update KampPrior.lean to remove reliance on the archived file. Clean stale documentation references. Verify the codebase builds after removal.

**Tasks**:
- [ ] **Task 1.1**: Move `Prop43.lean` to `Boneyard/Prop43.lean`
  - The file contains `nf_succ_char_formula`, `nf_succ_char_formula_correct`, `nf_2var_exist_depth0_tl_fn` -- all NF-depth machinery
  - These are used ONLY by KampPrior.lean's k=1 case
- [ ] **Task 1.2**: Inline the k=1 case dependencies into KampPrior.lean
  - Move `nf_succ_char_formula`, `nf_succ_char_formula_correct`, `nf_2var_exist_depth0_tl_fn`, `nf_2var_exist_depth0_tl_fn_correct` into KampPrior.lean (they total ~130 lines)
  - Update KampPrior.lean imports to remove `import Bimodal.Metalogic.WeakCanonical.Kamp.Prop43`
  - Add imports for NfToVecEA and other dependencies that Prop43.lean was pulling in
- [ ] **Task 1.3**: Update KampPrior.lean docstring
  - Replace "arity tower" comments at lines 38-39 and 113-114 with references to v30 plan
  - Update the "Proof Architecture" section to describe the new approach: structural formula induction -> V-EA -> temporal
  - Document that k=0 and k=1 use NF-depth (sorry-free, preserved), k >= 2 will use Prop 4.3
- [ ] **Task 1.4**: Verify `lake build` succeeds after archival
- [ ] **Task 1.5**: Sorry audit confirms exactly 3 sorrys in active Kamp/ files:
  - KampPrior.lean:154 (critical, unchanged)
  - EANegation.lean:1084 (non-critical)
  - EANegation.lean:1235 (non-critical)

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop43.lean` -- move to Boneyard
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Boneyard/Prop43.lean` -- archived file
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- inline k=1 dependencies, update docstring and imports (~150 lines changed)

**Verification**:
- `lake build` succeeds
- Sorry audit matches inventory (3 sorry in active files)
- No imports reference `Prop43` from active files
- k=0 and k=1 cases remain sorry-free in KampPrior.lean

---

### Phase 2: Generalized V-EA Predicate and Lemma 3.2(2) Arity Reduction [BLOCKED]

**BLOCKER** (Phase 2):
- **What failed**: Negation closure of IsVEA at arity >= 2. The `.all` case of `fo_isVEA` (Prop 4.3) requires `.all phi = .not (.ex (.not phi))`, which needs IsVEA for `.not phi`. Proving IsVEA for `.not phi` requires a biconditional for VVecEA2 negation: `neg_v.holds z0 z1 ↔ ¬v.holds z0 z1`.
- **What was tried**:
  1. Direct structural recursion on MonadicFormula with IsVEA result -- blocked by `.not` case
  2. Strengthened IH proving `IsVEA phi ∧ IsVEA (.not phi)` -- still blocked because the `.and` conjunction case has correlated existentials, and `.not (.ex phi)` reduces to `.all (.not phi)` which is circular
  3. Avoiding the `.all` case by handling it via `.not (.ex (.not phi))` -- the `.not` case at arity >= 3 requires VVecEA2 for `∃env. conds ∧ ¬eval phi`, which is not the VVecEA2 negation of `∃env. conds ∧ eval phi`
  4. At arity 2 specifically, the projection is deterministic (env determined by z0, z1), so negation = VVecEA2 negation. The forward direction (`¬v.holds → neg_v.holds`) is `neg_2var_vec_ea_indep_correct`. The backward direction (`neg_v.holds → ¬v.holds`) requires disjointness of `v.holds` and `neg_v.holds`, which is not proved in the codebase.
- **Why it's stuck**: The existing `neg_2var_vec_ea_indep_correct` provides only one direction of the VVecEA2 negation biconditional. The backward direction (showing `v.holds` and `neg_v.holds` cannot both hold on the same interval) would need a disjointness argument about the three-case construction (cases A, B1, B2). This is likely provable but requires non-trivial additional infrastructure (~100-200 lines).
- **What is needed**: Either (a) prove the backward direction `neg_2var_vec_ea_indep_backward: (neg_2var_vec_ea_indep v).holds z0 z1 → ¬v.holds z0 z1` on Prior structures, or (b) find an alternative approach that avoids the VVecEA2 negation biconditional, possibly by defining a different predicate that carries both the formula and its negation simultaneously.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder

**Partial progress**: `IsVEA` definition is complete and `isVEA_ex` (existential closure) is proved sorry-free in `ArityReduction.lean`. This is the core of Lemma 3.2(2) -- the result that prevents the arity tower.

**Goal**: Define a predicate `IsVEA` expressing that a MonadicFormula at arbitrary arity m is semantically equivalent to a V-EA formula on Prior structures. Implement Lemma 3.2(2): every m-variable EA formula (expressed via `IsVEA`) decomposes into a conjunction of 2-variable EAs. This is the arity firewall that prevents the arity tower.

**Approach**: Rather than building a full concrete `VecEA_m` type, define `IsVEA` as a predicate on MonadicFormula:

```lean
/-- A MonadicFormula at arity m is "V-EA" on Prior structures if for every
    pair of free variables (i, j) with i < j, there exists a VVecEA2 that
    captures the formula's behavior on that pair (with other variables
    existentially quantified out). -/
def IsVEA {sig : MonadicSignature} (phi : MonadicFormula sig m) : Prop :=
  ∀ (i j : Fin m), i < j →
    ∃ (v : VVecEA2),
      ∀ (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
        (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
        (env : Fin m → M.carrier),
        v.holds M atomMap (env i) (env j) ↔
        ∃ (env' : Fin m → M.carrier),
          (∀ k, k = i ∨ k = j → env' k = env k) ∧ eval M env' phi
```

Alternatively, a simpler predicate for the case needed (arity 1 -> temporal):

```lean
/-- At arity m, phi is V-EA if there exists a VVecEA2 for each variable pair
    such that the conjunction of all pairs is equivalent to phi. -/
def IsVEA_conj {sig : MonadicSignature} (phi : MonadicFormula sig m) : Prop :=
  ∃ (pairwise : ∀ (i j : Fin m), i < j → VVecEA2),
    ∀ (M : OrderedMonadicStructure sig) (atomMap : ...) (...) (env : ...),
      eval M env phi ↔
        ∀ (i j : Fin m) (h : i < j),
          (pairwise i j h).holds M atomMap (env i) (env j)
```

**Key design decision**: The predicate approach avoids building a concrete VecEA_m type (estimated 200-400 lines saved). The trade-off is that we lose direct translation to temporal formulas at arbitrary arity -- but we only need translation at arity 1, which VVecEA2.translateLeft already handles.

**Lemma 3.2(2) statement**: For MonadicFormula sig m with m >= 2, if IsVEA phi, then phi is equivalent to a conjunction where each conjunct is a 2-variable V-EA formula. The construction projects phi onto each pair (z_i, z_j) by existentially quantifying all other variables.

**Tasks**:
- [ ] **Task 2.1**: Create new file `ArityReduction.lean` with module header and imports
  - Import VecEAClosure, NegationIndep, VecEAFormula, MonadicFO
  - Document Lemma 3.2(2) and the IsVEA predicate approach
- [ ] **Task 2.2**: Define `IsVEA` predicate
  - Choose between the pairwise decomposition and the direct equivalence formulations
  - The predicate must support: (a) atomic formulas are IsVEA, (b) closure under disjunction, (c) closure under negation via Prop 4.2, (d) closure under existential via arity reduction
  - Target: ~50-80 lines for definitions
- [ ] **Task 2.3**: Prove IsVEA atomic cases
  - `atom p i` is IsVEA: the predicate at variable i is a zero-witness BracketFormula
  - `lt i j` is IsVEA: the order relation is a structural condition on the interval
  - Target: ~50-80 lines
- [ ] **Task 2.4**: Prove IsVEA closure under disjunction
  - If phi and psi are IsVEA, so is `disj phi psi`
  - Uses VVecEA2.disj_holds from VecEAClosure.lean
  - Target: ~30-50 lines
- [ ] **Task 2.5**: Implement Lemma 3.2(2) -- arity reduction
  - Statement: if phi : MonadicFormula sig (m+1) is IsVEA, then `ex phi` is IsVEA at arity m
  - The existential quantification absorbs one variable; each 2-var projection at arity m can be obtained from the (m+1)-arity projections by existentially quantifying the absorbed variable
  - Uses Lemma 3.4 existential closure from VecEAClosure.lean
  - Target: ~100-200 lines (highest complexity in this phase)
- [ ] **Task 2.6**: Prove IsVEA closure under negation
  - If phi is IsVEA, so is `not phi`
  - Uses Prop 4.2 model-independent (`neg_2var_vec_ea_indep` from NegationIndep.lean)
  - Each 2-var projection of phi gives a VVecEA2; negate it via Prop 4.2; conjunction of negated projections gives IsVEA for `not phi`
  - Target: ~80-150 lines
- [ ] **Task 2.7**: Prove IsVEA closure under conjunction
  - If phi and psi are IsVEA, so is `and phi psi`
  - Uses VVecEA2 conjunction closure from VecEAClosure.lean
  - Target: ~30-50 lines
- [ ] **Task 2.8**: Verify sorry-freedom of all new definitions
  - `lean_verify` on each key theorem
- [ ] **Task 2.9**: Verify `lake build` succeeds

**Timing**: 3 hours

**Depends on**: 1

**Files to create**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ArityReduction.lean` -- NEW (~350-600 lines)

**Verification**:
- All IsVEA closure theorems sorry-free (`lean_verify`)
- `lake build` succeeds
- No new sorry introduced

---

### Phase 3: Prop 4.3 -- Structural Formula Induction (FO -> V-EA) [NOT STARTED]

**Goal**: Implement Rabinovich's Prop 4.3: every MonadicFormula at any arity m is IsVEA on Prior structures. This is proved by structural induction on MonadicFormula using the closure properties from Phase 2.

**Approach**: The structural induction follows Rabinovich exactly:
- **Atomic** (`atom p i`): IsVEA by Phase 2, Task 2.3
- **Order** (`lt i j`): IsVEA by Phase 2, Task 2.3
- **Negation** (`not phi`): By IH, phi is IsVEA. By Phase 2 negation closure (Task 2.6), `not phi` is IsVEA.
- **Conjunction** (`and phi psi`): By IH, both are IsVEA. By Phase 2 conjunction closure (Task 2.7), `and phi psi` is IsVEA.
- **Universal** (`all phi`): `all phi = not (ex (not phi))`. By IH, phi is IsVEA. By negation closure, `not phi` is IsVEA. By existential closure (Task 2.5), `ex (not phi)` is IsVEA. By negation closure again, `not (ex (not phi))` is IsVEA.
- **Existential** (`ex phi`): By IH (at arity m+1), phi is IsVEA. By Phase 2 existential closure (Task 2.5), `ex phi` is IsVEA at arity m.

**Specialization to arity 1**: After proving Prop 4.3 at all arities, specialize to arity 1. For a MonadicFormula sig 1, IsVEA means there is a single VVecEA2 (only one pair: variables 0 and ... wait, arity 1 has only Fin 1, so there are NO pairs with i < j). This is the degenerate case -- every arity-1 formula is trivially IsVEA because there are no pairwise constraints. The actual content for arity 1 must come from the existential case: a MonadicFormula sig 1 containing `ex phi` produces a MonadicFormula sig 2 sub-formula, and the IH at arity 2 gives a VVecEA2 for the pair (0, 1). This VVecEA2 IS the temporal formula target.

**Key insight for KampPrior rewiring**: The arity-1 to temporal conversion goes:
1. MonadicFormula sig 1 -> (Prop 4.3 at arity 1 + arity 2) -> VVecEA2 (for each arity-2 sub-formula)
2. VVecEA2 -> temporal Formula (via Prop 3.5 / translateLeft)

The theorem needed for KampPrior is slightly different from the generic IsVEA: it needs to produce a concrete VVecEA2 for arity-1 formulas, not just assert IsVEA. This requires a stronger version:

```lean
def fo_to_vea (phi : MonadicFormula sig 1) :
    { v : VVecEA2 // ∀ M atomMap h_UZ h_SZ t,
      v.holdsLeft M atomMap t ↔ eval M (fun _ => t) phi }
```

This is constructive: it produces the VVecEA2 formula, not just asserts existence.

**Alternative approach**: If the IsVEA predicate from Phase 2 is existential (wrapping VVecEA2 witnesses), then Prop 4.3 at arity 1 directly gives a VVecEA2 via `Classical.choice`. The arity-1 specialization extracts the single pair and produces the VVecEA2.

**Tasks**:
- [ ] **Task 3.1**: Create new file `StructuralInduction.lean` with module header and imports
  - Import ArityReduction (Phase 2), NegationIndep, VecEAClosure, MonadicFO
  - Document Prop 4.3 and the structural induction approach
- [ ] **Task 3.2**: Implement `fo_isVEA` -- Prop 4.3 at all arities
  - `theorem fo_isVEA (phi : MonadicFormula sig m) : IsVEA phi`
  - Proof by structural induction on phi, using Phase 2 closure properties
  - Each case directly applies the corresponding closure theorem
  - Target: ~100-200 lines
- [ ] **Task 3.3**: Implement arity-1 specialization `fo_to_vea`
  - Extract a concrete VVecEA2 from IsVEA at arity 1
  - Handle the degenerate case (arity 1 has no pairs) by noting that arity-1 formulas with no quantifiers are temporal predicates, and quantified formulas go through arity-2 sub-formulas
  - May need a separate constructive induction at arity 1 that calls the arity-2 version internally
  - Target: ~100-200 lines
- [ ] **Task 3.4**: Prove correctness of `fo_to_vea`
  - `fo_to_vea_correct : v.holdsLeft M atomMap t ↔ eval M (fun _ => t) phi`
  - Bridges from IsVEA's pairwise decomposition to VVecEA2.holdsLeft
  - Target: ~50-100 lines
- [ ] **Task 3.5**: Verify sorry-freedom
  - `lean_verify` on `fo_isVEA` and `fo_to_vea_correct`
- [ ] **Task 3.6**: Verify `lake build` succeeds

**Timing**: 2.5 hours

**Depends on**: 2

**Files to create**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/StructuralInduction.lean` -- NEW (~250-500 lines)

**Verification**:
- `fo_isVEA` sorry-free (`lean_verify`)
- `fo_to_vea_correct` sorry-free (`lean_verify`)
- `lake build` succeeds
- No new sorry introduced

---

### Phase 4: Rewire KampPrior.lean + Final Verification [NOT STARTED]

**Goal**: Replace the sorry at KampPrior.lean:154 (`nf_characterizable_temporal_prior` succ succ k' case) using the Rabinovich chain: NF -> MonadicFormula (`nf_to_formula`) -> V-EA (`fo_to_vea`, Phase 3) -> temporal Formula (`VVecEA2.translateLeft`, Prop 3.5). Verify the full chain is sorry-free. Run complete sorry audit.

**Approach**: The sorry at line 154 is in the `| k' + 1 =>` branch of `nf_characterizable_temporal_prior`. The current proof structure handles k=0 (depth-0 NF, atom literals) and k=1 (depth-1 NF, via nf_succ_char_formula + nf_2var_exist_depth0_tl_fn). The k >= 2 case is sorry.

The new proof for k >= 2:
1. Convert NF to MonadicFormula: `nf_to_formula nf : MonadicFormula sig 1`
2. Apply Prop 4.3: `fo_to_vea (nf_to_formula nf)` gives a VVecEA2
3. Apply Prop 3.5: `VVecEA2.translateLeft` gives temporal Formula
4. Bridge correctness: compose `nf_to_formula_correct`, `fo_to_vea_correct`, and `translateLeft_correct`

The k=0 and k=1 cases are preserved unchanged (they are already sorry-free and work via the NF-depth approach, which is correct for low depth).

**Simplification opportunity**: The same `nf_to_formula -> fo_to_vea -> translateLeft` chain works for ALL k, not just k >= 2. We could unify all cases. However, preserving the k=0 and k=1 special cases avoids touching working sorry-free code and may produce simpler temporal formulas for these cases.

**Tasks**:
- [ ] **Task 4.1**: Add imports for StructuralInduction.lean to KampPrior.lean
- [ ] **Task 4.2**: Replace sorry at `nf_characterizable_temporal_prior` succ succ k' case
  - Build the temporal formula: `(fo_to_vea (nf_to_formula nf)).val.translateLeft`
  - Prove correctness by composing: `nf_to_formula_correct` + `fo_to_vea_correct` + `translateLeft_correct`
  - The result type matches: `{ A : Formula // ∀ M h_UZ h_SZ t, temporal_truth M atomMap t A ↔ nf_eval_nf M k 1 (fun _ => t) nf }`
  - May need `semantic_prior_implies_hasAttainedINF` for HasAttainedINF hypothesis required by NegationIndep
  - Target: ~50-100 lines
- [ ] **Task 4.3**: Verify `kamp_prior_expressive_completeness` is sorry-free
  - `lean_verify Bimodal.Metalogic.WeakCanonical.Kamp.kamp_prior_expressive_completeness`
- [ ] **Task 4.4**: Run `lake build` (full project)
- [ ] **Task 4.5**: Run sorry audit on Kamp directory:
  ```
  grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ --include="*.lean" | grep -v Boneyard | grep -v "sorry-free\|-- sorry\|/- sorry\|sorry_free\|sorryAx\|sorry_elim"
  ```
  Expected: exactly 2 non-critical sorry remaining (EANegation.lean:1084, EANegation.lean:1235). Zero critical-path sorry.
- [ ] **Task 4.6**: Verify external API preserved
  - Type signature of `kamp_prior_expressive_completeness` unchanged
  - Downstream consumers (PriorExpressiveness.lean, Completeness.lean) still build
- [ ] **Task 4.7**: Update orchestrator handoff JSON

**Timing**: 1.5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- replace sorry, add imports (~50-100 lines changed)

**Verification**:
- `kamp_prior_expressive_completeness` sorry-free (`lean_verify`)
- `lake build` succeeds (all jobs)
- Sorry audit shows exactly 2 non-critical sorry in EANegation.lean
- External API unchanged (type signatures preserved)

## Testing & Validation

- [ ] Phase 1: `lake build` succeeds after Prop43.lean archival
- [ ] Phase 1: Sorry audit confirms 3 sorry in active files (unchanged)
- [ ] Phase 2: All IsVEA closure theorems sorry-free (`lean_verify`)
- [ ] Phase 2: `lake build` succeeds
- [ ] Phase 3: `fo_isVEA` sorry-free (`lean_verify`)
- [ ] Phase 3: `fo_to_vea_correct` sorry-free (`lean_verify`)
- [ ] Phase 3: `lake build` succeeds
- [ ] Phase 4: `kamp_prior_expressive_completeness` sorry-free (`lean_verify`)
- [ ] Phase 4: Sorry audit: 0 critical-path sorry, 2 non-critical sorry
- [ ] Phase 4: External API preserved (type signatures unchanged)
- [ ] Phase 4: Full `lake build` succeeds

## Artifacts & Outputs

- `specs/305_rabinovich_ea_formula_implementation/plans/30_structural-induction-refactor.md` -- this plan
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Boneyard/Prop43.lean` -- archived NF-depth infrastructure
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ArityReduction.lean` -- NEW (~350-600 lines): IsVEA predicate + Lemma 3.2(2) arity reduction
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/StructuralInduction.lean` -- NEW (~250-500 lines): Prop 4.3 structural formula induction
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- MODIFIED: sorry eliminated, imports updated, k=1 dependencies inlined

## Rollback/Contingency

- **Full rollback**: `git checkout -- Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` restores all files. Delete new files `ArityReduction.lean` and `StructuralInduction.lean`. Move `Boneyard/Prop43.lean` back.
- **Phase 2 blocked** (IsVEA predicate design too complex): Try a direct constructive approach instead: define `fo_to_vvecEA2` as a function that takes a MonadicFormula sig m and returns a list of VVecEA2 for each variable pair, without the abstract predicate. This is heavier but avoids the predicate design challenges.
- **Phase 2 blocked** (Lemma 3.2(2) existential closure harder than expected): For the special case needed (arity 1 -> temporal), the existential case at arity 1 produces arity 2, which is directly within VVecEA2 scope. Try proving Prop 4.3 for arity 1 only, handling the existential case directly via arity-2 VVecEA2 and Lemma 3.4 existential closure. This avoids needing Lemma 3.2(2) for the arity-1 goal, though it would not generalize to higher arities.
- **Phase 3 blocked** (structural induction case mismatch): If the MonadicFormula constructors do not align cleanly with IsVEA closure (e.g., `and` vs `or` encoding), try converting MonadicFormula to a canonical form (negation normal form or disjunctive normal form) before applying IsVEA.
- **Phase 4 blocked** (composition mismatch between fo_to_vea and translateLeft): The types should align since fo_to_vea produces VVecEA2 and translateLeft consumes VVecEA2. If there is a mismatch in the `holdsLeft` vs `holds` semantics (1-var vs 2-var), use VecEATranslation.lean helpers.
- **Partial value**: Even completing Phases 1-2 has independent value -- the IsVEA predicate and Lemma 3.2(2) are reusable infrastructure for any future formalization that needs arity reduction for EA formulas.
