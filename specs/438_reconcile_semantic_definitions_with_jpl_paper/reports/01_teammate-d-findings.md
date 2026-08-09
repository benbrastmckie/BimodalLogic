# Teammate D Findings — Long-Term Alignment and Structural Direction

Scope: recurrence prevention, cluster shape, adjacent roadmap leverage, sequencing/risk,
and unconventional framing for the definitional-reconciliation re-issue. This report does
not restate teammate A's clause-by-clause reconciliation, teammate B's per-task verdicts,
or teammate C's adversarial audit; it addresses only the structural questions above.

## Key Findings

1. **The paper is not an occasionally-revised document — it is under continuous, task-numbered,
   diff-tracked revision at high velocity.** `git log --since="14 days ago" -- possible_worlds.tex`
   in the paper's own repository returns **59 commits**; the file has 288 commits total spanning
   2025-03-05 to 2026-08-09 (today). The single most recent commit, `38840a40 task 64 phase 4:
   appendix mirror and gluing-footnote symbol fix`, landed the same day this task was created.
   The definitional churn this task is reconciling is not an anomaly to be mopped up once — it
   is the file's steady state.

2. **The paper already carries its own machine-parseable revision ledger, unused by this repo.**
   Every substantive edit to `possible_worlds.tex` is wrapped in matched
   `%% CHANGE (<tag>): <rationale>` / `%% OLD: <superseded text>` comment pairs — 139 such CHANGE
   markers currently in the file, e.g. at `possible_worlds.tex:2435-2437` around
   \label{def:frame}'s Compositionality clause:
   ```
   %% CHANGE (task 56 package3): Compositionality restated as a biconditional, absorbing
   Interpolation as its right-to-left direction; ...
   %% OLD: \item[\it Compositionality:] If $w \Rightarrow_x u$ and $u \Rightarrow_y v$, then
   $w \Rightarrow_{x + y} v$.
   \item[\it Compositionality:] $w \Rightarrow_{x + y} v$ if and only if $w \Rightarrow_x u$
   and $u \Rightarrow_y v$ for some $u \in W$.
   ```
   This is a durable, already-existing changelog mechanism sitting one `git log`/`grep` away.
   Nothing in this repo's tooling reads it. This is the single highest-leverage fact for
   deliverable 1 (Recurrence-Prevention Mechanism, below).

3. **This repo's own Lean source already has an informal, now-stale citation convention
   pointing at the paper**, which independently corroborates that a citation mechanism is the
   right shape of fix, not a novel invention. `FormalSystem/Semantics/TaskFrame.lean:47-48`:
   ```
   - Paper's *Nullity* is an iff, and `nullity_identity : TaskRel w 0 u ↔ w = u` is an exact match.
   - Paper's *Compositionality* on the positive cone is `forward_comp`, whose `0 ≤ x`
   ```
   These docstring citations are bare prose, untagged, and unchecked by any script — exactly the
   failure mode that has now let two consecutive rounds of drift through undetected until an
   agent happened to re-read the paper by hand.

4. **`specs/ROADMAP.md`'s own "Paper Alignment Programme" section (lines 1599-1641) is itself a
   fourth stale artifact that Part B of this task's deliverables does not cover.** It states
   "same-sign frame axioms with identity Nullity ... official validity = maximal-history
   validity" — the *previous* superseded generation (matching 414/415's current descriptions,
   not the four-axiom/totality generation this task is reconciling to). Part B's deliverable 6
   only rewrites the six cluster tasks' `description` fields in `specs/state.json`; it does not
   mention `ROADMAP.md`. Left as-is, the roadmap will keep telling the next reader (human or
   agent) the wrong axiom count and the wrong validity predicate even after Part B completes.

5. **The paper's own task numbering (task 51, 52, 53, ... 64 in its commit messages) is
   namespace-identical to this repo's task numbering** (task 414, 415, ... 438). This is a
   standing citation hazard: "task 56" means something in the paper's git history and something
   entirely different in `specs/state.json`. Worth flagging explicitly in any re-issued
   description that quotes a paper commit message, so a future reader does not conflate the two.

## Recurrence-Prevention Mechanism

The question is not whether the paper will change again — the commit cadence above answers
that — but how to make the *next* revision cost one script run and one diff review instead of
another full-cluster re-derivation.

