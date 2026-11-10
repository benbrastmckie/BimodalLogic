/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.OrientedForest
import FormalSystem.Semantics.HistoryMorphism
import FormalSystem.ForMathlib.Combinatorics.SimpleGraphAcyclic

/-!
# The forward-cone unravelling of a one-step relation

For a one-step relation `E : W → W → Prop` this module builds the **forward-cone unravelling**
of `E` on the carrier `W ⊕ (W × List W)`: an unchanged copy of the base in the `inl` layer, and
a *path-recording* layer in the `inr` layer whose nodes are a base state together with the list
of base states already traversed. Its one-step relation `coneR` is doubly serial on the literal
sum carrier, its `inr` layer is an `IsOrientedForest`, and its *Saturation* splits across the two
layers: the `inl`-anchored half from the base's own *Saturation*, the `inr`-anchored half from
`saturation_of_orientedForest`.

The projection `coneF` back to the base is surjective and `TwoWayBounded`, so L⁺ truth transfers
along it by `TwoWayBounded.plus_invariance_of_isZTime_of_constraints`.

## The construction

`coneR E` has three kinds of edge and one deliberate absence:

* `inl u → inl v` whenever `E u v` — the `inl` layer is a verbatim copy of the base;
* `inl u → inr (v, h)` whenever `E u v`, for **every** recorded list `h` — the *entry* edge;
* `inr (u, h) → inr (v, u :: h)` whenever `E u v` — one `inr` step prepends the state just left
  to the record, so the recorded list strictly lengthens along every `inr` edge;
* nothing leaves the `inr` layer.

## The promiscuous entry edge, and why narrowing it breaks seriality

The entry edge is **promiscuous in the recorded list**: `coneR E (.inl u) (.inr (v, h))` holds for
every `h : List W` whenever `E u v`, with no coherence demand relating `h` to any real `E`-path
into `u`. The narrower rule `h = [u]` — which is the "obvious" reading, and will look to a later
reader like a correctness improvement — is **not** admissible, and this is not slack to be tidied
away.

Under the narrow rule the carrier still holds every node `inr (v, a :: t)` with `¬ E a v`. Such a
node traces no `E`-path, so nothing in the `inr` layer reaches it (an `inr` edge into it would
need `E a v`) and no entry edge reaches it either (an entry edge would need `t = []` and
`E a v`). It therefore has *no* predecessor at all, `coneR_serial_bwd` fails, and
`TaskFrame.ofStepSat`'s backward-seriality field cannot be discharged — so the carrier would have
to be cut down to a coherence subtype, with an `HEq` discipline at every transport. The
promiscuous rule is what keeps the carrier the literal sum type.

The same promiscuity is what makes `iter_inl_inr` an *equality* rather than a union over entry
points, and that equality is the whole of the `inl`-anchored half of the *Saturation* split.

## The carrier is the literal sum type

`IsOrientedForest (coneRin E)` holds on the **full** `W × List W`, incoherent records included.
Nothing in `IsOrientedForest` asks a node to be reachable: a record tracing no real `E`-path
simply has no incoming `inr` edge, which is compatible with loop-freeness, opposite-edge-freeness
and acyclicity. So no coherence subtype, no `Sigma` type and no `HEq` discipline appears anywhere
in this module.

## Why not reuse the universal cover

`Semantics/UniversalCover.lean` answers a different question and keeps its own consumers. The two
constructions divide as follows.

* The **universal cover** (`CoverPt`, `CoverStep`) is *forest-everywhere*: its whole carrier is an
  oriented forest, so its *Saturation* comes from `saturation_of_orientedForest` with **no**
  hypothesis on the base at all. The base need not be saturated.
* The **cone unravelling** (`coneR`) is *verbatim-copy-plus-tree*: the `inl` layer is the base
  relation unchanged, so base states, base fibres and base segments survive unmodified into the
  unravelling, and the `inr` layer records paths. That is what a formula-level rule needing a
  verbatim copy of the base alongside a path-recording layer requires, and it is why the base's
  own *Saturation* is a hypothesis of `saturation_coneR` rather than something the construction
  manufactures.

Both exist for the same downstream reason: `ProofSystem.FrameClass.Sat` demands
`FrameOver.IsRegular` — hence *Saturation* — of a frame-class member, so a countermodel can only
carry a refutation as a bona fide `FrameClass.Sat .ZTime` member once it has been presented as a
regular frame. `UniversalCover.lean` is modified by nothing here.

## Main definitions

