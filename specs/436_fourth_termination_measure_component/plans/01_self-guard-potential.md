# Implementation Plan: The fourth termination-measure component (`selfGuardPotential`)

- **Task**: 436 - fourth_termination_measure_component
- **Status**: [IMPLEMENTING]
- **Effort**: 12 hours
- **Dependencies**: 435 (literature sub-index curation, [COMPLETED])
- **Research Inputs**: `specs/436_fourth_termination_measure_component/reports/01_fourth-measure-component.md`
- **Artifacts**: plans/01_self-guard-potential.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/plan-format-enforcement.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/lean4.md
  - .claude/rules/plan-compliance.md
- **Type**: lean4

---

## Overview

`MintPaysForTime` is refuted as stated (`mintPaysForTime_untlNeg_false`, `MintBound.lean:7110`),
and both obvious repairs are closed by decided statements (do-not-re-attempt register entry 14,
`MintBound.lean:7501-7525`). What is missing is a **fourth measure component** paying for the
self-guarded minting rules that also survives the ordered split's identification arm. This plan
lands the researched design — **Candidate 2, `selfGuardPotential` over `selfGuardRules ×ˢ U`** —
into the single file `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`,
additively, sorry-free and axiom-free, following the parent plan's Phase 7-8 task lists
(`specs/434_discharge_mintpaysfortime_residual/plans/01_mintpaysfortime-time-analogue.md:544-681`).

**The plan opens with a refute-first gate.** The research's own adversarial-verification pass
could not discharge one exposure: the σ-hit obligation that register entry 15 decides **false**
(`MintBound.lean:7527-7541`) is inherited by `selfGuardPotential` in a weakened *time-hit* form,
and the research could not verify that the weakening escapes it. Phase 1 decides that question at
the `nextTime_reissues_retired_time` configuration **before any plumbing lemma is written**,
because it is cheap relative to the plumbing and is the single highest-information action
available. A `False` verdict means the recommendation is wrong, and the deliverable becomes a
decided negative result landed as register entry 17 — not a weaker substitute landed under the
deliverable's name.

**Definition of done** (contingent on Phase 1 deciding `True`): `MintPaysForTimeAt` defined with
its direction lemma `mintPaysForTimeAt_of_mintPaysForTime` and no new terminus hypothesis; the
four-component measure `budgetPotentialAt` with both step lemmas re-proved at it; the two
seed-level termini restated at the repaired shape; the repaired predicate discharged at
`U = signedUniverse C L`; full `lake build` green; `Saturation.lean`, `Fuel.lean`, `Tableau.lean`
untouched; no previously-landed declaration in `MintBound.lean` altered.

### Preserved Assets

The following work is complete and must not regress. All of it lives in
`FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` unless stated otherwise.

| Component | Location | Status | Note |
|-----------|----------|--------|------|
| Parent Phase 1: time-minting rule census (`freshTimeRules`, `mem_freshTimeRules`) | `MintBound.lean:6380-6412` | [COMPLETED] | Anti-drift guarantee for the nine-rule list |
| Parent Phase 2: time-coordinate plumbing | `MintBound.lean:6413-6568` | [COMPLETED] | |
| Parent Phase 3: `applyRule_emitted_time_mem` | `MintBound.lean:6569-6789` | [COMPLETED] | Needs `OrdTimesKnown` (register entry 16) |
| Parent Phase 4: verdict on `MintPaysForTime` as stated | `MintBound.lean:7051-7136` | [COMPLETED] | `mintWitness*` scaffolding + `mintPaysForTime_untlNeg_false` + `mintPaysForTime_empty` |
| Parent Phase 5: time dichotomy and engine lift | `MintBound.lean:6790-6995` | [COMPLETED] | |
| Parent Phase 6: time-reuse verdict | `MintBound.lean:7246-7354` | [COMPLETED] | `rho_src_ne_src`, `rhoSF_time_ne_src`, `mint_not_in_rhoSF_image`, `nextTime_reissues_retired_time`, `reuseStep`/`reuseWitness*`, `reuse_driven_through_engine` |
| Parent Phase 7 refutations | `MintBound.lean:7137-7245` | [COMPLETED] | `splitOrderedRank_lt_of_knownTimes_lt`, `mintPaysForTime_rank_repair_false` |
| Parent Phase 9: C9 register, 16 entries | `MintBound.lean:7355-7552` | [COMPLETED] | Must remain the file's final block |
| `identifyTime_no_collapse` | `MintBound.lean:231-251` | [COMPLETED] | The load-bearing lemma for Phase 3 below |
| `witnessPresent_identifyTime` | `MintBound.lean:644` | [COMPLETED] | Proof template for Phase 3 below |
| `mintPotential` / `_le_eight_mul` / `_le_of_grow` | `MintBound.lean:2971-2999` | [COMPLETED] | Proof template for Phase 2 below; **byte-unchanged** |
| `budgetPotential` and both step lemmas | `MintBound.lean:3883-3887`, `4693-4758`, `4768-4835` | [COMPLETED] | **Byte-unchanged**; the new measure is additive |
| `MintPaysForTime` and all consuming sites | `MintBound.lean:4031-4042` and 11 sites | [COMPLETED] | **Byte-unchanged** |

### Source-to-Implementation Mapping (H3, Tier 1)

Carried forward from the research report §4; do not re-derive. Chunk paths are absolute.

| Source | Chunk | Claim drawn | Lean shape it justifies | Confidence |
|---|---|---|---|---|
| Massacci 2000, Technique 8.2 | `/home/benjamin/Projects/Literature/sources/massacci_2000_single_step_tableaux_for_modal_logics/chunk_0026.md:20` | "Before reducing a π-formula, check whether the corresponding reduction already exists" — the defect-already-cured test | `selfGuardDischarged` transcribes each rule's own guard in **inverted polarity**, with catch-all `true`; the idiom `witnessPresent` already uses | High (verified_conversion) |
| Massacci 2000, Technique 8.3 / Lemma 8.3 / Thm 8.4 | `.../chunk_0028.md:35-37`, `chunk_0029.md:3-4`, `chunk_0030.md:1-8, 28-31` | Termination follows from measuring the rule's own self-discharge, not from measuring its cap | The component is stated against `ord.futureOf`/`pastOf` emptiness, deliberately **not** against `ord.timeCount` (which `identifyTime` lowers) | High (verified_conversion) |
| Caleiro-Viganò-Volpe 2013, §3.1 | `/home/benjamin/Projects/Literature/sources/caleiro_2013/sec03_31-mosaics.md:18-21, 26-31, 42-55` | The bound is over a finite closure set `Λ`, never over the number of time points | The index set is `selfGuardRules ×ˢ U`, fixed across the run, mirroring `mintPotential`'s `freshLabelRules ×ˢ U` | High (verified_conversion) |
| Caleiro-Viganò-Volpe 2013, §4.3 | `.../sec07_43-decidability-via-mosaics.md` (Thm 4.11 + closing remark) | Decidability requires "properly avoiding the repeated curing of the same defect" | The fourth component is a **second** defect ledger with its own defect notion, not a widening of the first (this is what separates it from register entry 14 route 1) | High (verified_conversion) |
| Caleiro-Viganò-Volpe 2013, SVDns | `.../sec03_31-mosaics.md:80` | Density (SVDns) is a saturation clause **separate** from the eventuality clauses SV1-SV4 | `densityRule`'s coordinate is a separate component (`gapPotential`, Candidate 3) and is a named residual of this plan, not part of it | High (verified_conversion) |
| Gerth 1995 / Baier-Katoen 2008 | `baier_katoen_2008` chunks `2cbdea06b931a75d`, `6887c5785c91627c` | LTL automaton state space is elementary subsets of `closure(φ)` | Corroborates the ceiling shape `≤ k · |U|` for fixed small `k`; here `k = 2` | Medium — FTS snippets only; **not load-bearing alone** |
| Venema 2001 §5 | `/home/benjamin/Projects/Literature/sources/venema_2001/` | Interval/gap accounting is indexed by pairs | Only relevant to the deferred `gapPotential`; the pair-indexing conclusion is independently forced by `densityRule`'s docstring (`Tableau.lean:1339-1356`) | **Low / UNVERIFIED** — not consulted end-to-end; nothing here rests on it |

