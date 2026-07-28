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
5. ~~**Phase 7.1 hypothesis changed**: the certificate's saturation field becomes a disjunction
   (`findUnexpanded … = none ∨ blocked`), and the blocked disjunct is the *normal* case for open
   branches once `serialityRule` lands.~~ **WITHDRAWN 2026-07-27b** — see revision item 5 of the
   second revision note below. The disjunction is refuted by measurement; Phase 7.1 gains a
   *documentation obligation* instead of a hypothesis change.

## Revision (seriality performance + length lemma) — 2026-07-27b

Second in-place revision, absorbing
`reports/05_seriality-performance-and-length-lemma.md`, the blocker-resolution dispatch for
sub-phase 2.6 and the `expandOnce_length_lt` residual. That report's "Recommended plan delta" is
the settled design and overrides both the pre-revision text and, where they conflict, report 04's
Phase-7-facing predictions. The changes it makes to this file:

1. **2.6 unblocked, and its blocker note replaced by a resolution note.** The 70x+ blowup was
   diagnosed as a *termination* defect, not a per-step cost: `ancestorTimes ord t = ord.pastOf t`
   (`SignedFormula.lean:782-783`) is the sole source of blocking candidates, and a time minted by
   `somePastPos` is a new global minimum whose `pastOf` is empty — so the past-directed serial
   chain is unblockable by construction and runs to fuel exhaustion. The fix is the four-line
   `blockCandidates` helper (order-related times filtered to strictly-earlier creation index;
   fresh times are `maxTime + 1`, so numeric order **is** creation order). 2.6 now names
   `blockCandidates` as part of the sub-phase, and the `.Discrete` `K2`/`K3` residual report 04
   flagged **closes** rather than needing documentation. Measured: `…Decidability.Saturation`
   590 s+ → 8.5 s; `BimodalTest.TableauConformance` 590 s+ → 35 s.
2. **`expandOnce_length_lt` restated as `expandOnceUnblocked_length_lt`, with a companion.**
   `expandBranchWithFuel` calls `expandOnceUnblockedWithApplied` (`Saturation.lean:407`) →
   `expandOnceUnblocked` (`Tableau.lean:1929`); nothing on the proof path calls `expandOnce`. The
   `filterMap` helper the previous revision called for is a **refuted** diagnosis — the
   obstruction was `split at h` not seeing through `(if c then … else …).1`, dissolved by
   `simp only [apply_ite Prod.fst] at h`, leaving `¬ l.isEmpty = true → l ≠ []`. Phase 4.3 is
   pointed at the strictly stronger `expandOnceUnblocked_adds_new` (`b ⊆ nb ∧ ∃ g ∈ nb, g ∉ b`),
   because `b.length < nb.length` alone cannot bound the step count (`nb = fs ++ b` may
   duplicate); the length lemma is retained as a corollary and sanity lemma.
3. **2.7's done-criterion baseline moves.** Unchanged in kind, but after 2.6 the W5/W6 controls
   flip `total=true → false` (seriality mints times `timeLinearity` does not yet order), so the
   criterion is now "**all seven** W-rows read `total=true`", not "W1-W4 flip".
4. **2.4's certificate stays a single conjunct.** The `∨ (findBlockedTime …).isSome` disjunct is
   deleted before it is written. `CertificateProbe` measures `fullySaturated=true applied=0
   orphans=0` on genuinely-open rows (`G p → p`) with seriality on, because `serialityRule` is
   deliberately outside `allRulesForFC` and hence outside `findUnexpanded`. The `fc` field repair
   and the applied-set deletion are unaffected.
5. **Phase 7.1 gains a documentation obligation, not a hypothesis change** (supersedes revision
   item 5 above). The truth lemma must *state* that `findUnexpanded = none` means "no **ordinary**
   rule applies", so a saturated branch may still be owed `T(F ⊤)`/`T(P ⊤)` at every label. These
   are true at every point of any serial frame, so the extracted model is unaffected — but the gap
   is named rather than assumed, and the certificate is not changed to hide it.

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

