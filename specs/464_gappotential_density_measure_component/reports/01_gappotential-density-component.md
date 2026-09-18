# Research Report: Task #464

**Task**: 464 - gapPotential: the density coordinate of the termination measure
**Started**: 2026-09-18T19:16:10Z
**Completed**: 2026-09-18T19:40:00Z
**Effort**: 5 implementation phases, roughly 1,200-1,600 added Lean lines over two new modules plus register and prose amendments
**Dependencies**: 462 (engine-level assembly, landed as `MintBound/MintPaysAssembly.lean`); 463 (file_scope serialization only)
**Sources/Inputs**: - Codebase (`MintBound/*.lean`, `Tableau.lean`, `SignedFormula.lean`, `Fuel.lean`); lean-lsp MCP (`lean_run_code` #eval measurements against the current `Tableau.olean`, no build); literature sub-index (caleiro_2013 §3.1, §3.2, §4.2; venema_2001 sec02; gerth_1995, baier_katoen_2008 and massacci_2000 consulted as analogues only)
**Artifacts**: - specs/464_gappotential_density_measure_component/reports/01_gappotential-density-component.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The outcome is (a), and a sorry-free route exists.** A density component can be defined, it
  drops at every `densityRule` step, and it survives the identification arm. This follows from
  lemmas already in the tree (`TimeOrdering.futureOf_mono`, `futureOf_transport`,
  `mem_futureOf_of_mem_constraints`, `mem_knownTimes_of_mem_futureOf`). Two `#eval` measurements
  on the current engine agree with the design (see Tactic Survey Results).
- **The `U ×ˢ U` shape holds up. The `denseRules` gating is not needed.** The ledger counts pairs
  `(x, y) ∈ U ×ˢ U` whose time pair `((σ x).time, (σ y).time)` is **not yet filled**, meaning no
  time lies strictly between them in `futureOf`. Adding edges only fills pairs, so the count can
  only fall. It therefore goes down or stays the same at every step of every frame class, and
  gating it on `Dense ≤ fc` would only improve the figure. It is not needed for soundness.
- **What makes the design work: count *unfilled pairs*, not *open gaps*.** The rule's own gap-target
  set gets bigger whenever another rule mints a new maximal time, so a ledger built on it would rise
  at ordinary steps. The rule has two filter conjuncts. Only the second one ("no intermediate") is
  monotone, and that is the only one the ledger may use.
- **`MintPaysForTimeFixed` itself is FALSE at `.Dense`/`.RTime`, so "extend its discharge to Dense"
  cannot hold as literally stated.** A concrete run state measures `knownTimes 2→3`,
  `mintPotential 40→40` and `selfGuardPotential 5→5` at the density step, so all three disjuncts
  fail. The correct deliverable is:
  - a decided refutation of `MintPaysForTimeFixed` at `.Dense` and `.RTime`;
  - a repaired predicate `MintPaysForTimeGap` with a fourth disjunct and a direction lemma
    `Fixed → Gap`;
  - a discharge `mintPaysForTimeGap_of_any` at **every** frame class, with no hypothesis;
  - a five-component measure that carries it.
- **The identification-arm hazard does not apply here.** The guard `densityRule` reads never
  mentions `ord.timeCount`, and the entry-15/17 σ-hit wall does not apply either. Both hits the
  drop needs (trigger time `s`, target time `t'`) come from formulas on the branch, via
  `SigmaFixed` and `OrdTimesKnown`, which `MintPaysForTimeFixed` already carries.

## Context & Scope

Researched: the exact firing condition of `densityRule` (`Tableau.lean:1344-1385`). Also the
existing three-disjunct residual `MintPaysForTimeFixed` (`SigmaFixed.lean:355`), the self-guard
ledger that it models (`TimeReuse.lean:465-510`, `OrientedGate.lean:480-860`), and the four-bucket
assembly (`MintPaysAssembly.lean:299-659`). I read C9 register entries 13-20 and 24-25 in full
(`Register.lean:157-915`), plus the named "density residual" subsection (`TimeReuse.lean:736-771`).

Constraints honoured: no `lake build` or `lean_build` (user focus). All Lean evidence below is
`#eval` against the up-to-date `Tableau.olean`, imported alone. I did not import the `MintBound`
modules, whose oleans were stale while another session was rebuilding. None of the refuted routes
(entry 14's re-indexing and rank-only repair, entry 17's σ-hit shape, entry 19 routes 1-3) is
re-attempted.

## Findings

### Codebase Patterns

**The rule.** `densityRule` fires on `T(G ψ)@l` and computes the following:
```
futureTimes := ord.futureOf l.time
gapTargets  := futureTimes.filter fun t' =>
  (ord.futureOf t').isEmpty                                   -- (i) t' maximal
  && !(futureTimes.any fun t'' => (ord.futureOf t'').contains t')  -- (ii) no intermediate
```
On `t' :: _` it mints `f := b.nextTime` and returns
`(.persistent (T(ψ)@f :: gProps), (ord.addFuture l.time f).addFuture f t')`. It carries no
`findApplicableRule` guard. Its guard is the `gapTargets` filter, and the result is
`.notApplicable` when that filter is empty. `expandOnceUnblocked` maps `.persistent` to
`.extended`.

**Why the target set cannot be the ledger.** Conjunct (i) is anti-monotone in reverse. A
`someFuturePos` step that mints a fresh future time creates a new maximal time, so a new gap target
appears. A potential of the form "#open gaps" therefore rises at ordinary steps. Conjunct (ii) is
different. Read positively, it says *filled*, and it is monotone:
```
gapFilled ord s t := (ord.futureOf s).any fun m => (ord.futureOf m).contains t
```
It is the rule's own conjunct (ii) transcribed verbatim, with the polarity inverted, in the same way
that `selfGuardDischarged` transcribes `untlNeg`'s guard.

**Proposed component.**
```
def gapPotential (U : Finset SignedFormula) (σ : SignedFormula → SignedFormula)
    (ord : TimeOrdering) : Nat :=
  ((U ×ˢ U).filter fun p =>
     gapFilled ord (σ p.1).label.time (σ p.2).label.time = false).card
```
Like `selfGuardPotential`, it takes no `Branch`. It depends only on `ord` and σ. Its ceiling is
`U.card * U.card` (`Finset.card_filter_le` + `Finset.card_product`).

**The four facts it needs, each with its template already in the tree:**

1. *Growth (every additive step, including self-guard and witness-guarded mints):* if
   `ord.constraints ⊆ ord'.constraints`, then `gapFilled ord s t → gapFilled ord' s t`. The proof is
   two applications of `TimeOrdering.futureOf_mono` (`Fuel.lean:938`), used exactly as
   `selfGuardDischarged_le_of_grow` uses it (`OrientedGate.lean:500`). `gapPotential_le_of_grow`
   is then `selfGuardPotential_le_of_grow` verbatim. The engine-level ordering growth is
   `expandOnceUnblocked_ord_mono` / `applyRule_ord_mono` (`OrderingTimes.lean:854,889`).
2. *Identification arm (Constraint (F)):* `gapFilled ord s t → gapFilled (ord.identifyTime t₂ t₁)
   (rho t₂ t₁ s) (rho t₂ t₁ t)` under `incomparableB ord (t₁, t₂)` and `IrreflOrd ord`. The proof
   applies `futureOf_transport` (`Invariants.lean:318`) to both memberships, with `m ↦ rho m`
   carrying the witness. `rhoSF` acts on the label's time by exactly this `rho`, so
   `gapPotential_identifyTime` and `_identifyOriented` are `selfGuardPotential_identifyTime` /
   `_identifyOriented` (`OrientedGate.lean:585-615`) with the inner lemma swapped. **Nothing here
   reads `ord.timeCount`**, so the lowering hazard named in the task is absent by construction.
3. *Strict drop at a density step:* suppose `(ord.futureOf s).filter P = t' :: tail`. This is the
   shape `irreflOrd_density_newOrd` (`Invariants.lean:406`) already extracts via `repeat' split`.
   - Before the step, conjunct (ii) gives `gapFilled ord s t' = false`.
   - After the step, `f ∈ ord'.futureOf s` and `t' ∈ ord'.futureOf f` both hold by
     `mem_futureOf_of_mem_constraints` (two direct edges, so the fuel of 100 is not reached). That
     gives `gapFilled ord' s t' = true`.
   - The column is `(sf, y)`, where `sf` is the trigger and `y ∈ b` is any formula at time `t'`.
     `t' ∈ b.knownTimes` holds by `mem_knownTimes_of_mem_futureOf` (`TimeCensus.lean:144`, under
     `OrdTimesKnown`). Confinement puts both in `U`, and `SigmaFixed` gives `σ sf = sf`,
     `σ y = y`.
   - Every other column only grows by fact 1. The result is a strict drop, by
     `Finset.card_lt_card` on a strict subset.
4. *Budget arithmetic at the density step:* the density step's contributions are:
   - `|kt nb| ≤ |kt b| + 1` (`pickBranches_knownTimes_card_le_succ`);
   - `mintPotential` does not rise (`mintPotential_le_of_grow`);
   - `selfGuardPotential` does not rise (`selfGuardPotential_le_of_grow`);
   - `gapPotential` drops by at least 1.

   So `mintTimeBudget + selfGuardPotential + gapPotential` does not rise, exactly as in bucket C.

**Why σ is harmless here, unlike entries 15/17.** The column hit is at the *trigger's* time and the
*target's* time. Both are times of formulas that are on the branch now, not a re-issued retired time.
Entry 18's arm reorientation removed re-issue from the engine path, and `SigmaFixed` (entry 20's
repair) covers every branch formula. Entry 17's `selfGuard_no_column_at_retired_time` cannot occur,
because the trigger is itself a branch formula fixed by σ.

