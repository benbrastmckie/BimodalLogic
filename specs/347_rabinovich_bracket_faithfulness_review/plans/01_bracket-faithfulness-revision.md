# Implementation Plan: Rabinovich Bracket Faithfulness Revision (task 347)

- **Task**: 347 - rabinovich_bracket_faithfulness_review
- **Status**: [IMPLEMENTING]
- **Effort**: ~5 hours
- **Dependencies**: 346 (landed — provides the `hexclExt` isolation point), 335 (provider), 309 (consumer assembly)
- **Research Inputs**: `specs/347_rabinovich_bracket_faithfulness_review/reports/01_bracket-faithfulness-adjudication.md` (H4-verified, verdict (b) SUBSTANTIVE)
- **Artifacts**: plans/01_bracket-faithfulness-revision.md
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/lean4.md
  - .claude/rules/git-workflow.md
- **Type**: lean4

## Overview

The task-346 soundness gate quarantines a strictly-exterior residue as the monolithic named
hypothesis `hexclExt` (`SharedWitness.lean:12665`, mirrored `OuterGate.lean:280`). Research report
01 adjudicated this residue as verdict **(b) SUBSTANTIVE**: `hexclExt` is a **globalization
artifact** — it ranges over ALL `qnf.2 σ = false` sub-forms, but Rabinovich 2014 §5 only ever
brackets **interior** witnesses (`z0<x1<…<xn<z1`, Notation 5.2 / Lemma 5.3) under a **bounded**
outer existential (Cor 5.4, `(∃z)^{<z1}_{>z0}`). The Lean `nf_eval_nf`
(`NormalForm.lean:203–207`) evaluates the fresh witness `∃ (x : M.carrier)` **unbounded**, so the
characterized `qnf` globalizes over exterior arrangements the paper never characterizes.

This plan lands **R1** (the smallest faithfulness-restoring revision) and records the adjudication.
R1 splits `hexclExt` by σ-zone: for an **interior-marked** σ (`nf0_zoneSpec σ.1 ∈
{kvE2_sep_zXW3, kvE2_sep_zWT3}`) the strictly-exterior guard `¬(x ≤ x1 ∧ x1 ≤ t)` falsifies one of
σ's strict `.order` atoms, so `¬ nf_eval_nf …` follows directly from the depth-0 atom clause
(`NormalForm.lean:201–202`) — discharged in-line, **no residue**. Only **exterior-marked** σ remain
in the deferred binder. Net effect: the deferred obligation shrinks from "all `qnf`-false σ" to
"exterior-arrangement σ only", making the report's "phantom obligation" characterization
machine-visible. The plan then retires the mis-framed `prop43_exterior_completeness` successor spec
(replacing it with a Prop 4.3 re-flatten / Lemma 7.6 adjacency task) and records the adjudication
for downstream consumers.

**Definition of done**: R1 landed (full `lake build` green, axiom-clean, sorry inventory unchanged
= empty on live paths); `hexclExt` binder narrowed to exterior-marked σ; successor spec
retired-and-replaced; consumer adjudication recorded for prop43 successor / task 309 Phases 13.4/14
/ task 335 Phase D.

### Source-to-Implementation Mapping (H3, Tier 1 — Rabinovich 2014)

| Source (Rabinovich 2014) | Lean identifier | File:line | R1 role |
|---|---|---|---|
| Notation 5.2 (p.7) — strictly-interior witnesses `z0<x1<…<z1` | `AtomKind.order` (strict `<`), `nf0_zoneSpec` | `NormalForm.lean:58–60,113–117`; `SharedWitness.lean` (zone defs `:79,:87`) | interior σ carry falsifiable strict order atoms |
| Lemma 5.3 (p.8) — interior-index singleton = base case | `kvE2_sepPosI` interior filter | `SharedWitness.lean:211–214` | interior-marked predicate = `zXW3 ∨ zWT3` |
| Cor 5.4 (p.8–9) — outer ∃ is BOUNDED `(∃z)^{<z1}_{>z0}` | `nf_eval_nf` unbounded outer ∃ | `NormalForm.lean:203–207` | root cause of `hexclExt`; not bounded in-place (R2/successor) |
| Lemma 5.1 proof cases 1/2/3 (p.9–11) — NO exterior case | `hexclExt` residue | `SharedWitness.lean:12665`; `OuterGate.lean:280` | narrow to exterior-marked σ only (R1) |
| Prop 4.3 / Lemma 7.6 (p.6, p.13) — re-flatten by adjacency | `Prop43.lean:120–159` (uniform-negation blocker) | — | R2 successor entry point (retire-and-replace) |

