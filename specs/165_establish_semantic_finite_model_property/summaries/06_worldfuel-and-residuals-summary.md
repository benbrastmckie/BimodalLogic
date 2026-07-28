# Phase 4 — `worldFuel'`, the branching residual, and the closure reduction

- **Task**: 165 (`establish_semantic_finite_model_property`), Phase 4 (T3 and T2 residuals)
- **Type**: lean4, hard mode (H2 anti-analysis, H9 wrap-up)
- **Session**: `sess_1785244791_96fa7d`
- **Date**: 2026-07-28
- **Result**: T3 (4.3) complete against its restated 5-criteria "Done when"; three green commits;
  zero sorries; engine untouched.

---

## Sub-phases executed

### 4.3e — the general fuel figure (COMPLETE, all six named targets)

`Fuel.lean`, additions only:

| Identifier | Content |
|---|---|
| `worldFuel'` | `(s + soundFuel' φ) * soundFuel' φ`, with `s` the seed-world count — deliberately *not* specialised to `1` |
| `worldFuel'_eq` | the identity `worldFuel' φ s = 2·c·((s + 2·c·m)·m)`, `c = |subformulaClosure φ|`, `m = 2^(2c)` |
| `soundFuel'_pos` | `0 < soundFuel' φ`, via `Finset.card_pos` and `self_mem_subformulaClosure` |
| `soundFuel'_le_worldFuel'` | via `Nat.le_mul_of_pos_left` |
| `chain_le_worldFuel'` | `chain_le_worlds_bounded` at the named figure, `hww` still visible |
| `expandBranchWithFuel_isSome_at_worldFuel'` | the 4.3 terminus, `maxBranches` quantified |

`soundFuel'` was frozen in name and body and gained one docstring paragraph naming it the
single-world (label-count) figure. `soundFuel_le_soundFuel'` and `chain_le_soundFuel'` were not
touched. The adjudicated decision was executed exactly as recorded; nothing was re-litigated.

Two environment facts worth carrying forward: **`ring` is not available in `Fuel.lean`** (Mathlib's
ring tactic is outside its import surface), and the identity is pure associativity/commutativity,
so `Nat.mul_left_comm` is both sufficient and the more honest tactic. `Nat.pos_pow_of_pos` does not
exist on this pin; `Nat.pow_pos` does.

### 4.3d residual 3 — split into a landed half and a refuted half

**Budget half — landed.** Report 06 §4's path-shaped (not tree-shaped) reading is confirmed by
re-reading `Saturation.lean:646/654, :675/681`, and is now theorems: `splitBudget_preserved`,
`extendBudget_preserved`, `budget_le_of_betaBudget`, carrying
`branchesUsed + β·fuel ≤ maxBranches` with `β` a **hypothesis** on `branches.length` rather than
the literal `3`. `budget_le_of_betaBudget` confirms the plan's claim that the stronger invariant
implies the landed one, so `expandBranchWithFuel_isSome_of_noSplit` needed no weakening.

**Fuel half — refuted as stated.** The plan called residual 3 "orthogonal to the fuel figure" and
its preservation "one line per arm". That holds for the budget and fails for the fuel:

* `estimateBranchDifficulty` (`Saturation.lean:360-364`) is always `≥ 1` — so no arm is starved to
  zero, and `allocateFuelProportionally_pos` proves that floor;
* but `allocateFuelProportionally` (`:378-388`) hands each arm a **proportional share**, and the
  arms recurse at `min pair.2 fuel` (`:653, :680`), so `k` equal arms each get about `fuel / k`.

The progress-measure hypothesis `U.card < b.toFinset.card + fuel` is therefore *not* re-established
at the arms by any parent fuel merely exceeding `U.card`; adequate fuel scales like
`β ^ depth · worldFuel'`, and `depth` is bounded by nothing proved so far. **The split arms
multiply the fuel figure.** Three `#guard_msgs` rows run the real allocator and show it:
`1000` units across three arms gives `[333, 333, 333]`; a second split gives `[111, 111, 111]`.

This is the same *class* of fact as the 4.3b blocker — a real property of a deliberate engine
policy, not a gap in a proof — so `NoSplit` stays the named hypothesis, which is what restated
criterion 3 already asks for.

### 4.2d — reduced to a bound

`TimeTypeBound.lean` now splits the obligation into **stabilisation** and **confinement** and
discharges stabilisation unconditionally: `closureIter_succ` (moves the step outside the
recursion), `closureIter_subset_succ`, `closureIter_subset_of_closed`, and
`exists_closureStep_subset` — the finite-monotone argument, with `exists_tableauClosed_closureIter`
as the packaged form.

What remains is confinement only: exhibit *any* finite emission-closed superset `M` of the seed.
The reduction is not circular, because `closureStep M ⊆ M` alone would give `TableauClosed M`
directly, whereas `closureIter n seed` is the **smaller** stock — and T2's `2^(2|C|)` is
exponential in `|C|`.

---

## Verification

| Check | Result |
|---|---|
| `lake build FormalSystem.Metalogic.Decidability` | green, 1054 jobs |
| `lake build BimodalTest` | green, 1949 jobs |
| `lean-sorry-census.sh` over `Verified/Termination/` | `sorry_count: 0` |
| Vacuous definitions | 0 |
| New axioms | 0 |
| Engine files touched | none |
| Signature changes to landed declarations | none (additions only) |
| `#guard_msgs` regression rows | 14 → 17 |

The full `lake build` was not used as the gate: the RED at
`FormalSystem/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` is pre-existing,
outside this territory, and that module does not import `Decidability/`.

---

## Plan deviations

1. **Sub-phase order.** The dispatch ordered residual 3 before 4.3e; 4.3e was executed first.
   Reason: the plan itself declares the two orthogonal and says residual 3 *adds* a theorem rather
   than modifying the one 4.3e consumes, so ordering carried no correctness cost — while 4.3e is
   the sole gate on the restated 5-criteria "Done when". Both landed, so the reordering cost
   nothing.
2. **Residual 3 half-landed rather than discharged**, with the fuel half recorded as a refutation
   rather than left as an open target. Documented in the plan as a FINDING with the four-element
   defect bar (counterexample, current behavior, required behavior, isolation).
3. **4.2d half-landed** rather than deferred entirely — the stabilisation half was cheap once
   isolated, and isolating it converts the remainder from "prove termination" into "exhibit a
   bound".
4. **Phase 4 heading left `[PARTIAL]`.** All three top-level tasks are now `[x]` and 4.3's
   Done-when is fully met, but 4.2d's confinement half is an unchecked sub-item; marking the phase
   COMPLETED over an open checkbox would misreport. A status banner under the heading records
   exactly what is and is not outstanding, and the handoff flags the judgment call so the
   orchestrator can flip it cheaply if it intends the 4.3 criteria alone to gate the phase.
