# Research Report: The Fourth Termination-Measure Component for `MintPaysForTime`

- **Task**: 436 — `fourth_termination_measure_component`
- **Type**: lean4 | **Mode**: `--hard` | **Literature**: `--lit` (`SUBINDEX_PRESENT`, 40 entries, `sparse=false`)
- **Date**: 2026-08-07
- **Session**: `sess_1786120320_eb4769`
- **Reference-grounding tier**: **Tier 1** (literature-backed) — five curated sources named in the
  dispatch; the 5-column mapping table is the first artifact of `## Findings`.
- **Scope**: research only. No `.lean` file was modified. Every claim below is cited to a
  `file:line` in this repository or to an absolute chunk path in the Literature corpus.

---

## 1. Do-not-re-attempt register: read and confirmed

I read all sixteen entries of section C9,
`FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean:7355-7552`, in full.
Enumeration of the closed routes, one line each, so that the closure is on the record:

| # | Closed route | Refuting witness / cited authority |
|---|---|---|
| 1 | `buildTableau_isSome` unconditionally | `maxBranches = 50000` guard; only `buildTableauAt_isSome_of_budget` is true |
| 2 | `buildTableau_isSome_of_budget` with only the branch budget quantified | measured: `φ = F(G p)` returns `none`, cause `resolveOpenArm = none` |
| 3 | a `.splitOrdered` cardinality twin of `expandOnceUnblocked_split_card_lt` | arm 3 merges times and can shrink the branch |
| 4 | an `allClosed` `iff` between `buildTableauAt` and `buildTableau` | genuine verdict difference; only `buildTableauAt_allClosed_imp` holds |
| 5 | `IrreflOrd`-free `witnessPresent_identifyTime` | `witnessPresent_identifyTime_unconditional_false` |
| 6 | a lower bound on `(b.identifyTime t₂ t₁).toFinset.card` | dead by definition; only `shrinkage_le_card` (upper) is available |
| 7 | `OrdTimesLeMaxTime` across the identification arm | `ordTimes_identifyTime_arm3_false`; repair is `OrdTimesKnown` |
| 8 | `BudgetedTotality` at `β`-linear budget alone | `budgetedTotality_beta_zero_false`; needs `β ≥ 1`, `β ≥ 3` |
| 9 | `DifficultyBounded fc U D` at any `D` | `difficultyBounded_multiplicity_false`; repair is `StepLengthBounded` |
| 10 | clause 2 of `UniverseClosed` at nonempty `U` | `universeClosed_identify_retime_false`; repair is `UniverseClosedAt` |
| 11 | clause 1 of `UniverseClosed`/`UniverseClosedAt`, and any `L`-side repair | `universeClosed_fresh_world_escapes`, `freshWorldHeadroom_not_universal` |
| 12 | repairing clause 2 by constraining `t₂`, or both `t₁` and `t₂` | not false but needlessly weaker; `timeMergeClosed_identifyTime_signedUniverse` |
| 13 | "not in `ruleMintsFreshLabel`" read as "introduces no time" | `freshTimeRules_incomparable_freshLabelRules` |
| **14** | **`MintPaysForTime` as stated, plus BOTH obvious repairs** | see below |
| 15 | "time reuse cannot happen" — it can, and the σ-hit hypothesis is **false** | `nextTime_reissues_retired_time`, `reuse_driven_through_engine`, `mint_not_in_rhoSF_image` |
| 16 | unconditional `applyRule_emitted_time_mem` without `OrdTimesKnown` | `applyRule_emitted_time_mem_ordTimesKnown_needed` |

**Entry 14, the two routes this task must not re-attempt** (`MintBound.lean:7501-7525`):

- **Route (1) — re-index `mintPotential` on `freshTimeRules`.** Closed by
  `witnessPresent_eq_false_of_not_freshLabel` (`MintBound.lean:7042`): `witnessPresent`'s match
  has exactly eight arms, one per `freshLabelRules` member, so the three added columns are
  permanently `false`, contribute a constant `3 · |U|`, and never move.
  **Not re-attempted below.** Candidate 2 introduces a *new* predicate over a *new* index set; it
  does not widen `mintPotential`'s index set and does not reuse `witnessPresent`. §6.4 states why
  this is a different move rather than a disguised re-attempt.
- **Route (2) — drop disjunct 1's cardinality conjunct, keep the ordering-rank conjunct.** Closed
  by `splitOrderedRank_lt_of_knownTimes_lt` (`MintBound.lean:7192`) plus
  `mintPaysForTime_rank_repair_false` (`MintBound.lean:7217`): `splitOrderedRank`'s base
  `Tmax*Tmax + 1` (`Fuel.lean:2395-2396`) is by construction one more than `incompPairs`' range
  (`incompPairs_card_le`, `Fuel.lean:2382`), so **every** time-minting step strictly raises the
  rank. **Not re-attempted below.** §5 in fact *uses* this fact in the opposite direction, as the
  numerator of a weight-feasibility bound, which is a consumption of the closed result rather than
  a re-attempt of it.

Additionally, one *near-miss* route the source already refutes in prose and which I therefore do
not propose: **"branch times with empty forward reach"** as a potential
(`MintBound.lean:7166-7168`) — the `untlNeg` arm removes the trigger's empty future and mints a
fresh time whose future is empty, net change zero. Candidate 2 is **not** this potential; the
difference is stated explicitly in §6.4.

---

## 2. Established shapes (file:line for each)

