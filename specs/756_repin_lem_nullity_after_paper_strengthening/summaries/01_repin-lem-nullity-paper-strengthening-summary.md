# Implementation Summary: Task #756

- **Task**: 756 - Re-pin `lem:nullity` in the paper definitions of record after the JPL paper strengthened it from an implication to a biconditional, and correct the in-tree docstrings that quote the retired wording
- **Status**: [COMPLETED]
- **Started**: 2026-10-14T22:10:00Z
- **Completed**: 2026-10-14T23:29:41Z
- **Effort**: ~3.5 hours (dominated by three full-tree Lean builds, ~15 min each)
- **Dependencies**: None
- **Artifacts**: plans/01_repin-lem-nullity-paper-strengthening.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The live JPL paper had drifted far past the single `lem:nullity` anchor the task description
assumed: `scripts/check-paper-definitions.sh` was red with **27** drifted anchors. The paper moved
**four** times over this task's lifecycle — once between research and planning, once between
planning and execution (HEAD `9359505a` → `0a51a798`, 3959 → 3961 lines), and once more mid-Phase-8,
when `def:id` re-drifted after all 27 anchors had already been re-pinned. Per
the settled Option A decision, all 27 were absorbed as one dated 2026-10-14 drift-correction
re-pin of `docs/reference/paper-definitions-of-record.md`, and the in-tree "verbatim" judgment pass
was scoped to exactly those anchors. **No Lean declaration was created, renamed or re-proved** —
`FrameOver.nullity_identity` and `nullity_identity_of_serial_limit` already prove the strengthened
biconditional, so the whole task is record and prose work.

## What Changed

**The record** (`docs/reference/paper-definitions-of-record.md`)

- All 27 drifted anchors re-pinned: fenced `latex` block, `sha256:` line and `MANIFEST:BEGIN/END`
  row each replaced from `check-paper-definitions.sh --resolve` output. `def:id` was re-pinned a
  second time when the paper moved again mid-Phase-8 (28 re-hashes over 27 distinct anchors),
  absorbed into the **same** dated section rather than opening a second one. No hash or block was
  transcribed by hand; a mechanical pass asserted each OLD block re-hashed to its OLD recorded hash
  before writing, so every placement was proved correct before the edit.
- The four `def:frame#*` sub-anchors and all 16 non-drifted rows left untouched (verified by diff).
- Eight heading glosses and entry notes falsified by the new text corrected, including
  `lem:nullity`'s gloss (now `w ⇒₀ u ↔ w = u`) **with the DERIVED, not-an-axiom claim preserved**.
- Whole-file sentinels re-pinned (`PINNED_COMMIT` `9ad4aa5d…`, `FILE_CHECKSUM` `0e39993c…`,
  `LINE_COUNT` 3962), provenance-table rows added, and the pre-existing sentinel/table divergence
  (`b4e45e2c…`/4529 vs `88d9a9a6…`/4573) resolved. This is the first re-pin since 2026-08-10 to pin
  a **clean** paper file rather than a dirty working tree.
- One new `### Drift correction (2026-10-14): the 27-anchor wave` section: gate state before/after,
  the Re-hashed list, a presentational-only list, six content-bearing changes called out
  individually, the two paper-ward alignments, the three footnote removals, and a full account of
  the in-tree prose the wave forced and what was deliberately left alone.

**Lean docstrings** (comment interiors only — no declaration, signature or proof touched)

- `FormalSystem/Semantics/TaskFrame.lean` — `lem:nullity` re-quoted at the module docstring and
  above `nullity_of_serial_limit`; `def:frame`'s whole-definition quote re-quoted (it had said
  "A \textit{frame} is any…" where the record pins "task frame", omitted the `⊇`-directed opening
  clause, and carried the retired "for $x, y \geq 0$" preamble); `def:temporal-order` and the
  *Fiber* clause re-quoted for `\mid`; the retired `\Fib(w, x)` form replaced by the pinned
  `\fib{w, x}` at four sites; the reflection-convention quote re-quoted for `for $x > 0$`, and its
  surrounding "read literally, the paper's `x ≥ 0` covers zero" discussion rewritten, since the
  paper's new strictly-positive proviso licenses the tree's strict-at-zero split outright;
  `cor:saturation-finite`'s two quotes re-quoted for the generalization to bare task relations; two
  Main-Definitions attributions re-pointed from `nullity` to `nullity_identity`.
