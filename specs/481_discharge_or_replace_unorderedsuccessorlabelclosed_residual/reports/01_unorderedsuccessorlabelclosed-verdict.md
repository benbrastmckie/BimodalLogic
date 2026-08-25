# `UnorderedSuccessorLabelClosed`: verdict and repair route

**Task**: 481 — discharge or replace the `UnorderedSuccessorLabelClosed` residual
**Phase**: research
**Session**: sess_1787672861_1a4999_481
**Baseline**: `lake build` green at HEAD (2493 jobs, warnings only) before any probe

---

## 0. Verdict in one paragraph

Outcome **(a) is refuted outright and in the strongest available form**: the predicate is false
at *every* nonempty finite label set, at *every* frame class, so there is no
frame-class or setting distinction that rescues it. Its satisfiability set is exactly `{∅}`.
Outcome **(c) is already half-executed in-tree** — C9 register entries 11 and 21 both cover this
residual, so this task does **not** add a 25th entry from scratch; what is missing is the
*sharpening* from the file's current "refutable at **some** `L`" to the true "refutable at **every
nonempty** `L`", plus the explicit carrier list. Outcome **(b) is available and cheaper than
expected**, because the rectangle hypothesis the repair needs (`TimeMergeClosed L`) is **already a
sibling hypothesis at every consuming site**.

**Recommendation**: do (c)-sharpening and (b), in that order, as two phases. Phase 1 is the
load-bearing one for the task-462 sequencing warning and is fully proved below.

---

## 1. Corrections to the task description (evidence-grounded)

| Claim in task description | Actual state |
|---|---|
| predicate at `MintBound.lean:6199` | correct — `def UnorderedSuccessorLabelClosed` is at **:6209**; its docstring opens at :6162 |
| refutation at `:6238` | correct — `unorderedSuccessorLabelClosed_not_universal` is at **:6246** |
| "carried as a live hypothesis by `buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse` (`:6215`)" | that theorem is at **:6498**. It is **one of nine** carriers, not the only one — full list in §4 |
| "the file already has 24 such entries; this would be the 25th" | correct that there are 24 entries, but **entries 11 and 21 already cover this residual in detail**. A 25th entry would duplicate them. The right move is to amend 21 |
| "which frame classes … check precisely which" | **frame class is not a discriminating dimension.** Every statement in the refutation chain (`unorderedSuccessorLabelClosed_not_universal`, `freshWorldHeadroom_not_universal`, `freshLabelHeadroom_not_universal`, and the new §2 result) is universally quantified in `fc`. The discriminating dimension is `L` (and, for the repair, the formula stock `C`) |
| "FIFTH termination residual" | confirmed at the `signedUniverse` level: the carriers take exactly four named residuals — `hlab`, `hSL : StepLengthBounded`, `hmint : MintPaysForTime{,Stable,Fixed}`, `hpb : PostBlockingSettles` — plus `hL : TimeMergeClosed` and the stock conditions `hC`/`hT`. `MintBound.lean:10084` and `:12759-12760` already enumerate `UnorderedSuccessorLabelClosed` among them, so the *file* is internally correct; the four-residual framing to be corrected lives in `specs/` artifacts, not in `MintBound.lean` |

---

## 2. The decisive new result (PROVED — compiles, no `sorry`, no new axiom)

The file currently records only that the residual is refutable at the single label set
`freshWorldLabels = {⟨0,0⟩}` (`unorderedSuccessorLabelClosed_not_universal`, :6246), and describes
it as "**not vacuous, and not free either** … it holds at every `L` for which the engine never
fires". That description is **too generous**. The refutation generalizes to every nonempty `L`.

### 2.1 What was proved

Three statements, all compiled against the real `MintBound` module via
`lake env lean` on a scratch file (probe sources reproduced in §6):

1. `unorderedSuccessorLabelClosedOrd_nonempty_false (fc) (L) (hne : L.Nonempty) :
   ¬ UnorderedSuccessorLabelClosedOrd fc L`
