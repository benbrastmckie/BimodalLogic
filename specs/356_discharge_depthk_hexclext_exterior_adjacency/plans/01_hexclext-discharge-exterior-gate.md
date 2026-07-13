# Implementation Plan: Task #356 — General-k `hexclExt` Exterior-Adjacency Discharge

- **Task**: 356 - Deliver the general-k `hexclExt` exterior-adjacency discharge lemma (Rabinovich 2014 Lemma 7.6)
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Dependencies**: Tasks 349/351/352/354 (per-side brackets, landed), Task 355 (interior gate, landed). All composition inputs sorry-free.
- **Research Inputs**: specs/356_discharge_depthk_hexclext_exterior_adjacency/reports/01_hexclext-discharge-shape-and-path.md
- **Artifacts**: plans/01_hexclext-discharge-exterior-gate.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/context/workflows/task-breakdown.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Deliver the general-`k` `hexclExt` exterior-adjacency discharge lemma
`bracketEndChar_kvExt_correct_prior` in a new leaf module
`Theories/Bimodal/.../NfMultiAnchorBridge/ExteriorGateAssembleK.lean`. This is a near-mechanical
general-`k` mirror of the already-landed k=2 discharge
`bracketEndChar_kvE2Ext_correct_two_prior_frag` (ExteriorBracket.lean:1069), one fold deeper. The
lemma composes the interior carrier `bracketEndChar_kv` at depth `(k+2)` with the two adjacent
exterior brackets (`kvE_extBracketPast`/`kvE_extBracketFut`) via `enrichEndpoints`, discharging the
`hexclExt` obligation that task 355's interior gate carries outward. Every composition input is
already landed sorry-free. Definition of done: the discharge lemma is green and sorry-free, axioms
exactly `[propext, Classical.choice, Quot.sound]`, full-tree `lake build` GREEN, consumable by task
357 and by KampPrior.lean:351.

### Research Integration

Report `01_hexclext-discharge-shape-and-path.md` (verdict GREEN-VIABLE) supplies the complete
transcription path and 5-column reference-grounding table. Key integrated findings:
- The deliverable is three things: (1) `bracketEndChar_kvExt` (enriched composed gate), (2)
  `bracketEndChar_kvExt_holds_iff` (one-line reuse of `VVecEA2.enrichEndpoints_holds`), (3)
  `bracketEndChar_kvExt_correct_prior` (the DoD `hexclExt` discharge lemma).
- All inputs landed sorry-free: `kvE_extBracketPast/Fut` + `_sound`/`_complete`
  (ExteriorBracketAssembleK.lean), `kvE_futBundle_of_realizer`/`kvE_pastBundle_of_realizer`
  (ExteriorConverterK.lean:208 / PastK:177), `bracketEndChar_kv_step_sound`/`_correct` +
  `bracketEndChar_kv_correct_prior` (InteriorGateGeneralK.lean).
- The internal `hexclExt` discharge is the verbatim k=2 guard-split (`not_and_or.mp` +
  `not_le.mp` → per-side `_sound`), reindexed.
- Depth-index anchor: state the discharge at `bracketEndChar_kv … (k+2)`, `qnf : NormalForm sig
  (k+2) 3`, so σ `: NormalForm sig (k+1) 4` matches the AssembleK bracket lemmas with no reindex.
  The k=2 discharge is the `k=0` member of this family (cross-check).
