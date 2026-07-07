# Implementation Plan: Task #315

- **Task**: 315 - Write the three positioning chapters closing BimodalReference Part I
- **Status**: [NOT STARTED]
- **Effort**: 7 hours
- **Dependencies**: None (task 319 restructure already landed; all sources readable)
- **Research Inputs**: specs/315_write_bimodalreference_part_iii_expressivepower_ch/reports/01_positioning-chapters-research.md
- **Artifacts**: plans/01_positioning-chapters-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: typst
- **Lean Intent**: false

## Overview

Replace the one-sentence placeholders in the three chapters that close Part I of
`Theories/Bimodal/typst/BimodalReference.typ` — `chapters/p3-ltl-to-tm.typ`,
`chapters/p3-vlach-blstar.typ`, `chapters/p3-decidability-frontier.typ` — with plain
textbook prose (no sync-class banners, no status symbols, no task numbers in body text,
per the task-319 register). A single bibliography pass first fixes two citation errors
caught in research (blackburn2000hybrid must become the IGPL manifesto `@article`;
Kamp's expressive-completeness theorem must cite `kamp1968` + `rabinovich2014`, NOT
`kamp1971formalproperties`) and imports all needed pre-verified entries. The
decidability-frontier chapter is written under the Lk EMBARGO: header comment and the
three `// SLOT-IN:` anchors preserved verbatim, no Lk-specific results anywhere.
Definition of done: both gates pass — `typst compile` (exit 0) and
`bash scripts/typst-sync-check.sh` (checks 1+2 per task 319 renumbering).

### Research Integration

Report `01_positioning-chapters-research.md` supplies: exact current file states and
hard constraints (§1); the two verification gates and backtick discipline with the
live-verified list of resolving Lean names (§2); full content inventories with paper
line citations for each chapter (§3-§5); live citation-verification verdicts and the
single-pass bibliography work plan (§4, §6); the style contract (§7); eight named
risks/traps (§8); and the recommended implementation order bib → vlach → ltl-to-tm →
frontier (§9). This plan follows that order and encodes every constraint as a phase
task or verification item.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md consulted (no roadmap_path in delegation context).

## Goals & Non-Goals

**Goals**:
- Three chapters of complete, self-standing textbook prose closing Part I, at the
  research-recommended sizes (ltl-to-tm ~140-190 lines, vlach-blstar ~150-200,
  decidability-frontier ~90-130).
- Honest positioning: TM as Until/Since temporal logic over linear orders fused with
  S5 + MF interaction over task frames — never "vanilla LTL + S5".
- Correct scholarship: Vlach/Kamp/Cresswell/hybrid-logic prior art with the two
  citation errors fixed and verified entries added; Kamp's theorem cited to the 1968
  dissertation + Rabinovich 2014 with both scope conditions (strict operators,
  Dedekind-complete flow) stated.
- Embargo compliance in the frontier chapter: EMBARGO header + 3 SLOT-IN anchor blocks
  byte-identical to the current file; published-results-only ceiling-and-descent
  narrative; zero Lk citations or paraphrased Lk theorems.
- Every backticked span resolves under sync-check Check 1; both gates green.

**Non-Goals**:
- No axiomatization of BL⋆ (the paper explicitly defers this; the book says the same).
- No restatement of salvaged content: the Determined/Deterministic remark
  (02-semantics.typ:166-169) and the FMP-resolution wording
  (p2-decidability-practice.typ) are cross-referenced, never duplicated.
- No decidability/complexity ladder content in the ltl-to-tm chapter (one forward
  reference at most); no perpetuity re-proof (05-theorems owns it).
- No populating the SLOT-IN anchors (reserved for task 318, post-TACAS-acceptance).
- No hand-written counts anywhere (sync-check Check 2); no edits to
  `generated/status.typ`.
