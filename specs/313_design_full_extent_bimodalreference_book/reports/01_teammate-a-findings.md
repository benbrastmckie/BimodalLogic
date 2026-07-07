# Teammate A Findings: Content Gap Analysis for the BimodalReference Book

**Task**: 313 — Design the full extent of the BimodalReference book
**Teammate**: A (Primary Angle — content gap analysis)
**Date**: 2026-07-06
**Sources examined**:
- `Theories/Bimodal/typst/BimodalReference.typ` + chapters 00–06 + `SYNC-MAP.md` (task 312 state, commit `a883361bf`)
- `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` (3,473 lines, read in full at section level)
- `/home/benjamin/Philosophy/Papers/PossibleWorlds/Lk/main.tex` + `sections/*.tex` (2,792 lines; abstract, intro, syntax/semantics, related-work ladder, conclusion read in depth)
- Lean source survey: `Automation/`, `Examples/`, `Metalogic/{Decidability,ConservativeExtension,WeakCanonical/Kamp}`, `FrameConditions/`, `Theorems/`

---

## Key Findings

### F1. The current book is a synced reference core, not yet a book

The seven current chapters (~1,560 lines of Typst) cover exactly: syntax, task semantics, the
42-constructor BX proof system, metalogic status, a theorem list, and discrepancy notes. Task 312
made this core *accurate* (271 verified Lean names, zero stale references per `SYNC-MAP.md`
Phase 6). What it deliberately excluded (SYNC-MAP "Scope Decisions" D2/D4) is precisely the
material the book arc now calls for:

- Paper's Objective Modality and 2D Semantics appendices — "out of scope (not formalized)"
- Paper §3.3 Extensions — one-line "not yet formalized" note only
- `Automation/` and `Examples/` — "not documented"
- Frame-class chapter — "deferred"

Task 312's scope calls were sync-pass decisions, not permanent design decisions. The full-extent
book must reverse most of them — but see F8 on how to do that without destroying the sync
discipline that task 312 just established.

### F2. The paper's entire motivational architecture (§1–§2) is absent

`possible_worlds.tex` §1 (Introduction, lines 413–490) and §2 (Primitive Worlds, lines 494–874)
contain the philosophical case for the system: why temporary sentences defeat eternalism, why
perpetuity (P1/P2) is the touchstone for a bimodal semantics, why Prior's world states conflate
the *what* with the *when* (chess-loop argument, lines 584–590), why Peircean semantics fails
(Black/White both "going to win", lines 617–624), why Montague's ⊠ trivializes perpetuity
(Triviality argument, lines 726–736), and why Kaplan-style two-dimensionalism forces the
abundance/temporal-absolutism dilemma (lines 767–874, backed by `app:frame-impossible` and
`app:abundant`). The book's current introduction is 92 lines with one diagram. None of this
motivation survives into it. For a "well-motivated, well-explained account", §1–§2 are the
single largest untapped source.

### F3. The paper's forward-looking material (§3.1 Restricted Modalities, §3.3 Extensions, §4) is absent — and it is exactly the book arc

The intended arc (LTL-adjacent core → S5 → Vlach cross-referencing → decidable fragments →
Logos) is already laid out inside the paper, but none of it is in the book:

- **Restricted modalities** (lines 1007–1073): stability ⟨τ⟩ₓ, Will/Could operators, open
  futures |τ⟩ₓ / open pasts ⟨τ|ₓ, four-place task relation and nomological necessity □ₙ. These
  show the payoff of *constructed* worlds: accessibility relations become definable, not
  primitive (lines 1052–1060).
- **Extensions** (lines 1162–1256): DF/DN/CO axioms with frame correspondence
  (`app:discrete`/`app:dense`/`app:complete`), the TM_f/TM_d/TM_c/TM_dc lattice, Next/Previous
  (X φ := ⊥ U φ — definable in the Lean Until/Since basis today but undocumented), metric tense
  note, and the **Vlach store/recall operators** ⟨store/recall for times and worlds, lines
  1246–1256⟩ defining BL⋆. BL⋆ appears nowhere in the book, yet it is the declared bridge to the
  Lk paper ("hybrid-lite fragment of BL⋆", `Lk/sections/01-intro.tex:18–26`).
