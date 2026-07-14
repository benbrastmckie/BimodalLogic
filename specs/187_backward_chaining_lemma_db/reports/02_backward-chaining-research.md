# Research Report: Backward-Chaining Lemma Database (Task 187)

**Task**: #187 — Backward-chaining lemma database (solve_by_elim analogue)
**Date**: 2026-07-14
**Session**: sess_1784042334_6ccc8d
**Supersedes/extends**: `reports/01_lemma-database-seed.md` (seed)
**Toolchain**: Lean v4.27.0-rc1 + Mathlib (packages: aesop, batteries, mathlib present in `.lake/packages/`)

## Executive Summary

The seed report is out of date in one decisive respect: **a static lemma database already
exists**. `tryDerivedMatch` (`Theories/Bimodal/Automation/Tactics/Helpers.lean:650-694`)
hardcodes 26 empty-context derived theorems and is already wired into `searchProof` as
strategy 1b. What is missing is (a) attribute-driven registration, (b) recursive
backward-chaining through lemma premises (current code requires `remainingGoals.isEmpty`
after `apply` — single-shot only), and (c) pre-filtering. All three needed mechanisms ship
in the Lean 4.27 core toolchain (`Lean.LabelAttribute`, `Lean.Meta.Tactic.SolveByElim`,
`Lean.Meta.DiscrTree`) — no Mathlib-specific machinery is required.

Recommended approach: a `register_label_attr`-based `@[tm_lemma]` attribute in a new leaf
module, plus a `tryLemmaMatch` that generalizes `tryDerivedMatch` with recursive subgoal
search (mirroring the existing `tryModusPonens` pattern at Helpers.lean:782).

## 1. Current State (verified against working tree, 2026-07-14)

### 1.1 File layout (seed references are stale)

The seed cites `Tactics.lean:862/507/655`. That file was split:

| Component | Actual location |
|---|---|
| `extractDerivationGoal` | `Automation/Tactics/Helpers.lean:511` |
| `tryAxiomMatch` (42 axiom ctors) | `Helpers.lean:532` |
| `tryDerivedMatch` (26 static lemmas) | `Helpers.lean:650` |
| `tryAssumptionMatch` | `Helpers.lean:706` |
| `tryModusPonens` (recursive, via `searchFn`) | `Helpers.lean:782` |
| `tryModalK` / `tryTemporalK` | `Helpers.lean:878` / `931` |
| `searchProof` (6-strategy pipeline) | `Helpers.lean:994-1029` |
| `modal_search` syntax + `SearchConfig` + `runModalSearch` | `Automation/Tactics/Commands.lean` (~line 104-160) |
| Computable search (IDDFS/best-first, separate system) | `Automation/ProofSearch/Core.lean`, `Strategies.lean` |

### 1.2 What `tryDerivedMatch` already does — and its three gaps

```lean
-- Helpers.lean:684-693 (paraphrased)
for derivedName in derivedExprs do   -- static List Name, 26 entries
  let remainingGoals ← goal.apply (mkConst derivedName)
  if remainingGoals.isEmpty then ... return ()   -- GAP: no recursion into subgoals
```

1. **No chaining**: succeeds only when `apply` closes the goal outright. Inference-rule
   lemmas (`imp_trans : (⊢ A→B) → (⊢ B→C) → ⊢ A→C`, `Combinators.lean:83`) can never fire,
   because their premises become subgoals. Contrast `tryModusPonens` (Helpers.lean:782),
   which takes `searchFn : MVarId → Nat → TacticM Bool` and recurses with `depth - 1` —
   that is the exact template to reuse.
2. **Static list**: adding a theorem means editing `Helpers.lean`, not annotating the
   theorem at its definition site. List drifts from the library (~85+ useful lemmas exist;
   26 registered).
3. **No pre-filter**: every registered lemma is tried by `apply` on every subgoal.
   Tolerable at 26; a concern at 85+ combined with recursion.

### 1.3 FrameClass parameterization (post-seed change that matters)

