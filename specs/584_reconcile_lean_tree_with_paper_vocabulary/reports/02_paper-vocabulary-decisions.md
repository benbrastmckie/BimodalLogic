# Research Report: Task #584

**Task**: 584 - Reconcile the Lean tree with the paper's renamed vocabulary and re-pin the record
**Started**: 2026-09-17T07:49:24Z
**Completed**: 2026-09-17T08:25:00Z
**Effort**: Small-to-medium if the recommended options are chosen (about 30 prose sites for TD->TR, a 14-anchor re-hash, one anchor retirement, script skip path, one CI step). Large (1,000+ sites) only if the Lean identifiers `swapTemporal`/`temporal_duality` are also renamed.
**Dependencies**: 595 (records home) done: record now lives at `docs/reference/paper-definitions-of-record.md`. 583 (CI wiring pattern) done. 601 (reflection convention) done. 589 (basename citations) open, owns the `specs/archive/` citation fix only.
**Sources/Inputs**: - Codebase (live grep counts, Boneyard/specs/.lake/.claude excluded), `bash scripts/check-paper-definitions.sh` (live run 2026-09-17), `--resolve` mode, the live paper `possible_worlds.tex` (read-only), lean-lsp MCP (`lean_run_code` swap-image checks), prior sweep report `01_paper-vocabulary-drift.md`
**Artifacts**: - specs/584_reconcile_lean_tree_with_paper_vocabulary/reports/02_paper-vocabulary-decisions.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The ground has moved since report 01. Re-verify everything against this report, not 01.**
  The live run now reports **14** drifted anchors (not 16) plus the dangling `thm:M5-valid`.
  `def:task-relation` is no longer in the drift set.
- **Rename 1 (converse -> reflection convention) is already done.** Task 601 adopted it: the
  record entry is re-pinned, "reflection convention" has 63 hits in 19 files, `FrameOver.converse`
  has 0, and "converse convention" survives once, as archive wording in the record. **No decision
  is left here.**
- **Rename 3 (Past/Future labels) is bigger in the paper and smaller in the tree than 01 said.**
  The paper renamed all four labels: Past -> *Some Past*, Future -> *Some Future*, Historical ->
  *All Past*, Henceforth -> *All Future*. The Lean names are already `somePast`/`someFuture`/
  `allPast`/`allFuture`, so **the tree already matches the new paper vocabulary**. Only a handful
  of doc labels are stale. Recommendation: adopt (it costs almost nothing).
- **Rename 2 (TD -> TR) is the only real decision.** Exposure: bare `TD` 60 hits in 29 files (36
  in 18 Lean files), "temporal duality" 130 hits, `temporal_duality` 255, `swapTemporal` 1,032
  (80 files), `TemporalDuality` 8. "TR" and "time reflection" have 0 hits. **The paper itself keeps
  `lem:temporal-duality` as the label of its semantic lemma**, and uses `thm:TR-valid` for the
  rule's soundness. Recommendation: rename the *rule abbreviation* `TD` -> `TR` in prose (about 30
  sites). Keep `swapTemporal`, the `temporal_duality` constructor and the "temporal duality" lemma
  vocabulary, and record that as a deliberate divergence.
- **`thm:M5-valid` cannot be re-resolved. It is commented out in the paper** (`% \begin{Tthm}
  \label{thm:M5-valid}`), so `--resolve` fails. Nothing in the tree cites it. Retire it (mark it
  DANGLING, drop the manifest row) the same way the record retired nine anchors on 2026-09-07.
- **The constructor naming audit can be closed.** Every one of the Lean `BX` layer's 27 temporal and
  uniformity constructors is either a paper axiom (UE, UT, UI, UC, UF, UG, SU, CN, TS, TC, TL, NP,
  NF, NA, NB) or its exact `swapTemporal` mirror. The count gap has one cause: the paper derives the
  past halves by TR and the tree states them as primitives. The mapping table is in Findings.

## Context & Scope

