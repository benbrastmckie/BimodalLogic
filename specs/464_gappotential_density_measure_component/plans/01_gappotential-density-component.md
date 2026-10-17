# Implementation Plan: Task #464

- **Task**: 464 - gapPotential: the density coordinate of the termination measure
- **Status**: [IMPLEMENTING]
- **Effort**: 16 hours
- **Dependencies**: 462 (REAL semantic; already landed as `MintBound/MintPaysAssembly.lean`, whose `pick_stage_source_rule` threading is what the density bucket plugs into); 463 (file_scope serialization edge only, no mathematical content)
- **Research Inputs**: specs/464_gappotential_density_measure_component/reports/01_gappotential-density-component.md
- **Artifacts**: plans/01_gappotential-density-component.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

`densityRule` mints a fresh time while lying outside both `freshLabelRules` and `selfGuardRules`,
so no disjunct of the current three-disjunct residual `MintPaysForTimeFixed` can move at a density
step, for any sigma whatsoever. This plan lands outcome (a): a fourth measure component
`gapPotential` that counts **unfilled time pairs** over the fixed index set `U ×ˢ U`, proves its
payment at `densityRule` steps and its preservation across `TimeOrdering.identifyTime`, repairs the
residual to a four-disjunct `MintPaysForTimeGap`, discharges that repair at **every** frame class
with no frame-class hypothesis, and carries it through a five-component measure to the terminus
family. It also lands the companion refutation half: `MintPaysForTimeFixed` is itself false at
`.Dense` and `.RTime`, so the task's literal "extend the `MintPaysForTimeFixed` discharge to
`.Dense`" cannot hold as stated and is replaced by a decided refutation plus a named repair.
Definition of done: the full gate set (`bash scripts/check-module-invariants.sh`) green, zero
`sorry`, every new declaration's axiom set within `{propext, Classical.choice, Quot.sound}`, and
`Fuel.lean` / `Saturation.lean` / `Tableau.lean` byte-unchanged.

**One naming correction, stated up front.** The task description asks for the discharge to reach
"`.Dense` and `.Dedekind`". There is no `.Dedekind` frame class: `FrameClass`
(`FormalSystem/ProofSystem/Axioms.lean:505-510`) has exactly four constructors — `Base`, `Dense`,
`ZTime`, `RTime` — and `.RTime` is the Dedekind-complete one, sitting above `.Dense` in the `LE`
instance (`Axioms.lean:512-517`). This plan therefore reads "`.Dedekind`" as `.RTime` throughout,
which is also the reading the research report took. Since Phase 6's discharge carries **no**
frame-class hypothesis at all, it covers all four constructors and the question of which two the
description meant does not affect the deliverable.

### Research Integration

The research report (`reports/01_gappotential-density-component.md`) settles the four design
questions this plan builds on, and this plan adopts all four:

1. **The component counts unfilled pairs, not open gaps.** `densityRule`'s guard has two filter
   conjuncts over `ord.futureOf l.time`: (i) `t'` is maximal, (ii) no intermediate reaches `t'`.
   Conjunct (i) is anti-monotone — any rule minting a fresh maximal time creates a new gap target,
   so a ledger over the rule's own target set *rises* at ordinary steps. Only conjunct (ii) is
   monotone, and read positively it says *filled*. `gapFilled` is conjunct (ii) transcribed
   verbatim with inverted polarity, exactly as `selfGuardDischarged` (`TimeReuse.lean:494`)
   transcribes `untlNeg`/`snceNeg`'s guards.
2. **The `U ×ˢ U` shape from the prior work holds up; the `denseRules` gating does not and is
   dropped.** Monotonicity holds at every frame class, so gating would add an `fc` parameter to a
   measure that currently has none, for no soundness gain.
3. **The identification-arm hazard named in the task description does not apply.** `densityRule`'s
   guard never mentions `ord.timeCount`, so the maxTime-lowering mechanism that refuted earlier
   candidates has nothing to act on here. Preservation is `futureOf_transport`
   (`Invariants.lean:320`) applied to both memberships.
4. **Both σ-hits come from branch formulas**, so register entry 17's
   `selfGuard_no_column_at_retired_time` wall does not arise: the trigger is itself a branch
   formula fixed by `SigmaFixed`, and the target time carries a branch formula by
   `mem_knownTimes_of_mem_futureOf` under `OrdTimesKnown`.

**One deviation from the report's recommended module layout, with its reason.** The report proposes
`MintBound/GapPotential.lean` importing `MintPaysAssembly`, with the density bucket landing
downstream. That layout does not work: the pick-level machinery the bucket needs —
`pickBranches_knownTimes_card_le_succ`, `pick_singleton_source`, `rule_census`,
`pick_stage_source_rule` — is declared `private` in `MintPaysAssembly.lean` and is therefore
unreachable from any downstream module. This plan inverts the edge instead:
`GapPotential.lean` imports `UntlSnceFree` (giving it `MintPaysForTimeFixed`, `BudgetStateFixed`,
`selfGuardPotential`, `futureOf_transport` and the `TimeCensus` facts), `MintPaysAssembly.lean`
re-points its single import at `GapPotential` and gains the density bucket **in place**, reusing
its own private helpers directly, and the five-component measure lands in a third new module
downstream of both. No helper is un-privated and no proof is duplicated.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was supplied in the delegation context, so no roadmap phases are included.
`specs/ROADMAP.md` does name this coordinate ("gapPotential, then the terminus family — RUN BEFORE
the spine"), which matches this plan's internal ordering: the component and its discharge land
first, the terminus family last.

## Goals & Non-Goals

- **Goals**: `gapFilled`, `gapPotential`, `gapPotential_le_sq`, `gapFilled_le_of_grow`,
  `gapPotential_le_of_grow`, `gapFilled_identifyTime`, `gapPotential_identifyTime`,
  `gapPotential_identifyOriented`, `gapPotential_lt_of_density`,
  `mintPaysForTimeFixed_dense_false`, `mintPaysForTimeFixed_rtime_false`, `MintPaysForTimeGap`,
  `mintPaysForTimeGap_of_mintPaysForTimeFixed`, `mintPaysForTimeGap_of_any`,
  `mintPaysForTimeGap_signedUniverse`, `BudgetStateGap`, `budgetPotentialGap`,
  `mintPathBoundGap`, `mintAwareFuelGap`, `derivedTmaxGap`, `derivedTmaxAt_le_derivedTmaxGap`,
  `BudgetedTotalityGap`, `expandBranchWithFuel_isSome_of_budget_gap`,
  `buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse_gap`
- **Non-Goals**:
  - De-vacuification of any terminus. The disclaimer `MintPaysAssembly.lean` already carries
    stands: register entries 9, 11 and 22 still refute co-hypotheses, and nothing here makes any
    terminus non-vacuous. Phase 9 preserves that disclaimer verbatim rather than softening it.
  - Discharging `UnorderedSuccessorLabelClosed` (register entry 21), `PostBlockingSettlesRun`
    (entries 24-25), or `DifficultyBounded` (entry 9). The gap coordinate is orthogonal to all
    three.
  - Re-attempting any refuted route. Register entry 14's two forbidden moves — re-indexing
    `mintPotential` on `freshTimeRules`, and dropping disjunct 1's cardinality conjunct in favour
    of the ordering-rank conjunct alone — are not attempted anywhere in this plan, and neither is
    entry 17's σ-hit shape, entry 19's routes 1-3, entry 18's bookkeeping-side redefinition, or
    entry 20's reading of route 4.
  - Weakening `MintPaysForTimeFixed`, deleting it, or deleting
    `mintPaysForTimeFixed_of_not_dense`. The repair is strictly additive and carries a direction
    lemma; see the entry-7 gate.
  - Editing `Fuel.lean`, `Saturation.lean` or `Tableau.lean`.
  - Any `native_decide`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Kernel cost of the refutation vehicle (an engine step plus `futureOf`'s fuel of 100) | M | M | The existing `gate_is_reissue_hazard` and `orientedGate_*` witnesses decide comparable engine steps. Use a declaration-scoped `set_option maxHeartbeats N in` and `decide +kernel` if `decide` alone times out. Never `native_decide` (it would add an axiom and breach the task's axiom constraint) |
| The `applyRule .densityRule` inversion is a 36-constructor `split` past the default heartbeat budget | M | H | Use the `repeat' split` pattern already proved at `applyRule_irreflOrd` (`Invariants.lean:425`), with `set_option maxHeartbeats 4000000 in` written declaration-scoped (`... in`) so gate C30's no-unscoped-heartbeat assertion still passes |
| `U`-side membership for the target column: `t'` must carry a branch formula | H | L | `OrdTimesKnown` (`RunInvariant.2`) plus `mem_knownTimes_of_mem_futureOf` (`TimeCensus.lean:145`). The predicate already quantifies `RunInvariant`, so no hypothesis is added |
| A `## References` docstring block citing the literature would fail gate C31 | L | M | `caleiro2013`, `gerth1995` and `massacci2000` have no `references.bib` entry (verified at plan time: `grep -nE '^@' references.bib` matches only `venema1993`, `baierkatoen2008`, `venema2007algebrascoalgebras`, `venema1993antiaxioms`). Cite the sources in ordinary docstring prose without a `## References` heading, or add the bib entries in Phase 9 — do not emit an unresolvable `[key]` inside a References block |
| The research's `#eval` measurements were taken against a possibly-stale `MintBound` olean set and are not kernel proofs | M | M | Treat every carried figure as unverified (see each phase's Scope Hypothesis). Phase 4 re-derives the refutation as a kernel-checked `decide`, which supersedes the `#eval`; no figure is committed into `FormalSystem/**` as an `#eval` (gate C27 forbids un-allowlisted debug artifacts) |
| The engine could fill a gap and then un-fill it | H | None | Impossible: edges are never removed except at the ordered split's arm 3, and arm 3 is covered by the transport proof (Phase 2) |
| `futureOf`'s fuel of 100 bounds path length | M | L | Growth and transport are both length-preserving, and the drop uses two length-1 edges, so fuel never binds |
| A sibling task commits into `MintBound/` on this shared working tree | M | M | One sibling (805) is dispatched this cycle; its declared `file_scope` is disjoint from `FormalSystem/**`. Re-read every file immediately before editing, stage only this task's own explicit file list (never `git add -A`, a directory, or a glob), and never run `git-snapshot.sh` in its reverting default mode |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3, 4, 5 | 1 |
| 3 | 6, 7 | 2, 3, 5 |
| 4 | 8 | 6, 7 |
| 5 | 9 | 4, 6, 8 |
| 6 | 10 | 9 |

