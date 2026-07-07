# Implementation Summary: Task #317 — Counterfactual and Constitutive Chapters of BimodalReference

- **Task**: 317 — write_bimodalreference_part_v_logos_chapters_const
- **Session**: sess_1783410218_f83296_317
- **Date**: 2026-07-07
- **Plan**: plans/01_counterfactual-constitutive-chapters.md (all 5 phases COMPLETED)
- **Type**: typst

## What Was Built

Both 10-line placeholders replaced with full adapted chapters, plus supporting infrastructure:

| Artifact | Result |
|----------|--------|
| `Theories/Bimodal/typst/chapters/p5-counterfactual.typ` | Full Part III chapter (~510 lines, 9 sections): motivation (Totality/Nixon, Restriction, SDA/STA, INT/LL), working definitions with P taken as given + forward refs to Part IV, imposition defined, bilateral propositions with exact inclusive operations, two-sorted grammar with the extensional-antecedent restriction, task semantics with boxright in BOTH imposition and mereological forms (unilateral truth clauses per the paper), CL ⊂ CML ⊂ CTL with the paper's exact axiom/derived ledger, HEADLINE □A := ⊤ □→ A with S5 derived (soundness only, no frame constraints), PD11 perpetuity re-derivation with proof cross-referencing Part I, twelve invalid schemata with exactly 3 interpreted countermodels (#1, #8, #9) as example environments + #11/#12 by argument, Vlach store/recall section reusing Part I's operators (@ch:vlach-blstar), soundness at characteristic-schemata strength with completeness stated open, events/continuous-time limitations |
| `Theories/Bimodal/typst/chapters/p5-constitutive.typ` | Full Part IV chapter (~360 lines, 8 sections), concludes the book: anti-primitive program, state lattice, duration-parameterized task relation over all states, possible states DEFINED as zero-duration self-task (external Logos Lean StatePossible authoritative) with the paper's connectedness-route remark, world/necessary states defined, Parthood/Nullity/Maximality constraints, Possibility/Nonempty/World Space theorems with proofs, imposition defined + Fine's four constraints derived as theorems with proofs, worlds as maximal possible evolutions with Containment theorem, ground/essence pointer (stays propositional), closing world-state-shadow comparison figure with the Divergence-5 restriction-not-isomorphism caveat |
| `Theories/Bimodal/typst/notation/constitutive-notation.typ` | New, ~70 lines; imported only by the two p5 chapters; imposition arrow via U+21FE (RIGHTWARDS OPEN-HEADED ARROW, visually verified); boxright defined here; zero collisions (taskrel/worldstate/histories/Dur/model/tuple/define/nec/poss/since/until untouched; taskto(x) reused) |
| `Theories/Bimodal/typst/bibliography.bib` | 11 entries appended (append-only; task-315 entries untouched): fine1975critical, fine2012counterfactuals, fine2012difficulty, fine2017truthmakercontent1, fine2017truthmakersemantics, lewis1973counterfactuals, lewis1979timesarrow, stalnaker1968theory, jackson1977causal, kripke1963semantical, goodman1947problem — fields verified against the paper's own counterfactual_worlds.bib; journal/year fields the paper's .bib omits are supplemented and marked `verify before print` |
| `Theories/Bimodal/typst/notation/bimodal-notation.typ` | store(i)/recall(i) added (superscript Logos form) |

## Honesty Constraints (all verified in the final audit)

- (a) Axiom/derived ledger exactly the paper's: R1 + C1–C7, M1–M5, TK/TD/GP/TR/LN/DF/NF/FN/UF basic; D1–D11 derived; D9/D10 noted as Fine's basic axioms derived here.
- (b) Soundness reported at characteristic-schemata strength only, enumerated: R1, C2, C3, C5, M3, M4, M5, □GA ↔ □A.
- (c) Completeness stated OPEN in the chapter head, the logics section, the S5 theorem scope note, and the soundness section.
- (d) Exactly 3 interpreted countermodels (#1, #8, #9); #11/#12 by argument; no "twelve worked models" claim; ModelChecker reproducibility footnote (raw() form, sync-check safe).
- (e) Shadow figure caveat: Part I's Nullity-as-identity and Reflection are additional world-state-level constraints; shadow claim phrased as restriction, not isomorphism.
- (f) No local-Lean claims; external Logos Lean names in prose/italics only; both chapters open with a plain provenance paragraph (published / adapted / not formalized locally).
- (g) Extensional-antecedent restriction in the grammar and respected by every displayed schema and countermodel.

## Plan Deviations

- Phase 1: `<ch:vlach-blstar>` label was already present — task 315 completed and committed it before this task ran; no edit was needed (label reused as-is).
- Phase 1: `sync-check-whitelist.txt` NOT touched — the `notation/constitutive-notation.typ` entry cannot be retired (the backticked path in bimodal-notation.typ's comment still cannot resolve against Lean source), and the file was concurrently modified by in-flight task 316.
- Phase 1: `maxevolutions` omitted from the notation file (used inline as `maximalstates_evolutions`); `prodop`/`sumop` use `times.o`/`plus.o` (Typst deprecated the `.circle` names); notation-file header comment written backtick-free (sync-check Check 1 scans comments).
- Phase 2: `<ch:counterfactual>` label added to the then-placeholder Part III heading one phase early so Part IV's back-references compile.
- Phase 3: stub headings for sections 7–9 appended so forward references compile at the phase boundary (filled in Phase 4). UF printed as F⊤ with an explanatory footnote (the paper prints FA, which is unsound as a schema and glossed as "endless"); the paper's ⟨P|F⟩-swap written as A†.
- Phase 4: ModelChecker footnote uses `#raw("\"disjoint\" = True")` instead of a backtick span (backticked form is a sync-check Check-1 violation).
- Phase 5 / gates: the two book-level acceptance gates each fail with exactly ONE cause that is external to this task: concurrent task 316 (in-flight throughout this run) added `chapters/ax-machine-appendix.typ` + an include in `BimodalReference.typ` but has not yet generated `generated/machine-appendix.{jsonl,typ}`. This breakage pre-existed task 317's first edit and lies entirely outside 317's write-set (BimodalReference.typ and generated/ are 316's territory; 317 only READ them). 317's content was verified at every phase boundary with a wrapper compile identical to BimodalReference.typ except that 316's missing appendix include is stubbed: EXIT=0, only benign pre-existing warnings; sync-check shows zero violations attributable to 317 files. Once 316 lands its artifacts, `typst compile` + `typst-sync-check.sh` should go green with no further 317 changes.

## Task 315 Coordination Notes

- `store(i)`/`recall(i)` are now defined in `notation/bimodal-notation.typ` (task 317); `p3-vlach-blstar.typ` currently writes the arrows inline (`arrow.t^i`) — harmless duplication, and task 315 should preserve the notation-file definitions.
- The `<ch:vlach-blstar>` label (committed by 315) is now referenced from Part III (`@ch:vlach-blstar` in the chapter header, tense-basis remark, and Vlach section) — must be preserved.

## Verification Evidence

- Per-phase: wrapper compile EXIT=0 after every phase; sync-check delta vs baseline = zero new violations at every phase boundary.
- Visual: PNG renders of pages 63–78 (Part III) and 69–75 (Part IV) skimmed — theorem environments, principle lists, imposition arrow, countermodel state assignments, Vlach clauses, shadow table all render correctly; thmbox definition/theorem cross-references resolve ("Definition 16.6", "Theorem 16.12", "Chapter 15/16").
- Git: four phase commits (72b8b164e, a242539a9, 399d33e3b, 19a00a9df) plus the final phase-5 commit.
