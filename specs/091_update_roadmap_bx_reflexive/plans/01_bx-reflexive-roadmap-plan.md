---
task: 91
type: plan
session: sess_1776000100_plan91
date: 2026-04-10
status: completed
phase_count: 8
estimated_hours: 5
---

# Implementation Plan: Task #91 - Rewrite ROAD_MAP.md for BX Reflexive Semantics

- **Task**: 91 - update_roadmap_bx_reflexive
- **Status**: [COMPLETED]
- **Effort**: 5 hours
- **Dependencies**: None (research complete)
- **Research Inputs**: specs/091_update_roadmap_bx_reflexive/reports/01_bx-reflexive-roadmap-research.md
- **Artifacts**: plans/01_bx-reflexive-roadmap-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Rewrite `specs/ROAD_MAP.md` to accurately reflect the current all-reflexive Burgess-Xu (BX) architecture. The existing roadmap documents a strict-semantics state from the task 81 migration (March-April 2026) that has been reverted/superseded: the code now uses reflexive `≤`/`≥` temporal semantics, retains the T-axioms as BX1/BX1', and routes completeness through `Metalogic/BXCanonical/` rather than `UltrafilterChain.lean`. The rewrite is a documentation task organized around sections of a new roadmap, not a code change. It produces one authoritative ROAD_MAP.md that is a diff from the current file: preserving still-valid dead-end history and the Dense/FMP/Soundness tracks, deleting stale restricted-coherence architecture, and adding new sections for the BX axiom system, reflexive semantics, the BXCanonical path, the 6 active-path sorries, legacy-code inventory, and the Burgess-Xu Until-induction technique.

### Research Integration

The research report at `specs/091_update_roadmap_bx_reflexive/reports/01_bx-reflexive-roadmap-research.md` is the ground truth for this rewrite. It enumerates 10 specific discrepancies in the current roadmap with file:line evidence, documents the 37 BX axioms in four layers, quotes the reflexive `Truth.lean:120-131` clauses verbatim, inventories the 6 active-path sorries, lists legacy files slated for archival, and explains the Burgess-Xu Until-induction technique. Each phase below cites the specific report section it draws from.

### Prior Plan Reference

No prior plan. This is the first plan for task 91.

### Roadmap Alignment

This task rewrites `specs/ROAD_MAP.md` itself. It is the roadmap-accuracy prerequisite for tasks 90 (Option A vs Option B research), 92 (Until/Since implementation), 93 (Box + TaskModel sorries), 94 (legacy archival), and 95 (axiom audit). All downstream BX completion work depends on an accurate baseline; without this rewrite those tasks would inherit a roadmap that contradicts the code they are modifying.

## Goals & Non-Goals

**Goals**:
- Produce a rewritten `specs/ROAD_MAP.md` that accurately describes the current all-reflexive BX architecture.
- Document the 37 BX axioms grouped by layer with file:line references.
- Quote the reflexive `Truth.lean` temporal clauses verbatim.
- Map the active `Metalogic → BXCanonical/{Frame,TruthLemma,Completeness}` path.
- Enumerate the 6 active-path sorries with file:line, goal summary, blocker, and strategy.
- Inventory legacy strict-semantics files to be archived in task 94.
- Explain the Burgess-Xu Until-induction technique and its role in closing the Frame.lean sorries.
- Preserve still-valid content: the 12 Dead Ends, Dense Completeness, FMP, Soundness, and the decidability-vs-representation-theorem framing.
- Cross-reference downstream tasks 90, 92, 93, 94, 95.

**Non-Goals**:
- Not modifying any Lean source files.
- Not closing any sorries in `BXCanonical/`.
- Not archiving or deleting legacy files (that is task 94).
- Not prescribing implementation strategy for tasks 90/92 beyond what the research report already recorded.
- Not rewriting TODO.md or state.json.
- Not auditing axioms via `#print axioms` (task 95).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Stale claims copied from current ROAD_MAP.md into rewrite | H | M | Phase 1 explicitly extracts only the preserved sections; the Discrepancies table in the research report is the checklist of claims to delete |
| File:line references drift if code changes during rewrite | M | L | Rewrite cites line ranges verbatim from the research report; Phase 8 re-verifies each reference against the current file |
| Conflating BX axiom system with canonical-model strategy | M | M | Phases 2 and 4 are structurally separate; the axiom table stays pure axiomatics, the BXCanonical section stays pure construction |
| Readers misunderstand why X/Y are "useless" | L | M | Phase 3 includes the explicit unfolding calculation from the research report |
| Downstream tasks 90-95 evolve before this rewrite lands | L | M | Roadmap describes current status as of 2026-04-10 with tasks 90-95 as active work items, not as a prescriptive plan |
| Sorry count claims drift | M | L | Use the exact count "6 sorries on the active path" from the research report; cite file:line for each rather than totals |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3, 4, 5, 6, 7 | 1 |
| 3 | 8 | 2, 3, 4, 5, 6, 7 |

