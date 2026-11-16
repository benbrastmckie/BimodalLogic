# Round 28 — Route (R-3): the path forth attacked AT a `(K1)`-admissible modulus, on `R4` and `B5`

Phase 11.48 of `plans/28_k1-admissible-refutation-first.md`. Decision 21, Ruling 27: **attack
before adopt**. Nothing is adopted, stated or repaired in this round; Phase 11.49 is a separate
phase and is not entered here.

## 0. Entry gate, re-derived from the record's own text (not read off a marker)

`records/round-27-register-coordinate-measurement.md` sections 8–14 were read in full at this
phase's entry. Their disposition, read from that text:

- **Item 1 LANDED**: `LnkRow.of_closed` (section 10), the first derivation of a row link at a
  POSITIVE budget anywhere in the tree, axioms `[propext, Quot.sound]`.
- **Items 2–4 REFUTED AT THE OWED SIGNATURE** (section 11): `Mrel P a b` carries `P` as a bare
  natural with nothing tying `P + 1` to the object, so at `P + 1 ≤ 2` the raised threshold is met
  by the tight pair `xR`/`yR` that `not_lnkRow_xR_yR` already kills.
- Section 11's own closing paragraph records that this refutation **does NOT reach a
  `(K1)`-admissible modulus** — the gap this round probes.
- **`(K2)`'s margin is SETTLED** (section 12, Ruling 30) and is NOT re-measured here.

**Ruling 25 check at entry.** Every declaration sections 8–14 call compiled was re-grepped with
`grep -rnE '(theorem|lemma|def|abbrev) +<name>\b' FormalSystem/ Tests/ specs/evidence/`. All
found: `LnkRow.of_closed` (`LadderStepFrag.lean:1424`), `Mrel.threshold_le_Tc` (`:1470`),
`Mrel_xR_yR_of_small_modulus` (probe `:1546`), `no_rowLinked_path_of_Mrel_at_small_modulus`
(`:1560`), `exists_rowLinked_path_over_Mrel_refuted` (`:1575`). The fixture inventory was
re-grepped the same way and all found: `gB_isLadderPath` (`:749`), `gLad_isLadderPath` (`:1328`),
`region_end_agrees_R4` (`:948`), `region_end_matchable_B5` (`:997`), `register_answerable_R4`
(`:1209`), `register_answerable_B5` (`:1433`), `not_Mrel_xR_yR` (`:884`), `not_lnkRow_xR_yR`
(`:493`), `exists_path_through_xM` (`:1290`), `LnkRow.first_zero` (`LadderStepFrag.lean:1042`),
`LnkRow.region_end_obj` (`:1066`), `regM` (probe `:1141`), `nxt_ge_sub` (`:1091`),
`gap_mono_of_pend` (`:1109`), `longer_region_forced` (`:1178`), `Mrel_gLad` (`:1385`).

**Carried figures, re-measured live at this phase's entry rather than carried on trust.**
`FormalSystem/Metalogic/Decidability/RaySummary/LadderStepFrag.lean` = **1,485** lines;
`Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` = **3,729**;
`specs/evidence/seam-gluing-ray-product/ladder-row-link-residue-obstruction.lean` = **1,599**.
All three match plan v28's authoring figures exactly — **confirmed unchanged**, not merely
assumed.

## 1. The attack targets, STATED IN ADVANCE OF THE FIRST ATTEMPT

The plan requires this section to exist before any proof is attempted, because four rounds have
turned on a target chosen inside the proof. Written here first; the verdicts are sections 3–5.

### Attack A — `R4`, at `3 ∣ P + 1`, lead 1 (the register's switch)

- **Pair attacked**: `xM P a b` / `yM P a b`, the landed re-aimed pair of `Mrel_xM_yM`. The tight
  pair `xR`/`yR` is **not** available at this modulus — `not_Mrel_xR_yR` excludes it outright
  under `3 ∣ P + 1` — which is precisely why Phase 11.47's refutation does not reach here.
- **Coordinate aimed at**: **the REGISTER**, at the switch `j = P → j = P + 1` of the exhibited
  answering map `ansM`, where round 27 section 5 recorded that `regM`'s two branches are each a
  `Drift` walk but **are not shown to join into one**.