* `coneRin` — the `inr`-layer one-step relation: prepend the state just left to the record
* `coneR` — the cone one-step relation on `W ⊕ (W × List W)`
* `coneF` — the projection back to the base
* `parIn` — drop the head of the record; the parent map fed to the acyclicity criterion
* `coneFrame` — the unravelling presented as a regular `FrameOver intOrder`

## Main results

* `coneRin_loopFree`, `coneRin_oppFree`, `coneRin_acyclic` — the three oriented-forest
  obligations, the third through `SimpleGraph.isAcyclic_of_rank_parent` with the record length as
  the rank and `parIn` as the parent map
* `coneRin_isOrientedForest` — the three assembled
* `coneRin_bwd_unique`, `coneRin_bwd_subsingleton` — backward determinism of the `inr` layer
* `coneR_serial_fwd`, `coneR_serial_bwd` — double seriality on the literal sum carrier
* `coneF_step`, `coneF_iter` — the projection is a homomorphism of one-step relations, and
  iterated
* `iter_inl_target`, `iter_inl_inl`, `iter_inr_fwd`, `iter_inl_inr` — the four transport
  identities
* `cone_member_classification` — the exhaustive member-shape classification the *Saturation*
  split consumes
* `saturation_coneR` — **the two-layer *Saturation* split**, with no seriality hypothesis
* `coneF_surjective` — the projection is surjective (axiom-free)
* `coneF_twoWayBounded` — the projection is `TwoWayBounded`
* `exists_coneUnravelling` — every regular frame over `intOrder` has a regular cone unravelling
  with surjective, two-way bounded projection, along which L⁺ truth transfers

## What is deliberately absent

**Unique path lifting is not stated**, and neither is any of the `Prefunctor.IsCovering`
machinery. `TwoWayBounded` has exactly two fields, and
`TwoWayBounded.plus_invariance_of_isZTime_of_constraints` consumes those two plus
`Function.Surjective`.

**No coherence subtype of the carrier** is introduced; see "The carrier is the literal sum type"
above.

**The formula-level rule is not here.** This module is the frame-side prerequisite only;
`Metalogic/NamingRules.lean`'s `clock_irr_sound` and `irr_sound` are untouched.

## Notes

### Verified Mathlib names

`SimpleGraph.isAcyclic_of_rank_parent` (from `ForMathlib/Combinatorics/SimpleGraphAcyclic.lean`)
and `SimpleGraph.fromRel_adj` are the two external names the acyclicity proof reads. The
`simp_all [parIn]` closing both branches of `coneRin_acyclic`'s parent obligation is
**pin-sensitive**: it compiles at this toolchain, and a Mathlib bump that changes `Prod`
destructuring or `List` `simp` normalisation may require it to be spelled out. The same note is
carried by `OrientedForest.lean` for its own `simp_all` sites.
-/

namespace FormalSystem.Semantics

variable {W : Type}

/-! ## The carrier and the relation -/

/-- The `inr`-layer one-step relation: step the base state along `E` and **prepend the state just
left** to the record, so the recorded list strictly lengthens along every edge. -/
def coneRin (E : W → W → Prop) : (W × List W) → (W × List W) → Prop :=
  fun p q => E p.1 q.1 ∧ q.2 = p.1 :: p.2

/--
The **cone one-step relation** on `W ⊕ (W × List W)`.

The `inl` layer is a verbatim copy of `E`; the entry edge `inl u → inr q` is **promiscuous in the
recorded list** (it asks only `E u q.1`, nothing about `q.2`); the `inr` layer is `coneRin`; and
nothing leaves the `inr` layer. See the module docstring for why narrowing the entry edge breaks
`coneR_serial_bwd`.
-/
def coneR (E : W → W → Prop) : (W ⊕ (W × List W)) → (W ⊕ (W × List W)) → Prop
  | .inl u, .inl v => E u v
  | .inl u, .inr q => E u q.1
  | .inr p, .inr q => coneRin E p q
  | .inr _, .inl _ => False

/-- The projection onto the base carrier: forget the layer, and in the `inr` layer forget the
record. -/
def coneF : (W ⊕ (W × List W)) → W
  | .inl u => u
  | .inr p => p.1

/-- **The cone carrier is nonempty** whenever the base is — the witness is an `inl` node. Needed
for `FrameOver.ofStepSat`'s `[Nonempty W]` binder, which instance search does not discharge for a
sum type from `Nonempty` of the left summand alone. -/
instance instNonemptyCone [h : Nonempty W] : Nonempty (W ⊕ (W × List W)) :=
  h.elim fun w => ⟨.inl w⟩

