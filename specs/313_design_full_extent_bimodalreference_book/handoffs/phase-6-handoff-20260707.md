# Phase 6 Handoff: Introduction Rewrite for the AI-Practitioner Arc

**Status**: COMPLETED
**Files touched**: `chapters/00-introduction.typ`, `chapters/06-notes.typ` (added `<sec:notes>` label for cross-reference), `sync-check-whitelist.txt` (URL entry)

## What was done

- Rewrote `00-introduction.typ` around five sections: "Why This Book Exists" (practitioner
  thesis: decidable fragment for automation vs. full logic as training-signal generator,
  citing README.md's Related Projects and forward to Part IV's pipeline chapter), "What TM
  Actually Is" (honest Until/Since+S5+MF+uniformity description, with the LTL→+S5→+Vlach
  tower explicitly marked outlook and never presented as the formalized system -- postmortem
  rule C-F1), "Combined Expressive Power: The Unification Grid" (fletcher-based grid diagram,
  operator axis × world-state-structure axis, TM cell shaded via `extension-node`), "Book Map"
  (one paragraph per part with sync-class), and "How to Read This Book If You Are an AI"
  (six-point protocol: trust ✓, treat ⧖ as open, treat ○/◇ as citations not facts, never
  hand-copy counts, prefer the future JSONL appendix, expect Lean names to resolve literally).
- Kept and re-captioned the light-cone diagram (cetz canvas unchanged; caption now explicitly
  notes that dotted paths are not alternative histories in TM's current formalization).
- Updated the closing Project Structure bullet: `Automation/`/`Examples/` no longer "not
  covered in this manual" -- points to Part IV.

## Deviations from plan

- Removed a placeholder `#outlook_marker` call from three heading lines in an early draft --
  no such helper was ever defined (the plan's "inline markers" concept has no established
  syntax in this codebase yet); left as plain headings instead. Caught before compile.
- The light-cone diagram's caption was initially drafted as an empty `#figure([], caption:
  ...)` (no image content, just caption text) -- a rendering mistake, not a deliberate figure.
  Replaced with a plain centered italic caption paragraph, matching the original chapter's
  house style (no figure/caption numbering was used for this diagram before).
- Fixed two Check-1 violations surfaced by the new content: `Automation/DatasetExporter`
  corrected to the real filename `Automation/DatasetExporter.lean`; `https://logos-labs.ai/`
  added to the whitelist as an external URL (not a Lean path).
- Added a `<sec:notes>` label to `06-notes.typ`'s heading so the new introduction's
  `@sec:notes` cross-reference resolves (06-notes.typ had no label before; needed once
  Phase 6 introduced the first cross-reference into it).

## Verification

`typst compile BimodalReference.typ build/BimodalReference.pdf` exits 0. `bash
scripts/typst-sync-check.sh` exits 0 (all 4 checks PASS, 233 backtick candidates). `pdftotext`
spot-check confirms the new section headings, practitioner-thesis prose, and unification-grid
figure all render in the compiled PDF.
