# Implementation Plan: Restricted Mutual Induction for Prop 4.3 (Task #305 v4)

- **Task**: 305 - rabinovich_ea_formula_implementation
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: None (all required sorry-free infrastructure exists)
- **Research Inputs**: reports/24_z-completeness-rabinovich.md, handoffs/phase-4-arity-tower-analysis-20260623.md, .orchestrator-handoff.json
- **Artifacts**: plans/26_restricted-mutual-induction.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Eliminate the sole critical-path sorry at NfExistTL.lean:301 (Part B at depth k+1) by implementing Rabinovich's Prop 4.3 via restricted mutual structural induction on MonadicFormula at arities 1 and 2. This plan supersedes v3 (plans/25_faithful-rabinovich-chain.md), which had Phases 1-3 targeting model-independent negation closure -- research definitively established these are unnecessary because KampPrior operates on Prior structures with HasAttainedINF, so the model-dependent `neg_2var_vec_ea` (already sorry-free) suffices. The v3 Phase 4 (Prop 4.3 via NF-depth induction) was blocked by an intrinsic circularity; the resolution is Rabinovich's formula-level structural induction with arity reduction. The approach is RESTRICTED: no new VVEAn types for n > 2 are needed. A single new file FOToVEA.lean (~400-600 lines) contains the mutual structural recursion, arity reduction (Lemma 3.2(2)), and existential closure (Lemma 3.4(3)). The bridge into NfExistTL.lean composes: NF -> nf_to_formula -> MonadicFormula sig 1 -> fo_to_vvea_1 -> VVecEA2 holdsLeft -> translateLeft -> Formula. Done when the sorry at NfExistTL.lean:301 is eliminated and `lake build` passes.

### Research Integration

**From handoff phase-4-arity-tower-analysis-20260623.md -- definitive arity tower analysis**:
- Combined Part A/Part B NF-depth induction has irreducible circularity at Part B depth k+1
- Five approaches exhaustively tested and all fail (Doets+NF disjunction, nf_to_formula bridge, rearranged induction, well-founded on quantifier depth, formula structural induction for sig 1 only)
- Rabinovich Prop 4.3 structural induction on MonadicFormula is the ONLY viable resolution
- Requires Lemma 3.2(2) arity reduction, Prop 4.2 negation closure (existing), Lemma 3.4(3) existential closure

**From .orchestrator-handoff.json -- implementation design**:
- RESTRICTED approach: mutual induction on arities 1 and 2 only, reusing existing VVecEA2 type
- No new VVEAn types needed for n > 2
- `fo_to_vvea_1 : MonadicFormula sig 1 -> VVecEA2` (holdsLeft semantics) mutual with `fo_to_vvea_2 : MonadicFormula sig 2 -> VVecEA2` (holds semantics)
- Cases: atom -> trivial; neg -> IH + Prop 4.2; and -> IH + conjunction closure; ex -> other-arity IH + existential/arity-reduction
- Lemma 3.2(2) arity reduction: depth-0 handled by VecEADecomp.lean (sorry-free), depth > 0 via nf_to_formula + structural IH
- Model-dependent negation acceptable because KampPrior operates on Prior structures with HasAttainedINF

**Superseded phases from v3 (plans/25_faithful-rabinovich-chain.md)**:
- Phase 1 (Cor 5.4 backward at EANegation.lean:1235): SUPERSEDED -- model-independent biconditional structurally unprovable at BracketFormula level; model-dependent alternative already sorry-free
- Phase 2 (Lemma 5.1 segment-type at EndpointNegation.lean:160): SUPERSEDED -- same structural obstruction; model-dependent `neg_interval_formula` already sorry-free
- Phase 3 (Model-independent Prop 4.2): SUPERSEDED -- model-dependent `neg_2var_vec_ea` suffices for KampPrior
- Phase 4 (Prop 4.3 via combined NF induction): SUPERSEDED -- irreducible circularity; replaced by formula-level structural induction
- Phase 5 (KampPrior sorry elimination): RETAINED in restructured form (Phases 3 and 4 of this plan)

### H3 Reference Grounding Table

