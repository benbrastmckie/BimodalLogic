# Implementation Plan: Deduction Theorem Tactic

- **Task**: 189 - Deduction theorem tactic
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Dependencies**: None (tasks 185/192/193 are related but non-blocking)
- **Research Inputs**: specs/189_deduction_theorem_tactic/reports/02_deduction-tactic-research.md (authoritative; supersedes reports/01_deduction-theorem-seed.md)
- **Artifacts**: plans/02_deduction-tactic-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Add a `deduction` tactic family that applies the existing frame-class-polymorphic
`deduction_theorem` (Metalogic/Core/DeductionTheorem.lean:320) to derivability goals
`Γ ⊢[fc] A → B`, transforming them into `(A :: Γ) ⊢[fc] B`. The tactic is built on
`MVarId.apply` — never a syntactic `Formula.imp` match — because `apply` unifies through
plain `def`s, which is what makes goals stated as `Γ ⊢ ψ.neg` (defeq to `ψ.imp bot`, the
dominant call-site pattern) work for free. Supporting deliverables: a computable
`deduction_converse`, a Prop-level `Derivable.deduction` corollary, and example-based tests.
Definition of done: all three phases build with `lake build`, zero sorries, tests demonstrate
the `.neg` defeq case and frame-class polymorphism.

### Research Integration

Key findings honored from report 02:

1. **`MVarId.apply`, not manual Expr assembly** — unification (default transparency) sees
   through `Formula.neg`; a syntactic match on the `Formula.imp` constructor would reject the
   dominant call-site. This is the load-bearing design decision.
2. **Template**: copy `mkOperatorKTactic` (Automation/Tactics/Helpers.lean:311-329) —
   3-app goal match `.app (.app (.app (.const ``DerivationTree _) fc) ctx) fml`, then
   `goal.apply (mkConst ...)`, `replaceMainGoal newGoals`.
3. **No new imports** — `deduction_theorem` is already transitively imported by the tactic
   layer via Commands.lean → Helpers.lean → GeneralizedNecessitation → DeductionTheorem.
4. **`deduction_with_mem` is private** (DeductionTheorem.lean:211) — do NOT call it cross-file
   and do NOT de-privatize; head-position introduction only (matches all 220 current usages).
5. **Noncomputability**: `deduction_theorem` is noncomputable, so defs/examples closed by the
   tactic must be `noncomputable` — established codebase practice
   (`modal_k_tactic`, `noncomputable example` precedent at TacticsTest.lean:365). Document in
   the tactic docstring. `Derivable.deduction` is the Prop-level escape hatch.
6. **Out of scope confirmations**: no `modal_search` integration (task 192), no call-site
   refactoring (task 193), no "A anywhere in Γ" variant.

### Prior Plan Reference

Plan 01 (seed-based) predates the frame-class generalization; its Phase-1 sketch (syntactic
`Formula.imp` match, 2-app goal Expr) is invalidated by report 02 corrections. Retained
lessons: naming `deduction`/`undischarge`, example-based test approach.

### Roadmap Alignment

No roadmap context provided for this run.

## Goals & Non-Goals

**Goals**:
- `deduction` tactic: goal `Γ ⊢[fc] A → B` (incl. `.neg`-stated goals) becomes `(A :: Γ) ⊢[fc] B`
- `deduction n` iterated form (innermost hypothesis ends at context head — documented)
- `undischarge h` macro: `exact deduction_theorem _ _ _ h` in the hypothesis direction
- Computable `deduction_converse` (weakening + modus ponens + assumption)
- Prop-level `Derivable.deduction` corollary
- Tests covering: basic, iterated, negation-defeq (load-bearing), non-Base frame class, converse round-trip
- Zero sorries; `lake build` green at every phase boundary

**Non-Goals**:
- Refactoring any of the 220 existing `deduction_theorem` call sites (task 193)
- Wiring `deduction` into `modal_search` strategy list (task 192 follow-up note only)
- De-privatizing `deduction_with_mem` / supporting A in non-head position
- A computable `deduction_theorem` variant

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `goal.apply` fails to unify through `Formula.neg` | M | L | Plain `def` at default transparency should unify; Phase 3 negation test verifies early. Fallback: `unfold Formula.neg` preprocessing inside the tactic before `apply`. |
| `apply` error message unhelpful on non-implication goals | L | M | Wrap `goal.apply` in `try/catch`; rethrow domain-specific message ("deduction: goal formula is not an implication"). |
| Tactic file not visible downstream (root import) | M | L | Phase 2 checklist item: import Deduction.lean from Commands.lean and mirror how `Automation.Tactics.Commands` is rooted in the library root import file. |
| Universe/level args on `mkConst` | L | L | `Formula`/`Context` are `Type 0`; empty level list, exactly as `mkOperatorKTactic` already does. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Fully sequential; each phase is sized to a single lean-implementation-agent run with a
`lake build` gate.

