# Research Report: Task #621

**Task**: 621 - Adopt uniform reflect naming for time reversal
**Started**: 2026-09-18T17:17:39Z
**Completed**: 2026-09-18T17:45:00Z
**Effort**: 3-5 hours (one mechanical identifier phase, one prose phase, one record/gates phase)
**Dependencies**: None (builds on the completed swap-family decision recorded in the time-reflection wave section of `docs/reference/paper-definitions-of-record.md`)
**Sources/Inputs**: - Codebase grep inventory (`FormalSystem/`, `Tests/`, READMEs, `docs/`, `typst/`, `scripts/`); live paper `possible_worlds.tex` (`lem:time-reflection` at line 4186, `thm:TR-valid` at line 4254); `docs/reference/paper-definitions-of-record.md`; `scripts/check-module-invariants.sh` (C15); `scripts/check-paper-definitions.sh`; lean-lsp MCP not needed (pure rename, no new proofs)
**Artifacts**: - specs/621_adopt_uniform_reflect_naming_for_time_reversal/reports/01_uniform-reflect-naming.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The paper change is confirmed. `\label{lem:time-reflection}` is live and not commented out (line 4186).
  `lem:temporal-duality` no longer occurs anywhere in the paper. The lemma also grew: it now proves
  that `F⁻` is a task frame and that `τ ↦ τ⁻` is a bijection `H_F → H_{F⁻}`. `check-paper-definitions.sh` gives case (b), a pass: the
  checksum moved, but all 42 pinned definitions are unchanged. No pinned entry needs a re-pin.
- Neither label is pinned or listed in KNOWN-ANCHORS, and no file in live tree scope cites
  either one. So C15 is unaffected today. **If any tree site is going to cite `lem:time-reflection`,
  the record must first get a `lem:time-reflection|LIVE-UNPINNED` row.** The one planned citation is the
  `truth_reflectTime` docstring. Without that row C15 goes red.
- Applying the test "does it reverse time order?" gives this verdict: **rename 8 identifier families**
  (about 250 occurrences in 15 Lean files). **Keep** the exchange-type `swap`s. These are the Kamp/EF
  `Equiv.swap`/`aggOdSwap12`/`swapNF01` family, `contraSwap`, `monoInv_swap`,
  `pairProject_swap_*`, the `trySwap*` mutators, and the `"modal_swap"`/`"temporal_swap"`/`"derived_swap"`
  wire tags with their `*SwapCount` fields.
- No test file or typst file references any renamed identifier. The renames touch only
  `FormalSystem/`, 3 READMEs and the record. There is also a prose sweep (Lean docstrings, 7
  docs files, 1 typst line, 3 test comment blocks).
- The work needs no new proofs and introduces no sorry or axiom. The one build risk is the rename of the `register_simp_attr`
  (`swap_norm`). It must happen in `TruthNormAttr.lean` and at every `simp only [...]` user in the same
  commit.

## Context & Scope

Here is the principle to apply: *`reflect` names every operation that reverses the time order on any
object (formula, frame, history, truth lemma). `swap` survives only for exchanges that are not time
reversal.* The time-reflection wave (2026-09-17) already renamed the formula-level operation
(`swapTemporal` → `reflectTime`, `swapMinus` → `MinusFormula.reflectTime`) and the
`*_swap_valid*` family. It kept `truth_swap`, `MinusFrame.swap` and `swapUS` by carve-out, and it
explicitly deferred `swap_norm`, `*_swap_of_tm*`, the `cValid` swaps and `starValid_*_swap`. This
task retires those carve-outs, because the paper's rename removes the "semantic lemma keeps its
name" justification.

Baseline: `bash scripts/check-module-invariants.sh` exits 0 (C15 passes), and
`bash scripts/check-paper-definitions.sh` exits 0 (case b).

## Findings

### Codebase Patterns

#### A. Paper and record

