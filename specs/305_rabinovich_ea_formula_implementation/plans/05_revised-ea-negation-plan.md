# Implementation Plan: Rabinovich EA-Formula Negation Closure (Revised)

- **Task**: 305 - Rabinovich EA-formula implementation
- **Status**: [IMPLEMENTING]
- **Effort**: 10 hours
- **Dependencies**: None (builds on existing sorry-free infrastructure in Phases 1-3)
- **Research Inputs**:
  - specs/305_rabinovich_ea_formula_implementation/reports/01_ea-formula-research.md
  - specs/305_rabinovich_ea_formula_implementation/reports/04_faithful-lemma51-design.md
- **Artifacts**: plans/05_revised-ea-negation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Revised plan for completing Rabinovich Section 5 negation closure. After 6 failed dispatches on Phase 4, research report 04 established that the sorry at EANegation.lean:1047 (backward direction, beta_0(r_0) sub-case of `neg_bracket_is_vbracket`) is structurally unsolvable at the BracketFormula level with a model-independent V-bracket. The paper's Lemma 5.1 operates at the VecEA2 level with endpoint conditions, and Proposition 4.2 only needs the model-dependent forward direction.

This revision replaces the blocked Phase 4-5 with a Boneyard porting strategy: adopt model-dependent forward-only proofs from `NegationClosure5.lean` and `NegationClosureProp42.lean` (archived by task 302, complete and sorry-free before archival). The Boneyard avoids the beta_0(r_0) problem entirely by case-splitting on segment conditions (`forall y, z0 < y -> y < r0 -> seg_0(y)`), not point values.

### Research Integration

- Report 01 (01_ea-formula-research.md): Original architecture design, confirmed Option A approach, identified ~1500-2000 new lines needed. Integrated in plan version 1.
- Report 04 (04_faithful-lemma51-design.md): Root cause analysis of Phase 4 blocker, confirmed beta_0(r_0) is structurally unsolvable at BracketFormula level, recommended Boneyard forward-only porting approach, provided complete adaptation mapping. Integrated in this revision.

### Revision Summary

| Original Phase | Status | Revised Action |
|---|---|---|
| Phase 1: Interval Splitting Infrastructure | [COMPLETED] | Preserved as-is |
| Phase 2: Lemma 5.3 (all-betas-True) | [COMPLETED] | Preserved as-is |
| Phase 3: Corollary 5.4 (partial bracket) | [COMPLETED] | Preserved as-is |
| Phase 4: Lemma 5.1 biconditional | [BLOCKED] | **Replaced**: Port Boneyard helpers + `neg_bracket_forward` (model-dependent forward-only) |
| Phase 5: Props 4.2/4.3 | [NOT STARTED] | **Replaced**: Port `neg_vecEA2` + `neg_2var_vec_ea` from Boneyard |
| Phase 6: ExistPart Rewire | [NOT STARTED] | Updated for model-dependent architecture |
| Phase 7: Integration | [NOT STARTED] | Updated for model-dependent architecture |

## Goals & Non-Goals

**Goals**:
- Port `neg_bracket_forward` (Lemma 5.1, model-dependent forward direction) from Boneyard
- Port `neg_partialBracketExist_forward` (Corollary 5.4, model-dependent forward) from Boneyard
- Port `neg_vecEA2` and `neg_2var_vec_ea` (Proposition 4.2) from Boneyard
- Rewire `existPart_succ_n1_bypass` to use EA negation closure path
- Eliminate all 4 live sorrys in PriorComposition.lean from the critical path
- Achieve `lake build` clean (sorry-free on the critical path)