### Phase 1: Core lemmas in DeductionTheorem.lean [NOT STARTED]

**Goal**: Add the computable converse lemma and the Prop-level corollary next to
`deduction_theorem` in `Theories/Bimodal/Metalogic/Core/DeductionTheorem.lean`.

**Tasks**:
- [ ] Add computable `def deduction_converse {fc : FrameClass} (Γ : Context) (A B : Formula) (h : Γ ⊢[fc] A.imp B) : (A :: Γ) ⊢[fc] B` per report 02 sketch: `DerivationTree.modus_ponens (A :: Γ) A B (DerivationTree.weakening Γ (A :: Γ) (A.imp B) h (List.subset_cons_of_subset A (List.Subset.refl Γ))) (DerivationTree.assumption (A :: Γ) A (List.Mem.head _))` — constructor arg order `modus_ponens Γ φ ψ h_imp h_arg` verified against `deduction_mp` (DeductionTheorem.lean:188-202)
- [ ] Verify `deduction_converse` is NOT marked `noncomputable` (it must stay computable)
- [ ] Add `theorem Derivable.deduction {fc : FrameClass} {Γ : Context} {A B : Formula} (h : Derivable fc (A :: Γ) B) : Derivable fc Γ (A.imp B) := h.elim fun d => ⟨deduction_theorem Γ A B d⟩` (must live in this file, not ProofSystem/Derivable.lean — wrong import direction)
- [ ] Docstrings on both declarations (converse states it is computable; corollary states it is the Prop-level entry point avoiding `noncomputable`)
- [ ] Gate: `lake build` green, zero sorries, no new warnings in the file

**Timing**: 45 minutes

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/Core/DeductionTheorem.lean` - add ~30 lines (2 declarations + docstrings)

**Verification**:
- `lake build` exits 0
- `grep -c sorry` unchanged for the file (zero new)
- `lean_hover_info` or `#check` confirms both signatures with `{fc : FrameClass}` polymorphism

---

### Phase 2: Deduction.lean tactic file + import wiring [NOT STARTED]

**Goal**: Create `Theories/Bimodal/Automation/Tactics/Deduction.lean` providing `deduction`,
`deduction n`, and `undischarge`, wired into the tactic layer's import chain.

**Tasks**:
- [ ] Create `Theories/Bimodal/Automation/Tactics/Deduction.lean` (new file preferred over growing 1032-line Helpers.lean); module docstring documents noncomputability implications for tactic users
- [ ] Implement core `deduction` elab following `mkOperatorKTactic` (Helpers.lean:311-329) verbatim with `deduction_theorem` as the rule constant: match `withReducible <| goal.getType'` against the 3-app pattern `.app (.app (.app (.const ``DerivationTree _) _fc) _ctx) _fml` (guard for a good error message ONLY — no syntactic `Formula.imp` requirement), then `goal.apply (mkConst ``Bimodal.Metalogic.Core.deduction_theorem)` and `replaceMainGoal newGoals`
- [ ] Wrap `goal.apply` in `try/catch`; rethrow as "deduction: goal formula is not an implication" on unification failure; non-DerivationTree goals get "deduction: goal must be a derivability goal `Γ ⊢[fc] A → B`, got {goalType}"
- [ ] Implement `deduction n` via `macro "deduction" n:num : tactic => `(tactic| iterate $n deduction)` (or the `syntax (num)? : tactic` + `elab_rules` pattern from Commands.lean:105-150 if macro/elab overload interaction requires it); docstring documents ordering: `Γ ⊢ A → B → C` after `deduction 2` becomes `B :: A :: Γ ⊢ C` (innermost hypothesis at head)
- [ ] Implement `undischarge` as a ~5-line macro expanding to `exact Bimodal.Metalogic.Core.deduction_theorem _ _ _ h` (hypothesis-direction symmetry)
- [ ] Add `import` of the new module to `Theories/Bimodal/Automation/Tactics/Commands.lean` (line 1 import block); confirm the new file is reachable from the library root import file the same way `Automation.Tactics.Commands` is rooted (add an explicit root entry only if Commands does not already pull it in)
- [ ] Sanity-check in-file: one `noncomputable example` at the bottom of Deduction.lean or via `lean_multi_attempt` exercising `deduction` on `⊢ p.imp (q.imp p)` (kept minimal; real tests are Phase 3)
- [ ] Gate: `lake build` green, zero sorries

**Timing**: 75 minutes

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Automation/Tactics/Deduction.lean` (new) - ~100 lines: elab + 2 macros + docs
- `Theories/Bimodal/Automation/Tactics/Commands.lean` - 1 import line
- Library root import file - only if needed for downstream visibility (verify, likely no-op)

