/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Closure
import FormalSystem.Metalogic.Decidability.BiLasso.Periodic

/-!
# The Time-Sliced L⁺ Certificate: Types and the Three-Segment Readout

The certificate type this subtree is built around, and the readout that turns its finite data into
bi-infinite functions. It states no condition beyond bi-seriality and proves no truth lemma: the
checker, the frame, the liveness computation and the two adequacy directions live beside it and
consume what is here.

## Why the carrier is sliced

A certificate presenting a frame on a **finite** carrier cannot be complete. There is a
`⊡`-free ℤ-time non-validity that the landed `Formula`-side witness family already certifies and
that no finite-carrier certificate can certify. `FrameOver.ofStep` requires `[Finite W]` on the
whole carrier and is therefore unusable here.

The carrier of the frame this certificate presents is `ℤ × Fin n` — **infinite, with finite
fibres**. Limit is discharged by `TaskFrame.limit_of_succOrder` and Saturation by
`TaskFrame.saturation_of_fib_finite`, whose docstring names exactly this case. **Nothing was lost by
slicing**: the finite graph is the one-slice special case, `back = fwd = [s]` and `mid = []`, and
`onePointCertificate` below exhibits it.

## What is *not* a field, and why

`PlusSlicedCertificate` carries no `stepR`, no `stateLab`, no `witness`, no `lift` and no `trans`
field. Each absence is a decision, not an omission:

* **no `stepR`, no `stateLab`** — the edge relation and the labelling are per *slice*, so they are
  fields of `PlusSlice` and reach the certificate through the slice sequence. A carrier-wide
  relation and a carrier-wide labelling would be functions on `ℤ × Fin n`, which is infinite: not
  finite data.
* **no `witness`** — its index set would be `ℤ × Fin n`, and it is redundant given both directions
  of the liveness characterization, which is *computed* rather than demanded.
* **no `lift`** — every history of the presented frame is an offset step path of the slice sequence
  and carries its own true type sequence, so there is nothing left to demand.
* **no `trans`** — succession is the slice's own `edge`; there is no second, arrival-pruned relation
  to carry, because there is no share-class at a time to prune against.

The last two absences are what `Limits/NoCertificate.lean`'s `not_exists_plusCertifies_pumpTarget`
forces: a demanded all-threads fulfilment condition on a finite, eventually periodic presentation is
not satisfiable at `pumpTarget`, and the repair has to be structural.

## The readout, and where its default comes from

All three decodings are `Periodic.unrollOf`, which is generic over `{α} [Inhabited α]`, so the
readout lemmas of `WitnessFamily/Compression/Extract.lean` (`getD_mapC`, `getD_range_mapC`,
`readout_backC`, `readout_midC`, `readout_fwdC`, `periodic_rel_of_windowC`) are available at every
`α` used here with no change. Two `Inhabited` instances are needed and they are supplied
differently, for a reason worth stating:

* `PlusSlice n C` is inhabited **unconditionally**, by the everywhere-false edge relation with the
  empty labelling. No positivity hypothesis is required, because `edge` and `lab` are total
  functions out of `Fin n` and are definable even at `n = 0`. The slice is never read inside the
  window — the readout lemmas are what guarantee that — so its content is immaterial.
* `Finset PlusFormula × Fin n` is **not** inhabited for arbitrary `n`, since `Fin 0` is empty. A
  `PlusGraphPath n C` supplies its own default from `back_ne`: the head of its `back` segment. That
  choice is better than a positivity field, because it is automatically a *member* of the path's
  own data, which is what makes `lab_mem` below hold at every time with no case for the default.
  It also witnesses `0 < n` (`PlusGraphPath.n_pos`).

## Main Definitions

- `PlusGraphPath` — a labelled path through the carrier, as three segments of (label, state) pairs
- `PlusSlice` — one time slice: an edge relation into the next slice and a state labelling
- `PlusSlicedCertificate` — three segments of slices, a box guess, a target path and a target time
- `PlusGraphPath.lab`, `.st` — the decoded label and state functions
- `PlusSlicedCertificate.slice`, `.edge`, `.slab` — the decoded slice sequence and its accessors
- `PlusSlice.BiSerialAt`, `PlusSlicedCertificate.BiSerial`, `.BiSerialWindow`
- `PlusSlicedCertificate.BoxFaithful`, `.BoxLabelFaithful`, `.Target` — two of the checker's four
  clause groups, written here to confirm the field list rather than to assert it