**Non-Goals**:
- Model-independent biconditional for `neg_bracket_is_vbracket` (Track B, future work)
- Removing dead-code sorrys in NfCharFormula.lean (lines 542, 657 -- deprecated)
- Removing PriorComposition.lean (stays as Boneyard reference)
- Implementing the future fragment (Section 7 of Rabinovich)
- Removing the existing sorry-marked `neg_bracket_is_vbracket` or `neg_partialBracketExist_is_vbracket` (leave as non-critical-path theorems)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Boneyard proofs need adaptation beyond simple renames (Boneyard behind `#exit`) | M | M | The proof structures use same types (BracketFormula, VBracketFormula); research verified definitional equivalences. Budget 50% extra time for Fin arithmetic and API differences. |
| `HasAttainedINF` does not cover `prior_UZ_successor` (needed for Cor 5.4 n=0) | M | M | Active codebase already handles n=0 via `by_cases` on segment failure. Can port `prior_UZ_successor` as a separate lemma using `HasAttainedINF.first_occ` with `Formula.top`. |
| `TemporalPred.eval_at_neg` not in active codebase | L | H | Simple lemma; port from Boneyard (3 lines). |
| Phase 6 rewire: bracket-to-NF type bridge may not compose with model-dependent negation | H | M | Validate types early with `lean_goal`. The translation pipeline (VecEATranslation) already takes M as parameter. |
| `VVecEA2.conj_holds_vvecEA2` not compatible with new forward-only architecture | L | L | Already in active codebase (VecEAClosure.lean:238). Uses same VVecEA2 type as Boneyard. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3 | -- (already completed) |
| 2 | 4 | 1, 2, 3 |
| 3 | 5 | 4 |
| 4 | 6 | 5 |
| 5 | 7 | 6 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Interval Splitting Infrastructure [COMPLETED]

**Goal**: Define `BracketFormula.splitAt` (the A_i^-/A_i^+ decomposition from Rabinovich p.10) and prove semantic correctness.

**Tasks**:
- [x] Define `BracketFormula.leftPart` and `BracketFormula.rightPart`
- [x] Prove `leftPart_holds` and `rightPart_holds` sorry-free
- [x] Prove `splitAt_combine` sorry-free (4-case split with dif_pos/dif_neg)
- [x] Add `BracketFormula.empty : BracketFormula 0` constructor

**Timing**: 2 hours
**Depends on**: none
**Completed**: 2026-06-15

---

### Phase 2: Lemma 5.3 -- All-Betas-True Base Case [COMPLETED]

**Goal**: Prove `neg_orderedPointsExist_is_vbracket` (Rabinovich Lemma 5.3, p.8).

**Tasks**:
- [x] Define `BracketFormula.prepend` with `prepend_holds` and `prepend_holds_inv`
- [x] Prove `orderedPointsExist_decompose`
- [x] Define `VBracketFormula.prependAll`
- [x] Prove base cases (n=0, n=1) and inductive step using `HasAttainedINF`
- [x] Prove `neg_orderedPointsExist_is_vbracket` sorry-free

**Timing**: 2 hours
**Depends on**: 1
**Completed**: 2026-06-16

---

### Phase 3: Corollary 5.4 -- Partial Bracket Negation (Forward) [COMPLETED]

**Goal**: Prove `neg_partialBracketExist_sufficient` (Corollary 5.4 forward direction).

**Tasks**:
- [x] Define `fChainFrom` / `fChainPred` (F_i chain construction)
- [x] Prove `bracket_implies_fChainPred` sorry-free
- [x] Prove `neg_partialBracketExist_sufficient` sorry-free
- [x] Prove `neg_bracket_zero_is_vbracket` sorry-free
- [ ] `neg_partialBracketExist_is_vbracket` backward: sorry at line 1172 (non-critical, superseded by Phase 4)

**Timing**: 1.5 hours
**Depends on**: 1, 2
**Completed**: 2026-06-17

---

### Phase 4: Boneyard Port -- Lemma 5.1 Forward + Helpers [NOT STARTED]

