/-
THE CLIPPED-COORDINATE CELL INDEX OF THE ADMISSIBLE LADDER CARRIER IS REFUTED AT A SECOND,
INDEPENDENT COORDINATE -- the countdown's PARITY, observable at the region end -- uniformly in
the clip bound; the bounded-carrier alternative is closed by the finite-width limitation; and what
remains landed is a GATED candidate together with an EXHIBITED threshold and period, never a
factorization lemma.

## What was asked

Define a computable index `ladderIndex B` carrying the gap coordinate that the earlier,
two-coordinate candidate discards,
  `(q, min c B, min n B, clip (n - c) [-B, B])`,
a `Fintype` as `Q × Fin (B+1) × Fin (B+1) × Fin (2*B+1)`, and prove the factorization lemma
  `ladderIndex B x = ladderIndex B y → cellAt M φ (t,x) z = cellAt M φ (t,y) z`
in either of two forms: at the exhibited bound `B = |cl φ|`, or existentially over `B`.

## Why it is false

`Count true true` forces `c' + 1 = c` -- there is no early discharge with leftover -- so the
countdown of a pending region runs down to `0` exactly and the FIRST IDLE STATE of the region sits
at distance exactly `c + 1`.  The object's `step` relation is independent of the counters, so it
may alternate a tag on every pending step and copy that tag onto the idle state that ends the
region.  An atom reading the tag, under `p U (r ∧ a)`, therefore reads `c mod 2` at a distance no
bound on `c` can reach.

Machine-checked here: `pending_run` and `idle_at` force the region, `truth_phiP` shows the truth
of the formula at a pending ladder state is a function of the countdown's parity and of nothing
else -- not of the next deadline `n`, not of any drift choice -- `cell_succ_ne` separates
`(q, c, n)` from `(q, c+1, n)` for EVERY `c` and `n` with `n` held FIXED, `index_collide` puts
`((true,false), 2B, 4B+2)` and `((true,false), 2B+1, 4B+2)` at one index at every `B`, and
`ladderIndex_not_factoring` concludes.  Both filed forms fall with it:
`exhibited_form_refuted` and `exists_form_refuted`.

The witnessing pair carries EQUAL next-deadlines and two gaps that BOTH saturate the clip, so the
gap coordinate is not what fails -- the countdown coordinate is.  **The gap mechanism recorded by
the twelfth wired probe is real and is NOT displaced**: it killed a SMALL gap at LARGE counters, a
genuinely gap-shaped obstruction, which is exactly why the gap coordinate is RETAINED below rather
than dropped.  This record adds a second mechanism; it does not replace the first.

## What the earlier one-part gate did and did not certify

The dispatch that filed the statement also filed a falsification test, and that test was sound and
non-vacuous: on the known refutation's own pair -- counters `(B, B+1)` against `(B, B+2)` -- the
gap coordinate DOES separate, for every clip bound of at least two (`gate_separates`), and it
COLLIDES below two (`gate_collides_below_two`).  Two things follow.  First, the clip bound must be
derived from the FORMULA -- its `X`-nesting depth, or `|cl φ|` -- and never from the counters,
since it must exceed the gaps the formula can see.  Second, and this is the lesson the present
record exists to carry: **a gate probing one coordinate certifies one coordinate.**  The candidate
that passed the one-part gate is refuted above at a coordinate the gate never touched.

## The bounded-carrier alternative, closed

The alternative to indexing the carrier is bounding it: replace the infinite admissible ladder
carrier by its deadline-bounded sub-carrier, which is a `Fintype` outright, so that no index is
needed.  The premise that makes that a general route is "every refutable formula has a refuting
ladder object with deadlines below some bound derived from the formula", and it is FALSE.

`bounded_ladder_finite` -- the bounded sub-carrier IS finite, as the route claims.
`finBranch_eq_ofSlicedStep` -- on a finite carrier the run layer's finite-branching frame
constructor is LITERALLY the sliced-step one (`rfl`: the two differ only in which proof discharges
`Saturation`, and proof irrelevance is definitional, so no transport lemma is needed).
`bounded_width_validates_Phi_neg` -- hence EVERY model on such a frame validates the finite-width
non-validity, by `NoFiniteWidth.no_finite_width_sat` applied unchanged.
`Phi_neg_not_valid` -- and that formula is not valid over integer time.
So the route cannot reach it.

The narrow carve-out, stated honestly rather than suppressed: a bounded carrier remains available
for a target that DOES have a finite-width countermodel.  That limitation's own disclaimer
(`NoFiniteWidth`, `not_finite_width_fmp`) is the right citation for the scope of what fails here.
What is refuted is the bounded-carrier route as the GENERAL route, not the bounded carrier as a
device.

## What is gated, and what is exhibited

**Gated.**  The re-scoped candidate `ladderIndexRes T P B`,
  `(q, min c T, c % (P+1), min n T, n % (P+1), clip (n - c) [-B, B])`,
separates both known pairs: `gate_gap_separates` on the gap pair that killed the two-coordinate
index (every clip bound of at least two), and `gate_parity_separates` on the parity pair that
kills the three-coordinate index (every modulus of at least two, stated at a SYMBOLIC modulus --
`consec_mod_ne` is the supporting arithmetic, since two consecutive naturals cannot be congruent
modulo `P+1`).  The three parameters are independent: `T` and `P` are object-derived, `B` is
formula-derived, and no theorem's hypotheses couple them.

**Exhibited.**  The datum the region end exposes is `step`-reachability in `c + 1` steps, and
iteration of any endofunction of a finite type is eventually periodic
(`iterate_eventually_periodic`), hence so is the reachability set of a finite object
(`reachN_eventually_periodic`).  That EXHIBITS the threshold `T` and the genuinely positive period
`P` at which the candidate's two residue coordinates are taken, instead of assuming them.

**The third gate, run one region out and in the past direction.**  Its recorded outcome, in the
sentence the measuring record wrote:

  No refutation was found on these three attempts.  Three attempts on one fixture family show
  that the known mechanisms and the nearest unknown one do not lift to the six-coordinate shape;
  they do not show that the general factorization holds, which remains OPEN and is stated
  nowhere.

The attempts, and what each measured.  **Second region's end**: `second_region_any_length` --
`Count false false` holds the countdown at `0` through an idle interval of ANY length while
`Drift` moves the next deadline by one per step in either direction, so EVERY second-region length
is reachable from EVERY pending state; hence `second_region_end_tag_achievable` (both parities of
the second region's end tag are achievable everywhere) and `second_region_sets_agree` (any two
pending states with the same object component have the SAME achievable second-region-end tag set,
for any counters).  The second region's end separates nothing, and for a reason independent of
`T`, `P` and `B`: idle drift freedom.  **The past direction**: the gap rises by at most two per
pending step (`gap_step_le`) and is at most one at a region start
(`gap_region_start_le_one`), so a state `j` steps past its region start has gap at most `2j - 1`
(`gap_le_region_age`); contrapositively a gap above `2k - 1` puts every region start beyond `k`
backward steps (`region_start_beyond_depth`), and the attempt's pair saturates the clip
identically (`clipped_gap_collides`).  The recorded refinement: the clip bound's formula-derivation
must cover `snce`-nesting depth as well as `X`-nesting depth.  **One region further**:
`third_region_any_length` -- subsumed, because the second-region theorem is stated from an
arbitrary pending state, so iterating it is one application of transitivity and no achievable
widths compound.

Two limits on what those three say, stated here rather than left to a reader: they are
REACHABILITY statements about the admissible carrier, not truth statements about `cellAt`; and the
past-direction bound locates a region START, which is not the same as showing that no
`snce`-formula separates the pair.

## What this probe does NOT say

- **No factorization lemma, for any index, in any shape.**  Not for the refuted three-coordinate
  candidate, which is false; not for the six-coordinate candidate, whose sufficiency is ARGUED and
  gated but not proved, and is asserted nowhere in this file.  The positive lemma is OPEN.