**Verification**:
- `lake build` exits 0
- `deduction` closes/transforms a smoke-test goal inside the new file
- No new imports beyond `Bimodal.Automation.Tactics.Helpers`-level scope (report: none needed)

---

### Phase 3: Tests in TacticsTest.lean [NOT STARTED]

**Goal**: Add an example-based test section exercising all tactic forms, with the
negation-defeq case as the load-bearing test.

**Tasks**:
- [ ] Add a "Deduction tactic" section to `Tests/BimodalTest/Automation/TacticsTest.lean` following the `noncomputable example` precedent (~line 365)
- [ ] Basic: `noncomputable example (p q : Formula) : ⊢ p.imp (q.imp p) := by deduction; deduction; ...` (finish with assumption-style closing)
- [ ] Iterated: same theorem via `deduction 2`, verifying context ordering `q :: p :: []`
- [ ] **Negation defeq (load-bearing)**: `noncomputable example (p : Formula) (h : [p] ⊢ Formula.bot) : ⊢ p.neg := by deduction; exact h` — verifies `apply` unifies through `Formula.neg`; if this fails, apply the Phase-2 fallback (`unfold Formula.neg` preprocessing) and re-gate
- [ ] Non-Base frame class: a goal at `⊢[fc]` for an explicit non-`Base` `fc` — verifies fc-polymorphism
- [ ] `undischarge` example (hypothesis direction)
- [ ] `deduction_converse` round-trip example — plain computable `example`, no `noncomputable`
- [ ] Failure-mode documentation: commented example (or `#guard_msgs` if the harness supports it cleanly) showing the error message on a non-implication goal
- [ ] Gate: `lake build` green (including test target), zero sorries

**Timing**: 60 minutes

**Depends on**: 2

**Files to modify**:
- `Tests/BimodalTest/Automation/TacticsTest.lean` - ~60-100 lines test section

**Verification**:
- `lake build` exits 0 with tests compiled
- All examples elaborate (examples ARE the tests; compilation is the pass criterion)
- Negation-defeq example compiles without any `unfold`/`show` at the call site

## Testing & Validation

- [ ] `lake build` green at each of the three phase gates
- [ ] Zero sorries across all touched files (`grep -rn "sorry"` on the 3-4 modified files)
- [ ] Negation-defeq test compiles with no call-site normalization
- [ ] Frame-class polymorphism test compiles at a non-`Base` frame class
- [ ] `deduction_converse` remains computable (no `noncomputable` keyword)
- [ ] Error path manually confirmed once via `lean_multi_attempt` on a non-implication goal (message contains "deduction:")

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Core/DeductionTheorem.lean` (modified, +~30 lines)
- `Theories/Bimodal/Automation/Tactics/Deduction.lean` (new, ~100 lines)
- `Theories/Bimodal/Automation/Tactics/Commands.lean` (modified, +1 import)
- `Tests/BimodalTest/Automation/TacticsTest.lean` (modified, +~60-100 lines)
- `specs/189_deduction_theorem_tactic/plans/02_deduction-tactic-plan.md` (this file)
- `specs/189_deduction_theorem_tactic/summaries/02_deduction-tactic-summary.md` (at implementation completion)

## Rollback/Contingency

- Phases 1-3 are additive-only (one new file, three appended sections); rollback is
  `git revert` of the phase commit(s) or deletion of Deduction.lean plus the single import
  line — no existing declaration is modified, so no call site can break.
- If the negation-defeq unification unexpectedly fails even with the `unfold Formula.neg`
  fallback, ship `deduction` scoped to syntactic implications, document the limitation in the
  docstring, and note the residual for task 192/193 follow-up; Phases 1 deliverables remain
  valid regardless.