- `FormalSystem/Semantics/FrameAxioms.lean` — `lem:nullity` re-quoted in the transcribed
  specification; `def:constraints` re-quoted in two places for the `A`/`C`/`F_t`/`S_{t,s}`
  restructuring (these had carried three pre-existing errors at once: "over a frame", "constraints
  *imposed on*", and `\Fib(…)`); the References line re-worded.
- `FormalSystem/Semantics/Extension/Admissible.lean` — `lem:nullity` re-quoted (it had also said
  "in every **frame**" where the record pins "task frame"); `def:constraints` re-quoted.
- `FormalSystem/Semantics/Extension/Constraint.lean` — `def:constraints` re-quoted.
- `FormalSystem/Semantics/Extension/Extension.lean` — the two `thm:extension` **footnote**
  quotations removed rather than re-quoted: the choice-freeness footnote no longer exists in the
  paper or the record. Each site now says so and restates the Zorn-versus-choice-free contrast as a
  property of the Lean proofs, which is what this repository is entitled to assert.
- `FormalSystem/Semantics/Validity.lean` — `def:frame-validity`'s two quotes re-quoted.
- `FormalSystem/Semantics/PartialHistory.lean` — `def:world-history`'s block quote re-quoted for
  the world-history/possible-world tier; the note claiming the appendix routes that tier through
  convex histories corrected.
- `FormalSystem/Semantics/TemporalOrder.lean`, `FormalSystem/Examples/TemporalStructures.lean` —
  `def:temporal-order` re-quoted for `\mid`.
- `FormalSystem/Semantics.lean` — the four-axiom paragraph now names the biconditional as the
  paper's own statement, with `FrameOver.nullity` as its reflexivity half.

**Non-Lean deliverables**

- `README.md` — the Nullity parenthetical now states the biconditional; not-an-axiom claim kept.
- `docs/reference/API_REFERENCE.md` — `lem:nullity` re-attributed from `FrameOver.nullity` to
  `FrameOver.nullity_identity`, with `nullity` named as the reflexivity half.
- `docs/reference/transcription-audit-surface.md` — parentheticals added to the two *Limit*/
  `lem:nullity` rows (rows kept, not rewritten).
- `typst/FormalFoundations.typ` — `#lemma("Nullity")` now states the biconditional, `#leansrc`
  re-pointed to `nullity_identity`, and the proof covers both directions.
- `typst/chapters/02-semantics.typ` — same for the `#lemma("Nullity")` block, reconciled with the
  existing `#leanNullityIdentity` paragraph (which now leads, with `#leanNullityDerived` as the
  projected-out half). The "Why Nullity Is a Lemma, Not an Axiom" remark and the derived-status
  claim are intact.
- `scripts/lean-citation-manifest.json` — regenerated (25 entries moved, 0 added, 0 removed, all in
  `TaskFrame.lean` and `PartialHistory.lean`).
- `typst/generated/status.typ`, `README.md` + `FormalSystem/README.md` inventory blocks —
  regenerated count fields only.

## Decisions

- **Absorbed all 27 anchors in one dated section** rather than re-pinning `lem:nullity` alone,
  following the record file's own 10-anchor and 14-anchor precedents (the relayed Option A).
- **Fixed pre-existing false-`verbatim` claims only on re-pinned anchors**, since those files were
  being edited anyway. Everything else was left alone and is enumerated below.
- **Kept weak-loop paraphrases that state what a proof consumes.** A proof needing only `w ⇒₀ w`
  keeps citing `w ⇒₀ w`: `FormalSystem/Semantics/Presheaf/Behavior.lean`,
  `docs/reference/state-topology-appendix-support.md`,
  `docs/development/PROPERTY_TESTING_GUIDE.md`, `typst/chapters/06-notes.typ` and the References
  lines of `Extension/Admissible.lean` and `Extension/Extension.lean` are correct as they stand.
- **Removed, not re-quoted, the `thm:extension` footnote citations.** A docstring cannot quote a
  footnote that no longer exists; asserting the choice-freeness contrast as a Lean-proof property
  is the honest replacement.

## Plan Deviations

- **Phase 6** `FormalSystem/Semantics/README.md`: altered — confirmed no edit needed. Its only two
  `nullity` mentions are a module-table row and the `taskRel_eq_iter` zero case, which already
  names `FrameOver.nullity_identity`.
- **Phase 6** `docs/theorem-index.md`: altered — no edit needed. Its mentions of re-pinned anchors
  are attributions and one "clause verbatim" paraphrase on an unchanged clause; it reproduces no
  re-pinned block text.
- **Phase 6** additionally edited `FormalSystem/Semantics/TaskFrame.lean` (Main-Definitions list,
  the `nullity` → `nullity_identity` re-attribution) — same correction class as the
  `API_REFERENCE.md` item, grouped here rather than reopening Phase 4.
- **Phase 7** additionally regenerated the INV inventory blocks in `README.md` and
  `FormalSystem/README.md` (`check-module-invariants.sh --emit-inventory`), a second
  generated-artifact gate the plan did not anticipate alongside C35.
- **Phase 4** also had to regenerate `typst/generated/status.typ` (`scripts/typst-sync-check.sh
  --fix`): a pre-commit hook blocked the commit on its `formalsystem-line-count` field.

## Verification

- Build: **Success.** `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 --no-share -- build`
  — guard exit 0; "Build completed successfully (2847 jobs)"; zero `error:` and zero `warning:`
  lines over the captured streams; and every one of the ten touched modules' `.olean` newer than
  its source. The `--no-share` flag is load-bearing here: an earlier invocation was answered by
  the guard's REPLAY path (see Follow-ups).
- Sorry count: 0 (`lean-sorry-census.sh`, empty inventory)
- Vacuous count: 1 — `FormalSystem/Examples/TemporalStructures.lean:495`
  `theorem int_domain_universal (t : Int) : intTimeHistory.domain t := trivial`. **Pre-existing and
  not vacuous in substance**: present identically at this task's pre-work baseline commit, and
  `intTimeHistory.domain t` reduces to `True` for a total ℤ history, so `trivial` is the honest
  proof of a real goal. No Lean declaration was touched by this task.
- Axiom count: 14, unchanged from the pre-work baseline. No axiom added.
- `scripts/check-paper-definitions.sh`: exit 0, silent case-(a) pass against the live paper.
- `scripts/check-paper-definitions.sh --paper /nonexistent/x.tex`: exit 0, `SKIP (neutral)` — the
  CI path is intact, so this remains a local-correctness obligation and not a release blocker.
- `scripts/readme-lint.sh`: exit 0.
- `scripts/check-module-invariants.sh --no-build`: exit 0, ALL CHECKS PASSED, zero `FAIL` lines;
  C15 (both rows), C20 (both tiers plus declaration span) and C35 all PASS.
- `python3 scripts/export-lean-citations.py --check`: exit 0, 86 seeded names resolved.
- `.claude/scripts/verify-deploy.sh`: exit 0 (15 checks, 0 failures). Note that this gate verifies
  the `.claude/` deploy tree against its source store, which this task did not touch — it is not a
  repository-wide Lean/docs aggregator, despite the plan naming it as the `full` tier's aggregator.
- `typst compile --root . typst/FormalFoundations.typ` and `typst/BimodalReference.typ`: both exit 0.
- `.claude/scripts/typst-element-lint.sh --verbose` on the two touched typst files: exit 1 with 15
  placement findings. **All 15 are pre-existing**: an identical run against those files as
  committed before the Phase 6 edits reports the same 15. None introduced here.
- Verbatim sweep: a programmatic check reconstructed every pinned block from the record and tested
  each in-tree `verbatim`-labelled quotation on a re-pinned anchor for containment. Zero genuine
  content mismatches remain. The residual flags are all rendering-convention artifacts — this tree
  renders `$math$` as `` `math` `` and LaTeX relations as Unicode (`\geq` → `≥`), a long-standing
  convention predating this task — plus one leading-ellipsis quote and several paraphrase
  references that are not quotations.
- DERIVED, not-an-axiom claim confirmed surviving at all four required sites: the record's
  `lem:nullity` heading, `TaskFrame.lean`'s module docstring and `nullity_of_serial_limit`
  docstring, `README.md`, and `typst/chapters/02-semantics.typ`'s "Why Nullity Is a Lemma, Not an
  Axiom" remark.
- Plan compliance spot-check: **skipped**, not passed or failed. The Goals-section identifier
  extraction yields only `PINNED_COMMIT`, `FILE_CHECKSUM` and `LINE_COUNT` — the record file's
  HTML-comment sentinel names, not Lean declarations — and the plan's `## Lean Challenge
  Statements` section declares the Lean identifier set explicitly empty. There is no declaration
  set to check; grepping the source roots for those three names would report false misses.
- Files verified: Yes.

## Impacts

- The local `check-paper-definitions.sh` gate is green again; it had been red on this wave and
  would have gone red on every subsequent dispatch touching the paper's definitions.
- Every `verbatim`-labelled docstring quotation on a re-pinned anchor now reproduces what the
  record pins, so the tree's own citation discipline ("verbatim against the record, not the paper")
  holds again.
- Three choice-freeness citations in `Extension/Extension.lean` no longer point at a paper footnote
  that was deleted; the record documents the removal so a future reader does not hunt for it.
- The record's provenance table and whole-file sentinels now agree, removing a divergence that had
  persisted across two earlier re-pins.

## Follow-ups

- **Left alone deliberately** (the plan's explicit non-goal): pre-existing false-`verbatim` claims
  on anchors *outside* the re-pinned set. The one found while sweeping is
  `FormalSystem/Semantics/Extension/Step.lean`'s `def:frame#Saturation` quote, which says "for any
  directed family" where the record pins "for any $\supseteq$-directed family".
  `def:frame#Saturation` is byte-stable and was not re-pinned, so touching it was out of scope.
- The 15 pre-existing `typst-element-lint.sh` placement findings on `typst/FormalFoundations.typ`
  and `typst/chapters/02-semantics.typ` (section-opening `#definition`/`#theorem` blocks with no
  intervening prose) are untouched and remain available as a `typst` task.
- The two typst edits here are statement-accuracy corrections, not presentation work, so they
  stayed in this `lean4` task; they would split cleanly into a `typst` follow-on if preferred.
- The paper moved four times during this task's own lifecycle. Expect this wave to recur; the
  mechanical `--resolve`-driven re-pin used here is reusable as-is, and Phase 8's "re-run the bare
  check last" step is what caught the fourth movement.
- **Two build-verification lessons worth carrying forward.** (1) A docstring edit applied while the
  acceptance build was already running is not covered by that build's verdict: the guard exit code
  and the success line were both green while `TaskFrame.olean` was still older than its source, and
  only the `.olean`-newer-than-source check caught it. Freeze the edited file set before launching
  the acceptance build. (2) The re-run then came back green in seconds because
  `lake-build-guard.sh` answered it from its REPLAY path — its staleness policy compares the
  record's *post*-build fingerprint against the caller's, and that fingerprint already included the
  mid-flight edit. `--no-share` forces a real build and is the right flag whenever a prior build's
  coverage is in doubt.

## References

- `specs/756_repin_lem_nullity_after_paper_strengthening/plans/01_repin-lem-nullity-paper-strengthening.md`
- `specs/756_repin_lem_nullity_after_paper_strengthening/reports/01_repin-lem-nullity-paper-strengthening.md`
- `docs/reference/paper-definitions-of-record.md` — "Drift correction (2026-10-14): the 27-anchor wave"
- `scripts/check-paper-definitions.sh`, `scripts/check-module-invariants.sh`,
  `scripts/export-lean-citations.py`, `scripts/typst-sync-check.sh`
