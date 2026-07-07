# Implementation Plan: Redesign k=2 Sub-Bracket into a VVecEA2 Arrangement-Disjunction Carrier

- **Task**: 325 - redesign_k2_subbracket_to_vvecea2_arrangementdisjunction
- **Status**: [IMPLEMENTING]
- **Effort**: 12-16 hours
- **Dependencies**: None (standalone; parent task 321 resumes via /revise 321 after completion)
- **Research Inputs**:
  - specs/325_redesign_k2_subbracket_to_vvecea2_arrangementdisjunction/reports/01_adversarial-verification.md (H4-verified PROCEED-TO-PLAN gate; its four precision corrections are BINDING and folded in below)
  - specs/324_redesign_k2_subbracket_arity4_correctness_pair/reports/02_phase6-blocker-research.md (machine-grounded blocker; Q3 corrected target definition + preserved-asset accounting)
  - specs/324_redesign_k2_subbracket_arity4_correctness_pair/reports/03_spawn-analysis.md (spawn decomposition rationale)
  - specs/321.../reports/01_blocker-research-successor-k.md Section 2 (successor `j+1` amended design spec, :56/:225)
- **Artifacts**: plans/01_vvecea2-carrier-redesign.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/plan-format-enforcement.md
  - .claude/rules/state-management.md
  - .claude/rules/git-workflow.md
- **Type**: lean4

## Overview

Task 324's Phase 6 is machine-refuted: the landed arity-4 carrier `kvE_subBracket2`
(`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean:6120`) returns a single
`Σ m, BracketFormula (m+1)` with a **constant tri-zone** `segmentTypes ≡ segExcl` (:6159) and a
**fixed filter-order** `pointTypes` (:6154). Adversarially re-verified against source (report 01),
its completeness converse `(∃ x1, nf_eval_nf M 1 4 [x1,w,x,t] σ) → (kvE_subBracket2 …).2.holds` is a
**false ∀-M statement** for two independent, machine-confirmed reasons (constant multi-zone segment
type vs per-point `IntervalPattern.holds`; fixed filter order vs positional monotone witnesses). No
rescue exists on that carrier; the fix is a **codomain change**.

This task delivers, **standalone against `nf_eval_nf M 1 4` and NOT wired into the outer gate**, a
corrected carrier `kvE_subBracket2V`/`kvE_subChain2V` (names at implementer discretion) whose
codomain is `VVecEA2` (a finite arrangement disjunction, `VecEAFormula.lean:271`) with **three
per-region segment types** (`segXU`/`segUW`/`segWT`) and **two interior witness slots** (`x1`, `w`),
plus a **freshly re-derived, machine-driven-through soundness AND completeness pair** over it — the
arity-4 analog of the proven `bracketEndChar_k1v_sound` (:2338) / `bracketEndChar_k1v_complete`
(:2979), lifted from k1v's two-region arrangement to a three-region one. Definition of done: BOTH
`kvE_subBracket2V_sound` and `kvE_subBracket2V_complete` compile **sorry-free**, are **axiom-clean**
(`propext`, `Classical.choice`, `Quot.sound` only), use no forbidden tactics, and the carrier's
per-region segments + disjunct arrangement are validated by **driving both directions to closed
proofs** (not type-check/probe).

### DRIVEN-PROOF VALIDATION DISCIPLINE (mandatory, binding — carried forward verbatim)

