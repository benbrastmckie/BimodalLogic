# Research Report: Task #872

**Task**: 872 - Open language transfer ledger
**Started**: 2026-11-05T17:42:28Z
**Completed**: 2026-11-05T17:52:00Z
**Effort**: ~1 dispatch, read-only
**Dependencies**: None
**Sources/Inputs**:
- `FormalSystem/PlusLanguage/` (18 files), `FormalSystem/OpenLanguage/` (10 files)
- `docs/theorem-index.md`, `FormalSystem/Metalogic/README.md`, `FormalSystem/OpenLanguage/README.md`,
  `FormalSystem/PlusLanguage/README.md`, `FormalSystem/Metalogic/Independence/README.md`,
  `FormalSystem/Metalogic/Expressiveness/README.md`
- `FormalSystem/Metalogic/Conservativity/Open/`, `Conservativity/Plus/`, `Deterministic/`,
  `Independence/`, `Expressiveness/OpenFutureElimination.lean`
- `specs/TODO.md`, `specs/856_*/plans/01_*.md` (phase status table)
- lean-lsp MCP (`lean_local_search`) — **degraded, see Evidence Tier below**
**Artifacts**: - `specs/872_open_language_transfer_ledger/reports/01_open-language-transfer-ledger.md`
**Standards**: report-format.md, subagent-return.md
**Task Type**: formal
**Domains**: logic (primary — modal/temporal object languages, proof systems, conservativity,
definability), math (secondary — the product decomposition of the stability class, order-theoretic
limit arguments)
**Tree state**: `git rev-parse --short HEAD` = `4c52993c1`

---

## Executive Summary

- **The transfer is well advanced at the syntax and semantics layers and barely started at the
  metalogic layer.** Of **64** ledger rows: **23 TRANSFERRED**, **10 REDUCIBLE**, **24 OWED**,
  **7 NOT APPLICABLE** — so 33 of the 57 applicable rows (58%) are either landed or one named
  theorem away. Eleven of the 24 OWED rows are already owned by a filed task; the **13 with no
  owner** are concentrated in two places: the state-locality fragment and the semantics-layer L⁺
  support lemmas.
- **The dispatch's expected reduction vehicle is the wrong one for most rows, and a better one is
  already landed.** `openValidIn_ofPlus_iff` / `openValid_ofPlus_iff` (semantic conservativity of
  L^▷ over L⁺) and `plusDerivable_openDerivable_iff` (proof-theoretic conservativity, both
  directions) are **unconditional and generic in the frame class** (`{fc : FrameClass}`). They
  reduce every L⁺ *result about an L⁺ formula* to its L^▷ reading at Base, Dense, ZTime and RTime
  alike. The ZTime/RTime translation equivalences (`openValidIn_ztime_iff_tr`,
  `openValidIn_rtime_iff_tr`) are needed only in the *opposite* direction — carrying a fact about
  genuinely open-modal formulas back to L⁺ — and they carry the `SeparationOver` hypothesis. Both
  vehicles are named per row below.
- **Eight L⁺ files have no `OpenLanguage/` counterpart.** Two are owned (`Subformulas.lean` →
  task 873, `Substitution.lean` → task 874). Four are internal infrastructure that correctly has
  no L^▷ reading (`PlusOmegaChain.lean`, `PlusLimitClosure.lean`'s Zorn layer,
  `PlusRayFibre.lean`'s path-space layer, `PlusNonValidities.lean`'s frame constructions). Two are
  **wanted and unowned**: `PlusStateLocal.lean` and `PlusIntTransfer.lean`.
- **The direct embedding of L into L^▷ exists nowhere — not as a single map and not even as a
  composition.** `OpenLanguage.ofPlus ∘ PlusLanguage.ofFormula` occurs **zero times** in the tree.
  (The nine `ofPlus (ofFormula φ)` hits in `StarLanguage/` and `Conservativity/Star/` are
  `StarLanguage.ofPlus`, a different map into L⋆.) Task 874 names this as a sub-deliverable
  ("whatever direct embedding `Formula -> OpenFormula`"), which under-states it: five separate
  ledger rows depend on it.
- **There are three unformalized hypotheses carrying L^▷ results, not two.** The dispatch named
  `SeparationOver` and the `DeltaProp` inexpressibility. The third is **`hmarkers`**, the
  enough-worlds condition on the witness frame of
  `ofut_not_plusDefinable_of_deltaProp_inexpressible` — true at `colourFibre D` for every `D`, but
  the module *states* that rather than compiling it, so it remains a hypothesis of the reduction
  theorem. No `axiom` declaration exists anywhere in `FormalSystem/`; these three are the complete
  set.
- **`FormalSystem/OpenLanguage/README.md` is now factually wrong in its headline claim.** It states
  "L^▷ is **semantic only**: it has no proof system", and its generated inventory lists six files.
  The directory now holds nine `.lean` files including `OpenAxioms.lean` (71 `OpenAxiom`
  constructors), `OpenDerivation.lean` (`OpenDerivable`, 7 rules) and `OpenErasure.lean`
  (`plusDerivable_openDerivable_iff`). This is task 856's phase 15 ("ledger surfaces") and is
  owned, but it is the single most misleading surface in the tree right now.
- **Four rows are blocked on open mathematics, not on unwritten Lean** and belong to the
  completeness and decidability programmes: TM⁺ completeness at any class, TM⁺ decidability, the
  35-row ZTime certificate front, and the `hinexpr` collapse argument. They are flagged in-row.

---

## Context & Scope

The end state is that the repository present two object languages, L and L^▷, with L⁺ surviving as
an internal layer rather than a front. The standing architectural ruling keeps L⁺ embedded and
forbids renaming or mutating `PlusFormula` / `PlusAxiom` / `PlusDerivationTree`, so the end state
is reached by making every L⁺ headline result readable at L^▷ through `ofPlus` and the
conservativity directions — not by deleting anything. This report is the ledger that makes
"everything for L⁺ has been transferred to L^▷" a measurable condition.

Nothing under `FormalSystem/` was edited. No Lean declaration was added. No completeness or
decidability claim is made. No rename, mutation or deletion is proposed.

### Evidence Tier — announced, per the dispatch's lean-readiness contract

`lean_local_search` returned `index: "warming"`. Under the dispatch's own interpretation rule,
an empty LSP result in that state is **not** proof of absence. **Every negative existence claim in
this report therefore rests on a recorded `grep` over `FormalSystem/**/*.lean`, not on the LSP
index.** The greps are reproduced verbatim in the Verification Commands section. This is a
degraded-but-adequate tier for existence questions over a tree whose declarations are all written
as literal `theorem`/`def`/`lemma` headers (no name-generating macros in either language
directory, confirmed by the per-file declaration sweep).

---

## Domain Analysis

Routed as **logic-primary** with a **math-secondary** cross-reference, and researched directly
rather than by sub-dispatch, because the question is a surface inventory over two object languages
in one repository rather than a literature question in either domain.

- **Logic** (primary): the ledger's subject matter is two modal/temporal object languages, their
  axiom inductives, derivation trees, truth recursions, validity predicates, conservativity
  directions, definability and non-definability results, and incompleteness. Every status
  assignment turns on a logic-domain distinction — most sharply the distinction between
  *conservativity* (unconditional, class-generic, in the `ofPlus` direction) and *translation*
  (conditional on separation, ZTime/RTime only, in the eliminating direction). Getting that
  backwards is what would make the ledger wrong.
- **Math** (secondary): three rows rest on non-logical mathematics and were cross-checked against
  it. `PlusRayFibre.lean` presents `⊡` as a quantifier over a **product of two path spaces** via
  `Presheaf.seamFibreEquiv`; its L^▷ counterpart `stab_iff_ofut_opast` is the same product
  decomposition read at the operator level, with `▷` and `◁` as the two projections — which is why
  that row is TRANSFERRED despite sharing no declaration name. `PlusLimitClosure.lean` rests on
  Zorn (`PartialHistory.exists_maximal_of_chainClosed`) and `PlusOmegaChain.lean` on cofinality in
  a preorder; both are frame-level order theory, which is why those rows are NOT APPLICABLE rather
  than OWED.
- **Physics**: not relevant. No dynamical-systems, ergodic or fixed-point content in scope.

---

## How the L⁺ surface was enumerated

Three sources, with counts recorded and per-row provenance marked in the ledger's **Src** column
(**A** = per-file declaration lists, **B** = `docs/theorem-index.md`, **C** =
`FormalSystem/Metalogic/README.md`).

### Source A — per-file declaration lists under `FormalSystem/PlusLanguage/`

18 files (17 `.lean` + `README.md`), **268 declarations**. Per-file counts:

| File | Decls | | File | Decls |
|---|---:|---|---|---:|
| `Axioms.lean` | 2 | | `PlusPasting.lean` | 29 |
| `Derivation.lean` | 18 | | `PlusRayFibre.lean` | 11 |
| `Formula.lean` | 61 | | `PlusReversal.lean` | 6 |
| `PlusDeterminism.lean` | 4 | | `PlusStateLocal.lean` | 15 |
| `PlusIntTransfer.lean` | 3 | | `PlusTruth.lean` | 29 |
| `PlusLCSchema.lean` | 9 | | `PlusValidity.lean` | 19 |
| `PlusLimitClosure.lean` | 8 | | `Subformulas.lean` | 27 |
| `PlusNonValidities.lean` | 8 | | `Substitution.lean` | 9 |
| `PlusOmegaChain.lean` | 10 | | **total** | **268** |

The L^▷ side, for comparison: 10 files (9 `.lean` + `README.md`), **195 declarations** —
`Formula.lean` 26, `OpenAxioms.lean` 6, `OpenClasses.lean` 16, `OpenDerivation.lean` 25,
`OpenErasure.lean` 25, `OpenOckhamist.lean` 35, `OpenReversal.lean` 6, `OpenTruth.lean` 29,
`OpenValidity.lean` 27.

Inductive sizes: `PlusAxiom` **53** constructors vs `OpenAxiom` **71**; `PlusDerivationTree`
**7** rule constructors vs `OpenDerivationTree` **7**.

Rows sourced from A: R1–R46 (the syntax, proof-system and semantics layers).

### Source B — the L⁺ rows of `docs/theorem-index.md`

442 table rows total. **17** cite a `FormalSystem.PlusLanguage.*` declaration by name;
**43** mention `L⁺` in their claim text. The 17 named-declaration rows are:
`plusValidZTime_iff_plusValidInt`, `box_global`, `isPlusStateLocal_of_stateLocal`,
`plusStateLocal_plusValid_iff_stab`, `marker_mono`, `marker_agree_add`, `omega_limit`,
`int_marker_add_le`, `intOrder_omega_cofinal`, `int_marker_exists_gt`, `stg_step`, `omega_chain`,
`gle_iff`, `bigAnd_iff`, `lcN_plusValidInt`, `lcN_plusValidZTime`, `plusValidIn_ofFormula_iff`.

