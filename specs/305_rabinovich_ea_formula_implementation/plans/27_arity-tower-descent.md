# Implementation Plan: Arity Tower Descent for Prop 4.3 (Task #305 v5)

- **Task**: 305 - rabinovich_ea_formula_implementation
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: None (Phase 1 completed; all required sorry-free infrastructure exists)
- **Research Inputs**: reports/24_z-completeness-rabinovich.md, handoffs/phase-4-arity-tower-analysis-20260623.md, .orchestrator-handoff.json (post-Phase-1)
- **Artifacts**: plans/27_arity-tower-descent.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Eliminate the sole critical-path sorry at FOToVEA.lean:118 (`nf_exist_to_temporal_aux`) by implementing the arity tower descent: a lexicographic induction on (depth, arity) that reduces depth-(k+1) arity-2 NF existentials to temporal formulas. This plan supersedes v4 (plans/26_restricted-mutual-induction.md), whose Phase 2 approach (mutual structural induction on MonadicFormula at arities 1 and 2) is fundamentally blocked by the arity tower -- `.ex` at arity 2 introduces arity 3, which cannot be reduced to arity 2 without first solving the arity-3 case, creating an infinite regress. Phase 1 of v4 was completed successfully: FOToVEA.lean was restructured to narrow the sorry from all `MonadicFormula sig 1` down to depth-(k+1) arity-2 NF existentials only.

The new approach works by lexicographic (k,n) descent: at depth (k+1) arity 2, the quantifier layer introduces depth-k arity-3 existentials; at depth k arity 3, quantifiers introduce depth-(k-1) arity-4; and so on, until reaching depth 0 at some arity m, where a generalized zone decomposition handles the base case. The key insight is that depth decreases at each step while arity increases by 1, so the descent terminates at depth 0 after exactly k+1 steps.

### Research Integration

**From .orchestrator-handoff.json (post-Phase 1 completion)**:
- Phase 1 completed: FOToVEA.lean restructured (149 lines), sorry narrowed to `nf_exist_to_temporal_aux`
- The MonadicFormula mutual induction approach is circular when used inside NF depth induction
- NF-direct approach via `nf_exist_to_temporal_aux` avoids this circularity
- Three-step resolution path identified: (1) wire depth-0 arity-3 zones, (2) generalize to arbitrary arity, (3) lexicographic descent

**From handoffs/phase-4-arity-tower-analysis-20260623.md**:
- Combined Part A/Part B NF-depth induction has irreducible circularity at Part B depth k+1
- Five approaches exhaustively tested and all fail
- Arity tower: depth k+1 arity 2 -> depth k arity 3 -> ... -> depth 0 arity k+3

**Integrated reports**: reports/24_z-completeness-rabinovich.md

### H3 Reference Grounding Table

| Source (Rabinovich 2014) | Lean Identifier | Type Signature | Status |
|--------------------------|-----------------|----------------|--------|
| Lemma 3.2(2) (p.4) | (new: generalized arity reduction) | `NF depth m -> conjunction of 2-var temporal formulas` | Phase 3-4 target |
| Lemma 3.4(1) (p.5) | `VVecEA2.conj_holds_vvecEA2` | `VVecEA2 -> VVecEA2 -> VVecEA2` | sorry-free (VecEAClosure.lean) |
| Lemma 3.4(3) (p.5) | (implicit in zone composition) | `exists y, VecEA condition -> temporal formula` | sorry-free zones in VecEADecomp.lean |
| Prop 3.5 (p.5) | `ExistsForallSpec.translate_correct` | `temporal_truth t v.translateLeft <-> v.holdsLeft t` | sorry-free (RabinovichTranslation.lean) |
| Prop 4.2 model-dep (p.6) | `neg_2var_vec_ea` | `neg v.holds -> exists v', v'.holds` | sorry-free (EANegationClosure.lean) |
| Prop 4.3 (p.6) | `nf_exist_to_temporal_aux` (generalized) | `NF (k+1) 2 -> exists A, temporal_truth A <-> exists x, nf_eval` | Phase 4 target |
| Thm 4.4 (p.6) | `nf_exist_to_temporal_correct` + bridge | NF -> temporal Formula | Phase 4 target |
| Depth-0 3-var decomp | `nf_3var_exist_depth0_characterization` | 3-var depth-0 NF -> zone case split | sorry-free (VecEADecomp.lean) |
| Depth-0 zone theorems | `nf_3var_zone_*_correct`, `nf_3var_bracket_*_correct` | Per-zone iff with VecEA2.holds | sorry-free (VecEADecomp.lean) |
| NF-to-Formula (Doets) | `nf_to_formula` / `nf_to_formula_correct` | `NormalForm sig k n -> MonadicFormula sig n` | sorry-free (NormalForm.lean) |
| V-EA translation | `VVecEA2.translateLeft` / `translateLeft_correct` | `VVecEA2 -> Formula` | sorry-free (VecEATranslation.lean) |