Do NOT accept the redesigned construction on type-check/probe grounds. Two consecutive prior
constructions have now failed EXACTLY that way — `kvE_subBracket` (task 321 Phase 8: type-checked
and probed clean, but its upward-only chain anchored at an interior point could not reach the `zXU`
zone below it) and `kvE_subBracket2` (task 324 Phase 6: type-checked and probed clean at soundness,
but the completeness converse is a false ∀-M statement). The new construction MUST be validated by
actually driving BOTH the soundness direction AND the completeness direction through to a closed,
sorry-free proof before the construction counts as validated — **neither direction may be deferred,
assumed, or accepted on the strength of the other having closed.** There is no pre-authorized
soundness-only partial here (unlike task 324's R2 fallback): the VVecEA2 codomain is precisely the
shape research proved makes completeness provable, so completeness is expected to close. If it hits a
genuine obstruction, STOP and write a blocker report — do NOT place a `sorry` and do NOT accept a
soundness-only deliverable.

### Codomain precision (adversarial-verification Correction 1 — BINDING)

The codomain is `VVecEA2` — a **structure** wrapping `disjuncts : List (Σ n, VecEA2 n)`
(`VecEAFormula.lean:271-273`); each *disjunct* is a `Σ n, VecEA2 n` (:252). Do NOT state the codomain
as the bare `Σ n, VecEA2 n` disjunct type. The redesign returns a `VVecEA2` **directly given `σ`**
(exactly as `kvE_subBracket2` returned its `Σ m, BracketFormula` directly given `σ`), and disjuncts
are selected in completeness via `VVecEA2.holds`'s `∃ vea ∈ disjuncts, vea.2.holds M atomMap x t`
(:276) at the fixed endpoints `(x,t)`. Confirmed structurally against `bracketEndChar_k1v` :1940 /
:2016-2018.

### Preserved Assets

All landed work below stays **byte-identical and unreferenced by new work** (do-not-edit list,
verbatim from the task description). The new-definitions-only exception (authorized for THIS task
only) permits adding new, separately-named definitions; originals are never edited in place, and
`kvE2_body`/`bracketEndChar_kvE2` are NOT re-pointed (that is task 321's future /revise work).

| Component | File / Location | Status | Verified |
|-----------|-----------------|--------|----------|
| Task-324 landed carrier `kvE_subBracket2` / `kvE_subChain2` | NfMultiAnchorBridge.lean:6120 / :6166 | [COMPLETED] byte-identical; REPLACED by new `…V` defs | report 01 (2026-07-07) |
| Task-324 zone/reach/sound/extract kit (full ~:6120-6720 range) | :6200-6720 | [COMPLETED] byte-identical | report 01 |
| k1v correctness templates `bracketEndChar_k1v_sound` / `_complete` | :2338 / :2979 | [COMPLETED] consume as template, do not rebuild | report 01 |
| k1v helper kit (`k1v_bracket_extract` :2150, `k1v_sorted_insert` :2751, `k1v_sorted_realization` :2797, `k1v_bracket_construct` :2838; `bracketFromLists` :1896) | grep'd anchors (Correction 2) | [COMPLETED] consume, do not rebuild | report 01 |
| Task-321 Stage A/B (`kvE_subFoldBits`, `kvE_subInteriorZones`, `kvE_subBracket`, `kvE_subChain`, `kvE_subBracket_implies_subChain`, `kvE2_body` + gate-fail, `bracketEndChar_kvE2` + `two_eq`, Stage-B discrimination) | NfMultiAnchorBridge.lean | [COMPLETED] byte-identical; do NOT re-point | task description |
| `BracketCarrierCorrectVPrior`, `ExistProviders`, task-310/311 material, task-320 probes | NfMultiAnchorBridge.lean | [COMPLETED] byte-identical | task description |

**FORBIDDEN to consume**: `EANegation.lean:1090` and `:1249` (uniform-backward variants) — both are
machine-confirmed live `sorry`s; consuming either imports proof debt onto this task's live path.

#### Preserved-asset fate under redesign (SURVIVE / RE-DERIVE / REPLACED — report 02 accounting)

**SURVIVE NEAR-VERBATIM** (reusable raw material — consume/adapt, do NOT rebuild; the
`subBracket2`/`sub2` in these names is *misleading*, the statements are carrier-agnostic —
Correction 3):

| Asset | Location | Why it survives |
|-------|----------|-----------------|
| `kvE_sub2_zoneHolds_cons_iff`, `_zXU`/`_zUW`/`_zWT` | :6615 / :6644 / :6655 / :6666 | pure `zoneHolds`↔inequalities over env `[x1,w,x,t]`; no reference to the old carrier |
| `kvE_subBracket2_complete_extract` | :6683 | reads `nf_eval_nf M 1 4` only; supplies the per-zone monotone witnesses the new disjunct closure consumes; statement never mentions the bracket carrier |
| `kvE_sub2_zXU`/`zUW`/`zWT` zone specs | :6200 / :6204 / :6208 | fold-bit zone specs, carrier-independent |

**RE-DERIVED** (proof shape survives but statement changes — restated over the VVecEA2 disjunct
`.holds` by destructuring the disjunction FIRST, exactly as `bracketEndChar_k1v_sound` does via
`simp only [bracketEndChar_k1v, VVecEA2.holds]` at :2352):

| Asset | Location | Re-derivation note |
|-------|----------|--------------------|
| `kvE_subBracket2_extract` | :6233 | restate over new carrier's disjunct `.holds` |
| `kvE_subBracket2_reaches_zXU/_zUW/_zWT` | :6327 / :6347 / :6367 | depend on extract shape |
| `kvE_subBracket2_fold_zXU/_zUW/_zWT` | :6434 / :6455 / :6476 | depend on `_reaches_z*` |
| `kvE_subBracket2_sound` | :6530 | binds the OLD single bracket; this task owns a fresh sound/complete pair over the new carrier |

**REPLACED** (new separately-named defs; originals stay byte-identical and unreferenced):
`kvE_subBracket2` :6120, `kvE_subChain2` :6166 → `kvE_subBracket2V` / `kvE_subChain2V`.

### Source-to-Implementation Mapping (H3: Tier 1 literature + Tier 3 landed assets)

Every load-bearing chain step cites Rabinovich per Guard G5. Literature source:
`~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`.

| Load-bearing decision | Source (Tier 1 / Tier 3) | Consumed asset / citation |
|-----------------------|--------------------------|---------------------------|
| Codomain = `VVecEA2` arrangement disjunction (not single bracket) | Rabinovich Lemma 5.3 base-case negation → V-∃∀ (md:137-152) + report 321 §2 :225 amended spec | `VVecEA2` struct VecEAFormula:271, `.holds` :276; `bracketEndChar_k1v` :1940 (structural mirror) |
| Three per-region segment types `segXU`/`segUW`/`segWT` (not constant `segExcl`) | Rabinovich Cor 5.4 per-β_i Until-chaining, per-segment (md:154-157) | arity-4 lift of `bracketFromLists.segmentTypes` :1902 (2-way `if` → 3-way `if`) |
| Two interior witness slots `x1`, `w` between three regions `(x,x1)`/`(x1,w)`/`(w,t)` | Rabinovich Def 3.1 strictly-increasing witnesses (md:61-74) | env `[x1,w,x,t]`; layout `zXU-arr ++ [x1-slot] ++ zUW-arr ++ [w-slot] ++ zWT-arr` |
| Disjuncts = `S_XU.permutations × S_UW.permutations × S_WT.permutations` | Rabinovich Lemma 5.3 case disjunction (md:137-152) | mirror of k1v `S_L.permutations.flatMap … S_R.permutations.map` :2016-2017; gate-fail `disjuncts := []` :2018 |
| Soundness read-back (disjunct `.holds` → reconstruct `nf_eval_nf`) | k1v soundness template | destructure via `VVecEA2.holds` :2352; `k1v_bracket_extract` :2150; survivors `kvE_sub2_zoneHolds_*` :6615 |
| Completeness disjunct selection + per-region segment discharge | Rabinovich Lemma 5.3 (md:137-152), Lemma 5.1 (md:134-135), Prop 4.2 (md:100-101) | three-region lift of `k1v_sorted_realization` :2797 + `k1v_bracket_construct` :2838; survivor `kvE_subBracket2_complete_extract` :6683 |
| No provider pinning (F3): `w` is a witness *type* slot | report 321 §2 (F3) | `charBase` of `w`'s projection; realized by 1-type uniqueness, no `w = e 1` residual |
| Successor-parameterized read `σ : NormalForm sig (j+1) 4` | report 321 §2 :56/:225 (Correction 4) | landed `NormalForm sig 1 4` = the `j=0` instance; `σ.2 ∘ nf0_assemble` read |

## Postmortem Constraints

Binding rules for all implementation dispatches. Derived from the two prior machine-grounded
failures and the task's binding constraints.

**The two prior failures and how each phase avoids repeating them:**

- **Failure A — `kvE_subBracket` (task 321 Phase 8).** An upward-only `Until` chain anchored at the
  interior σ-witness slot `u` type-checked and probed clean, but structurally could not express a
  witness in `zXU` lying *below* the anchor — a latent **soundness** gap found only when the proof
  was driven. *Avoided here:* the carrier anchors at fixed endpoints `{x,t}` with `x1`/`w` as
  interior witness slots (not anchors), and soundness is DRIVEN to a closed proof over the new
  carrier (Phase 3), never accepted on type-check.
- **Failure B — `kvE_subBracket2` (task 324 Phase 6).** A single `BracketFormula` with a constant
  tri-zone `segExcl` and a fixed filter-order `pointTypes` type-checked and probed clean at
  soundness, but its **completeness** converse is a false ∀-M statement (constant multi-zone segment
  vs per-point `IntervalPattern.holds`; fixed filter order vs positional monotone witnesses).
  *Avoided here:* the `VVecEA2` arrangement-disjunction codomain with three **per-region** segment
  types (`segXU`/`segUW`/`segWT`) is exactly the k1v mechanism that makes completeness provable, and
  completeness is DRIVEN to a closed proof (Phase 4).

**Do NOT**:
- **Do NOT accept a type-check/probe-clean construction as validated.** Both prior failures passed
  type-check and probes. Validation = BOTH directions driven to closed, sorry-free proofs (driven-
  proof discipline).
- **Do NOT reuse a constant multi-zone segment type.** `segmentTypes := fun _ => <multi-zone conj>`
  is the exact Failure-B defect. Each segment type must exclude only ITS OWN region's negatives, so
  every point of that region is genuinely zone-positive there.
- **Do NOT emit a single `BracketFormula` codomain.** The codomain is `VVecEA2` (disjunction over
  arrangements); a single bracket cannot realize the Lemma-5.3 V-∃∀ structure.
- **Do NOT be misled by preserved-asset names** (Correction 3): `kvE_subBracket2_complete_extract`
  and `kvE_sub2_zoneHolds_*` survive near-verbatim despite `subBracket2`/`sub2` in their names.
  Consume them directly; do NOT rebuild and do NOT assume a carrier dependency.
- **Do NOT edit any do-not-edit asset** (see Preserved Assets). Add separately-named defs only;
  originals stay byte-identical. Do NOT re-point `kvE2_body`/`bracketEndChar_kvE2`.
- **Do NOT consume `EANegation.lean:1090` or `:1249`** — both are live `sorry`s.
- **Do NOT use `simp`/`omega`/`aesop` on chain-construction steps.** `by omega` is permitted ONLY
  for `Fin`-index typing in signatures. Every chain step follows Cor 5.4 / Prop 3.5 step-by-step
  with a Rabinovich citation (Guard G5).
- **Do NOT leave `sorry` on any live path, including intermediate WIP.** Keep unfinished work
  uncommitted until green.
- **Do NOT pin the provider (Amendment F3):** no `w = e 1` / `x1 = e 0` residual equation; `w`
  enters as a witness *type* slot.
- **Do NOT defer either direction.** No soundness-only partial (that repeats task 324); no
  completeness strategic `sorry`.

**MUST preserve**:
- All Preserved Assets byte-identical and unreferenced by new work.
- Existing scoped `lake build` green — the module compiles after every committed lemma.
- Guards G1-G6 + Corrected Anchor-Cap: anchor count ≤ 2, fixed endpoints `{x,t}`; codomain may be
  witness-growing `VVecEA2` but anchor count never exceeds 2 (`x1`/`w` are witness slots, not
  anchors). Source: specs/309.../plans/07_offdiag-fi-chain-plan.md:230-260.
- Successor-parameterized compatibility: `σ : NormalForm sig (j+1) 4`, `σ.2 ∘ nf0_assemble` read at
  gate instance `j=0` (landed `NormalForm sig 1 4`).

**Design decisions are SETTLED** (do not re-open without a concrete counterexample):
- **The codomain must be `VVecEA2`, not `Σ m, BracketFormula`.** Settled by the machine-confirmed
  false-∀-M refutation of the single-bracket carrier (report 02 Q1/Q2, report 01 adversarial gate).
- **Three per-region segment types, not a constant tri-zone `segExcl`.** Settled by the same
  refutation (Obstruction 1) and by the proven `bracketFromLists.segmentTypes` per-side shape :1902.
- **`x1` and `w` are interior witness slots, not anchors** — anchor set stays `{x,t}` (G4/Cap).
- **BOTH directions must be driven to closed proofs; no deferral, no soundness-only partial.**
  Settled by the driven-proof discipline (binding).
- **New, separately-named additive definitions** (`…V` suffix); byte-identical originals; no
  in-place edit path.

## Goals & Non-Goals

- **Goals**:
  - A corrected additive carrier `kvE_subBracket2V`/`kvE_subChain2V` with codomain `VVecEA2`, three
    per-region segment types `segXU`/`segUW`/`segWT`, two interior witness slots `x1`/`w`, and
    disjuncts over `S_XU.permutations × S_UW.permutations × S_WT.permutations`.
  - A three-region lift of the k1v construction kit (`sorted_realization`/`bracket_construct`).
  - A soundness lemma `kvE_subBracket2V_sound : holds → ∃ x1, nf_eval_nf M 1 4 (Fin.cons x1 [w,x,t]) σ`,
    GENUINELY re-derived over the new carrier (the landed `kvE_subBracket2_sound` binds the old
    bracket and does not transfer).
  - A completeness lemma `kvE_subBracket2V_complete` (the reverse), the arity-4 analog of
    `bracketEndChar_k1v_complete` :2979.
  - Both lemmas sorry-free, axiom-clean, no forbidden tactics, Rabinovich-cited at every chain step,
    successor-parameter-compatible at `j=0`.
- **Non-Goals**:
  - Wiring the new carrier into the outer gate (`kvE2_body`/`bracketEndChar_kvE2` re-point) — task
    321's /revise work.
  - The depth-`j` fold-engine generalization — only the gate instance `j=0` (landed `nf0_assemble`)
    is in scope; the successor header stays *compatible*, not fully general.
  - Editing or re-deriving any Preserved Asset marked SURVIVE (consume verbatim).
  - Resolving parent task 321 — resumes after this task completes.

## Risks & Mitigations

- **R1 — Completeness per-region segment discharge (HIGH; the direction that failed on the old
  carrier).** Discharging `segXU`/`segUW`/`segWT` at every point of each open region requires that
  every point of region `(x,x1)` be `zXU`-positive there (and likewise per region) — the exact
  property the old constant `segExcl` violated. *Mitigation:* the survivor
  `kvE_subBracket2_complete_extract` (:6683) supplies the per-zone monotone witnesses; the three-way
  arrangement disjunction lets completeness select the model-sorted disjunct (three-region
  `sorted_realization`, Phase 2). Phase 4 DRIVES this to a closed proof — no acceptance on type-check.
  If a genuine obstruction appears, STOP and write a blocker report (no `sorry`, no soundness-only
  partial).
- **R2 — Three-region kit lift larger than k1v's two-region kit (MEDIUM; H8 sizing).** The
  `sorted_realization`/`bracket_construct` lift from two regions to three is strictly more machinery
  than k1v had. *Mitigation:* Phase 2 is pre-authorized to split into sub-phases 2.1
  (`sorted_insert`/`sorted_realization` lift) and 2.2 (`bracket_construct` lift) if a single dispatch
  overflows ~400 lines; commit-per-green per lemma.
- **R3 — Soundness re-derivation drift (MEDIUM).** The RE-DERIVED soundness building blocks
  (`extract`, `_reaches_z*`, `_fold_z*`) must be restated over the disjunct `.holds` by destructuring
  the disjunction FIRST. *Mitigation:* mirror `bracketEndChar_k1v_sound`'s `simp only [carrier,
  VVecEA2.holds]` at :2352; consume the SURVIVE `kvE_sub2_zoneHolds_*` lemmas verbatim. Phase 3
  pre-authorized to split 3.1 (re-derive building blocks) / 3.2 (assemble `_sound`).
- **R4 — Successor-parameterization drift (MEDIUM).** The carrier must read `σ : NormalForm sig
  (j+1) 4` and instantiate to the landed `NormalForm sig 1 4` at `j=0`. *Mitigation:* Phase 1
  includes the successor header with a `j=0` instance check as an exit criterion; Phase 5 confirms
  the threading end-to-end.
- **R5 — Accidental Preserved-Asset edit / forbidden-tactic slip (MEDIUM).** *Mitigation:* every
  phase runs a `git diff` byte-identical check on the do-not-edit ranges and a forbidden-tactic grep
  on new chain blocks; Phase 5 re-runs both globally.
- **R6 — Axiom leakage (LOW).** *Mitigation:* per-phase `lean_verify` axiom check; Phase 5 confirms
  the pair is axiom-clean (`propext`, `Classical.choice`, `Quot.sound` only).

## Implementation Phases

All new code is appended to
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` (same module). Suggested new
names (implementer discretion): `kvE_subBracket2V`, `kvE_subChain2V`, `segXU`/`segUW`/`segWT`, the
three-region `…_sorted_realization2`/`…_bracket_construct2` lift, `kvE_subBracket2V_sound`,
`kvE_subBracket2V_complete`.

**Scoped verification command (per phase):**
`lake build Theories.Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge`, plus `lean_verify`
(fully-qualified) on each phase's named lemma (axioms ⊆ `{propext, Classical.choice, Quot.sound}`),
plus a forbidden-tactic grep on new chain blocks (`simp`/`omega`/`aesop`; `by omega` only for
`Fin`-index typing) and a do-not-edit `git diff` byte-identical check.

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2 |
| 4 | 5 | 3, 4 |

Phases 2 (completeness construction kit) and 3 (soundness) are logically independent — both root at
the Phase 1 carrier and rejoin at Phase 5 — but **all phases append to a single Lean file**; to avoid
territory conflicts (H7), dispatch serially in order 1,2,3,4,5 (the safe default) OR enforce strict
append-only, non-overlapping line-range ownership. The wave table documents true logical parallelism;
sequential execution is recommended.

### Phase 1: VVecEA2 carrier `kvE_subBracket2V` + three per-region segment types + gate [COMPLETED]
- **Goal:** Add the additive `VVecEA2`-codomain carrier with three per-region segment types, two
  interior witness slots, the three-way arrangement disjunction, the empty-disjunction gate-fail
  branch, and the successor-parameterized header compatible at `j=0`. No proofs yet — this phase is
  the definitional foundation.
- **Tasks:**
  - [x] Define `segXU`/`segUW`/`segWT : TemporalPred`, each excluding ONLY its own region's negatives
        (`segXU` excludes `zXU`-negatives on `(x,x1)`; `segUW` `zUW`-negatives on `(x1,w)`; `segWT`
        `zWT`-negatives on `(w,t)`) — the arity-4 lift of `bracketFromLists.segmentTypes` :1902 from a
        2-way to a 3-way `if` keyed on the two interior anchor positions. Cite Rabinovich Cor 5.4
        (md:154-157). NOT a constant tri-zone `segExcl`.
  - [x] Define `kvE_subBracket2V : … → VVecEA2` (the struct, `VecEAFormula.lean:271` — NOT the bare
        `Σ n, VecEA2 n`), with per-disjunct point-type layout
        `zXU-arrangement ++ [x1-slot] ++ zUW-arrangement ++ [w-slot] ++ zWT-arrangement`; disjuncts
        `= S_XU.permutations.flatMap (fun lXU => S_UW.permutations.flatMap (fun lUW =>
        S_WT.permutations.map (fun lWT => mkDisjunct lXU lUW lWT)))` where
        `S_z = allTypes.filter (fun χ => b z χ)`; gate-failure branch `{ disjuncts := [] }`. Mirror
        `bracketEndChar_k1v` :2016-2018 one region up. `x1`/`w` are witness slots (anchor count stays
        2; G4/Cap). No provider pinning (F3): `w` is a `charBase`-of-projection witness *type* slot.
  - [x] Define `kvE_subChain2V` as the corresponding chain accessor over the new carrier (analog of
        `kvE_subChain2` :6166, adapted to the `VVecEA2` disjunct shape).
  - [x] Provide the successor-parameterized header (`σ : NormalForm sig (j+1) 4`), read via
        `σ.2 ∘ nf0_assemble` at gate instance `j=0` (landed `NormalForm sig 1 4`). Confirm the `j=0`
        instance elaborates (R4 exit criterion).
  - [x] `git diff` confirm all Preserved-Asset ranges byte-identical.
- **Estimated output:** ~200-320 lines. Bounded unit: one carrier def + three segment types + gate +
  successor header; all definitional, elaborates or does not.
- **Done when:** `segXU`/`segUW`/`segWT`, `kvE_subBracket2V`, `kvE_subChain2V`, and the successor
  header all elaborate with zero diagnostics; the `j=0` instance check compiles; scoped `lake build`
  green; `git diff` shows no edits to do-not-edit ranges.
- **Verification:** scoped `lake build` green; `lean_verify` on `kvE_subBracket2V`/`kvE_subChain2V`;
  forbidden-tactic grep clean; do-not-edit `git diff` clean.
- **Commit point:** `task 325 phase 1: VVecEA2 carrier kvE_subBracket2V + per-region segments + gate`
- **Depends on:** none

### Phase 2: Three-region construction kit lift (`sorted_realization` / `bracket_construct`) [COMPLETED]
- **Goal:** Lift the k1v two-region construction kit (`k1v_sorted_insert` :2751,
  `k1v_sorted_realization` :2797, `k1v_bracket_construct` :2838) one arity up to a **three-region**
  arrangement — the reusable machinery the completeness direction (Phase 4) consumes.
- **Tasks:**
  - [x] Lift `k1v_sorted_insert` / `k1v_sorted_realization` (:2751 / :2797) to sort realized points
        into a three-region arrangement `(S_XU × S_UW × S_WT)` permutation and select the matching
        disjunct. Cite Rabinovich Lemma 5.1 (md:134-135) at the insertion-induction step.
        *(landed: `k1v_sorted_realization3`; commit 2.1 d1f5fc359)*
  - [x] Lift `k1v_bracket_construct` (:2838) to build the three-region `IntervalPattern`/`VecEA2`
        data (monotone enumeration + per-region segment obligations) from sorted realized points. Cite
        Rabinovich Lemma 5.3 (md:137-152). *(landed: `k1v_bracket_construct3`)*
  - [x] Consume `existsBounded_right` (VecEAClosure:265) as a construction primitive; do not rebuild.
        *(deviation: `k1v_sorted_realization`/`k1v_sorted_insert` templates already encapsulate the
        `existsBounded_right` `n+1`-append pattern; consumed transitively via those, not directly.)*
  - [x] No `simp`/`omega`/`aesop` on chain-construction steps. *(no F_i chain steps arise in either
        lemma — both are pure list/interval index bookkeeping mirroring the landed k1v template, whose
        `simp only`/`omega` uses are structural index/length arithmetic only, not chain shortcuts.)*
- **Estimated output:** ~250-400 lines. Bounded unit: the three-region kit lemmas. **Pre-authorized
  sub-split** (H8): 2.1 = `sorted_insert`/`sorted_realization` lift; 2.2 = `bracket_construct` lift,
  each committed green independently if a single dispatch overflows ~400 lines.
- **Done when:** the three-region `sorted_realization`-lift and `bracket_construct`-lift lemmas
  compile sorry-free; scoped `lake build` green; `lean_verify` axiom-clean on each.
- **Verification:** scoped `lake build` green; `lean_verify` on each new kit lemma; forbidden-tactic
  grep clean; do-not-edit `git diff` clean.
- **Commit point:** `task 325 phase 2: three-region sorted_realization/bracket_construct kit lift`
- **Depends on:** 1

### Phase 3: Soundness over the disjunction (`kvE_subBracket2V_sound`) [COMPLETED]
- **Goal:** RE-DERIVE the soundness building blocks over the new carrier's disjunct `.holds`
  (destructuring the disjunction FIRST) and assemble the standalone soundness lemma against
  `nf_eval_nf M 1 4`.
- **Tasks:**
  - [x] Re-derive `kvE_subBracket2V_extract` / `_reaches_zXU`/`_zUW`/`_zWT` / `_fold_z*` (the RE-DERIVE
        set — proof shapes at :6233/:6327/:6434 survive; statements change) restated over the disjunct
        `.holds`. Destructure via `simp only [kvE_subBracket2V, VVecEA2.holds]` exactly as
        `bracketEndChar_k1v_sound` does at :2352. Consume the SURVIVE `kvE_sub2_zoneHolds_cons_iff`
        (:6615) and `_zXU`/`_zUW`/`_zWT` (:6644-6666) VERBATIM (do not rebuild — Correction 3).
        *(deviation: added a factored helper `bracketFromLists3_extract` doing the three-region
        monotone point-type extraction with the lists as explicit args — avoids simp-inlined-lambda
        `set`-fold fragility; `kvE_subBracket2V_extract` destructures the disjunction and calls it,
        mirroring how `bracketEndChar_k1v_sound` calls `k1v_bracket_extract`. The SURVIVE
        `kvE_sub2_zoneHolds_*` lemmas are consumed transitively by `_sound`'s zone-matching, which
        reuses the old `kvE_subBracket2_sound` env-`[a,w,x,t]` `zoneHolds` reconstruction verbatim.)*
  - [x] Assemble `kvE_subBracket2V_sound : holds → ∃ x1, nf_eval_nf M 1 4 (Fin.cons x1 [w,x,t]) σ`,
        reusing the :2338 template shape (`k1v_bracket_extract` :2150 one arity up). Cite Rabinovich
        Cor 5.4 / Prop 3.5 at each chain step. *(landed sorry-free, axiom-clean.)*
  - [x] Amendment F3 check: no provider-side pinning; no `w = e 1` / `x1 = e 0` residual equation.
        *(the anchor `a` is the bracket's own `ptX1` witness fed to `hgate`; no residual equation.)*
  - [x] No `simp`/`omega`/`aesop` on chain steps (`by omega` only for `Fin`-index typing).
        *(all `simp only` uses are definitional unfolds / list-index bookkeeping identical to the
        landed k1v + old-kvE kits; `omega` only for `Fin`-index bounds.)*
- **Estimated output:** ~250-380 lines. Bounded unit: the re-derived building blocks + `_sound`.
  **Pre-authorized sub-split** (H8): 3.1 = re-derive `extract`/`_reaches_z*`/`_fold_z*`; 3.2 =
  assemble `kvE_subBracket2V_sound`.
- **Done when:** `kvE_subBracket2V_sound` compiles sorry-free standalone; scoped `lake build` green;
  `lean_verify` axiom-clean.
- **Verification:** scoped `lake build` green; `lean_verify` on `kvE_subBracket2V_sound`;
  forbidden-tactic grep clean; do-not-edit `git diff` clean; F3 residual-equation grep clean.
- **Commit point:** `task 325 phase 3: soundness lemma kvE_subBracket2V_sound closed`
- **Depends on:** 1

### Phase 4: Completeness — disjunct selection + per-region segment discharge (`kvE_subBracket2V_complete`) [BLOCKED]

**BLOCKER** (Phase 4) — genuine mathematical obstruction in the LANDED Phase-1 carrier
`kvE_subBracket2V` (NfMultiAnchorBridge.lean:6779), which NEW-DEFINITIONS-ONLY forbids editing.
Machine-verified (two probes built green over the actual carrier; see the handoff `blockers`).

- **What failed:** the completeness conclusion `(kvE_subBracket2V (nf_depth0_char_formula atomMap
  h_surj) charK σ).holds M atomMap x t` is DIRECTLY FALSE for every honest realization, so
  `kvE_subBracket2V_complete : (∃ x1, nf_eval_nf M 1 4 [x1,w,x,t] σ) → …holds…` is unprovable (true
  hypothesis, refutable conclusion). Proven by `kvE_subBracket2V_never_holds_PROBE` (compiled green).
- **Root cause:** the carrier's gate `consistent` set (:6848-6849) has only SEVEN zones —
  `zPastX, zAtX, zXU, zUW, zWT, zAtT, zFutT` — and OMITS the two interior WITNESS SELF-ZONES
  `zAtX1` (v = x1, spec `(F,F)(T,F)(F,T)(T,F)`) and `zAtW` (v = w, spec `(F,T)(F,F)(F,T)(T,F)`).
  For any honest `σ`, the anchor `x1` realizes its own complete 1-type `χ0` at `zAtX1`
  (`nf_eval_depth1_fold_iff` forces `σ.2 (nf0_assemble zAtX1 χ0 σ.1) = true`); likewise `w` at
  `zAtW`. But the gate's second conjunct `∀ zs χ, ¬consistent zs → σ.2 (nf0_assemble zs χ σ.1) =
  false` then demands that same bit be `false`. Contradiction ⇒ gate false ⇒ carrier takes the
  `disjuncts := []` branch ⇒ `.holds` is `False`. Proven by `kvE_subBracket2V_gate_unsat_PROBE`.
- **Why soundness passed anyway:** `kvE_subBracket2V_sound` (:7488) has `.holds` as its HYPOTHESIS,
  so an always-`False` carrier makes it vacuously discharged — the empty-list case is closed by
  `simp at hmem` inside `kvE_subBracket2V_extract` (:7331). Soundness closing did NOT vouch for a
  non-empty carrier (as the dispatch's DRIVEN-PROOF discipline warned). This is the SAME failure
  class as task 324 Phase 6 (soundness holds vacuously; completeness a false ∀-M statement).
- **Contrast with the k1v template:** `bracketEndChar_k1v`'s `consistent` set INCLUDES the single
  witness self-zone `zAtW` (bracketEndChar_k1v_complete `hgate` :3090), and `ptW` folds the `zAtW`
  literals (`hptW` :3277). The 3-region redesign dropped BOTH witness self-zones from the gate and
  did not fold their self-types into `ptX1`/`ptW` (`ptX1 = ⟨charK (nfk_projFresh σ)⟩` :6840;
  `ptW = ⟨charBase (proj 1)⟩` :6841 — neither carries the zAtX1/zAtW literals).
- **What is needed (out of scope for Phase 4):** a Phase-1 carrier CORRECTION (new-defs `kvE_…V2`):
  extend `consistent` to NINE zones (add `zAtX1`, `zAtW`) and fold each witness self-zone's 1-type
  literals into `ptX1` / `ptW` respectively (arity-4 analog of k1v's `ptW` zAtW-folding). Then
  re-derive Phase-3 soundness AND Phase-4 completeness over the corrected carrier. This requires
  revising the plan (a v2 Phase 1) and re-doing Phases 1-4; it cannot be done under Phase-4's
  new-definitions-only-append constraint against the existing `kvE_subBracket2V`.
- **Prohibited (honored):** no `sorry` placed; no vacuous `def X := True`; no soundness-only
  acceptance; the landed Phase-1/2/3 assets left byte-identical (working tree byte-identical to
  commit be9f35965 for NfMultiAnchorBridge.lean).
- **Goal:** DRIVE the completeness direction (the one that failed on the old carrier) to a closed
  proof: select the model-sorted arrangement disjunct, discharge the three per-region segment types,
  and assemble the standalone completeness lemma — the arity-4 analog of `bracketEndChar_k1v_complete`
  :2979.
- **Tasks:**
  - [ ] Consume the SURVIVE `kvE_subBracket2_complete_extract` (:6683) VERBATIM to extract σ's
        per-zone monotone inner witnesses from an honest `nf_eval_nf M 1 4` realization (Correction 3:
        carrier-agnostic despite its name). Cite Rabinovich Prop 4.2 (md:100-101).
  - [ ] Select the model-sorted disjunct via the Phase-2 three-region `sorted_realization` lift, then
        discharge `segXU`/`segUW`/`segWT` on each full region — satisfiable because every point of
        region `(x,x1)` is `zXU`-positive there (etc.), the exact property the old constant `segExcl`
        violated. Build the `IntervalPattern.holds`/`VecEA2.holds` data via the Phase-2
        `bracket_construct` lift. Cite Rabinovich Lemma 5.3 (md:137-152) per segment/point condition.
  - [ ] Assemble `kvE_subBracket2V_complete : (∃ x1, nf_eval_nf M 1 4 (Fin.cons x1 [w,x,t]) σ) →
        holds`, selecting the disjunct via `VVecEA2.holds`'s `∃ vea ∈ disjuncts` (:276) at `(x,t)`.
        Confirm the pair `(sound, complete)` is the arity-4 analog of the k1v `(sound, complete)` pair.
  - [ ] **Driven-proof gate:** the lemma MUST close sorry-free. If a genuine obstruction appears
        (not mere effort), STOP, do NOT place a `sorry`, do NOT accept a soundness-only deliverable —
        write a blocker report. (This is not an expected outcome: the VVecEA2 carrier is the proven
        rescue shape.)
  - [ ] No `simp`/`omega`/`aesop` on chain steps.
- **Estimated output:** ~300-400 lines. Bounded unit: disjunct selection + segment discharge +
  `_complete` assembly (heavy machinery already in Phase 2). **Pre-authorized sub-split** (H8): 4.1 =
  disjunct selection + per-region segment discharge; 4.2 = assemble `kvE_subBracket2V_complete`.
- **Done when:** `kvE_subBracket2V_complete` compiles sorry-free standalone; scoped `lake build`
  green; `lean_verify` axiom-clean.
- **Verification:** scoped `lake build` green; `lean_verify` on `kvE_subBracket2V_complete`;
  forbidden-tactic grep clean; do-not-edit `git diff` clean.
- **Commit point:** `task 325 phase 4: completeness lemma kvE_subBracket2V_complete closed`
- **Depends on:** 2

### Phase 5: Correctness-pair packaging + successor threading + final verification [NOT STARTED]
- **Goal:** Confirm the full correctness pair is sorry-free, axiom-clean, forbidden-tactic-free, the
  do-not-edit invariant held throughout, and the successor-parameter threading is end-to-end
  compatible at `j=0`.
- **Tasks:**
  - [ ] Full scoped `lake build` green from a clean state.
  - [ ] `lean_verify` on both `kvE_subBracket2V_sound` and `kvE_subBracket2V_complete`: axioms ⊆
        `{propext, Classical.choice, Quot.sound}`.
  - [ ] `grep`-confirm zero `sorry` on the new live path (including no WIP `sorry`).
  - [ ] Forbidden-tactic grep over ALL new chain-construction blocks (`simp`/`omega`/`aesop`; `by
        omega` only in `Fin`-index typing positions).
  - [ ] `git diff` over all Preserved-Asset ranges: byte-identical, unreferenced by new work; confirm
        `kvE_subBracket2`/`kvE_subChain2` :6120/:6166 and the full ~:6120-6720 kit untouched.
  - [ ] Confirm the successor header threads: `σ : NormalForm sig (j+1) 4` instantiates to the landed
        `NormalForm sig 1 4` at `j=0` (R4); the carrier converges onto the amended spec (321 §2 :225).
  - [ ] Package a doc-comment lemma bundling the pair `(kvE_subBracket2V_sound,
        kvE_subBracket2V_complete)` as the arity-4 analog of the k1v pair (no new proof obligations).
- **Estimated output:** ~40-90 lines (packaging/doc lemma; no new heavy proofs).
- **Done when:** all checks pass; the deliverable is a green, axiom-clean arity-4 correctness pair
  over the `VVecEA2` carrier with BOTH directions driven closed.
- **Verification:** as listed in Tasks.
- **Commit point:** `task 325: complete implementation (VVecEA2 arity-4 correctness pair)`
- **Depends on:** 3, 4

## Testing & Validation

- [ ] Scoped `lake build` green after EACH committed phase (never commit a red or sorry-carrying state).
- [ ] `lean_verify` axiom check on every new lemma: axioms ⊆ `{propext, Classical.choice, Quot.sound}`.
- [ ] Soundness lemma `kvE_subBracket2V_sound : holds → ∃ x1, nf_eval_nf M 1 4` closes standalone,
      sorry-free (DRIVEN, not type-check).
- [ ] Completeness lemma `kvE_subBracket2V_complete` (reverse) closes standalone, sorry-free (DRIVEN,
      not type-check) — the direction that failed on the old carrier.
- [ ] BOTH directions closed before the construction counts as validated (driven-proof discipline);
      neither deferred, assumed, nor accepted on the strength of the other.
- [ ] Three per-region segment types `segXU`/`segUW`/`segWT` exclude only their own region's
      negatives (no constant tri-zone `segExcl`).
- [ ] Codomain is `VVecEA2` (the struct); disjuncts over `S_XU × S_UW × S_WT` permutations; gate-fail
      empty disjunction; anchor set fixed at `{x,t}` (G4/Cap; `x1`/`w` are witness slots).
- [ ] Forbidden-tactic grep clean on all new chain-construction blocks.
- [ ] Amendment F3: no provider-side pinning / residual `w = e 1` / `x1 = e 0` equation.
- [ ] `git diff` confirms all Preserved-Asset ranges byte-identical and unreferenced.
- [ ] Successor header `σ : NormalForm sig (j+1) 4` threads; `j=0` instance = landed `NormalForm sig 1 4`.

## Artifacts & Outputs

- plans/01_vvecea2-carrier-redesign.md (this file)
- New additive definitions and lemmas appended to
  `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean`:
  `segXU`/`segUW`/`segWT`, `kvE_subBracket2V`, `kvE_subChain2V`, the three-region
  `sorted_realization`/`bracket_construct` kit lift, `kvE_subBracket2V_sound`,
  `kvE_subBracket2V_complete` (names at implementer discretion).
- summaries/NN_vvecea2-carrier-redesign-summary.md (on completion)

## Rollback/Contingency

- **Per-phase rollback:** each phase commits only when green (scoped build + axiom-clean + no sorry).
  A failed phase leaves the prior green commit intact; nothing partial is committed. If a build goes
  red mid-phase, fix forward (correct the source) — never discard uncommitted changes to reach a
  passing build. If a rollback is genuinely required, run `bash .claude/scripts/git-snapshot.sh`
  first (per git-workflow.md "No Destructive Git on Uncommitted Work").
- **H8 sub-split valve:** Phases 2, 3, 4 are each pre-authorized to split into two sub-phases
  (2.1/2.2, 3.1/3.2, 4.1/4.2) with commit-per-green if a single dispatch overflows ~400 lines or fails
  the bounded-unit test. This is not a scope change — it is the H8 splitting rule applied in advance.
- **Completeness genuine-obstruction handling (R1):** if Phase 4 hits a genuine obstruction (not mere
  effort) driving completeness closed, STOP and write a blocker report. Do NOT place a strategic
  `sorry` (no-sorry-on-live-path rule) and do NOT accept a soundness-only deliverable (that repeats
  task 324's Phase-6 failure and violates the driven-proof discipline). This is not an expected
  outcome — the VVecEA2 arrangement-disjunction carrier is the machine-verified rescue shape.
- **After completion:** resume parent task 321 via `/revise 321` (fold this task's delivered VVecEA2
  carrier + full soundness/completeness pair into a v4 phase decomposition that re-points 321's Phase
  8 and downstream phases at it), then `/implement 321`.
