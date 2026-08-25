# Implementation Plan: `docs/` Overhaul — Deletions, Links, Gaps, and Drift Guard

- **Task**: 486 - docs/ OVERHAUL: delete the documents that are fiction, rewrite the false limitation entries, repair the dead links, close the documentation gaps, and add a mechanical drift guard
- **Status**: [IMPLEMENTING]
- **Effort**: 17.5 hours
- **Dependencies**: 484 (complete — corrected `specs/ROADMAP.md` and `FormalSystem/Metalogic/README.md`), 485 (complete — corrected `README.md` and the `FormalSystem/**/README.md` layer). Both are ground truth for this task.
- **Research Inputs**: specs/486_docs_overhaul_deletions_links_gaps_and_drift_guard/reports/01_docs-overhaul-verification.md
- **Artifacts**: plans/01_docs-overhaul-and-drift-guard.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

`docs/` describes a repository that no longer exists: two whole documents are fiction, ten
sites assert proof debt that a green tree refutes, the count tables are off by up to 21x, and
roughly seventy-five relative links resolve to nothing — several of them outside the repository
entirely. The work is prose, markdown, and two shell scripts; the verification gate forbids
changing any `.lean` declaration, signature, import, or tactic. The definition of done is that
every status claim in `docs/` is traceable to Lean source or `#print axioms`, the link resolver
returns zero, the nine missing `FormalSystem/` READMEs exist, and three new checks in
`scripts/check-module-invariants.sh` make this class of drift fail the build rather than
accumulate silently.

The guard phase runs last by construction: it asserts that documentation matches the verified
proof state, so it can only be authored once the content is correct.

### Research Integration

The research report (`reports/01_docs-overhaul-verification.md`) confirmed every substantive
claim in the task description that it checked against Lean source, and changed the shape of the
work in nine ways. The five that drive this plan's structure:

1. **The "94 dead links" figure is not reproducible** (report F2). The measured breakdown is
   **96 total / 76 after the documented ignore-classes / 74 genuinely actionable**. This plan
   therefore gates on the resolver **command** in report §6.1 returning zero lines, never on a
   number. Report §6.2 supplies a complete per-line repair table (Classes A-J) that Phase 7
   executes directly.
2. **`SORRY_REGISTRY.md` has 15 inbound references, not 4** (F1), nine of them in
   `docs/project-info/MAINTENANCE.md`, where the file is a live node in a documented
   four-document sync procedure. Phase 1 is a procedure rewrite, not a link repoint.
3. **Check C5 matches dotted module names only** (F7); slash-shaped paths such as
   `FormalSystem/Metalogic/Bundle/DovetailingChain.lean` are invisible to it, which is exactly
   why `BFMCS_ARCHITECTURE.md`'s dead source table survived a green gate. The new C12 closes
   this and is the highest-value guard in the task.
4. **Do not extend C5's regex to `Bimodal.*`** (F8): doing so turns the gate red on files this
   task must not touch. A distinct check (C12, slash-form only) is added instead.
5. **Dedekind strong completeness has three distinct statuses, not two** (F9). The rewritten
   Limitation 1 lifts the tree's own wording from `Metalogic.lean:83-110` and
   `StrongCompleteness.lean:25-89` rather than paraphrasing.

Report §2.1 lists the in-tree prose the implementer should **lift and adapt** rather than
re-derive. Report §10's eight-phase decomposition is the basis for the ten phases below;
the differences are that the documentation-gap phase moves **before** the link sweep (so the
sweep validates newly added content too), the missing-README phase moves to wave 1 (it touches
a disjoint file set and need not wait), and the guard phase splits in two (it is the largest
single unit of work in the task).

### Prior Plan Reference

No prior plan exists for this task. The plans for its two dependencies are informative for
effort calibration only: task 485's plan estimated 13.5 hours for a comparable
transcription-style documentation correction across two README layers and completed. This task
covers a larger surface (72 `docs/` files plus two shell scripts plus nine new READMEs), so
17.5 hours is a consistent scaling rather than an independent guess. Task 485's most
transferable lesson is its framing: every figure comes from `.lean` source, `#print axioms`, or
a filesystem walk — never from another document. That rule is restated as this plan's first
Goal because the defect being repaired here is precisely documents citing documents.

### Roadmap Alignment

No `roadmap_path` was supplied in the delegation context, so `specs/ROADMAP.md` was consulted
read-only and is not modified by this plan. Two items are relevant:

- The roadmap's **Check grounding** line names exactly `C5 (module-shaped path resolution in
  markdown/docs)` and `C9 (zero task-number citations under FormalSystem/)` as the mechanical
  anchors for its documentation phase. Phases 8 and 9 extend both grounds: C12 covers the
  slash-shaped path form C5 cannot see, and C9's computation is extended over `docs/` behind a
  soft-enforcement flag.
- The roadmap's `README/docs/module-docstring final polish` item is downstream of this task's
  content phases. This plan does not claim or close it.

### Task 485 Downstream Handoffs

Task 485's implementation recorded three handoffs falling in this task's territory. All three
are accounted for:

| Handoff | Disposition | Where |
|---------|-------------|-------|
| `docs/reference/axiom-reference.md` needs a 42 -> 45 constructor sweep | **In scope** — it is the task's own item 3a, and the largest single count defect (the document says 21 and omits the Dedekind layer entirely) | Phase 4 |
| ~30 out-of-scope `Bimodal.*` module references (485's deviation D2) | **Out of scope, deliberately** — see Non-Goals below and report F8 | Not scheduled |
| `FormalSystem/Metalogic/README.md:44-45` carry two stale import numerals, re-derived by 485 as 9 and 4 | **In scope** — confirmed at plan time: both lines currently read `2 import lines`; the measured values are 9 (`BXCanonical -> WeakCanonical`) and 4 (`BXCanonical -> Algebraic`) | Phase 4 |

## Goals & Non-Goals

**Goals**:

- Every status, count, and path claim in `docs/` is traceable to Lean source, `#print axioms`,
  or a filesystem walk — never to another document.
