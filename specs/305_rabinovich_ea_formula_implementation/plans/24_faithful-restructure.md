# Implementation Plan: Task #305 (Revised)

- **Task**: 305 - rabinovich_ea_formula_implementation
- **Status**: [IN PROGRESS]
- **Effort**: 8 hours
- **Dependencies**: None (all required sorry-free infrastructure exists)
- **Research Inputs**: reports/23_restructure-research.md, handoffs/phase-1-handoff.md
- **Artifacts**: plans/24_faithful-restructure.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Eliminate the sorry at KampPrior.lean:136 (`nf_characterizable_temporal_prior` succ case) by implementing the NF-to-temporal translation using the model-dependent negation closure chain from EANegationClosure.lean. Phase 0 (bypass archival) and Phase 1 (EndpointNegation base case) are complete. The original plan's Phases 2-4 assumed model-independent negation via EndpointNegation.lean, which has a genuine obstruction (same as EANegation.lean:1084). This revision redirects the critical path through the model-dependent chain, which is entirely sorry-free.

### Research Integration

Key findings from report 23 (restructure-research.md) and phase-1-handoff.md:
- The model-independent biconditional `neg_vecEA2_is_vvecEA2` (EndpointNegation.lean) has the SAME obstruction as EANegation.lean:1084 -- interior witnesses prevent blocking all configurations model-independently
- The model-DEPENDENT chain in EANegationClosure.lean is entirely sorry-free: `neg_vecEA2`, `neg_2var_vec_ea`, `neg_interval_formula`, `neg_bounded_exists`
- For KampPrior completeness on Prior structures, model-dependent negation closure suffices because the proof operates on specific canonical models
- `constenv_2var_determines` (NfComposition.lean) reduces n-var NF evaluation to 2-var NF evaluation for const-env evaluations -- only 2-var NFs need VecEA2 treatment
- `nf_2var_exist_depth0_tl` (NfToVecEA.lean) handles depth-0 existentials via VecEA2 translation (sorry-free)
- `translate_correct` (RabinovichTranslation.lean) converts VecEA2 to temporal formulas via Prop 3.5 (sorry-free)
- Prior structures trivially satisfy HasAttainedINF (`prior_hasAttainedINF`, sorry-free)

### Prior Plan Reference

Plan v24 (original) attempted a 6-phase restructuring using model-independent negation. Phase 0 completed (11 bypass files archived). Phase 1 discovered the model-independent obstruction. This revision narrows scope to the single critical-path sorry and uses the model-dependent chain.

### Critical Path Analysis

Only one sorry is on the critical path to `completeness_discrete`:
```
completeness_discrete
  -> kamp_prior_expressive_completeness
    -> nf_characterizable_temporal_prior (succ case)  <-- KampPrior.lean:136
```

The succ case must construct a `Formula` that characterizes a depth-(k+1) arity-1 NF on Prior structures. By `nf_eval_nf` at depth k+1, this requires:
1. Atom predicates at t (handled by `nf_depth0_char_formula`, already available)
2. For each `sub_nf : NormalForm sig k 2`, a temporal formula for `exists x, nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf` when `quant_assignment sub_nf = true`
3. For each `sub_nf` with `quant_assignment sub_nf = false`, a temporal formula for the negation of that existential

Steps 2-3 are where the model-dependent chain enters:
- Positive existentials: decompose via order direction (future/past/equal), build VecEA2, translate via Prop 3.5
- Negative existentials: use `neg_2var_vec_ea` from EANegationClosure.lean to get VVecEA2, then translate

The depth induction works because `nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf` at depth k involves existentials over depth-(k-1) NFs, which the IH handles.

## Goals & Non-Goals

**Goals**:
- Eliminate the sorry at KampPrior.lean:136 (`nf_characterizable_temporal_prior` succ case)
- Build the NF-to-temporal translation for depth k+1 using the model-dependent chain
- Achieve sorry-free `kamp_prior_expressive_completeness` and `completeness_discrete`
- Maintain `lake build` success at every phase

**Non-Goals**:
- Fixing the model-independent EndpointNegation.lean succ sorry (genuine obstruction, not on critical path)
- Fixing EANegation.lean sorries at lines 1084 and 1235 (permanent impossibilities)
- Creating new infrastructure files (ModelIndepNegation.lean, FOToVEA.lean, KampRabinovich.lean from original plan) -- the model-dependent chain makes these unnecessary
- Modifying any existing sorry-free files
- Addressing Stavi expressive completeness sorries (separate sorry chain)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Depth-k existential decomposition at arity 2 may not reduce cleanly to VecEA2 | H | M | `nf_2var_exist_depth0_tl` handles depth 0. For depth k>0, the NF structure at arity 2 has quantifier components over depth-(k-1) arity-3 NFs, but `constenv_2var_determines` collapses these to 2-var. The induction goes on k. |
| IH provides arity-1 translation but we need arity-2 existential translation | H | M | The IH gives 1-var depth-k NF -> Formula. The 2-var existential decomposes by order direction into endpoint + bracket. The endpoint predicates are 1-var formulas (handled by IH). The bracket's interior witness predicates are also 1-var (evaluated at specific points). |
| Model-dependent negation closure introduces `HasAttainedINF M atomMap` hypothesis | M | L | KampPrior already works under `semantic_prior_UZ`/`semantic_prior_SZ` hypotheses, and `prior_hasAttainedINF` derives HasAttainedINF from these. The hypothesis threads through naturally. |
| Building the conjunction over all sub_nf with their characteristic formulas may be complex | M | M | Use `Fintype.elems` to enumerate all `NormalForm sig k 2`, filter by quant_assignment, and take a conjunction of temporal formulas. The same pattern is used in `kamp_prior_expressive_completeness` for the disjunction over good NFs. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 0 | -- |
| 2 | 1 | 0 |
| 3 | 2 | 1 |
| 4 | 3 | 2 |

