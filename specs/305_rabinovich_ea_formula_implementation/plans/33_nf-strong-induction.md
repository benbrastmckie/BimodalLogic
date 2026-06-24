# Implementation Plan: NF-Based Strong Induction on Depth (Task #305 v33)

- **Task**: 305 - rabinovich_ea_formula_implementation
- **Status**: [IMPLEMENTING]
- **Effort**: 8 hours
- **Dependencies**: None (all prerequisite sorry-free infrastructure exists)
- **Research Inputs**: reports/19_critical-path-research.md
- **Artifacts**: plans/33_nf-strong-induction.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan eliminates the sole critical-path sorry at KampPrior.lean:287 (the k>=2 case of `nf_characterizable_temporal_prior`) using Approach A from report 19: NF-based strong induction on quantifier depth. The key insight is that the arity tower (arity 2 needs arity 3 needs arity 4...) is broken by strong induction on depth: at each depth step k -> k+1, arity increases by 1 but depth decreases by 1; at depth 0 ALL arities are handled because there are no quantifier conditions. Temporal negation (`Formula.neg`) handles the universal case trivially, bypassing the impossible V-EA negation biconditional entirely. The plan proceeds in 3 phases: (1) generalized VecEA_m types with existential closure, (2) depth-0 all-arity NF-to-temporal conversion, (3) strong induction assembly replacing the sorry.

### Research Integration

**From reports/19_critical-path-research.md (primary)**:
- Single critical sorry: KampPrior.lean:287 (`nf_characterizable_temporal_prior` succ/succ case). Sorrys at EANegation.lean:1090 and :1249 are off-path and documented impossible (report 18 S4).
- Report 24's chain (Cor 5.4 fix, VecEA2 biconditional) is incorrect: both are impossible at BracketFormula level, and they do not address the arity tower.
- The NF induction avoids negation entirely: `Formula.neg` provides trivial biconditional correctness at the temporal level. No V-EA negation (Prop 4.2, Lemma 5.1) is needed.
- Strong induction on depth k resolves the arity tower: depth-0 handles all arities (no quantifier conditions); depth k+1 arity-n decomposes into atom layer + depth-k arity-(n+1) quantifier layer.
- VecEA_m types ARE needed but only for existential closure, not negation. Operations needed: type definition, conjunction, existential closure.
- Estimated effort from report 19: 700-1050 lines across 3-4 phases.

### Prior Plan Reference

