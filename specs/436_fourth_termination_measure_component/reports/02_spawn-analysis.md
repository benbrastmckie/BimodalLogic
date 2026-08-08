# Blocker Analysis: Task #436

**Parent Task**: #436 - fourth_termination_measure_component
**Generated**: 2026-08-08
**Blocker**: The user's roadmap item 2 and `/spawn` prompt both instruct: stop attacking the
missing fourth termination-measure component from the *measure* side (every shape tried there —
including the just-refuted `selfGuardPotential` — inherits a σ-hit obligation that is false) and
instead attack the *identification-plus-`maxTime`* mechanism that produces that false obligation
in the first place.

## Root Cause

**What `identifyTime` does to `maxTime`, precisely.** Three declarations, all in
`FormalSystem/Metalogic/Decidability/SignedFormula.lean`:

- `Branch.knownTimes` (`SignedFormula.lean:349-350`): `(b.map (·.label.time)).eraseDups` — the
  set of times *currently* carried by some formula on the branch.
- `Branch.identifyTime b src tgt` (`SignedFormula.lean:364-367`): relabels every formula at time
  `src` to `tgt`, then `eraseDups`. After this, `src` is gone from the branch entirely unless some
  other formula independently already sat at `tgt` — the docstring says so explicitly: "`src`
  disappears from `knownTimes`... a partial order cannot be made total by adding edges alone if
  two of its elements are meant to be equal rather than ordered."
- `Branch.maxTime` (`SignedFormula.lean:373-374`) = `b.foldl (fun acc sf => max acc sf.label.time)
  0` and `Branch.nextTime` (`SignedFormula.lean:380-381`) = `maxTime + 1`. Both are recomputed
  from the *current, live* branch on every call — there is no memory of any larger time value the
  branch carried before an identification step removed it.

The companion ordering-side function, `TimeOrdering.identifyTime` (`SignedFormula.lean:705-710`),
does the same substitution on `ord.constraints`, dropping any constraint that collapses to
`(t, t)`.

**The consequence, decided.** `nextTime_reissues_retired_time` (`MintBound.lean:7321`) exhibits a
run where `firstIncomparablePair` selects and merges away the branch's *current maximum* time
(`2`), `Branch.maxTime` drops with it, and the post-identification `Branch.nextTime` is exactly
the retired value `2` — a fresh-time mint re-issues an index that used to name a distinct instant.
`reuse_driven_through_engine` (`MintBound.lean:7363`) confirms the live tableau engine actually
drives through this path two `expandOnceUnblocked` steps later, so it is not a hand-assembled
edge case.