Phases are strictly sequential: Phase 0 and 1 are complete, Phase 2 builds the depth-induction infrastructure, Phase 3 fills the sorry.

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

### Phase 2: Depth-k Existential-to-Temporal Translation [BLOCKED]

**Goal**: Implement a theorem that translates `exists x, nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf` into a temporal formula on Prior structures, for arbitrary depth k. This is the key missing piece for filling KampPrior.lean:136.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfExistTL.lean`
- [ ] Import NfToVecEA.lean, EANegationClosure.lean, VecEATranslation.lean, NfComposition.lean, PriorDefs.lean
- [ ] Implement the main theorem `nf_2var_exist_tl` by induction on depth k:
  ```
  nf_2var_exist_tl :
    forall (k : Nat) (sub_nf : NormalForm sig k 2),
    exists (A : Formula), forall (M : ...) (h_UZ : ...) (h_SZ : ...) (t : M.carrier),
      temporal_truth M atomMap t A <->
      exists x, nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf
  ```
- [ ] **Base case (k = 0)**: Delegate to `nf_2var_exist_depth0_tl` from NfToVecEA.lean (already sorry-free; does not need Prior hypotheses)
- [ ] **Inductive step (k+1)**: The NF at depth (k+1) arity 2 has:
  - Atom predicates on (x, t): order atoms determine direction (x < t, x > t, x = t)
  - Quantifier map: for each depth-k arity-3 sub_nf, whether `exists y, nf_eval_nf M k 3 (Fin.cons y (Fin.cons x (fun _ => t))) sub_nf` holds
  - By `constenv_nvar_to_2var`, the arity-3 evaluation reduces to arity-2 evaluation on (y, x) or (y, t) envs. But the IH applies at arity 2, depth k, giving temporal formulas for each sub-sub-existential.
  - The translation composes: build the conjunction of atom literals + quantifier formulas, wrap in the appropriate temporal operator (U/S) based on order direction.
- [ ] Implement the negation case: `nf_2var_notexist_tl` for `not exists x, ...` using `neg_2var_vec_ea` from EANegationClosure.lean to get VVecEA2, then translate via `VVecEA2.translateLeft`/`translateRight`
- [ ] Verify `lake build` succeeds

**Timing**: 3 hours

**Depends on**: 1

**Files to create**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfExistTL.lean` -- NEW (~200-400 lines)

**BLOCKER** (Phase 2):
- **What failed**: The depth induction on k for `nf_2var_exist_tl` does not close.
  At depth k+1, `nf_eval_nf M (k+1) 2 (Fin.cons x (fun _ => t)) sub_nf` decomposes
  into atoms at (x,t) AND quantifier conditions involving depth-k arity-3 existentials
  `exists y, nf_eval_nf M k 3 (Fin.cons y (Fin.cons x (fun _ => t))) sub_sub_nf`.
  The env `(y, x, t)` is NOT a constenv (x and t can differ), so
  `constenv_2var_determines` / `constenv_nvar_to_2var` do not apply.
  The IH at depth k for arity 2 cannot handle arity-3 existentials.
- **What was tried**:
  1. Direct depth induction on k: fails because arity grows (2 -> 3 -> 4 -> ...)
  2. Mutual induction on (k, arity 1) and (k, arity 2): fails because arity-2 step
     needs arity-3 at depth k
  3. Strengthened induction for all arities: would require proving for all n, but
     `constenv_2var_determines` only applies to constenvs of form (z, c, c, ..., c)
  4. Using `nf_to_formula` + `kamp_prior_expressive_completeness` recursively:
     circular -- `kamp_prior_expressive_completeness` calls `nf_characterizable_temporal_prior`
  5. Using `doets_lemma_1_1` to reduce 2-var to 1-var: fails because knowing individual
     1-var NFs of x and t does not determine their 2-var NF
  6. Using VVecEA2 negation closure: model-dependent (produces different VVecEA2 for each M),
     cannot construct model-independent temporal formula from it
- **Why stuck**: Rabinovich's proof of Prop 4.3 uses structural induction on FO formulas
  (not NF depth induction). The structural induction handles ALL arities simultaneously,
  using Prop 4.2 (negation closure) for the negation case and Lemma 3.4 (V-EA closure
  under existential) for the existential case. Our NF-based approach packages the
  formula structure into a depth index, but this loses the structural induction's ability
  to handle all arities at once. The depth induction at a FIXED arity doesn't close
  because existential quantification increases arity by 1.
