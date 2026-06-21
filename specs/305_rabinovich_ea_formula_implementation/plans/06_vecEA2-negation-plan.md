# Implementation Plan: VecEA2-Level Negation Closure (Rabinovich Lemma 5.1)

- **Task**: 305 - Rabinovich EA-formula implementation
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: Phases 1-3 [COMPLETED] (interval splitting, Lemma 5.3, Corollary 5.4 forward)
- **Research Inputs**:
  - specs/305_rabinovich_ea_formula_implementation/reports/05_vecEA2-level-lemma51.md
  - specs/305_rabinovich_ea_formula_implementation/reports/04_faithful-lemma51-design.md
  - specs/305_rabinovich_ea_formula_implementation/reports/01_ea-formula-research.md
- **Artifacts**: plans/06_vecEA2-negation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan implements the VecEA2-level three-case decomposition for Rabinovich's Lemma 5.1 and Proposition 4.2, maintaining perfect alignment with the paper's proof structure. The approach ports model-dependent, forward-only proofs from the Boneyard (`NegationClosure5.lean` and `NegationClosureProp42.lean`) into a new file `EANegationClosure.lean`, avoiding the structurally unsolvable beta_0(r_0) problem that blocked 6+ dispatches on the prior biconditional approach. The plan then rewires `KampBypass.lean` to use the EA negation closure path, eliminating all 4 live sorrys in `PriorComposition.lean` from the critical path.

### Research Integration

- **Report 05** (05_vecEA2-level-lemma51.md): Established that `neg_vecEA2_is_vvecEA2` at VecEA2 level provides perfect paper alignment. Confirmed `rightPart at index 0` equals Boneyard's `tail` definitionally. Verified Boneyard's `neg_interval_formula` avoids beta_0(r_0) via `bracket_tail_satisfiable` contrapositive. H4 adversarial verification passed on all claims. Primary source for this plan.
- **Report 04** (04_faithful-lemma51-design.md): Root cause analysis confirming beta_0(r_0) is structurally unsolvable at BracketFormula level. Recommended Boneyard forward-only porting approach.
- **Report 01** (01_ea-formula-research.md): Original architecture design, confirmed Option A approach.

### Prior Plan Reference

Plan v5 (05_revised-ea-negation-plan.md) provided the initial Boneyard porting strategy but defined Phase 4 as a single monolithic phase with ~14 task items and estimated 3 hours. Lesson learned: Phase 4 was too large for a single agent run (H8 violation). This plan decomposes the same work into four smaller phases (4A-4D), each bounded to one agent run. Phase 5 from v5 maps to Phase 5 here (same scope). Phases 6-7 from v5 are preserved with minor updates.

### Roadmap Alignment

No ROADMAP.md items explicitly reference this task's EA negation closure work.

## Goals & Non-Goals

**Goals**:
- Port helper definitions and lemmas from Boneyard NegationClosure5.lean (pureSeg, purePoint, eval_at_neg, inf_bracket_formula, bracket_tail_satisfiable)
- Port `neg_interval_formula` (Lemma 5.1 forward, model-dependent) adapted to use `HasAttainedINF`
- Port `neg_bounded_exists` (Corollary 5.4 forward, model-dependent) adapted to use `HasAttainedINF`
- Port `neg_vecEA2` and `neg_2var_vec_ea` (Proposition 4.2) from Boneyard NegationClosureProp42.lean
- Rewire `existPart_succ_n1_bypass` to use EA negation closure path
- Eliminate all 4 live sorrys in PriorComposition.lean from the critical path
- Achieve `lake build` clean (sorry-free on the critical path)

**Non-Goals**:
- Model-independent biconditional for `neg_bracket_is_vbracket` (future work)
- Removing dead-code sorrys in NfCharFormula.lean (lines 542, 657 -- deprecated)
- Removing PriorComposition.lean (stays as Boneyard reference)
- Implementing the future fragment (Section 7 of Rabinovich)
- Removing the existing sorry-marked theorems in EANegation.lean

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Boneyard proofs need adaptation beyond simple renames (behind `#exit`, not type-checked) | M | M | Research verified definitional equivalences (rightPart=tail, pureSeg=trivial). Budget 50% extra time for Fin arithmetic and API differences. |
| `HasAttainedINF.first_occ` uses `Formula` not `TemporalPred` -- adapter needed | L | H | Write `HasAttainedINF.first_occ_tp` wrapper: extract `.formula` from TemporalPred, call `first_occ`, convert back. Simple 5-line helper. |
| `prior_UZ_successor` needed for Cor 5.4 n=0 base case | M | M | Active codebase's `neg_partialBracketExist_is_vbracket` n=0 case (lines 1087-1159) is sorry-free and handles this with `by_cases` on segment failure + `HasAttainedINF`. Can derive or reuse. |
| Phase 6 rewire: bracket-to-NF type bridge may not compose with model-dependent negation | H | M | Validate types early with `lean_goal`. VecEATranslation already takes M as parameter. |
| `BracketFormula.pureSeg` vs `BracketFormula.trivial` not definitionally equal | L | M | Check via `lean_goal`; if not equal, use `trivial` directly since it has `trivial_holds` already proved. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 0 | 1, 2, 3 | -- (already completed) |
| 1 | 4 | 1, 2, 3 |
| 2 | 5 | 4 |
| 3 | 6 | 5 |
| 4 | 7 | 6 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Interval Splitting Infrastructure [COMPLETED]

