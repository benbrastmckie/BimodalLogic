# Research Report: the BX/TM membership-prose audit

**Task**: 801 - Re-pin the BX/TM anchor wave in paper-definitions-of-record.md after the paper's post-788 revision, and verify in-tree axiom-membership prose matches
**Started**: 2026-10-15T09:31:22Z
**Completed**: 2026-10-15T09:58:00Z
**Effort**: medium
**Dependencies**: 791, 793
**Sources/Inputs**:
  - `scripts/check-paper-definitions.sh` (full run and per-anchor `--resolve`, live working tree)
  - `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` (4092 lines, sha256 `76a39caf838a029b…`, paper repo HEAD `b939ccf9`, **clean**)
  - `docs/reference/paper-definitions-of-record.md` (2463 lines, committed and clean)
  - `scripts/check-module-invariants.sh` (C14, C15, C35 source text), `scripts/lean-citation-manifest.json`
  - `FormalSystem/`, `docs/`, `typst/`, `BimodalTools/`, `README.md` (full membership-prose sweep)
  - the seed report `reports/01_repin-bx-tm-anchor-wave.md`
**Artifacts**: - `specs/801_repin_bx_tm_anchor_wave_post_788_paper_revision/reports/01_bx-tm-membership-prose-audit.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The wave is 10 anchors and the paper has moved again since the seed report.** Same anchor
  set, but `lem:uniq`'s NEW hash moved `100afee0…` → `4d7a5038…` (its whole footnote was
  dropped). The other nine NEW hashes are stable across the two measurements. Every hash must
  still be re-derived at implementation time.
- **The central finding is positive and sharper than "nothing in the tree is false":** after this
  revision the paper's primitive axiom set and the tree's `inductive Axiom` **coincide exactly,
  key for key** — 16 named paper primitives (MK/MT/M5, TS/UI/UC/UF/UG/US/CN, MF/NB, UZ, NN,
  PU/SEP) plus the tree's 4 CPL constructors = 20. The record's own standing claim that the tree
  is a *proper subset* of the paper's lists is what became obsolete.
- **`UE` and `UT` no longer exist anywhere in the paper.** Zero `\aitem`, `\aref` or `\alabel`
  occurrences. Thirteen in-tree sites still assert they are paper schemata of `def:BX`, including
  two `Paper: def:BX` docstring attributions that C15 actively cross-checks against
  `docs/theorem-index.md`.
- **The sharpest false claim is in `typst/FormalFoundations.typ`:** line 490 says "NB is stated
  here as it belongs to BX in the paper" and line 496 calls MF "the sole bimodal-interaction
  axiom". The live `def:TMplus` names **two** bimodal interaction axioms, MF *and* NB. This is a
  mutually reinforcing pair of errors, and it is an explicit attribution *to the paper*.
- **Two files carry the entire pre-788 29-constructor table and no gate can see them.**
  `FormalSystem/ProofSystem/README.md` (Total 29) and `README.md:223` (23 Base) contradict their
  own adjacent "20 constructors" sentences. C14 misses both twice over — its markdown scope is
  `docs/` plus the *root* README only, and its stale-literal set is `{14,21,42,44,45}`, which
  contains neither 23 nor 29.
- **The gate baseline is clean except the one gate this task exists to turn green.**
  `check-paper-definitions.sh` exits 1 (10 anchors); `check-module-invariants.sh --no-build`,
  `export-lean-citations.py --check`, `readme-lint.sh`, `typst-sync-check.sh` and both Typst
  compiles all exit 0 at `c7c257267`.
- **C35 exposure is much narrower than the task description feared.** None of the nine derived
  declarations is seeded in the citation manifest; only `ProofSystem/Axioms.lean` is (one entry,
  span 408–534). Only an `Axioms.lean` edit forces `export-lean-citations.py`.
- **The declared `file_scope` under-covers the audit surface by eight files.**

## Context & Scope

The paper is read-only input maintained in a separate repository and is being revised by its
author. This repository pins a `sha256` per definition block in
`docs/reference/paper-definitions-of-record.md`, resolving anchors by `\label{}`/`\aitem{}` name
rather than line number. A changed block hash is the gate's outcome (c): FAIL, exit 1.

This round does the work the seed report explicitly deferred: it re-measures the live wave,
characterises `def:BX-z` and `def:BX-d` (which the seed left uncharacterised), extracts the
paper's post-revision membership structure, and performs the in-tree judgment pass that the task
calls its real content. It writes nothing outside `specs/`.

The working tree outside `specs/` is clean at `c7c257267`; task 791's edits to the record file are
committed. No concurrent foreign modification touched the audit surface during this round.

## Literature Proof Structure

**Source**: `possible_worlds.tex` (Brast-McKie, *Possible Worlds*, JPL submission), §`sub:Logic`,
§`sub:Extension`, and the definitional appendix following `\label{app:Soundness}`.
**Strategy**: not a proof to formalize — a **definitional demotion**. Each system's definition is
narrowed to the primitives the Lean `Axiom` inductive actually carries, and every schema removed
from a definition is restated in that same definition as a *derived theorem*, with a
`\leanfoot`/`\leanref` citation into this repository naming the declaration that proves it. No
step map applies; the extraction below is the membership map instead.

### Membership map (live paper)

| System | Axioms it now names | Demoted to derived theorem, by that definition's own text |
|---|---|---|
| `def:S5` | MK, MT, M5 (+ rule MP, metarule MN) | — |
| `def:BX` | TS, UI, UC, UF, UG, US, CN (+ metarules TN, TR) | **TC, TL** — "derived theorems of **BX** rather than further axioms" |
| `def:TMplus` (TM) | **MF and NB**, as the two *bimodal interaction* axioms | **NP, NF, NA** — "derived theorems of **TM** rather than of **BX**", from NB with MF and MT |
| `def:BX-z` | UZ | **Z1** — derived theorem of **TM**_z, "for the full bimodal system rather than for **BX**$_z$ alone" |
| `def:BX-d` | NN | **DN** — derived theorem of **BX**_d, "using only NN and the axioms of **BX**" |
| `def:BX-r` | PU, SEP | **CO** — derived theorem of **BX**_r, from PU with the axioms of **BX** (already absorbed) |

### Dependencies and consequences

- **The two sets now coincide.** 16 named paper primitives + 4 CPL constructors = **20** =
  `inductive Axiom`'s constructor count. Not a subset — an identity.
- **UE and UT were removed outright**, not demoted. They survive in the tree as derived
  declarations (`DerivedAxioms.untilF`, `DerivedAxioms.fUntilEquiv`) with no paper key at all.
- **`lem:derived-schemata` no longer exists.** The paper records it was "removed as unreadable",
  each schema now being marked derived where it is displayed. The task description's claim that
  NP/NF/NA are derived "by `lem:derived-schemata`" is therefore stale. **Zero in-tree citations**
  — no dangling-anchor retirement is needed.
- **`def:BX-r` is the precedent, already absorbed.** Its pinned text already carries the
  derived-theorem sentence for CO. This wave is the same editorial move arriving at BX, BX_z,
  BX_d and TM.
- **New, unrowed anchor**: `\label{fn:static-frame}` inside `app:discrete`'s footnote.
- **All 17 of the paper's inbound `\leanfoot`/`\leanref` targets resolve in the tree** (verified
  declaration by declaration; see Appendix). The paper's citations into this repository are live.

## Findings

### Codebase Patterns

#### Tier 1 — in-tree claims *about the paper* that the live paper contradicts

| # | Site | Claim | Why it is now false |
|---|---|---|---|
| 1 | `typst/FormalFoundations.typ:490` | "NB is stated here as it belongs to BX in the paper" | NB is an axiom of **TM** (`def:TMplus`), not of BX |
| 2 | `typst/FormalFoundations.typ:496` | TM extends S5 and BX by "the sole bimodal-interaction axiom: MF" | The paper names **two**: MF and NB |
| 3 | `typst/FormalFoundations.typ:463-491` | BX definition block lists TC, UE, UT, TL, NP, NF, NA, NB among BX's axioms; footnote asserts "Seventeen named keys" | Live `def:BX` names **nine** keys (TN, TR + TS, UI, UC, UF, UG, US, CN) |
| 4 | `docs/reference/axiom-reference.md:428-429` | "The paper's `def:BX` names its base tense logic by `\aitem` keys (TN, TR, TS, TC, TL, UE, UT, UI, UC, UF, UG, US, CN, NP, NF, NA, NB)" | Same 17-vs-9 error, stated as the heading premise of the whole Paper Key Correspondence section |
| 5 | `docs/reference/axiom-reference.md:455-457` | "of the paper's 11 non-uniformity temporal axioms, 7 are primitive and 4 (TC, TL, UE, UT) are derived; of its 4 uniformity axioms, 1 (NB) is primitive and 3 derived" | The reconciliation arithmetic rests on the paper having 15 BX axioms. It has 7, with MF and NB in TM. The total 20 still reconciles; the attribution does not |
| 6 | `docs/reference/axiom-reference.md:7-8` | tree's 20 = "the paper's primitive axiom schemata … **minus the nine of them that are theorems of the others**" | The "minus nine" clause is exactly what the revision retired: the two sets now coincide |
| 7 | `docs/reference/axiom-reference.md:87,99` | "**Paper keys**" table, row "F bridges \| UE, UT" | UE and UT are not paper keys any more |
| 8 | `typst/chapters/03-proof-theory.typ:142` | "MF is the sole bimodal interaction axiom" | Same as #2 |
| 9 | `docs/reference/paper-definitions-of-record.md:403-409` | "Nine schemata the paper lists as axioms are derived in the tree — TC, UE, UT, NP, NF, NA, TL, DN, Z1 … The paper's `def:BX` text and `typst/FormalFoundations.typ` are **not edited**: the divergence is recorded here" | The premise of that deliberate deferral is gone. The paper has caught up, and the divergence this note records no longer exists |
| 10 | `FormalSystem/ProofSystem/Axioms.lean:47`, `:74` | "Nine further schemata **the paper lists** are theorems rather than constructors: TC, UE, UT, NP, NF and NA…"; "The nine schemata **the paper also lists** — TC, UE, UT, TL, NP, NF, NA, Z1, DN" | UE/UT are not listed by the paper at all, and the paper no longer lists the other seven *as axioms* |
| 11 | `FormalSystem/README.md:111` | "Nine schemata **the paper lists as axioms** are derived too: UE, UT, NF…" | Same |
| 12 | `docs/theorem-index.md:66` | "Nine schemata **the paper lists as axioms** are theorems of the 20-constructor system" | Same |
| 13 | `docs/theorem-index.md:73,74` | UE and UT rows carry Paper-anchor cell `def:BX` | Neither key exists in the paper; the cell should become `—` |
| 14 | `docs/theorem-index.md:75,78,79` | NF, NP, NA rows carry `def:BX` | All three are now derived theorems of **TM** — `def:TMplus` |
| 15 | `FormalSystem/ProofSystem/DerivedAxioms.lean:134,143,153` | `Paper: def:BX` on `untilF` (UE), `fUntilEquiv` (UT), `discretePropagateFwd` (NF) | UE/UT → no anchor; NF → `def:TMplus` |
| 16 | `FormalSystem/Theorems/ConnectDerived.lean:140,163` | `Paper: def:BX` on `discreteSymmFwd` (NP), `discretePropagateBwd` (NA) | Both → `def:TMplus` |
| 17 | `docs/project-info/FEATURE_REGISTRY.md:23` | "the nine **paper schemata** TC, UE, UT, TL, NP, NF, NA, DN, Z1" | UE/UT are not paper schemata |

Sites 13–16 are **coupled by C15**, whose second assertion is that every `docs/theorem-index.md`
row carries its anchor *at the declaration*. Changing a theorem-index anchor cell without the
matching docstring `Paper:` line (or vice versa) turns C15 red. They must move together.

#### Tier 2 — in-tree claims false against the tree's *own* post-788 system

Independent of the paper revision; in scope because acceptance requires consistency "with 788's
completed 20-constructor system".

| # | Site | Defect |
|---|---|---|
| 18 | `FormalSystem/ProofSystem/README.md:26-44` | The whole pre-788 table, directly under its own correct sentence "**20 constructors** organized into **eight layers**": BX Temporal 9 (is 7); a "3b. Additional BX Temporal" layer of 2 naming `temp_linearity` (TL) and `F_until_equiv` (UT) as constructors (neither exists); Uniformity 4 (is 1, NB); a "7. Z1" layer (removed); Density 2 (is 1); **Total 29** (is 20); and a frame-classification paragraph citing "2 Discrete-only (`prior_UZ`, `z1`)" and cumulative counts "Base 23, Dense 25, Discrete 25, Dedekind 27" |
| 19 | `README.md:223` | "**20 constructors in eight layers**" followed by a decomposition summing to 29: "The **23 Base** constructors are propositional (4), S5 modal (3), Burgess-Xu temporal (**9**), an additional Burgess-Xu temporal layer (**2: TL, UT**), modal-temporal interaction (1), and uniformity (**4**) … density (2), Prior-UZ (1) and Z1 (1)" |
| 20 | `FormalSystem/ProofSystem/Axioms.lean:144` | "**Density** (1): GGφ → Gφ and ¬U(⊤,⊥)" — conflates DN (derived) with NN (the one constructor) |
| 21 | `FormalSystem/ProofSystem/Axioms.lean:147-148` | "Base axioms (**23**) are valid on all linear temporal orders. Prior/Z1 axioms (**2**) are discrete-only. The density axioms (**2**) …" — contradicts the layer list 25 lines above (16 Base / 1 ZTime / 1 Dense / 2 RTime) |

#### Tier 3 — correct; do **not** edit

Recorded to bound the edit surface, because several of these look superficially like Tier 1.

- `FormalSystem/README.md:98-107` — layer table is correct (7 / 1 / 1 / 1 / 1 / 2, Total 20).
- `typst/chapters/03-proof-theory.typ` — already post-788: "Layer 3: BX Temporal (7 primitive…)",
  "Layer 5: Uniformity (1 constructor; NP, NF, NA derived)", every one of the nine marked
  `(derived)`, counts drawn from `typst/generated/status.typ`. Line 18's "The axiom constructors
  are exactly the paper's primitive schemata" is now *newly, exactly* true. Only line 142 (#8) is
  wrong. Its `// CONFIRM(paper):` marker at line 361 is now confirmable.
