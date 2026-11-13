/-
# THE `hself` DERIVABILITY DECISION PROBE

A DECISION GATE, not a deliverable, and it decides NO DISPOSITION. Two landed, sorry-free cascade
declarations of `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` —
`exists_ladderPath_at_region_of_idle_past` (`:2227`) and the join `exists_ladderPath_at_region`
(`:2291`) — each carry one binder beyond their recorded blocks, the path-local self-loop

```
hself : ∀ p : ℤ, p ≤ a → pend (objAt g p) = false → step (objAt g p) (objAt g p) = true
```

whose disposition is a USER RULING that no agent may take. This probe settles the one question
underneath that ruling which is a matter of FACT rather than of judgement: **is `hself` derivable
from the other binders those two declarations already carry, or is it a genuine additional
premise?** The answer is a compiled object, not an argument.

## The verdict: NOT DERIVABLE

Recorded as a compiled top-level declaration rather than as a comment:

| Declaration | What it compiles |
|-------------|------------------|
| `hself_not_derivable` | the universally quantified implication from the recorded binders to `hself` is FALSE — and false even with `Fintype Q` assumed, which is strictly stronger than refuting it without finiteness and strictly stronger than what the two declarations' own binder lists need (neither takes a finiteness instance) |
| `instance_is_in_regime` | NON-VACUITY: the counterexample satisfies EVERY binder of `exists_ladderPath_at_region_of_idle_past` — `hg`, `hl`, `hcl`, `hidle`, `hrep`, `hv`, `hvreg` — so it is a counterexample to the DERIVATION and not to the regime |
| `instance_self_loop_fails` | the failing self-loop at the instance: an idle position `p = 0 ≤ a = 1` of the compiled ladder path with `stepD (objAt gW 0) (objAt gW 0) = false` |
| `hself_satisfiable_at_an_instance` | `hself` is also not REFUTABLE: the same walk over a total `step` satisfies every binder AND `hself`. Together with `hself_not_derivable` this is what "genuine additional premise" means — independent of the other binders, neither implied by them nor contradicted by them |
| `idle_successor_differs` | the exact gap the derivation stalls on, isolated: at the instance's idle position the walk MOVES (`objAt gW 1 ≠ objAt gW 0`), so `isLadderPath_components` (`LadderAgree.lean:636`) supplies `step (objAt gW 0) (objAt gW 1) = true` and never touches the diagonal |

**What the verdict implies for each of the three dispositions**, stated for Phase 11.16's first
task to read and carrying NO recommendation on the ruling:

* Disposition (R) — repair in-library, `hself` discharged and no binder at all — is **CLOSED by
  this probe**. `hself_not_derivable` is a compiled refutation of exactly the implication (R)
  would need, so no repair at this layer can remove the binder.
* The two remaining dispositions are untouched by this probe, and the choice between them is a
  choice between two honest naming conventions rather than between a correct and an incorrect
  statement. `hself` is a true additional hypothesis on a general object relation: the recorded
  blocks are not wrong about the mathematics, they are silent about one premise.

## The instance

Fixed, explicit, and compiled — every line below is a theorem of this file, not a hypothesis of
it:

```
carrier          Qd = Fin 2,  pendD 0 = false (idle),  pendD 1 = true (pending)
object relation  stepD q q' = decide (q = 1 ∨ q' = 1)      -- so stepD 0 0 = false
walk             period 4: objW u = 0 iff u % 4 = 0, else 1   (idle, pending, pending, pending)
countdown        cntW u = 2 at u % 4 = 1, 1 at u % 4 = 2, 0 otherwise
next deadline    constant 2                                   -- Drift 2 2 by `Or.inl rfl`
splice point     a = 1   (pending, cntAt gW 1 = 2)
cycle length     l = 2   (0 < l and l ≤ cntAt gW a = 2)
repetition       objAt gW 1 = objAt gW 3 = 1                  -- hrep at this l
idle witness     p = 0   (p ≤ a and pendD (objAt gW 0) = false)
comparison pos   v = 1   (v ≤ a and a ≤ v + cntAt gW v = 1 + 2)
failing self-loop at p = 0: stepD 0 0 = false
```

The countdown is forced rather than chosen, which is why the object is this shape and not the
shorter one: `Count`'s pending→idle clause requires `c = 0` at the last pending position of a
region, its pending→pending clause counts down by exactly one, and its idle→pending clause hands
over the next-deadline register. A region of three pending positions is therefore the shortest one
whose start carries `cntAt = 2`, and `hcl : l ≤ cntAt g a` together with `hrep` needs `l ≥ 2`
here because the object repeats inside the region (`objW 1 = objW 3 = 1`) and not at distance `1`.

## Why the DERIVABLE branch cannot close, recorded as the bounded attempt it was

