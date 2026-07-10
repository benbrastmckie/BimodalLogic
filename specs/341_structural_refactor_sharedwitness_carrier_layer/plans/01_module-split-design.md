# Implementation Plan: Task #341 — SharedWitness.lean Module-Split Design

- **Task**: 341 - structural_refactor_sharedwitness_carrier_layer
- **Status**: [NOT STARTED]
- **Effort**: 15 hours
- **Dependencies**: 340 [done], 337 [done], **335 [PLANNED — blocks all code-move phases]**
- **Research Inputs**: specs/341_structural_refactor_sharedwitness_carrier_layer/reports/01_sharedwitness-declaration-survey.md
- **Artifacts**: plans/01_module-split-design.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md; lean4.md; git-workflow.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

`SharedWitness.lean` has grown to **10,037 lines** (measured at HEAD; description said ~9248, survey
confirms further ~8% growth) inside a single flat `namespace Bimodal.Metalogic.WeakCanonical.Kamp`
with zero internal `section`/`namespace` structure — organized only by 40 `/-! ## …` comment banners.
This plan splits it along five natural seams (survey Seams A–E) into sibling modules under a new
`NfMultiAnchorBridge/SharedWitness/` subdirectory, turning `SharedWitness.lean` itself into a thin
re-export hub so the public API and every import site are preserved **byte-for-byte at the import
level**. This is a code-health / maintainability pass, NOT a semantic change: behavior, proved
theorems, axiom cleanliness `{propext, Classical.choice, Quot.sound}`, zero sorries, the F1–F7
faithfulness invariants, and the LITMUS (`NavigatedSpine:437`) must be preserved exactly. Definition
of done: `lake build` fully green, every public anchor axiom-clean, zero sorries introduced,
`SharedWitness.lean` reduced to a documented aggregator, dead code archived to `Boneyard/`, and no
`md:NN` citation propagated as if valid.

### Research Integration

Integrates report `01_sharedwitness-declaration-survey.md`:
- **Seam map** (banner-driven contiguous ranges) → five target modules (see module table below).
- **Verified current symbols** — name the split against `kvE2_sepArr'`, `kvE2_sepDisjValidOwner`,
  `kvE2_sepPosI`, `kvE2_ordRank`, `kvE2_sepBody`, `kvE2_sepBody_extract`,
  `kvE2_sepHonest_hLR_absurd`, `kvE2_sepHonestOrder'`, `kvE2_sepSlotLe`, `kvE2_sepGate` — and
  **NEVER** against the deleted `kvE2_sepArrL/R/Valid/Singleton/hLR` (all 0-decl, comment-only).
- **Non-contiguity hazard**: `kvE2_sepBody` def (SW:2314) but `extract` (SW:8410) and `outer_fold`
  (SW:9897) far downstream → the assembly module boundary needs a real dependency DAG before cutting
  (Phase 1 deliverable).
- **Boneyard candidates**: SW:899 "STAGED, not yet wired" predicate; SW:6698 O4 CRUX RECORD
  ("additive and inert"); SW:6528 Phase-9 hgate; deleted-symbol comment residue; 89 dangling `md:NN`
  citations. Verify 0 live consumers via `lean_references` before any move (Phase 2).
- **Hard sequencing**: implementation MUST wait for 335 [COMPLETED] + `SharedWitness.lean` frozen
  (335 Phase 4b may still re-shape it). Design phases (1–2) are safe now; the GATE (Phase 3) enforces
  the wait.

### Prior Plan Reference

No prior plan for task 341. This is the first plan.

### Roadmap Alignment

No `roadmap_flag` set for this dispatch; ROADMAP.md not consulted. The task advances the
NfMultiAnchorBridge carrier-layer maintainability goals recorded in the task description.

## Goals & Non-Goals

**Goals**:
- Split `SharedWitness.lean` into five cohesive sibling modules under `SharedWitness/`, each
  compiling with only backward imports.