- `BimodalTools/AxiomNames.lean:33-34`, `BimodalTools/FormulaEnumerator.lean:1284-1286`,
  `FormalSystem/ProofSystem.lean:26,32`, `docs/development/MODULE_ORGANIZATION.md:337`,
  `docs/reference/axiom-reference.md:56` — all state which *declarations* are derived in the
  tree, make no claim about the paper, and are true.
- `ConnectDerived.lean:109` (TC → `def:BX`), `LinearityDerived.lean:85` (TL → `def:BX`), `:136`
  (DN → `def:BX-d`), `CompletenessDerived.lean:51,61` (Z1 → `def:BX-z`) — all still correct
  anchors under the revision.
- `Axioms.lean`'s `modal_future` and `discrete_box_necessity` constructor docstrings make no
  BX-vs-TM membership claim; the Layer 4/5 comments are accurate.

#### The verbatim-quotation criterion is already satisfied

No in-tree site claims a verbatim quotation of any of the ten anchors. The only close restatement
is `typst/FormalFoundations.typ:463-465`, which paraphrases `def:BX`'s opening sentence without
asserting verbatim fidelity. The acceptance clause "no in-tree site claims a verbatim quotation it
does not reproduce" therefore holds before and after this task; the work is the membership
restatement, not a quotation repair.

