# `docs/` Overhaul: Verification, Measured Baselines, and Guard Design

**Task**: 486 — docs/ OVERHAUL (deletions, false-status rewrites, dead links, gaps, drift guard)
**Type**: lean4 (documentation correction against a Lean source of truth)
**Session**: sess_1787688954_7fb0f6_486
**Depends on**: 484 (ROADMAP + Metalogic/README anchors), 485 (README.md + `FormalSystem/**/README.md`) — both complete
**Source of record**: `specs/reviews/review-2026-08-25.md`
**Working tree**: `8202bfd42`, `ALL CHECKS PASSED` under `check-module-invariants.sh --no-build`

---

## 1. Verdict summary

Every substantive claim in the task description that I checked against Lean source is **true**.
The two anchor documents corrected by 484/485 are usable as ground truth and, in several places,
already contain the exact corrected prose this task needs to propagate into `docs/`.

Nine findings materially change the shape of the work. These are the reason this report is long:

| # | Finding | Effect on the plan |
|---|---------|--------------------|
| F1 | The `SORRY_REGISTRY.md` inbound-link count is **15**, not 4. Nine of them are in `MAINTENANCE.md`, where the file is a live node in a documented 4-document sync *procedure*. | Phase 1a is a procedure rewrite, not a link repoint. Size it accordingly. |
| F2 | The `94` dead-link figure is not reproducible. My measured count is **96 total / 76 after excluding template snippets and grep-fence false positives / 74 genuinely actionable**. | The verification gate must name a *command*, not the number 94. Proposed command in §6.1. |
| F3 | Four dead links the review did not enumerate (`architecture.md:1240,1244,1378,1379` → lowercase `dual-verification.md` / `proof-library-design.md`) plus two more classes (`Bimodal/` merge leftovers in `BENCHMARKING_GUIDE.md`; a nonexistent `Tests/BimodalTest/Core/Property/`). | Add to the Phase 4 repair table (§6.2 is complete and per-line). |
| F4 | `docs/reference/readme-standard.md:72,73` are **template illustrations**, exactly like the `DIRECTORY_README_STANDARD.md` snippets the review flagged LOW/IGNORE. The review did not classify them. | Reclassify as ignore; do not "fix" them into real links. |
| F5 | The archived task directories the dead links point at **were renumbered**: `192_fix_generalized_necessitation_termination` is now `specs/archive/192_master_tactic_dispatch`, and `174_property_based_testing` is now `specs/archive/174_split_oversized_files`. The old targets do not exist under any name. | Those 5 links must be **deleted**, not repointed. `.claude/rules/no-task-references-in-deliverables.md` independently forbids them. |
| F6 | `docs/` carries **180 task-number citations** (152 excluding the two deletion targets), 100 of them in `PHASED_IMPLEMENTATION.md` alone. Check C9 already forbids exactly this — but only under `FormalSystem/`. | The single most obvious guard extension carries 152 units of latent debt. Scope decision required (§9.1). |
| F7 | Check C5 matches **dotted** module names only (`FormalSystem.Foo.Bar`). Slash-shaped paths (`FormalSystem/Metalogic/Bundle/DovetailingChain.lean`) are invisible to it. That is precisely why `BFMCS_ARCHITECTURE.md`'s dead source-file table survived. Measured: **85 unresolved slash-paths** in `docs/` + `README.md` (69 excluding the two deletion targets). | This is the highest-value guard in the task, and it is cheap. Design in §8.2. |
| F8 | Extending C5's regex to also match `Bimodal.*` would **immediately fail the gate on 48 occurrences**, all in `FormalSystem/**/README.md` — outside this task's `file_scope`. | Do not touch C5's regex. Add a distinct check instead. |
| F9 | The task description states Dedekind strong completeness is "NOT STATED". `StrongCompleteness.lean:74-89` and `Metalogic.lean:95-101` are more precise and explicitly warn against collapsing statuses: there are **three** distinct statuses (Discrete machine-refuted; Base/Dense open; Dedekind unavailable-on-Reynolds's-terms, unproved *and* unrefuted). | The rewritten Limitation 1 must present three statuses. Copy the tree's own wording. |

---

## 2. Ground truth, re-derived at research time

Every figure below was derived from source, not from another document. Re-derive rather than
trusting this table if implementation happens more than a few commits later.

| Fact | Value | Command / anchor |
|------|-------|------------------|
| Repository metrics | **539 files / 170,898 code / 96,290 comment** | `cloc --include-lang=Lean --exclude-dir=.lake,lake-packages,Boneyard .` — exact match to `README.md:19-21` as corrected by 485 |
| Structural sorries | **0** | `check-module-invariants.sh` C3 (`PASS`) |
| Axiom constructors | **45** | `inductive Axiom` in `FormalSystem/ProofSystem/Axioms.lean` |
| Axiom layer split | **Base 37 / Dense 2 / Discrete 3 / Dedekind 3** | `Axiom.minFrameClass` at `Axioms.lean:588-597` |
| Inference rules | **7** | `DerivationTree` constructors, `ProofSystem/Derivation.lean:98,105,111,129,146,155,164` — `axiom`, `assumption`, `modus_ponens`, `necessitation`, `temporal_necessitation`, `temporal_duality`, `weakening` |
| `completeness` | `BXCanonical/Completeness.lean:196`, sorryAx-free | C2 baseline asserts `[propext, Classical.choice, Quot.sound]` |
| `completeness_dense` / `completeness_discrete` | `:255` / `:296` | same |
| Live module inventory | 467 live `.lean` (413 `FormalSystem` / 53 `Tests`) | C7 |
| Lake targets | `FormalSystem` (default), `BimodalTest` + 12 `lean_exe` | `lakefile.lean:15-107` |

**A defect in the Lean source itself, out of scope but worth recording**: `Axioms.lean:92-95`
gives the layer breakdown as Base 37 / Prior-Z1 3 / Density 2 = 42 and **never mentions the
Dedekind layer**. That docstring is the same omission this task fixes in
`docs/reference/axiom-reference.md`. It is prose, so the verification gate's "no `.lean`
declaration, signature, import, or tactic changed" would permit the edit — but `Axioms.lean` is
outside `file_scope`. Recommend a follow-up task rather than widening this one.

### 2.1 Anchor prose available for lifting

Task 484 and 485 left correct, carefully-worded prose in the tree. The implementer should
**lift and adapt** rather than re-derive:

| Needed for | Lift from |
|------------|-----------|
| Three-way strong-completeness status (2a, G9) | `Metalogic.lean:83-101`; `StrongCompleteness.lean:25-41` (terminology) and `:59-89` (the three statuses) |
| Discrete non-compactness (G2) | `StrongCompleteness.lean:59-72`; `Metalogic.lean:102-110` |
| Decidability sound-direction + `extractionFailed` caveat (2b, G1) | `Decidability/Correctness.lean:88-99` (the caveat, already written) and `:100-145` (the five theorems) |
| Four-frame-class partial order, why Dedekind sits above Dense, the TM⁺_c gap (G8) | `Axioms.lean:461-517` — an extensive, primary-source-grounded explanation already exists |
| `minFrameClass ≤ fc` invariant (G8) | `Axioms.lean:515-517` |

---

## 3. Phase 1 — Deletions

### 3.1 `docs/project-info/SORRY_REGISTRY.md` (1a)

Confirmed fiction. Every path it names is nonexistent; its own verification commands at `:24-31`
and `:56-69` glob `Bimodal/**/*.lean` and match nothing. It additionally carries 12 unresolved
slash-paths and 11 task-number citations.

**The task description understates the inbound links.** Actual non-self references, `grep -rn
'SORRY_REGISTRY' docs/ README.md scripts/ FormalSystem/`:

| File | Lines | Nature |
|------|-------|--------|
| `docs/README.md` | 97, 171, 222 | markdown links (the 3 the task names) |
| `docs/project-info/FEATURE_REGISTRY.md` | 7 | markdown link (the 4th the task names) |
| `docs/project-info/implementation-status.md` | 152 | markdown link (also a `../../../` escape — see §6.2) |
| `docs/development/DIRECTORY_README_STANDARD.md` | 296 | prose mention in a template listing |
| **`docs/project-info/MAINTENANCE.md`** | **13, 91, 134, 152, 170, 177, 180, 266, 278** | **9 sites; a live 4-document sync procedure** |
| `docs/project-info/IMPLEMENTATION_STATUS.md` | 28, 29, 59, 71, 84 | moot — file deleted by 1b |

`MAINTENANCE.md` is the real cost. It documents a "keep all four in sync" workflow
(`TODO.md` / `implementation-status.md` / `FEATURE_REGISTRY.md` / `SORRY_REGISTRY.md`) with a
numbered update table at `:134`, a flow diagram at `:152`, and a resolution walkthrough at
`:266-278`. Deleting one of the four documents invalidates the procedure. Two options:

- **(preferred)** Rewrite the procedure around the *mechanical* replacement that now exists:
  C3 of `check-module-invariants.sh` is the sorry inventory, and it is asserted by content with
  a hard zero. The maintenance step becomes "run the check", not "hand-edit a registry".
- (fallback) Excise the four `SORRY_REGISTRY` rows and leave the remaining three-document flow.

Note that `MAINTENANCE.md:170` and `:177-180` are inside a bash fence — the two false positives
the task description tells us to EXCLUDE from the link count. They still need editing as prose,
they simply are not broken *links*.

### 3.2 `docs/project-info/IMPLEMENTATION_STATUS.md` (1b)

Confirmed duplicate-and-contradictory. Deletion is clean: the only non-self reference in the
whole repository is `docs/reference/readme-standard.md:166`, a row in a naming-convention table
(`IMPLEMENTATION_STATUS.md` → `implementation-status.md`) that is *about* the uppercase/lowercase
convention and should be left exactly as it is. Deleting the file also removes 5 unresolved
slash-paths, 1 dead link (`:83` → `../../TODO.md`), and ~28 task-number citations.

### 3.3 A third deletion candidate the review did not raise

`docs/development/PHASED_IMPLEMENTATION.md` contains **100 task-number citations** — two thirds
of the repository's entire remaining docs/-side violation of
`.claude/rules/no-task-references-in-deliverables.md`. It is a historical phased plan: a
`specs/`-shaped artifact living in `docs/`. I am **not** recommending its deletion inside this
task (it is not in the review's deletion list and the task did not ask), but flag it now because
it single-handedly determines whether the C9-to-docs guard extension in §9.1 is cheap or
expensive.

---

## 4. Phase 2 — False status claims (all verified)

| ID | Claim | Verified | Notes for the implementer |
|----|-------|----------|---------------------------|
| 2a | `known-limitations.md:9-37` Limitation 1 | **FALSE, confirmed.** `completeness` is at `Completeness.lean:196` (not `:187`) and is sorryAx-free per C2 | See F9 — write **three** statuses. `CompactBase` is `SetConsequence.lean:219`, `CompactDense` `:263`, `strongCompletenessDiscrete_refuted` `DiscreteNonCompactness.lean:280` — all confirmed at those exact lines |
| 2b | `known-limitations.md:123-127` Limitation 6 | **FALSE, confirmed.** `Decidability/` subtree exists; `sound_of_isValid` at `Correctness.lean:100` | Correct path is `FormalSystem/Metalogic/Decidability/Correctness.lean` — **not** `.../Verified/Correctness.lean`. The `extractionFailed` caveat is already written at `:95-99`; quote it |
| 2c | `BFMCS_ARCHITECTURE.md` lacunae inventory | **FALSE, confirmed.** Of the 6 files in its source table at `:359-367`, only `BFMCS.lean` and `TemporalContent.lean` exist. `BMCS.lean`, `DovetailingChain.lean`, `TemporalCoherentConstruction.lean`, `Bundle/Completeness.lean` do not | Also delete the `Status: Sorry` rows in the operator table at `:193-198`, not just section 4. File also carries 9 task-number citations |
| 2d | `implementation-status.md:132` "12 sorries"; `:55,:72-74` | **FALSE, confirmed.** `countermodel_discrete` is *proved* at `WeakCanonical/GroupModel/CountermodelBase.lean:142` | Same file has **three more** defects the task did not list: `:65` "all 21 axiom schemas: 17 base + 1 dense + 3 discrete"; `:58` a Layer-2 module table row for a `Completeness.lean` that is archived; `:139` `lake build Bimodal` — a target that does not exist (only `FormalSystem` and `BimodalTest`) |
| 2e | `user-guide/architecture.md:1303-1307`, `:944-1000` | **Confirmed.** 45 axioms / 7 rules; no `Logos/` tree exists | `:920`-area and `:747-796` also place `set_lindenbaum` in the archived `Completeness.lean` (see G7) |
| 2f | Decidability overstated at `docs/README.md:16`, `BIMODAL_LOGIC.md:87`, `competitive-landscape.md:74,:82` | **Confirmed verbatim** at all four sites | Sound direction only; the converse `models φ → isValid φ fc = true` is open |
| 2g | `FEATURE_REGISTRY.md:29-30` P3-P6 | **FALSE, confirmed.** Actual per `Theorems.lean:51-54`: P3 `□φ → □△φ`, P4 `◇▽φ → ◇φ`, P5 `◇▽φ → △◇φ`, P6 `▽□φ → □△φ` | `docs/user-guide/tutorial.md:402` **already has these correct** — a ready-made in-repo cross-check. Also `FEATURE_REGISTRY.md:19` "14 axiom schemata", `:21` archived `Metalogic/Completeness.lean`, `:26` a `Theorems/Perpetuity.lean` (correct: `Theorems/Perpetuity.lean` **does** exist as an aggregator beside `Perpetuity/`), `:43` `Theorems/Propositional.lean` (a **directory**), `:59` `Automation/ProofSearch.lean` (a **directory**), `:72` "Task 174" |
| 2h | `tutorial.md:404-409`, `:381` | **Confirmed** at those lines | Rename to "consequence completeness" per `StrongCompleteness.lean:25-35`; add `completeness_dedekind` |
| 2i | `API_REFERENCE.md:612` build-errors note | **FALSE, confirmed.** Tree is green (C1/C3/C5 pass) | `:600` and `:627` give frame-class-free statements, confirmed. The Completeness section at `:616-626` has *already* been partly corrected (it names the Boneyard archive), so edit surgically |
| 2j | `test-coverage.md:20` "5" | **Confirmed.** `:7-11` correctly self-marks as superseded | Low harm as stated |

---

## 5. Phase 3 — Counts and classification

### 5.1 Axiom sweep (3a)

`docs/reference/axiom-reference.md:7-13` currently reads "21 axiom schemas … three layers /
Base 17 / Dense 1 / Discrete 3". The correct table:

| Layer | Count | Description |
|-------|-------|-------------|
| Base | 37 | Valid on all linear temporal frames |
| Dense | 2 | `density`, `dense_indicator` |
| Discrete | 3 | `prior_UZ`, `prior_SZ`, `z1` |
| Dedekind | 3 | `prior_U_gap`, `prior_S_gap`, `sep` (Reynolds 1992, printed p.168) |
| **Total** | **45** | |

Stale axiom *names* confirmed: the temporal layer is Burgess–Xu until/since
(`left_mono_until_G`, `enrichment_until`, `linear_since`, `F_until_equiv`, …), not T4/TA/TL/TK;
and `temp_k_dist` / `temp_4` are derived theorems per `Axioms.lean:96-98`
(`temporalKDistDerived`, `temporal4Derived` in `TemporalDerived.lean`).

**The task description's note that `README.md:164` says "44 constructors" is stale.** Task 485
already fixed it: `README.md:209` now reads "complete axiom schemas for all 45 constructors".
The front page is correct and the reference document it links to is wrong — which is the actual
current state, and slightly worse than the task described.

Other count sites confirmed: `BIMODAL_LOGIC.md:82` "14 axiom schemata, 7 inference rules" (the
7 is right, the 14 is wrong); `FEATURE_REGISTRY.md:19` and `:74`.

### 5.2 Operators (3b)

Confirmed. `untl` and `snce` are primitive at `Syntax/Formula.lean:96` and `:106`; `someFuture`,
`somePast`, `kPlus`, `kMinus` are all *derived* from them (`:147`, `:157`, `:196`, `:209`).
`operators.md` documents only the derived H/P/G/F forms. `Derivable` is
`(fc : FrameClass) (G : Context) (p : Formula)` at `ProofSystem/Derivable.lean:69` — confirmed;
`operators.md:194` omits `fc`. `operators.md:207` states unqualified completeness for arbitrary
`Γ`, the exact conflation `StrongCompleteness.lean:25-41` exists to forbid.

Additional, unlisted: `operators.md:7` and `:9` describe the system as "Logos" and "Logos's
formal proof system". Branding drift, worth a same-pass fix.

### 5.3 Semantics carrier (3c) and metrics (3d)

`BIMODAL_LOGIC.md:24` confirmed verbatim; the carrier is an arbitrary ordered abelian group `D`
(`StrongCompleteness.lean:165-169`), with dense and Dedekind-complete carriers explicitly
supported. `:39-43` operator table omits `untl`/`snce` — confirmed.

Metric drift confirmed at `project-info/README.md:117,123,127` and
`implementation-status.md:129-130`. Correct values are §2's `cloc` line. Recommend following
`README.md`'s own precedent: print the reproduction command beside the table.

---

## 6. Phase 4 — Dead links

### 6.1 The count is not 94; use a command, not a number

Measured with a straightforward resolver over all 72 `docs/*.md`:

| Bucket | Count |
|--------|-------|
| Total unresolved relative markdown links in `docs/` | **96** |
| less `DIRECTORY_README_STANDARD.md` template snippets (review: LOW/IGNORE; measured **18**, not 15) | −18 |
| less `MAINTENANCE.md:463,466` grep-patterns-in-a-bash-fence (review: EXCLUDE) | −2 |
| **Actionable** | **76** |
| less `readme-standard.md:72,73` — template illustrations, same class as `DIRECTORY_README_STANDARD.md` (F4) | −2 |
| **Genuinely actionable** | **74** |

The number `94` in the task description and the review is not reproducible by any classification
I could construct. **The verification gate should name this command and require zero**, with the
three ignore-classes handled by an explicit exclusion list rather than by arithmetic:

```bash
find docs -name '*.md' | sort | while read -r f; do
  dir=$(dirname "$f")
  grep -noP '\[[^]]*\]\(\K[^)]+' "$f" | while IFS=: read -r ln link; do
    case "$link" in http://*|https://*|mailto:*|'#'*) continue ;; esac
    path="${link%%#*}"; [ -z "$path" ] && continue
    case "$path" in /*) full="$path" ;; *) full="$dir/$path" ;; esac
    [ -e "$full" ] || echo "$f:$ln -> $link"
  done
done | grep -vE '^docs/(development/DIRECTORY_README_STANDARD|reference/readme-standard|project-info/MAINTENANCE)\.md:'
```

Expected at end of Phase 4: **0 lines**. Expected today: 76 lines minus the 2 `readme-standard`
lines = **74**.

### 6.2 Complete per-line repair table

All 74 actionable links, classified with a verified target. Nine of them disappear for free when
Phase 1 deletes their host file (marked †).

**Class A — case-wrong `Development/` → `development/` (12 sites)**

| Site | Fix |
|------|-----|
| `user-guide/tutorial.md:425,430,431,432` | `../Development/X` → `../development/X` |
| `user-guide/architecture.md:1380,1381,1383` | `../Development/X` → `../development/X` |
| `user-guide/tactic-development.md:789,790` | `../Development/X` → `../development/X` |
| `user-guide/tactic-development.md:182` | `../../Development/METAPROGRAMMING_GUIDE.md` → `../development/METAPROGRAMMING_GUIDE.md` (depth **and** case) |
| `reference/operators.md:312,360` | `../../Development/LEAN_STYLE_GUIDE.md` → `../development/LEAN_STYLE_GUIDE.md` (depth **and** case) |

**Class B — `../../../` and `../../` escapes resolving outside the repository (24 sites)**

| Site | Fix |
|------|-----|
| `docs/README.md:306` | `../../docs/README.md` → `README.md` (self-reference; consider deleting) |
| `docs/README.md:317, 408` | `../../../docs/research/bimodal-logic.md` → `research/BIMODAL_LOGIC.md` (also case) |
| `docs/README.md:400, 407` | `../../docs/` → `.` |
| `docs/README.md:401` | → `development/LEAN_STYLE_GUIDE.md` |
| `docs/README.md:402` | → `development/TESTING_STANDARDS.md` |
| `project-info/README.md:131` | → `implementation-status.md` |
| `project-info/README.md:133` † | → **delete** (`SORRY_REGISTRY.md` removed by 1a) |
| `project-info/README.md:134` | → `FEATURE_REGISTRY.md` |
| `project-info/implementation-status.md:151` | self-reference → delete or `implementation-status.md` |
| `project-info/implementation-status.md:152` † | → **delete** (1a) |
| `project-info/known-limitations.md:178` | → `implementation-status.md` |
| `project-info/performance-targets.md:5` | → `../development/BENCHMARKING_GUIDE.md` |
| `project-info/test-coverage.md:156` | → `../development/TESTING_STANDARDS.md` |
| `project-info/test-coverage.md:157` | → `../../Tests/BimodalTest/README.md` (verified to exist) |
| `project-info/test-coverage.md:163` | → `../../Tests/BimodalTest/` |
| `project-info/test-coverage.md:164` | `../../../benchmarks/` — **no such directory anywhere**; delete the link |
| `reference/README.md:101` | → `operators.md` |
| `reference/README.md:102` | → `API_REFERENCE.md` |
| `research/README.md:145, 211` | → `.` |
| `research/README.md:204` | → `BIMODAL_LOGIC.md` |
| `user-guide/README.md:97` | → `tutorial.md` |
| `user-guide/quickstart.md:103` | → `tutorial.md` |

**Class C — never-existed targets, delete the link (9 sites)**
`METHODOLOGY.md`: `user-guide/architecture.md:1221,1373`; `research/DUAL_VERIFICATION.md:500`;
`research/PROOF_LIBRARY_DESIGN.md:408`.
`research/layer-extensions.md`: `user-guide/architecture.md:1233,1318,1377`;
`research/DUAL_VERIFICATION.md:503`; `research/PROOF_LIBRARY_DESIGN.md:407`.

**Class D — case-wrong filenames (6 sites; 4 of them unlisted in the review — F3)**

| Site | Fix |
|------|-----|
| `docs/README.md:145` | `architecture/BFMCS_architecture.md` → `BFMCS_ARCHITECTURE.md` |
| `architecture/README.md:35` | `BFMCS_architecture.md` → `BFMCS_ARCHITECTURE.md` |
| `user-guide/architecture.md:1240, 1378` | `../research/dual-verification.md` → `../research/DUAL_VERIFICATION.md` |
| `user-guide/architecture.md:1244, 1379` | `../research/proof-library-design.md` → `../research/PROOF_LIBRARY_DESIGN.md` |

**Class E — wrong depth from `docs/reference/` (4 sites)**
`reference/operators.md:3,359,361,362`: `../../user-guide/` → `../user-guide/`.

**Class F — `.claude/` written relative instead of repo-root (6 sites)**
`user-guide/INTEGRATION.md:5,408,416`; `user-guide/MCP_INTEGRATION.md:57`;
`development/CONTRIBUTING.md:420,421`. Both targets (`.claude/CLAUDE.md`,
`.claude/docs/README.md`) exist, so `../../.claude/CLAUDE.md` resolves — **but see §9.2**:
`.claude/` is a gitignored, regenerable deploy artifact, and linking a committed document into it
is a drift source of its own. Recommend prose reference without a link.

**Class G — root `TODO.md` moved to `specs/TODO.md` (3 sites)**
`development/NONCOMPUTABLE_GUIDE.md:401`; `development/PHASED_IMPLEMENTATION.md:527`;
`project-info/IMPLEMENTATION_STATUS.md:83` †.

**Class H — archived task directories; DELETE, do not repoint (5 sites — F5)**
`architecture/ADR-001-Classical-Logic-Noncomputable.md:6,265`;
`development/NONCOMPUTABLE_GUIDE.md:5,190` (all → `specs/192_fix_generalized_necessitation_termination/`);
`development/PROPERTY_TESTING_GUIDE.md:713` (→ `specs/174_property_based_testing/reports/research-001.md`).
Renumbering means `192_` and `174_` now name entirely different tasks
(`specs/archive/192_master_tactic_dispatch`, `specs/archive/174_split_oversized_files`).
`.claude/rules/no-task-references-in-deliverables.md` forbids the citation regardless of whether
a target could be found.

**Class I — stale `Logos/Core/` root (1 link + 25 non-link prose paths)**
Only `project-info/tactic-registry.md:173` is a markdown *link*. The other 25 `Logos/`
occurrences are bare paths in tables and prose — invisible to any link checker, which is exactly
the F7 blind spot. Full inventory: `tactic-registry.md:15-24,34-36` (12 table rows) and `:173`;
`research/proof-search-automation.md:420-422,425,426`; `user-guide/examples.md:12`;
plus two the review missed: `development/CONTRIBUTING.md:130,394` and
`development/DOC_QUALITY_CHECKLIST.md:475`. Real target is
`FormalSystem/Automation/Tactics/` — note it is a **directory**, as are
`FormalSystem/Automation/ProofSearch/` and `FormalSystem/Theorems/Propositional/`.

**Class J — `Bimodal/` two-tree merge leftovers, unlisted in the review (F3, 3 sites)**
`development/BENCHMARKING_GUIDE.md:86,228` → `../project-info/performance-targets.md`;
`development/PROPERTY_TESTING_GUIDE.md:712` → `../../Tests/BimodalTest/Core/Property/`
**does not exist**; delete the link.

---

## 7. Phase 5 — Documentation gaps

**Zero coverage confirmed mechanically.** `grep -rl` across all 72 `docs/*.md` returns **0 files**
for every one of: `sound_of_isValid`, `isValid_sound`, `archWitness`,
`discrete_consequence_not_compact`, `completeness_dedekind`, `ValidDedekindDense`,
`Conservativity`, `derivable_translate`, `Independence`, `BaseLanguage`, `SetConsequence`,
`CompactBase`, `minFrameClass`, `FrameClass.Dedekind`, `consequence_completeness`. The single
exception is `set_lindenbaum`, which appears in exactly one file — `user-guide/architecture.md`,
placing it in the archived `Completeness.lean`, precisely as the task description says.

All nine gap anchors verified to exist at the cited locations:

| Gap | Anchors verified |
|-----|------------------|
| G1 | `Decidability/Correctness.lean:100` `sound_of_isValid`, `:111` `isValid_sound`, `:124` `isTautology_sound`, `:131` `isContradiction_sound`, `:142` `not_isSatisfiable_sound`; caveat prose `:95-99` |
| G2 | `DiscreteNonCompactness.lean:102` `archWitness`, `:194` / `:229` the two halves, `:250` `discrete_consequence_not_compact`, `:280` `strongCompletenessDiscrete_refuted` |
| G3 | `StrongCompleteness.lean:469` `completeness_dedekind`, `:450` `consequence_completeness_dedekind`; `Axioms.lean:485-513` Reynolds provenance |
| G4 | `Metalogic/Conservativity.lean:194` `derivable_translate`, `:210/222/232/253` the four `*_backward` rows; forward-direction refutation recorded in the module docstring and at `Metalogic.lean:33-38` |
| G5 | `Metalogic/Independence/{ClockFrame,CoNotPriorU,LoopingDuration}.lean` — all three present |
| G6 | `FormalSystem/BaseLanguage/{Formula,Axioms,Derivation,Translation,AxiomDischarge}.lean`; second `inductive Axiom` at `BaseLanguage/Axioms.lean:73` |
| G7 | `SetConsequence.lean:219` `CompactBase`, `:263` `CompactDense`, `:184` the `Core.SetConsistent` bridge (`not_setConsistent_of_setDerivable_bot`) |
| G8 | `Axioms.lean:461-483` partial order + the Dedekind-above-Dense argument, `:485-513` the TM⁺_c gap, `:515-517` the `minFrameClass ≤ fc` invariant |
| G9 | `StrongCompleteness.lean:450,535,639,746` the four `consequence_completeness_*`; three-way status at `Metalogic.lean:83-101` |

`docs/development/MODULE_ORGANIZATION.md` mentions **none** of `BaseLanguage`, `Decidability`,
`Independence`, `Conservativity`, or `SetConsequence` — consistent with the task's G6 note, and
broader than it.

---

## 8. Phase 6 — Missing READMEs and the guard

### 8.1 Scope answer: yes, 6a is in scope

The task description's Phase 6a and its verification gate (`readme-lint.sh` missing-README count
`9 -> 0`) both name it explicitly. Current baseline, `bash scripts/readme-lint.sh`:

```
Missing READMEs:          9
Total READMEs found:      37
Broken file references:   0     <- 485 took this from 5 to 0
RESULT: FAIL (9 missing READMEs, 0 broken references)
```

The 9, with file counts and the task's stated priority order:

| Priority | Directory | `.lean` files | Why |
|----------|-----------|---------------|-----|
| 1 | `Metalogic/WeakCanonical/GroupModel/` | 6 | hosts `countermodel_discrete` (`CountermodelBase.lean:142`) |
| 2 | `FormalSystem/BaseLanguage/` | 5 | the second object language (G6) |
| 3 | `Metalogic/Independence/` | 3 | G5 |
| 4 | `Metalogic/Decidability/Verified/Bridge/` | 15 | largest |
| 5 | `Metalogic/Decidability/Verified/Termination/` | 4 | |
| 6 | `Metalogic/WeakCanonical/DenseModelSurgery/` | 9 | |
| 7 | `Metalogic/WeakCanonical/Kamp/EANegationFixFaithful/` | 5 | |
| 8 | `Metalogic/WeakCanonical/RealModel/` | 7 | |
| 9 | `Semantics/Extension/` | 5 | |

**Note this puts 9 new files outside `file_scope`** (`docs/`, the two scripts). The task
description mandates it, so it is intended, but the planner should record the widening
explicitly. Follow `docs/reference/readme-standard.md` and the existing sibling READMEs for
format, and include a "Last verified" line (readme-lint Check 4).

**The ~110 unlisted-file figure is right in total but wrong in distribution.** Measured
per-README (`readme-lint.sh` Check 2, 110 hits):

| README | Count | Task description said |
|--------|-------|----------------------|
| `WeakCanonical/Kamp/README.md` | 57 | 35 |
| `WeakCanonical/Kamp/NfMultiAnchorBridge/README.md` | 21 | not listed |
| `Automation/README.md` | 13 | 13 ✓ |
| `BXCanonical/Chronicle/README.md` | 8 | 7 |
| `Metalogic/Bundle/README.md` | 4 | not listed (485 handed this off) |
| `WeakCanonical/IntegerModel/README.md` | 3 | not listed |
| `WeakCanonical/Separation/README.md` | 2 | not listed |
| `Automation/Tactics/README.md` | 2 | not listed |
| `Semantics/README.md` | **0** | 6 — **already clean** |

Check 2 does **not** currently affect `readme-lint.sh`'s exit code (the summary block recomputes
only `MISSING` and `BROKEN`). Closing all 110 is therefore *not* required by the stated gate.
Recommend treating it as optional and, if attempted, doing it as a separate late phase.

