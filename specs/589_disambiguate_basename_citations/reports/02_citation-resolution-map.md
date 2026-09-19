# Research Report: Task #589

**Task**: 589 - Disambiguate the 35 basename citations C20 cannot verify (and absorb three broken `specs/` docstring citations)
**Started**: 2026-09-18T18:45:00-07:00
**Completed**: 2026-09-18T19:05:00-07:00
**Effort**: Small-medium (about 50 comment-only edits in 19 files; no proof changes)
**Dependencies**: None outstanding. Predecessors 584, 585, 591 and 595 are completed; the list below is re-measured against the current tree.
**Sources/Inputs**: - Codebase (C20 resolver logic extracted verbatim from `scripts/check-module-invariants.sh` and re-run with full output), `grep` for declaration sites, pinned Mathlib under `.lake/packages/mathlib`, `specs/589_disambiguate_basename_citations/reports/01_unverifiable-citation-inventory.md`, `specs/reviews/review-2026-09-16.md` Finding M4, task 595 completion summary. No Mathlib search tools needed (this is a comment-only task).
**Artifacts**: - specs/589_disambiguate_basename_citations/reports/02_citation-resolution-map.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Re-measured.** C20 still reports exactly 35 unverifiable citations (22 ambiguous, 13 unresolved), the same set as report 01. But the citing lines have moved (Tableau.lean +2..+4, BadIntervals +12, Singletons +6, TableauConformance +28, CompletenessDedekind -2, NfMultiAnchorBridge -1), and tier 1 now counts **1006** resolvable citations, not 1,012. The plan must use the line numbers below, not report 01's.
- **34 of the 35 cited line numbers are wrong.** Only `DenseModelSurgery/Defs.lean:197` (`epsAt`) is correct. All 11 archive citations have drifted, even though the archive "no longer moves".
- **3 of the 22 would fail tier 1 immediately if only the path were qualified.** They land on blank lines: `Completeness.lean:72`, and `Formula.lean:163` (cited twice from PriorINF and once from ChronicleMonadicBridge). Qualifying the path without correcting the line turns an INFO into a FAIL.
- **Tier 1 passing does not mean correct.** In the same sentences being edited there are already-qualified citations that pass tier 1 but point at the wrong line: `FormalSystem/Syntax/Formula.lean:118`, `Syntax/Formula.lean:181`/`:193`, `ProofSystem/Axioms.lean:379`/`:387`/`:390`. Some cite the wrong file: `DerivedAxioms.priorSGap` and `serialPast` live in `ProofSystem/DerivedAxioms.lean`, not `Axioms.lean`.
- **Recommendation for the convention decision: option 3, drop line numbers (cite by declaration name) for all 16 non-live targets.** That is the 11 archive citations, the 2 Mathlib citations and the 3 `specs/` citations. For the 22 live ones, do what the task says: qualify the path and correct the number. After that C20 INFO is 0, tier 1 rises from 1006 to 1028, and tier 2 stays at 0.

## Context & Scope

The C20 gate lives in `scripts/check-module-invariants.sh`, in the section headed
`# C20: file.lean:NNN citations -- two tiers`. The regex is
`\b((?:[A-Za-z0-9_]+/)*[A-Za-z0-9_]+\.lean):(\d+)\b`. The resolver:

- takes a path with a `/` in it as a suffix to match against the live tree;
- takes a bare basename as a lookup in `by_base`;
- builds the live tree with `Boneyard`, `.lake`, `.git` and `specs` pruned.

Two consequences matter for the plan:

1. The regex only reads the **first** number after `file.lean:`. In companion forms such as `Axioms.lean:113, 117`, `:377,387,398`, `:524-526`, `:163-179`, `:180,193` and `RefutationF2.lean:335/339`, the second number is never checked. The plan must correct those companions by hand.
2. A citation with no `:NNN` suffix does not match the regex at all. So de-line-numbering removes a citation from C20 completely. That is the intended effect for non-live targets.

