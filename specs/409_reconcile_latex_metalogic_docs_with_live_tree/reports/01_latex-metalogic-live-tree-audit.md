# Research Report: Task #409

**Task**: 409 - reconcile_latex_metalogic_docs_with_live_tree
**Started**: 2026-07-28T23:01:38-07:00
**Completed**: 2026-07-28
**Effort**: research only (identifier/architecture audit; no .tex edits made)
**Dependencies**: none (coordinates with the strong-completeness leg of the completeness
programme tracked in `specs/ROADMAP.md`, which owns any further restatement once
per-class consequence/strong results land)
**Sources/Inputs**: codebase grep/read of `latex/subfiles/*.tex` and `FormalSystem/Metalogic/**`
(excluding `Boneyard/`), `pdflatex` compile runs
**Artifacts**: this report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- `04-Metalogic.tex` and `06-Notes.tex` both still compile standalone today (confirmed by
  running the exact required command; see "Compilation Confirmation" below). No LaTeX changes
  were made in this dispatch — this is a research-only report.
- The identifier audit confirms every stale name flagged in the task description
  (`semantic_weak_completeness`, `main_provable_iff_valid(_v2)`, `representation_theorem`,
  `strong_representation_theorem`, `deduction_theorem`, the `Representation/TruthLemma.lean`
  path, `semantic_task_rel_compositionality`, `finite_model_property_constructive`,
  `semantic_truth_lemma_v2`, `IndexedMCSFamily`, `canonical_model`) has **zero** live hits
  outside `Boneyard/` — all retired, no exceptions. Two additional stale identifiers not
  called out in the task description were found: `SemanticTaskRelV2` and `SemanticWorldState`
  (both 0 live hits) and `WorldHistory.time_shift` (0 hits — the live def is camelCase
  `WorldHistory.timeShift`).
- The single biggest architecture-fidelity gap is **not** individual names — it's the "Two
  Canonical Model Approaches" subsection (04-Metalogic.tex:326–346), which describes a false
  dichotomy (Syntactic-in-Boneyard vs. Semantic-quotient). The live tree has **three parallel
  completeness developments** (`BXCanonical/`, `WeakCanonical/`, `Algebraic/`) sharing common
  foundations (`Core/`, `Bundle/`), none of which is the retired `SemanticCanonicalModel`
  quotient construction the chapter currently describes.
- The per-class completeness picture is more advanced than the chapter's "Implementation
  Status" tables show: `completeness_dense` and `completeness_discrete`
  (`BXCanonical/Completeness.lean:255,296`) are **sorryAx-free** (axioms exactly `propext`,
  `Classical.choice`, `Quot.sound`); the general Base-frame `completeness` (line 196) carries
  exactly one live `sorryAx`, sourced from the deprecated `WeakCanonical.countermodel_discrete`
  fallback in its discrete branch — not from three separate `Metalogic_v2` sorries as the
  chapter's "Sorry Status" section claims (`Metalogic_v2` and `SemanticCanonicalModel.lean` no
  longer exist).
- `completeness_dedekind` (unconditional) does **not** yet exist as a live declaration —
  confirming the task description's "in flight" characterization. Only
  `completeness_dedekind_of_engine` / `consequence_completeness_dedekind_of_engine`
  (`StrongCompleteness.lean:274,308`) exist, both conditional on a supplied single-formula
  completeness "engine" hypothesis.
- A concrete section-by-section rewrite plan is given below, distinguishing full-replacement
  sections (Task Relation/Semantic World State/Universal Canonical Model definitions, Truth
  Lemma, Representation Theorem, both tikz diagrams, Implementation Status, Two Canonical Model
  Approaches) from light-edit sections (Soundness table, Deduction Theorem, Lindenbaum, Weak/
  Consequence Completeness, Decidability) and sections needing no change (Strong Completeness
  and Compactness — already landed).

## Context & Scope