- Single escalation-risk site: the ⇐-direction positive-witness positioning (`hpos`). k=2 used
  `kvE2_*Marked` zone bits; general-`k` uses the `kvE_*Admissible` order predicate. If the
  line-by-line mirror stalls there, mark [BLOCKED] with the exact goal state — do NOT land a
  `sorry` or a vacuous definition.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` provided in delegation context; roadmap consultation skipped. This task is
exterior-bracket-layer work (sibling to delivered tasks 348/351/352/354), feeding KampPrior.lean:351
via task 357.

## Goals & Non-Goals

**Goals**:
- Create the new leaf module `NfMultiAnchorBridge/ExteriorGateAssembleK.lean`, importing
  `InteriorGateGeneralK` and `ExteriorBracketAssembleK` (acyclic, purely additive).
- Define `bracketEndChar_kvExt` (enriched composed gate via `enrichEndpoints`).
- Prove `bracketEndChar_kvExt_holds_iff` (reuse of `VVecEA2.enrichEndpoints_holds`).
- Prove `bracketEndChar_kvExt_correct_prior` — the enriched-gate biconditional carrying only
  `P, hcharK, h_UZ, h_SZ, hreal, hexcl` (+ order bits), with `hexclExt` discharged internally.
- Full-tree `lake build` GREEN; `lean_verify bracketEndChar_kvExt_correct_prior` axioms exactly
  `[propext, Classical.choice, Quot.sound]`.

**Non-Goals**:
- KampPrior.lean:351 site wiring, import-graph aggregator threading, and site-certificate reshape
  (that is **task 357**).
- Discharging `hreal`/`hexcl` (interior realization + within-`[x,t]` cone exclusion) — these
  **remain threaded** by the lemma, discharged by the provider instantiation at the KampPrior
  recursion (task 309 P14 / task 357).
- Any interior-gate mathematics (that was task 355).
- Interior depths 0 and 1 (already-delivered base rungs carrying no exterior obligation).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| ⇐-direction `hpos` positive-witness positioning does not mirror (k=2 zone bits → general-k order predicate) | H | M | Mirror `kvE_futAdmissible`/`kvE_pastAdmissible` semantics + realized qnf arity-4 order layer per AssembleK header (lines 20-23). If it stalls, mark Phase 4 [BLOCKED] with exact goal state, route to targeted spawn — NEVER land a `sorry` or vacuous def (escalation rule). |
| Depth-index misalignment between interior carrier `(k+2)` and bracket lemmas σ `(k+1)` | H | L | State discharge at `(k+2)`; instantiate `bracketEndChar_kv_step_correct` at `k := k+1`. Cross-check against k=2 member (`k=0`, `qnf : NormalForm sig 2 3`). |
| `charF` vs `P` reconciliation in the composed gate | M | L | Bake `charF (k+1) := fun χ => P.existF 0 χ` (the `hcharK` convention) so interior carrier and brackets share `P`; mirror ExteriorBracket.lean:661. |
| New import introduces a cycle or breaks full-tree build | M | L | Import only `InteriorGateGeneralK` + `ExteriorBracketAssembleK` (confirmed acyclic; they do not import each other). `enrichEndpoints` reachable transitively. Additive-only leaf; verify with `lake build` in Phase 1. |
| ⇒-direction (the actual DoD `hexclExt` discharge) fails to transcribe | H | VL | It is a verbatim reindexed mirror of ExteriorBracket.lean:1120-1129; research confidence High. Isolated as its own phase (Phase 3) so the DoD-critical direction lands independently of the ⇐ risk. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel. This plan is fully sequential (each phase
builds on the previous file state).

### Phase 1: Scaffold leaf module + import reachability [COMPLETED]

**Goal**: Create `ExteriorGateAssembleK.lean` with correct imports and a compiling (empty-body)
skeleton, confirming the import chain is acyclic and reachable.

**Tasks**:
- [ ] Create `Theories/Bimodal/.../NfMultiAnchorBridge/ExteriorGateAssembleK.lean` importing
  `…NfMultiAnchorBridge.InteriorGateGeneralK` (interior step + carrier) and
  `…NfMultiAnchorBridge.ExteriorBracketAssembleK` (per-side brackets).
- [ ] Confirm `VVecEA2.enrichEndpoints`/`enrichEndpoints_holds` are reachable transitively
  (AssembleK → ExteriorBracketK → ExteriorBracket).
- [ ] Open the correct namespace(s); mirror the header block of the k=2 `ExteriorBracket.lean`.
- [ ] Add a module doc-comment stating scope (general-k exterior adjacency discharge, task 356).
- [ ] Verify `lake build` of the new (empty) module succeeds; confirm no import cycle.

**Timing**: 0.75 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/.../NfMultiAnchorBridge/ExteriorGateAssembleK.lean` — new file (create).

**Verification**:
- `lake build` on the new module target succeeds (no cycle, imports resolve).
- `lean_diagnostic_messages` on the file reports no errors.

---

### Phase 2: `bracketEndChar_kvExt` def + `_holds_iff` bridge [IN PROGRESS]

**Goal**: Define the general-`k` enriched composed gate and its anchor-semantics bridge.