Goals are `DerivationTree fc Γ φ`; notation `Γ ⊢ φ` fixes `fc = FrameClass.Base`
(`ProofSystem/Derivation.lean:315-330`). Derived theorems are fc-polymorphic
(`identity {fc : FrameClass} : ⊢[fc] A.imp A`, `Combinators.lean:107`), so plain `apply`
unifies `fc`. But `tryAxiomMatch` must discharge frame-class side goals
(`h.minFrameClass ≤ fc`) via `first | trivial | decide` (Helpers.lean:624-626). A
generalized `tryLemmaMatch` must classify non-`DerivationTree` subgoals produced by
`apply` and discharge them the same way (plus `simp` for `φ ∈ Γ` membership goals, as
`tryAssumptionMatch` does at Helpers.lean:720).

### 1.4 Weakening and lift infrastructure

- `DerivationTree.weakening (Γ Δ) (φ) : Γ ⊢[fc] φ → Γ ⊆ Δ → Δ ⊢[fc] φ` — `Derivation.lean:164`
- `DerivationTree.lift {fc₁ fc₂} (h_le : fc₁ ≤ fc₂)` — `Derivation.lean:190`
- Working pattern for "closed theorem into non-empty context" already exists:
  `AesopRules.lean` `axiom_temp_4` builds
  `DerivationTree.weakening [] Γ _ (temp_4_derived φ) (List.nil_subset Γ)`.
  This is the recipe for applying `⊢[fc] φ` lemmas to goals `Γ ⊢[fc] φ` with `Γ ≠ []`.

### 1.5 SearchConfig plumbing is partially dead

`SearchConfig` (Commands.lean) declares `visitLimit` and five weight fields, but
`runModalSearch` passes only `cfg.depth`; a comment confirms "visitLimit and weights not
yet used by searchProof". Expanding the branching factor with a lemma DB makes a visit
counter genuinely needed (see §3.6).

### 1.6 Aesop precedent and a latent doc bug

`AesopRules.lean` tags ~20 rules `@[aesop safe apply]` / `@[aesop safe forward]` /
`@[aesop norm unfold]` — all in the **default** rule set. The module docstring advertises
`aesop (rule_sets [TMLogic])`, but **no `declare_aesop_rule_sets [TMLogic]` exists anywhere
in `Theories/`** (only in `docs/user-guide/tactic-development.md`); the docstring example
would not elaborate. `tm_auto` is documented as deprecated in favor of `modal_search`.
Conclusion: aesop is a precedent for attribute-driven registration but not the recommended
vehicle; also worth a one-line doc fix during implementation.

### 1.7 Theorem inventory (current split layout)

Theorem files were also reorganized since the seed:
`Theorems/Propositional/` → `Core.lean` (15 decls), `Connectives.lean` (14),
`Reasoning.lean` (5); `Theorems/Perpetuity/` → `Principles.lean` (20), `Bridge.lean` (25),
`Helpers.lean` (6); plus `Combinators.lean` (12), `ModalS5.lean` (12), `ModalS4.lean` (4),
`TemporalDerived.lean` (51), `GeneralizedNecessitation.lean` (7), `ContextualProofs.lean`
(68, context-specific). Registration candidates for this task: the fc-polymorphic
empty-context theorems and inference rules (~60-90 declarations); context-specific lemmas
(`ContextualProofs.lean`) are explicitly out of scope (task 188 territory, see §4).

## 2. Available Mechanisms (verified present in toolchain/deps)

| Mechanism | Location | Verdict |
|---|---|---|
| `register_label_attr` macro + `Lean.labelled : Name → CoreM (Array Name)` | Lean core `src/lean/Lean/LabelAttribute.lean:73-95` (v4.27.0-rc1) | **Recommended.** Purpose-built "tag + enumerate" attribute; no env-extension boilerplate. |
| `Lean.Meta.Tactic.SolveByElim` (`SolveByElimConfig`, backtracking via `Lean.Meta.Tactic.Backtrack`) | Lean core `src/lean/Lean/Meta/Tactic/SolveByElim.lean`, `Elab/Tactic/SolveByElim.lean` | Alternative integration path (see §3.7); not recommended as primary. |
| `Lean.Meta.DiscrTree` | Lean core `src/lean/Lean/Meta/DiscrTree.lean` | Available but **overkill** for ≤100 lemmas; head-symbol filter suffices (§3.3). |
| `registerTagAttribute` / `ScopedEnvExtension` | Lean core | Works, but `register_label_attr` is the same thing with the enumeration API already written. |
| Aesop rule sets | `.lake/packages/aesop` | Not recommended: search loop must stay inside `searchProof` for K-rule/frame-class integration. |