| Option | Mechanism | Cost | Durability | Verdict |
|---|---|---|---|---|
| **A. Generated definitions-of-record file** | A script extracts the fixed set of `\label`-anchored `Ddef`/`Lthm`/`Tthm`/`Cthm` environments this cluster depends on (def:frame, lem:nullity, def:world-history, app:gluing, lem:segments, thm:extension, thm:occurrence, def:frame-properties, def:frame-validity, def:BL-semantics, cor:tm-completeness, thm:ConservativeExtension) into a single generated file, e.g. `specs/paper-definitions-of-record.md`, that both cluster specs and repo prose cite instead of re-quoting the paper freehand. | Low one-time (a python/awk extractor keyed on `\label{...}` through matching `\end{...}`) + near-zero marginal (re-run on demand) | High if paired with a hash check (below); the file itself does not go stale silently because regenerating it is cheap and mechanical | **Recommended, combined with C** |
| **B. \label-anchored citation convention alone (no automation)** | Just enforce "cite by \label + verbatim quote, never bare line number" as a written norm (this task's description already does this for Part B). | Zero tooling cost | Low alone — a norm with no checker is exactly what let 420/427/419's line-number anchors go stale twice already; \label anchors survive line-shift but not *content*-shift (a \label can persist while the text under it changes, as `def:frame` demonstrates: same label, three colliding axiom generations) | Necessary floor, insufficient by itself |
| **C. Checked-in hash of the paper's definition environments + a lint script (`check-*.sh` family)** | Store, per cluster task, the git SHA of `possible_worlds.tex` (or a content hash of the extracted block from Option A) at the time its description was last verified against the paper — e.g. a `paper_anchor_commit` field alongside each task in `state.json`. A new script `.claude/scripts/check-paper-definitions.sh`, structurally parallel to `check-task-references.sh`, diffs the stored commit/hash against the paper repo's current `HEAD` for the tracked labels and exits non-zero (or prints a loud banner, matching the `[SPARSE COVERAGE ...]`/`[UNVERIFIED ...]` banner family already used by the literature extension) when they diverge. | Low-to-moderate (new field + new script + one wiring point, e.g. as an optional gate in `/research`/`/plan` preflight for tasks whose `topic == "paper-refactor"`) | High — this is the only option that produces an *active, non-silent* signal the moment the paper moves again, rather than relying on a human or agent noticing | **Recommended, combined with A** |
| **D. Make the Lean tree the second source of truth instead of the paper's prose** | Invert the authority direction: once a definition is machine-checked in Lean, treat the Lean declaration (not the paper prose) as authoritative for downstream tasks, with the paper checked *against* Lean rather than the reverse. | High (contradicts the explicit user decision recorded in this task's description: "the Lean tree ... [is] downstream and must be refactored to match [the paper] faithfully. Any conflict resolves in the paper's favour") | N/A — not adoptable without overriding a stated user decision | **Rejected as stated; revisit only if the user's authority ruling changes** — see Unconventional Angles below for why it is nonetheless worth surfacing |
| **E. A single generated typst/LaTeX include the paper's own build pulls from this repo (reverse sync)** | Instead of this repo re-deriving from the paper, have the paper's build system `\input` a generated snippet this repo exports whenever Lean changes, so the paper cannot drift from Lean either. | High (requires write access / build coupling into `/home/benjamin/Philosophy/Papers/...`, which is explicitly out of this task's non-goals and, more importantly, would invert deliverable direction — the paper is external, user-owned research output, not a build artifact of this repo) | N/A | **Rejected** — conflates "prevent this repo's drift" with "control the paper," which is not this task's mandate |

**Recommendation: A + C together.** Generate `specs/paper-definitions-of-record.md` from the
paper's `\label`-anchored environments (Option A), and gate it with a lint script plus a stored
per-task anchor commit (Option C). This is the only combination that (a) gives every cluster
task and every piece of repo prose one place to cite instead of six independently-drifting
paraphrases, and (b) turns "the paper changed again" from a fact someone has to notice into a
script that fails loudly — the same posture this repo already uses for literature sparse-
coverage detection and task-reference-lint (`.claude/scripts/check-task-references.sh`,
`.claude/scripts/literature-briefing.sh`'s `<!-- lit-coverage ... -->` marker). Concretely for
Part B of this task: the six rewritten descriptions should cite `specs/paper-definitions-of-
record.md` line-items rather than re-quoting the paper inline six separate times, since inline
re-quoting is exactly the mechanism that produced today's re-issue (three independent
paraphrases of `def:frame`'s Compositionality clause, each frozen at a different paper commit).
Building the extractor script itself is out of *this* task's Part A/B scope (it edits nothing
under `FormalSystem/`, `latex/`, `typst/`, or the paper, but it does create new `.claude/`
tooling, which is a `meta`-type change under this repo's own routing table) — record it as a
recommended follow-up `meta` task rather than implementing it here.

## Cluster Shape Assessment

The task description frames the six-task decomposition (414/415/417/419/420/427) as fixed and
asks only for corrected descriptions. It is worth stress-testing that shape once, concretely,
before Part B commits six more descriptions to it.

**The decomposition is still defensible, with one caveat.** The six tasks split along genuinely
separable concerns — semantics refactor (414), completeness (415), FMP (417), an independence
argument (419), the frame-axiom Lean landing itself (420), and the typst book sync (427) — and
420 already has five landed, green, committed phases that a "land the whole four-axiom
TaskFrame atomically" alternative would have to either discard or awkwardly absorb. Collapsing
414+420 into one atomic task now, after 420 phases 1-5 are committed, would either (a) require
reverting green work to fold it into a bigger task, which contradicts the explicit instruction
that 420's landed phases must not be presented as undone, or (b) require 420 to stay a separate
task anyway, i.e. no real collapse.

**The caveat**: 414 and 420 are more tightly coupled than the task list's dependency edges
currently suggest, and the paper itself explains why. \label{app:gluing}'s footnote
(`possible_worlds.tex:2590`) states plainly: *"gluing along a directed family of domains rests
on Spherical rather than on composition alone ... making the assignment of world histories to
convex domains glue over directed covers"* — and 438's own description already notes this
coupling for (A)/(B) generally. Concretely: 420 owns landing Spherical (a def:frame axiom) as a
Lean field, but thm:extension — the theorem that makes 414's totality predicate non-vacuous —
needs Spherical as a *hypothesis*, not merely a *field*. If 420's phase 6 lands Spherical as an
unused structure field while 414 separately re-derives totality machinery without threading
Spherical through, the two tasks can each go green while jointly failing to reconstruct
\label{thm:extension}. **Recommendation**: rather than re-scoping the six tasks, add an explicit
cross-task acceptance criterion to both 414 and 420's re-issued descriptions: 420 phase 6 is not
done until 414 (or a shared research artifact) confirms the Spherical field's statement is
literally the hypothesis thm:extension's proof consumes, not merely a same-named axiom typed
into the structure. This is a stronger dependency-content constraint than the topological
Kahn-graph edge alone can express, and it belongs in the task text, not just the edge list —
this is a discovery that should feed teammate B's deliverable 5/9 dependency-edge work, not a
call to alter the six-task count.

**A second, smaller shape observation**: 419 (CO/Reynolds independence) and 427 (typst sync) are
consumers, not producers, of the other four tasks' definitional output. Nothing about the
definitional change argues for merging them into the producer tasks — if anything, the paper's
own churn argues for keeping "produce the Lean landing" and "propagate it to prose/adjacent
arguments" as separately re-runnable units, since a producer task re-running (say 420 phase 6
needing rework after a future paper revision) should not force 427's typst work to be redone
from scratch if 427 has already synced against a stable-enough intermediate snapshot. Splitting
finer would only be worth it if 427 or 419 were themselves independently blocked on unrelated
work, which the current state.json entries do not show (419 `not_started`, 427 `not_started`,
both waiting purely on the producer chain).

## Adjacent Roadmap Leverage

`specs/ROADMAP.md:1599-1641` ("Paper Alignment Programme") already threads the *previous*
generation of this same alignment effort through the completeness and decidability programmes.
Re-checking that threading against the *current* (four-axiom/totality) generation:

- **Completeness capstone (task 362, `completeness_capstone_consequence_all_classes_strong_where_compact`,
  status `not_started`) and the weak/strong distinction.** \label{cor:tm-completeness}
  (`possible_worlds.tex:3750-3754`) now reads: *"$\textbf{TM}$ ... are all \textit{weakly}
  complete ... \textit{Strong} completeness ... fails for the discrete and complete classes,
  where compactness fails."* This wording is unchanged by the (A)/(B) revisions under
  reconciliation here (it predates them, per `ROADMAP.md:1630-1631` already scoping it to weak
  completeness) — the totality/Seriality/Spherical changes do not touch the weak/strong
  terminology question. **This means 438's re-issue does not newly block or unblock task 362**;
  it only changes the semantic substrate 415's completeness constructions build on top of, which
  414/415 already flag. Worth stating explicitly in 415's re-issued description so a future
  reader does not conflate "completeness semantics changed" with "completeness scope (weak vs.
  strong) changed" — they are independent axes.