- Preserve the public API and all import sites exactly via a re-export hub (`SharedWitness.lean`).
- Improve the API: consistent naming, section structure, and docstrings grounding the design in
  Rabinovich Def 3.1 (cite PDF pages, and reports 05–09), re-citing `md:NN` comments wherever touched.
- Archive genuinely dead/superseded code to `Theories/Bimodal/Boneyard/`, preserving uncertain code
  in place with `NOTE:`/`QUESTION:` comments.
- Keep `lake build` green and axiom-clean `{propext, Classical.choice, Quot.sound}` after every phase;
  zero sorries introduced; F1–F7 and LITMUS preserved.

**Non-Goals**:
- No semantic changes: do NOT alter any proof, statement, definition body, or evaluation behavior.
- Do NOT fix the 89 `md:NN` citations wholesale — only re-cite comments the refactor actually moves
  or touches (deliberate user decision to leave the rest UNFIXED).
- Do NOT begin any code move before task 335 is [COMPLETED] and `SharedWitness.lean` is confirmed
  frozen.
- Do NOT rename or re-derive against the deleted `kvE2_sepArrL/R/Valid/Singleton/hLR` symbols.
- No changes to downstream consumers (OuterGate.lean, aggregator) beyond what import preservation
  guarantees automatically.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `kvE2_sepBody` non-contiguity (def SW:2314, extract SW:8410, outer_fold SW:9897) forces forward references across module boundaries | H | H | Phase 1 builds a real dependency DAG (`lean_references` on ~10 public anchors + grep); if `kvE2_sepBody` def is consumed by Seam C/D, relocate the def to an earlier module (e.g. `OrdRank`) with only `extract`/`outer_fold` in `Body`. Resolve cut lines from the DAG, never top-to-bottom line order. |
| 335 re-shapes `SharedWitness.lean` after design phases complete (335 Phase 4b `hbdry`/`hexcl` risk) | H | M | GATE Phase 3 re-diffs the frozen file against the survey and refreshes cut lines before any move; design artifacts cite symbols, not line numbers, to survive drift. |
| A code move silently changes elaboration (universe/instance/`open` scoping) and breaks a distant proof | H | M | `lake build` (scoped then full) green after every phase; `lean_verify` axiom check on that module's public anchors; sorry-count grep unchanged (must stay 0). Move verbatim; re-open the exact same namespace; carry `open`/`variable` context per module. |
| Boneyard candidate is actually load-bearing | M | M | Phase 2 confirms 0 live consumers via `lean_references` before archiving; anything uncertain stays in place with `NOTE:`/`QUESTION:` (preservation rule is binding). |
| Dispatch overflow on the large seams (C ~2640, D ~2000, E ~2200 lines) | M | M | Each large extraction phase authorizes a documented sub-split (C1/C2, D1/D2, E1/E2) at a banner boundary if a single agent dispatch cannot land it green; commit each green sub-step. |
| `md:NN` citations propagated into new modules as if valid | M | M | Phase 2 registers every touched `md:NN` comment; Phase 10 re-cites to Rabinovich PDF pages (existing style `Rabinovich §5, p.7` at SW:6132); never copy `md:NN` forward silently. |
| Lake file+directory coexistence (`SharedWitness.lean` beside `SharedWitness/`) misconfigured | L | L | Idiomatic Lean/Mathlib pattern; verified by `lake build` in Phase 4 (first module created). |

## Target Module Split (design — confirmed/refined in Phase 1)

All modules reopen `namespace Bimodal.Metalogic.WeakCanonical.Kamp`. Import order is strictly
backward. `SharedWitness.lean` becomes a re-export hub; because Lean re-exports imported decls
transitively, downstream (`OuterGate.lean`, aggregator `NfMultiAnchorBridge.lean`) needs **no edit**.

