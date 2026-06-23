# Implementation Plan: Task #305 (Revised v2)

- **Task**: 305 - rabinovich_ea_formula_implementation
- **Status**: [IN PROGRESS]
- **Effort**: 10 hours
- **Dependencies**: None (all required sorry-free infrastructure exists)
- **Research Inputs**: reports/23_restructure-research.md, handoffs/phase-1-handoff.md, handoffs/phase-2-arity-growth-blocker.md
- **Artifacts**: plans/24_faithful-restructure.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Eliminate the sorry at KampPrior.lean:136 (`nf_characterizable_temporal_prior` succ case) by following Rabinovich's actual proof structure: structural induction on MonadicFormula (Prop 4.3), not NF depth induction. The previous plan (v24) attempted depth induction on k at a fixed arity, which is BLOCKED by arity growth (depth-k arity-2 needs depth-(k-1) arity-3, etc.). This revision replaces blocked Phases 2-3 with three new phases matching Rabinovich's approach: model-independent negation (Prop 4.2), structural induction `fo_to_vvea` (Prop 4.3), and bridge to KampPrior sorry elimination.

Phase 0 (bypass archival) is complete. Phase 1 (EndpointNegation base case) is partial but not on the critical path.

### Research Integration

Key findings integrated into this revision:

**From report 23 (restructure-research.md) and phase-1-handoff.md:**
- The model-independent biconditional `neg_vecEA2_is_vvecEA2` (EndpointNegation.lean) has the SAME obstruction as EANegation.lean:1084 -- interior witnesses prevent blocking all configurations model-independently
- The model-DEPENDENT chain in EANegationClosure.lean is entirely sorry-free: `neg_vecEA2`, `neg_2var_vec_ea`, `neg_interval_formula`, `neg_bounded_exists`
- `translate_correct` (RabinovichTranslation.lean) converts VecEA2 to temporal formulas via Prop 3.5 (sorry-free)
- Prior structures trivially satisfy HasAttainedINF (`prior_hasAttainedINF`, sorry-free)

**From phase-2-arity-growth-blocker handoff:**
- NF depth induction at fixed arity BLOCKED: arity grows (2 -> 3 -> 4 -> ...) at each depth step
- `constenv_2var_determines` only applies to constenvs `(z, c, c, ..., c)`, not general envs `(y, x, t)`
- Rabinovich's Prop 4.3 uses structural induction on FO formulas (all arities simultaneously), which avoids the arity growth problem entirely
- Option A (structural induction on MonadicFormula) is the recommended resolution

### H3 Lemma Mapping Table

| Source | Lean Identifier | Status |
|--------|----------------|--------|
| Prop 4.2 (model-indep negation) | `neg_2var_vec_ea_indep` | NEEDED (Phase 2) |
| Prop 4.3 (FO -> V-EA) | `fo_to_vvea` | NEEDED (Phase 3) |
| Prop 4.2 (model-dep negation) | `neg_2var_vec_ea` | EXISTS (EANegationClosure.lean) |
| Lemma 5.1 (interval negation) | `neg_interval_formula` | EXISTS (EANegationClosure.lean) |
| Prop 3.5 (V-EA -> TL translation) | `ExistsForallSpec.translate_correct` | EXISTS (RabinovichTranslation.lean) |
| Lemma 3.4 (V-EA closure) | `VVecEA2.conj_holds_vvecEA2` + existential closure | EXISTS (VecEAClosure.lean) |
| Bridge | `nf_characterizable_temporal_prior` | SORRY (Phase 4) |

### Critical Path Analysis

Only one sorry is on the critical path to `completeness_discrete`:
```
completeness_discrete
  -> kamp_prior_expressive_completeness
    -> nf_characterizable_temporal_prior (succ case)  <-- KampPrior.lean:136
```

The revised approach for the succ case:
1. Each depth-(k+1) arity-1 NF decomposes into atoms + existential quantifiers over depth-k arity-2 NFs
2. The existential part is expressible as a `MonadicFormula sig 2`
3. Apply `fo_to_vvea` (Prop 4.3, structural induction) to get a model-independent VVecEA2
4. Apply `ExistsForallSpec.translate_correct` (Prop 3.5) to translate VVecEA2 to a temporal formula
5. Fill the sorry at KampPrior.lean:136

