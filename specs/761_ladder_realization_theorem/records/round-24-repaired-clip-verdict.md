# Round 24 — the refutation attempt against the repaired gap clip (plan v24, Phase 11.33)

**Outcome: (a) — REFUTED AT THE REPAIRED CLIP TOO.** The clip
`2 * (dBack φ + dFwd φ) + 2 ≤ B ∧ 2 ≤ B` (Ruling 10) does not make the agreement on
`kappa`-classes true. The refutation is compiled, at the two-state object of
`specs/evidence/seam-gluing-ray-product/ladder-cell-agreement-refutation.lean`, in that file's
fifth section (appended; lines 2824-3343), with zero `sorry` and the standard axiom profile.
Decision 17's obligation is discharged by its first disjunct.

## 1. Entry re-derivation

| Carried | Live (this dispatch) | Drift |
|---|---|---|
| `not_kappa_collision_of_gap_inside` at `ladder-step-fragment-gap-depth.lean:1180` | `:1185` | +5 lines, signature unchanged |
| `thetaC_pair_not_collision` at `:1191`, `hB : 4 ≤ B` | `:1196` | +5 lines, signature unchanged |
| `mixC_pair_not_collision` at `:1198`, `hB : 3 * k + 5 ≤ B` | `:1203` | +5 lines, signature unchanged |
| refutation fixture, fourth section objects (`gluePath`, `exists_upRamp`, `exists_downRamp`, `kappa_collision_pos`, `truth_diaF`, `gI`) | present, 2823 lines before this phase | none |

Neither non-collision lemma is re-proved; both are cited. They certify that the EARLIER refuting
witnesses are not collisions at the repaired clip. They never certified the agreement there, and
this round supplies a witness that is one.

## 2. The attempt, stated before it was made

The plan narrowed the attack to "a jump whose positive-arm gain is amplified faster than the sum
of the depths grows", and recorded that a hand search had not found one because the gap is
monotone along a single history and jumps saturate. The amplification found does not act on the
gap along a history. It acts on the REGISTER OF AN IDLE STATE, through `⊡`'s re-choice of the
past:

* a region entered from an idle state with register `r₀` has exactly `r₀ + 1` pending positions
  (`Count`: the countdown is set to the register and a region ends exactly at countdown `0`);
* so the idle state right after it is `r₀ + 2` steps later and carries a register at most
  `2 r₀ + 2` (`Drift`), attained by raising the register at every step;
* at an idle state, `◇ (p S (¬p ∧ ψ))` asks for SOME history through the state whose nearest
  earlier idle state satisfies `ψ`. If `ψ` holds exactly at idle registers `≤ K`, this holds
  exactly at idle registers `≤ 2 K + 2`.

One `snce` (guard `p`) per doubling. The formulas:

```
lvlC 0       := ◇ X (p ∧ X ¬p)                 -- idle register = 0
lvlC (j + 1) := ◇ (p S (¬p ∧ lvlC j))          -- idle register ≤ Kc (j + 1) = 2 * Kc j + 2
dblC j       := ◇ (p U (¬p ∧ lvlC j))          -- at a pending state: gap n - c ≤ Kc j + 1
```

`Kc j + 2 = 2 ^ (j + 1)` (`Kc_eq`). `dBack (dblC j) = j`, `dFwd (dblC j) = 3`.

## 3. What compiled

| Declaration | Statement |
|---|---|
| `nxt_le_double` | between consecutive idle positions with only pending positions between, `nxtAt g t ≤ 2 * nxtAt g s + 2` |
| `lvlC_false` | at an idle position with register `> Kc j`, `lvlC j` is false on every history |
| `lvlC_true` | at the idle state with register `Kc j`, `lvlC j` is true on every history |
| `dblC_mem` | at the pending state `(c, c + Kc j + 1)` EVERY realized type contains `dblC j` |
| `dblC_not_mem` | at every pending state `(c, n)` with `c + Kc j + 2 ≤ n` NONE does |
| `dblC_cell_ne` | the two cells differ |
| `dBack_dblC`, `dFwd_dblC`, `BRep_dblC` | depths `j`, `3`; repaired clip `2 j + 8` |
| `paramsOkRep_params` | (K1), (K2), (K3) as the library states them and (K4) at the repaired clip hold at `Tcof`, `Tnof`, `Pof` and `BRep φ := 2 * (dBack φ + dFwd φ) + 2` |
| `gap_clip_below_exponential_refuted` | for EVERY `Tc`, `Tn`, `P` and every clip `B < 2 ^ (j + 1)`: a `kappa`-collision `(c, n)`, `(c, n + (P + 1))` with `n = c + (2 ^ (j + 1) - 1)` whose cells differ at `dblC j` |
| `repaired_clip_refuted` | **the headline**: for every `j ≥ 3`, at `dblC j`, the repaired parameter conditions at the fixpoint's outputs, clip `2 j + 8`: that collision, cells different |

The repaired `ParamsOk` is stated in the fixture as `ParamsOkRep` (the library's `paramsOkK1`,
`paramsOkK2`, `paramsOkK3` verbatim, with `paramsOkK4Rep` in place of `paramsOkK4`), because this
phase may not edit `paramsOkK4`, `Bof` or `ParamsOk` in the library.

