# Implementation Plan: Monotone time issuance across identification

- **Task**: 437 - repair_time_index_reuse_in_identification_plus_nexttime_bookkeeping
- **Status**: [IMPLEMENTING]
- **Effort**: 19 hours
- **Dependencies**: None (spawned from 436, which is [IMPLEMENTING] and blocked on this result)
- **Research Inputs**:
  - `specs/437_repair_time_index_reuse_in_identification_plus_nexttime_bookkeeping/reports/01_spawn-analysis-pointer.md`
  - `specs/436_fourth_termination_measure_component/reports/02_spawn-analysis.md`
- **Artifacts**: plans/01_monotone-time-issuance.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/plan-format-enforcement.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/lean4.md
  - .claude/rules/plan-compliance.md
- **Type**: lean4
- **Lean Intent**: false

---

## Overview

`Branch.nextTime` (`SignedFormula.lean:380-381`) is `maxTime + 1`, recomputed from the live branch
on every call. The ordered split's identification arm (`Tableau.lean:1520-1527`) calls
`branch.identifyTime t₂ t₁`, which retires `t₂` from `knownTimes`. When `t₂` happens to be the
branch's current maximum, `maxTime` drops and the next mint re-issues the retired index. That is
decided, not conjectured: `nextTime_reissues_retired_time` (`MintBound.lean:7321`) and
`reuse_driven_through_engine` (`MintBound.lean:7363`). Because the accumulated renaming σ can never
land on a retired source time (`rhoSF_time_ne_src`, `MintBound.lean:7299`), every measure-side
fourth-component candidate inherits a false σ-hit obligation — register entries 15 and 17.

This task attacks the mechanism rather than the measure: make fresh-time issuance **monotone across
a run**, so the reuse configuration stops occurring at all. The plan opens with a mandatory
refute-first gate (Phase 1) that prototypes the mechanism **additively inside `MintBound.lean`,
against the same `reuseWitness*` / `gate*` configuration already landed there**, and decides two
questions before any live engine file is touched: (a) is reissue actually prevented, and (b) do
`RunInvariant`, `OrdTimesKnown` (register entries 7 and 16) and `UniverseClosedAt`-style
confinement (entries 10-12) survive the change. Only a TRUE verdict unlocks Phases 2-9.

**Definition of done** (contingent on Phase 1 deciding TRUE): the ordered split's identification arm
is oriented so that `Branch.maxTime` is non-decreasing across it; a machine-checked run-level
monotonicity statement is landed; `RunInvariant`, `OrdTimesKnown` and `UniverseClosedAt`'s clause 2
are re-proved at the oriented arm; `nextTime_reissues_retired_time`'s configuration no longer
re-issues on the engine path; every consumer in `Fuel.lean`, `MintBound.lean` and
`SubformulaProperty.lean` is re-verified; `lake build` is green; the result is sorry-free and
axiom-free; and any sub-route decided false is landed as C9 **register entry 18**.

### Research Integration

From `specs/436_fourth_termination_measure_component/reports/02_spawn-analysis.md`:

- **Root cause carried forward verbatim**: `knownTimes` / `identifyTime` / `maxTime` / `nextTime`
  at `SignedFormula.lean:349-381`, and `TimeOrdering.identifyTime` at `SignedFormula.lean:705-710`.
  Both `maxTime` and `nextTime` are recomputed from the live branch with no memory of a retired
  larger value.
- **All 17 C9 entries checked**; entries 14, 15 and 17 close the measure side, entries 7 and 16
  name `OrdTimesKnown` as a settled repair this task must not silently re-break, entries 10-12 name
  `UniverseClosedAt` confinement as the analogous settled repair. No entry closes *redefining* the
  bookkeeping mechanism — that is the genuinely unclosed route this plan takes.
- **Blast radius** from the report is carried and **extended by this plan's own grep** (see
  "Measured blast radius" below): the report's 4-file scope is an undercount.

### Prior Plan Reference

`specs/436_fourth_termination_measure_component/plans/01_self-guard-potential.md` is the shape this
plan mirrors, not a template to copy. What is carried from it:

- **The refute-first gate is worth its cost.** Its Phase 1 decided the whole task in one
  configuration out of a budget of three, at +144 lines against a plan-time estimate of 200-250,
  and Phases 2-9 were correctly marked `[BLOCKED]` rather than executed on a refuted design.
- **Effort calibration**: its per-phase estimates ran slightly *over* on line count and *under* on
  configuration count. This plan therefore states configuration budgets and line estimates as
  explicit Scope Hypotheses rather than as facts.
- **Verdict discipline**: a FALSE verdict is a successful deliverable landed as a register entry,
  not a failure. Reproduced here as Phase 10's unconditional role.
- **Its σ = `id` vs σ = run-realizable discriminating measurement** is the reason this plan
  requires the gate to distinguish "mechanism prevents reissue" from "mechanism is inert".
- **What is deliberately NOT carried**: its additive-only-in-`MintBound.lean` discipline. That
  discipline cannot hold here and the plan says so up front rather than discovering it mid-run.

### Roadmap Alignment

`specs/ROADMAP.md` was read. It contains no item naming `nextTime`, `identifyTime`, or the
termination-measure obstruction; the "roadmap item 2" the task description cites is the user's
spawn-prompt roadmap recorded in `specs/436_.../reports/02_spawn-analysis.md`, not a
`specs/ROADMAP.md` entry. **No `specs/ROADMAP.md` item is advanced or updated by this task**, and
this plan does not write to that file.

---

## Measured blast radius (this plan's own grep, superseding the research report's figure)

The task description's declared file scope is four files. Grep run at plan time shows the true
exposure is **six** source files plus one test file. This is stated here, before Phase 1, because
discovering it mid-implementation is exactly the failure the predecessor plan's Preserved-Assets
discipline exists to prevent.

