# Implementation Plan: Discharge the `DifficultyBounded` residual

- **Task**: 431 - Discharge `DifficultyBounded fc U D` (at `β ≥ 3`) on the totality terminus
- **Status**: [IMPLEMENTING]
- **Effort**: 11.5 hours
- **Dependencies**: None (parent task 428's terminus is landed and is read-only input here)
- **Research Inputs**: `specs/431_discharge_difficultybounded_residual/reports/01_spawn-inherited-research.md`
- **Artifacts**: plans/01_discharge-difficultybounded-residual.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

`DifficultyBounded fc U D` (MintBound.lean:3914) is one of four residual hypotheses on the
totality terminus. Planning established, with in-repo evidence and two green Lean probes, that the
obstruction is **not** the `private` visibility of `temporalCount`/`modalCount` that the current
docstring blames, and that the residual **as literally stated is refutable at every `D`**. The plan
therefore takes scope option **(b)** — no `Saturation.lean` edit — and delivers the honest maximum:
the refutation, plus an equivalence reducing the difficulty bound to a pure branch-**length** bound,
plus a sibling terminus stated at that length bound. Done means every new declaration is sorry-free
and axiom-free with `lake build` green, and the misleading in-source rationale is replaced.

### Research Integration

The inherited research is a spawn stub. The load-bearing findings below were established during
planning and are recorded here because no report carries them:

1. **`estimateBranchDifficulty` unfolds fine across the file boundary.** `private` blocks *name
   resolution*, not unfolding. `simp only [estimateBranchDifficulty]` inside MintBound.lean leaves
   the two counters as opaque terms (`temporalCount✝`, `modalCount✝`) over which `omega` reasons
   freely. **Verified green in planning**: `1 + b.length / 4 ≤ estimateBranchDifficulty b` closes by
   `simp only [estimateBranchDifficulty]; omega`.
2. **Upper bounds also transfer, via unification.** A generic lemma whose counters are universally
   quantified (`f g : Formula → Nat`) can be discharged against the unfolded goal by
   `exact gen_lemma _ _ …` — the elaborator unifies the metavariables with the private constants
   even though they cannot be typed. **Verified green in planning.**
3. **So option (a) is neither necessary nor sufficient.** Not necessary, by (1)+(2). Not sufficient,
   because the real obstruction is **multiplicity**: `estimateBranchDifficulty` sums its counters
   over the branch **list** and adds `b.length / 4`, while every confinement fact in the development
   is about `b.toFinset`. `Branch` is `List SignedFormula` (SignedFormula.lean:240) and **nothing in
   the repo asserts a branch is `Nodup`** (`BranchOrder.lean:281-283` records that avoiding a
   `Nodup` side condition was a deliberate design goal). `expandOnceUnblocked` builds successors as
   raw `formulas ++ b` (Tableau.lean:2233-2239) with no `eraseDups`. Confinement to `U` therefore
   bounds nothing about `b.length`, so no fixed `D` can bound `estimateBranchDifficulty` — with
   `temporalCount` public or private alike.
4. **Emitted-list lengths are `Θ(|b|)`, not constant.** 13 rule arms emit lists built by
   `filterMap` over the branch or over `timeOrd.futureOf`: `.boxPos` (Tableau.lean:671),
   `.diamondNeg` (731), `.boxNeg` (679), `.diamondPos` (704), `.allFutureNeg` (760), `.allPastNeg`
   (800), `.someFuturePos` (831), `.somePastPos` (875), `.densityRule` (1338), plus the four
   ordering-driven `.allFuturePos` (751), `.allPastPos` (791), `.someFutureNeg` (863),
   `.somePastNeg` (907). The `.branching` arms of `.untlPos`/`.sncePos`/`.untlNeg`/`.snceNeg` are
   the same shape. Only `.branchingOrdered` is benign: all three arms have length `≤ b.length`
   (arms 1-2 are the branch verbatim, arm 3 is `Branch.identifyTime` = `(b.map relabel).eraseDups`).
5. **No upper bound on successor list length exists anywhere.** The only length lemma is the *lower*
   bound `expandOnceUnblocked_length_lt` (Tableau.lean:2556). `Fuel.lean` uses `toFinset.card`
   throughout, deliberately, for exactly this reason.

### Prior Plan Reference

No prior plan for this task. The parent plan
`specs/428_engine_totality_at_a_quantified_branch_budget/plans/04_ordtimesknown-strengthening-totality.md`
is honoured as a constraint, not a template: `Fuel.lean`, `Tableau.lean` and `Saturation.lean` stay
byte-identical, and every edit here is **additive** inside `MintBound.lean` (new declarations plus
two docstring repairs) so no landed statement is withdrawn or re-proved.

### Roadmap Alignment

No `specs/ROADMAP.md` in this repository; no roadmap phases required.

## The scope decision, settled up front

**Chosen: (b) — restate and discharge using only `estimateBranchDifficulty`'s public interface plus
facts available in `MintBound.lean`. `Saturation.lean` is not edited.**

Rationale, in one line each:

- (a) is **not necessary**: unfolding plus generic-counter unification already gives both a lower
  bound and arbitrary upper bounds on `estimateBranchDifficulty` from inside `MintBound.lean`
  (findings 1-2, both probe-verified).
- (a) is **not sufficient**: the obstruction is list multiplicity, not name visibility (finding 3).
  Making `temporalCount` public would leave the residual exactly as unprovable as it is now, while
  breaking the parent plan's freeze for nothing.
- (b) is **sufficient for everything that is true here**: the difficulty bound is provably
  *equivalent, up to a factor of 4*, to a branch-length bound (Phase 3), and the length bound is a
  statement `MintBound.lean` can make about the engine on its own.

This decision is recorded in-source in Phase 1 by replacing the rationale at MintBound.lean:3907-3913,
which currently attributes the difficulty to the `private` markers.

## Goals & Non-Goals

**Goals**:
- Settle (a) vs (b) in-source with evidence, and retire the visibility-based explanation.
- Land the engine-free difficulty toolkit: length lower bound, sub-permutation monotonicity, and a
  concrete `difficultyCeiling U L` with `confined + length ≤ L → difficulty ≤ ceiling`.
- Land the equivalence: `DifficultyBounded fc U D` holds iff the engine's successors of
  `U`-confined branches have bounded **length** (both directions, up to the factor 4).
- Refute `DifficultyBounded` as literally stated: no `D` works at any `U` containing a formula the
  engine fires on.
- Land a sibling terminus stated at the length bound, with `D` read off as `difficultyCeiling U L`,
  leaving the existing terminus untouched.
- Every new declaration sorry-free, axiom-free, `lake build` green.

**Non-Goals**:
- Editing `Saturation.lean`, `Fuel.lean`, or `Tableau.lean` (see Constraints).
- Proving the rule-local `StepLengthGrowth` obligation isolated in Phase 4. Finding 4 shows this is
  a ~25-arm case analysis over `applyRule`; it is a task-sized chunk of its own and is explicitly
  carved out, with its full obligation map recorded in-source so a follow-up can execute it.
- Discharging the other three residuals (`UniverseClosed`, `MintPaysForTime`,
  `PostBlockingSettles`).
- Any change to the landed `buildTableauAt_isSome_of_budget` /
  `buildTableauAt_isSome_at_seed` statements or proofs.

## Constraints (read before starting)

- **Do not edit** `FormalSystem/Metalogic/Decidability/Saturation.lean`,
  `.../Verified/Termination/Fuel.lean`, `.../Tableau.lean`. Reasoning *about* their contents from
  `MintBound.lean` is expected and is not an edit.
- **The only file this plan writes is**
  `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`.
- **Do-not-re-attempt register compliance** (MintBound.lean:4455-4510, eight entries). Read it
  first. This plan attempts none of them, and the near misses are named so a reader can check:
  entry 3 (a `.splitOrdered` cardinality twin) — not attempted; the ordered arms are used only via
  the *length* fact `length ≤ b.length`, which is a different quantity and is read off the arm
  shapes, not proved as a cardinality twin. Entry 6 (a lower bound on
  `(b.identifyTime t₂ t₁).toFinset.card`) — not attempted; only the upper bound
  `length ≤ b.length` is used. Entry 7 (`OrdTimesLeMaxTime` preservation) — not touched;
  `RunInvariant` is consumed as-is by projection. Entries 1, 2, 4, 5, 8 are untouched.
- **No task-number citations in `MintBound.lean`.** `.claude/rules/no-task-references-in-deliverables.md`
  applies: cite declaration names, file:line anchors, and refuting witnesses, matching the register's
  own house style. Never "task 431".
- **Prefer module-scoped builds in-phase**:
  `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound`. Full `lake build`
  is Phase 7 only.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The refutation's engine reduction on a duplicate-padded branch resists (`blockedTimes` folds over the branch) | M | M | Pre-declared fallback in Phase 6: land the witness at a concrete `D` via `decide`, record the general argument as prose, close the phase `[COMPLETED WITH EXCLUSIONS]` with the required Reasoned Exclusions table. The refutation is off the critical path for Phases 3-5. |
| `difficultyCeiling U L` is astronomically large, tempting a "cleaner" tighter definition mid-proof | M | M | It only ever appears as a `Nat` argument to `mintAwareFuel`; size is irrelevant to correctness. `.claude/rules/plan-compliance.md` forbids substituting a different construction mid-implementation — escalate instead. |
| The generic-counter unification trick fails in the real file (different instance path than the probe) | H | L | Probe was run against `import FormalSystem.Metalogic.Decidability.Saturation` and was green. Phase 1 re-lands the lower bound first, so failure surfaces in the cheapest phase, before Phases 2-5 depend on it. |
| Sub-permutation (`List.Subperm`) API friction on `Finset.toList`/`List.replicate` | M | M | Phase 2 is allowed to route through `Multiset`/`List.Sublist` instead if `Subperm` lemmas are thin; the *statement* of `estimateBranchDifficulty_le_ceiling` is fixed by the plan, the internal route is not. |
| Accidental non-additive edit breaking a landed proof | H | L | All new declarations are appended in their own sections; the only in-place edits are two docstrings. Phase 7 runs the full build. |
| Phases in the same wave both write `MintBound.lean` | M | H | Waves express logical independence only. **All phases write one file — execute them sequentially.** Do not dispatch a wave in parallel. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 6 | 1 |
| 3 | 3 | 2 |
| 4 | 4, 5 | 3 |
| 5 | 7 | 4, 5, 6 |

Phases within the same wave are logically independent, but **every phase edits the same file
(`MintBound.lean`), so they must be executed sequentially, not dispatched in parallel.**

---

### Phase 1: The scope decision, and the lemma that settles it [COMPLETED]

- **Goal:** Record decision (b) in-source with evidence, and land the one lemma that proves the
  visibility framing wrong.
- **Tasks:**
  - [x] Open a new section in `MintBound.lean` (after the residual definitions, before
        `budgetPotential_step_unordered`) for the difficulty toolkit. *(completed)*
  - [x] Land `estimateBranchDifficulty_length_le (b : Branch) : 1 + b.length / 4 ≤ estimateBranchDifficulty b`,
        proved by `simp only [estimateBranchDifficulty]; omega`. (Probe-verified green in planning.)
        *(completed; the contrapositive `length_le_of_estimateBranchDifficulty_le` added alongside,
        since Phases 3 and 6 both consume that direction)*
  - [x] Docstring it with *why* it is available: unfolding crosses the file boundary and leaves the
        two counters as opaque non-negative terms, so `private` never blocked a bound in this
        direction. *(completed)*
  - [x] Rewrite the `DifficultyBounded` docstring rationale (MintBound.lean:3907-3913). Replace
        "cannot be stated from this file" with the real obstruction: `estimateBranchDifficulty` sums
        over the branch **list** and no invariant bounds a branch's length or asserts `Nodup`
        (cite `SignedFormula.lean:240`, `Tableau.lean:2233-2239`, `BranchOrder.lean:281-283`).
        State that widening `temporalCount`/`modalCount` would not help, so `Saturation.lean` is
        deliberately left untouched.
  - [x] Apply the same correction to the forward-reference at MintBound.lean:3553 if it repeats the
        visibility claim. *(completed; `grep -n private` confirmed exactly the two sites the Scope
        Hypothesis predicted — 3552-3553 and 3911 — and both were corrected)*
- **Timing:** 1 hour
- **Depends on:** none
- **Verification Tier:** local
- **Scope Hypothesis:** "two docstring sites repeat the visibility rationale (3553 and 3907-3913)".
  Confirm at implementation time with `grep -n "private" MintBound.lean` restricted to the
  difficulty discussion, and correct every site found rather than exactly two.
- **Files to modify:**
  - `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` — one new lemma, two
    docstring repairs.
- **Verification:**
  - `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound` green.
  - `lean_verify` on the new lemma: no `sorryAx`, no new axioms.

---

### Phase 2: The engine-free difficulty toolkit [COMPLETED]

- **Goal:** Land the upper-bound machinery: monotonicity under sub-permutation, and a concrete
  ceiling for confined branches of bounded length. No engine reasoning in this phase.
- **Tasks:**
  - [x] Generic counter lemma: for `f : Formula → Nat` and `l₁ l₂ : Branch` with `l₁.Subperm l₂`,
        `l₁.foldl (fun acc sf => acc + f sf.formula) 0 ≤ l₂.foldl (fun acc sf => acc + f sf.formula) 0`.
        *(completed as `branchCount_le_of_subperm`)*
  - [x] Generic shape lemma with both counters universally quantified, mirroring the unfolded form
        of `estimateBranchDifficulty` (planning probe `gen_mono` is the exact template).
        *(completed as `difficultyShape_le_of_subperm`; the unification trick was green in the real
        file exactly as the probe predicted)*
  - [x] `estimateBranchDifficulty_le_of_subperm {b₁ b₂ : Branch} (h : b₁.Subperm b₂) : estimateBranchDifficulty b₁ ≤ estimateBranchDifficulty b₂`,
        proved by `simp only [estimateBranchDifficulty]; exact gen_shape _ _ …` so unification
        supplies the private counters. *(completed)*
  - [x] `def difficultyCeiling (U : Finset SignedFormula) (L : Nat) : Nat` — the difficulty of the
        canonical worst branch of length `≤ L` drawn from `U`, e.g.
        `estimateBranchDifficulty (U.toList.flatMap (fun x => List.replicate L x))`.
        *(completed, at exactly the plan's suggested body, factored through a named
        `canonicalBranch U L`. **deviation: altered** — it must be `noncomputable def`, because
        `Finset.toList` is noncomputable. This forced the second deviation below.)*
  - [x] `estimateBranchDifficulty_le_ceiling : (∀ x ∈ b, x ∈ U) → b.length ≤ L → estimateBranchDifficulty b ≤ difficultyCeiling U L`,
        by exhibiting `b.Subperm` of the canonical list. *(completed; the `Subperm` step is
        `subperm_canonicalBranch`, via `List.subperm_ext_iff`)*
  - [x] `difficultyCeiling_mono` in `L` (needed by Phase 4/5 to absorb slack). *(completed)*
- **Timing:** 2 hours
- **Depends on:** 1
- **Verification Tier:** local
- **Scope Hypothesis:** the `Subperm` route is the intended one; if Mathlib's `List.Subperm` API is
  thin at `Finset.toList`/`List.replicate`, an equivalent `Multiset`-based or `List.Sublist`-based
  route is permitted. Confirm at implementation time by locating `List.Subperm.length_le` and a
  count/replicate membership lemma; the *statements* of `estimateBranchDifficulty_le_of_subperm` and
  `estimateBranchDifficulty_le_ceiling` are fixed and may not change.
- **Files to modify:**
  - `.../MintBound.lean` — new lemmas and one new `def`, in the Phase 1 section.
- **Verification:**
  - Module build green; `lean_verify` sorry-free and axiom-free on each new declaration.
  - Sanity `#eval` (not committed as a test) that `difficultyCeiling` on a two-element `U` and small
    `L` produces a finite number. *(deviation: altered — `difficultyCeiling` is `noncomputable`, so
    it cannot be `#eval`-ed at all. The equivalent check was run on the canonical list given as an
    explicit literal: at `U = {T□p, F(p U q)}` and `L = 3` the canonical branch has length 6 and
    difficulty 17. Finite, as required.)*

---

### Phase 3: The equivalence — difficulty bound iff length bound [COMPLETED]

- **Goal:** Reduce the difficulty residual to a pure branch-length residual, in both directions, so
  the residual's real content is exposed once and for all.
- **Tasks:**
  - [x] `def StepLengthBounded (fc) (U : Finset SignedFormula) (L : Nat) : Prop` — mirroring
        `DifficultyBounded`'s two conjuncts exactly (unordered successors, and `.splitOrdered` arms
        via the `bs`-equation form), with `nb.length ≤ L` / `p.1.length ≤ L` as the conclusions.
        *(completed)*
  - [x] `difficultyBounded_of_stepLengthBounded : StepLengthBounded fc U L → UniverseClosed fc U → DifficultyBounded fc U (difficultyCeiling U L)`
        — successors are `U`-confined by `UniverseClosed`, length-bounded by hypothesis, so Phase 2's
        ceiling applies. Confirm which conjunct of `UniverseClosed` covers the `.splitOrdered` arms
        and, if it does not, take the arm confinement as an explicit extra hypothesis rather than
        inventing one. *(completed; **no extra hypothesis was needed** — the Scope Hypothesis is
        confirmed: `expandOnceUnblocked_splitOrdered_shape` gives arms `(b, _)`, `(b, _)`,
        `(b.identifyTime t₂ t₁, _)`, so arms 1-2 use the incoming confinement and arm 3 uses
        `UniverseClosed`'s second conjunct exactly as stated)*
  - [x] `stepLengthBounded_of_difficultyBounded : DifficultyBounded fc U D → StepLengthBounded fc U (4 * D)`
        — from Phase 1's lower bound. *(completed)*
  - [x] Docstring the pair as *the* answer to the residual: the coefficient `D` the fuel allocation
        consumes is, up to a factor of 4, a bound on branch **length**, and nothing about formula
        complexity. *(completed)*
- **Timing:** 1.5 hours
- **Depends on:** 2
- **Verification Tier:** local
- **Scope Hypothesis:** "`UniverseClosed`'s first conjunct covers unordered successors and its second
  covers the identification relabelling, which between them confine every `.splitOrdered` arm".
  Confirm by reading MintBound.lean:3901-3905 against
  `expandOnceUnblocked_splitOrdered_shape` (MintBound.lean:788) before writing the proof; if the
  ordered arms are not covered, add the confinement as a named hypothesis on this theorem and say so
  in its docstring — do not weaken `StepLengthBounded`.
- **Files to modify:**
  - `.../MintBound.lean` — one new `def`, two new theorems.
- **Verification:**
  - Module build green; `lean_verify` sorry-free and axiom-free on all three.

---

### Phase 4: The satisfiable form, and the rule-local obligation it isolates [COMPLETED]

- **Goal:** State the *length-hypothesis* form of the residual — the form that is actually
  satisfiable — and reduce its discharge to one finitely-checkable, rule-local inequality, with the
  obligation map recorded in-source.
- **Tasks:**
  - [x] `def StepLengthGrowth (fc) (c : Nat) : Prop` — `∀ b ord tr`, every unordered successor and
        every `.splitOrdered` arm satisfies `length ≤ c * b.length + c`, under `RunInvariant b ord`
        (needed for the four ordering-driven arms, whose emitted list is bounded via
        `OrdTimesKnown`, not via `b` directly). *(completed)*
  - [x] `def DifficultyBoundedAt (fc) (U) (L D : Nat) : Prop` — `DifficultyBounded`'s two conjuncts
        with `RunInvariant b ord` and `b.length ≤ L` added as hypotheses. Mirror `MintPaysForTime`'s
        hypothesis order (MintBound.lean:3945-3948) so the family reads uniformly. *(completed)*
  - [x] `difficultyBoundedAt_ceiling : StepLengthGrowth fc c → UniverseClosed fc U → DifficultyBoundedAt fc U L (difficultyCeiling U (c * L + c))`.
  - [x] Docstring `StepLengthGrowth` with the **full obligation map** so a follow-up can execute it
        without redoing the reconnaissance: the constant arms (`.andPos`/`.orNeg`/`.impNeg` = 2,
        `.negPos`/`.negNeg` = 1, `.boxTemporal` ≤ 2, `.serialityRule` ≤ 2, the six `prior*`/`z1`/`sep`
        arms = 1); the branch-mapped arms (`.boxPos` Tableau.lean:671, `.diamondNeg` 731, `.boxNeg`
        679, `.diamondPos` 704, `.allFutureNeg` 760, `.allPastNeg` 800, `.someFuturePos` 831,
        `.somePastPos` 875, `.densityRule` 1338, and the `.branching` arms of `.untlPos` 921,
        `.sncePos` 968, `.untlNeg` 1013, `.snceNeg` 1144); the four ordering-driven arms
        (`.allFuturePos` 751, `.allPastPos` 791, `.someFutureNeg` 863, `.somePastNeg` 907) with the
        note that `TimeOrdering.futureOf` is `eraseDups`-ed (SignedFormula.lean:776) so `OrdTimesKnown`
        bounds its length by `b`'s known-time count; and `.branchingOrdered`'s three arms, all
        `≤ b.length` (Tableau.lean:1513-1519), the one already-benign family.
        *(completed. **deviation: altered** — the map was re-derived from `applyRule` as the Scope
        Hypothesis instructed, and three of the plan's figures were wrong and are corrected
        in-source: (i) `applyRule` has **36** arms, not ~25; (ii) two arms the plan's map omitted
        are present and constant — `.orderTrichotomy` 1282 (three `.branching` arms of length 2)
        and `.denseIndicatorClosure` 1331 (`.linear []`); (iii) `c = 3` is **too small**. The
        `witness :: gProps ++ fNegProps ++ modalProps` arms carry a fourth branch-length term,
        because `modalProps` is `boxDiamondPersistence` (Tableau.lean:434-442) and is itself two
        branch `filterMap`s concatenated; the `.branching` arms of `.untlPos`/`.sncePos`/`.untlNeg`/
        `.snceNeg` reach `2 + 4 * b.length`. **`c = 5` is the corrected constant**, and the
        statements are parametric in `c` so widening cost nothing. `.z1Rule` is at 1408, not 1409.
        The 13 branch-mapped / 4 ordering-driven / 6 `prior*`-`z1`-`sep` counts all checked out
        exactly as the plan predicted.)*
  - [x] State explicitly in the docstring that `StepLengthGrowth` is a **rule-local, finitely-many-cases**
        obligation — categorically unlike the residual it replaces, which could not be stated in
        terms of formula complexity at all — and that it is left unproved here by scope decision, not
        by discovery of an obstruction. *(completed)*
- **Timing:** 2 hours
- **Depends on:** 3
- **Verification Tier:** local
- **Scope Hypothesis:** `c = 3` is a hypothesis, from "worst emitted arm is `witness :: boxProps ++ diaProps`
  with each `filterMap` over a branch filter, i.e. `≤ 1 + 2 * b.length`, so
  `nb.length ≤ 3 * b.length + 1`". The implementer confirms by re-reading the four cited worst-case
  arms and **may widen `c`** (the statements are parametric in `c`, so widening costs nothing). The
  "13 branch-mapped arms" and "4 ordering-driven arms" counts are likewise hypotheses to be
  re-derived from `applyRule` before the docstring is written — correct the docstring to whatever the
  file actually contains.
- **Files to modify:**
  - `.../MintBound.lean` — two new `def`s, one new theorem, one substantial docstring.
- **Verification:**
  - Module build green; `lean_verify` sorry-free and axiom-free.
  - The docstring's cited line numbers each check out against the current `Tableau.lean`.

---

### Phase 5: The sibling terminus, at the length budget [COMPLETED]

- **Goal:** A caller-facing totality statement whose difficulty hypothesis is a branch-length bound
  and whose `D` is read off, with the landed terminus untouched.
- **Tasks:**
  - [x] `buildTableauAt_isSome_of_lengthBudget` — `buildTableauAt_isSome_of_budget`'s statement with
        `hD : DifficultyBounded fc U D` replaced by `hL : StepLengthBounded fc U L` and every `D`
        instantiated at `difficultyCeiling U L`. Prove it by `exact buildTableauAt_isSome_of_budget …
        (difficultyBounded_of_stepLengthBounded hL hUcl) …` — no new induction, no change to
        `stepDecreases_budgetPotential`. *(completed; the Scope Hypothesis is confirmed — every
        `D` flows through `mintAwareFuel`'s `D` argument, all inside `MintBound.lean`, so the
        sibling is a single application of the landed theorem and no `Fuel.lean` lemma needed a
        new form)*
  - [x] The seed-level sibling of `buildTableauAt_isSome_at_seed`, same substitution. *(completed
        as `buildTableauAt_isSome_at_seed_lengthBudget`)*
  - [x] Docstring both: what changed is the *shape* of one residual, from an unstatable
        formula-complexity bound to a branch-length bound; the other three residuals are unchanged
        and still named. *(completed)*
  - [x] Add a pointer from the landed terminus's residual paragraph (MintBound.lean:4410-4414) to the
        sibling, and to Phase 6's refutation once it lands (leave the cross-reference for Phase 7 if
        Phase 6 has not run yet). *(completed; the paragraph now names both the sibling and
        `difficultyBounded_multiplicity_false`, which Phase 6 lands next)*