### External Resources

- **caleiro_2013 §3.1, condition (SVDns)**, `sec03_31-mosaics.md:80`: "there exists Ω ∈ Points(S)
  such that (Γ, Ω), (Ω, Δ) ∈ S". Density is a condition on **pairs** of points, cured by inserting a
  middle point. **§3.2** (`sec04_32-mosaics-and-satisfiability.md:235-245`) cures it "between all
  the neighboring points". A cured pair stays cured, and the finite point stock bounds the number
  of pairs. That is precisely the monotone `U ×ˢ U` filled-pair ledger, and it confirms that the
  source keeps density as a separate vertical condition (already cited at `TimeReuse.lean:760`).
  **§4.2** (`sec06_42-mosaic-based-tableaux.md:277-285`) obtains SVDns through the DnsR tableau
  rule, one intermediate per pair.
- **venema_2001 sec02** (`validity-and-definability.md:5-7`): density corresponds to `Fq → FFq`,
  i.e. an intermediate point *per pair* `s < t`. The converted chunk set for venema_2001 stops at
  the interval-based chapter (`sec04_interval-based-temporal-logic.md`). It carries no
  tableau-termination argument for density, so it confirms the pair semantics and nothing more.
- **gerth_1995 / baier_katoen_2008**: closure-set tableaux get termination from a finite
  node-label space. The analogue here is the fixed index set `U ×ˢ U` under an evolving,
  non-monotone time set, with the renaming σ keeping the index fixed across identifications. This
  is the same device `mintPotential` and `selfGuardPotential` already use.
