# Territory E: Documentation & Publication Readiness — Findings

Review date: 2026-09-01. Repository HEAD `257cad9b8`. Read-only; no repository file was
modified. All ground truth below was re-derived from the tree at review time
(`find`/`wc -l`/`grep`/`git log`), never copied from another document.

---

## 1. Assessment

The Lean sources are in **excellent** publication shape and the prose documentation is not.
Doc-gen4 readiness across the core scope is genuinely strong: 67 of 68 files carry a module
docstring (99%) and 924 of 1,028 public declarations carry a `/--` doc comment (90%). Every
flagship declaration named in prose resolves in the tree — I checked 41 names and only one
(`co_not_derives_prior_U`, `Metalogic/Independence/README.md:30`) was wrong, and it is a
truncation of the real `co_not_derives_prior_U_gap`. The mathematics is described accurately
at the declaration sites.

The problem is the **aggregate layer**: `README.md`, `FormalSystem/README.md`,
`FormalSystem/Metalogic/README.md` and `FormalSystem/Metalogic.lean` restate, by hand, a large
body of quantitative and status facts that the tree already knows. Essentially every one of
those restatements has drifted. I found **~40 numeric claims stale** across four documents,
including six file counts wrong by 6–44 files and a "Ten loose files" claim contradicted by
the eleven-row table immediately beneath it. Three claims are worse than stale — they are
*contradictions between two live documents*:

- **`README.md:167` says Dedekind strong completeness is "not stated … no `CompactDedekind`
  definition and no refuting theorem"**, while `SetConsequence.lean:601,609` defines both and
  `DedekindNonCompactness.lean:431,459` refutes both. `Metalogic.lean:116-120` states the
  refutation correctly. The repository's front page contradicts its own status ledger about a
  headline result. (E-01)
- **`Metalogic.lean:227` says counts "exclude BOTH Boneyards (there are two)"** while
  `Metalogic/README.md:12-16` says there is exactly one and check B0 asserts it. (E-04)
- **`typst/FormalFoundations.typ:993,999-1004`** — a compiled publication artifact — reports
  `completeness` as carrying `sorryAx` and states the tree has "exactly one structural `sorry`
  … `countermodel_discrete` in `WeakCanonical/Transfer.lean`". C3 asserts zero, and
  `countermodel_discrete` is proved at `GroupModel/CountermodelBase.lean:143`. (E-02)

Separately, `FormalSystem/README.md` and `Syntax/README.md` still describe a **superseded
`Formula` type**: they present `all_past`/`all_future` as primitive constructors and omit
`untl`/`snce` entirely. `Formula`'s six constructors are `atom, bot, imp, box, untl, snce`
(`Syntax/Formula.lean:96,106`); `allPast`/`allFuture` are derived `def`s at lines 167 and 177,
and the snake_case spellings do not exist at all. The top-level `README.md` gets this right, so
a reader who reads both is told two incompatible things about the object language. (E-03)

The root cause is uniform and fixable: **there is no single source of truth**. Counts,
axiom-status claims and module inventories are hand-maintained in four to six places each.
`scripts/check-module-invariants.sh` already computes almost all of it (C2, C3, C7, C14) and
`scripts/typst-status-counts.sh` already *generates* `typst/generated/status.typ`. The
generation habit exists; it just has not been extended to the READMEs. Section 5 proposes the
policy and a `docs/theorem-index.md` schema with 16 populated rows.

Publication packaging gaps: no `CITATION.cff`, no `docs/ARCHITECTURE.md` layer diagram, no
theorem index, and `docs/README.md:273-279` documents a `lake build :docs` doc-gen4 recipe that
cannot work — `lakefile.lean` has no `doc-gen4` requirement and `lake-manifest.json` has zero
matches for it. CI and a build badge do exist (`.github/workflows/ci.yml`, `README.md:3`).

---

## 2. Drift table (Q1)

Every "ground truth" cell was measured at review time. Live counts exclude `*/Boneyard/*`
by name glob, matching the invariant script's convention.

### 2a. `FormalSystem/Metalogic/README.md`

| # | Claim | Location | Ground truth | Status |
|---|-------|----------|--------------|--------|
| 1 | "**314 live `.lean` files** (227,081 lines)" | `Metalogic/README.md:6-7` | 323 files, 229,930 lines | STALE |
| 2 | "The eight directories total 314 files, matching C7's `Metalogic 314` rollup" | `:191` | eight subdirs = 304 files; +19 loose = 323 | STALE (both halves) |
| 3 | Independence 3 files / 1,097 lines | `:34`, `:187` | 6 files / 1,883 lines | STALE |
| 4 | SoundnessLemmas 5 / 3,016 | `:188` | 5 / 2,487 | STALE |
| 5 | Decidability 62 / 52,132 | `:186` | 62 / 52,683 | STALE (lines) |
| 6 | Algebraic 5 / 2,887 | `:33`, `:182` | 5 / 2,899 | STALE (lines) |
| 7 | BXCanonical 28 / 23,256 | `:31`, `:184` | 28 / 23,269 | STALE (lines) |
| 8 | WeakCanonical 179 / 132,177 | `:32`, `:189` | 179 / 132,173 | STALE (lines) |
| 9 | "**Ten** loose files in `Metalogic/` are not aggregators" | `:136` | **eleven** — 19 loose `.lean` − 8 aggregators; the table at `:139-151` itself lists 11 rows | STALE, self-contradicting |
| 10 | `Soundness.lean` 2,108 | `:142` | 1,741 | STALE |
| 11 | `StrongCompleteness.lean` 1,002 | `:142` | 1,025 | STALE |
| 12 | `BaseLanguageSoundness.lean` 482 | `:146` | 506 | STALE |
| 13 | `Compactness.lean` 179 | `:148` | 181 | STALE |
| 14 | `Z1Countermodel.lean` 194 | `:151` | 202 | STALE |
| 15 | `Independence.lean` aggregator 46 | `:132` | 57 | STALE |
| 16 | "root `Metalogic.lean` (227 lines)" | `:153` | 257 | STALE |
| 17 | `FormalSystem/FormalSystem.lean` (107 lines) | `:174-175` | 101 | STALE |
| 18 | `IntegerModel/` 6 / 5,700 | `:211` | 6 / 5,697 | STALE (lines) |
| 19 | `GroupModel/` 6 / 3,357 | `:212` | 6 / 3,356 | STALE (lines) |
| 20 | `Independence/` row carries no README link | `:187` | `Metalogic/Independence/README.md` exists (57 lines) | INCOMPLETE |
| — | Core 4 / 2,050; Bundle 15 / 6,106; Kamp 116 / 77,619; EFGames 8 / 11,872; Expressiveness 5 / 9,503; DenseModelSurgery 9 / 7,568; RealModel 7 / 6,643; Separation 3 / 926; NfMultiAnchorBridge 47 / 41,345; EANegationFix 7 / 3,227; EANegationFixFaithful 5 / 2,661; "19 loose + 8 subdirs"; "57 loose Kamp modules"; BXCanonical "eight loose modules", Chronicle 14, Quasimodel 5, Filtration 1; aggregator lines for Algebraic 40 / Bundle 52 / BXCanonical 43 / Core 37 / Decidability 168 / SoundnessLemmas 34 / WeakCanonical 144; root `FormalSystem.lean` 50 | various | all confirmed | **ACCURATE** |

### 2b. `FormalSystem/Metalogic.lean` — the "Module Structure" tree (`:224-256`)

This block is the single most drifted artifact in the review.

| # | Claim | Location | Ground truth | Status |
|---|-------|----------|--------------|--------|
| 21 | "counts exclude BOTH Boneyards (there are two -- see `Metalogic/README.md`)" | `Metalogic.lean:227-228` | exactly **one** (`find FormalSystem -type d -name Boneyard` → 1); B0 asserts it; `Metalogic/README.md:12-16` says so explicitly | STALE + **CONTRADICTS** `Metalogic/README.md` |
| 22 | `Bundle/` 12 files | `:233` | 15 | STALE |
| 23 | `BXCanonical/` 20 files | `:235` | 28 | STALE |
| 24 | `Chronicle/` 8 files | `:236` | 14 | STALE |
| 25 | `WeakCanonical/` 135 files | `:239` | 179 | STALE |
| 26 | `Kamp/` 99 files, "has its OWN local `Boneyard/`" | `:240` | 116 files; no local Boneyard | STALE (both halves) |
| 27 | `Decidability/` 19 files | `:245` | 62 | STALE |
| 28 | `Propositional/` 3 files | `:246` | subdirectory of `Decidability/`; not separately re-derived | unverified |
| 29 | `SoundnessLemmas/` 3 files | `:248` | 5 | STALE |
| 30 | Tree omits `Independence/`, `Core/RestrictedMCS/`, `WeakCanonical/{DenseModelSurgery,RealModel,GroupModel}/` | `:231-251` | all exist and are live | INCOMPLETE |
| 31 | Aggregator list omits `Independence.lean` | `:249` | `Metalogic/Independence.lean` (57 lines) exists and is imported at `:14` | INCOMPLETE |

### 2c. `FormalSystem/README.md`

| # | Claim | Location | Ground truth | Status |
|---|-------|----------|--------------|--------|
| 32 | Primitive operators = `box`, `all_past` (H), `all_future` (G); `untl`/`snce` absent | `:51-58` | `Formula` ctors: `atom, bot, imp, box, untl, snce` (`Syntax/Formula.lean:96,106`). `all_past`/`all_future` do **not** exist as identifiers; `allPast`/`allFuture` are derived `def`s (`Formula.lean:167,177`) | **STALE — wrong object language** |
| 33 | Derived ops `some_past`, `some_future` | `:68-69` | `somePast` (`Formula.lean:157`), `someFuture` (`:147`) | STALE NAMES |
| 34 | `Metalogic.lean` 199 lines | `:228` | 257 (and `Metalogic/README.md:153` says 227 — three values for one file) | STALE |
| 35 | `Semantics.lean` 137 | `:230` | 207 | STALE |
| 36 | `Automation.lean` 102 | `:225` | 103 | STALE |
| 37 | `BaseLanguage.lean` 34 | `:226` | 44 | STALE |
| 38 | `FormalSystem/FormalSystem.lean` 107 | `:224` | 101 | STALE |
| 39 | `Theorems.lean` 88 | `:232` | 89 | STALE |
| 40 | "`BaseLanguage/` \| No \| … (no README yet)" | `:282` | `FormalSystem/BaseLanguage/README.md` exists (69 lines, 4,092 bytes) | STALE |
| 41 | Submodule Navigation table omits `Independence/` | `:273-283` | `Metalogic/Independence/README.md` exists | INCOMPLETE |
| 42 | "*Last verified: 2026-08-25*" | `:362` | `git log -1 -- FormalSystem` → 2026-09-01 | STALE |
| — | Boneyard 156 archived `.lean`; 45 axiom constructors; nine layers; 37/2/3/3 frame split; 7 inference rules | `:79-100`, `:283` | all confirmed (45 constructors enumerated from `Axioms.lean`) | **ACCURATE** |