### External Resources

#### Gate baseline, measured at `c7c257267`

| Gate | Exit | Note |
|---|---|---|
| `scripts/check-paper-definitions.sh` | **1** | 10 anchors drifted — the only red gate |
| `scripts/check-module-invariants.sh --no-build` | 0 | C14, C15 (81 citations + 289 theorem-index rows), C35 (86 seeded) all PASS |
| `python3 scripts/export-lean-citations.py --check` | 0 | 86 seeded names resolved |
| `bash scripts/readme-lint.sh` | 0 | RESULT: PASS |
| `bash scripts/typst-sync-check.sh` | 0 | all 4 checks green |
| `typst compile typst/BimodalReference.typ` | 0 | typst 0.14.2 |
| `typst compile typst/FormalFoundations.typ` | 0 | — |
| `lake build` | not run | no Lean *code* change is in scope; see the cost note under Risks |

#### Gate coupling, verified rather than assumed

- **C35 is nearly inert here.** `scripts/lean-citation-manifest.json` seeds **86** entries;
  none of `untilF`, `fUntilEquiv`, `discretePropagateFwd`, `discreteSymmFwd`,
  `discretePropagateBwd`, `connectFuture`, `tempLinearity`, `density`, `z1Thm`, `coDerived` is
  among them. The only seeded entry in the whole audit surface is
  `FormalSystem.ProofSystem.FrameClass` in `Axioms.lean` (keyword_line 486, span 408–534). Any
  line-count change above line 408 shifts it, so **an `Axioms.lean` edit — and only that — forces
  `python3 scripts/export-lean-citations.py`.**