- **Conservative-extension bridge (task 413, `formalize_tm_conservativity_bridge`,
  `not_started`).** \label{thm:ConservativeExtension}'s proof (`possible_worlds.tex:3744-3748`)
  is explicitly gated on task 413 by name in the paper itself: *"the forward direction is being
  formalized in the Lean 4 ... repository: TM's own language and proof system are not yet
  formalized there, so this direction is not yet machine-checked."* Task 413 concerns TM's proof
  system and language embedding, not TaskFrame/WorldHistory semantics — it is plausibly
  orthogonal to the (A)/(B) reconciliation and should stay unblocked by this re-issue. Flag as a
  candidate for explicit "unaffected, no re-issue needed" confirmation rather than silent
  omission, since the paper cites it by number and a careless reader might assume anything the
  paper name-checks is in scope.

- **FMP (task 417) gets a genuinely easier late-stage step from Spherical, not a harder one.**
  Spherical's statement (`possible_worlds.tex:2454`, \label{def:frame}) requires nonempty
  intersection for any $\supseteq$-directed family of nonempty segments. Over a **finite**
  `WorldState` (417's target, `D = ℤ`... but W finite), a strictly-descending chain of nonempty
  subsets of a finite set must stabilize after finitely many steps (pigeonhole on set size), and
  directedness supplies exactly the descending-chain structure needed to reach that stable
  nonempty member — i.e. Spherical is very plausibly *free* (a finite-set corollary, not a
  fresh proof burden) once Seriality is discharged over a finite frame. This is a genuine
  candidate discovery for whoever re-researches 417 under the corrected target signatures (Part
  A deliverable 2): flag it as a research lead rather than asserting it proven here (this report
  does not touch `FormalSystem/`, per non-goals, and the claim needs a real Lean proof attempt,
  not a hand-wave).

- **Tableau decidability (410/411/412) and shift-set representation (424) are very likely
  orthogonal to this reconciliation.** Nothing in the (A)/(B) changes described in this task
  touches BX's provability side, the shift-set/tableau machinery, or the discrete/dense/complete
  frame-class predicates that gate 424. These sit downstream of `def:frame-properties`
  (`possible_worlds.tex:2841-2849`, Discrete/Dense/Complete/Deterministic), which is unchanged
  by the axiom-count and totality revisions. No action needed, but worth a one-line confirmation
  in the re-issued task descriptions so the "does this ripple further" question doesn't get
  silently re-asked by a future agent triaging the tree.

- **`ROADMAP.md`'s Paper Alignment Programme section itself should be queued for a follow-up
  edit** once Part B lands, since (per Key Finding 4) it currently states the superseded
  three-axiom/maximal-history generation as settled fact. This is out of this task's stated
  non-goals (it touches neither `specs/state.json` nor the six task descriptions), but leaving
  it unflagged would mean the *next* roadmap reader inherits exactly the same stale-definition
  problem this task exists to fix, just one file over. Recommend recording it as a named
  follow-up in this task's completion summary rather than silently absorbing it into Part B's
  scope.

## Sequencing and Risk

Given the paper's revision cadence (59 commits in 14 days, latest same-day as this task), the
question "should Lean work wait for the paper to stabilize" needs a real answer, not a default.

**There is no visible stabilization signal to wait for.** The commit messages show the paper's
own author running a phased task-by-task revision process structurally identical to this repo's
own (`task 56 phase 1..7`, `task 58 phase 1..3`, ..., `task 64 phase 1..4`), which suggests
revision is the paper's steady operating mode through at least its current writing phase, not a
transient spike about to settle. Waiting for stabilization is not a bounded-cost strategy here.

**What is safe to land now, because it is invariant under the *plausible* revision surface**:
the machinery that has been re-derived, re-stated, and re-verified identically across the last
several paper commits without changing content — i.e. content that keeps getting *restated* in
different sections rather than *changed*. Two concrete candidates, both evidenced by the
inline CHANGE-comment trail itself:
  - **The converse convention** ($w \Rightarrow_x u := u \Rightarrow_{-x} w$ for $x < 0$) has no
    CHANGE marker touching its substance anywhere in the file's history search above — it is
    quoted identically in `def:frame`'s Task Relation clause and reused verbatim by
    `def:world-history`, `app:gluing`, `lem:segments`, and `thm:extension`'s proofs. This is
    already correctly landed in Lean per `FormalSystem/Semantics/TaskFrame.lean:179` (`converse`
    field) and 438's description confirms it as "Unchanged."
  - **Nontrivial `D`** — flagged `%% CHANGE (fix.md A2)` at `possible_worlds.tex:2416-2418` as
    the *oldest* surviving change in the current def:frame block (predating the Seriality/
    Spherical/totality package by many commits) — is comparatively stable and already a known
    Lean gap per 438's description ("absent, and already flagged in-file as known gaps: ... a
    `[Nontrivial D]` structure binder"). Landing `[Nontrivial D]` carries low risk of being
    invalidated by the next revision, since it long predates the current churn cluster.

  Both are narrow, mechanically low-risk additions that do not touch the coupled
  Seriality/Spherical/totality core — exactly the subset that should NOT wait, because it is
  the part of the paper that has stopped moving.

**What should explicitly wait, or be scoped defensively**: anything that has to state the exact
wording of Spherical or the totality-quantification clause verbatim in a place other than the
recommended definitions-of-record file (Recurrence-Prevention Mechanism, above) — those clauses
carry the freshest CHANGE markers (`sphericity-promote`, `sphericity-hoist`, `sphericity-formal`,
`sphericity-wording`, all landed within the last handful of commits per the tag list) and are
the most recently-settled, least-battle-tested parts of the current def:frame generation. Any
re-issued cluster description that must quote Spherical or totality verbatim should quote it
*once*, in the definitions-of-record file, and have every task cite that file by pointer — this
is the direct operational payoff of the Option A+C recommendation above: it converts "the
riskiest clause changes again" from "six paraphrases go stale" to "one file needs regenerating
and six citations still resolve."

**Process risk distinct from content risk**: this is the *second* time in this cluster's history
that a mid-flight paper revision has invalidated already-completed research (task 438's own
description: "changed AGAIN"). A third occurrence during the *re-issued* research window is not
merely possible, it is likely given the commit cadence. Recommend the re-issued descriptions for
414/415/417/419 (the four tasks whose research must re-run) explicitly instruct the next
research dispatch to check the paper's git log for commits since a stated date/SHA as its very
first research step, before re-reading any definition — this is cheap (one `git log --since`
call) and directly forecloses a third silent-drift cycle.

## Unconventional Angles

**Challenging "paper as sole source of truth, everything downstream" is worth naming even though
this task's description resolves it explicitly.** The description states, as a recorded user
decision dated today: *"the Lean tree, this repo's latex/ prose, and this repo's typst/ book are
ALL downstream and must be refactored to match [the paper] faithfully. Any conflict resolves in
the paper's favour."* That is a clear, current, binding instruction, and Option D above is
rejected against it. But it is worth surfacing the tension the evidence above makes visible:
the paper's own `\label{thm:ConservativeExtension}` proof (`possible_worlds.tex:3744-3748`)
already treats the Lean repository as an authority for its *own* forward-direction claim ("the
forward direction is being formalized in the Lean 4 ... repository"), and \label{cor:tm-
completeness}'s proof cites machine-checked status in the repo as evidence for specific frame
classes. The paper is not purely upstream of the Lean tree even today — it already leans on Lean
for some of its own claims' justification. This is not a call to reverse the authority ruling;
it is a note that the relationship is bidirectional in practice for a subset of claims (proof-
existence claims about TM$^+$'s own theorems), even while the *definitional* core (what this
task reconciles) is correctly one-directional, paper-to-Lean, per the user's explicit ruling.
If a future revision round finds itself arguing about authority direction again, this
asymmetry — definitions flow paper→Lean, but some proof-existence claims flow Lean→paper — is
worth having on record rather than re-discovering.

**A second unconventional angle: treat the recurrence itself as the deliverable, not a nuisance
around the deliverable.** This task's title is a "re-issue," implying the definitional churn is
an unwelcome interruption to otherwise-linear cluster progress. An alternative framing: a paper
under active peer-facing revision *should* be expected to keep moving until submission, and a
cluster whose research artifacts cannot survive that motion is mis-scoped regardless of how
many times it gets corrected. Under this framing, the actual success criterion for task 438 is
not "get back in sync once more" but "stop needing to get back in sync" — which is exactly what
the Option A+C mechanism targets, and is offered here as the argument for treating that
mechanism as a first-class, not optional-nice-to-have, follow-up rather than a suggestion buried
in a report.

## Evidence

- Task description: `jq -r '.active_projects[] | select(.project_number==438) | .description'
  specs/state.json` (full text read in full before this report was written).
- Paper commit velocity: `cd /home/benjamin/Philosophy/Papers/PossibleWorlds/JPL && git log
  --since="14 days ago" --oneline -- possible_worlds.tex` → 59 commits; `git log --oneline --
  possible_worlds.tex | wc -l` → 288 total; first commit 2025-03-05, most recent 2026-08-09
  (`38840a40 task 64 phase 4: appendix mirror and gluing-footnote symbol fix`).
- CHANGE-marker count: `grep -c "%% CHANGE" possible_worlds.tex` → 139.
- \label{def:frame}: `possible_worlds.tex:2412-2465` (Compositionality biconditional quoted at
  :2437; Seriality at :2446; Limit at :2451; Spherical at :2454, footnote at :2455-2458 citing
  Cmiel2021 and Kubis2019).
- \label{lem:nullity}: `possible_worlds.tex:2489-2497` (derived from Seriality + Limit).
- \label{def:world-history}: `possible_worlds.tex:2570-2579` (totality clause at :2577).
- \label{app:gluing}: `possible_worlds.tex:2584-2607`, footnote on Spherical-dependence of
  directed gluing at `possible_worlds.tex:2590`.
- \label{lem:segments}: `possible_worlds.tex:2611-2622`.
- \label{thm:extension}: `possible_worlds.tex:2625-2648`, footnote on Zorn/AC dependence at
  `possible_worlds.tex:2628-2629`.
- \label{thm:occurrence}: `possible_worlds.tex:2651-2658` (derived, not axiomatic).
- \label{def:frame-properties}: `possible_worlds.tex:2841-2849`.
- \label{def:frame-validity}: `possible_worlds.tex:2851-2865`.
- \label{def:BL-semantics}: `possible_worlds.tex:2677-2701`, box clause at :2696 (`for all
  σ ∈ H_F`).
- \label{thm:ConservativeExtension}: `possible_worlds.tex:3729-3748`.
- \label{cor:tm-completeness}: `possible_worlds.tex:3750-3764`.
- `specs/ROADMAP.md:1599-1641`, "Paper Alignment Programme" section, stale relative to current
  paper state (asserts three-axiom frame + identity Nullity + maximal-history validity).
- `FormalSystem/Semantics/TaskFrame.lean:47-48, 77-79, 152, 163, 177, 179` — current Lean
  structure fields and their (partly stale) inline paper-citation docstrings, read directly to
  corroborate task 438's description's claims about current repo state.
- `specs/state.json`: dependency edges for 414/415/417/419/420/427 confirmed via `jq` query
  (420 deps=[415,438]; 419 deps=[438]; 414 deps=[420,438]; 415 deps=[414,420,438]; 417
  deps=[414,420,438]; 427 deps=[414,415,417,419,420,438]); adjacent-roadmap task statuses for
  362, 413, 410, 411, 412, 424 confirmed via `jq` query, all `not_started` or `planned`.
- `.claude/scripts/` directory listing confirms the `check-*.sh` naming family this report's
  Option C recommendation is modeled on (`check-task-references.sh`, `check-extension-docs.sh`,
  `check-runtime-file-tracking.sh`, `check-vault-threshold.sh`), and the `literature-briefing.sh`
  `<!-- lit-coverage ... -->` non-silent-marker pattern cited as precedent (per CLAUDE.md's
  Literature Mode section).

## Confidence Level

- **High confidence**: paper commit velocity and CHANGE-marker mechanism (directly observed via
  `git log`/`grep`, not inferred); the six-task dependency edges and adjacent-task statuses
  (directly read from `state.json`); the quoted paper text (verbatim `Read` of the source file);
  the current Lean `TaskFrame` field state (directly read, corroborates rather than merely
  trusts the task description).
- **Medium confidence**: the Spherical-over-finite-W "free corollary" claim under Adjacent
  Roadmap Leverage — this is a plausible mathematical lead grounded in a standard finite-set
  descending-chain argument, but it has not been attempted in Lean and is offered as a research
  starting point, not a verified result.
- **Speculative, marked as such**: the "recurrence itself as deliverable" reframing and the
  bidirectional-authority observation under Unconventional Angles are interpretive arguments,
  not factual claims, and are offered for the user's judgment rather than as findings to act on
  without review.