### 2d. Top-level `README.md`

| # | Claim | Location | Ground truth | Status |
|---|-------|----------|--------------|--------|
| 43 | Dedekind strong completeness "**not stated** … this tree contains no `CompactDedekind` definition and no refuting theorem, so the class is *unproved* rather than refuted" | `README.md:167` | `SetConsequence.lean:601` `def StrongCompletenessDedekind`, `:609` `def CompactDedekind`; `DedekindNonCompactness.lean:431` `dedekind_consequence_not_compact`, `:459` `strongCompletenessDedekind_refuted` | **STALE — CONTRADICTS `Metalogic.lean:116-120`** |
| 44 | "Dedekind strong completeness (open …)" | `README.md:240-241` | refuted, as above | STALE |
| 45 | "`FormalSystem/` (413 live `.lean` files)" | `:107` | 434 | STALE |
| 46 | "Lean files 579" | `:19` | 580 repo-wide `.lean` excluding `.lake`/`Boneyard` | borderline (off by one) |
| 47 | `git clone …/BimodalLogic.git` then `cd ProofChecker` | `:150-152` | the clone creates `BimodalLogic/` | BROKEN RECIPE |
| — | 5 primitives `bot/imp/box/untl/snce`; argument-order note; 45 constructors / nine layers; 37-39-40-42 cumulative counts; CI badge | `:33-51`, `:171-192` | confirmed against `Formula.lean` and `Axioms.lean` | **ACCURATE** |

### 2e. `FormalSystem/Semantics/README.md` and `FormalSystem/Semantics.lean`

| # | Claim | Location | Ground truth | Status |
|---|-------|----------|--------------|--------|
| 48 | Contents table lists 16 loose modules | `Semantics/README.md:9-27` | 19 loose `.lean`; **missing** `FrameClassValidity.lean`, `FrameProperty.lean`, `TemporalOrder.lean` | INCOMPLETE |
| 49 | Key Definitions cite `truth_at`, `valid` | `:34-35` | `TruthAt` (`Truth.lean:163`); `valid` exists (`Validity.lean:377`) | half STALE |
| 50 | "*Last verified: 2026-05-29*" | `:67` | `git log -1 -- FormalSystem/Semantics` → 2026-09-01 | STALE (3 months) |
| 51 | Truth-clause table: `TruthAt M τ t ht φ`; `□φ` = `∀ σ, σ.domain t → …`; rows for `Hφ`/`Gφ` | `Semantics.lean:~176-190` | `TruthAt M τ t : Formula → Prop` — **no `ht` argument**; `box` clause is `∀ σ, σ.IsTotal → …` (`Truth.lean:167`); there are **no `H`/`G` clauses** — the recursion is on `untl`/`snce` | STALE — describes superseded type |
| 52 | "Nullity \| `w ∈ w · 0` \| `nullity : ∀ w, TaskRel w 0 w`" presented as a frame axiom | `Semantics.lean` Correspondence table | `README.md:82` states nullity is **derived**, not an axiom | INCONSISTENT |
| — | Correspondence/README per-file line counts (183/161/563/131/445/186) | `Correspondence/README.md:28-33` | exact match | **ACCURATE** |

### 2f. `FormalSystem/Syntax/README.md`, `ProofSystem/README.md`, sub-READMEs

| # | Claim | Location | Ground truth | Status |
|---|-------|----------|--------------|--------|
| 53 | "Primitives: `atom`, `bot`, `imp`, `box`, `all_past`, `all_future`" | `Syntax/README.md:19` | `atom, bot, imp, box, untl, snce` | **STALE — wrong object language** |
| 54 | "*Last verified: 2026-05-29*" | `Syntax/README.md:34` | dir changed 2026-08-17 | STALE |
| 55 | "*Last verified: 2026-05-29*" | `ProofSystem/README.md:86` | dir changed 2026-08-25 | STALE |
| 56 | "*Last verified: 2026-05-29*" | `Metalogic/Core/README.md:162` | dir changed 2026-08-25 | STALE |
| 57 | `ClockFrame.lean` 240 lines | `Independence/README.md:21` | 245 | STALE |
| 58 | Key result "`co_not_derives_prior_U`" | `Independence/README.md:30` | no such declaration; real names are `co_not_derives_prior_U_gap` (`CoNotPriorU.lean:327`) and `co_not_derives_prior_U_gap_schema` (`:578`) | STALE NAME |
| — | `SoundnessLemmas/README.md` per-file lines (141/107/1296/591/352 = 2,487) | `:13-17` | exact match — and it **disagrees with** `Metalogic/README.md:188`'s 3,016 | ACCURATE (parent is wrong) |
| — | `Independence/README.md` other five line counts; `Algebraic/README.md` module list | — | confirmed | **ACCURATE** |

### 2g. `docs/` and `typst/`

| # | Claim | Location | Ground truth | Status |
|---|-------|----------|--------------|--------|
| 59 | "`completeness` … Axioms: same, plus `sorryAx` … `sorryAx`: **yes**" | `typst/FormalFoundations.typ:993` | C2 baseline (`check-module-invariants.sh:145`) pins `completeness` at `[propext, Classical.choice, Quot.sound]` | **STALE — publication artifact** |
| 60 | "the development contains exactly one structural `sorry` … `countermodel_discrete` in `WeakCanonical/Transfer.lean`. It is dead code." | `typst/FormalFoundations.typ:999-1001` | C3 asserts **zero**; `countermodel_discrete` proved at `WeakCanonical/GroupModel/CountermodelBase.lean:143` | **STALE** |
| 61 | "The fourth result … The `sorryAx` traces to a single dependency, `countermodel_discrete`, which is dead code" | `typst/FormalFoundations.typ:697`, `:701`, `:1543` | as above | STALE (3 more sites) |
| 62 | `sorry-table` row `("WeakCanonical/", 4)` printed beside `sorry-total-excl-boneyard = 0` | `typst/generated/status.typ:22,28` | the 4 are in the relocated archive `Boneyard/Kamp/KampWeakCanonical/`; the generator computes `SORRY_WEAKCANONICAL_ALL` (`typst-status-counts.sh:116-117,216`) | MISLEADING LABEL |
| 63 | "All 21 TM axiom schemas organized into base (17), dense (1), and discrete (3) layers" | `docs/project-info/implementation-status.md:36` | 45 constructors, 37/2/3/3 | STALE — and **invisible to C14** (see E-09) |
| 64 | "one of the 14 TM axiom schemas" | `docs/user-guide/examples.md:579` | as above | STALE — invisible to C14 |
| 65 | `lake build :docs` generates doc-gen4 output | `docs/README.md:273-279` | `lakefile.lean` has no `doc-gen4` `require` and no `:docs` facet; `grep -c doc-gen lake-manifest.json` → 0 | BROKEN RECIPE |
| 66 | `completeness_dedekind` at `Metalogic/StrongCompleteness.lean:469` | `docs/reference/API_REFERENCE.md:656` | declaration at `:587`; line 469 is prose | STALE LINE NUMBER |
| 67 | "**Last Updated**: 2026-01-11" | `docs/reference/API_REFERENCE.md:4` | eight months of subsequent change | STALE |
| 68 | "_Last updated: March 2026_" | `docs/README.md` | as above | STALE |
| — | `completeness`/`_dense`/`_discrete` at `Completeness.lean:196/255/296` | `API_REFERENCE.md:653-655` | exact match | **ACCURATE** |
| — | 93 `file.lean:NNN` citations exist in live markdown; none is out-of-range | repo-wide | measured | acceptable but fragile |

---

## 3. Status-prose census (Q2) and doc-gen coverage (Q3)

### 3a. Status-prose census

`SORRY-FREE` / `sorry-free` occurrences on live surfaces (Boneyard excluded):

| Surface | Occurrences |
|---------|------------:|
| `FormalSystem/Metalogic.lean` | 17 |
| `FormalSystem/Metalogic/Decidability/README.md` | 18 |
| `README.md` | 6 |
| `FormalSystem/Metalogic/Algebraic/README.md` | 6 |
| `docs/project-info/known-limitations.md` | 6 |
| `Metalogic/Core/README.md`, `Metalogic/Bundle/README.md` | 4 each |
| `FormalSystem/Examples/README.md` | 3 |
| `FormalSystem/README.md`, `Decidability/BiLasso/README.md`, `docs/project-info/implementation-status.md`, `docs/architecture/BFMCS_ARCHITECTURE.md` | 2 each |
| 8 further READMEs + `docs/user-guide/tutorial.md`, `docs/user-guide/architecture.md`, `docs/reference/API_REFERENCE.md`, `docs/project-info/tactic-registry.md` | 1 each |
| `typst/chapters/*.typ` | 11 (plus the 5 stale `sorryAx` sites in `FormalFoundations.typ`) |

**The gap that matters.** `Metalogic.lean` asserts `SORRY-FREE` for **37 distinct declarations**
(extracted from the backticked names within three lines of each `SORRY-FREE` marker):

```
bl_not_derivable_nil_bot, bl_not_derivable_nil_bot_discrete, bl_soundness,
bl_soundness_dedekind, bl_soundness_dense, bl_soundness_discrete, ceb_backward,
cec_backward, ced_backward, cef_backward, companionChronicle, completeness,
completeness_base, completeness_dedekind, completeness_dense, completeness_discrete,
consequence_completeness_base, consequence_completeness_dedekind,
consequence_completeness_dense, consequence_completeness_discrete, decide,
dedekind_consequence_not_compact, derivable_translate, discrete_consequence_not_compact,
galoisClosed_isDiscrete, galoisClosed_mod, galoisClosed_of_indicator,
galoisClosed_sat_dense, kampPriorExpressiveCompleteness, soundness,
soundness_base_consequence, soundness_dedekind, soundness_dense,
soundness_dense_consequence, soundness_discrete, strongCompletenessDedekind_refuted,
strongCompletenessDiscrete_refuted
```

**Machine-pinned by the build: 8 declarations.** C2 (`check-module-invariants.sh:145-148`)
pins `completeness`, `completeness_dense`, `completeness_discrete`, `countermodel_dense`.
C14 (`:771-774`) pins `sound_of_isValid`, `completeness_dedekind`, `strongCompletenessBase`,
`strongCompletenessDense`.

