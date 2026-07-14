# Research Report: Deduction Theorem Tactic

**Task**: #189 — Deduction theorem tactic (lean4)
**Date**: 2026-07-14
**Session**: sess_1784042334_6ccc8d
**Supersedes/extends**: `reports/01_deduction-theorem-seed.md` (seed, 2026-05-22)

## Summary

The codebase has a fully-proven, frame-class-polymorphic `deduction_theorem` and a mature
custom-tactic layer under `Theories/Bimodal/Automation/Tactics/` that already demonstrates
every metaprogramming pattern the new tactic needs. The recommended implementation is a small
`deduction` tactic built on `MVarId.apply` (not manual `mkAppM` Expr assembly, as the seed
proposed — see "Corrections to the seed" below), plus one new computable converse lemma
(`deduction_converse`), an optional iterated form, and tests. Estimated total: **~150-250 new
lines across 3 files**, no new imports needed at the tactic site. Zero sorries expected; all
building blocks are proven.

## Corrections to the Seed Report (verified against current source)

The seed (2026-05-22) predates the frame-class generalization. Verified current facts:

1. **Signature now carries a frame class.**
   `Theories/Bimodal/Metalogic/Core/DeductionTheorem.lean:320`:
   ```lean
   noncomputable def deduction_theorem {fc : FrameClass} (Γ : Context) (A B : Formula)
       (h : (A :: Γ) ⊢[fc] B) : Γ ⊢[fc] A.imp B
   ```
   (Seed said line 336 with no `fc`.) Namespace: `Bimodal.Metalogic.Core`.

2. **`DerivationTree` is a `Type`-valued inductive with `fc` as the first explicit parameter**
   (`ProofSystem/Derivation.lean:85`): `inductive DerivationTree (fc : FrameClass) : Context → Formula → Type`.
   Notation (`Derivation.lean:315-328`): `Γ ⊢[fc] φ`, `⊢[fc] φ`, and `Γ ⊢ φ` / `⊢ φ`
   defaulting to `FrameClass.Base`. Consequence for the tactic: the goal `Expr` has **three**
   applications, `.app (.app (.app (.const ``DerivationTree _) fc) ctx) formula` — the seed's
   sketched two-application match would never fire. The existing `mkOperatorKTactic` factory
   (`Automation/Tactics/Helpers.lean:311-329`) already uses the correct 3-app pattern.

3. **`deduction_with_mem` is `private`** (`DeductionTheorem.lean:211`). A tactic cannot call it
   from another file. If the "A anywhere in Γ" variant is wanted, either de-privatize it or (
   simpler) scope the tactic to head-position introduction only (matches all 220 current usages).

4. **Seed's Phase-1 sketch would reject the dominant use case.** `Formula.neg φ` is a plain
   `def` equal to `φ.imp bot` (`Syntax/Formula.lean:115`). A strict syntactic match on the
   `Formula.imp` constructor fails on goals stated as `Γ ⊢ ψ.neg` — which is exactly the
   dominant call-site pattern (negation-via-contradiction in `MaximalConsistent.lean`,
   `RestrictedMCS/Basic.lean`, etc.). Using `MVarId.apply` instead unifies up to reducible/default
   transparency, so `.neg` goals work for free. This is the single most important design decision.

5. **Usage scale**: 220 `deduction_theorem` occurrences across `Theories/` (defs + call sites),
   spread over ~23 files including `Metalogic/Core/`, `Metalogic/Algebraic/`,
   `Metalogic/BXCanonical/`, and `Metalogic/WeakCanonical/`. Refactoring call sites is task 193's
   job, not this task's.

## Existing Infrastructure (what the implementation builds on)

### Tactic layer — `Theories/Bimodal/Automation/Tactics/`

