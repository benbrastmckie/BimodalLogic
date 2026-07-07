# Implementation Plan v2: Nine-Zone-Gate Correction of the VVecEA2 Arrangement-Disjunction Carrier

- **Task**: 325 - redesign_k2_subbracket_to_vvecea2_arrangementdisjunction
- **Status**: [NOT STARTED]
- **Effort**: 10-14 hours
- **Dependencies**: None (standalone; parent task 321 resumes via /revise 321 after completion)
- **Research Inputs**:
  - specs/325_redesign_k2_subbracket_to_vvecea2_arrangementdisjunction/reports/01_adversarial-verification.md (H4-verified PROCEED-TO-PLAN gate; four precision corrections BINDING and folded in)
  - specs/325_redesign_k2_subbracket_to_vvecea2_arrangementdisjunction/.orchestrator-handoff.json (machine-verified v1 Phase-4 BLOCKER: 7-zone gate omits the two interior witness self-zones; two probes built green over the actual carrier then removed)
  - specs/325_redesign_k2_subbracket_to_vvecea2_arrangementdisjunction/plans/01_vvecea2-carrier-redesign.md (v1 plan; Phases 1-3 landed, Phase 4 BLOCKED; superseded by this v2)
  - specs/324_redesign_k2_subbracket_arity4_correctness_pair/reports/02_phase6-blocker-research.md (machine-grounded Q3 corrected target definition + preserved-asset accounting)
  - specs/321.../reports/01_blocker-research-successor-k.md Section 2 (successor `j+1` amended design spec, :56/:225)
- **Artifacts**: plans/02_vvecea2-carrier-v2-nine-zone-gate.md (this file); supersedes plans/01_vvecea2-carrier-redesign.md
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/plan-format-enforcement.md
  - .claude/rules/state-management.md
  - .claude/rules/git-workflow.md
- **Type**: lean4

## Overview

Task 325 v1 landed a `VVecEA2` arrangement-disjunction carrier `kvE_subBracket2V`
(`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean:6779`) with three
per-region segment types and a three-region construction kit (Phases 1-3 [COMPLETED]), then hit a
**machine-verified** obstruction at Phase 4 completeness (v1 plan Phase 4 [BLOCKED]; handoff
`blockers`). Two probe theorems (`kvE_subBracket2V_gate_unsat_PROBE`,
`kvE_subBracket2V_never_holds_PROBE`) were **built green over the actual carrier** and then removed
to keep the tree byte-identical to commit `be9f35965`.

**Root cause (machine-verified).** The carrier's gate `consistent` set (:6846) lists only SEVEN
zones — `zPastX, zAtX, zXU, zUW, zWT, zAtT, zFutT` — and OMITS the two interior WITNESS SELF-ZONES:
- `zAtX1` (`v = x1`, spec `(F,F)(T,F)(F,T)(T,F)` = `mk4 eqz ltz gtz ltz`)
- `zAtW`  (`v = w`,  spec `(F,T)(F,F)(F,T)(T,F)` = `mk4 gtz eqz gtz ltz`)

Neither self-zone's 1-type literals are folded into the witness point-types `ptX1` (:6840,
`⟨charK (nfk_projFresh σ)⟩`) or `ptW` (:6841, `⟨charBase (proj 1)⟩`). For **every** honest
realization, `x1` realizes its own complete 1-type at `zAtX1` (and `w` at `zAtW`), so
`nf_eval_depth1_fold_iff` (:5187) forces `bits zAtX1 χ0 = true`; but the gate's second conjunct
`∀ zs χ, ¬consistent zs → bits zs χ = false` then demands that same bit `false`. Contradiction ⇒
gate false ⇒ carrier takes the `disjuncts := []` branch ⇒ `.holds` is `False` for **all** models.
Consequently v1 Phase-3 soundness `kvE_subBracket2V_sound` (commit `be9f35965`) closed only
**VACUOUSLY** (its hypothesis is the always-`False` `.holds`), and completeness is unprovable (true
hypothesis → `False` conclusion). This is the **THIRD** gate-class failure (see Postmortem below):
same class as task 324 Phase 6 (soundness vacuous, completeness false ∀-M).

**The fix (machine-identified in the blocker; mirrors the proven k1v template).** Extend the gate's
`consistent` set to NINE zones (add `zAtX1`, `zAtW`) and FOLD each witness self-zone's 1-type
literals into `ptX1` / `ptW` respectively — the exact arity-4 analog of how the landed
`bracketEndChar_k1v` carrier includes its single witness self-zone `zAtW` in its 7-zone gate
(:1752/:3632) and folds the zAtW literals into its `ptW` (`hptW`, :3277). k1v has ONE interior
witness ⇒ 7 zones; the arity-4 carrier has TWO interior witnesses (`x1`, `w`) ⇒ 9 zones.

**Deliverable (unchanged from v1).** Standalone against `nf_eval_nf M 1 4`, NOT wired into the outer
gate: a corrected carrier with codomain `VVecEA2` (`VecEAFormula.lean:271`) plus a **freshly
re-derived, machine-driven-through soundness AND completeness pair** — the arity-4 analog of
`bracketEndChar_k1v_sound` (:2338) / `bracketEndChar_k1v_complete` (:2979). Definition of done: BOTH
`kvE_subBracket2V_sound` and `kvE_subBracket2V_complete` compile **sorry-free**, are **axiom-clean**
(`propext`, `Classical.choice`, `Quot.sound` only), use no forbidden tactics, AND — new, mandatory —
the corrected carrier passes a **machine-checked NON-VACUITY GATE** (below) BEFORE either direction
is attempted, so soundness can never again close vacuously.

### Naming Decision (SETTLED — amend task 325's own defs IN PLACE, same names)

**Decision:** v2 AMENDS task 325's own Phase 1-3 definitions **in place, retaining their existing
names** (`kvE_subBracket2V`, `kvE_subChain2V`, `bracketFromLists3`, `k1v_sorted_realization3`,
`k1v_bracket_construct3`, `bracketFromLists3_extract`, `kvE_subBracket2V_sound` and its RE-DERIVE
kit). It does NOT introduce fresh `…V2` names.