- **Timing:** 2 hours
- **Depends on:** 3
- **Verification Tier:** local
- **Scope Hypothesis:** "the substitution is purely definitional — every `D` occurrence in the
  terminus chain flows through `mintAwareFuel`'s `D` argument, all inside `MintBound.lean`
  (`stepDecreases_budgetPotential` 4111, `expandBranchWithFuel_isSome_of_budget` 4221, terminus
  4416), so no `Fuel.lean` lemma needs a new form." Confirm by `grep -n "D" ` across those three
  declarations before starting; if a `Fuel.lean` statement turns out to need a different `D` shape,
  **stop and mark the phase `[BLOCKED]`** rather than editing `Fuel.lean`.
- **Files to modify:**
  - `.../MintBound.lean` — two new theorems, docstring pointer.
- **Verification:**
  - Module build green; `lean_verify` sorry-free and axiom-free on both siblings.
  - The landed `buildTableauAt_isSome_of_budget` and `_at_seed` are unchanged apart from added
    docstring prose (`git diff` shows no change inside either proof term).

---

### Phase 6: Refute the residual as literally stated [COMPLETED]

- **Goal:** A refuting witness in the register's house style: at any `U` containing a formula the
  engine fires on, **no** `D` satisfies `DifficultyBounded fc U D`.