| File | `nextTime` | `identifyTime` | `identifyTime t₂ t₁` | In declared scope? |
|------|-----------|----------------|----------------------|--------------------|
| `Decidability/SignedFormula.lean` | 1 (the def) | 4 (both defs + docstrings) | 0 | yes |
| `Decidability/Tableau.lean` | 9 mint sites (761, 801, 834, 878, 924, 971, 1069, 1168, 1370) + 6 docstring | 1 (arm 3, line 1526) | 1 | yes |
| `Verified/Termination/Fuel.lean` | — | 26 | 12 | yes |
| `Verified/Termination/MintBound.lean` | many | many | 66 | yes |
| `Verified/Decidable.lean` | **102** | 3 (all docstring) | 1 (docstring) | **NO — scope finding** |
| `Verified/Termination/SubformulaProperty.lean` | 0 | 8 | 2 | **NO — scope finding** |
| `Verified/Bridge/BranchOrder.lean` | 0 | 5 (2 `#eval` rows + docstring) | 0 | **NO — scope finding** |
| `Tests/BimodalTest/UntlSnceCopyProbe.lean` | 10 (`#eval` probe rows) | 0 | 0 | **NO — scope finding** |
| `Decidability/Saturation.lean` | 0 | 0 | 0 | correctly excluded |

**Why `Decidable.lean`'s 102 hits are the decisive scope fact.** That file independently
rediscovered this same obstruction from the `OrdWithin` / `SatState` side and recorded it in prose
(`Decidable.lean:271-284`): "`Branch.identifyTime` *removes* a time from `knownTimes` and so can
**lower** `nextTime`", with its own counterexample `b = [f₀, f₇]`, `ord = ⟨[(5,7)]⟩`. It also proves
`lt_nextTime_of_mem_knownTimes`, `OrdWithin.bound` and `OrdWithin.nextTime_not_mem`
(`Decidable.lean:297-330`), all of which consume `Branch.nextTime = maxTime + 1` **definitionally**.

This forces a hard design constraint, adopted before the gate rather than discovered after it:

> **`Branch.nextTime`, `Branch.maxTime`, `Branch.identifyTime` and `TimeOrdering.identifyTime` keep
> their current definitions and signatures, byte-unchanged.** The repair is made at the *arm*, not
> at the definitions.

Under that constraint `Decidable.lean`'s exposure collapses from 102 references to one docstring
paragraph, and `Tableau.lean`'s nine mint sites need no edit at all — because a monotone `maxTime`
makes `nextTime` monotone for free at all nine.

---

## Candidate mechanisms (the gate's ladder)

Three mechanisms were identified at plan time. **Candidate A is the plan's primary**; B and C are
the fallback rungs for Phase 1's attempt budget. The gate may not invent a fourth without recording
why all three failed.

### Candidate A — merge orientation: retire the smaller index (PRIMARY)

`firstIncomparablePair` (`Tableau.lean:422-429`) scans `knownTimes` in **branch order** and
guarantees only `t₂ ≠ t₁` (`firstIncomparablePair_spec`, `Fuel.lean:1023-1026`) — it does **not**
guarantee `t₁ < t₂`. Arm 3 currently calls `identifyTime t₂ t₁`, retiring `t₂` whatever its
magnitude. Orient the merge by numeric order instead: retire `min t₁ t₂`, keep `max t₁ t₂`.

- **Why it makes issuance monotone**: the surviving numeral is the larger of the pair, and no other
  formula's time changes, so `Branch.maxTime` cannot drop at the arm. Every other engine step is
  additive on the branch (`Decidable.lean:274` calls arm 3 "the engine's single non-additive step"),
  so `maxTime` — and hence `nextTime` — is non-decreasing across the whole run.
- **Why it is sound**: identification asserts the two instants are the *same*; which numeral
  survives is arbitrary. Nothing in the semantics reads the numeral's magnitude.
- **New state required**: none. No structure field, no signature change, no threaded counter.
- **Blast radius**: one arm in `Tableau.lean`; re-verification (mostly re-instantiation at swapped
  arguments) of the 82 `identifyTime t₂ t₁` sites.
- **Load-bearing lemmas already general in `src`/`tgt`** (so they survive the flip unchanged):
  `irreflOrd_identifyTime` (`MintBound.lean:74`), `ordTimesKnown_identifyTime`
  (`MintBound.lean:1331`, explicitly documented as needing *no trigger hypotheses at all*),
  `src_not_mem_knownTimes_identifyTime` / `knownTimes_identifyTime_subset` /
  `knownTimes_card_lt_identifyTime` (`Fuel.lean:1947, 1957, 1971`, all quantified over both times
  with only membership and distinctness hypotheses).
- **Known exposure**: `identifyTime_no_collapse` (`MintBound.lean:231`) is stated at `rho t₂ t₁`
  from an `incomparableB ord (t₁, t₂)` hypothesis, whose three conjuncts are written asymmetrically
  in `t₁`/`t₂`. Applying it at the flipped orientation needs a bridge — `incomparableB_symm` — and
  that bridge is a **named Phase 3 obligation**, not an assumption.

### Candidate B — a highwater field on `TimeOrdering` (FALLBACK 1)

Add `horizon : TimeIndex` to the `TimeOrdering` structure, raised at every mint and never lowered
by `identifyTime`; mint at `max b.nextTime (ord.horizon + 1)`.

- **Measured cost**: `TimeOrdering` is referenced in **29 files**; there are 35 `{ constraints := }`
  sites and 47 `: TimeOrdering :=` binding sites. Lean 4's anonymous constructor `⟨[...]⟩` does not
  fill default field values, so every such literal breaks. Also disturbs the many `decide`-based
  witnesses whose closed terms include `TimeOrdering` literals.
- **Verdict at plan time**: viable but expensive. Only reach for it if A fails.

### Candidate C — a run-level mint counter threaded through the engine (FALLBACK 2)

Thread a `TimeIndex` counter through `applyRule` / `expandOnceUnblocked`.

- **Measured cost**: changes the signature of the engine's two central functions, which
  `MintBound.lean` alone references hundreds of times, and would pull `Saturation.lean` into scope —
  which the task description explicitly wants untouched.
- **Verdict at plan time**: last resort. If the gate reaches this rung, the correct outcome is
  likely UNDECIDED plus register entry 18, not a 30-file refactor.

---

## Preserved Assets

Complete work that must not regress. All in `MintBound.lean` unless stated otherwise.