/-! ## The `inr` layer is an oriented forest -/

/-- Drop the head of the record. The empty record is its own parent, which is what makes the rank
inequality of `SimpleGraph.isAcyclic_of_rank_parent` hold without a side condition. -/
def parIn : (W × List W) → (W × List W)
  | (v, []) => (v, [])
  | (_, a :: t) => (a, t)

/-- The `inr` layer is loop-free: a `coneRin`-step lengthens the record, so no node steps to
itself. -/
theorem coneRin_loopFree (E : W → W → Prop) (p : W × List W) : ¬ coneRin E p p := by
  rintro ⟨-, h⟩
  exact absurd (congrArg List.length h) (by simp)

/-- The `inr` layer is opposite-edge-free: both directions of an edge would lengthen the record,
which is impossible. -/
theorem coneRin_oppFree (E : W → W → Prop) (p q : W × List W)
    (h : coneRin E p q) : ¬ coneRin E q p := by
  rintro ⟨-, h2⟩
  have h1 := congrArg List.length h.2
  have h2 := congrArg List.length h2
  simp at h1 h2
  omega

/-- The undirected multigraph underlying the `inr` layer is acyclic, by the rank-and-parent
criterion with the record length as the rank and `parIn` as the parent map. -/
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

/-- **The `inr` layer is an oriented forest**, over the full `W × List W` — incoherent records
included, since a record tracing no real `E`-path simply has no incoming edge. -/
theorem coneRin_isOrientedForest (E : W → W → Prop) : IsOrientedForest (coneRin E) where
  loopFree := coneRin_loopFree E
  oppFree := coneRin_oppFree E
  acyclic := coneRin_acyclic E

/-! ## Backward determinism of the `inr` layer -/

/-- **Backward determinism of the `inr` layer**: the recorded list forces the predecessor, so an
iterated `inr`-layer path into a node determines its source. This is the unique-`inr`-predecessor
property the task names. -/
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

/-- A backward fibre of the `inr` layer is a subsingleton: the consequence the
segment-inside-the-`inr`-layer case of the *Saturation* split consumes. -/
theorem coneRin_bwd_subsingleton {E : W → W → Prop} (n : ℕ) (q : W × List W) :
    {p | iter (coneRin E) n p q}.Subsingleton :=
  fun _ hp _ hp' => coneRin_bwd_unique n _ _ q hp hp'

/-! ## Double seriality on the literal sum carrier -/