2. `unorderedSuccessorLabelClosed_nonempty_false (fc) (L) (hne : L.Nonempty) :
   ¬ UnorderedSuccessorLabelClosed fc L`  — follows from 1 via the landed
   `unorderedSuccessorLabelClosedOrd_of_unorderedSuccessorLabelClosed`
3. `unorderedSuccessorLabelClosed_empty (fc) : UnorderedSuccessorLabelClosed fc (∅ : Finset Label)`

Together: **the residual's satisfiability set is exactly `{∅}`**, at every frame class.

### 2.2 Why it works, in one line

The in-tree witness `freshWorldBranch = [F(□p)@⟨0,0⟩]` is not special. For an arbitrary nonempty
`L`, take `l₀ ∈ L` maximizing `.world` (the same `Finset.max'` device
`freshWorldHeadroom_not_universal` already uses at :5964) and run the witness at `l₀` instead of at
`Label.initial`. `.boxNeg` emits at `Branch.nextWorld = l₀.world + 1`, which is outside `L`'s world
projection by maximality.

**The whole generalization is mechanical.** Every one of the fourteen `rfl`-proved private facts
supporting `findApplicableRule_freshWorldWitness` (:5834–5866: `ia_ug` … `tw_bn`) still holds by
`rfl` with the label a free variable — verified. Both engine lemmas
(`findApplicableRule_freshWorldWitness` :5877, `expandOnceUnblocked_freshWorldBranch` :5887)
generalize with their **proof scripts unchanged, character for character**. This is why the
implementation cost of Phase 1 is low.

### 2.3 Why this matters — the exact premature-closure risk this task exists to prevent

`MintBound.lean:12761`, `buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse_untlSnceFree`,
is presented as "**the residual, discharged at a nonempty concrete universe**" — the `hmint`
argument is gone because `mintPaysForTime_signedUniverse_untlSnceFree` discharges it, and
`signedUniverse_nonempty` + `modalWitnessStock_nonempty` are cited to show the universe is not the
empty one.

But that theorem still carries `hlab : UnorderedSuccessorLabelClosed fc L` (:12765). By §2.1 that
hypothesis is **false at every nonempty `L`**. So the "discharge at a nonempty concrete universe"
is, at every `L` where the universe is in fact nonempty, a **vacuously true conditional**. The same
applies to all nine carriers in §4.

This is exactly the failure mode `MintBound.lean:5711-5713` names for `DifficultyBounded` — "a
residual nobody can satisfy makes its theorem a true conditional with no reach" — recurring one
coordinate over, undetected because the file only ever refuted the residual at one witness `L`.

---

## 3. Sequencing with task 462 (`MintPaysForTimeFixed` at a nonempty universe)

The task description's sequencing warning is **confirmed and sharper than stated**.

- 462 targets `MintPaysForTimeFixed` at a nonempty universe. That is a *different* hypothesis
  (`hmint`) at the *same* setting.
- Discharging `hmint` there is genuine progress for the `U`-level termini
  (`buildTableauAt_isSome_of_lengthBudget_fixed` and siblings, which take `UniverseClosedAt fc U`
  directly and carry **no** `hlab`).
- Discharging `hmint` **does not** unlock the `signedUniverse` family. Those nine theorems remain
  vacuous at every nonempty `L` until `hlab` is replaced. Any 462 artifact claiming "the
  `signedUniverse` terminus now carries one residual fewer, at a nonempty universe" is claiming
  something vacuous.
- **Therefore**: Phase 1 of this task (§5) must land before or alongside 462, and 462's report must
  cite `unorderedSuccessorLabelClosed_nonempty_false` when it describes what its discharge buys.

---

## 4. Exact carrier list — which theorems still carry it, at which settings

All nine are universally quantified in `fc` (no frame-class restriction anywhere), all at
`U = signedUniverse C L`, and all carry `hL : TimeMergeClosed L` as a sibling hypothesis.

