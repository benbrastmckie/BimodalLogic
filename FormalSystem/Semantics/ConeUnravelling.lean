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
along it by `TwoWayBounded.plus_invariance_of_isZTime`.

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
`TwoWayBounded.plus_invariance_of_isZTime` consumes those two plus `Function.Surjective`.

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

/-! ## The set-level preamble

One frame-independent fact, stated here rather than in `OrientedForest.lean`, which this module
does not modify.
-/

/-- **A cofinal subfamily has the same intersection.** If every member of `S` contains a member of
`T ⊆ S`, then `⋂₀ T = ⋂₀ S`. This is what lets the *Saturation* split replace `S` by its
`inr`-contained subfamily in Case B without changing the goal. -/
theorem cofinal_sInter_eq {α : Type} {S T : Set (Set α)} (hTS : T ⊆ S)
    (hcof : ∀ s ∈ S, ∃ t ∈ T, t ⊆ s) : ⋂₀ T = ⋂₀ S := by
  refine Set.Subset.antisymm ?_ ?_
  · intro x hx s hs
    obtain ⟨t, htT, hts⟩ := hcof s hs
    exact hts (hx t htT)
  · intro x hx t htT
    exact hx t (hTS htT)

/-! ## The member-shape classification -/

/--
**An `inl`-anchored fibre, and a negative-duration `inr`-anchored fibre, always contain an `inl`
element** once they are nonempty.

The witness is obtained from any member element through `coneF`: `coneF_iter` projects the path to
the base, and `iter_inl_inl` (nonnegative, `inl` anchor) or `iter_inl_inr` (negative duration,
`inr` anchor) lifts it back as a path through the `inl` layer. For a negative duration at an `inl`
anchor the element is *already* `inl`, by `iter_inl_target`.