So **33 of 37 status claims in the ledger are prose-only**, unverified by any gate, and
restated in one to three further places each. That is the mechanism by which
`typst/FormalFoundations.typ` (E-02) and `README.md:167` (E-01) went stale without any check
firing.

**Recommended single-source-of-truth policy** — see §5.1.

### 3b. doc-gen4 coverage table (Q3)

Scope as specified: `Metalogic/*.lean`, `Metalogic/{SoundnessLemmas,Core,Independence}/**`,
`Semantics/**`. "mod" = module docstring `/-!` in the first 60 lines. "decl" counts public
`theorem|lemma|def|abbrev|structure|inductive|instance|class`; "doc" counts those immediately
preceded by a `/-- … -/` block.

| File | mod | decl | doc | % |
|------|-----|-----:|----:|--:|
| `Metalogic/Algebraic.lean` | Y | 0 | 0 | — |
| `Metalogic/BXCanonical.lean` | Y | 0 | 0 | — |
| `Metalogic/BaseLanguageSoundness.lean` | Y | 19 | 19 | 100% |
| `Metalogic/Bundle.lean` | Y | 0 | 0 | — |
| `Metalogic/Compactness.lean` | Y | 6 | 6 | 100% |
| `Metalogic/Conservativity.lean` | Y | 10 | 8 | 80% |
| `Metalogic/Core.lean` | Y | 0 | 0 | — |
| `Metalogic/Decidability.lean` | Y | 0 | 0 | — |
| `Metalogic/DedekindNonCompactness.lean` | Y | 25 | 24 | 96% |
| `Metalogic/DiscreteNonCompactness.lean` | Y | 16 | 11 | **69%** |
| `Metalogic/Independence.lean` | Y | 0 | 0 | — |
| `Metalogic/SetConsequence.lean` | Y | 54 | 50 | 93% |
| `Metalogic/Soundness.lean` | Y | 79 | 74 | 94% |
| `Metalogic/SoundnessLemmas.lean` | Y | 0 | 0 | — |
| `Metalogic/SpWitness.lean` | Y | 4 | 4 | 100% |
| `Metalogic/StrongCompleteness.lean` | Y | 36 | 34 | 94% |
| `Metalogic/TMCompletenessReduction.lean` | Y | 7 | 6 | 86% |
| **`Metalogic/WeakCanonical.lean`** | **N** | 0 | 0 | — |
| `Metalogic/Z1Countermodel.lean` | Y | 17 | 16 | 94% |
| `SoundnessLemmas/CoValidity.lean` | Y | 3 | 3 | 100% |
| `SoundnessLemmas/Core.lean` | Y | 3 | 3 | 100% |
| `SoundnessLemmas/DenseValidity.lean` | Y | 39 | 38 | 97% |
| `SoundnessLemmas/FrameClassVariants.lean` | Y | 5 | 5 | 100% |
| `SoundnessLemmas/Separability.lean` | Y | 8 | 8 | 100% |
| `Core/DeductionTheorem.lean` | Y | 13 | 13 | 100% |
| `Core/MCSProperties.lean` | Y | 10 | 10 | 100% |
| `Core/MaximalConsistent.lean` | Y | 24 | 24 | 100% |
| `Core/RestrictedMCS/Basic.lean` | Y | 19 | 19 | 100% |
| `Independence/ClockFrame.lean` | Y | 20 | 13 | **65%** |
| `Independence/CoNotPriorU.lean` | Y | 38 | 30 | 79% |
| `Independence/LexIntWitness.lean` | Y | 11 | 11 | 100% |
| `Independence/LoopingDuration.lean` | Y | 14 | 14 | 100% |
| `Independence/RationalWitness.lean` | Y | 9 | 8 | 89% |
| `Independence/StaticFrame.lean` | Y | 15 | 15 | 100% |
| `Semantics/BLSchemaValidity.lean` | Y | 5 | 5 | 100% |
| `Semantics/BLTruth.lean` | Y | 15 | 14 | 93% |
| `Semantics/BLValidity.lean` | Y | 29 | 29 | 100% |
| `Semantics/Correspondence/DurationFrames.lean` | Y | 22 | 17 | 77% |
| `Semantics/Correspondence/FwdRec.lean` | Y | 3 | 3 | 100% |
| `Semantics/Correspondence/FwdRecBridge.lean` | Y | 12 | 11 | 92% |
| **`Semantics/Correspondence/FwdRecPeriodicity.lean`** | Y | 20 | 9 | **45%** |
| `Semantics/Correspondence/Galois.lean` | Y | 13 | 13 | 100% |
| `Semantics/Correspondence/Indicator.lean` | Y | 5 | 5 | 100% |
| `Semantics/DurationClassification.lean` | Y | 10 | 9 | 90% |
| `Semantics/Extension/Admissible.lean` | Y | 11 | 11 | 100% |
| `Semantics/Extension/Constraint.lean` | Y | 13 | 12 | 92% |
| `Semantics/Extension/Extension.lean` | Y | 12 | 8 | 67% |
| `Semantics/Extension/PeriodicExtension.lean` | Y | 8 | 8 | 100% |
| `Semantics/Extension/Step.lean` | Y | 2 | 1 | 50% |
| `Semantics/FrameAxioms.lean` | Y | 6 | 6 | 100% |
| `Semantics/FrameClassValidity.lean` | Y | 2 | 2 | 100% |
| `Semantics/FrameProperty.lean` | Y | 7 | 7 | 100% |
| `Semantics/IntNormalForm.lean` | Y | 26 | 20 | 77% |
| `Semantics/IntTransfer.lean` | Y | 11 | 11 | 100% |
| **`Semantics/LexCarrier.lean`** | Y | 5 | 2 | **40%** |
| `Semantics/PartialHistory.lean` | Y | 7 | 7 | 100% |
| `Semantics/PartialHistoryOrder.lean` | Y | 15 | 13 | 87% |
| `Semantics/ShiftSet.lean` | Y | 24 | 22 | 92% |
| `Semantics/TaskFrame.lean` | Y | 89 | 82 | 92% |
| `Semantics/TaskModel.lean` | Y | 6 | 6 | 100% |
| `Semantics/TemporalOrder.lean` | Y | 3 | 3 | 100% |
| `Semantics/Truth.lean` | Y | 18 | 18 | 100% |
| **`Semantics/Ultraproduct/Carrier.lean`** | Y | 22 | 9 | **41%** |
| `Semantics/Ultraproduct/IndexFilter.lean` | Y | 6 | 4 | 67% |
| `Semantics/Ultraproduct/Los.lean` | Y | 2 | 2 | 100% |
| `Semantics/Ultraproduct/ShiftSetProduct.lean` | Y | 4 | 3 | 75% |
| `Semantics/Validity.lean` | Y | 64 | 60 | 94% |
| `Semantics/WorldHistory.lean` | Y | 27 | 26 | 96% |
| **TOTAL** | **67/68** | **1,028** | **924** | **90%** |

**Flagship declarations — doc comment present and paper cross-reference?** All 41 names I
checked resolve. Doc-comment status of the flagship set is uniformly good; the recurring gap is
the **paper cross-reference**, which is present in the Correspondence layer
(`app:dense`/`app:discrete`/`app:complete`, `def:frame-properties`, `def:TMplus-f` all cited)
and in `Semantics/` (`def:frame`, `def:world-history`, `def:constraints`, `def:BL-semantics`),
but is **absent from the completeness/compactness terminus set**: `completeness_dedekind`,
`consequence_completeness_*`, `strongCompletenessBase/Dense`, `discrete_consequence_not_compact`,
`dedekind_consequence_not_compact` carry rich prose but no `cor:tm-completeness` /
`thm:TM-soundness` anchor at the declaration site. That is exactly the hop a paper reader needs.

Files below 70% and worth a documentation pass: `Correspondence/FwdRecPeriodicity.lean` (45%),
`Semantics/LexCarrier.lean` (40%), `Semantics/Ultraproduct/Carrier.lean` (41%),
`Semantics/Extension/Step.lean` (50%), `Independence/ClockFrame.lean` (65%),
`Semantics/Extension/Extension.lean` (67%), `Ultraproduct/IndexFilter.lean` (67%),
`Metalogic/DiscreteNonCompactness.lean` (69%).

---

## 4. Findings

### E-01. `README.md` contradicts the status ledger on Dedekind strong completeness
- **Severity**: Critical
- **Category**: documentation
- **Anchors**: `README.md:167`; `README.md:240-241`; `FormalSystem/Metalogic.lean:116-120`;
  `FormalSystem/Metalogic/SetConsequence.lean:601,609`;
  `FormalSystem/Metalogic/DedekindNonCompactness.lean:431,459`
- **Description**: `README.md:167` states: "**Dedekind** — **not stated**, and unavailable on
  the primary source's own terms. … this tree contains no `CompactDedekind` definition and no
  refuting theorem, so the class is *unproved* rather than refuted." Ground truth:
  `SetConsequence.lean:601` is `def StrongCompletenessDedekind : Prop := StrongCompleteness
  FrameClass.Dedekind` and `:609` is `def CompactDedekind : Prop := Compact FrameClass.Dedekind`;
  `DedekindNonCompactness.lean:431` is `theorem dedekind_consequence_not_compact : ¬
  CompactDedekind` and `:459` is `theorem strongCompletenessDedekind_refuted : ¬
  StrongCompletenessDedekind`. `Metalogic.lean:116-120` describes exactly this and calls the
  class "**refuted**, like Discrete". `README.md:240-241` repeats the stale "open" reading.
  `git log` shows the refutation landed in commit `e5b55f5f4` at 2026-09-01 17:52 while
  `README.md` was last touched by commit `6d61afa35` at 2026-09-01 14:36 for an unrelated
  identifier rename — the front page was simply never updated afterwards.
- **Impact**: The repository's front page understates a machine-checked negative result, and a
  reviewer comparing `README.md` against `Metalogic.lean` sees the project contradicting itself
  about a headline metalogical fact. This is the single most damaging documentation defect for
  publication.
- **Recommendation**: Rewrite `README.md:163-168` so the Dedekind bullet matches
  `Metalogic.lean:116-120`: refuted, with `dedekind_consequence_not_compact` and
  `strongCompletenessDedekind_refuted` named and `DedekindNonCompactness.lean` cited; delete the
  "(open …)" parenthetical at `:240-241`. Better still, stop restating it — see E-14.
- **Effort**: S
- **Depends on**: —

### E-02. `typst/FormalFoundations.typ` reports a `sorryAx` and a live `sorry` that no longer exist
- **Severity**: Critical
- **Category**: documentation
- **Anchors**: `typst/FormalFoundations.typ:697`, `:701`, `:993`, `:999-1004`, `:1543`;
  `scripts/check-module-invariants.sh:145` (C2 baseline);
  `FormalSystem/Metalogic/WeakCanonical/GroupModel/CountermodelBase.lean:143`