### Preserved Assets

The following task-346 work is complete (full build GREEN, 1720 jobs, axiom-clean) and must not
regress. R1 narrows one binder; it must NOT re-prove or overwrite these.

| Component | File | Status | Verified |
|-----------|------|--------|----------|
| `kvE2_outer_fold_frag` (fold, `hreal`/`hexcl`/`hexclExt` interface) | SharedWitness.lean:12627 | [COMPLETED] | 2026-07-11 (task 346) |
| `bracketEndChar_kvE2_sound_two_prior_frag` (soundness half) | OuterGate.lean:245 | [COMPLETED] | 2026-07-11 (task 346) |
| `kvE2_sepBody_kit_sound_frag` | SharedWitness.lean:12487 | [COMPLETED] | 2026-07-11 (task 346) |
| `kvE2_sepFragment_realizable` (non-vacuity witness) | SharedWitness.lean ~:10265 | [COMPLETED] | 2026-07-11 (task 346) |
| Interior index + membership lemmas `kvE2_sepPosI`/`_mem`/`_zone`/`_subset` | SharedWitness.lean:211–233 | [COMPLETED] | task 342 |
| Everything above the SW:10210 341 GATE banner | SharedWitness.lean | [FROZEN] | do not edit |

## Postmortem Constraints

Binding rules for all implementation dispatches. Derived from research report 01 (verdict (b),
Adversarial Self-Verification), the task-346 summary, and prior 330/335 findings.

**Do NOT**:
- **Do NOT attempt to prove `hexclExt` as a strictly-exterior completeness / non-realization lemma
  on the `(x,t)` bracket.** Report 01 §7 R2 + 335 report 07 Refutation 2 machine-argue it is
  inexpressible in the bracket vocabulary and has NO §5 counterpart. R1 is a *split-and-discharge-
  the-interior-slice*, never a completeness proof.
- **Do NOT bound `nf_eval_nf`'s outer `∃ (x : M.carrier)` in place.** It is correct raw FOMLO
  semantics (`NormalForm.lean:203–207`); the unbounded ∃ is not a bug. The faithful bound is
  Prop 4.3 re-flatten (R2/successor), out of R1 scope.
- **Do NOT edit any declaration above the SW:10210 341 GATE banner** (orchestrator freeze).
- **Do NOT widen the `hexcl` cone or change its `x ≤ x1 ≤ t` guard.** R1 touches only `hexclExt`
  and its discharge site.
- **Do NOT use `simp`/`omega`/`aesop` to bypass the Rabinovich order-atom step.** The interior-slice
  discharge must go through the falsified `.order` atom explicitly (literature-fidelity policy);
  `omega`/`exact` on the extracted order literal is the sanctioned closing move.

**MUST preserve**:
- The task-346 full build (1720 jobs GREEN) and axiom cleanliness `{propext, Classical.choice,
  Quot.sound}` on all four key theorems — no new axioms, no `sorryAx` on any live path.
- The `hreal` / `hexcl` binders and the backward-branch realization channel (`hreal` at
  SharedWitness.lean:12747) — R1 does not touch them.
- The pre-existing unrelated `sorryAx` on `BXCanonical.completeness*` (task-155 residue, different
  module tree) is NOT a 347 regression and must NOT be "fixed" here.

**Design decisions are SETTLED** (do not re-open without a concrete machine counterexample):
- The dropped invariant is the **outer-∃ bound (Cor 5.4)**, NOT the per-σ order atoms — the order
  atoms are present and lossless (`nf0_zoneSpec` is a bijective projection of the `.order` channel).
- The faithful exterior mechanism is **Prop 4.3 re-flatten / Lemma 7.6 adjacency** (a separate
  exterior bracket composed with the interior `(x,t)` bracket), NOT exterior-exclusion on one
  bracket. This adjudicates in favour of 330/335's mechanism over the 346 summary's framing.
- R1 lands FIRST to shrink the residue to exterior-only; only then is the R2/successor scope well
  defined.

## Goals & Non-Goals

**Goals**:
- Land R1: split `hexclExt` by σ-zone; discharge the interior slice from order atoms; narrow the
  deferred binder to exterior-marked σ.
- Retire the `prop43_exterior_completeness` framing; replace with a Prop 4.3 re-flatten successor
  spec, keeping the `Prop43.lean:120–159` entry point.
- Record the adjudication for consumers (prop43 successor decision, 309 Phases 13.4/14, 335 Phase D).