The 26 further L⁺-mentioning rows that cite a declaration **outside** `PlusLanguage/` are the
reason source B matters: they are L⁺ headline results that source A cannot see. They contributed
rows **R47–R54** (`FormalSystem.Semantics.HistMorphism.plus_invariance`,
`HistMorphism.plusValidOn`, `TwoWayBounded.plus_invariance_of_isZTime`,
`Metalogic.NamingRules.plusTruthAt_congr_of_fresh`, `Semantics.plusValidIn_iff_recurrenceFree`,
`Semantics.stateLocal_ofPlus_iff`, `HybridLanguage.regFree_invariance`, and the 35-row
`Metalogic.Decidability.Plus*` certificate front).

For comparison, the L^▷ side holds **15** rows citing an `OpenLanguage`/Open-metalogic declaration
and **1** row whose claim text uses the `L^▷` glyph.

### Source C — the L⁺ entries of `FormalSystem/Metalogic/README.md`'s result table

The section *The TM⁺ metatheory rows — `Conservativity/Plus/`, `Deterministic/`, `Independence/`*
carries a 12-line table = **10 content rows**. All ten are in the ledger, as **R47–R56**. Verbatim,
with the README's own status verdicts:

| # | README row | README status |
|---|---|---|
| 1 | soundness at all four classes | landed |
| 2 | conservativity over TM, both directions, all four classes | landed |
| 3 | completeness of TM⁺ + *Determined* over the deterministic frames, all four classes | landed |
| 4 | the logic of the deterministic frames = the logic of the *Determined*-valid frames | landed |
| 5 | the logic of the deterministic frames = the logic of all task frames (for L, at every class) | landed |
| 6 | `⊡` is not definable in L | landed |
| 7 | the two pasting schemata are not derivable from the naive `⊡`-set | landed |
| 8 | completeness of the current TM⁺ axiom set at `.Base` | **FALSE** |
| 9 | completeness of any extension of the TM⁺ axiom set, at any class | **OPEN** |
| 10 | TM⁺ decidability | **OPEN** |

---

## The Transfer Ledger

Status values, as the dispatch fixes them:

- **TRANSFERRED** — a named L^▷ declaration exists.
- **REDUCIBLE** — no L^▷ declaration, but the result is reachable at a **stated frame class**
  through a **named** landed translation or conservativity theorem. Every REDUCIBLE row below
  names both.
- **OWED** — no counterpart and no reduction; the owning task is named, or its absence is stated.
- **NOT APPLICABLE** — about L⁺-specific syntax or frame-level infrastructure, with no L^▷ reading;
  the reason is given in one clause.

The two reduction vehicles, stated once so the rows can cite them by name:

- **(V1) `openValidIn_ofPlus_iff`** (`OpenLanguage/OpenValidity.lean:165`), with
  `openValidOn_ofPlus_iff`, `openValidOnFrames_ofPlus_iff`, `openValid_ofPlus_iff` and the
  truth-level `openTruthAt_ofPlus` (`OpenTruth.lean`). Signature
  `(fc : ProofSystem.FrameClass) (φ : PlusFormula) : OpenValidIn fc (ofPlus φ) ↔ PlusValidIn fc φ`
  — **unconditional, at every frame class (Base, Dense, ZTime, RTime).**
- **(V2) `plusDerivable_openDerivable_iff`** (`OpenLanguage/OpenErasure.lean:466`), with
  `openDerivable_of_plusDerivable` (`OpenDerivation.lean:352`) and
  `plusDerivable_of_openDerivable` (`OpenErasure.lean:458`). Signature
  `{fc : FrameClass} (φ : PlusFormula) : OpenDerivable fc [] (ofPlus φ) ↔ PlusDerivable fc [] φ`
  — **unconditional, at every frame class.**
- **(V3) `openValidIn_ztime_iff_tr` / `openValidIn_rtime_iff_tr`**
  (`Metalogic/Expressiveness/OpenFutureElimination.lean:421,432`) — the translation equivalences,
  at **ZTime** and **RTime only**, each **conditional on `SeparationOver`** (an unformalized
  hypothesis). They do **not** apply at Base or Dense. Used below only where the result concerns
  genuinely open-modal formulas.

### Layer 1 — syntax

| # | Src | L⁺ declaration | L⁺ file | L^▷ counterpart | Counterpart file | Status |
|---|---|---|---|---|---|---|
| R1 | A | `FormalSystem.PlusLanguage.PlusFormula` (7 ctors) | `PlusLanguage/Formula.lean` | `FormalSystem.OpenLanguage.OpenFormula` (9 ctors) | `OpenLanguage/Formula.lean` | **TRANSFERRED** |
| R2 | A | `PlusFormula.atom_injective` | `PlusLanguage/Formula.lean` | — | — | **OWED** — no owning task; belongs with task 873's syntax pass |
| R3 | A | `PlusContext` | `PlusLanguage/Formula.lean` | `OpenContext` | `OpenLanguage/OpenDerivation.lean` | **TRANSFERRED** |
| R4 | A | the 15 shared derived operators `PlusFormula.top`/`neg`/`someFuture`/`somePast`/`allFuture`/`allPast`/`and`/`or`/`iff`/`diamond`/`always`/`sometimes`/`dstab`/`kPlus`/`kMinus` | `PlusLanguage/Formula.lean` | `OpenFormula.top`…`dstab` plus `kPlus`/`kMinus`, and the two new duals `dofut`/`dopast` | `OpenLanguage/Formula.lean`, `OpenLanguage/OpenAxioms.lean` | **TRANSFERRED** |
| R5 | A | the 8 discrete/`⊡`-indexed abbreviations `PlusFormula.next`, `prev`, `would`, `after`, `Will`, `will`, `Could`, `could` | `PlusLanguage/Formula.lean` | — | — | **OWED** — no owning task; cheap, pure notation |
| R6 | A | `PlusFormula.reflectTime`, `reflect_time_involution`, 14 `reflect_time_*` push-throughs | `PlusLanguage/Formula.lean` | `OpenFormula.reflectTime`, `reflect_time_involution`, 5 `reflect_time_*` push-throughs | `OpenLanguage/Formula.lean` | **TRANSFERRED** |
| R7 | A | `PlusFormula.IsPureFuture` / `IsPurePast` and their 10 closure lemmas | `PlusLanguage/Formula.lean` | `IsPureFutureOpen` / `IsPurePastOpen`, with `isPureFutureOpen_ofPlus`, `isPurePastOpen_ofPlus`, `isPureFuture_eraseOpen`, `isPurePast_eraseOpen` | `OpenLanguage/OpenAxioms.lean`, `OpenDerivation.lean`, `OpenErasure.lean` | **TRANSFERRED** |
| R8 | A | `ofFormula`, `ofFormula_injective`, `ofFormula_reflectTime` — **the embedding of L into L⁺** | `PlusLanguage/Formula.lean` | none; `OpenLanguage.ofPlus ∘ PlusLanguage.ofFormula` occurs **0 times** tree-wide | — | **OWED** — named only in passing by task 874; see the prose section *The direct L-to-L^▷ embedding* |
| R9 | A | `ofCtx`, `mem_ofCtx` (contexts of L into L⁺) | `PlusLanguage/Formula.lean` | `embPlus` is the L⁺→L^▷ context map, not the L→L^▷ one | `OpenLanguage/OpenDerivation.lean` | **OWED** — same owner as R8 |
| R10 | A | `PlusFormula.subformulas` + 10 membership and `subformulas_trans` lemmas | `PlusLanguage/Subformulas.lean` | — | — | **OWED** — **task 873** (Open language subformula closure) |
| R11 | A | `plusSubformulaClosure`, `self_mem_plusSubformulaClosure`, `decidableMemPlusSubformulaClosure`, 8 `plusClosure_*` | `PlusLanguage/Subformulas.lean` | — | — | **OWED** — **task 873** |
| R12 | A | `PlusFormula.BoxStabFree`, `decidableBoxStabFree`, `boxStabFree_of_mem_subformulas`, `not_box_mem_plusSubformulaClosure`, `not_stab_mem_plusSubformulaClosure` | `PlusLanguage/Subformulas.lean` | — | — | **OWED** — **task 873** |
| R13 | A | `substPlus`, `substCtxPlus`, `substPlus_atom`, `substPlus_reflectTime` | `PlusLanguage/Substitution.lean` | — | — | **OWED** — **task 874** (Open language substitution closure) |
| R14 | A | `PlusAxiom.ofTMSubst`, `PlusAxiom.minFrameClass_ofTMSubst`, `PlusDerivationTree.ofTMSubst`, `plusDerivable_substPlus`, `plusDerivable_substPlus_nil` | `PlusLanguage/Substitution.lean` | — | — | **OWED** — **task 874** |

### Layer 2 — proof system

| # | Src | L⁺ declaration | L⁺ file | L^▷ counterpart | Counterpart file | Status |
|---|---|---|---|---|---|---|
| R15 | A | `PlusAxiom` (53 ctors), `PlusAxiom.minFrameClass` | `PlusLanguage/Axioms.lean` | `OpenAxiom` (71 ctors), `OpenAxiom.minFrameClass` | `OpenLanguage/OpenAxioms.lean` | **TRANSFERRED** |
| R16 | A | `PlusDerivationTree` (7 rules), `PlusDerivationTree.lift`, `.height`, `.ofWeakeningNil`, `height_ofWeakeningNil_lt`, `mp_height_gt_left`, `mp_height_gt_right` | `PlusLanguage/Derivation.lean` | `OpenDerivationTree` (7 rules) and the same six | `OpenLanguage/OpenDerivation.lean` | **TRANSFERRED** |
| R17 | A | `PlusDerivable`, `PlusDerivable.mono` | `PlusLanguage/Derivation.lean` | `OpenDerivable`, `OpenDerivable.mono` | `OpenLanguage/OpenDerivation.lean` | **TRANSFERRED** |
| R18 | A | `stabNecessitation` | `PlusLanguage/Derivation.lean` | `stabNecessitation`, plus the two new `ofutNecessitation`, `opastNecessitation` | `OpenLanguage/OpenDerivation.lean` | **TRANSFERRED** |
| R19 | A | `PlusAxiom.ofTM`, `PlusAxiom.minFrameClass_ofTM`, `PlusDerivationTree.ofTM`, `plusDerivable_of_derivable` — **the proof embedding of TM into TM⁺** | `PlusLanguage/Derivation.lean` | `OpenAxiom.ofPlus`, `OpenAxiom.minFrameClass_ofPlus`, `OpenDerivationTree.ofPlus`, `openDerivable_of_plusDerivable` are the TM⁺→TM^▷ analogue; the direct TM→TM^▷ one is absent | `OpenLanguage/OpenDerivation.lean` | **REDUCIBLE** at **every frame class** via **(V2)** `openDerivable_of_plusDerivable` composed with `plusDerivable_of_derivable` |
| R20 | A | `plus_backward_base`, `plus_backward_dense`, `plus_backward_ztime`, `plus_backward_rtime` | `PlusLanguage/Derivation.lean` | `open_backward_base`, `open_backward_dense`, `open_backward_ztime`, `open_backward_rtime` | `OpenLanguage/OpenDerivation.lean` | **TRANSFERRED** |

