# Implementation Plan: Verified Tableau Decidability of TM (Two-Track, Skeleton)

- **Task**: 165 - establish_semantic_finite_model_property (rescoped to tableau decidability)
- **Status**: [IMPLEMENTING]
- **Effort**: ~50 hours (Track A scope carried by this task; Track B deferred to follow-up tasks)
- **Dependencies**: None
- **Research Inputs**:
  - reports/02_tableau-decidability-hard-research.md (PRIMARY — hard-mode audit; trust its §9 H4 tables over the charter where they conflict)
  - reports/03_cslib-tableau-survey.md (supplementary — cslib patterns and anti-lessons)
  - reports/01_semantic-fmp-research.md (background only; semantic-FMP route out of scope; F4/F5/F6/F8/F9 remain valid and are reused)
- **Artifacts**: plans/01_tableau-decidability-two-track.md (this file)
- **Standards**: .claude/context/formats/plan-format.md; .claude/rules/plan-format-enforcement.md; .claude/rules/artifact-formats.md; .claude/rules/state-management.md; .claude/context/formats/status-markers reference in plan-format.md
- **Type**: lean4
- **Plan Metadata**: `skeleton: true` (Stage 4a escape valve — full scope exceeds the 8-phase hard-mode ceiling); `follow_up_tasks: [410, 411, 412]` (allocated by skill postflight); `dependency_waves: [[1],[2],[3,4,5],[6],[7],[8]]`

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
    30 constructors total; after R2 (+1) and R6 (+3) the case count is ~34 (02 §1.2, §9).
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

### Phase 2: Calculus Completion (R7, R2, R6, R5) [NOT STARTED]

- **Goal:** The rule set is adequate and honestly reported: trichotomy branching exists, Dedekind
  rules exist, the `.timeout` conflation is split, and the open-branch certificate is strong
  enough for a truth lemma.
- **Tasks:**
  - [ ] **2.1 R7 — verdict split** (`DecisionProcedure.lean:64,128,152,161`): split `.timeout`
    into `.fuelExhausted` / `.extractionFailed` so a closed tableau is never reported undecided;
    reprove `decide_result_exclusive` (`Correctness.lean:101`); update the conformance verdict
    adapter. Estimated output: ~100-200 lines. Done when: build green; conformance suite green
    with the new verdict vocabulary.
  - [ ] **2.2 R2 — `orderTrichotomy`** (`Tableau.lean`): new `TableauRule` constructor +
    `isApplicable` + `applyRule` case, branches syntactically the `temp_linearity` disjuncts
    (SETTLED decision); branching restricted to incomparable AND relevant time pairs (shared
    world + shared temporal formula) to contain `3^k` blowup. Re-run the §2.3 probe.
    Estimated output: ~200-350 lines. Done when: counterexample B closes; conformance corpus and
    `Saturation.lean` `#eval` suite green; branching-restriction rationale documented in-code.
  - [ ] **2.3 R6 — `dedekindRules`** (`Tableau.lean:1067`): design tableau counterparts for
    `prior_U_gap`/`prior_S_gap`/`sep` (`Axioms.lean:377,387,398`; the first two involve
    `K⁺`/`K⁻`, `Formula.lean:180,193`); add the `allRulesForFC` Dedekind arm
    (base + dense + dedekind, preserving `Discrete ≰ Dedekind`). Add Dedekind conformance rows
    (the three axiom instances close). Estimated output: ~150-300 lines. Done when: Dedekind
    axiom instances close; no regression in other classes' corpora; build green.
  - [ ] **2.4 R5 — certificate strengthening** (`Saturation.lean:50-59`): strengthen
    `ExpandedTableau.hasOpen` to certify `findUnexpanded … = none` (or restate against the
    applied-set predicate with a proved semantic-redundancy lemma — pick ONE, record the choice);
    fix the D4 orphan situation so a truth lemma's hypothesis is actually met by the pipeline
    (witness: `◇p`). Estimated output: ~150-300 lines. Done when: a `#eval` shows the pipeline's
    open certificate satisfies the strengthened predicate on `◇p`; build green.
- **Timing:** 4 dispatches, ~10 hours.
- **Depends on:** 1

### Phase 3: RuleSpec Gate — Self-Enforcing Frame-Class Composition [NOT STARTED]

- **Goal:** The rule lattice is machine-tied to the axiom lattice, so mis-gating a rule breaks
  the build instead of drifting silently (the focus requirement's core mechanism, 02 §8.3).
- **Tasks:**
  - [ ] Create `Decidability/Verified/RuleSpec.lean`: `ruleFrameClass : TableauRule → FrameClass`,
    `ruleAxioms : TableauRule → List (Σ φ, Axiom φ)` over the full post-Phase-2 constructor set
    (~34), and the two GATE lemmas, both `by decide` over the finite product:
    `ruleAxioms_minFrameClass_le` and `mem_allRulesForFC_iff`. Include a `Verified/README.md`
    stub describing the 02 §8.2 layout.
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
    new): the generalized signed subformula property over all ~34 rule cases against the signed,
    negation-closed closure — `closureWithNeg` for the Discrete rules (constraint 7;
    `priorUZ` emits `U(φ, ¬φ)`); `untlPos` branch 2 re-emits `U(e,g)` itself so no
    Fischer-Ladner unwinding is needed. Estimated output: ~300-500 lines (mechanical cases).
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
  - [ ] **5.1 `Verified/Bridge/BranchOrder.lean`** (new): from a saturated branch (trichotomy
    now guarantees totality) package `BranchOrder b ord : LinearOrder (Fin n)`,
    `n = b.knownTimes.length`. Record in-code the SETTLED blocking semantics decision
    (identification/deletion, never edge — constraint 4) that the unwinding of blocked loops
    will use. Estimated output: ~150-300 lines. Done when: `BranchOrder` sorry-free with a
    totality proof consuming the R2 saturation facts; build green.
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
    Demote `branchTruth` (`CountermodelExtraction.lean:263`) to a documented debugging aid or
    delete it — it must no longer appear in any proof path. Estimated output: ~250-450 lines.
    Done when: theorem sorry-free at the abstract carrier; four class specializations elaborate.
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