- **Obstruction lemma targeted**: NOT `LnkRow.region_end_obj` — `region_end_agrees_R4` already
  discharges it at this pair, so that door is shut. The target is the `Drift` continuity of the
  longer path's register across the switch, read against `Zrel`'s **gap** clause, the only clause
  `regM`'s two branches treat differently.
- **Statement attempted**: `¬ LnkRow a (b + 1) h h' t t` for every pair of ladder paths `h`, `h'`
  through `xM`, `yM`, under `3 ∣ P + 1` and `1 ≤ a + b`.

### Attack B — `B5`, at `6 ∣ P + 1`, leads 2 and 3

- **Pair attacked**: the `Mrel` pair of `Mrel_gLad`, over the concrete path `gLad`.
- **Lead 2 — the past row**: `LnkRow` is symmetric in the budget, so at `a ≥ 1` the `BwdJump`
  clause demands the same correspondence at every lower budget. `gLad`'s pending region extends
  into the past because `idle` is a sink there. **Coordinate aimed at**: the countdown and object
  in the PAST, against `LnkRow.first_zero`.
- **Lead 3 — the unexercised `3`-cycle branch `b0 → b2 → b3 → b0`**: Ruling 23 recorded that
  `region_end_matchable_B5` constructs only the `2`-cycle route. A refutation must show no second
  walk answers; the branch enlarges the option set, so a refutation there is strictly stronger.
- **Statement attempted**: the same shape as Attack A, over `B5` at `6 ∣ P + 1`.

### What would COUNT, and what would not

A refutation discharges this phase only if it carries its fixture's divisibility hypothesis
(`3 ∣ P + 1`, or `6 ∣ P + 1`) **in its own binder list** and names a compiled `IsLadderPath`
witness through the state it quantifies over. A refutation without the divisibility hypothesis is
a restatement of Phase 11.47's result.

## 2. The goal state Attack A reaches on `R4`, recorded verbatim

The refutation target was stated and attempted as

```
theorem attackA (P a b : ℕ) (h3 : 3 ∣ P + 1) (hab : 1 ≤ a + b)
    (h h' : ℤ → LadderState R4 pendR) (hh : IsLadderPath stepR pendR h)
    (hh' : IsLadderPath stepR pendR h') (t : ℤ) (ht : h t = xM P a b) (ht' : h' t = yM P a b) :
    ¬ LnkRow a (b + 1) h h' t t
```

driven down the landed skeleton of `not_lnkRow_xR_yR`: unfold `LnkRow`, take the forward jump
`hl.2.1 b rfl`, challenge at `t + 3` of the longer row. The state at the point where the landed
proof closes and this one does not (`trace_state`, reproduced):

```
hj : FwdJump (fun s' s => LnkRow a b h h' s s') t t
s : ℤ
hs : t < s
hR : LnkRow a b h h' s (t + 3)
hbt : ∀ (r' : ℤ), t < r' → r' < s → ∃ r, t < r ∧ r < t + 3 ∧ LnkRow a b h h' r' r
e3 : objAt h' (t + 3) = R4.r0
c3 : cntAt h' (t + 3) = cM P a b + (P + 1) - 3
hq : (↑(h s)).1 = (↑(h' (t + 3))).1
hcnt : (↑(h s)).2.1 = (↑(h' (t + 3))).2.1 ∨ 2 * (a + b) ≤ (↑(h s)).2.1 ∧ 2 * (a + b) ≤ (↑(h' (t + 3))).2.1
hnxt : (↑(h s)).2.2 = (↑(h' (t + 3))).2.2 ∨ 2 * (a + b) ≤ (↑(h s)).2.2 ∧ 2 * (a + b) ≤ (↑(h' (t + 3))).2.2
hgap : ... ∨ ... ∨ ...
hq' : objAt h s = objAt h' (t + 3)
⊢ False
```

**Why it does not close, and the landed proof does.** `not_lnkRow_xR_yR` closes because the tight
pair's shorter countdown is `2 (a + b) + 2`: the threshold branch of `hcnt` forces `s - t ≤ 2`, and
`t + 1`, `t + 2` carry `r1`, `r2` against the challenger's `r0`. At the raised threshold the
shorter countdown is `(P + 1) (a + (b + 1)) ≥ 3 (a + b + 1)`, so the threshold branch admits every
`s` with `s - t ≤ cM − 2(a+b)`, a range of width at least `a + b + 3 ≥ 4`; and `3 ∣ P + 1` makes
the forced walk's period divide the shift, so residue `0` recurs inside that range. `s = t + 3`
satisfies `hq'`, `hcnt` and `hnxt` outright.

