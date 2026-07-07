# Implementation Plan: Task #317

- **Task**: 317 - Write the counterfactual and constitutive chapters of BimodalReference (Parts III and IV)
- **Status**: [COMPLETED] (all 5 phases; final book-level gates blocked only by concurrent task 316's in-flight missing generated/machine-appendix artifacts -- external to this task's write-set)
- **Effort**: 7 hours
- **Dependencies**: Tasks 313, 319 (both complete); no file overlap with in-flight tasks 315/316/318 except one-line label edit in `p3-vlach-blstar.typ` (flagged for task 315 coordination)
- **Research Inputs**: specs/317_write_bimodalreference_part_v_logos_chapters_const/reports/01_counterfactual-constitutive-chapters.md
- **Artifacts**: plans/01_counterfactual-constitutive-chapters.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: typst
- **Lean Intent**: false

## Overview

Replace the two 10-line placeholders `Theories/Bimodal/typst/chapters/p5-counterfactual.typ` (Part III) and `p5-constitutive.typ` (Part IV, concludes the book) with full adapted chapters, plus a new `notation/constitutive-notation.typ` and ~11 bibliography entries. All content is transcribed/adapted from two verified sources: `counterfactual_worlds.tex` (the published paper, line anchors verified in the research report) and the Logos manual (`02-constitutive.typ`, `03-dynamics.typ`, `07-proof-theory.typ`), with `Logos/Foundations/Constitutive/Frame.lean` as ground truth for the possible-state definition (`StatePossible f s := f.taskRel s 0 s`). Definition of done: both chapters complete per the research report's Section 3 blueprints, all 7 divergence resolutions applied, `typst compile` exits 0, and `scripts/typst-sync-check.sh` passes.

### Research Integration