**Goal**: Define `BracketFormula.splitAt` (the A_i^-/A_i^+ decomposition from Rabinovich p.10) and prove semantic correctness.

**Tasks**:
- [x] Define `BracketFormula.leftPart` and `BracketFormula.rightPart`
- [x] Prove `leftPart_holds` and `rightPart_holds` sorry-free
- [x] Prove `splitAt_combine` sorry-free
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
- [x] Prove base cases and inductive step using `HasAttainedINF`
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

**Timing**: 1.5 hours
**Depends on**: 1, 2
**Completed**: 2026-06-17

---

### Phase 4: Boneyard Port -- Helper Definitions, bracket_tail_satisfiable, and Lemma 5.1 Forward [NOT STARTED]

**Goal**: Create `EANegationClosure.lean` and port all helper definitions, `bracket_tail_satisfiable`, the INF bracket formula infrastructure, `prior_UZ_successor`, `neg_bounded_exists` (Corollary 5.4 forward), and `neg_interval_formula` (Lemma 5.1 forward) from Boneyard NegationClosure5.lean. All adapted to use `HasAttainedINF` instead of `semantic_prior_UZ`.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegationClosure.lean` with imports from `EANegation`, `VecEAClosure`, `PriorINF`
- [ ] Write `HasAttainedINF.first_occ_tp` adapter: wraps `first_occ` to accept `TemporalPred` instead of `Formula`, using `P.formula` internally. Returns `(r0, hr0_above, hr0_below, h_neg_before, hPr0)` matching Boneyard's `first_occurrence_prior_strict` signature.
- [ ] Port `TemporalPred.eval_at_neg` (Boneyard NegationClosure5.lean:112-116): `P.neg.eval_at M atomMap t <-> not P.eval_at M atomMap t`. Simple simp lemma on `neg`, `eval_at`, `Formula.neg`, `temporal_truth`.
- [ ] Check whether `BracketFormula.pureSeg` (Boneyard:78-80) is definitionally equal to `BracketFormula.trivial` (VecEAFormula.lean:305). If yes, use `trivial` directly. If no, define `pureSeg` separately and prove equivalence.
- [ ] Port `BracketFormula.purePoint` (Boneyard:72-74): 1-witness bracket with point predicate and `TemporalPred.top` segments.
- [ ] Port `BracketFormula.pureSeg_holds` (Boneyard:104-109): simp lemma for pureSeg semantics. May be unnecessary if `trivial_holds` already covers this.
- [ ] Port `BracketFormula.purePoint_holds` (Boneyard:83-101): semantics of the purePoint bracket formula.
- [ ] Port `inf_bracket_formula` definition (Boneyard:313-315): `[not P, P, True](z0, z1)` bracket.
- [ ] Port `inf_bracket_formula_holds` (Boneyard:319-346): semantics of the INF bracket.
- [ ] Port `inf_bracket_formula_prior` (Boneyard:350-360): connects first-occurrence to INF bracket. Adapt to use `HasAttainedINF.first_occ_tp` instead of `first_occurrence_prior_strict`.
- [ ] Port `inf_formula_prior_is_vbracket` (Boneyard:364-373): wraps INF bracket as VBracketFormula.
- [ ] Define `BracketFormula.tail` as alias for `BracketFormula.rightPart (0 : Fin (n+1))` or inline `rightPart` calls directly. Research confirmed definitional equality.
- [ ] Port `bracket_tail_satisfiable` (Boneyard:726-818): if tail holds on (r0, z) with first-witness conditions, then bf holds on (z0, z). Critical helper for Case B1 contrapositive. ~90 lines, mostly Fin arithmetic.
- [ ] Port `prior_UZ_successor` (Boneyard:823-841): adapt to use `HasAttainedINF.first_occ` with `Formula.top`. Needed for `neg_bounded_exists` n=0 base case.
- [ ] Port `neg_bounded_exists` (Boneyard:859-937): Corollary 5.4 forward, model-dependent. Induction on n with 3 cases (A: no point, B1: segment ok -> IH on tail, B2: segment fail -> INF). Adapt all `semantic_prior_UZ` refs to `HasAttainedINF` and all `first_occurrence_prior_strict` calls to `HasAttainedINF.first_occ_tp`.
- [ ] Port `neg_interval_formula` (Boneyard:966-1032): Lemma 5.1 forward, model-dependent. Same 3-case structure as `neg_bounded_exists` but simpler n=0 base case (push_neg on segment universal). Adapt same way.
- [ ] Verify: `lake build Bimodal.Metalogic.WeakCanonical.Kamp.EANegationClosure` succeeds sorry-free

**Timing**: 2 hours

**Depends on**: 2, 3

**Files to create**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegationClosure.lean` (~500-600 lines)