This dispatch covers the decision-and-evidence phase for task 584. It re-ran the drift script,
re-counted every term against today's tree (which moved under tasks 595, 599, 601 and 602), read
each drifted anchor's word diff, audited `FormalSystem/Syntax/MinusLanguage/Axioms.lean`'s open
constructor-naming note against `FormalSystem/ProofSystem/Axioms.lean`, checked the
`DerivationTree` docstrings against the new "extends ... to include" phrasing, and read the CI
wiring convention that task 583 established. The paper is read-only input. No file outside this
report was edited.

## Findings

### Codebase Patterns

#### Live drift set (run 2026-09-17, exit 1, case (c))

Pinned sentinel: `1b3c33a2...` (paper commit `f61bbd75`). Paper repo HEAD is now `a166fcbf`
(2026-09-16), with the file dirty against it.

| Anchor | Nature of change (word diff) | Classification |
|---|---|---|
| `def:BLplus-language` | 4 label renames (Some/All Past/Future); prose of the symbol list rewritten with `\textit{}` | **Substantive (rename 3)** |
| `def:BX` | "smallest extension of CPL closed under" -> "extends CPL to include"; **`TD` -> `TR`**; new Burgess/Xu provenance footnote | **Substantive (rename 2)** + phrasing + footnote |
| `def:BX-z` | phrasing; new sentence: UZ, Z1 are the paper's own | phrasing + provenance |
| `def:BX-d` | phrasing; new sentence: DN, NN are the paper's own | phrasing + provenance |
| `def:BX-r` | phrasing; dropped "all instances of"; deleted commented-out TM^- / CO-conjecture lines | phrasing (the removed material was already commented) |
| `def:S5` | phrasing | phrasing |
| `def:TMplus` | phrasing; adds "The derivation relation ⊢_Λ ... is the smallest relation closed under the axioms and rules for Λ" | phrasing (closure condition relocated) |
| `def:BL-semantics` | **new** sentence: `\Past` and `\Future` satisfy the natural truth clauses, used freely | additive |
| `def:frame-properties` | "is Discrete, Dense, or Complete just in case its temporal order is" -> "inherits these properties from D" | reflow |
| `app:discrete`, `app:dense`, `app:complete` | dropped leading "For any temporal order D," | reflow |
| `cor:tm-completeness` | "have been" -> "are"; `\href` -> `\leanrepo{}`; **new sentence** on the Determined/⊡ extensions: sound over frames validating Determined, weakly complete over Deterministic frames | additive, backed by `detSoundness*`/`detCompleteness*` in `Metalogic/Deterministic/` |
| `def:id` | the operator-scope congruence sentence is now commented out | reflow (grep: nothing in the tree cites it) |
| `thm:M5-valid` | **whole environment commented out** | retire |

#### Rename 1: converse -> reflection convention (**already resolved**)

| Form | Count now | Report 01 count |
|---|---|---|
| "reflection convention" | 63 / 19 files | 0 |
| "converse convention" | 1 (record line 687, archive wording) | 35 |
| `FrameOver.converse` | 0 | 9 |
| `FrameOver.reflection` | 17 / 11 files | n/a |

Task 601 ("align task frame reflection convention", phases 5-7) did the adoption and re-pinned
`def:task-relation`. Nothing to decide. The implementation plan only needs a gate confirming no
regression.

#### Rename 2: metarule TD -> TR (**the one open decision**)

| Form | Count (live tree) | Kind |
|---|---|---|
| bare `TD` (rule abbreviation) | 60 hits / 29 files; 36 hits / 18 Lean files | prose, docstrings, typst, docs |
| "temporal duality" / "Temporal duality" | 89 + 41 = 130 | prose |
| `temporal_duality` | 255 / 78 files | **Lean constructor name** (`DerivationTree`, Minus/Plus/Star/Det/Co derivations) |
| `swapTemporal` | 1,032 / 80 files | **Lean function** |
| `TemporalDuality` | 8 / 4 files | `applyTemporalDuality`, `section TemporalDuality` |
| "TR", "time reflection" | 0 | none |

