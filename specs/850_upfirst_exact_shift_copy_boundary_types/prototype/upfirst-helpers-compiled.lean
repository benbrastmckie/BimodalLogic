import FormalSystem.Metalogic.Decidability.RaySummary.LadderChain

/-! Standalone research prototype (not a wired probe), compiled with `lake env lean` against the
built library during research. Everything in this file is PROVED (no `sorry`): the iterated
splice index map with its characterization lemmas, the forward-slack transport across a raise,
the re-derived iterated duplication with the realized types exposed at EVERY position through
the index map, and its register-held wrapper. The intended wired names are the ones used here;
the plan's Challenge block can pin these signatures. NOTE: `lean-challenge-snapshot.sh --check`
walks `specs/**` and will report a false ambiguity for any pinned name declared here (the same
advisory exit 71 the predecessor hit); check drift by header diff in that case. -/

namespace Probe850

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Semantics
open FormalSystem.Metalogic.Decidability
open FormalSystem.Metalogic.Decidability.RaySummary

/-! ## The iterated splice index map -/

section IterIdx

/-- **The retraction of `d` splices of `[u, u + l)` on positions**: the identity below `u + l`,
the original's position `u + ((v - u) mod l)` inside the run of `d + 1` copies, and `v - d · l`
above the run. Defined by iterating `spliceIdx` so that the `d + 1`-fold duplication's types
are read through it by one application of the duplication type lemma per step. -/
def iterSpliceIdx (u : ℤ) (l : ℕ) : ℕ → ℤ → ℤ
  | 0, v => v
  | d + 1, v => iterSpliceIdx u l d (spliceIdx u l v)

@[simp] theorem iterSpliceIdx_zero (u : ℤ) (l : ℕ) (v : ℤ) : iterSpliceIdx u l 0 v = v := rfl

theorem iterSpliceIdx_succ (u : ℤ) (l : ℕ) (d : ℕ) (v : ℤ) :
    iterSpliceIdx u l (d + 1) v = iterSpliceIdx u l d (spliceIdx u l v) := rfl

/-- Below `u + l` the retraction is the identity. -/
theorem iterSpliceIdx_of_lt (u : ℤ) (l : ℕ) (d : ℕ) (v : ℤ) (h : v < u + (l : ℤ)) :
    iterSpliceIdx u l d v = v := by
  induction d with
  | zero => rfl
  | succ d ih => rw [iterSpliceIdx_succ, spliceIdx_of_lt u l v h, ih]

/-- Above the run the retraction is the displacement by `d · l`. -/
theorem iterSpliceIdx_of_ge (u : ℤ) (l : ℕ) (d : ℕ) (v : ℤ)
    (h : u + ((d + 1) * l : ℕ) ≤ v) : iterSpliceIdx u l d v = v - (d * l : ℕ) := by
  induction d generalizing v with
  | zero => simp
  | succ d ih =>
    have e : (((d + 1 + 1) * l : ℕ) : ℤ) = ((d + 1) * l : ℕ) + (l : ℤ) := by push_cast; ring
    rw [e] at h
    have hge : u + (l : ℤ) ≤ v := by
      have : (0 : ℤ) ≤ (((d + 1) * l : ℕ) : ℤ) := Int.natCast_nonneg _
      omega
    rw [iterSpliceIdx_succ, spliceIdx_of_ge u l v hge, ih (v - l) (by omega)]
    push_cast; ring

