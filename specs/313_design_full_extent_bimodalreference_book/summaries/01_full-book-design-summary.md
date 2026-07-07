# Implementation Summary: Full-Extent BimodalReference Book (Skeleton)

- **Task**: 313 - design_full_extent_bimodalreference_book
- **Plan**: `plans/01_full-book-design.md` (12 phases, all `[COMPLETED]`)
- **Session**: sess_1783401046_cf25fe
- **Type**: typst (skeleton plan; five follow-up tasks 314-318 carry the deferred content)

## Outcome

`Theories/Bimodal/typst/BimodalReference.typ` is now a five-part living monograph (67
pages), up from a flat 7-chapter reference core. All 12 plan phases landed as separate
commits, each verified `typst compile` + `scripts/typst-sync-check.sh` green before
committing.

## What Was Built

**Infrastructure (Phases 1-4)**:
- `template.typ` extended with `proposition`/`corollary`/`example`/`notation-env`,
  `leansrc`/`leanref`, `chapter-header`, `items`/`item`, `principles`/`principle`/`pr()`,
  fletcher `extension-node` helpers (ported from the Logos manual template), plus two new
  Bimodal-specific helpers: `sync-banner` (per-chapter ✓/⧖/○/◇ banners) and
  `planned-chapter-notice`/`part-divider` (stub chapters, five-part dividers).
- `typst/bibliography.bib` (new, 10 seeded entries, no Lk entry per the embargo).
- `scripts/typst-status-counts.sh` (new): single-source-of-truth generator for axiom/rule/
  sorry counts and the frame-class breakdown, regenerating `typst/generated/status.typ`.
- `scripts/typst-sync-check.sh` (new): 4-check mechanical drift detector (backtick-name
  resolution, banner presence, legend discipline, count freshness), with
  `sync-check-whitelist.txt` for deliberate exceptions.
- `SYNC-MAP.md` extended with a "Sync-Class Legend" section and, at completion, a
  "Task 313 Chapters" re-stamp section.

**Five-part restructure (Phase 5)**: `BimodalReference.typ` now interleaves five
`#part-divider(...)` calls with the chapter includes; the title page's "Primary Reference"
became a numbered "Sources" block; the abstract was rewritten to describe the five-part
structure with a "Reading Guide -- Sync-Class Legend" box. Twelve new chapter files were
created: 7 content-bearing stubs (Part I/III/V, each naming its follow-up task) and 5
wave-4 shells (filled by Phases 7-11).

**Content (Phases 6-11)**:
- `00-introduction.typ` rewritten around the AI-practitioner practitioner thesis, an
  honest TM description (never "vanilla LTL+S5"), a fletcher unification-grid frontispiece,
  a five-part book map, and an "How to Read This Book If You Are an AI" protocol.
- `p2-frame-classes.typ` (new, ✓): the `FrameClass` partial order, the `FrameConditions/`
  typeclass hierarchy, DF/DN/CO paper correspondence, Next/Previous as derived operators,
  and the `Metalogic/ConservativeExtension/` fresh-atom lemma.
- `p2-decidability-practice.typ` (new, ✓) + `04-metalogic.typ` trim: resolves the FMP
  sorry-free-vs-"in progress" discrepancy (sorry-free finite-filtration statement; open,
  unwired semantic-validity bridge), the operational decision procedure, certificates and
  countermodels, and an honest metatheory section.
- `p4-proof-automation.typ` (new, ✓): tactics, Aesop integration, the bounded proof-search
  engine, and the learning/game-theoretic tactic modules.
- `p4-dataset-pipeline.typ` (new, ✓) + `docs/training/PIPELINE.md` pointerized: the
  dual-signal training pipeline, module map, the two `lake exe` executables, and the
  honest Tier-1 feasibility gate results (3 of 6 criteria FAILED) with the Tier-2 response.
- `p4-dual-verification.typ` (new, ✓): the dual-verification architecture and worked
  examples from the sorry-free `Examples/` library.

