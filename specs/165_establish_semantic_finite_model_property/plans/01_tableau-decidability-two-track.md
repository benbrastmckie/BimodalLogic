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

### Phase 4: Termination (WP3: T1, T2, T3) [COMPLETED]

> **Status as of 2026-07-28i — Phase 4 COMPLETE.** T1, T2 and T3 all complete. The last open
> item, **4.2d confinement**, landed this dispatch: `exists_confining` builds a finite
> emission-closed superset for *every* finite seed, so
> `exists_tableauClosed_closureIter_of_seed : ∃ n, TableauClosed (closureIter n seed)` is now
> **unconditional** — no hypothesis, no `sorry`, no stock the caller must invent. T3's five
> restated "Done when" criteria were already met at 2026-07-28h and are untouched. Both builds
> green, zero sorries, no new axioms.
>
> **Why the confinement proof looks the way it does.** The obligation reads like it wants a
> well-founded measure, and provably has none: `priorUGap` maps `U(⊤,g) ∧ F(¬g)` to
> `U(¬g ∨ K⁺¬g, g)`, which is strictly larger under every additive weighting of the
> constructors, and any weighting light enough to make it non-increasing admits infinitely many
> formulas below a bound. What replaces the measure is an **algebra**: `closureStep` distributes
> over union (`closureStep_union`), so `Confining` stocks are union-closed, so a stock can be
> assembled from independently-confining pieces. `exists_confining_of_forall` then reduces the
> seed-level obligation to a formula-level one, and a six-case structural induction closes it.
> The three Dedekind batch lemmas carry the content: each conclusion drags in six to ten
> formulas, and each of those emits nothing new for reasons decided at the outermost differing
> constructor.
>
> Residual 3's fuel half remains *refuted as stated* and recorded as an engine-policy finding;
> residual 4 (`WorldWitness`) remains a named hypothesis by design — neither is a Phase 4
> obligation.

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
  - [x] **4.3 T3 — justified fuel** *(**COMPLETE 2026-07-28h** against the restated 5-criteria
    "Done when" below — `worldFuel'` and all six 4.3e targets landed sorry-free, both builds green.
    `soundFuel'` and the set-growth progress
    measure landed 2026-07-28c; the branch invariant, the signed-formula universe and the
    unbranched step bound `chain_le_stock`/`chain_le_soundFuel'` landed 2026-07-28d;
    `buildTableau_isSome` outstanding and **restated**, see the 4.3b blocker note below)*
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
    length lemma is a corollary and sanity check only. Estimated output: ~200-400 lines.
    **Done when (RESTATED 2026-07-28g — supersedes the original "`buildTableau_isSome` sorry-free"
    criterion, which the 4.3b blocker note refuted and the `soundFuel'` decision below re-anchors):**
    1. `worldFuel'` is defined and `chain_le_worldFuel'` is sorry-free — the general fuel figure is
       *named* and the chain bound lands on it definitionally, not by estimate;
    2. `expandBranchWithFuel_isSome_at_worldFuel'` is sorry-free — totality at the named general
       figure, with `maxBranches` **quantified** (never the engine default);
    3. the three surviving hypotheses are *named in the theorem statement*, not hidden inside a
       figure: `WorldWitness` (residual 4), `NoSplit` (residual 3), and the branch budget;
    4. `soundFuel'` is unchanged in name and body, and `soundFuel_le_soundFuel'` /
       `chain_le_soundFuel'` are untouched;
    5. `#eval` runtime behavior unchanged (constraint 11); build green; zero sorries.
    **Explicitly NOT required**: `buildTableau_isSome` in any unconditional form — see the
    4.3b blocker note, which stands.
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
- [x] **4.2d T2 termination theorem** — `∃ n, closureStep (closureIter n seed) ⊆ closureIter n
  seed` in general. **COMPLETE 2026-07-28i, unconditional.** *(**Stabilisation half landed
  2026-07-28h.** `TimeTypeBound.lean` now splits the obligation
  into **stabilisation** and **confinement** and discharges stabilisation unconditionally:
  `closureIter_succ` (step moves outside the recursion), `closureIter_subset_succ`,
  `closureIter_subset_of_closed`, `exists_closureStep_subset` (the finite-monotone argument —
  cardinalities non-decreasing and capped by `|M|`, so a strict increase cannot persist past
  `|M|` rounds, and `Finset.eq_of_subset_of_card_le` upgrades the inclusion at the first repeat),
  and the packaged `exists_tableauClosed_closureIter`. **What remains is confinement only**:
  exhibit *any* finite emission-closed superset `M` of the seed, however crude. The reduction is
  not circular — `closureStep M ⊆ M` alone would give `TableauClosed M` directly, but
  `closureIter n seed` is the **smaller** stock, and T2's `2 ^ (2·|C|)` is exponential in `|C|`,
  so finding the fixed point at or below `M` is the point.
  **Confinement half landed 2026-07-28i.** The measure route is refuted (see the Phase 4 status
  banner); the route taken is the union algebra. Landed, all sorry-free: `closureStep_union`,
  `Confining`/`.union`/`.extend`/`.extendEmissions`, `closureStep_mono`/`closureIter_mono`,
  `constCore` (= `closureIter 3 ∅`, seven formulas, confining by kernel `decide`) and
  `constCore_subset_of_confining`, `stableAt` + `closureStep_closureIter_of_stableAt` +
  `exists_confining_of_stableAt` (confinement by computation for any concrete seed),
  `Carries`/`SubConfining` (the induction is strengthened to carry each subformula's **negation**,
  because `□ψ` emits `Gψ = ¬F(¬ψ)` whose `priorUZ` trigger `U(¬ψ, ⊤)` mentions `¬ψ`, which is not
  a subformula of `□ψ`), the six induction cases `subConfining_atom`/`_bot`/`_box`/`_untl`/
  `_snce`/`_imp`, the three Dedekind batches `exists_confining_gapU`/`_gapS`/`_sep`, the
  dispatcher `exists_confining_conjEmissions`, and the finish `subConfining` →
  `confinesFormula` → `exists_confining` → `exists_tableauClosed_closureIter_of_seed`.
  Six new `#guard_msgs` cascade rows were committed first (probe-first, constraint 1): a trigger
  delayed one round by `F(U(⊤,g) → ¬F(¬g))`, nested up to three deep, with and without a `□` on
  top, all still stabilise at **round 4** — delay does not compound, which is the executable form
  of the non-recurrence the proof establishes.)*
- [x] **4.3a T3 progress measure and fuel figure** — `Fuel.lean`: `expandOnceUnblocked_card_lt`
  (`Branch.toFinset` strictly grows along an extending step — the set-growth form, consuming
  `expandOnceUnblocked_adds_new` exactly as the 2026-07-27b note directs, **not** the length
  lemma), `card_le_of_subset_universe`, uncapped `soundFuel'`, and `soundFuel_le_soundFuel'`
  (the capped runtime default never runs past the justified bound).
