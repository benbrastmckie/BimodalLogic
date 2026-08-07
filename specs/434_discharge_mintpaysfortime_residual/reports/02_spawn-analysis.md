# Blocker Analysis: Task #434

**Parent Task**: #434 - Discharge `MintPaysForTime fc U Tmax`
**Generated**: 2026-08-07
**Blocker**: Phase 7 (and transitively Phase 8) are `[BLOCKED]`: no satisfiable repair of
`MintPaysForTime` exists among the two routes the plan specifies, both refuted in-source. A
fourth termination-measure component is needed — one that pays for the three self-guarded
minting rules (`untlNeg`, `snceNeg`, `densityRule`) and is preserved across
`TimeOrdering.identifyTime`, which can *lower* `ord.timeCount`.

## Root Cause

`FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` section D2 (Phase 4
verdict) proves `MintPaysForTime fc U Tmax` false as literally stated
(`mintPaysForTime_untlNeg_false`, universal in frame class and `Tmax`). The plan's Phase 7 then
tried the two repair routes the plan and Phase 4 verdict specify:

1. **Rule-coordinate narrowing** (widen the second disjunct's index set from `freshLabelRules` to
   `freshTimeRules`). Refuted by `witnessPresent_eq_false_of_not_freshLabel`: `witnessPresent`'s
   match has exactly eight arms, one per `freshLabelRules` member, so the three added columns
   (`densityRule`, `untlNeg`, `snceNeg`) are permanently `false` and only ever add
   `3 · |U|` to the count.
2. **Dropping disjunct 1's cardinality conjunct**, relying only on the ordering-rank conjunct.
   Refuted by `splitOrderedRank_lt_of_knownTimes_lt` + `mintPaysForTime_rank_repair_false`: the
   base `Tmax² + 1` in `splitOrderedRank` is by construction one more than `incompPairs`' range,
   so any newly-known time raises the rank regardless of the pair count.