### Reusable Infrastructure (all sorry-free)

| File | Lines | Key Identifiers | Role |
|------|-------|-----------------|------|
| VecEAFormula.lean | 769 | `VecEA2`, `VVecEA2`, bracket formulas | 2-var EA types and semantics |
| VecEAClosure.lean | 387 | `conj_holds_vvecEA2`, `conj_struct` | Conjunction/existential closure for 2-var |
| VecEADecomp.lean | 897 | `nf_3var_bracket_*`, `nf_3var_zone_*`, `nf_3var_exist_depth0_characterization` | Depth-0 arity-3 zone decomposition |
| EANegationClosure.lean | ~600 | `neg_2var_vec_ea`, `neg_interval_formula` | Prop 4.2 model-dependent negation |
| VecEATranslation.lean | ~300 | `translateLeft`, `translateLeft_correct` | VVecEA2 -> temporal Formula |
| NormalForm.lean | ~838 | `nf_to_formula`, `nf_to_formula_correct` | NF -> MonadicFormula conversion |
| NfExistTL.lean | 323 | `nf_characterizable_temporal_prior_combined` | Combined induction (Part A sorry-free, Part B uses nf_exist_to_temporal) |
| FOToVEA.lean | 149 | `nf_exist_to_temporal_aux` (sorry), `nf_exist_to_temporal`, `nf_exist_to_temporal_correct` | NF-direct bridge (Phase 1 output) |

### Roadmap Alignment

This plan advances the sole critical-path item: eliminating the sorry blocking `completeness_discrete`. The chain is: `kamp_prior_expressive_completeness` -> `nf_characterizable_temporal_prior` -> `nf_characterizable_temporal_prior_combined` (Part B k+1) -> `nf_exist_to_temporal_correct` -> `nf_exist_to_temporal_aux` (sorry at FOToVEA.lean:118).

## Goals & Non-Goals

**Goals**:
- Eliminate the sorry at FOToVEA.lean:118 (`nf_exist_to_temporal_aux`)
- Wire VecEADecomp depth-0 arity-3 zone theorems into temporal formula composition
- Implement generalized depth-0 zone decomposition for arbitrary arity m >= 3
- Implement lexicographic (depth, arity) descent reducing (k+1,2) to (0, k+3)
- Achieve sorry-free `nf_characterizable_temporal_prior_combined` chain through to `completeness_discrete`
- Maintain `lake build` success after every phase

**Non-Goals**:
- Fixing EANegation.lean:1084, EANegation.lean:1235, or EndpointNegation.lean:160 (off critical path, structurally unprovable at BracketFormula level)
- Building MonadicFormula-level mutual induction (superseded by NF-direct approach)
- Model-independent negation closure (model-dependent suffices for KampPrior)
- Addressing the Stavi chain (mathematically false, confirmed dead)
- Modifying any existing sorry-free code except to wire in the new chain at FOToVEA.lean

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Depth-0 arity-3 zone composition requires careful case-split on all 9 zone conditions | M | M | All 9 zone/equality/contradiction theorems exist in VecEADecomp.lean. The composition is mechanical: match zone -> apply zone theorem -> compose with translateLeft. Budget 200 lines. |
| Generalized depth-0 decomposition for arity m > 3 requires new inductive types or large case splits | H | M | At arity m, there are m*(m-1)/2 pairwise orderings. For each consistent ordering of m variables, decompose into zone conditions on pairs. Use induction on m: removing one variable reduces to arity m-1 plus the new variable's position among the others. Budget 500-800 lines across a new file. |
| Lexicographic descent may require well-founded recursion that Lean 4 struggles with | M | L | The descent is on (k, n) with k decreasing at each step and n = k+3-current_depth. Use `Nat.rec` on k (the depth parameter); no well-founded recursion needed since the outer structure is plain Nat induction. |
| NormalForm type may not decompose cleanly at arbitrary arity | M | M | NormalForm is parameterized by (sig, k, n). The existential `exists x, nf_eval_nf M k (n+1) (x::env) snf` is the standard form at all arities. If decomposition is complex, introduce a helper lemma `nf_exist_reduce_arity` abstracting the pattern. |
| Threading HasAttainedINF hypotheses through generalized descent | L | H | Expected and acceptable. All theorems in the chain already thread `h_UZ` and `h_SZ` (semantic Prior conditions). The generalized versions will follow the same pattern. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | -- |
| 3 | 3 | 1, 2 |
| 4 | 4 | 3 |