- `PlusSlicedCertificate.onePointCertificate` — the finite-graph special case, exhibited

## Main Results

- `PlusGraphPath.lab_sub`, `.decoded_mem` — every decoded label is drawn from the closure, because
  every decoded datum is a member of the path's own data
- `PlusSlicedCertificate.slab_sub` — every decoded slice label is drawn from the closure
- the six decoding-region lemmas and the four periodicity lemmas
- `PlusSlicedCertificate.exists_window_eq` — every slice equals a slice at a window time, by
  residue rather than by induction
- `PlusSlicedCertificate.biSerial_iff_window` — the `∀ t` form and the window-decided form agree,
  **in both directions**
- `PlusSlicedCertificate.forall_slab_iff_window` — the box clause's `∀ t` quantifier costs the
  checker nothing
- `PlusSlicedCertificate.boxLabelFaithful_iff_window` — the same for the box-**label** clause

## Tags

plus-language · certificate · time-sliced · readout · bi-serial
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.PlusLanguage

/-! ## A list lookup in range is a member

The one generic lemma this module needs that the `Formula`-side readout layer does not already
state, because the `Formula` side never needs a decoded datum's *membership* — only its value.
-/

/-- `List.getD` at an in-range index returns a member of the list. The default is explicit, so that
no `Inhabited` instance has to be matched at the use site. -/
theorem getD_mem_of_lt {α : Type*} {l : List α} {i : ℕ} (d : α) (h : i < l.length) :
    l.getD i d ∈ l := by
  have he : l.getD i d = l[i] := by
    rw [List.getD_eq_getElem?_getD, List.getElem?_eq_getElem h]
    rfl
  rw [he]
  exact List.getElem_mem h

/-- `Periodic.cyc` on a non-empty list returns a member of it. -/
theorem cyc_mem {α : Type*} [Inhabited α] {l : List α} (hl : l ≠ []) (i : ℤ) :
    Periodic.cyc l i ∈ l := by
  have hpos : (0 : ℤ) < (l.length : ℤ) := Periodic.length_pos_int hl
  refine getD_mem_of_lt _ ?_
  have h1 : 0 ≤ i % (l.length : ℤ) := Int.emod_nonneg _ (by omega)
  have h2 : i % (l.length : ℤ) < (l.length : ℤ) := Int.emod_lt_of_pos _ hpos
  omega

/-! ## A labelled path through the carrier -/

/--
**A labelled path through the carrier.**

An eventually periodic bi-infinite sequence of (label, state) pairs, on the same three-segment
scheme a `PlusLabelledLasso` decodes. Pairing the label with the state in one object is what keeps
the certificate finite data: the state sequence and the label sequence are cut at the same
recurrence, so they decode together. The path's state component is a slice index, and the slice it
lives in is determined by the time.
-/
structure PlusGraphPath (n : ℕ) (C : Finset PlusFormula) where
  /-- Labels and states for the leftward cycle, indexed left-to-right in time. -/
  back : List (Finset PlusFormula × Fin n)
  /-- Labels and states for the finite window `[0, |mid|)`. -/
  mid : List (Finset PlusFormula × Fin n)
  /-- Labels and states for the rightward cycle, indexed left-to-right in time. -/
  fwd : List (Finset PlusFormula × Fin n)
  /-- The leftward cycle is non-empty, so leftward decoding is periodic. -/
  back_ne : back ≠ []
  /-- The rightward cycle is non-empty, so rightward decoding is periodic. -/
  fwd_ne : fwd ≠ []
  /-- Every listed label is drawn from the given closure. -/
  label_sub : ∀ X ∈ back ++ mid ++ fwd, X.1 ⊆ C

namespace PlusGraphPath

variable {n : ℕ} {C : Finset PlusFormula}

/-- **The readout's default datum**: the path's own first `back` entry.

Supplied from `back_ne` rather than from a positivity field, so that the default is automatically a
member of the path's own data. That is what makes `decoded_mem` hold at every time with no special
case, and hence what makes `lab_sub` hold with no side condition. -/
def dflt (P : PlusGraphPath n C) : Finset PlusFormula × Fin n :=
  P.back.head P.back_ne

/-- The `Inhabited` instance the readout runs at, carried explicitly because it depends on the
path. -/
@[reducible]
def inh (P : PlusGraphPath n C) : Inhabited (Finset PlusFormula × Fin n) := ⟨P.dflt⟩