| New module (`…/NfMultiAnchorBridge/SharedWitness/`) | Seam | Key anchors | Est. lines | Imports |
|---|---|---|---|---|
| `Slots.lean` | A | slot/carrier types, outer/inner zone constants (Def 3.1), tagged joint slots (Lemma 3.2(1)), per-individual-slot `Fin N` family (task 340) | ~410 | `SubBracket2V`, `NavigatedSpine` |
| `OrdRank.lean` | B | `kvE2_sepPosI` (211), `kvE2_sepGate` (1207), `kvE2_ordRank` (1377), `kvE2_sepDisjValidOwner` (1503/1733), endpoint predicates, refined segment types (Cor 5.4) | ~1480 | `Slots` |
| `HonestOrder.lean` | C | `wo`-driven ordering, tie-class grouping, anchor-family keystone (distinct owners ⟹ distinct anchors), value-faithful monotonicity, halign bridge, merged slot-list `Nodup`, `kvE2_sepArr'` side-conditions | ~2640 | `OrdRank` |
| `Coincidence.lean` | D | task-337 bracket engine, `kvE2_sepHonest_hLR_absurd` (5710), `kvE2_sepHonestOrder'` (5959), `kvE2_sepSlotLe`, O3 extraction theorems | ~2000 | `HonestOrder` |
| `Body.lean` | E | `kvE2_sepBody` (2314), `holds_iff`, `kvE2_sepBody_extract` (8410), order-type disjunction, honesty families, O2/O3/O4 assembly, two public theorems, task-333 per-σ kit + `kvE2_outer_fold` (9897) | ~2200 | `Coincidence` |
| `SharedWitness.lean` (hub) | — | file-level module docstring + `import` of the five modules (re-export); no decls | ~30 | `Slots`, `OrdRank`, `HonestOrder`, `Coincidence`, `Body` |

**Boundary note (binding for Phase 1)**: `kvE2_sepBody` def sits physically in the Seam-E range but
early in the file (SW:2314); if the DAG shows Seam-C/D decls consume it, the def moves to `OrdRank`
(or a small dedicated `BodyCore`), leaving only `extract`/`outer_fold` in `Body`. The DAG decides;
line order does not.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 (GATE) | 1, 2 |
| 3 | 4 | 3 |
| 4 | 5 | 4 |
| 5 | 6 | 5 |
| 6 | 7 | 6 |
| 7 | 8 | 7 |
| 8 | 9 | 8 |
| 9 | 10 | 9 |
| 10 | 11 | 10 |

Phases within the same wave can execute in parallel. Phases 1–2 are read-only design (no `.lean`
edits) and safe to run **now**, pre-335. Phases 4–11 are gated by Phase 3.

---

### Phase 1: Dependency DAG & Cut-Line Specification [NOT STARTED]

**Goal**: Produce the authoritative import/dependency DAG and exact cut lines (symbol ranges) for the
five modules, resolving the `kvE2_sepBody` non-contiguity — WITHOUT moving any code. Safe pre-335.

**Tasks**:
- [ ] Run `lean_references` on the ~10 public anchors (`kvE2_sepArr'`, `kvE2_sepDisjValidOwner`,
  `kvE2_sepPosI`, `kvE2_ordRank`, `kvE2_sepBody`, `kvE2_sepBody_extract`, `kvE2_sepHonest_hLR_absurd`,
  `kvE2_sepHonestOrder'`, `kvE2_sepSlotLe`, `kvE2_sepGate`) plus grep of cross-symbol uses.
- [ ] Build a backward-only dependency DAG of the seams; confirm each proposed module imports only
  earlier modules.
- [ ] Resolve the `kvE2_sepBody` def placement (stay in `Body` vs. relocate to `OrdRank`/`BodyCore`)
  from the DAG; record the decision.
- [ ] Record exact cut lines (by symbol name + current line, noting line numbers are provisional
  until the GATE re-diff) and refined per-module line-count estimates against the true 10,037-line file.
- [ ] Capture the `open`/`variable`/section context each module must carry to elaborate identically.
- [ ] Append the finalized DAG + cut-line spec + module table as a "Design Decisions" section to this
  plan file (or a sibling design note under `plans/`).

**Timing**: ~1.5 hours

**Depends on**: none

**Files to modify**:
- `specs/341_.../plans/01_module-split-design.md` — append Design Decisions (no `.lean` edits).