Phases 1 and 2 can execute in parallel (Wave 1-2). Phase 3 depends on both. Phase 4 depends on 3.

---

### Phase 1: FOToVEA.lean Core -- Restructure Sorry Scope [COMPLETED]

*(Completed in plan v4. Preserved verbatim.)*

**Goal**: Restructure FOToVEA.lean to narrow the sorry from `fo_to_temporal_correct` (blanket over all MonadicFormula sig 1) to `nf_exist_to_temporal_aux` (localized to depth-(k+1) arity-2 NF existentials only).

**Tasks**:
- [x] **Task 1.1**: Delete `fo_to_temporal` and `fo_to_temporal_correct`
- [x] **Task 1.2**: Add `nf_exist_to_temporal_aux` with localized sorry for NF existentials
- [x] **Task 1.3**: Restructure `nf_exist_to_temporal` to use `Classical.choose` on aux theorem
- [x] **Task 1.4**: Restructure `nf_exist_to_temporal_correct` as direct `choose_spec`
- [x] **Task 1.5**: Remove 5 unnecessary imports
- [x] **Task 1.6**: Update NfExistTL.lean comments for NF-direct architecture
- [x] **Task 1.7**: Update KampPrior.lean documentation
- [x] **Task 1.8**: Verify `lake build` succeeds (1701 jobs)

**Timing**: 2 hours (actual)

**Depends on**: none

**Files modified**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/FOToVEA.lean` -- restructured (149 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfExistTL.lean` -- comments updated
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- documentation updated

**Verification**: `lake build` succeeds. Sorry localized to `nf_exist_to_temporal_aux` only.

---

### Phase 2: Wire Depth-0 Arity-3 Zone Composition [NOT STARTED]

**Goal**: Compose the 9 zone-specific theorems from VecEADecomp.lean into a single function `nf_3var_exist_depth0_tl` that maps depth-0 arity-3 NF existentials to temporal formulas. All constituent pieces exist and are sorry-free; this phase performs pure composition.

**Tasks**:
- [ ] **Task 2.1**: Create `NfZoneCompose.lean` with imports for VecEADecomp, VecEATranslation, VecEAFormula
- [ ] **Task 2.2**: Implement zone-to-temporal composition for each of the 6 strict-order zones:
  - For each zone (ytx, txy, yxt, xty, tyx, xyt): apply zone theorem to get VVecEA2, then `translateLeft`/`translateRight` to get temporal Formula, then compose correctness proof
  - Use `nf_3var_zone_*_correct` -> VVecEA2.holds -> `translateLeft_correct` -> temporal_truth
- [ ] **Task 2.3**: Handle 2 equality cases (y=t, y=x) using `nf_3var_eq_yt` and `nf_3var_eq_yx`
  - When y=t or y=x, the existential collapses to a condition on (x,t) alone -- express as temporal formula using predFormula infrastructure
- [ ] **Task 2.4**: Handle contradictory order cases (dispatch to False -> arbitrary temporal formula)
- [ ] **Task 2.5**: Build master theorem `nf_3var_exist_depth0_tl`:
  ```
  nf_3var_exist_depth0_tl : NormalForm sig 0 3 -> Formula
  nf_3var_exist_depth0_tl_correct :
    temporal_truth M atomMap t (nf_3var_exist_depth0_tl ssn) <->
    exists y, nf_eval_nf M 0 3 (y::x::(fun _ => t)) ssn
  ```
  Case-split on the 3 order boolean pairs, dispatch to zone/equality/contradiction handlers
- [ ] **Task 2.6**: Verify `lake build` succeeds

**Timing**: 2 hours

**Depends on**: none (uses existing VecEADecomp.lean infrastructure)