Phases within the same wave can execute in parallel.

### Phase 1: The Component, Its Ceiling, and Growth [COMPLETED]

**Goal**: `gapFilled` and `gapPotential` exist in a new module wired into both aggregators, with
the ceiling and the growth (non-increase) facts proved.

**Tasks**:
- [x] Create `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/GapPotential.lean`
      with the standard copyright header, `import ...MintBound.UntlSnceFree`, and
      `namespace FormalSystem.Metalogic.Decidability`.
- [x] Declare `gapFilled ord s t := (ord.futureOf s).any fun m => (ord.futureOf m).contains t` —
      `densityRule`'s own second filter conjunct (`Tableau.lean:1344-1385`) transcribed verbatim
      with the polarity inverted. Docstring must say, in words, that conjunct (i) (`t'` maximal) is
      deliberately absent because it is anti-monotone, and that this is the same polarity choice
      `selfGuardDischarged` explains.
- [x] Declare `gapPotential U σ ord :=
      ((U ×ˢ U).filter fun p => gapFilled ord (σ p.1).label.time (σ p.2).label.time = false).card`.
      It takes no `Branch`, exactly like `selfGuardPotential`.
- [x] Prove `gapPotential_le_sq` from `Finset.card_filter_le` and `Finset.card_product`.
- [x] Prove `gapFilled_le_of_grow` by two applications of `TimeOrdering.futureOf_mono`
      (`Fuel.lean:942`), modelled on `selfGuardDischarged_le_of_grow` (`OrientedGate.lean:504`).
- [x] Prove `gapPotential_le_of_grow` as `selfGuardPotential_le_of_grow`
      (`OrientedGate.lean:520`) verbatim with the inner lemma swapped.
- [x] Add one `import` line for the new module to `MintBound.lean` (additive only) and a
      corresponding `/-! ## ... -/` section paragraph to its module docstring.
- [x] Add the matching `import` line to the repository-root `FormalSystem.lean`, in sorted
      position between `...MintBound.FourComponent` and `...MintBound.Invariants` — gate C33
      asserts that file is byte-for-byte what `lake exe mk_all --lib FormalSystem` generates.
- [x] *(deviation: altered — the INV generated-inventory gate additionally went stale the moment
      the new module landed, because `README.md`, `FormalSystem/README.md` and
      `FormalSystem/Metalogic/README.md` carry generated file/line-count blocks that the plan's
      Phase 1 file list does not name. Regenerated with the gate's own sanctioned command
      `bash scripts/check-module-invariants.sh --emit-inventory`; the resulting diff is exactly
      the three counts this module moved, with no unrelated drift.)*

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: The research report estimates "roughly 1,200-1,600 added Lean lines over two
new modules" across the whole task (CARRIED-UNVERIFIED from
`reports/01_gappotential-density-component.md`, Effort field; not re-derived at plan time). This
plan splits the work over **three** new or edited module bodies rather than two, and the figure is
a hypothesis, not a budget: confirm the actual added-line count with
`git diff --stat` at Phase 10 and record the measured figure in the implementation summary rather
than restating the carried estimate.

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound`
exiting 0 with zero errors is the complete covering check — that one target transitively elaborates
both the new module and the aggregator, which is its only dependent — together with
`bash scripts/check-module-invariants.sh --no-build` exiting 0, which covers C33's root-aggregator
currency, C4's import resolution, C3's zero-sorry assertion and the C26/C27/C29/C30 source-text
checks the new file is subject to.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/GapPotential.lean` - new module: `gapFilled`, `gapPotential`, `gapPotential_le_sq`, `gapFilled_le_of_grow`, `gapPotential_le_of_grow`
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` - one added import plus a docstring section paragraph (additive only)
- `FormalSystem.lean` - one added import line, in sorted position

**Verification**:
- Guarded `lake build` of the `MintBound` aggregator target exits 0 with zero errors and zero
  warnings.
- `bash scripts/check-module-invariants.sh --no-build` exits 0 (in particular C33 passes, proving
  the root aggregator edit is in correct sorted position).
- `mcp__lean-lsp__lean_verify` on `gapPotential_le_of_grow` reports axioms within
  `{propext, Classical.choice, Quot.sound}`.

---

### Phase 2: Preservation Across the Identification Arm [COMPLETED]

**Goal**: `gapPotential` survives `TimeOrdering.identifyTime` at the engine's own orientation —
Constraint (F) for the new coordinate.

**Tasks**:
- [x] Prove `gapFilled_identifyTime`: under `incomparableB ord (t₁, t₂) = true` and
      `IrreflOrd ord`, `gapFilled ord s t = true →
      gapFilled (ord.identifyTime t₂ t₁) (rho t₂ t₁ s) (rho t₂ t₁ t) = true`, by applying
      `futureOf_transport` (`Invariants.lean:320`) to both memberships with `m ↦ rho t₂ t₁ m`
      carrying the witness. Model on `selfGuardDischarged_identifyTime`
      (`OrientedGate.lean:565`).
- [x] Prove `gapPotential_identifyTime` by `Finset.card_le_card` over the previous lemma — the
      filter's `true`-set only grows inside an index set that does not move, so no injection from
      the after-set into the before-set is needed (and none exists: `rhoSF t₂ t₁` is not injective
      on `U`). Model on `selfGuardPotential_identifyTime` (`OrientedGate.lean:586`).
      *(deviation: altered — the model lemma's `simp only [Finset.mem_filter] at hp ⊢` shape does
      not transfer verbatim, because this component's filter predicate carries the renaming inside
      its own `Decidable` instance argument, so adding `rhoSF` to the simp set stops
      `Finset.mem_filter` firing at all. Same decomposition, same single `Finset.card_le_card` over
      `gapFilled_identifyTime`; the membership is destructured with explicit
      `Finset.mem_filter.mp` / `.mpr` and the contradiction closed by `Eq.trans` up to defeq
      instead of by `rw`.)*
- [x] Prove `gapPotential_identifyOriented` at `(min t₁ t₂, max t₁ t₂)` via
      `incomparableB_of_firstIncomparablePair_oriented`, mirroring
      `selfGuardPotential_identifyOriented` (`OrientedGate.lean:607`).
- [x] Record in the docstring that `rhoSF` acts on the label's time by exactly the `rho` the reach
      transport is stated at, which is what lines the column index up, and that the renaming is
      *post-composed* so the statement applies unchanged at an `n`-th identification.
- [x] Record in the docstring that **nothing in this proof reads `ord.timeCount`**, so the
      maxTime-lowering mechanism that refuted earlier candidates (`nextTime_reissues_retired_time`,
      `reuse_driven_through_engine`) has no purchase on this coordinate.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Tier Justification**: The same single guarded `lake build` of the `MintBound` aggregator target
is the complete covering check — these three theorems are added to `GapPotential.lean` alone, no
existing signature changes, and the aggregator is the module's only dependent.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/GapPotential.lean` - add `gapFilled_identifyTime`, `gapPotential_identifyTime`, `gapPotential_identifyOriented`