- Paper `lem:time-reflection` (line 4186) states `M,τ,x ⊨ φ ⇔ M⁻,τ⁻,n(x) ⊨ φ⟨S|U⟩`, with
  `F⁻ : w ⇒⁻_x u ≔ w ⇒_{-x} u` and `τ⁻ = τ ∘ n`. It now also includes the claims that "F⁻ is a
  task frame" and that `τ ↦ τ⁻` is a bijection. `thm:TR-valid` (line 4254) cites it three times.
- Record sites that must change (`docs/reference/paper-definitions-of-record.md`):
  - line 108-110: the carve-out bullet "**The semantic lemma keeps its name.**" Retire it and
    replace it with a note that the paper renamed `lem:temporal-duality` → `lem:time-reflection`, so the
    carve-out is withdrawn.
  - line 128-131: `swapUS` (**kept**). Flip to renamed.
  - line 132-135: `truth_swap` (**kept**). Flip to renamed. `MinusFrame.swap` → `MinusFrame.reflect`.
  - line 138-141: "Adjacent `swap`-named identifiers ... possible follow-up". Replace with the
    classification table below.
  - line 338: the historical note on `lem:temporal-duality`. Leave it verbatim (it is dated history), or
    add "(since renamed `lem:time-reflection`)" in the same style as the `thm:TD-valid` parenthetical.
  - Add a new dated section, e.g. "Label rename absorption (2026-09-18): `lem:temporal-duality` →
    `lem:time-reflection`, prose only, no re-pin". Follow the dirty-pin convention the record already
    documents: re-pin only when absorbing a drift correction, and case (b) is not one.
  - KNOWN-ANCHORS: add `lem:time-reflection|LIVE-UNPINNED|...`, which is required before any tree
    citation. Optionally add `lem:temporal-duality|DANGLING|renamed by the paper to
    lem:time-reflection; cited only where the tree records the rename`. That row is needed only if
    some tree site records the old label.

#### B. Identifier classification (the test: does it denote reversal of time order?)

| Current | Kind / file(s) | Occurrences | Verdict | New name |
|---|---|---|---|---|
| `MinusFrame.swap` | def, `Semantics/MinusLanguage/MinusFrame.lean` (+ `F.swap` in `Metalogic/Conservativity/SpCountermodel.lean`, prose in `Semantics.lean`) | 8 | reverses the order of a frame (paper `F⁻`) | `MinusFrame.reflect` |
| `truth_swap` (`FormalSystem.Semantics`) | theorem, `MinusFrame.lean`. Users: `SpCountermodel.lean:204`. Prose: `Conservativity.lean`, `Semantics.lean`, `SpCountermodel.lean`, `Semantics/MinusLanguage/README.md` | 9 Lean + 1 README | truth lemma for time reversal (the L⁻ analogue of `lem:time-reflection`) | `truth_reflectTime` |
| `swapUS`, `swapUS_involutive` | def and theorem, `Metalogic/WeakCanonical/DenseModelSurgery/Dual.lean`. Users: `Lemma5.lean`, `TruthTransfer.lean`, `NoGaps.lean` (prose) | 43 + 9 | time reflection with boxes opaque (box subformulas treated as atoms) | `reflectTimeBoxOpaque`, `reflectTimeBoxOpaque_involutive` |
| `swap_norm` | `register_simp_attr`, `Automation/TruthNormAttr.lean:57`. Users: `Syntax/Formula.lean:706-715`, `Metalogic/Soundness.lean:1189`, `SoundnessLemmas/FrameClassVariants.lean` (13×), `Semantics/TruthTransport.lean` (prose), `Automation/README.md:82` | 25 | simp set of the `reflect_time_*` push-through lemmas | `reflect_time_norm` |
| `Encoding.swap` (`e.swap`, `theEncoding.swap`) | def, `Metalogic/Conservativity/Plus/Atomization.lean:83`. Used in `CoarsenedModels.lean` | ~12 | the encoding conjugated by `reflectTime`: `e.swap.ι (inr χ) = e.ι (inr χ.reflectTime)`. It exchanges nothing | `Encoding.reflectTime` (see Decisions) |
| `plusValidIn_swap_of_tm`, `plusValidIn_swap_of_tm_deriv` | `Atomization.lean:218,242`. Users: `Plus/AxiomValidity.lean` (46 lines), `Plus.lean`, `Soundness.lean:134` (prose) | 36 + 18 | concludes `PlusValidIn fc φ.reflectTime` | `plusValidIn_reflect_time_of_tm`, `plusValidIn_reflect_time_of_tm_deriv` |
| `cValid_swap_of_tm`, `cValid_swap_of_tm_deriv`, `naiveAxiom_cValid_swap`, `naive_cValid_and_swap` | `Metalogic/Independence/CoarsenedModels.lean` (only file) | 26 + 15 + 3 + 8 | each concludes `CValid φ.reflectTime` | `cValid_reflect_time_of_tm`, `cValid_reflect_time_of_tm_deriv`, `naiveAxiom_cValid_reflect_time`, `naive_cValid_and_reflect_time` |
| `starValid_{discrete_propagate_fwd, discrete_propagate_bwd, discrete_box_necessity, density, dense_indicator, z1, sep, modal_future, paste, untl_paste}_swap` (10) | `Conservativity/Star/StarAxiomValidity.lean`. Prose: `Syntax/StarLanguage/Axioms.lean:129-134` | ~20 | each is the temporal dual (reflectTime image) of a schema, consumed by `starAxiom_reflect_time_validIn_min` | `starValid_*_reflect_time` |
| `swap_next_all_future_eq` | `Theorems/DiscreteUnfolding.lean:439,456` | 2 | a `reflectTime` image equation | `reflect_time_next_all_future_eq` |