**Verification**:
- DAG is acyclic and backward-only; every anchor's consumers are accounted for.
- `kvE2_sepBody` placement decision is explicit and DAG-justified.
- Zero `.lean` files touched.

---

### Phase 2: Boneyard Inventory & Citation-Hazard Register [NOT STARTED]

**Goal**: Pinpoint and confirm dead/superseded code and register every `md:NN` citation the refactor
will touch — WITHOUT moving any code. Safe pre-335. Parallel with Phase 1 (read-only).

**Tasks**:
- [ ] `lean_references`-confirm 0 live consumers for each Boneyard candidate: SW:899 "STAGED, not yet
  wired" cross-σ bit-compatibility predicate; SW:6698 O4 CRUX RECORD ("additive and inert"); SW:6528
  Phase-9 O4 carrier-side hgate derivation.
- [ ] Pinpoint the description's "339 region-primary machinery" and "obsolete owner-block tuple
  remnants" (not located as distinct banners in the survey) via `lean_references`; classify each as
  ARCHIVE (0 consumers) or PRESERVE-IN-PLACE (`NOTE:`/`QUESTION:`).
- [ ] Enumerate deleted-symbol comment residue (`kvE2_sepArrL/R/Valid/Singleton` prose) for
  REWRITE/DROP.
- [ ] Register all 89 `md:NN` citations by location (top offenders `md:77`×27, `md:168`×24,
  `md:154`×9, `md:72`×8, `md:61`×6, …) and mark which will be moved/touched by the split — those get
  re-cited to Rabinovich PDF pages in Phase 10.
- [ ] Append the archival list + preservation list + citation register to the plan/design note.

**Timing**: ~1.5 hours

**Depends on**: none

**Files to modify**:
- `specs/341_.../plans/01_module-split-design.md` — append inventory (no `.lean` edits).

**Verification**:
- Every ARCHIVE item has a `lean_references` 0-consumer confirmation.
- Every uncertain item is explicitly marked PRESERVE-IN-PLACE.
- Zero `.lean` files touched.

---

### Phase 3: GATE — Verify 335 Complete & Re-Diff Frozen SharedWitness [NOT STARTED]

**Goal**: Enforce the hard sequencing constraint. No code move proceeds until this gate passes.

**Tasks**:
- [ ] Confirm task 335 status is [COMPLETED] in `specs/state.json` (currently `planned`).
- [ ] Confirm the H7 territory contract assigning `SharedWitness.lean` to task 333 and
  `OuterGate.lean` to task 335 is released (both landed).
- [ ] Re-diff the current `SharedWitness.lean` against the survey's line anchors and Phase 1 cut
  lines; if 335 Phase 4b re-shaped the file, refresh the cut lines and per-module estimates.
- [ ] Confirm baseline is green + axiom-clean before touching anything: `lake build` green,
  `lean_verify` on public anchors returns only `{propext, Classical.choice, Quot.sound}`, `grep -c`
  sorry/admit in code = 0.
- [ ] Record the frozen HEAD SHA and baseline metrics.

**Timing**: ~0.5 hours

**Depends on**: 1, 2

**Files to modify**:
- `specs/341_.../plans/01_module-split-design.md` — record gate result + baseline (no `.lean` edits).

**Verification**:
- 335 is [COMPLETED] and file frozen; if NOT, mark this phase [BLOCKED] and stop — do not proceed to
  Phase 4.
- Baseline `lake build` green, axiom-clean, zero sorries recorded.

---

### Phase 4: Extract Seam A → `SharedWitness/Slots.lean` [NOT STARTED]

**Goal**: Move slot/carrier types + enumeration to the first sub-module; convert `SharedWitness.lean`
to import it. First move — validates the file+directory hub pattern end-to-end.

**Tasks**:
- [ ] Create `NfMultiAnchorBridge/SharedWitness/Slots.lean`; reopen the namespace; carry the exact
  header `open`/`variable` context.
- [ ] Move Seam A decls verbatim (slot/carrier types, zone constants Def 3.1, tagged joint slots,
  per-individual-slot `Fin N` family) per Phase 1 cut lines.