/-- **A path witnesses `0 < n`.** `back` is non-empty, so it has an entry, whose state component
inhabits `Fin n`. -/
theorem n_pos (P : PlusGraphPath n C) : 0 < n :=
  lt_of_le_of_lt (Nat.zero_le _) (P.back.head P.back_ne).2.isLt

/-- The decoded bi-infinite (label, state) function. -/
def decoded (P : PlusGraphPath n C) (t : ℤ) : Finset PlusFormula × Fin n :=
  @Periodic.unrollOf _ P.inh P.back P.mid P.fwd t

/-- The decoded bi-infinite label function. -/
def lab (P : PlusGraphPath n C) (t : ℤ) : Finset PlusFormula := (P.decoded t).1

/-- The decoded bi-infinite state function. -/
def st (P : PlusGraphPath n C) (t : ℤ) : Fin n := (P.decoded t).2

/-- The backward cycle length, as an integer. -/
abbrev nb (P : PlusGraphPath n C) : ℤ := (P.back.length : ℤ)

/-- The window length, as an integer. -/
abbrev nm (P : PlusGraphPath n C) : ℤ := (P.mid.length : ℤ)

/-- The forward cycle length, as an integer. -/
abbrev nf (P : PlusGraphPath n C) : ℤ := (P.fwd.length : ℤ)

theorem nb_pos (P : PlusGraphPath n C) : 0 < P.nb := Periodic.length_pos_int P.back_ne

theorem nf_pos (P : PlusGraphPath n C) : 0 < P.nf := Periodic.length_pos_int P.fwd_ne

theorem nm_nonneg (P : PlusGraphPath n C) : 0 ≤ P.nm := Int.natCast_nonneg _

/-! ### The three decoding regions -/

/-- On the negatives the decoding is the leftward cycle. -/
theorem decoded_neg (P : PlusGraphPath n C) {t : ℤ} (ht : t < 0) :
    P.decoded t = @Periodic.cyc _ P.inh P.back t :=
  @Periodic.unrollOf_neg _ P.inh _ _ _ _ ht

/-- On the window `[0, |mid|)` the decoding reads `mid` directly. -/
theorem decoded_mid (P : PlusGraphPath n C) {t : ℤ} (h0 : 0 ≤ t) (ht : t < P.nm) :
    P.decoded t = P.mid.getD t.toNat P.dflt :=
  @Periodic.unrollOf_mid _ P.inh _ _ _ _ h0 ht

/-- At or past `|mid|` the decoding is the rightward cycle. -/
theorem decoded_fwd (P : PlusGraphPath n C) {t : ℤ} (ht : P.nm ≤ t) :
    P.decoded t = @Periodic.cyc _ P.inh P.fwd (t - P.nm) :=
  @Periodic.unrollOf_fwd _ P.inh _ _ _ _ ht

/-! ### Periodicity -/

/-- **Leftward periodicity.** Strictly left of the origin the data have period `|back|`. -/
theorem decoded_sub_nb (P : PlusGraphPath n C) {t : ℤ} (ht : t < 0) :
    P.decoded (t - P.nb) = P.decoded t :=
  @Periodic.unrollOf_sub_back_length _ P.inh _ _ _ P.back_ne _ ht

/-- **Rightward periodicity.** At or past `|mid|` the data have period `|fwd|`. -/
theorem decoded_add_nf (P : PlusGraphPath n C) {t : ℤ} (ht : P.nm ≤ t) :
    P.decoded (t + P.nf) = P.decoded t :=
  @Periodic.unrollOf_add_fwd_length _ P.inh _ _ _ P.fwd_ne _ ht

theorem lab_sub_nb (P : PlusGraphPath n C) {t : ℤ} (ht : t < 0) : P.lab (t - P.nb) = P.lab t := by
  rw [lab, lab, P.decoded_sub_nb ht]

theorem lab_add_nf (P : PlusGraphPath n C) {t : ℤ} (ht : P.nm ≤ t) :
    P.lab (t + P.nf) = P.lab t := by
  rw [lab, lab, P.decoded_add_nf ht]

theorem st_sub_nb (P : PlusGraphPath n C) {t : ℤ} (ht : t < 0) : P.st (t - P.nb) = P.st t := by
  rw [st, st, P.decoded_sub_nb ht]

theorem st_add_nf (P : PlusGraphPath n C) {t : ℤ} (ht : P.nm ≤ t) : P.st (t + P.nf) = P.st t := by
  rw [st, st, P.decoded_add_nf ht]