Every new name was checked with `grep -w` and none is already taken. The `FormalSystem.Semantics.TaskFrame.reflect` in
`Semantics/TaskFrame.lean:282` (the reflection convention on relations) lives in a different namespace
from `FormalSystem.Semantics.MinusFrame.reflect`, so there is no clash. Dot notation `F.reflect`
resolves by the type of `F`.

The naming pattern follows the substring rule the 2026-09-17 wave set: in multi-word snake_case
lemma names `swap` becomes `reflect_time` (as in `derivable_valid_and_reflect_time_validIn`), and in
camelCase defs it becomes `reflectTime`. The two exceptions are the frame operation, which becomes plain `reflect`
because it acts on a frame rather than on time-indexed content (as the task description asks), and
`truth_reflectTime`, which follows the description.

Local hypothesis names (`h_swap`, `h_box_swap`, `tf_swap`, `mt_swap`, `hswap`, `d_swap`,
`deriv_swap`, `g_swap`, ...) mostly sit in `FrameClassVariants.lean`, `Soundness.lean` and
`Principles.lean`. They are not API. Rename them to `h_refl`-style names only where the plan chooses a zero-`swap`
grep gate for those files. Otherwise leave them.

#### C. Keep (exchange, not time reversal) — `swap` survives

- `Equiv.swap`, `Prod.swap`, `List.Perm.swap` (Mathlib), `aggOdSwap12*`, `CAggOdSwap_clause_iff*`,
  `swapNF01*`, `cons2_comp_swap01` (Kamp/NfMultiAnchorBridge: index transpositions).
- `monoInv_swap`, `monoInv_of_swap` (GroupModel: pair-component exchange), `pairProject_swap_*`
  (EFSatNegation), `contraSwap` (Combinators: contraposition argument exchange).
- `trySwap*` mutators and the mutation-family wire tags `"modal_swap"`, `"temporal_swap"`,
  `"derived_swap"` plus the `modalSwapCount`/`temporalSwapCount`/`derivedSwapCount` fields
  (`Automation/ContrastiveGeneratorMain.lean`). These exchange operators within one time direction
  (until↔release, P↔H, box↔diamond), so they are not reflection. They are also serialized, so they stay byte-stable.
- The `"temporal_duality"` wire strings and the `"temporalDualityCount"` key (already carved out by the
  2026-09-17 wave) stay byte-stable.
- Operator-duality prose (`temporalDualityNeg`, `MonotonicityDuality.lean`, `section TemporalDuality`
  in `TemporalDerived.lean`, `docs/reference/axiom-reference.md:281` "△φ ↔ ¬▽¬φ") names ▽/△ and F/G
  duality, not reflection. Keep it.

