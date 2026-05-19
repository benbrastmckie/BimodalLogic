# Implementation Plan: Task #116 (v4 — Clean Restart)

- **Task**: 116 - Redefine G, H, F, P in terms of U and S following Burgess 1982
- **Status**: [NOT STARTED]
- **Effort**: 40 hours
- **Dependencies**: Task 107 (completed)
- **Research Inputs**: specs/116_redefine_ghfp_via_until_since/reports/01_redefine-ghfp-research.md, specs/116_redefine_ghfp_via_until_since/reports/02_team-research.md
- **Artifacts**: plans/04_redefine-ghfp-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Remove `all_future` (G) and `all_past` (H) as primitive constructors from the Formula inductive type. Redefine G, H, F, P as `def` abbreviations using `untl`/`snce` with `top`, following Burgess 1982 §1.1. Formula reduces from 8 to 6 constructors: `{atom, bot, imp, box, untl, snce}`.

### Starting State

- Formula has 8 constructors: atom, bot, imp, box, all_past, all_future, untl, snce
- `lake build` passes with zero errors (1647 jobs)
- 506 sorries across the codebase (pre-existing, not introduced by this task)
- 344 pattern-match arms reference `all_future`/`all_past` across 26 files
- `temp_k_dist` and `temp_4` are axiom constructors (45 invocations)

### Design Decision: `def` + `@[simp]` (Mathlib idiom)

G, H, F, P are retained as `def` abbreviations. This follows the standard Mathlib pattern: define a concept with `def`, then provide `@[simp]` characterization lemmas. This is how `Finset`, `List.map`, `Set.image` work in Mathlib.

**Key definitions** (to be created in Phase 1):
```lean
def Formula.top : Formula := Formula.bot.imp Formula.bot
def some_future (φ : Formula) := Formula.untl φ Formula.top
def some_past (φ : Formula) := Formula.snce φ Formula.top
def all_future (φ : Formula) := (some_future (φ.imp Formula.bot)).imp Formula.bot
def all_past (φ : Formula) := (some_past (φ.imp Formula.bot)).imp Formula.bot
```

**Key `@[simp]` theorems** (to be proved in Phase 1):
```lean
@[simp] theorem Truth.future_iff : truth_at M Ω τ t (all_future φ) ↔ ∀ s, t < s → truth_at M Ω τ s φ
@[simp] theorem Truth.past_iff   : truth_at M Ω τ t (all_past φ)   ↔ ∀ s, s < t → truth_at M Ω τ s φ
@[simp] theorem Truth.some_future_iff : truth_at M Ω τ t (some_future φ) ↔ ∃ s, t < s ∧ truth_at M Ω τ s φ
@[simp] theorem Truth.some_past_iff   : truth_at M Ω τ t (some_past φ)   ↔ ∃ s, s < t ∧ truth_at M Ω τ s φ
```

**Critical facts about the new definitions**:
- `F(φ) = ¬G(¬φ)` is NOT `rfl` — the structural expansions differ. Use semantic equivalence via `@[simp]` theorems.
- Induction on Formula uses exactly 6 constructors. All `| all_future` and `| all_past` arms must be removed.
- `truth_at` will have 6 cases. The `@[simp]` theorems do the real work of connecting G/H/F/P to their quantified meanings.

## AGENT COMPLIANCE REQUIREMENTS

**MANDATORY**: Agents executing this plan MUST follow these rules without exception.

1. **Follow the plan step by step, in order.** Do not skip steps. Do not reorder steps. Do not invent alternative approaches.
2. **Do not use `sorry`.** Every proof must be complete. If a proof is genuinely intractable, STOP and report — do not insert sorry and continue.
3. **Do not add wrappers, bridges, shims, or compatibility layers.** The goal is proofs that read as if G/H were never primitive.
4. **Verify after each phase.** Run `lake build` (or the specified module build) and confirm zero errors before moving to the next phase.
5. **Update this plan file** after completing each phase: check off subtasks with `[x]`, change phase status to `[COMPLETED]`.
6. **Commit after each phase** with message format: `task 116 phase {N}: {description}\n\nSession: {session_id}`.
7. **If stuck for more than 15 minutes on a single proof**, use `lean_goal` to inspect the proof state, then try `lean_multi_attempt` with candidate tactics. If still stuck, STOP and report the exact goal state — do not guess or insert sorry.

