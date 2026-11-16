# Round 27 — The REGISTER Coordinate at the `Mrel` Pair, Measured

Phase 11.46 of plan v27 (`plans/27_register-coordinate-measurement.md`), route (O-1),
decision 20, Ruling 22. **Verdict: outcome (b) — SATISFIABLE, AND EXHIBITED, on both fixtures.**

**Re-entry note.** The dispatch that produced this record selected Phase 11.44, whose `[PARTIAL]`
marker parses as open. Per that phase's RE-ENTRY NOTICE it executed **Phase 11.46** instead.
Phase 11.44 was not re-entered, re-marked, or written into.

## 0. Entry gate, re-derived against the live files (not read off a marker)

Every declaration Phase 11.46's entry condition names was re-derived by `grep` against the live
tree before any edit. The plan's line numbers held exactly, with no drift:

| Declaration | File | Line |
|---|---|---|
| `Zrel` | `FormalSystem/Metalogic/Decidability/RaySummary/LadderStepFrag.lean` | 201 |
| `LnkRow` | same | 642 |
| `exists_rowLinked_path_zero` | same | 750 |
| `LnkRow.first_zero` | same | 1042 |
| `LnkRow.region_end_obj` | same | 1066 |
| `Mrel` | same | 1338 |
| `gB_isLadderPath` | `specs/evidence/seam-gluing-ray-product/ladder-row-link-residue-obstruction.lean` | 749 |
| `not_Mrel_xR_yR` | same | 884 |
| `xM` / `yM` | same | 897 / 900 |
| `Mrel_xM_yM` | same | 905 |
| `region_end_agrees_R4` | same | 948 |
| `region_end_matchable_B5` | same | 997 |

`records/round-26-threshold-relation-verdict.md` section 2 was read: it records outcome (c), and
it already **withdraws** the fabricated `no_rowLinked_path_of_Mrel` claim from the interrupted
dispatch. `grep -rnE '(theorem|lemma|def) +no_rowLinked_path_of_Mrel' FormalSystem/ Tests/ specs/evidence/`
returns nothing, and this round asserts no such declaration anywhere.

