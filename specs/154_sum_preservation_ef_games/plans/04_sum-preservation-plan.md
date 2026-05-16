# Implementation Plan: Task #154 - Sum Preservation via BiCompat Construction (v6)

- **Task**: 154 - sum_preservation_ef_games
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: None (Phase 1 infrastructure already completed and sorry-free)
- **Research Inputs**: specs/154_sum_preservation_ef_games/reports/05_teammate-a-findings.md, specs/154_sum_preservation_ef_games/reports/05_teammate-b-findings.md, specs/154_sum_preservation_ef_games/reports/05_teammate-c-findings.md, specs/154_sum_preservation_ef_games/reports/05_teammate-d-findings.md
- **Artifacts**: plans/04_sum-preservation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close the 4 remaining sorries in `sum_nf_agree_sentence` (NEquivalence.lean lines 429, 451, 476, 496) by constructing `BiCompat sig k 1 I ms ms'` instances at each sorry site. The sorry-free infrastructure (`BiCompat`, `sum_nf_lift_gen`, `component_extend_fwd/bwd`, `extend_atoms`, `atomKind_one_pred_only`) is already in place. The sole remaining task is building a recursive helper `build_bicompat` that constructs BiCompat from component equivalence by induction on depth, then wiring it into the sorry sites. Agent D's team research verified that the dependent type cast problem is solved via `Sigma.Lex` constructors with `subst`/`Eq.rec`, and prototyped the key lemmas.

### Research Integration

Five rounds of research (reports 01-05) converged on a consensus: (1) `sum_nf_lift_gen` + `BiCompat` is the correct architecture (Agent C confirmed no simpler alternative exists); (2) the `h_atoms` construction at n=1 is trivially solved via `atomKind_one_pred_only` (Agent A verified compiling); (3) BiCompat construction decomposes into 6 independent lemmas totaling ~290 lines (Agent D decomposition); (4) the dependent type cast for Sigma.Lex order is solved by `subst h; rfl` (Agent D verified compiling); (5) the budget invariant `comp_depth j + comp_size j = k + 1` always holds (Agent B budget analysis).

### Prior Plan Reference

Plan v5 (04_sum-preservation-plan.md prior version) completed Phase 1 (signature design, BiCompat definition, component_extend, extend_atoms -- all sorry-free). Phases 2-4 were blocked because the plan lacked a concrete BiCompat construction strategy. This v6 plan replaces phases 2-4 with Agent D's decomposition into independent lemmas, which was verified to compile in prototypes.

## Goals & Non-Goals

**Goals**:
- Implement `build_bicompat` recursive helper constructing `BiCompat sig d n` from component equivalence, index matching, atom agreement, and per-component NF state
- Define order transfer helpers (`orderedSum_order_same_component`, `orderedSum_order_cross_component`) for Sigma.Lex reasoning
- Construct initial BiCompat state at each sorry site and close all 4 sorries
- Verify `doets_lemma_1_4` and full `lake build` pass sorry-free

**Non-Goals**:
- Proving `doets_lemma_1_5` (type-matching variant)
- Modifying NormalForm.lean infrastructure
- Refactoring `sum_nf_lift_gen` or `BiCompat` definitions (already sorry-free)
- Restructuring `KEquivalenceFramework` typeclass

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Per-component NF state tracking through Fin.cons creates dependent type headaches | H | M | Use existential CompNFState as Prop (not Structure). Each component carries `exists eM eN, NF agreement AND consistency`. Witnesses provided by component_extend at each step. |
| Sigma.Lex order coercion creates bureaucratic overhead in `extend_atoms` calls | M | H | Define 2 inline helpers: same-component order reduces to component order via `Sigma.Lex` right constructor + `subst`; cross-component order reduces to index comparison via `Sigma.Lex` left constructor. Agent D verified both patterns compile. |
| Budget exhaustion: component NF depth insufficient for remaining BiCompat depth | H | L | Budget invariant formally verified: `comp_depth j = k + 1 - comp_size j >= d` for all components j when `d + n = k + 1`. Agent B confirmed no off-by-one. |
| `build_bicompat` proof exceeds 200 lines causing elaboration timeout | M | M | Factor into sub-helpers: `bicompat_oracle_fwd` (forward witness), `bicompat_oracle_bwd` (backward), `build_bicompat` (assembly). Each under 80 lines. |
| Fresh component transfer for cross-component witnesses fails to produce correct NF depth | M | L | For component j with no projected elements, use `h_comp` at `m = remaining_depth + comp_size j` to bootstrap, then iterate `component_extend_fwd` to accumulate existing same-component elements. This always works since total budget is k+1. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Sigma.Lex Order Helpers and h_atoms at n=1 [COMPLETED]