| Component | Location | Note |
|-----------|----------|------|
| The 17-entry C9 register | `MintBound.lean:7694-7944` | Must remain the file's final block before `end FormalSystem.Metalogic.Decidability`. New entry 18 is appended inside it and the opening count ("Seventeen statements") updated in the same edit |
| `nextTime_reissues_retired_time`, `reuse_driven_through_engine`, `reuseStep`, `reuseWitness*` | `MintBound.lean:7309-7366` | The witness configuration this task's gate reuses. **Note: `reuse_driven_through_engine` runs the live engine under `decide` and WILL change value when arm 3 changes** — see Phase 7 |
| `rho_src_ne_src`, `rhoSF_time_ne_src`, `mint_not_in_rhoSF_image` | `MintBound.lean:7296-7307` | Statements about the renaming's construction; unaffected by any arm change, and must stay unaffected |
| `gateBranch`, `gateOrd`, `gateUniverse`, `gateSigma`, `gate_runInvariant`, `gate_confined`, `gate_is_reissue_hazard`, `gate_step_fires` | `MintBound.lean:7527-7600` | The second witness configuration. `gate_is_reissue_hazard` conjuncts 3-6 are stated about `Branch.identifyTime reuseWitnessBranch 2 0` — a direct function call, not the arm — so they remain true as stated; conjunct 7 and `gate_step_fires` run the engine |
| `OrdTimesKnown`, `RunInvariant`, `ordTimesKnown_identifyTime` | `MintBound.lean:1260, 1675, 1331` | Register entries 7 and 16's settled repair. Must be re-proved at the oriented arm, never weakened |
| `UniverseClosedAt`, `universeClosedAt_of_universeClosed`, `universeClosedAt_identify_at_trigger`, `timeMergeClosed_identifyTime_signedUniverse` | `MintBound.lean:5318-5350, 5613` | Register entries 10-12's settled repair. Clause 2's target-in-`knownTimes` restriction must still be discharged at the oriented trigger |
| `identifyTime_no_collapse`, `identifyTime_edge` | `MintBound.lean:204, 231` | Load-bearing for arm-3 preservation |
| `knownTimes_card_lt_identifyTime` and the `.splitOrdered` lexicographic measure | `Fuel.lean:1971-2030` | Arm 3's strict-drop discharge. **The termination measure's first component must still strictly drop under any orientation** |
| `firstIncomparablePair`, `firstIncomparablePair_spec` | `Tableau.lean:422`, `Fuel.lean:1023` | The trigger. Not edited; only its output's consumption is reoriented |
| `lt_nextTime_of_mem_knownTimes`, `OrdWithin`, `OrdWithin.bound`, `OrdWithin.nextTime_not_mem` | `Decidable.lean:297-330` | Consume `nextTime = maxTime + 1` definitionally. Protected by the byte-unchanged-definitions constraint |

---

## Postmortem Constraints

Binding on every implementation dispatch.

**Do NOT**:

- **Change the definition or signature of `Branch.nextTime`, `Branch.maxTime`,
  `Branch.identifyTime`, or `TimeOrdering.identifyTime`.** Rationale in "Measured blast radius"
  above: 102 `Decidable.lean` references consume `nextTime = maxTime + 1` definitionally, and
  `Fuel.lean`'s and `MintBound.lean`'s `identifyTime` lemmas are stated generically in `src`/`tgt`
  and stay reusable only if the function is unchanged. The repair goes at the *call site*.
- **Re-attempt any measure-side fourth component.** Register entry 14's two repairs (re-indexing
  `mintPotential` on `freshTimeRules`; dropping disjunct 1's cardinality conjunct) and entry 17's
  whole family (any component whose decrease is witnessed anywhere on the trigger's label, formula
  or time) are closed. This task is not a measure-side route and must not become one under pressure.
- **Weaken or bypass `OrdTimesKnown`.** Entries 7 and 16 record it as the settled repair for the
  refuted `OrdTimesLeMaxTime`. Silently re-breaking it is the single most likely way this task
  produces a green build that is actually a regression.
- **Weaken `UniverseClosedAt` clause 2, or "repair" it by constraining `t₂` as well as `t₁`.**
  Entry 12 decides that both-times constraints are weaker than necessary and that the defect is the
  weakness, not falsity. The oriented arm must discharge the *existing* clause, not a new one.
- **Edit `Saturation.lean`.** Confirmed by grep to reference neither `nextTime` nor `identifyTime`.
- **Widen the file scope silently.** `Decidable.lean`, `SubformulaProperty.lean`,
  `BranchOrder.lean` and `Tests/BimodalTest/UntlSnceCopyProbe.lean` are outside the task's declared
  `file_scope`. Phase 4 measures the exposure and Phase 8 lands it; if edits beyond docstrings and
  `#eval` probe rows are needed in `Decidable.lean`, that is an escalation to report, not a quiet
  expansion.
- **Use `sorry`, `def X := True`, `theorem X := trivial`, or any vacuous placeholder.** The task
  record requires sorry-free and axiom-free at completion, which rules out the strategic-sorry
  skeleton path entirely. A phase that cannot be completed as written is marked `[BLOCKED]` and
  escalated per `.claude/rules/plan-compliance.md`.
- **"Fix" a failing `decide` witness by editing the witness.** `reuse_driven_through_engine` and
  `gate_step_fires` are expected to change value under a successful repair. The correct response is
  to restate them with their new decided value and a docstring saying what changed and why — never
  to re-tune the branch until the old number comes back.
- **Append below the C9 register.** New declarations go in a new subsection inserted immediately
  before the `/-! ## C9` line.
- **Build past a FALSE gate.** Phase 1's verdict governs Phases 2-9 absolutely.

**MUST preserve**: every row of the Preserved Assets table; all 17 existing C9 entries and their
wording; full `lake build` green at every phase boundary that declares it.

**Settled at plan time** (do not re-open without a concrete counterexample):

- Candidate A is the primary mechanism and B/C are fallbacks, for the measured-cost reasons above.
- The repair is made at arm 3's call site, not in `SignedFormula.lean`'s definitions.
- Arm 3 is the engine's only non-additive branch step (`Decidable.lean:274`). Phase 2 turns this
  citation into a checked statement rather than trusting the prose.

---

## Goals & Non-Goals

**Goals**:
- Decide, before touching any live engine file, whether a monotone-issuance mechanism prevents the
  decided reuse configuration and survives `RunInvariant` / `OrdTimesKnown` / `UniverseClosedAt`.
- Land a machine-checked run-level monotonicity statement for fresh-time issuance.
- Re-prove the three settled invariants at the oriented arm.
- Re-verify every `identifyTime`-arm consumer across `Fuel.lean`, `MintBound.lean` and
  `SubformulaProperty.lean`, and repair the stale `decide` witnesses honestly.