**Tasks**:
- [ ] Define `bracketEndChar_kvExt` as `(bracketEndChar_kv … (k+2) qnf).enrichEndpoints
  (kvE_extBracketPast P qnf) (kvE_extBracketFut P qnf) : VVecEA2`. Mirror ExteriorBracket.lean:661.
- [ ] Reconcile `charF` vs `P`: bake `charF (k+1) := fun χ => P.existF 0 χ` (hcharK convention) so
  the interior carrier and the two brackets share `P`.
- [ ] Prove `bracketEndChar_kvExt_holds_iff` by one-line reuse of `VVecEA2.enrichEndpoints_holds`
  (mirror ExteriorBracket.lean:674) — `holds ↔ v.holds ∧ pL@x ∧ pR@t`.
- [ ] Confirm the carrier type is `VVecEA2` (via `BracketEndCharCarrierV`, CarrierK1V.lean:365) so
  `enrichEndpoints` applies at general `k`.

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/.../NfMultiAnchorBridge/ExteriorGateAssembleK.lean` — add def + bridge lemma.

**Verification**:
- `bracketEndChar_kvExt` typechecks at `qnf : NormalForm sig (k+2) 3`.
- `bracketEndChar_kvExt_holds_iff` is sorry-free; `lean_diagnostic_messages` clean.
- `lake build` on the module succeeds.

---

### Phase 3: `bracketEndChar_kvExt_correct_prior` ⇒ direction (the `hexclExt` discharge) [NOT STARTED]

**Goal**: Land the forward (⇒) direction — the DoD-critical internal `hexclExt` discharge. This is
the verbatim reindexed k=2 guard-split; low-risk and highest-value.

**Tasks**:
- [ ] State `bracketEndChar_kvExt_correct_prior`: `holds ↔ ∃ w, nf_eval_nf M (k+2) 3 [w,x,t] qnf`,
  carrying `P, hcharK, h_UZ, h_SZ, hreal, hexcl` + six order bits; `hexclExt` internal.
- [ ] ⇒: destructure via `_holds_iff` → interior `.holds` + past bracket @x + future bracket @t.
- [ ] Build the inline `hexclExt` lambda fed to `bracketEndChar_kv_step_sound`, reindexing the k=2
  pattern (ExteriorBracket.lean:1120-1129):
  `intro w hxw hwt hptW σ hbit x1 hguard hnf; rcases not_and_or.mp hguard with hx | ht`
  `· exact kvE_extBracketPast_sound … (not_le.mp hx) hnf`
  `· exact kvE_extBracketFut_sound … (not_le.mp ht) hnf`.
- [ ] Instantiate `bracketEndChar_kv_step_correct` at `k := k+1` so its σ `: NormalForm sig (k+1) 4`
  aligns with the AssembleK bracket lemmas (no reindex).
- [ ] Leave the ⇐ direction as a clearly-marked hole (`sorry` placeholder ONLY as a transient
  build marker within this phase's local iteration — must not be committed; Phase 4 removes it).
  Prefer structuring so the ⇒ direction compiles behind a `constructor`/`refine` with the ⇐ arm
  isolated.

**Timing**: 1.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/.../NfMultiAnchorBridge/ExteriorGateAssembleK.lean` — add lemma statement + ⇒ proof.

**Verification**:
- The ⇒ arm typechecks with no errors (`lean_goal` shows the ⇐ arm as the only remaining goal).
- No `sorry` is committed at phase end unless Phase 4 is a separate uncommitted iteration; the
  green commit for this phase covers the ⇒ arm only if the lemma can be split, otherwise defer the
  commit to Phase 4 completion.

---

### Phase 4: `bracketEndChar_kvExt_correct_prior` ⇐ direction (completeness) [NOT STARTED]

**Goal**: Land the reverse (⇐) direction, re-establishing interior + both brackets from a realizer.
This phase contains the single flagged escalation-risk site.

**Tasks**:
- [ ] From `⟨w, h⟩` derive `x < w < t` from the realized order bits.
- [ ] Re-establish interior via the completeness half of `bracketEndChar_kv_step_correct`.
- [ ] Re-establish the two brackets via `kvE_extBracketPast_complete` / `kvE_extBracketFut_complete`,
  feeding `hreal`/`hsat` from `kvE_pastBundle_of_realizer` / `kvE_futBundle_of_realizer` and
  `hpos`/`hneg` from the realized qnf. Mirror ExteriorBracket.lean:1130-1171.
