# Round 24 — the `untl` jump clause: verdict

Phase 11.39 of `plans/24_step-system-jump-clause-derivation.md`, dispatch 67. Module:
`FormalSystem/Metalogic/Decidability/RaySummary/LadderStepFrag.lean`. Probe:
`specs/evidence/seam-gluing-ray-product/ladder-row-link-residue-obstruction.lean`.

## Verdict: outcome (b) — MEASURED ACCOUNT. The phase is `[BLOCKED]`.

The phase's Goal has two halves. They came apart.

| Half | Status |
|---|---|
| The truth lemma over `LnkRow` at the `⊡`-free level (`untl` AND `snce` cases, every guard) | COMPILED: `truth_iff_of_lnkRow` |
| The path forth with a whole-row correspondence, which is what makes the truth lemma say anything about cells | NOT PROVED, and REFUTED for every `Zrel`-shaped hypothesis: `no_rowLinked_path_of_Zrel` |

**Fragment of the language covered by an AGREEMENT OF CELLS after this round: the step fragment,
unchanged.** `truth_iff_of_lnkRow` covers `untl`/`snce` at every guard between two paths that are
ALREADY row-linked; no declaration produces a row-linked pair at a positive budget except
reflexivity (`LnkRow.refl`). So no cell agreement for any formula with a jump is landed, and none
is claimed. Outcome (a) is NOT met: the path-forth lemma that delivers the clause does not exist.

**The whole-language clip `2 (dBack + dFwd) + 2` remains CONJECTURED** (Ruling 10). Nothing in
this round bears on it in either direction: the obstruction found is on the COUNTDOWN coordinate,
not the gap.

## 1. Entry: the live goal re-derived

`truth_iff_of_lnk`, `untl` case, re-read in this dispatch: unchanged from the statement record
(`records/round-24-jump-clause-statements.md` section 1) — the case closes only because
`StepFrag` forces the guard to `⊥`. `LnkRow`, `LnkRow.zero/.symm/.mono/.succ/.pred/.toLnk` and
`exists_rowLinked_path_zero` re-read as landed; nothing in them was changed.

## 2. What compiled

