# Research Report: Task #313

**Task**: Design the full extent of the BimodalReference book
**Date**: 2026-07-06
**Mode**: Team Research (4 teammates: Primary, Alternatives, Critic, Horizons)
**Session**: sess_1783395983_8bc762
**Lean ground truth**: commit `a883361bf` (post-task-312 synced state)

## Summary

The full-extent book is feasible and unusually well-sourced: nearly all proposed content
already exists in mature written form across the two possible-worlds papers, the Lk paper, the
counterfactuals paper, the LogosManual Typst chapters, and ~9,000 lines of unsurfaced Lean
(`Automation/`, `Examples/`, `Decidability/`). The dominant design constraint is **not content
but epistemic discipline**: task 312 just established a verified-reference contract (SYNC-MAP,
271 resolved Lean names), and most candidate additions are *not formalized* (Vlach/BL⋆
operators, all Lk results, the counterfactual layer, the 2D-semantics appendices). Every
teammate independently converged on the same solution: a **part-structured living monograph
with a per-chapter/per-claim sync-class legend** (verified / stated-with-sorries /
paper-sourced / outlook-planned), with infrastructure (status legend, `typst-sync-check.sh`
CI, scripted status counts) created **before** expansion. Three findings materially correct
the task framing (see Conflicts Resolved), and three decisions need the user before planning
(see Open Questions).

## Key Findings

### Primary Approach (Teammate A — content gap analysis)

- **The current book is a synced reference core, not yet a book** (~1,560 lines, ch. 00–06).
  Task 312's scope exclusions (SYNC-MAP D2/D4) are precisely the material the book arc calls
  for — they were sync-pass decisions, not permanent design decisions.
- **The paper's entire motivational architecture (§1–§2 of possible_worlds.tex, ~460 lines)
  is absent**: temporary sentences vs eternalism, perpetuity as touchstone, Prior's
  what/when conflation (chess-loop), Peircean/Ockhamist failure, Montague triviality,
  Kaplan/abundance dilemma — the single largest untapped source for a "well-motivated"
  account, backed by appendix theorems (`app:expressive`, `app:frame-impossible`,
  `app:abundant`).
- **The paper's forward material is exactly the book arc**: restricted modalities (§3.1),
  DF/DN/CO frame lattice + Next/Previous + Vlach store/recall defining BL⋆ (§3.3, lines
  1162–1256), open future with the only worked Vlach use (§4.1), dynamical
  systems/LTL/CTL/HyperLTL positioning (§4.2–4.3).
- **The Lk paper supplies a complete, ready-made decidable-fragments chapter**: the BL⋆
  ladder (undecidable ceiling → four restrictions → LTL floor), complexity map (L₁ ≅ PTL×S5
  EXPSPACE; k≥2 undecidable; ∀-AF-L_k PSPACE-complete flagship), Kamp scoping, hardware case
  study.
- **Two large formalized Lean assets the book never mentions**: `Automation/` (~8,900 lines:
  `tm_auto`, Aesop rules, bounded proof search, the full BMLogic dataset pipeline —
  enumeration → oracle labeling → proof-trace/countermodel JSONL export) and the operational
  decision procedure (`decide`, certificates, countermodel extraction). Plus sorry-free
  `Examples/` and the conservative-extension theorem.
- Full source→chapter mapping table with 24 rows: `01_teammate-a-findings.md` §Evidence.

### Alternative Approaches (Teammate B — counterfactual/Logos dimension + prior art)

- **The counterfactual chapter does not need to be written from scratch — it exists twice**:
  the published paper (`counterfactual_worlds.tex`, 2,277 lines: state lattice, imposition
  *defined*, bilateral propositions, CL ⊂ CML ⊂ CTL, twelve ModelChecker-reproducible
  countermodels, Vlach regimentation of tensed counterfactuals) and the LogosManual Typst
  chapters (`02-constitutive.typ` 1,623 lines, `03-dynamics.typ` 475 lines,
  `07-proof-theory.typ` 127 lines) with `#leansrc` anchors into Logos Lean. The job is
  **adaptation and re-staging** (propositional restriction + repositioning), not new
  mathematics.
- **The conceptual delta is one clean move**: replace primitive `WorldState` by a state
  lattice with parthood; possible/world states become *defined*; □A := ⊤ □→ A makes
  metaphysical modality **derived** (S5 as theorem, not stipulation) — the headline theorem
  of the counterfactual chapter.