Scope: comment and docstring text only. `lake build` is unaffected.

The working tree has uncommitted edits from task 560 in `Metalogic/Independence*`, `README.md` and `docs/theorem-index.md`. None of them overlaps any file this task edits.

## Findings

### Codebase Patterns

- The repository's rule is to cite the declaration name, never `file:line`. The C20 header comment says so, C15 resolves paper anchors by name, and commit `a16df671f` ("de-line-number the ShiftSet citations C20 tier 1 flagged") applied it.
- In **every one** of the 35 citing sentences, the prose already names the declaration or comment block it means. So a correct target can be found unambiguously in each case (table below).
- `DenseModelSurgery/Defs.lean` has a uniform +200-line drift (461->671, 384->584, 367->567, 340->540). Some insertion above line 200 shifted every later citation, and nothing noticed because each stale line was non-blank. This is the failure mode report 01 predicted.

### The 22 ambiguous citations: resolution map (current citing lines)

All paths below are relative to the repository root. "Now" is the line the named declaration starts on, or the first line of its docstring where the prose cites the docstring or warning.

| # | Citing site (current) | Cited | Prose names | Correct target | Verdict |
|---|---|---|---|---|---|
| 1 | `Metalogic/BXCanonical/Chronicle/ChronicleMonadicBridge.lean:763` | `Axioms.lean:524-526` | `minFrameClass = FrameClass.RTime` for prior_U_gap/priorSGap/sep | `ProofSystem/Axioms.lean:606` (`Axiom.minFrameClass`; arms at 611-612) | wrong |
| 2 | `...ChronicleMonadicBridge.lean:772` | `Axioms.lean:377` | `Axiom.prior_U_gap` stated with `Formula.kPlus` | `ProofSystem/Axioms.lean:442` | wrong |
| 3 | `...ChronicleMonadicBridge.lean:774` | `Formula.lean:163-179` | name-collision warning | `Syntax/Formula.lean:189` (warning line; `kPlus` docstring 181-197) | **blank, would FAIL** |
| 4 | `...ChronicleMonadicBridge.lean:908` | `Axioms.lean:398` | `Axiom.sep` | `ProofSystem/Axioms.lean:453` | wrong |
| 5 | `Metalogic/BXCanonical/CompletenessDedekind.lean:579` | `Completeness.lean:72` | `neg_consistent_of_not_derivable` | `Metalogic/BXCanonical/Completeness.lean:77` | **blank, would FAIL** |
| 6 | `Metalogic/Decidability/Tableau.lean:165` | `Axioms.lean:113, 117` | `Axiom.serial_future`, `DerivedAxioms.serialPast` | `ProofSystem/Axioms.lean:176`; `ProofSystem/DerivedAxioms.lean:85` | wrong (+ wrong file for 2nd) |
| 7 | `Metalogic/Decidability/Tableau.lean:1226` | `Axioms.lean:238` | `temp_linearity` | `ProofSystem/Axioms.lean:277` | wrong |
| 8 | `Metalogic/Decidability/Tableau.lean:1642` | `Axioms.lean:377,387,398` | prior_U_gap, priorSGap, sep | `ProofSystem/Axioms.lean:442`, `ProofSystem/DerivedAxioms.lean:165`, `ProofSystem/Axioms.lean:453` | wrong (+ wrong file for 2nd) |
| 9 | `Metalogic/Decidability/Tableau.lean:1928` | `Formula.lean:131` | `Formula.someFuture` | `Syntax/Formula.lean:149` | wrong |
| 10 | `Metalogic/Decidability/Tableau.lean:1928` | `Formula.lean:141` | `Formula.somePast` | `Syntax/Formula.lean:159` | wrong |
| 11 | `Metalogic/WeakCanonical/DenseModelSurgery/BadIntervals.lean:210` | `Defs.lean:461` | `epsTop` | `DenseModelSurgery/Defs.lean:671` | wrong |
| 12 | `...DenseModelSurgery/Lemma34.lean:17` | `Defs.lean:384` | `gapRightFormula_spec` | `DenseModelSurgery/Defs.lean:584` | wrong |
| 13 | `...DenseModelSurgery/Lemma34.lean:362` | `Defs.lean:197` | `epsAt` | `DenseModelSurgery/Defs.lean:197` | **correct** |
| 14 | `...DenseModelSurgery/Lemma34.lean:469` | `Defs.lean:367` | `gapRightFormula` | `DenseModelSurgery/Defs.lean:567` | wrong |
| 15 | `...DenseModelSurgery/Lemma5.lean:108` | `Defs.lean:461` | `epsTop` | `DenseModelSurgery/Defs.lean:671` | wrong |
| 16 | `...DenseModelSurgery/Lemma5.lean:171` | `Defs.lean:340` | `rhoFormula_eval` | `DenseModelSurgery/Defs.lean:540` | wrong |
| 17 | `...DenseModelSurgery/Singletons.lean:101` | `Soundness.lean:1601` | `sep_valid` | `Metalogic/Soundness.lean:1065` | wrong |
| 18 | `...DenseModelSurgery/Singletons.lean:128` | `Defs.lean:461` | `epsTop` | `DenseModelSurgery/Defs.lean:671` | wrong |
| 19 | `Metalogic/WeakCanonical/Kamp/PriorINF.lean:76` | `Formula.lean:163-179` | name-collision warning | `Syntax/Formula.lean:189` | **blank, would FAIL** |
| 20 | `.../Kamp/PriorINF.lean:110` | `Formula.lean:163-179` | name-collision warning | `Syntax/Formula.lean:189` | **blank, would FAIL** |
| 21 | `Tests/BimodalTest/TableauConformance.lean:334` | `Axioms.lean:113,117` | `serial_future`/`serial_past` | `ProofSystem/Axioms.lean:176`; `ProofSystem/DerivedAxioms.lean:85` (`serialPast`) | wrong (+ wrong file for 2nd) |
| 22 | `Tests/BimodalTest/TableauConformance.lean:488` | `Formula.lean:180,193` | `kPlus`/`kMinus` | `Syntax/Formula.lean:198`, `:211` | wrong |