- **What is needed**: One of:
  (a) Implement Prop 4.3 by structural induction on MonadicFormula (not NF depth),
      using VEF closure results + Prop 4.2 negation closure. This requires building
      model-independent VVecEA2 formulas, not just model-dependent ones.
  (b) Prove a generalized `constenv_2var_determines` that works for non-constenvs
      (env = (y, x, t) with x != t), reducing arity-3 to arity-2.
  (c) Find a different induction measure that decreases at each step (e.g., total
      quantifier complexity across all arities, not just depth at a fixed arity).
- **Prohibited**: Do NOT use sorry, def X := True, or vacuous placeholder

**Verification**:
- BLOCKED: `nf_2var_exist_tl` and `nf_2var_notexist_tl` cannot be implemented
  with the current infrastructure

---

### Phase 3: Fill KampPrior.lean Sorry [BLOCKED]

**Goal**: Replace the sorry at KampPrior.lean:136 with a proof using Phase 2's `nf_2var_exist_tl` and `nf_2var_notexist_tl`.

**Tasks**:
- [ ] Add `import Bimodal.Metalogic.WeakCanonical.Kamp.NfExistTL` to KampPrior.lean
- [ ] Fill the `succ k ih` case of `nf_characterizable_temporal_prior`:
  1. Extract `nf` as `(atom_assignment, quant_assignment)` via pattern match on `NormalForm sig (k+1) 1`
  2. Build atom predicate formula: conjunction of atom literals at t (reuse `nf_depth0_char_formula` for the atom part, or build manually for arity 1)
  3. For each `sub_nf : NormalForm sig k 2`:
     - If `quant_assignment sub_nf = true`: get temporal formula from `nf_2var_exist_tl k sub_nf`
     - If `quant_assignment sub_nf = false`: get temporal formula from `nf_2var_notexist_tl k sub_nf`
  4. Combine via conjunction: atom_formula AND (conjunction over all sub_nf of their formulas)
  5. Prove biconditional: forward uses `nf_eval_nf` decomposition at depth k+1; backward reconstructs NF evaluation from temporal truth
- [ ] Verify `kamp_prior_expressive_completeness` becomes sorry-free (it calls `nf_characterizable_temporal_prior` which now has no sorry)
- [ ] Run `lean_verify` on `kamp_prior_expressive_completeness`
- [ ] Run `lean_verify` on `completeness_discrete` to check sorry chain reduction
- [ ] Verify `lake build` succeeds
- [ ] Run sorry audit: `grep -rn "sorry" Theories/ --include="*.lean" | grep -v Boneyard | grep -v "sorry-free\|-- sorry\|/- sorry"`

**Timing**: 2.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- MODIFY (fill sorry, add import)

**BLOCKER** (Phase 3):
- **Blocked by**: Phase 2 (depth-k existential translation)
- Phase 3 cannot proceed until Phase 2 provides `nf_2var_exist_tl` and `nf_2var_notexist_tl`

**Verification**:
- BLOCKED: depends on Phase 2 resolution

## Testing & Validation

- [ ] `lake build` succeeds after each phase (incremental verification)
- [ ] `nf_2var_exist_tl` is sorry-free (`lean_verify`)
- [ ] `nf_2var_notexist_tl` is sorry-free (`lean_verify`)
- [ ] `nf_characterizable_temporal_prior` is sorry-free (`lean_verify`)
- [ ] `kamp_prior_expressive_completeness` is sorry-free (`lean_verify`)
- [ ] Sorry count on critical path reduced: KampPrior.lean:136 eliminated
- [ ] External API (type signature of `kamp_prior_expressive_completeness`) unchanged
- [ ] PriorExpressiveness.lean and Completeness.lean still build correctly

## Artifacts & Outputs

- `specs/305_rabinovich_ea_formula_implementation/plans/24_faithful-restructure.md` -- this plan (revised)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfExistTL.lean` -- NEW (depth-k existential TL translation)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- MODIFIED (sorry eliminated)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EndpointNegation.lean` -- EXISTS (Phase 1, partial)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Boneyard/` -- EXISTS (Phase 0, 11 archived files)

## Rollback/Contingency

- **Full rollback**: `git checkout -- Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` restores all files. Boneyard additions are safe (no code depends on them).
- **Phase 2 blocked**: If the depth-k existential translation encounters an unforeseen obstruction in the inductive step, consider:
  1. Splitting into two sub-phases: depth-0 (already done via `nf_2var_exist_depth0_tl`) and depth-1+ (new)
  2. Using a different induction strategy (e.g., on the NF structure directly rather than depth)
  3. As a last resort, restore bypass files from Boneyard (the codebase returns to prior state)
- **Phase 3 blocked**: If the NF decomposition at depth k+1 does not match the expected form, the obstruction is in the conjunction construction. The individual pieces (existential translation, negation closure) are sorry-free, so the issue would be in the wiring. Debug by checking `nf_eval_nf` unfolding at the specific depth.