## 3. `R4` — the per-fixture verdict, reported separately

**NO REFUTATION FOUND at `3 ∣ P + 1`.** Two compiled results, both appended to the wired probe:

| Declaration | What it records | Stalled coordinate |
|---|---|---|
| `attackA_stall_countdown` | at an admissible modulus `t + 3` of the shorter region carries the SAME object as the challenger `t + 3` of the longer one, and both countdowns clear `2 (a + b)` — the landed refutation's exclusion step is unavailable | **countdown** |
| `attackA_mirror_register_joins` | the shorter path's own register raised by `P + 1` is a `Drift` walk, starts exactly at `yM`'s register, and makes the gap clause hold by EQUALITY at every offset — a register joining `ansM`'s switch exists for EVERY ladder path through `xM` | **register** |

Lead 1 is therefore answered, and answered negatively for the attacker: round 27 section 5's
residual — that `regM`'s two branches "are not shown to join at the switch" — is a property of
`regM`, whose first branch raises the shorter register by `P + 1` while its second copies it
unshifted. The register that joins raises it by `P + 1` THROUGHOUT. No discontinuity is forced.

## 4. `B5` — the per-fixture verdict, reported separately

**NO REFUTATION FOUND at `6 ∣ P + 1`.** `B5` was attacked, not skipped; decision 21's closing
sentence is honoured. Three compiled results:

| Declaration | What it records | Stalled coordinate |
|---|---|---|
| `attackB_past_row_answerable` (lead 2) | at every past offset the two states are `Zrel`-related at every budget: both regions lengthen together, objects agree at equal offsets, countdowns and registers stay above every threshold, both gaps stay `0` | **countdown in the past** — the backward direction is strictly EASIER here, not harder |
| `region_end_matchable_B5_cyc3` (lead 3) | at `3 ∣ P + 1` the `3`-cycle branch supplies a splice of its own whose extra `P + 1` positions avoid `b1` entirely | **object** |
| `avoid_b1_closed_walk_three_dvd` + `avoid_b1_walk_forced` | every closed pending walk at `b0` avoiding `b1` has length divisible by `3` | — (the boundary) |

**Lead 3's attack is REAL and was properly aimed.** `region_end_matchable_B5` spends the extra
`P + 1` positions in the `2`-cycle (`spliceB`), so a shorter walk confined to the `3`-cycle — which
never visits `b1` — would leave those positions with no object-matching partner. That attack
SUCCEEDS at a modulus with `2 ∣ P + 1` and `3 ∤ P + 1`. It fails at a `(K1)`-admissible one, because
`(K1)` demands `l ∣ P + 1` for EVERY pending cycle length and `B5` has both `2` and `3`, giving
`6 ∣ P + 1`. `avoid_b1_closed_walk_three_dvd` states the boundary exactly: **the admissibility
constraint is not slack on this object — `3 ∣ P + 1` is what buys the escape.**

Lead 2 stalls for the structurally opposite reason to lead 3: the past is not a harder row but an
easier one, because both regions grow together going back and nothing separates them.

## 5. THE OUTCOME LETTER: **(b)** — NOT REFUTED ON EITHER FIXTURE

Both fixtures reached a verdict; neither yielded a refutation. Per the phase's own definition this
is **outcome (b)**, and Phase 11.49 is thereby licensed.

**THE TWO CLAIMS ARE DIFFERENT AND THIS RECORD SAYS WHICH ONE IT IS MAKING.** What is established
is that **no refutation was found** at a `(K1)`-admissible modulus on `R4` or `B5`, with the
coordinate each attack stalled on named and compiled. What is **NOT** established, and is **not
asserted anywhere in this round or in the probe**, is that the path forth is provable. The attacks
above address the `Zrel` clauses at exhibited pairs; a row link additionally demands the recursive
jump structure and the back-matching condition at every budget, and **nothing in this round touches
either**. `exists_rowLinked_path` remains unproved, and `grep` finds no declaration of that name —
only `exists_rowLinked_path_zero`, the budget-`(0,0)` case landed long before this round.