The source files' own paths start with `FormalSystem/` except the `Tests/` rows. Every
"Correct target" path must be written with enough prefix to be unique to C20's suffix match.
`ProofSystem/Axioms.lean`, `Syntax/Formula.lean`, `BXCanonical/Completeness.lean`,
`DenseModelSurgery/Defs.lean` and `Metalogic/Soundness.lean` are each unique. The last is
unique because `Deterministic/Soundness.lean` and `SharedWitness/Soundness.lean` do not end with
`/Metalogic/Soundness.lean`.

**Collocated already-qualified citations in the same sentences.** These pass tier 1 today but are wrong. The plan should fix them in the same edit:

| Site | Cited | Should be |
|---|---|---|
| `ChronicleMonadicBridge.lean:772` | `Syntax/Formula.lean:181` (`Formula.kPlus`) | `Syntax/Formula.lean:198` |
| `ChronicleMonadicBridge.lean:~771` | `` (`Kamp/KPlusFaithful.lean:152` / ) `` | malformed: the second slot is empty. Fill it or drop it. |
| `Tableau.lean:1926` | `FormalSystem/Syntax/Formula.lean:118` (`Formula.top`) | `:136` |
| `PriorINF.lean:74` | `FormalSystem/Syntax/Formula.lean:181`, `:193` | `:198`, `:211` |
| `PriorINF.lean:77-78` | `ProofSystem/Axioms.lean:379`, `:387`, `:390` (prior_U_gap, priorSGap, sep) | `ProofSystem/Axioms.lean:442`, `ProofSystem/DerivedAxioms.lean:165`, `ProofSystem/Axioms.lean:453` |
| `PriorINF.lean:~108` | `Syntax/Formula.lean:181` | `:198` |