- **Description**: The "Machine-Checked Status" table at `:993` records
  ``[`completeness`], … [same, plus `sorryAx`], [*yes*]``, and `:999-1001` reads "Outside
  `Boneyard/`, the development contains exactly one structural `sorry`, and it is the source of
  the single `sorryAx` above: `countermodel_discrete` in `WeakCanonical/Transfer.lean`. It is
  dead code." Ground truth: C2's baseline pins `completeness` at exactly
  `[propext, Classical.choice, Quot.sound]`; C3 asserts the structural sorry inventory is zero;
  `countermodel_discrete` is a discharged theorem at `GroupModel/CountermodelBase.lean:143`, not
  in `Transfer.lean`. Three further sites repeat it: `:697` (footnote "The `sorryAx` traces to a
  single dependency"), `:701` ("with one proof obligation outstanding. Its axiom report contains
  `sorryAx`"), `:1543` (``[`completeness`, one `sorryAx`]``).
- **Impact**: This is a **compiled publication artifact** (`typst/FormalFoundations.pdf` exists
  in-tree). It tells readers the Base-frame completeness theorem is not fully proved when it is.
  A reviewer who checks `#print axioms` will find the paper understating the result, which reads
  as carelessness rather than conservatism.
- **Recommendation**: Regenerate the status table from `scripts/typst-status-counts.sh` output
  rather than hand-maintaining it — the generator already exists and already writes
  `typst/generated/status.typ`. Extend it to emit the per-declaration axiom table, `#include`
  that, and delete the five hand-written sites. As an immediate fix, correct all five.
- **Effort**: M
- **Depends on**: —

### E-03. `FormalSystem/README.md` and `Syntax/README.md` describe a superseded `Formula` type
- **Severity**: Critical
- **Category**: naming
- **Anchors**: `FormalSystem/README.md:51-58`, `:68-69`; `FormalSystem/Syntax/README.md:19`;
  `FormalSystem/Syntax/Formula.lean:96,106,147,157,167,177`; `README.md:33-51`
- **Description**: `FormalSystem/README.md`'s "Primitive Operators" table lists
  `Hφ | all_past φ` and `Gφ | all_future φ` as primitives and does not mention `untl` or `snce`
  at all. `Syntax/README.md:19` lists primitives as "`atom`, `bot`, `imp`, `box`, `all_past`,
  `all_future`". The actual `Formula` inductive has six constructors — `atom`, `bot`, `imp`,
  `box`, `untl` (`Formula.lean:96`), `snce` (`:106`) — and `allPast`/`allFuture` are derived
  `def`s at `:177`/`:167`. The snake_case identifiers `all_past`, `all_future`, `some_past`,
  `some_future` **do not exist anywhere in the live tree** as declarations. The top-level
  `README.md:33-51` has the correct 5-primitive presentation *and* a careful argument-order note,
  so the repository states two incompatible object languages in two READMEs one directory apart.
- **Impact**: A reader following `FormalSystem/README.md` will write `Formula.all_past φ` and
  get a compile error, and will misread every temporal axiom and truth clause in the tree. The
  Until/Since primitivity is the substantive design choice of the whole formalization.
- **Recommendation**: Replace both tables with the `README.md:33-69` version (5 primitives +
  derived table with the guard-first/event-first note). Then delete the duplicate rather than
  maintaining three copies — see E-13.
- **Effort**: S
- **Depends on**: —

### E-04. `Metalogic.lean`'s module-structure tree is comprehensively stale and contradicts `Metalogic/README.md`
- **Severity**: High
- **Category**: documentation
- **Anchors**: `FormalSystem/Metalogic.lean:224-256`; `FormalSystem/Metalogic/README.md:12-18`
- **Description**: Drift rows 21–31. Every file count in the tree at `:231-251` is wrong:
  Bundle 12→15, BXCanonical 20→28, Chronicle 8→14, WeakCanonical 135→179, Kamp 99→116,
  Decidability 19→**62**, SoundnessLemmas 3→5. The block also asserts at `:227-228` that counts
  "exclude BOTH Boneyards (there are two -- see `Metalogic/README.md`)", and at `:240` that
  `Kamp/` "has its OWN local `Boneyard/`" — both flatly contradicted by
  `Metalogic/README.md:12-18` ("Archived code lives in exactly one place … B0 now asserts the
  archive-directory count is exactly 1") and by `find FormalSystem -type d -name Boneyard` → 1.
  The tree further omits `Independence/`, `Core/RestrictedMCS/`, and three live `WeakCanonical/`
  subdirectories, and its aggregator list at `:249` omits `Independence.lean` even though
  `Metalogic.lean:14` imports it.
- **Impact**: This is the top of the metalogic module and the first thing doc-gen4 renders for
  `FormalSystem.Metalogic`. It is the repository's most-read docstring and it is wrong in a
  dozen independent ways, including a self-contradiction the invariant script was specifically
  built to prevent.
- **Recommendation**: Delete `Metalogic.lean:224-256` entirely. A module docstring should not
  carry a directory census; that is `Metalogic/README.md`'s job (and even there it should be
  generated — E-14). Replace with three sentences of narrative plus a pointer to
  `Metalogic/README.md` and `scripts/check-module-invariants.sh`.
- **Effort**: S
- **Depends on**: E-14

### E-05. `Metalogic/README.md` file/line inventory has drifted across 19 cells
- **Severity**: High
- **Category**: documentation
- **Anchors**: `FormalSystem/Metalogic/README.md:6-7`, `:31-34`, `:132`, `:136`, `:142`, `:146`,
  `:148`, `:151`, `:153`, `:174-175`, `:182-191`, `:211-212`
- **Description**: Drift rows 1–20. Headline "**314 live `.lean` files** (227,081 lines)" vs 323
  / 229,930. "The eight directories total 314 files" vs 304 (the eight subdirectories) or 323
  (with the 19 loose files) — the sentence is wrong under either reading. `Independence/` is
  listed at 3 files / 1,097 lines but has 6 / 1,883. `SoundnessLemmas/` at 3,016 lines contradicts
  `SoundnessLemmas/README.md:13-17`, whose own per-file table sums to the correct 2,487. Nine
  further line counts are off. Most self-defeating: `:136` says "**Ten** loose files in
  `Metalogic/` are not aggregators" while the table immediately below it, `:139-151`, lists
  **eleven** rows — and eleven is correct (19 loose `.lean` − 8 aggregators).
- **Impact**: This document explicitly positions itself as the authoritative map ("It is the
  correct way to re-derive any count in this document", `:322`) and instructs the reader "Do not
  hand-roll the count". It then hand-rolls ~20 counts, all of them wrong. The credibility cost
  exceeds the informational value of the numbers.
- **Recommendation**: Generate this inventory. `scripts/check-module-invariants.sh` C7 already
  computes the live inventory; add a `--emit-inventory` mode that writes a markdown table, and
  replace §"Directory Inventory", §"Aggregator Convention" and §"Inside …" with an
  `<!-- BEGIN GENERATED -->` block. Fix "Ten" → "Eleven" immediately regardless.
- **Effort**: M
- **Depends on**: E-14

### E-06. Nine "Last verified" dates predate the directory's most recent change by 1–3 months
- **Severity**: Medium
- **Category**: documentation
- **Anchors**: `FormalSystem/README.md:362` (2026-08-25 / dir 2026-09-01);
  `Syntax/README.md:34` (2026-05-29 / 2026-08-17); `ProofSystem/README.md:86` (2026-05-29 /
  2026-08-25); `Semantics/README.md:67` (2026-05-29 / 2026-09-01); `Metalogic/README.md:341`
  (2026-08-26 / 2026-09-01); `Metalogic/Core/README.md:162` (2026-05-29 / 2026-08-25);
  `Theorems/README.md` (2026-05-29 / 2026-09-01); `Automation/README.md` (2026-05-29 /
  2026-08-31); missing entirely in `Metalogic/Bundle/README.md`,
  `Metalogic/Algebraic/README.md`, `FormalSystem/Examples/README.md`
- **Description**: Compared each README's `Last verified` stamp against
  `git log -1 --format=%cs -- <its directory>`. Eight are stale, three absent.
  `scripts/readme-lint.sh` Check 4 reports missing stamps but is explicitly **not gated**
  (`readme-lint.sh:30-36`), and it does not compare a present stamp against the directory's
  last-change date at all.
- **Impact**: A stamp that is three months behind the code is worse than no stamp: it certifies
  content that has since changed. Every stale drift row in §2 sits under one of these stamps.
- **Recommendation**: Extend `readme-lint.sh` Check 4 to compare the stamp against
  `git log -1 --format=%cs -- <dir>` and **report** (not gate) any README whose stamp is older.
  Add the three missing stamps. Consider making the stamp itself generated by the postflight
  hook that touches a directory.
- **Effort**: S
- **Depends on**: —

### E-07. Contents tables omit live modules; `Semantics/README.md` misses three
- **Severity**: Medium
- **Category**: organization
- **Anchors**: `FormalSystem/Semantics/README.md:9-27`; `ls FormalSystem/Semantics/*.lean`
- **Description**: `Semantics/` has 19 loose `.lean` files; the Contents table lists 16.
  Missing: `FrameClassValidity.lean` (the single documented `Semantics → ProofSystem` seam, and
  therefore one of the most architecturally significant files in the directory),
  `FrameProperty.lean` (`TaskFrame.IsDense/IsDiscrete/IsComplete` — the predicates the
  Correspondence layer is stated over), and `TemporalOrder.lean`. All three are described in
  `FormalSystem/Semantics.lean`'s docstring, so the information exists; it just is not in the
  README a reader lands on. `scripts/readme-lint.sh` Check 2 detects exactly this ("~110 such
  warnings") and is deliberately not gated.
- **Impact**: A reader cannot find the frame-class semantics seam from the directory README.
- **Recommendation**: Add the three rows. Longer term, generate the Contents table from `ls` +
  each file's `/-!` first line, which would close all ~110 `readme-lint` warnings at once.
- **Effort**: S
- **Depends on**: —

### E-08. `docs/README.md` documents a doc-gen4 build that cannot run
- **Severity**: High
- **Category**: api-ergonomics
- **Anchors**: `docs/README.md:271-279`; `lakefile.lean` (whole file); `lake-manifest.json`
- **Description**: `docs/README.md:273-279` says "Generate LEAN API documentation with doc-gen4:
  `lake build :docs` … Documentation will be in `.lake/build/doc/`". `lakefile.lean` contains no
  `require doc-gen4`, defines no `:docs` facet, and `grep -c doc-gen lake-manifest.json` returns
  0. The command fails. `docs/development/DIRECTORY_README_STANDARD.md:353-393` builds a whole
  section on the doc-gen4 division of labour, so the project intends to ship API docs.
- **Impact**: The 90%-complete docstring corpus — the strongest documentation asset in the
  repository — is not published anywhere. For a formalization paper, a browsable API is the
  primary way a referee checks a theorem statement.
- **Recommendation**: Add `require «doc-gen4» from git "https://github.com/leanprover/doc-gen4"
  @ "v4.33.0-rc1"` (matching `lean-toolchain`) and a CI job that builds and publishes to GitHub
  Pages. Then make `README.md` link the generated docs above the "Documentation" section. If
  doc-gen4 is deliberately not wanted, delete the recipe rather than leaving a broken one.
- **Effort**: M
- **Depends on**: —

### E-09. The C14 stale-axiom-count tripwire has a regex gap that lets two stale counts through
- **Severity**: Medium
- **Category**: documentation
- **Anchors**: `scripts/check-module-invariants.sh:730-733`;
  `docs/project-info/implementation-status.md:36`; `docs/user-guide/examples.md:579`
- **Description**: C14(i) scans for `\b(14|21|42|44)[[:space:]]+(axiom|constructor)`. The two
  surviving stale counts both interpose a word: "All **21 TM axiom** schemas organized into base
  (17), dense (1), and discrete (3) layers" and "one of the **14 TM axiom** schemas". Neither
  matches, so C14 passes while both stale claims stand. Ground truth is 45 constructors split
  37 / 2 / 3 / 3, per `Axiom.minFrameClass`. The comment at `:721-725` notes that C14's original
  markdown-only scope is "exactly why SIX '42 axiom constructors' claims survived a 42 → 45
  change untouched" — the same failure mode has recurred one word to the left.
- **Impact**: Two documents give the reader a 21- or 14-schema axiom system for a 45-constructor
  logic, and the gate that exists to catch this reports green.
- **Recommendation**: Widen the pattern to
  `\b(14|21|42|44)[[:space:]]+([A-Za-z⁺+]+[[:space:]]+)?(axiom|constructor|schema)` and keep the
  existing `grep -i axiom` precision guard. Fix both documents.
- **Effort**: S
- **Depends on**: —

### E-10. `typst/generated/status.typ` prints a live-looking sorry count for an archived subtree
- **Severity**: Medium
- **Category**: documentation
- **Anchors**: `typst/generated/status.typ:21-30`; `scripts/typst-status-counts.sh:108-117,216`
- **Description**: The generated file sets `sorry-total-excl-boneyard = 0` and then emits a
  `sorry-table` row `("WeakCanonical/", 4)`. The generator's own comment (`:108-112`) explains
  that the 4 live in the *relocated* archive `Boneyard/Kamp/KampWeakCanonical/`, and the row is
  populated from `SORRY_WEAKCANONICAL_ALL`. The label in the rendered book does not say so.
- **Impact**: A reader of the compiled book sees "WeakCanonical/ … 4" and concludes the largest
  live subtree carries four open obligations. It carries zero.
- **Recommendation**: Relabel the row `WeakCanonical/ (live + relocated Kamp archive)`, or split
  it into two rows — `WeakCanonical/ (live)` 0 and `Boneyard/Kamp/KampWeakCanonical/` 4 — which
  the script already computes separately (`SORRY_WEAKCANONICAL_LIVE`, `SORRY_KAMP_BONEYARD`).
- **Effort**: S
- **Depends on**: —

### E-11. `Semantics.lean`'s truth-clause and correspondence tables describe a superseded signature
- **Severity**: High
- **Category**: documentation
- **Anchors**: `FormalSystem/Semantics.lean` ("Truth Clauses" and "Correspondence" tables,
  ≈`:150-190`); `FormalSystem/Semantics/Truth.lean:163-174`; `README.md:82`, `:91`
- **Description**: The docstring's Truth Clauses table gives `TruthAt M τ t ht φ` (five
  arguments including a domain proof), a `□φ` clause reading `∀ σ, σ.domain t → …`, and rows for
  `Hφ` and `Gφ`. Ground truth (`Truth.lean:163-174`): `def TruthAt (M : TaskModel F)
  (τ : WorldHistory F) (t : F.Duration) : Formula → Prop` — four arguments, no `ht`; the `box`
  clause is `∀ (σ : WorldHistory F), σ.IsTotal → TruthAt M σ t φ`; and there are **no `H`/`G`
  clauses**, because the recursion is on `untl`/`snce`. The domain proof moved *inside* the
  `atom` clause (`∃ (ht : τ.domain t), …`). The Correspondence table additionally lists Nullity
  as a frame field, which `README.md:82` says is derived, not an axiom.
- **Impact**: Same class of defect as E-03 — the aggregator docstring for the semantics layer,
  which doc-gen4 renders as the module's front page, describes a different semantics. The `□`
  clause discrepancy (`σ.domain t` vs `σ.IsTotal`) is a genuine mathematical difference: total
  histories are the paper's `H_F`, and quantifying over merely-defined-at-`t` histories would be
  a different modality.
- **Recommendation**: Rewrite both tables from `Truth.lean:163-174` verbatim. Add the derived
  `H`/`G` clauses as a clearly-marked *derived* block, and reconcile the Nullity row with
  `README.md:82`.
- **Effort**: S
- **Depends on**: —

### E-12. History and process prose in module docstrings and READMEs
- **Severity**: Medium
- **Category**: documentation
- **Anchors**: `FormalSystem/Metalogic/README.md:15`, `:118`, `:166`, `:221`, `:252`, `:272`,
  `:275-280`; `FormalSystem/README.md:11-33`, `:180-191`, `:339-341`;
  `FormalSystem/Metalogic.lean:216-218`, `:227-228`, `:253-256`;
  `FormalSystem/Metalogic/WeakCanonical/Kamp/README.md:11`;
  `FormalSystem/Automation/README.md:45`; `README.md:200-207`;
  `FormalSystem/Metalogic/Decidability/README.md:18`;
  `FormalSystem/Metalogic/Decidability/Verified/README.md:68`
- **Description**: A grep for change-log phrasing (`used to (be|live|sit)`, `no longer`,
  `was moved`, `were consolidated`, `an earlier revision`, `the former sole`,
  `previously papered`, `retired as`, `recorded rather than half-done`, `this block previously
  did drift`) returns **19 hits on live documentation surfaces**, several of them multi-paragraph.
  Representative: `FormalSystem/README.md:11-33` is a 23-line section titled "Counting Live
  Files: Exclude the Archive" whose first paragraph is entirely about a past miscount ("It used
  to live in two places … repeated past descriptions of this repository's size were wrong for
  exactly that reason"); `Metalogic/README.md:106-118` is a section titled "The declined regroup,
  and its evidence"; `Metalogic/README.md:275-280` narrates the migration of
  `countermodel_discrete` out of `Transfer.lean`; `FormalSystem/README.md:180-191` and
  `README.md:196-198` each devote a paragraph to what "an earlier revision of this file said".
- **Impact**: Publication-quality documentation states the current mathematics. A reader
  encountering "this block previously did drift" learns something about the repository's process
  rather than about bimodal logic, and the process narration is itself a maintenance liability —
  three of the history paragraphs are now *themselves* stale (E-04's "there are two Boneyards",
  E-02's `sorryAx` narrative).
- **Recommendation**: Move the decision narratives to `docs/decisions/` as dated ADRs — the
  repository already has `docs/architecture/ADR-001…`, `ADR-004`, so the mechanism exists.
  Specifically: `Metalogic/README.md`'s "Why There Is No Physical Regroup" + "The declined
  regroup" → `docs/decisions/metalogic-no-physical-regroup.md`; the archive-consolidation
  narrative → `docs/decisions/single-boneyard.md`; the
  `validity_decidable`/`validity_has_decision_procedure` retirement (told in **four** places:
  `README.md:200-207`, `FormalSystem/README.md:339-341`, `Decidability/README.md:18`,
  `Decidability/Verified/README.md:68`) → one ADR, cited by pointer from all four. Leave the
  *current* invariant statement in place; cut the past tense.
- **Effort**: M
- **Depends on**: —

### E-13. Whole paragraphs duplicated near-verbatim between `README.md` and `Metalogic.lean`
- **Severity**: Medium
- **Category**: documentation
- **Anchors**: `README.md:161-168` ≈ `FormalSystem/Metalogic.lean:99-120`;
  `README.md:229-245` ≈ `Metalogic.lean:129-144`; `README.md:247-251` ≈ `Metalogic.lean:145-149`;
  `FormalSystem/README.md:180-191` ≈ `README.md:196-198`;
  `Semantics/Correspondence/README.md:8-12` ≈ `Metalogic.lean:130-134`
- **Description**: A whitespace-normalized substring search confirms four distinct multi-sentence
  blocks present in both `README.md` and `FormalSystem/Metalogic.lean`: the
  "single mechanism by which closure is shown: exhibit one formula valid on precisely the class's
  members" sentence, the "expressively complete relative to monadic first-order logic **for Prior
  structures**" paragraph, the "Closed-form characterizations of `Mod (AxiomSet .Discrete)` and
  `Mod (AxiomSet .Dedekind)` remain open and are not promised" sentence, and the
  "inter-derivable with the corresponding weak form through the deduction theorem" terminology
  caveat. The TM⁺_c paragraph appears twice more (`FormalSystem/README.md:180-191` and
  `README.md:196-198`) in independently-worded but semantically identical form.
- **Impact**: This duplication is the *transmission mechanism* for E-01: the strong-completeness
  paragraph was updated in `Metalogic.lean` and not in `README.md`, and nothing detected the
  divergence. Every duplicated paragraph is a future E-01.
- **Recommendation**: Designate `FormalSystem/Metalogic.lean` as the owner of per-theorem
  mathematical status (it is closest to the code and is what doc-gen4 renders) and reduce
  `README.md`'s corresponding sections to a two-sentence summary plus a link. Add a
  check-module-invariants check (C16) that fails if a designated "owned" paragraph appears in
  more than one file, using the same whitespace-normalized comparison.
- **Effort**: M
- **Depends on**: E-14

### E-14. No single source of truth for counts or per-theorem status; 33 of 37 status claims are prose-only
- **Severity**: High
- **Category**: organization
- **Anchors**: `FormalSystem/Metalogic.lean` (17 `SORRY-FREE` markers, 37 declarations named);
  `scripts/check-module-invariants.sh:145-148` (C2, 4 declarations), `:771-774` (C14, 4
  declarations); the §2 drift table (≈40 stale numeric cells across 4 documents)
- **Description**: See §3a. `Metalogic.lean` asserts sorry-freeness and an exact axiom set for
  37 declarations; the build pins 8. Independently, ~40 file/line counts are hand-maintained
  across `README.md`, `FormalSystem/README.md`, `Metalogic/README.md` and `Metalogic.lean`, and
  essentially all have drifted — while `check-module-invariants.sh` C7 already computes the live
  inventory and `scripts/typst-status-counts.sh` already generates `typst/generated/status.typ`
  from the tree. The generation pattern is established; it has simply not been applied to the
  markdown surfaces.
- **Impact**: This is the root cause of E-01, E-02, E-04, E-05, E-09 and E-13. Individually
  fixing those leaves the mechanism intact.
- **Recommendation**: Adopt the policy in §5.1: (a) machine-checked C2 baseline is the sole
  authority for axiom sets — extend it from 4 to all ~20 flagship declarations, or add a C16
  covering the rest; (b) exactly one human-readable ledger (`docs/theorem-index.md`, §5.2) whose
  status column is *generated* from the same `#print axioms` run; (c) every other surface carries
  a pointer, never a restatement; (d) all directory/file/line counts move into
  `<!-- BEGIN GENERATED -->` blocks emitted by `check-module-invariants.sh --emit-inventory`.
- **Effort**: L
- **Depends on**: —

### E-15. No theorem index: a paper reader cannot get from a result to a Lean file in ≤ 2 hops
- **Severity**: High
- **Category**: navigation
- **Anchors**: absent — `find . -iname "*theorem-index*" -o -iname "*results-ledger*"` returns
  nothing; nearest existing surfaces are `docs/reference/API_REFERENCE.md:648-666` (4 rows,
  stale header date `:4` = 2026-01-11) and `typst/FormalFoundations.typ:986-996` (5 rows, stale
  per E-02)
- **Description**: To locate `completeness_dedekind` from the paper's `cor:tm-completeness`, a
  reader must know (i) that the Dedekind class is the paper's TM⁺_c — stated in prose at
  `README.md:196` and `FormalSystem/README.md:180`, not in any table; (ii) that the theorem lives
  in `Metalogic/StrongCompleteness.lean`, not `BXCanonical/`, which is where
  `FormalSystem/README.md:301` sends them for "Completeness"; and (iii) that it is stated against
  `ValidDedekindDense` rather than `ValidDedekind`. That is three or four hops through prose.
  `typst/` does have a `#leansrc(module, name)` macro (`typst/template.typ:97-98`) that emits the
  module-plus-name pair, and `scripts/typst-sync-check.sh` verifies those names resolve — so a
  paper→Lean mapping partially exists, but it is one-directional, lives only in the typst
  sources, and has no Lean→paper counterpart in the repository.
- **Impact**: The primary navigation need of a referee is unserved. This is the single highest-
  value missing artifact for publication.
- **Recommendation**: Create `docs/theorem-index.md` with the schema and rows in §5.2; link it
  from `README.md` above "Documentation" and from `FormalSystem/Metalogic/README.md`. Generate
  its "Axioms" column from a `#print axioms` run so it cannot drift.
- **Effort**: M
- **Depends on**: E-14

### E-16. Missing publication packaging: `CITATION.cff`, `docs/ARCHITECTURE.md`, a "check the main theorems" recipe
- **Severity**: Medium
- **Category**: documentation
- **Anchors**: `ls CITATION*` → absent; `find . -iname "*ARCHITECTURE*"` →
  `docs/architecture/` (ADR catalog, 69 lines, no layer diagram),
  `docs/architecture/BFMCS_ARCHITECTURE.md` (proof-specific), `docs/user-guide/architecture.md`;
  `README.md:284-305` (BibTeX present); `.github/workflows/ci.yml` (present);
  `README.md:3` (badge present); `CLAUDE.md` (Lean/Mathlib version statement present)
- **Description**: What exists: CI + badge, a BibTeX block, an accurate Lean/Mathlib version
  statement (`CLAUDE.md`, with a re-derivation recipe), an Apache-2.0 `LICENSE`, and a Boneyard
  policy stated at `FormalSystem/README.md:11-33` and `Boneyard/README.md`. What is missing:
  (i) a `CITATION.cff` — GitHub renders a "Cite this repository" widget from it and Zenodo/DOI
  workflows consume it; the BibTeX at `README.md:299-304` has `year = {2025}` while the article
  entry says `2026`, so even the hand-written citation is internally inconsistent;
  (ii) a `docs/ARCHITECTURE.md` carrying the `Syntax → ProofSystem → Semantics → Metalogic →
  Automation` layer diagram — the layers are enumerated at `FormalSystem/README.md:234-269` but
  as six separate one-row tables with no diagram, and the two known upward edges
  (`Semantics → ProofSystem` via `FrameClassValidity.lean`, and `Decidability → Automation`,
  `Metalogic/README.md:293-308`) are documented in two different places and in neither picture;
  (iii) a copy-pasteable "how to check the main theorems" recipe — `#print axioms` appears
  nowhere in `README.md` as a reader-runnable command, even though C2/C14 run exactly that.
- **Impact**: A referee cannot verify the headline claims without reconstructing the invariant
  script's internals, and cannot cite the artifact in a machine-readable way.
- **Recommendation**: Add `CITATION.cff` (reconcile the year). Add `docs/ARCHITECTURE.md` with
  one diagram, the layer table, and both upward edges named in it. Add a `## Verifying the main
  theorems` section to `README.md` containing a `#print axioms` snippet for the eight
  machine-pinned declarations plus the one-line `bash scripts/check-module-invariants.sh`.
- **Effort**: M
- **Depends on**: E-15

### E-17. `README.md` install recipe `cd`s into a directory the clone does not create
- **Severity**: Medium
- **Category**: api-ergonomics
- **Anchors**: `README.md:150-152`
- **Description**: `git clone https://github.com/benbrastmckie/BimodalLogic.git` followed by
  `cd ProofChecker`. The clone creates `BimodalLogic/`. The `ProofChecker` name survives in
  several other places (`docs/architecture/README.md:6`, the `@software{proofchecker2025}` key at
  `README.md:299`, `CLAUDE.md`'s title), so the repository has two names and the quickstart uses
  the wrong one at the one point where it must be literally correct.
- **Impact**: The very first command a new reader runs fails.
- **Recommendation**: `cd BimodalLogic`. Separately, pick one project name and use it
  consistently, or state the relationship once ("the repository `BimodalLogic` contains the
  `ProofChecker` library").
- **Effort**: S
- **Depends on**: —

### E-18. `Independence/README.md` cites a declaration name that does not exist
- **Severity**: Low
- **Category**: naming
- **Anchors**: `FormalSystem/Metalogic/Independence/README.md:30`;
  `FormalSystem/Metalogic/Independence/CoNotPriorU.lean:327`, `:578`
- **Description**: Key Results lists "`co_not_derives_prior_U` and its companion
  (`CoNotPriorU.lean`)". No such declaration exists. The real pair is
  `co_not_derives_prior_U_gap` (`:327`) and `co_not_derives_prior_U_gap_schema` (`:578`), which
  is how `Theorems/DedekindDerived.lean:49-50,364-366` and `ProofSystem/Axioms.lean:405` cite
  them. This was the only broken declaration name among 41 checked.
- **Impact**: A reader grepping for the cited name finds nothing.
- **Recommendation**: Name both theorems in full. Consider extending
  `scripts/typst-sync-check.sh`'s backtick-name-resolution check (which already does exactly this
  job for `typst/**`) to `FormalSystem/**/*.md` and `docs/**`.
- **Effort**: S
- **Depends on**: —

### E-19. `FormalSystem/README.md` navigation table is missing `Independence/` and denies an existing README
- **Severity**: Low
- **Category**: navigation
- **Anchors**: `FormalSystem/README.md:273-283`; `FormalSystem/BaseLanguage/README.md` (69
  lines); `FormalSystem/Metalogic/Independence/README.md` (57 lines);
  `FormalSystem/Metalogic/README.md:187`
- **Description**: The Submodule Navigation table's last non-archive row reads
  "`BaseLanguage/` | No | Shared base-language definitions (no README yet)" — but
  `FormalSystem/BaseLanguage/README.md` exists (4,092 bytes, dated 2026-08-26). Independently,
  `Metalogic/README.md:187`'s Directory Inventory lists `Independence/` as the only unlinked row
  even though `Metalogic/Independence/README.md` exists and is one of the best-written READMEs
  in the tree.
- **Impact**: Two well-written READMEs are unreachable by navigation.
- **Recommendation**: Update the row to `Yes` with a link; link `Independence/` in
  `Metalogic/README.md:187`. `scripts/readme-lint.sh` Check 1 already knows every directory that
  has a README — have it also report READMEs that no parent README links to.
- **Effort**: S
- **Depends on**: —

### E-20. Terminology: five concepts carry two or more names across live surfaces
- **Severity**: Medium
- **Category**: naming
- **Anchors**: below
- **Description**:
  1. **Saturation vs Spherical.** `README.md:80` names the fourth frame axiom ***Saturation***
     and says "The Lean sources still carry this axiom under its former name *Spherical*
     (`TaskFrame.Spherical`, the `spherical` field of `FrameOver`); renaming them to match is
     pending." Confirmed: `Semantics/TaskFrame.lean:74,110,135-137,154-155` uses *Spherical*
     throughout, and `Semantics.lean`'s docstring likewise. So the axiom has one name in the
     README and another everywhere else. The rename is acknowledged as pending, and the commit
     that most recently touched `README.md` (`6d61afa35`) was the one creating that rename work
     item — so the README currently documents an intent, not the tree.
  2. **Consequence completeness vs strong completeness vs finite-context completeness.** Handled
     carefully and consistently in `README.md:163`, `Metalogic.lean:99-105`,
     `StrongCompleteness.lean`'s docstring, `API_REFERENCE.md:658-662` and
     `FormalFoundations.typ:974-978` — this one is **good**, and is the model the others should
     follow. The one weak point is the file *name* `StrongCompleteness.lean`, which hosts
     `completeness_dedekind` and `consequence_completeness_*` — i.e. the finite-context results
     the document is at pains to say are *not* strong completeness. The actual strong-completeness
     theorems live in `Compactness.lean`.
  3. **Dedekind vs Complete vs DedekindDense.** `FrameClass.Dedekind`, `TaskFrame.IsComplete`,
     `IsDedekind`, `ValidDedekindDense`, `validOn_co_iff_isComplete`, and the paper's
     `app:complete` all name closely-related notions. `Semantics.lean`'s docstring notes the
     "`Dedekind`-not-`Complete` naming deviation" is recorded at its definition site, but no
     single surface tabulates the four names against each other.
  4. **Task frame vs `TaskFrame` vs `FrameOver`.** `TaskFrame` is the total space and
     `FrameOver D` the fibre (`Semantics.lean` docstring, `TaskFrame.lean:50`), but
     `FormalSystem/README.md:120-127` presents "A task frame `(W, T, R)`" with a **three**-tuple
     and the properties "Nullity … and Compositionality", while `README.md:75-82` gives
     `F = (W, D, R)` with **four** axioms and says nullity is derived. Two incompatible
     definitions of the central object.
  5. **`all_past`/`some_past` vs `allPast`/`somePast`.** See E-03.
- **Impact**: (4) and (5) are substantive: a reader is told the frame has two properties in one
  README and four axioms in another. (1) is a known-and-tracked rename. (3) is a real risk for a
  referee reading `cor:tm-completeness`.
- **Recommendation**: Add a short **Notation and naming** table to `docs/theorem-index.md` (§5.2)
  mapping paper term → Lean identifier → defining file, covering at minimum: task frame /
  `TaskFrame` / `FrameOver`; Saturation / `spherical`; dense-and-complete / `FrameClass.Dedekind`
  / `IsDedekind` / `ValidDedekindDense`; TM⁺_c / `FrameClass.Dedekind`; Until / `untl` (guard
  first). Fix (4) by replacing `FormalSystem/README.md:120-127` with the `README.md:75-82` text.
  Consider renaming `StrongCompleteness.lean` → `ConsequenceCompleteness.lean`.
- **Effort**: M
- **Depends on**: E-15

### E-21. Doc-comment coverage falls below 70% in eight files, and one aggregator has no module docstring
- **Severity**: Low
- **Category**: documentation
- **Anchors**: `Semantics/Correspondence/FwdRecPeriodicity.lean` (9/20 = 45%);
  `Semantics/LexCarrier.lean` (2/5 = 40%); `Semantics/Ultraproduct/Carrier.lean` (9/22 = 41%);
  `Semantics/Extension/Step.lean` (1/2 = 50%); `Independence/ClockFrame.lean` (13/20 = 65%);
  `Semantics/Extension/Extension.lean` (8/12 = 67%); `Ultraproduct/IndexFilter.lean` (4/6 = 67%);
  `Metalogic/DiscreteNonCompactness.lean` (11/16 = 69%); and
  `Metalogic/WeakCanonical.lean` — the **only** file in the 68-file scope with no `/-!` module
  docstring
- **Description**: See §3b. Aggregate coverage is 90% (924/1,028), which is strong; these eight
  files plus the one missing module docstring are the whole of the gap in the reviewed scope.
  `Ultraproduct/Carrier.lean` and `FwdRecPeriodicity.lean` matter most: they carry the
  ultraproduct construction behind `compactBase`/`compactDense` and the `Walk`/`MinCyc`
  apparatus behind the density correspondence, both of which the paper discusses.
- **Impact**: In generated API docs these render as bare signatures under otherwise well-
  documented modules.
- **Recommendation**: Add a `/-!` header to `Metalogic/WeakCanonical.lean` (all seven sibling
  aggregators have one). Bring the eight files to ≥ 85%, prioritizing `Ultraproduct/Carrier.lean`
  and `FwdRecPeriodicity.lean`.
- **Effort**: M
- **Depends on**: —

### E-22. Flagship completeness/compactness theorems carry no paper anchor at their declaration site
- **Severity**: Medium
- **Category**: documentation
- **Anchors**: `Metalogic/StrongCompleteness.lean:568,587,658,787,930`;
  `Metalogic/Compactness.lean:143,146,156,163`;
  `Metalogic/DiscreteNonCompactness.lean:249,278`; `Metalogic/DedekindNonCompactness.lean:431,459`
  — contrast with `Semantics/Correspondence/DurationFrames.lean:354,419,485`
  (`app:dense`/`app:discrete`/`app:complete` cited) and `Semantics/TaskFrame.lean:74`
  (`def:frame#Spherical`, verbatim)
- **Description**: The repository has an excellent paper-anchoring convention —
  `specs/paper-definitions-of-record.md` (1,465 lines) pins 47 anchors by `\label{}` name with
  sha256 verification via `scripts/check-paper-definitions.sh`, and the Semantics and
  Correspondence layers cite those anchors in their docstrings. That convention **stops at the
  Metalogic terminus**: the twelve declarations above have long, careful doc comments that never
  name `cor:tm-completeness`, `thm:TM-soundness`, or any other anchor. `typst/FormalFoundations.typ`
  supplies the mapping in the other direction via `#leansrc`, but a reader in the Lean file has
  no way back.
- **Impact**: The `paper theorem → Lean declaration` hop works (through typst); the
  `Lean declaration → paper theorem` hop does not. A referee reading `completeness_dedekind`
  cannot tell which corollary of the paper it discharges without consulting three other files.
- **Recommendation**: Add a one-line `Paper: cor:tm-completeness` (or equivalent) to the doc
  comment of each flagship declaration, using the anchor names already pinned in
  `specs/paper-definitions-of-record.md`. Extend `scripts/check-paper-definitions.sh` (or C15,
  the "paper-anchor integrity" check at `check-module-invariants.sh:807`) to assert that every
  declaration listed in `docs/theorem-index.md` carries one.
- **Effort**: M
- **Depends on**: E-15

---

## 5. Proposed documentation architecture

### 5.1 Single-source-of-truth policy

| Fact class | Owner (authority) | Every other surface |
|---|---|---|
| **Axiom sets / sorry-freeness** per declaration | `scripts/check-module-invariants.sh` C2 + C14 baselines, extended from 8 to the full flagship set | a pointer: "axiom sets are asserted by check C2/C14 of `scripts/check-module-invariants.sh`; run it for the current sets" — the phrasing `Metalogic/README.md:248-253` already uses correctly |
| **Structural sorry inventory** | C3 (asserted zero, by content) | pointer only; **never** a per-directory table (E-10) |
| **File / line / directory counts** | `check-module-invariants.sh --emit-inventory` (new), written into `<!-- BEGIN GENERATED -->` blocks | nothing hand-typed; the four documents in §2 each drop their inventory tables |
| **Per-theorem human-readable status** | **one** ledger: `docs/theorem-index.md` (§5.2), status column generated from the C2/C14 `#print axioms` run | `README.md` and `FormalSystem/README.md` keep a 3–5 row highlights table that *links* to the ledger |
| **Mathematical narrative per theorem** | the declaration's own `/--` doc comment | READMEs summarize in ≤ 2 sentences and link |
| **Module inventory per directory** | that directory's `README.md` Contents table, generated from `ls` + each file's `/-!` first line | parent READMEs link, never restate |
| **Object-language definition** (`Formula`, frame axioms, truth clauses) | top-level `README.md` §Operators / §Task Semantics — it is currently the only correct one | `FormalSystem/README.md`, `Syntax/README.md`, `Semantics.lean` link to it (E-03, E-11, E-20.4) |
| **Design decisions and history** | `docs/decisions/*.md` (ADR form) | current-state prose only; no past tense (E-12) |
| **Paper ↔ Lean name mapping** | `docs/theorem-index.md` §Notation, cross-checked by `check-paper-definitions.sh` | `typst/`'s `#leansrc` continues to supply the paper→Lean direction |

Two new gates make the policy self-enforcing:
- **C16 (duplication)**: fail if any paragraph of ≥ 25 words appears, whitespace-normalized, in
  two or more of `README.md`, `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md`,
  `FormalSystem/Metalogic.lean`. This would have caught E-01 at the moment it was introduced.
- **C17 (name resolution in markdown)**: reuse `scripts/typst-sync-check.sh`'s backtick-name
  resolver over `FormalSystem/**/*.md` and `docs/**/*.md`. This would have caught E-18, E-03
  (`all_past` resolves nowhere) and E-20.5.

Also widen C14's regex (E-09) and extend `readme-lint.sh` Check 4 to compare stamps against
`git log -1 --format=%cs -- <dir>` (E-06).

### 5.2 `docs/theorem-index.md` — schema and first rows

**Schema**

```
| Paper label | Statement (one line) | Lean name | File | Frame class | Axioms |
```

- *Paper label* — the `\label{}`/`\aitem{}` anchor from `specs/paper-definitions-of-record.md`,
  or `—` where the result is the formalization's own.
- *Statement* — prose, one line, in the paper's vocabulary.
- *Lean name* — fully qualified where ambiguous.
- *File* — repository-relative path, **no line number** (line numbers drift; 93 already exist in
  live markdown).
- *Frame class* — `Base` / `Dense` / `Discrete` / `Dedekind` / `—`.
- *Axioms* — **generated**, not typed. `pcq` = exactly `propext`, `Classical.choice`,
  `Quot.sound`; `pinned:C2` / `pinned:C14` marks the machine-asserted subset; `claimed` marks a
  status asserted only in prose (currently 33 of 37 — E-14).

**First 16 rows** (all names and paths verified against the tree at review time)

| Paper label | Statement | Lean name | File | Frame class | Axioms |
|---|---|---|---|---|---|
| `thm:TM-soundness` | Derivability implies validity over all linear orders | `soundness` | `Metalogic/Soundness.lean` | Base | pcq (claimed) |
| `thm:TM-soundness` | …over densely ordered task frames | `soundness_dense` | `Metalogic/Soundness.lean` | Dense | pcq (claimed) |
| `thm:TM-soundness` | …over discrete task frames | `soundness_discrete` | `Metalogic/Soundness.lean` | Discrete | pcq (claimed) |
| `thm:TM-soundness` | …over dense Dedekind-complete flows, against `ValidDedekindDense` | `soundness_dedekind` | `Metalogic/Soundness.lean` | Dedekind | pcq (claimed) |
| `cor:tm-completeness` | Weak completeness over all linear orders | `completeness` | `Metalogic/BXCanonical/Completeness.lean` | Base | pcq **pinned:C2** |
| `cor:tm-completeness` | Weak completeness over dense orders | `completeness_dense` | `Metalogic/BXCanonical/Completeness.lean` | Dense | pcq **pinned:C2** |
| `cor:tm-completeness` | Weak completeness over discrete orders | `completeness_discrete` | `Metalogic/BXCanonical/Completeness.lean` | Discrete | pcq **pinned:C2** |
| `cor:tm-completeness` | Weak completeness over the dense-and-complete class (TM⁺_c), on ℝ | `completeness_dedekind` | `Metalogic/StrongCompleteness.lean` | Dedekind | pcq **pinned:C14** |
| — | Finite-context consequence completeness (Base) — **not** strong completeness | `consequence_completeness_base` | `Metalogic/StrongCompleteness.lean` | Base | pcq (claimed) |
| — | Finite-context consequence completeness (Dense) | `consequence_completeness_dense` | `Metalogic/StrongCompleteness.lean` | Dense | pcq (claimed) |
| — | Finite-context consequence completeness (Discrete) | `consequence_completeness_discrete` | `Metalogic/StrongCompleteness.lean` | Discrete | pcq (claimed) |
| — | Finite-context consequence completeness (Dedekind) | `consequence_completeness_dedekind` | `Metalogic/StrongCompleteness.lean` | Dedekind | pcq (claimed) |
| — | Strong completeness from a possibly-infinite `Γ : Set Formula`, via compactness | `strongCompletenessBase` | `Metalogic/Compactness.lean` | Base | pcq **pinned:C14** |
| — | Strong completeness (Dense), same route | `strongCompletenessDense` | `Metalogic/Compactness.lean` | Dense | pcq **pinned:C14** |
| — | Compactness by ultraproduct over finite sublists of the premise set | `compactBase`, `compactDense` | `Metalogic/Compactness.lean` | Base, Dense | pcq (claimed) |
| — | **Refutation**: the Discrete set-consequence relation is not compact (`{F p} ∪ {¬Xⁿ p}`) | `discrete_consequence_not_compact` | `Metalogic/DiscreteNonCompactness.lean` | Discrete | pcq (claimed) |

*Continuation rows to populate (all verified present):* `strongCompletenessDiscrete_refuted`
(`DiscreteNonCompactness.lean`), `dedekind_consequence_not_compact` and
`strongCompletenessDedekind_refuted` (`DedekindNonCompactness.lean`) — **the two rows whose
absence from `README.md` is E-01**; `galoisClosed_mod`, `galoisClosed_of_indicator`
(`Semantics/Correspondence/Galois.lean`); `galoisClosed_sat_dense`, `galoisClosed_isDiscrete`,
`validOn_nextTop_iff`, `validOn_nextTop_iff_isDiscrete`
(`Semantics/Correspondence/Indicator.lean`); `validOn_dn_iff_denselyOrdered`,
`validOn_df_iff_isDiscrete`, `validOn_co_iff_isComplete` (`Correspondence/DurationFrames.lean`,
paper labels `app:dense` / `app:discrete` / `app:complete`); `sat_dedekind_ssubset_mod_axiomSet`
(`Independence/RationalWitness.lean`), `sat_discrete_ssubset_mod_axiomSet`
(`Independence/LexIntWitness.lean`); `kampPriorExpressiveCompleteness`
(`WeakCanonical/Kamp/KampPrior.lean`); `countermodel_dense`
(`BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean`, **pinned:C2**),
`countermodel_discrete` (`WeakCanonical/GroupModel/CountermodelBase.lean`),
`countermodel_dedekind_dense` (`BXCanonical/CompletenessDedekind.lean`);
`sound_of_isValid` / `isValid_sound` (`Metalogic/Decidability/Correctness.lean`,
**pinned:C14**, with an explicit "completeness direction open" note);
`deduction_theorem` (`Metalogic/Core/DeductionTheorem.lean`);
`co_not_derives_prior_U_gap` / `co_not_derives_prior_U_gap_schema`
(`Independence/CoNotPriorU.lean`) and its converse `co_derived`
(`Theorems/DedekindDerived.lean`).

A second table in the same file — **Notation and naming** (E-20) — maps paper term → Lean
identifier → defining file for: task frame / `TaskFrame` (total space) / `FrameOver D` (fibre);
Saturation / `spherical`; TM⁺_c / `FrameClass.Dedekind`; dense-and-complete / `IsDedekind` /
`ValidDedekindDense`; Until (guard-first) / `untl`; Since / `snce`; H, G / `allPast`,
`allFuture` (derived).

### 5.3 README template

Every Lean-directory README, in this order (matching `docs/reference/readme-standard.md:41-70`,
which is already the standard — the gap is compliance, not the standard):

```
# DirectoryName
<one-paragraph scope: what mathematics lives here>

## Modules              <!-- GENERATED --> | File | Lines | Description |
## Key Results          hand-written; ≤ 6 bullets; each names a declaration
## Dependencies         Imports from: … / Imported by: …
## Related Documentation
---
**Last verified**: YYYY-MM-DD   <!-- checked against git log by readme-lint.sh -->
```

Current compliance across the 14 principal READMEs (`C`=Contents/Modules, `K`=Key Results/
Definitions, `D`=Dependencies, `R`=Related/Navigation):

| README | C | K | D | R | Last verified | Dir last changed |
|---|:-:|:-:|:-:|:-:|---|---|
| `FormalSystem/README.md` | – | Y | – | Y | 2026-08-25 | 2026-09-01 |
| `Syntax/README.md` | Y | Y | – | Y | 2026-05-29 | 2026-08-17 |
| `ProofSystem/README.md` | Y | Y | – | Y | 2026-05-29 | 2026-08-25 |
| `Semantics/README.md` | Y | Y | – | Y | 2026-05-29 | 2026-09-01 |
| `Semantics/Correspondence/README.md` | Y | Y | Y | Y | 2026-09-01 | 2026-09-01 |
| `Metalogic/README.md` | – | – | – | Y | 2026-08-26 | 2026-09-01 |
| `Metalogic/Core/README.md` | Y | Y | Y | Y | 2026-05-29 | 2026-08-25 |
| `Metalogic/Bundle/README.md` | – | – | – | Y | **none** | 2026-08-31 |
| `Metalogic/Algebraic/README.md` | Y | Y | Y | Y | **none** | 2026-09-01 |
| `Metalogic/Independence/README.md` | Y | Y | Y | Y | 2026-09-01 | 2026-09-01 |
| `Metalogic/SoundnessLemmas/README.md` | Y | Y | Y | Y | 2026-09-01 | 2026-09-01 |
| `Theorems/README.md` | Y | – | – | Y | 2026-05-29 | 2026-09-01 |
| `Automation/README.md` | Y | – | – | Y | 2026-05-29 | 2026-08-31 |
| `Examples/README.md` | Y | – | – | Y | **none** | 2026-08-31 |

`Semantics/Correspondence/`, `Metalogic/Independence/` and `Metalogic/SoundnessLemmas/` are
fully compliant and accurate — **use them as the template**. `Metalogic/README.md` is the least
compliant (no Contents, no Key Results, no Dependencies) and also the most drifted.

### 5.4 What moves where

| Content | From | To |
|---|---|---|
| Metalogic directory census | `Metalogic.lean:224-256` | deleted; generated block in `Metalogic/README.md` |
| Per-theorem status ledger | `Metalogic.lean:49-149`, `README.md:161-251`, `FormalSystem/README.md:319-341` | `docs/theorem-index.md` (generated status column); ≤ 5-row highlights + link remain |
| Layer diagram + upward edges | `FormalSystem/README.md:234-269`, `Metalogic/README.md:293-308` | new `docs/ARCHITECTURE.md` |
| Archive-consolidation history | `FormalSystem/README.md:11-33`, `Metalogic/README.md:10-22` | `docs/decisions/single-boneyard.md`; one-line current-state note + B0 pointer remains |
| "Why there is no physical regroup" | `Metalogic/README.md:64-118` | `docs/decisions/metalogic-no-physical-regroup.md` |
| `validity_decidable` retirement (4 copies) | `README.md:200-207`, `FormalSystem/README.md:339-341`, `Decidability/README.md:18`, `Decidability/Verified/README.md:68` | `docs/decisions/decidability-one-directional.md`; all four become pointers |
| Object-language tables | `FormalSystem/README.md:47-73`, `Syntax/README.md:16-24` | link to `README.md:31-69` (the only correct copy) |
| Axiom-report table | `typst/FormalFoundations.typ:986-996` | generated by `scripts/typst-status-counts.sh` into `typst/generated/status.typ` |

---

## 6. Metrics

**Scope read**: 14 principal `FormalSystem/**` READMEs + top-level `README.md` + `CLAUDE.md`;
`FormalSystem/Metalogic.lean` (257 lines), `FormalSystem/Semantics.lean` (207),
`FormalSystem.lean`, `FormalSystem/FormalSystem.lean`, and all 8 `Metalogic/` aggregators;
module docstrings of all 68 files in the specified core scope; `docs/` (9 subdirectories,
~60 files, spot-checked); `scripts/check-module-invariants.sh` (916 lines),
`scripts/typst-status-counts.sh`, `scripts/readme-lint.sh`,
`scripts/module-invariants-manifest.txt` (113 lines);
`specs/paper-definitions-of-record.md` (1,465 lines, header + provenance);
`typst/` (`FormalFoundations.typ`, `SYNC-MAP.md`, `generated/status.typ`, chapter grep);
`latex/subfiles/04-Metalogic.tex` (grep).

| Metric | Value |
|---|---|
| Findings | 22 (Critical 3, High 6, Medium 9, Low 4) |
| Drift-table rows | 68 checked; **~40 STALE**, 5 INCOMPLETE, 2 BROKEN RECIPE, ~21 ACCURATE |
| Cross-document contradictions | 3 (E-01 Dedekind, E-04 Boneyard count, E-02 sorry status) |
| Declaration names cited in prose, checked | 41; **40 resolve**, 1 wrong (E-18) |
| Files in doc-gen scope | 68 |
| …with module docstring | 67 (99%) — sole gap `Metalogic/WeakCanonical.lean` |
| Public declarations in scope | 1,028 |
| …with `/--` doc comment | 924 (**90%**) |
| Files below 70% doc coverage | 8 |
| Declarations claimed SORRY-FREE in `Metalogic.lean` | 37 |
| …machine-pinned by C2 + C14 | 8 (**33 of 37 are prose-only**) |
| `SORRY-FREE`/`sorry-free` occurrences on live surfaces | 92 across 24 files |
| History/process-prose hits on live doc surfaces | 19 |
| Duplicated multi-sentence blocks (`README.md` ↔ `Metalogic.lean`) | 4 confirmed verbatim (whitespace-normalized), 1 further semantic duplicate |
| `file.lean:NNN` citations in live markdown | 93 (none out-of-range; 1 confirmed stale: drift row 66) |
| READMEs with stale or missing `Last verified` | 11 of 14 |
| Live `.lean` files (excl. Boneyard): `FormalSystem/` | 434 |
| Live `.lean` files: `Metalogic/` | 323 (229,930 lines) |
| Archived `.lean` in `Boneyard/` | 156; `Boneyard` directories: **1** |
| `Axiom` constructors (enumerated) | 45 — matches every README claim |
| Missing publication artifacts | `CITATION.cff`, `docs/ARCHITECTURE.md`, `docs/theorem-index.md`, working doc-gen4 target |
| Present publication artifacts | CI workflow + badge, LICENSE (Apache-2.0), BibTeX block, Lean/Mathlib version statement, Boneyard policy, `paper-definitions-of-record.md` |
