# Implementation Plan: Revise BimodalReference.typ to Target State

- **Task**: 449 - review_paper_to_improve_bimodal_reference_manual
- **Status**: [NOT STARTED]
- **Effort**: 10 hours (per-phase timings sum to ~10.5 serial; Wave-2 parallelism compresses wall clock)
- **Dependencies**: None (edits `typst/` and `specs/` only; no Lean files, no paper files)
- **Research Inputs**: specs/449_review_paper_to_improve_bimodal_reference_manual/reports/01_paper-manual-lean-alignment.md
- **Artifacts**: plans/01_manual-to-target-state.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/context/standards/status-markers.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/no-task-references-in-deliverables.md
- **Type**: formal (typst implementation)

## Overview

Revise `typst/BimodalReference.typ` and its chapters against the JPL paper
`possible_worlds.tex`, applying the research report's R1–R14 ordered change list, re-aimed
under the user's governing directive. The manual presents the full bimodal system with
`snce`/`untl` primitive (the paper's TM+/BX) as THE system; the tense-primitive fragment is a
deferred subsystem. Done means: every chapter states the target end state, all paper citations
are by LaTeX anchor, every not-yet-established claim carries a `CONFIRM` comment, and the full
gate set (`typst compile`, `typst-sync-check.sh`, CONFIRM-grep well-formedness) is green.

### Governing Directive (user, verbatim — overrides conflicting research recommendations)

> "The goal is NOT for the Bimodal reference manual to be a progress report, but rather to
> clearly and cleanly state what the lean repository and paper both aim to deliver. Everything
> is in progress, and so it is best to target the end state without any historical or ephemeral
> reports on what is current or was the case or intended to be the case. Just state what final
> state should be, including comments with the 'CONFIRM' tag that I can check once the lean
> repo and paper have been finished to make sure they have hit the mark that the reference
> manual presents. Put otherwise, the aim is to draw on the paper to revise the manual to an
> ideal state that provides a target for the lean codebase to aim for, not a progress report of
> where the lean codebase is currently."

**What this changes about the research report's recommendations** (binding on every phase):

- **R5 re-aimed**: NO per-row Lean-status column. The completeness chapter states the target
  results of `cor:tm-completeness` as clean mathematical statements; each row not yet
  established in Lean gets a `// CONFIRM(lean): ...` comment naming the theorem that must
  exist axiom-free. The paper's rider — strong completeness *provably fails* for Z-time and R
  (non-compactness) — is a permanent mathematical fact and STAYS IN THE BODY as a stated
  negative result. Likewise Discrete strong completeness being provably false. "Not yet proved
  in Lean" never appears in the body.
- **All "current status" / "as of" / sorry-count / "Lean does not yet" prose**: converted to a
  `CONFIRM` comment or dropped. This includes every body display of sorry counts imported from
  `typst/generated/status.typ` (see status-apparatus disposition below).
- **R2c re-aimed**: the manual adopts infix guard-first `⊲`/`⊳` as the target notation
  unconditionally. NO hedging footnote about the Lean constructors' current event-first
  argument order, and NO new `guard-first-migration` LEAN-ANCHOR-MAY-MOVE marker — a
  `// CONFIRM(lean):` comment on the constructor-citing display carries that obligation
  instead. A purely mathematical footnote noting that the *literature's* Burgess convention
  writes U(φ,ψ) event-first (a timeless fact about the literature, not about this repo's
  progress) is permitted and recommended.
- **R8/06-notes re-aimed**: the back-matter chapter is recast from "implementation status and
  discrepancy notes" to a design-notes chapter recording *permanent, intended* divergences
  (structured `Atom` type, primed past mirrors, spelled-out CPL layer — these are design
  facts, not progress). All status framing goes; the deferred-subsystem axiom map stays,
  labeled as such.
- **Abstract/introduction re-aimed (R9)**: "fully proven", "one proof obligation outstanding",
  and the "provably incomplete ... headline correction" edition-narrative all go. The abstract
  states what the system is and what its metatheory delivers (with the genuine negative
  results), CONFIRM-guarded where Lean has not yet arrived.

**Status-apparatus disposition** (`typst/generated/status.typ`): the manual's chapters
(00-introduction, 03, 04, 06) import counts from this generated file. Structural counts —
45 axiom constructors, 7 rules, 4 frame classes — are facts about the system's definition and
remain in the body (and keep count-freshness checking meaningful). Sorry-census counts are
progress-dashboard material: every body display of them is removed, replaced where load-bearing
by `// CONFIRM(lean): scripts/typst-status-counts.sh --json reports sorry_total_excl_boneyard
= 0`. The file itself and `scripts/typst-status-counts.sh` are kept unchanged (they still feed
the structural counts and the sync-check freshness gate). `typst/FormalFoundations.typ` is a
separate standalone report, not included by `BimodalReference.typ` (verified against the main
file's `#include` list) — its status apparatus is out of scope and untouched.

### Research Integration

- `reports/01_paper-manual-lean-alignment.md` (R1–R14, findings A1–F5) — integrated in plan
  version 1. All Lean ground truth and paper anchors below are cited from this report's
  verified findings; the report's Appendix anchor index is the anchor source of record.

### Preserved Assets

No prior plan exists for this task, but the 2026-08-13 book revision left completed work that
must not regress:

| Asset | Location | Must preserve |
|-------|----------|---------------|
| Sync-check green state | `scripts/typst-sync-check.sh` (PASS 3/3) | Every phase re-establishes PASS before closing; whitelist edits only in Phase 8 |
| `LEAN-ANCHOR-MAY-MOVE` markers (7 sites) | per `typst/README.md` marker table | Keep all 7; they are maintainer comments, invisible in the PDF, compatible with the directive |
| Verified-aligned sections | 02-semantics task frames/extension chain (findings B1, B2), soundness narrative (D2), Vlach/BL* chapter content (F5) | Content edits limited to notation/ordering sweeps and anchor-form citations; no rewrites |
| Generated apparatus | `typst/generated/status.typ`, `scripts/typst-status-counts.sh`, machine-appendix JSONL | Never hand-edited; regenerate via scripts only |

### Source-to-Implementation Mapping (H3, Tier 1: paper → manual)

Reference tier: Tier 1 (literature-backed; source = `possible_worlds.tex`, cited by LaTeX
anchor only, never by line number — the paper is actively edited). Lean symbols cited as
`file.lean` + identifier. Full anchor list: research report Appendix.

| Source anchor / symbol | Report item | Target file(s) | Edit |
|------------------------|-------------|----------------|------|
| `def:BLplus-language`, `def:BLplus-semantics` (⊲/⊳ infix guard-first) | R1, R2a, A1 | notation/bimodal-notation.typ; 01-syntax.typ | Infix guard-first macros + book-wide display switch |
| `def:BLplus-defined` (since-first ordering; Next/Previous), `thm:BLplus-NextPrevious` | R2b, R2e, A2, A4 | 01-syntax.typ | Reorder snce/past first; add Next/Previous with discrete caveat |
| `def:time-shift-histories` (translation form) | R3b, B4 | 02-semantics.typ | Restate time-shift as translation ā(z)=z+d, τ(z)=σ(ā(z)) |
| `def:task-topology`, `app:topology-t1`, `app:topology-r0` | R3c, B6 | 02-semantics.typ | Optional one-footnote topology enrichment |
| `Axioms.lean` 45 constructors / 9 layers / `FrameClass` 4 values | R4a–c, C1 | 03-proof-theory.typ | Nine layers, Layer 9 table, four-class Hasse |
| `def:BX`, `def:TMplus`, `def:TMplus-f/d/c` axiom names (C2 verified map) | R4d–e, C2, C4 | 03-proof-theory.typ | Paper-name column; TM+ as primary comparandum |
| `cor:tm-completeness` (restated, 4 rows) + non-compactness rider | R5 (re-aimed), D1 finding | 04-metalogic.typ | Target completeness statements + CONFIRM(lean) rows; negative results in body |
| `def:TMplus-c` = BX_c/Reynolds (no TM+_dc in live paper) | R6a, C6 | p2-frame-classes.typ | Fix Dedekind ↔ TM+_c labeling |
| `thm:BLplus-PastFuture` (live embedding anchor) | R6b, R10c, D4 | p2-frame-classes.typ; p3-ltl-to-tm.typ | Deferred-subsystem note replaces conservativity theorem box |
| `Decidability/` tree (`decide_sound`; no machine-checked decidability) | R7, D3 | p2-decidability-practice.typ | Drop dead `cor:tm-decidability` citation; decidability as CONFIRM-guarded target |
| `sub:RestrictedModalities`; TM 12-schema presentation | R8d–e, E3 | 06-notes.typ | Anchor-form citations; subsystem-labeled axiom map |
| Four current frame axioms (Compositionality/Seriality/Limit/Spherical) | R10a, F4 | p3-ltl-to-tm.typ | Fix retired axiom vocabulary |
| JSONL `frame_class` incl. `Dedekind` (3 rows verified) | R12, C1 | ax-machine-appendix.typ | Add Dedekind to prose |
| All newly load-bearing anchors | R14 | specs/paper-definitions-of-record.md | Re-pin definitions of record |

## Decisions (RESOLVED by user, 2026-08-17)

Both formerly-gating decisions are resolved; no phase remains gated. The record below states
what was decided and the design principle each resolution carries.

**E1 — Tense-operator glyphs: RESOLVED — keep the H/G/P/F letters; NO paper-glyph
correspondence table.** The user's reasoning is a plan-wide design principle, stronger than
the report's Option A: **the reference manual stands on its own** — it is not a companion
document to the paper and must not require the paper to be read alongside it. Consequences,
applied throughout the phases:
- No glyph correspondence table, no "the paper writes this as ..." asides, no
  notation-mapping tables, no parenthetical paper-glyph glosses anywhere in the manual.
- The Burgess-convention footnote survives only as a note about the *literature's* alternative
  convention (a timeless scholarly fact), phrased without "the paper writes ..." framing.
- **Verdict on the axiom-name cross-index (paper-name column, Phase 4)**: KEPT. Judged
  against the stand-on-its-own principle: the short axiom names (TB, UG, UC, TA, ...) are
  stable *names for the axioms themselves* — scholarly citation apparatus a reference manual
  owes its reader (one cites an axiom by name), meaningful within the book once introduced,
  exactly as a theorem-numbering scheme is. A glyph table, by contrast, is pure translation
  scaffolding whose only use is reading the two documents side by side. The same verdict
  covers the extended-system names (TM+_f/TM+_d/TM+_c): they are the names of the systems,
  introduced and used by the book in its own right, anchored once by the introduction's
  naming remark (N1).
- Ordinary scholarly citations of the paper by anchor (crediting a theorem's source, pointing
  to where the deferred subsystem is developed) are citations, not bridges — they stay. The
  plan's own phase task items likewise continue citing paper anchors as internal provenance
  (plan-facing, not manual-facing).

**D1 — (DD)/two-fibre incompleteness exposition: RESOLVED — CUT ENTIRELY.** Not compressed
to a remark; removed (the non-default option). The 04-metalogic §Why TM Is Incomplete
section, the (DD) theorem boxes, the Halldén paragraphs, and the two-fibre cetz diagram are
all deleted (Phase 5). The discrete-or-dense dichotomy theorem — a standalone, verified-sound
mathematical fact independently used by the introduction — is retained as a bare stated
result inside 04-metalogic's frame-class-correspondence context, detached from any
incompleteness narrative. Stranded-reference cleanup is assigned explicitly: Phase 5 (labels,
unused imports in 04-metalogic), Phase 6 (the frame-classes chapter's "(DD) split validity"
cross-reference — already removed by R6b), Phase 8 (abstract/introduction sentences, verify
the introduction's dichotomy use still resolves, whitelist entries orphaned by the cut).
Bibliography needs no action: the References section renders cited entries only, so entries
cited solely by the deleted paragraphs drop out automatically.

**N1 — Book's name for the headline system** (non-gating; proceeding on default). Keep "TM"
as the book's name for the Until/Since-primitive system, fixed by one early introduction
remark identifying it with the published paper's TM+ (the single deliberate anchor point for
readers arriving from the paper). Alternative (rename to "TM+" throughout) would require a
sweep; not chosen.

## Postmortem Constraints

Binding rules for all implementation dispatches. No prior implementation attempts exist; rules
derive from the research report's risk factors, the governing directive, and repo rules.

**Do NOT**:
- Edit any `.lean` file or `possible_worlds.tex`. Lean-side needs become `CONFIRM(lean)`
  comments; paper-side issues are already surfaced to the user (below), never edited.
- Write status/progress prose in the manual body: no "as of", "currently", "not yet proved",
  sorry counts, in-flight-work notes, or edition-history narrative. The one exception:
  provably-false results (Discrete strong completeness; strong completeness over Z-time/R)
  are permanent mathematics and belong in the body.
- Cite the paper by line number or section number. LaTeX anchors (`def:`/`thm:`/`cor:`/`sub:`/
  `app:`) only — the paper is actively edited and line references rot immediately.
- Copy the paper's "machine-checked" proof line for `cor:tm-completeness` rows 1–2 into the
  body as an established fact; the manual asserts the target result, the CONFIRM comment
  carries the machine-checking obligation.
- Reference task numbers in any `typst/` file (`.claude/rules/no-task-references-in-deliverables.md`);
  the existing `LEAN-ANCHOR-MAY-MOVE: <scope>` convention (scope names, not task numbers) is
  the pattern to follow.
- Hand-edit `typst/generated/status.typ` or the machine-appendix JSONL; regenerate via
  `scripts/typst-status-counts.sh` / `scripts/typst-machine-appendix.sh` only.
- Remove `sync-check-whitelist.txt` entries before Phase 8: `cor:tm-decidability` is cited in
  two files owned by different phases (p2-decidability-practice, p3-decidability-frontier);
  early whitelist removal breaks the sync-check green state mid-plan.
- Delete or reword the seven existing `LEAN-ANCHOR-MAY-MOVE` markers.
- Plan or draft any past/future-primitive subsystem development — divergences of that kind are
  intended (task-description scoping constraint), and the subsystem is deferred wholesale.
- Add paper-bridging apparatus to the manual: glyph correspondence tables, notation-mapping
  tables, "the paper writes this as ..." asides, or parenthetical paper-glyph glosses (Decision
  E1's stand-on-its-own principle). Scholarly anchor-form citations of the paper as a *source*
  remain correct; side-by-side translation scaffolding does not.
- Reintroduce the (DD)/two-fibre incompleteness exposition in any form, compressed or
  otherwise (Decision D1: cut entirely). The dichotomy theorem alone survives, as a
  standalone result.

**MUST preserve**:
- `typst-sync-check.sh` PASS at every phase boundary (see Preserved Assets).
- The verified-aligned content of findings B1/B2/D2/F5 (notation-sweep-only in those regions).
- The book's two-part structure and chapter include order in `BimodalReference.typ`.

**Design decisions are SETTLED** (do not re-open without concrete counterexample):
- Guard-first infix `⊲`/`⊳` is the book's notation, adopted unconditionally as the end state
  (user FIX comments + governing directive). No hedging about Lean's current argument order.
- The book presents the Until/Since-primitive system in full; tense-primitive material is
  deferred-subsystem content consolidated to one note plus footnotes.
- CONFIRM comments (convention below) are the sole carrier for "finished-repo must satisfy X"
  obligations; no new marker vocabulary is invented for this purpose.
- The manual stands on its own (user, Decision E1 resolution): H/G/P/F letters kept, no
  paper-glyph bridging apparatus; the axiom-name cross-index and system names are kept as
  the book's own scholarly apparatus (verdict recorded under Decisions).
- The (DD)/two-fibre incompleteness exposition is cut entirely (user, Decision D1
  resolution); only the standalone dichotomy theorem survives.

## CONFIRM Tag Convention (established by Phase 1, used by all later phases)

- **Syntax** (Typst line comment, invisible in the compiled PDF):
  `// CONFIRM(lean): <assertion>` or `// CONFIRM(paper): <assertion>` — exactly this shape:
  two slashes, one space, `CONFIRM`, parenthesized lowercase target qualifier, colon, space,
  assertion on one line (continuation lines start `//   `).
- **Target qualifiers**: `lean` = the finished Lean repo must satisfy the assertion; `paper` =
  the finished paper must state/restore the assertion.
- **Placement**: immediately above the claim it guards (adjacent line, same indentation), the
  same placement rule as `LEAN-ANCHOR-MAY-MOVE`.
- **Checkability**: every CONFIRM states a checkable proposition — a fully qualified Lean
  theorem name that must exist and be axiom-free (verifiable via `lean_verify` or
  `#print axioms`), a script output condition (e.g. `scripts/typst-status-counts.sh --json`
  reports `sorry_total_excl_boneyard = 0`), or a named paper anchor that must state a given
  proposition. Never "verify this section".
- **Extraction command** (documented for the user):
  `grep -rn 'CONFIRM(' typst/` — filter with `grep -rn 'CONFIRM(lean)' typst/` or
  `grep -rn 'CONFIRM(paper)' typst/`.
- **Well-formedness check** (run at every phase gate):
  `grep -rn 'CONFIRM(' typst/ | grep -vE '// *CONFIRM\((lean|paper)\): ' | grep -vE '//   '`
  must output nothing.
- **Documentation**: registered in `typst/README.md` as a sibling subsection of the existing
  Marker Convention section (Phase 1).

## Goals & Non-Goals

- **Goals**: manual states the target end state of the TM+/BX system per the paper's live
  anchors; guard-first infix notation book-wide; nine-layer/four-class proof-theory chapter
  with paper-name cross-index; target-state completeness and decidability statements with
  CONFIRM obligations; tense-primitive material consolidated as deferred subsystem; all paper
  citations anchor-form; definitions-of-record re-pinned; all gates green.
- **Non-Goals**: no Lean edits; no paper edits; no past/future-primitive subsystem
  development; no conservative-extension formalization; no LaTeX-mirror (`latex/`) sync; no
  changes to `FormalFoundations.typ`; no changes to the sync-check script itself.

## Risks & Mitigations

- **Paper drifts mid-implementation** (author actively editing). Mitigation: Phase 1 re-pins
  `specs/paper-definitions-of-record.md` and re-runs `check-paper-definitions.sh` at gate-in;
  anchors only, never line numbers.
- **Over-claiming by copying the paper** (strong completeness "machine-checked", TM+
  "decidable"). Mitigation: postmortem constraint + CONFIRM convention; body asserts targets,
  comments carry the obligations.
- **Sync-check breakage from citation removal** (whitelisted anchors span two phases'
  territories). Mitigation: whitelist edits deferred to Phase 8 (postmortem constraint);
  each phase runs the full sync-check before closing.
- **Notation sweep misses a display** (chapters hardcode operator glyphs). Mitigation:
  Phase 1 macros + per-phase grep for residual event-first `U(`/`S(` operator displays;
  Phase 8 runs the book-wide residual grep as a closing gate.
- **Stranded references from the D1 cut** (labels, imports, whitelist entries, the
  introduction's dichotomy use). Mitigation: cleanup tasks assigned explicitly to Phases 5,
  6, and 8; `typst compile` fails on dangling `@`-references, making the residue mechanical
  to catch; bibliography self-prunes (cited-entries-only rendering).

## Surfaced to User (informational — NOT work phases; this task edits typst/ only)

- **Paper internal inconsistencies** (paper-side, outside this task's edit scope): the main
  body's claim that "TM" completely axiomatizes the base/discrete/dense/Dedekind theories
  looks like a typo for TM+ (near the anchor for the systems' introduction); the Conclusion
  asserts TM+ decidability while `cor:tm-decidability` is commented out and no decidability
  theorem is machine-checked — the paper is internally inconsistent about decidability.
- **Stale dependent task**: task 413's premise cites `thm:ConservativeExtension`, which is
  deleted from the paper; it needs re-scoping before implementation.
- **In-flight interplay**: task 448 (Lean guard-first constructor migration) is anticipated,
  not blocked on — the manual adopts guard-first as the end state now, with the CONFIRM(lean)
  obligation closing when 448 lands. Tasks 415/417/419/421–425 will move completeness/FMP/
  independence anchors; the existing `LEAN-ANCHOR-MAY-MOVE` markers cover those sites.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3, 4, 5, 6, 7 | 1 |
| 3 | 8 | 2, 3, 4, 5, 6, 7 |

Phases within the same wave can execute in parallel. Territory contracts (H7): every phase
owns exactly the files listed under its **Territory** field; no two Wave-2 phases share a
file. Wave-2 phases each depend only on Phase 1 (macros + CONFIRM convention + re-pinned
anchors); none depends on a sibling's decisions.

Per-phase gate (all phases): `cd typst && typst compile BimodalReference.typ
build/BimodalReference.pdf` exits 0; `bash scripts/typst-sync-check.sh` (from repo root)
passes; CONFIRM well-formedness grep (convention section above) outputs nothing.

### Phase 1: Conventions Foundation — CONFIRM Convention, Infix Macros, Anchor Re-Pin [NOT STARTED]

- **Goal:** Establish everything later phases consume: the CONFIRM tag convention documented
  in README, the infix guard-first since/until macros, and re-pinned paper anchors.
- **Territory:** `typst/notation/bimodal-notation.typ`, `typst/README.md`,
  `specs/paper-definitions-of-record.md`
- **Tasks:**
  - [ ] R1 (source: `def:BLplus-language`, macros `\since = \lhd` / `\until = \rhd`): add to
    `notation/bimodal-notation.typ` infix macros `#let snce = $lt.tri$`, `#let untl =
    $gt.tri$`, plus display helpers taking guard-first arguments (e.g. `#let snceOp(g, e)`,
    `#let untlOp(g, e)` rendering `g ⊲ e` / `g ⊳ e`). Per Decision E1 (resolved): the
    H/G/P/F letter macros stay as-is; add NO paper-glyph macros of any kind.
  - [ ] Document the CONFIRM convention in `typst/README.md` as a new subsection beside the
    existing Marker Convention section, reproducing the syntax, qualifiers, placement rule,
    checkability rule, and extraction commands from this plan's convention section verbatim.
  - [ ] R14: re-pin `specs/paper-definitions-of-record.md` against the live paper (known
    drift: `thm:s4`/`thm:sym` text changed; `def:BL-model`, `cor:tm-decidability` dangling)
    and add the newly load-bearing anchors: `def:BLplus-language`, `def:BLplus-semantics`,
    `def:BLplus-defined`, `def:BX`, `def:TMplus`, `def:TMplus-f`, `def:TMplus-d`,
    `def:TMplus-c`, restated `cor:tm-completeness`, `thm:BLplus-PastFuture`,
    `thm:BLplus-NextPrevious`, `def:time-shift-histories`. Run
    `bash scripts/check-paper-definitions.sh` and confirm it passes against the new pin.
- **Timing:** ~1 hour
- **Depends on:** none
- **Verification Tier:** local — compile gate + `check-paper-definitions.sh` pass; no chapter
  content changes yet, so sync-check must remain at its current PASS.
- **Estimated output:** ~100–150 lines
- **Scope Hypothesis:** the R14 anchor list above (12 anchors + drift repairs) is the
  hypothesis; confirm at implementation time by re-running `check-paper-definitions.sh` and
  diffing its recorded-anchor set against the report Appendix's anchor index.
- **Done when:** macros compile and render `g ⊲ e` correctly in a scratch display; README
  documents CONFIRM; `check-paper-definitions.sh` passes; all three phase gates green.

### Phase 2: Syntax Chapter to Guard-First Target State [NOT STARTED]

- **Goal:** Resolve all three inline FIX comments in `01-syntax.typ`; the chapter presents
  L+ as the book's language in guard-first infix notation with snce/past-first ordering.
- **Territory:** `typst/chapters/01-syntax.typ`
- **Tasks:**
  - [ ] R2a (source: `def:BLplus-language`, `def:BLplus-semantics`): replace `U(φ,ψ)`/
    `S(φ,ψ)` prefix event-first displays with infix guard-first `⊲`/`⊳` (via Phase 1 macros)
    in the grammar display, operator table, and swap definition.
  - [ ] R2b (source: `def:BLplus-defined` ordering; finding A2): reorder so snce/past precede
    untl/future in every table and definition list.
  - [ ] R2c (directive-re-aimed; E1 stand-on-its-own phrasing): delete the long
    Burgess-convention paragraph and the "Known, Deliberate Divergence" remark. Add one
    timeless footnote noting that part of the literature (the Burgess convention) writes
    since/until prefix and event-first — phrased as a fact about the literature, with no
    "this book follows the paper" framing. Place `// CONFIRM(lean): Formula.snce and
    Formula.untl (Syntax/Formula.lean) take arguments guard-first, matching
    def:BLplus-semantics` above the constructor-citing display. No hedging prose about
    current Lean argument order.
  - [ ] R2d (FIX at the L-vs-L+ paragraph): move the base-language-L contrast into a footnote
    after F/P/H/G are defined, citing the paper; the body presents L+ as the book's language
    throughout, standalone.
  - [ ] R2e (source: `def:BLplus-defined`, `thm:BLplus-NextPrevious`): add Next := ⊥⊳φ and
    Previous := ⊥⊲φ to the derived-operator section with the discrete-frames caveat.
  - [ ] R2f — DROPPED (Decision E1, resolved): no paper-glyph correspondence table, and no
    paper-glyph glosses. While applying R2a–e, also delete any existing "the paper writes
    this as ..." aside or parenthetical paper-glyph gloss encountered in the chapter (the
    stand-on-its-own sweep).
  - [ ] Delete the three inline FIX comments once addressed.
- **Timing:** ~1.5 hours
- **Depends on:** 1
- **Verification Tier:** local — phase gates, plus `grep -nE '\bU\(|\bS\(' typst/chapters/01-syntax.typ`
  returns only the Burgess footnote (if it renders the literature form) or nothing; plus
  `grep -c 'FIX:' typst/chapters/01-syntax.typ` returns 0.
- **Estimated output:** ~120–200 lines
- **Scope Hypothesis:** three FIX comments and one Known-Deliberate-Divergence remark exist in
  the chapter; confirm by grepping `FIX:` and the remark title at dispatch before editing.
- **Done when:** chapter has zero FIX comments, zero prefix event-first operator displays
  outside the Burgess footnote, snce-first ordering throughout; gates green.

### Phase 3: Semantics Chapter — Clause Ordering and Time-Shift [NOT STARTED]

- **Goal:** Truth-condition displays match the paper's guard-first infix form with the snce
  clause first; time-shift restated in the paper's translation form.
- **Territory:** `typst/chapters/02-semantics.typ`
- **Tasks:**
  - [ ] R3a (source: `def:BLplus-semantics`; finding B3): state the snce truth clause before
    the untl clause, both in infix guard-first form via Phase 1 macros. No other edits in the
    verified-aligned task-frame/extension-chain sections (findings B1/B2 — preserve).
  - [ ] R3b (source: `def:time-shift-histories`; finding B4): restate Time-Shift as the
    paper's translation form ā(z) = z + d with τ(z) = σ(ā(z)); move the order-automorphism
    generality and the partial-history domain clause to a footnote presenting them as the
    Lean-side generalization (`WorldHistory.lean` `timeShift`), which is a design fact, not
    status.
  - [ ] R3c (source: `def:task-topology`, `app:topology-t1`, `app:topology-r0`; finding B6,
    optional): one footnote noting the basic opens (w)_x generate a T1, R0 topology on W,
    cited to the paper's anchors; phrase as a paper-side result without Lean-status prose.
- **Timing:** ~1 hour
- **Depends on:** 1
- **Verification Tier:** local — phase gates, plus event-first residual grep on this file.
- **Estimated output:** ~60–120 lines
- **Scope Hypothesis:** the automorphism-form time-shift statement and the untl-first clause
  ordering are as the report located them; confirm by reading the current §Truth Conditions
  and §Time-Shift before editing.
- **Done when:** snce clause precedes untl in guard-first infix; time-shift is
  translation-form; gates green.

### Phase 4: Proof-Theory Chapter — Nine Layers, Four Classes, Paper Cross-Index [NOT STARTED]

- **Goal:** `03-proof-theory.typ` presents all 45 constructors in nine layers with the
  four-value FrameClass and a paper-name cross-index; the paper's TM+ system is the primary
  comparandum.
- **Territory:** `typst/chapters/03-proof-theory.typ`
- **Tasks:**
  - [ ] R4a (source: `Axioms.lean` 45 constructors, 9 layers; finding C1): fix "eight
    layers" → nine and the frame-class parameter description to four values.
  - [ ] R4b (source: `Axioms.lean` Layer 9 `prior_U_gap`/`prior_S_gap`/`sep`; paper
    `def:TMplus-c` Prior-U/Sep with K+/K− abbreviations): add a Layer 9 table so the layer
    tables sum to 45.
  - [ ] R4c (source: `Axioms.lean` `FrameClass`; finding C1): rewrite §Frame Classes —
    four values, Dedekind above Dense in the Hasse description, correspondence Base↔TM+,
    Dense↔TM+_d, Discrete↔TM+_f, Dedekind↔TM+_c, with a pointer to the frame-classes chapter
    for detail. Also fix the stale sentence claiming the paper's complete/combined extensions
    have no corresponding frame class (predates the Dedekind class; finding C6 ripple).
  - [ ] R4d (source: `def:BX`/`def:TMplus-*`; finding C2's verified constructor map; KEPT
    under the Decision E1 axiom-name verdict — citation apparatus, not translation
    scaffolding): add the short-name column (TB, UG, UC, TA, ...) to the Layer 3 and
    Layer 5–9 tables using the report's table verbatim, introduced as the axioms' names in
    the book's own right (source credited once by anchor); note TB vs `serial_future` as
    trivially interderivable, and that CO is derivable in BX_c rather than axiomatic.
  - [ ] R4e (finding C4): rewrite §Relation to the Paper's Presentation — primary contrast is
    `def:S5` + `def:BX` + `def:TMplus` (the book's system IS this system); the tense-primitive
    12-schema TM is one deferred-subsystem paragraph pointing to the back-matter table. The
    intended divergences (primed past mirrors, spelled-out CPL, M4/MB primitive; finding C3)
    stay, re-anchored against `def:BX`/`def:TMplus`.
  - [ ] R4f: notation/ordering sweep of every schema display (guard-first infix; axiom tables
    MAY stay future/until-direction-primary matching `def:BX`'s stated direction — the paper's
    own exception per finding A2).
- **Timing:** ~2 hours
- **Depends on:** 1
- **Verification Tier:** local — phase gates; layer-table sum check: the per-layer counts
  stated in the chapter must sum to 45; event-first residual grep on this file.
- **Estimated output:** ~250–300 lines
- **Scope Hypothesis:** the chapter's current layer tables sum to 42 and §Frame Classes
  claims three values; confirm both by reading the sections at dispatch (they drift with
  in-flight Lean work).
- **Done when:** layer tables sum to 45 across nine layers; four-class correspondence stated;
  paper-name columns present; TM+ is the primary comparandum; gates green.

### Phase 5: Metalogic Chapter — Target Completeness Statements [NOT STARTED]

- **Goal:** `04-metalogic.typ` states the target completeness results as clean mathematics
  with CONFIRM obligations; the old incompleteness exposition is cut entirely (Decision D1,
  resolved); genuine negative results stay in the body.
- **Territory:** `typst/chapters/04-metalogic.typ`
- **Tasks:**
  - [ ] R5a (directive-re-aimed; source: restated `cor:tm-completeness`): replace the
    completeness-status table with the four target statements — TM+ strongly complete over
    all task frames; TM+_d strongly complete over the dense frames; TM+_f weakly complete
    over Z-time; TM+_c weakly complete over the dense-and-complete class — as theorem-box
    mathematics with NO Lean-status column. Above each not-yet-established row place a
    CONFIRM comment naming the obligation, e.g.:
    `// CONFIRM(lean): a set-premise strong completeness theorem for FrameClass.Base exists in Metalogic/ and is axiom-free`
    (similarly Dense strong); for the established weak rows:
    `// CONFIRM(lean): completeness_dense / completeness_discrete / completeness_dedekind (Metalogic/BXCanonical/Completeness.lean) remain axiom-free`
    and for the base weak row:
    `// CONFIRM(lean): completeness (FrameClass.Base weak) is axiom-free (WeakCanonical.countermodel_discrete discharged)`.
    Keep the existing `canonical-completeness` LEAN-ANCHOR-MAY-MOVE markers adjacent.
  - [ ] R5a-negative (body, permanent mathematics): state as results that strong completeness
    fails for Z-time and for R (non-compactness; the paper's own rider), and that Discrete
    strong completeness is provably false (non-compactness witness {F p} ∪ {¬Xⁿp}).
  - [ ] R5b: delete the "none is established as complete" citation and every quotation of the
    old corollary text.
  - [ ] R5c (Decision D1 — resolved: CUT): delete §Why TM Is Incomplete, the (DD) theorem
    boxes, the Halldén paragraphs, and the two-fibre cetz diagram outright — no compressed
    remark, no replacement exposition. Retain ONLY the discrete-or-dense dichotomy theorem
    (verified sound; independently used by the introduction) as a standalone stated result
    relocated into this chapter's frame-class-correspondence context, detached from any
    incompleteness narrative, and give it a stable label the introduction can reference.
  - [ ] D1 stranded-reference cleanup (this file): remove any `@`-labels, figure labels, and
    now-unused imports (e.g. cetz, if the two-fibre diagram was this chapter's only usage)
    left by the cut; remove any subsection heading left empty by the deletion rather than
    leaving a stub. `typst compile` failing on a dangling `@`-reference is the mechanical
    check that nothing was missed.
  - [ ] R5d (finding D5): restate the CO/Reynolds-triple independence question as an open
    mathematical problem (open problems are permanent mathematical statements, not progress
    reports) without "under active formalization" phrasing; the existing
    `co-reynolds-independence` marker convention already guards the frame-classes chapter's
    site — no new marker here.
  - [ ] R5e: rewrite §Implementation Status consistently with the directive — remove
    sorry-count displays (status.typ imports for sorry counts go), replacing the load-bearing
    census claim with
    `// CONFIRM(lean): scripts/typst-status-counts.sh --json reports sorry_total_excl_boneyard = 0`;
    retitle/reshape the section as the chapter's formalization-anchor index (which Lean
    theorems carry which results) rather than a status report.
- **Timing:** ~1 hour (cutting is less work than the formerly-planned compression)
- **Depends on:** 1
- **Verification Tier:** local — phase gates; `grep -n 'sorry' typst/chapters/04-metalogic.typ`
  shows no body-prose sorry counts (CONFIRM comments and Lean identifiers are permitted
  matches); event-first residual grep.
- **Estimated output:** ~100–180 lines (net deletion-heavy after the D1 cut)
- **Scope Hypothesis:** the affected sections are as the report mapped them (status table,
  incompleteness exposition, implementation-status section); confirm section presence by
  heading grep at dispatch before editing.
- **Done when:** four target statements stated with CONFIRM obligations; negative results in
  body; no old-corollary quotations; incompleteness exposition fully removed with the
  dichotomy theorem retained standalone and labeled; no dangling labels or stub headings;
  gates green.

### Phase 6: Frame-Classes and Decidability-in-Practice Chapters [NOT STARTED]

- **Goal:** Fix the TM+_c labeling, replace the conservativity theorem box with the
  deferred-subsystem note, and restate decidability as a CONFIRM-guarded target.
- **Territory:** `typst/chapters/p2-frame-classes.typ`,
  `typst/chapters/p2-decidability-practice.typ`
- **Tasks:**
  - [ ] R6a (source: `def:TMplus-c`; finding C6): fix the frame-classes chapter's naming —
    `FrameClass.Dedekind` hosts BX_c/TM+_c (Reynolds; dense-and-complete, real-flow); the
    live paper defines no TM+_dc. The genuine unformalized gap is the BL-level complete-order
    class ({Z, R} up to isomorphism), which no FrameClass targets — keep that gap paragraph's
    substance, relabeled, phrased as a design-scope fact (the book's system does not target
    that class), not as pending work.
  - [ ] R6b (source: `thm:BLplus-PastFuture` live; finding D4): replace §Conservativity's
    theorem box (its paper footnote-source is deleted) with a short "Deferred: the
    tense-primitive subsystem" note — language embedding unconditional (cite
    `thm:BLplus-PastFuture`); proof-system conservativity is the deferred subsystem's future
    result, recorded as
    `// CONFIRM(paper): a conservative-extension theorem for the tense-primitive subsystem is stated (successor of the deleted thm:ConservativeExtension)` —
    no theorem box, no four-part status, and drop the "(DD) split validity" cross-reference
    (this removal also closes this chapter's only dangling reference into the incompleteness
    exposition Phase 5 cuts under Decision D1).
  - [ ] R6c: notation sweep of the Next/Previous section (guard-first infix).
  - [ ] R7 (directive-re-aimed; finding D3): in the decidability-practice chapter, remove the
    dead `cor:tm-decidability` citation (whitelist entry removal deferred to Phase 8). State
    the target: the decision procedure decides TM+ (body, as the aim the paper's conclusion
    asserts), guarded by
    `// CONFIRM(lean): a decidability theorem for TM+ (soundness + completeness of the decision procedure, or FMP bridge) exists and is axiom-free` and
    `// CONFIRM(paper): cor:tm-decidability is restored/restated with proof`.
    Keep the verified `decide_sound` account and the two-witness retraction content (correct
    mathematics); remove "open"/status phrasing from the body; do NOT add the report's
    suggested paper-vs-Lean status sentence (directive: that contrast is CONFIRM material).
    Keep the two `semantic-fmp` markers.
- **Timing:** ~1.5 hours
- **Depends on:** 1
- **Verification Tier:** local — phase gates (note: sync-check stays green because the
  `cor:tm-decidability` whitelist entry is still present until Phase 8 — removing a citation
  never adds a violation); event-first residual grep on both files.
- **Estimated output:** ~150–250 lines
- **Scope Hypothesis:** §Conservativity's theorem box and the dead citation are where the
  report mapped them; confirm by heading/anchor grep at dispatch.
- **Done when:** TM+_c labeling consistent with the metalogic chapter; conservativity box
  replaced by the deferred-subsystem note; decidability CONFIRM-guarded; gates green.

### Phase 7: Back Matter and Periphery — Notes, LTL/Vlach/Frontier, Machine Appendix [NOT STARTED]

- **Goal:** Recast the notes chapter as permanent design notes; fix retired vocabulary and
  citation forms in the three periphery chapters; complete the machine appendix's frame-class
  enumeration.
- **Territory:** `typst/chapters/06-notes.typ`, `typst/chapters/p3-ltl-to-tm.typ`,
  `typst/chapters/p3-vlach-blstar.typ`, `typst/chapters/p3-decidability-frontier.typ`,
  `typst/chapters/ax-machine-appendix.typ`
- **Tasks:**
  - [ ] R8a–c (directive-re-aimed): in `06-notes.typ` — "eight layers" → nine; delete
    §Completeness Status's old-corollary quotation and replace the section with a one-line
    pointer to the metalogic chapter's target statements (no parallel status prose); tighten
    §Language Basis to the deferred-subsystem framing with its conservativity sentence
    replaced per Phase 6's R6b shape. Recast the chapter's framing from "implementation
    status" to permanent design notes: intended divergences (structured Atom, primed
    mirrors, CPL layer, argument-order-free notational facts) are design records and stay;
    sorry-count displays and "current status" prose go (CONFIRM comments where load-bearing,
    reusing Phase 5's census CONFIRM shape).
  - [ ] R8d–e (source: `sub:RestrictedModalities`; finding E3): fix the Restricted-Modalities
    citation to anchor form; keep the 12-schema TM correspondence table, labeled explicitly
    as the deferred subsystem's axiom map.
  - [ ] R10 (finding F4): in `p3-ltl-to-tm.typ` — fix the retired axiom vocabulary (the
    embedding frame satisfies Compositionality/Seriality/Limit/Spherical); notation sweep of
    the translation table and Next discussion; shrink §The Conservativity Bridge to match
    Phase 6's deferred-subsystem note (pointer, not a restatement).
  - [ ] R11 (finding E3, F5): in `p3-vlach-blstar.typ` and `p3-decidability-frontier.typ` —
    replace paper line/section-number citations with anchors; update the frontier chapter's
    `cor:tm-decidability` sentence per Phase 6's R7 shape (CONFIRM-guarded target, dead
    citation removed); notation sweep where S/U displays appear. No content rewrites in the
    Vlach chapter (finding F5: aligned).
  - [ ] R12 (finding C1): in `ax-machine-appendix.typ` — add `Dedekind` to the `frame_class`
    prose enumeration. Add
    `// CONFIRM(lean): the machine appendix JSONL's since/until argument fields reflect guard-first constructor order`
    above the field-schema prose (the JSONL regenerates from Lean when the migration lands;
    `scripts/typst-machine-appendix.sh` + sync-check Check 3 handle the mechanical refresh).
- **Timing:** ~1.5 hours
- **Depends on:** 1
- **Verification Tier:** local — phase gates; event-first residual grep on all five files;
  `grep -n 'possible_worlds' typst/chapters/p3-vlach-blstar.typ typst/chapters/p3-decidability-frontier.typ typst/chapters/06-notes.typ`
  shows anchor-form citations only (no `:NNNN` line references, no bare §-numbers).
- **Estimated output:** ~150–250 lines
- **Scope Hypothesis:** five files, with the notes chapter carrying the bulk; the p3 chapters'
  edits are citation-form and sweep-only. Confirm the citation inventory by the grep above at
  dispatch; if the notes-chapter recast alone exceeds ~250 lines of output, split it off as
  Phase 7.1 (notes) / 7.2 (periphery + appendix) at implementation time.
- **Done when:** notes chapter carries no status prose; all periphery citations anchor-form;
  Dedekind enumerated in the appendix prose; gates green.

### Phase 8: Front Matter, Sync Records, and Closure [NOT STARTED]

- **Goal:** Reframe the abstract and introduction to the target state, record the revision in
  SYNC-MAP, clean the whitelist, and run the full closing gate set.
- **Territory:** `typst/BimodalReference.typ`, `typst/chapters/00-introduction.typ`,
  `typst/SYNC-MAP.md`, `typst/sync-check-whitelist.txt`
- **Tasks:**
  - [ ] R9a (finding F2; Decision N1 default): reframe the abstract and introduction — the
    book's system is the Until/Since-primitive bimodal logic, the paper's TM+, presented in
    full; the tense-primitive TM is a deferred subsystem; one early introduction remark fixes
    the naming convention (book's TM = paper's TM+).
  - [ ] R9b (directive-re-aimed): replace the "provably incomplete ... headline correction"
    sentences and the "one proof obligation outstanding" clause with the target-state
    completeness summary matching Phase 5's four statements; "fully proven" claims for
    soundness/deduction/Lindenbaum/perpetuity may stand only as statements of what the
    system's metatheory delivers, CONFIRM-guarded where the report found them ahead of the
    tree (soundness and perpetuity are verified sorry-free — no CONFIRM needed there).
  - [ ] R9c–d (finding C1, F3): "8 layers" → nine in the introduction; fix the Z/Q phrasing —
    frame classes are discrete/dense ordered abelian groups generally, with Z the
    successor-Archimedean completeness carrier and Q the dense chronicle carrier.
  - [ ] D1 stranded-reference check (front matter): the introduction independently uses the
    discrete-or-dense dichotomy theorem — verify its reference resolves to the standalone
    labeled statement Phase 5 retained in 04-metalogic, and that no abstract/introduction
    sentence still mentions the (DD) split validity, the two-fibre countermodel, or Halldén
    completeness (grep both files for `DD`, `two-fibre`, `Halldén`/`Hallden`).
  - [ ] R9e: ordering/notation sweep of operator mentions in both files.
  - [ ] R13: append a dated verdict section to `typst/SYNC-MAP.md` recording this revision
    (target-state directive, notation switch, completeness restatement, CONFIRM convention
    introduction); do not rewrite historical sections (per that file's own header rule).
  - [ ] Whitelist cleanup (deferred here from Phases 6–7 by postmortem constraint): remove
    the `cor:tm-decidability` entry, and the `thm:ConservativeExtension` entry if its last
    citation is gone; verify with `grep -rn 'cor:tm-decidability\|thm:ConservativeExtension'
    typst/chapters/` before removing each. Additionally, check for whitelist entries orphaned
    by the Phase 5 D1 cut (e.g. the `⊥ U φ` rejected-construction illustration or any
    two-fibre-countermodel candidate): for each whitelist entry, confirm a citing occurrence
    still exists in `typst/**/*.typ`; remove entries with none.
  - [ ] Closing gate set (full): `bash scripts/typst-status-counts.sh` (regenerate, confirm
    no count drift); `cd typst && typst compile BimodalReference.typ
    build/BimodalReference.pdf` exit 0; `bash scripts/typst-sync-check.sh` PASS all checks;
    CONFIRM well-formedness grep empty; book-wide event-first residual grep
    (`grep -rnE '\bU\(|\bS\(' typst/chapters/`) shows only deliberate literature-form
    mentions; `grep -rn 'FIX:' typst/chapters/` returns nothing for the three resolved
    comments; `bash scripts/check-paper-definitions.sh` still passes.
- **Timing:** ~1.5 hours
- **Depends on:** 2, 3, 4, 5, 6, 7
- **Verification Tier:** full — this phase runs the complete repository gate set for the
  typst deliverable (compile + sync-check + count regeneration + convention greps), closing
  what the earlier `local`-tier phases deferred.
- **Estimated output:** ~120–180 lines
- **Scope Hypothesis:** both whitelist entries become removable in this phase; confirm each
  with the citation grep above — if a citation survives (e.g. a deliberate
  negative-resolution mention retained by an earlier phase), keep that whitelist entry and
  record the reason in the phase notes rather than forcing removal.
- **Done when:** abstract/introduction state the target system with no edition-history
  narrative; SYNC-MAP verdict appended; whitelist consistent; ALL closing gates green.

## Testing & Validation

- [ ] Per-phase (every phase): `typst compile` exit 0; `typst-sync-check.sh` PASS; CONFIRM
  well-formedness grep empty (commands in the convention section).
- [ ] Phase 4 arithmetic check: chapter layer-table counts sum to 45.
- [ ] Phase 8 full gate set (enumerated in Phase 8's closing task).
- [ ] User acceptance greps (documented deliverables): `grep -rn 'CONFIRM(lean)' typst/` and
  `grep -rn 'CONFIRM(paper)' typst/` enumerate the complete finished-state checklist.

## Artifacts & Outputs

- plans/01_manual-to-target-state.md (this file)
- Modified: `typst/notation/bimodal-notation.typ`, `typst/README.md`,
  `typst/BimodalReference.typ`, `typst/SYNC-MAP.md`, `typst/sync-check-whitelist.txt`,
  `specs/paper-definitions-of-record.md`, and 12 chapter files
  (00-introduction, 01-syntax, 02-semantics, 03-proof-theory, 04-metalogic,
  p2-frame-classes, p2-decidability-practice, p3-ltl-to-tm, p3-vlach-blstar,
  p3-decidability-frontier, ax-machine-appendix, 06-notes)
- Not modified: any `.lean` file, `possible_worlds.tex`, `typst/generated/status.typ`
  (regenerated only), `typst/FormalFoundations.typ`, `typst/chapters/05-theorems.typ`,
  `typst/chapters/p4-*.typ` (no defects found by the report)
- summaries/01_manual-to-target-state-summary.md (at implementation completion)

## Rollback/Contingency

- Each phase commits independently (`task 449 phase P: {name}`); a defective phase reverts as
  a single commit without disturbing siblings (Wave-2 phases own disjoint files).
- If the paper drifts mid-implementation (`check-paper-definitions.sh` fails at a phase
  gate-in): stop, re-pin `specs/paper-definitions-of-record.md` against the new state, and
  re-verify only the anchors the current phase cites before proceeding.
- Decisions E1 and D1 are resolved (2026-08-17) and settled by postmortem constraint; no
  decision-flip contingency remains. Should the user later reverse D1, the cut exposition is
  recoverable from git history (it was committed content before this task).
- If `typst compile` breaks and cannot be fixed forward within a phase: revert that phase's
  working-tree edits only (via `git-snapshot.sh` + targeted restore per
  `.claude/rules/git-workflow.md`), never the committed prior phases.