**Integration (Phase 12)**: final SYNC-MAP re-stamp, `typst/README.md` rewrite
(five-part structure table, scripts documentation, follow-up task table), and a new
ROADMAP.md documentation-track entry (item 14, additive only).

## Discrepancies Found and Corrected (not present at the task-312 baseline)

Per-result live-source re-verification during Phases 7, 8, 9, and 11 surfaced several
corrections to what this task's own drafting initially assumed or to stale documentation
already in the repository:

1. **`FrameClass` file attribution**: the inductive type and its partial order live in
   `ProofSystem/Axioms.lean`, not `FrameConditions/FrameClass.lean` (a separate typeclass
   hierarchy).
2. **Next/Previous guard convention**: `Syntax/Formula.lean` defines `next φ := φ U ⊥`
   (event-first, Burgess convention), not the event-second `⊥ U φ` the plan's task text
   guessed.
3. **`Metalogic/ConservativeExtension/` mischaracterization**: its only theorem
   (`lift_derivation_qfree`) is a fresh-atom naming lemma for the irreflexivity argument,
   not a formalization of the paper's base-vs-Until/Since-extended-language conservativity
   as an earlier revision of `06-notes.typ` implied -- corrected there too.
4. **`tm_auto` is no longer Aesop-based**; `apply_axiom`/`modal_t` live in
   `Tactics/Helpers.lean`, not `Commands.lean`; the `TMLogic` Aesop rule set is referenced
   in doc comments but never actually registered.
5. **`Automation/README.md` line-count staleness** for `Commands.lean`,
   `ProofSearch/Core.lean`, and `Helpers.lean`.
6. **`docs/training/PIPELINE.md`'s own internal inconsistency**: claims "6 Lean modules"
   while its Module Reference documents 7.
7. **`Examples/README.md` overclaims** "dense and discrete" concrete temporal-structure
   instances; only the discrete (`Int`) case is concretely instantiated.

All seven are documented inline in the relevant chapters and/or `SYNC-MAP.md`'s Phase-12
re-stamp section, per the postmortem rule against unverified per-result correspondences.

## Plan Deviations

- A latent `scripts/typst-sync-check.sh` bug (path-detection ordering: extension check ran
  before line-suffix stripping) was found and fixed during Phase 8, once chapter prose
  began citing many `File.lean:NNN`-style locations.
- Two small script amendments beyond strict phase territory: `typst-status-counts.sh`
  gained a frame-class breakdown (`base-count`/`dense-only-count`/`discrete-only-count`)
  during Phase 3, anticipating Phase 7's explicit need for it.
- A transient sorry-count fluctuation (43 vs. 46) was observed and traced to a concurrent,
  unrelated task's in-flight edit to `WeakCanonical/Kamp/NfMultiAnchorBridge.lean`; resolved
  by re-running the generator once the concurrent edit settled (documented in the Phase 5
  handoff as a validation of the drift detector's sensitivity, not a defect).
- See individual phase handoffs (`handoffs/phase-{1..12}-handoff-*.md`) for full per-phase
  deviation detail.

## Verification

Final state: `typst compile BimodalReference.typ build/BimodalReference.pdf` exits 0
(67 pages); `scripts/typst-sync-check.sh` exits 0 (all 4 checks PASS, 485 backtick
candidates, zero violations); `scripts/typst-status-counts.sh` shows zero drift from the
task-312 baseline (42/7/43); embargo audit clean (zero Lk-specific content, only
embargo-exclusion meta-references); preserved-assets honesty prose intact.

## Follow-Up Tasks (declared in `.skeleton-return.json`, already created in state.json)

| Task | Scope |
|------|-------|
| 314 | Part I motivation chapter ("Why Construct Possible Worlds") |
| 315 | Part III expressive-power chapters (four, Lk-abstracted) |
| 316 | Machine-readable JSONL appendix, exported from Lean |
| 317 | Part V Logos chapters (constitutive structure, tensed counterfactual logic) |
| 318 | Lk slot-in for the Decidability Frontier chapter (post-TACAS-acceptance only) |
