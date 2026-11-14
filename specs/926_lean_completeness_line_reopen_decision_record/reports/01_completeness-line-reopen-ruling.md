# Research Report: Task #926

**Task**: 926 - Lean completeness line reopen decision record
**Started**: 2026-11-14T06:56:00Z
**Completed**: 2026-11-14T08:10:00Z
**Effort**: ~1 hour
**Dependencies**: Task 927 (completed), Task 928 (completed)
**Sources/Inputs**: Codebase (`specs/archive/879`, `901`, `902`, `903`, `906`; `specs/927`,
  `928`; `specs/ROADMAP.md`); no web search, no literature read beyond what 928 already read
**Artifacts**: This report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The ruling, in one sentence: Recommendation 8 (901) stays in force for all four routes.
  None of R1-R4 is reopened as "formalize the Reynolds engine's §§7-15"; three of the four
  (R2, R3, R4-Q1-converse) were never actually blocked by that ruling in the first place and
  can proceed on stated terms, R1 is blocked by a *second*, separate standing ruling ("do not
  re-open the CSLib `require` question", also inherited into 901 Recommendation 8) rather than
  by Recommendation 8 itself, and R4-Q2 is blocked on a literature-acquisition gap, not a
  ruling.**
- **R2 needs no ruling and is already in motion.** Task 927 found the final-frame step
  CONDITIONALLY DISCHARGED by composing already-landed, non-engine declarations
  (`exists_orientedForest_cover_of_constraints`, `saturation_of_orientedForest`,
  `plus_invariance_of_isZTime_of_constraints`); the one named condition is already filed as
  task 932. Ruling: **REOPEN — already executing, no further ruling act needed.**
- **R1 (`Muller.toRabin_exists`) is costed at ~1,000 lines, sited in the fork, no `require`
  entailed — but has no payoff in this repository while the "do not re-open the CSLib `require`
  question" ruling stands**, because the only way its output reaches this repository's
  completeness line is through a `require` this record does not touch. Ruling: **KEEP CLOSED
  in this repository**, with the condition stated below for what would reopen it.
- **R3 (determinization-free progress-measure design) is not yet a filable task of any kind** —
  879's P9 names it as "a research design, not an ingredient." A *paper*-level research pass
  (no Lean, same as the engine's own current paper status) is not barred by Recommendation 8,
  which only bars Lean filing. Ruling: **REOPEN for paper research only; Lean filing stays
  barred regardless of outcome.**
- **R4 splits into three sub-questions with three different dispositions.** Q1 "as stated"
  (does `lcU` derive from `LC_n` + mirror at ZTime) is, per 906's own Recommendation 4, "no
  cheaper than `LCRulesComplete` itself" — i.e. not actually independent of the barred engine.
  Its **converse** (does `lcU` derive `lcN`?) is flagged by 906 as a cheap, unexplored,
  model-theoretically-unobstructed question confined to schema/derivation files, not the
  engine. Q2 (admissibility of `clock`/`aaFwd`/`aaBwd`) is blocked on an unheld source
  (Di Maio-Zanardo 1998), not on any ruling. Ruling: **Q1-as-stated KEEP CLOSED (entangled with
  the barred engine); Q1-converse and the guarded-until-form candidate REOPEN; Q2 stays BLOCKED
  pending literature acquisition.**

## Context & Scope

This is a decision record only: no Lean file is written or edited, no part of the Reynolds
engine's §§7-15 is formalized, attempted, or filed, and no completeness claim is made. The task
exists because the completeness front currently carries zero active tasks of any kind, not
because the mathematics is settled: `specs/archive/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md`
Deliverable 4 returns GO for T3 as a staged paper programme, but
`specs/archive/901_two_sided_reynolds_engine_paper_proof`'s Recommendation 8 bars filing a Lean
formalization of the Reynolds engine's §§7-15, and `specs/ROADMAP.md` records that lifting it
"needs a fresh user ruling reversing that." A research dispatch cannot reverse a user ruling, so
the task is to rule reopen/keep-closed/reopen-on-conditions for each of four named routes
(R1-R4), with the argument, and to state terms precisely enough that a successor can file
against a reopened route without re-asking.

The four founding reports (879, 901, 902, 903) are cited below, not re-derived or condensed —
their content is taken as given per the dispatch's own instruction. What this record adds is
the two companion dispatches this task depends on, both completed since the dispatch was
written: task 927 (final-frame remeasurement) and task 928 (determinization cost assessment).
Their findings are load-bearing for this ruling and are read from their reports/summaries
directly, not re-derived.

## Findings

### R1 — Prove `Muller.toRabin_exists`

**Cost (928, Finding 2):** ~1,000 lines (800-1,200), one new file, 4-7 phases, measured against
in-tree comparables (`DA/Concat.lean`, 762 lines) — not against the landed same-state-space
conversions, which would understate it roughly fivefold. **Construction of record (928, Finding
1):** Thomas 1997 §6.1 Theorem 6.5 with Remark 6.6, the appearance-record (LAR) route — not
Safra's and not Piterman's, because the input is already deterministic. The prior "Safra/Piterman
in corpus" attribution in 879's row 16 is a misattribution as to this lemma. **Siting (928,
Finding 3):** the fork; the minimal statement closure measures 956 third-party lines; this
repository's `lake-manifest.json` holds no `cslib` entry; proving the lemma in the fork commits
this repository to nothing, and "the `require` question becomes live only if this repository's
Lean code comes to consume it." **Value (928, Finding 4):** (O1) and (O3) are separable; (O1)
alone unblocks the automaton side of a `Prop`-valued completeness statement (classical extraction
suffices), while (O3) binds only the decidability front and is discharged by restating already-
landed upstream code, not by this lemma.

**Why this is not actually gated by Recommendation 8.** `Muller.toRabin_exists` is a general
automata-theoretic lemma about deterministic ω-automaton conversion. It is not Reynolds' chronicle,
ban/lull, hue-scheduling, universal-non-acceptance, or truth-lemma content — it is infrastructure
the AA rule and ban mechanism *consume*, not part of §§7-15 itself. Proving it, even in this
repository, would not be "a Lean formalization of any part of §§7-15."

**Why it is gated anyway, by a second, separate ruling.** 901's Recommendation 8 reads in full:
"Do not file a Lean formalization of any part of §§7-15 above, **and do not re-open the CSLib
`require` question**. Both conclusions are inherited and this write-up strengthens neither
direction." (`specs/archive/901_two_sided_reynolds_engine_paper_proof/reports/01_two-sided-reynolds-engine-paper-proof.md:991`).
The second clause is a standing ruling of its own, inherited from 902's narrowing of 879's
Recommendation 6 ("do not file a *determinization* project ... the live question is whether to
depend on it") and 902's own Recommendation 3 ("Do not `require` CSLib now, in either form").
`specs/ROADMAP.md:160` restates it as still in force: "The CSLib `require` question is not to be
re-opened on their account either." Proving R1 *in the fork* does not trip this (928 Finding 3),
but the only route by which proving it benefits *this repository's* completeness line is for this
repository's Lean code to consume the fork's output — which is exactly the `require` question the
ruling bars re-opening. Upstreaming to Mathlib proper would sidestep the `require` question
entirely, but 902 records 0 of 11 prior PRs from this author merged (8 closed unmerged, 3 open),
an unbounded-latency path, not a substitute for a near-term decision.

**Ruling: KEEP CLOSED, in this repository, as a task.** Nothing here reverses the `require`
ruling or Recommendation 8. The stated condition for reopening: either (a) the `require` ruling
is separately reversed by the user, or (b) the lemma is accepted upstream into Mathlib proper
(no fixed timeline, author's own PR history argues against counting on it), or (c)
Recommendation 8 itself is reversed and the engine comes to need (O1) directly. Absent any of
the three, filing R1 against this repository has no payoff to collect, independent of its cost.
Proving the lemma *in the fork itself* is not this repository's task to file at all — the fork is
a separate codebase under separate ownership, and nothing in this record claims authority over
tasks sited there.

### R2 — Close the final-frame step

Task 927's four findings (`specs/927_final_frame_step_remeasure_against_landed_cover/reports/01_final-frame-step-remeasure.md`,
re-validated against live source by its implementation dispatch):

1. The landed trio — `exists_orientedForest_cover_of_constraints` (`UniversalCover.lean:591`),
   `saturation_of_orientedForest` (`OrientedForest.lean:880`), and
   `plus_invariance_of_isZTime_of_constraints` (`HistoryMorphism.lean:681`) — composes sorry-free
   at axiom profile `[propext, Classical.choice, Quot.sound]`, discharging the final-frame step
   as 901 Finding 15 states it.
2. The source-side obligation (Compositionality, Seriality, Limit on the chronicle quotient) has
   none of its three conjuncts doubtful: two are free for any `ofStepRel`-generated relation over
   the integers, and the third reduces to the double seriality §13.1 already establishes.
3. 901's ingredient row and "weakest link" Risks paragraph are **stale, not wrong-at-the-time** —
   the universal cover and the Saturation-free lift chain both landed the same evening 901 was
   committed.
4. The final-frame step is **CONDITIONALLY DISCHARGED**: the condition is a named, compiled
   four-lemma API refactor (presenting the chronicle quotient as a `FrameOver intOrder` without
   the `Saturation`/`[Finite W]` that `ofStepSat`/`ofStep` otherwise demand), filed as task 932,
   not an open mathematical question.

**Why this needs no ruling at all.** None of this touches §§7-15: 897 and 898 (the two landed
pieces) are universal-cover and base-invariance lemmas outside the Reynolds engine proper, and
task 932 is frame-presentation API in `IntNormalForm.lean` whose proofs already exist inline in
`ofStepSat`'s body — it formalizes no chronicle, ban, lull, or truth-lemma content. 927's summary
is explicit: "Finding (4) positive does NOT make T3 complete. Rows 17-21 of the ingredient table
remain paper, §§7-14 remain paper." This route closes one acknowledged gap in the *paper* proof's
write-up (901 Finding 15, the final frame specifically) using Lean pieces that were never barred,
and leaves the barred rows exactly as barred.

**Ruling: REOPEN — already executing, no further ruling act needed.** Task 931 (applying the 901
record correction) and task 932 (the named condition) are both already filed by task 927, with
declared `file_scope` and `dependencies: []`. This record adds nothing beyond confirming that
neither task requires, nor should be read as, a reversal of Recommendation 8.

### R3 — The determinization-free alternative

879's P9 names "an explicit progress-measure argument that avoids determinization" as "the ONLY
route to a Lean proof that sidesteps (O1)," and calls it "a research design, not an ingredient"
(`specs/archive/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md:229`).
No report in this tree has yet attempted to specify what such an argument would look like; it is
named but not designed.

**Scope of what reopening could mean.** If the progress-measure design turns out to be a genuine
alternative *proof architecture* for the same completeness result Reynolds' engine establishes
(rather than a reformulation confined to, say, the AA rule alone), a Lean filing of it would
still be proving the same target the engine proves, and 901's Recommendation 8 text — "any part
of §§7-15" — is squarely aimed at exactly that outcome regardless of which construction produces
it. The bar is on filing Lean against the completeness result via the engine's content; a
different architecture that reaches the same result is not a loophole around that bar on the
strength of using different lemmas.

What Recommendation 8 does *not* bar is **paper-level research** — 879's own P9 (producing 901,
a paper proof) was exactly that, and Recommendation 8's own text says the paper write-up
"strengthens neither direction" of the two standing bars, treating paper work as orthogonal to
them. A research pass asking "does a determinization-free progress-measure argument exist, and
what would it need?" at Reynolds-2001-style rigour, without landing or attempting any Lean, is
the same kind of work 879's P9 and 901 already did and is not itself a formalization of
anything.

**Ruling: REOPEN for paper research only.** A research-type task may be filed to design (on
paper) a determinization-free progress-measure argument for T3, explicitly scoped FILE SCOPE:
none / no Lean, mirroring 879's and 901's own posture. Its outcome does not change what may be
filed in Lean: if the design succeeds, filing it in Lean still requires the same Recommendation-8
reversal any other route into §§7-15 requires, and the record states that explicitly here so a
successor does not re-ask.

### R4 — T1's two reduced questions

879's NO-GO-but-reduced verdict on T1: "(Q1) is `lcU α β` derivable in TM⁺ + `LC_n` + mirror at
ZTime for state-local `β`? (Q2) are `clock`, `aaFwd`, `aaBwd` admissible over TM⁺ + the schemata?"
(`specs/archive/879_.../reports/01_lplus-ztime-completeness-programme.md:227`).

**Q1, as stated.** Task 906 proved the ZTime case **unsettleable by any model**: `lcN_plusValidZTime`
and `lcU_plusValidZTime` are both compiled, so every ZTime model validates both schemata, and "the
two extensions have exactly the same ZTime models by construction"
(`specs/archive/906_lcu_derivability_from_lcn_non_ztime_separating_model/reports/01_lcu-lcn-separating-model.md:44-53,66-69`).
Only a proof-theoretic argument can decide it. 906's own Recommendation 4 names the live target —
whether `ExtDerivation .ZTime IsLCAxiom RuleSet.all` derives `lcU` — and states plainly: "the
honest prior is that it is no cheaper than `LCRulesComplete` itself, since `lcU` is `.ZTime`-valid
and would follow from completeness immediately" (line 327-328). `LCRulesComplete` is stated with
no proof and no `sorry` in `Metalogic/LCExtension.lean` and is T3's own target
(`specs/ROADMAP.md:163`). Pursuing Q1-as-stated to a Lean conclusion is therefore not an
independent, cheaper route around the engine — it is, by 906's own assessment, as hard as the
barred result itself, and a successful derivation would in substance *be* a proof of completeness
via the full apparatus Recommendation 8 keeps out of Lean.

**Q1, converse direction.** 906's same Recommendation 4 names a genuinely separate, cheaper,
unexplored question: "does `IsLCUAxiom` derive `lcN`?" — "no model-theoretic obstruction to
looking has been established here." This is confined to the schema/derivation-calculus files
(`PlusLCSchema.lean`, `LCExtension.lean`), not the Reynolds engine's chronicle/ban/lull/truth-lemma
content, and nothing in Recommendation 8's text reaches it.

**The guarded-until-form candidate.** 906 Finding 6 / Recommendation 3 records a weaker until-form
schema — `⊡G≤(⟐α → ⟐(⟐β U ⟐α)) → ⟐G≤(⟐α → (⟐β U ⟐α))` — that survives 906's countermodel and
whose `.Base` validity is "open on the same Zorn-plus-Extension-Theorem footing as `lcN`'s," i.e.
a genuine open candidate rather than a settled non-candidate (unlike `lcU` itself, now shown to be
`.ZTime`-only). This, too, is schema-level work outside the engine.

**Q2.** Admissibility of `clock`, `aaFwd`, `aaBwd` is blocked on Di Maio-Zanardo 1998, which
879 already recorded as "not held" in the local Zotero library (line 227), and nothing in 906,
927, or 928 touches it. This is a literature-acquisition gap, not a ruling.

**Ruling:**
- **Q1-as-stated: KEEP CLOSED.** Entangled with the barred engine by 906's own cost assessment;
  reopening it in the direction that would actually resolve T1 is, in substance, reopening the
  engine's completeness proof itself.
- **Q1-converse (`lcN` from `lcU`) and the guarded-until-form candidate's `.Base` validity:
  REOPEN.** Both are schema-level, unexplored, model-theoretically unobstructed, and outside
  §§7-15; either may be filed (paper or Lean, confined to the schema/derivation files named
  above) without touching Recommendation 8.
- **Q2: stays BLOCKED, pending literature acquisition of Di Maio-Zanardo 1998**, not pending any
  ruling. A literature task (`/literature` ingestion, or a Zotero-gap check via `/cite --gaps`)
  is the correct next step, not a research or Lean task against the completeness front.

## Recommendations

1. **File no task against R1 in this repository.** If the `require` ruling or Recommendation 8
   is ever reversed, or Mathlib upstreaming succeeds, re-cost against 928's figures (~1,000
   lines, 4-7 phases) rather than re-measuring from scratch — the costing does not go stale on
   its own terms, only its applicability does.