No existing custom attribute or environment extension in the project (`grep
registerTagAttribute|EnvExtension|register_` over `Theories/Bimodal/` is empty), so this
task introduces the project's first — keep it minimal.

## 3. Recommended Approach

### 3.1 New leaf module: the attribute

**New file** `Theories/Bimodal/Automation/LemmaDB.lean` (imports **only `Lean`** — this is
load-bearing, see import constraint below):

```lean
import Lean

/-- Registers a derived theorem for `modal_search` backward chaining. -/
register_label_attr tm_lemma
```

**Import constraint**: attributes must be declared in a module *imported by* the modules
that use the tag. Today the dependency direction is `Automation/Tactics/Helpers.lean →
imports → Theorems/*`. Tagging theorems in `Theorems/*` therefore requires
`Theorems/* → imports → Automation.LemmaDB`. Because `LemmaDB.lean` imports only `Lean`,
this creates **no cycle** (verify with `lake build` after wiring; the module has no
project deps). If reviewers object to `Theorems` importing from `Automation`, relocate to
`Theories/Bimodal/LemmaAttr.lean` — contents identical; this is purely a naming/layering
decision.

### 3.2 Generalize `tryDerivedMatch` → `tryLemmaMatch` (Helpers.lean)

Signature mirrors `tryModusPonens` exactly:

```lean
def tryLemmaMatch (goal : MVarId) (_ctx _formula : Expr)
    (searchFn : MVarId → Nat → TacticM Bool) (depth : Nat) : TacticM Bool := do
  let lemmas ← Lean.labelled `tm_lemma   -- Array Name, cheap env lookup
  for lemmaName in lemmas do
    let success ← observing? do
      setGoals [goal]
      let newGoals ← goal.apply (mkConst lemmaName)
      for sub in newGoals do
        let subType ← sub.getType
        if (← extractDerivationGoal subType).isSome then
          unless (← searchFn sub (depth - 1)) do throwError "subgoal failed"
        else
          -- side goals: `φ ∈ Γ` membership, `fc₁ ≤ fc₂` frame-class, etc.
          setGoals [sub]
          evalTactic (← `(tactic| first | trivial | decide | simp))
          unless (← getGoals).isEmpty do throwError "side goal failed"
      setGoals []
    if success.isSome then return true
  return false
```

Notes:
- The `newGoals.isEmpty` fast path of the old `tryDerivedMatch` falls out for free
  (empty loop). Delete `tryDerivedMatch` and its 26-name list after migrating the names
  to `@[tm_lemma]` tags — do not keep two databases.
- `observing?` wrapping is mandatory (established convention in every `try*` helper here)
  to avoid mvar-state corruption on backtrack.
- Instantiate mvars in `subType` (`instantiateMVars`) before `extractDerivationGoal`,
  since `apply` may leave assigned mvars.
- **Noncomputable lemmas are a non-issue**: `tryDerivedMatch` already applies
  `double_negation` etc. (deduction-theorem-based, noncomputable) successfully — term
  construction never evaluates. Seed question 5 is settled by existing evidence.

### 3.3 Pre-filter (seed question 2)

Skip DiscrTree. At ≤100 lemmas, filter by **head constructor of the conclusion formula**:
extract the `Formula` argument from the lemma's return type (`DerivationTree fc ctx φ` —
same `.app` pattern as `extractDerivationGoal`, applied under `forallTelescope` on
`ConstantInfo.type`), take its head constant (`Formula.imp`, `Formula.box`, …), and only
`apply` lemmas whose head matches the goal formula's head or is a variable. Build this
`HashMap Name (Option Name)` once per `modal_search` invocation (compute in
`runModalSearch`, thread through, or recompute in `tryLemmaMatch` — 100 signature reads
per invocation is acceptable for v1; cache in an `IO.Ref` only if benchmarks demand).
DiscrTree remains the documented upgrade path if the DB grows past ~300 entries.

### 3.4 Pipeline position and depth budget (seed questions 3, 4)