#### D. Out of scope but flagged (other words for time reversal)

The principle also covers `mirror`/`dual`/`AntiIso` names. The task names only the swap families,
so these are **not** recommended for this task. List them as a possible follow-up:
- `CoNotPriorU.clockMirrorIso`, `truthAt_mirror` (8 occurrences, one file). This is a time-reversal truth lemma
  for the clock model. It is cheap to rename to `clockReflectIso`/`truthAt_reflect`. `reflect` on
  histories in the same file already follows the principle.
- `TruthAntiIso` / `Truth.truthAt_of_truthAntiIso` (`Semantics/TruthTransport.lean`). This is the generic
  task-frame analogue of `lem:time-reflection`. Keep the structure name, which is a precise "anti-isomorphism"
  concept, but consider adding a `lem:time-reflection` pointer to its docstring. That pointer needs the KNOWN-ANCHORS row.
- `DenseModelSurgery.dual`/`dualize`/`*_dual` (order duality of monadic structures, Mathlib
  `OrderDual` idiom) and `sep_order_mirror`. Keep them.
- "mirror" as prose for derived time-reflection schemata (about 1,100 occurrences). Keep it.

### External Resources

- No Mathlib search was needed: the task renames identifiers and changes no statements.
- Paper: `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`, `lem:time-reflection` (l.4186), `thm:TR-valid` (l.4254). Commented-out references at l.3817, l.3948 and l.4030 also use the new label.

### Prose inventory (needs rewording; not identifiers)

Lean docstrings and comments where "swap" or "temporal duality" names the reflection:
- `Semantics/MinusLanguage/MinusFrame.lean` (13 lines). This includes l.65-70 "Converse closure and TR" and l.92-94
  (the "`swap` in its name is the frame operation" justification, which must be deleted). l.168 and
  l.292-299 (the "temporal-duality lemma" docstring) should cite `lem:time-reflection` (needs the row) or say "the
  paper's time-reflection lemma" in plain prose. "swap-strengthened simultaneous induction" becomes
  "reflection-strengthened". Keep "`no_max` and `no_min` swap roles", which is an exchange, or reword it to "exchange".
- `Metalogic/SoundnessLemmas/FrameClassVariants.lean` (61 lines, the densest): "swap-validity",
  "swapped axioms", "temporal-duality soundness", `swap φ` notation.
- `Syntax/Formula.lean` (16 lines, including the l.706 `swap_norm` section header), `Metalogic/Soundness.lean`
  (14 lines, l.71 "temporal duality soundness", l.202), `Syntax/MinusLanguage/Formula.lean:179-190`
  (`swap(Pφ)` notation), `Syntax/StarLanguage/{Formula,Axioms}.lean`,
  `Conservativity/Plus/{Atomization,AxiomValidity,PlusSoundness}.lean`, `Conservativity/{Plus,Star}.lean`,
  `Conservativity/Star/{StarAxiomValidity,StarPasting}.lean`, `Conservativity/MinusLanguageSoundness.lean`
  (l.417-438), `Conservativity/SpCountermodel.lean:187`, `Deterministic/Soundness.lean:36-40`,
  `Semantics/Truth.lean:131` ("temporal-duality infrastructure"), `SoundnessLemmas.lean:25`,
  `Bundle/WitnessSeed.lean:168`, `Algebraic/LindenbaumQuotient.lean:336`, `Core/MCSProperties.lean:291-295`,
  `Theorems/Perpetuity.lean:54-55`, `Perpetuity/{Principles,Helpers}.lean`, `GeneralizedNecessitation.lean:116-124`,
  `ProofSystem/Derivation.lean:149`, `Syntax/PlusLanguage/Substitution.lean:40,124`,
  `Automation/FormulaEnumerator.lean:991`.
