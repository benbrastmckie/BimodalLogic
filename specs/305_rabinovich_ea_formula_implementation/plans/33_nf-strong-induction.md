# Implementation Plan: NF-Based Strong Induction on Depth (Task #305 v33)

- **Task**: 305 - rabinovich_ea_formula_implementation
- **Status**: [IMPLEMENTING]
- **Effort**: 16 hours (8 spent, 8 remaining)
- **Dependencies**: None (all prerequisite sorry-free infrastructure exists)
- **Research Inputs**: reports/19_critical-path-research.md
- **Artifacts**: plans/33_nf-strong-induction.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan eliminates the sole critical-path sorry at KampPrior.lean:287 (the k>=2 case of `nf_characterizable_temporal_prior`) using Approach A from report 19: NF-based strong induction on quantifier depth. The key insight is that the arity tower (arity 2 needs arity 3 needs arity 4...) is broken by strong induction on depth: at each depth step k -> k+1, arity increases by 1 but depth decreases by 1; at depth 0 ALL arities are handled because there are no quantifier conditions. Temporal negation (`Formula.neg`) handles the universal case trivially, bypassing the impossible V-EA negation biconditional entirely. The plan proceeds in 3 phases: (1) generalized VecEA_m types with existential closure, (2) depth-0 all-arity NF-to-temporal conversion via `translateEF1`, (3) strong induction assembly replacing the sorry.

**Phase 2 approach pivot (dispatches 1-3)**: The original Phase 2 design used VecEA_m zones with inductive existential peeling. After 3 implementation dispatches, this was proven structurally unfixable: the IH-based formula (restrict_inner at arity n+1) cannot encode cross-conditions between inner existential variables and the free variable t when both are on the same side of x. The replacement uses `translateEF1` from Translation.lean, which handles all n+2 positions in a single Since/Until chain. At depth 0, all interval predicates (beta) are `TemporalPred.top`, making the chain a pure ordering-with-predicates assertion. See handoffs v33-phase-2-dispatch-2.md and v33-phase-2-dispatch-3.md for the full analysis.

**Phase 2 architecture (dispatches 4-6)**: The succ n case uses a three-way case split:
- (a) Inconsistent NF (order booleans form a cycle) → `Formula.bot` — FULLY PROVED
- (b) NF-equal positions (two positions have identical order/predicate assignments) → merge via IH with `skipFin`/`mergeNF` — FULLY PROVED (dispatches 4-5)
- (c) Transitive strict total order → `translateEF1` with rank function — proof structure complete, ~20 mechanical build errors (dispatch 6)

### Research Integration

**From reports/19_critical-path-research.md (primary)**:
- Single critical sorry: KampPrior.lean:287 (`nf_characterizable_temporal_prior` succ/succ case). Sorrys at EANegation.lean:1090 and :1249 are off-path and documented impossible (report 18 S4).
- Report 24's chain (Cor 5.4 fix, VecEA2 biconditional) is incorrect: both are impossible at BracketFormula level, and they do not address the arity tower.
- The NF induction avoids negation entirely: `Formula.neg` provides trivial biconditional correctness at the temporal level. No V-EA negation (Prop 4.2, Lemma 5.1) is needed.
- Strong induction on depth k resolves the arity tower: depth-0 handles all arities (no quantifier conditions); depth k+1 arity-n decomposes into atom layer + depth-k arity-(n+1) quantifier layer.
- VecEA_m types are used in Phase 1 for existential closure infrastructure (conjunction, disjunction, type definitions). Phase 2 uses `translateEF1` directly instead of VecEA_m zones.