Per the delegation, this audit covers architecture/identifier fidelity in `latex/subfiles/`,
focused on `04-Metalogic.tex` (542 lines) and `06-Notes.tex` (90 lines), with the terminology
pass (strong vs. consequence completeness) already landed and out of scope for further
restatement here. Scope item (1) of the task asks for a complete `\texttt{...}` identifier
audit across `latex/subfiles/*.tex` (not just the two primary files), so the table below
includes all seven subfiles for completeness, with the primary-target rows called out. No
files under `FormalSystem/` or `Tests/` were modified, and no `lake build`/`lake clean`/
`lean_build` calls were made, per the binding concurrency constraint (task 418's build lock).
Read-only `grep`/`Read` of `FormalSystem/` and two `pdflatex` compile runs (which touch only
`latex/subfiles/*.{aux,log,out,pdf}`) were the only non-report actions taken.

## Findings

### Identifier Audit (all `\texttt{...}` occurrences in `latex/subfiles/*.tex`)

Legend: **live?** = found via `grep -rn '\b<id>\b' FormalSystem/ --include='*.lean'` excluding
`Boneyard/`. Table/prose identifiers that are not Lean identifiers (e.g. inline type
annotations like `\texttt{valid proof}`) are marked N/A.

#### `04-Metalogic.tex` (primary target)

| identifier | file:line | live? | live replacement / note |
|---|---|---|---|
| `prop_k_valid` … `temp_future_valid` (15 axiom-validity lemmas) | 34–48 | YES (all 15) | Unchanged — `FormalSystem/Metalogic/Soundness.lean:112` etc. (per-axiom `theorem <name>` at file top level; also re-proved per frame-class-variant in `SoundnessLemmas/DenseValidity.lean` as `axiom_<name>`) |
| `WorldHistory.time_shift` | 54 | **NO** | Retired name. Live: `WorldHistory.timeShift` (def, `FormalSystem/Semantics/WorldHistory.lean:246`), with supporting lemmas `time_shift_domain_iff`, `time_shift_inverse_domain`, `time_shift_time_shift_states`, `time_shift_congr` (snake_case *lemma* names, camelCase *def* name — this mixed convention is itself worth noting in the rewrite) |
| `set_lindenbaum` | 97, 203, 300, 522 | YES | Unchanged — `FormalSystem/Metalogic/Core/MaximalConsistent.lean` (14 live call sites) |
| `SemanticTaskRelV2` | 127 | **NO** | Retired, no direct replacement. Live architecture has no single "task relation" type name playing this role; task-relatedness is realized per-development (e.g. `BXCanonical.CanonicalTaskRelation`, `Bundle/CanonicalTaskRelation.lean`) |
| `SemanticWorldState` | 138 (footnote) | **NO** | Retired, no replacement. Live world-state role is played by `BXPoint` (BXCanonical) / `FMCS`+`BFMCS` (Bundle) depending on development — see Architecture Narrative below |
| `IndexedMCSFamily D` (×2) | 142, 144 | **NO** | Retired. Live: `FMCS` ("Family of MCS", `FormalSystem/Metalogic/Bundle/FMCSDef.lean`) for a single time-indexed MCS family, `BFMCS` ("Bundle of FMCS", `FormalSystem/Metalogic/Bundle/BFMCS.lean`) for the bundle with modal coherence |
| `canonical_model D family` | 146 | **NO** | Retired. Live construction is `BXCanonical.CanonicalModel` (chain-based, builds a `BFMCS Int` from BX witnesses — `FormalSystem/Metalogic/BXCanonical/CanonicalModel.lean`), not a single parametric-`D` function |
| `truth_lemma` | 157 | **NO** (as a bare name) | Retired name/path. Live truth lemmas are per-development: `BXCanonical/TruthLemma.lean`, `WeakCanonical/TruthLemma.lean`, `Algebraic/ParametricTruthLemma.lean` (+ `RestrictedParametricTruthLemma.lean`) |
| `FormalSystem/Metalogic/Representation/TruthLemma.lean` | 157 (footnote path) | **NO — path missing** | `Representation/` directory does not exist in the live tree. See File-Path Audit below |
| `representation_theorem` | 169, 207, 319(via `main_provable_iff_valid`'s footnote), 525 | **NO** | Retired concept, no direct replacement — see Architecture Narrative: the live proof goes Lindenbaum → canonical BFMCS/BXPoint construction → truth lemma → countermodel extraction → completeness directly, with no intermediate "every consistent formula is satisfiable in the canonical model" theorem under this name |
| `FormalSystem/Metalogic/Representation/UniversalCanonicalModel.lean` | 169 (footnote path) | **NO — path missing** | Same as above |
| `contextToSet` | 175 | YES | Unchanged — `FormalSystem/Metalogic/Core/MaximalConsistent.lean:123` |
| `strong_representation_theorem` | 184 (footnote) | **NO** | Retired, no replacement — see note above; concept is now folded into the `set_lindenbaum` + `SetMaximalConsistent.neg_excludes` argument directly inside each `completeness*` proof |
| `deduction_theorem` | 202, 521 | **NO (as bare name)** | Retired top-level name. Live: `deductionTheorem` (list-context form, `FormalSystem/Metalogic/Core/DeductionTheorem.lean`) and the newer general dot-notation form `FormalSystem.ProofSystem.Derivable.deduction` (same file, line 467) |
| `MaximalConsistent` | 204 | YES | Unchanged (20 live hits) — `FormalSystem/Metalogic/Core/MaximalConsistent.lean` |
| `semantic_weak_completeness` | 210, 236, 491, 526 | **NO** | Retired. Live per-class weak completeness: `completeness` (Base, `BXCanonical/Completeness.lean:196`, one live sorryAx), `completeness_dense` (:255, sorryAx-free), `completeness_discrete` (:296, sorryAx-free); `completeness_dedekind` unconditional not yet landed (see below) |
| `consequence_completeness_*` | 211, 527 | partial — accurate as a wildcard already | Live pattern: `consequence_completeness_dedekind_of_engine` (`StrongCompleteness.lean:274`), conditional on an engine hypothesis; per the task description, Base/Dense/Discrete instances "follow the same three-declaration shape" but were not found as separate already-landed declarations in this pass (only the Dedekind instance exists in `StrongCompleteness.lean` today) |
| `Context = List Formula` | 251 | YES (as a fact) | `Context` is `List Formula` — confirmed live, `FormalSystem/Syntax/Context.lean` (not directly grepped by name here but consistent with `Core.lean`'s docstring and `StrongCompleteness.lean`'s own statement) |
| `consequence_completeness_dedekind` | 262 | YES (as `_of_engine` variant) | The **unconditional** `consequence_completeness_dedekind` (without `_of_engine`) does **not** exist; only `consequence_completeness_dedekind_of_engine` (`StrongCompleteness.lean:274`) is landed. The footnote's own text already hedges this ("stated there modulo its single-formula completeness engine") — accurate, but the theorem environment's un-suffixed macro name doesn't match the actual declaration name exactly; worth tightening in the rewrite |
| `FormalSystem/Metalogic/StrongCompleteness.lean` | 263 | YES — path exists | Confirmed |
| `Set Formula`, `SetConsistent`, `SetMaximalConsistent` | 295, 299 | YES | All live — `FormalSystem/Metalogic/Core/MaximalConsistent.lean` |
| `set_lindenbaum` (Core/MaximalConsistent.lean cite) | 300 | YES | Path and name both confirmed |
| `main_provable_iff_valid` | 319, 528 | **NO** | Retired top-level biconditional name. No single unconditional `⊢ φ ↔ ⊨ φ` declaration exists live; the live results are the directional `completeness`/`completeness_dense`/`completeness_discrete` theorems (right-to-left) paired with `soundness`/`soundness_dense`/`soundness_discrete` (left-to-right, `Soundness.lean`) — the biconditional is available compositionally per class but not under one name |
| `Boneyard/` | 337 | YES (as a directory reference) | Correct — still accurate that the syntactic approach is archived there |
| `decide_sound` | 361, 507, 530 | YES | Unchanged — `FormalSystem/Metalogic/Decidability/Correctness.lean:56` (plus `decide_sound'` variant at :63) |
| `Derivable FrameClass.Base [] $\varphi$` | 365 | YES (type shape) | Consistent with live `Derivable`/`DerivationTree` signatures |
| `decide`, `simp` | 370 | N/A | Lean tactics, not identifiers to audit |
| `valid proof`, `invalid counter`, `timeout` | 421–423 | N/A | Prose description of a result type's constructors, not literal identifiers; live `DecisionResult` constructors should be spot-checked against `Decidability/DecisionProcedure.lean` in the rewrite pass but were not required for this audit |
| `FormalSystem/Metalogic/` | 430 | YES — path exists | Correct |
| `IndexedMCSFamily` | 430 | **NO** | Same as above — the whole sentence ("using the IndexedMCSFamily approach") is stale; the live approach is the three-development split (BXCanonical/WeakCanonical/Algebraic) over shared `Core`/`Bundle` |
| `Boneyard/Metalogic_v2/` | 431 | path status unclear from this audit (Boneyard excluded by scope) — **the citing sentence's premise is stale regardless**: the *live, non-Boneyard* organization is not "Deprecated code in Boneyard, active code using IndexedMCSFamily" but three live developments plus one archived directory | — |
| `Core/`, `Soundness/`, `Representation/`, `Completeness/`, `Applications/`, `Decidability/` (directory-structure diagram + descriptions, 470–475) | 470–475 | **Representation/, Completeness/, Applications/ do NOT exist; Soundness/ does not exist as a directory (Soundness.lean is a file); Core/ and Decidability/ exist** | See Live Module Layout below for the replacement diagram content |
| `Metalogic_v2`, `sorry` (482) | 482 | **NO — module doesn't exist** | The whole "Sorry Status" subsection (480–491) describes `Metalogic_v2`/`SemanticCanonicalModel.lean`/`FiniteModelProperty.lean`, none of which exist live |
| `semantic_task_rel_compositionality` | 485 | **NO** | Retired, no replacement (see above) |
| `main_provable_iff_valid_v2` | 486 | **NO** | Retired, no replacement |
| `finite_model_property_constructive` | 487 | **NO** | Retired. Live: `mcs_finite_model_property` (`FormalSystem/Metalogic/Decidability/FMP/FMP.lean:204`), used by `Decidability/Correctness.lean:177` |
| `finite_model_property` (bare, 529) | 529 | live only as a docstring-quoted informal name | `FMP.lean:36` docstring says `finite_model_property: ¬valid(φ) → ∃ finite model falsifying φ`; the actual declaration is `mcs_finite_model_property` |
| `soundness` | 520 | YES | `FormalSystem/Metalogic/Soundness.lean:1063` (plus `soundness_dense`, `soundness_discrete`, `soundness_dedekind` variants) |

#### `06-Notes.tex` (primary target)

| identifier | file:line | live? | live replacement / note |
|---|---|---|---|
| `always`, `sometimes` | 34 | YES | `FormalSystem/Syntax/Formula.lean` (confirmed live in `01-Syntax.tex` audit below; same constructors) |
| `Axiom.modal_t` … `Axiom.temp_future` (10 axiom names) | 44–53 | YES (all 10) | Unchanged — matches `03-ProofTheory.tex`'s already-accurate table |
| `Axiom.modal_5_collapse` | 60 | YES | Unchanged |
| `set_lindenbaum` | 73 | YES | Unchanged |
| `semantic_truth_lemma_v2` | 74 | **NO** | Retired. See `truth_lemma` note above — no single live name plays this exact role; nearest live analogues are the per-development truth lemmas (`BXCanonical/TruthLemma.lean` etc.) |
| `semantic_weak_completeness` | 75 | **NO** | Retired — see 04-Metalogic.tex entry above |
| `main_provable_iff_valid` | 76 | **NO** | Retired — see 04-Metalogic.tex entry above |

#### Other subfiles (in scope for the full audit per scope item 1; NOT part of the 04/06 rewrite)

| file | identifiers | live? | note |
|---|---|---|---|
| `01-Syntax.tex` | `Formula`, `String`, `atom s`, `bot`, `imp`, `box`, `all_past`, `all_future`, `neg`, `and`, `or`, `pos`, `some_past`, `some_future`, `always`, `sometimes`, `swap_temporal` | YES (all) | Accurate, no drift found |
| `03-ProofTheory.tex` | `Axiom.*` (14), `DerivationTree.*` (7 constructors) | YES (all) | Accurate, no drift found |
| `00-Introduction.tex` | `Bimodal/`, `Syntax/`, `ProofSystem/`, `Semantics/`, `Metalogic/`, `Theorems/` | `Bimodal/` **stale** (project root is not named `Bimodal/`; the Lean sources live under `FormalSystem/`), the five subdirectory names are individually correct as subdirectories of `FormalSystem/` | Out of this task's declared scope (00-Introduction.tex, not 04/06) but flagged since scope item 1 asked for the full audit; recommend a follow-up task or note for whoever next touches 00-Introduction.tex |
| `05-Theorems.tex` | `perpetuity_1`–`perpetuity_6`, `Perpetuity.lean`, `ModalS5.lean`, `ModalS4.lean`, `Propositional.lean`, `Combinators.lean`, `GeneralizedNecessitation.lean` | `perpetuity_1`–`6` YES (now in `Theorems/Perpetuity/Principles.lean`, re-exported via `Theorems/Perpetuity.lean`); `Propositional.lean` **stale as a bare file** — now a directory `Theorems/Propositional/{Core,Connectives,Reasoning}.lean` | Out of scope for 04/06 rewrite; minor path drift, flagged for completeness only |

### File-Path Audit (all `FormalSystem/...` paths cited in `latex/subfiles/*.tex`)

| path cited | exists? | live path if different |
|---|---|---|
| `FormalSystem/Metalogic/Representation/TruthLemma.lean` (04:157) | **MISSING** | No single successor file; nearest live analogues by development: `FormalSystem/Metalogic/BXCanonical/TruthLemma.lean`, `FormalSystem/Metalogic/WeakCanonical/TruthLemma.lean`, `FormalSystem/Metalogic/Algebraic/ParametricTruthLemma.lean` |
| `FormalSystem/Metalogic/Representation/UniversalCanonicalModel.lean` (04:169) | **MISSING** | No successor under that name; nearest live analogue: `FormalSystem/Metalogic/BXCanonical/CanonicalModel.lean` (chain-based BFMCS construction) |
| `FormalSystem/Metalogic/Core/MaximalConsistent.lean` (04:300) | EXISTS | — |
| `FormalSystem/Metalogic/StrongCompleteness.lean` (04:263) | EXISTS | — |
| `FormalSystem/Metalogic/` (04:430) | EXISTS (directory) | — |
| `Boneyard/Metalogic_v2/` (04:431) | out of grep scope (Boneyard excluded) but the *live* organizational claim built on this path is stale regardless (see Architecture Narrative) | — |

### Live Module Layout (`FormalSystem/Metalogic/`, excluding `Boneyard/`)

Top-level structure, for the directory tikz diagram. (Full recursive listing collected during
this audit; only top-level + one level of nesting shown here, since several subdirectories —
notably `WeakCanonical/Kamp/` — are very large internal machinery not suited to a summary
diagram.)

```
FormalSystem/Metalogic/
├── Core/                       -- shared foundations for every completeness route
│   ├── DeductionTheorem.lean       (deductionTheorem, Derivable.deduction)
│   ├── MaximalConsistent.lean      (Consistent, MaximalConsistent, SetConsistent,
│   │                                 SetMaximalConsistent, set_lindenbaum, contextToSet)
│   ├── MCSProperties.lean
│   └── RestrictedMCS/Basic.lean
│
├── Soundness.lean               -- top-level soundness theorem (soundness, soundness_dense,
│                                    soundness_discrete, soundness_dedekind + per-axiom *_valid)
├── SoundnessLemmas/              -- per-axiom validity lemmas backing Soundness.lean
│   ├── Core.lean, CoValidity.lean, DenseValidity.lean, FrameClassVariants.lean,
│   │   Separability.lean
│
├── StrongCompleteness.lean       -- consequence-completeness statements + the strong-
│                                    completeness programme (Dedekind instance landed;
│                                    Base/Dense/Discrete instances follow the same shape)
│
├── BXCanonical/                  -- completeness development #1: BX (chronicle/Henkin) route
│   ├── Frame.lean, TruthLemma.lean, Completeness.lean, CompletenessDedekind.lean,
│   │   CanonicalChain.lean, CanonicalModel.lean, CanonicalTaskRelation.lean
│   ├── Chronicle/                    (14 files: ChronicleConstruction, ChronicleToCountermodel, …)
│   ├── Quasimodel/                   (5 files: SubformulaClosure, HintikkaPoint, Construction, …)
│   └── Filtration/DefectChain.lean
│
├── WeakCanonical/                -- completeness development #2: Reynolds/Doets discrete route
│   ├── ReflexiveCanonical.lean, TruthLemma.lean, FrameProperties.lean,
│   │   ChronicleExtraction.lean, NEquivalence.lean, NormalForm.lean, OrderedSum.lean,
│   │   Table.lean, Transfer.lean (exports countermodel_discrete), PriorDefs(Dense).lean,
│   │   PriorExpressiveness(Dense).lean, StaviConnectives.lean, ReflexiveCanonical.lean
│   ├── Kamp/                          (very large — Kamp's-theorem translation machinery,
│   │                                   ~90 files: normal-form translation, ExistsForall
│   │                                   encoding, NfMultiAnchorBridge/ subtree, etc.)
│   ├── IntegerModel/                  (GoodStructures, ReynoldsBridge — exports
│   │                                   countermodel_discrete_reynolds_v2, ReynoldsNoGaps, …)
│   ├── DenseModelSurgery/, RealModel/, EFGames/, Expressiveness/, Separation/
│
├── Algebraic/                    -- completeness development #3: Lindenbaum-Tarski / parametric
│   ├── BooleanStructure.lean, InteriorOperators.lean, LindenbaumQuotient.lean,
│   │   ParametricCanonical.lean, ParametricCompleteness.lean, ParametricHistory.lean,
│   │   ParametricTruthLemma.lean, RestrictedParametricTruthLemma.lean, UltrafilterMCS.lean
│
├── Bundle/                       -- shared canonical-frame construction (BFMCS) used by
│   │                                BXCanonical (and referenced by others)
│   ├── BFMCS.lean (Bundle of FMCS), FMCSDef.lean (single Family of MCS), CanonicalFrame.lean,
│   │   CanonicalTaskRelation.lean, Construction.lean, LimitMCS(Coherence).lean,
│   │   ModalSaturation.lean, RealExtension(Bundle).lean, SuccRelation.lean,
│   │   TemporalCoherence.lean, TemporalContent.lean, UntilSinceCoherence.lean,
│   │   WitnessSeed.lean
│
└── Decidability/                 -- tableau-based decision procedure + FMP
    ├── SignedFormula.lean, Tableau.lean, Closure.lean, Saturation.lean,
    │   ProofExtraction.lean, CountermodelExtraction.lean, DecisionProcedure.lean,
    │   Correctness.lean (decide_sound), CancellableExpansion.lean, TraceCertificate.lean,
    │   TraceExport.lean
    ├── FMP/                            (ClosureMCS, Filtration, FiniteModel, FMP.lean —
    │                                    mcs_finite_model_property, TruthPreservation)
    ├── Propositional/                  (PropForm, Kalmar, Decidable)
    └── Verified/                       (Decidable.lean, RuleSpec.lean, Bridge/ [17 files],
                                          Termination/ [Fuel, SubformulaProperty, TimeTypeBound])
```

**Key correction versus the chapter's current diagram (04-Metalogic.tex:434–465)**: the chapter
draws a single linear pipeline `Core → {Representation, Soundness} → Completeness → {Applications,
FMP} → Decidability`. The live tree instead has **three parallel, independently-developed
completeness routes** (`BXCanonical/`, `WeakCanonical/`, `Algebraic/`) that all sit on top of
shared `Core/` (MCS machinery) and, for `BXCanonical/`, the shared `Bundle/` (BFMCS)
construction; `WeakCanonical/` is used *within* `BXCanonical/Completeness.lean`'s discrete
branch (as `WeakCanonical.countermodel_discrete`, deprecated/sorried) and *also* independently
exports the sorry-free `countermodel_discrete_reynolds_v2` used by `completeness_discrete`.
There is no `Representation/`, `Completeness/`, or `Applications/` directory at all.

### Live Per-Class Completeness Terminus Theorems

All in `FormalSystem/Metalogic/BXCanonical/Completeness.lean` unless noted.

| theorem | file:line | statement shape | sorry/axiom status |
|---|---|---|---|
| `completeness` | `Completeness.lean:196` | `valid φ → Derivable FrameClass.Base [] φ` | Carries live `sorryAx`. Sole source: the discrete branch calls the deprecated `WeakCanonical.countermodel_discrete` (`WeakCanonical/Transfer.lean`), whose underlying `succ_cofinal` argument is "provably unfixable" (per the module docstring) and has been archived to `Boneyard/DeadChronicleGapElimination/`. The dense branch (`countermodel_dense_enriched`) and mixed branch (`Chronicle.mcs_mixed_case_absurd`) are individually sorryAx-free; only the discrete branch is the debt. |
| `completeness_dense` | `Completeness.lean:255` | `ValidDense φ → Derivable FrameClass.Dense [] φ` | **sorryAx-free**. Docstring: "machine-verified; axioms: exactly `propext`, `Classical.choice`, `Quot.sound`" (kernel-verified via `#print axioms` — see lines 368–369 of the same file). |
| `completeness_discrete` | `Completeness.lean:296` | `ValidDiscrete φ → Derivable FrameClass.Discrete [] φ` | **sorryAx-free**, same axiom set. Uses `countermodel_discrete_reynolds_v2` (`WeakCanonical/IntegerModel/ReynoldsBridge.lean:739`) rather than the deprecated `WeakCanonical.countermodel_discrete` — this is a *different, sorry-free* pipeline from the one the general `completeness` theorem's discrete branch uses. |
| `completeness_dedekind` (unconditional) | — | — | **Does not exist as a live declaration.** Confirmed by grep across the whole non-Boneyard tree. Only `completeness_dedekind_of_engine` exists (`StrongCompleteness.lean:308`), conditional on a supplied single-formula completeness "engine" hypothesis — matches the task description's "in flight via the limit-MCS route" characterization. `BXCanonical/CompletenessDedekind.lean` (166 lines) currently hosts only carrier-probe lemmas (`real_lub_of_bddAbove`, `dedekind_box_dense_mem`), not the completeness theorem itself. |
| `consequence_completeness_dedekind_of_engine` | `StrongCompleteness.lean:274` | finite-context consequence completeness for Dedekind, conditional on an engine | Landed; Base/Dense/Discrete instances are documented as following the same three-declaration shape but were not found as separate landed declarations in this pass — `StrongCompleteness.lean` currently only develops the Dedekind instance. |

This matches — and gives file:line precision to — the task description's summary
("completeness at `Metalogic/BXCanonical/Completeness.lean:196`, `completeness_dense` at :255,
`completeness_discrete` at :296 — the latter two sorryAx-free …; `completeness_dedekind` in
flight via the limit-MCS route").

### Architecture Narrative (for the rewrite)

The live proof-of-completeness architecture, replacing the retired "quotient of (history, time)
pairs" story:

1. **Shared foundation** (`Core/`): `Consistent`, `MaximalConsistent`, `SetConsistent`,
   `SetMaximalConsistent`, `set_lindenbaum` (Zorn's-lemma Lindenbaum extension, set-level and
   finitary), `contextToSet`, `deductionTheorem`/`Derivable.deduction`. Nothing here is tied to
   any one completeness route — all three routes build on it.
2. **Three parallel completeness developments**, not two:
   - **`BXCanonical/`** — the "BX" (chronicle/Henkin-style) route. Builds a `BFMCS Int`
     (Bundle of Family-of-MCS, from `Bundle/`) via a chain construction
     (`CanonicalChain.lean`/`CanonicalModel.lean`) that resolves formulas along an
     enumeration schedule using forward/backward temporal witness seeds
     (`Bundle/WitnessSeed.lean`). Proves the truth lemma (`BXCanonical/TruthLemma.lean`) and
     is the home of the actual `completeness`/`completeness_dense`/`completeness_discrete`/
     (eventually) `completeness_dedekind` theorems.
   - **`WeakCanonical/`** — the Reynolds/Doets discrete-completeness route, including the large
     `Kamp/` subtree (Kamp's-theorem-style normal-form translation machinery) used to bridge
     temporal formulas to monadic first-order structures for the Doets k-types argument. Its
     main export, `countermodel_discrete` (`WeakCanonical/Transfer.lean`), is the deprecated
     fallback still wired into the general `completeness` theorem's discrete branch (the sole
     sorry source); its *sorry-free* sibling, `countermodel_discrete_reynolds_v2`
     (`IntegerModel/ReynoldsBridge.lean`), is what `completeness_discrete` actually uses.
   - **`Algebraic/`** — the Lindenbaum-Tarski quotient-algebra route: `LindenbaumQuotient.lean`,
     `ParametricCanonical.lean`, `ParametricTruthLemma.lean` (+ restricted variant),
     `UltrafilterMCS.lean`. This is the module family closest in spirit to the chapter's
     retired "quotient construction" prose (04-Metalogic.tex:162–164), but it is a *third*,
     independently-developed route, not the same construction under a new name, and it is not
     currently the one feeding the landed `completeness*` theorems in `BXCanonical/`.
3. **`Bundle/`** supplies the shared canonical-frame vocabulary used by `BXCanonical/`: `FMCS`
   (a single time-indexed family of MCS — the direct conceptual successor to the chapter's
   retired `IndexedMCSFamily`) and `BFMCS` (a bundle/set of `FMCS` instances with modal
   coherence — the direct conceptual successor to the chapter's "canonical model" role, though
   structurally different: it is a *bundle* rather than a single quotient of history-time
   pairs, precisely so that `□` can quantify over the bundled histories rather than all
   histories, per the module's own "Key Insight" docstring).
4. **Truth lemma and "representation theorem"**: there is no single live analogue of the
   chapter's `representation_theorem`/`strong_representation_theorem` pair. The proof argument
   those theorems encapsulated (consistent set → Lindenbaum-extend → canonical world → truth
   lemma → satisfiable) is now inlined directly inside each `completeness*` proof in
   `BXCanonical/Completeness.lean` (see the proof body at line 196 onward: `set_lindenbaum` →
   case-split on dense/discrete/mixed → `countermodel_*` → contradiction with the semantic
   validity hypothesis) rather than being factored into a standalone, reusable representation
   theorem. The rewrite should present this as "the proof inlines what was previously two
   separate representation theorems" rather than hunting for a 1:1 name replacement.
5. **Decidability** (`Decidability/`): structurally unchanged from the chapter's description —
   `SignedFormula`, `Tableau`, `Closure`, `Saturation`, `ProofExtraction`,
   `CountermodelExtraction`, `DecisionProcedure`, `Correctness` (`decide_sound`) all exist as
   named live files matching the chapter's status table rows. The FMP lives in `Decidability/
   FMP/FMP.lean` as `mcs_finite_model_property`, not the top-level `FormalSystem/Metalogic/
   FMP.lean` "central hub" the chapter's directory diagram shows.

## Concrete Section-by-Section Rewrite Plan

### `04-Metalogic.tex`

| section | lines | action |
|---|---|---|
| Soundness (table) | 10–54 | **Light edit**. All 15 lemma names are live and correct; only line 54's `WorldHistory.time_shift` needs correcting to `WorldHistory.timeShift`. |
| Core Infrastructure / Deduction Theorem | 56–74 | **No change needed** for the theorem statement; optionally add a footnote noting the live name is `deductionTheorem` (list-context) with a newer `Derivable.deduction` general form, since the chapter never actually cites a bare identifier here (only "Deduction Theorem" as English + the theorem environment) — low priority. |
| Consistency / Lindenbaum's Lemma | 76–104 | **No change needed**. `set_lindenbaum` is live and correctly cited. |
| Canonical World States (Task Relation, Semantic World State, Universal Canonical Model, Canonical Valuation, Truth Lemma) | 111–164 | **Full replacement**. Every named construction here (`SemanticTaskRelV2`, `SemanticWorldState`, `IndexedMCSFamily D`, `canonical_model D family`, the quotient-construction Truth Lemma) is retired. Replace with the live `BXCanonical`/`Bundle` picture: `FMCS`/`BFMCS` from `Bundle/`, the chain construction from `BXCanonical/CanonicalChain.lean`/`CanonicalModel.lean`, and the truth lemma from `BXCanonical/TruthLemma.lean`. This section also carries three `% FIX`/`% TODO` author comments (116, 130, 132, 160) flagging the existing prose as informal/wrong-spirit — the rewrite should resolve or explicitly carry these forward, not silently drop them. |
| Representation Theorem / Strong Representation Theorem | 166–188 | **Full replacement or removal**. No live 1:1 analogue exists (see Architecture Narrative point 4). Replace with a short paragraph describing how the argument is now inlined in each `completeness*` proof, or delete the standalone theorem environments and fold the content into the Weak/Consequence Completeness subsections that follow. |
| Theorem Dependency Structure (tikz figure) | 190–227 | **Full replacement**. The diagram's node labels (`deduction_theorem`, `set_lindenbaum`, `MaximalConsistent`, `representation_theorem`, `semantic_weak_completeness`, `consequence_completeness_*`) mix two retired names with two live ones inside one figure. Redraw against the live dependency structure: `Core/` (`deductionTheorem`, `set_lindenbaum`, `MaximalConsistent`) → `Bundle/` (`FMCS`/`BFMCS`) → `BXCanonical/TruthLemma.lean` → `BXCanonical/Completeness.lean` (`completeness`/`completeness_dense`/`completeness_discrete`) → `StrongCompleteness.lean` (`consequence_completeness_dedekind_of_engine` etc.). |
| Weak Completeness | 233–247 | **Light edit**. Update the footnote's cited name from `semantic_weak_completeness` to the per-class `completeness`/`completeness_dense`/`completeness_discrete` set (with the sorry caveat on the Base case), keeping the proof-sketch prose (which is generic contrapositive reasoning and still accurate). |
| Consequence Completeness | 249–278 | **No change needed** — already updated in the terminology pass; footnote already correctly cites `consequence_completeness_dedekind` and `StrongCompleteness.lean`. Minor tightening only: the exact declaration name is `consequence_completeness_dedekind_of_engine` (with the `_of_engine` suffix), not the bare name the footnote uses — a one-word fix. |
| Strong Completeness and Compactness | 280–316 | **No change needed** — already landed and confirmed accurate against `StrongCompleteness.lean`'s docstring (per-class split, compactness argument, and file citation all match). |
| Provable iff Valid | 318–324 | **Full replacement or removal**. No unconditional `main_provable_iff_valid` biconditional exists live. Replace with a paragraph stating the result compositionally per class (`completeness*` + `soundness*` pairs), or remove the standalone theorem environment. |
| Two Canonical Model Approaches | 326–346 | **Full replacement**. This is the largest architecture-fidelity gap: the "Syntactic (Boneyard) vs. Semantic (quotient)" dichotomy is false against the live tree, which has three parallel developments (`BXCanonical/`, `WeakCanonical/`, `Algebraic/`) plus the shared `Bundle/` construction, none of which is a straightforward "equivalence classes of (history, time) pairs" quotient. Replace with the Architecture Narrative content above (point 2). The existing `% TODO` comment at line 331 (about porting the syntactic approach from Boneyard) should be preserved or explicitly resolved, not silently dropped. |
| Decidability (Decidability theorem, Decision Soundness, Tableau Structure, Complexity, Decision Result Types) | 348–426 | **No change needed**. `decide_sound`, the `Derivable FrameClass.Base [] φ` type shape, and the tableau vocabulary are all confirmed live and accurate. |
| File Organization and Dependencies (prose + directory tikz diagram) | 428–476 | **Full replacement**. Both the prose ("using the `IndexedMCSFamily` approach") and the diagram (`Core/ → {Representation/, Soundness/} → Completeness/ → {Applications/, FMP.lean} → Decidability/`) are stale — `Representation/`, `Completeness/`, `Applications/` don't exist, `Soundness/` is a file not a directory, and there's no top-level `FMP.lean` hub. Replace with the live top-level layout from "Live Module Layout" above: `Core/` → three parallel routes (`BXCanonical/`, `WeakCanonical/`, `Algebraic/`) + `Bundle/` → `Decidability/`, plus `Soundness.lean`/`SoundnessLemmas/` and `StrongCompleteness.lean` as top-level files. |
| Implementation Status: Sorry Status | 478–491 | **Full replacement**. Describes `Metalogic_v2`'s three sorries in `SemanticCanonicalModel.lean`/`FiniteModelProperty.lean`, none of which exist. Replace with the accurate live picture: `completeness` (Base) carries one live sorryAx sourced from the deprecated `WeakCanonical.countermodel_discrete` fallback; `completeness_dense` and `completeness_discrete` are sorryAx-free; `completeness_dedekind` (unconditional) is not yet landed (only the `_of_engine` conditional form exists). |
| Implementation Status: Decidability Implementation (table) | 493–511 | **No change needed** — submodule names/status match live `Decidability/` structure (spot-check only; not exhaustively re-verified line-by-line in this pass since the task description did not flag it as stale). |
| Implementation Status: Metalogic Implementation (table) | 513–540 | **Full replacement**. Every "Lean" column entry that names a retired identifier (`deduction_theorem`, `set_lindenbaum` is fine, `IndexedMCSFamily`, `truth_lemma`, `representation_theorem`, `semantic_weak_completeness`, `main_provable_iff_valid`, `finite_model_property`) needs updating per the identifier audit table above; the footnote at 536–540 already correctly states the terminology distinction (consequence vs. strong completeness) but should be updated once the "Lean" column names are fixed, since it currently reads consistently only because the surrounding stale names are internally consistent with *each other*, not with the live tree. |

### `06-Notes.tex`

| section | lines | action |
|---|---|---|
| Implementation Status (top summary table) | 8–23 | **No change needed** — this table describes results at the English/status level ("Completeness — Proven (Semantic) — Lindenbaum, truth lemma, weak completeness"), not specific identifiers; the claims remain directionally accurate (completeness is proven for the classes described) though "Semantic" as the qualifier is now ambiguous given three developments exist — consider changing to "per-class (Base/Dense/Discrete proven, Dedekind in progress)" for precision. |
| Discrepancy Notes / Terminology / Axiom Naming / M5 Collapse | 25–65 | **No change needed** — all `Axiom.*` names live and correct, matches `03-ProofTheory.tex`. |
| Completeness Status | 67–79 | **Full replacement of the bullet list** (lines 72–77): `set_lindenbaum` stays; `semantic_truth_lemma_v2`, `semantic_weak_completeness`, `main_provable_iff_valid` are all retired (same replacements as the 04-Metalogic.tex identifier audit entries). Line 78's "world states as equivalence classes of history-time pairs" prose should be updated to the `FMCS`/`BFMCS` bundle picture. Line 79's Bridge-sorry caveat should be updated to reflect the current single sorry source (deprecated `WeakCanonical.countermodel_discrete` in the Base branch) rather than a generic "bridge sorries remain" — note this line already correctly uses the settled terminology ("the finite-context form; strong completeness is reserved for infinite premise sets") from the terminology pass, so only the sorry-count/identifier claims need updating, not the terminology. |
| Decidability Implementation | 81–88 | **No change needed** — matches the live `Decidability/FMP/FMP.lean` picture (FMP "stated but not yet fully formalized" is consistent with `mcs_finite_model_property` existing but the overall FMP-driven completeness path not being the one used by the landed `completeness*` theorems). |

## Compilation Confirmation

Both required commands were run exactly as specified, from `latex/subfiles/`, with
`TEXINPUTS=../assets:` (since `formatting.sty` lives in `latex/assets/`):

```
$ TEXINPUTS=../assets: pdflatex -interaction=nonstopmode 04-Metalogic.tex
exit code: 0
Output written on 04-Metalogic.pdf (12 pages, 286897 bytes).

$ TEXINPUTS=../assets: pdflatex -interaction=nonstopmode 06-Notes.tex
exit code: 0
Output written on 06-Notes.pdf (3 pages, 102298 bytes).
```

Both files compile standalone today, confirming the task description's claim and establishing
the pre-rewrite baseline that any future rewrite must preserve. Note: running these commands
regenerated `04-Metalogic.log` (already git-tracked, now shows as modified) and created new
untracked build artifacts (`04-Metalogic.{aux,out,pdf}`, `06-Notes.{aux,log,out,pdf}`) under
`latex/subfiles/`. These are harmless standard LaTeX build byproducts and were left in place
rather than cleaned up, since compiling was explicitly authorized by the dispatch instructions
and no `FormalSystem/`/`Tests/` files were touched.

## Decisions

- Scoped the identifier/path audit to all seven `latex/subfiles/*.tex` files (per scope item 1's
  literal wording) while keeping the section-by-section **rewrite plan** limited to
  `04-Metalogic.tex` and `06-Notes.tex` only, per the task's explicit primary-target framing and
  the "especially" qualifier in the task description. Findings for `00-Introduction.tex` (stale
  `Bimodal/` root name) and `05-Theorems.tex` (minor `Propositional.lean` → `Propositional/`
  path drift) are recorded but flagged out-of-scope for this task's rewrite, not silently
  dropped.
- Did not attempt to independently re-verify the `[propext, Classical.choice, Quot.sound]`
  axiom claims for `completeness_dense`/`completeness_discrete` via a live `lean_verify` MCP
  call, since the module's own docstring already states these were "kernel-verified via
  `#print axioms` against fresh oleans" and the concurrency constraint asked for minimal
  interaction with the Lean toolchain during task 418's build-lock window; the docstring claim
  is treated as authoritative pending any future independent check.
- Treated `consequence_completeness_dedekind_of_engine`/`completeness_dedekind_of_engine`
  (both suffixed `_of_engine`) as the accurate live names rather than assuming the unsuffixed
  forms will land imminently — the rewrite should cite the suffixed names as they exist today
  and can be updated again once (if) the unconditional forms land.

## Risks & Mitigations

- **Risk**: the tikz diagrams (Theorem Dependency Structure, File Organization) are the
  highest-effort rewrite items (structural redraws, not text edits) and the most likely to
  silently drift again if the underlying module layout changes further (e.g., if
  `completeness_dedekind` lands unconditionally, or if `Algebraic/` becomes the live source for
  `BXCanonical/`'s truth lemma). **Mitigation**: when redrawing, cite the aggregator files
  (`BXCanonical.lean`, `WeakCanonical.lean`, `Algebraic.lean`, `Bundle.lean`, `Core.lean`) by
  name in figure captions/footnotes so a future reconciliation pass can re-derive the diagram
  from those docstrings rather than re-deriving the whole module tree from scratch.
- **Risk**: this task's coordination note says a separate leg (tracked in `specs/ROADMAP.md`'s
  "Completeness programme" block) owns stating the genuine strong-completeness results once
  they land; if that work lands `completeness_dedekind` unconditionally before this task's
  rewrite is implemented, the "Implementation Status" table content proposed above will need a
  small follow-up patch. **Mitigation**: the rewrite plan already phrases the Dedekind status
  in terms of the current `_of_engine` conditional form rather than presupposing convergence
  timing, so the patch surface if/when it lands is small (one table row + one footnote).
- **Risk**: `WeakCanonical.countermodel_discrete`'s deprecation status (feeding the general
  `completeness` theorem's sole sorry) could change if a Base-to-Discrete MCS transfer or
  Henkin-style discrete model is found (per `Completeness.lean`'s own docstring, "a genuine open
  construction, not a re-wiring task"). **Mitigation**: the rewrite plan's Sorry Status section
  should cite the specific blocker (the docstring's own characterization) rather than a vague
  "sorries remain" claim, so a future pass can tell at a glance whether the blocker is still
  open.

## Context Extension Recommendations

- **Topic**: Metalogic module architecture (three-development split).
- **Gap**: no existing `.claude/context/` or `.memory/` entry documents that
  `FormalSystem/Metalogic/` contains three independently-developed, parallel completeness
  routes (`BXCanonical/`, `WeakCanonical/`, `Algebraic/`) sharing `Core/`/`Bundle/` — this is
  exactly the kind of "unexpected pattern in the codebase" future Lean-implementation or
  research dispatches touching `Metalogic/` would benefit from knowing up front rather than
  re-discovering via a full directory walk each time.
- **Recommendation**: a short memory entry (see `memory_candidates` in the metadata file) or a
  `.claude/context/project/logic/domain/` note summarizing this architecture split, referencing
  the five aggregator-file docstrings (`Core.lean`, `BXCanonical.lean`, `WeakCanonical.lean`,
  `Algebraic.lean`, `Bundle.lean`) as the source of truth, so it stays current as those
  docstrings are updated rather than needing separate maintenance.

## Appendix

### Search commands used

```
grep -noE '\texttt\{[^}]*\}' latex/subfiles/*.tex
find FormalSystem/Metalogic -type f -name '*.lean' | grep -v Boneyard | sort
find FormalSystem/Metalogic -maxdepth 2 -type d | grep -v Boneyard | sort
grep -rl "\b<identifier>\b" FormalSystem/ --include='*.lean' | grep -v Boneyard   # per-identifier liveness check, ~45 identifiers checked
grep -n "^theorem completeness" FormalSystem/Metalogic/BXCanonical/Completeness.lean
grep -rn "completeness_dedekind\b" FormalSystem/ --include='*.lean' | grep -v Boneyard
sed -n '1,60p' FormalSystem/Metalogic/{Core,BXCanonical,WeakCanonical,Algebraic,Bundle}.lean   # aggregator docstrings
TEXINPUTS=../assets: pdflatex -interaction=nonstopmode 04-Metalogic.tex   # from latex/subfiles/
TEXINPUTS=../assets: pdflatex -interaction=nonstopmode 06-Notes.tex      # from latex/subfiles/
```

### Files/paths referenced in this report

- `latex/subfiles/04-Metalogic.tex`, `latex/subfiles/06-Notes.tex` (audited, not modified)
- `latex/subfiles/00-Introduction.tex`, `01-Syntax.tex`, `03-ProofTheory.tex`, `05-Theorems.tex`
  (audited for scope item 1 completeness; not part of the 04/06 rewrite)
- `FormalSystem/Metalogic/{Core,BXCanonical,WeakCanonical,Algebraic,Bundle,Decidability,
  Soundness,SoundnessLemmas,StrongCompleteness}.lean` and their subdirectories (read-only)
- `FormalSystem/Metalogic/BXCanonical/Completeness.lean:196,255,296` (per-class completeness
  termini)
- `FormalSystem/Metalogic/StrongCompleteness.lean:274,308` (Dedekind consequence/weak
  completeness, conditional forms)
- `FormalSystem/Semantics/WorldHistory.lean:246` (`timeShift`)