- [ ] Edit `SharedWitness.lean` to `import …SharedWitness.Slots` and delete the moved block.
- [ ] `lake build` (scoped module then full) green.

**Timing**: ~1.5 hours

**Depends on**: 3

**Files to modify**:
- `NfMultiAnchorBridge/SharedWitness/Slots.lean` — new (~410 lines moved).
- `NfMultiAnchorBridge/SharedWitness.lean` — add import, remove moved block.

**Verification**:
- `lake build` green; `lean_verify` axiom-clean on any anchor now living in `Slots`; sorry count 0.
- `git commit` this green milestone (`task 341 phase 4: extract Slots module`).

---

### Phase 5: Extract Seam B → `SharedWitness/OrdRank.lean` [NOT STARTED]

**Goal**: Move the per-slot global-index + `kvE2_ordRank` kernel + interior `kvE2_sepPosI` +
`kvE2_sepGate` + `kvE2_sepDisjValidOwner` (plus `kvE2_sepBody` def if Phase 1 relocated it here).

**Tasks**:
- [ ] Create `SharedWitness/OrdRank.lean` importing `Slots`; reopen namespace.
- [ ] Move Seam B decls verbatim per Phase 1 cut lines (including any Phase-1-mandated `kvE2_sepBody`
  def relocation).
- [ ] Wire the import into `SharedWitness.lean`; remove moved block.
- [ ] `lake build` green.

**Timing**: ~2 hours

**Depends on**: 4

**Files to modify**:
- `SharedWitness/OrdRank.lean` — new (~1480 lines moved).
- `SharedWitness.lean` — add import, remove moved block.

**Verification**:
- `lake build` green; `lean_verify` axiom-clean on `kvE2_ordRank`, `kvE2_sepPosI`,
  `kvE2_sepDisjValidOwner`; sorry count 0.
- Commit green milestone.

---

### Phase 6: Extract Seam C → `SharedWitness/HonestOrder.lean` [NOT STARTED]

**Goal**: Move honest-order construction + membership/monotonicity + halign + merged-slot `Nodup`.
Largest seam (~2640 lines): sub-split authorized if a single dispatch cannot land it green.

**Tasks**:
- [ ] Create `SharedWitness/HonestOrder.lean` importing `OrdRank`; reopen namespace.
- [ ] Move Seam C decls verbatim (wo-ordering, tie-class grouping, anchor-family keystone,
  value-faithful monotonicity, halign FOUNDATION bridge, merged slot-list `Nodup`, `kvE2_sepArr'`
  soundness side-conditions).
- [ ] If overflow: sub-split at a banner boundary into `HonestOrder.lean` (C1: order construction) +
  `HonestOrderMembership.lean` (C2: halign + membership/Nodup), committing each green sub-step.
- [ ] Wire import(s); remove moved block(s); `lake build` green.

**Timing**: ~2 hours

**Depends on**: 5

**Files to modify**:
- `SharedWitness/HonestOrder.lean` (+ optional `HonestOrderMembership.lean`) — new (~2640 lines moved).
- `SharedWitness.lean` — add import(s), remove moved block(s).

**Verification**:
- `lake build` green; axiom-clean on the C anchors; sorry count 0. Commit green milestone(s).

---

### Phase 7: Extract Seam D → `SharedWitness/Coincidence.lean` [NOT STARTED]

**Goal**: Move the coincidence-fold / discharge engine, `kvE2_sepHonest_hLR_absurd` certificate,
`kvE2_sepHonestOrder'`, and O3 extraction theorems.

**Tasks**:
- [ ] Create `SharedWitness/Coincidence.lean` importing `HonestOrder`; reopen namespace.
- [ ] Move Seam D decls verbatim (task-337 bracket engine, `kvE2_sepHonest_hLR_absurd` at 5710,
  `kvE2_sepHonestOrder'` at 5959, `kvE2_sepSlotLe`, O3 extraction theorems).
- [ ] Sub-split (D1/D2) at a banner boundary if overflow.
- [ ] Wire import(s); remove moved block(s); `lake build` green.