- [x] **4.3b T3 branch invariant, universe, and the unbranched step bound** *(deviation: altered —
  the sub-phase's named deliverable `buildTableau_isSome` is **not** landed; see the 4.3b blocker
  note below, which refutes its unconditional statement. What landed is the whole composition up
  to the two dimensions it needs.)* — `Fuel.lean` gains: `TrichStock` and
  `trichClosed_of_trichStock` (the 4.2a deferred cost, isolated into one decidable stock-side
  condition rather than a sorry); `BranchStock` (the fuel loop's branch invariant);
  `findApplicableRule_applyRule_eq` / `findApplicableSerialRule_applyRule_eq` /
  `findApplicableLinearityRule_applyRule_eq` (one extraction lemma per pick stage, turning the
  pick back into the `applyRule` equation T1 speaks about); `pick_result_mem`;
  `expandOnceUnblocked_extended_mem` and `expandOnceUnblocked_extended_stock` (**T1 iterated** —
  the invariant survives a step); `signedUniverse`, `mem_signedUniverse`,
  `card_signedUniverse_le`, `branch_card_le`; `ExtendStep`, `card_lt_of_extendStep`,
  `chain_card_le`, `branchStock_chain`, `chain_le_card_universe`; and the two headline bounds
  `chain_le_stock` (an unbranched run out of a stock-confined branch takes at most `2·|C|·|L|`
  steps) and `chain_le_soundFuel'` (at the T2 label figure `2^(2|C|)` that bound *is* `soundFuel'`,
  so the fuel figure is earned rather than stated). Zero sorries.
- [x] **4.3c-prerequisite T3 label dimension** — landed 2026-07-28e. `Fuel.lean` gains
  `Branch.labelFinset`/`worldFinset`/`timeFinset` with `card_labelFinset_le`;
  `chain_le_own_labels` (taking `L` to be the run's *own* label set discharges `chain_le_stock`'s
  `hl` outright and relocates the obligation to a cardinality) and `chain_le_worlds_times` (that
  cardinality split into the two dimensions a `Label` has); `TimeChain` (the run-level chain
  invariant, stated as exactly `blocking_fires_of_card_lt`'s `hchain` at `b.timeFinset`);
  `timeFinset_card_le_of_not_blocked` and its empty-tracker variant (**T2 contraposed** — a branch
  the run has not blocked has at most `2 ^ (2·|C|)` times); `chain_le_worlds_of_not_blocked`;
  `comparable_of_firstIncomparablePair_none` (linearity saturation gives pairwise comparability);
  `timeChain_of_linearity_saturated`; and `chain_le_worlds_of_linearity_saturated`. Zero sorries.
  *(deviation: altered — the sub-phase does not fully discharge the label dimension. One residual,
  `OrderDual`, remains as a named hypothesis; see the 4.3c-prerequisite note below.)*
- [x] **4.3c T3 `expandBranchWithFuel_isSome`** — landed 2026-07-28e in the corrected form the
  4.3b blocker note specified. `NoSplit` is the branch invariant under which the engine's step
  never splits and which survives an extending step;
  `expandBranchWithFuel_isSome_of_noSplit` rules out all three sources of `none` — the branch
  budget guard by the hypothesis `branchesUsed + fuel ≤ maxBranches` (invariant along the run,
  since each step increments one and decrements the other), fuel exhaustion by the T3 progress
  measure (`U.card < b.toFinset.card + fuel`, contradictory at `fuel = 0`), and the split arms by
  the invariant. `expandBranchWithFuel_isSome_of_stock` instantiates it at `signedUniverse C L`.
  `expandOnceUnblocked_nil` / `noSplit_nil` / `expandBranchWithFuel_nil_isSome` supply a concrete
  non-vacuity witness, so the invariant is demonstrably satisfiable rather than possibly empty.
  The engine is untouched. *(deviation: altered — `buildTableau_isSome` itself is NOT landed and
  cannot be at the engine's default `maxBranches`; the corollary needs a caller that fixes the
  budget. The `.split`/`.splitOrdered` arms remain outstanding, now isolated behind `NoSplit`
  rather than behind a sorry.)* **Scope note (2026-07-28g):** what landed here is the
  **single-world** instantiation — `expandBranchWithFuel_isSome_of_stock` is stated at the abstract
  `2 * |C| * |L|`, and `chain_le_soundFuel'` identifies that with `soundFuel'` only under a
  single-world label count. The **general-figure** instantiation is 4.3e below. Do **not** re-open,
  re-prove, restate or rename anything in 4.3c to get there — 4.3e consumes it exactly as landed.
- [x] **4.3d T3 residuals** — *(residuals 1 and 2 discharged 2026-07-28f; residual 3's **budget**
  half discharged 2026-07-28h with its **fuel** half converted into a recorded engine-policy
  finding — see the FINDING below; residual 4 remains a named hypothesis by design, which is what
  the restated "Done when" criterion 3 asks for)* named, isolated obligations, none a sorry: `OrderDual` (the `futureOf`/`pastOf`
  duality — **DONE**, `orderDual_holds`), the world dimension `W` (**DONE**, `worldFinset_card_le` /
  `chain_le_worlds_bounded`), and:
  - **Residual 3 — the branching arms** (`.split` / `.splitOrdered`, and `resolveOpenArm`'s own
    `none`). **Still open.** *(target corrected 2026-07-28g — report 06 §4; read before starting.)*
    The budget invariant to generalise to is **linear with a branching-factor coefficient, not
    tree-shaped**: `branchesUsed + β * fuel ≤ maxBranches`. Source basis: in both split arms
    `branchesUsed'` is a `let` bound **once, before** the fold (`Saturation.lean:646, :675`) and the
    **same** value is passed to every sibling (`:654, :681`), while the fold's accumulator carries
    only the `Option` result and no counter (`:647-664, :676-690`). Sibling usage is therefore
    **not** accumulated: `branchesUsed` at a node is the sum, along one root-to-node **path**, of
    `1` per extending step and `branches.length` per split. Preservation is one line per arm, since
    every recursive call receives `≤ fuel₀ - 1` (`min pair.2 fuel`, `:653, :680`, against the
    matched `fuel + 1`); the guard needs `β * fuel ≥ 1`, which the T3 fuel hypothesis already gives.
    **State `β` as a hypothesis on `branches.length`, not as the literal `3`** — `3` is the
    currently *measured* maximum (`orderTrichotomy`'s three `disjuncts`,
    `Tableau.lean:1119-1122, :1161`; `timeLinearity`'s three arms, `:1351-1354`; every other
    `.branching` construction site is a 2-element literal), and a census is not a theorem.
    `branchesUsed + β * fuel ≤ maxBranches` **implies** the landed `branchesUsed + fuel ≤
    maxBranches`, so `expandBranchWithFuel_isSome_of_noSplit` needs no weakening. This residual is
    **orthogonal to the fuel figure** — do not entangle the two.
  - **Residual 4 — `WorldWitness` is an invariant, not a theorem.** *(newly named 2026-07-28g;
    previously unnamed.)* `worldFinset_card_le`, and hence `chain_le_worlds_bounded`, carry
    `hww : WorldWitness C S (run n)` as a hypothesis; `Fuel.lean:1000-1003` records that deriving it
    is a 36-case induction over `applyRule` of the same shape and size as T1. The general fuel
    figure inherits it. **It must remain visible in every statement that depends on it** — a "Done
    when" that lets it hide inside a named figure would let a later dispatch claim a world bound
    that assumes itself. Discharging it is out of scope for 4.3 and belongs with the T1 work.
- [x] **4.3e T3 general fuel figure** — *(**LANDED 2026-07-28h**, all six targets sorry-free, both
  builds green, `#eval` behaviour unchanged, fourteen `#guard_msgs` regression rows still matching
  plus three new arm-fuel probes. `worldFuel'_eq` needed `Nat.mul_left_comm` rather than `ring` —
  `Mathlib.Tactic.Ring` is not in `Fuel.lean`'s import surface, and the identity is pure
  associativity/commutativity so no ring machinery is warranted; `soundFuel'_pos` uses
  `Nat.pow_pos`, not the non-existent `Nat.pos_pow_of_pos`.)* *(created 2026-07-28g by the RECORDED
  DECISION below; report 06.)* `Fuel.lean`, **additions only**, engine untouched:
  - `worldFuel' (φ : Formula) (s : Nat) : Nat := (s + soundFuel' φ) * soundFuel' φ` — the general
    figure, `s` the seed-world count. **Do not specialise `s` to `1` in the definition**:
    `chain_le_worlds_bounded` quantifies `S` universally and the restatement must consume it. (The
    engine's own seed *is* a singleton — `buildTableau`'s
    `initialBranch = [SignedFormula.neg φ Label.initial]`, `Saturation.lean:930` — record that as a
    note, not as the definition.)
  - `worldFuel'_eq` — the arithmetic identity `worldFuel' φ s = 2 * c * ((s + 2*c*m) * m)` at
    `c = (subformulaClosure φ).card`, `m = 2 ^ (2*c)`. It is an **identity, not an estimate**:
    `2*c*((s + 2*c*m)*m) = (2*c*m)*(s + 2*c*m) = soundFuel' φ * (s + soundFuel' φ)`.
  - `soundFuel'_pos : 0 < soundFuel' φ` — via `Finset.card_pos` and
    `FormalSystem.Syntax.self_mem_subformulaClosure` (`Closure.lean:42`, verified to exist).
  - `soundFuel'_le_worldFuel' : soundFuel' φ ≤ worldFuel' φ s` — via
    `Nat.le_mul_of_pos_left : {n : ℕ} (m : ℕ) (h : 0 < n) : m ≤ n * m` (`Init.Data.Nat.Lemmas`;
    signature verified by loogle) and `soundFuel'_pos`.
  - `chain_le_worldFuel'` — `chain_le_worlds_bounded` restated at the named figure: same
    hypotheses (**including `hww`** — residual 4) plus `hφ : C.card = (subformulaClosure φ).card`,
    concluding `n ≤ worldFuel' φ S.card`.
  - `expandBranchWithFuel_isSome_at_worldFuel'` — the 4.3 terminus:
    `expandBranchWithFuel_isSome_of_stock` instantiated at the general figure. The label-side
    hypothesis is `|L| ≤ (s + 2*|C|*2^(2|C|)) * 2^(2|C|)`, which yields
    `2 * |C| * |L| ≤ worldFuel' φ s` by the same identity — so this step is **instantiation, not new
    mathematics**. `maxBranches` stays quantified, with the branch-budget hypothesis.
  - One docstring sentence on `soundFuel'` naming it the single-world (label-count) figure and
    pointing at `worldFuel'`; a module-docstring status update.
  **Do NOT** redefine `soundFuel'`, rename it, or restate `soundFuel_le_soundFuel'` /
  `chain_le_soundFuel'` — see the RECORDED DECISION below for why each is rejected.
  Estimated output: ~120-200 lines. Done when: the six items above sorry-free; `#eval` behaviour
  unchanged (constraint 11); build green.

**4.3d residuals 1-2 landed (2026-07-28f).** Both in `Fuel.lean`, sorry-free, three green commits;
`lake build FormalSystem.Metalogic.Decidability` (1054) and `lake build BimodalTest` (1949) green.

1. **`OrderDual` is now a theorem, not a hypothesis.** `orderDual_holds` proves it for every
   `TimeOrdering`, so `timeChain_of_linearity_saturated` and
   `chain_le_worlds_of_linearity_saturated` both drop their `hd` parameter. Route was the recorded
   one: `open private reachableForward reachableBackward from … SignedFormula` — pure consumption,
   no engine edit, no wave-3 territory violation. The shared breadth-first shape is factored out
   as `bfsClosure` and characterised by paths (`PathN`, `PathN.snoc`, `PathN.reverse`,
   `mem_directFutureOf_iff`). As predicted, completeness was the hard half: it is **false** without
   the visited-set invariant `BfsInv`, and it needs a *joint* induction over the frontier and
   visited statements, since the visited statement at length `m+1` needs the frontier statement at
   the same length. `orderDual_holds` needs only `propext` and `Quot.sound`.

2. **The world dimension is bounded, and the bound is not 1.** Only `boxNeg`/`diamondPos` mint
   fresh worlds, and neither self-guards; what stops re-firing is `findApplicableRule`'s
   `witnessPresent` gate, whose *modal* arms quantify over `branch.knownWorlds` while its
   *temporal* arms hold `world := l.world` fixed. That world-indifference is the S5 discipline
   appearing as a termination fact: a minted world is identified by the sign, formula and time of
   its witness, never by its own index. `WorldWitness C S b` records it as a branch invariant,
   `worldFinset_card_le` counts it (`|S| + 2*|C|*|times|`, by injection into
   `signedUniverse C b.timeLabels`), and `chain_le_worlds_bounded` discharges **both** cardinalities
   — no `W`, no `hW`, no `OrderDual`. Three `#guard_msgs` rows run the engine's real
   `witnessPresent` and confirm the world-indifference directly.

**FINDING — `soundFuel'` is not the general fuel figure (2026-07-28f).** This is new, and it
changes what 4.3's "Done when" can mean. `chain_le_soundFuel'` takes
`hL : L.card ≤ 2 ^ (2 * C.card)` on the **label** set, but T2 bounds **times**, and a label is a
world *and* a time. So `hL` asks for `|worlds| * |times|` to sit under the T2 *time* figure, which
holds only in a single world. The theorem is not wrong — `hL` is a hypothesis, not a claim — but
there is no route from T2 to `hL` once any `boxNeg`/`diamondPos` fires. With
`|worlds| ≤ |S| + 2*|C|*2^(2*|C|)`, the honest figure is `chain_le_worlds_bounded`'s,
which exceeds `soundFuel' φ = 2*n*2^(2*n)` by about `2*|C|*2^(2*|C|)`.
`soundFuel'` was **not** redefined — that is a plan-level decision, deliberately left to a
revision — and no claim in `Fuel.lean` now asserts it suffices in the presence of fresh worlds.
**A plan revision should decide** whether to (a) redefine `soundFuel'` to carry a world factor,
(b) keep it as the single-world figure and rename it accordingly, or (c) restate 4.3's deliverable
against `chain_le_worlds_bounded`. **RESOLVED — see the RECORDED DECISION immediately below.**

**RECORDED DECISION — the general fuel figure is `worldFuel'`; `soundFuel'` is frozen
(2026-07-28g, report 06).** Resolves the FINDING above. Adopted: **(b) + (c) in combination,
without a rename**. Verified first: the arithmetic. With `c := |C|`, `m := 2^(2c)`, `s := |S|` and
`F := soundFuel' φ = 2·c·m` (valid under `hφ`), `chain_le_worlds_bounded`'s figure factors
**exactly**:

    2·c·((s + 2·c·m)·m) = (2·c·m)·(s + 2·c·m) = F·(s + F) = s·F + F²

So the general figure is *exactly* `soundFuel' φ · (|S| + soundFuel' φ)`, and the ratio to
`soundFuel'` is *exactly* `|S| + 2·|C|·2^(2|C|)` — the FINDING's "roughly a factor of
2·|C|·2^(2|C|)" is confirmed and sharpened to an identity. At the engine's own seed (`|S| = 1`,
`Saturation.lean:930`) the general figure is `soundFuel' φ · (soundFuel' φ + 1)`: to a `+1`, the
**square** of the single-world figure. Two figures that differ by a squaring must not share a name.

- **Adopted.** Keep `soundFuel'`'s name *and* body frozen, re-documented as the explicitly
  **single-world (label-count)** figure; add a new named general figure
  `worldFuel' φ s := (s + soundFuel' φ) * soundFuel' φ`, defined so that it is *definitionally*
  `chain_le_worlds_bounded`'s RHS; restate 4.3's "Done when" against `worldFuel'` plus a quantified
  branch budget. Execution is sub-phase **4.3e** above.
- **(a) redefine `soundFuel'` — REJECTED**, four reasons, in weight order. (i) It silently
  destroys a landed theorem's content: `chain_le_soundFuel'`'s docstring claims "this is the
  theorem that earns it", and the content of that claim is that `chain_le_stock`'s bound
  `2·|C|·|L|` *equals* `soundFuel' φ` with no slack. Redefining turns it into a loose inequality
  with a factor `s+F` of slack and makes the docstring false — a green build with a lying
  docstring, the worst failure mode available here. (ii) It is a semantic change under a stable
  name, explained as `2n·2^(2n)` in the module docstring, in `soundFuel_le_soundFuel'`, and in 17
  places in this plan. (iii) The single-world figure is independently useful and would be lost:
  only `boxNeg`/`diamondPos` mint worlds (`Fuel.lean:935`), so for modal-operator-free `φ` the
  world count *is* 1 and `soundFuel'` is the true, quadratically-exponentially better bound —
  redefining forecloses the "modal-free ⟹ single world" corollary Track A will want.
  (iv) It saves no call-site churn: `grep -rn "soundFuel'" --include=*.lean` finds **no consumer
  outside `Fuel.lean`**.
- **(b)'s rename half — REJECTED.** Renaming forces renaming two landed, green, sorry-free
  theorems (`soundFuel_le_soundFuel'`, `chain_le_soundFuel'`) plus 17 plan references, for zero
  mathematical content. The misreading a rename would prevent is prevented better by the
  docstring — which `Fuel.lean:1180-1191` already contains in the sharpest available form. The
  remedy for a name that is right-but-narrow is documentation, not churn.
- **(c) alone — REJECTED as insufficient** (its *substance* is adopted, as the restated "Done
  when"). `chain_le_worlds_bounded` is a **chain-length** bound; 4.3's deliverable is a **fuel
  figure**, a `Nat` a caller hands to `expandBranchWithFuel`. `expandBranchWithFuel_isSome_of_stock`
  takes `hfuel : 2 * C.card * L.card < fuel`, so a caller needs a named computable `Nat`; against a
  bare five-factor expression every downstream consumer re-inlines it, and a "Done when" phrased
  against an inline expression is not mechanically checkable — which is the failure mode that
  produced this blocker. Since there are no `.lean` consumers yet, the naming decision must be made
  **now**, before Phase 7 hard-codes an expression.
- **What the decision does *not* do.** It does not discharge `WorldWitness` (4.3d residual 4), does
  not discharge the branching arms (residual 3), and does not make `buildTableau_isSome` provable
  at the engine default — `Saturation.lean:590, :594, :931` are unchanged and the 4.3b blocker note
  stands. All three stay **named hypotheses**, never `sorry`, never a vacuous placeholder.
- **Prohibited**: redefining or renaming `soundFuel'`; restating or re-proving anything in 4.3b /
  4.3c; any engine edit (wave-3 territory contract); baking `|S| = 1` into `worldFuel'`; letting
  `hww` disappear into the figure.

**FINDING — the split arms multiply the fuel figure; residual 3 is *not* orthogonal to it
(2026-07-28h).** Report 06 §4's correction of the budget shape is confirmed by re-reading the
source and is now a landed theorem: `branchesUsed'` is a `let` bound once before each fold
(`Saturation.lean:646, :675`), the same value reaches every sibling (`:654, :681`), and the
accumulator carries no counter, so the budget is **path-shaped**. `splitBudget_preserved`,
`extendBudget_preserved` and `budget_le_of_betaBudget` land the linear invariant
`branchesUsed + β·fuel ≤ maxBranches` with `β` a hypothesis on `branches.length`, not the literal
`3`, and confirm it implies the landed `branchesUsed + fuel ≤ maxBranches` so nothing is weakened.

**But the budget was never the binding constraint in the split arms — the fuel is, and that half
does *not* compose orthogonally.** Source: `estimateBranchDifficulty` (`Saturation.lean:360-364`)
is `1 + 3·tempCount + 2·modCount + len/4`, hence **always ≥ 1**, so no arm is starved to zero
(`allocateFuelProportionally_pos` proves the floor). But `allocateFuelProportionally (fuel+1)`
(`:378-388`) hands each arm `min (max 1 (fuel.succ * d / max 1 total)) fuel` — a **proportional
share** — and the arms recurse at `min pair.2 fuel` (`:653, :680`). So `k` arms of equal
difficulty each get about `fuel / k`, and the progress-measure hypothesis
`U.card < b.toFinset.card + fuel` that `expandBranchWithFuel_isSome_of_noSplit` consumes is **not**
re-established at the arms by any parent fuel merely exceeding `U.card`. Adequate fuel for a
splitting run scales like `β ^ depth * worldFuel'`, and `depth` is bounded by nothing proved so
far. Three committed `#guard_msgs` rows run the real allocator and show it: `1000` units across
three arms gives `[333, 333, 333]`, and a second split inside an arm gives `[111, 111, 111]` — a
ninth of the original.

This is the same **class** of fact as the 4.3b blocker (`buildTableau_isSome` is false at the
engine default `maxBranches`): a real property of a deliberate engine policy, not a gap in a
proof. The proportional allocator exists for `#eval` reasons and the wave-3 territory contract
forbids editing it. **Consequence for the plan**: `NoSplit` stays the named hypothesis confining
the arms — which is exactly what restated criterion 3 requires — and any future unconditional
split-arm totality theorem must either (i) assume a split-depth bound and a fuel figure
exponential in it, or (ii) be preceded by an engine-side change to the allocation policy, which is
a *separate task* with its own conformance risk, not a Phase 4 sub-phase. Do **not** re-attempt
residual 3's fuel half as stated; it is refuted in that form.

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

**BLOCKER (4.3b -> 4.3c) — `buildTableau_isSome` as written is FALSE (2026-07-28d).** Raised as a
blocker rather than annotated as a deviation, per `.claude/rules/plan-compliance.md`: the plan step
cannot be executed as written, and the reason is a property of the engine's signature rather than
a proof difficulty.

- **What failed**: the sub-phase's named deliverable, `buildTableau_isSome`, i.e.
  `∀ φ fc, (buildTableau φ (soundFuel' φ) fc).isSome`.
- **Why it is false, from source**: `buildTableau` (`Saturation.lean:928-951`) calls
  `expandBranchWithFuel initialBranch fuel TimeOrdering.empty fc` at the **default**
  `maxBranches := 50000` (`Saturation.lean:590`), and that function's very first line is
  `if branchesUsed >= maxBranches then none` (`:594`). The counter increments once per extending
  step and by `branches.length` per split (`:624, :646, :675`), so a formula whose expansion
  explores more than 50000 branches returns `none` **at any fuel whatsoever**, including
  `soundFuel'`. Independently, `buildTableau`'s own last arm returns `none` when the branch is
  still unsaturated after the post-blocking pass (`:950`). Neither `none` is a fuel exhaustion,
  so no fuel figure can rule them out.
- **What is needed (4.3c)**: state the theorem over an explicit branch budget —
  `expandBranchWithFuel_isSome` with `maxBranches` universally quantified and a hypothesis bounding
  `branchesUsed`, then a `buildTableau`-level corollary at a `maxBranches` large enough. Do **not**
  edit the engine's default to dodge this: `maxBranches = 50000` is a deliberate runtime guard and
  the wave-3 territory contract forbids engine edits.
- **The two remaining mathematical residuals**, both now isolated behind named hypotheses in
  `Fuel.lean` rather than behind a sorry:
  1. **The label dimension.** `chain_le_stock` takes `∀ x ∈ run n, x.label ∈ L` as a hypothesis.
     `blocking_fires_of_card_lt` (4.2b) is what supplies it, but *its* `hchain` hypothesis — the
     times counted are totally ordered by `ancestorTimes` — is a run-level invariant nothing yet
     establishes. `timeLinearity` is what makes the ordering total, so the missing piece is an
     invariant tying `timeLinearity`'s effect to `ancestorTimes`. This is the single largest
     remaining piece of T3 and should be its own sub-phase.
  2. **The branching arms.** `chain_le_stock` covers `.extended` steps only. The `.split` /
     `.splitOrdered` arms fold over sub-branches and can report `none` through `resolveOpenArm`
     (`Saturation.lean:661-664, :686-689`), which is a separate obligation from the step bound.
- **A third residual, of a different kind — `TrichStock`.** The 4.2a decision deferred to 4.3 the
  cost of carrying `TrichClosed C b` through the loop. Measurement here **corrects that note's
  optimism**: `TrichClosed` is *anti*-monotone in the branch, so it cannot be transported forward
  at all, and the note's reason for optimism (`orderTrichotomy` emits only positive disjuncts) is
  true but insufficient — `negPos` fired on a branch formula `¬F(A ∧ B)` puts a *negated*
  `F(A ∧ B)` on the branch, and nothing in `TableauClosed` then supplies the other two disjuncts of
  that triple. `Fuel.lean` therefore re-establishes `TrichClosed` at each step from a stock-side
  hypothesis `TrichStock C`, which is exactly the C-only condition 4.2a rejected as a
  `TableauClosed` *field*. As a hypothesis it is sound and decidable, and it holds outright of any
  stock containing no `F(A ∧ B)`; as a field it would still make `TableauClosed` unsatisfiable, so
  **do not move it into `TableauClosed`**. Discharging it in general requires bounding the
  *negatively signed* formulas of a run more tightly than `C` does — showing a negated `F(A ∧ B)`
  reaches the branch only for the finitely many `A ∧ B` in the seed's trichotomy completion.
- **Prohibited**: do not use `sorry`, `def X := True`, or a vacuous placeholder for any of the
  above; do not weaken `tableauClosed_of_closureStep_subset`; do not edit the engine.

**BLOCKER (4.3b -> 4.3c) RESOLVED (2026-07-28e).** Both residuals the note above listed are
discharged in the sense it asked for, and the corrected `expandBranchWithFuel_isSome` is proved.
`lake build FormalSystem.Metalogic.Decidability` (1054 jobs) and `lake build BimodalTest`
(1949 jobs) green; zero sorries in `Verified/`; no new axioms
(`propext`, `Classical.choice`, `Quot.sound` only); conformance corpus verdict-neutral; five new
`#guard_msgs` rows added to the regression corpus.

- **Residual 1 (label dimension) — resolved down to one named side condition.** The decisive
  observation is that `chain_le_stock` universally quantifies `L`, so instantiating it at the
  run's *own* label set makes `hl` a triviality and moves the entire obligation into a
  **cardinality**. That cardinality then splits cleanly (worlds × times), and only the time factor
  is T2's business. The chain invariant itself comes from `timeLinearity` being self-suppressing:
  `firstIncomparablePair` scans for a pair neither of whose members is in the other's transitive
  future or past, so the rule's silence *is* pairwise comparability.
- **Residual 2 (branching arms) — isolated, not discharged.** Now carried by the `NoSplit`
  predicate rather than by prose, and `expandBranchWithFuel_isSome_of_noSplit` is stated over it.
- **The one NEW residual — `OrderDual`, and why it is a hypothesis.** `firstIncomparablePair`
  records comparability as `futureOf`-membership; `isTemporallyBlocked`, and hence
  `blocking_fires_of_card_lt`, reads it as `ancestorTimes` = `pastOf`. These are the forward and
  backward transitive closures of the *same* constraint list, so the duality holds — but proving
  it needs an induction on `reachableForward`/`reachableBackward` (`SignedFormula.lean:741,751`),
  and **both are `private`**, so the statement cannot even be written from `Fuel.lean`. There are
  exactly two routes: an engine edit (forbidden by the wave-3 territory contract), or
  `open private reachableForward reachableBackward from …`, which this repository already uses for
  precisely this situation (`Kamp/NfMultiAnchorBridge/InteriorGateGeneralK.lean:687`) and which is
  pure consumption — no engine edit, no re-proof. **Take the `open private` route.** The
  mathematical content is: forward BFS membership yields a constraint path, and backward BFS from
  the far end recovers the near end within the same number of layers; both closures run at the
  same default fuel (`100`), so no fuel mismatch is hidden in the statement. Five committed
  `#guard_msgs` rows (chain, fork, diamond, post-`identifyTime`, depth-30) witness it holding on
  the ordering shapes the engine actually builds, so it is not a silent assumption.
- **A dimension the earlier notes never named — worlds.** `chain_le_worlds_of_not_blocked` carries
  the world count as a parameter `W`. T1 bounds formulas and T2 bounds times; **neither bounds
  worlds**, and a `Label` has both components. The argument for `W` is the S5 rules' fresh-world
  discipline and is a genuinely separate obligation. Do not assume `soundFuel'` covers it — as
  defined, `soundFuel' = 2·n·2^(2n)` has no world factor at all.
- **`buildTableau_isSome` remains unprovable at the engine's default**, exactly as the blocker
  note said. `expandBranchWithFuel_isSome_of_noSplit`/`_of_stock` are the corrected statements; a
  `buildTableau`-level corollary requires a caller that fixes `maxBranches`, which the current
  signature's default does not permit without an engine edit. Do not re-attempt the unconditional
  form.

### Phase 5: Bridge Infrastructure (BranchOrder, Embed, Carrier) [COMPLETED]

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
  - [x] **5.1 `Verified/Bridge/BranchOrder.lean`** (new) *(rewritten 2026-07-27; the original
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
  - [x] **5.2 `Verified/Bridge/Embed.lean` + `Verified/Bridge/Carrier.lean`** (new):
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

**PHASE 5 STATUS (2026-07-28c) — COMPLETE, sorry-free, both builds green.**

*5.1 delivered, with one design refinement the plan text did not anticipate.* `timeOrderTotal`
alone is **not** sufficient to package a `LinearOrder`: it delivers totality only, and the other
two `LinearOrder` obligations fail for independent, measured reasons. Transitivity of
`strictBefore` (`futureOf`-membership) is **not a theorem** — `futureOf` is a fuel-bounded BFS
(default `fuel := 100`), so on a chain longer than the fuel it under-reports and transitivity is
false as stated about the function the engine calls. Antisymmetry fails on a **cyclic** constraint
list, which `addFuture` never guards against; the pinned probe
`#eval timeOrderTotal chainBranch ⟨[(0,1),(1,2),(2,0)]⟩ = true` shows `timeOrderTotal` reporting
`true` for an inconsistent order. The landed gate is therefore
`branchOrderValid b ord := timeOrderTotal b ord && orderIrrefl b ord && orderTransOn b ord` —
still ONE decidable `Bool`, carried on a certificate exactly as `timeOrderTotal` was designed to
be, with the two new conjuncts quantified over `b.knownTimes` (cubically many checks). The
order-level branching rule's done-criterion is unchanged in kind: one more conjunct to flip.

*Indexing decision, settled:* `BranchTime b := Fin b.knownTimes.length` — the simple indexing, NOT
the `ord.constraints ∪ knownTimes` union. 2.5's non-destructive expansion removed the cause of the
Q2.2 symptom, and union indexing would force the bridge to invent semantic content for times
carrying no formulas.

*Construction route:* `linearOrderOfSTO` on the strict relation `branchLT`, not a hand-rolled
`LinearOrder` literal. A literal with an opaque `le` field **cannot** synthesise the `rfl` defaults
for `lt_iff_le_not_ge` / `min_def` / `max_def` / `compare_eq_compareOfLessAndEq` — measured, four
errors. `branchLT` carries an index-level tiebreak (`timeAt i = timeAt j ∧ i < j`) so trichotomy
and irreflexivity hold with no `List.Nodup b.knownTimes` side condition to thread downstream; the
tiebreak never fires on a real branch, since `knownTimes` is `eraseDups`.

*5.2 delivered as specified.* `FrameConditionFor` is **`Type`-valued, not `Prop`-valued** — forced
by `.Discrete`, whose `SuccOrder`/`PredOrder` binders are data, not propositions. `.Dedekind`'s lub
component is `isLUB_csSup`; the plan's `Real.isLUB_sSup` **does not exist** (refuted by the
name-verification pass), as does not `OrderEmbedding.trans` (the composition is
`RelEmbedding.trans`, since `↪o` unfolds to `RelEmbedding`). Both corrections are recorded in
`Embed.lean`'s verification docstring. The name pass carried a deliberate control error which
reported `unknown identifier`, per constraint 2.

*New API for Phases 6 and 7:*
- `branchOrderValid b ord : Bool` — the gate; `total_of_valid` / `irrefl_of_valid` /
  `trans_of_valid` unpack it into relational form
- `BranchOrder b ord h : LinearOrder (BranchTime b)`; `BranchOrder_lt_iff` / `BranchOrder_le_iff`
  (both `Iff.rfl`), `lt_of_strictBefore`, `le_of_strictBefore`, `strictBefore_of_lt`
- `timeAt b i` / `timeAt_mem`, plus `Finite`/`Fintype (BranchTime b)`
- `embed_finite_to_dense` (ℚ/ℝ), `finOrderEmbInt` / `finiteOrderEmbInt` / `embed_finite_to_int` (ℤ)
- `class TemporalCarrier fc D` with the four instances `.Base ℚ`, `.Dense ℚ`, `.Discrete ℤ`,
  `.Dedekind ℝ`; `HasLUBs`, `DiscreteStructure`, `FrameConditionFor`
- `exists_monotone_placement fc D h : ∃ f : BranchTime b → D, Function.Injective f ∧ ∀ i j,
  (BranchOrder b ord h).le i j ↔ f i ≤ f j` — **the interface Phase 6 starts from.** Stated with an
  explicit `.le` rather than an instance-in-statement `letI`, because `Fin`'s own `instLEFin` wins
  over a `letI`-introduced `LinearOrder` in a `↪o` statement position (measured).

*Regression corpus:* +7 `#guard_msgs` rows (6 in `BranchOrder.lean`, 1 in `Embed.lean`), total 30.

**DO NOT RE-ATTEMPT in Phase 6/7:**
- Proving `strictBefore`/`futureOf` transitive outright — false at fixed fuel; consume
  `trans_of_valid` instead.
- Weakening the gate back to `timeOrderTotal` alone — the cycle probe refutes it.
- A Mathlib linear extension of a partial branch order (`extend_partialOrder`/`LinearExtension`)
  — unsound, counterexample recorded in `BranchOrder.lean`'s module docstring.
- Reusing `embed_finite_to_dense` for `ℤ` — `ℤ` is not densely ordered under any weakening.
- A `Prop`-valued `frame_condition` — `SuccOrder`/`PredOrder` are data.

### Phase 6: Interpolation — the Mathematical Core (WP4 stage 3) [COMPLETED]

- **Goal:** A total model on the carrier `D`, constant on half-open intervals between embedded
  branch times, with truth invariance on each interval — the countermodel's engine
  (`Verified/Bridge/Interpolate.lean`, new; 02 §5.2 stage 3).
- **Tasks:**
  - [x] **6.1 Model construction + propositional/modal invariance** *(deviation: altered — the
    partition is singletons `{d_i}` plus OPEN gaps `(d_i, d_{i+1})` and the two open rays, NOT
    the half-open `[d_i, d_{i+1})` the plan text specifies; forced by a measured counterexample,
    see the PHASE 6 STATUS banner below)*: define the constant-on-
    `[d_i, d_{i+1})` valuation extension (total on `D` — never an island, constraint 6); prove
    `interp_invariance` for atoms, propositional connectives, and `box` (universal over `Omega`,
    no accessibility). Estimated output: ~200-350 lines. Done when: those cases of the induction
    are sorry-free with the temporal cases stated and the file structured so 6.2/6.3 fill them;
    intermediate `sorry`s here are FORBIDDEN — instead split the theorem into per-case lemmas so
    each sub-phase lands complete lemmas only.
  - [x] **6.2 Temporal universal/existential cases** *(deviation: altered — the four derived
    operators are definitionally `untl`/`snce` wrapped in `imp`/`bot`, so they land as one-line
    corollaries of 6.3; and no `sat_*` fact is consumed, because `InterpInvariant` is a statement
    about the constructed model, not about the branch — the saturation facts belong one level up,
    in Phase 7's truth lemma)*: `allFuture`/`allPast`/`someFuture`/
    `somePast` cases of `interp_invariance`, consuming the repaired transitive ordering facts and
    the branch saturation (`sat_*`) facts. Estimated output: ~200-400 lines. Done when: cases
    sorry-free; build green.
  - [x] **6.3 `untl`/`snce` cases** *(deviation: altered — the open-interval guard is discharged
    from the region structure and carrier density, not from a branch-side trichotomy fact; see
    the banner below. Closed on the first dispatch, so the bounded-unit stopping condition never
    fired)*: discharge the open-interval guard using the trichotomy-
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

**PHASE 6 STATUS (2026-07-28d) — COMPLETE, sorry-free, both builds green.** One dispatch, not
three. `lake build FormalSystem.Metalogic.Decidability` and `lake build BimodalTest` both green;
`interpInvariant` verifies on `propext`/`Classical.choice`/`Quot.sound` only.

*The half-open partition the plan specifies is WRONG, and the correction is forced.* Under
`[d_i, d_{i+1})` the region is closed on the left, so its least element `d_i` has no region-mate
below it and every past-directed operator can tell `d_i` apart from its own region. Measured
counterexample, recorded in `Interpolate.lean`'s module docstring: `D = ℚ`, placed points
`{0, 1}`, model constant on half-open regions with an atom `p` true exactly on `[0,1)`. Then
`somePast p` is **false** at `0` and **true** at `1/2`, and `0` and `1/2` are half-open
region-mates. The dual failure afflicts future-directed operators under `(d_i, d_{i+1}]`; no
orientation of a half-open partition works.

*The landed partition:* `SameRegion f r r' := ∀ i, (f i < r ↔ f i < r') ∧ (r < f i ↔ r' < f i)` —
"`r` and `r'` stand in the same order relation to every placed point". The regions are the
**singletons** `{d_i}` together with the **open** gaps `(d_i, d_{i+1})` and the two open rays.
Singleton regions are invariant trivially (`sameRegion_singleton`); open regions have members on
both sides of any member, which is exactly what the temporal cases consume. `region_total` is the
"never an island" statement (every `r : D` is a placed point, below everything, above everything,
or in a gap with identified endpoints); `regionExtend` is the total-on-`D` extension operator.

*Density is load-bearing, and `.Discrete ℤ` is NOT covered.* "An open region has a member
strictly above (below) any of its members" is **false on `ℤ`** — with placed points `{0,2}` the
gap `(0,2)` is the singleton `{1}`. This is proved, not suspected:
`not_exists_gt_sameRegion_int`. So `interpInvariant` and every temporal case carry
`[DenselyOrdered D] [NoMaxOrder D] [NoMinOrder D]`. `.Base ℚ`, `.Dense ℚ` and `.Dedekind ℝ` all
satisfy these (checked by `inferInstance` in the file). **`.Discrete ℤ` needs a separate route in
Phase 7** — this is the one genuinely open item this phase creates.

*No `sat_*` fact is consumed.* `InterpInvariant` is a statement about the constructed model, so
it follows from the region structure and density alone. The branch's saturation facts are
consumed one level up, by Phase 7's truth lemma, which is where model values get tied to what the
branch asserts. Lemma statements are as the plan specifies; only their hypothesis lists are
shorter.

*New API for Phase 7:*
- `SameRegion f r r'`, `regionCode`, `sameRegion_iff_regionCode_eq`; `SameRegion.refl/symm/trans`,
  `sameRegion_convex`, `sameRegion_singleton`, `sameRegion_of_gap`, `placed_ne_of_sameRegion_ne`
- `regionExtend f g : D → W` (total on `D`), `regionExtend_apply`, `regionExtend_congr`,
  `regionExtend_total`
- `exists_greatest_placed_lt`, `exists_least_placed_gt`, `exists_gt_sameRegion`,
  `exists_lt_sameRegion`, `region_total` (all over `[Fintype ι]`)
- `exists_region_placement fc D h` — `exists_monotone_placement` upgraded to the region structure,
  preserving the explicit `(BranchOrder b ord h).le` shape
- `RegionConstant f τ` (the hypothesis Phase 7's history construction must discharge),
  `InterpInvariant f M Om χ`
- `interpInvariant_atom/bot/imp/box/neg/top/untl/snce/someFuture/somePast/allFuture/allPast`
- `interpInvariant hRC χ` — **the assembled induction, the interface Phase 7 starts from**

**DO NOT RE-ATTEMPT in Phase 7:**
- A half-open `[d_i, d_{i+1})` (or `(d_i, d_{i+1}]`) region partition — refuted above.
- Dropping the density hypotheses from the temporal cases — `not_exists_gt_sameRegion_int` refutes
  it, and it is a theorem in the file.
- Serving `.Discrete ℤ` from `interpInvariant` — `ℤ` is not densely ordered, so the hypothesis is
  unsatisfiable there. A discrete-specific truth lemma is required.

### Phase 7: Truth Lemma and Track A Decidability — MILESTONE [BLOCKED]

**ENGINE CONTRACT CHANGE (2026-07-28b, from sub-phase 2.7c).** See the identically-titled note
under Phase 5 — it applies here verbatim. The short version: a `.inr` arm out of a split is now
fully saturated, `.allClosed` now means every sub-branch genuinely closed, and an unsettleable
arm surfaces as `none`/`STALLED` rather than as a closure. `not_valid_of_hasOpen` consumes the
`hasOpen` certificate, so point 1 is the one that matters most here.

- **Goal:** **Headline result 1**: `not_valid_of_hasOpen` generic in the carrier, semantic rule
  soundness, and `Decidable` instances for all four frame classes. On completion this task has
  delivered standalone publishable value regardless of Track B's fate.
- **Verification Tier**: `full` (7.3 runs the conformance corpus); sub-phases 7.1a–7.1e declare
  their own tiers in the RECORDED DECISION block below.
- **Tasks:** **SUPERSEDED — the 7.1/7.2/7.3 bullets below are the original decomposition and are
  retained as the record. The task list in force is the one inside the RECORDED DECISION
  (2026-07-28j, report 07) at the end of this phase.** 7.2 and 7.3 survive that decision
  essentially unchanged; 7.1 is replaced by 7.1a–7.1e.
  - [ ] **7.1 `Verified/Bridge/Omega.lean` + `Verified/Bridge/TruthLemma.lean`** (new)
    *(in progress — handoff; O1 and O3 landed sorry-free, and the 2026-07-28g banner corrects both
    residuals the 2026-07-28f banner named — `BoxContextClosed` → `BoxTemporalSpread`, `GapDemands`
    → `GapAdequate` + `branchGapVal`. See the PHASE 7 STATUS banners below, latest last, for what
    landed and what is owed)*: build
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

**PHASE 7 STATUS (2026-07-28e) — PARTIAL after one dispatch. 7.1 half landed, sorry-free, both
builds green** (`lake build FormalSystem.Metalogic.Decidability`, `lake build BimodalTest`); every
new theorem verifies on `propext`/`Classical.choice`/`Quot.sound` only. 7.2 and 7.3 not started.

*What landed.* `Verified/Bridge/Omega.lean` (the countermodel's objects) and
`Verified/Bridge/TruthLemma.lean` (the invariance induction the truth lemma runs on), both
registered in `Decidability.lean`:
- `regionFrame W ι D` — states `W × (Set ι × Set ι)` (branch world + region code), `TaskRel s d s'
  := d = 0 → s = s'`. A **universal `TaskRel` is not available**: `nullity_identity` is an iff, so
  `TaskRel w 0 u` must imply `w = u`. This is the weakest relation the axioms permit, which leaves
  `respects_task` free for every history built on it.
- `regionHistory f w Δ`, `regionOmega f` (a `Set.range`, not `Set.univ`), `shiftClosed_regionOmega`,
  `mem_regionOmega_iff`, `regionOmega_total`, `worldHistory_ext`, `timeShift_regionHistory`.
- `truthAt_box_iff` / `truthAt_box_congr` / `truthAt_box_iff_base`, `regionHistory_eq_timeShift`,
  `truthAt_regionHistory_offset`, `regionConstant_regionHistory_zero`.
- `InterpInvariantAt` with all cases and the assembled `interpInvariantAt`, plus
  `interpInvariantAt_regionHistory` instantiating it at the countermodel's base histories, and
  `interpInvariantAt_of_interpInvariant` recording that nothing from Phase 6 is lost.

*Correction 1 — `Ω = Set.univ` is unusable, contrary to the 7.1 task text.* `Set.univ` is
shift-closed but contains the empty history (`domain := fun _ => False`), at which every atom is
false. `TruthAt … (box φ)` is a universal over `Ω`, so one such history falsifies `□p` outright
and no branch carrying `T(□p)` could be satisfied. `Ω` is therefore an explicit range: the
branch's worlds at every time offset. `Set.univ_shift_closed` is consequently NOT the fallback the
plan names; `shiftClosed_regionOmega` replaces it.

*Correction 2 — Phase 6's `∀ τ ∈ Ω, RegionConstant f τ` obligation is UNSATISFIABLE, and the
interface moves to a per-history form.* This supersedes the Phase 6 handoff's "first obligation".
A shift-closed `Ω` contains `timeShift τ Δ` for every `Δ`, whose state at `r` is `τ.states (r+Δ)`.
Fix `r ≠ r'`; since `ι` is finite only finitely many `Δ` put a placed point between `r+Δ` and
`r'+Δ`, so for cofinitely many `Δ` the two are region-mates and region-constancy of that translate
forces `τ.states (r+Δ) = τ.states (r'+Δ)` — i.e. `τ.states` constant, and a constant-state history
cannot separate two times, so no branch asserting `T(p) @ t₁` and `F(p) @ t₂` in one world is
satisfiable. Machine witness in-tree: `not_regionConstant_regionHistory_one` (`D = ℚ`, one placed
point at `0`, `Δ = 1`; the region-mates `-1/2` and `-2` have translates `1/2` and `-1` straddling
it). The replacement is `InterpInvariantAt f M Om τ χ`, hypothesised on `RegionConstant f τ` for
the single history plus `ShiftClosed Om`. **Building the history through `regionExtend` does not
help and is not what landed** — the region code is carried in the state directly. Phase 6's file
is untouched and all its region lemmas are consumed verbatim.

*Why the swap costs nothing, and why the `box` case got easier.* For any shift-closed `Ω`,
`time_shift_preserves_truth` upgrades the fixed-time universal into a universal over times:
`TruthAt M Ω τ x (box φ) ↔ ∀ σ ∈ Ω, ∀ y, TruthAt M Ω σ y φ` (`truthAt_box_iff`). So `box` truth
has no free evaluation point and its invariance case consumes **no** induction hypothesis — the
one case that forced Phase 6's global formulation. The `untl`/`snce` cases were already
single-history arguments and reproduce unchanged. Measured adequacy of this reading against the
engine: `□p → □Gp`, `□p → □□p`, `□p → G□p`, `□p → ¬◇F¬p` all CLOSE, as do the seriality rows
`Gp → Fp`, `¬(Gp ∧ G¬p)`, `¬(Hp ∧ H¬p)`, `F ⊤`, `P ⊤`, while the control `Fp → p` stays OPEN.

*What remains in 7.1* (documented in `TruthLemma.lean`'s "What the truth lemma still needs"):
- **O1 the valuation** — a `TaskModel (regionFrame …)` is a predicate on (world, region code);
  at placed codes the branch dictates it, at gap codes it is free.
- **O2 the gap policy** — `T(Gφ) @ (w,t)` needs `φ` at every `r > f t` and `T(□φ)` needs `φ` at
  every point of every base history (`truthAt_box_iff_base`), while region invariance transports
  only between region-*mates* and a gap region contains no placed point. Importing a value from an
  endpoint is exactly the half-open partition Phase 6 refuted, so the gap valuation must be defined
  outright and its consistency with every universal branch fact proved. This is the remaining
  mathematical content.
- **O3 a missing `sat_*` fact** — `sat_box_pos` propagates `T(□φ)` to every known world at the
  *same* time; the `box` case needs every known *label*. The engine has it (`boxTemporal`,
  `Tableau.lean:635`, plus the closed probes above) but there is no `sat_box_temporal` to consume.
  Proving it unfolds `applyRule` (`sat_box_pos` already needs `maxHeartbeats 1600000`), so budget
  it as its own sub-phase, not inside the truth-lemma induction.

**DO NOT RE-ATTEMPT (added by this dispatch):**
- `Ω := Set.univ` — the empty history falsifies every `□`.
- A universal `TaskRel` — `nullity_identity` is an iff and forbids it.
- Discharging `∀ τ ∈ Ω, RegionConstant f τ` by building the history through `regionExtend`, or by
  any other means — refuted above and machine-witnessed.
- Copying a gap region's valuation from an adjacent placed point — that is the refuted half-open
  partition wearing a different hat.

**PHASE 7 STATUS (2026-07-28f) — still PARTIAL after a second dispatch. O1 and O3 landed
sorry-free; both builds green** (`lake build FormalSystem.Metalogic.Decidability`,
`lake build BimodalTest`); every new theorem verifies on `propext`/`Classical.choice`/`Quot.sound`
only. O2 is the sole remaining content of 7.1; 7.2 and 7.3 are still not started.

*What landed.* Two new files, both registered in `Decidability.lean`:

- `Verified/Bridge/Valuation.lean` — **O1 discharged.** `placedCode f i := regionCode f (f i)`,
  `IsPlacedCode`, and `placedCode_injective` (injectivity of the placement lifts to the codes, via
  `placed_ne_of_sameRegion_ne`). `regionValuation f placedVal gapVal` is total on codes: placed
  codes read `placedVal`, every other code reads the parameter `gapVal`. `regionModel` packages it
  as a `TaskModel (regionFrame W ι D)`; `truthAt_atom_regionHistory` discharges the domain
  existential in `TruthAt`'s atom clause outright (region histories are total), and
  `truthAt_atom_placed` / `truthAt_atom_gap` are the two readbacks. `branchPlacedVal` /
  `branchModel` instantiate the placed half at `b.hasPosAt (.atom p) ⟨w, timeAt b i⟩`, and
  `truthAt_atom_branch_placed` is exactly the O1 statement the previous handoff asked for.
- `Verified/Bridge/BoxSaturation.lean` — **O3 discharged as far as saturation can reach.**
  `sat_box_temporal` (the lemma the previous handoff named as missing: `T(□φ) @ l` puts `T(Gφ) @ l`
  and `T(Hφ) @ l` on a saturated branch), `sat_all_future_pos` / `sat_all_past_pos` (`T(Gφ) @ (w,t)`
  puts `T(φ)` at every `t' ∈ timeOrd.futureOf t`, dually for `H`), and `sat_box_cross`. Kept in
  their own module because each unfolds `applyRule`; all three carry `maxHeartbeats 1600000`.

*Correction 3 — `gapVal` stays a parameter, and both endpoint-copy policies are now refuted in
tree.* The refutation was previously prose plus a region-constancy witness. It is now stated
against the actual model: `not_leftCopy_gapAdequate` and `not_rightCopy_gapAdequate`
(`Valuation.lean`) exhibit `leftCopyGap` / `rightCopyGap` at one placed point on `ℚ` under which
`G p` (resp. `H p`) is **false** at that point, although a branch carrying `T(G p)` together with
`F(p)` at one label is perfectly consistent. `GapDemands` names the obligation a correct policy
must meet (the `allFuture` and `allPast` survival conditions).

*Correction 4 — O3 as stated is only half available, and the other half is not a saturation fact.*
`sat_box_cross` reaches every label differing from `(w,t)` in **at most one** coordinate: other
worlds at time `t` via `sat_box_pos`, other times in world `w` via `sat_box_temporal` then
`sat_all_future_pos`/`sat_all_past_pos`. It does **not** reach `(w', t')` differing in both, and no
strengthening of `findUnexpanded = none` will make it: `boxPos` emits `T(φ)`, never `T(□φ)`, so
there is nothing at `(w', t)` for `boxTemporal` to act on. The engine still closes `□p → □Gp`,
`□p → □□p`, `□p → G□p`, `□p → ¬◇F¬p`, and the mechanism is `boxDiamondPersistence`
(`Tableau.lean:434`), which the six label-minting rules apply **at rule-application time**. The
missing fact is therefore a *branch invariant*, `BoxContextClosed` (`BoxSaturation.lean`), whose
proof is an induction over tableau construction, not over the rule table. `sat_box_all_labels`
already derives the full grid from `BoxContextClosed` + saturation, so the truth lemma's `box` case
has its interface; only the invariant's proof is owed.

*What remains in 7.1.*
- **O2, unchanged and now precisely bounded** — exhibit a `gapVal` satisfying `GapDemands` for
  every gated saturated branch. This is the one non-mechanical obligation left on the Phase 7
  critical path. It is the `denseRules` (`prior_U_gap`/`prior_S_gap`/`sep`) content: a gap region
  between consecutive placed points must carry `{φ : T(Gφ)` at or below the left endpoint`}` ∪
  `{ψ : T(Hψ)` at or above the right endpoint`}` ∪ the `□`-forced set ∪ the straddling `U`/`S`
  guards, and the consistency of that union is what the dense rules must be shown to guarantee.
- **`BoxContextClosed`** — the induction over tableau construction described above. Budget it as
  its own sub-phase; it touches no engine file, only reads them.

**DO NOT RE-ATTEMPT (added by this dispatch):**
- Defining the gap valuation by copying an adjacent placed point, in *either* direction — both
  halves are now machine-refuted (`not_leftCopy_gapAdequate`, `not_rightCopy_gapAdequate`).
- Trying to obtain cross-world *and* cross-time `T(□φ)` propagation from `findUnexpanded = none`.
  Measured impossible above; use `BoxContextClosed` instead.
- Adding the O3 lemmas to `CountermodelExtraction.lean` — they live in `Bridge/BoxSaturation.lean`
  precisely so an `applyRule`-unfolding timeout cannot take down the green prefix.

**PHASE 7 STATUS (2026-07-28g) — still PARTIAL after a third dispatch. Both residuals named by the
2026-07-28f banner were mis-stated; both are now corrected and the corrections are sorry-free and
green** (`lake build FormalSystem.Metalogic.Decidability`, `lake build BimodalTest`); every new
theorem verifies on `propext`/`Classical.choice`/`Quot.sound` only. 7.2 and 7.3 are still not
started. Both files remain purely additive; no engine file was touched.

*Correction 5 — `BoxContextClosed` is not a construction invariant, and `BoxTemporalSpread` is.*
The 2026-07-28f banner named `BoxContextClosed` ("`T(□φ)` at every known label") on the strength of
`boxDiamondPersistence` (`Tableau.lean:434`). Reading the six call sites refutes it on two
independent counts. First, every call site passes `boxDiamondPersistence branch l.world l.time
freshTime`, and that function reads `branch.boxPosAtWorldTime l.world l.time` — the box formulas at
the *triggering* label only, so a `T(□φ)` at another world is not copied to the fresh time. Second,
the world-minting rules copy box formulas' **contents**, not the formulas: `boxNeg`/`diamondPos`
(`Tableau.lean:541`, `:583`) run `branch.boxPosFormulas.filterMap` with the arm
`| .box inner => SignedFormula.pos inner {world := freshWorld, ...}`, so a fresh world receives
`T(B)` and never `T(□B)` — `BoxContextClosed` fails at the first minted world whenever any `T(□φ)`
is on the branch, which is exactly the case it was introduced to serve. Saturation does not repair
it either: `witnessPresent` (`Tableau.lean:1670`) suppresses `boxNeg`/`diamondPos` on the
*witness* alone (`F(ψ)`, resp. `T(ψ)`, at some known world), so the auto-propagation outputs are
outside the applicability test.
The replacement is `BoxTemporalSpread` (`Bridge/BoxSaturation.lean`): `T(□φ)` anywhere puts
`T(Gφ)` and `T(Hφ)` at **every known world** at the box formula's own time. That *is* maintained by
the world-minting rules, which copy `allFuturePosAtTime l.time` / `allPastPosAtTime l.time` — all
worlds — onto the fresh world. It is strictly weaker than `BoxContextClosed`
(`boxTemporalSpread_of_boxContextClosed`, so nothing is lost), and it is enough: `sat_box_grid`
derives the full grid from it plus saturation and `timeOrderTotal`, with no case needing `T(□φ)`
anywhere other than where it was found. Also landed: `mem_knownWorlds_of_mem`,
`mem_knownTimes_of_mem`, `mem_directFutureOf_iff_mem_constraints`,
`mem_directPastOf_iff_mem_constraints`, `mem_directFutureOf_iff_mem_directPastOf` (the one-step
converse), `TimeOrderConverse`, `knownTime_trichotomy`.

*Correction 6 — `GapDemands` was stated backwards and is vacuous; `GapAdequate` and `branchGapVal`
replace it, and O2's atomic half is discharged.* `GapDemands.future` takes *model* truth of
`G φ` at a placed point as its hypothesis, and `Truth.future_iff` (`Semantics/Truth.lean:264`) is an
`iff` making that hypothesis definitionally its own conclusion. `gapDemands_trivial`
(`Bridge/Valuation.lean`) proves every policy satisfies it — including `leftCopyGap` and
`rightCopyGap`, which the same file refutes. `GapDemands` is retained only so the mistake stays
visible. `GapAdequate` is the corrected obligation: *branch* fact as hypothesis, model truth at gap
points as conclusion, in three fields (`T(G p)` survives upward, `T(H p)` downward, `T(□ p)`
everywhere). `branchGapVal` defines the policy outright — at a gap code `c`, the atom `p` holds
when some index in `c.1` (placed points below the gap) carries `T(G p)`, or some index in `c.2`
(above) carries `T(H p)`, or `T(□ p)` is on the branch at all — reading only the region code and
the branch, so it imports nothing from an endpoint and is neither refuted copy policy.
`branchGapVal_gapAdequate` discharges all three fields.

*What remains in 7.1.*
- **`BoxTemporalSpread` for constructed branches** — the induction over tableau construction, now
  over an invariant the construction actually maintains. `sat_box_grid` consumes it; only the
  invariant's proof is owed.
- **`TimeOrderConverse`** — `t' ∈ futureOf t → t ∈ pastOf t'`. The one-step case is proved
  (`mem_directFutureOf_iff_mem_directPastOf`: both sides say the constraint list carries the edge);
  the closure case is a fuel-bounded BFS duality (forward and backward shortest-path depths agree,
  so equal fuel suffices) and is carried as an explicit hypothesis by every consumer. Small,
  self-contained, no engine dependency.
- **The truth-lemma induction itself**, with `branchGapVal` fixed as the atom clause's gap arm.
  Condition 4 of the O2 list — the `U`/`S` straddling guards, the `prior_U_gap`/`prior_S_gap`/`sep`
  content — is *not* a constraint on the gap policy: a guard is in general compound and a compound
  formula's value at a gap point is fixed by the induction, not by `gapVal`. It is discharged
  inside the induction, where the `untlPos`-minted witness (a placed point) and the dense rules'
  intermediate guards are available.

**DO NOT RE-ATTEMPT (added by this dispatch):**
- `BoxContextClosed` as a construction invariant — refuted above on two independent counts; use
  `BoxTemporalSpread`.
- `GapDemands` as the gap obligation — machine-proved vacuous (`gapDemands_trivial`); use
  `GapAdequate`.
- Folding the `U`/`S` straddling guards into the gap *policy* — they are compound-formula
  obligations of the induction, not degrees of freedom of `gapVal`.

**PHASE 7 STATUS (2026-07-28h) — still PARTIAL after a fourth dispatch. Both residuals named by
the 2026-07-28g banner are closed; one of them was closed by discovering it was already proved,
the other by refuting it and replacing it. Sorry-free; both builds green** (`lake build
FormalSystem.Metalogic.Decidability`, `lake build BimodalTest`); the sorry census over
`Verified/` reports `0`; every new theorem verifies on `propext`/`Classical.choice`/`Quot.sound`
only. 7.2 and 7.3 are still not started. No engine file was touched.

*Residual B (`TimeOrderConverse`) was not open — it was already proved, in another module.*
`Verified/Termination/Fuel.lean` carries `orderDual_holds`, for **every** `TimeOrdering`, via
`open private reachableForward reachableBackward` plus the shared breadth-first shape `bfsClosure`
(`bfsClosure_sound` for the forward half, `PathN.reverse` for the edge-by-edge reversal,
`bfsClosure_complete` and the `BfsInv` visited-set invariant for the backward half). `OrderDual`
and `TimeOrderConverse` are the same statement. `timeOrderConverse` (`Bridge/BoxSaturation.lean`)
is the rename, and every `hConv` hypothesis downstream is now dischargeable at the call site. The
two names are kept apart because the fuel module reaches the duality for a termination purpose
that has nothing to do with the box grid. **Lesson for the next dispatch: grep the whole
`Verified/` tree for an obligation's statement before budgeting a proof for it.**

*Correction 7 — `BoxTemporalSpread` is refuted on the engine's own output, and `BoxAnchored`
replaces it.* The 2026-07-28g banner named `BoxTemporalSpread` on the strength of the
world-minting copy (`boxNeg`/`diamondPos` copy `branch.allFuturePosAtTime l.time` and
`branch.allPastPosAtTime l.time` onto the fresh world, `Tableau.lean:553-559`). That reading of
the copy is correct; what it misses is that the copy happens at **one** time — the *triggering*
label's `l.time` — while the box formula does not stay at one time. `boxDiamondPersistence`
relabels `T(□φ)` from `(w,t)` to `(w,freshTime)`, so one `T(□φ)` on the seed becomes a `T(□φ)` at
every time the run later mints in that world, and `BoxTemporalSpread` then demands `T(Gφ)` at the
fresh world at every one of them, of which the mint supplied exactly one. Measured, not argued:
`(□p ∧ ◇q) → r` at `.Base`, fuel `200`, gives an OPEN saturated branch over 2 worlds and 7 times
with `boxTemporalSpreadCheck = false` — and note the world there is minted at the *same* time the
box sits at, so this is not the cross-time-mint case one would guess at. `(□p ∧ ◇(G q)) → r` and
the `.Dense` run of the same formula fail identically. Rows in
`Tests/BimodalTest/BoxSpreadProbe.lean` as `#guard_msgs`, so the refutation is re-runnable.
`BoxAnchored` is the correction — for each known world, **one** anchor time carrying `T(φ)`,
`T(Gφ)` and `T(Hφ)` together — and `boxAnchoredCheck` and `boxGridCheck` are both `true` on every
branch that refutes the spread. `sat_box_grid_of_anchored` derives the grid from it by
`knownTime_trichotomy` about the anchor; `boxAnchored_of_boxTemporalSpread` records that nothing
is lost by the weakening.

*Correction 8 — the box invariant does not want a construction induction, and the plan should
stop asking for one.* `timeOrderTotal`, the grid's *other* branch-level side condition, is nowhere
proved invariant under expansion in this development: it is a decidable check on the finished
branch, carried as `hTot : timeOrderTotal b timeOrd = true` and discharged per run by computation.
`BoxAnchored` has exactly the same character — a first-order condition on a finite branch,
decidable in the branch, needed only for the one saturated branch `hasOpen` returns — and
`boxAnchored_of_check` gives it the same treatment. `sat_box_grid_of_check` is the composed form
the truth lemma consumes, with both side conditions as `Bool` equations. This is what turns the
residual from "induct over `expandOnceUnblocked` across every rule in `allRulesForFC`, including
the two that mint worlds and the six that mint times" into "evaluate a `Bool`". A
construction-level proof of `BoxAnchored` is strictly stronger and remains worth having as
hygiene; it is **not** on the truth lemma's critical path, and treating it as if it were is what
the previous two dispatches spent themselves on.

*What remains in 7.1 — one item, and it is the mathematical content.* The **truth-lemma induction
itself**: `not_valid_of_hasOpen`, generic in `TemporalCarrier`, consuming the `sat_*` family and
the three now-complete interfaces (O1 `branchPlacedVal`/`truthAt_atom_branch_placed`, O2
`branchGapVal`/`branchGapVal_gapAdequate`, O3 `sat_box_grid_of_check`). `TruthLemma.lean`'s "What
the truth lemma still needs" section has been rewritten to say this and to name the interfaces;
it is the file the next dispatch should open. The `U`/`S` straddling guards are discharged inside
the induction, where the `untlPos`-minted witness (a placed point) and the dense rules'
intermediate guards are available; the preamble must state that `findUnexpanded = none` means "no
*ordinary* rule applies", since `serialityRule` sits outside `allRulesForFC`.

**DO NOT RE-ATTEMPT (added by this dispatch):**
- `TimeOrderConverse` as an open obligation — already proved as `orderDual_holds`.
- `BoxTemporalSpread` as a construction invariant *or* as a saturated-branch fact — machine-refuted
  on `(□p ∧ ◇q) → r`; use `BoxAnchored`.
- A construction induction for the box invariant as a *prerequisite* for the truth lemma —
  `boxAnchoredCheck` discharges it the same way `timeOrderTotal` is already discharged.

**PHASE 7 STATUS (2026-07-28i) — still PARTIAL after a fifth dispatch. The 2026-07-28h banner's
"one item remains, and it is the induction" reading is WRONG: O2 was not discharged, its
*interface* is refuted, and the refutation is machine-checked. Sorry-free; both builds green**
(`lake build FormalSystem.Metalogic.Decidability` — 1110 jobs; `lake build BimodalTest`); sorry
census over `Verified/` reports `0`. 7.2 and 7.3 are still not started. No engine file was
touched.

*Correction 9 — `GapAdequate` is necessary but NOT sufficient, and the truth-lemma induction must
not be started against it.* `gapAdequate_insufficient` (`Bridge/Valuation.lean`) proves three
things at once, of one two-formula branch `refuteBoxBranch` = `[T(□p), T(□(p → q))]` at a single
label: the policy `branchGapVal` **is** `GapAdequate` (that is `branchGapVal_gapAdequate`,
unchanged); the branch asserts `T(□(p → q))`; and the assembled model makes `□(p → q)` **false**.
The mechanism: `GapAdequate` constrains `gapVal` at *atoms* only, on the stated ground that "at
every compound formula the value is fixed by the induction". `truthAt_box_iff_base` destroys that
ground — `□` is the universal modality over every point of every base history, and
`regionHistory` has total domain, so `T(□χ)` for **compound** `χ` is a demand on the gap points'
*induced* values, which nothing but the atom policy can supply. With `T(□p)` on the branch and no
`T(□q)`/`T(G q)`/`T(H q)` anywhere, every gap point gets `p` true and `q` false, so `p → q` is
false there. The engine really builds branches of that shape: `Tests/BimodalTest/BoxSpreadProbe.lean`
row D reports `OPEN boxP=true boxPQ=true boxQ=false Gq=false Hq=false` for
`(□p ∧ □(p → q)) → r` at `.Base`. (Row E records that the same shape STALLS under `.Dense` at
fuel 200 and again at 400 — pinned as measured, and a separate question from the gap policy.)

*What the residual actually is.* Not a better `gapVal`. The gap's state must be closed under the
propositional consequences of the forced set
`{χ : T(Gχ) below} ∪ {χ : T(Hχ) above} ∪ {χ : T(□χ)}`, and a saturated branch is not closed under
those consequences — the lower ray gives the same failure from `T(H(p → q))`, `T(H p)` and `F(q)`
at the earliest known time, a perfectly satisfiable configuration that forces `q` on the ray with
nothing on the branch naming it. So O2's replacement is a **realisability condition on the
branch**, in the decidable-check family `timeOrderTotal` and `boxAnchoredCheck` already belong to.
Two candidate routes, **neither probed yet** — and by this task's own repeatedly-paid process
lesson, the next dispatch probes the engine before proving anything about either:

- *Model-side.* Each gap region takes the atoms of a chosen known label, with a `Bool` check that
  the chosen label's positive content contains the region's forced set. Cheap to check; costs a
  restatement of the induction target, which becomes indexed by the label assigned to each
  region, with the temporal cases re-derived at gap points rather than inherited.
- *Branch-side.* The dense rules realise each gap as an actual minted label
  (`prior_U_gap`/`prior_S_gap`/`sep` are already shaped for this) and those labels are placed in
  the carrier, so no region is forced by facts it does not itself carry. Costlier, and it touches
  the engine's rule set rather than the bridge.

*What else landed, and survives the correction untouched.* `sat_imp_pos`
(`Bridge/PropSaturation.lean`, new module): the one member of the `sat_*` family
`CountermodelExtraction.lean` never carried. `impPos` is the only **branching** propositional rule,
and `findApplicableRule`'s `.branching` arm declines a non-self-guarded, non-fresh-label rule
exactly when `bss.any (fun fs => fs.all branch.contains)` — for `T(ψ → χ)` that is literally
`F(ψ) ∈ b ∨ T(χ) ∈ b`. Isolated in its own module for the reason `BoxSaturation.lean` gives for
its own: the proof unfolds `applyRule` and needs `maxHeartbeats 1600000`. Nothing in it depends on
the gap policy, so the O2 refutation leaves it intact — the `imp` case needs it at *placed*
labels, where the branch dictates the valuation and no gap point is involved.

**DO NOT RE-ATTEMPT (added by this dispatch):**
- The truth-lemma induction against `GapAdequate`, with `branchGapVal` or any other policy —
  machine-refuted by `gapAdequate_insufficient`. The `box` case is where it fails, so an induction
  that leaves `box` for last will look healthy until the last case and then be unclosable.
- Any *atom-wise* gap policy read off the branch's `T(G ·)`/`T(H ·)`/`T(□ ·)` facts — the closure
  argument above rules out the whole family, not just the three policies already refuted by name.
- The union of the two copy policies ("left-or-right") as a rehabilitation of either — it dies on
  the rays, where one endpoint is missing and the other's own value is unconstrained by the
  `H`-demand that reaches past it.
- Re-deriving `sat_imp_pos` inside the induction, or adding it to `CountermodelExtraction.lean` —
  it exists, in `Bridge/PropSaturation.lean`, deliberately isolated.

**RECORDED DECISION — the gap arm is a REGION LABELLING, not a synthesised policy and not an MCS
bridge (2026-07-28j, report 07).** Resolves the "two candidate routes, neither probed yet" left
open by the 2026-07-28i banner. Adopted: the **model-side** candidate, in a specific form. The
"branch → BFMCS → existing parametric truth lemma" pivot was adjudicated and is **rejected**.

*The decision, in one sentence.* A region of the carrier takes the **atom content of a known branch
label**, chosen per region and certified by a decidable branch-level gate — not a policy synthesised
from the region's forced set, and not an MCS.

*Why the pivot is rejected — three independent grounds, first one decisive.*

1. **Its step 1 is inter-derivable with the goal.** `set_lindenbaum`
   (`Core/MaximalConsistent.lean:303`) is gated on `SetConsistent`. Write G for the Phase 7 goal
   `hasOpen → ¬ valid φ` and P for `hasOpen → SetConsistent {φ.neg}`. **P ⟹ G is already free**:
   `exists_mcs_with_negation` (`Decidability/FMP/FMP.lean:63`) plus `countermodel_dense`
   (`Chronicle/ChronicleToCountermodelBasic.lean:829`, which takes an MCS `A` with `φ.neg ∈ A` and
   `□¬U(⊤,⊥) ∈ A` and **no branch at all**) deliver the countermodel, so the pivot's steps 2–4 are
   not work, they are work already done for a different input. **G ⟹ P** holds by in-tree
   soundness. So P is not a weaker obligation than G; contrapositively P demands `⊢ φ ⟹ the tableau
   closes`, i.e. completeness of the tableau relative to the Hilbert calculus, whose only
   non-circular proof here runs through the model existence Phase 7 is trying to build. (A second
   obstacle sits on the same step: `countermodel_dense` also needs `□¬U(⊤,⊥) ∈ A`, so the Lindenbaum
   seed is a *pair* whose consistency the pivot never mentions.)
2. **Its step 3 names an obligation that does not exist.** `FMCS` (`Bundle/FMCSDef.lean:103`) has
   exactly four fields — `mcs`, `is_mcs`, `forward_G`, `backward_H`. `forward_F`/`backward_P` live in
   `BFMCS.RestrictedTemporallyCoherent` (`Bundle/TemporalCoherence.lean:308`), which **both** truth
   lemmas take as `_h_rtc` — leading underscore, unused in the proof body
   (`RestrictedParametricTruthLemma.lean:119`, `ParametricTruthLemma.lean:379`). `Formula` has no
   `G`/`H`/`F`/`P` constructors (`allFuture φ := (untl φ.neg ⊤).neg`), so the induction has six
   cases and every temporal obligation lands on `h_buc`/`h_fuc`
   (`TemporalCoherence.lean:489,541`) — which are strictly *stronger* than `forward_F`
   (`someFuture φ = untl φ ⊤`).
3. **No theorem in `Algebraic/` is applicable, and Chronicle has no finite seed.** Both truth lemmas
   hardwire `ParametricCanonicalTaskModel`, whose world states are `{M : Set Formula //
   SetMaximalConsistent M}` (`ParametricCanonical.lean:70,207`); the branch model's are
   `W × (Set ι × Set ι)`. And `omegaChain`'s base case is hard-wired to `singletonChronicle A`
   (`ChronicleConstruction.lean:70,283`) with no `omegaChainFrom` anywhere — and a seed chronicle's
   `f` must be MCS-valued regardless, so ground 1 applies unchanged.

*Why the region labelling escapes `gapAdequate_insufficient`.* That refutation is a fact about
**forced sets**, not about **label contents**. A saturated branch is propositionally closed *at each
label* — that is exactly `sat_imp_pos` (`Bridge/PropSaturation.lean:91`) — and `sat_box_grid_of_check`
(`Bridge/BoxSaturation.lean:566`) puts the box content at every label. On the refuting shape itself:
`T(□p)` and `T(□(p→q))` put `T(p)` and `T(p→q)` at every label, `sat_imp_pos` then forces `F(p)` or
`T(q)`, and openness rules out `F(p)` — so `T(q)` sits at every label and a region carrying a label's
atoms makes `p → q` **true**. The 2026-07-28i ban on "any atom-wise gap policy read off the branch's
`T(G·)`/`T(H·)`/`T(□·)` facts" stands verbatim: this policy is read off a *chosen label*, not off
those facts, and is not either refuted copy policy (those choose the source by *position*, which is
what breaks the non-reflexive `G`/`H` demands; this chooses by *content*, validated by a check).

*Measured before adopted, per this task's own process lesson.* Two unregistered probe files
(contents in report 07 §6, re-runnable via `lake env lean`) evaluated, on branches the engine
actually builds:

- **Stationary labels** (`T(Gχ)@l ⟹ T(χ)@l`, dually for `H`): rows `(□p ∧ ◇q) → r`,
  `(□p ∧ ◇Gq) → r`, the same at `.Dense`, `(□p ∧ □(p→q)) → r`, `Gp → p`, `¬(Fp → p)` report
  `stationary = 14/14, 13/14, 20/20, 4/4, 3/4, 4/4`. Row `Gp → p` is the discriminator: exactly the
  label carrying `T(Gp)` without `T(p)` fails, so the check is not vacuous.
- **Region fill** (a label absorbing every `G`-, `H`- and `□`-demand of its world, carrying no `F(·)`
  of any, and G/H-reflexive — strong enough to state *every* non-placed point of its world at once):
  `fillPerWorld = [7,7], [7,3], [10,10], [4], [2], [4]`. Every world of every open branch measured
  has **at least two**. The refuting shape has all four of its labels qualifying against 28 demands.

**Honest bound**: `absorbs` uses branch-wide demands (an over-approximation), checks no `untl`/`snce`
guard condition, and is not a proof that a gate of this shape suffices. It establishes the route is
not dead on arrival on the branches that killed the previous two interfaces. Sub-phase 7.1a exists
precisely because that is not the same as sufficiency.

*A strictly easier first milestone.* `valid` quantifies over the carrier
(`Semantics/Validity.lean:79`), so one carrier refutes it; and `finOrderEmbInt`
(`Bridge/Embed.lean:76`) is the `Nat`-cast, so `finiteOrderEmbInt` places `n` branch times at
`0,…,n-1` — **contiguous**. A contiguous ℤ placement has *empty* interior gap regions: the only
non-placed points are the two rays. `valid`/`ValidDiscrete` therefore lose the dense-gap problem
entirely, while `ValidDense` (ℚ) and `ValidDedekindDense` (ℝ) keep it. These are different problems
and the plan no longer treats them as one milestone. **Caveat verified and corrected**: only
`TemporalCarrier` instances for `Base ℚ`, `Dense ℚ`, `Discrete ℤ`, `Dedekind ℝ` are registered
(`Bridge/Carrier.lean:136-164`); a `Base ℤ` instance does not exist and is explicit work in 7.1c.

*Assets.* Nothing is deleted and no signature changes — `branchModel`'s `gapVal` **parameter**
survives; only the inhabitant `branchGapVal` is retired. Load-bearing: all of `Termination/`,
`BranchOrder`, `Embed`, `Carrier`, all of `Interpolate` (region-constancy is exactly what a
per-region label state delivers), `Omega`, `Valuation`'s `placedCode`/`regionValuation`/
`regionModel`/`branchPlacedVal`/`branchModel`/`truthAt_atom_placed`/`truthAt_atom_gap`, the whole
`sat_*` family with `boxAnchoredCheck`/`sat_box_grid_of_check`/`timeOrderConverse`, and `sat_imp_pos`
(promoted: it is *why* a label's content is propositionally closed). Retired but **kept as refutation
documentation**: `GapDemands`/`gapDemands_trivial`, `GapAdequate`/`branchGapVal`/
`branchGapVal_gapAdequate`, `leftCopyGap`/`rightCopyGap` and their refutations,
`gapAdequate_insufficient`.

#### Phase 7 task list in force (supersedes the 7.1/7.2/7.3 bullets above)

- [x] **7.1a Probe the gate before stating it** (new scratch probe rows only; no `Verified/` edit).
  **DONE (2026-07-28k)** — `Tests/BimodalTest/RegionGateProbe.lean`, registered in
  `Tests/BimodalTest.lean`, `lake build BimodalTest` green (1973 jobs). All nine rows report
  `total=true gate=true`: the six report-07 shapes at `.Base` plus three at `.Dense`. Both
  additions the sub-phase demanded were made and both fire: the `untl`/`snce` straddling guards
  (`T(U(φ,ψ))` below the region demands `ψ`, `T(S(φ,ψ))` above demands `ψ`) and the `F`-side
  demands (`F(U(φ,ψ))` below demands `¬φ`), the latter *subsuming* report 07's `G`/`H` demands
  rather than sitting beside them, since `T(Gχ)` is `F(U(¬χ,⊤))` on a saturated branch. The gate
  is measured non-vacuous three ways: `regionGate_refutable`'s two-label synthetic branch reports
  `gate=false`; row A excludes 4 of its 7 labels per region; row E (`G p → p`) discriminates
  exactly as it did in report 07, its interior regions admitting 2 labels rather than 3.
  Extend the two report-07 probes to the *per-region* demand — for each gap region and each ray,
  the `G`-demands from placed points below and `H`-demands from placed points above only — and add
  the two checks report 07 did not make: (i) the `untl`/`snce` guard conditions a region state must
  meet, (ii) the `F`-side (negative) demands at the chosen label. Report per-row `Bool`s for the
  same six shapes plus at least three `.Dense` rows. **Verification Tier**: `local`.
  Estimated output: ~120-200 lines, in `Tests/BimodalTest/`. Done when: the rows are `#guard_msgs`-
  pinned; **if any row reports `false`, STOP and record a DO-NOT-RE-ATTEMPT entry rather than
  proceeding to 7.1b** — that is the whole point of this sub-phase.
- [x] **7.1b `Bridge/RegionLabel.lean`** (new module):
  **DONE (2026-07-28k)** — sorry-free; `lake build FormalSystem.Metalogic.Decidability` green
  (1111 jobs); registered in `FormalSystem/Metalogic/Decidability.lean`. Delivered: `branchRank`;
  the six demand lists with a membership lemma each; `regionMeets`; `regionLabelCandidates`;
  `regionLabelCheck`; `regionLabel`; the four gate-unpacking lemmas; six consumption lemmas
  (`regionLabel_box`, `regionLabel_diaNeg`, `regionLabel_untlGuard`, `regionLabel_snceGuard`,
  `regionLabel_untlNeg`, `regionLabel_snceNeg`), every one stated **branch fact ⟹ branch fact at
  the chosen label**, with model truth never a hypothesis; `cutIndex`/`cutIndex_le`;
  `branchRegionVal` at the **unchanged** `branchModel` gapVal type; and the two model-side
  readbacks `truthAt_atom_branch_region` and `truthAt_atom_gap_of_box`. The last is the
  atom-level instance of the case that killed `GapAdequate`, and it goes the right way.
  Axiom audit: `propext`/`Classical.choice`/`Quot.sound` only. **Gate evaluates `true` on the
  7.1a corpus**: `RegionGateProbe.lean` now reports both its own `gate` and the library's
  `check` on every row, and the two agree on all ten (nine engine rows `true`, the synthetic
  row `false`) — an independent cross-check, since the probe's copy was written first and
  separately.
  *(deviation: altered — the gate's `F`-side row is the general `F(U(φ,ψ)) ⟹ ¬φ` rather than a
  separate `G`/`H` row. This subsumes rather than adds: `T(Gχ)` is `F(U(¬χ,⊤))` on a saturated
  branch, so the `G`/`H` demands are the `ψ = ⊤` instance. Measured equivalent in 7.1a.)*
  Original text: `regionLabel`, the per-region choice; the
  decidable gate `regionLabelCheck b timeOrd : Bool` in the family `timeOrderTotal` and
  `boxAnchoredCheck` already belong to; `branchRegionVal b regionLabel : WorldIndex → Set (BranchTime b)
  × Set (BranchTime b) → Atom → Prop` (**the existing `branchModel` gapVal type, unchanged**); and the
  consumption lemmas the induction will want, stated as *branch fact ⟹ model truth at gap points*
  in the corrected direction `GapAdequate` established (branch fact as hypothesis, never model truth).
  **Verification Tier**: `interface`. Estimated output: ~200-350 lines. Done when: sorry-free; the
  gate evaluates `true` on the 7.1a corpus; `lake build FormalSystem.Metalogic.Decidability` green.
- [x] **7.1c The ℤ milestone — `not_valid_of_hasOpen` for `valid` and `ValidDiscrete`.**
  **COMPLETE (2026-07-28o) — all six cases of `branchTruthAt` are sorry-free, both temporal cases
  in both directions, and the sorry census over `Verified/` reports `0`.** The negative halves
  landed at 2026-07-28n; the positive halves landed at 2026-07-28o together with rows 7-10 of
  `temporalWitnessCheck` and `Stepped`, which is the resolution of the witness-existence
  obstruction that banner identified. `not_valid_of_hasOpen_int` and
  `not_validDiscrete_of_hasOpen_int` are sorry-free, and the sub-phase's "done when: sorry-free at
  ℤ for both classes" is met. See the 2026-07-28o STATUS banner below.
  **PREREQUISITES DONE (2026-07-28k); the induction itself is NOT started.** Landed sorry-free,
  `lake build FormalSystem.Metalogic.Decidability` green (1112 jobs), `lake build BimodalTest`
  green (1975 jobs):
  - the missing `TemporalCarrier FrameClass.Base ℤ` instance (`Bridge/Carrier.lean`, noncomputable
    like its `.Discrete ℤ` sibling, with a by-name sanity check alongside the other four);
  - `Bridge/IntGaps.lean` (new module, registered): `placedCount`, `finiteOrderEmbInt_nonneg`,
    `finiteOrderEmbInt_lt_card`, `exists_preimage_finiteOrderEmbInt` (the contiguity itself),
    `isPlacedCode_finiteOrderEmbInt`, **`ray_of_gap_finiteOrderEmbInt`** — the dichotomy the
    induction consumes, "a non-placed integer lies on the lower ray or the upper ray, there is no
    third case" — plus `regionCode_fst_eq_empty_of_neg`/`regionCode_fst_eq_univ_of_card_le` and
    `cutIndex_eq_zero`/`cutIndex_eq_length`, which identify the two rays as region `0` and region
    `n` of `regionLabelCheck`'s indexing.
  **Import-closure findings, both real and both worked around rather than papered over**: neither
  `Set.ncard` nor `Nat.card` is in this project's Mathlib closure. `cutIndex`
  (`Bridge/RegionLabel.lean`) uses a `Finset.univ.filter` card under `open Classical`, and
  `placedCount` (`Bridge/IntGaps.lean`) is `@Fintype.card T (Fintype.ofFinite T)` written out —
  pinned to the very instance `finiteOrderEmbInt` itself computes with, so the bound cannot drift
  from the definition. A future dispatch adding either Mathlib import may simplify both; neither
  is blocked on it.
  **What remains of 7.1c**: the six-case induction. Original text: Add the
  missing `TemporalCarrier FrameClass.Base ℤ` instance; use `finiteOrderEmbInt`'s contiguity to show
  interior gap regions are empty, so only the two ray regions carry a `regionLabel`; run the
  six-case induction (`atom`, `bot`, `imp`, `box`, `untl`, `snce` — `Formula` has no `G`/`H`/`F`/`P`
  constructors, so there are exactly six) consuming `branchPlacedVal`, `branchRegionVal`,
  `sat_box_grid_of_check`, `sat_imp_pos` and `Interpolate`'s `InterpInvariant*`. **Write the `box`
  case first, then `untl`** — the 2026-07-28i lesson: the case that tests the interface goes first.
  The preamble must state that `findUnexpanded = none` means "no *ordinary* rule applies", since
  `serialityRule` sits outside `allRulesForFC`. **Verification Tier**: `full`.
  Estimated output: ~300-450 lines. Done when: sorry-free at ℤ for both classes; **green milestone
  commit**.
- [x] **7.1d The dense milestone — `ValidDense` (ℚ) and `ValidDedekindDense` (ℝ).** *(COMPLETE
  2026-07-28q: all four temporal halves, the assembly, the ℚ/ℝ instantiation and both headline
  results, sorry-free. See the 2026-07-28q banner.)* The same
  induction with non-empty interior gap regions. This is where the `prior_U_gap`/`prior_S_gap`/`sep`
  content lives and where a single region label must meet *both* the `G`-content from the left and
  the `H`-content from the right. Consume `Interpolate`'s `exists_gt_sameRegion`/
  `exists_lt_sameRegion` (both need `DenselyOrdered` + `NoMaxOrder`/`NoMinOrder`, available at ℚ/ℝ).
  **Verification Tier**: `full`. Estimated output: ~250-400 lines. Done when: sorry-free for both
  classes; green milestone commit.
- [x] **7.1e Demote or delete `branchTruth`** (`CountermodelExtraction.lean:263`) — unchanged from
  the original 7.1 text and unaffected by this decision; it must no longer appear on any proof path.
  **Verification Tier**: `local`. Estimated output: ~20-40 lines.
  **COMPLETE (2026-07-28p) — deleted, not demoted, and the choice is evidence-backed.**
  `branchTruth` and its only consumer `signedTruthInModel` are gone. The retirement note had
  defended keeping the evaluator on the ground that it was "an executable debugging aid, useful
  for `#eval`-inspecting what a branch claims". Measured rather than believed: `branchTruth` is
  `Prop`-valued and carries no `Decidable` instance, so `Decidable (branchTruth cm w t f)` fails
  to synthesise and `#eval` was never available on it. With that gone the definition was on no
  proof path, could not be run, and its sole consumer was referenced nowhere in the project — so
  "demote" had nothing left to demote to. The module docstring's stale "Semantic Correctness
  Guarantee" section, which still advertised the long-retired `branchTruthLemma` as a key
  theorem, was replaced by a pointer to where the truth lemma actually lives. Full `lake build`
  green (1939 jobs).
- [ ] **7.2 Semantic rule soundness** (`Verified/Decidable.lean`, new) — **BLOCKED
  (2026-07-28t) at 16 of 28 rules, all sorry-free. The assembly's target statement is FALSE as
  written, and the `RuleSound`-weakening repair is now measured impossible: the refuting branch
  is one the engine itself builds, and `buildTableau` consequently closes an invalid formula.
  Unblocking requires an engine change to `applyRule`'s group-3 blocks — see the 2026-07-28t
  banner for the defect at the four-element bar, and for why it was escalated rather than
  attempted.** *(deviation: escalated, not substituted — per `plan-compliance.md`, a step that
  cannot be executed as written on a `.lean` file is raised as a blocker.)*
  Previously **STARTED
  (2026-07-28s), 15 of 28 rules landed sorry-free; not closed, and the assembly's target
  statement is now known to be FALSE as written — see the 2026-07-28s banner.** The module exists and is
  registered: `SatState` (the satisfiability notion), `SatResult` (preservation read off
  `applyRule`'s own `RuleResult × TimeOrdering`), `RuleSound` indexed by a `CarrierProp`, and
  `RuleSound.mono`. Landed: the eight truth-functional rules and the three label-preserving modal
  rules (`boxPos`, `diamondNeg`, `boxTemporal`). Open: `boxNeg`/`diamondPos` (obligation stated,
  see the 2026-07-28r banner), the eight temporal quantifier rules, the four `untl`/`snce` rules,
  `orderTrichotomy`, the eight frame-class-gated rules, and the assembly itself.
  *(deviation: altered — delivery split by rule **shape family**, one green commit each, rather
  than one induction landed whole. The single induction over `allRulesForFC` via
  `mem_allRulesForFC_iff` is unchanged as the assembly; what changed is that its 28 per-rule
  obligations are discharged in families first. The estimate of ~250-450 lines was for the whole
  sub-phase and is low: 11 rules cost ~690 lines including the framework.)*
  Original text: the `allClosed → valid` direction as ONE induction over `allRulesForFC fc`,
  using `mem_allRulesForFC_iff` from Phase 3. **Verification Tier**: `full`. Estimated output:
  ~250-450 lines. Done when: sorry-free for all four classes via the single induction; build green.
- [ ] **7.3 `valid_iff_allClosed` + `Decidable` instances** — **unchanged in content, split in
  delivery**: the `valid`/`ValidDiscrete` pair may land after 7.1c without waiting for 7.1d.
  **Verification Tier**: `full`. Estimated output: ~150-300 lines. Done when: all four instances
  sorry-free; conformance corpus green with zero expected-failure rows remaining for validity
  verdicts; **green milestone commit**.

**Timing:** 5-6 dispatches. **Depends on:** 3, 4, 6.

**PHASE 7 STATUS (2026-07-29b) — the `RuleSound` statement blocker is CLOSED. 7.2 goes 18 → 23,
and the denominator is corrected from 28 to 34.** Seven green commits, each verified by
`git show --stat`. `lake build FormalSystem.Metalogic.Decidability.Verified.Decidable` green
(1350 jobs); `lake env lean` green on `Tableau.lean` and `Verified/Decidable.lean`; sorry census
over `Verified/` reports `0`.

1. **THE AUTHORIZED STATEMENT CHANGE LANDED, IN ITS CORRECTED FORM.** `RuleSound` now carries
   `OrdWithin b ord := ∀ p ∈ ord.constraints, p.1 ∈ b.knownTimes ∧ p.2 ∈ b.knownTimes` as its
   **last** hypothesis, after `SatState`. The *membership* form, not the numeric `< b.nextTime`
   form the prior dispatch proposed: the numeric bound is refuted as an inductive invariant by
   the identification arm of `timeLinearity`, the engine's one non-additive step, which can lower
   `nextTime` while a constraint endpoint survives the rewrite. Membership is stable under exactly
   that operation and implies the numeric bound (`OrdWithin.bound`), so the fresh-time producers
   lose nothing. 19 sites, not 18 — `RuleSound.mono` needed an extra `intro` *and* an extra
   `exact` argument. Position was load-bearing exactly as predicted; all 18 rule proofs take one
   appended anonymous `intro` and none consumes the hypothesis.
2. **ALL FOUR FRESH-TIME EXISTENTIALS ARE PROVED**, sorry-free: `allFutureNeg`, `allPastNeg`,
   `someFuturePos`, `somePastPos`. Plus `denseIndicatorClosure` (emits `.linear []`, so the
   handed-in state discharges it; proved at `carrierBase`, reusable at `.Dense` through
   `RuleSound.mono`). The three latter existentials went green on the first attempt against the
   infrastructure the first one established.
3. **THE DENOMINATOR IS 34, NOT 28.** `TableauRule` has 36 constructors; `allRules` has 26;
   `+ denseRules` 2 `+ discreteRules` 3 `+ dedekindRules` 3 = 34 reachable through
   `allRulesForFC`; `+ serialityRule + timeLinearity` = 36 the engine actually fires. Line 177 of
   this plan already warned against the "28" figure and the warning had been going unread for
   several dispatches. Older banners below retain "of 28" as written; they are historical record.
4. **A NEW ENGINE DEFECT BLOCKS THE `untl`/`snce` FAMILY**, independent of the ordering gap just
   closed and of the same family as the group-3 defect already removed from `boxNeg`/`diamondPos`.
   `untlPos`, `sncePos` and the ACTIVE arms of `untlNeg`/`snceNeg` copy `F(U(e', g'))`
   *unconditionally* from the trigger's time to the minted time. `Until`'s truth is
   interval-relative, so — unlike the `□`/`◇` copies, which are `Ω`-universal and so
   time-invariant under shift-closure — no transfer argument exists. Counterexample recorded in
   full in `Verified/Decidable.lean`: with `e'` true exactly on `{1/n}` and `g'` false exactly on
   `{1/n}`, `¬U(e', g')` holds at `0` but `U(e', g')` holds at every `d ∈ (0,1)`, and every
   witness time either emitted branch admits lies in that range. ESCALATED, not repaired: it is an
   engine change and needs the conformance corpus as its acceptance gate, as task 418's did.
   The PASSIVE arm of `untlNeg`/`snceNeg` is sound and provable today, but cannot land alone
   because `RuleSound` is stated per rule and `untlNeg` owns both arms.

**PHASE 7 STATUS (2026-07-29a) — 7.2 is at 18 of 28 rules sorry-free, and the engine blocker
that closed the previous dispatch is RESOLVED. A NEW blocker replaces it, in `RuleSound`'s own
statement rather than in the engine, and it is escalated rather than taken.** Four green commits.
`lake build FormalSystem.Metalogic.Decidability.Verified.Decidable` green (exit 0, 1350 jobs);
`lake env lean` green on `Tableau.lean` and on `Verified/Decidable.lean`; sorry census over
`Verified/` reports `0`. **The full conformance corpus (`Tests/BimodalTest/TableauConformance.lean`,
27 rows) ran to completion, exit 0, every `#guard_msgs` row matching** — the acceptance gate the
previous handoff demanded, satisfied.

*The engine fix had already landed, under a different task.* The previous handoff's top
obligation was to remove the six group-3 temporal-copy blocks from `boxNeg`/`diamondPos`. That
was done by task 418 (commit `c2a25cfb5`), gated on the full corpus, with baseline and after
verdicts recorded under that task's `artifacts/`. Verified here rather than assumed: the six
identifiers are absent from `Tableau.lean`, and `applyRule`'s docstring now carries the
prohibition against reintroducing them. **Nothing was re-done.**

*What landed here.* (1) `mem_boxDiamondPersistence_label`, the label-level companion the four
fresh-time rules were said to be blocked on — it recovers the fresh label `(w, ft)` and the
source label `(w, t)` with matching sign and formula, where `mem_boxDiamondPersistence` recovers
only the formula. Prop-valued, additive, one `Tableau.lean` rebuild as the handoff advised.
(2) **`ruleSound_boxNeg` and `ruleSound_diamondPos`**, taking 16 → 18, together with the two
shared helpers `satAt_of_mem_boxProps` and `satAt_of_mem_diaProps`.

*Why the two fresh-world rules were reopened despite a DO-NOT-RE-ATTEMPT entry.* The register
said both "remain false, now for a strictly stronger reason". That entry's premise was the
presence of the group-3 blocks. The blocks are gone, so the premise is void and the entry with
it. This is the same failure mode the previous dispatch's own process lesson named — reusing a
recorded value in a new argument without rechecking its meaning — applied to the register itself.
Both rules are now proved, sorry-free, first-attempt-green.

*THE NEW BLOCKER, at the four-element bar, and it is a statement defect, not an engine defect.*
`RuleSound carrierBase r` is **false** for all six fresh-*time* producers (`allFutureNeg`,
`allPastNeg`, `someFuturePos`, `somePastPos`, and the `untl`/`snce` fresh-time arms).
`Branch.nextTime` is `b.maxTime + 1`, a function of the *branch* alone; `SatState`'s four fields
relate `ord`'s times to `b`'s times in none of them; and `RuleSound` quantifies over `b` and
`ord` independently. So `ord` may already mention `b.nextTime`, and since `addFuture` merely
conses, the successor ordering can be cyclic — at which point **no** re-choice of `tv` satisfies
`ordResp`. Proved, not argued: `addFuture_nextTime_cycle_unsatisfiable` and
`addPast_nextTime_cycle_unsatisfiable` in `Verified/Decidable.lean`. The engine never builds such
an ordering (it threads from `TimeOrdering.empty` and only ever adds an edge to a genuinely fresh
index), which is exactly why this is a defect in the statement.

*Two remedies, both escalated per `plan-compliance.md` rather than taken.* (1) A fifth `SatState`
field bounding `ord`'s times by `b.nextTime` — **measured obstruction: this is blocked, not
merely costly.** Any such field mentions `b` positively, and `SatState.mono` weakens `b` to a
sublist with a *smaller* `nextTime`, so the field does not survive `mono`, which is consumed
throughout. (2) A well-formedness hypothesis on `RuleSound` — `∀ p ∈ ord.constraints, p.1 <
b.nextTime ∧ p.2 < b.nextTime`. Survives `mono`, costs the eighteen landed proofs one `intro`
each, discharged at the assembly by induction from `TimeOrdering.empty`. Remedy 2 is a genuine
weakening of `RuleSound` and needs approval as such. **It is NOT the schedule-reachability
weakening that was measured and closed**: it does not restrict which branches the engine builds
and is not tailored to exclude a counterexample; it is a well-formedness condition on the
`(branch, ordering)` pair, discharged by construction. The distinction is real; the choice is the
user's.

*Carried forward for 7.3, from task 418's own measurement and unrepaired there.* Post-fix,
`buildTableau ((G p) → □(G p)) 1000 .Base` returns **fuel-exhausted `(0,0)`**, not `.hasOpen`, and
`decide` returns `.fuelExhausted`, not `.invalid` with a countermodel. The wrong-verdict defect is
gone (`fuelExhausted` is honest ignorance where `extractionFailed` asserted validity), but the
countermodel 7.3 needs is still owed, and each such search now costs ≈860 s.

**PHASE 7 STATUS (2026-07-28t) — still PARTIAL after a fifteenth dispatch. 7.2 is at 16 of 28
rules sorry-free, and the `RuleSound`-weakening fork is SETTLED — by refuting the premise both
of its branches shared. 7.2 is now BLOCKED on an engine defect, recorded below.**
`lake build FormalSystem.Metalogic.Decidability.Verified.Decidable` green (exit 0, 1350 jobs);
`lake env lean` green on the module and on both probes, every pinned row matching; sorry census
over `Verified/` reports `0`. Three green commits, each verified by `git show --stat` for
**content** (+236/-14, then +58, then +69). 7.1a–7.1e remain closed; no engine file was touched.

*The fork was settled by measuring its shared premise, and the premise is false.* The instruction
was to price a branch hypothesis "excluding what the schedule never builds", the candidate being
that `T(G p)` is an `imp` whose propositional decomposition is scheduled ahead of `boxNeg`. Before
pricing it, that claim was turned into a prediction and checked — the eleventh-dispatch discipline
— and it does not survive:

- `allRules` schedules `boxNeg` **ahead of** `impPos`, `andNeg` and `orPos`. Only the
  non-branching propositional rules precede it.
- Expansion is **additive**: `expandOnceUnblocked` reads `.linear fs` as `fs ++ b`, so decomposing
  `T(G p)` never removes it, and `tempGProps` filters the branch by *shape*, indifferent to
  whether a formula has been expanded. The source outlives its own decomposition.
- Driven from `b0` by the engine's **own selector**, `boxNeg` fires and the clash appears.
  `Tests/BimodalTest/BoxNegReachabilityProbe.lean` pins it, together with the closure reason:
  `contradiction` at the minted world, not a negated axiom.

So the refuting branch is exactly a branch the engine builds. **No branch invariant can separate
them, and the `RuleSound`-weakening fork is therefore closed rather than open** — there is nothing
to price, because a hypothesis that admits what the engine builds also admits the counterexample.

*A pinned row was being misread, and this is the larger finding.* The 2026-07-28s banner and
`BoxNegPreservationProbe.lean` both rested on `isValid ((G p) → □(G p)) = false`, read as the
correct verdict on an invalid formula and used to conclude that **no engine defect was in
evidence**. Measured: `buildTableau ((G p) → □(G p)) 1000 .Base` returns **`allClosed`**, and
`decide` returns **`extractionFailed`** — `isInvalid` is `false`, `getCountermodel?` is `none`.
`isValid`'s `false` conflates "judged invalid" with "claimed valid, then could not build the proof
term", and only the second happened. The tableau closes an invalid formula. `(G p) → □(G p)` is
invalid on the project's own semantics: `TruthAt … (box φ)` is `∀ σ ∈ Ω, TruthAt … σ t φ`, fixing
the time and ranging over histories, while `G p` is evaluated along `τ` alone.

*The defect, stated to the four-element bar.* **Counterexample**: `(G p) → □(G p)`, invalid.
**Current behaviour**: `buildTableau` returns `.allClosed` with one closed branch; `decide`
returns `.extractionFailed`; no countermodel. **Required behaviour**: `.hasOpen`, hence
`.invalid` with a countermodel. **Isolation**: `boxNeg`'s group-3 blocks (`tempGProps`,
`tempHProps`, `tempFNegProps`, `tempPNegProps`, `tempUNegProps`, `tempSNegProps`,
`Tableau.lean:555-574`) copy temporal formulas across worlds; `diamondPos` carries the identical
block at `:599-619`. Groups 1 and 2 (the witness, and the `T(□B)`/`F(◇B)` propagation) are sound
and are not implicated.

*What was deliberately NOT done.* The engine fix — deleting the six group-3 blocks — was not
attempted. It edits `applyRule` itself, which is a plan deviation on a `.lean` file and so must be
escalated rather than substituted; and removing the blocks can only make branches *harder* to
close, so it risks the opposite failure on the conformance corpus and needs the corpus as its
acceptance gate rather than a end-of-dispatch improvisation in a shared clone.

*What landed instead.* `ruleSound_orderTrichotomy`, the one remaining rule that is self-contained
— no fresh label, no `boxDiamondPersistence`, and untouched by the defect. Its content is split
into `truthAt_and` and `exists_trichotomy_disjunct`, the latter stating the whole of the rule's
mathematics over three points of `D`: two times interpreted above a common point, each carrying a
formula in one history, satisfy one of `F(φ∧ψ)`, `F(φ∧Fψ)`, `F(Fφ∧ψ)` there. The times may be
incomparable in the *recorded* ordering, but `tv` lands them in a `LinearOrder`, and
`lt_trichotomy` decides. The plumbing — `List.find?` back through `flatMap`/`filterMap` to two
order edges and two branch formulas — is kept out of the lemma and consumed by the rule's proof.

#### Additions to the Phase 7 DO-NOT-RE-ATTEMPT register (2026-07-28t)

- **Weakening `RuleSound` by a schedule-reachability hypothesis, or by any branch invariant
  meant to exclude the `boxNeg` counterexample.** Measured: the engine builds that branch. The
  2026-07-28s entry describing this as the next measurable fork is **superseded** — it was
  measured, and it is closed, not open.
- **Re-deriving the reachability measurement** — that `boxNeg` precedes `impPos` in `allRules`,
  that expansion is additive, that the clash arises from `b0` under the engine's own selector, or
  that the closure reason is `contradiction` at the minted world. All `#guard_msgs`-pinned in
  `Tests/BimodalTest/BoxNegReachabilityProbe.lean`.
- **Reading `isValid φ = false` as "the engine judged `φ` invalid."** It is also what
  `extractionFailed` reports. Discriminate with `isInvalid` / `getCountermodel?`, never with
  `isValid` alone. The 2026-07-28s claim that "no engine defect is claimed, and row 5 pins why"
  is **withdrawn**; the row's value is right and its reading was wrong.
- **Re-proving `ruleSound_orderTrichotomy`, `exists_trichotomy_disjunct` or `truthAt_and`.**
- **Attempting the group-3 engine fix without the conformance corpus as its acceptance gate.**
  Removing the blocks only makes branches harder to close, so the risk it carries is
  under-closing, which only the corpus detects.
- Plus every prior entry, all carried forward unchanged.


**PHASE 7 STATUS (2026-07-28s) — still PARTIAL after a fourteenth dispatch. 7.2 is at 15 of 28
rules sorry-free, and the sub-phase's own target statement has been measured FALSE.**
`lake build FormalSystem.Metalogic.Decidability.Verified.Decidable` green (exit 0, zero errors);
`lake env lean` green on the module and on the new probe, all five pinned rows matching; sorry
census over `Verified/` reports `0`. Two green code commits, each verified by `git show --stat`
for **content** (+288, then +159/-11). 7.1a–7.1e remain closed; no file under `Verified/Bridge/`
was touched; no engine file was touched. 7.3 not started.

*The `ordResp` fork, settled by measurement rather than by preference.* The previous dispatch
stopped at this fork and refused to guess. It resolves to **route (a)**: `SatState.ordResp` stays
on `ord.constraints`, and the transitive closure the four temporal universal rules consume is
bridged once, on the consumer side. The measurement is the producers' side of the ledger. Every
fresh-time rule — `allFutureNeg` (`Tableau.lean:652`), `allPastNeg` (`:692`), `someFuturePos`
(`:723`), `somePastPos`, and the `untl`/`snce` fresh-time arms — returns
`timeOrd.addFuture l.time branch.nextTime`, a new edge consed onto the list. Under the
strengthened field each would owe the closure property for the *extended* ordering, which needs a
path-factorisation lemma over `(t, tNew) :: cs` that is **not in the tree**, re-applied at six
sites. Under the field as it stands each owes only `∀ p ∈ (t, tNew) :: cs, tv p.1 < tv p.2` — head
from the witness, tail from the state handed in. Six harder obligations against four consumers
sharing one lemma: the closure reasoning belongs to the consumers. Nothing speculative was written
into the definition, and the field is unchanged.

*What landed.* The bridge — `mem_constraints_of_mem_directFutureOf`, its past dual,
`lt_of_pathN_directFutureOf`/`lt_of_pathN_directPastOf` (the `n + 1` in those statements is what
carries strictness), and `SatState.lt_of_mem_futureOf`/`gt_of_mem_pastOf` via `bfsClosure_sound`,
the route `Bridge/TemporalSaturation.lean`'s `orderDual_converse` already walks. Then the four
temporal universal rules as one shape family: `allFuturePos`, `allPastPos`, `someFutureNeg`,
`somePastNeg`. The import edge into `Verified/Termination/Fuel.lean` was weighed explicitly and is
intra-`Verified/` — Fuel imports only `TimeTypeBound` and `Saturation`, both already in the
decidability build, so it adds no cross-tree edge, unlike the `Metalogic.Soundness` edge the
previous dispatch declined.

*A Lean fact worth recording, because it changes proof shape.* `Formula.allFuture` and
`Formula.allPast` are **definitions, not constructors** — `G A` unfolds to an `imp`. So `cases φ`
cannot separate `G A` from a general implication, and the two positive rules cannot be driven the
way `boxPos` is driven by the genuine `.box` constructor. They are driven by `split` on
`applyRule`'s own matcher, which decides exactly the distinction the engine decides. Four
point-form truth lemmas (`truthAt_of_allFuture`, `truthAt_of_allPast`,
`not_truthAt_of_someFuture`, `not_truthAt_of_somePast`) keep the arms free of any dependence on
how `split` names what it binds — unification folds the unfolded hypothesis back without the proof
ever naming the matrix.

*PROBE BEFORE PROVING, FOR THE ELEVENTH CONSECUTIVE DISPATCH — AND THIS TIME IT OVERTURNED A
STANDING CONCLUSION.* The 2026-07-28r banner recorded that the `boxNeg`/`diamondPos` group-3 copy
was suspected unsound, that three shapes chosen to expose it as a wrong verdict all reported
correctly, and — correctly and explicitly — that this measured verdicts and not steps. Reading the
`boxNeg` arm this dispatch produced a prediction: on verdict-row B, `(G p) → □(G p)`, the fresh
world receives the witness `F(G p)` *and* the group-3 copy `T(G p)`, so the successor should close
and the verdict should read `true`. The pinned row says `false`. A prediction contradicting a
pinned measurement is a fact to be measured, not reasoned around, so it was measured:
`Tests/BimodalTest/BoxNegPreservationProbe.lean` applies `applyRule .boxNeg` to that branch
directly. **It emits exactly two formulas, both at the minted label, being the same formula with
opposite signs.** Consequences, all pinned:

- The branch `T(G p) @ (w₀,t₀)`, `F(□(G p)) @ (w₀,t₀)` is **satisfiable** — precisely because
  `(G p) → □(G p)` is invalid, which is what verdict-row B's `false` records — and its `boxNeg`
  successor is **unsatisfiable**, since `SatAt` reads the emitted pair as `TruthAt …` and
  `¬ TruthAt …` at one point, for every `hist` and `tv`.
- So **`RuleSound carrierBase .boxNeg` is FALSE.** `ruleSound_boxNeg` is not unproved but
  unprovable, and `diamondPos` carries an identical `tempGProps` block.
- So **the assembly `∀ r ∈ allRulesForFC fc, RuleSound _ r` cannot be proved as stated**, since
  both rules are members at every frame class. This is the sub-phase's own target statement, and
  it is the reason this finding outranks the four rules landed beside it.
- **No engine defect is claimed, and row 5 pins why**: the verdict on the same formula is still
  `false`. The engine never applies `boxNeg` to that branch — `T(G p)` is itself an `imp`, so the
  propositional schedule reaches it first — which is also *why* the three verdict rows came back
  clean: they do not exercise the copy in the engine's own run. The prior dispatch's conclusion was
  not wrong about what it measured; it was measuring the wrong thing for this obligation, and said
  so at the time.

*The fork this opens, deliberately left unguessed.* `RuleSound` must be weakened for these two
rules by a hypothesis excluding branches the engine never builds — schedule reachability is the
obvious candidate, being exactly what makes the counterexample unreachable — and the assembly must
then thread that hypothesis through the tableau induction. Which invariant is strong enough for
these two and cheap enough for the other twenty-six is the next **measurable** question. Nothing
was written into `RuleSound` on spec; the same discipline that kept `carrierDense` undeclared and
kept `ordResp` unstrengthened applies here.

*Environment.* A shared clone with three other live sessions. `Tableau.olean` and
`SubformulaProperty.olean` were deleted out from under two builds mid-dispatch and three `lean`
processes were observed compiling one module concurrently; this cost most of the dispatch's wall
clock and none of its content. Nothing under `WeakCanonical/DenseModelSurgery/**`, `specs/408_*/**`,
`specs/414_*/**` or `specs/415_*/**` was touched, staged, committed or reverted. Staging was by
explicit path throughout and `git show --stat` after each commit matched the intended diff size.
`mcp__lean-lsp__lean_run_code` was found to report `success` on code that does not compile
(`example : (1:Nat) = 2 := by rfl` returns clean) and was discarded as a probe channel mid-dispatch;
every result reported here is from `lake build`/`lake env lean`.

#### Additions to the Phase 7 DO-NOT-RE-ATTEMPT register (2026-07-28s)

- **Re-deriving the ordering bridge** — `mem_constraints_of_mem_directFutureOf`,
  `mem_constraints_of_mem_directPastOf`, `lt_of_pathN_directFutureOf`, `lt_of_pathN_directPastOf`,
  `SatState.lt_of_mem_futureOf`, `SatState.gt_of_mem_pastOf`. All landed sorry-free and all four
  temporal universal rules consume them.
- **Re-opening the `ordResp` fork**, or strengthening `ordResp` to `strictBefore`/the closure.
  Measured and settled above; the producers' side is strictly the more expensive one.
- **Re-proving `ruleSound_allFuturePos`, `ruleSound_allPastPos`, `ruleSound_someFutureNeg`,
  `ruleSound_somePastNeg`**, or the helpers `truthAt_of_allFuture`, `truthAt_of_allPast`,
  `not_truthAt_of_someFuture`, `not_truthAt_of_somePast`, `asSomeFuture?_eq_some`,
  `asSomePast?_eq_some`.
- **Driving `allFuturePos`/`allPastPos` by `cases φ`.** `Formula.allFuture`/`allPast` are
  definitions, not constructors; `cases` cannot separate them from a general `imp`. Use `split` on
  `applyRule`'s matcher.
- **Attempting to prove `RuleSound carrierBase .boxNeg` or `.diamondPos` as currently stated.**
  Measured false, in tree, `#guard_msgs`-pinned in `Tests/BimodalTest/BoxNegPreservationProbe.lean`.
  Re-running those five rows is also on this register.
- **Attempting the assembly `∀ r ∈ allRulesForFC fc, RuleSound _ r` in its present shape.** It
  entails the two statements above and is therefore false. The 2026-07-28r entry treating the
  single induction over `mem_allRulesForFC_iff` as the unchanged assembly is **superseded**: the
  induction principle is fine, the predicate it ranges over is not.
- **Claiming, on the strength of the above, that the engine decides wrongly.** It does not; the
  verdict row is pinned beside the others. The failure is in the rule-level statement's
  quantification over arbitrary branches.
- **Using `mcp__lean-lsp__lean_run_code` as a verification channel in this project.** It reports
  `success: true` with empty diagnostics for code that does not compile.
- Plus every prior entry, all carried forward unchanged.


**PHASE 7 STATUS (2026-07-28r) — still PARTIAL after a thirteenth dispatch. 7.2 is STARTED, not
closed: `Verified/Decidable.lean` exists, is registered, and carries 11 of the 28 rules
sorry-free.** `lake build FormalSystem.Metalogic.Decidability` green (1117 jobs); **full
`lake build` green (1941 jobs)**, up from 1939 by exactly the new module and the new probe;
`lake build BimodalTest` green (1987 jobs); sorry census over `Verified/` reports `0`; zero
vacuous definitions, zero axioms. Two green code commits, each verified by `git show --stat` for
**content**. 7.1a–7.1e remain closed and no file under `Verified/Bridge/` was touched. 7.3 not
started.

*The three definitions the sub-phase turns on, and why each is shaped as it is.*

1. **`SatState`** — a model `M`, a shift-closed `Ω`, an interpretation `hist` of the branch's
   world labels landing **inside `Ω`**, and an interpretation `tv` of its time labels
   **respecting the abstract `TimeOrdering`**. Four fields, all load-bearing. `histMem` is what
   makes `□` (which quantifies over `Ω`) say anything about the branch's own other worlds.
   `shiftClosed` was added mid-dispatch, not designed in: `boxTemporal` is unsound without it,
   and that only became visible when the rule was attempted.
2. **`SatResult`** — stated against `applyRule`'s actual return type, `RuleResult × TimeOrdering`,
   rather than against a hand-summarised "successor branch". This matters: the ordering a
   fresh-time rule returns is then part of the obligation rather than an afterthought, and
   `.branching` is the only constructor carrying a disjunction, which is exactly why closing
   *all* arms is what a closed tableau needs. Each successor may re-choose `hist`/`tv` (the
   fresh-label rules need that) but never `M` or `Ω` (no rule needs that).
3. **`RuleSound C r`**, indexed by a `CarrierProp`. Only `carrierBase` is declared. The dense,
   discrete and Dedekind carrier properties are deliberately **absent** — each is to be stated in
   the same step that proves a rule consuming it. `RuleSound.mono` is what makes deferring them
   safe, so the base family never needs restating at a higher class.

*What landed, by shape family.* The eight truth-functional rules (`andPos`, `andNeg`, `orPos`,
`orNeg`, `impPos`, `impNeg`, `negPos`, `negNeg`) — same three moves each, and the only classical
steps are the genuine ones. Then the three **label-preserving** modal rules: `boxPos` and
`diamondNeg` from `histMem` alone, and `boxTemporal` from shift-closure via two new point-form
lemmas, `truthAt_allFuture_of_box` and `truthAt_allPast_of_box`.

*A reuse decision, made explicitly rather than by default.*
`Metalogic.Soundness.modal_future_valid` already states `□A → □(GA)`, exactly the future half of
what `boxTemporal` needs, and grepping for it first was right. It was **not** imported: the edge
would pull the whole soundness tree into the decidability tree's build for half of one rule, and
the past dual does not exist there at all. Both halves are derived instead from the primitive
`modal_future_valid` itself uses, `TimeShift.time_shift_preserves_truth`, in eight lines. This is
deriving from the primitive, not re-deriving the lemma.

*Probe before proving changed the conclusion again — for the tenth consecutive dispatch, and
this time by refuting the dispatch's own suspicion.* `boxNeg` and `diamondPos` mint a fresh world
and copy three groups of formulas to it. Groups 1 and 2 (the witness; the `T(□B)`/`F(◇B)`
propagation) are the argument `boxPos`/`diamondNeg` already make plus a one-point `hist` update
at an index absent from the branch. Group 3 — every `T(GB)`, `T(HB)`, `F(FB)`, `F(PB)`,
`F(U(B,C))`, `F(S(B,C))` at the source *time*, from **any** world, copied to the fresh world —
has no evident justification: `G` is evaluated inside a single history, and the witness history
is chosen for the witness condition alone. The natural next move was to write that up as an
engine defect. It was measured first instead
(`Tests/BimodalTest/CrossWorldPropagationProbe.lean`): the three invalid shapes that would expose
an unsound group-3 copy as a **wrong verdict** — `(¬F p) → □(¬F p)`, `(G p) → □(G p)`,
`(¬P p) → □(¬P p)` — all report `false`, the correct answer, beside a `true` control and a
`false` control. **No defect is claimed**: there is no counterexample, and under the defect bar a
suspicion without one is not a finding. What the probe does *not* settle is the proof obligation,
and the two come apart — a step can spoil a satisfiable branch while every branch it spoils is
closable another way. Both rules are therefore left **open with the obligation stated**, never
papered over with a sorry.

*The fork that stopped this dispatch, named rather than guessed at.* The four temporal
**universal** rules (`allFuturePos`, `allPastPos`, `someFutureNeg`, `somePastNeg`) propagate
along `timeOrd.futureOf`/`pastOf`, the transitive closure. Consuming that needs
`t' ∈ futureOf ord t → tv t < tv t'`, which `SatState.ordResp` (stated on raw constraints) does
not give directly; the path is `TimeOrdering.bfsClosure_sound` and `PathN` in
`Verified/Termination/Fuel.lean`. The alternative is to **strengthen `ordResp` to `strictBefore`**,
which makes these four rules immediate and pushes the same BFS reasoning into the fresh-time
rules that must re-establish it. Which is right is a measurable question — the producers are the
fresh-time rules and the consumers are these four — and it was not settled by guess at the end of
a dispatch. Nothing speculative was written into the definition.

*Environment.* Both concurrent sessions were quiet. Nothing under
`WeakCanonical/DenseModelSurgery/**`, `specs/408_*/**`, `specs/414_*/**` or `specs/415_*/**` was
touched, staged, committed or reverted — a task-408 untracked scratch file appeared during the
dispatch and was correctly left unstaged. Staging was by explicit path throughout, and
`git show --stat` after every commit matched the intended diff size.

#### Additions to the Phase 7 DO-NOT-RE-ATTEMPT register (2026-07-28r)

- **Re-deriving `SatAt`, `SatState`, `SatResult`, `CarrierProp`, `carrierBase`, `RuleSound`,
  `RuleSound.mono`, `SatState.mono`, `SatState.append`, or the three `satResult_*` discharge
  lemmas.** All landed sorry-free and all are consumed.
- **Re-proving any of the eleven landed rules**: `ruleSound_andPos`, `ruleSound_andNeg`,
  `ruleSound_orPos`, `ruleSound_orNeg`, `ruleSound_impPos`, `ruleSound_impNeg`,
  `ruleSound_negPos`, `ruleSound_negNeg`, `ruleSound_boxPos`, `ruleSound_diamondNeg`,
  `ruleSound_boxTemporal` — nor the inversion lemmas `asAnd?_eq_some`, `asOr?_eq_some`,
  `asNeg?_eq_some`, `asDiamond?_eq_some`, nor `truthAt_allFuture_of_box` /
  `truthAt_allPast_of_box`.
- **Importing `FormalSystem.Metalogic.Soundness` into the decidability tree to get
  `modal_future_valid`.** Considered and rejected with reasons; the two point-form lemmas above
  are derived from `time_shift_preserves_truth` instead, and there is no past dual in the
  soundness tree to import anyway.
- **Claiming the fresh-world cross-modal-temporal copy (`boxNeg`/`diamondPos` group 3) is an
  engine defect.** Measured on three shapes chosen to expose it as a wrong verdict; all three
  report the correct `false`. Re-running those three rows is also on this register — they are
  `#guard_msgs`-pinned in `Tests/BimodalTest/CrossWorldPropagationProbe.lean`. The *proof*
  obligation remains open and is not on this register.
- **Omitting `shiftClosed` from `SatState`, or adding it back as a separate `RuleSound`
  hypothesis.** It is a property of `Ω`, every validity notion imposes it, and `boxTemporal`
  consumes it.
- **Declaring `carrierDense`/`carrierDiscrete`/`carrierDedekind` before a rule consumes one.**
  An unconsumed carrier property is unvalidatable dead weight, the same objection that governs
  gate rows; `RuleSound.mono` is what makes deferring them free.
- Plus every prior entry, all carried forward unchanged.


**PHASE 7 STATUS (2026-07-28l) — still PARTIAL after a seventh dispatch. 7.1c's induction is
started, four of its six cases are sorry-free, and the two headline results are in tree complete
modulo the other two.** `lake build FormalSystem.Metalogic.Decidability` green (1113 jobs);
`lake env lean` green on the new module; sorry census over `Verified/` reports `2`, both of them
the tracked temporal cases named below. 7.1d, 7.1e, 7.2 and 7.3 are still not started. No engine
file was touched.

*What landed.* One new module, `Verified/Bridge/IntTruth.lean`, registered in
`Decidability.lean`, and one new probe, `Tests/BimodalTest/RayRegionProbe.lean`, registered in
`Tests/BimodalTest.lean`:

- `stateLabel` — the label a carrier point reads: its own branch time at a placed point, its
  region's chosen label elsewhere. With it, `Bridge/Valuation.lean`'s placed readback and
  `Bridge/RegionLabel.lean`'s gap readback become **one** statement, `truthAt_atom_state`, and it
  is an `iff`.
- `BranchTruthAt` — the induction predicate, **signed** and one-directional in each sign
  (`T(φ)@stateLabel → φ true`, `F(φ)@stateLabel → φ false`), which is the strength a saturated
  branch actually has.
- `branchTruthAt_atom`, `branchTruthAt_bot`, `branchTruthAt_imp`, **`branchTruthAt_box`** — all
  sorry-free, and all proved **generic in the carrier `D` and the placement `f`**, so 7.1d
  inherits them verbatim. The `box` case was written first, per the 2026-07-28i lesson, and it
  closes exactly as the region-labelling decision predicted: `sat_box_grid_of_check` at placed
  points, `regionLabel_box` at gap points, so the induction hypothesis always lands at a *label*
  and never at a gap valuation.
- `OrderFaithful` and `RayOnly` — the two properties the temporal cases need of a placement,
  both stated **without** a `LinearOrder` instance on `BranchTime b`, both discharged at ℤ
  (`orderFaithful_intPlace`, `rayOnly_intPlace`) from `Bridge/IntGaps.lean`.
- `intPlace` — `finiteOrderEmbInt (BranchTime b)` instantiated **directly**, never through
  `exists_monotone_placement`.
- `not_valid_of_hasOpen_int` and `not_validDiscrete_of_hasOpen_int` — the two headline results,
  assembled and type-correct, complete modulo `branchTruthAt_untl`/`branchTruthAt_snce`.

*Correction 10 — the carrier has worlds the branch never mentioned, and the `box` case dies
unless the model normalises them.* `regionOmega f` is `Set.range fun p : WorldIndex × D => …` —
the range over **all** of `WorldIndex`, which is `Nat` — and `truthAt_box_iff_base` quantifies
over exactly that range. At an unmentioned world `branchPlacedVal b w i p` is `false` for every
atom, so one such world falsifies `□p` on a branch carrying `T(□p)`. The repair is `normWorld`:
every carrier world is read as a world the branch knows, and `normModel` composes that onto
`regionModel`'s two valuation arguments. No signature moves — `branchModel`'s `gapVal` type is
untouched and `branchRegionVal` is consumed exactly as 7.1b states it.

*Correction 11 — the "ℤ is the easy milestone" premise holds only for the INTERIOR, and this is
where 7.1c actually stops.* Contiguity does empty the interior gaps (`ray_of_gap_finiteOrderEmbInt`,
unchanged). What it does not buy is the other half of the dense route: region invariance
(`interpInvariantAt`, `Bridge/TruthLemma.lean`) requires `DenselyOrdered D`, and
`not_exists_gt_sameRegion_int` (`Bridge/Interpolate.lean`) is the in-tree machine witness that its
`exists_gt_sameRegion` step fails at ℤ. So at ℤ the two rays are **infinite** regions whose points
must be reasoned about one at a time, while at ℚ/ℝ one invariance lemma handles each region
wholesale. The `untl`/`snce` cases are consequently *harder* on the rays at ℤ than at ℚ/ℝ, which
inverts the sub-phase ordering's stated rationale for those two cases (it remains correct for the
interior, and hence for everything the four landed cases do).

*Probed before proving, and the hypothesis was refuted.* The obstruction Correction 11 exposes
suggested a specific defect: the gate imports each region's demands from labels on the *other*
side of it and asks nothing about what a region's chosen label demands **of the region itself** —
and an upper-ray point has no witness above it outside its own ray, so `T(U(φ,ψ))` at the ray's
label needs `T(φ)` at that same label. `Tests/BimodalTest/RayRegionProbe.lean` measured this
before anything was stated in `Verified/`. **The hypothesis is refuted on every engine row**:
`rayUp` and `rayDn` are `true` on all six rows measured (`F p → p`, `P p → p`, `G p → p`,
`(□p ∧ ◇q) → r`, `(□p ∧ □(p→q)) → r`, and `F p → p` at `.Dense`), alongside `check=true`. The ray
self-demand is therefore a **candidate additional gate row**, in the same decidable family, not a
refutation of `regionLabelCheck`; row G pins a synthetic branch with `check=true rayUp=false`, so
it is not vacuous. This is the fourth consecutive dispatch in which probing first changed the
conclusion.

*What remains in 7.1c — two lemmas, four items.* Enumerated in `IntTruth.lean`'s
"The temporal cases — OWED" section and repeated here because they are the whole residual:

1. **`sat_untl_pos` discards the ordering.** It concludes `∃ t' ∈ b.knownTimes, …` with no
   relation between `t'` and the until's own time. The ordering is present in the existing proof
   and thrown away — `witnessPresent` scans `timeOrd.futureOf t` and the proof binds that
   membership to `_`. A strengthened `sat_untl_pos_future` keeping `strictBefore ord t t' = true`
   is a re-run of the existing proof, not a new argument. `sat_snce_pos` is the mirror.
2. **The witness must be the earliest one**, because `TruthAt … (untl φ ψ)` demands the guard at
   every point strictly between. The saturation fact's second disjunct is an iteration step;
   `b.knownTimes.length - branchRank b ord t'` is the decreasing measure, and `branchRank` already
   exists in `Bridge/RegionLabel.lean`.
3. **The ray self-demand** — measured `true` on the corpus as above, to be added as a gate row.
4. **Region invariance is unavailable at ℤ** — Correction 11; the rays are handled point by point.

None of the four touches an engine file, the region labelling, or any interface already landed.

#### Phase 7 DO-NOT-RE-ATTEMPT register (consolidated; all prior entries carried forward verbatim)

*From 2026-07-28e:*
- `Ω := Set.univ` — the empty history falsifies every `□`.
- A universal `TaskRel` — `nullity_identity` is an iff and forbids it.
- Discharging `∀ τ ∈ Ω, RegionConstant f τ` by building the history through `regionExtend`, or by
  any other means — refuted and machine-witnessed.
- Copying a gap region's valuation from an adjacent placed point — the refuted half-open partition
  wearing a different hat.

*From 2026-07-28f:*
- Defining the gap valuation by copying an adjacent placed point, in *either* direction — both
  halves machine-refuted (`not_leftCopy_gapAdequate`, `not_rightCopy_gapAdequate`).
- Trying to obtain cross-world *and* cross-time `T(□φ)` propagation from `findUnexpanded = none`.
- Adding the O3 lemmas to `CountermodelExtraction.lean` — they live in `Bridge/BoxSaturation.lean`.

*From 2026-07-28g:*
- `BoxContextClosed` as a construction invariant — refuted on two independent counts.
- `GapDemands` as the gap obligation — machine-proved vacuous (`gapDemands_trivial`).
- Folding the `U`/`S` straddling guards into the gap *policy* — they are compound-formula
  obligations of the induction, not degrees of freedom of `gapVal`.

*From 2026-07-28h:*
- `TimeOrderConverse` as an open obligation — already proved as `orderDual_holds`.
- `BoxTemporalSpread` as a construction invariant *or* as a saturated-branch fact — machine-refuted
  on `(□p ∧ ◇q) → r`; use `BoxAnchored`.
- A construction induction for the box invariant as a *prerequisite* for the truth lemma —
  `boxAnchoredCheck` discharges it the way `timeOrderTotal` already is.

*From 2026-07-28i:*
- The truth-lemma induction against `GapAdequate`, with `branchGapVal` or any other policy —
  machine-refuted by `gapAdequate_insufficient`. The `box` case is where it fails, so an induction
  that leaves `box` for last will look healthy until the last case and then be unclosable.
- Any *atom-wise gap policy read off the branch's `T(G ·)`/`T(H ·)`/`T(□ ·)` facts* — the closure
  argument rules out the whole family. **Scope note (2026-07-28j)**: the ban is on policies read off
  the region's *forced set*; a policy reading a *chosen known label's* atoms is outside it, because a
  label's content is propositionally closed by `sat_imp_pos` while a forced set is not.
- The union of the two copy policies ("left-or-right") as a rehabilitation of either.
- Re-deriving `sat_imp_pos` inside the induction, or adding it to `CountermodelExtraction.lean`.

*Added by this decision (2026-07-28j):*
- **Branch labels → MCSs via `set_lindenbaum`**, in any form, as a route to the truth lemma — the
  consistency hypothesis is inter-derivable with the goal. Bans the whole family, not just the
  four-step version adjudicated in report 07.
- **Seeding Chronicle from the branch** (a finite `Chronicle`, an `omegaChainFrom`, a finite
  prescribed-order family of MCSs) — same refutation; the seed must be MCS-valued.
- **Treating `forward_F`/`RestrictedTemporallyCoherent` as an obligation to discharge** — it is
  passed as `_h_rtc` and unused. Budgeting for it is budgeting for nothing; the obligations are
  `h_buc`/`h_fuc`.
- **Applying `parametric_shifted_truth_lemma` or `restricted_parametric_shifted_truth_lemma` to a
  branch model** — both hardwire `ParametricCanonicalTaskModel`, whose world states are MCS
  subtypes. Reuse the *shape*, never the theorem.
- **Treating all four `Decidable` instances as one milestone** — ℤ placements are contiguous and
  have empty interior gaps; ℚ/ℝ placements do not.

*Added by this dispatch (2026-07-28l):*
- **Building the countermodel over `WorldIndex` without normalising the worlds the branch never
  mentions.** `regionOmega` is a range over *all* of `WorldIndex` and `truthAt_box_iff_base`
  quantifies over it, so one unmentioned world falsifies `□p` on a branch carrying `T(□p)` and
  the `box` case is unclosable. Use `normWorld`/`normModel` (`Bridge/IntTruth.lean`).
- **Writing bare `i < j` or `i ≤ j` for `BranchTime b` and expecting the branch order.**
  `BranchTime b` is an `abbrev` for `Fin n`, so `Fin`'s own order instances win and a `letI` of
  `BranchOrder b ord hV` does **not** displace them. Write `(BranchOrder b ord hV).lt/.le`
  explicitly. Separately, the `LE` instance `finiteOrderEmbInt` carries reaches `LinearOrder`
  through `DistribLattice` while `Monotone`/`StrictMono` reach it through `Preorder`; the paths
  are defeq but not syntactically equal, so unification against a metavariable fails. Route
  monotonicity through `RelEmbedding.map_rel_iff`, which has no instance arguments at all
  (`le_intPlace_of_branchLE`). Three separate elaboration failures came out of this one trap.
- **Assuming ℤ is uniformly easier than ℚ/ℝ.** Correction 11: contiguity empties the *interior*
  only. The two rays are infinite regions and region invariance — which handles a whole region at
  once at ℚ/ℝ — needs `DenselyOrdered` and is machine-refuted at ℤ by
  `not_exists_gt_sameRegion_int`.
- **Using `sat_untl_pos`/`sat_snce_pos` as they stand for the `untl`/`snce` positive case.** They
  discard the witness's position in the time order, which the case cannot do without. Strengthen
  them (the ordering is already in their proofs, bound to `_`) rather than working around them.
- **Treating the ray self-demand as a refutation of `regionLabelCheck`.** Measured `true` on all
  six engine rows (`Tests/BimodalTest/RayRegionProbe.lean`); it is a candidate additional gate
  row, not a reason to restate the region labelling for a fourth time.


**PHASE 7 STATUS (2026-07-28m) — still PARTIAL after an eighth dispatch. Two of 7.1c's four
enumerated items are LANDED sorry-free; the two temporal cases are still owed, on a residual that
is now considerably smaller and fully enumerated.** `lake build
FormalSystem.Metalogic.Decidability` green (1115 jobs); sorry census over `Verified/` reports `2`,
the same two tracked temporal cases and no new ones. Four green commits. No engine file touched.

*What landed.* Two new `Verified/Bridge/` modules, both registered in `Decidability.lean`, and one
new probe registered in `Tests/BimodalTest.lean`:

- **`Bridge/TemporalSaturation.lean`** — item 1, done. `sat_untl_pos_future` and
  `sat_snce_pos_past`: the existing `sat_untl_pos`/`sat_snce_pos` proofs with the
  `futureOf`/`pastOf` membership *kept* rather than bound to `_`, reported as `strictBefore`.
  Also `orderDual_converse`, the `pastOf → futureOf` direction of the closure duality, which the
  `snce` mirror needs and `Fuel.lean`'s `orderDual_holds` does not supply — same three steps
  (backward BFS soundness, `PathN.reverse`, forward BFS completeness at the same fuel).
- **`Bridge/TemporalGate.lean`** — item 3, done and enlarged. `temporalWitnessCheck`, a fourth
  decidable branch gate in the family `timeOrderTotal`/`boxAnchoredCheck`/`regionLabelCheck`
  belongs to, carrying four rows — `untlNegFuture`, `snceNegPast`, `untlRaySelf`, `snceRaySelf` —
  with four consumption lemmas, every one branch-fact-in and branch-fact-out.
- **`Tests/BimodalTest/TemporalWitnessProbe.lean`** — twelve rows, twelve conditions each, all
  `#guard_msgs`-pinned.

*Probed before proving, for the fifth consecutive dispatch, and it changed the conclusion three
times.* The probe corpus had to be **extended** first, and that is the finding that made the rest
possible: **not one of the six rows `RayRegionProbe.lean` measures contains a genuine until.**
Every until in `F p → p`, `P p → p`, `G p → p` and the three modal shapes is guard-`⊤`, where the
acting rules are the *linear* `someFuturePos`/`someFutureNeg`; the branching `untlPos`/`untlNeg`
arms — the ones whose second arm is `T(guard) ∧ T(U)` resp. `F(guard) ∧ F(U)` — never fire. Four
rows carrying genuine untils and sinces were added. Then:

1. **The obvious guard row is refuted, and the reason governs the whole design.** "Every known
   time after the until carries `T(φ)` or `T(ψ)`" is `false` on nine of twelve rows — *including
   rows with no genuine until in them*. The cause has nothing to do with untils: the guard of a
   `someFuture` is `⊤`, and **the engine never writes `T(⊤)` on a branch**, because `⊤` is true
   everywhere without any branch fact saying so. Any row asking the branch to *assert* a guard
   fails on the entire `someFuture`/`somePast` fragment. The `ψ = ⊤` case must be split off and
   discharged semantically — the split `sat_untl_pos` itself makes.
2. **A second candidate is refuted.** "Every region label of a world denies the event of every
   negative until in that world" is `false` on two gate-*accepted* rows. It overreaches:
   `untlNegSubjects`'s "asserted strictly below region `j`" side condition is correct, since a
   region below the until's own time holds no point above the evaluation point.
3. **`untlNegFuture` is much stronger than expected and holds everywhere.** `F(U(φ,ψ))` at `(w,t)`
   denies `φ` at *every* known time after `t`, on all twelve rows including the four the region
   gate rejects. That settles the negative case at placed points outright — no minimal-witness
   argument, no reasoning about the guard interval — where `sat_untl_neg`'s
   `F(φ)@t' ∨ F(ψ)@t'` settles nothing, since neither disjunct covers `s = t'`, the case whose
   guard interval is empty.

*Correction 12 — the `ℤ` rays are asymmetric, and the lower one is the residual.* At an
**upper-ray** point the positive case closes outright: every point above reads the same label, so
`untlRay_self` supplies the witness and the guard interval is empty. At a **placed** point the
witness and the intervening points are all placed, so item 2's iteration plus a genuine-guard row
closes it. The **lower ray** is neither: a point below every placed point reaches a placed witness
across the whole lower ray *and* every placed point below the witness, so it demands the guard at
the ray's own label **and** at every known time below the witness. `regionLabel` chooses the
*first eligible* candidate, not the order-minimal one, so `untlNegFuture` does not reach past it
either. This is a strictly larger demand than the placed case, it is not carried by any row of
`temporalWitnessCheck`, and it is where 7.1c now stops.

*A finding outside 7.1c, recorded because 7.3 will meet it.* `regionLabelCheck` reports **false**
on the branches the engine builds for `U(p,q) → q` and `S(p,q) → q` (probe rows H, J, M, N).
`regionLabelCheck b ord = true` is a *hypothesis* of `not_valid_of_hasOpen_int`, so nothing already
proved is affected — but 7.3 has to discharge it for the branches the engine actually produces,
and for these it cannot. Measured here rather than discovered there.

*What remains in 7.1c.* The two positive halves, plus two named gaps in the negative halves:
(i) the geometry step `f i < f j → strictBefore ord (timeAt b i) (timeAt b j)` — the converse of
`OrderFaithful`, which follows from the packaged order's totality and `le_intPlace_of_branchLE`,
with `branchLT`'s equal-times disjunct vacuous because `b.knownTimes` is an `eraseDups` and hence
`timeAt` is injective; (ii) the lower-ray negative demand of Correction 12. Both are enumerated in
`IntTruth.lean`'s "The temporal cases — OWED" section, which this dispatch rewrote in place.

#### Additions to the Phase 7 DO-NOT-RE-ATTEMPT register (2026-07-28m)

- **Any gate row asking the branch to *assert* a guard** (`b.hasPosAt ψ …`) without exempting
  `ψ = ⊤`. Refuted on nine of twelve probe rows, including rows containing no genuine until: the
  engine never writes `T(⊤)`. Split on `guard = Formula.top` and discharge that case
  semantically, as `sat_untl_pos` does.
- **"Every region label denies the event of every negative until in the world"** as a gate row.
  Refuted on two gate-accepted rows. `untlNegSubjects`'s "strictly below region `j`" side
  condition is correct and must not be dropped; consume `regionLabel_untlNeg` for the non-placed
  points instead.
- **Measuring temporal demands on the `RayRegionProbe.lean`/`RegionGateProbe.lean` corpus alone.**
  Every until in those nine rows is guard-`⊤`, so the branching `untlPos`/`untlNeg` arms never
  fire and any conclusion drawn about them is a conclusion about a case the corpus does not
  contain. Use `TemporalWitnessProbe.lean`'s extended corpus.
- **`sat_untl_neg`/`sat_snce_neg` for the negative temporal case.** `F(φ)@t' ∨ F(ψ)@t'` settles
  neither half at `s = t'`, whose guard interval is empty. Consume `untlNeg_spread`/
  `snceNeg_spread` from `Bridge/TemporalGate.lean` instead.
- **Re-deriving `sat_untl_pos_future`, `sat_snce_pos_past`, `orderDual_converse`, or any row or
  consumption lemma of `temporalWitnessCheck`.** All landed sorry-free in
  `Bridge/TemporalSaturation.lean` and `Bridge/TemporalGate.lean`.
- **Assuming the two `ℤ` rays are mirror images for the *positive* case.** Correction 12: the
  upper ray closes outright via `untlRay_self`; the lower ray is a strictly larger demand.

**PHASE 7 STATUS (2026-07-28q) — 7.1d is CLOSED. The dense milestone is delivered: the truth
lemma is sorry-free at every one of the six `Formula` constructors at `ℚ` and `ℝ`, and so are both
headline results.** `lake build FormalSystem.Metalogic.Decidability` green (1116 jobs); **full
`lake build` green (1939 jobs)**; sorry census over `Verified/` reports `0`, compiler cross-check
MATCH; zero vacuous definitions, zero axioms. Six green commits, each verified by
`git show --stat` for **content** and not merely for exit status. No engine file touched, and
nothing belonging to the concurrent task-408/415 sessions staged.

*What landed, in plan order.*

1. **Two measured gate rows, each stated in the same step that consumes it.** The dispatch prompt
   asked one question to be settled before any proof — whether the dense negative case's
   non-placed evaluation point needs a new row — and the answer is **yes, and so does the positive
   one**. Both were measured on the corpus in the exact adopted shape, beside the rows they
   strengthen, before being written into `temporalWitnessCheck`.
2. **Rows 5 and 6, generalised from the rays to an arbitrary region** (`untlNegRegionUp` /
   `snceNegRegionDn`). Two reaches, not one, and they are separate for a reason worth naming: a
   region label's *rank* says nothing about its region *index*, so the placed points above a
   region (`j ≤ branchRank v`) and the labels of the regions above it (`j ≤ j'`) are reached by
   different clauses. This row **subsumes** the two it replaces — at `j = 0` the rank condition is
   vacuous and the first reach is old row 5 verbatim — so the gate stayed at ten rows here.
   `untlNegRay_low` survives as the `j = 0` instance; `snceNegRay_up` survives as the `j = n`
   instance, and its rank condition is *derived* (`branchRank_lt_length`) rather than vacuous,
   which is why it now carries the side condition explicitly and `branchTruthAt_snce_neg` gained
   `hV`. Measured `uNRU`: `true` on all eight gate-accepted rows, single `false` exactly where
   `uRL` already fails.
3. **Rows 11 and 12** (`untlPosRegion` / `sncePosRegion`), which do **not** subsume rows 3, 9 and
   10 and are therefore adopted beside them, taking the gate to twelve rows. The `self` diagnostic
   column is what settled that: `self` alone is `false` on every genuine-until row, and the
   `known` disjunct alone is unsatisfiable at the top region, where no known time has rank `n`.
   The disjunction is load-bearing, not decoration, and the measurement said so before the proof
   did.
4. **All four temporal halves at a dense carrier**, in `Verified/Bridge/DenseTruth.lean`. The
   negative pair compiled on the first attempt.
5. **The assembly, the instantiation and the headlines**: `branchTruthAt_dense`,
   `exists_countermodel_dense`, `not_validDense_of_hasOpen` (ℚ) and
   `not_validDedekindDense_of_hasOpen` (ℝ).

*The finding that made the negative halves smaller than `ℤ`'s, not larger.* `ℤ`'s negative halves
are seven leaves apiece with three vacuous; the dense ones are **four leaves and none vacuous**.
The `j`-genericity of `regionLabel_untlNeg` (recorded in the 2026-07-28p banner) means a
non-placed point reads `regionLabel … (cutIndex (regionCode f s))` whether it is in an interior
gap or on a ray, so the case split is simply *placed or not*, twice, with no ray analysis at all.
`RayOnly`, `RaySplit`, `Stepped`, `upperRay_of_gt`, `lowerRay_of_lt` and `isPlacedCode_of_between`
appear nowhere in the dense file. What replaces the ray analysis is arithmetic on the cut index —
three counting lemmas (`branchRank_lt_cutIndex` from the last dispatch, plus `cutIndex_mono` and
`cutIndex_le_branchRank` from this one), one per side condition.

*Where the positive halves genuinely differ, in one word.* At `ℤ` the upper-ray leaf **vanishes**
its guard interval: `Stepped` supplies an immediate successor and there is nothing strictly
between. At `ℚ`/`ℝ` no point has a successor, the interval is always inhabited, and the guard has
to be **carried across a whole region** instead. That is precisely what row 11's `self` disjunct
demands and what no `ℤ` row ever did — the one place the dense milestone genuinely costs more
than the discrete one. `exists_gt_sameRegion` supplies the witness `Stepped` used to, and
`sameRegion_convex` does the work `upperRay_of_gt` did.

*A landed row consumed for the first time, at no cost.* `regionLabel_untlGuard` and
`regionLabel_snceGuard` — `Bridge/RegionLabel.lean`'s straddling guards — close the sub-leaf where
a placed-to-placed witness's guard interval meets a non-placed point. `ℤ` never called them
because contiguity made that sub-leaf empty. Consuming them adds **no** obligation to 7.3:
`untlGuards`/`snceGuards` are already rows of `regionLabelCheck`, which is already a hypothesis.
Worth recording as a general principle — consuming an already-gated row is free, and is always
preferable to adding a new one.

*The instantiation is a cast, not a construction.* `ℚ`/`ℝ` reuse `intPlace` composed with
`Int.cast`. `Function.Injective`, `OrderFaithful` and `OrderReflecting` all transport along any
strictly monotone map (`orderFaithful_comp`, `orderReflecting_comp`); what does *not* transport is
`RayOnly`/`RaySplit`/`Stepped`, which is `not_exists_gt_sameRegion_int` read the other way round
and is exactly why this was a separate sub-phase rather than a corollary.

*What Phase 7 still owes.* 7.2 and 7.3, in that order. 7.2 is 7.3's true prerequisite, since
`valid_iff_allClosed` is an iff whose `allClosed → valid` direction *is* 7.2.

*Environment.* Both concurrent sessions were quiet. Nothing under
`WeakCanonical/DenseModelSurgery/**`, `specs/408_*/**` or `specs/415_*/**` was touched, staged,
committed or reverted; staging was by explicit path throughout, and `git show --stat` after every
commit matched the intended diff size.

#### Additions to the Phase 7 DO-NOT-RE-ATTEMPT register (2026-07-28q)

- **Re-deriving any of the four dense temporal halves**, `branchTruthAt_dense`,
  `exists_countermodel_dense`, `not_validDense_of_hasOpen` or
  `not_validDedekindDense_of_hasOpen`. All landed sorry-free.
- **Re-deriving `cutIndex_mono`, `cutIndex_le_branchRank`, `lt_of_cutIndex_le_branchRank`,
  `gt_of_branchRank_lt_cutIndex`, `stateLabel_sameRegion`, `orderFaithful_comp` or
  `orderReflecting_comp`.**
- **Re-measuring or restating rows 5, 6, 11 and 12**, or their consumption lemmas
  (`untlNegRegion_up`, `untlNegRegion_label`, `snceNegRegion_dn`, `snceNegRegion_label`,
  `untlPosRegion_witness`, `sncePosRegion_witness`). Measured, adopted, consumed.
- **Using `RayOnly`, `RaySplit`, `Stepped`, `upperRay_of_gt`, `lowerRay_of_lt` or
  `isPlacedCode_of_between` in anything dense.** All four are false at `ℚ`/`ℝ`; the dense file
  uses none of them and needs none.
- **Building a fresh `ℚ`/`ℝ` placement.** It is `intPlace` composed with `Int.cast`, and the three
  placement facts transport along any strictly monotone map.
- **Treating rows 11 and 12 as subsuming rows 3, 9 and 10.** They do not — the `self` disjunct is
  an escape those rows do not offer — and the corpus measurement shows both disjuncts are needed.
- **Adding a new gate row where a `regionLabelCheck` row already reaches.** `regionLabel_untlGuard`
  closed the dense positive placed leaf at zero cost in gate strength.
- Plus every prior entry, all carried forward unchanged.

**PHASE 7 STATUS (2026-07-28p) — 7.1e is CLOSED; 7.1d is started, with its assembly and its one
new counting bridge landed sorry-free.** `lake build FormalSystem.Metalogic.Decidability` green
(1116 jobs); **full `lake build` green (1939 jobs)**; sorry census over `Verified/` reports `0`,
compiler cross-check MATCH; zero vacuous definitions, zero axioms. Three green commits, each
verified by `git show --stat` for **content** and not merely for exit status. No engine file
touched, and nothing belonging to the concurrent task-408 session staged.

*What landed, in plan order.*

1. **7.1d's assembly** — `Verified/Bridge/DenseTruth.lean` (new, registered).
   `branchTruthAt_of_temporal` is the whole six-case induction with the `untl`/`snce` cases
   abstracted into hypotheses and the other four discharged, unchanged, from `IntTruth.lean`.
   This is the machine-checked form of the claim the last three banners made in prose — that
   `atom`, `bot`, `imp` and `box` are generic in the carrier and the placement and so carry to
   `ℚ`/`ℝ` verbatim. It compiled on the first attempt. It also **names the residual exactly**:
   the only difference between the discrete and dense milestones is two hypotheses, so a reader
   can see at a glance what 7.1d still owes. A second, unplanned finding fell out of the binder
   list: `branchOrderValid` and `temporalWitnessCheck` do not appear in it at all, because no
   non-temporal case consumes either.
2. **7.1e** — `branchTruth` and `signedTruthInModel` deleted. See the sub-phase entry above; the
   short version is that the justification for the intermediate "keep the evaluator" state was
   measured and found false, which turned "demote or delete" into simply delete.
3. **The rank/cut-index bridge** — `branchRank_lt_cutIndex`, with `branchRank_eq_card` and
   `length_filter_finRange` under it. See below; this is the piece that makes the dense negative
   case tractable.

*A finding that shrinks 7.1d, obtained by reading the lemma rather than assuming its shape.*
`regionLabel_untlNeg` and `regionLabel_snceNeg` (`Bridge/RegionLabel.lean`) are stated for an
**arbitrary** region index `j ≤ n`, with side condition `branchRank b ord t < j`. They are not
specialised to the rays. The `ℤ` development only ever called them at `j = n`, and the last
banner's framing suggested an interior gap would need new region-label content — it does not. A
non-placed point reads `regionLabel b ord w (cutIndex (regionCode f s))` whether it sits in an
interior gap or on the upper ray, and the reaching lemma is the same in both cases. So the dense
negative `untl` case has a leaf structure that is *simpler* than `ℤ`'s in one respect: the "`s`
non-placed" leaf covers interior gaps and the upper ray **at once**, where `ℤ` split them.

What that leaf needs is the side condition, and supplying it is the one genuinely new counting
argument: `branchRank` is a `List.filter` length in the **branch** order while `cutIndex` is a
`Finset.card` in the **carrier** order. `branchRank_lt_cutIndex` proves
`f i < s → branchRank b ord (timeAt b i) < cutIndex (regionCode f s)` from `OrderFaithful` alone,
with strictness coming from the one element that separates the two counts — `i` is below `s` and
so is counted on the right, and `strictBefore` is irreflexive on a gated branch and so does not
count `i` on the left. `branchRank_eq_card` moves the count off the list and onto the index type
via `List.map_getElem_finRange`; that is where the argument actually happens, and it needs no
injectivity, because the list and the index type are in *definitional* bijection.

*What 7.1d still owes, and it is the bulk of it.* All four temporal halves at a dense carrier.
The negative halves now have their reaching lemma and their side condition; the positive halves
are the harder pair, because `Stepped`'s witness has to be replaced by density
(`exists_gt_sameRegion`/`exists_lt_sameRegion`) and the residual leaf of Correction 12 has to be
re-examined at a carrier where a region is inhabited. **The obligation the next dispatch should
resolve before writing any proof** is whether the negative case's "`r` non-placed" leaf needs a
new gate row: at `ℤ`, `r` on the lower ray was covered by row 5 (`untlNegRayLow`), whose reach is
*every* known time, and whose scope is `j = 0` only. At `ℚ`/`ℝ`, `r` can sit in an interior
region `j`, and `regionLabel b ord w j` is an arbitrary known time whose rank bears no relation
to `j` — `regionLabel` picks the first eligible candidate, not the order-minimal one — so neither
row 5 nor `untlNeg_spread` reaches. The natural generalisation is row 5 with `0` replaced by an
arbitrary `j`, which would subsume it. **It must be measured on the corpus before it is stated**,
in the exact form to be adopted and beside the row it strengthens; that is the process lesson
that has changed the conclusion in eight consecutive dispatches, most sharply in the last one,
where two already-"adoptable" rows both proved unusable as measured.

*Environment.* The concurrent task-408 session was quiet this dispatch. Its untracked files
(`WeakCanonical/DenseModelSurgery/TruthTransfer.lean`, and `Dual.lean` before it) were never
staged; staging was by explicit path throughout. Worth recording as a change from the last
banner: **both previously-red out-of-territory modules are now green** — the full `lake build`
completes with 1939 jobs and zero errors, so `CounterexampleElimination.lean` and
`BadIntervals.lean` are no longer masking anything.

#### Additions to the Phase 7 DO-NOT-RE-ATTEMPT register (2026-07-28p)

- **Re-proving `atom`/`bot`/`imp`/`box` for the dense carrier, or writing a second six-case
  induction for it.** `branchTruthAt_of_temporal` is the shared assembly; the dense milestone
  supplies two hypotheses to it and nothing else.
- **Re-deriving `branchRank_lt_cutIndex`, `branchRank_eq_card` or `length_filter_finRange`.** All
  landed sorry-free.
- **Assuming an interior gap needs region-label content that the rays did not.**
  `regionLabel_untlNeg`/`regionLabel_snceNeg` are `j`-generic; only the side condition had to be
  supplied, and it now is.
- **Keeping `branchTruth` as an "executable debugging aid".** It is `Prop`-valued with no
  `Decidable` instance and was never `#eval`-able. It is deleted; do not reintroduce it.
- **Searching for a Mathlib `List`-to-`Finset` counting lemma for this transfer.**
  `List.finRange_map_getElem` does not exist; the name is `List.map_getElem_finRange`, and the
  card transfer is `simp [Finset.univ, Fintype.elems, Finset.card, Finset.filter,
  Multiset.filter]`, both recorded in `length_filter_finRange`.
- Plus every prior entry, all carried forward unchanged.

**PHASE 7 STATUS (2026-07-28o) — 7.1c is CLOSED. The truth lemma is sorry-free at every one of
the six `Formula` constructors, and so are both headline results.** `lake build
FormalSystem.Metalogic.Decidability` green (1115 jobs), no `declaration uses sorry` anywhere, no
warnings from either file touched; `lean-sorry-census.sh` over `Verified/` reports **0**. Five
green commits. No engine file touched.

*Measured before stated, for the seventh consecutive dispatch — and this time the measurement
changed the rows.* `gw` and `rdG` were already measured and the prior banner called them
"adoptable"; walking the proof showed **neither is usable as measured**, in two independent ways.
`untlPosGuardedWitness` exempts the *whole row* when `ψ = ⊤`, so it asserts nothing at all on the
`someFuture`/`somePast` fragment — where the positive case still needs a witness, because
`TruthAt … (untl φ ⊤)` demands one. And `untlRayDnGuard` permitted the escape "the event sits at
the ray's own label, with no guard obligation", which does not close the lower-ray leaf: the ray
label is itself a known time, so placed points sit strictly below it, and every one of those is
strictly above the lower-ray evaluation point and inside the guard interval. Both strengthenings
were measured in the exact adopted form as `probe4`'s `uGW`/`sGW`/`uRD`/`sRU`, each beside the
weaker form it strengthens: all four are `true` on all eight rows the region gate accepts, and
neither ever differs from its weaker neighbour anywhere in the twelve. Adopted as rows 7-10 with
four consumption lemmas.

*Obstruction 1 is resolved by option 1, in its minimal form.* `Stepped` — every carrier point has
an immediate successor and an immediate predecessor — discharged at `ℤ` by `r + 1` and `r - 1`. It
is a property of the **carrier**, not of the placement, because that is all the upper-ray leaf
needs: a witness to exist and a guard interval it can empty. The other half of what the banner
said might be needed — "everything strictly above an upper-ray point is itself upper-ray" — is
**derived**, not assumed: `upperRay_of_gt` gets it from `RayOnly` and `RaySplit` alone, since a
point above an upper-ray point can be neither placed nor lower-ray. `lowerRay_of_lt` mirrors it.
`Stepped` is false at `ℚ`/`ℝ`, but so are `RayOnly` and `RaySplit`, and all three are used only by
the temporal cases, so 7.1d pays nothing it was not already paying.

*The earliest-witness iteration was never written, and is now known not to be needed.* It had been
the standing shape of item 2 since the 2026-07-28l banner. Row 7 hands back the witness *and* the
guard below it in one step, so the branch performs the minimisation once, decidably, instead of
the proof redoing it — and `sat_untl_pos_future` is consequently **not called** by either positive
half. The placed leaf is six lines.

*A trimming that is a finding, not a tidy-up.* Neither positive half references `branchOrderValid`,
the frame class, `findUnexpanded`, `findClosure`, `timeOrderTotal`, `boxAnchoredCheck`,
`regionLabelCheck`, or the non-empty-worlds hypothesis. The whole positive direction is carried by
the placement geometry plus rows 3, 7, 9 and 10. `regionLabelCheck` is load-bearing in the
**negative** direction only — which sharpens the 7.3 obligation below rather than removing it.

*The rays swap in the positive direction too, and the same way round as in the negative one.*
`untl` closes its **upper** ray by `untlRay_self` + `Stepped` and carries Correction 12's residual
at the **lower** one; `snce` is the exact mirror.

*Carried forward, unchanged and still live.* `regionLabelCheck` reports **false** on the branches
the engine builds for `U(p,q) → q` and `S(p,q) → q` (probe rows H, J, M, N). It is a *hypothesis*
wherever used, so nothing proved is affected — but 7.3 has to discharge it for real engine
branches, and `temporalWitnessCheck`, now **ten** rows, needs the same treatment.

*An environment hazard, recorded because it cost this dispatch real time.* A concurrent session
working task 408 in this same clone moved the shared worktree to a detached `HEAD` five commits
back, and separately stashed this task's in-progress `TemporalGate.lean` edit (stash message:
"re-stashed by t408-p20.4 after accidental pop of git-snapshot-1785279640"). Nothing was lost —
the commit was recovered from `main` and the edit from the stash — but a commit of this task's
that appeared to succeed had in fact captured only part of the intended diff, and the omission was
visible only as an "unknown identifier" at the *consumer*. Verify committed **content**, not just
commit exit status, while another session shares the clone.

#### Additions to the Phase 7 DO-NOT-RE-ATTEMPT register (2026-07-28o)

- **Re-deriving the positive temporal halves**, `Stepped`, `stepped_int`, `upperRay_of_gt`,
  `lowerRay_of_lt`, rows 7-10 of `temporalWitnessCheck`, or their four consumption lemmas
  (`untlPos_witness`, `sncePos_witness`, `untlRayDn_witness`, `snceRayUp_witness`). All landed
  sorry-free.
- **An earliest-witness iteration on `b.knownTimes.length - branchRank b ord t'`.** Not needed and
  not written. Row 7 supplies the witness together with the guard below it; the minimisation
  belongs in the decidable row, not in the proof.
- **Calling `sat_untl_pos_future`/`sat_snce_pos_past` from the positive halves.** They are not
  used. Their only role in the older design was the guard-`⊤` case, which row 7 now covers because
  its exemption drops the guard and keeps the witness.
- **A gate row that exempts the whole row when `ψ = ⊤`** (as the originally measured `gw`/`rdG`
  did). It asserts nothing on the `someFuture`/`somePast` fragment, where a witness is still owed.
  The exemption must sit inside the witness.
- **A lower-ray positive row permitting the escape `b.hasPosAt φ` at the ray's own label.** It does
  not close the leaf; see the banner above.
- **Assuming that "everything above an upper-ray point is upper-ray" needs to be a hypothesis.**
  It is derivable from `RayOnly` + `RaySplit` (`upperRay_of_gt`). Only the *successor* had to be
  assumed.
- **Adding `regionLabelCheck`, saturation, or the other branch gates back to the positive halves'
  binder lists.** Measured unused; the trim is deliberate.
- Plus every prior entry, all carried forward unchanged.

**PHASE 7 STATUS (2026-07-28n) — still PARTIAL after a ninth dispatch, but the temporal residual
is now HALVED and the remaining half is one direction, not two.** Both **negative** temporal
halves are landed sorry-free. `lake build FormalSystem.Metalogic.Decidability` green; sorry
census over `Verified/` reports `2`, and both are now `branchTruthAt_untl_pos` /
`branchTruthAt_snce_pos` — the negative cases have left the inventory. Three green commits. No
engine file touched.

*The split came first, and it is what made the rest possible.* `branchTruthAt_untl` is now
`fun w r => ⟨branchTruthAt_untl_pos … w r, branchTruthAt_untl_neg … w r⟩`, and likewise for
`snce`. Nothing in the negative direction touches the earliest-witness iteration or the guard at
all, so the whole positive-side residual of Correction 12 stays out of its way. The four landed
non-temporal cases, `sat_untl_pos_future`, `sat_snce_pos_past`, `orderDual_converse` and every
row and consumption lemma of `temporalWitnessCheck` were consumed, not re-derived.

*Measured before stated, for the sixth consecutive dispatch.* `untlNegRayLow` — "a negative until
asserted at its world's **lower-ray** label denies its event at *every* known time" — reports
`true` on **eleven of twelve** corpus rows, the single `false` being row N, where
`regionLabelCheck` already reports `false`. That is the same acceptance standard the four
existing rows met. The strictly weaker "at its own label only" variant was measured alongside as
a diagnostic and fails on exactly that same row, so extending the demand from the ray label to
the whole of `b.knownTimes` costs nothing anywhere in the corpus — and the strong form is the one
the case needs. Adopted with its mirror `snceNegRayUp` as rows 5 and 6 of `temporalWitnessCheck`,
with two consumption lemmas in the established branch-fact-in/branch-fact-out shape.

*The rays swap between the two operators.* `untl` needs its extra row at the **lower** ray and
`snce` at the **upper** one, and the leaf `untl` closes with `regionLabel_untlNeg` at `j = n` its
mirror closes with `regionLabel_snceNeg` at `j = 0`, whose `0 ≤ branchRank` side condition is
free where the other needed `branchRank_lt_length`. This is the negative-direction counterpart of
Correction 12's positive-direction asymmetry, and it runs the same way round.

*What else landed, all sorry-free.*

- **`List.eraseDups` is `Nodup`, proved rather than imported.** The import closure has
  `eraseDups_cons` and `mem_eraseDups` but **no** `Nodup` lemma for `eraseDups` at all;
  Mathlib's `nodup_dedup` is about `List.dedup`, a different function. The recursion is on the
  *filtered* tail, so it is a `length` recursion and not a structural one. Hence
  `knownTimes_nodup` and `timeAt_injective` (`Bridge/BranchOrder.lean`).
- **`OrderReflecting` and `RaySplit`**, beside `OrderFaithful`/`RayOnly`, with both discharges at
  `ℤ`. Order reflection is the geometry step the 2026-07-28m banner owed, and `timeAt_injective`
  is exactly what collapses `branchLT`'s equal-times disjunct, which would otherwise leave a tie
  the case cannot use. `RaySplit` is the position to `RayOnly`'s label: the index says which
  label a non-placed point reads, the position says which points lie above it, and the temporal
  cases need both.
- **`branchRank_lt_length`**, which is what lets a *placed* point reach the upper ray's label
  through `regionLabel_untlNeg`'s "strictly below region `j`" side condition at `j = n`.
- **`isPlacedCode_of_between`** — contiguity in the form the induction consumes it: a carrier
  point strictly between two placed points is itself placed. Proved now rather than next
  dispatch because walking the positive placed-point leaf confirmed its shape. This is the step
  that turns "the guard at every carrier point strictly between" into "at every known time
  strictly between", and it is precisely where `ℤ` parts company with `ℚ`/`ℝ`.

*The negative `untl` case tree, for the record — four live leaves and three vacuous ones.* Write
`r` for the evaluation point and `s` for the witness the semantics hands back, so `r < s`.
`r` placed / `s` placed closes by `OrderReflecting` + `untlNeg_spread`; `r` placed / `s` upper
ray by `regionLabel_untlNeg` at `j = n`; `r` placed / `s` lower ray is vacuous by `RaySplit`;
`r` **lower ray** is one leaf covering all three shapes of `s`, because every label any point
reads is a known time and that is exactly row 5's reach — this is the leaf Correction 12 named;
`r` upper ray forces `n ≠ 0`, makes `s` placed and `s` lower ray vacuous, and closes `s` upper
ray against `r`'s own label.

*What remains in 7.1c — one direction, and its row shapes are already measured.* Only
`branchTruthAt_untl_pos` and `branchTruthAt_snce_pos`. Walking the placed-point leaf confirms
`untlPosGuardedWitness` is exactly the row it wants, and `Tests/BimodalTest/TemporalWitnessProbe.lean`
already reports `gw` and `rdG` (`untlRayDnGuard`) `true` on **every** row the region gate
accepts, so both row shapes are measured and adoptable — they were deliberately **not** stated
this dispatch, because the discipline that has held for six dispatches is measure-then-state-
then-consume in one step, and an unconsumed row in the gate is dead weight a reviewer cannot
validate. Two obstructions are newly identified and neither is a row:

1. **The upper-ray positive leaf needs a witness to exist at all.** At an upper-ray `r` the
   design says `untlRay_self` closes it outright because the guard interval is empty — but that
   argument silently needs *some* `s > r` that is still on the upper ray, i.e. a successor-like
   property of the carrier. `D` is only an `AddCommGroup` + `LinearOrder` here, so `r + 1` is not
   available generically; at `ℤ` it is. Either a new abstract property beside `RayOnly`/
   `RaySplit` ("the upper ray has no greatest element and everything above an upper-ray point is
   upper-ray") or an `ℤ`-only statement of the positive halves is owed. **This was not visible
   before the negative halves were written.**
2. **The lower-ray positive leaf** is Correction 12's residual, unchanged: the guard at the ray's
   own label *and* at every known time below the witness. `untlRayDnGuard` is the measured row
   for it.

The `ψ = ⊤` split is unchanged and still governs: the engine never writes `T(⊤)`, so the guard
row must exempt `ψ = Formula.top` and that case takes its witness from the already-landed
`sat_untl_pos_future` instead.

*Carried forward, unchanged and still live.* `regionLabelCheck` reports **false** on the branches
the engine builds for `U(p,q) → q` and `S(p,q) → q` (probe rows H, J, M, N). It is a *hypothesis*
wherever used, so nothing proved is affected — but 7.3 has to discharge it for real engine
branches, and `temporalWitnessCheck`, now six rows, will need the same treatment.

#### Additions to the Phase 7 DO-NOT-RE-ATTEMPT register (2026-07-28n)

- **Re-deriving the negative temporal halves.** `branchTruthAt_untl_neg` and
  `branchTruthAt_snce_neg` are landed sorry-free. Likewise `OrderReflecting`, `RaySplit`,
  `isPlacedCode_of_between`, `branchRank_lt_length`, `nodup_eraseDups`, `knownTimes_nodup`,
  `timeAt_injective`, rows 5-6 of `temporalWitnessCheck` and their two consumption lemmas.
- **Looking for a `Nodup` lemma for `List.eraseDups` in Mathlib or Batteries.** There is none in
  this import closure — `grep` and an `exact?` probe both come back empty, and
  `List.nodup_dedup` is about `List.dedup`. It is proved locally in `Bridge/BranchOrder.lean`.
- **Assuming an upper-ray point has a carrier point above it** without an explicit property. `D`
  is only an `AddCommGroup` + `LinearOrder` at the point where the temporal cases are stated;
  `RayOnly` and `RaySplit` say nothing about inhabitance above the upper ray. See obstruction 1
  above.
- **Stating the two measured positive rows in `Verified/` before the proof that consumes them.**
  `untlPosGuardedWitness` and `untlRayDnGuard` are measured and adoptable, but a row that enters
  the gate without a consumption lemma is unvalidatable dead weight and makes 7.3's discharge
  obligation larger for nothing. State them in the same step that consumes them.
- Plus every prior entry, all carried forward unchanged; nothing this dispatch did contradicts
  any of them.

### Phase 8: Hygiene — Vacuous Theorems and Documentation [IN PROGRESS]

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