**Non-Goals**:
- Proving exterior completeness / discharging the exterior-marked residue (R2 = successor task).
- Bounding `nf_eval_nf`'s outer ∃ (Prop 4.3 re-flatten infrastructure).
- Any edit above the SW:10210 341 GATE banner or to the `hreal`/`hexcl` channels.
- Re-running the `da50f596c`-style inexpressibility probe (inherited-High, does not change verdict).

## Risks & Mitigations

- **Risk (Medium confidence, flagged by H4 Adversarial Self-Verification)**: the interior-slice
  discharge lemma "is a short proof" is *plausible but not machine-verified*; it "could hit a
  `Fin`-index / `decide` wrinkle" when unfolding `nf0_zoneSpec σ.1` to the concrete falsified
  `.order` atom over the env `[x1,w,x,t]`. **Mitigation**: Phase 1 proves the lemma in ISOLATION
  (a standalone `theorem`) with its own build+axiom check BEFORE any fold wiring, so a Fin-index
  wrinkle surfaces early and cannot corrupt the landed 346 gate. If the lemma resists after a
  bounded attempt, mark Phase 1 [BLOCKED] with the exact goal state — do NOT paper over with
  `sorry` or a vacuous placeholder, and do NOT proceed to Phase 2.
- **Risk**: narrowing the `hexclExt` binder could break the internal caller chain
  (`kvE2_outer_fold_frag` → `bracketEndChar_kvE2_sound_two_prior_frag`). **Mitigation**: Phase 2
  propagates the narrowed binder through BOTH sites in one dispatch and rebuilds the full project;
  the 346 summary confirms zero EXTERNAL consumers of these theorems, so the break surface is
  contained to `NfMultiAnchorBridge`.
- **Risk**: doc phases (3/4) drift from the actual landed Lean state. **Mitigation**: doc phases
  depend on Phase 2 landing green and cite the post-R1 binder shape verbatim.

## Dependency Analysis

| Wave | Phases | Blocked by | Rationale |
|------|--------|------------|-----------|
| 1 | Phase 1 | -- | Isolated lemma; no other phase's decisions needed |
| 2 | Phase 2 | 1 | Wiring consumes the Phase-1 lemma |
| 3 | Phase 3, Phase 4 | 2 | Docs describe the landed post-R1 state |

Waves are informational; the orchestrator dispatches strictly one phase per cycle. Phases 3 and 4
are mutually independent (distinct file territory) but both require Phase 2 green.

## Implementation Phases

### Phase 1: Interior-slice order-atom discharge lemma [COMPLETED]

- **Goal:** Prove, in isolation, that a strictly-exterior `x1` falsifies an interior-marked σ from
  the depth-0 atom clause — the order-atom-only core of R1.
- **Tasks:**
  - Add a standalone `theorem` in `SharedWitness.lean` (BELOW the SW:10210 GATE banner, near the
    fold at ~:12620) of shape:
    `∀ (σ : NormalForm sig 1 4) (x1 : M.carrier),
       (nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3) →
       ¬ (x ≤ x1 ∧ x1 ≤ t) →
       ¬ nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ`.
  - Proof strategy (literature-faithful, per report 01 §7 R1 / `NormalForm.lean:201–202`): from the
    interior-zone hypothesis, extract the concrete strict `.order` atom σ.1 asserts (e.g. `zXW3` ⇒
    `x < x1`, i.e. env-pos-for-x `<` env-pos-for-x1); from `¬(x ≤ x1 ∧ x1 ≤ t)` derive the case
    (`x1 < x` or `t < x1`) that falsifies that atom; feed the depth-0 clause `∀ a, atom_eval M env a
    ↔ (assignment a = true)` to contradict. Close the order literal with `exact`/`omega`, NOT with a
    blanket `simp`/`decide` over the whole `nf_eval_nf`.
  - Use `lean_goal` / `lean_multi_attempt` at the `.order`-extraction step to resolve any Fin-index
    (`⟨i, h⟩`) matching wrinkle before committing the edit.
- **Verification criteria:**
  - `lake build Theories.Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness`
    green (scoped).
  - `#print axioms` on the new lemma = `{propext, Classical.choice, Quot.sound}`, NO `sorryAx`.
  - Grep confirms no `sorry`/vacuous-`True` term introduced.