Paper evidence that bears on the decision:
- The rule is now `\aitem{TR}`. The paper's commented prose calls it "the time reflection
  metarule". The `def:BX` footnote calls TR Burgess's "working mirror-image convention".
- **The paper still labels its semantic lemma `lem:temporal-duality`** (live, line ~4161), and
  `thm:TR-valid` (live, resolves) proves the rule sound through that lemma. So in the paper,
  "temporal duality" names the *semantic lemma* and "TR" names the *rule*. That split is exactly
  the middle path.
- `swapTemporal` implements the paper's `φ_{⟨S|U⟩}` exactly (`untl ↔ snce`, all else
  homomorphic). The name describes the operation. It does not borrow the rule's name.

A non-TD stale item surfaced along the way: `Formula.swapTemporal`'s docstring
(`Syntax/Formula.lean:599-607`) says it swaps "`allPast φ` ↔ `allFuture φ`", which are not
constructors. It swaps `untl`/`snce`.

#### Rename 3: Past/Future labels (**near-free adoption**)

The paper's `def:BLplus-language` now reads *Some Past* `\past`, *Some Future* `\future`,
*All Past* `\Past`, *All Future* `\Future`. Report 01 missed the second pair: it said
Historical/Henceforth "keep their labels", and they no longer do.

| Form | Tree count | Note |
|---|---|---|
| Lean `somePast`/`someFuture`/`allPast`/`allFuture` | (these are the definitions in `Syntax/Formula.lean:149-179`) | **already the paper's new vocabulary** |
| "Some Past"/"Some Future"/"All Past"/"All Future" as labels | 0 | |
| "Henceforth" | 1 (a Kamp docstring, "Henceforth-past") | incidental |
| "Historical" used as the H operator's label | `docs/user-guide/quickstart.md:32` (`φ.past` "Historical"), `Syntax/Formula.lean:177` ("DSL Notation: `H φ` for Historically"), `docs/reference/operators.md:180` | the other 35 "Historical" hits are "Historical Note/Context" headings, not labels |
| `NOTATION.md` | no label hits | |

`docs/user-guide/quickstart.md:28-33` also names `φ.past`/`φ.future`, which do not exist in
`Formula`. That is stale independent of the rename. Automation identifiers
`trySwapPastHistorically`/`pastToHistoricallyAtOccurrence` (in `ContrastiveGeneratorMain.lean` and
its tests) use "Historically" as an identifier. Leave them unless the user wants the long tail.

#### `thm:M5-valid` (dangling)

`check-paper-definitions.sh --resolve "thm:M5-valid|env|-|-"` returns "could not resolve". In the
paper the theorem and its proof are fully commented out (`% \begin{Tthm} \label{thm:M5-valid}`,
around line 4145). An anchor-scoped grep outside `.lake/.git/specs/.claude/agent-system` finds the
anchor **only** in the record (header row 41, entry at line 1372, manifest line 1752), so no C15
citation depends on it. The action is **retirement**, not re-resolution: mark the entry
**DANGLING** and remove the manifest row. This follows the "Drift correction and rename absorption
(2026-09-07)" precedent, which retired nine anchors.

#### "smallest extension ... closed under" -> "extends ... to include"

- **`DerivationTree` docstrings use neither phrasing.** `ProofSystem/Derivation.lean` and the
  Minus/Plus/Star `Derivation.lean` files describe an inductive family of 7 rules. An inductive
  type *is* the least relation closed under its constructors, which is what the paper now says in
  `def:TMplus`'s new closing sentence. They need no edit.
- **Stale sites (8)**: `FormalSystem/Syntax/MinusLanguage/Axioms.lean:13-15` and 7 typst sites in
  `typst/FormalFoundations.typ` (446, 490, 498, 527, 541, 577) and `typst/chapters/03-proof-theory.typ:360`.
- `MinusLanguage/Axioms.lean:13-15` is doubly stale. It attributes to `\S sub:Logic` a "TM⁻" with
  the schemata TK/T4/TS/TC/TL and rules MP/MN/TD. But the record's "Language correspondence
  (2026-09-08)" says TM⁻ has **no paper counterpart**, and the paper's `sub:Logic` has no TK/T4 in
  BX. Line 146 repeats the attribution. This docstring should cite TM⁻ as the tree's own
  transposition and drop the paper-quoting phrasing.