### Layer 3 — semantics

| # | Src | L⁺ declaration | L⁺ file | L^▷ counterpart | Counterpart file | Status |
|---|---|---|---|---|---|---|
| R21 | A | `PlusTruthAt` and the 16 `PlusTruth.*` clause lemmas | `PlusLanguage/PlusTruth.lean` | `OpenTruthAt` (9 clauses) and the 10 `OpenTruth.*` clause lemmas | `OpenLanguage/OpenTruth.lean` | **TRANSFERRED** |
| R22 | A | `stab_of_box`, `of_stab`, `stab_four`, `stab_five` — S5 for `⊡` at truth level | `PlusLanguage/PlusTruth.lean` | `stab_of_box`, `ofut_k`, `of_ofut`, `ofut_four`, `ofut_five` and the four `opast_*` mirrors, plus `ofut_of_stab`, `opast_of_stab` | `OpenLanguage/OpenTruth.lean` | **TRANSFERRED** |
| R23 | A | `box_stab_iff`, `stab_box_of_box`, `stab_congr_state` | `PlusLanguage/PlusTruth.lean` | — | — | **REDUCIBLE** at **every frame class** via **(V1)** `openTruthAt_ofPlus` (truth-level, unconditional) |
| R24 | A, B | `stab_state_only`, `box_time_invariant`, `box_global` | `PlusLanguage/PlusTruth.lean` | — | — | **REDUCIBLE** at **every frame class** via **(V1)** `openTruthAt_ofPlus`, **for the `ofPlus` image only**. There is no L^▷-wide analogue and there cannot be: `▷`/`◁` are provably not state-local (`ofut_pastDet`, `opast_futDet`, `not_openValid_stab_of_ofut`) |
| R25 | A | `truth_congr_ext` | `PlusLanguage/PlusTruth.lean` | `openTruthAt_congr_ext` | `Metalogic/Conservativity/Open/OpenAxiomValidity.lean` | **TRANSFERRED** |
| R26 | A | `plusTruthAt_timeShift` | `PlusLanguage/PlusTruth.lean` | `openTruthAt_timeShift` | `Metalogic/Conservativity/Open/OpenAxiomValidity.lean` | **TRANSFERRED** |
| R27 | A | `Semantics.TaskFrame.PlusValidOn`, `PlusValidOnFrames`, `PlusValidIn`, `PlusValid`, with `.mono`, `of_forall`, `of_forall_regular`, `apply` | `PlusLanguage/PlusValidity.lean` | `Semantics.TaskFrame.OpenValidOn`, `OpenValidOnFrames`, `OpenValidIn`, `OpenValid`, the same four, plus `OpenValid.of_not` | `OpenLanguage/OpenValidity.lean` | **TRANSFERRED** |
| R28 | A | `PlusValidDense`, `PlusValidZTime`, `PlusValidRTime` — the per-class abbreviations | `PlusLanguage/PlusValidity.lean` | — (`OpenValidDense`/`OpenValidZTime`/`OpenValidRTime` all absent) | — | **OWED** — no owning task; pure notation, but the ZTime/RTime translation rows read awkwardly without it |
| R29 | A, B | `plusTruthAt_ofFormula`, `plusTruthAt_ofCtx`, `plusValidOnFrames_ofFormula_iff`, `plusValidIn_ofFormula_iff`, `plusValid_ofFormula_iff` — **semantic conservativity of L⁺ over L** | `PlusLanguage/PlusValidity.lean` | `openTruthAt_ofPlus`, `openValidOn_ofPlus_iff`, `openValidOnFrames_ofPlus_iff`, `openValidIn_ofPlus_iff`, `openValid_ofPlus_iff` are the L^▷-over-**L⁺** row; the L^▷-over-**L** row is absent | `OpenLanguage/OpenTruth.lean`, `OpenValidity.lean` | **REDUCIBLE** at **every frame class** by composing **(V1)** with `plusValidIn_ofFormula_iff`; blocked as a *stated* row on R8 |
| R30 | A | `after_negation_stable_dstab`, `after_negation_stable_stab` | `PlusLanguage/PlusValidity.lean` | — | — | **REDUCIBLE** at **every frame class** via **(V1)** `openValidIn_ofPlus_iff` |
| R31 | A | `plusTruthAt_rev`, `plusValidOn_rev_iff`, `plusValid_reflectTime` — `lem:time-reflection` at L⁺ | `PlusLanguage/PlusReversal.lean` | `openTruthAt_rev`, `openValidOn_rev_iff`, `openValid_reflectTime`, with the class swaps `agreeUpTo_rev_iff`, `agreeFrom_rev_iff`, `image_rev_stabClass` | `OpenLanguage/OpenReversal.lean` | **TRANSFERRED** |
| R32 | A | `plusValidOnFrames_reflectTime`, `plusValidIn_reflectTime`, `plusValidIn_reflectTime_iff` — the frame-class-level reflection rows | `PlusLanguage/PlusReversal.lean` | — (`openValidOnFrames_reflectTime`, `openValidIn_reflectTime` both absent) | — | **OWED** — no owning task; `OpenReversal.lean` stops at `openValid_reflectTime` |
| R33 | A | `pasteFun`, `paste`, `pasteAt`, `paste_rel`, `paste_rel_le_lt`, `pasteAt_states_le`, `pasteAt_states_not_le`, `isTotal_pasteAt`, `paste_eq_pasteAt` | `PlusLanguage/PlusPasting.lean` | consumed unchanged by `paste_mem_openFutureClass_inter_openPastClass` and by `ofut_opast_to_stab` | `OpenLanguage/OpenClasses.lean`, `OpenTruth.lean` | **NOT APPLICABLE** — frame/history constructions, language-independent, so no L^▷ restatement is meaningful |
| R34 | A | `AgreeFrom`, `AgreeUpTo`, `agreeFrom_mono`, `agreeUpTo_mono`, `paste_agreeFrom`, `paste_agreeUpTo` | `PlusLanguage/PlusPasting.lean` | lifted into the two restricted-modal classes: `openFutureClass`, `openPastClass`, `agreeUpTo_equivalence`, `agreeFrom_equivalence`, `openFutureClass_subset_stabClass`, `openPastClass_subset_stabClass`, `openFutureClass_inter_openPastClass`, `openFutureClass_anti`, `openPastClass_mono` | `OpenLanguage/OpenClasses.lean` | **TRANSFERRED** |
| R35 | A | `truth_congr_agreeFrom`, `truth_congr_agreeUpTo` | `PlusLanguage/PlusPasting.lean` | `openTruthAt_congr_agreeFrom`, `openTruthAt_congr_agreeUpTo` | `Metalogic/Conservativity/Open/OpenAxiomValidity.lean` | **TRANSFERRED** |
| R36 | A | the pasting validities `paste_valid`, `paste_valid'`, `paste_plusValid`, `paste'_plusValid`, `untl_paste_starValid`, `snce_paste_plusValid` (PS/US and mirrors) | `PlusLanguage/PlusPasting.lean` | the constructors `OpenAxiom.paste`, `OpenAxiom.untl_paste` exist; their validity block does not | `OpenLanguage/OpenAxioms.lean` | **OWED** — **task 856 phase 10** (`[NOT STARTED]`: "validity block — discrete, Prior, Dedekind, `⊡` and pasting") |
| R37 | A | `future_dstab_valid`, `stab_allFuture_valid`, `untl_dstab_valid`, `snce_dstab_valid`, `future_dstab_plusValid`, `stab_allFuture_plusValid` | `PlusLanguage/PlusPasting.lean` | — | — | **OWED** — **task 856 phase 10** |
| R38 | A | `refute_stab_box`, `refute_allFuture_stab`, `refute_stab_allFuture_past`, `refute_determined`, `refute_somePast_stab` — the five refutations bounding the `⊡` axiom set from above | `PlusLanguage/PlusNonValidities.lean` | `not_openValid_stab_box`, `not_openValid_allFuture_stab`, `not_openValid_stab_allFuture_past`, `not_openValid_determined`, `not_openValid_somePast_stab` | `OpenLanguage/OpenOckhamist.lean` | **TRANSFERRED** |
| R39 | A | `NF`, `natHist`, `natModel` — the permissive ℤ countermodel | `PlusLanguage/PlusNonValidities.lean` | reused unchanged by `OpenOckhamist.lean`'s converse-failure block | `PlusLanguage/PlusNonValidities.lean` | **NOT APPLICABLE** — a frame/model construction, not a statement in either language |
| R40 | A, C | `states_eq_of_deterministic`, `stab_iff_of_deterministic`, `determined_of_deterministic`, `stab_biconditional_plusValidOn_of_deterministic` — `app:deterministic`'s positive half | `PlusLanguage/PlusDeterminism.lean` | `openTruthAt_eraseOpen_of_deterministic`, `openTruthAt_erasePlus_eraseOpen_of_deterministic`, `OpenValidDetIn`, `openValidDetIn_iff_plusValidDetIn_eraseOpen`, `openValidDetIn_iff_validDetIn_erasePlus_eraseOpen` | `Metalogic/Deterministic/OpenCollapse.lean` | **TRANSFERRED** — as a collapse theorem rather than per-lemma; the shape differs, the content is the L^▷ reading |
| R41 | A, B | `PlusFormula.StateLocal`, `StateLocal.neg/and/or`, `IsPlusStateLocal`, `isPlusStateLocal_box`, `isPlusStateLocal_stab`, `isPlusStateLocal_of_stateLocal`, `not_isPlusStateLocal_someFuture`, `not_isPlusStateLocal_somePast`, `plusStateLocal_stab_iff`, `plusStateLocal_plusValid_iff_stab`, `stab_of_stateLocal` — **the state-locality fragment** | `PlusLanguage/PlusStateLocal.lean` | — (`openStateLocal`, `IsOpenStateLocal`, `StateLocalOpen` all absent) | — | **OWED** — **no owning task.** The highest-value unowned row; see Recommendations T1 |
| R42 | A, B | `plusTruthAt_map`, `PlusValidInt`, `plusValidZTime_iff_plusValidInt` — carrier normalization for L⁺ | `PlusLanguage/PlusIntTransfer.lean` | — | — | **REDUCIBLE** at **ZTime** via **(V3)** `openValidIn_ztime_iff_tr` composed with `plusValidZTime_iff_plusValidInt` — **conditional on `SeparationOver TaskFrame.IsZTime`**. The `ofPlus` image alone is reducible unconditionally at every class via **(V1)** |
| R43 | A, B | `plusStab_iff_rays`, `plusStab_iff_omega` — `⊡` as a quantifier over a product of two path spaces | `PlusLanguage/PlusRayFibre.lean` | `stab_to_ofut_opast`, `ofut_opast_to_stab`, `stab_iff_ofut_opast`, `stab_iff_opast_ofut`, with `openValid_stab_imp_ofut_opast`, `openValid_ofut_opast_imp_stab` | `OpenLanguage/OpenTruth.lean`, `OpenValidity.lean` | **TRANSFERRED** — the same product decomposition read at the operator level, with `▷` and `◁` as the two projections |
| R44 | A | `BwdSeq`, `FwdSeq`, `SeqPair`, `ZPathFibre`, `pathFibreEquiv`, `splice`, `splice_isStepPath`, `omegaSplitEquiv`, `seamOmegaEquiv` | `PlusLanguage/PlusRayFibre.lean` | — | — | **NOT APPLICABLE** — path-space/presheaf infrastructure for the ℤ-time decidability front; the objects are frame-level, not language-level |
| R45 | A, B | `marker_mono`, `marker_agree_add`, `omega_limit`, `int_marker_add_le`, `intOrder_omega_cofinal`, `int_marker_exists_gt`, `Stg`, `stg_step`, `omega_chain` | `PlusLanguage/PlusOmegaChain.lean` | — | — | **NOT APPLICABLE** — these statements quantify over histories, times and world states, never over formulas of either language (confirmed from the theorem-index claim text for `marker_mono` and `omega_chain`); they are splice/ω-limit infrastructure for the limit-closure countermodel |
| R46 | A | `PartialHistory.exists_maximal_of_chainClosed`, `restrictIic`, `LCProp`, `lcProp_restrictIic`, `lcProp_chainSup`, `limit_history` | `PlusLanguage/PlusLimitClosure.lean` | — | — | **NOT APPLICABLE** — Zorn-style history-construction infrastructure, frame-level |
| R47 | A, C | `blc`, `blc_plusValid` — the limit-closure formula and its Base validity | `PlusLanguage/PlusLimitClosure.lean` | — | — | **REDUCIBLE** at **every frame class** via **(V1)** `openValidIn_ofPlus_iff` on `ofPlus (blc p)`; **task 875** owns stating it ("the `ofPlus`-image of the limit-closure countermodel formula is Base-valid and not L^▷-derivable") |
| R48 | A, B | `PlusFormula.gle`, `gle_iff`, `bigAnd`, `bigAnd_iff`, `lcAnte`, `lcCons`, `lcN`, `lcN_plusValidInt`, `lcN_plusValidZTime` — Reynolds's `LC_n` schema at `⊡` | `PlusLanguage/PlusLCSchema.lean` | — | — | **REDUCIBLE** at **every frame class** via **(V1)** for the `ofPlus` image; **task 875** owns the L^▷ `LC_n` statement. **Note**: task 871 (`[NOT STARTED]`) corrects this file's docstring and restores `omega_chain`'s segment-property parameter, and is a prerequisite |