`IsLadderPath step pend g` is `∀ u, RladAdm step pend u (g u) (g (u + 1))`, and the only `step`
fact it yields is `step (objAt g u) (objAt g (u + 1)) = true` (`isLadderPath_components`,
`LadderAgree.lean:636`/`:647`). A derivation of `hself` at an idle `p ≤ a` would therefore need
`objAt g (p + 1) = objAt g p` — the walk standing still at that position — and NO binder of
`exists_ladderPath_at_region_of_idle_past` supplies it: `hidle` supplies one idle position below
`a` and says nothing about its successor; `hrep` is a repetition at the PENDING position `a` at
distance `l`; `hl`, `hcl`, `hv` and `hvreg` are arithmetic on the countdown. `idle_successor_differs`
isolates that gap at the instance. A grep of every module under
`FormalSystem/Metalogic/Decidability/RaySummary/` finds every diagonal `step q q = true`
occurrence in the tree to be a HYPOTHESIS (`LadderAgree.lean:1867`, `:2233`, `:2296`, `:2878`) and
never a conclusion, which is consistent with this verdict and is not what establishes it.

## NON-GENERALITY. What this probe does NOT establish.

**It decides DERIVABILITY at this layer and nothing else.** It does not say `hself` is
unsatisfiable (`hself_satisfiable_at_an_instance` compiles the opposite), it does not say the two
landed declarations are wrong, it does not rename or re-sign either of them, and it takes no
position on the Stage 0 ruling in `specs/ROADMAP.md`.

**It does not touch candidate (b).** The primitive-decision note at `LadderAgree.lean:1758-1790`
records a second candidate — insert a copy of an idle-containing cycle, obtained by a pigeonhole
over a finite object type — and records it as UNAVAILABLE AT THIS LAYER because the idle-past
regime hypothesis supplies exactly ONE idle position at or below the splice point while that
pigeonhole needs many idle runs below it. This probe refutes the derivation of `hself` from the
recorded binders; it says nothing about whether some OTHER construction, at some other layer,
could avoid needing a self-loop at all. The one landed pigeonhole of that family lives in
`LadderPin.lean`, above `LadderAgree.lean` in the import DAG, and is cited here by path only.

**It is not a step toward any of this task's filed Goals.** Nothing under the names
`exists_ladderPath_at_region_of_idle_past`, `exists_ladderPath_at_region`,
`exists_spliced_ladderPath_of_idle_past`, `cellAt_const_of_kappa_eq`, `ladderSound`,
`ladderCons_localRun`, `ladderLift` or `ladderRealized` is landed by this file, in the library or
here. A probe is compiled with `lake env lean` outside the Lake module graph, so it imports no
other probe and re-derives whatever it needs; no other probe and no library file is edited or
re-signed by it.
-/
import FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree

set_option autoImplicit false

open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe761SelfLoop

/-! ### The object: two states, one idle without a self-loop -/

/-- The carrier. `0` is the idle state, `1` the pending one. -/
abbrev Qd : Type := Fin 2

def pendD : Qd → Bool := fun q => decide (q = 1)

/-- The object relation. Every transition touching the pending state `1` is allowed; the only
forbidden transition is the IDLE SELF-LOOP `0 → 0`, which is exactly the fact `hself` asserts and
this object denies. -/
def stepD : Qd → Qd → Bool := fun q q' => decide (q = 1 ∨ q' = 1)

/-- The totally permissive relation, used only for `hself_satisfiable_at_an_instance`. -/
def stepTotal : Qd → Qd → Bool := fun _ _ => true

theorem pendD_zero : pendD 0 = false := by decide

theorem pendD_one : pendD 1 = true := by decide

/-- The idle state has no self-loop. -/
theorem stepD_diag_zero : stepD 0 0 = false := by decide

/-! ### The walk, its countdown, and its lift to the admissible carrier

Period `4`: one idle position followed by a pending region of three. The countdown is forced by
`Count` and is not a free choice — see this file's header. -/

def objW (u : ℤ) : Qd := if u % 4 = 0 then 0 else 1

def cntW (u : ℤ) : ℕ := if u % 4 = 1 then 2 else if u % 4 = 2 then 1 else 0

/-- The countdown is admissible at the walk's object: `0` at every idle position. -/
theorem objW_adm (u : ℤ) : cntW u ∈ Adm pendD (objW u) := by
  intro h
  unfold objW pendD at h
  unfold cntW
  split_ifs with h1 h2 <;> simp_all

/-- The ladder path's underlying function into the admissible carrier, with the next-deadline
register constant at `2`. -/
def gW (u : ℤ) : LadderState Qd pendD := ⟨(objW u, cntW u, 2), objW_adm u⟩

theorem objAt_gW (u : ℤ) : objAt gW u = objW u := rfl

theorem cntAt_gW (u : ℤ) : cntAt gW u = cntW u := rfl

