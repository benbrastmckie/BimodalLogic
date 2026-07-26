# Implementation Summary: Task #196 — Codebase Tactic Survey

**Status**: IMPLEMENTED
**Session**: sess_1785103409_6af9e1_196
**Date**: 2026-07-26
**Deliverable**: `specs/196_codebase_tactic_survey/reports/02_automation-survey.md` (sections 1-7)

This was a survey. **No `.lean` file was modified.** No Edit or Write call in this run targeted
any path under `Theories/`.

---

## 1. The three survivor decisions

These are the task's mandated highest-value output. Each is recorded here before any state
mutation, so the analysis survives even if a `state.json` write is lost to a concurrent writer.

### Task 186 `unify_search_systems` — **ABANDON**

**Driving measured number**: **0** real proof-site invocations of `modal_search`,
`temporal_search`, `propositional_search` and `tm_auto` across the entire 178K-line proof surface
(`Metalogic/`, `Theorems/`, `Semantics/`, `ProofSystem/`, `Syntax/`, `FrameConditions/`).

186 proposed spending 15 hours unifying two search engines so each gained the other's strengths.
The premise that capability is the binding constraint has already been tested and refuted: task
185 raised `tryAxiomMatch` from 12 to 42 axiom constructors and added 26 derived theorems, and
adoption stayed at exactly 3 invocations, all in `Examples/`. Its dependency on task 199 also
cannot be satisfied as intended — 199 is `[partial]` and produced no tactic.

**Preserved finding**: `bounded_search_with_proof` is genuinely incomplete —
`Automation/ProofSearch/Core.lean:1193-1196` still skips modal K and temporal K. A real defect,
in code with zero call sites.

**Completion summary applied to state.json**:
> Abandoned by the codebase tactic survey. Measured 2026-07-26: the search-tactic family this
> task would unify (modal_search, temporal_search, propositional_search, tm_auto) has ZERO real
> proof-site invocations across the entire 178K-line proof surface; the only 3 invocations
> anywhere are in Examples/BimodalProofs.lean. The premise that capability is the binding
> constraint was already tested and refuted by completed task 185, which raised tryAxiomMatch
> coverage from 12 to 42 axiom constructors with zero change in adoption. Its dependency on task
> 199 also cannot be satisfied: 199 is partial and produced no tactic. Preserved finding:
> bounded_search_with_proof genuinely lacks modal K and temporal K
> (Automation/ProofSearch/Core.lean:1193-1196) — a real defect in code with zero call sites. See
> specs/196_codebase_tactic_survey/reports/02_automation-survey.md section 6.1.

### Task 192 `master_tactic_dispatch` (`tm_prove`) — **ABANDON**

**Driving measured numbers**: **0** combined real proof sites across every sub-tactic `tm_prove`
would dispatch to; **129** live `Derivable` references showing its one durable idea already
shipped without it.

A dispatcher's value is bounded by what it dispatches to. All five of 192's dependencies (185,
187, 190, 191, 194) completed and were archived, so 192 has been fully unblocked with every
prerequisite in hand — and in that time nobody even wrote a description for it.

**Preserved finding**: the `Derivable`/`DerivationTree` transfer principle was 192's real
contribution and is **not lost** — it landed via task 181 (`ProofSystem/Derivable.lean:69`,
`.ofTree` at :99, `.lift` at :110, 129 references). The Aesop half cannot ship: `DerivationTree`
is still `Type`, not `Prop` (`Derivation.lean:91`), which is exactly why the Aesop rule set was
deprecated.

**Completion summary applied to state.json**:
> Abandoned by the codebase tactic survey. Measured 2026-07-26: every sub-tactic tm_prove would
> dispatch to has ZERO real proof-site invocations, so a dispatcher over them has no value to
> deliver. All five dependencies (185, 187, 190, 191, 194) completed and archived, leaving 192
> fully unblocked with every prerequisite in hand — and it still had an empty description, which
> is a judgment already made and never recorded. Its one durable idea, the Derivable/DerivationTree
> transfer principle, already shipped independently via task 181: ProofSystem/Derivable.lean:69
> with 129 live references. The Aesop half cannot ship because DerivationTree is still Type, not
> Prop (Derivation.lean:91). See
> specs/196_codebase_tactic_survey/reports/02_automation-survey.md section 6.2.