### Layer 4 — metalogic (source C's ten rows, plus the L⁺ results living outside `PlusLanguage/`)

| # | Src | L⁺ declaration | L⁺ file | L^▷ counterpart | Counterpart file | Status |
|---|---|---|---|---|---|---|
| R49 | C | **TM⁺ soundness at all four classes** — `plus_derivable_valid_and_reflect_time_validIn`, `plus_soundness_validIn`, `plus_soundness_in`, `plus_soundness_valid`, `plus_soundness_base/dense/ztime/rtime`, `plus_not_derivable_nil_bot` | `Metalogic/Conservativity/Plus/PlusSoundness.lean` | the per-axiom validity blocks are landed (`openAxiomValidIn_propBlock`, `modalBlock`, `tempMonoBlock`, `tempAccumBlock`, `linearityBlock`, `tempEquivBlock`, `ofutBlock`, `rigidityBlock`, and each `*_reflect` twin); the soundness recursion is not | `Metalogic/Conservativity/Open/OpenAxiomValidity.lean` | **OWED** — **task 856 phase 12** (`OpenSoundness.lean`, `[NOT STARTED]`), gated on phases 10–11 |
| R50 | C | **TM⁺ conservativity over TM, both directions, all four classes** — `forward_plus`, `forward_plus_base/dense/ztime/rtime`, `plusDerivable_ofFormula_iff` and its four class instances, `plus_of_tmMinus` + four, `tmFrag_iff_plus`, and `Corollaries.lean`'s `tmFragIffPlus*` | `Metalogic/Conservativity/Plus/Forward.lean`, `Corollaries.lean` | — | — | **OWED** — **task 856 phase 13** (`Forward.lean` — conservativity over TM and the TM⁺ row, `[NOT STARTED]`) |
| R51 | C | **completeness of TM⁺ + *Determined* over the deterministic frames, all four classes** — `detCompletenessBase/Dense/ZTime/RTime`, `detCompleteness`, `detDerivable_iff_derivable_erasePlus`, `detDerivable_ofFormula_iff` | `Metalogic/Deterministic/Completeness.lean` | `detDerivable_eraseOpen_of_openValidDetIn`, `validDetIn_eraseOpen_of_openValidDetIn`, `openValidDetIn_of_validDetIn_eraseOpen` | `Metalogic/Deterministic/OpenCollapse.lean` | **TRANSFERRED** — task 856 phase 14 is `[COMPLETED]`; the L^▷ deterministic-validity of `φ` is TM-derivability of its double erasure |
| R52 | C | **the logic of the deterministic frames = the logic of the *Determined*-valid frames** — `logicDeterministicEqDeterminedValid`, `detCompletenessBetween`, `logicBetweenEqDeterministic` | `Metalogic/Deterministic/Completeness.lean` | — | — | **REDUCIBLE** at **every frame class** via `openValidDetIn_iff_plusValidDetIn_eraseOpen` (`Metalogic/Deterministic/OpenCollapse.lean`, unconditional) |
| R53 | C | **the logic of the deterministic frames = the logic of all task frames (for L, at every class)** | `Metalogic/Deterministic/SameLogic.lean` | — | — | **NOT APPLICABLE** — a statement about **L**, not about L⁺-specific syntax; it is already shared by every language above L and needs no L^▷ restatement |
| R54 | C | **`⊡` is not definable in L** — `stabNotDefinable`, with `StabFam`, `sf_deterministic`, `tauOne`, `box_someFuture_false_left/right` | `Metalogic/Independence/StabUndefinable.lean` | the L^▷ analogue is "`▷` is not L⁺-definable": `ofut_not_plusDefinable_of_deltaProp_inexpressible`, with `OfutPlusDefinable`, the `MarkerGadget` block, `colourFibre`, `colourFibre_isRegular`, `ofut_pastDet`, `opast_futDet` | `Metalogic/Independence/OpenFutureUndefinable.lean` | **TRANSFERRED** — but **conditional on two unformalized hypotheses** (`hinexpr`, `hmarkers`); see *Unformalized hypotheses* below. The companion positive half (`openValidIn_ztime_iff_tr`, `openValidIn_rtime_iff_tr`) closes the class split at ZTime/RTime, itself conditional on `SeparationOver` |
| R55 | C | **the two pasting schemata are not derivable from the naive `⊡`-set** — `pasteNotNaiveDerivable`, `untlPasteNotNaiveDerivable`, `plusAxiomSetNonRedundant` | `Metalogic/Independence/PastingIndependence.lean` | — | — | **OWED** — **no owning task.** `OpenAxiom` has 71 constructors against `PlusAxiom`'s 53, and no non-redundancy result covers the 18 new ones; see Recommendations T3 |
| R56 | C | **completeness of the current TM⁺ axiom set at `.Base` is FALSE** — `plus_incomplete_base`, `not_plus_complete_base` | `Metalogic/Independence/PlusIncompleteness.lean` | — (`open_incomplete`, `openComplete` for L^▷ both absent) | — | **OWED** — **task 875** (Open language incompleteness transfer), gated on 856 and 871 |
| R57 | C | **completeness of any extension of the TM⁺ axiom set, at any class** — stated nowhere in the tree, never discharged with `sorry` | — | — | — | **OWED** — no owning task. **FLAG: blocked on open mathematics, not on unwritten Lean.** Belongs to the completeness programme |
| R58 | C | **TM⁺ decidability** — stated nowhere in the tree | — | the reductions are landed and conditional: `decidableOpenValidInOfTranslation`, `openDecider`, `openDecider_correct`, `decidableOpenValidZTimeOfTr`, `decidableOpenValidRTimeOfTr`, `openComplete_of_plusComplete_in`, `openValid_of_plusSound` | `Metalogic/Expressiveness/OpenFutureElimination.lean` | **REDUCIBLE** at **ZTime** and **RTime** via **(V3)**, **conditional on `SeparationOver`** *and* on the L⁺ antecedent. **FLAG: the antecedent is open mathematics.** Task 868 (`[COMPLETED]`) landed exactly these reductions |

### Layer 5 — L⁺ results living outside `PlusLanguage/` (source B)

| # | Src | L⁺ declaration | L⁺ file | L^▷ counterpart | Counterpart file | Status |
|---|---|---|---|---|---|---|
| R59 | B | `FormalSystem.Semantics.HistMorphism.plus_invariance`, `HistMorphism.plusValidOn`, `TwoWayBounded.plus_invariance_of_isZTime` — truth/validity invariance along a history-lifting morphism | `Semantics/HistoryMorphism.lean` | — (`open_invariance` absent) | — | **OWED** — **task 869** (Open modal invariance ray agreement lifting, `[NOT STARTED]`) |
| R60 | B | `FormalSystem.Metalogic.NamingRules.plusTruthAt_congr_of_fresh` — L⁺ truth is unchanged by a valuation change at a fresh atom | `Metalogic/NamingRules.lean` | — | — | **OWED** — **no owning task**; see Recommendations T2 |
| R61 | B | `FormalSystem.Semantics.plusValidIn_iff_recurrenceFree` — `PlusValidIn fc φ ↔ PlusValidOnFrames (… ∧ RecurrenceFree) φ` | `Semantics/Frames/TranslationProduct.lean` | — | — | **OWED** — **no owning task**; see Recommendations T2 |
| R62 | B | `FormalSystem.Semantics.stateLocal_ofPlus_iff` — the two state-locality fragments agree along `ofPlus`, as a biconditional | `Semantics/StateLocalTransfer.lean` | — (this `ofPlus` is `StarLanguage.ofPlus`, L⁺→L⋆, not `OpenLanguage.ofPlus`) | — | **OWED** — **no owning task**; pairs with R41 |
| R63 | B | `FormalSystem.HybridLanguage.regFree_invariance` — invariance for every register-free formula, so for every L⁺ formula | `HybridLanguage/HybridInvariance.lean` | — | — | **NOT APPLICABLE** — a hybrid-layer result that covers L⁺ as a sub-case; its L^▷ reading is exactly task 869's `open_invariance` (R59) and would duplicate it |
| R64 | B | the ZTime certificate front: 35 index rows under `Metalogic.Decidability.PlusSharingWitnessFamily.*` and `PlusSlicedCertificate.*` (agreement, producers, the `NoFiniteWidth` and `FiniteCarrier` incompleteness/FMP-failure results) | `Metalogic/Decidability/PlusWitnessFamily/`, `Metalogic/Decidability/` | — | — | **OWED** — no owning task. **FLAG: blocked on open mathematics, not on unwritten Lean.** This is the ZTime decidability programme; transferring it to L^▷ before the L⁺ side closes would multiply an unfinished surface |