### 8.2 The guard (6b) — design

**Why the existing lint caught nothing.** Three independent blind spots, all verified:

1. `readme-lint.sh` takes a root argument (`ROOT="${1:-FormalSystem}"`) so it *can* be pointed at
   `docs/` today — but it only ever opens files literally named `README.md`. In `docs/` that is
   6 of 72 files. And its Check 1 fires only on directories containing `.lean` files, so it is
   structurally inert outside a Lean tree.
2. `check-module-invariants.sh` C5 matches **dotted** names via
   `\b(?:FormalSystem|BimodalTest)(?:\.[A-Z][A-Za-z0-9_]*)+`. Slash-shaped paths are invisible.
   This is why `BFMCS_ARCHITECTURE.md`'s four dead `Bundle/*.lean` rows passed a green gate.
3. C9 (task references) and C10 (stale asset paths) are scoped to `FormalSystem/` and to the
   specific `FormalSystem/{docs,latex,typst}` pattern respectively. Neither sees `docs/`.

**Recommended implementation — three checks, following the script's own established idiom**
(an `ENFORCE_Cn` flag, a computation, `pass`/`fail`/`soft` + `note`, and an optional companion
allowlist file, exactly as C5/C8/C9/C10 do):

| New check | What it asserts | Initial debt | Enforce at once? |
|-----------|-----------------|--------------|------------------|
| **C12 — slash-path resolution in markdown** | every `FormalSystem/… `, `Tests/…`, `Logos/…`, `Bimodal/…` slash-path in non-`specs` markdown resolves to a file or directory (try bare, `.lean`, `.md`, `/`) | **85** in `docs/` + `README.md`; **69** after Phase 1 deletions; **0** after Phase 4 | Yes — Phase 4 clears it |
| **C13 — markdown link resolution** | every relative markdown link in `docs/` and `README.md` resolves; three documented ignore-paths (`DIRECTORY_README_STANDARD.md`, `readme-standard.md`, `MAINTENANCE.md`) via an allowlist file, not hardcoded | 96 → 0 | Yes — Phase 4 clears it |
| **C14 — status-claim tripwires** | the documented sorry count is 0 and the documented axiom count is 45, checked by grepping `docs/` for the *stale* literals and for any `sorries \| [1-9]`-shaped table row; and, under `--no-build`-off, that `#print axioms` for the G1/G3 headline theorems matches a recorded baseline (the C2 mechanism, extended) | unknown until Phases 2-3 land | Yes — Phases 2-3 clear it |