- **Prior art gives ready presentation devices**: Gabbay et al. fusion-vs-product framing
  and fragment/decidability lattices; Demri-Goranko-Lange operator-by-operator
  expressiveness ladders; hybrid-logic literature (Vlach 1973, Cresswell 1990, Blackburn ↓/@)
  situating store/recall as bounded-register hybrid binders — which explains decidability
  behavior; Baier-Katoen "checkable artifact" framing matching the dual-verification story.
- **Typst infrastructure: LogosManual's template is a strict superset — port, don't fork**:
  `proposition/corollary/example/notation-env`, `chapter-header` dependency preambles,
  auto-labeled `principles` axiom lists, `leansrc/leanref`, bibliography apparatus (the
  current book has none). Three notation divergences to resolve deliberately; four
  paper-vs-Logos presentation divergences documented (duration-parameterized task relation,
  possible-state definition, propositional vs FOL, U/S basis).

### Gaps and Shortcomings (Teammate C — Critic)

- **The "vanilla LTL + S5 + Vlach" framing misdescribes the formalization**: no Vlach
  operators exist in Lean (`Formula.lean:70–85`: atom/bot/imp/box/untl/snce only); TM is not
  a fusion/product (load-bearing interaction + uniformity axiom layers, past operators, ℤ/ℚ
  time); the PTL×S5 identification belongs to Lk's L₁ over trace sets — a different logic.
- **"Derive metaphysical modality" is on paper only**: □A := ⊤ □→ A with soundness
  (no completeness), formalized nowhere; LogosManual is a 197-line overview; the semantics
  is implemented in ModelChecker (Python), not Lean. Adding constitutive structure is a
  base-level semantic *replacement*, not a conservative chapter-sized extension.
- **The decidability story is weaker than the design assumes**: `validity_decidable` is
  literally `Classical.em` (vacuous); no `Decidable` instance; fuel-based `decide` with
  timeout; tableau soundness proven but semantic completeness runs through the sorry-tainted
  chain. The new chapters must inherit `06-notes.typ`'s existing honesty — decidability is a
  program to *report on*, not a settled asset to *present*.
- **Sorry counts are method-dependent** (38 strict / 43 book-stamped / ~53 loose): any
  hand-copied number is stale at the next commit — script a single-source count.
- **Publication risks are the most likely source of real-world trouble**: Lk is an
  *anonymous TACAS 2027 double-blind submission* (deanonymization risk if sourced publicly);
  possible_worlds is a live JPL submission (self-plagiarism/prior-publication questions);
  Counterfactual Worlds is published (Springer copyright constrains verbatim reuse).
- **Unasked questions**: audience undefined (≥4 candidate audiences with conflicting genre
  expectations); LogosManual single-source-of-truth conflict for the Logos-roadmap content;
  re-sync cadence against a moving Lean target (tasks 303/309–311 in flight).
- **The AI-training contrast has zero source material** (one sentence at
  `00-introduction.typ:12`) — it is newly authored outlook content with a different
  epistemic status, and must be typed and effort-estimated as such.

### Strategic Horizons (Teammate D)

- **The book is the natural spine of ROADMAP.md's Post-Completeness → Publication phase,
  but the roadmap never names it** — add a book/documentation track; engineer the book to
  tolerate roadmap churn.
- **Three roadmap tracks advanced by one part**: the tableau is already implemented
  sorry-free at file level, the dual-signal training pipeline is documented
  (`docs/training/PIPELINE.md` → BimodalHarness), and the dual-verification architecture is
  named in README. A Part on automation simultaneously *specifies* the tableau/fragment
  work, *documents* the dataset program, and *narrates* dual verification.
- **The ceiling-and-descent narrative is already published architecture**: possible_worlds
  §Extensions builds TM → TM⁺/BL⁺ → BL⋆ (Vlach, explicitly out of paper scope); Lk
  self-describes as "hybrid-lite fragment of BL⋆" descending from the undecidable ceiling by
  four verified restrictions. Each operator added buys expressiveness; each restriction buys
  decidability. Adopt the papers' own framing — no new theory, only exposition.