**From dispatches 1-6 (Phase 2 implementation)**:
- IH-based formula (peeling one existential variable at a time) is fundamentally broken for the forward direction. Cross-conditions between inner witnesses and t are undetermined when both are on the same side of x.
- `translateEF1 n k alpha beta` (Translation.lean:243) is the correct tool: it builds a single Since/Until chain for all n+1 positions with evaluation point at rank k.
- At depth 0, `beta = TemporalPred.top` everywhere (no interval quantifier conditions).
- The three-way case split (inconsistent/merge/translateEF1) correctly partitions the NF space. The merge case uses `skipFin`/`unskipFin`/`mergeNF` infrastructure to reduce arity by identifying equal positions.
- Rank function defined as `nf_rank i = card { j | nf_lt_bool j i = true }` using `Finset.filter` on `Finset.univ`. Bool-valued `nf_lt_bool` avoids Prop/Bool coercion issues.
- `buildRight_top_of_mono` and `buildLeft_top_of_mono` helper theorems factor the backward direction construction.

### Prior Plan Reference

Plan v32 completed B.2 fix and impossibility documentation (sorry-free infrastructure hardening). Plans v28-v31 explored various approaches that all failed due to the backward direction impossibility at BracketFormula level. Key lessons: (1) biconditionals at BracketFormula level are impossible with the interior-witness convention, (2) forward-only constructions suffice, (3) the VecEA_m approach from plan v31 was blocked by negation biconditionals but the type infrastructure concept is sound for existential closure. Effort calibration: v32 was 2.5 hours for ~200 lines of targeted work; this plan has produced ~1318 lines across 6 dispatches.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Define VecEA_m and VVecEA_m generalized types (arbitrary arity m) in a new file
- Implement VecEA_m existential closure using existing VBracketFormula.existsBounded_right
- Implement conjunction/disjunction closure for VecEA_m
- Generalize depth-0 NF existential conversion from arity 2-3 to arbitrary arity n using `translateEF1`
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
| Mechanical build errors in translateEF1 proof are deeper than expected | M | M | Errors are typed (Fin bounds, List API renames, convert args); use lean_goal at each site to understand the actual goal state |
| Fin bound arithmetic in buildRight_top_of_mono / buildLeft_top_of_mono | M | M | Pre-compute bounds as `have` statements before `refine` blocks; use `omega` after establishing hypotheses |
| List.get_map renamed to List.getElem_map in current Mathlib | L | H | Systematic find-and-replace; already identified in dispatch 6 handoff |
| Nat.strongRecOn encoding for the strong induction does not type-check cleanly | M | L | Lean 4 has Nat.strongRecOn returning Sort u; if needed, use WellFoundedRelation on Nat with lt_wfRel |
| Performance: type-checking time explodes for large NF spaces | M | L | All definitions already noncomputable; monitor with lean_profile_proof; the completeness proof uses Classical.dec for good_prop |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2a, 2b | 1 |
| 3 | 3 | 2a, 2b |

---

### Phase 1: VecEA_m Types and Existential Closure [COMPLETED]

**Goal**: Define generalized VecEA_m (m-free-variable) and VVecEA_m types with existential closure, conjunction, and disjunction operations.

**Files**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEA_m.lean` (new, sorry-free)

---

### Phase 2a: Depth-0 NF Existential Conversion — Proof Structure [COMPLETED]

**Goal**: Build the complete proof structure for `nf_nvar_exist_depth0_tl` using three-way case split and translateEF1.

**What was built** (1318 lines, 0 sorrys, ~20 build errors):
- [x] File created with imports, helpers (nfPredAtPos, insertEnv lemmas, consistency gates)
- [x] n=0 base case proved sorry-free
- [x] Three-way case split for succ n: inconsistent / merge / strict total order
- [x] Inconsistent case (cycle in order booleans) → bot — PROVED
- [x] Merge case — skipFin/unskipFin/mergeNF infrastructure — PROVED (both directions)
  - [x] `skipFin`, `skipFin_injective`, `skipFin_ne` helper functions
  - [x] `unskipFin`, `skipFin_unskipFin`, `unskipFin_skipFin` inverses
  - [x] `mergeNF` definition for combining equal positions
  - [x] `merge_forward` : env' satisfying merged NF → env satisfying original NF
  - [x] Backward direction: env with equal values → env' satisfying merged NF
  - [x] Symmetric j=free-var sub-case handled
- [x] translateEF1 case — rank function + biconditional proof structure written
  - [x] `nf_lt_bool` : Bool-valued strict order from NF
  - [x] `nf_rank` via `Finset.filter` counting predecessors
  - [x] Rank injectivity, surjectivity, monotonicity, order reflection
  - [x] `nf_order_irrel` for proof-irrelevance of AtomKind.order
  - [x] `h_lt_acyclic` : `nf_lt_bool i j = true → nf_lt_bool j i = false`
  - [x] `buildRight_top_of_mono` / `buildLeft_top_of_mono` helper theorems
  - [x] Forward direction: witness extraction from buildRight/buildLeft chains
  - [x] Backward direction: chain construction from monotone `pts`

**Files**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfDepth0Generalized.lean` (1318 lines)

