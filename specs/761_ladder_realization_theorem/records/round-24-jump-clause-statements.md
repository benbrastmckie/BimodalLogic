# Round 24 — the two jump clauses' statement layer

Phase 11.38 of `plans/24_step-system-jump-clause-derivation.md`. This file is the durable record
of the statement layer; the module carrying it is
`FormalSystem/Metalogic/Decidability/RaySummary/LadderStepFrag.lean`.

**This round does not shrink the count move.** Lengthen a region, cascade through the cap, insert
a region in a tight chain: none of the three is attempted, and the promoted step system is the
base case of the derivation, not the theorem.

## 1. Where the window is consumed (read from the live tree, dispatch 66)

`truth_iff_of_lnk`, `untl` case, `lean_goal` at the line `obtain ⟨rfl, hfα⟩ := hf` — the state
BEFORE the guard is destructed to `⊥`:

```
hf : StepFrag (γ.untl α)
hda : dBack (γ.untl α) ≤ a
hdb : dFwd (γ.untl α) ≤ b
hτ : ∀ (u : ℤ), τ.state u = (u + k, g u)
hτ' : ∀ (u : ℤ), τ'.state u = (u + k', g' u)
hl : Lnk a b g g' t
⊢ PlusTruthAt (ladderModel step pend fwd bwd lab) τ t (γ.untl α) ↔
    PlusTruthAt (ladderModel step pend fwd bwd lab) τ' t (γ.untl α)
```

By `PlusTruthAt`'s clause (`FormalSystem/PlusLanguage/PlusTruth.lean:89`) each side is
`∃ s, t < s ∧ PlusTruthAt M τ s α ∧ ∀ r, t < r → r < s → PlusTruthAt M τ r γ`. This agrees with
the goal state the plan carries from the research round; the plan's version is the same goal with
`PlusTruthAt` unfolded once. The live proof closes the case only because `hf` forces `γ = ⊥`
(`truth_nxt` then pins the witness to `t + 1`, and `Lnk.succ` moves the link there). With
`γ ≠ ⊥` a witness `s > t + b` is outside every position `Lnk a b g g' t` mentions. In
`exists_linked_path` the window is consumed at the two inductions `hfw` (`j ≤ b`) and `hbw`
(`j ≤ a`): each spends one unit of budget per position through `Zrel.succ` / `Zrel.pred`, and
stops when the budget is spent. The gap is in the link relation, not in the induction.

## 2. What compiled

| Declaration | Content | Axioms |
|---|---|---|
| `FwdJump R t t'`, `BwdJump R t t'` | the jump condition of the `untl` / `snce` clause, over a relation `R` on positions | not measured |
| `FwdJump.mono`, `BwdJump.mono` | monotone in `R` | not measured |
| `LnkRow a b g g' t t'` | the row link (definition below) | `[propext, Quot.sound]` |
| `LnkRow.zero` | `LnkRow a b g g' t t' → Zrel a b (g t) (g' t')` | `[propext, Quot.sound]` |
| `LnkRow.symm` | symmetry (swapping paths and positions) | `[propext, Classical.choice, Quot.sound]` |
| `LnkRow.mono` | monotone in both budgets | same |
| `LnkRow.succ`, `LnkRow.pred` | a jump to the adjacent position is answered at the adjacent position | same |
| `LnkRow.toLnk` | `LnkRow a b g g' t t → Lnk a b g g' t` — the window restriction, for every `(a, b)` | same |
| `exists_rowLinked_path_zero` | the `⊡` clause against `LnkRow` at the budget `(0, 0)` | same |

The definition, verbatim:

```lean
def FwdJump (R : ℤ → ℤ → Prop) (t t' : ℤ) : Prop :=
  ∀ s : ℤ, t < s → ∃ s' : ℤ, t' < s' ∧ R s s' ∧
    ∀ r' : ℤ, t' < r' → r' < s' → ∃ r : ℤ, t < r ∧ r < s ∧ R r r'

def LnkRow (a b : ℕ) (g g' : ℤ → LadderState Q pend) (t t' : ℤ) : Prop :=
  Zrel a b (g t) (g' t') ∧
  (∀ b₀ : ℕ, b = b₀ + 1 →
    FwdJump (fun s s' => LnkRow a b₀ g g' s s') t t' ∧
    FwdJump (fun s' s => LnkRow a b₀ g g' s s') t' t) ∧
  (∀ a₀ : ℕ, a = a₀ + 1 →
    BwdJump (fun s s' => LnkRow a₀ b g g' s s') t t' ∧
    BwdJump (fun s' s => LnkRow a₀ b g g' s s') t' t)
```

**How the relation was derived.** It is the goal of section 1 read as a condition on the two
rows: a witness `s` on one row needs a witness `s'` on the other at which `α` transfers, and `γ`
at every `r'` strictly before `s'` needs some `r` strictly before `s` from which it transfers; the
sub-formulas have `dFwd ≤ b - 1`, so the answering pairs are linked at `(a, b - 1)`. Nothing was
added and nothing was tuned against a proof. Three properties follow from the derivation rather
than from a choice:

- **It is two-positioned.** The answer to a far witness need not sit at the same distance, so the
  relation links position `t` of `g` to position `t'` of `g'`. The plan's `LnkRow → Lnk a b` is
  the diagonal case `t' = t`.
- **The window is a theorem.** No `Lnk` conjunct is assumed: a forward jump to `t + 1` has no
  position strictly before its answer to answer back, so the answer is `t' + 1` (`LnkRow.succ`),
  and iterating gives `LnkRow.toLnk`.
- **It is one relation, not a family.** The scope hypothesis's STOP condition is not met.

## 3. The `⊡` clause against `LnkRow` — a FINDING, not a compiled clause

The plan's task is to restate the `⊡` clause (`exists_linked_path`'s conclusion strengthened from
the window to the row) and compile it. **It compiles at the budget `(0, 0)` only**
(`exists_rowLinked_path_zero`), where the row link is the state relation. At a positive budget the
restated clause

```
Zrel a b (h t) y → ∃ h', IsLadderPath step pend h' ∧ h' t = y ∧ LnkRow a b h h' t t
```

was NOT attempted, for two reasons, and the relation was not weakened to make it go through.

1. **Its conclusion contains a jump condition.** Producing `FwdJump` between `h` and `h'` over
   the whole row is the path forth with a whole-row correspondence — the engine Phase 11.39
   attempts. The `⊡` clause and the jump clauses are not separable at the row level: this phase's
   prohibition on attempting a jump clause covers it.
2. **As restated, with the hypothesis `Zrel a b`, it is expected to be FALSE.** See section 5,
   fact (i). The hypothesis of the path forth must be a stronger state relation than the budget of
   the row link it delivers; in the step system the two coincide, and that coincidence does not
   survive a jump.

## 4. The two jump clauses' signatures (OWED; text only, declared nowhere)

**The truth lemma over the row link, `⊡`-free level** — its `untl` case is the first jump clause,
its `snce` case the second:

```
truth_iff_of_lnkRow :
  ∀ ψ, (no `stab` and no `box` in ψ) → ∀ a b, dBack ψ ≤ a → dFwd ψ ≤ b →
    ∀ τ τ' k k' g g' t t', IsLadderPath step pend g → IsLadderPath step pend g' →
      (∀ u, τ.state u = (u + k, g u)) → (∀ u, τ'.state u = (u + k', g' u)) →
      LnkRow a b g g' t t' →
      (PlusTruthAt M τ t ψ ↔ PlusTruthAt M τ' t' ψ)
```

**The path forth with a whole-row correspondence** — the engine of both, and the `⊡` clause of
the lift:

```
exists_rowLinked_path :
  IsLadderPath step pend h → S a b (h t) y →
    ∃ h', IsLadderPath step pend h' ∧ h' t = y ∧ LnkRow a b h h' t t
```

with the state relation `S a b` NOT fixed by this phase. Candidate, at the repaired clip:
`S a b := Zrel (a + b + 1) (a + b)` (both gap arms at `2 (a + b) + 2`).