**Verification**:
- Guarded `lake build` of the `MintBound` aggregator target exits 0 with zero errors.
- `mcp__lean-lsp__lean_verify` on `gapPotential_identifyOriented` reports axioms within
  `{propext, Classical.choice, Quot.sound}`.

---

### Phase 3: The Strict Drop at a Density Step [COMPLETED]

**Goal**: `gapPotential_lt_of_density` — the payment, stated at the ordering operation
`(ord.addFuture s f).addFuture f t'` with the guard and the two σ-hits as hypotheses.

**Tasks**:
- [x] Prove the `applyRule .densityRule` inversion facts: the trigger shape via `isApplicable`,
      the result shape `(.persistent (T(ψ)@f :: gProps), (ord.addFuture l.time f).addFuture f t')`,
      and `heq : (ord.futureOf l.time).filter _ = t' :: tail` as the head-of-filter fact. Use the
      `repeat' split` pattern from `applyRule_irreflOrd` (`Invariants.lean:425`) with
      `set_option maxHeartbeats 4000000 in` written declaration-scoped.
      *(deviation: altered — no heartbeat raise is needed and none was written. The 4000000 figure
      is `applyRule_irreflOrd`'s, and that proof pays it because it QUANTIFIES the rule and so
      splits all 36 constructors; fixing the rule to `.densityRule` collapses the match to one
      arm. The real obstacle was different: `Formula.allFuture ψ` is a derived shape
      `((⊥ → ⊥) untl (ψ → ⊥)) → ⊥`, so the arm's constructor pattern is invisible until
      `Formula.allFuture`, `someFuture`, `neg` and `top` are in the simp set — the same extra
      nesting `applyRule_allFuturePos_emitted_nil_of_untlSnceFree` needs. With that, the
      inversions elaborate at the default budget, so `GapPotential.lean` carries no
      `set_option maxHeartbeats` line at all.)*
- [x] Derive `gapFilled ord s t' = false` for the filter head from the rule's own conjunct (ii) —
      this is the before-state of the paying column.
- [x] Derive the after-state `gapFilled ((ord.addFuture s f).addFuture f t') s t' = true` from
      `mem_futureOf_of_mem_constraints` (`Invariants.lean:225`) applied to the two direct edges
      `(s, f)` and `(f, t')`; both are length-1 paths, so the fuel of 100 is nowhere near reached.
- [x] State and prove `gapPotential_lt_of_density` with hypotheses `hunfilled : gapFilled ord s t' = false`,
      `hx : x ∈ U`, `hy : y ∈ U`, `hhx : (σ x).label.time = s`, `hhy : (σ y).label.time = t'`,
      concluding `gapPotential U σ ((ord.addFuture s f).addFuture f t') < gapPotential U σ ord`.
      The proof is `Finset.card_lt_card` on a strict subset: the column `(x, y)` leaves the
      `false`-set, and every other column only grows by Phase 1's `gapFilled_le_of_grow`. Posture
      is modelled exactly on `selfGuardPotential_lt_of_addFuture` (`OrientedGate.lean:700`) —
      guard as a hypothesis, σ-hit as a hypothesis, stated at the ordering operation rather than
      at the rule.