**Justification (three grounds):**
1. **Not on any DO-NOT-EDIT list.** The guards' byte-identical requirement covers **PRIOR** tasks'
   landed assets — task-321 Stage A/B (`kvE_subFoldBits`/`kvE_subInteriorZones`/`kvE_subBracket`/
   `kvE_subChain`/`kvE2_body`/`bracketEndChar_kvE2`/Stage-B discrimination), task-324's Phases 1-5
   (`kvE_subBracket2`/`kvE_subChain2` + the full zone/reach/sound/extract kit ~:6120-6720), the k1v
   templates (`bracketEndChar_k1v`/`_sound`/`_complete` + kit :2028-2979), `BracketCarrierCorrectVPrior`,
   `ExistProviders`, task-310/311 material, task-320 probes. The definitions listed above were
   CREATED AND COMMITTED BY TASK 325 ITSELF (Phases 1-3, commit `be9f35965`); they are this task's
   own work product, not a prior landed asset.
2. **Nothing else references them.** They are standalone against `nf_eval_nf M 1 4` and are NOT
   wired into the outer gate (`kvE2_body`/`bracketEndChar_kvE2` re-point is task 321's future
   `/revise 321` work, explicitly out of scope). No symbol outside task 325's own kit consumes them,
   so amending in place breaks nothing.
3. **Cleaner + avoids a false preservation obligation.** The v1 carrier closed only VACUOUSLY — it
   has no validated status worth freezing byte-identical. A `…V2` rename would (a) proliferate names,
   (b) leave the defective v1 carrier as dead code that future readers must be warned away from, and
   (c) create a second byte-identical-original obligation for an object that was never correct.
   Amending in place is the surgical minimum: only the carrier's `consistent` set + `ptX1`/`ptW`
   change, plus a re-drive of the carrier-binding soundness chain.

**Guard compliance:** every PRIOR landed asset (all of the byte-identical list in ground 1) stays
untouched. A per-phase `git diff` byte-identical check over those PRIOR ranges is retained (R5); the
in-place edits are confined to task 325's own :6728-onward block.

### Codomain precision (adversarial-verification Correction 1 — BINDING, carried forward)

The codomain is `VVecEA2` — a **structure** wrapping `disjuncts : List (Σ n, VecEA2 n)`
(`VecEAFormula.lean:271-273`); each *disjunct* is a `Σ n, VecEA2 n` (:252). Do NOT state the codomain
as the bare `Σ n, VecEA2 n`. Disjuncts are selected in completeness via `VVecEA2.holds`'s
`∃ vea ∈ disjuncts, vea.2.holds M atomMap x t` (:276) at the fixed endpoints `(x,t)`.

## Preserved Assets & Fate Under the v2 Correction