**Goal**: Define the order reasoning infrastructure needed by `extend_atoms` and prove the `h_atoms` construction for the n=1 sorry site environments.

**Tasks**:
- [x] **Task 1.1**: Define `orderedSum_order_same_component` helper *(deviation: altered -- implemented as `cast_lt_iff` + `orderedSum_order_fwd_via_comp` + `orderedSum_order_bwd_via_comp` which handle same-component AND cross-component order transfer together using CompData consistency, rather than separate same/cross helpers)*
- [x] **Task 1.2**: Define `orderedSum_order_cross_component` helper *(deviation: altered -- folded into `orderedSum_order_fwd_via_comp` and `orderedSum_order_bwd_via_comp` which handle both same- and cross-component cases in a single lemma using Sigma.Lex.lt_def decomposition)*
- [x] **Task 1.3**: Define `sum_atoms_from_component_nf` helper *(deviation: altered -- implemented as `sum_atoms_one_var` with same semantics but different name; uses atomKind_one_pred_only + atom_agreement_from_nf as planned)*
- [x] **Task 1.4**: Verify all helpers compile *(completed -- all helpers compile sorry-free; also added CompData structure and cast_lt_iff transport lemma not in original plan)*

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` - Add 3 helper lemmas before `sum_nf_agree_sentence`

**Verification**:
- All 3 helpers compile sorry-free
- `lake build` passes

---

### Phase 2: build_bicompat Recursive Construction [IN PROGRESS]

**Goal**: Implement the recursive `build_bicompat` definition that constructs `BiCompat sig d n` from component equivalence, index matching, atom agreement, and per-component NF state tracking.

**Tasks**:
- [ ] **Task 2.1**: Define the per-component NF state predicate as a function parameter bundle. Rather than a separate `CompNFState` structure, pass the state as hypotheses directly to `build_bicompat`:
  ```lean
  private noncomputable def build_bicompat (sig : MonadicSignature) :
      forall (d n : Nat) (I : Type) [LinearOrder I]
      (ms ms' : I -> OrderedMonadicStructure sig)
      (h_comp : forall m, m <= d + n -> forall i nf : NormalForm sig m 0,
        nf_eval_nf (ms i) m 0 Fin.elim0 nf <-> nf_eval_nf (ms' i) m 0 Fin.elim0 nf)
      (env_M : Fin n -> (orderedSum sig I ms).carrier)
      (env_N : Fin n -> (orderedSum sig I ms').carrier)
      (h_idx : forall p : Fin n, (env_M p).1 = (env_N p).1)
      (h_atoms : forall a : AtomKind sig n,
        atom_eval (orderedSum sig I ms) env_M a <->
        atom_eval (orderedSum sig I ms') env_N a),
      BiCompat sig d n I ms ms' env_M env_N
  ```
  The key design choice: `h_comp` provides component sentence equivalence at all depths `m <= d + n`, which is the full budget. At each recursive step, `component_extend_fwd/bwd` consumes 1 depth level from the component, and the IH at `d-1` with `n+1` needs `m <= (d-1) + (n+1) = d + n`, which is available from the same `h_comp`.
- [x] **Task 2.1**: Define build_bicompat signature *(deviation: altered -- takes CompData as explicit argument instead of inline h_comp; CompData tracks per-component NF state through recursion)*
- [x] **Task 2.2**: Implement base case (d=0): `BiCompat sig 0 ... = True`, close with `trivial`. *(completed)*
- [x] **Task 2.3**: Implement forward oracle at d+1 *(partially completed -- oracle_step finds c, derives pred agreement, ord_fwd, ord_bwd, all compile sorry-free. Remaining: CompData update for recursive call)*
- [ ] **Task 2.3a**: Complete CompData update for recursive BiCompat call at depth d *(in progress -- needs if/dite on j' = j for per-component update, consistency update for Fin.cons shifted indices)*
- [ ] **Task 2.4**: Implement backward oracle at d+1 (symmetric to forward, using `component_extend_bwd`).
- [ ] **Task 2.5**: Handle the "iterate component_extend for same-component elements" sub-problem. *(deviation: skipped -- replaced by CompData structure which maintains per-component NF state through recursion. CompData.agree provides the needed multi-var component NF at each step without explicit iteration.)*
- [ ] **Task 2.6**: Verify `build_bicompat` compiles sorry-free and `lake build` passes.

**Timing**: 4 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` - Add `build_bicompat` (and optional `build_comp_nf_chain` helper) between `extend_atoms` and `sum_nf_lift_gen`

**Verification**:
- `build_bicompat` compiles sorry-free
- Type signature matches `BiCompat sig d n I ms ms' env_M env_N`
- `lake build` passes

---

### Phase 3: Close Sorries and Final Verification [NOT STARTED]

**Goal**: Wire `build_bicompat` and `sum_atoms_from_component_nf` into the 4 sorry sites, close all sorries, and verify the full dependency chain.

**Tasks**:
- [ ] **Task 3.1**: Close sorry at line 429 (case succ.mp.mp, ms' -> ms direction). The pattern:
  ```lean
  -- Construct h_atoms for n=1
  have h_atoms_1 := sum_atoms_from_component_nf i ms ms' a b h_agree_comp
  -- Construct h_idx (trivial: both envs have index i at position 0)
  have h_idx_1 : forall p : Fin 1, (Fin.cons (show _ from ⟨i, a⟩) Fin.elim0 p).1 =
      (Fin.cons (show _ from ⟨i, b⟩) Fin.elim0 p).1 := by
    intro p; fin_cases p; simp [Fin.cons_zero]
  -- Construct BiCompat
  have h_bc := build_bicompat sig k 1 I ms ms'
    (fun m hm => h_comp m (by omega)) _ _ h_idx_1 h_atoms_1
  -- Apply sum_nf_lift_gen to get NF agreement
  have h_lift := sum_nf_lift_gen sig k 1 I ms ms'
    (fun m hm => h_comp m (by omega)) _ _ h_atoms_1 h_bc
  exact ⟨⟨i, a⟩, (h_lift sub_nf).mpr hb_eval⟩
  ```
- [ ] **Task 3.2**: Close sorry at line 451 (case succ.mp.mpr, ms -> ms' direction). Same pattern with `.mp` instead of `.mpr` and witness `⟨i, b⟩`.
- [ ] **Task 3.3**: Close sorry at line 476 (case succ.mpr.mp, ms -> ms' direction). Same pattern as 3.2.
- [ ] **Task 3.4**: Close sorry at line 496 (case succ.mpr.mpr, ms' -> ms direction). Same pattern as 3.1.
- [ ] **Task 3.5**: Verify sorry count is zero in NEquivalence.lean:
  ```bash
  grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean
  ```
- [ ] **Task 3.6**: Verify `doets_lemma_1_4` in OrderedSum.lean is transitively sorry-free:
  ```bash
  grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean
  ```
  Expect only `doets_lemma_1_5` (explicitly out of scope).
- [ ] **Task 3.7**: Run `lake build` and confirm exit code 0 with no new sorries.
- [ ] **Task 3.8**: Update docstrings: remove "4 remaining sorries" and "blocker" references from `sum_nf_agree_sentence` and `KEquivalenceFramework`.

**Timing**: 2.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` - Replace 4 sorries with `build_bicompat` + `sum_nf_lift_gen` calls, update docstrings
- `Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean` - Update docstrings if needed

**Verification**:
- `lake build` succeeds with exit code 0
- `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` shows zero matches
- `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean` shows only `doets_lemma_1_5`
- No downstream regressions

## Testing & Validation

- [ ] `lake build` succeeds with exit code 0
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` shows zero sorries
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean` shows only `doets_lemma_1_5`
- [ ] `grep -rn "carrier_order := sorry" Theories/` returns no matches
- [ ] No downstream regressions: all files importing NEquivalence.lean and OrderedSum.lean build
- [ ] `lean_verify` on `sum_preservation_proof` shows no sorry axiom

## Artifacts & Outputs

- `specs/154_sum_preservation_ef_games/plans/04_sum-preservation-plan.md` (this file, v6)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` (new: order helpers, `sum_atoms_from_component_nf`, `build_bicompat`; updated: 4 sorry sites closed, docstrings)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean` (docstring updates if needed)

## Rollback/Contingency

- Git revert to pre-implementation commit restores all files
- If `build_bicompat` with general per-component state tracking proves intractable, try the **n=1 specialization**: since all 4 sorry sites start with single-element environments `![⟨i,a⟩]`/`![⟨i,b⟩]`, define `build_bicompat_one` that handles only the n=1 initial case, where component i has exactly 1 projected element and all other components have 0. This avoids the general multi-component projection problem.
- If the Sigma.Lex order helpers fail to provide the needed form, use `show`/`change` to inline the order reasoning at each call site instead of factored helpers
- If elaboration times exceed 30 seconds, factor `build_bicompat` into a separate file `Theories/Bimodal/Metalogic/WeakCanonical/SumPreservation.lean`
- As a last resort, restrict to `[Fintype I]` -- sufficient for the Reynolds pipeline since the condensation quotient is finite