Keep in the current 1b slot (after `tryAxiomMatch`, before `tryAssumptionMatch` is also
defensible, but preserving existing ordering minimizes behavioral churn):

```
1  tryAxiomMatch          (cheap, closes leaf goals)
1b tryLemmaMatch          (NEW — gate recursion behind depth > 1; depth-0-cost
                           direct-apply still allowed at depth = 1)
2  tryAssumptionMatch
3  tryModusPonens         (depth > 1)
4  tryModalK / 5 tryTemporalK
```

- **Depth budget**: `depth - 1` per subgoal, uniform — identical to `tryModusPonens`.
  No split-budget scheme; the existing code base has one depth discipline, keep it.
- **Coexist with `tryModusPonens`** (seed Q4): yes. MP chains through *context*
  implications (`φ→ψ ∈ Γ`); `tryLemmaMatch` chains through *library* lemmas. Neither
  subsumes the other. Lemma match runs first (more targeted; MP is the noisier strategy).

### 3.5 Category handling (seed §Phase 4, simplified)

| Category | Handling |
|---|---|
| Closed fc-polymorphic (`⊢[fc] φ`) — e.g. `identity`, `double_negation` | Direct `apply` when goal ctx is `[]`. For `Γ ≠ []`: second attempt wrapped in `DerivationTree.weakening [] Γ _ · (List.nil_subset Γ)` (recipe proven in `AesopRules.axiom_temp_4`). Implement as a fallback branch inside `tryLemmaMatch`. |
| Inference rules (`(⊢ A→B) → (⊢ B→C) → ⊢ A→C`) | Free: `apply` creates `DerivationTree` premise subgoals, recursion handles them. This is the main new capability. |
| Necessitation variants (`(⊢ φ) → ⊢ □φ`) | Free: premise subgoal has ctx `[]`, recursion handles it. |
| Context-specific (`[A∧B] ⊢ A`, `ContextualProofs.lean`) | **Out of scope** — requires context-subset unification = task 188 (weakening-aware search). Do not tag these with `@[tm_lemma]` in this task. |

This collapses the seed's Phase 4 to one small fallback branch plus a tagging policy.

### 3.6 Visit limit (new, recommended in-scope)

Recursion over ~60-90 lemmas multiplies branching. Wire `SearchConfig.visitLimit`
(currently dead) minimally: add an `IO.Ref Nat` counter created in `runModalSearch`,
decremented in `searchProof`'s preamble, aborting at 0. ~15 lines across
`Commands.lean`/`Helpers.lean`; changes `searchProof`'s signature (add the ref, or a
small `SearchState` structure). If the planner prefers zero signature churn, defer to
task 192 (master dispatch) — but flag that `modal_search (depth := 10)` with chaining and
no visit cap can be slow on unprovable goals.

### 3.7 Alternative considered and rejected: core `solve_by_elim` directly

`Lean.Meta.Tactic.SolveByElim.solveByElim` with the tagged-lemma list would give
backtracking for free. Rejected as primary because the search loop must interleave with
DerivationTree-specific strategies (`tryModalK`/`tryTemporalK` context transformations,
axiom frame-class discharge, MP over object-level implications) that solve_by_elim's
apply-only model cannot express, and it would fork depth accounting from
`SearchConfig.depth`. Its `Backtrack` module is still worth reading for `observing?`
discipline. A standalone `tm_solve_by_elim` wrapper could be a cheap bonus later; not
this task.

### 3.8 Rule sets / multiple databases (seed question 6)

Defer. Single `tm_lemma` label now; `register_label_attr tm_lemma_prop` etc. later is
additive and cheap. Task 192 (master dispatch) is the natural home for set selection
syntax like `modal_search +prop`.

### 3.9 Forward chaining (seed question 7)

Out of scope. Forward rules live in the (default-rule-set) aesop path; backward chaining
in `searchProof` is this task. Note the TMLogic doc bug (§1.6) as a drive-by one-line fix.

## 4. Concrete File Targets

