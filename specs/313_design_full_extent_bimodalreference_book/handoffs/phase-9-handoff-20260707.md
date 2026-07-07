# Phase 9 Handoff: Part IV Chapter — Proof Automation

**Status**: COMPLETED
**Files touched**: `chapters/p4-proof-automation.typ` (filled from Phase-5 shell)

## What was done

- Wrote the full chapter: the three tactics (`apply_axiom`, `modal_t`, `tm_auto`), the Aesop
  rule set, the bounded proof-search engine (`ProofSearch/Core.lean`, `Strategies.lean`), and
  a survey of `SuccessPatterns.lean`/`EFGameTactics.lean`, with live line counts and
  declaration line numbers throughout, verified via a dedicated research dispatch before
  writing any prose.

## Deviations from plan (all are verification-driven corrections, not scope changes)

1. **File attribution corrected**: the plan's task text expected `tm_auto`, `apply_axiom`,
   and `modal_t` all in `Automation/Tactics/Commands.lean`. Live source shows `apply_axiom`
   and `modal_t` are in `Tactics/Helpers.lean` (1,032 lines); only `tm_auto` is in
   `Commands.lean` (710 lines).
2. **`tm_auto` is not Aesop-based**: contrary to the plan's task text and
   `Automation/README.md`'s own usage example, `tm_auto`'s doc comment (dated 2026-01-17)
   states it now delegates to `runModalSearch` (the bounded proof-search engine) specifically
   "to avoid proof reconstruction issues" that the prior Aesop-based implementation had.
3. **No `TMLogic` Aesop rule set is actually registered**: `AesopRules.lean` cites `TMLogic`
   only in a doc-comment usage example; every `@[aesop ...]` attribute in the file is
   unqualified, registering into Aesop's default rule set. The chapter states this precisely
   rather than repeating the doc-comment's implied claim.
4. **`modal_t`'s macro body does not yet match its doc comment**: the doc comment describes
   targeting the T axiom specifically, but the macro currently expands identically to
   `apply_axiom`. Noted as a doc/implementation gap, not silently repeated as fact.
5. **`EFGameTactics.lean` does not name "Kamp" directly**: it cites Gabbay-Hodkinson-Reynolds
   (GHR93) as its literature basis; the chapter notes the classical lineage without overstating
   a direct textual connection that isn't in the source.
6. **`Automation/README.md`'s own line-count columns are stale** for `Commands.lean` (431 vs.
   710 live), `ProofSearch/Core.lean` (1018 vs. 1195 live), and `Helpers.lean` (921 vs. 1032
   live) — the chapter cites live counts throughout and flags this in a closing note.
7. Several multi-word/bare-line-number backtick citations were rewritten (filenames repeated
   per citation, default-parameter values de-backticked to plain prose) to satisfy the
   sync-checker's literal-match resolution, matching the pattern established in Phase 8.

## Verification

`typst compile BimodalReference.typ build/BimodalReference.pdf` exits 0. `bash
scripts/typst-sync-check.sh` exits 0 (all 4 checks PASS, 417 backtick candidates, up from 345).
