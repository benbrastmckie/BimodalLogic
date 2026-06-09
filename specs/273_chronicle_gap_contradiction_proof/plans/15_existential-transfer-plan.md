# Implementation Plan: Existential Transfer via Depth Induction (v15)

- **Task**: 273 - chronicle_gap_contradiction_proof
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: None
- **Research Inputs**: specs/273_chronicle_gap_contradiction_proof/reports/09_concrete-implementation-roadmap.md
- **Artifacts**: plans/15_existential-transfer-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close the 3 remaining sorry sites in `StaviCompleteness.lean` that block `stavi_expressive_completeness` and the entire completeness chain. Research report 09 discovered that `existential_transfer_from_nf` (NFGameBridge.lean:719) already solves the arity escalation problem that blocked plans v11-v14. The solution requires only a single new lemma (`nvar_nf_agreement_from_pointwise`, ~30 lines) plus edits to 3 sorry sites (~120 lines total). All mathematical infrastructure is already proved.

### Research Integration

Report 09 (`09_concrete-implementation-roadmap.md`) provided:
- Exact goal states for all 3 sorry sites (lines 2405, 2487, 2857)
- Discovery that `existential_transfer_from_nf` already exists and handles arity-parametric transfer
- Complete dependency graph showing all upstream lemmas are fully proved
- Lean code sketches for Steps 1 and 2
- Structural template (nf_exist_sf_guarded_forward) for Step 3

### Prior Plan Reference

Plans v11-v14 all failed due to escalating complexity from re-deriving infrastructure that already existed:
- v11: BLOCKED by IsSuccArchimedean circularity (discreteness assumption)
- v12: BLOCKED by 1-var interval types being insufficient
- v13: BLOCKED by fixed arity being insufficient (arity escalation)
- v14: BLOCKED by same arity escalation; proposed ~300-500 lines of new infrastructure (IsMatchedConfig, zone_match_witness_2var, etc.) that turned out to be unnecessary

Key lesson: agents over-analyzed and declared blocked instead of writing code. The research report found that the existing codebase already had the critical lemma (`existential_transfer_from_nf`) that resolves the arity problem. This plan is designed to be executed incrementally with sorry stubs, not analyzed to death.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Prove `nvar_nf_agreement_from_pointwise` (new lemma, ~30 lines)
- Fill sorry at line 2405 in `nf_2var_existential_transfer` (forward direction)
- Fill sorry at line 2487 in `nf_2var_existential_transfer` (backward direction)
- Fill sorry at line 2857 in `nf_exist_sf_guarded_backward`
- Make `stavi_expressive_completeness` sorry-free
- Run `lake build` clean

**Non-Goals**:
- Restructuring `nf_2var_existential_transfer` (existing structure is correct)
- Introducing new axioms or sorry placeholders
- Filling dead-code sorry sites in DiscreteStaviCompleteness.lean
- Building IsMatchedConfig or zone_match_witness_2var infrastructure (unnecessary)
- Modifying any file other than StaviCompleteness.lean

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Fin.cases boilerplate for 3-variable ordering (9 cases) is tedious | L | H | Follow the existing h_3var_atoms proof block (lines 2335-2375) as a template; same pattern already used |
| Depth bound arithmetic (j'+1 <= k from hj : j'+1 < k) causes omega/linarith issues | L | M | Use `by omega` which handles Nat arithmetic; the bound j'+1 <= k follows directly from j'+1 < k |
| nf_agreement_from_shared_nf signature does not match expected usage | M | L | Verify signature with lean_hover_info before writing code; fallback to manual NF evaluation equivalence |
| Sorry site 3 formula parsing is more complex than expected | H | M | Use nf_exist_sf_guarded_forward (lines 2695-2815) as structural template; factor into helper lemmas; use sorry stubs for sub-goals and fill incrementally |
| Sorry site 3 reference model argument requires nf_realizable lemma | M | M | Check if nf_realizable exists; if not, use Classical.choice with the finite model property or direct construction |
| Agent declares blocked instead of writing code | H | M | MANDATORY: write code with sorry stubs first, compile, then fill sorries one at a time. Never declare blocked without having attempted code. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

---

### Phase 1: New Lemma -- nvar_nf_agreement_from_pointwise [NOT STARTED]

**Goal**: Create a new lemma that derives n-var NF agreement at any depth d <= k from pointwise 1-var NF agreement at depth k and ordering agreement. This is the key missing piece that resolves the arity escalation problem.