**Why this defeats every measure-side candidate.** The accumulated renaming trail `σ` (composed
from `rhoSF src tgt` at each identification) is constructed so that it can *never* land on a
retired source time: `rhoSF_time_ne_src` (`MintBound.lean:7299`) proves
`(rhoSF src tgt sf).label.time ≠ src` for every `sf` whatsoever — this is a statement about the
renaming's construction, not about any particular measure. `mint_not_in_rhoSF_image`
(`MintBound.lean:7307`) is a three-line corollary: nothing minted at a re-issued time can ever lie
in σ's image. Register entry 15 (`MintBound.lean:7866-7880`) establishes this for the
formula-hit form (`mintPotential_lt_of_mint`'s hypothesis); entry 17
(`MintBound.lean:7893-7938`, the result just landed by this task) establishes it again for a
strictly weaker time-hit form (`selfGuardPotential`'s obligation) and shows the weakening escapes
nothing, because `rhoSF_time_ne_src` is already a statement about *times*, not formulas — any
measure component whose decrease is witnessed anywhere on the trigger's label inherits the same
false obligation. **The obstruction is not in what any measure counts; it is that `nextTime`,
as currently defined, can hand out a time index that a live run has already retired, and the
renaming machinery that tracks provenance is — correctly, by construction — blind to that
specific index once it is retired.**

**The user's attack vector.** Roadmap item 2 names this precisely: repair `identifyTime`'s effect
on `maxTime`/`nextTime` bookkeeping so that fresh-time issuance is monotone across the whole run
— i.e. `nextTime` must never again hand out an index that a prior identification step retired —
rather than continuing to search for a measure component that survives reissue. If time issuance
is made monotone, the reuse configuration `nextTime_reissues_retired_time` decides today simply
stops occurring, and the σ-hit obligation `rhoSF_time_ne_src`/`mint_not_in_rhoSF_image` never
gets exercised on a *reused* value in the first place (a genuinely fresh value being outside a
particular finite `U`'s σ-image is a separate, ordinary confinement question, not this
obstruction).

## C9 Entries Checked

All 17 entries were read. The ones bearing directly on this attack vector, and why none of them
forbids it:

| Entry | What it closes | Why this route is unaffected |
|---|---|---|
| 5 | Unconditional (`IrreflOrd`-free) `witnessPresent_identifyTime` | About a *different* predicate's preservation across identification, not about redefining `nextTime` itself |
| 6 | A lower bound on `identifyTime`'s branch cardinality | About bounding survivors from below; this task does not attempt that |
| 7 | `OrdTimesLeMaxTime` across identification — refuted; repair is `OrdTimesKnown` | **Directly adjacent**: `maxTime` dropping under identification already broke one invariant once, and the settled repair (`OrdTimesKnown`, membership-based rather than bound-based) must be re-verified, not re-broken, by any change to how `nextTime`/`maxTime` are computed |
| 10, 11, 12 | `UniverseClosed`/`UniverseClosedAt` clauses, confinement to `U` | A monotone-highwater-mark repair must not silently violate confinement (a "never reissue" mark must still only ever mint times that keep the branch inside `U`'s time projection where `UniverseClosedAt` is assumed) |
| 14 | `MintPaysForTime` as stated; both obvious measure-side repairs | Explicitly the route this task does **not** re-attempt — this task is not a measure component |
| 15 | Time reuse happens; σ-hit hypothesis is false (formula-hit form) | This is the fact this task's repair targets directly: prevent the reuse, not work around its consequence |
| 16 | Unconditional `applyRule_emitted_time_mem` without `OrdTimesKnown` | Same adjacency as entry 7 — `OrdTimesKnown` is a consuming invariant that must survive |
| 17 | `selfGuardPotential`/`MintPaysForTimeAt` (time-hit form) refuted; no label-witnessed fourth component escapes | This task's own predecessor result; explicitly the trigger for attacking from the other side |

No entry addresses *redefining* `nextTime`'s or `TimeOrdering.identifyTime`'s bookkeeping
mechanism itself — every entry above is a consequence of the *current* mechanism. This is a
genuinely new, previously-unclosed route.

## Widened Blast Radius (flagged explicitly, per instructions)

The parent task's additive-only-in-`MintBound.lean` discipline **cannot** hold for this repair.
Grep confirms the following call sites of the two functions in question:

- `Branch.nextTime` is called at **9 sites** in `FormalSystem/Metalogic/Decidability/Tableau.lean`
  (lines 761, 801, 834, 878, 924, 971, 1069, 1168, 1370) — one per `freshTimeRules` member, not
  just the two self-guarded rules this task's predecessor touched.
- `Branch.identifyTime` / `TimeOrdering.identifyTime` are called together at
  `Tableau.lean:1520` (the `.splitOrdered` arm) and consumed extensively in proofs in
  `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean` (e.g. lines 1948, 1959,
  1973, 1991, 2445-2457) that already reason about `identifyTime`'s effect on `knownTimes`
  cardinality and must be re-checked, not necessarily rewritten, against any redefinition.
- `FormalSystem/Metalogic/Decidability/Saturation.lean` does **not** reference `nextTime` or
  `identifyTime` at all (confirmed by grep) — it is out of scope and should stay untouched.
- `FormalSystem/Metalogic/Decidability/SignedFormula.lean` is where the definitions
  (`Branch.knownTimes`, `Branch.identifyTime`, `Branch.maxTime`, `Branch.nextTime`,
  `TimeOrdering.identifyTime`, `TimeOrdering.addFuture`/`addPast`, `TimeOrdering` itself,
  `SignedFormula.lean:349-381, 671-710`) live and would need to change.

## Proposed Decomposition

**One task**, following the precedent set by this task's own plan (a single task, refute-first
gated, sized by phases rather than by task boundary — the same shape task 436 itself used, where
phase 1 decided the question in two phases out of ten planned). A second, separately-numbered
task for the "if the gate passes" build was considered and rejected: the build's specific shape
(which field carries the highwater mark, whether it lives on `TimeOrdering` or a new run-level
counter) is exactly the kind of implementation detail that the Sequentiality criterion says
belongs in the *same* task's later phases, decided by the gate — spawning a second task now would
either duplicate the gate's own design work or commit to an undetermined mechanism prematurely.
If the new task's own `/plan` again produces a gate-refuted negative result, that is itself a
valid, complete deliverable (as it was here), and a further `/spawn` can decompose from its
findings exactly as this one did.

### New Task 1: Repair Time-Index Reuse in Identification-Plus-nextTime Bookkeeping

- **Effort**: 16-22 hours
- **Task Type**: lean4
- **Rationale**: Directly implements the user's named attack vector (roadmap item 2). Targets the
  mechanism — `nextTime`/`maxTime` recomputed from the live branch, blind to identification-retired
  values — that C9 entries 15 and 17 together establish as the actual obstruction, rather than
  continuing to search the measure-component family entry 17 just closed off entirely.
- **Depends on**: None

## Dependency Reasoning

Only one task is proposed, so there is no inter-task dependency graph. The gate-then-build
internal structure is left to the task's own plan (mirroring `01_self-guard-potential.md`'s
Phase 1 refute-first gate), not encoded as a task dependency.

## After Completion

Once the spawned task is complete, resume the parent task #436 with `/implement 436` — though in
practice, given that either outcome (repair lands, or is refuted and register-recorded) changes
the state of the obstruction this task's own plan is blocked on, the more likely next step is a
fresh `/research 436` or a direct continuation from the new task's findings, matching how this
task itself followed from task 434's negative result.

The blocker will be resolved because: if the new task's monotone-nextTime repair lands and holds
under `RunInvariant`/`OrdTimesKnown`/`UniverseClosedAt`, the σ-hit obligation
(`rhoSF_time_ne_src`/`mint_not_in_rhoSF_image`) is never exercised against a *reused* time again,
which removes the specific mechanism that refuted both the formula-hit form (entry 15) and the
time-hit form (entry 17) of every measure-side candidate tried so far — at which point either no
fourth measure component is needed at all (if `mintPotential_lt_of_mint`'s original σ-hit
hypothesis becomes directly dischargeable) or a fourth component becomes provable where the
`selfGuardPotential` shape was not. If the repair itself proves infeasible or unsound against
`OrdTimesKnown`/confinement, that is a decided, register-worthy negative result exactly like this
task's, and closes the identification-side route the same way entry 17 closed the measure-side
route — at which point the two roadmap items would together mean both named attack vectors are
exhausted, which is itself an actionable, reportable state for the user.
