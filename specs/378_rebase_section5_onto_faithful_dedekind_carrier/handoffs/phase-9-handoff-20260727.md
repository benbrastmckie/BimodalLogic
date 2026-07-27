# Phase 9 handoff — TASK COMPLETE. Prop 4.2 landed at the faithful Dedekind carrier, 9/9 phases

**Session**: `sess_1785164194_b6cbfb` | **Date**: 2026-07-27 | **Phase 9 status**: COMPLETED
**Task status**: implemented — 9 of 9 phases, no phase blocked, no phase re-split

## Immediate next action

**None for this task.** The plan is fully executed and its `- **Status**:` is `[COMPLETED]`, with
all Testing & Validation boxes checked. The full task summary is at
`specs/378_rebase_section5_onto_faithful_dedekind_carrier/summaries/01_faithful-dedekind-section5-rebase-summary.md`.

The single follow-up worth spawning is stated in the summary's "What this EXCLUDES / what remains":
**construct a genuinely non-attained Dedekind-complete frame class** (the paper's own `ℝ` with
`P₁ = {x | x > 0}`, `z₀ = 0`). Until that exists, the re-base is machine-checked but
*unobservable* — see `prop42_faithful_unobservable_on_prior`. That is a new task, not a
continuation of this one.

## What Phase 9 landed

`FormalSystem/Metalogic/WeakCanonical/Kamp/Prop42Faithful.lean` — new, live, 8 declarations
(6 theorems), 0 sorries, all axiom-clean, **compiled on the first build**.

| Declaration | Role |
|---|---|
| `prop42_contentful_of_dedekind` | **the headline**: `Prop42Contentful` from `HasDedekindINF` ALONE |
| `prop42_witness_exposes_negFixFaithful` | names the witness the `∃ v'` hides |
| `prop42_contentful_of_attained_inf_only` | the landed attained theorem is now a corollary; its `HasAttainedSUP` arg is UNUSED |
| `prop42Faithful_perPoint_is_VACUOUS` | failed-vacuity control, re-run against the FINAL statement |
| `prop42_witness_carries_limit_gate` | the `K⁺(¬β₁)(z₀)` gate (p.9) still fires in the witness |
| `prop42_faithful_unobservable_on_prior` | the re-base's CUMULATIVE exclusion statement |

Plus: the 9-row faithful re-base table appended to `Kamp/Section5Correspondence.lean` (no existing
row deleted or renumbered), and one import edge + NOTE in `Kamp/NfMultiAnchorBridge.lean`.

## Measured results (actual, not asserted)

| Gate | After Phase 8 | After Phase 9 |
|---|---|---|
| `lake build` exit | 0 | **0** |
| Jobs | 1891 | **1892** (+1) |
| Live modules from `FormalSystem.lean` | 277 | **278** (+1) |
| Tactic-position sorries in `Kamp/` | 4 dead / 0 live | **4 dead / 0 live** |
| Tactic-position sorries in the new module | — | **0** |
| Real `axiom` declarations in `FormalSystem/` | 0 | **0** |
| `AggregateOffDiagK1` explicit build | 1098 jobs, EXIT 0 | **1098 jobs, EXIT 0** |
| `EANegationFix/` attained stack | untouched | **untouched** (`git status --porcelain` empty) |

Cumulative across the task: **1883 → 1892 jobs**, **269 → 278 live modules**, exactly +1 per phase
for nine phases. Census is tactic-position via `.claude/scripts/lean-sorry-census.sh`, never
`grep -c`. Liveness by transitive `import` walk from `FormalSystem.lean`; no `Boneyard` module is
live; `lake build BoneyardArchive` never run or cited.

**The recurring axiom-count note, one last time.** Bare `grep -c '^axiom ' FormalSystem/` returns
**2**; both are prose continuation lines inside `Boneyard/` comments
(`Boneyard/DiscreteXY/Discreteness.lean:40`;
`Boneyard/StrictSemanticsLegacy/Bundle/SuccChainFMCS.lean:1233`). Neither is a declaration. Real
axiom count: **0**. All six new theorems verify as subsets of
`[propext, Classical.choice, Quot.sound]`; `prop42_faithful_unobservable_on_prior` needs only
`[propext]`.

`FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1225` carries one `sorry`. It is **outside
`Kamp/`, pre-existing**, and predates this task entirely (traced to the module-path rename commit).
Not introduced here.

## Non-vacuity: both halves of the control, recorded verbatim

Positive (compiles, and that is what makes it worthless):
`prop42Faithful_perPoint_is_VACUOUS` proves the per-point `∃ v'` ordering from **no carrier
hypothesis at all**.

Negative (must NOT typecheck — both confirmed as hard type mismatches):

