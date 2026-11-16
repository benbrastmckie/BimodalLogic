# Round 25 — the residue-carrying state relation: VERDICT

**Phase**: 11.41 (plan v25, route (M-1), decision 18). **Outcome: (a) — REFUTED.**
**A `/revise` is owed on this verdict.** Phase 11.42 is NOT licensed.

## The relation, stated in full

In `FormalSystem/Metalogic/Decidability/RaySummary/LadderStepFrag.lean`, section `Residue`:

```
def Srel (P a b : ℕ) (x y : LadderState Q pend) : Prop :=
  Zrel a b x y ∧ (x.1.2.1 : ℤ) ≡ (y.1.2.1 : ℤ) [ZMOD ((P : ℤ) + 1)]
```

`x.1.2.1` is the countdown coordinate. The modulus is `P + 1`, the one `paramsOkK1` constrains
(every `l ∈ objCycleLens step pend` divides it). The content is the plan's `S`, unaltered; the
library name is `Srel` (parallel to `Zrel`), and the spelling of the congruence is `Int.ModEq`.

Landed with it: `Srel.toZrel` (`S → Zrel a b`), `Srel.refl`, `Srel.symm`, `Srel.mono` (in `(a, b)`).
Axioms: `Srel`, `Srel.toZrel`, `Srel.refl` depend on none; `Srel.symm`, `Srel.mono` on
`[propext, Classical.choice, Quot.sound]`. Pinned in `KTypeSummaryAxiomTest.lean`.

## Entry re-derivation (against the live files)

