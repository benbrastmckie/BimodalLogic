# Research Report: Orphan Triage — Metalogic Import Closure (Task 385)

- **Task**: 385 `orphan_triage_metalogic_import_closure`
- **Session**: sess_1784886673_059c3f_385
- **Agent**: lean-research-hard-agent (H2/H3/H4 contracts active; H5 not triggered — no "divergence"/"audit" focus)
- **Date**: 2026-07-24
- **Reference grounding tier**: Tier 3 (implementation-backed — grounded in the repo tree, lakefile, git history, and `specs/reviews/review-2026-07-24-metalogic-cleanup.md` §2.2/§3.2/§3.3). The `--lit` briefing (12 documents: Rabinovich, Kamp, Gabbay–Hodkinson–Reynolds, Burgess) was loaded and is **not relevant** to this repo-hygiene task; no literature claims are load-bearing here.

## Executive Summary

Independent recomputation of the import closure **confirms the review's 21-file / 4,837-LOC orphan list exactly**, with two corrections the review missed because it used only the `Bimodal` library root:

1. `Decidability/TraceExport.lean` is **NOT dead** — it is compiled via `lake exe trace_exporter` (`Automation/TraceExporter.lean:12`) and by two test files. Verdict: **KEEP**.
2. The "dead" aggregator `Theories/Bimodal/Metalogic.lean` **is compiled by the test suite** — 6 files under `Tests/BimodalTest/Integration/` do `import Bimodal.Metalogic`. Verdict remains **DELETE**, but with a mandatory test-import re-point step.

Additionally, `lake build BoneyardArchive` **fails today** (measured, exit non-zero: broken imports of since-moved modules) — the review's and task-378 charter's "vacuous pass" characterization is stale. This settles the Boneyard build-policy question empirically: **adopt the never-built policy and delete the `BoneyardArchive` lean_lib**.

None of the "possibly-accidentally-dropped" files was actually accidentally dropped (git-history verified per file below); all decision-bucket files except TraceExport get **ARCHIVE** verdicts.

## Methodology (independent recomputation, H4 requirement)

Script: `scratchpad/closure.py` — parses `^import` lines of all 423 `.lean` modules under `Theories/`, computes reachability from:
- the `Bimodal` lib root (`Theories/Bimodal.lean`, per `lakefile.lean` `lean_lib Bimodal`),
- all 12 `lean_exe` roots (`Bimodal.Automation.*`, per `lakefile.lean`),
- (checked separately) the `BimodalTest` test-driver imports under `Tests/`.

