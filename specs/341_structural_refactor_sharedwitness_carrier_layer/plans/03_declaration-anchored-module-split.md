# Implementation Plan: Task #341 — SharedWitness Module-Split (Declaration-Anchored)

- **Task**: 341 - structural_refactor_sharedwitness_carrier_layer
- **Status**: [IMPLEMENTING]
- **Effort**: 20 hours
- **Dependencies**: 335 [done], 337 [done], 340 [done], 346 [done], 347 [done], 348 [done] — **all code-move gates SATISFIED** (re-verified 2026-07-26 against `specs/archive/state.json`)
- **Research Inputs**: reports/03_refactor-strategy-evaluation.md (primary), reports/01_sharedwitness-declaration-survey.md, reports/02_post-kamp-revision-realignment.md, reports/03_teammate-{a,b,c}-*.md
- **Artifacts**: plans/03_declaration-anchored-module-split.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md; lean4.md; git-workflow.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

`SharedWitness.lean` is **13,386 lines / 462 top-level declarations** (measured 2026-07-26 at
`9f8e33d5a`). This plan splits it along the 10-module map into sibling modules under a new
`NfMultiAnchorBridge/SharedWitness/` subdirectory, reducing `SharedWitness.lean` to a thin
**re-export hub** so every import site is preserved. This is a **purely structural,
behavior-preserving** refactor: no proof, statement, definition body, or evaluation behavior
changes; the full-tree `lake build` stays GREEN and the axiom set on `completeness_discrete` stays
unchanged after every phase. It is a re-export/module-split, **not** a re-proof.

This is a **targeted refresh** of `plans/02_module-split-refresh.md`, which is hereby SUPERSEDED.
Plan 02's design is correct and is preserved verbatim in strategy, module map, phase structure, and
verification bar. The single defect being corrected is **arithmetic**: plan 02 drove its split from
absolute line ranges taken against a 12,800-line snapshot that is no longer current.

### The Defect Corrected, and the Structural Fix

Plan 02 asserted "`SharedWitness.lean` is confirmed frozen (12,800 lines)". **That freeze assumption
was false.** The file is now 13,386 lines — +586. Every plan-02 cut point at or after the growth
site was wrong by up to 586 lines. Concretely wrong in plan 02: module J's band `11516–12800`, the
"sixth-seam" block `SW:10210–12800`, the Phase-1 precondition "12,800 lines, single flat namespace
(50–12800)", and the Overview's "lines 50–12800". The namespace does not even open at line 50 — it
opens at **line 56** and closes at **line 13386**.

**The structural fix**: every cut boundary in this plan is specified by **declaration identity** —
"module X spans from declaration `foo` through declaration `bar` inclusive" — not by line offset.
Line numbers appear only as an informational aid, clearly marked as such. This is the substantive
improvement: it corrects the current drift AND immunizes the plan against further growth, which this
file has now demonstrated four times (9,248 → 12,600 → 12,800 → 13,386). Any future dispatch
re-derives its own line numbers from the declaration names, which do not drift.

### Growth Attribution — the 586 lines are ZERO new declarations

Traced through git history for `SharedWitness.lean`:

| Commit | Task/phase | Lines | Δ |
|---|---|---|---|
| `29980c185` | 380: complete implementation | 12,800 | — (plan-02 baseline) |
| `98682ae47` → `1d09fde60` | 291 phase 5.16/5.17 | 12,795 | −5 |
| `4f10a53fa` | 292 phase 6: Apache headers | 12,801 | +6 |
| `1c2883ae8` | **399 phase 3: SharedWitness mechanical sweep** | 13,382 | **+581** |
| `ab239bda8` | 399 phase 8: tier-3 docBlame docstrings | 13,386 | +4 |
| `078ca90ce`, `9f8e33d5a` | 400 phases 2/3/5 (`push Not`, alias swaps, `IsChain`) | 13,386 | 0 |

**Finding (binding on the module map)**: the declaration inventory is *identical* between the
12,800-line plan-02 baseline and current HEAD. Diffing the ordered `(modifier, kind, name)` triple
sequence of all top-level declarations across the two revisions returns **no differences**: 462
declarations in both, same names, same order, same `private`/`noncomputable` modifiers. All 586 net
lines are the Apache license header (+6, prepended, which alone shifts every line by 6) plus
docstring/comment expansion from the task-399 documentation sweeps.

**Consequence**: **no module absorbs new declarations, because there are none.** The 10-module map
needs no re-partitioning — only re-anchoring. Growth is distributed near-uniformly (1.3%–6.5% per
module), exactly the signature of a whole-file comment sweep rather than a localized code addition.
There are no declarations that fail to fit the existing map.

| Module | plan-02 LOC | current LOC | Δ | % |
|---|---|---|---|---|
| A Slots | 849 | 904 | +55 | 6.5% |
| B OrderGate | 1434 | 1525 | +91 | 6.3% |
| C Carrier | 731 | 751 | +20 | 2.7% |
| D Completeness | 1053 | 1116 | +63 | 6.0% |
| E EngineInputs | 1331 | 1399 | +68 | 5.1% |
| F Soundness | 1510 | 1571 | +61 | 4.0% |
| G DisjunctionSpikes | 1192 | 1207 | +15 | 1.3% |
| H Assembly | 1664 | 1698 | +34 | 2.0% |
| I KitFold | 1702 | 1796 | +94 | 5.5% |
| J FragmentFoldRight | 1285 | 1364 | +79 | 6.1% |

### Structural Preconditions — re-verified against the current file

Every plan-02 precondition re-measured 2026-07-26:

| Precondition (plan 02) | Status | Current measurement |
|---|---|---|
| Single flat `namespace Bimodal.Metalogic.WeakCanonical.Kamp` | **CONFIRMED** | Sole `namespace` at :56; sole `end Bimodal.Metalogic.WeakCanonical.Kamp` at :13386 |
| Namespace band "50–12800" | **CHANGED** | Actually **56–13386**; the `50` was wrong even against the old file (imports at :7–8, module docstring :10–54) |
| Zero `section` / `mutual` | **CONFIRMED** | 0 occurrences at line start outside comments |
| Imports limited to `SubBracket2V` + `NavigatedSpine` | **CONFIRMED** | Exactly two `import` lines (:7, :8), unchanged |
| Three `open`s replicated by every submodule | **CONFIRMED** | `Bimodal.Syntax` (:58), `…WeakCanonical` (:59), `…WeakCanonical.Separation` (:60) — plan 02 cited these as ":52–54", now **:58–60** |
| File is "frozen" | **FALSE — now correctly characterized** | Four commits touched it 2026-07-25/26 (tasks 291, 292, 399, 400). It is NOT frozen; it is *declaration-stable*. See the Freeze Contract below. |
| 89 dangling `md:NN` citations | **CONFIRMED** | Exactly 89 (`md:77`×27, `md:168`×24, `md:154`×9, `md:72`×8, `md:61`×6, `md:91`×3, …) |
| Deleted-symbol comment residue | **CONFIRMED** | 23 comment references to `kvE2_sepArrL/R`, `kvE2_sepValid`, `kvE2_sepSingleton` |
| LITMUS anchor | **RE-ANCHORED** | `bracketEndChar_kvE2` decision-gate record is at `NavigatedSpine.lean:433/451/475`, not `:437`. Verify **by content**, never by line. |
| Sole live `sorry` | **RE-ANCHORED** | `Transfer.lean:1242`, inside the `countermodel_discrete` region (its docstring at :1206–1210 names it "the repository's sole live `sorry`"). Locate **by content**, never by line. Boneyard sorries are excluded by scope. |