| Clause | Must deliver | Expected to consume | Count-move move |
|---|---|---|---|
| `untl` (forward jump) | for every position after `t` on `h`, an answering position on `h'` with the passed positions answered back, at `(a, b - 1)` | `(K1)`'s modulus, where the answering region's length differs from the original's by more than the budget reads | lengthen a region |
| `snce` (backward jump) | the mirror, at `(a - 1, b)`, over the PAST row | `(K2)`'s margin: the cap `cnt_cap_of_row` binds two regions deep, and a doubling chain has about `card` regions | cascade through the cap; insert a region in a tight chain |

The "expected to consume" column is an EXPECTATION carried from the research round and the plan.
Nothing in it is compiled, and Phase 11.39 is told in advance that `(K2)`'s margin is thin.

## 5. The three facts that bound what the trunk can claim

- **The whole-language upper bound is a CONJECTURE.** That the gap clip `2 (dBack + dFwd) + 2`
  suffices for the agreement on the whole language is conjectured. The compiled envelope below is
  a LOWER bound; certifying that three refuting witnesses are gone at a clip does not certify the
  agreement there.
- **The step-fragment bound is PROVED and TIGHT.** `max (2 dBack) (2 dFwd + 2)` is proved on
  `StepFrag` (`cellAt_eq_of_Zrel`, with the bridge `Zrel_of_kappa_eq` in the wired probe
  `specs/evidence/seam-gluing-ray-product/ladder-step-fragment-gap-depth.lean`), and tight on the
  forward arm (`stepFrag_gap_depth_exact`).
- **`thetaC` and `mixC` each use ONE JUMP** and are therefore outside everything compiled so far,
  this phase included: no declaration of the module evaluates a formula over `LnkRow`.

**The lower-bound envelope** `F(a, b) ≥ max (2 a + b − 1) (2 b + 2)`, each row re-derived in this
dispatch against the probe's own theorem statements (not re-compiled here):

| Family | `dBack` | `dFwd` | Needs `B ≥` | Probe theorems read |
|---|---|---|---|---|
| `sigC b` | 1 | `b` | `2 b + 2` | `sigC_mem` (holds at gap `−(2 b + 1)`), `sigC_not_mem` (fails at every gap `≤ −(2 b + 2)`) — `ladder-step-fragment-gap-depth.lean` |
| `thetaC` | 1 | 1 | `4` | `thetaC_not_mem` (fails at gap `−3`), `thetaC_mem` (holds at every gap `≤ −4`), `dBack_thetaC`, `dFwd_thetaC` — `ladder-cell-agreement-refutation.lean` |
| `mixC a k`, `k ≥ 1` | `a` | `k + 2` | `2 a + k + 1` | `mixC_mem` (holds at gap `2 a + k`), `mixC_not_mem` (fails at every gap `≥ 2 a + k + 1`), `dBack_mixC`, `dFwd_mixC` — same file |

Arithmetic: `2 (a + b) + 2 ≥ 2 a + b − 1` and `2 (a + b) + 2 ≥ 2 b + 2` for all `a, b`, so the
repaired clip dominates the envelope. The carried figures are confirmed unchanged.

**Fact (i), used in section 3 — ARGUED, not compiled.** At `mixC a k` the two pending states with
one countdown `c ≥ k + 4` and registers `c + 2 a + k`, `c + 2 a + k + 1` satisfy
`Zrel a (k + 2)`: same object state, equal countdowns, registers both `≥ 2 (a + k + 2)`, gaps
`2 a + k` and `2 a + k + 1` both `≥ 2 a`. By `mixC_mem` and `mixC_not_mem` their cells differ. So
`cellAt_eq_of_Zrel` does not extend to the whole language at `Zrel`'s own thresholds, and a path
forth from `Zrel a b` to `LnkRow a b` would contradict the owed truth lemma taken with its `⊡`
lift. The upper gap arm must read at least `2 a + b − 1`, not `2 a`. No library or probe
declaration states this; a later round that relies on it should compile it first.