| File | Change |
|---|---|
| `Theories/Bimodal/Automation/LemmaDB.lean` | **NEW**: `import Lean` + `register_label_attr tm_lemma` (+ module doc). ~20 lines. |
| `Theories/Bimodal/Automation/Tactics/Helpers.lean` | Add `tryLemmaMatch` (~50 lines, §3.2 + weakening fallback §3.5 + head filter §3.3); replace strategy 1b call in `searchProof` (:1007); delete `tryDerivedMatch` (:650-694); update module docstring (:37-46). |
| `Theories/Bimodal/Theorems/Combinators.lean` | `import Bimodal.Automation.LemmaDB`; tag 12 theorems. |
| `Theories/Bimodal/Theorems/Propositional/{Core,Connectives,Reasoning}.lean` | Import + tag the fc-polymorphic empty-context subset (start with the 12 already in the old static list, expand per §1.7). |
| `Theories/Bimodal/Theorems/{ModalS5,ModalS4,TemporalDerived}.lean` | Import + tag (start with the 14 from the static list). |
| `Theories/Bimodal/Theorems/Perpetuity/{Principles,Bridge}.lean` | Import + tag (`diamond_4`, `modal_5`, `box_to_future`, `box_to_past`, + candidates). |
| `Theories/Bimodal/Theorems/GeneralizedNecessitation.lean` | Import + tag inference-rule forms usable backward (`generalized_modal_k` etc. — note these are already special-cased by `tryModalK`; tagging is optional/duplicative, decide in plan). |
| `Theories/Bimodal/Automation/Tactics/Commands.lean` | Docstring update; optional `visitLimit` wiring (§3.6). |
| `Tests/BimodalTest/Automation/TacticsTest.lean` (+ `EdgeCaseTest.lean`) | New cases: (a) parity with old static list (regression), (b) chaining goals — e.g. a goal closable only by `imp_trans` of two registered lemmas, (c) closed lemma under non-empty context via weakening fallback, (d) depth-exhaustion failure message. |

**Migration invariant**: every goal the old `tryDerivedMatch` closed must still close
(the 26 names become tags; the isEmpty path is subsumed). A regression test enumerating a
few representatives from each tier is the cheapest guard.

## 5. Risks

1. **Import direction** (`Theorems → Automation.LemmaDB`): no cycle since LemmaDB is a
   leaf, but it is a new layering precedent — settle placement in planning (§3.1).
2. **Search blow-up**: mitigated by head-symbol pre-filter + `depth > 1` gate; visit
   limit (§3.6) is the real fix. Benchmark `modal_search` on existing test suite before/
   after (Tests/BimodalTest/Automation/ builds are the proxy).
3. **`apply` unification surprises with fc mvars**: fc-polymorphic lemmas unify fine at
   `FrameClass.Base` goals (existing evidence: static list works), but lemmas pinned at a
   specific frame class would fail silently — tagging policy: only tag fc-polymorphic or
   Base-stated theorems; the `first | trivial | decide` discharger handles `≤` side goals.
4. **`simp` in side-goal discharge can be slow**: keep discharge tactic ordered
   `trivial | decide | simp` so `simp` only runs for membership goals.
5. **Zero-sorry compliance**: pure metaprogramming + annotation task; no new axioms, no
   sorries anticipated. All chaining failures degrade to `modal_search` returning its
   existing "no proof found" error.

## 6. Dependencies and Sequencing

- **Task 185** (complete axiom coverage): completed/archived — dependency satisfied.
- **Tasks 186, 188, 189, 192**: all `not_started`; this task should NOT wait on them.
  Boundary contracts: context-specific lemma application → 188; rule-set selection syntax
  and weight/visit plumbing (if deferred) → 192; computable-search parity
  (`ProofSearch/Core.lean` has no lemma DB — intentionally untouched here) → 186.

## 7. Suggested Phase Structure for Planning

1. **Phase 1**: `LemmaDB.lean` + tag the existing 26 static-list theorems at their
   definition sites + `tryLemmaMatch` with recursion + delete `tryDerivedMatch` +
   regression tests green (`lake build` + Tests). This alone is a shippable increment.
2. **Phase 2**: head-symbol pre-filter + weakening fallback for non-empty contexts +
   chaining tests (`imp_trans` compositions).
3. **Phase 3**: expand tagging across remaining fc-polymorphic theorems (~30-60 more),
   visitLimit wiring, docstring/doc fixes (incl. TMLogic doc bug), benchmark check.

Each phase is one agent-run sized (~100-300 lines).
