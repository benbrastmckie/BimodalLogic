# Implementation Plan: Task #589

- **Task**: 589 - Disambiguate the 35 basename citations C20 cannot verify (and absorb three broken `specs/` docstring citations)
- **Status**: [COMPLETED]
- **Effort**: 3.5 hours
- **Dependencies**: None outstanding (predecessors 584, 585, 591, 595 completed; research re-measured against the current tree)
- **Research Inputs**: specs/589_disambiguate_basename_citations/reports/02_citation-resolution-map.md
- **Artifacts**: plans/02_citation-resolution-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false (comment/docstring edits only; no declarations, proofs or imports change)

## Overview

Every edit is comment or docstring text. The 22 AMBIGUOUS citations point at live files. For each one, qualify the path to a unique suffix and correct the line number. The line numbers must be corrected too: 21 of the 22 are wrong, and 3 land on blank lines once the path is qualified. The 16 citations of non-live targets are converted to declaration-name citations with no `:NNN` suffix, which takes them out of C20's regex. That is 11 Boneyard, 2 Mathlib, and 3 plus 1 extra `specs/` citations. The convention is then recorded in the C20 header. The work splits by citing-file cluster into four phases with disjoint files, which can run in parallel. A final gate phase follows.

### Research Integration

Report 02 is the primary input. Its main findings:
- C20 still reports exactly 35 unverifiable citations: 22 ambiguous and 13 unresolved.
- The current tier-1 baseline is **1006**, not report 01's 1,012.
- 34 of the 35 cited numbers are wrong. Only `DenseModelSurgery/Defs.lean:197` (`epsAt`) is right.
- `DenseModelSurgery/Defs.lean` drifted by a uniform +200 lines.
- Some sentences already carry qualified citations that pass tier 1 but point at the wrong line (`Syntax/Formula.lean:118/181/193`, `ProofSystem/Axioms.lean:379/387/390`). Some cite the wrong file: `priorSGap` and `serialPast` live in `ProofSystem/DerivedAxioms.lean`.
- The C20 regex reads only the first number after `file.lean:`. Companion numbers (`:113, 117`, `:377,387,398`, `:524-526`, `:163-179`, `:180,193`, `335/339`) are never checked, so they must be fixed by hand.
- Convention decision: the task asked for option 3 (drop line numbers, cite by name) to be evaluated first, and the evidence supports it. All 11 archive numbers had drifted, even though the archive "does not move". No `user_decision` is needed.

The report's tables are a **map, not frozen values**. The implementer re-derives every target with `grep -n` on the declaration name at edit time.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap consultation requested for this dispatch. This task is the terminal task of the codebase-cleanup topic.

## Goals & Non-Goals

**Goals**:
- For all 22 ambiguous citations, qualify the path to a unique suffix and correct the number. Also correct the companion numbers C20 does not read.
- Fix the collocated wrong-but-passing citations in the same sentences, including the wrong-file ones (`DerivedAxioms.lean`).
- Convert the 11 Boneyard, 2 Mathlib and 3+1 `specs/` citations to name-based citations with no line numbers.
- Record the out-of-live-tree citation convention in the C20 header, and reword the INFO message.
- End state: C20 INFO absent (0); tier 1 `PASS ... all 1028 resolvable` (1006 + 22), with zero out-of-range or blank landings; tier 2 still zero.