- [x] Docstring must say that the direction here is a **gate**, not a nicety: the lemma is a
      strict `<`, never a `≤`, and the hypothesis list is not widened to make it close (register
      entry 7).

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: The report asserts the inversion needs `set_option maxHeartbeats 4000000`
(CARRIED-UNVERIFIED from `reports/01_gappotential-density-component.md`, Risks section, which reads
it off `applyRule_irreflOrd`'s existing budget rather than measuring the new proof). Confirm the
actual budget this proof needs by raising from the default in steps and recording the lowest value
at which it elaborates; do not copy 4000000 in without checking a smaller figure suffices, and
keep whatever value is used declaration-scoped for gate C30.

**Tier Justification**: The same single guarded `lake build` of the `MintBound` aggregator target
is the complete covering check — the inversion and drop lemmas are added to `GapPotential.lean`
alone, they change no existing signature, and the aggregator is that module's only dependent.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/GapPotential.lean` - add the `applyRule .densityRule` inversion facts and `gapPotential_lt_of_density`

**Verification**:
- Guarded `lake build` of the `MintBound` aggregator target exits 0 with zero errors.
- The conclusion is a strict `<` (read off the statement, not inferred from the proof closing).
- `mcp__lean-lsp__lean_verify` on `gapPotential_lt_of_density` reports axioms within
  `{propext, Classical.choice, Quot.sound}`.

---

### Phase 4: The Refutation Half -- `MintPaysForTimeFixed` Is False at `.Dense` and `.RTime` [COMPLETED]

**Goal**: a kernel-decided refutation establishing that the task's literal "extend the
`MintPaysForTimeFixed` discharge to `.Dense`" cannot hold, so the repair in Phase 5 is a necessity
rather than a preference.

**Tasks**:
- [x] Build the vehicle as `private def`s inside `GapPotential.lean`: the pre-step branch, the
      ordering, the universe and the `Tmax` at which the engine's chosen step is `densityRule`.
      The report's measured starting point is `[T(Gp)@⟨0,0⟩, T(p)@⟨0,1⟩]` with ordering
      `[(0, 1)]` at `.Dense`, reaching the density step after three prior steps (negPos,
      someFutureNeg, impNeg).
      *(deviation: altered — the vehicle landed is a different, strictly simpler one. The report's
      starting point does reach a density step after exactly those three prior steps, confirmed by
      a step trace. But a refutation vehicle has to be a state at which the engine's NEXT step is
      the density step, so the three-steps-later state would have to be written out as a literal
      six-formula branch. Adding `F(F¬p)@⟨0,0⟩` to the branch up front achieves the same thing in
      three formulas: it is exactly `negPos`'s output at the trigger, so `negPos` reports nothing
      and the pick falls straight through to `densityRule`. The engine's pick, successor and every
      figure are identical at `.Dense` and `.RTime`.)*
- [x] Prove `mintPaysForTimeFixed_dense_false :
      ∃ (U : Finset SignedFormula) (Tmax : Nat), ¬ MintPaysForTimeFixed FrameClass.Dense U Tmax`
      by `decide` (or `decide +kernel` under a declaration-scoped heartbeat budget) at that
      vehicle, with σ = `id`. All three disjuncts must be shown to fail at the same step.
      *(deviation: altered — plain `decide` suffices; no `decide +kernel` and no heartbeat budget
      were needed, so `GapPotential.lean` carries no `set_option maxHeartbeats` line.)*
- [x] Prove `mintPaysForTimeFixed_rtime_false` the same way at `.RTime`.
- [x] Docstring must state precisely **why** all three fail, independently of the witness: at a
      `densityRule` step disjunct 1 fails because the mint raises `knownTimes`, disjunct 2 cannot
      move because `densityRule ∉ freshLabelRules`, and disjunct 3 cannot move because
      `densityRule ∉ selfGuardRules` — for every σ whatsoever. The witness decides it; the prose
      explains it.
- [x] Do **not** leave any `#eval` behind in `FormalSystem/**`: gate C27 requires every live
      `#eval`/`#check`/`#print` under `FormalSystem/` to be on
      `scripts/debug-artifact-allowlist.txt` with an exact per-file count and a reason. Keep the
      measurement work in scratch and commit only the `decide`-backed theorems.
- [x] Do **not** delete, weaken or re-state `mintPaysForTimeFixed_of_not_dense`
      (`MintPaysAssembly.lean:637`) — it remains the correct statement at `.Base`/`.ZTime` and is
      superseded in prose only.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: The report carries four `#eval` figures at the measured vehicle —
`knownTimes 2→3`, `mintPotential 40→40`, `selfGuardPotential 5→5`, `gapPotential 25→19`, combined
budget `72→67`, `|U| = 5` (CARRIED-UNVERIFIED from
`reports/01_gappotential-density-component.md`, Tactic Survey Results; taken by `#eval` against a
`Tableau.olean` while the `MintBound` oleans were being rebuilt by another session, and explicitly
described there as checked computations rather than kernel proofs). Confirm each at implementation
time by the `decide` proof itself, which is the kernel-checked replacement; if a figure differs,
the vehicle has drifted and the vehicle — not the figure — is what must be re-chosen.

**Tier Justification**: The same single guarded `lake build` of the `MintBound` aggregator target
is the complete covering check — the vehicle `private def`s and the two refutations are confined to
`GapPotential.lean`, nothing outside it is referenced by a new name, and the aggregator is that
module's only dependent.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/GapPotential.lean` - add the refutation vehicle (`private def`s) plus `mintPaysForTimeFixed_dense_false` and `mintPaysForTimeFixed_rtime_false`

**Verification**:
- Guarded `lake build` of the `MintBound` aggregator target exits 0 with zero errors.
- `mcp__lean-lsp__lean_verify` on both refutations reports axioms within
  `{propext, Classical.choice, Quot.sound}` — in particular confirming no `native_decide` was used.
- `grep -nE '#eval|#check|#print|#reduce|dbg_trace' GapPotential.lean` returns nothing.

---

### Phase 5: `MintPaysForTimeGap` and the Direction Lemma [COMPLETED]

**Goal**: the repaired four-disjunct residual exists, together with the direction lemma that makes
every theorem restated against it a strengthening.

**Tasks**:
- [x] Declare `MintPaysForTimeGap fc U Tmax` as `MintPaysForTimeFixed`'s three disjuncts
      **verbatim** (same order, same conjuncts, same hypothesis list — copy from
      `SigmaFixed.lean:356`), plus a fourth disjunct:
      `mintTimeBudget' + selfGuardPotential' + gapPotential' ≤ mintTimeBudget + selfGuardPotential + gapPotential
      ∧ gapPotential' < gapPotential`.
- [x] Prove `mintPaysForTimeGap_of_mintPaysForTimeFixed`: nothing is dropped and a disjunct is
      added, so the new predicate is **weaker** and the implication runs
      `Fixed → Gap`, never the other way. This is the
      `universeClosedAt_of_universeClosed` idiom.
- [x] Docstring must state the direction in words, and say that the predicate is not landed
      without this lemma — register entry 7 exists because a weakening was once mistaken for a
      repair.
- [x] Docstring must also state what the fourth disjunct is *not*: it is not a re-indexing of
      `mintPotential` on `freshTimeRules` (entry 14's first forbidden move, refuted by
      `witnessPresent_eq_false_of_not_freshLabel`, whose match has exactly eight arms so the three
      added columns are permanently false), and it does not drop disjunct 1's cardinality conjunct
      in favour of the ordering-rank conjunct alone (entry 14's second forbidden move, refuted by
      `splitOrderedRank_lt_of_knownTimes_lt` plus `mintPaysForTime_rank_repair_false`).

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Tier Justification**: The same single guarded `lake build` of the `MintBound` aggregator target
is the complete covering check — the predicate and its direction lemma are new declarations in
`GapPotential.lean`, no existing declaration's signature changes, and the aggregator is that
module's only dependent.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/GapPotential.lean` - add `MintPaysForTimeGap` and `mintPaysForTimeGap_of_mintPaysForTimeFixed`

**Verification**:
- Guarded `lake build` of the `MintBound` aggregator target exits 0 with zero errors.
- The first three disjuncts of `MintPaysForTimeGap` are byte-identical to
  `MintPaysForTimeFixed`'s, confirmed by a side-by-side diff of the two definition bodies.
- `mintPaysForTimeGap_of_mintPaysForTimeFixed` exists and runs in the `Fixed → Gap` direction.

---

### Phase 6: The Density Bucket and the All-Frame-Class Discharge [COMPLETED]

**Goal**: `MintPaysForTimeGap` discharged at **every** frame class, at an arbitrary universe, with
no frame-class hypothesis — the result `mintPaysForTimeFixed_of_not_dense` could not reach.

**Tasks**:
- [x] Re-point `MintPaysAssembly.lean`'s single import from `...MintBound.UntlSnceFree` to
      `...MintBound.GapPotential` (which imports `UntlSnceFree`, so nothing is lost).
- [x] Add `mintPays_bucketD_density`: the fifth bucket of `rule_census`'s split, closing the new
      fourth disjunct from `gapPotential_lt_of_density` plus the three non-rise facts —
      `pickBranches_knownTimes_card_le_succ` (the existing private helper, reachable because this
      bucket lives in the same module), `mintPotential_le_of_grow` (`MintPotential.lean:1021`) and
      `selfGuardPotential_le_of_grow` (`OrientedGate.lean:520`). The arithmetic must be **exact**,
      closing by `omega` from inequalities with no slack, as every existing bucket's does.
- [x] Supply the bucket's two σ-hits: the trigger from `SigmaFixed` plus confinement
      (`sigma_formula_hit_of_sigmaFixed`), and the target column from `mem_knownTimes_of_mem_futureOf`
      under `OrdTimesKnown` plus confinement.
- [x] Restate `pickBranches_mintPays` as `pickBranches_mintPaysGap`, **dropping the `hfc`
      hypothesis** — the `absurd hden (findApplicableRule_ne_densityRule hfc hpick)` arm is
      replaced by the new bucket. Keep the original intact and additive.
- [x] Lift to `expandOnceUnblocked_mintPaysGap` by the same `keyO`/`keyB` `pick_ord_eq` /
      `pick_branches_eq` pattern the existing lift uses; do not destructure the three-stage pick a
      second time.
- [x] Prove `mintPaysForTimeGap_of_any (fc) (U) (Tmax) : MintPaysForTimeGap fc U Tmax` — every
      frame class, arbitrary universe, no hypothesis.
- [x] Prove `mintPaysForTimeGap_signedUniverse` at `signedUniverse C L`, nonempty whenever `C` and
      `L` are (`signedUniverse_nonempty`).
- [x] Docstring must say what this retires (the `¬ (FrameClass.Dense ≤ fc)` restriction, register
      entry 20's item (b)) and what it does **not** do: it makes no terminus in the file
      non-vacuous. Preserve the existing de-vacuification disclaimer verbatim.

**Timing**: 2 hours

**Depends on**: 3, 5

**Verification Tier**: local

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound`
exiting 0 is the complete covering check — `MintPaysAssembly.lean` has exactly one dependent in the
whole tree, the `MintBound` aggregator (verified at plan time: no other module under `MintBound/`
imports it), and that one target elaborates both.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/MintPaysAssembly.lean` - re-pointed import; add `mintPays_bucketD_density`, `pickBranches_mintPaysGap`, `expandOnceUnblocked_mintPaysGap`, `mintPaysForTimeGap_of_any`, `mintPaysForTimeGap_signedUniverse`

**Verification**:
- Guarded `lake build` of the `MintBound` aggregator target exits 0 with zero errors.
- `mintPaysForTimeGap_of_any`'s statement carries **no** frame-class hypothesis, read off the
  signature.
- `mintPaysForTimeFixed_of_not_dense` and `mintPaysForTimeFixed_signedUniverse_of_not_dense` are
  still present and unchanged (`git diff` shows additions only in their vicinity).
- `mcp__lean-lsp__lean_verify` on `mintPaysForTimeGap_of_any` reports axioms within
  `{propext, Classical.choice, Quot.sound}`.

---

### Phase 7: The Five-Component Measure: State, Weight, and Step Lemmas [COMPLETED]

**Goal**: `BudgetStateGap` and `budgetPotentialGap` exist and provably decrease at every step the
engine can take, including all three arms of an ordered split.

**Tasks**:
- [x] Create `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/FiveComponent.lean`
      with the standard header and `import ...MintBound.MintPaysAssembly`.
- [x] Declare `BudgetStateGap`: `BudgetStateFixed`'s clauses (`SigmaFixed.lean:451`) with the
      budget clause widened to
      `mintTimeBudget U σ b ord + selfGuardPotential U σ ord + gapPotential U σ ord ≤ Tmax`.
- [x] Prove `budgetStateFixed_of_budgetStateGap` (or the correctly-directed analogue), so the
      relationship to the landed state is explicit and the direction is on the record.
      *(deviation: altered — landed under exactly that name, and the direction is the one the
      plan's parenthetical anticipated: `BudgetStateGap → BudgetStateFixed`. The five-component
      STATE is the stronger one (one more non-negative summand on the left of the budget clause)
      even though the repaired RESIDUAL `MintPaysForTimeGap` is the weaker one. The two run
      opposite ways and the docstring says so.)*
- [x] Declare `budgetPotentialGap := budgetPotentialAt U Tmax σ b ord
      + (2 * (Tmax * Tmax + 1) + U.card) * gapPotential U σ ord`, reusing `budgetPotentialAt`'s own
      weight argument (`FourComponent.lean:67`) rather than inventing a second one. The docstring
      must say which three quantities the weight has to dominate, as `budgetPotentialAt`'s does.
- [x] Prove the unordered-step lemma: gap non-increase is Phase 1's `gapPotential_le_of_grow`, via
      `expandOnceUnblocked_ord_mono` (`OrderingTimes.lean:897`).
- [x] Prove the `splitOrdered` step lemma at all three arms: arms 1 and 2 by growth, arm 3 by
      Phase 2's `gapPotential_identifyOriented`.
- [x] Prove `stepDecreases_budgetPotentialGap`, taking `MintPaysForTimeGap` where the landed
      `stepDecreases_budgetPotentialAt_fixed` (`SigmaFixed.lean:734`) takes
      `MintPaysForTimeFixed`.

**Timing**: 2 hours

**Depends on**: 2, 5

**Verification Tier**: local

**Tier Justification**: A guarded `lake build` of the `MintBound` aggregator target exiting 0 is
the complete covering check — `FiveComponent.lean` is a brand-new module whose only dependent is
the aggregator, and this phase changes no existing declaration's signature anywhere.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/FiveComponent.lean` - new module: `BudgetStateGap`, `budgetPotentialGap`, the unordered and `splitOrdered` step lemmas, `stepDecreases_budgetPotentialGap`
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` - one added import plus a docstring section paragraph (additive only)
- `FormalSystem.lean` - one added import line, in sorted position

**Verification**:
- Guarded `lake build` of the `MintBound` aggregator target exits 0 with zero errors.
- `bash scripts/check-module-invariants.sh --no-build` exits 0 (C33 confirms the second root
  aggregator edit is in correct sorted position).
- The arm-3 case of the `splitOrdered` step lemma cites `gapPotential_identifyOriented`, confirmed
  by reading the proof term.

---

### Phase 8: The Figures and the Terminus Family [COMPLETED]

**Goal**: the enlarged figures and the eight termini restated at the five-component measure, with
the `MintPaysForTimeGap` hypothesis **discharged** rather than carried.

**Tasks**:
- [x] Declare `derivedTmaxGap kt0 Ucard := kt0 + 10 * Ucard + Ucard * Ucard` — `derivedTmaxAt`
      (`FourComponent.lean:508`) plus the gap ceiling `gapPotential_le_sq` supplies.
- [x] Prove `derivedTmaxGap_spec` (definitional, as `derivedTmaxAt_spec` is) and
      `derivedTmaxAt_le_derivedTmaxGap` — the new bound is an **enlargement**, never a
      replacement, so nothing stated at `derivedTmaxAt` is withdrawn.
- [x] Declare `mintPathBoundGap` and `mintAwareFuelGap`, mirroring `mintPathBoundAt` /
      `mintAwareFuelAt` (`FourComponent.lean:424,430`), and prove the two enlargement lemmas
      `mintPathBoundAt_le_mintPathBoundGap` and `mintAwareFuelAt_le_mintAwareFuelGap`.
- [x] Prove `budgetPotentialGap_lt_mintPathBoundGap`.
- [x] Declare `BudgetedTotalityGap` and restate the terminus family at it: the eight `_fixed`
      termini in `SigmaFixed.lean` (`expandBranchWithFuel_isSome_of_budget_fixed`,
      `buildTableauAt_isSome_of_budget_fixed`, `buildTableauAt_isSome_at_seed_fixed`,
      `buildTableauAt_isSome_of_lengthBudget_fixed`,
      `buildTableauAt_isSome_at_seed_lengthBudget_fixed`,
      `buildTableauAt_isSome_of_lengthBudget_signedUniverse_fixed`,
      `buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse_fixed`, plus
      `budgetPotentialAt_lt_mintPathBoundAt_fixed`) become their `_gap` counterparts.
- [x] In each restated terminus, **drop the `hmint` hypothesis** and discharge it internally from
      Phase 6's `mintPaysForTimeGap_of_any`. This is the headline improvement: the residual becomes
      a theorem rather than a condition the caller must meet.
- [x] Docstring must preserve the de-vacuification disclaimer: dropping `hmint` does not make any
      terminus non-vacuous, because entries 9, 11 and 22 still refute co-hypotheses
      (`DifficultyBounded`, clause 2 of `UniverseClosed`, `PostBlockingSettles`).

**Timing**: 2 hours

**Depends on**: 6, 7

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts **eight** `_fixed` termini to restate, enumerated above
and measured at plan time by `grep -nE '^(def|theorem) ' SigmaFixed.lean` over the
`BudgetedTotalityFixed` section (`SigmaFixed.lean:764-892`). Confirm the count at implementation
time by re-running that grep against the live file; if the section has grown, restate every member
rather than the eight named here, and record the actual count in the implementation summary.

**Scope Hypothesis CONFIRMED at implementation time.** The grep was re-run against the live file
(`awk 'NR>=764 && NR<=920 && /^(def|theorem) /' SigmaFixed.lean`) and returns **nine**
declarations: the `def BudgetedTotalityFixed` at `:771` plus exactly the **eight** theorems the
plan enumerates — `budgetPotentialAt_lt_mintPathBoundAt_fixed` `:764`,
`expandBranchWithFuel_isSome_of_budget_fixed` `:783`, `buildTableauAt_isSome_of_budget_fixed`
`:802`, `buildTableauAt_isSome_at_seed_fixed` `:819`,
`buildTableauAt_isSome_of_lengthBudget_fixed` `:837`,
`buildTableauAt_isSome_at_seed_lengthBudget_fixed` `:852`,
`buildTableauAt_isSome_of_lengthBudget_signedUniverse_fixed` `:873`,
`buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse_fixed` `:892`. The section has not
grown; the count is 8 and all 8 were restated.

**Tier Justification**: A guarded `lake build` of the `MintBound` aggregator target exiting 0 is
the complete covering check — every declaration this phase adds lands in `FiveComponent.lean`,
whose only dependent is the aggregator; the `_fixed` termini in `SigmaFixed.lean` are read, never
edited, so no existing signature changes.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/FiveComponent.lean` - add `derivedTmaxGap`, `derivedTmaxGap_spec`, `derivedTmaxAt_le_derivedTmaxGap`, `mintPathBoundGap`, `mintAwareFuelGap`, the two enlargement lemmas, `budgetPotentialGap_lt_mintPathBoundGap`, `BudgetedTotalityGap`, and the eight restated termini

**Verification**:
- Guarded `lake build` of the `MintBound` aggregator target exits 0 with zero errors.
- `buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse_gap`'s signature carries **no**
  `hmint` hypothesis and **no** frame-class restriction, read off the statement.
- `derivedTmaxAt_le_derivedTmaxGap` and `mintAwareFuelAt_le_mintAwareFuelGap` both exist, proving
  the figures enlarge rather than replace.
- `mcp__lean-lsp__lean_verify` on the seed-level terminus reports axioms within
  `{propext, Classical.choice, Quot.sound}`.

---

### Phase 9: The Register Entry and the Prose Amendments [COMPLETED]

**Goal**: every in-tree statement that the density coordinate is open is corrected, and the
refutation half is recorded as a C9 register entry.

**Tasks**:
- [x] Add **C9 register entry 26** to `Register.lean` (verified at plan time: the register's
      numbered list currently ends at entry 25, `Register.lean:843`). It records both halves: that
      `MintPaysForTimeFixed` at `.Dense`/`.RTime` is refuted, not merely unproved, with the
      deciding witnesses named; and that the repair `MintPaysForTimeGap` is landed and discharged
      at every frame class with no hypothesis. State what the entry forbids re-attempting: a
      density payment built on the rule's own gap-target set, which rises at ordinary steps because
      conjunct (i) is anti-monotone.
- [x] Amend register entries 14, 17, 19 and 20 in place where they say the density coordinate /
      `gapPotential` is unimplemented, so they say it is closed. Do not delete their refutations:
      entry 14's two forbidden moves, entry 17's σ-hit refutation and entry 19's routes 1-3 are all
      untouched by this work and must remain readable as live prohibitions.
- [x] Amend the five remaining in-tree prose sites that assert the coordinate is open, measured at
      plan time by `grep -rn 'gapPotential' FormalSystem/`: the "density residual" subsection in
      `TimeReuse.lean` (including "no `gapPotential` is implemented in this file"), the two
      mentions in `OrientedGate.lean`, the four in `SigmaFixed.lean` (including
      `MintPaysForTimeFixed`'s own docstring closing line "`gapPotential` remains implemented
      nowhere and assumed by nothing"), the one in `FourComponent.lean`, and the two in
      `MintPaysAssembly.lean`.
      *(deviation: altered — the per-file hit counts in this item are plan-time estimates of RAW
      `gapPotential` occurrences, not of occurrences asserting the coordinate is OPEN, which is
      the criterion the item's own first line states. Re-run at implementation time, the
      open-assertion filter returns **six** sites in **five** `.lean` files: `SigmaFixed.lean:355`
      (one, not four), `TimeReuse.lean:537` and `:756` (two), `OrientedGate.lean:163` (one, not
      two), `MintPaysAssembly.lean:630` (one, not two), and `Register.lean:520`. `FourComponent.lean`
      has one such site too (`:725`), so it IS a real target, and all six plus `FourComponent`'s
      were amended. Total raw `gapPotential` hits across those six files: 32 — which is where the
      larger plan-time per-file counts came from.)*
- [x] Amend `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/README.md` and
      `FormalSystem/Metalogic/Decidability/Verified/README.md`.
- [x] Preserve the de-vacuification disclaimer at every site it appears. Nothing here makes a
      terminus non-vacuous, and the amendments must not read as though it does.
- [x] If any literature source is cited, cite it in ordinary docstring prose. Do **not** place an
      unresolvable `[key]` inside a `## References` block: gate C31 requires every such key to
      resolve in the repository-root `references.bib`, and `caleiro2013`, `gerth1995` and
      `massacci2000` have no entry there. Either add the bib entries in this phase or cite without
      the References heading.
      *(done: a "What the literature contributed, and what it did not" block was added to
      `GapPotential.lean`'s module docstring, in ordinary prose with NO `## References` heading, so
      no bib key is introduced. It grounds Venema's interval-based section as what fixes the
      `U ×ˢ U` pair indexing — its chop operator is literally `gapFilled`'s existential over an
      intermediate — and the Gerth-Peled-Vardi-Wolper / Baier-Katoen closure-set pattern as the
      fixed-index-set property that makes the component survive `identifyTime`, while stating
      plainly that the analogy is partial and that Caleiro-Viganò-Volpe's mosaic method and
      Massacci's prefix-length bound were considered and are NOT used. C31 re-run: all 239
      References-block citations resolve; no new key added.)*
- [x] Add no task-number citation to any file under `FormalSystem/` — gate C9 asserts zero, and
      `.claude/rules/no-task-references-in-deliverables.md` requires durable anchors (declaration
      names, register entry numbers, filenames) instead.

**Timing**: 1.5 hours

**Depends on**: 4, 6, 8

**Verification Tier**: interface

**Scope Hypothesis**: This phase asserts **six** `.lean` prose sites plus **two** READMEs,
enumerated above and measured at plan time by
`grep -rn 'gapPotential' --include=*.lean --include=README.md FormalSystem/` (which returned
`Register.lean`, `TimeReuse.lean`, `OrientedGate.lean`, `SigmaFixed.lean`, `FourComponent.lean`,
`MintPaysAssembly.lean`, plus the two README files found by a separate
`grep -rln 'density residual|densityRule|MintPaysForTimeFixed'` sweep). Re-run both greps at
implementation time; Phases 1-8 add new `gapPotential` occurrences of their own, so filter to
occurrences asserting the coordinate is OPEN rather than counting raw hits, and record the
corrected count.

**Tier Justification**: This phase edits docstring prose across six modules spanning the whole
`MintBound` import chain, so no single-module check covers it; one guarded
`lake build` of the `MintBound` aggregator target elaborates all six files and their one shared
dependent (an unbalanced `/-!` or `/--` delimiter is a real parse surface a diff read-through can
miss), together with `bash scripts/check-module-invariants.sh --no-build` exiting 0, which covers
C5's module-path resolution in markdown, C13/C32's markdown-link resolution, C14's documented
axiom/sorry counts, C9's zero task-number citations and C31's References-block key resolution.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/Register.lean` - add C9 entry 26; amend entries 14, 17, 19, 20 in place
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/TimeReuse.lean` - amend the "density residual" subsection
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/OrientedGate.lean` - amend the two named-residual mentions
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/SigmaFixed.lean` - amend `MintPaysForTimeFixed`'s docstring and the three other mentions
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/FourComponent.lean` - amend the one mention
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/MintPaysAssembly.lean` - amend the two mentions
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/README.md` - record the landed coordinate and the new modules
- `FormalSystem/Metalogic/Decidability/Verified/README.md` - record the landed coordinate
- `references.bib` - optional: add the bib entries if any literature source is cited inside a References block

**Verification**:
- Guarded `lake build` of the `MintBound` aggregator target exits 0 with zero errors (no docstring
  delimiter was broken).
- `bash scripts/check-module-invariants.sh --no-build` exits 0.
- No in-tree prose remaining asserts the density coordinate is open, confirmed by re-running the
  two plan-time greps and reading every surviving hit.
- The de-vacuification disclaimer is still present at each site it was present before, confirmed
  by `git diff`.

---

### Phase 10: Full Gate Set [COMPLETED]

**Goal**: the repository's complete gate set green, with the task's own four constraints
independently evidenced.

**Tasks**:
- [x] Run the complete gate set: `bash scripts/check-module-invariants.sh` (no `--no-build`, no
      `--only`, no narrowing flag of any kind).
      *(deviation: altered — this dispatch carries a `## Batch Gate Deferral` directive telling it
      to discharge this phase's declared `full` tier against a SCOPED tier instead, naming
      `agent-system/extensions/core/scripts/tests/run-all.sh --only SUITE` or
      `.../verify-deploy.sh --only-gate N`. **No `agent-system/` directory exists in this
      repository** — it is a deploy target, and `.claude-extensions.json` carries no `source_dir`
      — and both named scripts cover the core extension's own test suites rather than
      `FormalSystem/**`, which is the only tree this task touches. There was nothing to narrow to,
      so the **full** unnarrowed gate set was run instead: strictly stronger than the deferral
      asked for, not weaker. Result: exit 0, `ALL CHECKS PASSED`, 55 PASS rows, zero FAIL rows.
      The once-per-invocation batch-level stage still owes its own run; nothing here forgives
      it.)* This is the aggregator for every check this
      repository's Lean side gates on — C1 `lake build` exits 0, C2/C14/C21 axiom baselines,
      C3 zero structural `sorry` asserted by content, C4/C5/C33 import and aggregator currency,
      C16 the Batteries env_linter batch against `scripts/nolints.json`, C24 `Init` reachability,
      C26-C32 the source-text checks, and the remainder. Every gate it aggregates must pass; a
      findings list with any FAIL row is not a pass.
- [x] Confirm zero `sorry` across the task's own additions independently:
      `bash .claude/scripts/lean-sorry-census.sh` and a content grep over the three touched module
      bodies.
- [x] Confirm the axiom constraint on every new declaration named under Goals:
      `mcp__lean-lsp__lean_verify` on each, each reporting a subset of
      `{propext, Classical.choice, Quot.sound}`. In particular confirm no `native_decide` anywhere.
- [x] Confirm the frozen files are byte-unchanged: `md5sum` of `Fuel.lean`, `Saturation.lean` and
      `Tableau.lean` matches their pre-task values, and `git diff --name-only` lists none of the
      three.
- [x] Confirm `MintBound.lean` was edited additively only: `git diff` on it shows added lines
      (two imports plus docstring paragraphs) and no deletions or modifications.
- [x] Record the measured added-line count (`git diff --stat`) against Phase 1's carried estimate,
      and record both figures in the implementation summary.
- [x] Re-read every file immediately before its commit and stage only this task's own explicit
      file list — a sibling task is live on this shared working tree this cycle.

**Timing**: 1 hour

**Depends on**: 9

**Verification Tier**: full

**Files to modify**:
- none planned; this phase only measures. Any repair the gate set demands is made in the file that
  fails and recorded as a deviation.

**Verification**:
- `bash scripts/check-module-invariants.sh` exits 0 with no FAIL row in its findings list.
- `bash .claude/scripts/lean-sorry-census.sh` reports zero `sorry` in the three touched modules.
- `mcp__lean-lsp__lean_verify` on all 24 Goals identifiers reports axioms within
  `{propext, Classical.choice, Quot.sound}`.
- `md5sum FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean` and the two other
  frozen files match their pre-task values; `git diff --name-only` names none of them.
- `git diff` on `MintBound.lean` shows additions only.

---

## Lean Challenge Statements

```lean
import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.MintPaysAssembly

namespace FormalSystem.Metalogic.Decidability

def gapFilled (ord : TimeOrdering) (s t : TimeIndex) : Bool := sorry

def gapPotential (U : Finset SignedFormula) (σ : SignedFormula → SignedFormula)
    (ord : TimeOrdering) : Nat := sorry

theorem gapPotential_le_sq (U : Finset SignedFormula) (σ : SignedFormula → SignedFormula)
    (ord : TimeOrdering) : gapPotential U σ ord ≤ U.card * U.card := sorry

theorem gapFilled_le_of_grow {ord ord' : TimeOrdering}
    (hord : ∀ q ∈ ord.constraints, q ∈ ord'.constraints) (s t : TimeIndex)
    (h : gapFilled ord s t = true) : gapFilled ord' s t = true := sorry

theorem gapPotential_le_of_grow {U : Finset SignedFormula}
    {σ : SignedFormula → SignedFormula} {ord ord' : TimeOrdering}
    (hord : ∀ q ∈ ord.constraints, q ∈ ord'.constraints) :
    gapPotential U σ ord' ≤ gapPotential U σ ord := sorry

theorem gapFilled_identifyTime {ord : TimeOrdering} {t₁ t₂ : TimeIndex}
    (hinc : incomparableB ord (t₁, t₂) = true) (hnsl : IrreflOrd ord) (s t : TimeIndex)
    (h : gapFilled ord s t = true) :
    gapFilled (ord.identifyTime t₂ t₁) (rho t₂ t₁ s) (rho t₂ t₁ t) = true := sorry

theorem gapPotential_identifyTime {U : Finset SignedFormula}
    {σ : SignedFormula → SignedFormula} {ord : TimeOrdering} {t₁ t₂ : TimeIndex}
    (hinc : incomparableB ord (t₁, t₂) = true) (hnsl : IrreflOrd ord) :
    gapPotential U (fun x => rhoSF t₂ t₁ (σ x)) (ord.identifyTime t₂ t₁)
      ≤ gapPotential U σ ord := sorry

theorem gapPotential_identifyOriented {U : Finset SignedFormula}
    {σ : SignedFormula → SignedFormula} {b : Branch} {ord : TimeOrdering} {t₁ t₂ : TimeIndex}
    (htrig : firstIncomparablePair b ord = some (t₁, t₂)) (hirr : IrreflOrd ord) :
    gapPotential U
        (fun x => rhoSF (identifyOrient t₁ t₂).1 (identifyOrient t₁ t₂).2 (σ x))
        (identifyOriented b ord t₁ t₂).2
      ≤ gapPotential U σ ord := sorry

theorem gapPotential_lt_of_density {U : Finset SignedFormula}
    {σ : SignedFormula → SignedFormula} {ord : TimeOrdering} {s f t' : TimeIndex}
    (hunfilled : gapFilled ord s t' = false)
    {x y : SignedFormula} (hx : x ∈ U) (hy : y ∈ U)
    (hhx : (σ x).label.time = s) (hhy : (σ y).label.time = t') :
    gapPotential U σ ((ord.addFuture s f).addFuture f t') < gapPotential U σ ord := sorry

theorem mintPaysForTimeFixed_dense_false :
    ∃ (U : Finset SignedFormula) (Tmax : Nat),
      ¬ MintPaysForTimeFixed FormalSystem.ProofSystem.FrameClass.Dense U Tmax := sorry

theorem mintPaysForTimeFixed_rtime_false :
    ∃ (U : Finset SignedFormula) (Tmax : Nat),
      ¬ MintPaysForTimeFixed FormalSystem.ProofSystem.FrameClass.RTime U Tmax := sorry

def MintPaysForTimeGap (fc : FormalSystem.ProofSystem.FrameClass) (U : Finset SignedFormula)
    (Tmax : Nat) : Prop := sorry

theorem mintPaysForTimeGap_of_mintPaysForTimeFixed
    {fc : FormalSystem.ProofSystem.FrameClass} {U : Finset SignedFormula} {Tmax : Nat}
    (h : MintPaysForTimeFixed fc U Tmax) : MintPaysForTimeGap fc U Tmax := sorry

theorem mintPaysForTimeGap_of_any (fc : FormalSystem.ProofSystem.FrameClass)
    (U : Finset SignedFormula) (Tmax : Nat) : MintPaysForTimeGap fc U Tmax := sorry

theorem mintPaysForTimeGap_signedUniverse (fc : FormalSystem.ProofSystem.FrameClass)
    (C : Finset Formula) (L : Finset Label) (Tmax : Nat) :
    MintPaysForTimeGap fc (signedUniverse C L) Tmax := sorry

def BudgetStateGap (U : Finset SignedFormula) (Tmax : Nat)
    (σ : SignedFormula → SignedFormula) (b : Branch) (ord : TimeOrdering) : Prop := sorry

def budgetPotentialGap (U : Finset SignedFormula) (Tmax : Nat)
    (σ : SignedFormula → SignedFormula) (b : Branch) (ord : TimeOrdering) : Nat := sorry

def mintPathBoundGap (Ucard Tmax mintBudget : Nat) : Nat := sorry

def mintAwareFuelGap (Ucard Tmax mintBudget D β : Nat) : Nat := sorry

def derivedTmaxGap (kt0 Ucard : Nat) : Nat := sorry

theorem derivedTmaxAt_le_derivedTmaxGap (kt0 Ucard : Nat) :
    derivedTmaxAt kt0 Ucard ≤ derivedTmaxGap kt0 Ucard := sorry

def BudgetedTotalityGap (fc : FormalSystem.ProofSystem.FrameClass)
    (U : Finset SignedFormula) (mintBudget Tmax D β : Nat) : Prop := sorry

theorem expandBranchWithFuel_isSome_of_budget_gap
    {fc : FormalSystem.ProofSystem.FrameClass} {U : Finset SignedFormula}
    {mintBudget Tmax D β : Nat}
    (hβ : 3 ≤ β) (hUcl : UniverseClosedAt fc U) (hD : DifficultyBounded fc U D)
    (harm : ArmSettlement fc) :
    BudgetedTotalityGap fc U mintBudget Tmax D β := sorry

theorem buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse_gap
    {fc : FormalSystem.ProofSystem.FrameClass}
    {C : Finset Formula} {L : Finset Label} {L' β : Nat} (phi : Formula) (hβ : 3 ≤ β)
    (hC : TableauClosed C) (hT : TrichStock C) (hL : TimeMergeClosed L)
    (hlab : UnorderedSuccessorLabelClosed fc L)
    (hSL : StepLengthBounded fc (signedUniverse C L) L')
    (hpb : PostBlockingSettles fc)
    (hseed : ∀ x ∈ seedBranch phi, x ∈ signedUniverse C L) :
    (buildTableauAt phi
        (mintAwareFuelGap (signedUniverse C L).card
          (derivedTmaxGap ((seedBranch phi).knownTimes.toFinset.card)
            (signedUniverse C L).card)
          (10 * (signedUniverse C L).card
            + (signedUniverse C L).card * (signedUniverse C L).card)
          (difficultyCeiling (signedUniverse C L) L') β)
        fc
        (β * mintAwareFuelGap (signedUniverse C L).card
          (derivedTmaxGap ((seedBranch phi).knownTimes.toFinset.card)
            (signedUniverse C L).card)
          (10 * (signedUniverse C L).card
            + (signedUniverse C L).card * (signedUniverse C L).card)
          (difficultyCeiling (signedUniverse C L) L') β)
      ).isSome = true := sorry

end FormalSystem.Metalogic.Decidability
```

## Testing & Validation

- [ ] `bash scripts/check-module-invariants.sh` exits 0 with no FAIL row (the complete gate set).
- [ ] `bash .claude/scripts/lean-sorry-census.sh` reports zero `sorry` in `GapPotential.lean`,
      `MintPaysAssembly.lean` and `FiveComponent.lean`.
- [ ] Every Goals identifier exists and `mcp__lean-lsp__lean_verify` reports its axioms within
      `{propext, Classical.choice, Quot.sound}`; no `native_decide` anywhere in the tree's
      additions.
- [ ] `mintPaysForTimeGap_of_any`'s statement carries no frame-class hypothesis, and
      `buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse_gap`'s carries no `hmint`.
- [ ] `gapPotential_lt_of_density` concludes a strict `<`; no direction lemma was weakened to a
      `≤` to make a proof close.
- [ ] `mintPaysForTimeFixed_dense_false` and `_rtime_false` are decided, not assumed.
- [ ] `mintPaysForTimeFixed_of_not_dense` and the whole `_fixed` terminus family survive unchanged.
- [ ] `md5sum` of `Fuel.lean`, `Saturation.lean` and `Tableau.lean` unchanged; `MintBound.lean`
      diff is additions only.
- [ ] No new `#eval`/`#check`/`#print` under `FormalSystem/` (gate C27), no unscoped
      `maxHeartbeats` (gate C30), no `lemma` keyword (gate C23), no task-number citation (gate C9).

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/GapPotential.lean` (new)
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/FiveComponent.lean` (new)
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/MintPaysAssembly.lean`
  (density bucket and the all-frame-class discharge)
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/Register.lean`
  (C9 entry 26; entries 14, 17, 19, 20 amended)
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`,
  `FormalSystem.lean` (two imports each, additive)
- Prose amendments in `TimeReuse.lean`, `OrientedGate.lean`, `SigmaFixed.lean`,
  `FourComponent.lean`, and the two READMEs
- `specs/464_gappotential_density_measure_component/summaries/01_gappotential-density-component-summary.md`

## Rollback/Contingency

- **Per-phase**: every phase is a separate commit, and phases 1-8 are strictly additive to new
  modules or additive within one existing module, so reverting a single phase is
  `git revert <sha>` with no cross-phase entanglement. `git revert` creates a new commit and
  discards nothing uncommitted, so it needs no snapshot.
- **If a phase's uncommitted work must be discarded** (the rare case `git revert` does not cover):
  take a durable, non-reverting checkpoint first with
  `bash .claude/scripts/git-snapshot.sh 464 --no-revert`, then follow
  `context/contracts/recovery.md`'s rollback rung for the reverting invocation shape. Never run
  `git-snapshot.sh` in its default reverting mode on this shared working tree — a sibling task is
  live this cycle and would lose its uncommitted work.
- **If Phase 3's strict drop cannot be proved**: the task's outcome (b) branch opens. Do **not**
  weaken `gapPotential_lt_of_density` to a `≤`, widen its hypothesis list to make it close, or
  present either as a repair (register entry 7). Instead land a machine-checked impossibility
  result identifying the obstruction precisely, record it as the C9 entry Phase 9 writes, and
  close Phases 5-8 as `[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` record in
  each citing Phase 3's own failing measurement. Outcome (b) is a result, not a failure.
- **If Phase 6's bucket arithmetic will not close exactly**: the fault is in the component, not the
  arithmetic. Do not add slack, a hypothesis, or a frame-class restriction to
  `MintPaysForTimeGap` to make `omega` succeed — re-derive the budget and report the gap.