- **File territory:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` (append below banner only).
- **Timing:** ~1.5 hours. **Depends on:** none.
- **Escalation:** if the lemma resists a bounded attempt (Fin-index / `decide` wrinkle
  unresolvable), mark [BLOCKED] with the exact `lean_goal` state and what infrastructure is missing;
  do NOT proceed to Phase 2.
- **Estimated output:** ~40–120 lines (one theorem + proof).

### Phase 2: Narrow `hexclExt` to exterior-marked σ; re-thread fold + OuterGate [NOT STARTED]

- **Goal:** Consume the Phase-1 lemma so the deferred `hexclExt` binder ranges only over
  exterior-marked σ; propagate the narrowed shape through both theorem sites; full build green.
- **Tasks:**
  - In `kvE2_outer_fold_frag` (`SharedWitness.lean:12665`): narrow the `hexclExt` binder from
    `∀ σ, qnf.2 σ = false → …` to additionally require the exterior-zone marker
    (`nf0_zoneSpec σ.1 ≠ kvE2_sep_zXW3 ∧ ≠ kvE2_sep_zWT3`, or the equivalent
    `¬(nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ = kvE2_sep_zWT3)`).
  - At the discharge site (`SharedWitness.lean:12735–12737`, inside the `¬hcone` branch): add
    `by_cases` on the interior-zone predicate for σ; the interior-marked branch closes via the
    Phase-1 lemma (no residue), the exterior-marked branch closes via the narrowed `hexclExt`.
  - Propagate the narrowed binder through `bracketEndChar_kvE2_sound_two_prior_frag`
    (`OuterGate.lean:280`) and its call to the fold (`OuterGate.lean:291`).
  - Update the in-code design-note comments at the binder sites
    (`SharedWitness.lean:12658–12664`, `OuterGate.lean:248–253`) to state the residue is now
    exterior-marked-only and cite report 01 (R1 interior slice discharged, R2 = Prop 4.3 re-flatten).
- **Verification criteria:**
  - Full `lake build` green (target: `Build completed successfully`, exit 0), no new RED.
  - `#print axioms` on `kvE2_outer_fold_frag`, `bracketEndChar_kvE2_sound_two_prior_frag`,
    `kvE2_sepBody_kit_sound_frag` = `{propext, Classical.choice, Quot.sound}`, NO `sorryAx`.
  - Sorry inventory delta = 0: live paths remain EMPTY (grep + `#print axioms` cross-confirm; the
    known `BXCanonical.completeness*` residue is pre-existing and out of scope).
  - Diff touches only the two `NfMultiAnchorBridge` files below the GATE banner.
- **File territory:** `SharedWitness.lean` (fold + discharge site), `OuterGate.lean` (soundness-half binder + call).
- **Timing:** ~2 hours. **Depends on:** 1.
- **Estimated output:** ~60–160 lines (binder edits, `by_cases` re-thread, comment updates).

### Phase 3: Retire-and-replace the `prop43_exterior_completeness` successor spec [NOT STARTED]

- **Goal:** Correct the mis-framed successor spec in the task-346 summary per report 01's
  retire-and-replace adjudication.
- **Tasks:**
  - In `specs/346_successor_carrier_redefinition/summaries/01_successor-carrier-redefinition-summary.md`,
    "Deferred Successor Task Specification" section (~:164–215): mark the
    `prop43_exterior_completeness` framing **RETIRED** (the "prove strictly-exterior completeness /
    no exterior point realizes a `qnf`-false sub" obligation is a phantom completeness theorem with
    no §5 counterpart).
  - Replace with `prop43_exterior_reflatten`: "restore interval-bounding faithfulness by
    re-flattening the exterior witness arrangement (Rabinovich Prop 4.3 p.6 + Lemma 7.6 p.13
    adjacency) into a SEPARATE exterior bracket composed with the interior `(x,t)` bracket; land R1
    first (done here) to shrink the residue to exterior-marked σ only." Keep the dependency graph
    (346/335/309), the 330/335 grounding, and the `Prop43.lean:120–159` uniform-negation entry
    point. Definition of done unchanged at the 309 level (full completeness, `KampPrior:351`
    retired) but achieved by re-flatten/adjacency, NOT exterior exclusion.
  - Note the reconciliation: 346's *pointer* ("Prop-4.3 successor") is correct; its *mechanism*
    ("exterior exclusion on this gate") is wrong; 347 adjudicates for 330/335's re-flatten mechanism.
- **Verification criteria:**
  - The retired spec no longer instructs a would-be implementer to "prove exterior completeness".
  - The replacement spec cites Prop 4.3 + Lemma 7.6 and the R1-first ordering, and is `/task`/`/spawn`-createable verbatim.
  - No Lean file touched; no build impact.