**Tasks**:
- [ ] Run `lean_hover_info` on `existential_transfer_from_nf`, `nf_fraisse_compression`, `nvar_nf_eq_depth_zero_from_pointwise`, `atom_agree_from_pointwise_nf`, and `nf_agreement_from_shared_nf` to verify their exact signatures
- [ ] Insert the following lemma BEFORE `nf_2var_existential_transfer` (around line 2265 in StaviCompleteness.lean):

```lean
theorem nvar_nf_agreement_from_pointwise {sig : MonadicSignature}
    {M M' : OrderedMonadicStructure sig}
    {k : Nat} (n : Nat)
    (env_M : Fin n → M.carrier) (env_M' : Fin n → M'.carrier)
    (h_nf_points : ∀ i : Fin n,
      nf_characteristic M k 1 (fun _ => env_M i) =
      nf_characteristic M' k 1 (fun _ => env_M' i))
    (h_order : ∀ i j : Fin n,
      (env_M i < env_M j ↔ env_M' i < env_M' j)) :
    ∀ d, d ≤ k →
      nf_characteristic M d n env_M = nf_characteristic M' d n env_M' := by
  intro d hd
  induction d with
  | zero =>
    exact nvar_nf_eq_depth_zero_from_pointwise env_M env_M' h_nf_points h_order
  | succ d' ih =>
    apply nf_fraisse_compression (d' + 1) n M env_M M' env_M'
    · exact atom_agree_from_pointwise_nf env_M env_M' h_nf_points h_order
    · intro j hj chi
      have h_nf_j1 : nf_characteristic M (j + 1) n env_M =
          nf_characteristic M' (j + 1) n env_M' :=
        ih (j + 1) (by omega) (by omega)
      have h_agree_j1 := nf_agreement_from_shared_nf M env_M M' env_M'
        (nf_characteristic M (j + 1) n env_M)
        (nf_characteristic_satisfies M (j + 1) n env_M)
        (h_nf_j1 ▸ nf_characteristic_satisfies M' (j + 1) n env_M')
      exact existential_transfer_from_nf env_M env_M' h_agree_j1 chi
```

- [ ] If any signature does not match, adjust the proof accordingly (add implicit arguments, reorder parameters)
- [ ] Run `lean_verify nvar_nf_agreement_from_pointwise` to confirm no sorry/sorryAx
- [ ] If the proof does not typecheck, use sorry stubs for failing sub-goals and iterate