- No changes to chapter titles/order that would break the abstract's promise at
  `BimodalReference.typ:139`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Backticked non-Lean tokens fail sync-check Check 1 (the #1 failure mode) | M | H | Backticks ONLY for names on the report §2 verified list or real repo paths; BL⋆, LTL, S5, HyperLTL, glyphs, paper theorem labels set in italics/math/plain text; dedicated backtick audit in Phase 5 before running the script; whitelist additions only as last resort |
| Kamp misattribution survives into print | H | M | Phase 1 rewrites the `kamp1971formalproperties` note and adds `kamp1968` + `rabinovich2014`; Phase 2 cites the theorem exclusively as kamp1968 (+rabinovich2014) and "now" as kamp1971formalproperties; Phase 5 grep-audits `@kamp1971formalproperties` contexts |
| Embargo leakage by paraphrase (e.g. "undecidable for k >= 2" as a tower claim) | H | M | Frontier chapter states only the *expectation from published prior art* form (report §5); Phase 5 adversarial audit greps for Lk, L_k, Lₖ, alternation-free, tower-specific complexity claims, and diff-verifies header + anchors byte-identical |
| `PriorStructure` or other non-resolving name backticked | M | M | Report §2: write "Prior structures" in prose; only `MonadicFormula`, `KampTranslation`, `rabinovich_translate`, `kamp_prior_expressive_completeness`, etc. from the verified list get backticks |
| Conservativity overclaim (attributing paper's L-vs-L⁺ theorem to `Metalogic/ConservativeExtension/`) | M | M | ltl-to-tm states the two-layer story honestly: paper theorem cited to the paper; Lean side cross-references p2-frame-classes' fresh-atom `lift_derivation_qfree` statement without re-litigating |
| Bib key collisions / casing drift when copying from Lk.bib and possible_worlds.bib | L | M | Single Phase 1 edit pass; normalize copied keys to the book's all-lowercase convention; compile after the pass (unused entries are harmless under ieee numeric style) |
| Vlach glyph inconsistency (⋆ vs ★) | L | L | Keep `BL#super[⋆]` exactly as the existing heading; Phase 5 grep for ★ |
| Chapter cross-references dangle (labels not yet defined when a sibling compiles) | M | L | Label contract fixed in this plan before writing: `<sec:ltl-to-tm>`, `<sec:vlach-blstar>`, `<sec:decidability-frontier>`; each chapter adds its own label in its own phase; full-document compile at the end of every writing phase |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |

Phases within the same wave can execute in parallel. (Phases 2 and 3 touch disjoint
files and use the pre-agreed label contract above, so either order — or parallel
execution — is safe; the research-recommended sequence is 2 before 3.)

### Phase 1: Bibliography pass [COMPLETED]

**Goal**: All citations needed by the three chapters exist and are correct in
`Theories/Bimodal/typst/bibliography.bib`, unblocking every later `@key`.

**Tasks**:
- [ ] Fix `blackburn2000hybrid`: convert to `@article` with the IGPL manifesto fields —
      Blackburn, "Representation, Reasoning, and Relational Structures: a Hybrid Logic
      Manifesto", *Logic Journal of the IGPL* 8(3):339-365, 2000. Keep the key.
- [ ] Fix `kamp1971formalproperties`: add volume 37, number 3, pages 227-273 (Theoria);
      rewrite its note to "Kamp's *now* operator; NOT the source of the
      expressive-completeness theorem — see kamp1968".
- [ ] Enrich `cresswell1990entities`: Kluwer, Studies in Linguistics and Philosophy
      vol. 41, Dordrecht, 1990; clear its "verify before print" note.
- [ ] Clear now-verified "verify before print" notes on `baierkatoen2008` and
      `gabbay2003manyvalued`; merge GKWZ series/volume data from `Lk/Lk.bib:179`.
- [ ] Add from `Lk/Lk.bib` (pre-verified in Lk Phase 14, copy wholesale): `kamp1968`,
      `rabinovich2014`, `gpss1980` (optional), `sistlaClarke1985`, `marx1999`,
      `hmv2004`, `hirschHodkinsonKurucz2002`, `arecesBlackburnMarx2001`,
      `tenCateFranceschet2005`, `franceschetEtAl2003`, `demriLazic2009`,
      `alurHenzinger1994`, `goranko1996` (Lk/Lk.bib:260).
- [ ] Add from `possible_worlds.bib` (normalize keys to the book's all-lowercase
      convention): `Pnueli1977`, `Clarke1982`, `Emerson1986`, `Lamport1980` (or
      `lamport1983`), `Vardi2001`, `Belnap2001`, `Rumberg2016`, `Thomason1984`,
      `Kurucz2003` (optional), `Clarkson2014`, `Finkbeiner2015`, `Finkbeiner2016`,
      `Finkbeiner2017`.
- [ ] Record the final key spelling for every added entry (needed by Phases 2-4 when
      citing) — keep a short key list in the phase commit message or progress notes.
- [ ] Preserve the embargo header comment at the top of `bibliography.bib` (NO Lk
      entry) — verify it is untouched.

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/typst/bibliography.bib` - fix 2 entries, enrich 2, clear verified
  notes, add ~20 entries

**Verification**:
- `typst compile Theories/Bimodal/typst/BimodalReference.typ` exits 0 (unused entries
  do not render under ieee numeric style, so this catches only syntax errors — that is
  the point of this gate here).
- Embargo header comment still present at top of bibliography.bib; no entry mentions
  the Lk submission.
- Grep confirms `kamp1968`, `rabinovich2014`, `goranko1996`, `franceschetEtAl2003`
  (or lowercased equivalents) now exist.

---

### Phase 2: Write p3-vlach-blstar.typ [COMPLETED]

**Goal**: Complete chapter "Vlach Operators and the BL#super[⋆] Tower" (~150-200
lines), the citation-sensitive scholarly spine, replacing the placeholder sentence.

**Tasks**:
- [x] Keep the existing heading `= Vlach Operators and the BL#super[⋆] Tower` (glyph ⋆,
      not ★) and add label `<sec:vlach-blstar>`; optional `#chapter-header(...)` per
      the p2-frame-classes/p2-decidability-practice pattern.
      [DEVIATION: heading label is `<ch:vlach-blstar>` instead of `<sec:vlach-blstar>`,
      per orchestrator course correction — task 317 depends on a resolvable
      `<ch:vlach-blstar>` label on this chapter heading. A typst heading carries one
      label; no sibling chapter needs `@sec:vlach-blstar`, so no dangling refs.]
      [DEVIATION: the `<sec:decidability-frontier>` label was added to the
      p3-decidability-frontier.typ heading during this phase (heading line only, embargo
      blocks untouched) so this chapter's forward reference compiles green.]
- [ ] Motivation section: TM⁺ "lack[s] the means by which to cross reference either
      times or worlds" (possible_worlds.tex:1246); natural-language driver — tense
      anaphora ("Once, everyone now alive hadn't yet been born"), Kamp's "now",
      Vlach's "then".
- [ ] The operators exactly as in the paper (:1246-1256): evaluation points gain a
      vector v of stored times and μ of stored worlds; four indexed families —
      time-store ↑ⁱ, time-recall ↓ⁱ, world-store ⇑ⁱ, world-recall ⇓ⁱ; generalizes
      Vlach's single now/then pair to indexed families and adds world-theoretic
      counterparts; BL semantics otherwise unchanged.
- [ ] BL⋆ definition (:1255) including the stability operator Ⓞ: short subsection
      presenting Ⓞ (quantifies over worlds intersecting τ at x; monomodal S5; trivial
      on non-temporal formulas); one paragraph on definable Will/Could and open-future/
      open-past restrictions |τ⟩ₓ/⟨τ|ₓ with the definability-not-primitive-accessibility
      payoff (:1052-1060). State plainly that the paper declines to axiomatize BL⋆
      (:1256) and a logic for BL⋆ is future work.
- [ ] Worked-use pointer, ONE sentence: the open-future analysis application with
      `@brastmckie2026possibleworlds` and a cross-reference to the Determined/
      Deterministic closing remark of the semantics chapter (02-semantics.typ:166-169).
      Do NOT reintroduce the sea-battle exposition.
- [ ] Hybrid-logic prior-art narrative: Kamp 1971 "now" (@kamp1971formalproperties —
      its correct role); Vlach 1973 "then"/storage-recall (@vlach1973nowandthen);
      Cresswell 1990 unboundedly many stored indices (@cresswell1990entities); hybrid
      ↓-binder and @-operator (@blackburn2000hybrid, now the manifesto); Goranko's
      reference pointers (@goranko1996). Framing sentence: Vlach families are
      hybrid-style binders over time and world coordinates with an indexed register
      vector; known cost profile of ↓ motivates the frontier chapter — one forward
      reference to `<sec:decidability-frontier>`, NO results stated here.
- [ ] Kamp's theorem, correctly scoped: Until/Since in their STRICT readings are
      expressively complete for the first-order theory of linear order over
      Dedekind-complete flows — cite `@kamp1968` + `@rabinovich2014`, NEVER
      kamp1971formalproperties. State both scope conditions; cross-reference the
      book's strict-semantics discussion (`@sec:design-choices` / 06-notes.typ).
      Optional completing note: GPSS 1980 future-only adequacy over ℕ-like flows
      (why LTL can be future-only; TM keeps past operators because its flows are
      general) — cite `gpss1980` if added in Phase 1.
- [ ] Formalization frontier in honest plain prose (04-metalogic.typ:113-117 register):
      work toward a Kamp-style expressive-completeness theorem is in progress in
      `Metalogic/WeakCanonical/Kamp/` — Rabinovich proof chain targeting
      `kamp_prior_expressive_completeness` (every `MonadicFormula` with one free
      variable has a U/S-equivalent on Prior structures — "Prior structures" in plain
      prose, no backticks), translation implemented as `rabinovich_translate`. State
      the modules are not sorry-free and results "should not be cited as settled";
      one or two plain sentences, NO sorry-count tables, NO status symbols.
- [ ] Paper-side theorems via `#theorem(...)` + citation footnote, never fabricated
      Lean anchors; `#leansrc(module, name)` only for real Lean declarations.

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/typst/chapters/p3-vlach-blstar.typ` - full chapter prose replacing
  the placeholder

**Verification**:
- `typst compile Theories/Bimodal/typst/BimodalReference.typ` exits 0.
- Chapter contains no ✓/⧖/○/◇ symbols, no task numbers, no sync-class banners.
- `@kamp1968` and `@rabinovich2014` cite the theorem; `@kamp1971formalproperties`
  appears only in the "now"-operator prior-art role.
- Backticks limited to the report §2 verified list; heading glyph is ⋆.

---

### Phase 3: Write p3-ltl-to-tm.typ [NOT STARTED]

**Goal**: Complete chapter "From LTL to TM: Honest Positioning" (~140-190 lines)
replacing the placeholder sentence.

**Tasks**:
- [ ] Keep the existing heading; add label `<sec:ltl-to-tm>`; optional
      `#chapter-header(...)`.
- [ ] Thesis paragraph (mandated framing): TM is Until/Since temporal logic over
      linear orders (durations a totally ordered abelian group, strict/irreflexive
      semantics) fused with an S5 metaphysical modality plus the MF interaction axiom
      and uniformity axioms, interpreted over task frames where worlds are
      task-constrained functions from convex duration sets to world states. The
      modality quantifies over the constructed history space, not a second primitive
      Kripke dimension. NO "TM = LTL + S5" phrasing anywhere, including section titles.
- [ ] Trace vs task semantics contrast: LTL ω-sequences, distinguished initial point,
      non-strict Until with primitive Next (`@baierkatoen2008`,
      `@demrigorankolange2016`) vs TM histories with convex domains over an ordered
      abelian group, bi-infinite or partial, no initial point, validity over all
      frames/histories/times. Cross-reference the semantics chapter rather than
      restating; use possible_worlds.tex:1412-1440 (task frame as labeled transition
      system with duration labels).
- [ ] Operator-convention deltas (table or short list): strict vs non-strict
      Until/Since (cross-ref `@sec:design-choices`); Next/Previous derived (`next`/
      `prev`, Burgess convention, `next_unfold`/`prev_unfold` — cross-ref
      p2-frame-classes §Next and Previous); past operators present vs LTL future-only
      (GPSS adequacy belongs to chapter 2's Kamp discussion — pointer only); anchored
      vs floating validity.
- [ ] Fusion vs product positioning (GKWZ vocabulary): TM is neither the fusion (no
      interaction) nor literally the product PTL × S5 — MF (and derived TF) hold
      because worlds are constructed with time-shift invariance, where the general
      product landscape must impose such principles (possible_worlds.tex:1519-1526).
      Cite `@gabbay2003manyvalued`; optionally the Kurucz 2003 handbook chapter.
- [ ] LTL/CTL/CTL*/HyperLTL triangulation (possible_worlds.tex:1519-1533, fully
      outside the Lk embargo): worlds linear as in LTL; worlds through a world state
      branch as in CTL; □ unrestricted rather than state-relativized path
      quantification; HyperLTL binds trace variables and its satisfiability is
      undecidable whereas TM's □ binds nothing. Cite the Pnueli/Clarke/Emerson/
      Lamport/Vardi/Clarkson/Finkbeiner entries added in Phase 1.
- [ ] Branching-time neighbors, brief: STIT (Belnap-Perloff-Xu, `@belnap2001`) and
      Rumberg transition semantics (`@rumberg2016`, `@thomason1984`) posit branching
      outright; the task relation unfolds into a tree from a total duration order
      (:1495-1501). Optional: shifts of finite type as the finite-discrete instance
      (`@lind2021` if added).
- [ ] Conservativity bridge, two-layer honest story: paper side — TM (H/G basis)
      extends conservatively to TM⁺ (Until/Since basis), the book's Lean system works
      in the Until/Since basis natively (possible_worlds.tex:1240-1244 + 06-notes
      §Language Basis); Lean side — NO Lean module formalizes the paper's L-vs-L⁺
      conservativity; `Metalogic/ConservativeExtension/` proves the different
      fresh-atom lemma `lift_derivation_qfree` — cross-reference
      `@sec:conservative-extension` (p2-frame-classes) rather than overclaiming.
- [ ] At most one forward reference to `<sec:decidability-frontier>`; no complexity
      results here. Perpetuity cited by cross-reference (P1/P2, 02-semantics
      §Time-Shift), not restated.

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/typst/chapters/p3-ltl-to-tm.typ` - full chapter prose replacing
  the placeholder

**Verification**:
- `typst compile Theories/Bimodal/typst/BimodalReference.typ` exits 0.
- Grep: no occurrence of "vanilla LTL" or any "LTL + S5" identity phrasing.
- No decidability/complexity claims; at most one forward reference to the frontier
  chapter; no restated perpetuity proof.
- Backticks limited to verified list (`untl`, `snce`, `next`, `prev`, `next_unfold`,
  `prev_unfold`, `lift_derivation_qfree`, real paths); LTL/S5/CTL/HyperLTL never
  backticked.

---

### Phase 4: Write p3-decidability-frontier.typ [NOT STARTED]

**Goal**: Complete chapter "The Decidability Frontier" (~90-130 lines) under full
embargo compliance, with prose sections placed so each SLOT-IN anchor sits at the
natural insertion point of its future content.

**Tasks**:
- [ ] Preserve BYTE-IDENTICAL: the EMBARGO header comment block (current lines 8-12)
      and all three `// SLOT-IN:` anchor blocks with their reservation comments
      (ladder-table, complexity-map, case-study). Take a before-copy of these blocks
      for the Phase 5 diff.
- [ ] Add label `<sec:decidability-frontier>`; keep the heading; optional
      `#chapter-header(...)`.
- [ ] Section (i) — the question: what expressive extensions cost.
- [ ] Section (ii) — floor and product zone: LTL satisfiability PSPACE-complete
      (Sistla-Clarke 1985); PTL × S5 products decidable but EXPSPACE-hard/complete
      territory (GKWZ 2003, Marx 1999, Halpern-van der Meyden-Vardi 2004); ceiling
      within products: S5×S5×S5-like three-dimensional products undecidable/
      non-finitely-axiomatizable (Hirsch-Hodkinson-Kurucz 2002) — positioning "one
      modal dimension over linear time" as the safe zone.
- [ ] Section (iii) — the cross-referencing ceiling with linear-flow descent: hybrid ↓
      undecidable over arbitrary frames (Areces-Blackburn-Marx 2001, ten Cate-
      Franceschet 2005); over linear structures hybrid binders become decidable though
      non-elementary (Franceschet-de Rijke-Schlingloff 2003 — CAUTION: this paper, NOT
      tenCateFranceschet2005, is the linear-order decidable bound); freeze/registers:
      one register future-only decidable non-primitive-recursive, two registers or
      past undecidable (Demri-Lazić 2009), clock discipline as tamer alternative
      (Alur-Henzinger 1994); trace quantification: HyperLTL satisfiability undecidable
      (Finkbeiner-Hahn 2016), model checking decidable at quantifier-alternation-
      exponential cost (Finkbeiner-Rabe-Sánchez 2015), FO embedding (Finkbeiner-
      Zimmermann 2017), origin (Clarkson et al. 2014); reference pointers
      (Goranko 1996).
- [ ] Section (iv) — BL⋆ expectation paragraph in the *prior-art expectation* form
      ONLY: indexed store/recall over both times and worlds gives hybrid-binder-like
      power in two coordinates; by the published pattern one must EXPECT undecidability
      at the top of the tower and decidable fragments only under register bounds,
      anchoring disciplines, or quantifier restrictions. Attribute nothing; leave
      actual tower results to the SLOT-INs. Prose ends at anchor 1 (ladder-table).
- [ ] Section (v) — what a complexity map for the tower would need to chart (generic,
      forward-looking); prose ends at anchor 2 (complexity-map).
- [ ] Section (vi) — applications outlook, verification-flavored and generic
      (`@baierkatoen2008`); prose ends at anchor 3 (case-study).
- [ ] Section (vii) — TM's own position: decidable via FMP claimed in the paper
      (`@brastmckie2026possibleworlds`, cor:tm-decidability); in-repo, tableau
      soundness proven (`decide_sound`), finite-filtration FMP statement sorry-free
      (`fmp_completeness`), semantic-validity bridge open — REUSE the resolved wording
      via cross-reference `@sec:decidability-practice`, do not paraphrase freshly.
- [ ] FORBIDDEN content check while writing: no BL⋆-ladder table, no L_k/Lₖ theorem or
      attribution, no alternation-freedom results, no hardware/constant-time case
      study, no Lk citation, no "undecidable for k >= 2" / "PSPACE-complete
      diamond-free fragment" style claims about the tower.

**Timing**: 1.5 hours

**Depends on**: 2, 3

**Files to modify**:
- `Theories/Bimodal/typst/chapters/p3-decidability-frontier.typ` - prose sections
  woven around the preserved header and anchors

**Verification**:
- `typst compile Theories/Bimodal/typst/BimodalReference.typ` exits 0.
- Diff of EMBARGO header block and the three SLOT-IN blocks against the pre-edit copy:
  byte-identical, still in-place, each at its natural insertion point.
- Grep the chapter for `Lk`, `L_k`, `Lₖ`, `alternation`, `TACAS`: hits only inside the
  preserved comment blocks.
- Prose is complete and self-standing without the anchors.

---

### Phase 5: Full verification, backtick and embargo audit [NOT STARTED]

**Goal**: Both gates green on the finished book; adversarial audit of the three
predictable failure modes (backticks, Kamp attribution, embargo leakage).

**Tasks**:
- [ ] Backtick audit: extract every backticked span in the three new chapters; each
      must be (a) on the report §2 verified list or a real `Theories/Bimodal/` path, or
      (b) whitelisted. Confirm BL⋆/LTL/S5/CTL/HyperLTL/operator glyphs/paper theorem
      labels are NOT backticked. Whitelist additions to `sync-check-whitelist.txt`
      only if a genuinely non-Lean backtick is unavoidable (expected: none).
- [ ] Kamp audit: grep all three chapters for `kamp` citations; theorem contexts cite
      kamp1968 (+rabinovich2014); kamp1971formalproperties only in "now" contexts.
- [ ] Embargo audit (repeat of Phase 4 check on the final state): header + anchors
      byte-identical; no Lk-derived claims in prose; bibliography.bib contains no Lk
      entry and its embargo header comment is intact.
- [ ] Consistency audit: chapter titles/order still match the abstract's promise
      (`BimodalReference.typ:139`); glyph ⋆ used throughout; no hand-written counts in
      any new chapter; no duplication of the Determined/Deterministic remark or the
      FMP-resolution wording (cross-references only).
- [ ] Run `typst compile Theories/Bimodal/typst/BimodalReference.typ` — exit 0 (the
      two pre-existing thmbox font warnings are tolerated; page count should grow from
      the 59-page baseline).
- [ ] Run `bash scripts/typst-sync-check.sh` — both checks pass (Check 1 name
      resolution, Check 2 count freshness).
- [ ] Fix any failures and re-run both gates to green.

**Timing**: 0.5 hours

**Depends on**: 4

**Files to modify**:
- (audit fixes only, if any) `Theories/Bimodal/typst/chapters/p3-*.typ`,
  `Theories/Bimodal/typst/sync-check-whitelist.txt` (last resort)

**Verification**:
- `typst compile` exit 0 AND `bash scripts/typst-sync-check.sh` exit 0, both run
  from the repo root on the final state — these are the task's acceptance gates.

## Testing & Validation

- [ ] `typst compile Theories/Bimodal/typst/BimodalReference.typ` exits 0 after every
      writing phase and on the final state.
- [ ] `bash scripts/typst-sync-check.sh` exits 0 on the final state (checks 1+2).
- [ ] EMBARGO header + three SLOT-IN anchor blocks byte-identical to the pre-task file.
- [ ] Zero occurrences of Lk-specific results, Lk citations, or "vanilla LTL + S5"
      framing in the compiled prose.
- [ ] Kamp theorem cited as kamp1968 + rabinovich2014; blackburn2000hybrid is the IGPL
      manifesto `@article`.
- [ ] Every backticked span resolves (whitelist, path, or Lean grep); no status
      symbols, task numbers, or sync-class banners in body text.

## Artifacts & Outputs

- `Theories/Bimodal/typst/bibliography.bib` (2 fixes, 2 enrichments, ~20 additions)
- `Theories/Bimodal/typst/chapters/p3-ltl-to-tm.typ` (~140-190 lines)
- `Theories/Bimodal/typst/chapters/p3-vlach-blstar.typ` (~150-200 lines)
- `Theories/Bimodal/typst/chapters/p3-decidability-frontier.typ` (~90-130 lines)
- `specs/315_write_bimodalreference_part_iii_expressivepower_ch/plans/01_positioning-chapters-plan.md` (this file)
- `specs/315_write_bimodalreference_part_iii_expressivepower_ch/summaries/01_positioning-chapters-summary.md` (on completion)

## Rollback/Contingency

All changes are additive prose edits to four text files in a git repository. To
revert: `git checkout` the four files to their pre-task state (the placeholders and
the current bibliography.bib are committed). Phases commit independently, so a failed
later phase rolls back alone. If sync-check Check 1 cannot be satisfied for a needed
token, prefer rewording the prose over whitelist growth; if a citation entry proves
unverifiable, cite the verified subset and note the omission in the summary rather
than fabricating fields. The EMBARGO blocks are never at risk from rollback since they
are preserved verbatim from the committed baseline.