## Goals & Non-Goals

**Goals**:
- Eliminate the sorry at KampPrior.lean:136 (`nf_characterizable_temporal_prior` succ case)
- Build model-independent negation closure `neg_2var_vec_ea_indep` (Prop 4.2)
- Prove `fo_to_vvea` by structural induction on MonadicFormula (Prop 4.3)
- Bridge `fo_to_vvea` to `nf_characterizable_temporal_prior` via Prop 3.5
- Achieve sorry-free `kamp_prior_expressive_completeness` and `completeness_discrete`
- Maintain `lake build` success at every phase

**Non-Goals**:
- Fixing the model-independent EndpointNegation.lean succ sorry (genuine obstruction, not on critical path)
- Fixing EANegation.lean sorries at lines 1084 and 1235 (permanent impossibilities)
- The abandoned NfExistTL.lean approach (NF depth induction blocked by arity growth)
- Modifying any existing sorry-free files (except KampPrior.lean for sorry elimination)
- Addressing Stavi expressive completeness sorries (separate sorry chain)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Model-independent negation may require enumerating too many VBracketFormula outputs | M | M | `neg_interval_formula` produces outputs determined by TemporalPred labels (finite, model-independent structure). The disjunction over all possible outputs is finite and well-defined. |
| Structural induction on MonadicFormula may not match VVecEA2 semantics cleanly at `lt` case | M | L | The `lt` constructor `MonadicFormula.lt i j` for 2-var formulas is an order atom. VVecEA2 already encodes order information via endpoint predicates and bracket structure. Map `lt 0 1` to a VVecEA2 that holds iff z0 < z1 (trivially true in the open interval context). |
| Bridging `fo_to_vvea` output to `nf_characterizable_temporal_prior` requires connecting MonadicFormula evaluation with NF evaluation | H | M | At depth k+1, `nf_eval_nf` decomposes into atom assignments + quantifier map. The quantifier map is itself expressible as a conjunction of existential MonadicFormulas. The bridge composes: NF -> MonadicFormula -> VVecEA2 -> TL Formula. |
| The `all` (universal) case of MonadicFormula structural induction | M | L | Express `all alpha` as `not (ex (not alpha))`. Use negation closure (Prop 4.2) + existential closure (Lemma 3.4). No separate universal case needed. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 0 | -- |
| 2 | 1 | 0 |
| 3 | 2 | -- |
| 4 | 3 | 2 |
| 5 | 4 | 3 |

Phase 2 has no dependency on Phase 1 (different approach). Phases 3 and 4 are strictly sequential after Phase 2.

---

### Phase 0: Archive Bypass Infrastructure to Boneyard [COMPLETED]

**Goal**: Move the 8+ bypass files to Boneyard/, update imports so `lake build` passes.

**Tasks**:
- [x] Move KampBypassCore, KampBypassEqCase, KampBypassBridge, KampBypassUntil, KampBypassSince, KampBypass, KampMutualInduction, NfCharFormula to Boneyard/
- [x] Archive KampForward and GeneralExistPart to Boneyard/ (used KampBypass internally)
- [x] Move PriorComposition sorry stubs to Boneyard/
- [x] Update KampPrior.lean: remove old imports, replace proof body with sorry placeholder
- [x] Verify `lake build` succeeds

**Timing**: 1.5 hours (actual: completed)

**Depends on**: none

**Completed**: 2026-06-23

---

### Phase 1: VecEA2-Level Lemma 5.1 Base Case [PARTIAL]

**Goal**: Implement `neg_vecEA2_is_vvecEA2` in EndpointNegation.lean.

**Tasks**:
- [x] Create EndpointNegation.lean with theorem signature
- [x] Implement base case (n = 0): sorry-free, 3 disjuncts via de Morgan (~125 lines)
- [ ] ~~Implement succ case~~ (GENUINE OBSTRUCTION: same as EANegation.lean:1084; interior witnesses prevent model-independent biconditional; documented in EndpointNegation.lean)
- [x] Verify `lake build` succeeds

**OBSTRUCTION**: The succ case is NOT on the critical path. The model-dependent versions in EANegationClosure.lean (`neg_vecEA2`, `neg_2var_vec_ea`) are sorry-free and sufficient for KampPrior. The EndpointNegation.lean sorry remains as a documented impossibility (same class as EANegation.lean:1084).