**Nothing was adopted.** No relation was repaired, no conjunct added, no threshold raised, no
hypothesis added to any recorded signature, `(K2)`'s margin not re-measured (Ruling 30),
`LnkRow.of_closed` not re-derived (Ruling 29). Route (R-2) — the object half of `(K1)` as a
hypothesis of `exists_rowLinked_path`, plus its bridge to `ParamsOk` — is Phase 11.49's work and
was not begun here.

## 6. Phase-marker hygiene (Rulings 17, 21, 24, 26, 28)

Phases 11.39, 11.42, 11.44, 11.45 and 11.47 stay exactly at their own markers. **This phase
re-marked none of them and wrote into none of them.** The only plan-file edit this round makes is
to the Phase 11.48 heading itself.

## 7. Ruling 25's check before committing

Every declaration this record asserts as compiled, re-grepped with
`grep -rnE '(theorem|lemma|def|abbrev) +<name>\b' FormalSystem/ Tests/ specs/evidence/` AFTER the
append, all found in
`specs/evidence/seam-gluing-ray-product/ladder-row-link-residue-obstruction.lean`:
`attackA_stall_countdown`, `attackA_mirror_register_joins`, `cyc3Bidx`, `cyc3Bidx_step`,
`cyc3Bidx_pend`, `cyc3Bidx_ne_b1`, `splice3B`, `region_end_matchable_B5_cyc3`,
`avoid_b1_walk_forced`, `avoid_b1_closed_walk_three_dvd`, `attackB_past_row_answerable`.
Every one carries an inline `#print axioms` guard reporting `[propext, Quot.sound]`, a strict
subset of the permitted set.

`exists_rowLinked_path`, `cellAt_const_of_kappa_eq` and `ladderRealized` are **not** claimed
compiled and `grep` finds no declaration of any of the three.

**The admissibility check, mechanical.** Every declaration this round lands that speaks about a
modulus carries its fixture's divisibility hypothesis in its own binder list, read off the
signature: `attackA_stall_countdown (h3 : 3 ∣ P + 1)`, `region_end_matchable_B5_cyc3
(h3 : 3 ∣ P + 1)`, `attackB_past_row_answerable (h6 : 6 ∣ P + 1)`.
`attackA_mirror_register_joins` carries none and claims none — it is a statement about `Drift`
continuity that holds at every `P`, and it is not a refutation.

**The non-vacuity check.** `R4`: ladder paths through `xM` exist at every position
(`exists_path_through_xM`, landed). `B5`: `gLad_isLadderPath` and `gB_isLadderPath`, both landed.

## 8. Deviation from plan v28, recorded rather than annotated silently

Plan v28's Scope Hypothesis says **ZERO** compiled theorems land in the wired probe on outcome (b),
and its Files-to-modify line says the probe is "untouched on outcome (b)". **Six measurement
declarations were appended anyway** (append-only: 287 insertions, 0 deletions, confirmed by
`git diff`). The reason is Ruling 25: this record makes "is compiled" claims about the switch
joining, the `3`-cycle splice and the past row, and a claim that names no declaration `grep` finds
is exactly the failure a past dispatch committed when it fabricated `no_rowLinked_path_of_Mrel`.
Withholding the declarations would have turned this round's verdict into unverifiable prose.

`FormalSystem/.../LadderStepFrag.lean` and `Tests/.../KTypeSummaryAxiomTest.lean` are **untouched**
— the plan scoped the former's docstring paragraph to outcome (a), and the axiom pins went inline in
the probe, which is that file's own established convention. Neither file-length baseline was
approached: both stand unchanged at 1,485 and 3,729 lines.

## 9. Verification run for this phase

| Gate | Result |
|---|---|
| `lake-build-guard.sh build --timeout 1800 -- build` | exit 0, **2,976 jobs**, `grep -c "error:"` = 0 |
| `lake-build-guard.sh build --timeout 1800 -- build BimodalTest` | exit 0, **3,044 jobs**, `grep -c "error:"` = 0 |
| `scripts/check-evidence-probes.sh` | **PASS — all 65 wired probes compile** |
| `scripts/check-module-invariants.sh` | **ALL CHECKS PASSED** |
| `scripts/readme-lint.sh` | **PASS** (0 broken file references) |
| `grep -rn 'sorry\|native_decide'` on probe + `LadderStepFrag.lean` | only the header docstring's "No `sorry`" sentence |
| `git diff` on the wired probe | **287 insertions, 0 deletions — appended hunks only** |