- `typst/FormalFoundations.typ` is broadly stale against the paper: it uses TB/TA, `TM^+_f`,
  "smallest extension", and TD. Its remark at lines 1034-1041 claims "the development has no TD
  rule" and "the uniformity layer does not even match in count", and both claims are wrong (see
  the audit below). The typst doc belongs to the `SYNC-MAP.md` flow. Recommend that the plan treat
  it as a separate phase or a spawned follow-up, not an inline edit.

#### Constructor-by-constructor naming audit (resolves `MinusLanguage/Axioms.lean:73`)

The formulas are transcribed from `FormalSystem/ProofSystem/Axioms.lean` against the live paper's
`\aitem` list. The tree's `untl`/`snce` take the guard first and the event second, the same order
as the paper's `φ \until ψ` (verified at `Semantics/Truth.lean:202`). "Mirror" means the
constructor is the exact `swapTemporal` image of its partner. Representative pairs (UG, TC, SU,
NP, TL) were checked in Lean with `lean_run_code` by `simp [Formula.swapTemporal, ...]`, and all
passed.

| Paper key | Paper schema | Lean future/primary constructor | Lean mirror (paper derives it by TR) |
|---|---|---|---|
| TN | if ⊢φ then ⊢Gφ | `DerivationTree.temporal_necessitation` (rule) | none |
| TR | if ⊢φ then ⊢φ⟨S\|U⟩ | `DerivationTree.temporal_duality` (rule, `swapTemporal`) | none |
| TS | F⊤ | `serial_future` (⊤→F⊤) | `serial_past` |
| TC | φ → G P φ | `connect_future` | `connect_past` |
| TL | Fφ∧Fψ → F(Fφ∧ψ) ∨ F(φ∧ψ) ∨ F(φ∧Fψ) | `temp_linearity` (**disjuncts ordered F(φ∧ψ) ∨ (F(φ∧Fψ) ∨ F(Fφ∧ψ))**, which differs from the paper's order) | `temp_linearity_past` |
| UE | (φUψ) → Fψ | `until_F` | `since_P` |
| UT | Fφ → (⊤Uφ) | `F_until_equiv` | `P_since_equiv` |
| UI | φU(φ∧(φUψ)) → φUψ | `absorb_until` | `absorb_since` |
| UC | G(φ→ψ) → (χUφ → χUψ) | `right_mono_until` | `right_mono_since` |
| UF | (φUψ) → (φ∧(φUψ))Uψ | `self_accum_until` | `self_accum_since` |
| UG | G(φ→χ) → (φUψ → χUψ) | `left_mono_until_G` | `left_mono_since_H` |
| SU | θ∧(φUψ) → φU(ψ∧(φSθ)) | `enrichment_until` | `enrichment_since` |
| CN | (φUψ ∧ χUθ) → three-way disjunction | `linear_until` (left-associated `(A∨B)∨C`) | `linear_since` |
| NP | X⊤ → Y⊤ | `discrete_symm_fwd` | `discrete_symm_bwd` |
| NF | X⊤ → G X⊤ | `discrete_propagate_fwd` | none |
| NA | X⊤ → H X⊤ | `discrete_propagate_bwd` (**name suggests a mirror, but it is NA itself**) | none |
| NB | X⊤ → □X⊤ | `discrete_box_necessity` | none |

The counts reconcile. The paper has 11 non-uniformity temporal axioms, which the tree states as 11
pairs (22 constructors), plus 4 uniformity axioms, which the tree states as 5 (NP's mirror is
explicit). That is 27, the tree's "22 BX temporal + 5 uniformity". Every Lean constructor is a
paper axiom instance or a TR image of one, and TR is a Lean rule. **The two base systems therefore
derive the same theorems at the empty context, by inspection.** The "structurally finer" wording at
`MinusLanguage/Axioms.lean:73` overstates the difference, and so does typst's "conjecture" remark.
This is a textual correspondence, not a machine-checked equivalence theorem. If the user wants the
claim formally pinned, it is a small, separate Lean task (paper-keyed abbreviations plus a
`derivable_iff`).

Burgess/Xu provenance already in the tree: only `enrichment_until`/`_since` cite "Burgess A3a/A3b,
Xu (3)/(4)", and that matches the new footnote (SU = A3a). The footnote's other attributions
(TN ⊂ TG, TS No Last Element, UC/UG/SU/UF/UI = A1a/A2a/A3a/A5a/A6a, CN = A7a + Xu,
UE from UC, TC/UT/NP/NF/NA/NB original, TL ~ Xu V₃, UZ/Z1/DN/NN original) have no counterpart
in `ProofSystem/Axioms.lean` or `docs/reference/axiom-reference.md`. **Caution:** the
`linear_until` region of `Axioms.lean` carries a NOTE saying "Burgess's A7a" was *removed as
unsound under open guard*, while the paper's footnote says CN *is* A7a. When the provenance lands,
the docstring must reconcile these two claims (fixed-event vs. per-witness events) rather than
copy the footnote verbatim. That is why provenance folding fits better as its own task.

#### CI wiring (final phase)

- The convention is `docs/development/CI_CD_PROCESS.md` § "Wiring a New Check Script": a step
  `name:` containing the script path, a body of `set -euo pipefail` plus `::group::`, placement
  directly before "Report results", and a new row in the Runtime Budget table.
- The same doc already lists `check-paper-definitions.sh` as a **known non-conforming script**,
  because it exits 2 when the paper is missing.
- The required change is at `scripts/check-paper-definitions.sh:135-138` (`if [ ! -f "$PAPER" ]`).
  When the paper is absent and neither `--against` nor `--resolve` was given, print
  `SKIP (neutral): paper not found at <path>` and exit 0. A missing **record** file must stay
  exit 2, because it is a present-but-wrong repository input. The script calls no `lake`, so
  placement is unconstrained. After wiring, remove the "known non-conforming" paragraph.

### External Resources

- Live paper `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`: `\aitem{TR}`
  (around line 1241), `lem:temporal-duality` (around 4161), `thm:TR-valid` (around 4229), the
  commented `thm:M5-valid` (around 4145), `def:BLplus-language` labels (around 3092-3099).
  Line numbers are indicative only. Cite anchors.
- No Mathlib lemmas are involved. This task is vocabulary and records work only.

### Recommendations

1. **Rename 1**: no action. Add only a regression gate (`grep "converse convention"` = the 1 archive hit).
2. **Rename 2 (user decision)**: recommended option **B (prose-only)**. Rename the rule abbreviation `TD` -> `TR` at
   the approximately 29 prose files, preferring "the reflection rule **TR**" where a gloss is used.
   Keep `swapTemporal`, `temporal_duality` and "temporal duality" (the paper keeps
   `lem:temporal-duality`). Record the identifier divergence in the record's new correction
   section with that justification. Option A (full identifier rename, 1,300+ sites) is not
   recommended. Option C (keep `TD`, record a divergence) is viable but leaves paper-citing
   docstrings using a rule name the paper no longer has.
3. **Rename 3**: adopt. Fix the 3 label sites (`quickstart.md:32`, `Formula.lean:177`,
   `operators.md:180`), plus the nonexistent `φ.past`/`φ.future` in quickstart. The Lean names already match.
4. Retire `thm:M5-valid`, and re-quote and re-hash the 14 drifted anchors using their live text.
5. Fix `MinusLanguage/Axioms.lean:13-15,73,146`: replace the open audit note with the table above
   (or a pointer to it in the tree), and drop the paper attribution of TM⁻'s phrasing.
6. Fix `Formula.swapTemporal`'s docstring.
7. Re-pin the sentinels (`PINNED_COMMIT` = paper HEAD at re-pin time, `FILE_CHECKSUM`,
   `LINE_COUNT`, plus a provenance row) per the dirty-pin convention. This is a case-(c)
   correction, so a re-pin is warranted. Re-run the script **immediately** before the pin,
   because the paper moves mid-dispatch.
8. Final phase: add the skip-neutral path, the CI step, and the budget row, and delete the
   "known non-conforming" note.
9. Spawn or defer: Burgess/Xu provenance into `Axioms.lean`/`axiom-reference.md` (reconcile the
   A7a note first); typst `FormalFoundations.typ` resync; optional Lean equivalence theorem.

No sorry, axiom or proof work is involved. The zero-debt path is trivially available.

## Decisions

- Rename 1 is treated as closed (evidence: task 601 commits and the record entry at line 685).
- Rename 3 is recommended for adoption without a user question, because the tree's identifiers
  already match. It is still listed so the user sees it.
- Rename 2 is raised as `user_decision`, since the task explicitly reserves it to the user.
- `thm:M5-valid` is retired rather than re-resolved (it is commented out, not relabelled).
- The naming audit is closed as "same system, explicit mirrors" on textual evidence plus 5 Lean
  spot checks. A formal equivalence theorem is out of scope.
- Provenance folding and the typst resync are recommended as separate tasks.

## Risks & Mitigations

- **The paper moves again mid-implementation**, as it did between report 01 and now (16 -> 14
  anchors, plus new label renames). Mitigation: re-run the script at the start of each phase and
  immediately before the re-pin, and quote the live text, never this report's diffs.
- **Blind `TD` -> `TR` replacement**: `README.md:175` has `graph TD` (mermaid) and must not
  change. Some `TD` sites refer to TM⁻'s own rule (`MinusLanguage/Derivation.lean`). Those are
  Lean-only and may keep TD or follow the choice, so decide explicitly in the plan.
- **C15**: no citation of `thm:M5-valid` exists, so retirement cannot break C15's 58 citations.
  Still run `check-module-invariants.sh --no-build` after the record edit.
- **Axiom baseline**: prose and docstring edits only, so no C2 movement is expected. Verify with
  `lake build` (detached, guarded) plus full `check-module-invariants.sh`.
- **Skip path masking real failures**: a skip must fire only when the paper file is absent. A
  missing record stays exit 2.

## Tactic Survey Results
- Not applicable (no proof goals). The `lean_run_code` checks below only verified formula
  identities.

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| swapTemporal(UG instance) = left_mono_since_H instance | simp | success | [swapTemporal, allFuture, allPast, someFuture, somePast, neg, top] |
| swapTemporal(TC instance) = connect_past instance | simp | success | same |
| swapTemporal(SU instance) = enrichment_since instance | simp | success | [swapTemporal, and, neg] |
| swapTemporal(NP) = discrete_symm_bwd | simp | success | [swapTemporal] |
| swapTemporal(TL instance) = temp_linearity_past instance | simp | success | [swapTemporal, and, or, neg, someFuture, somePast, top] |

## Context Extension Recommendations
- **Topic**: paper-to-Lean axiom key correspondence
- **Gap**: The mapping lives only in a docstring table with an open audit note.
- **Recommendation**: after the plan lands, point `docs/reference/axiom-reference.md` at the
  closed table (paper key -> constructor -> mirror).

## Appendix
- Commands: `bash scripts/check-paper-definitions.sh`; `--resolve` for `thm:M5-valid`,
  `thm:TR-valid`, `lem:temporal-duality`; per-anchor `git diff --no-index --word-diff`;
  `grep -rIo` counts excluding `.lake`, `Boneyard`, `specs`, `.git`, `.claude`, `agent-system`.
- Lean: `mcp__lean-lsp__lean_run_code` (5 `simp` identities, no diagnostics).
- References: `docs/reference/paper-definitions-of-record.md` (§ Language correspondence
  2026-09-08, § Drift correction and rename absorption 2026-09-07, manifest);
  `docs/development/CI_CD_PROCESS.md` § Wiring a New Check Script; `specs/reviews/review-2026-09-16.md` H2.