**Files to create**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfZoneCompose.lean` -- NEW (~200 lines)

**Verification**:
- `nf_3var_exist_depth0_tl_correct` is sorry-free (`lean_verify`)
- `lake build` succeeds

---

### Phase 3: Generalized Depth-0 Decomposition + Lexicographic Descent [NOT STARTED]

**Goal**: Implement the full arity tower descent by Nat induction on depth k. At each depth level, the quantifier layer introduces arity-(n+1) existentials at depth-(k-1). The descent bottoms out at depth 0, where a generalized zone decomposition handles arbitrary arity m. The depth-0 generalization works by induction on m: base case m=3 uses Phase 2 infrastructure; step case m+1 decomposes by case-splitting on the new variable's position among the existing m variables, reducing each case to a conjunction of arity-m conditions (handled by IH) and pairwise 2-variable zone conditions (handled by VecEADecomp-style reasoning).

**Tasks**:
- [ ] **Task 3.1**: Create `ArityTowerDescent.lean` with imports for NfZoneCompose, VecEADecomp, FOToVEA, NormalForm
- [ ] **Task 3.2**: Implement depth-0 generalized decomposition by induction on arity m:
  - Base case m <= 2: trivial (no free variables beyond the pair (x,t))
  - Base case m = 3: delegate to `nf_3var_exist_depth0_tl` from Phase 2
  - Step case m+1: for `exists y, nf_eval_nf M 0 (m+1) (y::env) snf`:
    - The new variable y has pairwise order relations with each of the m existing variables
    - Case-split on y's position relative to existing variables (finite: at most (m+1)! orderings, but NF booleans constrain this)
    - Each consistent ordering fixes y's position; the existential over y with fixed ordering is expressible as a conjunction of: (a) conditions on y vs each existing variable (2-variable zone conditions, handled by VecEADecomp-style), and (b) conditions on the remaining m variables (handled by IH at arity m)
    - Compose: temporal formula for the conjunction
  - Type: `nf_mvar_exist_depth0_tl : (m : Nat) -> NormalForm sig 0 m -> Formula`
  - Correctness: `nf_mvar_exist_depth0_tl_correct : temporal_truth ... <-> exists y, nf_eval_nf M 0 m (y::env) snf`
- [ ] **Task 3.3**: Implement the lexicographic (k,n) descent by Nat.rec on k:
  - `nf_exist_to_temporal_general : (k n : Nat) -> NormalForm sig k n -> Formula`
  - Base case k=0: use `nf_mvar_exist_depth0_tl` from Task 3.2
  - Step case k+1 at arity n: the NF existential `exists x, nf_eval_nf M (k+1) n (x::env) snf` decomposes into:
    - Atom layer: conditions on (x, env) using predicates and pairwise orderings -- expressible as VecEA2 conditions at depth 0
    - Quantifier layer: for each sub-NF at depth k and arity (n+1), apply IH at (k, n+1)
    - Since the outer recursion is on k (Nat.rec), and the inner call at depth k and arity (n+1) is a *smaller* depth, this terminates
  - Correctness theorem composing atom layer + quantifier layer
- [ ] **Task 3.4**: Verify the generalized descent is sorry-free
- [ ] **Task 3.5**: Verify `lake build` succeeds

**Timing**: 4 hours

**Depends on**: 2 (for nf_3var_exist_depth0_tl as the m=3 base case)

**Files to create**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ArityTowerDescent.lean` -- NEW (~600-1000 lines)

**Verification**:
- `nf_exist_to_temporal_general` is sorry-free (`lean_verify`)
- `nf_mvar_exist_depth0_tl_correct` is sorry-free (`lean_verify`)
- `lake build` succeeds

---

### Phase 4: Compose into FOToVEA + Final Verification [NOT STARTED]

**Goal**: Wire `nf_exist_to_temporal_general` from Phase 3 into `nf_exist_to_temporal_aux` in FOToVEA.lean to eliminate the sorry. Verify the full chain from `nf_exist_to_temporal_aux` through `kamp_prior_expressive_completeness` to `completeness_discrete` is sorry-free. Run full sorry audit.

**Tasks**:
- [ ] **Task 4.1**: Add import for ArityTowerDescent.lean in FOToVEA.lean
- [ ] **Task 4.2**: Replace the sorry in `nf_exist_to_temporal_aux` with proof using `nf_exist_to_temporal_general`:
  - Instantiate at k+1 and arity 2
  - Use `nf_exist_to_temporal_general_correct` to establish the biconditional
  - Compose with the `h_UZ` and `h_SZ` hypotheses
- [ ] **Task 4.3**: Verify `nf_exist_to_temporal_aux` is sorry-free (`lean_verify`)
- [ ] **Task 4.4**: Verify chain sorry-freedom:
  - `nf_exist_to_temporal_correct` (delegates to aux)
  - `nf_characterizable_temporal_prior_combined` (NfExistTL.lean)
  - `nf_characterizable_temporal_prior_partA` (NfExistTL.lean)
  - `nf_characterizable_temporal_prior` (KampPrior.lean)
  - `kamp_prior_expressive_completeness` (KampPrior.lean)