This is the fact that excludes those two shapes from the `inr`-contained subfamily in Case B of
the *Saturation* split.
-/
theorem mem_range_inl_of_mem {E : W → W → Prop} {z : W ⊕ (W × List W)} {x : ℤ}
    (hshape : (∃ a : W, z = Sum.inl a) ∨ x < 0)
    {y : W ⊕ (W × List W)} (hy : y ∈ TaskFrame.Fib (ofStepRel (coneR E)) z x) :
    ∃ b : W, (Sum.inl b : W ⊕ (W × List W)) ∈ TaskFrame.Fib (ofStepRel (coneR E)) z x := by
  rcases lt_or_ge x 0 with hx | hx
  · have hx' : x ≤ 0 := le_of_lt hx
    rw [TaskFrame.mem_Fib, ofStepRel_of_nonpos hx'] at hy
    cases z with
    | inl a =>
      obtain ⟨c, hc⟩ := iter_inl_target _ y a hy
      subst hc
      exact ⟨c, by rw [TaskFrame.mem_Fib, ofStepRel_of_nonpos hx']; exact hy⟩
    | inr q =>
      obtain ⟨n, hn⟩ : ∃ n : ℕ, x.natAbs = n + 1 := ⟨x.natAbs - 1, by omega⟩
      have hbase : iter E x.natAbs (coneF y) q.1 := by
        simpa [coneF] using coneF_iter x.natAbs y (.inr q) hy
      refine ⟨coneF y, ?_⟩
      rw [TaskFrame.mem_Fib, ofStepRel_of_nonpos hx', hn]
      exact (iter_inl_inr n (coneF y) q).mpr (hn ▸ hbase)
  · obtain ⟨a, rfl⟩ : ∃ a : W, z = Sum.inl a := by
      rcases hshape with h | h
      · exact h
      · omega
    rw [TaskFrame.mem_Fib, ofStepRel_of_nonneg hx] at hy
    have hbase : iter E x.natAbs a (coneF y) := by
      simpa [coneF] using coneF_iter x.natAbs (.inl a) y hy
    refine ⟨coneF y, ?_⟩
    rw [TaskFrame.mem_Fib, ofStepRel_of_nonneg hx]
    exact (iter_inl_inl x.natAbs a (coneF y)).mpr hbase

/--
**A set inside the `inr` layer that is bounded above by a backward fibre is a subsingleton.**

Its elements are `inr` nodes with a common iterated `inr`-layer path into `v`, and
`coneRin_bwd_unique` makes that path's source unique. Applied at a *segment* — whose
`TaskFrame.IsSegment` proviso supplies `0 ≤ y` and whose second conjunct supplies the bound —
this is the "segment contained in the `inr` layer" cell of the classification.

`seg_subsingleton` is **not** available here and is not the route: it demands
`IsOrientedForest (coneR E)`, which is false — the `inl` layer is a verbatim copy of `E` and
inherits its loops and opposite edges. Only the `inr` layer is a forest, and
`coneRin_bwd_unique` is that layer's own determinism fact.
-/
theorem subsingleton_of_subset_range_inr {E : W → W → Prop} {v : W ⊕ (W × List W)} {y : ℤ}
    (hy : 0 ≤ y) {s : Set (W ⊕ (W × List W))}
    (hinr : s ⊆ Set.range (Sum.inr : W × List W → W ⊕ (W × List W)))
    (hfib : s ⊆ TaskFrame.Fib (ofStepRel (coneR E)) v (-y)) : s.Subsingleton := by
  intro z hz z' hz'
  obtain ⟨p, rfl⟩ := hinr hz
  obtain ⟨p', rfl⟩ := hinr hz'
  have h1 := hfib hz
  have h2 := hfib hz'
  rw [TaskFrame.mem_Fib, ofStepRel_of_nonpos (by omega : -y ≤ 0)] at h1 h2
  obtain ⟨q, hvq, hi1⟩ := (iter_inr_fwd _ p v).mp h1
  obtain ⟨q', hvq', hi2⟩ := (iter_inr_fwd _ p' v).mp h2
  have hqq : q = q' := Sum.inr.inj (hvq.symm.trans hvq')
  subst hqq
  exact congrArg Sum.inr (coneRin_bwd_unique _ p p' q hi1 hi2)

/--
**Case A's table as one lemma.** A nonempty fibre-or-segment member of the cone's task relation
that is *not* contained in the `inr` layer has an `inl`-preimage that is a nonempty fibre or
segment of the base relation.

The `inl`-preimage is taken literally, so `Sum.inl b ∈ s ↔ b ∈ Sum.inl ⁻¹' s` is `Iff.rfl` and
needs no statement of its own; that is what lets Case A return `Sum.inl b` for the base witness
`b` that the base's *Saturation* supplies.

The shapes excluded by the `¬ ⊆ Set.range Sum.inr` hypothesis are exactly the ones
`fib_inr_pos_subset` sends into the `inr` layer: a nonnegative-duration `inr`-anchored fibre, and
a segment either of whose endpoint fibres is one.
-/
theorem fib_or_seg_inl_preimage {E : W → W → Prop} {s : Set (W ⊕ (W × List W))}
    (hkind : TaskFrame.IsFiber (ofStepRel (coneR E)) s ∨
      TaskFrame.IsSegment (ofStepRel (coneR E)) s)
    (hns : ¬ s ⊆ Set.range (Sum.inr : W × List W → W ⊕ (W × List W))) :
    (TaskFrame.IsFiber (ofStepRel E) (Sum.inl ⁻¹' s) ∨
        TaskFrame.IsSegment (ofStepRel E) (Sum.inl ⁻¹' s)) ∧
      (Sum.inl ⁻¹' s).Nonempty := by
  refine ⟨?_, ?_⟩
  · rcases hkind with ⟨z, x, rfl⟩ | ⟨w, v, x, y, hx, hy, rfl⟩
    · cases z with
      | inl a => exact Or.inl ⟨a, x, inl_preimage_fib_inl a x⟩
      | inr q =>
        rcases lt_or_ge x 0 with hxneg | hxpos
        · exact Or.inl ⟨q.1, x, inl_preimage_fib_inr_neg q hxneg⟩
        · exact absurd (fib_inr_pos_subset q hxpos) hns
    · -- the `w` endpoint must be `inl`, since `0 ≤ x` sends an `inr` anchor into the `inr` layer
      obtain ⟨a, rfl⟩ : ∃ a : W, w = Sum.inl a := by
        cases w with
        | inl a => exact ⟨a, rfl⟩
        | inr p =>
          exact absurd (fun u hu => fib_inr_pos_subset p hx hu.1) hns
      -- the `v` endpoint is either `inl`, or `inr` at a strictly negative `-y`
      refine Or.inr ?_
      cases v with
      | inl b =>
        refine ⟨a, b, x, y, hx, hy, ?_⟩
        rw [TaskFrame.Seg, TaskFrame.Seg, Set.preimage_inter, inl_preimage_fib_inl a x,
          inl_preimage_fib_inl b (-y)]
      | inr q =>
        have hypos : 0 < y := by
          rcases lt_or_ge 0 y with h | h
          · exact h
          · have hy0 : y = 0 := le_antisymm h hy
            subst hy0
            exact absurd (fun u hu => fib_inr_pos_subset q (by norm_num) hu.2) hns
        refine ⟨a, q.1, x, y, hx, hy, ?_⟩
        rw [TaskFrame.Seg, TaskFrame.Seg, Set.preimage_inter, inl_preimage_fib_inl a x,
          inl_preimage_fib_inr_neg q (by omega : -y < 0)]
  · obtain ⟨z, hzs, hzn⟩ := Set.not_subset.mp hns
    cases z with
    | inl a => exact ⟨a, hzs⟩
    | inr p => exact absurd ⟨p, rfl⟩ hzn

/--
**The exhaustive member-shape classification the *Saturation* split consumes.**

Every nonempty fibre-or-segment member of `ofStepRel (coneR E)` falls under exactly one of three
*dispositions*, and the three are what `saturation_coneR`'s four steps act on:

* **D1 — subsingleton.** Closed outright by `OrientedForest.sInter_nonempty_of_subsingleton_member`
  (Reduction A), which consumes no forest input at all.
* **D2 — not contained in the `inr` layer.** Transported by `Sum.inl ⁻¹'` through
  `fib_or_seg_inl_preimage` and closed by the base's own *Saturation* (Case A).
* **D3 — an `inr`-anchored fibre of nonnegative duration.** Transported by `Sum.inr ⁻¹'` through
  `inr_preimage_fib_inr_pos` and closed by `saturation_of_orientedForest` on the `inr` layer
  (Case B).

The grid is `{IsFiber, IsSegment}` × anchor side × duration sign, and all twelve cells have a
named disposition:

| # | Class | Anchor(s) | Duration | Disposition |
|---|-------|-----------|----------|-------------|
| 1 | `IsFiber` | `inl` | `0 ≤ x` | **D2** — `mem_range_inl_of_mem` gives an `inl` element |
| 2 | `IsFiber` | `inl` | `x < 0` | **D2** — `iter_inl_target`: every element is already `inl` |
| 3 | `IsFiber` | `inr` | `0 ≤ x` | **D3** — the Case B shape |
| 4 | `IsFiber` | `inr` | `x < 0` | **D2** — `iter_inl_inr` exhibits the `inl` entry point |
| 5 | `IsSegment` | `inl`, `inl` | `0 < y` | **D2** or **D1** — `inr`-contained is D1, else D2 |
| 6 | `IsSegment` | `inl`, `inl` | `y = 0` | **D2** or **D1** — likewise |
| 7 | `IsSegment` | `inl`, `inr` | `0 < y` | **D2** or **D1** — likewise |
| 8 | `IsSegment` | `inl`, `inr` | `y = 0` | **D1** — `fib_inr_pos_subset` at `-0` forces it |
| 9 | `IsSegment` | `inr`, `inl` | `0 < y` | **D1** — `fib_inr_pos_subset` at `0 ≤ x` forces it |
| 10 | `IsSegment` | `inr`, `inl` | `y = 0` | **D1** — likewise |
| 11 | `IsSegment` | `inr`, `inr` | `0 < y` | **D1** — likewise |
| 12 | `IsSegment` | `inr`, `inr` | `y = 0` | **D1** — likewise |

The segment rows collapse to one uniform argument — `inr`-contained gives D1 by
`subsingleton_of_subset_range_inr`, and otherwise D2 — which is why the statement below is a
three-way disjunction rather than a twelve-way one. Rows 8–12 are the rows in which
`inr`-containment is *forced* rather than merely possible, and they are recorded separately
because that is the information a reader needs to see no cell was dropped.
-/
theorem cone_member_classification {E : W → W → Prop} {s : Set (W ⊕ (W × List W))}
    (hkind : TaskFrame.IsFiber (ofStepRel (coneR E)) s ∨
      TaskFrame.IsSegment (ofStepRel (coneR E)) s)
    (hne : s.Nonempty) :
    s.Subsingleton
      ∨ ¬ s ⊆ Set.range (Sum.inr : W × List W → W ⊕ (W × List W))
      ∨ ∃ (p : W × List W) (x : ℤ), 0 ≤ x ∧ s = TaskFrame.Fib (ofStepRel (coneR E)) (.inr p) x := by
  have hD2 : ∀ {z : W ⊕ (W × List W)} {x : ℤ}, (∃ a : W, z = Sum.inl a) ∨ x < 0 →
      s = TaskFrame.Fib (ofStepRel (coneR E)) z x →
      ¬ s ⊆ Set.range (Sum.inr : W × List W → W ⊕ (W × List W)) := by
    intro z x hshape hseq hsub
    obtain ⟨y0, hy0⟩ := hne
    rw [hseq] at hy0 hsub
    obtain ⟨b, hb⟩ := mem_range_inl_of_mem hshape hy0
    exact absurd (hsub hb) (by simp)
  rcases hkind with ⟨z, x, hseq⟩ | ⟨w, v, x, y, hx, hy, hseq⟩
  · rcases lt_or_ge x 0 with hxneg | hxpos
    · exact Or.inr (Or.inl (hD2 (Or.inr hxneg) hseq))
    · cases z with
      | inl a => exact Or.inr (Or.inl (hD2 (Or.inl ⟨a, rfl⟩) hseq))
      | inr p => exact Or.inr (Or.inr ⟨p, x, hxpos, hseq⟩)
  · by_cases hsub : s ⊆ Set.range (Sum.inr : W × List W → W ⊕ (W × List W))
    · exact Or.inl (subsingleton_of_subset_range_inr hy hsub (fun u hu => (hseq ▸ hu).2))
    · exact Or.inr (Or.inl hsub)

/-! ## The two-layer *Saturation* split

`saturation_coneR` is four steps, of which the two cases of the layer split are the named
step lemmas below.

* **Step 1** — a subsingleton member closes the goal outright, by
  `sInter_nonempty_of_subsingleton_member` (Reduction A of `OrientedForest.lean`). This disposes
  of every duration-zero fibre, every segment with a zero endpoint offset, and every segment
  contained in the `inr` layer.
* **Step 2** — split on `∃ s₀ ∈ S, s₀ ⊆ Set.range Sum.inr`.
* **Step 3** — `sInter_nonempty_of_no_inr_member` (Case A).
* **Step 4** — `sInter_nonempty_of_inr_member` (Case B).
-/

/--
**Case A of the layer split**: no member of the family lies inside the `inr` layer.

The whole family transports by `Sum.inl ⁻¹'` through `fib_or_seg_inl_preimage` into a
`⊇`-directed family of nonempty base fibres and segments, the base's own *Saturation* supplies a
witness `b`, and `Sum.inl b` is a witness for the original family — because the `inl` layer is a
verbatim copy of the base, so `Sum.inl b ∈ s ↔ b ∈ Sum.inl ⁻¹' s` holds by definition.

This is the half of the split that reads `hbase`, and it is the reason `saturation_coneR` cannot
do without it.
-/
theorem sInter_nonempty_of_no_inr_member {E : W → W → Prop}
    (hbase : TaskFrame.Saturation (ofStepRel E))
    {S : Set (Set (W ⊕ (W × List W)))} (hSne : S.Nonempty)
    (hd : ∀ S₁ ∈ S, ∀ S₂ ∈ S, ∃ S' ∈ S, S' ⊆ S₁ ∩ S₂)
    (hmem : ∀ s ∈ S, (TaskFrame.IsFiber (ofStepRel (coneR E)) s ∨
      TaskFrame.IsSegment (ofStepRel (coneR E)) s) ∧ s.Nonempty)
    (hA : ∀ s ∈ S, ¬ s ⊆ Set.range (Sum.inr : W × List W → W ⊕ (W × List W))) :
    (⋂₀ S).Nonempty := by
  have hdir : TaskFrame.DirectedFamily ((fun s => Sum.inl ⁻¹' s) '' S) := by
    refine ⟨?_, ?_⟩
    · obtain ⟨s₀, hs₀⟩ := hSne
      exact ⟨Sum.inl ⁻¹' s₀, s₀, hs₀, rfl⟩
    · rintro _ ⟨s₁, hs₁, rfl⟩ _ ⟨s₂, hs₂, rfl⟩
      obtain ⟨s', hs', hsub⟩ := hd s₁ hs₁ s₂ hs₂
      refine ⟨Sum.inl ⁻¹' s', ⟨s', hs', rfl⟩, ?_⟩
      intro b hb
      exact ⟨(hsub hb).1, (hsub hb).2⟩
  have hmem' : ∀ t ∈ (fun s => Sum.inl ⁻¹' s) '' S,
      (TaskFrame.IsFiber (ofStepRel E) t ∨ TaskFrame.IsSegment (ofStepRel E) t) ∧ t.Nonempty := by
    rintro _ ⟨s, hs, rfl⟩
    exact fib_or_seg_inl_preimage (hmem s hs).1 (hA s hs)
  obtain ⟨b, hb⟩ := hbase _ hdir hmem'
  exact ⟨Sum.inl b, fun s hs => hb (Sum.inl ⁻¹' s) ⟨s, hs, rfl⟩⟩

/--
**Case B of the layer split**: some member lies inside the `inr` layer.

Directedness makes the `inr`-contained members **cofinal** in the family — the common sub-member
of `s₀` and any `s` is itself inside the `inr` layer and inside `s` — so `cofinal_sInter_eq`
replaces the family by that subfamily without changing the intersection. Every member of the
subfamily is then an `inr`-anchored fibre of nonnegative duration: `cone_member_classification`
leaves only that cell once the subsingleton disposition is excluded by `hnosub` and the
not-`inr`-contained disposition is excluded by membership in the subfamily. The subfamily
transports by `Sum.inr ⁻¹'` through `inr_preimage_fib_inr_pos`, and
`saturation_of_orientedForest` on the `inr` layer closes the goal.

The `inr` half therefore reads **no** hypothesis about the base: `coneRin_isOrientedForest` holds
for every `E` whatsoever.
-/
theorem sInter_nonempty_of_inr_member {E : W → W → Prop}
    {S : Set (Set (W ⊕ (W × List W)))}
    (hd : ∀ S₁ ∈ S, ∀ S₂ ∈ S, ∃ S' ∈ S, S' ⊆ S₁ ∩ S₂)
    (hne : ∀ s ∈ S, s.Nonempty)
    (hmem : ∀ s ∈ S, (TaskFrame.IsFiber (ofStepRel (coneR E)) s ∨
      TaskFrame.IsSegment (ofStepRel (coneR E)) s) ∧ s.Nonempty)
    (hnosub : ∀ T ∈ S, ¬ T.Subsingleton)
    {s₀ : Set (W ⊕ (W × List W))} (hs₀ : s₀ ∈ S)
    (hs₀inr : s₀ ⊆ Set.range (Sum.inr : W × List W → W ⊕ (W × List W))) :
    (⋂₀ S).Nonempty := by
  -- the `inr`-contained subfamily, and its cofinality
  have hTS : {s ∈ S | s ⊆ Set.range (Sum.inr : W × List W → W ⊕ (W × List W))} ⊆ S :=
    fun _ hs => hs.1
  have hcof : ∀ s ∈ S, ∃ t ∈ {s ∈ S | s ⊆ Set.range (Sum.inr : W × List W → W ⊕ (W × List W))},
      t ⊆ s := by
    intro s hs
    obtain ⟨s', hs', hsub⟩ := hd s₀ hs₀ s hs
    exact ⟨s', ⟨hs', fun z hz => hs₀inr (hsub hz).1⟩, fun z hz => (hsub hz).2⟩
  have hTeq : ⋂₀ {s ∈ S | s ⊆ Set.range (Sum.inr : W × List W → W ⊕ (W × List W))} = ⋂₀ S :=
    cofinal_sInter_eq hTS hcof
  -- every member of the subfamily is an `inr`-anchored fibre of nonnegative duration
  have hshape : ∀ s ∈ {s ∈ S | s ⊆ Set.range (Sum.inr : W × List W → W ⊕ (W × List W))},
      ∃ (p : W × List W) (x : ℤ), 0 ≤ x ∧
        s = TaskFrame.Fib (ofStepRel (coneR E)) (.inr p) x := by
    intro s hs
    rcases cone_member_classification (hmem s hs.1).1 (hne s hs.1) with h | h | h
    · exact absurd h (hnosub s hs.1)
    · exact absurd hs.2 h
    · exact h
  -- transport the subfamily into the `inr` layer
  have hdir : TaskFrame.DirectedFamily ((fun s => Sum.inr ⁻¹' s) ''
      {s ∈ S | s ⊆ Set.range (Sum.inr : W × List W → W ⊕ (W × List W))}) := by
    refine ⟨⟨Sum.inr ⁻¹' s₀, s₀, ⟨hs₀, hs₀inr⟩, rfl⟩, ?_⟩
    rintro _ ⟨s₁, hs₁, rfl⟩ _ ⟨s₂, hs₂, rfl⟩
    obtain ⟨s', hs', hsub⟩ := hd s₁ hs₁.1 s₂ hs₂.1
    refine ⟨Sum.inr ⁻¹' s', ⟨s', ⟨hs', fun z hz => hs₁.2 (hsub hz).1⟩, rfl⟩, ?_⟩
    intro q hq
    exact ⟨(hsub hq).1, (hsub hq).2⟩
  have hmem' : ∀ t ∈ (fun s => Sum.inr ⁻¹' s) ''
      {s ∈ S | s ⊆ Set.range (Sum.inr : W × List W → W ⊕ (W × List W))},
      (TaskFrame.IsFiber (ofStepRel (coneRin E)) t ∨
        TaskFrame.IsSegment (ofStepRel (coneRin E)) t) ∧ t.Nonempty := by
    rintro _ ⟨s, hs, rfl⟩
    obtain ⟨z, hz⟩ := hne s hs.1
    obtain ⟨q, rfl⟩ := hs.2 hz
    obtain ⟨p, x, hx, hseq⟩ := hshape s hs
    refine ⟨Or.inl ⟨p, x, ?_⟩, ⟨q, hz⟩⟩
    rw [hseq]; exact inr_preimage_fib_inr_pos p hx
  obtain ⟨p, hp⟩ :=
    saturation_of_orientedForest (coneRin_isOrientedForest E) _ hdir hmem'
  refine ⟨Sum.inr p, ?_⟩
  rw [← hTeq]
  exact fun s hs => hp (Sum.inr ⁻¹' s) ⟨s, hs, rfl⟩

/--
**The two-layer *Saturation* split.**

*Saturation* of the cone's task relation follows from *Saturation* of the base's, with the two
layers discharged by different means: the `inl`-anchored families from the base's own
*Saturation* (`sInter_nonempty_of_no_inr_member`), the `inr`-anchored families from
`saturation_of_orientedForest` on the `inr` layer (`sInter_nonempty_of_inr_member`), and the
mixed case handled by **directedness** — a family with one `inr`-contained member has its
`inr`-contained members cofinal, so there is no genuinely mixed case left to treat.

**No seriality hypothesis is taken, and none is needed.** Every nonemptiness obligation in the
split is discharged from the member's own nonemptiness, through the projection homomorphism;
adding a seriality hypothesis would silently weaken the statement.

`hbase` is taken in `ofStepRel` form rather than as a frame field, mirroring
`saturation_of_orientedForest'`'s own `hgen`-parameterised design: this tree has no
relation-level `F.TaskRel = ofStepRel F.step` equality for a general regular `F`, only the
pointwise `FrameOver.taskRel_eq_iter`, so the bridge is made once at the frame assembly --
`base_taskRel_eq_ofStepRel` below is the lemma that makes it -- rather than inside this
theorem.

Paper: `def:frame#Saturation`
-/
theorem saturation_coneR {E : W → W → Prop}
    (hbase : TaskFrame.Saturation (ofStepRel E)) :
    TaskFrame.Saturation (ofStepRel (coneR E)) := by
  intro S hdir hmem
  obtain ⟨hSne, hd⟩ := hdir
  have hne : ∀ s ∈ S, s.Nonempty := fun s hs => (hmem s hs).2
  -- Step 1: a subsingleton member closes the goal outright
  by_cases hsub : ∃ T ∈ S, T.Subsingleton
  · obtain ⟨T, hT, hTsub⟩ := hsub
    exact sInter_nonempty_of_subsingleton_member hd hne hT hTsub
  have hnosub : ∀ T ∈ S, ¬ T.Subsingleton := by
    intro T hT hTsub
    exact hsub ⟨T, hT, hTsub⟩
  -- Step 2: split on whether some member lies inside the `inr` layer
  by_cases hB : ∃ s₀ ∈ S, s₀ ⊆ Set.range (Sum.inr : W × List W → W ⊕ (W × List W))
  · obtain ⟨s₀, hs₀, hs₀inr⟩ := hB
    -- Step 4 (Case B)
    exact sInter_nonempty_of_inr_member hd hne hmem hnosub hs₀ hs₀inr
  · -- Step 3 (Case A)
    push Not at hB
    exact sInter_nonempty_of_no_inr_member hbase hSne hd hmem hB

/-! ## The projection is surjective -/

-- `linter.unusedVariables`, scoped to this declaration: the `{E}` binder is genuinely unread, and
-- a deletion trial confirms it — removing the binder leaves the statement, the proof term
-- `fun w => ⟨.inl w, rfl⟩` and the build all unchanged, because `coneF` mentions no relation. The
-- binder is retained because it is the published signature this theorem's recorded statement
-- fixes; see the doc comment below and `scripts/nolint-attribute-allowlist.txt`.
set_option linter.unusedVariables false in
/-- **The projection is surjective**, with the `Sum.inl` section as the witness — axiom-free, as
`UniversalCover.endpt_surjective` is. The `inl` layer being a verbatim copy of the base is exactly
what makes this one line.

The `{E}` binder is genuinely unread, and the linter is correct about that: `coneF` is the sum
eliminator and mentions no relation at all, unlike `UniversalCover.endpt_surjective`, whose own
`{E}` indexes the carrier `CoverPt E`. It is retained because this is the **published signature**
that the recorded statement of this theorem fixes, so dropping it would change a contract
signature to spare a linter; a use site supplies it as `coneF_surjective (E := E)`. Paired
entry: `scripts/nolint-attribute-allowlist.txt`. -/
@[nolint unusedArguments]
theorem coneF_surjective {E : W → W → Prop} :
    Function.Surjective (coneF (W := W)) :=
  fun w => ⟨.inl w, rfl⟩

/-! ## The base-*Saturation* bridge -/

/--
**The base frame's task relation is the one generated by its one-step relation**, as a
relation-level equality.

`FrameOver.taskRel_eq_iter` (`Semantics/IntNormalForm.lean`) is the pointwise biconditional, and
`ofStepRel F.step w d u` is *definitionally* its right-hand conjunction, so `funext` plus
`propext` of that theorem is the whole proof.

**Why this lemma exists, and why it lives here.** `saturation_coneR` takes its base hypothesis in
`ofStepRel` form, mirroring `saturation_of_orientedForest'`'s own `hgen`-parameterised design,
because this tree ships no relation-level `F.TaskRel = ofStepRel F.step` equality for a general
regular `F`. This closes that gap once, at the frame assembly, rather than inside
`saturation_coneR`.

**Placement is deliberate, not accidental.** The statement is general enough to belong upstream
in `Semantics/IntNormalForm.lean` eventually, beside `taskRel_eq_iter` itself. It is kept here
because `IntNormalForm.lean` is widely imported and this module's blast radius is deliberately
one file. A later reader should **promote** it deliberately — move it upstream and re-point this
module's one use site — rather than duplicate it.

Constraints consumed: Compositionality, Seriality, Limit

Paper: — (formalization-native; the paper states no generated-relation equality)
-/
theorem base_taskRel_eq_ofStepRel (F : FrameOver intOrder) [F.IsRegular] :
    F.TaskRel = ofStepRel F.step := by
  funext w d u
  exact propext (F.taskRel_eq_iter w u d)

/-! ## The cone frame -/

/--
**The cone frame** of a regular frame over `intOrder`: the cone carrier presented as a
`FrameOver intOrder` through `FrameOver.ofStepSat`.

The two seriality fields come from `coneR_serial_fwd`/`coneR_serial_bwd` at the base's own
one-step seriality witnesses, `F.serial w 1 zero_le_one`. The *Saturation* field comes from
`saturation_coneR` at the base's *Saturation*, carried into `ofStepRel` form by
`base_taskRel_eq_ofStepRel`.

**There is no `coneFrameOfSerial` / `coneFrameOfSerialSat` intermediate layer**, and that
asymmetry with `UniversalCover.lean`'s `coverFrameOfSerial` is the substantive content of this
module rather than slack to be tidied away. The cover's *Saturation* comes from
`saturation_of_orientedForest`, a fact about oriented forests, so the cover can be built over a
base carrying *Seriality* alone and a second, constraint-parameterised layer has something real
to range over. The cone's `inl` layer is a verbatim copy of the base and inherits its loops and
opposite edges, so `IsOrientedForest (coneR E)` is false and the `inl`-anchored half of the
*Saturation* split must read the base's own *Saturation*. A second, constraint-parameterised
layer here would have to take all four constraints, i.e. exactly `[F.IsRegular]` unbundled, and
would parameterise over nothing.

`FrameOver.ofStep` cannot present this frame: the cone carrier is infinite whenever `W` is, and
`ofStep`'s `[Finite W]` binder is consumed exactly to obtain *Saturation*.

Constraints consumed: Compositionality, Seriality, Limit, Saturation
-/
def coneFrame (F : FrameOver intOrder) [F.IsRegular] : FrameOver intOrder :=
  FrameOver.ofStepSat (coneR F.step)
    (coneR_serial_fwd fun w => (F.serial w 1 zero_le_one).1)
    (coneR_serial_bwd fun w => (F.serial w 1 zero_le_one).2)
    (saturation_coneR (base_taskRel_eq_ofStepRel F ▸ F.saturation))

/-- The cone frame's task relation is the one generated by the cone's one-step relation. -/
theorem coneFrame_taskRel (F : FrameOver intOrder) [F.IsRegular] :
    (coneFrame F).TaskRel = ofStepRel (coneR F.step) :=
  FrameOver.ofStepSat_taskRel _ _ _ _

/-- **The cone frame is regular** — *Saturation* included, inherited from the base's own. An
`instance`, not a `theorem`: `exists_coneUnravelling`'s call to
`TwoWayBounded.plus_invariance_of_isZTime` reads `[F'.IsRegular]` by synthesis. -/
instance coneFrame_isRegular (F : FrameOver intOrder) [F.IsRegular] :
    (coneFrame F).IsRegular :=
  FrameOver.ofStepSat_isRegular _ _ _ _

/-! ## The projection is two-way bounded -/

/--
**The projection is two-way bounded.**

`forth` is `coneF_iter` on the two sign-guarded conjuncts of `ofStepRel`, with the source side
read through `coneFrame_taskRel` and the base side through `FrameOver.taskRel_eq_iter`.

`step` is a four-way split on the anchor's shape and the sign of the duration, and each branch is
a transport identity already proved above:

* `.inl w`, either sign — `iter_inl_inl`, at `.inl v`: the `inl` layer is a verbatim copy of the
  base, so a base path lifts to the `inl` layer unchanged in both directions;
* `.inr p`, `0 ≤ x` — `exists_iter_coneRin`, at the `inr` node the lift records: forward from the
  `inr` layer stays in the `inr` layer, and the base path is recorded as it is traversed;
* `.inr p`, `x < 0` — `exists_iter_coneR_bwd_inr`, landing on `.inl v`. The witness leaves the
  `inr` layer, which is possible only because the entry edge is **promiscuous in the recorded
  list**: a base predecessor of `p.1` is realised by entering at `.inl v` and stepping in, with no
  coherence demand on `p.2`. At `x < 0` the duration is a genuine `n + 1`, which is what the
  entry edge needs — a zero-length backward path would have to stay at `.inr p` itself, and that
  case is on the `0 ≤ x` side of the split.

`UniversalCover.endpt_twoWayBounded` is the two-field template; the split here is four-way
rather than two-way because the cone carrier has two layers.

Constraints consumed: Compositionality, Seriality, Limit
-/
theorem coneF_twoWayBounded (F : FrameOver intOrder) [F.IsRegular] :
    TwoWayBounded (F' := coneFrame F) (F := F) coneF := by
  constructor
  · intro a x b hab
    rw [coneFrame_taskRel] at hab
    rw [F.taskRel_eq_iter]
    exact ⟨fun hx => coneF_iter _ _ _ (hab.1 hx), fun hx => coneF_iter _ _ _ (hab.2 hx)⟩
  · intro a x v hv
    rw [F.taskRel_eq_iter] at hv
    match a with
    | .inl w =>
      refine ⟨.inl v, ?_, rfl⟩
      rw [coneFrame_taskRel]
      exact ⟨fun hx => (iter_inl_inl x.natAbs w v).mpr (hv.1 hx),
             fun hx => (iter_inl_inl x.natAbs v w).mpr (hv.2 hx)⟩
    | .inr p =>
      rcases le_or_gt 0 x with hx | hx
      · have hx' : (0 : ℤ) ≤ x := hx
        obtain ⟨q, hq1, hq⟩ := exists_iter_coneRin x.natAbs p v (hv.1 hx')
        refine ⟨.inr q, ?_, hq1⟩
        rw [coneFrame_taskRel]
        exact (ofStepRel_of_nonneg hx' _ _).mpr ((iter_inr_fwd _ _ _).mpr ⟨q, rfl, hq⟩)
      · have hxlt : (x : ℤ) < 0 := hx
        have hx' : x ≤ (0 : ℤ) := le_of_lt hxlt
        obtain ⟨n, hn⟩ := Nat.exists_eq_succ_of_ne_zero (Int.natAbs_ne_zero.mpr (ne_of_lt hxlt))
        have hbase : iter F.step (n + 1) v p.1 := by
          have h := hv.2 hx'
          rw [hn] at h
          exact h
        obtain ⟨z, hz, hzf⟩ := exists_iter_coneR_bwd_inr n p v hbase
        refine ⟨z, ?_, hzf⟩
        rw [coneFrame_taskRel]
        refine (ofStepRel_of_nonpos hx' _ _).mpr ?_
        rw [hn]
        exact hz

/-! ## Assembly -/

open FormalSystem.PlusLanguage in
/--
**Every regular frame over `intOrder` has a regular cone unravelling with surjective, two-way
bounded projection, along which L⁺ truth transfers.**

The cone frame is `coneFrame F`; the projection is `coneF`; two-way boundedness is
`coneF_twoWayBounded` and surjectivity is `coneF_surjective`; and
`TwoWayBounded.plus_invariance_of_isZTime` supplies the history morphism together with the truth
biconditional, reading both frames' `IsRegular` instances by synthesis — which is why
`coneFrame_isRegular` above is an `instance`.

**The base's *Saturation* is inherited, not manufactured, and that asymmetry with
`UniversalCover.lean` is the substantive content of this module rather than slack to be tidied
away.** `UniversalCover.lean`'s cover-existence theorem has a general form taking
*Compositionality*, *Seriality* and *Limit* and no more, because the cover's own *Saturation*
comes from `saturation_of_orientedForest` — a fact about oriented forests, with no hypothesis on
the base. This theorem cannot be stated that way. The cone's `inl` layer is a verbatim copy of
the base and inherits its loops and opposite edges, so `IsOrientedForest (coneR E)` is false and
no structural route to *Saturation* exists; the `inl`-anchored half of the split
(`sInter_nonempty_of_no_inr_member`) reads the base's own *Saturation* instead. That reading is
**necessary**, not merely convenient: over `E := fun w u => (w ≤ u : Prop)` on `ℤ` — which is
*Compositional*, *Serial* and *Limit* — the family `{Fib (ofStepRel (coneR E)) (.inl w) 1 | w : ℤ}`
is `⊇`-directed with nonempty `IsFiber` members and empty `⋂₀`, so the cone over such a base has
no *Saturation* field to give. Hence `[F.IsRegular]` here, which bundles *Saturation* with the
other three, and hence no constraint-parameterised general form below it: such a form would have
to take all four constraints and would parameterise over nothing.

**This theorem must not be discharged by delegating to `exists_orientedForest_cover`.** That
theorem has a satisfying witness of exactly this *type* and an entirely different
*construction* — the oriented-forest cover, not the cone — so a proof routed through it would
assert nothing about this module while passing every name-existence check, every zero-debt check
and every axiom check. The witness is `coneFrame F` and nothing else.

**Unique path lifting is deliberately not stated.** `plus_invariance_of_isZTime` consumes `forth`,
`step` and surjectivity and nothing else, so the covering-property machinery would cost the module
its weight for no consumer.

Constraints consumed: Compositionality, Seriality, Limit, Saturation

Paper: — (formalization-native; the paper defines no unravelling of a task frame)
-/
theorem exists_coneUnravelling (F : FrameOver intOrder) [F.IsRegular]
    (M : TaskModel F.toTaskFrame) :
    ∃ (F' : FrameOver intOrder) (_ : F'.IsRegular) (f : F'.WorldState → F.WorldState),
      TwoWayBounded f ∧ Function.Surjective f ∧
        ∃ g : HistMorphism F' F, g.toFun = f ∧
          ∀ (φ : PlusFormula) (τ' : WorldHistory F'.toTaskFrame) (t : ↑intOrder),
            PlusTruthAt (g.pullM M) τ' t φ ↔ PlusTruthAt M (g.mapH τ') t φ :=
  ⟨coneFrame F, coneFrame_isRegular F, coneF, coneF_twoWayBounded F,
    coneF_surjective (E := F.step),
    @TwoWayBounded.plus_invariance_of_isZTime intOrder (coneFrame F) F
      (coneFrame_isRegular F) ‹F.IsRegular›
      (inferInstanceAs (SuccOrder ℤ)) (inferInstanceAs (IsSuccArchimedean ℤ))
      coneF (coneF_twoWayBounded F) (coneF_surjective (E := F.step)) M⟩

end FormalSystem.Semantics
