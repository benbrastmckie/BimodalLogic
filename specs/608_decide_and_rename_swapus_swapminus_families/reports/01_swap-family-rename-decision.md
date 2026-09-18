# Research Report: Task #608

**Task**: 608 - Decide and rename the swapUS / swapMinus / *_swap_valid* families
**Started**: 2026-09-18T14:13:45Z
**Completed**: 2026-09-18T14:30:00Z
**Effort**: 2-3 hours (one mechanical rename phase, one docs/record phase)
**Dependencies**: None (task 584 is archived and landed)
**Sources/Inputs**: - Codebase (grep inventory of `FormalSystem/`, `Tests/`, READMEs, `docs/`, `typst/`, `scripts/`), task 584 archive (`specs/archive/584_reconcile_lean_tree_with_paper_vocabulary/rename-map.tsv`, plan 02, summary 02), `docs/reference/paper-definitions-of-record.md` § "Drift correction and rename absorption (2026-09-17)", paper source `possible_worlds.tex` (`lem:temporal-duality`, `thm:TR-valid`)
**Artifacts**: - specs/608_decide_and_rename_swapus_swapminus_families/reports/01_swap-family-rename-decision.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Decision: a split verdict, not all-or-nothing.** Each family is judged by one test: does it
  denote the paper's time reflection `φ⟨S|U⟩` (the operation behind rule TR and `thm:TR-valid`)?
- **RENAME `swapMinus` -> `reflectTime`** (84 occurrences, 9 files). It *is* time reflection on
  L⁻: a full recursion (box included) that TM⁻'s `time_reflection` rule transforms by, and that
  `tr` intertwines with `Formula.reflectTime`. After renaming, `tr_swapMinus` becomes
  `tr_reflectTime : tr φ.reflectTime = (tr φ).reflectTime`. That matches the existing
  `ofPlus_reflectTime` / `atomize_reflectTime` pattern exactly.
- **RENAME `_swap_valid` -> `_reflect_time_valid`** (197 occurrences, 21 files). Every member
  states `Valid… φ.reflectTime` for an axiom or derivation. That is the paper's `thm:TR-valid`
  restricted to axioms. 584 already used the snake-case `swap_temporal -> reflect_time`
  convention.
- **KEEP `swapUS`** (53 occurrences, 5 files). It is *not* `reflectTime`: `.box φ` is left opaque
  on purpose, as the docstring requires. Renaming it into the reflect-time vocabulary would suggest
  it is the same operation, and a bare `reflectTime` would collide in meaning with
  `Formula.reflectTime` on the same type. Its name already spells the paper's `⟨S|U⟩`.
