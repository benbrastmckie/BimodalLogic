# Implementation Summary: Task #736

- **Task**: 736 - Cslib omega-automata survey and E3 reopen check
- **Status**: [COMPLETED]
- **Started**: 2026-10-05T20:52:41-07:00
- **Completed**: 2026-10-05T21:05:00-07:00
- **Effort**: ~0.5 hours (verification-and-closure round)
- **Dependencies**: None
- **Artifacts**: plans/01_cslib-survey-e3-closure.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

**Verdict: (i) KEEP candidate (d), the time-axis Ramsey-coloured summary. E3's device selection
stands, with its reasons substantially rewritten.** This is a complete and valid outcome, not a
blockage: nothing here licenses or requires a `/revise 711`, and this task performed none.

The research dispatch had already delivered all four acceptance items. This round was therefore a
verification-and-closure round, not a build round: it re-ran the four acceptance gates at *this*
round's HEAD rather than citing the research dispatch's run (Phase 1), made one bounded
acquisition attempt at the three still-WANTED sources (Phase 2), recorded the E3 re-audit at E3's
own site so the verdict is discoverable from the probe the ROADMAP cites (Phase 3), and wrote
this summary with an operator hand-off list (Phase 4). All four phases completed; the probe
collection is green at every checkpoint.

## What Changed

- `specs/evidence/seam-gluing-ray-product/device-selection-probe.lean` — one comment-only
  RE-AUDIT block appended inside the existing header comment (67 insertions, 0 deletions). No
  declaration, import, or proof touched; the seven `#print axioms` lines are unchanged. The block
  records which of E3's grounds survive, which do not, why the selection nonetheless stands, and
  what it refuses to claim.
- `specs/736_cslib_omega_automata_survey_and_e3_reopen_check/summaries/01_cslib-omega-automata-survey-summary.md` — created (this file).
- `specs/736_cslib_omega_automata_survey_and_e3_reopen_check/plans/01_cslib-survey-e3-closure.md` — phase status markers and inline deviation annotations.
- `specs/736_cslib_omega_automata_survey_and_e3_reopen_check/handoffs/` — three phase-end handoffs.
- `specs/literature-index.json` — **unchanged**. Phase 2 closed no gap, so it wrote nothing.
- No Lean declaration was added, changed, or removed anywhere in this round.

## Decisions

- **No cslib port, and no Lake `require` on cslib.** The port assessment's standing
  recommendation is PORT NOTHING: the McNaughton closure is 7,526 lines across 47 modules
  against a Mathlib rev 76 commits divergent from this tree's, and what it delivers is an
  acceptor over STATES — the axis `Probe732Device.not_lasso_sufficient_on_chain` refutes. The
  `require` dissent is recorded and rejected on that stated ground. cslib is treated as a
  read-only reference.
- **The RE-AUDIT block was written to the probe file's actual claim structure, not the report's
  shorthand.** The plan's Scope Hypothesis asked for exactly this check and it fired: the file's
  own (a)/(b) rejection list has four clauses — inertness on the probed shapes, no Mathlib
  infrastructure, no Safra/Piterman formalization anywhere, and (b)'s FOCS 2005 source WANTED —
  which are *not* the four the report's "four rejection grounds" shorthand enumerates. The
  plan's items (3) and (4) are genuine claims of the file but live in the Selection paragraph and
  in "What this does NOT establish". The block covers six claims and states the discrepancy.
- **No bridge call was made on any Tier-3 open-access record.** None of them was one of the three
  named sources; ingesting them would have added unrelated documents to the global corpus without
  closing any named gap.

## Plan Deviations