**Timing**: 4 hours (actual: base case done, succ case blocked)

**Depends on**: 0

**Completed** (partial): 2026-06-23

---

### Phase 2: Model-Independent Negation [BLOCKED]

**BLOCKER** (Phase 2):
- **What failed**: The plan's Phase 2-3-4 decomposition assumes the arity growth problem can be solved by structural induction on MonadicFormula (Rabinovich Prop 4.3). However, the `ex` case of the structural induction for `MonadicFormula sig 2` introduces `MonadicFormula sig 3`, which requires arity-3 V-EA infrastructure that does not exist in the codebase.
- **What was tried**: (1) Direct NF depth induction with `nf_2var_exist_tl_prior` helper -- circular dependency: the depth-(k+1) characterization needs temporal formulas for existentials at depth k+1. (2) Mutual structural induction on MonadicFormula for arities 1 and 2 -- blocked by arity-3 V-EA. (3) Z-completeness transfer via `US_expressively_complete_over_Z` -- requires NF realizability on Z theorem (not proved). (4) Stavi conversion via `flatten_stavi_correct_prior` -- blocked by sorry at `nf_exist_sf_guarded_backward` (StaviCompleteness.lean:2873).
- **Why stuck**: The fundamental obstruction is the arity tower: at NF depth k with arity n, the existential quantifier introduces arity n+1. The codebase has VVecEA2 (arity 2) but not general V-EA for arity >= 3. Rabinovich's Prop 4.3 requires V-EA for all arities simultaneously.
- **What is needed**: One of four resolution paths: (a) Build general V-EA infrastructure for arity >= 3 (significant new infrastructure, ~500+ lines). (b) Fix the Stavi backward sorry at StaviCompleteness.lean:2873 (nf_exist_sf_guarded_backward). (c) Prove NF realizability on Z-structures (all depth-k arity-1 NFs are realized by some Z-structure). (d) Find an alternative proof structure that avoids the arity tower.
- **Prohibited**: Do NOT use sorry, def X := True, or vacuous placeholder

*(deviation: blocked -- arity growth obstruction prevents all four planned resolution paths)*

**Goal**: Build `neg_2var_vec_ea_indep`, a model-independent version of `neg_2var_vec_ea` that produces a VVecEA2 whose structure depends only on the input VVecEA2 (not on any specific model M).

**Signature**:
```lean
theorem neg_2var_vec_ea_indep {sig : MonadicSignature}
    (v : VVecEA2) :
    { v' : VVecEA2 //
      ∀ (M : OrderedMonadicStructure sig)
        (atomMap : Formula → sig.preds)
        (h_INF : HasAttainedINF M atomMap)
        (z0 z1 : M.carrier) (h_lt : z0 < z1),
        (¬ v.holds M atomMap z0 z1) → v'.holds M atomMap z0 z1 }
```

**Technique**: Enumerate all possible VBracketFormula outputs from `neg_interval_formula` by case-splitting on boolean conditions (pointType occurrence at endpoints, segmentType satisfaction in the interval). Each case produces a VBracketFormula whose structure depends only on TemporalPred labels, which are model-independent. Take the disjunction of ALL possible outputs as the model-independent VVecEA2. Prove: for any Prior structure M, at least one disjunct holds.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ModelIndepNegation.lean`
- [ ] Import EANegationClosure.lean, VecEAClosure.lean, VecEAFormula.lean
- [ ] Analyze `neg_interval_formula` to catalog all possible VBracketFormula outputs (finite set determined by TemporalPred labels)
- [ ] For each disjunct in VVecEA2: each disjunct's endpoint predicates and bracket formula are structurally determined by the input VVecEA2's TemporalPred labels
- [ ] Build `neg_2var_vec_ea_indep` by taking the disjunction over all possible outputs
- [ ] Prove correctness: for any model M satisfying HasAttainedINF, if `not v.holds M atomMap z0 z1` then `v'.holds M atomMap z0 z1` (at least one disjunct is the one `neg_2var_vec_ea` would produce for M)
- [ ] Verify `lake build` succeeds

**Timing**: 2.5 hours

**Depends on**: none (uses existing sorry-free infrastructure in EANegationClosure.lean)