**Goal**: Port the model-dependent forward-only proofs from the Boneyard (`NegationClosure5.lean`) into a new file `EANegationClosure.lean`. This replaces the blocked biconditional approach with the Boneyard's 3-case structure that avoids the beta_0(r_0) sub-case entirely.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegationClosure.lean` with imports from `EANegation`, `VecEAClosure`, `PriorINF`
- [ ] Port `TemporalPred.eval_at_neg` (Boneyard NegationClosure5.lean:112-116): `P.neg.eval_at M atomMap t <-> not P.eval_at M atomMap t`. Simple simp lemma.
- [ ] Port `BracketFormula.pureSeg` (Boneyard NegationClosure5.lean:78-80): 0-witness bracket with segment predicate. Active codebase has `BracketFormula.trivial` -- check if definitionally equal; if so, use `trivial` directly.
- [ ] Port `BracketFormula.purePoint` (Boneyard NegationClosure5.lean:72-74): 1-witness bracket with point predicate and True segments. Define or inline as `BracketFormula.single pt top top`.
- [ ] Port `BracketFormula.pureSeg_holds` (Boneyard NegationClosure5.lean:104-109): simp lemma for pureSeg semantics
- [ ] Port `BracketFormula.purePoint_holds` (Boneyard NegationClosure5.lean:83-101): simp lemma for purePoint semantics
- [ ] Port `inf_bracket_formula` definition (Boneyard NegationClosure5.lean:313-315): `[not P, P, True](z0, z1)` bracket
- [ ] Port `inf_bracket_formula_holds` (Boneyard NegationClosure5.lean:319-346): semantics of the INF bracket
- [ ] Port `inf_bracket_formula_prior` (Boneyard NegationClosure5.lean:350-360): connects `first_occurrence_prior_strict` to bracket formula. Adapt to use `HasAttainedINF.first_occ` instead of `semantic_prior_UZ` directly.
- [ ] Port `inf_formula_prior_is_vbracket` (Boneyard NegationClosure5.lean:364-373): wraps INF bracket as VBracketFormula
- [ ] Port `BracketFormula.tail` definition (Boneyard NegationClosure5.lean:716-718): shift pointTypes/segmentTypes by 1. Note: definitionally equal to `rightPart ⟨0, _⟩`; can alias or use rightPart directly.
- [ ] Port `bracket_tail_satisfiable` (Boneyard NegationClosure5.lean:726-818): if tail holds on (r0, z) with first-witness conditions, then bf holds on (z0, z). Critical helper for Case B1 contrapositive.
- [ ] Port `prior_UZ_successor` (Boneyard NegationClosure5.lean:823-841): on Prior-UZ, the first point above z0 has empty interval. Adapt to use `HasAttainedINF.first_occ` with `Formula.top`.
- [ ] Port `neg_bounded_exists` (Boneyard NegationClosure5.lean:859-937): Corollary 5.4 forward, model-dependent. Induction on n with 3 cases (A: no point, B1: segment ok -> IH on tail, B2: segment fail -> INF).
- [ ] Port `neg_interval_formula` (Boneyard NegationClosure5.lean:966-1032): Lemma 5.1 forward, model-dependent. Same 3-case structure as `neg_bounded_exists` but simpler base case.
- [ ] Verify: `lake build Bimodal.Metalogic.WeakCanonical.Kamp.EANegationClosure` succeeds sorry-free

**Timing**: 3 hours
**Depends on**: 2, 3

**Files to create**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegationClosure.lean` (~500-600 lines)

**Key Type Signatures**:
```lean
-- Lemma 5.1 forward (model-dependent)
theorem neg_interval_formula
    (M : OrderedMonadicStructure sig) (atomMap : Formula -> sig.preds)
    (h_INF : HasAttainedINF M atomMap) :
    forall (n : Nat) (bf : BracketFormula n) (z0 z1 : M.carrier),
    z0 < z1 -> not bf.holds M atomMap z0 z1 ->
    exists v : VBracketFormula, v.holds M atomMap z0 z1

-- Corollary 5.4 forward (model-dependent)
theorem neg_bounded_exists
    (M : OrderedMonadicStructure sig) (atomMap : Formula -> sig.preds)
    (h_INF : HasAttainedINF M atomMap) :
    forall (n : Nat) (bf : BracketFormula n) (z0 z1 : M.carrier),
    z0 < z1 ->
    not (exists z, z0 < z /\ z < z1 /\ bf.holds M atomMap z0 z) ->
    exists v : VBracketFormula, v.holds M atomMap z0 z1
```

**Porting Adaptation Table**:
| Boneyard Reference | Active Codebase Equivalent | Action |
|---|---|---|
| `semantic_prior_UZ` | `HasAttainedINF` | Replace in type signatures |
| `first_occurrence_prior_strict` | `HasAttainedINF.first_occ` | Adapt call site (Formula vs TemporalPred) |
| `BracketFormula.tail` | `BracketFormula.rightPart ⟨0, _⟩` | Define `tail` as alias or use `rightPart` directly |
| `bracket_prepend_holds` | `BracketFormula.prepend_holds` (EANegation.lean) | Already available |
| `BracketFormula.pureSeg` | `BracketFormula.trivial` | Verify definitional equivalence |
| `BracketFormula.purePoint` | Define new or inline | New definition needed |

**Verification**:
- All ported definitions and theorems compile sorry-free
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.EANegationClosure` succeeds
- `neg_interval_formula` and `neg_bounded_exists` are sorry-free

---