- Leave these exchange-sense "swap"s alone: `Theorems/Propositional/{Core,Connectives}.lean`, `MixedSum.lean`,
  `TemporalGate.lean`, `IntTruth.lean:801`, `DenseTruth.lean`, `Carrier.lean`, `Validity.lean:554`, `Truth.lean:228`,
  `Axioms.lean:249`, `BXCanonical/*`, `ReflexiveCanonical.lean`, `Separability.lean:300`, `DiscreteNonCompactness.lean`,
  `Decidability/Saturation.lean`, all of Kamp/EFGames/MintBound, `TableauConformance.lean`, `FormulaMutatorTest.lean`.

READMEs: `ProofSystem/README.md:72` (`⊢ swap(φ)`), `SoundnessLemmas/README.md:6,16,23`
("swap-validity"), `Bundle/README.md:47-63`, `Syntax/PlusLanguage/README.md:73`,
`Semantics/MinusLanguage/README.md:17` (cites `truth_swap`), `Automation/README.md:82`
(`swap_norm`).

Docs: `docs/development/LEAN_STYLE_GUIDE.md:923-942` (stale `φ.swap`, `swap_past_future_involution`),
`docs/development/PROPERTY_TESTING_GUIDE.md:639-642`, `docs/user-guide/examples.md:424`,
`docs/user-guide/architecture.md:53`, `docs/development/CONTRIBUTING.md:166` (example branch name,
optional). Keep `docs/project-info/performance-targets.md:48,60` and the
`"Temporal duality"` label in `DerivationBenchmark.lean`, which are benchmark output labels already carved out.

Tests (comments only; no identifier uses): `Tests/BimodalTest/Syntax/FormulaPropertyTest.lean:20-117`
("Temporal swap"), `Integration/ProofSystemSemanticsTest.lean:25,265` ("Temporal duality soundness"),
`Integration/COVERAGE.md:23`, `ProofSystem/DerivationTest.lean:166-172`,
`Automation/TacticsTest.lean:374`.

Typst: `typst/chapters/04-metalogic.typ:38` "*Temporal duality*: Past-future swap preserves
validity" becomes "*Time reflection*: reflecting past and future preserves validity". Nothing in typst cites a
renamed Lean identifier or either lemma label. `bimodal-notation.typ:51 #let swap` is a notation macro
name; it is optional to rename (grep its users first).

### Recommendations

Suggested three-phase plan (sorry-free by construction, since statements do not change):

1. **Identifier renames (atomic-batch; build red between files).** Use word-boundary sed over the files in
   table B. Order: `TruthNormAttr.lean` + every `simp only [swap_norm ...]` site together, then
   `Atomization.lean` → `AxiomValidity.lean`/`Plus.lean` → `CoarsenedModels.lean`, then
   `StarAxiomValidity.lean`, `Dual.lean`/`Lemma5.lean`/`TruthTransfer.lean`/`NoGaps.lean`,
   `MinusFrame.lean`/`SpCountermodel.lean`, and `DiscreteUnfolding.lean`. Restrict `e\.swap`/`F\.swap`
   seds to `Atomization.lean`, `CoarsenedModels.lean` and `SpCountermodel.lean`, because Mathlib `p.swap` (Prod)
   occurs elsewhere. Then run `lake build` (detached/guarded) and a regression grep:
   `grep -rnwE 'swapUS|truth_swap|swap_norm|MinusFrame\.swap|Encoding\.swap|[a-zA-Z_]+_swap_of_tm[a-z_]*|cValid_swap|naive_cValid_and_swap|starValid_[a-z0-9_]+_swap|swap_next_all_future_eq' FormalSystem Tests docs typst README.md --exclude-dir=Boneyard`
   must return nothing outside the record.
2. **Prose sweep.** Work through the inventory above using the same test. Where "swap" names the operation, rewrite it to use
   reflection terms. Leave exchange-sense uses. Replace every `lem:temporal-duality` and
   "temporal duality soundness" reference with the time-reflection wording.
