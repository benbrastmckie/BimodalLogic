/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SubBracket2V
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.NavigatedSpine

/-! # Shared-Interior-Witness Joint Carrier — slots and zone constants

Module A of the `SharedWitness` tower. Outer and inner zone constants (Rabinovich 2014,
"A Proof of Kamp's Theorem", Def 3.1, PDF pp.2-3), the tagged joint slot type and its
per-slot `Fin N` families, and the positive-interior selectors `kvE2_sepPos` /
`kvE2_sepPosI` / `kvE2_sepPosI_mem`.

Leaf of the tower: imports only `SubBracket2V` and `NavigatedSpine`. -/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.WeakCanonical.Separation
  (nf_depth0_char_formula nf_depth0_char_formula_correct
   formula_conjList formula_conjList_iff)

/-- `ZoneSpec n` equality is decidable (a function over `Fin n` into `Bool × Bool`); the
    type synonym is a plain `def`, so instance search needs this explicit private bridge
    (file-local; nothing downstream sees it). -/
private instance {n : Nat} : DecidableEq (ZoneSpec n) :=
  -- `inferInstanceAs`, not `decidable_of_iff (∀ i, a i = b i) …`: the latter needs
  -- `Decidable (∀ i : Fin n, a i = b i)`, and synthesising that requires seeing `a i` as a
  -- function application, which in turn requires unfolding the semireducible `ZoneSpec` — an
  -- unfolding instance search will not perform. Naming the unfolded type directly sidesteps it.
  inferInstanceAs (DecidableEq (Fin n → Bool × Bool))

/-! ## Outer zone constants (Def 3.1, PDF pp.2-3 — the fresh `x1` relative to `[w,x,t]`)

Coordinates of the depth-2 env: `0 ↦ w`, `1 ↦ x`, `2 ↦ t`. Seven consistent zones under the
bracket order `x < w < t`, INCLUDING the shared-witness self-zone `zAtW3` (nine-zone lesson
one level up: the honest joint gate must admit the witness self-zone or it is unsatisfiable). -/

/-- `x1 < x` — exterior past (Prop 3.5 `Since` navigation at the left endpoint). -/
def kvE2_sep_zPastX3 : ZoneSpec 3 :=
  Fin.cons (true, false) (Fin.cons (true, false) (fun _ => (true, false)))

/-- `x1 = x` — left-endpoint boundary. -/
def kvE2_sep_zAtX3 : ZoneSpec 3 :=
  Fin.cons (true, false) (Fin.cons (false, false) (fun _ => (true, false)))

/-- `x < x1 < w` — LEFT interior (the class the landed per-σ kit serves). -/
def kvE2_sep_zXW3 : ZoneSpec 3 :=
  Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false)))

/-- `x1 = w` — shared-witness self-zone (rides the `ptW` slot literal). -/
def kvE2_sep_zAtW3 : ZoneSpec 3 :=
  Fin.cons (false, false) (Fin.cons (false, true) (fun _ => (true, false)))

/-- `w < x1 < t` — RIGHT interior (mirrored slot group). -/
def kvE2_sep_zWT3 : ZoneSpec 3 :=
  Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (true, false)))

/-- `x1 = t` — right-endpoint boundary. -/
def kvE2_sep_zAtT3 : ZoneSpec 3 :=
  Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, false)))

/-- `t < x1` — exterior future (Prop 3.5 `Until` navigation at the right endpoint). -/
def kvE2_sep_zFutT3 : ZoneSpec 3 :=
  Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, true)))

/-! ## Inner zone constants (Def 3.1, PDF pp.2-3 — a 1-type point `v` relative to `[x1,w,x,t]`)

The three interior patterns `kvE_sub2_zXU`/`kvE_sub2_zUW`/`kvE_sub2_zWT`
(`SubBracket2.lean:123-133`) are CONSUMED, not rebuilt. The bit patterns are
placement-generic: for a LEFT-interior σ (`x < x1 < w`) the pattern `kvE_sub2_zXU` reads
"`x < v < x1`" and `kvE_sub2_zWT` reads "`w < v < t`"; for a RIGHT-interior σ
(`w < x1 < t`) the SAME pattern `kvE_sub2_zXU` reads "`x < v < w`" and `kvE_sub2_zWT`
reads "`x1 < v < t`". Only the right-interior middle region and the self/boundary zones
need fresh constants. -/

/-- Right-interior middle region `w < v < x1` (for σ with `w < x1`). -/
def kvE2_sep_zWX1 : ZoneSpec 4 :=
  Fin.cons (true, false) (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (true, false))))

/-- Left-interior fresh-witness self-zone `v = x1` (with `x1 < w`); defeq to
    `kvE_subBracket2V`'s internal `zAtX1` (`SubBracket2V.lean:165`). -/
def kvE2_sep_zAtX1L : ZoneSpec 4 :=
  Fin.cons (false, false) (Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false))))

/-- Left-interior shared-witness self-zone `v = w` (with `x1 < w`); defeq to
    `kvE_subBracket2V`'s internal `zAtW` (`SubBracket2V.lean:166`). -/
def kvE2_sep_zAtWL : ZoneSpec 4 :=
  Fin.cons (false, true) (Fin.cons (false, false) (Fin.cons (false, true) (fun _ => (true, false))))

/-- Right-interior fresh-witness self-zone `v = x1` (with `w < x1`). -/
def kvE2_sep_zAtX1R : ZoneSpec 4 :=
  Fin.cons (false, false) (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (true, false))))

/-- Right-interior shared-witness self-zone `v = w` (with `w < x1`). -/
def kvE2_sep_zAtWR : ZoneSpec 4 :=
  Fin.cons (true, false) (Fin.cons (false, false) (Fin.cons (false, true) (fun _ => (true, false))))

/-- Exterior past `v < x` (placement-generic bits: `v` below every env point). -/
def kvE2_sep_zPastX4 : ZoneSpec 4 :=
  Fin.cons (true, false) (Fin.cons (true, false) (Fin.cons (true, false) (fun _ => (true, false))))

/-- Left-endpoint boundary `v = x` (placement-generic for both interior classes). -/
def kvE2_sep_zAtX4 : ZoneSpec 4 :=
  Fin.cons (true, false) (Fin.cons (true, false) (Fin.cons (false, false) (fun _ => (true, false))))

/-- Right-endpoint boundary `v = t` (placement-generic). -/
def kvE2_sep_zAtT4 : ZoneSpec 4 :=
  Fin.cons (false, true) (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, false))))

/-- Exterior future `t < v` (placement-generic). -/
def kvE2_sep_zFutT4 : ZoneSpec 4 :=
  Fin.cons (false, true) (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, true))))

/-! ## Per-σ fold-bit reads and formula pieces (top-level, per the crux failed-closer-3
lesson: NO `let`-buried internals — `rw`/`rfl` must see through every name) -/

/-- Sub-level fold-bit read (Def 4.1, PDF p.5): `σ.2 ∘ nf0_assemble` at gate instance
    `j = 0`, the same consume-do-not-rebuild read as `kvE_subBracket2V`
    (`SubBracket2V.lean:145-146`), exposed at top level. -/
def kvE2_sepBits {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) (zs : ZoneSpec 4) (χ : NormalForm sig 0 1) : Bool :=
  σ.2 (nf0_assemble zs χ σ.1)