---

# Round 28, part 2 — Phase 11.49, route (R-2): the object half of `(K1)` as a hypothesis

## 10. Entry gate, re-derived from section 5 of this same record

Section 5 above reads **outcome (b)**: both fixtures reached a verdict, neither yielded a
refutation. The gate was read from that text and not from a phase marker. Every declaration
section 7 lists as compiled was re-grepped at entry with
`grep -rnE '(theorem|lemma|def|abbrev) +<name>\b' FormalSystem/ Tests/ specs/evidence/`; all
eleven were found, and `exists_rowLinked_path` was confirmed still absent (only
`exists_rowLinked_path_zero`, `LadderStepFrag.lean:750`). Phase 11.49 is therefore licensed.

**What section 5 licenses, and what it does not.** It licenses ADDING the hypothesis. It is not
evidence that the path forth is provable: the attacks of sections 3 and 4 address the `Zrel`
clauses at exhibited pairs, and a row link additionally demands the recursive jump structure and
the back-matching condition at every budget. Neither was touched there, and the induction is this
phase's own work.

## 11. The repaired signature, STATED IN ADVANCE OF THE FIRST ATTEMPT

```lean
theorem exists_rowLinked_path {Q : Type} [Fintype Q] {step : Q → Q → Bool} {pend : Q → Bool}
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    {P : ℕ} (hK1 : ∀ l ∈ objCycleLens step pend, l ∣ (P + 1))
    (a b : ℕ) (h : ℤ → LadderState Q pend) (hh : IsLadderPath step pend h) (t : ℤ)
    (y : LadderState Q pend) (hM : Mrel P a b (h t) y) :
    ∃ h' : ℤ → LadderState Q pend, IsLadderPath step pend h' ∧ h' t = y ∧
      LnkRow a b h h' t t
```

### The diff against the signature `round-24-jump-clause-verdict.md` section 3 recorded as owed

The owed goal recorded there, at the candidate hypothesis of that round, was

```
⊢ ∃ h', IsLadderPath step pend h' ∧ h' t = y ∧ LnkRow a (b + 2) h h' t t
```

under `fwd`, `bwd`, `h`, `hh : IsLadderPath step pend h`, `t`, `y`, and a state relation on
`(h t, y)`.

| Difference | Verdict |
|---|---|
| `(hK1 : ∀ l ∈ objCycleLens step pend, l ∣ (P + 1))` added | **THE ONE SANCTIONED DIFFERENCE** (decision 21, route (R-2)) |
| `[Fintype Q]` added | **Forced by the sanctioned difference, not a second hypothesis**: `objCycleLens` does not elaborate without it. It is an instance binder, carries no mathematical content beyond finiteness of the object, and `Mrel.threshold_le_Tc` already takes it in this same module. Recorded rather than passed over. |
| the state relation is `Mrel P a b` rather than round 24's `Zrel (a + b + 1) (a + b)` | Not a difference introduced here: round 24's candidate was refuted (`no_rowLinked_path_of_Zrel`), `Srel` after it (`no_rowLinked_path_of_Srel`), and `Mrel` is the relation Phase 11.44 landed and Phase 11.47 re-aimed. Carried, not chosen. |
| budget `(a, b)` universally quantified rather than `(a, b + 2)` | A strengthening, not a weakening: the recorded goal was one instantiation of this. |
| no `lab`, no `φ` | **The point of (R-2).** See the mechanical check in section 13. |

Nothing else is added. In particular `paramsOkK1` in full is **NOT** taken — that is (R-1), and
it is rejected by the user because it drags `lab` and `φ` into a layer free of the formula index.

## 12. The bridge to `ParamsOk`, landed and recorded (item 2)

```lean
theorem objHalfK1_of_paramsOk {Q : Type} [Fintype Q] {step : Q → Q → Bool} {pend : Q → Bool}
    {lab : Q → Atom → Bool} {φ : PlusFormula} {Tc Tn P B : ℕ}
    (hp : ParamsOk step pend lab φ Tc Tn P B) :
    ∀ l ∈ objCycleLens step pend, l ∣ (P + 1) :=
  hp.1.2.1
```