**Non-Goals**:
- A tier-1.5 name-near-line check. That belongs in a follow-up task (report Recommendation 5).
- Extending C20's resolver to the archive, or adding a `Mathlib/` allowlist. Option 3 makes both unnecessary.
- Rewriting prose. Correct numbers and paths, not sentences. The one allowed exception is optional: the stale `minFrameClass = Dedekind` becoming `RTime` at `ChronicleMonadicBridge`.
- The extension-less citations at `CarrierK1V.lean:39-41` (`VecEADecomp:233/244`, `KampPrior:307`). Converting them is optional, cheap, and not required.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Line drift between research and edit (any edit above a cited line shifts it) | M | M | Re-derive each target by `grep -n` on the declaration name at edit time. Edit citing sites bottom-up within each file. |
| Qualifying a path without fixing its number turns an INFO into a tier-1 FAIL (3 blank landings) | H | M | Always change the path and the number in the same edit. Run the extracted C20 after each phase. |
| A qualified suffix is still ambiguous (e.g. bare `Soundness.lean`) | M | L | Use the report's prefixes: `ProofSystem/Axioms.lean`, `ProofSystem/DerivedAxioms.lean`, `Syntax/Formula.lean`, `BXCanonical/Completeness.lean`, `DenseModelSurgery/Defs.lean`, `Metalogic/Soundness.lean`. Confirm with the extracted resolver. |
| A rewritten docstring line exceeds 100 columns (the `longLine` lint) | L | M | Reflow within the comment. Compile each edited Lean file (`lake env lean <file>`) to surface linter warnings. |
| Uncommitted task-560 edits in the working tree get swept into this task's commits | M | L | None of the files overlap. Stage only this task's explicit file list, never `git add -A` or a directory pathspec. |
| Parallel phases collide | L | L | Each phase owns a disjoint file set (listed per phase). Only Phase 4 touches `scripts/`. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3, 4 | -- |
| 2 | 5 | 1, 2, 3, 4 |

Phases within the same wave can execute in parallel (disjoint file ownership).

**C20-only iteration command** (used by every phase; much faster than the full invariants script):
```
awk '/^# C20: file.lean:NNN citations/{f=1} f&&/^python3 - <<.PYEOF.$/{g=1;next} g&&/^PYEOF$/{exit} g' \
  scripts/check-module-invariants.sh > "$SCRATCH/c20.py" && ENFORCE_C20=1 python3 "$SCRATCH/c20.py"
```
Put `c20.py` in a scratch directory, never in the repo.

### Phase 1: DenseModelSurgery cluster (8 citations) [COMPLETED]

**Goal**: Resolve report rows 11-18: the 7 `Defs.lean` citations plus `Soundness.lean:1601`.