- **Tasks:**
  - [x] Choose the witness: `sf₀ := neg (imp (atom p) (atom q))` at one label, `U₀ := {sf₀, pos (atom p) …, neg (atom q) …}`
        closed enough for the one step, and `b := List.replicate n sf₀`. *(completed exactly as
        specified: `multWitness`, `multUniverse`, `multBranch n`)*
  - [x] Prove the step fires generically in `n`: `expandOnceUnblocked (List.replicate n sf₀) …` is
        `.extended ([T p, F q] ++ b)`. The reductions needed are duplicate-insensitive:
        `Branch.knownTimes` and `timeType` go through `eraseDups`/`Finset` (SignedFormula.lean:350,
        640), so `blockedTimes` (Tableau.lean:2064) agrees with its value at `[sf₀]`;
        `findUnexpandedUnblockedWith` short-circuits on the head; `.impNeg` (Tableau.lean:659) emits
        exactly `2` formulas and passes `findApplicableRule`'s `fs.all branch.contains` guard
        (Tableau.lean:1908-1911). *(completed generically in `n` **and** in `fc` — the pre-declared
        `decide` fallback was NOT needed. The reduction is even cleaner than the plan anticipated:
        `blockedTimes b TimeOrdering.empty fc tr = []` holds for an *arbitrary* branch, frame class
        and tracker, because `blockCandidates` is empty at the empty ordering — so no `knownTimes`
        or `timeType` reasoning about the padded branch was required at all. The remaining work was
        showing `.impNeg` is the first applicable rule in `allRulesForFC fc`, which needs only that
        the three Dedekind rules and `.negPos`/`.negNeg` are inapplicable to a `.neg`-signed
        implication between atoms.)*
  - [x] `theorem difficultyBounded_multiplicity_false (D : Nat) : ¬ DifficultyBounded fc U₀ D` —
        instantiate at `n := 4 * (D + 1)` and close with Phase 1's lower bound. *(completed at
        exactly `n = 4 * D + 4`)*
  - [x] Docstring: this is why the landed terminus's `hD` is unsatisfiable at any useful `U`, hence
        why the Phase 5 sibling is a repair rather than a convenience. *(completed)*
