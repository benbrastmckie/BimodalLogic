# Findings Note: Book-Paper-Lean Revision

- **Task**: 442 - revise_bimodal_reference_book_against_paper_and_lean
- **Plan**: `specs/442_revise_bimodal_reference_book_against_paper_and_lean/plans/01_book-paper-lean-revision.md`
- **Scope**: what implementation discovered beyond what
  `reports/01_book-paper-lean-sync-audit.md` already covers. That report remains the
  disposition authority for the original 25 Check-1 violations and is referenced here rather
  than duplicated.

## 1. Lean/paper divergences found and NOT fixed here

Per the task's non-goals: no Lean changes were made. Divergences are recorded, not resolved.

### 1a. `nullity_identity` is strictly stronger than `lem:nullity` (open design question)

`TaskFrame.nullity_identity` (`Semantics/TaskFrame.lean`) is stated as an iff
(`TaskRel w 0 u ↔ w = u`), asserting injectivity at zero duration in addition to reflexivity.
The paper's `lem:nullity` asserts reflexivity only. The Lean module's own docstring documents
this as an open design question, not yet settled jointly with other in-flight formalization
work, and names three live options (demote to a derived reflexivity-only lemma; keep the iff as
a deliberate strengthening; keep reflexivity derived and drop injectivity). Recorded in
`typst/chapters/02-semantics.typ`'s Task Frames section (Phase 3); no Lean change made.

### 1b. `completeness_dense`/`completeness_discrete`/`completeness_dedekind` vs. `cor:tm-completeness`'s "none is complete"

`Metalogic/BXCanonical/Completeness.lean` and `Metalogic/StrongCompleteness.lean` state
`completeness_dense`, `completeness_discrete`, and (via `soundness_dedekind`/
`completeness_dedekind`) Dedekind-class results for the frame-class-parameterized **BX** proof
system (Base/Dense/Discrete/Dedekind), sorry-free where claimed. The paper's `cor:tm-completeness`
states that *TM* and its extensions **TM_f, TM_d, TM_c, TM_dc** (the paper's own, more
economical 12-schema presentation) are sound but **none is established as complete**, with a
positive incompleteness proof given for the base case (via the (DD) two-fibre countermodel) and
for TM_c (over {Z,R}), and an explicit "open, not refuted" status for TM_f. The paper gives no
dedicated incompleteness argument for TM_d.

BX is documented elsewhere in this book (`03-proof-theory.typ`, `@sec:paper-contrast`) as "more
fine-grained... not extra strength" relative to TM. Whether the Lean-side Dense/Discrete/Dedekind
BX completeness results are consistent with, contradict, or resolve the paper's claims about
TM_d/TM_f is **not adjudicated in this book**. Two live possibilities were identified but not
resolved: (a) the (DD)-style split-validity argument that refutes TM's base-case completeness
needs *both* a discrete and a dense fibre simultaneously, so it may simply not apply once
restricted to a single subclass (Dense-only or Discrete-only), which would make the Lean results
consistent with the paper; or (b) the Lean results establish something genuinely beyond what the
paper's text currently claims. The general Base-frame `completeness` theorem (unlike its
dense/discrete/Dedekind siblings) carries `sorryAx`, attributed by the module's own audit to a
deprecated dead-code dependency (`WeakCanonical.countermodel_discrete`) rather than to an
identified mathematical obstruction — closing that dependency would not by itself resolve the
Dense/Discrete/Dedekind-vs-TM_d/TM_f question above.

Marked in the book with `LEAN-ANCHOR-MAY-MOVE: canonical-completeness` at every citation site
(04-metalogic.typ x3, 06-notes.typ x1) since this is squarely the territory the in-flight
`completeness_over_total_history_semantics` work touches. **Recommend the user have this
reconciled explicitly**, ideally as part of or immediately after that in-flight task, since it
touches the same `BXCanonical/Completeness.lean` / `StrongCompleteness.lean` files.

### 1c. Total-history semantics: already closed, not still-open as an earlier record suggested

`specs/paper-definitions-of-record.md`'s note on `def:BL-semantics` states that `Truth.lean`
"still takes an explicit `Omega : Set (WorldHistory F)` parameter" for the box clause — a gap
the total-history refactor was expected to close. At this revision, the live
`Semantics/Truth.lean` module's own docstring states plainly: "There is no admissible-history
parameter... The designated-carrier argument that earlier revisions threaded through every
clause has been deleted outright," with `Box` quantifying over `WorldHistory.IsTotal` directly,
matching `def:BL-semantics` exactly. **This gap already appears closed in the live tree**,
ahead of what the tracked record describes. Not treated as a divergence requiring a marker
(TaskFrame/WorldHistory/Truth.lean structure is not itself named in the task description's list
of anchors 415/417/419 will move); recorded here so the discrepancy between the paper-
definitions-of-record note and the live tree is visible to whoever next touches that file.