/-- Depth-0 coordinate projection of a σ's arity-4 base (Def 3.1 point-type channel;
    the arity-4 analog of `nf_x_proj3`/`nf_t_proj3`, top-level clone of
    `kvE_subBracket2V`'s internal `proj`). -/
def kvE2_sepProj4 {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) (k : Fin 4) : NormalForm sig 0 1 :=
  fun a => match a with
    | .pred p _ => σ.1 (.pred p k)
    | .order i j h => absurd (Subsingleton.elim i j) h

/-- Depth-0 coordinate projection of the joint arity-3 base `qnf.1` (env `[w,x,t]`). -/
def kvE2_sepProj3 {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (r : NormalForm sig 0 3) (k : Fin 3) : NormalForm sig 0 1 :=
  fun a => match a with
    | .pred p _ => r (.pred p k)
    | .order i j h => absurd (Subsingleton.elim i j) h

/-- Biconditional literal at an anchor (Prop 3.5 folding mechanism, PDF p.5). -/
def kvE2_sepLit (bit : Bool) (f : Formula) : Formula :=
  if bit then f else f.neg

/-- Interior-positive 1-type enumeration for σ at zone pattern `zs`
    (duplicate-free `Finset.univ.toList`, Fintype `NormalForm.lean:167-178`). -/
noncomputable def kvE2_sepS {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) (zs : ZoneSpec 4) : List (NormalForm sig 0 1) :=
  (Finset.univ.toList : List (NormalForm sig 0 1)).filter (fun χ => kvE2_sepBits σ zs χ)

/-- σ's exclusion segment content at zone pattern `zs` (Cor 5.4, PDF p.5: real
    per-region exclusion, never a constant tri-zone). -/