- **massacci_2000**: its rule bounding is one application per (rule, premise-label). The present
  bound is one fill per time pair, and it is the same kind of argument.

### Recommendations

Outcome (a). Suggested phase decomposition, all additive: two new modules under `MintBound/`,
aggregator imports, and register/prose amendments. `Fuel.lean`, `Saturation.lean` and
`Tableau.lean` are untouched.

1. **`MintBound/GapPotential.lean`** (imports `MintPaysAssembly`). Declares `gapFilled`,
   `gapPotential`, `gapPotential_le_sq`, `gapFilled_le_of_grow`, `gapPotential_le_of_grow`,
   `gapFilled_identifyTime`, `gapPotential_identifyTime`, `gapPotential_identifyOriented`, an
   `applyRule .densityRule` inversion (trigger shape via `isApplicable`, result shape, new ordering,
   head-of-filter facts), and `gapPotential_lt_of_density`.
2. **The companion refutation.** `mintPaysForTimeFixed_dense_false` and `_rtime_false`, a
   `decide`/`decide +kernel` witness at the measured vehicle (see the survey table). Ideally also
   at a concrete `signedUniverse C L`. Record it as **C9 entry 26**: the literal extension to
   `.Dense` is refuted, and the repair is named. This is the "(b)-shaped" half. It does not replace
   (a).