- **Phase 2**, "for each Tier-3 `open_access` record ... run exactly one bridge call" — **altered**:
  no bridge call was made. Every Tier-3 open-access record returned was a different paper from the
  named gap (e.g. "Safraless LTL synthesis considering maximal realizability" 2016, "Automata and
  fixed point logic" 2006). The per-named-source bound was honoured instead of the per-record one.
- **Phase 3**, "confirm the four rejection grounds as the file actually states them" — **altered**:
  the confirmation found the file's ground structure differs from the plan's framing, so the
  RE-AUDIT block was written to the file's actual structure (six claims) rather than to the plan's
  four, with the discrepancy stated in the block itself.

## Verification

- Build: **N/A for `lake build`** — this round added no Lean declaration. The task's own declared
  gate is the evidence-probe collection, which was run three times:
  - Phase 1 baseline: `bash scripts/check-evidence-probes.sh` → `PASS  all 17 wired probe(s)
    compile`, **exit 0**.
  - Phase 3, after the only code-adjacent edit: **exit 0**, same 17 PASS.
  - Phase 4 closing gate: see below.
  - `lake env lean specs/evidence/seam-gluing-ray-product/device-selection-probe.lean` → **exit 0**,
    no error, no warning, axiom profiles unchanged.
- Sorry count: **0** (no Lean source under `FormalSystem/`, `Tests/`, or `specs/evidence/` was
  modified except by comment).
- Vacuous count: **0**.
- Axiom count: **unchanged** — no `axiom` declaration added; the edited probe's seven
  `#print axioms` lines are byte-identical before and after.
- Tests: N/A (no test surface touched).
- Files verified: Yes.

### Acceptance items, re-run at this round's HEAD

1. **Report present with all four sections.** `reports/01_cslib-omega-automata-survey.md`, 737
   lines, headings located: `### (A) cslib inventory and port assessment` (line 113),
   `### (B) Literature gathering and index wiring` (328), `### (C) Lean feasibility probe` (390),
   `### (D) The verdict on E3` (427).
2. **Literature sub-index valid.** `specs/literature-index.json`: valid JSON, **106 entries**,
   **0** duplicate `doc_id`, **0** entries missing `doc_id`, **0** orphans (every `doc_id`
   resolved WHOLE against the 13,701-entry global `~/Projects/Literature/index.json` — never by
   author-year stem), 106 unique source paths, **0** missing on disk. Note on method:
   `literature-validate-mode.md`'s `specs/literature/{path}` filesystem checks target a per-repo
   literature directory and do not apply to this `doc_id`-keyed sub-index; the five checks listed
   here are the ones actually run, stated rather than a mode claimed that does not fit.
3. **Probe collection green.** `bash scripts/check-evidence-probes.sh` → `PASS  all 17 wired
   probe(s) compile`, **exit 0**, at all three checkpoints. One SKIP by design
   (`bi-lasso-decision-layer/spike-untl-unfolding-and-fwd-obstruction`, deferred).
   `scripts/check-evidence-probes.sh` blob hash `ab095f826d4d2ae355f2e65bc221eafa7d03fd32` at
   Phase 1 and byte-identical at Phase 3 — this round appended nothing to the shared file, so the
   contention risk with tasks 711/733/734 never materialised.
4. **Every cslib claim re-verified by direct file read this round**, not carried over. cslib was
   reachable (`3bdf16d9f`; `upstream/main` `ea16de32a`), so the plan's fallback to attribution was
   not needed. Results in "Impacts" below.

### Non-regression gate

`check-task-references.sh`: **198** unexempted occurrences before and after, EXIT=1 both times.
The gate for this round is non-regression, not a pass — the lint FAILs repo-wide on a pre-existing
baseline. **0** flagged occurrences in either file this task touched.

## Impacts

- **The (c)/(d) shared-Ramsey-core claim is RAISED from LOW-confidence framing to High,
  machine-checked**, and the limit E3 left open is closed. `Cslib.ωLanguage.IsRegular.compl`
  (upstream, `OmegaRegularLanguage.lean:248`) is proved *through*
  `Cslib.Automata.NA.Buchi.buchiFamily_cover` (upstream, `Congruences/BuchiCongruence.lean:122`),
  which colours a pair of time points by the congruence class of the segment between them and
  applies `infinite_graph_ramsey` (`:125`). That is candidate (d)'s device, and it is the proof of
  Büchi complementation. The in-tree counterpart already using the same device on the MSO side is
  `RamseyFactorization.lean`'s two orientation-specific instantiations of `infinite_ramsey_pairs`
  over monadic k-types.
- **The McNaughton claim is now precise.** `Cslib.ωLanguage.IsRegular.iff_da_muller` is
  `proof_wanted` **upstream** (`:259` at `ea16de32a`) and a real, term-proved, sorry-free theorem
  **in the fork** (`:440`). The report's "fork-only" attribution is correct; this round pins down
  what upstream carries instead.
- **`BuchiCompl.lean` remains a non-resource, re-confirmed.** Fork-only; `complement_language_sub`,
  `complement_language_sup` and `complement_language_eq` are all `proof_wanted` (lines 293, 321,
  328), emitting no declaration. A `grep -c sorry` of 0 on that file is a **false negative**.
- **E3's record is now self-describing.** A reader arriving at
  `device-selection-probe.lean` from the ROADMAP learns from the file itself that the selection
  was re-audited, which grounds did not survive, and where the full verdict lives — the verdict no
  longer exists only inside a task directory.

## Follow-ups

Operator hand-off list — findings this task deliberately did not act on, each with its reason.
This task spawns no follow-on tasks of its own; filing any of these is the operator's call.

- **(a) Stale note in `FormalSystem/ForMathlib/Combinatorics/InfiniteRamseyPairs.lean` (~line 36).**
  The module says "`Mathlib.Data.Nat.Nth` is not in this project's built cache, so `Nat.nth` is
  deliberately not used". That is falsified — the olean is present and this task's own probe
  (`cslib-ramsey-port-feasibility.lean`) uses `Nat.nth`. **Not edited**: the file is in task 711's
  `file_scope` and 711 is `partial`, i.e. a live writer.
- **(b) Two now-stale statements in `specs/ROADMAP.md`'s E3 section.** The "no formalization in any
  proof assistant" rejection framing (still literally true of Safra/Piterman, but misleading as
  deployed), and item (3)'s "LOW-confidence framing, not a finding" limit, which is now closed.
  **Not edited**: no `roadmap_flag` on this dispatch.