- The two fiction documents (`SORRY_REGISTRY.md`, `IMPLEMENTATION_STATUS.md`) are deleted and
  every inbound reference is repointed, rewritten, or removed, including the four-document sync
  procedure in `MAINTENANCE.md` that one of them anchors.
- The report §6.1 link resolver returns **zero lines** over `docs/`.
- All nine documentation gaps (G1-G9) have coverage in at least one `docs/` file.
- `bash scripts/readme-lint.sh` reports **0** missing READMEs.
- `bash scripts/check-module-invariants.sh` reports **ALL CHECKS PASSED** with C12, C13, and
  C14 present and reporting real (non-skipped) results.
- No `.lean` declaration, signature, import, or tactic is changed.

**Non-Goals**:

- **The ~38 dotted `Bimodal.*` module references** across roughly twenty
  `FormalSystem/**/README.md` files (485's deviation D2; report F8 measured 48, this plan
  measured 38 — the discrepancy is itself evidence the figure needs re-derivation, not
  propagation). Excluded for three reasons: the files lie outside this task's `file_scope`;
  closing it means editing twenty READMEs unrelated to `docs/`; and report F8 establishes that
  extending C5's regex to catch them would turn a green gate red on exactly those untouched
  files. C12 covers the *slash* form of the same defect; the dotted sweep belongs to the
  follow-up task 485 handed off, which this plan does not create.
- Deleting `docs/development/PHASED_IMPLEMENTATION.md` (report §3.3). It is a third deletion
  candidate carrying 100 of the repository's remaining task-number citations, but the review
  did not list it and the task did not ask. Phase 9's C9-over-`docs/` check is added
  soft-enforced precisely so this debt is *visible* at every gate without blocking here.
- Closing the ~110 files present on disk but absent from their directory README's inventory
  (report §8.1). `readme-lint.sh` Check 2 does not affect its exit code, so the stated gate does
  not require it. Enforcing it would convert 110 cosmetic warnings into gate failures.
- Correcting `FormalSystem/ProofSystem/Axioms.lean:92-95`, whose layer-breakdown docstring gives
  42 and omits the Dedekind layer — the same defect this task fixes in `axiom-reference.md`. It
  is prose and so permitted by the verification gate, but the file is outside `file_scope`.
  Recommend a follow-up task.
- Any change to C5's existing regex.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Line numbers in the task description and report drift before implementation | H | M | Every phase re-derives its targets by content grep, never by line number alone. Report §2's ground-truth table carries an explicit "re-derive rather than trusting this table" instruction |
| Phases 2/3/4 collide on shared files (`known-limitations.md`, `implementation-status.md`, `FEATURE_REGISTRY.md`) | M | H if dispatched in parallel | Wave 2 is split by **file ownership**, not by defect ID. Each phase below carries an explicit exclusive file list; no file appears in two wave-2 phases |
| The "74 actionable links" hypothesis is wrong at implementation time | M | M | The gate is the resolver command returning zero, not the number. Any surplus found is repaired in-phase and the count recorded as a deviation |
| C12/C13 turn the gate red on files this task must not touch | H | M | Both checks are scoped to `docs/` + `README.md` and, for C12, to slash-shaped paths only. C13 uses an allowlist **file**, not hardcoded exclusions, so a surprise can be recorded rather than forcing an out-of-scope edit |
| C14's `#print axioms` extension slows or breaks the default gate | M | L | C14 reuses C2's existing scratch-file + `lake env lean` machinery verbatim (`check-module-invariants.sh:122-163`) and inherits its `--no-build` skip behavior |
| Nine new READMEs widen `file_scope` beyond `docs/` and the two scripts | L | H (certain) | The widening is mandated by the task's own Phase 6a and verification gate. Phase 5 records it explicitly; the files are new, so no existing content is at risk |
| Newly written gap content introduces new dead links | M | M | Phase 6 (gaps) is sequenced **before** Phase 7 (link sweep), so the sweep validates the new content |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 5 | -- |
| 2 | 2, 3, 4 | 1 |
| 3 | 6 | 2, 3, 4 |
| 4 | 7 | 6 |
| 5 | 8 | 7 |
| 6 | 9 | 5, 8 |
| 7 | 10 | 9 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Deletions and the `MAINTENANCE.md` Procedure Rewrite [COMPLETED]

**Goal**: Remove the two fiction documents and leave no inbound reference dangling, including
the four-document sync procedure that one of them anchors.

