# Implementation Plan: Engine-Level Assembly for `MintPaysForTimeFixed` at a Nonempty Universe

- **Task**: 462 - mintpaysfortime_engine_level_assembly
- **Status**: [COMPLETED]
- **Effort**: 6.5 hours
- **Dependencies**: None
- **Research Inputs**: `specs/462_mintpaysfortime_engine_level_assembly/reports/01_engine-level-mint-assembly.md`
- **Artifacts**: plans/01_engine-level-mint-assembly.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Add a new section **D5** to
`FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` that discharges
`MintPaysForTimeFixed fc U Tmax` at an arbitrary nonempty universe, under the single frame-class
hypothesis `¬ (FormalSystem.ProofSystem.FrameClass.Dense ≤ fc)`. The work is ten additions
totalling ~500-600 Lean lines: a strengthened pick-stage bridge that keeps stage one's
`findApplicableRule` equation alive, a density exclusion, a handful of guard/trigger/shape
inversions, a four-bucket rule-census case split at the `pickBranches` level, the engine lift, the
discharge itself, and prose. **No engine definition, no predicate statement, and no previously
landed declaration is altered** — every item is an addition. Definition of done: `lake build`
green, zero `sorry`, zero axioms beyond the recorded baseline, `check-module-invariants.sh` with
no new failure, and section D5's prose stating honestly that the discharge unlocks no terminus.

### Research Integration

The research report is ground truth and its verdict is **plumbing, not open mathematics**, backed
by seven Lean probes compiled against the built `MintBound` olean. Four probe sources are preserved
at `specs/462_mintpaysfortime_engine_level_assembly/probes/` (`Probe462.lean`, `Probe462b.lean`,
`Probe462c.lean`, `Probe462d.lean`) and **must be consumed, not re-derived**. Specifically:

| Probe file | Probe | Supplies |
|---|---|---|
| `Probe462b.lean` | 4 | The strengthened bridge `pick_stage_source_rule`, full statement + 44-line proof, compiled first try |
| `Probe462.lean` | 1 | The density exclusion proof (`simp only [isApplicable] at hA; split at hA <;> simp_all`) |
| `Probe462.lean` | 2 | The `untlNeg` ACTIVE-guard inversion (`by_contra`, no PASSIVE arm to consider) |
| `Probe462.lean` | 3 | `allFutureNeg` result-shape inversion |
| `Probe462c.lean` | 5, 6, 7 | `untlNeg` trigger recovery, `untlPos` shape, the `decide`-able four-bucket census |
| `Probe462d.lean` | 5' | An alternative, cleaner `untlNeg` trigger statement destructuring `sf` |

Three findings from the report shape the design and are load-bearing:

1. **The frame restriction is ONE hypothesis, not two.** `¬ (FrameClass.Dense ≤ fc)` excludes
   `.Dense` and `.Dedekind` together (since `Dense ≤ Dedekind` in the `FrameClass` partial order)
   and admits exactly `.Base` and `.Discrete`. It goes in the theorem statement, visible, never
   hidden behind a definition.
2. **`untlNeg`/`snceNeg` have no live PASSIVE arm** (`Tableau.lean:1022-1142` retires it), so a
   non-`notApplicable` result *forces* the ACTIVE guard and disjunct 3's guard extraction is a
   one-`by_contra` inversion.
3. **None of the six witness-guarded minting rules ever returns `.persistent`**, so disjunct 2 has
   exactly two result shapes, both already covered by `mintPotential_lt_of_pick_linear_sigmaFixed`
   and `..._branching_sigmaFixed`.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap context was provided in the delegation and no `specs/ROADMAP.md` was consulted.

### Verified line anchors (re-derived at 14,105 lines, commit `e8d0055ec`)

Every anchor below was re-verified by `grep` at plan time. **They will drift as D5 grows — the
implementer must re-locate before every edit and must never trust a number in this plan as a
current offset.**

| Declaration | Line |
|---|---|
| `pick_ord_eq` | 972 |
| `pick_branches_eq` | 1139 |
| `pick_stage_source` (the existing, insufficient bridge) | 1163 |
| `pickBranches_ordTimes` (the engine-lift template) | 1205 |
| `pickOrd_mono` | 1928 |
| `pick_stage_source_guarded` (precedent for the strengthening) | 2767 |
| `mintPotential_expandOnceUnblocked` | 3156 |
| `applyRule_emitted_time_mem` | 6887 |
| `knownTimes_card_le_succ_of_unorderedSuccessor` | 7196 |
| `selfGuardPotential_lt_of_untlNeg` / `..._snceNeg` | 9250 / 9265 |
| `sigmaTimeStable_of_sigmaFixed` | 10388 |
| `MintPaysForTimeFixed` (def) | 10537 |
| `mintPotential_lt_of_pick_linear_sigmaFixed` / `..._branching_sigmaFixed` | 10575 / 10587 |
| `mintPaysForTimeFixed_signedUniverse_empty` (superseded by this work) | 11147 |
| `findApplicableRule_result_ne_notApplicable` | 11845 |
| `findApplicableRule_isApplicable` | 12711 |
| `pick_stage_source_noMint` (the structural model for the new bridge) | 12738 |
| `pickBranches_knownTimes_subset` | 12788 |
| `splitOrderedRank_le_of_knownTimes_subset` | 12838 |
| `mintPaysForTimeFixed_signedUniverse_untlSnceFree` (D3, generalized by this work) | 12897 |
| `signedUniverse_nonempty` | 12919 |
| D4 boundary note ends / **D5 insertion point** | ~13369 |
| C9 register header (`## C9. The do-not-re-attempt register`) | 13371 |
| C9 entry 20's `*What is left, ...*` paragraph | ~13835-13858 |
| `end FormalSystem.Metalogic.Decidability` | 14105 |