### Tallies

64 rows in all.

| Status | Rows | Row numbers |
|---|---:|---|
| **TRANSFERRED** | 23 | R1, R3, R4, R6, R7, R15, R16, R17, R18, R20, R21, R22, R25, R26, R27, R31, R34, R35, R38, R40, R43, R51, R54 |
| **REDUCIBLE** | 10 | R19, R23, R24, R29, R30, R42, R47, R48, R52, R58 |
| **OWED** | 24 | R2, R5, R8, R9, R10, R11, R12, R13, R14, R28, R32, R36, R37, R41, R49, R50, R55, R56, R57, R59, R60, R61, R62, R64 |
| **NOT APPLICABLE** | 7 | R33, R39, R44, R45, R46, R53, R63 |

Of the 57 applicable rows (64 less the 7 NOT APPLICABLE), 33 — 58% — are TRANSFERRED or REDUCIBLE.

**The 24 OWED rows by owner.** Owned (11): task **856** — R36, R37, R49, R50; task **873** — R10,
R11, R12; task **874** — R13, R14; task **875** — R56; task **869** — R59. **No owner (13)** — R2,
R5, R8, R9, R28, R32, R41, R55, R57, R60, R61, R62, R64. R8 and R9 are counted as unowned because
task 874 names the direct embedding only in a subordinate clause and is itself downstream of its
consumers; see Recommendation T4.

---

## Findings

### Logic-domain findings

#### Which L⁺ files have no `OpenLanguage/` counterpart file, and whether one is wanted

Eight of the seventeen `PlusLanguage/*.lean` files have no counterpart file.

**Wanted, and owned:**

- `Subformulas.lean` (373 lines, 27 decls) → **task 873**. `openSubformulas`, `subformulasOpen`,
  `openSubformulaClosure` all return zero tree-wide. Task 873 additionally specifies the agreement
  lemma `subformulas_ofPlus` that makes it a transfer rather than a duplicate.
- `Substitution.lean` (233 lines, 9 decls) → **task 874**. `substOpen`, `substCtxOpen` both return
  zero tree-wide.

**Wanted, and unowned:**

- `PlusStateLocal.lean` (410 lines, 15 decls). This is the highest-value gap. The state-locality
  fragment is the decidability front's one working anchor for `⊡` (one bit per cell,
  `stab_mem_tpOf_iff_cell` resting on `stab_state_only`), and task 876's own description already
  records that removing `⊡` as a primitive would lose it. There is no L^▷ state-locality
  predicate, no `IsOpenStateLocal`, and no `▷`/`◁` row saying why they fall outside the fragment —
  even though the facts that put them outside it (`ofut_pastDet`, `opast_futDet`) are landed one
  directory over. A counterpart file is wanted and the content is largely assembled.
- `PlusIntTransfer.lean` (204 lines, 3 decls). Carrier normalization is the prerequisite any
  integer-indexed enumeration route rests on. R42 is REDUCIBLE at ZTime through the conditional
  translation, which is strictly weaker than the direct statement the L⁺ file gives. A short
  `OpenIntTransfer.lean` stating `openTruthAt_map` and an `OpenValidInt` would make the L^▷ side
  match without touching the hypothesis.

**Internal infrastructure that correctly has no L^▷ reading:**

- `PlusOmegaChain.lean` (334 lines) — the ω-limit of splices. Every statement quantifies over
  histories, times and world states; `marker_mono` is a fact about strictly increasing `ℕ`-indexed
  sequences in a preorder. Language-independent.
- `PlusLimitClosure.lean`'s Zorn layer (`exists_maximal_of_chainClosed`, `LCProp`,
  `lcProp_restrictIic`, `lcProp_chainSup`, `limit_history`). Language-independent. The file's two
  *formula*-level declarations (`blc`, `blc_plusValid`) are a separate row and **are** wanted at
  L^▷ (R47, owned by task 875).
- `PlusRayFibre.lean`'s path-space layer (`BwdSeq`, `FwdSeq`, `ZPathFibre`, `splice`,
  `omegaSplitEquiv`, `seamOmegaEquiv`). Frame-level presheaf machinery. Its *operator*-level
  consequence is already transferred (R43 — `stab_iff_ofut_opast` is the same product
  decomposition with `▷`/`◁` as the projections).
- `PlusNonValidities.lean`'s frame constructions (`NF`, `natHist`, `natModel`) — reused unchanged
  by `OpenOckhamist.lean`, which is the right outcome. Its five *refutations* are transferred
  (R38).

One borderline case worth recording: `PlusPasting.lean` has no counterpart file, but it is **not**
in the list above because its content splits three ways — the `paste`/`pasteAt` constructions are
reused unchanged (R33, NOT APPLICABLE), the agreement relations are lifted into `OpenClasses.lean`
(R34, TRANSFERRED), the congruences into `OpenAxiomValidity.lean` (R35, TRANSFERRED), and only the
pasting *validities* are owed (R36/R37, task 856 phase 10). No new file is wanted; the validity
block belongs where 856 is already putting it.

#### The direct L-to-L^▷ embedding is stated nowhere — not as a single map, not as a composition

The question the dispatch asks has a sharper answer than expected.

`grep -rn 'ofPlus (ofFormula\|ofPlus ∘ ofFormula\|ofFormulaOpen\|OpenFormula.ofFormula'` over
`FormalSystem/**/*.lean` returns **nine hits, all of them `StarLanguage.ofPlus`** — a different
map, `PlusFormula → StarFormula`, in `StarLanguage/Embedding.lean` and
`Metalogic/Conservativity/Star/Forward.lean`. `grep -rn 'ofFormula'` over `OpenLanguage/` returns
**one hit, inside a docstring**, in `OpenLanguage/Formula.lean:240`.

So: the composite `OpenLanguage.ofPlus ∘ PlusLanguage.ofFormula` is **not** stated as a single map,
and is **not** stated as a composition either. It does not appear in the tree at all. Nor does the
context-level map (`ofCtx`'s analogue). This is the architectural asymmetry with L⋆: for L⋆ the
composite embedding carries its own named row (`starDerivable_ofFormula_iff`), and for L^▷ it has
no name at any level.

Five ledger rows are blocked on it: R8 (the formula map), R9 (the context map), R19 (the proof
embedding of TM into TM^▷ — currently only REDUCIBLE through a two-step composition), R29 (semantic
conservativity of L^▷ over **L**, as opposed to over L⁺), and R50 (conservativity over TM at all
four classes, task 856 phase 13, which will need a name for the embedding it is conservative over).

Task 874 mentions it as a sub-deliverable in a subordinate clause — "`substOpen_atom` together with
whatever direct embedding `Formula -> OpenFormula` this file needs". Given that it is the end
state's front-door map between the two languages the repository intends to present, that placement
understates it. Recommendation T4 below.

#### Three L^▷ results depend on unformalized hypotheses, not two

The dispatch named two and asked whether there are others. There is one more, and the set is now
complete: `grep -rnE '^axiom '` over `FormalSystem/**/*.lean` returns **no `axiom` declaration
anywhere in the tree** (all ten hits are the word "axiom" inside docstrings), so every undischarged
assumption is an explicit hypothesis on a named theorem, and the three below are all of them.

1. **`SeparationOver`** (`Metalogic/Expressiveness/OpenFutureElimination.lean:349`) — "every L⁺
   formula is equivalent, on every regular frame satisfying `P`, to a separated form". An explicit
   named hypothesis standing for **cited literature this tree does not formalize**: Gabbay's
   Separation Theorem over the integer flow (GHR Thm 10.2.9) and over Dedekind-complete time
   (Thm 10.3.20). It carries **seven declarations**: `tr`, `openTruthAt_iff_tr`,
   `openValidOnFrames_iff_tr`, `openValidIn_ztime_iff_tr`, `openValidIn_rtime_iff_tr`,
   `exists_translation_ztime`, `exists_translation_rtime` — and is inherited by
   `decidableOpenValidZTimeOfTr`, `decidableOpenValidRTimeOfTr`, `decidableOpenValidInOfTranslation`,
   `openDecider`, `openDecider_correct`, `openComplete_of_plusComplete_in`, `openValid_of_plusSound`.
   The module records that it is **false** for `U`/`S` over `ℚ`, which is why the two reductions
   are confined to ZTime and RTime. **Task 867** (`[NOT STARTED]`) owns discharging it over
   discrete time.
2. **`hinexpr`** (`Metalogic/Independence/OpenFutureUndefinable.lean:412`) — that
   `MarkerGadget.DeltaProp` is not L⁺-expressible on the permissive frame over a dense,
   non-Dedekind-complete duration. The module's docstring records that the research round
   **derives** it (a collapse computation in the style of GHR vol. 1 Lemma 12.4.2, transposed from
   their flow to a dense carrier, "derived rather than quoted"), and that the half is
   **"UNVERIFIED in Lean"** and "the paper step of record". **FLAG: open-ish mathematics** — it is
   derived in prose, so formalizing it is a Lean task rather than a research one, but it is not a
   mechanical transfer.
3. **`hmarkers`** (`Metalogic/Independence/OpenFutureUndefinable.lean:410`) — **the one the
   dispatch did not name.** The frame's enough-worlds condition: from any present state with the
   marker atom false there is a world with the same past carrying the marker future. The module
   states that it "holds at `colourFibre D` for every `D`, because the world histories of that
   frame are the arbitrary colour functions with a clock offset and the marker future is just
   another colour function — but this module *states* that rather than compiling it, so `hmarkers`
   stays a hypothesis of the reduction theorem." This is **unwritten Lean, not open mathematics**,
   and the witness frame it needs (`colourFibre`, `colourFibre_isRegular`) is landed in the same
   file. It is the cheapest of the three by a wide margin and nobody owns it.

Both hypotheses 2 and 3 sit on the **same theorem**, `ofut_not_plusDefinable_of_deltaProp_inexpressible`
— the negative half of the definability class split (R54). Discharging `hmarkers` alone would not
make that theorem unconditional, but it would reduce it to a single hypothesis with a single,
clearly-labelled paper step behind it, which is a materially better surface than two.

A fourth family is worth distinguishing from these three, because it is **not** an unformalized
hypothesis: `openComplete_of_plusComplete_in`, `openValid_of_plusSound`,
`decidableOpenValidInOfTranslation`, `openDecider_correct` take an L⁺ *completeness relation*, an
L⁺ *soundness* fact, or an L⁺ *decidability* instance as a hypothesis. Those antecedents are
**genuinely open mathematics** (completeness of any extension of TM⁺ is open at every class;
`Decidable PlusValidZTime` is stated nowhere), not unformalized literature. Task 868 landed them
deliberately in that conditional shape, with the hypothesis as the leading clause, so that each
lands automatically when its antecedent arrives.

#### `OpenLanguage/README.md` now contradicts the tree

Not a ledger row, but the most misleading surface found, and it bears directly on the "measurable
condition" this ledger is supposed to create:

- The README states: *"L^▷ is **semantic only**: it has no proof system, and no axiomatization,
  soundness or completeness claim is made for `▷` or `◁`."* Since then `OpenAxioms.lean`
  (71 `OpenAxiom` constructors), `OpenDerivation.lean` (`OpenDerivable`, 7 rules, both
  conservativity directions over TM⁺ at the empty context) and `OpenErasure.lean`
  (`plusDerivable_openDerivable_iff`, the 21-entry discharge table) have landed. The
  *no-completeness* half of the claim remains true and important; the *no proof system* half is
  false.
- Its generated inventory (`<!-- BEGIN GENERATED: inventory dir=FormalSystem/OpenLanguage -->`)
  lists **six** files. The directory holds **nine** `.lean` files. `OpenAxioms.lean`,
  `OpenDerivation.lean` and `OpenErasure.lean` are absent from the table.
- `Metalogic/Conservativity/Open.lean`'s docstring is already correct and current (it names the
  53 re-declared TM⁺ schemata, the S5 laws, the strength ordering, the Ockhamist principle, the
  rigidity schemata, soundness at every class, conservativity over TM⁺ both directions and over TM
  at four classes, and the explicit *no completeness, at any frame class, in any form*). So the two
  surfaces now disagree with each other.