Stale prose to leave for the implementer's judgement: `ChronicleMonadicBridge.lean:908` says `minFrameClass = Dedekind`, but the frame class is now named `RTime`. The task says to correct the number and not the prose. A one-word rename to the current enum constructor is a factual correction, not a rewrite, but it can also be left as it is.

### The 13 unresolved citations: the convention decision

**Evidence for option 3 (drop line numbers, cite by name).** All 11 archive line numbers are wrong now:

| Cited | What is there now | What the prose means | Where it actually is |
|---|---|---|---|
| `NegationIndep.lean:193` / `:196` (Case 1a / 1b of `neg_vecEA2_indep`) | docstring bullet / `let trivBf` | the Case 1a / 1b lets of `neg_vecEA2_indep` | def at 195; cases at ~197-201 |
| `NegationIndep.lean:341-345` | the B.2-fix paragraph | "B.1 gap remains UNFIXABLE" obstruction | 343 |
| `NegationIndep.lean:346-364` | middle of B.1 paragraph | the unfixability ruling (B.1 + PHASE 3 re-confirmation) | 343-366 |
| `NegationIndep.lean:357-364` | middle of PHASE 3 paragraph | the PHASE 3 fallback | 352-366 (and its CORRECTION at 368) |
| `RefutationF2.lean:335/339` (`f2sub1`/`f2sub2`) | proof-case lines | defs | 358 / 362 |
| `RefutationF2.lean:582` (`f2_carrier_eq`) | a `show` inside a proof | theorem | 605 |
| `ExteriorPinnedProbeK.lean:181` (`kvE_probe_selfZone_coincide`) | `(Classical.dec _) := rfl` | theorem | 198 |

So "the archive does not move" is empirically false here: these citations were written against
pre-archive or pre-reflow versions. Option 2, extending C20 to verify the archive, would turn all
11 into tier-1 **failures** (or wrong-but-passing landings) and then require 11 line fixes that
the next archive reorganisation (ADR-005 already did one) would break again. Option 1, a marker
suffix, keeps 11 wrong numbers under a label that says "intentionally unchecked".

**Recommended convention (option 3).** Cite a non-live target by its **full path, with no
`:NNN`, plus the declaration name or a quoted comment-block marker**. Concrete rewrites:

| Current | Replacement |
|---|---|
| `` `Boneyard/NegationIndep.lean:193` `` / `:196` | `` `neg_vecEA2_indep` (Case 1a / Case 1b), `FormalSystem/Boneyard/Kamp/KampWeakCanonical/VecEANormalForm/NegationIndep.lean` `` |
| `` `Boneyard/NegationIndep.lean:341-345` `` | `` the "B.1 gap remains UNFIXABLE" note after `neg_2var_vec_ea_indep_correct` in `Boneyard/.../NegationIndep.lean` `` |
| `` `Boneyard/NegationIndep.lean:346-364` `` (x3) | `` the B.1 / "PHASE 3 RESOLUTION" note after `neg_2var_vec_ea_indep_correct` in `Boneyard/.../NegationIndep.lean` `` |
| `` `Boneyard/NegationIndep.lean:357-364` `` (x2) | `` the "PHASE 3 RESOLUTION" fallback (and its "CORRECTION") after `neg_2var_vec_ea_indep_correct` in `Boneyard/.../NegationIndep.lean` `` |
| `RefutationF2.lean:335/339` | `` `f2sub1`/`f2sub2` in `Boneyard/Kamp/KampWeakCanonical/TranslationEra/RefutationF2.lean` `` |
| `f2_carrier_eq`, `RefutationF2.lean:582` | `` `f2_carrier_eq` (same file) `` |
| `ExteriorPinnedProbeK.lean:181` | `` `Boneyard/Kamp/KampWeakCanonical/ProbeIterations/ExteriorPinnedProbeK.lean` `` (the declaration `kvE_probe_selfZone_coincide` is already named in the sentence) |