**Key Type Signatures** (adapted from Boneyard to use `HasAttainedINF`):
```lean
-- Adapter for HasAttainedINF with TemporalPred
theorem HasAttainedINF.first_occ_tp
    (h_INF : HasAttainedINF M atomMap)
    (P : TemporalPred) (z0 z1 : M.carrier) (h_lt : z0 < z1)
    (h_exists : exists x, z0 < x /\ x < z1 /\ P.eval_at M atomMap x) :
    exists r0, z0 < r0 /\ r0 < z1 /\
      P.eval_at M atomMap r0 /\
      (forall y, z0 < y -> y < r0 -> not P.eval_at M atomMap y)

-- Lemma 5.1 forward (model-dependent)
theorem neg_interval_formula
    (h_INF : HasAttainedINF M atomMap) :
    forall (n : Nat) (bf : BracketFormula n) (z0 z1 : M.carrier),
    z0 < z1 -> not bf.holds M atomMap z0 z1 ->
    exists v : VBracketFormula, v.holds M atomMap z0 z1

-- Corollary 5.4 forward (model-dependent)
theorem neg_bounded_exists
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
| `first_occurrence_prior_strict` | `HasAttainedINF.first_occ_tp` | New adapter, same output shape |
| `BracketFormula.tail` | `BracketFormula.rightPart (0 : Fin (n+1))` | Define alias or inline |
| `bracket_prepend_holds` | `BracketFormula.prepend_holds` (EANegation.lean) | Already available, same name in Boneyard |
| `BracketFormula.pureSeg` | `BracketFormula.trivial` (VecEAFormula.lean:305) | Verify equivalence, use trivial if equal |
| `BracketFormula.purePoint` | Define new | New definition needed |

**Verification**:
- All ported definitions and theorems compile sorry-free
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.EANegationClosure` succeeds
- `neg_interval_formula` and `neg_bounded_exists` are sorry-free

---

### Phase 5: Proposition 4.2 -- VecEA2 Negation Closure [NOT STARTED]

**Goal**: Port `VBracketFormula.toVVecEA2WithEndpoints`, `neg_vecEA2`, and `neg_2var_vec_ea` from Boneyard NegationClosureProp42.lean. This is the VecEA2-level three-case decomposition that matches the paper's Case 1 (endpoint failure) and Case 2+3 (bracket interior fails) structure.

**Tasks**:
- [ ] Port `VBracketFormula.toVVecEA2WithEndpoints` definition (Boneyard NegationClosureProp42.lean:47-50): wraps VBracketFormula disjuncts with endpoint predicates to form VVecEA2
- [ ] Port `VBracketFormula.toVVecEA2WithEndpoints_holds` (Boneyard NegationClosureProp42.lean:54-66): semantic correctness of the wrapping -- requires `hL`, `hR` endpoint hypotheses
- [ ] Port `neg_vecEA2` (Boneyard NegationClosureProp42.lean:75-116): Prop 4.2 single conjunct, three-case de Morgan decomposition matching the paper:
  - Case 1a: `not endpointLeft(z0)` -- trivial VVecEA2 with `endpointLeft.neg` and `pureSeg top`
  - Case 1b: `not endpointRight(z1)` -- trivial VVecEA2 with `endpointRight.neg` and `pureSeg top`
  - Case 2+3: `endpointLeft(z0) AND endpointRight(z1) AND not bracket(z0, z1)` -- apply `neg_interval_formula` from Phase 4, wrap result with `toVVecEA2WithEndpoints`
  - Adapt `semantic_prior_UZ` to `HasAttainedINF`, `neg_interval_formula` already uses `HasAttainedINF`
