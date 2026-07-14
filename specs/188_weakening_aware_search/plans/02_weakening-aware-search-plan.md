# Implementation Plan: Weakening-Aware Search

- **Task**: 188 - Weakening aware search
- **Status**: [COMPLETED]
- **Effort**: 5 hours
- **Dependencies**: None (task 187 explicitly NOT a dependency; leave a parameterized hook)
- **Research Inputs**: reports/02_weakening-aware-search.md (authoritative; supersedes reports/01_weakening-aware-seed.md)
- **Artifacts**: plans/02_weakening-aware-search-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The tactic-search layer (`modal_search`) cannot use any of the ~26 registered empty-context
derived theorems when the goal context is non-empty, because `tryDerivedMatch`
(`Theories/Bimodal/Automation/Tactics/Helpers.lean:650`) applies `⊢ φ`-typed constants directly
and unification pins the goal context to `[]`. The fix is a new closure-step strategy
`tryWeakenedDerivedMatch` that wraps table hits in `DerivationTree.weakening` and discharges the
`[] ⊆ Δ` side-goal schematically — a pattern that already typechecks at the term level
(`Automation/AesopRules.lean:103`) and already exists in the computable search
(`ProofSearch/Core.lean:1098`). Done means: weakened matching wired into `searchProof`, the
computable `matchDerived` table extended beyond its single entry, the `matchAxiom`
short-circuit completeness bug fixed, tests passing, `lake build` green with zero sorries.

### Research Integration

From `reports/02_weakening-aware-search.md`:
- **Closure step, never a backward rule** — generic backward weakening leaves `?Γ` as an
  unconstrained metavariable (infinite branching). Weakening fires only against concrete
  table candidates whose context (`[]`) is known; branching factor unchanged.
- The gap is confined to `tryDerivedMatch`; `tryAxiomMatch` (:532) is already
  context-polymorphic and needs no change. No `ProofSystem/` changes: `DerivationTree.weakening`
  (`Derivation.lean:164`), `Derivable.weaken` (aesop rule), and `List.nil_subset` all exist.
- Recursion inherits the new strategy for free: MP / modal-K / temporal-K subgoals call back
  into `searchProof`.
- Latent completeness bug flagged for fixing in passing: `bounded_search_with_proof`'s
  `matchAxiom` branch (`Core.lean:1082-1093`) returns `none` on frame-class mismatch or formula
  mismatch instead of falling through to derived/assumption/MP.

### Prior Plan Reference

No prior plan (plans/ directory did not exist; this is plan round 2 following report 02).

### Roadmap Alignment

No ROADMAP.md consultation requested for this task.

## Goals & Non-Goals