**Files to create**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ModelIndepNegation.lean` -- NEW (~400 lines)

**Key dependency**: `neg_interval_formula` in EANegationClosure.lean (sorry-free, model-dependent). This phase lifts it to model-independent by enumerating all possible case-split outcomes.

**Verification**:
- [ ] `neg_2var_vec_ea_indep` is sorry-free (`lean_verify`)
- [ ] `lake build` succeeds

---

### Phase 3: Structural Induction fo_to_vvea [NOT STARTED]

**Goal**: Prove `fo_to_vvea`, Rabinovich's Prop 4.3: every `MonadicFormula sig 2` is equivalent to a VVecEA2 on Prior structures. This uses structural induction on MonadicFormula, avoiding the arity growth problem that blocked the NF depth induction approach.

**Signature**:
```lean
theorem fo_to_vvea {sig : MonadicSignature}
    (psi : MonadicFormula sig 2) :
    { v : VVecEA2 //
      ∀ (M : OrderedMonadicStructure sig)
        (atomMap : Formula → sig.preds)
        (h_INF : HasAttainedINF M atomMap)
        (z0 z1 : M.carrier) (h_lt : z0 < z1),
        eval M (Fin.cons z0 (fun _ => z1)) psi ↔ v.holds M atomMap z0 z1 }
```

**Structural induction on MonadicFormula (Rabinovich Prop 4.3)**:
- **`atom p i`**: Directly a VVecEA2 -- endpoint predicates encode whether `p` holds at `z0` (i=0) or `z1` (i=1)
- **`lt i j`**: Order atom. For `lt 0 1` (z0 < z1), this is trivially true in the open interval context. Build a VVecEA2 that always holds. For `lt 1 0`, build one that never holds (empty disjunction).
- **`not alpha`**: By IH, `alpha` maps to some `v : VVecEA2`. Apply `neg_2var_vec_ea_indep` from Phase 2 to get `v' : VVecEA2` encoding the negation.
- **`and alpha beta`**: By IH, `alpha` maps to `v1` and `beta` maps to `v2`. Use `VVecEA2.conj_holds_vvecEA2` from VecEAClosure.lean (Lemma 3.4, conjunction closure).
- **`ex alpha`**: By IH on `alpha : MonadicFormula sig 3`, get `v : VVecEA2` for the 3-variable formula. Apply VVecEA2 existential closure from VecEAClosure.lean (Lemma 3.4, existential quantification). Note: the IH applies to `alpha : MonadicFormula sig (2+1)` directly because structural induction handles all arities simultaneously.
- **`all alpha`**: Express as `not (ex (not alpha))`. Use negation closure (Phase 2) + existential closure (Lemma 3.4) + negation closure again.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/FOToVEA.lean`
- [ ] Import ModelIndepNegation.lean, VecEAClosure.lean, MonadicFO.lean
- [ ] Implement `fo_to_vvea` by structural induction on MonadicFormula
- [ ] Handle `atom` case: map predicate atoms to VVecEA2 endpoint predicates
- [ ] Handle `lt` case: map order atoms to trivial/empty VVecEA2
- [ ] Handle `not` case: apply `neg_2var_vec_ea_indep` (Phase 2)
- [ ] Handle `and` case: apply `VVecEA2.conj_holds_vvecEA2` (VecEAClosure.lean)
- [ ] Handle `ex` case: apply VVecEA2 existential closure (VecEAClosure.lean)
- [ ] Handle `all` case: reduce to `not (ex (not alpha))` and compose closures
- [ ] Verify `lake build` succeeds

**Timing**: 2 hours

**Depends on**: 2

**Files to create**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/FOToVEA.lean` -- NEW (~300 lines)

**Verification**:
- [ ] `fo_to_vvea` is sorry-free (`lean_verify`)
- [ ] `lake build` succeeds

---

### Phase 4: Bridge and KampPrior Sorry Elimination [NOT STARTED]

**Goal**: Connect `fo_to_vvea` to `nf_characterizable_temporal_prior` and eliminate the sorry at KampPrior.lean:136.

**Bridge logic**:
1. For each depth-(k+1) arity-1 NF, the existential quantifier part is expressible as a `MonadicFormula sig 2`
2. Apply `fo_to_vvea` (Phase 3) to get a VVecEA2
3. Apply `ExistsForallSpec.translate_correct` (Prop 3.5, RabinovichTranslation.lean) to translate VVecEA2 to a temporal `Formula`
4. Compose with the atom predicate conjunction to get the full characteristic temporal formula
5. Fill the sorry at KampPrior.lean:136