### Task 193 `codebase_tactic_refactor` — **RE-SCOPE**

**Driving measured numbers**: **153** occurrences of `intro F M Omega _h_sc τ _h_mem t` (148 of
them in two files) and **173** occurrences of `simp only [truth_at, …]` (131 in three files, two
of them the same two).

193 is the only survivor whose deliverable is *application* rather than *construction* — the
shape of work the evidence supports. What was wrong was its target (`Theorems/`, 3.8% of the
tree, sorry-free and stable) and its instrument (`tm_prove`, now abandoned), not its kind.

**New scope**: define `intros_validity`, `intros_validity_framed`, `simp_truth` and
`unfold_validity` as single-line macros, and apply them in ONE pass over
`Metalogic/SoundnessLemmas/DenseValidity.lean` (92 + 54 sites),
`Metalogic/SoundnessLemmas/FrameClassVariants.lean` (56 + 30) and `Metalogic/Soundness.lean`
(47). Completion criterion is measured reduction in proof text, not the existence of macros.

**Dependencies**: `[189, 192, 196, 402]` → `[402]`. 189 archived, 192 abandoned, 196 completing
now, 402 retained.

**`file_scope`**: `["Theories/Bimodal/Automation/Tactics/",
"Theories/Bimodal/Metalogic/SoundnessLemmas/", "Theories/Bimodal/Metalogic/Soundness.lean"]`

**Effort**: 8 hours.

### Downstream tasks 177 and 178: no edits required

Both declare `dependencies: [131, 193, 402]`. Because 193 is **re-scoped rather than abandoned or
merged**, both edges on 193 stay valid and **neither task needs to be touched**. This was a
deliberate argument for re-scoping over abandoning: abandoning 193 would have orphaned two edges
and forced edits to two further tasks during a window when `state.json` has no locking and three
agents are writing to it. Both 177 and 178 already depend on 402 directly, so 193's new 402
dependency adds no ordering constraint.

---

## 2. Ranked inventory headline

Ten groups ranked by `Score = (R × D) × C × A / X` — reach × density, scaled by concentration and
an **adoption factor**, divided by complexity. Sorry-impact was deliberately dropped from the
formula: with exactly **one** executable sorry left in 185,531 lines, it carries no signal.

| Rank | Group | Score |
|------|-------|-------|
| 1 | MCS axiom application (`mcs_mp`) | 225 |
| 2 | Validity intro macro | 153 |
| 3 | Truth simp bundle | 72.7 |
| 4 | EF-game tactic application pass | 56.4 |
| 5 | `tauto` / `by_contra` audit | 28.0 |
| 6-10 | subformulas simp, `modus_ponens` search, `deduction_theorem`, `imp_trans`, `push_neg` | 20.5 → 4.0 |

**All ten groups are naming-upgrade sensitive**, and that uniformity is the finding rather than
an oversight: realizing any of them means a mass edit of proof text, and a mass proof rewrite
must not race the mass rename in task 402. The only naming-upgrade-independent work available is
*defining* a tactic without applying it — precisely the activity that produced ~5,800 lines of
unused automation.

---

## 3. The adoption verdict

**More bespoke tactic development is not warranted, and no task should be chartered to build a
tactic as its deliverable.**

- ~5,800 lines of proof automation exist, are tested, and survive the post-168 architecture.
- Total real proof-site invocations: **38** — all in one file, all from the one tactic family
  (`simp_game_tuple`, `order_refl`) that was written against a specific measured file.
- Every family written against a general notion of "modal proof" has **zero** uptake.
- `modal_search`'s only mention in a real proof file is a comment at `Theorems/Combinators.lean:92`
  explaining that it *cannot* prove the goal.
- The `@[simp]` count moved from 147 to **151** in two months, despite all four teammates of a
  prior research round independently calling it the highest-leverage, zero-risk improvement.
  `registerSimpAttr` appears exactly once in the tree — in a comment declining to use it.