| Declaration | Content | Axioms |
|---|---|---|
| `LnkRow.refl` | `LnkRow a b g g t t` | `[propext, Quot.sound]` |
| `RowFrag` | the predicate "no `⊡`, no `□`" | not measured |
| `truth_iff_of_lnkRow` | the truth lemma over the row link, signature below | `[propext, Classical.choice, Quot.sound]` |
| `LnkRow.first_zero` | under `LnkRow a (b + 1)` with `1 ≤ a + b`, the first position after `t` where the first row's countdown is `0` is answered by the first such position after `t'` on the second, with the same object state | `[propext, Quot.sound]` |
| `LnkRow.region_end_obj` | for ladder paths, same hypotheses, first row pending with positive countdown: `objAt g' (t' + cntAt g' t') = objAt g (t + cntAt g t)` | `[propext, Quot.sound]` |
| `ProbeRowResidue.no_rowLinked_path_of_Zrel` (probe) | the refutation of section 4 | `[propext, Classical.choice, Quot.sound]` |

Guarded `lake build` (2976 jobs) and `build BimodalTest` (3044 jobs): exit 0, zero errors. The
four library declarations are pinned in `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`.

### Statement fidelity: the landed truth lemma against the recorded one

Recorded (Phase 11.38, text):

```
truth_iff_of_lnkRow :
  ∀ ψ, (no `stab` and no `box` in ψ) → ∀ a b, dBack ψ ≤ a → dFwd ψ ≤ b →
    ∀ τ τ' k k' g g' t t', IsLadderPath step pend g → IsLadderPath step pend g' →
      (∀ u, τ.state u = (u + k, g u)) → (∀ u, τ'.state u = (u + k', g' u)) →
      LnkRow a b g g' t t' →
      (PlusTruthAt M τ t ψ ↔ PlusTruthAt M τ' t' ψ)
```

Landed:

```lean
theorem truth_iff_of_lnkRow
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x) (lab : Q → Atom → Bool) :
    ∀ ψ : PlusFormula, RowFrag ψ → ∀ a b : ℕ, dBack ψ ≤ a → dFwd ψ ≤ b →
      ∀ (τ τ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame) (k k' : ℤ)
        (g g' : ℤ → LadderState Q pend) (t t' : ℤ),
        IsLadderPath step pend g → IsLadderPath step pend g' →
        (∀ u : ℤ, τ.state u = (u + k, g u)) → (∀ u : ℤ, τ'.state u = (u + k', g' u)) →
        LnkRow a b g g' t t' →
        (PlusTruthAt (ladderModel step pend fwd bwd lab) τ t ψ ↔
          PlusTruthAt (ladderModel step pend fwd bwd lab) τ' t' ψ)
```

Differences: `fwd`, `bwd`, `lab` are the model's own parameters, which the recorded text left
inside `M`; "no `stab` and no `box`" is the predicate `RowFrag`. No hypothesis was added and none
dropped; the two `IsLadderPath` hypotheses are kept although the proof does not use them. **One
fidelity observation, not a difference**: the lemma is a whole truth lemma — its `snce` case is
proved too, since it is the literal mirror and costs nothing once the relation is the clause's
condition. That does NOT discharge Phase 11.40's `snce` obligation, whose content is the BACKWARD
path forth.

## 3. The path forth: the goal state reached, verbatim

The lemma attempted, at the candidate hypothesis the statement record names
(`S a b := Zrel (a + b + 1) (a + b)`), at a row budget `(a, b + 2)`, in the case the step system
never meets — countdowns DIFFERENT and both above the threshold:

```
Q : Type
step : Q → Q → Bool
pend : Q → Bool
fwd : ∀ (t : ℤ) (x : LadderState Q pend), ∃ y, RladAdm step pend t x y
bwd : ∀ (t : ℤ) (x : LadderState Q pend), ∃ y, RladAdm step pend (t - 1) y x
a b : ℕ
h : ℤ → LadderState Q pend
hh : IsLadderPath step pend h
t : ℤ
y : LadderState Q pend
hc : 1 ≤ cntAt h t
hne : cntAt h t ≠ (↑y).2.1
hq : (↑(h t)).1 = (↑y).1
hn :
  (↑(h t)).2.2 = (↑y).2.2 ∨
    2 * (a + (b + 2) + 1 + (a + (b + 2))) ≤ (↑(h t)).2.2 ∧ 2 * (a + (b + 2) + 1 + (a + (b + 2))) ≤ (↑y).2.2
hgap :
  ↑(↑(h t)).2.2 - ↑(↑(h t)).2.1 = ↑(↑y).2.2 - ↑(↑y).2.1 ∨
    2 * ↑(a + (b + 2) + 1) ≤ ↑(↑(h t)).2.2 - ↑(↑(h t)).2.1 ∧ 2 * ↑(a + (b + 2) + 1) ≤ ↑(↑y).2.2 - ↑(↑y).2.1 ∨
      ↑(↑(h t)).2.2 - ↑(↑(h t)).2.1 ≤ -(2 * ↑(a + (b + 2)) + 2) ∧ ↑(↑y).2.2 - ↑(↑y).2.1 ≤ -(2 * ↑(a + (b + 2)) + 2)
hbig : 2 * (a + (b + 2) + 1 + (a + (b + 2))) ≤ cntAt h t ∧ 2 * (a + (b + 2) + 1 + (a + (b + 2))) ≤ (↑y).2.1
⊢ ∃ h', IsLadderPath step pend h' ∧ h' t = y ∧ LnkRow a (b + 2) h h' t t
```

(Produced by `trace_state` in a scratch file outside the repository, after destructing the
hypothesis and discarding the equal-countdown disjunct; the scratch file is not kept and nothing
with a placeholder body entered the tree.)

**The step that fails is the first one: the choice of `h'`.** The step system chose `h'` one
position at a time (`Zrel.succ`, then `glue`), and any answer that kept `Zrel` would do. Here `h'`
must stay pending for `y`'s countdown, which differs from `h`'s, so its current region has a
DIFFERENT LENGTH from `h`'s — and `LnkRow.region_end_obj` (compiled) says that whatever `h'` is
chosen, its region must end at the object state where `h`'s region ends. The hypotheses say
nothing about where the object's walks of the two lengths end.

**The count-move move being attempted: LENGTHEN A REGION** (the first of the three). Cascade
through the cap and insert a region in a tight chain were not reached.

## 4. The goal above is not merely unproved: it has no solution on a three-state object

`no_rowLinked_path_of_Zrel` (wired probe, compiled):

```lean
theorem no_rowLinked_path_of_Zrel (A B a b : ℕ) (hab : 1 ≤ a + b) :
    ∃ x y : LadderState C3 pendC, Zrel A B x y ∧
      ∃ h : ℤ → LadderState C3 pendC, IsLadderPath stepC pendC h ∧ h 0 = x ∧
        ¬ ∃ h' : ℤ → LadderState C3 pendC, IsLadderPath stepC pendC h' ∧ h' 0 = y ∧
          LnkRow a (b + 1) h h' 0 0
```

`C3` is a pending `2`-cycle `p0 ⇄ p1` with an idle sink; `x = (p0, 2 m, 2 m)`,
`y = (p0, 2 m + 1, 2 m + 1)` with `m = A + B + 1`. The object walk inside a pending region is
forced to alternate (`objAt_flip`), so the two regions end at `p0` and `p1`. This holds for EVERY
`(A, B)`: raising `Zrel`'s thresholds does not help, and the candidate
`Zrel (a + b + 1) (a + b)` of the statement record is one instance.

Scope of the refutation, stated so it is not over-read:

- It refutes a HYPOTHESIS SHAPE of an owed lemma. It does not refute `LnkRow`, the truth lemma,
  or any agreement of cells; it bears on neither `cellAt_const_of_kappa_eq_schema_refuted` nor
  `no_fibre_equation_over_kappa`.
- It needs a row budget `(a, b + 1)` with `1 ≤ a + b`. At the row budget `(0, 1)` it says nothing.
- It does not say which relation works. That `Zrel` plus a residue conjunct suffices is proved
  nowhere.
- It was reached while attempting the proof, as the reason the first step has no witness; the
  round did not switch from the clause to a refutation of the clause. The clause's truth-lemma
  half is proved.

## 5. Which obstruction: `(K1)`'s modulus, through the row correspondence's shape

The plan asks for one of: `(K2)`'s margin, `(K1)`'s modulus, the row correspondence's shape.

- **`(K1)`'s modulus.** The state relation of the path forth must make the countdown's residue
  modulo an object-determined quantity part of the relation. `Zrel` has no such coordinate, and
  cannot have one "for every object" at fixed thresholds — which was the step system's defining
  property (its thresholds are solutions of one-step closure conditions and mention no object).
- **Not `(K2)`'s margin.** The margin was not reached: the attempt stops before any cascade or
  insertion. The plan's advance warning that the margin is thin is neither confirmed nor refuted.
- **The row correspondence's shape is NOT at fault.** `LnkRow` was not weakened, and the truth
  lemma over it closed with no change to it.

**The scope estimate was wrong, and this is the STOP condition the phase names.** The Scope
Hypothesis reads: "If the clause turns out to need ... a change to `Zrel` itself, STOP and record
that the scope estimate was wrong: that is a route question." The path forth needs a state
relation that is not `Zrel` at any budgets. **A `/revise` is owed on this verdict.**

## 6. What would have to be true for the path forth to close

A state relation `S a b` such that, at minimum:

1. `S a b x y` with different countdowns implies the object's pending walks from the common
   object state of lengths `x`'s and `y`'s countdown can be chosen to end at one object state —
   and, iterating `LnkRow.first_zero` down the budget, to agree on a final segment and on what
   they pass. A residue conjunct `c ≡ c' (mod P)` with `P` a common multiple of the object's
   pending cycle lengths is the candidate; `(K1)` already carries such a modulus on the
   counter-quotient side. NOT proved sufficient.
2. `S` is preserved by the construction of the lengthened (or shortened) region — the library's
   splice/pump layer (`LadderPump`, `LadderChain`) is the existing machinery for inserting
   object cycles into a pending region.
3. The register side: after the region the two paths are offset by the difference of the
   countdowns, and the next region's countdown is read off the register. Whether the offset can
   be absorbed without the cascade the plan names (through the cap; a tight chain) was NOT
   reached and is NOT known.

Items 1 and 2 are the "lengthen a region" move; item 3 is where the other two moves would enter.
