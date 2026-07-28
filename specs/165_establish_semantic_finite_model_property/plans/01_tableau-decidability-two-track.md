# Implementation Plan: Verified Tableau Decidability of TM (Two-Track, Skeleton)

- **Task**: 165 - establish_semantic_finite_model_property (rescoped to tableau decidability)
- **Status**: [IMPLEMENTING]
- **Effort**: ~50 hours (Track A scope carried by this task; Track B deferred to follow-up tasks)
- **Dependencies**: None
- **Research Inputs**:
  - reports/02_tableau-decidability-hard-research.md (PRIMARY — hard-mode audit; trust its §9 H4 tables over the charter where they conflict)
  - reports/03_cslib-tableau-survey.md (supplementary — cslib patterns and anti-lessons)
  - reports/01_semantic-fmp-research.md (background only; semantic-FMP route out of scope; F4/F5/F6/F8/F9 remain valid and are reused)
  - reports/04_blocker-resolution-r5-branchorder-seriality.md (AUTHORITATIVE for Phase 2.4-2.8, Phase 5.1 and Phase 7.1 — its "Recommended plan delta" is settled design and overrides the pre-revision text of those phases)
- **Artifacts**: plans/01_tableau-decidability-two-track.md (this file)
- **Standards**: .claude/context/formats/plan-format.md; .claude/rules/plan-format-enforcement.md; .claude/rules/artifact-formats.md; .claude/rules/state-management.md; .claude/context/formats/status-markers reference in plan-format.md
- **Type**: lean4
- **Plan Metadata**: `skeleton: true` (Stage 4a escape valve — full scope exceeds the 8-phase hard-mode ceiling); `follow_up_tasks: [410, 411, 412]` (allocated by skill postflight); `dependency_waves: [[1],[2],[3,4,5],[6],[7],[8]]`

## Revision (blocker research) — 2026-07-27

This plan was revised in place (no new plan version) to absorb
`reports/04_blocker-resolution-r5-branchorder-seriality.md`, the blocker-resolution dispatch for
Phase 2.4. That report's "Recommended plan delta" is the settled design; the changes it makes to
this file are:

1. **Phase 2.4 restated** and its `**BLOCKER**` block replaced by a resolution note. The blocker's
   own diagnosis was **refuted by source inspection**: all thirteen `.persistent` return sites in
   `applyRule` are already branch-guarded, so persistent-rule re-firing is not the cycle driver;
   **source destruction** (`Tableau.lean:1365, 1369, 1428, 1431`) is. `AppliedRedundant` was
   further measured **false** on four formulas (`◇(p ∧ q)`, `◇◇p`, `◇¬¬p`, `◇(□(p∧q) ∧ ¬p)`), so
   the previously-proposed "prove `AppliedRedundant` invariant" sub-phase is deleted rather than
   scheduled (report 04 §Q1.2, Contradiction Log C1/C2).
2. **Four new sub-phases** 2.5 / 2.6 / 2.7 / 2.8 added, all inside Phase 2's existing engine
   territory, so the wave structure is unchanged. **Execution order: 2.8 → 2.5 → 2.6 → 2.7 → 2.4.**
3. **Phase 3** constructor count corrected from ~34 to **36**, with an explicit
   `mem_allRulesForFC_iff` exclusion clause for `serialityRule` (deliberately not in
   `allRulesForFC`).
4. **Phase 5.1 rewritten**: per-branch orderings behind the decidable `timeOrderTotal` gate;
   Mathlib linear extension recorded as a refuted non-goal.
5. **Phase 7.1 hypothesis changed**: the certificate's saturation field becomes a disjunction
   (`findUnexpanded … = none ∨ blocked`), and the blocked disjunct is the *normal* case for open
   branches once `serialityRule` lands.

## Overview

The tableau stack in `FormalSystem/Metalogic/Decidability/` executes but proves nothing real:
the WP1 audit (report 02) found the calculus **not adequate** (defects D1-D5, two with
machine-produced unsatisfiable open branches), the blocking machinery vacuous (D3), and the
headline theorems `validity_decidable` / `validity_has_decision_procedure` vacuous. This plan
repairs the calculus (R1-R7), builds the composability architecture (RuleSpec gate lemma,
`TemporalCarrier` class, `Verified/` module layout per report 02 §8.2), proves termination (WP3)
and the semantic bridge (WP4), and lands **Track A: `Decidable` instances for validity over all
four frame classes** (Base/ℚ, Dense/ℚ, Discrete/ℤ, Dedekind/ℝ via `ValidDedekindDense`) — the
first publishable milestone, reachable without touching the Hilbert system. **Track B**
(decidability of provability, ~34 admissibility lemmas, completeness corollaries, discharge of
the `countermodel_discrete` sorry) is deliberately deferred to three follow-up tasks declared in
`.skeleton-return.json`; see Planned Strategic Sorries.

**Definition of done (this task)**: `Decidable (⊨ φ)` plus the three class variants proved
sorry-free with the conformance corpus green for all four frame classes; all four vacuous
theorems deleted/replaced; docs corrected. Track B division points recorded, follow-up tasks
created.

### Research Integration

Both hard-mode reports are fully integrated. Load-bearing corrections adopted from report 02 §9:
rule count is **30 total / 25 base** (not 23/28); Dedekind gating Base+Dense is **correct** (the
terminus consumes `ValidDedekindDense`); the real Dedekind gap is missing
`prior_U_gap`/`prior_S_gap`/`sep` rules (D5); blocking is too **eager**, not too weak (C4).

### Source-to-Implementation Mapping (H3, Tier 3 implementation-backed)

Grounding tier per report 02: Tier 3 (implementation-backed); no load-bearing claim rests on
literature. Literature rows in report 02 §6 are advisory. Every phase below cites its grounding
section; the report's §6 mapping table is the master source-to-declaration map and is not
duplicated here.

| Phase | Grounding sections | Primary targets |
|-------|-------------------|-----------------|
| 1.1 | 03 §6, §9.1-9.2; 02 §2.1 controls | `Tests/BimodalTest/TableauConformance.lean` (new) |
| 1.2 | 02 §2.2 (D1), §2.7 R1 | `Decidability/SignedFormula.lean:676,681` |
| 1.3 | 02 §2.4 (D3), §2.7 R3+R4; 03 §4.5 | `SignedFormula.lean:707,732,763`; `Saturation.lean:1247` |
| 2.1 | 02 §2.5, §2.7 R7 | `DecisionProcedure.lean:64,128`; `Correctness.lean:101` |
| 2.2 | 02 §2.3 (D2), §2.7 R2, §3.3, §10 risk 1 | `Tableau.lean:73,274,345` (new ctor `orderTrichotomy`) |
| 2.3 | 02 §2.7 R6 (D5), §10 | `Tableau.lean:1067` (`dedekindRules`) |
| 2.4 | 02 §2.7 R5 (D4) | `Saturation.lean:50-59` (`ExpandedTableau.hasOpen`) |
| 3 | 02 §8.1-8.3 | `Decidability/Verified/RuleSpec.lean` (new) |
| 4.1 | 02 §4.2 T1 (negation-closure trap), §9 | `Verified/Termination/SubformulaProperty.lean` (new) |
| 4.2 | 02 §4.2 T2, §4.3 (verified Mathlib names); 03 §3.4 | `Verified/Termination/TimeTypeBound.lean` (new) |
| 4.3 | 02 §4.2 T3, §10; 03 §4.3 | `Verified/Termination/Fuel.lean` (new) |
| 5.1 | 02 §5.2 stage 1 | `Verified/Bridge/BranchOrder.lean` (new) |
| 5.2 | 02 §5.2 stage 2, §5.3, §8.4; 03 §3.2, §7.2 | `Verified/Bridge/Embed.lean`, `Bridge/Carrier.lean` (new) |
| 6.1-6.3 | 02 §5.2 stage 3, §2.6, §10; 03 §4.2 | `Verified/Bridge/Interpolate.lean` (new) |
| 7.1 | 02 §5.2 stages 4-5; 01 F6/F9 | `Verified/Bridge/Omega.lean`, `Bridge/TruthLemma.lean` (new) |
| 7.2-7.3 | 02 §8.5 Track A | `Verified/Decidable.lean` (new) |
| 8 | 02 §7 | `Correctness.lean:78,91`; `FMP/FMP.lean:183,237`; LaTeX/typst |