/-- Inside the run, position `j` of the `i`-th copy is position `j` of the original block. -/
theorem iterSpliceIdx_add_mul (u : ℤ) (l : ℕ) (d : ℕ) (i j : ℕ) (hi : i ≤ d) (hj : j < l) :
    iterSpliceIdx u l d (u + (i * l : ℕ) + (j : ℤ)) = u + (j : ℤ) := by
  induction d generalizing i with
  | zero =>
    have : i = 0 := by omega
    subst this; simp
  | succ d ih =>
    rcases Nat.eq_zero_or_pos i with h0 | hpos
    · subst h0
      rw [iterSpliceIdx_of_lt u l _ _ (by push_cast; omega)]
      simp
    · obtain ⟨i', rfl⟩ : ∃ i', i = i' + 1 := ⟨i - 1, by omega⟩
      have e : u + ((i' + 1) * l : ℕ) + (j : ℤ) = (u + (i' * l : ℕ) + (j : ℤ)) + (l : ℤ) := by
        push_cast; ring
      have hge : u + (l : ℤ) ≤ (u + (i' * l : ℕ) + (j : ℤ)) + (l : ℤ) := by
        have : (0 : ℤ) ≤ ((i' * l : ℕ) : ℤ) := Int.natCast_nonneg _
        omega
      rw [iterSpliceIdx_succ, e, spliceIdx_of_ge u l _ hge, add_sub_cancel_right]
      exact ih i' (by omega)

/-- **Every copy boundary inside the run retracts to `u`.** -/
theorem iterSpliceIdx_boundary (u : ℤ) (l : ℕ) (hl : 0 < l) (d i : ℕ) (hi : i ≤ d) :
    iterSpliceIdx u l d (u + (i * l : ℕ)) = u := by
  have := iterSpliceIdx_add_mul u l d i 0 hi hl
  simpa using this

/-- **The run's top boundary retracts to `u + l`.** -/
theorem iterSpliceIdx_top (u : ℤ) (l : ℕ) (d : ℕ) :
    iterSpliceIdx u l d (u + ((d + 1) * l : ℕ)) = u + (l : ℤ) := by
  rw [iterSpliceIdx_of_ge u l d _ le_rfl]; push_cast; ring

/-- Inside the run the retraction lands in the original block `[u, u + l)`. -/
theorem iterSpliceIdx_mem (u : ℤ) (l : ℕ) (d : ℕ) (v : ℤ) (hv : u ≤ v)
    (hv' : v < u + ((d + 1) * l : ℕ)) :
    u ≤ iterSpliceIdx u l d v ∧ iterSpliceIdx u l d v < u + (l : ℤ) := by
  induction d generalizing v with
  | zero =>
    refine ⟨hv, ?_⟩
    simpa using hv'
  | succ d ih =>
    rcases lt_or_ge v (u + (l : ℤ)) with h | h
    · rw [iterSpliceIdx_of_lt u l _ v h]; omega
    · rw [iterSpliceIdx_succ, spliceIdx_of_ge u l v h]
      apply ih (v - l) (by omega)
      have e : (((d + 1 + 1) * l : ℕ) : ℤ) = ((d + 1) * l : ℕ) + (l : ℤ) := by push_cast; ring
      rw [e] at hv'; omega

end IterIdx

/-! ## Forward slack transports across a raise, increased by exactly the raised amount -/

section Raise

variable {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}

/-- **Forward slack transports across a raise of `z`'s region by `d · l`**, increased by exactly
`d · l`: the raised path's region at `z` is longer by `d · l`, every position above it sits above
the run of copies, where the raised path is the original displaced by `d · l`, so the first
region start above `z`'s region is the original's displaced by `d · l` with the same countdown
(hence the same register at the idle position before it). The mirror of `hasForwardSlack_del`.
Only two exposure clauses of the raise are consumed: the countdown at `z` and the walk above the
run. -/
theorem hasForwardSlack_raise (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (z : ℤ) {u : ℤ} {l d : ℕ} (hul : u + (l : ℤ) ≤ z + (cntAt g z : ℤ))
    {L n : ℕ} (hslack : HasForwardSlack g z L n)
    (g' : ℤ → LadderState Q pend) (hg' : IsLadderPath step pend g')
    (hcz : cntAt g' z = cntAt g z + d * l)
    (habove : ∀ v : ℤ, u + ((d + 1) * l : ℕ) ≤ v →
      objAt g' v = objAt g (v - (d * l : ℕ)) ∧ cntAt g' v = cntAt g (v - (d * l : ℕ))) :
    HasForwardSlack g' z (L + d * l) n := by
  intro I hI hidle hnext
  have hczZ : (cntAt g' z : ℤ) = (cntAt g z : ℤ) + ((d * l : ℕ) : ℤ) := by rw [hcz]; push_cast; ring
  have e : (((d + 1) * l : ℕ) : ℤ) = ((d * l : ℕ) : ℤ) + (l : ℤ) := by push_cast; ring
  -- every position above `z`'s raised region sits above the run of copies
  have hab : ∀ i : ℕ, u + ((d + 1) * l : ℕ) ≤ z + (cntAt g' z : ℤ) + 1 + (i : ℤ) := fun i => by
    rw [hczZ, e]; omega
  have hpull : ∀ i : ℕ, objAt g' (z + (cntAt g' z : ℤ) + 1 + (i : ℤ))
      = objAt g (z + (cntAt g z : ℤ) + 1 + (i : ℤ)) := fun i => by
    rw [(habove _ (hab i)).1, hczZ]; congr 1; ring
  have hidle' : ∀ i : ℕ, i < I →
      pend (objAt g (z + (cntAt g z : ℤ) + 1 + (i : ℤ))) = false := fun i hi => by
    rw [← hpull i]; exact hidle i hi
  have hnext' : pend (objAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ))) = true := by
    rw [← hpull I]; exact hnext
  have hb := hslack I hI hidle' hnext'
  -- the register at the idle position before the first region start, on both paths
  have h0' := hidle' (I - 1) (by omega)
  have h0 := hidle (I - 1) (by omega)
  have hcast : ∀ C : ℤ, C + 1 + ((I - 1 : ℕ) : ℤ) = C + (I : ℤ) := by
    intro C; push_cast [Nat.cast_sub (by omega : 1 ≤ I)]; ring
  rw [hcast] at h0' h0
  have h1' : pend (objAt g (z + (cntAt g z : ℤ) + (I : ℤ) + 1)) = true := by
    rw [show z + (cntAt g z : ℤ) + (I : ℤ) + 1 = z + (cntAt g z : ℤ) + 1 + (I : ℤ) by ring]
    exact hnext'
  have h1 : pend (objAt g' (z + (cntAt g' z : ℤ) + (I : ℤ) + 1)) = true := by
    rw [show z + (cntAt g' z : ℤ) + (I : ℤ) + 1 = z + (cntAt g' z : ℤ) + 1 + (I : ℤ) by ring]
    exact hnext
  have hpin' := cntAt_eq_nxtAt_of_idle_pend g hg _ h0' h1'
  have hpin := cntAt_eq_nxtAt_of_idle_pend g' hg' _ h0 h1
  have hreg : nxtAt g' (z + (cntAt g' z : ℤ) + (I : ℤ))
      = nxtAt g (z + (cntAt g z : ℤ) + (I : ℤ)) := by
    rw [← hpin, ← hpin']
    have hab' : u + ((d + 1) * l : ℕ) ≤ z + (cntAt g' z : ℤ) + (I : ℤ) + 1 := by
      rw [hczZ, e]; omega
    rw [(habove _ hab').2, hczZ]; congr 1; ring
  rw [hreg, hczZ]
  have hLZ : ((L + d * l : ℕ) : ℤ) = (L : ℤ) + ((d * l : ℕ) : ℤ) := by push_cast; ring
  rw [hLZ]
  omega

end Raise

/-! ## The iterated duplication with the realized types exposed everywhere -/

section Iterate

variable {Q : Type} [Finite Q] [Nonempty Q] {step : Q → Q → Bool} {pend : Q → Bool}

/-- **THE ITERATED DUPLICATION, READ THROUGH THE INDEX MAP.** `d` duplications of a
type-respecting block `[u, u + l)` of a pending-forever region: the walk is the original read
through `iterSpliceIdx u l d` at EVERY position, every countdown before the block whose region
reaches it is raised by `d · l`, above the run the countdown is the original's `d · l` earlier,
and the realized stab-free type at every position is the original's at the retracted position —
in particular the original's type at `u` at every copy boundary `u + i · l` (`i ≤ d`) and its
type at `u + l` at the run's top `u + (d + 1) · l`. The landed
`exists_iterSpliced_ladderPath_of_pend_past` exposes types only below `u + l` and at `u + l`;
every one of its clauses is a reading of this one through the characterization lemmas of
`iterSpliceIdx`. -/
theorem exists_iterSpliced_ladderPath_idx_of_pend_past
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    {g : ℤ → LadderState Q pend} (hg : IsLadderPath step pend g) {u : ℤ} {l : ℕ}
    (hl : 0 < l) (hcl : l ≤ cntAt g u)
    (hpast : ∀ p : ℤ, p ≤ u → pend (objAt g p) = true)
    (hrep : objAt g u = objAt g (u + (l : ℤ)))
    (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t, g t))
    (hty : tpOf (ladderModel step pend fwd bwd lab) φ σ u
         = tpOf (ladderModel step pend fwd bwd lab) φ σ (u + (l : ℤ))) (d : ℕ) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      (∀ v : ℤ, objAt g' v = objAt g (iterSpliceIdx u l d v)) ∧
      (∀ v : ℤ, v ≤ u → u ≤ v + (cntAt g v : ℤ) → cntAt g' v = cntAt g v + d * l) ∧
      (∀ v : ℤ, u + ((d + 1) * l : ℕ) ≤ v → cntAt g' v = cntAt g (v - (d * l : ℕ))) ∧
      ∀ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame,
        (∀ t : ℤ, σ'.state t = (t, g' t)) →
        ∀ w : ℤ, tpOf (ladderModel step pend fwd bwd lab) φ σ' w
          = tpOf (ladderModel step pend fwd bwd lab) φ σ (iterSpliceIdx u l d w) := by
  classical
  haveI : Fintype Q := Fintype.ofFinite Q
  induction d with
  | zero =>
      refine ⟨g, hg, fun _ => rfl, fun v _ _ => by simp, fun v _ => by simp, fun σ' hσ' w => ?_⟩
      exact tpOf_stabFree_eq_of_objAt_eq fwd bwd lab φ (k := 0) (k' := 0) σ' σ
        (fun t => by rw [add_zero]; exact hσ' t) (fun t => by rw [add_zero]; exact hσ t)
        (fun _ => rfl) hno w
  | succ d ih =>
      obtain ⟨g₁, hg₁, hobj₁, hcnt₁, habove₁, hty₁⟩ := ih
      -- the original's object and type at the retraction of `u + l` are those at `u`
      have hidx_ul : objAt g (iterSpliceIdx u l d (u + (l : ℤ))) = objAt g u := by
        rcases d with _ | d
        · rw [iterSpliceIdx_zero]; exact hrep.symm
        · rw [show u + (l : ℤ) = u + ((1 * l : ℕ) : ℤ) by push_cast; ring,
            iterSpliceIdx_boundary u l hl (d + 1) 1 (by omega)]
      have hty_ul : tpOf (ladderModel step pend fwd bwd lab) φ σ (iterSpliceIdx u l d (u + (l : ℤ)))
          = tpOf (ladderModel step pend fwd bwd lab) φ σ u := by
        rcases d with _ | d
        · rw [iterSpliceIdx_zero]; exact hty.symm
        · rw [show u + (l : ℤ) = u + ((1 * l : ℕ) : ℤ) by push_cast; ring,
            iterSpliceIdx_boundary u l hl (d + 1) 1 (by omega)]
      have hpast₁ : ∀ p : ℤ, p ≤ u → pend (objAt g₁ p) = true := fun p hp => by
        rw [hobj₁ p, iterSpliceIdx_of_lt u l d p (by omega)]; exact hpast p hp
      have hrep₁ : objAt g₁ u = objAt g₁ (u + (l : ℤ)) := by
        rw [hobj₁ u, hobj₁ (u + (l : ℤ)), iterSpliceIdx_of_lt u l d u (by omega), hidx_ul]
      have hcu₁ : cntAt g₁ u = cntAt g u + d * l := hcnt₁ u le_rfl (by omega)
      have hcl₁ : l ≤ cntAt g₁ u := by rw [hcu₁]; omega
      obtain ⟨g₂, hg₂, hobj₂, hcnt₂⟩ :=
        exists_spliced_ladderPath_of_pend_past hg₁ hl hcl₁ hpast₁ hrep₁
      have hobj₂' : ∀ w : ℤ, objAt g₂ w = objAt g₁ (spliceIdx u l w) := fun w => by
        rw [hobj₂ w, spliceObj_eq_objAt_spliceIdx]
      refine ⟨g₂, hg₂, fun v => ?_, fun v hv hreg => ?_, fun v hv => ?_, fun σ₂ hσ₂ w => ?_⟩
      · rw [hobj₂' v, hobj₁, iterSpliceIdx_succ]
      · have hreg₁ : u ≤ v + (cntAt g₁ v : ℤ) := by rw [hcnt₁ v hv hreg]; push_cast; omega
        rw [hcnt₂ v, spliceCnt_add_of_mem_region hl v hv hreg₁, hcnt₁ v hv hreg]
        ring
      · have e : (((d + 1 + 1) * l : ℕ) : ℤ) = ((d + 1) * l : ℕ) + (l : ℤ) := by push_cast; ring
        rw [e] at hv
        have hge : u + (l : ℤ) ≤ v := by
          have : (0 : ℤ) ≤ (((d + 1) * l : ℕ) : ℤ) := Int.natCast_nonneg _
          omega
        rw [hcnt₂ v, spliceCnt_of_ge v hge, habove₁ (v - (l : ℤ)) (by omega)]
        congr 1; push_cast; ring
      · obtain ⟨σ₁, hσ₁⟩ := exists_hist_of_isLadderPath fwd bwd g₁ hg₁
        have hty₁' : tpOf (ladderModel step pend fwd bwd lab) φ σ₁ u
            = tpOf (ladderModel step pend fwd bwd lab) φ σ₁ (u + (l : ℤ)) := by
          rw [hty₁ σ₁ hσ₁ u, hty₁ σ₁ hσ₁ (u + (l : ℤ)), iterSpliceIdx_of_lt u l d u (by omega),
            hty_ul]
        have htr := tpOf_eq_spliceIdx_of_tpOf_eq step pend fwd bwd lab φ u l hl (k := 0) (k' := 0)
          σ₁ σ₂ (fun t => by rw [add_zero]; exact hσ₁ t) (fun t => by rw [add_zero]; exact hσ₂ t)
          hobj₂' hno hty₁' w
        rw [htr, hty₁ σ₁ hσ₁, iterSpliceIdx_succ]

end Iterate

/-! ## The register-held wrapper with the same exposure -/

section AssemblyIdx

variable {Q : Type} [Finite Q] [Nonempty Q] {step : Q → Q → Bool} {pend : Q → Bool}

/-- **THE REGISTER-HELD ITERATED DUPLICATION OF A GIVEN BLOCK, READ THROUGH THE INDEX MAP.**
The landed `exists_ladderPath_through_iterSpliced_nxt_of_pend_past` with the walk and the types
exposed at every position through `iterSpliceIdx u l d`, and the countdown above the run. The
proof is the landed one: the duplication supplies the walk and the countdown; the register is
rebuilt by the landed lift with `z` at the origin and `n₀ := nxtAt g z`, every pin of the
duplicated path sitting above the run where it is the original's pin displaced by `d · l`. -/
theorem exists_ladderPath_through_iterSpliced_nxt_idx_of_pend_past
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    {g : ℤ → LadderState Q pend} (hg : IsLadderPath step pend g) (z : ℤ) {u : ℤ} {l : ℕ}
    (hl : 0 < l) (hcl : l ≤ cntAt g u) (hzu : z ≤ u)
    (hul : u + (l : ℤ) ≤ z + (cntAt g z : ℤ))
    (hpast : ∀ p : ℤ, p ≤ u → pend (objAt g p) = true)
    (hrep : objAt g u = objAt g (u + (l : ℤ)))
    (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t, g t))
    (hty : tpOf (ladderModel step pend fwd bwd lab) φ σ u
         = tpOf (ladderModel step pend fwd bwd lab) φ σ (u + (l : ℤ))) (d : ℕ) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      (∀ v : ℤ, objAt g' v = objAt g (iterSpliceIdx u l d v)) ∧
      cntAt g' z = cntAt g z + d * l ∧
      nxtAt g' z = nxtAt g z ∧
      (∀ v : ℤ, u + ((d + 1) * l : ℕ) ≤ v → cntAt g' v = cntAt g (v - (d * l : ℕ))) ∧
      ∀ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame,
        (∀ t : ℤ, σ'.state t = (t, g' t)) →
        ∀ w : ℤ, tpOf (ladderModel step pend fwd bwd lab) φ σ' w
          = tpOf (ladderModel step pend fwd bwd lab) φ σ (iterSpliceIdx u l d w) := by
  classical
  haveI : Fintype Q := Fintype.ofFinite Q
  have hpu : pend (objAt g u) = true := hpast u le_rfl
  obtain ⟨g₁, hg₁, hobj₁, hcnt₁, habove₁, hty₁⟩ :=
    exists_iterSpliced_ladderPath_idx_of_pend_past step pend fwd bwd lab φ hno hg hl hcl hpast hrep
      σ hσ hty d
  have hcz : cntAt g₁ z = cntAt g z + d * l := hcnt₁ z hzu (by omega)
  -- every position of `g₁` below `u + (d + 1) l` is pending
  have hpend_all : ∀ v : ℤ, v < u + ((d + 1) * l : ℕ) → pend (objAt g₁ v) = true := fun v hv => by
    rw [hobj₁ v]
    rcases lt_or_ge v u with hvu | hvu
    · rw [iterSpliceIdx_of_lt u l d v (by omega)]; exact hpast v (le_of_lt hvu)
    · obtain ⟨h1, h2⟩ := iterSpliceIdx_mem u l d v hvu hv
      have := (cntAt_sub_of_pend g hg u hpu (iterSpliceIdx u l d v - u).toNat (by omega)).1
      rwa [show u + (((iterSpliceIdx u l d v - u).toNat : ℕ) : ℤ) = iterSpliceIdx u l d v by omega]
        at this
  -- the walk above the run is the original displaced by `d · l`
  have hobj_above : ∀ v : ℤ, u + ((d + 1) * l : ℕ) ≤ v → objAt g₁ v = objAt g (v - (d * l : ℕ)) :=
    fun v hv => by rw [hobj₁ v, iterSpliceIdx_of_ge u l d v hv]
  -- the register, rebuilt with `z` at the origin
  let w : ℤ → Q := fun v => objAt g₁ (v + z)
  let c : ℤ → ℕ := fun v => cntAt g₁ (v + z)
  have hg₂ : IsLadderPath step pend (fun v => g₁ (v + z)) := isLadderPath_shift hg₁ z
  have hw : ∀ v, step (w v) (w (v + 1)) = true := fun v => by
    have := objAt_step _ hg₂ v
    exact this
  have hidle : ∀ v, pend (w v) = false → c v = 0 := fun v h =>
    cntAt_eq_zero_of_idle _ hg₂ v h
  have hpp : ∀ v, pend (w v) = true → pend (w (v + 1)) = true → c (v + 1) + 1 = c v :=
    fun v h0 h1 => cntAt_succ_of_pend_pend _ hg₂ v h0 h1
  have hpi : ∀ v, pend (w v) = true → pend (w (v + 1)) = false → c v = 0 :=
    fun v h0 h1 => (cntAt_eq_zero_of_pend_idle _ hg₂ v h0 h1).1
  have hpins : ∀ s v, pend (w s) = false → pend (w (s + 1)) = true →
      pend (w v) = false → pend (w (v + 1)) = true →
      ((c (s + 1) : ℤ) - c (v + 1)).natAbs ≤ (s - v).natAbs :=
    fun s v hs0 hs1 hv0 hv1 => pinCompat_of_ladderPath _ hg₂ s v hs0 hs1 hv0 hv1
  have hn₀ : ∀ v, pend (w v) = false → pend (w (v + 1)) = true →
      ((c (v + 1) : ℤ) - nxtAt g z).natAbs ≤ v.natAbs := fun v h0 h1 => by
    have hge : u + ((d + 1) * l : ℕ) ≤ v + z := by
      by_contra hlt
      rw [not_le] at hlt
      exact Bool.false_ne_true (h0.symm.trans (hpend_all (v + z) hlt))
    have ho0 := hobj_above (v + z) hge
    have ho1 := hobj_above (v + z + 1) (by omega)
    have hc1 := habove₁ (v + z + 1) (by omega)
    have h0' : pend (objAt g (v + z - (d * l : ℕ))) = false := by
      have : pend (objAt g₁ (v + z)) = false := h0
      rwa [ho0] at this
    have h1' : pend (objAt g (v + z - (d * l : ℕ) + 1)) = true := by
      have : pend (objAt g₁ (v + 1 + z)) = true := h1
      rwa [show v + 1 + z = v + z + 1 by ring, ho1,
        show v + z + 1 - (d * l : ℕ) = v + z - (d * l : ℕ) + 1 by ring] at this
    have hpin := cntAt_eq_nxtAt_of_idle_pend g hg _ h0' h1'
    have hc : (c (v + 1) : ℤ) = nxtAt g (v + z - (d * l : ℕ)) := by
      change (cntAt g₁ (v + 1 + z) : ℤ) = _
      rw [show v + 1 + z = v + z + 1 by ring, hc1,
        show v + z + 1 - (d * l : ℕ) = v + z - (d * l : ℕ) + 1 by ring, hpin]
    rw [hc]
    have hlip := nxtAt_lipschitz_two_sided g hg (v + z - (d * l : ℕ)) z
    have hge' : u + ((d * l : ℕ) : ℤ) + (l : ℤ) ≤ v + z := by
      have e : (((d + 1) * l : ℕ) : ℤ) = ((d * l : ℕ) : ℤ) + (l : ℤ) := by push_cast; ring
      rw [e] at hge
      omega
    have hnn : (0 : ℤ) ≤ ((d * l : ℕ) : ℤ) := Int.natCast_nonneg _
    omega
  obtain ⟨g₃, hg₃, hobj₃, hcnt₃, hnxt₃⟩ :=
    exists_ladderPath_of_walk_nxt w c (nxtAt g z) hw hidle hpp hpi hpins hn₀
  -- translate back
  have hobj' : ∀ v : ℤ, objAt (fun v => g₃ (v - z)) v = objAt g₁ v := fun v => by
    change objAt g₃ (v - z) = _
    rw [hobj₃]
    change objAt g₁ (v - z + z) = _
    rw [sub_add_cancel]
  have hcnt' : ∀ v : ℤ, cntAt (fun v => g₃ (v - z)) v = cntAt g₁ v := fun v => by
    change cntAt g₃ (v - z) = _
    rw [hcnt₃]
    change cntAt g₁ (v - z + z) = _
    rw [sub_add_cancel]
  refine ⟨fun v => g₃ (v - z), ?_, fun v => ?_, ?_, ?_, fun v hv => ?_, fun σ' hσ' w => ?_⟩
  · intro v
    have := hg₃ (v - z)
    rwa [show v - z + 1 = v + 1 - z by ring] at this
  · rw [hobj' v, hobj₁ v]
  · rw [hcnt' z, hcz]
  · change nxtAt g₃ (z - z) = _
    rw [sub_self, hnxt₃]
  · rw [hcnt' v, habove₁ v hv]
  · obtain ⟨σ₁, hσ₁⟩ := exists_hist_of_isLadderPath fwd bwd g₁ hg₁
    have e1 : tpOf (ladderModel step pend fwd bwd lab) φ σ' w
        = tpOf (ladderModel step pend fwd bwd lab) φ σ₁ w :=
      tpOf_stabFree_eq_of_objAt_eq fwd bwd lab φ (k := 0) (k' := 0) σ' σ₁
        (fun t => by rw [add_zero]; exact hσ' t) (fun t => by rw [add_zero]; exact hσ₁ t)
        hobj' hno w
    rw [e1, hty₁ σ₁ hσ₁ w]

end AssemblyIdx

/-! ## The overshoot loop with its sampling window as the one room hypothesis -/

section DelNxtIterWin

variable {Q : Type} [Fintype Q] [Nonempty Q] {step : Q → Q → Bool} {pend : Q → Bool}

/-- **ONE STEP OF THE OVERSHOOT LOOP, with the sampling window as the room hypothesis.** The
landed `exists_deleted_ladderPath_step_of_pend_past` consumes `hwb : w₀ ≤ z + budget` and
`hroom : budget · (budget + 1) ≤ cntAt g z` only to derive that the window
`[w₀, w₀ + budget · l]` lies inside `z`'s region; here that window IS the hypothesis, so the
loop can sample from a start pushed out by a run of copies. Proof: the landed one. -/
theorem exists_deleted_ladderPath_step_win_of_pend_past
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    {g : ℤ → LadderState Q pend} (hg : IsLadderPath step pend g) (z : ℤ)
    (hpast : ∀ p : ℤ, p ≤ z → pend (objAt g p) = true)
    (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t, g t))
    (w₀ : ℤ) (hzw : z ≤ w₀) (l : ℕ) (hl : 0 < l)
    (hwin : w₀ + ((Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l : ℕ) : ℤ)
      ≤ z + (cntAt g z : ℤ))
    {L : ℕ} (hLb : Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l ≤ L)
    (hgap : nxtAt g z + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l ≤ cntAt g z)
    (hslack : HasForwardSlack g z L (nxtAt g z)) :
    ∃ (g' : ℤ → LadderState Q pend) (d : ℕ), IsLadderPath step pend g' ∧
      0 < d ∧ d ≤ Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card ∧
      (∀ v : ℤ, v ≤ w₀ → objAt g' v = objAt g v) ∧
      cntAt g' z + d * l = cntAt g z ∧
      nxtAt g' z = nxtAt g z ∧
      HasForwardSlack g' z (L - d * l) (nxtAt g z) ∧
      ∀ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame,
        (∀ t : ℤ, σ'.state t = (t, g' t)) →
        ∀ v : ℤ, v ≤ w₀ →
          tpOf (ladderModel step pend fwd bwd lab) φ σ' v
            = tpOf (ladderModel step pend fwd bwd lab) φ σ v := by
  classical
  have hz : pend (objAt g z) = true := hpast z le_rfl
  obtain ⟨a, d, hd, hdb, hwa, haw, hcl, hrep, hty⟩ :=
    exists_typeBlock_of_spacing step pend fwd bwd lab φ σ hg z hz w₀ l hzw hwin
  have hdl : 0 < d * l := Nat.mul_pos hd hl
  have hdlb : d * l ≤ Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l :=
    Nat.mul_le_mul_right l hdb
  have hdlL : d * l ≤ L := le_trans hdlb hLb
  have hza : z ≤ a := le_trans hzw hwa
  have hal : a + ((d * l : ℕ) : ℤ) ≤ z + (cntAt g z : ℤ) := le_trans haw hwin
  have hpast_a : ∀ p : ℤ, p ≤ a → pend (objAt g p) = true := fun p hp' => by
    rcases le_or_gt p z with hpz | hpz
    · exact hpast p hpz
    · have := (cntAt_sub_of_pend g hg z hz (p - z).toNat (by omega)).1
      rwa [show z + (((p - z).toNat : ℕ) : ℤ) = p by omega] at this
  have hfirst : ∀ I : ℕ, 0 < I →
      (∀ i : ℕ, i < I → pend (objAt g (z + (cntAt g z : ℤ) + 1 + (i : ℤ))) = false) →
      pend (objAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ))) = true →
      ((nxtAt g (z + (cntAt g z : ℤ) + (I : ℤ)) : ℤ) - nxtAt g z).natAbs
        ≤ ((cntAt g z : ℤ) + I - (d * l : ℕ)).natAbs := fun I hI hidle hnext => by
    have := hasForwardSlack_mono g z hslack hdlL I hI hidle hnext
    omega
  have hanch := anchor_clause_of_first_region_start g hg z hz (d * l) (nxtAt g z) hfirst a hza hal
  obtain ⟨g', hg', hobj', hcnt', hnxt'⟩ :=
    exists_deleted_ladderPath_of_pend_past_nxt hg hdl hcl hpast_a hrep z (nxtAt g z) hanch
  refine ⟨g', d, hg', hd, hdb, ?_, ?_, hnxt', ?_, ?_⟩
  · intro v hv
    rw [hobj' v, delObj_eq_of_le hrep v (by omega)]
  · rw [hcnt' z, delCnt_sub_of_mem_region hg hdl hcl z hza (by omega)]
    omega
  · exact hasForwardSlack_del g hg z hdl hcl hza hal hslack hdlL g' hg' hobj' hcnt'
  · intro σ' hσ' v hv
    have hσ0 : ∀ t : ℤ, σ.state t = (t + 0, g t) := fun t => by rw [add_zero]; exact hσ t
    have hσ'0 : ∀ t : ℤ, σ'.state t = (t + 0, g' t) := fun t => by rw [add_zero]; exact hσ' t
    have hdel := tpOf_eq_delIdx_of_tpOf_eq step pend fwd bwd lab φ a (d * l) hdl (k := 0)
      (k' := 0) σ σ' hσ0 hσ'0 (fun w => (hobj' w).trans rfl) hno hty v
    rw [hdel]
    rcases lt_or_eq_of_le (show v ≤ a by omega) with hlt | heq
    · rw [delIdx_of_lt a (d * l) v hlt]
    · rw [heq, delIdx_of_ge a (d * l) a le_rfl, ← hty]

/-- **THE OVERSHOOT LOOP, with the sampling window as the room hypothesis**: the window must
hold `R + budget` blocks of length `l` inside `z`'s region. Proof: the landed one. -/
theorem exists_deleted_ladderPath_overshoot_win_of_pend_past
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    {g : ℤ → LadderState Q pend} (hg : IsLadderPath step pend g) (z : ℤ)
    (hpast : ∀ p : ℤ, p ≤ z → pend (objAt g p) = true)
    (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t, g t))
    (w₀ : ℤ) (hzw : z ≤ w₀) (l : ℕ) (hl : 0 < l)
    (hlb : l ≤ Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card) (R : ℕ)
    (hwin : w₀ + ((R * l + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l : ℕ) : ℤ)
      ≤ z + (cntAt g z : ℤ))
    (hgap : nxtAt g z + R * l + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l
      ≤ cntAt g z)
    (hslack : HasForwardSlack g z
      (R * l + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l) (nxtAt g z)) :
    ∃ (g' : ℤ → LadderState Q pend) (t : ℕ), IsLadderPath step pend g' ∧
      R ≤ t ∧ t < R + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card ∧
      (∀ v : ℤ, v ≤ w₀ → objAt g' v = objAt g v) ∧
      cntAt g' z + t * l = cntAt g z ∧
      nxtAt g' z = nxtAt g z ∧
      HasForwardSlack g' z
        (R * l + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l - t * l) (nxtAt g z) ∧
      ∀ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame,
        (∀ t : ℤ, σ'.state t = (t, g' t)) →
        ∀ v : ℤ, v ≤ w₀ →
          tpOf (ladderModel step pend fwd bwd lab) φ σ' v
            = tpOf (ladderModel step pend fwd bwd lab) φ σ v := by
  classical
  induction R using Nat.strong_induction_on generalizing g σ with
  | _ R ih =>
  rcases Nat.eq_zero_or_pos R with hR0 | hRpos
  · subst hR0
    refine ⟨g, 0, hg, le_rfl, by omega, fun _ _ => rfl, by simp, rfl, by simpa using hslack,
      fun σ' hσ' v _ => ?_⟩
    exact tpOf_stabFree_eq_of_objAt_eq fwd bwd lab φ (k := 0) (k' := 0) σ' σ
      (fun t => by rw [add_zero]; exact hσ' t) (fun t => by rw [add_zero]; exact hσ t)
      (fun _ => rfl) hno v
  · have hwin₀ : w₀ + ((Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l : ℕ) : ℤ)
        ≤ z + (cntAt g z : ℤ) := by
      have hc : ((Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l : ℕ) : ℤ)
          ≤ ((R * l + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l : ℕ) : ℤ) := by
        exact_mod_cast Nat.le_add_left _ _
      omega
    obtain ⟨g₁, d, hg₁, hd, hdb, hagree₁, hcnt₁, hnxt₁, hslack₁, hty₁⟩ :=
      exists_deleted_ladderPath_step_win_of_pend_past step pend fwd bwd lab φ hno hg z hpast σ hσ
        w₀ hzw l hl hwin₀ (Nat.le_add_left _ _) (by omega) hslack
    rcases le_or_gt R d with hRd | hdR
    · exact ⟨g₁, d, hg₁, hRd, by omega, hagree₁, hcnt₁, hnxt₁, hslack₁, hty₁⟩
    · have e : (R - d) * l + d * l = R * l := by
        rw [← Nat.add_mul, Nat.sub_add_cancel (le_of_lt hdR)]
      obtain ⟨σ₁, hσ₁⟩ := exists_hist_of_isLadderPath fwd bwd g₁ hg₁
      have hpast₁ : ∀ p : ℤ, p ≤ z → pend (objAt g₁ p) = true := fun p hp => by
        rw [hagree₁ p (by omega)]; exact hpast p hp
      have hwin₁ : w₀ + (((R - d) * l + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l
          : ℕ) : ℤ) ≤ z + (cntAt g₁ z : ℤ) := by
        have hc : ((R * l + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l : ℕ) : ℤ)
            = (((R - d) * l + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l : ℕ) : ℤ)
              + ((d * l : ℕ) : ℤ) := by
          rw [← e]; push_cast; ring
        have hc1 : (cntAt g₁ z : ℤ) + ((d * l : ℕ) : ℤ) = (cntAt g z : ℤ) := by
          exact_mod_cast hcnt₁
        omega
      have hgap₁ : nxtAt g₁ z + (R - d) * l +
          Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l ≤ cntAt g₁ z := by
        rw [hnxt₁]; omega
      have hslack₁' : HasForwardSlack g₁ z
          ((R - d) * l + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l)
          (nxtAt g₁ z) := by
        rw [hnxt₁]
        have hamt : R * l + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l - d * l
            = (R - d) * l + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l := by omega
        rw [hamt] at hslack₁
        exact hslack₁
      obtain ⟨g₂, t', hg₂, hRt', ht'R, hagree₂, hcnt₂, hnxt₂, hslack₂, hty₂⟩ :=
        ih (R - d) (by omega) hg₁ hpast₁ σ₁ hσ₁ hwin₁ hgap₁ hslack₁'
      refine ⟨g₂, d + t', hg₂, by omega, by omega,
        fun v hv => (hagree₂ v hv).trans (hagree₁ v hv), ?_, hnxt₂.trans hnxt₁, ?_,
        fun σ' hσ' v hv => (hty₂ σ' hσ' v hv).trans (hty₁ σ₁ hσ₁ v hv)⟩
      · rw [Nat.add_mul]; omega
      · rw [hnxt₁] at hslack₂
        have hamt : R * l + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l
            - (d + t') * l
            = (R - d) * l + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l - t' * l := by
          rw [Nat.add_mul]; omega
        rw [hamt]
        exact hslack₂

end DelNxtIterWin

/-! ## The exact-shift theorem, up-first: raise by `budget` copies, overshoot above the run,
delete the exact remainder inside the run -/

section ExactUpFirst

variable {Q : Type} [Fintype Q] [Nonempty Q] {step : Q → Q → Bool} {pend : Q → Bool}

/-- **THE EXACT-SHIFT THEOREM, UP-FIRST.** Under the gap `nxtAt g z + m · (P + 1) ≤ cntAt g z`
and the regime at EXACTLY the amount `m · (P + 1)`: the countdown lowered by exactly
`m · (P + 1)`, the object state, the register and the realized stab-free type at `z` held. The
ordering: (i) the original pigeonhole block `[u, u + l)`, `l ∣ P + 1`, target `R := m · q` blocks;
(ii) RAISE by `b := budget` copies of it with the register held, which adds exactly `b · l` of
slack (`hasForwardSlack_raise`) and exposes `(objAt, tpOf)` at every copy boundary `u + i · l`,
`i ≤ b`; (iii) the overshoot loop ABOVE the run, sampling from `u + (b + 1) · l`, deletes `t · l`
with `R ≤ t < R + b` and leaves the run untouched; (iv) the remainder `r := R + b − t ∈ [1, b]`
is deleted EXACTLY as the single block `[u, u + r · l)` of the run, whose ends carry the
original's `(objAt, tpOf)` at `u`. No `budget²` term: the raise pays for the overshoot before it
happens. -/
theorem exists_ladderPath_through_deleted_exact_upfirst_of_pend_past
    {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (z : ℤ)
    (hpast : ∀ p : ℤ, p ≤ z → pend (objAt g p) = true) (m : ℕ)
    (hTc : Tc + m * (P + 1) ≤ cntAt g z)
    (hgap : nxtAt g z + m * (P + 1) ≤ cntAt g z)
    (hslack : HasForwardSlack g z (m * (P + 1)) (nxtAt g z)) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      objAt g' z = objAt g z ∧ cntAt g' z + m * (P + 1) = cntAt g z ∧
      nxtAt g' z = nxtAt g z ∧
      ∀ (σ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
        (∀ t : ℤ, σ.state t = (t, g t)) →
        (∀ t : ℤ, σ'.state t = (t, g' t)) →
        tpOf (ladderModel step pend fwd bwd lab) φ σ' z
          = tpOf (ladderModel step pend fwd bwd lab) φ σ z := by
  classical
  have hz : pend (objAt g z) = true := hpast z le_rfl
  have hbud := budget_le_Tc step pend lab φ Tc Tn P B hp
  have hb2 := budget_mul_succ_le_Tc step pend lab φ Tc Tn P B hp
  -- a history of the original, and the type-respecting block of `z`'s region
  obtain ⟨σ₀, hσ₀⟩ := exists_hist_of_isLadderPath fwd bwd g hg
  have hσ₀' : ∀ t : ℤ, σ₀.state t = (t + 0, g t) := fun t => by rw [add_zero]; exact hσ₀ t
  obtain ⟨u, l, hl, hlb, hzu, hcl, hul, hrep, hty⟩ :=
    exists_typeBlock_of_budget_le_cnt_within step pend fwd bwd lab φ σ₀ hg z hz (by omega)
  have hpast_u : ∀ p : ℤ, p ≤ u → pend (objAt g p) = true := fun p hp' => by
    rcases le_or_gt p z with hpz | hpz
    · exact hpast p hpz
    · have := (cntAt_sub_of_pend g hg z hz (p - z).toNat (by omega)).1
      rwa [show z + (((p - z).toNat : ℕ) : ℤ) = p by omega] at this
  have hpu : pend (objAt g u) = true := hpast_u u le_rfl
  obtain ⟨q, hq⟩ := typeBlock_length_dvd_of_paramsOk step pend fwd bwd lab φ hp σ₀ hσ₀' hg hno
    u l hl hlb hpu hcl hrep hty
  have hRl : (m * q) * l = m * (P + 1) := by rw [hq]; ring
  have hul' : u + (l : ℤ) ≤ z + (cntAt g z : ℤ) := by omega
  -- the budget products
  have hbl : Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l
      ≤ Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card *
        (Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card) :=
    Nat.mul_le_mul_left _ hlb
  have hbb : Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card *
      (Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card + 1)
      = Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card *
        (Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card) +
        Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card := Nat.mul_succ _ _
  have hb1l : (Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card + 1) * l
      = Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l + l := Nat.succ_mul _ _
  -- (ii) the raise by `b` copies, the register held
  obtain ⟨g₁, hg₁, hobj₁, hcz₁, hnxt₁, habove₁, hty₁⟩ :=
    exists_ladderPath_through_iterSpliced_nxt_idx_of_pend_past step pend fwd bwd lab φ hno hg z
      hl hcl hzu hul' hpast_u hrep σ₀ hσ₀ hty (Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card)
  have hobj_above₁ : ∀ v : ℤ,
      u + ((Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card + 1) * l : ℕ) ≤ v →
      objAt g₁ v = objAt g (v - (Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l : ℕ)) ∧
      cntAt g₁ v = cntAt g (v - (Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l : ℕ)) :=
    fun v hv => ⟨by rw [hobj₁ v, iterSpliceIdx_of_ge u l _ v hv], habove₁ v hv⟩
  have hslack₁ : HasForwardSlack g₁ z
      ((m * q) * l + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l) (nxtAt g z) := by
    rw [hRl]
    exact hasForwardSlack_raise g hg z hul' hslack g₁ hg₁ hcz₁ hobj_above₁
  -- (iii) the overshoot loop above the run
  obtain ⟨σ₁, hσ₁⟩ := exists_hist_of_isLadderPath fwd bwd g₁ hg₁
  have hpast₁ : ∀ p : ℤ, p ≤ z → pend (objAt g₁ p) = true := fun p hp => by
    rw [hobj₁ p, iterSpliceIdx_of_lt u l _ p (by omega)]; exact hpast p hp
  have hwin : u + ((Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card + 1) * l : ℕ)
      + (((m * q) * l + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l : ℕ) : ℤ)
      ≤ z + (cntAt g₁ z : ℤ) := by
    rw [hcz₁, hb1l]
    generalize hbq : Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card = b
      at hul hbl hbb hb2 hbud ⊢
    omega
  obtain ⟨g₂, t, hg₂, hRt, htR, hagree₂, hcnt₂, hnxt₂, hslack₂, hty₂⟩ :=
    exists_deleted_ladderPath_overshoot_win_of_pend_past step pend fwd bwd lab φ hno hg₁ z hpast₁
      σ₁ hσ₁ (u + ((Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card + 1) * l : ℕ))
      (by omega) l hl hlb (m * q) hwin (by rw [hnxt₁, hcz₁]; omega)
      (by rw [hnxt₁]; exact hslack₁)
  -- (iv) the exact remainder `r`, deleted as one block of the run
  obtain ⟨r, hr⟩ : ∃ r : ℕ, r + t = m * q + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card :=
    ⟨m * q + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card - t, by omega⟩
  have hr1 : 1 ≤ r := by omega
  have hrb : r ≤ Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card := by omega
  have hrl : 0 < r * l := Nat.mul_pos hr1 hl
  have ert : r * l + t * l = (m * q) * l + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l := by
    rw [← Nat.add_mul, hr, Nat.add_mul]
  have hcz₂ : cntAt g₂ z + (m * q) * l = cntAt g z + r * l := by omega
  have hrw₀ : u + ((r * l : ℕ) : ℤ)
      ≤ u + ((Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card + 1) * l : ℕ) := by
    have : r * l ≤ (Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card + 1) * l :=
      Nat.mul_le_mul_right l (by omega)
    omega
  have hrep₂ : objAt g₂ u = objAt g₂ (u + ((r * l : ℕ) : ℤ)) := by
    rw [hagree₂ u (by omega), hagree₂ _ hrw₀, hobj₁, hobj₁, iterSpliceIdx_of_lt u l _ u (by omega),
      iterSpliceIdx_boundary u l hl _ r hrb]
  have hpast₂ : ∀ p : ℤ, p ≤ u → pend (objAt g₂ p) = true := fun p hp' => by
    rw [hagree₂ p (by omega), hobj₁ p, iterSpliceIdx_of_lt u l _ p (by omega)]
    exact hpast_u p hp'
  have hz₂ : pend (objAt g₂ z) = true := hpast₂ z hzu
  -- the run block lies inside `z`'s (still long enough) region
  have huzb : u - z ≤ ((Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card : ℕ) : ℤ) := by
    omega
  have hc₂big : Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card + r * l ≤ cntAt g₂ z := by
    omega
  have hcl₂ : r * l ≤ cntAt g₂ u := by
    have h2 : (u - z).toNat ≤ Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card := by omega
    have h1 := (cntAt_sub_of_pend g₂ hg₂ z hz₂ (u - z).toNat (by omega)).2
    rw [show z + (((u - z).toNat : ℕ) : ℤ) = u by omega] at h1
    omega
  have hal₂ : u + ((r * l : ℕ) : ℤ) ≤ z + (cntAt g₂ z : ℤ) := by omega
  -- the regime at exactly the remainder, and the anchor clause
  have hamt : (m * q) * l + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l - t * l
      = r * l := by omega
  rw [hamt, hnxt₁] at hslack₂
  have hfirst : ∀ I : ℕ, 0 < I →
      (∀ i : ℕ, i < I → pend (objAt g₂ (z + (cntAt g₂ z : ℤ) + 1 + (i : ℤ))) = false) →
      pend (objAt g₂ (z + (cntAt g₂ z : ℤ) + 1 + (I : ℤ))) = true →
      ((nxtAt g₂ (z + (cntAt g₂ z : ℤ) + (I : ℤ)) : ℤ) - nxtAt g z).natAbs
        ≤ ((cntAt g₂ z : ℤ) + I - (r * l : ℕ)).natAbs := fun I hI hidle hnext => by
    have := hslack₂ I hI hidle hnext
    omega
  have hanch := anchor_clause_of_first_region_start g₂ hg₂ z hz₂ (r * l) (nxtAt g z) hfirst u hzu
    hal₂
  obtain ⟨g₃, hg₃, hobj₃, hcnt₃, hnxt₃⟩ :=
    exists_deleted_ladderPath_of_pend_past_nxt hg₂ hrl hcl₂ hpast₂ hrep₂ z (nxtAt g z) hanch
  refine ⟨g₃, hg₃, ?_, ?_, hnxt₃, fun σ σ' hσ hσ' => ?_⟩
  · rw [hobj₃ z, delObj_eq_of_le hrep₂ z hzu, hagree₂ z (by omega), hobj₁ z,
      iterSpliceIdx_of_lt u l _ z (by omega)]
  · rw [hcnt₃ z, delCnt_sub_of_mem_region hg₂ hrl hcl₂ z hzu (by omega)]
    omega
  · -- the type at `z`: through `σ₂` (the deletion), `σ₁` (the loop), `σ₀` (the raise), `σ`
    obtain ⟨σ₂, hσ₂⟩ := exists_hist_of_isLadderPath fwd bwd g₂ hg₂
    have hσ₂0 : ∀ t : ℤ, σ₂.state t = (t + 0, g₂ t) := fun t => by rw [add_zero]; exact hσ₂ t
    have hσ'0 : ∀ t : ℤ, σ'.state t = (t + 0, g₃ t) := fun t => by rw [add_zero]; exact hσ' t
    have hty₂' : tpOf (ladderModel step pend fwd bwd lab) φ σ₂ u
        = tpOf (ladderModel step pend fwd bwd lab) φ σ₂ (u + ((r * l : ℕ) : ℤ)) := by
      rw [hty₂ σ₂ hσ₂ u (by omega), hty₂ σ₂ hσ₂ _ hrw₀, hty₁ σ₁ hσ₁, hty₁ σ₁ hσ₁,
        iterSpliceIdx_of_lt u l _ u (by omega), iterSpliceIdx_boundary u l hl _ r hrb]
    have hdel := tpOf_eq_delIdx_of_tpOf_eq step pend fwd bwd lab φ u (r * l) hrl (k := 0)
      (k' := 0) σ₂ σ' hσ₂0 hσ'0 (fun w => (hobj₃ w).trans rfl) hno hty₂' z
    have hz₂' : tpOf (ladderModel step pend fwd bwd lab) φ σ' z
        = tpOf (ladderModel step pend fwd bwd lab) φ σ₂ z := by
      rw [hdel]
      rcases lt_or_eq_of_le hzu with hlt | heq
      · rw [delIdx_of_lt u (r * l) z hlt]
      · rw [heq, delIdx_of_ge u (r * l) u le_rfl, ← hty₂']
    have e3 : tpOf (ladderModel step pend fwd bwd lab) φ σ₀ z
        = tpOf (ladderModel step pend fwd bwd lab) φ σ z :=
      tpOf_stabFree_eq_of_objAt_eq fwd bwd lab φ (k := 0) (k' := 0) σ₀ σ
        hσ₀' (fun t => by rw [add_zero]; exact hσ t) (fun _ => rfl) hno z
    rw [hz₂', hty₂ σ₂ hσ₂ z (by omega), hty₁ σ₁ hσ₁, iterSpliceIdx_of_lt u l _ z (by omega), e3]

/-- **THE DOWNWARD CELL INCLUSION ON THE WITNESSING PATH, under the regime at exactly
`m · (P + 1)`**: the landed `mem_cellAt_of_shift_of_hasForwardSlack` with the `budget²` gap
hypothesis dropped and the regime amount reduced to `m · (P + 1)`; the hypotheses are exactly
`n + 2 ≤ c`, `Tc ≤ c` and `HasForwardSlack g z (m · (P + 1)) n`. -/
theorem mem_cellAt_of_shift_of_hasForwardSlack_exact
    {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (q : Q) (c n : ℕ) (h : c ∈ Adm pend q) (m : ℕ) (h' : c + m * (P + 1) ∈ Adm pend q)
    (hgap : n + 2 ≤ c) (hTc : Tc ≤ c) (z : ℤ)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (hgz : g z = ⟨(q, c + m * (P + 1), n), h'⟩)
    (hslack : HasForwardSlack g z (m * (P + 1)) n)
    (τ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hτ : ∀ t : ℤ, τ.state t = (t, g t)) :
    tpOf (ladderModel step pend fwd bwd lab) φ τ z ∈
      cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z := by
  classical
  have hoz : objAt g z = q := by simp [objAt, hgz]
  have hcz : cntAt g z = c + m * (P + 1) := by simp [cntAt, hgz]
  have hnz : nxtAt g z = n := by simp [nxtAt, hgz]
  have hz : pend (objAt g z) = true := by
    by_contra hne
    rw [Bool.not_eq_true, hoz] at hne
    have := h hne
    omega
  have hpast := pend_past_of_nxtAt_lt g hg z hz (by rw [hcz, hnz]; omega)
  obtain ⟨g', hg', ho, hc, hn, hty⟩ :=
    exists_ladderPath_through_deleted_exact_upfirst_of_pend_past step pend fwd bwd lab φ Tc Tn P B
      hp hno g hg z hpast m (by rw [hcz]; omega) (by rw [hcz, hnz]; omega)
      (by rw [hnz]; exact hslack)
  have hc' : cntAt g' z = c := by omega
  obtain ⟨τ', hτ'⟩ := exists_hist_of_isLadderPath fwd bwd g' hg'
  rw [mem_cellAt_ladder_iff]
  refine ⟨g', τ', hg', ?_, hτ', ?_⟩
  · apply Subtype.ext
    change (objAt g' z, cntAt g' z, nxtAt g' z) = (q, c, n)
    rw [ho, hc', hn, hoz, hnz]
  · exact hty τ τ' hτ hτ'

end ExactUpFirst

/-! ## The landed statements, re-derived as corollaries (statements copied verbatim) -/

section Corollaries

/-- The landed exact-shift theorem (statement verbatim) as a corollary of the up-first one:
monotonicity of the regime and arithmetic on the gap. -/
theorem exists_ladderPath_through_deleted_exact_of_pend_past
    {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (z : ℤ)
    (hpast : ∀ p : ℤ, p ≤ z → pend (objAt g p) = true) (m : ℕ)
    (hTc : Tc + m * (P + 1) ≤ cntAt g z)
    (hgap : nxtAt g z + m * (P + 1) +
      Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card *
        (Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card) ≤ cntAt g z)
    (hslack : HasForwardSlack g z
      (m * (P + 1) + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card *
        (Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card)) (nxtAt g z)) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      objAt g' z = objAt g z ∧ cntAt g' z + m * (P + 1) = cntAt g z ∧
      nxtAt g' z = nxtAt g z ∧
      ∀ (σ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
        (∀ t : ℤ, σ.state t = (t, g t)) →
        (∀ t : ℤ, σ'.state t = (t, g' t)) →
        tpOf (ladderModel step pend fwd bwd lab) φ σ' z
          = tpOf (ladderModel step pend fwd bwd lab) φ σ z :=
  exists_ladderPath_through_deleted_exact_upfirst_of_pend_past step pend fwd bwd lab φ Tc Tn P B
    hp hno g hg z hpast m hTc (by omega) (hasForwardSlack_mono g z hslack (Nat.le_add_right _ _))

-- `linter.unusedVariables`: the landed statement is pinned verbatim; `hslk` is implied by
-- `hgap` once the regime amount is `m · (P + 1)` and is not read.
set_option linter.unusedVariables false in
/-- The landed cell inclusion (statement verbatim) as a corollary of the exact one. -/
theorem mem_cellAt_of_shift_of_hasForwardSlack
    {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (q : Q) (c n : ℕ) (h : c ∈ Adm pend q) (m : ℕ) (h' : c + m * (P + 1) ∈ Adm pend q)
    (hgap : n + 2 ≤ c)
    (hslk : n + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card *
      (Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card) ≤ c)
    (hTc : Tc ≤ c) (z : ℤ)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (hgz : g z = ⟨(q, c + m * (P + 1), n), h'⟩)
    (hslack : HasForwardSlack g z
      (m * (P + 1) + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card *
        (Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card)) n)
    (τ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hτ : ∀ t : ℤ, τ.state t = (t, g t)) :
    tpOf (ladderModel step pend fwd bwd lab) φ τ z ∈
      cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z :=
  mem_cellAt_of_shift_of_hasForwardSlack_exact step pend fwd bwd lab φ Tc Tn P B hp hno q c n h m
    h' hgap hTc z g hg hgz (hasForwardSlack_mono g z hslack (Nat.le_add_right _ _)) τ hτ

end Corollaries

end Probe850