3. **`MintPaysForTimeGap`**: `MintPaysForTimeFixed`'s three disjuncts verbatim, plus a fourth,
   `mintTimeBudget' + selfGuard' + gap' ≤ mintTimeBudget + selfGuard + gap ∧ gap' < gap`. It lands
   together with the direction lemma `mintPaysForTimeGap_of_mintPaysForTimeFixed` (weaker
   predicate, so each restatement is a strengthening; see the entry-7 gate). Bucket D becomes
   `mintPays_bucketD_density`, and `pickBranches_mintPaysGap` drops `hfc`. The results are
   `mintPaysForTimeGap_of_any` (every `fc`, arbitrary `U`) and its `signedUniverse C L` form,
   which is nonempty whenever `C` and `L` are.
4. **Five-component measure (`MintBound/FiveComponent.lean` or a section of the same module).**
   - `BudgetStateGap`: `BudgetStateFixed` with the clause
     `mintTimeBudget + selfGuardPotential + gapPotential ≤ Tmax`.
   - `budgetPotentialGap := budgetPotentialAt + (2·(Tmax²+1) + |U|) · gapPotential`, the same
     weight argument as `budgetPotentialAt`.
   - The step lemmas at unordered and `splitOrdered` steps. At every non-density step gap
     non-increase is fact 1, and at arm 3 it is fact 2.
   - `derivedTmaxGap := kt0 + 10·|U| + |U|²`, with the enlargement lemmas
     `derivedTmaxAt_le_derivedTmaxGap` and `mintAwareFuelAt_le_…`.
   - The termini restated at the new state and predicate.
5. **Documentation.** Amend register entries 14, 17, 19 and 20 in place, where they say
   "`gapPotential` remains implemented nowhere", so they say the coordinate is closed. Also amend
   the density-residual subsection, the READMEs, and the aggregator docstring. Keep the
   de-vacuification disclaimer from `MintPaysAssembly.lean`: none of this makes any terminus
   non-vacuous. Entries 9, 11 and 22 still refute co-hypotheses.

## Decisions

- Keep `U ×ˢ U` indexing. Index by σ-image *times*, not formulas, as `selfGuardPotential` does. The
  cheaper index `{x ∈ U | x is T(G _)} ×ˢ U` is also sound and shrinks the figure. Optional.
- Do **not** gate on `denseRules` in the definition. Monotonicity holds at every class, and gating
  adds `fc` to a measure that currently has no `fc` parameter. The same applies to the figure
  enlargement at `.Base`/`.ZTime`: it is optional. The existing four-component termini remain
  available there.
- Deliver the refutation of `MintPaysForTimeFixed` at `.Dense` alongside the repair, because the
  task's literal "extend the `MintPaysForTimeFixed` discharge" is false.