## Postmortem Constraints

Binding rules for all implementation dispatches. Derived from report 02's adversarial audit
(§2, §9-10), report 03's cslib anti-lessons (§4), and prior hard-mode task experience. No prior
plan exists for this task; rules derive from research risk factors and cross-repo postmortems.

**Do NOT**:
1. **Do NOT close any repair sub-phase without its regression probe passing** (probe-first).
   Phases 1.2/1.3/2.2 MUST re-run the corresponding report 02 §2.2-2.4 probes as committed
   `#eval` regressions plus `lake build`. A sorry-free green build is NOT adequacy evidence —
   cslib shipped a sorry-free, build-green tableau that answered OPEN on `𝐅⊤` (03 §4.1, §6).
2. **Do NOT verify a Mathlib name without a deliberate control error in the same run.**
   `import Mathlib` alone silently elaborates to nothing in this project; a bogus `#check`
   "passes" (02 §9 C2 — this exact failure shipped a nonexistent lemma name once already).
3. **Do NOT trust blocking for anything until R3/R4 land** (Phase 1.3). Current blocking fires
   vacuously (D3 + swapped-argument bug); any termination/pigeonhole result proved before the
   repair measures an artifact (02 §2.4, §4.4). Corollary: do not phrase any work as
   "strengthen blocking" — blocking is too eager, not too weak (C4).
4. **Do NOT record a blocked step as an ordering/accessibility edge.** Blocking must be an
   identification or a deletion; an extra edge becomes an unpayable obligation the moment
   soundness quantifies over arbitrary models — cslib's most expensive lesson, machine-witnessed
   (03 §3.3). Decide this in Phase 5.1, before the bridge is built.
5. **Do NOT attempt a depth-based termination measure for the modal (S5) dimension.** cslib
   mechanized its falsity (`modalApplyOneS5_rankStep_not_dischargeable`, sorry-free). Use
   pigeonhole/counting over a fixed finite universe (03 §3.4).
6. **Do NOT build an island countermodel.** A finite-carrier valuation biased to `false` breaks
   every positive `G`/`H` on a `NoMaxOrder` domain; the interpolated model must be total on the
   carrier `D` (03 §4.2; this is why Phase 6 uses constant-on-half-open-intervals).
7. **Do NOT use plain `subformulaClosure` for the Discrete class in T1.** `priorUZ`/`priorSZ`
   emit `U(φ, ¬φ)` where `¬φ` is not a subformula; T1 as stated is FALSE without negation
   closure. Use `closureWithNeg` (`Syntax/SubformulaClosure/Closure.lean:71`) (02 §4.2).
8. **Do NOT introduce any new `sorry` in `FormalSystem/`** — the `Decidability/` tree is
   sorry-free and must stay so; the single pre-existing sorry (`countermodel_discrete`,
   `WeakCanonical/Transfer.lean:1242`) remains untouched and is discharged by follow-up task
   412. This task's plan contains no in-file strategic sorries: division points are
   whole deferred files/theorems (see Planned Strategic Sorries).
9. **Do NOT spend effort re-litigating the Dedekind gating.** `Discrete ≰ Dedekind` is correct
   (terminus is `ValidDedekindDense`); the gap is the missing D5 rules, nothing else (02 C3).
10. **Do NOT size case analyses against the charter's "28 rules".** `allRules` has 25 entries,
    30 constructors total; after R2 (+1) and R6 (+3) the case count is ~34 (02 §1.2, §9), and
    after 2.6 (`serialityRule`, +1) and 2.7 (`timeLinearity`, +1) it is **36** (04 §Q2.4, Phase 3
    delta). `serialityRule` is deliberately absent from `allRulesForFC`, so any `by decide` gate
    over that list needs an explicit exclusion clause for it.