| Object | Location | Shape (verbatim or condensed) |
|---|---|---|
| `MintPaysForTime` | `MintBound.lean:4031-4042` | `∀ σ b ord tr, RunInvariant b ord → (∀ x ∈ b, x ∈ U) → ∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1, (knownTimes ≤ ∧ rank ≤) ∨ (mintTimeBudget ≤ ∧ mintPotential <)` |
| `mintPotential` | `MintBound.lean:2971-2973` | `((freshLabelRules ×ˢ U).filter (fun p => witnessPresent p.1 (σ p.2) b ord = false)).card` |
| `mintPotential_le_eight_mul` | `MintBound.lean:2978` | `≤ 8 * U.card` |
| `mintPotential_le_of_grow` | `MintBound.lean:2988` | branch-grow + ord-grow ⇒ non-increasing |
| `mintTimeBudget` | `MintBound.lean:3867-3869` | `b.knownTimes.toFinset.card + mintPotential U σ b ord` |
| `extensionAllowance` | `MintBound.lean:3877-3879` | `U.card + mintTimeBudget * U.card - b.toFinset.card` |
| `budgetPotential` | `MintBound.lean:3883-3887` | `2*(Tmax²+1) * mintPotential + extensionAllowance + splitOrderedRank` |
| `splitOrderedRank` | `Fuel.lean:2395-2396` | `b.knownTimes.toFinset.card * (Tmax*Tmax+1) + (incompPairs b ord).card` |
| `incompPairs` | `Fuel.lean:1048-1049` | `((knownTimes ×ˢ knownTimes).filter (incomparableB ord)).toFinset` |
| `incompPairs_card_le` | `Fuel.lean:2382` | `≤ knownTimes.card * knownTimes.card` |
| `UniverseClosedAt` | `MintBound.lean:5318-5322` | clause 1 verbatim; clause 2 with `t₁ ∈ b.knownTimes` |
| `TimeOrdering.identifyTime` | `SignedFormula.lean:705-710` | `filterMap` renaming with `a' == b' → none`, then `eraseDups` |
| `Branch.identifyTime` | `SignedFormula.lean:364-367` | `(b.map (retime src→tgt)).eraseDups` |
| `Branch.knownTimes` / `maxTime` / `nextTime` | `SignedFormula.lean:349-381` | `(b.map (·.label.time)).eraseDups` / `foldl max 0` / `maxTime + 1` |
| `TimeOrdering.timeCount` | `SignedFormula.lean:788-792` | count of distinct endpoints in `ord.constraints` |
| `TimeOrdering.futureOf` / `pastOf` | `SignedFormula.lean:776-783` | BFS transitive closure, fuel `100` |
| `futureOf_mono` / `pastOf_mono` | `Fuel.lean:914`, `Fuel.lean:926` | monotone in the constraint list |
| `firstIncomparablePair_spec` | `Fuel.lean:1023-1026` | `t₁ ∈ knownTimes ∧ t₂ ∈ knownTimes ∧ t₂ ≠ t₁ ∧ t₂ ∉ futureOf t₁ ∧ t₂ ∉ pastOf t₁` |
| **`identifyTime_no_collapse`** | **`MintBound.lean:231-251`** | **on an incomparable pair under `IrreflOrd`, `rho t₂ t₁ a ≠ rho t₂ t₁ b` for every constraint `(a,b)` — no constraint is dropped** |
| `mem_futureOf_of_mem_constraints` / `mem_pastOf_of_mem_constraints` | `MintBound.lean:215`, `223` | edge ⇒ reachability, both directions |
| `RunInvariant` / `IrreflOrd` / `OrdTimesKnown` | `MintBound.lean:1675-1676`, `71`, `1260-1261` | `IrreflOrd ∧ OrdTimesKnown`; `OrdTimesKnown` = every constraint endpoint ∈ `b.knownTimes` |
| `nextTime_reissues_retired_time` | `MintBound.lean:7309` | decided: `firstIncomparablePair` merges `2` away, post-identification `nextTime = 2` |
| `reuse_driven_through_engine` | `MintBound.lean:7351` | decided: two `expandOnceUnblocked` steps later time `2` is back on the branch |
| `witnessPresent_eq_false_of_not_freshLabel` | `MintBound.lean:7042` | `witnessPresent` identically `false` outside `freshLabelRules` |
| `splitOrderedRank_lt_of_knownTimes_lt` | `MintBound.lean:7192` | one extra known time strictly raises the rank |
| `mintPaysForTime_rank_repair_false` | `MintBound.lean:7217` | the weakened predicate is false, every `fc`, every `Tmax ≥ 3` |
| `witnessPresent_identifyTime` | `MintBound.lean:644` | preserved across identification **under `IrreflOrd`** |
| `unorderedSuccessorBranches` | `MintBound.lean:1048-1051` | `.extended nb => [nb] \| .split bs => bs \| _ => []` — **`.splitOrdered` excluded by construction** |
| `RuleResult → ExpansionResult` mapping | `MintBound.lean:1067-1072` | `.linear`/`.persistent → .extended`; `.branching → .split`; `.branchingOrdered → .splitOrdered` |
| `budgetPotential_step_unordered` | `MintBound.lean:4693-4758` | consumes `MintPaysForTime` |
| `budgetPotential_step_splitOrdered` | `MintBound.lean:4768-4835` | **does not** consume `MintPaysForTime`; arm 3's strict drop comes from `hrank` |

### The three self-guarded rules, guards read off `applyRule`

| Rule | Guard (source) | Emission shape | `ExpansionResult` |
|---|---|---|---|
| `untlNeg` ACTIVE | `futureTimes.isEmpty && timeOrd.timeCount > 0 && timeOrd.timeCount < 4` where `futureTimes = timeOrd.futureOf l.time` — `Tableau.lean:1016, 1063` | `newOrd = timeOrd.addFuture l.time freshTime`, `freshTime = branch.nextTime` (`Tableau.lean:1069-1071`) | `.branching [branch1, branch2]` (`Tableau.lean:1133`) → `.split` |
| `snceNeg` ACTIVE | past mirror; `pastTimes = timeOrd.pastOf l.time` (`Tableau.lean:1147`), same `timeCount` cap (`Tableau.lean:1167` comment "Same guard as untlNeg active case above") | `addPast` mirror | `.branching` → `.split` |
| `densityRule` | `gapTargets = futureTimes.filter (fun t' => (futureOf t').isEmpty && !(futureTimes.any fun t'' => (futureOf t'').contains t'))`; `[] → .notApplicable` (`Tableau.lean:1363-1368`) | `newOrd = (addFuture l.time freshTime).addFuture freshTime t'` (`Tableau.lean:1373`) | `.persistent (witness :: gProps)` (`Tableau.lean:1385`) → **`.extended`** |

Two consequences worth stating because they are easy to get wrong:

1. **`densityRule` returns `.persistent`, which maps to `.extended`** (`MintBound.lean:1071`), so it
   *is* inside `unorderedSuccessorBranches` and *is* in `MintPaysForTime`'s scope. It is not
   excluded by being non-branching.
2. **`densityRule` is frame-class gated**: `denseRules` (`Tableau.lean:1593`) is included only when
   `decide (FrameClass.Dense ≤ fc)` (`Tableau.lean:1626`). `untlNeg`/`snceNeg` are in `carrierBase`
   and available at every frame class — which is exactly why the Phase 4 verdict picked `untlNeg`
   as the frame-class-universal refutation vehicle.

---

## 3. Two structural findings that reshape the problem

### 3.1 `MintPaysForTime` never sees the identification arm; `budgetPotential` does

`unorderedSuccessorBranches` is `.extended`/`.split` only, with `.splitOrdered` excluded *by
construction* and by explicit docstring intent (`MintBound.lean:1043-1051`). Correspondingly,
`budgetPotential_step_splitOrdered` (`MintBound.lean:4768-4775`) carries no `MintPaysForTime`
hypothesis at all.

So the dispatch's phrase "preserved across `TimeOrdering.identifyTime`" is **not** a requirement on
the repaired `MintPaysForTime` statement. It is a requirement on the *fourth component of
`budgetPotential`*, because adding a component forces `budgetPotential_step_splitOrdered` to be
re-proved. This matters for phase sequencing: the repaired predicate and the re-proof of the
splitOrdered step are two separable obligations, and the second is where a candidate dies.