**Named literature gap (carried, not papered over)**: no corpus source has a merge/identification
step. The mosaic method never merges points. Every identification-preservation argument in this
plan (Phase 3) is **repo-internal** and rests on `identifyTime_no_collapse`, not on literature.

---

## Postmortem Constraints

Binding on every implementation dispatch. Derived from the 16-entry C9 register, the parent plan's
Phase 7 blocker, and the research report's adversarial-verification pass.

**Do NOT**:

- **Re-index `mintPotential` on `freshTimeRules`.** Register entry 14 route 1. Closed by
  `witnessPresent_eq_false_of_not_freshLabel` (`MintBound.lean:7042`): `witnessPresent`'s match has
  exactly eight arms, so the added columns are permanently `false` and contribute a constant
  `3·|U|`. `mintPotential` stays byte-unchanged.
- **Drop disjunct 1's cardinality conjunct and rely on the ordering-rank conjunct.** Register entry
  14 route 2. Closed by `splitOrderedRank_lt_of_knownTimes_lt` (`MintBound.lean:7192`) and
  `mintPaysForTime_rank_repair_false` (`MintBound.lean:7217`). Both existing disjuncts are retained
  **verbatim** in `MintPaysForTimeAt`; a third is added.
- **Propose any component affine in `b.knownTimes.toFinset.card`.** Corollary (F′): a self-guarded
  mint raises that count and the identification arm lowers it, so no sign of coefficient satisfies
  both. This kills Candidate 1 (`timeSlotDeficit`) and every variant of it, including anything that
  reduces to re-coefficienting `splitOrderedRank`'s first summand.
- **State the component against `ord.timeCount`.** `TimeOrdering.identifyTime` lowers it; that is
  precisely the obstruction the parent plan's Phase 7 blocker names. Candidate 2 measures the
  *discharge*, not the *cap*, and must not mention `timeCount`.
- **Use "branch times with empty forward reach" as the potential.** Refuted in prose at
  `MintBound.lean:7166-7168`: the arm removes the trigger's empty future and mints a fresh time
  whose future is empty, net change zero. `selfGuardPotential` is indexed by the fixed set
  `selfGuardRules ×ˢ U` through `σ`, does not take `b`, and counts columns, not times.
- **Let the fourth component rise at the identification arm, even by one unit.** Constraint (F),
  derived from `budgetPotential_step_splitOrdered`'s arm-3 `omega` inputs
  (`MintBound.lean:4812-4835`): the guaranteed strict-drop margin there is one unit of
  `splitOrderedRank`, while paying for a mint requires weight `≥ 2·Tmax²+1`. Rescaling
  `splitOrderedRank` does not rescue it — the mint-side rise scales identically.
- **Attempt an `IrreflOrd`-free identification-preservation lemma.** Register entry 5;
  `witnessPresent_identifyTime_unconditional_false` (`MintBound.lean:143`) is the refutation for the
  sibling predicate.
- **Refute the design by instantiating σ with a function unconstrained by the run.** σ is
  universally quantified in `MintPaysForTime`'s statement with no tying hypothesis, so an
  adversarial σ defeats *any* σ-mediated potential and teaches nothing.
  `mintPaysForTime_untlNeg_false` sets the discipline by using the most favorable available σ
  (`id`, `MintBound.lean:7113`). Phase 1's gate must use a **run-realizable** σ — the `rhoSF` the
  identification itself produces.
- **Cover `densityRule` in this task.** Candidate 3 (`gapPotential`) is `denseRules`-gated
  (`Tableau.lean:1593, 1626`) and quadratic in `|U|`. It is the right *second* component and is
  carried here as a named residual (Phase 10). Do not widen `selfGuardRules` to include it.
- **Alter any previously-landed declaration.** Additive only. `MintPaysForTime`, `mintPotential`,
  `budgetPotential`, `budgetPotential_step_unordered`, `budgetPotential_step_splitOrdered`,
  `mintPathBound`, `mintAwareFuel` and every existing terminus stay byte-unchanged. New measure
  work lands as new `*At` siblings alongside them.
- **Edit `Saturation.lean`, `Fuel.lean`, or `Tableau.lean`.** `file_scope` is exactly one file.
- **Use `sorry`, `def X := True`, `theorem X := trivial`, or any vacuous placeholder.** The task
  record requires sorry-free and axiom-free at completion, which rules out the strategic-sorry
  skeleton path entirely. If a phase cannot be completed as written, mark it `[BLOCKED]` and
  escalate per `.claude/rules/plan-compliance.md`.
- **Append below the C9 register.** C9 (`MintBound.lean:7355-7552`) must remain the file's final
  block before `end FormalSystem.Metalogic.Decidability`. All new declarations go in a new
  subsection of D2, inserted immediately **before** the `/-! ## C9` line.

**MUST preserve**:

- Every declaration in the Preserved Assets table above, verbatim.
- All 16 existing C9 entries and their wording. New entries are appended and the opening count
  ("Sixteen statements") is updated in the same edit — that docstring text is the one exception to
  the do-not-alter rule, and it is explicitly sanctioned by the task record.
- Full `lake build` green at every phase boundary that declares it.

**Design decisions are SETTLED** (do not re-open without a concrete counterexample):

- **Candidate 2 is the design.** Candidate 1 is refuted by (F′); Candidate 3 is deferred as the
  density coordinate. Do not re-survey the design space.
- **`MintPaysForTimeAt` is a weakening** of `MintPaysForTime` — a third disjunct added, nothing
  removed. The direction lemma is therefore `mintPaysForTimeAt_of_mintPaysForTime`, and every
  theorem restated against it is a **strengthening**. This is the
  `universeClosedAt_of_universeClosed` idiom (`MintBound.lean:5332`), used twice already in this
  file.
- **Identification preservation routes through `identifyTime_no_collapse` + `firstIncomparablePair_spec`.**
  Do not seek a different argument. The chain is: `firstIncomparablePair_spec` (`Fuel.lean:1023-1026`)
  ⇒ `incomparableB ord (t₁,t₂)` (`Fuel.lean:1044-1045`) ⇒ `identifyTime_no_collapse`
  (`MintBound.lean:231-251`) ⇒ no constraint dropped ⇒ `futureOf` non-emptiness transports via
  `mem_futureOf_of_mem_constraints` (`MintBound.lean:215`).
- **`MintPaysForTime` never quantifies over the identification arm.**
  `unorderedSuccessorBranches` excludes `.splitOrdered` by construction (`MintBound.lean:1048-1051`),
  and `budgetPotential_step_splitOrdered` carries no `MintPaysForTime` hypothesis. The preservation
  requirement therefore lands on the **measure** (Phase 7), not on the repaired predicate.
- **`densityRule` IS inside `MintPaysForTimeAt`'s scope**, via `.persistent → .extended`
  (`Tableau.lean:1385` + `MintBound.lean:1071`). It is not excluded by being non-branching. This is
  exactly why the deliverable is the frame-class-universal half plus a named residual, not a closed
  result.
- **The fuel-figure enlargement is not a new hypothesis.** Adding a fourth component forces
  `mintPathBound`/`mintAwareFuel` to absorb `2·(Tmax²+1)·2·|U|`. That is an arithmetic enlargement
  of the kind `splitAwareFuel_le_mintAwareFuel` already records (register entry 8), not a new
  assumption on any caller.

---

## Goals & Non-Goals

**Goals**:
- Decide, first and cheaply, whether the inherited σ-hit exposure refutes the recommended design.
- Land `selfGuardPotential` with its ceiling, growth-monotonicity, and identification-preservation
  lemmas.