**Tasks**:
- [x] Re-derive targets: `grep -n` for `def epsTop`, `theorem gapRightFormula_spec`, `def epsAt`, `def gapRightFormula`, `theorem rhoFormula_eval` in `FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/Defs.lean`, and for `theorem sep_valid` in `FormalSystem/Metalogic/Soundness.lean`. Expected values: 671, 584, 197, 567, 540, 1065.
- [x] `BadIntervals.lean` (~:210): `Defs.lean:461` becomes `DenseModelSurgery/Defs.lean:<epsTop>`.
- [x] `Lemma34.lean` (~:17, ~:362, ~:469): qualify all three. `:197` keeps its number; `:384` and `:367` are corrected.
- [x] `Lemma5.lean` (~:108, ~:171): qualify and correct (`epsTop`, `rhoFormula_eval`).
- [x] `Singletons.lean` (~:101, ~:128): `Soundness.lean:1601` becomes `Metalogic/Soundness.lean:<sep_valid>`, and `Defs.lean:461` becomes `DenseModelSurgery/Defs.lean:<epsTop>`.
- [x] Run the extracted C20. None of these 8 appears in INFO, and tier 1 has no FAIL. *(deviation: altered — to keep every edited file's line count unchanged (other files cite lines in these four), three sentences were minimally tightened during reflow: BadIntervals "together with" -> "plus", Lemma34 "where Reynolds transports it — namely at each application of" -> "where Reynolds does: at each use of", Lemma5 "Checked rather than asserted, exactly as" -> "Checked, not asserted, as"; the adjacent wrong-but-passing `ProofSystem/Axioms.lean:422` in Singletons was also corrected to 453 (`Axiom.sep`))*

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: The 8 citations sit in exactly 4 files at the approximate lines above (report 02, measured 2026-09-18). Confirm by grepping the C20 INFO output for `DenseModelSurgery` and `Soundness.lean:1601` before editing.

**Files to modify** (all under `FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/`):
- `BadIntervals.lean`, `Lemma34.lean`, `Lemma5.lean`, `Singletons.lean`: citation text only.

**Verification**:
- The extracted C20 shows no INFO rows from these files and no tier-1 FAIL.
- Each qualified citation's cited line contains (or begins the docstring of) the named declaration. Spot-check with `sed -n`.
- `lake env lean` on each edited file produces no new warnings (for example, no longLine warnings).

---

### Phase 2: Decidability, TableauConformance and CompletenessDedekind cluster (8 citations + collocated) [COMPLETED]

**Goal**: Resolve report rows 5-10 and 21-22, fix the collocated `Formula.lean:118`, and fix the wrong-file companions.

**Tasks**:
- [x] Re-derive targets with `grep -n`:
  - In `FormalSystem/ProofSystem/Axioms.lean`: `| serial_future`, `| temp_linearity`, `| prior_U_gap`, `| sep`.
  - In `FormalSystem/ProofSystem/DerivedAxioms.lean`: `def serialPast`, `def priorSGap`.
  - In `FormalSystem/Syntax/Formula.lean`: `def top`, `def someFuture`, `def somePast`, `def kPlus`, `def kMinus`.
  - In `FormalSystem/Metalogic/BXCanonical/Completeness.lean`: `theorem neg_consistent_of_not_derivable`.
- [x] `CompletenessDedekind.lean` (~:579): `Completeness.lean:72` becomes `BXCanonical/Completeness.lean:<77>`. The old number lands on a blank line.
- [x] `Tableau.lean`, bottom-up:
  - ~:1928: `Formula.lean:131`/`:141` become `Syntax/Formula.lean:<someFuture>`/`<somePast>`.
  - ~:1926: `FormalSystem/Syntax/Formula.lean:118` becomes `:<top>` (136).
  - ~:1642: `Axioms.lean:377,387,398` splits into `ProofSystem/Axioms.lean:<prior_U_gap>`, `ProofSystem/DerivedAxioms.lean:<priorSGap>` and `ProofSystem/Axioms.lean:<sep>`.
  - ~:1226: `Axioms.lean:238` becomes `ProofSystem/Axioms.lean:<temp_linearity>`.
  - ~:165: `Axioms.lean:113, 117` becomes `ProofSystem/Axioms.lean:<serial_future>` and `ProofSystem/DerivedAxioms.lean:<serialPast>`.
- [x] `Tests/BimodalTest/TableauConformance.lean`, bottom-up:
  - ~:488: `Formula.lean:180,193` becomes `Syntax/Formula.lean:<kPlus>`, `:<kMinus>`.
  - ~:334: `Axioms.lean:113,117` gets the same split as Tableau ~:165.
- [x] Run the extracted C20. *(deviation: altered — to keep Tableau.lean's line count fixed (it is cited from many modules), three sites were compacted: at ~:165 `DerivedAxioms.serialPast` is cited by name only (no path/line); at ~:1926 the prefix `FormalSystem/` was dropped (`Syntax/Formula.lean:136`, still unique); at ~:1928 the second citation is the companion form `:159`. TableauConformance.lean and CompletenessDedekind.lean each grew by one line (no inbound citations))*

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: 8 C20-visible citations plus 1 collocated qualified citation, in 3 files. Confirm against the C20 INFO rows for `Tableau.lean`, `TableauConformance.lean` and `CompletenessDedekind.lean` before editing.

**Files to modify**:
- `FormalSystem/Metalogic/BXCanonical/CompletenessDedekind.lean`: one citation.
- `FormalSystem/Metalogic/Decidability/Tableau.lean`: five sites.
- `Tests/BimodalTest/TableauConformance.lean`: two sites.

**Verification**:
- The extracted C20 shows no INFO rows from these files and no tier-1 FAIL.
- Every companion number (the second and third numbers in a list) lands on its named declaration. Check each by hand with `sed -n`, because C20 does not read them.
- `lake env lean` on each edited file produces no new warnings.

---

### Phase 3: ChronicleMonadicBridge and PriorINF cluster (6 citations + collocated) [COMPLETED]

**Goal**: Resolve report rows 1-4 and 19-20, including the 3 `Formula.lean:163-179` blank landings, and fix the collocated wrong-but-passing citations and the malformed empty slot.

**Tasks**:
- [x] Re-derive targets with `grep -n`: `def Axiom.minFrameClass`, `| prior_U_gap`, `| sep` (ProofSystem/Axioms.lean); `def priorSGap` (ProofSystem/DerivedAxioms.lean); `def kPlus`, `def kMinus`, `NAME-COLLISION WARNING` (Syntax/Formula.lean).
- [x] In `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleMonadicBridge.lean`, bottom-up:
  - ~:908: `Axioms.lean:398` becomes `ProofSystem/Axioms.lean:<sep>`. Optionally reword `Dedekind` to `RTime`.
  - ~:774: `Formula.lean:163-179` becomes `Syntax/Formula.lean:<warning line>`. Use a single line or a correct range.
  - ~:772: `Axioms.lean:377` becomes `ProofSystem/Axioms.lean:<prior_U_gap>`, and the collocated `Syntax/Formula.lean:181` becomes `:<kPlus>`.
  - ~:771: the malformed `` (`Kamp/KPlusFaithful.lean:152` / ) ``. Fill the empty slot with the intended target if the prose makes it clear. Otherwise drop the empty slot. Verify that `KPlusFaithful.lean:152` itself lands on its intended declaration.
  - ~:763: `Axioms.lean:524-526` becomes `ProofSystem/Axioms.lean:<minFrameClass>`, with the companion range pointing at the arms.
- [x] In `FormalSystem/Metalogic/WeakCanonical/Kamp/PriorINF.lean`, bottom-up:
  - ~:110 and ~:108: `Formula.lean:163-179` becomes `Syntax/Formula.lean:<warning>`, and the collocated `Syntax/Formula.lean:181` becomes `:<kPlus>`.
  - ~:74-78: `Formula.lean:163-179` becomes `Syntax/Formula.lean:<warning>`. The collocated `Formula.lean:181`/`:193` become `:<kPlus>`/`:<kMinus>`. `ProofSystem/Axioms.lean:379/387/390` become `ProofSystem/Axioms.lean:<prior_U_gap>`, `ProofSystem/DerivedAxioms.lean:<priorSGap>` and `ProofSystem/Axioms.lean:<sep>`.
- [x] Run the extracted C20. *(deviation: altered — the empty slot was filled with `:174` (`kMinus_formula_correct`); `minFrameClass = Dedekind` reworded to `RTime`; the collocated wrong-but-passing `Core/MaximalConsistent.lean:491` was corrected to 462 (`theorem_in_mcs`); in PriorINF `DerivedAxioms.priorSGap` is cited by name only so the `:453` companion stays unambiguous; `Kamp/PriorINF.lean:~93` (not C20-read) left as is)*

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: 6 C20-visible citations plus about 6 collocated qualified citations and 1 malformed slot, in 2 files. Confirm by reading the full sentences around each INFO row before editing.

**Files to modify**:
- `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleMonadicBridge.lean`: citation text only.
- `FormalSystem/Metalogic/WeakCanonical/Kamp/PriorINF.lean`: citation text only.

**Verification**:
- The extracted C20 shows no INFO rows from these files and no tier-1 FAIL. In particular, none of the three former `163-179` sites lands on a blank line.
- The collocated and companion numbers are checked by hand with `sed -n`.
- `lake env lean` on each edited file produces no new warnings.

---

### Phase 4: Non-live targets by name (Boneyard, Mathlib, specs/) and record the convention [COMPLETED]

**Goal**: Convert the 13 UNRESOLVED citations and the 3+1 broken `specs/` citations to name-based citations with no line numbers (option 3), and record the convention in C20.

**Tasks**:
- [x] List the exact citing sites of the 11 Boneyard citations from the extracted C20 INFO output: `NegationIndep.lean` x8, `RefutationF2.lean` x2 and `ExteriorPinnedProbeK.lean` x1.
- [x] Rewrite each Boneyard citation per the report's replacement table. Use the full `FormalSystem/Boneyard/Kamp/KampWeakCanonical/...` path (no `:NNN`) at least once per citing file. `Boneyard/.../X.lean` is acceptable for later mentions in the same file. Anchor each citation to its declaration or its quoted comment-block marker:
  - `neg_vecEA2_indep` Case 1a / Case 1b.
  - The "B.1 gap remains UNFIXABLE" and "PHASE 3 RESOLUTION" / "CORRECTION" notes after `neg_2var_vec_ea_indep_correct`.
  - `f2sub1`/`f2sub2` and `f2_carrier_eq`.
  - `kvE_probe_selfZone_coincide`.
  - Confirm each quoted marker and declaration name exists in the archived file with `grep`.
- [x] `scripts/check-copyright-headers.sh` (:5, :14): drop `:259-264` and `:182-249`. Keep `` `isInLibraryRoot` `` / `` `copyrightHeaderChecks` `` (Mathlib/Tactic/Linter/Header.lean).
- [x] `FormalSystem/Syntax/BigConj.lean` (~:30): drop the `specs/098` bullet, and drop the `## References` heading if it becomes empty.
- [x] `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/CarrierK1V.lean` (~:44): replace `(specs/305 report 40 ...)` with `(a genuine violation of the ≤2-free-variable cap, Lemma 3.2(2))`. Optionally, name-cite the extension-less `VecEADecomp:233/244` and `KampPrior:307` at ~:39-41.
- [x] `FormalSystem/Syntax/MinusLanguage/Axioms.lean` (~:81-83): drop the `specs/archive/514_...` sentence. The `docs/reference/axiom-reference.md` § Paper Key Correspondence citation just before it remains the durable anchor; confirm that section still exists.
- [x] `Tests/BimodalTest/Property.lean` (~:54): drop the dead `specs/174_.../research-001.md` bullet.
- [x] In the C20 header comment in `scripts/check-module-invariants.sh`, add the convention sentence: citations of files outside the live tree (`Boneyard/`, Mathlib) name the declaration and give the path without a line number, and C20 does not read them. Also reword the INFO message so it no longer implies that archived-path citations are expected to remain, for example by dropping "an archived path, say". Change comments and message strings only; do not change resolver logic.
- [x] Run a repo-wide `grep -rn 'specs/[0-9]' FormalSystem Tests --include=*.lean` and confirm that no live docstring still cites a `specs/` path. Leave any hits outside this task's scope for a follow-up, and note them in the summary.
- [x] Run the extracted C20. *(deviation: altered — to preserve line counts where many modules cite a file, some Boneyard citations use a shorter anchor: NegFix uses `Boneyard/Kamp/KampWeakCanonical/VecEANormalForm/NegationIndep.lean` (no `FormalSystem/` prefix) with the "PHASE 3 RESOLUTION" marker only; CarrierK1V uses "(a genuine ≤2-free-variable-cap violation, Lemma 3.2(2))". Prop42Contentful (+1 line) and Section5Correspondence (+2 lines) grew; their 8 inbound citations in Prop42Faithful.lean, NfMultiAnchorBridge.lean and Section5Correspondence.lean were shifted mechanically via a difflib line map (same target line content). The optional extension-less `VecEADecomp:233/244`, `KampPrior:307` in CarrierK1V were not converted. The INFO message now also says how to fix a row)*

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: 11 Boneyard citations in the live citing files that C20 INFO names, 2 in `check-copyright-headers.sh`, and 4 `specs/` citations in 4 Lean files. This comes from report 02. Confirm the Boneyard citing-file set from the C20 INFO output before editing; the report lists the cited files, not the citing ones.

**Files to modify**:
- The live files that cite `NegationIndep.lean`, `RefutationF2.lean` and `ExteriorPinnedProbeK.lean`, as enumerated from the C20 INFO output. A planning-time grep found these 6 files, all under `FormalSystem/Metalogic/WeakCanonical/Kamp/`: `Prop42Contentful.lean`, `Section5Correspondence.lean`, `NfMultiAnchorBridge.lean`, `NfMultiAnchorBridge/ExteriorFiberK.lean`, `NfMultiAnchorBridge/ExteriorPinnedConverseK.lean` and `EANegationFix/NegFix.lean`. None overlaps Phases 1-3.
- `scripts/check-copyright-headers.sh`: comments only.
- `scripts/check-module-invariants.sh`: the C20 header comment and the INFO message string.
- `FormalSystem/Syntax/BigConj.lean`, `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/CarrierK1V.lean`, `FormalSystem/Syntax/MinusLanguage/Axioms.lean`, `Tests/BimodalTest/Property.lean`: docstrings only.

**Verification**:
- The extracted C20 shows no UNRESOLVED INFO rows.
- `bash scripts/check-copyright-headers.sh` still runs cleanly.
- `lake env lean` on each edited Lean file produces no new warnings.

---

### Phase 5: Final gate [COMPLETED]

**Goal**: Confirm the end state across the whole repository with the full gate set.

**Tasks**:
- [x] Run the extracted C20 and confirm:
  - INFO rows are absent (0).
  - Tier 1 reports `PASS ... all 1028 resolvable` (1006 + 22). Any deviation must be explained, for example by a citation that concurrent work added or removed. *(deviation: result is 1031 = 1006 + 22 + 3: companion lists split into separately qualified citations add 4 regex matches (Tableau ~:1642 +2, TableauConformance ~:334 +1, ~:488 +1) and the `:159` companion form at Tableau ~:1928 removes 1)*
  - There are zero out-of-range or blank landings.
  - Tier 2 reports PASS with zero.
- [x] Run the full `bash scripts/check-module-invariants.sh`. It must have no new FAILs compared with the pre-task baseline.
- [x] Run `lake build`. It must pass; the edits are comment-only, but this is the final gate.
- [x] Run the repository's task-reference lint on the edited deliverables. Deliverable files must not cite task numbers.
- [x] Review the staged diff: only this task's explicit file list, with no task-560 working-tree files.

**Timing**: 0.5 hours

**Depends on**: 1, 2, 3, 4

**Verification Tier**: full

**Files to modify**:
- None, unless a gate finding requires a fix in a file from Phases 1-4.

**Verification**:
- All gate commands above pass with the stated counts.

## Testing & Validation

- [x] C20 INFO is 0.
- [x] C20 tier 1 is PASS with 1028 resolvable citations, and zero out-of-range or blank landings.
- [x] C20 tier 2 is PASS with zero.
- [x] Every companion number C20 does not read has been verified by hand against its named declaration.
- [x] The full `check-module-invariants.sh` has no new FAILs, and `lake build` is green.
- [x] No `specs/` path citations remain in the four absorbed docstrings.

## Artifacts & Outputs

- Comment-only edits in about 19 files (Lean docstrings plus two scripts).
- The C20 header records the convention for citing targets outside the live tree.
- specs/589_disambiguate_basename_citations/summaries/02_citation-resolution-summary.md, written at implementation.

## Rollback/Contingency

All changes are comment text, committed per phase with explicit per-file staging, so any phase can be reverted with `git revert` of its commit. If tier 1 FAILs after a phase, fix the offending line number in place, re-deriving it with `grep -n`; a revert is not needed. If the Boneyard citing-file set from Phase 4 overlaps Phases 1-3, run Phase 4 after them instead of in parallel.