### 3.2 The arm-3 margin theorem — a hard feasibility constraint on any fourth component

Read `budgetPotential_step_splitOrdered`'s arm-3 case (`MintBound.lean:4812-4835`). The strict
inequality is closed by `omega` from exactly two facts:

- `hrk : splitOrderedRank` at the arm `<` `splitOrderedRank` at `(b, ord)` — margin **≥ 1**;
- `hEmul`/`hEexp`: `extensionAllowance` is **non-increasing**, because one unit of `mintTimeBudget`
  is worth `U.card` and the branch cannot shrink by more than `U.card`
  (`card_le_of_subset_universe`, used at `MintBound.lean:4818-4819`) — margin **0**.

So the *guaranteed* strict-drop margin at the identification arm is one unit of `splitOrderedRank`.
Now the other side. At a step that mints a time, `splitOrderedRank` **rises** by up to
`(Tmax*Tmax+1) + Tmax*Tmax = 2*Tmax*Tmax + 1` (first summand by `splitOrderedRank`'s definition,
second bounded by `incompPairs_card_le` plus the carried `hkT`). A fourth component `C` that pays
for a self-guarded mint by dropping one unit must therefore carry weight

> `W ≥ 2*Tmax*Tmax + 1`.

If that same `C` **rises** by even one unit at the identification arm, the arm-3 obligation needs a
drop of `W ≥ 2*Tmax*Tmax + 1` elsewhere, against a guaranteed margin of `1`. Sharpening the margin
does not rescue it: the best available sharpening is `≥ 2*Tmax + 1` (from
`knownTimes.card` dropping by ≥1, `incompPairs(b) ≥ 1` since the trigger pair is incomparable, and
`incompPairs(nb) ≤ (k-1)²`), and `2*Tmax + 1 < 2*Tmax*Tmax + 1` for every `Tmax ≥ 2`.

**Constraint (F).** *Any fourth component of `budgetPotential` must be non-increasing at the
identification arm. It may not rise even by one unit.* This is not a stylistic preference; it is
forced by the weights already fixed in `budgetPotential` and by the arm-3 margin. Every candidate
below is judged first against (F).

**Corollary (F′) — the whole family of `knownTimes.card`-affine components is dead.** Any `C` that
is an affine function of `b.knownTimes.toFinset.card` alone rises at exactly the steps where
`knownTimes.card` falls and falls where it rises. Since a self-guarded mint raises it
(`knownTimes_card_le_succ_of_unorderedSuccessor`, and the refutation configuration in
`mintPaysForTime_untlNeg_false` shows the rise is real) and the identification arm lowers it
(`knownTimes_card_lt_identifyTime`, `Fuel.lean:1971`), no sign of coefficient satisfies both. This
is a one-line reason why the problem is hard and why Candidate 1 below fails.

---

## 4. Literature grounding (H3, 5-column mapping table)

Chunk paths are absolute. `caleiro_2013` is `provenance_fidelity: verified_conversion`;
`massacci_2000_single_step_tableaux_for_modal_logics` is `verified_conversion` (confirmed by
`literature-search.sh` result metadata). `baier_katoen_2008` and `venema_2001` returned no
fidelity flag on the queries I ran — I mark those rows' confidence accordingly and I do **not**
rest any load-bearing design decision on them alone.

| Source | Section / chunk | Claim drawn | Intended Lean shape | Confidence |
|---|---|---|---|---|
| Caleiro–Viganò–Volpe 2013 | `/home/benjamin/Projects/Literature/sources/caleiro_2013/sec03_31-mosaics.md:18-21, 26-31, 42-55` | A mosaic is a *pair of points*, a point is a subset of a **finite closure set `Λ`** closed under subformulas and single negation. The whole bound is over `Λ`, never over the number of time points. | The analogue of `Λ` in this development is the confinement universe `U : Finset SignedFormula`; a candidate's index set must be `U`-derived and **fixed across the run**, exactly as `mintPotential`'s `freshLabelRules ×ˢ U` is (`MintBound.lean:2973`). | High — read verbatim, verified_conversion |
| Caleiro–Viganò–Volpe 2013 | `.../sec07_43-decidability-via-mosaics.md` (Thm 4.11 and the closing remark) | Decidability follows from `Λ` finite ⇒ finitely many mosaics; and the tableau-side decision procedure requires "properly avoiding the **repeated curing of the same defect**". | "Curing a defect" is precisely `witnessPresent` turning from `false` to `true`; the fourth component must be a *second* defect-curing ledger with its own defect notion, not a widening of the first. | High — read verbatim |
| Caleiro–Viganò–Volpe 2013 | `.../sec03_31-mosaics.md:80` (SVDns) | The **density** saturation condition (SVDns) is a *separate* saturation clause from the eventuality clauses (SV1–SV4). | `densityRule`'s obligation is a separate coordinate from `untlNeg`/`snceNeg`'s, and should be a separate component rather than three columns of one potential. This is the literature's own decomposition, and it matches what §6.3 finds independently. | High — read verbatim |
| Massacci 2000 | `/home/benjamin/Projects/Literature/sources/massacci_2000_single_step_tableaux_for_modal_logics/chunk_0028.md:35-37`, `chunk_0029.md:3-4`, `chunk_0030.md:1-8, 28-31` | **Technique 8.3**: the π-rule (the existential/witness-minting rule) is applied only to prefixes shorter than a height bound `hb_L` computed from the *formula*; termination (Lemma 8.3, Thm 8.4) follows because the longest non-prunable prefix chain has length `hb_L = 2 + d + n × p`. | This is the exact template for `untlNeg`/`snceNeg`'s `timeOrd.timeCount < 4` guard (`Tableau.lean:1063`). The lesson transferred is *not* to measure the cap directly (the cap is state-side and `identifyTime` lowers it) but to measure **the rule's own self-discharge**: after firing, the rule's precondition is permanently false at that prefix. | High — read verbatim, verified_conversion |
| Massacci 2000 | `chunk_0026.md:20` (Technique 8.2) | "Before reducing a π-formula, check whether the corresponding [reduction already exists]" — the defect-already-cured test. | Exactly the `witnessPresent` idiom, and the shape a new `selfGuardDischarged` predicate should copy. | High — read verbatim |
| Gerth et al. 1995 / Baier–Katoen 2008 | `baier_katoen_2008` chunk `2cbdea06b931a75d` (GNBA construction, Thm 5.37) and `6887c5785c91627c` (elementary sets, Def 5.35) | The LTL automaton's state space is the set of **elementary subsets of `closure(φ)`** — a bound over a finite formula closure, not over an unboundedly growing index/time set. | Same conclusion as the Caleiro row: the ceiling must be `≤ k * U.card` for a fixed small `k`, mirroring `mintPotential_le_eight_mul` (`MintBound.lean:2978`). | Medium — retrieved via FTS snippet, chunk not read end-to-end; no fidelity flag reported. Not load-bearing on its own. |
| Venema 2001 §5 | `/home/benjamin/Projects/Literature/sources/venema_2001/` (interval-based temporal logic) | Interval/gap-based reasoning treats a *gap between two points* as the unit of accounting. | The `densityRule` coordinate should be indexed by **pairs** of times (source, maximal target), not by single times — see Candidate 3. | **Low/UNVERIFIED** — I did not read this chunk end-to-end and the sub-index entry carries no fidelity guarantee I confirmed. The pair-indexing conclusion is independently forced by `densityRule`'s own docstring (`Tableau.lean:1339-1356`), which is the citation I actually rely on. |
| Blackburn–de Rijke–Venema 2002 §6.4-6.5 | `blackburn_2002_ch06_sec04-05` | Textbook cross-check on mosaic mechanics. | Cross-check only; no design decision rests on it. | **Not consulted this dispatch** — recorded as an unfilled cross-check, not as a source I am claiming. |