| Plan's citation | Live | Drift |
|---|---|---|
| `truth_iff_of_lnkRow` `LadderStepFrag.lean:1116` | 1116 at entry | none (shifted +5 by this phase's header addition) |
| `LnkRow.refl` `:1007`, `first_zero` `:1029`, `region_end_obj` `:1053`, `RowFrag` `:1097` | as cited at entry | none |
| `paramsOkK1` `CounterQuotient.lean:866` | 866; object conjunct at 869 | none |
| `LadderStepFrag.lean` 1,202 lines, no `longFile` baseline | 1,202 at entry; 1,273 after | within 1500, no baseline added |
| probe wired at `check-evidence-probes.sh:3057` | list entry at 3057 | none |
| `KTypeSummaryAxiomTest.lean` 101 lines of headroom | 3,612 at entry (88 of headroom against 3700); 3,647 after | the plan's figure was measured before Phase 11.34's pin; baseline not raised |

The fixture argument, re-derived: on `C3` the refuting pair `xC m`, `yC m` has countdowns `2 m`
and `2 m + 1`; `2 ∈ objCycleLens stepC pendC` is now COMPILED (`two_mem_objCycleLens_C3`), and so
is the exclusion (`not_Srel_xC_yC`: with `2 ∣ P + 1` the pair is not `Srel`-related at any budget).
The relation's motivation holds.

## What the two obstruction lemmas say at `Srel` (tested before anything else)

`LnkRow` is stated over `Zrel`, so both lemmas are unchanged in statement.

- `LnkRow.region_end_obj`: the two current regions must end at one object state. On an object whose
  pending walk is forced and periodic with period dividing `P + 1`, congruent countdowns satisfy
  it. On a branching object it constrains the choice of the second path's walk; the congruence does
  not supply one.
- `LnkRow.first_zero`: the first exhausted countdown is answered by the first exhausted countdown,
  **with every position before the answer answered back**. The congruence at the linked pair says
  nothing about those intermediate positions. Each needs an answer with its own object state and a
  countdown equal to its own or above `Zrel`'s threshold `2 (a + b)` — a threshold that does not
  depend on the object. **This is where the attack was aimed, and it is where the relation broke.**

The same account is in the module's section docstring for `Srel`.

## The refutation attempt: fixtures, pairs tried, and why each did or did not break

All in the wired probe `specs/evidence/seam-gluing-ray-product/ladder-row-link-residue-obstruction.lean`,
APPENDED (the 221 landed lines are untouched).

### Fixture 1 — `C3` (pending `2`-cycle `p0 ⇄ p1`): NOT BROKEN

| Pair | Result | Why |
|---|---|---|
| `xC m = (p0, 2m, 2m)`, `yC m = (p0, 2m+1, 2m+1)` (the pair that defeats `Zrel`) | not `Srel`-related (`not_Srel_xC_yC`) | parity; the residue conjunct excludes it |
| tight pair `xT a b = (p0, 2(a+b)+2, ·)`, `yT P a b = (p0, 2(a+b)+2+(P+1), ·)` | `Srel P a (b+1)`-related (`Srel_xT_yT`); attack ANSWERED at the level of states (`Zrel_tight_answer_C3`) | two steps in, both regions are at `p0` and the shorter countdown `2(a+b)` still meets the threshold left after one jump: a `2`-cycle has two residues and the shorter region has exactly two positions above the threshold |

No row-linked pair of paths is constructed on `C3` and none is refuted. `Zrel_tight_answer_C3` is a
statement about two states.

### Fixture 2 — `R4` (pending `3`-cycle `r0 → r1 → r2 → r0`, each exiting to an idle sink): BROKEN

No existing object under `specs/evidence/` was re-used: the attack needs a FORCED pending walk of
period `≥ 3`, and the tight-chain fixtures there are built for pump/regime questions and carry
branching or period-`2` pending parts. `R4` is `C3` with one more state on the cycle — the smallest
object that fits.

| Pair | Result |
|---|---|
| `xR a b = (r0, 2(a+b)+2, 2(a+b)+2)`, `yR P a b = (r0, 2(a+b)+2+(P+1), 2(a+b)+2+(P+1))` | `Srel P a (b+1)`-related at EVERY `P` (`Srel_xR_yR`); NO row-linked pair of ladder paths (`not_lnkRow_xR_yR`) |

The mechanism (`not_lnkRow_xR_yR`): take the second `FwdJump` of the row link — positions of the
LONGER region must be answered. Position `t + 3` of the longer region carries `r0` with countdown
`2(a+b) + (P+1) - 1`. Its answer `s > t` on the shorter path:

- inside the shorter region (`s ≤ t + 2(a+b) + 2`): the countdown clause of `Zrel a b` forces
  `s ∈ {t+1, t+2}` (equal countdowns or both `≥ 2(a+b)`), and those positions carry `r1`, `r2`;
- beyond it: the answer passes the region's last position, countdown `0`, which must be answered
  back by `t + 1` or `t + 2` on the longer path, whose countdowns are positive and `2(a+b) ≥ 2 > 0`.

**Headline**: `ProbeRowResidue.no_rowLinked_path_of_Srel (P a b) (hab : 1 ≤ a + b)` — two
`Srel P a (b + 1)`-related states, a ladder path through the first, no row-linked ladder path
through the second. `#print axioms`: `[propext, Classical.choice, Quot.sound]`, pinned by
`#guard_msgs` in the probe. The modulus is arbitrary, so every `(K1)`-admissible `P`
(`3 ∣ P + 1`, `three_mem_objCycleLens_R4`) is covered.

## The failing coordinate

Of the three the obligation enumerates — the residue; the register offset after the lengthened
region; the past row — **it is the residue.** Not the register offset: the pair's registers and
gaps are matched and no clause of the proof reads them. Not the past row: no backward jump is used
(`a` may be `0` with `b ≥ 1`).

Stated exactly, so the `/revise` is not mis-aimed: the conjunct fixes the residue of the countdowns
AT THE LINKED PAIR. The row link asks every position of the longer region to be answered at ITS OWN
residue by a position of the shorter region above `Zrel`'s countdown threshold. That threshold's
margin is `2` per forward unit of budget and is independent of the object, while the number of
residues to answer is the object's cycle length. `2` residues fit (fixture 1); `3` do not
(fixture 2). The defect is a coupling between the countdown THRESHOLD and the modulus, which a
conjunct on the two states cannot repair.

## What a `/revise` has to rule on

The refutation points at an object-dependent countdown threshold (a margin of at least a cycle
length — at most `P + 1` — above `2 (a + b)`, per jump). That is NOT `S` with a different modulus,
and it is not `Zrel` at other thresholds in the sense decision 18 excludes (those thresholds were
object-independent); it is a third shape, and this phase's prohibition on designing a third
relation was observed. Whether it survives is not proved, not probed and not claimed here. The
refuting pair sits exactly AT the threshold; nothing is known about pairs a cycle length above it.

## What this phase does NOT establish

It bears on the path forth and on nothing else. It says nothing about the clip (Ruling 16), nothing
about `ladderLift`, and it does not revive `cellAt_const_of_kappa_eq` or `ladderRealized` under
their pinned names. It does not refute the row link, `truth_iff_of_lnkRow`, or any agreement of
cells. Phase 11.39 is untouched and stays as it was. No path forth was attempted: outcome (a) was
reached at the refutation step, which the order binding on this phase places first.