Plan v32 completed B.2 fix and impossibility documentation (sorry-free infrastructure hardening). Plans v28-v31 explored various approaches that all failed due to the backward direction impossibility at BracketFormula level. Key lessons: (1) biconditionals at BracketFormula level are impossible with the interior-witness convention, (2) forward-only constructions suffice, (3) the VecEA_m approach from plan v31 was blocked by negation biconditionals but the type infrastructure concept is sound for existential closure. Effort calibration: v32 was 2.5 hours for ~200 lines of targeted work; this plan targets ~700-1050 lines with higher per-line complexity.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Define VecEA_m and VVecEA_m generalized types (arbitrary arity m) in a new file
- Implement VecEA_m existential closure using existing VBracketFormula.existsBounded_right
- Implement conjunction/disjunction closure for VecEA_m
- Generalize depth-0 NF existential conversion from arity 2-3 to arbitrary arity n
- Build `nf_nvar_exist_depth0_tl` converting depth-0 arity-(n+1) NF existentials to temporal Formula
- Replace the sorry at KampPrior.lean:287 with strong induction on k using Nat.strongRecOn
- Achieve `lake build` success with zero critical-path sorrys in KampPrior.lean
- Leave EANegation.lean sorrys (#2, #3) untouched (off-path, documented impossible)

**Non-Goals**:
- Fixing Cor 5.4 backward direction (impossible, off critical path)
- Implementing Prop 4.3 structural induction on MonadicFormula (not needed; NF induction bypasses it)
- V-EA negation (Prop 4.2, Lemma 5.1) -- the NF approach avoids this entirely
- Refactoring BracketFormula conventions (Approach B from report 19 -- too risky)
- Generalizing beyond what is needed for the completeness proof

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Zone generalization from arity 3 to arity n is harder than expected | H | M | Use inductive construction over Fin permutations rather than explicit case enumeration; fall back to bounded arity (up to 6) if general case is too complex |
| VecEA_m existential closure Fin index arithmetic is error-prone | M | M | Build on existing VBracketFormula.existsBounded_right (sorry-free); validate with lean_goal at each step |
| Nat.strongRecOn encoding for the strong induction does not type-check cleanly | M | L | Lean 4 has Nat.strongRecOn returning Sort u; if needed, use WellFoundedRelation on Nat with lt_wfRel |
| Performance: type-checking time explodes for large NF spaces | M | L | All definitions already noncomputable; monitor with lean_profile_proof; the completeness proof uses Classical.dec for good_prop |
| Existing sorry-free code breaks during refactoring | H | L | Phase 1-2 create new files only; Phase 3 modifies only the sorry site in KampPrior.lean; incremental lake build after each phase |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 1, 2 |

Phases within the same wave can execute in parallel.

---

### Phase 1: VecEA_m Types and Existential Closure [COMPLETED]

**Goal**: Define generalized VecEA_m (m-free-variable) and VVecEA_m types with existential closure, conjunction, and disjunction operations. These generalize the existing VecEA2/VVecEA2 from 2 free variables to arbitrary arity m.

**Tasks**:
- [ ] Create new file `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEA_m.lean`
- [ ] Import VecEAFormula.lean and VecEAClosure.lean
- [ ] Define `VecEA_m (n : Nat) (m : Nat)` structure: m free variables, n existential witnesses, with endpoint predicates (one per free variable), bracket formula, and free-variable position assignment
- [ ] Define semantics `VecEA_m.holds` parameterized by m-element environment (Fin m -> M.carrier)
- [ ] Define `VVecEA_m (m : Nat)` as disjunction wrapper (list of Sigma-typed VecEA_m)
- [ ] Define `VVecEA_m.holds` semantics
- [ ] Implement `VecEA_m.existClosure` : absorbs one free variable via existential quantification, producing VVecEA_m (m-1). Core operation uses BracketFormula.existsBounded_right for the bounded existential pattern
- [ ] Prove `VecEA_m.existClosure_correct` : `VVecEA_m.holds (m-1) env_rest <-> exists z, VecEA_m.holds m (insert z env_rest)`
- [ ] Implement `VVecEA_m.conj` : conjunction closure (extend BracketFormula.conj_to_bracket_exists to m free variables)
- [ ] Implement `VVecEA_m.disj` : disjunction closure (trivial: concatenate disjunct lists)
- [ ] Add `VecEA_m.toVecEA2` : specialize m=2 case back to VecEA2 for translation bridge
- [ ] Prove `VecEA_m.toVecEA2_correct` : semantics preservation
- [ ] Verify with `lake build Bimodal.Metalogic.WeakCanonical.Kamp.VecEA_m`

**Timing**: 3 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEA_m.lean` -- NEW file (~300 lines)

**Verification**:
- `lake build` succeeds with the new file
- `lean_verify` on key definitions shows no axiom dependencies beyond Classical
- VecEA_m.existClosure_correct is sorry-free

---

### Phase 2: Depth-0 All-Arity NF Existential Conversion [IN PROGRESS]

**Goal**: Generalize the depth-0 NF-to-temporal conversion from arity 2 (NfToVecEA.lean, sorry-free) and arity 3 (VecEADecomp.lean, sorry-free) to arbitrary arity n. At depth 0, NFs are purely atomic (predicate and order assignments) with no quantifier layer, so the existential `exists x, nf_eval_nf M 0 (n+1) (x :: env) sub_nf` decomposes into zones determined by order booleans. Each zone produces a VecEA_m formula that can be existentially closed and translated to temporal.

**Tasks**:
- [ ] Create new file `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfDepth0Generalized.lean`
- [ ] Import VecEA_m.lean, NfToVecEA.lean, VecEADecomp.lean, VecEATranslation.lean
- [ ] Define `nf_proj_var` : extract 1-var NF from n-var depth-0 NF for variable i (generalize nf_y_proj, nf_x_proj3, nf_t_proj3)
- [ ] Prove `extract_var_nf` : correctness of projection (generalize extract_y_nf, extract_x_nf3, extract_t_nf3)
- [ ] Define `nf_zone_vecEA_m` : for a given zone (permutation of n+1 variables determining order), construct a VecEA_m formula for the existential. Each variable position determines whether it is an endpoint or a bracket witness
- [ ] Prove `nf_zone_vecEA_m_correct` : for each consistent zone, the VecEA_m formula correctly captures `exists x, nf_eval_nf M 0 (n+1) (x :: env) sub_nf` restricted to that zone
- [ ] Define `nf_nvar_exist_depth0_tl` : the main function. For a depth-0 arity-(n+1) NF sub_nf, produce a temporal Formula equivalent to the existential. Construction: (a) enumerate all consistent zones, (b) for each zone build VecEA_m, (c) apply existClosure n-1 times to reduce to VVecEA_m 2, (d) specialize to VVecEA2 via toVecEA2, (e) apply translateLeft to get temporal Formula, (f) take disjunction over all zones
- [ ] Prove `nf_nvar_exist_depth0_tl_correct` : biconditional correctness `temporal_truth t A <-> exists env, nf_eval_nf M 0 (n+1) (env :: t) sub_nf`
- [ ] Specialize: verify that at n=1 (arity 2) the result is consistent with existing `nf_2var_exist_depth0_tl`
- [ ] Verify with `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfDepth0Generalized`

**Timing**: 3 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfDepth0Generalized.lean` -- NEW file (~300 lines)

**Verification**:
- `lake build` succeeds with the new file
- `nf_nvar_exist_depth0_tl_correct` is sorry-free
- All zone constructions sorry-free

---

### Phase 3: Strong Induction and KampPrior Rewire [NOT STARTED]

**Goal**: Replace the sorry at KampPrior.lean:287 with a strong induction on depth k. The strong induction provides: for all k' < k and all arities n, depth-k' arity-n NF existentials can be converted to temporal formulas. At each depth step, `nf_succ_char_formula` builds the characteristic formula given an `exist_tl_fn`, and the exist_tl_fn is constructed using the generalized depth-0 base case (Phase 2) plus recursive application of the induction hypothesis.

**Tasks**:
- [ ] Add import for NfDepth0Generalized.lean and VecEA_m.lean in KampPrior.lean
- [ ] Define `nf_nvar_exist_tl` : the generalized multi-variable existential conversion function. Given depth k, arity n+1, and an NF, produce a temporal Formula. At depth 0: use `nf_nvar_exist_depth0_tl` (Phase 2). At depth k+1: decompose the NF into atom layer + quantifier layer. The atom layer uses depth-0 zone decomposition. The quantifier layer has depth-k, arity-(n+2) existentials handled by recursive call
- [ ] Prove `nf_nvar_exist_tl_correct` using Nat.strongRecOn on k: biconditional correctness at all depths and arities
- [ ] Define `nf_2var_exist_tl_fn` : specialize `nf_nvar_exist_tl` to arity 2 (the interface expected by `nf_succ_char_formula`). This is the function `NormalForm sig k 2 -> Formula` with the correct biconditional property
- [ ] Prove `nf_2var_exist_tl_fn_correct` : matches the specification required by `nf_succ_char_formula_correct`
- [ ] Replace the sorry at KampPrior.lean:287 (the `k' + 1` match arm) with: construct `exist_tl_fn` using `nf_2var_exist_tl_fn` at depth k'+1, then apply `nf_succ_char_formula` and `nf_succ_char_formula_correct` exactly as the k=0 case does
- [ ] Verify the sorry is eliminated: `lean_goal` at the former sorry site should show "no goals" or the proof should be complete
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior` to verify
- [ ] Run full `lake build` to ensure no regressions

**Timing**: 2 hours

**Depends on**: 1, 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- modify sorry at line 287 (~100-200 lines of new proof code, plus imports)

**Verification**:
- `lake build` succeeds with no errors
- `lean_verify Bimodal.Metalogic.WeakCanonical.Kamp.kamp_prior_expressive_completeness` shows no sorry dependencies
- `grep -n "sorry" KampPrior.lean` returns empty (no sorrys in this file)
- EANegation.lean sorrys at :1090 and :1249 remain (off-path, documented impossible)

---

## Testing & Validation

- [ ] `lake build` succeeds with zero errors after all phases
- [ ] `lean_verify` on `kamp_prior_expressive_completeness` shows no sorry in its dependency chain
- [ ] `lean_verify` on `nf_characterizable_temporal_prior` shows no sorry
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` returns empty
- [ ] Remaining sorrys in EANegation.lean:1090 and :1249 are confirmed off critical path (not imported by KampPrior)
- [ ] New files VecEA_m.lean and NfDepth0Generalized.lean compile without warnings

## Artifacts & Outputs

- `plans/33_nf-strong-induction.md` -- this plan file
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEA_m.lean` -- new file (Phase 1)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfDepth0Generalized.lean` -- new file (Phase 2)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- modified (Phase 3)

## Rollback/Contingency

- Phases 1-2 create new files only -- no risk to existing sorry-free code. Rollback: delete the new files.
- Phase 3 modifies only the sorry site at KampPrior.lean:287. Rollback: `git checkout Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` restores the sorry.
- If the generalized zone decomposition (Phase 2) proves too complex for arbitrary arity n, fall back to bounded arity support (explicit handling up to arity 6, sufficient for quantifier depths up to 4). This reduces generality but is sufficient for the completeness proof.
- If Nat.strongRecOn does not give the right recursion shape, define a custom well-founded recursion on `(k : Nat)` using `Nat.lt_wfRel` and `WellFoundedRelation.wf.fix`.