Results: 423 modules total; 123 Boneyard modules (73 top-level + 50 Kamp); 38 non-Boneyard orphans vs the lib root alone. Of those 38, 17 are outside this task's Metalogic scope (14 are `Automation/*` exe roots/leaves, plus `ProofSystem/{Substitution,LinearityDerivedFacts}.lean`, `Theorems/ContextualProofs.lean` — see Adjacent Findings). The remaining **21 match the review's list file-for-file, and the LOC sum is exactly 4,837**. Zero Boneyard modules are inside the live closure (359's no-live-imports invariant already holds — confirmed independently).

Buildability was verified empirically: Lake accepts direct orphan module targets (`lake build Bimodal.Metalogic.DenseSoundness` etc. — all green except CanonicalIrreflexivity, whose dependency is bit-rotted).

## Findings — Per-File Verdict Table (21 files)

Destinations: **TB** = top-level `Theories/Bimodal/Boneyard/`, **KB** = `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Boneyard/`.

| # | File (under `Theories/Bimodal/`) | LOC | Sorries | Verdict | Rationale |
|---|---|---|---|---|---|
| 1 | `Metalogic.lean` | 55 | 0 | **DELETE** + re-point 6 test imports | Dead duplicate aggregator with stale status table ("Completeness \| SORRY (chronicle)"). Live aggregator is `Metalogic/Metalogic.lean` (root imports it at `Bimodal/Bimodal.lean:4`). **BUT** 6 test files import it (list below) — replace `import Bimodal.Metalogic` with `import Bimodal.Metalogic.Metalogic` (+ `import Bimodal.Metalogic.Completeness` if decl resolution requires; the dead aggregator also pulled `SoundnessLemmas.*`, transitively available via `Soundness`). Verify with `lake build BimodalTest`. Deletion precedent: `Prop35VeeLift.lean`. |
| 2 | `Metalogic/DenseSoundness.lean` | 50 | 0 | **ARCHIVE → TB** `SoundnessVariants/` | Pure alias wrapper: both theorems delegate to live `Soundness.lean` (`density_valid`:379, `axiom_dense_valid`:879). The doc-advertised names `soundness_dense` (:1193) live in `Soundness.lean`, not here. `git log -S "import Bimodal.Metalogic.DenseSoundness" -- 'Theories/**'` is EMPTY — never imported on main; not "accidentally dropped", never wired. Compiles green, so RE-IMPORT is possible but would only add duplicate alias surface (§2.3 of the review counts alias stacks as debt). Doc fixes: `Metalogic/README.md:46`, `typst/SYNC-MAP.md:176,180`, `Metalogic/Metalogic.lean:75`. |
| 3 | `Metalogic/DiscreteSoundness.lean` | 52 | 0 | **ARCHIVE → TB** `SoundnessVariants/` | Same as #2 (`discreteness_forward_valid`:394, `axiom_discrete_valid`:928, `soundness_discrete`:1338 all live in `Soundness.lean`). One textual referencer: never-built `Boneyard/StrictSemanticsLegacy/DiscreteCompleteness.lean:3` — patch that import line to the new module path in the same move (cosmetic; the file is never compiled under the chosen policy). Doc fixes: `Metalogic/README.md:47`, `Metalogic/Metalogic.lean:76`. |
| 4 | `Metalogic/ConservativeExtension/ExtFormula.lean` | 353 | 0 | **ARCHIVE → TB** `ConservativeExtension/` (move directory as a unit) | Sorry-free, compiles green (verified), Goldblatt-1992-style conservativity infrastructure. But: built for the abandoned "substitution approach" (git: `task 958` partial commits; superseded when `canonicalR_irreflexive` was eliminated by other means, `task 967` commit dc8e7d1cc); zero consumers ever on the main-branch live tree; conservativity is not claimed in the paper (`typst/SYNC-MAP.md` maps these files to 0) nor in any flagship results table. RE-IMPORT would add ~1,600 LOC of CI surface for an unconsumed metatheorem. Archive preserves it for promotion if conservativity ever becomes a paper claim. Internal import lines (`Bimodal.Metalogic.ConservativeExtension.*` → `Bimodal.Boneyard.ConservativeExtension.*`) should be rewritten at move time for coherence. Doc fixes: `Metalogic/README.md:116,299`. |
| 5 | `Metalogic/ConservativeExtension/ExtDerivation.lean` | 287 | 0 | **ARCHIVE → TB** (with #4) | Same unit; imports ExtFormula. |
| 6 | `Metalogic/ConservativeExtension/Substitution.lean` | 262 | 0 | **ARCHIVE → TB** (with #4) | Same unit; imports ExtDerivation, ExtFormula. |
| 7 | `Metalogic/ConservativeExtension/Lifting.lean` | 698 | 0 | **ARCHIVE → TB** (with #4) | Same unit; chain top (imported by nothing). |
| 8 | `Metalogic/Decidability/FMP/DenseFMP.lean` | 112 | 0 | **ARCHIVE → TB** `FMPVariants/` | Sorry-free, green (verified). Orphaned when its importer — the itself-orphaned `Decidability/FMP.lean` aggregator — was deleted (commit ef13e2c33, "task 366 phase 4: delete orphaned Decidability/FMP.lean aggregator"); i.e. off the live build **before** 366, not accidentally dropped by it. Result `dense_fmp` referenced nowhere else in `Theories/` (grep-verified). Live FMP path (`FMP/FMP.lean` ← `Decidability/Correctness.lean`) does not need it. Doc fix: `FMP/README.md:14`. |
| 9 | `Metalogic/Decidability/FMP/DiscreteFMP.lean` | 117 | 0 | **ARCHIVE → TB** `FMPVariants/` | Same as #8; `discrete_mcs_finite_model_property` referenced nowhere else; live discrete decidability (`decide`) is sorry-free without it. Doc fix: `FMP/README.md:15`. |
| 10 | `Metalogic/Decidability/TraceExport.lean` | 221 | 0 | **KEEP — no action** (correction to review) | NOT compiled-by-nothing: imported by `Automation/TraceExporter.lean:12` (root of `lake exe trace_exporter`, lakefile.lean) and by `Tests/BimodalTest/{TraceExportTest.lean:13,TraceExporterE2ETest.lean:14}`. The review's own caveat ("check trace_exporter root") resolves to keep. |
| 11 | `Metalogic/Bundle/CanonicalIrreflexivity.lean` | 177 | 0 | **ARCHIVE → TB** `DeadCanonicalModel/` | Dead Bundle leaf; its purpose (strictness/irreflexivity infra for the canonical relation) is served on the live path since the `canonicalR_irreflexive` axiom elimination (commit dc8e7d1cc). **Does not compile today**: its dependency `ProofSystem/Substitution.lean` is bit-rotted (10+ errors at :383–:412 — stale `Formula` constructor case names). RE-IMPORT would require repairing that 459-LOC file first, for a consumer nothing needs. See Adjacent Findings for the dependency's own fate. Doc fix: `Metalogic/README.md:73`. |
| 12 | `Metalogic/WeakCanonical/Kamp/HCaptureDischarge.lean` | 117 | 1 | **ARCHIVE → KB** `ZetaProbes/` | ζ-era probe (spike file), carries a sorry, superseded by the landed ζ wire. |
| 13 | `Metalogic/WeakCanonical/Kamp/InfAlphabetProbe.lean` | 135 | 2 | **ARCHIVE → KB** `ZetaProbes/` | ζ-era probe, 2 sorries. |
| 14 | `Metalogic/WeakCanonical/Kamp/OptionBLocalityProbe.lean` | 102 | 0 | **ARCHIVE → KB** `ZetaProbes/` | ζ-era probe; sorry-free but a locality experiment, not an API. |
| 15 | `Metalogic/WeakCanonical/Kamp/PerFormulaRenderProbe.lean` | 568 | 1 | **ARCHIVE → KB** `ZetaProbes/` | Spike file; redefines `efSatFin` locally (:188 per review, i.e. shadow definitions — must never be re-imported as-is). |
| 16 | `Metalogic/WeakCanonical/Kamp/ZetaAtomMapReconcile.lean` | 182 | 0 | **ARCHIVE → KB** `ZetaProbes/` | ζ-scaffolding reconciliation, superseded by landed wire. |
| 17 | `Metalogic/WeakCanonical/Kamp/Prop43.lean` | 192 | 2 | **ARCHIVE → KB** (flat) | Orphan that itself imports `Kamp.Boneyard.{VecEA_m,EAVecNegationClosure}` — the erstwhile "live imports into Boneyard" from the 359 charter. Archiving it makes the textual situation consistent (Boneyard importing Boneyard); the no-live-imports invariant already holds (closure-verified). Its existing `Kamp.Boneyard.*` import lines remain valid unchanged after the move. |
| 18 | `Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/NavigatedEndChar.lean` | 292 | 4 | **ARCHIVE → KB** `NfMultiAnchorBridgeRetired/` | Retired k≥2 per-depth escalation path (superseded by ζ wire); imports Boneyard module `NavigatedEndCharSinglePoint`'s sibling `Lemma32Reduction`. |
| 19 | `Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorDeepExclSupplyK.lean` | 131 | 4 | **ARCHIVE → KB** `NfMultiAnchorBridgeRetired/` | Retired escalation path; only importer of #20. |
| 20 | `Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorDeepSliceSupplyK.lean` | 185 | 0 | **ARCHIVE → KB** `NfMultiAnchorBridgeRetired/` | Sorry-free but its only importer is #19 (an orphan). |
| 21 | `Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/Lemma32Reduction.lean` | 549 | 5 | **ARCHIVE → KB** `NfMultiAnchorBridgeRetired/` | Importers are #18 and Kamp-Boneyard `NavigatedEndCharSinglePoint.lean` only. Update those two import lines (plus #19→#20's) to the new module paths at move time. |

**Task-378 PRESERVE constraint verified for #18–21**: grep of all four files for `hasDefinableINF_excludes_kplus`, `lemma53`/`Basis`, `EANegationFix` — **zero hits**. The load-bearing ~29% of `NfMultiAnchorBridge` (37 live files remain after the moves) is untouched, and these are moves, not deletions, so 378's "never file deletion" is satisfied either way. `DedekindINF.lean` (378's landed asset) is live and unaffected.

### Test files requiring re-point for verdict #1

All in `Tests/BimodalTest/Integration/`: `Helpers.lean:4`, `BimodalIntegrationTest.lean:3`, `TemporalIntegrationTest.lean:3`, `ProofSystemSemanticsTest.lean:3`, `ComplexDerivationTest.lean:3`, `AutomationProofSystemTest.lean`.

## Boneyard Build Policy — Single Chosen Policy

**Chosen: NEVER-BUILT ARCHIVES.** Liveness is decided solely by reachability from `Theories/Bimodal.lean` (lib root) or a `lean_exe`/test root. Neither Boneyard participates in any build.

Empirical basis (all measured this session):
- `lake build BoneyardArchive` **FAILS today** — the failure list includes imports of modules that no longer exist (e.g. `Bimodal.Metalogic.WeakCanonical.Kamp.NfComposition`, `...Kamp.KampBypassUntil`). The "passes VACUOUSLY" note in the 378 charter is stale.
- The `#exit` convention is inconsistent: of 73 top-level Boneyard files, only 14 have `#exit` before imports (truly inert), ~31 have `#exit` after imports (imports still elaborate), 25 have imports and **no** `#exit` (fully elaborate; several are the build-breakers), 3 have neither. `Kamp/Boneyard/` (50 files): zero `#exit` anywhere, zero lake coverage.
- A vacuous or broken archive target provides no verification value; the 378 charter itself says the vacuous pass is "NEVER evidence of health".

**Concrete lakefile change** (in `/home/benjamin/Projects/BimodalLogic/lakefile.lean`): delete the entire block
```
/-- Archived dead code. Not built by default.
    Build with: lake build BoneyardArchive -/
lean_lib BoneyardArchive where
  srcDir := "Theories"
  globs := #[.submodules `Bimodal.Boneyard]
  leanOptions := theoryLeanOptions
```
No other target references it (grep-verified: only `Theories/Bimodal/Boneyard/README.md:307-313` and `MergedBracketQuarantine/README.md:18` mention it in prose).

**Accompanying doc changes**:
1. `Theories/Bimodal/Boneyard/README.md` (~:300–:315): remove the "How to Verify Compilation"/`lake build BoneyardArchive` instructions; state the policy: "Boneyard code is never compiled. Liveness = reachability from `Theories/Bimodal.lean` or a lakefile root. `lake build` (default target) must stay green after any Boneyard change."
2. Create `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Boneyard/README.md` (none exists) with the same policy statement and a directory inventory for the newly archived files.
3. Fix `Theories/Bimodal/Boneyard/MergedBracketQuarantine/README.md:18` ("inert even inside the BoneyardArchive" — target no longer exists).

**Rejected alternative**: extend `BoneyardArchive`-style coverage to both Boneyards. Would require repairing broken imports across up to 123 archived files today and re-repairing after every live-tree refactor, for zero verification value. Rejected on measured breakage + maintenance cost.

**Optional (route to 359 tidying, NOT this task)**: normalize `#exit`-before-imports headers across archived files as a defense-in-depth convention.

## Division of Labor with Task 359 (runs after, depends on 385)

| Work item | Owner |
|---|---|
| All 19 file MOVES + 1 DELETE above; test-import re-point; lakefile `BoneyardArchive` removal; the 3 README/policy edits; doc-reference fixes for moved files (`Metalogic/README.md`, `FMP/README.md`, `SYNC-MAP.md`, `Metalogic/Metalogic.lean:75-76` tree lines); import-line patches in `DiscreteCompleteness.lean:3`, `NavigatedEndCharSinglePoint.lean`, and among moved files | **385 implementation** |
| Decl-level archival (EANegation `neg_bracket_is_vbracket`/`neg_partialBracketExist_is_vbracket` per 359's amended charter; `endIntervalStep`); Fin/non-Fin twin consolidation (Drift-Register #7); Boneyard header/`#exit` normalization and README inventory tidying; any further intra-file dead-decl sweeps | **359** |
| Rule: 359 MUST NOT move whole files 385 moved; 385 MUST NOT excise declarations inside live files | both |

The 359 charter's "~3 remaining live imports into Boneyard" is confirmed obsolete (independent closure check: zero Boneyard modules reachable from the live root); 385's archival of Prop43/NavigatedEndChar removes even the textual (dead) import edges from non-Boneyard paths.

## Adjacent Findings (outside the 21 — for the planner)

1. **`Theories/Bimodal/ProofSystem/Substitution.lean` (459 LOC) is bit-rotted**: orphan whose only importer is #11, and it no longer compiles (errors at :383 type mismatch, :401–:404 invalid alternative names `all_past`/`all_future`, multiple unsolved goals — a `Formula` API drift casualty). Recommend the 385 plan archive it to TB `DeadCanonicalModel/` together with #11; otherwise it remains a broken orphan invisible to CI.
2. Other non-Metalogic lib-root orphans (informational, no verdict requested): `ProofSystem/LinearityDerivedFacts.lean` (82), `Automation/ProofFirstBenchmark.lean` (167). `Theorems/ContextualProofs.lean` (451) is rescued by the `proof_extractor` exe root; `Automation/*` files are exe roots themselves.
3. Full `lake build` risk of all moves: **zero** for the lib target (all moved files are outside the live closure — recompute-verified) plus the one controlled test-import re-point for #1. Recommended verification gate for the implementer: `lake build && lake build BimodalTest`.

## Tactic Survey Results

Not applicable — no proof construction in scope (repo-hygiene triage; the only Lean-tool work was build verification).

## Adversarial Self-Verification

Every load-bearing claim was re-derived from primary evidence (tree, lakefile, git, builds), not the review doc. The review doc was treated as a hypothesis list.

### Claim Verification Table

| Claim | Source/Counterexample | Verification Method | Confidence |
|---|---|---|---|
| The 21-file orphan list and 4,837 LOC total are correct | Independent closure recomputation over all 423 modules (script parsing `^import` lines, roots = lib root + 12 exe roots), LOC summed per file | scripted recomputation (not trusting review); file-for-file match | High |
| `Theories/Bimodal/Metalogic.lean` is shadowed by live `Metalogic/Metalogic.lean` | `Theories/Bimodal/Bimodal.lean:4` (`import Bimodal.Metalogic.Metalogic`) | Read of root aggregator | High |
| **Counterexample to "compiled by nothing"**: dead aggregator IS compiled by the test driver | 6 files in `Tests/BimodalTest/Integration/` contain `import Bimodal.Metalogic`; `BimodalTest` is the lakefile `testDriver` | grep over `Tests/` + lakefile read | High |
| **Counterexample to review §2.2**: `TraceExport.lean` is not dead | `Automation/TraceExporter.lean:12` imports it; `lean_exe trace_exporter` root = `Bimodal.Automation.TraceExporter` (lakefile.lean); also 2 test files | grep + lakefile read; closure-with-exe-roots run rescues it | High |
| `lake build BoneyardArchive` fails (target broken, not vacuous) | Background build run this session: `error: build failed`, with unresolvable module list (e.g. `Kamp.NfComposition`) | executed `lake build BoneyardArchive` | High |
| `#exit` discipline is partial: 14/73 inert-before-imports, 25/73 no `#exit` at all; Kamp/Boneyard 0/50 | Scripted per-file first-`#exit` vs first-`import` line comparison | scripted grep classification | High |
| Zero live (lib-closure) imports into either Boneyard — 359 invariant holds | Closure ∩ Boneyard = ∅ | scripted recomputation | High |
| DenseSoundness/DiscreteSoundness are pure aliases of live theorems | `Soundness.lean` decls at :379, :394, :879, :928, :1193, :1338; wrapper bodies delegate 1-to-1 | full Read of both 50-line files + grep of Soundness.lean | High |
| DenseSoundness was never imported on the main line (not "accidentally dropped") | `git log -S "import Bimodal.Metalogic.DenseSoundness" -- 'Theories/**'` returns nothing | git pickaxe | High |
| ConservativeExtension chain + both FMP variants compile green today | `lake build Bimodal.Metalogic.ConservativeExtension.Lifting Bimodal...DenseFMP ...DiscreteFMP` → "Build completed successfully" | executed lake build of orphan module targets | High |
| CanonicalIrreflexivity cannot build; `ProofSystem/Substitution.lean` bit-rotted | `lake build Bimodal.Metalogic.Bundle.CanonicalIrreflexivity` → errors in `ProofSystem/Substitution.lean:383-:412` | executed lake build | High |
| FMP variants orphaned by deletion of their (orphaned) aggregator, results referenced nowhere | commit ef13e2c33; grep for `dense_fmp`/`discrete_mcs_finite_model_property` outside the two files: zero hits | git pickaxe + grep | High |
| ConservativeExtension was task-958-era ("substitution approach"), never consumed live on main | `git log -S "import Bimodal.Metalogic.ConservativeExtension"` → only 958 partial-implementation commits + an off-main publication-branch commit (78f44d2ca) | git pickaxe; branch nature of 78f44d2ca confirmed via its stat (removes specs/, Boneyard/ — absent changes on main HEAD) | Medium-High |
| 378 frozen surfaces absent from the 4 bridge orphans | grep for `hasDefinableINF_excludes_kplus`, `lemma53`, `EANegationFix`: NONE | grep | High |
| Literature briefing not relevant to this task | Briefing lists 12 docs, all Kamp/expressive-completeness mathematics; task is file-hygiene | executed `literature-briefing-invoke.sh`, reviewed listing | High |

### Contradiction Log

1. **378 charter ("`lake build BoneyardArchive` passes VACUOUSLY, #exit line 5 precedes imports line 7") vs measured build failure.** Resolution per precedence: direct tool observation (executed build, exit failure) outranks a charter prose note; the `#exit@5/import@7` pattern exists but only in 14/73 files (measured), so the charter generalized from a sample. The charter's *policy* conclusion ("only reachability decides liveness") is unaffected and is adopted here. RESOLVED in favor of measurement.
2. **Review §2.2 ("21 orphans... compiled by nothing") vs test-driver and exe-root evidence.** The review computed reachability from the lib root only. With exe + test roots, 2 of 21 (`Metalogic.lean` via tests, `TraceExport.lean` via exe+tests) are compiled. RESOLVED: verdicts adjusted (#1 gains a mandatory re-point step; #10 flips to KEEP).
3. **Review's "vacuous lake lib" phrasing vs broken lib.** Same resolution as (1); the recommended fix (remove the lib) is strengthened, not weakened.

### Recommendations modified after verification

- `TraceExport.lean`: review left it "check then archive"; verification flips it to **KEEP**.
- `Metalogic.lean` DELETE: augmented with the required 6-file test re-point (would otherwise break `lake build BimodalTest`).
- CanonicalIrreflexivity: "archive" upgraded from stylistic to necessary (it cannot even compile), and its broken dependency `ProofSystem/Substitution.lean` added to the move list recommendation.

## Memory Candidates

1. **Pattern (lean4/lake)**: `lake build <Module.Name>` builds modules *outside* a lib's root closure as long as they are under its `srcDir` — the cheapest bit-rot check for orphaned files before deciding archive-vs-re-import (no scratch imports needed).
2. **Pattern (repo-hygiene)**: import-closure orphan computations MUST union all lakefile roots — `lean_lib` roots, every `lean_exe` root, and the test driver — or files like exe-only serializers and test-only aggregators are misclassified as dead.
3. **Fact (this repo)**: the `BoneyardArchive` lake target is broken (not vacuous); only 14/73 top-level Boneyard files carry `#exit` before imports; `Kamp/Boneyard/` has no `#exit` and no lake coverage. Chosen policy: never-built archives, liveness = reachability from lakefile roots.