## Goals & Non-Goals

**Goals**:
- Land `mintPaysForTimeFixed_of_not_dense`: `MintPaysForTimeFixed fc U Tmax` for every `fc` with
  `¬ (FrameClass.Dense ≤ fc)`, at an arbitrary universe, with no `sorry` and no new hypothesis on
  the predicate.
- Land `mintPaysForTimeFixed_signedUniverse_of_not_dense`, the `signedUniverse C L` instantiation,
  holding for **every** `C` including formulas carrying `untl`/`snce` — generalizing D3's
  `mintPaysForTimeFixed_signedUniverse_untlSnceFree` (:12897) off its syntactic fragment.
- Land the reusable spine: `pick_stage_source_rule` (strengthened bridge) and
  `pickBranches_mintPays` (four-bucket census).
- Amend C9 entry 20's "*What is left*" paragraph in place to record item (a) as landed and to
  carry the honest scope finding.
- State the scope honestly in D5's section prose: this discharge unlocks **no** terminus.

**Non-Goals**:
- The density coordinate (`gapPotential`) — C9 entry 20's item (b). Explicitly out of scope; the
  frame-class hypothesis is what buys its exclusion.
- Any change to `MintPaysForTimeFixed`'s statement: no new hypothesis, no weakened disjunct, no
  re-indexed `mintPotential`, no dropped cardinality conjunct.
- Any change to `MintPaysForTimeAt` or to disjunct 3's shape (C9 entry 19 route 2 forbids the bare
  `selfGuardPotential` drop; entry 17's `mintPaysForTimeAt_reuse_false` remains true).
- Any change to the four-component measure, `budgetPotentialAt`, `mintPathBoundAt`,
  `mintAwareFuelAt`, `derivedTmaxAt`, or any fuel figure. **No figure changes.**
- Any attempt to de-vacuify an `hlab`-carrying terminus or to discharge `UniverseClosedAt`,
  `DifficultyBounded`, `StepLengthBounded`, `PostBlockingSettles`, or `PostBlockingSettlesRun`.
- Adding a C9 entry 25. The register stays at **24 entries**.

## Standing Prohibitions (apply to every phase, without exception)

Each phase below restates the phase-specific ones; this is the full list and it is binding
throughout.

1. **No `sorry`.** Not structural, not strategic, not temporary. The zero-debt gate applies.
2. **No new axioms.** `#print axioms` for the flagship theorems must match the recorded baseline
   (invariants check C2).
3. **No vacuous discharge and no predicate that is itself false.** If a route requires weakening
   the predicate to something unsatisfiable or trivially true, it is not the route.
4. **Do not edit the md5-pinned frozen files**: `Fuel.lean`, `Saturation.lean`, `Tableau.lean`.
   Nothing in this plan needs an edit to any of them.
5. **Do not alter any previously landed declaration.** All ten items are additions. Amending C9
   entry 20's prose paragraph is the single sanctioned in-place edit and it touches prose only.
6. **Do not re-attempt anything in the C9 do-not-re-attempt register** — entries 14, 17, 18, 19
   and 20 especially, plus the recently amended 11 and 21. Read the relevant entry before
   reaching for a "natural next lemma".
7. **No task-number citations outside `specs/**`.** Invariants check C9 enforces zero task-number
   citations under `FormalSystem/`. Cite declaration names and section labels instead.
8. **Do not claim the result de-vacuifies any `hlab`-carrying terminus**, or that it unlocks any
   downstream terminus at all. See "Honesty constraint" below.
9. **`lake build` green and no regression** to any currently-passing
   `bash scripts/check-module-invariants.sh` check.
10. **STOP-and-record is a legitimate outcome.** If any step turns out to need a fact that does not
    exist — genuinely open mathematics rather than plumbing — the correct response is to stop,
    record the obligation with the exact goal state and the lemma that is missing, mark the phase
    `[BLOCKED]`, and report it. It is never to force it, never to weaken the predicate to make it
    close, and never to leave a `sorry` behind.

## Honesty constraint (binding on Phase 5's prose, and on the final report)