- **Creative additions**: machine-readable JSONL appendix generated from Lean (the book as
  training/eval artifact); dual-track informal+Lean-anchored claim style as house style; an
  "if you are an AI" reader preface; a shaded unification-grid frontispiece (horizontal
  operator axis × vertical world-state-structure axis, TM as first verified cell) as the
  no-rewrite contract for later volumes.

## Synthesis

### Conflicts Resolved

1. **"Vanilla LTL + S5 + Vlach" framing** (C's refutation vs A/D's endorsement). Resolved:
   all three actually converge — the framing is **honest as the published extension roadmap**
   (TM → TM⁺ → BL⋆ tower + Lk descent), **misleading as a description of formalized TM**.
   The book presents TM as "Until/Since temporal logic over linear orders, fused with S5
   plus interaction axioms over task frames", and uses LTL+S5+Vlach as the
   *ceiling-and-descent positioning narrative*, explicitly marked unformalized where it is.
2. **Counterfactual chapter scope** (B's "adaptation job" vs C's "next-volume-sized
   program"). Resolved: both are right at different registers. The *prose* exists and adapts
   cheaply (B's evidence is decisive: the content is already in Typst with theorem
   environments); the *formalization* does not exist in this repo (C is decisive on that).
   Verdict: two bounded chapters (Constitutive Structure; Counterfactual Logic) in the final
   Part, carrying `paper-sourced(published)` / `planned` status markers, cross-linked to
   LogosManual as the owner of the full treatment — sequenced **last** (D's R6), after the
   ownership question (Open Question 3) is settled.
3. **Book architecture** (A's 7-part/18-chapter maximal inventory vs C's minimal 2-part
   split vs D's 4-part monograph). Resolved: adopt **D's part skeleton as the frame, C's
   two-register discipline as the contract, A's mapping table as the content inventory** —
   a five-part shape (below) that places A's motivation chapters and keeps every part
   independently green.
4. **Decidability positioning** (A's "operational asset to surface" vs C's "vacuous headline
   theorems"). Resolved: both true at different layers — the *procedure* (tableau, decide,
   certificates, countermodels) is real, implemented, and worth an operational chapter; the
   *metatheorems* (`validity_decidable`) are currently vacuous and must be reported as open
   program. D's R3 turns this tension into a feature: the chapter's final section is a
   normative status table where every non-✓ row is a candidate roadmap task.

### Consolidated Book Shape (recommendation for the planner)

```
Part I   — Motivation and Positioning                     [sync-class: paper-sourced/outlook]
           Rewritten introduction (arc stated up front; dual-verification framing;
           "how to read this book if you are an AI"); Why Construct Possible Worlds?
           (paper §1–§2 + 2D-appendix theorems); unification-grid frontispiece.
Part II  — The Bimodal Core                               [sync-class: lean-verified]
           Existing ch. 01–06 lightly restructured + Frame Classes & Extensions chapter
           (DF/DN/CO ↔ FrameConditions/, Next/Previous derived, conservative extension)
           + operational Decidability chapter split out of ch. 04.
Part III — Expressive Power and Its Price                 [sync-class: paper-sourced]
           From LTL to TM (honest positioning; trace vs task semantics); Vlach/BL⋆ and
           cross-referencing (+ Kamp formalization frontier status); The Decidability
           Frontier (Lk ladder + complexity map) — EMBARGOED pending Lk publication;
           Open Future + Dynamical Systems/CS positioning (paper §4).
Part IV  — Automated and Neural Reasoning                 [sync-class: lean-verified/outlook]
           Proof Automation (tactics, Aesop, proof search); The BMLogic Dataset Pipeline
           (promote docs/training/PIPELINE.md — move and cite, don't duplicate);
           Dual Verification; Worked Examples (from Examples/).
Part V   — Toward the Logos                               [sync-class: paper-sourced/planned]
           Constitutive Structure (state lattice, imposition defined, worlds derived);
           Counterfactual Logic (CL/CML/CTL, □A := ⊤ □→ A as headline, countermodels
           as examples); cross-linked to LogosManual — sequenced last.
```

### Preconditions (must land before any chapter expansion)

1. **Status-legend extension of SYNC-MAP** — per-chapter `sync-class` header + per-claim
   legend (✓ verified / ⧖ with-sorries / ○ paper-proved-unformalized / ◇ planned); the
   verification pass checks no unstamped Lean claim anywhere and no `lean-verified` label on
   Part III/V chapters.
2. **`typst-sync-check.sh` CI drift detector** (task 312's suggested follow-up) — create as
   a task and dependency of the expansion.
3. **Scripted status counts** — one generator (fixed grep pattern, Boneyard excluded,
   commit-stamped) consumed by both SYNC-MAP and the Typst build; never hand-copy numbers.
4. **Template port from LogosManual** (small, mechanical): theorem environments,
   `chapter-header`, `principles`, `leansrc/leanref`, bibliography.bib, notation
   reconciliation (3 collisions documented by B).

### Gaps Identified (remaining)

- Per-item Lean formalization status for paper-appendix results (A's table rows 13–14) —
  directory-level evidence only; needs per-theorem verification during planning.
- FMP status discrepancy: `Decidability/README.md` says sorry-free incl. `FMP/`;
  `04-metalogic.typ:260` says "in progress" — resolve against `Correctness.lean` before the
  new decidability chapter states either.
- `counterfactual_worlds.tex` was read structurally but not exhaustively; B's staging list
  (9 items in dependency order) is the working outline, to be re-verified at drafting time.
- Prior-art citations (B's F3) are from training knowledge — verify before print.

### Open Questions (need the user before/during planning)

1. **Audience**: Lean users, temporal-logic researchers, AI-training practitioners,
   philosophers — which is primary? Every genre decision downstream depends on this.
2. **Lk embargo policy**: the Lk paper is an anonymous double-blind TACAS 2027 submission.
   Embargo the Decidability Frontier chapter until acceptance, or write it citation-free at
   a higher level of abstraction?
3. **LogosManual ownership split**: which document owns the Logos roadmap and the
   constitutive/counterfactual exposition — BimodalReference (with LogosManual linking) or
   LogosManual (with BimodalReference linking)? One owner; the other links.
4. **Text-reuse policy per paper**: paraphrase-only vs adapted transcription, given JPL
   live submission (possible_worlds) and Springer copyright (counterfactual_worlds).

### Recommendations

1. Deliver this report as the "initial design report" the task names; slice follow-up work
   **per part**, each one agent-run-sized (D's R6): (a) infrastructure preconditions task;
   (b) Part I motivation; (c) Part II core restructure + frame-classes/decidability
   chapters; (d) Part IV automation (mostly promotion of existing docs); (e) Part III
   expressive power (gated on Open Question 2); (f) Part V Logos bridge (last, gated on
   Open Question 3).
2. Ask the four Open Questions at `/plan` time via AskUserQuestion before committing the
   chapter inventory.
3. Add the book as a named track in ROADMAP.md (D's F1) and correct the stale 41/6 counts.
4. Adopt the dual-track claim style and machine-readable appendix (D's R5) — cheap,
   distinctive, on-mission.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary — content gap analysis, source→chapter mapping | completed | high (medium on per-item formalization status) |
| B | Alternatives — counterfactual/Logos sources, prior art, Typst infrastructure | completed | high (medium on prior-art citation details) |
| C | Critic — framing corrections, drift/publication/scope risks | completed | high (medium on copyright implications) |
| D | Horizons — roadmap alignment, ceiling-and-descent narrative, living-monograph shape | completed | high (medium on Logos-side depth) |

## References

- Teammate findings: `specs/313_design_full_extent_bimodalreference_book/reports/01_teammate-{a,b,c,d}-findings.md`
- `Theories/Bimodal/typst/BimodalReference.typ` + chapters 00–06 + `SYNC-MAP.md` (task 312, commit `a883361bf`)
- `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` (3,473 lines)
- `/home/benjamin/Philosophy/Papers/PossibleWorlds/Lk/main.tex` + `sections/*.tex` (anonymous TACAS 2027 submission)
- `/home/benjamin/Philosophy/Papers/Counterfactuals/JPL/counterfactual_worlds.tex` (published, JPL 2025)
- `/home/benjamin/Projects/Logos/Theory/typst/manual/` (LogosManual.typ + chapters 02, 03, 07 + template.typ)
- `Theories/Bimodal/Automation/` (README + 27 files), `Metalogic/Decidability/`, `Examples/`, `Metalogic/ConservativeExtension/`
- `specs/ROADMAP.md`, `docs/training/PIPELINE.md`, `README.md:183–184`
