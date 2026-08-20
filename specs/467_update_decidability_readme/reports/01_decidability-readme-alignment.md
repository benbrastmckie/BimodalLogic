# Research Report: Task #467

**Task**: 467 - Systematically update FormalSystem/Metalogic/Decidability/README.md to be aligned with the current state of the Decidability/ directory
**Started**: 2026-08-20T01:35:00Z
**Completed**: 2026-08-20T01:42:00Z
**Effort**: small-medium (documentation-only; no proof changes)
**Dependencies**: None
**Sources/Inputs**:
- Codebase: `FormalSystem/Metalogic/Decidability/**` (all `.lean` and `README.md` files)
- Codebase: `FormalSystem/Metalogic/Decidability.lean` (the aggregator/import root)
- `git log` on the README and on undocumented files
**Artifacts**:
- This report: `specs/467_update_decidability_readme/reports/01_decidability-readme-alignment.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The top-level `Decidability/README.md`'s central claim — that the directory "decides
  validity of TM bimodal logic formulas" — **overclaims what is proven**. `Correctness.lean`
  explicitly documents (in a section titled "`validity_decidable` / `validity_has_decision_procedure`
  — Retired as vacuous") that only the sound direction (`decide_sound`: a `.valid` witness implies
  `⊨ φ`) is established; the full decidability biconditional `isValid φ fc = true ↔ ⊨ φ` is stated
  as "still owed" / "open". This is the single highest-priority correction.
- The **Modules table is missing two entire subdirectories** (`Verified/`, 21 files — the
  correctness theory; `Propositional/`, 3 files — the propositional-fragment decision procedure)
  and **three top-level files** (`CancellableExpansion.lean`, `TraceCertificate.lean`,
  `TraceExport.lean`), despite all being imported by the `Decidability.lean` aggregator (or, for
  `TraceCertificate.lean`, by both `Saturation.lean` and `DecisionProcedure.lean` directly).
- The `FMP.lean` module-table row is a **factual error**: it lists `FMP.lean` as a top-level
  sibling of `DecisionProcedure.lean` etc., but no such file exists at
  `Decidability/FMP.lean` — the re-export lives at `Decidability/FMP/FMP.lean`, inside the
  subdirectory the table already lists separately.
- The **Dependency Flowchart has the Correctness/DecisionProcedure edge backwards** and omits
  `TraceCertificate.lean` (imported directly by both `Saturation.lean` and `DecisionProcedure.lean`)
  and the `FMP` edge out of `Correctness.lean`.
- The `DecisionResult` type description in Quick Reference is **stale**: it says
  "(valid/invalid/timeout)"; post-R7 the single `timeout` constructor was split into
  `fuelExhausted` and `extractionFailed` (see `decide_result_exclusive` in `Correctness.lean`).
- The entire directory tree (all 60 `.lean` files under `Decidability/`, including `Verified/`
  and `Propositional/`) is **actually sorry-free**; the 8 occurrences of the word "sorry" found by
  `grep` are all inside doc-comment prose ("sorry-free", "no `sorry`") describing other things,
  not live `sorry` tactic uses. This is consistent with, and should be preserved by, the README's
  existing "Sorry-free" claims.
- "Related Documentation" is missing links to `Verified/README.md` and `Propositional/README.md`,
  both of which exist.
- The footer's "*Last verified: 2026-05-29*" stamp is stale — the file was last git-modified
  2026-08-17 (task 417 phase 12.5) and today is 2026-08-19/20.

## Context & Scope

Scope per the task: compare `FormalSystem/Metalogic/Decidability/README.md`'s claims (module
table, quick reference, algorithm overview, dependency flowchart, complexity, related docs)
against the actual current directory contents — files, module structure, sorry inventory, import
graph, and subdirectories — and record every concrete correction needed. This report does not
edit the README; it hands a full correction list to the planning/implementation phase.

The directory as of this research pass contains, under `FormalSystem/Metalogic/Decidability/`:

- 13 top-level `.lean` files (README currently documents 9 of them, correctly, plus one — `BiLasso.lean`
  — correctly, plus one that does not exist — `FMP.lean`).
- 4 subdirectories: `FMP/` (6 `.lean` + README), `BiLasso/` (18 `.lean` + README), `Verified/`
  (21 `.lean`, includes `Verified/Bridge/` and `Verified/Termination/` sub-subdirectories, + README),
  `Propositional/` (3 `.lean` + README). The README's Modules table covers `FMP/` and `BiLasso/`
  only; `Verified/` and `Propositional/` are entirely absent.

## Findings

### 1. Overview section overclaims decidability (highest priority)

**README text (Overview)**:
> This directory implements a verified decision procedure that:
> - Decides validity of TM bimodal logic formulas
> - Returns proof terms (`DerivationTree`) when valid
> - Returns countermodel descriptions when invalid
> - Uses fuel-based termination for practical execution

**Actual state**, per `Correctness.lean` (lines ~68-105), under the heading
"`validity_decidable` / `validity_has_decision_procedure` — Retired as vacuous":

- The module records that two previously-existing theorems with those names were **removed**
  because their names claimed a decidability result their proofs did not establish — one was
  `Classical.em (⊨ φ)` in disguise, the other an unwitnessed existential built the same way.
- What is actually proved is **one direction only**: `decide_sound (φ) (d : ⊢ φ) : ⊨ φ` — if
  `decide` returns `.valid proof`, then `φ` is semantically valid (soundness of the *witness*,
  not decidability of validity).
- The converse/full statement the directory would need to honestly claim "decides validity" —
  `isValid φ fc = true ↔ ⊨ φ`, plus `Decidable (⊨ φ)` instances for the four frame classes — is
  explicitly named as **not yet proved** ("That obligation is open... No such statement is
  written here until it can be proved.").
- `BiLasso/README.md` independently corroborates this: "**This directory does not decide the
  logic.** `cor:tm-decidability` records decidability of TM as open."

**Correction needed**: the Overview's bullet "Decides validity of TM bimodal logic formulas"
should be replaced with language that matches what is actually proved — e.g., "implements a
tableau-based procedure that searches for a proof or a countermodel, with the soundness direction
machine-checked (`decide_sound`); full decidability (validity ↔ `isValid` reporting `true`) is not
yet established — see `Correctness.lean`'s 'Retired as vacuous' section." The README should not
independently repeat the overclaim that the codebase itself deliberately walked back.

### 2. Modules table: missing files and subdirectories

Not listed in the README's Modules table, but present and (mostly) imported by the
`Decidability.lean` aggregator:

| Missing item | Size | Sorry | Imported by aggregator? | Notes |
|---|---|---|---|---|
| `CancellableExpansion.lean` | 350 lines | 0 | No | Runtime-only `IO` abort-aware mirror of the pure tableau core (`expandBranchWithFuel → saturateBlocked → buildTableau → decide → decideAutoAdaptive`); imports `Saturation.lean` and `DecisionProcedure.lean` |
| `TraceCertificate.lean` | 316 lines | 0 | Yes | Defines `TraceEntry`/`ProofCertificate`/`TraceResult`; imported directly by both `Saturation.lean` and `DecisionProcedure.lean` — this is a core dependency, not a peripheral one |
| `TraceExport.lean` | 223 lines | 0 | No (imported by `FormalSystem/Automation/TraceExporter.lean`, `DatasetGenerator.lean`, and three test files, plus `lakefile.lean`) | JSON serialization for trace certificates |
| `Verified/` (21 files: `RuleSpec.lean`, `Decidable.lean`, `Termination/*.lean` ×4, `Bridge/*.lean` ×15) | — | 0 (4 occurrences of the word "sorry" are prose, e.g. "both sorry-free") | Yes — 20 of the 21 files are imported directly by the aggregator (only `RuleSpec.lean`... actually all listed ones are imported; see aggregator import list) | The correctness theory for the engine, kept beside it per its own README. Has its own `Verified/README.md` |
| `Propositional/` (3 files: `PropForm.lean`, `Kalmar.lean`, `Decidable.lean`) | — | 0 (1 prose occurrence) | Yes — all three imported by the aggregator | Self-contained Kalmár-style propositional decision procedure; independent of the modal/temporal/completeness machinery. Has its own `Propositional/README.md` |

Both `Verified/` and `Propositional/` are directly imported by
`FormalSystem/Metalogic/Decidability.lean` (confirmed by reading its import block — 30 imports
total, spanning `SignedFormula` through `Verified.Decidable`), so their absence from the top-level
README's Modules table is not a matter of them being unwired or experimental; they are part of
the live build graph.

**Correction needed**: add rows (or a rows-plus-subtable, matching the existing `FMP/`/`BiLasso/`
row style) for `CancellableExpansion.lean`, `TraceCertificate.lean`, `TraceExport.lean`,
`Verified/`, and `Propositional/`.

### 3. `FMP.lean` row is a factual error

**README text**: `| \`FMP.lean\` | Re-export for FMP subdirectory | Sorry-free |` — listed as a
top-level file alongside `DecisionProcedure.lean`, `IntPresentation.lean`, etc.

**Actual state**: `ls FormalSystem/Metalogic/Decidability/FMP.lean` → does not exist. The
re-export file is `FormalSystem/Metalogic/Decidability/FMP/FMP.lean`, i.e., *inside* the `FMP/`
subdirectory that the table already lists as its own row ("`FMP/` | Finite model property proofs
(7 files) | Sorry-free"). There is no top-level `Decidability/FMP.lean` sibling file, unlike the
`BiLasso.lean` row immediately below it, which correctly names a real top-level re-export file
(`Decidability/BiLasso.lean` does exist and does re-export the `BiLasso/` subdirectory).

**Correction needed**: delete the `FMP.lean` row (or, if the intent was to note that the
subdirectory contains its own internal re-export file `FMP/FMP.lean`, fold that detail into the
`FMP/` row's description instead, the way `BiLasso/`'s row already explains its own entry point
`check`).

### 4. File-count convention is inconsistent between rows

- `FMP/ (7 files)`: counts 6 `.lean` files + 1 `README.md` = 7.
- `BiLasso/ (18 files)`: counts 18 `.lean` files only (19 total files including its `README.md`).

Both are individually defensible but use different counting rules, which will read as an error
once `Verified/` (21 `.lean` files, 22 with README) and `Propositional/` (3 `.lean`, 4 with
README) rows are added. **Correction needed**: pick one convention (recommend "`.lean` files
only", matching the `BiLasso/` row and matching what a reader most likely wants to know) and apply
it uniformly: `FMP/ (6 files)`, `BiLasso/ (18 files)`, `Verified/ (21 files)`,
`Propositional/ (3 files)`.

### 5. Sorry inventory: README's "Sorry-free" claims are correct today (no change needed here)

Every `.lean` file under `Decidability/`, including `Verified/` and `Propositional/`, has zero
live `sorry` uses. `grep -rn '\bsorry\b'` over the whole tree returns exactly 8 hits, all inside
doc-comment prose describing files as "sorry-free" or explaining what "no `sorry`" would mean —
none are actual tactic-block `sorry`s. This confirms the existing "Sorry-free" column values in
the README's table are accurate and should be preserved (and extended to the new rows added per
Finding 2, all of which are also sorry-free).

### 6. Quick Reference: `DecisionResult` variant list is stale

**README text**: "**Result type**: `DecisionResult` (valid/invalid/timeout)"

**Actual state**: `Correctness.lean`'s `decide_result_exclusive` theorem documents (and its
docstring states explicitly) that "Post-R7 this is a four-way exclusivity statement: the former
`timeout` constructor was split into `fuelExhausted` (validity genuinely undetermined) and
`extractionFailed` (the tableau closed, so the formula is valid, but no proof term was
reconstructed)." `DecisionProcedure.lean`'s `decide` docstring lists all four outcomes:
`valid proof`, `invalid counter`, `fuelExhausted`, `extractionFailed`.

**Correction needed**: change "(valid/invalid/timeout)" to
"(valid/invalid/fuelExhausted/extractionFailed)".

### 7. Quick Reference: entry points list is incomplete (minor)

`DecisionProcedure.lean` now exposes, beyond `decide`/`isValid`/`isSatisfiable`: `decideBlocking`
(a documented complement to `decide` for the blocking-aware engine — "It is a complement, not a
substitute"), `decideAuto`, `decideAutoAdaptive`, `decideBatch`, `decideOptimized`,
`decideWithTrace`, `decideAutoWithTrace`. Not all of these necessarily belong in a terse Quick
Reference, but `decideBlocking` is architecturally significant (a second top-level entry point
with a documented, non-overlapping purpose) and is a reasonable minimum addition. Treat the rest
as optional/lower-priority.

### 8. Dependency Flowchart: backwards edge and missing nodes

**Actual import graph** (from each file's own `import` lines):

```
SignedFormula.lean            (no internal imports — base)
  └─ Tableau.lean
       └─ Closure.lean
            └─ Saturation.lean  ── also imports TraceCertificate.lean
                 ├─ ProofExtraction.lean
                 └─ CountermodelExtraction.lean
                      └─ DecisionProcedure.lean  ── also imports TraceCertificate.lean
                           └─ Correctness.lean  ── also imports FMP/FMP.lean
```

(`IntPresentation.lean` imports `FMP/Periodicity.lean` independently; `BiLasso.lean` imports the
18 `BiLasso/*.lean` files and is not itself imported by the aggregator or by anything in
`FormalSystem/`, only by `Tests/BimodalTest/Metalogic/PeriodicExtensionAxiomTest.lean` — the
README's existing claim that it is "outside the build graph" is essentially accurate for the main
library, modulo that one test importer, which is worth a one-word caveat rather than a rewrite.)

**README's diagram** draws `DecisionProcedure.lean` at the *top*, flowing down through
`ProofExtraction`/`CountermodelExtraction` into `Correctness.lean`, then down through
`Saturation.lean` → `Closure.lean` → `Tableau.lean` → `SignedFormula.lean`.

**The `Correctness.lean` edge is backwards.** `Correctness.lean` *imports* `DecisionProcedure.lean`
(depends on it), it is not depended upon by it. The diagram should show `Correctness.lean` as a
downstream consumer of `DecisionProcedure.lean` (drawn below/after it, or with the arrow direction
reversed), not as an intermediate layer between `DecisionProcedure` and
`ProofExtraction`/`CountermodelExtraction`.

**Missing from the diagram**: `TraceCertificate.lean` (a direct import of both `Saturation.lean`
and `DecisionProcedure.lean` — i.e., load-bearing at two points in the real chain) and the
`Correctness.lean → FMP/FMP.lean` edge. `IntPresentation.lean`, `CancellableExpansion.lean`,
`TraceExport.lean`, `BiLasso.lean`, and the `Verified/`/`Propositional/` subtrees are absent
entirely, which is defensible for a "core chain only" diagram as long as the diagram is captioned
as such — but the backwards `Correctness` edge should be fixed regardless of how much breadth is
added.

### 9. Related Documentation: missing links

**README text** currently links: Metalogic README, Bundle README, Core README, FMP README,
BiLasso README.

**Missing**: `Verified/README.md` and `Propositional/README.md` both exist at
`FormalSystem/Metalogic/Decidability/Verified/README.md` and
`FormalSystem/Metalogic/Decidability/Propositional/README.md` respectively, and both already
link back to the parent `Decidability/README.md` (reciprocal links exist on their side). The
top-level README should link to both, matching the existing FMP/BiLasso pattern.

**Caveat for the implementer**: `Verified/README.md` is itself substantially stale — its own
"Layout" status table marks `Termination/TimeTypeBound.lean`, `Termination/Fuel.lean`,
`Bridge/Carrier.lean`, `Bridge/BranchOrder.lean`, `Bridge/Embed.lean`, `Bridge/Interpolate.lean`,
`Bridge/TruthLemma.lean`, and `Decidable.lean` as "planned", though all of these files exist,
compile, and are sorry-free (imported by the aggregator today). It is also missing 11 files
entirely from its table (`MintBound.lean`, `RegionFrame.lean`, `Valuation.lean`,
`BoxSaturation.lean`, `PropSaturation.lean`, `TemporalSaturation.lean`, `RegionLabel.lean`,
`TemporalGate.lean`, `IntGaps.lean`, `IntTruth.lean`, `DenseTruth.lean`) and lists two files that
do not exist (`Internalize.lean`, `Refutation/Core.lean`, `Refutation/Rules/*.lean`,
`Bridge/Omega.lean`, `Provable.lean` — all marked "planned"/"deferred", consistent with not
existing yet). This is **out of the literal scope of task 467** (which targets the top-level
`Decidability/README.md` only), but linking to a README this stale from the now-corrected
top-level README will read oddly; recommend either (a) flagging `Verified/README.md`'s staleness
as a natural follow-up task, or (b) if time permits within this task, doing a lighter-touch pass
there too. Left to the planning phase to decide scope.

### 10. Footer timestamp is stale

`*Last verified: 2026-05-29*` — the README file was last git-modified 2026-08-17 (commit
`40e831c44`, "task 417 phase 12.5: finalise BiLasso README and Decidability module table"), and
today's date is 2026-08-19/20. The stamp should be updated to the date this task's corrections
land, consistent with the file's own convention of tracking the last substantive review date.

### 11. Items checked and found accurate (no change needed)

- **Quick Reference boolean helpers** `isValid`, `isSatisfiable` — both exist in
  `DecisionProcedure.lean` with the documented signatures.
- **Usage code block** (`#check decide`, `#check isValid`, `#check isSatisfiable`) — all three
  still resolve under `import FormalSystem.Metalogic.Decidability`.
- **Algorithm Overview** (optimization fast-path → tableau → branch analysis) — matches `decide`'s
  actual structure in `DecisionProcedure.lean` (axiom-proof fast path → compositional-proof fast
  path → bounded proof search → tableau fallback → closed/open branch analysis).
  `decideBlocking`'s existence (Finding 7) doesn't invalidate this description of `decide` itself.
  Complexity claims (`O(2^n)`, PSPACE-complete) are informal/architectural, not a Lean-proved
  complexity-class theorem in this directory; leaving them as descriptive prose is fine, but they
  should not be conflated with the (also informal) decidability claim corrected in Finding 1 —
  those are two different, both-currently-unformalized statements.
- **BiLasso/ row's "not itself imported" / "outside the build graph"** — accurate for the main
  library build graph; the one test importer (`PeriodicExtensionAxiomTest.lean`) is a minor
  nuance, not a contradiction, and does not need a table change (optionally a one-word caveat).
- **`IntPresentation.lean` description** ("Computational presentation of a finite ℤ-time frame")
  matches its actual import of `FMP/Periodicity.lean` and its role as `BiLasso`'s presentation
  substrate.

## Decisions

- Scope the corrections to `Decidability/README.md` itself, per the task; treat
  `Verified/README.md`'s independent staleness (Finding 9's caveat) as a flagged adjacent issue
  rather than in-scope work, pending a planning-phase call on whether to fold it in.
- Recommend the "count `.lean` files only" convention for subdirectory file counts (Finding 4) to
  resolve the FMP/BiLasso inconsistency when new subdirectory rows are added.
- Recommend fixing the `Correctness.lean` edge direction in the dependency flowchart (Finding 8)
  as a correctness fix, independent of how much additional breadth (Verified/, Propositional/,
  Trace*) the planning phase decides to add to the diagram.

## Risks & Mitigations

- **Risk**: rewriting the Overview's decidability claim (Finding 1) touches load-bearing framing
  language that other documentation (e.g., `Metalogic/README.md`, task descriptions) may quote or
  assume. **Mitigation**: the correction only needs to remove the overclaim and point to
  `Correctness.lean`'s own retirement note — it does not require inventing new claims, and
  `BiLasso/README.md` already demonstrates the accurate phrasing pattern ("does not decide the
  logic... records decidability of TM as open").
- **Risk**: adding full rows for `Verified/` (21 files) and `Propositional/` (3 files) could bloat
  the top-level table. **Mitigation**: follow the existing `FMP/`/`BiLasso/` row style — one
  summary row per subdirectory with a file count and a link to that subdirectory's own README,
  not a full per-file breakdown (the sub-READMEs already carry that detail, once `Verified/`'s is
  fixed).

## Context Extension Recommendations

- **Topic**: `Verified/README.md` accuracy.
  **Gap**: as detailed in Finding 9's caveat, this sub-README's status table is drastically out of
  date (8+ files marked "planned" that are actually complete and imported; 11 files missing from
  the table entirely).
  **Recommendation**: file or spawn a follow-up task specifically for
  `FormalSystem/Metalogic/Decidability/Verified/README.md`, structured the same way as this task.

## Appendix

Commands used (representative, run against repo root
`/home/benjamin/Projects/BimodalLogic`):

```
find FormalSystem/Metalogic/Decidability -type f | sort
cat FormalSystem/Metalogic/Decidability/README.md
grep -rn '\bsorry\b' FormalSystem/Metalogic/Decidability --include='*.lean'
grep -n '^import FormalSystem.Metalogic.Decidability' FormalSystem/Metalogic/Decidability/*.lean
cat FormalSystem/Metalogic/Decidability.lean   # the aggregator/import root
cat FormalSystem/Metalogic/Decidability/Verified/README.md
cat FormalSystem/Metalogic/Decidability/Propositional/README.md
cat FormalSystem/Metalogic/Decidability/FMP/README.md
sed -n '1,110p' FormalSystem/Metalogic/Decidability/Correctness.lean
grep -n 'def decide\b|def isValid\b|def isSatisfiable\b|def buildTableau\b' FormalSystem/Metalogic/Decidability/*.lean
git log -1 --format='%ai' -- FormalSystem/Metalogic/Decidability/README.md
git log -p -1 -- FormalSystem/Metalogic/Decidability/README.md
```