theorem nxtAt_gW (u : ℤ) : nxtAt gW u = 2 := rfl

/-- **The walk is a ladder path over ANY object relation that admits its own transitions.** The
three clauses of `RladAdm` that do not mention `step` — the idle-zero side condition, `Drift` on
the constant register, and `Count` on the forced countdown — are discharged here once, so that the
same walk can be read over `stepD` (where the idle self-loop fails) and over `stepTotal` (where it
holds) without the `Count` case analysis being repeated. -/
theorem gW_isLadderPath_of_step (step : Qd → Qd → Bool)
    (hstep : ∀ u : ℤ, step (objW u) (objW (u + 1)) = true) :
    IsLadderPath step pendD gW := by
  intro u
  have h : u % 4 = 0 ∨ u % 4 = 1 ∨ u % 4 = 2 ∨ u % 4 = 3 := by omega
  refine ⟨hstep u, objW_adm u, Or.inl rfl, ?_⟩
  show Count (pendD (objW u)) (pendD (objW (u + 1))) (cntW u) 2 (cntW (u + 1))
  unfold objW cntW pendD Count
  rcases h with h | h | h | h <;>
    · have h' : (u + 1) % 4 = (u % 4 + 1) % 4 := by omega
      rw [h] at h'
      norm_num at h'
      simp [h, h']

/-- `stepD` admits every transition of the walk: each step of the walk touches the pending state
`1`, because the walk is never idle twice in a row. -/
theorem stepD_along_objW (u : ℤ) : stepD (objW u) (objW (u + 1)) = true := by
  have h : u % 4 = 0 ∨ u % 4 = 1 ∨ u % 4 = 2 ∨ u % 4 = 3 := by omega
  unfold objW stepD
  rcases h with h | h | h | h <;>
    · have h' : (u + 1) % 4 = (u % 4 + 1) % 4 := by omega
      rw [h] at h'
      norm_num at h'
      simp [h, h']

theorem gW_isLadderPath : IsLadderPath stepD pendD gW :=
  gW_isLadderPath_of_step stepD stepD_along_objW

theorem gW_isLadderPath_total : IsLadderPath stepTotal pendD gW :=
  gW_isLadderPath_of_step stepTotal (fun _ => rfl)

/-! ### The instance's binders, each a compiled fact -/

theorem objAt_gW_zero : objAt gW 0 = 0 := by rw [objAt_gW]; unfold objW; norm_num

theorem objAt_gW_one : objAt gW 1 = 1 := by rw [objAt_gW]; unfold objW; norm_num

theorem objAt_gW_three : objAt gW 3 = 1 := by rw [objAt_gW]; unfold objW; norm_num

theorem cntAt_gW_one : cntAt gW 1 = 2 := by rw [cntAt_gW]; unfold cntW; norm_num

/-- `hidle` at the instance: `p = 0` is an idle position at or below the splice point `a = 1`. -/
theorem instance_hidle : ∃ p : ℤ, p ≤ (1 : ℤ) ∧ pendD (objAt gW p) = false :=
  ⟨0, by norm_num, by rw [objAt_gW_zero]; exact pendD_zero⟩

/-- `hrep` at the instance, at the cycle length `l = 2`: the object repeats INSIDE the pending
region, which is why `l = 1` would not do. -/
theorem instance_hrep : objAt gW 1 = objAt gW (1 + ((2 : ℕ) : ℤ)) := by
  rw [objAt_gW_one, show (1 : ℤ) + ((2 : ℕ) : ℤ) = 3 by norm_num, objAt_gW_three]

/-- **THE GAP THE DERIVATION STALLS ON, ISOLATED.** At the instance's idle position the walk
MOVES. So `isLadderPath_components` supplies `stepD (objAt gW 0) (objAt gW 1) = true` and says
nothing whatever about `stepD (objAt gW 0) (objAt gW 0)`, which is the diagonal `hself` asks
about. -/
theorem idle_successor_differs : objAt gW 1 ≠ objAt gW 0 := by
  rw [objAt_gW_zero, objAt_gW_one]; decide

/-- **THE FAILING SELF-LOOP, AT A COMPILED LADDER PATH.** `gW` is a ladder path over
`(stepD, pendD)`, the position `p = 0` is idle and at or below the splice point `a = 1`, and the
self-loop `hself` asks for there is FALSE. -/
theorem instance_self_loop_fails :
    IsLadderPath stepD pendD gW ∧ (0 : ℤ) ≤ 1 ∧ pendD (objAt gW 0) = false ∧
      stepD (objAt gW 0) (objAt gW 0) = false :=
  ⟨gW_isLadderPath, by norm_num, by rw [objAt_gW_zero]; exact pendD_zero,
    by rw [objAt_gW_zero]; exact stepD_diag_zero⟩

/-- **NON-VACUITY: THE COUNTEREXAMPLE IS IN THE REGIME.** Every binder of
`exists_ladderPath_at_region_of_idle_past` (`LadderAgree.lean:2227`) holds at this instance, listed
in the declaration's own order — `hg`, `hl`, `hcl`, `hidle`, `hrep`, then `hv` and `hvreg` at the
comparison position `v = 1`. So `instance_self_loop_fails` refutes the DERIVATION of `hself` from
those binders, and is not a counterexample to the idle-past regime itself. -/
theorem instance_is_in_regime :
    IsLadderPath stepD pendD gW ∧ 0 < (2 : ℕ) ∧ (2 : ℕ) ≤ cntAt gW 1 ∧
      (∃ p : ℤ, p ≤ (1 : ℤ) ∧ pendD (objAt gW p) = false) ∧
      objAt gW 1 = objAt gW (1 + ((2 : ℕ) : ℤ)) ∧
      (1 : ℤ) ≤ 1 ∧ (1 : ℤ) ≤ 1 + (cntAt gW 1 : ℤ) :=
  ⟨gW_isLadderPath, by norm_num, by rw [cntAt_gW_one], instance_hidle, instance_hrep,
    le_rfl, by rw [cntAt_gW_one]; norm_num⟩

/-! ### The verdict -/

/-- **THE VERDICT: `hself` IS NOT DERIVABLE.** The universally quantified implication from the
binders `exists_ladderPath_at_region_of_idle_past` records — `hg`, `hl`, `hcl`, `hidle`, `hrep`,
`hv`, `hvreg` — to the path-local self-loop `hself` is FALSE.

It is refuted here with `Fintype Q` ASSUMED, which is strictly stronger than refuting it without
finiteness, and strictly stronger than what the two landed declarations need: both sit in
`LadderAgree.lean`'s `section Path`, whose variable block is `{Q : Type} {step} {pend}` with no
finiteness instance at all. So no appeal to a finite object type repairs the derivation either,
which is the half of the primitive-decision note at `LadderAgree.lean:1758-1790` this declaration
machine-checks.

Consequence for the ruling, carrying no recommendation on it: disposition (R) — an in-library
repair discharging `hself` and adding no binder — asks for exactly this implication, and this
declaration closes it. -/
theorem hself_not_derivable :
    ¬ ∀ (Q : Type) (_ : Fintype Q) (step : Q → Q → Bool) (pend : Q → Bool)
        (g : ℤ → LadderState Q pend) (a : ℤ) (l : ℕ),
        IsLadderPath step pend g → 0 < l → l ≤ cntAt g a →
        (∃ p : ℤ, p ≤ a ∧ pend (objAt g p) = false) →
        objAt g a = objAt g (a + (l : ℤ)) →
        ∀ v : ℤ, v ≤ a → a ≤ v + (cntAt g v : ℤ) →
        ∀ p : ℤ, p ≤ a → pend (objAt g p) = false →
          step (objAt g p) (objAt g p) = true := by
  intro h
  have hbad :=
    h Qd inferInstance stepD pendD gW 1 2 gW_isLadderPath (by norm_num)
      (by rw [cntAt_gW_one]) instance_hidle instance_hrep 1 le_rfl
      (by rw [cntAt_gW_one]; norm_num) 0 (by norm_num)
      (by rw [objAt_gW_zero]; exact pendD_zero)
  rw [objAt_gW_zero, stepD_diag_zero] at hbad
  exact Bool.false_ne_true hbad

/-- **AND IT IS NOT REFUTABLE EITHER: `hself` IS A GENUINE INDEPENDENT PREMISE.** The same walk,
read over the totally permissive object relation, satisfies every binder of
`exists_ladderPath_at_region_of_idle_past` AND the self-loop. Together with
`hself_not_derivable` this is what makes `hself` a premise rather than a defect: it is independent
of the other binders — neither implied by them (`hself_not_derivable`) nor contradicted by them
(here) — so the recorded blocks are not wrong about the mathematics, only silent about one
hypothesis. -/
theorem hself_satisfiable_at_an_instance :
    IsLadderPath stepTotal pendD gW ∧ 0 < (2 : ℕ) ∧ (2 : ℕ) ≤ cntAt gW 1 ∧
      (∃ p : ℤ, p ≤ (1 : ℤ) ∧ pendD (objAt gW p) = false) ∧
      objAt gW 1 = objAt gW (1 + ((2 : ℕ) : ℤ)) ∧
      (∀ p : ℤ, p ≤ (1 : ℤ) → pendD (objAt gW p) = false →
        stepTotal (objAt gW p) (objAt gW p) = true) :=
  ⟨gW_isLadderPath_total, by norm_num, by rw [cntAt_gW_one], instance_hidle, instance_hrep,
    fun _ _ _ => rfl⟩

end Probe761SelfLoop