```
example ... : Prop42Contentful M atomMap v := ⟨topVVec, fun z0 z1 _ => Iff.rfl⟩
  -- error: Type mismatch — Iff.rfl has type ?m ↔ ?m but is expected to have type
  --   VVecEA2.holds M atomMap topVVec z0 z1 ↔ ¬VVecEA2.holds M atomMap v z0 z1

example ... : Prop42Contentful M atomMap v := prop42Faithful_perPoint_is_VACUOUS M atomMap v
  -- error: Type mismatch — has type
  --   ∀ (z0 z1 : M.carrier), z0 < z1 → ∃ v', VVecEA2.holds M atomMap v' z0 z1 ↔ ¬VVecEA2.holds M atomMap v z0 z1
  -- but is expected to have type  Prop42Contentful M atomMap v
```

The second is the important one: the compiler certifies the per-point and hoisted orderings are
**different statements**, so the hoisting is the content rather than a stylistic choice.

The failure mode specific to this phase was neither of those, and is worth carrying forward as a
general lesson: **`Prop42Contentful` existentially quantifies the witness**, so a construction that
had silently dropped the paper's Case 1 gate would have proved the headline theorem *verbatim*.
`_iff` lemmas and `∃`-statements alike are silent about the construction. That gap is closed by
naming the witness (`prop42_witness_exposes_negFixFaithful`) and proving the gate fires in it
(`prop42_witness_carries_limit_gate`).

## `HasDedekindSUP`: SIXTH and final drop — verdict

Dropped in Phases 4, 5, 6, 7, 8 **and** 9. Not a hypothesis of `prop42_contentful_of_dedekind`,
exactly as predicted by the Phase 8 handoff. No use was contrived. `orderedPointsExist_combine_kminus`
and `HasDedekindSUP.last_occ_tp` remain unconsumed.

Phase 2 nonetheless proved its independent worth here: `Lemma53FaithfulPast.lean` **is** consumed by
Phase 9 — but for its `K⁻` **exclusion** theorem `prior_makes_kminus_disjunct_unreachable`, which
supplies the "and its dual" half of the mandated cumulative exclusion statement. That is a genuine
use, not a symmetric one.

Concrete payoff recorded in code: `prop42_contentful_of_attained_inf_only` shows the landed
`prop42_contentful_of_attained` is now a corollary whose `HasAttainedSUP` argument is **unused**.

## Deviations raised in Phase 9

1. **Extra import** — `Prop42Faithful.lean` also imports `Kamp.Lemma53FaithfulPast`, required to
   execute Phase 9's own Verification bullet ("disjunct (2) **and its dual**"). Cycle-free.
2. **`Section5Correspondence.lean` beyond row-append** — two statements in its existing "What the
   carrier EXCLUDES" section went stale the moment this phase landed (the strengthening-chain
   diagram marked only `HasAttainedINF` as landed; one sentence still read "Building the faithful
   carrier is separately owned"). Both corrected in place. **No existing row deleted or renumbered.**
3. **Stale citation corrected** — `DedekindINF.lean:167` → `:172` (true line of
   `HasAttainedINF.toHasDedekindINF`) in three files: the new module plus inherited copies in
   `VecEANegFixFaithful.lean` (×2) and `NegFixListFaithful.lean`. Comment-only. The stale number
   originates in the plan (~line 1278) and had propagated through Phases 7-8.
4. **Jobs/modules projection was stale** — plan says 1891/277 terminal; measured is **1892/278**.
   Recorded in the plan rather than silently matched, per the Phase 8 carry-forward instruction.

## Line-number / path discipline: keep it

Third consecutive phase in which re-confirming citations by `grep -n` before editing caught a real
error (Phase 7: line drift; Phase 8: a wrong *path*; Phase 9: `DedekindINF.lean:167`→`:172`,
inherited and propagated). It stayed cheap every time. Verified-current this phase:
`Prop42Contentful.lean:151`, `Section5Correspondence.lean:128`, `DedekindINF.lean:136`,
`Lemma53.lean:290`, `Lemma53Faithful.lean:189`/`:354`/`:382`, `Lemma53FaithfulPast.lean:355`,
`EANegationFix/VecEANegFix.lean:183`, `EANegationFix/OnBuilder.lean:179`,
`VecEANegFixFaithful.lean:281`.

## Binding constraints: all held

- **Three-strikes prohibition** — no attempt at the model-independent Prop 4.2 backward direction.
  `EANegation.lean` and `Boneyard/EANegationVBracketBackward.lean` not read, referenced, or edited.
  Phase 9 was statement assembly over `VVecEA2.negFixFaithful_iff`, as forecast.
- **Sorry gate** — zero new live sorries, tactic-position census.
- **PRESERVE** — no file deleted, no declaration excised, no attained-carrier declaration weakened.
- **Rabinovich by PDF page only** — p.6 read directly via the `Read` tool's `pages` parameter and
  quoted verbatim; the corrupt companion `.md` never consulted.

## Sizing

Closed in one agent run, first build, no re-split, no internal boundaries needed — the same
profile as Phases 7 and 8.