| Asset | Location | Relevance |
|---|---|---|
| `mkOperatorKTactic` factory | `Helpers.lean:311-329` | **The template.** Matches goal `DerivationTree fc Γ φ`, calls `goal.apply (mkConst ruleConst)`, `replaceMainGoal newGoals`. `deduction` is the same shape with `deduction_theorem` as the rule constant. |
| `modal_k_tactic` / `temporal_k_tactic` | `Helpers.lean:357,377` | Proof that `goal.apply` on a **noncomputable** rule (`generalized_modal_k` is noncomputable) works fine inside a tactic. |
| `modal_search` + `SearchConfig` | `Commands.lean:105-160` | `syntax`/`elab_rules` pattern for optional numeric/named parameters — reusable for `deduction n`. |
| `apply_axiom`, `assumption_search` | `Helpers.lean` | More `elab "..." : tactic` precedents. |
| Import chain | `Commands.lean:1` → `Helpers.lean` → `Bimodal.Theorems.GeneralizedNecessitation` → `Bimodal.Metalogic.Core.DeductionTheorem` | `deduction_theorem` is **already transitively imported** by the tactic files. No new imports needed. |

### Proof-system layer

- `DerivationTree.weakening Γ Δ φ d h_sub` and `DerivationTree.assumption Γ φ h_mem`
  (`ProofSystem/Derivation.lean`) — everything needed for the (computable) converse lemma.
- `weakenCons` (`Theorems/ContextualProofs.lean:54`, private, `.Base`-only) shows the exact
  weakening incantation: `List.subset_cons_of_subset A (List.Subset.refl Γ)`.
- `Derivable fc Γ φ := Nonempty (DerivationTree fc Γ φ)` (`ProofSystem/Derivable.lean:62`) — a
  Prop-level wrapper with rule lemmas (`Derivable.mp`, `.weaken`, ...) but **no deduction
  theorem corollary yet**. Adding one is a two-line optional deliverable (see Phase 4).

### Test layer

- `Tests/BimodalTest/Automation/TacticsTest.lean` — example-based tactic tests; already contains
  `noncomputable example` precedents (lines ~365-372), which is exactly how tests of the new
  tactic must be written (see Noncomputability below).

## Recommended Implementation

### Phase 1 — Converse lemma `deduction_converse` (computable, ~15 lines)

Missing from the codebase (verified by grep: no `imp_elim`/converse in `DeductionTheorem.lean`).
Add next to `deduction_theorem` in `Metalogic/Core/DeductionTheorem.lean`:

```lean
/-- Converse of the deduction theorem: from `Γ ⊢ A → B` obtain `A :: Γ ⊢ B`.
    Computable: weakening + modus ponens + assumption. -/
def deduction_converse {fc : FrameClass} (Γ : Context) (A B : Formula)
    (h : Γ ⊢[fc] A.imp B) : (A :: Γ) ⊢[fc] B :=
  DerivationTree.modus_ponens (A :: Γ) A B
    (DerivationTree.weakening Γ (A :: Γ) (A.imp B) h
      (List.subset_cons_of_subset A (List.Subset.refl Γ)))
    (DerivationTree.assumption (A :: Γ) A (List.Mem.head _))
```

(Constructor argument order verified against `deduction_mp` at `DeductionTheorem.lean:188-202`:
`modus_ponens Γ φ ψ h_imp h_arg`.) This gives the tactic pair a clean lemma on each side and is
independently useful.

### Phase 2 — `deduction` tactic (~60-80 lines incl. docs)

**Where**: `Automation/Tactics/Helpers.lean` (alongside `mkOperatorKTactic`) or a new
`Automation/Tactics/Deduction.lean` imported by `Commands.lean`. New file preferred: keeps
Helpers.lean (already 1032 lines) from growing, and Commands.lean already imports Helpers.

**Core** (follow `mkOperatorKTactic` verbatim, swapping the rule constant):