noncomputable def kvE2_sepSegForm {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (σ : NormalForm sig 1 4) (zs : ZoneSpec 4) : Formula :=
  formula_conjList ((Finset.univ.toList : List (NormalForm sig 0 1)).map fun χ =>
    if kvE2_sepBits σ zs χ then Formula.top else (charBase χ).neg)

/-! ## Outer enumeration: positive subs and their placement classes -/

/-- Positive subs of the depth-2 quant layer (Fintype enumeration, duplicate-free). -/
noncomputable def kvE2_sepPos {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) : List (NormalForm sig 1 4) :=
  (Finset.univ.toList : List (NormalForm sig 1 4)).filter (fun σ => qnf.2 σ)

/-- Positive subs in outer placement class `zs` (classified by the σ's own order bits —
    model-independent; the quarantined enumeration device reused as a pattern only). -/
noncomputable def kvE2_sepPosIn {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (zs : ZoneSpec 3) : List (NormalForm sig 1 4) :=
  (kvE2_sepPos qnf).filter (fun σ => decide (nf0_zoneSpec σ.1 = zs))

/-- **Interior-restricted owner index**. The positive subs whose fresh
    point `x1` lies in one of the two INTERIOR outer zones (`x < x1 < w`, `w < x1 < t`).
    Rabinovich §5 (p.7) ψ0/ψ1/φ split: interiority is a construction invariant of φ — the
    interleaving index ranges over bracket witnesses only — never a hypothesis on realized
    types. A SINGLE two-zone order-preserving filter of `kvE2_sepPos` (the `kvE2_sepPosIn`
    pattern), so global enumeration order, `Nodup`, and the `zipIdx`/membership transfer
    machinery are inherited; a member's interiority is recovered definitionally via
    `List.mem_filter` (`kvE2_sepPosI_mem`), never hypothesized. -/
noncomputable def kvE2_sepPosI {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) : List (NormalForm sig 1 4) :=
  (kvE2_sepPos qnf).filter
    (fun σ => decide (nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3))

/-- Membership in the interior index = positivity + the interiority disjunction. -/
theorem kvE2_sepPosI_mem {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3)
    (σ : NormalForm sig 1 4) :
    σ ∈ kvE2_sepPosI qnf ↔ σ ∈ kvE2_sepPos qnf ∧
      (nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3) := by
  simp [kvE2_sepPosI, List.mem_filter]

/-- Interior owners are positive owners. -/
theorem kvE2_sepPosI_subset {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {qnf : NormalForm sig 2 3}
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPosI qnf) : σ ∈ kvE2_sepPos qnf :=
  ((kvE2_sepPosI_mem qnf σ).mp hσ).1

/-- Interior owners are interior (the definitional recovery of the interiority
    disjunction — this replaces, and never resurrects, any interiority hypothesis). -/
theorem kvE2_sepPosI_zone {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {qnf : NormalForm sig 2 3}
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPosI qnf) :
    nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3 :=
  ((kvE2_sepPosI_mem qnf σ).mp hσ).2

/-- The interior index is duplicate-free: filtering preserves the `kvE2_sepPos` `Nodup`
    fact (itself a filter of the duplicate-free `Finset.univ.toList`; the file's private
    `kvE2_sepPos_nodup` states the intermediate step). -/
theorem kvE2_sepPosI_nodup {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) :
    (kvE2_sepPosI qnf).Nodup :=
  ((Finset.nodup_toList _).filter _ : (kvE2_sepPos qnf).Nodup).filter _

/-- Whether some positive sub in outer class `zs` has fresh depth-1 projection `χ`
    (the σ-level literal driver for the five non-interior endpoint literals). -/
noncomputable def kvE2_sepHasPos {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (zs : ZoneSpec 3) (χ : NormalForm sig 1 1) : Bool :=
  (kvE2_sepPosIn qnf zs).any (fun σ => decide (nfk_projFresh σ = χ))

/-! ## Tagged joint slots (Lemma 3.2(1) interleaving carriers)

Each slot records WHICH positive interior σ it belongs to and which of σ's regions it
realizes, so the refined segment computation and the later extraction phases can read the
arrangement structurally. Point types remain quantifier-free/E[Σ]-atom (Lemma 5.1, PDF p.3). -/

/-- A joint bracket slot: `l*` constructors belong to a LEFT-interior σ (`x < x1 < w`),
    `r*` constructors to a RIGHT-interior σ (`w < x1 < t`). `lXU`/`lUW`/`lWT` are σ's
    interior-positive 1-type slots in `(x,x1)`/`(x1,w)`/`(w,t)`; `rXW`/`rWX1`/`rX1T` in
    `(x,w)`/`(w,x1)`/`(x1,t)`; `lX1`/`rX1` are σ's fresh-witness E[Σ]-atom slots. -/
inductive KvE2SepSlot (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds] where
  | lXU (σ : NormalForm sig 1 4) (χ : NormalForm sig 0 1)
  | lX1 (σ : NormalForm sig 1 4)
  | lUW (σ : NormalForm sig 1 4) (χ : NormalForm sig 0 1)
  | lWT (σ : NormalForm sig 1 4) (χ : NormalForm sig 0 1)
  | rXW (σ : NormalForm sig 1 4) (χ : NormalForm sig 0 1)
  | rWX1 (σ : NormalForm sig 1 4) (χ : NormalForm sig 0 1)
  | rX1 (σ : NormalForm sig 1 4)
  | rX1T (σ : NormalForm sig 1 4) (χ : NormalForm sig 0 1)
deriving DecidableEq

/-- The owning positive sub of a slot. -/
def kvE2_sepSlotSub {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] :
    KvE2SepSlot sig → NormalForm sig 1 4
  | .lXU σ _ => σ
  | .lX1 σ => σ
  | .lUW σ _ => σ
  | .lWT σ _ => σ
  | .rXW σ _ => σ
  | .rWX1 σ _ => σ
  | .rX1 σ => σ
  | .rX1T σ _ => σ

/-- Region rank of a slot WITHIN its list (left list for `lXU`/`lX1`/`lUW`/`rXW`, right
    list for `lWT`/`rWX1`/`rX1`/`rX1T`): a valid arrangement keeps each σ's slots in
    non-decreasing rank order (`XU* < x1 < UW*` on the left; `WX1* < x1 < X1T*` on the
    right; single-region slot kinds are rank-constant, hence internally free). -/
def kvE2_sepSlotRank {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] :
    KvE2SepSlot sig → Nat
  | .lXU _ _ => 0
  | .lX1 _ => 1
  | .lUW _ _ => 2
  | .lWT _ _ => 0
  | .rXW _ _ => 0
  | .rWX1 _ _ => 0
  | .rX1 _ => 1
  | .rX1T _ _ => 2

/-- Left-interior fresh-witness point type: the `charK (nfk_projFresh σ)` E[Σ]-atom head
    (Lemma 5.1, PDF p.3 — an atom typing its OWN point only; no-nesting) PLUS σ's `zAtX1`
    self-zone literals (nine-zone lesson, `SubBracket2V.lean:207-215` pattern). -/
noncomputable def kvE2_sepPtX1L {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4) : TemporalPred :=
  ⟨formula_conjList
    (charK (nfk_projFresh σ)
      :: (Finset.univ.toList : List (NormalForm sig 0 1)).map fun χ =>
          kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zAtX1L χ) (charBase χ))⟩

/-- Right-interior fresh-witness point type (mirrored self-zone `kvE2_sep_zAtX1R`). -/
noncomputable def kvE2_sepPtX1R {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4) : TemporalPred :=
  ⟨formula_conjList
    (charK (nfk_projFresh σ)
      :: (Finset.univ.toList : List (NormalForm sig 0 1)).map fun χ =>
          kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zAtX1R χ) (charBase χ))⟩

/-- Point type of a slot: `charBase χ` for 1-type slots, the folded `charK` E[Σ]-atom
    point type for fresh-witness slots (Lemma 5.1 quantifier-free/E[Σ]-atom discipline). -/
noncomputable def kvE2_sepSlotType {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula) :
    KvE2SepSlot sig → TemporalPred
  | .lXU _ χ => ⟨charBase χ⟩
  | .lX1 σ => kvE2_sepPtX1L charBase charK σ
  | .lUW _ χ => ⟨charBase χ⟩
  | .lWT _ χ => ⟨charBase χ⟩
  | .rXW _ χ => ⟨charBase χ⟩
  | .rWX1 _ χ => ⟨charBase χ⟩
  | .rX1 σ => kvE2_sepPtX1R charBase charK σ
  | .rX1T _ χ => ⟨charBase χ⟩

/-- σ's canonical LEFT-region slot block: for a left-interior σ its `(x,x1)` types, the
    fresh slot, then its `(x1,w)` types; for a right-interior σ its `(x,w)` types (read
    through the placement-generic `kvE_sub2_zXU` bit pattern); empty otherwise. -/
noncomputable def kvE2_sepSlotsLFor {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) : List (KvE2SepSlot sig) :=
  if nf0_zoneSpec σ.1 = kvE2_sep_zXW3 then
    (kvE2_sepS σ kvE_sub2_zXU).map (.lXU σ)
      ++ .lX1 σ :: (kvE2_sepS σ kvE_sub2_zUW).map (.lUW σ)
  else if nf0_zoneSpec σ.1 = kvE2_sep_zWT3 then
    (kvE2_sepS σ kvE_sub2_zXU).map (.rXW σ)
  else []

/-- σ's canonical RIGHT-region slot block: for a left-interior σ its `(w,t)` types; for a
    right-interior σ its `(w,x1)` types, the fresh slot, then its `(x1,t)` types (read
    through the placement-generic `kvE_sub2_zWT` bit pattern); empty otherwise. -/
noncomputable def kvE2_sepSlotsRFor {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) : List (KvE2SepSlot sig) :=
  if nf0_zoneSpec σ.1 = kvE2_sep_zXW3 then
    (kvE2_sepS σ kvE_sub2_zWT).map (.lWT σ)
  else if nf0_zoneSpec σ.1 = kvE2_sep_zWT3 then
    (kvE2_sepS σ kvE2_sep_zWX1).map (.rWX1 σ)
      ++ .rX1 σ :: (kvE2_sepS σ kvE_sub2_zWT).map (.rX1T σ)
  else []

/-- Canonical joint LEFT slot list: the union over all positive subs (Lemma 3.2(1) —
    the conjunction's witness multiset between `x` and the shared `w`).
    Deliberate: stays mapping over `kvE2_sepPos`, NOT `kvE2_sepPosI` —
    semantically equivalent since non-interior owners contribute `[]`
    (`kvE2_sepPosI_flatMap_slotsLFor`); report 07 sanctions either anchor and the
    conservative diff is smaller. -/
noncomputable def kvE2_sepSlotsL {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) : List (KvE2SepSlot sig) :=
  (kvE2_sepPos qnf).flatMap kvE2_sepSlotsLFor

/-- Canonical joint RIGHT slot list (between the shared `w` and `t`). Stays over
    `kvE2_sepPos` (see `kvE2_sepSlotsL` — deliberate choice). -/
noncomputable def kvE2_sepSlotsR {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) : List (KvE2SepSlot sig) :=
  (kvE2_sepPos qnf).flatMap kvE2_sepSlotsRFor

/-! ## Foundation — the full per-individual-slot family (`Fin N`)

Model-independent scaffolding for the per-slot value-rank carrier (plan Phase 6: "the FULL slot
family `Fin N`"; handoff step (1): "slotIndexOf/positionOf, model-independent, from
`kvE2_sepSlotsLFor ++ kvE2_sepSlotsRFor`"). `kvE2_sepSlotBlock σ` is σ's canonical individual-slot
block (its LEFT then RIGHT region slots); `kvE2_sepAllSlots qnf` is the full cross-owner slot family
whose length is `N` (total base+anchor slots). `kvE2_sepAllSlots_nodup` (the load-bearing
distinctness fact) makes `kvE2_sepSlotIndexOf` a genuine embedding into `[0, N)`, so a value family
`G j = (value_j, j)` over `Fin N` is injective (feeds `kvE2_ordRank_injective`, Phase 6). Every
component is a syntactic filter of `σ` — no `M` appears (F4/F5/LITMUS clean; per gate report 09 the
per-owner slot list stays model-independent). Rabinovich Def 3.1: the witness is a strict chain of
INDIVIDUAL points, so the carrier ranges over per-individual-slot positions, not owner-region
ranks. -/

/-- σ's canonical per-individual-slot block: its LEFT region slots followed by its RIGHT region
    slots (variable arity — the per-slot granularity Rabinovich Def 3.1 requires, replacing the
    fixed 3-arity owner-region tuple this refinement removes). -/
noncomputable def kvE2_sepSlotBlock {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) : List (KvE2SepSlot sig) :=
  kvE2_sepSlotsLFor σ ++ kvE2_sepSlotsRFor σ

/-- The full cross-owner individual-slot family (length `N` = total base+anchor slots across all
    positive owners). The `Fin N` domain of the per-slot value-rank family `G` (Phase 6).
    Re-anchored to flatMap over the interior index `kvE2_sepPosI` — the
    VALUE is unchanged (`kvE2_sepAllSlots_eq_pos`; non-interior owners contribute empty
    blocks), but the enumeration now ranges over bracket witnesses only, matching the
    Rabinovich §5 (p.7) interleaving-index scope. NOT defeq to the old body — proofs that
    decomposed the family over `kvE2_sepPos` repair by the one rewrite
    `kvE2_sepAllSlots_eq_pos`. -/
noncomputable def kvE2_sepAllSlots {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) : List (KvE2SepSlot sig) :=
  (kvE2_sepPosI qnf).flatMap kvE2_sepSlotBlock

/-- **Global per-individual-slot position** (Phase 6 `slotIndexOf`): the 0-based index of slot `s`
    in the full slot family. When `kvE2_sepAllSlots` is `Nodup` (see `kvE2_sepAllSlots_nodup`) this
    is a genuine injection on the family's members — the structural (model-independent) index the
    lex value-rank family `G` uses in its second coordinate. -/
noncomputable def kvE2_sepSlotIndexOf {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (s : KvE2SepSlot sig) : ℕ :=
  (kvE2_sepAllSlots qnf).idxOf s

/-- Block membership splits over the two region blocks. -/
theorem kvE2_sepMem_slotBlock {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4)
    (s : KvE2SepSlot sig) :
    s ∈ kvE2_sepSlotBlock σ ↔ s ∈ kvE2_sepSlotsLFor σ ∨ s ∈ kvE2_sepSlotsRFor σ := by
  rw [kvE2_sepSlotBlock, List.mem_append]

/-! ### Interior-index transfer foundation

Non-interior owners contribute EMPTY slot blocks (the `else []` branches of
`kvE2_sepSlotsLFor`/`kvE2_sepSlotsRFor`), so flatMapping any slot-family builder over the
interior index `kvE2_sepPosI` yields the SAME VALUE as over the full `kvE2_sepPos`. The
equality is provable, not definitional — the `kvE2_sepPosI_flatMap_*` lemmas below are the
one-rewrite repair tool for the re-anchoring phases. -/

/-- Non-interior owners have no LEFT-region slots (the `else []` branch). -/
theorem kvE2_sepSlotsLFor_eq_nil {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {σ : NormalForm sig 1 4}
    (h1 : nf0_zoneSpec σ.1 ≠ kvE2_sep_zXW3) (h2 : nf0_zoneSpec σ.1 ≠ kvE2_sep_zWT3) :
    kvE2_sepSlotsLFor σ = [] := by
  rw [kvE2_sepSlotsLFor, if_neg h1, if_neg h2]

/-- Non-interior owners have no RIGHT-region slots (the `else []` branch). -/
theorem kvE2_sepSlotsRFor_eq_nil {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {σ : NormalForm sig 1 4}
    (h1 : nf0_zoneSpec σ.1 ≠ kvE2_sep_zXW3) (h2 : nf0_zoneSpec σ.1 ≠ kvE2_sep_zWT3) :
    kvE2_sepSlotsRFor σ = [] := by
  rw [kvE2_sepSlotsRFor, if_neg h1, if_neg h2]

/-- Non-interior owners have an empty slot block. -/
theorem kvE2_sepSlotBlock_eq_nil {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {σ : NormalForm sig 1 4}
    (h1 : nf0_zoneSpec σ.1 ≠ kvE2_sep_zXW3) (h2 : nf0_zoneSpec σ.1 ≠ kvE2_sep_zWT3) :
    kvE2_sepSlotBlock σ = [] := by
  rw [kvE2_sepSlotBlock, kvE2_sepSlotsLFor_eq_nil h1 h2, kvE2_sepSlotsRFor_eq_nil h1 h2]
  rfl

/-- A nonempty LEFT block forces interiority: a positive owner exhibiting a LEFT-region
    slot is a member of the interior index (contrapositive of the `else []` branches). -/
theorem kvE2_sepMem_posI_of_slotL {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {qnf : NormalForm sig 2 3}
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf)
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2_sepSlotsLFor σ) :
    σ ∈ kvE2_sepPosI qnf := by
  refine (kvE2_sepPosI_mem qnf σ).mpr ⟨hσ, ?_⟩
  by_cases h1 : nf0_zoneSpec σ.1 = kvE2_sep_zXW3
  · exact Or.inl h1
  · by_cases h2 : nf0_zoneSpec σ.1 = kvE2_sep_zWT3
    · exact Or.inr h2
    · rw [kvE2_sepSlotsLFor_eq_nil h1 h2] at hs
      simp at hs

/-- A nonempty RIGHT block forces interiority. -/
theorem kvE2_sepMem_posI_of_slotR {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {qnf : NormalForm sig 2 3}
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf)
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2_sepSlotsRFor σ) :
    σ ∈ kvE2_sepPosI qnf := by
  refine (kvE2_sepPosI_mem qnf σ).mpr ⟨hσ, ?_⟩
  by_cases h1 : nf0_zoneSpec σ.1 = kvE2_sep_zXW3
  · exact Or.inl h1
  · by_cases h2 : nf0_zoneSpec σ.1 = kvE2_sep_zWT3
    · exact Or.inr h2
    · rw [kvE2_sepSlotsRFor_eq_nil h1 h2] at hs
      simp at hs

/-- A nonempty slot block forces interiority: the converse membership route by which any
    consumer holding only `σ ∈ kvE2_sepPos` plus a slot recovers `σ ∈ kvE2_sepPosI`. -/
theorem kvE2_sepMem_posI_of_slot {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {qnf : NormalForm sig 2 3}
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf)
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2_sepSlotBlock σ) :
    σ ∈ kvE2_sepPosI qnf := by
  rcases (kvE2_sepMem_slotBlock σ s).mp hs with h | h
  · exact kvE2_sepMem_posI_of_slotL hσ h
  · exact kvE2_sepMem_posI_of_slotR hσ h

/-- Generic transfer engine: flatMapping over a filtered list equals flatMapping over the
    whole list when the function vanishes off the predicate. -/
private theorem kvE2_sep_flatMap_filter_of_vanish {α β : Type _} {p : α → Bool}
    (f : α → List β) (l : List α) (h : ∀ a ∈ l, p a = false → f a = []) :
    (l.filter p).flatMap f = l.flatMap f := by
  induction l with
  | nil => rfl
  | cons a l ih =>
    cases hp : p a with
    | true =>
      rw [List.filter_cons_of_pos hp, List.flatMap_cons, List.flatMap_cons,
        ih (fun x hx hpx => h x (List.mem_cons_of_mem a hx) hpx)]
    | false =>
      rw [List.filter_cons_of_neg (by simp [hp]), List.flatMap_cons,
        h a (List.mem_cons_self ..) hp, List.nil_append,
        ih (fun x hx hpx => h x (List.mem_cons_of_mem a hx) hpx)]

/-- **Key value-transfer lemma**: the full slot family over the interior
    index has the SAME VALUE as over all positive owners — non-interior owners contribute
    empty blocks. Not defeq: re-anchoring phases repair broken `rfl`/unfold proofs by this
    one rewrite. -/
theorem kvE2_sepPosI_flatMap_slotBlock {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] (qnf : NormalForm sig 2 3) :
    (kvE2_sepPosI qnf).flatMap kvE2_sepSlotBlock
      = (kvE2_sepPos qnf).flatMap kvE2_sepSlotBlock := by
  rw [kvE2_sepPosI]
  refine kvE2_sep_flatMap_filter_of_vanish _ _ (fun σ _ hp => ?_)
  rw [decide_eq_false_iff_not, not_or] at hp
  exact kvE2_sepSlotBlock_eq_nil hp.1 hp.2

/-- LEFT-region value transfer: `kvE2_sepSlotsL`-shaped flatMaps re-anchor by one rewrite. -/
theorem kvE2_sepPosI_flatMap_slotsLFor {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] (qnf : NormalForm sig 2 3) :
    (kvE2_sepPosI qnf).flatMap kvE2_sepSlotsLFor
      = (kvE2_sepPos qnf).flatMap kvE2_sepSlotsLFor := by
  rw [kvE2_sepPosI]
  refine kvE2_sep_flatMap_filter_of_vanish _ _ (fun σ _ hp => ?_)
  rw [decide_eq_false_iff_not, not_or] at hp
  exact kvE2_sepSlotsLFor_eq_nil hp.1 hp.2

/-- RIGHT-region value transfer. -/
theorem kvE2_sepPosI_flatMap_slotsRFor {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] (qnf : NormalForm sig 2 3) :
    (kvE2_sepPosI qnf).flatMap kvE2_sepSlotsRFor
      = (kvE2_sepPos qnf).flatMap kvE2_sepSlotsRFor := by
  rw [kvE2_sepPosI]
  refine kvE2_sep_flatMap_filter_of_vanish _ _ (fun σ _ hp => ?_)
  rw [decide_eq_false_iff_not, not_or] at hp
  exact kvE2_sepSlotsRFor_eq_nil hp.1 hp.2

/-- **Universal re-anchoring repair tool**: the re-anchored slot family
    has the SAME VALUE as the old full-`kvE2_sepPos` flatMap. Every proof that decomposed
    `kvE2_sepAllSlots` over the full positive-owner list repairs by this one rewrite. -/
theorem kvE2_sepAllSlots_eq_pos {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] (qnf : NormalForm sig 2 3) :
    kvE2_sepAllSlots qnf = (kvE2_sepPos qnf).flatMap kvE2_sepSlotBlock := by
  rw [kvE2_sepAllSlots, kvE2_sepPosI_flatMap_slotBlock]

/-- A slot of a positive owner's block is a member of the full slot family. The hypothesis
    stays over `kvE2_sepPos` (existing call sites compile unchanged): the slot itself forces
    interiority via `kvE2_sepMem_posI_of_slot`. -/
theorem kvE2_sepMem_allSlots {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3)
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf)
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2_sepSlotBlock σ) :
    s ∈ kvE2_sepAllSlots qnf :=
  List.mem_flatMap.mpr ⟨σ, kvE2_sepMem_posI_of_slot hσ hs, hs⟩

/-- The interior-positive 1-type enumeration is duplicate-free (filter of the `Nodup`
`Finset.toList`). -/
theorem kvE2_sepS_nodup {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) (zs : ZoneSpec 4) :
    (kvE2_sepS σ zs).Nodup :=
  (Finset.univ.nodup_toList).filter _

/-- A slot family `(kvE2_sepS σ zs).map f` with `f` injective is duplicate-free. -/
theorem kvE2_sepS_map_nodup {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) (zs : ZoneSpec 4)
    {f : NormalForm sig 0 1 → KvE2SepSlot sig} (hf : Function.Injective f) :
    ((kvE2_sepS σ zs).map f).Nodup :=
  (kvE2_sepS_nodup σ zs).map hf

/-- Every slot in σ's block is owned by σ. -/
theorem kvE2_sepSlotSub_of_mem_block {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {σ : NormalForm sig 1 4}
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2_sepSlotBlock σ) : kvE2_sepSlotSub s = σ := by
  rw [kvE2_sepMem_slotBlock, kvE2_sepSlotsLFor, kvE2_sepSlotsRFor] at hs
  by_cases h1 : nf0_zoneSpec σ.1 = kvE2_sep_zXW3
  · simp only [if_pos h1] at hs
    rcases hs with hL | hR
    · rcases List.mem_append.mp hL with h | h
      · obtain ⟨χ, _, rfl⟩ := List.mem_map.mp h; rfl
      · rcases List.mem_cons.mp h with rfl | h
        · rfl
        · obtain ⟨χ, _, rfl⟩ := List.mem_map.mp h; rfl
    · obtain ⟨χ, _, rfl⟩ := List.mem_map.mp hR; rfl
  · by_cases h2 : nf0_zoneSpec σ.1 = kvE2_sep_zWT3
    · simp only [if_neg h1, if_pos h2] at hs
      rcases hs with hL | hR
      · obtain ⟨χ, _, rfl⟩ := List.mem_map.mp hL; rfl
      · rcases List.mem_append.mp hR with h | h
        · obtain ⟨χ, _, rfl⟩ := List.mem_map.mp h; rfl
        · rcases List.mem_cons.mp h with rfl | h
          · rfl
          · obtain ⟨χ, _, rfl⟩ := List.mem_map.mp h; rfl
    · simp [if_neg h1, if_neg h2] at hs

/-- σ's canonical slot block is duplicate-free: within each region the constructor is injective in
    `χ`, and distinct constructors separate the region groups (cross `a ≠ b` goals close by
    `reduceCtorEq`). -/
theorem kvE2_sepSlotBlock_nodup {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] (σ : NormalForm sig 1 4) :
    (kvE2_sepSlotBlock σ).Nodup := by
  rw [kvE2_sepSlotBlock, kvE2_sepSlotsLFor, kvE2_sepSlotsRFor]
  by_cases h1 : nf0_zoneSpec σ.1 = kvE2_sep_zXW3
  · -- (map .lXU) ++ (.lX1 σ :: (map .lUW)) ++ (map .lWT)
    simp only [if_pos h1]
    rw [List.nodup_append, List.nodup_append, List.nodup_cons]
    refine ⟨⟨kvE2_sepS_map_nodup σ _ (fun a b h => by simpa using h),
        ⟨?_, kvE2_sepS_map_nodup σ _ (fun a b h => by simpa using h)⟩, ?_⟩,
      kvE2_sepS_map_nodup σ _ (fun a b h => by simpa using h), ?_⟩
    · -- .lX1 σ ∉ (map .lUW)
      intro hmem; obtain ⟨χ, _, heq⟩ := List.mem_map.mp hmem; simp at heq
    · -- ∀ a ∈ map .lXU, ∀ b ∈ .lX1 σ :: map .lUW, a ≠ b
      intro a ha b hb
      obtain ⟨χa, _, rfl⟩ := List.mem_map.mp ha
      rcases List.mem_cons.mp hb with rfl | hb
      · simp
      · obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hb; simp
    · -- ∀ a ∈ (map .lXU ++ .lX1 σ :: map .lUW), ∀ b ∈ map .lWT, a ≠ b
      intro a ha b hb
      obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hb
      rcases List.mem_append.mp ha with ha | ha
      · obtain ⟨χa, _, rfl⟩ := List.mem_map.mp ha; simp
      · rcases List.mem_cons.mp ha with rfl | ha
        · simp
        · obtain ⟨χa, _, rfl⟩ := List.mem_map.mp ha; simp
  · by_cases h2 : nf0_zoneSpec σ.1 = kvE2_sep_zWT3
    · -- (map .rXW) ++ (map .rWX1 ++ (.rX1 σ :: map .rX1T))
      simp only [if_neg h1, if_pos h2]
      rw [List.nodup_append, List.nodup_append, List.nodup_cons]
      refine ⟨kvE2_sepS_map_nodup σ _ (fun a b h => by simpa using h),
        ⟨⟨kvE2_sepS_map_nodup σ _ (fun a b h => by simpa using h),
          ⟨⟨?_, kvE2_sepS_map_nodup σ _ (fun a b h => by simpa using h)⟩, ?_⟩⟩, ?_⟩⟩
      · -- .rX1 σ ∉ (map .rX1T)
        intro hmem; obtain ⟨χ, _, heq⟩ := List.mem_map.mp hmem; simp at heq
      · -- ∀ a ∈ map .rWX1, ∀ b ∈ .rX1 σ :: map .rX1T, a ≠ b
        intro a ha b hb
        obtain ⟨χa, _, rfl⟩ := List.mem_map.mp ha
        rcases List.mem_cons.mp hb with rfl | hb
        · simp
        · obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hb; simp
      · -- ∀ a ∈ map .rXW, ∀ b ∈ (map .rWX1 ++ .rX1 σ :: map .rX1T), a ≠ b
        intro a ha b hb
        obtain ⟨χa, _, rfl⟩ := List.mem_map.mp ha
        rcases List.mem_append.mp hb with hb | hb
        · obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hb; simp
        · rcases List.mem_cons.mp hb with rfl | hb
          · simp
          · obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hb; simp
    · simp [if_neg h1, if_neg h2]

/-- Blocks of distinct owners are disjoint (each slot's owner is recovered by `kvE2_sepSlotSub`) —
    the cross-owner distinctness feeding `kvE2_sepAllSlots_nodup`. -/
theorem kvE2_sep_blocks_disjoint {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {σ τ : NormalForm sig 1 4}
    (hne : σ ≠ τ) : (kvE2_sepSlotBlock σ).Disjoint (kvE2_sepSlotBlock τ) := by
  intro a ha hb
  exact hne ((kvE2_sepSlotSub_of_mem_block ha).symm.trans (kvE2_sepSlotSub_of_mem_block hb))

/-- **The full slot family is duplicate-free**: distinct
    individual slots occupy distinct positions, so `kvE2_sepSlotIndexOf` embeds the family into
    `[0, N)` and the lex value family `G j = (value_j, j)` is injective (feeds
    `kvE2_ordRank_injective`). Per-block distinctness plus cross-owner disjointness via
    `kvE2_sepSlotSub`. Model-independent (gate report 09: the per-owner slot list stays fixed). -/
theorem kvE2_sepAllSlots_nodup {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) :
    (kvE2_sepAllSlots qnf).Nodup := by
  rw [kvE2_sepAllSlots, List.nodup_flatMap]
  refine ⟨fun σ _ => kvE2_sepSlotBlock_nodup σ, ?_⟩
  exact (kvE2_sepPosI_nodup qnf).imp (fun hne => kvE2_sep_blocks_disjoint hne)

/-- A family member's global index is `< N` (the `Fin N` domain bound for `G`, Phase 6). -/
theorem kvE2_sepSlotIndexOf_lt {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3)
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2_sepAllSlots qnf) :
    kvE2_sepSlotIndexOf qnf s < (kvE2_sepAllSlots qnf).length :=
  List.idxOf_lt_length_of_mem hs

/-- `kvE2_sepSlotIndexOf` is injective on family members (idxOf recovers the slot via
    `List.idxOf_get`): the structural (model-independent) injectivity that, combined with the lex
    value family, gives `G j = (value_j, j)` a globally injective index coordinate (Phase 6). -/
theorem kvE2_sepSlotIndexOf_injOn {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] (qnf : NormalForm sig 2 3)
    {s r : KvE2SepSlot sig} (hs : s ∈ kvE2_sepAllSlots qnf) (hr : r ∈ kvE2_sepAllSlots qnf)
    (h : kvE2_sepSlotIndexOf qnf s = kvE2_sepSlotIndexOf qnf r) : s = r := by
  have hsl : (kvE2_sepAllSlots qnf).idxOf s < (kvE2_sepAllSlots qnf).length :=
    List.idxOf_lt_length_of_mem hs
  have hrl : (kvE2_sepAllSlots qnf).idxOf r < (kvE2_sepAllSlots qnf).length :=
    List.idxOf_lt_length_of_mem hr
  rw [← List.idxOf_get hsl, ← List.idxOf_get hrl]
  congr 1
  exact Fin.ext h

/-- **Block position of a slot**: the 0-based index of `s`
    within its OWNER's individual-slot block. The per-INDIVIDUAL-slot coordinate the refined reader
    `kvE2_sepSlotGIdx` will project the payload at — REPLACING the region-rank projection
    `kvE2_sepSlotRank`, whose collapse of same-region base slots to one index is the exact 337
    stop-guard tie. Purely structural (a syntactic `idxOf`); reads no zone bit and no model data
    (F4/F5/LITMUS clean). -/
noncomputable def kvE2_sepBlockPos {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] (s : KvE2SepSlot sig) : ℕ :=
  (kvE2_sepSlotBlock (kvE2_sepSlotSub s)).idxOf s

/-- A slot of its owner's block has block position `< block length`, so the refined reader's
    `List.getD` at `kvE2_sepBlockPos` hits a real payload entry (the per-slot payload is
    block-length-long). -/
theorem kvE2_sepBlockPos_lt {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {σ : NormalForm sig 1 4}
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2_sepSlotBlock σ) :
    kvE2_sepBlockPos s < (kvE2_sepSlotBlock σ).length := by
  have hsub : kvE2_sepSlotSub s = σ := kvE2_sepSlotSub_of_mem_block hs
  rw [kvE2_sepBlockPos, hsub]
  exact List.idxOf_lt_length_of_mem hs

/-- **Region tag**: `true` for a slot in σ's LEFT block
    (`kvE2_sepSlotsLFor`: `lXU`/`lX1`/`lUW`/`rXW`), `false` for the RIGHT block
    (`kvE2_sepSlotsRFor`: `lWT`/`rWX1`/`rX1`/`rX1T`). The region-scoped consistency predicate
    compares ranks ONLY within one region: block rank is non-monotone across the L→R boundary
    (crux correction — `lUW` rank 2 in the left region precedes `lWT` rank 0 in the right region),
    so a whole-block monotone constraint would be WRONG. Reads no zone bit, no model data. -/
def kvE2_sepSlotRegionLeft {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] :
    KvE2SepSlot sig → Bool
  | .lXU _ _ => true
  | .lX1 _   => true
  | .lUW _ _ => true
  | .rXW _ _ => true
  | .lWT _ _ => false
  | .rWX1 _ _ => false
  | .rX1 _   => false
  | .rX1T _ _ => false

/-- Every slot in σ's LEFT block is region-left. -/
theorem kvE2_sepSlotsLFor_regionLeft {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] (σ : NormalForm sig 1 4)
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2_sepSlotsLFor σ) :
    kvE2_sepSlotRegionLeft s = true := by
  rw [kvE2_sepSlotsLFor] at hs
  by_cases h1 : nf0_zoneSpec σ.1 = kvE2_sep_zXW3
  · simp only [if_pos h1] at hs
    rcases List.mem_append.mp hs with h | h
    · obtain ⟨χ, _, rfl⟩ := List.mem_map.mp h; rfl
    · rcases List.mem_cons.mp h with rfl | h
      · rfl
      · obtain ⟨χ, _, rfl⟩ := List.mem_map.mp h; rfl
  · by_cases h2 : nf0_zoneSpec σ.1 = kvE2_sep_zWT3
    · simp only [if_neg h1, if_pos h2] at hs
      obtain ⟨χ, _, rfl⟩ := List.mem_map.mp hs; rfl
    · simp [if_neg h1, if_neg h2] at hs

/-- Every slot in σ's RIGHT block is region-right. -/
theorem kvE2_sepSlotsRFor_regionRight {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] (σ : NormalForm sig 1 4)
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2_sepSlotsRFor σ) :
    kvE2_sepSlotRegionLeft s = false := by
  rw [kvE2_sepSlotsRFor] at hs
  by_cases h1 : nf0_zoneSpec σ.1 = kvE2_sep_zXW3
  · simp only [if_pos h1] at hs
    obtain ⟨χ, _, rfl⟩ := List.mem_map.mp hs; rfl
  · by_cases h2 : nf0_zoneSpec σ.1 = kvE2_sep_zWT3
    · simp only [if_neg h1, if_pos h2] at hs
      rcases List.mem_append.mp hs with h | h
      · obtain ⟨χ, _, rfl⟩ := List.mem_map.mp h; rfl
      · rcases List.mem_cons.mp h with rfl | h
        · rfl
        · obtain ⟨χ, _, rfl⟩ := List.mem_map.mp h; rfl
    · simp [if_neg h1, if_neg h2] at hs

/-- A constantly-true relation is `Pairwise` on any list. -/
private theorem kvE2_pairwise_of_forall {X : Type*} (R : X → X → Prop) (l : List X)
    (h : ∀ a b, R a b) : l.Pairwise R := by
  induction l with
  | nil => exact List.Pairwise.nil
  | cons a t ih => exact List.Pairwise.cons (fun b _ => h a b) ih

/-- σ's LEFT block is rank-non-decreasing (`lXU`(0) … `lX1`(1) … `lUW`(2); or `rXW`(0)). -/
theorem kvE2_sepSlotsLFor_rank_sorted {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] (σ : NormalForm sig 1 4) :
    (kvE2_sepSlotsLFor σ).Pairwise (fun a b => kvE2_sepSlotRank a ≤ kvE2_sepSlotRank b) := by
  rw [kvE2_sepSlotsLFor]
  by_cases h1 : nf0_zoneSpec σ.1 = kvE2_sep_zXW3
  · simp only [if_pos h1]
    rw [List.pairwise_append]
    refine ⟨?_, ?_, ?_⟩
    · rw [List.pairwise_map]
      exact kvE2_pairwise_of_forall _ _ (fun a b => by simp [kvE2_sepSlotRank])
    · rw [List.pairwise_cons]
      refine ⟨?_, ?_⟩
      · intro b hb; obtain ⟨χ, _, rfl⟩ := List.mem_map.mp hb; simp [kvE2_sepSlotRank]
      · rw [List.pairwise_map]
        exact kvE2_pairwise_of_forall _ _ (fun a b => by simp [kvE2_sepSlotRank])
    · intro a ha b hb
      obtain ⟨χa, _, rfl⟩ := List.mem_map.mp ha
      rcases List.mem_cons.mp hb with rfl | hb
      · simp [kvE2_sepSlotRank]
      · obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hb; simp [kvE2_sepSlotRank]
  · by_cases h2 : nf0_zoneSpec σ.1 = kvE2_sep_zWT3
    · simp only [if_neg h1, if_pos h2]
      rw [List.pairwise_map]
      exact kvE2_pairwise_of_forall _ _ (fun a b => by simp [kvE2_sepSlotRank])
    · simp only [if_neg h1, if_neg h2]; exact List.Pairwise.nil

/-- σ's RIGHT block is rank-non-decreasing (`lWT`(0); or `rWX1`(0) … `rX1`(1) … `rX1T`(2)). -/
theorem kvE2_sepSlotsRFor_rank_sorted {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] (σ : NormalForm sig 1 4) :
    (kvE2_sepSlotsRFor σ).Pairwise (fun a b => kvE2_sepSlotRank a ≤ kvE2_sepSlotRank b) := by
  rw [kvE2_sepSlotsRFor]
  by_cases h1 : nf0_zoneSpec σ.1 = kvE2_sep_zXW3
  · simp only [if_pos h1]
    rw [List.pairwise_map]
    exact kvE2_pairwise_of_forall _ _ (fun a b => by simp [kvE2_sepSlotRank])
  · by_cases h2 : nf0_zoneSpec σ.1 = kvE2_sep_zWT3
    · simp only [if_neg h1, if_pos h2]
      rw [List.pairwise_append]
      refine ⟨?_, ?_, ?_⟩
      · rw [List.pairwise_map]
        exact kvE2_pairwise_of_forall _ _ (fun a b => by simp [kvE2_sepSlotRank])
      · rw [List.pairwise_cons]
        refine ⟨?_, ?_⟩
        · intro b hb; obtain ⟨χ, _, rfl⟩ := List.mem_map.mp hb; simp [kvE2_sepSlotRank]
        · rw [List.pairwise_map]
          exact kvE2_pairwise_of_forall _ _ (fun a b => by simp [kvE2_sepSlotRank])
      · intro a ha b hb
        obtain ⟨χa, _, rfl⟩ := List.mem_map.mp ha
        rcases List.mem_cons.mp hb with rfl | hb
        · simp [kvE2_sepSlotRank]
        · obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hb; simp [kvE2_sepSlotRank]
    · simp only [if_neg h1, if_neg h2]; exact List.Pairwise.nil

/-- **Within-region rank sortedness**: the block is rank-non-decreasing
    within each region. Across the L→R boundary the region tags differ, so the constraint is
    vacuous there (crux correction). This is the engine both the prefix-sum (model/coincident)
    and value-rank (honest) consistency proofs consume. -/
theorem kvE2_sepSlotBlock_region_rank_sorted {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] (σ : NormalForm sig 1 4) :
    (kvE2_sepSlotBlock σ).Pairwise
      (fun a b => kvE2_sepSlotRegionLeft a = kvE2_sepSlotRegionLeft b →
        kvE2_sepSlotRank a ≤ kvE2_sepSlotRank b) := by
  rw [kvE2_sepSlotBlock, List.pairwise_append]
  refine ⟨?_, ?_, ?_⟩
  · exact (kvE2_sepSlotsLFor_rank_sorted σ).imp (fun {a b} h (_ : kvE2_sepSlotRegionLeft a
      = kvE2_sepSlotRegionLeft b) => h)
  · exact (kvE2_sepSlotsRFor_rank_sorted σ).imp (fun {a b} h (_ : kvE2_sepSlotRegionLeft a
      = kvE2_sepSlotRegionLeft b) => h)
  intro a ha b hb hreg
  rw [kvE2_sepSlotsLFor_regionLeft σ ha, kvE2_sepSlotsRFor_regionRight σ hb] at hreg
  exact absurd hreg (by simp)

/-- **Block-position alignment**: within one region, a strictly smaller
    rank occupies a strictly earlier block position. The contrapositive of within-region rank
    sortedness — the fact the prefix-sum consistency proof needs (position order refines region
    rank order). -/
theorem kvE2_sepBlock_pos_lt_of_rank_lt {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] (σ : NormalForm sig 1 4)
    {j k : Fin (kvE2_sepSlotBlock σ).length}
    (hreg : kvE2_sepSlotRegionLeft ((kvE2_sepSlotBlock σ).get j)
      = kvE2_sepSlotRegionLeft ((kvE2_sepSlotBlock σ).get k))
    (hrank : kvE2_sepSlotRank ((kvE2_sepSlotBlock σ).get j)
      < kvE2_sepSlotRank ((kvE2_sepSlotBlock σ).get k)) :
    j.val < k.val := by
  rcases lt_trichotomy j.val k.val with h | h | h
  · exact h
  · exact absurd (by rw [Fin.ext h] at hrank; exact hrank) (lt_irrefl _)
  · have hp := (List.pairwise_iff_get.mp (kvE2_sepSlotBlock_region_rank_sorted σ)) k j h
    exact absurd (hp hreg.symm) (by omega)

/-- **Global index is monotone along the block**: within one owner's
    block, a strictly earlier block position has a strictly smaller global slot index. Because the
    block occurs as a contiguous `Nodup` infix of `kvE2_sepAllSlots`, `kvE2_sepSlotIndexOf` of the
    `i`-th block slot is `(prefix length) + i`. Feeds the model/coincident prefix-sum consistency
    (payload `block.map kvE2_sepSlotIndexOf`). -/
theorem kvE2_sepSlotIndexOf_block_mono {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] (qnf : NormalForm sig 2 3)
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf)
    {j k : Fin (kvE2_sepSlotBlock σ).length} (hjk : j.val < k.val) :
    kvE2_sepSlotIndexOf qnf ((kvE2_sepSlotBlock σ).get j)
      < kvE2_sepSlotIndexOf qnf ((kvE2_sepSlotBlock σ).get k) := by
  have hposnd : (kvE2_sepPos qnf).Nodup := List.Nodup.filter _ (Finset.nodup_toList _)
  obtain ⟨pre, post, hpos⟩ := List.append_of_mem hσ
  have hσpre : σ ∉ pre := by
    rw [hpos] at hposnd
    intro hc
    exact (List.nodup_append.mp hposnd).2.2 σ hc σ List.mem_cons_self rfl
  have hall : kvE2_sepAllSlots qnf
      = pre.flatMap kvE2_sepSlotBlock
        ++ (kvE2_sepSlotBlock σ ++ post.flatMap kvE2_sepSlotBlock) := by
    rw [kvE2_sepAllSlots_eq_pos, hpos, List.flatMap_append, List.flatMap_cons]
  have hoff : ∀ (i : Fin (kvE2_sepSlotBlock σ).length),
      kvE2_sepSlotIndexOf qnf ((kvE2_sepSlotBlock σ).get i)
        = (pre.flatMap kvE2_sepSlotBlock).length + i.val := by
    intro i
    have hmem : (kvE2_sepSlotBlock σ).get i ∈ kvE2_sepSlotBlock σ := List.get_mem _ _
    have hnotP : (kvE2_sepSlotBlock σ).get i ∉ pre.flatMap kvE2_sepSlotBlock := by
      intro hc
      obtain ⟨τ, hτ, hsτ⟩ := List.mem_flatMap.mp hc
      have hst : σ = τ :=
        (kvE2_sepSlotSub_of_mem_block hmem).symm.trans (kvE2_sepSlotSub_of_mem_block hsτ)
      exact hσpre (hst ▸ hτ)
    rw [kvE2_sepSlotIndexOf, hall, List.idxOf_append_of_notMem hnotP,
      List.idxOf_append_of_mem hmem, List.get_idxOf (kvE2_sepSlotBlock_nodup σ) i]
  rw [hoff j, hoff k]; omega