**Tasks**:
- [x] Re-derive the inbound reference set: `grep -rn 'SORRY_REGISTRY\|IMPLEMENTATION_STATUS' docs/ README.md scripts/ FormalSystem/`
- [x] Delete `docs/project-info/SORRY_REGISTRY.md` (every path it names is nonexistent; its own verification commands at `:24-31` and `:56-69` glob `Bimodal/**/*.lean` and match nothing)
- [x] Delete `docs/project-info/IMPLEMENTATION_STATUS.md` (duplicates and contradicts the lowercase `implementation-status.md`, which declares itself authoritative at `:7-9`)
- [x] Repoint or remove the markdown links at `docs/README.md:97,171,222`, `docs/project-info/FEATURE_REGISTRY.md:7`, `docs/project-info/implementation-status.md:152` *(deviation: altered -- the measured inbound set was 28 non-self references, not the report's 15; six further sites in `docs/project-info/README.md` (4) and `docs/project-info/tactic-registry.md` (2) and seven further `MAINTENANCE.md` sites were repaired in the same pass)*
- [x] Rewrite `docs/project-info/MAINTENANCE.md`'s four-document sync procedure (9 sites: `:13,91,134,152,170,177,180,266,278`) around the **mechanical** replacement: C3 of `check-module-invariants.sh` is the sorry inventory and asserts a hard zero by content. The maintenance step becomes "run the check", not "hand-edit a registry". Note `:170` and `:177-180` sit inside a bash fence — they need editing as prose but are not broken links
- [x] Update the prose mention at `docs/development/DIRECTORY_README_STANDARD.md:296` (template listing)
- [x] Leave `docs/reference/readme-standard.md:166` **unchanged** — it is a row in a naming-convention table that is *about* the uppercase/lowercase convention

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: The research report measured 15 non-self inbound references to
`SORRY_REGISTRY.md` (task description said 4) and exactly one to `IMPLEMENTATION_STATUS.md`
outside itself. Confirm at implementation time with the grep in the first task item before
editing; if the count differs, repair the actual set and record the deviation.

**Files to modify**:
- `docs/project-info/SORRY_REGISTRY.md` - delete
- `docs/project-info/IMPLEMENTATION_STATUS.md` - delete
- `docs/project-info/MAINTENANCE.md` - rewrite the sync procedure around C3
- `docs/README.md` - repoint 3 links
- `docs/project-info/FEATURE_REGISTRY.md` - repoint 1 link
- `docs/project-info/implementation-status.md` - repoint 1 link
- `docs/development/DIRECTORY_README_STANDARD.md` - prose mention

**Verification**:
- Both files absent from the working tree
- `grep -rn 'SORRY_REGISTRY' docs/ README.md` returns only intentional prose (no markdown links)
- `grep -rn 'IMPLEMENTATION_STATUS' docs/` returns only `readme-standard.md:166`
- `bash scripts/check-module-invariants.sh --no-build` still reports ALL CHECKS PASSED

---

### Phase 2: `known-limitations.md` — the Completeness and Decidability Core [COMPLETED]

**Goal**: Replace the two false limitation entries with the genuine open items, stated in the
tree's own words.

**Tasks**:
- [x] Delete Limitation 1 (`:9-37`, "General Base-Frame Completeness Has Residual Proof Debt", including `:21` and the citation to `BXCanonical/Completeness.lean:187`). `completeness` is at `Completeness.lean:196` and is sorryAx-free per C2
- [x] Replace it with the **three** distinct strong-completeness statuses (report F9): Discrete machine-refuted (`DiscreteNonCompactness.lean:280` `strongCompletenessDiscrete_refuted`); Base and Dense open (`SetConsequence.lean:219` `CompactBase`, `:263` `CompactDense`); Dedekind unavailable on Reynolds's terms — unproved **and** unrefuted. Lift the wording from `Metalogic.lean:83-101` and `StrongCompleteness.lean:59-89`; do not collapse the three into two
- [x] Rewrite Limitation 6 (`:123-127`, "No Decidability Procedures"). The decision procedure exists (the `FormalSystem/Metalogic/Decidability/` subtree); the sound direction is proved (`Correctness.lean:100` `sound_of_isValid`, `:111` `isValid_sound`); the completeness direction `models phi -> isValid phi fc = true` is open (`Correctness.lean:107-109` is the model phrasing)
- [x] Surface, do not elide, the `extractionFailed` caveat: `isKnownValid` is true on `extractionFailed`, which carries no proof witness. The prose is already written at `Correctness.lean:95-99` — quote it
- [x] Add a genuine limitation entry for discrete non-compactness (G2): `archWitness` (`DiscreteNonCompactness.lean:102`), `discrete_consequence_not_compact` (`:250`), `strongCompletenessDiscrete_refuted` (`:280`). Lift from `StrongCompleteness.lean:59-72` and `Metalogic.lean:102-110`
- [x] Also corrected `:157` "All 21 axiom schemas" -> 45 and removed the summary table's task-number citation column *(deviation: altered -- both are Phase 4-class defects, taken here because wave 2 is split by file ownership and this file is Phase 2's exclusive owner)*
- [x] Ensure the consequence-completeness / strong-completeness distinction (G9) is stated explicitly, so a reader cannot read the four completeness theorems *as* strong completeness
- [x] Repoint the `../../../` escape at `:178` to `implementation-status.md` *(deviation: altered -- the escape duplicated an existing `implementation-status.md` link two lines above, so it was repointed to `../reference/API_REFERENCE.md` instead of creating a duplicate)*

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: prose

**Files to modify**:
- `docs/project-info/known-limitations.md` - exclusive owner for this wave

**Verification**:
- No `docs/` file asserts residual Base-frame proof debt: `grep -rni 'residual.*proof debt\|cannot yet be treated as a fully verified' docs/` is empty
- The three strong-completeness statuses appear distinctly, with `strongCompletenessDiscrete_refuted`, `CompactBase`, and Dedekind each named
- `grep -rn 'extractionFailed' docs/` is non-empty
- Every theorem name cited resolves: check each against its stated file with `grep -n`

---

### Phase 3: Remaining False-Status Sites [COMPLETED]

**Goal**: Clear the false-status defects in the architecture, status, tutorial, and coverage
documents.