**Literature Proof Structure (Tier 1).** The step map the corpus supplies for this task is short
and I state it plainly rather than inflating it:

1. Fix a finite closure `Λ` (here: `U`), closed enough that every object the procedure creates
   lives in it. *(Caleiro sec03; already discharged here by the confinement hypothesis
   `∀ x ∈ b, x ∈ U` and `UniverseClosedAt` clause 1.)*
2. For each rule class that creates a new object, identify a **defect** in `Λ`-indexed terms whose
   curing is (a) monotone under the procedure's growth steps and (b) permanent. *(Caleiro sec07's
   "avoid repeated curing of the same defect"; Massacci T.8.2.)*
3. Bound the number of applications of that rule class by the number of curable defects.
   *(Massacci T.8.3 / Lemma 8.3.)*
4. Handle density as a **separate** saturation clause with its own defect notion.
   *(Caleiro sec03 SVDns, listed apart from SV1–SV4.)*

Step 2(b) — *permanence* — is where this development's problem lives, because
`TimeOrdering.identifyTime` is a step the literature's procedures do not have. No corpus source
addresses an identification/merge step; the mosaic method never merges points. **I state this as a
gap rather than papering over it**: the identification-preservation arguments in §6 are
repo-internal and are not literature-supported.

---

## 5. Candidate design space

Three candidates, from three distinct literature patterns, each answered against the five required
questions. All are stated against the existing signature conventions
(`U : Finset SignedFormula`, `σ : SignedFormula → SignedFormula`, `b : Branch`,
`ord : TimeOrdering`), mirroring `mintPotential`.

---

### 6.1 Candidate 1 — Closure-set time-slot deficit *(pattern: closure-set potential; Gerth/Baier–Katoen + Caleiro Λ-finiteness)*

**Definition sketch.**

```lean
def timeSlots (U : Finset SignedFormula) : Finset TimeIndex :=
  U.image (fun x => x.label.time)

def timeSlotDeficit (U : Finset SignedFormula) (b : Branch) : Nat :=
  (timeSlots U \ b.knownTimes.toFinset).card
```