| Source (Rabinovich 2014) | Lean Identifier | Type Signature | Status |
|--------------------------|-----------------|----------------|--------|
| Lemma 3.2(2) (p.4) | (new: in FOToVEA.lean) | `VVecEA2 -> conjunction of VVecEA2 with <= 2 free vars` | Phase 2 target |
| Lemma 3.4(1) (p.5) | `VVecEA2.conj_holds_vvecEA2` | `VVecEA2 -> VVecEA2 -> VVecEA2` (conjunction closure) | sorry-free (VecEAClosure.lean) |
| Lemma 3.4(3) (p.5) | (new: in FOToVEA.lean) | `exists y, VVecEA2 -> VVecEA2` (existential closure) | Phase 2 target |
| Prop 3.5 (p.5) | `ExistsForallSpec.translate_correct` | `temporal_truth t v.translateLeft <-> v.holdsLeft t` | sorry-free (RabinovichTranslation.lean) |
| Prop 4.2 model-dep (p.6) | `neg_2var_vec_ea` | `neg v.holds -> exists v', v'.holds` | sorry-free (EANegationClosure.lean) |
| Prop 4.3 (p.6) | (new: `fo_to_vvea_1`, `fo_to_vvea_2`) | `MonadicFormula sig n -> VVecEA2` for n=1,2 | Phase 1-2 target |
| Thm 4.4 (p.6) | (new: bridge in NfExistTL.lean) | NF -> MonadicFormula sig 1 -> VVecEA2 -> Formula | Phase 3 target |
| HasAttainedINF | `prior_hasAttainedINF` | `Prior -> HasAttainedINF` | sorry-free (PriorDefs.lean) |
| NF-to-Formula (Doets) | `nf_to_formula` / `nf_to_formula_correct` | `NormalForm sig k n -> MonadicFormula sig n` | sorry-free (NormalForm.lean) |
| V-EA translation | `VVecEA2.translateLeft` / `translateLeft_correct` | `VVecEA2 -> Formula` | sorry-free (VecEATranslation.lean) |

### Reusable Infrastructure (all sorry-free)

| File | Lines | Key Identifiers | Role |
|------|-------|-----------------|------|
| VecEAFormula.lean | 769 | `VecEA2`, `VVecEA2`, bracket formulas | 2-var EA types and semantics |
| VecEAClosure.lean | 387 | `conj_holds_vvecEA2`, `conj_struct` | Conjunction/existential closure for 2-var |
| VecEADecomp.lean | 897 | `nf_3var_bracket_*`, `nf_3var_zone_*` | Depth-0 arity-3 zone decomposition |
| EANegationClosure.lean | ~600 | `neg_2var_vec_ea`, `neg_interval_formula` | Prop 4.2 model-dependent negation |
| VecEATranslation.lean | ~300 | `translateLeft`, `translateLeft_correct` | VVecEA2 -> temporal Formula |
| NormalForm.lean | ~838 | `nf_to_formula`, `nf_to_formula_correct` | NF -> MonadicFormula conversion |
| NfExistTL.lean | 323 | `nf_characterizable_temporal_prior_combined`, `nf_characterizable_temporal_prior_partA` | Combined induction (Part A sorry-free, Part B sorry at line 301) |

### Roadmap Alignment

This plan advances the sole critical-path item: "Task 303 (k>0 depth induction via Rabinovich Section 5 Lemma 5.1) -> sorry-free `completeness_discrete`." Completing this chain eliminates the ONLY remaining sorry blocking `completeness_discrete`.

## Goals & Non-Goals

**Goals**:
- Eliminate the sorry at NfExistTL.lean:301 (Part B at depth k+1)
- Implement Prop 4.3 via mutual structural induction on MonadicFormula at arities 1 and 2
- Implement Lemma 3.2(2) arity reduction (arity-3 -> conjunction of arity-2) within FOToVEA.lean
- Implement Lemma 3.4(3) existential closure within FOToVEA.lean
- Bridge FOToVEA into NfExistTL.lean to resolve Part B at k+1
- Achieve sorry-free `nf_characterizable_temporal_prior_partA` chain through to `completeness_discrete`
- Maintain `lake build` success after every phase