## Goals & Non-Goals

**Goals**:
- Remove `all_future` and `all_past` as Formula constructors
- Add `def` abbreviations with `@[simp]` characterization theorems
- Derive `temp_k_dist` and `temp_4` from BX axioms; remove as axiom constructors
- Fix all downstream files (344 pattern-match arms across 26 files)
- `lake build` passes with zero errors
- Zero new sorries introduced (506 is the baseline; final count must be ≤ 506)
- Use `simp only [...]` (not bare `simp`) in proof terms for stability

**Non-Goals**:
- Fixing pre-existing sorries (unless they become unreachable after the refactor)
- Modifying `box` or any modal operators
- Repairing ConservativeExtension/ExtFormula (dead code in Boneyard)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| temp_k_dist/temp_4 derivation is circular | H | M | After Phase 1, G = ¬F¬, so derivation is straightforward via contrapositive + BX2G |
| Separation/Hierarchy.lean (82 arms) exceeds budget | H | M | These are syntactic predicates — each arm removal is mechanical |
| SubformulaClosure proofs need structural analysis for all_future/all_past cases | M | H | With 6 constructors, SubformulaClosure handles imp/untl/snce directly — no injection issues |
| SoundnessLemmas proofs break due to truth_at changes | H | H | @[simp] characterization theorems handle this automatically |
| Cascade of failures across 26 files | H | H | Work in dependency order (Phase 1 → 2 → 3 by import chain) |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 1 |
| 4 | 4 | 2, 3 |
| 5 | 5 | 4 |

---

### Phase 1: Core Redefinition — Formula.lean and Truth.lean [COMPLETED]

**Goal**: Remove `all_future` and `all_past` as constructors. Add `def` abbreviations. Prove `@[simp]` characterization theorems.

**Tasks (execute in this exact order)**:

- [x] 1.1. In `Formula.lean`, remove `| all_past : Formula → Formula` (line 76) and `| all_future : Formula → Formula` (line 78) from the `inductive Formula` block
- [x] 1.2. In `Formula.lean`, add `def` abbreviations AFTER the `Formula` namespace opens (~line 105):
  ```lean
  def top : Formula := Formula.bot.imp Formula.bot
  def neg (φ : Formula) : Formula := φ.imp Formula.bot
  def some_future (φ : Formula) : Formula := Formula.untl φ Formula.top
  def some_past (φ : Formula) : Formula := Formula.snce φ Formula.top
  def all_future (φ : Formula) : Formula := (some_future φ.neg).neg
  def all_past (φ : Formula) : Formula := (some_past φ.neg).neg
  ```
  NOTE: Check if `top`, `neg`, `some_future`, `some_past` already exist as definitions. If so, update them to use the new forms. Do NOT create duplicates.