/-- Forward seriality of `coneR`: an `inl` node steps within the `inl` layer, and an `inr` node
steps within the `inr` layer by recording the state it leaves. -/
theorem coneR_serial_fwd {E : W → W → Prop} (hfwd : ∀ w, ∃ u, E w u) :
    ∀ z : W ⊕ (W × List W), ∃ z', coneR E z z' := by
  rintro (u | ⟨v, l⟩)
  · obtain ⟨u', h⟩ := hfwd u
    exact ⟨.inl u', h⟩
  · obtain ⟨v', h⟩ := hfwd v
    exact ⟨.inr (v', v :: l), h, rfl⟩

/-- **Backward seriality of `coneR`, and the promiscuous entry edge's reason for being**: every
`inr` node — coherent or not — is reached by the entry edge from an `inl` base predecessor of its
base state. Under the narrow entry rule `h = [u]` this proof has no replacement. -/
theorem coneR_serial_bwd {E : W → W → Prop} (hbwd : ∀ w, ∃ v, E v w) :
    ∀ z : W ⊕ (W × List W), ∃ z', coneR E z' z := by
  rintro (u | ⟨v, l⟩)
  · obtain ⟨u', h⟩ := hbwd u
    exact ⟨.inl u', h⟩
  · obtain ⟨v', h⟩ := hbwd v
    exact ⟨.inl v', h⟩

/-! ## The projection is a homomorphism -/

/-- The projection carries a cone step to a base step: all three edge kinds project to `E`. -/
theorem coneF_step {E : W → W → Prop} {z z' : W ⊕ (W × List W)} (h : coneR E z z') :
    E (coneF z) (coneF z') := by
  match z, z', h with
  | .inl _, .inl _, h => exact h
  | .inl _, .inr _, h => exact h
  | .inr _, .inr _, h => exact h.1

/-- The projection carries iterated cone steps to iterated base steps. -/
theorem coneF_iter {E : W → W → Prop} :
    ∀ (n : ℕ) (z z' : W ⊕ (W × List W)), iter (coneR E) n z z' →
      iter E n (coneF z) (coneF z') := by
  intro n
  induction n with
  | zero => intro z z' h; rw [iter_zero] at h; subst h; rfl
  | succ n ih =>
    intro z z' h
    obtain ⟨v, hv, hstep⟩ := h
    exact ⟨coneF v, ih z v hv, coneF_step hstep⟩

/-! ## The `iter`-level transport identities -/

/-- Nothing enters the `inl` layer: an iterated path landing on an `inl` node starts there. -/
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

/-- The `inl` layer is a verbatim copy of the base, at every duration. -/
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

/-- Forward from the `inr` layer stays in the `inr` layer, and is the `inr`-layer iterate. -/
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

/--
**The promiscuous-entry collapse.** At a positive duration, an iterated cone path from an `inl`
node to an `inr` node is exactly a base path to that node's base state.

This is where the promiscuous entry edge earns its keep: because the entry edge imposes nothing
on the recorded list, the set of entry points contributing to this fibre collapses to a **single**
base fibre instead of a union indexed by records. That collapse is the whole of the
`inl`-anchored half of the *Saturation* split.
-/
theorem iter_inl_inr {E : W → W → Prop} (n : ℕ) (w : W) (q : W × List W) :
    iter (coneR E) (n + 1) (.inl w) (.inr q) ↔ iter E (n + 1) w q.1 := by
  constructor
  · intro h; simpa [coneF] using coneF_iter (n + 1) (.inl w) (.inr q) h
  · rintro ⟨c, hc, hstep⟩
    exact ⟨.inl c, (iter_inl_inl n w c).mpr hc, hstep⟩

/-! ## The `Fib`-level preimage bridges -/

/-- Case A, `inl` anchor: the `inl`-preimage of an `inl`-anchored fibre is the base fibre. -/
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

/-- Case A, `inr` anchor at a **negative** duration: the `inl`-preimage of a backward fibre at an
`inr` node is the base backward fibre at its base state. The promiscuous entry edge is what makes
this an equality rather than a union over entry points. -/
theorem inl_preimage_fib_inr_neg {E : W → W → Prop} (q : W × List W) {x : ℤ} (hx : x < 0) :
    Sum.inl ⁻¹' (TaskFrame.Fib (ofStepRel (coneR E)) (.inr q) x)
      = TaskFrame.Fib (ofStepRel E) q.1 x := by
  ext w
  obtain ⟨n, hn⟩ : ∃ n : ℕ, x.natAbs = n + 1 := ⟨x.natAbs - 1, by omega⟩
  simp only [Set.mem_preimage, TaskFrame.mem_Fib, ofStepRel_of_nonpos (le_of_lt hx), hn]
  exact iter_inl_inr n w q

/-- Case B: a forward fibre at an `inr` node lies entirely in the `inr` layer. -/
theorem fib_inr_pos_subset {E : W → W → Prop} (p : W × List W) {x : ℤ} (hx : 0 ≤ x) :
    TaskFrame.Fib (ofStepRel (coneR E)) (.inr p) x ⊆ Set.range (Sum.inr : W × List W → _) := by
  intro z hz
  rw [TaskFrame.mem_Fib, ofStepRel_of_nonneg hx] at hz
  obtain ⟨q, rfl, -⟩ := (iter_inr_fwd _ p z).mp hz
  exact ⟨q, rfl⟩

/-- Case B: the `inr`-preimage of a forward fibre at an `inr` node is the corresponding fibre of
the `inr`-layer relation. -/
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

/-! ## The `inr`-layer lifts -/

/-- The `inr`-layer lift: a base path out of `p.1` lifts to an `inr`-layer path out of `p`,
recording it. This is the `step` field of `TwoWayBounded` at a nonnegative duration and an
`inr`-anchored point. -/
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

/-- The backward half of `step` at an `inr`-anchored point: every base predecessor is realised,
through the `inl` layer, by the promiscuous entry edge. -/
theorem exists_iter_coneR_bwd_inr {E : W → W → Prop} (n : ℕ) (p : W × List W) (v : W)
    (h : iter E (n + 1) v p.1) :
    ∃ z : W ⊕ (W × List W), iter (coneR E) (n + 1) z (.inr p) ∧ coneF z = v :=
  ⟨.inl v, (iter_inl_inr n v p).mpr h, rfl⟩

end FormalSystem.Semantics