- **KEEP `truth_swap`** (13 occurrences, 6 files). It is the L⁻ analogue of the paper's
  `lem:temporal-duality`. 584's carve-out 2 keeps that lemma's name, and the `swap` in the name
  refers to the frame operation `MinusFrame.swap` (order reversal, the paper's `F⁻`), not to the
  formula operation.
- **No serialized strings are affected.** None of the four families appears in any string
  literal, JSON key or dataset tag. The only `swap` wire strings are the contrastive-generator
  mutation families `"modal_swap"`, `"temporal_swap"` and `"derived_swap"`. They are a different
  concept (operator mutations) and stay byte-stable. No typst, script or CI file names these
  identifiers. There are no collisions: none of the proposed new names exists today.

## Context & Scope

The TD -> TR wave of task 584 (2026-09-17) renamed `swapTemporal -> reflectTime`,
`swap_temporal -> reflect_time`, `temporal_duality -> time_reflection`, `TemporalDuality ->
TimeReflection` and `temporalDuality -> timeReflection`. It applied a token map
(`rename-map.tsv`) with an explicit exclusion list. It explicitly left `swapUS`, `swapMinus`,
`truth_swap` and `*_swap_valid*` "not in the decided set". The record
(`docs/reference/paper-definitions-of-record.md`, ~line 117) lists them as a possible follow-up.
This task makes that decision and scopes the rename. Boneyard contains **zero** occurrences of any
of the four families, and `Tests/` contains none either.

## Findings

### Codebase Patterns

**Family 1: `swapMinus`** (`FormalSystem/Syntax/MinusLanguage/Formula.lean:142`, namespace
`FormalSystem.MinusLanguage.MinusFormula`)
- Definition: `atom/bot` fixed, `imp`/`box` recursed, `allPast φ ↦ allFuture φ.swapMinus`,
  `allFuture φ ↦ allPast φ.swapMinus`. Its docstring reads: "the L⁻-side analogue of
  `Formula.reflectTime` and is what TM⁻'s TR rule ... transforms by".
- Members: `swapMinus`, `swapMinus_involution`, 9 `@[simp]` push-through lemmas
  (`swapMinus_top/neg/and/or/iff/diamond/always/someFuture/somePast`),
  `swapMinus_df_valid_of_predOrder` (`Semantics/MinusLanguage/MinusSchemaValidity.lean:155`),
  `tr_swapMinus` (`Syntax/MinusLanguage/Translation.lean:148`), plus dot-notation uses
  (`φ.swapMinus`, `MinusFormula.swapMinus`).
- Files (9): `Syntax/MinusLanguage/Formula.lean`, `Syntax/MinusLanguage/Translation.lean`,
  `Syntax/MinusLanguage/Derivation.lean`, `Syntax/MinusLanguage.lean`,
  `Semantics/MinusLanguage/MinusFrame.lean`, `Semantics/MinusLanguage/MinusSchemaValidity.lean`,
  `Metalogic/Conservativity/Backward.lean`, `Metalogic/Conservativity/MinusLanguageSoundness.lean`,
  and one README (`Semantics/MinusLanguage/README.md`).
- Code sites use dot notation or fully qualified names. A bare `reflectTime` appears only in prose,
  so defining `MinusFormula.reflectTime` introduces no elaboration ambiguity with
  `FormalSystem.Syntax.Formula.reflectTime`. No file opens both the `Formula` and `MinusFormula`
  namespaces.
- **Prose that must be reworded, not just token-replaced**: `Derivation.lean:27`
  ("**TR uses `swapMinus`, not `reflectTime`.** `reflectTime` acts on L's `untl`/`snce`") and
  `Translation.lean:26,136-145`, `Backward.lean:64-65`. After the rename these must contrast
  `MinusFormula.reflectTime` with `Formula.reflectTime`. A blind token replace would produce the
  self-contradiction "TR uses `reflectTime`, not `reflectTime`".

**Family 2: `*_swap_valid*`** (21 files; 197 occurrences)
- Every member concludes validity of `….reflectTime` (verified at `Soundness.lean:1247-1273`,
  `FrameClassVariants.lean:102`, `Plus/AxiomValidity.lean:176`, `Star/StarAxiomValidity.lean:1230`,
  `Deterministic/Soundness.lean:85`, `MinusLanguageSoundness.lean:442`).
- The variant suffixes after the substring `_swap_valid` are `(none)`, `In`, `In_min`,
  `DeterminedIn`, `_general` and `_zTimeSucc`. A single substring row `_swap_valid ->
  _reflect_time_valid` covers them all, for example `derivable_valid_and_reflect_time_validIn`,
  `axiom_reflect_time_valid_general`, `det_derivable_valid_and_reflect_time_validDeterminedIn`,
  `minus_derivable_valid_and_reflect_time_valid_zTimeSucc`.
- Every token that contains `_swap_valid` is TR-sense. There are no false positives: local
  hypotheses are named `h_swap`, `h_box_swap`, and so on, and do not contain the substring.
- READMEs that mention members: `Metalogic/README.md`, `Metalogic/SoundnessLemmas/README.md`,
  `Metalogic/Conservativity/Star/README.md`, `Syntax/PlusLanguage/README.md`,
  `Syntax/StarLanguage/README.md`.

**Family 3: `swapUS`** (`Metalogic/WeakCanonical/DenseModelSurgery/Dual.lean:182`)
- `| .box φ => .box φ`. The box is **opaque**, and the docstring says this is "required rather than
  optional", because `TemporalTruth` reads box-subformulas as atoms through `atomMap`. This is a
  different function from `Formula.reflectTime`, which recurses into the box. It is used only
  inside `DenseModelSurgery/` (`Dual.lean`, `TruthTransfer.lean`, `NoGaps.lean`, `Lemma5.lean`),
  with 53 occurrences in total.

**Family 4: `truth_swap`** (`Semantics/MinusLanguage/MinusFrame.lean:299`)
- `MinusFrameTruth F.swap V w φ ↔ MinusFrameTruth F V w φ.swapMinus`. The lemma name follows the
  frame operation `MinusFrame.swap` (order reversal, the paper's `F⁻ = ⟨W, D, ⇒⁻⟩`). Its paper
  counterpart is `lem:temporal-duality`, which the paper and 584's carve-out 2 both keep.

**Adjacent `swap`-named TR-sense identifiers outside the named families** (recorded; see
Decisions):
- `swap_norm` simp attribute (`Automation/TruthNormAttr.lean:57`, 26 occurrences): it collects the
  eleven `Formula.reflect_time_*` lemmas.
- `plusValidIn_swap_of_tm(_deriv)`, `cValid_swap_of_tm(_deriv)`, `naiveAxiom_cValid_swap`,
  `naive_cValid_and_swap`. Here the `swap` mixes the `Encoding.swap` conjugation with the
  reflected conclusion.
- `starValid_*_swap` (10 lemmas): explicitly written mirror schemata, not `.reflectTime`
  statements.
- Prose: "swap-validity" / "Swap-validity" (about 30 occurrences in docstrings).

### External Resources

- The paper (`possible_worlds.tex`), `lem:temporal-duality` (line 4186): `M,τ,x ⊨ φ ⇔
  M⁻,τ⁻,n(x) ⊨ φ⟨S|U⟩`. This is the frame-reversal truth transfer, the counterpart of
  `truth_swap`.
- The paper, `thm:TR-valid` (line 4254): "If ⊨ φ, then ⊨ φ⟨S|U⟩". The `*_swap_valid*` family
  instantiates this per axiom, which justifies the reflect-time vocabulary.
- No Mathlib lookups were needed. The rename touches no Mathlib API.

### Recommendations

Extend 584's token-map mechanism with a new map file,
`specs/608_decide_and_rename_swapus_swapminus_families/rename-map.tsv`:

```
# old_substring	new_substring	scope/notes
swapMinus	reflectTime	all identifier tokens incl. compounds (MinusFormula.swapMinus, swapMinus_involution, swapMinus_{top,neg,and,or,iff,diamond,always,someFuture,somePast}, swapMinus_df_valid_of_predOrder, tr_swapMinus)
_swap_valid	_reflect_time_valid	all *_swap_valid* soundness lemmas (validIn, validIn_min, validDeterminedIn, valid_general, valid_zTimeSucc variants)
# EXCLUSIONS
swapUS	(kept)	box-opaque U/S exchange, not reflectTime (Dual.lean docstring: opacity is required)
truth_swap	(kept)	L⁻ analogue of lem:temporal-duality (paper keeps the name); names MinusFrame.swap
MinusFrame.swap	(kept)	frame order reversal (paper's F⁻), not a formula operation
"modal_swap"/"temporal_swap"/"derived_swap"	(kept)	contrastive mutation-family wire tags, unrelated concept
swap_norm, *_swap_of_tm*, *cValid*swap, starValid_*_swap	(kept)	out of the decided set; possible follow-up
FormalSystem/Boneyard/**	(kept)	archive (0 hits anyway)
```

Suggested phases:
1. **Identifier rename (atomic batch).** Apply the map by whole-token substitution over
   `FormalSystem/` (excluding Boneyard) and the READMEs' backticked mentions. The token regex
   should be `[A-Za-z0-9_.']+` containing the substring. Skip string literals, although none
   contain the substrings. Gates: `lake build`, the `lean_exe` roots, BimodalTest, and a residual
   grep for `swapMinus|_swap_valid` that returns empty.
2. **Prose pass (classified, never a global sed).** Reword `Derivation.lean:24-28,85`,
   `Translation.lean:26,136-145`, `Backward.lean:64-65`, `MinusFrame.lean` (lines 92, 295, 300 and
   the `truth_swap` docstring) and `MinusSchemaValidity.lean:35,146`. The contrast becomes
   `MinusFormula.reflectTime` versus `Formula.reflectTime`, the L⁻ and L time reflections. The
   "swap-validity" docstring phrasing may optionally become "reflection validity" inside renamed
   lemma docstrings.
3. **Record update.** In `docs/reference/paper-definitions-of-record.md`, replace the "Not in the
   decided set" bullet (around line 117) with the verdict: two families renamed, two kept, each
   with its reason. Also add `swapUS`'s box opacity to the `swapUS` docstring as a pointer that it
   is deliberately *not* `reflectTime`. Run `readme-lint`, `typst-sync-check` and
   `check-paper-definitions.sh`.

A sorry-free path trivially exists: this is a pure rename with no proof changes.

## Decisions

- **The split verdict** is decided by the agent, not escalated. The test "does the identifier
  denote `φ⟨S|U⟩`/TR?" is already the convention 584 applied: it renamed the metarule sense and
  kept the operator-duality and semantic-lemma senses. Applying that test mechanically settles
  each family, so no `user_decision` is raised.
- **The lemma-compound spelling for `swapMinus` follows 584 row 1 mechanically.** The camelCase
  `swapMinus_neg` becomes `reflectTime_neg`, just as `swapTemporal_injective` became
  `reflectTime_injective`. It does not become `reflect_time_neg`. This keeps the map a pure
  substring rule. The Formula-side `reflect_time_*` names came from the snake-case
  `swap_temporal_*` originals, so the difference in spelling is inherited, not new.
- **The `_swap_valid` component becomes `_reflect_time_valid`, not `_reflect_valid`**, matching
  584's `swap_temporal -> reflect_time` snake-case component.
- **Adjacent families (`swap_norm`, `*_swap_of_tm*`, `starValid_*_swap`, the `cValid` swaps) are
  out of scope.** They are not named by the task, and several mix the `Encoding.swap` conjugation
  or write their mirror schemata out explicitly, so each would need its own classification. They
  are recorded as a possible follow-up.

## Risks & Mitigations

- **Blind replacement creates self-contradictory prose** (`Derivation.lean:27`). Mitigation:
  phase 2 is a classified prose pass, as in 584 phase 3.
- **Ambiguity between `MinusFormula.reflectTime` and `Formula.reflectTime`.** This is low risk:
  every code site uses dot notation or a qualified name, and no file opens both namespaces.
  Mitigation: `lake build` is the gate.
- **Overlap with concurrent tasks' commits** (584's handoff noted docs renames swept into other
  tasks' commits). Mitigation: stage by explicit file list only.
- **Long names** (`minus_derivable_valid_and_reflect_time_valid_zTimeSucc`, 55 characters) could
  exceed the 100-character line limit at call sites. Mitigation: run the line-length lint after
  phase 1 and rewrap as needed.

## Tactic Survey Results

- Not applicable (no tactic survey performed): this is a pure identifier rename with no proof
  obligations.

## Context Extension Recommendations

- **Topic**: identifier-rename token-map mechanics (as used in 584 and here)
- **Gap**: the procedure (map TSV, whole-token substitution, string-literal skip, classified
  prose ledger) is recorded only in archived task artifacts
- **Recommendation**: a short `context/project/lean4/operations/identifier-rename.md` in the
  source store (`agent-system/extensions/lean/...`)

## Appendix

- Inventory commands: `grep -rho --include=*.lean -E "[A-Za-z0-9_.']*<fam>[A-Za-z0-9_']*"` over
  git-tracked `FormalSystem`/`Tests` files excluding Boneyard. For non-Lean files, `git ls-files |
  grep -v specs/Boneyard/.claude/agent-system | xargs grep`.
- Collision check: `grep -E "reflectTime_(involution|neg|...|df_valid)|tr_reflectTime|_reflect_time_valid"`
  returned empty.
- String-literal check: the only `"…swap…"` literals are in `ContrastiveGeneratorMain.lean:769-1014`
  (mutation families).