**Non-Goals**:
- Fixing EANegation.lean:1084, EANegation.lean:1235, or EndpointNegation.lean:160 (off critical path, structurally unprovable at BracketFormula level)
- Building general V-EA infrastructure for arity >= 3 (the restricted approach avoids this)
- Model-independent negation closure (model-dependent suffices for KampPrior)
- Addressing the Stavi chain (mathematically false, confirmed dead)
- Modifying any existing sorry-free code except to wire in the new chain at NfExistTL.lean

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Arity-3 to arity-2 reduction at depth > 0 requires complex nf_to_formula + IH composition | H | M | Depth-0 case handled by VecEADecomp.lean (897 lines, sorry-free). Depth > 0: compose nf_to_formula to get MonadicFormula, apply structural IH. Budget extra 100 lines for helper lemmas. |
| Mutual structural recursion on MonadicFormula may require well-founded induction in Lean 4 | M | L | MonadicFormula is an inductive type; Lean 4 handles mutual recursion natively. If needed, use `MonadicFormula.rec` or combine into a single function dispatching on arity. |
| Existential closure (Lemma 3.4(3)) may require careful witness reindexing | M | L | VecEAClosure.lean provides templates for witness manipulation. The existential y simply joins the witness block (straightforward reindexing). |
| neg_2var_vec_ea (model-dependent) requires threading HasAttainedINF through Prop 4.3 | L | H | Expected and acceptable. Prior structures have HasAttainedINF via `prior_hasAttainedINF`. Thread the hypothesis through all lemmas. |
| Bridge from FOToVEA to NfExistTL requires matching evaluation semantics | M | M | `nf_to_formula_correct` (sorry-free) establishes the equivalence. Compose: nf_eval_nf <-> MonadicFormula.eval <-> VVecEA2.holds <-> temporal_truth. Each step has a sorry-free correctness proof. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Fully sequential: each phase builds on the previous. No parallel execution possible due to the chain structure.

---

### Phase 1: FOToVEA.lean Core -- Mutual Structural Induction Skeleton + Atom/And/Neg Cases [IN PROGRESS]

*(deviation: altered — Instead of mutual structural induction on MonadicFormula, using NF enumeration + Part A decomposition approach. The existential case is handled by decomposing into arity-2 NFs and using Part B IH, avoiding the arity tower.)*