Landed in `LadderStepFrag.lean`, beside the consumer, so that no later phase re-derives a
projection path. `#print axioms` (via `lean_verify`): `[propext, Classical.choice, Quot.sound]`, a
subset of the permitted set. Composed with `paramsOk_params` it discharges the added hypothesis at
the four parameters the periodicity fixpoint defines, so the repaired consumer is not vacuous.

**A STATEMENT FIDELITY OBSERVATION, recorded rather than silently absorbed.** Plan v28 item 2
says "There is no predicate in the library equal to the object half alone" and treats the bridge
as wholly new. The first clause is correct — no *predicate* equals it. But the *projection lemma*
already existed: `objCycle_dvd_succ_of_paramsOk` (`LadderAgree.lean:1032`) is literally
`hp.1.2.1` in POINTWISE form, `{l : ℕ} (hl : l ∈ objCycleLens step pend) : l ∣ (P + 1)`, and
`LadderAgree` is in `LadderStepFrag`'s import closure (computed over the `import` graph, not
assumed). The bridge owed here is the BUNDLED `∀` form the path forth's binder list contains, and
it is a one-line corollary rather than a fresh derivation. It is still landed under its own name,
because the plan's reason for demanding it — that no downstream phase re-derive a projection
path — is served by the bundled form existing beside the consumer.

## 13. The mechanical checks the phase owes, run and reported

