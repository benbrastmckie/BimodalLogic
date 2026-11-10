import FormalSystem.Semantics.OrientedForest
import FormalSystem.ForMathlib.Combinatorics.SimpleGraphAcyclic

/-!
PROBE (task 894 research): the cone-unravelling carrier `W ⊕ (W × List W)` with the
promiscuous-entry relation `coneR`, checking
  (1) `IsOrientedForest (coneRin E)` on the inr layer,
  (2) double seriality of `coneR` on the FULL sum carrier (no coherence subtype),
  (3) the projection homomorphism and the four transport identities the two-layer
      Saturation split rests on.
-/

namespace Probe894

open FormalSystem.Semantics

variable {W : Type}

/-- The inr-layer one-step relation: prepend the current base state to the record. -/
def coneRin (E : W → W → Prop) : (W × List W) → (W × List W) → Prop :=
  fun p q => E p.1 q.1 ∧ q.2 = p.1 :: p.2

/-- The cone relation.  Note the ENTRY edge is promiscuous in the recorded list. -/
def coneR (E : W → W → Prop) : (W ⊕ (W × List W)) → (W ⊕ (W × List W)) → Prop
  | .inl u, .inl v => E u v
  | .inl u, .inr q => E u q.1
  | .inr p, .inr q => coneRin E p q
  | .inr _, .inl _ => False

/-- The projection onto the base carrier. -/
def coneF : (W ⊕ (W × List W)) → W
  | .inl u => u
  | .inr p => p.1

/-! ## (1) the inr layer is an oriented forest -/

def parIn : (W × List W) → (W × List W)
  | (v, []) => (v, [])
  | (_, a :: t) => (a, t)

theorem coneRin_loopFree (E : W → W → Prop) (p : W × List W) : ¬ coneRin E p p := by
  rintro ⟨-, h⟩
  exact absurd (congrArg List.length h) (by simp)

theorem coneRin_oppFree (E : W → W → Prop) (p q : W × List W)
    (h : coneRin E p q) : ¬ coneRin E q p := by
  rintro ⟨-, h2⟩
  have h1 := congrArg List.length h.2
  have h2 := congrArg List.length h2
  simp at h1 h2
  omega

theorem coneRin_acyclic (E : W → W → Prop) :
    (SimpleGraph.fromRel (coneRin E)).IsAcyclic := by
  refine SimpleGraph.isAcyclic_of_rank_parent (fun p => p.2.length) parIn ?_ ?_
  · rintro ⟨v, l⟩
    cases l with
    | nil => simp [parIn]
    | cons a t => simp [parIn]
  · intro u v huv
    rw [SimpleGraph.fromRel_adj] at huv
    obtain ⟨-, hst⟩ := huv
    rcases hst with hst | hst
    · left
      obtain ⟨-, hl⟩ := hst
      obtain ⟨vu, lu⟩ := u
      obtain ⟨vv, lv⟩ := v
      simp_all [parIn]
    · right
      obtain ⟨-, hl⟩ := hst
      obtain ⟨vu, lu⟩ := u
      obtain ⟨vv, lv⟩ := v
      simp_all [parIn]

theorem coneRin_isOrientedForest (E : W → W → Prop) : IsOrientedForest (coneRin E) where
  loopFree := coneRin_loopFree E
  oppFree := coneRin_oppFree E
  acyclic := coneRin_acyclic E

/-! ## (2) double seriality on the full sum carrier -/