### Phase 2: Calculus Completion (R7, R2, R6, R5) [COMPLETED]

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
    Prove `saturated_downward_closed` and `expandOnceUnblocked_length_lt` (report 04 §Q1.4;
    **renamed 2026-07-27b** from `expandOnce_length_lt` — `expandOnce` has no proof-path caller,
    `Saturation.lean:407` → `Tableau.lean:1929`), plus `expandOnceUnblocked_adds_new` — these are
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
    finding the form it accepts. This is Phase 4.3's consumer, not Phase 7's.
    **RESOLVED 2026-07-27b: landed.**
    **CORRECTION 2026-07-27b (report 05 §Q2.2, measured): the `filterMap`/unifier diagnosis in
    the paragraph above is REFUTED.** `split at h` cannot see through the `Prod.fst` projection
    in `(if c then … else …).1`, so the seven guard `ite`s were never opened and the surviving
    goal only *looked* like a `filterMap` statement. Inserting `simp only [apply_ite Prod.fst]
    at h` into the loop opens all of them and the residual obligation is `¬ l.isEmpty = true →
    l ≠ []`, which plain `simp` closes — no helper of any shape is needed. A second, independent
    trap explains "the helper compiles but does not fire": `first | simp_all | <fallback>` never
    reaches the fallback, because `simp_all` reports success whenever it makes any progress, even
    leaving the goal open. Landed 2026-07-27b as `expandOnceUnblocked_length_lt` (renamed) with
    the companion `expandOnceUnblocked_adds_new`.)*

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

  - [x] **2.6 (new) — `serialityRule` with globally-last scheduling** (`Tableau.lean` +
    `Saturation.lean`). Add the `serialityRule` constructor with
    `isApplicable .serialityRule _ _ = true` (keyed on the *label*, not the formula shape) and the
    `applyRule` arm emitting `T(F ⊤)` / `T(P ⊤)` at the label, self-suppressing once both are
    present — the tableau images of `Axiom.serial_future` / `Axiom.serial_past`
    (`Axioms.lean:113,117`), hence sound for every frame class. Keep it **out of
    `allRulesForFC`** entirely and give `expandOnce` a two-stage pick: ordinary rules first, and
    only when `findUnexpanded` returns `none` retry with `serialityRule` enabled. Add an in-code
    note contrasting this against the Dedekind **prepend** (`Tableau.lean:1295-1301`) — both are
    scheduling lessons, in opposite directions. **Also part of this sub-phase (2026-07-27b,
    report 05 §Q1.5)**: the `blockCandidates` helper in `Tableau.lean`, immediately before
    `isTemporallyBlockedSaturated`, together with the one-line swap of `ancestorTimes ord t` for
    `blockCandidates ord t` in that predicate. Without it the past-directed serial chain is
    unblockable by construction and the engine is unbuildable; see the resolution note below.
    Estimated output: ~150-250 lines.
    **Done when**: `S1`-`S5` and `K2`-`K6` are CLOSED in all four class tables at
    `conformanceFuel = 200`; every control row and counterexamples `A`/`B` hold; the `.Discrete`
    `K2`/`K3` residual (report 04 §Q3.5) is either closed or documented with its cause isolated
    (**measured 2026-07-27b: it CLOSES** — `K2`-`K6` all read `CLOSED target=CLOSED` at
    `.Discrete`, so no documentation of a residual is owed); `lake build
    …Decidability.Saturation` ≤ 15 s with zero `FAIL` in its inline suite and `lake build
    BimodalTest.TableauConformance` ≤ 45 s, exit 0.
    *(done 2026-07-27b. The preserved WIP applied unchanged; `blockCandidates` is the whole
    additional fix. Measured: `…Decidability.Saturation` 6.8 s with 34 `PASS` and zero `FAIL`;
    `BimodalTest.TableauConformance` 35 s, exit 0; `lake build` and `lake build BimodalTest`
    both exit 0. Exactly 11 `#guard_msgs` blocks moved — the four class tables (`S1`-`S5`,
    `K2`-`K6` only) and the seven `TimeOrderProbe` rows. Every control, both counterexamples,
    `CertificateProbe`, `BX*`, `R*` unmoved. Fuel stays 200 with no new per-row override.
    **Unplanned but forced deviation, recorded here and raised in the handoff**:
    `saturateBlockedCancellable` (`CancellableExpansion.lean`) still called `expandOnce` where
    the pure `saturateBlocked` calls `expandOnceNoFresh`. That mirror drift was benign before
    seriality and immediately fatal after it — `expandOnce` picks over *all* times and carries
    the seriality stage, so on an open branch it never reports `.saturated`, and
    `buildTableauCancellable`'s closing check returned `none`. Measured: every invalid formula
    in `C5SmokeTest` (`p`, `⊥`, `p → q`, `□p`, `U(p,q)`, …) reported `timeout` at every fuel
    from 7 to 500 while the pure engine answered `OPEN` at all of them; 27 assertions failed in
    a file that was green at baseline. Resynced to `expandOnceNoFresh`. Neither report 04 nor
    report 05 measured this consumer — both stopped at `Saturation` and
    `TableauConformance`.)*
    **Depends on 2.5** — the prototype that produced 24/24 has both changes; seriality on the
    destructive engine was not measured and must not be attempted separately.

