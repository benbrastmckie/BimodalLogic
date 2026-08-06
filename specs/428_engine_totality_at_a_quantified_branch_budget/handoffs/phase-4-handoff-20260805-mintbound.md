# Handoff — plan 03, after Phase 7; Phase 4 in progress

**Plan**: `specs/428_engine_totality_at_a_quantified_branch_budget/plans/03_mint-bound-irreflexivity-totality.md`
**Repo state**: green. `lake build FormalSystem.Metalogic.Decidability` succeeds. Zero `sorry`,
zero `axiom`, zero `NoSplit` in `MintBound.lean`.

## Immediate next action

Finish **Phase 4** (`expandOnceUnblocked_irreflOrd` + `OrdTimesLeMaxTime` at the branching
shapes). Sub-step 4.1 is already landed and committed; the phase's own progress notes in the plan
file carry the full continuation detail, including a correction to the phase's task list and the
statement-shape guidance below. Read those notes first — they are the resume point.

After Phase 4: Phase 8 (depends on 6, 7 — both landed — and consumes Phase 4's `IrreflOrd`), then
9, 10, …

## Phases landed this dispatch

| Phase | Status | Content |
|---|---|---|
| 1 | COMPLETED | New module + build wiring; `rho`, `rhoSF`, `IrreflOrd`, `irreflOrd_identifyTime`, `irreflOrd_addFuture`, the **new** `irreflOrd_addPast`, `incomparableB_of_firstIncomparablePair`, and the refuting counterexample record |
| 2 | COMPLETED | `applyRule_irreflOrd_of_ne_density` — the eight non-density mint sites |
| 3 | COMPLETED | `densityRule` **discharged** (the `[BLOCKED]` clause did not fire); `OrdTimesLeMaxTime`, `applyRule_irreflOrd` (unrestricted), `applyRule_ordTimes_nonbranching` |
| 5 | COMPLETED | The twelve-lemma reachability transport stack |
| 6 | COMPLETED | Claim (i): `witnessPresent_identifyTime`, `arm3_preserves_witness` |
| 7 | COMPLETED | Claim (ii): `applyRule_branchingOrdered_rule`, `expandOnceUnblocked_splitOrdered_{shape,no_deletion}` |
| 4 | IN PROGRESS | Sub-step 4.1 landed: the three pick bridges carrying the ordering |

Execution followed the plan's **dependency-wave** order, not strict numeric order: 5 before 3
(Phase 3's own task list anticipates consuming Phase 5's `mem_directFutureOf_iff'`), and 6, 7
before 4 (Phase 6 is wave 3, Phase 4 is wave 4). No phase content was changed.

## Headline result

**The plan's single highest-risk item, R1 / Phase 3's `densityRule` second edge, discharged.**
`applyRule_irreflOrd` is landed with **no rule excluded and no frame-class restriction**.
`densityRule` was not deleted from `denseRules`, `IrreflOrd` was not weakened, and
`OrdTimesLeMaxTime` is a hypothesis Phases 3-4 discharge as a run invariant — not an admitted
assumption on the terminus.

The bridge from "reachable" to "appears in a constraint" did **not** need the converse of
`mem_futureOf_of_mem_constraints`. `bfsClosure_sound` carries a `1 ≤ n` lower bound on path
length, so any member of `ord.futureOf s` is reached by a path with a *last* edge; that subsumes
the plan's two sub-case split, including the cyclic case.

## Hard constraints — all holding

- `Saturation.lean` md5 `ae47004e06e77f2846cc3e1dfa408382`, `Fuel.lean` md5
  `8a395bd7117a682c1f8302a2ac5f0f1f`, `Tableau.lean` md5 `cfd82332c8e400ac97ab709ece5dfb4a` —
  all unchanged from task start. `git diff b2c5b3d98..HEAD -- <those three>` is empty.
- Files changed under `FormalSystem/`: exactly `Decidability.lean` (one import line) and the new
  `Verified/Termination/MintBound.lean`. Exactly what the plan declares.
- No `NoSplit`, no `sorry`, no `axiom`, no vacuous placeholder, no task-number citation in any
  `.lean` file. The one vacuous hit and the 71 task-ref hits under `FormalSystem/` are both
  **pre-existing** (identical counts at `b2c5b3d98`) and in files this task never touched.
- Every landed declaration `lean_verify`s to a subset of `[propext, Classical.choice, Quot.sound]`.

## Reusable findings for the next dispatch

1. **Keep obligations on the goal side.** A hypothesis `applyRule … = (.linear fs, ord')` cannot
   be split in step with the goal: `split at h` fails to reach every `dite` once the equation is
   oriented, leaving an unsplit `Decidable.rec`. Phase 3's
   `nonBranchingResultBranch : Branch → RuleResult → Option Branch` is the working shape — the
   rule case analysis then reduces result and ordering together.
2. **`contradiction` is load-bearing in every `applyRule` induction.** `applyRule` is one `match`
   over three discriminants with overlapping patterns, so `split` emits *every* rule's arm inside
   each rule's case, each carrying a false discriminant equation.
3. **`first` does not backtrack out of a failing `by` block.** Order alternatives so those that
   fail by plain tactic failure (`subst`, `obtain`) come before any containing `(by simp)`.
4. **`omega` is unusable on `TimeIndex`** despite `abbrev TimeIndex := Nat` — it reports "no
   usable constraints". Use `Nat.ne_of_gt` / `Nat.lt_succ_of_le`.
5. **`Branch` is an `abbrev` for `List SignedFormula`**, so `(fs ++ b).maxTime` resolves to
   `List.maxTime` and fails; write `Branch.maxTime (fs ++ b)`.
6. **Several `Fuel.lean` / `Tableau.lean` helpers are `private`** and must be re-proved locally:
   `le_foldl_max`, `mem_le_foldl_max` (done: `maxTime_le_of_forall`, `maxTime_mono`,
   `maxTime_le_append`), and `pick_extended` / `pick_split` / `pick_splitOrdered` (the
   `.splitOrdered` one is done as `pick_splitOrdered'`; `.extended` / `.split` still needed).
7. **`maxHeartbeats 4000000` is required** for the `applyRule` rule inductions. Whole-module
   build is ~26s wall / ~73s user from a warm `Fuel.lean`. It was never raised above the scratch
   file's figure.

## Grounding corrections recorded (not absorbed)

- Plan Phase 2's site labels at `:924/:971` and `:1069/:1168` are swapped relative to the source
  (`:924` is `untlPos`, `:971` is `sncePos`, `:1069` is `untlNeg` active, `:1168` is `snceNeg`
  active). The set of nine sites and the four-`addPast` split are unchanged.
- Plan Phase 4 cites `pick_result_mem` as supplying `sf ∈ b`; it **consumes** that and concludes
  about the formula stock. The real source is `List.mem_of_find?_eq_some` on each pick stage.
- `TableauRule` has **36** constructors, not the plan's estimated ~32. No effect on outcome.