C14 is the check the task actually asks for ("diffs documented status/axiom tables against actual
`#print axioms` output and the C3 sorry inventory"). The cleanest form reuses C2's existing
machinery verbatim: write a scratch `.lean`, `lake env lean` it, rejoin the pretty-printer's
continuation lines with the `sed` idiom already in the script at `:147-148`, and compare to a
baseline heredoc. Extend the four-theorem list to include `sound_of_isValid` and
`completeness_dedekind`, so that G1 and G3 are pinned by the build rather than by prose.

**Do not extend C5's regex to `Bimodal` (F8).** 48 occurrences remain, all in
`FormalSystem/**/README.md`, outside this task's `file_scope`. Adding `Bimodal` to C5 would turn
a green gate red on files this task must not touch. C12 above already covers the *slash* form;
the dotted `Bimodal.*` sweep belongs in the follow-up task that 485 handed off.

**`readme-lint.sh` scope extension (6b-ii).** Two changes: (a) in Checks 2-4, iterate over
`*.md` rather than `README.md` when the root is not a Lean tree, or simply accept multiple roots;
(b) make the summary block count Check 2's `NOT LISTED` hits, or explicitly document that it does
not. If (b) is done, note that it turns 110 currently-cosmetic warnings into gate failures —
see §8.1. Recommend documenting rather than enforcing.

---

## 9. Scope decisions the planner must make

### 9.1 Does the guard extend C9 (task references) to `docs/`?

Arguments for: it is the single cheapest guard to write (C9's grep is 3 lines), the rule
(`.claude/rules/no-task-references-in-deliverables.md`) already binds `docs/`, and Class H of the
dead links exists *because* nothing enforced it.

Argument against: **152 citations** must be removed first, 100 of them in one file
(`PHASED_IMPLEMENTATION.md`) that nothing else in this task touches.

**Recommendation**: add the check computing over `docs/` from the outset with
`ENFORCE_C9_DOCS=${ENFORCE_C9_DOCS:-0}` — the script's own documented pattern for "an end-state
invariant the tree does not satisfy until the corresponding work lands" (`:52-58`). Progress is
visible at every gate without blocking this task. Flip it in the follow-up that cleans
`PHASED_IMPLEMENTATION.md`. Do **not** silently omit the check.

### 9.2 Should `docs/` link into `.claude/` at all? (Class F)

`.claude/` is a gitignored, disposable deploy artifact regenerated from
`agent-system/extensions/**` (see `.claude/rules/source-store-deploy-boundary.md`). The 6 links
resolve on this machine and would resolve on any machine that has deployed the agent system, but
they are dead in a fresh clone. Recommend converting to unlinked prose ("see the agent-system
configuration under `.claude/`"), which satisfies the link gate without asserting a path that a
clean checkout does not have.

### 9.3 Does the metric table stay, or become a command?

`README.md` (as corrected by 485) prints its `cloc` command directly beneath its table, which is
what made the drift detectable. Recommend the same treatment for
`project-info/README.md:123` and `implementation-status.md:129-130`, rather than hardcoding
`539` in two more places that will drift again.

---

## 10. Suggested phase decomposition

Sized so each phase is one agent run and ends at a checkable state. Phase 6 must run last, per
the task's own constraint.

| Phase | Content | Gate |
|-------|---------|------|
| **P1** | Deletions 1a + 1b; rewrite `MAINTENANCE.md`'s 4-document procedure around C3; repoint or delete all 15 `SORRY_REGISTRY` inbound references | `SORRY_REGISTRY.md` and `IMPLEMENTATION_STATUS.md` gone; `grep -rn SORRY_REGISTRY docs/` returns only intentional prose |
| **P2** | 2a + 2b + G1 + G2 + G9 — the completeness/decidability status core, lifting prose from `Metalogic.lean:83-110`, `StrongCompleteness.lean:25-89`, `Correctness.lean:88-145`. Rewrite Limitations 1 and 6 | no `docs/` file asserts residual Base-frame debt; three strong-completeness statuses stated |
| **P3** | 2c + 2d + 2e + 2h + 2i + 2j — remaining false-status sites, plus the three unlisted `implementation-status.md` defects (§4, row 2d) | §4 table fully addressed |
| **P4** | 3a + 3b + 3c + 3d + 2f + 2g — the count/classification sweep; axiom-reference layer table to 45/37/2/3/3; `untl`/`snce` in `operators.md`; metric tables | `grep -rn '\b21 axiom\|14 axiom\|~40 \|~8000' docs/` clean |
| **P5** | Phase 4 dead links, all 74, per §6.2's table; plus the 25 non-link `Logos/` prose paths (Class I) | the §6.1 command returns 0 lines; `slash-path` scan returns 0 |
| **P6** | Gaps G3-G8 — new content in `API_REFERENCE.md`, `known-limitations.md`, `MODULE_ORGANIZATION.md`, `user-guide/architecture.md` | each of the 15 grep terms in §7 hits ≥1 `docs/` file |
| **P7** | 6a — the 9 missing READMEs | `readme-lint.sh` missing count 0 |
| **P8** | 6b — C12, C13, C14 in `check-module-invariants.sh`; `readme-lint.sh` scope extension; `MODULE_INVARIANTS.md` documentation of the new checks | `bash scripts/check-module-invariants.sh` → `ALL CHECKS PASSED`, with the new checks reporting real (non-skipped) results |

P2/P3/P4 touch overlapping files (`known-limitations.md`, `implementation-status.md`,
`FEATURE_REGISTRY.md`). If dispatched in parallel under territory contracts, split by **file**
rather than by defect ID: assign `known-limitations.md` + `Correctness`-derived content to one
owner, `implementation-status.md` + `project-info/README.md` to a second,
`FEATURE_REGISTRY.md` + `axiom-reference.md` + `operators.md` to a third.

---

## 11. Zero-debt compliance

No phase of this task requires a `sorry`, an axiom, or any Lean declaration change. The work is
prose, markdown, and two shell scripts. The one place where a "defer it" temptation exists is
§9.1 (the C9 docs extension); the recommendation there is the script's own documented
soft-enforcement idiom, which *records* the invariant and reports progress rather than omitting
the check — the opposite of deferral.

## 12. Tactic survey

Not applicable. This task contains no proof goals: the verification gate explicitly forbids
changing any `.lean` declaration, signature, import, or tactic. The tooling used for verification
was `check-module-invariants.sh` (C1-C11), `readme-lint.sh`, `cloc`, and direct source reading.
The one Lean-execution mechanism relevant to the deliverable is `#print axioms` via
`lake env lean` on a scratch file — already implemented as C2 at
`scripts/check-module-invariants.sh:122-163` and the recommended basis for C14.

---

**Last verified**: 2026-08-25 against working tree `8202bfd42`.
