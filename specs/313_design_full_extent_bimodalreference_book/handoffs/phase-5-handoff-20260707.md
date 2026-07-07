# Phase 5 Handoff: Five-Part Restructure of the Main File with Stub Division Points

**Status**: COMPLETED
**Files touched**: `BimodalReference.typ` (structure), `template.typ` (new `planned-chapter-notice`/`part-divider` helpers), 12 new chapter files, `sync-check-whitelist.txt`, `generated/status.typ` (regenerated), `chapters/p5-counterfactual.typ` (math-symbol fix)

## What was done

- Added two new template helpers: `planned-chapter-notice(task-number, body)` (styled stub box)
  and `part-divider(number, title, dominant-class, scope)` (full-page part divider).
- Created 7 content-bearing stubs with abstracts and follow-up task numbers:
  `p1-why-worlds.typ` (314), `p3-ltl-to-tm.typ`/`p3-vlach-blstar.typ`/
  `p3-decidability-frontier.typ`/`p3-open-future.typ` (all 315), `p5-constitutive.typ`/
  `p5-counterfactual.typ` (both 317). `p3-decidability-frontier.typ` additionally carries
  the three `// SLOT-IN:` anchors (`ladder-table`, `complexity-map`, `case-study`) reserved
  for follow-up 318, with an explicit embargo comment.
- Created 5 wave-4 empty shells (banner + title only, outlook placeholder):
  `p2-frame-classes.typ`, `p2-decidability-practice.typ`, `p4-proof-automation.typ`,
  `p4-dataset-pipeline.typ`, `p4-dual-verification.typ` -- to be filled by Phases 7-11 in
  the same files.
- Restructured `BimodalReference.typ`: five `#part-divider(...)` calls interleave the
  `#include` list into Parts I-V exactly per the plan's ordering; back matter (06-notes,
  bibliography) follows Part V. Title page's "Primary Reference" block became a numbered
  "Sources" block (possible-worlds paper, counterfactual-worlds paper, Lean repo as ground
  truth -- no Lk entry). Abstract rewritten to describe the five-part structure and to
  point to the sync-class legend. Added a "Reading Guide -- Sync-Class Legend" box after
  the abstract with the four symbols and what an automated reader may treat as ground truth.
- Regenerated `typst/generated/status.typ` (still 42/7/43, stamp advanced to the Phase-4
  commit) and re-ran `scripts/typst-sync-check.sh` to green after adding 9 new whitelist
  entries for external paper/Logos citations surfaced by the new stub chapters
  (`possible_worlds.tex`, `counterfactual_worlds.tex`, four `app:*` appendix labels, three
  Logos chapter filenames).

## Deviations from plan

- **Math-symbol fix**: `p5-counterfactual.typ`'s draft used `boxright.r` (not a valid typst
  math symbol) to write the counterfactual conditional; typst raised `unknown symbol
  modifier`. Replaced with a plain-text gloss (`"⊤ counterfactually implies A"`) since no
  counterfactual-arrow symbol/notation exists yet in this codebase (that notation belongs to
  follow-up 317's constitutive-notation module). Not a scope change, a compile-fix.
- **Transient count-drift observed and resolved**: mid-phase, `typst-sync-check.sh`'s Check 4
  reported a sorry-count mismatch (43 to 46, `WeakCanonical/` 24 to 27) against a live
  regeneration. Investigation (`git status --short Theories/Bimodal/Metalogic/WeakCanonical/`)
  found an uncommitted, actively-edited file (`NfMultiAnchorBridge.lean`) — a concurrent
  process (unrelated task, e.g. task 309's Kamp work) editing the shared repo while this
  phase ran. Re-running the counter script moments later reproduced the original 43/24
  values, confirming the mismatch was a transient artifact of concurrent editing rather than
  genuine drift. Regenerated `generated/status.typ` a final time to the settled values before
  committing. This is a real-world validation of Phase 4's drift detector (it does its job
  even under concurrent-repo noise) but worth flagging: sync-check runs against a live,
  multi-agent repo can show transient false positives near actively-edited files; a re-run
  disambiguates.

## Verification

`typst compile BimodalReference.typ build/BimodalReference.pdf` exits 0; 50 pages.
`pdftotext` confirms all five part-divider titles render at ascending page positions
interleaved with their chapters, and all 7 content stubs render their correct follow-up
task number ("Planned chapter — to be written under task 314/315/317"). `bash
scripts/typst-sync-check.sh` exits 0 (all 4 checks PASS).
