# Implementation Plan: Task #341 — SharedWitness Module-Split (Fresh, Current-Tree)

- **Task**: 341 - structural_refactor_sharedwitness_carrier_layer
- **Status**: [NOT STARTED]
- **Effort**: 20 hours
- **Dependencies**: 335 [done], 337 [done], 340 [done], 346 [done], 347 [done], 348 [done] — **all code-move gates SATISFIED**
- **Research Inputs**: reports/03_refactor-strategy-evaluation.md (primary, current-tree), reports/01_sharedwitness-declaration-survey.md, reports/02_post-kamp-revision-realignment.md, reports/03_teammate-{a,b,c}-*.md
- **Artifacts**: plans/02_module-split-refresh.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md; lean4.md; git-workflow.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

`SharedWitness.lean` is **12,800 lines** (verified current: single flat
`namespace Bimodal.Metalogic.WeakCanonical.Kamp`, lines 50–12800, zero `section`/`mutual`, imports
only `SubBracket2V` + `NavigatedSpine`). This plan splits it along the research-verified 10-module
map into sibling modules under a new `NfMultiAnchorBridge/SharedWitness/` subdirectory, reducing
`SharedWitness.lean` to a thin **re-export hub** so every import site is preserved. This is a
**purely structural, behavior-preserving** refactor: no proof, statement, definition body, or
evaluation behavior changes; the full-tree `lake build` stays GREEN and the axiom set on
`completeness_discrete` (`BXCanonical/Completeness.lean:276`) stays unchanged after every phase. It
is a re-export/module-split, **not** a re-proof.

This is a FRESH re-plan against the CURRENT tree; it supersedes `plans/01_module-split-design.md`
(stale five-seam design, pre-growth line counts, gated on the now-COMPLETED task 335).

### Research Integration

Adopts the current-tree synthesis (`reports/03_refactor-strategy-evaluation.md`):
- **Strategy**: *privatize-first-then-split* — privatize leaked-internal scaffolding while the file
  is still monolithic (mechanically safe: `private` restricts to file scope; a green build after
  privatizing is the authoritative confirmation of "no external consumer"), then cut the linear
  tower into 10 modules + hub in strict backward (leaf-first) import order.
- **10-module map** (`Slots → OrderGate → Carrier → Completeness → EngineInputs → Soundness →
  DisjunctionSpikes → Assembly → KitFold → FragmentFoldRight → hub`), the only map measured against
  the current 12,800-line HEAD; acyclic by construction (flat namespace, source-order cut).
- **`kvE2_sepBody` non-contiguity is DISSOLVED, not mitigated**, by the order-preserving cut: def
  (:2347, module Carrier) precedes every consumer (`_extract` :8575 in Assembly, `outer_fold` in
  FragmentFoldRight), so no forward reference exists.
- **Named against real current symbols** (`kvE2_sepArr'`, `kvE2_sepDisjValidOwner`, `kvE2_sepPosI`,
  `kvE2_ordRank`, `kvE2_sepBody`, `kvE2_sepBody_extract`, `kvE2_sepHonest_hLR_absurd`,
  `kvE2_sepHonestOrder'`), **never** the deleted `kvE2_sepArrL/R/Valid/Singleton/hLR`.

### Deltas from Research — the tree changed AGAIN after report 03 (this plan accounts for them)

1. **All code-move gates are now COMPLETED** (335, 337, 340, 346, 347, 348). Report 03 gated on
   348 "must reach COMPLETED + frozen"; it now HAS. The GATE phase (P1) is a fast re-verification,
   not a blocker. `SharedWitness.lean` is confirmed frozen (12,800 lines, mtime predates the recent
   356/357 leaf work).
2. **The "31 external symbols" API figure is STALE/INCOMPLETE.** Report 03 measured external
   consumption over `{OuterGate, ExteriorZoneTriage, ExteriorBracket, ExteriorNegation,
   ExteriorNegationPast}` and MISSED `Kamp/KampPrior.lean`, which is a heavy consumer:
   `kvE2_sepFragment`, `kvE2_sepFragment_frag`, `kvE2_sepFragment_realizable`, `kvE2_sepPos`,
   `kvE2_sepPosI`, `kvE2_sepPosI_mem`, `kvE2_sepPtW`, `kvE2_sep_zXW3`, `kvE2_sep_zWT3`,
   `nf0_assemble`, `nf0_zoneSpec`, `nf0_zoneSpec_assemble`. **P2 re-measures the external surface
   including KampPrior and the converters** before any privatization. This is precisely the task-358
   preservation requirement (358 edits KampPrior.lean and consumes these interfaces).