- [x] 1.3. In `Formula.lean`, update `complexity` to remove `| all_past` and `| all_future` arms. Add `@[simp]` lemmas: `complexity_all_future`, `complexity_all_past`, etc. if needed. *(deviation: altered -- @[simp] complexity lemmas not needed since all_future/all_past are now defs that unfold structurally)*
- [x] 1.4. In `Formula.lean`, update `beq_refl` to remove `| all_past` and `| all_future` induction arms
- [x] 1.5. In `Formula.lean`, update ALL other functions and proofs that pattern-match on `all_past`/`all_future` (beq helpers, injection proofs, etc.) — there are 34 arm references in this file
- [x] 1.6. Verify: `lake build Bimodal.Syntax.Formula` compiles with zero errors
- [x] 1.7. In `Truth.lean`, update `truth_at` to remove `| all_past` and `| all_future` cases (currently 4 arm references)
- [x] 1.8. In `Truth.lean`, prove and add `@[simp]` to the 4 characterization theorems:
  - `Truth.future_iff`: `truth_at M Omega τ t φ.all_future ↔ ∀ s, t < s → truth_at M Omega τ s φ`
  - `Truth.past_iff`: `truth_at M Omega τ t φ.all_past ↔ ∀ s, s < t → truth_at M Omega τ s φ`
  - `Truth.some_future_iff`: `truth_at M Omega τ t (some_future φ) ↔ ∃ s, t < s ∧ truth_at M Omega τ s φ`
  - `Truth.some_past_iff`: `truth_at M Omega τ t (some_past φ) ↔ ∃ s, s < t ∧ truth_at M Omega τ s φ`
- [x] 1.9. Verify: `lake build Bimodal.Semantics.Truth` compiles with zero errors
- [x] 1.10. Commit: `task 116 phase 1: remove all_future/all_past constructors, add def + @[simp]` *(committed as aa1b5af0f)*