- **Timing:** 2 hours
- **Depends on:** 1
- **Verification Tier:** local
- **Commit Mode:** per-substep
- **Scope Hypothesis:** "the padded-branch reduction is provable generically in `n`". Confirm early
  with `#eval expandOnceUnblocked (List.replicate 5 sf₀) …` and `lean_multi_attempt` on the
  `blockedTimes` step **before** investing in the general proof.
  **Pre-declared fallback** (use only after the generic reduction has been genuinely attempted): land
  `difficultyBounded_multiplicity_false_at (D := 3)` (and one larger `D`) by `decide` on a concrete
  padded branch, record the general argument as register prose, and close the phase
  `[COMPLETED WITH EXCLUSIONS]` with the required `#### Reasoned Exclusions` table — `Item` = the
  universally-quantified-in-`D` form, `Reason` = engine reduction generic in `n` not achieved within
  the phase, `Evidence` = the concrete `decide` witnesses plus the goal state reached. Do **not**
  use `native_decide`.
- **Files to modify:**
  - `.../MintBound.lean` — witness definitions and one refutation theorem.
- **Verification:**
  - Module build green; `lean_verify` on the refutation: sorry-free, axiom-free (in particular no
    `Lean.ofReduceBool`, which `native_decide` would introduce).

---

### Phase 7: Register entry, cross-references, and the full gate [NOT STARTED]