### Phase 5: Proposition 4.2 -- VecEA2 Negation Closure [NOT STARTED]

**Goal**: Port `neg_vecEA2` and `neg_2var_vec_ea` from the Boneyard (`NegationClosureProp42.lean`) to prove that the negation of any VecEA2 / VVecEA2 formula is a VVecEA2 formula. This completes the negation closure chain needed for the ExistPart rewire.

**Tasks**:
- [ ] Port `VBracketFormula.toVVecEA2WithEndpoints` definition (Boneyard NegationClosureProp42.lean:47-50): wraps VBracketFormula disjuncts with endpoint predicates to form VVecEA2
- [ ] Port `VBracketFormula.toVVecEA2WithEndpoints_holds` (Boneyard NegationClosureProp42.lean:54-66): semantic correctness of the wrapping
- [ ] Port `neg_vecEA2` (Boneyard NegationClosureProp42.lean:75-116): Prop 4.2 single conjunct, 3-case de Morgan decomposition. Case 3 uses `neg_interval_formula` from Phase 4.
- [ ] Port `neg_disjunct_list` helper (Boneyard NegationClosureProp42.lean:125-153): induction on disjunct list, combining via `VVecEA2.conj_holds_vvecEA2` (already in VecEAClosure.lean)
- [ ] Port `neg_2var_vec_ea` (Boneyard NegationClosureProp42.lean:159-169): Prop 4.2 full -- unfold VVecEA2.holds, push_neg, apply `neg_disjunct_list`
- [ ] Add `TemporalPred.eval_at_top` if not already present: `TemporalPred.top.eval_at M atomMap t = True`
- [ ] Verify: `lake build Bimodal.Metalogic.WeakCanonical.Kamp.EANegationClosure` succeeds sorry-free

**Timing**: 1.5 hours
**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegationClosure.lean` -- extend with Prop 4.2 (~150 lines)

**Key Type Signatures**:
```lean
-- Prop 4.2 (single conjunct)
theorem neg_vecEA2
    (M : OrderedMonadicStructure sig) (atomMap : Formula -> sig.preds)
    (h_INF : HasAttainedINF M atomMap)
    (n : Nat) (vea : VecEA2 n) (z0 z1 : M.carrier)
    (h_lt : z0 < z1) (h_neg : not vea.holds M atomMap z0 z1) :
    exists v : VVecEA2, v.holds M atomMap z0 z1

-- Prop 4.2 (full)
theorem neg_2var_vec_ea
    (M : OrderedMonadicStructure sig) (atomMap : Formula -> sig.preds)
    (h_INF : HasAttainedINF M atomMap)
    (v : VVecEA2) (z0 z1 : M.carrier)
    (h_lt : z0 < z1) (h_neg : not v.holds M atomMap z0 z1) :
    exists v' : VVecEA2, v'.holds M atomMap z0 z1
```

**Verification**:
- `neg_vecEA2` and `neg_2var_vec_ea` compile sorry-free
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.EANegationClosure` succeeds

---

### Phase 6: ExistPart Rewire [NOT STARTED]

**Goal**: Replace the sorry-containing backward direction in `existPart_succ_n1_bypass` (k>0 case, KampBypass.lean lines 480-741) with a new proof path that uses EA negation closure instead of `prior_2var_transfer_until/since` from PriorComposition.lean. This eliminates all 4 live sorrys on the critical path.

**Tasks**:
- [ ] Define `existPart_succ_n1_ea`: alternative proof of ExistPart(k+1) at n=1 using the EA negation closure path
- [ ] Prove the encoding step: show "exists x in zone, nf_eval_nf M (k+1) 2 [x,t] sub_nf" is equivalent to a bracket formula or VecEA2, using CharPart(k+1) for point/interval types
- [ ] Prove the positive case: use existing VecEATranslation machinery
- [ ] Prove the negation case: apply `neg_2var_vec_ea` (Prop 4.2) to get VVecEA2, then translate via Prop 3.5
- [ ] Wire `existPart_succ_n1_ea` into `existPart_succ_n1_bypass`
- [ ] Verify `existPart_succ` compiles sorry-free
- [ ] Verify `kamp_mutual_induction` compiles sorry-free

**Timing**: 2 hours
**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` (~200 lines modified/added)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampMutualInduction.lean` (verify compilation, no changes expected)