| Check | Result |
|---|---|
| `lab`/`φ` do NOT enter the row-link layer | **PASS.** `exists_lengthened_region`, `exists_spliced_ladderPath_nxt_of_pend_past` and `Zrel.forall_iff_eq` each carry neither string in their binder lists (checked by parsing the headers out of the source, not by eye). `objHalfK1_of_paramsOk` carries both, **and that is the point of (R-2)**: the bridge is exactly where `lab` and `φ` appear and where they stop. Nothing downstream of it mentions either. |
| the full `paramsOkK1` is NOT taken (rejected (R-1)) | **PASS.** `paramsOkK1` occurs nowhere in anything this phase landed. |
| no second induction principle beside the scaffold (Ruling 29) | **PASS.** `Nat.strong_induction_on` occurs at `LadderStepFrag.lean:666, 680, 1027, 1437` — all four pre-existing (`LnkRow.symm`, `LnkRow.mono`, `LnkRow.toLnk`'s neighbourhood, and `LnkRow.of_closed` itself). This phase added none, and `LnkRow.of_closed` is instantiated rather than re-derived. |
| `(K2)`'s margin not re-measured (Ruling 30) | **PASS.** `Mrel.threshold_le_Tc` untouched. |
| no `sorry`, `axiom`, `native_decide`, vacuous definition | **PASS.** The only `sorry` occurrences anywhere in the touched files are the word in prose docstrings about axiom profiles. |
| nothing landed under `cellAt_const_of_kappa_eq` or `ladderRealized` | **PASS.** `grep` finds no declaration of either. |
| Ruling 25 — every "is compiled" claim names a declaration `grep` finds | **PASS.** `objHalfK1_of_paramsOk`, `exists_spliced_ladderPath_nxt_of_pend_past`, `exists_lengthened_region`, `Zrel.forall_iff_eq`: one hit each. |
| `exists_rowLinked_path` | **STILL ABSENT, and not claimed.** `grep` finds only `exists_rowLinked_path_zero`. |

Guarded full `lake build`: exit 0, zero `error:`, 2976 jobs, with the `.olean` of both touched
modules newer than its source. Guarded `-- build BimodalTest`: exit 0, zero errors.

## 14. WHAT LANDED, AND WHERE THE PATH FORTH STALLED

### Landed

| Declaration | Content | Axioms |
|---|---|---|
| `objHalfK1_of_paramsOk` | the bridge: `ParamsOk → ∀ l ∈ objCycleLens step pend, l ∣ (P + 1)` | `[propext, Classical.choice, Quot.sound]` |
| `exists_spliced_ladderPath_nxt_of_pend_past` | the splice lift with the register pinned at a CHOSEN anchor rather than at the hardwired `-(l : ℤ)` | `[propext, Classical.choice, Quot.sound]` |
| `exists_lengthened_region` | **count move 1**, with the register offset in the conclusion | `[propext, Classical.choice, Quot.sound]` |
| `Zrel.forall_iff_eq` | `(∀ a b, Zrel a b x y) ↔ x = y` — the budget cannot be stripped | `[propext, Quot.sound]` |

All four are pinned in `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`, together with the
bridge check and the restriction check on count move 1 (which reads the register offset and the
countdown offset off the conclusion and requires them EQUAL, so a move that shifted the countdown
while leaving the register alone would fail to typecheck).

### The goal state the path forth reaches, recorded verbatim

The scaffold instantiates cleanly at the natural relation
`S k m s s' := Mrel P k m (h s) (h' s')`: its soundness clause is `Mrel.toZrel` outright, with
nothing to prove. The whole content is the two jump clauses, and this is the goal `LnkRow.of_closed`
leaves (produced by `trace_state` in a scratch file outside the repository; nothing with a
placeholder body entered the tree):

```
case refine_1
Q : Type
inst✝ : Fintype Q
step : Q → Q → Bool
pend : Q → Bool
P : ℕ
h h' : ℤ → LadderState Q pend
a b : ℕ
t : ℤ
hS : Mrel P a b (h t) (h' t)
k m : ℕ
s s' : ℤ
hs : Mrel P k (m + 1) (h s) (h' s')
⊢ FwdJump (fun s s' => Mrel P k m (h s) (h' s')) s s' ∧ FwdJump (fun s' s => Mrel P k m (h s) (h' s')) s' s
```

And the top-level goal in the case the step system never meets — countdowns both above the raised
threshold — with the added hypothesis in scope:

```
case inr
...
hK1 : ∀ l ∈ objCycleLens step pend, l ∣ P + 1
hres : ↑(↑(h t)).2.1 ≡ ↑(↑y).2.1 [ZMOD ↑P + 1]
hq : (↑(h t)).1 = (↑y).1
hb1 : (P + 1) * (a + b) ≤ (↑(h t)).2.1
hb2 : (P + 1) * (a + b) ≤ (↑y).2.1
⊢ ∃ h', IsLadderPath step pend h' ∧ h' t = y ∧ LnkRow a b h h' t t
```

### The clause it stalls on, and the coordinate

**It stalls on `hfw`/`hbw` — the jump clauses — and the coordinate is the REGISTER.** The stall is
in the CONSTRUCTION layer, not in the added hypothesis, and this round can say exactly where.

1. The correspondence the splice supplies is `spliceEmb a l`, and it transports the OBJECT
   coordinate perfectly: `objAt h' (spliceEmb a l v) = objAt h v` at every `v`, below the splice
   point by `spliceObj_eq_of_le` and above it by `spliceObj_of_ge`.
2. It transports the COUNTDOWN in a stated, two-regime way: `cntAt h' v = cntAt h v + l` for
   `v ≤ a` (every such `v` is in the region, the past being pending-forever) and
   `cntAt h' (v + l) = cntAt h v` for `v ≥ a`.
3. It does **not** transport the REGISTER at all. `exists_ladderPath_of_walk` — the lift every
   splice in the library factors through — concludes `objAt` and `cntAt` and nothing else; the
   register it produces is whatever `drift_extension_of_pins` chooses through the region-start
   pins. `exists_ladderPath_of_walk_nxt_at` pins it at ONE anchor, which is what count move 1
   above exploits, and that is the whole of what is available.
4. `Zrel` reads the register in TWO of its four clauses — the register clause and the gap clause
   `n - c` — at EVERY matched pair. `Zrel.forall_iff_eq` (landed) says the budget cannot be
   stripped to avoid this, so the thresholds are the content rather than bookkeeping.

**Why pinning the register everywhere is not merely unlanded but obstructed.** The gap clause
wants equality on both sides of the splice seam, and that is two incompatible demands one step
apart. At a matched pair below the seam the countdown is raised by `l`, so the gap is preserved
only if the register is raised by `l` too — which is exactly count move 1's conclusion, and
exactly the offset `attackA_mirror_register_joins` exhibited. At a matched pair above the seam the
countdown reverts to EQUALITY, so the gap is preserved only if the register reverts too. The two
demands sit at adjacent positions `a + l - 1` and `a + l`, and `Drift` permits a change of at most
one per step. For `l ≥ 2` no register walk meets both. The register must therefore spend the drop
over `l` steps, during which the gap is wrong by between `1` and `l` and has to be carried by
`Zrel`'s threshold disjuncts instead — and whether those disjuncts cover it is not decided here
and is NOT claimed either way.

**A second, independent coordinate, stated because it is a hypothesis of count move 1 and not of
the consumer.** `exists_lengthened_region` carries `Fintype.card Q ≤ cntAt g t`, the room the
pigeonhole `exists_objCycle_of_card_le_cnt` needs to find a cycle on the region's own walk. `Mrel`
supplies `(P + 1) * (a + b)` and the added hypothesis supplies `l ∣ P + 1` for the object's cycle
lengths; neither forces `P + 1 ≥ Fintype.card Q`. **This is reported as a finding and is NOT
repaired by adding a second hypothesis**, which is outside this phase's authorization (decision 21
admits the object half of `(K1)` and nothing else). It is named here so the next revision can
route it rather than rediscover it.

