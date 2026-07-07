# Phase 8 Handoff: Decidability in Practice (+ 04-metalogic trim)

**Status**: COMPLETED
**Files touched**: `chapters/p2-decidability-practice.typ` (filled from Phase-5 shell), `chapters/04-metalogic.typ` (Decidability section trimmed, status table corrected), `chapters/06-notes.typ` (resolved-status wording synced), `chapters/p4-proof-automation.typ` (added forward-reference label), `scripts/typst-sync-check.sh` (path-detection ordering bug fix), `sync-check-whitelist.txt`

## What was done

- **FMP discrepancy resolved first**, per the phase's own ordering requirement. Verified
  against live source (`Metalogic/Decidability/Correctness.lean`, the `FMP/` module, and
  `Metalogic/Decidability/README.md`): the entire `Decidability/` tree, including all seven
  `FMP/` files, is genuinely sorry-free (direct comment-stripped scan, zero matches). The
  "in progress" wording in the pre-existing metalogic chapter was about the *statement*, not
  the *proof*: `fmp_completeness`'s antecedent quantifies over `FMP.ClosureMCSBundle φ` (a
  finite syntactic filtration structure), not directly over semantic validity `⊨ φ`. Resolved
  wording: ✓ sorry-free finite-filtration result; ⧖ open-but-not-sorry-tainted
  semantic-validity bridge. This exact wording now appears identically in three places:
  the new chapter, `04-metalogic.typ`'s status table, and `06-notes.typ`'s Decidability
  Implementation section (the plan's "both documents must state the SAME resolved status"
  requirement, extended to all three).
- Wrote the full chapter: `decide`/`isValid`/`isSatisfiable`/`DecisionResult`/`getProof?`/
  `getCountermodel?` (`DecisionProcedure.lean`), fuel semantics and the `timeout` branch,
  `TraceCertificate`/`ProofCertificate`/`CertOutcome` and `CountermodelExtraction`'s
  `SimpleCountermodel`/`SemanticCountermodel`, an honest metatheory section (`decide_sound`
  proven; `validity_decidable` stated plainly as the vacuous `Classical.em` tautology; FMP
  status as resolved above), and a closing normative status table with candidate follow-up
  task pointers (165/82/290/300).
- Trimmed `04-metalogic.typ`'s Decidability section to a two-paragraph summary +
  cross-reference (`@sec:decidability-practice`); removed the tableau-structure/complexity
  detail now owned by the new chapter; corrected the Component Status table's FMP row into
  two rows (finite-filtration statement proven; semantic-validity bridge open).

## Deviations from plan

- **Script bug found and fixed**: `scripts/typst-sync-check.sh`'s Check-1 path-detection
  logic checked `cand.endswith((".lean", ...))` *before* stripping a trailing `:NNN` line
  suffix, so any bare `` `Foo.lean:123` `` citation was misclassified as a bare identifier
  (never as a path) and always failed resolution. Fixed by stripping the line suffix before
  the extension test. This was a latent bug from Phase 4, only surfaced once this chapter's
  prose used many `File.lean:NNN` citations.
- Several bare `` `:NNN` `` line-only backtick citations (relying on a preceding sentence's
  filename for context) were rewritten to repeat the filename in every citation -- both
  because the sync-checker cannot resolve context-dependent shorthand, and because it is
  more precise exposition regardless.
- Added one whitelist entry for the verbatim `fmp_completeness` type-signature quote (spacing
  differs slightly from the Lean source's own formatting, so literal grep does not match; this
  is the same "type-signature illustration" category already established in Phase 4).

## Verification

`typst compile BimodalReference.typ build/BimodalReference.pdf` exits 0. `bash
scripts/typst-sync-check.sh` exits 0 (all 4 checks PASS, 345 backtick candidates, up from 289).