- **Goal:** Close the loop: the register records what must not be re-attempted, every
  cross-reference resolves, and the whole project builds.
- **Tasks:**
  - [ ] Add register entry 9 at MintBound.lean:4455-4510: "**`DifficultyBounded fc U D` at any `D`,
        for a `U` the engine fires on.**" — refuted by `difficultyBounded_multiplicity_false` (or, on
        the Phase 6 fallback, by the concrete witnesses plus the recorded argument), with the
        one-line cause: difficulty sums over the branch **list**, confinement bounds only the
        `toFinset`, and no `Nodup` invariant exists. Note that widening `temporalCount`/`modalCount`
        does not revive it, so a reader who reaches for `Saturation.lean` has already been here.
  - [ ] Update the terminus's "The residuals, stated once" paragraph (MintBound.lean:4410-4414) to
        point at the Phase 5 sibling and the register entry.
  - [ ] Verify every new docstring's file:line citation still resolves.
  - [ ] Full `lake build` green.
  - [ ] `lean_verify` sweep over every declaration added by Phases 1-6: sorry-free, axiom-free.
  - [ ] Write `summaries/01_discharge-difficultybounded-residual-summary.md`.
- **Timing:** 1 hour
- **Depends on:** 4, 5, 6
- **Verification Tier:** full
- **Scope Hypothesis:** "the register has exactly eight entries, so the new one is 9." Confirm by
  re-reading the register head before numbering.