The task description's own value claim is **wrong** and the deliverable must correct it, not
repeat it. Landing this unlocks **no** downstream terminus:

- The nine `hlab : UnorderedSuccessorLabelClosed fc L` carriers (at :6225, :6449, :6491, :6516,
  :10080, :10110, :11059, :11077, :12971 — re-locate before citing) stay vacuous at every nonempty
  `L`, because `unorderedSuccessorLabelClosed_nonempty_false` (:11539) makes that predicate's
  satisfiability set exactly `{∅}`.
- Every `hmint`-carrying terminus that carries no `hlab` stays conditioned on `UniverseClosedAt fc U`
  plus `DifficultyBounded`/`StepLengthBounded` plus `PostBlockingSettles`/`PostBlockingSettlesRun`
  — of which C9 entries 9, 11 and 22 refute three.

What the work **does** deliver, and what the prose may claim:

1. It retires C9 entry 20's item (a) — the last non-density obstruction to the mint predicate itself.
2. It generalizes D3's discharge from the `untl`/`snce`-free fragment to arbitrary `C` including
   temporal operators — the case entry 20 itself calls "the hard one".
3. It is satisfiable rather than vacuous: `signedUniverse_nonempty` (:12919) plus any nonempty `C`
   containing a temporal operator gives a witness, and the discharged hypothesis is a *theorem*
   there.