2. **Take no further action on R2 here.** Tasks 931 and 932, already filed by task 927, carry
   the route forward; this record's role is limited to confirming neither needs a ruling.
3. **If R3 is wanted, file it as a `formal`/research task with `FILE SCOPE: none`**, explicitly
   modeled on 879's P9 / 901's own paper-only posture, and explicitly stating up front that a
   positive design result does not authorize a Lean filing without a separate Recommendation-8
   reversal.
4. **If R4 is wanted, file the converse direction and/or the guarded-until-form candidate's
   `.Base` validity as a `formal` or `lean4` task scoped to `PlusLCSchema.lean` /
   `LCExtension.lean`**, not to any Reynolds-engine file. Do not file Q1-as-stated; do not file
   Q2 as a research task — route Q2 through literature acquisition first.
5. **Record this ruling's terms where a successor will look.** This report is the durable
   record; no amendment to `specs/ROADMAP.md`'s existing Recommendation-8 sentence is needed,
   since this ruling does not change that sentence's truth — it only settles, for R1-R4
   specifically, which parts of each route are and are not reachable without reversing it.

## Decisions

- **No route is reopened as a reversal of Recommendation 8.** Every reopening above (R2, R3's
  paper-only research, R4's converse/guarded-form sub-questions) is a route this record finds
  was never actually blocked by that ruling, not a case of this record overriding it.
- **R1 is ruled on its own standing bar ("do not re-open the CSLib `require` question"), not on
  Recommendation 8's §§7-15 clause.** The two clauses of Recommendation 8 are treated separately
  because 928's costing shows they bind R1 differently: the engine-content clause does not reach
  a general automata lemma, the `require` clause does.
- **No `user_decision` is raised.** Every route's disposition follows from the cited artifacts
  (927, 928, 906, 902, 901) without requiring a preference judgment the record cannot infer; the
  one standing preference question — whether to ever reverse Recommendation 8 or the `require`
  ruling — is not newly live here and is not put to the user as a routine field.

## Risks & Mitigations

- **Risk: a successor reads "REOPEN" for R2/R3/R4 as license to touch the Reynolds engine's
  §§7-15.** *Mitigation*: each reopening above is stated with its exact scope (task 932's
  frame-presentation API; a paper-only R3 task; the schema files named for R4) and the record
  states explicitly, more than once, that Recommendation 8 stays in force for the engine content
  itself.
- **Risk: R1's cost estimate (928) goes stale before any of its three reopening conditions
  fires.** *Mitigation*: 928's estimate is already stated as an order-of-magnitude figure with a
  measured basis (in-tree comparables), not a precision claim; Recommendation 3 above directs a
  successor to re-cost against it rather than treat it as permanently fixed.
- **Risk: Q1-converse or the guarded-until-form candidate turns out, on closer study, to also be
  "as hard as completeness."** *Mitigation*: 906 itself states "no model-theoretic obstruction to
  looking has been established" for the converse and separately shows the guarded form survives
  an actual countermodel attempt (not merely an absence of one) — stronger evidence of
  tractability than Q1-as-stated had before 906's own negative result. If a successor task finds
  otherwise, that finding supersedes this one on the normal record-correction path, not by this
  record being wrong now.

## Context Extension Recommendations

- **Topic**: the two-clause structure of 901's Recommendation 8.
- **Gap**: nothing in the project's context files currently distinguishes the engine-content bar
  from the CSLib-`require` bar as two independently-triggerable rulings; both have so far only
  been read together, as this record's R1 analysis needed to separate them explicitly.
- **Recommendation**: if a future record needs to re-apply Recommendation 8 to a new route,
  state which clause (or both) the route trips, rather than citing "Recommendation 8" as a single
  undifferentiated bar — this record's R1/R2 contrast is the worked example.

## Appendix

### Search queries / lookups used

- `grep -n "927\|928"` against `specs/state.json`/`specs/TODO.md` to locate the companion tasks'
  current status and artifacts.
- Direct reads of `specs/927_final_frame_step_remeasure_against_landed_cover/summaries/01_...md`
  and `specs/928_muller_torabin_determinization_cost_assessment/summaries/01_...md`.
- `grep -n "Recommendation 8"` / `"Finding 4"` / `"require"` against
  `specs/archive/901_.../reports/01_...md`, `specs/archive/902_.../reports/01_...md`,
  `specs/ROADMAP.md` to pin the exact two-clause wording of the standing ruling.
- `grep -n "Q1\|Q2\|unsettleable\|guarded-until\|Recommendations"` against
  `specs/archive/906_.../reports/01_lcu-lcn-separating-model.md` for R4's exact findings.

### References

- `specs/archive/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md`
- `specs/archive/901_two_sided_reynolds_engine_paper_proof/reports/01_two-sided-reynolds-engine-paper-proof.md`
- `specs/archive/902_reassess_lplus_ztime_nogo_cslib_omega_automata/reports/01_...md`
- `specs/archive/903_muller_sufficiency_for_auxiliary_atoms_rule_ztime/reports/01_muller-sufficiency-aa-rule-ban-lull.md`
- `specs/archive/906_lcu_derivability_from_lcn_non_ztime_separating_model/reports/01_lcu-lcn-separating-model.md`
- `specs/927_final_frame_step_remeasure_against_landed_cover/reports/01_final-frame-step-remeasure.md`
- `specs/927_final_frame_step_remeasure_against_landed_cover/summaries/01_final-frame-step-remeasure-summary.md`
- `specs/928_muller_torabin_determinization_cost_assessment/reports/01_muller-torabin-cost-assessment.md`
- `specs/928_muller_torabin_determinization_cost_assessment/summaries/01_muller-torabin-cost-assessment-summary.md`
- `specs/ROADMAP.md`