- Reach a green, sorry-free, axiom-free `lake build`.
- Land any sub-route decided false as C9 register entry 18.

**Non-Goals**:
- Closing `MintPaysForTime`, or supplying the fourth measure component. Whether the repair makes
  that component unnecessary or merely provable is a **follow-on** question for task 436, and this
  plan does not answer it.
- Covering `densityRule` / `gapPotential`. Still a named residual.
- Any change to `Saturation.lean`, or to the four protected definitions in `SignedFormula.lean`.
- Any strategic-sorry skeleton path.

---

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| R1 — `incomparableB` is not symmetric in `t₁`/`t₂`, so `identifyTime_no_collapse` does not transfer to the flipped orientation | H | M | Phase 3 lands `incomparableB_symm` as a **named obligation before** any consumer is reoriented. If it is false, Candidate A fails at Phase 3 and the gate ladder resumes at Candidate B — recorded, not worked around |
| R2 — `knownTimes_card_lt_identifyTime` fails to drop at the reoriented arm, breaking the `.splitOrdered` termination measure | H | L | The lemma's hypotheses are membership + distinctness only, both supplied by `firstIncomparablePair_spec` in either orientation. Phase 3 proves it at swapped arguments **before** Phase 5 touches `Tableau.lean` |
| R3 — `Decidable.lean` needs real proof edits, not just docstring repair, blowing the declared file scope | H | M | Phase 4 is a dedicated census phase whose sole output is the classified edit list. If proof edits there are required, Phase 4 escalates rather than proceeding |
| R4 — 66 `identifyTime t₂ t₁` sites in `MintBound.lean` make Phase 7 the largest single phase | M | H | Phase 4's census classifies them as arm-bound (need reorientation) vs. generically quantified (need none) before Phase 7 starts, and Phase 7 carries an explicit Scope Hypothesis on the count |
| R5 — the monotone arm changes `decide`-evaluated engine witnesses (`reuse_driven_through_engine`, `gate_step_fires`, and `Tests/BimodalTest/UntlSnceCopyProbe.lean`'s `#eval` rows), turning a *success* into a red build | M | H | Anticipated in the Postmortem Constraints: restate with new decided values plus a docstring saying what changed. Phase 7 owns the `MintBound.lean` witnesses, Phase 8 the probes |
| R6 — the gate passes but issuance is monotone only at arm 3, while some other step shrinks the branch | H | L | Phase 2's second task is exactly to check the "single non-additive step" claim rather than cite it |
| R7 — phase budget. Ten phases at ~19h | M | M | Stated, not hidden. A FALSE gate collapses the task to Phases 1 and 10. If Phases 6-8 overrun, the correct outcome is a `[PARTIAL]` phase plus a named residual, never a silently oversized phase |
| R8 — a green build that silently regressed an invariant | H | L | Phase 9's audit re-runs the invariant statements by name and checks axioms, rather than trusting `lake build` alone |

---

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6, 7, 8 | 5 |
| 7 | 9 | 6, 7, 8 |
| 8 | 10 | 1 |

Phases within the same wave can execute in parallel. Wave 6's three phases are territory-disjoint
by file (`Fuel.lean` / `MintBound.lean` / `SubformulaProperty.lean` + probes) and may be dispatched
in parallel under explicit file ownership. Phase 10 depends only on Phase 1 because it runs on
either verdict.

---

### Phase 1: Refute-first gate on monotone time issuance [COMPLETED]

**Goal**: Decide, additively inside `MintBound.lean` and **before any live engine file is touched**,
(a) whether the monotone-issuance mechanism actually prevents the decided reuse, and (b) whether
`RunInvariant`, `OrdTimesKnown` and `UniverseClosedAt`-style confinement survive it. This phase
produces a binary verdict that governs whether Phases 2-9 execute at all.

**Tasks**:
- [x] Read C9 (`MintBound.lean:7694-7944`) in full, all 18 paragraphs of entry 17 included, before
      writing anything. The task record requires this and the gate's own framing depends on it.
- [x] Open a new subsection `/-! ### Monotone time issuance: the identification-side gate`
      immediately **before** the `/-! ## C9` line.
- [x] Define the prototype orientation without touching the engine:
      `def identifyOrient (t₁ t₂ : TimeIndex) : TimeIndex × TimeIndex := (min t₁ t₂, max t₁ t₂)`
      (retired, surviving), with a docstring stating that the surviving numeral is the larger and
      why that is the whole mechanism.
- [x] Define the prototype arm-3 successor
      `def identifyOriented (b : Branch) (ord : TimeOrdering) (t₁ t₂ : TimeIndex) :
      Branch × TimeOrdering` as `(b.identifyTime (identifyOrient t₁ t₂).1 (identifyOrient t₁ t₂).2,
      ord.identifyTime (identifyOrient t₁ t₂).1 (identifyOrient t₁ t₂).2)`. It calls the **existing,
      unmodified** `Branch.identifyTime` / `TimeOrdering.identifyTime` — this is the constraint the
      whole plan rests on and the gate must demonstrate it holds.
- [x] **Question (a), at the SAME witness**: decide, at `reuseWitnessBranch` / `reuseWitnessOrd`
      with the pair `(0, 2)` that `firstIncomparablePair` actually selects there
      (`gate_is_reissue_hazard` conjunct 3), the conjunction:
      `2 ∈ reuseWitnessBranch.knownTimes ∧ (identifyOriented ... ).1.nextTime > 2 ∧
      reuseWitnessBranch.maxTime ≤ (identifyOriented ...).1.maxTime`.
      Land as `oriented_arm_does_not_reissue`.
- [x] **Question (a), driven through the engine**: define the oriented analogue of `reuseStep` and
      decide that after two steps the branch does **not** re-carry a retired index — the direct
      counterpart of `reuse_driven_through_engine` (`MintBound.lean:7363`). Land as
      `oriented_reuse_not_driven_through_engine`. A gate that only checks the hand-assembled
      configuration is not sufficient; this is the conjunct that makes the verdict about *runs*.
- [x] **Question (b), invariants at the gate**: decide, at both `reuseWitness*` and `gate*`
      configurations, that `RunInvariant`, `OrdTimesKnown` and confinement to the respective
      universe all hold **after** the oriented arm. Land as `oriented_gate_invariants`, in the
      seven-conjunct discipline `gate_is_reissue_hazard` uses, so that a negative verdict is
      attributable to the mechanism and not to a violated precondition.
- [x] **Non-inertness check** (the discriminating measurement, mirroring
      `selfGuardPotential_lt_at_gate_with_id`): decide that at the same configuration the *current*
      orientation **does** re-issue (`(Branch.identifyTime reuseWitnessBranch 2 0).nextTime = 2`,
      already decided at `MintBound.lean:7321`) while the oriented one does not. Without this pair
      the gate cannot distinguish "prevented" from "the configuration stopped applying".
- [x] State the verdict in words in the subsection docstring and in the phase's progress record. *(VERDICT: TRUE — landed in the subsection docstring)*

**Verdict criteria (binary, with an explicit undecided branch)**:
- **TRUE** — reissue is prevented at both the witness and the engine-driven form, and all three
  invariants survive: land the gate theorems and **proceed to Phase 2**.
- **FALSE** — reissue is not prevented, or an invariant demonstrably fails: land the refutation as a
  named theorem, mark Phases 2-9 `[BLOCKED]` naming this phase, jump to **Phase 10**, land C9
  **register entry 18** following the existing convention (declaration name + refuting witness,
  never an issue number), and report back.
- **UNDECIDED** — no mechanism on the ladder both prevents reissue and keeps the four protected
  definitions byte-unchanged within the attempt budget: close `[BLOCKED]`, record which rung failed
  and on which conjunct, land entry 18 as an **open exposure** rather than a refutation, and report
  back. Do not proceed to Phase 2 on an untested mechanism.

**Attempt budget**: at most **three** mechanisms, in the ladder order A → B → C. Do not spend the
phase widening the search beyond the ladder; a fourth mechanism requires recording why all three
failed first.

**Timing**: 2.5 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: "Candidate A is the mechanism", "at most three ladder rungs", and
"~150-250 new lines in `MintBound.lean`" are plan-time hypotheses, not facts. Confirm at
implementation time by recording in the phase's commit message the rung actually used, the number
of rungs attempted, and the actual diff size. If the first rung decides the gate, say so rather than
prototyping the other two.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` — new D2 subsection
  immediately before `/-! ## C9`; **no other file**

**Verification**:
- Every new declaration sorry-free; `lake build
  FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound` green.
- `git diff --stat` shows exactly one file changed.
- The verdict (TRUE / FALSE / UNDECIDED) is stated in words in the subsection docstring.

---

### Phase 2: Generalize the gate — run-level monotonicity [NOT STARTED]

**Goal**: Lift the gate's decided configuration to a general theorem, and check — rather than cite —
that arm 3 is the engine's only non-additive branch step.

**Tasks**:
- [ ] `maxTime_le_identifyTime_oriented {b : Branch} {t₁ t₂ : TimeIndex} (h₁ : t₁ ∈ b.knownTimes)
      (h₂ : t₂ ∈ b.knownTimes) : b.maxTime ≤ (identifyOriented b ord t₁ t₂).1.maxTime` — the general
      form of the gate's third conjunct, quantified over all branches and both times.
- [ ] `nextTime_le_identifyTime_oriented` — the immediate corollary at `nextTime`, stated separately
      because that is the form the nine mint sites consume.
- [ ] `retired_lt_nextTime_oriented`: the retired index is strictly below the post-arm `nextTime`,
      so it can never be re-issued. This is the statement that *replaces* the obstruction, and it is
      the one register entry 18 will cite if a later phase fails.
- [ ] **Check the "single non-additive step" claim.** `Decidable.lean:274` asserts arm 3 is the
      engine's only non-additive branch step. Turn this into a checked statement: enumerate
      `applyRule`'s result constructors and confirm every non-`.branchingOrdered` arm extends the
      branch (or leaves it alone) rather than replacing it. If the sweep finds a second
      branch-shrinking arm, **stop and mark the phase `[BLOCKED]`** — Phase 1's verdict would then
      be about arm 3 only and would not establish run-level monotonicity.
- [ ] `maxTime_monotone_along_run`: the run-level statement, composing the arm-3 result with the
      additive-step sweep.

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: "arm 3 is the only non-additive branch step" is a **citation**, not a
confirmed fact, until this phase's fourth task checks it. Confirm by naming, in the commit message,
the enumeration actually performed and the constructor count it covered.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`

**Verification**:
- All five declarations sorry-free; module build green; still exactly one file changed.

---

### Phase 3: Invariant survival at the oriented arm, generally [NOT STARTED]

**Goal**: Re-prove the three settled invariants at the oriented arm for arbitrary branches and
times, not just at the gate configuration. This is where register entries 7, 10-12 and 16 are
protected.

**Tasks**:
- [ ] `incomparableB_symm {ord : TimeOrdering} {t₁ t₂ : TimeIndex} :
      incomparableB ord (t₁, t₂) = true → incomparableB ord (t₂, t₁) = true`. **Land this first** —
      it is R1, the single most likely point of failure, and `identifyTime_no_collapse`
      (`MintBound.lean:231`) cannot be applied at the flipped orientation without it. If it is
      false, mark the phase `[BLOCKED]` and return to Phase 1's ladder at Candidate B rather than
      routing around it.
- [ ] `identifyTime_no_collapse_oriented` — `identifyTime_no_collapse` restated at the oriented
      arguments, via `incomparableB_symm`.
- [ ] `ordTimesKnown_identifyTime_oriented` — register entries 7/16's invariant at the oriented arm.
      Note `ordTimesKnown_identifyTime` (`MintBound.lean:1331`) is documented as needing *no trigger
      hypotheses at all*, so this should be a direct instantiation; if it is not, that is a finding
      to record, not to route around.
- [ ] `irreflOrd_identifyTime_oriented` — likewise from `irreflOrd_identifyTime`
      (`MintBound.lean:74`), which is already general in `src`/`tgt`.
- [ ] `runInvariant_identifyTime_oriented` — the bundle.
- [ ] `knownTimes_card_lt_identifyTime_oriented` — **R2**: the `.splitOrdered` measure's first
      component must still strictly drop. `knownTimes_card_lt_identifyTime` (`Fuel.lean:1971`) needs
      only membership of the target and distinctness, both supplied by `firstIncomparablePair_spec`
      in either orientation. Prove it here, in `MintBound.lean`, **before** `Tableau.lean` is
      touched.
- [ ] `universeClosedAt_identify_at_trigger_oriented` — entries 10-12's confinement bridge. The
      oriented merge target is `max t₁ t₂`, which `firstIncomparablePair_spec` puts in
      `b.knownTimes` just as it does `t₁`. Confirm `timeMergeClosed_identifyTime_signedUniverse`
      (`MintBound.lean:5613`) still discharges clause 2 at the oriented target.

**Timing**: 2.5 hours

**Depends on**: 2

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: "seven declarations, each a direct instantiation of an existing general
lemma" is a hypothesis. Confirm at implementation time by recording which of the seven were direct
instantiations and which needed independent proofs; a lemma that needed an independent proof is a
signal that the orientation is doing more than re-labelling and must be reported.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`

**Verification**:
- All declarations sorry-free; module build green; still exactly one file changed.
- `incomparableB_symm` is landed before any lemma that consumes it.

---

### Phase 4: Consumer census and edit-list construction [NOT STARTED]

**Goal**: Produce the classified edit list for the live-engine change, and settle the file-scope
question, **before** any consumer is edited. No proof work in this phase.

**Tasks**:
- [ ] Enumerate all `identifyTime t₂ t₁` occurrences (plan-time count: 82 across five files) and
      classify each as **arm-bound** (the site is about the ordered split's arm and must be
      reoriented) or **generically quantified** (the site quantifies over `src`/`tgt` and needs no
      change).
- [ ] Enumerate the `decide`-evaluated and `#eval`-evaluated sites whose values depend on the
      engine's arm-3 behavior: `reuse_driven_through_engine` (`MintBound.lean:7363`),
      `gate_step_fires` (`MintBound.lean:7596`), `BranchOrder.lean:459, 465`,
      `Fuel.lean:1371`, and the `Tests/BimodalTest/UntlSnceCopyProbe.lean` probe rows. These are the
      expected-red sites of a *successful* change (R5).
- [ ] Confirm `Decidable.lean`'s exposure. Plan-time reading says its three `identifyTime`
      references are all docstring prose (`Decidable.lean:277, 278, 284`) and its 102 `nextTime`
      references all consume `nextTime = maxTime + 1`, which is unchanged. **Verify this; if a proof
      site there requires edits, escalate the file-scope expansion explicitly and stop.**
- [ ] Confirm `Saturation.lean` remains untouched (grep, recorded).
- [ ] Write the edit list into the phase's progress record, grouped by owning phase (6 = `Fuel.lean`,
      7 = `MintBound.lean`, 8 = `SubformulaProperty.lean` + `BranchOrder.lean` + probes +
      `Decidable.lean` docstring). This grouping is the territory contract Wave 6's parallel
      dispatch depends on.

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: the counts in "Measured blast radius" (82 arm-shape occurrences; 6 source
files + 1 test file; `Decidable.lean` docstring-only) are **plan-time greps**, not facts. Confirm
each by re-running the grep at implementation time and recording the actual numbers. A divergence of
more than ~10% in any row is a finding to report before Phase 5 starts.