### 1d. Atom clause: deliberate, documented Lean-side retention of a domain conjunct

`def:BL-semantics`'s atom clause has no domain conjunct (the paper's evaluation point is
already total, so the check is vacuous). `TruthAt`'s atom clause retains
`∃ (ht : τ.domain t)` anyway, documented in the Lean source as "Decision A, accepted gap" —
kept so `TruthAt` stays meaningful at the partial histories the extension machinery traffics in
internally. Not a bug; recorded in `02-semantics.typ`'s Truth Conditions section (Phase 4) as a
deliberate implementation choice, not smoothed over.

## 2. Marker string and every site carrying it

Marker string: `// LEAN-ANCHOR-MAY-MOVE: <scope> -- see typst/README.md`, three scope suffixes
(`canonical-completeness`, `semantic-fmp`, `co-reynolds-independence`). Full occurrence table
(7 sites, file/line/what-it-guards) lives in `typst/README.md`'s Marker Convention section,
kept in sync with a fresh `grep -rn "LEAN-ANCHOR-MAY-MOVE" typst/chapters/`; not duplicated here
to avoid a second copy going stale. The README section's own closing note states explicitly
that the list covers each scope's headline claims, not a claimed-exhaustive sweep of every
secondary prose mention — a full re-audit after 415/417/419 land is still advisable.

## 3. Conservativity-bridge finding (task description §4, non-goal: do not modify that task)

A separate Lean task targets a formalized conservativity bridge between *TM* and *TM*#super[+].
Its premise is `thm:ConservativeExtension`, which **no longer exists in the paper** — it
survives only inside `%% OLD:` comment blocks and a standalone `%% CHANGE` note in
`possible_worlds.tex` stating the prose claim "is false in the same way the labeled theorem
was." `def:TMplus`'s replacement footnote makes no conservativity claim at all; the actual
status is the four-part backward-unconditional / forward-fails-for-base-and-discrete /
forward-open-for-dense-and-complete result now stated in `typst/chapters/p2-frame-classes.typ`'s
`@sec:conservative-extension` section. **That Lean-side bridge task's premise is stale.**
Recorded here per the task description's instruction to raise this with the user; the bridge
task itself was not modified from this task.

## 4. Untracked paper anchors used in this revision

`cor:tm-completeness`, `cor:tm-decidability`, and `def:TMplus` are **not** among the 26 anchors
tracked by `specs/paper-definitions-of-record.md`. Every quote from these three anchors used in
this revision was re-verified directly against the live paper at implementation time (matching
the task description's own section 4/5/6 text closely, confirming those sections were already
accurate as of the task's authoring). `check-paper-definitions.sh`'s case-(a)/(b)/(c) gate does
**not** protect the corrected completeness/decidability/conservativity text in this book against
future drift on these three anchors specifically — a silent paper edit to any of them would not
trip the gate. Extending the tracked set to include them is optional future work, out of scope
here.

## 5. Hölder's theorem citation style (deferred, not resolved)

The paper names Hölder's theorem without a bibliography entry, treating it as a standard named
result available without citation. The book does not currently invoke Hölder's theorem by name
anywhere (confirmed via `grep -rn -i "h.lder\|holder" typst/chapters/*.typ` — no hits), so the
style question the task description raised (name without citation, matching the paper, vs. add
a formal reference) is moot for this revision. Flagged per the task's instruction rather than
resolved unilaterally; if a future expository pass states the fact (a nontrivial discrete
Archimedean totally ordered abelian group is isomorphic to Z), match the paper's own practice.

## 6. `vlach1973nowandthen` citation status (confirmed, not assumed)

The plan hypothesized this bibliography entry "appears to be uncited." Confirmed at
implementation time: it is already cited three times in `p3-vlach-blstar.typ`. No action was
needed; recorded to close out the plan's own flagged uncertainty.

## Acceptance gates (task description §8), confirmed at completion

1. `bash scripts/typst-sync-check.sh` — Check 1 `TOTAL_VIOLATIONS=0`, Check 2
   `MISMATCH_COUNT=0`, Check 3 clean. `PASS (all 3 checks green)`.
2. `cd typst && typst compile BimodalReference.typ build/BimodalReference.pdf` — succeeds, no
   unresolved references or citations.
3. `bash scripts/check-paper-definitions.sh` — exits case (b) at completion (paper's live
   checksum has drifted across the task's own duration, but all 26 tracked definitions remain
   unchanged).
4. `typst/SYNC-MAP.md` — new dated verdict section appended (`## 2026-08-13 Verdict —
   Book-Paper-Lean Revision`); historical tables above it are unmodified (confirmed via
   `git diff` showing only additions, no deleted or altered lines).
5. This findings note.