**Tasks**:
- [ ] Add imports for FOToVEA.lean and RabinovichTranslation.lean to KampPrior.lean
- [ ] Build the bridge: for each `sub_nf : NormalForm sig k 2` in the quantifier map:
  - Express `exists x, nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf` as evaluation of a `MonadicFormula sig 2`
  - Apply `fo_to_vvea` to get VVecEA2
  - Apply `ExistsForallSpec.translate_correct` to get temporal formula
- [ ] Fill the `succ k ih` case of `nf_characterizable_temporal_prior`:
  1. Build atom predicate formula (conjunction of atom literals at t)
  2. For each quantifier component, get temporal formula via the bridge
  3. Combine into a single temporal formula characterizing the NF
  4. Prove biconditional correctness
- [ ] Verify `kamp_prior_expressive_completeness` becomes sorry-free
- [ ] Run `lean_verify` on `kamp_prior_expressive_completeness`
- [ ] Run `lean_verify` on `completeness_discrete` to check sorry chain reduction
- [ ] Verify `lake build` succeeds
- [ ] Run sorry audit: `grep -rn "sorry" Theories/ --include="*.lean" | grep -v Boneyard | grep -v "sorry-free\|-- sorry\|/- sorry"`

**Timing**: 1.5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- MODIFY (fill sorry, add imports)

**Verification**:
- [ ] `nf_characterizable_temporal_prior` is sorry-free (`lean_verify`)
- [ ] `kamp_prior_expressive_completeness` is sorry-free (`lean_verify`)
- [ ] `completeness_discrete` sorry chain reduced
- [ ] `lake build` succeeds

## Testing & Validation

- [ ] `lake build` succeeds after each phase (incremental verification)
- [ ] `neg_2var_vec_ea_indep` is sorry-free (`lean_verify`)
- [ ] `fo_to_vvea` is sorry-free (`lean_verify`)
- [ ] `nf_characterizable_temporal_prior` is sorry-free (`lean_verify`)
- [ ] `kamp_prior_expressive_completeness` is sorry-free (`lean_verify`)
- [ ] Sorry count on critical path reduced: KampPrior.lean:136 eliminated
- [ ] External API (type signature of `kamp_prior_expressive_completeness`) unchanged
- [ ] PriorExpressiveness.lean and Completeness.lean still build correctly

## Artifacts & Outputs

- `specs/305_rabinovich_ea_formula_implementation/plans/24_faithful-restructure.md` -- this plan (revised v2)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ModelIndepNegation.lean` -- NEW (Phase 2, model-independent negation, ~400 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/FOToVEA.lean` -- NEW (Phase 3, FO -> VVecEA2, ~300 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- MODIFIED (Phase 4, sorry eliminated, ~200 lines added)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EndpointNegation.lean` -- EXISTS (Phase 1, partial, not on critical path)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Boneyard/` -- EXISTS (Phase 0, 11 archived files)

## Rollback/Contingency

- **Full rollback**: `git checkout -- Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` restores all files. New files (ModelIndepNegation.lean, FOToVEA.lean) can simply be deleted.
- **Phase 2 blocked**: If enumerating all `neg_interval_formula` outputs proves infeasible, consider:
  1. Using a weaker model-independent result that covers enough cases for the structural induction
  2. Restricting to Prior structures at the `neg_2var_vec_ea_indep` level (weakening from HasAttainedINF to Prior hypotheses)
- **Phase 3 blocked**: If the structural induction `ex` case does not compose cleanly:
  1. Check whether VecEAClosure existential closure handles the arity shift from `MonadicFormula sig 3` to VVecEA2
  2. If not, may need an intermediate lemma bridging 3-variable VecEA to 2-variable VecEA2
- **Phase 4 blocked**: If connecting MonadicFormula evaluation to NF evaluation is difficult, consider:
  1. Building the bridge lemma separately: `nf_eval_nf_as_monadic_eval` showing NF evaluation equals evaluation of an explicit MonadicFormula
  2. As a last resort, restore bypass files from Boneyard (the codebase returns to prior state)