| # | Line | Declaration | Also carries |
|---|------|-------------|--------------|
| 1 | 6224 | `unorderedSuccessor_confined_signedUniverse_of_headroom` | `hC`, `hT` |
| 2 | 6432 | `universeClosedAt_signedUniverse_of_headroom` | `hC`, `hT`, `hL` |
| 3 | 6472 | `buildTableauAt_isSome_of_lengthBudget_signedUniverse` | `hSL`, `hmint : MintPaysForTime`, `hpb` |
| 4 | 6498 | `buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse` | `hSL`, `hmint : MintPaysForTime`, `hpb` |
| 5 | 10061 | `buildTableauAt_isSome_of_lengthBudget_signedUniverse_selfGuarded` | `hSL`, `hmint : MintPaysForTimeStable`, `hpb` |
| 6 | 10092 | `buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse_selfGuarded` | `hSL`, `hmint : MintPaysForTimeStable`, `hpb` |
| 7 | 11040 | `buildTableauAt_isSome_of_lengthBudget_signedUniverse_fixed` | `hSL`, `hmint : MintPaysForTimeFixed`, `hpb` |
| 8 | 11059 | `buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse_fixed` | `hSL`, `hmint : MintPaysForTimeFixed`, `hpb` |
| 9 | 12761 | `buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse_untlSnceFree` | `hSL`, `hpb`, `hfree` (`hmint` discharged) |

Nothing outside `MintBound.lean` references the symbol (repo-wide grep: only this file, plus
`specs/` artifacts).

---

## 5. The repair route — outcome (b), with the key half already proved

### 5.1 Why the residual as stated is unrepairable, and where the slack is

`UnorderedSuccessorLabelClosed fc L` (:6209) quantifies over **every** branch whose *labels* lie in
`L`, with **no formula confinement at all**. But its single consuming site,
`unorderedSuccessor_confined_signedUniverse_of_headroom` (:6224), derives *both*
`hbf : ∀ y ∈ b, y.formula ∈ C` and `hbl : ∀ y ∈ b, y.label ∈ L`, and feeds **only `hbl`** to `hlab`.
The formula-confinement fact is computed and then thrown away. That discarded hypothesis is the
entire slack, and it is exactly the `DifficultyBounded → StepLengthBounded` repair pattern: state
the residual at the strength the consumer can actually supply.

### 5.2 The two escape routes, and how each is closed

Per `applyRule_emitted_world_dichotomy` (:6156) and `unorderedSuccessor_time_dichotomy` (:7155), a
successor's label can leave `L` in exactly two ways:

| Coordinate | Escaping rules | Closed by |
|---|---|---|
| world | `.boxNeg`, `.diamondPos` only — both emit **only** at `Branch.nextWorld` | a `boxFree` stock condition (**new; shape-gate half proved, §5.3**) |
| time | the nine `freshTimeRules` (:6564) | `untlSnceFree` stock condition — **already landed**: `unorderedSuccessor_knownTimes_subset` (:12619) proves an `untl`/`snce`-free branch has *no* new times, at every frame class |

Plus the four-quadrant problem entry 21 warns about — `⟨w, t⟩` with `w` and `t` from *different*
formulas of `b`. **This is already paid for**: `TimeMergeClosed L` (:5707) is precisely
`∀ l ∈ L, ∀ l' ∈ L, ⟨l.world, l'.time⟩ ∈ L`, it is characterized as "L is a full rectangle"
(`timeMergeClosed_iff_product`, :5727), it is satisfiable and non-vacuous
(`timeMergeClosed_product`, :5714), and it is **already a hypothesis of every carrier in §4**. No
new currency is introduced.

### 5.3 The new shape-gate half — PROVED (compiles, no `sorry`)

`.boxNeg` is gated by `isApplicable`'s `| .boxNeg, .neg, .box _ => true` arm, and `.diamondPos` by
`asDiamond? φ`, whose only matching pattern `.imp (.box (.imp φ .bot)) .bot` also contains a `.box`
node (`Tableau.lean:267-269, 354-355`). So a **box-free** formula rejects both **at the shape gate,
before any frame-class gate is consulted** — the same structural reason
`MintBound.lean:12396-12403` gives for the `untlSnceFree` discharge carrying no frame-class
restriction. The following all compiled first try:

```lean
def boxFree : Formula → Bool
  | .atom _ => true | .bot => true
  | .imp a b => boxFree a && boxFree b
  | .box _ => false
  | .untl a b => boxFree a && boxFree b
  | .snce a b => boxFree a && boxFree b

theorem asDiamond_eq_none_of_boxFree {φ} (h : boxFree φ = true) : asDiamond? φ = none
theorem isApplicable_boxNeg_false_of_boxFree {sf fc} (h : boxFree sf.formula = true) :
    isApplicable .boxNeg sf fc = false
theorem isApplicable_diamondPos_false_of_boxFree {sf fc} (h : boxFree sf.formula = true) :
    isApplicable .diamondPos sf fc = false
theorem findApplicableRule_not_worldMinting {sf b ord fc r res o}
    (hfree : boxFree sf.formula = true) (h : findApplicableRule sf b ord fc = some (r, res, o)) :
    r ≠ .boxNeg ∧ r ≠ .diamondPos
```

### 5.4 What remains for Phase 2 (mechanical mirror of an existing section)

Section D3 (`:12421-12786`, the `untlSnceFree` discharge) is a line-for-line template. The
world-coordinate mirror needs:

- `pickBranches_worldFinset_subset` — mirror of `pickBranches_knownTimes_subset` (:12594),
  with `applyRule_emitted_world_mem` (:2223, hypotheses `rule ≠ .boxNeg`, `rule ≠ .diamondPos`) in
  place of `applyRule_emitted_time_mem`
- `pick_stage_source_noWorldMint` — mirror of `pick_stage_source_noMint` (:12544). Stage 1 uses
  §5.3's `findApplicableRule_not_worldMinting`; stages 2 and 3 run exactly one rule each
  (`serialityRule`, `timeLinearity` via `findApplicableSerialRule_rule` /
  `findApplicableLinearityRule_rule`), neither of which is `boxNeg`/`diamondPos`
- `unorderedSuccessor_worldFinset_subset` — mirror of `unorderedSuccessor_knownTimes_subset` (:12619),
  routed through the same `pick_branches_eq`
- the composite `unorderedSuccessor_label_mem_of_propositional` (world subset + time subset +
  `TimeMergeClosed L` + confinement ⇒ label ∈ L), then
  `unorderedSuccessor_confined_signedUniverse_of_propositional`,
  `universeClosedAt_signedUniverse_of_propositional`, and the terminus restatement with `hlab` gone
- non-vacuity: a `boxFree`-and-`untlSnceFree` stock is the **purely propositional** fragment
  (`atom`/`bot`/`imp`). A witness stock analogous to `modalWitnessStock` (:12729) is needed —
  note `modalWitnessStock` itself contains `□p` and therefore does **not** qualify

### 5.5 Honest scope of the repair — the reach is narrow

Combining `boxFree` with `untlSnceFree` collapses the stock to the propositional fragment, which is
strictly narrower than the modal fragment the `untlSnceFree` mint discharge reaches. That narrowing
is **forced, not a proof weakness**: `freshWorldHeadroom_not_universal` (:5964) proves no condition
on a finite `L` can absorb a fresh world, so any `L`-side discharge must forbid the world-minting
rules from firing at all, which means forbidding `.box` from the stock. The upside is real
— on that fragment the terminus would carry **two** residuals fewer (`hlab` and `hmint`), leaving
only `hSL : StepLengthBounded` and `hpb : PostBlockingSettles`.

This should be stated in the docstring in exactly the register `MintBound.lean:12416-12419` uses
("What this is not"), so no downstream artifact reads the propositional discharge as a general one.

---

## 6. Verified probe sources

Probe files (all compiled with `lake env lean` from the repo root against the built
`FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound`, warnings only, no `sorry`,
no axiom):

- `specs/481_discharge_or_replace_unorderedsuccessorlabelclosed_residual/probes/Probe1.lean` — the fourteen `rfl` facts hold with the label a free variable
- `specs/481_discharge_or_replace_unorderedsuccessorlabelclosed_residual/probes/Probe2.lean` — generalized engine lemmas + the three §2.1 theorems
- `specs/481_discharge_or_replace_unorderedsuccessorlabelclosed_residual/probes/Probe3.lean` — the four §5.3 theorems