**Why it would pay for all three rules.** Under confinement, `b.knownTimes.toFinset ⊆ timeSlots U`
(from `∀ x ∈ b, x ∈ U` plus `Branch.knownTimes`'s definition, `SignedFormula.lean:349-350`), and
under `UniverseClosedAt` clause 1 the successor is confined too, so the minted `b.nextTime` is a
member of `timeSlots U`. Every one of the nine `freshTimeRules` — including all three self-guarded
ones — adds a genuinely new known time, so the deficit strictly drops by ≥1. It is the only
candidate here that covers all three rules with a single uniform argument.

**Preservation across `identifyTime`: NO, and provably so.** `src_not_mem_knownTimes_identifyTime`
(`Fuel.lean:1947`) and `knownTimes_card_lt_identifyTime` (`Fuel.lean:1971`) say the retired time
leaves `knownTimes` and the count strictly drops, so `timeSlotDeficit` **rises by exactly 1** at
arm 3. By Constraint (F) of §3.2, this is fatal: the component needs weight `≥ 2*Tmax*Tmax + 1` to
pay for a mint, and its arm-3 rise then demands a drop of that size against a margin of at most
`2*Tmax + 1`.

Worse, it is redundant as well as infeasible: since `knownTimes ⊆ timeSlots U`,
`timeSlotDeficit U b = |timeSlots U| − b.knownTimes.toFinset.card` exactly, so adding
`W * timeSlotDeficit` to `budgetPotential` is *literally* re-coefficienting `splitOrderedRank`'s
first summand by `(Tmax*Tmax+1) − W`. That is Corollary (F′) instantiated. **Reject.**

**Direction lemma.** Would have been a *weakening* of `MintPaysForTime` (a third disjunct), hence
a strengthening of every theorem stated against it — the `universeClosedAt_of_universeClosed`
direction (`MintBound.lean:5332`). Moot given the rejection.

**New hypothesis leaked into the terminus.** None: `timeSlots U` is computed from `U`, and the
containment `knownTimes ⊆ timeSlots U` follows from the confinement hypothesis already carried by
`BudgetState` (`MintBound.lean:3892-3894`). Clean, but irrelevant.

---

### 6.2 Candidate 2 — Self-guard discharge potential *(pattern: Massacci T.8.2/8.3 prefix-cap + Caleiro's defect-curing; **RECOMMENDED**)*

**Definition sketch.**

```lean
/-- The two frame-class-universal self-guarded minting rules. Deliberately NOT
    `freshTimeRules` and NOT a widening of `freshLabelRules`. -/
def selfGuardRules : Finset TableauRule := {TableauRule.untlNeg, TableauRule.snceNeg}

/-- The rule's OWN guard, read off `applyRule`, in the "already discharged" polarity.
    Not `witnessPresent`, and it does not call `witnessPresent`. -/
def selfGuardDischarged (r : TableauRule) (sf : SignedFormula) (ord : TimeOrdering) : Bool :=
  match r with
  | .untlNeg  => !(ord.futureOf sf.label.time).isEmpty
  | .snceNeg  => !(ord.pastOf   sf.label.time).isEmpty
  | _         => true

def selfGuardPotential (U : Finset SignedFormula) (σ : SignedFormula → SignedFormula)
    (ord : TimeOrdering) : Nat :=
  ((selfGuardRules ×ˢ U).filter (fun p => selfGuardDischarged p.1 (σ p.2) ord = false)).card
```

Note the `_ => true` catch-all: the polarity is the **mirror image** of the defect entry 14
records. `witnessPresent` is identically `false` off `freshLabelRules`, so widening its index set
adds permanently-*uncured* columns that inflate the count without ever moving.
`selfGuardDischarged` is identically `true` off `selfGuardRules`, so any column outside the index
set would be permanently *cured* and contribute `0`. The index set is exactly two rules wide, and
the ceiling is `selfGuardPotential ≤ 2 * U.card`, the twin of `mintPotential_le_eight_mul`.

Note also that it does **not** take `b`. That is deliberate: it is a pure function of the ordering
and the renamed index set, which is what makes the arm-3 argument go through without touching
`Branch.identifyTime` at all.

**Why it pays for `untlNeg` / `snceNeg`.** The ACTIVE arm fires only when
`(ord.futureOf l.time).isEmpty` (`Tableau.lean:1016, 1063`), i.e. exactly when the `untlNeg` column
at the trigger's time is **uncured**. Its own `newOrd = ord.addFuture l.time freshTime`
(`Tableau.lean:1071`) puts `freshTime` into `directFutureOf l.time`, hence into
`futureOf l.time` by `mem_futureOf_of_mem_constraints` (`MintBound.lean:215`) — so after the step
that column is **cured**. The source itself states this as the operative mechanism:
"`ruleSelfGuarded .untlNeg` remains true, now for a different reason: the ACTIVE arm returns
`newOrd`, which makes `futureTimes` non-empty at the next call" (`Tableau.lean:1057-1058`).
`snceNeg` is the exact past mirror (`Tableau.lean:1147`, `1167`).

No column un-cures at a growth step: `addFuture`/`addPast` only cons onto `ord.constraints`
(`SignedFormula.lean:685-690`), and `futureOf_mono`/`pastOf_mono` (`Fuel.lean:914`, `926`) then
give monotonicity of `selfGuardDischarged` in exactly the shape `mintPotential_le_of_grow`
(`MintBound.lean:2988-2999`) consumes. So `selfGuardPotential_le_of_grow` is a near-transcription
of an already-landed proof.

**Preservation across `identifyTime`: YES — and the load-bearing lemma is already landed.**
This is the discriminating property, so I give the argument in full.

At arm 3 the successor is `(b.identifyTime t₂ t₁, ord.identifyTime t₂ t₁)` with the renaming
`rhoSF t₂ t₁ ∘ σ` (`MintBound.lean:4813, 4833`), the trigger satisfying
`firstIncomparablePair b ord = some (t₁, t₂)` (`MintBound.lean:4782`), and `IrreflOrd ord` from
`RunInvariant` (`MintBound.lean:1675-1676`).

1. **No constraint is dropped.** `identifyTime_no_collapse` (`MintBound.lean:231-251`) proves
   exactly this: for `(a,b) ∈ ord.constraints`, `rho t₂ t₁ a ≠ rho t₂ t₁ b`, given
   `incomparableB ord (t₁,t₂)` and `IrreflOrd ord`. Since `TimeOrdering.identifyTime`'s `filterMap`
   discards a constraint *only* when `a' == b'` (`SignedFormula.lean:707-710`), every constraint
   survives as its renamed image. `incomparableB ord (t₁,t₂)` is available from
   `firstIncomparablePair_spec` (`Fuel.lean:1023-1026`), whose last two conjuncts are literally
   `incomparableB`'s two clauses (`Fuel.lean:1044-1045`).
2. **Hence `futureOf` non-emptiness transports.** If `(ord.futureOf t) ≠ []`, take the first edge
   `(t, u)` on a witnessing path; its image `(rho t, rho u)` is in
   `(ord.identifyTime t₂ t₁).constraints` by step 1, so `rho u ∈ futureOf (rho t)` by
   `mem_futureOf_of_mem_constraints`. And `rho t = (rhoSF t₂ t₁ (σ x)).label.time` for the
   corresponding index element, because `rhoSF` acts on the label's time by `rho`
   (`MintBound.lean:67`).
3. **Therefore `selfGuardDischarged` is preserved at every column**, so the filter's true-set only
   grows and `selfGuardPotential U (rhoSF t₂ t₁ ∘ σ) (ord.identifyTime t₂ t₁) ≤
   selfGuardPotential U σ ord`. Constraint (F) is satisfied with equality-or-better; nothing rises.

The template proof already exists in the file: `witnessPresent_identifyTime` (`MintBound.lean:644`)
is the same statement for the other predicate, and it also needs `IrreflOrd` — register entry 5
records that dropping `IrreflOrd` refutes it. The new lemma is its sibling, and needs the
incomparability conjunct in addition, which the trigger supplies.

**Why the `ord.timeCount`-lowering worry does not bite.** The dispatch flags that `identifyTime`
can lower `ord.timeCount` and that this is the obstruction. It is the obstruction *for any
component stated against `ord.timeCount`*, which is why Candidate 2 is deliberately **not** stated
against it. Massacci's technique is a *rule-application guard*, and what his termination proof
measures is not the guard's counter but the fact that the π-rule's precondition becomes and stays
false (T.8.2's already-reduced test, `chunk_0026.md:20`). Candidate 2 measures the discharge, not
the cap. `ord.timeCount` may fall freely at arm 3 without moving `selfGuardPotential` by a single
unit, because `selfGuardPotential` does not mention it.

**Direction lemma it admits.** The repaired predicate

```lean
def MintPaysForTimeAt (fc : FrameClass) (U : Finset SignedFormula) (Tmax : Nat) : Prop :=
  ∀ σ b ord tr, RunInvariant b ord → (∀ x ∈ b, x ∈ U) →
    ∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1,
      (disjunct 1, verbatim) ∨ (disjunct 2, verbatim) ∨
      (selfGuardPotential U σ (expandOnceUnblocked b ord fc tr).2 < selfGuardPotential U σ ord)
```

is a **weakening** of `MintPaysForTime` — a third disjunct is added and nothing is removed. So
`mintPaysForTimeAt_of_mintPaysForTime` is the available implication, the converse is false (by
`mintPaysForTime_untlNeg_false`, `MintBound.lean:7110`, which refutes the stronger one at a `U`
where the weaker one is intended to hold), and **every theorem restated against it is a
strengthening**. This is the same direction and the same idiom as
`universeClosedAt_of_universeClosed` (`MintBound.lean:5332`) and
`ordTimesLeMaxTime_of_ordTimesKnown` — the repair pattern this file has used twice already, so the
docstring can say so by name.

**New hypothesis leaked into the terminus?** No new *hypothesis*. But it does force a new
*coefficient*: `budgetPotential` must become

```lean
(2 * (Tmax*Tmax + 1)) * mintPotential + (2 * (Tmax*Tmax + 1)) * selfGuardPotential
  + extensionAllowance + splitOrderedRank
```

and `mintPathBound` / `mintAwareFuel` must absorb the extra `2*(Tmax²+1) * 2 * U.card`. That is an
arithmetic enlargement of a fuel figure, of exactly the kind `splitAwareFuel_le_mintAwareFuel`
already records (register entry 8), not a new assumption on the caller. All four consuming termini
(`buildTableauAt_isSome_of_lengthBudget_at` and siblings) keep their hypothesis lists unchanged.

---

### 6.3 Candidate 3 — Interval-gap fill potential *(pattern: Venema §5 interval accounting + Caleiro SVDns; the `densityRule` companion)*

**Definition sketch.**

```lean
/-- The gap `(t, t')` is filled: some interpolant sits strictly between.
    Transcribes `densityRule`'s own `gapTargets` filter (Tableau.lean:1364-1366). -/
def gapFilled (ord : TimeOrdering) (t t' : TimeIndex) : Bool :=
  (ord.futureOf t).any (fun t'' => (ord.futureOf t'').contains t')

def gapPotential (U : Finset SignedFormula) (σ : SignedFormula → SignedFormula)
    (ord : TimeOrdering) : Nat :=
  ((U ×ˢ U).filter (fun p =>
      gapFilled ord (σ p.1).label.time (σ p.2).label.time = false)).card
```

Ceiling `≤ U.card * U.card`.

**Why it pays for `densityRule`.** The rule fires only when `t' ∈ gapTargets`, whose second
conjunct is precisely `¬ gapFilled ord l.time t'` (`Tableau.lean:1366`). Its `newOrd` adds
`l.time < freshTime` and `freshTime < t'` (`Tableau.lean:1373`), so `freshTime` witnesses
`gapFilled` at `(l.time, t')` afterwards. The column flips uncured → cured: a strict drop of ≥1,
*provided* the pair `(l.time, t')` is hit by the index set (see the σ-hit residual below).

Monotone under growth by `futureOf_mono`, in both occurrences of `futureOf` inside `gapFilled`;
preserved at arm 3 by the same `identifyTime_no_collapse` argument as Candidate 2 (`gapFilled` is
built only from `futureOf`, and every edge survives). So it satisfies Constraint (F) too.

**Why it is NOT the recommendation, despite covering the rule Candidate 2 misses.**

- `densityRule` is `denseRules`-gated (`Tableau.lean:1593, 1626`), so this component is dead weight
  at `.Base` and `.Discrete`, whereas `untlNeg`/`snceNeg` are `carrierBase` and bite everywhere.
  The Phase 4 verdict used exactly this asymmetry to choose its refutation vehicle.
- The index set is `U ×ˢ U`, quadratic in `|U|`, versus Candidate 2's `2 * U.card`. That inflates
  `mintPathBound` by a factor of `|U|`.
- Its σ-hit obligation is a *pair* hit — both `l.time` and `t'` must be in the σ-image of `U`'s
  time projection — which is strictly harder than Candidate 2's single-time hit.

It is the right **second** component, in a later phase, and the literature agrees that it is a
separate clause (Caleiro's SVDns sits apart from SV1–SV4, `sec03:80`).

---

### 6.4 Why Candidate 2 is not a disguised re-attempt of register entry 14

Stated explicitly because a reader will and should check.

| Refuted route (entry 14) | Candidate 2 |
|---|---|
| Index set: `freshTimeRules ×ˢ U` — a *widening of `mintPotential`'s own* index set | Index set: `selfGuardRules ×ˢ U` — a *new, disjoint-purpose* index set on a **separate** measure component; `mintPotential` is byte-unchanged |
| Predicate: `witnessPresent`, reused verbatim | Predicate: `selfGuardDischarged`, a new definition that never calls `witnessPresent` |
| Failure mode: the added columns are permanently `false` (`witnessPresent_eq_false_of_not_freshLabel`) | The added columns are `false` exactly when the rule can fire and `true` exactly when it cannot, by transcription of the rule's own guard — the polarity is inverted and the catch-all is `true`, so nothing is permanently uncured |
| Also refuted: dropping disjunct 1's cardinality conjunct | Both disjuncts are retained **verbatim**; a third is added |

And, separately, Candidate 2 is not the "branch times with empty forward reach" potential the
source refutes at `MintBound.lean:7166-7168`. That one is indexed by `b.knownTimes` and counts
*times*; the fresh time it mints has an empty future, so the count is net-zero. Candidate 2 is
indexed by the **fixed** set `selfGuardRules ×ˢ U` through `σ` and counts *columns*. The freshly
minted time contributes nothing new because it was already an uncured column before the step
(before the step `freshTime ∉ ord`'s endpoints, so `futureOf freshTime = []` already), and after
the `untlNeg` step `freshTime` is the *target* of the new edge, not its source, so its column is
unchanged. The net-zero mechanism that kills the `knownTimes`-indexed version does not arise. I
flag this as the single most important thing for the implementer to verify first (§8, risk R1).

---

## 7. Recommendation

**Recommend Candidate 2 (`selfGuardPotential`), landed first and alone; Candidate 3
(`gapPotential`) as a separate follow-on component for the density coordinate.**

The discriminating reasons, in the order that decides:

1. **It is the only candidate that satisfies Constraint (F).** Candidate 1 provably violates it
   (§6.1, and by Corollary (F′) so does every `knownTimes.card`-affine variant). Candidate 3
   satisfies it too, so (F) alone does not separate 2 from 3 — but it eliminates the whole family
   the dispatch's framing would naturally lead to.
2. **Its identification-preservation rests on an already-landed, machine-checked lemma**
   (`identifyTime_no_collapse`, `MintBound.lean:231-251`), not on a new mathematical argument. The
   dispatch names identification-preservation as the single most likely failure point; for
   Candidate 2 that step is nearly free, because the file already proved the sharp fact that no
   constraint collapses at an incomparable trigger under `IrreflOrd`.
3. **It is frame-class-universal.** `untlNeg`/`snceNeg` are in `carrierBase`; `densityRule` is
   `denseRules`-gated. The terminus needs a statement at every frame class, and Candidate 2
   discharges the frame-class-universal half. This is the same reasoning by which
   `mintPaysForTime_untlNeg_false` was preferred to a `densityRule` witness.
4. **Its ceiling is linear (`2 * U.card`), not quadratic**, so the fuel-figure enlargement is a
   constant multiple rather than a factor of `|U|`.
5. **It reuses two landed proofs almost verbatim** — `mintPotential_le_of_grow`
   (`MintBound.lean:2988`) for the growth direction and `witnessPresent_identifyTime`
   (`MintBound.lean:644`) as the template for the identification direction — which is the single
   best predictor of whether a phase closes in this file.

**What it does not do, said plainly:** it does not cover `densityRule`. A repaired
`MintPaysForTimeAt` carrying only the `selfGuardPotential` disjunct is still refutable at
`.Dense`/`.Dedekind` by a `densityRule` vehicle. The honest deliverable of a first phase is
therefore the *frame-class-universal* half plus a named residual, not a closed result — which is
the same shape as `UniverseClosedAt` (clause 2 repaired, clause 1 carried as
`UnorderedSuccessorLabelClosed`, register entry 11).

---

## 8. Open residual and risks, ranked

**R1 — the σ-hit obligation is inherited and is *false*, not open (register entry 15).**
Candidate 2's strict drop needs the trigger's time `l.time` to equal `(σ x).label.time` for some
`x ∈ U`. After a time reuse, `rho_src_ne_src` and `mint_not_in_rhoSF_image` (`MintBound.lean:7268`
region) say the re-issued time is outside σ's image. Candidate 2's obligation is a *time* hit
rather than a *formula* hit, which is strictly weaker than `mintPotential_lt_of_mint`'s — but I
have **not** verified that the weakening escapes the refutation, and entry 15's closing sentence
("the obstruction is intrinsic to identification-plus-`maxTime`") suggests it does not. Entry 14's
own instruction is that the repair must **carry it structurally rather than discharge it**
(`MintBound.lean:7271`), i.e. `MintPaysForTimeAt` stays a named hypothesis exactly as
`MintPaysForTime` does. **This is the largest risk to the recommendation and it must be tested
first**, before any of the plumbing lemmas are written: construct the analogue of
`mintPaysForTime_untlNeg_false` against `MintPaysForTimeAt` at the reuse configuration
(`nextTime_reissues_retired_time`'s branch, `MintBound.lean:7309`) and see whether it decides
`False`. If it does, Candidate 2 is refuted and the report's recommendation is wrong; that outcome
should be landed as register entry 17 rather than absorbed.

**R2 — the "freshTime column is unchanged" claim (§6.4) is argued, not decided.** It rests on
`freshTime = b.nextTime ∉` the ordering's endpoints before the step, which needs `OrdTimesKnown`
(`MintBound.lean:1260`) plus `nextTime > maxTime ≥` every known time. Plausible and probably a
three-line lemma, but unverified.

**R3 — RESOLVED during self-verification, no longer a risk.** The `snceNeg` ACTIVE guard is read
off the arm's own `if` at `Tableau.lean:1163`:
`pastTimes.isEmpty && timeOrd.timeCount > 0 && timeOrd.timeCount < 4`, an exact mirror of
`untlNeg`'s at `Tableau.lean:1063`, with `newOrd = timeOrd.addPast l.time freshTime`
(`Tableau.lean:1170`). Since `addPast ord t t_new = (t_new, t) :: ord.constraints`
(`SignedFormula.lean:689-690`), the new edge is `(freshTime, l.time)`, so
`freshTime ∈ ord'.pastOf l.time` by `mem_pastOf_of_mem_constraints` (`MintBound.lean:223`) and the
`snceNeg` column at the trigger's time is cured. The mirror is exact.

**R4 — density remains open** at `.Dense`/`.Dedekind`, per §6.3.

**R5 — no literature source covers a merge/identification step.** The corpus's procedures never
identify two points, so §6.2's preservation argument is entirely repo-internal. Flagged per the H3
Tier-1 requirement; the mosaic/closure-set citations support the *shape* of the component (fixed
finite index, defect-curing) and nothing more.

---

## Adversarial Self-Verification

I attempted to refute each load-bearing claim, with priority on the `identifyTime`-preservation
argument for Candidate 2. Where I could not verify, the verdict is **uncertain**, not "holds".

| Claim | Source/Counterexample | Verdict |
|---|---|---|
| `unorderedSuccessorBranches` excludes `.splitOrdered`, so `MintPaysForTime` never quantifies over the identification arm | `MintBound.lean:1048-1051` read verbatim; corroborated by `budgetPotential_step_splitOrdered` (`MintBound.lean:4768-4775`) carrying no `hmint` | **Holds** — direct source read, two independent confirmations |
| `densityRule` is nonetheless inside `MintPaysForTime`'s scope, via `.persistent → .extended` | `Tableau.lean:1385` (`.persistent`) + `MintBound.lean:1071` (`.persistent fs => .extended (fs ++ b)`) | **Holds** — direct source read. Tried to refute by assuming `.persistent` mapped to `saturated`; the match arm says otherwise |
| Constraint (F): a fourth component may not rise at all at arm 3 | Derived from `budgetPotential_step_splitOrdered`'s arm-3 `omega` inputs (`MintBound.lean:4812-4835`) plus `splitOrderedRank`/`incompPairs_card_le`. Attempted refutation: rescale `splitOrderedRank` by `K` — fails because the mint-side rise scales by `K` too, so the required weight scales identically and the inequality `K ≥ K*(2Tmax²+1)` is unsatisfiable | **Holds as an argument; not machine-checked.** The `≥ 2*Tmax+1` sharpening in particular is my arithmetic, not a landed lemma |
| Corollary (F′): every `knownTimes.card`-affine component is dead | Immediate from (F) + `knownTimes_card_lt_identifyTime` (`Fuel.lean:1971`) + the mint-side rise decided in `mintPaysForTime_untlNeg_false` | **Holds** modulo (F) |
| **Candidate 2 is preserved across `identifyTime` at the trigger** | The chain is: `firstIncomparablePair_spec` (`Fuel.lean:1023-1026`) ⇒ `incomparableB ord (t₁,t₂)` (`Fuel.lean:1044-1045`) ⇒ `identifyTime_no_collapse` (`MintBound.lean:231-251`, **already landed and machine-checked**) ⇒ no constraint dropped ⇒ `futureOf` non-emptiness transports via `mem_futureOf_of_mem_constraints` (`MintBound.lean:215`). Attempted refutations: (a) *the surviving edge might be a self-loop after renaming* — excluded, that is exactly `identifyTime_no_collapse`'s conclusion; (b) *`futureOf` is fuel-bounded at 100, so a path could be lost* — the argument uses a **single edge**, reached at `n = 1` in `mem_futureOf_of_mem_constraints`, so fuel is not consumed; (c) *`eraseDups` could drop the image edge* — `List.mem_eraseDups` preserves membership, and `TimeOrdering.identifyTime` applies `eraseDups` after `filterMap` (`SignedFormula.lean:710`) | **Holds** — landed-lemma-backed. This is the strongest claim in the report and it is the one I most tried to break |
| Candidate 2 strictly drops at the `untlNeg` ACTIVE arm | Guard `futureTimes.isEmpty` at `Tableau.lean:1063`; `newOrd = addFuture l.time freshTime` at `Tableau.lean:1071`; source's own statement of the mechanism at `Tableau.lean:1057-1058` | **Holds for the trigger column, CONDITIONAL on σ-hit** — see next row |
| The strict drop is *unconditionally* available | **Refuted-by-inheritance.** Register entry 15 (`MintBound.lean:7527-7541`) decides that the engine re-issues a retired time (`nextTime_reissues_retired_time`, `reuse_driven_through_engine`) and that nothing minted there lies in σ's image (`mint_not_in_rhoSF_image`). Candidate 2's obligation is a weaker *time*-hit rather than a formula-hit, and I could not verify that the weakening escapes | **UNCERTAIN — and this is the recommendation's principal exposure.** Risk R1. The report does **not** claim Candidate 2 closes `MintPaysForTime`; it claims Candidate 2 is the right *shape* for the fourth component and that the σ-hit residual is carried structurally, per entry 14's own instruction (`MintBound.lean:7271`) |
| Candidate 2's freshly minted time contributes no new uncured column | Argued in §6.4 from `freshTime = b.nextTime` being absent from the ordering pre-step, plus the fresh time being the *target* rather than the source of the new edge. Attempted refutation: some `x ∈ U` already sits at the value `freshTime` and its `untlNeg` column flips — but such a column was **already** uncured before the step (`futureOf freshTime = []` then too), so no flip occurs | **Probably holds; UNVERIFIED.** Risk R2. Depends on `OrdTimesKnown` + `nextTime > maxTime`, neither assembled into a lemma here |
| Candidate 2 is not register entry 14's route (1) | Comparison table, §6.4. Attempted refutation: "any new column set over `U` is a re-indexing" — rejected, because entry 14's refutation is specifically that `witnessPresent` is identically false off `freshLabelRules` (`witnessPresent_eq_false_of_not_freshLabel`, `MintBound.lean:7042`), and `selfGuardDischarged` is a different function with the opposite catch-all polarity | **Holds** |
| Candidate 2 is not the refuted "branch times with empty forward reach" potential | `MintBound.lean:7166-7168` describes a potential indexed by branch times; Candidate 2 is indexed by `selfGuardRules ×ˢ U` through `σ` and does not take `b` at all | **Holds** on the definitions, but the *net-zero mechanism* that killed the refuted one is the same mechanism R2 covers, so the two rows share a risk |
| Candidate 1 is infeasible | §6.1, from (F) and the identity `timeSlotDeficit = |timeSlots U| − knownTimes.card` under confinement | **Holds** modulo (F) |
| `snceNeg`'s guard mirrors `untlNeg`'s exactly | Initially read only the comment at `Tableau.lean:1167`; flagged uncertain, then re-checked the arm's own `if` at `Tableau.lean:1163` (`pastTimes.isEmpty && timeOrd.timeCount > 0 && timeOrd.timeCount < 4`) and its `newOrd = timeOrd.addPast l.time freshTime` (`Tableau.lean:1170`), with `addPast` consing `(t_new, t)` (`SignedFormula.lean:689-690`) | **Holds** — upgraded from uncertain during this pass; R3 closed |
| The literature supports the *shape* (fixed finite index set, defect-curing, separate density clause) | `caleiro_2013/sec03:18-21, 42-55, 80`; `sec07` Thm 4.11 and closing remark; `massacci .../chunk_0026.md:20`, `chunk_0028.md:35-37`, `chunk_0029.md:3-4`, `chunk_0030.md:28-31` — all read verbatim | **Holds** for `caleiro_2013` and `massacci_2000` (both `verified_conversion`) |
| The literature supports the *identification-preservation* argument | No corpus source has a merge/identification step. Searched; found none | **Does not hold — explicit gap.** §4 and R5 record this rather than implying literature support |
| `venema_2001 §5` supports pair-indexing for the density coordinate | Not read end-to-end this dispatch; the conclusion is independently forced by `densityRule`'s own docstring (`Tableau.lean:1339-1356`) | **UNCERTAIN / provisional.** Marked Low in the H3 table; the repo citation, not the paper, is what §6.3 rests on |
| `baier_katoen_2008` Def 5.35 / Thm 5.37 say what I attribute to them | FTS snippets only (`2cbdea06b931a75d`, `6887c5785c91627c`); chunks not read end-to-end | **UNCERTAIN.** Marked Medium; no design decision rests on this row alone |
| `blackburn_2002 §6.4-6.5` cross-check | Not consulted | **Not claimed.** Recorded as an unfilled cross-check |

**Recommendations modified after verification.** Two. (i) The recommendation was initially going to
be "Candidate 2 closes the frame-class-universal half of `MintPaysForTime`"; after the σ-hit row it
was downgraded to "Candidate 2 is the right shape for the fourth component, with the σ-hit residual
carried structurally", and R1 was promoted to the top-ranked risk with an explicit
refute-it-first instruction. (ii) Candidate 3 was initially co-recommended; after finding that
`densityRule` is `denseRules`-gated (`Tableau.lean:1626`) while `untlNeg`/`snceNeg` are
`carrierBase`, it was demoted to a separate follow-on component so that the first phase delivers a
frame-class-universal result.

**No contradictions between sources were found**, so there is no Contradiction Log entry. The one
near-contradiction — entry 14 saying "neither obvious repair is available" versus this report
proposing a `mintPotential`-shaped component — is resolved in §6.4 by the polarity and index-set
distinction, and the resolution is testable rather than rhetorical (R1's decide-it-first
instruction).

---

## 9. Suggested phase shape for the planner

1. **Refute-first gate.** Attempt `mintPaysForTimeAt_untlNeg_false` at the reuse configuration
   (`nextTime_reissues_retired_time`'s branch). If it decides `False`, stop and land register
   entry 17. *(This is R1; it must be phase 1, not a later verification step.)*
2. `selfGuardRules`, `ruleSelfGuardedTime` Bool/Finset agreement lemma (mirror of
   `mem_freshLabelRules`, `MintBound.lean:2960`), `selfGuardDischarged`, `selfGuardPotential`,
   `selfGuardPotential_le_two_mul`.
3. `selfGuardPotential_le_of_grow` (transcribe `mintPotential_le_of_grow`, `MintBound.lean:2988`).
4. `selfGuardDischarged_identifyTime` + `selfGuardPotential_identifyTime` (transcribe
   `witnessPresent_identifyTime`, `MintBound.lean:644`, consuming `identifyTime_no_collapse`).
5. `MintPaysForTimeAt`, `mintPaysForTimeAt_of_mintPaysForTime` (the direction lemma, weakening),
   and the `untlNeg`/`snceNeg` discharge lemmas.
6. Re-prove `budgetPotential_step_unordered` and `budgetPotential_step_splitOrdered` at the
   four-component measure; re-derive `mintPathBound`/`mintAwareFuel`.
7. Residual note for the `densityRule` coordinate (Candidate 3) and register maintenance.

Phases 2-4 are transcriptions of landed proofs and should be sized accordingly. Phase 6 is the
only one that touches landed termini, and it touches their proofs, not their statements.