Use the full `FormalSystem/Boneyard/Kamp/KampWeakCanonical/...` path at least once per file.
Inside a single file, an abbreviated `Boneyard/.../X.lean` is fine for repeat mentions.

**Mathlib (2 citations, `scripts/check-copyright-headers.sh:5` and `:14`).** Both numbers are
**correct** against the pinned Mathlib: `isInLibraryRoot` is at 259 and `copyrightHeaderChecks`
at 182 in `.lake/packages/mathlib/Mathlib/Tactic/Linter/Header.lean`. Both sentences already
name the declaration. Under the same convention, drop `:259-264` and `:182-249` and keep
`` `isInLibraryRoot` (Mathlib/Tactic/Linter/Header.lean) `` and likewise for the other. Nothing is
lost, and the next Mathlib bump cannot rot them. If the user prefers to keep them, the fallback
is a C20 allowlist for the `Mathlib/` prefix. That is strictly more machinery, so it is not
recommended.

### The three broken `specs/` docstring citations (and one more found)

Task 595 is completed. It settled `docs/architecture/` as the home for decision records and
`docs/reference/` for reference records. None of the three needs a new record:

| Site (current line) | Citation | Recommended fix |
|---|---|---|
| `FormalSystem/Syntax/BigConj.lean:30` | `- Teammate A findings (specs/098/reports/03_teammate-a-findings.md §3.2)` | Drop the bullet. Drop the `## References` heading too if it becomes empty. The definitions are self-explanatory and nothing durable is lost. |
| `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/CarrierK1V.lean:44` (report said :42) | `(specs/305 report 40 — a genuine ≤2-cap violation)` | Replace with `(a genuine violation of the ≤2-free-variable cap, Lemma 3.2(2))`. That paper anchor is already used three lines below, at line 47. |
| `FormalSystem/Syntax/MinusLanguage/Axioms.lean:81-83` (report said :76) | "originally opened in §1.2 of the archived report ... under `specs/archive/514_.../reports/`" | Drop the sentence. The durable closure record is already cited just before it: `docs/reference/axiom-reference.md` § Paper Key Correspondence, which exists at line 358. |
| **Extra:** `Tests/BimodalTest/Property.lean:54` | `* [Research Report](../../specs/174_property_based_testing/reports/research-001.md)` | That directory does not exist. Drop the bullet. It belongs to the same class the task absorbs. |

A secondary note, out of C20's regex and **not** required: `CarrierK1V.lean:39-41` also carries
extension-less line citations (`VecEADecomp:233/244`, `KampPrior:307`). They are the same kind of
rot, but the task does not require them. Converting them to names while the file is open is
cheap.

### Recommendations

1. **The 22 ambiguous citations:** qualify each path and correct its number, including the companion numbers C20 does not read, using the resolution map above. Fix the collocated wrong-but-passing citations in the same sentences.
2. **The 11 archive, 2 Mathlib and 3+1 `specs/` citations:** drop the line numbers and cite by name (option 3), as tabulated above.
3. **Record the convention.** Add one sentence to the C20 header comment in `scripts/check-module-invariants.sh`: *"Citations of files outside the live tree (`Boneyard/`, Mathlib) name the declaration and the path without a line number; C20 does not read them."* Then change the INFO wording from "an archived path, say" so it no longer implies archive citations are expected to remain.
4. **Verification (expected after implementation):**
   - C20 INFO: absent (0).
   - Tier 1: `PASS ... all 1028 resolvable ... citation(s)`. That is 1006 + 22. The total drops by 13 because the de-line-numbered citations no longer match the regex. It is not 1006 + 35.
   - Tier 2: unchanged, `PASS ... zero`.
   - `lake build` is not needed for comment-only edits, but a targeted `lake env lean` on one edited file is a cheap sanity check if wanted.