theorem coneR_serial_fwd {E : W → W → Prop} (hfwd : ∀ w, ∃ u, E w u) :
    ∀ z : W ⊕ (W × List W), ∃ z', coneR E z z' := by
  rintro (u | ⟨v, l⟩)
  · obtain ⟨u', h⟩ := hfwd u
    exact ⟨.inl u', h⟩
  · obtain ⟨v', h⟩ := hfwd v
    exact ⟨.inr (v', v :: l), h, rfl⟩

theorem coneR_serial_bwd {E : W → W → Prop} (hbwd : ∀ w, ∃ v, E v w) :
    ∀ z : W ⊕ (W × List W), ∃ z', coneR E z' z := by
  rintro (u | ⟨v, l⟩)
  · obtain ⟨u', h⟩ := hbwd u
    exact ⟨.inl u', h⟩
  · obtain ⟨v', h⟩ := hbwd v
    exact ⟨.inl v', h⟩

/-! ## (3) the projection homomorphism and the transport identities -/

theorem coneF_step {E : W → W → Prop} {z z' : W ⊕ (W × List W)} (h : coneR E z z') :
    E (coneF z) (coneF z') := by
  match z, z', h with
  | .inl _, .inl _, h => exact h
  | .inl _, .inr _, h => exact h
  | .inr _, .inr _, h => exact h.1

theorem coneF_iter {E : W → W → Prop} :
    ∀ (n : ℕ) (z z' : W ⊕ (W × List W)), iter (coneR E) n z z' → iter E n (coneF z) (coneF z') := by
  intro n
  induction n with
  | zero => intro z z' h; rw [iter_zero] at h; subst h; rfl
  | succ n ih =>
    intro z z' h
    obtain ⟨v, hv, hstep⟩ := h
    exact ⟨coneF v, ih z v hv, coneF_step hstep⟩

/-- Nothing enters the inl layer. -/
theorem iter_inl_target {E : W → W → Prop} :
    ∀ (n : ℕ) (z : W ⊕ (W × List W)) (b : W), iter (coneR E) n z (.inl b) → ∃ a, z = .inl a := by
  intro n
  induction n with
  | zero => intro z b h; rw [iter_zero] at h; exact ⟨b, h⟩
  | succ n ih =>
    intro z b h
    obtain ⟨v, hv, hstep⟩ := h
    match v, hstep with
    | .inl c, _ => exact ih z c hv
    | .inr _, hstep => exact absurd hstep (by simp [coneR])

/-- The inl layer is a verbatim copy of the base. -/
theorem iter_inl_inl {E : W → W → Prop} :
    ∀ (n : ℕ) (a b : W), iter (coneR E) n (.inl a) (.inl b) ↔ iter E n a b := by
  intro n
  induction n with
  | zero => intro a b; simp [iter_zero, Sum.inl.injEq]
  | succ n ih =>
    intro a b
    constructor
    · intro h
      obtain ⟨v, hv, hstep⟩ := h
      match v, hstep with
      | .inl c, hstep => exact ⟨c, (ih a c).mp hv, hstep⟩
      | .inr _, hstep => exact absurd hstep (by simp [coneR])
    · rintro ⟨c, hc, hstep⟩
      exact ⟨.inl c, (ih a c).mpr hc, hstep⟩

/-- Forward from the inr layer stays in the inr layer, and is the inr-layer iterate. -/
theorem iter_inr_fwd {E : W → W → Prop} :
    ∀ (n : ℕ) (p : W × List W) (z : W ⊕ (W × List W)),
      iter (coneR E) n (.inr p) z ↔ ∃ q, z = .inr q ∧ iter (coneRin E) n p q := by
  intro n
  induction n with
  | zero =>
    intro p z
    constructor
    · intro h; rw [iter_zero] at h; exact ⟨p, h.symm, rfl⟩
    · rintro ⟨q, rfl, hq⟩; rw [iter_zero] at hq; rw [iter_zero, hq]
  | succ n ih =>
    intro p z
    constructor
    · intro h
      obtain ⟨v, hv, hstep⟩ := h
      obtain ⟨q', rfl, hq'⟩ := (ih p v).mp hv
      match z, hstep with
      | .inr q, hstep => exact ⟨q, rfl, q', hq', hstep⟩
      | .inl _, hstep => exact absurd hstep (by simp [coneR])
    · rintro ⟨q, rfl, q', hq', hstep⟩
      exact ⟨.inr q', (ih p (.inr q')).mpr ⟨q', rfl, hq'⟩, hstep⟩

/-- **The promiscuous-entry collapse**: at a positive duration the inl-preimage of a backward
fibre at an inr node is the base backward fibre at its base state.  This is the identity that
makes the inl-anchored half of the Saturation split go through. -/
theorem iter_inl_inr {E : W → W → Prop} (n : ℕ) (w : W) (q : W × List W) :
    iter (coneR E) (n + 1) (.inl w) (.inr q) ↔ iter E (n + 1) w q.1 := by
  constructor
  · intro h; simpa [coneF] using coneF_iter (n + 1) (.inl w) (.inr q) h
  · rintro ⟨c, hc, hstep⟩
    exact ⟨.inl c, (iter_inl_inl n w c).mpr hc, hstep⟩

/-- **Backward determinism of the inr layer**: the recorded list forces the predecessor. -/
theorem coneRin_bwd_unique {E : W → W → Prop} :
    ∀ (n : ℕ) (p p' q : W × List W),
      iter (coneRin E) n p q → iter (coneRin E) n p' q → p = p' := by
  intro n
  induction n with
  | zero => intro p p' q h h'; rw [iter_zero] at h h'; exact h.trans h'.symm
  | succ n ih =>
    intro p p' q h h'
    obtain ⟨v, hv, hs⟩ := h
    obtain ⟨v', hv', hs'⟩ := h'
    have hvv : v = v' := by
      obtain ⟨-, h2⟩ := hs
      obtain ⟨-, h2'⟩ := hs'
      have : v.1 :: v.2 = v'.1 :: v'.2 := by rw [← h2, ← h2']
      exact Prod.ext (by simpa using congrArg List.head? this)
        (by simpa using congrArg List.tail this)
    exact ih p p' v hv (hvv ▸ hv')

/-- A nonempty backward fibre of the inr layer is a singleton: the consequence the
segment-⊆-inr-layer case of the split consumes. -/
theorem coneRin_bwd_subsingleton {E : W → W → Prop} (n : ℕ) (q : W × List W) :
    {p | iter (coneRin E) n p q}.Subsingleton :=
  fun _ hp _ hp' => coneRin_bwd_unique n _ _ q hp hp'

end Probe894

namespace Probe894b

open FormalSystem.Semantics

variable {W : Type}

open Probe894

/-! ## (4) the Fib-level transport bridge used by the two-layer split -/

/-- Case A, inl anchor: the inl-preimage of an inl-anchored fibre is the base fibre. -/
theorem inl_preimage_fib_inl {E : W → W → Prop} (a : W) (x : ℤ) :
    Sum.inl ⁻¹' (TaskFrame.Fib (ofStepRel (coneR E)) (.inl a) x)
      = TaskFrame.Fib (ofStepRel E) a x := by
  ext b
  rcases le_or_gt 0 x with hx | hx
  · simp only [Set.mem_preimage, TaskFrame.mem_Fib, ofStepRel_of_nonneg hx]
    exact iter_inl_inl _ a b
  · have hx' : x ≤ 0 := le_of_lt hx
    simp only [Set.mem_preimage, TaskFrame.mem_Fib, ofStepRel_of_nonpos hx']
    exact iter_inl_inl _ b a

/-- Case A, inr anchor at a NEGATIVE duration: the inl-preimage of a backward fibre at an inr
node is the base backward fibre at its base state.  The promiscuous entry edge is what makes
this an equality rather than a union over entry points. -/
theorem inl_preimage_fib_inr_neg {E : W → W → Prop} (q : W × List W) {x : ℤ} (hx : x < 0) :
    Sum.inl ⁻¹' (TaskFrame.Fib (ofStepRel (coneR E)) (.inr q) x)
      = TaskFrame.Fib (ofStepRel E) q.1 x := by
  ext w
  obtain ⟨n, hn⟩ : ∃ n : ℕ, x.natAbs = n + 1 := ⟨x.natAbs - 1, by omega⟩
  simp only [Set.mem_preimage, TaskFrame.mem_Fib, ofStepRel_of_nonpos (le_of_lt hx), hn]
  exact iter_inl_inr n w q

/-- Case B: a forward fibre at an inr node lies in the inr layer, and its inr-preimage is the
corresponding fibre of the inr-layer relation. -/
theorem fib_inr_pos_subset {E : W → W → Prop} (p : W × List W) {x : ℤ} (hx : 0 ≤ x) :
    TaskFrame.Fib (ofStepRel (coneR E)) (.inr p) x ⊆ Set.range (Sum.inr : W × List W → _) := by
  intro z hz
  rw [TaskFrame.mem_Fib, ofStepRel_of_nonneg hx] at hz
  obtain ⟨q, rfl, -⟩ := (iter_inr_fwd _ p z).mp hz
  exact ⟨q, rfl⟩

theorem inr_preimage_fib_inr_pos {E : W → W → Prop} (p : W × List W) {x : ℤ} (hx : 0 ≤ x) :
    Sum.inr ⁻¹' (TaskFrame.Fib (ofStepRel (coneR E)) (.inr p) x)
      = TaskFrame.Fib (ofStepRel (coneRin E)) p x := by
  ext q
  simp only [Set.mem_preimage, TaskFrame.mem_Fib, ofStepRel_of_nonneg hx]
  constructor
  · intro h
    obtain ⟨q', hq', hiter⟩ := (iter_inr_fwd _ p (.inr q)).mp h
    cases Sum.inr.inj hq'
    exact hiter
  · intro h
    exact (iter_inr_fwd _ p (.inr q)).mpr ⟨q, rfl, h⟩

end Probe894b

namespace Probe894c

open FormalSystem.Semantics Probe894

variable {W : Type}

/-- The inr-layer lift: a base path out of `p.1` lifts to an inr-layer path out of `p`,
recording it.  This is the `step` field of `TwoWayBounded` at a nonnegative duration and an
inr-anchored point. -/
theorem exists_iter_coneRin {E : W → W → Prop} :
    ∀ (n : ℕ) (p : W × List W) (v : W), iter E n p.1 v →
      ∃ q : W × List W, q.1 = v ∧ iter (coneRin E) n p q := by
  intro n
  induction n with
  | zero =>
    intro p v h
    rw [iter_zero] at h
    exact ⟨p, h.symm ▸ rfl, by rw [iter_zero]⟩
  | succ n ih =>
    intro p v h
    obtain ⟨c, hc, hstep⟩ := h
    obtain ⟨q, hq1, hq⟩ := ih p c hc
    exact ⟨(v, q.1 :: q.2), rfl, q, hq, by exact ⟨hq1 ▸ hstep, rfl⟩⟩

/-- The backward half of `step` at an inr-anchored point: every base predecessor is realised,
through the inl layer, by the promiscuous entry edge. -/
theorem exists_iter_coneR_bwd_inr {E : W → W → Prop} (n : ℕ) (p : W × List W) (v : W)
    (h : iter E (n + 1) v p.1) :
    ∃ z : W ⊕ (W × List W), iter (coneR E) (n + 1) z (.inr p) ∧ coneF z = v :=
  ⟨.inl v, (iter_inl_inr n v p).mpr h, rfl⟩

end Probe894c