`#print axioms`: `[propext, Quot.sound]` on `nxt_le_double`; `[propext, Classical.choice,
Quot.sound]` on the other eight printed theorems.

Smallest instance: `j = 3`. `dblC 3` has `dBack = 3`, `dFwd = 3`, repaired clip `14`, and
separates the gap `15` from the gap `15 + (P + 1)`.

## 4. Each refutation names its clip (carried Ruling 5)

| Refutation | Clip it is about |
|---|---|
| `refutationTargetC_holds`, `cellAt_const_of_kappa_eq_schema_refuted`, `no_fibre_equation_over_kappa` (`thetaC`) | the filed `(K4)`: `max (2 dBack + 1) (2 dFwd + 1) 2`, value `3` |
| `mixC_refutes` | the filed `(K4)`, value `2 k + 5` |
| `repaired_clip_refuted` (`dblC j`, `j ≥ 3`) | the repaired clip `2 * (dBack + dFwd) + 2`, value `2 j + 8` |
| `gap_clip_below_exponential_refuted` | every clip `B < 2 ^ (j + 1)` at `dblC j`, at every `Tc`, `Tn`, `P` |

**The step-fragment results are untouched.** `stepFrag_gap_depth_exact`,
`cellAt_const_of_kappa_eq_stepFrag` and `sigC_refutes` concern formulas whose `untl`/`snce` sit at
the guard `⊥` only. `dblC` uses a `snce` and an `untl` at the guard `p`.

## 5. What this does and does not establish

* The clip `2 * (dBack φ + dFwd φ) + 2` is wrong, and so is every clip polynomial in the two
  exactness depths: a clip under which the agreement holds must satisfy
  `F (a, 3) ≥ 2 ^ (a + 1)`.
* The lower-bound envelope recorded in `reports/23_gap-reading-depth-derived.md`,
  `F (a, b) ≥ max (2 a + b − 1) (2 b + 2)`, is a lower bound and is not tight: it was derived from
  families that move the gap by at most two per operator.
* NOT established: that any clip makes the agreement true. `dblC j` is defeated by
  `B ≥ 2 ^ (j + 1)`. Nothing here proves or refutes the agreement at a clip exponential in
  `dBack φ`, and no search for a faster-growing family was made. The absence of such a family in
  this record is a fact about this round's scope and is not evidence about the agreement.
* NOT touched: the tight family (`tight_state_refuses_C`), the countdown coordinate, `(K1)`,
  `(K2)`, `(K3)`.

## 6. Consequences inside plan v24

* Phase 11.35 (the repaired `(K4)` in the library at this shape) closes
  `[COMPLETED WITH EXCLUSIONS]` on this outcome, as that phase's own entry condition states.
* The jump-clause trunk (Phases 11.38-11.40) carried the candidate
  `S a b := Zrel (a + b + 1) (a + b)`, whose gap arms are linear in the budget. `dblC` shows the
  whole-language gap reading is exponential in the backward depth, so a state relation for the
  jump clauses needs a gap threshold of that order; this is independent of, and additional to,
  the countdown-residue obstruction recorded in `round-24-jump-clause-verdict.md`.
* A `/revise` is owed. The mechanism (`nxt_le_double`: the idle register doubles across one
  region, backwards in `⊡`-time) is the same doubling `(K2)`'s cascade bound iterates; a repaired
  clip would have to come from that source, not from the formula's depths alone.

## 7. Gates

Recorded in the dispatch summary
(`summaries/24_step-system-jump-clause-derivation-summary.md`), measured in this dispatch.

## Landing in the library (Phase 11.34, dispatch 73)

The refutation of the filed agreement's schema at the FILED `(K4)` clip is now a compiled library
declaration: `FormalSystem.Metalogic.Decidability.RaySummary.exists_kappa_collision_cellAt_ne_at_K4_clip`
(`RaySummary/LadderRealize.lean`), axioms `[propext, Classical.choice, Quot.sound]`.

- **Route**: (i), by measurement — the two-state object and the `thetaC` argument elaborate inside
  `LadderRealize.lean`'s import closure (`LadderChain` -> `LadderPump` -> `LadderAgree`), with nothing
  imported from `specs/`.
- **Statement**: existential — a finite object, labelling, formula, `Tc Tn P` with `ParamsOk` at
  `B = max (2 * dBack phi + 1) (max (2 * dFwd phi + 1) 2)`, a `kappa`-collision at those parameters,
  and the two cells unequal at world time `0`, evaluation time `0`.
- **Witness**: `private`, namespace `K4ClipWitness` (47 declarations copied from the fixture's
  `thetaC` chain). The fixture is unedited and stays the independently-gated duplicate.
- **NOT landed**: the `dblC` strengthening of this record (`repaired_clip_refuted`,
  `gap_clip_below_exponential_refuted`, lower bound `2 ^ (dBack phi + 1)`). It is named in the
  declaration's docstring and stays probe-only; landing it is a second declaration family.
