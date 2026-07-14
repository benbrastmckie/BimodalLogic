# Research Report: Weakening-Aware Proof Search

**Task**: #188 — Weakening-aware search (lean4)
**Date**: 2026-07-14
**Session**: sess_1784042334_6ccc8d
**Supersedes/extends**: `reports/01_weakening-aware-seed.md` (seed)

## Executive Summary

The seed report's diagnosis is confirmed, but its file references are stale: the automation code
was reorganized (`Tactics.lean` → `Tactics/{Helpers,Commands}.lean`, `ProofSearch.lean` →
`ProofSearch/{Core,Strategies}.lean`). Two of the three search layers already have partial
weakening awareness; the gap is concentrated in one place — **`tryDerivedMatch` in
`Tactics/Helpers.lean`**, which applies empty-context theorem constants (`⊢ φ` =
`DerivationTree FrameClass.Base [] φ`) directly and therefore fails whenever the goal context is
non-empty. Fixing this requires a small, well-scoped change (~60-100 lines) using a
weakening-wrapper pattern that already exists verbatim at the term level in `AesopRules.lean:103`.
Task 187 (lemma database) is NOT STARTED, so this task should not depend on it; instead it should
make the existing hardcoded theorem table weakening-aware and leave a clean hook for 187.

## Current State (verified against HEAD, post-reorganization)

### Layer inventory

| Layer | File | Weakening status |
|-------|------|------------------|
| Tactic search (`modal_search` etc.) | `Theories/Bimodal/Automation/Tactics/Helpers.lean` (`searchProof` :994) | **Gap**: `tryDerivedMatch` (:650) fails on non-empty contexts; `tryAxiomMatch` (:532) is fine (context-polymorphic constructor) |
| Computable search | `Theories/Bimodal/Automation/ProofSearch/Core.lean` (`bounded_search_with_proof` :1064) | Partial: already weakens `matchDerived` hits from `[]` via `List.nil_subset` (:1098); `matchDerived` table (:1024) has only ONE entry |
| Aesop (Prop-level `Derivable`) | `Theories/Bimodal/ProofSystem/Derivable.lean` | Covered: `Derivable.weaken` (:140) is `@[aesop safe apply]` — but see caveat below |

### Key facts

1. **Weakening constructor** — `Theories/Bimodal/ProofSystem/Derivation.lean:164`:
   ```lean
   | weakening (Γ Δ : Context) (φ : Formula)
       (d : DerivationTree fc Γ φ)
       (h : Γ ⊆ Δ) : DerivationTree fc Δ φ
   ```
   `fc` is implicit (inductive parameter); `Γ Δ φ` are explicit. Applying the constructor to a
   goal `DerivationTree fc Δ φ` unifies `Δ, φ` and leaves goals `?Γ : Context`,
   `?d : DerivationTree fc ?Γ φ`, `?h : ?Γ ⊆ Δ`.

2. **Prop-level monotonicity lemma** — `Derivable.weaken` (`ProofSystem/Derivable.lean:140`),
   already registered `@[aesop safe apply]`. No new ProofSystem lemma is needed for this task.

3. **`searchProof` strategy order** (`Tactics/Helpers.lean:994-1029`): axiom match → derived
   match → assumption match → modus ponens → modal K → temporal K, all depth-guarded, recursing
   via `searchFn`.

4. **The gap, precisely**: `tryDerivedMatch` (:650) does `goal.apply (mkConst derivedName)` for
   each of ~26 registered theorem constants (Combinators, Propositional, ModalS5, Perpetuity,
   TemporalDerived). These constants have type `⊢ φ-schema`, i.e. context `[]`. `apply` unifies
   the goal's context with `[]`, so the strategy is dead for every non-empty-context goal. The
   docstring at :646-648 explicitly acknowledges this ("would require weakening infrastructure").

5. **Working term-level pattern** (proves the construction typechecks) —
   `Automation/AesopRules.lean:103`:
   ```lean
   DerivationTree.weakening [] Γ _ (Bimodal.Theorems.TemporalDerived.temp_4_derived φ) (List.nil_subset Γ)
   ```
   and the computable analogue at `ProofSearch/Core.lean:1098`.

6. **Decidability groundwork**: `Formula` derives `DecidableEq, BEq, Hashable`
   (`Syntax/Formula.lean:85`); `Context := List Formula` (`Syntax/Context.lean:54`). So subset
   checks in the computable layer are `decide`-able, and `List.nil_subset` covers the dominant
   `[] ⊆ Γ` case for free (no decidability needed — it is schematic).

7. **Related task states** (from `specs/state.json`): 186 (unify search systems), 187 (lemma DB),
   192 (master dispatch), 193 (refactor) are all `not_started`. **Do not depend on 187**; design
   for it as a future consumer.