- Task 199, the one live bespoke-tactic experiment, produced **no tactic at all**: its Phase 1
  `fan_order` theorem is provably false (counterexample `p=0, a=1, b=2, q=0, a'=2, b'=1`), Phase 2
  depended on it, and Phase 3 closed 3 of 6 goals by hand-written proofs. The binding cost of a
  bespoke tactic here is not implementation difficulty — it is that a tactic encodes a *claimed*
  uniformity whose truth is usually unknown at planning time.

Tactic work is permitted only under all four preconditions: (1) application, not construction, is
the deliverable; (2) the uniformity is verified before chartering, not assumed; (3) the target is
a specific measured file set, not a layer; (4) the work is sequenced behind task 402.

---

## 4. What the May 2026 research got wrong

Nine conclusions were invalidated or superseded (report section 3). The three that mattered most:

- **Sorry-driven prioritisation is dead**: ~41 executable sorries → **1**
  (`Metalogic/WeakCanonical/Transfer.lean:1242`).
- **The "single highest-ROI action" is unexecutable**: its target file
  `ExpressivenessGeneral.lean` has been **deleted from the tree entirely**, and its named sorries
  no longer exist.
- **The largest line-savings estimate targets dead code**: `Hierarchy.lean`,
  `TemporalClosure.lean`, `Duality.lean`, `DedekindZ.lean` and `ExpressiveCompleteness.lean` are
  all now in `Boneyard/`.

Of 42 cited `.lean` paths: 6 split into directories, 5 moved to `Boneyard/`, 1 deleted, 30
survive (23 only under a corrected prefix).

---

## 5. New task creation: DEFERRED

This run had `orchestrator_mode: true`. No interactive prompt is available, so the multi-task
creation standard's mandatory user-confirmation component cannot be satisfied. **Per the plan's
Phase 6 branch, no new tasks were created.**

Three ready-to-run `/task "…"` invocations are left in report section 7, complete with measured
site counts, go/no-go gates and inline 402-dependency rationale:

| Proposal | Slug | Effort | Deps |
|----------|------|--------|------|
| A | `mcs_axiom_application_pass` | 14h | `[402]` |
| B | `ef_game_tactic_application_pass` | 10h | `[402]` |
| C | `normalization_module_triage` | 3h | `[]` — rewrites no proof bodies, stated inline |

Proposals A and B cover ranked groups 1 and 4; groups 2 and 3 are covered by the re-scoped 193;
the remaining six are deliberately not spawned, each with a one-line reason (section 7.5).

---

## 6. Staleness horizon of this survey

- **Names**: every declaration name cited is as of 2026-07-26. Occurrence *counts* survive task
  402's rename; the literal grep *strings* do not. Re-derive any grep-expressed claim after 402.
- **Paths**: six of the May report's named files were split into directories in roughly two
  months. Path-level claims have a half-life of weeks; ratio- and ranking-level claims are
  durable.
- **Concurrency**: three agent sessions were writing to the repository during measurement. One is
  actively rewriting `Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean`
  (13,405 lines at 22:13 UTC — a moving target). No recommendation depends on that file. Counts
  may drift a few units; no conclusion turns on a difference under ~20 occurrences.

---

## Plan Deviations

- None. All six phases executed as planned. Phase 6's new-task branch resolved to the autonomous
  path (create no tasks, emit `/task` invocations) exactly as the plan specified for
  `orchestrator_mode: true`.
- One process note, not a deviation from the plan: the plan's per-phase verification
  `git status --porcelain -- 'Theories/**/*.lean'` returns non-empty from Phase 2 onward, because
  a concurrent agent is modifying
  `Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` and adding
  `SharedWitness/Carrier.lean`. Those changes are not this task's. This run issued no Edit or
  Write call against any path under `Theories/`, and every commit it made staged only explicit
  paths under `specs/196_codebase_tactic_survey/` (plus `specs/state.json` and `specs/TODO.md` in
  Phase 6) — verifiable from `git show --stat` on commits `e58b49083`, `cc1b56405`, `6bd3b9537`,
  `c58ee16f7`, `e824318d6`.