- [ ] Port `neg_disjunct_list` helper (Boneyard NegationClosureProp42.lean:125-153): induction on disjunct list. Each step: negate single VecEA2 via `neg_vecEA2`, combine with `VVecEA2.conj_holds_vvecEA2` (already in VecEAClosure.lean:238)
- [ ] Port `neg_2var_vec_ea` (Boneyard NegationClosureProp42.lean:159-169): Prop 4.2 full -- unfold `VVecEA2.holds`, `push_neg`, apply `neg_disjunct_list`
- [ ] Verify: `lake build Bimodal.Metalogic.WeakCanonical.Kamp.EANegationClosure` succeeds sorry-free

**Timing**: 1.5 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegationClosure.lean` -- extend with Prop 4.2 (~120 lines)

**Key Type Signatures** (adapted to `HasAttainedINF`):
```lean
-- Prop 4.2 (single conjunct) -- paper's three-case decomposition
theorem neg_vecEA2
    (h_INF : HasAttainedINF M atomMap)
    (n : Nat) (vea : VecEA2 n) (z0 z1 : M.carrier)
    (h_lt : z0 < z1) (h_neg : not vea.holds M atomMap z0 z1) :
    exists v : VVecEA2, v.holds M atomMap z0 z1

-- Prop 4.2 (full)
theorem neg_2var_vec_ea
    (h_INF : HasAttainedINF M atomMap)
    (v : VVecEA2) (z0 z1 : M.carrier)
    (h_lt : z0 < z1) (h_neg : not v.holds M atomMap z0 z1) :
    exists v' : VVecEA2, v'.holds M atomMap z0 z1
```

**Paper Alignment**:
| Paper Case | Code Branch | Construction |
|---|---|---|
| Case 1a: `not alpha_0(z_0)` | `by_cases hL : endpointLeft.eval_at` -> False | `VVecEA2 [endpointLeft.neg, top, pureSeg top]` |
| Case 1b: `not alpha_n(z_1)` | `by_cases hR : endpointRight.eval_at` -> False | `VVecEA2 [top, endpointRight.neg, pureSeg top]` |
| Case 2+3: bracket fails | Both endpoints hold -> `neg_interval_formula` | `(neg_interval_formula ...).toVVecEA2WithEndpoints epL epR` |

**Verification**:
- `neg_vecEA2` and `neg_2var_vec_ea` compile sorry-free
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.EANegationClosure` succeeds

---

### Phase 6: ExistPart Rewire [NOT STARTED]

**Goal**: Replace the sorry-containing backward direction in `existPart_succ_n1_bypass` (k>0 case, KampBypass.lean) with a new proof path that uses EA negation closure (`neg_2var_vec_ea`) instead of `prior_2var_transfer_until/since` from PriorComposition.lean. This eliminates all 4 live sorrys on the critical path.

**Tasks**:
- [ ] Define `existPart_succ_n1_ea`: alternative proof of ExistPart(k+1) at n=1 using the EA negation closure path
- [ ] Prove the encoding step: show "exists x in zone, nf_eval_nf M (k+1) 2 [x,t] sub_nf" is equivalent to a VecEA2 or VVecEA2, using CharPart(k+1) for point/interval types
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

**Timing**: 0.5 hours

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
| 1-3 | 4 live (PriorComposition) + 2 EANegation | Same | Infrastructure only |
| 4 | 4 live + 2 EANegation | 4 live + 2 EANegation | New file EANegationClosure: Lemma 5.1 + Cor 5.4 forward sorry-free |
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

- `plans/06_vecEA2-negation-plan.md` -- this plan
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegation.lean` -- existing (Phases 1-3 work)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegationClosure.lean` -- NEW file (Phases 4-5)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- rewired to use EA path (Phase 6)

## Rollback/Contingency

- Phases 4-5 create a new file (EANegationClosure.lean) and do not modify existing sorry-free code. Rollback = delete the new file.
- Phase 6 rewire of KampBypass.lean is the only destructive change. If it fails, revert KampBypass.lean (the sorry path still works). The new EA machinery remains available.
- Git provides per-phase commits for rollback to any intermediate state.
- If `bracket_tail_satisfiable` porting in Phase 4 reveals unexpected Fin arithmetic issues, the proof can be adapted incrementally -- it is the largest helper (~90 lines) but uses the same structural patterns as `BracketFormula.prepend_holds` which is already sorry-free in the active codebase.