## Risks & Mitigations

- **Kernel cost of the refutation vehicle** (engine step plus `futureOf` fuel of 100). Existing
  witnesses (`gate_is_reissue_hazard`, `orientedGate_*`) decide comparable engine steps. Use
  `set_option maxHeartbeats` and `decide +kernel` if needed; it adds no axiom. Never use
  `native_decide`.
- **The density-inversion lemma is a large `split`.** Use the `repeat' split` pattern from
  `applyRule_irreflOrd` (`maxHeartbeats 4000000`) to expose `heq : filter = t' :: tail`.
- **Membership of the `U`-side for `y`.** `t'` must carry a branch formula. This comes from
  `OrdTimesKnown` (`RunInvariant.2`), and the predicate already quantifies `RunInvariant`.
- **The engine could fill a gap and then un-fill it.** This is impossible. Edges are never removed
  except at arm 3, and arm 3 is transported.
- **`futureOf` fuel (100).** Only paths of at most 100 layers count. Growth and transport both
  preserve path length, and the drop uses two length-1 edges, so fuel never interferes.

## Tactic Survey Results

All results are `#eval` measurements via `lean_run_code` importing `FormalSystem.Metalogic.Decidability.Tableau` only. They are checked computations, not kernel proofs.

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| The engine picks `densityRule` from a plain run | `#eval` of `expandOnceUnblocked` iterated at `.Dense` from `[T(Gp)@⟨0,0⟩, T(p)@⟨0,1⟩]`, ord `[(0,1)]` | success: step 4 is `densityRule @t0`, and ord becomes `[(2,1),(0,2),(0,1)]` | steps 1-3: negPos, someFutureNeg, impNeg |
| All three `MintPaysForTimeFixed` disjuncts fail at that step (σ = id, U = the pre-step branch, `|U| = 5`) | `#eval` | knownTimes `2→3`, mintPotential `40→40`, selfGuardPotential `5→5` | the refutation vehicle for Phase 2 |
| gapPotential drops there | `#eval` | `25→19` (strict) | combined budget `72→67` |
| gapPotential never rises at additive steps; drops at every density step | `#eval` over a 60-step `.Dense` run of the row-B formula `(Fp∧Fq)→(F(p∧Fq)∨F(p∧q)∨F(q∧Fp))`, time-pair form | 0 rises; 3 density steps, each a drop of 1 | arm 3 is not exercised (no ordered split reached); covered by the transport proof |
| Proof tactics | not attempted | N/A | no build permitted; the proof templates are the named `selfGuard*` lemmas |

## Context Extension Recommendations

- **Topic**: monotone-ledger design for tableau termination measures
- **Gap**: no context file records the rule this line of work keeps rediscovering. A measure
  component must transcribe the *monotone* half of a rule's guard, with its polarity inverted, and
  never the guard's target set.
- **Recommendation**: add a short pattern note under `.claude/context/project/lean4/patterns/`
  (via the source store `agent-system/extensions/lean/`) citing `selfGuardDischarged` and
  `gapFilled` as the two instances.

## Appendix

- Files read: `MintBound/{Register,TimeReuse,OrientedGate,SigmaFixed,FourComponent,MintPaysAssembly,Measure,Invariants}.lean` (relevant ranges), `Tableau.lean:375-390,1320-1400,1610-1670,1800-1840,2284-2300`, `SignedFormula.lean:600-720`.
- Literature: `~/Projects/Literature/sources/caleiro_2013/sec03,sec04,sec06`, `venema_2001/sec02`.
- Search: no rate-limited Mathlib search was needed. All required lemmas are local and were
  verified by grep: `futureOf_mono` (Fuel.lean:938), `futureOf_transport`,
  `mem_futureOf_of_mem_constraints`, `mem_knownTimes_of_mem_futureOf`,
  `expandOnceUnblocked_ord_mono`, and `pickBranches_knownTimes_card_le_succ`.