- **C15 is the binding constraint**, through its theorem-index/declaration cross-check (Tier 1
  sites 13–16).
- **C14 is blind to Tier 2.** Source read at `scripts/check-module-invariants.sh:1958-2001`: its
  markdown scope is `docs` + `README.md` (nested `FormalSystem/**/README.md` excluded) and its
  stale-literal pattern is `\b(14|21|42|44|45)[[:space:]]+…(axiom|constructor|schema)`. 23 and 29
  are outside the set, so `README.md:223` and `ProofSystem/README.md`'s Total-29 table both pass.
  The in-file comment at line 1938 still describes the old "not 29" behaviour and no longer
  matches the code.
- **`readme-lint.sh` does not check counts** — presence, links and date stamps only.

#### Re-pin mechanism

`--resolve` confirmed working and sufficient (`def:TMplus` resolved live: text plus
`sha256 139a9a56…`). Locators from the MANIFEST block (`docs/reference/paper-definitions-of-record.md:2222-2269`,
43 rows): `CO|aitem|-|-`; the other nine are `env|-|-`. Each of the ten anchors has **exactly
one** prose entry, so placement is unambiguous: `CO` 1625, `def:BX` 1663, `def:BX-z` 1751,
`def:BX-d` 1773, `def:TMplus` 1811, `app:discrete` 1845, `def:id` 2031, `def:strongest` 2057,
`thm:exist` 2076, `lem:uniq` 2085.