- **File territory:** `specs/346_successor_carrier_redefinition/summaries/01_successor-carrier-redefinition-summary.md` (successor-spec section only).
- **Timing:** ~0.75 hours. **Depends on:** 2.
- **Estimated output:** ~40–90 lines of markdown edits.

### Phase 4: Record adjudication for consumers [NOT STARTED]

- **Goal:** Capture the adjudication outcome so downstream consumers pick up the interior+boundary
  + adjacent-exterior model instead of a single all-arrangement gate.
- **Tasks:**
  - Produce the task-347 consumer record (in the 347 summary / handoff and, where load-bearing, as
    in-code notes at the narrowed binder) covering:
    - **prop43 successor decision**: RETIRE "prove exterior completeness"; REPLACE with
      `prop43_exterior_reflatten` (Prop 4.3 re-flatten); land R1 first (done).
    - **Task 309 Phases 13.4/14** (+ `KampPrior.lean:351`): consume an interior+boundary gate **+
      adjacent exterior bracket**, seam at anchors `x,t`; do NOT expect a single all-arrangement
      `(x,t)` gate.
    - **Task 335 Phase D**: re-shape the provider obligation to **bounded interior + jointly-ordered**
      witnesses (Cor 5.4 ⇐), routed through `kvE2_sepPosI`, NOT the global `kvE2_sepPos`.
  - Confirm the R1 landing made the "phantom obligation" machine-visible: the deferred residue is
    now exterior-marked σ only (cite the narrowed binder shape from Phase 2).
- **Verification criteria:**
  - All three consumer records present and each cites its Rabinovich §5 grounding + the post-R1
    binder shape.
  - Consistent with the Phase-3 replacement spec (no contradiction between successor spec and
    consumer notes).
- **File territory:** task-347 summary/handoff artifacts; optional in-code consumer notes at
  `SharedWitness.lean`/`OuterGate.lean` binder sites (no proof-term edits).
- **Timing:** ~0.75 hours. **Depends on:** 2.
- **Estimated output:** ~50–110 lines of documentation.

## Testing & Validation

- **Phase 1**: scoped `lake build` of `SharedWitness`; `#print axioms` on the new lemma; sorry grep.
- **Phase 2**: full `lake build` green; `#print axioms` on the three key theorems; sorry-inventory
  delta = 0 (live paths empty); diff scoped to the two `NfMultiAnchorBridge` files below the banner.
- **Phases 3/4**: doc-review — retired framing removed, replacement spec createable, consumer
  records grounded and internally consistent; no build impact.
- **Regression guard**: the task-346 build (1720 jobs) must stay green and axiom-clean throughout;
  the `BXCanonical.completeness*` `sorryAx` is pre-existing and NOT a 347 regression.

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` — Phase-1
  interior-slice lemma + Phase-2 narrowed `hexclExt` binder + re-threaded discharge.
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/OuterGate.lean` — Phase-2
  narrowed soundness-half binder + call.
- `specs/346_successor_carrier_redefinition/summaries/01_successor-carrier-redefinition-summary.md`
  — Phase-3 retired-and-replaced successor spec.
- `specs/347_rabinovich_bracket_faithfulness_review/summaries/01_*.md` (+ handoff) — Phase-4
  consumer adjudication record.

## Rollback/Contingency

- R1 is additive+narrowing on a self-contained gate with zero external consumers (346 summary
  §"No Full-Build Breakage"). If Phase 2 turns the build RED and cannot be resolved in-dispatch,
  revert the Phase-2 binder edits (restore the monolithic `hexclExt`); the Phase-1 lemma is inert
  standalone and may remain. Mark the phase [PARTIAL]; the 346 gate is unaffected by an isolated
  Phase-1 lemma.
- If Phase 1 is [BLOCKED] (Fin-index wrinkle unresolvable), the entire R1 revision is deferred; the
  346 gate stands as-is and the successor spec (Phases 3/4) may still proceed as pure documentation
  (they do not depend on the Lean landing being green — but note in them that R1 remains unlanded).

## Plan Metadata

```json
{
  "phases": 4,
  "total_effort_hours": 5,
  "complexity": "medium",
  "research_integrated": true,
  "plan_version": 1,
  "dependency_waves": [[1], [2], [3, 4]],
  "reports_integrated": [
    {
      "path": "reports/01_bracket-faithfulness-adjudication.md",
      "integrated_in_plan_version": 1,
      "integrated_date": "2026-07-11"
    }
  ],
  "skeleton": false,
  "follow_up_tasks": []
}
```
