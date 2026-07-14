# Implementation Summary: Backward-Chaining Lemma Database (Task 187)

- **Plan**: `specs/187_backward_chaining_lemma_db/plans/02_backward-chaining-plan.md`
- **Status**: implemented (4/4 phases complete)
- **Build**: full `lake build` green (1755 jobs); `BimodalTest.Automation.LemmaDBTest` green (~1.7s)
- **Zero-debt**: 0 new sorries, 0 new axioms, 0 vacuous definitions in touched files
- **Session**: sess_1784042334_6ccc8d

## What was built

Replaced the static 26-name lemma list in `tryDerivedMatch` with an
attribute-driven, backward-chaining lemma database for `modal_search`.

1. **`@[tm_lemma]` attribute** — new leaf module
   `Theories/Bimodal/Automation/LemmaDB.lean` (imports only `Lean`;
   `register_label_attr tm_lemma`). No import cycle: `Theorems/* → LemmaDB`,
   while `Automation/Tactics/* → Theorems/*` reads the DB via `Lean.labelled`.

2. **`tryLemmaMatch` / `tryLemmaMatchCore`** in `Helpers.lean` — replaces the
   deleted `tryDerivedMatch`. Applies `@[tm_lemma]` theorems via `apply` and
   **recurses into remaining `DerivationTree` premises** via `searchFn`
   (backward chaining), discharging `apply` side goals (frame-class `≤`,
   context membership) with `first | trivial | decide | simp`.

3. **Head-symbol pre-filter** (`formulaHead` + `lemmaConclusionHead`) bounds
   branching; **weakening fallback** reduces `Γ ⊢[fc] φ` to `[] ⊢[fc] φ` via
   `DerivationTree.weakening` so closed lemmas apply under non-empty contexts.

4. **`SearchConfig.visitLimit` wired** as a real abort: `IO.Ref Nat` counter
   created per invocation in `runModalSearch`/`runTemporalSearch`/
   `runPropositionalSearch`, decremented in `searchProof`'s preamble, aborts at 0.

5. **Expanded tagging** to 35 theorems (26 migration set + 9 premise-free).
   **Doc fixes**: `Commands.lean` visitLimit docstring; `AesopRules.lean`
   corrected the invalid `aesop (rule_sets [TMLogic])` example (no such rule
   set is declared) to plain `aesop`.

## Migration invariant

All 26 goals formerly closed by the static `tryDerivedMatch` list still close
via `modal_search` — machine-checked by Group 2 of
`Tests/BimodalTest/Automation/LemmaDBTest.lean` (one goal per former entry).

## HOOK FOR TASK 188 (weakening-aware / context-specific search)

Task 188 must hook into **`tryLemmaMatchCore`** — NOT the deleted
`tryDerivedMatch`. Signature:

```
def tryLemmaMatchCore (lemmas : Array Name) (goal : MVarId) (fc _ctx formula : Expr)
    (searchFn : MVarId → Nat → TacticM Bool) (depth : Nat) : TacticM Bool
```

- It is the parameterized core behind `tryLemmaMatch` (which just passes
  `← Lean.labelled `tm_lemma`). 188 can call it with an alternative lemma set
  or wrap/extend the recursion + weakening machinery without touching the
  attribute DB.
- The existing **weakening fallback** lives at the end of `tryLemmaMatchCore`
  (`DerivationTree.weakening [] Γ φ ?d (List.nil_subset Γ)`, guarded by
  `isNilContext` for termination) — 188's context-subset unification can build
  on this exact recipe. `fc` is threaded through for building the weakened
  subgoal.
- `searchProof`'s recursion entry is `searchProof counter` (curried
  `IO.Ref Nat` budget); pass it as `searchFn`.

## Plan Deviations

- **imp_trans intentionally NOT tagged** (Phase 3): it is an inference rule
  with a free middle term `B` that its conclusion `A.imp C` does not determine.
  The greedy, backtrack-free `modal_search` mis-unifies the middle (e.g.
  `identity : A→A` grabs `?B := A`), so tagging adds cost with no reliable
  benefit. Tagging it would be *sound* but *ineffective*. Documented at
  `Combinators.imp_trans`. Backward chaining through such rules would need
  search backtracking over metavariable instantiations (out of scope).
  Consequence: Phase 3 chaining tests (a) imp_trans and (b) necessitation were
  replaced. The genuinely-new recursion capability is demonstrated instead via
  the **determined-premise weakening fallback** (Group 3 tests c/d), which the
  old `tryDerivedMatch` (requiring `apply` to leave zero goals, never
  recursing) could not do. Necessitation `⊢ □φ ⇒ ⊢ φ` recursion is already
  handled by `tryModalK`, not `tryLemmaMatch`.
- **Tests placed in a NEW file** `Tests/BimodalTest/Automation/LemmaDBTest.lean`
  (registered in `Tests/BimodalTest.lean`), not `TacticsTest.lean` which is
  broken at baseline (~94 pre-existing errors from the frame-class
  generalization). Follows the task-189 precedent.
- **`efq` (deprecated alias) not tagged**; the primary `efq_neg` (identical
  statement) is tagged instead — stacked `@[deprecated]`+`@[tm_lemma]` blocks
  do not parse, and automation should not apply deprecated constants. The
  migration goal `¬A → (A → B)` still closes.
- **Expanded tagging conservative** (9 additions → 35, not ~30-60): only
  premise-free empty-context theorems, to avoid inference-rule branching
  blowup. GeneralizedNecessitation and ContextualProofs untouched as required.
- **`searchProof` signature**: added a curried `IO.Ref Nat` first parameter and
  dropped the unused `_maxDepth` parameter; `try*` helper signatures unchanged.

## Test coverage (LemmaDBTest.lean)

- Group 1: `@[tm_lemma]` label-count smoke check (`≥ 26`, currently 35).
- Group 2: 26-goal migration regression (migration invariant).
- Group 3: weakening fallback under non-empty context (c); depth-exhaustion /
  non-derivability + weakening-termination via `fail_if_success` (d).
- Group 4: `visitLimit := 0` aborts a provable goal; `visitLimit := 1000`
  closes it (proves the counter is a real abort).
- Group 5: expanded-tag spot checks (`lem`, `peirce_axiom`, `box_to_present`,
  `mb_diamond`).

## Modified / new files

New: `Theories/Bimodal/Automation/LemmaDB.lean`,
`Tests/BimodalTest/Automation/LemmaDBTest.lean`.
Modified: `Automation/Tactics/{Helpers,Commands}.lean`,
`Automation/AesopRules.lean`, `Theorems/Combinators.lean`,
`Theorems/Propositional/{Core,Connectives,Reasoning}.lean`,
`Theorems/TemporalDerived.lean`, `Theorems/ModalS5.lean`,
`Theorems/Perpetuity/{Principles,Helpers}.lean`, `Tests/BimodalTest.lean`.

(`Propositional/Reasoning.lean` change is the `import` + `@[tm_lemma]` on
`bi_imp` only.)