Both refutations are machine-checked (decided statements, not arguments), and are entered in the
do-not-re-attempt register (`MintBound.lean` section C9, entry 14, of 16 total entries — read
before any new work, per the handoff's own instruction). The handoff's own diagnosis is precise:
`untlNeg`/`snceNeg` are guarded by `futureOf`/`pastOf` emptiness plus `ord.timeCount < 4`, and
`densityRule` by the maximal-unfilled-gap set; none of the three termination arguments is
`mintPotential`, and composing them into one measure that also survives `identifyTime` lowering
`ord.timeCount` is "open mathematics, not a proof-engineering gap."

**Literature coverage check** (per the user's explicit instruction to ground the spawned work in
literature):

- The **per-repo sub-index** (`specs/literature-index.json`, 33 entries) has **zero** relevant
  coverage. Every entry traces to the Kamp-theorem / temporal-expressive-completeness research
  line (rabinovich_2014, gabbay_199x, burgess_198x, reynolds_1992, venema_1993_since, doets_198x,
  goldblatt_2023) — a different, unrelated research thread in this repository's history. Nothing
  in the sub-index concerns tableau termination, well-founded measures, blocking/loop-checking,
  or mosaic-style decidability arguments.
- The **global corpus** (`~/Projects/Literature/index.json`, 343 entries), by contrast, already
  contains several directly relevant, previously-ingested sources not yet registered in the
  sub-index:
  - `massacci_2000_single_step_tableaux_for_modal_logics` (`provenance_fidelity: verified_conversion`)
    — a termination technique for modal-logic tableaux bounding rule application by prefix
    length; the closest direct analogue in the corpus to "a bound that pays for a rule class."
  - `caleiro_2013` (7 chunked sections, `On the Mosaic Method for Many-Dimensional Modal Logics`)
    — decidability via mosaics for *combined* tense-and-modal logics, structurally the closest
    match to TM's S5-modal + linear-temporal combination; §4.2–4.3 cover mosaic-based tableau
    systems and decidability/complexity bounds.
  - `blackburn_2002_ch06_sec01-03` / `sec04-05` / `sec06-07` (Blackburn–de Rijke–Venema, *Modal
    Logic*, Ch. 6 "Satisfiability and Decidability" including "Quasi-models, Mosaics, and
    Tiling") — the standard textbook treatment of tableau/mosaic termination arguments.
  - `venema_2001_sec04` (§5 "Interval-Based Temporal Logic") — directly relevant to
    `densityRule`'s maximal-unfilled-gap guard, which is an interval/density-style condition.
  - `gerth_1995_onthefly_ltl` (Gerth et al., "Simple On-the-Fly Automatic Verification of
    Linear Temporal Logic") and `baier_katoen_2008_part01`–`part12` (*Principles of Model
    Checking*) — the classical LTL tableau/automaton closure-set construction, whose termination
    argument is the standard reference point for "a measure over an evolving time/state set that
    must not grow unboundedly."
  - `vardi_wolper_1986_automata_verification`, `vardi_1996_automata_ltl` — automata-theoretic
    background for the same family of termination arguments.

  All of the above are tier-1 (already-local) hits confirmed by both direct
  `literature-search.sh` FTS queries and a `literature-discover.sh` keyword-overlap pass — no
  online ingestion was necessary; the gap is **curation** (registering existing global-corpus
  documents into the per-repo sub-index), not **acquisition**.

**Conclusion**: coverage is *sparse in the per-repo sub-index* but *present in the global corpus*.
Per the routing this implies: the spawned decomposition needs a foundational curation task to
populate the sub-index with the identified documents (and confirm no closer-fit paper is missing
via one online discovery pass) before the measure-design task can be usefully run with `--lit`.

## Proposed New Tasks

### New Task 1: Curate literature sub-index for tableau-termination measure design
- **Effort**: 2-3 hours
- **Task Type**: meta
- **Rationale**: The per-repo sub-index has zero entries relevant to termination-measure design;
  running the measure-design task with `--lit` today would inject nothing useful. The needed
  material already exists in the global corpus and only needs registration plus one confirmatory
  online discovery pass for gaps (e.g., a paper specifically on well-founded/Dershowitz-Manna-style
  orderings for loop-checking modal-temporal tableaux, which the corpus does not yet have).
- **Depends on**: None

### New Task 2: Design and land the fourth termination-measure component for `MintPaysForTime`
- **Effort**: 10-14 hours
- **Task Type**: lean4
- **Rationale**: This is the actual mathematics the task 434 handoff named as needed: a measure
  component paying for `untlNeg`/`snceNeg`/`densityRule` that is preserved across
  `TimeOrdering.identifyTime`. It resumes task 434's plan at Phase 7 (and Phase 8), consuming the
  curated literature via `--lit` for termination-technique grounding, and must not re-attempt any
  of the 16 do-not-re-attempt register entries in `MintBound.lean` section C9 (in particular
  entry 14's two named-refuted routes).
- **Depends on**: New Task 1, because the *specific set of curated papers* — mosaic-method
  decidability for combined modal+temporal logics (`caleiro_2013`), the interval/density
  treatment (`venema_2001_sec04`), the closure-set LTL termination argument
  (`gerth_1995_onthefly_ltl`, `baier_katoen_2008`), and the direct tableau-bound technique
  (`massacci_2000`) — is what shapes *which* termination-ordering pattern (mosaic-style bound,
  closure-set potential, prefix-length bound, or a hybrid) Task 2's implementer should draw on
  when designing the fourth measure component. This is a genuine implementation-detail
  dependency, not merely a completion-order constraint: which papers get curated and how they
  are annotated in the sub-index (their relevance notes) directly informs the measure-design
  strategy Task 2 attempts first.

## Dependency Reasoning

- **New Task 2 depends on New Task 1**: Task 1's curation choices (which papers are registered,
  and the relevance annotation attached to each) determine what `--lit` surfaces to Task 2's
  implementer, and therefore which termination-measure design pattern is attempted first. A
  differently-curated sub-index (e.g., prioritizing the automaton/closure-set style of
  `gerth_1995`/`baier_katoen_2008` over the mosaic style of `caleiro_2013`) would lead Task 2 to
  a different first design attempt. This is not just "Task 1 must finish before Task 2 starts" —
  Task 1's specific output content shapes Task 2's approach.
- No other task pairs exist in this decomposition (only two tasks proposed), so there is no
  independence claim to make.

**File Footprint Overlap Check**: Task 1's `file_scope` (`specs/literature-index.json`) and Task
2's `file_scope` (`FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`) do
not overlap under the shared file-footprint-overlap algorithm — no auto-added dependency is
needed beyond the explicit content-dependency already declared above.

## After Completion

Once both spawned tasks are complete, resume the parent task #434 with `/implement 434` (Phase 7
onward), or continue directly from the new measure-design task's own plan if the spawned task
absorbs Phases 7-8 in its own scope.

The blocker will be resolved because: New Task 1 gives the measure-design task genuine,
literature-grounded termination-ordering patterns to draw on via `--lit` (mosaic-method
decidability for combined tense+modal logics, interval/density arguments, and closure-set LTL
termination arguments), and New Task 2 uses that grounding to design and land the fourth measure
component the task 434 handoff identified as the single missing piece — without re-attempting
either of the two refuted repair routes recorded in the do-not-re-attempt register.