- Task 856's **phase 15** is titled "ledger surfaces and the full gate" and is `[NOT STARTED]`, so
  this is owned. Recording it here because until phase 15 runs, a reader of `OpenLanguage/README.md`
  will conclude the transfer has not started at the proof-system layer, when in fact phases 1–9
  and 14 of 856 are complete.

One further stale surface, lower stakes: `PlusLanguage/README.md`'s inventory row for
`Subformulas.lean` reads `<!-- TODO: add description -->`.

### Math-domain cross-reference

Three rows turn on non-logical mathematics, and each was checked against it rather than assigned by
name-matching:

- **R43 (TRANSFERRED despite no shared name).** `PlusRayFibre.lean` presents the `⊡` clause as a
  quantifier over a **product of two path spaces** — `plusStab_iff_rays` reading the stability
  clause over ray pairs through `Presheaf.seamFibreEquiv`, with `BwdSeq`/`FwdSeq`/`SeqPair`
  realizing the two factors and `plusStab_iff_omega` the ω-split. `OpenTruth.lean`'s
  `stab_iff_ofut_opast` / `stab_iff_opast_ofut` is that same decomposition read at the operator
  level, with `▷` and `◁` as the two **projections**: `stab_to_ofut_opast` needs no frame axiom,
  `ofut_opast_to_stab` needs exactly one `paste`. `OpenLanguage/README.md`'s `app:gluing`
  correspondence row states the identification explicitly ("the product structure of `⟨τ⟩_x` — the
  open pasts and the open futures as its two factors — read at the level of the modals rather than
  the classes"). So the mathematical content transferred even though the declaration names share
  nothing.
- **R45, R46 (NOT APPLICABLE on mathematical grounds).** `PlusOmegaChain.lean`'s results are
  order-theoretic facts about preorders and cofinality (`marker_mono` — a strictly increasing
  `ℕ`-indexed sequence in a preorder is monotone; `intOrder_omega_cofinal`;
  `int_marker_exists_gt`), and `PlusLimitClosure.lean`'s Zorn layer builds maximal partial
  histories. Neither mentions a formula of either language. Classifying these as OWED would have
  inflated the ledger with rows that have no meaning at L^▷.
- **R34 (TRANSFERRED as a lift, not a copy).** `AgreeFrom`/`AgreeUpTo` are the agreement relations
  of `PlusPasting.lean`; `OpenClasses.lean` turns them into the two restricted-modal **equivalence
  classes** `openFutureClass`/`openPastClass` with `agreeUpTo_equivalence`/`agreeFrom_equivalence`,
  and adds the lattice-shaped facts the product decomposition needs — the two inclusions into
  `stabClass`, `openFutureClass_inter_openPastClass` (the two classes meet in `{τ}`),
  `openFutureClass_anti` and `openPastClass_mono` (moving forward narrows the futures, widens the
  pasts). That is a strictly richer structure than the L⁺ source, which is why it counts as
  transferred rather than owed.

### Cross-Domain Synthesis

The ledger's shape is explained by one structural fact that spans both domains: **L^▷ extends L⁺ by
two modals whose semantic classes are the two factors of L⁺'s stability class.** Everything that
follows from that is cheap and is landed; everything that cuts against it is owed.

- Results that are *about an L⁺ formula* transfer unconditionally at every frame class, because
  `ofPlus` is injective with a retraction (`eraseOpen_ofPlus`) and both conservativity directions
  are class-generic. This is why 21 rows are TRANSFERRED and 11 more are REDUCIBLE through (V1) or
  (V2) with no hypothesis at all. **The ZTime/RTime translation equivalences are not the vehicle
  for any of these rows**, contrary to the dispatch's expectation — they are needed only for R42
  and R58, where the statement concerns genuinely open-modal formulas and must be pushed *back*
  into L⁺.
- Results that are *about the whole language* — soundness, conservativity over TM, axiom-set
  non-redundancy, state-locality, incompleteness — do **not** transfer by conservativity, because
  the L^▷ axiom set is strictly larger (71 vs 53 constructors) and the two new modals break the
  properties the L⁺ proofs rely on. These are exactly the OWED rows, and exactly the ones task 856
  is working through phase by phase.
- The one place where the mathematics, not the Lean, is the obstruction is the frame-class split:
  `▷` is L⁺-definable at ZTime and RTime (conditionally on separation) and **not** definable at
  Base or Dense (conditionally on `hinexpr` and `hmarkers`). Base and Dense have no translation, so
  no reduction exists there and none can be written; that is why `openValidIn_ztime_iff_tr` and
  `openValidIn_rtime_iff_tr` have no Base or Dense siblings and why a REDUCIBLE row citing them
  must state its class.

---

## Decisions

1. **Reduction vehicle.** Where an L⁺ result is a claim about an L⁺ formula, the REDUCIBLE status
   cites **(V1) `openValidIn_ofPlus_iff`** or **(V2) `plusDerivable_openDerivable_iff`** at *every
   frame class*, not the ZTime/RTime translations. Both are unconditional and class-generic; the
   translations are neither. The ZTime/RTime translations are cited only at R42 and R58, where the
   direction of reduction genuinely runs from L^▷ back to L⁺.
2. **Frame class on every REDUCIBLE row.** Per the dispatch, no REDUCIBLE row is left without one.
   Nine cite "every frame class" (Base, Dense, ZTime, RTime) on the strength of (V1)/(V2)'s
   `{fc : FrameClass}` binder; two cite ZTime/RTime and name the `SeparationOver` hypothesis.
3. **Frame-level infrastructure is NOT APPLICABLE, not OWED.** Declarations whose statements
   quantify over histories, times, world states or path spaces rather than over formulas get NOT
   APPLICABLE with the reason in one clause (R33, R39, R44, R45, R46). Marking them OWED would
   invent work that has no L^▷ meaning and would make the ledger's remaining-work count wrong.
4. **R53 and R63 are NOT APPLICABLE for a different reason** — each is a result about a *lower or
   higher* language (L, and the hybrid register-free class respectively) that already covers L⁺ as a
   sub-case and needs no separate L^▷ restatement. Stated separately so the two kinds of
   NOT APPLICABLE are not confused.
5. **R54 is TRANSFERRED, with conditionality recorded in-row.** Its L^▷ counterpart exists as a
   named declaration, which is what TRANSFERRED means in the dispatch's closed set. Its two
   undischarged hypotheses are a separate axis and are recorded both in the row and in the
   *Unformalized hypotheses* finding, rather than being folded into the status.
6. **No task is filed from this dispatch.** Per the dispatch, OWED rows get a named owner or a
   proposed scope; filing is left to the conclusion stage.

---

## Recommendations

### For each OWED row: existing owner, or proposed scope

**Already owned — no new task needed.**

| Rows | Owner | Status |
|---|---|---|
| R36, R37 (pasting validities) | **856** phase 10 | `[NOT STARTED]` |
| R49 (soundness) | **856** phase 12 | `[NOT STARTED]`, gated on phases 10–11 |
| R50 (conservativity over TM) | **856** phase 13 | `[NOT STARTED]` |
| R10, R11, R12 (subformulas, closure, `BoxStabFree`) | **873** | `[NOT STARTED]`, gated on 856 |
| R13, R14 (substitution, `ofTMSubst`, substitution transfer) | **874** | `[NOT STARTED]`, gated on 856 |
| R56 (incompleteness at Base) | **875** | `[NOT STARTED]`, gated on 856 and 871 |
| R59 (history-morphism invariance) | **869** | `[NOT STARTED]` |
| R47, R48 (`blc`, `LC_n`) — REDUCIBLE but owed as stated rows | **875**, with **871** as prerequisite | `[NOT STARTED]` |

**Unowned — proposed tasks, in descending value. Not filed from this dispatch.**

**T1 — The L^▷ state-locality fragment (covers R41, R62).** Build
`FormalSystem/OpenLanguage/OpenStateLocal.lean`, the L^▷ counterpart of
`PlusLanguage/PlusStateLocal.lean`: the syntactic predicate `OpenFormula.StateLocal` and the
semantic `IsOpenStateLocal`, the soundness induction `isOpenStateLocal_of_stateLocal`, the
fragment-level `openStateLocal_openValid_iff_stab`, and the agreement biconditional
`stateLocal_ofPlus_iff` saying the L^▷ fragment is exactly the `ofPlus`-preimage of the L⁺ one —
the exact shape `Semantics/StateLocalTransfer.lean` already uses for L⁺-over-L⋆, and it must live
in its own module for the same import reason that file records. Then the two negative rows that
make the fragment's boundary honest: `▷` and `◁` are **not** state-local, derivable in a line each
from the landed `ofut_pastDet` and `opast_futDet`. Why it matters: state-locality is the
decidability front's one working anchor for `⊡` (one bit per cell), and task 876 (stability
primitive removal) names its loss as a live risk — so this task is also 876's missing evidence.
Gated on task 856's soundness phase only if a derivability row is wanted; the semantic rows need
nothing beyond what is landed. Size: moderate, mostly mechanical. **Lean task.**