**RESOLVED** (Phase 2, task 2.6) — the seriality blowup was a termination defect in the blocking
predicate, not a per-step cost. *(Was: "**BLOCKER** — `serialityRule` is written and correct, and
makes the engine too slow to build." Resolved 2026-07-27b per report 05 §Q1.)*

**Root cause.** `isTemporallyBlockedSaturated` (`Tableau.lean:1649-1655`) draws its only blocking
candidates from `ancestorTimes ord t`, which is `ord.pastOf t` (`SignedFormula.lean:782-783`) —
past-directed, because blocking was written for the future-directed existentials. A time minted by
`somePastPos` is placed strictly *before* everything on the branch, so its `pastOf` is empty and
`(ancestorTimes ord t).any …` is `false` unconditionally: **the past-directed serial chain
`T(P⊤)@t ⟶ t' ⟶ t'' ⟶ …` cannot be blocked at any depth**. Seriality serves the newest unblocked
time, `somePastPos` mints its predecessor, and the loop runs to fuel exhaustion. Traced on the
bare atom `p` at `.Base`: the blocked set grows `[1] → [2,1] → [3,2,1] → …` but *always* excludes
the newest time, while the ordering grows `(3,2),(4,3),(5,4),…` without bound — 68 distinct times
inside a 200-step budget. The future half works exactly as report 04 §Q3.5 described (time 1
blocks at step 5); only the past half runs away. This is a **pre-existing latent defect that 2.6
merely exposes**, invisible earlier because the prototype report 04 measured still carried the
branch-level halt that sub-phase 2.5 had to remove.

**The fix, four lines.** `blockCandidates ord t := ancestorTimes ord t ++ (ord.futureOf t).filter
(fun t' => t' < t)`, swapped into `isTemporallyBlockedSaturated`. The `t' < t` filter is what keeps
the added arm well-founded: fresh times are minted at `Branch.nextTime = maxTime + 1`
(`SignedFormula.lean:363`), so numeric index order **is** creation order. `ancestorTimes` is
retained unfiltered, so the arm is purely additive — and measured verdict-neutral with seriality
off (whole four-class corpus, `CertificateProbe` and `TimeOrderProbe` unmoved).

| | before 2.6 | 2.6 as patched | 2.6 + `blockCandidates` |
|---|---|---|---|
| `lake build …Decidability.Saturation` | ~8 s | > 590 s | **8.5 s** |
| `lake build BimodalTest.TableauConformance` | 37 s | > 590 s | **35 s** |
| row `C2 p` (`.Base`, fuel 200) | OPEN, 1 step | STALL, 200 steps, 87 819 ms | OPEN, 7 steps, 1 ms |
| row `C3 Gp->p` | OPEN, 3 steps | STALL, 200 steps, 82 380 ms | OPEN, 11 steps, 3 ms |
| row `Fp->FFp` | OPEN, 3 steps | STALL, 200 steps, 82 057 ms | OPEN, 13 steps, 5 ms |

**Rejected alternatives, scored against measurement** (report 05 §Q1.7): caching `blockedTimes` is
*correctly* identified as the per-step hotspot (26 ms/step at `len=81`, dominating both scans) but
cannot bound a non-terminating loop — demoted from "the fix" to a quantified reserve if 2.7 or
Phase 4 pushes cost back up. Firing seriality once per label does not bound the chain (each firing
creates the next unserved label). Suppressing seriality where a successor exists does not
terminate either (every new endpoint lacks one). Restricting seriality to `G`/`H`/`F`/`P` scope is
refuted by report 04 §Q3.2's `K2` measurement. Fuel 200 is confirmed sufficient, unchanged.

**Historical record — the blocked dispatch, retained for provenance:**

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

  - [x] **2.7a — additive per-branch ordering plumbing** *(done 2026-07-28)*.
    `RuleResult.branchingOrdered` and `ExpansionResult.splitOrdered` added as new constructors;
    `.branching` / `.split` unchanged. Arms added at every enumerated consumer, plus the ordered
    analogues `tryBranchOrdered_inr` / `foldlOrdered_preserves_findClosure` carrying the
    `expandBranchWithFuel_sound` invariant through the ordered fold. Measured: `lake build`
    green, `lake build BimodalTest` green at 39 s (baseline 39 s), **zero** `#guard_msgs`
    movement — the plumbing is verdict-neutral exactly as the plan predicted.
  - [x] **2.7b — `timeLinearity`** *(done 2026-07-28b; was BLOCKED, blocker resolved below)*.
    `Branch.identifyTime` / `TimeOrdering.identifyTime`, the `TableauRule.timeLinearity`
    constructor with its three-arm `applyRule` case, `firstIncomparablePair`, `linearityRules` /
    `findApplicableLinearityRule` / `findUnexpandedLinearity`, the two stage lemmas and the
    `ruleToString` entry are all landed and green; Phase 3's **36**-constructor expectation is
    met. The third expansion stage is now wired into `expandOnce` / `expandOnceUnblocked`, after
    seriality, and the third-stage cases in `expandOnceUnblocked_pick_ne_nil` / `_adds_new` are
    discharged by the two existing stage lemmas. **All seven** W-rows read
    `total=true incomparable=[]` — 2.7's done-criterion, met. C4 stays `OPEN` at `.Base`.
  - [x] **2.7c — split/post-blocking open-arm contract repair** *(done 2026-07-28b; the
    prerequisite the blocker below called for)*. `Saturation.resolveOpenArm` settles each
    sub-branch that comes back `.inr` **while its siblings are still in scope**, reporting
    closed / genuinely-saturated-open / undecided; an arm that cannot be settled propagates as
    fuel exhaustion and is never converted into a closure. `saturateBlocked` moved above
    `expandBranchWithFuel` for definition order; `saturateBlockedCancellable` moved likewise and
    `resolveOpenArmCancellable` added so the `IO` mirror stays a line-for-line transcription.
    `resolveOpenArm_inr` carries the `findClosure = none` invariant through the new layer, so
    `expandBranchWithFuel_sound` and `blocking_sound` are unchanged in statement. Measured
    **verdict-neutral on its own**: with the stage still unwired, `lake build` and
    `lake build BimodalTest` green at 38.6 s (baseline 39 s) with **zero** `#guard_msgs`
    movement.
  - [x] **2.7 (new) — per-branch time orderings + `timeLinearity`** *(done 2026-07-28b via
    2.7a + 2.7c + 2.7b)* (`Tableau.lean` +
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
    enough. **Done when**: `timeOrderTotal` holds of every open certificate in the corpus; **all
    seven** W-rows pinned in 2.8 read `total=true`; no verdict moves except intended ones.
    **Baseline moved by 2.6 (2026-07-27b, report 05 §Q1.6)**: seriality mints witness times that
    `timeLinearity` does not yet order, so the controls W5/W6 flip `total=true → false` when 2.6
    lands. The criterion is therefore "all seven flip to `total=true`", not "W1-W4 flip" —
    W5/W6's regression is expected, benign, and 2.7's to repair.
    *(Historical scoping note, retained for the record. It was accurate: the change was split
    across three dispatches (2.7a plumbing, 2.7c contract repair, 2.7b scheduling) exactly as
    the "split if one dispatch is not enough" clause anticipated. Deliberately not begun in one
    pass rather than begun and abandoned: it is a 57-site refactor of `RuleResult`/`ExpansionResult` across
    `Tableau.lean`, `Saturation.lean`, `CancellableExpansion.lean`, `CountermodelExtraction.lean`,
    `Automation/DatasetExport.lean` and the corpus, and a partial pass leaves the tree red.
    Scoping for the dedicated dispatch, measured 2026-07-27b:*
    - *`ExpansionResult.split (branches : List Branch)` and `RuleResult.branching` are matched at
      57 sites across those six files. Note the plan text above reads as though `.split`'s
      **payload** changes; an additive `ExpansionResult.splitOrdered` /
      `RuleResult.branchingOrdered` pair leaves every existing consumer's behaviour intact and
      only requires each `match` to gain an arm, which the compiler enumerates. Choosing between
      the two shapes is the dispatch's first decision and should be raised, not assumed.*
    - *`pick_extended` and the whole `ProgressLemmas` chain in `Tableau.lean` match on
      `ExpansionResult`/`RuleResult` and must be updated with it. They are `all_goals`-robust
      sweeps, so a new constructor costs an arm apiece rather than a re-proof.*
    - *The done-criterion baseline is already re-pinned: all seven `TimeOrderProbe` rows currently
      read `total=false` and must all read `total=true`. Their current pinned values are in
      `TableauConformance.lean` and were measured against the post-2.6 engine, so they are the
      right baseline to diff against.*
    - *`Phase 3` expects **36** constructors including `timeLinearity`; 2.7 is what supplies it.
      Until then the `mem_allRulesForFC_iff` gate cannot be written.)*

    **DESIGN FORK RESOLVED — ADDITIVE (2026-07-28).** The prior dispatch raised a conflict: the
    2.7 text above labels the change "Additive" yet writes `ExpansionResult.split (branches :
    List (Branch × TimeOrdering))`, which is a *breaking* payload change. Report 04 §Q2.4 writes
    the same breaking line for `.split` (04:378) while its own recommendation sentence (04:367)
    and its "Existing rules are unaffected" paragraph (04:392-393) both require additivity. The
    decision is **additive**: `RuleResult.branchingOrdered` and `ExpansionResult.splitOrdered`
    are added as new constructors; `.branching` and `.split` keep their payloads and their
    meaning verbatim.

    *Rationale, verified at the sites rather than assumed.* The enumerated consumers are
    `RuleResult` matches at `Saturation.lean:171,541`, `CountermodelExtraction.lean:714,779,857,
    923`, `Tableau.lean:1562,1805,1844,1883,2064` and `TableauConformance.lean:565`, and
    `ExpansionResult` matches at `Saturation.lean:447,452,614,619,720,726,1405,1413` and
    `CancellableExpansion.lean:91,96,153,159`. Under the breaking reading every one of those
    sites changes *and* every `.split branches` consumer must be re-plumbed to destructure a
    pair, including the four `CountermodelExtraction.lean` `.branching` arms that are *proof*
    arms (`857`, `923` discharge `ruleSelfGuarded` contradictions) — so the diff would carry
    proof risk for zero semantic gain, since no existing rule has a per-branch ordering to
    supply. Under the additive reading every existing site is byte-identical and the compiler
    enumerates the missing arms, so a partial pass is a *compile error*, not a silent behaviour
    change, and each commit boundary can be green. The additive reading is therefore both the
    smaller diff and the one report 04's Phase 5.1 constraint ("per-branch orderings, introduced
    additively, staged behind a decidable gate") actually names. No refutation was found at any
    site: nothing consumes `.split` in a way that *needs* the ordering to be intrinsic to the
    constructor rather than carried by a sibling constructor.

    *One clarification the report's arm list forces.* Report 04:400-402 gives arm payloads
    `([], ord.addFuture t₁ t₂)` / `([], ord.addFuture t₂ t₁)` / identification, and 04:404-408
    notes arm 3 needs `Branch.identifyTime` because `TimeOrdering` cannot express equality. A
    *delta* payload cannot express arm 3 — identifying `t₂` with `t₁` must **remove** `t₂` from
    `Branch.knownTimes`, which no list of added formulas can do, and if `t₂` survives then
    `timeOrderTotal` still fails and the done-criterion cannot be met. `branchingOrdered`
    therefore carries **replacement** branches, not deltas. This needs no change to the declared
    type — `Branch` is an `abbrev` for `List SignedFormula` (`SignedFormula.lean:240`), so
    `List (List SignedFormula × TimeOrdering)` and `List (Branch × TimeOrdering)` are the same
    type — and arms 1 and 2 simply pass `branch` through unchanged.

    **BLOCKER — RESOLVED 2026-07-28b.** Raised 2026-07-28 rather than silently annotated, per
    `.claude/rules/plan-compliance.md`; the diagnosis below was correct and is retained
    verbatim. The repair is 2.7c above (`Saturation.resolveOpenArm`), landed before the stage
    was re-wired. Post-repair measurements, replacing every forecast in the entry below:

    - **C4 at `.Base` stays `OPEN`.** The countermodel survives with the stage wired. This is
      the gate the blocker existed to protect and it is met.
    - **All seven W-rows read `total=true incomparable=[]`.** W1-W4 need a per-row fuel of 400
      (`linearityFuel` in the corpus): the three-way split divides the budget proportionally and
      these rows order eight to ten times each. The boundary is measured, not guessed — `STALLED`
      at 200/250/280, W2 flips at 280, W4 at 350, all four at 400, stable through 800/1200/2000.
      W5/W6 clear at `conformanceFuel` and are left on it. W7 (W1 at 2000, five times its own
      fuel) is identical, so the flip is the rule firing and not the budget. The blocker's
      suspicion was right: the `STALL`s were partly an artifact of arms being re-explored under
      the broken contract, and what remained was a plain budget shortfall.
    - **W6's `CLOSED` is gone** — it was the same unsoundness as C4, and the contract repair
      removed both.
    - **The `.Dense`/`.Dedekind` C4 repair did not materialise.** The blocker recorded that the
      broken-contract wiring also flipped C4 at `.Dense`/`.Dedekind` from `OPEN [DEFECT]` to
      `CLOSED` (matching target). Under the repaired contract those rows stay `OPEN [DEFECT]`.
      That apparent repair was an artifact of the same abandoned-sibling defect, so it was never
      bankable; the two rows remain open defects for their own scheduled work. No regression —
      they were `OPEN [DEFECT]` before this sub-phase and are `OPEN [DEFECT]` after.
    - **One cost regression, not a verdict regression.** `□p → □q` now takes 1473 ms, over the
      dataset labeller's 1000 ms wall clock, and was reported `.timeout` instead of `.invalid`.
      Every other smoke-corpus row still decides correctly and all but that one finish in ≤ 19 ms.
      Fixed by `labelWallclockTimeoutMs = 3000`, replacing four scattered `1000` defaults.
      Exceeding the budget yields `.timeout`, the conservative label, never a wrong verdict.
    - **Suite cost.** `TableauConformance` 36 s → 59 s and `lake build BimodalTest` 39 s → 61 s.
      That is the price of a third splitting stage; it is recorded rather than absorbed silently.

    The original entry follows.

    - **What failed**: with the third stage wired in, `lake build BimodalTest` moves a corpus
      row it must not move. `.Base` row **C4 `Fp->FFp`** flips `OPEN` → `CLOSED` against
      `target=OPEN`. That is a soundness regression: there is no density over an arbitrary
      linear order, and ℤ with `p` true only at `1` is a countermodel. (The same wiring also
      *repairs* C4 at `.Dense` and `.Dedekind`, where it flips `OPEN [DEFECT]` → `CLOSED`
      matching `target=CLOSED` — but that repair cannot be banked while `.Base` is unsound.)
      Rows W2/W5/W7 do flip to `total=true incomparable=[]` as intended; W1/W3/W4 read
      `STALLED` at the pinned fuel 200 and W6 reads `CLOSED`.
    - **What was tried**: the arms were varied one at a time and the result measured each time.
      Identification arm **alone** → `OPEN`, with the total order `5 < 0 < 1 < 2 < 4`, which is
      a genuine countermodel (`p` at `1`, nothing after it). Arms 2+3 → `OPEN`, likewise total.
      Arms 1+2 → `CLOSED`. Arms 1+3 → `CLOSED`. All three → `CLOSED`. So every variant
      containing arm 1 closes, and arm 1 is *sound* — `F(F p)` really is on the branch at every
      known future of the root, so an ordering that puts a serial witness strictly between the
      root and the `p`-witness really does force `F(p)` at the `p`-witness.
    - **Why stuck — the defect is not in this rule.** Replacing `buildTableau` with a direct
      `expandBranchWithFuel` call in a probe shows the fuel loop returns `.inr openBranch` for
      a branch whose `findUnexpanded ≠ none`: saturated only in the *unblocked* sense. The
      split fold in `expandBranchWithFuel` short-circuits on the first sub-branch that comes
      back `.inr` and never explores the remaining arms; `buildTableau` (`Saturation.lean:853`)
      then runs `saturateBlocked` on that branch, which **closes** it, and returns
      `.allClosed` — so the sibling arms the fold abandoned are silently counted as closed.
      The bug is in the open-branch contract between the split fold and the post-blocking
      pass. It is pre-existing; it needs a rule whose arms come back open-but-not-saturated,
      and before `timeLinearity` no corpus row produced one. This is the same shape as 2.6's
      stale `saturateBlockedCancellable` mirror: a latent drift that a new rule made fatal.
    - **What is needed**: one dedicated dispatch to repair the split/post-blocking contract —
      either the fold must not accept a sub-branch as open while siblings are unexplored and
      the branch is not `findUnexpanded`-saturated, or a `saturateBlocked` closure of the
      returned branch must send the search back to the abandoned siblings. That changes what
      `expandBranchWithFuel` may return, which Phases 5 and 7 consume, so it is deliberately
      **not** attempted inside 2.7. Once repaired, re-enabling 2.7b is two `match` arms in
      `expandOnce` / `expandOnceUnblocked` plus the third-stage cases in
      `expandOnceUnblocked_pick_ne_nil` / `_adds_new`, for which the two stage lemmas
      (`findApplicableLinearityRule_not_linear` / `_not_persistent`) are already in the tree.
      The W-row cost question (W1/W3/W4 `STALLED` at fuel 200 under three-way splitting) must
      be re-measured after the repair, not before — the STALLs may be an artifact of arms being
      re-explored under the broken contract.
    - **Prohibited**: no `sorry`, no axiom, no vacuous placeholder was introduced, and the tree
      was left green rather than red. The rule itself is landed and reviewable rather than
      reverted, so the repair dispatch has only the contract to fix.
  - [x] **2.4 R5 — certificate strengthening** *(restated 2026-07-27; was BLOCKED)*
    (`Saturation.lean:50-59`): strengthen `ExpandedTableau.hasOpen` to carry `(fc : FrameClass)`
    and the proposition

    ```lean
    saturated : findUnexpanded openBranch (timeOrd := timeOrdering) (fc := fc) = none
    ```

    **Single conjunct (2026-07-27b, report 05 Contradiction Log C1).** The previously-planned
    `∨ (findBlockedTime openBranch timeOrdering tracker).isSome` disjunct is **deleted before it
    is written**: `CertificateProbe` measures literal full saturation reachable on genuinely-open
    branches with seriality on (`fullySaturated=true applied=0 orphans=0` for `◇p` *and*
    `G p → p`), because `serialityRule` is kept out of `allRulesForFC` and therefore out of
    `findUnexpanded`. The consequence for the truth lemma is a Phase 7.1 documentation
    obligation, not a certificate change.

    and **delete the applied set from the certificate**. The `fc` field repairs a latent defect
    found in report 04 §Q1.3: `findUnexpandedWithApplied`'s `fc` argument defaults to `.Base` and
    is supplied at neither `hasOpen` nor the two `buildTableau` sites (`Saturation.lean:667, 676`)
    nor `BranchListResult.foundOpen` (`155-158`), so the certificate currently certifies `.Base`
    saturation for all four classes. Keep the "Certificate Strength (R5)" section
    (`Saturation.lean:76-113`) but **rewrite** it: record that `AppliedRedundant` was *refuted*
    (cite the four failing formulas) and record the corrected diagnosis — destruction, not
    persistent-rule re-firing. Retire `appliedEntryRedundant` / `AppliedRedundant` or demote them
    to documented historical predicates; nothing may depend on them.
    Estimated output: ~150-300 lines. **Done when**: `hasOpen` carries `fc` and the single
    conjunct; the pipeline's certificate is constructible for `◇p`; the R5 section reflects the
    refutation; build green. **Depends on 2.5 and 2.6.**
    *(done 2026-07-27b. `hasOpen` now reads `(openBranch) (timeOrdering) (fc)
    (saturated : findUnexpanded openBranch (timeOrd := timeOrdering) (fc := fc) = none)` — the
    applied set is gone from the certificate and both `buildTableau` sites, plus their
    `buildTableauCancellable` mirrors, pass the tableau's own frame class. `extractCountermodelSimple`
    takes the stronger hypothesis, which is the same one the `sat_*` family already wanted.
    Measured: **no verdict moved anywhere** — the four class tables, all seven `TimeOrderProbe`
    rows, every control, both counterexamples and the `BX*`/`R*` families are unmoved; the only
    `#guard_msgs` blocks that changed are the two `CertificateProbe` rows, which were rewritten
    because there is no applied set left to count. Both now read
    `certified fc=Base saturated=true`, including the genuinely-open `G p → p`. `AppliedRedundant`
    and `appliedEntryRedundant` are retained as history with zero dependents (verified by grep).
    **Ordering deviation, raised rather than silently annotated** (`.claude/rules/plan-compliance.md`):
    2.4 was executed **before** 2.7, reversing the plan's `2.6 → 2.7 → 2.4`. 2.4's declared
    dependency is "Depends on 2.5 and 2.6", both of which landed in this dispatch, and nothing in
    2.4 reads 2.7's output; report 05 §Q3's stated reason for ordering 2.4 last was that its design
    is simplified by 2.6, which is satisfied. The reason for the swap is budget: 2.7 is a 57-site
    refactor of `RuleResult`/`ExpansionResult` across six files and could not be completed **and
    verified green** in the remaining dispatch, whereas 2.4 could. Starting 2.7 and abandoning it
    mid-refactor would have left the tree red; 2.7 is left untouched and fully scoped instead.)*
- **Timing:** ~8 dispatches, ~20 hours. **Order: 2.8 → 2.5 → 2.6 → 2.7 → 2.4.**
- **Depends on:** 1

### Phase 3: RuleSpec Gate — Self-Enforcing Frame-Class Composition [COMPLETED]

- **Goal:** The rule lattice is machine-tied to the axiom lattice, so mis-gating a rule breaks
  the build instead of drifting silently (the focus requirement's core mechanism, 02 §8.3).
- **Tasks:**
  - [x] Create `Decidability/Verified/RuleSpec.lean`: `ruleFrameClass : TableauRule → FrameClass`,
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

**COMPLETION NOTE (2026-07-28, Phase 3).** Both planned gates landed `by decide` as specified,
over the corrected constructor count of 36 and with the exclusion clause the revision called for
— widened, on inspection, to cover `timeLinearity` as well as `serialityRule`, since 2.7 put the
second rule outside `allRulesForFC` for exactly the same reason. Three things are worth recording
for the phases that consume this file:

1. **A third gate was added**, `ruleAxioms_covers_ruleFrameClass`: a rule gated above `.Base`
   must name an axiom at exactly its own frame class. The two planned gates run
   axiom-class → rule-class, and neither catches a rule that is gated high with nothing behind
   it — which is precisely the failure mode 02 §8.3 names ("adding a Dedekind rule without an
   accompanying Dedekind axiom breaks the build immediately"). GATE 3 is what makes that sentence
   true, and it is what makes the empty `ruleAxioms` entries safe rather than a loophole.
2. **`instance : LawfulBEq TableauRule` was needed** and lives in `RuleSpec.lean`. `TableauRule`
   derives `DecidableEq` and `BEq` independently, and the core `Decidable (a ∈ l)` instance goes
   through `LawfulBEq`; without it *no* gate is decidable, since every gate is a membership check.
   The instance is `Prop`-valued and cannot change what the engine computes. It belongs beside
   the `deriving` clause in `Tableau.lean` and should move there when a later phase owns that file.
3. **One line outside territory**: `import ...Verified.RuleSpec` in
   `Decidability/Metalogic/Decidability.lean`. Without it the new module is never built and the
   gates are never checked. Corpus-neutral by construction — `TableauConformance.lean` imports
   `Saturation` and `Tableau` directly, not the aggregator.

**Done-criterion evidence (mis-gating controls).** Five deliberate mis-gatings were applied,
built, and reverted; each gate is independently load-bearing rather than jointly redundant:

| Control | Gates broken |
|---------|--------------|
| `densityRule` `.Dense` → `.Base` | GATE 1 + GATE 2 |
| `priorUGap` `.Dedekind` → `.Discrete` | GATE 1 + GATE 2 + GATE 3 |
| base rule `untlNeg` grounded in `Axiom.prior_U_gap` | GATE 1 only |
| `ruleAxioms .sepRule` emptied | GATE 3 only |
| `serialityRule` exclusion clause deleted from GATE 2 | GATE 2 only |

The last row is the one the revision predicted: without the clause the gate fails, and it fails
on the 8 rule/class pairs of the two scheduled rules with no indication of why.

**Measured**: `lake build` and `lake build BimodalTest` both green; `RuleSpec.lean` elaborates in
2.0 s (all 36 + 144 + 36 `decide` calls). Conformance corpus re-executed under a forced rebuild
(59.2 s, matching the 2.7 baseline) with zero `#guard_msgs` movement. Zero new sorries, axioms or
vacuous definitions.

### Phase 4: Termination (WP3: T1, T2, T3) [PARTIAL]

- **Goal:** `buildTableau` totality at a justified, uncapped fuel; the pigeonhole argument is
  about real blocking (possible only now that Phase 1.3 made blocking genuine).
- **Tasks:**
  - [x] **4.1 T1 — `applyRule_subformula_closed`** *(deviation: altered — landed as one theorem
    per rule, `applyRule_<rule>_closed`, and against an abstract `TableauClosed` predicate rather
    than `closureWithNeg`; see the 2026-07-28 note below for both reasons and for the 10-of-36
    completion state)* (`Verified/Termination/SubformulaProperty.lean`,
    new): the generalized signed subformula property over all **36** rule cases against the signed,
    negation-closed closure — `closureWithNeg` for the Discrete rules (constraint 7;
    `priorUZ` emits `U(φ, ¬φ)`); `untlPos` branch 2 re-emits `U(e,g)` itself so no
    Fischer-Ladner unwinding is needed. The two new cases are mechanical: `serialityRule` emits
    `F⊤`/`P⊤` and `⊤ = ⊥ → ⊥`, so `closureWithNeg` already contains it; `timeLinearity` emits
    **no formulas** in arms 1-2 and only relabels in arm 3 (which must be shown label-only).
    Estimated output: ~300-500 lines (mechanical cases).
    Done when: theorem sorry-free; the `priorUZ`/`priorSZ` and `densityRule` cases have explicit
    comments; build green.
  - [x] **4.2 T2 — pigeonhole** *(deviation: altered — the plan's single deliverable split into a
    counting half and a construction half; the counting half is complete, the construction half is
    complete except for the general termination theorem, which is carried as an explicit hypothesis
    rather than a sorry. See the 2026-07-28c note below.)*
    (`Verified/Termination/TimeTypeBound.lean`, new):
    `blocking_fires_of_card_lt` via `Finset.exists_ne_map_eq_of_card_lt_of_maps_to` (verified
    to exist, 02 §4.3; `Fintype.exists_ne_map_eq_of_card_lt` does NOT exist — constraint 2
    applies to any further name checks). Bound `2^(2·|signedClosure φ|)` time-types; the
    trichotomy rule increases branching but not the time-type count, so the bound is R2-stable
    (02 §4.4). Estimated output: ~150-300 lines. Done when: theorem sorry-free; build green.
  - [ ] **4.3 T3 — justified fuel** *(in progress — `soundFuel'` and the set-growth progress
    measure landed 2026-07-28c; `buildTableau_isSome` outstanding)*
    (`Verified/Termination/Fuel.lean`, new): define uncapped
    `soundFuel'` (exponential closed form tied to the T2 bound — a quadratic constant cannot
    cover an exponential step count, 03 §4.3) and prove `buildTableau_isSome`. Keep capped
    `soundFuel` as the runtime default (constraint 11). This also separates the two open-branch
    populations: at `soundFuel'`, fuel exhaustion is impossible, so downstream phases handle
    only genuinely-saturated branches (03 §4.4). **Progress measure (2026-07-27b, report 05
    §Q2.5)**: consume `expandOnceUnblocked_adds_new` (`b ⊆ nb ∧ ∃ g ∈ nb, g ∉ b`, landed in 2.5),
    **not** `expandOnceUnblocked_length_lt`. Strict length increase does not bound the step count,
    because `nb = fs ++ b` may re-add formulas already present, so `List.length` has no upper
    bound; what bounds it is *set* growth against the finite signed closure × label set. The
    length lemma is a corollary and sanity check only. Estimated output: ~200-400 lines. Done when:
    `buildTableau_isSome` sorry-free; `#eval` runtime behavior unchanged; build green.
- **Timing:** 3 dispatches, ~9 hours.
- **Depends on:** 2 (rule set final; blocking genuine since 1.3)
- **Territory:** `Verified/Termination/` only.

**PARTIAL — 4.1 dispatch 1 of n (2026-07-28).** `lake build` and `lake build BimodalTest` green,
zero sorries, no new axioms or vacuous definitions, conformance corpus verdict-neutral. Landed:

- [x] **4.1a Closure design and infrastructure** — `RuleResult.emitted`, `TableauClosed`, the
  eight `as*?` inversion lemmas in `iff` form, fourteen one-step component-extraction lemmas on
  `TableauClosed`, `mem_filterMap_guarded`, `identifyTime_formula_mem`, and (in `Tableau.lean`)
  `mem_boxDiamondPersistence`.
- [x] **4.1b Rule cases, 10 of 36** — `andPos`, `andNeg`, `orPos`, `orNeg`, `impPos`, `impNeg`,
  `negPos`, `negNeg`, `boxTemporal`, `denseIndicatorClosure`.
- [x] **4.1c Rule cases, remaining 26** — landed 2026-07-28 (dispatch 2). All 36 rule cases
  sorry-free, plus the combined `applyRule_subformula_closed` by `cases rule`.
- [x] **4.2a Statement repair** — `TableauClosed` re-keyed, `trich` migrated to `TrichClosed`
  (2026-07-28c, dispatch 3). See the resolved-blocker note below.
- [x] **4.2b T2 counting** — `TimeTypeBound.lean`: `signedStock`, `card_signedStock`,
  `Branch.timeTypeFinset`, `timeTypeFinset_subset_signedStock`, `exists_ne_timeType_eq`
  (the `Finset.exists_ne_map_eq_of_card_lt_of_maps_to` pigeonhole against
  `(signedStock C).powerset`, card `2 ^ (2 * |C|)`), `isSubsetBlocked_of_timeTypeFinset_subset`,
  `isTemporallyBlocked_of_ancestor`, `blocking_fires_of_card_lt` and its empty-tracker corollary.
- [x] **4.2c Concrete closure** — `conjEmissions`, `emissions`, `closureStep`, `closureIter`,
  and `tableauClosed_of_closureStep_subset`: **all seven `TableauClosed` fields reduce to the
  single decidable containment `closureStep C ⊆ C`**, so a caller exhibits a stock and runs a
  check instead of reproving the fields. Six committed `#guard_msgs in #eval` stabilisation rows
  (probe-first, constraint 1) show the operator halting from the subformula closure — round 3 for
  `p` (|C| = 8), `F p` (11), `G p` (13), the real `priorUGap` trigger (20) and the real `sepRule`
  trigger (30); round 4 for `□p` (17).
- [ ] **4.2d T2 termination theorem** — the one piece outstanding: `∃ n, closureStep (closureIter
  n seed) ⊆ closureIter n seed` in general. It is carried as an explicit hypothesis, never a
  `sorry`, so nothing downstream is weakened by its absence — a consumer that supplies a stock
  gets `TableauClosed` from a `decide`.
- [x] **4.3a T3 progress measure and fuel figure** — `Fuel.lean`: `expandOnceUnblocked_card_lt`
  (`Branch.toFinset` strictly grows along an extending step — the set-growth form, consuming
  `expandOnceUnblocked_adds_new` exactly as the 2026-07-27b note directs, **not** the length
  lemma), `card_le_of_subset_universe`, uncapped `soundFuel'`, and `soundFuel_le_soundFuel'`
  (the capped runtime default never runs past the justified bound).
- [ ] **4.3b T3 `buildTableau_isSome`** — outstanding. Its two dimensions are now separately
  available: formulas by T1, labels by `blocking_fires_of_card_lt`. What remains is composing
  them and carrying `TrichClosed C b` through the fuel loop's branch invariant (preservation is
  favourable: `orderTrichotomy` adds only positive disjuncts, so it never enlarges the set of
  branch-side negated disjuncts `TrichClosed` quantifies over).

**Two settled-design corrections, both forced by source inspection, both recorded in the module
docstring rather than assumed:**

1. **`closureWithNeg` is also too small.** Constraint 7 says plain `subformulaClosure` fails
   because `priorUZ` emits `U(φ, ¬φ)`. True, but `closureWithNeg φ` contains `¬φ` and still not
   `U(φ, ¬φ)`, which is what the rule actually emits. Seven rules emit formulas outside
   `closureWithNeg` (`boxTemporal`, `serialityRule`, `priorUZ`, `priorSZ`, `priorUGap`,
   `priorSGap`, `sepRule`, plus `orderTrichotomy`). T1 is therefore stated against an abstract
   predicate `TableauClosed C` whose fields are exactly that census; T2 supplies a concrete `C`
   with a cardinality. `z1Rule`, `densityRule` and `timeLinearity`, suspected of needing fields,
   provably do not — `G inner` *is* a subformula of `G(G(inner) → inner)` under the `untl`
   encoding, and `timeLinearity` emits nothing.
2. **`orderTrichotomy` is analytic after all, and that is what keeps the closure finite.** Its
   restriction 3 fires only when the branch already carries the negation of one of the three
   `temp_linearity` disjuncts, so the `trich` field is an "all three or none" condition on an
   operand pair already present — not a quadratic closure over `C × C`, which would iterate
   `F(F(x ∧ y) ∧ y')` without bound.

**4.1 COMPLETE (2026-07-28, dispatch 2).** All 36 rule cases sorry-free; `lake build` and
`lake build BimodalTest` green; conformance corpus verdict-neutral; no new axioms or vacuous
definitions. The 4.1c blocker recorded by dispatch 1 (a combined theorem is OOM-killed at
~19.2 GiB) is resolved as predicted by keeping one rule per declaration; the surviving 26 cases
landed in four green batches. Three reusable pieces made the propagation-heavy rules tractable
and are worth knowing before touching this file again:

- `mem_filterMap_sub` — every propagation block emits a *subformula* of a branch formula, so the
  per-block obligation is one uniform `subformulas` membership rather than a per-block choice of
  component lemma, and it is discharged after `clear` has removed the unfolded `applyRule` term
  from the context.
- `mem_of_branch_contains` — `Branch.contains` is `List.any` with `BEq`, not `List.contains`, so
  `List.contains_iff_mem` does not apply. `orderTrichotomy` is the only case that needs it.
- Closer-chain ordering is load-bearing: the witness alternative must come first and must not
  mention `hg`, because `rcases` has already substituted `g` in that goal, and naming a
  non-existent hypothesis inside a `first` alternative is a hard elaboration error rather than a
  backtrackable failure.

**BLOCKER (4.2) RESOLVED (2026-07-28c).** The `TableauClosed` statement defect recorded above is
repaired; `lake build` green, zero sorries. Two changes, one mechanical and one a recorded design
decision:

1. **Conjunctive re-keying of `gapU`/`gapS`/`sep`** (mechanical, as predicted). Each field is now
   keyed on the rule's whole trigger — `U(⊤,g) ∧ F¬g`, `S(⊤,g) ∧ P¬g`,
   `K⁺ψ ∧ ¬K⁺(ψ ∧ U(ψ,¬ψ))`. `sub` never produces a conjunction out of a conclusion, so none of
   the three re-fires on its own output. The three rule closers shortened exactly as predicted
   (`hC.gapU _ hsf` in place of `hC.gapU _ (hC.and_left hsf)`).

2. **DECISION — `trich` leaves `TableauClosed` and becomes `TrichClosed C b`.** Options weighed:
   (a) keep a `C`-only field — rejected, it is the field that admits no finite `C`, because
   `F(x ∧ Fy)` is again of the form `F(x ∧ y′)`; (b) strengthen the rule's guard from
   `ds.any` to `ds.all` so one branch-side negation implies all three — rejected, it is an engine
   edit, and Phase 4's territory contract forbids engine edits in wave 3, and it could move
   conformance verdicts; (c) **adopted** — state the condition where its guard actually lives.
   `orderTrichotomy` fires only when `branch.contains (SignedFormula.neg d l0)` holds for one of
   the three disjuncts, so the obligation is branch-relative by nature. `TrichClosed C b` is
   defined in `SubformulaProperty.lean` with the rule's own disjunct order, so
   `applyRule_orderTrichotomy_closed` discharges it by `exact hany` with no glue; that theorem no
   longer needs `hC` or `hb` at all (it is analytic, as recorded in the 4.1 note), and
   `applyRule_subformula_closed` gains one hypothesis `htrich`. **Rationale**: this is the only
   option that keeps `TableauClosed` a finitely-satisfiable condition on `C` alone — which is what
   `TimeTypeBound.lean` counts against — without touching the engine or weakening T1. **Cost
   deferred to 4.3**: `Fuel.lean`'s branch invariant must carry and preserve `TrichClosed C b`.
   Preservation is not free but is tractable: `orderTrichotomy` adds only *positive* disjuncts, so
   it never enlarges the set of branch-side negated disjuncts that `TrichClosed` quantifies over.

- **Still prohibited**: do not widen `C` to absorb the chains — they are strictly size-increasing,
  so no cardinality bound survives widening. Do not weaken T1 to dodge this.

### Phase 5: Bridge Infrastructure (BranchOrder, Embed, Carrier) [NOT STARTED]

**ENGINE CONTRACT CHANGE (2026-07-28b, from sub-phase 2.7c) — read before consuming
`expandBranchWithFuel`.** What the fuel loop may return while sibling branches are unexplored
has changed, and this phase consumes it.

*Before*: `expandBranchWithFuel` could return `.inr openBranch` for a branch that was open only
in the *unblocked* sense (`findUnexpanded openBranch ≠ none`), reached by short-circuiting a
split fold on its first `.inr` arm and abandoning that arm's siblings. `buildTableau` was then
responsible for the post-blocking pass — and, because it had lost the siblings, could report
`.allClosed` on the strength of a branch it had closed while untried arms remained.

*After*: each arm is settled inside the fold by `Saturation.resolveOpenArm`, which runs the
post-blocking pass while the siblings are still in scope. Consequences to rely on:

1. **A `.inr` result from a split arm is fully saturated** — `findUnexpanded = none` — not merely
   unblocked-saturated. The top-level `.saturated` path (no split above it) can still hand back
   an unsaturated branch, which is why `buildTableau` retains its own `saturateBlocked` call.
2. **`.allClosed` now means every sub-branch genuinely closed.** It is no longer reachable by
   abandoning siblings.
3. **An arm that can be settled neither way propagates as `none`** (fuel exhaustion / `STALLED`),
   never as a closure. Downstream reasoning may treat `none` as "the engine decided nothing" and
   must not read it as a negative answer.
4. `expandBranchWithFuel_sound` / `blocking_sound` are unchanged in statement; the invariant
   travels through the new layer via `resolveOpenArm_inr`.

`saturateBlockedCancellable` and the new `resolveOpenArmCancellable` mirror this line-for-line
in `CancellableExpansion.lean`; the `_tracedImpl` mirror in `Saturation.lean` does **not** yet
carry the repair (it feeds trace certificates only, and no corpus row consumes it for a verdict)
— if a later phase starts reading verdicts off the traced mirror, sync it first.

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

**ENGINE CONTRACT CHANGE (2026-07-28b, from sub-phase 2.7c).** See the identically-titled note
under Phase 5 — it applies here verbatim. The short version: a `.inr` arm out of a split is now
fully saturated, `.allClosed` now means every sub-branch genuinely closed, and an unsettleable
arm surfaces as `none`/`STALLED` rather than as a closure. `not_valid_of_hasOpen` consumes the
`hasOpen` certificate, so point 1 is the one that matters most here.

- **Goal:** **Headline result 1**: `not_valid_of_hasOpen` generic in the carrier, semantic rule
  soundness, and `Decidable` instances for all four frame classes. On completion this task has
  delivered standalone publishable value regardless of Track B's fate.
- **Tasks:**
  - [ ] **7.1 `Verified/Bridge/Omega.lean` + `Verified/Bridge/TruthLemma.lean`** (new): build
    `WorldHistory`/`Omega` with total `domain := fun _ => True` and universal `TaskRel`
    (report 01 F6 — verified sound); `ShiftClosed` via `time_shift_preserves_truth`
    (`Truth.lean:446`) per report 01 F9, `Set.univ_shift_closed` as fallback; prove
    `not_valid_of_hasOpen` generic in `TemporalCarrier`, consuming the `sat_*` family verbatim.
    **Documentation obligation (2026-07-27b, report 05 Contradiction Log C1 — supersedes the
    2026-07-27 hypothesis change, which rested on a prototype and is refuted)**:
    `not_valid_of_hasOpen` consumes the restated 2.4 certificate — `fc`-indexed saturation as a
    **single conjunct**, `findUnexpanded … = none` — plus `timeOrderTotal`. Report 04 §Q3.5's
    claim that no open branch is ever fully saturated once `serialityRule` lands is **measured
    false**: `CertificateProbe` reports `fullySaturated=true applied=0 orphans=0` for both `◇p`
    and the genuinely-open `G p → p` with seriality on, because `serialityRule` is deliberately
    outside `allRulesForFC` and `findUnexpanded` reads `allRulesForFC`. What Phase 7.1 must do
    instead is **state, in the truth lemma's preamble, that `findUnexpanded = none` means "no
    *ordinary* rule applies"** — so the branch it reads may still be owed `T(F ⊤)`/`T(P ⊤)` at
    every label. Those formulas are true at every point of any serial frame, so the extracted
    model is unaffected; the gap must be named, not assumed away, and the certificate must not be
    weakened to hide it. The loop-unwinding/identification argument (settled semantics:
    identification/deletion, never edge) is still on the critical path for blocked branches.
    Note also that blocking is now **bidirectional** (`blockCandidates`, 2.6): the identification
    argument gets a strictly decreasing *creation index* to induct on in both directions, since a
    time may only be blocked by one created strictly earlier.
    Budget accordingly — the ~250-450 line estimate is a **floor**.
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