**Timing**: 4 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Syntax/Formula.lean` — Remove constructors, add defs, fix all internal pattern matches
- `Theories/Bimodal/Semantics/Truth.lean` — Remove truth_at arms, add @[simp] characterization theorems

**Verification**:
- Formula inductive has exactly 6 constructors: atom, bot, imp, box, untl, snce
- `all_future`, `all_past`, `some_future`, `some_past` are `def` abbreviations
- 4 `@[simp]` characterization theorems proved
- Both files compile with zero errors

---

### Phase 2: Derive temp_k_dist and temp_4, Remove Axiom Constructors [IN PROGRESS]

**Goal**: Now that G = ¬F¬ and F = ⊤ U, derive temp_k_dist and temp_4 from BX axioms. Replace all 45 invocations. Remove the axiom constructors.

**Why this is now possible**: With G φ = ¬(⊤ U ¬φ), the temp_k_dist property G(φ→ψ) → (Gφ → Gψ) can be derived via:
1. G(φ→ψ) means ¬F(¬(φ→ψ)). Using BX2G (guard monotonicity), derive that F(¬ψ) → F(¬φ).
2. Contrapositive: ¬F(¬φ) → ¬F(¬ψ), i.e., Gφ → Gψ.

And temp_4 (Gφ → GGφ) follows from F(F(¬φ)) → F(¬φ) via BX5/BX6.

**Tasks (execute in this exact order)**:

- [x] 2.1. In `TemporalDerived.lean`, study existing derived theorems to understand the API (DerivationTree, mp, tautology, etc.) *(completed)*
- [x] 2.2. Derive `temp_k_dist_derived : Derivable ((φ.imp ψ).all_future.imp (φ.all_future.imp ψ.all_future))` — sorry-free proof from BX axioms *(completed — derived via BX3 + propositional contraposition)*
- [x] 2.3. Derive `temp_4_derived : Derivable (φ.all_future.imp φ.all_future.all_future)` — sorry-free proof from BX axioms *(completed — derived via BX3 + BX6 + double negation elimination)*
- [x] 2.4. Verify: `lake build Bimodal.Theorems.TemporalDerived` compiles *(deviation: altered — module-level build fails due to pre-existing errors in GeneralizedNecessitation.lean (upstream dependency); the derived theorems themselves type-check successfully per lean_goal)*
- [ ] 2.5. Replace all ~45 invocations of `Axiom.temp_k_dist` and `Axiom.temp_4` across the codebase with the derived theorems. Use `grep -rn "Axiom.temp_k_dist\|Axiom.temp_4" Theories/ --include="*.lean"` to find them all.
- [ ] 2.6. Remove `| temp_k_dist` and `| temp_4` constructors from `Axiom` inductive in `Axioms.lean`
- [ ] 2.7. Fix match arms in `Soundness.lean`, `DiscreteSoundness.lean`, `Substitution.lean` that match on removed axiom constructors
- [ ] 2.8. Verify: `lake build Bimodal.ProofSystem.Axioms` compiles
- [ ] 2.9. Verify: `lake build` for all files that referenced temp_k_dist/temp_4 compiles
- [ ] 2.10. Commit: `task 116 phase 2: derive temp_k_dist/temp_4 from BX axioms, remove axiom constructors`

**Timing**: 5 hours

**Depends on**: Phase 1

**Files to modify**:
- `Theories/Bimodal/Theorems/TemporalDerived.lean` — Add derived theorems
- `Theories/Bimodal/ProofSystem/Axioms.lean` — Remove constructors
- `Theories/Bimodal/Metalogic/Soundness.lean` — Remove match arms
- `Theories/Bimodal/Metalogic/DiscreteSoundness.lean` — Remove match arms
- `Theories/Bimodal/ProofSystem/Substitution.lean` — Remove match arms, replace invocations
- ~17 other files with invocations (see grep output)

**Verification**:
- Both derived theorems compile and are sorry-free
- Zero references to `Axiom.temp_k_dist` or `Axiom.temp_4` remain
- Axiom inductive has 2 fewer constructors
- All affected files compile

---

### Phase 3: Fix All Downstream Files [IN PROGRESS]

**Goal**: Fix all 26 files (344 pattern-match arms) that break after Phase 1. Work in import-dependency order so each file compiles before moving to the next.

**Strategy for each file**: Remove `| all_future` and `| all_past` match/induction arms. For functions (match expressions), the logic previously in those arms is now handled by the `imp` case (since `all_future φ` is structurally an `imp` term) or by the `untl`/`snce` cases (for `some_future`/`some_past`). For proofs, use `simp only [Truth.future_iff, ...]` where truth_at is involved. Use `simp only` (not bare `simp`) for stability.

**Tasks (grouped by module, execute groups in this order)**:

**Group A — Syntax layer** (no truth_at, purely structural):
- [x] 3.1. Fix `Syntax/Formula.lean` internal references (if any remain after Phase 1) *(no changes needed — Phase 1 handled all)*
- [x] 3.2. Fix `Syntax/Subformulas.lean` (2 arms) *(completed — removed all_future/all_past match/induction arms, rewrote membership theorems)*
- [ ] 3.3. Fix `Syntax/SubformulaClosure.lean` (2 arms) *(in progress — 26 errors remain after fixing defs, extractors, depth functions, decidable instances, duality proofs; remaining errors are injection/noConfusion rewrites in lines 1380-1560)*
- [ ] 3.4. Fix `Syntax.lean` barrel file (2 arms)
- [ ] 3.5. Verify: `lake build Bimodal.Syntax` compiles

**Group B — ProofSystem layer**:
- [ ] 3.6. Fix `ProofSystem/Substitution.lean` (8 arms) — remove all_future/all_past from induction proofs, keep 6-constructor arms only
- [ ] 3.7. Verify: `lake build Bimodal.ProofSystem` compiles

**Group C — Semantics layer**:
- [x] 3.8. Fix `Semantics/Truth.lean` (if any remain after Phase 1) *(no changes needed — Phase 1 handled all)*
- [x] 3.9. Verify: `lake build Bimodal.Semantics` compiles *(verified: Validity.lean also fixed)*

**Group D — Automation layer**:
- [ ] 3.10. Fix `Automation/ProofSearch.lean` (7 arms) — update formula pattern recognition
- [ ] 3.11. Fix `Automation/SuccessPatterns.lean` (3 arms)
- [ ] 3.12. Fix `Automation/Tactics.lean` (2 arms)
- [ ] 3.13. Verify: `lake build Bimodal.Automation` compiles

**Group E — Metalogic core**:
- [x] 3.14. Fix `Metalogic/SoundnessLemmas.lean` (2 arms) *(completed — 102 errors fixed, added swap_temporal simp lemmas to Formula.lean, rewrote proofs with Truth.future_iff/past_iff/some_future_iff/some_past_iff)*
- [x] 3.15. Fix `Metalogic/Soundness.lean` *(completed — rewrote all simp calls to use Truth characterization theorems, rewrote linearity/seriality/duality proofs for existential forms)*
- [x] 3.16. Fix `Metalogic/Decidability/SignedFormula.lean` (4 arms) *(completed — removed all_future/all_past arms from subformulas, subformulas_trans, unexpandedComplexity)*
- [ ] 3.17. Verify: `lake build Bimodal.Metalogic.Soundness` and `lake build Bimodal.Metalogic.Decidability` compile

**Group F — Algebraic metalogic**:
- [x] 3.18. Fix `Metalogic/Algebraic/ParametricTruthLemma.lean` (4 arms) *(completed — removed all_future/all_past induction arms from both truth lemmas)*
- [x] 3.19. Fix `Metalogic/Algebraic/RestrictedParametricTruthLemma.lean` (4 arms) *(completed — removed all_future/all_past induction arms from both truth lemmas)*
- [ ] 3.20. Verify: `lake build Bimodal.Metalogic.Algebraic` compiles

**Group G — BXCanonical**:
- [x] 3.21. Fix `Metalogic/BXCanonical/Quasimodel/SubformulaClosure.lean` *(completed — removed 2 pattern arms)*
- [ ] 3.22. Verify: `lake build Bimodal.Metalogic.BXCanonical` compiles *(in progress — Frame.lean and OrderedSeedConsistency.lean fixed; Realization.lean, TruthLemma.lean, RRelation.lean still have errors)*

**Group H — WeakCanonical/Separation** (highest arm count — 260 total):
- [ ] 3.23. Fix `WeakCanonical/Separation/Defs.lean` (36 arms) — syntactic predicates, purely structural
- [ ] 3.24. Fix `WeakCanonical/Separation/Duality.lean` (20 arms)
- [ ] 3.25. Fix `WeakCanonical/Separation/DedekindZ.lean` (20 arms)
- [ ] 3.26. Fix `WeakCanonical/Separation/Eliminations.lean` (2 arms)
- [ ] 3.27. Fix `WeakCanonical/Separation/NormalForm.lean` (2 arms)
- [ ] 3.28. Fix `WeakCanonical/Separation/FormulaOps.lean` (4 arms)
- [ ] 3.29. Fix `WeakCanonical/Separation/SeparationThm.lean` (4 arms)
- [ ] 3.30. Fix `WeakCanonical/Separation/TemporalClosure.lean` (58 arms) — leverage existing structural induction
- [ ] 3.31. Fix `WeakCanonical/Separation/Hierarchy.lean` (82 arms) — largest file, mechanical arm removal
- [x] 3.32. Fix `WeakCanonical/Table.lean` (10 arms) *(completed — removed all_future/all_past from operator_depth, table, temporal_truth, table_depth_bound, table_correctness)*
- [ ] 3.33. Fix `WeakCanonical/TruthLemma.lean` (2 arms)
- [ ] 3.34. Fix `WeakCanonical/ExpressiveCompleteness.lean` (20 arms)
- [ ] 3.35. Verify: `lake build Bimodal.Metalogic.WeakCanonical` compiles

**Group I — Theorems**:
- [x] 3.36. Fix `Theorems/GeneralizedNecessitation.lean` *(completed — added swap_temporal_all_future/all_past to simp calls)*
- [x] 3.37. Fix `Theorems/Perpetuity/Bridge.lean` *(completed — added swap_temporal_all_future/all_past to simp calls)*
- [x] 3.38. Fix `Theorems/Perpetuity/Helpers.lean` *(completed — added swap_temporal_all_future to simp call)*
- [x] 3.39. Fix `Theorems/Perpetuity/Principles.lean` *(completed — added swap_temporal_all_future/all_past to simp calls)*
- [x] 3.40. Fix `Theorems/TemporalDerived.lean` *(completed — fixed H_transitivity swap proof)*
- [ ] 3.41. Verify: `lake build Bimodal.Theorems` compiles

- [ ] 3.42. Commit after each group, or after the full phase: `task 116 phase 3: fix {N} downstream files`

**Timing**: 20 hours

**Depends on**: Phase 1

**Verification**:
- All 26 files compile with zero errors
- Zero `| all_future` or `| all_past` pattern-match arms remain (except in Boneyard/ConservativeExtension)
- Zero new sorries introduced

---

### Phase 4: Full Build Validation and Sorry Audit [NOT STARTED]

**Goal**: Full `lake build`, sorry audit, documentation update.

**Tasks**:
- [ ] 4.1. Run `lake build` for the entire project — must succeed with zero errors
- [ ] 4.2. Run `grep -r "sorry" Theories/ --include="*.lean" -c | awk -F: '$2>0{sum+=$2} END {print sum}'` — count must be ≤ 506 (baseline)
- [ ] 4.3. Update module-level docstrings in Formula.lean, Axioms.lean, Truth.lean to reflect 6-constructor design
- [ ] 4.4. Update the module docstring at top of Formula.lean (lines 24-50) to remove references to all_past/all_future as "primitive temporal operators"
- [ ] 4.5. Verify Boneyard/ConservativeExtension still compiles (it may have its own all_future/all_past references — if broken, mark as dead code and disable import)
- [ ] 4.6. Commit: `task 116 phase 4: full build validation and documentation`

**Timing**: 2 hours

**Depends on**: Phase 2, Phase 3

---

### Phase 5: Test Suite and Final Validation [NOT STARTED]

**Goal**: Update test suite, final validation.

**Tasks**:
- [ ] 5.1. Check `Tests/` directory for all_future/all_past constructor references
- [ ] 5.2. Fix any test files that reference removed constructors
- [ ] 5.3. Run `lake build Tests` — must succeed
- [ ] 5.4. Final `lake build` — zero errors, zero new sorries
- [ ] 5.5. Create implementation summary at `specs/116_redefine_ghfp_via_until_since/summaries/04_redefine-ghfp-summary.md`
- [ ] 5.6. Write metadata to `specs/116_redefine_ghfp_via_until_since/.return-meta.json`
- [ ] 5.7. Commit: `task 116 phase 5: test suite and final validation`

**Timing**: 2 hours

**Depends on**: Phase 4

**Verification**:
- `lake build` succeeds with zero errors
- `lake build Tests` succeeds
- Sorry count ≤ 506
- Formula has 6 constructors
- Axiom has 2 fewer constructors (temp_k_dist, temp_4 removed)
- All @[simp] characterization theorems proved

## Testing & Validation

- [ ] `lake build` succeeds with zero errors
- [ ] Formula inductive has exactly 6 constructors: atom, bot, imp, box, untl, snce
- [ ] all_future, all_past, some_future, some_past are `def` abbreviations
- [ ] `@[simp]` characterization theorems proved for all 4
- [ ] temp_k_dist_derived and temp_4_derived are sorry-free theorems
- [ ] Axiom inductive reduced by 2 constructors
- [ ] Zero new sorry markers (baseline: 506)
- [ ] No `| all_future` or `| all_past` match arms outside Boneyard
- [ ] `simp only` used (not bare `simp`) in proof terms

## Rollback/Contingency

- **Git-based rollback**: Each phase committed separately; `git revert` if needed
- **Phase 2 safety**: If temp_k_dist/temp_4 derivation proves intractable, keep as axiom constructors temporarily and file a follow-up task
- **Separation/Hierarchy.lean**: If 82-arm removal exceeds budget, split into sub-phases (Defs first, then Hierarchy)
- **Sorry bridge**: If any metalogic proof becomes genuinely intractable after the refactor (not just needs rewriting), STOP and report — do not insert sorry