**T2 — The L^▷ semantics-support lemmas (covers R28, R32, R60, R61, and optionally R42).** A single
small task collecting the L⁺ support lemmas that have no L^▷ sibling and that each take a few lines:
the three per-class validity abbreviations `OpenValidDense`/`OpenValidZTime`/`OpenValidRTime`
(R28); the three frame-class-level reflection rows `openValidOnFrames_reflectTime`,
`openValidIn_reflectTime`, `openValidIn_reflectTime_iff` that `OpenReversal.lean` stops short of
(R32); `openTruthAt_congr_of_fresh`, the fresh-atom congruence that discharges an auxiliary letter
(R60); and `openValidIn_iff_recurrenceFree` (R61). Each is a direct transcription of its L⁺ twin
over `OpenTruthAt`/`OpenValidIn`, with the two new modal cases added to the recursion. Optionally
absorb R42 (`openTruthAt_map`, `OpenValidInt`, and the carrier normalization at ZTime) as a final
phase — it is the only item in the group that is not purely mechanical, since the ZTime normalization
needs either the conditional translation or a direct induction. Size: small-to-moderate.
**Lean task.**

**T3 — L^▷ axiom-set non-redundancy (covers R55).** `OpenAxiom` has **71** constructors against
`PlusAxiom`'s **53**, and `plusAxiomSetNonRedundant` has no L^▷ analogue, so nothing rules out that
some of the 18 new schemata are derivable from the rest. Scope: state and prove non-redundancy for
the new block — the eight S5 schemata for `▷`/`◁`, the three ordering schemata
(`stab_of_box`, `ofut_of_stab`, `opast_of_stab`), `hn_open` and `hn_open_mirror`, the four rigidity
schemata, and `definability_fwd` — reusing `PastingIndependence.lean`'s method (a model refuting
the candidate while validating the rest) and the landed `sinkFrame` / `NF` countermodels, several of
which already refute exactly the needed converses (`not_openValid_stab_of_ofut`,
`not_openValid_opast_of_ofut`, `not_openValid_ofut_of_opast`). **Hard gate: must run after task
856 phase 12 (soundness)**, since each non-derivability argument needs soundness of the remaining
set. Flag: this may uncover a genuinely redundant schema, in which case the finding is a
recommendation to the maintainer and not a licence to remove a constructor. Size: moderate to large.
**Lean task.**

**T4 — Name the direct L-to-L^▷ embedding (covers R8, R9, and unblocks R19, R29, R50).** Promote
what task 874 currently carries in a subordinate clause into its own early, tiny task: a named map
`OpenLanguage.ofFormula : Formula → OpenFormula` (or equivalently a named abbreviation for
`ofPlus ∘ PlusLanguage.ofFormula`), with `ofFormula_injective`, `ofFormula_reflectTime`, the
context map and its membership lemma, and the `rfl` commutation pin
`ofFormula = ofPlus ∘ PlusLanguage.ofFormula` that makes every L⁺-level fact about `ofFormula`
available at L^▷ by rewriting. Then the single-map readings of R19 (TM into TM^▷) and R29
(semantic conservativity of L^▷ over L), each one line from the composite plus (V1)/(V2). Why it
should be its own task and run early: it is the end state's front-door map between the two
languages the repository intends to present; five ledger rows depend on it; and task 856 phase 13
(conservativity over TM) will need a name for the embedding it is conservative over, so leaving it
inside 874 puts it downstream of its own consumers. Size: small. **Lean task.** It should be
sequenced **before** 856 phase 13 and before 874.

**T5 — Discharge `hmarkers` (sharpens R54).** Compile what
`Metalogic/Independence/OpenFutureUndefinable.lean` currently only states: that the enough-worlds
condition holds at `colourFibre D` for every `D`, because that frame's world histories are the
arbitrary colour functions with a clock offset and the marker future is another colour function.
The frame and its regularity instance (`colourFibre`, `colourFibre_isRegular`) are landed in the
same file. Outcome: `ofut_not_plusDefinable_of_deltaProp_inexpressible` specializes to a one-hypothesis
form at the witness frame, leaving `hinexpr` as the single, clearly-labelled paper step. Size:
small. **Lean task.** Note: task 860 (`[RESEARCHED]`) adds a bridge lemma in
`Semantics/Frames/TranslationProduct.lean` making the "every colour function is a history" step
compiled rather than stated — **check whether 860 already discharges the load-bearing step before
filing T5**; if it does, T5 shrinks to an application.

**T6 — The L^▷ discrete/`⊡`-indexed abbreviations (covers R5, and R2).** `OpenFormula` lacks
`next`, `prev`, `would`, `after`, `Will`, `will`, `Could`, `could` (confirmed absent) and
`atom_injective`. Pure notation and one injectivity lemma. Lowest-value row in the ledger; worth
absorbing into T2 or into task 873's syntax pass rather than filing on its own. **Lean task,
trivial.**

### Rows blocked on open mathematics, not on unwritten Lean — flagged, and explicitly not proposed as tasks

Per the dispatch, these belong to the completeness and decidability programmes and not to this one.
They are listed so the ledger's remaining-work count is not read as a to-do list.

1. **R57 — completeness of any extension of the TM⁺ axiom set, at any class.** OPEN. Stated nowhere
   in the tree and never discharged with `sorry`. `Metalogic/README.md` records that the nearest
   literature (Reynolds 2003 on until/since over the reals, Zanardo 1991 on branching time under an
   Ockhamist reading) does not settle the all-histories semantics used here. There is nothing to
   transfer because there is nothing at L⁺ to transfer.
2. **R58 — TM⁺ decidability.** OPEN. `Decidable PlusValidZTime` is stated nowhere. The L^▷
   reductions are already landed in their conditional form (task 868, `[COMPLETED]`), which is the
   correct and complete response to this row: the moment the L⁺ antecedent arrives, the L^▷ result
   follows by application.
3. **R64 — the 35-row ZTime certificate front** (`PlusSharingWitnessFamily`,
   `PlusSlicedCertificate`, `NoFiniteWidth`, `FiniteCarrier`). This is the ZTime decidability
   programme mid-flight, including two landed *negative* results (the sharing-family class is
   incomplete under no hypothesis at all; the time-sliced class is incomplete for L⁺ over ℤ-time;
   the finite-carrier finite model property fails). Transferring an unfinished certificate front to
   a second language would multiply the surface that is currently being narrowed. Recommend
   explicitly **deferring** the L^▷ reading of this block until the L⁺ side closes.
4. **R54's `hinexpr`** — the inexpressibility of `MarkerGadget.DeltaProp`. Derived in prose
   (a GHR-style collapse computation transposed to a dense carrier), "derived rather than quoted",
   and UNVERIFIED in Lean. Formalizing it is a substantial research-grade Lean task, not a
   transfer. `SeparationOver` is its mirror on the positive side and is already owned by task 867.

---

## Risks & Mitigations

- **Risk: the ledger's TRANSFERRED count reads as more progress than exists, because 856 is
  mid-flight.** 21 TRANSFERRED rows depend on task 856 phases 1–9 and 14, which are complete, but
  phases 10–13 and 15 are not, so the L^▷ proof system is **sound-pending**: `OpenDerivable`
  exists, both conservativity directions over TM⁺ exist, and no soundness theorem exists.
  *Mitigation*: R49 (soundness) is called out as OWED in its own row rather than folded into R15–R20,
  and the per-owner table above makes 856's remaining phases explicit. Treat "TRANSFERRED at the
  proof-system layer" as "the objects exist", not "the metatheory holds".
- **Risk: a REDUCIBLE row is read as a landed result.** Eleven rows have no L^▷ declaration at all.
  *Mitigation*: every REDUCIBLE cell names its vehicle and its frame class, and the two conditional
  rows (R42, R58) name `SeparationOver` in the cell. A future consumer should treat REDUCIBLE as
  "one line of Lean away, given the named theorem", not as "done".
- **Risk: `OpenLanguage/README.md`'s "semantic only" claim misleads a reader into re-filing work
  task 856 has already done.** *Mitigation*: flagged in Findings with its owner (856 phase 15).
  Until that phase runs, `Metalogic/Conservativity/Open.lean`'s docstring is the accurate surface
  and should be preferred.
- **Risk: the negative existence claims rest on grep, not on the LSP index.** `lean_local_search`
  reported `index: warming`. *Mitigation*: announced as the Evidence Tier above; every negative
  claim's grep is recorded below and re-runnable. The tier is adequate here because neither
  language directory generates declaration names by macro — confirmed by the per-file declaration
  sweep, in which every declaration appears as a literal `theorem`/`def`/`lemma`/`inductive` header.
- **Risk: T3 (axiom-set non-redundancy) could discover a redundant `OpenAxiom` constructor and be
  read as licence to remove it.** *Mitigation*: T3's scope explicitly says a redundancy finding is a
  recommendation to the maintainer, not a removal. The standing ruling against mutating the axiom
  inductives of the embedded language has an obvious analogue here, and task 876 already shows that
  removing a primitive is a decision-gated task in its own right.
- **Risk: task-ordering inversion.** T4 (the direct L→L^▷ embedding) is a prerequisite of 856
  phase 13 and of 874, both of which are already filed and gated the other way. *Mitigation*: T4's
  scope states the sequencing requirement explicitly. If the conclusion stage files T4, it must also
  record the dependency edge, or 856 phase 13 will re-derive an unnamed composite.
- **Risk: double-counting between T2 and task 869.** T2 proposes `openValidIn_iff_recurrenceFree`
  and the reflection rows; task 869 proposes `open_invariance` over `OpenFormula`, which touches the
  same recursion. *Mitigation*: flagged here; if both are filed they share file territory
  (`OpenLanguage/`, `Semantics/`) and should be batched or given an explicit dependency edge rather
  than run concurrently.

---

## Verification Commands

Every count and every declaration name above is reproducible from the commands below, run from the
repository root at `4c52993c1`.