**Verification**:
- `existPart_succ_n1_bypass` compiles sorry-free for ALL k (including k>0)
- `kamp_mutual_induction` compiles sorry-free
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampBypass` succeeds
- `grep -n sorry` in KampBypass.lean returns no results

---

### Phase 7: Integration, Cleanup, and Verification [NOT STARTED]

**Goal**: Verify the full pipeline compiles sorry-free from `completeness_discrete` down, clean up imports, and document the new EA path.

**Tasks**:
- [ ] Verify `completeness_discrete` in KampPrior.lean compiles sorry-free
- [ ] Run `lake build` on full project -- verify clean build
- [ ] Run `lean_verify` on `completeness_discrete` to confirm no axiom leaks
- [ ] Disconnect PriorComposition.lean from the import chain if EA path makes it unnecessary
- [ ] If PriorComposition is still imported by other modules, add deprecation comment
- [ ] Update module docstrings in modified files to reflect new EA path
- [ ] Add file header to EANegationClosure.lean documenting Rabinovich reference and Boneyard provenance
- [ ] Decide disposition of sorry-marked `neg_bracket_is_vbracket` and `neg_partialBracketExist_is_vbracket` in EANegation.lean: either (a) comment out / move to Boneyard, or (b) leave as non-critical-path aspirational theorems

**Timing**: 1 hour
**Depends on**: 6

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- import cleanup
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- verify only
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegation.lean` -- optional sorry disposition
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegationClosure.lean` -- docstring finalization

**Verification**:
- `lake build` succeeds with no sorry on critical path
- `grep -rn sorry Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` shows only: NfCharFormula.lean dead-code sorrys, optional EANegation.lean non-critical sorrys, and PriorComposition.lean if retained
- `lean_verify Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior.completeness_discrete` reports no sorry axiom

## Sorry Elimination Roadmap

| Phase | Sorrys Before | Sorrys After | What Changes |
|-------|--------------|-------------|--------------|
| 1 | 4 live (PriorComposition) | 4 live | Infrastructure only -- no sorry touched |
| 2 | 4 live | 4 live | New lemma (Lemma 5.3) added sorry-free |
| 3 | 4 live + 2 in EANegation | 4 live + 2 EANegation | Corollary 5.4 forward sorry-free; backward sorry non-critical |
| 4 | 4 live + 2 EANegation | 4 live + 2 EANegation | New file EANegationClosure: Lemma 5.1 forward sorry-free |
| 5 | 4 live + 2 EANegation | 4 live + 2 EANegation | Prop 4.2 sorry-free in EANegationClosure |
| 6 | 4 live + 2 EANegation | 0 live + 2 EANegation | Rewire eliminates all 4 PriorComposition sorrys from critical path |
| 7 | 0 live + 2 EANegation | 0 live + 0-2 EANegation | Verification + optional sorry disposition |

## Testing & Validation

- [ ] Each phase ends with scoped `lake build Module.Name` verification
- [ ] Phase 4 verifies `neg_interval_formula` and `neg_bounded_exists` compile sorry-free
- [ ] Phase 5 verifies `neg_vecEA2` and `neg_2var_vec_ea` compile sorry-free
- [ ] Phase 6 verifies `existPart_succ_n1_bypass` compiles sorry-free
- [ ] Phase 7 runs full `lake build` and `lean_verify` on `completeness_discrete`
- [ ] Final sorry audit: `grep -rn sorry Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` shows only non-critical code
- [ ] Type compatibility: `lean_goal` verification at key integration points

## Artifacts & Outputs

- `plans/05_revised-ea-negation-plan.md` -- this plan (revised from 01_ea-formula-plan.md)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegation.lean` -- existing (Phases 1-3 work)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegationClosure.lean` -- NEW file (Phases 4-5: Lemma 5.1 forward, Cor 5.4 forward, Props 4.2)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEAFormula.lean` -- extended with interval splitting (Phase 1)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- rewired to use EA path (Phase 6)

## Rollback/Contingency

- Phases 4-5 create a new file (EANegationClosure.lean) and do not modify existing sorry-free code. Rollback = delete the new file.
- Phase 6 rewire of KampBypass.lean is the only destructive change. If it fails, revert KampBypass.lean (the sorry path still works). The new EA machinery remains available.
- Git provides per-phase commits for rollback to any intermediate state.
- If Boneyard porting in Phase 4 reveals unexpected API incompatibilities, the `bracket_tail_satisfiable` proof (largest helper, ~100 lines) can be adapted incrementally.