**Headrooms, re-measured at entry** (the plan's figures confirmed unchanged):
`LadderStepFrag.lean` 1,368 lines, no in-source `longFile` baseline, package limit 1500
(`lakefile.toml:34`) — 132 lines of headroom; wired probe 1,050 lines;
`KTypeSummaryAxiomTest.lean` 3,691 against an in-source `longFile 3700` — 9 lines of headroom.

## 1. The register's local law, in the ladder conditions' own terms

Re-derived from the live `RladAdm` / `Rlad` / `Count` / `Drift` / `Adm` definitions, not from any
record. `RladAdm step pend t x y` is `Rlad step pend t x.1 y.1`, whose four conjuncts are

```
step x.1 y.1 = true  ∧  (pend x.1 = false → x.2.1 = 0)  ∧
Drift x.2.2 y.2.2    ∧  Count (pend x.1) (pend y.1) x.2.1 x.2.2 y.2.1
```

The register `n = x.2.2` occurs in exactly two of them:

* in `Drift n n'`, which is `n' = n ∨ n' = n + 1 ∨ n' + 1 = n` — a free `±1`/`0` walk;
* inside `Count px py c n c'`, and there **only** at an idle-to-pending transition, where the
  branch `c' = n` seeds the new countdown. Inside a pending region (`px = py = true`) `Count` is
  `c' + 1 = c` and does not mention the register at all.

`Adm pend q = {c | pend q = false → c = 0}` constrains the **countdown**, never the register. So
**inside a pending region the register is an unconstrained `Drift` walk**, and exactly two
consequences are forced:

* `ProbeRowResidue.nxt_ge_sub` — the register falls by at most one per step; nothing bounds its
  rise;
* `ProbeRowResidue.gap_mono_of_pend` — since the countdown inside a region falls by exactly one
  per step, the gap `n - c` is **non-decreasing** along a region and rises by **at most two** per
  step.

`Probe761C.nxt_le_double` is about the IDLE register across a region. It is a different object,
is cited here only as context, and is not used.

## 2. What `Zrel` at the budget left demands of an answering pair

Quoted from the live definition (`LadderStepFrag.lean:201`), not paraphrased:

```lean
def Zrel (a b : ℕ) (x y : LadderState Q pend) : Prop :=
  x.1.1 = y.1.1 ∧
  (x.1.2.1 = y.1.2.1 ∨ (2 * (a + b) ≤ x.1.2.1 ∧ 2 * (a + b) ≤ y.1.2.1)) ∧
  (x.1.2.2 = y.1.2.2 ∨ (2 * (a + b) ≤ x.1.2.2 ∧ 2 * (a + b) ≤ y.1.2.2)) ∧
  ((x.1.2.2 : ℤ) - x.1.2.1 = (y.1.2.2 : ℤ) - y.1.2.1 ∨
    (2 * (a : ℤ) ≤ (x.1.2.2 : ℤ) - x.1.2.1 ∧ 2 * (a : ℤ) ≤ (y.1.2.2 : ℤ) - y.1.2.1) ∨
    ((x.1.2.2 : ℤ) - x.1.2.1 ≤ -(2 * (b : ℤ) + 2) ∧
      (y.1.2.2 : ℤ) - y.1.2.1 ≤ -(2 * (b : ℤ) + 2)))
```

At a budget `(a, b + 1)` one forward jump leaves `(a, b)`. The obligation on an answering pair is
therefore: one object state; countdowns **equal or both `≥ 2 (a + b)`**; registers **equal or both
`≥ 2 (a + b)`**; gaps **equal, or both `≥ 2 a`, or both `≤ -(2 b + 2)`**.

Inside a pending region both gaps start at `0` on this pair and are non-decreasing (section 1), so
the third gap escape `≤ -(2 b + 2)` is **dead** there and only the first two are live. This is the
measurement's governing arithmetic.

## 3. Fixture `R4` — the landed pair `xM` / `yM`

Write `C := cM P a b = (P + 1) * (a + (b + 1))`, the countdown `xM` carries; `yM` carries
`C + (P + 1)`; both registers equal their countdowns; `(K1)` gives `3 ∣ P + 1`, hence `P + 1 ≥ 3`.

**The longer region's object and countdown are forced** at every ladder path through `yM`
(`longer_region_forced`): at offset `j` they are `rotR^[j] R4.r0` and `C + (P + 1) - j`. Only the
register is free, which is what makes this a measurement of the register rather than a choice of
three coordinates. `stM_zero` anchors the exhibited family at the pair: `stM P a b h t 0 = yM P a b`.

**The exhibited answering position** is `ansM P t j = if j ≤ P then t + j else t + (j - (P + 1))`.
**The exhibited register** is `regM P h t j = if j ≤ P then nxtAt h (t + j) + (P + 1) else nxtAt h (t + (j - (P + 1)))`
— the shorter path's own register, raised by exactly the modulus over the longer region's extra
`P + 1` positions and copied unshifted afterwards.

`register_answerable_R4` compiles: for every `j ≤ C + (P + 1)`,
`Zrel a b (stM P a b h t j) (h (ansM P t j))`, for an arbitrary ladder path `h` through `xM`.
Non-vacuity: `exists_path_through_xM`.

**Values reached, by branch.**

* `j ≥ P + 1` (answer `i = j - (P + 1)`): **all four clauses by equality**. Countdowns
  `C + (P + 1) - j = C - i`; objects `rotR^[j] r0 = rotR^[i] r0` because `3 ∣ P + 1` returns the
  forced walk to where it started; register `regM = nxtAt h (t + i)`; gap equal as a consequence.
* `j ≤ P` (answer `i = j`): no countdown-matching partner exists — the longer region's countdown
  there exceeds every countdown in the shorter region. What carries it is section 1's one-sided
  law. `nxt_ge_sub` forces `nxtAt h (t + j) ≥ C - j ≥ C - P = (P + 1) (a + b) + 1 ≥ 3 (a + b) + 1`,
  so the **countdown and register clauses pass on their thresholds** `2 (a + b)`, while the **gap
  clause passes by equality**: `regM j - (C + (P+1) - j) = nxtAt h (t+j) - (C - j)`, the shorter
  path's own gap.

The overlap of the two branches is non-empty (`P + 1 ≤ C - 2(a+b)` because `(P+1)(a+b) ≥ 3(a+b) ≥ 2(a+b)`),
so the switch point is not forced to `P`; `P` is the one chosen.

## 4. Fixture `B5` — over the walk `region_end_matchable_B5` supplies, with `6 ∣ P + 1`

`region_end_matchable_B5` spends the longer region's extra `P + 1` positions in the `2`-cycle
`b0 → b1 → b0` and then copies the shorter walk, which needs `2 ∣ P + 1`. With `2 ∣ P + 1` the
walk `spliceB P` builds out of that cycle **is that cycle again**, so the longer region here walks
the `2`-cycle throughout. `6 ∣ P + 1` is the `(K1)` constraint carried in the statement's
hypotheses; `2 ∣ P + 1` is the part the object coordinate consumes.

`gLad c₀ t` is a concrete ladder path on `B5` (`gLad_isLadderPath`): a pending region ending at
`t + c₀`, object walking the `2`-cycle, register descending in lockstep with the countdown, idle
afterwards. The region extends infinitely into the past because `idle` is a sink in `B5` — a
pending state has no idle predecessor — which is the ladder conditions' own doing, not a choice.

`Mrel_gLad` puts the pair `gLad C t t` / `gLad (C + (P+1)) t t` at the same arithmetic as
`Mrel_xM_yM`. `register_answerable_B5` compiles: for every `j ≤ C + (P + 1)`,
`Zrel a b (gLad (C + (P+1)) t (t + j)) (gLad C t (ansM P t j))` — the **same** exhibited answering
map `ansM`.

**Values reached**: the exhibited register is `C + (P + 1) - j`, which is the longer path's **own**
register, so on this fixture the exhibition is realized by an actual ladder path rather than only
pointwise. The gap is `0` on both sides at every position. Past the modulus every clause holds by
equality; over the first `P + 1` positions the countdown and register clauses pass on their
thresholds (`C - j ≥ C - P ≥ 2(a+b)`) and the gap clause by equality (`0 = 0`).

**Ruling 23.** `B5` is used here as a **satisfiability** fixture, not as a refutation carrier:
nothing is refuted on it and nothing is claimed to be, so the enlarged option set the branching
supplies cannot defeat anything. The `3`-cycle branch `b0 → b2 → b3 → b0` is **not** exercised by
this measurement; what is measured is that the `2`-cycle route `region_end_matchable_B5` itself
constructs carries every `Zrel` clause. The measurement says nothing about walks taking the other
branch.

## 5. The verdict, and what it licenses

**Outcome (b).** The register coordinate is satisfiable at the `Mrel` pair on both landed fixtures,
with the answering registers exhibited as functions (`regM`; on `B5`, the path's own register).
The coordinate at which both of Phase 11.44's attacks stopped is therefore not an obstruction.

This **licenses Phase 11.47 and nothing else**. In particular it is **NOT a path forth**, **NOT a
`LnkRow`**, and **NOT an agreement of cells**. `LnkRow` additionally demands the recursive jump
structure and the back-matching condition at every budget; neither statement here supplies either,
and neither is named `exists_rowLinked_path`.

**The residual, stated so Phase 11.47 inherits it rather than discovers it.** On `R4` the exhibited
register's two branches are each a `Drift` walk, but they are **not shown to join into one** at the
switch: `regM`'s value just below the switch is the shorter register raised by `P + 1`, and just
above it is the shorter register unshifted at a position `P + 1` earlier, and `Drift` relates the
two only by accident. A `LnkRow` needs the longer row to be an actual ladder path, so Phase 11.47's
induction must either carry a single `Drift`-continuous register across the switch or re-choose
the answering map so that no switch is needed. `B5` shows the obstacle is not universal: there the
single walk `C + (P + 1) - j` works throughout and is realized by `gLad`.

## 6. What this phase does NOT establish

It bears on the path forth's **register** coordinate and on nothing else. It says nothing about the
clip (Ruling 16), nothing about `ladderLift`, and it does **not** revive `cellAt_const_of_kappa_eq`
or `ladderRealized` under their pinned names — both remain unclaimed in `FormalSystem/` and
`Tests/`. No fourth relation is stated, no conjunct is added to `Mrel`, no new `def` relating two
ladder states is landed, and the countdown and object coordinates are consumed as settled inputs
rather than re-attacked (Ruling 22).

## 7. Compiled declarations (Ruling 25: every name below is a declaration `grep` finds)

Appended to `specs/evidence/seam-gluing-ray-product/ladder-row-link-residue-obstruction.lean`
(append-only; 466 insertions, 0 deletions):

`nxt_ge_sub`, `gap_mono_of_pend`, `cM`, `ansM`, `regM`, `pendR_rotR_iterate`, `stM`, `stM_zero`,
`longer_region_forced`, `register_answerable_R4`, `exists_path_through_xM`, `cyc2Bz`,
`cyc2Bz_pend`, `cyc2Bz_step`, `cyc2Bz_idle`, `gLad`, `gLad_isLadderPath`, `gLad_at`, `Mrel_gLad`,
`register_answerable_B5`.

Nine `#print axioms` guards, each reporting a subset of `[propext, Classical.choice, Quot.sound]`.

In `FormalSystem/Metalogic/Decidability/RaySummary/LadderStepFrag.lean`: an appended
`/-! ### What the register coordinate measures at the `Mrel` pair -/` block in the `Threshold`
section. **No library-side theorem was landed**, because both measurements are stated at probe-local
fixtures (`R4`, `B5`) that do not exist in the library; consequently no axiom-profile pin was owed
and `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` was **not touched**, so its nine-line
`longFile` headroom was not spent. `LadderStepFrag.lean` went from 1,368 to 1,396 lines, inside the
package-wide `longFile 1500`, so no in-source baseline was added.

---

# Phase 11.47 — the `LnkRow` recursive-induction scaffold

## 8. Entry gate, re-derived (not read off a marker)

Section 5 above records **outcome (b)**, read here from this record's own text and not from any
phase marker. Every declaration section 7 calls compiled was re-grepped at this phase's entry
with `grep -rnE '(theorem|lemma|def|abbrev) +<name>\b' FormalSystem/ Tests/ specs/evidence/`:
`nxt_ge_sub` (`ladder-row-link-residue-obstruction.lean:1091`), `gap_mono_of_pend` (`:1109`),
`regM` (`:1141`), `longer_region_forced` (`:1178`), `register_answerable_R4` (`:1209`),
`exists_path_through_xM` (`:1290`), `gLad_isLadderPath` (`:1328`), `Mrel_gLad` (`:1385`),
`register_answerable_B5` (`:1433`). All found. Ruling 25 discharged at entry.

The library inventory was re-derived the same way, against
`FormalSystem/Metalogic/Decidability/RaySummary/LadderStepFrag.lean`:

| Declaration | Line | What it already carries |
|---|---|---|
| `Zrel` | 201 | object equal; countdowns equal or both `≥ 2(a+b)`; registers equal or both `≥ 2(a+b)`; gaps equal, or both `≥ 2a`, or both `≤ -(2b+2)` |
| `Zrel.succ` / `Zrel.pred` | 223 / 312 | the one-step closure conditions, forward and backward |
| `exists_path_through` | 438 | a ladder path through any state at any position, from the two seriality hypotheses |
| `Lnk` | 469 | the WINDOW link: `Zrel` at `t+i` for `-a ≤ i ≤ b`, at the budget left |
| `exists_linked_path` | 503 | the path forth **at the window level**, by two `Nat` inductions |
| `FwdJump` / `BwdJump` | 612 / 617 | the jump conditions, with their back-matching clause |
| `FwdJump.mono` / `BwdJump.mono` | 621 / 629 | relation-monotonicity of both jump conditions |
| `LnkRow` | 642 | the ROW link, by well-founded recursion on `a + b` |
| `LnkRow.zero/.symm/.mono/.succ/.pred/.toLnk` | 653–713 | projections and budget monotonicity |
| `exists_rowLinked_path_zero` | 750 | the path forth at budget `(0,0)` ONLY — `LnkRow 0 0` |
| `truth_iff_of_lnkRow` | 1129 | the whole `⊡`-free truth lemma over the row link, `untl` and `snce` cases included |
| `Srel` / `Mrel` | 1255 / 1338 | the residue-carrying and threshold-carrying state relations |

`LadderPump` / `LadderChain`: re-derived by `grep` at this phase's entry — see section 11.

## 9. The induction's invariant and its closure property, STATED BEFORE THE ATTEMPT

`LnkRow a b g g' t t'` is a well-founded recursion on `a + b` whose unfolding is a conjunction of
(i) `Zrel a b (g t) (g' t')` and (ii) four jump conditions, each over `LnkRow` at a budget one
smaller. Nothing in the tree derives (ii) at a positive budget. The invariant that does is a
BUDGET-INDEXED POSITION RELATION, carried abstractly so the induction can be audited:

> **Invariant.** A family `S : ℕ → ℕ → ℤ → ℤ → Prop`, read as "position `t` of `g` and position
> `t'` of `g'` answer each other at the budget `(a, b)".

> **Closure property (three clauses, and they are exactly the three conjuncts of `LnkRow`):**
> 1. **soundness** — `S a b t t' → Zrel a b (g t) (g' t')`;
> 2. **forward closure** — `S a (b+1) t t'` implies `FwdJump (S a b) t t'` AND
>    `FwdJump (flip (S a b)) t' t`;
> 3. **backward closure** — `S (a+1) b t t'` implies `BwdJump (S a b) t t'` AND
>    `BwdJump (flip (S a b)) t' t`.

> **Conclusion.** `S a b t t' → LnkRow a b g g' t t'`, for EVERY `(a, b)`, positive included.

The induction is `Nat.strong_induction_on` on `a + b`, mirroring `LnkRow.symm` and `LnkRow.mono`;
`FwdJump.mono` and `BwdJump.mono` transport the induction hypothesis under the jump conditions and
are re-used rather than re-proved. At `(0,0)` both jump clauses are vacuous and the conclusion is
`Zrel 0 0`, which is what `exists_rowLinked_path_zero` already supplies — that lemma is the base
case of the CONSUMER (`exists_rowLinked_path`), not of the scaffold, whose own base case is the
vacuity of clauses 2 and 3.

This is deliberately a COINDUCTION-SHAPED principle: it converts "build the whole row
correspondence" into "exhibit one relation and check it is closed under both jumps". It adds no
hypothesis to `LnkRow`, weakens nothing, and is positionwise in neither direction — its conclusion
is a `LnkRow` at an arbitrary budget, read from the signature.

## 10. Item 1 — the scaffold, LANDED

`LnkRow.of_closed` (`FormalSystem/Metalogic/Decidability/RaySummary/LadderStepFrag.lean`, section
`Scaffold`). It is the first derivation of a row link at a POSITIVE budget anywhere in the tree.
Signature, read off the source:

```
theorem LnkRow.of_closed {g g' : ℤ → LadderState Q pend} (S : ℕ → ℕ → ℤ → ℤ → Prop)
    (hzr : ∀ a b t t', S a b t t' → Zrel a b (g t) (g' t'))
    (hfw : ∀ a b t t', S a (b + 1) t t' →
      FwdJump (fun s s' => S a b s s') t t' ∧ FwdJump (fun s' s => S a b s s') t' t)
    (hbw : ∀ a b t t', S (a + 1) b t t' →
      BwdJump (fun s s' => S a b s s') t t' ∧ BwdJump (fun s' s => S a b s s') t' t)
    (a b : ℕ) (t t' : ℤ) (h : S a b t t') : LnkRow a b g g' t t'
```

`#print axioms`: `[propext, Quot.sound]`. The three hypotheses are literally the three conjuncts of
`LnkRow`'s unfolding with `S` for the recursive occurrence; the proof is
`Nat.strong_induction_on` on `a + b`, re-using `FwdJump.mono` and `BwdJump.mono` and re-proving
nothing. `LnkRow`, `Zrel`, `Mrel`, `Srel` and `FwdJump`/`BwdJump` are untouched; no hypothesis was
added to any of them.

It is checked as RECURSIVE rather than positionwise two ways: the budget `(a, b)` is universally
quantified and the conclusion is a `LnkRow` at it, read from the signature above; and
`Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` instantiates it at the POSITIVE budget
`(3, 5)` in an `example`, so a version silently restricted to `(0, 0)` would fail to typecheck.

## 11. Items 2–4 — the owed `exists_rowLinked_path` over `Mrel` is FALSE AS OWED

Before writing a count move, the owed consumer's statement was read against the relation it is
owed over. `Mrel P a b` carries `P` as a **bare natural number**: nothing in its definition, and
nothing in the signature Phase 11.47 owes, relates `P + 1` to the object. The modulus condition is
`(K1)` = `paramsOkK1` (`CounterQuotient.lean:866`), and it lives on the counter-quotient side.

At `P + 1 ≤ 2` the raised countdown threshold `(P + 1) * (a + (b + 1))` is at most
`2 * (a + b) + 2`, which the SHORTER countdown of the tight pair `xR` / `yR` meets exactly. So that
pair — the pair `no_rowLinked_path_of_Srel` already refutes the path forth from, via
`not_lnkRow_xR_yR`, which carries no divisibility hypothesis at all — **is `Mrel`-related at
`P ≤ 1`**. Three theorems, appended to
`specs/evidence/seam-gluing-ray-product/ladder-row-link-residue-obstruction.lean` (append-only) and
compiled with their `#print axioms` guards:

| Declaration | What it states |
|---|---|
| `Mrel_xR_yR_of_small_modulus` | at `P ≤ 1` the tight pair IS `Mrel P a (b+1)`-related |
| `no_rowLinked_path_of_Mrel_at_small_modulus` | at `P ≤ 1` and every row budget `(a, b+1)` with `1 ≤ a+b`, two `Mrel`-related states of `R4`, a path through the first, and no row-linked path through the second |
| `exists_rowLinked_path_over_Mrel_refuted` | the owed statement, quantified over `Q`, `step`, `pend`, `P`, `a`, `b` exactly as owed, is FALSE |

**What this does and does not close.** It closes the statement AS OWED: items 2, 3 and 4 cannot be
landed over `Mrel` at the signature the plan fixes, because no construction can exist. It does
**not** refute the path forth at a `(K1)`-admissible modulus for `R4` — every such modulus has
`3 ∣ P + 1`, hence `P + 1 ≥ 3`, where `not_Mrel_xR_yR` excludes this pair and section 5's
measurement found the register coordinate answerable at a re-aimed pair. The live question is the
`(K1)`-RESTRICTED path forth, and restricting it adds a hypothesis to a recorded signature, which
this phase's own prohibitions route to the user rather than take.

`LadderPump` / `LadderChain`, re-read as the second task requires: `LadderPump` is the splice and
deletion INDEX layer (`delIdx`, `spliceEmb`, `delIdx_strictMono`, `spliceIdx_delIdx`, `delObj`,
`delCnt` — `LadderPump.lean:78–139`), and `LadderChain` carries the budget and margin lemmas
(`budget_le_cascadeBound:189`, `budget_le_Tc:203`, `budget_mul_succ_le_Tc:212`,
`two_pow_card_prodState_le_Tc:240`). Neither was consumed: both are machinery for the count moves,
and the count moves have no statement left to serve.

## 12. The `(K2)` margin AT THE RAISED THRESHOLD — MEASURED, and NOT consumed

The phase's `(K2)` item is taken as a measurement rather than deferred, at `Mrel`'s raised
threshold and not at `Zrel`'s. `(K2)` = `paramsOkK2` (`CounterQuotient.lean`) has as its third
conjunct

```
card Q * 2 ^ |closure φ| * (P + 1) * (sup stabDepth + 1) ≤ Tc
```

whose `(P + 1)` factor is exactly `Mrel`'s raised margin per unit of budget, and whose
`card Q * 2 ^ |closure φ|` factor is the type-pigeonhole budget this layer's row budget is bounded
by (`budget_le_cascadeBound`, `card_prodState`). Landed in `LadderStepFrag.lean`, section
`RaisedMargin`:

```
theorem Mrel.threshold_le_Tc {Q : Type} [Fintype Q] {step pend lab φ} {Tc Tn P B : ℕ} (a b : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hab : a + b ≤ Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card) :
    (P + 1) * (a + b) ≤ Tc
```

`#print axioms`: `[propext, Classical.choice, Quot.sound]`. **The margin is NOT consumed by the
raise**, so no `(K2)` finding and no new ruling on `(K2)` is owed. The remaining factor
`(sup stabDepth + 1) ≥ 1` is slack.

A second, independently checkable fact bearing on the repair: `(K1)` is a DIVISIBILITY condition
into `P + 1` and **does not bound `P` from above** — stated at `CounterQuotient.lean:431` and
re-read here. So a `(K1)`-restricted repair of the owed signature constrains `P` from below only,
and `Mrel.threshold_le_Tc` is what supplies the room it then needs.

## 13. What fragment of the language is covered by an AGREEMENT OF CELLS after this phase

**None that was not covered before it.** `truth_iff_of_lnkRow` (`LadderStepFrag.lean:1129`) is a
whole `⊡`-free truth lemma over the row link and was already landed; the `untl` clause this phase
owed is its corollary against `exists_rowLinked_path`, and `exists_rowLinked_path` did not land —
it is refuted at the signature owed. So the covered fragment is still the budget-`(0,0)` level that
`exists_rowLinked_path_zero` reaches, and **not** `untl` at the `⊡`-free level over `Mrel`. The
`snce` mirror and the `⊡` lift remain owed to Phase 11.40 exactly as before, and that phase's gate
on this one is NOT satisfied.

Phases 11.39, 11.42 and 11.45 stay closed at their own markers, and this phase neither re-marked
nor wrote into any of them (Rulings 17, 21, 24, 26). The deliverable was re-pointed here and has
now been measured rather than re-pointed again: the measurement is that the deliverable's
STATEMENT, not its construction, is what is wrong.

## 14. Ruling 25's check before committing

Every declaration this round asserts as compiled, re-grepped with
`grep -rnE '(theorem|lemma|def|abbrev) +<name>\b' FormalSystem/ Tests/ specs/evidence/`:
`LnkRow.of_closed`, `Mrel.threshold_le_Tc` (both `FormalSystem/.../LadderStepFrag.lean`);
`Mrel_xR_yR_of_small_modulus`, `no_rowLinked_path_of_Mrel_at_small_modulus`,
`exists_rowLinked_path_over_Mrel_refuted` (all `specs/evidence/.../ladder-row-link-residue-obstruction.lean`).
`exists_rowLinked_path` itself is NOT claimed compiled and `grep` finds no declaration of that name
— only `exists_rowLinked_path_zero`. `cellAt_const_of_kappa_eq` and `ladderRealized` remain
unclaimed in `FormalSystem/` and `Tests/`.