- No seventh coordinate, and no index of any width is claimed to factor the cells.
- No upper bound and no complexity bound, for the index or for anything it feeds; every quantity
  named here is a COUNT.
- No finiteness is added anywhere.  `anchorCells_finite` and `anchorCells_ncard_le` are
  UNTOUCHED: the SET of cells is still finite and still bounded.  What is absent is only the
  computable INDEX.
- Nothing about `HitPresented`; no declaration mentions `PlusValidZTime` except the one that
  states the finite-width non-validity it needs.
- No library module is created and no declaration is added under the main library; the only
  library-side edits this record carries are a module docstring and record rows.
- The acceptance clause is never dropped.  It rides on the same missing index
  (`stab_mem_tpOf_iff` is the stab letter of THAT cell, `box_mem_tpOf_iff` one global bit), so
  nothing here licenses weakening the realization statement to make a structure writable.
- The successor design is not chosen here.  If the gated candidate is refuted in turn, the
  direction on record is a different presentation of a cell -- a set-valued per-state datum over a
  quotient -- and not a wider tuple.

## Axioms

`cell_succ_ne`, `ladderIndex_not_factoring`, `exhibited_form_refuted`, `exists_form_refuted`,
`truth_phiP`, `bounded_ladder_finite`, `finBranch_eq_ofSlicedStep`,
`bounded_width_validates_Phi_neg`, `Phi_neg_not_valid`, `gate_parity_separates`,
`iterate_eventually_periodic`, `reachN_eventually_periodic`, `second_region_any_length`,
`second_region_sets_agree` and `third_region_any_length` depend on
`[propext, Classical.choice, Quot.sound]`; `gate_gap_separates`, `gap_le_region_age` and
`region_start_beyond_depth` on `[propext, Quot.sound]`.  No new axiom, no placeholder body and no
vacuous definition appears anywhere in this file.

Compile: `lake env lean specs/evidence/seam-gluing-ray-product/ladder-cell-index-obstructions.lean`
-/
import FormalSystem.Metalogic.Decidability.RaySummary.RunLayer
import FormalSystem.Metalogic.Decidability.RaySummary.AnchorLayer
import FormalSystem.Metalogic.Decidability.RaySummary.LadderModel
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Limits.NoFiniteWidth

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability.RaySummary
open FormalSystem.Metalogic.Decidability.PlusSlicedCertificate

namespace Probe773

/-! ## The four-state object: a pending pair alternating a tag, an idle pair carrying it -/

/-- Object states `(pending?, tag)`. -/
abbrev Qp : Type := Bool × Bool

def pendP : Qp → Bool := fun q => q.1

/-- While pending the tag flips on every pending step and is COPIED onto the idle state that
ends the region; an idle state only goes to an idle state with the same tag. -/
def stepP : Qp → Qp → Bool := fun x y =>
  if x.1 then (if y.1 then (y.2 != x.2) else (y.2 == x.2))
  else (!y.1 && (y.2 == x.2))

theorem rlad_iff (t : ℤ) (x y : Qp × ℕ × ℕ) :
    Rlad stepP pendP t x y ↔
      stepP x.1 y.1 = true ∧ (x.1.1 = false → x.2.1 = 0) ∧ Drift x.2.2 y.2.2 ∧
        Count x.1.1 y.1.1 x.2.1 x.2.2 y.2.1 := Iff.rfl