**Goals** *(reconciled 2026-07-14: first two goals were delivered by task 187's
`tryLemmaMatchCore` + `@[tm_lemma]` database; no `derivedTheoremTable` or
`tryWeakenedDerivedMatch` exists or is needed)*:
- `modal_search` closes non-empty-context goals whose formula matches a registered derived
  theorem (e.g., `[p, q] ⊢ (p.imp p)`), including under recursion (MP/K subgoals).
  *(done-by-187; machine-checked by task 188's `WeakeningSearchTest.lean`)*
- Single shared derived-theorem table (`derivedTheoremTable : List Name`) used by both
  `tryDerivedMatch` and `tryWeakenedDerivedMatch`, passed as a parameter so task 187 can inject
  a lemma DB later without touching strategy code. *(obsolete — 187 landed the lemma DB directly)*
- Computable `bounded_search_with_proof` recognizes more derived-theorem shapes via an extended
  `matchDerived`, reusing the existing `weakening [] Γ` plumbing at `Core.lean:1098`.
- `matchAxiom` failure falls through to the remaining strategies (completeness fix).
- Zero sorries, no vacuous definitions, every phase ends with a green scoped `lake build`.

**Non-Goals**:
- Non-empty-context lemma registration, subsumption indexing, canonical-form storage → task 187.
- "Weakened modus ponens" / backward chaining over a lemma pool → tasks 187/192.
- Aesop tuning of `Derivable.weaken` safe-rule metavariable risk → note for tasks 186/192 only.
- Reordering modal-K/temporal-K strategies (research confirmed no ordering change needed).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `MVarId.apply` on `DerivationTree.weakening` yields goals in unexpected order (explicit `Γ Δ φ` args) | M | M | Phase 1 starts with a throwaway proof-of-concept elab before committing to the design; classify goals defensively by type shape (mirror `tryAxiomMatch` :545-551), never by position |
| Search-time regression from extra strategy pass | L | L | Strategy placed after the three cheap strategies; one linear pass over 26 names only on their failure; skip when goal context is syntactically `[]`; negative-goal perf test in Phase 4 |
| `matchAxiom` fall-through restructure changes dependent-match elaboration (`_hax :` binding, `heq ▸`) | M | M | Restructure to an `Option`-valued axiom attempt consumed by the existing chain; keep the proof term identical in the success branch; scoped build gate immediately after |
| Term-size growth from extra `weakening` node | L | L | Accepted — identical to what manual proofs produce today |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 3 | -- |
| 2 | 2 | 1 |
| 3 | 4 | 1, 2, 3 |

Phases within the same wave can execute in parallel (Phases 1 and 3 touch disjoint files).

### Phase 1: `tryWeakenedDerivedMatch` in tactic search [COMPLETED]

> **Reconciliation note (task 188 implementation, 2026-07-14)**: This phase was fully
> subsumed by task 187 (committed before 188 implementation began). `tryDerivedMatch` no
> longer exists; `tryLemmaMatchCore` (`Helpers.lean:696-773`) now matches against the
> `@[tm_lemma]` database and, for non-empty contexts, applies a weakening fallback via
> `DerivationTree.weakening` + `List.nil_subset` (`Helpers.lean:753-772`). No separate
> `tryWeakenedDerivedMatch` is needed. All tasks below are marked done-by-187.

**Goal**: Weakened derived-theorem matching wired into `searchProof` as a closure step; the
motivating example `[p, q] ⊢ (p.imp p)` closes by `modal_search`.

**Tasks**:
- [x] *(deviation: skipped — subsumed by task 187)* Proof-of-concept (throwaway, ~5-line elab or `#eval`/example in a scratch section): apply
      `mkConst ``DerivationTree.weakening` to a goal `DerivationTree fc Δ φ`; confirm resulting
      goal count/kinds (`?Γ : Context` assigned by later unification, `?d : DerivationTree fc ?Γ φ`,
      `?h : ?Γ ⊆ Δ`) and that classification by type shape works. Delete scratch before commit.
- [x] *(deviation: altered — task 187 replaced the static list with the `@[tm_lemma]` database consumed by `tryLemmaMatchCore`)* Factor the 26-name list out of `tryDerivedMatch` (`Helpers.lean:653-682`) into a shared
      top-level constant `derivedTheoremTable : List Name`; `tryDerivedMatch` reuses it
      (behavior unchanged).
- [x] *(deviation: altered — task 187's weakening fallback inside `tryLemmaMatchCore` provides this behavior)* Implement `tryWeakenedDerivedMatch (goal : MVarId) (ctx formula : Expr) : TacticM Bool`
      per the research sketch (report §Phase 1):
      - `observing?` discipline exactly as in the existing three strategies (state rollback).
      - Early-exit `return false` when the extracted `ctx` is syntactically `List.nil`
        (direct `tryDerivedMatch` already covers that case).
      - `goal.apply (mkConst ``DerivationTree.weakening)`; classify resulting goals by matching
        goal types against `DerivationTree _ _ _` vs `_ ⊆ _` (defensive, order-independent —
        mirror the `Axiom _`/frame-class split in `tryAxiomMatch` :545-551).
      - Loop over `derivedTheoremTable` (taken as a parameter with default
        `derivedTheoremTable`, the task-187 hook): `dGoal.apply (mkConst derivedName)`; on
        empty residual goals, close the subset goal with `exact List.nil_subset _`; `catch _ =>
        continue` per candidate; error out of the `observing?` block if no candidate matches.
- [x] *(deviation: skipped — subsumed by task 187 wiring of `tryLemmaMatch`)* Wire into `searchProof` (:994) immediately after `tryAssumptionMatch` (:1011) and before
      `tryModusPonens` — cheap goal-closing strategies before expensive decomposition. Keep
      `tryDerivedMatch` in place at :1007 (direct application is cheaper, smaller terms).
- [x] *(deviation: skipped — subsumed by task 187 docstring updates)* Update the strategy-list docstring in the `Helpers.lean` header (:25-45) from five to six
      strategies; remove/adjust the stale "would require weakening infrastructure" note at
      :646-648.
- [x] *(deviation: skipped — task 187 committed green; headline example covered by task 188 Phase 4 test file)* Gate: `lake build Bimodal.Automation.Tactics.Helpers` green; inline
      `example (p q : Formula) : [p, q] ⊢ (p.imp p) := by modal_search` succeeds (may live in
      the Phase 4 test file from the start if preferred); zero sorries introduced
      (`grep -n sorry` on touched files).

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/Tactics/Helpers.lean` — factor table, new strategy, wiring, docstrings (~70 lines)

**Verification**:
- Scoped build green; motivating example closes; existing `modal_search` behavior on
  empty-context goals unchanged (spot-check an existing passing example).

---

### Phase 2: Subset side-goal combinator (task-187 forward compatibility) [COMPLETED]

> **Reconciliation note (task 188 implementation, 2026-07-14)**: Obsoleted by task 187's
> design. The committed weakening fallback in `tryLemmaMatchCore` reduces the whole goal to
> the empty context and recurses, so the subset side-goal is always literally `[] ⊆ Γ` and
> `List.nil_subset` suffices by construction — no `first` combinator is required. Tasks
> below are marked done-by-187 (skipped as obsolete).

**Tasks**:
- [x] *(deviation: skipped — obsolete under 187's design; subset goal is always `[] ⊆ Γ`)* In `tryWeakenedDerivedMatch`, close the `⊆` goal with:
      `first | exact List.nil_subset _ | exact List.Subset.refl _ | simp [List.subset_def] | decide`
      (report §Phase 2 — combinator, not a dedicated subset prover).
- [x] *(deviation: skipped — obsolete, no `decide` arm exists)* Confirm the `decide` arm is reachable only for closed contexts (DecidableEq on `Formula`,
      `Syntax/Formula.lean:85`) and that failure of all arms fails the candidate cleanly inside
      `observing?` (no stuck metavariables leak).
- [x] *(deviation: skipped — task 187 committed green)* Gate: `lake build Bimodal.Automation.Tactics.Helpers` green; Phase 1 example still closes.

**Timing**: 0.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Automation/Tactics/Helpers.lean` — subset-closing tactic only (~15 lines)

**Verification**:
- Scoped build green; no behavior change for `[]`-context candidates (first arm still fires).

---

### Phase 3: Computable search — extend `matchDerived`, fix `matchAxiom` fall-through [COMPLETED]

**Goal**: `bounded_search_with_proof` recognizes the closed-form derived theorems with
unambiguous head structure (not just `□φ → G□φ`), and `matchAxiom` failure no longer
short-circuits the strategy chain.

**Tasks**:
- [x] *(deviation: altered — `lce_imp`/`rce_imp` (noncomputable section) and `temp_4_derived`/`H_transitivity` (noncomputable defs) excluded because `matchDerived` must stay computable for `bounded_search_with_proof`; added arms: identity, dni, box_to_future, box_to_past)* Extend `matchDerived` (`Core.lean:1024`) with structural formula-shape arms returning
      `some (⊢ φ)`, prioritizing unambiguous head shapes (report §Phase 3): identity `φ → φ`,
      `dni` (`φ → ¬¬φ`), `lce_imp`/`rce_imp` (`(A ∧ B) → A/B`), `box_to_future` (`□φ → Gφ`),
      `box_to_past` (`□φ → Hφ`), `temp_4_derived` (`Gφ → GGφ`), `H_transitivity` (`Hφ → HHφ`).
      Skip shapes whose pattern is ambiguous against these; each arm reuses the corresponding
      `Bimodal.Theorems.*` constant. The existing `weakening [] Γ` wrapper at :1098 needs no
      change.
- [x] Fix the completeness bug at `Core.lean:1082-1093`: restructure so that
      `matchAxiom φ = some ⟨ψ, witness⟩` with `φ ≠ ψ` or
      `¬ witness.minFrameClass ≤ FrameClass.Base` falls through to the
      derived/assumption/MP chain instead of returning `(none, visited, visits)`. Suggested
      shape: compute the axiom attempt as an `Option (Γ ⊢ φ)` first (preserving the
      `heq ▸ DerivationTree.axiom Γ ψ witness hfc` success term), then match on it with the
      existing chain as the `none` branch. Preserve termination (function is structural on
      `depth`; no recursion added).
- [x] Gate: `lake build Bimodal.Automation.ProofSearch.Core` green; zero sorries; no `decide`
      timeouts introduced.

**Timing**: 1.5 hours

**Depends on**: none (disjoint file from Phases 1-2; can run in Wave 1)

**Files to modify**:
- `Theories/Bimodal/Automation/ProofSearch/Core.lean` — `matchDerived` arms + `matchAxiom` fall-through (~40 lines)

**Verification**:
- Scoped build green; a `#eval`/`decide`-style spot check that
  `bounded_search_with_proof [p] (p.imp p) 3` now returns `some _` (formula-shape arm firing
  through the weakening wrapper).

---

### Phase 4: Tests and regression guard [COMPLETED]

**Goal**: Machine-checked evidence for the new behavior in both layers plus a no-regression
sanity check; full-project build green.

**Tasks**:
- [x] *(deviation: altered — cases placed in NEW `Tests/BimodalTest/Automation/WeakeningSearchTest.lean` because `TacticsTest.lean` and `ProofSearchTest.lean` are baseline-broken (pre-existing String/Atom and `search` identifier errors); new file registered in `Tests/BimodalTest.lean`)* Add to `Tests/BimodalTest/Automation/TacticsTest.lean` (report §Phase 4):
      - `example (p q : Formula) : [p, q] ⊢ (p.imp p) := by modal_search` — weakened identity
        in non-empty context (previously required manual
        `DerivationTree.weakening [] [p,q] _ ... (List.nil_subset _)`).
      - `example (p q : Formula) : [(p.imp p).imp q] ⊢ q := by modal_search 3` — weakened
        derived theorem under recursion (MP subgoal in non-empty context).
      - At least one Tier-2 case, e.g. `[q] ⊢ ((Formula.box p).imp (Formula.all_future p))`
        via `box_to_future` (adjust to actual constructor names in the file's existing style).
      - Negative sanity check: an unprovable goal (e.g. `[] ⊢ p` for atomic `p`) still fails
        fast — `modal_search` failure observed via the file's existing failure-test idiom
        (guard against search-space regression).
- [x] *(deviation: altered — placed in `WeakeningSearchTest.lean`, see above)* Add computable-layer cases to `Tests/BimodalTest/Automation/ProofSearchTest.lean`:
      `bounded_search_with_proof` returns `some` for an extended-`matchDerived` shape in a
      non-empty context, and for an axiom-mismatch formula that previously dead-ended
      (fall-through fix witnessed).
- [x] *(deviation: altered — `lake build BimodalTest` is baseline-broken (431 pre-existing errors across 17 untouched test files, e.g. `DerivationTest.lean`, `EdgeCaseTest.lean`); gate satisfied via scoped `lake build BimodalTest.Automation.WeakeningSearchTest` green + full default-target `lake build` green)* Gate: `lake build BimodalTest` green, then full `lake build` green (final verification);
      zero sorries in the diff (`git diff --stat` + sorry grep over touched files).

**Timing**: 1 hour

**Depends on**: 1, 2, 3

**Files to modify**:
- `Tests/BimodalTest/Automation/TacticsTest.lean` — new tactic-layer cases (~25 lines)
- `Tests/BimodalTest/Automation/ProofSearchTest.lean` — new computable-layer cases (~10 lines)

**Verification**:
- `lake build BimodalTest` and full `lake build` green; all new examples close; negative test
  confirms no blow-up.

## Testing & Validation

- [x] `lake build Bimodal.Automation.Tactics.Helpers` green after Phases 1-2 *(done-by-187; file untouched by 188)*
- [x] `lake build Bimodal.Automation.ProofSearch.Core` green after Phase 3
- [x] `lake build BimodalTest.Automation.WeakeningSearchTest` + full `lake build` green after Phase 4 *(deviation: full `lake build BimodalTest` root is baseline-broken in 17 pre-existing files)*
- [x] `[p, q] ⊢ (p.imp p)` closes by `modal_search` (headline acceptance criterion; also mirrored at the computable layer via `bounded_search_with_proof`)
- [x] Recursion case `[(p.imp p).imp q] ⊢ q` closes by `modal_search 3`
- [x] Existing empty-context behavior unchanged (TF arm regression `#guard` passes)
- [x] Zero sorries and no vacuous definitions in all touched files (`#print axioms` on `matchDerived`/`bounded_search_with_proof`: only `propext`, `Quot.sound`)
- [x] Negative goal fails fast (`bounded_search_with_proof [] z 5` returns `none`, guarded)

## Artifacts & Outputs

- `specs/188_weakening_aware_search/plans/02_weakening-aware-search-plan.md` (this file)
- `specs/188_weakening_aware_search/summaries/02_weakening-aware-search-summary.md` (at /implement completion)
- Modified (actual, task 188): `Theories/Bimodal/Automation/ProofSearch/Core.lean`,
  `Tests/BimodalTest.lean`
- Added (actual, task 188): `Tests/BimodalTest/Automation/WeakeningSearchTest.lean`
- Not modified (deviations): `Helpers.lean` (done-by-187), `TacticsTest.lean` /
  `ProofSearchTest.lean` (baseline-broken; superseded by the new test file)

## Rollback/Contingency

- Each phase is a self-contained green commit (`task 188 phase P: ...`); revert the specific
  commit(s) to roll back — no `ProofSystem/` or semantics files are touched, so reverts are
  isolated to automation and tests.
- If the Phase 1 proof-of-concept shows `apply weakening` goal handling is unreliable, fall
  back to constructing the weakening application explicitly via `mkAppM` with the goal's
  `fc/Δ/φ` (term-level pattern from `AesopRules.lean:103`) instead of `MVarId.apply` — same
  strategy contract, no plan restructure.
- If the Phase 3 `matchAxiom` restructure proves risky, split it out: land the `matchDerived`
  extension alone (independent) and defer the fall-through fix to a spawned follow-up task.