The Probe2 refutation body, which Phase 1 can lift almost verbatim (`gp`/`gWitness`/`gBranch`/
`gEmitted` are the label-generalized replacements for `fwp`/`freshWorldWitness`/`freshWorldBranch`/
`freshWorldEmitted`):

```lean
theorem unorderedSuccessorLabelClosedOrd_nonempty_false
    (fc : FormalSystem.ProofSystem.FrameClass) (L : Finset Label) (hne : L.Nonempty) :
    ¬ UnorderedSuccessorLabelClosedOrd fc L := by
  intro h
  have hine : (L.image (·.world)).Nonempty := hne.image _
  obtain ⟨l₀, hl₀, hl₀w⟩ := Finset.mem_image.mp ((L.image (·.world)).max'_mem hine)
  have hstep := expandOnceUnblocked_gBranch fc EventualityTracker.empty l₀
  have hmem : (gEmitted l₀ ++ gBranch l₀)
      ∈ unorderedSuccessorBranches
        (expandOnceUnblocked (gBranch l₀) TimeOrdering.empty fc EventualityTracker.empty).1 := by
    rw [hstep]; simp [unorderedSuccessorBranches]
  have hbl : ∀ y ∈ gBranch l₀, y.label ∈ L := by
    intro y hy
    simp only [gBranch, List.mem_cons, List.not_mem_nil, or_false] at hy
    subst hy
    simpa [gWitness, SignedFormula.neg] using hl₀
  have hbad := h (gBranch l₀) TimeOrdering.empty EventualityTracker.empty
    (ordTimesKnown_empty (gBranch l₀)) hbl _ hmem
    (SignedFormula.neg gp ⟨l₀.world + 1, l₀.time⟩) (by simp [gEmitted])
  simp only [SignedFormula.neg] at hbad
  have hle : l₀.world + 1 ≤ (L.image (·.world)).max' hine :=
    Finset.le_max' (L.image (·.world)) (l₀.world + 1)
      (Finset.mem_image.mpr ⟨⟨l₀.world + 1, l₀.time⟩, hbad, rfl⟩)
  rw [hl₀w] at hle
  exact absurd hle (Nat.not_succ_le_self _)
```

---

## 7. Recommended phase decomposition for the planner

**Phase 1 — the sharpened verdict (outcome (c), amended not added).** Land the label-generalized
witness (`gWitness`/`gBranch`/`gEmitted` beside the existing `freshWorld*` family, which stays
verbatim — nothing in this file is withdrawn), the generalized engine lemmas, and the three §2.1
theorems. Amend C9 entry **21** — do **not** add a 25th entry — to record "refuted at every
nonempty `L`, satisfiable exactly at `∅`", and amend entry 11's third paragraph in the same
register. Correct the `unorderedSuccessorLabelClosed_not_universal` docstring, which currently
claims the residual "holds at every `L` for which the engine never fires" as if that were a
substantive class. Add the vacuity note to
`buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse_untlSnceFree`'s docstring (§2.3).
Estimated ~150-200 lines. **This phase alone is a complete, valid deliverable for the task's
acceptance criteria**, and it is the phase task 462 depends on.

**Phase 2 — the replacement (outcome (b)).** The `boxFree` mirror of section D3 per §5.3-5.4, the
propositional-stock discharge, the terminus restatement with `hlab` gone, and the non-vacuity
witnesses. Estimated ~250-350 lines. Split into 2a (the world-subset machinery) and 2b (the
composite + terminus restatement) if phase sizing demands.

**Zero-debt note.** No step above requires a `sorry` or a new axiom. Every load-bearing new
statement in Phases 1 and 5.3 has already been compiled. Phase 2's remaining pieces are structural
mirrors of a landed section, not open mathematics.

**Regression surface.** All nine carriers keep their statements verbatim; the new material is
additive. `check-module-invariants.sh` and `lake build` should be run after each phase.