## Recommended Approach

### Core principle: weakening as a closure step, never a search rule

Adding weakening as a generic backward rule is catastrophic (the premise context `?Γ` is an
unconstrained metavariable — infinite branching). Instead, weakening should fire **only when a
concrete candidate lemma with a known (smaller) context matches the goal formula**. The candidate
set is finite (the derived-theorem table), the context is known (`[]` for all current entries),
and the subset side-goal is closed schematically by `List.nil_subset`. Branching factor of the
search is unchanged; each `searchProof` call gains at most one extra pass over the same ~26-entry
table it already scans. Recursion (modus ponens / modal K / temporal K subgoals) inherits the new
strategy automatically since they call back into `searchProof`.

### Phase 1 — `tryWeakenedDerivedMatch` in `Tactics/Helpers.lean` (~50-70 lines)

New strategy function, inserted in `searchProof` immediately after `tryAssumptionMatch`
(cheap goal-closing strategies before expensive decomposition):

```lean
def tryWeakenedDerivedMatch (goal : MVarId) (_ctx _formula : Expr) : TacticM Bool := do
  let result ← observing? do
    setGoals [goal]
    -- Goal: DerivationTree fc Δ φ. Apply weakening ⇒ ?Γ, ?d : DT fc ?Γ φ, ?h : ?Γ ⊆ Δ
    let newGoals ← goal.apply (mkConst ``DerivationTree.weakening)
    -- classify: the DerivationTree goal is ?d; the ⊆ goal is ?h (?Γ is assigned by unification)
    ...
    for derivedName in derivedExprs do   -- reuse/share the existing table from tryDerivedMatch
      try
        let gs ← dGoal.apply (mkConst derivedName)   -- unifies ?Γ := []
        if gs.isEmpty then
          setGoals [subsetGoal]
          evalTactic (← `(tactic| exact List.nil_subset _))
          setGoals []; return ()
      catch _ => continue
    throwError "no weakened derived theorem matched"
  return result.isSome
```

Implementation notes:
- **Factor the theorem table out** of `tryDerivedMatch` into a shared
  `derivedTheoremTable : List Name` constant so both strategies (and later task 187) use one list.
- Goal classification after `apply weakening`: match goal types against
  `DerivationTree _ _ _` vs `_ ⊆ _` (same pattern as the `Axiom _`/frame-class split in
  `tryAxiomMatch` :545-551).
- `observing?` discipline (state rollback on failure) exactly as in the existing three strategies.
- Keep `tryDerivedMatch` first (direct application is cheaper and produces smaller terms);
  `tryWeakenedDerivedMatch` only runs when it fails. Optionally skip it when the extracted `ctx`
  is syntactically `List.nil` (direct match already covered that case).

### Phase 2 — subset side-goal tactic (small, ~15 lines)

For the current scope, every registered lemma has context `[]`, so
`exact List.nil_subset _` suffices. To be forward-compatible with non-empty lemma contexts
(task 187 will want `ecq : [A, ¬A] ⊢ B` etc.), close the `⊆` goal with a first-combinator:

```lean
first
  | exact List.nil_subset _
  | exact List.Subset.refl _
  | simp [List.subset_def]
  | decide