3. **Two NEW leaf modules** were added by tasks 356/357 into `NfMultiAnchorBridge/`:
   `ExteriorGateAssembleK.lean` and `EndIntervalConsumerK.lean`. Neither imports `SharedWitness`
   directly (they are the general-`k` "K" architecture). BUT `ExteriorGateAssembleK` (356) DOES
   consume `SharedWitness` zone constants transitively — `kvE2_sep_zPastX3` (:201),
   `kvE2_sep_zFutT3` (:223), `nf0_zoneSpec` — so those symbols join the preserved-API contract.
   Folding-in verdict: the K-family/converters are **disjoint from the split** (0 direct
   `SharedWitness` imports across `ExteriorConverterK/PastK`, `ExteriorBracketK`, `ExteriorFiberK`,
   `InteriorGateGeneralK`, `ExteriorNegationK/PastK`) but sit in `completeness_discrete`'s build
   cone, so **full-tree green** (not scoped-only) is the binding verification after every phase.
4. **CarrierK1V.lean:2144 dead `⟨[]⟩` placeholder** (`endIntervalStep`/`endInterval`, task-349
   Phase-2 HOLE) is a *guarded* cleanup candidate — superseded by 357's `endIntervalStepPrior`
   (EndIntervalConsumerK), with no live *code* consumers outside CarrierK1V, BUT
   `InteriorGateGeneralK:18` comments "task 349 Phase 5 can fill the endIntervalStep body" and task
   349 is still `[planned]`. Treated as PRESERVE-IN-PLACE-with-NOTE by default (P17), deletable only
   if a fresh `lean_references` shows 0 consumers AND 349's live plan confirms the approach is
   abandoned.
5. **Task 359** (Boneyard deletion, scope `Kamp/Boneyard/`, dep 303, not started) is file-disjoint;
   its deletion direction means wholesale Boneyard *archival* of 341's residue is lower priority —
   prefer git-history-as-archive + `NOTE:` over creating new soon-to-be-deleted Boneyard files
   (P18).

### Prior Plan Reference

`plans/01_module-split-design.md` (five-seam, pre-growth sizes, 335-gated) is superseded. Retained
as reference for the re-export-hub pattern and the verbatim-move discipline, both carried forward.
Report 03 already reconciled it against current HEAD.

### Roadmap Alignment

No `roadmap_flag` set for this dispatch; ROADMAP.md not consulted. The task advances the
NfMultiAnchorBridge carrier-layer maintainability goal recorded in the task description.

## Goals & Non-Goals

**Goals**:
- Split `SharedWitness.lean` into 10 cohesive sibling modules under `SharedWitness/`, each importing
  only earlier modules (strict backward tower).
- Preserve the **complete** external API — re-measured to include `KampPrior.lean`, the converters,
  `ExteriorGateAssembleK` (356), `ExteriorNegation/Past`, `OuterGate`, `ExteriorZoneTriage`, and the
  aggregator — via a re-export hub, so no consumer file needs an edit.
- Privatize leaked-internal scaffolding (research-estimated ~346 symbols, re-counted in P2) to shrink
  cross-module coupling — behavior-preserving, green-build-verified.
- Keep the full-tree `lake build` GREEN and the `completeness_discrete` axiom set unchanged after
  every phase; zero sorries introduced; LITMUS (`NavigatedSpine.lean:437`) and F1–F7 invariants
  preserved by non-modification.
- Improve API cohesion: `section` structure and docstrings grounding the design in Rabinovich Def
  3.1 (cite PDF pages), re-citing touched `md:NN` comments.

**Non-Goals**:
- No semantic change: do NOT alter any proof, statement, definition body, or evaluation behavior.
- Do NOT split, rename, or refactor the carrier trio (`Base.lean`, `CarrierK1V.lean`,
  `CarrierKv.lean`) or `SubBracket2V.lean` (report 03 Conflict 3; `SubBracket2V` is frozen by 349) —
  the ONLY exception is the guarded CarrierK1V:2144 dead-placeholder cleanup (P17).
- Do NOT rename any of the frozen-pinned public symbols (all consumed by frozen/disjoint files);
  the `Sep.*` Mathlib-style rename is a deferred post-thaw task, not executed here.
- Do NOT fix the 89 `md:NN` citations wholesale — only re-cite comments the split actually touches.
- Do NOT edit `KampPrior.lean` (task-358 territory) or any file outside `NfMultiAnchorBridge/`.

## Preserved Public API Contract (binding — re-measured, supersedes report 03's 31-symbol set)

The re-export hub MUST keep every symbol below importable with its current name and signature. P2
finalizes this set by direct `grep -wF` re-measurement; the list here is the current-tree floor:

| Consumer (frozen/disjoint — MUST compile unchanged) | Symbols it consumes from SharedWitness |
|---|---|
| `Kamp/KampPrior.lean` (task-358 territory) | `kvE2_sepFragment`, `kvE2_sepFragment_frag`, `kvE2_sepFragment_realizable`, `kvE2_sepPos`, `kvE2_sepPosI`, `kvE2_sepPosI_mem`, `kvE2_sepPtW`, `kvE2_sep_zXW3`, `kvE2_sep_zWT3`, `nf0_assemble`, `nf0_zoneSpec`, `nf0_zoneSpec_assemble` |
| `Kamp/ExteriorNegation.lean` | `kvE2_sepPos`, `kvE2_sep_z{XW3,WT3,AtT3,AtW3,AtX3,FutT3,PastX3}`, `nf0_{assemble,dropFresh,dropFresh_assemble,projFresh,projFresh_assemble,split_assemble,zoneSpec,zoneSpec_assemble}` |
| `Kamp/ExteriorNegationPast.lean` | `kvE2_sep_z{AtT3,AtW3,AtX3,FutT3,PastX3,WT3,XW3}`, `nf0_{assemble,dropFresh,projFresh,zoneSpec}` |
| `NfMultiAnchorBridge/ExteriorGateAssembleK.lean` (task 356, transitive) | `kvE2_sep_zPastX3`, `kvE2_sep_zFutT3`, `nf0_zoneSpec` |
| `NfMultiAnchorBridge/OuterGate.lean` (imports hub directly) | report-03 Group-set (incl. `kvE2_sepFragment` @OuterGate:210, gate/fold anchors) |
| `NfMultiAnchorBridge/ExteriorZoneTriage.lean` (imports hub directly) | report-03 zone/triage set |
| `Kamp/NfMultiAnchorBridge.lean` (aggregator) | re-export pass-through |