`exists_lengthened_region` also carries the pending-forever past, which is the regime
`exists_spliced_ladderPath_of_pend_past` discharges without a pin cascade. Count moves 2 and 3 —
cascade through the cap, and insert a region in a tight chain — are what lift that restriction,
and **they were not reached**, per the phase's own stop rule.

## 15. The fragment covered by an agreement of cells after this phase

**Unchanged by this phase.** The `untl` clause of `truth_iff_of_lnkRow` is a corollary of the path
forth, the path forth did not close, and the corollary was therefore not derived. What is covered
by an agreement of cells after this round is exactly what was covered before it: the budget-`(0, 0)`
case, via `exists_rowLinked_path_zero` and `truth_iff_of_lnkRow` at `dBack ψ = dFwd ψ = 0`. The
`snce` mirror and the lift to the `⊡`-carrying level remain owed to **Phase 11.40** and are
untouched here.

## 16. Phase-marker hygiene, and the deviation from plan v28

Phases 11.39, 11.42, 11.44, 11.45 and 11.47 stay exactly at their own markers. **This phase
re-marked none of them and wrote into none of them** (Rulings 17, 21, 24, 26, 28). The only
plan-file edit is to the Phase 11.49 heading itself. The deliverable was re-pointed here rather
than re-filed.

**Deviation, recorded rather than annotated silently.** Plan v28's Scope Hypothesis for this phase
names ONE bridge, ONE scaffold instantiation, THREE count moves, ONE path-forth lemma and ONE
corollary clause. The bridge landed; the scaffold instantiation was reached and its goal recorded
but not discharged; ONE of the three count moves landed; the path-forth lemma and the corollary
did NOT land. One object landed that the Scope Hypothesis does not name —
`exists_spliced_ladderPath_nxt_of_pend_past`, the register-exposing splice lift — because the
landed splice layer pins the register at a hardwired position and count move 1's own statement
requires it pinned at the anchor; without it the "register offset stated IN THE STATEMENT"
requirement of item 3 could not be met at all. A second unnamed object landed,
`Zrel.forall_iff_eq`, because the budget-free simplification it refutes is the shape the next
round would otherwise reach for. The estimate was wrong in the direction the phase's own text
anticipated, and it is recorded as a route finding rather than absorbed.

**The gate collision**, recorded: `typst-sync-check.sh` Check 2 blocked the first sub-step commit
on `formalsystem-line-count` drift caused by this phase's own appends (committed 411272 vs live
411316). This is the cross-set collision with the `status.typ` owner that the task description's
FILE SCOPE anticipates. Remedy applied in-phase: `typst-sync-check.sh --fix`, with
`typst/generated/status.typ` staged alongside each sub-step.

**Module headroom**, re-measured live rather than carried: `LadderStepFrag.lean` stood at 1485
before this phase (matching plan v28's figure) and stands at 1697 after. It crossed the
package-wide `longFile 1500`, so an in-source `set_option linter.style.longFile 1700` baseline was
added **in place**, with a comment saying why the module is not split. The module was NOT split.
`KTypeSummaryAxiomTest.lean` stood at 3729 (matching) and stands at 3794, inside its in-source
`longFile 3800`; its baseline was not raised.