**Timing**: ~2 hours

**Depends on**: 6

**Files to modify**:
- `SharedWitness/Coincidence.lean` — new (~2000 lines moved).
- `SharedWitness.lean` — add import, remove moved block.

**Verification**:
- `lake build` green; axiom-clean on `kvE2_sepHonestOrder'`, `kvE2_sepHonest_hLR_absurd`; sorry
  count 0. Commit green milestone.

---

### Phase 8: Extract Seam E → `SharedWitness/Body.lean` [NOT STARTED]

**Goal**: Move the body / holds_iff / extract assembly — `kvE2_sepBody` (unless relocated in Phase 5),
`kvE2_sepBody_extract`, `kvE2_outer_fold`, honesty families, O2/O3/O4 assembly, and the two public
theorems. `SharedWitness.lean` is now a pure re-export hub.

**Tasks**:
- [ ] Create `SharedWitness/Body.lean` importing `Coincidence`; reopen namespace.
- [ ] Move remaining Seam E decls verbatim (respecting the Phase-1 non-contiguity resolution:
  `extract` at 8410 and `outer_fold` at 9897 land here; the def location per Phase 1).
- [ ] Sub-split (E1/E2) at a banner boundary if overflow.
- [ ] Reduce `SharedWitness.lean` to imports of all five modules + module docstring; confirm it holds
  no decls.
- [ ] `lake build` green; confirm `OuterGate.lean` and the aggregator still compile unchanged.

**Timing**: ~2 hours

**Depends on**: 7

**Files to modify**:
- `SharedWitness/Body.lean` — new (~2200 lines moved).
- `SharedWitness.lean` — now hub-only (~30 lines).

**Verification**:
- `lake build` green (full project); axiom-clean on `kvE2_sepBody`, `kvE2_sepBody_extract`, the two
  public theorems; sorry count 0. `OuterGate.lean` + aggregator unchanged and green. Commit milestone.

---

### Phase 9: Boneyard Archival [NOT STARTED]

**Goal**: Move confirmed-dead code (Phase 2 inventory) to `Theories/Bimodal/Boneyard/`; rewrite/drop
deleted-symbol comment residue; preserve uncertain code in place with `NOTE:`/`QUESTION:`.

**Tasks**:
- [ ] Create `Theories/Bimodal/Boneyard/SharedWitnessResidue/SharedWitnessResidue.lean` + `README.md`
  following the existing Boneyard convention (subdir + README per `Boneyard/README.md`).
- [ ] Move ONLY Phase-2-confirmed 0-consumer items (SW:899 staged predicate, SW:6698 CRUX RECORD,
  SW:6528 hgate if unreferenced, 339 region-primary + owner-block remnants if confirmed dead).
- [ ] Rewrite or drop deleted-symbol comment residue (`kvE2_sepArrL/R/Valid/Singleton`) — do NOT
  propagate.
- [ ] Add `NOTE:`/`QUESTION:` markers to every PRESERVE-IN-PLACE item flagged in Phase 2.
- [ ] `lake build` green (Boneyard is a leaf; confirm nothing live imported the moved code).

**Timing**: ~1.5 hours

**Depends on**: 8

**Files to modify**:
- `Theories/Bimodal/Boneyard/SharedWitnessResidue/` — new archive + README.
- The relevant `SharedWitness/*.lean` modules — remove archived blocks, rewrite residual comments.

**Verification**:
- `lake build` green; sorry count 0; axiom-clean unchanged. No live decl lost (only 0-consumer code
  moved). Commit milestone.

---

### Phase 10: API & Documentation Pass [NOT STARTED]

**Goal**: Add `section` structure, consistent naming, and comprehensive docstrings across the five
modules; re-cite every touched `md:NN` comment to Rabinovich PDF pages.

**Tasks**:
- [ ] Add per-module file docstrings and `section` structure explaining the value-faithful
  per-individual-slot design and its Rabinovich Def 3.1 grounding (cite PDF pages + reports 05–09).
- [ ] Normalize naming/signatures where trivially safe (no semantic change; no renamed public symbol
  without confirming all call sites).