**Contract rule**: a symbol appears in the contract iff any file OUTSIDE `SharedWitness/*` and
outside the hub references it. Everything else is internal scaffolding, free to privatize/scope.
The hub re-exports all contract symbols; because Lean re-exports imported decls transitively and the
aggregator imports the hub, KampPrior/converters/K-family see no change.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A privatized symbol is actually external (report 03's 346 figure predates the KampPrior/356 re-measure) | H | M | P2 re-measures external surface (incl. KampPrior, converters, 356) BEFORE P3 privatizes; P3's own full-tree green build is the authoritative net — any failure ⇒ un-privatize that symbol + add to contract, never force |
| Hub drops a contract symbol, silently breaking KampPrior/converters (task-358 dependency) | H | M | Post-hub import-equivalence tripwire (P16): a throwaway `example` referencing every contract symbol through the hub; `git diff` must show KampPrior/OuterGate/ExteriorZoneTriage/ExteriorNegation(Past)/ExteriorGateAssembleK/aggregator UNTOUCHED across all phases |
| A verbatim move changes elaboration and shifts `completeness_discrete`'s axiom set | H | L | Full-tree `lake build` green + `lean_verify` on each module's anchors after every phase; `completeness_discrete` axiom snapshot at P1 re-checked at P20 (and per-phase if budget allows); move verbatim, reopen the exact namespace, replicate the three `open`s |
| Oversized modules (F 1510, H 1664, I 1702 LOC) overflow a single agent run | M | H | Each extraction phase mandates ≤500-line verbatim green SUB-COMMITS (commit-per-green-substep); report-03 sub-phase budget cited per module; a phase may span multiple resumable dispatches |
| CarrierK1V:2144 removal conflicts with in-flight task 349 (Phase 5 may still target endIntervalStep) | M | M | P17 is guarded: default PRESERVE-IN-PLACE + `NOTE:` cross-referencing 357; delete ONLY on fresh 0-consumer `lean_references` AND confirmation 349 abandoned the approach |
| `OrderGate.lean` (1434 LOC) unwieldy as one module | L | M | Documented 11-module fallback: split B at :1267 into `GateSegments` + `OrderRank` (report 03 Decision 2) — a pre-approved option, not a new design |
| `md:NN` citations propagated as valid into new modules | M | M | P5 registers every touched `md:NN`; P19 re-cites to Rabinovich PDF pages; never copy `md:NN` forward |
| Lake file+directory coexistence (`SharedWitness.lean` beside `SharedWitness/`) | L | L | Idiomatic Mathlib pattern; first extraction (P6) is the empirical confirmation |

## Target Module Split (from report 03 Decision 2 — bands are current-HEAD-measured)

All modules reopen `namespace Bimodal.Metalogic.WeakCanonical.Kamp` and replicate the three `open`s
(`Bimodal.Syntax`, `…WeakCanonical`, `…WeakCanonical.Separation`, SharedWitness.lean:52–54). Import
order is strictly backward (acyclic by construction). Exact intra-module cut lines are P4's
deliverable (anchored on symbol names, not line numbers, which drift).

| # | Module (`…/SharedWitness/`) | Band (HEAD) | Est. LOC | Imports | Report-03 sub-phase budget |
|---|---|---|---|---|---|
| A | `Slots.lean` | 50–898 | 849 | `SubBracket2V`, `NavigatedSpine` | 2 |
| B | `OrderGate.lean` | 899–2332 | 1434 | `Slots` | 3 |
| C | `Carrier.lean` | 2333–3063 | 731 | `OrderGate` | 2 |
| D | `Completeness.lean` | 3064–4116 | 1053 | `Carrier` | 3 |
| E | `EngineInputs.lean` | 4117–5447 | 1331 | `Completeness` | 3 |
| F | `Soundness.lean` | 5448–6957 | 1510 | `EngineInputs` | 4 |
| G | `DisjunctionSpikes.lean` | 6958–8149 | 1192 | `Soundness` | 3 |
| H | `Assembly.lean` | 8150–9813 | 1664 | `DisjunctionSpikes` | 4 |
| I | `KitFold.lean` | 9814–11515 | 1702 | `Assembly` | 4 |
| J | `FragmentFoldRight.lean` | 11516–12800 | 1285 | `KitFold` | 3 |
| — | `SharedWitness.lean` (hub) | — | ~30 | `FragmentFoldRight` (transitively all) | — |

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
span multiple ≤500-line green sub-commits (report-03 budget column) — the phase completes when its
whole module is moved and the full tree is green.

---

### Phase 1: GATE — Re-verify gates satisfied & snapshot baseline [NOT STARTED]

**Goal**: Confirm all code-move gates are COMPLETED and record the green + axiom baseline. No code moved.

**Tasks**:
- [ ] Confirm in `specs/state.json`: 335, 337, 340, 346, 347, 348 all `completed` (verified at plan
  time — re-confirm at dispatch).
- [ ] Confirm `SharedWitness.lean` frozen: 12,800 lines, single flat namespace (50–12800), imports
  only `SubBracket2V` + `NavigatedSpine`; record HEAD SHA.
- [ ] Baseline `lake build` full-tree GREEN.
- [ ] Snapshot `completeness_discrete` axioms: `lean_verify` on
  `Bimodal.Metalogic.BXCanonical.completeness_discrete` (resolve exact FQ name at verify time);
  record the exact axiom set (expect `{propext, Classical.choice, Quot.sound}`).
- [ ] `grep`/`lean_verify` source-scan: 0 `sorry`/`admit` in code across `NfMultiAnchorBridge/`.

**Timing**: ~0.5 hours

**Depends on**: none

**Files to modify**: none (baseline record appended to this plan or a sibling design note).

**Verification**: gates COMPLETED, file frozen, baseline green, axiom set recorded, 0 sorries.

---

### Phase 2: Re-measure the external API surface [NOT STARTED]

**Goal**: Produce the authoritative Preserved-Public-API set (corrects report 03's incomplete 31),
including KampPrior + converters + task-356 ExteriorGateAssembleK. Design only; no code moved.

**Tasks**:
- [ ] For every top-level public decl in `SharedWitness.lean`, `grep -wF` its name across ALL files
  outside `SharedWitness/*` and the hub — specifically `KampPrior.lean`, `ExteriorNegation.lean`,
  `ExteriorNegationPast.lean`, `OuterGate.lean`, `ExteriorZoneTriage.lean`, `ExteriorGateAssembleK.lean`,
  the converters (`ExteriorConverterK/PastK`), the rest of the K-family, and the aggregator.
- [ ] Union the hits → the CONTRACT set (must be ⊇ the table in "Preserved Public API Contract").
- [ ] The complement (public decls with 0 external hits) → the PRIVATIZE candidate set; re-count
  exactly (resolve report 03's 84-vs-85 grep discrepancy by direct count).
- [ ] Record both sets in a design note under `plans/`.

**Timing**: ~1.5 hours

**Depends on**: 1

**Files to modify**: `plans/02_module-split-refresh.md` (or sibling design note) — no `.lean` edits.

**Verification**: CONTRACT set ⊇ the current-tree floor table; every KampPrior/ExteriorNegation(Past)/356
symbol is in CONTRACT; PRIVATIZE set exactly counted.

---

### Phase 3: Privatize leaked-internal scaffolding [NOT STARTED]

**Goal**: Mark the P2 PRIVATIZE set `private` in place (single-file edit to the still-monolithic
`SharedWitness.lean`), shrinking coupling before any cut. Behavior-preserving.

**Tasks**:
- [ ] Add `private` to each P2 PRIVATIZE-set decl (keep `noncomputable` ordering correct).
- [ ] Full-tree `lake build` GREEN — this is the authoritative net: a failure on any symbol proves it
  IS external ⇒ revert that `private`, move the symbol into CONTRACT, re-record.
- [ ] `lean_verify` `completeness_discrete` axioms unchanged vs P1.
- [ ] Commit (`task 341 phase 3: privatize leaked-internal scaffolding`).

**Timing**: ~1.5 hours

**Depends on**: 2

**Files to modify**: `SharedWitness.lean` only (privatization; no moves).

**Verification**: full-tree green; `completeness_discrete` axioms unchanged; 0 sorries; KampPrior/
converters/356 still compile unchanged.

---

### Phase 4: Private cross-reference audit + cut-line DAG spec [NOT STARTED]

**Goal**: Finalize exact per-module cut lines so no private symbol is orphaned from its consumer.
Design only; no code moved. Parallel with P5.

**Tasks**:
- [ ] `lean_references` (or last-use grep) on every file-scoped private; record last-use line.
- [ ] Confirm the A→J order-preserving cut leaves each private's last use in its own or a later
  module; hoist any boundary-crossing private to the appropriate module.
- [ ] Confirm the `kvE2_sepBody` def (:2347, Carrier) precedes all consumers (`_extract` :8575
  Assembly, `outer_fold` FragmentFoldRight) — non-contiguity dissolved, record the confirmation.
- [ ] Capture the exact `open`/section context each module carries; record symbol-anchored cut lines.

**Timing**: ~1.5 hours

**Depends on**: 3

**Files to modify**: design note under `plans/` — no `.lean` edits.

**Verification**: DAG acyclic backward-only; every private's consumer in-module-or-later; cut lines
symbol-anchored.

---

### Phase 5: Boneyard/citation inventory + CarrierK1V:2144 placeholder audit [NOT STARTED]

**Goal**: Classify dead-code candidates and register touched `md:NN` citations. Design only. Parallel with P4.

**Tasks**:
- [ ] `lean_references`-confirm 0 live consumers for SW:899 "STAGED, not yet wired" predicate,
  SW:6698 O4 CRUX RECORD, SW:6528 hgate residue (re-check — 344/346 may have wired some in).
- [ ] Audit CarrierK1V.lean:2144 `endIntervalStep`/`endInterval`: fresh `lean_references`; cross-check
  task 349 status + InteriorGateGeneralK:18/59 comments; classify ARCHIVE / DELETE / PRESERVE-with-NOTE
  (default PRESERVE, given 349 `[planned]`).
- [ ] Enumerate deleted-symbol comment residue (`kvE2_sepArrL/R/Valid/Singleton`) for REWRITE/DROP.
- [ ] Register every `md:NN` citation the split will move/touch (top: `md:77`×27, `md:168`×24, …).

**Timing**: ~1.5 hours

**Depends on**: 3

**Files to modify**: design note under `plans/` — no `.lean` edits.

**Verification**: every ARCHIVE/DELETE item has a 0-consumer confirmation; uncertain items marked
PRESERVE; citation register complete.

---

### Phase 6: Extract Module A → `SharedWitness/Slots.lean` [NOT STARTED]

**Goal**: Move slot/carrier types, zone constants (Def 3.1), tagged joint slots, per-slot `Fin N`
family. First move — validates the file+directory hub pattern. (~849 LOC; ~2 green sub-commits.)

**Tasks**:
- [ ] Create `SharedWitness/Slots.lean`; reopen namespace; replicate the three `open`s.
- [ ] Move Module-A decls verbatim per P4 cut lines, in ≤500-line green sub-commits.
- [ ] Edit `SharedWitness.lean` to `import …SharedWitness.Slots`; delete the moved block.
- [ ] Full-tree `lake build` GREEN; `lean_verify` anchors + `completeness_discrete` axioms unchanged.

**Timing**: ~1.5 hours

**Depends on**: 4, 5

**Files to modify**: `SharedWitness/Slots.lean` (new, ~849 moved); `SharedWitness.lean` (import + delete).

**Verification**: full-tree green; contract symbols in Slots (`kvE2_sep_z*`, `nf0_*`) importable via
hub; `completeness_discrete` axioms unchanged; 0 sorries. Commit each green sub-step.

---

### Phase 7: Extract Module B → `SharedWitness/OrderGate.lean` [NOT STARTED]

**Goal**: Move `kvE2_sepPosI`, `kvE2_sepGate`, `kvE2_ordRank`, `kvE2_sepDisjValidOwner`, endpoint
predicates, refined segment types. (~1434 LOC; ~3 sub-commits; 11-module fallback authorized if unwieldy.)

**Tasks**:
- [ ] Create `SharedWitness/OrderGate.lean` importing `Slots`; reopen namespace.
- [ ] Move Module-B decls verbatim per P4 cut lines, ≤500-line green sub-commits.
- [ ] If unwieldy: split at :1267 into `GateSegments.lean` + `OrderRank.lean` (pre-approved fallback).
- [ ] Wire import into hub; delete moved block; full-tree `lake build` GREEN.

**Timing**: ~2 hours

**Depends on**: 6

**Files to modify**: `SharedWitness/OrderGate.lean` (+ optional `GateSegments`/`OrderRank`); `SharedWitness.lean`.

**Verification**: full-tree green; `lean_verify` `kvE2_sepPosI`/`kvE2_ordRank`/`kvE2_sepDisjValidOwner`;
`kvE2_sepPosI`/`kvE2_sepPosI_mem` (KampPrior contract) importable via hub; axioms unchanged; 0 sorries.

---

### Phase 8: Extract Module C → `SharedWitness/Carrier.lean` [NOT STARTED]

**Goal**: Move `kvE2_sepBody` def (:2347), `kvE2_sepGate_holds_of_honest`, Group-3/4 heads. (~731 LOC; ~2 sub-commits.)

**Tasks**:
- [ ] Create `SharedWitness/Carrier.lean` importing `OrderGate`; reopen namespace.
- [ ] Move Module-C decls verbatim; confirm `kvE2_sepBody` def lands here (its consumers are all later).
- [ ] Wire hub import; delete moved block; full-tree `lake build` GREEN.

**Timing**: ~1.5 hours

**Depends on**: 7

**Files to modify**: `SharedWitness/Carrier.lean` (new); `SharedWitness.lean`.

**Verification**: full-tree green; `lean_verify` `kvE2_sepBody`; axioms unchanged; 0 sorries.

---

### Phase 9: Extract Module D → `SharedWitness/Completeness.lean` [NOT STARTED]

**Goal**: Move `kvE2_sepBody_complete` and Group-4 completeness reduction. (~1053 LOC; ~3 sub-commits.)

**Tasks**:
- [ ] Create `SharedWitness/Completeness.lean` importing `Carrier`; reopen namespace.
- [ ] Move Module-D decls verbatim, ≤500-line green sub-commits.
- [ ] Wire hub import; delete moved block; full-tree `lake build` GREEN.

**Timing**: ~2 hours

**Depends on**: 8

**Files to modify**: `SharedWitness/Completeness.lean` (new); `SharedWitness.lean`.

**Verification**: full-tree green; `lean_verify` completeness anchors; axioms unchanged; 0 sorries.

---

### Phase 10: Extract Module E → `SharedWitness/EngineInputs.lean` [NOT STARTED]

**Goal**: Move the task-337 engine inputs (internal-only, no frozen-pinned symbol). (~1331 LOC; ~3 sub-commits.)

**Tasks**:
- [ ] Create `SharedWitness/EngineInputs.lean` importing `Completeness`; reopen namespace.
- [ ] Move Module-E decls verbatim, ≤500-line green sub-commits.
- [ ] Wire hub import; delete moved block; full-tree `lake build` GREEN.

**Timing**: ~2 hours

**Depends on**: 9

**Files to modify**: `SharedWitness/EngineInputs.lean` (new); `SharedWitness.lean`.

**Verification**: full-tree green; axioms unchanged; 0 sorries.

---

### Phase 11: Extract Module F → `SharedWitness/Soundness.lean` [NOT STARTED]

**Goal**: Move `kvE2_sepHonest_hLR_absurd` (:6087), honest-order soundness. (~1510 LOC; ~4 sub-commits.)

**Tasks**:
- [ ] Create `SharedWitness/Soundness.lean` importing `EngineInputs`; reopen namespace.
- [ ] Move Module-F decls verbatim, ≤500-line green sub-commits.
- [ ] Wire hub import; delete moved block; full-tree `lake build` GREEN.

**Timing**: ~2 hours

**Depends on**: 10

**Files to modify**: `SharedWitness/Soundness.lean` (new); `SharedWitness.lean`.

**Verification**: full-tree green; `lean_verify` `kvE2_sepHonest_hLR_absurd`; axioms unchanged; 0 sorries.

---

### Phase 12: Extract Module G → `SharedWitness/DisjunctionSpikes.lean` [NOT STARTED]

**Goal**: Move `kvE2_sepProjFresh_eval` (:7297) and disjunction-spike machinery. (~1192 LOC; ~3 sub-commits.)

**Tasks**:
- [ ] Create `SharedWitness/DisjunctionSpikes.lean` importing `Soundness`; reopen namespace.
- [ ] Move Module-G decls verbatim, ≤500-line green sub-commits.
- [ ] Wire hub import; delete moved block; full-tree `lake build` GREEN.

**Timing**: ~2 hours

**Depends on**: 11

**Files to modify**: `SharedWitness/DisjunctionSpikes.lean` (new); `SharedWitness.lean`.

**Verification**: full-tree green; axioms unchanged; 0 sorries.

---

### Phase 13: Extract Module H → `SharedWitness/Assembly.lean` [NOT STARTED]

**Goal**: Move `kvE2_sepBody_extract` (:8575), `kvE2_sepBody_holds_of_honest` (:9800), O4 assembly.
(~1664 LOC; ~4 sub-commits.)

**Tasks**:
- [ ] Create `SharedWitness/Assembly.lean` importing `DisjunctionSpikes`; reopen namespace.
- [ ] Move Module-H decls verbatim, ≤500-line green sub-commits.
- [ ] Wire hub import; delete moved block; full-tree `lake build` GREEN.

**Timing**: ~2 hours

**Depends on**: 12

**Files to modify**: `SharedWitness/Assembly.lean` (new); `SharedWitness.lean`.

**Verification**: full-tree green; `lean_verify` `kvE2_sepBody_extract`; axioms unchanged; 0 sorries.

---

### Phase 14: Extract Module I → `SharedWitness/KitFold.lean` [NOT STARTED]

**Goal**: Move `kvE2_sepFragment_frag`/`_realizable` (:10219/:10265 — KampPrior contract),
`kvE2_sepGateAtPin_fragL`, per-σ kit. (~1702 LOC; ~4 sub-commits.)

**Tasks**:
- [ ] Create `SharedWitness/KitFold.lean` importing `Assembly`; reopen namespace.
- [ ] Move Module-I decls verbatim, ≤500-line green sub-commits.
- [ ] Wire hub import; delete moved block; full-tree `lake build` GREEN.

**Timing**: ~2 hours

**Depends on**: 13

**Files to modify**: `SharedWitness/KitFold.lean` (new); `SharedWitness.lean`.

**Verification**: full-tree green; `lean_verify` `kvE2_sepFragment_realizable`; KampPrior contract
symbols importable via hub; axioms unchanged; 0 sorries.

---

### Phase 15: Extract Module J → `SharedWitness/FragmentFoldRight.lean` [NOT STARTED]

**Goal**: Move `kvE2_sepBody_kit_sound_frag`, `kvE2_outer_fold_frag`, the SW:10210–12800 "sixth-seam"
tail. (~1285 LOC; ~3 sub-commits.)

**Tasks**:
- [ ] Create `SharedWitness/FragmentFoldRight.lean` importing `KitFold`; reopen namespace.
- [ ] Move Module-J decls verbatim, ≤500-line green sub-commits.
- [ ] Wire hub import; delete moved block; full-tree `lake build` GREEN.

**Timing**: ~2 hours

**Depends on**: 14

**Files to modify**: `SharedWitness/FragmentFoldRight.lean` (new); `SharedWitness.lean`.

**Verification**: full-tree green; axioms unchanged; 0 sorries.

---

### Phase 16: Hub reduction + import-equivalence tripwire [NOT STARTED]

**Goal**: Reduce `SharedWitness.lean` to a documented re-export hub; prove the full external contract
is preserved. `SharedWitness.lean` holds zero decls.

**Tasks**:
- [ ] Reduce `SharedWitness.lean` to `import` of all 10 modules + module docstring; confirm 0 decls.
- [ ] Import-equivalence tripwire: a throwaway `example`/`#check` referencing EVERY Preserved-Public-API
  contract symbol through the hub (catches any dropped decl).
- [ ] `git diff` confirms `KampPrior.lean`, `OuterGate.lean`, `ExteriorZoneTriage.lean`,
  `ExteriorNegation(Past).lean`, `ExteriorGateAssembleK.lean`, aggregator ALL untouched.
- [ ] Full-tree `lake build` GREEN; `completeness_discrete` axioms unchanged.

**Timing**: ~1 hour

**Depends on**: 15

**Files to modify**: `SharedWitness.lean` (now hub-only, ~30 lines).

**Verification**: full-tree green; every contract symbol resolves via hub; downstream files
byte-unchanged; axioms unchanged; 0 sorries.

---

### Phase 17: Guarded CarrierK1V:2144 dead-placeholder cleanup [NOT STARTED]

**Goal**: Resolve the superseded `endIntervalStep`/`endInterval` `⟨[]⟩` placeholder per P5's audit.
Parallel with P18.

**Tasks**:
- [ ] Re-run `lean_references` on `endIntervalStep`/`endInterval` in CarrierK1V.lean; re-check task
  349 status.
- [ ] If 0 consumers AND 349 confirmed to have abandoned the endIntervalStep approach: remove verbatim
  (git history is the archive). ELSE: add a `NOTE:`/`QUESTION:` comment cross-referencing 357's
  `endIntervalStepPrior`/EndIntervalConsumerK supersession and leave in place.
- [ ] Full-tree `lake build` GREEN.

**Timing**: ~0.5 hours

**Depends on**: 16

**Files to modify**: `CarrierK1V.lean` (removal or NOTE: only — no other change).

**Verification**: full-tree green; axioms unchanged; 0 sorries; no live consumer lost.

---

### Phase 18: Deleted-symbol comment cleanup + Boneyard decision [NOT STARTED]

**Goal**: Rewrite/drop deleted-symbol comment residue; decide archival vs. delete for P5-confirmed
dead code (prefer git-history-as-archive given task 359's Boneyard-deletion direction). Parallel with P17.

**Tasks**:
- [ ] Rewrite or drop `kvE2_sepArrL/R/Valid/Singleton` comment residue — do NOT propagate.
- [ ] For each P5-confirmed 0-consumer dead block (SW:899, SW:6698, SW:6528 if unreferenced): DELETE
  (git history archives) unless still uncertain, in which case `NOTE:`/`QUESTION:` in place. Do NOT
  create new `Kamp/Boneyard/` files (task 359 is deleting that directory).
- [ ] Full-tree `lake build` GREEN.

**Timing**: ~1 hour

**Depends on**: 16

**Files to modify**: the relevant `SharedWitness/*.lean` modules (comment/dead-code edits).

**Verification**: full-tree green; no deleted-symbol residue propagated; axioms unchanged; 0 sorries.

---

### Phase 19: API & documentation pass [NOT STARTED]

**Goal**: Add `section` structure + per-module docstrings; re-cite touched `md:NN` comments to
Rabinovich PDF pages.

**Tasks**:
- [ ] Per-module file docstrings grounding the value-faithful per-slot design in Rabinovich Def 3.1 /
  Lemma 3.2(1) / Cor 5.4 (cite PDF pages; reports 05–09), never `md:NN`.
- [ ] Re-cite every P5-registered touched `md:NN` to Rabinovich PDF pages (style `Rabinovich §5, p.7`,
  SW:6132); for modules I/J re-ground in the revised Prop 4.3 treatment (347/348).
- [ ] Full-tree `lake build` GREEN (docstring/section edits must not change elaboration).

**Timing**: ~1.5 hours

**Depends on**: 17, 18

**Files to modify**: all `SharedWitness/*.lean` + hub — docstrings, sections, re-cited comments.

**Verification**: full-tree green; no `md:NN` in any touched comment; axioms unchanged; 0 sorries.

---

### Phase 20: Final verification [NOT STARTED]

**Goal**: Confirm all invariants preserved across the completed refactor.

**Tasks**:
- [ ] Full-tree `lake build` GREEN (from clean if budget allows).
- [ ] `lean_verify` `completeness_discrete` → axiom set EXACTLY equals the P1 snapshot.
- [ ] `lean_verify` on all Preserved-Public-API anchors → `{propext, Classical.choice, Quot.sound}`.
- [ ] Source-scan 0 `sorry`/`admit` in code across all new modules.
- [ ] Confirm LITMUS (`NavigatedSpine.lean:437`, `bracketEndChar_kvE2`) byte-unchanged (341 never
  edits NavigatedSpine) and F1–F7 intact (no statement/proof altered).
- [ ] Confirm downstream files (KampPrior, OuterGate, ExteriorZoneTriage, ExteriorNegation(Past),
  ExteriorGateAssembleK, aggregator) byte-unchanged; write execution summary.

**Timing**: ~1 hour

**Depends on**: 19

**Files to modify**: `specs/341_.../summaries/02_module-split-summary.md` (new).

**Verification**: full green, `completeness_discrete` axioms == P1 snapshot, 0 sorries, LITMUS + F1–F7
preserved, full external API import-equivalent, downstream unchanged. Final commit.

---

## Testing & Validation

- [ ] Full-tree `lake build` GREEN after EVERY phase (3, 6–20) — scoped `lake build <Module>` first
  for speed, then full (proves hub re-export + KampPrior/converters/K-family still compile).
- [ ] `completeness_discrete` axiom set unchanged vs the P1 snapshot (bookend P1↔P20; per-phase if budget).
- [ ] `lean_verify` on each module's anchors → `{propext, Classical.choice, Quot.sound}`.
- [ ] 0 `sorry`/`admit` in code across all new modules at every phase.
- [ ] `git diff` shows KampPrior/OuterGate/ExteriorZoneTriage/ExteriorNegation(Past)/ExteriorGateAssembleK/
  aggregator UNTOUCHED across all 20 phases (import-preservation tripwire).
- [ ] LITMUS (`NavigatedSpine.lean:437`) byte-unchanged; no `md:NN` propagated as valid.

## Artifacts & Outputs

- `plans/02_module-split-refresh.md` (this file; P1–P5 append design decisions/inventory).
- `NfMultiAnchorBridge/SharedWitness/{Slots,OrderGate,Carrier,Completeness,EngineInputs,Soundness,
  DisjunctionSpikes,Assembly,KitFold,FragmentFoldRight}.lean` (+ optional `GateSegments`/`OrderRank`).
- `NfMultiAnchorBridge/SharedWitness.lean` — reduced to a documented re-export hub.
- `specs/341_.../summaries/02_module-split-summary.md`.

## Rollback/Contingency

- Each phase is an independent green commit; roll back a failed phase via `git revert` — earlier
  extractions remain valid.
- The 20-phase plan spans multiple `/implement` dispatches; the phase table is the resume ledger.
  Because moves are verbatim and the hub preserves the API, re-inlining a moved block is mechanical
  (revert the extraction commit returns `SharedWitness.lean` toward its monolithic form).
- If P3 privatization or any extraction cannot land green, restore the pre-phase state, mark the phase
  `[PARTIAL]`, record the failing symbol/cut line, and refine (un-privatize the external symbol, or
  sub-split the module) before retry.
- If P17's CarrierK1V:2144 audit is inconclusive against in-flight task 349, default to
  PRESERVE-IN-PLACE-with-NOTE — never delete on suspicion.
