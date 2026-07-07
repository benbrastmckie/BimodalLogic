# Implementation Summary: Revise BimodalReference.typ to Match Paper + Lean Source

- **Task**: 312 - revise_bimodalreference_typst_paper_lean
- **Plan**: plans/01_revise-typst-reference.md (all 7 phases completed)
- **Session**: sess_1783392719_6dfe8f
- **Date**: 2026-07-06 (Lean source at commit `a883361bf`)

## Outcome

All seven typst chapter files plus the main document, notation module, and README were
revised against the live Lean source (`Theories/Bimodal/`, excluding `Boneyard/`), with
the paper `possible_worlds.tex` as terminology/narrative guide. The document compiles
cleanly (`typst compile Theories/Bimodal/typst/BimodalReference.typ
build/BimodalReference.pdf`, exit 0). A reusable claim-verification table landed as
`Theories/Bimodal/typst/SYNC-MAP.md`.

## Phase Results

| Phase | Result |
|-------|--------|
| 0 | Primary completeness wiring verified from live imports: `BXCanonical.completeness` (`Metalogic/BXCanonical/Completeness.lean:135`) + dense/discrete variants; three-way doc disagreement (README=Bundle, ROADMAP=Chronicle, typst=deleted FMP) resolved from source. Scope decisions recorded in SYNC-MAP preamble. |
| 1 | SYNC-MAP claim table + regenerated counts: 42 axiom constructors / 8 layers, 7 rules, 43 genuine sorries in Metalogic (41 excl. nested Kamp/Boneyard); Soundness x3 and Perpetuity P1-P6 confirmed sorry-free. |
| 2 | `04-metalogic.typ` full rewrite: live module tree, honest sorry inventory, three-way case-split completeness architecture, strict-semantics note, Kamp WIP note; all references to `semantic_weak_completeness`/FMP-path/Representation deleted. |
| 3 | `03-proof-theory.typ` full rewrite: all 42 constructors tabulated by layer with formulas transcribed from `Axioms.lean`; FrameClass parametrization + paper TM+/TM_d/TM_f correspondence (TM_c noted unformalized); TK/T4/TF derived-axioms section; 7 rules kept; paper-contrast aside. |
| 4 | `01-syntax.typ` rewritten to Until/Since primitive basis (Burgess convention, `Atom` type, derived G/H/F/P with Lean names, updated `swap_temporal`); `02-semantics.typ` gained the Reflection constraint (Lean `converse`, `TaskFrame.lean:93`) and U/S truth clauses; strict `<` H/G conditions preserved as derived characterizations. Additive notation macros only. |
| 5 | `06-notes.typ` rewritten (reflexive-as-current contradiction removed, task-93 history, paper<->Lean axiom correspondence, stamped counts); `05-theorems.typ` module table fixed (subdirectories, ContextualProofs, TemporalDerived); `00-introduction.typ` counts + live directory list; main-file abstract fixed. |
| 6 | README `thmbox` fix + latex-divergence note; stray top-level PDF removed; gates: compile exit 0, 271 backticked names all resolve live, counts re-derived at HEAD and match. |

## Plan Deviations

- Phase 3 planned "additive macros" to `notation/bimodal-notation.typ`; none were needed
  (plain typst math covers U/S and frame-class subscripts). Macros were instead added in
  Phase 4 (`leanNullityIdentity`, `leanForwardComp`, `leanConverse`, `leanReflection`).
- `BimodalReference.typ` (abstract) was not listed in any phase's "Files to modify" but
  contained a stale `semantic_weak_completeness` claim; fixed in Phase 5 to satisfy the
  Phase 6 extraction gate.
- The `<sec:formulas>` label was added to `01-syntax.typ` during Phase 3 (one phase
  early) because the rewritten `03-proof-theory.typ` forward-references it.
- Phase 5 verification "no reflexive-as-current text" passes with historical/contrastive
  mentions retained by design (past-tense only).

## Flagged (not edited) and Suggested Follow-ups

- `docs/reference/{axiom-reference,operators,tactic-reference}.md` are stale on the same
  axes this task fixed (old axiom set, old completeness narrative) — follow-up suggested.
- `Theories/Bimodal/latex/BimodalReference.tex` is now declared divergent (note added to
  `typst/README.md`); a full latex re-sync is a suggested follow-up task.
- A `typst-sync-check.sh` drift detector (re-running the SYNC-MAP extraction in CI) is a
  suggested follow-up; the extraction/verification method is documented in SYNC-MAP.
- `specs/ROADMAP.md` states "41 BX axioms in 6 layers"; source has 42 constructors in 8
  layers — minor roadmap correction suggested.
- `Metalogic/README.md` still self-warns as stale (Bundle-primary narrative).

## Files Modified

- `Theories/Bimodal/typst/chapters/00-introduction.typ` … `06-notes.typ` (7 files)
- `Theories/Bimodal/typst/BimodalReference.typ` (abstract)
- `Theories/Bimodal/typst/notation/bimodal-notation.typ` (additive macros)
- `Theories/Bimodal/typst/SYNC-MAP.md` (new)
- `Theories/Bimodal/typst/README.md` (thmbox fix, sync + divergence notes)
- `Theories/Bimodal/typst/BimodalReference.pdf` (removed; output lives in `build/`)