3. **Record and gates.** Apply the record edits in A (retire the carve-out, flip the three kept
   bullets, add the table-B map, add the KNOWN-ANCHORS row(s), add the dated section). Then run
   `bash scripts/check-module-invariants.sh --emit-inventory` if README line counts moved (they will for
   `MinusFrame.lean`, `Dual.lean`, `Atomization.lean`, `CoarsenedModels.lean` and `StarAxiomValidity.lean` only if
   line counts change, which pure renames usually do not). Also run `check-paper-definitions.sh`,
   `check-module-invariants.sh`, `readme-lint.sh`, `typst-sync-check.sh` and `lake build`.

## Decisions

- `Encoding.swap` → `Encoding.reflectTime`. It denotes conjugating the encoding by time reflection,
  and it is not an exchange. Under the task's principle, `swap` cannot survive for it. `reflectTime` reads correctly in
  `atomize e φ.reflectTime = (atomize e.reflectTime φ).reflectTime`. The plan may choose
  `Encoding.conjReflect` instead, but it must not keep `swap`.
- The `starValid_*_swap` family gets the suffix form `starValid_X_reflect_time`, not
  `starValid_X_reflect_time_valid`, because `starValid` already carries "valid".
- `swap_norm` → `reflect_time_norm`, matching the `reflect_time_*` lemmas it collects.
- The whole-file pin is not re-pinned. The paper is in case (b), and the dirty-pin convention in the record forbids a
  re-pin on anything other than a drift correction.
- `lem:time-reflection` becomes LIVE-UNPINNED, not pinned. The tree paraphrases the lemma and never quotes it.
- `mirror`/`dual`/`AntiIso` names are deferred (section D). They are not `swap`, and the task scope names the
  swap families.

## Risks & Mitigations

- **simp attribute rename**: every user of the `register_simp_attr` rename must change in the same build. There are
  6 Lean files, and they are listed.
- **Unwanted sed matches**: `.swap` is Mathlib's `Prod.swap`/`Equiv.swap` in Kamp/GroupModel files. Scope the
  `e.swap`/`F.swap` edits to the three named files and use `-w`.
- **C15 red**: any new `lem:time-reflection` citation needs the KNOWN-ANCHORS row, and it must go into the same
  commit as the citation or before it. (The 608 implementation hit this and worked around it with plain prose.)
- **Dual meaning of "reflect"**: `TaskFrame.reflect` is the *reflection convention* (`def:task-relation`), and
  `MinusFrame.reflect` is the frame reversal `F⁻`. These are different namespaces and related concepts. The docstring of
  `MinusFrame.reflect` should say it is the paper's `F⁻`, so readers do not confuse the two.
- **Byte stability**: no renamed substring occurs in a string literal. The wire tags contain
  `swap`/`temporal_duality` but are kept. Verify with a grep for `"[^"]*reflect_time[^"]*"` after the edit.
- **Concurrent edits**: the working tree has unrelated modifications (`specs/state.json`, `.claude-extensions.json`).
  Stage only task-scoped files.

## Tactic Survey Results

- Not applicable (no tactic survey performed): the task is a rename with unchanged statements, so no proof goal
  is opened. Baseline gates: `check-module-invariants.sh` exits 0, and `check-paper-definitions.sh` exits 0 (case b).

## Context Extension Recommendations

- **Topic**: Naming principle for time reversal
- **Gap**: The rule "reflect for every time-order reversal, swap only for exchanges" is recorded only in the
  paper-definitions record's wave notes.
- **Recommendation**: Add a short naming rule to `docs/development/LEAN_STYLE_GUIDE.md` (and fix its stale
  `φ.swap` example in the same edit) so that future lemmas follow the convention.

## Appendix

- Searches: `grep -rnoE '\b[A-Za-z_.]*[sS]wap[A-Za-z0-9_]*'` (identifier census), declaration grep for
  `def|theorem ... swap`, `grep -w` collision checks for every proposed name, `grep -iE 'temporal[- ]duality'`
  across FormalSystem/Tests/docs/typst, and a grep of the paper for `lem:time-reflection|lem:temporal-duality`.
- C15 mechanics: `scripts/check-module-invariants.sh` l.1776-1850. It resolves citations against MANIFEST +
  KNOWN-ANCHORS in the record and excludes specs/**, Boneyard and the record itself.