**Freeze Contract (replaces plan 02's false freeze assertion)**: this plan does NOT assume the file
is frozen. It assumes only that the **declaration name sequence** is stable, and it is anchored to
that sequence. Phase 1 re-derives the current line numbers from the declaration names and confirms
the name sequence still matches the table below; a mechanical comment sweep landing mid-execution is
absorbed automatically rather than invalidating the plan.

### Research Integration

Adopts the current-tree synthesis (`reports/03_refactor-strategy-evaluation.md`), carried forward
from plan 02 unchanged:

- **Strategy**: *privatize-first-then-split* — privatize leaked-internal scaffolding while the file
  is still monolithic (mechanically safe: `private` restricts to file scope, so a green build after
  privatizing is the authoritative confirmation of "no external consumer"), then cut the linear
  tower into 10 modules + hub in strict backward (leaf-first) import order.
- **10-module map** (`Slots → OrderGate → Carrier → Completeness → EngineInputs → Soundness →
  DisjunctionSpikes → Assembly → KitFold → FragmentFoldRight → hub`); acyclic by construction (flat
  namespace, source-order cut).
- **`kvE2_sepBody` non-contiguity is DISSOLVED, not mitigated**, by the order-preserving cut: the
  def is the FIRST declaration of module Carrier and precedes every consumer
  (`kvE2_sepBody_extract` in Assembly, `kvE2_outer_fold_frag` in FragmentFoldRight), so no forward
  reference exists. Re-confirmed against the current file: `kvE2_sepBody` :2500 <
  `kvE2_sepBody_extract` :8961 < `kvE2_outer_fold_frag` :13247.
- **Named against real current symbols** (`kvE2_sepArr'`, `kvE2_sepDisjValidOwner`, `kvE2_sepPosI`,
  `kvE2_ordRank`, `kvE2_sepBody`, `kvE2_sepBody_extract`, `kvE2_sepHonest_hLR_absurd`,
  `kvE2_sepHonestOrder'` — all re-confirmed present), **never** the deleted
  `kvE2_sepArrL/R/Valid/Singleton/hLR`.

### Deltas from Plan 02 (beyond the line-anchor correction)

1. **Growth is documentation-only** (above). No new declarations; map unchanged.
2. **Symbol-provenance corrections to the Preserved Public API contract.** Two entries in plan 02's
   contract table attribute symbols to `SharedWitness.lean` that are not declared there:
   - The `nf0_*` family (`nf0_assemble`, `nf0_zoneSpec`, `nf0_zoneSpec_assemble`, `nf0_dropFresh`,
     `nf0_projFresh`, `nf0_split_assemble`, `nf0_dropFresh_assemble`, `nf0_projFresh_assemble`) is
     declared in **`Kamp/NfEFold.lean`**, reaching consumers transitively. The split cannot lose
     them; they are not in SharedWitness's 462-declaration inventory.
   - **`kvE2_sepFragment` is declared in `OuterGate.lean:223`** — OuterGate *declares* it, and
     OuterGate *imports* SharedWitness. Plan 02 had this dependency backwards. (The similarly-named
     `kvE2_sepFragment_frag` :10632 and `kvE2_sepFragment_realizable` :10679 ARE in SharedWitness,
     module I.) This matters: the hard rule forbidding a submodule from importing `OuterGate.lean`
     stands, and there is no tension, because SharedWitness never needed `kvE2_sepFragment`.
3. **`kvE2_sepPosI` is in module A (Slots), not module B (OrderGate).** `kvE2_sepPos` :204,
   `kvE2_sepPosI` :222, `kvE2_sepPosI_mem` :228 all precede module A's boundary. Plan 02's Phase 7
   goal and verification listed `kvE2_sepPosI` as a module-B move — corrected to Phase 6 here.
4. **Direct-importer set is narrower than plan 02 implied.** Exactly four files import
   `…NfMultiAnchorBridge.SharedWitness`: the aggregator `Kamp/NfMultiAnchorBridge.lean`,
   `Kamp/ExteriorNegation.lean`, `NfMultiAnchorBridge/ExteriorZoneTriage.lean`, and
   `NfMultiAnchorBridge/OuterGate.lean`. `KampPrior.lean` reaches it via the aggregator;
   `ExteriorNegationPast.lean` via `ExteriorNegation`; `ExteriorGateAssembleK.lean` transitively.
   All remain in the contract — the hub preserves all of them — but P2 should measure the
   transitive set deliberately rather than assuming direct imports.
5. **Dependent-task status refresh** (plan 02's guards branch on these):
   - **349 is now COMPLETED** (plan 02 guarded P17 on 349 being `[planned]`). P5/P17's guard is
     re-based: check what 349's *completed* execution did with `endIntervalStep`, not what its
     pending plan intended.
   - **356, 357, 359 are COMPLETED.** `Kamp/Boneyard/` still exists on disk; P18's "do not create
     new Boneyard files" direction stands on git-history-as-archive grounds regardless.
   - **358 is ABANDONED.** Plan 02 justified the KampPrior re-measure as "precisely the task-358
     preservation requirement". That rationale is void, but **the requirement is not**: KampPrior
     still consumes the API and must compile byte-unchanged. The non-goal "do not edit
     KampPrior.lean" now rests on plain scope, not on 358's territory.
6. **Effort-arithmetic note**: the per-phase timings below sum to ~30.5 h, while the headline
   `Effort` field reads 20 h (inherited from plan 02). The re-derivation does not change the work,
   so the headline is preserved; treat 20 h as the no-rework floor and ~30.5 h as the phase-sum
   estimate.

### Prior Plan Reference

`plans/02_module-split-refresh.md` is SUPERSEDED by this file (stale absolute line ranges, false
freeze assertion). Its strategy, module map, phase structure, contract discipline, and verification
bar are carried forward here unchanged. `plans/01_module-split-design.md` (five-seam, pre-growth,
335-gated) was already superseded by plan 02 and remains so.

### Roadmap Alignment

No `roadmap_flag` set for this dispatch; ROADMAP.md not consulted. The task advances the
NfMultiAnchorBridge carrier-layer maintainability goal recorded in the task description.

## Goals & Non-Goals

**Goals**:
- Split `SharedWitness.lean` into 10 cohesive sibling modules under `SharedWitness/`, each importing
  only earlier modules (strict backward tower), with every boundary specified by declaration
  identity.
- Preserve the **complete** external API — measured across `KampPrior.lean`, the converters,
  `ExteriorGateAssembleK`, `ExteriorNegation`/`Past`, `OuterGate`, `ExteriorZoneTriage`, and the
  aggregator — via a re-export hub, so no consumer file needs an edit.
- Privatize leaked-internal scaffolding (150 declarations are already `private`; the remaining
  candidates are re-counted in P2) to shrink cross-module coupling — behavior-preserving,
  green-build-verified.
- Keep the full-tree `lake build` GREEN and the `completeness_discrete` axiom set unchanged after
  every phase; zero sorries introduced; the `bracketEndChar_kvE2` LITMUS record and F1–F7 invariants
  preserved by non-modification.
- Improve API cohesion: `section` structure and docstrings grounding the design in Rabinovich Def
  3.1, citing **PDF page numbers only**.

**Non-Goals**:
- No semantic change: do NOT alter any proof, statement, definition body, or evaluation behavior.
- Do NOT split, rename, or refactor the carrier trio (`Base.lean`, `CarrierK1V.lean`,
  `CarrierKv.lean`) or `SubBracket2V.lean` — the ONLY exception is the guarded CarrierK1V
  dead-placeholder cleanup (P17).
- Do NOT rename any frozen-pinned public symbol; the `Sep.*` Mathlib-style rename is a deferred
  post-thaw task, not executed here.
- Do NOT fix the 89 `md:NN` citations wholesale — only re-cite comments the split actually touches.
- Do NOT edit `KampPrior.lean` or any file outside `NfMultiAnchorBridge/`.
- **Do NOT split any other file in `NfMultiAnchorBridge/`.** See "Out-of-Scope Follow-Up" below.

## Out-of-Scope Follow-Up (record, do NOT absorb)

`NfMultiAnchorBridge/` holds 33 files / 41,565 lines. This task splits `SharedWitness.lean` **only**.
Ten sibling files now exceed 1,000 lines and are candidates for their own split tasks — this is a
**recommendation to record after P20**, explicitly NOT work to absorb here:

| File | LOC | File | LOC |
|---|---|---|---|
| `InteriorGateGeneralK.lean` | 2552 | `AggregateOffDiagK1.lean` | 1561 |
| `SubBracket2V.lean` | 2263 | `ExteriorNavFutK1.lean` | 1503 |
| `Base.lean` | 2237 | `ExteriorPinnedConverseK.lean` | 1389 |
| `AggregateHookDischarge.lean` | 2191 | `ExteriorBracket.lean` | 1208 |
| `CarrierK1V.lean` | 2167 | `ExteriorNavPastK1.lean` | 1102 |

Any attempt to bring one of these into scope during execution is scope violation — file a new task.

## Preserved Public API Contract (binding — floor set; P2 finalizes)

The re-export hub MUST keep every symbol below importable with its current name and signature. P2
finalizes this set by direct re-measurement; the list here is the current-tree floor, with the
plan-02 provenance errors corrected.

| Consumer (MUST compile unchanged) | Symbols consumed from SharedWitness | Module |
|---|---|---|
| `Kamp/KampPrior.lean` (via aggregator) | `kvE2_sepPos`, `kvE2_sepPosI`, `kvE2_sepPosI_mem` | A |
| | `kvE2_sepPtW` | B |
| | `kvE2_sepFragment_frag`, `kvE2_sepFragment_realizable` | I |
| | `kvE2_sep_zXW3`, `kvE2_sep_zWT3` | A |
| `Kamp/ExteriorNegation.lean` (direct importer) | `kvE2_sepPos`; `kvE2_sep_z{XW3,WT3,AtT3,AtW3,AtX3,FutT3,PastX3}` | A |
| `Kamp/ExteriorNegationPast.lean` (via ExteriorNegation) | `kvE2_sep_z{AtT3,AtW3,AtX3,FutT3,PastX3,WT3,XW3}` | A |
| `NfMultiAnchorBridge/ExteriorGateAssembleK.lean` (transitive) | `kvE2_sep_zPastX3`, `kvE2_sep_zFutT3` | A |
| `NfMultiAnchorBridge/OuterGate.lean` (direct importer) | report-03 Group-set (gate/fold anchors) | P2 |
| `NfMultiAnchorBridge/ExteriorZoneTriage.lean` (direct importer) | report-03 zone/triage set | P2 |
| `Kamp/NfMultiAnchorBridge.lean` (aggregator) | re-export pass-through | — |

**Provenance corrections (do not re-introduce)**: the `nf0_*` family is declared in
`Kamp/NfEFold.lean` and `kvE2_sepFragment` in `OuterGate.lean:223`. Neither is a SharedWitness
declaration; neither can be lost by this split; neither belongs in the SharedWitness contract table.

**Contract rule**: a symbol appears in the contract iff any file OUTSIDE `SharedWitness/*` and
outside the hub references it. Everything else is internal scaffolding, free to privatize/scope. The
hub re-exports all contract symbols; because Lean re-exports imported decls transitively and the
aggregator imports the hub, KampPrior/converters/K-family see no change.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| **Line ranges drift again mid-execution** (this file has grown 4×) | H | H | **All boundaries are declaration-anchored.** Every phase re-derives its own line numbers from the anchor names at dispatch time. P1 confirms the 462-name sequence still matches; a comment sweep landing mid-execution is absorbed, not fatal |
| A privatized symbol is actually external | H | M | P2 re-measures the external surface (incl. KampPrior, converters, `ExteriorGateAssembleK`) BEFORE P3 privatizes; P3's own full-tree green build is the authoritative net — any failure ⇒ un-privatize that symbol + add to contract, never force |
| Hub drops a contract symbol, silently breaking consumers | H | M | Post-hub import-equivalence tripwire (P16): a throwaway `example` referencing every contract symbol through the hub; `git diff` must show KampPrior/OuterGate/ExteriorZoneTriage/ExteriorNegation(Past)/ExteriorGateAssembleK/aggregator UNTOUCHED across all phases |
| A verbatim move changes elaboration and shifts `completeness_discrete`'s axiom set | H | L | Full-tree `lake build` green + `lean_verify` on each module's anchors after every phase; axiom snapshot at P1 re-checked at P20; move verbatim, reopen the exact namespace, replicate the three `open`s (:58–60) |
| Oversized modules (I 1796, H 1698, F 1571 LOC) overflow a single agent run | M | H | Each extraction phase mandates ≤500-line verbatim green SUB-COMMITS (commit-per-green-substep); sub-phase budget cited per module; a phase may span multiple resumable dispatches |
| CarrierK1V dead-placeholder removal conflicts with 349's completed work | M | M | P17 is guarded: default PRESERVE-IN-PLACE + `NOTE:`; delete ONLY on fresh 0-consumer `lean_references` AND confirmation 349's completed execution abandoned the approach |
| `OrderGate.lean` (1525 LOC) unwieldy as one module | L | M | Pre-approved 11-module fallback: split B at the `## Order-type-disjunction index (RELOCATED above the carrier)` banner into `GateSegments` (`kvE2_sepSlotChi` … `kvE2_sepGate`, 23 decls) + `OrderRank` (`KvE2SepSpikeOrderType` … `kvE2_sepSlotsROf_mem`, 75 decls). Note the split is lopsided — `OrderRank` would still be ~1128 LOC — so it buys less than it appears to |
| `md:NN` citations propagated as valid into new modules | M | M | P5 registers every touched `md:NN`; P19 re-cites to Rabinovich PDF pages; **never copy `md:NN` forward** |
| Lake file+directory coexistence (`SharedWitness.lean` beside `SharedWitness/`) | L | L | Idiomatic Mathlib pattern; first extraction (P6) is the empirical confirmation |
| Plan-02 dead-block references cannot be located | L | M | Plan 02 cited "SW:899 STAGED, not yet wired" — that exact string exists in neither the old nor the current file; the nearest match is "DELIBERATELY not yet wired" at :970. P5 locates every dead-block candidate **by content**; unlocatable items are dropped, not guessed |

## Target Module Split — DECLARATION-ANCHORED (authoritative)

All modules reopen `namespace Bimodal.Metalogic.WeakCanonical.Kamp` and replicate the three `open`s
(`Bimodal.Syntax`, `…WeakCanonical`, `…WeakCanonical.Separation`, currently `SharedWitness.lean:58–60`).
Import order is strictly backward (acyclic by construction).

**The `First declaration` / `Last declaration` columns are the AUTHORITATIVE boundary
specification.** The `Lines (informational)` column is a measurement at `9f8e33d5a` (13,386 lines)
and is expected to drift; re-derive it at dispatch time by locating the anchor declarations. All ten
boundaries were verified to land on clean seams — a blank line after a completed proof, immediately
before a `/-!` section banner or a `/--` docstring — never mid-proof.

| # | Module (`…/SharedWitness/`) | First declaration (inclusive) | Last declaration (inclusive) | # decls | Lines (informational) | LOC | Imports | Sub-phase budget |
|---|---|---|---|---|---|---|---|---|
| A | `Slots.lean` | *file start*: `private instance : DecidableEq (ZoneSpec n)`; first named `kvE2_sep_zPastX3` | `kvE2_sepConsistentBlock_slotIndexOf` | 79 | 56–959 | 904 | `SubBracket2V`, `NavigatedSpine` | 2 |
| B | `OrderGate.lean` | `kvE2_sepSlotChi` | `kvE2_sepSlotsROf_mem` | 98 | 960–2484 | 1525 | `Slots` | 3 |
| C | `Carrier.lean` | `kvE2_sepBody` | `kvE2_sepCoincidentAnchor_discharge` | 24 | 2485–3235 | 751 | `OrderGate` | 2 |
| D | `Completeness.lean` | `kvE2_sepAllSlots_map_slotIndexOf_nodup` | `kvE2_sepHonest_rank_strictMono` | 42 | 3236–4351 | 1116 | `Carrier` | 3 |
| E | `EngineInputs.lean` | `kvE2_sepSlotGIdx_honestOrder` | `kvE2_sepHonest_witnesses` | 64 | 4352–5750 | 1399 | `Completeness` | 3 |
| F | `Soundness.lean` | `kvE2_sepPos_mem` | `kvE2_sepSegForm_excludes` | 51 | 5751–7321 | 1571 | `EngineInputs` | 4 |
| G | `DisjunctionSpikes.lean` | `kvE2_sepSpikeDisjValid` | `kvE2_sepEpR_eval_of_honest` | 37 | 7322–8528 | 1207 | `Soundness` | 3 |
| H | `Assembly.lean` | `kvE2_sepSlotGIdx_honestOrder'` | `kvE2_sepBody_holds_of_honest` | 40 | 8529–10226 | 1698 | `DisjunctionSpikes` | 4 |
| I | `KitFold.lean` | `kvE2_sepBundleL_sound` | `kvE2_sepGateAtPin_fragL` | 17 | 10227–12022 | 1796 | `Assembly` | 4 |
| J | `FragmentFoldRight.lean` | `kvE2_sep_rXW_mem_slotsLFor` | `kvE2_outer_fold_frag` (*last decl in file*) | 10 | 12023–13386 | 1364 | `KitFold` | 3 |
| — | `SharedWitness.lean` (hub) | — (zero decls) | — | 0 | — | ~30 | `FragmentFoldRight` (transitively all) | — |

**Partition check**: 79+98+24+42+64+51+37+40+17+10 = **462** = the full declaration inventory. The
partition is contiguous and exhaustive; no declaration is unassigned or double-assigned.

**Private/public split per module** (for P2/P3 sizing; 150 of 462 are already `private`):

| Module | A | B | C | D | E | F | G | H | I | J |
|---|---|---|---|---|---|---|---|---|---|---|
| public | 76 | 91 | 7 | 41 | 56 | 37 | 14 | 30 | 16 | 10 |
| private | 3 | 7 | 17 | 1 | 8 | 14 | 23 | 10 | 1 | 0 |

**Re-anchored landmarks** (plan-02 line citations, corrected):

| Landmark | Plan-02 citation | Declaration anchor | Current line | Module |
|---|---|---|---|---|
| Joint carrier def | `SW:2347` | `kvE2_sepBody` | 2500 | C |
| Extraction | `SW:8575` | `kvE2_sepBody_extract` | 8961 | H |
| hLR absurdity | `SW:6087` | `kvE2_sepHonest_hLR_absurd` | 6408 | F |
| ProjFresh eval | `SW:7297` | `kvE2_sepProjFresh_eval` | 7653 | G |
| Holds-of-honest | `SW:9800` | `kvE2_sepBody_holds_of_honest` | 10213 | H |
| Fragment frag / realizable | `SW:10219` / `SW:10265` | `kvE2_sepFragment_frag` / `_realizable` | 10632 / 10679 | I |
| **"Sixth-seam" block** | `SW:10210–12800` | **`kvE2_sepFragment_frag` → `kvE2_outer_fold_frag`** | 10632–13386 | tail of I + all of J |
| B fallback split point | `SW:1267` | banner `## Order-type-disjunction index (RELOCATED above the carrier)`, i.e. before `KvE2SepSpikeOrderType` | 1357 | B |
| O4 CRUX RECORD banner | `SW:6698` | `/-! ## O4 CRUX RECORD — verdict: **FAIL**` | 7206 | F |
| `hgate` residue | `SW:6528` | between `kvE2_sepBody_complete_holds'` and `kvE2_sepDisjunct_extract` | ~6850–6880 | F |
| "not yet wired" block | `SW:899` (string absent) | `"DELIBERATELY not yet wired"` | 970 | B |

Note the sixth-seam correction is not a simple offset: it spans the *tail of module I plus all of
module J*, not module J alone. Plan 02's phrasing attached it to Phase 15 (module J) only.

**Hard rule (binding)**: no `SharedWitness/*` submodule may import the hub, `OuterGate.lean`, or
`ExteriorZoneTriage.lean` — any such import closes a cycle. Extract strictly A→J.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4, 5 | 3 |
| 5 | 6 | 4, 5 |
| 6 | 7 | 6 |
| 7 | 8 | 7 |
| 8 | 9 | 8 |
| 9 | 10 | 9 |
| 10 | 11 | 10 |
| 11 | 12 | 11 |
| 12 | 13 | 12 |
| 13 | 14 | 13 |
| 14 | 15 | 14 |
| 15 | 16 | 15 |
| 16 | 17, 18 | 16 |
| 17 | 19 | 17, 18 |
| 18 | 20 | 19 |

Extraction phases (6–15) are strictly sequential (each imports the prior module). Phases 4/5 (design)
and 17/18 (guarded cleanup) are the only parallelizable pairs. Each extraction phase may internally
span multiple ≤500-line green sub-commits — the phase completes when its whole module is moved and
the full tree is green.

**Standing rule for every extraction phase**: locate the module's first and last declaration BY NAME
from the anchor table, then move that declaration span verbatim. Do not act on any absolute line
number recorded in this plan without re-deriving it first.

---

### Phase 1: GATE — Re-verify gates, re-derive anchors, snapshot baseline [COMPLETED]

**Goal**: Confirm all code-move gates are COMPLETED, confirm the declaration-anchor table still
matches the file, and record the green + axiom baseline. No code moved.

**Tasks**:
- [ ] Confirm 335, 337, 340, 346, 347, 348 all `completed` (they are archived in
  `specs/archive/state.json`; re-confirm at dispatch).
- [ ] Re-derive the declaration index: extract the ordered `(modifier, kind, name)` triple sequence
  of all top-level declarations in `SharedWitness.lean` (comment-aware scan). Confirm **462
  declarations** and that the 20 anchor names in the module table are present, in the stated order,
  with the stated per-module counts (79/98/24/42/64/51/37/40/17/10 = 462).
- [ ] Record the CURRENT line number of each anchor. If the count or order has changed, STOP and
  re-plan the affected module — do not proceed on a stale partition.
- [ ] Confirm structural preconditions: sole `namespace` line, sole `end` line, zero
  `section`/`mutual`, exactly two imports (`SubBracket2V`, `NavigatedSpine`), three `open`s.
- [ ] Baseline `lake build` full-tree GREEN.
- [ ] Snapshot `completeness_discrete` axioms via `lean_verify` (resolve exact FQ name at verify
  time); record the exact set (expect `{propext, Classical.choice, Quot.sound}`).
- [ ] Source-scan: 0 `sorry`/`admit` in code across `NfMultiAnchorBridge/`; confirm the sole live
  repository `sorry` is the one in `countermodel_discrete` (`Transfer.lean`) — located BY CONTENT.

**Timing**: ~0.5 hours

**Depends on**: none

**Files to modify**: none (baseline record appended to this plan or a sibling design note).

**Verification**: gates COMPLETED; 462-declaration anchor table confirmed; preconditions confirmed;
baseline green; axiom set recorded; sole live `sorry` unchanged.

---

### Phase 2: Re-measure the external API surface [COMPLETED]

**Goal**: Produce the authoritative Preserved-Public-API set. Design only; no code moved.

**Tasks**:
- [ ] For every top-level PUBLIC decl in `SharedWitness.lean` (312 of 462; the other 150 are already
  `private`), `grep -wF` its name across ALL files outside `SharedWitness/*` and the hub —
  specifically `KampPrior.lean`, `ExteriorNegation.lean`, `ExteriorNegationPast.lean`,
  `OuterGate.lean`, `ExteriorZoneTriage.lean`, `ExteriorGateAssembleK.lean`, the converters
  (`ExteriorConverterK/PastK`), the rest of the K-family, and the aggregator.
- [ ] Union the hits → the CONTRACT set (must be ⊇ the floor table above).
- [ ] Do NOT chase `nf0_*` or `kvE2_sepFragment` — they are declared in `NfEFold.lean` and
  `OuterGate.lean:223` respectively, not here (see Provenance corrections).
- [ ] The complement (public decls with 0 external hits) → the PRIVATIZE candidate set; count
  exactly.
- [ ] Record CONTRACT and PRIVATIZE sets, tagged with each symbol's module (A–J), in a design note
  under `plans/`.

**Timing**: ~1.5 hours

**Depends on**: 1

**Files to modify**: design note under `plans/` — no `.lean` edits.

**Verification**: CONTRACT ⊇ floor table; every KampPrior/ExteriorNegation(Past)/`ExteriorGateAssembleK`
symbol in CONTRACT; PRIVATIZE set exactly counted and module-tagged.

---

### Phase 3: Privatize leaked-internal scaffolding [COMPLETED]

**DEVIATION (altered)**: the privatize-first direction was inverted. Lean `private` is
*file*-scoped, so a symbol made private in the monolith becomes invisible to every later module
of the tower — privatizing MORE symbols before the cut would have had to be undone during
extraction. Measurement found the converse problem already present: **19 existing `private`
declarations are consumed across the planned module bands** and had to be made module-public
for the split to build at all. This phase de-privatized those 19 (each marked with a one-line
provenance comment) instead of adding privates. Re-privatizing per-module is now correct and
cheap to do as a follow-up, since `private` in a 900-1800 line module means what the plan
wanted it to mean.


**Goal**: Mark the P2 PRIVATIZE set `private` in place (single-file edit to the still-monolithic
`SharedWitness.lean`), shrinking coupling before any cut. Behavior-preserving.

**Tasks**:
- [ ] Add `private` to each P2 PRIVATIZE-set decl (keep `noncomputable` ordering correct).
- [ ] Full-tree `lake build` GREEN — the authoritative net: a failure on any symbol proves it IS
  external ⇒ revert that `private`, move the symbol into CONTRACT, re-record.
- [ ] `lean_verify` `completeness_discrete` axioms unchanged vs P1.
- [ ] Commit (`task 341 phase 3: privatize leaked-internal scaffolding`).

**Timing**: ~1.5 hours

**Depends on**: 2

**Files to modify**: `SharedWitness.lean` only (privatization; no moves).

**Verification**: full-tree green; axioms unchanged; 0 sorries; KampPrior/converters/K-family still
compile unchanged.

---

### Phase 4: Private cross-reference audit + cut-boundary DAG spec [COMPLETED]

**Goal**: Confirm no private symbol is orphaned from its consumer under the declaration-anchored
partition. Design only; no code moved. Parallel with P5.

**Tasks**:
- [ ] `lean_references` (or last-use grep) on every file-scoped private; record the NAME of its
  last-using declaration (not the line).
- [ ] Confirm the A→J order-preserving cut leaves each private's last use in its own or a later
  module; hoist any boundary-crossing private to the appropriate module and amend the anchor table.
- [ ] Confirm `kvE2_sepBody` (first decl of module C) precedes all consumers
  (`kvE2_sepBody_extract` in H, `kvE2_outer_fold_frag` in J) — non-contiguity dissolved; record.
- [ ] Capture the `open`/section context each module carries.
- [ ] Re-verify all ten cut points still land on clean seams (blank line after a completed proof,
  before a `/-!` banner or `/--` docstring) — never mid-proof.

**Timing**: ~1.5 hours

**Depends on**: 3

**Files to modify**: design note under `plans/` — no `.lean` edits.

**Verification**: DAG acyclic backward-only; every private's consumer in-module-or-later; all cut
points clean-seam-confirmed and declaration-anchored.

---

### Phase 5: Dead-code inventory + citation register + CarrierK1V placeholder audit [COMPLETED]

**DEVIATION (skipped)**: the `md:NN` citation register is moot. Commit `e70535a2a`
(*re-anchor 89 dangling md:NN citations to PDF page references*), landed by a concurrent
dispatch between this plan's baseline and the first code move, already converted all 89 to
PDF-page style. Zero `md:NN` remain anywhere in the tower. Only one stale `` `md:` `` pointer
survived, in the hub docstring preamble, and was re-cited in Phase 16.

**DEVIATION (skipped)**: the CarrierK1V `endIntervalStep`/`endInterval` placeholder audit found
the work already done — task 349's completed execution removed the skeleton to
`Kamp/Boneyard/NfMultiAnchorBridgeRetired/EndIntervalSkeleton.lean` and left a supersession
NOTE at `CarrierK1V.lean:2162`. See Phase 17.


**Goal**: Classify dead-code candidates and register touched `md:NN` citations. Design only. Parallel
with P4.

**Tasks**:
- [ ] Locate each dead-block candidate **BY CONTENT, never by line**: the "DELIBERATELY not yet
  wired" block (module B), the `/-! ## O4 CRUX RECORD — verdict: **FAIL**` banner (module F), the
  `hgate` residue between `kvE2_sepBody_complete_holds'` and `kvE2_sepDisjunct_extract` (module F).
  `lean_references`-confirm 0 live consumers for each. **If a candidate cannot be located by
  content, DROP it** — plan 02's "SW:899 STAGED, not yet wired" string does not exist in the file
  and must not be guessed at.
- [ ] Audit the `endIntervalStep`/`endInterval` `⟨[]⟩` placeholder in `CarrierK1V.lean` (locate by
  declaration name): fresh `lean_references`; cross-check task 349's **completed** record and the
  `InteriorGateGeneralK` comments referencing it; classify ARCHIVE / DELETE / PRESERVE-with-NOTE
  (default PRESERVE).
- [ ] Enumerate the 23 deleted-symbol comment residues (`kvE2_sepArrL/R`, `kvE2_sepValid`,
  `kvE2_sepSingleton`) for REWRITE/DROP.
- [ ] Register every `md:NN` citation the split will move/touch. Current inventory: **89 total** —
  `md:77`×27, `md:168`×24, `md:154`×9, `md:72`×8, `md:61`×6, `md:91`×3, remainder singletons.

**Timing**: ~1.5 hours

**Depends on**: 3

**Files to modify**: design note under `plans/` — no `.lean` edits.

**Verification**: every ARCHIVE/DELETE item has a 0-consumer confirmation AND was located by
content; unlocatable items dropped; uncertain items marked PRESERVE; 89-citation register complete.

---

### Phase 6: Extract Module A → `SharedWitness/Slots.lean` [COMPLETED]

**Goal**: Move the span from the file's first declaration through
**`kvE2_sepConsistentBlock_slotIndexOf`** (79 decls: slot/carrier types, zone constants per Def 3.1,
tagged joint slots, per-slot `Fin N` family, and the `kvE2_sepPos`/`kvE2_sepPosI`/`kvE2_sepPosI_mem`
contract trio). First move — validates the file+directory hub pattern. (~904 LOC; ~2 sub-commits.)

**Tasks**:
- [ ] Create `SharedWitness/Slots.lean`; reopen namespace; replicate the three `open`s.
- [ ] Move the anchored declaration span verbatim, in ≤500-line green sub-commits.
- [ ] Edit `SharedWitness.lean` to `import …SharedWitness.Slots`; delete the moved block.
- [ ] Full-tree `lake build` GREEN; `lean_verify` anchors + `completeness_discrete` axioms unchanged.

**Timing**: ~1.5 hours

**Depends on**: 4, 5

**Files to modify**: `SharedWitness/Slots.lean` (new); `SharedWitness.lean` (import + delete).

**Verification**: full-tree green; contract symbols `kvE2_sep_z{PastX3,AtX3,XW3,AtW3,WT3,AtT3,FutT3}`,
`kvE2_sepPos`, `kvE2_sepPosI`, `kvE2_sepPosI_mem` all land in `Slots.lean` and remain importable via
the hub; axioms unchanged; 0 sorries. Commit each green sub-step.

---

### Phase 7: Extract Module B → `SharedWitness/OrderGate.lean` [COMPLETED]

**Goal**: Move the span **`kvE2_sepSlotChi` → `kvE2_sepSlotsROf_mem`** (98 decls: `kvE2_sepPtW`,
`kvE2_sepGate`, `kvE2_ordRank`, `kvE2_sepDisjValidOwner`, `kvE2_sepArr'`, `KvE2SepSpikeOrderType`,
`KvE2SepWeakOrder`, endpoint predicates, refined segment types). (~1525 LOC; ~3 sub-commits.)

Note: `kvE2_sepPosI` is NOT in this module — it moved in Phase 6 (plan-02 misassignment corrected).

**Tasks**:
- [ ] Create `SharedWitness/OrderGate.lean` importing `Slots`; reopen namespace.
- [ ] Move the anchored declaration span verbatim, ≤500-line green sub-commits.
- [ ] If unwieldy: apply the pre-approved fallback — split at the `## Order-type-disjunction index
  (RELOCATED above the carrier)` banner into `GateSegments.lean` (`kvE2_sepSlotChi` …
  `kvE2_sepGate`, 23 decls) + `OrderRank.lean` (`KvE2SepSpikeOrderType` … `kvE2_sepSlotsROf_mem`,
  75 decls). The split is lopsided (~397 / ~1128 LOC) — apply only if genuinely needed.
- [ ] Wire import into hub; delete moved block; full-tree `lake build` GREEN.

**Timing**: ~2 hours

**Depends on**: 6

**Files to modify**: `SharedWitness/OrderGate.lean` (+ optional `GateSegments`/`OrderRank`);
`SharedWitness.lean`.

**Verification**: full-tree green; `lean_verify` `kvE2_sepGate`, `kvE2_ordRank`,
`kvE2_sepDisjValidOwner`, `kvE2_sepArr'`; `kvE2_sepPtW` (KampPrior contract) importable via hub;
axioms unchanged; 0 sorries.

---

### Phase 8: Extract Module C → `SharedWitness/Carrier.lean` [COMPLETED]

**Goal**: Move the span **`kvE2_sepBody` → `kvE2_sepCoincidentAnchor_discharge`** (24 decls,
17 already private: the joint carrier def, `kvE2_sepGate_holds_of_honest`, Group-3/4 heads).
(~751 LOC; ~2 sub-commits.)

**Tasks**:
- [ ] Create `SharedWitness/Carrier.lean` importing `OrderGate`; reopen namespace.
- [ ] Move the anchored span verbatim; confirm `kvE2_sepBody` is the FIRST declaration of this
  module and that all its consumers are in later modules.
- [ ] Wire hub import; delete moved block; full-tree `lake build` GREEN.

**Timing**: ~1.5 hours

**Depends on**: 7

**Files to modify**: `SharedWitness/Carrier.lean` (new); `SharedWitness.lean`.

**Verification**: full-tree green; `lean_verify` `kvE2_sepBody`, `kvE2_sepGate_holds_of_honest`;
axioms unchanged; 0 sorries.

---

### Phase 9: Extract Module D → `SharedWitness/Completeness.lean` [COMPLETED]

**Goal**: Move the span **`kvE2_sepAllSlots_map_slotIndexOf_nodup` → `kvE2_sepHonest_rank_strictMono`**
(42 decls: `kvE2_sepBody_complete` and the Group-4 completeness reduction). (~1116 LOC; ~3 sub-commits.)

**Tasks**:
- [ ] Create `SharedWitness/Completeness.lean` importing `Carrier`; reopen namespace.
- [ ] Move the anchored span verbatim, ≤500-line green sub-commits.
- [ ] Wire hub import; delete moved block; full-tree `lake build` GREEN.

**Timing**: ~2 hours

**Depends on**: 8

**Files to modify**: `SharedWitness/Completeness.lean` (new); `SharedWitness.lean`.

**Verification**: full-tree green; `lean_verify` `kvE2_sepBody_complete`; axioms unchanged; 0 sorries.

---

### Phase 10: Extract Module E → `SharedWitness/EngineInputs.lean` [COMPLETED]

**Goal**: Move the span **`kvE2_sepSlotGIdx_honestOrder` → `kvE2_sepHonest_witnesses`** (64 decls:
the task-337 engine inputs; internal-only, no frozen-pinned symbol). (~1399 LOC; ~3 sub-commits.)

**Tasks**:
- [ ] Create `SharedWitness/EngineInputs.lean` importing `Completeness`; reopen namespace.
- [ ] Move the anchored span verbatim, ≤500-line green sub-commits.
- [ ] Wire hub import; delete moved block; full-tree `lake build` GREEN.

**Timing**: ~2 hours

**Depends on**: 9

**Files to modify**: `SharedWitness/EngineInputs.lean` (new); `SharedWitness.lean`.

**Verification**: full-tree green; axioms unchanged; 0 sorries.

---

### Phase 11: Extract Module F → `SharedWitness/Soundness.lean` [COMPLETED]

**Goal**: Move the span **`kvE2_sepPos_mem` → `kvE2_sepSegForm_excludes`** (51 decls:
`kvE2_sepHonest_hLR_absurd`, `kvE2_sepHonestOrder'`, honest-order soundness, the O4 CRUX RECORD
banner and the `hgate` residue block). (~1571 LOC; ~4 sub-commits.)

**Tasks**:
- [ ] Create `SharedWitness/Soundness.lean` importing `EngineInputs`; reopen namespace.
- [ ] Move the anchored span verbatim, ≤500-line green sub-commits.
- [ ] Carry the P5 dead-block classifications for the CRUX RECORD / `hgate` residue into this move
  (resolution itself happens in P18).
- [ ] Wire hub import; delete moved block; full-tree `lake build` GREEN.

**Timing**: ~2 hours

**Depends on**: 10

**Files to modify**: `SharedWitness/Soundness.lean` (new); `SharedWitness.lean`.

**Verification**: full-tree green; `lean_verify` `kvE2_sepHonest_hLR_absurd`, `kvE2_sepHonestOrder'`;
axioms unchanged; 0 sorries.

---

### Phase 12: Extract Module G → `SharedWitness/DisjunctionSpikes.lean` [COMPLETED]

**Goal**: Move the span **`kvE2_sepSpikeDisjValid` → `kvE2_sepEpR_eval_of_honest`** (37 decls, 23
already private: `kvE2_sepProjFresh_eval` and the disjunction-spike machinery). (~1207 LOC;
~3 sub-commits.)

**Tasks**:
- [ ] Create `SharedWitness/DisjunctionSpikes.lean` importing `Soundness`; reopen namespace.
- [ ] Move the anchored span verbatim, ≤500-line green sub-commits.
- [ ] Wire hub import; delete moved block; full-tree `lake build` GREEN.

**Timing**: ~2 hours

**Depends on**: 11

**Files to modify**: `SharedWitness/DisjunctionSpikes.lean` (new); `SharedWitness.lean`.

**Verification**: full-tree green; `lean_verify` `kvE2_sepProjFresh_eval`; axioms unchanged; 0 sorries.

---

### Phase 13: Extract Module H → `SharedWitness/Assembly.lean` [COMPLETED]

**DEVIATION (altered)**: the first cut placed `kvE2_sepSlotGIdx_honestOrder'` at the tail of
module G (38/39 instead of 37/40) because the anchor-matching regex's word boundary after the
primed name's apostrophe matched `kvE2_sepSlotGIdx_honestOrder'_mono` instead. Corrected in
Phase 16: the declaration and its section banner were moved to the head of `Assembly.lean`,
restoring the plan's 37/40 split.

**Goal**: Move the span **`kvE2_sepSlotGIdx_honestOrder'` → `kvE2_sepBody_holds_of_honest`** (40
decls: `kvE2_sepBody_extract`, O4 assembly). (~1698 LOC; ~4 sub-commits.)

**Tasks**:
- [ ] Create `SharedWitness/Assembly.lean` importing `DisjunctionSpikes`; reopen namespace.
- [ ] Move the anchored span verbatim, ≤500-line green sub-commits.
- [ ] Wire hub import; delete moved block; full-tree `lake build` GREEN.

**Timing**: ~2 hours

**Depends on**: 12

**Files to modify**: `SharedWitness/Assembly.lean` (new); `SharedWitness.lean`.

**Verification**: full-tree green; `lean_verify` `kvE2_sepBody_extract`,
`kvE2_sepBody_holds_of_honest`; axioms unchanged; 0 sorries.

---

### Phase 14: Extract Module I → `SharedWitness/KitFold.lean` [COMPLETED]

**Goal**: Move the span **`kvE2_sepBundleL_sound` → `kvE2_sepGateAtPin_fragL`** (17 decls:
`kvE2_outer_fold`, the KampPrior-contract `kvE2_sepFragment_frag`/`_realizable`, per-σ kit). This
module holds the FRONT of the "sixth-seam" block, which begins at `kvE2_sepFragment_frag` and runs
to end of file. (~1796 LOC — the largest module; ~4 sub-commits.)

**Tasks**:
- [ ] Create `SharedWitness/KitFold.lean` importing `Assembly`; reopen namespace.
- [ ] Move the anchored span verbatim, ≤500-line green sub-commits.
- [ ] Wire hub import; delete moved block; full-tree `lake build` GREEN.

**Timing**: ~2 hours

**Depends on**: 13

**Files to modify**: `SharedWitness/KitFold.lean` (new); `SharedWitness.lean`.

**Verification**: full-tree green; `lean_verify` `kvE2_sepFragment_frag`,
`kvE2_sepFragment_realizable`; KampPrior contract symbols importable via hub; axioms unchanged;
0 sorries.

---

### Phase 15: Extract Module J → `SharedWitness/FragmentFoldRight.lean` [COMPLETED]

**Goal**: Move the span **`kvE2_sep_rXW_mem_slotsLFor` → `kvE2_outer_fold_frag`** (10 decls, all
public, none private: `kvE2_sepGateAtPin_fragR`, `kvE2_sepBody_kit_sound_frag`,
`kvE2_sepInterior_exterior_notRealizable`, `kvE2_outer_fold_frag`). This is the TAIL of the
"sixth-seam" block and runs to the file's last declaration. (~1364 LOC; ~3 sub-commits.)

**Tasks**:
- [ ] Create `SharedWitness/FragmentFoldRight.lean` importing `KitFold`; reopen namespace.
- [ ] Move the anchored span verbatim, ≤500-line green sub-commits.
- [ ] Wire hub import; delete moved block; full-tree `lake build` GREEN.

**Timing**: ~2 hours

**Depends on**: 14

**Files to modify**: `SharedWitness/FragmentFoldRight.lean` (new); `SharedWitness.lean`.

**Verification**: full-tree green; `lean_verify` `kvE2_sepBody_kit_sound_frag`,
`kvE2_outer_fold_frag`; axioms unchanged; 0 sorries.

---

### Phase 16: Hub reduction + import-equivalence tripwire [COMPLETED]

**Goal**: Reduce `SharedWitness.lean` to a documented re-export hub; prove the full external contract
is preserved. `SharedWitness.lean` holds zero decls.

**Tasks**:
- [ ] Reduce `SharedWitness.lean` to `import` of all 10 modules + module docstring; confirm 0
  top-level declarations (re-run the P1 declaration scan against the hub — expect 0).
- [ ] Import-equivalence tripwire: a throwaway `example`/`#check` referencing EVERY
  Preserved-Public-API contract symbol through the hub (catches any dropped decl).
- [ ] Confirm the 10 modules' declaration counts sum to 462 — none lost, none duplicated.
- [ ] `git diff` confirms `KampPrior.lean`, `OuterGate.lean`, `ExteriorZoneTriage.lean`,
  `ExteriorNegation(Past).lean`, `ExteriorGateAssembleK.lean`, aggregator ALL untouched.
- [ ] Full-tree `lake build` GREEN; `completeness_discrete` axioms unchanged.

**Timing**: ~1 hour

**Depends on**: 15

**Files to modify**: `SharedWitness.lean` (now hub-only, ~30 lines).

**Verification**: full-tree green; hub holds 0 decls; 462 declarations conserved across the 10
modules; every contract symbol resolves via hub; downstream files byte-unchanged; axioms unchanged.

---

### Phase 17: Guarded CarrierK1V dead-placeholder cleanup [COMPLETED]

**DEVIATION (skipped — no-op)**: nothing to do. The placeholder was already archived to
`Boneyard/NfMultiAnchorBridgeRetired/EndIntervalSkeleton.lean`, and `CarrierK1V.lean` already
carries an adequate NOTE naming both the archive and the live replacement
(`endIntervalStepPrior` in `EndIntervalConsumerK.lean`). `CarrierK1V.lean` was NOT modified.


**Goal**: Resolve the superseded `endIntervalStep`/`endInterval` `⟨[]⟩` placeholder per P5's audit.
Parallel with P18.

**Tasks**:
- [ ] Re-run `lean_references` on `endIntervalStep`/`endInterval` in `CarrierK1V.lean` (locate by
  declaration name, not line); re-check task 349's completed record.
- [ ] If 0 consumers AND 349's completed execution confirmed to have abandoned the endIntervalStep
  approach: remove verbatim (git history is the archive). ELSE: add a `NOTE:`/`QUESTION:` comment
  cross-referencing the `endIntervalStepPrior`/`EndIntervalConsumerK` supersession and leave in place.
- [ ] Full-tree `lake build` GREEN.

**Timing**: ~0.5 hours

**Depends on**: 16

**Files to modify**: `CarrierK1V.lean` (removal or `NOTE:` only — no other change).

**Verification**: full-tree green; axioms unchanged; 0 sorries; no live consumer lost.

---

### Phase 18: Deleted-symbol comment cleanup + dead-block resolution [COMPLETED]

**DEVIATIONS**:
- *(altered)* The 23 deleted-symbol residues were reviewed rather than rewritten wholesale.
  All but one already frame `kvE2_sepValid` / `kvE2_sepArrL` / `kvE2_sepArrR` /
  `kvE2_sepSingleton` explicitly as removed or replaced, so they do not propagate the symbols
  as live. Several apparent hits are the LIVE declaration `kvE2_sepValid_tie_of_nodup` matching
  on a name prefix. The one genuinely misleading case — the "DELIBERATELY not yet wired"
  banner in `OrderGate.lean`, whose wiring narrative names removed symbols while documenting
  live definitions — was PRESERVED with a `NOTE:` per the preserve-over-delete direction.
- *(skipped)* The `hgate` residue candidate could not be located as dead code: the region
  between `kvE2_sepBody_complete_holds'` and `kvE2_sepDisjunct_extract` is a live docstring.
  Dropped per this plan's own "unlocatable items are dropped, not guessed" rule.
- *(altered)* The O4 CRUX RECORD banner was PRESERVED unchanged. It is self-labelled
  "inert; decision-gate input" — a deliberate decision record, not dead code.
- *(added)* Work not anticipated by the plan: **22 `SW:NNNN` monolith line pointers** were
  stripped. The split made them doubly stale, and spot-checking showed they no longer resolved
  to the declarations their prose names, so they were removed rather than re-anchored —
  re-resolving would have fabricated citations, the same hazard as `md:NN`.


**Goal**: Rewrite/drop deleted-symbol comment residue; resolve P5-confirmed dead code (prefer
git-history-as-archive). Parallel with P17.

**Tasks**:
- [ ] Rewrite or drop the 23 `kvE2_sepArrL/R` / `kvE2_sepValid` / `kvE2_sepSingleton` comment
  residues — do NOT propagate them as if the symbols exist.
- [ ] For each P5-confirmed 0-consumer dead block (the "DELIBERATELY not yet wired" block in
  `OrderGate.lean`, the O4 CRUX RECORD banner and `hgate` residue in `Soundness.lean`): DELETE (git
  history archives) unless still uncertain, in which case `NOTE:`/`QUESTION:` in place. Do NOT
  create new `Kamp/Boneyard/` files.
- [ ] Full-tree `lake build` GREEN.

**Timing**: ~1 hour

**Depends on**: 16

**Files to modify**: the relevant `SharedWitness/*.lean` modules (comment/dead-code edits).

**Verification**: full-tree green; no deleted-symbol residue propagated; axioms unchanged; 0 sorries.

---

### Phase 19: API & documentation pass (citation re-grounding) [COMPLETED]

**DEVIATION (altered)**: the per-module docstrings were written inline during each extraction
phase rather than as a separate pass, so each module landed self-documenting. No `section`
structure was added: the modules are already 750-1800 lines with `/-! ## ` banners throughout,
and adding `section` would have been the plan's one non-behaviour-preserving structural risk
for no navigational gain.


**Goal**: Add `section` structure + per-module docstrings; re-cite touched `md:NN` comments to
Rabinovich PDF page numbers.

**Citation rule (binding)**: the 89 `md:NN` references point into a Rabinovich markdown that was
replaced by a PDF text-extract; the line references are meaningless. By deliberate user decision
they are left UNFIXED wholesale — but this refactor MOVES those comments between modules and MUST
NOT silently propagate them as if valid. **Where the refactor touches an `md:NN` citation, re-cite
by Rabinovich PDF page. Cite by PDF page only, never `md:NN`.** The codebase already uses this style
(e.g. `Rabinovich §5 (p.7…)` at the current :216, :418, :3439, :3544, :7615).

**Tasks**:
- [ ] Per-module file docstrings grounding the value-faithful per-slot design in Rabinovich Def 3.1 /
  Lemma 3.2(1) / Cor 5.4, citing PDF pages, never `md:NN`.
- [ ] Re-cite every P5-registered touched `md:NN` to Rabinovich PDF pages; for modules I/J re-ground
  in the revised Prop 4.3 treatment.
- [ ] Any `md:NN` NOT touched by the split stays as-is (the deliberate user decision) — do not
  expand scope into a wholesale citation fix.
- [ ] Full-tree `lake build` GREEN (docstring/section edits must not change elaboration).

**Timing**: ~1.5 hours

**Depends on**: 17, 18

**Files to modify**: all `SharedWitness/*.lean` + hub — docstrings, sections, re-cited comments.

**Verification**: full-tree green; **zero `md:NN` in any comment the split touched**; untouched
`md:NN` count accounted for against the P5 register (89 minus touched); axioms unchanged; 0 sorries.

---

### Phase 20: Final verification + follow-up recording [COMPLETED]

**Goal**: Confirm all invariants preserved across the completed refactor.

**Tasks**:
- [ ] Full-tree `lake build` GREEN (from clean if budget allows); `BimodalTest` GREEN.
- [ ] `lean_verify` `completeness_discrete` → axiom set EXACTLY equals the P1 snapshot
  (`{propext, Classical.choice, Quot.sound}`).
- [ ] `lean_verify` on all Preserved-Public-API anchors → same axiom set.
- [ ] Confirm the sole live repository `sorry` count is unchanged — locate it BY CONTENT in
  `Metalogic/WeakCanonical/Transfer.lean` (`countermodel_discrete`), NEVER by line number.
- [ ] Source-scan 0 `sorry`/`admit` in code across all new modules.
- [ ] Confirm the `bracketEndChar_kvE2` LITMUS record in `NavigatedSpine.lean` is byte-unchanged
  (341 never edits NavigatedSpine) — verify BY CONTENT, not by line; and F1–F7 intact (no
  statement/proof altered).
- [ ] Confirm downstream files (KampPrior, OuterGate, ExteriorZoneTriage, ExteriorNegation(Past),
  ExteriorGateAssembleK, aggregator) byte-unchanged.
- [ ] Record the out-of-scope follow-up recommendation: the ten `NfMultiAnchorBridge/` siblings over
  1,000 LOC (table above) as candidate split tasks. **Record only — do not create or execute them
  here.**
- [ ] Write execution summary.

**Timing**: ~1 hour

**Depends on**: 19

**Files to modify**: `specs/341_.../summaries/03_module-split-summary.md` (new).

**Verification**: full green; `BimodalTest` green; axioms == P1 snapshot; sole live `sorry` count
unchanged; 0 new sorries; LITMUS + F1–F7 preserved; full external API import-equivalent; downstream
unchanged; follow-up recorded. Final commit.

---

## Testing & Validation

- [ ] Full-tree `lake build` GREEN after EVERY phase (3, 6–20) — scoped `lake build <Module>` first
  for speed, then full (proves hub re-export + KampPrior/converters/K-family still compile).
- [ ] `BimodalTest` GREEN at P20.
- [ ] `completeness_discrete` axiom set unchanged vs the P1 snapshot (bookend P1↔P20; per-phase if
  budget allows).
- [ ] `lean_verify` on each module's anchors → `{propext, Classical.choice, Quot.sound}`.
- [ ] 0 `sorry`/`admit` in code across all new modules at every phase; the sole live repository
  `sorry` (`countermodel_discrete` in `Transfer.lean`, located by content) unchanged in count.
- [ ] Declaration conservation: the 10 modules' declaration counts sum to 462 at P16.
- [ ] `git diff` shows KampPrior/OuterGate/ExteriorZoneTriage/ExteriorNegation(Past)/
  ExteriorGateAssembleK/aggregator UNTOUCHED across all 20 phases (import-preservation tripwire).
- [ ] `bracketEndChar_kvE2` LITMUS record byte-unchanged (verified by content); no `md:NN`
  propagated as valid into any touched comment.
- [ ] No file under `NfMultiAnchorBridge/` other than `SharedWitness.lean`, the new
  `SharedWitness/*` modules, and (guarded) `CarrierK1V.lean` is modified.

## Artifacts & Outputs

- `plans/03_declaration-anchored-module-split.md` (this file; P1–P5 append design decisions and
  inventories).
- `NfMultiAnchorBridge/SharedWitness/{Slots,OrderGate,Carrier,Completeness,EngineInputs,Soundness,
  DisjunctionSpikes,Assembly,KitFold,FragmentFoldRight}.lean` (+ optional `GateSegments`/`OrderRank`).
- `NfMultiAnchorBridge/SharedWitness.lean` — reduced to a documented re-export hub.
- `specs/341_.../summaries/03_module-split-summary.md`.

## Rollback/Contingency

- Each phase is an independent green commit; roll back a failed phase via `git revert` — earlier
  extractions remain valid.
- The 20-phase plan spans multiple `/implement` dispatches; the phase table is the resume ledger.
  Because moves are verbatim and the hub preserves the API, re-inlining a moved block is mechanical.
- **If the file grows again mid-execution**: this is expected and NOT a re-plan trigger. Re-derive
  the current line numbers from the declaration anchor names and continue. A re-plan is required
  only if the P1 declaration-name scan shows the *name sequence* changed — i.e. declarations were
  added, removed, or reordered — in which case amend the affected module's anchor pair and its
  declaration count, and re-verify the 462-conservation total.
- If P3 privatization or any extraction cannot land green, restore the pre-phase state, mark the
  phase `[PARTIAL]`, record the failing symbol/anchor, and refine (un-privatize the external symbol,
  or sub-split the module) before retry.
- If P17's `CarrierK1V` audit is inconclusive, default to PRESERVE-IN-PLACE-with-NOTE — never delete
  on suspicion.