theorem count_tt (c n c' : ℕ) : Count true true c n c' ↔ c' + 1 = c := by simp [Count]
theorem count_tf (c n c' : ℕ) : Count true false c n c' ↔ c' = 0 ∧ c = 0 := by simp [Count]
theorem count_ff (c n c' : ℕ) : Count false false c n c' ↔ c' = 0 := by simp [Count]

theorem fwdP : ∀ t x, ∃ y, RladAdm stepP pendP t x y := by
  rintro t ⟨⟨⟨b, tg⟩, c, n⟩, hx⟩
  cases b with
  | false =>
    have hc : c = 0 := hx rfl
    subst hc
    exact ⟨⟨((false, tg), 0, n), fun _ => rfl⟩, by
      simp [RladAdm, rlad_iff, stepP, Drift, Count]⟩
  | true =>
    cases c with
    | zero =>
      exact ⟨⟨((false, tg), 0, n), fun _ => rfl⟩, by
        simp [RladAdm, rlad_iff, stepP, Drift, Count]⟩
    | succ c =>
      exact ⟨⟨((true, !tg), c, n), fun h => by cases h⟩, by
        simp [RladAdm, rlad_iff, stepP, Drift, Count]⟩

theorem bwdP : ∀ t x, ∃ y, RladAdm stepP pendP (t - 1) y x := by
  rintro t ⟨⟨⟨b, tg⟩, c, n⟩, hx⟩
  cases b with
  | false =>
    have hc : c = 0 := hx rfl
    subst hc
    exact ⟨⟨((false, tg), 0, n), fun _ => rfl⟩, by
      simp [RladAdm, rlad_iff, stepP, Drift, Count]⟩
  | true =>
    exact ⟨⟨((true, !tg), c + 1, n), fun h => by cases h⟩, by
      simp [RladAdm, rlad_iff, stepP, Drift, Count]⟩

def F : FrameOver intOrder := ladderFrameAdm stepP pendP fwdP bwdP

instance : F.IsRegular := ladderFrameAdm_isRegular stepP pendP fwdP bwdP

/-! ## The three letters: pending, idle, and the tag -/

def pA : Atom := ⟨"p", none⟩
def rA : Atom := ⟨"r", none⟩
def aA : Atom := ⟨"a", none⟩

theorem pA_ne_rA : pA ≠ rA := by simp [pA, rA]
theorem aA_ne_pA : aA ≠ pA := by simp [aA, pA]
theorem aA_ne_rA : aA ≠ rA := by simp [aA, rA]

def labP : Qp → Atom → Bool := fun q at_ =>
  if at_ = pA then q.1 else if at_ = rA then !q.1 else if at_ = aA then q.2 else false

def M : TaskModel F.toTaskFrame := ladderModel stepP pendP fwdP bwdP labP

def p : PlusFormula := .atom pA
def r : PlusFormula := .atom rA
def a : PlusFormula := .atom aA

/-- `p U (r AND a)`: "the region ends on a tagged idle state". -/
def phiP : PlusFormula := .untl p (r.and a)

/-! ## Histories of `F` are offset ladder paths -/

theorem hist_path (σ : WorldHistory F) :
    ∃ (k : ℤ) (g : ℤ → LadderState Qp pendP),
      IsSlicedStepPath (RladAdm stepP pendP) k g ∧ σ.path = fun t => (t + k, g t) :=
  (ofSlicedStepFinBranch_mem_HF_iff (RladAdm stepP pendP) (RladAdm_fwd _ _) (RladAdm_bwd _ _)
    fwdP bwdP σ.path).mp ⟨σ, rfl⟩

theorem hist_of_path (k : ℤ) (g : ℤ → LadderState Qp pendP)
    (hg : IsSlicedStepPath (RladAdm stepP pendP) k g) :
    ∃ σ : WorldHistory F, σ.path = fun t => (t + k, g t) :=
  (ofSlicedStepFinBranch_mem_HF_iff (RladAdm stepP pendP) (RladAdm_fwd _ _) (RladAdm_bwd _ _)
    fwdP bwdP _).mpr ⟨k, g, hg, rfl⟩

section Along
variable {σ : WorldHistory F} {k : ℤ} {g : ℤ → LadderState Qp pendP}
  (hσ : σ.path = fun t => (t + k, g t))
include hσ

theorem state_eq (s : ℤ) : σ.state s = (s + k, g s) := congrFun hσ s

theorem truth_p (s : ℤ) : PlusTruthAt M σ s p ↔ (g s).1.1.1 = true := by
  show M.valuation (σ.state s) pA ↔ _
  rw [state_eq hσ s]
  simp [M, ladderModel, labP]

theorem truth_r (s : ℤ) : PlusTruthAt M σ s r ↔ (g s).1.1.1 = false := by
  show M.valuation (σ.state s) rA ↔ _
  rw [state_eq hσ s]
  simp [M, ladderModel, labP, pA_ne_rA.symm]

theorem truth_a (s : ℤ) : PlusTruthAt M σ s a ↔ (g s).1.1.2 = true := by
  show M.valuation (σ.state s) aA ↔ _
  rw [state_eq hσ s]
  simp [M, ladderModel, labP, aA_ne_pA, aA_ne_rA]

end Along

/-! ## The tag as a function of distance -/

/-- The tag `i` pending steps after a state tagged `tg`. -/
def tagAt (tg : Bool) (i : ℤ) : Bool := if i % 2 = 0 then tg else !tg

theorem tagAt_succ (tg : Bool) (i : ℤ) : tagAt tg (i + 1) = !(tagAt tg i) := by
  unfold tagAt
  split_ifs with h1 h2 h2
  · omega
  · simp
  · rfl
  · omega

/-- **The decisive arithmetic**: the tag at distance `c` and at distance `c + 1` always differ,
so the parity of the countdown is never invisible. -/
theorem tagAt_ne_succ (tg : Bool) (i : ℤ) : tagAt tg i ≠ tagAt tg (i + 1) := by
  rw [tagAt_succ]
  cases tagAt tg i <;> simp

/-! ## The forced run: the region is deterministic in the object component -/

section Run
variable {g : ℤ → LadderState Qp pendP} (hg : ∀ t, Rlad stepP pendP t (g t).1 (g (t + 1)).1)
include hg

/-- **Forward determinism while pending**: the countdown runs down by exactly one per step and
the tag flips by exactly one per step, so at distance `i ≤ c` the state is pending with tag
`tagAt tg i` and countdown `c - i`.  No drift freedom touches either. -/
theorem pending_run (tg : Bool) (c n : ℕ) (h0 : (g 0).1 = ((true, tg), c, n)) :
    ∀ i : ℕ, i ≤ c →
      (g (i : ℤ)).1.1.1 = true ∧ (g (i : ℤ)).1.1.2 = tagAt tg (i : ℤ) ∧
        (g (i : ℤ)).1.2.1 = c - i := by
  intro i
  induction i with
  | zero =>
    intro _
    rw [Nat.cast_zero, h0]
    exact ⟨rfl, by simp [tagAt], by simp⟩
  | succ i ih =>
    intro hi
    obtain ⟨hq1, hq2, hc⟩ := ih (by omega)
    rw [show ((i + 1 : ℕ) : ℤ) = (i : ℤ) + 1 by push_cast; ring]
    obtain ⟨hs, -, -, hcount⟩ := (rlad_iff ((i : ℤ)) (g (i : ℤ)).1 (g ((i : ℤ) + 1)).1).mp
      (hg (i : ℤ))
    rw [hq1] at hcount
    cases hy : (g ((i : ℤ) + 1)).1.1.1 with
    | false =>
      rw [hy, count_tf] at hcount
      omega
    | true =>
      refine ⟨rfl, ?_, by rw [hy, count_tt] at hcount; omega⟩
      have hbne : (g ((i : ℤ) + 1)).1.1.2 ≠ (g (i : ℤ)).1.1.2 := by
        simpa [stepP, hq1, hy] using hs
      rw [hq2] at hbne
      rw [tagAt_succ]
      revert hbne
      cases (g ((i : ℤ) + 1)).1.1.2 <;> cases tagAt tg (i : ℤ) <;> simp

/-- **The region ends on an idle state carrying the tag of the last pending state**, at distance
exactly `c + 1`.  `Count true true` cannot fire at countdown `0`, so the successor is idle, and
`stepP` copies the tag. -/
theorem idle_at (tg : Bool) (c n : ℕ) (h0 : (g 0).1 = ((true, tg), c, n)) :
    (g ((c : ℤ) + 1)).1.1.1 = false ∧ (g ((c : ℤ) + 1)).1.1.2 = tagAt tg (c : ℤ) := by
  obtain ⟨hq1, hq2, hc⟩ := pending_run hg tg c n h0 c le_rfl
  obtain ⟨hs, -, -, hcount⟩ := (rlad_iff ((c : ℤ)) (g (c : ℤ)).1 (g ((c : ℤ) + 1)).1).mp
    (hg (c : ℤ))
  rw [hq1, hc, Nat.sub_self] at hcount
  cases hy : (g ((c : ℤ) + 1)).1.1.1 with
  | true =>
    rw [hy, count_tt] at hcount
    omega
  | false =>
    refine ⟨rfl, ?_⟩
    have hbeq : (g ((c : ℤ) + 1)).1.1.2 = (g (c : ℤ)).1.1.2 := by
      simpa [stepP, hq1, hy] using hs
    rw [hbeq, hq2]

end Run

/-! ## `phiP` reads exactly the parity of the countdown, at every pending state -/

section Truth
variable {σ : WorldHistory F} {k : ℤ} {g : ℤ → LadderState Qp pendP}
  (hσ : σ.path = fun t => (t + k, g t))
  (hg : ∀ t, Rlad stepP pendP t (g t).1 (g (t + 1)).1)
include hσ hg

/-- **The truth of `phiP` at a pending ladder state is a function of the state alone**, and that
function reads `c mod 2`: the until is forced to fire at the region end `c + 1`, where the tag is
`tagAt tg c`.  Neither the next-deadline `n` nor any drift choice appears. -/
theorem truth_phiP (tg : Bool) (c n : ℕ) (h0 : (g 0).1 = ((true, tg), c, n)) :
    PlusTruthAt M σ 0 phiP ↔ tagAt tg (c : ℤ) = true := by
  constructor
  · rintro ⟨(s : ℤ), hs, hχ, hguard⟩
    have hs' : (0 : ℤ) < s := hs
    rw [PlusTruth.and_iff, truth_r hσ, truth_a hσ] at hχ
    obtain ⟨hr, ha⟩ := hχ
    rcases lt_trichotomy s ((c : ℤ) + 1) with hlt | heq | hgt
    · have hlt' : s < (c : ℤ) + 1 := hlt
      have hsn : ((s.toNat : ℕ) : ℤ) = s := Int.toNat_of_nonneg (by omega)
      have hle : s.toNat ≤ c := by omega
      obtain ⟨hq1, -, -⟩ := pending_run hg tg c n h0 s.toNat hle
      rw [← hsn] at hr
      rw [hr] at hq1
      exact absurd hq1 (by simp)
    · subst heq
      obtain ⟨-, htg⟩ := idle_at hg tg c n h0
      rw [htg] at ha
      exact ha
    · have hgt' : (c : ℤ) + 1 < s := hgt
      have hp := hguard ((c : ℤ) + 1) (show (0 : ℤ) < (c : ℤ) + 1 by omega) hgt
      rw [truth_p hσ] at hp
      obtain ⟨hidle, -⟩ := idle_at hg tg c n h0
      rw [hidle] at hp
      exact absurd hp (by simp)
  · intro htag
    refine ⟨(c : ℤ) + 1, show (0 : ℤ) < (c : ℤ) + 1 by omega, ?_, ?_⟩
    · rw [PlusTruth.and_iff, truth_r hσ, truth_a hσ]
      obtain ⟨hidle, htg⟩ := idle_at hg tg c n h0
      exact ⟨hidle, by rw [htg]; exact htag⟩
    · intro (s' : ℤ) h1 h2
      have h1' : (0 : ℤ) < s' := h1
      have h2' : s' < (c : ℤ) + 1 := h2
      rw [truth_p hσ]
      have hsn : ((s'.toNat : ℕ) : ℤ) = s' := Int.toNat_of_nonneg (by omega)
      have hle : s'.toNat ≤ c := by omega
      obtain ⟨hq1, -, -⟩ := pending_run hg tg c n h0 s'.toNat hle
      rw [← hsn]
      exact hq1

end Truth

/-! ## A reference history through every pending ladder state -/

/-- The run that keeps `n` fixed (`Drift n n` always holds), counts the region down to `0`, and
is idle ever after; extended backwards by lengthening the countdown and flipping the tag. -/
def gRefRaw (tg : Bool) (c n : ℕ) (t : ℤ) : Qp × ℕ × ℕ :=
  if t ≤ (c : ℤ) then ((true, tagAt tg t), ((c : ℤ) - t).toNat, n)
  else ((false, tagAt tg (c : ℤ)), 0, n)

theorem gRefRaw_adm (tg : Bool) (c n : ℕ) (t : ℤ) :
    (gRefRaw tg c n t).2.1 ∈ Adm pendP (gRefRaw tg c n t).1 := by
  show (gRefRaw tg c n t).1.1 = false → (gRefRaw tg c n t).2.1 = 0
  unfold gRefRaw
  split_ifs <;> simp

def gRef (tg : Bool) (c n : ℕ) (t : ℤ) : LadderState Qp pendP :=
  ⟨gRefRaw tg c n t, gRefRaw_adm tg c n t⟩

theorem gRefRaw_step (tg : Bool) (c n : ℕ) (t : ℤ) :
    Rlad stepP pendP 0 (gRefRaw tg c n t) (gRefRaw tg c n (t + 1)) := by
  rw [rlad_iff]
  have hts : tagAt tg (t + 1) = !(tagAt tg t) := tagAt_succ tg t
  unfold gRefRaw
  rcases lt_trichotomy t (c : ℤ) with hlt | heq | hgt
  · have h1 : t ≤ (c : ℤ) := le_of_lt hlt
    have h2 : t + 1 ≤ (c : ℤ) := by omega
    rw [if_pos h1, if_pos h2, hts]
    refine ⟨?_, by simp, Or.inl rfl, ?_⟩
    · show stepP (true, tagAt tg t) (true, !(tagAt tg t)) = true
      cases tagAt tg t <;> simp [stepP]
    · show Count true true (((c : ℤ) - t).toNat) n (((c : ℤ) - (t + 1)).toNat)
      rw [count_tt]
      omega
  · have h1 : t ≤ (c : ℤ) := le_of_eq heq
    have h2 : ¬ (t + 1 ≤ (c : ℤ)) := by omega
    rw [if_pos h1, if_neg h2, heq]
    refine ⟨?_, by simp, Or.inl rfl, ?_⟩
    · show stepP (true, tagAt tg (c : ℤ)) (false, tagAt tg (c : ℤ)) = true
      cases tagAt tg (c : ℤ) <;> simp [stepP]
    · show Count true false (((c : ℤ) - (c : ℤ)).toNat) n 0
      rw [count_tf]
      omega
  · have h1 : ¬ (t ≤ (c : ℤ)) := by omega
    have h2 : ¬ (t + 1 ≤ (c : ℤ)) := by omega
    rw [if_neg h1, if_neg h2]
    refine ⟨?_, by simp, Or.inl rfl, ?_⟩
    · show stepP (false, tagAt tg (c : ℤ)) (false, tagAt tg (c : ℤ)) = true
      cases tagAt tg (c : ℤ) <;> simp [stepP]
    · show Count false false 0 n 0
      rw [count_ff]

theorem gRef_isPath (tg : Bool) (c n : ℕ) :
    IsSlicedStepPath (RladAdm stepP pendP) 0 (gRef tg c n) := by
  intro t
  show Rlad stepP pendP (t + 0) (gRefRaw tg c n t) (gRefRaw tg c n (t + 1))
  have h : Rlad stepP pendP (t + 0) (gRefRaw tg c n t) (gRefRaw tg c n (t + 1)) ↔
      Rlad stepP pendP 0 (gRefRaw tg c n t) (gRefRaw tg c n (t + 1)) := Iff.rfl
  rw [h]
  exact gRefRaw_step tg c n t

theorem gRef_zero (tg : Bool) (c n : ℕ) : (gRef tg c n 0).1 = ((true, tg), c, n) := by
  show gRefRaw tg c n 0 = ((true, tg), c, n)
  unfold gRefRaw
  rw [if_pos (by positivity : (0 : ℤ) ≤ (c : ℤ))]
  simp [tagAt]

/-! ## The cells at a pending state -/

/-- A pending admissible ladder state with countdown `c` and next-deadline `n`. -/
def st (tg : Bool) (c n : ℕ) : LadderState Qp pendP :=
  ⟨((true, tg), c, n), fun h => by cases h⟩

def wP (tg : Bool) (c n : ℕ) : F.WorldState := ((0 : ℤ), st tg c n)


def wRef (tg : Bool) (c n : ℕ) : F.WorldState := ((0 : ℤ), gRef tg c n 0)

theorem wRef_eq (tg : Bool) (c n : ℕ) : wRef tg c n = wP tg c n :=
  Prod.ext rfl (Subtype.ext (gRef_zero tg c n))

/-- **Every type realized at a pending state settles `phiP` the same way**, by the countdown's
tag: the cell does not merely contain a type with `phiP`, it is uniform in `phiP`. -/
theorem phiP_mem_iff_of_mem_cell (tg : Bool) (c n : ℕ) (T : Finset PlusFormula)
    (hT : T ∈ cellAt M phiP (wP tg c n) 0) : (phiP ∈ T ↔ tagAt tg (c : ℤ) = true) := by
  obtain ⟨σ, hσz, rfl⟩ := hT
  obtain ⟨k, g, hg, hpath⟩ := hist_path σ
  have hst : ((0 : ℤ) + k, g 0) = wP tg c n := by
    rw [← hσz]
    exact (congrFun hpath 0).symm
  have hg0 : (g 0).1 = ((true, tg), c, n) :=
    congrArg (fun w : ℤ × LadderState Qp pendP => w.2.1) hst
  rw [mem_tpOf_iff]
  constructor
  · intro h
    exact (truth_phiP hpath (fun t => hg t) tg c n hg0).mp h.2
  · intro h
    exact ⟨self_mem_plusSubformulaClosure phiP,
      (truth_phiP hpath (fun t => hg t) tg c n hg0).mpr h⟩

/-- The cell at a pending state is nonempty: `gRef` is a history through it. -/
theorem exists_mem_cell (tg : Bool) (c n : ℕ) : ∃ T, T ∈ cellAt M phiP (wP tg c n) 0 := by
  obtain ⟨σ, hσ⟩ := hist_of_path 0 (gRef tg c n) (gRef_isPath tg c n)
  refine ⟨tpOf M phiP σ 0, ⟨σ, ?_, rfl⟩⟩
  rw [← wRef_eq]
  exact congrFun hσ 0

/-- **THE OBSTRUCTION, at every counter value**: the cells at `(q, c, n)` and `(q, c + 1, n)`
differ for EVERY `c` and `n`, with the next-deadline `n` held FIXED (so the gap differs by one
but neither state is distinguished by it in any clipped range).  The separating datum is the
parity of `c`, read at the region end -- a distance `c + 1` away, which no bound on `c` can
reach.  Consequently no index whose countdown coordinate has finite range can be sound: it must
identify two countdowns of opposite parity at equal `n`. -/
theorem cell_succ_ne (tg : Bool) (c n : ℕ) :
    cellAt M phiP (wP tg c n) 0 ≠ cellAt M phiP (wP tg (c + 1) n) 0 := by
  intro heq
  obtain ⟨T, hT⟩ := exists_mem_cell tg c n
  have h1 := phiP_mem_iff_of_mem_cell tg c n T hT
  rw [heq] at hT
  have h2 := phiP_mem_iff_of_mem_cell tg (c + 1) n T hT
  have hiff : (tagAt tg (c : ℤ) = true) ↔ (tagAt tg ((c + 1 : ℕ) : ℤ) = true) := h1.symm.trans h2
  rw [show ((c + 1 : ℕ) : ℤ) = (c : ℤ) + 1 by push_cast; ring] at hiff
  have hne := tagAt_ne_succ tg (c : ℤ)
  revert hiff hne
  cases tagAt tg (c : ℤ) <;> cases tagAt tg ((c : ℤ) + 1) <;> simp

/-! ## The candidate index and its refutation -/

/-- **The dispatch's candidate index**: `(q, min c B, min n B, clip (n - c) [-B, B])`, with the
gap coordinate offset by `B` so that it lands in `Fin (2*B + 1)` (truncated `ℕ`-subtraction
implements the clip at `-B`; `min ... (2*B)` the clip at `+B`).  A `Fintype` by construction for
every finite object. -/
def ladderIndex (B : ℕ) {Q : Type} {pend : Q → Bool} (x : LadderState Q pend) :
    Q × Fin (B + 1) × Fin (B + 1) × Fin (2 * B + 1) :=
  (x.1.1, ⟨min x.1.2.1 B, by omega⟩, ⟨min x.1.2.2 B, by omega⟩,
    ⟨min ((x.1.2.2 + B) - x.1.2.1) (2 * B), by omega⟩)

/-- **The cheap falsification gate passes, for `2 ≤ B`.** On the known refutation's own pair --
counters `(B, B+1)` against `(B, B+2)`, where every counter is `≥ B` -- the gap coordinate gives
`B+1` against `B+2`, so the candidate is NOT killed by the existing refutation. -/
theorem gate_separates (B : ℕ) (hB : 2 ≤ B) :
    min ((B + 1 + B) - B) (2 * B) ≠ min ((B + 2 + B) - B) (2 * B) := by omega

/-- **...but only for `2 ≤ B`**: at `B ≤ 1` the clip range is narrower than the gaps being
separated and the candidate collides on that very pair.  The `φ`-derived bound must therefore
exceed the gaps `φ` can see, which is the parameter-origin rule restated as a LOWER bound on
`B`. -/
theorem gate_collides_below_two (B : ℕ) (hB : B ≤ 1) :
    min ((B + 1 + B) - B) (2 * B) = min ((B + 2 + B) - B) (2 * B) := by omega

def xRef (B : ℕ) : LadderState Qp pendP :=
  ⟨((true, false), 2 * B, 4 * B + 2), fun h => by cases h⟩

def yRef (B : ℕ) : LadderState Qp pendP :=
  ⟨((true, false), 2 * B + 1, 4 * B + 2), fun h => by cases h⟩

/-- The two states collide in the candidate index, at every `B`: the object components agree, the
two counters both saturate `min _ B`, and both gaps (`2B+2` and `2B+1`) saturate the clip at
`+B`. -/
theorem index_collide (B : ℕ) : ladderIndex B (xRef B) = ladderIndex B (yRef B) := by
  simp only [ladderIndex, xRef, yRef, Prod.mk.injEq, Fin.mk.injEq, true_and]
  omega

/-- **THE REFUTATION, uniform in `B`**: the gap-carrying three-coordinate index does not factor
`cellAt`, for any `B` whatsoever.  The witnessing pair carries EQUAL next-deadlines and gaps that
both saturate the clip, so the gap coordinate is not what fails -- the countdown coordinate is,
through the parity its clipping destroys. -/
theorem ladderIndex_not_factoring (B : ℕ) :
    ¬ ∀ x y : LadderState Qp pendP, ladderIndex B x = ladderIndex B y →
        cellAt M phiP ((0 : ℤ), x) 0 = cellAt M phiP ((0 : ℤ), y) 0 := by
  intro h
  exact cell_succ_ne false (2 * B) (4 * B + 2) (h (xRef B) (yRef B) (index_collide B))

/-- The exhibited-bound form, at `B = |cl phiP|`, is refuted. -/
theorem exhibited_form_refuted :
    ¬ ∀ x y : LadderState Qp pendP,
        ladderIndex (plusSubformulaClosure phiP).card x
          = ladderIndex (plusSubformulaClosure phiP).card y →
        cellAt M phiP ((0 : ℤ), x) 0 = cellAt M phiP ((0 : ℤ), y) 0 :=
  ladderIndex_not_factoring _

/-- The `∃ B` fallback form is refuted too: the witness is uniform in `B`. -/
theorem exists_form_refuted :
    ¬ ∃ B : ℕ, ∀ x y : LadderState Qp pendP, ladderIndex B x = ladderIndex B y →
        cellAt M phiP ((0 : ℤ), x) 0 = cellAt M phiP ((0 : ℤ), y) 0 := by
  rintro ⟨B, h⟩
  exact ladderIndex_not_factoring B h

/-! ## The re-scoped candidate index -/

/-- **The re-scoped candidate**: thresholds AND residues on both counters, beside the clipped
gap.  `T` and `P` are object-derived, `B` is formula-derived, and the three are independent.

The gap coordinate is offset by `B` so that it lands in `Fin (2*B + 1)`: truncated `ℕ`
subtraction implements the clip at `-B`, and `min _ (2*B)` the clip at `+B`.  A `Fintype` by
construction for every finite object. -/
def ladderIndexRes (T P B : ℕ) {Q : Type} {pend : Q → Bool} (x : LadderState Q pend) :
    Q × Fin (T + 1) × Fin (P + 1) × Fin (T + 1) × Fin (P + 1) × Fin (2 * B + 1) :=
  (x.1.1,
    ⟨min x.1.2.1 T, by omega⟩,
    ⟨x.1.2.1 % (P + 1), Nat.mod_lt _ (Nat.succ_pos P)⟩,
    ⟨min x.1.2.2 T, by omega⟩,
    ⟨x.1.2.2 % (P + 1), Nat.mod_lt _ (Nat.succ_pos P)⟩,
    ⟨min ((x.1.2.2 + B) - x.1.2.1) (2 * B), by omega⟩)

/-! ## Gate 1: the gap pair that killed the two-coordinate index -/

/-- **The first cheap gate passes, for `2 ≤ B`.**  On the pair that the two-coordinate
refutation turns on -- counters `(B, B+1)` against `(B, B+2)`, where both counters saturate every
threshold -- the gap coordinate gives `B+1` against `B+2`, which the clip keeps apart as soon as
`2 ≤ B`.  The lower bound on `B` is exactly the earlier gate's collision half read as a
constraint: the clip must exceed the gaps the FORMULA can see, so `B` is formula-derived and
never counter-derived. -/
theorem gate_gap_separates (T P B : ℕ) (hB : 2 ≤ B) :
    ladderIndexRes T P B (st false B (B + 1)) ≠ ladderIndexRes T P B (st false B (B + 2)) := by
  intro h
  have h6 := congrArg (fun z : Qp × Fin (T + 1) × Fin (P + 1) × Fin (T + 1) × Fin (P + 1) ×
      Fin (2 * B + 1) => z.2.2.2.2.2.val) h
  simp only [ladderIndexRes, st] at h6
  omega

/-! ## Gate 2: the parity pair that kills the three-coordinate index -/

/-- The arithmetic the parity gate turns on, at a SYMBOLIC modulus.  Two consecutive naturals
cannot be congruent modulo `P + 1` once `1 ≤ P`: the congruence gives `(P+1 : ℤ) ∣ 1`, hence
`P + 1 ≤ 1`.  This is outside `omega`'s fragment, which handles `%` only at a literal modulus,
and fixing the modulus at `2` to dodge it would weaken `gate_parity_separates`. -/
theorem consec_mod_ne (P B : ℕ) (hP : 1 ≤ P) :
    2 * B % (P + 1) ≠ (2 * B + 1) % (P + 1) := by
  intro h
  have hm : Nat.ModEq (P + 1) (2 * B) (2 * B + 1) := h
  have hd := Nat.ModEq.dvd hm
  have h1 : ((P : ℤ) + 1) ∣ 1 := by
    have he : ((2 * B + 1 : ℕ) : ℤ) - ((2 * B : ℕ) : ℤ) = 1 := by push_cast; ring
    push_cast at hd
    push_cast at he
    rw [he] at hd
    exact_mod_cast hd
  have := Int.le_of_dvd (by norm_num) h1
  omega

/-- **The second cheap gate passes, for `1 ≤ P`.**  On the pair that REFUTES the three-coordinate
candidate -- counters `(2B, 4B+2)` against `(2B+1, 4B+2)`, with EQUAL next-deadlines, both
countdowns saturating `min _ B` at the refuted index's threshold, and both gaps saturating the
clip at `+B` -- the separating coordinate is the countdown residue `c % (P+1)`.  The gap
coordinate cannot do it (both gaps clip to the top) and the threshold coordinate cannot do it
(both countdowns saturate); the residue coordinate is what the re-scope adds. -/
theorem gate_parity_separates (T P B : ℕ) (hP : 1 ≤ P) :
    ladderIndexRes T P B (st false (2 * B) (4 * B + 2))
      ≠ ladderIndexRes T P B (st false (2 * B + 1) (4 * B + 2)) := by
  intro h
  have h3 := congrArg (fun z : Qp × Fin (T + 1) × Fin (P + 1) × Fin (T + 1) × Fin (P + 1) ×
      Fin (2 * B + 1) => z.2.2.1.val) h
  simp only [ladderIndexRes, st] at h3
  exact consec_mod_ne P B hP h3

/-! ## The bounded-carrier alternative, closed by the finite-width limitation -/

/-- **(1) The deadline-bounded admissible ladder sub-carrier is finite**, exactly as the
bounded-carrier route claims: it injects into `Q × Fin (N+1) × Fin (N+1)`. -/
theorem bounded_ladder_finite {Q : Type} [Finite Q] (pend : Q → Bool) (N : ℕ) :
    Finite {x : LadderState Q pend // x.1.2.1 ≤ N ∧ x.1.2.2 ≤ N} := by
  refine Finite.of_injective
    (fun x => (x.1.1.1, (⟨x.1.1.2.1, Nat.lt_succ_of_le x.2.1⟩ : Fin (N + 1)),
      (⟨x.1.1.2.2, Nat.lt_succ_of_le x.2.2⟩ : Fin (N + 1)))) ?_
  intro a b hab
  simp only [Prod.mk.injEq, Fin.mk.injEq] at hab
  obtain ⟨h1, h2, h3⟩ := hab
  exact Subtype.ext (Subtype.ext (Prod.ext h1 (Prod.ext h2 h3)))

/-- **(2) On a finite carrier the run layer's parallel constructor is the landed one.**  The two
differ only in the proof discharging `Saturation`, and proof irrelevance is definitional, so the
frames are equal by `rfl` -- no transport is needed to apply a finite-width result to a
`ofSlicedStepFinBranch` frame. -/
theorem finBranch_eq_ofSlicedStep {W : Type} [Finite W] [Nonempty W] (R : ℤ → W → W → Prop)
    (hf : FwdFinBranch R) (hb : BwdFinBranch R)
    (fwd : ∀ t w, ∃ u, R t w u) (bwd : ∀ t w, ∃ v, R (t - 1) v w) :
    ofSlicedStepFinBranch R hf hb fwd bwd = FrameOver.ofSlicedStep R fwd bwd := rfl

/-- **(3) Every model on a FINITE-carrier `ofSlicedStepFinBranch` frame validates `Φ.neg`.**
`NoFiniteWidth.no_finite_width_sat` applies unchanged through (2).  Since `Φ.neg` is a ℤ-time
non-validity (`NoFiniteWidth.not_plusValidZTime_neg_Φ`), no such model refutes it: the
bounded-carrier route's premise fails at `φ = Φ.neg`. -/
theorem bounded_width_validates_Phi_neg {W : Type} [Finite W] [Nonempty W]
    (R : ℤ → W → W → Prop) (hf : FwdFinBranch R) (hb : BwdFinBranch R)
    (fwd : ∀ t w, ∃ u, R t w u) (bwd : ∀ t w, ∃ v, R (t - 1) v w)
    (M : TaskModel (ofSlicedStepFinBranch R hf hb fwd bwd).toTaskFrame)
    (τ : WorldHistory (ofSlicedStepFinBranch R hf hb fwd bwd)) (t : ℤ) :
    PlusTruthAt M τ t NoFiniteWidth.Φ.neg := by
  show PlusTruthAt M τ t NoFiniteWidth.Φ → PlusTruthAt M τ t PlusFormula.bot
  intro hΦ
  exact NoFiniteWidth.no_finite_width_sat R fwd bwd M τ t hΦ

/-- The non-validity that the bounded-carrier route therefore cannot reach, restated here so the
citation is machine-checked rather than quoted. -/
theorem Phi_neg_not_valid : ¬ PlusValidZTime NoFiniteWidth.Φ.neg :=
  NoFiniteWidth.not_plusValidZTime_neg_Φ

/-! ## The exhibited threshold and period -/

/-! ## The generic fact: iteration on a finite type is eventually periodic -/

/-- **Iteration of an endofunction of a finite type is eventually periodic**, with a threshold
`T` and a GENUINELY POSITIVE period `P`.  Pigeonhole on `n => f^[n] a` (infinite domain, finite
codomain) gives `i ≠ j` with equal iterates; `T` is the smaller and `P` their difference, and the
conclusion propagates by `Function.iterate_add_apply`.

The period is `1 ≤ P`, not `0 ≤ P`: at `P = 0` the conclusion would be a tautology. -/
theorem iterate_eventually_periodic {A : Type} [Finite A] (f : A → A) (a : A) :
    ∃ T P : ℕ, 1 ≤ P ∧ ∀ k, T ≤ k → f^[k + P] a = f^[k] a := by
  obtain ⟨i, j, hij, hfe⟩ := Finite.exists_ne_map_eq_of_infinite (fun n : ℕ => f^[n] a)
  rcases lt_or_gt_of_ne hij with hlt | hlt
  · refine ⟨i, j - i, by omega, ?_⟩
    intro k hk
    obtain ⟨m, rfl⟩ : ∃ m, k = i + m := ⟨k - i, by omega⟩
    have hkey : i + m + (j - i) = m + j := by omega
    rw [hkey, Function.iterate_add_apply, ← hfe, ← Function.iterate_add_apply]
    congr 1
    omega
  · refine ⟨j, i - j, by omega, ?_⟩
    intro k hk
    obtain ⟨m, rfl⟩ : ∃ m, k = j + m := ⟨k - j, by omega⟩
    have hkey : j + m + (i - j) = m + i := by omega
    rw [hkey, Function.iterate_add_apply, hfe, ← Function.iterate_add_apply]
    congr 1
    omega

/-! ## The reachability map, and the exhibited threshold and period -/

/-- One step of reachability under the object's step relation: the states reachable in one
`step` from somewhere in `S`. -/
def reachStep {Q : Type} [Fintype Q] [DecidableEq Q] (step : Q → Q → Bool)
    (S : Finset Q) : Finset Q :=
  S.biUnion (fun q => Finset.univ.filter (fun q' => step q q' = true))

/-- **The step-reachability set of a finite object is eventually periodic in the number of
steps.**  `Finset Q` is a `Fintype` whenever `Q` is one with decidable equality, so the generic
lemma applies at `A := Finset Q`.

This is what EXHIBITS the `T` and `P` the re-scoped index's residue coordinates are taken at: the
region-end observable is reachability in `c + 1` steps, and the pair above says `min c T` plus
`c % (P + 1)` determines it.  It does NOT say the six coordinates suffice. -/
theorem reachN_eventually_periodic {Q : Type} [Fintype Q] [DecidableEq Q]
    (step : Q → Q → Bool) (S : Finset Q) :
    ∃ T P : ℕ, 1 ≤ P ∧
      ∀ k, T ≤ k → (reachStep step)^[k + P] S = (reachStep step)^[k] S :=
  iterate_eventually_periodic (reachStep step) S

/-! ## The third gate: the second-region-end hunt, and its recorded outcome -/

theorem count_ft (c n c' : ℕ) : Count false true c n c' ↔ c' = n := by simp [Count]

/-- Object states `(pending?, tag)`, as in the refutation fixture `Qp` above. -/
abbrev Q2 : Type := Bool × Bool

def pend2 : Q2 → Bool := fun q => q.1

/-- The parity object extended MINIMALLY: the idle clause drops its `!y.1` conjunct, so an idle
state may step to a PENDING one carrying the tag.  Every other clause is unchanged, so every
region's end still carries the parity of that region's length -- including the second and the
third, which is what this file needs. -/
def step2 : Q2 → Q2 → Bool := fun x y =>
  if x.1 then (if y.1 then (y.2 != x.2) else (y.2 == x.2))
  else (y.2 == x.2)

theorem rlad2_iff (t : ℤ) (x y : Q2 × ℕ × ℕ) :
    Rlad step2 pend2 t x y ↔
      step2 x.1 y.1 = true ∧ (x.1.1 = false → x.2.1 = 0) ∧ Drift x.2.2 y.2.2 ∧
        Count x.1.1 y.1.1 x.2.1 x.2.2 y.2.1 := Iff.rfl

/-- A pending admissible ladder state. -/
def pnd (tg : Bool) (c n : ℕ) : LadderState Q2 pend2 :=
  ⟨((true, tg), c, n), fun h => by cases h⟩

/-- An idle admissible ladder state; `Adm` forces its countdown to `0`. -/
def idl (tg : Bool) (n : ℕ) : LadderState Q2 pend2 :=
  ⟨((false, tg), 0, n), fun _ => rfl⟩

/-- Reachability by admissible ladder steps.  `Rlad` ignores its time argument, so fixing it at
`0` loses nothing. -/
abbrev RladStar : LadderState Q2 pend2 → LadderState Q2 pend2 → Prop :=
  Relation.ReflTransGen (RladAdm step2 pend2 0)

/-- The tag `i` pending steps after a state tagged `tg`. -/
def tagN (tg : Bool) (i : ℕ) : Bool := if i % 2 = 0 then tg else !tg

theorem tagN_zero (tg : Bool) : tagN tg 0 = tg := by simp [tagN]
theorem tagN_one (tg : Bool) : tagN tg 1 = !tg := by simp [tagN]

theorem tagN_succ (tg : Bool) (i : ℕ) : tagN tg (i + 1) = tagN (!tg) i := by
  unfold tagN
  rcases Nat.even_or_odd i with h | h
  · have h1 : i % 2 = 0 := Nat.even_iff.mp h
    have h2 : (i + 1) % 2 = 1 := by omega
    simp [h1, h2]
  · have h1 : i % 2 = 1 := Nat.odd_iff.mp h
    have h2 : (i + 1) % 2 = 0 := by omega
    simp [h1, h2]

/-! ## Attempt (iii-a): the second region's end -/

/-- One pending step: the countdown falls by exactly one and the tag flips. -/
theorem step_pend_down (tg : Bool) (c n : ℕ) :
    RladAdm step2 pend2 0 (pnd tg (c + 1) n) (pnd (!tg) c n) := by
  show Rlad step2 pend2 0 _ _
  rw [rlad2_iff]
  refine ⟨?_, by simp [pnd], Or.inl rfl, ?_⟩
  · show step2 (true, tg) (true, !tg) = true
    cases tg <;> simp [step2]
  · show Count true true (c + 1) n c
    rw [count_tt]

/-- **The countdown runs down with `n` held fixed**, so the region's last pending state carries
the tag `tagN tg c`: the parity of the region's length is in the tag. -/
theorem run_down (tg : Bool) (c n : ℕ) : RladStar (pnd tg c n) (pnd (tagN tg c) 0 n) := by
  induction c generalizing tg with
  | zero => rw [tagN_zero]
  | succ c ih =>
    rw [tagN_succ]
    exact Relation.ReflTransGen.head (step_pend_down tg c n) (ih (!tg))

/-- **The region ends on an idle state carrying the tag.**  `Count true true` cannot fire at
countdown `0`, so the successor is idle, and `step2` copies the tag. -/
theorem step_region_end (tg : Bool) (n : ℕ) :
    RladAdm step2 pend2 0 (pnd tg 0 n) (idl tg n) := by
  show Rlad step2 pend2 0 _ _
  rw [rlad2_iff]
  refine ⟨?_, by simp [pnd], Or.inl rfl, ?_⟩
  · show step2 (true, tg) (false, tg) = true
    cases tg <;> simp [step2]
  · show Count true false 0 n 0
    rw [count_tf]
    exact ⟨rfl, rfl⟩

/-- **The idle interval drifts the next deadline freely**: `Count false false` pins the countdown
at `0` and places no constraint on the next deadline beyond `Drift`. -/
theorem step_idle_drift (tg : Bool) (n n' : ℕ) (h : Drift n n') :
    RladAdm step2 pend2 0 (idl tg n) (idl tg n') := by
  show Rlad step2 pend2 0 _ _
  rw [rlad2_iff]
  refine ⟨?_, fun _ => rfl, h, ?_⟩
  · show step2 (false, tg) (false, tg) = true
    cases tg <;> simp [step2]
  · show Count false false 0 n 0
    rw [count_ff]

/-- **Hence EVERY next-deadline value is reachable within the idle interval.**  Drift down to
`0`, then up to the target: the idle interval may be of any length, so no bound survives it.
This is the fact that dissolves the "achievable window" the prediction expected. -/
theorem idle_to_any (tg : Bool) (n m : ℕ) : RladStar (idl tg n) (idl tg m) := by
  have hdown : ∀ k, RladStar (idl tg k) (idl tg 0) := by
    intro k
    induction k with
    | zero => exact Relation.ReflTransGen.refl
    | succ k ih =>
      exact Relation.ReflTransGen.head
        (step_idle_drift tg (k + 1) k (Or.inr (Or.inr rfl))) ih
  have hup : ∀ k, RladStar (idl tg 0) (idl tg k) := by
    intro k
    induction k with
    | zero => exact Relation.ReflTransGen.refl
    | succ k ih =>
      exact ih.tail (step_idle_drift tg k (k + 1) (Or.inr (Or.inl rfl)))
  exact (hdown n).trans (hup m)

/-- **A region starts, handed the next deadline as its length.**  `Count false true` sets the new
countdown to the idle state's next deadline. -/
theorem step_region_start (tg : Bool) (m : ℕ) :
    RladAdm step2 pend2 0 (idl tg m) (pnd tg m m) := by
  show Rlad step2 pend2 0 _ _
  rw [rlad2_iff]
  refine ⟨?_, fun _ => rfl, Or.inl rfl, ?_⟩
  · show step2 (false, tg) (true, tg) = true
    cases tg <;> simp [step2]
  · show Count false true 0 m m
    rw [count_ft]

/-- **(iii-a), the measurement**: from EVERY pending state, a second region of EVERY length is
reachable.  The target state's countdown is `m` for an arbitrary `m`, with no dependence on the
source state's counters whatsoever -- the achievable second-region lengths are not an interval of
width `2c + 3` positioned by the residues, they are all of `ℕ`. -/
theorem second_region_any_length (tg : Bool) (c n m : ℕ) :
    RladStar (pnd tg c n) (pnd (tagN tg c) m m) :=
  ((run_down tg c n).tail (step_region_end (tagN tg c) n)).trans
    ((idle_to_any (tagN tg c) n m).tail (step_region_start (tagN tg c) m))

/-- **(iii-a), the consequence**: both parities of the second region's end tag are achievable
from every pending state.  `m = 0` keeps the tag, `m = 1` flips it. -/
theorem second_region_end_tag_achievable (tg : Bool) (c n : ℕ) (b : Bool) :
    ∃ m : ℕ, RladStar (pnd tg c n) (pnd (tagN tg c) m m) ∧ tagN (tagN tg c) m = b := by
  by_cases h : tagN tg c = b
  · exact ⟨0, second_region_any_length tg c n 0, by rw [tagN_zero]; exact h⟩
  · refine ⟨1, second_region_any_length tg c n 1, ?_⟩
    rw [tagN_one]
    revert h
    cases tagN tg c <;> cases b <;> simp

/-- **(iii-a), the verdict: NO REFUTATION.**  Any two pending states with the same object
component have the SAME achievable second-region-end tag set -- both sets are everything -- for
ANY values of either counter.  The second region's end separates nothing, and it does so
independently of `T`, `P` and `B`. -/
theorem second_region_sets_agree (tg : Bool) (c1 n1 c2 n2 : ℕ) (b : Bool) :
    (∃ m : ℕ, RladStar (pnd tg c1 n1) (pnd (tagN tg c1) m m) ∧ tagN (tagN tg c1) m = b) ∧
      (∃ m : ℕ, RladStar (pnd tg c2 n2) (pnd (tagN tg c2) m m) ∧ tagN (tagN tg c2) m = b) :=
  ⟨second_region_end_tag_achievable tg c1 n1 b, second_region_end_tag_achievable tg c2 n2 b⟩

/-! ## Attempt (iii-b): the past direction -/

/-- The gap `n - c`, over `ℤ` so that it is not truncated. -/
def gapZ {Q : Type} (x : Q × ℕ × ℕ) : ℤ := (x.2.2 : ℤ) - (x.2.1 : ℤ)

/-- **Along a forward pending chain the gap rises by at most two per step**: `Count true true`
forces `c' + 1 = c` while `Drift` moves `n` by at most one.  (This is pre-landed finding (A),
restated as the per-step bound the backward reading needs.) -/
theorem gap_step_le {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool)
    (x y : Q × ℕ × ℕ) (hx : pend x.1 = true) (hy : pend y.1 = true)
    (h : Rlad step pend 0 x y) : gapZ y ≤ gapZ x + 2 := by
  obtain ⟨-, -, hd, hc⟩ := h
  rw [hx, hy, count_tt] at hc
  simp only [Drift] at hd
  simp only [gapZ]
  omega

/-- **At a region start the gap is at most one**: `Count false true` hands the new countdown the
idle state's next deadline, and `Drift` moves that deadline by at most one. -/
theorem gap_region_start_le_one {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool)
    (x y : Q × ℕ × ℕ) (hx : pend x.1 = false) (hy : pend y.1 = true)
    (h : Rlad step pend 0 x y) : gapZ y ≤ 1 := by
  obtain ⟨-, -, hd, hc⟩ := h
  rw [hx, hy, count_ft] at hc
  simp only [Drift] at hd
  simp only [gapZ]
  omega

/-- **A state reached `j` steps after its region start has gap at most `2j - 1`.**  The two
per-step bounds above, chained: the region start contributes at most `1` and each further pending
step at most `2`. -/
theorem gap_le_region_age {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool)
    (x : ℕ → Q × ℕ × ℕ) (k : ℕ)
    (hstep : ∀ i, i < k → Rlad step pend 0 (x i) (x (i + 1)))
    (h0 : pend (x 0).1 = false)
    (hp : ∀ i, 1 ≤ i → i ≤ k → pend (x i).1 = true) :
    ∀ j, 1 ≤ j → j ≤ k → gapZ (x j) ≤ 2 * (j : ℤ) - 1 := by
  intro j
  induction j with
  | zero => intro h _; omega
  | succ j ih =>
    intro _ hjk
    rcases Nat.eq_zero_or_pos j with hj0 | hj0
    · subst hj0
      have h1 := gap_region_start_le_one step pend (x 0) (x 1) h0
        (hp 1 le_rfl hjk) (hstep 0 (by omega))
      push_cast
      omega
    · have hprev := ih hj0 (by omega)
      have hstp := gap_step_le step pend (x j) (x (j + 1))
        (hp j hj0 (by omega)) (hp (j + 1) (by omega) hjk) (hstep j (by omega))
      push_cast at hprev hstp ⊢
      omega

/-- **(iii-b), the verdict as a bound**: a state whose gap exceeds `2k - 1` has NO region start
within `k` backward steps.  So a formula whose past-depth is at most `k` cannot see the region
start of such a state, and two such states are not separated THERE. -/
theorem region_start_beyond_depth {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool)
    (x : ℕ → Q × ℕ × ℕ) (k : ℕ) (hk : 1 ≤ k)
    (hstep : ∀ i, i < k → Rlad step pend 0 (x i) (x (i + 1)))
    (h0 : pend (x 0).1 = false)
    (hp : ∀ i, 1 ≤ i → i ≤ k → pend (x i).1 = true)
    (hgap : 2 * (k : ℤ) - 1 < gapZ (x k)) : False :=
  absurd (gap_le_region_age step pend x k hstep h0 hp k hk le_rfl) (by omega)

/-- The pair the attempt turns on: countdown `1`, next deadlines `2B+1` and `2B+2`, so true gaps
`2B` and `2B+1` -- both above the clip and both saturating it, so the clipped gap coordinate
CANNOT separate them.  Both region starts are at least `B + 1` steps back by the bound above, so
no formula of past-depth at most `B` reaches either: the clip bound's `phi`-derivation must cover
`snce`-nesting depth as well as `X`-nesting depth. -/
theorem clipped_gap_collides (B : ℕ) (hB : 1 ≤ B) :
    min ((2 * B + 1 + B) - 1) (2 * B) = min ((2 * B + 2 + B) - 1) (2 * B) := by omega

/-! ## Attempt (iii-c): one region further -/

/-- **(iii-c), the verdict: SUBSUMED.**  (iii-a)'s reachability theorem is stated from an
ARBITRARY pending state, so iterating it is one application of transitivity: a third region of
every length is reachable through a second region of every length.  The achievable widths do not
compound because there is no interval to compound -- the same idle drift freedom applies at every
region boundary.  Stopped here, per the binding stop condition. -/
theorem third_region_any_length (tg : Bool) (c n m2 m3 : ℕ) :
    RladStar (pnd tg c n) (pnd (tagN (tagN tg c) m2) m3 m3) :=
  (second_region_any_length tg c n m2).trans
    (second_region_any_length (tagN tg c) m2 m2 m3)


end Probe773

/-! ## Axiom check -/

#print axioms Probe773.cell_succ_ne
#print axioms Probe773.ladderIndex_not_factoring
#print axioms Probe773.exhibited_form_refuted
#print axioms Probe773.exists_form_refuted
#print axioms Probe773.gate_gap_separates
#print axioms Probe773.gate_parity_separates
#print axioms Probe773.bounded_ladder_finite
#print axioms Probe773.finBranch_eq_ofSlicedStep
#print axioms Probe773.bounded_width_validates_Phi_neg
#print axioms Probe773.Phi_neg_not_valid
#print axioms Probe773.iterate_eventually_periodic
#print axioms Probe773.reachN_eventually_periodic
#print axioms Probe773.truth_phiP
#print axioms Probe773.second_region_any_length
#print axioms Probe773.second_region_sets_agree
#print axioms Probe773.gap_le_region_age
#print axioms Probe773.region_start_beyond_depth
#print axioms Probe773.third_region_any_length
#print axioms Probe773.gate_separates
#print axioms Probe773.gate_collides_below_two