Phases within the same wave can execute in parallel (though in practice they will be authored sequentially as sections of the single ROAD_MAP.md file).

### Phase 1: Scaffold new ROAD_MAP.md and archive legacy content [COMPLETED]

**Goal**: Create the skeleton of the rewritten roadmap and identify which current-file content survives.

**Inputs**:
- Current `specs/ROAD_MAP.md` (232 lines)
- Research report "Current ROAD_MAP.md Discrepancies" table (10 rows)
- Research report "Recommendations for Implementer" (items 1-11)

**Tasks**:
- [ ] Read current `specs/ROAD_MAP.md` in full and annotate which sections are preserved vs deleted
- [ ] **Preserve (copy forward)**:
  - "Dead Ends (Archived)" items 1-12 (verify all are still valid anti-patterns)
  - "Dense Completeness (task 68)" section
  - "FMP Truth Preservation (task 82)" section
  - "Soundness Extensions" section
  - "Investigated Dead Ends: Logic Weakening (Task 77)" section
  - "Representation Theorem Goal" paragraphs (decidability-vs-representation-theorem framing)
- [ ] **Delete (do not carry forward)**:
  - The ~220-sorry Overview table (Phase 5 will provide a replacement focused on active-path sorries)
  - "Path A: Original (Full Temporal Coherence) -- BYPASSED" (entire subsection)
  - "Path B: Restricted Coherence -- ACTIVE (Task 81)" (entire subsection; it is no longer active)
  - "What 'Closing the Gap' Means (Task 83)" (task 83 is superseded)
  - "Completeness Chain (Sorry-Free Modulo Task 83)" table
  - "Algebraic Perspective" paragraph (the UltrafilterChain-based algebraic path is legacy)
  - "SuccChainFMCS Working Infrastructure" subsection
  - "Task 81 Contribution" subsection (the migration it describes was reverted)
  - "SuccChain FMCS Legacy Sorries" item (supplanted by Phase 6's legacy inventory)
  - "Recommended Priority Order" (Phase 8 writes a new one)
- [ ] Create the new file skeleton at `specs/ROAD_MAP.md` with section headings in the final order (see Phase 8 for full TOC). Each section contains a placeholder TODO comment that the subsequent phases will fill in.

**Deliverable**: Scaffolded `specs/ROAD_MAP.md` with:
1. Top-of-file Overview (placeholder)
2. BX Axiom System (placeholder — Phase 2)
3. Reflexive Truth Semantics (placeholder — Phase 3)
4. X/Y Operator Status (placeholder — Phase 3)
5. Active Metalogic Path: BXCanonical (placeholder — Phase 4)
6. Canonical Model Construction (placeholder — Phase 4)
7. Active-Path Sorry Inventory (placeholder — Phase 5)
8. Legacy Code Inventory (placeholder — Phase 6)
9. Burgess-Xu Until-Induction Technique (placeholder — Phase 7)
10. Dead Ends (Archived) — preserved content
11. Other Open Items (Dense, FMP, Soundness) — preserved content
12. Investigated Dead Ends: Logic Weakening (Task 77) — preserved
13. Representation Theorem Goal — preserved
14. Recommended Priority Order (placeholder — Phase 8)
15. Task Cross-Reference (placeholder — Phase 8)

**Timing**: 45 minutes

**Depends on**: none

**Files to modify**:
- `specs/ROAD_MAP.md` — replace entirely with scaffolded version preserving enumerated sections

**Verification**:
- New file opens and parses as Markdown
- Every "Preserve" item above appears verbatim (except for minor rewording of intros)
- No "Path A/Path B", "restricted coherence", "Task 81", "Task 83", "SuccChainFMCS", "UltrafilterChain", or "deferralClosure" claims remain in the preserved content or in Section 1 Overview
- Section headings match the final TOC list

---

### Phase 2: Document the BX Axiom System [COMPLETED]

**Goal**: Produce a complete, cited "BX Axiom System" section.

**Inputs**:
- Research report "Current BX Axiom System" (four layers, 37 axioms)
- `Theories/Bimodal/ProofSystem/Axioms.lean` lines 46-272 for direct verification

**Tasks**:
- [ ] Write a 2-3 sentence intro explaining: BX = Burgess-Xu axiomatization, 37 total, grouped into propositional (4), S5 modal (5), BX temporal (26), modal-temporal interaction (2); all sound on the frame class `Base` (linear temporal orders with S5 modal equivalence)
- [ ] Render the four sub-tables from the research report verbatim:
  - Layer 1: Propositional (`prop_k`, `prop_s`, `ex_falso`, `peirce`)
  - Layer 2: S5 Modal (`modal_t`, `modal_4`, `modal_b`, `modal_5_collapse`, `modal_k_dist`)
  - Layer 3: BX Temporal (`temp_k_dist`, `temp_4`, BX1/BX1' through BX12/BX12')
  - Layer 4: Modal-Temporal Interaction (`modal_future`, `temp_future`)
- [ ] Bold BX1 `temp_t_future` (Axioms.lean:117) and BX1' `temp_t_past` (Axioms.lean:121) with the annotation "necessary for reflexive `bx_le`; NOT removed (the claim of T-axiom removal in the previous roadmap was stale)"
- [ ] Add a callout box or paragraph: "Why the axioms prove reflexive semantics": BX8 (`ψ → (φUψ)`) and BX9 (`(φUψ) → (φ ∨ ψ)`) are sound only under reflexive Until (witness `s = t` allowed); under strict `<` semantics BX8 fails. This is the clearest code-level evidence that the codebase is reflexive.
- [ ] Cite the comment at `Axioms.lean:46-49` (Burgess 1982/84, Xu 1988, Venema 1993)

**Deliverable**: "BX Axiom System" section in `specs/ROAD_MAP.md` (~80-100 lines including tables).

**Timing**: 45 minutes

**Depends on**: 1

**Files to modify**:
- `specs/ROAD_MAP.md` (BX Axiom System section)

**Verification**:
- All 37 axioms appear in the tables
- Every file:line reference resolves to the correct constructor in `Axioms.lean`
- BX1/BX1' are highlighted with the "T-axiom NOT removed" annotation
- BX8/BX9 reflexivity argument is included

---

### Phase 3: Document reflexive truth semantics and X/Y operator status [COMPLETED]

**Goal**: Produce the "Reflexive Truth Semantics" and "X/Y Operator Status" sections.

**Inputs**:
- Research report "Reflexive Truth Semantics" (Truth.lean:120-131 verbatim block)
- Research report "X/Y Operator Status" (unfolding calculation)
- `Theories/Bimodal/Semantics/Truth.lean:120-131`
- `Theories/Bimodal/Syntax/Formula.lean:328-334`

**Tasks**:
- [ ] Write "Reflexive Truth Semantics" section:
  - 1-2 sentence intro: "All four temporal operators in TM use reflexive ordering. The current-point is included for G/H (`≤`), and Until/Since witnesses can be the current point (`t ≤ s` / `s ≤ t`) with a half-open guard."
  - Quote `Truth.lean:120-131` verbatim as a Lean code block
  - Bullet the four operator semantics:
    - G (`all_future`): `∀ s, t ≤ s → ...` — reflexive future
    - H (`all_past`): `∀ s, s ≤ t → ...` — reflexive past
    - U (`untl`): `∃ s, t ≤ s ∧ ψ@s ∧ ∀ r, t ≤ r < s → φ@r` — reflexive witness, half-open guard
    - S (`snce`): `∃ s, s ≤ t ∧ ψ@s ∧ ∀ r, s < r ≤ t → φ@r` — mirror
  - Note: "The half-open guard `[t, s)` (strict on the witness side) makes the `s = t` case vacuous for the guard and forces `ψ` at `t` — BX8 is sound."
- [ ] Write "X/Y Operator Status" section:
  - Quote the `Formula.next`/`Formula.prev` definitions from `Formula.lean:328-334`
  - Show the unfolding calculation from the research report (6-step derivation ending in `next φ ≡ φ`)
  - State: "Under the current reflexive semantics with half-open guard, `next φ ≡ φ` and `prev φ ≡ φ` semantically. X/Y are definitional dead code: their docstrings reference 'discrete strict semantics' which is stale (that semantics was reverted). They should not be used in proofs."
  - Link forward to task 94 archival consideration

**Deliverable**: "Reflexive Truth Semantics" (~30 lines) and "X/Y Operator Status" (~20 lines) sections.

**Timing**: 30 minutes

**Depends on**: 1

**Files to modify**:
- `specs/ROAD_MAP.md` (Reflexive Truth Semantics + X/Y Operator Status sections)

**Verification**:
- `Truth.lean:120-131` code block matches the file verbatim
- Formula.lean line references resolve
- The `next φ ≡ φ` derivation has all 6 unfolding steps
- No claim that X/Y are "useful" or "primitive" operators

---

### Phase 4: Document the active Metalogic path (BXCanonical) [COMPLETED]

**Goal**: Produce the "Active Metalogic Path: BXCanonical" and "Canonical Model Construction" sections.

**Inputs**:
- Research report "Active Metalogic Path" (module graph)
- Research report "Canonical Model Construction (BXCanonical)" (BXPoint, bx_le, bx_modal_equiv, lemmas)
- `Theories/Bimodal/Metalogic/Metalogic.lean:4`
- `Theories/Bimodal/Metalogic/BXCanonical/BXCanonical.lean`
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean:46-94`
- `Theories/Bimodal/Metalogic/BXCanonical/TruthLemma.lean:27-36`
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean:124-154`

**Tasks**:
- [ ] Write "Active Metalogic Path: BXCanonical" section:
  - 1-sentence intro: "The active completeness path flows through `Metalogic/BXCanonical/`; the legacy `UltrafilterChain`/`FrameConditions/Completeness`/`SuccChainFMCS` modules are still built via top-level aggregation in `Metalogic.lean` but are NOT imported by `BXCanonical`."
  - Reproduce the module import graph tree verbatim from the research report (lines 170-186)
  - Note the verification: `grep` over `BXCanonical/` imports returns no hits for `UltrafilterChain`, `SuccChainFMCS`, or `FrameConditions.Completeness`
- [ ] Write "Canonical Model Construction" section:
  - **BXPoint** (Frame.lean:46-53): quote the structure definition; note "a canonical frame point is an MCS of formulas"
  - **bx_le** (Frame.lean:56-62): quote `def bx_le (w v : BXPoint) : Prop := g_content w.formulas ⊆ v.formulas`; explain "`w ≤ v ↔ ∀ φ, Gφ ∈ w → φ ∈ v`"; note reflexivity requires BX1 `temp_t_future`, transitivity requires `temp_4`
  - **bx_modal_equiv** (Frame.lean:65-68): quote the definition
  - **Key infrastructure lemmas**: bullet `g_content_closed_derivation`, `h_content_closed_derivation`, `bx_forward_witness`, `bx_backward_witness`, `bx_modal_witness` with file:line refs
  - **Truth Lemma** (TruthLemma.lean:27-36): note cases `atom`, `bot`, `imp`, `box`, `G`, `H` are sorry-free; `U` and `S` delegate to four Frame.lean helper lemmas
  - **Completeness Theorem** (Completeness.lean:124-154): quote the theorem signature; describe the contrapositive proof flow; note the remaining TaskModel-embedding sorry at line 154

**Deliverable**: Two sections totaling ~60-80 lines.

**Timing**: 50 minutes

**Depends on**: 1

**Files to modify**:
- `specs/ROAD_MAP.md` (Active Metalogic Path + Canonical Model Construction sections)

**Verification**:
- Module import tree matches the research report
- Every file:line reference in the Canonical Model Construction subsection resolves
- No mention of restricted coherence, deferralClosure, SuccChainFMCS, or UltrafilterChain in these sections

---

### Phase 5: Inventory remaining sorries (active path) [COMPLETED]

**Goal**: Produce the "Active-Path Sorry Inventory" section — the canonical list of 6 sorries.

**Inputs**:
- Research report "Remaining Sorries (Active Path)" (6-row table)
- `Frame.lean:440, 596-622, 653, 675, 690, 704`
- `Completeness.lean:143-148, 154`

**Tasks**:
- [ ] Write 2-sentence intro: "There are exactly 6 sorries on the active completeness path, all inside `Theories/Bimodal/Metalogic/BXCanonical/`. They fall into three groups: Until/Since eventuality resolution (4), Box modal-witness (1), and TaskModel embedding (1)."
- [ ] Reproduce the 6-row sorry table from the research report with columns: #, File:Line, Definition, Goal Summary, Blocker, Strategy/Owning Task
  - Row 1: Frame.lean:440 — `bx_modal_witness` — owned by task 93
  - Row 2: Frame.lean:653 — `bx_until_eventuality_resolution` — owned by tasks 90+92
  - Row 3: Frame.lean:675 — `bx_until_backward` — owned by tasks 90+92
  - Row 4: Frame.lean:690 — `bx_since_eventuality_resolution` — owned by tasks 90+92
  - Row 5: Frame.lean:704 — `bx_since_backward` — owned by tasks 90+92
  - Row 6: Completeness.lean:154 — `bx_completeness` final step — owned by task 93
- [ ] Add a "Current gap summary" paragraph referencing Frame.lean:596-622 as the module-level analysis
- [ ] Note: "Completeness.lean:143-148 documents the rejected constant-history approach (task 88 anti-pattern); the TaskModel embedding at line 154 must use non-constant histories."

**Deliverable**: "Active-Path Sorry Inventory" section (~40 lines with table).

**Timing**: 30 minutes

**Depends on**: 1

**Files to modify**:
- `specs/ROAD_MAP.md` (Active-Path Sorry Inventory section)

**Verification**:
- Exactly 6 rows in the table
- Every file:line reference resolves to an actual `sorry` in the named definition
- Strategy column references tasks 90/92/93 correctly
- No mention of SuccChainFMCS or UltrafilterChain sorries in this section (they are in Phase 6's Legacy section)

---

### Phase 6: Document legacy code to archive [COMPLETED]

**Goal**: Produce the "Legacy Code Inventory" section listing files slated for task 94 archival.

**Inputs**:
- Research report "Legacy Code Inventory" (4-file table + 2 aggregation-only files)

**Tasks**:
- [ ] Write intro: "The following files were written under a strict-semantics architecture that has since been reverted. They are not imported by `BXCanonical` and are not on the active completeness path. Task 94 will archive them to `Boneyard/StrictSemanticsLegacy/`. Archiving these files mechanically drops approximately 210 sorries from the codebase total."
- [ ] Reproduce the 4-file legacy table from the research report:
  - `Metalogic/Algebraic/UltrafilterChain.lean` (~67 sorries, strict G/H + SuccChain F/P witnesses)
  - `FrameConditions/Completeness.lean` (~54 sorries, original full-coherence completeness)
  - `Metalogic/Algebraic/DovetailedChain.lean` (~29 sorries, dovetailed Z-chain construction)
  - `Metalogic/Bundle/SuccChainFMCS.lean` (~61 sorries, SuccChain FMCS + restricted coherence)
- [ ] List the aggregation-only-but-not-required files: `Metalogic/Completeness.lean`, `Metalogic/Bundle/CanonicalConstruction.lean`
- [ ] Include the verification command: `grep -r "import.*\(UltrafilterChain\|SuccChainFMCS\|FrameConditions\.Completeness\)" Theories/Bimodal/Metalogic/BXCanonical/` returns nothing
- [ ] Note: "X/Y operator definitions in `Syntax/Formula.lean:328-334` are also candidates for archival or deletion (see X/Y Operator Status section) — task 94 should decide."

**Deliverable**: "Legacy Code Inventory" section (~30 lines).

**Timing**: 20 minutes

**Depends on**: 1

**Files to modify**:
- `specs/ROAD_MAP.md` (Legacy Code Inventory section)

**Verification**:
- All 4 files named with correct paths
- Sorry counts match the research report
- The grep verification command is included
- Cross-reference to task 94 is present

---

### Phase 7: Document the Burgess-Xu Until-induction path forward [COMPLETED]

**Goal**: Produce the "Burgess-Xu Until-Induction Technique" section explaining how the 4 Frame.lean Until/Since sorries will be closed.

**Inputs**:
- Research report "Burgess-Xu Until-Induction Technique" (Historical Context, Key Result, 8-item axiom role list, Option A vs Option B)
- Research report "External References" (Burgess 1982, Xu 1988, SEP links)
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean:596-622` module docstring

**Tasks**:
- [ ] Write "Historical Context" subsection: name the papers Burgess (1982) "Axioms for tense logic I" and Xu (1988) "On some U, S-tense logics"; note the Axioms.lean:46-49 comment already cites these; link to the Stanford Encyclopedia Burgess-Xu entry
- [ ] Write "Key Result" subsection: "Burgess (1982), simplified by Xu (1988), gives a complete axiomatization of the Since-Until tense logic over all reflexive linear orderings. BX1-BX12 in `Axioms.lean` are modeled on this axiomatization."
- [ ] Write "Axiom Roles in the Until-Induction Proof" subsection: reproduce the 8-item list from the research report lines 292-301:
  1. BX10 (`until_F`) — extracts F-witness
  2. BX7 (`linear_until`) — linearity of Until witnesses
  3. BX11 (`temp_linearity`) — F-witness linearity
  4. BX5 (`self_accum_until`) — guard propagation
  5. BX6 (`absorb_until`) — prevents infinite deferral
  6. BX9 (`until_elim`) — current-time case under reflexive semantics
  7. BX4 (`connect_future`) — backward contradiction
  8. BX1 (`temp_t_future`) — reflexivity + current-point extraction
- [ ] Write "Option A vs Option B" subsection (task 90's research framing):
  - **Option A**: Redefine `bx_le` from `g_content ⊆` to an Until-witness-based ordering; prove equivalence using BX10 + BX12 + BX4 + BX1. Avoids Henkin closure; more intricate reflexivity/transitivity proofs.
  - **Option B**: Henkin witness closure — explicitly enrich the canonical frame with witness MCS points for each Until/Since formula. Classical Burgess construction.
- [ ] Reference `Frame.lean:596-622` as the module-level analysis in the codebase that task 90 will build on
- [ ] Include the external references block with links:
  - Burgess (1982) ResearchGate URL
  - SEP Burgess-Xu supplementary entry
  - SEP Temporal Logic main article
  - Xu (1988) citation

**Deliverable**: "Burgess-Xu Until-Induction Technique" section (~50-60 lines).

**Timing**: 40 minutes

**Depends on**: 1

**Files to modify**:
- `specs/ROAD_MAP.md` (Burgess-Xu section)

**Verification**:
- All 8 axiom roles listed with axiom names matching Phase 2's table
- Both Option A and Option B described
- External reference links present
- Reference to Frame.lean:596-622 module docstring
- Cross-reference to task 90 (Option A vs B research) and task 92 (implementation)

---

### Phase 8: Final assembly, cross-references, and verification [COMPLETED]

**Goal**: Wire all sections together, write the new Overview and Recommended Priority Order, add the task cross-reference section, and verify every file:line reference.

**Inputs**:
- All drafted sections from Phases 2-7
- Preserved sections from Phase 1
- Research report "Relationship to Tasks 90, 92, 93, 94, 95"
- Research report "Recommendations for Implementer" item 11 (priority order)

**Tasks**:
- [ ] Write new Overview (top of file):
  - 1 sentence: "TM is a bimodal logic combining S5 modality with reflexive linear temporal logic, axiomatized via the Burgess-Xu (BX) system. This roadmap describes the current state of the completeness effort as of 2026-04-10."
  - 2-3 sentence architecture summary: BX axioms (37, reflexive), reflexive truth semantics, BXCanonical completeness path, 6 remaining sorries
  - Active-path sorry summary table (replacing the deleted ~220-sorry table): 4 Until/Since in Frame.lean, 1 Box in Frame.lean, 1 TaskModel in Completeness.lean; total 6 on active path; ~210 legacy sorries to be archived in task 94
  - Pointer: "See sections below for axiom system, semantics, canonical construction, sorry inventory, and the BX Until-induction proof strategy."
- [ ] Write "Recommended Priority Order" section replacing the deleted original:
  1. Task 91 [this task] — rewrite ROAD_MAP.md
  2. Task 94 — archive legacy strict-semantics code (immediate ~210 sorry drop)
  3. Task 90 — research Option A (redefine `bx_le`) vs Option B (Henkin closure)
  4. Task 92 — implement chosen approach; close the 4 Frame.lean Until/Since sorries
  5. Task 93 — close Box direction (Frame.lean:440) and TaskModel embedding (Completeness.lean:154)
  6. Task 95 — `#print axioms` audit; expected `{propext, Classical.choice, Quot.sound}`
  7. Task 68 — dense completeness (independent track)
  8. Task 82 — FMP truth preservation (independent, decidability track)
  9. Task 60 — remove `discrete_Icc_finite_axiom` custom axiom (independent)
- [ ] Write "Task Cross-Reference" section listing tasks 90, 92, 93, 94, 95 with 1-sentence descriptions, status markers, and dependency chain
- [ ] Final verification pass:
  - [ ] Grep the final ROAD_MAP.md for any of: "UltrafilterChain", "SuccChainFMCS", "deferralClosure", "restricted_forward_F", "restricted coherence", "Path A", "Path B", "Task 81 migration", "Task 83" — all should appear ONLY in preserved Dead Ends section (as historical context) or in the Legacy Code Inventory
  - [ ] Verify every `Axioms.lean:NN` reference resolves (manually check against file)
  - [ ] Verify every `Frame.lean:NN`, `TruthLemma.lean:NN`, `Completeness.lean:NN` reference resolves
  - [ ] Verify `Truth.lean:120-131` quoted block matches source
  - [ ] Verify `Formula.lean:328-334` references resolve
  - [ ] Verify section order matches the Phase 1 TOC
  - [ ] Verify all 12 Dead Ends items are preserved
  - [ ] Verify Dense, FMP, Soundness, Logic Weakening sections are preserved
  - [ ] Spell-check and Markdown-lint the file
- [ ] Add final "Last updated" line at the bottom: `*Last updated: 2026-04-10 (task 91)*`

**Deliverable**: Final `specs/ROAD_MAP.md` ready for commit.

**Timing**: 40 minutes

**Depends on**: 2, 3, 4, 5, 6, 7

**Files to modify**:
- `specs/ROAD_MAP.md` (Overview, Recommended Priority Order, Task Cross-Reference sections; final lint pass)

**Verification**:
- No stale-claim grep hits outside preserved Dead Ends section
- All file:line references resolve
- Section order matches TOC
- Preserved sections present
- File is well-formed Markdown

---

## Testing & Validation

- [ ] `specs/ROAD_MAP.md` parses as valid Markdown (no broken tables, no unclosed code fences)
- [ ] Every file:line reference in the new roadmap corresponds to the actual file content at that line
- [ ] The 10 stale claims from the research Discrepancies table are absent (grep check)
- [ ] The 12 Dead Ends items are all preserved
- [ ] The BX axiom table has all 37 axioms grouped by layer (4 + 5 + 26 + 2)
- [ ] The 6-row sorry inventory table exactly matches the research report
- [ ] The 4-file legacy inventory exactly matches the research report
- [ ] Task cross-references (90, 92, 93, 94, 95) are present and accurate
- [ ] No code changes in `Theories/` (documentation-only task)

## Artifacts & Outputs

- `specs/ROAD_MAP.md` — rewritten roadmap (primary deliverable, replaces existing file)
- `specs/091_update_roadmap_bx_reflexive/summaries/01_roadmap-rewrite-summary.md` — execution summary (created by /implement)

## Rollback/Contingency

- **Rollback**: `git checkout HEAD -- specs/ROAD_MAP.md` restores the pre-rewrite version. Since this is a documentation-only change with no code impact, rollback is trivial and carries no risk to the build.
- **Partial completion**: If the rewrite is interrupted mid-phase, the current ROAD_MAP.md may be inconsistent. Mark phase `[PARTIAL]` and resume at the next phase on the next /implement run. Do not merge a partially rewritten ROAD_MAP.md; it is more confusing than the current (stale but internally consistent) version.
- **Discovery of additional discrepancies during rewrite**: If a phase uncovers a claim not listed in the research report's Discrepancies table, document it in the execution summary and apply the same delete-or-preserve decision using the "does the code support this claim?" test.