**Tasks**:
- [x] `docs/architecture/BFMCS_ARCHITECTURE.md` (2c) *(deviation: altered -- the document's BFMCS/BMCS ontology names were also inverted relative to the tree (real names: `FMCS` for a single history, `BFMCS` for the bundle), and its 5.1 completeness chain cited six nonexistent theorems; both corrected, since leaving them would have shipped a known falsehood and left C12 red)*: remove the whole section 4 "Lacunae Inventory" and its TOC entry (`:36-41`); correct `:17-19`, `:194-195`, `:350-367`. Of the six files in the source table at `:359-367`, only `BFMCS.lean` and `TemporalContent.lean` exist — `BMCS.lean`, `DovetailingChain.lean`, `TemporalCoherentConstruction.lean`, `Bundle/Completeness.lean` do not. Also delete the `Status: Sorry` rows in the operator table at `:193-198`
- [x] `docs/project-info/implementation-status.md` (2d): `:132` "Known sorries | 12" -> 0; rewrite `:55` and `:72-74` — `countermodel_discrete` is **proved** at `WeakCanonical/GroupModel/CountermodelBase.lean:142`, not dead code (see `Metalogic.lean:33-38`)
- [x] Same file, three defects the task description did not list (report §4, row 2d): `:65` "all 21 axiom schemas: 17 base + 1 dense + 3 discrete"; `:58` a Layer-2 module table row for an archived `Completeness.lean`; `:139` `lake build Bimodal` — a target that does not exist (only `FormalSystem` and `BimodalTest`)
- [x] `docs/user-guide/architecture.md` (2e): correct `:1303` ("8 axioms, 7 rules" -> 45 axiom constructors; the 7 rules figure **is** correct per `ProofSystem/Derivation.lean`); delete the false Base-frame debt at `:1305-1307`; remove the `Logos/` tree documentation at `:944-1000` (`LogosTest/`, `Archive/`, `Counterexamples/`, `Syntax/DSL.lean`, `ProofSystem/Rules.lean`, `Metalogic/Completeness.lean` — none exist)
- [x] `docs/user-guide/tutorial.md` (2h): correct the `:404-409` status note (false Base-frame debt; add `completeness_dedekind`); rename `:381`'s "Strong completeness" to "consequence completeness" per `StrongCompleteness.lean:25-35`, since the statement is finite-`Context`. Note `:402` already has the P3-P6 perpetuity principles **correct** — use it as an in-repo cross-check for Phase 4, do not change it
- [x] Also fixed `docs/project-info/implementation-status.md:129-130` metric drift (~40 files / ~8000 lines -> 539 / 170,898 with the `cloc` reproduction command) *(deviation: altered -- item 3d of Phase 4, taken here because Phase 3 owns this file exclusively)*
- [x] Repaired `docs/user-guide/examples.md:949`, which asserted the same false Base-frame proof debt and is named nowhere in the plan *(deviation: altered -- surplus site found by the Phase 2 verification grep)*
- [x] `docs/project-info/test-coverage.md` (2j): `:20` "Sorry Placeholders | 5" -> 0. Leave the `:7-11` superseded notice intact

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: prose

**Files to modify**:
- `docs/architecture/BFMCS_ARCHITECTURE.md` - exclusive owner
- `docs/project-info/implementation-status.md` - exclusive owner
- `docs/user-guide/architecture.md` - exclusive owner
- `docs/user-guide/tutorial.md` - exclusive owner
- `docs/project-info/test-coverage.md` - exclusive owner

**Verification**:
- `grep -rn 'Lacunae' docs/` is empty
- `grep -rn 'sorries.*| *[1-9]\|Sorry Placeholders.*[1-9]' docs/` is empty
- `grep -rn 'lake build Bimodal\b' docs/` is empty
- `grep -rn 'Logos/' docs/user-guide/architecture.md` is empty
- Every source path named in `BFMCS_ARCHITECTURE.md`'s tables resolves on disk

---

### Phase 4: Counts, Classification, and the Reference Layer [COMPLETED]

**Goal**: Bring every count and classification table to the measured ground truth, and correct
the reference documents that the front page links to.

**Tasks**:
- [x] `docs/reference/axiom-reference.md` (3a, and 485's handoff 1): replace `:7-13`'s "21 axiom schemas / three layers / Base 17 / Dense 1 / Discrete 3" with **45 total: Base 37 / Dense 2 / Discrete 3 / Dedekind 3**, per `Axiom.minFrameClass` (`Axioms.lean:588-597`). Name the Dedekind layer (`prior_U_gap`, `prior_S_gap`, `sep`; Reynolds 1992, printed p.168)
- [x] Same file: correct the stale axiom **names**. The temporal layer is Burgess-Xu until/since (`left_mono_until_G`, `enrichment_until`, `linear_since`, `F_until_equiv`, ...), not T4/TA/TL/TK; `temp_k_dist` and `temp_4` are **derived theorems** (`temporalKDistDerived`, `temporal4Derived` in `TemporalDerived.lean`) per `Axioms.lean:96-98`. Note the front page (`README.md:209`, as corrected by 485) already says 45 — the reference document it links to is the wrong half
- [x] `docs/reference/operators.md` (3b): add `untl` and `snce`, the two **primitive** binary temporal constructors (`Syntax/Formula.lean:96`, `:106`), plus `kPlus`/`kMinus`/`next`. Every H/P/G/F entry the file has is a derived form (`:147,157,196,209`). Correct `:194` to `Derivable (fc : FrameClass) (G : Context) (p : Formula)` per `ProofSystem/Derivable.lean:69`. Rewrite `:207`'s unqualified completeness claim — it is the exact finite/infinite conflation `StrongCompleteness.lean:25-41` exists to forbid. Also correct the "Logos" branding at `:7` and `:9`
- [x] `docs/reference/API_REFERENCE.md` (2i): delete the `:612` "Currently has build errors (type class instance problems)" note about `deductionTheorem` — the tree is green. Add the frame-class parameter to the soundness/completeness statements at `:600` and `:627`. Edit surgically: `:616-626` has already been partly corrected and names the Boneyard archive
- [x] `docs/project-info/FEATURE_REGISTRY.md` (2g): correct P3-P6, which are simply wrong. Actual per `Theorems.lean:51-54`: P3 `box phi -> box always phi`, P4 `diamond sometimes phi -> diamond phi`, P5 `diamond sometimes phi -> always diamond phi`, P6 `sometimes box phi -> box always phi`. Cross-check against `docs/user-guide/tutorial.md:402`, which already has them right. Also: `:19` "14 axiom schemata" and `:74`; `:21` archived `Metalogic/Completeness.lean`; `:43` `Theorems/Propositional.lean` (a **directory**); `:59` `Automation/ProofSearch.lean` (a **directory**); `:72` a task-number citation
- [x] `docs/research/BIMODAL_LOGIC.md`: `:82` "14 axiom schemata" -> 45 (the "7 inference rules" is correct); `:24` (3c) — the carrier is an arbitrary ordered abelian group `D` (`StrongCompleteness.lean:165-169`), not "discrete temporal points implemented as integers"; dense and Dedekind-complete carriers are explicitly supported. `:39-43` operator table omits `untl`/`snce`; `:87` overstates decidability
- [x] Decidability overstatement (2f) at `docs/README.md:16`, `docs/research/competitive-landscape.md:74` and `:82` — sound direction only *(deviation: altered -- two surplus sites also corrected: `docs/research/BIMODAL_LOGIC.md:137` and `docs/reference/API_REFERENCE.md:216` "The 14 axiom schemata", neither named in the plan)*
- [x] Metric drift (3d): `docs/project-info/README.md:117,123,127` *(deviation: altered -- the `implementation-status.md:129-130` half was done in Phase 3, which owns that file exclusively)* and `docs/project-info/implementation-status.md:129-130` are `~40 files / ~8000 lines / 12 sorries` against an actual **539 files / 170,898 code lines / 0 sorries**. Follow `README.md`'s own precedent (report §9.3): print the `cloc` reproduction command beneath the table rather than hardcoding the figure in two more places
- [x] **485 handoff 3**: `FormalSystem/Metalogic/README.md:44-45` both read `2 import lines`; the measured values are **9** (`BXCanonical -> WeakCanonical`) and **4** (`BXCanonical -> Algebraic`). Re-derive with `grep -rhc '^import FormalSystem.Metalogic.WeakCanonical' FormalSystem/Metalogic/BXCanonical/` before editing

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: prose

**Scope Hypothesis**: This phase asserts the axiom layer split **Base 37 / Dense 2 / Discrete 3
/ Dedekind 3 = 45**, and the metrics **539 files / 170,898 code lines**. Confirm the split at
implementation time from `Axiom.minFrameClass` in `FormalSystem/ProofSystem/Axioms.lean` (not
from `Axioms.lean:92-95`, whose docstring gives a stale 42 and omits the Dedekind layer — see
Non-Goals), and the metrics from `cloc --include-lang=Lean --exclude-dir=.lake,lake-packages,Boneyard .`.
It also asserts the import numerals 9 and 4; re-derive both by grep.

**Files to modify**:
- `docs/reference/axiom-reference.md` - exclusive owner
- `docs/reference/operators.md` - exclusive owner
- `docs/reference/API_REFERENCE.md` - exclusive owner
- `docs/project-info/FEATURE_REGISTRY.md` - exclusive owner
- `docs/research/BIMODAL_LOGIC.md` - exclusive owner
- `docs/research/competitive-landscape.md` - exclusive owner
- `docs/README.md` - exclusive owner (Phase 1's link repoints there are already committed)
- `docs/project-info/README.md` - exclusive owner
- `FormalSystem/Metalogic/README.md` - two numerals only (declared `file_scope` widening)

**Verification**:
- `grep -rn '\b21 axiom\|14 axiom\|~40 \|~8000\|44 constructor' docs/` is empty
- The axiom-reference layer table sums to 45 and names four layers
- `grep -rn 'untl\|snce' docs/reference/operators.md` is non-empty
- `grep -rn 'Logos' docs/reference/operators.md` is empty
- `sed -n '44,45p' FormalSystem/Metalogic/README.md` shows 9 and 4

---

### Phase 5: The Nine Missing READMEs [COMPLETED]

**Goal**: Take `readme-lint.sh`'s missing-README count from 9 to 0.

**Tasks**:
- [x] Record the baseline: `bash scripts/readme-lint.sh` (expected `Missing READMEs: 9`, `Total READMEs found: 37`, `Broken file references: 0`)
- [x] Write `FormalSystem/Metalogic/WeakCanonical/GroupModel/README.md` (6 files — hosts `countermodel_discrete` at `CountermodelBase.lean:142`, the tree's most consequential recent theorem)
- [x] Write `FormalSystem/BaseLanguage/README.md` (5 files — the second object language, with its own `inductive Axiom` at `BaseLanguage/Axioms.lean:73` and a translation into the primary language)
- [x] Write `FormalSystem/Metalogic/Independence/README.md` (3 files — `ClockFrame`, `CoNotPriorU`, `LoopingDuration`)
- [x] Write `FormalSystem/Metalogic/Decidability/Verified/Bridge/README.md` (15 files)
- [x] Write `FormalSystem/Metalogic/Decidability/Verified/Termination/README.md` (4 files)
- [x] Write `FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/README.md` (9 files)
- [x] Write `FormalSystem/Metalogic/WeakCanonical/Kamp/EANegationFixFaithful/README.md` (5 files)
- [x] Write `FormalSystem/Metalogic/WeakCanonical/RealModel/README.md` (7 files)
- [x] Write `FormalSystem/Semantics/Extension/README.md` (5 files)
- [x] Follow `docs/reference/readme-standard.md` and the existing sibling READMEs for format; every file must carry a `Last verified` line (readme-lint Check 4)
- [x] Use no dotted `Bimodal.*` module names and no task-number citations in the new files (C5, C9)

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: Nine directories, with the per-directory `.lean` file counts above.
Confirm both at implementation time from `bash scripts/readme-lint.sh` output and a filesystem
walk of each directory; write the inventory from the walk, never from this list.

**Files to modify**:
- Nine new `FormalSystem/**/README.md` files (a declared, task-mandated widening beyond the
  `docs/` + two-scripts `file_scope`; see Risks)

**Verification**:
- `bash scripts/readme-lint.sh` reports `Missing READMEs: 0`
- `Broken file references` remains 0 (485 took it from 5 to 0; do not regress it)
- `bash scripts/check-module-invariants.sh --no-build` still reports ALL CHECKS PASSED

---

### Phase 6: Documentation Gaps G3-G8 [COMPLETED]

**Goal**: Give the six remaining landed-but-undocumented results their first coverage anywhere
in `docs/`. (G1, G2, and G9 landed in Phase 2 alongside the limitation rewrites.)

**Tasks**:
- [x] **G8 first — the four-frame-class model.** `FrameClass`, its partial order, why Dedekind sits **above** Dense rather than being a fourth leaf, the TM+_c gap, and the `minFrameClass <= fc` derivation invariant. An extensive primary-source-grounded explanation already exists at `Axioms.lean:461-517` — lift it. This is the central organizing concept and every other gap entry reads against it
- [x] **G3 — Dedekind / real-line completeness.** `completeness_dedekind` (`StrongCompleteness.lean:469`), `consequence_completeness_dedekind` (`:450`), `FrameClass.Dedekind`, `ValidDedekindDense`, Reynolds 1992 section 9 Thm 7 provenance (`Axioms.lean:485-513`)
- [x] **G1 (API side)** — add the decidability soundness bridge to `docs/reference/API_REFERENCE.md`: `sound_of_isValid` (`Correctness.lean:100`), `isValid_sound` (`:111`), `isTautology_sound` (`:124`), `isContradiction_sound` (`:131`), `not_isSatisfiable_sound` (`:142`), carrying the `extractionFailed` caveat from `:95-99`
- [x] **G4 — conservativity.** `Metalogic/Conservativity.lean`: the TM/TM+ backward bridge (`translate`, `derivable_translate` at `:194`, and `ceb_backward`/`cef_backward`/`ced_backward`/`cec_backward` at `:210,222,232,253`) **and** the negative result that the forward direction is refuted for Base and Discrete
- [x] **G5 — independence results.** `Metalogic/Independence/{ClockFrame,CoNotPriorU,LoopingDuration}.lean`
- [x] Also replaced `MODULE_ORGANIZATION.md`'s stale section 1 directory tree (a nested `FormalSystem/Bimodal/` layout with `lakefile.toml` and an in-tree `docs/`, none of which exists) *(deviation: altered -- surplus defect found while adding the five absent subtrees)*
- [x] **G6 — the tense-primitive base language.** `FormalSystem/BaseLanguage/` (`Formula`, `Axioms`, `Derivation`, `Translation`, `AxiomDischarge`). Add to `docs/development/MODULE_ORGANIZATION.md`, which currently mentions **none** of `BaseLanguage`, `Decidability`, `Independence`, `Conservativity`, or `SetConsequence` — add all five
- [x] **G7 — the set-based consequence layer.** `SetConsequence.lean`: `SetConsistent`, `SetMaximalConsistent`, `set_lindenbaum`, `CompactBase` (`:219`), `CompactDense` (`:263`), the `Core.SetConsistent` bridge (`:184`), and the two reductions. Correct `docs/user-guide/architecture.md:747-796` (and the `:920` area), which still places `set_lindenbaum` in an archived `Completeness.lean`
- [x] Cross-link the new entries to the rewritten Limitations 1 and 6 from Phase 2

**Timing**: 2 hours

**Depends on**: 2, 3, 4

**Verification Tier**: prose

**Files to modify**:
- `docs/reference/API_REFERENCE.md` - G1, G3, G4 declaration entries
- `docs/project-info/known-limitations.md` - G4/G5 negative results as genuine limitation entries
- `docs/development/MODULE_ORGANIZATION.md` - G6, plus the four other absent subtrees
- `docs/user-guide/architecture.md` - G7, G8
- `docs/README.md` - navigation entries for the new sections, if needed

**Verification**:
- Each of these 15 terms hits at least one `docs/` file (research measured 0 for all but `set_lindenbaum`): `sound_of_isValid`, `isValid_sound`, `archWitness`, `discrete_consequence_not_compact`, `completeness_dedekind`, `ValidDedekindDense`, `Conservativity`, `derivable_translate`, `Independence`, `BaseLanguage`, `SetConsequence`, `CompactBase`, `minFrameClass`, `FrameClass.Dedekind`, `consequence_completeness`
- `grep -rn 'set_lindenbaum' docs/` no longer places it in an archived `Completeness.lean`
- Every declaration name added resolves in Lean source at the file it is cited from

---

### Phase 7: Dead-Link Repair and Stale Prose Paths [NOT STARTED]

**Goal**: Take the report §6.1 resolver command to zero lines, and clear the non-link stale
paths that no link checker can see.

**Tasks**:
- [ ] Record the current count with the report §6.1 resolver command before editing
- [ ] **Class A** (12 sites) — case-wrong `Development/` -> `development/`: `user-guide/tutorial.md:425,430,431,432`; `user-guide/architecture.md:1380,1381,1383`; `user-guide/tactic-development.md:789,790`; `user-guide/tactic-development.md:182` and `reference/operators.md:312,360` (depth **and** case)
- [ ] **Class B** (24 sites) — `../../../` and `../../` escapes resolving outside the repository. Per-line targets in report §6.2; nine of these disappear for free because Phase 1 deleted their host file or target
- [ ] **Class C** (9 sites) — never-existed targets `METHODOLOGY.md` and `research/layer-extensions.md`: **delete the link**, keep the prose
- [ ] **Class D** (6 sites) — case-wrong filenames: `BFMCS_architecture.md` -> `BFMCS_ARCHITECTURE.md` at `docs/README.md:145` and `architecture/README.md:35`; `dual-verification.md` / `proof-library-design.md` -> uppercase at `user-guide/architecture.md:1240,1244,1378,1379` (four the review did not enumerate)
- [ ] **Class E** (4 sites) — wrong depth from `docs/reference/`: `operators.md:3,359,361,362` use `../../user-guide/`, should be `../user-guide/`
- [ ] **Class F** (6 sites) — `.claude/` links: convert to **unlinked prose** rather than repointing (report §9.2). `.claude/` is a gitignored, regenerable deploy artifact; a committed document linking into it is dead in a fresh clone and is itself a drift source
- [ ] **Class G** (3 sites) — root `TODO.md` moved to `specs/TODO.md`
- [ ] **Class H** (5 sites) — archived task directories: **delete, do not repoint**. `192_` and `174_` were renumbered and now name entirely different tasks; `.claude/rules/no-task-references-in-deliverables.md` forbids the citation regardless
- [ ] **Class I** (1 link + 25 non-link prose paths) — stale `Logos/Core/` root. Only `tactic-registry.md:173` is a markdown link; the other 25 are bare paths in tables and prose, invisible to any link checker (report F7's blind spot). Sites: `tactic-registry.md:15-24,34-36,173`; `research/proof-search-automation.md:420-422,425,426`; `user-guide/examples.md:12`; `development/CONTRIBUTING.md:130,394`; `development/DOC_QUALITY_CHECKLIST.md:475`. Real target is `FormalSystem/Automation/Tactics/` — note it is a **directory**, as are `FormalSystem/Automation/ProofSearch/` and `FormalSystem/Theorems/Propositional/`
- [ ] **Class J** (3 sites) — `Bimodal/` two-tree merge leftovers: `development/BENCHMARKING_GUIDE.md:86,228` -> `../project-info/performance-targets.md`; `development/PROPERTY_TESTING_GUIDE.md:712` -> a nonexistent `Tests/BimodalTest/Core/Property/`, delete the link
- [ ] Leave the three ignore-classes alone: `development/DIRECTORY_README_STANDARD.md` (18 template snippets), `reference/readme-standard.md:72,73` (same class), `project-info/MAINTENANCE.md:463,466` (grep patterns inside a bash fence)

**Timing**: 2 hours

**Depends on**: 6

**Verification Tier**: prose

**Scope Hypothesis**: 74 genuinely actionable dead links (96 total, less 18 template snippets,
less 2 grep-fence false positives, less 2 `readme-standard.md` template illustrations), plus 25
non-link stale prose paths. The task description's figure of 94 is **not reproducible** and must
not be used as a gate. Confirm by running the report §6.1 resolver command before and after; the
gate is **zero lines returned**, not a count matching this hypothesis.

**Files to modify**:
- Approximately 20 files across `docs/` — see report §6.2 for the complete per-line table

**Verification**:
- The report §6.1 resolver command returns **0 lines**
- `grep -rn 'Logos/' docs/` is empty
- `grep -rn 'Bimodal/' docs/` is empty (excluding `Tests/BimodalTest`, which is a real path)
- `grep -rn '\.\./\.\./\.\./' docs/` is empty
- No new link points into `.claude/`

---

### Phase 8: Guard Part 1 — C12 and C13 [NOT STARTED]

**Goal**: Add the two resolution checks that would have caught this task's link and path defects,
following the script's own established check idiom.

**Tasks**:
- [ ] Read `scripts/check-module-invariants.sh`'s existing idiom for C5/C8/C9/C10: an `ENFORCE_Cn` flag, a computation, `pass`/`fail`/`soft` + `note`, and an optional companion allowlist file. C1-C11 exist; C12 and C13 are the next free numbers
- [ ] **C12 — slash-path resolution in markdown.** Assert that every `FormalSystem/...`, `Tests/...`, `Logos/...`, `Bimodal/...` slash-shaped path in non-`specs` markdown resolves to a file or directory (try bare, `.lean`, `.md`, and trailing `/`). This is the check that closes report F7: C5 matches **dotted** names via `\b(?:FormalSystem|BimodalTest)(?:\.[A-Z][A-Za-z0-9_]*)+` and is blind to the slash form, which is why `BFMCS_ARCHITECTURE.md`'s dead source table passed a green gate
- [ ] **Do not modify C5's regex.** Extending it to `Bimodal.*` would immediately fail the gate on occurrences in `FormalSystem/**/README.md`, outside this task's `file_scope` (report F8)
- [ ] **C13 — markdown link resolution.** Assert that every relative markdown link in `docs/` and `README.md` resolves. Implement the three documented ignore-paths (`development/DIRECTORY_README_STANDARD.md`, `reference/readme-standard.md`, `project-info/MAINTENANCE.md`) via a companion **allowlist file**, not hardcoded exclusions, so a future surprise is recorded rather than forcing an out-of-scope edit
- [ ] Enforce both at once: Phase 7 clears their debt, so both should report a real zero, not a soft note
- [ ] Verify both checks actually fail when they should: temporarily introduce one broken slash path and one broken link, confirm each check reports it, then revert

**Timing**: 1.5 hours

**Depends on**: 7

**Verification Tier**: full

**Scope Hypothesis**: C12's initial debt was measured at 85 unresolved slash-paths across
`docs/` + `README.md` (69 after the Phase 1 deletions, 0 after Phase 7); C13's at 96 links
before the ignore-classes. Confirm by running each new check immediately after writing it and
before enabling enforcement; if either reports a non-zero count after Phase 7, repair the
residue in this phase rather than weakening the check.

**Files to modify**:
- `scripts/check-module-invariants.sh` - add C12 and C13
- A new allowlist file for C13's three ignore-paths (path per the script's existing companion-file convention)

**Verification**:
- `bash scripts/check-module-invariants.sh` -> ALL CHECKS PASSED, with C12 and C13 both reporting real (non-skipped, non-soft) results
- Negative test: an injected broken slash path fails C12; an injected broken link fails C13; both revert cleanly

---

### Phase 9: Guard Part 2 — C14, the C9 Extension, and `readme-lint.sh` Scope [NOT STARTED]

**Goal**: Add the status-claim tripwire the task actually asks for, record the task-citation
invariant without blocking, and extend the lint's scope.

**Tasks**:
- [ ] **C14 — status-claim tripwires.** Assert (i) the documented sorry count is 0 and the documented axiom count is 45, by grepping `docs/` for the stale literals and for any `sorries | [1-9]`-shaped table row; and (ii) with `--no-build` off, that `#print axioms` for the headline theorems matches a recorded baseline. This is the check the task description asks for: "diffs documented status/axiom tables against actual `#print axioms` output and the C3 sorry inventory"
- [ ] Implement C14's `#print axioms` half by reusing C2's existing machinery **verbatim** (`check-module-invariants.sh:122-163`): write a scratch `.lean`, `lake env lean` it, rejoin the pretty-printer's continuation lines with the `sed` idiom already at `:147-148`, compare to a baseline heredoc. Extend C2's four-theorem list to include `sound_of_isValid` and `completeness_dedekind`, so gaps G1 and G3 are pinned by the build rather than by prose
- [ ] **C9 over `docs/`** (report §9.1): add the computation with `ENFORCE_C9_DOCS=${ENFORCE_C9_DOCS:-0}` — the script's own documented pattern (`:52-58`) for an end-state invariant the tree does not yet satisfy. This makes the 152 remaining task-number citations (100 of them in `PHASED_IMPLEMENTATION.md`) visible at every gate without blocking this task. Do **not** silently omit the check; do **not** enforce it here
- [ ] **`readme-lint.sh` scope extension** (6b-ii): (a) iterate over `*.md` rather than only files literally named `README.md` when the root is not a Lean tree, or accept multiple roots — today it opens 6 of 72 files in `docs/`, and its Check 1 fires only on directories containing `.lean` files, so it is structurally inert outside a Lean tree; (b) **document** rather than enforce Check 2's `NOT LISTED` hits in the summary block — enforcing would convert ~110 cosmetic warnings into gate failures (see Non-Goals)
- [ ] Document C12, C13, C14, and the `ENFORCE_C9_DOCS` flag in `docs/development/MODULE_INVARIANTS.md` (or the script's own header, matching where C1-C11 are documented)
- [ ] Negative-test C14: temporarily reintroduce a stale sorry count in a `docs/` table, confirm the check fails, revert

**Timing**: 2 hours

**Depends on**: 5, 8

**Verification Tier**: full

**Scope Hypothesis**: The C9-over-`docs/` computation is expected to report **152** task-number
citations (180 before the Phase 1 deletions), 100 of them in
`docs/development/PHASED_IMPLEMENTATION.md`. Confirm by running the check once written; the
number is reported, not gated, so a divergence is recorded rather than fixed here.

**Files to modify**:
- `scripts/check-module-invariants.sh` - add C14 and the soft C9-over-`docs/` computation
- `scripts/readme-lint.sh` - scope extension
- `docs/development/MODULE_INVARIANTS.md` - document the new checks and flag

**Verification**:
- `bash scripts/check-module-invariants.sh` -> ALL CHECKS PASSED, C14 reporting a real result
- `bash scripts/check-module-invariants.sh --no-build` -> ALL CHECKS PASSED, C14 skipping its `#print axioms` half cleanly
- `ENFORCE_C9_DOCS=1 bash scripts/check-module-invariants.sh` fails with a count, confirming the computation is live and not a stub
- `bash scripts/readme-lint.sh` -> `Missing READMEs: 0`, exit code unchanged in meaning
- Negative test on C14 fails as expected and reverts cleanly

---

### Phase 10: Final Verification Gate [NOT STARTED]

**Goal**: Run the task's stated verification gate end to end and record the closing figures.

**Tasks**:
- [ ] `bash scripts/check-module-invariants.sh` -> ALL CHECKS PASSED, including C12, C13, C14
- [ ] `bash scripts/readme-lint.sh` -> missing-README count 0
- [ ] Report §6.1 resolver command -> 0 lines
- [ ] Confirm no `.lean` declaration, signature, import, or tactic changed: `git diff --stat` over `*.lean` should show only `FormalSystem/Metalogic/README.md` (markdown) and the nine new READMEs (markdown) — zero `.lean` files
- [ ] Re-derive and record the closing ground truth: file/line counts via `cloc`, axiom constructor count via `Axiom.minFrameClass`, sorry count via C3
- [ ] Record in the implementation summary: the actual dead-link count repaired against the 74 hypothesis, the actual `SORRY_REGISTRY` inbound count against the 15 hypothesis, and the C9-over-`docs/` figure against the 152 hypothesis

**Timing**: 0.5 hours

**Depends on**: 9

**Verification Tier**: full

**Files to modify**:
- None (verification only; findings go to the implementation summary)

**Verification**:
- All four gate commands pass as stated above
- `git diff --name-only` contains no `.lean` file

---

## Testing & Validation

- [ ] `bash scripts/check-module-invariants.sh` reports ALL CHECKS PASSED, with C12, C13, and C14 present and reporting real (non-skipped) results
- [ ] `bash scripts/check-module-invariants.sh --no-build` also passes, with C14's `#print axioms` half skipping cleanly
- [ ] `bash scripts/readme-lint.sh` reports `Missing READMEs: 0` and `Broken file references: 0`
- [ ] The report §6.1 link resolver returns zero lines over `docs/`
- [ ] `grep -rn '\b21 axiom\|14 axiom\|~40 \|~8000\|44 constructor\|Lacunae\|Logos/' docs/` is empty
- [ ] All 15 gap-coverage grep terms from report §7 hit at least one `docs/` file
- [ ] No `.lean` file appears in `git diff --name-only`
- [ ] Negative tests for C12, C13, and C14 each fail on an injected defect and revert cleanly

## Artifacts & Outputs

- `specs/486_docs_overhaul_deletions_links_gaps_and_drift_guard/plans/01_docs-overhaul-and-drift-guard.md` (this file)
- `specs/486_docs_overhaul_deletions_links_gaps_and_drift_guard/summaries/NN_docs-overhaul-summary.md`
- Two deleted files: `docs/project-info/SORRY_REGISTRY.md`, `docs/project-info/IMPLEMENTATION_STATUS.md`
- Nine new `FormalSystem/**/README.md` files
- One new allowlist companion file for C13
- Modified: approximately 25 files under `docs/`, `scripts/check-module-invariants.sh`, `scripts/readme-lint.sh`, `FormalSystem/Metalogic/README.md` (two numerals)

## Rollback/Contingency

The task is prose, markdown, and two shell scripts; nothing here can break the Lean build, and
Phase 10 asserts that no `.lean` file was touched. Rollback is therefore per-phase and cheap:

- **Per phase**: `git revert` the phase's commits. Waves 1 and 2 are file-disjoint, so a single
  phase can be reverted without disturbing its siblings.
- **Phase 1 (deletions)**: the two deleted files remain recoverable from history. If the
  `MAINTENANCE.md` procedure rewrite proves unworkable, the report's documented fallback is to
  excise the four `SORRY_REGISTRY` rows and leave the remaining three-document flow intact.
- **Phases 8-9 (the guard)**: if a new check proves too noisy or produces false failures, demote
  it to the script's soft-enforcement idiom (`ENFORCE_Cn=${ENFORCE_Cn:-0}`) rather than deleting
  it — the invariant stays recorded and progress stays visible. Do not weaken C5, which is
  untouched by design.
- **If a phase runs long**: mark it `[PARTIAL]` and resume. No phase leaves the repository in a
  state that fails the pre-existing gate, since C12/C13/C14 do not exist until Phase 8.