5. **Optional (belongs in a follow-up task, not this one):** add a tier-1.5 name check. When a citation's sentence carries a backticked identifier, check that the identifier appears within a few lines of the cited line. This would have caught all 21 wrong-but-non-blank landings found here.

## Decisions

- Do the 22 ambiguous citations the way the task specifies (qualify + correct the number) rather than de-line-numbering them. The task text and its verification criterion ("tier 1's verified count rises") both require it, and WeakCanonical and Decidability are deliberately outside tier 2.
- Use option 3 for all non-live targets, backed by evidence that option 3 alone survives: 11 of 11 archive numbers had drifted.
- Mathlib citations are de-line-numbered as well, even though they are correct today. This gives one convention and zero INFO rows with no allowlist.
- The extra broken `Property.lean:54` link is absorbed, because it is the same defect class.
- No `user_decision` is needed. The task text already asks for option 3 to be evaluated first, and the evidence supports it.

## Risks & Mitigations

- **Line drift between this research and implementation.** Any edit above a cited line shifts it. Mitigation: the implementer re-derives each target by `grep -n` on the declaration name at edit time. The table is a map, not a set of frozen values. Edit citing files bottom-up within each file so that citing-site line numbers stay valid.
- **The 3 blank-line landings.** If a path is qualified without correcting the number, C20 tier 1 FAILs. Mitigation: always change the path and the number together, then run C20.
- **Suffix uniqueness.** A too-short qualified path such as `Soundness.lean` stays ambiguous. Mitigation: use the prefixes given above, then confirm with the extracted resolver (next item) before running the full script.
- **The full invariants script is slow and runs Lean.** Mitigation: to iterate on C20 alone, extract its Python the way this research did and run that:
  `awk '/^# C20: file.lean:NNN citations/{f=1} f&&/^python3 - <<.PYEOF.$/{g=1;next} g&&/^PYEOF$/{exit} g' scripts/check-module-invariants.sh > c20.py && ENFORCE_C20=1 python3 c20.py`
- **Line length.** Task 597 enforces `longLine`, so some rewritten docstring lines may exceed 100 columns. Mitigation: reflow within the comment and check with the repository's lint.

## Tactic Survey Results

- Not applicable (no tactic survey performed). The task edits comments only and involves no proof goals.

## Context Extension Recommendations

- **Topic**: citing files outside the live tree
- **Gap**: nothing states how to cite archived (`Boneyard/`) or upstream (Mathlib) declarations. The C20 header only implies the rule.
- **Recommendation**: put the one-sentence rule from Recommendation 3 in the C20 header. If a Lean-conventions doc covers citation style, mirror it there too.

## Appendix

- Measurement: the C20 Python block, extracted verbatim, with the INFO loop changed to print all rows plus `by_base` candidates. Run on 2026-09-18 against HEAD `b66e43acf` plus the uncommitted task-560 working tree.
- Declaration sites were located with `grep -n` for `| serial_future`, `| temp_linearity`, `| prior_U_gap`, `| sep `, `def Axiom.minFrameClass`, `def serialPast`, `def priorSGap`, `def top`, `def someFuture`, `def somePast`, `def kPlus`, `def kMinus`, `NAME-COLLISION WARNING`, `theorem neg_consistent_of_not_derivable`, `def epsTop`, `theorem gapRightFormula_spec`, `def gapRightFormula`, `theorem rhoFormula_eval`, `def epsAt`, `theorem sep_valid`, `def neg_vecEA2_indep`, `f2sub1`, `f2_carrier_eq`, `kvE_probe_selfZone_coincide`, `isInLibraryRoot` and `copyrightHeaderChecks`.
- References: `specs/reviews/review-2026-09-16.md` Finding M4; commit `a16df671f`; task 595 summary (`specs/archive/595_*/summaries/01_durable-records-home-summary.md`).