```

`decide` works for closed formulas (DecidableEq); `simp [List.subset_def]` handles literal-list
goals with free formula variables. No dedicated subset prover is warranted yet (seed Question 2:
answer — combinator, not new infrastructure).

### Phase 3 — computable search: extend `matchDerived` (~20-40 lines)

`bounded_search_with_proof` already has the weakening plumbing (`Core.lean:1098`); its weakness is
that `matchDerived` (:1024) recognizes exactly one theorem shape (`□φ → G□φ`). Extend the match
with the other closed-form derived theorems that pattern-match structurally
(identity `φ → φ`, dni, lce/rce, box_to_future/past, temp_4, H_transitivity, ...). Each new arm is
a formula-shape match returning `some (⊢ φ)`; the existing `weakening [] Γ` wrapper does the rest.
This is mechanical; prioritize the shapes with unambiguous head structure. (Seed Question 4:
yes — and the plumbing already exists, only the table is thin.)

**Bug worth fixing in passing** (flag for planner): in `bounded_search_with_proof`, the
`matchAxiom` branch (:1082-1093) returns `none` outright on frame-class mismatch instead of
falling through to derived/assumption/MP strategies — a completeness gap independent of
weakening. The weakening-aware edit touches this `match` chain anyway; restructure so failure
falls through.

### Phase 4 — tests (`Tests/BimodalTest/Automation/TacticsTest.lean`)

Existing test files: `Tests/BimodalTest/Automation/TacticsTest.lean`, `EdgeCaseTest.lean`.
Add cases of the form:

```lean
-- previously required: exact DerivationTree.weakening [] [p,q] _ (identity ...) (List.nil_subset _)
example (p q : Formula) : [p, q] ⊢ (p.imp p) := by modal_search
-- weakened derived under recursion (MP subgoal in non-empty context)
example (p q : Formula) : [(p.imp p).imp q] ⊢ q := by modal_search 3
```

Plus a negative/perf sanity check that `modal_search` still fails fast on unprovable goals
(no search-space regression).

### Out of scope (defer, with rationale)

- **Non-empty-context lemma registration + subsumption indexing** → task 187 (lemma DB). The
  seed's Phase 1 "context subsumption checker" (`isDefEq`-based) is only needed once lemmas with
  non-`[]` contexts are registered; for `[]`-context lemmas subsumption is trivially true.
  Design hook: `tryWeakenedDerivedMatch` should take the theorem table as a parameter.
- **"Weakened modus ponens"** (using `⊢ ψ → φ` pool lemmas as implications, not just ctx members)
  → this is backward chaining over a lemma DB, i.e. task 187/192 territory.
- **Aesop tuning**: `Derivable.weaken` is `@[aesop safe apply]` with an unconstrained premise
  context — as a *safe* rule this can commit aesop to a `?G ⊆ D` goal with a metavariable
  context. Worth a note in 186/192, not a blocker here (the `Derivable` layer is not the target
  of this task).
- **Modal K / temporal K interaction** (seed Question 3): no ordering change needed — weakened
  matching is a closure step tried before the K rules; if a K rule transforms the context, the
  recursive `searchProof` call tries weakened matching again in the transformed context.

## Answers to Seed Questions

1. **Performance cost of subsumption checks**: nil for this task — all candidates have context
   `[]`, so the check is the schematic `List.nil_subset`. Indexing by formula head becomes
   relevant only with task 187's open-ended lemma DB.
2. **Subset proof construction**: `first`-combinator (Phase 2), not a dedicated prover.
3. **Interaction with K rules**: weakening-before-transformation, and recursion re-applies it
   after transformation; no special handling.
4. **Computable search**: yes — plumbing exists at `Core.lean:1098`; extend `matchDerived`.
5. **Canonical-form storage**: premature; revisit in 187.

## File Targets (concrete)

| File | Change | Est. lines |
|------|--------|-----------|
| `Theories/Bimodal/Automation/Tactics/Helpers.lean` | Factor `derivedTheoremTable`; add `tryWeakenedDerivedMatch`; wire into `searchProof` (:994) as strategy 2c | ~70 |
| `Theories/Bimodal/Automation/ProofSearch/Core.lean` | Extend `matchDerived` (:1024); fix matchAxiom fall-through (:1082) | ~40 |
| `Tests/BimodalTest/Automation/TacticsTest.lean` | New weakening-aware test cases | ~30 |
| `Theories/Bimodal/Automation/Tactics/Commands.lean` | Docstring update only (strategy list :25-45 in Helpers header + README) | ~5 |

No changes needed in `ProofSystem/` — all required lemmas (`DerivationTree.weakening`,
`Derivable.weaken`, `List.nil_subset`) exist.

## Risks

- **Term-size growth**: weakened proofs carry an extra `weakening` node; harmless (the manual
  pattern produces identical terms today).
- **`apply` unification surprises**: `DerivationTree.weakening` has explicit `Γ Δ φ` args;
  `MVarId.apply` handles these as metavariables, but goal-classification code must not assume a
  fixed goal order (mirror the defensive classification in `tryAxiomMatch` :545-551). Validate
  with a 5-line proof-of-concept elab before committing to the design (first implementation step).
- **Search-time regression**: bounded — one extra linear pass over ~26 names, only after the
  three cheap strategies fail. Existing depth/visit guards unchanged.

## References

- `Theories/Bimodal/ProofSystem/Derivation.lean:164` — `weakening` constructor (fc-parameterized)
- `Theories/Bimodal/ProofSystem/Derivable.lean:140` — `Derivable.weaken` (`@[aesop safe apply]`)
- `Theories/Bimodal/Automation/Tactics/Helpers.lean:532/650/706/994` — `tryAxiomMatch` / `tryDerivedMatch` / `tryAssumptionMatch` / `searchProof`
- `Theories/Bimodal/Automation/ProofSearch/Core.lean:1024/1064/1098` — `matchDerived` / `bounded_search_with_proof` / existing nil-weakening
- `Theories/Bimodal/Automation/AesopRules.lean:103` — term-level weakening pattern (typechecks today)
- `Theories/Bimodal/Syntax/Formula.lean:85`, `Syntax/Context.lean:54` — DecidableEq / Context def
- Seed: `specs/188_weakening_aware_search/reports/01_weakening-aware-seed.md`