```lean
elab "deduction" : tactic => do
  let goal ← getMainGoal
  let goalType ← withReducible <| goal.getType'
  -- Guard for a good error message only; do NOT syntactically require Formula.imp,
  -- because Formula.neg unfolds to imp via unification in `apply`.
  match goalType with
  | .app (.app (.app (.const ``DerivationTree _) _fc) _ctx) _fml =>
    let newGoals ← goal.apply (mkConst ``Bimodal.Metalogic.Core.deduction_theorem)
    replaceMainGoal newGoals
  | _ => throwError "deduction: goal must be a derivability goal `Γ ⊢[fc] A → B`, got {goalType}"
```

Key points:
- `goal.apply` unifies `deduction_theorem`'s conclusion `Γ ⊢[fc] A.imp B` with the goal,
  instantiating `fc Γ A B` by unification (unfolding `Formula.neg`, `Formula.top`-style defs as
  needed) and leaves exactly one subgoal `(A :: Γ) ⊢[fc] B`. This handles the `.neg` case and
  all frame classes with zero extra code.
- If unification fails (goal formula not an implication up to defeq), `apply` throws; wrap in
  `try ... catch` to rethrow a domain-specific message ("deduction: goal formula is not an
  implication").
- `undischarge h` (seed Phase 2) is genuinely just `exact Bimodal.Metalogic.Core.deduction_theorem _ _ _ h`;
  a one-line `macro` suffices, or skip it — its value over plain `exact` is marginal. Recommend
  implementing it as a `macro` for symmetry, cost ~5 lines. Symmetrically, an `intro_hyp h`
  macro for `deduction_converse` can be considered but is optional.

### Phase 3 — Iterated form `deduction n` (~20 lines)

Reuse the `syntax "deduction" (num)? : tactic` + `elab_rules` pattern from
`Commands.lean:105-150`: loop `n` times over the Phase-2 core (a `for _ in [0:n]` in `TacticM`,
or simply `macro "deduction" n:num : tactic => `(tactic| iterate $n deduction)`). Goal
`Γ ⊢ A → B → C` after `deduction 2` becomes `B :: A :: Γ ⊢ C` (note ordering: innermost
hypothesis ends at the head — document this).

### Phase 4 — Optional Prop-level corollary (~10 lines)

In `Metalogic/Core/DeductionTheorem.lean` (cannot live in `ProofSystem/Derivable.lean` — wrong
import direction):

```lean
theorem Derivable.deduction {fc : FrameClass} {Γ : Context} {A B : Formula}
    (h : Derivable fc (A :: Γ) B) : Derivable fc Γ (A.imp B) :=
  h.elim fun d => ⟨deduction_theorem Γ A B d⟩
```

Being Prop-valued, this has **no noncomputability friction at all** and lets `theorem`-level
users avoid `noncomputable def`. Cheap and worth including.

### Phase 5 — Tests (~60-100 lines)

Add a section to `Tests/BimodalTest/Automation/TacticsTest.lean` (or a new
`DeductionTacticTest.lean` registered like the existing test files):

1. `noncomputable example (p q : Formula) : ⊢ p.imp (q.imp p) := by deduction; deduction; ...`
   — basic + iterated.
2. **Negation goal** (the load-bearing case): `noncomputable example (p : Formula) (h : [p] ⊢ Formula.bot) : ⊢ p.neg := by deduction; exact h` — verifies defeq unification through `Formula.neg`.
3. Non-`Base` frame class: goal at `⊢[fc]` for some explicit `fc` — verifies fc-polymorphism.
4. Failure message test (commented, or `#guard_msgs`): `deduction` on a non-implication goal.
5. `deduction_converse` round-trip example (computable `example`, no `noncomputable` needed).

## Noncomputability (seed Question 1 — resolved)

`DerivationTree` is `Type`-valued, so results are `def`s/`example`s, never `theorem`s.
`deduction_theorem` is noncomputable (Classical membership decision), so **any `def` whose body
the tactic completes must be marked `noncomputable`** — same situation as today's explicit
call sites and as `modal_k_tactic` (which applies noncomputable `generalized_modal_k`;
see `Commands.lean:365` comment and `noncomputable example`s in `TacticsTest.lean`). This is
established, accepted practice in this codebase; the tactic docstring should state it. The
Phase-4 `Derivable.deduction` corollary is the escape hatch for Prop-level users. No computable
variant is feasible without decidable Formula equality throughout the recursion — `Formula` does
have `DecidableEq` derivable in principle, but rewriting `deduction_theorem` computably is out
of scope and unnecessary.

## Answers to remaining seed questions

- **Q2 (modal_search integration)**: Do not wire `deduction` into `modal_search`'s strategy list
  in this task. `modal_search` builds explicit `DerivationTree` terms in its own search loop
  (`ProofSearch/Core.lean`); injecting a noncomputable metatheorem changes its output class.
  Leave as a follow-up note for task 192 (master dispatch).
- **Q3 (proof-term size)**: `deduction_theorem` recurses over the derivation at *evaluation*
  level, but as a tactic it contributes a single constant application to the proof term —
  elaboration cost is negligible. Term size is only a concern for `#eval`/extraction, which is
  irrelevant for noncomputable terms.
- **Q4 (A not at head)**: Out of scope. `deduction_with_mem` is `private`; all 220 existing
  usages are head-position. Do not de-privatize in this task.
- **Q5 (naming)**: `deduction` for goal-direction introduction (analogue of `intro`), matching
  the seed and the codebase's `modal_*_tactic` naming culture. Avoid `intro` itself (clashes with
  the core tactic conceptually).

## File targets

| File | Change | Est. lines |
|---|---|---|
| `Theories/Bimodal/Metalogic/Core/DeductionTheorem.lean` | Add `deduction_converse` (def) + `Derivable.deduction` (theorem) | ~30 |
| `Theories/Bimodal/Automation/Tactics/Deduction.lean` (new) | `deduction`, `deduction n`, `undischarge` | ~100 |
| `Theories/Bimodal/Automation/Tactics/Commands.lean` | `import Bimodal.Automation.Tactics.Deduction` (or place in Helpers and skip) | 1 |
| `Tests/BimodalTest/Automation/TacticsTest.lean` | Test section | ~60-100 |

## Risks / open points for the planner

1. **Unification transparency**: `goal.apply` should see through `Formula.neg` (plain `def`,
   default transparency). Verify with the Phase-5 negation test early; if it unexpectedly fails,
   fall back to `unfold Formula.neg` inside the tactic or `delta%`-style preprocessing. Low risk.
2. **Universe/level args**: `mkConst ``...deduction_theorem` needs no level args (`Formula`,
   `Context` are `Type 0`); `mkConst` with empty levels is what `mkOperatorKTactic` already does.
3. **Where the tactic file sits in `Bimodal.lean` root import** — mirror how
   `Automation.Tactics.Commands` is currently rooted so the tactic is available downstream.
4. Task dependency note from seed (task 185/192/193 links) still stands; none block this task.

## References (verified this session)

- `Theories/Bimodal/Metalogic/Core/DeductionTheorem.lean:188` — `deduction_mp`
- `Theories/Bimodal/Metalogic/Core/DeductionTheorem.lean:211` — `deduction_with_mem` (private)
- `Theories/Bimodal/Metalogic/Core/DeductionTheorem.lean:320` — `deduction_theorem`
- `Theories/Bimodal/ProofSystem/Derivation.lean:85,315-328` — `DerivationTree`, notations
- `Theories/Bimodal/ProofSystem/Derivable.lean:62` — Prop-level `Derivable`
- `Theories/Bimodal/Syntax/Formula.lean:115` — `Formula.neg φ = φ.imp bot`
- `Theories/Bimodal/Automation/Tactics/Helpers.lean:311-329` — `mkOperatorKTactic` template
- `Theories/Bimodal/Automation/Tactics/Commands.lean:105-160` — parameterized-tactic syntax pattern
- `Theories/Bimodal/Theorems/ContextualProofs.lean:54` — `weakenCons` incantation
- `Tests/BimodalTest/Automation/TacticsTest.lean:365` — `noncomputable example` test precedent