- [ ] **Escalation-risk site**: the positive-witness positioning (`hpos`) needs the realizer
  positioned strictly exterior (`t < x1` / `x1 < x`). At k=2 this came from `kvE2_*Marked` zone
  bits; at general `k` it must come from `kvE_futAdmissible`/`kvE_pastAdmissible` semantics + the
  realized qnf's arity-4 order layer (AssembleK header lines 20-23 prescribe
  `kvE_futRealizer_admissible`). Mirror line-by-line.
- [ ] **If the `hpos` positioning does NOT go through**: mark this phase [BLOCKED] in the plan,
  record the exact `lean_goal` state and the stuck subgoal, and route to a targeted spawn. Do NOT
  land a `sorry` and do NOT weaken/vacuate the definition (task escalation rule).

**Timing**: 1.5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/.../NfMultiAnchorBridge/ExteriorGateAssembleK.lean` — add ⇐ proof, completing the lemma.

**Verification**:
- `bracketEndChar_kvExt_correct_prior` is fully sorry-free; `lean_diagnostic_messages` clean.
- `grep -c sorry` on the new file = 0.
- If BLOCKED: metadata status = `blocked`, exact goal state recorded, ⇒ direction preserved green.

---

### Phase 5: Axiom verification + full-tree green + consumability [NOT STARTED]

**Goal**: Confirm the deliverable meets DoD and is consumable by task 357 / KampPrior.lean:351.

**Tasks**:
- [ ] Run full-tree `lake build`; confirm GREEN (no new errors anywhere in the tree).
- [ ] Run `lean_verify bracketEndChar_kvExt_correct_prior`; confirm axioms are exactly
  `[propext, Classical.choice, Quot.sound]` (no `sorryAx`, no extra axioms).
- [ ] Confirm the lemma signature carries exactly `P, hcharK, h_UZ, h_SZ, hreal, hexcl` + order
  bits, with `hexclExt` discharged internally (matches the consumability shape task 357 expects).
- [ ] Cross-check the `k=0` member instantiates to the same shape as the landed k=2 discharge
  (sanity, not a proof obligation).
- [ ] Do NOT modify KampPrior.lean or the aggregator import graph (task 357 scope).

**Timing**: 1.25 hours

**Depends on**: 4

**Files to modify**:
- None (verification only; no edits unless a build fix in the new file is required).

**Verification**:
- Full-tree `lake build` exits 0.
- `lean_verify` axiom set exactly `[propext, Classical.choice, Quot.sound]`.
- New file `grep -c sorry` = 0.

## Testing & Validation

- [ ] `lake build` full-tree GREEN (no regressions across the tree).
- [ ] `lean_verify bracketEndChar_kvExt_correct_prior` → axioms exactly `[propext, Classical.choice, Quot.sound]`.
- [ ] `grep -c sorry ExteriorGateAssembleK.lean` = 0.
- [ ] `bracketEndChar_kvExt_correct_prior` signature carries only `P, hcharK, h_UZ, h_SZ, hreal,
  hexcl` + order bits (hexclExt internal) — consumability shape for task 357.
- [ ] Import chain acyclic (new leaf imports only `InteriorGateGeneralK` + `ExteriorBracketAssembleK`).

## Artifacts & Outputs

- `Theories/Bimodal/.../NfMultiAnchorBridge/ExteriorGateAssembleK.lean` (new leaf module) containing:
  - `bracketEndChar_kvExt` (def)
  - `bracketEndChar_kvExt_holds_iff` (lemma)
  - `bracketEndChar_kvExt_correct_prior` (the DoD `hexclExt` discharge lemma)
- Implementation summary at `specs/356_.../summaries/01_hexclext-discharge-exterior-gate-summary.md` (at /implement).

## Rollback/Contingency

- The change is purely additive (one new leaf module; no edits to existing files). Rollback = delete
  `ExteriorGateAssembleK.lean`; the tree returns to its current GREEN state with no other changes.
- If Phase 4 (⇐ direction, `hpos` positioning) cannot close green: mark the task [BLOCKED] rather
  than landing a `sorry` or a vacuous definition. Preserve the green ⇒ direction (the DoD-critical
  `hexclExt` discharge) and record the exact stuck goal state for a targeted spawn. The escalation
  rule is absolute: no `sorry`, no vacuous def.