- [ ] Re-cite every `md:NN` comment the split moved/touched (Phase 2 register) to Rabinovich PDF pages
  using the existing style `Rabinovich §5, p.7` (SW:6132); NEVER copy `md:NN` forward as valid.
- [ ] `lake build` green (docstring/comment/section edits must not change elaboration).

**Timing**: ~1.5 hours

**Depends on**: 9

**Files to modify**:
- All five `SharedWitness/*.lean` modules + `SharedWitness.lean` hub — docstrings, sections,
  re-cited comments.

**Verification**:
- `lake build` green; sorry count 0; axiom-clean unchanged. No `md:NN` remains in any comment the
  refactor touched. Commit milestone.

---

### Phase 11: Final Verification [NOT STARTED]

**Goal**: Confirm all invariants preserved across the completed refactor.

**Tasks**:
- [ ] `lake build` full project green from clean (`lake clean && lake build` if feasible in budget).
- [ ] `lean_verify` on all public anchors → axioms exactly `{propext, Classical.choice, Quot.sound}`.
- [ ] `grep -c` sorry/admit in code across all new modules = 0 (baseline preserved).
- [ ] Confirm LITMUS preserved (`NavigatedSpine:437`, UNVERIFIED exact line — locate and confirm
  unchanged) and F1–F7 faithfulness invariants intact (no statement/proof altered).
- [ ] Confirm `SharedWitness.lean` public API import-equivalent to the frozen baseline; `OuterGate.lean`
  and aggregator unchanged.
- [ ] Write the execution summary.

**Timing**: ~1 hour

**Depends on**: 10

**Files to modify**:
- `specs/341_.../summaries/01_module-split-summary.md` — new.

**Verification**:
- Full green, axiom-clean, zero sorries, LITMUS + F1–F7 preserved, API import-equivalent. Final commit.

---

## Testing & Validation

- [ ] `lake build` fully green after EVERY phase (4–11); scoped `lake build Module.Name` per module
  during extraction, full `lake build` at phase end.
- [ ] `lean_verify` axiom check on each module's public anchors returns only
  `{propext, Classical.choice, Quot.sound}`.
- [ ] `grep -c 'sorry\|admit'` (code, not comments) = 0 across all new modules at every phase.
- [ ] `OuterGate.lean` and aggregator `NfMultiAnchorBridge.lean` compile unchanged (import
  preservation proven).
- [ ] LITMUS (`NavigatedSpine:437`) and F1–F7 faithfulness invariants confirmed unchanged.
- [ ] No `md:NN` citation propagated as valid into any refactor-touched comment.

## Artifacts & Outputs

- `specs/341_.../plans/01_module-split-design.md` (this file; Phases 1–3 append design decisions).
- `NfMultiAnchorBridge/SharedWitness/Slots.lean`, `OrdRank.lean`, `HonestOrder.lean`,
  `Coincidence.lean`, `Body.lean` (+ optional C2/D2/E2 sub-splits, + optional `BodyCore.lean`).
- `NfMultiAnchorBridge/SharedWitness.lean` — reduced to a documented re-export hub.
- `Theories/Bimodal/Boneyard/SharedWitnessResidue/` — archive + README.
- `specs/341_.../summaries/01_module-split-summary.md`.

## Rollback/Contingency

- Each phase is an independent green commit; roll back by `git revert` of the offending phase commit —
  earlier module extractions remain valid.
- If the GATE (Phase 3) finds 335 incomplete or the file re-shaped, mark Phase 3 [BLOCKED], keep the
  design artifacts (Phases 1–2 are pure design and remain valid modulo a cut-line refresh), and wait.
- If an extraction cannot land green after reasonable effort, restore the pre-phase state (the moved
  block is verbatim, so re-inlining is mechanical), mark the phase [PARTIAL], and record the failing
  cut line for a refined sub-split.
- Because all moves are verbatim and the hub preserves the public API, no downstream consumer needs
  rollback: reverting the extraction commits returns `SharedWitness.lean` to its monolithic form.
