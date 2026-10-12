/-
Probe 761 (requirement (W)'s run layer, phase 2, the soundness half, over the two-state object):
**the ladder's structural liveness is FORWARD-ONLY — an admissible ladder history can be pending
at every past time, so `Cons`'s backward liveness field `slive` is not replaceable by `Count`,
and the realization theorem this probe accompanies is `[BLOCKED]` on the open index of which
cell a ladder state has.** This file is the machine-checked record of the one design fact the
blocked record settles, and of the reasons no statement of the record itself exists on the tree
as it stands.

**What was asked.** On `ladderModel` over `ladderFrameAdm` (`RaySummary/LadderModel.lean`), the
ladder analogue of `Realize.lean`'s `Cons`/`cons_localRun`/`presented_modelOf`, stated at the Hit
level per ladder cell:
  `structure LadderCons (φ : PlusFormula) (lab) (step) (pend) : Prop`
      -- `Cons`'s fields with the liveness fields `ulive`/`slive` replaced by the ladder's
         structural liveness, and with the `box`/`stab` letters PINNED per cell by the anchor
         layer's equations (`box_mem_tpOf_iff`, `stab_mem_tpOf_iff`)
  `theorem ladderCons_localRun …`
      -- every ladder run satisfies the run conditions
  `theorem ladderRealized … (k : ℕ) (hk : 1 ≤ k) :
      HitCl (ladderModel …) τ t φ k = ↑(hitOf (truncate B …) … (clNow φ) k)`
      -- per ladder cell, for ALL φ, `box`/`stab` letters INCLUDED, the cell being
         `cellAt (ladderModel …) φ (t, ⟨(q, c, n), h⟩)`

**Why no statement exists — first: `truncate` is defined nowhere.** No declaration of that name
exists under `FormalSystem/`, in this evidence collection, or in `docs/theorem-index.md`; the
only hits are the fixture theorems `hitCl_eq_truncated` / `hitCl_eq_truncated_node`, which
truncate a seam-index WINDOW on a fixture, not a ladder. `hitOf` needs `[Fintype Q]` on its
presentation and the ladder carrier `LadderState Q pend` is infinite, so `hitOf (truncate B …)`
can only mean the counter-clipping quotient `Q × Fin (B+1) × Fin (B+1)` — exactly the index
`ladder-cell-refutation.lean` refutes (`cell_ne`, `exhibited_form_refuted`,
`exists_form_refuted`) and the record deletes. The statement line is internally inconsistent.

**Why no statement exists — second: every per-cell soundness statement presupposes a finite
index of ladder states, the open sub-problem.** Three independent, library-anchored reasons,
none re-proved here. (a) `Probe760.cell_ne B : cellAt M phi (w1 B) 0 ≠ cellAt M phi (w2 B) 0`
for every `B`: a presentation whose states carry one type set per `q ∈ Q` cannot be saturated
(HWZ Def. 12, "every `t ∈ T_w` lies on some run") at both `w1 B` and `w2 B`, so saturation fails
on every `Q`-indexed candidate. (b) `Count true true` forces a pending region at `(q, c, n)` to
end at exactly `z + c + 1`, so a `step`-chain through `q₀` whose pend-pattern does not end its
region in `c₀` steps lifts to NO `RladAdm` path through `(q₀, c₀, n₀)`: the `Q`-projection of a
seam fibre is a PROPER subset of `{ρ | IsRun lab step (clNow φ) t ρ}`, and `hitOf` over `Q`
over-approximates `HitCl` even for `box`/`stab`-free `φ`. (c) The `stab` clause of
`PlusTruth.lean` — `PlusTruthAt M τ t (.stab ψ) ↔ ∀ σ, τ.state t = σ.state t →
PlusTruthAt M σ t ψ` — makes any labelling that reads closure truth off the world state alone
force `ψ → ⊡ψ` at every point: the eighth probe's `Probe747.stab_iff_of_presented_nowUnique`
with both of its hypotheses (`Presented`, `nowUnique`) dropped, false for any object with a
non-deterministic `step` and an `untl` letter. Hence a per-cell object carries a SET of types per
ladder state, which a finite object can do only through a finite index of those states.

**Why no statement exists — third: the `box`/`stab` acceptance clause presupposes the same
index.** "The stab letter at `(q, c, n)` is that cell's bit" presupposes a presentation state
per cell at which the bit is stored (`stab_mem_tpOf_iff` is per cell). With no index, a
`LadderCons` field can only pin `lab q (⊡ψ)` per `q` — the wrong granularity by (a). A
`LadderCons` without the clause would be a same-named, strictly weaker statement, and is not
written.

**What this probe establishes (F4).** The object `Q = Bool`, `stepB ≡ true`, `pendB = id`
(`true` pending, `false` idle); the history
  `gPast B z := if z ≤ 0 then (true, (-z).toNat, B) else (false, 0, B)`
pending at every past time with the countdown `(-z).toNat`, idle from `1` on, `n = B`
throughout; its admissibility `gPast_adm` (every `z`); `gPastA B` the admissible history; and
the three statements, verbatim:
  `theorem gPast_isPath (B : ℕ) : IsSlicedStepPath (RladAdm stepB pendB) 0 (gPastA B)`
  `theorem gPast_pending_past (B : ℕ) (z : ℤ) (hz : z ≤ 0) : (gPastA B z).1.1 = true`
  `theorem gPast_count (B : ℕ) (z : ℤ) (hz : z ≤ 0) : (gPastA B z).1.2.1 = (-z).toNat`
The mechanism: forward, `Count true true` reads `c' + 1 = c`, so the current deadline counts
down and a pending region ends; backward, the SAME clause reads `c = c' + 1` for the predecessor,
so the countdown GROWS into the past without bound — `(-z).toNat` at `z ≤ 0`. A `snce`-letter
claimed along `gPastA B` is never structurally discharged: no pending region of this history
ever begins.

**Consequence for a successor bundle.** `ulive` is replaceable by the ladder's structural
liveness — forward, a pending state `(q, c, n)` at `z` is idle at `z + c + 1`; with a pend-field
and `persist` this is `untl_iff_of_UCoh_ULive`'s shape. `slive` is NOT: it must stay as
`Realize.lean`'s `SLive` deferral-graph condition over `Q`'s `step`, sound on ladder paths because
`Rlad`'s first conjunct makes the `Q`-projection a `step`-chain. What transfers from
`Realize.lean`, as description and not as a plan: `UCoh`, `deferGraph`, `Disch`, `persist`,
`SCoh`, `bwdDeferGraph`, `SLive`, `snce_iff_of_SCoh_SLive`, each reusable on the `Q`-projection.
What does not: `frameOf`/`modelOf` (finite WIDTH — `Probe747.modelOf_incomplete`),
`presented_modelOf` (trace level), `anchored_runTrace_of_boxStabFree`,
`run_seam_state`/`isRun_of_chain_seam` (each reads a seam state off a finite presentation).

**What a true statement would need** (no claim is made here). A finite index of ladder states
per cell — the open sub-problem. A theorem parametric in an abstract index
`idx : LadderState Q pend → I`, `[Fintype I]`, with a saturation hypothesis, is the
unsatisfiable-hypothesis form unless some `idx` is exhibited for a `⊡`-bearing `φ`; that is
research-level and not claimed. The two Hit-level positives in this collection,
`hitCl_eq_truncated` and `hitCl_eq_truncated_node`, are fixture arguments (a seam
classification, a constant-block run, a fixture subset fact) and supply no general truncation
lemma: on the ladder the seam fibre at a fixed `(q₀, c₀, n₀)` is infinite for any object with a
pending cycle.

**What this probe does NOT say.** (a) Cells are closure-indexed SETS over the time axis,
`box`/`stab` bits included, never one bit per depth. (b) The slice `LadderState Q pend` is
infinite (`Rlad_slice_infinite` one level down) and no fibre bound is assumed or claimed. (c) No
upper bound of any kind, no complexity bound — `B` is a count, carried through unchanged.
(d) Zero debt: no external lemma, no cslib require, nothing cited in place of a proof; every
theorem cites `LadderModel.lean` and re-proves nothing. (e) The landed form is forward-only in
the precise sense that the FORWARD liveness is structural and the BACKWARD one is not — the
witness is a past-pending history of the LADDER, not a claim about `⊡(Pp)` or about any backward
fixture (nothing beyond `Probe719Backward.pastStab_iff_allBwdPathsMeet` is claimed there); no
device-discrimination claim. Also: nothing about `HitPresented` or `PlusValidZTime` in any form;
`anchorCells_finite` and `anchorCells_ncard_le` untouched (the SET of cells stays finite and
bounded; what is open is the computable index of WHICH cell a ladder state has);
`presented_modelOf` untouched; no `LadderRealize.lean` exists and none is created by this probe;
the index-free, `box`/`stab`-free run-layer half is a design option not taken here; the
successor design is not chosen here.

`gPast_isPath` carries `[propext, Classical.choice, Quot.sound]`; `gPast_pending_past` and
`gPast_count` carry `[propext, Quot.sound]`.

Compile: `lake env lean specs/evidence/seam-gluing-ray-product/ladder-liveness-forward-only.lean`
-/
import FormalSystem.Metalogic.Decidability.RaySummary.LadderModel

open FormalSystem.Syntax FormalSystem.Semantics
open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe761

/-- The two-state object: `step` total, `pend` the identity (`true` pending, `false` idle). -/
abbrev stepB : Bool → Bool → Bool := fun _ _ => true
abbrev pendB : Bool → Bool := fun q => q

/-- Pending at every past time with the countdown `(-z).toNat`, idle from `1` on; `n = B`
throughout. -/
def gPast (B : ℕ) (z : ℤ) : Bool × ℕ × ℕ :=
  if z ≤ 0 then (true, (-z).toNat, B) else (false, 0, B)

theorem gPast_adm (B : ℕ) (z : ℤ) : (gPast B z).2.1 ∈ Adm pendB (gPast B z).1 := by
  unfold gPast
  split_ifs <;> simp [Adm]

def gPastA (B : ℕ) (z : ℤ) : LadderState Bool pendB := ⟨gPast B z, gPast_adm B z⟩

theorem gPast_isPath (B : ℕ) : IsSlicedStepPath (RladAdm stepB pendB) 0 (gPastA B) := by
  intro z
  rcases lt_trichotomy z 0 with h | h | h
  · have h1 : z ≤ 0 := le_of_lt h
    have h2 : z + 1 ≤ 0 := by omega
    simp [RladAdm, Rlad, gPastA, gPast, h1, h2, Drift, Count]
    omega
  · subst h
    simp [RladAdm, Rlad, gPastA, gPast, Drift, Count]
  · have h1 : ¬ z ≤ 0 := not_le.mpr h
    have h2 : ¬ z + 1 ≤ 0 := by omega
    simp [RladAdm, Rlad, gPastA, gPast, h1, h2, Drift, Count]

theorem gPast_pending_past (B : ℕ) (z : ℤ) (hz : z ≤ 0) : (gPastA B z).1.1 = true := by
  simp [gPastA, gPast, hz]

/-- The countdown along the past is unbounded: no pending region of `gPastA` ever ends. -/
theorem gPast_count (B : ℕ) (z : ℤ) (hz : z ≤ 0) : (gPastA B z).1.2.1 = (-z).toNat := by
  simp [gPastA, gPast, hz]

end Probe761

#print axioms Probe761.gPast_isPath
#print axioms Probe761.gPast_pending_past
#print axioms Probe761.gPast_count
