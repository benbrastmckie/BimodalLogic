# Research Report: Task #465

**Task**: 465 - Complete the terminus restatement family at the repaired residuals
**Started**: 2026-10-17T01:04:00Z
**Completed**: 2026-10-17T01:12:25Z
**Effort**: ~1 hour (research); implementation effort depends on the scope decision below
**Dependencies**: 462, 463, 464 — all three settled (463 and 433 archived; 464's nine phases committed through `282e3ddc4`)
**Sources/Inputs**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/` (all 20 submodules; the monolithic `MintBound.lean` named in the task description has since been split into an aggregator plus submodules, so the line references `:6308-:12240` no longer resolve)
- `specs/archive/433_discharge_postblockingsettles_residual/plans/01_postblockingsettles-refute-or-prove.md`, Phase 6 `#### Reasoned Exclusions`
- lean-lsp MCP (symbol index reported `warming` on both attempts; name-existence evidence therefore degrades to a grep sweep over `FormalSystem/`, announced here rather than presented as an LSP-backed negative)
- No literature source is referenced by this task; the literature-extraction protocol does not apply.
**Artifacts**:
- `specs/465_complete_terminus_restatement_family/reports/01_complete-terminus-restatement-family.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The task's premise is void as written, and the dispatch's own stop-condition fires.** The
  fourteen deferred restatements were to be `_lengthBudget`/`signedUniverse` siblings of eight
  `_run` family roots. All nine `_run` termini — the eight roots and seed forms plus
  `buildTableauAt_isSome_of_budget_of_run` — were **retired as vacuous** after
  `PostBlockingSettlesRun` was refuted. There are no roots left to apply, so not one of the
  fourteen is "a one-line application of its family root". The dispatch instructs: STOP on such a
  member, record why, do not force it. That is what this report does, for all fourteen at once.
- **Why they were retired, in the file's own words**: each "read as a headline result — the tableau
  construction succeeds — while establishing nothing, because each carried a hypothesis this file
  itself refutes." Landing fourteen more of the same shape would manufacture exactly the defect the
  retirement record exists to prevent.
- **Re-deriving the family matrix from the file as it stands** (the dispatch's explicit
  instruction) finds the five landed families **complete**, not half-populated: root (4 of its 4
  available slots), `_at`, `_selfGuarded`, `_fixed` and 464's new `_gap` (6 of 6 each). The live
  gap is somewhere else: the post-blocking **seed** narrowing has exactly **one** member repo-wide,
  `buildTableauAt_isSome_of_budget_fixed_seedRun`, whose own docstring says "This is the
  representative restatement, not the family … Widening the seed narrowing to the rest of that
  family is deliberately deferred rather than forgotten."
- **A larger finding the task cannot absorb but a planner must know**: every one of the 28 termini
  in the five landed families carries `hpb : PostBlockingSettles fc`, and
  `postBlockingSettles_fuel_zero_false` / `postBlockingSettles_fuel_gap_false` prove
  `¬ PostBlockingSettles fc` **universally quantified in the frame class**. All 28 are therefore
  true conditionals with provably false antecedents. The only post-blocking hypothesis this file has
  not refuted is `PostBlockingSettlesSeedRun`.
- **Recommended rescope** (see Decisions, and the `user_decision` on `.return-meta.json`): complete
  the **seedRun** family rather than the dead `_run` family — the gap the file itself names — and
  amend the register so no future reader goes looking for the fourteen. A sorry-free, axiom-clean,
  purely-additive path exists for every member proposed.

## Context & Scope

Researched: what the fourteen recorded exclusions actually were, whether they still exist as a
gap, and what the family matrix looks like in the file as it stands today after 462, 463 and 464.
Constraints carried from the dispatch: no `sorry`; additive only; no previously-landed declaration
altered; `Fuel.lean`, `Saturation.lean`, `Tableau.lean` untouched; axioms within
`{propext, Classical.choice, Quot.sound}`; full `lake build` green; and the stop-condition on any
member that is not a one-line application.

Two structural facts about the present tree that the task description predates:

1. `MintBound.lean` is now a 130-line aggregator; the declarations live in
   `MintBound/{Terminus,ClosureResidual,FourComponent,SigmaFixed,PostBlocking,UntlSnceFree,GapPotential,MintPaysAssembly,FiveComponent,Register}.lean`.
2. `specs/433_…` has been archived to `specs/archive/433_discharge_postblockingsettles_residual/`;
   its Phase 6 exclusion record is intact there.

## Findings

### Codebase Patterns

**The six-slot family convention, re-derived.** Each repair family restates the terminus at six
call sites, named by stacking a family suffix onto a slot name:

| Slot | Name shape | What it fixes |
|------|-----------|---------------|
| S1 | `buildTableauAt_isSome_of_budget{_SUFFIX}` | the family root; all figures quantified |
| S2 | `buildTableauAt_isSome_at_seed{_SUFFIX}` | `Tmax`/mint budget read off `derivedTmax*` |
| S3 | `buildTableauAt_isSome_of_lengthBudget{_SUFFIX}` | `DifficultyBounded` → `StepLengthBounded` |
| S4 | `buildTableauAt_isSome_at_seed_lengthBudget{_SUFFIX}` | S2 ∧ S3 |
| S5 | `buildTableauAt_isSome_of_lengthBudget_signedUniverse{_SUFFIX}` | `UniverseClosedAt` discharged at `signedUniverse C L` |
| S6 | `buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse{_SUFFIX}` | S2 ∧ S3 ∧ S5 |

Note the convention detail a new member must not get wrong: an S5/S6 form **drops** the `_at`
suffix, because `UniverseClosedAt` is discharged there rather than carried — which is why
`buildTableauAt_isSome_of_lengthBudget_signedUniverse` (ClosureResidual.lean:1116) is the `_at`
family's S5 despite its name, and why the root family has no S5/S6 at all (its `UniverseClosed` is
false at every nonempty universe, `universeClosed_nonempty_false`).

**The matrix as it stands today** (grep over `FormalSystem/`, `theorem buildTableauAt_isSome*`):

| Family | S1 | S2 | S3 | S4 | S5 | S6 | Module | Status |
|--------|----|----|----|----|----|----|--------|--------|
| root (no suffix) | 169 | 191 | 235 | 254 | n/a | n/a | `Terminus.lean` | complete (4/4 available) |
| `_at` | 970 | 987 | 1007 | 1022 | 1116 | 1142 | `ClosureResidual.lean` | complete 6/6 |
| `_selfGuarded` | 567 | 585 | 605 | 621 | 649 | 680 | `FourComponent.lean` | complete 6/6 |
| `_fixed` | 812 | 829 | 847 | 862 | 883 | 902 | `SigmaFixed.lean` | complete 6/6 |
| `_gap` | 671 | 689 | 708 | 724 | 743 | 765 | `FiveComponent.lean` | complete 6/6 (landed by 464) |
| `_untlSnceFree` | — | — | — | — | — | 690 | `UntlSnceFree.lean` | 1 member, deliberate |
| `_fixed_seedRun` | 1273 | — | — | — | — | — | `PostBlocking.lean` | **1 member, deferral named in-file** |
| `_run` | retired | retired | retired | retired | — | — | (gone) | **withdrawn as vacuous** |

So the fourteen `_lengthBudget`/`signedUniverse` gaps the task was created to fill **do not exist**:
they were gaps in the `_run` family, and that family is gone. The five live families are already
uniform.

**The retirement record** (`PostBlocking.lean`, section C12, `/-! #### The termini restated at the
narrowed residual — retired as vacuous`) names all nine removed declarations
(`_of_budget_run`, `_of_budget_of_run`, `_at_seed_run`, `_of_budget_at_run`, `_at_seed_at_run`,
`_of_budget_selfGuarded_run`, `_at_seed_selfGuarded_run`, `_of_budget_fixed_run`,
`_at_seed_fixed_run`), the refutation that reaches each, and the frame-class split. The refuting
theorems: `postBlockingSettlesRun_terminusFuel_false` (at `mintAwareFuelAt …`),
`postBlockingSettlesRun_mintAwareFuel_false` (at the un-`At` figure),
`postBlockingSettlesRun_false_succ` (every positive fuel), plus
`postBlockingSettlesRun_false_dense` / `_rtime`. C9 register entries 24 and 25 carry the verdict;
entry 25 also records that at `.ZTime` the predicate is *undecided* rather than refuted, and that
undecided still means undelivered.

**The live successor line.** `PostBlockingSettlesSeedRun fc fuel` (PostBlocking.lean:1210) fixes
the four arguments `buildTableauAt` always supplies at their defaults (`ord := TimeOrdering.empty`,
`tr := EventualityTracker.empty`, `ap := {}`, `bu := 0`). It kills the `_run` witness (checked, not
hoped for) and is **not** shown true; entry 25 and the definition's own clause (iii) name one
structurally independent, unprobed refutation route against it. Its bridge
`buildTableauAt_isSome_of_settlesSeedRun` survives the exchange byte for byte, and
`postBlockingSettlesSeedRun_of_postBlockingSettlesRun` fixes the direction, so every restatement
against it is a **strengthening** of its original.

**Hypothesis health, per hypothesis a new member could carry** (this is the table that decides
which slots are worth landing):

| Hypothesis | Status | Witness |
|------------|--------|---------|
| `PostBlockingSettles fc` | **FALSE at every frame class** | `postBlockingSettles_fuel_zero_false`, `postBlockingSettles_fuel_gap_false` |
| `PostBlockingSettlesRun fc (n+1)` | **FALSE** at `.Base`/`.Dense`/`.RTime`; undecided at `.ZTime` | `postBlockingSettlesRun_false_succ`, `_false_dense`, `_false_rtime` |
| `PostBlockingSettlesSeedRun fc fuel` | not refuted, not proved | entry 25; definition clause (iii) |
| `ArmSettlement fc` | not refuted; carried honestly | `MintPotential.lean:1731` |
| `UniverseClosedAt fc U` | not refuted (its only concrete route needs `hlab`, below) | `universeClosedAt_signedUniverse_of_headroom` |
| `DifficultyBounded fc U D` | **refutable at every `D`** | `difficultyBounded_multiplicity_false` |
| `StepLengthBounded fc U L` | satisfiable | `difficultyBoundedAt_ceiling_at` |
| `MintPaysForTimeFixed fc U Tmax` | **FALSE at `.Dense`/`.RTime`** | register entry 26 (landed by 464) |
| `MintPaysForTimeGap` | **discharged**, no frame-class restriction | `mintPaysForTimeGap_of_any` |
| `UnorderedSuccessorLabelClosed fc L` (S5/S6 only) | **FALSE at every nonempty finite `L`** | `unorderedSuccessorLabelClosed_nonempty_false`, `freshLabelHeadroom_not_universal` |

Two consequences a planner must not flatten: (a) the healthiest available terminus shape is
`StepLengthBounded` + `UniverseClosedAt` + `PostBlockingSettlesSeedRun` + `ArmSettlement` with
`hmint` **discharged** via the `_gap` route — i.e. an S3/S4-shaped `_gap_seedRun` member carries no
refuted hypothesis at all; (b) every S5/S6 slot carries `hlab`, which is refuted at every nonempty
`L`. The repository's existing practice is to land S5/S6 anyway, with the vacuity stated locally —
`buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse_untlSnceFree`'s docstring is the model
("No artifact should read this theorem, or any of the eight siblings that carry `hlab`, as claiming
a discharge at a nonempty universe until `hlab` is absent from the signature").

**Import-graph constraint on where new members can live.** The submodule DAG is
`FourComponent → SigmaFixed → {PostBlocking, UntlSnceFree}`, `UntlSnceFree → GapPotential →
MintPaysAssembly → FiveComponent`. `PostBlocking` and the `FiveComponent` chain are **parallel
branches**: `FiveComponent.lean` does not see `PostBlockingSettlesSeedRun` or
`buildTableauAt_isSome_of_settlesSeedRun`, and `PostBlocking.lean` does not see
`expandBranchWithFuel_isSome_of_budget_gap`. So a `_gap_seedRun` member cannot be appended to
either module as it stands. The clean, additive answer is a **new submodule** (e.g.
`MintBound/SeedRunTermini.lean`) importing both, holding the whole seedRun family; that edits no
landed module except the aggregator's import list and prose, and `MintBound/README.md`.

### External Resources

None consulted. This is a closed-world restatement task over declarations the repository already
owns; no Mathlib lemma, tactic, or external source is implicated. The rate-limited Mathlib search
tools (`lean_leansearch`, `lean_loogle`, `lean_leanfinder`, `lean_state_search`) were deliberately
not called — there is no Mathlib-shaped question here, and spending the budget would have bought
nothing.

### Recommendations

A sorry-free path exists for every member below; none needs new mathematics. Four parts, the first
three additive-only, in dependency order.

**(C) Correct the record — mandatory under any option, and cheap.** Amend
`PostBlocking.lean`'s section C12 retirement record (or C9 entry 25) with one short paragraph
stating that the fourteen `_lengthBudget`/`signedUniverse` siblings deferred alongside the nine
retired `_run` termini are **moot**: their roots are gone, and completing them would mean restating
a refuted hypothesis. Without this, the deferral record stands as an open invitation to re-attempt
exactly what this report refutes — the same trap the task description identifies ("a
half-populated family is a trap for a future reader who assumes an absent member is absent for a
reason"), one level up.

**(A) Complete the `_fixed_seedRun` family, S2–S4.** Three members, each a one-line application of
the landed root in the idiom every other family already uses:

```
buildTableauAt_isSome_at_seed_fixed_seedRun                 -- S2
buildTableauAt_isSome_of_lengthBudget_fixed_seedRun         -- S3
buildTableauAt_isSome_at_seed_lengthBudget_fixed_seedRun    -- S4
```

Recipe (mirroring `_fixed` S2–S4 exactly, with `hpb` restated at the instantiated figure and `harm`
threaded through): S2 `:= buildTableauAt_isSome_of_budget_fixed_seedRun phi _ hβ hUcl hD hmint harm
hpb hseed (Nat.le_refl _) (derivedTmaxAt_spec (seedBranch phi) U) (Nat.le_refl _)`; S3
`:= buildTableauAt_isSome_of_budget_fixed_seedRun phi maxBranches hβ hUcl
(difficultyBounded_of_stepLengthBounded_at hL hUcl) hmint harm hpb hseed hmb hT hbud`; S4 the S2
form applied to the S3 substitution. The one authoring hazard: `hpb`'s fuel argument must be the
conclusion's fuel expression written out (`mintAwareFuelAt U.card (derivedTmaxAt …) (10 * U.card) D
β` in S2, with `difficultyCeiling U L` for `D` in S3/S4), so these signatures are longer than their
`_fixed` counterparts and must be transcribed, not copied.

**(B) Add the `_gap_seedRun` line, S1–S4, in a new submodule.** This is the part that buys
something beyond uniformity: `_gap` discharges `hmint` outright at every frame class, so
`_gap_seedRun` S3/S4 are the first termini in the file carrying **no** refuted hypothesis. S1
transcribes the representative's three-line proof against the `_gap` engine lemma
(`refine buildTableauAt_isSome_of_settlesSeedRun hpb ?_` then
`exact expandBranchWithFuel_isSome_of_budget_gap hβ hUcl hD harm (seedBranch phi)
TimeOrdering.empty EventualityTracker.empty {} maxBranches 0 hseed (runInvariant_initial _) hmb hT
(by omega)`); S2–S4 are one-line applications of it. Figures reused byte for byte:
`mintAwareFuelGap`, `derivedTmaxGap`, `mintPathBoundGap`, and the enlarged floor
`10 * U.card + U.card * U.card` — it costs **no figure**, in entry 20's formulation.

**(D) S5/S6 for both lines — the one judgment call.** Four further members
(`_of_lengthBudget_signedUniverse_{fixed,gap}_seedRun`,
`_at_seed_lengthBudget_signedUniverse_{fixed,gap}_seedRun`), each a one-line application of its own
S3/S4 through `universeClosedAt_signedUniverse_of_headroom hC hT hL hlab`. Mechanically trivial;
substantively they carry `hlab`, which is refuted at every nonempty `L`, so each is vacuous at
exactly the universes it is aimed at. Uniformity argues for landing them (every other family has
them); the retirement lesson argues against adding more headline-shaped statements with false
antecedents. If landed, each MUST carry the `_untlSnceFree` docstring's explicit local
`hlab`-vacuity paragraph, so a reader meeting one at its declaration site gets the signal locally
rather than thousands of lines away in the register.

**Explicitly NOT recommended** (each would violate the dispatch's prohibitions or the zero-debt
posture): landing any member at `PostBlockingSettles` or `PostBlockingSettlesRun`; reviving any of
the nine retired `_run` termini; adding an import edge into a landed module to make `_gap_seedRun`
fit (use a new submodule instead); and touching the five complete families, which need nothing.

## Decisions

- **The fourteen are reported as moot, not attempted.** The dispatch's stop-condition ("if any of
  the fourteen turns out NOT to be a one-line application … STOP on that member, record why, and do
  not force it") fires for all fourteen simultaneously, for a single shared reason: the family root
  each would apply no longer exists. Recording that once, with the retirement evidence, is the
  faithful execution of that instruction.
- **The re-derivation was run as instructed, and it changed the answer.** The dispatch anticipated
  that "earlier tasks may have landed some, or added new family roots" — 464 added a whole new
  family root (`_gap`, complete at 6/6), and 433's own later phases *removed* the family the count
  of fourteen was measured against. Both directions materialized.
- **The live gap is named from the file, not invented.** `_fixed_seedRun`'s own docstring declares
  itself "the representative restatement, not the family" and names the widening as "deliberately
  deferred rather than forgotten". That is the same shape of work the task was created to do, at the
  one residual this file has not refuted.
- **The systemic `PostBlockingSettles` vacuity is reported, not repaired here.** All 28 landed
  termini carry a provably false antecedent. Repairing that is a predicate-level question (the
  unprobed refutation route against `PostBlockingSettlesSeedRun` must be settled first), not a
  restatement; it belongs in its own task. This report names it so no planner mistakes the
  restatement work for a fix.
- **No `sorry`, no axiom, no deferral pattern is recommended anywhere above.** Every proposed member
  is a term-mode application of a landed theorem.

## Risks & Mitigations

- **Risk: repeating the retirement.** Landing a family at a hypothesis that is merely *unrefuted*
  is what produced the nine vacuous `_run` termini. `PostBlockingSettlesSeedRun` is unrefuted with
  an unprobed attack route named on its own docstring.
  *Mitigation*: keep the proposed set small and honest — prefer (B)'s S3/S4, which carry no refuted
  hypothesis at all; give every new member a docstring that names its residual's exact status and
  cites entry 25; and do not describe any of them as a discharge.
- **Risk: a future refutation of `PostBlockingSettlesSeedRun` retires the new members too.**
  *Mitigation*: the cost of that retirement is bounded and known to be ~zero (the nine-member
  removal was cost-free: a whole-environment reverse-dependency scan found no dependents, and
  `FormalSystem.Metalogic.Decidability.decide` reaches no constant of this file). Keeping the new
  members in one dedicated submodule makes a future retirement a single-file deletion.
- **Risk: the `hpb` fuel expression drifts from the conclusion's.** A mistyped figure yields a
  theorem whose hypothesis is at a different fuel than its conclusion — still type-correct, still
  provable, and quietly wrong.
  *Mitigation*: author S2–S4 by copying the `_fixed`/`_gap` sibling's conclusion expression verbatim
  into `hpb`, then verify with `lean_hover_info` on the landed declaration before `lake build`.
- **Risk: `#print axioms` / build regression from a new submodule.** A new file must be added to the
  aggregator's import list or it is never built.
  *Mitigation*: add the import in the same phase as the file, in dependency position (after
  `FiveComponent`), and verify with the guarded full build
  (`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`, detached).
- **Risk: concurrency.** Siblings 805 (implement) and 464 (just closed) share this working tree; the
  `MintBound/` files carry mtimes from 17:43–17:50 today.
  *Mitigation*: the Lean tree is committed and clean as of this research (`git status --porcelain`
  shows only `specs/**` modifications); 805's declared `file_scope` touches no `FormalSystem/` path.
  Re-read each target file immediately before editing, and stage explicit file lists only.

## Tactic Survey Results

Not applicable (no tactic survey performed). No proof goal was opened: every member proposed is a
term-mode application of a landed theorem, and the research question was which members exist, not
how to close a goal. The one automation call any proposed member needs — `by omega` inside (B)'s S1
— is copied verbatim from the landed `buildTableauAt_isSome_of_budget_fixed_seedRun` and
`buildTableauAt_isSome_of_budget_gap`, where it already compiles.

## Context Extension Recommendations

- **Topic**: "A family of restatements is only as good as its weakest hypothesis" — the pattern
  whereby a uniform-looking family of termini all carry one refuted residual, so completing the
  family multiplies vacuous headline theorems instead of adding reach.
  **Gap**: `context/project/lean4/domain/` documents the zero-debt gate and the register idiom, but
  nothing states the family-level version of the rule the C12 retirement record discovered
  empirically: before landing a sibling, check the *status* of every hypothesis it inherits, not
  only that it type-checks.
  **Recommendation**: a short `context/project/lean4/patterns/vacuous-family-restatement.md`
  recording the check (hypothesis-health table before family completion) and citing this file's C12
  retirement record as the worked instance.
- **Topic**: stale line-range references in task descriptions after a module split.
  **Gap**: this task's description points at `MintBound.lean:6308-:12240`, which no longer exists.
  **Recommendation**: one line in `context/formats/*` task-authoring guidance preferring declaration
  names over line ranges when naming Lean work.

## Appendix

**Searches and probes of record**

- `grep -rn "^theorem buildTableauAt_isSome\|^ *theorem buildTableauAt_isSome" FormalSystem/` — 33
  declarations, the matrix above.
- `grep -n "hpb : PostBlockingSettles" MintBound.lean` — **0 hits**: the grep the Phase 6 Scope
  Hypothesis prescribed now reports nothing, because the file is a 130-line aggregator. This is the
  single clearest signal that the recorded enumeration no longer applies.
- `grep -rn "PostBlockingSettlesRun" FormalSystem/` — 33 hits, none a terminus; all are the
  definition, its direction lemma, its bridge, its refutations, or register prose.
- `grep -rn "seedRun" FormalSystem/` — 4 hits: the definition, the direction lemma, the bridge, the
  single representative terminus (plus one Register.lean prose mention). Confirms `_fixed_seedRun`
  is a singleton.
- `grep -n "^import" MintBound/*.lean` — the DAG constraint in Findings.
- `mcp__lean-lsp__lean_local_search "buildTableauAt_isSome_at_seed_fixed_seedRun"` — `{"items":[],
  "index":"warming"}` on two attempts. Per the readiness contract, an empty result under `warming`
  is **not** proof of absence; the grep sweep above is the evidence of record for every
  name-existence claim in this report.

**Key declaration sites**

| Declaration | Site |
|---|---|
| `PostBlockingSettlesSeedRun` | `MintBound/PostBlocking.lean:1210` |
| `buildTableauAt_isSome_of_settlesSeedRun` | `MintBound/PostBlocking.lean:1237` |
| `buildTableauAt_isSome_of_budget_fixed_seedRun` | `MintBound/PostBlocking.lean:1273` |
| C12 retirement record (the nine names) | `MintBound/PostBlocking.lean:735-790` |
| C9 register entries 22 / 24 / 25 / 26 | `MintBound/Register.lean:720 / 834 / 876 / 957` |
| `expandBranchWithFuel_isSome_of_budget_gap` | `MintBound/FiveComponent.lean:651` |
| `universeClosedAt_signedUniverse_of_headroom` | `MintBound/ClosureResidual.lean:1076` |
| `ArmSettlement` | `MintBound/MintPotential.lean:1731` |

**Incidental finding, outside this task's scope** (recorded in the issue log, severity minor): the
C9 register holds 26 entries since 464 landed entry 26, but `Register.lean:11`,
`MintBound.lean:119` and `MintBound/README.md:17` still say "twenty-five"; `README.md:54` says
"twenty-six" and records `Register.lean` at 923 lines against an actual 1001. Whichever task next
edits the register should correct the count in all four places.