- [ ] **Task 4.5**: Run `lake build` (full project, ~1700 jobs)
- [ ] **Task 4.6**: Run sorry audit on the Kamp directory:
  ```
  grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ --include="*.lean" | grep -v Boneyard | grep -v "sorry-free\|-- sorry\|/- sorry"
  ```
  Expected remaining sorry (non-critical-path only):
  - EANegation.lean:1084 (neg_bracket beta_0)
  - EANegation.lean:1235 (neg_partialBracketExist n+1)
  - EndpointNegation.lean:160 (neg_vecEA2 succ)
- [ ] **Task 4.7**: Verify `completeness_discrete` sorry chain -- check remaining sorry between `kamp_prior_expressive_completeness` and `completeness_discrete`
- [ ] **Task 4.8**: Verify external API preserved: type signatures of `kamp_prior_expressive_completeness` and `completeness_discrete` unchanged
- [ ] **Task 4.9**: Document final sorry inventory in orchestrator handoff

**Timing**: 2 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/FOToVEA.lean` -- replace sorry, add import (~20 lines changed)

**Verification**:
- `lake build` succeeds (all ~1700 jobs)
- `kamp_prior_expressive_completeness` sorry-free
- `completeness_discrete` sorry chain reduced
- Only non-critical-path sorry remain in Kamp directory
- External API unchanged

## Testing & Validation

- [x] Phase 1: atom/conjunction/negation cases sorry-free, existential sorry localized (DONE)
- [ ] Phase 2: `nf_3var_exist_depth0_tl_correct` sorry-free (`lean_verify`)
- [ ] Phase 2: `lake build` succeeds
- [ ] Phase 3: `nf_mvar_exist_depth0_tl_correct` sorry-free (`lean_verify`)
- [ ] Phase 3: `nf_exist_to_temporal_general` sorry-free (`lean_verify`)
- [ ] Phase 3: `lake build` succeeds
- [ ] Phase 4: `nf_exist_to_temporal_aux` sorry-free (`lean_verify`)
- [ ] Phase 4: `nf_characterizable_temporal_prior_combined` sorry-free (`lean_verify`)
- [ ] Phase 4: `kamp_prior_expressive_completeness` sorry-free (`lean_verify`)
- [ ] Phase 4: sorry audit shows only non-critical-path sorry
- [ ] Phase 4: External API unchanged
- [ ] Phase 4: PriorExpressiveness.lean and Completeness.lean still build correctly

## Artifacts & Outputs

- `specs/305_rabinovich_ea_formula_implementation/plans/27_arity-tower-descent.md` -- this plan
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/FOToVEA.lean` -- MODIFIED (sorry eliminated)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfZoneCompose.lean` -- NEW (~200 lines, depth-0 arity-3 zone composition)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ArityTowerDescent.lean` -- NEW (~600-1000 lines, generalized descent)

## Rollback/Contingency

- **Full rollback**: `git checkout -- Theories/Bimodal/Metalogic/WeakCanonical/Kamp/FOToVEA.lean` restores the sorry. Delete `NfZoneCompose.lean` and `ArityTowerDescent.lean`.
- **Phase 2 blocked** (zone composition difficult): If composing the 9 zone theorems with translateLeft is complex, introduce a helper `zone_to_temporal` that abstracts the pattern: zone theorem -> VVecEA2 -> translateLeft -> Formula. Each zone case becomes a single-line application.
- **Phase 3 blocked** (arbitrary arity decomposition too complex): Simplify by handling arities 3, 4, 5 explicitly (covers depths 0, 1, 2) and using sorry for arity >= 6. This still eliminates the sorry for the most common cases and narrows the remaining sorry to high-arity NFs that are rare in practice. Later work can generalize.
- **Phase 3 blocked** (Lean recursion issues): If Lean 4 struggles with the nested induction on (k, m), restructure as a single function on `k + m` (the sum decreases at each step since k decreases by 1 while m increases by 1, but k+m stays constant -- so use k as the termination measure instead, since it strictly decreases).
- **Phase 4 blocked** (composition mismatch): If the type signatures do not compose cleanly, introduce intermediate `Iff.trans` lemmas to bridge the gaps. The individual correctness theorems are all sorry-free, so composition should be mechanical.
