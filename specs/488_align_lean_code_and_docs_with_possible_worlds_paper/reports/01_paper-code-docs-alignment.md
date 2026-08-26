# Research Report: Paper / Lean / Docs Alignment for `possible_worlds.tex`

- **Task**: 488 - align_lean_code_and_docs_with_possible_worlds_paper
- **Started**: 2026-08-25T00:00:00Z
- **Completed**: 2026-08-25T00:00:00Z
- **Effort**: ~1 session (research only; no implementation)
- **Dependencies**: None
- **Sources/Inputs**:
  - Paper (read-only): `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`
    (4856 lines, sha256 `5d700a2f05999bb6…`). It has **no** `\input`/`\include` of
    `metalogic.tex` or `missing.md` (only a commented `% \input sn-article.bbl` at line 4854),
    so those two companion files are **out of scope** and were not read.
  - Pinned record: `specs/paper-definitions-of-record.md` (1247 lines)
  - Lean: `FormalSystem/` (413 live `.lean`), `Tests/` (53), `FormalSystem/Boneyard/` (156, excluded)
  - Docs: `README.md`, `FormalSystem/README.md`, `Tests/README.md`, `docs/README.md`,
    `data/README.md`, `latex/README.md`, `typst/README.md`, `CLAUDE.md`,
    `docs/reference/axiom-reference.md`, `typst/SYNC-MAP.md`
  - Command output: `lake build`; `scripts/check-paper-definitions.sh`;
    `scripts/check-module-invariants.sh --no-build`; `scripts/typst-sync-check.sh`;
    `scripts/typst-status-counts.sh`; `cloc`; an independent 25-theorem `#print axioms` audit
- **Artifacts**: `specs/488_align_lean_code_and_docs_with_possible_worlds_paper/reports/01_paper-code-docs-alignment.md`
- **Standards**: status-markers.md, artifact-management.md, tasks.md, report-format.md

## Executive Summary

- **The Lean tree is in better shape than the paper's claims about it.** Every load-bearing
  metatheorem is genuinely proved: `lake build` exits 0 with **zero** `sorry` warnings, check C3
  reports **zero** structural sorries in live `FormalSystem/`, and an independent `#print axioms`
  over **25** soundness/completeness/decidability theorems returns exactly
  `[propext, Classical.choice, Quot.sound]` for all 25. `README.md:144`'s sorry-free claim is
  **correct**.
- **The paper over-claims what the repository proves, in three places.** It asserts TM⁺ and TM⁺_d
  are **strongly** complete and attributes that to this repository (`possible_worlds.tex:4657-4670`);
  the tree proves only *weak* and *finite-context consequence* completeness and records infinitary
  strong completeness as **open** (`README.md:149`). It asserts TM⁺ is **decidable** "as implemented
  in the Lean 4 repository" (`:1706`), which the tree contradicts and which the paper's own
  commented-out `cor:tm-decidability` proof also contradicts (`:4683`). And it asserts "the results
  throughout are formalized in Lean 4" (`:1801`) over three appendix sections that have no Lean
  counterpart at all.
- **The paper has drifted again since the last pin.** `scripts/check-paper-definitions.sh` **exits 1**:
  **32** recorded definitions drifted and **6** recorded anchors are now dangling. The dominant
  change is a global `frame` → `task frame` rename; the substantive ones are the `def:directed`
  ⊇/⊆ split, the removal of *Deterministic* from `def:frame-properties`, and the replacement of
  `thm:s4`/`thm:sym` by a single `thm:s5`.
- **30 citations of 6 now-nonexistent paper anchors** sit in live (non-`Boneyard`) scope —
  `lem:fibers` ×17, `thm:ConservativeExtension` ×5, `cor:tm-decidability` ×4, `app:valid` ×2,
  `thm:occurrence` ×1, `app:nonempty` ×1 — across 14 files.