**Files to modify**:
- None (census only; output goes to the task's progress record)

**Verification**:
- Every one of the enumerated occurrences appears in the edit list with a classification.
- The `Decidable.lean` scope question is answered yes/no in writing.

---

### Phase 5: Thread the repair into the live engine [NOT STARTED]

**Goal**: Change the ordered split's identification arm to the oriented form. The single smallest
edit in the plan, and the one that turns everything downstream red until Phases 6-8 land.

**Tasks**:
- [ ] Edit `Tableau.lean`'s `.timeLinearity` arm (line 1526) so arm 3 is the oriented merge. Keep
      arms 1 and 2 byte-unchanged.
- [ ] Extend the arm's existing comment block (`Tableau.lean:1499-1518`) with a paragraph stating
      why the orientation matters: which numeral survives is semantically arbitrary, but retiring
      the smaller keeps `Branch.maxTime` non-decreasing, which is what makes fresh-time issuance
      monotone across the run. Cite `nextTime_reissues_retired_time` by name as the configuration
      being closed.
- [ ] Confirm by grep that the nine `branch.nextTime` mint sites (761, 801, 834, 878, 924, 971,
      1069, 1168, 1370) need **no** edit — they inherit monotonicity from the unchanged
      `nextTime = maxTime + 1` over a now-monotone `maxTime`. Record the confirmation; do not edit
      them.
- [ ] Confirm the four protected definitions in `SignedFormula.lean` are untouched
      (`git diff --stat` shows `SignedFormula.lean` absent).

**Timing**: 1 hour

**Depends on**: 4

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: "one arm, one file, nine mint sites needing no edit" is the plan's central
scope claim. Confirm by recording the actual `git diff --stat` for this phase; more than one changed
file here means the design constraint was violated.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Tableau.lean` — the `.timeLinearity` arm and its comment
  block only

**Verification**:
- `Tableau.lean` itself elaborates.
- Downstream modules are **expected red** at this point; that is the declared `atomic-batch`
  intermediate state and is not committed as green.

---

### Phase 6: Re-verify `Fuel.lean` consumers [NOT STARTED]

**Goal**: Bring `Fuel.lean`'s twelve arm-bound sites and the `.splitOrdered` measure back to green
at the oriented arm.

**Tasks**:
- [ ] Reorient `applyRule_timeLinearity_arms` (`Fuel.lean:1902`) and
      `applyRule_timeLinearity_arms_trigger` (`Fuel.lean:1931`) — the two shape lemmas every other
      site routes through.
- [ ] Re-verify the arm-3 discharge in `splitOrderedMeasure_lt_of_timeLinearity` (`Fuel.lean:2017`
      region) and the fuel-figure arithmetic at `Fuel.lean:2444-2457`, consuming
      `knownTimes_card_lt_identifyTime_oriented` from Phase 3.
- [ ] Re-verify `src_not_mem_knownTimes_identifyTime` / `knownTimes_identifyTime_subset` /
      `knownTimes_card_lt_identifyTime` (`Fuel.lean:1947-1980`) are **unchanged** — they are
      generically quantified and should need no edit. If one needs an edit, that contradicts Phase
      4's classification and must be reported.
- [ ] Update the `#eval` dual-check row at `Fuel.lean:1371` if its value changed, with a docstring
      note saying what changed.
- [ ] Update the arm-3 prose at `Fuel.lean:1886, 1990-1995, 2008-2009, 2364, 2510-2523` so the
      narrative matches the oriented arm.

**Timing**: 2 hours

**Depends on**: 5

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: "twelve arm-bound sites, of which the three `knownTimes_*` lemmas need no
edit" comes from Phase 4's census. Confirm by recording actual edited-declaration count.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean`

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.Fuel` green, sorry-free.

---

### Phase 7: Re-verify `MintBound.lean` consumers and restate the stale witnesses [NOT STARTED]

**Goal**: The largest re-verification surface (plan-time count: 66 arm-shape occurrences), plus the
honest restatement of the engine-driven `decide` witnesses whose values a *successful* repair
changes.

**Tasks**:
- [ ] Work the Phase 4 edit list's `MintBound.lean` group in census order, arm-bound sites only.
- [ ] **Restate `reuse_driven_through_engine` (`MintBound.lean:7363`).** Under a successful repair
      the engine no longer re-carries the retired index, so this `decide` changes value. Restate it
      with its new decided value and a docstring paragraph saying: what it decided before, what it
      decides now, and that the change is the repair working — not a regression. Do **not** re-tune
      the witness branch to recover the old number.
- [ ] Re-verify `gate_is_reissue_hazard` (`MintBound.lean:7578`). Conjuncts 3-6 are stated about a
      direct `Branch.identifyTime reuseWitnessBranch 2 0` call rather than about the arm, so they
      should survive verbatim; conjunct 7 and `gate_step_fires` (`MintBound.lean:7596`) run the
      engine and may not. Restate what changed, with the same discipline.
- [ ] Re-verify `ordTimes_identifyTime_arm3_false` (`MintBound.lean:1217`) — register entry 7's
      refutation of the weak form. It must remain **true**; if the orientation accidentally rescues
      `OrdTimesLeMaxTime`, that is a significant finding to report, not to quietly absorb.
- [ ] Re-verify `universeClosedAt_identify_at_trigger` (`MintBound.lean:5340` region),
      `mem_identifyTime_time_at_trigger` (`MintBound.lean:6569`), and
      `timeMergeClosed_identifyTime_signedUniverse` (`MintBound.lean:5613`) — the three
      trigger-bridge lemmas, all of which name `t₁` as the merge target.
- [ ] Re-verify `mintPotential_identifyTime` (`MintBound.lean:3011`) and
      `witnessPresent_identifyTime` (`MintBound.lean:644`).
- [ ] Confirm `rho_src_ne_src`, `rhoSF_time_ne_src`, `mint_not_in_rhoSF_image`
      (`MintBound.lean:7296-7307`) are **byte-unchanged**. They are statements about the renaming's
      construction and must not be disturbed; entry 15's wording depends on them.
- [ ] Confirm the entry-17 gate declarations (`selfGuardRules` … `mintPaysForTimeAt_reuse_false`)
      still elaborate. Entry 17's *refutation* stands as a historical statement about the old arm;
      whether it still applies to the new arm is a **Phase 10 documentation question**, not a
      licence to delete it.

**Timing**: 3 hours

**Depends on**: 5

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: "66 arm-shape occurrences, most generically quantified and needing no edit"
is a plan-time grep. Confirm by recording, in the phase's commit message, how many of the 66 were
actually edited. If more than ~25 required edits, that is a signal the orientation is not the
re-labelling the plan assumes, and it should be reported before continuing.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound` green,
  sorry-free.
- Every restated `decide` witness carries a docstring paragraph naming its old and new value.

---

### Phase 8: Re-verify the out-of-declared-scope consumers [NOT STARTED]

**Goal**: Bring the three source files and one test file outside the task's declared `file_scope`
back to green, with the scope expansion recorded rather than silent.

**Tasks**:
- [ ] `SubformulaProperty.lean`: re-verify `applyRule_timeLinearity_closed` (line 674) and the two
      arm-shape sites at 666-689, consuming `identifyTime_formula_mem` (line 438) which is
      generically quantified and should need no edit. Update the arm-3 prose at line 57.
- [ ] `Decidable.lean`: update the docstring paragraph at lines 271-284 so its account of the
      identification arm matches the oriented arm — specifically, its counterexample
      (`b = [f₀, f₇]`, `ord = ⟨[(5,7)]⟩`, identify `7` with `0`, `b'.nextTime = 1`) is exactly the
      configuration the repair closes, and the paragraph should now say so and cite `OrdWithin` as
      the invariant that survives either way. **Proof edits in this file are out of scope**; if any
      are required, stop and escalate.
- [ ] `BranchOrder.lean`: update the two `#eval` rows at lines 459, 465 if their values changed, and
      the arm-3 prose at lines 39, 74, 406.
- [ ] `Tests/BimodalTest/UntlSnceCopyProbe.lean`: re-verify the ten `nextTime` probe rows. These read
      `nextTime` on hand-built branches with no identification step, so they are expected to be
      unaffected; confirm rather than assume.
- [ ] Record the file-scope expansion (which files, why, what was edited) in the phase's progress
      record, for the task summary to carry.

**Timing**: 1.5 hours

**Depends on**: 5

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: "`Decidable.lean` needs docstring edits only" is the phase's central
hypothesis and the plan's largest scope risk (R3). Confirm explicitly; a required proof edit there
is an escalation, not a task.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/SubformulaProperty.lean`
- `FormalSystem/Metalogic/Decidability/Verified/Decidable.lean` (docstring only)
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/BranchOrder.lean`
- `Tests/BimodalTest/UntlSnceCopyProbe.lean` (only if a probe row changed value)

**Verification**:
- Each edited module builds green, sorry-free.
- `Saturation.lean` confirmed absent from `git diff --stat`.

---

### Phase 9: Whole-repository green, sorry and axiom audit [NOT STARTED]

**Goal**: Establish the task's stated completion bar — sorry-free, axiom-free, `lake build` green —
and confirm no invariant regressed silently behind a green build.

**Tasks**:
- [ ] Full `lake build` green from a clean state.
- [ ] Sorry sweep across the six edited files; the count must be zero, and must match the
      pre-change baseline everywhere else.
- [ ] Axiom audit: `lean_verify` (or `#print axioms`) on the phase-2/3 monotonicity and invariant
      theorems, on `nextTime_reissues_retired_time`'s restated successor, and on the flagship
      termination results downstream of `splitOrderedMeasure`.
- [ ] Re-state by name, in the phase record, that `OrdTimesKnown`, `RunInvariant` and
      `UniverseClosedAt` clause 2 each hold at the oriented arm, citing the Phase 3 theorem that
      proves it. A green build alone does not establish this (R8).
- [ ] `git diff --stat` for the whole task: confirm `SignedFormula.lean` and `Saturation.lean` are
      absent, and that the four protected definitions are byte-unchanged.

**Timing**: 1.5 hours

**Depends on**: 6, 7, 8

**Verification Tier**: full

**Commit Mode**: per-substep

**Files to modify**:
- None (audit only; findings go to the progress record)

**Verification**:
- `lake build` exits 0.
- Zero `sorry` in the edited files; no new axioms.
- The three invariant citations are named.

---

### Phase 10: C9 register entry 18 and the verdict record [NOT STARTED]

**Goal**: Land the task's decided outcome in the register, on **either** verdict. This phase runs
whether Phase 1 decided TRUE, FALSE or UNDECIDED — only its content differs.

**Tasks**:
- [ ] Append **register entry 18** inside the C9 block (`MintBound.lean:7694-7944`), following the
      file's existing convention: declaration name plus refuting witness, never an issue number.
      Update the opening count from "Seventeen statements" to "Eighteen statements" in the same
      edit — that docstring text is the sanctioned exception to the do-not-alter rule.
- [ ] **If Phase 1 decided TRUE and Phases 2-9 landed**: entry 18 records what is now closed —
      that the reuse configuration entries 15 and 17 rest on no longer occurs on the engine path,
      naming `retired_lt_nextTime_oriented` and the restated
      `reuse_driven_through_engine` — and, critically, states what this does **and does not** do for
      the missing fourth measure component. Entry 17's refutation of `selfGuardPotential` stands as
      a statement about the old arm; whether a measure-side component is now provable is a
      **follow-on question for task 436**, and entry 18 must say that explicitly rather than
      implying the measure question is closed.
- [ ] **If Phase 1 decided FALSE or UNDECIDED**: entry 18 records the identification-side route as
      refuted (or as an open exposure with the exact failing conjunct named), in entry 17's voice —
      the mechanism attempted, the ladder rung reached, the witness, and the one-line reason. Note
      in it that with the measure side closed by entries 14/15/17 and the identification side closed
      here, both of the user's named attack vectors are exhausted, which is itself the actionable
      reportable state.
- [ ] Record, in the entry or its subsection, the file-scope expansion this task discovered
      (`Decidable.lean`'s 102 `nextTime` references and the byte-unchanged-definitions constraint
      they force) — a future reader reaching for a `nextTime` redefinition needs that number.
- [ ] Confirm C9 remains the file's final block before `end FormalSystem.Metalogic.Decidability`.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` — C9 block only

**Verification**:
- Entry 18 present, count updated to "Eighteen statements", C9 still the file's final block.
- Module build green.

---

## Testing & Validation

- [ ] Phase 1's gate theorems are sorry-free and the verdict is stated in words.
- [ ] `oriented_reuse_not_driven_through_engine` decides the engine-driven form, not only the
      hand-assembled configuration.
- [ ] `RunInvariant`, `OrdTimesKnown` and `UniverseClosedAt` clause 2 each proved at the oriented
      arm, generally (Phase 3), not only at the gate configuration.
- [ ] `knownTimes_card_lt_identifyTime_oriented` proved before `Tableau.lean` is edited, so the
      `.splitOrdered` termination measure's arm-3 discharge is never in doubt.
- [ ] `ordTimes_identifyTime_arm3_false` still true (register entry 7 not accidentally rescued).
- [ ] `rho_src_ne_src`, `rhoSF_time_ne_src`, `mint_not_in_rhoSF_image` byte-unchanged.
- [ ] `SignedFormula.lean` and `Saturation.lean` absent from the task's cumulative `git diff --stat`.
- [ ] Full `lake build` green; zero `sorry` in edited files; no new axioms.
- [ ] Register entry 18 landed and the C9 count updated.

## Artifacts & Outputs

- `specs/437_repair_time_index_reuse_in_identification_plus_nexttime_bookkeeping/plans/01_monotone-time-issuance.md` (this file)
- `specs/437_repair_time_index_reuse_in_identification_plus_nexttime_bookkeeping/summaries/01_monotone-time-issuance-summary.md` (implementation summary, written at completion)
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` — the gate subsection,
  the monotonicity and invariant theorems, the restated witnesses, C9 entry 18
- `FormalSystem/Metalogic/Decidability/Tableau.lean` — the oriented arm (Phase 5 only)
- `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean`,
  `.../SubformulaProperty.lean`, `Verified/Decidable.lean` (docstring),
  `Verified/Bridge/BranchOrder.lean`, `Tests/BimodalTest/UntlSnceCopyProbe.lean` —
  consumer re-verification

## Rollback/Contingency

- **Phase 1 decides FALSE or UNDECIDED**: this is a *successful* outcome, not a failure. Mark Phases
  2-9 `[BLOCKED]` naming Phase 1, execute Phase 10 with the refuted/open content, and report. Do not
  build on a refuted mechanism, and do not substitute a weaker deliverable under this task's name.
- **Phase 3's `incomparableB_symm` is false**: Candidate A is dead. Return to Phase 1's ladder at
  Candidate B, re-run the gate there, and re-decide. Record the rung transition; do not patch around
  the missing symmetry.
- **Phase 2's non-additive-step sweep finds a second branch-shrinking arm**: Phase 1's verdict does
  not establish run-level monotonicity. Mark Phase 2 `[BLOCKED]`, and route the finding to Phase 10
  as an open exposure.
- **Phase 4 finds `Decidable.lean` needs proof edits**: stop, escalate the file-scope expansion, and
  do not proceed to Phase 5 without it being accepted.
- **A phase leaves the build red**: fix forward per `.claude/rules/error-handling.md`. Never discard
  uncommitted changes to reach a green build; snapshot via `.claude/scripts/git-snapshot.sh 437`
  before any intentional rollback.
- **Whole-task revert**: every phase after Phase 4 is confined to the files listed in its own
  "Files to modify". Phase 5 is a single arm in a single file, so reverting the engine change alone
  restores the pre-task behavior while leaving Phases 1-3's additive `MintBound.lean` work — which
  is a standalone decided result — intact.