**Goal**: Create `FOToVEA.lean` with the mutual structural induction skeleton for `fo_to_vvea_1` (arity 1) and `fo_to_vvea_2` (arity 2), and implement the atom, conjunction, and negation cases. The existential case is left as sorry (addressed in Phase 2).

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/FOToVEA.lean`
- [ ] Add imports: VecEAFormula, VecEAClosure, EANegationClosure, VecEATranslation, NormalForm (MonadicFormula types), VecEADecomp
- [ ] Define the mutual structural recursion signature:
  - `fo_to_vvea_1 : MonadicFormula sig 1 -> { v : VVecEA2 // ... v.holdsLeft ... }` (semantics: `v.holdsLeft t <-> eval M (fun _ => t) phi`)
  - `fo_to_vvea_2 : MonadicFormula sig 2 -> { v : VVecEA2 // ... v.holds ... }` (semantics: `v.holds z0 z1 <-> eval M env phi` where `env 0 = z0, env 1 = z1`)
- [ ] Implement **atom case** (both arities):
  - Arity 1: `atom p 0` -> VVecEA2 encoding predicate p at the single free variable (via endpointLeft)
  - Arity 2: `atom p 0` -> VVecEA2 encoding p at z0; `atom p 1` -> VVecEA2 encoding p at z1
  - Order atoms: `lt i j` -> trivial VVecEA2 based on z0 < z1 hypothesis or its negation
- [ ] Implement **conjunction case** (both arities):
  - By IH, both sub-formulas map to VVecEA2. Apply `VVecEA2.conj_holds_vvecEA2` (VecEAClosure.lean, sorry-free)
- [ ] Implement **negation case** (both arities):
  - By IH, sub-formula maps to VVecEA2. Apply `neg_2var_vec_ea` (EANegationClosure.lean, sorry-free, model-dependent)
  - Thread HasAttainedINF hypothesis through
- [ ] Leave **existential case** as `sorry` (both arities) with documentation referencing Phase 2
- [ ] Leave **universal case** as reduction to negation + existential (or sorry if existential is sorry)
- [ ] Verify `lake build` succeeds with the new file (sorry in existential cases only)

**Timing**: 2 hours

**Depends on**: none

**Files to create**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/FOToVEA.lean` -- NEW (~200-300 lines initial skeleton)

**Verification**:
- `lake build` succeeds
- Atom, conjunction, and negation cases are sorry-free
- Sorry exists only in existential/universal cases (documented)

---

### Phase 2: Arity Reduction (Lemma 3.2(2)) + Existential Closure (Lemma 3.4(3)) [NOT STARTED]

**Goal**: Implement the remaining cases of the mutual structural induction -- the existential case for both arities. This requires Lemma 3.2(2) (arity-3 to arity-2 reduction) for the arity-2 existential case and Lemma 3.4(3) (existential closure) for the arity-1 existential case. Eliminate all sorry in FOToVEA.lean.

**Tasks**:
- [ ] Implement **Lemma 3.4(3) existential closure** (~50-100 lines):
  - Statement: if `phi(y, z_0, ..., z_m)` is V-EA (represented as VVecEA2), then `exists y, phi` is V-EA
  - Implementation: the existential variable y joins the EA witness block. EA has the form `exists x_1 ... x_k, conditions`; adding `exists y` extends the witness sequence to `exists y x_1 ... x_k, conditions`
  - This handles the arity-1 existential case: `ex alpha` where alpha has arity 2, by IH maps to VVecEA2, apply existential closure
- [ ] Implement **Lemma 3.2(2) arity reduction** for arity-3 to arity-2:
  - **Depth-0 case** (~50 lines): Use VecEADecomp.lean infrastructure (897 lines, sorry-free). The depth-0 arity-3 zone decomposition (`nf_3var_bracket_*`, `nf_3var_zone_*`) provides the decomposition into 2-variable zones. Wrap as a conjunction of VVecEA2 formulas.
  - **Depth > 0 case** (~150-200 lines): For each depth-(k+1) arity-3 NF condition:
    - Apply `nf_to_formula` to convert to `MonadicFormula sig 3`
    - The arity-3 MonadicFormula has sub-formulas that are arity-3 or lower
    - On a linear order with 3 free variables (y, z0, z1), decompose by the 6 possible orderings of y relative to z0, z1
    - Each ordering case fixes the relative position, reducing to pairwise 2-variable relationships
    - Apply structural IH on the resulting 2-variable formulas
- [ ] Implement **arity-2 existential case**: `ex alpha` where alpha has arity 3:
  - By IH, alpha (arity 3) should map to VVecEA2 -- but we only have IH for arities 1 and 2
  - Apply Lemma 3.2(2): reduce arity-3 to conjunction of arity-2, each handled by IH
  - Then apply Lemma 3.4(3) existential closure on the result
- [ ] Implement **universal case**: `all alpha = not (ex (not alpha))` -- reduces to negation + existential (both now implemented)
- [ ] Verify all sorry in FOToVEA.lean are eliminated
- [ ] Verify `lake build` succeeds

**Timing**: 3 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/FOToVEA.lean` -- fill existential/universal cases, add Lemma 3.2(2) and Lemma 3.4(3) (~200-300 additional lines)

**Verification**:
- `lean_verify` confirms `fo_to_vvea_1` and `fo_to_vvea_2` are sorry-free
- `lake build` succeeds

---

### Phase 3: Bridge Wiring -- Connect FOToVEA into NfExistTL.lean [NOT STARTED]

**Goal**: Wire the FOToVEA infrastructure into NfExistTL.lean to eliminate the sorry at line 301 (Part B at depth k+1). The bridge composes: NF -> `nf_to_formula` -> MonadicFormula sig 1 -> `fo_to_vvea_1` -> VVecEA2 holdsLeft -> `translateLeft` -> Formula.

**Tasks**:
- [ ] Add import for FOToVEA.lean in NfExistTL.lean
- [ ] Build the Part B bridge lemma for depth k+1:
  - For each `sub_nf : NormalForm sig (k+1) 2`, convert the existential `exists x, nf_eval_nf M (k+1) 2 (x::t) sub_nf` to temporal:
    1. Apply `nf_to_formula` to `sub_nf` to get `phi : MonadicFormula sig 2`
    2. Use `nf_to_formula_correct` to establish `nf_eval_nf M (k+1) 2 env sub_nf <-> eval M env phi`
    3. The existential `exists x, eval M (x::t) phi` equals `eval M (fun _ => t) (MonadicFormula.ex phi)`
    4. `MonadicFormula.ex phi : MonadicFormula sig 1` -- apply `fo_to_vvea_1` to get `v : VVecEA2` with holdsLeft semantics
    5. Apply `VVecEA2.translateLeft` to get `A : Formula`
    6. Use `VVecEA2.translateLeft_correct` to establish `temporal_truth M atomMap t A <-> v.holdsLeft t`
    7. Compose the biconditionals: `temporal_truth M atomMap t A <-> exists x, nf_eval_nf M (k+1) 2 (x::t) sub_nf`
- [ ] Replace the sorry at NfExistTL.lean:301 with the bridge construction
- [ ] Verify `nf_characterizable_temporal_prior_combined` is sorry-free
- [ ] Verify `nf_characterizable_temporal_prior_partA` is sorry-free
- [ ] Verify `nf_characterizable_temporal_prior` (in KampPrior.lean) is sorry-free (it delegates to `nf_characterizable_temporal_prior_partA`)
- [ ] Verify `lake build` succeeds

**Timing**: 2 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfExistTL.lean` -- replace sorry at line 301, add imports (~50-100 lines)

**Verification**:
- `lean_verify` confirms `nf_characterizable_temporal_prior_combined` is sorry-free
- `lean_verify` confirms `nf_characterizable_temporal_prior_partA` is sorry-free
- `lake build` succeeds

---

### Phase 4: Verification -- Lake Build, Sorry Audit, KampPrior Chain Validation [NOT STARTED]

**Goal**: Full verification pass: confirm `lake build` succeeds, audit sorry inventory, validate the complete KampPrior chain from `nf_characterizable_temporal_prior` through `kamp_prior_expressive_completeness` to `completeness_discrete`.

**Tasks**:
- [ ] Run `lake build` (full project, ~1700 jobs)
- [ ] Run sorry audit on the Kamp directory:
  ```
  grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ --include="*.lean" | grep -v Boneyard | grep -v "sorry-free\|-- sorry\|/- sorry"
  ```
  Expected remaining sorry (non-critical-path):
  - EANegation.lean:1084 (neg_bracket beta_0 -- unprovable at BracketFormula level)
  - EANegation.lean:1235 (neg_partialBracketExist n+1 -- unprovable at BracketFormula level)
  - EndpointNegation.lean:160 (neg_vecEA2 succ -- model-dep alternative exists)
- [ ] Verify `kamp_prior_expressive_completeness` is sorry-free via `lean_verify`
- [ ] Verify `completeness_discrete` sorry chain -- check how many sorry remain between `kamp_prior_expressive_completeness` and `completeness_discrete`
- [ ] Verify external API preserved: type signature of `kamp_prior_expressive_completeness` unchanged
- [ ] Verify PriorExpressiveness.lean and Completeness.lean still build correctly
- [ ] Document final sorry inventory in handoff

**Timing**: 1 hour

**Depends on**: 3

**Files**: None modified (verification only)

**Verification**:
- `lake build` succeeds (all ~1700 jobs)
- `kamp_prior_expressive_completeness` sorry-free
- `completeness_discrete` sorry chain reduced
- Only non-critical-path sorry remain in Kamp directory
- External API unchanged

## Testing & Validation

- [ ] `lake build` succeeds after each phase (incremental verification)
- [ ] Phase 1: atom/conjunction/negation cases sorry-free, existential cases documented sorry
- [ ] Phase 2: `fo_to_vvea_1` and `fo_to_vvea_2` fully sorry-free (`lean_verify`)
- [ ] Phase 3: `nf_characterizable_temporal_prior_combined` sorry-free (`lean_verify`)
- [ ] Phase 3: `nf_characterizable_temporal_prior_partA` sorry-free (`lean_verify`)
- [ ] Phase 4: `kamp_prior_expressive_completeness` sorry-free (`lean_verify`)
- [ ] Phase 4: sorry audit shows only non-critical-path sorry (EANegation.lean:1084, EANegation.lean:1235, EndpointNegation.lean:160)
- [ ] External API unchanged: type signature of `kamp_prior_expressive_completeness` preserved
- [ ] PriorExpressiveness.lean and Completeness.lean still build correctly

## Artifacts & Outputs

- `specs/305_rabinovich_ea_formula_implementation/plans/26_restricted-mutual-induction.md` -- this plan
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/FOToVEA.lean` -- NEW (~400-600 lines, Prop 4.3 mutual induction + Lemma 3.2(2) + Lemma 3.4(3))
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfExistTL.lean` -- MODIFIED (sorry at line 301 eliminated)

## Rollback/Contingency

- **Full rollback**: `git checkout -- Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfExistTL.lean` restores the sorry. Delete `FOToVEA.lean`.
- **Phase 1 blocked** (skeleton issues): MonadicFormula is a standard inductive type; mutual recursion should be straightforward. If Lean 4 mutual recursion is problematic, combine into a single function `fo_to_vvea (n : Nat) : MonadicFormula sig n -> VVecEA2` dispatching on `n` with a well-founded termination argument on formula structure.
- **Phase 2 blocked** (arity reduction): If Lemma 3.2(2) at depth > 0 is too complex, attempt a simpler approach: since the arity-2 existential case produces `ex (MonadicFormula sig 3)`, and the result's free variables are still z0 and z1, the existential over the third variable with z0, z1 fixed is semantically a 2-variable statement. Directly construct the VVecEA2 by absorbing the existential witness into the EA witness block without full arity reduction.
- **Phase 3 blocked** (bridge composition): The individual pieces (nf_to_formula_correct, fo_to_vvea correctness, translateLeft_correct) are all sorry-free. If composition is difficult, introduce intermediate lemmas decomposing the biconditional chain. As a last resort, restore NfExistTL.lean from git.