- **(c) Three context-extension recommendations from the report**: `proof_wanted` as a trust
  surface distinct from `sorry` in `metadata-trust-surfaces.md`; a new
  `external-library-port-assessment.md` pattern; a stem-collision pass for the literature audit.
  **Not implemented**: `.claude/**` is a disposable deploy artifact (and was flagged STALE for
  `core filetypes lean typst` this dispatch); these belong in the source store via `/meta`.
- **(d) Three sources left WANTED by Phase 2**, each with its query and reason:
  - Kupferman–Vardi, "Safraless Decision Procedures", FOCS 2005 — query
    `"Safraless Decision Procedures Kupferman Vardi"`. Absent from all three tiers; Tier 3
    returned only different Safraless papers. Only the 2001 rank-construction core is in corpus.
  - Grädel–Thomas–Wilke 2002, "Automata, Logics, and Infinite Games" — query
    `"Automata Logics and Infinite Games Graedel Thomas Wilke"`. Absent from all tiers; it is
    Springer LNCS 2500 and not open access.
  - Hodkinson–Reynolds, Handbook of Modal Logic ch. 11, §§5.10–5.11 bodies — query
    `"Hodkinson Reynolds Temporal Logic Handbook Modal Logic mosaics monodic"`. The chapter *is* in
    corpus as whole-id `hodkinson_2006`, but its conversion is TOC/front-matter only (9.6 KB of
    markdown from a 52 KB PDF, 2,094 tokens); `5.10 Mosaics . . . 708` and `5.11 Monodic fragments
    . . . 710` appear only as table-of-contents lines. The bodies are genuinely absent. A targeted
    re-conversion of the existing PDF will not help — the PDF itself is the truncated artifact.
- **(e) The port assessment's standing recommendation: port nothing; treat cslib as a read-only
  reference.** The `require` dissent is recorded and rejected on the stated ground that it would
  drag *this* tree 76 Mathlib commits forward. **Not acted on** by design — this round
  relitigates nothing.
- **(f) `file_scope` drift in `specs/state.json`.** It anticipated `specs/evidence/cslib-omega-automata/`,
  while the probe landed in `specs/evidence/seam-gluing-ray-product/`. `file_scope` is descriptive
  and never filesystem-validated; the plan's `Files to modify` entries are the harvest source that
  corrects it as a side effect. Flagged, not separately fixed.

## References

- `specs/736_cslib_omega_automata_survey_and_e3_reopen_check/reports/01_cslib-omega-automata-survey.md` — the research report (737 lines) carrying the cslib inventory, port assessment, literature gap analysis and E3 verdict
- `specs/736_cslib_omega_automata_survey_and_e3_reopen_check/plans/01_cslib-survey-e3-closure.md` — this round's plan
- `specs/736_cslib_omega_automata_survey_and_e3_reopen_check/handoffs/` — three phase-end handoffs with the raw recorded evidence
- `specs/evidence/seam-gluing-ray-product/device-selection-probe.lean` — E3's own record, now carrying the RE-AUDIT block
- `specs/evidence/seam-gluing-ray-product/cslib-ramsey-port-feasibility.lean` — the port-feasibility probe (from the research dispatch)
- `scripts/check-evidence-probes.sh` — the collection gate