/-! ### Every decoded datum is a member, so every decoded label is in the closure -/

/--
**Every decoded datum is a member of the path's own data.**

The default case is not an exception: the default *is* `back.head`, a member of `back`. This is the
payoff of supplying the `Inhabited` instance from `back_ne` rather than from a positivity field.
-/
theorem decoded_mem (P : PlusGraphPath n C) (t : ℤ) : P.decoded t ∈ P.back ++ P.mid ++ P.fwd := by
  by_cases ht : t < 0
  · rw [P.decoded_neg ht]
    exact List.mem_append_left _ (List.mem_append_left _ (@cyc_mem _ P.inh _ P.back_ne t))
  · have ht' : (0 : ℤ) ≤ t := not_lt.mp ht
    by_cases htm : t < P.nm
    · have h1 : t < (P.mid.length : ℤ) := htm
      have hlt : t.toNat < P.mid.length := by omega
      rw [P.decoded_mid ht' htm]
      exact List.mem_append_left _
        (List.mem_append_right _ (getD_mem_of_lt (l := P.mid) (i := t.toNat) P.dflt hlt))
    · rw [P.decoded_fwd (not_lt.mp htm)]
      exact List.mem_append_right _ (@cyc_mem _ P.inh _ P.fwd_ne (t - P.nm))

/-- **Every decoded label is drawn from the closure**, at every time and with no side condition. -/
theorem lab_sub (P : PlusGraphPath n C) (t : ℤ) : P.lab t ⊆ C :=
  P.label_sub _ (P.decoded_mem t)

end PlusGraphPath

/-! ## One time slice -/

/--
**One time slice.**

The edge relation into the next slice, and the state labelling of this slice. The labelling is per
slice, not per state, and that is the whole amendment: a labelling per state would have to be a
function on the infinite carrier.
-/
structure PlusSlice (n : ℕ) (C : Finset PlusFormula) where
  /-- The one-step edge relation from this slice to the next. -/
  edge : Fin n → Fin n → Bool
  /-- The state labelling of this slice: the closure's atoms, `⊡`-formulas and `□`-formulas true at
  a state of this slice. -/
  lab : Fin n → Finset PlusFormula
  /-- Every slice label is drawn from the given closure. -/
  lab_sub : ∀ w, lab w ⊆ C

namespace PlusSlice

variable {n : ℕ} {C : Finset PlusFormula}

/-- **The inert slice**: no edges, empty labels. It is the readout's default and is never read
inside the window; the readout lemmas are what guarantee that. No positivity hypothesis is needed,
because `edge` and `lab` are total functions out of `Fin n` and are definable even at `n = 0`. -/
def inert (n : ℕ) (C : Finset PlusFormula) : PlusSlice n C where
  edge := fun _ _ => false
  lab := fun _ => ∅
  lab_sub := fun _ => Finset.empty_subset _

instance instInhabited : Inhabited (PlusSlice n C) := ⟨inert n C⟩

@[simp] theorem default_eq : (default : PlusSlice n C) = inert n C := rfl

/--
**Bi-seriality at one slice**: every state has an outgoing edge into the next slice, and every state
has an incoming edge from this one.

Stated at a single slice, so that extending it over all times needs only that the *slice* at an
arbitrary time equals the slice at a window time — one decoded value, not two. That is what makes
`biSerial_iff_window` a residue computation rather than an induction.
-/
def BiSerialAt (s : PlusSlice n C) : Prop :=
  (∀ w, ∃ u, s.edge w u = true) ∧ (∀ u, ∃ w, s.edge w u = true)

end PlusSlice

/-! ## The time-sliced certificate -/

/--
**The time-sliced certificate.**

Three segments of slices, decoded by the same three-segment readout `PlusGraphPath` uses,
presenting a frame on the infinite carrier `ℤ × Fin n` with finite fibres. See this module's header
for what is deliberately *not* a field here, and why. The finite-graph certificate is the special
case `back = fwd = [s]`, `mid = []`; `onePointCertificate` exhibits it.
-/
structure PlusSlicedCertificate (Γ Del : PlusContext) where
  /-- The slice width. -/
  n : ℕ
  /-- Slices are non-empty. -/
  n_pos : 0 < n
  /-- The leftward period, left-to-right in time. -/
  back : List (PlusSlice n (plusClosureOf (Γ ++ Del)))
  /-- The window `[0, |mid|)`. -/
  mid : List (PlusSlice n (plusClosureOf (Γ ++ Del)))
  /-- The rightward period, left-to-right in time. -/
  fwd : List (PlusSlice n (plusClosureOf (Γ ++ Del)))
  /-- The leftward period is non-empty, so leftward decoding is periodic. -/
  back_ne : back ≠ []
  /-- The rightward period is non-empty, so rightward decoding is periodic. -/
  fwd_ne : fwd ≠ []
  /-- The box guess. -/
  bx : PlusFormula → Bool
  /-- The target path. -/
  target : PlusGraphPath n (plusClosureOf (Γ ++ Del))
  /-- The time on the target path at which the target is read. -/
  targetTime : ℤ

namespace PlusSlicedCertificate

variable {Γ Del : PlusContext}

/-- The decoded bi-infinite slice sequence. -/
def slice (G : PlusSlicedCertificate Γ Del) (t : ℤ) :
    PlusSlice G.n (plusClosureOf (Γ ++ Del)) :=
  Periodic.unrollOf G.back G.mid G.fwd t

/-- The edge relation from slice `t` to slice `t + 1`. -/
def edge (G : PlusSlicedCertificate Γ Del) (t : ℤ) (w u : Fin G.n) : Bool :=
  (G.slice t).edge w u

/-- The state labelling of slice `t`. -/
def slab (G : PlusSlicedCertificate Γ Del) (t : ℤ) (w : Fin G.n) : Finset PlusFormula :=
  (G.slice t).lab w

/--
**Every decoded slice label is drawn from the closure.**

Free, and worth noting why: `lab_sub` is a *field* of `PlusSlice`, so every value the readout can
return — a `back`, `mid` or `fwd` entry, or the inert default — carries it already. No membership
argument is needed here, unlike `PlusGraphPath.lab_sub`, where the bound is a condition on the
list's entries rather than on each entry.
-/
theorem slab_sub (G : PlusSlicedCertificate Γ Del) (t : ℤ) (w : Fin G.n) :
    G.slab t w ⊆ plusClosureOf (Γ ++ Del) :=
  (G.slice t).lab_sub w

/-- The leftward period, as an integer. -/
abbrev nb (G : PlusSlicedCertificate Γ Del) : ℤ := (G.back.length : ℤ)

/-- The window length, as an integer. -/
abbrev nm (G : PlusSlicedCertificate Γ Del) : ℤ := (G.mid.length : ℤ)

/-- The rightward period, as an integer. -/
abbrev nf (G : PlusSlicedCertificate Γ Del) : ℤ := (G.fwd.length : ℤ)

theorem nb_pos (G : PlusSlicedCertificate Γ Del) : 0 < G.nb := Periodic.length_pos_int G.back_ne

theorem nf_pos (G : PlusSlicedCertificate Γ Del) : 0 < G.nf := Periodic.length_pos_int G.fwd_ne

theorem nm_nonneg (G : PlusSlicedCertificate Γ Del) : 0 ≤ G.nm := Int.natCast_nonneg _

/-! ### The three decoding regions -/

/-- On the negatives the slice sequence is the leftward cycle. -/
theorem slice_neg (G : PlusSlicedCertificate Γ Del) {t : ℤ} (ht : t < 0) :
    G.slice t = Periodic.cyc G.back t :=
  Periodic.unrollOf_neg _ _ _ ht

/-- On the window `[0, |mid|)` the slice sequence reads `mid` directly. -/
theorem slice_mid (G : PlusSlicedCertificate Γ Del) {t : ℤ} (h0 : 0 ≤ t) (ht : t < G.nm) :
    G.slice t = G.mid.getD t.toNat default :=
  Periodic.unrollOf_mid _ _ _ h0 ht

/-- At or past `|mid|` the slice sequence is the rightward cycle. -/
theorem slice_fwd (G : PlusSlicedCertificate Γ Del) {t : ℤ} (ht : G.nm ≤ t) :
    G.slice t = Periodic.cyc G.fwd (t - G.nm) :=
  Periodic.unrollOf_fwd _ _ _ ht

/-! ### Periodicity

These two lemmas are what make every later window decision sound: they are the slice-sequence
analogue of the fact `coherent_iff_window` plays on the `Formula` side.
-/

/-- **Leftward periodicity.** Strictly left of the origin the slice sequence has period `|back|`. -/
theorem slice_periodic_back (G : PlusSlicedCertificate Γ Del) {t : ℤ} (ht : t < 0) :
    G.slice (t - G.nb) = G.slice t :=
  Periodic.unrollOf_sub_back_length _ _ _ G.back_ne ht

/-- **Rightward periodicity.** At or past `|mid|` the slice sequence has period `|fwd|`. -/
theorem slice_periodic_fwd (G : PlusSlicedCertificate Γ Del) {t : ℤ} (ht : G.nm ≤ t) :
    G.slice (t + G.nf) = G.slice t :=
  Periodic.unrollOf_add_fwd_length _ _ _ G.fwd_ne ht

/--
**Every slice equals a slice at a window time.**

The window is `[-|back|, |mid| + |fwd|)`. Proved by *residue*, not by induction: on the negatives
the readout is `cyc back`, which reads only `t % |back|`, so `(t % |back|) - |back|` is a window
time with the same residue; at or past `|mid|` it is `cyc fwd (t - |mid|)`, so
`|mid| + (t - |mid|) % |fwd|` is a window time with the same residue. The middle region is already
inside the window.
-/
theorem exists_window_eq (G : PlusSlicedCertificate Γ Del) (t : ℤ) :
    ∃ s : ℤ, -G.nb ≤ s ∧ s < G.nm + G.nf ∧ G.slice s = G.slice t := by
  have hb := G.nb_pos
  have hf := G.nf_pos
  have hm := G.nm_nonneg
  by_cases ht : t < 0
  · have hnn : 0 ≤ t % G.nb := Int.emod_nonneg t (by omega)
    have hlt : t % G.nb < G.nb := Int.emod_lt_of_pos t hb
    refine ⟨t % G.nb - G.nb, by omega, by omega, ?_⟩
    rw [G.slice_neg (by omega : t % G.nb - G.nb < 0), G.slice_neg ht]
    refine Periodic.cyc_congr ?_
    have e : t % G.nb - G.nb = t % G.nb + (-1) * G.nb := by omega
    rw [e, Periodic.emod_add_mul, Int.emod_eq_of_lt hnn hlt]
  · by_cases htm : t < G.nm
    · exact ⟨t, by omega, by omega, rfl⟩
    · have htm' : G.nm ≤ t := not_lt.mp htm
      have hnn : 0 ≤ (t - G.nm) % G.nf := Int.emod_nonneg _ (by omega)
      have hlt : (t - G.nm) % G.nf < G.nf := Int.emod_lt_of_pos _ hf
      refine ⟨G.nm + (t - G.nm) % G.nf, by omega, by omega, ?_⟩
      rw [G.slice_fwd (by omega : G.nm ≤ G.nm + (t - G.nm) % G.nf), G.slice_fwd htm']
      refine Periodic.cyc_congr ?_
      have e : G.nm + (t - G.nm) % G.nf - G.nm = (t - G.nm) % G.nf := by omega
      rw [e, Int.emod_eq_of_lt hnn hlt]

/-! ### Bi-seriality -/

/--
**Bi-seriality**, over all times. This is the form the frame construction consumes: the presented
relation must be serial in both directions at every time, or `TaskFrame`'s Limit and Saturation
obligations cannot be discharged.
-/
def BiSerial (G : PlusSlicedCertificate Γ Del) : Prop :=
  ∀ t : ℤ, (G.slice t).BiSerialAt

/--
**Bi-seriality, decided on the window** `[-|back|, |mid| + |fwd|)`.

This is the form a checker evaluates: finitely many times, finitely many states. `Fin G.n` is a
finite type and `edge` is `Bool`-valued, so every clause under the two bounded quantifiers is
decidable.
-/
def BiSerialWindow (G : PlusSlicedCertificate Γ Del) : Prop :=
  ∀ t : ℤ, -G.nb ≤ t → t < G.nm + G.nf → (G.slice t).BiSerialAt

/--
**The window-decided form and the `∀ t` form agree.**

Both directions are proved and both are needed: `←` is what the checker needs (it evaluates the
window and concludes the condition), and `→` is what the frame construction needs (it has the
condition and reads it at an arbitrary time). The `←` direction is `exists_window_eq`; the `→`
direction is restriction.
-/
theorem biSerial_iff_window (G : PlusSlicedCertificate Γ Del) :
    G.BiSerial ↔ G.BiSerialWindow := by
  constructor
  · intro h t _ _
    exact h t
  · intro h t
    obtain ⟨s, hs1, hs2, hs3⟩ := G.exists_window_eq t
    rw [← hs3]
    exact h s hs1 hs2

/-! ### Confirming the field list: two of the checker's four clause groups

Phase 13's Scope Hypothesis asserts that the field list above is sufficient for the frame of
Phase 14, the checker of Phase 17 and the soundness proof of Phase 18. Two of the checker's four
clause groups can be written **now**, against these fields alone, and are written here: doing so is
the confirmation the Scope Hypothesis asks for, rather than an assertion that the fields will do.
Phase 17 consumes these two rather than restating them.

The other two groups — existential-from-liveness, and universal — need Phase 15's computed liveness
and are not stateable yet. What they *read* is `slice`, `edge` and `slab`, all present above and all
exercised by the two clauses below, so the confirmation covers their field dependencies even though
it cannot cover their content.

**No clause here quantifies over a time in a way that would need alignment.** The box clause ranges
over all `t` and is decided on the window by `exists_window_eq`; the target clause reads one time on
one path. The slice time is the only time there is.
-/

/--
**(C3) The box clause**, on the slice labelling.

The box guess is true of `χ` exactly when `χ` is labelled at every state of every slice. Stated with
the `∀ t` quantifier, which `exists_window_eq` reduces to the window when the checker evaluates it.
-/
def BoxFaithful (G : PlusSlicedCertificate Γ Del) : Prop :=
  ∀ χ : PlusFormula, PlusFormula.box χ ∈ plusClosureOf (Γ ++ Del) →
    (G.bx χ = true ↔ ∀ (t : ℤ) (w : Fin G.n), χ ∈ G.slab t w)

/--
**(C3b) The box-label clause**, on the slice labelling.

(C3) `BoxFaithful` constrains the box guess against the **subformula** `χ`: `G.bx χ = true` exactly
when `χ` is labelled at every state of every slice. It says nothing about where the **boxed**
formula `PlusFormula.box χ` is labelled, and in a `PlusSlice` the two are independent data. This
clause is the missing half: a slice labels `box χ` exactly when the box guess reports `χ`.

**Why it is a separate clause and not a consequence.** `PlusLocalCoherentSeqLab`'s box clause reads
`box χ ∈ lab t ↔ bx χ = true`, and nothing else in the condition set delivers it.
`Position.lean`'s `AgreesOnState` gives only `box χ ∈ X ↔ box χ ∈ G.slab t w`, because `box` is a
state shape; `LabCoherent` deliberately omits the box clause, since it is global rather than
one-step; and (C3) relates `bx` to `χ`, not to `box χ`. So a labelling read off the position graph
carries `box χ ∈ lab t ↔ box χ ∈ G.slab t (st t)` and no more, and without this clause a walk in
the timed graph cannot be read as a `LabRun` at all — whatever else the walk does.

**A genuine model satisfies it**, for the same reason it satisfies (C3): in an L⁺ model the truth of
a boxed formula is independent of both history and time (`plusBox_const`), so `box χ` belongs to the
L⁺ type at a carrier element exactly when `χ` is true everywhere, which is what `bx` is required to
report. The clause therefore narrows the certificate class only away from certificates whose slice
labelling contradicts their own box guess, and not away from any certificate a countermodel
presents.

Stated with the `∀ t` quantifier, which `exists_window_eq` reduces to the window when the checker
evaluates it — see `boxLabelFaithful_iff_window`.
-/
def BoxLabelFaithful (G : PlusSlicedCertificate Γ Del) : Prop :=
  ∀ χ : PlusFormula, PlusFormula.box χ ∈ plusClosureOf (Γ ++ Del) →
    ∀ (t : ℤ) (w : Fin G.n), (PlusFormula.box χ ∈ G.slab t w ↔ G.bx χ = true)

/-- **(C3b), decided on the window** `[-|back|, |mid| + |fwd|)`: the form a checker evaluates. -/
def BoxLabelFaithfulWindow (G : PlusSlicedCertificate Γ Del) : Prop :=
  ∀ χ : PlusFormula, PlusFormula.box χ ∈ plusClosureOf (Γ ++ Del) →
    ∀ t : ℤ, -G.nb ≤ t → t < G.nm + G.nf → ∀ w : Fin G.n,
      (PlusFormula.box χ ∈ G.slab t w ↔ G.bx χ = true)

/--
**(C4) The target clause**, on the target path.

Every premise is labelled at the target time and no conclusion is. Read on `target.lab` rather than
on `slab`, because the target is read along one path at one time, not across a slice.
-/
def Target (G : PlusSlicedCertificate Γ Del) : Prop :=
  (∀ γ ∈ Γ, γ ∈ G.target.lab G.targetTime) ∧ (∀ σ ∈ Del, σ ∉ G.target.lab G.targetTime)

/--
**The box clause is decided on the window.**

The reduction `exists_window_eq` licenses, stated here because it is the clause-level form Phase 17
evaluates and because proving it now is what shows the `∀ t` quantifier in `BoxFaithful` costs the
checker nothing.
-/
theorem forall_slab_iff_window (G : PlusSlicedCertificate Γ Del) (χ : PlusFormula) :
    (∀ (t : ℤ) (w : Fin G.n), χ ∈ G.slab t w) ↔
      (∀ t : ℤ, -G.nb ≤ t → t < G.nm + G.nf → ∀ w : Fin G.n, χ ∈ G.slab t w) := by
  constructor
  · intro h t _ _ w
    exact h t w
  · intro h t w
    obtain ⟨s, hs1, hs2, hs3⟩ := G.exists_window_eq t
    have : G.slab t w = G.slab s w := by rw [slab, slab, hs3]
    rw [this]
    exact h s hs1 hs2 w

/--
**The box-label clause is decided on the window**, by the same residue reduction as (C3).

Both directions, as `biSerial_iff_window` has both and for the same two consumers: `←` is what a
checker needs, and `→` is what a soundness proof needs when it reads the clause at an arbitrary
time.
-/
theorem boxLabelFaithful_iff_window (G : PlusSlicedCertificate Γ Del) :
    G.BoxLabelFaithful ↔ G.BoxLabelFaithfulWindow := by
  constructor
  · intro h χ hχ t _ _ w
    exact h χ hχ t w
  · intro h χ hχ t w
    obtain ⟨s, hs1, hs2, hs3⟩ := G.exists_window_eq t
    have hslab : G.slab t w = G.slab s w := by rw [slab, slab, hs3]
    rw [hslab]
    exact h χ hχ s hs1 hs2 w

/-! ### The finite graph is the one-slice special case

Nothing was lost by slicing, and this is the declaration that says so rather than asserting it: a
certificate whose `back` and `fwd` are the same single slice and whose `mid` is empty presents
exactly a finite graph, repeated at every time.
-/

/--
**The one-slice certificate.** `back = fwd = [s]`, `mid = []`: the finite-graph certificate,
recovered as a special case. `slice_onePointCertificate` below confirms that its slice sequence is
constant.
-/
def onePointCertificate (Γ Del : PlusContext) {n : ℕ} (hn : 0 < n)
    (s : PlusSlice n (plusClosureOf (Γ ++ Del))) (bx : PlusFormula → Bool)
    (target : PlusGraphPath n (plusClosureOf (Γ ++ Del))) (targetTime : ℤ) :
    PlusSlicedCertificate Γ Del where
  n := n
  n_pos := hn
  back := [s]
  mid := []
  fwd := [s]
  back_ne := List.cons_ne_nil _ _
  fwd_ne := List.cons_ne_nil _ _
  bx := bx
  target := target
  targetTime := targetTime

/-- **The one-slice certificate's slice sequence is constant.** This is the sense in which the
finite graph is a special case and not merely an analogy. -/
theorem slice_onePointCertificate (Γ Del : PlusContext) {n : ℕ} (hn : 0 < n)
    (s : PlusSlice n (plusClosureOf (Γ ++ Del))) (bx : PlusFormula → Bool)
    (target : PlusGraphPath n (plusClosureOf (Γ ++ Del))) (targetTime : ℤ) (t : ℤ) :
    (onePointCertificate Γ Del hn s bx target targetTime).slice t = s := by
  have hone : ∀ i : ℤ, Periodic.cyc [s] i = s := by
    intro i
    have hlen : (([s] : List (PlusSlice n (plusClosureOf (Γ ++ Del)))).length : ℤ) = 1 := by simp
    unfold Periodic.cyc
    rw [hlen, Int.emod_one]
    rfl
  have hnm : (onePointCertificate Γ Del hn s bx target targetTime).nm = 0 := by
    simp [onePointCertificate]
  by_cases ht : t < 0
  · rw [slice_neg _ ht]
    exact hone t
  · rw [slice_fwd _ (by rw [hnm]; exact not_lt.mp ht)]
    exact hone _

end PlusSlicedCertificate

end FormalSystem.Metalogic.Decidability