Omitting this reproduces exactly the failure mode C9 entry 21 documents for
`buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse_untlSnceFree`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Phase 3's four-bucket case split runs long (~200-280 lines) and overflows one agent run | M | M | Build it as four separately-stated private bucket lemmas, each compiling green and committed on its own; the combinator is then short. Phase 3's Tasks encode this. |
| Line anchors in this plan drift as D5 grows | M | H | Every phase's first task is re-location by `grep -n` on the declaration name. Never `sed -n` a stale offset. |
| An inversion probe does not transplant verbatim (namespace, implicit-binder, or `open` differences) | L | M | Probes are archived Lean sources against the same olean; transplant them, adjust binders only, and re-run the module build immediately. |
| The six shape lemmas (item #5) turn out redundant | L | M | Cost the report's §8 alternative first: a `.persistent` variant of `mintPotential_lt_of_pick_linear_sigmaFixed` (~3 lines, since `nonBranchingResultBranch` treats `.linear`/`.persistent` alike and `applyRule_fresh_witness_nonbranching` is shape-agnostic). Time-box the cost check; fall back to the six lemmas. |
| Temptation to reach for a registered dead route when a bucket resists | H | L | Standing Prohibition 6; the relevant entries are 14, 17, 18, 19, 20. Read before reaching. |
| Prose repeats the task's false value claim | H | M | The Honesty constraint section above; Phase 5 verification greps its own prose for the required negative finding. |
| Register drifts off 24 entries | M | L | Phase 5 verification counts entries and asserts exactly 24. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel. This plan is fully sequential: every edit
lands in the same file (`MintBound.lean`), so parallel phases would collide.

---

### Phase 1: Section D5 scaffold, strengthened bridge, density exclusion [COMPLETED]

**Goal**: Open section D5 at the correct insertion point and land the two zero-risk spine items:
the strengthened pick-stage bridge (which is the *entire* missing threading the task names) and
the frame-class density exclusion.

**Tasks**:
- [x] Re-locate the insertion point: `grep -n '^/-! ## C9\. The do-not-re-attempt register'` on
      `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`. D5 opens
      immediately **before** that header and after D4's boundary note, so the register stays last.
- [x] Read `pick_stage_source_noMint` (grep for the name; ~:12738) in full — the new bridge is a
      structural copy of it.
- [x] Add the D5 section header `/-! ## D5. ...` with a placeholder one-paragraph intro (the full
      prose lands in Phase 5).
- [x] Transplant Probe 4 from `specs/462_mintpaysfortime_engine_level_assembly/probes/Probe462b.lean`
      as `private theorem pick_stage_source_rule`. Statement and 44-line proof are consumed
      verbatim; adjust only binder/namespace details forced by the surrounding file. Do not
      re-derive it.
- [x] Verify the transplanted bridge's conclusion is exactly
      `∃ sf, sf ∈ b ∧ applyRule r sf b ord = (res, o) ∧ (findApplicableRule sf b ord fc = some (r, res, o) ∨ ruleMintsFreshTime r = false)`
      — the third conjunct's left disjunct is what `pick_stage_source` (:1163) discards and what
      disjunct 2 requires.
- [x] Transplant Probe 1 from `probes/Probe462.lean` as
      `theorem findApplicableRule_ne_densityRule`, carrying `hfc : ¬ (FormalSystem.ProofSystem.FrameClass.Dense ≤ fc)`.
- [x] Docstring both: the bridge cites `pick_stage_source_guarded` (:2767) and
      `pick_stage_source_noMint` (:12738) as its two precedents; the exclusion cites
      `findApplicableRule_isApplicable` (:12711) and records that `¬(Dense ≤ fc)` covers `.Dense`
      and `.Dedekind` together and admits exactly `.Base` and `.Discrete`.
- [x] Build the module; commit each green sub-step. *(deviation: altered — Phase 1 landed as a single green sub-step; the module build costs ~15 minutes, so both declarations were built together rather than one at a time)*

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts two new declarations totalling ~55 lines
(`pick_stage_source_rule` ~45, `findApplicableRule_ne_densityRule` ~10), and asserts that Probe 4
transplants verbatim. Confirm at implementation time by: (a) the module build succeeding on the
transplanted proof without proof-script edits beyond binders — if the proof needs real repair,
record what changed and why; (b) `git diff --stat` on the phase's commits against the ~55-line
figure. A material overrun is a signal to re-read `pick_stage_source_noMint`, not to press on.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` — new section D5
  header plus two declarations, inserted before the C9 register header.

**Prohibitions (phase-specific, in addition to all Standing Prohibitions)**:
- Do not modify `pick_stage_source` (:1163), `pick_stage_source_guarded` (:2767), or
  `pick_stage_source_noMint` (:12738). The new bridge is a fourth sibling, not a replacement.
- Do not place D5 after the C9 register.
- Do not edit `Tableau.lean` to expose the guard differently — it is md5-pinned.

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound` exits 0.
- `grep -c 'sorry' ` on the new hunk returns 0 structural occurrences.
- `grep -n 'pick_stage_source_rule\|findApplicableRule_ne_densityRule'` finds both, positioned
  above the C9 register header line.

---

### Phase 2: Guard, trigger, and result-shape inversions [COMPLETED]

**Goal**: Land the leaf inversion lemmas the census case split will consume: the `untlNeg`/`snceNeg`
ACTIVE-guard extraction, the trigger-shape recovery, and the result-shape lemmas for the six
witness-guarded minting rules (or the cheaper `.persistent` variant that replaces them).

**Tasks**:
- [x] Cost the report's §8 alternative **first**, time-boxed to ~15 minutes: attempt a `.persistent`
      variant of `mintPotential_lt_of_pick_linear_sigmaFixed` (:10575). `nonBranchingResultBranch`
      treats `.linear` and `.persistent` alike and `applyRule_fresh_witness_nonbranching` is
      already shape-agnostic, so it is plausibly ~3 lines and removes six lemmas. If it does not
      land inside the time box, abandon it and take the six shape lemmas. Record which route was
      taken and why. *(outcome: the `.persistent` variant is NOT available. `findApplicableRule`'s `.persistent` arm carries **no guard at all** — a deliberate design decision the engine's own comment records — so there is no `findApplicableRule_guard_persistent` to build a `.persistent` payment lemma on. Route taken: exclude `.persistent` from the six on the rule side instead.)*
- [x] Transplant Probe 2 (`probes/Probe462.lean`) as `theorem applyRule_untlNeg_active_guard`, and
      mirror it for `snceNeg` as `applyRule_snceNeg_active_guard`. The proof is a single
      `by_contra` — do not write a two-way PASSIVE/ACTIVE arm analysis; the PASSIVE arm is retired
      in `Tableau.lean:1022-1142` and no longer exists.
- [x] Transplant the trigger recovery (Probe 5' chosen — destructuring `sf` is what lets the consumer feed `selfGuardPotential_lt_of_untlNeg`'s literal `⟨Sign.neg, φ, l⟩` trigger without a further rewrite): prefer Probe 5' (`probes/Probe462d.lean`, destructures `sf`)
      over Probe 5 (`probes/Probe462c.lean`) if it fits the consuming site better; land
      `isApplicable_untlNeg_trigger` and the `snceNeg` mirror.
- [x] *(deviation: altered — ONE lemma replaces six.* `applyRule_ne_persistent_of_fresh` is quantified over `r` under `ruleMintsFreshLabel r = true` and `ruleMintsFreshTime r = true`, which is exactly the six, and excludes only `.persistent` — the sole shape the payment lemmas do not cover that also contributes a successor branch. `.branchingOrdered` and `.notApplicable` need no exclusion: neither contributes a branch to `pickBranches`. Proof skeleton is Probe 3's/Probe 6's, run once instead of six times.)* If the six shape lemmas are needed: transplant Probe 3 (`allFutureNeg`, `probes/Probe462.lean`)
      and Probe 6 (`untlPos`, `probes/Probe462c.lean`) and write the four siblings by the same
      pattern, for `allPastNeg`, `someFuturePos`, `somePastPos`, `sncePos`. Model on the existing
      `applyRule_boxNeg_result`.
- [x] Assert, in a docstring on the shape lemmas, the probe-established fact that **none** of the
      six ever returns `.persistent` — the `.persistent` arms in `applyRule` belong to
      `allPastPos` and `someFutureNeg`, which are not among the six.
- [x] *(deviation: altered — Probe 7's `revert r; decide` does NOT compile: `TableauRule` carries no `Fintype` instance, so the quantified form has no `Decidable` instance. Replaced with `cases r <;> decide`, which is equally exhaustive-by-construction and keeps the anti-drift guarantee.)* Land the census helper: transplant Probe 7 (`probes/Probe462c.lean`) as a private
      `rule_census` lemma, proved by `revert r; decide` over all 36 constructors.
- [x] Build the module after each declaration; commit each green sub-step. *(deviation: altered — each declaration was verified individually by an isolated `lake env lean` probe against the phase-1 olean (`scratchpad/P2.lean`, exit 0) before insertion, then the whole phase was built in place once. A full MintBound module build costs ~15 minutes, so per-declaration module builds were not affordable; the isolated probe is per-declaration evidence of the same kind.)*

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts (a) the four-bucket partition of all 36 `TableauRule`
constructors is exactly `{ruleMintsFreshTime = false}` (27, plus `serialityRule` and `timeLinearity`
arriving only via stages 2/3) ∪ `freshLabelRules ∩ freshTimeRules` (6) ∪ `{untlNeg, snceNeg}` ∪
`{densityRule}`; and (b) either six shape lemmas at ~10 lines each, or one ~3-line `.persistent`
variant replacing them. Confirm (a) mechanically — the `decide`-proved census lemma *is* the
confirmation, and if `decide` fails the partition is wrong and everything downstream must stop.
Confirm (b) by which branch of the first task actually compiled; record the outcome in the commit
message.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` — section D5,
  appended below Phase 1's declarations.

**Prohibitions (phase-specific, in addition to all Standing Prohibitions)**:
- Do not re-index `mintPotential` on `freshTimeRules` — C9 entry 14 closes that route
  (`witnessPresent_eq_false_of_not_freshLabel`).
- Do not weaken disjunct 3 to a bare `selfGuardPotential` drop — C9 entry 19 route 2 forbids it and
  entry 17's `mintPaysForTimeAt_reuse_false` is still true about `MintPaysForTimeAt`.
- Do not add a PASSIVE-arm case to the guard lemmas; there is no such arm.
- Do not mark any new lemma `@[simp]` — that would change elaboration behavior file-wide and take
  this phase out of the `local` tier.

**Verification**:
- Module build exits 0 after each declaration.
- The census lemma closes by `decide` with no manual case list.
- Each guard lemma's proof contains exactly one `by_contra` and no arm split.

---

### Phase 3: `pickBranches_mintPays` — the four-bucket census case split [COMPLETED]

**Goal**: Land the bulk of the work: at the `pickBranches` level, prove the three-way disjunct of
`MintPaysForTimeFixed` for every successor branch, by case-splitting the picked rule into the four
census buckets and closing each from an already-landed payment lemma.

**Tasks**:
- [x] Re-read the disjunct of `MintPaysForTimeFixed` at its current line (grep the name; was :10537)
      so the goal shape is exact, including that
      `mintTimeBudget U σ b ord = b.knownTimes.toFinset.card + mintPotential U σ b ord`.
- [x] Confirm the hypotheses available at the consuming site *(confirmed: `hconf`, `hfix`, `hri.ordTimesKnown` and `sf ∈ b` from the pick are exactly what the buckets need; no new hypothesis was required)* are exactly the ones the payment
      lemmas need — `hconf : ∀ x ∈ b, x ∈ U`, `hfix : SigmaFixed σ b`, `hri : RunInvariant b ord`
      (whose `.ordTimesKnown` field supplies `OrdTimesKnown b ord`), and `sf ∈ b` from the pick.
      **No new hypothesis is added to the predicate.** If one appears to be needed, STOP and record.
- [x] **Build the phase as four separately-stated private bucket lemmas, each compiling green on
      its own and committed as its own sub-step**, then a short combinator. This is what keeps the
      phase inside one agent run and gives four natural checkpoints.
- [x] **Bucket A — `ruleMintsFreshTime r = false` (27 rules, plus `serialityRule`/`timeLinearity`
      from stages 2/3) → disjunct 1.** Close from `applyRule_emitted_time_mem` (:6887) → knownTimes
      subset → `Finset.card_le_card` for conjunct 1, and
      `splitOrderedRank_le_of_knownTimes_subset` (:12838) + `pickOrd_mono` (:1928) for conjunct 2.
- [x] **Bucket B — `freshLabelRules ∩ freshTimeRules` (`allFutureNeg`, `allPastNeg`,
      `someFuturePos`, `somePastPos`, `untlPos`, `sncePos`) → disjunct 2.** Conjunct 2 from
      `mintPotential_lt_of_pick_linear_sigmaFixed` (:10575) or `..._branching_sigmaFixed` (:10587),
      selected by Phase 2's shape lemma (exactly two shapes reachable; `.persistent` is not one).
      This is the bucket that consumes Phase 1's bridge: it needs the *stage-one*
      `findApplicableRule` equation, because the pick lemmas consume
      `findApplicableRule_guard_linear`/`_branching`, whose `witnessPresent … = false` guard lives
      in `findApplicableRule`'s `if` and **not** in `applyRule`. Conjunct 1 by `omega` from
      `knownTimes_card_le_succ_of_unorderedSuccessor` (:7196, giving `|kt nb| ≤ |kt b| + 1`) and
      conjunct 2's `mintPotential nb o + 1 ≤ mintPotential b ord`. The sum is exact, with no slack.
- [x] **Bucket C — `untlNeg`, `snceNeg` → disjunct 3.** Conjunct 2 from
      `selfGuardPotential_lt_of_untlNeg` (:9250) / `..._snceNeg` (:9265), reached through Phase 2's
      guard inversion. Conjunct 1 by `omega` from :7196, `mintPotential_expandOnceUnblocked` (:3156,
      applicable because neither rule is in `freshLabelRules` so the potential only grows on the
      state side), and the self-guard drop. Again exact, no slack — this is C9 entry 19's route 2
      working as designed, and `sigmaTimeStable_of_sigmaFixed` (:10388) weakens `hfix` where needed.
- [x] **Bucket D — `densityRule` → excluded.** Discharge by Phase 1's
      `findApplicableRule_ne_densityRule` under `hfc`, reached through the bridge's left disjunct.
      When the bridge yields its *right* disjunct (`ruleMintsFreshTime r = false`) the rule is in
      Bucket A, so no density case arises there.
- [x] Combine the four buckets into `private theorem pickBranches_mintPays`, driven by Phase 2's
      `decide`-proved census lemma so no constructor is silently missed.
- [x] Build the module after each bucket; commit each green sub-step. *(deviation: altered — each bucket lemma was verified individually by an isolated `lake env lean` probe against the phase-2 olean (`scratchpad/P3.lean`, exit 0) before insertion; the phase was then built in place once. A MintBound module build costs ~15 minutes. Three private adapters not named in the plan were added to keep the buckets readable: `pick_singleton_source`, `pick_singleton_source_noMint`, `pickBranches_knownTimes_card_le_succ` — the last is the pick-level counterpart of `knownTimes_card_le_succ_of_unorderedSuccessor`, which buckets B and C need before the engine lift.)*

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts ~200-280 lines across four buckets and one combinator, and
asserts that every bucket closes from an already-landed lemma with `omega` for both budget
conjuncts. Confirm by: (a) each bucket lemma compiling green before the next is started —
a bucket that does not close from its named lemma is the STOP-and-record trigger, not an invitation
to search for a substitute; (b) `git diff --stat` across the phase's sub-step commits against the
200-280 band. A large overrun means a bucket is being proved the wrong way — re-read the payment
lemma's statement before writing more lines.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` — section D5,
  appended below Phase 2's declarations.

**Prohibitions (phase-specific, in addition to all Standing Prohibitions)**:
- Do not add a hypothesis to `MintPaysForTimeFixed` to make a bucket close. If a bucket needs one,
  STOP and record.
- Do not drop disjunct 1's cardinality conjunct — C9 entry 14 closes that route
  (`splitOrderedRank_lt_of_knownTimes_lt`, `mintPaysForTime_rank_repair_false`).
- Do not redefine `nextTime`, add a `TimeOrdering` highwater field, or add a run-level mint counter
  — C9 entry 18 closes all three. **This task edits no engine definition at all.**
- Do not introduce `gapPotential` or any density-coordinate machinery; the frame hypothesis is the
  whole of the density treatment here.
- Do not leave a bucket "closed" by a tactic that succeeds vacuously — if a goal disappears
  unexpectedly, inspect the state rather than accepting it.

**Verification**:
- Module build exits 0 after each bucket lemma and after the combinator.
- The combinator's case analysis is driven by the `decide`-proved census; no constructor is handled
  by an unexamined catch-all.
- Zero `sorry` in the new hunk.

---

### Phase 4: Engine lift, the discharge, and the `signedUniverse` instantiation [COMPLETED]

**Goal**: Lift the `pickBranches`-level result to the engine, state and prove the discharge under
`¬ (FrameClass.Dense ≤ fc)`, and instantiate it at `signedUniverse C L` for arbitrary `C`.

**Tasks**:
- [x] Re-read the engine-lift template `pickBranches_ordTimes` / `expandOnceUnblocked_ordTimes`
      (grep the names; was ~:1205/:1226) — the `keyO` pattern joining `pick_ord_eq` (:972) and
      `pick_branches_eq` (:1139) is copied from there.
- [x] Land `expandOnceUnblocked_mintPays` by that template, feeding Phase 3's
      `pickBranches_mintPays` and Phase 1's `pick_stage_source_rule` as the `hp` argument.
- [x] Land `mintPaysForTimeFixed_of_not_dense`, carrying
      `(hfc : ¬ (FormalSystem.ProofSystem.FrameClass.Dense ≤ fc))` **explicitly in the statement**.
      It is a single hypothesis; do not state it as two disequalities against `.Dense` and
      `.Dedekind`, which would be both weaker in form and redundant.
- [x] Land `mintPaysForTimeFixed_signedUniverse_of_not_dense`, the `signedUniverse C L`
      instantiation, holding for **every** `C` — no `untl`/`snce`-free side condition.
- [x] Docstring the two termini: record that this supersedes
      `mintPaysForTimeFixed_signedUniverse_empty` (:11147) and generalizes
      `mintPaysForTimeFixed_signedUniverse_untlSnceFree` (:12897) off its syntactic fragment, and
      that non-vacuity comes from `signedUniverse_nonempty` (:12919) plus any nonempty `C` carrying
      a temporal operator.
- [x] Build the module; commit each green sub-step. *(deviation: altered — verified first by an isolated `lake env lean` probe against the phase-3 olean (`scratchpad/P4.lean`/`P5.lean`, exit 0, with `#print axioms` on all three new declarations showing only `propext`, `Classical.choice`, `Quot.sound`), then built in place once.)*

**Timing**: 1 hour

**Depends on**: 3

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts three declarations at ~30 / ~15 / ~8 lines, and asserts the
`expandOnceUnblocked_ordTimes` `keyO` pattern transplants. Confirm by locating that template by name
before writing (not by the line number above) and by the module build succeeding; if the template's
shape has drifted, record the difference rather than assuming this plan's description of it.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` — section D5,
  appended below Phase 3's declarations.

**Prohibitions (phase-specific, in addition to all Standing Prohibitions)**:
- Do not hide the frame-class restriction behind a new definition, a `variable`, or a typeclass.
  It goes in the statement, visible to a reader of the theorem alone.
- Do not restate any downstream terminus against the new discharge, and do not remove `hmint` from
  any existing theorem — see the Honesty constraint. The discharge feeds nothing here.
- Do not touch `mintPaysForTimeFixed_signedUniverse_untlSnceFree` (:12897) or
  `mintPaysForTimeFixed_signedUniverse_empty` (:11147); they are superseded in prose, not deleted.

**Verification**:
- Module build exits 0.
- `grep -n 'Dense ≤ fc'` shows the hypothesis present in `mintPaysForTimeFixed_of_not_dense`'s
  statement, not only in its proof.
- The `signedUniverse` instantiation's statement carries no syntactic side condition on `C`.

---

### Phase 5: Section D5 prose, C9 entry 20 amendment, and the full gate [COMPLETED]

**Goal**: Write section D5's prose stating the scope honestly, amend C9 entry 20's "*What is left*"
paragraph in place, and run the full repository gate.

**Tasks**:
- [x] Replace Phase 1's placeholder D5 intro with the full section prose. It must state, in terms:
      what D5 delivers (entry 20 item (a) retired; D3's discharge generalized to arbitrary `C`
      including temporal operators — the case entry 20 calls the hard one; satisfiable rather than
      vacuous); the frame-class restriction and why `¬(Dense ≤ fc)` is one condition covering
      `.Dense` and `.Dedekind` and admitting exactly `.Base` and `.Discrete`; and — unambiguously —
      that landing this makes **no** terminus in the file non-vacuous.
- [x] The negative finding must name both halves: the nine `hlab` carriers stay vacuous
      (`unorderedSuccessorLabelClosed_nonempty_false`), **and** every `hlab`-free `hmint`-carrying
      terminus stays conditioned on `UniverseClosedAt` plus `DifficultyBounded`/`StepLengthBounded`
      plus `PostBlockingSettles`/`PostBlockingSettlesRun`, three of which C9 entries 9, 11 and 22
      refute. Re-locate the nine carriers by grep before citing any line.
- [x] Amend C9 entry 20's `*What is left, ...*` paragraph **in place** (grep for
      `What is left, stated so it is not mistaken`): item (a) becomes landed, naming the new
      theorems; item (b) — the density coordinate — is unchanged and remains the only thing left;
      the paragraph carries the finding that the discharge unlocks no terminus.
- [x] **Do not add C9 entry 25.** Do not modify entries 11 or 21 — they already cover the `hlab`
      side. Confirm the register still contains exactly 24 entries, and that the header sentence
      still reads "Twenty-four statements".
- [x] Run the full gate: `lake build`, then `bash scripts/check-module-invariants.sh`.
- [x] Compare the invariants output *(identical to the pre-task baseline: ALL CHECKS PASSED, no newly failing check)* against the pre-task baseline; any newly failing check is a
      regression and must be fixed before the phase closes.
- [x] Commit.

**Timing**: 1 hour

**Depends on**: 4

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts ~60 lines of prose, that the C9 register contains exactly
24 entries before and after, and that the nine `hlab` carriers sit at :6225, :6449, :6491, :6516,
:10080, :10110, :11059, :11077, :12971 **in the pre-D5 file** — every one of which will have shifted
by D5's added lines. Confirm by: (a) re-locating each carrier by grep on
`UnorderedSuccessorLabelClosed` and counting the live occurrences, and citing names not offsets in
the prose; (b) counting register entries by grepping the numbered-entry pattern between the C9
header and the file's `end`, asserting 24.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` — D5 section prose
  (replacing the Phase 1 placeholder) and C9 entry 20's "*What is left*" paragraph.

**Prohibitions (phase-specific, in addition to all Standing Prohibitions)**:
- **Do not claim the result de-vacuifies any `hlab`-carrying terminus, or unlocks any downstream
  terminus.** Omitting the negative finding reproduces exactly the failure mode C9 entry 21
  documents.
- Do not add C9 entry 25; do not renumber, reorder, or delete any register entry; do not edit
  entries 11 or 21.
- Do not cite task numbers anywhere in `FormalSystem/` — invariants check C9 enforces zero, and
  Standing Prohibition 7 covers it. Cite declaration names and section labels.
- Do not cite line numbers in the committed prose; they drift. Cite declaration names.

**Verification**:
- `lake build` exits 0.
- `bash scripts/check-module-invariants.sh` shows no check failing that passed before this task
  (C1 build, C2 `#print axioms` baseline, C3 zero structural `sorry`, C9 zero task-number
  citations under `FormalSystem/` are the ones most at risk here).
- The C9 register contains exactly 24 numbered entries and its header still says "Twenty-four".
- D5's prose contains an explicit sentence to the effect that no terminus becomes non-vacuous.
- `git diff` on entry 20 shows a prose-only change confined to the "*What is left*" paragraph.

---

## Testing & Validation

- [x] `lake build` exits 0 with no new warnings attributable to D5.
- [x] Zero `sorry` — asserted by content, not by line number (invariants check C3).
- [x] `#print axioms` for the four flagship theorems matches the recorded baseline (check C2).
- [x] `bash scripts/check-module-invariants.sh` passes every check that passed before this task.
- [x] Zero task-number citations under `FormalSystem/` (check C9).
- [x] `mintPaysForTimeFixed_of_not_dense` and `mintPaysForTimeFixed_signedUniverse_of_not_dense`
      both exist, both carry `¬ (FrameClass.Dense ≤ fc)` visibly in their statements, and neither
      adds a hypothesis to `MintPaysForTimeFixed`.
- [x] The `signedUniverse` terminus has no syntactic side condition on `C` (it is not restricted to
      the `untl`/`snce`-free fragment).
- [x] `git diff` confirms `Fuel.lean`, `Saturation.lean`, `Tableau.lean` are untouched.
- [x] `git diff` confirms every Lean change is an addition inside section D5, plus the single
      prose-only amendment to C9 entry 20.
- [x] The C9 register stands at exactly 24 entries.
- [x] D5's prose carries the honest scope statement.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` — new section D5
  (~500-600 lines) inserted before the C9 register, plus an in-place prose amendment to C9 entry 20.
- New declarations: `pick_stage_source_rule` (private), `findApplicableRule_ne_densityRule`,
  `applyRule_untlNeg_active_guard` / `applyRule_snceNeg_active_guard`,
  `isApplicable_untlNeg_trigger` / `isApplicable_snceNeg_trigger`, the six `applyRule_*_result`
  shape lemmas *or* the `.persistent` pick-lemma variant that replaces them, a private census
  lemma, four private bucket lemmas, `pickBranches_mintPays` (private),
  `expandOnceUnblocked_mintPays`, `mintPaysForTimeFixed_of_not_dense`,
  `mintPaysForTimeFixed_signedUniverse_of_not_dense`.
- `specs/462_mintpaysfortime_engine_level_assembly/summaries/01_*-summary.md` — the implementation
  summary, which must repeat the honest scope statement and must record which Phase 2 route (six
  shape lemmas vs. `.persistent` variant) was taken.
- Per-phase commits following `task {N} phase {P}: {name}` plus green sub-step commits.

## Rollback/Contingency

- Every phase is additive and independently revertable: `git revert` the phase's commits restores
  the previous green state, since nothing previously landed is modified except entry 20's prose in
  Phase 5.
- If Phase 3 stalls on a single bucket, the other three bucket lemmas are already committed green
  and standalone; the phase closes `[PARTIAL]` with the stalling bucket recorded, rather than being
  rolled back wholesale.
- **If the assembly turns out to need genuinely open mathematics after all** — a bucket that cannot
  close from any landed lemma, a payment lemma whose statement does not reach the goal, a
  hypothesis the predicate does not bind — the implementer STOPS. Record: the exact goal state,
  the lemma that would close it and why it does not exist, and which C9 entry (if any) already
  covers the gap. Mark the phase `[BLOCKED]` and report. This is an explicitly legitimate outcome
  of this task and is strictly preferred to forcing the proof, weakening the predicate, or leaving
  a `sorry`.
- The compiled probes at `specs/462_mintpaysfortime_engine_level_assembly/probes/` remain the
  evidence base for the verdict that the work is plumbing; if that verdict is overturned, the
  report and the probes are what the overturning must be argued against.