13. **Do NOT attempt the refuted routes recorded in report 04.** Specifically: (a) proving
    `AppliedRedundant` invariant under `expandBranchWithFuel` — the predicate is measured *false*
    on `◇(p ∧ q)`, `◇◇p`, `◇¬¬p`, `◇(□(p∧q) ∧ ¬p)` (§Q1.2); (b) a transitive/recursive
    strengthening of `appliedEntryRedundant` — `findApplicableRule`'s `.persistent` output set
    grows with the branch, so the predicate is not monotone and the induction step fails (§Q1.2);
    (c) Mathlib `extend_partialOrder` / `LinearExtension` on the branch order — unsound, measured
    counterexample (§Q2.3); (d) scheduling `serialityRule` at the head or per-formula-last of the
    priority list — both measured to regress control rows (§Q3.4, "Recommendations modified after
    verification").
11. **Do NOT let `soundFuel` uncapping degrade the runtime procedure.** Keep the capped
    `soundFuel` as the `#eval` default; introduce uncapped `soundFuel'` used only in theorems
    (02 §10). Plan the fuel form jointly with calculus repair, never after (03 §4.3).
12. **Do NOT start Phase 6 (interpolation) before Phases 1-2 are green.** The guard obligation
    its `untl` case discharges is only produced once `orderTrichotomy` exists (02 §5.2, §10).

**MUST preserve** (completed work that must not regress):
- The `sat_*` saturation-fact family (`CountermodelExtraction.lean:333-904`) — reused verbatim
  by the new truth lemma (02 §5.2 stage 5).
- `isTimeOrderedBefore` (`CountermodelExtraction.lean:198`) — the correct transitive-reachability
  helper R1 wires in.
- The `Saturation.lean` `#eval` test suite (lines ~700-1600) — every calculus phase must leave it
  green or update it with the change explicitly justified in the phase summary.
- The existing engine's public API (`decide`, `buildTableau`, `isValid`) — the `Verified/`
  subtree sits beside it (02 §8.2); R7's `DecisionResult` split is the only sanctioned API change.
- Sorry-free status of everything outside `WeakCanonical/Transfer.lean:1242`.

**Design decisions are SETTLED** (do not re-open without a concrete counterexample):
- **Two-track split**: Track A (validity) before and independent of Track B (provability). First
  green milestone requires no Hilbert-system work (02 §8.5).
- **Internalization over substitution** for Track B: no cut or uniform-substitution
  admissibility exists in the tree; designs requiring them are rejected (02 §3.4). Recorded here
  so follow-up tasks inherit it, together with the constraint that `Branch.internalize` keeps
  `z1Rule`'s two premises at the same label (02 §3.3).
- **`orderTrichotomy` branches are syntactically the `temp_linearity` disjuncts** — the single
  highest-leverage design decision; makes the eventual admissibility lemma a one-liner (02 §3.3).
- **Carriers**: Base→ℚ, Dense→ℚ, Discrete→ℤ, Dedekind→ℝ, confined to four `TemporalCarrier`
  instances (02 §5.3, §8.4).
- **RuleSpec gate before any admissibility work**: `ruleFrameClass`/`ruleAxioms` + two `by decide`
  GATE lemmas make rule/axiom mis-gating a build failure, not a silent drift (02 §8.3).
- **Frame-class variation by parameter, not per-class files** — the `DenseFMP.lean` wholesale-
  delegation shape is the named anti-pattern (03 §4.6).

## Goals & Non-Goals

- **Goals**:
  - Repair the calculus so both machine-produced counterexample branches close (D1, D2) and
    blocking is a genuine subset condition (D3/D4), with executable regression evidence.
  - Add the missing Dedekind rules (D5) and split the conflated `.timeout` verdict (R7).
  - Build the composability architecture: `Verified/RuleSpec.lean` gate, `TemporalCarrier`
    class, `Verified/` module layout — base development plus modular per-class extensions.
  - Prove termination (T1 generalized subformula property, T2 pigeonhole, T3 justified fuel).
  - Prove the semantic bridge `not_valid_of_hasOpen` generically in the carrier and land
    `Decidable (⊨ φ)` + `ValidDense`/`ValidDiscrete`/`ValidDedekindDense` variants (Track A).
  - Remove the four vacuous theorems; correct LaTeX/typst overclaims.
  - Declare Track B follow-up tasks with the reversed skeleton dependency direction.
- **Non-Goals** (deferred to follow-ups, not silently dropped):
  - `Branch.internalize` and the ~34 per-rule admissibility lemmas (410,
    411).
  - `allClosed_derivable`, `Decidable (Derivable fc [] φ)`, completeness corollaries,
    discharging `countermodel_discrete`, the Dedekind completeness engine (412).
  - Semantic FMP via filtration (report 01's route — out of scope by task rescope).
  - Porting cslib code verbatim (module-system friction; re-derive patterns instead, 03 §8).

## Risks & Mitigations

- **Risk (High)**: `orderTrichotomy` multiplies branching `3^k` and could wreck practicality and
  the fuel bound. **Mitigation**: restrict branching to incomparable-and-relevant time pairs
  (shared world + shared temporal formula); prototype in Phase 2.2 and re-run the §2 probes and
  conformance corpus BEFORE Phase 4 fixes the fuel form (02 §10; 03 §4.3 joint-planning rule).
- **Risk (High)**: the interpolation lemma (Phase 6) is the mathematical core, comparable to
  canonical-model completeness. **Mitigation**: three bounded sub-phases with per-case stopping
  conditions; the `untl`/`snce` case (6.3) has an explicit escalation path (see phase) instead of
  an unbounded attempt surface.
- **Risk (Medium)**: R3/R4 break `blocking_sound` and `Closure.lean` monotonicity lemmas.
  **Mitigation**: their reproof is budgeted inside Phase 1.3, not discovered later (02 §10).
- **Risk (Medium)**: Dedekind rules (R6) have no prior art in the tree; `prior_U_gap`/
  `prior_S_gap` use `K⁺`/`K⁻` which no current rule touches. **Mitigation**: Phase 2.3 is scoped
  as a design phase with a fixed deliverable (rules + probe rows), and its admissibility burden
  is entirely in 411 (02 §10).
- **Risk (Medium)**: two distinct open-branch populations (genuinely saturated vs
  fuel-exhausted) need two different arguments; conflating them re-creates cslib's blocked-
  witness gap. **Mitigation**: Phase 4.3/7.1 treat them separately by construction — T3 proves
  fuel-exhaustion cannot occur at `soundFuel'`, so the bridge only ever sees saturated branches
  (03 §4.4).
- **Risk (Low)**: deleting `validity_decidable` breaks documentation name references.
  **Mitigation**: Phase 8 updates `typst/chapters/p2-decidability-practice.typ:70,112` in the
  same dispatch (02 §10).

## Implementation Phases

**Dispatch granularity**: sub-phases (N.M) are the unit of one agent run under H8; each is one
bounded, verifiable unit with a stated output estimate and done-criterion. Top-level phases
group sub-phases sharing a theme and territory. 20 dispatch units total.

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 4, 5 | 2 |
| 4 | 6 | 2, 5 |
| 5 | 7 | 3, 4, 6 |
| 6 | 8 | 7 |

Phases within the same wave can execute in parallel. **Territory contracts (wave 3)**: Phase 3
owns only new file `Verified/RuleSpec.lean`; Phase 4 owns only new directory
`Verified/Termination/`; Phase 5 owns only new directory `Verified/Bridge/` (files
`BranchOrder.lean`, `Embed.lean`, `Carrier.lean`). No wave-3 phase edits engine files — all
engine edits complete in waves 1-2. Reads are unrestricted.

### Phase 1: Conformance Harness and Mechanical Calculus Repairs (R1, R3, R4) [COMPLETED]

- **Goal:** Executable regression corpus in place; the three mechanical WP1 defects (D1 transitive
  closure, D3 ancestor set, D3′ swapped eventuality arguments) fixed with probes green.
- **Tasks:**
  - [x] **1.1 Conformance corpus** (`Tests/BimodalTest/TableauConformance.lean`, new). Rows per
    frame class with expected verdicts and an explicit statement of which validity notion each
    class's corpus targets (03 §6): cslib's five seriality/dual probes (`F⊤`, `¬G⊥`, `Gp → Fp`,
    `Hp → Pp`, `P⊤`), the `Fq → Fᵏ⊤` family `k = 0..6`, `Gp → GGp` (counterexample A), the
    `temp_linearity` permutation instance (counterexample B), Until/Since linearity rows, and the
    report 02 §2.1 controls (`p → p` CLOSED, `p` OPEN, `Gp → p` OPEN, `Fp → FFp` OPEN,
    `G(p→q) → (Gp → Gq)` CLOSED). Use `#guard_msgs in #eval` with a `String` verdict adapter
    (`decide`/`native_decide`/`rfl` stall on fuel loops — 03 §6). Currently-failing rows are
    committed as documented expected-current-failure rows to be flipped by later phases.
    Estimated output: ~200-300 lines. Done when: file builds; every row's current verdict is
    recorded; failing rows enumerated in the phase summary.
  - [x] **1.2 R1 — transitive `futureOf`/`pastOf`** (`SignedFormula.lean:676,681`): replace the
    direct-edge filter with fuel-bounded transitive closure reusing `isTimeOrderedBefore`
    (`CountermodelExtraction.lean:198`). Re-run the §2.2 probe: `applyRule .someFutureNeg` on
    branch A now propagates to `[1, 2]`. Estimated output: ~100-200 lines incl. probe `#eval`s.
    Done when: counterexample A's probe closes under the blocking-free driver; `lake build` green;
    conformance rows updated.
  - [x] **1.3 R3 + R4 — genuine blocking** (`SignedFormula.lean:707,732,763`): `ancestorTimes`
    follows predecessor edges only and excludes `t` itself; fix the swapped
    `t_new`/`t_anc` arguments at the `isTemporallyBlocked` call site; check the branching arms
    thread eventuality trackers per-branch (03 §4.5) and fix if not. Reprove `blocking_sound`
    (`Saturation.lean:1247`) and any broken `Closure.lean` monotonicity lemmas against the
    repaired predicate. Re-run the §2.4 probe: `isTemporallyBlocked b0 1 ⟨[(0,1)]⟩ = false`.
    Estimated output: ~200-350 lines. Done when: §2.4 probe evals flipped and committed;
    `lake build` green; `Saturation.lean` `#eval` suite green or updates justified.
    *(deviation: none required for the two contingent items — `blocking_sound` is stated about
    `findClosure openBranch = none`, not about the blocking predicate, so it re-elaborated
    unchanged; no `Closure.lean` monotonicity lemma broke. The 03 §4.5 per-branch tracker check
    found the cslib defect does NOT reproduce here: each recursive `expandBranchWithFuel` call
    re-runs `registerEventualities`/`fulfillEventualities` against its own branch before
    consulting `findBlockedTime`, so no fix was needed; the finding is recorded in-code at the
    `.split` arm.)*
- **Timing:** 3 dispatches, ~7 hours.
- **Depends on:** none

### Phase 2: Calculus Completion (R7, R2, R6, R5) [PARTIAL]

- **Goal:** The rule set is adequate and honestly reported: trichotomy branching exists, Dedekind
  rules exist, the `.timeout` conflation is split, and the open-branch certificate is strong
  enough for a truth lemma.
- **Tasks:**
  - [x] **2.1 R7 — verdict split** (`DecisionProcedure.lean:64,128,152,161`): split `.timeout`
    into `.fuelExhausted` / `.extractionFailed` so a closed tableau is never reported undecided;
    reprove `decide_result_exclusive` (`Correctness.lean:101`); update the conformance verdict
    adapter. Estimated output: ~100-200 lines. Done when: build green; conformance suite green
    with the new verdict vocabulary.
    *(done: `DecisionResult.timeout` split into `.fuelExhausted` / `.extractionFailed`;
    `isUndecided` holds of the former only; `decide_result_exclusive` reproved as four-way
    exclusivity, plus `not_undecided_of_extractionFailed` and
    `isKnownValid_of_extractionFailed`. `CancellableExpansion` mirror and the six
    `Automation/` consumers updated; conformance adapter's `STALLED`/`.fuelExhausted`
    correspondence documented in-file.)*
  - [x] **2.2 R2 — `orderTrichotomy`** (`Tableau.lean`): new `TableauRule` constructor +
    `isApplicable` + `applyRule` case, branches syntactically the `temp_linearity` disjuncts
    (SETTLED decision); branching restricted to incomparable AND relevant time pairs (shared
    world + shared temporal formula) to contain `3^k` blowup. Re-run the §2.3 probe.
    Estimated output: ~200-350 lines. Done when: counterexample B closes; conformance corpus and
    `Saturation.lean` `#eval` suite green; branching-restriction rationale documented in-code.
    *(done: counterexample B flips OPEN -> CLOSED and is the ONLY row that moved across all
    four class tables. Deviation from the phase text, recorded: the rule triggers on a
    **witness** formula at an incomparable sibling time under a common predecessor, not on a
    pair of unconsumed `T(F .)` eventualities at one label — the eventuality-pair trigger is
    unreachable, because `someFuturePos` is consumable and consumes the first eventuality
    before the second is decomposed out of the antecedent conjunction. Branches are still
    syntactically the `temp_linearity` disjuncts, as settled. Three-part termination guard
    (disjunct still present / witnesses now ordered / first-witnesses-only) with the measured
    divergence traces recorded in-code. Row B needs fuel ~10000, so `Row` gained a per-row
    `fuel` override rather than raising the corpus-wide bound — raising it corpus-wide was
    tried and made the file take minutes.)*
  - [x] **2.3 R6 — `dedekindRules`** (`Tableau.lean:1067`): design tableau counterparts for
    `prior_U_gap`/`prior_S_gap`/`sep` (`Axioms.lean:377,387,398`; the first two involve
    `K⁺`/`K⁻`, `Formula.lean:180,193`); add the `allRulesForFC` Dedekind arm
    (base + dense + dedekind, preserving `Discrete ≰ Dedekind`). Add Dedekind conformance rows
    (the three axiom instances close). Estimated output: ~150-300 lines. Done when: Dedekind
    axiom instances close; no regression in other classes' corpora; build green.
    *(done: `priorUGap`/`priorSGap`/`sepRule` added; all three Dedekind rows flip
    STALLED -> CLOSED with no other row moving. Two design points recorded in-code: each rule
    triggers on its axiom's antecedent **conjunction** (a conjunct trigger loses a race to the
    consumable Until/Since rules), and the Dedekind arm is **prepended** to `allRulesForFC`
    rather than appended, since appending leaves the rules dead. `Discrete <= Dedekind` is
    preserved: the arm is base + dense + dedekind.)*
  - [x] **2.8 (new, cheap — land FIRST) — the `timeOrderTotal` gate**
    (`Saturation.lean` + `Tests/BimodalTest/TableauConformance.lean`). Add the decidable predicate

    ```lean
    def timeOrderTotal (b : Branch) (ord : TimeOrdering) : Bool :=
      b.knownTimes.all fun t₁ => b.knownTimes.all fun t₂ =>
        t₁ == t₂ || (ord.futureOf t₁).contains t₂ || (ord.futureOf t₂).contains t₁
    ```

    and pin rows W1–W7 in the corpus as currently-failing `#guard_msgs` rows, so 2.7 has a
    measurable done-criterion and the regression signal exists *before* the change. The measured
    W-rows (report 04 §Q2.1, fuel-insensitive at 200 and 2000) are `¬(F(G p) ∧ F(¬p))`,
    `¬(F p ∧ F q)`, `¬(F(G p) ∧ F(G q))`, `¬(F(¬p) ∧ F(G p))` (each `knownTimes=[2,1]`,
    `constraints=[(0,2),(0,1)]`, `incomparable=[(1,2)]`), plus the comparable controls
    `¬(F p ∧ P q)` and `F p → F F p`. Estimated output: ~60-100 lines.
    Done when: the predicate elaborates; W1–W7 pinned with their current (mostly `false`)
    verdicts; `lake build` and `lake build BimodalTest` green.
    *(done: `timeOrderTotal` and the `incomparableTimePairs` diagnostic added to
    `Saturation.lean` with the refuted-linear-extension non-goal recorded in-code;
    `TimeOrderProbe` pins W1–W7 in the corpus. Measured, reproducing report 04 §Q2.1 exactly:
    W1–W4 `total=false knownTimes=[2,1] constraints=[(0,2),(0,1)] incomparable=[(1,2)]`;
    controls W5 `¬(F p ∧ P q)` and W6 `F p → F F p` already `total=true`; W7 is W1 at fuel
    2000 and is identical, so the incomparability is structural, not a fuel artifact.
    Deviation: the probe pins `knownTimes`/`constraints`/`incomparable` alongside the verdict
    rather than the verdict alone, so 2.5's expected `knownTimes` change is visible as a
    distinct signal from 2.7's expected `total` flip.)*
  - [x] **2.5 (new) — branch-guarded non-destructive expansion** (`Tableau.lean`, with
    `applied`-threading removal in `Saturation.lean` / `CancellableExpansion.lean`).
    Add `ruleMintsFreshLabel` and `witnessPresent` (8 arms: `boxNeg`, `diamondPos`,
    `allFutureNeg`, `allPastNeg`, `someFuturePos`, `somePastPos`, `untlPos`, `sncePos` —
    `densityRule` already carries its own `existingIntermediates` guard at `Tableau.lean:1074-1076`);
    guard the `.linear` and `.branching` results in `findApplicableRule` (`1308-1317`) exactly as
    the `.persistent` arms already guard themselves; make `expandOnce` **non-destructive**
    (`remaining := b`, lines `1365, 1369`). Delete or demote the `…WithApplied` family
    (`1376-1435`) and drop `applied` threading from `expandBranchWithFuel`
    (`Saturation.lean:310-381`), the traced mirrors (`417-535`) and `CancellableExpansion.lean`.
    Prove `saturated_downward_closed` and `expandOnce_length_lt` (report 04 §Q1.4) — these are
    **mechanical unfolding lemmas** (`List.find?_eq_none`, `List.findSome?_eq_none_iff`), NOT an
    induction over `expandBranchWithFuel`. Estimated output: ~250-400 lines.
    **Done when**: the full corpus is unmoved (all 24 measured rows plus the existing
    `#guard_msgs` tables); every open certificate reports `findUnexpanded … = none`;
    `lake build` and `lake build BimodalTest` green.
    *(done, across two dispatches. The first landed the guards, non-destructive `expandOnce`,
    `expandOnceNoFresh` and the reproved `sat_*` family, and regressed row B in the two dense
    classes. The second repaired that regression (two defects, bisected — see the resolution
    note replacing the BLOCKER below) and landed `saturated_downward_closed`.
    **Deviation, recorded and escalated in the handoff**: `expandOnce_length_lt` is NOT landed.
    It needs a per-rule output-nonemptiness fact — the guards give `fs ≠ []` for the
    non-fresh-label `.linear` case only, and the `.persistent` and fresh-label `.linear` cases
    are rule-by-rule. The automated route is mapped: `unfold applyRule at h; repeat' split at h`
    plus `simp only [apply_ite Prod.fst] at h` reduces the whole thing to about seven uniform
    "`filterMap` of an `ite` is non-nil, given the guard failed" goals; a helper of the shape
    `(∃ a ∈ l, p a = false) → (l.filterMap fun a => if p a then none else some (f a)) ≠ []`
    discharges them, but the unifier did not take it as stated and the remaining work is
    finding the form it accepts. This is Phase 4.3's consumer, not Phase 7's.)*

**2.5 note — what landed, and the four deviations.**

Landed and green (`lake build` + `lake build BimodalTest`, zero new sorries/axioms/vacuous
defs): `ruleMintsFreshLabel` and `witnessPresent` (8 arms); guards on the `.linear` and
`.branching` results of `findApplicableRule`; non-destructive `expandOnce`; the `…WithApplied`
family demoted to inert wrappers; the "Certificate Strength (R5)" section rewritten to record
the refutation and the corrected diagnosis. **The headline result is measured**: the corpus R5
probe flips from `fullySaturated=false applied=3 orphans=3` to
`fullySaturated=true applied=0 orphans=0` on `◇p` — the certificate Phase 7 needs is reachable
on the pipeline's own output. `Branch.knownTimes` now retains the root time (`[0,2,1]` vs
`[2,1]` on W1-W7), confirming report 04 §Q2.2's predicted side effect.

Deviations, all forced and all recorded in-code:

1. *No output-presence guard on the `.persistent` arm*, contrary to the report's §Q1.4 sketch.
   It is provably dead code — every `.persistent` arm of `applyRule` already filters its own
   output, and `densityRule` emits at a fresh time — and adding it puts an extra `if` between
   the saturation lemmas and the filter structure they read. Same treatment for `untlNeg` and
   `snceNeg` via a new `ruleSelfGuarded`: report 04 §Q1.1 established both are already
   self-guarded by their `unprocessed` filter and re-include the source in every arm.
2. *Fresh-label branching rules use the witness guard **instead of** the output-presence test*,
   symmetric with the `.linear` arm, rather than in addition to it. Their arms live at a label
   the branch does not have, so the output test can never fire there.
3. *The `sat_*` family was reproved rather than merely re-elaborated.* `sat_imp_neg`,
   `sat_box_neg`, `sat_untl_pos` and `sat_snce_pos` were proved `exfalso` from
   `*_not_expanded` helpers asserting their formulas cannot occur on a saturated branch. Those
   helpers were true only of the destructive engine — which is exactly why the four facts were
   worthless — and the guards make them false. Each is now proved directly off the guard that
   suppressed the rule, and each has content for the first time. This is the MUST-PRESERVE
   `sat_*` family strengthened, not weakened.
4. *`branchTruthLemma` retired early* (Phase 7.1 directs "demote to a documented debugging aid
   or delete it — it must no longer appear in any proof path"). Its `imp`/`untl`/`snce` cases
   rested on the same vacuity; discharging them properly is the Phase 6 interpolation argument.
   `branchTruth` itself survives as an executable debugging aid with the rationale in-file.
   Nothing outside `CountermodelExtraction.lean` referenced it. *This is a `.lean` plan
   deviation and is raised in the handoff rather than only annotated here.*

Also landed, unplanned but forced: `expandOnceNoFresh` (`Tableau.lean`) and its use in
`saturateBlocked`. The post-pass previously abandoned the whole branch the moment the first
unexpanded formula needed a fresh label; under non-destructive expansion that happens
constantly, since sources persist. It now skips such candidates and stops only when no
label-free work remains. This is report 04 §Q1.5's flagged residual risk, materialised.

**Not landed** (carried to a follow-up unit): `saturated_downward_closed` and
`expandOnce_length_lt`. The four reproved `sat_*` lemmas are the load-bearing instances of the
former. The latter needs `formulas ≠ []` for every rule result the guards let through, which is
a per-rule argument (`denseIndicatorClosure` returns `.linear []`, suppressed by the guard, but
that is a rule-by-rule fact, not a generic one) — a bounded unit of its own, and Phase 4.3's
consumer.

**RESOLVED** (Phase 2, task 2.5) — the row B dense regression, and the two defects behind it.

Row B (`(F p ∧ F q) → (F(p ∧ F q) ∨ F(p ∧ q) ∨ F(q ∧ F p))`) now reads `CLOSED` at `.Base`,
`.Discrete`, `.Dense` and `.Dedekind`. It is the **only** row either repair moves; every other
row in all four class tables, plus `CertificateProbe` and `TimeOrderProbe`, is unmoved.

The bisection that separated the two defects, in the order it was run:

1. *Blocking against an unsaturated ancestor.* `findBlockedTime` decides subset blocking from
   formula content alone, and `type(t) ⊆ type(t_anc)` is only evidence of repetition once
   `t_anc` has finished expanding. Added `timeSaturated` / `isTemporallyBlockedSaturated` /
   `findBlockedTimeSaturated` (`Tableau.lean`, where `isExpanded` is in scope). **Measured: this
   alone did not move row B** — the halting branch's block was against interpolated time 4,
   which *is* saturated, so the side condition was satisfied.
2. *Blocking halting the branch rather than the time.* The halting state was
   `blockedSat=(some 3)` with `unexpanded=(some @time 0)`: one blocked interpolant was being
   treated as a verdict on the whole branch, abandoning it with propagation outstanding at the
   root, which has no ancestors and is therefore never blocked. Blocking now skips a blocked time
   as an expansion **source** (`blockedTimes`, `findUnexpandedUnblocked`, `expandOnceUnblocked`)
   and the branch counts as saturated only when no *unblocked* formula has an applicable rule.
   The branch-level early exit is gone from `expandBranchWithFuel`, its traced mirror and
   `CancellableExpansion`. **Measured: corpus completely unmoved** — necessary, not sufficient.
3. *`densityRule` diverging.* Deleting `densityRule` from `denseRules` made row B read `CLOSED`
   in all four classes, isolating it as the remaining cause. Its gap selection took the *head* of
   `futureOf l.time` and gave up if that one gap was filled; filling a gap adds a time, changes
   the head, and exposes a fresh unfilled gap, so it interpolated without bound *from the root* —
   which node-level blocking cannot stop, because the root is never blocked. Gap targets are now
   restricted to unfilled **maximal** elements of the source's future; an interpolant is never
   maximal, so the admissible-gap set shrinks as gaps are filled. **Measured at `.Dense`:
   `STALLED` at 30000 and 50000, `CLOSED` at 70000 and 100000** (before the guard, 120000 was
   still `STALLED`). Row B's per-row corpus fuel is raised 10000 → 100000; the run costs about a
   second per class, because fuel is a step budget and the proportional allocator hands most
   sub-branches a small share.

Also resynced in passing: `expandOnceWithAppliedTracedImpl` was still *destroying* its source and
picking via `findUnexpandedWithApplied`, so traced runs were reporting on a different engine from
the one `buildTableau` runs.

  - [ ] **2.6 (new) — `serialityRule` with globally-last scheduling** (`Tableau.lean` +
    `Saturation.lean`). Add the `serialityRule` constructor with
    `isApplicable .serialityRule _ _ = true` (keyed on the *label*, not the formula shape) and the
    `applyRule` arm emitting `T(F ⊤)` / `T(P ⊤)` at the label, self-suppressing once both are
    present — the tableau images of `Axiom.serial_future` / `Axiom.serial_past`
    (`Axioms.lean:113,117`), hence sound for every frame class. Keep it **out of
    `allRulesForFC`** entirely and give `expandOnce` a two-stage pick: ordinary rules first, and
    only when `findUnexpanded` returns `none` retry with `serialityRule` enabled. Add an in-code
    note contrasting this against the Dedekind **prepend** (`Tableau.lean:1295-1301`) — both are
    scheduling lessons, in opposite directions. Estimated output: ~150-250 lines.
    *(ATTEMPTED AND BACKED OUT — see the 2.6 blocker note below. The work is preserved verbatim
    at `specs/165_establish_semantic_finite_model_property/2.6-serialityRule-wip.patch`.)*
    **Done when**: `S1`-`S5` and `K2`-`K6` are CLOSED in all four class tables at
    `conformanceFuel = 200`; every control row and counterexamples `A`/`B` hold; the `.Discrete`
    `K2`/`K3` residual (report 04 §Q3.5) is either closed or documented with its cause isolated.
    **Depends on 2.5** — the prototype that produced 24/24 has both changes; seriality on the
    destructive engine was not measured and must not be attempted separately.

**BLOCKER** (Phase 2, task 2.6) — `serialityRule` is written and correct, and makes the engine
too slow to build.

- **What was built** (all of it, preserved in `2.6-serialityRule-wip.patch`): the
  `serialityRule` constructor; `isApplicable .serialityRule _ _ = true` keyed on the label;
  the `applyRule` arm emitting `T(F ⊤)` / `T(P ⊤)` filtered against the branch and
  self-suppressing once both are present; `serialityRules` / `findApplicableSerialRule` /
  `findUnexpandedSerial` kept **out** of `allRulesForFC`; the globally-last two-stage pick in
  both `expandOnce` and `expandOnceUnblocked` (blocked times skipped in *both* stages); the
  `ruleToString` case; and the in-code note contrasting the scheduling against the Dedekind
  prepend. `lake build FormalSystem.Metalogic.Decidability.Tableau` is green with all of it.
- **What failed**: `lake build FormalSystem.Metalogic.Decidability.Saturation` — that file's own
  inline `#eval` smoke suite — exceeds **590 s** (it takes about 8 s without the rule), and
  `lake build BimodalTest.TableauConformance` likewise goes from 8 s to over 590 s. No verdict
  could be measured, because nothing finishes.
- **What was tried**: `blockedTimes` was being computed twice per expansion step (once inside
  `findUnexpandedUnblocked`, once by the seriality stage); split into
  `findUnexpandedUnblockedWith` so one call is shared. Real fix, no measurable effect here.
- **Why stuck — and this is the substantive finding**: report 04 §Q3.5 states plainly that with
  seriality on, "**every** genuinely-open row terminates as `OPEN-blocked` rather than
  `OPEN-sat`". The 24/24 measurement therefore rests on the *branch-level* blocking halt: the
  serial chain `T(F⊤)@t ⟶ t' ⟶ t'' ⟶ …` was terminated by the whole branch being handed back the
  moment any time blocked. Sub-phase 2.5 had to **remove** that halt — it is defect (2) in the
  resolution note above, the direct cause of the row B regression. So 2.6's measurement basis and
  2.5's repair are in tension, and that tension was not visible in the report, which measured a
  prototype carrying the old halt. Node-level blocking does bound the chain (each new time is
  blocked within a step or two and the rule then has no unblocked label to serve), so this is a
  cost problem, not a termination problem — but it is a cost problem large enough to stop the
  build.
- **What is needed**: a bounded dispatch that profiles the seriality-on engine and decides
  between (a) making blocked times cheap enough to compute per step — `blockedTimes` runs a
  `timeSaturated` test per surviving ancestor pair, and seriality roughly doubles branch length,
  so the inner loop is the obvious suspect and caching the blocked set across steps of one
  branch is the obvious fix; (b) suppressing seriality at labels that cannot contribute (its
  outputs are only ever consumed by `someFuturePos` / `somePastPos`, so a label whose successor
  already exists needs neither); or (c) re-measuring the report's 24/24 against the repaired
  blocking to find what the real fuel requirement now is. Applying the patch is step 0 of that
  dispatch; nothing needs re-deriving.
- **Prohibited**: no `sorry`, no vacuous placeholder, and no axiom was introduced. The tree was
  returned to the last green commit rather than left un-buildable.

  - [ ] **2.7 (new) — per-branch time orderings + `timeLinearity`** (`Tableau.lean` +
    `Saturation.lean` + `CancellableExpansion.lean`). Additive
    `RuleResult.branchingOrdered (branches : List (List SignedFormula × TimeOrdering))` and
    `ExpansionResult.split (branches : List (Branch × TimeOrdering))`; plumbing per report 04
    §Q2.4's table (`expandOnce`, `expandBranchWithFuel` `.split` arm at `Saturation.lean:375`,
    `saturateBlocked`, the traced mirrors, `CancellableExpansion.lean`). Existing rules are
    unaffected: `.branching bss` translates to `bss.map (·, newOrd)`, the current behaviour
    verbatim, so no conformance verdict can move from the plumbing alone. Add
    `Branch.identifyTime` / `TimeOrdering.identifyTime` and the `timeLinearity` base rule with
    **three** arms — `ord.addFuture t₁ t₂`, `ord.addFuture t₂ t₁`, and the identification arm
    (arm 3 cannot be dropped: the two-arm version forces distinctness and loses models in which
    one instant witnesses both existentials). Keep `orderTrichotomy` — it is sound and fixed
    counterexample B; it simply mints fresh witness times rather than ordering existing ones, so
    it is the formula-level companion, not a replacement. Estimated output: ~300-450 lines;
    split into 2.7a (plumbing, zero verdict movement) and 2.7b (the rule) if one dispatch is not
    enough. **Done when**: `timeOrderTotal` holds of every open certificate in the corpus; the
    W1-W7 rows pinned in 2.8 flip; no verdict moves except intended ones.
  - [ ] **2.4 R5 — certificate strengthening** *(restated 2026-07-27; was BLOCKED)*
    (`Saturation.lean:50-59`): strengthen `ExpandedTableau.hasOpen` to carry `(fc : FrameClass)`
    and the proposition

    ```lean
    saturated : findUnexpanded openBranch (timeOrd := timeOrdering) (fc := fc) = none
                ∨ (findBlockedTime openBranch timeOrdering tracker).isSome
    ```

    and **delete the applied set from the certificate**. The `fc` field repairs a latent defect
    found in report 04 §Q1.3: `findUnexpandedWithApplied`'s `fc` argument defaults to `.Base` and
    is supplied at neither `hasOpen` nor the two `buildTableau` sites (`Saturation.lean:667, 676`)
    nor `BranchListResult.foundOpen` (`155-158`), so the certificate currently certifies `.Base`
    saturation for all four classes. Keep the "Certificate Strength (R5)" section
    (`Saturation.lean:76-113`) but **rewrite** it: record that `AppliedRedundant` was *refuted*
    (cite the four failing formulas) and record the corrected diagnosis — destruction, not
    persistent-rule re-firing. Retire `appliedEntryRedundant` / `AppliedRedundant` or demote them
    to documented historical predicates; nothing may depend on them.
    Estimated output: ~150-300 lines. **Done when**: `hasOpen` carries `fc` and the disjunction;
    the pipeline's certificate is constructible for `◇p`; the R5 section reflects the refutation;
    build green. **Depends on 2.5 and 2.6.**
- **Timing:** ~8 dispatches, ~20 hours. **Order: 2.8 → 2.5 → 2.6 → 2.7 → 2.4.**
- **Depends on:** 1

### Phase 3: RuleSpec Gate — Self-Enforcing Frame-Class Composition [NOT STARTED]

- **Goal:** The rule lattice is machine-tied to the axiom lattice, so mis-gating a rule breaks
  the build instead of drifting silently (the focus requirement's core mechanism, 02 §8.3).
- **Tasks:**
  - [ ] Create `Decidability/Verified/RuleSpec.lean`: `ruleFrameClass : TableauRule → FrameClass`,
    `ruleAxioms : TableauRule → List (Σ φ, Axiom φ)` over the full post-Phase-2 constructor set
    (**36** — 34 today plus `serialityRule` from 2.6 and `timeLinearity` from 2.7), and the two
    GATE lemmas, both `by decide` over the finite product: `ruleAxioms_minFrameClass_le` and
    `mem_allRulesForFC_iff`. Both new rules gate to `.Base`: `serialityRule` to
    `Axiom.serial_future` / `Axiom.serial_past`, `timeLinearity` to `Axiom.temp_linearity` (same
    as `orderTrichotomy`). Because `serialityRule` is deliberately **not** in `allRulesForFC`
    (its scheduling is the two-stage pick in `expandOnce`, 2.6), `mem_allRulesForFC_iff` needs an
    explicit **exclusion clause** for it — without one the `by decide` gate fails confusingly.
    Include a `Verified/README.md` stub describing the 02 §8.2 layout.
- **Estimated output:** ~150-250 lines.
- **Done when:** both gates proved `by decide`; deliberately mis-gating one rule locally (then
  reverting) is confirmed to fail the build — evidence in the phase summary.
- **Timing:** 1 dispatch, ~2.5 hours.
- **Depends on:** 2
- **Territory:** `Verified/RuleSpec.lean`, `Verified/README.md` only.

### Phase 4: Termination (WP3: T1, T2, T3) [NOT STARTED]

- **Goal:** `buildTableau` totality at a justified, uncapped fuel; the pigeonhole argument is
  about real blocking (possible only now that Phase 1.3 made blocking genuine).
- **Tasks:**
  - [ ] **4.1 T1 — `applyRule_subformula_closed`** (`Verified/Termination/SubformulaProperty.lean`,
    new): the generalized signed subformula property over all **36** rule cases against the signed,
    negation-closed closure — `closureWithNeg` for the Discrete rules (constraint 7;
    `priorUZ` emits `U(φ, ¬φ)`); `untlPos` branch 2 re-emits `U(e,g)` itself so no
    Fischer-Ladner unwinding is needed. The two new cases are mechanical: `serialityRule` emits
    `F⊤`/`P⊤` and `⊤ = ⊥ → ⊥`, so `closureWithNeg` already contains it; `timeLinearity` emits
    **no formulas** in arms 1-2 and only relabels in arm 3 (which must be shown label-only).
    Estimated output: ~300-500 lines (mechanical cases).
    Done when: theorem sorry-free; the `priorUZ`/`priorSZ` and `densityRule` cases have explicit
    comments; build green.
  - [ ] **4.2 T2 — pigeonhole** (`Verified/Termination/TimeTypeBound.lean`, new):
    `blocking_fires_of_card_lt` via `Finset.exists_ne_map_eq_of_card_lt_of_maps_to` (verified
    to exist, 02 §4.3; `Fintype.exists_ne_map_eq_of_card_lt` does NOT exist — constraint 2
    applies to any further name checks). Bound `2^(2·|signedClosure φ|)` time-types; the
    trichotomy rule increases branching but not the time-type count, so the bound is R2-stable
    (02 §4.4). Estimated output: ~150-300 lines. Done when: theorem sorry-free; build green.
  - [ ] **4.3 T3 — justified fuel** (`Verified/Termination/Fuel.lean`, new): define uncapped
    `soundFuel'` (exponential closed form tied to the T2 bound — a quadratic constant cannot
    cover an exponential step count, 03 §4.3) and prove `buildTableau_isSome`. Keep capped
    `soundFuel` as the runtime default (constraint 11). This also separates the two open-branch
    populations: at `soundFuel'`, fuel exhaustion is impossible, so downstream phases handle
    only genuinely-saturated branches (03 §4.4). Estimated output: ~200-400 lines. Done when:
    `buildTableau_isSome` sorry-free; `#eval` runtime behavior unchanged; build green.
- **Timing:** 3 dispatches, ~9 hours.
- **Depends on:** 2 (rule set final; blocking genuine since 1.3)
- **Territory:** `Verified/Termination/` only.

### Phase 5: Bridge Infrastructure (BranchOrder, Embed, Carrier) [NOT STARTED]

- **Goal:** A saturated branch's time structure is packaged as a finite total order and embedded
  into each class's concrete carrier through one abstract interface — the only place the four
  classes genuinely diverge (02 §8.4).
- **Tasks:**
  - [ ] **5.1 `Verified/Bridge/BranchOrder.lean`** (new) *(rewritten 2026-07-27; the original
    "trichotomy now guarantees totality" premise was refuted by measurement — report 04 §Q2.1)*:
    from a saturated branch **carrying `timeOrderTotal`** (the decidable gate landed in 2.8 and
    discharged by `timeLinearity` in 2.7) package `BranchOrder b ord : LinearOrder (Fin n)`.
    Index `Fin n` over the times occurring in `ord` **union** `b.knownTimes` — or note that 2.5's
    non-destructive expansion keeps the root time in `knownTimes` and makes the simple
    `n = b.knownTimes.length` indexing correct. (Pre-2.5, destruction emptied the root time, so
    `constraints = [(0,2),(0,1)]` with `knownTimes = [2,1]` induced the **empty** order on
    `knownTimes` — report 04 §Q2.2.) **Non-goal, explicitly**: do NOT attempt a Mathlib linear
    extension of a partial branch order (`extend_partialOrder` / `LinearExtension`). It is
    **unsound**, with a measured counterexample: in `¬(F(G p) ∧ F(¬p))` the incomparable siblings
    carry `T(G p)` and `F(p)`, so exactly one of the two extensions is a model and the branch does
    not record which (report 04 §Q2.3). The same argument kills "propagate universals to
    incomparable times". Record in-code the SETTLED blocking semantics decision
    (identification/deletion, never edge — constraint 4) that the unwinding of blocked loops will
    use; `identifyTime` now arrives from 2.7 and is shared. Estimated output: ~150-300 lines.
    Done when: `BranchOrder` sorry-free with a totality proof consuming `timeOrderTotal`;
    build green.
  - [ ] **5.2 `Verified/Bridge/Embed.lean` + `Verified/Bridge/Carrier.lean`** (new):
    `class TemporalCarrier (fc) (D)` with `embed_finite` and `frame_condition` fields (02 §8.4);
    instances `.Base ℚ`, `.Dense ℚ`, `.Discrete ℤ`, `.Dedekind ℝ`. ℚ/ℝ `embed_finite` via
    `Order.embedding_from_countable_to_dense` (verified, `Mathlib.Order.CountableDenseLinearOrder`);
    ℤ via a hand-rolled monotone `Fin n ↪o ℤ` (dense embedding does NOT apply to ℤ — separate
    lemma, no attempted reuse). Dedekind `frame_condition` in `ValidDedekindDense` shape via
    `Real.isLUB_sSup`; Discrete instances from `Mathlib.Data.Int.SuccPred`. All Mathlib-name
    checks under project imports with a control error (constraint 2). Estimated output:
    ~200-350 lines. Done when: all four instances elaborate sorry-free; build green.
- **Timing:** 2 dispatches, ~6 hours.
- **Depends on:** 2 (5.2's order theory is independent of the rule set, but wave-3 scheduling
  keeps territory clean; 5.1 needs R2 totality)
- **Territory:** `Verified/Bridge/{BranchOrder,Embed,Carrier}.lean` only.

### Phase 6: Interpolation — the Mathematical Core (WP4 stage 3) [NOT STARTED]

- **Goal:** A total model on the carrier `D`, constant on half-open intervals between embedded
  branch times, with truth invariance on each interval — the countermodel's engine
  (`Verified/Bridge/Interpolate.lean`, new; 02 §5.2 stage 3).
- **Tasks:**
  - [ ] **6.1 Model construction + propositional/modal invariance**: define the constant-on-
    `[d_i, d_{i+1})` valuation extension (total on `D` — never an island, constraint 6); prove
    `interp_invariance` for atoms, propositional connectives, and `box` (universal over `Omega`,
    no accessibility). Estimated output: ~200-350 lines. Done when: those cases of the induction
    are sorry-free with the temporal cases stated and the file structured so 6.2/6.3 fill them;
    intermediate `sorry`s here are FORBIDDEN — instead split the theorem into per-case lemmas so
    each sub-phase lands complete lemmas only.
  - [ ] **6.2 Temporal universal/existential cases**: `allFuture`/`allPast`/`someFuture`/
    `somePast` cases of `interp_invariance`, consuming the repaired transitive ordering facts and
    the branch saturation (`sat_*`) facts. Estimated output: ~200-400 lines. Done when: cases
    sorry-free; build green.
  - [ ] **6.3 `untl`/`snce` cases**: discharge the open-interval guard using the trichotomy-
    certified fact that the guard holds at every branch time strictly between source and witness
    (producible only post-R2; `untlPos` branch 2 is NOT a semantic decomposition — 02 §2.6).
    Estimated output: ~200-400 lines. **Bounded-unit stopping condition**: if after one full
    dispatch the `untl` case is not closed, do NOT churn — the implementer stops, writes a
    precise obstruction note (which saturation fact is missing), and the orchestrator either
    adds one targeted saturation-fact sub-phase (6.4, deriving the missing branch fact from the
    R2 rules) or escalates to a plan revision. No third attempt on the same formulation without
    a revision (H5/H6).
- **Timing:** 3 dispatches, ~10 hours.
- **Depends on:** 2, 5
- **Territory:** `Verified/Bridge/Interpolate.lean` only.

### Phase 7: Truth Lemma and Track A Decidability — MILESTONE [NOT STARTED]

- **Goal:** **Headline result 1**: `not_valid_of_hasOpen` generic in the carrier, semantic rule
  soundness, and `Decidable` instances for all four frame classes. On completion this task has
  delivered standalone publishable value regardless of Track B's fate.
- **Tasks:**
  - [ ] **7.1 `Verified/Bridge/Omega.lean` + `Verified/Bridge/TruthLemma.lean`** (new): build
    `WorldHistory`/`Omega` with total `domain := fun _ => True` and universal `TaskRel`
    (report 01 F6 — verified sound); `ShiftClosed` via `time_shift_preserves_truth`
    (`Truth.lean:446`) per report 01 F9, `Set.univ_shift_closed` as fallback; prove
    `not_valid_of_hasOpen` generic in `TemporalCarrier`, consuming the `sat_*` family verbatim.
    **Hypothesis change (2026-07-27, report 04 §Q3.5)**: `not_valid_of_hasOpen` consumes the
    restated 2.4 certificate — `fc`-indexed saturation **or blocked** — plus `timeOrderTotal`.
    Once `serialityRule` lands (2.6) no open branch is ever fully saturated in the
    `findUnexpanded = none` sense (seriality always demands one more successor), so **the blocked
    disjunct is the normal case for open branches**, not a corner case: the
    loop-unwinding/identification argument (settled semantics: identification/deletion, never
    edge) is on the critical path. Budget accordingly — the ~250-450 line estimate is a **floor**.
    Demote `branchTruth` (`CountermodelExtraction.lean:263`) to a documented debugging aid or
    delete it — it must no longer appear in any proof path. Estimated output: ~250-450 lines
    (floor). Done when: theorem sorry-free at the abstract carrier; four class specializations
    elaborate.
  - [ ] **7.2 Semantic rule soundness** (`Verified/Decidable.lean`, new): the `allClosed → valid`
    direction as ONE induction over `allRulesForFC fc` (each rule preserves satisfiability),
    using `mem_allRulesForFC_iff` from Phase 3 — no per-class re-proof (SETTLED
    parameter-not-files decision). Estimated output: ~250-450 lines. Done when: sorry-free for
    all four classes via the single induction; build green.
  - [ ] **7.3 `valid_iff_allClosed` + `Decidable` instances**: combine 7.1, 7.2, and
    `buildTableau_isSome` (4.3) into `Decidable (⊨ φ)` and the `ValidDense` / `ValidDiscrete` /
    `ValidDedekindDense` variants; replace nothing in the engine — instances live in
    `Verified/Decidable.lean`. Run the FULL conformance corpus as the acceptance gate.
    Estimated output: ~150-300 lines. Done when: all four instances sorry-free; conformance
    corpus green with zero expected-failure rows remaining for validity verdicts; **green
    milestone commit** per wrap-up discipline.
- **Timing:** 3 dispatches, ~9 hours.
- **Depends on:** 3, 4, 6

### Phase 8: Hygiene — Vacuous Theorems and Documentation [NOT STARTED]

- **Goal:** No vacuous theorems remain in `Decidability/`; documentation matches reality.
- **Tasks:**
  - [ ] Delete `validity_decidable` and `validity_has_decision_procedure`
    (`Correctness.lean:78,91`); point their former use sites (if any) at the Phase 7 instances;
    state `isValid φ fc = true ↔ ⊨ φ`-shaped replacements where natural.
  - [ ] Replace `filtered_world_bound` and `fmp_size_bound` (`FMP/FMP.lean:183,237`) with the
    real bound — report 01 F8 machine-verified `Nat.card (Set ↥cl) = 2 ^ cl.card` as an equality.
  - [ ] Documentation: `latex/subfiles/04-Metalogic.tex:351` (mark the `2^|cl(φ)|` claim proved
    or conjectural per what actually landed); `typst/chapters/p2-decidability-practice.typ:42`
    (same), `:70,112` (update the deleted-theorem references), `:26-28` (record Track A's
    completion of the semantics bridge).
- **Estimated output:** ~150-250 lines (Lean + LaTeX + typst diffs).
- **Done when:** `grep` confirms no `∧ True`-padded or `Classical.em` theorem bodies remain in
  `Decidability/`; `lake build` green; doc builds unaffected.
- **Timing:** 1 dispatch, ~2.5 hours.
- **Depends on:** 7

## Planned Strategic Sorries

`plan_metadata.skeleton: true`. The division points below are whole deferred obligations, not
in-file `sorry` placeholders — this task's tree stays sorry-free (Postmortem constraint 8); the
one pre-existing repo sorry is row 3's file/line. Columns map field-for-field onto the
`wrap-up.md` `sorry_inventory` schema.

| Division Point | File / Line / Statement | Assumption | Why Deferred | Follow-Up Task |
|-----------------|--------------------------|------------|---------------|----------------|
| Branch internalization + routine admissibility (WP2 part 1) | TBD — `Decidability/Verified/Internalize.lean`, `Verified/Refutation/Rules/{Propositional,Modal,Temporal}.lean` (not created in this task); statement shape `rule_admissible` per report 02 §3.1 | Labelled branches internalize into single formulas (world labels via □/◇, time labels via U/S guards realizing `TimeOrdering`); no cut/substitution admissibility needed (SETTLED internalization design); `z1Rule`'s two premises kept at one label | Track A needs none of the Hilbert-side work; ~21 routine lemmas are the cheaper half of WP2 but still exceed this task's phase ceiling | 410 |
| Hard admissibility block: `untlNeg` Reynolds co-decomposition, `untlPos`, `orderTrichotomy`, `z1Rule`, Dense, Dedekind rules (WP2 part 2) | TBD — `Verified/Refutation/Rules/{UntilSince,Trichotomy,Discrete,Dense,Dedekind}.lean` (not created in this task) | Axioms `self_accum_until`/`absorb_until`/`until_F`/`temp_linearity`/`z1`/`prior_U_gap`/`prior_S_gap`/`sep` suffice; trichotomy branches syntactically equal the `temp_linearity` disjuncts (guaranteed by Phase 2.2's SETTLED design) | Research-grade lemmas (02 §3.2-3.3: `untlNeg` is "the single largest lemma"); benefits from a `/literature` acquisition of Reynolds 1992/2003 first (02 §10) | 411 |
| Decidability of provability + completeness corollaries (Track B finish) | `FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1242` — `countermodel_discrete` (pre-existing `sorry`, deliberately untouched by this task); plus TBD `Verified/Refutation/Core.lean` (`allClosed_derivable`), `Verified/Provable.lean` (`Decidable (Derivable fc [] φ)`) | `allClosed_derivable` as one induction over `allRulesForFC` discharged by the admissibility lemmas + `ruleFrameClass ≤ fc` (Phase 3 gate fixes the lemma shape); with T3 totality this yields `Decidable (Derivable fc [] φ)`, the completeness corollaries, and the Dedekind engine for `completeness_dedekind_of_engine` (`StrongCompleteness.lean:308`) | Requires both admissibility follow-ups complete; only Track B discharges `countermodel_discrete` (02 §8.5 — "corollary of WP2", not of WP3+WP4) | 412 |

## Testing & Validation

- [ ] Conformance corpus (`Tests/BimodalTest/TableauConformance.lean`) green per frame class at
  every phase boundary from 1.1 onward; failing rows only ever documented expected-current
  failures scheduled to flip.
- [ ] Report 02 §2.2-2.4 probes committed as `#eval` regressions and re-run at each repair
  sub-phase (probe-first, constraint 1).
- [ ] `lake build` green at every sub-phase close; green sub-steps committed per the
  commit-per-green-substep mandate.
- [ ] `Saturation.lean` in-file `#eval` suite (lines ~700-1600) green or explicitly updated.
- [ ] Every Mathlib-name verification run with a deliberate control error (constraint 2).
- [ ] Sorry census at task close: exactly one repo sorry (`Transfer.lean:1242`) remains, matching
  the Planned Strategic Sorries table row 3.
- [ ] Phase 3 gate negative test: transient mis-gating fails the build (evidence in summary).
- [ ] Runtime sanity: `decide`'s `#eval` behavior on the corpus does not visibly degrade after
  R2/T3 (capped `soundFuel` retained as runtime default).

## Artifacts & Outputs

- `specs/165_establish_semantic_finite_model_property/plans/01_tableau-decidability-two-track.md` (this file)
- `specs/165_establish_semantic_finite_model_property/.skeleton-return.json` (follow-up task declarations)
- New: `Tests/BimodalTest/TableauConformance.lean`
- New: `FormalSystem/Metalogic/Decidability/Verified/{RuleSpec.lean, README.md}`,
  `Verified/Termination/{SubformulaProperty,TimeTypeBound,Fuel}.lean`,
  `Verified/Bridge/{BranchOrder,Embed,Carrier,Interpolate,Omega,TruthLemma}.lean`,
  `Verified/Decidable.lean`
- Modified: `Decidability/{SignedFormula,Tableau,Saturation,Closure,DecisionProcedure,Correctness,CountermodelExtraction}.lean`, `FMP/FMP.lean`
- Modified docs: `latex/subfiles/04-Metalogic.tex`, `typst/chapters/p2-decidability-practice.typ`
- `summaries/01_tableau-decidability-two-track-summary.md` on completion

## Rollback/Contingency

- Every sub-phase ends in a green commit; rollback is `git revert` of the offending sub-phase
  commits — never destructive git on a dirty tree (snapshot via `git-snapshot.sh` first if
  needed).
- The `Verified/` subtree is additive; if waves 3-5 stall, waves 1-2's calculus repairs stand
  alone as committed value (the engine is strictly less wrong than before).
- If Phase 2.2's branching restriction proves refutation-incomplete (a conformance row that
  should close stays open), widen the restriction stepwise rather than reverting R2 — the
  unrestricted rule is the known-sound fallback, at fuel cost absorbed by T3's uncapped bound.
- If Phase 6.3 hits its stopping condition twice, escalate to `/revise` with the obstruction
  note; do not convert to an in-file sorry (constraint 8).