- **Open future** (§4.1, lines 1291–1409): sea-battle analysis, the `Determined` schema and
  `Deterministic` frame constraint (`app:deterministic`, `app:deterministic-future`), the (Sea)
  and (Det) formulas — the paper's only *worked use* of the Vlach operators — and the
  actuality-operator discussion (@, #, and why neither is posited).
- **Dynamical systems and CS positioning** (§4.2–4.3, lines 1412–1541): NDS/LTS equivalence,
  Williamson's deterministic semantics as a limiting case, shifts of finite type, the
  LTL/CTL/CTL* triangulation ("individual worlds are linear as in LTL; the set of worlds through
  a state branches as in CTL; □ is unrestricted rather than path-quantified"), and the HyperLTL
  contrast (decidability of TM vs undecidability of HyperLTL, lines 1527–1533) — the exact
  passage the Lk paper names as its origin (`Lk/sections/01-intro.tex:27–37`).

### F4. The Lk paper supplies a complete, ready-made "decidable fragments" chapter

`Lk/main.tex` ("Rebinding the Trace: Decidable Modal Logics for Synchronous Hyperproperties")
is the concrete realization of arc point (1) — carving decidable fragments for fully automated
reasoning:

- The **BL⋆ ladder** (`07-related-work.tex:32–104`, Table `tab:bl-star-ladder`): from the
  undecidable BL⋆ ceiling down to the LTL floor via four verified restrictions (store fused to
  □, recall confined to atoms, clock-anchoring, diamond-freedom). This one table *is* the
  book-arc narrative in compressed form.
- The **complexity map**: L1 = PTL×S5 EXPSPACE-complete floor; L_k satisfiability undecidable
  for k ≥ 2; the surprise that alternation-freedom does NOT restore decidability (Minsky
  encoding, Theorem F-B); the PSPACE-complete diamond-free flagship ∀-AF-L_k (Theorem F-A)
  covering the whole hardware case study (`01-intro.tex:69–80`).
- **Kamp's theorem, correctly scoped** (`02-syntax-semantics.tex:270–293`): strict vs non-strict
  Until, Dedekind-complete flows, GPSS future-only adequacy — this directly complements the
  book's strict-semantics design-choice discussion (`06-notes.typ` §Design Choices) and the
  in-progress Kamp formalization (`Metalogic/WeakCanonical/Kamp/`, tasks 303/309–311).
- **Case study** (`06-case-study.tex`): constant-time as ∀∀, reset convergence as non-prenex,
  SVA/Logos-Hardware bridge — application material the book currently has zero of.
- Caveat: the Lk paper is an anonymized conference submission ("Extended version to appear",
  `main.tex:22–24`); book citations must mark results as unpublished/under review, and none are
  Lean-formalized (its own conclusion names Lean 4 formalization as future work,
  `08-conclusion.tex:56–59`).

### F5. The Lean codebase has two large formalized assets the book never mentions

- **`Automation/` (≈8,900 lines across 27 files + 2 subdirs)**: proof tactics (`tm_auto`,
  `apply_axiom`, `modal_t`, Aesop `TMLogic` rule set — `Automation/Tactics/Commands.lean`,
  `AesopRules.lean`), a bounded proof-search engine (`ProofSearch/Core.lean`, 1,018 lines), and
  a complete **ML dataset pipeline** — `FormulaEnumerator.lean` (1,091 lines), depth-bounded
  enumeration → `DatasetGenerator` (runs `decide`, extracts proof traces) → validator →
  JSONL export, plus `BenchmarkOracle`, `BenchmarkAnchors` (ground-truth valid/invalid pairs),
  `ProofStepExtractor/Export` (derivation-tree steps to JSONL), `EnrichedCountermodel` (negative
  examples), and EF-game tactics. The `Automation/README.md` names the product: "the BMLogic
  benchmark datasets". This is the *only* place in the entire project where arc point (1)'s
  "training AI systems to reason proof-theoretically... deterministically checkable and fast"
  is already implemented — and the book's introduction gestures at it in one sentence
  (`00-introduction.typ:12`) then never returns.
- **`Metalogic/Decidability/` in operational detail**: `decide`, `isValid`, `isSatisfiable`,
  `DecisionResult`, proof extraction, countermodel extraction, `TraceCertificate`/`TraceExport`.
  The book's ch. 4 describes the tableau abstractly; it never presents the decision procedure as
  a usable artifact (entry points, fuel semantics, certificate format), which is what the
  "fast, deterministically checkable" arc framing needs.

Secondary unsurfaced Lean assets: `Examples/` (sorry-free `BimodalProofs.lean`,
`TemporalStructures.lean` — concrete dense/discrete instantiations), the conservative-extension
theorem infrastructure (`Metalogic/ConservativeExtension/` — book cites the directory but never
states the theorem the paper calls `thm:ConservativeExtension`), the Kamp/expressiveness tree
(`WeakCanonical/{Kamp,EFGames,ExpressiveCompleteness,MonadicFO,RabinovichTranslation,
StaviConnectives}` — one-line WIP note only), and `FrameConditions/` (deferred per D2).

### F6. The paper's appendix contains formal results with no book counterpart

Beyond §§ already mirrored (Task Semantics/Soundness/Proof Theory → book ch. 2–4):

| Appendix block | Result | Book status |
|---|---|---|
| `app:ObjectiveModality` (lines 1563–1741) | □ as strongest objective normal modality: uniqueness (`lem:uniq`), S4 derivation (`thm:s4`), existence under coarse-grained identity (`cor:exists`) | absent (D4 exclusion); not Lean-formalized |
| `app:TwoDimensional` (lines 1742–2255) | BLK strictly more expressive than BLM (`app:expressive`, bisimulation proof); perpetuity invalid for Kaplan (`app:invalid`); **no frame constraint can validate perpetuity** (`app:frame-impossible`); abundance suffices (`app:abundant`); unboundedness (`app:unbounded`) | absent; not Lean-formalized |
| `app:TaskSemantics` correspondence | DF/DN/CO frame-correspondence theorems (`app:discrete`, `app:dense`, `app:complete`); deterministic frames (`app:deterministic`, `app:deterministic-future`); task-topology R0/non-discreteness (`app:topology-r0`, `app:topology-nondiscrete`) | absent; partially Lean-formalized (`FrameConditions/`) — needs per-result status check |
| `app:ProofTheory` extras | `thm:BLplus-NextPrevious` (Next/Previous from strict Until); conservative extension `thm:ConservativeExtension`; `cor:tm-decidability`; derived theorems Pthm:11–22 (incl. operator-commutation Pthm:21/22 for out-of-domain evaluation) | mostly absent; several ARE Lean-formalized (ConservativeExtension/, Decidability/, Theorems/) |

### F7. Counterfactual chapter (arc point 4) — sources verified to exist

`/home/benjamin/Philosophy/Papers/Counterfactuals/JPL/counterfactual_worlds.tex` (2,277 lines)
and `/home/benjamin/Projects/Logos/Theory/typst/manual/LogosManual.typ` (197-line master file)
both exist. The parent paper already plants the hook twice: "I present a hyperintensional task
semantics in [Brast-McKie 2025], defining world states as maximal possible states"
(`possible_worlds.tex:483` fn., `:883` fn., `:965` fn. — counterfactuals named explicitly at
`:965`). The natural book move is a closing roadmap chapter, not a full treatment: world states
cease to be primitive, constitutive (parthood) structure yields the counterfactual semantics,
and metaphysical modality becomes derived — with the Logos as the umbrella program (arc
point 3). Deep gap analysis of these two sources belongs to a follow-up pass; the present point
is that the *slot* and the *hooks* are already in the parent paper.

### F8. Challenge — the sync discipline must be protected, not diluted

Task 312's central achievement is an enforceable invariant: every backticked Lean name in the
book resolves in live source (`SYNC-MAP.md` Phase 6, 271 names). Most of the content identified
above is **not formalized** (Vlach operators, restricted modalities, objective modality, all Lk
results, 2D expressiveness results). Pouring it into the existing chapters would produce a book
in which the reader can no longer tell verified claims from narrative, and would make the next
sync pass unmanageable. Recommendation: a **two-register design** —

1. *Lean-grounded chapters* keep the SYNC-MAP contract (every formal claim carries a Lean
   anchor and the sorry-status convention already used in ch. 4).
2. *Narrative/roadmap chapters* (motivation, open future, Lk fragments, counterfactual outlook)
   carry an explicit per-chapter status banner: "presents results from [source]; not formalized
   in this repository" — mirroring how `04-metalogic.typ` already handles in-progress work
   ("should not be cited as a settled result").

A secondary challenge: the current title page names one "Primary Reference"
(`BimodalReference.typ:97–99`). A book of the planned extent has three source pillars (parent
paper, Lk paper, counterfactuals paper) plus the Lean repository as ground truth; the front
matter should say so.

---

## Recommended Approach

Proposed full-extent structure (existing chapters in parentheses; ★ = new; register R1 =
Lean-synced, R2 = narrative/not-formalized):

**Part I — Motivation**
1. ★ Introduction, rewritten (absorbs current `00-introduction.typ`): the book arc stated up
   front — decidable-fragment program vs proof-theoretic RL training (R2, citing `Automation/`
   for the implemented half); TM as vanilla-LTL-adjacent, then + S5, then + Vlach (R2).
2. ★ Why Construct Possible Worlds? (R2): paper §1–§2 — temporary sentences, perpetuity as
   touchstone, Prior's conflation, Peircean/Ockhamist, Montague triviality, Kaplan/abundance
   dilemma, simulation metasemantics. Backed by appendix results `app:expressive`,
   `app:frame-impossible`, `app:abundant` stated as theorems-with-citations.

**Part II — The System TM (R1, current core preserved)**
3. Syntax (current `01-syntax.typ`).
4. Task Semantics (current `02-semantics.typ` + ★ possible-worlds-as-equivalence-classes
   construction from paper lines 921–939, + ★ moment/duration distinction).
5. Proof Theory (current `03-proof-theory.typ`).
6. ★ Frame Classes and Extensions (promotes D2's deferred chapter; R1/R2 mixed): DF/DN/CO
   correspondence (`app:discrete/dense/complete` ↔ `FrameConditions/`), TM_c/TM_dc as
   not-yet-formalized (R2), Next/Previous as derived (R1 — definable today), conservative
   extension theorem stated (R1, `Metalogic/ConservativeExtension/`).

**Part III — Metalogic (R1)**
7. Soundness & Completeness (current `04-metalogic.typ` §§1–3).
8. ★ Decidability and the Decision Procedure (splits out of ch. 4; expanded to the operational
   level: `decide`, certificates, countermodels, FMP status, complexity).

**Part IV — Theorems and Applications**
9. Theorems (current `05-theorems.typ` + ★ Pthm:11–22 inventory where formalized).
10. ★ The Open Future (R2): paper §4.1 — sea battle, Determined/Deterministic
    (`app:deterministic`), actuality, the (Sea)/(Det) formulas as first Vlach use.
11. ★ Dynamical Systems and Computation (R2): paper §4.2–4.3 — NDS/LTS, shifts of finite type,
    LTL/CTL/HyperLTL positioning, STIT/transition-semantics comparisons.

**Part V — Expressive Power and Decidable Fragments**
12. ★ Cross-Referencing Times and Worlds (R2 with R1 hooks): Vlach store/recall, BL⋆, and the
    Kamp expressiveness program (Kamp correctly scoped per `Lk 02:270–293`; live Lean status of
    `WeakCanonical/Kamp/` as the formalization frontier).
13. ★ Decidable Fragments: the L_k Hierarchy (R2): the BL⋆ ladder, complexity map (T1–T4,
    Theorems F-A/F-B), L1 axiomatization via quasimodels, hardware case study; honest
    unpublished-status marking.

**Part VI — Automation and AI (R1)**
14. ★ Proof Automation: `tm_auto`/`apply_axiom`/Aesop rules, bounded proof search.
15. ★ The BMLogic Dataset Pipeline: enumeration → oracle labeling → proof-step/countermodel
    export; the RL-signal thesis made concrete.
16. ★ Worked Examples (from `Examples/`, sorry-free).

**Part VII — Outlook**
17. ★ Toward Counterfactual Worlds (R2): constitutive structure, tensed counterfactuals,
    derived metaphysical modality; Logos roadmap (arc points 3–4).
18. Notes (current `06-notes.typ`, absorbing per-chapter discrepancy notes).

Sequencing suggestion: Parts I, V, VI first (highest arc value, fully sourced today); Part IV
ch. 10–11 second; Part VII last (depends on a dedicated gap analysis of the counterfactuals
paper).

---

## Evidence / Examples (source → chapter mapping table)

| # | Source location | What it offers | Target chapter (above) | Formalized? |
|---|---|---|---|---|
| 1 | `possible_worlds.tex:413–490` (§1) | Temporary vs permanent sentences; eternalism critique; P1/P2 motivation; Alvin example; objective modality, Transparency; nomological □ₙ | Ch. 2 | no |
| 2 | `possible_worlds.tex:557–671` (§2.1) | Prior/Kripke/Carnap history; Diodorean; Peircean vs Ockhamist clauses + stability Ⓞ; chess-loop recurrence argument; what/when conflation | Ch. 2 | no |
| 3 | `possible_worlds.tex:675–761` (§2.2) | Montague ⊠, universal □, Triviality argument; Dorr–Goodman/Fine converse definition | Ch. 2 | no |
| 4 | `possible_worlds.tex:767–874` (§2.3) | Time-shift, Abundance, temporal absolutism; simulation vs realist vs instrumentalist metasemantics | Ch. 2 | no |
| 5 | `possible_worlds.tex:879–1004` (§3) | Worlds as equivalence classes [τ]; moments as ⟨τ,x⟩ pairs; chess (K)/(P) example; P1 validity sketch via time-shift | Ch. 4 | yes (histories, time-shift: `Semantics/WorldHistory.lean`, `Truth.lean`); classes construction itself not in Lean |
| 6 | `possible_worlds.tex:1007–1073` (§3.1) | Stability ⟨τ⟩ₓ; Will/Could; open futures/pasts; 4-place task relation, □ₙ; definability-vs-primitive-accessibility argument | Ch. 10 + Ch. 6 | no |
| 7 | `possible_worlds.tex:1079–1156` (§3.2) | TM 12-schema presentation; P1–P6 derivations in prose | already in Ch. 5/9 (`03-proof-theory.typ:325+`, `05-theorems.typ`) | yes |
| 8 | `possible_worlds.tex:1162–1256` (§3.3) | DF/DN/CO + TM_f/d/c/dc lattice; Next/Previous; Until/Since; **Vlach store/recall, BL⋆** (lines 1246–1256) | Ch. 6 (extensions), Ch. 12 (Vlach) | partially (Dense/Discrete classes yes; TM_c/TM_dc no; X/Y definable; Vlach no) |
| 9 | `possible_worlds.tex:1291–1409` (§4.1) | Open future; Determined schema; (Sea)/(Det); @/# discussion; paradox resolution | Ch. 10 | no |
| 10 | `possible_worlds.tex:1412–1541` (§4.2–4.3) | NDS/LTS; Williamson deterministic semantics; shifts of finite type; coalgebra/groupoid footnotes; LTL/CTL/CTL*/HyperLTL positioning; STIT/Rumberg–Zanardo | Ch. 11 | no |
| 11 | `possible_worlds.tex` app. lines ~1563–1741 | Strongest-objective-modality theorems (`lem:uniq`, `thm:s4`, `cor:exists`) | Ch. 2 (or appendix) | no |
| 12 | `possible_worlds.tex` app. ~1742–2255 | `app:expressive`, `app:invalid`, `app:frame-impossible`, `app:abundant`, `app:unbounded` | Ch. 2 backbone | no |
| 13 | `possible_worlds.tex` app. (TaskSemantics) | `app:discrete/dense/complete` correspondence; `app:deterministic(-future)`; `app:topology-r0/nondiscrete` | Ch. 6, Ch. 10, Ch. 11 | partially (`FrameConditions/`) |
| 14 | `possible_worlds.tex` app. (ProofTheory) | `thm:BLplus-NextPrevious`; `thm:ConservativeExtension`; `cor:tm-decidability`; Pthm:11–22 | Ch. 6, Ch. 8, Ch. 9 | largely yes (`ConservativeExtension/`, `Decidability/`, `Theorems/`) — per-item check needed |
| 15 | `Lk/sections/01-intro.tex`, `07-related-work.tex:3–104` | BL⋆-as-ceiling; four restrictions; the ladder table | Ch. 13 (+ Ch. 12 bridge) | no |
| 16 | `Lk/sections/02-syntax-semantics.tex` | L_k grammar/semantics; basic validity bundle; L0 = LTL conservativity; Kamp correctly scoped (`:270–293`) | Ch. 13; Kamp scoping also Ch. 12 and `06-notes` design-choice section | no |
| 17 | `Lk/sections/04*.tex`, `05-axiomatization.tex` | Complexity map T1–T4; Theorems F-A/F-B; AxL1 quasimodel completeness; L2 non-axiomatizability | Ch. 13 | no |
| 18 | `Lk/sections/06-case-study.tex` | Constant-time ∀∀; reset convergence (non-prenex); SVA/Logos-Hardware bridge | Ch. 13 | no |
| 19 | `Theories/Bimodal/Automation/` (README + 27 files, e.g. `FormulaEnumerator.lean` 1091 ln, `Tactics/Commands.lean` 431 ln, `ProofSearch/Core.lean` 1018 ln) | Tactics, Aesop rules, proof search, BMLogic dataset pipeline, benchmark oracle, proof-step JSONL export | Ch. 14–15 | **yes** (unsurfaced) |
| 20 | `Theories/Bimodal/Examples/` | Sorry-free worked derivations; concrete dense/discrete structures | Ch. 16 | **yes** (unsurfaced) |
| 21 | `Theories/Bimodal/Metalogic/Decidability/` (`DecisionProcedure.lean`, `TraceCertificate.lean`, `CountermodelExtraction.lean`) | Operational decision procedure: entry points, certificates, countermodels | Ch. 8 | **yes** (under-surfaced) |
| 22 | `Theories/Bimodal/Metalogic/WeakCanonical/{Kamp,EFGames,ExpressiveCompleteness,MonadicFO,...}` | Kamp-theorem formalization frontier (tasks 303/309–311) | Ch. 12 | in progress (24 sorries per SYNC-MAP) |
| 23 | `Theories/Bimodal/Metalogic/ConservativeExtension/` | TM ⊂ TM⁺ conservativity infrastructure | Ch. 6 | yes (0 sorries per SYNC-MAP) |
| 24 | `counterfactual_worlds.tex` (2,277 ln) + `LogosManual.typ`; hooks at `possible_worlds.tex:483,883,965` | Constitutive structure → tensed counterfactuals → derived metaphysical modality | Ch. 17 | no (separate gap analysis recommended) |

**Flag for verification during implementation**: `Metalogic/Decidability/README.md` marks all
modules including `FMP/` "Sorry-free", while `04-metalogic.typ:260` lists "Tableau FMP — In
progress". SYNC-MAP's count (0 sorries in `Decidability/`) supports the README; the chapter's
"in progress" wording may reflect an unwired completeness direction rather than sorries. Resolve
against `Correctness.lean` (`fmp_completeness`) before the new Ch. 8 states either.

---

## Confidence Level

**High** for: the inventory of what the current book contains (all seven chapters read in
full); the paper §1–§4 gap list (read at full text level, line citations verified); the Lean
`Automation/`/`Examples/`/`Decidability/` gaps (directories listed, READMEs read); the
BL⋆ → Lk bridge (both ends read in the sources).

**Medium** for: per-item formalization status in table rows 13–14 (directory-level evidence
only; individual theorem names not verified against Lean declarations); the FMP status flag;
the proposed 18-chapter partitioning (a design judgment other teammates should stress-test).

**Low** for: row 24 depth (counterfactuals paper existence and hooks verified, content not yet
analyzed).