- Land `MintPaysForTimeAt` with a machine-checked direction lemma and a confirmation that it leaks
  no new hypothesis into the terminus.
- Land the four-component measure `budgetPotentialAt` with both step lemmas re-proved at it.
- Restate the two seed-level termini at the repaired shape and discharge the repaired predicate at
  `U = signedUniverse C L`.
- Record any further refuted route as a new C9 register entry.

**Non-Goals**:
- Covering `densityRule` (Candidate 3, `gapPotential`). Explicitly a named residual.
- Closing `MintPaysForTime` itself. The repaired predicate remains a **named hypothesis**, per
  register entry 14's own instruction that the σ-hit residual be carried structurally rather than
  discharged (`MintBound.lean:7271`).
- Any change to the three excluded files, or to any landed declaration.
- Any use of the strategic-sorry skeleton path — forbidden by the task's sorry-free requirement.

---

## Risks & Mitigations

- **R1 (highest) — the inherited σ-hit obligation.** `selfGuardPotential`'s strict drop needs the
  trigger's time `l.time` to equal `(σ x).label.time` for some `x ∈ U`. Register entry 15 decides
  that σ's image omits merged-away times and that the engine re-issues them. The weakening from a
  *formula* hit to a *time* hit may or may not escape this; the research could not verify it.
  **Mitigation**: Phase 1 is a refute-first gate with a binary verdict and an explicit
  refuted-branch route. No plumbing is written before the verdict.
- **R2 — the "freshly minted time contributes no new uncured column" claim.** Argued, not decided.
  Rests on `freshTime = b.nextTime` being absent from the ordering's endpoints pre-step, which needs
  `OrdTimesKnown` plus `nextTime > maxTime`. **Mitigation**: Phase 4 must land this as an explicit
  named lemma before the `untlNeg` discharge lemma, not assume it inline.
- **R3 — Constraint (F) is an argument, not a landed lemma.** The research derived it from arm 3's
  `omega` inputs but did not machine-check it. **Mitigation**: Phase 7 tests it directly by proving
  `selfGuardPotential`'s non-increase at arm 3 *before* attempting the arm-3 inequality; if the
  non-increase fails, the phase is `[BLOCKED]`, not worked around by re-weighting.
- **R4 — Phases 7-9 are the least well-scoped.** Re-proving both step lemmas at a four-component
  measure and re-deriving the fuel chain touches the heaviest proofs in the file (each existing step
  lemma is 65-70 dense lines, with `_at` variants at `MintBound.lean:5400` and `5471`).
  **Mitigation**: they are split across three phases, section C6's fuel induction is already
  parameterized over an abstract measure (`MintBound.lean:3524-3779`) which should make
  re-instantiation cheap, and each phase declares an independent green criterion so a stall in one
  does not invalidate the others.
- **R5 — phase budget.** Ten phases is at the stated ceiling (MAX_CYCLES 13, 2 consumed). **This is
  stated rather than hidden.** If Phase 1 decides `False`, the task collapses to Phases 1 and 10 and
  the budget is ample. If Phase 1 decides `True` and any of Phases 7-9 overruns, the correct
  outcome is a `[PARTIAL]` phase plus a named residual — **not** a silently oversized phase and
  **not** an un-restated terminus landed under the deliverable's name.
- **R6 — density remains open** at `.Dense`/`.Dedekind`. A `MintPaysForTimeAt` carrying only the
  `selfGuardPotential` disjunct is still refutable there by a `densityRule` vehicle. **Mitigation**:
  Phase 10 states this as a named residual in the predicate's own docstring obligation map, in the
  voice `UnorderedSuccessorLabelClosed`'s docstring uses.

---

## Implementation Phases

All phases modify exactly one file:
`FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`. All new declarations go
into a new subsection of section D2, inserted immediately **before** the `/-! ## C9` register block.

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |
| 5 | 6 | 4, 5 |
| 6 | 7 | 3, 6 |
| 7 | 8 | 7 |
| 8 | 9 | 8 |
| 9 | 10 | 9 |

Phases 2 and 3 are independent of each other and may execute in parallel if the orchestrator
dispatches a parallel wave; every other wave is sequential. **Phase 1 gates the entire plan**: a
`False` or undecided verdict there routes directly to Phase 10 and marks Phases 2-9 `[BLOCKED]`.

---

### Phase 1: Refute-first gate on the inherited sigma-hit obligation [COMPLETED]

**VERDICT: FALSE.** Decided at the first gate configuration (attempt budget 3, one used). The
recommended design does **not** survive the σ-hit hazard. Per the plan's own Rollback/Contingency
section this is a *successful* phase outcome, not a failure: Phases 2-9 are `[BLOCKED]` citing this
phase, and the task routes to Phase 10 for register entry 17.

**What landed** (`MintBound.lean`, new D2 subsection immediately before `/-! ## C9`, +144 lines,
against the plan-time estimate of ~200-250):

- `selfGuardRules`, `selfGuardRules_card`, `selfGuardDischarged`, `selfGuardPotential`,
  `MintPaysForTimeAt` — all four definitions, as specified.
- `selfGuard_no_column_at_retired_time` — the **general** half of the verdict.
- `gateTrigger`, `gateBranch`, `gateOrd`, `gateUniverse`, `gateSucc`, `gateNewOrd`, `gateSigma`;
  `gate_runInvariant`, `gate_confined`, `gate_is_reissue_hazard` (seven decided conjuncts),
  `gate_step_fires`.
- `selfGuardPotential_lt_at_gate_with_id`, `selfGuardPotential_eq_at_gate_with_sigma` — the
  discriminating pair.
- `mintPaysForTimeAt_reuse_false` — the verdict theorem, at every frame class and every `Tmax`.

**Why FALSE.** `rhoSF_time_ne_src` is already a statement about *times*: `(rhoSF src tgt sf).label
.time ≠ src` for every `sf`. Register entry 15's formula-hit refutation (`mint_not_in_rhoSF_image`)
is a three-line corollary of it. So weakening the obligation from a formula hit to a *time* hit
weakens nothing the refutation depended on — the curing edge `untlNeg`'s ACTIVE arm adds is anchored
at the trigger's time, and when that time is one an earlier identification retired, no column of
`selfGuardRules ×ˢ U` is indexed there at all.