The plan follows the research report (01_counterfactual-constitutive-chapters.md) exactly:
- **Section 2 source map**: verified paper line anchors for all 9 content items plus motivation, Vlach, and soundness material — implementers transcribe from these anchors, not from memory.
- **Section 3 blueprints**: the 9-section counterfactual chapter spec (3.1) and 8-section constitutive chapter spec (3.2) are the section-by-section specification; this plan references them rather than duplicating them.
- **Section 4**: 7 divergence resolutions (duration-parameterized task relation; Lean-first possible-state definition; stay propositional; CTL over derived H/G; Part-I frame-constraint asymmetry in the closing figure; unilateral truth clauses per the paper; countermodel-coverage honesty — only #1/#8/#9 fully interpreted, #11/#12 by argument).
- **Section 7**: notation symbol table with collision analysis (do NOT rebind `taskrel`/`worldstate`; reuse `taskto(x)`).
- **Section 9**: 5-phase split adopted below; drafting order is constitutive-before-counterfactual even though book order is counterfactual-then-constitutive (forward references from Part III need Part IV labels fixed first).
- **Baseline verified in research**: compile and sync-check both green before any edits.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap_path provided; no ROADMAP.md consultation for this task.

## Goals & Non-Goals

**Goals**:
- Full Part III chapter: motivation, working state/imposition definitions (P taken as given, forward-referencing Part IV), bilateral propositions, grammar with the extensional-antecedent restriction, task semantics with boxright in BOTH imposition and mereological form, CL ⊂ CML ⊂ CTL axiom ladder via `principles`/`principle`/`pr()`, HEADLINE `□A := ⊤ □→ A` with S5 derived (soundness only; completeness stated open), perpetuity re-derivation (PD11 `□A → △A`) cross-referencing Part I, twelve invalid schemata with the three interpreted countermodels (#1, #8, #9) as `example` environments and #11/#12 by argument, Vlach store/recall regimentation reusing Part I operators, honest soundness/limitations section; cite `@brastmckie2025counterfactualworlds`.
- Full Part IV chapter: anti-primitive opening, state lattice, duration-parameterized task relation over all states, possible/world states DEFINED (Lean form `s ⟹₀ s`), frame constraints and derived theorems (Possibility/Nonempty/World Space), imposition defined with Fine's four constraints as theorems, worlds as maximal possible evolutions (Containment, M_Z = H_Z), ground/essence pointer citing `@brastmckie2021identity`, closing world-state-shadow comparison figure with the honest restriction/specialization caveat; concludes the book.
- New `notation/constitutive-notation.typ` (~40-60 lines), imported by the two p5 chapters only (NOT via template.typ), with zero collisions against `bimodal-notation.typ`/`shared-notation.typ`.
- ~11 bibliography entries verified against `counterfactual_worlds.bib`.
- `typst compile` and `scripts/typst-sync-check.sh` pass at every phase boundary.

**Non-Goals**:
- No template.typ changes (all environments already ported by task 313).
- No local Lean formalization; no claims of one (honesty constraint: state plainly what is published, adapted, and not formalized).
- No FOL/lambda machinery from the Logos manual (stay propositional; pointer only).
- No twelve worked countermodels (only three are interpreted in the paper — do not fabricate).
- No completeness claims (open per the paper); soundness reported at the paper's actual "characteristic schemata" strength.
- No wholesale import of Logos notation files; no edits to `generated/status.typ` or counts.
- No `p3-vlach-blstar.typ` content (task 315's scope) beyond the one-line heading label.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Countermodel transcription errors (dense fusion-letter state assignments at paper lines 1119-1126, 1149-1156, 1188-1198) | H | M | Transcribe directly from the .tex with the file open; keep the γ(x) = a.e.g form for the #8 world-set typo (research Risk 7) |
| Imposition-arrow glyph has no Typst builtin | M | H | Timeboxed experiment in Phase 1 (max ~20 min); fallback: `$attach(arrow.r.long, br: #w)$` composed form with a `notation-env` note in the chapter |
| Notation collisions shadow book-wide symbols (`taskrel`, `worldstate`, `since`/`until`) | H | L | Phase 1 defines only the Section-7 subset; do not rebind listed names; do not import Logos notation files; compile after the notation file alone |
| Axiom-vs-theorem ledger drift (C1-C7 axioms vs D1-D11/PD11 derived; Fine 2012 treats D9/D10 as basic) | H | M | Keep the paper's ledger exactly; per-phase checklist item in Phases 3-4 |
| sync-check failure from backticked external Logos Lean names | M | M | Prose/italics for mentions (p4-dual-verification footnote pattern); `#leansrc(...)` string args are safe; whitelist entries only as last resort with comment block |
| Overclaiming (12 countermodels, completeness, local formalization) | H | M | Honesty constraints written into phase tasks verbatim; Phase 5 sweep re-checks each claim against the paper anchors |
| Conflict with task 315 on `p3-vlach-blstar.typ` label | L | L | One-line label only (`<ch:vlach-blstar>`); flag in implementation summary for task 315 to preserve |
| Scope creep past ~1,400 total Typst lines | M | M | Phase budgets below; Section 3 blueprints define the ceiling — condense motivation prose (~2 pages), do not reproduce paper appendix proofs beyond the soundness enumeration |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel (this plan is fully sequential: Phase 2 fixes the Part IV labels that Phase 3's forward references target, and Phases 3-4 write the same file).

### Phase 1: Enabling Infrastructure — Notation, Bibliography, Labels [COMPLETED]

**Goal**: All shared symbols, citations, and cross-reference anchors exist and the document compiles green, so chapter drafting never blocks on infrastructure.

**Tasks**:
- [x] Create `Theories/Bimodal/typst/notation/constitutive-notation.typ` (~40-60 lines) with exactly the research Section 7 symbol table: `statespace`, `parthood`, `properpart`, `fusion`, `Fusion`, `nullstate`, `fullstate`, `compat`, `incompat`, `iparthood(t)`, `maxcompat(s,t)`, `connected`, `possible`, `necessary`, `maximalstates` (optional), `imposition(w)`, `prodop`, `sumop`, `evolutions`, `maxevolutions`. Header comment mirrors `bimodal-notation.typ:10-25` reconciliation-note style [DEVIATION: `maxevolutions` omitted — used inline as $M$-with-subscript in the chapter instead; `prodop`/`sumop` use `times.o`/`plus.o` (Typst deprecated `times.circle`/`plus.circle`); header comment written backtick-free because sync-check Check 1 scans comments]
- [x] Do NOT rebind `taskrel`, `worldstate`, `histories`, `Dur`, `model`, `tuple`, `define`, `nec`, `poss`, `since`, `until`; reuse `taskto(x)` for the general task relation
- [x] Timeboxed imposition-arrow glyph experiment (~20 min): U+21FE RIGHTWARDS OPEN-HEADED ARROW renders correctly (verified via PNG render) and is the closest match to the paper's \rightarrowtriangle; adopted as `imposition(w)` with attach-subscript; fallback documented in header comment
- [x] Define `store(i)` = `$arrow.t^#i$` and `recall(i)` = `$arrow.b^#i$` in `notation/bimodal-notation.typ` (Part I owns the operators; superscript Logos form per research Section 6) — note for task 315 coordination
- [x] Add label `<ch:vlach-blstar>` to the level-1 heading of `chapters/p3-vlach-blstar.typ` [DEVIATION: already present — task 315 completed and committed the label before this phase ran; no edit needed]
- [x] Add bibliography entries to `Theories/Bimodal/typst/bibliography.bib`, verified against the paper's own `counterfactual_worlds.bib`: all 11 keys appended (append-only; task-315 entries untouched); journal/year fields the paper's .bib omits were supplemented and marked `verify before print` per the book's existing convention
- [x] Add `#import "../notation/constitutive-notation.typ": *` to both p5 chapter files (after the template import; NOT to template.typ)
- [x] Check `sync-check-whitelist.txt` header's "planned notation file" note [DEVIATION: entry NOT retired — the backticked path in bimodal-notation.typ's comment still cannot resolve against Lean source, so the whitelist entry remains needed; also the whitelist file is concurrently modified by in-flight task 316, so no edit was made]

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/typst/notation/constitutive-notation.typ` - new file
- `Theories/Bimodal/typst/notation/bimodal-notation.typ` - add store/recall
- `Theories/Bimodal/typst/bibliography.bib` - ~11 new entries
- `Theories/Bimodal/typst/chapters/p3-vlach-blstar.typ` - one-line label
- `Theories/Bimodal/typst/chapters/p5-counterfactual.typ`, `p5-constitutive.typ` - notation import line only
- `Theories/Bimodal/typst/sync-check-whitelist.txt` - only if the planned-file note is retired

**Verification**:
- `typst compile BimodalReference.typ build/BimodalReference.pdf` exits 0
- `bash scripts/typst-sync-check.sh` passes
- Grep confirms no rebinding of the forbidden names in the new notation file

---

### Phase 2: Draft p5-constitutive.typ (Part IV, full chapter) [COMPLETED]

**Goal**: Complete Part IV chapter per research blueprint 3.2 — drafted FIRST (definitions flow downhill) even though it is the later book part, fixing all labels that Phase 3's forward references will target.

**Tasks**:
- [x] Chapter skeleton: level-1 heading with label `<ch:constitutive>`, then `#chapter-header(description:, dependencies:, connections:)` following `p4-dual-verification.typ` house style; one up-front prose paragraph stating what is published (paper), what is adapted (Logos manual), what is not formalized locally (external Logos Lean covers the constitutive layer only partially) — no per-claim markers, no banners
- [x] Section 1 Opening: anti-primitive program (paper 666-678, 708-713, 1380-1392); interpretation of states (689-706): static, partial, specific; impossible states and their role
- [x] Section 2 State lattice: complete lattice ⟨S,⊑⟩, fusion, null/full state, proper part; optionally atomic/composite (Logos 02-constitutive.typ:301-322); `notation-env` reconciling the paper's `s.t` dot fusion with the `⊔` glyph
- [x] Section 3 Task relation over all states: duration-parameterized `s taskto(d) t` with Compositionality (Divergence 1: matches Part I 02-semantics.typ and Lean `TaskFrame`); remark on the paper's unparameterized simplification; connectedness; **possible states DEFINED** as `s ⟹₀ s` (Divergence 2: Lean `StatePossible` is ground truth) with remark on the paper's connectedness form, transient states (740-743), and Restricted Reflexivity (738); compatible, maximal, **world states defined** (`StatePossible ∧ StateMaximal`), necessary states, Nullity (764-777) — label these definitions for Phase 3 forward references
- [x] Section 4 Frame constraints and derived theorems: Parthood L/R (750-756), Maximality (785-795), Nullity; theorems Possibility (1771-1780), Nonempty (1786-1793), World Space (1798-1816); task-space definition (807)
- [x] Section 5 Imposition defined and Fine's constraints as theorems: compatible part, `[w]_t`, imposition (656-663); derive Inclusion (1682-1689), Actuality (1695-1705), Incorporation (1713-1730), Completeness (1738-1744) — label the imposition definition and the constraints theorem for Phase 3
- [x] Section 6 Worlds as maximal possible evolutions: evolutions in Logos form (τ over convex X ⊆ Q, Divergence 1), world histories, possible worlds as time-shift classes (819-832); Containment L/R (1447-1452) and M_Z = H_Z (1822-1842)
- [x] Section 7 Ground and essence pointer: brief; cite `@brastmckie2021identity`; point to LogosManual for FOL/lambda (Divergence 3); do not reproduce PI¹
- [x] Section 8 Closing comparison figure: Part I primitives ↦ Part IV constructions table/figure (W primitive ↦ world states defined; task relation on W ↦ task relation on all S; valuation ↦ bilateral propositions; histories ↦ maximal possible evolutions; □ primitive ↦ derived in Part III); **Divergence 5 caveat stated plainly**: Part I's Nullity-as-identity and Reflection are additional world-state-level frame constraints, not derived — shadow claim is restriction/specialization, not isomorphism. This section concludes the book
- [x] External Lean names in prose/italics or `#leansrc(...)` string form only — no bare backticked Logos identifiers (sync-check discipline)

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/typst/chapters/p5-constitutive.typ` - full chapter (~400-600 lines)

**Verification**:
- `typst compile` exits 0; `bash scripts/typst-sync-check.sh` passes
- All 8 blueprint sections present; labels `<ch:constitutive>` + the definition/theorem labels Phase 3 needs exist
- Divergences 1, 2, 3, 5 resolutions visibly applied (grep for the remarks)

---

### Phase 3: Draft p5-counterfactual.typ Sections 1-6 (through CTL + headline S5) [COMPLETED]

**Goal**: Part III chapter core per research blueprint 3.1 items 1-6: motivation through the axiom ladder, headline S5 derivation, and perpetuity re-derivation, with forward references to Phase 2's Part IV labels.

**Tasks**:
- [x] Chapter skeleton: level-1 heading with label `<ch:counterfactual>`, `#chapter-header(...)`, same up-front honesty paragraph pattern as Phase 2; cite `@brastmckie2025counterfactualworlds` at the head
- [x] Section 1 Motivation (~2 pages condensed): Totality (Nixon `(N)`, 391-458), Restriction (SDA vs STA, 486-521), INT/LL derivation of STA from SDA (555-567), Fine's constraints as assumptions (608-614), the stated aim: validate SDA without STA, no counterfactual primitive
- [x] Section 2 Working definitions: state space; possible states P *taken as given with explicit @-pointer to Part IV* (`<ch:constitutive>` + definition labels); compatibility, world states, World Space; compatible part / maximal compatible parts / **imposition defined** (656-663); Fine's four constraints *stated* as facts proven in Part IV (forward reference)
- [x] Section 3 Bilateral propositions: closed/exclusive/exhaustive ⟨V,F⟩ (855-864); impossible-states rationale; cite `@brastmckie2021identity`; ⊗/⊕ and ∧/∨/¬ operations (914-928); bilattice footnote optional (add refs to bib only if kept)
- [x] Section 4 Grammar with the **extensional-antecedent restriction** (876-899): two-sorted grammar exactly as in the paper; footnote (from 1013) that ModelChecker's unrestricted extension is NOT adopted; Divergence 4 remark: CTL stated over the book's derived H/G (Until/Since primitive per Part I), paper's H/G-primitive language strictly weaker, soundness unaffected — do NOT restate axioms with Until/Since
- [x] Section 5 Task semantics: truth clauses (938-947); **boxright in BOTH forms**: imposition form (946) AND basic mereological form (954-956); logical consequence (963-967); Divergence 6: follow the paper's unilateral clauses, evaluation at world histories, bivalence by World Space (950); optional remark on the Logos bilateral generalization
- [x] Section 6 The logics CL ⊂ CML ⊂ CTL via `principles`/`principle`/`pr()`: CL (R1, C1-C7 with paper names, 982-1003; derived D1/D2); CML (**HEADLINE `□A := ⊤ □→ A`**, 1014, with the why-CL-cannot-define-□ explanation, then M1-M5); headline theorem D3-D10 ⇒ **CML entails S5 with no frame constraints** (1046-1048) — soundness only, completeness open, stated honestly; CTL (TK/TD/GP/TR/LN/DF/NF/UF, 1051-1071); **perpetuity re-derivation** PD11 `□A → △A` (1649-1657) cross-referencing Part I's perpetuity chapter (05-theorems P1-P6): imposed semantically there, derived from counterfactual axioms here
- [x] Keep the paper's axiom/derived ledger exactly (C1-C7 axioms; D1-D11/PD11 derived)

**Timing**: 2 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/typst/chapters/p5-counterfactual.typ` - sections 1-6 (~350-500 lines)

**Verification**:
- `typst compile` exits 0; `bash scripts/typst-sync-check.sh` passes
- Forward references to Part IV resolve (no unresolved-label warnings in compile output)
- Grammar restriction, both boxright forms, headline definition, and S5-soundness-only honesty all present (grep-checkable)

---

### Phase 4: p5-counterfactual.typ Sections 7-9 — Countermodels, Vlach, Soundness [COMPLETED]

**Goal**: Complete Part III per blueprint items 7-9 with the countermodel-honesty and soundness-strength constraints applied exactly.

**Tasks**:
- [x] Section 7 Countermodels: twelve invalid schemata (1088-1104) as a display list; `example` environments for the THREE fully interpreted countermodels only — #1 red ball/Mary (1110-1133), #8 Boris/Olga (1138-1173; note it also invalidates #1 and #11), #9/STA party case with Sobel-sequence footnote (1178-1208, fn 1202); #11/#12 by argument from D6 (1170-1173); ModelChecker-reproducibility footnote (`"disjoint" = True`, fn 1106); **do not claim twelve worked models** (Divergence 7)
- [x] Transcribe state assignments character-by-character from the .tex (highest-risk step); keep `γ(x) = a.e.g` form for the #8 world-set discrepancy
- [x] Section 8 Tensed counterfactuals via Vlach store/recall: N′ motivation (1223-1242); ↑ᵢ/↓ⁱ syntax + clauses (1251-1270) using Phase 1's `store(i)`/`recall(i)`, **explicitly presented as reusing Part I's operators** with @-reference to `<ch:vlach-blstar>`; regimentations (n)/(n′)/(n″) (1233, 1275, 1288); Jackson jump case d/u/l (1302-1353) citing `@jackson1977causal`; Icosahedron backwards case (1355-1366); Suppositional Accommodation remark (1343)
- [x] Section 9 Soundness and open problems: soundness at the paper's exact strength — characteristic schemata proven in the Appendix, enumerated: R1, C2, C3, C5, M3, M4, M5, □GA↔□A (paper 1855 wording); **completeness open** (969, 1500); limitations: events/processes idealized as states (1399-1428), discrete vs continuous time with DN/CO alternatives (1461-1487); not formalized in this repository (external Logos Lean covers the constitutive/dynamical layer partially)

**Timing**: 1.5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/typst/chapters/p5-counterfactual.typ` - sections 7-9 appended (~300-400 lines)

**Verification**:
- `typst compile` exits 0; `bash scripts/typst-sync-check.sh` passes
- Exactly three `example` countermodel environments; #11/#12 argument present; no "twelve countermodels" claim
- Soundness enumeration matches the eight-item list; completeness stated open

---

### Phase 5: Cross-Reference Sweep, Honesty Audit, Final Verification [COMPLETED]

**Goal**: Book-level integration is consistent and both mandated checks pass on the final state.

**Tasks**:
- [x] Cross-reference sweep: `@`-references between `<ch:counterfactual>` ↔ `<ch:constitutive>` render as "Chapter N"; Vlach reference to `<ch:vlach-blstar>` resolves; check `00-introduction.typ` Part III/IV promises still match (no edit expected); confirm `part-divider` blurbs in `BimodalReference.typ:217-241` still describe the written chapters
- [x] Honesty audit against the paper anchors: (a) axiom/derived ledger exact, (b) soundness = characteristic schemata only, (c) completeness open in both places it arises, (d) three interpreted countermodels only, (e) shadow-figure caveat present (Divergence 5), (f) no local-Lean claims, (g) extensional-antecedent restriction in the grammar and respected by every displayed schema
- [x] Check unintended `#show "TM": strong` hits in the new prose (standalone "TM" only)
- [x] Notation polish: every new symbol used at least once; unused Section-7 symbols removed from constitutive-notation.typ; no leftover collision
- [x] Final compile with warning review + sync-check; PDF pages for Parts III/IV skimmed via PNG renders (defs/theorems/proofs, imposition arrow, axiom lists, countermodels, Vlach clauses, shadow table all verified) [DEVIATION: full-book compile and sync-check each fail with exactly ONE cause -- task 316's missing generated/machine-appendix.{jsonl,typ}, in-flight and outside this task's write-set, pre-existing before 317's first edit; 317 content verified green via a wrapper compile that stubs only 316's appendix include, and sync-check shows zero violations from 317 files]
- [x] Note in implementation summary: the `<ch:vlach-blstar>` label and `store`/`recall` definitions added for task 315 to preserve

**Timing**: 1 hour

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/typst/chapters/p5-counterfactual.typ`, `p5-constitutive.typ` - polish edits only
- `Theories/Bimodal/typst/notation/constitutive-notation.typ` - prune unused symbols if any

**Verification**:
- `typst compile BimodalReference.typ build/BimodalReference.pdf` exits 0 with no new warnings
- `bash scripts/typst-sync-check.sh` passes (0 violations, count freshness OK)
- Honesty-audit checklist items (a)-(g) all confirmed

## Testing & Validation

- [ ] `typst compile BimodalReference.typ build/BimodalReference.pdf` exits 0 after every phase
- [ ] `bash scripts/typst-sync-check.sh` passes after every phase (backtick resolution + count freshness)
- [ ] No rebinding of `taskrel`, `worldstate`, `histories`, `Dur`, `model`, `tuple`, `define`, `nec`, `poss`, `since`, `until` in the new notation file
- [ ] Both chapters carry `chapter-header` and labeled level-1 headings; all `@`-references resolve without compile warnings
- [ ] Countermodel count = 3 interpreted `example` environments; axiom ledger matches the paper; completeness stated open; soundness = characteristic-schemata strength
- [ ] Visual PDF skim of Parts III and IV

## Artifacts & Outputs

- `Theories/Bimodal/typst/chapters/p5-counterfactual.typ` — full Part III chapter (~650-900 lines)
- `Theories/Bimodal/typst/chapters/p5-constitutive.typ` — full Part IV chapter (~400-600 lines)
- `Theories/Bimodal/typst/notation/constitutive-notation.typ` — new notation file (~40-60 lines)
- `Theories/Bimodal/typst/bibliography.bib` — ~11 new entries
- `Theories/Bimodal/typst/notation/bimodal-notation.typ` — store/recall additions
- `Theories/Bimodal/typst/chapters/p3-vlach-blstar.typ` — one-line label
- `specs/317_write_bimodalreference_part_v_logos_chapters_const/summaries/01_counterfactual-constitutive-chapters-summary.md` — implementation summary (flags the task-315 coordination items)

## Rollback/Contingency

- Each phase ends green and is committed per the commit-per-green-substep mandate (`task 317 phase {P}: {name}`); rollback = revert to the last green phase commit.
- If the imposition-arrow glyph experiment fails, ship the documented fallback (`attach` form) — never block a phase on typography.
- If a phase exceeds its budget, land the file in a compiling state (sections complete so far), mark the phase [PARTIAL], and let the next `/implement` resume; never commit a non-compiling chapter.
- The two chapter files start as placeholders under git — full-file revert restores the placeholder state without affecting the rest of the book.