---

### Phase 2b: Fix Build Errors [COMPLETED]

**Goal**: Fix the ~20 mechanical build errors in NfDepth0Generalized.lean to achieve clean `lake build`.

**What was fixed** (dispatches 7-8):
- [x] Replaced `Fin.cons` witnesses with explicit if-then-else functions (avoids `Fin.induction` computation issues)
- [x] Helped omega with Fin.val coercions via explicit `have` statements and `show` blocks
- [x] Fixed `List.get_map` → modern List API (`List.getElem_map`, `List.ext_getElem`)
- [x] Restructured backward direction proofs using `List.map_map` + `List.map_congr_left`
- [x] Fixed `convert`/`congr` subgoal structure throughout
- [x] All `buildRight_top_of_mono` / `buildLeft_top_of_mono` Fin bound proofs fixed

**Files**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfDepth0Generalized.lean` (~1310 lines, 0 errors, 0 sorrys)

---

### Phase 3: Strong Induction and KampPrior Rewire [IN PROGRESS]

**Goal**: Replace the sorry at KampPrior.lean:287 with a strong induction on depth k. The strong induction provides: for all k' < k and all arities n, depth-k' arity-n NF existentials can be converted to temporal formulas. At each depth step, `nf_succ_char_formula` builds the characteristic formula given an `exist_tl_fn`, and the exist_tl_fn is constructed using the generalized depth-0 base case (Phase 2) plus recursive application of the induction hypothesis.

**Tasks**:
- [x] **Task 3.1**: Add import for NfDepth0Generalized.lean in KampPrior.lean *(completed)*
- [x] **Task 3.2**: Define `nf_nvar_exist_all_depths` : generalized all-depth all-arity existential conversion. By Nat.rec on k, for all n: at k=0 use `nf_nvar_exist_depth0_tl_fn`; at k+1 use IH at depth k. Returns `∃ A, ∀ M h_UZ h_SZ t, temporal_truth M atomMap t A ↔ ∃ env, nf_eval_nf M k (n+1) (insertEnv env t) sub_nf`. *(definition complete, k=0 case proved, k+1 case sorry)*
- [x] **Task 3.3**: Define `nf_nvar_exist_all_depths_fn` and `nf_nvar_exist_all_depths_fn_correct` : convenience wrapper extracting formula and correctness. *(completed)*
- [x] **Task 3.4**: Rewrite `nf_characterizable_temporal_prior` to use `nf_nvar_exist_all_depths_fn` at depth k for the exist_tl_fn. Proof uses `insertEnv env t = Fin.cons (env 0) (fun _ => t)` bridge. *(completed — no sorry in nf_characterizable_temporal_prior itself)*
- [x] **Task 3.5**: Verify old sorry at KampPrior.lean:287 is eliminated *(confirmed — nf_characterizable_temporal_prior now handles all depths via nf_nvar_exist_all_depths)*
- [ ] **Task 3.6**: Prove the k+1 case of `nf_nvar_exist_all_depths` *(deviation: altered — n=0 case proved using char_k1; n=1 and n≥2 cases remain sorry. The n=1 case is the critical path: it requires a simultaneous fixed-point construction where exist(k+1, 1, _) and char(k+2, _) are defined mutually, or a self-referential NF-disjunction formula with a "P=Q" correctness argument)*
- [ ] **Task 3.7**: Run `lake build` with zero errors and zero sorrys in KampPrior.lean
- [ ] **Task 3.8**: Verify `lean_verify` on kamp_prior_expressive_completeness shows no sorry

**BLOCKER** (Phase 3, Task 3.6):
- **What failed**: The k+1 case of `nf_nvar_exist_all_depths` at KampPrior.lean:355
- **What was tried**: Multiple approaches to construct the temporal formula:
  1. Decompose atoms/quantifiers separately — fails because they share env variables
  2. Use IH's (n+1)-variable existential for quantifier conditions — IH gives unconditional existential, but we need 1-variable with fixed env
  3. Enumerate arity-1 NF types for x — arity-1 type doesn't determine arity-2 type relative to t
  4. Extend translateEF1 with Formula (not TemporalPred) — viable but requires significant new infrastructure
- **Why stuck**: The n-variable existential at depth k+1 involves coupled atoms and quantifiers. The quantifier conditions involve inner 1-variable existentials with FIXED outer environment, which don't match the IH's unconditional existential. Building the temporal formula requires encoding quantifier conditions as nested Since/Until chains where inner chain points can reference outer chain points' positions.
- **What is needed**: Either (a) extend the translateEF1 framework to use `Formula` instead of `TemporalPred` for alpha/beta, allowing quantifier conditions to be encoded at each chain point; or (b) define a recursive formula construction that builds nested Since/Until chains with depth proportional to k; or (c) find a way to reduce the 1-variable-with-fixed-env existential to the unconditional existential from the IH.
- **Prohibited**: Do NOT use sorry, def X := True, or vacuous placeholder

**Timing**: 3 hours

**Depends on**: 2a, 2b

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
- [ ] VecEA_m.lean and NfDepth0Generalized.lean compile without warnings

## Artifacts & Outputs

- `plans/33_nf-strong-induction.md` -- this plan file
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEA_m.lean` -- new file (Phase 1)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfDepth0Generalized.lean` -- new file (Phase 2)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- modified (Phase 3)

## Dispatch History

| Dispatch | Cycle | Result | Key Change |
|----------|-------|--------|------------|
| 1 | 1 | Partial | Backward direction proved (3 subcases). 1 sorry (forward). |
| 2 | 2 | Partial | Analysis only — confirmed IH approach unfixable. |
| 3 | 3 | Partial | Restructured to 3-way case split. 3 sorrys (from 1, but fixable). |
| 4 | 4 | Partial | Filled 2 merge sorrys. Added skipFin/unskipFin. 1 sorry remains. |
| 5 | 5 | Partial | Wrote translateEF1 proof structure (~670 lines). 0 sorrys, ~20 build errors. |
| 6 | 6 | Complete | Phase 2b: fixed all ~20 build errors. 0 sorrys, 0 errors. |
| 7 | 7 | Partial | Phase 3: restructured nf_characterizable_temporal_prior, eliminated old sorry at :287. 1 sorry remains at nf_nvar_exist_all_depths k+1 (line 355). |
| 8 | 8 | In progress | Phase 3 continuation: attempting to prove nf_nvar_exist_all_depths k+1. |

## Rollback/Contingency

- Phase 1 created a new file (VecEA_m.lean) — sorry-free, no risk. Rollback: delete the file.
- Phase 2 created a new file (NfDepth0Generalized.lean) — rollback: `git checkout Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfDepth0Generalized.lean` or delete.
- Phase 3 modifies only the sorry site at KampPrior.lean:287. Rollback: `git checkout Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` restores the sorry.
- If build errors in Phase 2b prove deeper than mechanical (e.g., rank function logic is wrong), fall back to bounded arity support (explicit handling up to arity 6, sufficient for quantifier depths up to 4).
- If Nat.strongRecOn does not give the right recursion shape, define a custom well-founded recursion on `(k : Nat)` using `Nat.lt_wfRel` and `WellFoundedRelation.wf.fix`.