- **Files to modify:**
  - `.../MintBound.lean` — register entry, docstring cross-references.
  - `specs/431_discharge_difficultybounded_residual/summaries/01_discharge-difficultybounded-residual-summary.md`
- **Verification:**
  - `lake build` green from a clean LSP restart.
  - `git diff --stat` shows `MintBound.lean` as the only modified `.lean` file.

---

## Testing & Validation

- [ ] `lake build` green (Phase 7), and module-scoped builds green at each earlier phase.
- [ ] `lean_verify` on each new declaration: no `sorryAx`, no `Lean.ofReduceBool`, no new axioms.
- [ ] `grep -c "sorry" MintBound.lean` unchanged from its pre-task value.
- [ ] `git diff --stat` confirms `Saturation.lean`, `Fuel.lean`, `Tableau.lean` untouched; re-check
      their md5s against the parent plan's pins.
- [ ] The landed `buildTableauAt_isSome_of_budget` / `_at_seed` proof terms are byte-unchanged.
- [ ] No task-number citation anywhere in `MintBound.lean`
      (`bash .claude/scripts/check-task-references.sh`).
- [ ] Every file:line citation in every new docstring resolves to what it claims.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` — additive:
  the difficulty toolkit (`estimateBranchDifficulty_length_le`,
  `estimateBranchDifficulty_le_of_subperm`, `difficultyCeiling`,
  `estimateBranchDifficulty_le_ceiling`, `difficultyCeiling_mono`), the equivalence
  (`StepLengthBounded`, `difficultyBounded_of_stepLengthBounded`,
  `stepLengthBounded_of_difficultyBounded`), the satisfiable form (`StepLengthGrowth`,
  `DifficultyBoundedAt`, `difficultyBoundedAt_ceiling`), the sibling terminus
  (`buildTableauAt_isSome_of_lengthBudget` and its seed form), the refutation
  (`difficultyBounded_multiplicity_false`), register entry 9, and the two docstring repairs.
- `specs/431_discharge_difficultybounded_residual/plans/01_discharge-difficultybounded-residual.md`
  (this file).
- `specs/431_discharge_difficultybounded_residual/summaries/01_discharge-difficultybounded-residual-summary.md`.

## Follow-Up (not in scope, recommend `/spawn`)

Proving `StepLengthGrowth fc c` for a concrete `c` — a ~25-arm case analysis over `applyRule`, with
the four ordering-driven arms routed through `OrdTimesKnown`. Phase 4 records the complete obligation
map in-source, so the follow-up needs no fresh reconnaissance. Landing it turns
`difficultyBoundedAt_ceiling` into an unconditional discharge of the satisfiable form of the
residual, which is the furthest this residual can be taken.

## Rollback/Contingency

- Every phase is additive to a single file. Revert with
  `git checkout HEAD -- FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`
  after taking a snapshot (`bash .claude/scripts/git-snapshot.sh 431`) if the tree is dirty — see
  `.claude/rules/git-workflow.md`'s "No Destructive Git on Uncommitted Work".
- Because commits are per-green-substep, any phase can be abandoned without losing earlier phases:
  Phases 1-3 stand alone as a completed result (the toolkit plus the equivalence) even if Phases 4-6
  do not land.
- If Phase 5's substitution turns out to require a `Fuel.lean` change, mark it `[BLOCKED]` and stop.
  Editing `Fuel.lean` is out of scope and would break the parent plan's freeze; that is a decision
  for a new task, not a mid-phase deviation.