**Measured at the gate** (σ = `rhoSF 2 0`, the renaming the identification itself produces):
`knownTimes` 3 → 4 (disjunct 1's first conjunct `4 ≤ 3` false); `mintTimeBudget` 27 → 28 and
`mintPotential` 24 → 24 (both of disjunct 2's conjuncts false); `selfGuardPotential` 3 → 3
(disjunct 3's `3 < 3` false).

**The refutation is attributable to σ, not to an inert component.** At the same step with `σ = id`
the potential *does* drop, 4 → 3 (`selfGuardPotential_lt_at_gate_with_id`). The failure is located
exactly at the σ-hit obligation, and `gate_is_reissue_hazard` decides all seven preconditions so it
is not attributable to a violated hypothesis either.

**Scope Hypothesis confirmed:** one configuration, not three; +144 lines, not 200-250. Recorded per
the phase's own instruction rather than silently absorbed.

- **Goal:** Decide, before any plumbing lemma exists, whether `MintPaysForTimeAt` survives at the
  configuration register entry 15 identifies as the σ-hit hazard. This phase produces a **binary
  verdict** that determines whether the rest of the plan executes at all.

- **Tasks:**
  - [ ] Open a new subsection `/-! ### The fourth measure component: the self-guard discharge
        potential` immediately before `/-! ## C9` (`MintBound.lean:7355`).
  - [ ] Define `selfGuardRules : Finset TableauRule := {TableauRule.untlNeg, TableauRule.snceNeg}`.
        Docstring must state it is deliberately **not** `freshTimeRules` and **not** a widening of
        `freshLabelRules`, citing register entry 14.
  - [ ] Define `selfGuardDischarged (r : TableauRule) (sf : SignedFormula) (ord : TimeOrdering) :
        Bool` — `.untlNeg => !(ord.futureOf sf.label.time).isEmpty`,
        `.snceNeg => !(ord.pastOf sf.label.time).isEmpty`, `_ => true`. The catch-all is `true`, the
        **mirror image** of `witnessPresent`'s polarity; docstring must say why (a column outside the
        index set would be permanently cured and contribute `0`, whereas entry 14's route 1 died
        because its added columns were permanently uncured). Guards are transcribed from
        `Tableau.lean:1016, 1063` (`untlNeg`) and `Tableau.lean:1147, 1163` (`snceNeg`). Do **not**
        mention `ord.timeCount`.
  - [ ] Define `selfGuardPotential (U : Finset SignedFormula) (σ : SignedFormula → SignedFormula)
        (ord : TimeOrdering) : Nat := ((selfGuardRules ×ˢ U).filter (fun p =>
        selfGuardDischarged p.1 (σ p.2) ord = false)).card`. It deliberately does **not** take `b`.
  - [ ] Define `MintPaysForTimeAt (fc) (U) (Tmax) : Prop` — `MintPaysForTime`'s body
        (`MintBound.lean:4031-4042`) copied verbatim with a **third disjunct** added:
        `selfGuardPotential U σ (expandOnceUnblocked b ord fc tr).2 < selfGuardPotential U σ ord`.
        Definition only in this phase; the direction lemma and the full obligation-map docstring are
        Phase 6.
  - [ ] Build the gate configuration. Extend the `reuseWitnessBranch`/`reuseWitnessOrd` shape
        (`MintBound.lean:7335-7344`) so that **after** the identification `2 → 0`, the branch carries
        an `untlNeg` trigger at the re-issued time `2` whose ACTIVE arm fires. Reuse
        `mintWitnessTrigger`'s formula shape `F(U(e,g))` (`MintBound.lean:7069`). Name the pieces
        `gateBranch`, `gateOrd`, `gateUniverse` following the `mintWitness*` naming.
  - [ ] Prove the configuration is a genuine hazard, in the six-conjunct style of
        `nextTime_reissues_retired_time` (`MintBound.lean:7309-7322`): `IrreflOrd`, `OrdTimesKnown`,
        `firstIncomparablePair` selects the pair, the re-issued time equals the retired one, the
        trigger sits at that time, and the ACTIVE arm fires. Without these conjuncts a negative
        verdict is attributable to a violated precondition rather than to the arm.
  - [ ] Instantiate `σ := rhoSF 2 0` — the renaming the identification itself produces. This is the
        **most favorable run-realizable** σ, mirroring `mintPaysForTime_untlNeg_false`'s use of `id`
        (`MintBound.lean:7113`). An adversarial σ is a forbidden shortcut (see Postmortem
        Constraints).
  - [ ] Decide the gate: whether all three disjuncts of `MintPaysForTimeAt` fail at this
        configuration, by `decide`, quantified over the frame class in the four-case style of
        `mintPaysForTime_untlNeg_false` (`MintBound.lean:7115-7122`).
  - [ ] Land the verdict as a named theorem and record it in a docstring that states the verdict in
        words.

- **Verdict criteria (binary, with an explicit undecided branch):**
  - **TRUE** (the third disjunct holds at the gate configuration): land
    `selfGuardPotential_lt_at_reissued_time` with a docstring stating that the time-hit weakening
    escapes register entry 15's formula-hit refutation. **Proceed to Phase 2.**
  - **FALSE** (all three disjuncts fail): land `mintPaysForTimeAt_reuse_false :
    ¬ MintPaysForTimeAt fc gateUniverse Tmax`. **The recommendation is wrong.** Mark Phases 2-9
    `[BLOCKED]` with this phase named as the blocker, jump to Phase 10, land the outcome as C9
    **register entry 17** following the existing convention (declaration name + refuting witness,
    never an issue number), and report back. Do not build further on a refuted design.
  - **UNDECIDED** (no configuration satisfying the hazard conjuncts is constructible within the
    attempt budget, or `decide` does not evaluate): close the phase `[BLOCKED]`, record the closest
    configuration reached and exactly which conjunct failed, land register entry 17 as an *open*
    exposure rather than a refutation, and report back. **Do not proceed to Phase 2 on an untested
    design.**

- **Attempt budget:** at most **three** distinct gate configurations. If none of the three both
  (a) satisfies `RunInvariant` and the hazard conjuncts and (b) fires a self-guarded ACTIVE arm at
  the re-issued time, take the UNDECIDED branch. Do not spend the phase widening the search.

- **Estimated output:** ~200-250 lines.
- **Timing:** 2 hours
- **Depends on:** none
- **Verification Tier:** local
- **Commit Mode:** per-substep
- **Scope Hypothesis:** "at most three gate configurations" and "~200-250 lines" are plan-time
  estimates, not facts. Confirm at implementation time by recording the actual configuration count
  and the actual diff size in the phase's commit message; if the first configuration decides the
  gate, say so rather than constructing the other two.
- **Done when:** the gate theorem is sorry-free, `lake build
  FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound` is green, and the verdict
  (TRUE / FALSE / UNDECIDED) is stated in words in the theorem's docstring and in the phase's
  progress record.

---

### Phase 1R: Re-gate at the oriented identification arm [IN PROGRESS]

**RESUMPTION.** Phase 1's FALSE verdict was decided against `gateSigma = rhoSF 2 0`, the renaming
the identification arm produced *at the time the gate was built*. The spawned blocker task has
since reoriented arm 3 to merge `min t₁ t₂` into `max t₁ t₂` (C9 register entry 18), so at the
reuse witness's own trigger `(0, 2)` the arm now produces `rhoSF 0 2` and **no run produces
`rhoSF 2 0` there any more**. Entry 18 says so in its own closing paragraph: entry 17's refutation
"stands as a statement **about the unoriented arm**", and whether a measure-side component is now
provable "is a genuinely open follow-on question".

This phase re-runs Phase 1's gate at the renaming the oriented arm actually hands back, with the
same refute-first discipline and the same binary verdict criteria. It is Phase 1's own methodology
re-executed against a changed engine, not a new design.

- **Goal:** Decide whether Phase 1's FALSE verdict survives the oriented arm, and if it does not,
  identify the minimal hypothesis that excludes the Phase-1 gate configuration without excluding
  any state the engine can reach.

- **Tasks:**
  - [ ] Land the converse of `selfGuard_no_column_at_retired_time`: at any time *other* than the
        retired one a column of `selfGuardRules ×ˢ U` **is** indexed, because `rhoSF src tgt` fixes
        every time but `src`.
  - [ ] Land the general reason the oriented arm escapes the σ-hit obligation: the post-arm branch
        carries no formula at the retired index (`src_not_mem_knownTimes_identifyTime`), so the
        arm's own renaming fixes the time of **every formula the branch still carries**.
  - [ ] Name that property (`SigmaTimeStable`) and land the repaired predicate carrying it.
  - [ ] Build the oriented gate: the post-oriented-arm state at the reuse witness, with an
        `untlNeg` trigger whose ACTIVE arm fires, in the `gate*` shape.
  - [ ] Measure all three disjuncts there, and measure `SigmaTimeStable` at both gates so the
        exclusion is decided rather than asserted.
  - [ ] State the verdict in words in a docstring.

- **Verdict criteria (binary):** TRUE — disjunct 3 holds at the oriented gate and the Phase-1 gate
  is excluded by a hypothesis the engine discharges: unblock Phases 2-9. FALSE — the FALSE verdict
  survives: leave Phases 2-9 blocked and record a new register entry.

- **Verification Tier:** local
- **Done when:** the verdict theorems are sorry-free, `lake build` of the module is green, and the
  verdict is stated in words.

---

### Phase 2: Index-set agreement, the ceiling, and growth monotonicity [COMPLETED]

**BLOCKER RESOLVED** (Phase 2): the Phase 1 blocker named "a discharge of the σ-hit obligation itself" as the unblock condition. Phase 1R supplies it: at the renaming the *oriented* identification arm produces, the obligation is met at every trigger the engine can select (`sigmaTimeStable_identifyOriented`), and the self-guard potential falls at the very configuration that refuted it. Phase 1's verdict was a statement about the unoriented arm and does not survive the reorientation.

- **Goal:** Give `selfGuardPotential` the two structural facts every consumer needs — a linear
  ceiling and non-increase under growth — by transcribing the already-landed `mintPotential`
  siblings.

- **Tasks:**
  - [x] `mem_selfGuardRules {r : TableauRule} : r ∈ selfGuardRules ↔ (r = .untlNeg ∨ r = .snceNeg)`,
        the anti-drift guarantee mirroring `mem_freshLabelRules` (`MintBound.lean:2960`) and
        `mem_freshTimeRules` (`MintBound.lean:6387`).
  - [x] `selfGuardPotential_le_two_mul (U) (σ) (ord) : selfGuardPotential U σ ord ≤ 2 * U.card`.
        Transcribe `mintPotential_le_eight_mul` (`MintBound.lean:2978-2987`); the coefficient is the
        index set's width.
  - [x] `selfGuardDischarged_le_of_grow`: if `ord.constraints ⊆ ord'.constraints` then
        `selfGuardDischarged r sf ord = true → selfGuardDischarged r sf ord' = true`. Consumes
        `futureOf_mono` (`Fuel.lean:914`) and `pastOf_mono` (`Fuel.lean:926`). Note `addFuture` /
        `addPast` only cons onto `ord.constraints` (`SignedFormula.lean:685-690`), which is what
        supplies the hypothesis at every call site.
  - [x] `selfGuardPotential_le_of_grow`: under the same ordering-growth hypothesis,
        `selfGuardPotential U σ ord' ≤ selfGuardPotential U σ ord`. Transcribe
        `mintPotential_le_of_grow` (`MintBound.lean:2988-2999`) — same `Finset.card_le_card` +
        filter-subset skeleton. Note this sibling needs **only** the ord-grow half, not the
        branch-grow half, because `selfGuardPotential` does not take `b`.

- **Estimated output:** ~130-180 lines.
- **Timing:** 1.5 hours
- **Depends on:** 1
- **Verification Tier:** local
- **Commit Mode:** per-substep
- **Done when:** all four declarations sorry-free, module build green, and no existing declaration
  in the file appears in `git diff` except as context.

---

### Phase 3: Preservation across the identification arm [COMPLETED]

**BLOCKER RESOLVED** (Phase 3): the Phase 1 blocker named "a discharge of the σ-hit obligation itself" as the unblock condition. Phase 1R supplies it: at the renaming the *oriented* identification arm produces, the obligation is met at every trigger the engine can select (`sigmaTimeStable_identifyOriented`), and the self-guard potential falls at the very configuration that refuted it. Phase 1's verdict was a statement about the unoriented arm and does not survive the reorientation.

- **Goal:** The discriminating property, and the one Constraint (F) turns on: `selfGuardPotential`
  does not rise across `TimeOrdering.identifyTime` at an incomparable trigger. This is the crux
  phase; its argument is repo-internal (no literature support — see the named gap above).

- **Tasks:**
  - [x] `selfGuardDischarged_identifyTime`: given `IrreflOrd ord` and
        `incomparableB ord (t₁, t₂)`, if `selfGuardDischarged r sf ord = true` then
        `selfGuardDischarged r (rhoSF t₂ t₁ sf) (ord.identifyTime t₂ t₁) = true`. Follow the proof
        template of `witnessPresent_identifyTime` (`MintBound.lean:644`), which is the same statement
        for the sibling predicate and needs the same `IrreflOrd`.
  - [x] The argument, in the three steps the research fixed — do not substitute another:
        (1) **no constraint is dropped**: `identifyTime_no_collapse` (`MintBound.lean:231-251`) gives
        `rho t₂ t₁ a ≠ rho t₂ t₁ b` for every `(a,b) ∈ ord.constraints`, and
        `TimeOrdering.identifyTime`'s `filterMap` discards only when `a' == b'`
        (`SignedFormula.lean:707-710`);
        (2) **non-emptiness transports**: take the first edge on a witnessing path; its image is in
        the identified ordering's constraints, so reachability follows from
        `mem_futureOf_of_mem_constraints` (`MintBound.lean:215`) / `mem_pastOf_of_mem_constraints`
        (`MintBound.lean:223`) at `n = 1` — a **single edge**, so `futureOf`'s fuel bound of `100` is
        not consumed;
        (3) `rhoSF` acts on the label's time by `rho` (`MintBound.lean:67`), so the column index
        lines up.
  - [x] `selfGuardPotential_identifyTime`: under the same hypotheses,
        `selfGuardPotential U (rhoSF t₂ t₁ ∘ σ) (ord.identifyTime t₂ t₁) ≤ selfGuardPotential U σ ord`.
        The filter's true-set only grows, so this is `Finset.card_le_card` over the previous lemma.
  - [x] Docstring must state that this is **Constraint (F) discharged with equality-or-better** and
        that it is what separates Candidate 2 from every `knownTimes.card`-affine component.
  - [x] Note in the docstring that `incomparableB ord (t₁,t₂)` is available at the consuming site
        from `firstIncomparablePair_spec` (`Fuel.lean:1023-1026`), whose last two conjuncts are
        literally `incomparableB`'s two clauses (`Fuel.lean:1044-1045`). Do not add a new hypothesis
        for it.

- **Estimated output:** ~200-280 lines.
- **Timing:** 2.5 hours
- **Depends on:** 1
- **Verification Tier:** local
- **Commit Mode:** per-substep
- **Done when:** both lemmas sorry-free, module build green, `lean_verify` on
  `selfGuardPotential_identifyTime`'s fully qualified name reports no `sorryAx`.

---

### Phase 4: The `untlNeg` discharge lemma [BLOCKED]

**BLOCKER** (Phase 4): blocked by Phase 1's FALSE verdict. `mintPaysForTimeAt_reuse_false` decides `MintPaysForTimeAt` false at the σ-hit hazard, at every frame class and every `Tmax`, with the most favorable run-realizable σ. `selfGuard_no_column_at_retired_time` gives the general reason, so no other configuration escapes it. Building plumbing for a refuted design is forbidden by the plan's own Rollback/Contingency section. **What is needed to unblock**: a fourth measure component whose index set is not carried through σ at all, or a discharge of the σ-hit obligation itself — which the time-reuse verdict decides is false, not open.

- **Goal:** Prove that the `untlNeg` ACTIVE arm strictly drops `selfGuardPotential`. This phase
  establishes the proof skeleton that Phase 5 mirrors.

- **Tasks:**
  - [ ] First land the R2 lemma the research flagged as argued-but-unverified, as its own named
        declaration: the freshly minted time `b.nextTime` is absent from the ordering's endpoints
        before the step, hence its own column is already uncured and no column flips on its account.
        Consumes `OrdTimesKnown` (`MintBound.lean:1260-1261`) plus `nextTime = maxTime + 1 >` every
        known time (`SignedFormula.lean:349-381`). Do **not** inline this into the discharge proof.
  - [ ] `selfGuardPotential_lt_of_untlNeg`: at an `untlNeg` ACTIVE step, given the trigger is
        σ-hit on its time (the hypothesis Phase 1 decided is satisfiable), the potential strictly
        drops. Mechanism, from the source's own statement (`Tableau.lean:1057-1058`): the arm fires
        only when `(ord.futureOf l.time).isEmpty` (`Tableau.lean:1016, 1063`), and its own
        `newOrd = ord.addFuture l.time freshTime` (`Tableau.lean:1071`) puts `freshTime` into
        `futureOf l.time` via `mem_futureOf_of_mem_constraints` — so the trigger's column flips
        uncured → cured.
  - [ ] Combine with `selfGuardPotential_le_of_grow` (Phase 2) to show no other column un-cures, so
        the flip is a net strict decrease rather than an exchange.
  - [ ] Docstring: name the σ-hit hypothesis explicitly and cite Phase 1's gate theorem as the
        evidence that it is not vacuous. Per register entry 14's instruction
        (`MintBound.lean:7271`), it is **carried structurally**, not discharged.

- **Estimated output:** ~200-300 lines.
- **Timing:** 2.5 hours
- **Depends on:** 2, 3
- **Verification Tier:** local
- **Commit Mode:** per-substep
- **Scope Hypothesis:** "the R2 lemma is a three-line lemma" is the research's estimate
  (report §8, R2) and is unverified. Confirm at implementation time; if it is materially larger,
  record the actual size and consider whether it warrants its own sub-phase rather than absorbing
  the overrun silently.
- **Done when:** both lemmas sorry-free, module build green.

---

### Phase 5: The `snceNeg` discharge lemma [BLOCKED]

**BLOCKER** (Phase 5): blocked by Phase 1's FALSE verdict. `mintPaysForTimeAt_reuse_false` decides `MintPaysForTimeAt` false at the σ-hit hazard, at every frame class and every `Tmax`, with the most favorable run-realizable σ. `selfGuard_no_column_at_retired_time` gives the general reason, so no other configuration escapes it. Building plumbing for a refuted design is forbidden by the plan's own Rollback/Contingency section. **What is needed to unblock**: a fourth measure component whose index set is not carried through σ at all, or a discharge of the σ-hit obligation itself — which the time-reuse verdict decides is false, not open.

- **Goal:** The exact past mirror of Phase 4. Research risk R3 was resolved during
  adversarial verification: the mirror is exact, so this phase is a transcription, not a
  re-derivation.

- **Tasks:**
  - [ ] `selfGuardPotential_lt_of_snceNeg`, transcribing Phase 4's proof with
        `futureOf → pastOf`, `addFuture → addPast`, `mem_futureOf_of_mem_constraints →
        mem_pastOf_of_mem_constraints`.
  - [ ] Verify the mirror rather than assuming it: the `snceNeg` ACTIVE guard is
        `pastTimes.isEmpty && timeOrd.timeCount > 0 && timeOrd.timeCount < 4` at
        `Tableau.lean:1163` (read the arm's own `if`, **not** the comment at `Tableau.lean:1167`),
        with `newOrd = timeOrd.addPast l.time freshTime` at `Tableau.lean:1170`, and
        `addPast ord t t_new = (t_new, t) :: ord.constraints` (`SignedFormula.lean:689-690`) — so the
        new edge is `(freshTime, l.time)` and the column is cured via `mem_pastOf_of_mem_constraints`
        (`MintBound.lean:223`).
  - [ ] If the mirror turns out **not** to be exact, that is a finding: stop, do not force it, and
        record it as a further C9 register entry in Phase 10.

- **Estimated output:** ~120-200 lines.
- **Timing:** 1.5 hours
- **Depends on:** 4
- **Verification Tier:** local
- **Commit Mode:** per-substep
- **Done when:** lemma sorry-free, module build green.

---

### Phase 6: `MintPaysForTimeAt`'s direction lemma and the no-leak confirmation [BLOCKED]

**BLOCKER** (Phase 6): blocked by Phase 1's FALSE verdict. `mintPaysForTimeAt_reuse_false` decides `MintPaysForTimeAt` false at the σ-hit hazard, at every frame class and every `Tmax`, with the most favorable run-realizable σ. `selfGuard_no_column_at_retired_time` gives the general reason, so no other configuration escapes it. Building plumbing for a refuted design is forbidden by the plan's own Rollback/Contingency section. **What is needed to unblock**: a fourth measure component whose index set is not carried through σ at all, or a discharge of the σ-hit obligation itself — which the time-reuse verdict decides is false, not open.

- **Goal:** Complete the parent plan's Phase 7 deliverable. The direction lemma is a **gate, not a
  nicety**: register entry 7 exists because a "simplification" that was secretly a weakening was
  mistaken for a repair.

- **Tasks:**
  - [ ] `mintPaysForTimeAt_of_mintPaysForTime : MintPaysForTime fc U Tmax → MintPaysForTimeAt fc U
        Tmax`. A third disjunct was added and nothing was removed, so this is the available
        implication and the converse is false — `mintPaysForTime_untlNeg_false`
        (`MintBound.lean:7110`) refutes the stronger one at a `U` where the weaker one is intended to
        hold.
  - [ ] The docstring must state the **direction in words**: "the new predicate is weaker, so every
        theorem restated against it is a strengthening", naming
        `universeClosedAt_of_universeClosed` (`MintBound.lean:5332`) and
        `ordTimesLeMaxTime_of_ordTimesKnown` as the two prior uses of this idiom in this file. A
        repaired predicate without this sentence is not accepted.
  - [ ] Confirm the repair **leaks no new hypothesis into the terminus**. Every quantity the third
        disjunct newly constrains must already be reachable at the consuming site. Mirror
        `universeClosedAt_identify_at_trigger`'s role and land the analogous bridge lemma if one is
        needed. If a genuinely new terminus hypothesis is unavoidable, that is a **blocker to
        escalate**, not a cost to absorb silently.
  - [ ] Docstring `MintPaysForTimeAt` with its full obligation map, per coordinate, in the voice
        `UnorderedSuccessorLabelClosed`'s docstring uses: what is **discharged** (the `untlNeg` /
        `snceNeg` coordinate, Phases 4-5), what is **carried** (the σ-hit, per the time-reuse
        verdict and Phase 1's gate), what remains **open** (the `densityRule` coordinate — see
        Phase 10's residual), and what is assumed by nothing else.
  - [ ] Record explicitly that the only cost is a **coefficient**, not a hypothesis: the fuel figure
        must absorb `2·(Tmax²+1)·2·|U|`, of the kind `splitAwareFuel_le_mintAwareFuel` already
        records (register entry 8). All consuming termini keep their hypothesis lists unchanged.

- **Estimated output:** ~150-220 lines.
- **Timing:** 2 hours
- **Depends on:** 4, 5
- **Verification Tier:** interface
- **Commit Mode:** per-substep
- **Done when:** the direction lemma is sorry-free and its direction is stated in words in the
  docstring; `MintPaysForTime` is retained verbatim and every theorem currently stated against it is
  unchanged (`git diff` shows no edit to any of them); module build green.

---

### Phase 7: The four-component measure and its identification arm [BLOCKED]

**BLOCKER** (Phase 7): blocked by Phase 1's FALSE verdict. `mintPaysForTimeAt_reuse_false` decides `MintPaysForTimeAt` false at the σ-hit hazard, at every frame class and every `Tmax`, with the most favorable run-realizable σ. `selfGuard_no_column_at_retired_time` gives the general reason, so no other configuration escapes it. Building plumbing for a refuted design is forbidden by the plan's own Rollback/Contingency section. **What is needed to unblock**: a fourth measure component whose index set is not carried through σ at all, or a discharge of the σ-hit obligation itself — which the time-reuse verdict decides is false, not open.

- **Goal:** Land `budgetPotentialAt`, the additive four-component sibling of `budgetPotential`, and
  re-prove the identification-arm step lemma at it. This phase is where Constraint (F) is tested for
  real.

- **Tasks:**
  - [ ] Define `budgetPotentialAt` as `budgetPotential`'s body
        (`MintBound.lean:3883-3887`) plus a fourth summand
        `(2 * (Tmax*Tmax + 1)) * selfGuardPotential U σ ord`. **`budgetPotential` itself is
        byte-unchanged**; this is a new declaration alongside it.
  - [ ] **Test Constraint (F) before attempting the inequality.** Establish
        `selfGuardPotential`'s non-increase at arm 3 directly from `selfGuardPotential_identifyTime`
        (Phase 3), with `incomparableB` supplied by `firstIncomparablePair_spec` through
        `expandOnceUnblocked_splitOrdered_shape`. If the non-increase does not go through, the phase
        is `[BLOCKED]` — do **not** work around it by re-weighting the components, which the
        research shows is unsatisfiable (the mint-side rise scales identically).
  - [ ] `budgetPotentialAt_step_splitOrdered_at`, re-proving
        `budgetPotential_step_splitOrdered` (`MintBound.lean:4768-4835`) at the four-component
        measure. The arm-3 case's `omega` gets one additional non-increase input; `hrk` and
        `hEmul`/`hEexp` are unchanged.
  - [ ] Carry the existing `_at` variant (`budgetPotential_step_splitOrdered_at`,
        `MintBound.lean:5471`) forward in the same shape if the terminus chain routes through it —
        confirm which one the seed-level termini actually consume before writing either.

- **Estimated output:** ~250-400 lines.
- **Timing:** 3 hours
- **Depends on:** 3, 6
- **Verification Tier:** interface
- **Commit Mode:** atomic-batch
- **Scope Hypothesis:** "one additional `omega` input suffices at arm 3" is derived from reading
  `MintBound.lean:4812-4835`'s existing proof, not from having run it. Confirm by inspecting the
  actual goal state with `lean_goal` at the arm-3 case before writing the proof; if more inputs are
  needed, record which and why.
- **Done when:** the step lemma is sorry-free, module build green, and `git diff` shows
  `budgetPotential` and both original step lemmas unmodified.

---

### Phase 8: The unordered step lemma and the fuel-figure re-derivation [BLOCKED]

**BLOCKER** (Phase 8): blocked by Phase 1's FALSE verdict. `mintPaysForTimeAt_reuse_false` decides `MintPaysForTimeAt` false at the σ-hit hazard, at every frame class and every `Tmax`, with the most favorable run-realizable σ. `selfGuard_no_column_at_retired_time` gives the general reason, so no other configuration escapes it. Building plumbing for a refuted design is forbidden by the plan's own Rollback/Contingency section. **What is needed to unblock**: a fourth measure component whose index set is not carried through σ at all, or a discharge of the σ-hit obligation itself — which the time-reuse verdict decides is false, not open.

- **Goal:** Re-prove the unordered step lemma at the four-component measure, consuming
  `MintPaysForTimeAt`'s third disjunct, and re-derive the fuel figures that carry it.

- **Tasks:**
  - [ ] `budgetPotentialAt_step_unordered_at`, re-proving
        `budgetPotential_step_unordered` (`MintBound.lean:4693-4758`) at the four-component measure
        with `MintPaysForTimeAt` in place of `MintPaysForTime`. The new third disjunct's strict drop
        is worth `2·(Tmax²+1)` — exactly the weight needed to dominate a mint's rise in
        `splitOrderedRank` (`(Tmax²+1) + Tmax²`, the second summand bounded by
        `incompPairs_card_le`, `Fuel.lean:2382`).
  - [ ] Re-derive `mintPathBoundAt` / `mintAwareFuelAt` (or the naming the file's `_at` convention
        dictates) absorbing the extra `2·(Tmax²+1)·2·|U|`, alongside the byte-unchanged
        `mintPathBound` (`MintBound.lean:4872`) and `mintAwareFuel` (`MintBound.lean:4879`). Land the
        comparison lemma recording that the new figure **enlarges** rather than replaces the landed
        one, in the shape `splitAwareFuel_le_mintAwareFuel` uses.
  - [ ] Re-instantiate section C6's fuel induction (`MintBound.lean:3524-3779`) at the new measure.
        That section is parameterized over an abstract measure, so this should be an instantiation
        rather than a re-proof — **confirm that before writing anything**, and if it is not, say so
        and treat the gap as a blocker rather than expanding the phase.

- **Estimated output:** ~250-400 lines.
- **Timing:** 3 hours
- **Depends on:** 7
- **Verification Tier:** interface
- **Commit Mode:** atomic-batch
- **Scope Hypothesis:** "C6's induction re-instantiates rather than re-proves" is a plan-time
  hypothesis read off the section header (`MintBound.lean:3524`, "The fuel induction, over an
  abstract measure"). Confirm by reading the section's actual parameterization before starting; if
  it is measure-specific, mark the phase `[BLOCKED]` rather than absorbing a full re-proof.
- **Done when:** the step lemma and the fuel comparison lemma are sorry-free, module build green.

---

### Phase 9: Terminus restatement and the concrete instantiation [BLOCKED]

**BLOCKER** (Phase 9): blocked by Phase 1's FALSE verdict. `mintPaysForTimeAt_reuse_false` decides `MintPaysForTimeAt` false at the σ-hit hazard, at every frame class and every `Tmax`, with the most favorable run-realizable σ. `selfGuard_no_column_at_retired_time` gives the general reason, so no other configuration escapes it. Building plumbing for a refuted design is forbidden by the plan's own Rollback/Contingency section. **What is needed to unblock**: a fourth measure component whose index set is not carried through σ at all, or a discharge of the σ-hit obligation itself — which the time-reuse verdict decides is false, not open.

- **Goal:** Deliver the task's "done" condition — the two seed-level termini restated at the
  repaired shape, and the repaired predicate discharged at a **concrete, useful** universe.

- **Tasks:**
  - [ ] Classify the `MintPaysForTime` consuming sites as seed-level or intermediate **before**
        restating anything: `grep -n MintPaysForTime` in `MintBound.lean` and record the
        classification. Restate **only** the seed-level ones; the originals and every intermediate
        site stay as they are.
  - [ ] Restate them at `MintPaysForTimeAt`, mirroring how the closure repair landed
        `buildTableauAt_isSome_of_budget_at`: names follow the file's existing `_at` convention.
  - [ ] Discharge the repaired predicate at the concrete instantiation `U = signedUniverse C L`,
        `σ = id`, `Tmax = derivedTmax ((seedBranch phi).knownTimes.toFinset.card) U.card`, at an
        arbitrary frame class. Model the discharge on
        `timeMergeClosed_identifyTime_signedUniverse` (`MintBound.lean:5541` region), the analogous
        "repaired clause discharged at a concrete useful universe" theorem.
  - [ ] If the discharge needs a closure condition on `L` (the `TimeMergeClosed` pattern), state it,
        name it, and **prove it satisfiable at a concrete finite `L`** — do not leave it as a third
        unproved residual. Note the world-side analogue is refuted
        (`freshWorldHeadroom_not_universal`, register entry 11), so verify satisfiability rather than
        assuming the time side behaves like `TimeMergeClosed`.
  - [ ] `lean_verify` on the delivered theorem's fully qualified name.

- **Estimated output:** ~250-400 lines.
- **Timing:** 3 hours
- **Depends on:** 8
- **Verification Tier:** full
- **Commit Mode:** per-substep
- **Scope Hypothesis:** "two seed-level termini" is carried from the parent plan's own Scope
  Hypothesis (parent plan, Phase 8) and names `buildTableauAt_isSome_at_seed` and
  `buildTableauAt_isSome_at_seed_lengthBudget` as the likely pair. Confirm the set by the grep-and-
  classify task above before restating anything. If more than two are genuinely seed-level, restate
  those and record the count; do not silently expand into intermediate sites.
- **Done when:** full `lake build` green; `lean_verify` reports the delivered theorem **sorry-free
  and axiom-free**; the delivered theorem's statement mentions a concrete `U` (a
  `signedUniverse C L`, not a universally quantified `U`) — a universally quantified restatement is
  not the deliverable; `git diff --stat` shows `Saturation.lean`, `Fuel.lean`, `Tableau.lean`
  untouched.

---

### Phase 10: Register entries, the density residual, and the closing gate [COMPLETED]

**ROUTED HERE BY PHASE 1's FALSE VERDICT.** This is now the only other phase that runs. Register entry 17 takes its **Phase 1 FALSE branch** form: the `selfGuardPotential` design and the σ-hit exposure it inherits, with `mintPaysForTimeAt_reuse_false` as the refuting witness and `selfGuard_no_column_at_retired_time` as the general reason. The Phase 1 TRUE branch's candidate entry (Candidate 1 / `timeSlotDeficit`) is **not** the one to land.

- **Goal:** Bring the file's own narrative into agreement with what landed, record every route
  refuted along the way, and run the closing gates. **This phase runs on every path through the
  plan**, including the Phase 1 FALSE and UNDECIDED branches where it is the only other phase.

- **Tasks:**
  - [x] Append the new C9 register entry or entries following the existing convention exactly:
        cited by declaration name and refuting witness, never by an issue number or tracker entry.
        Update the opening count ("Sixteen statements") in the same edit. Candidates, depending on
        which path the plan took: *(landed: entry 17 in its FALSE-branch form, appended at the end
        of C9; opening count updated "Sixteen" -> "Seventeen". No further route was refuted, since
        Phases 2-9 never ran, so entry 17 is the only new entry.)*
        - **Entry 17 (Phase 1 FALSE / UNDECIDED branch)**: the `selfGuardPotential` design and the
          σ-hit exposure it inherits, with `mintPaysForTimeAt_reuse_false` (or the open-exposure
          statement) as the witness.
        - **Entry 17 (Phase 1 TRUE branch)**: Candidate 1, the closure-set time-slot deficit
          (`timeSlotDeficit`), and by Corollary (F′) the whole family of `knownTimes.card`-affine
          fourth components — refuted by Constraint (F) plus the identity
          `timeSlotDeficit U b = |timeSlots U| − b.knownTimes.toFinset.card` under confinement,
          which makes it literally a re-coefficienting of `splitOrderedRank`'s first summand. A
          reader who reaches for the naturally-suggested "count the time slots not yet used" has
          already been here.
        - Any further route refuted during Phases 2-9 (in particular, a non-exact `snceNeg` mirror
          per Phase 5, or a measure-specific C6 induction per Phase 8).
  - [x] Record the **density residual** in `MintPaysForTimeAt`'s docstring obligation map and in the
        register narrative: `MintPaysForTimeAt` carrying only the `selfGuardPotential` disjunct
        remains refutable at `.Dense`/`.Dedekind` by a `densityRule` vehicle, because `densityRule`
        returns `.persistent` which maps to `.extended` (`Tableau.lean:1385` + `MintBound.lean:1071`)
        and is therefore inside the predicate's scope. Name the intended second component
        (`gapPotential`, indexed by `U ×ˢ U`, transcribing `densityRule`'s own `gapTargets` filter at
        `Tableau.lean:1364-1366`) and state that Caleiro's SVDns (`sec03:80`) is the literature's own
        reason it is a separate clause. Do **not** implement it here. *(landed in three places: an
        "Obligation map" paragraph appended to `MintPaysForTimeAt`'s docstring, a dedicated
        subsection "The density residual" between `mintPaysForTimeAt_reuse_false` and C9, and the
        "What is **not** refuted" paragraph closing register entry 17. Nothing implemented.)*
  - [x] Reconcile any docstring in the file that asserts the fourth component is missing — in
        particular the "The repair, attempted and BLOCKED" narrative (`MintBound.lean:7137-7183`) and
        entry 14's closing paragraph (`MintBound.lean:7521-7525`) — with what actually landed.
        Leaving them stale is a correctness defect in the file's documentation. *(deviation:
        altered — the "attempted and BLOCKED" narrative was reconciled by an appended paragraph
        recording that the fourth component has since been attempted and decided FALSE. Entry 14's
        closing paragraph was deliberately NOT edited: this plan's own Testing & Validation
        checklist requires "`git diff` shows no modification to ... any of the 16 original C9
        entries' bodies", and entry 14's claim — that a fourth component paying for the three
        self-guarded minting rules is still missing — remains true. The reconciliation a reader
        needs lives in entry 17, which cross-references entry 14 by number in both directions.)*
  - [x] Closing gate: full `lake build` green; `lean_verify` on every new theorem reports sorry-free
        and axiom-free; `git diff --stat` confirms only `MintBound.lean` changed among source files;
        `grep -c sorry` on the changed file returns no new occurrences. *(all pass. Full `lake build`
        green, 2333 jobs. No new theorem was introduced by this phase — it is documentation only —
        so `lean_verify` was run on the phase's subject instead:
        `FormalSystem.Metalogic.Decidability.mintPaysForTimeAt_reuse_false` reports axioms
        `{propext, Classical.choice, Quot.sound}`, i.e. no `sorryAx` and no project axiom.
        `git diff --stat` shows `MintBound.lean` as the only changed source file, with
        `Saturation.lean`, `Fuel.lean`, `Tableau.lean` untouched. `grep -c sorry` on the changed
        file returns 1, unchanged from before the phase — the single hit is the word `sorryAx`
        inside pre-existing prose at line 6608, not a proof term.)*

- **Estimated output:** ~120-250 lines (mostly docstring prose).
- **Timing:** 1.5 hours
- **Depends on:** 9 (on the success path); **1** on the Phase 1 FALSE / UNDECIDED path
- **Verification Tier:** full
- **Commit Mode:** per-substep
- **Done when:** full `lake build` green, every closing-gate check above passes, and C9's opening
  count matches its entry count.

---

## Testing & Validation

- [ ] `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound` green at the
      end of every phase.
- [ ] Full `lake build` green at the end of Phase 9 and Phase 10.
- [ ] `lean_verify` on every new theorem's fully qualified name reports sorry-free and axiom-free.
- [ ] `git diff --stat` shows `FormalSystem/ProofSystem/.../Saturation.lean`,
      `.../Fuel.lean`, and `.../Tableau.lean` untouched at every phase boundary.
- [ ] `git diff` shows no modification to `MintPaysForTime`, `mintPotential`, `budgetPotential`,
      `budgetPotential_step_unordered`, `budgetPotential_step_splitOrdered`, `mintPathBound`,
      `mintAwareFuel`, or any of the 16 original C9 entries' bodies.
- [ ] C9 remains the file's final block before `end FormalSystem.Metalogic.Decidability`.
- [ ] No `sorry`, no `def X := True`, no `theorem X := trivial` anywhere in the diff.

## Artifacts & Outputs

- `specs/436_fourth_termination_measure_component/plans/01_self-guard-potential.md` (this file)
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` — new D2 subsection with
  `selfGuardRules`, `selfGuardDischarged`, `selfGuardPotential`, `MintPaysForTimeAt`, their lemmas,
  the four-component measure, the restated termini, the concrete discharge, and the new C9 entries.
- `specs/436_fourth_termination_measure_component/summaries/01_self-guard-potential-summary.md`

## Rollback/Contingency

- **Phase 1 decides FALSE or UNDECIDED**: this is a *successful* outcome, not a failure. The
  deliverable becomes the decided negative result plus register entry 17. Phases 2-9 are marked
  `[BLOCKED]` citing Phase 1, Phase 10 runs, and the task reports back. Nothing is landed under the
  deliverable's name that is weaker than the deliverable.
- **A later phase stalls**: mark that phase `[PARTIAL]` or `[BLOCKED]` with what was tried and what
  goal state was reached, per `.claude/rules/plan-compliance.md` — do **not** silently substitute a
  different decomposition, and do **not** land a vacuous placeholder. Everything already committed
  stays; the file is additive throughout, so no landed declaration is at risk.
- **A repair that trades one named residual for another is not a discharge.** If the terminus
  restatement (Phase 9) would require introducing a new unproved residual, land nothing there rather
  than landing a weaker substitute, and record the reason.
- **Full revert**: every phase's work is a contiguous additive block in one file, so
  `git revert` of the phase's commit restores the prior state exactly. No other file is touched.