Whole-file sentinels to re-pin **last** (lines 64-68), plus the summary-table rows at 59-62:
`PINNED_COMMIT: 9ad4aa5d…` → `b939ccf9…`; `FILE_CHECKSUM: 0e39993c…` → the live sha256;
`LINE_COUNT: 3962` → the live line count. The live file is **clean** against its HEAD, as at the
27-anchor wave.

### Recommendations

1. **Re-derive the wave first, before any edit.** Run the gate untruncated and `--resolve` each
   drifted anchor. Treat this report's Appendix as a prior. The acceptance criterion to state is
   conditional: *the gate is green against the paper revision absorbed at time T, identified by
   its sha256 and paper-repo HEAD* — never an unconditional exit 0.
2. **Re-pin mechanically, asserting each OLD block first.** For every anchor, confirm the record's
   pinned fence re-hashes to its recorded OLD sha256 before writing the replacement, so each
   placement is proved. Then update, per anchor: the `latex` fence, the `sha256:` line, and the
   MANIFEST row. Sentinels last, per the absorption order (gate re-run with the old sentinels in
   place forces full anchor validation and should report case (b) before the sentinels move).
3. **Phase the prose work by gate coupling, not by directory.** Three natural phases:
   (a) the record file — re-pin plus the dated drift-correction entry, including rewriting the
   obsolete 2026-10-14 amendment note (#9) to record that the divergence is now *resolved*;
   (b) the C15-coupled quartet — `theorem-index.md` rows and the `DerivedAxioms.lean` /
   `ConnectDerived.lean` `Paper:` lines, edited together in one commit, with
   `check-module-invariants.sh --no-build` as the gate;
   (c) everything else — `axiom-reference.md`, both Typst documents, `Axioms.lean`,
   `ProofSystem/README.md`, `FormalSystem/README.md`, `README.md`, `FEATURE_REGISTRY.md`.
4. **Batch every Lean docstring edit into one phase.** A docstring edit in
   `ProofSystem/Axioms.lean` invalidates essentially the whole downstream library; `Axioms.lean`,
   `DerivedAxioms.lean` and `ConnectDerived.lean` are all near the root of the import DAG. One
   full `lake build` at the end of a single Lean phase, not one per file. Run
   `export-lean-citations.py` after the `Axioms.lean` edit.
5. **Lead the drift-correction entry with the coincidence, not the diff.** The durable fact worth
   recording is that the paper's primitive set and the tree's `inductive Axiom` now agree key for
   key (16 + 4 CPL = 20). State the UE/UT *removal* separately from the TC/TL/NP/NF/NA/Z1/DN
   *demotions* — they are different editorial acts with different in-tree consequences.
6. **Name the four Tier-D anchors explicitly in the entry**, per the recorded user decision:
   `def:id`, `def:strongest`, `thm:exist`, `lem:uniq` absorbed as part of this re-pin on the basis
   of zero citing files, with the dropped primed `Str'` operator as the paper-side cause. Note
   that `lem:uniq` was re-resolved mid-task if it moves again.
7. **Extend the declared `file_scope`** to the eight uncovered files (listed under Decisions), or
   record the exclusion. `docs/reference/axiom-reference.md` carries four of the seventeen Tier-1
   defects and is the single most affected file in the repository; it is absent from `file_scope`.
8. **Raise `fn:static-frame` and the new `app:discrete` sentence as a separate question**, as the
   seed report recommended and the user's recorded decision preserved. The added
   "extending TM by DN alone does not prove NN" claim is an independence result adjacent to
   `FormalSystem/Metalogic/Independence/`, and may be formalizable rather than merely quotable.
   Do not fold a possible new Lean obligation into a re-pin task. `fn:static-frame` is also a new
   anchor with no row, so it is a candidate addition rather than a re-pin.
9. **Treat the C14 widening as a separate, optional follow-up.** Adding 23 and 29 to its
   stale-literal set and widening its markdown scope to `FormalSystem/**/README.md` would have
   caught Tier 2 mechanically. Worth a task; it is a gate change, outside this task's scope.

## Decisions

- **The wave to absorb is the 10 anchors enumerated here**, superseding the 4 named in the task
  description — as that description itself instructs.
- **`lem:derived-schemata` requires no work.** It no longer exists in the paper and has zero
  in-tree citations, so there is no dangling anchor to retire. The task description's reference to
  it is stale and should not be propagated into the record entry.
- **UE/UT removal is in scope.** It is not an unrelated subsystem wave: it is part of the same
  `def:BX` membership revision this task exists to absorb, and seventeen in-tree sites turn on it.
- **Tier 2 (the pre-788 count tables) is in scope**, on the strength of the acceptance clause
  requiring consistency with 788's 20-constructor system — not on the strength of the paper
  revision, which is silent about them.
- **Tier 3 is explicitly out of scope**, recorded so implementation does not "correct" true
  statements about tree-internal derivation into false ones.
- **`app:discrete`'s added sentence and `fn:static-frame` stay out**, per the user's recorded
  decision, which admitted the four unformalized anchors but expressly did not extend to
  `app:discrete`.
- **Eight files are missing from the declared `file_scope`**: `docs/reference/axiom-reference.md`,
  `docs/project-info/FEATURE_REGISTRY.md`, `docs/theorem-index.md`,
  `typst/chapters/03-proof-theory.typ`, `FormalSystem/ProofSystem/DerivedAxioms.lean`,
  `FormalSystem/Theorems/ConnectDerived.lean`, `FormalSystem/ProofSystem.lean` (verify only — Tier
  3), `docs/user-guide/architecture.md` (minor; line 1549 calls TF an axiom, a pre-existing
  inaccuracy independent of this wave).
- **Two `file_scope` entries carry no defect**: `docs/reference/API_REFERENCE.md` and
  `typst/generated/status.typ` (generated; regenerate only if a count changes, which none will).

## Risks & Mitigations

- **The paper moves again mid-task.** It has now moved at least six times across these runs, and
  it moved between the seed report and this one. Mitigation: re-derive at implementation time;
  report which wave was absorbed and which was not, identified by sha256 and paper HEAD.
- **Mistaking inherited red for self-inflicted red.** Mitigated in advance by the measured
  baseline above: every gate but `check-paper-definitions.sh` is green at `c7c257267`, so any new
  red is attributable.
- **C15 half-edit.** Changing a `theorem-index.md` anchor cell without its declaration's `Paper:`
  line (or vice versa) turns C15 red in a way that reads as a regression. Mitigation: edit the
  quartet in one phase and gate it with `check-module-invariants.sh --no-build`.
- **Full-library rebuild cost.** Docstring-only edits at the root of the import DAG still force a
  full rebuild. Mitigation: one Lean phase, one build, run detached through
  `lake-build-guard.sh` per `context/project/lean4/operations/long-builds.md`.
- **Over-editing Tier 3.** The true tree-internal statements name the same nine schemata as the
  false paper-attributing ones, so a search-and-replace over "UE, UT" would corrupt correct prose.
  Mitigation: the explicit Tier 3 list above; this is a judgment pass, as the task says.
- **Concurrent siblings.** Tasks 795–799 are dispatched this same cycle with no declared
  `file_scope`. Mitigation: re-read each file immediately before editing; stage explicit file
  lists only; never a directory or glob `git add`.
- **Typst compile regression.** `FormalFoundations.typ`'s BX block is a structured `#items[…]`
  list; removing entries risks a syntax slip. Mitigation: compile both documents after each Typst
  edit (both are fast and green now).

## Tactic Survey Results

- Not applicable (no tactic survey performed). This is record-and-prose work: the task's non-goals
  forbid new Lean declarations and any change to the axiom set, and no proof goal arose. All nine
  derived schemata were already machine-checked by 788; this round verified their *names and
  anchors*, not their proofs.

## Context Extension Recommendations

- **Topic**: a gate's stale-literal set as a maintenance liability.
  **Gap**: C14 is the tripwire that is supposed to keep documented axiom counts honest, yet its
  literal set `{14,21,42,44,45}` was never extended when the total moved to 20, so the two most
  stale tables in the repository pass it. Nothing in the context tree records that a count-pinning
  gate must have its *superseded* literals added, not just its current one.
  **Recommendation**: add a short note to `context/project/lean4/domain/metadata-trust-surfaces.md`
  — which already documents what Lean metadata rows are *not* checked by — covering count-tripwire
  gates: when a pinned count changes, the old value joins the stale set and the gate's directory
  scope should be re-checked against where the count is actually documented.

## Appendix

### Measured hash pairs (snapshot 2026-10-15; re-derive before use)

Paper sha256 `76a39caf838a029b646e7e62c36373ad21fe1e8078a7961cce527dd520e8ccbb`, 4092 lines,
paper repo HEAD `b939ccf9`, file clean. Repo HEAD `c7c257267`.

| Anchor | OLD sha256 (record's pin, verified) | NEW sha256 (live) | vs seed |
|---|---|---|---|
| `CO` | `5c468c01776c449b212c98070b5bfc70951691a23905cd4d4c249bf1f5375d41` | `707368059ff1f7cc53c8b4ca9c591781ee427263797c8d36d3fb85e8abe8e955` | unchanged |
| `def:BX` | `8fdba7ab64b74d245bd47bfa14e6baac17c9d2ce67fdea5371a5fa9fc624a903` | `64cc5cc90860bd5c3855701a4de57c38a10ffb6d0c59025224c82869f8454ec2` | unchanged |
| `def:BX-z` | `96e4b25e71c457bd3618f3a818b1852176b345d2c86199fbe16b6c46076ba334` | `c38466b21121724f71d039014c525e5e4f8c397025f37746fcfb7587c85a5581` | unchanged |
| `def:BX-d` | `2423da4688632bfea7d0d3613a4bca4953c6197e6120dd43f79cbd5e44e294d0` | `44a74c839c0c74141fb1565120cb91193973fc33a69c35d5070bcbc67379e40c` | unchanged |
| `def:TMplus` | `d71622fc325a3d40ae4a7823c0d5d17f73e4a18bcf2e1c4be59e6693db35e142` | `139a9a56bdf9b22c2544c6c86ec1eeb178e4908810578556ed6c057de8ef5e42` | unchanged |
| `app:discrete` | `465b089fd41ed5b599cf080621c0181bfcce5ef8374d44f9f147709d23409864` | `240826f45dae75872ef1219aaac79903d775f424ac46077feac45febfd7bcc54` | unchanged |
| `def:id` | `f56301e580b40894ddd7d69c6a72d326a8a41f984f8713cf431215b5f0fd9c92` | `0d994904bc8d6f1166fd4c947fe69a889e36be37343aca778182e9b19594d1d0` | unchanged |
| `def:strongest` | `1df0d202e5c4ccfeb92b6c83048ece99bb80dc6ce46774a05ff9e728e93231ec` | `0b96a04d79de927726435874a3def84136b85776a0d3f8e230b87e4b11622a70` | unchanged |
| `thm:exist` | `93d234140af7d36b60d55ffa2248a3f3896c6a80e115b2801efaeed07c115eef` | `299ecc33bf9397538f37aa263a5022c15c2a9a915de07dbee2b1b1244ee3c635` | unchanged |
| `lem:uniq` | `56f31fcacb80f4811e98c7ab8c1bcd49502cb8d51b10f813f36a2c943a950003` | `4d7a50384b457ec9c56b026c554d2736037b749a2da130ff5ed24640bbd3ca55` | **moved** from `100afee0…`: the whole `I8`/relational-model footnote was dropped, leaving only the unprimed uniqueness claim |

`CO`'s OLD hash is reported against base commit `9ad4aa5d…` and matches the record's pin; the
other nine OLD hashes are reported as verified against the pinned text in the record file.

### Per-anchor characterisation of the two the seed left open

- **`def:BX-z`**: axiom list narrows from `{UZ, Z1}` to `{UZ}`; a new sentence makes Z1 a derived
  theorem of **TM**_z, explicitly "for the full bimodal system rather than for **BX**$_z$ alone";
  the Archimedean closing sentence now rests on UZ alone.
- **`def:BX-d`**: axiom list narrows from `{DN, NN}` to `{NN}`; a new sentence makes DN a derived
  theorem of **BX**_d "using only NN and the axioms of **BX**". Both match the tree exactly
  (`CompletenessDerived.z1Thm` via the ZTime completeness engine; `LinearityDerived.density` from
  NN with the Base schemata).

### The paper's inbound citations into this repository — all 17 resolve

`Combinators.temporalFutureDerived` (`Theorems/Combinators.lean:910`),
`CompletenessDerived.z1Thm` (`Metalogic/CompletenessDerived.lean:63`),
`ConnectDerived.connectFuture` (`:112`), `ConnectDerived.discreteSymmFwd` (`:143`),
`ConnectDerived.discretePropagateBwd` (`:166`),
`DedekindDerived.coDerived` (`Theorems/DedekindDerived.lean:370`),
`DerivedAxioms.discretePropagateFwd` (`ProofSystem/DerivedAxioms.lean:155`),
`DiscreteUnfolding.dfSchema` (`:477`), `DiscreteUnfolding.succIndicator` (`:118`),
`LinearityDerived.density` (`:138`), `LinearityDerived.tempLinearity` (`:88`),
`Perpetuity.perpetuity1`–`4` (`Theorems/Perpetuity/Principles.lean:76,310,445,514`),
`TemporalDerived.temporal4Derived` (`:250`), `TemporalDerived.temporalKDistDerived` (`:194`).

### Commands used

- `bash scripts/check-paper-definitions.sh` — full drift run, untruncated, exit 1
- `bash scripts/check-paper-definitions.sh --resolve "def:TMplus|env|-|-"` — mechanism confirmation
- `bash scripts/check-module-invariants.sh --no-build` — exit 0; C14/C15/C35 verdicts read per-check
- `python3 scripts/export-lean-citations.py --check`; `bash scripts/readme-lint.sh`;
  `bash scripts/typst-sync-check.sh`; `typst compile --root . typst/{BimodalReference,FormalFoundations}.typ`
- `grep -n "label{...}"` over the paper for duplicate-label disambiguation (none: each of the ten
  anchors occurs exactly once, in the definitional appendix following `\label{app:Soundness}`)
- `grep -nE "aref\{UE\}|aitem\{UE\}|alabel\{UE\}"` and the UT equivalents over the paper — zero hits
- `python3` over `scripts/lean-citation-manifest.json` for seeded-name and span membership
- `sed -n '1932,2002p' scripts/check-module-invariants.sh` — C14's scope and literal set, read
  rather than inferred