**Timing**: 45 minutes

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` -- insert new lemma around line 2265

**Verification**:
- `lean_verify nvar_nf_agreement_from_pointwise` shows no sorryAx
- `lean_diagnostic_messages` on the file shows no errors at the lemma

---

### Phase 2: Fill Sorry Sites 1 and 2 in nf_2var_existential_transfer [NOT STARTED]

**Goal**: Replace the sorry at line 2405 (forward direction) and line 2487 (backward direction) using `nvar_nf_agreement_from_pointwise` from Phase 1 plus `existential_transfer_from_nf`.

**Tasks**:
- [ ] Read the context around sorry site 1 (lines 2380-2420) to identify exact available hypotheses
- [ ] Replace sorry at line 2405 with code that:
  1. Applies `nvar_nf_agreement_from_pointwise` at n=3 for the config (u,x,t)/(u',x',t') to get 3-var NF agreement at depth j'+1
  2. Feeds the pointwise NF hypotheses (h_nf_u, h_nf_x, h_nf_t) as pointwise data
  3. Constructs ordering agreement for all Fin 3 pairs using Fin.cases (follow the pattern from h_3var_atoms proof, lines 2335-2375)
  4. Applies `existential_transfer_from_nf` with the 3-var NF agreement to conclude 4-var transfer

```lean
-- Sketch for sorry site 1 (line 2405):
have h_nf_3var : nf_characteristic M (j' + 1) 3
    (Fin.cons u (Fin.cons x fun _ => t)) =
    nf_characteristic M' (j' + 1) 3
    (Fin.cons u' (Fin.cons x' fun _ => t')) := by
  apply nvar_nf_agreement_from_pointwise 3
    (Fin.cons u (Fin.cons x fun _ => t))
    (Fin.cons u' (Fin.cons x' fun _ => t'))
  · -- Pointwise 1-var NF agreement
    intro i; refine Fin.cases ?_ (fun i' => ?_) i
    · simp only [Fin.cons_zero]; exact h_nf_u
    · refine Fin.cases ?_ (fun i'' => ?_) i'
      · simp only [Fin.cons_succ, Fin.cons_zero]; exact h_nf_x
      · simp only [Fin.cons_succ]; exact h_nf_t
  · -- Ordering agreement (9 cases, Fin.cases on both i and j)
    intro i j
    refine Fin.cases ?_ (fun i' => ?_) i <;>
    refine Fin.cases ?_ (fun j' => ?_) j
    -- ... (follow h_3var_atoms pattern)
    all_goals sorry  -- Fill each case individually
  · exact j' + 1
  · omega
have h_agree := nf_agreement_from_shared_nf ...
exact (existential_transfer_from_nf _ _ h_agree sub_nf).symm
```

- [ ] Fill all 9 ordering cases using the available ordering hypotheses (h_ux, h_xu, h_ut, h_tu, h_order_xt, and reflexivity/symmetry)
- [ ] Run `lean_goal` at the sorry site to verify the replacement typechecks
- [ ] Read the context around sorry site 2 (lines 2470-2500) to identify exact available hypotheses
- [ ] Replace sorry at line 2487 with the symmetric version (M and M' swapped)
- [ ] Run `lean_verify nf_2var_existential_transfer` to confirm no sorry/sorryAx
- [ ] Verify downstream: `lean_verify nf_2var_from_interval_data` should now be sorry-free (it calls nf_2var_existential_transfer)

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` -- replace sorry at lines 2405 and 2487

**Verification**:
- `lean_verify nf_2var_existential_transfer` shows no sorryAx
- `lean_verify nf_2var_from_interval_data` shows no sorryAx (chain verification)
- `lean_verify nf_2var_transfer` shows no sorryAx (chain verification)

---

### Phase 3: Fill Sorry Site 3 in nf_exist_sf_guarded_backward [NOT STARTED]

**Goal**: Replace the sorry at line 2857 in `nf_exist_sf_guarded_backward`. This is the most complex step but is now a pure formula-parsing problem (not a mathematical one) since all upstream transfer lemmas are proved.

**Tasks**:
- [ ] Read `nf_exist_sf_guarded_forward` (lines 2695-2815) as a structural template for the backward direction
- [ ] Read the context around sorry site 3 (lines 2830-2870) to identify the exact goal state and available hypotheses
- [ ] Analyze what data `h_sf` (the Stavi formula truth) provides: temporal witness extraction, interval guard data, atom matching
- [ ] Write initial proof structure with sorry stubs for each major sub-step:
  1. `sorry` -- Extract temporal witness x from Stavi formula
  2. `sorry` -- Determine x's 1-var NF type from char_k_correct
  3. `sorry` -- Build interval data from the interval guard
  4. `sorry` -- Apply nf_2var_from_interval_data to conclude 2-var NF
- [ ] Fill each sorry stub one at a time, compiling after each:
  - Sub-step 1: Unfold nf_exist_sf_guarded, case-split on order direction and consistency, extract witness from Until/Since
  - Sub-step 2: Use char_k_correct to identify which depth-k NF type the witness satisfies
  - Sub-step 3: From the interval guard truth, extract that all points between x and t satisfy constrained NFs, giving interval_nf_types data
  - Sub-step 4: Combine NF type, ordering, interval types, above_max, below_min into nf_2var_from_interval_data application
- [ ] If any sub-step proves intractable, factor it into a helper lemma with a clear type signature and sorry body, then fill the helper separately

**Timing**: 1.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` -- replace sorry at line 2857

**Verification**:
- `lean_verify nf_exist_sf_guarded_backward` shows no sorryAx
- `lean_verify nf_2var_exist_sf_classical` shows no sorryAx (chain verification)
- `lean_verify nf_characterizable_by_stavi` shows no sorryAx (chain verification)
- `lean_verify stavi_expressive_completeness` shows no sorryAx (chain verification)

---

### Phase 4: Full Chain Verification and Build [NOT STARTED]

**Goal**: Verify the entire sorry chain from `completeness_discrete` is resolved and the project builds clean.

**Tasks**:
- [ ] Run `lean_verify stavi_expressive_completeness` -- confirm no sorryAx
- [ ] Run `lean_verify US_expressively_complete_over_prior` -- confirm no sorryAx
- [ ] Run `lean_verify gap_prior_UZ_contradiction` -- confirm no sorryAx
- [ ] Run `lean_verify completeness_discrete` -- confirm no sorryAx from this chain
- [ ] Run `lake build` -- confirm full project builds without errors
- [ ] Count remaining sorry sites in StaviCompleteness.lean to confirm reduction

**Timing**: 15 minutes

**Depends on**: 3

**Files to modify**: None (verification only)

**Verification**:
- `lean_verify completeness_discrete` shows no sorryAx from this chain
- `lake build` passes without errors
- Sorry count in StaviCompleteness.lean decreased by 3

---

## What NOT to Do

These anti-patterns caused all 4 prior plans to fail. The implementing agent MUST avoid them:

1. **Do NOT over-analyze before writing code.** Write code with sorry stubs, compile, iterate. Prior agents spent their entire context budget analyzing and declared blocked without attempting code.

2. **Do NOT restructure nf_2var_existential_transfer.** The existing structure (forward/backward with zone_match + case split on j) is correct. Only replace the sorry inside `| j' + 1 =>`.

3. **Do NOT introduce new axioms or sorry placeholders.** The goal is to eliminate sorry sites, not move them.

4. **Do NOT build IsMatchedConfig, zone_match_witness_2var, or interval_2var_nf_types infrastructure.** Research report 09 proved this is unnecessary -- existential_transfer_from_nf already handles it.

5. **Do NOT try to bypass the bridge lemma with a different approach.** The bridge lemma architecture is sound; only the depth induction was missing.

6. **Do NOT solve Step 3 before Steps 1 and 2.** The dependency is strict.

7. **Do NOT declare blocked without having written and compiled code.** If a sub-goal is hard, use a sorry stub and move on to the next sub-goal. Fill stubs later.

## Testing & Validation

- [ ] `lean_verify nvar_nf_agreement_from_pointwise` -- no sorryAx
- [ ] `lean_verify nf_2var_existential_transfer` -- no sorryAx
- [ ] `lean_verify nf_2var_from_interval_data` -- no sorryAx (chain)
- [ ] `lean_verify nf_2var_transfer` -- no sorryAx (chain)
- [ ] `lean_verify nf_exist_sf_guarded_backward` -- no sorryAx
- [ ] `lean_verify nf_2var_exist_sf_classical` -- no sorryAx (chain)
- [ ] `lean_verify nf_characterizable_by_stavi` -- no sorryAx (chain)
- [ ] `lean_verify stavi_expressive_completeness` -- no sorryAx
- [ ] `lean_verify US_expressively_complete_over_prior` -- no sorryAx
- [ ] `lean_verify completeness_discrete` -- no sorryAx from this chain
- [ ] `lake build` passes without errors
- [ ] No new sorry introduced anywhere in the codebase

## Artifacts & Outputs

- `specs/273_chronicle_gap_contradiction_proof/plans/15_existential-transfer-plan.md` (this file)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (~150-200 new/modified lines)
- `specs/273_chronicle_gap_contradiction_proof/summaries/15_existential-transfer-summary.md` (after implementation)

## Rollback/Contingency

- **If Phase 1 lemma does not typecheck**: Check signatures with lean_hover_info. The most likely issue is argument ordering or implicit variable mismatch. Adjust the proof term accordingly. All dependencies are fully proved, so the mathematical content is correct.

- **If Phase 2 ordering boilerplate is too tedious**: Use `decide` or `omega` for the reflexivity cases (i = j), and build a helper tactic or use `Fin.cases` automation. The 9 cases decompose to: 3 reflexive (trivially Iff.rfl), 3 forward (using h_ux, h_ut, h_order_xt), and 3 backward (using symmetry).

- **If Phase 3 formula parsing is more complex than expected**: Factor into helper lemmas with sorry stubs. Each helper should have a clear type signature matching a sub-goal from lean_goal. Fill helpers one at a time. If the entire Phase 3 exceeds 2 hours, mark it [PARTIAL] and save progress.

- **If Phase 3 requires nf_realizable**: Search the codebase with lean_local_search for "realizable" or "nf_characteristic_surjective". If not found, construct a witness using Classical.choice with the existence theorem for NFs (every consistent NF is satisfiable in some model).

- **Git revert** to the commit before implementation if any phase introduces regressions in `lake build`.