/-- **Region-scoped per-owner consistency**: the owner's per-slot payload
    `t` extends σ's region order — within each region, a strictly larger region rank gets a strictly
    larger payload entry. Region-scoped, NOT whole-block monotone: block rank drops at the L→R
    boundary (crux correction). Replaces the length-3 `i₀<i₁<i₂` `kvE2_sepConsistentTuple`. Reads no
    zone bit, no model literal (abstract ℕ compare; F4/F5/LITMUS clean). -/
noncomputable def kvE2_sepConsistentBlock {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) (t : List ℕ) : Bool :=
  decide (∀ j k : Fin (kvE2_sepSlotBlock σ).length,
    kvE2_sepSlotRegionLeft ((kvE2_sepSlotBlock σ).get j)
      = kvE2_sepSlotRegionLeft ((kvE2_sepSlotBlock σ).get k) →
    kvE2_sepSlotRank ((kvE2_sepSlotBlock σ).get j)
      < kvE2_sepSlotRank ((kvE2_sepSlotBlock σ).get k) →
    t.getD j.val 0 < t.getD k.val 0)

/-- Reading a `block.map f` payload at a block position `m` returns `f (block.get m)`. -/
theorem kvE2_sepBlockMap_getD {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4)
    (f : KvE2SepSlot sig → ℕ) (m : Fin (kvE2_sepSlotBlock σ).length) :
    ((kvE2_sepSlotBlock σ).map f).getD m.val 0 = f ((kvE2_sepSlotBlock σ).get m) := by
  rw [List.getD_eq_getElem?_getD, List.getElem?_map, List.getElem?_eq_getElem m.isLt]
  rfl

/-- **Prefix-sum consistency** (model/coincident payload): the payload
    `block.map kvE2_sepSlotIndexOf` extends every region order. Within a region a larger rank gives
    a
    later block position (`kvE2_sepBlock_pos_lt_of_rank_lt`), hence a larger global index
    (`kvE2_sepSlotIndexOf_block_mono`). -/
theorem kvE2_sepConsistentBlock_slotIndexOf {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] (qnf : NormalForm sig 2 3)
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf) :
    kvE2_sepConsistentBlock σ ((kvE2_sepSlotBlock σ).map (kvE2_sepSlotIndexOf qnf)) = true := by
  rw [kvE2_sepConsistentBlock, decide_eq_true_eq]
  intro j k hreg hrank
  rw [kvE2_sepBlockMap_getD, kvE2_sepBlockMap_getD]
  exact kvE2_sepSlotIndexOf_block_mono qnf hσ (kvE2_sepBlock_pos_lt_of_rank_lt σ hreg hrank)

end FormalSystem.Metalogic.WeakCanonical.Kamp