All PRIOR landed work stays **byte-identical and unreferenced by new work** (do-not-edit list,
verbatim from the task description). The new-definitions-only exception (authorized for THIS task
only) is EXTENDED by the Naming Decision above to also permit in-place amendment of task 325's OWN
committed defs (grounds 1-3). `kvE2_body`/`bracketEndChar_kvE2` are NOT re-pointed (task 321's work).

| Component | File / Location | Fate under v2 | Verified |
|-----------|-----------------|---------------|----------|
| Task-324 landed carrier `kvE_subBracket2`/`kvE_subChain2` + full kit ~:6120-6720 | :6120-6720 | PRIOR — byte-identical, untouched | v1 report 01 |
| k1v correctness templates `bracketEndChar_k1v_sound`/`_complete` + kit :2028-2979 | :2338 / :2979 | PRIOR — consume as template, byte-identical | v1 report 01; :1752/:3277/:3632 (this session) |
| Task-321 Stage A/B, `BracketCarrierCorrectVPrior`, `ExistProviders`, task-310/311, task-320 probes | NfMultiAnchorBridge.lean | PRIOR — byte-identical, do NOT re-point | task description |
| **SURVIVE — task-324 carrier-agnostic survivors** `kvE_sub2_zoneHolds_cons_iff`/`_zXU`/`_zUW`/`_zWT` (:6615-6671), `kvE_subBracket2_complete_extract` (:6683), `kvE_sub2_zXU`/`zUW`/`zWT` zone specs (:6200-6208) | :6200-6694 | SURVIVE — consume verbatim (names misleading, statements carrier-agnostic — Correction 3) | v1 report 01 |
| **SURVIVE — task-325's own carrier-INDEPENDENT kit** `bracketFromLists3` (:6753), `k1v_sorted_realization3` (:6926), `k1v_bracket_construct3` (:7002), `bracketFromLists3_extract` (:7230) | :6753-7343 | SURVIVE unchanged — all take `ptX1`/`ptW`/`segXU`/`segUW`/`segWT` as EXPLICIT args and conclude over `bracketFromLists3 … .holds`; none reference the carrier gate/`consistent`/`bits`. Confirmed by Read: `k1v_bracket_construct3` concludes `(bracketFromLists3 …).holds` (:7024); `bracketFromLists3_extract` hyp is `(bracketFromLists3 …).holds` (:7234) | this session (grep :6753-7343) |
| **AMEND IN PLACE — the carrier** `kvE_subBracket2V` (:6779), `kvE_subChain2V` (:6880) | :6779-6913 | AMEND — 9-zone `consistent` (+`zAtX1`,`zAtW`) + fold self-types into `ptX1`/`ptW`; `kvE_subChain2V` re-checks (structurally unchanged, defeq re-verify) | this session |
| **RE-DRIVE (non-vacuously) — carrier-binding soundness chain** `kvE_subBracket2V_extract` (:7315), `_reaches_zXU`/`_zUW`/`_zWT` (:7371/7390/7409), `_fold_z*` (:7430/7449/7468), `kvE_subBracket2V_sound` (~:7488) | :7315-7500 | RE-DRIVE — these `simp only [kvE_subBracket2V, VVecEA2.holds]` and must re-close over the corrected (now NON-empty) carrier; v1's vacuous close no longer applies | this session |

**FORBIDDEN to consume**: `EANegation.lean:1090` and `:1249` (uniform-backward variants) — both are
machine-confirmed live `sorry`s.

## The Mandatory NON-VACUITY GATE (new v2 obligation — structural countermeasure)

**Rationale.** Two consecutive iterations (task 324 Phase 6; task 325 v1 Phase 4) closed soundness
on an always-`False` carrier, and only a hand-written probe over the actual carrier later exposed the
emptiness. **Vacuous soundness must never again count as validation.** v2 therefore adds an EXPLICIT,
committed, machine-checked non-vacuity lemma that MUST close BEFORE soundness or completeness is
attempted, and whose success is a hard exit criterion of Phase 1.

**Obligation `kvE_subBracket2V_nonvacuous` (Phase 1, mandatory):** demonstrate the corrected gate is
satisfiable by an honest σ — i.e. for σ arising from an actual model realization
`(∃ x1, nf_eval_nf M 1 4 (Fin.cons x1 [w,x,t]) σ)`, the carrier gate holds and the carrier's
`disjuncts` list is NON-empty, so `(kvE_subBracket2V …).holds M atomMap x t` is NOT definitionally
`False`. Concretely, a two-part driven lemma:
1. `kvE_subBracket2V_gate_holds_of_honest`: honest σ ⟹ `gate` (both conjuncts). The second conjunct
   now discharges because `zAtX1`, `zAtW` ∈ `consistent`, so the forced-true bits at those zones no
   longer contradict `¬consistent zs → bits zs χ = false`. This is the EXACT statement whose negation
   the removed v1 probe `kvE_subBracket2V_gate_unsat_PROBE` proved over the old 7-zone gate — it must
   now flip to provable.
2. `kvE_subBracket2V_nonvacuous`: honest σ ⟹ `(kvE_subBracket2V …).disjuncts ≠ []` (the gate-true
   branch selects the non-empty `flatMap` arrangement list). Directly refutes the removed v1 probe
   `kvE_subBracket2V_never_holds_PROBE`.

**Hard gate:** Phase 1 does NOT count complete until both lemmas close sorry-free. Phases 2-3
(soundness/completeness) MUST NOT begin until the non-vacuity lemma is green. If the corrected gate
is somehow still unsatisfiable, STOP and write a blocker report — do NOT proceed to a soundness proof
that could close vacuously.

## Postmortem Constraints

Binding rules for all implementation dispatches. Derived from THREE machine-grounded gate-class
failures and the task's binding constraints.

### The three prior gate-class failures and the v2 structural countermeasure

| # | Failure | Carrier / phase | Machine-verified defect | How v2 avoids it |
|---|---------|-----------------|-------------------------|------------------|
| 1 | **Reachability** | `kvE_subBracket` (task 321 Phase 8) | Upward-only `Until` chain anchored at the interior σ-witness slot could not express a `zXU` witness lying BELOW the anchor — a latent soundness gap found only when driven | Carrier anchors at fixed endpoints `{x,t}`; `x1`/`w` are interior witness slots (not anchors); soundness DRIVEN (Phase 2) |
| 2 | **False-converse** | `kvE_subBracket2` (task 324 Phase 6) | Single `BracketFormula` with CONSTANT tri-zone `segExcl` + fixed filter-order `pointTypes`; completeness converse a false ∀-M statement (per-point `IntervalPattern.holds` vs constant multi-zone; positional monotone witnesses vs fixed order) | `VVecEA2` disjunction + THREE PER-REGION segment types `segXU`/`segUW`/`segWT` (each excludes only its own region's negatives); completeness DRIVEN (Phase 3) |
| 3 | **Empty-gate vacuity** (THIS iteration) | `kvE_subBracket2V` v1 (task 325 v1 Phase 4) | 7-zone gate OMITS witness self-zones `zAtX1`/`zAtW`; honest σ forces `bits zAtX1 χ0 = true`, gate demands `false` ⇒ gate always false ⇒ carrier always empty ⇒ soundness closed VACUOUSLY, completeness unprovable | **9-zone gate** (adds `zAtX1`,`zAtW`) + fold self-types into `ptX1`/`ptW` (k1v `ptW` pattern :3277); **plus the mandatory NON-VACUITY GATE** (above) — a machine-checked gate-satisfiability lemma that MUST close before soundness/completeness, so vacuous soundness can never again pass as validation |

**Structural countermeasure introduced by v2:** the NON-VACUITY GATE. Every future carrier redesign
in this family MUST prove its gate satisfiable by an honest σ before any soundness proof is accepted.

### DRIVEN-PROOF VALIDATION DISCIPLINE (mandatory, binding — carried forward verbatim)

Do NOT accept the redesigned construction on type-check/probe grounds. THREE consecutive prior
constructions have now failed EXACTLY that way — `kvE_subBracket` (task 321 Phase 8: type-checked and
probed clean, unreachable-below-anchor), `kvE_subBracket2` (task 324 Phase 6: type-checked and probed
clean at soundness, false-∀-M completeness), and `kvE_subBracket2V` v1 (task 325 v1: type-checked and
probed clean at soundness, but VACUOUSLY on an always-`False` carrier). The corrected construction
MUST be validated by actually driving BOTH the soundness direction AND the completeness direction
through to a closed, sorry-free proof — AND by the new NON-VACUITY GATE — before it counts as
validated. **Neither direction may be deferred, assumed, or accepted on the strength of the other
having closed; and neither may close over an empty carrier.** If completeness hits a genuine
obstruction, STOP and write a blocker report — do NOT place a `sorry` and do NOT accept a
soundness-only deliverable.

### Do NOT

- **Do NOT accept a type-check/probe-clean OR a vacuously-closed construction as validated.** All
  three prior failures passed type-check/probes; v1 additionally closed soundness vacuously.
  Validation = NON-VACUITY GATE green AND both directions driven to closed, sorry-free proofs.
- **Do NOT leave `zAtX1` or `zAtW` out of the gate `consistent` set.** Their omission is the exact
  Failure-3 defect. The corrected `consistent` set has NINE zones.
- **Do NOT leave `ptX1`/`ptW` unfolded.** Each must fold ITS OWN witness self-zone's 1-type literals
  (arity-4 analog of k1v `ptW` zAtW-folding :3277), else soundness cannot re-derive the self-zone
  membership and completeness cannot discharge the witness point.
- **Do NOT reuse a constant multi-zone segment type** (Failure 2). Per-region `segXU`/`segUW`/`segWT`
  each exclude only their own region's negatives.
- **Do NOT emit a single `BracketFormula` codomain.** Codomain is `VVecEA2`.
- **Do NOT be misled by preserved-asset names** (Correction 3): `kvE_subBracket2_complete_extract`
  and `kvE_sub2_zoneHolds_*` survive near-verbatim despite `subBracket2`/`sub2` in their names.
- **Do NOT edit any PRIOR do-not-edit asset** (Preserved Assets). In-place amendment is authorized
  ONLY for task 325's own committed defs (Naming Decision). Do NOT re-point `kvE2_body`/`bracketEndChar_kvE2`.
- **Do NOT consume `EANegation.lean:1090` or `:1249`** — live `sorry`s.
- **Do NOT use `simp`/`omega`/`aesop` on chain-construction steps.** `by omega` permitted ONLY for
  `Fin`-index typing in signatures. Every chain step follows Cor 5.4 / Prop 3.5 step-by-step with a
  Rabinovich citation (Guard G5).
- **Do NOT leave `sorry` on any live path, including intermediate WIP.** Keep unfinished work
  uncommitted until green.
- **Do NOT pin the provider (Amendment F3):** no `w = e 1` / `x1 = e 0` residual equation; `w` and
  `x1` enter as witness *type* slots. (The self-type FOLDING into `ptX1`/`ptW` is a zone-literal
  fold on the complete 1-type, NOT a provider equation — same mechanism k1v `ptW` uses at :3277.)
- **Do NOT begin soundness/completeness before the NON-VACUITY GATE closes.**

### MUST preserve

- All PRIOR Preserved Assets byte-identical and unreferenced by new work.
- All task-325 SURVIVE assets (`bracketFromLists3`, `k1v_sorted_realization3`, `k1v_bracket_construct3`,
  `bracketFromLists3_extract`, and the task-324 survivors) consumed unchanged.
- Existing scoped `lake build` green — the module compiles after every committed lemma.
- Guards G1-G6 + Corrected Anchor-Cap (source: specs/309.../plans/07_offdiag-fi-chain-plan.md:230-260):
  G1 no arity-1 collapse; G2 no projection-based third-free-anchor tower; G3 real exclusion segments
  (never top/const-multi-zone); G4 witnesses stay bracket witnesses, anchor set fixed at `{x,t}`;
  G5 F_i chains step-by-step, cite Rabinovich at every step, no simp/omega/aesop shortcut (`by omega`
  only for `Fin`-index typing); G6 carrier stays the two-anchor bracket characteristic, fixed
  endpoints, codomain may be witness-growing `VVecEA2`, anchor count never exceeds 2. `x1`/`w` remain
  witness slots (adding their self-zones to the gate does NOT make them anchors — the anchor set is
  still `{x,t}`; a self-zone is a zone-spec value, not an endpoint).
- Successor-parameterized compatibility: `σ : NormalForm sig (j+1) 4`, `σ.2 ∘ nf0_assemble` read at
  gate instance `j=0` (landed `NormalForm sig 1 4`).

### Design decisions are SETTLED (do not re-open without a concrete counterexample)

- **Gate `consistent` set has NINE zones** (7 base + `zAtX1` + `zAtW`). Settled by the machine-verified
  v1 empty-gate blocker and the k1v precedent (:1752/:3632).
- **`ptX1`/`ptW` fold their own witness self-zone 1-type literals.** Settled by the same blocker and
  k1v `ptW` (:3277).
- **Codomain is `VVecEA2`, three per-region segment types, `x1`/`w` interior witness slots** (anchor
  set `{x,t}`). Carried from v1; unchanged.
- **NON-VACUITY GATE precedes soundness/completeness.** Settled by the driven-proof discipline + the
  three-failure postmortem.
- **Amend task 325's own defs in place, same names** (Naming Decision).
- **BOTH directions driven to closed proofs; no deferral, no soundness-only partial, no vacuous close.**

## Goals & Non-Goals

- **Goals**:
  - A corrected carrier `kvE_subBracket2V` with a NINE-zone gate `consistent` set (adds `zAtX1`,
    `zAtW`) and `ptX1`/`ptW` folding their own witness self-zone literals, codomain `VVecEA2`, three
    per-region segment types, disjuncts over `S_XU × S_UW × S_WT` permutations.
  - A committed, machine-checked NON-VACUITY GATE (`kvE_subBracket2V_gate_holds_of_honest` +
    `kvE_subBracket2V_nonvacuous`) proving the gate is satisfiable by an honest σ and the carrier is
    non-empty — closing BEFORE soundness/completeness.
  - `kvE_subBracket2V_sound` RE-DRIVEN **non-vacuously** over the corrected (non-empty) carrier.
  - `kvE_subBracket2V_complete` (the reverse), driven to a closed proof — the direction that failed.
  - Both lemmas sorry-free, axiom-clean, no forbidden tactics, Rabinovich-cited at every chain step,
    successor-parameter-compatible at `j=0`.
- **Non-Goals**:
  - Wiring the carrier into the outer gate (`kvE2_body`/`bracketEndChar_kvE2` re-point) — task 321's
    `/revise 321` work.
  - The depth-`j` fold-engine generalization — only gate instance `j=0` is in scope.
  - Editing/re-deriving any SURVIVE asset (consume verbatim) or any PRIOR do-not-edit asset.
  - Resolving parent task 321 — resumes after this task completes.

## Risks & Mitigations

- **R0 — NON-VACUITY GATE fails to close (CRITICAL; the whole rationale for v2).** If the corrected
  9-zone gate is still unsatisfiable by an honest σ, the entire redesign is invalid. *Mitigation:*
  the 9-zone `consistent` set removes the exact `¬consistent zAtX1`/`zAtW → bits = false` conjunct
  that the removed v1 probe proved contradictory; the k1v gate (:3632) with its one witness self-zone
  is the proven precedent. Phase 1 DRIVES the gate-satisfiability lemma to a closed proof as a hard
  exit criterion. If it does not close, STOP and write a blocker report (do NOT proceed to soundness).
- **R1 — Completeness per-region segment discharge (HIGH; failed on task 324's carrier).** Requires
  every point of region `(x,x1)` be `zXU`-positive there (etc.). *Mitigation:* survivor
  `kvE_subBracket2_complete_extract` (:6683) supplies per-zone monotone witnesses; the SURVIVE
  three-region kit (`k1v_sorted_realization3` :6926, `k1v_bracket_construct3` :7002) selects the
  model-sorted disjunct; the NON-VACUITY GATE (Phase 1) guarantees a non-empty disjuncts list to
  select FROM. Phase 3 DRIVES this closed. Genuine obstruction ⇒ STOP + blocker report (no `sorry`,
  no soundness-only).
- **R2 — Soundness re-derivation over the widened gate (MEDIUM).** `ptX1`/`ptW` now carry extra
  self-zone literals; the RE-DRIVE chain (`kvE_subBracket2V_extract`/`_reaches`/`_fold`/`_sound`,
  :7315-7500) must re-close over the new point-type shapes. *Mitigation:* the SURVIVE
  `bracketFromLists3_extract` (:7230) is unchanged (takes `ptX1`/`ptW` as args); only the
  carrier-destructuring `simp only [kvE_subBracket2V, VVecEA2.holds]` layer re-derives. Mirror k1v
  `hptW` self-zone handling (:3277). Phase 2 pre-authorized to sub-split.
- **R3 — Accidental PRIOR-asset edit / forbidden-tactic slip (MEDIUM).** *Mitigation:* every phase
  runs a `git diff` byte-identical check on the PRIOR do-not-edit ranges (distinct from the
  authorized in-place edits to task 325's own :6728+ block) and a forbidden-tactic grep.
- **R4 — Successor-parameterization drift (LOW; unchanged from v1).** *Mitigation:* Phase 1 keeps the
  successor header with a `j=0` instance check; Phase 4 confirms threading end-to-end.
- **R5 — Axiom leakage (LOW).** *Mitigation:* per-phase `lean_verify`; Phase 4 confirms axiom-clean.

## Implementation Phases

All amended/new code lives in
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` (task 325's own :6728-onward
block). SURVIVE assets and all PRIOR ranges stay byte-identical.

**Scoped verification command (per phase):**
`lake build Theories.Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge`, plus `lean_verify`
(fully-qualified) on each phase's named lemma (axioms ⊆ `{propext, Classical.choice, Quot.sound}`),
plus a forbidden-tactic grep on new chain blocks (`simp`/`omega`/`aesop`; `by omega` only for
`Fin`-index typing) and a PRIOR-range `git diff` byte-identical check.

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 (incl. NON-VACUITY GATE green) |
| 3 | 3 | 1 (incl. NON-VACUITY GATE green) |
| 4 | 4 | 2, 3 |

Phases 2 (soundness) and 3 (completeness) are logically independent — both root at the Phase-1
corrected carrier and rejoin at Phase 4 — but all phases append to a single Lean file; dispatch
serially in order 1,2,3,4 (safe default, H7) OR enforce strict non-overlapping line-range ownership.
**Neither Phase 2 nor Phase 3 may begin until the Phase-1 NON-VACUITY GATE is green.**

### Phase 1: Corrected nine-zone-gate carrier + witness self-type folding + NON-VACUITY GATE [COMPLETED]
- **Goal:** Amend `kvE_subBracket2V` in place so its gate `consistent` set has NINE zones (adds
  `zAtX1`, `zAtW`) and `ptX1`/`ptW` fold their own witness self-zone 1-type literals; then DRIVE the
  mandatory NON-VACUITY GATE to a closed proof. This phase's completion is HARD-GATED on the
  non-vacuity lemma closing.
- **Tasks:**
  - [ ] Add the two witness self-zone specs to `kvE_subBracket2V` (:6779), defeq to the blocker's
        machine-verified values: `zAtX1 := mk4 eqz ltz gtz ltz` (`(F,F)(T,F)(F,T)(T,F)`, `v=x1`) and
        `zAtW := mk4 gtz eqz gtz ltz` (`(F,T)(F,F)(F,T)(T,F)`, `v=w`). Cite Rabinovich Def 3.1
        (md:61-74).
  - [ ] Extend the gate `consistent` set (:6846) from SEVEN to NINE zones:
        `zs = zPastX ∨ zAtX ∨ zXU ∨ zAtX1 ∨ zUW ∨ zAtW ∨ zWT ∨ zAtT ∨ zFutT` (insert each witness
        self-zone adjacent to its region, mirroring k1v's 7-zone ordering :3632 one witness up).
  - [ ] Fold each witness self-zone's 1-type literals into the witness point-types, replacing the
        bare `ptX1 := ⟨charK (nfk_projFresh σ)⟩` (:6840) and `ptW := ⟨charBase (proj 1)⟩` (:6841) with
        complete-type-plus-self-zone-literal folds — the arity-4 analog of k1v `hptW`'s
        `char (nf_y_proj) :: (allTypes.map fun χ => if bits zAtW χ then char χ else (char χ).neg)`
        construction (:3277). `ptX1` folds `zAtX1` literals; `ptW` folds `zAtW` literals. Amendment F3
        preserved: this is a zone-literal fold on the complete 1-type, NOT a `w = e 1` residual.
  - [ ] Re-verify `kvE_subChain2V` (:6880) still elaborates over the amended carrier (structurally
        unchanged; it accessor-projects the same `bracketFromLists3`).
  - [ ] Keep the successor-parameterized header (`σ : NormalForm sig (j+1) 4`, `σ.2 ∘ nf0_assemble`
        at `j=0`); confirm the `j=0` instance elaborates (R4).
  - [ ] **NON-VACUITY GATE (mandatory, hard exit criterion):** DRIVE closed —
        (a) `kvE_subBracket2V_gate_holds_of_honest`: `(∃ x1, nf_eval_nf M 1 4 (Fin.cons x1 [w,x,t]) σ)
        → gate` (the corrected second conjunct discharges because `zAtX1`,`zAtW` ∈ `consistent`; this
        flips the removed v1 `kvE_subBracket2V_gate_unsat_PROBE` from provable-negation to provable);
        (b) `kvE_subBracket2V_nonvacuous`: honest σ ⟹ `(kvE_subBracket2V …).disjuncts ≠ []` and hence
        `.holds` is not definitionally `False` (refutes the removed v1 `_never_holds_PROBE`). Consume
        `kvE_subBracket2_complete_extract` (:6683) / `nf_eval_depth1_fold_iff` (:5187) to supply the
        forced honest bits. Cite Rabinovich Prop 4.2 (md:100-101).
  - [ ] `git diff` confirm all PRIOR do-not-edit ranges byte-identical; confirm the SURVIVE
        task-325 kit (`bracketFromLists3`, `k1v_sorted_realization3`, `k1v_bracket_construct3`,
        `bracketFromLists3_extract`) unedited.
- **Estimated output:** ~200-350 lines (carrier amendment is small; the NON-VACUITY GATE proof is the
  bulk). Bounded unit: corrected carrier + two non-vacuity lemmas.
- **Done when:** the amended `kvE_subBracket2V`/`kvE_subChain2V` elaborate; the `j=0` instance
  compiles; `kvE_subBracket2V_gate_holds_of_honest` AND `kvE_subBracket2V_nonvacuous` close
  sorry-free; scoped `lake build` green; `lean_verify` axiom-clean on the non-vacuity lemmas; PRIOR
  `git diff` clean.
- **Verification:** scoped `lake build` green; `lean_verify` on `kvE_subBracket2V_nonvacuous` and
  `kvE_subBracket2V_gate_holds_of_honest`; forbidden-tactic grep clean; PRIOR-range `git diff` clean;
  NON-VACUITY GATE confirmed green (HARD gate — Phase 2/3 blocked until so).
- **Commit point:** `task 325 phase 1: nine-zone-gate carrier + witness self-type fold + non-vacuity gate`
- **Depends on:** none

### Phase 2: Soundness RE-DRIVEN non-vacuously over the corrected carrier [COMPLETED]
- **Goal:** RE-DRIVE the carrier-binding soundness chain over the corrected (now NON-empty) carrier so
  `kvE_subBracket2V_sound` closes NON-vacuously; confirm the SURVIVE kit is consumed unchanged.
- **Tasks:**
  - [x] **Kit-survival confirmation (first, cheap):** Confirmed `bracketFromLists3`, `k1v_sorted_realization3`,
        `k1v_bracket_construct3`, `bracketFromLists3_extract` take `ptX1`/`ptW`/`segXU`/`segUW`/`segWT`
        as EXPLICIT arguments and conclude over `bracketFromLists3 … .holds` (do NOT bind the carrier
        gate); SURVIVE the Phase-1 amendment byte-identical.
  - [x] RE-DRIVE `kvE_subBracket2V_extract` (:7330), `_reaches_zXU`/`_zUW`/`_zWT` (:7390/7409/7428),
        `_fold_z*` (:7448/7467/7486) over the corrected carrier *(deviation: altered — the RE-DRIVE was
        already performed as Phase 1's fix-forward, commits be865449c/72c34be83; this dispatch VERIFIED
        the chain compiles green, sorry-free, and non-vacuously over the amended nine-zone carrier
        rather than re-editing byte-identical code)*. These `simp only [kvE_subBracket2V, VVecEA2.holds]`
        and destructure a non-empty disjuncts list whose `ptX1`/`ptW` carry the self-zone literals; the
        anchor projection uses `formula_conjList_iff` + `List.mem_cons_self` (k1v `hptW` :3277). Consumes
        the SURVIVE `kvE_sub2_zoneHolds_*` verbatim.
  - [x] RE-DRIVE `kvE_subBracket2V_sound : holds → ∃ x1, nf_eval_nf M 1 4 (Fin.cons x1 [w,x,t]) σ`
        (:7514) — closes NON-vacuously: the hypothesis `.holds` is genuinely inhabitable per Phase-1
        `kvE_subBracket2V_nonvacuous`. Extracts the anchor `a` via `kvE_subBracket2V_extract`, feeds the
        explicit `hgate`, assembles via `nf_eval_depth1_fold_iff`. Rabinovich Cor 5.4 / Prop 3.5 cited.
  - [x] Amendment F3 check: no provider-side pinning; no `w = e 1` / `x1 = e 0` residual equation (grep clean).
  - [x] No `simp`/`omega`/`aesop` on chain steps (`by omega` only for `Fin`-index typing) — grep clean;
        only the plan-authorized destructuring `simp only [kvE_subBracket2V, VVecEA2.holds]` + membership
        bookkeeping present.
- **Estimated output:** ~250-380 lines. **Pre-authorized sub-split** (H8): 2.1 = kit-survival check +
  re-derive `extract`/`_reaches`/`_fold`; 2.2 = re-assemble `kvE_subBracket2V_sound`.
- **Done when:** `kvE_subBracket2V_sound` compiles sorry-free standalone AND non-vacuously (Phase-1
  non-vacuity green); scoped `lake build` green; `lean_verify` axiom-clean.
- **Verification:** scoped `lake build` green; `lean_verify` on `kvE_subBracket2V_sound`;
  forbidden-tactic grep clean; PRIOR-range `git diff` clean; F3 residual-equation grep clean.
- **Commit point:** `task 325 phase 2: soundness re-driven non-vacuously over nine-zone carrier`
- **Depends on:** 1 (NON-VACUITY GATE green)

### Phase 3: Completeness driven closed — disjunct selection + per-region segment discharge [COMPLETED]
- **Goal:** DRIVE the completeness direction (the one that was BLOCKED) to a closed proof over the
  corrected non-empty carrier: prove the gate holds for the honest σ (via Phase-1
  `kvE_subBracket2V_gate_holds_of_honest`), select the model-sorted arrangement disjunct, discharge
  the three per-region segment types, and assemble `kvE_subBracket2V_complete`.
- **Tasks:**
  - [x] Consume the SURVIVE `kvE_subBracket2_complete_extract` (:6683) VERBATIM to extract σ's
        per-zone monotone inner witnesses from an honest `nf_eval_nf M 1 4` realization (carrier-agnostic
        despite its name — Correction 3). Cite Rabinovich Prop 4.2 (md:100-101).
  - [x] Discharge the carrier gate for the honest σ via Phase-1 `kvE_subBracket2V_gate_holds_of_honest`
        (this is precisely the step that was impossible on the v1 7-zone gate). Take the gate-true
        branch to reach the non-empty `flatMap` disjuncts list.
  - [x] Select the model-sorted disjunct via the SURVIVE `k1v_sorted_realization3` (:6926), then build
        the `IntervalPattern.holds`/`VecEA2.holds` data via the SURVIVE `k1v_bracket_construct3` (:7002)
        and discharge `segXU`/`segUW`/`segWT` on each full region — satisfiable because every point of
        region `(x,x1)` is `zXU`-positive there (etc.). Also discharge the folded `ptX1`/`ptW`
        witness-point obligations at the interior witnesses `x1`/`w` (the k1v `ptW`-at-`w`
        discharge one witness up). Cite Rabinovich Lemma 5.3 (md:137-152) per segment/point condition.
  - [x] Assemble `kvE_subBracket2V_complete : (∃ x1, nf_eval_nf M 1 4 (Fin.cons x1 [w,x,t]) σ) →
        holds`, selecting the disjunct via `VVecEA2.holds`'s `∃ vea ∈ disjuncts` (:276) at `(x,t)`.
        Confirm `(sound, complete)` is the arity-4 analog of the k1v pair. *(deviation: altered — the
        `ptX1` head is `charK (nfk_projFresh σ)`, a depth-1 type, so completeness takes an explicit
        `hcharK` charK-realization hypothesis + three σ.1 order bits, the exact mirror of soundness's
        explicit `hgate`; STANDALONE per plan Overview, not wired to the outer gate.)*
  - [x] **Driven-proof gate:** the lemma MUST close sorry-free and NON-vacuously. Genuine obstruction
        ⇒ STOP, no `sorry`, no soundness-only acceptance, write a blocker report.
  - [x] No `simp`/`omega`/`aesop` on chain steps.
- **Estimated output:** ~300-400 lines (heavy construction machinery already SURVIVES in the Phase-2
  kit). **Pre-authorized sub-split** (H8): 3.1 = gate discharge + disjunct selection + per-region
  segment discharge; 3.2 = assemble `kvE_subBracket2V_complete`.
- **Done when:** `kvE_subBracket2V_complete` compiles sorry-free standalone; scoped `lake build`
  green; `lean_verify` axiom-clean.
- **Verification:** scoped `lake build` green; `lean_verify` on `kvE_subBracket2V_complete`;
  forbidden-tactic grep clean; PRIOR-range `git diff` clean.
- **Commit point:** `task 325 phase 3: completeness lemma kvE_subBracket2V_complete closed`
- **Depends on:** 1 (NON-VACUITY GATE green)

### Phase 4: Correctness-pair packaging + successor threading + final verification [NOT STARTED]
- **Goal:** Confirm the full correctness pair is sorry-free, non-vacuous, axiom-clean,
  forbidden-tactic-free, the PRIOR do-not-edit invariant held throughout, and the successor-parameter
  threading is end-to-end compatible at `j=0`.
- **Tasks:**
  - [ ] Full scoped `lake build` green from a clean state.
  - [ ] `lean_verify` on `kvE_subBracket2V_nonvacuous`, `kvE_subBracket2V_sound`, and
        `kvE_subBracket2V_complete`: axioms ⊆ `{propext, Classical.choice, Quot.sound}`.
  - [ ] Confirm NON-VACUITY: re-state (or reference) that `kvE_subBracket2V_nonvacuous` shows the
        carrier is inhabited for an honest σ, so soundness did NOT close vacuously.
  - [ ] `grep`-confirm zero `sorry` on the new live path (including no WIP `sorry`).
  - [ ] Forbidden-tactic grep over ALL new/amended chain blocks (`simp`/`omega`/`aesop`; `by omega`
        only in `Fin`-index typing positions).
  - [ ] `git diff` over all PRIOR do-not-edit ranges: byte-identical, unreferenced by new work
        (task-324 kit ~:6120-6720, k1v templates :2028-2979, task-321 Stage A/B, etc.). Confirm the
        SURVIVE task-325 kit unedited.
  - [ ] Confirm the successor header threads: `σ : NormalForm sig (j+1) 4` instantiates to landed
        `NormalForm sig 1 4` at `j=0` (R4); the carrier converges onto the amended spec (321 §2 :225).
  - [ ] Package a doc-comment lemma bundling `(kvE_subBracket2V_sound, kvE_subBracket2V_complete)` as
        the arity-4 analog of the k1v pair (no new proof obligations).
- **Estimated output:** ~40-90 lines (packaging/doc lemma; no new heavy proofs).
- **Done when:** all checks pass; the deliverable is a green, axiom-clean, NON-VACUOUS arity-4
  correctness pair over the corrected nine-zone `VVecEA2` carrier with BOTH directions driven closed.
- **Verification:** as listed in Tasks.
- **Commit point:** `task 325: complete implementation (nine-zone VVecEA2 arity-4 correctness pair)`
- **Depends on:** 2, 3

**Realistic phase count (adjusted with justification).** The task's suggested skeleton allowed a
separate "P2 kit re-wire (if needed)" phase. This v2 COLLAPSES it: this session verified (grep
:6753-7343) that the three-region construction kit (`bracketFromLists3`, `k1v_sorted_realization3`,
`k1v_bracket_construct3`, `bracketFromLists3_extract`) takes `ptX1`/`ptW`/`segXU`/`segUW`/`segWT` as
EXPLICIT arguments and concludes over `bracketFromLists3 … .holds` — none bind the carrier gate/
`consistent`/`bits`. So the Phase-1 gate widening + point-type fold leaves the kit byte-identical; no
re-wire phase is needed. The kit-survival CONFIRMATION is folded into Phase 2's first (cheap) task.
Net: 4 phases (corrected carrier + non-vacuity gate; soundness re-drive; completeness; packaging).

## Testing & Validation

- [ ] Scoped `lake build` green after EACH committed phase (never commit a red or sorry-carrying state).
- [ ] **NON-VACUITY GATE** green FIRST: `kvE_subBracket2V_gate_holds_of_honest` +
      `kvE_subBracket2V_nonvacuous` close sorry-free, proving the corrected gate is satisfiable by an
      honest σ and the carrier is non-empty — BEFORE soundness/completeness are attempted.
- [ ] Gate `consistent` set has NINE zones (7 base + `zAtX1` + `zAtW`); `ptX1`/`ptW` fold their own
      witness self-zone literals (k1v `ptW` pattern :3277).
- [ ] `lean_verify` axiom check on every new/amended lemma: axioms ⊆ `{propext, Classical.choice, Quot.sound}`.
- [ ] Soundness `kvE_subBracket2V_sound : holds → ∃ x1, nf_eval_nf M 1 4` closes standalone, sorry-free,
      and NON-vacuously (DRIVEN, not type-check; carrier inhabited per non-vacuity).
- [ ] Completeness `kvE_subBracket2V_complete` (reverse) closes standalone, sorry-free (DRIVEN) — the
      direction that was BLOCKED in v1.
- [ ] BOTH directions closed before the construction counts as validated; neither deferred, assumed,
      accepted on the strength of the other, nor closed over an empty carrier.
- [ ] Three per-region segment types `segXU`/`segUW`/`segWT` exclude only their own region's negatives
      (no constant tri-zone `segExcl`).
- [ ] Codomain is `VVecEA2` (the struct); disjuncts over `S_XU × S_UW × S_WT` permutations; anchor set
      fixed at `{x,t}` (G4/Cap; `x1`/`w` are witness slots — self-zones are zone-specs, not anchors).
- [ ] Forbidden-tactic grep clean on all new/amended chain-construction blocks.
- [ ] Amendment F3: no provider-side pinning / residual `w = e 1` / `x1 = e 0` equation (the self-type
      fold is a zone-literal fold on the complete 1-type, not a provider equation).
- [ ] `git diff` confirms all PRIOR do-not-edit ranges byte-identical; SURVIVE task-325 kit unedited.
- [ ] Successor header `σ : NormalForm sig (j+1) 4` threads; `j=0` instance = landed `NormalForm sig 1 4`.

## Artifacts & Outputs

- plans/02_vvecea2-carrier-v2-nine-zone-gate.md (this file); supersedes plans/01_vvecea2-carrier-redesign.md
- Amended/new definitions and lemmas in
  `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean`:
  amended `kvE_subBracket2V` (nine-zone gate + folded `ptX1`/`ptW`), `kvE_subChain2V`;
  new `kvE_subBracket2V_gate_holds_of_honest`, `kvE_subBracket2V_nonvacuous`; re-driven
  `kvE_subBracket2V_extract`/`_reaches_z*`/`_fold_z*`/`kvE_subBracket2V_sound`; new
  `kvE_subBracket2V_complete`. SURVIVE kit (`bracketFromLists3`, `k1v_sorted_realization3`,
  `k1v_bracket_construct3`, `bracketFromLists3_extract`) consumed unchanged.
- summaries/NN_vvecea2-carrier-v2-summary.md (on completion)

## Rollback/Contingency

- **Per-phase rollback:** each phase commits only when green (scoped build + axiom-clean + no sorry +,
  for Phase 1, non-vacuity green). A failed phase leaves the prior green commit intact. If a build goes
  red mid-phase, fix forward — never discard uncommitted changes to reach a passing build. If rollback
  is genuinely required, run `bash .claude/scripts/git-snapshot.sh` first (git-workflow.md
  "No Destructive Git on Uncommitted Work").
- **NON-VACUITY GATE failure (R0):** if the corrected 9-zone gate is still unsatisfiable by an honest
  σ, STOP and write a blocker report; do NOT proceed to a soundness proof that could close vacuously.
- **H8 sub-split valve:** Phases 2, 3 are each pre-authorized to split into two sub-phases (2.1/2.2,
  3.1/3.2) with commit-per-green if a single dispatch overflows ~400 lines.
- **Completeness genuine-obstruction handling (R1):** if Phase 3 hits a genuine obstruction driving
  completeness closed, STOP and write a blocker report. Do NOT place a strategic `sorry` and do NOT
  accept a soundness-only deliverable (that repeats task 324's Phase-6 and task 325 v1 failures).
- **After completion:** resume parent task 321 via `/revise 321` (fold this task's delivered corrected
  VVecEA2 carrier + full soundness/completeness pair into a v4 phase decomposition that re-points
  321's Phase 8 and downstream phases at it), then `/implement 321`.