- **`README.md` carries three concrete, checkable errors**: the repository URL is wrong in three
  places (`ProofChecker` vs. the actual remote and the paper's cited `BimodalLogic`); the task-frame
  description names only three of the six constraints the `TaskFrame` structure actually carries;
  and the operator table's "Lean Constructor" column was not updated by the guard-first migration.
  Its *numeric* claims (45/37/39/40/42 axioms, 539 files, 170,898 LOC) are all **verified correct**.
- **Two of the 45 axiom constructors are definitionally vacuous** — `F_until_equiv` and
  `P_since_equiv` reduce to `X → X` (confirmed by `rfl`). The paper's `TMP-UT` has the same
  degeneracy. Separately, **six in-tree locations still say "42 axiom constructors"**, stale by 3;
  check C14 does not cover `.lean` docstrings, only `docs/` + `README.md`.

## Context & Scope

Three artifacts were compared pairwise:

1. **The paper** — `possible_worlds.tex`, a JPL submission. Read-only input to this repository;
   never edited from here.
2. **The Lean codebase** — what is actually defined and actually proved.
3. **The documentation** — `README.md` + per-directory READMEs + `docs/` + `typst/`.

The repository already carries substantial paper-alignment machinery that this report builds on
rather than duplicates: `specs/paper-definitions-of-record.md` pins 50 paper definitions verbatim
by `\label`/`\aitem` anchor with sha256 hashes, and `scripts/check-paper-definitions.sh`
re-derives every hash from the live paper. Many Lean modules already cite paper anchors verbatim
(`FormalSystem/Semantics/TaskFrame.lean:513-515`, `FormalSystem/Semantics/FrameAxioms.lean:350-351`).
This report's job is to find where that machinery has fallen behind and where claims in either
direction are not supported.

**Skepticism note**: no README claim below is accepted on its own authority. Every numeric claim
was re-derived by running the command that produces it; every proof-status claim was re-derived by
`#print axioms`.

**Line-number caveat**: all `README.md` line references below are against the **committed** file at
`git HEAD` (`36da86ead`). While this research was in flight, a concurrent agent left `README.md`
modified in the working tree (`git diff README.md`: -10/+2). That diff **deletes** the
strong-completeness precision block at lines 146-152 — the block that correctly separates
*refuted* (Discrete) from *open* (Base, Dense) from *not stated* (Dedekind) — and replaces it with
the flat sentence "Completeness results are proven for all four frame classes". That flattening is
itself a **new SUBSTANTIVE discrepancy** (it is precisely the distinction D1/D2 turn on) and any
plan acting on this report must reconcile with that working-tree change before editing `README.md`.
It also independently fixes the line-243 paper URL to `publications/possible_worlds.pdf`, which
partially addresses D19's URL inconsistency.

## Findings

### F1. Build and proof reality — no discrepancy

`lake build` (full, from clean cache state): **exit 0**, `Build completed successfully (2493 jobs)`.

- **0** `error:` lines.
- **0** occurrences of `declaration uses 'sorry'`.
- Warnings are all lint-class, none proof-affecting: 142 "automatically included section
  variable", 83 "unused simp argument", 62 "overlapping instance parameters", 22 "variable name
  not explicitly referenced", 9 "tactic is never executed", 5 "'done' does nothing", 1
  "'assumption' does nothing", plus 14 "Try this".

`scripts/check-module-invariants.sh --no-build` reports **ALL CHECKS PASSED**, including
`PASS C3 structural sorry inventory is ZERO across FormalSystem/ (Boneyard/ excluded)`.

The 1005 `grep -rn '\bsorry\b'` hits in `FormalSystem/`+`Tests/` are **prose in docstrings**
("sorry-free", "the sorry root cause analysis…"), not tactic occurrences — C3 asserts zero
*by content*, and the build's zero sorry-warnings independently confirms it.

Live per-directory `sorry` census (`scripts/typst-status-counts.sh`, re-run):
`sorry_total = 4`, all four in `WeakCanonical/` **inside `Boneyard/`**;
`sorry_total_excl_boneyard = 0`; `Algebraic/`, `BXCanonical/`, `Bundle/`,
`Core/ + Decidability/ + SoundnessLemmas/ + top-level` all **0**.

**No load-bearing theorem is affected by any sorry.**

### F2. Metatheorem verification status — independent `#print axioms` audit

Run via a scratch file over `import FormalSystem`. All 25 returned
`[propext, Classical.choice, Quot.sound]` — no `sorryAx`, no custom axiom.

| # | Theorem (fully qualified) | Location | Paper counterpart | Status |
|---|---|---|---|---|
| 1 | `Metalogic.soundness` | `Metalogic/Soundness.lean:1080` | `thm:TM-soundness` (4484), for TM⁺ | **PROVED** |
| 2 | `Metalogic.soundness_dense` | `Soundness.lean:1254` | `app:dense` (3886) | **PROVED** |
| 3 | `Metalogic.soundness_discrete` | `Soundness.lean:1400` | `app:discrete` (3805) | **PROVED** |
| 4 | `Metalogic.soundness_dedekind` | `Soundness.lean:1927` | `app:complete` (3966) | **PROVED** |
| 5 | `Metalogic.soundness_base_consequence` | `StrongCompleteness.lean:551` | — | **PROVED** |
| 6 | `Metalogic.soundness_dense_consequence` | `StrongCompleteness.lean:655` | — | **PROVED** |
| 7 | `Metalogic.soundness_discrete_consequence` | `StrongCompleteness.lean:763` | — | **PROVED** |
| 8 | `Metalogic.soundness_dedekind_consequence` | `StrongCompleteness.lean:408` | — | **PROVED** |
| 9 | `Metalogic.BXCanonical.completeness` | `BXCanonical/Completeness.lean:196` | `cor:tm-completeness` row **TM⁺** | **PROVED (weak only)** |
| 10 | `Metalogic.BXCanonical.completeness_dense` | `Completeness.lean:255` | row **TM⁺_d** | **PROVED (weak only)** |
| 11 | `Metalogic.BXCanonical.completeness_discrete` | `Completeness.lean:296` | row **TM⁺_f** | **PROVED** |
| 12 | `Metalogic.completeness_base` | `StrongCompleteness.lean:564` | row **TM⁺** | **PROVED (weak)** |
| 13 | `Metalogic.completeness_dense` | `StrongCompleteness.lean:672` | row **TM⁺_d** | **PROVED (weak)** |
| 14 | `Metalogic.completeness_discrete` | `StrongCompleteness.lean:781` | row **TM⁺_f** | **PROVED** |
| 15 | `Metalogic.completeness_dedekind` | `StrongCompleteness.lean:469` | row **TM⁺_c** | **PROVED** (vs `ValidDedekindDense`) |
| 16 | `Metalogic.consequence_completeness_base` | `StrongCompleteness.lean:535` | — | **PROVED** (finite ctx) |
| 17 | `Metalogic.consequence_completeness_dense` | `StrongCompleteness.lean:639` | — | **PROVED** (finite ctx) |
| 18 | `Metalogic.consequence_completeness_discrete` | `StrongCompleteness.lean:746` | — | **PROVED** (finite ctx) |
| 19 | `Metalogic.consequence_completeness_dedekind` | `StrongCompleteness.lean:450` | — | **PROVED** (finite ctx) |
| 20 | `Metalogic.strongCompletenessDiscrete_refuted` | `DiscreteNonCompactness.lean:280` | contradicts nothing in paper | **PROVED (a refutation)** |
| 21 | `Metalogic.discrete_consequence_not_compact` | `DiscreteNonCompactness.lean` | — | **PROVED** |
| 22 | `Metalogic.strongCompletenessBase_of_compact` | `StrongCompleteness.lean:305` | paper's TM⁺ **strong** claim | **CONDITIONAL** — hypothesis `CompactBase` unproved |
| 23 | `Metalogic.strongCompletenessDense_of_compact` | `StrongCompleteness.lean:331` | paper's TM⁺_d **strong** claim | **CONDITIONAL** — hypothesis `CompactDense` unproved |
| 24 | `Metalogic.Decidability.sound_of_isValid` | `Decidability/Correctness.lean` | paper's decidability claim | **PROVED (one direction only)** |
| 25 | `Metalogic.Decidability.isValid_sound` | `Decidability/Correctness.lean` | " | **PROVED (one direction only)** |

**Absent from Lean entirely** (searched, not found):

- Unconditional **strong** completeness for `Base` or `Dense`. `CompactBase`/`StrongCompletenessBase`
  and `CompactDense`/`StrongCompletenessDense` (`Metalogic/SetConsequence.lean`) *name* the
  obligations; rows 22-23 above are the conditionals over them. No `CompactDedekind` exists.
- The **completeness direction** of decidability, `⊨ φ → isValid φ fc = true`; hence no
  `valid_iff_allClosed`, no `isValid ↔ ⊨` biconditional, and no `Decidable (⊨ φ)` instance.
  `Decidability/Correctness.lean` records `validity_decidable` and
  `validity_has_decision_procedure` as **retired as vacuous** — their proofs were instances of
  `Classical.em`.
- **BL-level (TM, not TM⁺) soundness.** `FormalSystem/BaseLanguage/` has `Formula.lean`,
  `Axioms.lean` (16 constructors, an exact transcription of the paper's TM), `Derivation.lean`,
  `Translation.lean`, `AxiomDischarge.lean` — but **no soundness theorem**. `grep -n 'soundness'
  FormalSystem/BaseLanguage/*.lean` returns nothing. The paper's `thm:TM-soundness` (4484) has no
  direct Lean counterpart; it would follow by composing `Conservativity.translate` with
  `Metalogic.soundness`, but that composition is not stated anywhere.

### F3. Paper drift against the pinned record — the gate is RED

`bash scripts/check-paper-definitions.sh` → **exit 1** (case (c), genuine drift).

```
[paper-definitions] FAIL: drift detected
  32 recorded definition(s) drifted
   6 recorded anchor(s) could not be resolved
```

Pinned checksum in the record: `f134fd7d460c08aaf94c5b1c09571ab2663c509d1ee32f2d31b89ee640281381`
(`specs/paper-definitions-of-record.md:60`, 4213 lines). Live paper: 4856 lines,
sha256 `5d700a2f05999bb6…`. The paper has grown ~643 lines since the last pin.

**The 6 dangling anchors**, with their real cause:

| Anchor | Cause (verified in live paper) |
|---|---|
| `def:frame#Compositionality` | `\item[\it X:]` → `\item[\bf X:]`; the `\aitem`/item resolver keys on the markup |
| `def:frame#Seriality` | same |
| `def:frame#Limit` | same |
| `def:frame#Spherical` | same |
| `thm:s4` | **removed** — replaced by a single `thm:s5` at line 2158 |
| `thm:sym` | **removed** — folded into `thm:s5` |

**The 32 drifted anchors**, triaged by whether the mathematics changed:

*Purely terminological — the `frame` → `task frame` rename* (20 anchors, no mathematical change):
`def:task-relation`, `lem:nullity`, `def:world-history`, `thm:extension`, `cor:occurrence`,
`def:constraints`, `lem:nesting`, `lem:nonempty`, `lem:admissible`, `lem:step`,
`def:BL-semantics`, `def:time-shift-histories`, `def:frame-validity`, `app:discrete`,
`app:dense`, `app:complete`, `cor:spherical-finite`, `cor:tm-completeness` (partly),
`thm:BLplus-NextPrevious` (partly), `def:frame` (partly).

*Cosmetic only* (`\vspace` retuning, `\it`→`\bf`, `\mathrm{Th}`→`\Th` macro): `def:S5`,
`def:BX`, `def:BLplus-semantics`, `def:TMplus-c`, `def:TMplus-f`.

*Substantive — the mathematics or the claim changed* (7):

| Anchor | Paper line | What changed | Lean impact |
|---|---|---|---|
| `def:directed` | 2804 | **Split** into `⊇-Directed` and `⊆-Directed`; previously one unqualified notion | Lean's `TaskFrame.DirectedFamily` (`Semantics/TaskFrame.lean:276`) is already the ⊇ form. **Extensionally still correct**; only verbatim quotes are stale. Lean has no ⊆-Directed counterpart. |
| `def:frame` | 2834 | *Spherical* now reads "`⊇`-directed family"; gained a footnote placing it as `S₁ᵈ` in the Ćmiel–Kuhlmann–Kuhlmann ball-space hierarchy, and stating it is **strictly stronger** than "spherically complete" (`S₁`) | Lean's `Spherical` (`TaskFrame.lean:343`) matches the ⊇ reading. The strictly-stronger-than-`S₁` remark is new information not recorded anywhere in the tree. |
| `def:frame-properties` | 3694 | **`Deterministic` clause removed**; now a standalone `def:deterministic` at 2868 | `FormalSystem/Examples/TemporalStructures.lean:219` asserts "`Deterministic` is a clause inside `def:frame-properties`" — now **false**. |
| `cor:tm-completeness` | 4657 | Gained a **new footnote** claiming the completeness *and* soundness results "have been established in the Lean 4 repository for this paper" | See D1/D2 — this is the sharpest over-claim. |
| `def:strongest` / `thm:exist` | 2134 / 2146 | "strongest objective **normal** modal operator" → "strongest objective modal operator" | No Lean counterpart (see F6). |
| `def:id` | 1823 | Substantially expanded: `p_i` reclassified as *propositional variables*; `LL⁻` gained an explicit free-for/operator-scope proviso plus footnote | No Lean counterpart. |
| `thm:extension` | 3128 | Footnote no longer says the proof appeals to Zorn "**and hence to the axiom of choice**" | Three in-tree sites quote the **old** text verbatim (see D12). |

Additionally, the paper has grown a **new appendix block** with no record coverage and no Lean
counterpart: `def:task-topology` (2872), `app:topology-t1` (2904), `app:topology-r0` (2923),
`app:gluing` (2976), `def:interval-site` (3208), `def:behavior-presheaf` (3233),
`lem:factorization-linear` (3247), `lem:interval-twisted-arrow` (3278),
`app:presheaf-dictionary` (3313), `def:path-category` (3386), `def:conduche` (3406),
`cor:path-fibration` (3510).

### F4. Dangling paper-anchor citations in live scope

Derived mechanically: all `\label{}` in the live paper (147 uncommented, 153 including
commented-out) vs. all `(def|thm|lem|cor|app|rmk):[A-Za-z0-9_-]+` citations under
`FormalSystem/`, `Tests/`, `docs/`, `typst/`, `latex/`, `README.md`, `CLAUDE.md`
(`Boneyard/` excluded).

| Anchor | Status in paper | Cites | Files |
|---|---|---|---|
| `lem:fibers` | **ABSENT** (retired 2026-08-17 wave 2, per record `:99-104`) | 17 | `FormalSystem/Semantics.lean`, `Semantics/Extension/{README.md,Constraint.lean,Step.lean,Admissible.lean,Extension.lean}` |
| `thm:ConservativeExtension` | **ABSENT** (never a paper label) | 5 | `Metalogic/Conservativity.lean`, `typst/chapters/p2-frame-classes.typ`, `typst/SYNC-MAP.md` |
| `cor:tm-decidability` | **COMMENTED OUT** in paper (4672-4688) | 4 | `Metalogic/Decidability/BiLasso/README.md`, `typst/SYNC-MAP.md`, `typst/chapters/p3-decidability-frontier.typ`, `typst/chapters/p2-decidability-practice.typ` |
| `app:valid` | **ABSENT** | 2 | `Metalogic/Soundness.lean` |
| `thm:occurrence` | **ABSENT** (renamed `cor:occurrence` in 2026-08-11 wave) | 1 | `Semantics/Extension/Extension.lean` |
| `app:nonempty` | **ABSENT** (merged into `cor:occurrence`) | 1 | `Semantics/Extension/Extension.lean` |

**30 citations across 14 distinct files.** Note the repository has no lint for this — C5/C12/C13
check *filesystem paths* and markdown links, not paper anchors. That is a gap worth closing.

### F5. Proof-system correspondence — paper ↔ `FormalSystem/ProofSystem/Axioms.lean`

Verified constructor-by-constructor against `def:S5` (4518), `def:BX` (4536), `def:TMplus-f`
(4585), `def:TMplus-d` (4605), `def:TMplus-c` (4622), `def:TMplus` (4645), and the TM system in
`sub:Logic` (1187-1199) / `sub:Extension` (1277-1281).

Both sides are **guard-first**: the paper's `φ ▷ ψ` puts the guard first
(`def:BLplus-semantics`, 3730-3737), and Lean's `Formula.untl guard event` matches
(`Syntax/Formula.lean:85-96`, per `specs/decisions/untl-snce-argument-order.md`). The `U(e,g)`
pretty-printed form is event-first and is a *printer* convention only
(`Automation/DataExport.lean:138`).

**Counts, all re-derived:** 45 constructors (`prop_k` at `Axioms.lean:103` … `sep` at `:452`);
Base 37, Dense 2, Discrete 3, Dedekind 3 (routing at `Axioms.lean:588-597`). 7 `DerivationTree`
constructors (`ProofSystem/Derivation.lean:98,105,111,129,146,155,164`).

**MATCH** (paper key → Lean constructor): `TMP-MT`→`modal_t`, `TMP-M5`→`modal_5_collapse`,
`TMP-MK`→`modal_k_dist`, `TMP-SE`→`serial_future`, `TMP-UG`→`left_mono_until_G`,
`TMP-UC`→`right_mono_until`, `TMP-CV`→`connect_future`, `TMP-SU`→`enrichment_until`,
`TMP-UF`→`self_accum_until`, `TMP-UI`→`absorb_until`, `TMP-CN`→`linear_until`,
`TMP-UE`→`until_F`, `TMP-LN`→`temp_linearity`, `TMP-MF`→`modal_future`,
`TMP-NP`→`discrete_symm_fwd`, `TMP-NF`→`discrete_propagate_fwd`,
`TMP-NA`→`discrete_propagate_bwd`, `TMP-NB`→`discrete_box_necessity`,
`TMP-UZ`→`prior_UZ`, `TMP-Z1`→`z1`, `TMP-DN`→`density`, `TMP-NN`→`dense_indicator`,
`TMP-PU`→`prior_U_gap`, `TMP-SEP`→`sep`. **Rules**: `TMP-MP`→`modus_ponens`,
`TMP-MN`→`necessitation`, `TMP-TN`→`temporal_necessitation`, `TMP-TD`→`temporal_duality`.

**`dense_indicator` is a MATCH, not a mismatch.** `Axioms.lean:369-370` is
`Axiom (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).neg` = `¬ untl(⊥, ⊤)`; the paper
defines `Xφ := ⊥ ▷ φ` (`def:BLplus-defined`, 3756), so `TMP-NN` = `¬X⊤` is literally the same
term. The docstring's `¬U(⊤,⊥)` is event-first printer notation. Only the *inlining* differs
(Lean writes `untl bot top` at five sites rather than using a `next` abbreviation).

**LEAN-ONLY, by design and not a defect** (13 past-mirror constructors the paper obtains via the
`TMP-TD` rule: `serial_past`, `left_mono_since_H`, `right_mono_since`, `connect_past`,
`enrichment_since`, `self_accum_since`, `absorb_since`, `linear_since`, `since_P`,
`temp_linearity_past`, `P_since_equiv`, `prior_SZ`, `prior_S_gap`; plus `discrete_symm_bwd`, the
TD-converse of `TMP-NP`; plus the 4 CPL constructors the paper leaves abstract; plus `modal_4`
and `modal_b`, redundant in S5 but used in proof scripts, cf. `Axioms.lean:283`).

**PAPER-ONLY, correctly derived rather than axiomatized**: `TMP-CO` →
`Theorems.DedekindDerived.co_derived`; `TK` → `TemporalDerived.temporalKDistDerived`; `T4` →
`TemporalDerived.temporal4Derived`; `DF` → `DiscreteUnfolding.dfSchema`; `TF`, `P1`-`P6`.

**TM (BL) vs TM⁺ (BL⁺) — the Lean tree does distinguish them.**
`FormalSystem/BaseLanguage/Formula.lean` defines `BLFormula` over the paper's BL exactly (`⊥`,
`→`, `□`, `allPast`, `allFuture`; no `untl`/`snce`), and `BaseLanguage/Axioms.lean:75-131` gives a
**16-constructor** `Axiom` inductive that is an exact transcription of the paper's TM
(MK, MT, M5, MF, TK, T4, TB, TA, TL + DF, DN, CO). The two systems are bridged one-way by
`Metalogic/Conservativity.lean` (`translate`, `derivable_translate`, and the four rows
`ceb_backward`/`cef_backward`/`ced_backward`/`cec_backward`); the forward direction is
**refuted** for Base and Discrete and **open** for the other two, documented at length at
`Conservativity.lean:31-60`.

### F6. Paper appendix sections with no Lean counterpart

Searched by concept, not by name:

| Paper section | Anchors | Lean counterpart |
|---|---|---|
| `app:ObjectiveModality` (1810-2247) | `def:id`, `def:lang`, `def:qe`, `def:key-terms`, `def:opost`, `lem:trans`, `def:rel-model`, `lem:rel-model`, `def:norm`, `lem:obj-norm`, `def:strongest`, `thm:exist`, `thm:s5`, `lem:uniq`, `cor:S5`, `rmk:collapse` | **NONE.** `grep -rn 'objective modal\|strongest objective\|propositional identity' FormalSystem/ -l` → empty. |
| `app:TwoDimensional` (2248-2758) | `def:two-dimensional-model`, `def:global-language`, `def:satisfaction`, `def:bisimulation`, `lem:Lprime-bisim`, `app:expressive`, `def:assignment`, `lem:box-definable`, `app:invalid`, `def:abundant`, `app:frame-impossible`, `app:abundant`, `app:unbounded` | **NONE.** `grep -rn 'bisimulation\|two-dimensional\|abundant' FormalSystem/ -l` → empty. (Note: `def:order-automorphism`/`def:time-shifted`/`lem:time-shift-invariance` *do* have partial counterparts — `Semantics/WorldHistory.lean:262-370`, `Semantics/Truth.lean:457` `time_shift_preserves_truth`, `Semantics/PartialHistoryOrder.lean:121-165`.) |
| Topology / presheaf / Conduché block (2872-3565) | `def:task-topology`, `app:topology-t1`, `app:topology-r0`, `def:interval-site`, `def:behavior-presheaf`, `lem:factorization-linear`, `lem:interval-twisted-arrow`, `app:presheaf-dictionary`, `def:path-category`, `def:conduche`, `cor:path-fibration` | **NONE.** `grep -rn 'Conduche\|presheaf\|twisted arrow' FormalSystem/ -l` returns 4 files, all incidental prose (`Semantics/TaskFrame.lean` uses "topology" descriptively). |

These three blocks are roughly **1,500 of the paper's 4,856 lines**. `possible_worlds.tex:1801`
— "The results throughout are formalized in Lean 4 in the repository" — sits at the *opening of
the Appendix*, so it scopes over all of them.

### F7. `README.md` accuracy audit

**Correct — verified, no discrepancy:**

| Claim | Line | Verification |
|---|---|---|
| Lean files 539 | 19 | `cloc --include-lang=Lean --exclude-dir=.lake,lake-packages,Boneyard .` → **539** ✓ (this includes the 71 `.lean` files under `specs/`; the "413 live" figure at line 91 is the `FormalSystem/` subset, and both are consistent) |
| ~170,898 LOC / ~96,290 comment | 20-21 | cloc → **170,898 / 96,290** ✓ exactly |
| 5 primitive connectives | 33 | `Formula` has 6 constructors, of which `atom` is not a connective: `bot, imp, box, untl, snce` = **5** ✓; matches `def:BLplus-language` (3718) |
| Derived operator definitions | 45-60 | ✓ against `Syntax/Formula.lean:134-616`, except `▽` (see below) |
| Atom clause `x ∈ dom(τ)` | 72 | ✓ `Semantics/Truth.lean:161` |
| Box clause over all histories | 75 | ✓ `Truth.lean:164` (`σ.IsTotal`) |
| U/S truth clauses (notation reading) | 76-77 | ✓ `Truth.lean:165-168` |
| 413 live `.lean` in `FormalSystem/` | 91 | ✓ C7: `413 FormalSystem / 53 Tests`, 569 total, 156 archived |
| 156 archived files | 110 | ✓ C7 |
| 45 constructors, nine layers | 95, 175, 209 | ✓ counted 45 |
| Layer breakdown 4+5+18+4+1+5 = 37 | 175 | ✓ |
| Base 37 / Dense 39 / Discrete 40 / Dedekind 42 | 156-173 | ✓ from `Axiom.minFrameClass` (`Axioms.lean:588-597`) |
| Sorry-free, exactly `[propext, Classical.choice, Quot.sound]` | 144 | ✓ **independently re-verified on 25 theorems** |
| Strong completeness: Discrete refuted, Base/Dense open, Dedekind not stated | 148-150 | ✓ against `DiscreteNonCompactness.lean:280`, `SetConsequence.lean`, and absence of `CompactDedekind` |
| Dedekind stated vs `ValidDedekindDense` | 152 | ✓ `StrongCompleteness.lean:469` |
| Decidability one-directional; `validity_decidable` retired as vacuous | 181-201 | ✓ |

**Wrong — needs fixing:**

| Line(s) | Claim | Reality |
|---|---|---|
| 3, 133-134, 250 | Repository is `github.com/benbrastmckie/**ProofChecker**` (CI badge, `git clone`, `@software` citation `url`) | `git remote -v` → `git@github.com:benbrastmckie/**BimodalLogic**.git`. The paper cites `BimodalLogic` in 8 places. The CI badge URL is therefore also broken. |
| 66 | "a **task relation** … satisfying **three** constraints: *nullity*, *compositionality*, and *reflection*" | `structure TaskFrame` (`Semantics/TaskFrame.lean:474-580`) has **seven** fields: `nonempty`, `nullity_identity`, `comp`, `converse`, `serial`, `limit`, `spherical`. The README omits *Seriality*, *Limit* and *Spherical* — **three of the paper's four `def:frame` axioms** — and calls `converse` "reflection". |
| 42-43 | `U(φ,ψ)` → Lean constructor `untl φ ψ`; `S(φ,ψ)` → `snce φ ψ` | Guard-first migration inverted this. `U(e,g)` is event-first notation, `untl` is guard-first, so `U(φ,ψ)` is `untl ψ φ`. The *notation* column and the truth clauses at 76-77 are right; only the "Lean Constructor" column is wrong. |
| 179 | "the paper's TM⁺_c is completeness *simpliciter* — no density binder — so its models are exactly `{ℤ, ℝ}` … **No element of `FrameClass` picks that class out**" | **Stale.** The live `cor:tm-completeness` (4664) now reads "**TM⁺_c** Weakly complete over the **dense-and-complete** class", and the `{ℤ,ℝ}`/`Th(ℤ)∩Th(ℝ)` footnote in `def:TMplus-c` is **commented out** (4635-4640). Under the paper's current text, `FrameClass.Dedekind` **is** TM⁺_c. |
| 81 | Paper URL `benbrastmckie.com/wp-content/uploads/2026/07/possible_worlds.pdf` | Inconsistent with line 11 and line 243, which both use `benbrastmckie.com/publications/possible-worlds.pdf` / `possible_worlds.pdf`. Three different URLs for one paper. |

**Minor / cosmetic:**

- Line 58: `▽φ` defined as `¬△¬φ`, matching Lean (`Formula.lean:616`). The paper's
  `def:BLplus-defined` (3755) gives the explicit disjunction `▷φ ∨ φ ∨ ◁φ`. Classically
  equivalent; term-distinct.
- Line 13: "(outdated)" annotation on `latex/BimodalReference.pdf` — accurate but the file is
  still linked as **Specification** in the header.

### F8. Sub-README and in-tree docstring accuracy

| File:line | Claim | Reality |
|---|---|---|
| `FormalSystem/ProofSystem/Axioms.lean:58` | "**Total**: 42 axiom constructors (32 base + 5 uniformity + 2 prior + 1 Z1 + 2 density)" | **45**, and the sum shown (32+5+2+1+2) = 42 ≠ 45 |
| `FormalSystem/ProofSystem/Axioms.lean:84` | "**42 constructors** organized into eight layers" | **45**, nine layers |
| `FormalSystem/Metalogic/Decidability/ProofExtraction.lean:27` | "all **42** axiom schemata" | 45 |
| `FormalSystem/Automation/ProofSearch/Core.lean:322` | "all **42** axioms are implications or negations" | 45 |
| `FormalSystem/Automation/Tactics/Helpers.lean:33`, `:1103` | "All **42** axiom constructors across 8 layers" / "(42 constructors)" | 45, 9 layers |
| `FormalSystem/Automation/Tactics/Commands.lean:454` | "resolve all **42** axiom constructors" | 45 |
| `FormalSystem/README.md:181-186` | Repeats the stale TM⁺_c "no frame class here" claim | See F7 line 179 |
| `FormalSystem/README.md:357` | "*Last verified: 2026-05-29*" | Stale by ~3 months |
| `FormalSystem/Examples/TemporalStructures.lean:219` | "`Deterministic` is a clause inside `def:frame-properties`" | Paper removed it; now standalone `def:deterministic` (2868) |
| `FormalSystem/Semantics/Extension/Extension.lean:30`, `:190` | Quotes `thm:extension`'s footnote **verbatim**: "appeals to Zorn's lemma **and hence to the axiom of choice**" | Paper's live text dropped that clause and restructured the sentence |
| `Tests/BimodalTest/Semantics/SphericalFiniteAxiomTest.lean:290` | Same stale verbatim quote | Same |
| `FormalSystem/Semantics/TaskFrame.lean:39`, `Semantics/FrameAxioms.lean:129` | Quote `lem:nullity` verbatim as "in every **frame**" | Paper now says "in every **task frame**" |
| `latex/README.md` (end) | "*Last Updated: 2026-03-16*" | Stale |

`docs/reference/axiom-reference.md:5-16` correctly says **45 constructors** with the
37/2/3/3 split, and correctly names `Axiom.minFrameClass` as authoritative. `Tests/README.md`
and `latex/README.md` make no quantitative claims. Check **C14** already lints documented
axiom/sorry counts, but its scope is `docs/` + `README.md` only — which is exactly why the six
stale "42"s in `.lean` docstrings survive.

### F9. Typst manual — `typst-sync-check.sh` is RED

```
== Check 1: backtick name resolution ==   TOTAL_VIOLATIONS=0  TOTAL_CANDIDATES=563
== Check 2: count freshness ==            MISMATCH_COUNT=3
  VIOLATION: sorry-total:                committed=5  live=4
  VIOLATION: sorry-total-excl-boneyard:  committed=1  live=0
  VIOLATION: sorry-table[WeakCanonical/]: committed=5  live=4
== Check 3: machine appendix freshness == MA_COUNT_MISMATCHES=0
typst-sync-check.sh: FAIL
```

`typst/generated/status.typ` is stamped `08927bc5e (2026-08-17)` and asserts **1** sorry outside
`Boneyard/`; the tree has **0**. The fix is mechanical: re-run `scripts/typst-status-counts.sh`
and commit the regenerated file. (This report's investigation regenerated it and then restored the
committed content; the working tree is unchanged.)

`typst/chapters/02-semantics.typ:122,128,227,255` and `typst/FormalFoundations.typ:219` quote
"directed family" without the `⊇` qualifier the paper now carries.

### F10. Semantics correspondence — extensional check

`def:frame` (2834) has four axioms; `def:task-relation` (2776) adds the converse convention and
a nonempty `W`. Against `structure TaskFrame` (`Semantics/TaskFrame.lean:474-580`):

| Paper | Lean field | Definition site | Verdict |
|---|---|---|---|
| `W` nonempty (`def:task-relation`) | `nonempty : Nonempty WorldState` | `:492` | **MATCH** |
| *Compositionality* (biconditional, `x,y ≥ 0`) | `comp : TaskFrame.Compositional TaskRel` | `:533`, def at `:400-401` | **MATCH**, both directions; `Interpolates` (`:376`) and `forward_comp` project the halves |
| converse convention `w ⇒₋ₓ u ≔ u ⇒ₓ w` | `converse : ∀ w d u, TaskRel w d u ↔ TaskRel u (-d) w` | `:549` | **MATCH** |
| *Seriality* | `serial : TaskFrame.Serial TaskRel` | `:556`, def at `:358-359` | **MATCH** |
| *Limit* `⋂_{x>0}(w)_x = {w}` | `limit : ∀ w u, (∀ x, 0 < x → ∃ y, \|y\| < x ∧ TaskRel w y u) → u = w` | `:566` | **MATCH extensionally.** Lean states only the `⊆` half; the `⊇` half (`w ∈` every cone) is immediate from `nullity_identity` giving `TaskRel w 0 w` with `\|0\| < x`. |
| *Spherical* (`⊇`-directed family of nonempty fibers and segments) | `spherical : TaskFrame.Spherical TaskRel` | `:577`, def at `:343-345`, with `DirectedFamily` at `:276-277`, `IsFiber` at `:284`, `IsSegment` | **MATCH.** `DirectedFamily S := S.Nonempty ∧ ∀ S₁ S₂ ∈ S, ∃ S' ∈ S, S' ⊆ S₁ ∩ S₂` is precisely the paper's new `⊇-Directed`. |
| — (no paper counterpart) | `nullity_identity : ∀ w u, TaskRel w 0 u ↔ w = u` | `:511` | **STRICTLY STRONGER than the paper.** `lem:nullity` (2889) is a *derived* result asserting only reflexivity (`w ⇒₀ w`), choice-free, from *Seriality* at `x = 0` plus *Limit*. Lean's iff additionally asserts injectivity-at-zero. This is already flagged in-tree as an **OPEN DESIGN QUESTION** with three live options at `TaskFrame.lean:501-509`. |

Truth clauses (`Semantics/Truth.lean:161-168`) match `def:BL-semantics` (3566) and
`def:BLplus-semantics` (3730) clause for clause, with one deliberate documented divergence: Lean's
atom clause carries a domain conjunct (`∃ ht : τ.domain t, …`) that `def:BL-semantics`'s atom
clause has no counterpart for; `Truth.lean:133` records that under totality the conjunct is
vacuous. **Not a defect.**

### F11. Two axiom constructors are definitionally vacuous

`Formula.top := Formula.bot.imp Formula.bot` (`Syntax/Formula.lean:134`) and
`Formula.someFuture φ := Formula.untl Formula.top φ` (`:147`). Therefore
`F_until_equiv` (`Axioms.lean:270-271`), stated as
`(Formula.someFuture φ).imp (Formula.untl (Formula.bot.imp Formula.bot) φ)`, is
`X.imp X` — the two sides are the *same term*. Verified:

```lean
example (φ : Formula) : (Formula.someFuture φ) = (Formula.untl (Formula.bot.imp Formula.bot) φ) := rfl  -- typechecks
example (φ : Formula) : (Formula.somePast φ)   = (Formula.snce (Formula.bot.imp Formula.bot) φ) := rfl  -- typechecks
```

Both `rfl`s typecheck (`lake env lean` on the scratch file produced no output). So
`F_until_equiv` and `P_since_equiv` are **dead weight**: 2 of the 37 Base constructors carry no
content. The paper has the identical degeneracy — `TMP-UT` is `Fφ → (⊤ ▷ φ)` (4558) while
`def:BLplus-defined` (3751) sets `▷φ ≔ ⊤ ▷ φ`. Neither side is *wrong*; both are stating an
identity as an axiom.

## Decisions

- **The paper is read-only.** Per `specs/paper-definitions-of-record.md`, this repository never
  edits `possible_worlds.tex`. Every "change paper?" resolution below is therefore a
  **recommendation to the author**, to be surfaced as a written finding, not an edit.
- **Direction of correction is asymmetric.** Where the paper claims *more* than the tree proves
  (D1-D4), the correct fix is to weaken the paper's claim — **not** to open a research programme
  to make the claim true. Where the tree's *documentation* is behind (D11-D22), the fix is to
  update the tree.
- **The pinned record must be re-pinned before anything else.** With 32 drifted anchors, any
  further paper-citing work in this repository is being done against a stale baseline.
- **`nullity_identity` stays as-is.** `TaskFrame.lean:501-509` deliberately defers this to a joint
  decision with the consequence-refactor work. This report does not reopen it; it records it.

## Discrepancy Inventory

Severity: **BLOCKING** = a published claim is false as stated; **SUBSTANTIVE** = materially
misleading or a real content gap; **COSMETIC** = accurate-but-stale wording or stamps.

| ID | Axis | Paper says | Lean/docs actually | Sev | Resolution direction |
|---|---|---|---|---|---|
| D1 | Metatheorem | **TM⁺ strongly complete over all task frames**, "established in the Lean 4 repository" (`:4661`, `:4668`) | Weak + finite-context only. Infinitary strong completeness is **open**: `strongCompletenessBase_of_compact` is conditional on unproved `CompactBase` (`StrongCompleteness.lean:305`; `README.md:149`) | **BLOCKING** | **Change paper** — weaken to weak/finite-context, or drop the Lean attribution for this row |
| D2 | Metatheorem | **TM⁺_d strongly complete over dense task frames**, same attribution (`:4662`) | Same: conditional on unproved `CompactDense` (`StrongCompleteness.lean:331`) | **BLOCKING** | **Change paper** |
| D3 | Metatheorem | "making **TM⁺ decidable** as implemented in the Lean 4 repository" (`:1706`) | Sound direction only; completeness direction open; `Decidable (⊨ φ)` unavailable; `validity_decidable` **retired as vacuous** (`README.md:181-201`). The paper's own commented-out proof at `:4683` says "no decidability theorem is machine-checked at present" | **BLOCKING** | **Change paper** — `:1706` contradicts `:4683`; reconcile to the `:4683` wording |
| D4 | Metatheorem | "The results **throughout** are formalized in Lean 4 in the repository" (`:1801`) | `app:ObjectiveModality`, `app:TwoDimensional`, and the topology/presheaf/Conduché block (~1,500 lines) have **no** Lean counterpart (F6) | **BLOCKING** | **Change paper** — scope the claim to the task-semantics + soundness/completeness material |
| D5 | Metatheorem | `thm:TM-soundness` (`:4484`) soundness of **TM** over BL, "formalized in the Lean 4 repository" (`:4311`, `:4494`) | No BL-level soundness theorem exists. `BaseLanguage/` has syntax, 16 axioms, derivations, translation — no soundness. Would follow by composing `Conservativity.translate` with `Metalogic.soundness`, but that composition is unstated | **SUBSTANTIVE** | **Change Lean** — state `BaseLanguage` soundness as the composite (small, mechanical); *or* change paper to attribute TM⁺ soundness only |
| D6 | Proof system | `def:TMplus-c` bases BX_c on `TMP-PU` + `TMP-SEP` only, **no density axiom** (`:4622`) | `FrameClass.Dedekind` = 42 axioms = Base 37 + `density` + `dense_indicator` + the 3 Reynolds axioms; `Dense ≤ Dedekind` (`Axioms.lean:588-597`, `FormalSystem/README.md:166-180`) | **SUBSTANTIVE** | **Document the mismatch** — the paper's TM⁺_c as axiomatized is weaker than Lean's Dedekind system, yet `cor:tm-completeness` claims completeness over the dense-and-complete class. Either the paper adds `TMP-DN`/`TMP-NN` to BX_c, or the tree records that `completeness_dedekind` proves a *different* (stronger-premise) statement |
| D7 | Docs | (paper: TM⁺_c weakly complete over the **dense-and-complete** class, `:4664`) | `README.md:179` and `FormalSystem/README.md:181-186` assert the paper's TM⁺_c is "completeness *simpliciter*", models `{ℤ,ℝ}`, and that **no** `FrameClass` picks it out. The `{ℤ,ℝ}` footnote is now **commented out** in the paper (`:4635-4640`) | **SUBSTANTIVE** | **Change docs** — the "gap worth naming" is no longer a gap under the paper's current text |
| D8 | Record | (paper moved: 32 anchors drifted, 6 dangling) | `scripts/check-paper-definitions.sh` **exits 1**. Pinned checksum `f134fd7d…` / 4213 lines vs live `5d700a2f…` / 4856 lines | **BLOCKING** (gate red) | **Change record** — re-quote and re-hash all 32; retire `thm:s4`/`thm:sym`; re-resolve the four `def:frame#*` item anchors against `\bf`; re-pin the checksum sentinels |
| D9 | Record | `def:directed` **split** into `⊇-Directed` / `⊆-Directed` (`:2804`) | `TaskFrame.DirectedFamily` (`:276`) is already ⊇; **no semantic change**. 10+ verbatim quotes say plain "directed family" | **SUBSTANTIVE** (quote fidelity) | **Change record + Lean/typst quotes**; consider whether ⊆-Directed is load-bearing anywhere |
| D10 | Semantics | `def:frame`'s *Spherical* footnote now places it as `S₁ᵈ` in the ball-space hierarchy and says it is **strictly stronger** than "spherically complete" (`S₁`) | Not recorded anywhere in the tree | **COSMETIC** | **Change Lean docstring** — add the ball-space characterization to `TaskFrame.lean:343` |
| D11 | Semantics | `def:frame-properties` no longer contains **Deterministic**; standalone `def:deterministic` at `:2868` | `FormalSystem/Examples/TemporalStructures.lean:219` says it *is* a clause inside `def:frame-properties` | **SUBSTANTIVE** | **Change Lean docstring** |
| D12 | Semantics | `thm:extension` footnote dropped "**and hence to the axiom of choice**" (`:3128`) | Quoted verbatim as the old text at `Semantics/Extension/Extension.lean:30`, `:190`, `Tests/BimodalTest/Semantics/SphericalFiniteAxiomTest.lean:290` | **SUBSTANTIVE** | **Change Lean docstrings** — re-quote |
| D13 | Record | `frame` → **`task frame`** globally (20 anchors) | `Semantics/TaskFrame.lean:39`, `Semantics/FrameAxioms.lean:129` and others quote "in every frame" verbatim | **COSMETIC** | **Change record + Lean quotes** |
| D14 | Record | `thm:s4` / `thm:sym` **removed**, replaced by `thm:s5` (`:2158`) | Record manifest rows `:1190-1191` are dangling | **SUBSTANTIVE** | **Change record** — retire both, add `thm:s5` |
| D15 | Record | `def:strongest` / `thm:exist` dropped "**normal**" (`:2134`, `:2146`) | Record holds the "normal" text | **COSMETIC** | **Change record** |
| D16 | Anchors | `lem:fibers` **removed from the paper** | Cited **17×** across 6 files under `FormalSystem/Semantics/` (F4) | **SUBSTANTIVE** | **Change Lean** — repoint to a live anchor or to the record's DANGLING entry |
| D17 | Anchors | `cor:tm-decidability` is **fully commented out** (`:4672-4688`) | Cited **4×**: `Decidability/BiLasso/README.md`, `typst/SYNC-MAP.md`, `typst/chapters/p3-decidability-frontier.typ`, `p2-decidability-practice.typ` | **SUBSTANTIVE** | **Change docs** — cite the paper's commented text as an unpublished remark, or drop |
| D18 | Anchors | `thm:ConservativeExtension` / `app:valid` / `app:nonempty` / `thm:occurrence` do not exist | Cited 5× / 2× / 1× / 1× | **SUBSTANTIVE** | **Change Lean/typst** — `thm:occurrence`→`cor:occurrence`; `app:nonempty` merged into `cor:occurrence`; the other two appear to be invented anchors |
| D19 | Docs | (paper cites `github.com/benbrastmckie/**BimodalLogic**` 8×) | `README.md:3,133-134,250` say `**ProofChecker**`; `git remote -v` → `BimodalLogic` | **SUBSTANTIVE** | **Change docs** — CI badge is broken, clone instruction is wrong, citation URL is wrong |
| D20 | Docs | (paper `def:frame` has 4 axioms + nonempty W + converse) | `README.md:66` names only **three** constraints ("nullity, compositionality, reflection"); `TaskFrame` has **seven** fields | **SUBSTANTIVE** | **Change docs** |
| D21 | Syntax | (both sides guard-first) | `README.md:42-43` map `U(φ,ψ)` → `untl φ ψ`; correct is `untl ψ φ` (guard-first constructor vs event-first notation) | **SUBSTANTIVE** | **Change docs** |
| D22 | Docs | — | Six in-tree sites say "**42** axiom constructors" (`Axioms.lean:58`, `:84`; `Decidability/ProofExtraction.lean:27`; `Automation/ProofSearch/Core.lean:322`; `Automation/Tactics/Helpers.lean:33`, `:1103`; `Automation/Tactics/Commands.lean:454`); actual is **45** | **SUBSTANTIVE** | **Change Lean docstrings**, and **extend check C14** to `.lean` docstrings (it currently scans only `docs/` + `README.md`) |
| D23 | Build | — | `scripts/typst-sync-check.sh` **FAILS**: `typst/generated/status.typ` claims `sorry-total=5`, `excl-boneyard=1`; live is `4`/`0` | **SUBSTANTIVE** | **Change docs** — re-run `scripts/typst-status-counts.sh`, commit |
| D24 | Proof system | `TMP-UT` `Fφ → (⊤▷φ)` (`:4558`) — vacuous given `def:BLplus-defined:3751` | `F_until_equiv` / `P_since_equiv` are **definitionally `X → X`** (verified by `rfl`); 2 of 37 Base constructors carry no content | **SUBSTANTIVE** | **Both** — report to the author; consider removing the two Lean constructors (a 45→43 change touching axiom counts everywhere, so scope carefully) |
| D25 | Semantics | `lem:nullity` (`:2889`) **derives** reflexivity from Seriality + Limit; no Nullity axiom | `TaskFrame.nullity_identity` is a primitive **iff** — strictly stronger (injectivity-at-zero) | **SUBSTANTIVE** | **Deliberately deferred** — `TaskFrame.lean:501-509` records three live options and defers to the consequence-refactor decision. Do **not** settle here. |
| D26 | Docs | — | `FormalSystem/README.md:357` "Last verified: 2026-05-29"; `latex/README.md` "Last Updated: 2026-03-16"; `README.md:81` uses a third, different paper URL | **COSMETIC** | **Change docs** |
| D27 | Syntax | `▽φ ≔ ▷φ ∨ φ ∨ ◁φ` (`:3755`) | Lean `sometimes φ := φ.neg.always.neg` (`Formula.lean:616`); `README.md:58` matches Lean | **COSMETIC** | **No change** — classically equivalent; optionally note the term-level divergence |

### Explicit "no discrepancy found"

- **Syntax / primitives.** Paper `def:BLplus-language` (`:3718`) `⟨SL, ⊥, →, □, since, until⟩`
  vs Lean `Formula` (`Syntax/Formula.lean:76-106`): exact match on the 5 primitives + atoms.
  Derived operators `past`/`future`/`Past`/`Future`/`always`/`Next`/`Previous`
  (`def:BLplus-defined`) match `somePast`/`someFuture`/`allPast`/`allFuture`/`always`/`next`/`prev`
  term-for-term. Argument order agrees (both guard-first).
- **Axiom-schema formulas.** Every `MATCH` in F5 was checked at formula level, not name level.
  In particular `dense_indicator` = `TMP-NN`, and `linear_until` = `TMP-CN` (guards `φ∧χ`, events
  `ψ∧θ`/`ψ∧χ`/`φ∧θ` agree; only `∨`-association differs).
- **Inference rules.** All four paper rules (`TMP-MP`, `TMP-MN`, `TMP-TN`, `TMP-TD`) have exact
  Lean counterparts; the extra three `DerivationTree` constructors (`axiom`, `assumption`,
  `weakening`) are structural.
- **TM vs TM⁺ separation.** `BaseLanguage/Axioms.lean:75-131` is an exact 16-constructor
  transcription of the paper's TM; the four paper systems are the four `FrameClass` instantiations.
- **Frame-axiom extensional agreement.** Compositionality, Seriality, Limit, Spherical all match
  extensionally (F10), including the ⊇-directedness the paper only recently made explicit.
- **Sorry inventory and axiom dependencies.** Zero structural sorries; 25/25 theorems at exactly
  `[propext, Classical.choice, Quot.sound]`. `README.md:144` is correct.
- **All README numeric claims** (539 / 170,898 / 96,290 / 413 / 156 / 45 / 37 / 39 / 40 / 42 /
  4+5+18+4+1+5) verified correct.
- **`docs/reference/axiom-reference.md`** correctly states 45 with the 37/2/3/3 split.
- **`Tests/README.md`, `latex/README.md`** make no quantitative or status claims that could be
  wrong.
- **`lake build`**: clean, exit 0, no errors, no sorry warnings.

### Axes examined but not exhaustively — named, not silently omitted

- **`docs/README.md` (412 lines) and `data/README.md` (307 lines)** were grepped for
  quantitative/status claims (none found beyond generic "complete implementation" wording at
  `docs/README.md:16,204,209`) but were **not read line by line**.
- **`latex/BimodalReference.tex`** and its subfiles were **not examined**. `README.md:13` already
  marks the PDF "(outdated)"; a decision about whether to retire or refresh it is out of scope here.
- **`typst/` chapters** were checked for dangling anchors and stale counts, but their *prose
  claims* about the Lean tree were **not audited claim-by-claim**. `typst/SYNC-MAP.md` is itself
  marked "historical record".
- **The paper's main-body prose** (`§sec:Introduction` through `§sec:TenseModality`, lines 1-1810)
  was searched only for Lean/repository/formalization claims. Its mathematical content outside the
  anchored definitions was **not** compared to the tree.
- **The paper's new topology / presheaf / Conduché appendix** was established to have no Lean
  counterpart by concept-level grep; its *content* was not read in detail.
- **`Tests/BimodalTest/` (53 files)** were not audited against the paper.
- **The paper's bibliography** and citation accuracy were not examined.
- **`metalogic.tex` and `missing.md`** — confirmed **not** `\input` by `possible_worlds.tex`, so
  deliberately out of scope.

## Recommendations

Prioritized and sized into implementable chunks. Chunk sizes target one agent run each.

**P0 — Re-baseline the paper record (blocks everything else).**

1. **Re-pin `specs/paper-definitions-of-record.md`.** Re-quote and re-hash all 32 drifted anchors;
   re-resolve the four `def:frame#*` item anchors against `\bf`; retire `thm:s4`/`thm:sym` as
   DANGLING and add `thm:s5`; re-pin `FILE_CHECKSUM`/`LINE_COUNT`/`PINNED_COMMIT`; write a new
   "Drift correction (2026-08-25)" section following the file's own established convention.
   Add the paper's new anchors (`def:deterministic`, `def:task-topology`, the presheaf block) only
   if they become load-bearing. **Gate**: `scripts/check-paper-definitions.sh` exits 0.
   *Size*: 1 run, `specs/` only.

**P1 — Report the paper's over-claims to the author (no repo edit).**

2. **Produce a findings memo** covering D1-D5 and D24: the strong-completeness attribution
   (`:4661-4670`), the decidability claim (`:1706` vs `:4683`), the blanket formalization claim
   (`:1801`), `thm:TM-soundness` (`:4311`, `:4494`), the BX_c/Dedekind axiom-basis mismatch (D6),
   and the `TMP-UT` vacuity. Each with the exact paper line and the exact Lean counter-evidence.
   The paper is read-only from here — this is a deliverable, not an edit.
   *Size*: 1 run, `specs/` only.

**P2 — Fix `README.md` (highest reader-facing impact).**

3. **Repository URL** (D19): fix lines 3, 133-134, 250 to `benbrastmckie/BimodalLogic`; verify the
   CI badge resolves. Also reconcile the three different paper URLs (lines 11, 81, 243).
4. **Task-frame description** (D20): rewrite line 66 to name all six constraints, using the
   paper's names (Compositionality, Seriality, Limit, Spherical) plus `converse` and
   `nullity_identity`, and note the last as a documented strengthening.
5. **Operator table** (D21): fix the "Lean Constructor" column at lines 42-43 to `untl ψ φ` /
   `snce ψ φ`, with a one-line note that the `U(…)`/`S(…)` notation is event-first.
6. **TM⁺_c "gap"** (D7): rewrite `README.md:179` and `FormalSystem/README.md:181-186` against the
   paper's current `cor:tm-completeness`.
   *Size*: 1 run, `README.md` + `FormalSystem/README.md`.

**P3 — Fix stale in-tree counts and stamps.**

7. **The six "42"s** (D22) → 45 / nine layers, and fix `Axioms.lean:58`'s parenthetical sum.
8. **Extend check C14** to scan `.lean` docstrings for axiom-count claims, so this cannot recur.
9. **Regenerate `typst/generated/status.typ`** (D23) via `scripts/typst-status-counts.sh`; commit.
   **Gate**: `scripts/typst-sync-check.sh` exits 0.
10. Refresh the stale `Last verified` / `Last Updated` stamps (D26).
    *Size*: 1 run for 7+9+10; 1 run for 8.

**P4 — Repair dangling paper-anchor citations.**

11. **`lem:fibers` ×17** (D16) across `FormalSystem/Semantics.lean` and
    `Semantics/Extension/{README.md,Constraint.lean,Step.lean,Admissible.lean,Extension.lean}`:
    repoint to the record's DANGLING entry or to the live neighbouring anchor.
12. **`thm:occurrence`, `app:nonempty`, `app:valid`, `thm:ConservativeExtension`,
    `cor:tm-decidability`** (D17-D18): 13 citations across 8 files.
13. **Add a lint** — a C15-style check that every `(def|thm|lem|cor|app|rmk):slug` citation in
    non-`specs/` scope resolves to a live `\label{}` in the pinned paper. This is the mechanism
    that would have caught all 30 at write time.
    *Size*: 1 run for 11+12; 1 run for 13.

**P5 — Refresh verbatim paper quotations.**

14. **`thm:extension` footnote** (D12) at `Extension.lean:30`, `:190`,
    `SphericalFiniteAxiomTest.lean:290`.
15. **`frame` → `task frame`** in verbatim quotes (D13) at `TaskFrame.lean:39`,
    `FrameAxioms.lean:129`, and the ~20 other quote sites.
16. **"directed family" → "⊇-directed family"** (D9) in Lean docstrings and
    `typst/chapters/02-semantics.typ:122,128,227,255`, `typst/FormalFoundations.typ:219`.
17. **`Deterministic`** (D11) at `Examples/TemporalStructures.lean:219`.
18. **Ball-space footnote** (D10): add the `S₁ᵈ` characterization to `TaskFrame.lean:343`.
    *Size*: 1 run for 14+17+18; 1 run for 15+16 (mechanical, wide).

**P6 — Optional Lean work (only if the author confirms).**

19. **State `BaseLanguage` soundness** (D5) as the composite of `Conservativity.translate` and
    `Metalogic.soundness`, giving the paper's `thm:TM-soundness` a direct Lean counterpart.
    This is small and mechanical, and would convert a BLOCKING paper over-claim into a true one.
20. **Retire `F_until_equiv` / `P_since_equiv`** (D24). Deliberately **last**: it changes 45→43
    and touches every axiom count in `README.md`, `docs/reference/axiom-reference.md`,
    `typst/generated/status.typ`, check C14's baseline, and the six stale docstrings from P3.
    Do **not** bundle this with P3.

**Explicitly NOT recommended**: attempting to prove `CompactBase`/`CompactDense` to make D1/D2
true. Strong completeness for Base and Dense is a genuine open research problem
(`README.md:149`), and it is already **refuted** for Discrete
(`strongCompletenessDiscrete_refuted`). The correct resolution is a paper correction.

## Risks & Mitigations

- **Risk**: the paper drifts *again* mid-implementation — it has done so at least six times, twice
  while a dispatch was in flight (`specs/paper-definitions-of-record.md:24-40`, `:78-99`).
  **Mitigation**: re-run `scripts/check-paper-definitions.sh` at the start **and end** of every
  phase; make P0's re-pin the first phase so later phases have a fresh baseline.
- **Risk**: the D24 axiom-count change (45→43) collides with the P3 docstring fix (42→45).
  **Mitigation**: P3 and P6.20 must not be in the same plan; P6.20 is explicitly deferred behind
  author confirmation.
- **Risk**: a plan reads D1/D2 as an invitation to prove strong completeness. **Mitigation**: the
  "Explicitly NOT recommended" note above, plus the zero-debt policy — a `sorry`ed
  `StrongCompletenessBase` would be debt on an open problem.
- **Risk**: mass verbatim-quote edits (P5.15/16) touch ~20-30 sites and could silently change a
  docstring's meaning. **Mitigation**: quote only from the re-pinned record produced by P0, never
  from the live paper directly; re-run `check-module-invariants.sh` after.
- **Risk**: fixing the CI badge URL exposes a genuinely failing or nonexistent workflow.
  **Mitigation**: check `.github/workflows/ci.yml` exists and the badge resolves before committing.

## Appendix

**Commands run and their headline results**

| Command | Result |
|---|---|
| `lake build` | exit 0, 2493 jobs, 0 errors, 0 sorry warnings |
| `scripts/check-module-invariants.sh --no-build` | ALL CHECKS PASSED (C3 sorry = 0; C14 no stale counts in `docs/`+`README.md`; C9D 138 soft task-refs under `docs/`) |
| `scripts/check-paper-definitions.sh` | **exit 1** — 32 drifted, 6 dangling |
| `scripts/typst-sync-check.sh` | **FAIL** — 3 count mismatches in `typst/generated/status.typ` |
| `scripts/typst-status-counts.sh` | `axiom_count 45`, `rule_count 7`, `base 37`, `dense 2`, `discrete 3`, `dedekind 3`, `sorry_total 4`, `sorry_total_excl_boneyard 0` |
| `cloc --include-lang=Lean --exclude-dir=.lake,lake-packages,Boneyard .` | 539 files / 170,898 code / 96,290 comment / 31,981 blank |
| `git remote -v` | `git@github.com:benbrastmckie/BimodalLogic.git` |
| `#print axioms` × 25 (scratch file over `import FormalSystem`) | all `[propext, Classical.choice, Quot.sound]` |
| `rfl` check on `someFuture`/`somePast` | both typecheck — `F_until_equiv`/`P_since_equiv` vacuous |

**Paper line references used above** (live file, 4856 lines):
`536`, `1203`, `1365`, `1661`, `1706`, `1801-1804`, `1823` (`def:id`), `2134` (`def:strongest`),
`2146` (`thm:exist`), `2158` (`thm:s5`), `2197` (`lem:uniq`), `2764` (`def:BL-language`),
`2776` (`def:task-relation`), `2804` (`def:directed`), `2834` (`def:frame`),
`2868` (`def:deterministic`), `2889` (`lem:nullity`), `3128` (`thm:extension`),
`3146` (`cor:occurrence`), `3566` (`def:BL-semantics`), `3694` (`def:frame-properties`),
`3718` (`def:BLplus-language`), `3730` (`def:BLplus-semantics`), `3745` (`def:BLplus-defined`),
`3805`/`3886`/`3966` (`app:discrete`/`app:dense`/`app:complete`), `4306` (`app:Soundness`),
`4311`, `4484` (`thm:TM-soundness`), `4494`, `4518` (`def:S5`), `4536` (`def:BX`),
`4585` (`def:TMplus-f`), `4605` (`def:TMplus-d`), `4622` (`def:TMplus-c`), `4645` (`def:TMplus`),
`4657` (`cor:tm-completeness`), `4668` (its new Lean footnote), `4672-4688`
(`cor:tm-decidability`, commented out).

**Related existing infrastructure** (do not duplicate — extend):
`specs/paper-definitions-of-record.md`, `scripts/check-paper-definitions.sh`,
`scripts/check-module-invariants.sh` (C3, C5, C12, C13, C14),
`scripts/typst-sync-check.sh`, `scripts/typst-status-counts.sh`,
`specs/decisions/untl-snce-argument-order.md`, `specs/decisions/total-history-validity-decisions.md`.

## Context Extension Recommendations

- **Topic**: paper-anchor citation integrity.
  **Gap**: nothing in the tree verifies that a `def:*`/`thm:*`/`lem:*`/`cor:*`/`app:*` citation
  in a Lean docstring or typst chapter still resolves to a live `\label{}` in the paper. 30 such
  citations are currently dangling (F4).
  **Recommendation**: add a C15 check to `scripts/check-module-invariants.sh`, and a short
  context note under `.claude/context/project/lean4/` describing the citation convention and
  the check.
- **Topic**: axiom-count claims in `.lean` docstrings.
  **Gap**: check C14 lints only `docs/` + `README.md`, which is why six "42 axiom constructors"
  claims survived a 42→45 change.
  **Recommendation**: extend C14's content scan to `FormalSystem/**/*.lean`.

---

## Addendum: Orchestrator Verification Pass (semantics + README semantics section)

Added after the report was first committed, in response to a follow-up question about whether the
Lean *semantics* is completely accurate and whether `README.md`'s semantics section matches. This
pass re-derived F10's conclusions independently rather than accepting them. It **corrects one
finding (D25)**, **adds one new discrepancy (D28)**, and sharpens two existing ones.

### A1. D25 is WRONG — `nullity_identity` is derivable, not "strictly stronger"

`TaskFrame.lean:501-509` asserts that the `nullity_identity` field is "**Strictly stronger than
the paper** — OPEN DESIGN QUESTION", on the grounds that `lem:nullity` (`:2889`) asserts
reflexivity only while the Lean field is an `iff` that additionally asserts injectivity-at-zero.
F10's last row and Discrepancy D25 both repeat that claim and defer it.

**The claim is false.** Injectivity-at-zero follows from the `limit` field *alone*, by
instantiating the cone witness at `y := 0`: if `R w 0 u` then for every `x > 0` we have
`|0| < x` and `R w 0 u`, so `u` lies in every positive cone of `w`, so `limit` gives `u = w`.
Reflexivity is then `nullity_of_serial_limit` (`FrameAxioms.lean:149`), i.e. `serial` at `x = 0`
composed with the same `limit`. Together they give the field's full `↔`.

Verified against the real definitions (not a paraphrase) — both theorems typecheck under
`lake env lean`, emitting only an `unusedSectionVars` linter warning for `[Nontrivial D]`:

```lean
theorem inj_at_zero_of_limit {W : Type} {R : W → D → W → Prop}
    (hLim : ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ R w y u) → u = w)
    (w u : W) (h : R w 0 u) : u = w := by
  refine hLim w u ?_
  intro x hx
  exact ⟨0, by simpa using hx, h⟩

theorem nullity_iff_of_serial_limit {W : Type} {R : W → D → W → Prop}
    (hSer : TaskFrame.Serial R)
    (hLim : ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ R w y u) → u = w)
    (w u : W) : R w 0 u ↔ w = u := by
  constructor
  · intro h; exact (inj_at_zero_of_limit hLim w u h).symm
  · rintro rfl; exact TaskFrame.nullity_of_serial_limit hSer hLim w
```

**Consequences for the plan:**

1. **The Lean frame class is extensionally exactly the paper's**, not a proper subclass. Lean's
   `{nullity_identity, comp, converse, serial, limit, spherical}` and the paper's
   `{Compositionality, Seriality, Limit, Spherical}` + nonempty `W` + converse convention are
   inter-derivable. F10's separate worry that Lean's `limit` states only the `⊆` half of
   `⋂_{x>0}(w)_x = {w}` is likewise closed: the `⊇` half is `w ∈ (w)_x` for all `x > 0`, which is
   reflexivity-at-zero, which the above derives. No circularity — the `⊆` half alone drives it.
2. **D25 moves from BLOCKED/deferred to a mechanical docstring correction.** Option (a) recorded
   at `TaskFrame.lean:507` ("demote it to a derived lemma proved from Seriality + Limit once
   those land") is available *now*; `serial` and `limit` are both already fields.
3. The "OPEN DESIGN QUESTION" and "Strictly stronger than the paper" language at
   `TaskFrame.lean:501-509` must be **retired**, and the joint-decision framing dropped — the
   question is settled, not deferred. Whether to actually delete the field (making it a derived
   lemma, a breaking change for construction sites) versus keeping it as documented redundancy
   is a separate, purely ergonomic call.

### A2. D28 (NEW, SUBSTANTIVE) — `README.md`'s box clause quantifies over the wrong histories

| ID | Axis | Paper says | Lean/docs actually | Sev | Resolution direction |
|---|---|---|---|---|---|
| D28 | Semantics / docs | `def:BL-semantics` (`:3573`): "$\M,\tau,x \vDash \Box\varphi$ *iff* $\M,\sigma,x \vDash \varphi$ for all $\sigma \in H_{\F}$" — `H_F` is the **total** histories | `README.md:74`: "for all world-histories `σ`", where `README.md:68` defines a world-history as a map from a **convex subset** `X ⊆ D` — i.e. partial. Lean is correct (`Truth.lean:166`: `∀ σ, σ.IsTotal → …`; `Validity.lean:94-97` binds `τ.IsTotal`) | **SUBSTANTIVE** | **Change docs** — "for all **total** world-histories `σ`" |

This was missed by the original pass, which checked `Truth.lean` against the paper (match) and
`README.md`'s numeric claims (correct) but did not check `README.md`'s *truth clauses* against
either. It is not cosmetic: atoms are false off-domain (`Truth.lean:161`), so a `□` ranging over
partial histories would falsify `□p` at almost every point and break the S5 fragment.
`Truth.lean:120-130` explicitly records that the quantifier ranges over `H_F` "with no `Ω` and no
shift-closure side condition"; `README.md` never received that update.

### A3. D20 is worse than stated — the three named constraints are the two non-axioms

`README.md:66` names "three constraints: *nullity*, *compositionality*, and *reflection*".
Against `def:frame`'s four axioms and `TaskFrame`'s six constraint fields, the omissions are
**Seriality**, **Limit**, and **Spherical** — and *Spherical* is the condition the entire
`def:constraints` → `lem:admissible` → `lem:step` → `thm:extension` (Zorn) → `cor:occurrence`
chain consumes. Of the three the README does name, "reflection" is the converse *convention*
(`def:task-relation`, definitional, not an axiom) and "nullity" is derivable (A1). So the
sentence lists the two non-axioms and omits all three substantive frame conditions. Any rewrite
should state the four paper axioms and note that `converse` and `nullity_identity` are carried as
fields for construction ergonomics rather than as independent content.

### A4. D21 confirmed, with the internal-consistency detail

`README.md`'s `U(φ,ψ)` is **event-first**: its own truth clause (`README.md:75`) places `φ` at the
witness `y > x` and `ψ` on the open interval. The paper's `φ \until \psi` (`def:BLplus-semantics`,
`:3733`) is **guard-first**, as is Lean's `untl ψ φ` (`Truth.lean:167`). README is therefore
internally consistent — its derived rows `Fφ = U(φ,¬⊥)` and `Xφ = U(φ,⊥)` follow its own
convention correctly — and **only the "Lean Constructor" column is wrong**: `untl φ ψ` should read
`untl ψ φ`, and `snce φ ψ` should read `snce ψ φ`. Worth pairing the fix with a sentence noting
that README's `U(φ,ψ)` and the paper's `φ \until \psi` take their arguments in *opposite* orders,
since a reader cross-referencing the two silently inverts every temporal clause.

### A5. Semantics axes re-verified as MATCHING (no change needed)

- **Truth clauses** `Truth.lean:161-168` vs `def:BL-semantics` + `def:BLplus-semantics`: match
  clause for clause, including until/since guard/event order.
- **Validity restricted to `H_F`**: `Validity.lean:94-97` binds `τ.IsTotal` at every consequence
  and validity variant — the paper's `τ ∈ H_F`.
- **Non-vacuity of validity**: `TaskFrame.not_validOn_bot` and `hF_nonempty_of_frameAxioms`
  (`Validity.lean:586-601`) discharge `cor:occurrence`'s closing clause `H_F ≠ ∅` from the frame
  fields alone. Without it `ValidOn ⊥` would be a theorem.
- **World-history definition**: `README.md:68` (convex `X ⊆ D`, respects the task relation)
  matches `WorldHistory.convex` (`WorldHistory.lean:112`) and `def:world-history`.
- **Atom clause domain conjunct**: `README.md:70` correctly reflects Lean's `∃ ht : τ.domain t`
  rather than the paper's total-history clause. Consistent with the accepted gap recorded at
  `Truth.lean:132-135`; not a defect.
- **`Serial` includes `x = 0`** (`TaskFrame.lean:359`, `0 ≤ x`), which A1's derivation requires.

### A6. Revised inventory deltas

| ID | Was | Now |
|---|---|---|
| D25 | SUBSTANTIVE, "deliberately deferred", do not settle | **Settled**: docstring correction at `TaskFrame.lean:501-509`; retire "strictly stronger"/"OPEN DESIGN QUESTION" |
| D20 | SUBSTANTIVE, "names only three of six" | Unchanged severity; note that the three named are the two non-axioms and *Spherical* is among the omitted |
| D21 | SUBSTANTIVE | Unchanged; scoped to the "Lean Constructor" column only, plus an opposite-argument-order note |
| D28 | — | **NEW**, SUBSTANTIVE, change docs |

Inventory total: **28** discrepancy IDs (27 original + D28).
