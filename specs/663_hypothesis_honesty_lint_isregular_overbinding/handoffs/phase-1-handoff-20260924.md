# Phase 1 handoff — task 663

**Next action**: Phase 2 — add the `Constraints consumed:` normal form to
`docs/development/REFERENCE_NORMAL_FORM.md`.

**State**: Phase 1 [COMPLETED], committed as `91df8b12e`. C34 census landed in
`scripts/check-module-invariants.sh` (after C33, before C9-DOCS), `ENFORCE_C34` defaults to 0.
Harness `--no-build` is fully green (ALL CHECKS PASSED, zero FAIL).

**Measured figures (re-derive, never quote)**: 259 raw bracketed occurrences / 47 files;
C34's declaration-level census: 212 binder-carrying declarations in 46 files, 0 markers,
630 live .lean files, 11980 declaration spans. `class IsRegular` at `TaskFrame.lean:1170`,
four fields unchanged. All eight fix sites present and binder-carrying.

**Key decisions**: marker parsed out of `comments_only` over the doc block; binder scan runs
over `mask`ed code from keyword line to end of span, truncated at the first top-level command
(`variable`/`section`/`open`/…) so a `variable [F.IsRegular]` block is never attributed to the
preceding theorem. `classify()` returns binders (bracketed) and mentions (any) separately —
C34a in Phase 6 uses `mentions`, C34b uses `binders`.

**Deviations**: one — a third anti-silence condition (zero bracketed binder sites) added beyond
the two the plan names. Annotated inline on the plan checklist.