```bash
# --- Source A: file and declaration counts -----------------------------------
ls -1 FormalSystem/PlusLanguage/ | wc -l            # 18
ls -1 FormalSystem/OpenLanguage/ | wc -l            # 10
ls -1 FormalSystem/PlusLanguage/*.lean | wc -l      # 17
ls -1 FormalSystem/OpenLanguage/*.lean | wc -l      # 9

grep -hE '^\s*(theorem|lemma|def|abbrev|structure|inductive|instance|class) [A-Za-z0-9_]' \
  FormalSystem/PlusLanguage/*.lean | wc -l          # 268
grep -hE '^\s*(theorem|lemma|def|abbrev|structure|inductive|instance|class) [A-Za-z0-9_]' \
  FormalSystem/OpenLanguage/*.lean | wc -l          # 195

# per-file declaration counts (the two tables in "How the L⁺ surface was enumerated")
for f in FormalSystem/PlusLanguage/*.lean; do \
  printf '%s  %s\n' \
    "$(grep -cE '^\s*(theorem|lemma|def|abbrev|structure|inductive|instance|class) [A-Za-z0-9_]' "$f")" \
    "$(basename "$f")"; done
for f in FormalSystem/OpenLanguage/*.lean; do \
  printf '%s  %s\n' \
    "$(grep -cE '^\s*(theorem|lemma|def|abbrev|structure|inductive|instance|class) [A-Za-z0-9_]' "$f")" \
    "$(basename "$f")"; done

# per-file declaration NAMES, with namespace boundaries (the row contents)
for f in FormalSystem/PlusLanguage/*.lean FormalSystem/OpenLanguage/*.lean; do \
  echo "### $f"; \
  grep -oE '^(namespace|end) [A-Za-z0-9_.]+|^\s*(theorem|lemma|def|abbrev|structure|inductive|instance|class) [A-Za-z0-9_'"'"'.!?]+' "$f" \
    | sed -E 's/^\s+//'; done

# inductive sizes
awk '/^inductive PlusAxiom/{f=1} f&&/^\s{2}\| [a-zA-Z0-9_]+/{n++} /^def |^end /{if(f&&n)exit} END{print n}' \
  FormalSystem/PlusLanguage/Axioms.lean                      # 53
awk '/^inductive OpenAxiom/{f=1} f&&/^\s{2}\| [a-zA-Z0-9_]+/{n++} END{print n}' \
  FormalSystem/OpenLanguage/OpenAxioms.lean                  # 71
for pair in "FormalSystem/PlusLanguage/Derivation.lean PlusDerivationTree" \
            "FormalSystem/OpenLanguage/OpenDerivation.lean OpenDerivationTree"; do \
  set -- $pair; \
  awk -v want="inductive $2" '$0 ~ want {f=1; next} \
    f && /^(namespace|def |abbrev |end |theorem )/ {exit} \
    f && /^\s{2}\| [a-zA-Z0-9_]+/ {n++} END{print n}' "$1"; done   # 7 and 7

# --- Source B: docs/theorem-index.md ----------------------------------------
grep -cE '^\|' docs/theorem-index.md                             # 442
grep -cE '^\|.*FormalSystem\.PlusLanguage\.' docs/theorem-index.md   # 17
grep -cE '^\|.*L⁺' docs/theorem-index.md                         # 43
grep -cE '^\|.*FormalSystem\.(OpenLanguage|Metalogic\.Conservativity\.open|Metalogic\.Expressiveness\.open)' \
  docs/theorem-index.md                                          # 15
grep -cE '^\|.*L\^▷' docs/theorem-index.md                       # 1
grep -cE '^\|.*FormalSystem\.Metalogic\.Decidability\.(PlusSharingWitnessFamily|PlusSlicedCertificate)' \
  docs/theorem-index.md                                          # 35
# the 17 named-declaration rows, with line numbers
grep -nE '^\|.*FormalSystem\.PlusLanguage\.' docs/theorem-index.md \
  | sed -E 's/^([0-9]+):.*(FormalSystem\.PlusLanguage\.[A-Za-z0-9_.'"'"']+).*/\1 \2/'
# the claim text of the two rows cited for R45's NOT APPLICABLE verdict
sed -n '487p;494p' docs/theorem-index.md

# --- Source C: FormalSystem/Metalogic/README.md -----------------------------
sed -n '/^### The TM⁺ metatheory rows/,/^### The TM⋆/p' FormalSystem/Metalogic/README.md \
  | grep -cE '^\|'                                               # 12 lines = 10 content rows
sed -n '265,340p' FormalSystem/Metalogic/README.md               # the table and its prose

# --- Open-side metalogic declaration lists ----------------------------------
for f in FormalSystem/Metalogic/Conservativity/Open/OpenAxiomValidity.lean \
         FormalSystem/Metalogic/Deterministic/OpenCollapse.lean \
         FormalSystem/Metalogic/Independence/OpenFutureUndefinable.lean \
         FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean; do \
  echo "### $f"; \
  grep -oE '^(namespace|end) [A-Za-z0-9_.]+|^\s*(theorem|lemma|def|abbrev|structure|inductive|instance|class|axiom) [A-Za-z0-9_'"'"'.!?]+' "$f" \
    | sed -E 's/^\s+//'; done
for f in FormalSystem/Metalogic/Conservativity/Plus/PlusSoundness.lean \
         FormalSystem/Metalogic/Conservativity/Plus/Forward.lean \
         FormalSystem/Metalogic/Conservativity/Plus/Corollaries.lean \
         FormalSystem/Metalogic/Independence/PlusIncompleteness.lean \
         FormalSystem/Metalogic/Independence/StabUndefinable.lean \
         FormalSystem/Metalogic/Independence/PastingIndependence.lean \
         FormalSystem/Metalogic/Deterministic/Completeness.lean; do \
  echo "### $f"; \
  grep -oE '^\s*(theorem|lemma|def|abbrev|structure|inductive|instance) [A-Za-z0-9_'"'"'.!?]+' "$f" \
    | sed -E 's/^\s+//'; done

# --- Files referencing OpenLanguage outside OpenLanguage/ -------------------
grep -rlE 'OpenLanguage|OpenFormula|OpenValid' FormalSystem --include=*.lean \
  | grep -v '^FormalSystem/OpenLanguage/' | sort            # the 18 files cited in Layer 4/5

# --- Negative existence claims (the Evidence Tier rests on these) -----------
for n in openValidInt OpenValidInt openStateLocal IsOpenStateLocal StateLocalOpen \
         openSubformulas subformulasOpen openSubformulaClosure openComplexity \
         substOpen substCtxOpen openStab_iff_rays openOmega blcOpen openLimitClosure \
         lcNOpen openValid_paste paste_openValid openBoxStabFree open_incomplete \
         openDecidable open_soundness openDerivable_ofPlus_iff forward_open \
         openValidOnFrames_reflectTime openValidIn_reflectTime openValidZTime \
         openValidRTime OpenValidDense OpenValidZTime OpenValidRTime openTruthAt_map \
         open_invariance openTruthAt_congr_of_fresh openValidIn_iff_recurrenceFree \
         ofCtxOpen openOfCtx mem_ofCtxOpen openAfter_negation open_state_only \
         openStab_state_only; do \
  printf '%s  %s\n' "$(grep -rn "\b$n\b" FormalSystem --include=*.lean | wc -l)" "$n"; done
# every line above prints 0 except: openComplete (6, = openComplete_of_plusComplete_in)
for n in next prev would after Will will Could could; do \
  printf '%s  OpenFormula.%s\n' \
    "$(grep -cE "^\s*(def|lemma) $n\b" FormalSystem/OpenLanguage/Formula.lean)" "$n"; done  # all 0

# --- The direct L -> L^▷ embedding question ---------------------------------
grep -rnE 'ofPlus \(ofFormula|ofPlus ∘ ofFormula|ofFormulaOpen|ofBase|OpenFormula\.ofFormula' \
  FormalSystem --include=*.lean      # 9 hits, ALL StarLanguage.ofPlus (Star/ and StarLanguage/)
grep -rn 'ofFormula' FormalSystem/OpenLanguage/   # 1 hit, a docstring at Formula.lean:240
grep -rn 'ofPlus' FormalSystem --include=*.lean | grep -vE 'StarLanguage|Conservativity/Star' \
  | grep -oE '^[^:]+:[0-9]+' | cut -d: -f1 | sort | uniq -c   # the 23-file ofPlus consumer list

# --- Unformalized hypotheses -------------------------------------------------
grep -rnE '^axiom ' FormalSystem --include=*.lean   # zero axiom DECLARATIONS (all hits are prose)
grep -rnE '^def (SeparationOver|OfutPlusDefinable|SepClauses|DeltaProp)' FormalSystem --include=*.lean
grep -rnE '\(h[a-z]* : (SeparationOver|.*[Ii]nexpressible)' FormalSystem --include=*.lean
sed -n '/theorem ofut_not_plusDefinable_of_deltaProp_inexpressible/,/:= /p' \
  FormalSystem/Metalogic/Independence/OpenFutureUndefinable.lean   # hmarkers + hinexpr
sed -n '72,100p' FormalSystem/Metalogic/Independence/OpenFutureUndefinable.lean  # the three-way split
grep -nE 'not formalized|undischarged|unformalized|UNVERIFIED|hypothesis' \
  FormalSystem/Metalogic/Expressiveness/README.md

# --- The reduction vehicles' signatures (V1, V2, V3) ------------------------
grep -n -A5 'theorem openValidIn_ofPlus_iff\|theorem openValid_ofPlus_iff\|theorem openValidOnFrames_ofPlus_iff' \
  FormalSystem/OpenLanguage/OpenValidity.lean                      # V1, {fc : FrameClass}
grep -n -A6 'theorem plusDerivable_openDerivable_iff\|theorem plusDerivable_of_openDerivable' \
  FormalSystem/OpenLanguage/OpenErasure.lean                       # V2, {fc : FrameClass}
grep -n -A6 'theorem openDerivable_of_plusDerivable' FormalSystem/OpenLanguage/OpenDerivation.lean
sed -n '340,440p' FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean  # V3 and SeparationOver

# --- Stale-surface findings ---------------------------------------------------
sed -n '/BEGIN GENERATED/,/END GENERATED/p' FormalSystem/OpenLanguage/README.md   # 6 rows, 9 files
sed -n '/BEGIN GENERATED/,/END GENERATED/p' FormalSystem/PlusLanguage/README.md   # Subformulas TODO
grep -n 'semantic only' FormalSystem/OpenLanguage/README.md
cat FormalSystem/Metalogic/Conservativity/Open.lean                # the accurate surface

# --- Task ownership ----------------------------------------------------------
grep -nE '^### [0-9]+\.' specs/TODO.md
grep -nE '^### Phase' specs/856_*/plans/*.md     # phases 1-9,14 COMPLETED; 10-13,15 NOT STARTED
sed -n '362,386p' specs/TODO.md                  # task 868, COMPLETED
```

---

## Issue Log

Recorded as they arose, per the dispatch's capture-only contract
(`specs/872_open_language_transfer_ledger/issues.jsonl`):

- **win** / `prior-art-reuse` / severity `none` — the three-source enumeration landed cleanly and
  task 856's plan phase table supplied the exact landed/owed split for the L^▷ proof system without
  re-derivation.
- **issue** / `tooling-degraded` / severity `minor` — `lean_local_search` reported
  `index: "warming"`, so LSP-backed absence is not proof of absence; evidence of record for every
  negative existence claim degraded to a recorded grep, announced in the report.

Nothing else arose: no gate collision, no blocker, no deviation from the dispatch's scope.
