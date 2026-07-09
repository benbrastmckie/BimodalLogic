import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SubBracket2V
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.NavigatedSpine

/-! # Shared-Interior-Witness Joint Carrier (task 321 v7, Phase 7 = O1 + O1b + O2)

The ONE unbuilt object named by the SubBracket2V API banner (`SubBracket2V.lean:25-27`):
the shared-interior-witness conjunction `∃ w, ⋀_σ (per-σ realization at that same w)`,
built as a concrete, model-independent joint carrier `kvE2_sepBody` (Candidate A staged via
Candidate C; plan `specs/321_.../plans/07_v7-faithful-separate-bracket.md` Phase 7; report
`specs/321_.../reports/07_v7-consolidated-faithful-route.md` §2.2).

Every disjunct is a single FLAT bracket (Rabinovich 2014, `md:` refs to the Literature chunk):

- ONE shared `ptW` slot + per positive interior σ one `charK (nfk_projFresh σ)` E[Σ]-atom
  slot plus σ's per-region interior-positive `charBase χ` slots — quantifier-free /
  E[Σ]-atom point types ONLY (**Lemma 5.1**, md:72: "alpha_j, beta_j are quantifier-free
  formulas over Sigma"); no chain predicate in any point-type position (FM-merge), no
  bracket-in-bracket (no-nesting, `NavigatedSpine.lean:43-48`).
- Disjuncts enumerate the JOINT interleavings of every positive interior σ's slot sequence
  between the fixed endpoints `x`, the shared `w` slot, and `t` (**Lemma 3.2(1)**, md:77:
  "Conjunction of exists-forall formulas is equivalent to a disjunction of exists-forall
  formulas") — realized as permutations of the tagged slot union filtered by the per-σ
  region order (`XU* < x1 < UW*` resp. `WX1* < x1 < X1T*`).
- Refined segment types = conjunction of EVERY interior σ's exclusion content on that
  refined sub-interval (**Cor 5.4**, md:154-157), keyed per arrangement by the position of
  each σ's fresh-witness slot.
- `epL`/`epR`/`ptW` carry (i) `qnf.1`'s endpoint 1-types, (ii) each interior σ's
  exterior/boundary `charBase` literals (per-σ `epL`/`epR` content, `SubBracket2V.lean:183-192`),
  and (iii) the σ-LEVEL navigation literals for the five non-interior outer placements —
  `Since`/`Until` `charK`-atom literals at the fixed endpoints (**Prop 3.5**, md:91-94: the
  reconstruction rides the temporal evaluation point; LITMUS: no `x1 < e_i` literal).
- Gate-failure branch `{ disjuncts := [] }` under the depth-2 gate: outer off-fiber falsity,
  outer seven-zone consistency (the joint witness self-zone `zAtW3` included — nine-zone
  lesson one level up, `SubBracket2V.lean:160-166`), inner off-fiber for every positive σ,
  and the inner NINE-zone consistency (verbatim `SubBracket2V.lean:1400-1408` pattern set,
  including both witness self-zones `zAtX1`/`zAtW`) for left-interior positives.

**Recorded scope decision (Phase 7).** Positive subs are classified by their OUTER zone
`nf0_zoneSpec σ.1` (x1 relative to `[w,x,t]`; the enumeration device of the quarantined
`kvE2_body` reused as a *pattern*, never imported). The two interior classes (`zXW3`,
`zWT3`) receive slot groups; the five non-interior classes ride the σ-level endpoint
literals that the landed joint dischargers (`NavigatedSpine.lean:257-383`) serve. The inner
nine-zone gate clause is stated for the LEFT-interior class (the class the landed per-σ kit
`kvE_subBracket2V_correctness_pair` serves); extending it to the mirrored right-interior
class is deferred to the phase that consumes it (Phases 8-10 arbitration).

DO-NOT-EDIT discipline: this module is purely additive; it consumes only public
`SubBracket2V`/`NavigatedSpine`/sibling-Kamp assets and rebuilds nothing landed. -/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation
  (nf_depth0_char_formula nf_depth0_char_formula_correct
   formula_conjList formula_conjList_iff)

/-- `ZoneSpec n` equality is decidable (a function over `Fin n` into `Bool × Bool`); the
    type synonym is a plain `def`, so instance search needs this explicit private bridge
    (file-local; nothing downstream sees it). -/
private instance {n : Nat} : DecidableEq (ZoneSpec n) :=
  fun a b => decidable_of_iff (∀ i : Fin n, a i = b i) funext_iff.symm

/-! ## Outer zone constants (Def 3.1, md:61-74 — the fresh `x1` relative to `[w,x,t]`)

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

/-! ## Inner zone constants (Def 3.1, md:61-74 — a 1-type point `v` relative to `[x1,w,x,t]`)

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
def kvE2_sepBits {sig : MonadicSignature}
    (σ : NormalForm sig 1 4) (zs : ZoneSpec 4) (χ : NormalForm sig 0 1) : Bool :=
  σ.2 (nf0_assemble zs χ σ.1)

/-- Depth-0 coordinate projection of a σ's arity-4 base (Def 3.1 point-type channel;
    the arity-4 analog of `nf_x_proj3`/`nf_t_proj3`, top-level clone of
    `kvE_subBracket2V`'s internal `proj`). -/
def kvE2_sepProj4 {sig : MonadicSignature}
    (σ : NormalForm sig 1 4) (k : Fin 4) : NormalForm sig 0 1 :=
  fun a => match a with
    | .pred p _ => σ.1 (.pred p k)
    | .order i j h => absurd (Subsingleton.elim i j) h

/-- Depth-0 coordinate projection of the joint arity-3 base `qnf.1` (env `[w,x,t]`). -/
def kvE2_sepProj3 {sig : MonadicSignature}
    (r : NormalForm sig 0 3) (k : Fin 3) : NormalForm sig 0 1 :=
  fun a => match a with
    | .pred p _ => r (.pred p k)
    | .order i j h => absurd (Subsingleton.elim i j) h

/-- Biconditional literal at an anchor (Prop 3.5 folding mechanism, PDF p.5). -/
def kvE2_sepLit (bit : Bool) (f : Formula) : Formula :=
  if bit then f else f.neg

/-- Interior-positive 1-type enumeration for σ at zone pattern `zs`
    (duplicate-free `Finset.univ.toList`, Fintype `NormalForm.lean:167-178`). -/
noncomputable def kvE2_sepS {sig : MonadicSignature}
    (σ : NormalForm sig 1 4) (zs : ZoneSpec 4) : List (NormalForm sig 0 1) :=
  (Finset.univ.toList : List (NormalForm sig 0 1)).filter (fun χ => kvE2_sepBits σ zs χ)

/-- σ's exclusion segment content at zone pattern `zs` (Cor 5.4, md:154-157: real
    per-region exclusion, never a constant tri-zone). -/
noncomputable def kvE2_sepSegForm {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (σ : NormalForm sig 1 4) (zs : ZoneSpec 4) : Formula :=
  formula_conjList ((Finset.univ.toList : List (NormalForm sig 0 1)).map fun χ =>
    if kvE2_sepBits σ zs χ then Formula.top else (charBase χ).neg)

/-! ## Outer enumeration: positive subs and their placement classes -/

/-- Positive subs of the depth-2 quant layer (Fintype enumeration, duplicate-free). -/
noncomputable def kvE2_sepPos {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) : List (NormalForm sig 1 4) :=
  (Finset.univ.toList : List (NormalForm sig 1 4)).filter (fun σ => qnf.2 σ)

/-- Positive subs in outer placement class `zs` (classified by the σ's own order bits —
    model-independent; the quarantined enumeration device reused as a pattern only). -/
noncomputable def kvE2_sepPosIn {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (zs : ZoneSpec 3) : List (NormalForm sig 1 4) :=
  (kvE2_sepPos qnf).filter (fun σ => decide (nf0_zoneSpec σ.1 = zs))

/-- Whether some positive sub in outer class `zs` has fresh depth-1 projection `χ`
    (the σ-level literal driver for the five non-interior endpoint literals). -/
noncomputable def kvE2_sepHasPos {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (zs : ZoneSpec 3) (χ : NormalForm sig 1 1) : Bool :=
  (kvE2_sepPosIn qnf zs).any (fun σ => decide (nfk_projFresh σ = χ))

/-! ## Tagged joint slots (Lemma 3.2(1) interleaving carriers)

Each slot records WHICH positive interior σ it belongs to and which of σ's regions it
realizes, so the refined segment computation and the later extraction phases can read the
arrangement structurally. Point types remain quantifier-free/E[Σ]-atom (Lemma 5.1, md:72). -/

/-- A joint bracket slot: `l*` constructors belong to a LEFT-interior σ (`x < x1 < w`),
    `r*` constructors to a RIGHT-interior σ (`w < x1 < t`). `lXU`/`lUW`/`lWT` are σ's
    interior-positive 1-type slots in `(x,x1)`/`(x1,w)`/`(w,t)`; `rXW`/`rWX1`/`rX1T` in
    `(x,w)`/`(w,x1)`/`(x1,t)`; `lX1`/`rX1` are σ's fresh-witness E[Σ]-atom slots. -/
inductive KvE2SepSlot (sig : MonadicSignature) where
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
def kvE2_sepSlotSub {sig : MonadicSignature} : KvE2SepSlot sig → NormalForm sig 1 4
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
def kvE2_sepSlotRank {sig : MonadicSignature} : KvE2SepSlot sig → Nat
  | .lXU _ _ => 0
  | .lX1 _ => 1
  | .lUW _ _ => 2
  | .lWT _ _ => 0
  | .rXW _ _ => 0
  | .rWX1 _ _ => 0
  | .rX1 _ => 1
  | .rX1T _ _ => 2

/-- Left-interior fresh-witness point type: the `charK (nfk_projFresh σ)` E[Σ]-atom head
    (Lemma 5.1, md:72 — an atom typing its OWN point only; no-nesting) PLUS σ's `zAtX1`
    self-zone literals (nine-zone lesson, `SubBracket2V.lean:207-215` pattern). -/
noncomputable def kvE2_sepPtX1L {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4) : TemporalPred :=
  ⟨formula_conjList
    (charK (nfk_projFresh σ)
      :: (Finset.univ.toList : List (NormalForm sig 0 1)).map fun χ =>
          kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zAtX1L χ) (charBase χ))⟩

/-- Right-interior fresh-witness point type (mirrored self-zone `kvE2_sep_zAtX1R`). -/
noncomputable def kvE2_sepPtX1R {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4) : TemporalPred :=
  ⟨formula_conjList
    (charK (nfk_projFresh σ)
      :: (Finset.univ.toList : List (NormalForm sig 0 1)).map fun χ =>
          kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zAtX1R χ) (charBase χ))⟩

/-- Point type of a slot: `charBase χ` for 1-type slots, the folded `charK` E[Σ]-atom
    point type for fresh-witness slots (Lemma 5.1 quantifier-free/E[Σ]-atom discipline). -/
noncomputable def kvE2_sepSlotType {sig : MonadicSignature}
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
noncomputable def kvE2_sepSlotsLFor {sig : MonadicSignature}
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
noncomputable def kvE2_sepSlotsRFor {sig : MonadicSignature}
    (σ : NormalForm sig 1 4) : List (KvE2SepSlot sig) :=
  if nf0_zoneSpec σ.1 = kvE2_sep_zXW3 then
    (kvE2_sepS σ kvE_sub2_zWT).map (.lWT σ)
  else if nf0_zoneSpec σ.1 = kvE2_sep_zWT3 then
    (kvE2_sepS σ kvE2_sep_zWX1).map (.rWX1 σ)
      ++ .rX1 σ :: (kvE2_sepS σ kvE_sub2_zWT).map (.rX1T σ)
  else []

/-- Canonical joint LEFT slot list: the union over all positive subs (Lemma 3.2(1) —
    the conjunction's witness multiset between `x` and the shared `w`). -/
noncomputable def kvE2_sepSlotsL {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) : List (KvE2SepSlot sig) :=
  (kvE2_sepPos qnf).flatMap kvE2_sepSlotsLFor

/-- Canonical joint RIGHT slot list (between the shared `w` and `t`). -/
noncomputable def kvE2_sepSlotsR {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) : List (KvE2SepSlot sig) :=
  (kvE2_sepPos qnf).flatMap kvE2_sepSlotsRFor

/-! ## Task 340 Phases 3/6 foundation — the full per-individual-slot family (`Fin N`)

Model-independent scaffolding for the per-slot value-rank carrier (plan Phase 6: "the FULL slot
family `Fin N`"; handoff step (1): "slotIndexOf/positionOf, model-independent, from
`kvE2_sepSlotsLFor ++ kvE2_sepSlotsRFor`"). `kvE2_sepSlotBlock σ` is σ's canonical individual-slot
block (its LEFT then RIGHT region slots); `kvE2_sepAllSlots qnf` is the full cross-owner slot family
whose length is `N` (total base+anchor slots). `kvE2_sepAllSlots_nodup` (the load-bearing
distinctness fact) makes `kvE2_sepSlotIndexOf` a genuine embedding into `[0, N)`, so a value family
`G j = (value_j, j)` over `Fin N` is injective (feeds `kvE2_ordRank_injective`, Phase 6). Every
component is a syntactic filter of `σ` — no `M` appears (F4/F5/LITMUS clean; per gate report 09 the
per-owner slot list stays model-independent). Rabinovich Def 3.1: the witness is a strict chain of
INDIVIDUAL points, so the carrier ranges over per-individual-slot positions, not owner-region ranks. -/

/-- σ's canonical per-individual-slot block: its LEFT region slots followed by its RIGHT region
    slots (variable arity — the per-slot granularity Rabinovich Def 3.1 requires, replacing the
    fixed 3-arity owner-region tuple this refinement removes). -/
noncomputable def kvE2_sepSlotBlock {sig : MonadicSignature}
    (σ : NormalForm sig 1 4) : List (KvE2SepSlot sig) :=
  kvE2_sepSlotsLFor σ ++ kvE2_sepSlotsRFor σ

/-- The full cross-owner individual-slot family (length `N` = total base+anchor slots across all
    positive owners). The `Fin N` domain of the per-slot value-rank family `G` (Phase 6). -/
noncomputable def kvE2_sepAllSlots {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) : List (KvE2SepSlot sig) :=
  (kvE2_sepPos qnf).flatMap kvE2_sepSlotBlock

/-- **Global per-individual-slot position** (Phase 6 `slotIndexOf`): the 0-based index of slot `s`
    in the full slot family. When `kvE2_sepAllSlots` is `Nodup` (see `kvE2_sepAllSlots_nodup`) this
    is a genuine injection on the family's members — the structural (model-independent) index the
    lex value-rank family `G` uses in its second coordinate. -/
noncomputable def kvE2_sepSlotIndexOf {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (s : KvE2SepSlot sig) : ℕ :=
  (kvE2_sepAllSlots qnf).idxOf s

/-- A slot of a positive owner's block is a member of the full slot family. -/
theorem kvE2_sepMem_allSlots {sig : MonadicSignature} (qnf : NormalForm sig 2 3)
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf)
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2_sepSlotBlock σ) :
    s ∈ kvE2_sepAllSlots qnf :=
  List.mem_flatMap.mpr ⟨σ, hσ, hs⟩

/-- Block membership splits over the two region blocks. -/
theorem kvE2_sepMem_slotBlock {sig : MonadicSignature} (σ : NormalForm sig 1 4)
    (s : KvE2SepSlot sig) :
    s ∈ kvE2_sepSlotBlock σ ↔ s ∈ kvE2_sepSlotsLFor σ ∨ s ∈ kvE2_sepSlotsRFor σ := by
  rw [kvE2_sepSlotBlock, List.mem_append]

/-- The interior-positive 1-type enumeration is duplicate-free (filter of the `Nodup` `Finset.toList`). -/
theorem kvE2_sepS_nodup {sig : MonadicSignature} (σ : NormalForm sig 1 4) (zs : ZoneSpec 4) :
    (kvE2_sepS σ zs).Nodup :=
  (Finset.univ.nodup_toList).filter _

/-- A slot family `(kvE2_sepS σ zs).map f` with `f` injective is duplicate-free. -/
theorem kvE2_sepS_map_nodup {sig : MonadicSignature} (σ : NormalForm sig 1 4) (zs : ZoneSpec 4)
    {f : NormalForm sig 0 1 → KvE2SepSlot sig} (hf : Function.Injective f) :
    ((kvE2_sepS σ zs).map f).Nodup :=
  (kvE2_sepS_nodup σ zs).map hf

/-- Every slot in σ's block is owned by σ. -/
theorem kvE2_sepSlotSub_of_mem_block {sig : MonadicSignature} {σ : NormalForm sig 1 4}
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
theorem kvE2_sepSlotBlock_nodup {sig : MonadicSignature} (σ : NormalForm sig 1 4) :
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
theorem kvE2_sep_blocks_disjoint {sig : MonadicSignature} {σ τ : NormalForm sig 1 4}
    (hne : σ ≠ τ) : (kvE2_sepSlotBlock σ).Disjoint (kvE2_sepSlotBlock τ) := by
  intro a ha hb
  exact hne ((kvE2_sepSlotSub_of_mem_block ha).symm.trans (kvE2_sepSlotSub_of_mem_block hb))

/-- **The full slot family is duplicate-free** (task 340 Phase 6 foundation, load-bearing): distinct
    individual slots occupy distinct positions, so `kvE2_sepSlotIndexOf` embeds the family into
    `[0, N)` and the lex value family `G j = (value_j, j)` is injective (feeds
    `kvE2_ordRank_injective`). Per-block distinctness plus cross-owner disjointness via
    `kvE2_sepSlotSub`. Model-independent (gate report 09: the per-owner slot list stays fixed). -/
theorem kvE2_sepAllSlots_nodup {sig : MonadicSignature} (qnf : NormalForm sig 2 3) :
    (kvE2_sepAllSlots qnf).Nodup := by
  rw [kvE2_sepAllSlots, List.nodup_flatMap]
  refine ⟨fun σ _ => kvE2_sepSlotBlock_nodup σ, ?_⟩
  have hnd : (kvE2_sepPos qnf).Nodup :=
    List.Nodup.filter _ (Finset.nodup_toList _)
  exact hnd.imp (fun hne => kvE2_sep_blocks_disjoint hne)

/-- A family member's global index is `< N` (the `Fin N` domain bound for `G`, Phase 6). -/
theorem kvE2_sepSlotIndexOf_lt {sig : MonadicSignature} (qnf : NormalForm sig 2 3)
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2_sepAllSlots qnf) :
    kvE2_sepSlotIndexOf qnf s < (kvE2_sepAllSlots qnf).length :=
  List.idxOf_lt_length_of_mem hs

/-- `kvE2_sepSlotIndexOf` is injective on family members (idxOf recovers the slot via
    `List.idxOf_get`): the structural (model-independent) injectivity that, combined with the lex
    value family, gives `G j = (value_j, j)` a globally injective index coordinate (Phase 6). -/
theorem kvE2_sepSlotIndexOf_injOn {sig : MonadicSignature} (qnf : NormalForm sig 2 3)
    {s r : KvE2SepSlot sig} (hs : s ∈ kvE2_sepAllSlots qnf) (hr : r ∈ kvE2_sepAllSlots qnf)
    (h : kvE2_sepSlotIndexOf qnf s = kvE2_sepSlotIndexOf qnf r) : s = r := by
  have hsl : (kvE2_sepAllSlots qnf).idxOf s < (kvE2_sepAllSlots qnf).length :=
    List.idxOf_lt_length_of_mem hs
  have hrl : (kvE2_sepAllSlots qnf).idxOf r < (kvE2_sepAllSlots qnf).length :=
    List.idxOf_lt_length_of_mem hr
  rw [← List.idxOf_get hsl, ← List.idxOf_get hrl]
  congr 1
  exact Fin.ext h

/-- **Block position of a slot** (task 340 Phase 4 reader foundation): the 0-based index of `s`
    within its OWNER's individual-slot block. The per-INDIVIDUAL-slot coordinate the refined reader
    `kvE2_sepSlotGIdx` will project the payload at — REPLACING the region-rank projection
    `kvE2_sepSlotRank`, whose collapse of same-region base slots to one index is the exact 337
    stop-guard tie. Purely structural (a syntactic `idxOf`); reads no zone bit and no model data
    (F4/F5/LITMUS clean). -/
noncomputable def kvE2_sepBlockPos {sig : MonadicSignature} (s : KvE2SepSlot sig) : ℕ :=
  (kvE2_sepSlotBlock (kvE2_sepSlotSub s)).idxOf s

/-- A slot of its owner's block has block position `< block length`, so the refined reader's
    `List.getD` at `kvE2_sepBlockPos` hits a real payload entry (the per-slot payload is
    block-length-long). -/
theorem kvE2_sepBlockPos_lt {sig : MonadicSignature} {σ : NormalForm sig 1 4}
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2_sepSlotBlock σ) :
    kvE2_sepBlockPos s < (kvE2_sepSlotBlock σ).length := by
  have hsub : kvE2_sepSlotSub s = σ := kvE2_sepSlotSub_of_mem_block hs
  rw [kvE2_sepBlockPos, hsub]
  exact List.idxOf_lt_length_of_mem hs

/-- **Region tag** (task 340 Phase 3 flip): `true` for a slot in σ's LEFT block
    (`kvE2_sepSlotsLFor`: `lXU`/`lX1`/`lUW`/`rXW`), `false` for the RIGHT block
    (`kvE2_sepSlotsRFor`: `lWT`/`rWX1`/`rX1`/`rX1T`). The region-scoped consistency predicate
    compares ranks ONLY within one region: block rank is non-monotone across the L→R boundary
    (crux correction — `lUW` rank 2 in the left region precedes `lWT` rank 0 in the right region),
    so a whole-block monotone constraint would be WRONG. Reads no zone bit, no model data. -/
def kvE2_sepSlotRegionLeft {sig : MonadicSignature} : KvE2SepSlot sig → Bool
  | .lXU _ _ => true
  | .lX1 _   => true
  | .lUW _ _ => true
  | .rXW _ _ => true
  | .lWT _ _ => false
  | .rWX1 _ _ => false
  | .rX1 _   => false
  | .rX1T _ _ => false

/-- Every slot in σ's LEFT block is region-left. -/
theorem kvE2_sepSlotsLFor_regionLeft {sig : MonadicSignature} (σ : NormalForm sig 1 4)
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
theorem kvE2_sepSlotsRFor_regionRight {sig : MonadicSignature} (σ : NormalForm sig 1 4)
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
theorem kvE2_sepSlotsLFor_rank_sorted {sig : MonadicSignature} (σ : NormalForm sig 1 4) :
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
theorem kvE2_sepSlotsRFor_rank_sorted {sig : MonadicSignature} (σ : NormalForm sig 1 4) :
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

/-- **Within-region rank sortedness** (task 340 Phase 3 flip): the block is rank-non-decreasing
    within each region. Across the L→R boundary the region tags differ, so the constraint is
    vacuous there (crux correction). This is the engine both the prefix-sum (model/coincident)
    and value-rank (honest) consistency proofs consume. -/
theorem kvE2_sepSlotBlock_region_rank_sorted {sig : MonadicSignature} (σ : NormalForm sig 1 4) :
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
  exact absurd hreg (by simp [kvE2_sepSlotRegionLeft])

/-- **Block-position alignment** (task 340 Phase 3 flip): within one region, a strictly smaller
    rank occupies a strictly earlier block position. The contrapositive of within-region rank
    sortedness — the fact the prefix-sum consistency proof needs (position order refines region
    rank order). -/
theorem kvE2_sepBlock_pos_lt_of_rank_lt {sig : MonadicSignature} (σ : NormalForm sig 1 4)
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

/-- **Global index is monotone along the block** (task 340 Phase 3/5 flip): within one owner's
    block, a strictly earlier block position has a strictly smaller global slot index. Because the
    block occurs as a contiguous `Nodup` infix of `kvE2_sepAllSlots`, `kvE2_sepSlotIndexOf` of the
    `i`-th block slot is `(prefix length) + i`. Feeds the model/coincident prefix-sum consistency
    (payload `block.map kvE2_sepSlotIndexOf`). -/
theorem kvE2_sepSlotIndexOf_block_mono {sig : MonadicSignature} (qnf : NormalForm sig 2 3)
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
    rw [kvE2_sepAllSlots, hpos, List.flatMap_append, List.flatMap_cons]
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

/-- **Region-scoped per-owner consistency** (task 340 Phase 3 flip): the owner's per-slot payload
    `t` extends σ's region order — within each region, a strictly larger region rank gets a strictly
    larger payload entry. Region-scoped, NOT whole-block monotone: block rank drops at the L→R
    boundary (crux correction). Replaces the length-3 `i₀<i₁<i₂` `kvE2_sepConsistentTuple`. Reads no
    zone bit, no model literal (abstract ℕ compare; F4/F5/LITMUS clean). -/
noncomputable def kvE2_sepConsistentBlock {sig : MonadicSignature}
    (σ : NormalForm sig 1 4) (t : List ℕ) : Bool :=
  decide (∀ j k : Fin (kvE2_sepSlotBlock σ).length,
    kvE2_sepSlotRegionLeft ((kvE2_sepSlotBlock σ).get j)
      = kvE2_sepSlotRegionLeft ((kvE2_sepSlotBlock σ).get k) →
    kvE2_sepSlotRank ((kvE2_sepSlotBlock σ).get j)
      < kvE2_sepSlotRank ((kvE2_sepSlotBlock σ).get k) →
    t.getD j.val 0 < t.getD k.val 0)

/-- Reading a `block.map f` payload at a block position `m` returns `f (block.get m)`. -/
theorem kvE2_sepBlockMap_getD {sig : MonadicSignature} (σ : NormalForm sig 1 4)
    (f : KvE2SepSlot sig → ℕ) (m : Fin (kvE2_sepSlotBlock σ).length) :
    ((kvE2_sepSlotBlock σ).map f).getD m.val 0 = f ((kvE2_sepSlotBlock σ).get m) := by
  rw [List.getD_eq_getElem?_getD, List.getElem?_map, List.getElem?_eq_getElem m.isLt]
  rfl

/-- **Prefix-sum consistency** (task 340 Phase 3/5 flip, model/coincident payload): the payload
    `block.map kvE2_sepSlotIndexOf` extends every region order. Within a region a larger rank gives a
    later block position (`kvE2_sepBlock_pos_lt_of_rank_lt`), hence a larger global index
    (`kvE2_sepSlotIndexOf_block_mono`). -/
theorem kvE2_sepConsistentBlock_slotIndexOf {sig : MonadicSignature} (qnf : NormalForm sig 2 3)
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf) :
    kvE2_sepConsistentBlock σ ((kvE2_sepSlotBlock σ).map (kvE2_sepSlotIndexOf qnf)) = true := by
  rw [kvE2_sepConsistentBlock, decide_eq_true_eq]
  intro j k hreg hrank
  rw [kvE2_sepBlockMap_getD, kvE2_sepBlockMap_getD]
  exact kvE2_sepSlotIndexOf_block_mono qnf hσ (kvE2_sepBlock_pos_lt_of_rank_lt σ hreg hrank)

/-! ## Cross-σ bit-compatibility predicate (task 333 Phase 1 — STAGED, not yet wired)

The task 321 filter (`kvE2_sepSlotLe` below) admits ANY cross-σ interleaving
(`!(sub a = sub b)` ⇒ valid), which is arrangement-blind: it enumerates placements whose
per-interval segment content is INconsistent with a positive sub's fold-bit content (the
O4 CRUX defect, `SharedWitness` O4 block). Rabinovich 2014 Lemma 3.2(1) (md:77) admits only
*consistent interval-decomposition refinements*: a foreign 1-type slot may sit in a region
relative to another positive σ only when σ's fold bit for that (region, 1-type) is TRUE.

The four definitions below encode that predicate. They are DELIBERATELY not yet wired into
`kvE2_sepSlotLe`/`kvE2_sepValid`: switching the live filter breaks the identity-arrangement
`kvE2_sepSlotsL_valid`/`_valid` and hence `kvE2_sepBody_nonvacuous`, whose repair requires a
joint model-sorted arrangement (Phase 2 make-or-break — no single-σ `k1v_sorted_realization3`
analog exists for the joint slot list). The full switch + mechanical downstream repair is
captured, verified-compiling except those two lemmas, in
`handoffs/phase1-switch-and-repairs.patch`. These staged defs read arrangement fresh-slot
adjacency (slot INDICES) only, never a model-order `x1 < e_i` literal (LITMUS). -/

/-- Optional base 1-type carried by a slot: `some χ` for the six 1-type slots, `none`
    for the two fresh-witness E[Σ]-atom slots (`lX1`/`rX1`, which carry `charK`, no base χ). -/
def kvE2_sepSlotChi {sig : MonadicSignature} :
    KvE2SepSlot sig → Option (NormalForm sig 0 1)
  | .lXU _ χ => some χ
  | .lX1 _ => none
  | .lUW _ χ => some χ
  | .lWT _ χ => some χ
  | .rXW _ χ => some χ
  | .rWX1 _ χ => some χ
  | .rX1 _ => none
  | .rX1T _ χ => some χ

/-- If the slot is a fresh-witness slot, the placement-generic zone pattern of its owner's
    BEFORE-fresh interior region — `x<v<x1` (`kvE_sub2_zXU`) for a left-interior σ's `lX1`,
    `w<v<x1` (`kvE2_sep_zWX1`) for a right-interior σ's `rX1`; `none` for 1-type slots. The
    zone is EXACTLY the one the owner's own before-fresh 1-type slots read their bits at
    (`kvE2_sepSlotsLFor`/`RFor`), so a foreign slot placed there is admitted iff its 1-type
    is in σ's before-fresh segment. -/
def kvE2_sepFreshZoneBefore {sig : MonadicSignature} :
    KvE2SepSlot sig → Option (ZoneSpec 4)
  | .lX1 _ => some kvE_sub2_zXU
  | .rX1 _ => some kvE2_sep_zWX1
  | _ => none

/-- Owner's AFTER-fresh interior region zone pattern — `x1<v<w` (`kvE_sub2_zUW`) for a
    left-interior σ's `lX1`, `x1<v<t` (`kvE_sub2_zWT`) for a right-interior σ's `rX1`;
    `none` for 1-type slots. -/
def kvE2_sepFreshZoneAfter {sig : MonadicSignature} :
    KvE2SepSlot sig → Option (ZoneSpec 4)
  | .lX1 _ => some kvE_sub2_zUW
  | .rX1 _ => some kvE_sub2_zWT
  | _ => none

/-- Cross-σ bit-compatibility of the ordered pair `(a, b)` (`a` before `b` in the
    arrangement), for slots of DIFFERENT owners: (1) if `b` is `σ`'s fresh slot and `a`
    carries `χ`, then `a` lies in `σ`'s before-fresh region, admitted iff
    `kvE2_sepBits σ (before-zone) χ = true`; (2) if `a` is `σ`'s fresh slot and `b` carries
    `χ`, then `b` lies in `σ`'s after-fresh region, admitted iff
    `kvE2_sepBits σ (after-zone) χ = true`. Two 1-type slots or two fresh slots impose no
    cross constraint (their relative order does not place either inside the other's interval
    decomposition). Bool-valued / `decide`-friendly (`kvE2_sepBits` is already `Bool`).
    Rabinovich 2014 Lemma 3.2(1) (md:77). -/
def kvE2_sepCompat {sig : MonadicSignature} (a b : KvE2SepSlot sig) : Bool :=
  (match kvE2_sepFreshZoneBefore b, kvE2_sepSlotChi a with
    | some zb, some χa => kvE2_sepBits (kvE2_sepSlotSub b) zb χa
    | _, _ => true)
  && (match kvE2_sepFreshZoneAfter a, kvE2_sepSlotChi b with
    | some za, some χb => kvE2_sepBits (kvE2_sepSlotSub a) za χb
    | _, _ => true)

/-- **Cross-σ discrimination witness** (task 333 Phase-1 audit item 2, proof form —
    stronger than the planned `#eval` sanity check, and abstract over any `sig`/`σ`/`χ`).
    A foreign 1-type slot `a` (carrying `χ`) placed BEFORE a left-interior σ's fresh slot
    `.lX1 σ` is admitted by the redefined compat filter iff σ's before-fresh
    (`kvE_sub2_zXU`, region `(x, x1)`) fold bit for `χ` is TRUE: the compat value equals
    that bit EXACTLY. Hence the filter REJECTS the arrangement-blind bad interleaving
    (`kvE2_sepBits σ zXU χ = false` ⇒ `kvE2_sepCompat a (.lX1 σ) = false`) and ADMITS the
    bit-true one — the cross-σ correctness the arrangement-blind task 321 filter lacked
    (Rabinovich Lemma 3.2(1), md:77; interval-decomposition + Feferman–Vaught composition
    md:74, md:207-236). The mirror for `.rX1` (right-interior fresh, `kvE2_sep_zWX1`) and
    the after-fresh clause hold by the same reduction. NOTE (audit item 1a): a *fresh-less*
    sub's whole macro-side region (a right-interior σ on the LEFT list; a left-interior σ on
    the RIGHT list) is NOT keyed by this filter — its exclusion of foreign χ-points is owned
    by the refined-segment machinery `kvE2_sepSegLForSub`/`kvE2_sepSegRForSub` (uniform
    `kvE_sub2_zXU` / `kvE_sub2_zWT` segment forms), so the compat filter is CORRECTLY silent
    there; no third compat clause is needed. -/
theorem kvE2_sepCompat_lX1_eq {sig : MonadicSignature}
    (σ : NormalForm sig 1 4) (χ : NormalForm sig 0 1) (a : KvE2SepSlot sig)
    (hχ : kvE2_sepSlotChi a = some χ) :
    kvE2_sepCompat a (.lX1 σ) = kvE2_sepBits σ kvE_sub2_zXU χ := by
  unfold kvE2_sepCompat
  cases a <;>
    simp_all [kvE2_sepFreshZoneBefore, kvE2_sepFreshZoneAfter, kvE2_sepSlotChi,
      kvE2_sepSlotSub]

/-- **After-fresh mirror** of `kvE2_sepCompat_lX1_eq`: a foreign 1-type slot `b` (carrying
    `χ`) placed AFTER a left-interior σ's fresh slot `.lX1 σ` is admitted iff σ's after-fresh
    (`kvE_sub2_zUW`, region `(x1, w)`) fold bit for `χ` is TRUE. Consumed by the joint
    sorted-realization proof (Phase 2) for the `p > x1_σ` branch. -/
theorem kvE2_sepCompat_lX1_after_eq {sig : MonadicSignature}
    (σ : NormalForm sig 1 4) (χ : NormalForm sig 0 1) (b : KvE2SepSlot sig)
    (hχ : kvE2_sepSlotChi b = some χ) :
    kvE2_sepCompat (.lX1 σ) b = kvE2_sepBits σ kvE_sub2_zUW χ := by
  unfold kvE2_sepCompat
  cases b <;>
    simp_all [kvE2_sepFreshZoneBefore, kvE2_sepFreshZoneAfter, kvE2_sepSlotChi,
      kvE2_sepSlotSub]

/-- **Right-list before-fresh** mirror: a foreign 1-type slot `a` (carrying `χ`) placed
    BEFORE a right-interior σ's fresh slot `.rX1 σ` is admitted iff σ's before-fresh
    (`kvE2_sep_zWX1`, region `(w, x1)`) fold bit for `χ` is TRUE. -/
theorem kvE2_sepCompat_rX1_eq {sig : MonadicSignature}
    (σ : NormalForm sig 1 4) (χ : NormalForm sig 0 1) (a : KvE2SepSlot sig)
    (hχ : kvE2_sepSlotChi a = some χ) :
    kvE2_sepCompat a (.rX1 σ) = kvE2_sepBits σ kvE2_sep_zWX1 χ := by
  unfold kvE2_sepCompat
  cases a <;>
    simp_all [kvE2_sepFreshZoneBefore, kvE2_sepFreshZoneAfter, kvE2_sepSlotChi,
      kvE2_sepSlotSub]

/-- **Right-list after-fresh** mirror: a foreign 1-type slot `b` (carrying `χ`) placed
    AFTER a right-interior σ's fresh slot `.rX1 σ` is admitted iff σ's after-fresh
    (`kvE_sub2_zWT`, region `(x1, t)`) fold bit for `χ` is TRUE. -/
theorem kvE2_sepCompat_rX1_after_eq {sig : MonadicSignature}
    (σ : NormalForm sig 1 4) (χ : NormalForm sig 0 1) (b : KvE2SepSlot sig)
    (hχ : kvE2_sepSlotChi b = some χ) :
    kvE2_sepCompat (.rX1 σ) b = kvE2_sepBits σ kvE_sub2_zWT χ := by
  unfold kvE2_sepCompat
  cases b <;>
    simp_all [kvE2_sepFreshZoneBefore, kvE2_sepFreshZoneAfter, kvE2_sepSlotChi,
      kvE2_sepSlotSub]

/-- Arrangement validity relation, Bool-valued: slots of the SAME σ must appear in
    non-decreasing region rank; slots of different σ must be cross-σ bit-compatible
    (`kvE2_sepCompat`) — the task 333/334 redefinition of the arrangement-blind task 321
    filter (Rabinovich Lemma 3.2(1), md:77). -/
def kvE2_sepSlotLe {sig : MonadicSignature} (a b : KvE2SepSlot sig) : Bool :=
  if kvE2_sepSlotSub a = kvE2_sepSlotSub b then
    decide (kvE2_sepSlotRank a ≤ kvE2_sepSlotRank b)
  else
    kvE2_sepCompat a b

-- REMOVED (task 334 Phase 6): the additive open-zone arrangement filter `kvE2_sepValid` and the
-- flat-union permutation-filter interleaving sets `kvE2_sepArrL`/`kvE2_sepArrR`. These enumerated
-- `(kvE2_sepSlotsL/R qnf).permutations.filter kvE2_sepValid` — an additive open-bit filter over a
-- flat cross-owner slot union that is FALSE (empty) on the coincidence case (handoff 05). The
-- carrier now enumerates the order-type disjunction `kvE2_sepArr'` (Lemma 3.2(1), md:77), where
-- each disjunct reads the zone bit appropriate to its own arrangement.

/-! ## Joint endpoint predicates and the shared `ptW` slot -/

/-- Joint left endpoint predicate at the fixed `x`: `qnf.1`'s x-type head; σ-level
    `Since`/at-`x` `charK`-atom literals for the `zPastX3`/`zAtX3` outer classes (Prop
    3.5, md:91-94 — navigation rides the `Since` evaluation point, LITMUS-clean); each
    interior σ's own x-type and exterior/boundary `charBase` literals
    (`SubBracket2V.lean:183-187` pattern). -/
noncomputable def kvE2_sepEpL {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) : TemporalPred :=
  ⟨formula_conjList
    (charBase (kvE2_sepProj3 qnf.1 ⟨1, by omega⟩)
      :: ((Finset.univ.toList : List (NormalForm sig 1 1)).map fun χ =>
            kvE2_sepLit (kvE2_sepHasPos qnf kvE2_sep_zPastX3 χ)
              (Formula.snce (charK χ) Formula.top))
      ++ ((Finset.univ.toList : List (NormalForm sig 1 1)).map fun χ =>
            kvE2_sepLit (kvE2_sepHasPos qnf kvE2_sep_zAtX3 χ) (charK χ))
      ++ ((kvE2_sepPosIn qnf kvE2_sep_zXW3 ++ kvE2_sepPosIn qnf kvE2_sep_zWT3).flatMap
            fun σ =>
              charBase (kvE2_sepProj4 σ ⟨2, by omega⟩)
                :: ((Finset.univ.toList : List (NormalForm sig 0 1)).map fun χ =>
                      kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zPastX4 χ)
                        (Formula.snce (charBase χ) Formula.top))
                ++ ((Finset.univ.toList : List (NormalForm sig 0 1)).map fun χ =>
                      kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zAtX4 χ) (charBase χ))))⟩

/-- Joint right endpoint predicate at the fixed `t` (mirror of `kvE2_sepEpL`: at-`t` and
    `Until` σ-level literals for `zAtT3`/`zFutT3`; per interior σ its t-type and
    `zAtT4`/`zFutT4` literals, `SubBracket2V.lean:188-192` pattern). -/
noncomputable def kvE2_sepEpR {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) : TemporalPred :=
  ⟨formula_conjList
    (charBase (kvE2_sepProj3 qnf.1 ⟨2, by omega⟩)
      :: ((Finset.univ.toList : List (NormalForm sig 1 1)).map fun χ =>
            kvE2_sepLit (kvE2_sepHasPos qnf kvE2_sep_zAtT3 χ) (charK χ))
      ++ ((Finset.univ.toList : List (NormalForm sig 1 1)).map fun χ =>
            kvE2_sepLit (kvE2_sepHasPos qnf kvE2_sep_zFutT3 χ)
              (Formula.untl (charK χ) Formula.top))
      ++ ((kvE2_sepPosIn qnf kvE2_sep_zXW3 ++ kvE2_sepPosIn qnf kvE2_sep_zWT3).flatMap
            fun σ =>
              charBase (kvE2_sepProj4 σ ⟨3, by omega⟩)
                :: ((Finset.univ.toList : List (NormalForm sig 0 1)).map fun χ =>
                      kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zAtT4 χ) (charBase χ))
                ++ ((Finset.univ.toList : List (NormalForm sig 0 1)).map fun χ =>
                      kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zFutT4 χ)
                        (Formula.untl (charBase χ) Formula.top))))⟩

/-- The ONE shared interior-witness point type (the object the SubBracket2V banner names):
    `charBase` of `qnf.1`'s w-coordinate 1-type (arity-3 analog of the per-σ `ptW`,
    `SubBracket2V.lean:216-219`; Amendment F3 — a TYPE slot, never a `w = e 1` provider
    equation); the σ-level `zAtW3` `charK`-atom literals; and EVERY interior σ's own
    w-type plus `v = w` self-zone literals (`zAtWL` for the left class, `zAtWR` mirrored). -/
noncomputable def kvE2_sepPtW {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) : TemporalPred :=
  ⟨formula_conjList
    (charBase (kvE2_sepProj3 qnf.1 ⟨0, by omega⟩)
      :: ((Finset.univ.toList : List (NormalForm sig 1 1)).map fun χ =>
            kvE2_sepLit (kvE2_sepHasPos qnf kvE2_sep_zAtW3 χ) (charK χ))
      ++ ((kvE2_sepPosIn qnf kvE2_sep_zXW3).flatMap fun σ =>
            charBase (kvE2_sepProj4 σ ⟨1, by omega⟩)
              :: (Finset.univ.toList : List (NormalForm sig 0 1)).map fun χ =>
                  kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zAtWL χ) (charBase χ))
      ++ ((kvE2_sepPosIn qnf kvE2_sep_zWT3).flatMap fun σ =>
            charBase (kvE2_sepProj4 σ ⟨1, by omega⟩)
              :: (Finset.univ.toList : List (NormalForm sig 0 1)).map fun χ =>
                  kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zAtWR χ) (charBase χ)))⟩

/-! ## Refined segment types (Cor 5.4, md:154-157)

Each refined sub-interval of a joint arrangement carries EVERY interior σ's exclusion
content there. Which of σ's regions a LEFT sub-interval at cut `i` lies in is keyed by
whether σ's fresh-witness slot occurs among the first `i` slots of the arrangement —
a structural read of the arrangement, never an `x1 < e_i` literal (LITMUS). -/

/-- σ's exclusion contribution to the left-region refined sub-interval at cut `i` of
    arrangement `lL`. Left-interior σ: `(x,x1)` exclusion before its fresh slot, `(x1,w)`
    after. Right-interior σ: uniform `(x,w)` exclusion. Non-interior σ: no segment
    contribution (its content rides its `charK` E[Σ]-atom endpoint literal). -/
noncomputable def kvE2_sepSegLForSub {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (lL : List (KvE2SepSlot sig)) (i : Nat) (σ : NormalForm sig 1 4) : Formula :=
  if nf0_zoneSpec σ.1 = kvE2_sep_zXW3 then
    (if (lL.take i).contains (.lX1 σ) then kvE2_sepSegForm charBase σ kvE_sub2_zUW
     else kvE2_sepSegForm charBase σ kvE_sub2_zXU)
  else if nf0_zoneSpec σ.1 = kvE2_sep_zWT3 then
    kvE2_sepSegForm charBase σ kvE_sub2_zXU
  else Formula.top

/-- σ's exclusion contribution to the right-region refined sub-interval at cut `j` of
    arrangement `lR` (mirror: left-interior σ uniform `(w,t)`; right-interior σ `(w,x1)`
    before its fresh slot, `(x1,t)` after). -/
noncomputable def kvE2_sepSegRForSub {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (lR : List (KvE2SepSlot sig)) (j : Nat) (σ : NormalForm sig 1 4) : Formula :=
  if nf0_zoneSpec σ.1 = kvE2_sep_zXW3 then
    kvE2_sepSegForm charBase σ kvE_sub2_zWT
  else if nf0_zoneSpec σ.1 = kvE2_sep_zWT3 then
    (if (lR.take j).contains (.rX1 σ) then kvE2_sepSegForm charBase σ kvE_sub2_zWT
     else kvE2_sepSegForm charBase σ kvE2_sep_zWX1)
  else Formula.top

/-- Refined-conjunction segment type for the left region at cut `i`. -/
noncomputable def kvE2_sepSegLAt {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (qnf : NormalForm sig 2 3)
    (lL : List (KvE2SepSlot sig)) (i : Nat) : TemporalPred :=
  ⟨formula_conjList ((kvE2_sepPos qnf).map (kvE2_sepSegLForSub charBase lL i))⟩

/-- Refined-conjunction segment type for the right region at cut `j`. -/
noncomputable def kvE2_sepSegRAt {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (qnf : NormalForm sig 2 3)
    (lR : List (KvE2SepSlot sig)) (j : Nat) : TemporalPred :=
  ⟨formula_conjList ((kvE2_sepPos qnf).map (kvE2_sepSegRForSub charBase lR j))⟩

/-- Segment index dispatcher for the joint bracket: indices `≤ lL.length` are left-region
    cuts, the rest are right-region cuts (same boundary convention as `bracketFromLists`,
    `CarrierK1V.lean:389`). -/
noncomputable def kvE2_sepSegs {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (qnf : NormalForm sig 2 3)
    (lL lR : List (KvE2SepSlot sig)) (i : Nat) : TemporalPred :=
  if i ≤ lL.length then kvE2_sepSegLAt charBase qnf lL i
  else kvE2_sepSegRAt charBase qnf lR (i - lL.length - 1)

/-- **Fresh N-slot bracket builder** (plan Phase 7 O1): the `bracketFromLists`
    (`CarrierK1V.lean:389`) shape generalized to PER-INDEX segment types — required because
    the refined-conjunction segments vary across each region's cuts (the private 2-slot
    `bracketFromLists3` cannot express this). Point types are `lL ++ ptW :: lR` — the §5
    bracket `[α_0, …, α_n](z_0, z_1)` (PDF p.7) with the two FIXED endpoints and one shared
    interior witness slot at position `lL.length`. -/
def kvE2_sepBracketN (lL : List TemporalPred) (ptW : TemporalPred)
    (lR : List TemporalPred) (segs : Nat → TemporalPred) :
    BracketFormula (lL.length + 1 + lR.length) where
  pointTypes := fun i =>
    (lL ++ ptW :: lR)[i.val]'(by
      simp only [List.length_append, List.length_cons]; omega)
  segmentTypes := fun i => segs i.val

/-- **Joint disjunct builder** (TOP-LEVEL per the crux failed-closer-3 lesson): one flat
    `VecEA2` per pair of left/right interleavings, with the joint endpoint predicates, the
    shared `ptW` slot, and the refined-conjunction segments. -/
noncomputable def kvE2_sepDisjunct {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (lL lR : List (KvE2SepSlot sig)) : Σ n, VecEA2 n :=
  ⟨(lL.map (kvE2_sepSlotType charBase charK)).length + 1
      + (lR.map (kvE2_sepSlotType charBase charK)).length,
   { endpointLeft := kvE2_sepEpL charBase charK qnf
     endpointRight := kvE2_sepEpR charBase charK qnf
     bracket := kvE2_sepBracketN
       (lL.map (kvE2_sepSlotType charBase charK))
       (kvE2_sepPtW charBase charK qnf)
       (lR.map (kvE2_sepSlotType charBase charK))
       (kvE2_sepSegs charBase qnf lL lR) }⟩

/-! ## The depth-2 gate -/

/-- The seven consistent OUTER zones under the bracket order `x < w < t` (Def 3.1,
    md:61-74), including the shared-witness self-zone `zAtW3` (nine-zone lesson one level
    up: `SubBracket2V.lean:160-166`). -/
def kvE2_sepOuterConsistent (zs : ZoneSpec 3) : Prop :=
  zs = kvE2_sep_zPastX3 ∨ zs = kvE2_sep_zAtX3 ∨ zs = kvE2_sep_zXW3 ∨
    zs = kvE2_sep_zAtW3 ∨ zs = kvE2_sep_zWT3 ∨ zs = kvE2_sep_zAtT3 ∨ zs = kvE2_sep_zFutT3

/-- The nine consistent INNER zones for a LEFT-interior σ (`x < x1 < w < t`) — the
    VERBATIM pattern set of `kvE_subBracket2V_gate_holds_of_honest`'s conclusion
    (`SubBracket2V.lean:1400-1408`), including both witness self-zones `zAtX1`/`zAtW`,
    so the honest discharge consumes that landed lemma directly. -/
def kvE2_sepInnerConsistentL (zs : ZoneSpec 4) : Prop :=
  zs = Fin.cons (true, false) (Fin.cons (true, false) (Fin.cons (true, false) (fun _ => (true, false)))) ∨
  zs = Fin.cons (true, false) (Fin.cons (true, false) (Fin.cons (false, false) (fun _ => (true, false)))) ∨
  zs = Fin.cons (true, false) (Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false)))) ∨
  zs = Fin.cons (false, false) (Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false)))) ∨
  zs = Fin.cons (false, true) (Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false)))) ∨
  zs = Fin.cons (false, true) (Fin.cons (false, false) (Fin.cons (false, true) (fun _ => (true, false)))) ∨
  zs = Fin.cons (false, true) (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (true, false)))) ∨
  zs = Fin.cons (false, true) (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, false)))) ∨
  zs = Fin.cons (false, true) (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, true))))

/-- **Depth-2 joint gate** (arity-3 lift of the per-σ gate `SubBracket2V.lean:232-234`):
    (i) OUTER off-fiber falsity — a sub whose atom-layer restriction to `[w,x,t]`
    disagrees with `qnf.1` is negative; (ii) OUTER seven-zone consistency — a positive
    sub's fresh witness sits in a consistent placement; (iii) INNER off-fiber falsity for
    every positive sub (its own depth-1 quant layer is on-fiber); (iv) INNER nine-zone
    consistency for LEFT-interior positives (the class the landed per-σ kit serves; the
    exact syntactic clause the O4 `hgate` derivation needs, `SubBracket2V.lean:1872-1877`). -/
def kvE2_sepGate {sig : MonadicSignature} (qnf : NormalForm sig 2 3) : Prop :=
  (∀ σ : NormalForm sig 1 4, nf0_dropFresh σ.1 ≠ qnf.1 → qnf.2 σ = false) ∧
  (∀ σ : NormalForm sig 1 4, ¬ kvE2_sepOuterConsistent (nf0_zoneSpec σ.1) →
    qnf.2 σ = false) ∧
  (∀ σ : NormalForm sig 1 4, qnf.2 σ = true →
    ∀ τ : NormalForm sig 0 5, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false) ∧
  (∀ σ : NormalForm sig 1 4, qnf.2 σ = true → nf0_zoneSpec σ.1 = kvE2_sep_zXW3 →
    ∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1), ¬ kvE2_sepInnerConsistentL zs →
      σ.2 (nf0_assemble zs χ σ.1) = false)

/-! ## Task 334 Phases 1-2 (RELOCATED above the carrier) — order-type-disjunction index

The order-type-disjunction index and per-disjunct validity predicate (built in Phases 1-2 and
originally sited below the carrier) are relocated here so `kvE2_sepBody` can be rewired to
enumerate `kvE2_sepArr'` (Phase 6). Verbatim; only the file position changed. The Phase-1 spike
THEOREMS and the Phase-4/5 three-way cuts remain below (they consume the coincidence brick and are
not needed to DEFINE the carrier). See the Phase-1/2 banners further down for the paper grounding
(Lemma 3.2(1), md:77; §5 coincidence, md:168-173). -/

/-- Order-type index for the 2-owner spike: the relative placement of the foreign owner τ's
    χ-witness against σ's fresh anchor `x1_σ` on the merged anchor set `{x1_σ, x1_τ, w}`. Ties are a
    first-class order-type (Lemma 3.2(1), md:77; §5 coincidence, md:168-173). -/
inductive KvE2SepSpikeOrderType where
  /-- τ's χ-witness STRICTLY BELOW `x1_σ` (`x < x1_τ < x1_σ`): reads σ's OPEN `zXU` bit. -/
  | strictBefore
  /-- τ's χ-witness STRICTLY ABOVE `x1_σ` (`x1_σ < x1_τ < w`): reads σ's OPEN `zUW` bit. -/
  | strictAfter
  /-- τ's χ-witness COINCIDENT at `x1_σ` (`x1_τ = x1_σ`): reads σ's CLOSED `zAtX1L` bit. -/
  | coincident
deriving DecidableEq

/-- The 2-owner order-type disjunction list (Lemma 3.2(1) disjuncts over the merged anchor set,
    md:77): the coincidence order-type is a first-class disjunct. -/
def kvE2_sepSpikeOrderTypes : List KvE2SepSpikeOrderType :=
  [.strictBefore, .strictAfter, .coincident]

/-- A k-owner weak order on the merged anchor set `A`: one entry per positive owner carrying BOTH
    its placement tag (relative to `w`, driving the F5 zone-bit read) AND its cross-owner **rank** —
    the position of the owner's fresh anchor in the merged ascending chain `{x1_σ, x1_τ, …}`
    (Lemma 3.2(1), md:77: one global order over the union of both owners' points). Two owners whose
    anchors interleave differently (`x1_σ < x1_τ` vs `x1_τ < x1_σ`) receive DISTINCT rank tuples, so
    they are now DISTINGUISHABLE — the cross-owner data task 337's `.holds` builder consumes. The
    placement tag stays the 3-value per-owner type (F5: strict→OPEN, coincident→CLOSED); the ℕ rank
    is the orthogonal merged-chain position. -/
abbrev KvE2SepWeakOrder (sig : MonadicSignature) :=
  List (NormalForm sig 1 4 × KvE2SepSpikeOrderType × List ℕ)

/-- The order-type tag list is exhaustive: every tag is a member. -/
theorem kvE2_sepSpikeOrderTypes_complete (tag : KvE2SepSpikeOrderType) :
    tag ∈ kvE2_sepSpikeOrderTypes := by
  cases tag <;> decide

/-- **Cross-owner distinguishability witness** (the defining property this task installs). Two
    owners `σ, τ` interleaving as `x1_σ < x1_τ` (ranks `0 < 1`) versus `x1_τ < x1_σ` (ranks `1 < 0`)
    yield DISTINCT enriched weak orders. Under the task-334 carrier `List (NormalForm sig 1 4 ×
    KvE2SepSpikeOrderType)` both collapse to the SAME value `[(σ, c), (τ, c)]` — the exact
    under-specification (report 337/02 Q2) that blocked task 337. The added ℕ rank makes them
    unequal, giving task 337's `.holds` builder the cross-owner data to consume. -/
example {sig : MonadicSignature} (σ τ : NormalForm sig 1 4) :
    ([(σ, KvE2SepSpikeOrderType.coincident, [0, 1, 2]),
      (τ, KvE2SepSpikeOrderType.coincident, [3, 4, 5])]
        : KvE2SepWeakOrder sig)
      ≠ [(σ, KvE2SepSpikeOrderType.coincident, [3, 4, 5]),
         (τ, KvE2SepSpikeOrderType.coincident, [0, 1, 2])] := by
  simp

/-- **Per-slot global-index tuple** (task 340): for an owner at merged-chain position `k` in an
    `n`-owner arrangement, the region-primary placeholder index tuple `(k, n+k, 2n+k)` — the global
    indices of its region-rank-0/1/2 slots. Behavior-preserving: `giOf = regionRank·n + k`
    reproduces 339's region-primary/owner-secondary order EXACTLY (Phase 2). Consistency
    `i₀<i₁<i₂` holds (`k < n+k < 2n+k`). Phase 5 replaces this with the honest model value order. -/
def kvE2_sepPlaceholderTuple (n k : ℕ) : List ℕ := [k, n + k, 2 * n + k]

/-- **Finite tuple index range** (task 340): all `(ℕ × ℕ × ℕ)` global-index tuples with each
    component `< 3n`. Finite, `DecidableEq`, `decide`-able; contains every `kvE2_sepPlaceholderTuple
    n k` for `k < n` and every order-consistent interleaving over `n` owners' ≤3 region ranks. This
    is the per-slot index the enumeration ranges over, replacing the single `List.range n` rank. -/
def kvE2_sepIdxTuples (n : ℕ) : List (List ℕ) :=
  (List.range (3 * n)).flatMap (fun a =>
    (List.range (3 * n)).flatMap (fun b =>
      (List.range (3 * n)).map (fun c => [a, b, c])))

/-- The placeholder tuple for position `k < n` is in the tuple index range. -/
theorem kvE2_sepPlaceholderTuple_mem (n k : ℕ) (hk : k < n) :
    kvE2_sepPlaceholderTuple n k ∈ kvE2_sepIdxTuples n := by
  rw [kvE2_sepIdxTuples, kvE2_sepPlaceholderTuple, List.mem_flatMap]
  refine ⟨k, List.mem_range.mpr (by omega), ?_⟩
  rw [List.mem_flatMap]
  refine ⟨n + k, List.mem_range.mpr (by omega), ?_⟩
  rw [List.mem_map]
  exact ⟨2 * n + k, List.mem_range.mpr (by omega), rfl⟩

/-- **Enumeration richness** (task 340 Phase 5.1): every order-consistent global-index tuple whose
    three components each lie in `[0, 3n)` is enumerated by `kvE2_sepIdxTuples n`. This is the
    strict generalization of `kvE2_sepPlaceholderTuple_mem` (SW:740) from the region-primary
    placeholder shape `(k, n+k, 2n+k)` to an ARBITRARY in-range tuple `(a, b, c)` — the membership
    fact the model-value-faithful honest order (`kvE2_sepHonestOrder`) needs: an owner's three
    slots' actual global positions in M's value order are all `< 3n` (there are `3n` slots total),
    so the honest tuple is a member by exactly the same three `List.mem_flatMap`/`List.mem_range`
    steps. Reads no zone bit; abstract-ℕ only (F4/LITMUS clean). -/
theorem kvE2_sepIdxTuple_mem_of_lt (n a b c : ℕ)
    (ha : a < 3 * n) (hb : b < 3 * n) (hc : c < 3 * n) :
    [a, b, c] ∈ kvE2_sepIdxTuples n := by
  rw [kvE2_sepIdxTuples, List.mem_flatMap]
  refine ⟨a, List.mem_range.mpr ha, ?_⟩
  rw [List.mem_flatMap]
  refine ⟨b, List.mem_range.mpr hb, ?_⟩
  rw [List.mem_map]
  exact ⟨c, List.mem_range.mpr hc, rfl⟩

/-- **Variable-length `N`-bound index enumeration** (task 340 Phase 3): every list of length `L`
    whose entries all lie in `[0, n)`. Generalizes the fixed length-3 `kvE2_sepIdxTuples` to the
    per-owner block length `L = (kvE2_sepSlotBlock σ).length`, the arity the per-INDIVIDUAL-slot
    refinement requires (a region provably holds ≥2 base slots, so a fixed 3-tuple is unfaithful —
    postmortem constraint). Finite, terminating, `decide`-able; the `N`-bound replaces the WRONG
    `3*n` bound (report 08). Reads no zone bit; abstract-ℕ only (F4/F5/LITMUS clean). -/
def kvE2_sepIdxTuplesN (n : ℕ) : ℕ → List (List ℕ)
  | 0 => [[]]
  | L + 1 =>
    (List.range n).flatMap (fun a => (kvE2_sepIdxTuplesN n L).map (fun t => a :: t))

/-- **Enumeration richness at the `N` bound** (task 340 Phase 3): every list whose entries all lie in
    `[0, n)` is enumerated by `kvE2_sepIdxTuplesN n` at its own length. The variable-length strict
    generalization of `kvE2_sepIdxTuple_mem_of_lt` — the membership fact the per-slot honest order
    (whose per-owner payload is `(kvE2_sepSlotBlock σ).length`-long with every entry `< N`) needs to
    be a member of the enumeration. Same `List.mem_flatMap`/`List.mem_range`/`List.mem_map` technique,
    now by induction on the list. Reads no zone bit; abstract-ℕ only (F4/LITMUS clean). -/
theorem kvE2_sepIdxTupleN_mem_of_forall_lt (n : ℕ) :
    ∀ (l : List ℕ), (∀ x ∈ l, x < n) → l ∈ kvE2_sepIdxTuplesN n l.length := by
  intro l
  induction l with
  | nil => intro _; simp [kvE2_sepIdxTuplesN]
  | cons a t ih =>
    intro h
    rw [List.length_cons, kvE2_sepIdxTuplesN, List.mem_flatMap]
    refine ⟨a, List.mem_range.mpr (h a List.mem_cons_self), ?_⟩
    rw [List.mem_map]
    exact ⟨t, ih (fun x hx => h x (List.mem_cons_of_mem _ hx)), rfl⟩

/-! ### Task 340 Phase 5 — abstract lex-rank kernel (model-agnostic sort spec)

The honest-order construction (steps 2/4/5 of the Phase-5 map) reduces every one of its obligations
— the in-range bound `i < 3n`, the per-owner consistency `i₀<i₁<i₂`, the cross-owner `Nodup`, and
the cross-region `a<u'<b` monotonicity — to ONE spec: the rank of an element in a finite family
under a STRICT total order is `< n`, strictly monotone, and injective. The construction takes the
strict order to be the LEX product `(model value, slot index)`, so that ties in the model value are
broken by the (always distinct) slot index. This is exactly what the distinctness crux (SW:1585)
forces: distinct owners may share witness values, so value alone is NOT a strict order; the index
tiebreak makes it one WITHOUT any (unprovable) value-distinctness hypothesis. Pure `Finset.card`
combinatorics; reads no model data; abstract over any `LinearOrder` (F4/LITMUS clean). -/

/-- **Rank of `i` under a strict family** (task 340 Phase 5): the number of indices whose `g`-value
    is strictly smaller. When `g` is injective this is the 0-based position of `i` in the ascending
    sort of `g` — a bijection `Fin n → Fin n`'s underlying position map. The honest order uses
    `g = (model value, slot index)` in the lex order. -/
def kvE2_ordRank {β : Type*} [LinearOrder β] {n : ℕ} (g : Fin n → β) (i : Fin n) : ℕ :=
  (Finset.univ.filter (fun j => g j < g i)).card

/-- Every rank is `< n` (it counts a subset of the `n-1` indices other than `i`). Gives the
    `< 3n` enumeration-membership bound the honest tuple feeds to `kvE2_sepIdxTuple_mem_of_lt`. -/
theorem kvE2_ordRank_lt {β : Type*} [LinearOrder β] {n : ℕ} (g : Fin n → β) (i : Fin n) :
    kvE2_ordRank g i < n := by
  have hsub : Finset.univ.filter (fun j => g j < g i) ⊆ Finset.univ.erase i := by
    intro j hj
    rw [Finset.mem_filter] at hj
    rw [Finset.mem_erase]
    refine ⟨?_, Finset.mem_univ j⟩
    rintro rfl
    exact lt_irrefl _ hj.2
  have hn : 0 < n := i.pos
  calc kvE2_ordRank g i ≤ (Finset.univ.erase i).card := Finset.card_le_card hsub
    _ = n - 1 := by
        rw [Finset.card_erase_of_mem (Finset.mem_univ i), Finset.card_univ, Fintype.card_fin]
    _ < n := by omega

/-- **Strict monotonicity** (task 340 Phase 5): a strictly smaller `g`-value has a strictly smaller
    rank. Supplies BOTH the per-owner consistency `i₀<i₁<i₂` (from the bundle chain `val₀<val₁<val₂`)
    AND the cross-region `a<u'<b` monotonicity (from `val(σ,2) < val(τ,1)`). Needs only the single
    strict inequality — no value-distinctness. -/
theorem kvE2_ordRank_strictMono {β : Type*} [LinearOrder β] {n : ℕ} (g : Fin n → β) {a b : Fin n}
    (hab : g a < g b) : kvE2_ordRank g a < kvE2_ordRank g b := by
  have hsub : Finset.univ.filter (fun j => g j < g a) ⊆ Finset.univ.filter (fun j => g j < g b) := by
    intro j hj
    rw [Finset.mem_filter] at hj ⊢
    exact ⟨hj.1, lt_trans hj.2 hab⟩
  apply Finset.card_lt_card
  rw [Finset.ssubset_iff_of_subset hsub]
  refine ⟨a, Finset.mem_filter.mpr ⟨Finset.mem_univ a, hab⟩, ?_⟩
  rw [Finset.mem_filter]
  push_neg
  intro _
  exact le_refl _

/-- **Injectivity** (task 340 Phase 5): an injective family has an injective rank — the ranks are
    `n` distinct values in `[0,n)`, hence a permutation of `Fin n`. Supplies the cross-owner `Nodup`
    conjunct of `kvE2_sepDisjValid` (the honest `g = (value, index)` is injective in its index
    component, so distinct slots get distinct ranks even when model values coincide). -/
theorem kvE2_ordRank_injective {β : Type*} [LinearOrder β] {n : ℕ} (g : Fin n → β)
    (hg : Function.Injective g) : Function.Injective (kvE2_ordRank g) := by
  intro a b hrank
  by_contra hne
  rcases lt_trichotomy (g a) (g b) with h | h | h
  · exact absurd hrank (Nat.ne_of_lt (kvE2_ordRank_strictMono g h))
  · exact hne (hg h)
  · exact absurd hrank.symm (Nat.ne_of_lt (kvE2_ordRank_strictMono g h))

/-- **General order-type-disjunction index** (Lemma 3.2(1), md:77): the finite `List` of weak
    orders on `A` — all per-owner (placement tag × per-slot global-index tuple) assignments, built as
    the cartesian `foldr` product over `kvE2_sepPos qnf`, with the tuple component ranging over
    `kvE2_sepIdxTuples n` (`n = |pos|`). Finite, terminating, `decide`-able. Enumerating index tuples
    alongside tags is what makes two differently-interleaving models yield DISTINCT weak orders; the
    order-CONSISTENCY of the tuple (per-owner `i₀<i₁<i₂` and cross-owner `Nodup`) is the cross-owner
    conjunct of `kvE2_sepDisjValid`. Replaces the abandoned `kvE2_sepArrL/R` carrier. -/
noncomputable def kvE2_sepOrderTypes {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) : List (KvE2SepWeakOrder sig) :=
  let n := (kvE2_sepAllSlots qnf).length
  (kvE2_sepPos qnf).foldr
    (fun σ acc =>
      kvE2_sepSpikeOrderTypes.flatMap (fun tag =>
        (kvE2_sepIdxTuplesN n (kvE2_sepSlotBlock σ).length).flatMap
          (fun t => acc.map (fun wo => (σ, tag, t) :: wo))))
    [[]]

/-- σ's canonical (model) placement tag, read from its realized outer zone class. -/
noncomputable def kvE2_sepModelTag {sig : MonadicSignature}
    (σ : NormalForm sig 1 4) : KvE2SepSpikeOrderType :=
  if nf0_zoneSpec σ.1 = kvE2_sep_zXW3 then .strictBefore else .strictAfter

/-- The model weak order: each positive owner tagged with its canonical zone-class placement AND
    its rank = its index in `kvE2_sepPos` (via `zipIdx`, so the ranks are `0,1,…,n-1` — distinct,
    hence order-consistent). The strict per-owner tags remain honestly-undischargeable (the genuine
    Rabinovich `r_0=z_0` asymmetry, SW:1421-1429), so this stays a conditional disjunct. -/
noncomputable def kvE2_sepModelOrder {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) : KvE2SepWeakOrder sig :=
  (kvE2_sepPos qnf).zipIdx.map
    (fun p => (p.1, kvE2_sepModelTag p.1, (kvE2_sepSlotBlock p.1).map (kvE2_sepSlotIndexOf qnf)))

/-- The two interior outer classes are distinct (index-0 order bits differ). -/
private theorem kvE2_sep_zWT3_ne_zXW3 : kvE2_sep_zWT3 ≠ kvE2_sep_zXW3 := by
  intro h
  have h0 := congrFun h (0 : Fin 3)
  simp only [kvE2_sep_zWT3, kvE2_sep_zXW3, Fin.cons_zero, Prod.mk.injEq] at h0
  exact Bool.false_ne_true h0.1

/-- **Closed-zone leaf — placement-generic forward read** (task 336). At a coincidence tie the
    disjunct is validated by σ's CLOSED self-zone bit at its own fresh type (§5 meet channel,
    md:168-173), fed by the preserved axiom-clean coincidence discharges. The self-zone key is
    placement-appropriate: LEFT-interior owners (`nf0_zoneSpec σ.1 = kvE2_sep_zXW3`, `x < x1 < w`)
    read the CLOSED `zAtX1L` bit (`kvE2_sepCoincidentAnchor_discharge`); every other placement
    (in particular RIGHT-interior owners, `nf0_zoneSpec σ.1 = kvE2_sep_zWT3`, `w < x1 < t`) reads
    the CLOSED `zAtX1R` bit (`kvE2_sepCoincidentAnchor_discharge_R`). Both branches read CLOSED
    self-zone keys — never an OPEN key (F5). -/
def kvE2_sepClosedLeafStub {sig : MonadicSignature}
    (σ : NormalForm sig 1 4) : Bool :=
  if nf0_zoneSpec σ.1 = kvE2_sep_zXW3 then
    kvE2_sepBits σ kvE2_sep_zAtX1L (nf0_projFresh σ.1)
  else
    kvE2_sepBits σ kvE2_sep_zAtX1R (nf0_projFresh σ.1)

/-- **Per-owner disjunct validity.** Strict placements read σ's OPEN zone bit; the `coincident` tie
    reads σ's CLOSED `zAtX1L` bit via the forward stub. No disjunct conflates open and closed keys
    (F5). -/
def kvE2_sepDisjValidOwner {sig : MonadicSignature}
    (σ : NormalForm sig 1 4) : KvE2SepSpikeOrderType → Bool
  | .strictBefore => kvE2_sepBits σ kvE_sub2_zXU (nf0_projFresh σ.1)
  | .strictAfter  => kvE2_sepBits σ kvE_sub2_zUW (nf0_projFresh σ.1)
  | .coincident   => kvE2_sepClosedLeafStub σ

/-- **Per-owner index-tuple consistency** (task 340, the linear-extension conjunct): the owner's
    per-slot global-index tuple `(i₀,i₁,i₂)` EXTENDS its region order — `i₀ < i₁ < i₂`, i.e. the
    global index of its region-rank-0 slot precedes its fresh anchor (rank 1) precedes its region-2
    slot (`lXU<lX1<lUW` left, `rWX1<rX1<rX1T` right). A linear extension of each owner's region
    partial order (Lemma 3.2(1), md:77: one consistent global order over the union). Reads NO zone
    bit (F5 clean); an abstract ℕ compare, never an `x1 < e_i` model literal (F4/LITMUS clean). -/
def kvE2_sepConsistentTuple (t : List ℕ) : Bool :=
  decide (t.getD 0 0 < t.getD 1 0 ∧ t.getD 1 0 < t.getD 2 0)

/-- **Per-disjunct validity** (faithful replacement of the additive `kvE2_sepValid`): a weak order
    is valid iff (i) every per-owner placement is admitted by the owner's arrangement-appropriate
    zone bit (the per-order-type read, F5), (ii) every owner's per-slot global-index tuple EXTENDS
    its region order (`kvE2_sepConsistentTuple`, the task-340 linear-extension conjunct), AND (iii)
    the cross-owner anchor-base indices `i₀` are pairwise distinct (`Nodup`) — the per-owner extension
    plus distinct anchor bases give a genuine total order over the union (Lemma 3.2(1), md:77: one
    consistent global order). The consistency conjunct (ii) is what makes the a<u'<b cross-region
    interleaving admissible while keeping each owner's own slots region-ordered. Reads no zone bit in
    (ii)/(iii). NOT an additive filter over a flat slot union. -/
noncomputable def kvE2_sepDisjValid {sig : MonadicSignature}
    (_qnf : NormalForm sig 2 3) (wo : KvE2SepWeakOrder sig) : Bool :=
  wo.all (fun p => kvE2_sepDisjValidOwner p.1 p.2.1)
    && wo.all (fun p => kvE2_sepConsistentBlock p.1 p.2.2)
    && decide (wo.flatMap (fun p => p.2.2)).Nodup

/-- **The faithful carrier** (replacing `kvE2_sepArrL/R`): the valid order-type disjuncts, the
    per-order-type filter of the disjunction index (Lemma 3.2(1), md:77). -/
noncomputable def kvE2_sepArr' {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) : List (KvE2SepWeakOrder sig) :=
  (kvE2_sepOrderTypes qnf).filter (kvE2_sepDisjValid qnf)

/-- The carrier's validity predicate is decidable, so `kvE2_sepArr'` is `decide`-able. -/
noncomputable instance kvE2_sepArr'_decidable {sig : MonadicSignature} (qnf : NormalForm sig 2 3) :
    DecidablePred (fun wo : KvE2SepWeakOrder sig => kvE2_sepDisjValid qnf wo = true) :=
  fun wo => inferInstanceAs (Decidable (kvE2_sepDisjValid qnf wo = true))

/-- **Structural non-emptiness helper** (generalized over rank bound `n`, tag map `f`, and the
    `zipIdx` start `s`): the `(tag, rank)` assignment tagging each owner by `f` and ranking it by its
    consecutive `zipIdx` index `s, s+1, …` — all `< n` — is reachable in the cartesian rank×tag
    enumeration. Both `kvE2_sepModelOrder` and `kvE2_sepCoincidentOrder` are instances (`s = 0`,
    `n = |pos|`). -/
private theorem kvE2_sepOrderTypes_mem_aux {sig : MonadicSignature} (n : ℕ)
    (f : NormalForm sig 1 4 → KvE2SepSpikeOrderType)
    (gt : ℕ → List ℕ)
    (L : List (NormalForm sig 1 4)) (s : ℕ)
    (hb : ∀ i, i < L.length → gt (s + i) ∈ kvE2_sepIdxTuples n) :
    (L.zipIdx s).map (fun p => (p.1, f p.1, gt p.2)) ∈
      L.foldr
        (fun σ acc =>
          kvE2_sepSpikeOrderTypes.flatMap (fun tag =>
            (kvE2_sepIdxTuples n).flatMap (fun t => acc.map (fun wo => (σ, tag, t) :: wo))))
        [[]] := by
  induction L generalizing s with
  | nil => simp
  | cons σ L ih =>
    simp only [List.zipIdx_cons, List.map_cons, List.foldr_cons]
    rw [List.mem_flatMap]
    refine ⟨f σ, kvE2_sepSpikeOrderTypes_complete _, ?_⟩
    rw [List.mem_flatMap]
    refine ⟨gt s, ?_, ?_⟩
    · simpa using hb 0 (by simp)
    · rw [List.mem_map]
      refine ⟨(L.zipIdx (s + 1)).map (fun p => (p.1, f p.1, gt p.2)), ?_, rfl⟩
      exact ih (s + 1) (fun i hi => by
        have h := hb (i + 1) (by simpa using hi)
        rwa [show s + (i + 1) = s + 1 + i by omega] at h)

/-- **Enumeration-parametric membership** (task 340 Phase 3 flip): the per-OWNER payload assignment
    `gt` (each `gt σ` drawn from σ's own tuple set `enum σ`) is reachable in the σ-dependent cartesian
    tag×tuple enumeration. The generalization of `kvE2_sepOrderTypes_mem_aux` from a fixed tuple set +
    position-indexed `gt` to a per-owner `enum`/`gt` — the shape the variable-length per-slot payload
    (`block.map …`) needs. -/
private theorem kvE2_sepOrderTypes_mem_aux' {sig : MonadicSignature}
    (f : NormalForm sig 1 4 → KvE2SepSpikeOrderType)
    (enum : NormalForm sig 1 4 → List (List ℕ))
    (gt : NormalForm sig 1 4 → List ℕ)
    (L : List (NormalForm sig 1 4)) (s : ℕ)
    (hb : ∀ σ ∈ L, gt σ ∈ enum σ) :
    (L.zipIdx s).map (fun p => (p.1, f p.1, gt p.1)) ∈
      L.foldr
        (fun σ acc =>
          kvE2_sepSpikeOrderTypes.flatMap (fun tag =>
            (enum σ).flatMap (fun t => acc.map (fun wo => (σ, tag, t) :: wo))))
        [[]] := by
  induction L generalizing s with
  | nil => simp
  | cons σ L ih =>
    simp only [List.zipIdx_cons, List.map_cons, List.foldr_cons]
    rw [List.mem_flatMap]
    refine ⟨f σ, kvE2_sepSpikeOrderTypes_complete _, ?_⟩
    rw [List.mem_flatMap]
    refine ⟨gt σ, hb σ List.mem_cons_self, ?_⟩
    rw [List.mem_map]
    exact ⟨(L.zipIdx (s + 1)).map (fun p => (p.1, f p.1, gt p.1)),
      ih (s + 1) (fun τ hτ => hb τ (List.mem_cons_of_mem σ hτ)), rfl⟩

/-- **Enumeration-parametric owner projection** (task 340 Phase 3 flip): every disjunct in the
    σ-dependent enumeration carries exactly `L` in order. Generalizes `kvE2_sepOrderTypes_owners_aux`
    over an arbitrary per-owner `enum`. -/
private theorem kvE2_sepOrderTypes_owners_aux' {sig : MonadicSignature}
    (enum : NormalForm sig 1 4 → List (List ℕ))
    (L : List (NormalForm sig 1 4)) {wo : KvE2SepWeakOrder sig}
    (hwo : wo ∈
      L.foldr
        (fun σ acc =>
          kvE2_sepSpikeOrderTypes.flatMap (fun tag =>
            (enum σ).flatMap (fun t => acc.map (fun wo => (σ, tag, t) :: wo))))
        [[]]) :
    wo.map Prod.fst = L := by
  induction L generalizing wo with
  | nil => simp only [List.foldr_nil, List.mem_singleton] at hwo; subst hwo; rfl
  | cons σ L ih =>
    simp only [List.foldr_cons] at hwo
    rw [List.mem_flatMap] at hwo
    obtain ⟨tag, _, hwo⟩ := hwo
    rw [List.mem_flatMap] at hwo
    obtain ⟨t, _, hwo⟩ := hwo
    rw [List.mem_map] at hwo
    obtain ⟨wo', hwo', rfl⟩ := hwo
    simp only [List.map_cons, ih hwo']

/-- The model-order disjunct is present in the enumeration index (F2, structural level). -/
theorem kvE2_sepModelOrder_mem_orderTypes {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) :
    kvE2_sepModelOrder qnf ∈ kvE2_sepOrderTypes qnf := by
  rw [kvE2_sepModelOrder, kvE2_sepOrderTypes]
  refine kvE2_sepOrderTypes_mem_aux' kvE2_sepModelTag _
    (fun σ => (kvE2_sepSlotBlock σ).map (kvE2_sepSlotIndexOf qnf)) (kvE2_sepPos qnf) 0
    (fun σ hσ => ?_)
  have h := kvE2_sepIdxTupleN_mem_of_forall_lt (kvE2_sepAllSlots qnf).length
    ((kvE2_sepSlotBlock σ).map (kvE2_sepSlotIndexOf qnf)) (fun y hy => by
      obtain ⟨s, hs, rfl⟩ := List.mem_map.mp hy
      exact kvE2_sepSlotIndexOf_lt qnf (kvE2_sepMem_allSlots qnf hσ hs))
  rwa [List.length_map] at h

/-- **Structural non-vacuity** (F2, md:77): whenever the honest model arrangement's disjunct is
    valid — the selection guaranteed by the honest bundle (full semantic discharge is Phase 8) —
    the faithful carrier `kvE2_sepArr'` is non-empty, because the model-order disjunct is present in
    the enumeration and passes the per-order-type filter. -/
theorem kvE2_sepArr'_mem_modelOrder {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3)
    (hvalid : kvE2_sepDisjValid qnf (kvE2_sepModelOrder qnf) = true) :
    kvE2_sepModelOrder qnf ∈ kvE2_sepArr' qnf := by
  rw [kvE2_sepArr', List.mem_filter]
  exact ⟨kvE2_sepModelOrder_mem_orderTypes qnf, hvalid⟩

/-! ## Phase 4 — `wo`-driven slot ordering (the rewire consuming the cross-owner rank) -/

/-- **wo-driven owner ordering** (Phase 4): the owners of `wo` listed in ascending merged-chain
    RANK order — the cross-owner order `wo` now carries. This is what the rewired `kvE2_sepBody`
    consumes to realize each disjunct's OWN cross-owner slot order, replacing the discarded-`_wo`
    body's fixed `kvE2_sepPos` order (the exact root bug SW:835-836 that stalled task 337's plans).
    Because `mergeSort` is a permutation of its input, `kvE2_sepOrderOwners wo` carries the same
    owner MULTISET as `wo` — but sequenced by the rank the disjunct realizes. -/
def kvE2_sepOrderOwners {sig : MonadicSignature}
    (wo : KvE2SepWeakOrder sig) : List (NormalForm sig 1 4) :=
  (wo.mergeSort (fun a b => decide (a.2.2.getD 0 0 ≤ b.2.2.getD 0 0))).map Prod.fst

/-- **Owner merged-chain rank read** (task 339): σ's merged-chain rank as recorded in `wo` (338's
    per-owner rank field, consumed AS-IS). Owners not present in `wo` default to `0` (never occurs
    on the enumeration index, where `wo.map Prod.fst = kvE2_sepPos qnf`). -/
def kvE2_sepOwnerRank {sig : MonadicSignature}
    (wo : KvE2SepWeakOrder sig) (σ : NormalForm sig 1 4) : ℕ :=
  ((wo.find? (fun p => decide (p.1 = σ))).map (fun p => p.2.2.getD 0 0)).getD 0

/-- **Per-slot global index reader** (task 340): the single global index of slot `s` under `wo` —
    read from the owner's per-slot index tuple `(i₀,i₁,i₂)` at `s`'s region rank. Owners not in `wo`
    default to tuple `(0,0,0)` (never occurs on the enumeration index). This is the abstract ℕ the
    single-level merge key compares — a total order on the full slot multiset (Rabinovich Def 3.1
    single global chain), NOT a region×owner product. Reads no zone bit (F5 clean); never a model
    relative-position literal (F4/LITMUS clean — the index is structural carrier data). -/
noncomputable def kvE2_sepSlotGIdx {sig : MonadicSignature}
    (wo : KvE2SepWeakOrder sig) (s : KvE2SepSlot sig) : ℕ :=
  let t := ((wo.find? (fun p => decide (p.1 = kvE2_sepSlotSub s))).map
    (fun p => p.2.2)).getD []
  t.getD (kvE2_sepBlockPos s) 0

/-- **Single-level per-slot global-index merge key** (task 340): compares two slots by their global
    index `kvE2_sepSlotGIdx wo`. Region rank is NO LONGER primary — a region-2 slot of one owner can
    precede a region-1 slot of another (the honest `a<u'<b` cross-region case, report 06, that the
    dropped 339 region-primary lex could not express). The index is a total order over the union of
    all owners' points (Def 3.1 single global chain), constrained to extend each owner's region order
    by the `kvE2_sepDisjValid` consistency conjunct. Abstract ℕ compare; F4/F5/LITMUS clean. -/
noncomputable def kvE2_sepSlotMergeLe {sig : MonadicSignature}
    (wo : KvE2SepWeakOrder sig) (a b : KvE2SepSlot sig) : Bool :=
  decide (kvE2_sepSlotGIdx wo a ≤ kvE2_sepSlotGIdx wo b)

/-- The wo-ordered joint LEFT slot list — a genuine POINT-LEVEL cross-owner merge (task 339): the
    per-owner LEFT region slots, `mergeSort`ed by the composite point-level key
    `kvE2_sepSlotMergeLe wo` (region rank primary, owner merged-chain rank secondary). Because
    `mergeSort` is a permutation of its input, this carries the SAME slot multiset as the block
    union `(kvE2_sepOrderOwners wo).flatMap kvE2_sepSlotsLFor` (so every per-owner slot-membership
    fact survives, `List.mergeSort_perm`), but individual owner slots are now interleaved into ONE
    globally key-sorted chain (Rabinovich Def 3.1, single global chain over the union of points),
    NOT sequenced as contiguous owner blocks. Genuinely CONSUMES `wo` (via `kvE2_sepOwnerRank`).
    Never asserts flat-union monotone validity; the joint sorted-realization builder is task 337. -/
noncomputable def kvE2_sepSlotsLOf {sig : MonadicSignature}
    (wo : KvE2SepWeakOrder sig) : List (KvE2SepSlot sig) :=
  ((kvE2_sepOrderOwners wo).flatMap kvE2_sepSlotsLFor).mergeSort (kvE2_sepSlotMergeLe wo)

/-- The wo-ordered joint RIGHT slot list (right mirror of `kvE2_sepSlotsLOf`): point-level merge of
    the per-owner RIGHT region slots by the same composite key. Consumes `wo`. -/
noncomputable def kvE2_sepSlotsROf {sig : MonadicSignature}
    (wo : KvE2SepWeakOrder sig) : List (KvE2SepSlot sig) :=
  ((kvE2_sepOrderOwners wo).flatMap kvE2_sepSlotsRFor).mergeSort (kvE2_sepSlotMergeLe wo)

/-- Structural helper: every disjunct in the `foldr` enumeration carries EXACTLY the positive
    owners in `kvE2_sepPos` order (one prepended entry per owner). -/
private theorem kvE2_sepOrderTypes_owners_aux {sig : MonadicSignature} (n : ℕ)
    (L : List (NormalForm sig 1 4)) {wo : KvE2SepWeakOrder sig}
    (hwo : wo ∈
      L.foldr
        (fun σ acc =>
          kvE2_sepSpikeOrderTypes.flatMap (fun tag =>
            (kvE2_sepIdxTuples n).flatMap (fun t => acc.map (fun wo => (σ, tag, t) :: wo))))
        [[]]) :
    wo.map Prod.fst = L := by
  induction L generalizing wo with
  | nil => simp only [List.foldr_nil, List.mem_singleton] at hwo; subst hwo; rfl
  | cons σ L ih =>
    simp only [List.foldr_cons] at hwo
    rw [List.mem_flatMap] at hwo
    obtain ⟨tag, _, hwo⟩ := hwo
    rw [List.mem_flatMap] at hwo
    obtain ⟨t, _, hwo⟩ := hwo
    rw [List.mem_map] at hwo
    obtain ⟨wo', hwo', rfl⟩ := hwo
    simp only [List.map_cons, ih hwo']

/-- Every `wo` in the enumeration index has owner-projection exactly `kvE2_sepPos qnf`. -/
theorem kvE2_sepOrderTypes_owners {sig : MonadicSignature} (qnf : NormalForm sig 2 3)
    {wo : KvE2SepWeakOrder sig} (hwo : wo ∈ kvE2_sepOrderTypes qnf) :
    wo.map Prod.fst = kvE2_sepPos qnf := by
  rw [kvE2_sepOrderTypes] at hwo
  exact kvE2_sepOrderTypes_owners_aux' _ _ hwo

/-- Every positive owner appears in the wo-ordered owner list (rank-reordering permutes, never
    drops, the owner multiset): the membership fact the `kvE2_sepBody_extract` rewire consumes. -/
theorem kvE2_sepMem_orderOwners {sig : MonadicSignature} (qnf : NormalForm sig 2 3)
    {wo : KvE2SepWeakOrder sig} (hwo : wo ∈ kvE2_sepOrderTypes qnf)
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf) :
    σ ∈ kvE2_sepOrderOwners wo := by
  rw [kvE2_sepOrderOwners]
  have hperm := (List.mergeSort_perm wo (fun a b => decide (a.2.2.getD 0 0 ≤ b.2.2.getD 0 0))).map Prod.fst
  rw [kvE2_sepOrderTypes_owners qnf hwo] at hperm
  exact hperm.mem_iff.mpr hσ

/-- **Point-level merge membership** (task 339, LEFT): every per-owner LEFT slot of a positive
    owner is a member of the merged chain `kvE2_sepSlotsLOf wo`. Because the merge is a
    `mergeSort` (hence a permutation, `List.mergeSort_perm`) of the block union
    `(kvE2_sepOrderOwners wo).flatMap kvE2_sepSlotsLFor`, membership reduces to the block-union
    membership `kvE2_sepMem_orderOwners` — the same permutation technique as
    `kvE2_sepMem_orderOwners` itself. This is the `hmemL` witness the `kvE2_sepBody_extract`
    rewire consumes against the point-level def. -/
theorem kvE2_sepSlotsLOf_mem {sig : MonadicSignature} (qnf : NormalForm sig 2 3)
    {wo : KvE2SepWeakOrder sig} (hwo : wo ∈ kvE2_sepOrderTypes qnf)
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf)
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2_sepSlotsLFor σ) :
    s ∈ kvE2_sepSlotsLOf wo := by
  rw [kvE2_sepSlotsLOf]
  exact (List.mergeSort_perm _ _).mem_iff.mpr
    (List.mem_flatMap.mpr ⟨σ, kvE2_sepMem_orderOwners qnf hwo hσ, hs⟩)

/-- **Point-level merge membership** (task 339, RIGHT mirror of `kvE2_sepSlotsLOf_mem`). -/
theorem kvE2_sepSlotsROf_mem {sig : MonadicSignature} (qnf : NormalForm sig 2 3)
    {wo : KvE2SepWeakOrder sig} (hwo : wo ∈ kvE2_sepOrderTypes qnf)
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf)
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2_sepSlotsRFor σ) :
    s ∈ kvE2_sepSlotsROf wo := by
  rw [kvE2_sepSlotsROf]
  exact (List.mergeSort_perm _ _).mem_iff.mpr
    (List.mem_flatMap.mpr ⟨σ, kvE2_sepMem_orderOwners qnf hwo hσ, hs⟩)

/-- **Below-anchor cross-region interleaving** (task 340, the defining property this redesign
    installs — the case report 06 proved 339's region-primary key could NOT express). With a per-slot
    global index in which owner σ's region-2 slot `lUW` receives a STRICTLY SMALLER index than owner
    τ's region-1 anchor slot `lX1` — the honest `a < u' < b` configuration (σ's `lUW` witness `u'`
    below τ's anchor `b = x1_τ`) — the single-level merge key places `.lUW σ` BEFORE `.lX1 τ`.
    Region rank is no longer primary: a region-2 slot precedes a foreign region-1 slot. Under any
    2-level region-primary key (339) this is impossible, since region 1 < region 2 always forces
    `.lX1 τ` first regardless of owner data (report 06 Experiment C rank-independence). -/
example {sig : MonadicSignature} (σ τ : NormalForm sig 1 4) (χ : NormalForm sig 0 1)
    (wo : KvE2SepWeakOrder sig)
    (hlt : kvE2_sepSlotGIdx wo (.lUW σ χ) < kvE2_sepSlotGIdx wo (.lX1 τ)) :
    kvE2_sepSlotMergeLe wo (.lUW σ χ) (.lX1 τ) = true := by
  simp only [kvE2_sepSlotMergeLe, decide_eq_true_eq]
  omega

/-- **Same-owner region monotonicity of the global index** (task 340): whenever an owner's index
    tuple extends its region order (`i₀ < i₁ < i₂`, the `kvE2_sepDisjValid` consistency conjunct),
    the global index is strictly increasing in region rank, so the merge keeps each owner's own
    slots in `lXU < lX1 < lUW` order (preserving the same-owner `rank<rank ⟹ index<index` fact the
    ⇒-extraction consumes). Here shown for σ's `lX1` (region 1) below `lUW` (region 2). -/
example {sig : MonadicSignature} (σ : NormalForm sig 1 4) (χ : NormalForm sig 0 1)
    (wo : KvE2SepWeakOrder sig)
    (hlt : kvE2_sepSlotGIdx wo (.lX1 σ) < kvE2_sepSlotGIdx wo (.lUW σ χ)) :
    kvE2_sepSlotMergeLe wo (.lX1 σ) (.lUW σ χ) = true := by
  simp only [kvE2_sepSlotMergeLe, decide_eq_true_eq]
  omega

/-! ## The joint carrier (O1) -/

/-- **`kvE2_sepBody` — the joint separate-content shared-witness carrier** (task 321 v7
    Phase 7 O1; rewired task 334 Phase 6). Model-independent: disjuncts enumerate the ORDER-TYPE
    DISJUNCTION `kvE2_sepArr'` — one FLAT bracket per VALID weak order on the merged anchor set
    (Lemma 3.2(1), md:77), where each disjunct reads the zone bit appropriate to its own arrangement
    (strict disjuncts the OPEN `zXU`/`zUW` bits, the coincidence disjunct the CLOSED `zAtX1L` bit;
    §5 meet-typed shared point, md:168-173). The bracket (`kvE2_sepDisjunct`) carries one shared
    `ptW`, per-σ E[Σ]-atom fresh slots, refined-conjunction segments, and the joint endpoint
    conjunction at the fixed anchors (Lemma 3.2(2), md:78: everything over the two free variables
    `(x, t)`), built over the canonical per-owner region-block slot lists `kvE2_sepSlotsL/R qnf`.
    Gate-failure branch is the empty disjunction (its `holds` is `False`). Non-vacuity now follows
    from `kvE2_sepArr' ≠ []` (the coincidence disjunct is admitted by the closed channel), NEVER
    from a valid slot permutation of the flat union (which can be empty — handoff 05). -/
noncomputable def kvE2_sepBody {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) : VVecEA2 :=
  @dite _ (kvE2_sepGate qnf) (Classical.dec _)
    (fun _ =>
      { disjuncts :=
          -- Task 334 Phase 6: rewired OFF `List.Perm.refl`/the additive `kvE2_sepArrL/R`
          -- flat-union permutation-filter ONTO the order-type disjunction `kvE2_sepArr'`
          -- (Lemma 3.2(1), md:77). One disjunct per VALID weak order (per-order-type validity);
          -- the bracket carries the region-partitioned Def 3.1 point/segment content over the
          -- canonical per-owner region blocks. Non-vacuity now follows from `kvE2_sepArr' ≠ []`
          -- (the coincidence disjunct is admitted by the closed channel), never from a valid slot
          -- permutation of the flat union (which can be empty — handoff 05).
          -- Task 338 Phase 4: CONSUME `wo` — each disjunct realizes its OWN cross-owner slot
          -- order `kvE2_sepSlotsLOf/ROf wo` (the per-owner blocks sequenced by wo's merged-chain
          -- rank), NEVER the discarded-`_wo` fixed concatenation `kvE2_sepSlotsL/R qnf` (root bug).
          (kvE2_sepArr' qnf).map fun wo =>
            kvE2_sepDisjunct charBase charK qnf (kvE2_sepSlotsLOf wo) (kvE2_sepSlotsROf wo) })
    (fun _ => { disjuncts := [] })

/-- Gate-failure computation (mirror of the landed `_gate_fail` house pattern). -/
theorem kvE2_sepBody_gate_fail {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    (h : ¬ kvE2_sepGate qnf) :
    kvE2_sepBody charBase charK qnf = { disjuncts := [] } := by
  simp only [kvE2_sepBody]
  exact dif_neg h

/-- **O2 — arrangement-product membership collapse** for the joint enumeration: on the
    gate-true branch, the carrier holds at the fixed endpoints iff SOME pair of left/right
    interleavings' disjunct holds. Carrier-specific instantiation of the landed structural
    collapse `VVecEA2.holds_flatMap_map` (`NavigatedSpine.lean:220`), applying by
    `rw [dif_pos]` because the disjunct builder and both interleaving sets are TOP-LEVEL
    defs (crux failed-closer-3 lesson: no `let`-buried `S_L`/`S_R`/`mkDisjunct`). -/
theorem kvE2_sepBody_holds_iff {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    (hg : kvE2_sepGate qnf)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (x t : M.carrier) :
    (kvE2_sepBody charBase charK qnf).holds M atomMap x t ↔
      ∃ wo ∈ kvE2_sepArr' qnf,
        (kvE2_sepDisjunct charBase charK qnf (kvE2_sepSlotsLOf wo) (kvE2_sepSlotsROf wo)).2.holds
          M atomMap x t := by
  simp only [kvE2_sepBody]
  rw [dif_pos hg]
  simp only [VVecEA2.holds, List.mem_map]
  constructor
  · rintro ⟨vea, ⟨wo, hwo, rfl⟩, hvea⟩
    exact ⟨wo, hwo, hvea⟩
  · rintro ⟨wo, hwo, hvea⟩
    exact ⟨_, ⟨wo, hwo, rfl⟩, hvea⟩

/-! ## O1b — non-vacuity (fresh analog of `kvE_subBracket2V_nonvacuous`,
`SubBracket2V.lean:1425`; FM-vac discipline: the honest configuration must take the
gate-true branch and produce a NON-empty disjunct list, so no later direction can close
vacuously). -/

/-- Bool bridge: a truth-value biconditional forces Bool equality. -/
private theorem kvE2_sep_boolEq {b c : Bool} (h : (b = true) ↔ (c = true)) : b = c := by
  cases b <;> cases c <;> simp_all

/-- A trivially-total relation is pairwise on any list. -/
private theorem kvE2_sep_pairwise_of_forall {α : Type} {R : α → α → Prop} :
    ∀ {l : List α}, (∀ a b, R a b) → l.Pairwise R
  | [], _ => List.Pairwise.nil
  | _ :: _, h => List.Pairwise.cons (fun b _ => h _ b) (kvE2_sep_pairwise_of_forall h)

/-- Pairwise over a `flatMap` from within-block pairwise + cross-block totality on a
    duplicate-free spine. -/
private theorem kvE2_sep_pairwise_flatMap {α β : Type} {R : β → β → Prop}
    {f : α → List β} {l : List α} (hnd : l.Nodup)
    (hin : ∀ a ∈ l, (f a).Pairwise R)
    (hcross : ∀ a ∈ l, ∀ b ∈ l, a ≠ b → ∀ x ∈ f a, ∀ y ∈ f b, R x y) :
    (l.flatMap f).Pairwise R := by
  induction l with
  | nil => exact List.Pairwise.nil
  | cons a as ih =>
    rw [List.flatMap_cons, List.pairwise_append]
    obtain ⟨hna, hnd'⟩ := List.nodup_cons.mp hnd
    refine ⟨hin a List.mem_cons_self,
      ih hnd' (fun b hb => hin b (List.mem_cons_of_mem _ hb))
        (fun b hb c hc => hcross b (List.mem_cons_of_mem _ hb) c (List.mem_cons_of_mem _ hc)),
      ?_⟩
    intro x hx y hy
    obtain ⟨b, hb, hyb⟩ := List.mem_flatMap.mp hy
    exact hcross a List.mem_cons_self b (List.mem_cons_of_mem _ hb)
      (fun he => hna (he ▸ hb)) x hx y hyb

/-- Same-owner rank monotonicity satisfies the validity relation (the `if`-true branch). -/
private theorem kvE2_sepSlotLe_same {sig : MonadicSignature} {a b : KvE2SepSlot sig}
    (hsub : kvE2_sepSlotSub a = kvE2_sepSlotSub b)
    (h : kvE2_sepSlotRank a ≤ kvE2_sepSlotRank b) : kvE2_sepSlotLe a b = true := by
  unfold kvE2_sepSlotLe
  rw [if_pos hsub]
  exact decide_eq_true h

/-- Distinct owners satisfy the validity relation exactly when cross-σ bit-compatible
    (`kvE2_sepCompat`) — the task 333/334 replacement of the unconditional `_of_sub_ne`. -/
private theorem kvE2_sepSlotLe_of_ne_compat {sig : MonadicSignature} {a b : KvE2SepSlot sig}
    (h : kvE2_sepSlotSub a ≠ kvE2_sepSlotSub b)
    (hc : kvE2_sepCompat a b = true) : kvE2_sepSlotLe a b = true := by
  unfold kvE2_sepSlotLe
  rw [if_neg h]
  exact hc

/-- Same-owner, rank-sorted lists are `kvE2_sepSlotLe`-pairwise (bridges a rank-only
    `Pairwise` to the validity relation on a single-σ block). -/
private theorem kvE2_sep_pairwise_rank_same {sig : MonadicSignature}
    {l : List (KvE2SepSlot sig)} {σ : NormalForm sig 1 4}
    (hsub : ∀ s ∈ l, kvE2_sepSlotSub s = σ)
    (hr : l.Pairwise (fun a b => kvE2_sepSlotRank a ≤ kvE2_sepSlotRank b)) :
    l.Pairwise (fun a b => kvE2_sepSlotLe a b = true) := by
  induction l with
  | nil => exact List.Pairwise.nil
  | cons x xs ih =>
    rw [List.pairwise_cons] at hr ⊢
    refine ⟨fun b hb => kvE2_sepSlotLe_same ?_ (hr.1 b hb),
      ih (fun s hs => hsub s (List.mem_cons_of_mem _ hs)) hr.2⟩
    rw [hsub x List.mem_cons_self, hsub b (List.mem_cons_of_mem _ hb)]

/-- Every slot of σ's canonical LEFT block is owned by σ. -/
private theorem kvE2_sepSlotsLFor_sub {sig : MonadicSignature} {σ : NormalForm sig 1 4}
    {s : KvE2SepSlot sig} (h : s ∈ kvE2_sepSlotsLFor σ) : kvE2_sepSlotSub s = σ := by
  unfold kvE2_sepSlotsLFor at h
  split at h
  · rcases List.mem_append.mp h with h' | h'
    · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp h'; rfl
    · rcases List.mem_cons.mp h' with rfl | h''
      · rfl
      · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp h''; rfl
  · split at h
    · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp h; rfl
    · exact (List.not_mem_nil h).elim

/-- Every slot of σ's canonical RIGHT block is owned by σ. -/
private theorem kvE2_sepSlotsRFor_sub {sig : MonadicSignature} {σ : NormalForm sig 1 4}
    {s : KvE2SepSlot sig} (h : s ∈ kvE2_sepSlotsRFor σ) : kvE2_sepSlotSub s = σ := by
  unfold kvE2_sepSlotsRFor at h
  split at h
  · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp h; rfl
  · split at h
    · rcases List.mem_append.mp h with h' | h'
      · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp h'; rfl
      · rcases List.mem_cons.mp h' with rfl | h''
        · rfl
        · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp h''; rfl
    · exact (List.not_mem_nil h).elim

/-- σ's canonical LEFT block respects the region-rank order (`XU* < x1 < UW*`). -/
private theorem kvE2_sepSlotsLFor_rankPairwise {sig : MonadicSignature}
    (σ : NormalForm sig 1 4) :
    (kvE2_sepSlotsLFor σ).Pairwise
      (fun a b => kvE2_sepSlotRank a ≤ kvE2_sepSlotRank b) := by
  unfold kvE2_sepSlotsLFor
  split
  · refine List.pairwise_append.mpr ⟨?_, ?_, ?_⟩
    · exact List.pairwise_map.mpr
        (kvE2_sep_pairwise_of_forall fun _ _ => (Nat.zero_le _))
    · refine List.pairwise_cons.mpr ⟨?_, ?_⟩
      · intro b hb
        obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hb
        exact (Nat.le_succ 1)
      · exact List.pairwise_map.mpr
          (kvE2_sep_pairwise_of_forall fun _ _ => (Nat.le_refl _))
    · intro s hs b _
      obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hs
      exact (Nat.zero_le _)
  · split
    · exact List.pairwise_map.mpr
        (kvE2_sep_pairwise_of_forall fun _ _ => (Nat.le_refl _))
    · exact List.Pairwise.nil

/-- σ's canonical LEFT block is a valid same-owner arrangement. -/
private theorem kvE2_sepSlotsLFor_pairwise {sig : MonadicSignature}
    (σ : NormalForm sig 1 4) :
    (kvE2_sepSlotsLFor σ).Pairwise (fun a b => kvE2_sepSlotLe a b = true) :=
  kvE2_sep_pairwise_rank_same (fun _ hs => kvE2_sepSlotsLFor_sub hs)
    (kvE2_sepSlotsLFor_rankPairwise σ)

/-- σ's canonical RIGHT block respects the region-rank order (`WX1* < x1 < X1T*`). -/
private theorem kvE2_sepSlotsRFor_rankPairwise {sig : MonadicSignature}
    (σ : NormalForm sig 1 4) :
    (kvE2_sepSlotsRFor σ).Pairwise
      (fun a b => kvE2_sepSlotRank a ≤ kvE2_sepSlotRank b) := by
  unfold kvE2_sepSlotsRFor
  split
  · exact List.pairwise_map.mpr
      (kvE2_sep_pairwise_of_forall fun _ _ => (Nat.le_refl _))
  · split
    · refine List.pairwise_append.mpr ⟨?_, ?_, ?_⟩
      · exact List.pairwise_map.mpr
          (kvE2_sep_pairwise_of_forall fun _ _ => (Nat.zero_le _))
      · refine List.pairwise_cons.mpr ⟨?_, ?_⟩
        · intro b hb
          obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hb
          exact (Nat.le_succ 1)
        · exact List.pairwise_map.mpr
            (kvE2_sep_pairwise_of_forall fun _ _ => (Nat.le_refl _))
      · intro s hs b _
        obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hs
        exact (Nat.zero_le _)
    · exact List.Pairwise.nil

/-- σ's canonical RIGHT block is a valid same-owner arrangement. -/
private theorem kvE2_sepSlotsRFor_pairwise {sig : MonadicSignature}
    (σ : NormalForm sig 1 4) :
    (kvE2_sepSlotsRFor σ).Pairwise (fun a b => kvE2_sepSlotLe a b = true) :=
  kvE2_sep_pairwise_rank_same (fun _ hs => kvE2_sepSlotsRFor_sub hs)
    (kvE2_sepSlotsRFor_rankPairwise σ)

/-- The positive-sub spine is duplicate-free (`Finset.univ.toList` + filter). -/
private theorem kvE2_sepPos_nodup {sig : MonadicSignature} (qnf : NormalForm sig 2 3) :
    (kvE2_sepPos qnf).Nodup :=
  (Finset.nodup_toList _).filter _

-- REMOVED (task 334 Phase 6): the two FALSE scaffolds `kvE2_sepSlotsL_valid`/`kvE2_sepSlotsR_valid`
-- (which asserted `kvE2_sepValid (kvE2_sepSlotsL/R qnf) = true` — the identity interleaving of the
-- flat union is a valid additive arrangement). They were documented FALSE post-switch (the identity
-- interleaving need not be cross-σ compat; handoff 05) and carried the two `sorryAx` placeholders
-- that contaminated `kvE2_sepBody_nonvacuous`. The rewired non-vacuity routes through the order-type
-- disjunction `kvE2_sepArr'` (`kvE2_sepArr'_mem_modelOrder`), which is axiom-clean. (Risk R5.)

/-- Dropping the fresh coordinate of a REALIZED arity-4 depth-0 base recovers the
    arity-3 base realized at the same three points (Def 3.1 env-restriction channel):
    both sides answer every `[w,x,t]`-atom by the same model truth. -/
private theorem kvE2_sep_dropFresh_eq {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) {x1 w x t : M.carrier}
    (σ1 : NormalForm sig 0 4) (r : NormalForm sig 0 3)
    (hσ : ∀ a : AtomKind sig 4,
      atom_eval M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) a ↔ σ1 a = true)
    (hr : ∀ a : AtomKind sig 3,
      atom_eval M (Fin.cons w (Fin.cons x (fun _ => t))) a ↔ r a = true) :
    nf0_dropFresh σ1 = r := by
  funext a
  match a with
  | .pred p i =>
    have h4 := hσ (.pred p i.succ)
    have h3 := hr (.pred p i)
    simp only [atom_eval, Fin.cons_succ] at h4 h3
    simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ]
    exact kvE2_sep_boolEq (h4.symm.trans h3)
  | .order i j hne =>
    have h4 := hσ (.order i.succ j.succ (fun he => hne (Fin.succ_injective _ he)))
    have h3 := hr (.order i j hne)
    simp only [atom_eval, Fin.cons_succ] at h4 h3
    simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ]
    exact kvE2_sep_boolEq (h4.symm.trans h3)

/-- **Arity-3 outer zone consistency** (fresh analog of the private arity-4
    `kvE_sub2V_zone_consistent`, `SubBracket2V.lean:1270` — template only, new code):
    a point realized in some zone relative to the honest `[w,x,t]` (with `x < w < t`)
    sits in one of the SEVEN consistent outer zones (Def 3.1, md:61-74). -/
private theorem kvE2_sep_zone3_consistent {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (w x t u : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (zs : ZoneSpec 3)
    (hz : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs u) :
    kvE2_sepOuterConsistent zs := by
  have h0 := hz ⟨0, by omega⟩
  have h1 := hz ⟨1, by omega⟩
  have h2 := hz ⟨2, by omega⟩
  simp only [Fin.cons] at h0 h1 h2
  have hzs : ∀ (p0 p1 p2 : Bool × Bool),
      zs ⟨0, by omega⟩ = p0 → zs ⟨1, by omega⟩ = p1 → zs ⟨2, by omega⟩ = p2 →
      zs = Fin.cons p0 (Fin.cons p1 (fun _ => p2)) := by
    intro p0 p1 p2 e0 e1 e2
    funext i
    match i with
    | ⟨0, _⟩ => simpa only [Fin.cons] using e0
    | ⟨1, _⟩ => simpa only [Fin.cons] using e1
    | ⟨2, _⟩ => simpa only [Fin.cons] using e2
  have hxt : x < t := hxw.trans hwt
  rcases lt_trichotomy u x with hux | rfl | hux
  · -- u < x : zPastX3
    have huw : u < w := hux.trans hxw
    have hut : u < t := hux.trans hxt
    exact Or.inl (hzs _ _ _
      (Prod.ext_iff.mpr ⟨h0.1.mp huw, k1v_bool_eq_false h0.2 (lt_asymm huw)⟩)
      (Prod.ext_iff.mpr ⟨h1.1.mp hux, k1v_bool_eq_false h1.2 (lt_asymm hux)⟩)
      (Prod.ext_iff.mpr ⟨h2.1.mp hut, k1v_bool_eq_false h2.2 (lt_asymm hut)⟩))
  · -- u = x : zAtX3
    exact Or.inr (Or.inl (hzs _ _ _
      (Prod.ext_iff.mpr ⟨h0.1.mp hxw, k1v_bool_eq_false h0.2 (lt_asymm hxw)⟩)
      (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_irrefl _),
        k1v_bool_eq_false h1.2 (lt_irrefl _)⟩)
      (Prod.ext_iff.mpr ⟨h2.1.mp hxt, k1v_bool_eq_false h2.2 (lt_asymm hxt)⟩)))
  · -- x < u : split against w
    rcases lt_trichotomy u w with huw | rfl | huw
    · -- x < u < w : zXW3
      have hut : u < t := huw.trans hwt
      exact Or.inr (Or.inr (Or.inl (hzs _ _ _
        (Prod.ext_iff.mpr ⟨h0.1.mp huw, k1v_bool_eq_false h0.2 (lt_asymm huw)⟩)
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hux), h1.2.mp hux⟩)
        (Prod.ext_iff.mpr ⟨h2.1.mp hut, k1v_bool_eq_false h2.2 (lt_asymm hut)⟩))))
    · -- u = w : zAtW3 (the shared-witness self-zone)
      exact Or.inr (Or.inr (Or.inr (Or.inl (hzs _ _ _
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_irrefl _),
          k1v_bool_eq_false h0.2 (lt_irrefl _)⟩)
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hux), h1.2.mp hux⟩)
        (Prod.ext_iff.mpr ⟨h2.1.mp hwt, k1v_bool_eq_false h2.2 (lt_asymm hwt)⟩)))))
    · -- w < u : split against t
      rcases lt_trichotomy u t with hut | rfl | hut
      · -- w < u < t : zWT3
        exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inl (hzs _ _ _
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm huw), h0.2.mp huw⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hux), h1.2.mp hux⟩)
          (Prod.ext_iff.mpr ⟨h2.1.mp hut, k1v_bool_eq_false h2.2 (lt_asymm hut)⟩))))))
      · -- u = t : zAtT3
        exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inl (hzs _ _ _
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm huw), h0.2.mp huw⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hux), h1.2.mp hux⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_irrefl _),
            k1v_bool_eq_false h2.2 (lt_irrefl _)⟩)))))))
      · -- t < u : zFutT3
        exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (hzs _ _ _
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm huw), h0.2.mp huw⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hux), h1.2.mp hux⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_asymm hut), h2.2.mp hut⟩)))))))

/-- **The depth-2 joint gate holds for an honest `qnf`** (the arity-3 lift of
    `kvE_subBracket2V_gate_holds_of_honest`, `SubBracket2V.lean:1392`): from an honest
    depth-2 realization at `[w,x,t]` under `x < w < t`, all four gate clauses hold —
    (i)/(ii) by realizing each positive sub and reading its atom layer against the model
    (Prop 4.2, md:100-101); (iii) via the landed depth-1 fold decomposition
    (`nf_eval_depth1_fold_iff`, `CarrierKv.lean:466`); (iv) by CONSUMING the landed per-σ
    honest gate lemma at the realized fresh witness. -/
theorem kvE2_sepGate_holds_of_honest {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    kvE2_sepGate qnf := by
  obtain ⟨h_atom, h_quant⟩ := h
  refine ⟨?_, ?_, ?_, ?_⟩
  · -- (i) outer off-fiber falsity
    intro σ hne
    cases hb : qnf.2 σ with
    | false => rfl
    | true =>
      obtain ⟨x1, hσ⟩ := (h_quant σ).mpr hb
      exact absurd
        (kvE2_sep_dropFresh_eq M σ.1 qnf.1
          ((nf_eval_depth1_fold_iff M _ σ).mp hσ).1 h_atom) hne
  · -- (ii) outer seven-zone consistency
    intro σ hncons
    cases hb : qnf.2 σ with
    | false => rfl
    | true =>
      obtain ⟨x1, hσ⟩ := (h_quant σ).mpr hb
      have hσ_atom := ((nf_eval_depth1_fold_iff M _ σ).mp hσ).1
      have hz : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)))
          (nf0_zoneSpec σ.1) x1 := by
        intro i
        constructor
        · have h1 := hσ_atom (.order 0 i.succ (Fin.succ_ne_zero i).symm)
          simp only [atom_eval, Fin.cons_zero, Fin.cons_succ] at h1
          exact h1
        · have h1 := hσ_atom (.order i.succ 0 (Fin.succ_ne_zero i))
          simp only [atom_eval, Fin.cons_zero, Fin.cons_succ] at h1
          exact h1
      exact absurd (kvE2_sep_zone3_consistent M w x t x1 hxw hwt _ hz) hncons
  · -- (iii) inner off-fiber falsity for every positive sub
    intro σ hb
    obtain ⟨x1, hσ⟩ := (h_quant σ).mpr hb
    exact ((nf_eval_depth1_fold_iff M _ σ).mp hσ).2.2
  · -- (iv) inner nine-zone consistency for LEFT-interior positives
    intro σ hb hzone
    obtain ⟨x1, hσ⟩ := (h_quant σ).mpr hb
    have hσ_atom := ((nf_eval_depth1_fold_iff M _ σ).mp hσ).1
    -- Read the two left-interior order bits off the placement guard (the zone-spec
    -- components ARE σ.1's fresh-coupling order bits, `nf0_zoneSpec` def).
    have hbit_xx1 : (nf0_zoneSpec σ.1 ⟨1, by omega⟩).2 = true := by
      rw [congrFun hzone ⟨1, by omega⟩]; decide
    have hbit_x1w : (nf0_zoneSpec σ.1 ⟨0, by omega⟩).1 = true := by
      rw [congrFun hzone ⟨0, by omega⟩]; decide
    -- Transfer the bits to real order facts through the realized atom layer.
    have hxx1 : x < x1 := by
      have h1 := hσ_atom (.order (Fin.succ ⟨1, by omega⟩) 0 (Fin.succ_ne_zero ⟨1, by omega⟩))
      simp only [atom_eval, Fin.cons] at h1
      exact h1.mpr hbit_xx1
    have hx1w : x1 < w := by
      have h1 := hσ_atom (.order 0 (Fin.succ ⟨0, by omega⟩) (Fin.succ_ne_zero ⟨0, by omega⟩).symm)
      simp only [atom_eval, Fin.cons] at h1
      exact h1.mpr hbit_x1w
    exact fun zs χ hncons =>
      (kvE_subBracket2V_gate_holds_of_honest σ M x1 w x t hxx1 hx1w hwt hσ).2 zs χ hncons

/-- **Per-σ honest witness bundle (LEFT list, left-interior σ)** — task 333 Phase 2
    point-map step 1 (the ⇐-direction of Rabinovich Lemma 3.2(1), md:77). From the qnf
    honest realization, a LEFT-interior positive σ (`x < x1_σ < w`, guard `hzone`) has at
    its extracted fresh anchor `x1_σ` a real witness point in `(x, x1_σ)` for every 1-type
    in `kvE2_sepS σ kvE_sub2_zXU`, and one in `(x1_σ, w)` for every 1-type in
    `kvE2_sepS σ kvE_sub2_zUW`. These are exactly the `hrealXU`/`hrealUW` inputs the joint
    slot sort consumes to place each foreign χ-slot on the model-correct side of `x1_σ` (so
    that `kvE2_sepCompat` holds via `kvE2_sepCompat_lX1_eq`/`_lX1_after_eq`). Reuses the
    do-not-edit extractor `kvE_subBracket2_complete_extract` (`SubBracket2.lean:606`); no new
    model reasoning, and NO `x1 < e_i` model-order literal is exposed (LITMUS: the anchor
    `x1_σ` is an interval endpoint of the witness bundle, never compared to a slot index). -/
private theorem kvE2_sepHonestBundleL {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (σ : NormalForm sig 1 4) (hσpos : σ ∈ kvE2_sepPos qnf)
    (hzone : nf0_zoneSpec σ.1 = kvE2_sep_zXW3) :
    ∃ x1 : M.carrier, x < x1 ∧ x1 < w ∧
      (∀ χ ∈ kvE2_sepS σ kvE_sub2_zXU,
        ∃ u : M.carrier, x < u ∧ u < x1 ∧ nf_eval_nf M 0 1 (fun _ => u) χ) ∧
      (∀ χ ∈ kvE2_sepS σ kvE_sub2_zUW,
        ∃ u : M.carrier, x1 < u ∧ u < w ∧ nf_eval_nf M 0 1 (fun _ => u) χ) := by
  have hb : qnf.2 σ = true := (List.mem_filter.mp hσpos).2
  obtain ⟨h_atom, h_quant⟩ := h
  obtain ⟨x1, hσ⟩ := (h_quant σ).mpr hb
  obtain ⟨hσ_atom, _h_off, _h_zonefwd, hbelowXU, hbelowUW, _hbelowWT⟩ :=
    kvE_subBracket2_complete_extract σ M x1 w x t hσ
  have hbit_xx1 : (nf0_zoneSpec σ.1 ⟨1, by omega⟩).2 = true := by
    rw [congrFun hzone ⟨1, by omega⟩]; decide
  have hbit_x1w : (nf0_zoneSpec σ.1 ⟨0, by omega⟩).1 = true := by
    rw [congrFun hzone ⟨0, by omega⟩]; decide
  have hxx1 : x < x1 := by
    have h1 := hσ_atom (.order (Fin.succ ⟨1, by omega⟩) 0 (Fin.succ_ne_zero ⟨1, by omega⟩))
    simp only [atom_eval, Fin.cons] at h1
    exact h1.mpr hbit_xx1
  have hx1w : x1 < w := by
    have h1 := hσ_atom (.order 0 (Fin.succ ⟨0, by omega⟩) (Fin.succ_ne_zero ⟨0, by omega⟩).symm)
    simp only [atom_eval, Fin.cons] at h1
    exact h1.mpr hbit_x1w
  refine ⟨x1, hxx1, hx1w, ?_, ?_⟩
  · intro χ hχ
    exact hbelowXU χ (List.mem_filter.mp hχ).2
  · intro χ hχ
    exact hbelowUW χ (List.mem_filter.mp hχ).2

/-- **Per-owner RIGHT honest bundle** (task 334 Phase 7, C13 — the completeness-side mirror of
    `kvE2_sepHonestBundleL` :1207). From an honest `qnf` and a RIGHT-interior owner σ
    (`nf0_zoneSpec σ.1 = kvE2_sep_zWT3`, i.e. `w < x1 < t`), extract σ's fresh anchor `x1`
    strictly inside `(w, t)` together with real witnesses for each of its `zWX1`-positive
    (region `(w, x1)`) and `zWT`-positive (region `(x1, t)`) 1-types. Symmetric to the LEFT
    bundle: the LEFT bundle serves `zXU`/`zUW` around a `(x, w)`-interior anchor; this serves
    `zWX1`/`zWT` around a `(w, t)`-interior anchor (`kvE_sub2_zWT` reads `x1 < v < t` for a
    right-interior σ, per the placement-generic comment :102-105).

    Proof route (mirrors L, per plan 03 Phase-7 tasks): `qnf`'s depth-2 quant layer supplies σ's
    model witness `x1`; the depth-1 fold decomposition `nf_eval_depth1_fold_iff` (the extractor's
    generic zone-forward channel, the SAME `h_zone` iff feeding `kvE_subBracket2_complete_extract`)
    fired REVERSE (`.mpr`) at zones `zWX1`/`zWT` yields the region witnesses, whose intervals are
    decoded by the pure order fact `kvE_sub2_zoneHolds_cons_iff` (the Phase-3 region structure;
    Def 3.1 exterior/interior β, md:66-74; Lemma 3.2(1) ⇐ honest arrangement, md:77). No
    `x1 < e_i` literal (F4); QF point types only (F1); disjunction realized non-vacuously per
    honest owner (F2). -/
private theorem kvE2_sepHonestBundleR {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (σ : NormalForm sig 1 4) (hσpos : σ ∈ kvE2_sepPos qnf)
    (hzone : nf0_zoneSpec σ.1 = kvE2_sep_zWT3) :
    ∃ x1 : M.carrier, w < x1 ∧ x1 < t ∧
      (∀ χ ∈ kvE2_sepS σ kvE2_sep_zWX1,
        ∃ u : M.carrier, w < u ∧ u < x1 ∧ nf_eval_nf M 0 1 (fun _ => u) χ) ∧
      (∀ χ ∈ kvE2_sepS σ kvE_sub2_zWT,
        ∃ u : M.carrier, x1 < u ∧ u < t ∧ nf_eval_nf M 0 1 (fun _ => u) χ) := by
  have hb : qnf.2 σ = true := (List.mem_filter.mp hσpos).2
  obtain ⟨_h_atom, h_quant⟩ := h
  obtain ⟨x1, hσ⟩ := (h_quant σ).mpr hb
  obtain ⟨hσ_atom, h_zone, _h_off⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hσ
  have hbit_wx1 : (nf0_zoneSpec σ.1 ⟨0, by omega⟩).2 = true := by
    rw [congrFun hzone ⟨0, by omega⟩]; decide
  have hbit_x1t : (nf0_zoneSpec σ.1 ⟨2, by omega⟩).1 = true := by
    rw [congrFun hzone ⟨2, by omega⟩]; decide
  have hwx1 : w < x1 := by
    have h1 := hσ_atom (.order (Fin.succ ⟨0, by omega⟩) 0 (Fin.succ_ne_zero ⟨0, by omega⟩))
    simp only [atom_eval, Fin.cons] at h1
    exact h1.mpr hbit_wx1
  have hx1t : x1 < t := by
    have h1 := hσ_atom (.order 0 (Fin.succ ⟨2, by omega⟩) (Fin.succ_ne_zero ⟨2, by omega⟩).symm)
    simp only [atom_eval, Fin.cons] at h1
    exact h1.mpr hbit_x1t
  refine ⟨x1, hwx1, hx1t, ?_, ?_⟩
  · intro χ hχ
    have hbit : σ.2 (nf0_assemble kvE2_sep_zWX1 χ σ.1) = true := (List.mem_filter.mp hχ).2
    obtain ⟨v, hz, hv⟩ := (h_zone kvE2_sep_zWX1 χ).mpr hbit
    obtain ⟨hp0, hp1, _, _⟩ :=
      (kvE_sub2_zoneHolds_cons_iff M x1 w x t v (true, false) (false, true) (false, true)
        (true, false)).mp hz
    exact ⟨v, hp1.2.mpr rfl, hp0.1.mpr rfl, hv⟩
  · intro χ hχ
    have hbit : σ.2 (nf0_assemble kvE_sub2_zWT χ σ.1) = true := (List.mem_filter.mp hχ).2
    obtain ⟨v, hz, hv⟩ := (h_zone kvE_sub2_zWT χ).mpr hbit
    obtain ⟨hp0, _, _, hp3⟩ :=
      (kvE_sub2_zoneHolds_cons_iff M x1 w x t v (false, true) (false, true) (false, true)
        (true, false)).mp hz
    exact ⟨v, hp0.2.mpr rfl, hp3.1.mpr rfl, hv⟩

/-- **Fresh-anchor / base-χ point distinctness — REDUCED FORM** (task 334 Phase 2).
    σ's fresh anchor `x1` realizes σ at env `[x1,w,x,t]`; its OWN depth-0 arity-1 base type is
    therefore `nf0_projFresh σ.1` (extracted by `nf_eval_nf0_cons_factor`). Hence any point `p`
    realizing a base type `χ` that DIFFERS from `nf0_projFresh σ.1` is distinct from `x1`
    (`nf_eval_unique` forces the two base types equal on coincidence). This is the honest,
    sorry-free, axiom-clean distinctness engine.

    IMPORTANT (make-or-break residual): the hypothesis `hχne : χ ≠ nf0_projFresh σ.1` is the
    genuine obstruction. Research established (and the crux investigation confirmed) that there
    is NO fresh-vs-base type-separation lemma, and the "E[Σ]-atom incompatible with a base type
    at a point" intuition is UNSOUND (`charK = existF` is existential; a point may satisfy both).
    So the distinctness `p ≠ x1` can only come from the base-type inequality `χ ≠ nf0_projFresh σ.1`,
    which is NOT dischargeable for arbitrary cross-owner base types — distinct positive owners may
    carry the same base type, and a foreign owner's χ-witness may coincide exactly with another
    owner's fresh anchor. See the Phase-2 blocker note in the plan. -/
theorem kvE2_sepFreshAnchor_ne_baseChiPoint {sig : MonadicSignature}
    (σ : NormalForm sig 1 4) (M : OrderedMonadicStructure sig)
    (x1 w x t : M.carrier)
    (hσ : nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (p : M.carrier) (χ : NormalForm sig 0 1)
    (hp : nf_eval_nf M 0 1 (fun _ => p) χ)
    (hχne : χ ≠ nf0_projFresh σ.1) :
    p ≠ x1 := by
  intro heq
  subst heq
  have hσ1 : nf_eval_nf M 0 4 (Fin.cons p (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1 :=
    hσ.1
  have hfresh : nf_eval_nf M 0 1 (fun _ => p) (nf0_projFresh σ.1) :=
    ((nf_eval_nf0_cons_factor M (Fin.cons w (Fin.cons x (fun _ => t))) p σ.1).mp hσ1).2.1
  exact hχne (nf_eval_unique M 0 1 (fun _ => p) χ (nf0_projFresh σ.1) hp hfresh)

/-- **CRUX VERIFICATION SPIKE — coincident-anchor discharge** (task 334 Phase 3, the
    front-loaded make-or-break). At a shared anchor `v = x1` (σ's fresh witness point), a
    foreign base type `χ` realized AT that point (`nf_eval_nf M 0 1 (fun _ => x1) χ`) discharges
    σ's CLOSED self-zone fold bit `kvE2_sepBits σ kvE2_sep_zAtX1L χ` — WITHOUT any `p ≠ x1`
    inequality. Route: the extractor's generic zone-forward channel
    (`SubBracket2.lean:614-618`, `∀ zs χ, (∃ v, zoneHolds env zs v ∧ v realizes χ) → bit = true`)
    fired at the closed self-zone `kvE2_sep_zAtX1L` with witness `v = x1` (`zoneHolds` at the
    anchor is a pure order fact given `x < x1 < w < t`). This is the Rabinovich §5 shared-anchor
    meet-type identification (md:168-173): the point genuinely realizes both σ's depth-1 fresh
    type and the foreign depth-0 `χ` (existential `charK`, NavigatedSpine:411), so the coincidence
    is DISCHARGED, not refuted. No extractor extension needed — the generic channel already
    quantifies over ALL zone specs including the closed self-zone. -/
theorem kvE2_sepCoincidentAnchor_discharge {sig : MonadicSignature}
    (σ : NormalForm sig 1 4) (M : OrderedMonadicStructure sig)
    (x1 w x t : M.carrier) (hxx1 : x < x1) (hx1w : x1 < w) (hwt : w < t)
    (hσ : nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (χ : NormalForm sig 0 1)
    (hp : nf_eval_nf M 0 1 (fun _ => x1) χ) :
    kvE2_sepBits σ kvE2_sep_zAtX1L χ = true := by
  obtain ⟨_, _, h_zonefwd, _, _, _⟩ := kvE_subBracket2_complete_extract σ M x1 w x t hσ
  have hx1t : x1 < t := lt_trans hx1w hwt
  refine h_zonefwd kvE2_sep_zAtX1L χ ⟨x1, ?_, hp⟩
  -- `zoneHolds env kvE2_sep_zAtX1L x1` is a pure order fact (v = x1: `x < x1 < w < t`).
  refine (kvE_sub2_zoneHolds_cons_iff M x1 w x t x1
    (false, false) (true, false) (false, true) (true, false)).mpr ?_
  refine ⟨⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_⟩⟩
  · exact iff_of_false (lt_irrefl _) (by decide)
  · exact iff_of_false (lt_irrefl _) (by decide)
  · exact iff_of_true hx1w rfl
  · exact iff_of_false (not_lt.mpr (le_of_lt hx1w)) (by decide)
  · exact iff_of_false (not_lt.mpr (le_of_lt hxx1)) (by decide)
  · exact iff_of_true hxx1 rfl
  · exact iff_of_true hx1t rfl
  · exact iff_of_false (not_lt.mpr (le_of_lt hx1t)) (by decide)

/-- **O1b — non-vacuity of the joint carrier** (task 334 Phase 6 REWIRE; fresh analog of
    `kvE_subBracket2V_nonvacuous`, `SubBracket2V.lean:1425`; FM-vac): for a `qnf` arising from an
    actual model realization under `x < w < t`, the depth-2 gate holds, so the carrier takes the
    gate-true branch; and since the honest model arrangement's order-type disjunct is valid
    (`hvalid`, the honest-selection guaranteed by the honest bundle — full semantic discharge is
    Phase 8), the model-order disjunct is a member of `kvE2_sepArr'` (Lemma 3.2(1), md:77), so the
    carrier's `disjuncts` list — one bracket per valid weak order — is NON-empty.

    This is the Phase-6 removal of the `sorryAx` contamination (Risk R5): non-vacuity now routes
    through the order-type disjunction `kvE2_sepArr'` (via the axiom-clean
    `kvE2_sepArr'_mem_modelOrder`) rather than through the DELETED FALSE scaffolds
    `kvE2_sepSlotsL_valid`/`_valid` (which asserted the identity interleaving of the flat union is a
    valid arrangement — FALSE post-switch, handoff 05). Rabinovich Prop 4.2 (md:100-101). -/
theorem kvE2_sepBody_nonvacuous {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hvalid : kvE2_sepDisjValid qnf (kvE2_sepModelOrder qnf) = true) :
    (kvE2_sepBody charBase charK qnf).disjuncts ≠ [] := by
  have hgate := kvE2_sepGate_holds_of_honest qnf M w x t hxw hwt h
  simp only [kvE2_sepBody]
  split
  case isTrue _ =>
    apply List.ne_nil_of_mem (a := kvE2_sepDisjunct charBase charK qnf
      (kvE2_sepSlotsLOf (kvE2_sepModelOrder qnf)) (kvE2_sepSlotsROf (kvE2_sepModelOrder qnf)))
    exact List.mem_map.mpr
      ⟨kvE2_sepModelOrder qnf, kvE2_sepArr'_mem_modelOrder qnf hvalid, rfl⟩
  case isFalse hg =>
    exact absurd hgate hg

/-! ## Task 334 Phase 8 — Lemma 3.2(1) ⇐ (completeness): the honest arrangement selects its
    order-type disjunct (md:77; §5 coincidence, md:168-173).

**Empirical finding (this dispatch, `lean_goal`-grounded).** The genuinely honest selection is the
COINCIDENCE (tie) arrangement, NOT the strict `kvE2_sepModelOrder`. At σ's OWN fresh anchor `x1`,
σ's fresh base type `nf0_projFresh σ.1` is realized AT `x1` — so the CLOSED self-zone bit
`kvE2_sepBits σ zAtX1L (nf0_projFresh σ.1)` is forced TRUE (via the preserved axiom-clean
`kvE2_sepCoincidentAnchor_discharge`), while the OPEN `zXU`/`zUW` bits that
`kvE2_sepDisjValidOwner .strictBefore/.strictAfter` read are NOT forced (the exact handoff-05
open-vs-closed discrimination, SW:2414-2417). Hence `kvE2_sepDisjValid qnf (kvE2_sepModelOrder qnf)`
(strict tags) is NOT honestly provable; the honestly-valid disjunct is the coincident one. This
supersedes the singleton retreat with the full multi-owner LEFT-interior completeness. -/

/-- **Global Nodup — prefix-sum payload** (task 340 Phase 5 flip conjunct (iii)): the flattened
    model/coincident payload over the whole family is duplicate-free (the global slot index is
    injective on the `Nodup` family). -/
theorem kvE2_sepAllSlots_map_slotIndexOf_nodup {sig : MonadicSignature} (qnf : NormalForm sig 2 3) :
    ((kvE2_sepAllSlots qnf).map (kvE2_sepSlotIndexOf qnf)).Nodup :=
  List.Nodup.map_on (fun a ha b hb hab => kvE2_sepSlotIndexOf_injOn qnf ha hb hab)
    (kvE2_sepAllSlots_nodup qnf)

/-- Flattening a per-owner `block.map f` payload over the whole `zipIdx`-tagged owner list yields
    exactly `allSlots.map f` (owner blocks concatenate to the family in order; the `zipIdx` position
    is irrelevant). -/
private theorem kvE2_sepZip_flatMap_aux {sig : MonadicSignature}
    (g : NormalForm sig 1 4 → KvE2SepSpikeOrderType) (f : KvE2SepSlot sig → ℕ)
    (L : List (NormalForm sig 1 4)) (n : ℕ) :
    ((L.zipIdx n).map (fun p => (p.1, g p.1, (kvE2_sepSlotBlock p.1).map f))).flatMap
        (fun p => p.2.2)
      = (L.flatMap kvE2_sepSlotBlock).map f := by
  induction L generalizing n with
  | nil => simp
  | cons a t ih =>
    simp only [List.zipIdx_cons, List.map_cons, List.flatMap_cons, List.map_append, ih (n + 1)]

/-- **Payload flatten** (task 340 Phase 5/7 flip conjunct (iii)): the flattened per-slot payload of a
    `block.map f`-tagged weak order over all owners is `allSlots.map f` — feeding the global-Nodup
    lemmas `kvE2_sepAllSlots_map_slotIndexOf_nodup` / `_honestGIdx_nodup`. -/
theorem kvE2_sepZipPayload_flatMap {sig : MonadicSignature} (qnf : NormalForm sig 2 3)
    (g : NormalForm sig 1 4 → KvE2SepSpikeOrderType) (f : KvE2SepSlot sig → ℕ) :
    ((kvE2_sepPos qnf).zipIdx.map
        (fun p => (p.1, g p.1, (kvE2_sepSlotBlock p.1).map f))).flatMap (fun p => p.2.2)
      = (kvE2_sepAllSlots qnf).map f := by
  rw [kvE2_sepAllSlots]; exact kvE2_sepZip_flatMap_aux g f (kvE2_sepPos qnf) 0

/-- The honest COINCIDENCE (tie) arrangement: every positive owner placed at its own fresh anchor
    (Lemma 3.2(1) coincidence disjunct, md:77; §5 meet, md:168-173). -/
noncomputable def kvE2_sepCoincidentOrder {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) : KvE2SepWeakOrder sig :=
  (kvE2_sepPos qnf).zipIdx.map
    (fun p => (p.1, KvE2SepSpikeOrderType.coincident,
      (kvE2_sepSlotBlock p.1).map (kvE2_sepSlotIndexOf qnf)))

/-- The coincidence arrangement is present in the enumeration index (F2, structural level): the
    all-coincident tag assignment with consecutive `zipIdx` ranks is reachable in the cartesian
    rank×tag enumeration (a `kvE2_sepOrderTypes_mem_aux` instance, `s = 0`). -/
theorem kvE2_sepCoincidentOrder_mem_orderTypes {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) :
    kvE2_sepCoincidentOrder qnf ∈ kvE2_sepOrderTypes qnf := by
  rw [kvE2_sepCoincidentOrder, kvE2_sepOrderTypes]
  refine kvE2_sepOrderTypes_mem_aux' (fun _ => KvE2SepSpikeOrderType.coincident) _
    (fun σ => (kvE2_sepSlotBlock σ).map (kvE2_sepSlotIndexOf qnf)) (kvE2_sepPos qnf) 0
    (fun σ hσ => ?_)
  have h := kvE2_sepIdxTupleN_mem_of_forall_lt (kvE2_sepAllSlots qnf).length
    ((kvE2_sepSlotBlock σ).map (kvE2_sepSlotIndexOf qnf)) (fun y hy => by
      obtain ⟨s, hs, rfl⟩ := List.mem_map.mp hy
      exact kvE2_sepSlotIndexOf_lt qnf (kvE2_sepMem_allSlots qnf hσ hs))
  rwa [List.length_map] at h

/-- **Phase 8a (LEFT) — per-owner honest coincidence validity.** For an honest realization, a
    LEFT-interior positive owner's CLOSED self-zone bit at its own fresh type is forced TRUE. The
    anchor `x1 ∈ (x, w)` and its order bounds are exactly the data `kvE2_sepHonestBundleL` (:1207)
    extracts; the closed bit is discharged by the preserved `kvE2_sepCoincidentAnchor_discharge`. -/
theorem kvE2_sepCoincidentOwner_valid_left {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (σ : NormalForm sig 1 4) (hσmem : σ ∈ kvE2_sepPos qnf)
    (hzone : nf0_zoneSpec σ.1 = kvE2_sep_zXW3) :
    kvE2_sepClosedLeafStub σ = true := by
  have hb : qnf.2 σ = true := (List.mem_filter.mp hσmem).2
  obtain ⟨_h_atom, h_quant⟩ := h
  obtain ⟨x1, hσ⟩ := (h_quant σ).mpr hb
  -- left-interior order bounds x < x1 < w, from the zone guard through the realized atom layer
  obtain ⟨hσ_atom, _h_zone, _h_off⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hσ
  have hbit_xx1 : (nf0_zoneSpec σ.1 ⟨1, by omega⟩).2 = true := by
    rw [congrFun hzone ⟨1, by omega⟩]; decide
  have hbit_x1w : (nf0_zoneSpec σ.1 ⟨0, by omega⟩).1 = true := by
    rw [congrFun hzone ⟨0, by omega⟩]; decide
  have hxx1 : x < x1 := by
    have h1 := hσ_atom (.order (Fin.succ ⟨1, by omega⟩) 0 (Fin.succ_ne_zero ⟨1, by omega⟩))
    simp only [atom_eval, Fin.cons] at h1
    exact h1.mpr hbit_xx1
  have hx1w : x1 < w := by
    have h1 := hσ_atom (.order 0 (Fin.succ ⟨0, by omega⟩) (Fin.succ_ne_zero ⟨0, by omega⟩).symm)
    simp only [atom_eval, Fin.cons] at h1
    exact h1.mpr hbit_x1w
  -- σ's own fresh base type is realized AT x1 (the fresh coordinate factor)
  have hfresh : nf_eval_nf M 0 1 (fun _ => x1) (nf0_projFresh σ.1) :=
    ((nf_eval_nf0_cons_factor M (Fin.cons w (Fin.cons x (fun _ => t))) x1 σ.1).mp hσ.1).2.1
  -- the coincidence discharge closes the CLOSED self-zone bit (LEFT branch of the guard)
  rw [kvE2_sepClosedLeafStub, if_pos hzone]
  exact kvE2_sepCoincidentAnchor_discharge σ M x1 w x t hxx1 hx1w hwt hσ (nf0_projFresh σ.1) hfresh

/-- **Phase 8b (RIGHT) — right coincidence discharge** (mirror of `kvE2_sepCoincidentAnchor_discharge`
    at the RIGHT self-zone `zAtX1R`, `w < x1 < t`; consumes the same generic zone-forward channel of
    `kvE_subBracket2_complete_extract` that `kvE2_sepHonestBundleR` (:1259) routes through). At a
    RIGHT-interior owner's fresh anchor `x1 ∈ (w, t)`, a base type `χ` realized AT `x1` discharges
    σ's CLOSED right self-zone bit `kvE2_sepBits σ zAtX1R χ` — the §5 shared-anchor meet-type
    identification (md:168-173) on the right side. This is the genuine mathematical content of the
    right completeness half. NOTE: the current `kvE2_sepDisjValidOwner .coincident`/`kvE2_sepClosedLeafStub`
    read `zAtX1L` (left) only; wiring this right bit into a placement-generic coincident validity
    channel is a tightly-scoped carrier-predicate extension (plan scope note :417-419), tracked as a
    follow-up. -/
theorem kvE2_sepCoincidentAnchor_discharge_R {sig : MonadicSignature}
    (σ : NormalForm sig 1 4) (M : OrderedMonadicStructure sig)
    (x1 w x t : M.carrier) (hxw : x < w) (hwx1 : w < x1) (hx1t : x1 < t)
    (hσ : nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (χ : NormalForm sig 0 1)
    (hp : nf_eval_nf M 0 1 (fun _ => x1) χ) :
    kvE2_sepBits σ kvE2_sep_zAtX1R χ = true := by
  obtain ⟨_, _, h_zonefwd, _, _, _⟩ := kvE_subBracket2_complete_extract σ M x1 w x t hσ
  have hxx1 : x < x1 := lt_trans hxw hwx1
  refine h_zonefwd kvE2_sep_zAtX1R χ ⟨x1, ?_, hp⟩
  -- `zoneHolds env kvE2_sep_zAtX1R x1` is a pure order fact (v = x1: `x < w < x1 < t`).
  refine (kvE_sub2_zoneHolds_cons_iff M x1 w x t x1
    (false, false) (false, true) (false, true) (true, false)).mpr ?_
  refine ⟨⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_⟩⟩
  · exact iff_of_false (lt_irrefl _) (by decide)
  · exact iff_of_false (lt_irrefl _) (by decide)
  · exact iff_of_false (not_lt.mpr (le_of_lt hwx1)) (by decide)
  · exact iff_of_true hwx1 rfl
  · exact iff_of_false (not_lt.mpr (le_of_lt hxx1)) (by decide)
  · exact iff_of_true hxx1 rfl
  · exact iff_of_true hx1t rfl
  · exact iff_of_false (not_lt.mpr (le_of_lt hx1t)) (by decide)

/-- **Phase 8b (RIGHT) — per-owner honest coincidence validity** (task 336; mirror of
    `kvE2_sepCoincidentOwner_valid_left`). For an honest realization, a RIGHT-interior positive
    owner (`nf0_zoneSpec σ.1 = kvE2_sep_zWT3`, `w < x1 < t`) has its CLOSED right self-zone bit at
    its own fresh type forced TRUE. The anchor `x1 ∈ (w, t)` and its order bounds are extracted
    inline (the `kvE2_sepHonestBundleR` :1259 pattern); the closed `zAtX1R` bit is discharged by
    the landed axiom-clean `kvE2_sepCoincidentAnchor_discharge_R`. The guard in
    `kvE2_sepClosedLeafStub` selects the RIGHT (`else`) branch via `if_neg` on
    `kvE2_sep_zWT3_ne_zXW3`. Sorry-free, axiom-clean; F5-faithful (CLOSED key). -/
theorem kvE2_sepCoincidentOwner_valid_right {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (σ : NormalForm sig 1 4) (hσmem : σ ∈ kvE2_sepPos qnf)
    (hzone : nf0_zoneSpec σ.1 = kvE2_sep_zWT3) :
    kvE2_sepClosedLeafStub σ = true := by
  have hb : qnf.2 σ = true := (List.mem_filter.mp hσmem).2
  obtain ⟨_h_atom, h_quant⟩ := h
  obtain ⟨x1, hσ⟩ := (h_quant σ).mpr hb
  -- right-interior order bounds w < x1 < t, from the zone guard through the realized atom layer
  obtain ⟨hσ_atom, _h_zone, _h_off⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hσ
  have hbit_wx1 : (nf0_zoneSpec σ.1 ⟨0, by omega⟩).2 = true := by
    rw [congrFun hzone ⟨0, by omega⟩]; decide
  have hbit_x1t : (nf0_zoneSpec σ.1 ⟨2, by omega⟩).1 = true := by
    rw [congrFun hzone ⟨2, by omega⟩]; decide
  have hwx1 : w < x1 := by
    have h1 := hσ_atom (.order (Fin.succ ⟨0, by omega⟩) 0 (Fin.succ_ne_zero ⟨0, by omega⟩))
    simp only [atom_eval, Fin.cons] at h1
    exact h1.mpr hbit_wx1
  have hx1t : x1 < t := by
    have h1 := hσ_atom (.order 0 (Fin.succ ⟨2, by omega⟩) (Fin.succ_ne_zero ⟨2, by omega⟩).symm)
    simp only [atom_eval, Fin.cons] at h1
    exact h1.mpr hbit_x1t
  -- σ's own fresh base type is realized AT x1 (the fresh coordinate factor)
  have hfresh : nf_eval_nf M 0 1 (fun _ => x1) (nf0_projFresh σ.1) :=
    ((nf_eval_nf0_cons_factor M (Fin.cons w (Fin.cons x (fun _ => t))) x1 σ.1).mp hσ.1).2.1
  -- the right coincidence discharge closes the CLOSED self-zone bit (RIGHT branch of the guard)
  rw [kvE2_sepClosedLeafStub, if_neg (fun hcon => kvE2_sep_zWT3_ne_zXW3 (hzone.symm.trans hcon))]
  exact kvE2_sepCoincidentAnchor_discharge_R σ M x1 w x t hxw hwx1 hx1t hσ (nf0_projFresh σ.1) hfresh

/-- **Lemma 3.2(1) ⇐ (completeness) — `kvE2_sepBody_complete`** (task 334 Phase 8; generalized to
    right-interior owners in task 336). For an honest model realization whose positive owners are
    each INTERIOR — LEFT (`nf0_zoneSpec σ.1 = kvE2_sep_zXW3`, `x < x1 < w`) OR RIGHT
    (`nf0_zoneSpec σ.1 = kvE2_sep_zWT3`, `w < x1 < t`), the disjunction `hLR` — the honest
    COINCIDENCE (tie) arrangement is a VALID, PRESENT member of the faithful carrier
    `kvE2_sepArr'`; hence the carrier is NON-VACUOUS (`kvE2_sepArr' qnf ≠ []`) — the ⇐ direction of
    Lemma 3.2(1) (md:77): every honest arrangement selects its order-type disjunct (here the
    coincidence disjunct, §5 meet, md:168-173). The per-owner `rcases` dispatches each owner to its
    placement-appropriate closed-self-zone validator: LEFT →
    `kvE2_sepCoincidentOwner_valid_left` (`zAtX1L` bit, `kvE2_sepCoincidentAnchor_discharge`);
    RIGHT → `kvE2_sepCoincidentOwner_valid_right` (`zAtX1R` bit,
    `kvE2_sepCoincidentAnchor_discharge_R`), both routed through the placement-guarded
    `kvE2_sepClosedLeafStub`. Sorry-free, axiom-clean. Faithfulness: F2 (⇐ realized, non-vacuous),
    F1, F5 (closed vs open key discrimination), F6.

    The interior hypothesis `hLR` remains a live obligation: `kvE2_sepPos` admits seven outer zone
    classes (`kvE2_sepOuterConsistent`, :631-633) with no dichotomy forcing positive owners to be
    interior. A fully unconditional completeness theorem over the exterior/boundary classes would
    require new coincidence mathematics for those five classes and is out of scope — the gap is
    honestly carried as `hLR`, not bridged by any `sorry` or axiom. -/
theorem kvE2_sepBody_complete {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hLR : ∀ σ ∈ kvE2_sepPos qnf,
        nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3) :
    kvE2_sepArr' qnf ≠ [] := by
  apply List.ne_nil_of_mem (a := kvE2_sepCoincidentOrder qnf)
  rw [kvE2_sepArr', List.mem_filter]
  refine ⟨kvE2_sepCoincidentOrder_mem_orderTypes qnf, ?_⟩
  rw [kvE2_sepDisjValid, Bool.and_eq_true, Bool.and_eq_true]
  refine ⟨⟨?_, ?_⟩, ?_⟩
  · -- (i) per-owner closed-self-zone validity, dispatched by placement.
    rw [List.all_eq_true]
    intro p hp
    rw [kvE2_sepCoincidentOrder, List.mem_map] at hp
    obtain ⟨⟨σ, i⟩, hmem, rfl⟩ := hp
    have hσmem : σ ∈ kvE2_sepPos qnf := List.fst_mem_of_mem_zipIdx hmem
    -- `p.2.1 = .coincident`, so `kvE2_sepDisjValidOwner p.1 p.2.1 = kvE2_sepClosedLeafStub σ`.
    show kvE2_sepDisjValidOwner σ KvE2SepSpikeOrderType.coincident = true
    rcases hLR σ hσmem with hzone | hzone
    · exact kvE2_sepCoincidentOwner_valid_left qnf M w x t hxw hwt h σ hσmem hzone
    · exact kvE2_sepCoincidentOwner_valid_right qnf M w x t hxw hwt h σ hσmem hzone
  · -- (ii) per-owner region-scoped consistency: the prefix-sum payload extends each region order.
    rw [List.all_eq_true]
    intro p hp
    rw [kvE2_sepCoincidentOrder, List.mem_map] at hp
    obtain ⟨⟨σ, k⟩, hmem, rfl⟩ := hp
    have hσmem : σ ∈ kvE2_sepPos qnf := List.fst_mem_of_mem_zipIdx hmem
    exact kvE2_sepConsistentBlock_slotIndexOf qnf hσmem
  · -- (iii) cross-owner global Nodup over all slot indices.
    rw [decide_eq_true_eq, kvE2_sepCoincidentOrder,
      kvE2_sepZipPayload_flatMap qnf (fun _ => KvE2SepSpikeOrderType.coincident)
        (kvE2_sepSlotIndexOf qnf)]
    exact kvE2_sepAllSlots_map_slotIndexOf_nodup qnf

/-- **Phase 1 (task 337) — the honest coincidence witness is a carrier member.** Factored from
    `kvE2_sepBody_complete`'s membership route: under an honest interior realization (`hLR`) the
    COINCIDENCE arrangement `kvE2_sepCoincidentOrder qnf` (all-coincident tags, `zipIdx` ranks) is a
    VALID, PRESENT member of `kvE2_sepArr' qnf` — the ⇐-direction witness weak order this task's
    `.holds` builder plugs into `kvE2_sepBody_holds_iff.mpr`. Additive; edits no carrier declaration.
    F5: validity reads only CLOSED self-zone bits (via the coincidence validators). -/
theorem kvE2_sepCoincidentOrder_mem_arr' {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hLR : ∀ σ ∈ kvE2_sepPos qnf,
        nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3) :
    kvE2_sepCoincidentOrder qnf ∈ kvE2_sepArr' qnf := by
  rw [kvE2_sepArr', List.mem_filter]
  refine ⟨kvE2_sepCoincidentOrder_mem_orderTypes qnf, ?_⟩
  rw [kvE2_sepDisjValid, Bool.and_eq_true, Bool.and_eq_true]
  refine ⟨⟨?_, ?_⟩, ?_⟩
  · rw [List.all_eq_true]
    intro p hp
    rw [kvE2_sepCoincidentOrder, List.mem_map] at hp
    obtain ⟨⟨σ, i⟩, hmem, rfl⟩ := hp
    have hσmem : σ ∈ kvE2_sepPos qnf := List.fst_mem_of_mem_zipIdx hmem
    show kvE2_sepDisjValidOwner σ KvE2SepSpikeOrderType.coincident = true
    rcases hLR σ hσmem with hzone | hzone
    · exact kvE2_sepCoincidentOwner_valid_left qnf M w x t hxw hwt h σ hσmem hzone
    · exact kvE2_sepCoincidentOwner_valid_right qnf M w x t hxw hwt h σ hσmem hzone
  · rw [List.all_eq_true]
    intro p hp
    rw [kvE2_sepCoincidentOrder, List.mem_map] at hp
    obtain ⟨⟨σ, k⟩, hmem, rfl⟩ := hp
    have hσmem : σ ∈ kvE2_sepPos qnf := List.fst_mem_of_mem_zipIdx hmem
    exact kvE2_sepConsistentBlock_slotIndexOf qnf hσmem
  · rw [decide_eq_true_eq, kvE2_sepCoincidentOrder,
      kvE2_sepZipPayload_flatMap qnf (fun _ => KvE2SepSpikeOrderType.coincident)
        (kvE2_sepSlotIndexOf qnf)]
    exact kvE2_sepAllSlots_map_slotIndexOf_nodup qnf

/-! ### Task 340 Phase 5A — anchor family KEYSTONE (distinct owners ⟹ distinct anchors)

The design gate (report 06) dissolves the coinciding-anchor "fork": two DISTINCT positive owners
provably CANNOT share a fresh anchor. `kvE2_sepPos` is `Finset.univ.toList.filter` (`Nodup`,
owners distinct normal forms) and each owner's anchor realizes it at the depth-1 environment
`[x1, w, x, t]`; `nf_eval_unique` (NormalForm.lean:245) forces equal-anchor ⟹ equal-owner. Hence
the anchor family is INJECTIVE and strictly orderable — the value-rank owner-block layout is
well-defined with no ties. This is the keystone every later phase depends on. -/

/-- **Owner anchor value** (task 340 Phase 5A): σ's fresh depth-1 witness `x1_σ`, extracted as the
    `Classical.choose` of the honest realization existential `(h.2 σ).mpr`. Off the positive spine
    (`qnf.2 σ ≠ true`) it defaults to `x`. Model-dependent (needs the realization `h`), like the
    completeness-side witness (report 02 Q2 — the value order is inherently per-M). No `x1 < e_i`
    literal introduced (LITMUS clean): only the already-extracted witness is named. -/
noncomputable def kvE2_sepAnchorVal {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (σ : NormalForm sig 1 4) : M.carrier :=
  if hb : qnf.2 σ = true then Classical.choose ((h.2 σ).mpr hb) else x

/-- The anchor value realizes its owner at the depth-1 environment `[x1_σ, w, x, t]` (the exact
    shape `kvE2_sepCoincidentOwner_valid_left/right` extract from `(h.2 σ).mpr`). -/
theorem kvE2_sepAnchorVal_spec {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (σ : NormalForm sig 1 4) (hb : qnf.2 σ = true) :
    nf_eval_nf M 1 4
      (Fin.cons (kvE2_sepAnchorVal qnf M w x t h σ) (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  rw [kvE2_sepAnchorVal, dif_pos hb]
  exact Classical.choose_spec ((h.2 σ).mpr hb)

/-- **KEYSTONE** (task 340 Phase 5A): distinct positive owners have distinct anchors. If σ, τ are
    positive owners with equal anchors `a`, the single environment `[a, w, x, t]` realizes BOTH σ
    and τ at depth 1, arity 4, so `nf_eval_unique` forces `σ = τ`. This kills any coinciding-anchor
    fork at the anchor level: the anchor family is injective, so plain value rank is already a
    strict total order (no lex tiebreak needed for realizability). -/
theorem kvE2_sepAnchor_injOn {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {σ τ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf) (hτ : τ ∈ kvE2_sepPos qnf)
    (heq : kvE2_sepAnchorVal qnf M w x t h σ = kvE2_sepAnchorVal qnf M w x t h τ) :
    σ = τ := by
  have hbσ : qnf.2 σ = true := (List.mem_filter.mp hσ).2
  have hbτ : qnf.2 τ = true := (List.mem_filter.mp hτ).2
  have hrσ := kvE2_sepAnchorVal_spec qnf M w x t h σ hbσ
  have hrτ := kvE2_sepAnchorVal_spec qnf M w x t h τ hbτ
  rw [heq] at hrσ
  exact nf_eval_unique M 1 4 _ σ τ hrσ hrτ

/-- **Anchor family** (task 340 Phase 5A): the injective `Fin n → M.carrier` sending each owner
    index to its anchor value. `n = |kvE2_sepPos qnf|`. Injectivity (from `List.get` on the `Nodup`
    positive spine + the keystone `kvE2_sepAnchor_injOn`) makes `kvE2_ordRank` of this family a
    strict, injective rank — the value-faithful owner-block order key. -/
noncomputable def kvE2_sepAnchorFam {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    Fin (kvE2_sepPos qnf).length → M.carrier :=
  fun k => kvE2_sepAnchorVal qnf M w x t h ((kvE2_sepPos qnf).get k)

/-- The anchor family is injective: `List.get` on the `Nodup` positive spine is injective, and the
    keystone lifts anchor-equality to owner-equality. Supplies the cross-owner `Nodup` conjunct
    (via `kvE2_ordRank_injective`) and licenses value-faithful ranking. -/
theorem kvE2_sepAnchorFam_injective {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    Function.Injective (kvE2_sepAnchorFam qnf M w x t h) := by
  have hnd : (kvE2_sepPos qnf).Nodup := by
    unfold kvE2_sepPos; exact List.Nodup.filter _ (Finset.nodup_toList _)
  intro a b hab
  have hga : (kvE2_sepPos qnf).get a ∈ kvE2_sepPos qnf := (kvE2_sepPos qnf).get_mem a
  have hgb : (kvE2_sepPos qnf).get b ∈ kvE2_sepPos qnf := (kvE2_sepPos qnf).get_mem b
  have hget : (kvE2_sepPos qnf).get a = (kvE2_sepPos qnf).get b :=
    kvE2_sepAnchor_injOn qnf M w x t h hga hgb hab
  exact (List.Nodup.get_inj_iff hnd).mp hget

/-! ### Task 340 Phase 5B — the honest value-rank order (owner-block tuples, coincident tags)

The single honest order (no bifurcation, report 06): every owner is tagged `.coincident` and its
per-slot global-index tuple is the value-rank owner block `(3r, 3r+1, 3r+2)`, `r = ` the rank of
its anchor in the injective anchor family. Membership in `kvE2_sepArr'` is TUPLE-AGNOSTIC — the
tag validators (`kvE2_sepCoincidentOwner_valid_left/right`) read only the CLOSED self-zone bit, so
they reuse VERBATIM; consistency `i₀<i₁<i₂` is `omega` on `3r<3r+1<3r+2`; the `i₀`-`Nodup` conjunct
is `kvE2_ordRank_injective` on the keystone-injective family (via `3·`). -/

/-- **Phase 5D — LEFT engine-precondition data at the value-ranked anchor.** The public,
    canonical-anchor form of `kvE2_sepHonestBundleL`: for a LEFT-interior owner σ, at its
    `kvE2_sepAnchorVal` anchor (the value the honest rank is computed from) there are real
    witnesses in `(x, x1_σ)` for every `zXU`-positive base type and in `(x1_σ, w)` for every
    `zUW`-positive base type. These are the `hnd`/`hreal` inputs (per the region base-type lists)
    that task 337 feeds to `k1v_sorted_realizationK` for the honest-order regions. Mirrors the
    private bundle proof with the anchor pinned to `kvE2_sepAnchorVal`. -/
theorem kvE2_sepHonestAnchorBundleL {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (σ : NormalForm sig 1 4) (hσpos : σ ∈ kvE2_sepPos qnf)
    (hzone : nf0_zoneSpec σ.1 = kvE2_sep_zXW3) :
    x < kvE2_sepAnchorVal qnf M w x t h σ ∧ kvE2_sepAnchorVal qnf M w x t h σ < w ∧
      (∀ χ ∈ kvE2_sepS σ kvE_sub2_zXU,
        ∃ u : M.carrier, x < u ∧ u < kvE2_sepAnchorVal qnf M w x t h σ ∧
          nf_eval_nf M 0 1 (fun _ => u) χ) ∧
      (∀ χ ∈ kvE2_sepS σ kvE_sub2_zUW,
        ∃ u : M.carrier, kvE2_sepAnchorVal qnf M w x t h σ < u ∧ u < w ∧
          nf_eval_nf M 0 1 (fun _ => u) χ) := by
  have hb : qnf.2 σ = true := (List.mem_filter.mp hσpos).2
  have hσ := kvE2_sepAnchorVal_spec qnf M w x t h σ hb
  obtain ⟨hσ_atom, _h_off, _h_zonefwd, hbelowXU, hbelowUW, _hbelowWT⟩ :=
    kvE_subBracket2_complete_extract σ M (kvE2_sepAnchorVal qnf M w x t h σ) w x t hσ
  have hbit_xx1 : (nf0_zoneSpec σ.1 ⟨1, by omega⟩).2 = true := by
    rw [congrFun hzone ⟨1, by omega⟩]; decide
  have hbit_x1w : (nf0_zoneSpec σ.1 ⟨0, by omega⟩).1 = true := by
    rw [congrFun hzone ⟨0, by omega⟩]; decide
  have hxx1 : x < kvE2_sepAnchorVal qnf M w x t h σ := by
    have h1 := hσ_atom (.order (Fin.succ ⟨1, by omega⟩) 0 (Fin.succ_ne_zero ⟨1, by omega⟩))
    simp only [atom_eval, Fin.cons] at h1
    exact h1.mpr hbit_xx1
  have hx1w : kvE2_sepAnchorVal qnf M w x t h σ < w := by
    have h1 := hσ_atom (.order 0 (Fin.succ ⟨0, by omega⟩) (Fin.succ_ne_zero ⟨0, by omega⟩).symm)
    simp only [atom_eval, Fin.cons] at h1
    exact h1.mpr hbit_x1w
  refine ⟨hxx1, hx1w, ?_, ?_⟩
  · intro χ hχ
    exact hbelowXU χ (List.mem_filter.mp hχ).2
  · intro χ hχ
    exact hbelowUW χ (List.mem_filter.mp hχ).2

/-- **Phase 5D — RIGHT engine-precondition data at the value-ranked anchor.** Right mirror of
    `kvE2_sepHonestAnchorBundleL` for a RIGHT-interior owner σ (`w < x1_σ < t`): real witnesses in
    `(w, x1_σ)` for `zWX1`-positive base types and in `(x1_σ, t)` for `zWT`-positive base types,
    pinned to the canonical `kvE2_sepAnchorVal` anchor. -/
theorem kvE2_sepHonestAnchorBundleR {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (σ : NormalForm sig 1 4) (hσpos : σ ∈ kvE2_sepPos qnf)
    (hzone : nf0_zoneSpec σ.1 = kvE2_sep_zWT3) :
    w < kvE2_sepAnchorVal qnf M w x t h σ ∧ kvE2_sepAnchorVal qnf M w x t h σ < t ∧
      (∀ χ ∈ kvE2_sepS σ kvE2_sep_zWX1,
        ∃ u : M.carrier, w < u ∧ u < kvE2_sepAnchorVal qnf M w x t h σ ∧
          nf_eval_nf M 0 1 (fun _ => u) χ) ∧
      (∀ χ ∈ kvE2_sepS σ kvE_sub2_zWT,
        ∃ u : M.carrier, kvE2_sepAnchorVal qnf M w x t h σ < u ∧ u < t ∧
          nf_eval_nf M 0 1 (fun _ => u) χ) := by
  have hb : qnf.2 σ = true := (List.mem_filter.mp hσpos).2
  have hσ := kvE2_sepAnchorVal_spec qnf M w x t h σ hb
  obtain ⟨hσ_atom, h_zone, _h_off⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hσ
  have hbit_wx1 : (nf0_zoneSpec σ.1 ⟨0, by omega⟩).2 = true := by
    rw [congrFun hzone ⟨0, by omega⟩]; decide
  have hbit_x1t : (nf0_zoneSpec σ.1 ⟨2, by omega⟩).1 = true := by
    rw [congrFun hzone ⟨2, by omega⟩]; decide
  have hwx1 : w < kvE2_sepAnchorVal qnf M w x t h σ := by
    have h1 := hσ_atom (.order (Fin.succ ⟨0, by omega⟩) 0 (Fin.succ_ne_zero ⟨0, by omega⟩))
    simp only [atom_eval, Fin.cons] at h1
    exact h1.mpr hbit_wx1
  have hx1t : kvE2_sepAnchorVal qnf M w x t h σ < t := by
    have h1 := hσ_atom (.order 0 (Fin.succ ⟨2, by omega⟩) (Fin.succ_ne_zero ⟨2, by omega⟩).symm)
    simp only [atom_eval, Fin.cons] at h1
    exact h1.mpr hbit_x1t
  refine ⟨hwx1, hx1t, ?_, ?_⟩
  · intro χ hχ
    have hbit : σ.2 (nf0_assemble kvE2_sep_zWX1 χ σ.1) = true := (List.mem_filter.mp hχ).2
    obtain ⟨v, hz, hv⟩ := (h_zone kvE2_sep_zWX1 χ).mpr hbit
    obtain ⟨hp0, hp1, _, _⟩ :=
      (kvE_sub2_zoneHolds_cons_iff M (kvE2_sepAnchorVal qnf M w x t h σ) w x t v
        (true, false) (false, true) (false, true) (true, false)).mp hz
    exact ⟨v, hp1.2.mpr rfl, hp0.1.mpr rfl, hv⟩
  · intro χ hχ
    have hbit : σ.2 (nf0_assemble kvE_sub2_zWT χ σ.1) = true := (List.mem_filter.mp hχ).2
    obtain ⟨v, hz, hv⟩ := (h_zone kvE_sub2_zWT χ).mpr hbit
    obtain ⟨hp0, _, _, hp3⟩ :=
      (kvE_sub2_zoneHolds_cons_iff M (kvE2_sepAnchorVal qnf M w x t h σ) w x t v
        (false, true) (false, true) (false, true) (true, false)).mp hz
    exact ⟨v, hp0.2.mpr rfl, hp3.1.mpr rfl, hv⟩

/-! ### Task 340 Phase 6 — the `value_j` → engine-point binding (data-flow inversion)

Report 08 §Missing Design element 1: each individual slot's rank key `value_j` is bound to the
engine-realized point for that slot, NOT a free canonical value. An anchor slot (`lX1`/`rX1`) takes
its owner's canonical `kvE2_sepAnchorVal`; a base slot takes the witness the anchor realization
forces for its base type `χ` in the slot's OWN region interval (Def 3.1's monotone enumeration of
INDIVIDUAL points, PDF p.4). `Classical.epsilon` keeps the map total; the interval-and-realization
spec is recovered per slot from the honest bundles (`kvE2_sepHonestAnchorBundleL/R`) /
`kvE_subBracket2_complete_extract`, which prove exactly the constraining existence. Reads M only
through already-extracted witnesses ordered by `<` (F4/LITMUS clean — no `x1 < e_i` literal); the
honest per-slot order (Phase 6/7) is `kvE2_ordRank` of `G j = (value_j, slotIndexOf j)` over the
full slot family `Fin N`, with the index tiebreak giving injectivity WITHOUT value-distinctness. -/
noncomputable def kvE2_sepSlotValue {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    KvE2SepSlot sig → M.carrier
  | .lX1 σ => kvE2_sepAnchorVal qnf M w x t h σ
  | .rX1 σ => kvE2_sepAnchorVal qnf M w x t h σ
  | .lXU σ χ => @Classical.epsilon _ ⟨x⟩
      (fun v => x < v ∧ v < kvE2_sepAnchorVal qnf M w x t h σ ∧ nf_eval_nf M 0 1 (fun _ => v) χ)
  | .lUW σ χ => @Classical.epsilon _ ⟨x⟩
      (fun v => kvE2_sepAnchorVal qnf M w x t h σ < v ∧ v < w ∧ nf_eval_nf M 0 1 (fun _ => v) χ)
  | .lWT σ χ => @Classical.epsilon _ ⟨x⟩
      (fun v => w < v ∧ v < t ∧ nf_eval_nf M 0 1 (fun _ => v) χ)
  | .rXW σ χ => @Classical.epsilon _ ⟨x⟩
      (fun v => x < v ∧ v < kvE2_sepAnchorVal qnf M w x t h σ ∧ nf_eval_nf M 0 1 (fun _ => v) χ)
  | .rWX1 σ χ => @Classical.epsilon _ ⟨x⟩
      (fun v => w < v ∧ v < kvE2_sepAnchorVal qnf M w x t h σ ∧ nf_eval_nf M 0 1 (fun _ => v) χ)
  | .rX1T σ χ => @Classical.epsilon _ ⟨x⟩
      (fun v => kvE2_sepAnchorVal qnf M w x t h σ < v ∧ v < t ∧ nf_eval_nf M 0 1 (fun _ => v) χ)

/-- The anchor slot's `value` is its owner's canonical anchor value (definitional). -/
theorem kvE2_sepSlotValue_lX1 {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) (σ : NormalForm sig 1 4) :
    kvE2_sepSlotValue qnf M w x t h (.lX1 σ) = kvE2_sepAnchorVal qnf M w x t h σ := rfl

/-- The right anchor slot's `value` is its owner's canonical anchor value (definitional). -/
theorem kvE2_sepSlotValue_rX1 {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) (σ : NormalForm sig 1 4) :
    kvE2_sepSlotValue qnf M w x t h (.rX1 σ) = kvE2_sepAnchorVal qnf M w x t h σ := rfl

/-- **`lXU` slot value spec** (Phase 6): a before-anchor left base slot's value lies in `(x, x1_σ)`
    and realizes its base type `χ`. From the honest bundle's below-anchor witnesses. -/
theorem kvE2_sepSlotValue_lXU_spec {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (σ : NormalForm sig 1 4) (hσpos : σ ∈ kvE2_sepPos qnf)
    (hzone : nf0_zoneSpec σ.1 = kvE2_sep_zXW3)
    (χ : NormalForm sig 0 1) (hχ : χ ∈ kvE2_sepS σ kvE_sub2_zXU) :
    x < kvE2_sepSlotValue qnf M w x t h (.lXU σ χ)
      ∧ kvE2_sepSlotValue qnf M w x t h (.lXU σ χ) < kvE2_sepAnchorVal qnf M w x t h σ
      ∧ nf_eval_nf M 0 1 (fun _ => kvE2_sepSlotValue qnf M w x t h (.lXU σ χ)) χ := by
  haveI : Nonempty M.carrier := ⟨x⟩
  exact Classical.epsilon_spec
    ((kvE2_sepHonestAnchorBundleL qnf M w x t hxw hwt h σ hσpos hzone).2.2.1 χ hχ)

/-- **`lUW` slot value spec** (Phase 6): an after-anchor left base slot's value lies in `(x1_σ, w)`
    and realizes `χ`. From the honest bundle's above-anchor witnesses. -/
theorem kvE2_sepSlotValue_lUW_spec {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (σ : NormalForm sig 1 4) (hσpos : σ ∈ kvE2_sepPos qnf)
    (hzone : nf0_zoneSpec σ.1 = kvE2_sep_zXW3)
    (χ : NormalForm sig 0 1) (hχ : χ ∈ kvE2_sepS σ kvE_sub2_zUW) :
    kvE2_sepAnchorVal qnf M w x t h σ < kvE2_sepSlotValue qnf M w x t h (.lUW σ χ)
      ∧ kvE2_sepSlotValue qnf M w x t h (.lUW σ χ) < w
      ∧ nf_eval_nf M 0 1 (fun _ => kvE2_sepSlotValue qnf M w x t h (.lUW σ χ)) χ := by
  haveI : Nonempty M.carrier := ⟨x⟩
  exact Classical.epsilon_spec
    ((kvE2_sepHonestAnchorBundleL qnf M w x t hxw hwt h σ hσpos hzone).2.2.2 χ hχ)

/-- **`rWX1` slot value spec** (Phase 6): a before-anchor right base slot's value lies in
    `(w, x1_σ)` and realizes `χ`. From the honest bundle R's below-anchor witnesses. -/
theorem kvE2_sepSlotValue_rWX1_spec {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (σ : NormalForm sig 1 4) (hσpos : σ ∈ kvE2_sepPos qnf)
    (hzone : nf0_zoneSpec σ.1 = kvE2_sep_zWT3)
    (χ : NormalForm sig 0 1) (hχ : χ ∈ kvE2_sepS σ kvE2_sep_zWX1) :
    w < kvE2_sepSlotValue qnf M w x t h (.rWX1 σ χ)
      ∧ kvE2_sepSlotValue qnf M w x t h (.rWX1 σ χ) < kvE2_sepAnchorVal qnf M w x t h σ
      ∧ nf_eval_nf M 0 1 (fun _ => kvE2_sepSlotValue qnf M w x t h (.rWX1 σ χ)) χ := by
  haveI : Nonempty M.carrier := ⟨x⟩
  exact Classical.epsilon_spec
    ((kvE2_sepHonestAnchorBundleR qnf M w x t hxw hwt h σ hσpos hzone).2.2.1 χ hχ)

/-- **`rX1T` slot value spec** (Phase 6): an after-anchor right base slot's value lies in
    `(x1_σ, t)` and realizes `χ`. From the honest bundle R's above-anchor witnesses. -/
theorem kvE2_sepSlotValue_rX1T_spec {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (σ : NormalForm sig 1 4) (hσpos : σ ∈ kvE2_sepPos qnf)
    (hzone : nf0_zoneSpec σ.1 = kvE2_sep_zWT3)
    (χ : NormalForm sig 0 1) (hχ : χ ∈ kvE2_sepS σ kvE_sub2_zWT) :
    kvE2_sepAnchorVal qnf M w x t h σ < kvE2_sepSlotValue qnf M w x t h (.rX1T σ χ)
      ∧ kvE2_sepSlotValue qnf M w x t h (.rX1T σ χ) < t
      ∧ nf_eval_nf M 0 1 (fun _ => kvE2_sepSlotValue qnf M w x t h (.rX1T σ χ)) χ := by
  haveI : Nonempty M.carrier := ⟨x⟩
  exact Classical.epsilon_spec
    ((kvE2_sepHonestAnchorBundleR qnf M w x t hxw hwt h σ hσpos hzone).2.2.2 χ hχ)

/-- **`lWT` slot value spec** (Phase 6): a right-region base slot of a LEFT-interior owner lies in
    `(w, t)` and realizes `χ`. Direct from the anchor realization's `zWT` extraction. -/
theorem kvE2_sepSlotValue_lWT_spec {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (σ : NormalForm sig 1 4) (hσpos : σ ∈ kvE2_sepPos qnf)
    (χ : NormalForm sig 0 1) (hχ : χ ∈ kvE2_sepS σ kvE_sub2_zWT) :
    w < kvE2_sepSlotValue qnf M w x t h (.lWT σ χ)
      ∧ kvE2_sepSlotValue qnf M w x t h (.lWT σ χ) < t
      ∧ nf_eval_nf M 0 1 (fun _ => kvE2_sepSlotValue qnf M w x t h (.lWT σ χ)) χ := by
  have hb : qnf.2 σ = true := (List.mem_filter.mp hσpos).2
  have hσ := kvE2_sepAnchorVal_spec qnf M w x t h σ hb
  obtain ⟨_, _, _, _, _, hbelowWT⟩ :=
    kvE_subBracket2_complete_extract σ M (kvE2_sepAnchorVal qnf M w x t h σ) w x t hσ
  haveI : Nonempty M.carrier := ⟨x⟩
  exact Classical.epsilon_spec (hbelowWT χ (List.mem_filter.mp hχ).2)

/-- **`rXW` slot value spec** (Phase 6): a left-region base slot of a RIGHT-interior owner lies in
    `(x, x1_σ)` and realizes `χ`. Direct from the anchor realization's `zXU` extraction. -/
theorem kvE2_sepSlotValue_rXW_spec {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (σ : NormalForm sig 1 4) (hσpos : σ ∈ kvE2_sepPos qnf)
    (χ : NormalForm sig 0 1) (hχ : χ ∈ kvE2_sepS σ kvE_sub2_zXU) :
    x < kvE2_sepSlotValue qnf M w x t h (.rXW σ χ)
      ∧ kvE2_sepSlotValue qnf M w x t h (.rXW σ χ) < kvE2_sepAnchorVal qnf M w x t h σ
      ∧ nf_eval_nf M 0 1 (fun _ => kvE2_sepSlotValue qnf M w x t h (.rXW σ χ)) χ := by
  have hb : qnf.2 σ = true := (List.mem_filter.mp hσpos).2
  have hσ := kvE2_sepAnchorVal_spec qnf M w x t h σ hb
  obtain ⟨_, _, _, hbelowXU, _, _⟩ :=
    kvE_subBracket2_complete_extract σ M (kvE2_sepAnchorVal qnf M w x t h σ) w x t hσ
  haveI : Nonempty M.carrier := ⟨x⟩
  exact Classical.epsilon_spec (hbelowXU χ (List.mem_filter.mp hχ).2)

/-- **Within-region value ordering** (task 340 Phase 7 conjunct (ii), the honest-consistency crux):
    for two slots of the same owner σ in the same region with a strictly smaller region rank, the
    smaller-rank slot's `value` is strictly smaller. Each region's rank-0/1/2 slots realize their
    types in the nested intervals `(x,x1_σ) < x1_σ < (x1_σ,w)` (left) / `(w,x1_σ) < x1_σ < (x1_σ,t)`
    (right) pinned by the value specs. Feeds `kvE2_sepSlotHonestGIdx_mono` to give honest consistency. -/
theorem kvE2_sepSlotValue_region_rank_mono {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf)
    {a b : KvE2SepSlot sig} (hamem : a ∈ kvE2_sepSlotBlock σ) (hbmem : b ∈ kvE2_sepSlotBlock σ)
    (hreg : kvE2_sepSlotRegionLeft a = kvE2_sepSlotRegionLeft b)
    (hrank : kvE2_sepSlotRank a < kvE2_sepSlotRank b) :
    kvE2_sepSlotValue qnf M w x t h a < kvE2_sepSlotValue qnf M w x t h b := by
  rw [kvE2_sepMem_slotBlock] at hamem hbmem
  by_cases hz1 : nf0_zoneSpec σ.1 = kvE2_sep_zXW3
  · rw [kvE2_sepSlotsLFor, kvE2_sepSlotsRFor, if_pos hz1, if_pos hz1] at hamem hbmem
    rcases hamem with haL | haR
    · rcases List.mem_append.mp haL with ha | ha
      · obtain ⟨χa, hχa, rfl⟩ := List.mem_map.mp ha
        rcases hbmem with hbL | hbR
        · rcases List.mem_append.mp hbL with hb | hb
          · obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hb; exact absurd hrank (by simp [kvE2_sepSlotRank])
          · rcases List.mem_cons.mp hb with rfl | hb
            · rw [kvE2_sepSlotValue_lX1]
              exact (kvE2_sepSlotValue_lXU_spec qnf M w x t hxw hwt h σ hσ hz1 χa hχa).2.1
            · obtain ⟨χb, hχb, rfl⟩ := List.mem_map.mp hb
              exact lt_trans (kvE2_sepSlotValue_lXU_spec qnf M w x t hxw hwt h σ hσ hz1 χa hχa).2.1
                (kvE2_sepSlotValue_lUW_spec qnf M w x t hxw hwt h σ hσ hz1 χb hχb).1
        · obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hbR; exact absurd hreg (by simp [kvE2_sepSlotRegionLeft])
      · rcases List.mem_cons.mp ha with rfl | ha
        · rcases hbmem with hbL | hbR
          · rcases List.mem_append.mp hbL with hb | hb
            · obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hb; exact absurd hrank (by simp [kvE2_sepSlotRank])
            · rcases List.mem_cons.mp hb with rfl | hb
              · exact absurd hrank (by simp [kvE2_sepSlotRank])
              · obtain ⟨χb, hχb, rfl⟩ := List.mem_map.mp hb
                rw [kvE2_sepSlotValue_lX1]
                exact (kvE2_sepSlotValue_lUW_spec qnf M w x t hxw hwt h σ hσ hz1 χb hχb).1
          · obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hbR; exact absurd hreg (by simp [kvE2_sepSlotRegionLeft])
        · obtain ⟨χa, _, rfl⟩ := List.mem_map.mp ha
          rcases hbmem with hbL | hbR
          · rcases List.mem_append.mp hbL with hb | hb
            · obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hb; exact absurd hrank (by simp [kvE2_sepSlotRank])
            · rcases List.mem_cons.mp hb with rfl | hb
              · exact absurd hrank (by simp [kvE2_sepSlotRank])
              · obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hb; exact absurd hrank (by simp [kvE2_sepSlotRank])
          · obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hbR; exact absurd hreg (by simp [kvE2_sepSlotRegionLeft])
    · obtain ⟨χa, _, rfl⟩ := List.mem_map.mp haR
      rcases hbmem with hbL | hbR
      · rcases List.mem_append.mp hbL with hb | hb
        · obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hb; exact absurd hreg (by simp [kvE2_sepSlotRegionLeft])
        · rcases List.mem_cons.mp hb with rfl | hb
          · exact absurd hreg (by simp [kvE2_sepSlotRegionLeft])
          · obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hb; exact absurd hreg (by simp [kvE2_sepSlotRegionLeft])
      · obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hbR; exact absurd hrank (by simp [kvE2_sepSlotRank])
  · by_cases hz2 : nf0_zoneSpec σ.1 = kvE2_sep_zWT3
    · rw [kvE2_sepSlotsLFor, kvE2_sepSlotsRFor, if_neg hz1, if_neg hz1, if_pos hz2, if_pos hz2]
        at hamem hbmem
      rcases hamem with haL | haR
      · obtain ⟨χa, _, rfl⟩ := List.mem_map.mp haL
        rcases hbmem with hbL | hbR
        · obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hbL; exact absurd hrank (by simp [kvE2_sepSlotRank])
        · rcases List.mem_append.mp hbR with hb | hb
          · obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hb; exact absurd hreg (by simp [kvE2_sepSlotRegionLeft])
          · rcases List.mem_cons.mp hb with rfl | hb
            · exact absurd hreg (by simp [kvE2_sepSlotRegionLeft])
            · obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hb; exact absurd hreg (by simp [kvE2_sepSlotRegionLeft])
      · rcases List.mem_append.mp haR with ha | ha
        · obtain ⟨χa, hχa, rfl⟩ := List.mem_map.mp ha
          rcases hbmem with hbL | hbR
          · obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hbL; exact absurd hreg (by simp [kvE2_sepSlotRegionLeft])
          · rcases List.mem_append.mp hbR with hb | hb
            · obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hb; exact absurd hrank (by simp [kvE2_sepSlotRank])
            · rcases List.mem_cons.mp hb with rfl | hb
              · rw [kvE2_sepSlotValue_rX1]
                exact (kvE2_sepSlotValue_rWX1_spec qnf M w x t hxw hwt h σ hσ hz2 χa hχa).2.1
              · obtain ⟨χb, hχb, rfl⟩ := List.mem_map.mp hb
                exact lt_trans (kvE2_sepSlotValue_rWX1_spec qnf M w x t hxw hwt h σ hσ hz2 χa hχa).2.1
                  (kvE2_sepSlotValue_rX1T_spec qnf M w x t hxw hwt h σ hσ hz2 χb hχb).1
        · rcases List.mem_cons.mp ha with rfl | ha
          · rcases hbmem with hbL | hbR
            · obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hbL; exact absurd hreg (by simp [kvE2_sepSlotRegionLeft])
            · rcases List.mem_append.mp hbR with hb | hb
              · obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hb; exact absurd hrank (by simp [kvE2_sepSlotRank])
              · rcases List.mem_cons.mp hb with rfl | hb
                · exact absurd hrank (by simp [kvE2_sepSlotRank])
                · obtain ⟨χb, hχb, rfl⟩ := List.mem_map.mp hb
                  rw [kvE2_sepSlotValue_rX1]
                  exact (kvE2_sepSlotValue_rX1T_spec qnf M w x t hxw hwt h σ hσ hz2 χb hχb).1
          · obtain ⟨χa, _, rfl⟩ := List.mem_map.mp ha
            rcases hbmem with hbL | hbR
            · obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hbL; exact absurd hreg (by simp [kvE2_sepSlotRegionLeft])
            · rcases List.mem_append.mp hbR with hb | hb
              · obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hb; exact absurd hrank (by simp [kvE2_sepSlotRank])
              · rcases List.mem_cons.mp hb with rfl | hb
                · exact absurd hrank (by simp [kvE2_sepSlotRank])
                · obtain ⟨χb, _, rfl⟩ := List.mem_map.mp hb; exact absurd hrank (by simp [kvE2_sepSlotRank])
    · rw [kvE2_sepSlotsLFor, kvE2_sepSlotsRFor, if_neg hz1, if_neg hz1, if_neg hz2, if_neg hz2]
        at hamem
      simp only [List.not_mem_nil, or_self] at hamem

/-- **The lex value family `G`** (Phase 6): over the full individual-slot family `Fin N`
    (`N = (kvE2_sepAllSlots qnf).length`), `G j = (value_j, j)` in the LEX product
    `M.carrier ×ₗ Fin N`. The slot index second coordinate makes `G` injective WITHOUT any
    value-distinctness hypothesis (the distinctness crux, SW:~1000): distinct owners may share
    witness values, but the index tiebreak is always distinct. `kvE2_ordRank G` is then the
    per-INDIVIDUAL-slot value rank — the value-faithful global index the refined carrier reads. -/
noncomputable def kvE2_sepSlotG {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    Fin (kvE2_sepAllSlots qnf).length → M.carrier ×ₗ Fin (kvE2_sepAllSlots qnf).length :=
  fun j => toLex (kvE2_sepSlotValue qnf M w x t h ((kvE2_sepAllSlots qnf).get j), j)

/-- `G` is injective (the slot-index second lex coordinate is injective), no value-distinctness
    hypothesis needed. Feeds `kvE2_ordRank_injective` → the cross-owner global `Nodup` conjunct. -/
theorem kvE2_sepSlotG_injective {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    Function.Injective (kvE2_sepSlotG qnf M w x t h) := by
  intro a b hab
  have h2 : ((kvE2_sepSlotValue qnf M w x t h ((kvE2_sepAllSlots qnf).get a), a) :
      M.carrier × Fin (kvE2_sepAllSlots qnf).length)
      = (kvE2_sepSlotValue qnf M w x t h ((kvE2_sepAllSlots qnf).get b), b) :=
    congrArg (ofLex) hab
  exact (Prod.ext_iff.mp h2).2

/-- A strictly smaller slot value forces a strictly smaller `G` (lex first coordinate), hence a
    strictly smaller `kvE2_ordRank` — the region-monotonicity engine for the honest order. -/
theorem kvE2_sepSlotG_lt_of_value_lt {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {a b : Fin (kvE2_sepAllSlots qnf).length}
    (hlt : kvE2_sepSlotValue qnf M w x t h ((kvE2_sepAllSlots qnf).get a)
      < kvE2_sepSlotValue qnf M w x t h ((kvE2_sepAllSlots qnf).get b)) :
    kvE2_sepSlotG qnf M w x t h a < kvE2_sepSlotG qnf M w x t h b := by
  exact Prod.Lex.left _ _ hlt

/-- **The honest per-individual-slot global index** (Phase 6/7): slot `s`'s value rank
    `kvE2_ordRank G` at its family position. This is the value-faithful per-slot index the refined
    carrier reads (via `kvE2_sepBlockPos`), replacing the tied `(3r,3r+1,3r+2)` owner-region tuple
    the 337 stop-guard refuted. Off-family (never on the enumeration) defaults to `0`. -/
noncomputable def kvE2_sepSlotHonestGIdx {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (s : KvE2SepSlot sig) : ℕ :=
  if hs : kvE2_sepSlotIndexOf qnf s < (kvE2_sepAllSlots qnf).length then
    kvE2_ordRank (kvE2_sepSlotG qnf M w x t h) ⟨kvE2_sepSlotIndexOf qnf s, hs⟩
  else 0

/-- **Region monotonicity engine** (Phase 7 conjunct (ii)): a strictly smaller slot value gives a
    strictly smaller honest global index. Within a region the bundle facts give
    `value(before) < value(anchor) < value(after)`, so this yields the region-order extension. -/
theorem kvE2_sepSlotHonestGIdx_mono {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {a b : KvE2SepSlot sig} (ha : a ∈ kvE2_sepAllSlots qnf) (hb : b ∈ kvE2_sepAllSlots qnf)
    (hlt : kvE2_sepSlotValue qnf M w x t h a < kvE2_sepSlotValue qnf M w x t h b) :
    kvE2_sepSlotHonestGIdx qnf M w x t h a < kvE2_sepSlotHonestGIdx qnf M w x t h b := by
  have hal : kvE2_sepSlotIndexOf qnf a < (kvE2_sepAllSlots qnf).length :=
    kvE2_sepSlotIndexOf_lt qnf ha
  have hbl : kvE2_sepSlotIndexOf qnf b < (kvE2_sepAllSlots qnf).length :=
    kvE2_sepSlotIndexOf_lt qnf hb
  have hga : (kvE2_sepAllSlots qnf).get ⟨kvE2_sepSlotIndexOf qnf a, hal⟩ = a := List.idxOf_get hal
  have hgb : (kvE2_sepAllSlots qnf).get ⟨kvE2_sepSlotIndexOf qnf b, hbl⟩ = b := List.idxOf_get hbl
  unfold kvE2_sepSlotHonestGIdx
  rw [dif_pos hal, dif_pos hbl]
  apply kvE2_ordRank_strictMono
  apply kvE2_sepSlotG_lt_of_value_lt
  rw [hga, hgb]; exact hlt

/-- **Cross-owner Nodup ingredient** (Phase 7 conjunct (iii)): the honest global index is injective
    on family members. Composes `kvE2_ordRank_injective` (on the index-injective `G`) with
    `kvE2_sepSlotIndexOf_injOn`. Gives distinct value-ranked indices for distinct individual slots
    — the per-slot faithfulness the refinement installs (no owner-region tie). -/
theorem kvE2_sepSlotHonestGIdx_injOn {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {a b : KvE2SepSlot sig} (ha : a ∈ kvE2_sepAllSlots qnf) (hb : b ∈ kvE2_sepAllSlots qnf)
    (heq : kvE2_sepSlotHonestGIdx qnf M w x t h a = kvE2_sepSlotHonestGIdx qnf M w x t h b) :
    a = b := by
  have hal : kvE2_sepSlotIndexOf qnf a < (kvE2_sepAllSlots qnf).length :=
    kvE2_sepSlotIndexOf_lt qnf ha
  have hbl : kvE2_sepSlotIndexOf qnf b < (kvE2_sepAllSlots qnf).length :=
    kvE2_sepSlotIndexOf_lt qnf hb
  unfold kvE2_sepSlotHonestGIdx at heq
  rw [dif_pos hal, dif_pos hbl] at heq
  have hfin := kvE2_ordRank_injective (kvE2_sepSlotG qnf M w x t h)
    (kvE2_sepSlotG_injective qnf M w x t h) heq
  exact kvE2_sepSlotIndexOf_injOn qnf ha hb (congrArg Fin.val hfin)

/-- **Honest consistency** (task 340 Phase 7 conjunct (ii)): the honest payload
    `block.map kvE2_sepSlotHonestGIdx` extends every region order. Within a region a larger rank has a
    larger value (`kvE2_sepSlotValue_region_rank_mono`), hence a larger value rank
    (`kvE2_sepSlotHonestGIdx_mono`). The value-faithful counterpart of
    `kvE2_sepConsistentBlock_slotIndexOf`. -/
theorem kvE2_sepConsistentBlock_honest {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf) :
    kvE2_sepConsistentBlock σ
      ((kvE2_sepSlotBlock σ).map (kvE2_sepSlotHonestGIdx qnf M w x t h)) = true := by
  rw [kvE2_sepConsistentBlock, decide_eq_true_eq]
  intro j k hreg hrank
  rw [kvE2_sepBlockMap_getD, kvE2_sepBlockMap_getD]
  have hjmem : (kvE2_sepSlotBlock σ).get j ∈ kvE2_sepSlotBlock σ := List.get_mem _ _
  have hkmem : (kvE2_sepSlotBlock σ).get k ∈ kvE2_sepSlotBlock σ := List.get_mem _ _
  refine kvE2_sepSlotHonestGIdx_mono qnf M w x t h
    (kvE2_sepMem_allSlots qnf hσ hjmem) (kvE2_sepMem_allSlots qnf hσ hkmem) ?_
  exact kvE2_sepSlotValue_region_rank_mono qnf M w x t hxw hwt h hσ hjmem hkmem hreg hrank

/-- **Global Nodup — honest value-rank payload** (task 340 Phase 7 conjunct (iii)): the flattened
    honest payload over the whole family is duplicate-free (`kvE2_sepSlotHonestGIdx` is injective on
    the family via the lex index tiebreak — no value-distinctness needed). -/
theorem kvE2_sepAllSlots_map_honestGIdx_nodup {sig : MonadicSignature} (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    ((kvE2_sepAllSlots qnf).map (kvE2_sepSlotHonestGIdx qnf M w x t h)).Nodup :=
  List.Nodup.map_on (fun a ha b hb hab => kvE2_sepSlotHonestGIdx_injOn qnf M w x t h ha hb hab)
    (kvE2_sepAllSlots_nodup qnf)

/-- **The honest order** (task 340 Phase 7 flip): all owners `.coincident`-tagged with the
    per-INDIVIDUAL-slot value-rank payload `block.map kvE2_sepSlotHonestGIdx` (replacing the tied
    length-3 `(3r,3r+1,3r+2)` owner-block the 337 stop-guard refuted). Model-dependent (the value
    rank is per-M). Structural mirror of `kvE2_sepCoincidentOrder` with the value-rank payload. -/
noncomputable def kvE2_sepHonestOrder {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) : KvE2SepWeakOrder sig :=
  (kvE2_sepPos qnf).zipIdx.map
    (fun p => (p.1, KvE2SepSpikeOrderType.coincident,
      (kvE2_sepSlotBlock p.1).map (kvE2_sepSlotHonestGIdx qnf M w x t h)))

/-- The honest order is present in the enumeration index (F2). A `kvE2_sepOrderTypes_mem_aux`
    instance (`s = 0`, all-coincident tag, honest tuple); every tuple component `< 3n` from
    `kvE2_ordRank_lt` feeding `kvE2_sepIdxTuple_mem_of_lt`. -/
theorem kvE2_sepHonestOrder_mem_orderTypes {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    kvE2_sepHonestOrder qnf M w x t h ∈ kvE2_sepOrderTypes qnf := by
  rw [kvE2_sepHonestOrder, kvE2_sepOrderTypes]
  refine kvE2_sepOrderTypes_mem_aux' (fun _ => KvE2SepSpikeOrderType.coincident) _
    (fun σ => (kvE2_sepSlotBlock σ).map (kvE2_sepSlotHonestGIdx qnf M w x t h))
    (kvE2_sepPos qnf) 0 (fun σ hσ => ?_)
  have h := kvE2_sepIdxTupleN_mem_of_forall_lt (kvE2_sepAllSlots qnf).length
    ((kvE2_sepSlotBlock σ).map (kvE2_sepSlotHonestGIdx qnf M w x t h)) (fun y hy => by
      obtain ⟨s, hs, rfl⟩ := List.mem_map.mp hy
      have hidx := kvE2_sepSlotIndexOf_lt qnf (kvE2_sepMem_allSlots qnf hσ hs)
      rw [kvE2_sepSlotHonestGIdx, dif_pos hidx]
      exact kvE2_ordRank_lt _ _)
  rwa [List.length_map] at h

/-- **The honest order is a carrier member** (task 340 Phase 5B — the object task 337 consumes).
    Under an honest interior realization (`hLR`) the value-rank honest order is a VALID, PRESENT
    member of `kvE2_sepArr' qnf`. The three `kvE2_sepDisjValid` conjuncts: (i) all-`.coincident`
    validity reuses `kvE2_sepCoincidentOwner_valid_left/right` VERBATIM (tuple-agnostic, CLOSED
    self-zone bit only); (ii) consistency via `kvE2_sepHonestTuple_consistent`; (iii) `i₀`-`Nodup`
    from `kvE2_ordRank_injective` on the keystone-injective anchor family (through `3·`). -/
theorem kvE2_sepHonestOrder_mem_arr' {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hLR : ∀ σ ∈ kvE2_sepPos qnf,
        nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3) :
    kvE2_sepHonestOrder qnf M w x t h ∈ kvE2_sepArr' qnf := by
  rw [kvE2_sepArr', List.mem_filter]
  refine ⟨kvE2_sepHonestOrder_mem_orderTypes qnf M w x t h, ?_⟩
  rw [kvE2_sepDisjValid, Bool.and_eq_true, Bool.and_eq_true]
  refine ⟨⟨?_, ?_⟩, ?_⟩
  · -- (i) per-owner closed-self-zone validity (all tags `.coincident`), reused verbatim.
    rw [List.all_eq_true]
    intro p hp
    rw [kvE2_sepHonestOrder, List.mem_map] at hp
    obtain ⟨⟨σ, i⟩, hmem, rfl⟩ := hp
    have hσmem : σ ∈ kvE2_sepPos qnf := List.fst_mem_of_mem_zipIdx hmem
    show kvE2_sepDisjValidOwner σ KvE2SepSpikeOrderType.coincident = true
    rcases hLR σ hσmem with hzone | hzone
    · exact kvE2_sepCoincidentOwner_valid_left qnf M w x t hxw hwt h σ hσmem hzone
    · exact kvE2_sepCoincidentOwner_valid_right qnf M w x t hxw hwt h σ hσmem hzone
  · -- (ii) per-owner region-scoped consistency via the value-rank monotonicity engine.
    rw [List.all_eq_true]
    intro p hp
    rw [kvE2_sepHonestOrder, List.mem_map] at hp
    obtain ⟨⟨σ, k⟩, hmem, rfl⟩ := hp
    have hσmem : σ ∈ kvE2_sepPos qnf := List.fst_mem_of_mem_zipIdx hmem
    exact kvE2_sepConsistentBlock_honest qnf M w x t hxw hwt h hσmem
  · -- (iii) cross-owner global Nodup on the value ranks (injective on the family).
    rw [decide_eq_true_eq, kvE2_sepHonestOrder,
      kvE2_sepZipPayload_flatMap qnf (fun _ => KvE2SepSpikeOrderType.coincident)
        (kvE2_sepSlotHonestGIdx qnf M w x t h)]
    exact kvE2_sepAllSlots_map_honestGIdx_nodup qnf M w x t h

/-! ### Task 340 Phase 5C — value-faithful monotonicity (the honest `a < u' < b` interleave)

The value order is reproduced by the honest tuple's global indices. The load-bearing content
(report 06 Q4): the cross-region step `i₂(σ) < i₁(τ) ⟺ r_σ < r_τ ⟺ x1_σ < x1_τ`. With the block
tuple `(3r, 3r+1, 3r+2)`, `i₂(σ)=3r_σ+2` and `i₁(τ)=3r_τ+1`, so `i₂(σ) < i₁(τ) ⟺ r_σ < r_τ`
(`omega`); and `x1_σ < x1_τ → r_σ < r_τ` is `kvE2_ordRank_strictMono` on the anchor family. This
is the merged-chain monotonicity `kvE2_sepSlotsLOf/ROf` inherit through `kvE2_sepSlotGIdx` — the
disjunct task 339 dropped, now expressible because indices are value-ranked not region-primary. -/

/-- **Anchor order lifts to rank order** (task 340 Phase 5C): a strictly smaller anchor gets a
    strictly smaller value rank. Direct `kvE2_ordRank_strictMono` on the anchor family. -/
theorem kvE2_sepHonest_rank_strictMono {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {a b : Fin (kvE2_sepPos qnf).length}
    (hlt : kvE2_sepAnchorFam qnf M w x t h a < kvE2_sepAnchorFam qnf M w x t h b) :
    kvE2_ordRank (kvE2_sepAnchorFam qnf M w x t h) a
      < kvE2_ordRank (kvE2_sepAnchorFam qnf M w x t h) b :=
  kvE2_ordRank_strictMono (kvE2_sepAnchorFam qnf M w x t h) hlt

/-! ### Task 337 Phase 1 — the halign FOUNDATION bridge

The joint sorted lists `kvE2_sepSlotsLOf/ROf (kvE2_sepHonestOrder …)` are `mergeSort`ed by
`kvE2_sepSlotMergeLe`, whose key reader is `kvE2_sepSlotGIdx wo`. On the honest order this reader
projects, at `kvE2_sepBlockPos s`, the payload tuple `block.map kvE2_sepSlotHonestGIdx` — so the
merge key of slot `s` is exactly its value-faithful index `kvE2_sepSlotHonestGIdx … s`. This is the
load-bearing bridge from the structural sort key to the model value order. -/

/-- **halign FOUNDATION bridge** (task 337 Phase 1): under the honest order, the mergeSort key
    reader `kvE2_sepSlotGIdx` coincides with the value-faithful per-slot index
    `kvE2_sepSlotHonestGIdx` on every slot of every positive owner's block. Resolves the honest
    order's `find?` (owners are `kvE2_sepPos`-distinct) to `σ`'s payload, then reads it at
    `kvE2_sepBlockPos s` via `kvE2_sepBlockMap_getD` / `List.idxOf_get`. -/
theorem kvE2_sepSlotGIdx_honestOrder {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf)
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2_sepSlotBlock σ) :
    kvE2_sepSlotGIdx (kvE2_sepHonestOrder qnf M w x t h) s
      = kvE2_sepSlotHonestGIdx qnf M w x t h s := by
  have hsub : kvE2_sepSlotSub s = σ := kvE2_sepSlotSub_of_mem_block hs
  have hfind : (kvE2_sepHonestOrder qnf M w x t h).find?
        (fun p => decide (p.1 = kvE2_sepSlotSub s))
      = some (σ, KvE2SepSpikeOrderType.coincident,
          (kvE2_sepSlotBlock σ).map (kvE2_sepSlotHonestGIdx qnf M w x t h)) := by
    rw [hsub, kvE2_sepHonestOrder, List.find?_map]
    have hex : ∃ q ∈ (kvE2_sepPos qnf).zipIdx,
        ((fun p => decide (p.1 = σ)) ∘
          (fun p : NormalForm sig 1 4 × ℕ =>
            (p.1, KvE2SepSpikeOrderType.coincident,
              (kvE2_sepSlotBlock p.1).map (kvE2_sepSlotHonestGIdx qnf M w x t h)))) q = true := by
      have hm : σ ∈ (kvE2_sepPos qnf).zipIdx.map Prod.fst := by
        rw [List.zipIdx_map_fst]; exact hσ
      obtain ⟨q, hq, hq1⟩ := List.mem_map.mp hm
      exact ⟨q, hq, by simp [Function.comp, hq1]⟩
    obtain ⟨q, hq, hqp⟩ := hex
    cases hf : (kvE2_sepPos qnf).zipIdx.find?
        ((fun p => decide (p.1 = σ)) ∘
          (fun p : NormalForm sig 1 4 × ℕ =>
            (p.1, KvE2SepSpikeOrderType.coincident,
              (kvE2_sepSlotBlock p.1).map (kvE2_sepSlotHonestGIdx qnf M w x t h)))) with
    | none =>
      rw [List.find?_eq_none] at hf
      exact absurd hqp (by simpa using hf q hq)
    | some r =>
      have hr := List.find?_some hf
      simp only [Function.comp, decide_eq_true_eq] at hr
      simp [hr]
  unfold kvE2_sepSlotGIdx
  rw [hfind]
  simp only [Option.map_some, Option.getD_some]
  have hidx : kvE2_sepBlockPos s = (kvE2_sepSlotBlock σ).idxOf s := by
    rw [kvE2_sepBlockPos, hsub]
  rw [hidx]
  have hlt : (kvE2_sepSlotBlock σ).idxOf s < (kvE2_sepSlotBlock σ).length :=
    List.idxOf_lt_length_of_mem hs
  rw [List.getD_eq_getElem?_getD, List.getElem?_map, List.getElem?_eq_getElem hlt]
  simp only [Option.map_some, Option.getD_some]
  congr 1
  exact List.idxOf_get hlt

/-- **halign monotonicity** (task 337 Phase 2 ingredient): on the honest order the mergeSort key
    `kvE2_sepSlotGIdx` is strictly monotone in the slot value across the whole family. Composes the
    bridge `kvE2_sepSlotGIdx_honestOrder` with the value-faithful `kvE2_sepSlotHonestGIdx_mono`.
    This is the fact that makes `kvE2_sepSlotsLOf/ROf` a genuinely value-sorted chain. -/
theorem kvE2_sepSlotGIdx_honestOrder_mono {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {σ τ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf) (hτ : τ ∈ kvE2_sepPos qnf)
    {a b : KvE2SepSlot sig} (ha : a ∈ kvE2_sepSlotBlock σ) (hb : b ∈ kvE2_sepSlotBlock τ)
    (hlt : kvE2_sepSlotValue qnf M w x t h a < kvE2_sepSlotValue qnf M w x t h b) :
    kvE2_sepSlotGIdx (kvE2_sepHonestOrder qnf M w x t h) a
      < kvE2_sepSlotGIdx (kvE2_sepHonestOrder qnf M w x t h) b := by
  rw [kvE2_sepSlotGIdx_honestOrder qnf M w x t h hσ ha,
      kvE2_sepSlotGIdx_honestOrder qnf M w x t h hτ hb]
  exact kvE2_sepSlotHonestGIdx_mono qnf M w x t h
    (kvE2_sepMem_allSlots qnf hσ ha) (kvE2_sepMem_allSlots qnf hτ hb) hlt

/-- **halign injectivity** (task 337 Phase 2 `hnd` ingredient): on the honest order the mergeSort
    key `kvE2_sepSlotGIdx` is injective on the whole slot family. Composes the bridge with the
    value-faithful `kvE2_sepSlotHonestGIdx_injOn`. This is the no-ties fact behind the joint sorted
    lists' `Nodup`. -/
theorem kvE2_sepSlotGIdx_honestOrder_injOn {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {σ τ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf) (hτ : τ ∈ kvE2_sepPos qnf)
    {a b : KvE2SepSlot sig} (ha : a ∈ kvE2_sepSlotBlock σ) (hb : b ∈ kvE2_sepSlotBlock τ)
    (heq : kvE2_sepSlotGIdx (kvE2_sepHonestOrder qnf M w x t h) a
      = kvE2_sepSlotGIdx (kvE2_sepHonestOrder qnf M w x t h) b) :
    a = b := by
  rw [kvE2_sepSlotGIdx_honestOrder qnf M w x t h hσ ha,
      kvE2_sepSlotGIdx_honestOrder qnf M w x t h hτ hb] at heq
  exact kvE2_sepSlotHonestGIdx_injOn qnf M w x t h
    (kvE2_sepMem_allSlots qnf hσ ha) (kvE2_sepMem_allSlots qnf hτ hb) heq

/-! ### Task 337 Phase 1 — value-sorted merged slot lists (halign consumers)

The joint lists `kvE2_sepSlotsLOf/ROf wo` are `mergeSort`ed by the merge key `kvE2_sepSlotMergeLe wo`
(`= decide (kvE2_sepSlotGIdx wo a ≤ kvE2_sepSlotGIdx wo b)`). Because that key is a total preorder
(`≤` on the global-index ℕ), `List.pairwise_mergeSort` gives the lists `Pairwise` under the key —
for ANY `wo`. Specialised to the honest order and threaded through the banked halign trio
(`kvE2_sepSlotGIdx_honestOrder{,_mono,_injOn}`), the lists become genuinely value-sorted. These are
the value-sortedness facts P2/P3 consume; they are NOT re-derivations of the trio. -/

/-- The merge key `kvE2_sepSlotMergeLe wo` is transitive (globally, `≤` on ℕ). -/
theorem kvE2_sepSlotMergeLe_trans {sig : MonadicSignature} (wo : KvE2SepWeakOrder sig)
    (a b c : KvE2SepSlot sig)
    (hab : kvE2_sepSlotMergeLe wo a b = true) (hbc : kvE2_sepSlotMergeLe wo b c = true) :
    kvE2_sepSlotMergeLe wo a c = true := by
  simp only [kvE2_sepSlotMergeLe, decide_eq_true_eq] at hab hbc ⊢
  exact le_trans hab hbc

/-- The merge key `kvE2_sepSlotMergeLe wo` is total (globally, `≤` on ℕ). -/
theorem kvE2_sepSlotMergeLe_total {sig : MonadicSignature} (wo : KvE2SepWeakOrder sig)
    (a b : KvE2SepSlot sig) :
    kvE2_sepSlotMergeLe wo a b || kvE2_sepSlotMergeLe wo b a := by
  simp only [kvE2_sepSlotMergeLe, Bool.or_eq_true, decide_eq_true_eq]
  exact le_total _ _

/-- **Merge-key sortedness, LEFT** (task 337 Phase 1 ingredient): the joint LEFT slot list is
    `Pairwise` under the merge key `kvE2_sepSlotMergeLe wo`. Direct `List.pairwise_mergeSort`. -/
theorem kvE2_sepSlotsLOf_mergeSorted {sig : MonadicSignature} (wo : KvE2SepWeakOrder sig) :
    (kvE2_sepSlotsLOf wo).Pairwise (fun a b => kvE2_sepSlotMergeLe wo a b = true) := by
  rw [kvE2_sepSlotsLOf]
  exact List.pairwise_mergeSort (kvE2_sepSlotMergeLe_trans wo) (kvE2_sepSlotMergeLe_total wo) _

/-- **Merge-key sortedness, RIGHT** (mirror of `kvE2_sepSlotsLOf_mergeSorted`). -/
theorem kvE2_sepSlotsROf_mergeSorted {sig : MonadicSignature} (wo : KvE2SepWeakOrder sig) :
    (kvE2_sepSlotsROf wo).Pairwise (fun a b => kvE2_sepSlotMergeLe wo a b = true) := by
  rw [kvE2_sepSlotsROf]
  exact List.pairwise_mergeSort (kvE2_sepSlotMergeLe_trans wo) (kvE2_sepSlotMergeLe_total wo) _

/-- The wo-ordered owner list of an enumeration member lists exactly the positive owners:
    `kvE2_sepOrderOwners wo` is a `mergeSort` permutation of `wo.map Prod.fst = kvE2_sepPos qnf`. -/
theorem kvE2_sepOrderOwners_mem_pos {sig : MonadicSignature} (qnf : NormalForm sig 2 3)
    {wo : KvE2SepWeakOrder sig} (hwo : wo ∈ kvE2_sepOrderTypes qnf)
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepOrderOwners wo) : σ ∈ kvE2_sepPos qnf := by
  rw [kvE2_sepOrderOwners] at hσ
  have hperm := (List.mergeSort_perm wo (fun a b => decide (a.2.2.getD 0 0 ≤ b.2.2.getD 0 0))).map
    Prod.fst
  rw [kvE2_sepOrderTypes_owners qnf hwo] at hperm
  exact hperm.mem_iff.mp hσ

/-- Every slot of the joint LEFT list belongs to some positive owner's slot block. -/
theorem kvE2_sepSlotsLOf_mem_block {sig : MonadicSignature} (qnf : NormalForm sig 2 3)
    {wo : KvE2SepWeakOrder sig} (hwo : wo ∈ kvE2_sepOrderTypes qnf)
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2_sepSlotsLOf wo) :
    ∃ σ ∈ kvE2_sepPos qnf, s ∈ kvE2_sepSlotBlock σ := by
  rw [kvE2_sepSlotsLOf] at hs
  obtain ⟨σ, hσ, hsσ⟩ := List.mem_flatMap.mp ((List.mergeSort_perm _ _).mem_iff.mp hs)
  exact ⟨σ, kvE2_sepOrderOwners_mem_pos qnf hwo hσ, by
    rw [kvE2_sepSlotBlock]; exact List.mem_append_left _ hsσ⟩

/-- Every slot of the joint RIGHT list belongs to some positive owner's slot block. -/
theorem kvE2_sepSlotsROf_mem_block {sig : MonadicSignature} (qnf : NormalForm sig 2 3)
    {wo : KvE2SepWeakOrder sig} (hwo : wo ∈ kvE2_sepOrderTypes qnf)
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2_sepSlotsROf wo) :
    ∃ σ ∈ kvE2_sepPos qnf, s ∈ kvE2_sepSlotBlock σ := by
  rw [kvE2_sepSlotsROf] at hs
  obtain ⟨σ, hσ, hsσ⟩ := List.mem_flatMap.mp ((List.mergeSort_perm _ _).mem_iff.mp hs)
  exact ⟨σ, kvE2_sepOrderOwners_mem_pos qnf hwo hσ, by
    rw [kvE2_sepSlotBlock]; exact List.mem_append_right _ hsσ⟩

/-- **Value-sortedness of the joint LEFT list on the honest order** (task 337 Phase 1): the merged
    LEFT slot list is `Pairwise` value-nondecreasing. Consumes the banked halign trio: the list is
    merge-key sorted (`kvE2_sepSlotsLOf_mergeSorted`), and on the honest order a strictly smaller
    merge key forces a strictly smaller value — contrapositively, `value b < value a` would give
    `key b < key a` (`kvE2_sepSlotGIdx_honestOrder_mono`), contradicting `key a ≤ key b`. -/
theorem kvE2_sepSlotsLOf_honest_valueSorted {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    (kvE2_sepSlotsLOf (kvE2_sepHonestOrder qnf M w x t h)).Pairwise
      (fun a b => kvE2_sepSlotValue qnf M w x t h a ≤ kvE2_sepSlotValue qnf M w x t h b) := by
  have hwo := kvE2_sepHonestOrder_mem_orderTypes qnf M w x t h
  refine (kvE2_sepSlotsLOf_mergeSorted _).imp_of_mem ?_
  intro a b ha hb hab
  obtain ⟨σ, hσ, haσ⟩ := kvE2_sepSlotsLOf_mem_block qnf hwo ha
  obtain ⟨τ, hτ, hbτ⟩ := kvE2_sepSlotsLOf_mem_block qnf hwo hb
  rw [kvE2_sepSlotMergeLe, decide_eq_true_eq] at hab
  by_contra hlt
  rw [not_le] at hlt
  exact absurd hab (not_le.mpr (kvE2_sepSlotGIdx_honestOrder_mono qnf M w x t h hτ hσ hbτ haσ hlt))

/-- **Value-sortedness of the joint RIGHT list on the honest order** (mirror). -/
theorem kvE2_sepSlotsROf_honest_valueSorted {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    (kvE2_sepSlotsROf (kvE2_sepHonestOrder qnf M w x t h)).Pairwise
      (fun a b => kvE2_sepSlotValue qnf M w x t h a ≤ kvE2_sepSlotValue qnf M w x t h b) := by
  have hwo := kvE2_sepHonestOrder_mem_orderTypes qnf M w x t h
  refine (kvE2_sepSlotsROf_mergeSorted _).imp_of_mem ?_
  intro a b ha hb hab
  obtain ⟨σ, hσ, haσ⟩ := kvE2_sepSlotsROf_mem_block qnf hwo ha
  obtain ⟨τ, hτ, hbτ⟩ := kvE2_sepSlotsROf_mem_block qnf hwo hb
  rw [kvE2_sepSlotMergeLe, decide_eq_true_eq] at hab
  by_contra hlt
  rw [not_le] at hlt
  exact absurd hab (not_le.mpr (kvE2_sepSlotGIdx_honestOrder_mono qnf M w x t h hτ hσ hbτ haσ hlt))

/-! ### Task 337 Phase 1 — region-assembly foundations (anchor boundary facts)

The region-assembly helper (`kvE2_sepHonest_engineInputs`) feeds `k1v_sorted_realizationK` regions
whose boundaries are the value-sorted interior anchors. The structural inputs `hpos`/`hlink`/`hbdry`
rest on two anchor facts, banked here as green sub-lemmas (H2 decomposition of the partition):
(i) each anchor (`.lX1`/`.rX1`) slot value lies strictly in its side's open interval — from the
honest bundles; (ii) distinct interior owners have distinct anchor values — the keystone
`kvE2_sepAnchor_injOn` lifted to the slot-value layer. These are model-order facts consumed as the
`hpos` strictness and `hbdry` endpoints; they do NOT re-derive the banked halign/value-sortedness
trio. -/

/-- **LEFT anchor slot in `(x, w)`** (Phase 1 `hbdry`/`hpos` ingredient): a LEFT-interior owner's
    `.lX1` slot value lies strictly between `x` and the shared `w`. Directly the honest bundle L's
    anchor bounds, re-typed through the definitional `kvE2_sepSlotValue_lX1`. -/
theorem kvE2_sepSlotValue_lX1_mem {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (σ : NormalForm sig 1 4) (hσpos : σ ∈ kvE2_sepPos qnf)
    (hzone : nf0_zoneSpec σ.1 = kvE2_sep_zXW3) :
    x < kvE2_sepSlotValue qnf M w x t h (.lX1 σ)
      ∧ kvE2_sepSlotValue qnf M w x t h (.lX1 σ) < w := by
  rw [kvE2_sepSlotValue_lX1]
  exact ⟨(kvE2_sepHonestAnchorBundleL qnf M w x t hxw hwt h σ hσpos hzone).1,
    (kvE2_sepHonestAnchorBundleL qnf M w x t hxw hwt h σ hσpos hzone).2.1⟩

/-- **RIGHT anchor slot in `(w, t)`** (mirror of `kvE2_sepSlotValue_lX1_mem`): a RIGHT-interior
    owner's `.rX1` slot value lies strictly between the shared `w` and `t`. Honest bundle R. -/
theorem kvE2_sepSlotValue_rX1_mem {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (σ : NormalForm sig 1 4) (hσpos : σ ∈ kvE2_sepPos qnf)
    (hzone : nf0_zoneSpec σ.1 = kvE2_sep_zWT3) :
    w < kvE2_sepSlotValue qnf M w x t h (.rX1 σ)
      ∧ kvE2_sepSlotValue qnf M w x t h (.rX1 σ) < t := by
  rw [kvE2_sepSlotValue_rX1]
  exact ⟨(kvE2_sepHonestAnchorBundleR qnf M w x t hxw hwt h σ hσpos hzone).1,
    (kvE2_sepHonestAnchorBundleR qnf M w x t hxw hwt h σ hσpos hzone).2.1⟩

/-- **LEFT anchor value distinctness** (Phase 1 `hpos` strictness ingredient): distinct positive
    owners have distinct `.lX1` slot values. The keystone `kvE2_sepAnchor_injOn` at the slot-value
    layer (via the definitional `kvE2_sepSlotValue_lX1`). -/
theorem kvE2_sepSlotValue_lX1_injOn {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {σ τ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf) (hτ : τ ∈ kvE2_sepPos qnf)
    (heq : kvE2_sepSlotValue qnf M w x t h (.lX1 σ)
      = kvE2_sepSlotValue qnf M w x t h (.lX1 τ)) : σ = τ := by
  rw [kvE2_sepSlotValue_lX1, kvE2_sepSlotValue_lX1] at heq
  exact kvE2_sepAnchor_injOn qnf M w x t h hσ hτ heq

/-- **RIGHT anchor value distinctness** (mirror): distinct positive owners have distinct `.rX1`
    slot values. -/
theorem kvE2_sepSlotValue_rX1_injOn {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {σ τ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf) (hτ : τ ∈ kvE2_sepPos qnf)
    (heq : kvE2_sepSlotValue qnf M w x t h (.rX1 σ)
      = kvE2_sepSlotValue qnf M w x t h (.rX1 τ)) : σ = τ := by
  rw [kvE2_sepSlotValue_rX1, kvE2_sepSlotValue_rX1] at heq
  exact kvE2_sepAnchor_injOn qnf M w x t h hσ hτ heq

/-! ### Task 337 Phase 1 — merged slot-list `Nodup` (region `hnd` foundation)

`k1v_sorted_realizationK`'s `hnd` obligation (each region's slot content duplicate-free) rests on the
whole merged list being duplicate-free. Distinct individual slots stay distinct through the
point-level `mergeSort` (a permutation): the pre-sort per-owner LEFT/RIGHT blocks are each `Nodup`
(left/right parts of the banked `kvE2_sepSlotBlock_nodup`) and cross-owner disjoint (subsets of the
banked disjoint full blocks). Model-independent; collision-free (structural slot identity, not model
value). -/

/-- σ's canonical LEFT-region slot block is duplicate-free (left part of the `Nodup` full block). -/
theorem kvE2_sepSlotsLFor_nodup {sig : MonadicSignature} (σ : NormalForm sig 1 4) :
    (kvE2_sepSlotsLFor σ).Nodup := by
  have h := kvE2_sepSlotBlock_nodup σ
  rw [kvE2_sepSlotBlock, List.nodup_append] at h
  exact h.1

/-- σ's canonical RIGHT-region slot block is duplicate-free (right part of the `Nodup` full block). -/
theorem kvE2_sepSlotsRFor_nodup {sig : MonadicSignature} (σ : NormalForm sig 1 4) :
    (kvE2_sepSlotsRFor σ).Nodup := by
  have h := kvE2_sepSlotBlock_nodup σ
  rw [kvE2_sepSlotBlock, List.nodup_append] at h
  exact h.2.1

/-- LEFT blocks of distinct owners are disjoint (subsets of the disjoint full blocks). -/
theorem kvE2_sepSlotsLFor_disjoint {sig : MonadicSignature} {σ τ : NormalForm sig 1 4}
    (hne : σ ≠ τ) : (kvE2_sepSlotsLFor σ).Disjoint (kvE2_sepSlotsLFor τ) := by
  intro a ha hb
  exact kvE2_sep_blocks_disjoint hne
    (by rw [kvE2_sepSlotBlock]; exact List.mem_append_left _ ha)
    (by rw [kvE2_sepSlotBlock]; exact List.mem_append_left _ hb)

/-- RIGHT blocks of distinct owners are disjoint (subsets of the disjoint full blocks). -/
theorem kvE2_sepSlotsRFor_disjoint {sig : MonadicSignature} {σ τ : NormalForm sig 1 4}
    (hne : σ ≠ τ) : (kvE2_sepSlotsRFor σ).Disjoint (kvE2_sepSlotsRFor τ) := by
  intro a ha hb
  exact kvE2_sep_blocks_disjoint hne
    (by rw [kvE2_sepSlotBlock]; exact List.mem_append_right _ ha)
    (by rw [kvE2_sepSlotBlock]; exact List.mem_append_right _ hb)

/-- The wo-ordered owner list is duplicate-free (a `mergeSort` permutation of the `Nodup`
    positive spine `kvE2_sepPos`). -/
theorem kvE2_sepOrderOwners_nodup {sig : MonadicSignature} (qnf : NormalForm sig 2 3)
    {wo : KvE2SepWeakOrder sig} (hwo : wo ∈ kvE2_sepOrderTypes qnf) :
    (kvE2_sepOrderOwners wo).Nodup := by
  rw [kvE2_sepOrderOwners]
  have hperm : List.Perm
      ((wo.mergeSort (fun a b => decide (a.2.2.getD 0 0 ≤ b.2.2.getD 0 0))).map Prod.fst)
      (kvE2_sepPos qnf) := by
    have hp := (List.mergeSort_perm wo
      (fun a b => decide (a.2.2.getD 0 0 ≤ b.2.2.getD 0 0))).map Prod.fst
    rwa [kvE2_sepOrderTypes_owners qnf hwo] at hp
  exact hperm.nodup_iff.mpr (kvE2_sepPos_nodup qnf)

/-- **The joint LEFT slot list is duplicate-free** (task 337 Phase 1 `hnd` foundation): distinct
    slots stay distinct through the point-level merge. `mergeSort` is a permutation, and the pre-sort
    flatMap over the (`Nodup`) positive owners of the per-owner LEFT blocks is `Nodup` by
    `kvE2_sepSlotsLFor_nodup` + cross-owner `kvE2_sepSlotsLFor_disjoint`. -/
theorem kvE2_sepSlotsLOf_nodup {sig : MonadicSignature} (qnf : NormalForm sig 2 3)
    {wo : KvE2SepWeakOrder sig} (hwo : wo ∈ kvE2_sepOrderTypes qnf) :
    (kvE2_sepSlotsLOf wo).Nodup := by
  rw [kvE2_sepSlotsLOf]
  refine (List.mergeSort_perm _ _).nodup_iff.mpr ?_
  rw [List.nodup_flatMap]
  exact ⟨fun σ _ => kvE2_sepSlotsLFor_nodup σ,
    (kvE2_sepOrderOwners_nodup qnf hwo).imp (fun hne => kvE2_sepSlotsLFor_disjoint hne)⟩

/-- **The joint RIGHT slot list is duplicate-free** (mirror of `kvE2_sepSlotsLOf_nodup`). -/
theorem kvE2_sepSlotsROf_nodup {sig : MonadicSignature} (qnf : NormalForm sig 2 3)
    {wo : KvE2SepWeakOrder sig} (hwo : wo ∈ kvE2_sepOrderTypes qnf) :
    (kvE2_sepSlotsROf wo).Nodup := by
  rw [kvE2_sepSlotsROf]
  refine (List.mergeSort_perm _ _).nodup_iff.mpr ?_
  rw [List.nodup_flatMap]
  exact ⟨fun σ _ => kvE2_sepSlotsRFor_nodup σ,
    (kvE2_sepOrderOwners_nodup qnf hwo).imp (fun hne => kvE2_sepSlotsRFor_disjoint hne)⟩

/-! ### Task 337 Phase 1 — strict base realizers in the whole side interval (region `hreal`)

The engine `k1v_sorted_realizationK`'s `hreal` obligation asks, for every base 1-type `χ` placed in a
region `(lo, hi)`, for a STRICT-interior realizer. The design-committed resolution (b) supplies the
strict realizer from the OWNER-RELATIVE honest bundle intervals (`kvE2_sepHonestAnchorBundleL/R`),
which are strict BY CONSTRUCTION — `χ` of a LEFT owner `σ` realizes strictly inside `(x, a_σ)` (its
`zXU` types) or `(a_σ, w)` (its `zUW` types), both `⊆ (x, w)`; mirror on the right in `(w, t)`. This
is the whole-side (`(x,w)` / `(w,t)`) strict realizer, monotonicity-closed through the bundle anchor
bounds. It does NOT rest on any base-value ≠ anchor-value non-collision claim (resolution (a), which
is false in general): the strictness is entirely owner-relative. -/

/-- **LEFT base realizer in `(x, w)`** (Phase 1 region `hreal` ingredient): every base 1-type of a
    LEFT-interior owner `σ` — whether in the below-anchor `zXU` set or the above-anchor `zUW` set —
    has a strict-interior realizer in the whole LEFT interval `(x, w)`. From honest bundle L: the
    `zXU` witness sits in `(x, a_σ) ⊆ (x, w)` (via `a_σ < w`), the `zUW` witness in `(a_σ, w) ⊆
    (x, w)` (via `x < a_σ`). Resolution (b) strictness — no non-collision assumption. -/
theorem kvE2_sepHonestBaseRealizerL {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (σ : NormalForm sig 1 4) (hσpos : σ ∈ kvE2_sepPos qnf)
    (hzone : nf0_zoneSpec σ.1 = kvE2_sep_zXW3)
    (χ : NormalForm sig 0 1)
    (hχ : χ ∈ kvE2_sepS σ kvE_sub2_zXU ++ kvE2_sepS σ kvE_sub2_zUW) :
    ∃ u : M.carrier, x < u ∧ u < w ∧ nf_eval_nf M 0 1 (fun _ => u) χ := by
  have hb := kvE2_sepHonestAnchorBundleL qnf M w x t hxw hwt h σ hσpos hzone
  rcases List.mem_append.mp hχ with hc | hc
  · obtain ⟨u, hxu, hua, hev⟩ := hb.2.2.1 χ hc
    exact ⟨u, hxu, lt_trans hua hb.2.1, hev⟩
  · obtain ⟨u, hau, huw, hev⟩ := hb.2.2.2 χ hc
    exact ⟨u, lt_trans hb.1 hau, huw, hev⟩

/-- **RIGHT base realizer in `(w, t)`** (mirror of `kvE2_sepHonestBaseRealizerL`): every base 1-type
    of a RIGHT-interior owner `σ` — below-anchor `zWX1` or above-anchor `zWT` — has a strict-interior
    realizer in the whole RIGHT interval `(w, t)`, from honest bundle R. Resolution (b) strictness. -/
theorem kvE2_sepHonestBaseRealizerR {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (σ : NormalForm sig 1 4) (hσpos : σ ∈ kvE2_sepPos qnf)
    (hzone : nf0_zoneSpec σ.1 = kvE2_sep_zWT3)
    (χ : NormalForm sig 0 1)
    (hχ : χ ∈ kvE2_sepS σ kvE2_sep_zWX1 ++ kvE2_sepS σ kvE_sub2_zWT) :
    ∃ u : M.carrier, w < u ∧ u < t ∧ nf_eval_nf M 0 1 (fun _ => u) χ := by
  have hb := kvE2_sepHonestAnchorBundleR qnf M w x t hxw hwt h σ hσpos hzone
  rcases List.mem_append.mp hχ with hc | hc
  · obtain ⟨u, hwu, hua, hev⟩ := hb.2.2.1 χ hc
    exact ⟨u, hwu, lt_trans hua hb.2.1, hev⟩
  · obtain ⟨u, hau, hut, hev⟩ := hb.2.2.2 χ hc
    exact ⟨u, lt_trans hb.1 hau, hut, hev⟩

/-! ### Task 337 Phase 1 — per-owner per-zone base-type `Nodup` (region `hnd` packaging)

**Packaging decision (SECONDARY question resolved, grounded in code):** `k1v_sorted_realizationK`'s
`hnd` is on the TYPE list `List (NormalForm sig 0 1)` of each region. Two DISTINCT base slots of
DIFFERENT owners can carry the SAME base type `χ` in the same zone, so the FLAT joint left/right
type list is NOT `Nodup` (even though the SLOT list is — `kvE2_sepSlotsLOf_nodup`), and simply
`dedup`-ing the flat list is WRONG: the eventual bracket needs ONE strictly-ordered point PER SLOT,
so collapsing shared types would under-count the points. The correct packaging — mirroring the
single-owner sound path (`SubBracket2V.lean:1982`, `k1v_bracket_construct3` fed `hndXU`/`hndUW`/
`hndWT` per single owner) — is PER-OWNER, PER-ZONE regions: each region's type list is a SINGLE
owner's SINGLE-zone set `kvE2_sepS σ zs`, which is a `filter` of the `Nodup` `Finset.univ.toList`
and hence `Nodup`. This banks that `hnd` foundation. The remaining engine-inputs delta is the
CROSS-OWNER TILING of these per-owner regions (see the Phase-1 continuation note). The per-region
`hnd` foundation `(kvE2_sepS σ zs).Nodup` is ALREADY BANKED as `kvE2_sepS_nodup` (:372) — a `filter`
of the `Nodup` universe list — so it is CONSUMED, not re-derived. -/

/-! ### Task 337 Phase 1 — the joint engine inputs (cross-owner value→gap partition)

The remaining Phase-1 deliverable: boundary-linked region lists `kvE2_sepHonestRegionsL/R`
feeding `k1v_sorted_realizationK` (SubBracket2V.lean:633-646), with the five preconditions
`hpos`/`hlink`/`hnd`/`hreal`/`hbdry` bundled as `kvE2_sepHonest_engineInputs`.

**Design (cycle-8 resolution, consumed not re-derived):**
- **Boundaries** are the value-sorted LEFT anchors `a_1 < … < a_k` (the `kvE2_sepAnchorVal`s of
  the LEFT-interior owners), so `regionsL = [(x,a_1,S_0), (a_1,a_2,S_1), …, (a_k,w,S_k)]`;
  `interleaveK` will emit `a_1..a_k` as internal boundaries and `w` as the final un-emitted
  `hi`, matching the bracket layout `lL ++ ptW :: lR`. Mirror on the right in `(w,t)`.
  Strict sortedness is anchor injectivity (`kvE2_sepAnchor_injOn`) + `mergeSort`.
- **Cross-owner value→gap partition**: each base slot contributes a `(value, type)` pair
  (`kvE2_sepSlotValue`), and a gap `(lo,hi)` carries exactly the types having SOME pair with
  value strictly interior to the gap (`kvE2_sepGapTypes`) — placement by VALUE, not statically
  by owner (a `zUW` type of owner σ is realized in `(a_σ,w)`, spanning several gaps).
- **Collision folding carried structurally**: a base value CAN equal a foreign anchor
  (base values are `Classical.epsilon` choices; resolution (a) is false in general). The gap
  filter is STRICT, so a colliding pair is simply absent from both adjacent gaps — it never
  poisons `hreal` — and `kvE2_sepGapTypes_mem_of` records exactly when a type IS present.
  Realizing the folded types AT their anchor (the meet-type fold flagged in the 5D docstring)
  is Phase 3's point-type step, not a gap `hreal` obligation.
- **`hnd` without flat-dedup of slots**: each gap's TYPE list is a `filter` of the `dedup`ed
  type pool, hence `Nodup`; the per-SLOT multiplicity (one bracket point per slot,
  `kvE2_sepDisjunct_extract`) is untouched — slots and their values remain available to the
  Phase-2/3 alignment through the pair pools `kvE2_sepHonestBasePairsL/R`.
- **`hreal` is value-witnessed**: for a type in a gap the witnessing pair's own value is the
  strict-interior realizer — interiority from the gap filter itself, realization from the
  slot-value spec lemmas (`kvE2_sepSlotValue_*_spec`, owner-relative resolution (b) strictness;
  no non-collision assumption anywhere).
- **F4/LITMUS**: all bounds below are between extracted witness VALUES and the bracket range
  `x`/`w`/`t` — no `x1 < e_i` relative-position literal, no owner-to-owner chain. -/

/-- The types a gap `(lo, hi)` carries: those base 1-types having SOME `(value, type)` pair with
    value STRICTLY interior to the gap. A `filter` of the `dedup`ed type pool, hence `Nodup` —
    the engine's per-region `hnd` — while the pair pool itself keeps full per-slot multiplicity
    for the later alignment. Pairs whose value collides with a gap boundary (an anchor) are
    excluded by strictness: the fold structure. -/
noncomputable def kvE2_sepGapTypes {sig : MonadicSignature} {M : OrderedMonadicStructure sig}
    (pairs : List (M.carrier × NormalForm sig 0 1)) (lo hi : M.carrier) :
    List (NormalForm sig 0 1) :=
  (pairs.map Prod.snd).dedup.filter
    (fun χ => pairs.any (fun p => decide (p.2 = χ) && decide (lo < p.1) && decide (p.1 < hi)))

/-- Gap type lists are duplicate-free (engine `hnd`): a `filter` of a `dedup`. -/
theorem kvE2_sepGapTypes_nodup {sig : MonadicSignature} {M : OrderedMonadicStructure sig}
    (pairs : List (M.carrier × NormalForm sig 0 1)) (lo hi : M.carrier) :
    (kvE2_sepGapTypes pairs lo hi).Nodup :=
  List.Nodup.filter _ (List.nodup_dedup _)

/-- Membership extraction for a gap type: some pair carries it with strictly interior value
    (the engine `hreal` witness source). -/
theorem kvE2_sepGapTypes_mem {sig : MonadicSignature} {M : OrderedMonadicStructure sig}
    {pairs : List (M.carrier × NormalForm sig 0 1)} {lo hi : M.carrier}
    {χ : NormalForm sig 0 1} (hχ : χ ∈ kvE2_sepGapTypes pairs lo hi) :
    ∃ p ∈ pairs, p.2 = χ ∧ lo < p.1 ∧ p.1 < hi := by
  obtain ⟨-, hany⟩ := List.mem_filter.mp hχ
  obtain ⟨p, hp, hcond⟩ := List.any_eq_true.mp hany
  simp only [Bool.and_eq_true, decide_eq_true_eq] at hcond
  exact ⟨p, hp, hcond.1.1, hcond.1.2, hcond.2⟩

/-- Membership introduction for a gap type (the fold-structure carrier: a pair with strictly
    interior value puts its type in the gap; a boundary-colliding pair does not qualify). -/
theorem kvE2_sepGapTypes_mem_of {sig : MonadicSignature} {M : OrderedMonadicStructure sig}
    {pairs : List (M.carrier × NormalForm sig 0 1)} {lo hi : M.carrier}
    {p : M.carrier × NormalForm sig 0 1} (hp : p ∈ pairs)
    (hlo : lo < p.1) (hhi : p.1 < hi) : p.2 ∈ kvE2_sepGapTypes pairs lo hi := by
  refine List.mem_filter.mpr ⟨List.mem_dedup.mpr (List.mem_map.mpr ⟨p, hp, rfl⟩), ?_⟩
  exact List.any_eq_true.mpr ⟨p, hp, by simp [hlo, hhi]⟩

/-- Gap region skeleton over interior boundaries: `lo -| mid_1 | mid_2 | … |- hi`, each gap
    carrying its `kvE2_sepGapTypes`. Recursive on the boundary list so `hlink`/`hpos`/`hbdry`
    fall to structural induction. -/
noncomputable def kvE2_sepGapRegions {sig : MonadicSignature} {M : OrderedMonadicStructure sig}
    (pairs : List (M.carrier × NormalForm sig 0 1)) :
    M.carrier → List M.carrier → M.carrier →
      List (M.carrier × M.carrier × List (NormalForm sig 0 1))
  | lo, [], hi => [(lo, hi, kvE2_sepGapTypes pairs lo hi)]
  | lo, a :: as, hi => (lo, a, kvE2_sepGapTypes pairs lo a) :: kvE2_sepGapRegions pairs a as hi

/-- The gap region list is never empty (there is always the `(lo, hi)` gap). -/
theorem kvE2_sepGapRegions_ne_nil {sig : MonadicSignature} {M : OrderedMonadicStructure sig}
    (pairs : List (M.carrier × NormalForm sig 0 1)) (lo : M.carrier) (mid : List M.carrier)
    (hi : M.carrier) : kvE2_sepGapRegions pairs lo mid hi ≠ [] := by
  cases mid <;> simp [kvE2_sepGapRegions]

/-- The first gap region starts at `lo` (left half of the engine's `hbdry`). -/
theorem kvE2_sepGapRegions_head?_fst {sig : MonadicSignature} {M : OrderedMonadicStructure sig}
    (pairs : List (M.carrier × NormalForm sig 0 1)) (lo : M.carrier) (mid : List M.carrier)
    (hi : M.carrier) : ∀ y ∈ (kvE2_sepGapRegions pairs lo mid hi).head?, y.1 = lo := by
  cases mid with
  | nil =>
    intro y hy
    simp only [kvE2_sepGapRegions, List.head?_cons, Option.mem_def, Option.some.injEq] at hy
    subst hy; rfl
  | cons a as =>
    intro y hy
    simp only [kvE2_sepGapRegions, List.head?_cons, Option.mem_def, Option.some.injEq] at hy
    subst hy; rfl

/-- The last gap region ends at `hi` (right half of the engine's `hbdry`). -/
theorem kvE2_sepGapRegions_getLast?_snd {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} (pairs : List (M.carrier × NormalForm sig 0 1))
    (mid : List M.carrier) : ∀ (lo hi : M.carrier),
      ∀ y ∈ (kvE2_sepGapRegions pairs lo mid hi).getLast?, y.2.1 = hi := by
  induction mid with
  | nil =>
    intro lo hi y hy
    simp only [kvE2_sepGapRegions, List.getLast?_singleton, Option.mem_def,
      Option.some.injEq] at hy
    subst hy; rfl
  | cons a as ih =>
    intro lo hi y hy
    simp only [kvE2_sepGapRegions] at hy
    cases hrec : kvE2_sepGapRegions pairs a as hi with
    | nil => exact absurd hrec (kvE2_sepGapRegions_ne_nil pairs a as hi)
    | cons b bs =>
      rw [hrec, List.getLast?_cons_cons] at hy
      exact ih a hi y (by rw [hrec]; exact hy)

/-- Consecutive gap regions share their boundary anchor (the engine's `hlink`). -/
theorem kvE2_sepGapRegions_chain' {sig : MonadicSignature} {M : OrderedMonadicStructure sig}
    (pairs : List (M.carrier × NormalForm sig 0 1)) (mid : List M.carrier) :
    ∀ (lo hi : M.carrier),
      List.Chain' (fun a b => a.2.1 = b.1) (kvE2_sepGapRegions pairs lo mid hi) := by
  induction mid with
  | nil =>
    intro lo hi
    simp only [kvE2_sepGapRegions]
    exact List.chain'_singleton _
  | cons a as ih =>
    intro lo hi
    simp only [kvE2_sepGapRegions]
    refine List.chain'_cons'.mpr ⟨?_, ih a hi⟩
    intro y hy
    exact (kvE2_sepGapRegions_head?_fst pairs a as hi y hy).symm

/-- Under a strict boundary chain `lo < mid_1 < … < hi`, every gap is nonempty
    (the engine's `hpos`). -/
theorem kvE2_sepGapRegions_pos {sig : MonadicSignature} {M : OrderedMonadicStructure sig}
    (pairs : List (M.carrier × NormalForm sig 0 1)) (mid : List M.carrier) :
    ∀ (lo hi : M.carrier), List.Chain (· < ·) lo (mid ++ [hi]) →
      ∀ r ∈ kvE2_sepGapRegions pairs lo mid hi, r.1 < r.2.1 := by
  induction mid with
  | nil =>
    intro lo hi hch r hr
    simp only [List.nil_append] at hch
    simp only [kvE2_sepGapRegions, List.mem_singleton] at hr
    subst hr
    exact (List.chain_cons.mp hch).1
  | cons a as ih =>
    intro lo hi hch r hr
    simp only [List.cons_append] at hch
    have h1 := List.chain_cons.mp hch
    simp only [kvE2_sepGapRegions, List.mem_cons] at hr
    rcases hr with rfl | hr
    · exact h1.1
    · exact ih a hi h1.2 r hr

/-- Every gap region's type list is the `kvE2_sepGapTypes` of its own endpoints
    (feeds `hnd`/`hreal` instantiation). -/
theorem kvE2_sepGapRegions_types {sig : MonadicSignature} {M : OrderedMonadicStructure sig}
    (pairs : List (M.carrier × NormalForm sig 0 1)) (mid : List M.carrier) :
    ∀ (lo hi : M.carrier), ∀ r ∈ kvE2_sepGapRegions pairs lo mid hi,
      r.2.2 = kvE2_sepGapTypes pairs r.1 r.2.1 := by
  induction mid with
  | nil =>
    intro lo hi r hr
    simp only [kvE2_sepGapRegions, List.mem_singleton] at hr
    subst hr; rfl
  | cons a as ih =>
    intro lo hi r hr
    simp only [kvE2_sepGapRegions, List.mem_cons] at hr
    rcases hr with rfl | hr
    · rfl
    · exact ih a hi r hr

/-- Strictly-between boundary points chain strictly from `lo` to `hi`. -/
private theorem kvE2_sepChain_lt_between {α : Type*} [Preorder α] (mid : List α) :
    ∀ lo hi : α, mid.Pairwise (· < ·) → (∀ a ∈ mid, lo < a ∧ a < hi) → lo < hi →
      List.Chain (· < ·) lo (mid ++ [hi]) := by
  induction mid with
  | nil =>
    intro lo hi _ _ hlh
    exact List.Chain.cons hlh List.Chain.nil
  | cons a as ih =>
    intro lo hi hpw hmem hlh
    have hc := List.pairwise_cons.mp hpw
    simp only [List.cons_append]
    refine List.Chain.cons (hmem a List.mem_cons_self).1 ?_
    exact ih a hi hc.2 (fun b hb => ⟨hc.1 b hb, (hmem b (List.mem_cons_of_mem _ hb)).2⟩)
      (hmem a List.mem_cons_self).2

/-- LEFT `(value, type)` pair pool: every base slot of the joint LEFT side — a LEFT-interior
    owner's below-anchor (`lXU`) and above-anchor (`lUW`) types AND a RIGHT-interior owner's
    left-region (`rXW`) types — paired with its engine-bound `kvE2_sepSlotValue`. Placement into
    gaps is by VALUE (cross-owner), never statically by owner. -/
noncomputable def kvE2_sepHonestBasePairsL {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    List (M.carrier × NormalForm sig 0 1) :=
  (kvE2_sepPosIn qnf kvE2_sep_zXW3).flatMap (fun σ =>
      (kvE2_sepS σ kvE_sub2_zXU).map
        (fun χ => (kvE2_sepSlotValue qnf M w x t h (.lXU σ χ), χ))
        ++ (kvE2_sepS σ kvE_sub2_zUW).map
        (fun χ => (kvE2_sepSlotValue qnf M w x t h (.lUW σ χ), χ)))
    ++ (kvE2_sepPosIn qnf kvE2_sep_zWT3).flatMap (fun σ =>
      (kvE2_sepS σ kvE_sub2_zXU).map
        (fun χ => (kvE2_sepSlotValue qnf M w x t h (.rXW σ χ), χ)))

/-- RIGHT `(value, type)` pair pool (mirror): a RIGHT-interior owner's below-anchor (`rWX1`)
    and above-anchor (`rX1T`) types AND a LEFT-interior owner's right-region (`lWT`) types. -/
noncomputable def kvE2_sepHonestBasePairsR {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    List (M.carrier × NormalForm sig 0 1) :=
  (kvE2_sepPosIn qnf kvE2_sep_zXW3).flatMap (fun σ =>
      (kvE2_sepS σ kvE_sub2_zWT).map
        (fun χ => (kvE2_sepSlotValue qnf M w x t h (.lWT σ χ), χ)))
    ++ (kvE2_sepPosIn qnf kvE2_sep_zWT3).flatMap (fun σ =>
      (kvE2_sepS σ kvE2_sep_zWX1).map
        (fun χ => (kvE2_sepSlotValue qnf M w x t h (.rWX1 σ χ), χ))
        ++ (kvE2_sepS σ kvE_sub2_zWT).map
        (fun χ => (kvE2_sepSlotValue qnf M w x t h (.rX1T σ χ), χ)))

/-- Every LEFT pair's value realizes its type (the `hreal` evaluation core; interiority is the
    gap filter's own strictness). From the six per-slot value specs — owner-relative
    resolution (b), no non-collision assumption. -/
theorem kvE2_sepHonestBasePairsL_eval {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    ∀ p ∈ kvE2_sepHonestBasePairsL qnf M w x t h,
      nf_eval_nf M 0 1 (fun _ => p.1) p.2 := by
  intro p hp
  rw [kvE2_sepHonestBasePairsL] at hp
  rcases List.mem_append.mp hp with hp | hp
  · obtain ⟨σ, hσ, hpσ⟩ := List.mem_flatMap.mp hp
    have hσpos : σ ∈ kvE2_sepPos qnf := (List.mem_filter.mp hσ).1
    have hzone : nf0_zoneSpec σ.1 = kvE2_sep_zXW3 :=
      of_decide_eq_true (List.mem_filter.mp hσ).2
    rcases List.mem_append.mp hpσ with hpm | hpm
    · obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp hpm
      exact (kvE2_sepSlotValue_lXU_spec qnf M w x t hxw hwt h σ hσpos hzone χ hχ).2.2
    · obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp hpm
      exact (kvE2_sepSlotValue_lUW_spec qnf M w x t hxw hwt h σ hσpos hzone χ hχ).2.2
  · obtain ⟨σ, hσ, hpσ⟩ := List.mem_flatMap.mp hp
    have hσpos : σ ∈ kvE2_sepPos qnf := (List.mem_filter.mp hσ).1
    obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp hpσ
    exact (kvE2_sepSlotValue_rXW_spec qnf M w x t h σ hσpos χ hχ).2.2

/-- Every RIGHT pair's value realizes its type (mirror of `kvE2_sepHonestBasePairsL_eval`). -/
theorem kvE2_sepHonestBasePairsR_eval {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    ∀ p ∈ kvE2_sepHonestBasePairsR qnf M w x t h,
      nf_eval_nf M 0 1 (fun _ => p.1) p.2 := by
  intro p hp
  rw [kvE2_sepHonestBasePairsR] at hp
  rcases List.mem_append.mp hp with hp | hp
  · obtain ⟨σ, hσ, hpσ⟩ := List.mem_flatMap.mp hp
    have hσpos : σ ∈ kvE2_sepPos qnf := (List.mem_filter.mp hσ).1
    obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp hpσ
    exact (kvE2_sepSlotValue_lWT_spec qnf M w x t h σ hσpos χ hχ).2.2
  · obtain ⟨σ, hσ, hpσ⟩ := List.mem_flatMap.mp hp
    have hσpos : σ ∈ kvE2_sepPos qnf := (List.mem_filter.mp hσ).1
    have hzone : nf0_zoneSpec σ.1 = kvE2_sep_zWT3 :=
      of_decide_eq_true (List.mem_filter.mp hσ).2
    rcases List.mem_append.mp hpσ with hpm | hpm
    · obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp hpm
      exact (kvE2_sepSlotValue_rWX1_spec qnf M w x t hxw hwt h σ hσpos hzone χ hχ).2.2
    · obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp hpm
      exact (kvE2_sepSlotValue_rX1T_spec qnf M w x t hxw hwt h σ hσpos hzone χ hχ).2.2

/-- Value-sorted LEFT anchor boundary list: the LEFT-interior owners' canonical anchors in
    `≤`-`mergeSort` order (strictified below by anchor injectivity). -/
noncomputable def kvE2_sepHonestAnchorsL {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) : List M.carrier :=
  ((kvE2_sepPosIn qnf kvE2_sep_zXW3).map
    (fun σ => kvE2_sepAnchorVal qnf M w x t h σ)).mergeSort (fun a b => decide (a ≤ b))

/-- Value-sorted RIGHT anchor boundary list (mirror). -/
noncomputable def kvE2_sepHonestAnchorsR {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) : List M.carrier :=
  ((kvE2_sepPosIn qnf kvE2_sep_zWT3).map
    (fun σ => kvE2_sepAnchorVal qnf M w x t h σ)).mergeSort (fun a b => decide (a ≤ b))

/-- Every LEFT boundary anchor is strictly inside `(x, w)` (honest bundle L bounds). -/
theorem kvE2_sepHonestAnchorsL_bounds {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    ∀ a ∈ kvE2_sepHonestAnchorsL qnf M w x t h, x < a ∧ a < w := by
  intro a ha
  rw [kvE2_sepHonestAnchorsL] at ha
  obtain ⟨σ, hσ, rfl⟩ := List.mem_map.mp ((List.mergeSort_perm _ _).mem_iff.mp ha)
  have hσpos : σ ∈ kvE2_sepPos qnf := (List.mem_filter.mp hσ).1
  have hzone : nf0_zoneSpec σ.1 = kvE2_sep_zXW3 :=
    of_decide_eq_true (List.mem_filter.mp hσ).2
  have hb := kvE2_sepHonestAnchorBundleL qnf M w x t hxw hwt h σ hσpos hzone
  exact ⟨hb.1, hb.2.1⟩

/-- Every RIGHT boundary anchor is strictly inside `(w, t)` (honest bundle R bounds). -/
theorem kvE2_sepHonestAnchorsR_bounds {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    ∀ a ∈ kvE2_sepHonestAnchorsR qnf M w x t h, w < a ∧ a < t := by
  intro a ha
  rw [kvE2_sepHonestAnchorsR] at ha
  obtain ⟨σ, hσ, rfl⟩ := List.mem_map.mp ((List.mergeSort_perm _ _).mem_iff.mp ha)
  have hσpos : σ ∈ kvE2_sepPos qnf := (List.mem_filter.mp hσ).1
  have hzone : nf0_zoneSpec σ.1 = kvE2_sep_zWT3 :=
    of_decide_eq_true (List.mem_filter.mp hσ).2
  have hb := kvE2_sepHonestAnchorBundleR qnf M w x t hxw hwt h σ hσpos hzone
  exact ⟨hb.1, hb.2.1⟩

/-- The sorted anchor list is `≤`-sorted and duplicate-free, hence STRICTLY sorted: the
    `hpos`/`hlink` strictness seed. Nodup is the keystone `kvE2_sepAnchor_injOn` on the
    `Nodup` positive spine. Stated generically over the zone filter to serve both sides. -/
private theorem kvE2_sepHonestAnchors_pairwise_aux {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) (zs : ZoneSpec 3) :
    (((kvE2_sepPosIn qnf zs).map
      (fun σ => kvE2_sepAnchorVal qnf M w x t h σ)).mergeSort
        (fun a b => decide (a ≤ b))).Pairwise (· < ·) := by
  have hle : (((kvE2_sepPosIn qnf zs).map
      (fun σ => kvE2_sepAnchorVal qnf M w x t h σ)).mergeSort
        (fun a b => decide (a ≤ b))).Pairwise (fun a b => decide (a ≤ b) = true) :=
    List.pairwise_mergeSort
      (fun a b c hab hbc => by
        simp only [decide_eq_true_eq] at hab hbc ⊢
        exact le_trans hab hbc)
      (fun a b => by
        simp only [Bool.or_eq_true, decide_eq_true_eq]
        exact le_total a b) _
  have hnd : (((kvE2_sepPosIn qnf zs).map
      (fun σ => kvE2_sepAnchorVal qnf M w x t h σ)).mergeSort
        (fun a b => decide (a ≤ b))).Nodup := by
    refine (List.mergeSort_perm _ _).nodup_iff.mpr ?_
    refine List.Nodup.map_on ?_ (List.Nodup.filter _ (kvE2_sepPos_nodup qnf))
    intro σ hσ τ hτ heq
    exact kvE2_sepAnchor_injOn qnf M w x t h
      (List.mem_filter.mp hσ).1 (List.mem_filter.mp hτ).1 heq
  have hle' := hle.imp (fun hab => of_decide_eq_true hab)
  exact (hle'.and hnd).imp (fun hc => lt_of_le_of_ne hc.1 hc.2)

/-- The LEFT boundary chain is strict: `x < a_1 < … < a_k < w`. -/
theorem kvE2_sepHonestAnchorsL_chain {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    List.Chain (· < ·) x (kvE2_sepHonestAnchorsL qnf M w x t h ++ [w]) :=
  kvE2_sepChain_lt_between _ x w
    (kvE2_sepHonestAnchors_pairwise_aux qnf M w x t h kvE2_sep_zXW3)
    (kvE2_sepHonestAnchorsL_bounds qnf M w x t hxw hwt h) hxw

/-- The RIGHT boundary chain is strict: `w < a_1 < … < a_k < t`. -/
theorem kvE2_sepHonestAnchorsR_chain {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    List.Chain (· < ·) w (kvE2_sepHonestAnchorsR qnf M w x t h ++ [t]) :=
  kvE2_sepChain_lt_between _ w t
    (kvE2_sepHonestAnchors_pairwise_aux qnf M w x t h kvE2_sep_zWT3)
    (kvE2_sepHonestAnchorsR_bounds qnf M w x t hxw hwt h) hwt

/-- **The joint LEFT engine region list**: gaps between `x`, the value-sorted LEFT anchors, and
    `w`, each carrying the base types whose slot value is strictly interior to it. -/
noncomputable def kvE2_sepHonestRegionsL {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    List (M.carrier × M.carrier × List (NormalForm sig 0 1)) :=
  kvE2_sepGapRegions (kvE2_sepHonestBasePairsL qnf M w x t h) x
    (kvE2_sepHonestAnchorsL qnf M w x t h) w

/-- **The joint RIGHT engine region list** (mirror in `(w, t)`). -/
noncomputable def kvE2_sepHonestRegionsR {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    List (M.carrier × M.carrier × List (NormalForm sig 0 1)) :=
  kvE2_sepGapRegions (kvE2_sepHonestBasePairsR qnf M w x t h) w
    (kvE2_sepHonestAnchorsR qnf M w x t h) t

/-- **The Phase-1 engine-input bundle** (task 337): the joint LEFT/RIGHT gap region lists
    satisfy ALL five `k1v_sorted_realizationK` preconditions —
    `hpos` (strict anchor chain), `hlink` (shared boundaries), `hnd` (filter-of-dedup type
    lists), `hreal` (each gap type's own slot value is a strict-interior realizer) — plus the
    endpoint boundary alignment `hbdry` (`regionsL` runs `x … w`, `regionsR` runs `w … t`, so
    the merged chain is `x < … < w < … < t` with `w` the single shared pivot).

    Folded (anchor-colliding) base values are structurally absent from every gap list — their
    realization AT the anchors is Phase 3's meet-type point step. Alignment of the gap content
    with `kvE2_sepSlotsLOf/ROf` (halign) is Phase 2/3, consuming the banked
    `kvE2_sepSlotGIdx_honestOrder` trio — not part of this bundle. -/
theorem kvE2_sepHonest_engineInputs {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    (∀ r ∈ kvE2_sepHonestRegionsL qnf M w x t h, r.1 < r.2.1) ∧
    List.Chain' (fun a b => a.2.1 = b.1) (kvE2_sepHonestRegionsL qnf M w x t h) ∧
    (∀ r ∈ kvE2_sepHonestRegionsL qnf M w x t h, r.2.2.Nodup) ∧
    (∀ r ∈ kvE2_sepHonestRegionsL qnf M w x t h, ∀ χ ∈ r.2.2,
      ∃ u, r.1 < u ∧ u < r.2.1 ∧ nf_eval_nf M 0 1 (fun _ => u) χ) ∧
    (∀ r ∈ kvE2_sepHonestRegionsR qnf M w x t h, r.1 < r.2.1) ∧
    List.Chain' (fun a b => a.2.1 = b.1) (kvE2_sepHonestRegionsR qnf M w x t h) ∧
    (∀ r ∈ kvE2_sepHonestRegionsR qnf M w x t h, r.2.2.Nodup) ∧
    (∀ r ∈ kvE2_sepHonestRegionsR qnf M w x t h, ∀ χ ∈ r.2.2,
      ∃ u, r.1 < u ∧ u < r.2.1 ∧ nf_eval_nf M 0 1 (fun _ => u) χ) ∧
    kvE2_sepHonestRegionsL qnf M w x t h ≠ [] ∧
    kvE2_sepHonestRegionsR qnf M w x t h ≠ [] ∧
    (∀ y ∈ (kvE2_sepHonestRegionsL qnf M w x t h).head?, y.1 = x) ∧
    (∀ y ∈ (kvE2_sepHonestRegionsL qnf M w x t h).getLast?, y.2.1 = w) ∧
    (∀ y ∈ (kvE2_sepHonestRegionsR qnf M w x t h).head?, y.1 = w) ∧
    (∀ y ∈ (kvE2_sepHonestRegionsR qnf M w x t h).getLast?, y.2.1 = t) := by
  have hrealL : ∀ r ∈ kvE2_sepHonestRegionsL qnf M w x t h, ∀ χ ∈ r.2.2,
      ∃ u, r.1 < u ∧ u < r.2.1 ∧ nf_eval_nf M 0 1 (fun _ => u) χ := by
    intro r hr χ hχ
    rw [kvE2_sepGapRegions_types _ _ _ _ r hr] at hχ
    obtain ⟨p, hp, rfl, hlo, hhi⟩ := kvE2_sepGapTypes_mem hχ
    exact ⟨p.1, hlo, hhi, kvE2_sepHonestBasePairsL_eval qnf M w x t hxw hwt h p hp⟩
  have hrealR : ∀ r ∈ kvE2_sepHonestRegionsR qnf M w x t h, ∀ χ ∈ r.2.2,
      ∃ u, r.1 < u ∧ u < r.2.1 ∧ nf_eval_nf M 0 1 (fun _ => u) χ := by
    intro r hr χ hχ
    rw [kvE2_sepGapRegions_types _ _ _ _ r hr] at hχ
    obtain ⟨p, hp, rfl, hlo, hhi⟩ := kvE2_sepGapTypes_mem hχ
    exact ⟨p.1, hlo, hhi, kvE2_sepHonestBasePairsR_eval qnf M w x t hxw hwt h p hp⟩
  have hndL : ∀ r ∈ kvE2_sepHonestRegionsL qnf M w x t h, r.2.2.Nodup := by
    intro r hr
    rw [kvE2_sepGapRegions_types _ _ _ _ r hr]
    exact kvE2_sepGapTypes_nodup _ _ _
  have hndR : ∀ r ∈ kvE2_sepHonestRegionsR qnf M w x t h, r.2.2.Nodup := by
    intro r hr
    rw [kvE2_sepGapRegions_types _ _ _ _ r hr]
    exact kvE2_sepGapTypes_nodup _ _ _
  exact ⟨kvE2_sepGapRegions_pos _ _ x w
      (kvE2_sepHonestAnchorsL_chain qnf M w x t hxw hwt h),
    kvE2_sepGapRegions_chain' _ _ x w, hndL, hrealL,
    kvE2_sepGapRegions_pos _ _ w t
      (kvE2_sepHonestAnchorsR_chain qnf M w x t hxw hwt h),
    kvE2_sepGapRegions_chain' _ _ w t, hndR, hrealR,
    kvE2_sepGapRegions_ne_nil _ _ _ _, kvE2_sepGapRegions_ne_nil _ _ _ _,
    kvE2_sepGapRegions_head?_fst _ _ _ _, kvE2_sepGapRegions_getLast?_snd _ _ _ _,
    kvE2_sepGapRegions_head?_fst _ _ _ _, kvE2_sepGapRegions_getLast?_snd _ _ _ _⟩

/-! ### Task 337 Phase 2 — global monotone bracket witness (engine invocation + stitch)

`kvE2_sepHonest_witnesses` invokes `k1v_sorted_realizationK` (SubBracket2V.lean:633) once per
side on the Phase-1 region lists and stitches the two `interleaveK` chains around the single
shared pivot `w` into the globally strictly monotone bracket witness chain, with per-side
range bounds `x < · < w` (LEFT) and `w < · < t` (RIGHT). The full engine `Forall₂` data is
exposed so Phase 3 can thread the per-region realizers into the per-slot point-type step.
All bounds are between engine points and the bracket range `x`/`w`/`t` — no `x1 < e_i`
relative-position literal, no owner-to-owner chain (F4/LITMUS NavigatedSpine:437). Per-slot
re-indexing into `kvE2_sepSlotsLOf wo ++ ptW :: kvE2_sepSlotsROf wo` (the halign step over
the banked `kvE2_sepSlotGIdx_honestOrder` trio + value-sortedness, including the duplicate
per-gap type and folded-anchor cases) is Phase 3's alignment work, consuming this chain. -/

/-- Under a strict boundary chain every gap region's `lo` is at least the global `lo`
    (feeds the stitcher's `hlo` for the engine's point lists). -/
theorem kvE2_sepGapRegions_lo_le {sig : MonadicSignature} {M : OrderedMonadicStructure sig}
    (pairs : List (M.carrier × NormalForm sig 0 1)) (mid : List M.carrier) :
    ∀ (lo hi : M.carrier), List.Chain (· < ·) lo (mid ++ [hi]) →
      ∀ r ∈ kvE2_sepGapRegions pairs lo mid hi, lo ≤ r.1 := by
  induction mid with
  | nil =>
    intro lo hi _ r hr
    simp only [kvE2_sepGapRegions, List.mem_singleton] at hr
    subst hr; exact le_refl _
  | cons a as ih =>
    intro lo hi hch r hr
    simp only [List.cons_append] at hch
    have h1 := List.chain_cons.mp hch
    simp only [kvE2_sepGapRegions, List.mem_cons] at hr
    rcases hr with rfl | hr
    · exact le_refl _
    · exact le_of_lt (lt_of_lt_of_le h1.1 (ih a hi h1.2 r hr))

/-- Under a strict boundary chain every gap region's `hi` is at most the global `hi`
    (feeds the interleave upper bound for the engine's point lists). -/
theorem kvE2_sepGapRegions_hi_le {sig : MonadicSignature} {M : OrderedMonadicStructure sig}
    (pairs : List (M.carrier × NormalForm sig 0 1)) (mid : List M.carrier) :
    ∀ (lo hi : M.carrier), List.Chain (· < ·) lo (mid ++ [hi]) →
      ∀ r ∈ kvE2_sepGapRegions pairs lo mid hi, r.2.1 ≤ hi := by
  induction mid with
  | nil =>
    intro lo hi _ r hr
    simp only [kvE2_sepGapRegions, List.mem_singleton] at hr
    subst hr; exact le_refl _
  | cons a as ih =>
    intro lo hi hch r hr
    simp only [List.cons_append] at hch
    have h1 := List.chain_cons.mp hch
    simp only [kvE2_sepGapRegions, List.mem_cons] at hr
    rcases hr with rfl | hr
    · have hpw := List.chain_iff_pairwise.mp h1.2
      exact le_of_lt (List.rel_of_pairwise_cons hpw
        (List.mem_append_right _ (List.mem_singleton_self hi)))
    · exact ih a hi h1.2 r hr

/-- **Interleave upper bound** (dual of the stitcher's global lower bound
    `k1v_stitch_regions` `.2`): if every block point sits strictly below its region's `hi`,
    the regions are non-degenerate and boundary-linked, and every region `hi` is at most a
    global `hi`, then the whole interleaved chain sits strictly below the global `hi`. -/
theorem kvE2_sepInterleaveK_lt {sig : MonadicSignature} {M : OrderedMonadicStructure sig}
    {β : Type _} :
    ∀ (regs : List (M.carrier × M.carrier × List (β × M.carrier))) (hi : M.carrier),
      (∀ e ∈ regs, ∀ q ∈ e.2.2, q.2 < e.2.1) →
      (∀ e ∈ regs, e.1 < e.2.1) →
      List.Chain' (fun a b => a.2.1 = b.1) regs →
      (∀ e ∈ regs, e.2.1 ≤ hi) →
      ∀ y ∈ interleaveK regs, y < hi := by
  intro regs
  induction regs with
  | nil => intro hi _ _ _ _ y hy; simp [interleaveK] at hy
  | cons e rest ih =>
    intro hi hblk hpos hlink hhi y hy
    obtain ⟨el, esep, eblk⟩ := e
    cases rest with
    | nil =>
      simp only [interleaveK, List.mem_map] at hy
      obtain ⟨q, hq, rfl⟩ := hy
      exact lt_of_lt_of_le (hblk _ List.mem_cons_self q hq) (hhi _ List.mem_cons_self)
    | cons e' rest' =>
      simp only [interleaveK, List.mem_append, List.mem_cons] at hy
      rcases hy with hy | hy | hy
      · obtain ⟨q, hq, rfl⟩ := List.mem_map.mp hy
        exact lt_of_lt_of_le (hblk _ List.mem_cons_self q hq) (hhi _ List.mem_cons_self)
      · have hsep : esep = e'.1 := (List.chain'_cons.mp hlink).1
        rw [hy, hsep]
        exact lt_of_lt_of_le (hpos e' (List.mem_cons_of_mem _ List.mem_cons_self))
          (hhi e' (List.mem_cons_of_mem _ List.mem_cons_self))
      · exact ih hi (fun g hg => hblk g (List.mem_cons_of_mem _ hg))
          (fun g hg => hpos g (List.mem_cons_of_mem _ hg))
          (List.chain'_cons.mp hlink).2
          (fun g hg => hhi g (List.mem_cons_of_mem _ hg)) y hy

/-- `Forall₂` left-membership extraction (local helper): each left element is related to
    some member of the right list. -/
private theorem kvE2_sepForall₂_mem_left {α β : Type _} {R : α → β → Prop} :
    ∀ {l₁ : List α} {l₂ : List β}, List.Forall₂ R l₁ l₂ →
      ∀ a ∈ l₁, ∃ b ∈ l₂, R a b := by
  intro l₁ l₂ hf
  induction hf with
  | nil => intro a ha; simp at ha
  | cons hab _ ih =>
    intro a ha
    rcases List.mem_cons.mp ha with rfl | ha'
    · exact ⟨_, List.mem_cons_self, hab⟩
    · obtain ⟨b, hb, hR⟩ := ih a ha'
      exact ⟨b, List.mem_cons_of_mem _ hb, hR⟩

/-- `Forall₂` boundary-skeleton transfer (local helper): when related entries share both
    boundaries, the boundary-link `Chain'` transfers from the region list to the engine's
    point list. -/
private theorem kvE2_sepForall₂_chain' {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {β γ : Type _}
    {R : (M.carrier × M.carrier × β) → (M.carrier × M.carrier × γ) → Prop}
    (hR : ∀ p r, R p r → p.1 = r.1 ∧ p.2.1 = r.2.1) :
    ∀ {ps : List (M.carrier × M.carrier × β)} {rs : List (M.carrier × M.carrier × γ)},
      List.Forall₂ R ps rs →
      List.Chain' (fun a b => a.2.1 = b.1) rs →
      List.Chain' (fun a b => a.2.1 = b.1) ps := by
  intro ps rs hf
  induction hf with
  | nil => intro _; exact List.chain'_nil
  | @cons p r ps' rs' hpr hf' ih =>
    intro hch
    cases hf' with
    | nil => exact List.chain'_singleton _
    | @cons p' r' ps'' rs'' hpr' hf'' =>
      have hch' := List.chain'_cons.mp hch
      refine List.chain'_cons.mpr ⟨?_, ih hch'.2⟩
      rw [(hR p r hpr).2, hch'.1, ← (hR p' r' hpr').1]

/-- **Phase 2 — the global monotone bracket witness** (task 337): invoking the engine
    `k1v_sorted_realizationK` on the Phase-1 LEFT/RIGHT region lists yields per-side
    point-tagged region lists `psL`/`psR` — full engine `Forall₂` guarantees exposed for
    the Phase-3 point-type step — whose stitched chains sit strictly inside `(x, w)` resp.
    `(w, t)` and concatenate around the single shared pivot `w` into the globally strictly
    monotone bracket witness chain `interleaveK psL ++ w :: interleaveK psR`, every point
    strictly inside the bracket range `(x, t)`. Consumes the Phase-1 bundle
    `kvE2_sepHonest_engineInputs`; all bounds ride the bracket range `x`/`w`/`t`
    (F4/LITMUS: no `x1 < e_i` literal, no owner-to-owner chain). -/
theorem kvE2_sepHonest_witnesses {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    ∃ (psL psR : List (M.carrier × M.carrier × List (NormalForm sig 0 1 × M.carrier))),
      List.Forall₂ (fun p r => p.1 = r.1 ∧ p.2.1 = r.2.1 ∧
          List.Perm (p.2.2.map Prod.fst) r.2.2 ∧
          (p.2.2.map Prod.snd).Pairwise (· < ·) ∧
          (∀ q ∈ p.2.2, (r.1 < q.2 ∧ q.2 < r.2.1) ∧ nf_eval_nf M 0 1 (fun _ => q.2) q.1))
        psL (kvE2_sepHonestRegionsL qnf M w x t h) ∧
      List.Forall₂ (fun p r => p.1 = r.1 ∧ p.2.1 = r.2.1 ∧
          List.Perm (p.2.2.map Prod.fst) r.2.2 ∧
          (p.2.2.map Prod.snd).Pairwise (· < ·) ∧
          (∀ q ∈ p.2.2, (r.1 < q.2 ∧ q.2 < r.2.1) ∧ nf_eval_nf M 0 1 (fun _ => q.2) q.1))
        psR (kvE2_sepHonestRegionsR qnf M w x t h) ∧
      (∀ y ∈ interleaveK psL, x < y ∧ y < w) ∧
      (∀ y ∈ interleaveK psR, w < y ∧ y < t) ∧
      (interleaveK psL ++ w :: interleaveK psR).Pairwise (· < ·) := by
  obtain ⟨hposL, hlinkL, hndL, hrealL, hposR, hlinkR, hndR, hrealR,
    hneL, hneR, hheadL, hlastL, hheadR, hlastR⟩ :=
    kvE2_sepHonest_engineInputs qnf M w x t hxw hwt h
  obtain ⟨psL, hfL, hsortL⟩ := k1v_sorted_realizationK M _ hposL hlinkL hndL hrealL
  obtain ⟨psR, hfR, hsortR⟩ := k1v_sorted_realizationK M _ hposR hlinkR hndR hrealR
  -- Region-level global bounds from the strict anchor boundary chains.
  have hloL : ∀ r ∈ kvE2_sepHonestRegionsL qnf M w x t h, x ≤ r.1 :=
    kvE2_sepGapRegions_lo_le _ _ x w (kvE2_sepHonestAnchorsL_chain qnf M w x t hxw hwt h)
  have hhiL : ∀ r ∈ kvE2_sepHonestRegionsL qnf M w x t h, r.2.1 ≤ w :=
    kvE2_sepGapRegions_hi_le _ _ x w (kvE2_sepHonestAnchorsL_chain qnf M w x t hxw hwt h)
  have hloR : ∀ r ∈ kvE2_sepHonestRegionsR qnf M w x t h, w ≤ r.1 :=
    kvE2_sepGapRegions_lo_le _ _ w t (kvE2_sepHonestAnchorsR_chain qnf M w x t hxw hwt h)
  have hhiR : ∀ r ∈ kvE2_sepHonestRegionsR qnf M w x t h, r.2.1 ≤ t :=
    kvE2_sepGapRegions_hi_le _ _ w t (kvE2_sepHonestAnchorsR_chain qnf M w x t hxw hwt h)
  -- Transfer the region skeleton facts through the engine's `Forall₂` onto `psL`/`psR`.
  have hmemL := kvE2_sepForall₂_mem_left hfL
  have hmemR := kvE2_sepForall₂_mem_left hfR
  have hposPsL : ∀ p ∈ psL, p.1 < p.2.1 := by
    intro p hp; obtain ⟨r, hr, h1, h2, -, -, -⟩ := hmemL p hp
    rw [h1, h2]; exact hposL r hr
  have hposPsR : ∀ p ∈ psR, p.1 < p.2.1 := by
    intro p hp; obtain ⟨r, hr, h1, h2, -, -, -⟩ := hmemR p hp
    rw [h1, h2]; exact hposR r hr
  have hloPsL : ∀ p ∈ psL, x ≤ p.1 := by
    intro p hp; obtain ⟨r, hr, h1, -, -, -, -⟩ := hmemL p hp
    rw [h1]; exact hloL r hr
  have hloPsR : ∀ p ∈ psR, w ≤ p.1 := by
    intro p hp; obtain ⟨r, hr, h1, -, -, -, -⟩ := hmemR p hp
    rw [h1]; exact hloR r hr
  have hhiPsL : ∀ p ∈ psL, p.2.1 ≤ w := by
    intro p hp; obtain ⟨r, hr, -, h2, -, -, -⟩ := hmemL p hp
    rw [h2]; exact hhiL r hr
  have hhiPsR : ∀ p ∈ psR, p.2.1 ≤ t := by
    intro p hp; obtain ⟨r, hr, -, h2, -, -, -⟩ := hmemR p hp
    rw [h2]; exact hhiR r hr
  have hsortPsL : ∀ p ∈ psL, (p.2.2.map Prod.snd).Pairwise (· < ·) := by
    intro p hp; obtain ⟨r, hr, -, -, -, h4, -⟩ := hmemL p hp; exact h4
  have hsortPsR : ∀ p ∈ psR, (p.2.2.map Prod.snd).Pairwise (· < ·) := by
    intro p hp; obtain ⟨r, hr, -, -, -, h4, -⟩ := hmemR p hp; exact h4
  have hrangePsL : ∀ p ∈ psL, ∀ q ∈ p.2.2, p.1 < q.2 ∧ q.2 < p.2.1 := by
    intro p hp q hq; obtain ⟨r, hr, h1, h2, -, -, h5⟩ := hmemL p hp
    rw [h1, h2]; exact (h5 q hq).1
  have hrangePsR : ∀ p ∈ psR, ∀ q ∈ p.2.2, p.1 < q.2 ∧ q.2 < p.2.1 := by
    intro p hp q hq; obtain ⟨r, hr, h1, h2, -, -, h5⟩ := hmemR p hp
    rw [h1, h2]; exact (h5 q hq).1
  have hlinkPsL : List.Chain' (fun a b => a.2.1 = b.1) psL :=
    kvE2_sepForall₂_chain' (fun p r hpr => ⟨hpr.1, hpr.2.1⟩) hfL hlinkL
  have hlinkPsR : List.Chain' (fun a b => a.2.1 = b.1) psR :=
    kvE2_sepForall₂_chain' (fun p r hpr => ⟨hpr.1, hpr.2.1⟩) hfR hlinkR
  -- Per-side strict range bounds on the stitched chains.
  have hLlow : ∀ y ∈ interleaveK psL, x < y :=
    (k1v_stitch_regions psL x hsortPsL hrangePsL hposPsL hlinkPsL hloPsL).2
  have hRlow : ∀ y ∈ interleaveK psR, w < y :=
    (k1v_stitch_regions psR w hsortPsR hrangePsR hposPsR hlinkPsR hloPsR).2
  have hLhigh : ∀ y ∈ interleaveK psL, y < w :=
    kvE2_sepInterleaveK_lt psL w (fun p hp q hq => (hrangePsL p hp q hq).2)
      hposPsL hlinkPsL hhiPsL
  have hRhigh : ∀ y ∈ interleaveK psR, y < t :=
    kvE2_sepInterleaveK_lt psR t (fun p hp q hq => (hrangePsR p hp q hq).2)
      hposPsR hlinkPsR hhiPsR
  refine ⟨psL, psR, hfL, hfR,
    fun y hy => ⟨hLlow y hy, hLhigh y hy⟩,
    fun y hy => ⟨hRlow y hy, hRhigh y hy⟩, ?_⟩
  -- Stitch around the single shared pivot `w`.
  rw [List.pairwise_append]
  refine ⟨hsortL, List.pairwise_cons.mpr ⟨fun y hy => hRlow y hy, hsortR⟩, ?_⟩
  intro a ha b hb
  have haw : a < w := hLhigh a ha
  rcases List.mem_cons.mp hb with rfl | hb'
  · exact haw
  · exact haw.trans (hRlow b hb')

/-! ### Task 340 Phase 5D — completeness reduction to the single 337-owned `.holds`

The Phase-5 sorry-free deliverable terminates here (design gate report 06 Q4/Q5, phase sizing).
`kvE2_sepHonestOrder_mem_arr'` (5B) is the carrier member; the remaining obligation to make the
separated body hold is the realization of the honest disjunct's own bracket — the single
337-owned `.holds`, produced by `kvE_subBracket2V_sound_of_parts` (SubBracket2V.lean:1290) over
the engine-precondition regions bundle (consecutive distinct-anchor intervals: `hpos`/`hlink` from
the keystone-strict anchor family + `kvE2_ordRank_strictMono`, `hnd` per-zone base-type `Nodup`,
`hreal` from the honest bundles `kvE2_sepHonestBundleL/R`) fed to `k1v_sorted_realizationK`
(SubBracket2V.lean:633). That regions realization — including any meet-type folding for a foreign
base witness forced onto an anchor (report 06 R3) — is task 337's territory, NOT a carrier change.
Below is the complete, axiom-clean reduction taking that one `.holds` as the delegated step. -/

/-- **Phase 5D — the completeness hand-off to task 337.** Given the honest interior realization
    (`hLR`) and the realization of the honest disjunct's own bracket (`hdisj`, the single 337-owned
    `.holds`), the separated body holds at the fixed endpoints `x`, `t`. Wires the Phase-5B carrier
    member `kvE2_sepHonestOrder_mem_arr'` into `kvE2_sepBody_holds_iff.mpr`. Complete and
    axiom-clean UP TO the delegated `.holds` — the sanctioned Phase-5 completion boundary. -/
theorem kvE2_sepBody_complete_holds {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (hg : kvE2_sepGate qnf)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hLR : ∀ σ ∈ kvE2_sepPos qnf,
        nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3)
    (hdisj : (kvE2_sepDisjunct charBase charK qnf
        (kvE2_sepSlotsLOf (kvE2_sepHonestOrder qnf M w x t h))
        (kvE2_sepSlotsROf (kvE2_sepHonestOrder qnf M w x t h))).2.holds M atomMap x t) :
    (kvE2_sepBody charBase charK qnf).holds M atomMap x t := by
  rw [kvE2_sepBody_holds_iff charBase charK qnf hg M atomMap x t]
  exact ⟨kvE2_sepHonestOrder qnf M w x t h,
    kvE2_sepHonestOrder_mem_arr' qnf M w x t hxw hwt h hLR, hdisj⟩

/-! ## O3 — Joint soundness extraction (task 321 v7, Phase 8)

From a REALIZED joint disjunct of `kvE2_sepBody`, extract the shared witness `w` (the one
`ptW` slot at bracket position `|lL|`; `x < w < t` from the bracket's OWN range — FM-x1t:
witness bounds ride the bracket's range/ordering, never a chain) and, per positive interior
σ, the witness bundle `(x1_σ, hxx1, hx1t, hanchor, hbelow)` — the inputs the task-326
closer `kvE_subBracket2V_sound_of_parts` (`SubBracket2V.lean:1025`) consumes. Positions are
carried by the arrangement's slot INDICES (structural reads; LITMUS: no `x1 < e_i`
relative-position literal anywhere). The shared-`w` pivot CONSUMES the Lemma 5.1 kit
`BracketFormula.leftPart_holds`/`rightPart_holds` (`VecEAFormula.lean:375/:412`; D4 — the
kit is never rebuilt). Templates (new N-slot code regardless):
`kvE_sub2V_bounded_anchor_of_outer` (`SubBracket2V.lean:1182`, public) and the private
`kvE_subBracket2V_extract` (`SubBracket2V.lean:762`, pattern only). Rabinovich 2014:
Def 3.1 monotone enumeration (PDF p.4), Lemma 5.1 (md:72, md:168-171, md:218),
Cor 5.4 (md:154-157). -/

/-- Membership in the positive-sub spine is exactly fold-bit truth (Fintype enumeration). -/
theorem kvE2_sepPos_mem {sig : MonadicSignature} (qnf : NormalForm sig 2 3)
    (σ : NormalForm sig 1 4) :
    σ ∈ kvE2_sepPos qnf ↔ qnf.2 σ = true := by
  unfold kvE2_sepPos
  rw [List.mem_filter]
  simp

/-- **Per-σ LEFT-interior soundness bundle at the shared witness** (O3): σ's fresh witness
    `x1` strictly inside `(x, w)` realizing the folded fresh point type `kvE2_sepPtX1L`
    (head = the `charK (nfk_projFresh σ)` E[Σ]-atom anchor — Lemma 5.1, md:72), with every
    `zXU`-positive 1-type realized strictly BELOW `x1` (Cor 5.4, md:154-157). Bounds ride
    the bracket's own ordering (FM-x1t). -/
def kvE2_sepBundleL {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x : M.carrier) : Prop :=
  ∃ x1 : M.carrier, x < x1 ∧ x1 < w ∧
    (kvE2_sepPtX1L charBase charK σ).eval_at M atomMap x1 ∧
    (∀ χ : NormalForm sig 0 1, σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true →
      ∃ u : M.carrier, x < u ∧ u < x1 ∧
        (⟨charBase χ⟩ : TemporalPred).eval_at M atomMap u)

/-- **Per-σ RIGHT-interior soundness bundle at the shared witness** (O3, mirrored class):
    σ's fresh witness `x1` strictly inside `(w, t)` realizing `kvE2_sepPtX1R`, with every
    `zWX1`-positive 1-type (region `(w, x1)`) realized strictly BELOW `x1` and above `w`.
    NOTE (Phase-7 watch item): no landed per-σ correctness kit serves this class yet; the
    bundle is extracted for Phases 9-10 arbitration. -/
def kvE2_sepBundleR {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w t : M.carrier) : Prop :=
  ∃ x1 : M.carrier, w < x1 ∧ x1 < t ∧
    (kvE2_sepPtX1R charBase charK σ).eval_at M atomMap x1 ∧
    (∀ χ : NormalForm sig 0 1, σ.2 (nf0_assemble kvE2_sep_zWX1 χ σ.1) = true →
      ∃ u : M.carrier, w < u ∧ u < x1 ∧
        (⟨charBase χ⟩ : TemporalPred).eval_at M atomMap u)

/-- The `charK` E[Σ]-atom anchor head of a realized LEFT-interior fresh point type
    (Lemma 5.1, md:72 — the atom predicates only of its own point; the
    `kvE_subBracket2V_extract` head-projection pattern, `SubBracket2V.lean:798-802`). -/
theorem kvE2_sepPtX1L_anchor {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (x1 : M.carrier)
    (h : (kvE2_sepPtX1L charBase charK σ).eval_at M atomMap x1) :
    (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap x1 := by
  simp only [kvE2_sepPtX1L, TemporalPred.eval_at] at h ⊢
  rw [formula_conjList_iff] at h
  exact h _ List.mem_cons_self

/-- Mirrored anchor head projection for the RIGHT-interior fresh point type. -/
theorem kvE2_sepPtX1R_anchor {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (x1 : M.carrier)
    (h : (kvE2_sepPtX1R charBase charK σ).eval_at M atomMap x1) :
    (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap x1 := by
  simp only [kvE2_sepPtX1R, TemporalPred.eval_at] at h ⊢
  rw [formula_conjList_iff] at h
  exact h _ List.mem_cons_self

/-- A left-interior bundle under `w < t` yields EXACTLY the
    `kvE_subBracket2V_sound_of_parts` (`SubBracket2V.lean:1025`) input 5-tuple
    `(x1, hxx1, hx1t, hanchor, hbelow)` — `x1 < t` rides `x1 < w < t`, the bracket's own
    ordering (FM-x1t; never a formula literal, LITMUS). -/
theorem kvE2_sepBundleL_parts {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    {w x t : M.carrier} (hwt : w < t)
    (h : kvE2_sepBundleL charBase charK σ M atomMap w x) :
    ∃ x1 : M.carrier, x < x1 ∧ x1 < t ∧
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap x1 ∧
      (∀ χ : NormalForm sig 0 1, σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true →
        ∃ u : M.carrier, x < u ∧ u < x1 ∧
          (⟨charBase χ⟩ : TemporalPred).eval_at M atomMap u) := by
  obtain ⟨x1, hxx1, hx1w, hpt, hbelow⟩ := h
  exact ⟨x1, hxx1, hx1w.trans hwt,
    kvE2_sepPtX1L_anchor charBase charK σ M atomMap x1 hpt, hbelow⟩

/-- Mirrored bounded-anchor fragment for a right-interior bundle under `x < w`
    (Phase-7 watch item: recorded for Phases 9-10 arbitration; no landed consumer yet). -/
theorem kvE2_sepBundleR_parts {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    {w x t : M.carrier} (hxw : x < w)
    (h : kvE2_sepBundleR charBase charK σ M atomMap w t) :
    ∃ x1 : M.carrier, x < x1 ∧ x1 < t ∧
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap x1 := by
  obtain ⟨x1, hwx1, hx1t, hpt, -⟩ := h
  exact ⟨x1, hxw.trans hwx1, hx1t,
    kvE2_sepPtX1R_anchor charBase charK σ M atomMap x1 hpt⟩

/-! ### Witness-count normalization and the shared-`w` split (Lemma 5.1 kit consumption) -/

/-- Witness-count normalization for bracket formulas: the joint count `|lL| + 1 + |lR|` is
    not SYNTACTICALLY a successor, so re-type it without touching content (definitional
    structure eta makes `kvE2_sepCastBracket rfl bf ≡ bf`). -/
def kvE2_sepCastBracket {m n : Nat} (h : m = n) (bf : BracketFormula m) :
    BracketFormula n where
  pointTypes := fun i => bf.pointTypes ⟨i.val, by omega⟩
  segmentTypes := fun i => bf.segmentTypes ⟨i.val, by omega⟩

/-- The count cast preserves the bracket semantics. -/
theorem kvE2_sepCastBracket_holds {sig : MonadicSignature} {m n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h : m = n) (bf : BracketFormula m) (z0 z1 : M.carrier) :
    (kvE2_sepCastBracket h bf).holds M atomMap z0 z1 ↔ bf.holds M atomMap z0 z1 := by
  subst h
  exact Iff.rfl

/-- **Shared-witness split for a realized bracket** (Lemma 5.1, md:168-171: the
    `A_i^-`/`A_i^+` decomposition at "which `i` the new point corresponds to", md:218):
    from `holds` over `(x, t)`, the witness at index `i` is strictly inside `(x, t)`,
    realizes its point type, and BOTH halves hold at it — CONSUMING the landed kit
    `BracketFormula.leftPart_holds`/`rightPart_holds` (`VecEAFormula.lean:375/:412`;
    D4: the kit is consumed for every shared-`w` pivot, never rebuilt). -/
theorem kvE2_sepBracket_split_at {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (bf : BracketFormula (n + 1)) (x t : M.carrier) (i : Fin (n + 1))
    (h : bf.holds M atomMap x t) :
    ∃ w : M.carrier, x < w ∧ w < t ∧
      (bf.pointTypes i).eval_at M atomMap w ∧
      (bf.leftPart i).holds M atomMap x w ∧
      (bf.rightPart i).holds M atomMap w t := by
  simp only [BracketFormula.holds, BracketFormula.toIntervalPattern,
    IntervalPattern.holds] at h
  obtain ⟨ws, hmono, hrange, hpt, hseg0, hsegmid, hsegn⟩ := h
  exact ⟨ws i, (hrange i).1, (hrange i).2, hpt i,
    BracketFormula.leftPart_holds M atomMap bf x t i ws hmono hrange hpt hseg0 hsegmid hsegn,
    BracketFormula.rightPart_holds M atomMap bf x t i ws hmono hrange hpt hseg0 hsegmid hsegn⟩

/-! ### Structural navigation helpers (private plumbing) -/

/-- Point-list read at the shared `ptW` position `|L|` (§5 bracket, PDF p.7). -/
private theorem kvE2_sep_getElem_mid {α : Type} (L R : List α) (p : α) :
    (L ++ p :: R)[L.length]'(by
      simp only [List.length_append, List.length_cons]; omega) = p := by
  rw [List.getElem_append_right (Nat.le_refl _)]
  simp only [Nat.sub_self, List.getElem_cons_zero]

/-- Point-list read strictly left of the shared slot. -/
private theorem kvE2_sep_getElem_left {α : Type} (L R : List α) (p : α)
    (i : Nat) (hi : i < L.length) :
    (L ++ p :: R)[i]'(by
      simp only [List.length_append, List.length_cons]; omega) = L[i]'hi := by
  rw [List.getElem_append_left hi]

/-- Point-list read strictly right of the shared slot (offset `|L| + 1 + j`). -/
private theorem kvE2_sep_getElem_right {α : Type} (L R : List α) (p : α)
    (j : Nat) (hj : j < R.length) :
    (L ++ p :: R)[L.length + 1 + j]'(by
      simp only [List.length_append, List.length_cons]; omega) = R[j]'hj := by
  rw [List.getElem_append_right (by omega)]
  simp only [show L.length + 1 + j - L.length = j + 1 by omega, List.getElem_cons_succ]

/-- In a valid arrangement, a slot of the SAME σ with strictly smaller region rank sits at
    a strictly smaller index (the structural position read — LITMUS: positions by
    arrangement index, never an `x1 < e_i` literal). -/
private theorem kvE2_sep_index_lt_of_rank_lt {sig : MonadicSignature}
    {l : List (KvE2SepSlot sig)}
    (hpw : l.Pairwise (fun a b => kvE2_sepSlotLe a b = true))
    {i j : Nat} (hi : i < l.length) (hj : j < l.length)
    (hsub : kvE2_sepSlotSub (l[j]'hj) = kvE2_sepSlotSub (l[i]'hi))
    (hrk : kvE2_sepSlotRank (l[j]'hj) < kvE2_sepSlotRank (l[i]'hi)) :
    j < i := by
  rcases Nat.lt_trichotomy j i with hlt | heq | hgt
  · exact hlt
  · subst heq; exact absurd hrk (lt_irrefl _)
  · exfalso
    have hle := List.pairwise_iff_getElem.mp hpw i j hi hj hgt
    unfold kvE2_sepSlotLe at hle
    rw [if_pos hsub.symm, decide_eq_true_eq] at hle
    omega

/-- σ's fresh-witness slot is in its canonical LEFT block (left-interior σ). -/
private theorem kvE2_sep_lX1_mem_slotsLFor {sig : MonadicSignature}
    {σ : NormalForm sig 1 4} (hzone : nf0_zoneSpec σ.1 = kvE2_sep_zXW3) :
    (.lX1 σ : KvE2SepSlot sig) ∈ kvE2_sepSlotsLFor σ := by
  unfold kvE2_sepSlotsLFor
  rw [if_pos hzone]
  exact List.mem_append.mpr (Or.inr List.mem_cons_self)

/-- A left-interior σ's `zXU`-positive 1-type slot is in its canonical LEFT block. -/
private theorem kvE2_sep_lXU_mem_slotsLFor {sig : MonadicSignature}
    {σ : NormalForm sig 1 4} (hzone : nf0_zoneSpec σ.1 = kvE2_sep_zXW3)
    {χ : NormalForm sig 0 1} (hbit : σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true) :
    (.lXU σ χ : KvE2SepSlot sig) ∈ kvE2_sepSlotsLFor σ := by
  unfold kvE2_sepSlotsLFor
  rw [if_pos hzone]
  exact List.mem_append.mpr
    (Or.inl (List.mem_map_of_mem (List.mem_filter.mpr ⟨by simp, hbit⟩)))

/-- σ's fresh-witness slot is in its canonical RIGHT block (right-interior σ). -/
private theorem kvE2_sep_rX1_mem_slotsRFor {sig : MonadicSignature}
    {σ : NormalForm sig 1 4} (hzone : nf0_zoneSpec σ.1 = kvE2_sep_zWT3) :
    (.rX1 σ : KvE2SepSlot sig) ∈ kvE2_sepSlotsRFor σ := by
  unfold kvE2_sepSlotsRFor
  rw [hzone, if_neg kvE2_sep_zWT3_ne_zXW3, if_pos rfl]
  exact List.mem_append.mpr (Or.inr List.mem_cons_self)

/-- A right-interior σ's `zWX1`-positive 1-type slot is in its canonical RIGHT block. -/
private theorem kvE2_sep_rWX1_mem_slotsRFor {sig : MonadicSignature}
    {σ : NormalForm sig 1 4} (hzone : nf0_zoneSpec σ.1 = kvE2_sep_zWT3)
    {χ : NormalForm sig 0 1} (hbit : σ.2 (nf0_assemble kvE2_sep_zWX1 χ σ.1) = true) :
    (.rWX1 σ χ : KvE2SepSlot sig) ∈ kvE2_sepSlotsRFor σ := by
  unfold kvE2_sepSlotsRFor
  rw [hzone, if_neg kvE2_sep_zWT3_ne_zXW3, if_pos rfl]
  exact List.mem_append.mpr
    (Or.inl (List.mem_map_of_mem (List.mem_filter.mpr ⟨by simp, hbit⟩)))

-- NOTE (task 334 Phase 6): the four `arrL/arrR`-based helpers (`kvE2_sep_mem_arrL/R`,
-- `kvE2_sep_arrL/R_pairwise`) were DELETED with the abandoned additive filter
-- (`kvE2_sepValid`/`kvE2_sepArrL/R`). The facts they supplied — canonical-slot membership and
-- region-rank pairwise ordering of the disjunct's slot lists — are now passed to
-- `kvE2_sepDisjunct_extract` as explicit hypotheses (`hmemL/hpairL/hmemR/hpairR`), discharged at
-- each call site for the arrangement the carrier actually uses.

/-! ### The O3 extraction theorems -/

/-- **O3 — joint soundness extraction from a realized disjunct** (task 321 v7 Phase 8;
    report 07 §2.4 `kvE2_sepConj_sharedW` shape, Candidate C staging): from a realized
    joint disjunct over valid interleavings, extract BOTH joint endpoint realizations, the
    ONE shared witness `w` (the `ptW` slot at position `|lL|`; `x < w < t` from the
    bracket's OWN range — FM-x1t), and at that SAME `w` the per-σ witness bundle for every
    positive interior σ of either class. Each witness position is read structurally off
    the arrangement's slot indices via Def 3.1 monotone enumeration (PDF p.4) — never an
    `x1 < e_i` literal (LITMUS); each σ's `zXU`/`zWX1` interior content is realized
    strictly below σ's fresh slot by the region-rank validity (Cor 5.4, md:154-157;
    Lemma 3.2(1), md:77 at the interleaving membership). -/
theorem kvE2_sepDisjunct_extract {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    {lL lR : List (KvE2SepSlot sig)}
    (hmemL : ∀ σ ∈ kvE2_sepPos qnf, ∀ s ∈ kvE2_sepSlotsLFor σ, s ∈ lL)
    (hpairL : lL.Pairwise (fun a b => kvE2_sepSlotLe a b = true))
    (hmemR : ∀ σ ∈ kvE2_sepPos qnf, ∀ s ∈ kvE2_sepSlotsRFor σ, s ∈ lR)
    (hpairR : lR.Pairwise (fun a b => kvE2_sepSlotLe a b = true))
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (x t : M.carrier)
    (h : (kvE2_sepDisjunct charBase charK qnf lL lR).2.holds M atomMap x t) :
    (kvE2_sepEpL charBase charK qnf).eval_at M atomMap x ∧
    (kvE2_sepEpR charBase charK qnf).eval_at M atomMap t ∧
    ∃ w : M.carrier, x < w ∧ w < t ∧
      (kvE2_sepPtW charBase charK qnf).eval_at M atomMap w ∧
      (∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zXW3 →
        kvE2_sepBundleL charBase charK σ M atomMap w x) ∧
      (∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zWT3 →
        kvE2_sepBundleR charBase charK σ M atomMap w t) := by
  obtain ⟨hepL, hepR, hbr⟩ := h
  refine ⟨hepL, hepR, ?_⟩
  -- Destructure the realized N-slot bracket (Def 3.1 monotone enumeration, PDF p.4).
  simp only [kvE2_sepDisjunct, kvE2_sepBracketN, BracketFormula.holds,
    BracketFormula.toIntervalPattern] at hbr
  rw [IntervalPattern.holds_eq_succ M atomMap _ _ x t
    (show (lL.map (kvE2_sepSlotType charBase charK)).length + 1
        + (lR.map (kvE2_sepSlotType charBase charK)).length
      = (lL.map (kvE2_sepSlotType charBase charK)).length
        + (lR.map (kvE2_sepSlotType charBase charK)).length + 1 by omega)] at hbr
  obtain ⟨ws, hmono, hrange, hpt, -, -, -⟩ := hbr
  -- Canonical point-type reads (defeq re-typing; template `SubBracket2V.lean:699-702`).
  have hpt' : ∀ (i : Nat) (hi : i < (lL.map (kvE2_sepSlotType charBase charK)).length
        + (lR.map (kvE2_sepSlotType charBase charK)).length + 1),
      ((lL.map (kvE2_sepSlotType charBase charK)
          ++ kvE2_sepPtW charBase charK qnf
            :: lR.map (kvE2_sepSlotType charBase charK))[i]'(by
        simp only [List.length_append, List.length_cons]; omega)).eval_at M atomMap
        (ws ⟨i, hi⟩) := fun i hi => hpt ⟨i, hi⟩
  refine ⟨ws ⟨(lL.map (kvE2_sepSlotType charBase charK)).length, by omega⟩,
    (hrange _).1, (hrange _).2, ?_, ?_, ?_⟩
  · -- The shared `ptW` realization at position `|lL|` (§5 bracket, PDF p.7).
    have h1 := hpt' (lL.map (kvE2_sepSlotType charBase charK)).length (by omega)
    rwa [kvE2_sep_getElem_mid] at h1
  · -- LEFT-interior bundles: σ's fresh slot occurs in the LEFT interleaving.
    intro σ hσpos hzone
    obtain ⟨iσ, hiσ, hgetiσ⟩ := List.mem_iff_getElem.mp
      (hmemL σ hσpos _ (kvE2_sep_lX1_mem_slotsLFor hzone))
    have hiσm : iσ < (lL.map (kvE2_sepSlotType charBase charK)).length := by
      simp only [List.length_map]; omega
    refine ⟨ws ⟨iσ, by omega⟩, (hrange _).1,
      hmono _ _ (Fin.mk_lt_mk.mpr hiσm), ?_, ?_⟩
    · -- σ's folded fresh point type at its own slot (Lemma 5.1, md:72).
      have h1 := hpt' iσ (by omega)
      rwa [kvE2_sep_getElem_left _ _ _ iσ hiσm, List.getElem_map, hgetiσ] at h1
    · -- Every `zXU`-positive 1-type strictly below σ's fresh slot (region-rank validity).
      intro χ hbit
      obtain ⟨jχ, hjχ, hgetjχ⟩ := List.mem_iff_getElem.mp
        (hmemL σ hσpos _ (kvE2_sep_lXU_mem_slotsLFor hzone hbit))
      have hji : jχ < iσ := kvE2_sep_index_lt_of_rank_lt hpairL
        hiσ hjχ (by rw [hgetjχ, hgetiσ]; rfl) (by rw [hgetjχ, hgetiσ]; exact Nat.zero_lt_one)
      have hjχm : jχ < (lL.map (kvE2_sepSlotType charBase charK)).length := by
        simp only [List.length_map]; omega
      refine ⟨ws ⟨jχ, by omega⟩, (hrange _).1,
        hmono _ _ (Fin.mk_lt_mk.mpr hji), ?_⟩
      have h1 := hpt' jχ (by omega)
      rwa [kvE2_sep_getElem_left _ _ _ jχ hjχm, List.getElem_map, hgetjχ] at h1
  · -- RIGHT-interior bundles (mirrored): σ's fresh slot occurs in the RIGHT interleaving.
    intro σ hσpos hzone
    obtain ⟨jσ, hjσ, hgetjσ⟩ := List.mem_iff_getElem.mp
      (hmemR σ hσpos _ (kvE2_sep_rX1_mem_slotsRFor hzone))
    have hjσm : jσ < (lR.map (kvE2_sepSlotType charBase charK)).length := by
      simp only [List.length_map]; omega
    refine ⟨ws ⟨(lL.map (kvE2_sepSlotType charBase charK)).length + 1 + jσ, by omega⟩,
      hmono _ _ (Fin.mk_lt_mk.mpr (by omega)), (hrange _).2, ?_, ?_⟩
    · have h1 := hpt' ((lL.map (kvE2_sepSlotType charBase charK)).length + 1 + jσ)
        (by omega)
      rwa [kvE2_sep_getElem_right _ _ _ jσ hjσm, List.getElem_map, hgetjσ] at h1
    · intro χ hbit
      obtain ⟨j', hj', hgetj'⟩ := List.mem_iff_getElem.mp
        (hmemR σ hσpos _ (kvE2_sep_rWX1_mem_slotsRFor hzone hbit))
      have hji : j' < jσ := kvE2_sep_index_lt_of_rank_lt hpairR
        hjσ hj' (by rw [hgetj', hgetjσ]; rfl) (by rw [hgetj', hgetjσ]; exact Nat.zero_lt_one)
      have hj'm : j' < (lR.map (kvE2_sepSlotType charBase charK)).length := by
        simp only [List.length_map]; omega
      refine ⟨ws ⟨(lL.map (kvE2_sepSlotType charBase charK)).length + 1 + j', by omega⟩,
        hmono _ _ (Fin.mk_lt_mk.mpr (by omega)),
        hmono _ _ (Fin.mk_lt_mk.mpr (by omega)), ?_⟩
      have h1 := hpt' ((lL.map (kvE2_sepSlotType charBase charK)).length + 1 + j')
        (by omega)
      rwa [kvE2_sep_getElem_right _ _ _ j' hj'm, List.getElem_map, hgetj'] at h1

/-- **Shared-`w` pivot for the joint disjunct** (Lemma 5.1, md:168-171/md:218 — the
    `A_i^-`/`A_i^+` split at the index of the ONE shared `ptW` slot): from a realized
    joint disjunct, the shared witness realizes `kvE2_sepPtW` and BOTH halves of the
    count-normalized joint bracket hold at it — through the CONSUMED kit
    `kvE2_sepBracket_split_at` = `BracketFormula.leftPart_holds`/`rightPart_holds` (D4).
    The halves carry the refined-conjunction segment realizations for the Phase 9 (O4)
    `hgate` derivation. -/
theorem kvE2_sepDisjunct_halves {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    (lL lR : List (KvE2SepSlot sig))
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (x t : M.carrier)
    (h : (kvE2_sepDisjunct charBase charK qnf lL lR).2.holds M atomMap x t) :
    ∃ w : M.carrier, x < w ∧ w < t ∧
      (kvE2_sepPtW charBase charK qnf).eval_at M atomMap w ∧
      ((kvE2_sepCastBracket
          (n := (lL.map (kvE2_sepSlotType charBase charK)).length
            + (lR.map (kvE2_sepSlotType charBase charK)).length + 1) (by simp only [kvE2_sepDisjunct]; omega)
          (kvE2_sepDisjunct charBase charK qnf lL lR).2.bracket).leftPart
        ⟨(lL.map (kvE2_sepSlotType charBase charK)).length, by omega⟩).holds
          M atomMap x w ∧
      ((kvE2_sepCastBracket
          (n := (lL.map (kvE2_sepSlotType charBase charK)).length
            + (lR.map (kvE2_sepSlotType charBase charK)).length + 1) (by simp only [kvE2_sepDisjunct]; omega)
          (kvE2_sepDisjunct charBase charK qnf lL lR).2.bracket).rightPart
        ⟨(lL.map (kvE2_sepSlotType charBase charK)).length, by omega⟩).holds
          M atomMap w t := by
  obtain ⟨-, -, hbr⟩ := h
  have hbr' := (kvE2_sepCastBracket_holds M atomMap
    (n := (lL.map (kvE2_sepSlotType charBase charK)).length
      + (lR.map (kvE2_sepSlotType charBase charK)).length + 1) (by simp only [kvE2_sepDisjunct]; omega)
    ((kvE2_sepDisjunct charBase charK qnf lL lR).2.bracket) x t).mpr hbr
  obtain ⟨w, hxw, hwt, hptw, hleft, hright⟩ := kvE2_sepBracket_split_at M atomMap _ x t
    ⟨(lL.map (kvE2_sepSlotType charBase charK)).length, by omega⟩ hbr'
  refine ⟨w, hxw, hwt, ?_, hleft, hright⟩
  have h2 : (kvE2_sepCastBracket
      (n := (lL.map (kvE2_sepSlotType charBase charK)).length
        + (lR.map (kvE2_sepSlotType charBase charK)).length + 1) (by simp only [kvE2_sepDisjunct]; omega)
      (kvE2_sepDisjunct charBase charK qnf lL lR).2.bracket).pointTypes
      ⟨(lL.map (kvE2_sepSlotType charBase charK)).length, by omega⟩
      = kvE2_sepPtW charBase charK qnf := kvE2_sep_getElem_mid _ _ _
  rwa [h2] at hptw

/-- **O3 at carrier level**: extraction from any realized `kvE2_sepBody` (no gate
    hypothesis — the gate-failure branch is the empty disjunction, whose `holds` is
    `False`). Routes through the O2 membership collapse `kvE2_sepBody_holds_iff` and
    `kvE2_sepDisjunct_extract`.

    Task 334 Phase 6: post-rewire the carrier's disjunct bracket is built over the canonical
    per-owner region-block slot lists `kvE2_sepSlotsL/R qnf`; the two region-rank pairwise facts
    `hpairL`/`hpairR` on those lists (the ordering the extraction reads for same-owner slot
    location) are passed as hypotheses. They hold whenever the canonical union is a single
    region-sorted block (e.g. the singleton configuration; the general multi-owner pairwise
    discharge is the completeness-side Phase-8 obligation). -/
theorem kvE2_sepBody_extract {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    (hpairL : ∀ wo ∈ kvE2_sepArr' qnf,
      (kvE2_sepSlotsLOf wo).Pairwise (fun a b => kvE2_sepSlotLe a b = true))
    (hpairR : ∀ wo ∈ kvE2_sepArr' qnf,
      (kvE2_sepSlotsROf wo).Pairwise (fun a b => kvE2_sepSlotLe a b = true))
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (x t : M.carrier)
    (h : (kvE2_sepBody charBase charK qnf).holds M atomMap x t) :
    (kvE2_sepEpL charBase charK qnf).eval_at M atomMap x ∧
    (kvE2_sepEpR charBase charK qnf).eval_at M atomMap t ∧
    ∃ w : M.carrier, x < w ∧ w < t ∧
      (kvE2_sepPtW charBase charK qnf).eval_at M atomMap w ∧
      (∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zXW3 →
        kvE2_sepBundleL charBase charK σ M atomMap w x) ∧
      (∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zWT3 →
        kvE2_sepBundleR charBase charK σ M atomMap w t) := by
  by_cases hg : kvE2_sepGate qnf
  · rw [kvE2_sepBody_holds_iff charBase charK qnf hg M atomMap x t] at h
    obtain ⟨wo, hwo, hd⟩ := h
    have hwo' : wo ∈ kvE2_sepOrderTypes qnf := (List.mem_filter.mp hwo).1
    exact kvE2_sepDisjunct_extract charBase charK qnf
      (fun σ hσ s hs => kvE2_sepSlotsLOf_mem qnf hwo' hσ hs) (hpairL wo hwo)
      (fun σ hσ s hs => kvE2_sepSlotsROf_mem qnf hwo' hσ hs) (hpairR wo hwo)
      M atomMap x t hd
  · rw [kvE2_sepBody_gate_fail charBase charK qnf hg] at h
    simp [VVecEA2.holds] at h

/-! ## Phase 9 (O4) — carrier-side per-σ `hgate` derivation: the derivable core

The `hgate` bundle the task-326 closers consume (`kvE_subBracket2V_sound_of_parts`
`SubBracket2V.lean:1025`, spec verbatim at `kvE_subBracket2V_correctness_pair`
`:1868-1882`) has six conjuncts. The lemmas in this section derive the pieces the joint
carrier's realized content DOES determine: the arity-4 nine-zone consistency (the N-point
re-derivation of the private template `kvE_sub2V_zone_consistent`, `SubBracket2V.lean:1270`),
the inner off-fiber conjunct (gate clause (iii)), the inner nine-zone falsity clause (gate
clause (iv)), and the refined-segment exclusion channel (Cor 5.4, md:154-157: a bit-false
1-type is excluded throughout every realized refined sub-interval). -/

/-- Any zone spec realized by a point over the anchor env `[x1, w, x, t]` with
    `x < x1 < w < t` is one of the NINE order-consistent inner zones
    `kvE2_sepInnerConsistentL` (Def 3.1, md:61-74: disjunctions range only over consistent
    order types). Public arity-4 re-derivation of the PRIVATE template
    `kvE_sub2V_zone_consistent` (`SubBracket2V.lean:1270`, template only — plan Phase 9
    task 1); its contrapositive discharges the inconsistent-zone cases of the `hgate`
    forward-zone conjunct. Prop 3.5 (md:91-94) at each navigation literal: every case is a
    pure order-trichotomy read of the evaluation point `u` against the env — no
    `x1 < e_i` literal (LITMUS). -/
theorem kvE2_sep_zone4_consistent {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (x1 w x t u : M.carrier)
    (hxx1 : x < x1) (hx1w : x1 < w) (hwt : w < t)
    (zs : ZoneSpec 4)
    (hz : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) zs u) :
    kvE2_sepInnerConsistentL zs := by
  unfold kvE2_sepInnerConsistentL
  have h0 := hz ⟨0, by omega⟩
  have h1 := hz ⟨1, by omega⟩
  have h2 := hz ⟨2, by omega⟩
  have h3 := hz ⟨3, by omega⟩
  simp only [Fin.cons] at h0 h1 h2 h3
  have hzs : ∀ (p0 p1 p2 p3 : Bool × Bool),
      zs ⟨0, by omega⟩ = p0 → zs ⟨1, by omega⟩ = p1 → zs ⟨2, by omega⟩ = p2 →
        zs ⟨3, by omega⟩ = p3 →
      zs = Fin.cons p0 (Fin.cons p1 (Fin.cons p2 (fun _ => p3))) := by
    intro p0 p1 p2 p3 e0 e1 e2 e3
    funext i
    match i with
    | ⟨0, _⟩ => simpa only [Fin.cons] using e0
    | ⟨1, _⟩ => simpa only [Fin.cons] using e1
    | ⟨2, _⟩ => simpa only [Fin.cons] using e2
    | ⟨3, _⟩ => simpa only [Fin.cons] using e3
  have hxw : x < w := hxx1.trans hx1w
  have hxt : x < t := hxw.trans hwt
  have hx1t : x1 < t := hx1w.trans hwt
  rcases lt_trichotomy u x with hux | hux | hux
  · -- u < x : zPastX
    have hux1 : u < x1 := hux.trans hxx1
    have huw : u < w := hux1.trans hx1w
    have hut : u < t := huw.trans hwt
    exact Or.inl (hzs _ _ _ _
      (Prod.ext_iff.mpr ⟨h0.1.mp hux1, k1v_bool_eq_false h0.2 (lt_asymm hux1)⟩)
      (Prod.ext_iff.mpr ⟨h1.1.mp huw, k1v_bool_eq_false h1.2 (lt_asymm huw)⟩)
      (Prod.ext_iff.mpr ⟨h2.1.mp hux, k1v_bool_eq_false h2.2 (lt_asymm hux)⟩)
      (Prod.ext_iff.mpr ⟨h3.1.mp hut, k1v_bool_eq_false h3.2 (lt_asymm hut)⟩))
  · -- u = x : zAtX
    subst hux
    exact Or.inr (Or.inl (hzs _ _ _ _
      (Prod.ext_iff.mpr ⟨h0.1.mp hxx1, k1v_bool_eq_false h0.2 (lt_asymm hxx1)⟩)
      (Prod.ext_iff.mpr ⟨h1.1.mp hxw, k1v_bool_eq_false h1.2 (lt_asymm hxw)⟩)
      (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_irrefl u),
        k1v_bool_eq_false h2.2 (lt_irrefl u)⟩)
      (Prod.ext_iff.mpr ⟨h3.1.mp hxt, k1v_bool_eq_false h3.2 (lt_asymm hxt)⟩)))
  · -- x < u : split against x1
    rcases lt_trichotomy u x1 with hux1 | hux1 | hux1
    · -- x < u < x1 : zXU
      have huw : u < w := hux1.trans hx1w
      have hut : u < t := huw.trans hwt
      exact Or.inr (Or.inr (Or.inl (hzs _ _ _ _
        (Prod.ext_iff.mpr ⟨h0.1.mp hux1, k1v_bool_eq_false h0.2 (lt_asymm hux1)⟩)
        (Prod.ext_iff.mpr ⟨h1.1.mp huw, k1v_bool_eq_false h1.2 (lt_asymm huw)⟩)
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_asymm hux), h2.2.mp hux⟩)
        (Prod.ext_iff.mpr ⟨h3.1.mp hut, k1v_bool_eq_false h3.2 (lt_asymm hut)⟩))))
    · -- u = x1 : zAtX1
      subst hux1
      exact Or.inr (Or.inr (Or.inr (Or.inl (hzs _ _ _ _
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_irrefl u),
          k1v_bool_eq_false h0.2 (lt_irrefl u)⟩)
        (Prod.ext_iff.mpr ⟨h1.1.mp hx1w, k1v_bool_eq_false h1.2 (lt_asymm hx1w)⟩)
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_asymm hxx1), h2.2.mp hxx1⟩)
        (Prod.ext_iff.mpr ⟨h3.1.mp hx1t, k1v_bool_eq_false h3.2 (lt_asymm hx1t)⟩)))))
    · -- x1 < u : split against w
      rcases lt_trichotomy u w with huw | huw | huw
      · -- x1 < u < w : zUW
        have hut : u < t := huw.trans hwt
        exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inl (hzs _ _ _ _
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm hux1), h0.2.mp hux1⟩)
          (Prod.ext_iff.mpr ⟨h1.1.mp huw, k1v_bool_eq_false h1.2 (lt_asymm huw)⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_asymm hux), h2.2.mp hux⟩)
          (Prod.ext_iff.mpr ⟨h3.1.mp hut, k1v_bool_eq_false h3.2 (lt_asymm hut)⟩))))))
      · -- u = w : zAtW
        subst huw
        exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inl (hzs _ _ _ _
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm hx1w), h0.2.mp hx1w⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_irrefl u),
            k1v_bool_eq_false h1.2 (lt_irrefl u)⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_asymm hxw), h2.2.mp hxw⟩)
          (Prod.ext_iff.mpr ⟨h3.1.mp hwt, k1v_bool_eq_false h3.2 (lt_asymm hwt)⟩)))))))
      · -- w < u : split against t
        have hx1u : x1 < u := hx1w.trans huw
        have hxu : x < u := hxw.trans huw
        rcases lt_trichotomy u t with hut | hut | hut
        · -- w < u < t : zWT
          exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inl (hzs _ _ _ _
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm hx1u), h0.2.mp hx1u⟩)
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm huw), h1.2.mp huw⟩)
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_asymm hxu), h2.2.mp hxu⟩)
            (Prod.ext_iff.mpr ⟨h3.1.mp hut, k1v_bool_eq_false h3.2 (lt_asymm hut)⟩))))))))
        · -- u = t : zAtT
          subst hut
          exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inl (hzs _ _ _ _
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm hx1u), h0.2.mp hx1u⟩)
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm huw), h1.2.mp huw⟩)
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_asymm hxu), h2.2.mp hxu⟩)
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h3.1 (lt_irrefl u),
              k1v_bool_eq_false h3.2 (lt_irrefl u)⟩)))))))))
        · -- t < u : zFutT
          have hx1u' : x1 < u := hx1t.trans hut
          have hxu' : x < u := hxt.trans hut
          have hwu' : w < u := hwt.trans hut
          exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (hzs _ _ _ _
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm hx1u'), h0.2.mp hx1u'⟩)
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hwu'), h1.2.mp hwu'⟩)
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_asymm hxu'), h2.2.mp hxu'⟩)
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h3.1 (lt_asymm hut), h3.2.mp hut⟩)))))))))

/-- `hgate` conjunct — INNER OFF-FIBER falsity for a positive σ (spec conjunct at
    `SubBracket2V.lean:1872`), read directly off joint gate clause (iii): the depth-2 gate
    already carries this conjunct model-independently for EVERY positive sub. -/
theorem kvE2_sepHgate_offFiber {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (hg : kvE2_sepGate qnf)
    (σ : NormalForm sig 1 4) (hσ : qnf.2 σ = true) :
    ∀ τ : NormalForm sig 0 5, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false :=
  hg.2.2.1 σ hσ

/-- Joint gate clause (iv) surfaced for the O4 pipeline: inner NINE-zone falsity for a
    left-interior positive σ. Combined with `kvE2_sep_zone4_consistent`'s contrapositive
    this discharges the `hgate` forward-zone conjunct (`SubBracket2V.lean:1873-1877`) for
    every INCONSISTENT zone pattern: no model point realizes such a zone, and its fold bit
    is `false`. -/
theorem kvE2_sepHgate_innerNine {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (hg : kvE2_sepGate qnf)
    (σ : NormalForm sig 1 4) (hσ : qnf.2 σ = true)
    (hzone : nf0_zoneSpec σ.1 = kvE2_sep_zXW3) :
    ∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1), ¬ kvE2_sepInnerConsistentL zs →
      σ.2 (nf0_assemble zs χ σ.1) = false :=
  hg.2.2.2 σ hσ hzone

/-- **Refined-segment exclusion channel** (Cor 5.4, md:154-157 — the quantifier-free
    segment read; Lemma 5.1, md:72 at the segment formula's quantifier-free shape): a
    realized per-σ exclusion segment falsifies every bit-FALSE 1-type at its point. This is
    the ONLY carrier channel that converts model facts on the OPEN refined sub-intervals
    into fold-bit information; its contrapositive is the `hgate` forward-zone conjunct
    restricted to segment-interior points. -/
theorem kvE2_sepSegForm_excludes {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (σ : NormalForm sig 1 4) (zs : ZoneSpec 4) (χ : NormalForm sig 0 1)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (u : M.carrier)
    (h : (⟨kvE2_sepSegForm charBase σ zs⟩ : TemporalPred).eval_at M atomMap u)
    (hbit : kvE2_sepBits σ zs χ = false) :
    ¬ (⟨charBase χ⟩ : TemporalPred).eval_at M atomMap u := by
  simp only [kvE2_sepSegForm, TemporalPred.eval_at] at h
  rw [formula_conjList_iff] at h
  have hneg := h ((charBase χ).neg)
    (List.mem_map.mpr ⟨χ, by simp, by simp [hbit]⟩)
  simp only [TemporalPred.eval_at, Formula.neg, temporal_truth] at hneg ⊢
  exact hneg

/-! ## O4 CRUX RECORD — task 321 v7 Phase 9 verdict: **FAIL** (inert; decision-gate input)

**This is NOT a route NO-GO.** The derivable core above (`kvE2_sep_zone4_consistent`,
`kvE2_sepHgate_offFiber`, `kvE2_sepHgate_innerNine`, `kvE2_sepSegForm_excludes`) plus the
biconditional endpoint/witness literals (`kvE2_sepEpL`/`EpR`/`PtW`/`PtX1L` — covering the
six at/exterior inner zones `zPastX4`/`zAtX4`/`zAtX1L`/`zAtWL`/`zAtT4`/`zFutT4` in BOTH
directions) and σ's OWN slot channel (its `kvE2_sepS`-enumerated bit-true 1-types realized
at its `lXU`/`lUW`/`lWT` slots) determine five of the six `hgate` conjuncts
(`SubBracket2V.lean:1868-1882`) at the extracted anchor. What fails is exactly the
forward-zone conjunct (`:1873-1877`) at a CROSS-σ slot point — the residue both prior
handoffs flagged ("bracket points inside another σ's zone are not covered by segment
exclusions; points sit between segments").

**Captured crux (`lean_goal`, minimal instance; hypothesis set is the FULL superset — the
realized joint disjunct `h` itself, arrangement memberships `hL`/`hR`, the gate `hg`, and
every Phase-8-extractable fact `hepL`/`hepR`/`hptW`/`hptX1`/`hbundleL`, so the failure is
not attributable to a dropped input).** With σ, τ distinct left-interior positives,
`hτbit : kvE2_sepBits τ kvE_sub2_zXU χ = true`, and τ's χ-slot interleaved before σ's
fresh slot (`kvE2_sepSlotLe` leaves cross-σ order free), the slot's witness `v` satisfies
`x < v < x1` with `hχv : nf_eval_nf M 0 1 (fun _ => v) χ` in EVERY realization of that
arrangement, and the forward-zone conjunct instantiated at `v` demands:

    ⊢ σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true

**Failed closers on the captured crux (five; task-327 evidence style):**
  1. `exact hτbit` → *Type mismatch: has type `kvE2_sepBits τ kvE_sub2_zXU χ = true` but
     is expected to have type `σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true`.* τ's bit does
     not transfer to σ — the carrier has NO cross-σ bit channel.
  2. `simp_all [kvE2_sepBits, kvE2_sepGate, kvE2_sepInnerConsistentL]` → unfolds the gate
     to its four clauses; goal UNSOLVED. All four gate clauses conclude `… = false`
     (off-fiber ×2, inconsistent-zone ×2); no clause in the entire carrier concludes a
     bit-TRUE for σ from another σ's data.
  3. `exact hg.2.2.2 σ hσ hσzone kvE_sub2_zXU χ (by simp [kvE2_sepInnerConsistentL])` →
     residual sub-goal `¬ kvE_sub2_zXU = …` over the nine consistent patterns is FALSE
     (`kvE_sub2_zXU` IS the third consistent pattern), and the clause's conclusion has the
     wrong polarity (`= false`) besides.
  4. `exact kvE2_sepSegForm_excludes … v (by assumption) (by assumption)` → leaves goals
     `TemporalPred.eval_at M atomMap' ⟨kvE2_sepSegForm … σ kvE_sub2_zXU⟩ v` (unprovable:
     `v` is a bracket POINT — the realized disjunct asserts segments only on the OPEN
     intervals between consecutive witnesses, never at a witness) and
     `kvE2_sepBits σ kvE_sub2_zXU χ = false` (wrong polarity: the exclusion channel
     consumes a false bit; it cannot produce a true one at a non-segment point).
  5. `aesop` → *failed to prove the goal after exhaustive search.*

**Channel exhaustion (why no derivation exists, not merely none found).** The carrier's
only model-fact→fold-bit channels are: (a) the segment contrapositive
(`kvE2_sepSegForm_excludes`) — fires only at segment-covered points, and `v` is a witness
point between segments; (b) the `kvE2_sepLit` biconditional literals at `x`/`w`/`t`/`x1` —
stated only for the six at/exterior zones, never for the three open interior regions
`zXU`/`zUW`/`zWT`; (c) σ's own slot membership (`kvE2_sepS σ zs` enumerates σ's bit-TRUE
1-types) — τ's slot is not in σ's enumeration. The gate `kvE2_sepGate` contributes only
falsity clauses. Hence `σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true` is underdetermined
by the realized carrier content — the plan's Phase 10 FAIL criterion verbatim ("a per-σ
zone bit required by `hgate` underdetermined by the refined-conjunction segments +
E[Σ]-atom literals").

**Why no ADDITIVE repair closes it (probed at the bit level, not re-designed here):**
  * A conjunctive cross-σ gate clause (`τ`'s `zXU`-bit true → σ's `zXU`- AND `zUW`- AND
    `zAtX1`-bits true for that χ) is sound-sufficient but NOT honest-derivable: an honest
    model may place every χ-point of `(x,w)` strictly above `x1_σ`, leaving σ's `zXU`-bit
    honestly false — the clause would break `kvE2_sepGate_holds_of_honest` and non-vacuity
    (FM-vac, prohibited).
  * The honest-derivable DISJUNCTIVE clause (σ's `zXU`- OR `zAtX1`- OR `zUW`-bit true)
    cannot select the disjunct matching the REALIZED arrangement's placement of τ's slot —
    the Bool disjunction is arrangement-blind while the placement is arrangement-chosen.
  * The faithful repair is BIT-COMPATIBILITY FILTERING of the interleaving enumeration
    (admit an arrangement only when every cross-σ slot placement matches a true bit of
    every other interior positive — Lemma 3.2(1)'s disjunction ranges over CONSISTENT
    refinements, md:77). That re-defines `kvE2_sepValid`/`kvE2_sepArrL`/`kvE2_sepArrR`
    (Phase 7 carrier structure) with knock-on rework of O1b non-vacuity (the canonical
    identity arrangement is no longer always admitted) and the O2/O3 membership plumbing —
    a carrier re-definition outside this phase's additive scope, owned by the Phase 10
    decision gate.

**Second, independent obstruction to the ∀-anchor form (`:1868` binds every
`a ∈ (x,t)` realizing the `charK` anchor).** Conjunct `a < w` requires the right region to
EXCLUDE anchor-realizing points, but the right-region segment content for a left-interior
σ (`kvE2_sepSegRForSub` = `kvE2_sepSegForm … kvE_sub2_zWT`) conjoins only depth-0
`charBase` 1-type negations — the depth-1 `charK (nfk_projFresh σ)` E[Σ]-atom is never
excluded there, and a right-interior τ with `nfk_projFresh τ = nfk_projFresh σ` even
POSITIVELY realizes it above `w` at its `rX1` slot.

**LITMUS.** No `x1 < e_i` relative-position literal was introduced or needed; the
obstruction is a missing arrangement-bit compatibility constraint, not a positioning
literal. Prohibited patches (chain splicing FM-merge, `x1 < e_i`, gate-modulo-assumed
`hgate`, vacuous placeholder, `sorry`) were NOT applied.

**Consequence (Phase 10 routing input).** O4 FAIL → per the plan's decision-gate table the
indicated route is **N2** (single-positive-sub fragment): with ONE interior positive there
are no cross-σ slots — every left-list witness is σ's own bit-true 1-type or the
literal-covered self-zones — so the residue vanishes; this is exactly the configuration
the landed `kvE_subBracket2V_sound_of_outer` (`SubBracket2V.lean:1216`) +
`kvE_sub2V_bounded_anchor_of_outer` (`:1182`) already serve. The derivable core landed
above remains live input to N2's per-σ gate work. This record is additive and inert. -/

/-! ## Task 334 Phase 1 — MAKE-OR-BREAK SPIKE: faithful order-type disjunction composes

The plan-02 additive open-zone filter (`kvE2_sepValid`/`kvE2_sepArrL/R`) was proven FALSE on a
concrete 2-owner coincidence (handoff 05): with a foreign owner τ's χ-witness coinciding EXACTLY
with σ's fresh anchor `x1_σ`, the extractor's reverse channels force σ's OPEN-zone bits
`kvE2_sepBits σ zXU χ = false` and `kvE2_sepBits σ zUW χ = false`, while the CLOSED-zone bit
`kvE2_sepBits σ zAtX1L χ = true` (via `kvE2_sepCoincidentAnchor_discharge`). The additive filter
reads ONLY the open bits, so `kvE2_sepArrL = []` and `kvE2_sepBody_nonvacuous` is FALSE.

This spike ABANDONS the additive-filter framing and builds the faithful Rabinovich Lemma 3.2(1)
form (md:77): an order-type disjunction over the merged anchor set, where EACH disjunct reads the
zone bit appropriate to ITS arrangement — strict disjuncts the OPEN `zXU`/`zUW` bits, the
coincidence disjunct the CLOSED `zAtX1L` bit (§5 meet-typed shared point, md:168-173). The
coincidence is a first-class DISJUNCT admitted by the closed channel, NOT a tie refuted by an
open-bit inequality. This is per-order-type validity, NOT handoff-05's rejected "Option A" (a
single disjunctive open∨closed filter over the same flat union). -/

-- NOTE (task 334 Phase 6): `KvE2SepSpikeOrderType` and `kvE2_sepSpikeOrderTypes` were RELOCATED
-- above the carrier (`## Task 334 Phases 1-2 (RELOCATED above the carrier)`), so `kvE2_sepBody`
-- can reference `kvE2_sepArr'`. The Phase-1 spike theorems below still consume them.

/-- **Per-order-type validity** (the faithful replacement of the additive `kvE2_sepValid`): each
    disjunct reads the fold bit appropriate to ITS arrangement. Strict disjuncts consume σ's OPEN
    `zXU`/`zUW` bits (the surviving task-333 compat-leaf reads, `kvE2_sepCompat_lX1_eq`/`_after_eq`,
    SW:409/422); the coincidence disjunct consumes σ's CLOSED `zAtX1L` bit fed by
    `kvE2_sepCoincidentAnchor_discharge` (the §5 meet channel). No disjunct conflates open and
    closed keys — the crux the additive filter structurally could not express (handoff 05). -/
def kvE2_sepSpikeDisjValid {sig : MonadicSignature}
    (σ : NormalForm sig 1 4) (χ : NormalForm sig 0 1) :
    KvE2SepSpikeOrderType → Bool
  | .strictBefore => kvE2_sepBits σ kvE_sub2_zXU χ
  | .strictAfter  => kvE2_sepBits σ kvE_sub2_zUW χ
  | .coincident   => kvE2_sepBits σ kvE2_sep_zAtX1L χ

/-- The filtered valid order-type disjuncts (the faithful analog of `kvE2_sepArrL`, per-order-type
    rather than an additive filter over a flat slot union). -/
def kvE2_sepSpikeArr {sig : MonadicSignature}
    (σ : NormalForm sig 1 4) (χ : NormalForm sig 0 1) : List KvE2SepSpikeOrderType :=
  kvE2_sepSpikeOrderTypes.filter (kvE2_sepSpikeDisjValid σ χ)

/-- **CONTRAST — the plan-02 RED baseline.** The additive OPEN-zone-only filter (reading solely
    the `zXU`/`zUW` bits, never the closed one) is EMPTY on the exact handoff-05 scenario. This is
    precisely the obligation `kvE2_sepBody_nonvacuous` made FALSE: no strict disjunct survives when
    the coincidence forces both open bits to `false`. -/
theorem kvE2_sepSpike_additiveOpenOnly_vacuous {sig : MonadicSignature}
    (σ : NormalForm sig 1 4) (χ : NormalForm sig 0 1)
    (hzXU : kvE2_sepBits σ kvE_sub2_zXU χ = false)
    (hzUW : kvE2_sepBits σ kvE_sub2_zUW χ = false) :
    ([KvE2SepSpikeOrderType.strictBefore, KvE2SepSpikeOrderType.strictAfter].filter
      (kvE2_sepSpikeDisjValid σ χ)) = [] := by
  have h1 : kvE2_sepSpikeDisjValid σ χ KvE2SepSpikeOrderType.strictBefore = false := hzXU
  have h2 : kvE2_sepSpikeDisjValid σ χ KvE2SepSpikeOrderType.strictAfter = false := hzUW
  simp [List.filter_cons, h1, h2]

/-- **MAKE-OR-BREAK SPIKE (task 334 Phase 1 GATE).** On the exact 2-owner coincidence the additive
    filter made FALSE (handoff 05) — σ a left-interior owner realized at `[x1,w,x,t]` with the
    foreign owner τ's base type `χ` realized AT σ's fresh anchor `x1` and NO χ-witness strictly in
    `(x,x1)` or `(x1,w)` (so σ's OPEN bits are `false`) — the faithful order-type-disjunction
    filter is NON-VACUOUS: the coincidence disjunct is admitted via the CLOSED `zAtX1L` bit fed by
    the preserved, axiom-clean `kvE2_sepCoincidentAnchor_discharge`.

    This proves the faithful architecture COMPOSES on the make-or-break obligation: the closed
    channel ROUTES into per-order-type validity (Lemma 3.2(1) coincidence disjunct, md:77;
    §5 meet-type, md:168-173), where the additive open-only filter could not (type-mismatch,
    handoff 05). Faithfulness invariants exercised: F2 (non-vacuity, coincidence direction),
    F5 (closed vs open key discrimination — the crux), F1 (QF types via the preserved brick). -/
theorem kvE2_sepSpike_twoOwner_coincidence_nonvacuous {sig : MonadicSignature}
    (σ : NormalForm sig 1 4) (M : OrderedMonadicStructure sig)
    (x1 w x t : M.carrier) (hxx1 : x < x1) (hx1w : x1 < w) (hwt : w < t)
    (hσ : nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (χ : NormalForm sig 0 1)
    (hp : nf_eval_nf M 0 1 (fun _ => x1) χ)
    -- The handoff-05 OPEN-zone FALSE pins (no χ-witness strictly in `(x,x1)` or `(x1,w)`); kept as
    -- scenario fidelity — non-vacuity of the FULL faithful arr needs only the coincidence disjunct,
    -- while `kvE2_sepSpike_additiveOpenOnly_vacuous` shows these make the open-only filter empty.
    (_hzXU : kvE2_sepBits σ kvE_sub2_zXU χ = false)
    (_hzUW : kvE2_sepBits σ kvE_sub2_zUW χ = false) :
    kvE2_sepSpikeArr σ χ ≠ [] := by
  -- The CLOSED-zone bit is discharged TRUE by the preserved axiom-clean coincidence brick.
  have hclosed : kvE2_sepBits σ kvE2_sep_zAtX1L χ = true :=
    kvE2_sepCoincidentAnchor_discharge σ M x1 w x t hxx1 hx1w hwt hσ χ hp
  -- The coincidence disjunct is therefore VALID and present in the filtered order-type list,
  -- so the faithful arrangement set is non-empty — the exact obligation the additive filter failed.
  apply List.ne_nil_of_mem (a := KvE2SepSpikeOrderType.coincident)
  unfold kvE2_sepSpikeArr
  rw [List.mem_filter]
  refine ⟨by decide, ?_⟩
  simpa [kvE2_sepSpikeDisjValid] using hclosed

-- NOTE (task 334 Phase 6): the Phase-2 order-type index cluster (KvE2SepWeakOrder,
-- kvE2_sepOrderTypes, kvE2_sepModelTag/Order, kvE2_sepClosedLeafStub, kvE2_sepDisjValidOwner,
-- kvE2_sepDisjValid, kvE2_sepArr', kvE2_sepArr'_decidable, kvE2_sepModelOrder_mem_*,
-- kvE2_sepArr'_mem_modelOrder) was RELOCATED above the carrier so kvE2_sepBody can enumerate
-- kvE2_sepArr'. See "## Task 334 Phases 1-2 (RELOCATED above the carrier)".

/-! ## Task 334 Phase 4 — closed-zone compat leaf + three-way segment-meet cut (LEFT)

The 5th, closed-zone compat leaf (`kvE2_sepCompat_zAtX1L_eq`) re-hosts the Phase-2 forward stub
`kvE2_sepClosedLeafStub` (which read σ's OWN fresh type `nf0_projFresh σ.1`) over a FOREIGN owner's
base type `χ`: at a coincidence tie the disjunct's closed-zone validity is discharged TRUE by the
preserved axiom-clean `kvE2_sepCoincidentAnchor_discharge` (§5 meet channel, md:168-173). The
three-way segment cut (`kvE2_sepSegLForSub'`) supersedes the binary before/after cut
`kvE2_sepSegLForSub` (`:561`) with a before/**at**/after cut whose "at" case sets the LEFT-interior
segment type to the MEET `A_i^- ∧ A_i^+` (the §5 splitting `A_i = A_i^- ∧ A_i^+`, md:168) — the
conjunction of σ's `(x,x1)` before-exclusion (`kvE_sub2_zXU`) and `(x1,w)` after-exclusion
(`kvE_sub2_zUW`), i.e. universal β over the whole shared interval around the closed anchor.

Faithfulness invariants exercised: **F2** (meet, not vacuity — the "at" case discriminates via a
genuine two-sided exclusion, never `Formula.top`), **F5** (the coincidence disjunct reads the CLOSED
`zAtX1L` key; strict disjuncts read the OPEN `zXU`/`zUW` keys — never conflated), **F1** (the meet
type is quantifier-free over Σ — a `Formula.and` of two `charBase`-fold segment forms), **F6** (the
per-bracket F-chain is unaffected — this is a per-owner segment contribution, combined ABOVE the
chain by the cross-owner `kvE2_sepPos`-map conjunction in `kvE2_sepSegLAt`).

The binary `kvE2_sepSegLForSub` is left in place (additive build; its removal/rewiring is Phase 6);
the two LEFT compat leaves `kvE2_sepCompat_lX1_eq`/`kvE2_sepCompat_lX1_after_eq` survive unchanged as
the strict-disjunct validators (see the survival note below). -/

/-- **5th closed-zone compat leaf** (Phase 4, re-host of `kvE2_sepClosedLeafStub` over foreign base
    types). At a coincidence tie — a foreign owner's base type `χ` realized AT σ's fresh anchor `x1`
    (`nf_eval_nf M 0 1 (fun _ => x1) χ`) under `x < x1 < w < t` — the coincidence disjunct's
    validity `kvE2_sepSpikeDisjValid σ χ .coincident` is TRUE, discharged by the preserved
    axiom-clean `kvE2_sepCoincidentAnchor_discharge`. Definitionally the disjunct read is
    `kvE2_sepBits σ kvE2_sep_zAtX1L χ` (the CLOSED self-zone key, F5), so this leaf establishes the
    §5 meet-typed shared point (md:168-173) over a FOREIGN owner's type — the generalization of the
    stub's own-type read `kvE2_sepBits σ kvE2_sep_zAtX1L (nf0_projFresh σ.1)`. F2 (meet, not
    vacuity): the tie is a first-class DISCHARGED disjunct, never a refuted inequality. -/
theorem kvE2_sepCompat_zAtX1L_eq {sig : MonadicSignature}
    (σ : NormalForm sig 1 4) (M : OrderedMonadicStructure sig)
    (x1 w x t : M.carrier) (hxx1 : x < x1) (hx1w : x1 < w) (hwt : w < t)
    (hσ : nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (χ : NormalForm sig 0 1)
    (hp : nf_eval_nf M 0 1 (fun _ => x1) χ) :
    kvE2_sepSpikeDisjValid σ χ KvE2SepSpikeOrderType.coincident = true := by
  -- The disjunct read `kvE2_sepSpikeDisjValid σ χ .coincident` is definitionally the CLOSED
  -- `zAtX1L` bit; the preserved brick discharges it TRUE for the foreign type `χ` at the tie.
  show kvE2_sepBits σ kvE2_sep_zAtX1L χ = true
  exact kvE2_sepCoincidentAnchor_discharge σ M x1 w x t hxx1 hx1w hwt hσ χ hp

/-- **Three-way LEFT segment cut** (Phase 4, supersedes the binary `kvE2_sepSegLForSub`, `:561`).
    σ's exclusion contribution to a LEFT-region refined sub-interval, keyed by σ's placement tag on
    the merged anchor set (the order-type disjunct). Branches on `nf0_zoneSpec σ.1`:
    * a LEFT-interior owner (`zXW3`, `x < x1_σ < w`) gets the three-way before/**at**/after cut:
      - `strictBefore` → LEFT β: the `(x, x1)` before-exclusion `kvE_sub2_zXU`;
      - `coincident`   → the **MEET** `A_i^- ∧ A_i^+` (§5 splitting, md:168): `Formula.and` of the
        `(x,x1)` and `(x1,w)` exclusions — universal β over the whole shared interval, the closed
        anchor's two-sided content (F1 QF meet, F2 non-vacuous);
      - `strictAfter`  → RIGHT β: the `(x1, w)` after-exclusion `kvE_sub2_zUW`;
    * a RIGHT-interior owner (`zWT3`) contributes its uniform `(x,w)` exclusion (`kvE_sub2_zXU`),
      as in the binary cut — no tie on the left region for a right-interior owner;
    * a non-interior σ contributes `Formula.top` (its content rides its endpoint literal).
    Additive: the binary `kvE2_sepSegLForSub` is retained; Phase 6 rewires the assembly onto this. -/
noncomputable def kvE2_sepSegLForSub' {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (σ : NormalForm sig 1 4) (tag : KvE2SepSpikeOrderType) : Formula :=
  if nf0_zoneSpec σ.1 = kvE2_sep_zXW3 then
    match tag with
    | .strictBefore => kvE2_sepSegForm charBase σ kvE_sub2_zXU
    | .coincident   =>
        Formula.and (kvE2_sepSegForm charBase σ kvE_sub2_zXU)
          (kvE2_sepSegForm charBase σ kvE_sub2_zUW)
    | .strictAfter  => kvE2_sepSegForm charBase σ kvE_sub2_zUW
  else if nf0_zoneSpec σ.1 = kvE2_sep_zWT3 then
    kvE2_sepSegForm charBase σ kvE_sub2_zXU
  else Formula.top

/-- **"At"-case soundness** (Phase 4, Risk R2 core content). For a LEFT-interior owner σ
    (`nf0_zoneSpec σ.1 = kvE2_sep_zXW3`), the coincidence ("at") case of the three-way cut IS the
    §5 meet `A_i = A_i^- ∧ A_i^+` (md:168): the `Formula.and` of σ's `(x,x1)` before-exclusion and
    `(x1,w)` after-exclusion. This is the faithful universal-β-over-the-shared-interval type — σ
    excludes every foreign χ it excludes on EITHER open sub-interval, i.e. over the whole interval
    `(x,w) ∖ {x1}` around the closed anchor. Sound (not vacuity, F2): the meet is a genuine
    two-sided `charBase`-fold conjunction, never `Formula.top`; QF (F1). Axiom-clean (definitional
    reduction — no `sorryAx`). -/
theorem kvE2_sepSegLForSub'_at_sound {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (σ : NormalForm sig 1 4) (hzone : nf0_zoneSpec σ.1 = kvE2_sep_zXW3) :
    kvE2_sepSegLForSub' charBase σ KvE2SepSpikeOrderType.coincident
      = Formula.and (kvE2_sepSegForm charBase σ kvE_sub2_zXU)
          (kvE2_sepSegForm charBase σ kvE_sub2_zUW) := by
  simp only [kvE2_sepSegLForSub', hzone, if_pos]

/-! ## Task 334 Phase 5 — three-way segment-meet cut (RIGHT)

The RIGHT mirror of Phase 4. The §5 splitting `A_i = A_i^- ∧ A_i^+` (md:168) with the right
sub-interval `A_i^+(z,z_1)` (md:170) is realized on the RIGHT region: the tie now belongs to a
RIGHT-interior owner (`zWT3`, `w < x1_σ < t`), whose two open sub-intervals are the `(w, x1)`
before-exclusion (`kvE2_sep_zWX1`) and the `(x1, t)` after-exclusion (`kvE_sub2_zWT`). The three-way
before/**at**/after cut sets the "at" (coincidence) case to the MEET of those two, i.e. universal β
over the whole shared interval `(w,t) ∖ {x1}` around the closed anchor. A LEFT-interior owner
(`zXW3`) on the RIGHT region contributes its uniform `(w,t)` exclusion (`kvE_sub2_zWT`), exactly as
in the binary cut `kvE2_sepSegRForSub` (`:574`) — no tie on the right region for a left-interior
owner.

Compat-leaf survival audit (Task 334 Phase 4+5, binding):
  * All FOUR strict-disjunct compat leaves SURVIVE unchanged, re-hosted as strict-disjunct
    validators (their statements are untouched; only their ROLE changed from bits of the abandoned
    additive filter to per-order-type strict validators):
      - `kvE2_sepCompat_lX1_eq`        (:409) — LEFT `strictBefore`, open key `kvE_sub2_zXU`;
      - `kvE2_sepCompat_lX1_after_eq`  (:422) — LEFT `strictAfter`,  open key `kvE_sub2_zUW`;
      - `kvE2_sepCompat_rX1_eq`        (:434) — RIGHT `strictBefore`, open key `kvE2_sep_zWX1`;
      - `kvE2_sepCompat_rX1_after_eq`  (:446) — RIGHT `strictAfter`,  open key `kvE_sub2_zWT`.
    NONE is replaced.
  * ONE new closed-zone leaf was ADDED in Phase 4: `kvE2_sepCompat_zAtX1L_eq` (:2505), reading the
    CLOSED `zAtX1L` key; it serves the coincidence disjunct on BOTH sides (the closed anchor
    `x1_σ` is the same §5 meet-typed shared point whether σ is left- or right-interior), so no
    separate right-side closed leaf is needed.

Faithfulness invariants exercised: **F2** (the "at" case is the genuine two-sided meet, never
`Formula.top` — no weakening to vacuity), **F5** (the coincidence disjunct reads the CLOSED
`zAtX1L` key via `kvE2_sepCompat_zAtX1L_eq`; the strict disjuncts read the OPEN `zWX1`/`zWT` keys —
never conflated), **F1** (the meet type is quantifier-free over Σ — a `Formula.and` of two
`charBase`-fold segment forms), **F6** (per-bracket F-chain unaffected — a per-owner segment
contribution combined ABOVE the chain).

The binary `kvE2_sepSegRForSub` is left in place (additive build; its removal/rewiring is Phase 6). -/

/-- **Three-way RIGHT segment cut** (Phase 5, supersedes the binary `kvE2_sepSegRForSub`, `:574`).
    σ's exclusion contribution to a RIGHT-region refined sub-interval, keyed by σ's placement tag on
    the merged anchor set (the order-type disjunct). Branches on `nf0_zoneSpec σ.1`:
    * a LEFT-interior owner (`zXW3`) contributes its uniform `(w,t)` exclusion (`kvE_sub2_zWT`),
      as in the binary cut — no tie on the right region for a left-interior owner;
    * a RIGHT-interior owner (`zWT3`, `w < x1_σ < t`) gets the three-way before/**at**/after cut:
      - `strictBefore` → the `(w, x1)` before-exclusion `kvE2_sep_zWX1`;
      - `coincident`   → the **MEET** `A_i^- ∧ A_i^+` (§5 splitting, md:168; right sub-interval
        `A_i^+(z,z_1)`, md:170): `Formula.and` of the `(w,x1)` and `(x1,t)` exclusions — universal
        β over the whole shared interval, the closed anchor's two-sided content (F1 QF meet, F2
        non-vacuous);
      - `strictAfter`  → the `(x1, t)` after-exclusion `kvE_sub2_zWT`;
    * a non-interior σ contributes `Formula.top` (its content rides its endpoint literal).
    Additive: the binary `kvE2_sepSegRForSub` is retained; Phase 6 rewires the assembly onto this. -/
noncomputable def kvE2_sepSegRForSub' {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (σ : NormalForm sig 1 4) (tag : KvE2SepSpikeOrderType) : Formula :=
  if nf0_zoneSpec σ.1 = kvE2_sep_zXW3 then
    kvE2_sepSegForm charBase σ kvE_sub2_zWT
  else if nf0_zoneSpec σ.1 = kvE2_sep_zWT3 then
    match tag with
    | .strictBefore => kvE2_sepSegForm charBase σ kvE2_sep_zWX1
    | .coincident   =>
        Formula.and (kvE2_sepSegForm charBase σ kvE2_sep_zWX1)
          (kvE2_sepSegForm charBase σ kvE_sub2_zWT)
    | .strictAfter  => kvE2_sepSegForm charBase σ kvE_sub2_zWT
  else Formula.top

/-- **"At"-case soundness** (Phase 5, Risk R2 core content — RIGHT mirror of
    `kvE2_sepSegLForSub'_at_sound`). For a RIGHT-interior owner σ
    (`nf0_zoneSpec σ.1 = kvE2_sep_zWT3`), the coincidence ("at") case of the three-way cut IS the
    §5 meet `A_i = A_i^- ∧ A_i^+` (md:168; right sub-interval `A_i^+(z,z_1)`, md:170): the
    `Formula.and` of σ's `(w,x1)` before-exclusion (`kvE2_sep_zWX1`) and `(x1,t)` after-exclusion
    (`kvE_sub2_zWT`). This is the faithful universal-β-over-the-shared-interval type — σ excludes
    every foreign χ it excludes on EITHER open sub-interval, i.e. over the whole interval
    `(w,t) ∖ {x1}` around the closed anchor. Sound (not vacuity, F2): the meet is a genuine
    two-sided `charBase`-fold conjunction, never `Formula.top`; QF (F1). Axiom-clean (definitional
    reduction — no `sorryAx`). -/
theorem kvE2_sepSegRForSub'_at_sound {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (σ : NormalForm sig 1 4) (hzone : nf0_zoneSpec σ.1 = kvE2_sep_zWT3) :
    kvE2_sepSegRForSub' charBase σ KvE2SepSpikeOrderType.coincident
      = Formula.and (kvE2_sepSegForm charBase σ kvE2_sep_zWX1)
          (kvE2_sepSegForm charBase σ kvE_sub2_zWT) := by
  unfold kvE2_sepSegRForSub'
  rw [if_neg (fun h => kvE2_sep_zWT3_ne_zXW3 (hzone.symm.trans h)), if_pos hzone]

/-! ## Task 334 Phase 6 — Lemma 3.2(1) ⇒ (soundness) over the order-type disjunction

The ⇒ half of Lemma 3.2(1) (md:77): a HELD (selected) order-type disjunct implies the joint
conjunction — i.e. every per-owner placement in the held weak order is admitted by that owner's
arrangement-appropriate zone bit (F2, ⇒ realized, not vacuity). Each disjunct reads the bit
appropriate to ITS arrangement: a strict placement reads σ's OPEN `zXU`/`zUW` bit (via the surviving
task-333 compat leaves, and its segment content is the binary before/after cut refined by the
three-way `kvE2_sepSegLForSub'`/`kvE2_sepSegRForSub'` at the meet, Phases 4/5); the coincidence
placement reads σ's CLOSED `zAtX1L` bit (the §5 meet channel discharged by the axiom-clean
`kvE2_sepCoincidentAnchor_discharge`; re-hosted as `kvE2_sepCompat_zAtX1L_eq`, md:168-173). No
disjunct conflates open and closed keys (F5). -/

/-- **Lemma 3.2(1) ⇒ (soundness), order-type level** (task 334 Phase 6): a valid disjunct
    `wo ∈ kvE2_sepArr' qnf` carries the JOINT conjunction of its per-owner arrangement bits — every
    placement `(σ, tag)` in the held weak order is admitted by `kvE2_sepDisjValidOwner σ tag`
    (`= true`). This is the ⇒ half of Lemma 3.2(1) (md:77) at the per-order-type validity level: a
    HELD disjunct (one consistent arrangement) implies the conjunction of the zone-bit conditions
    its arrangement selects — strict placements the OPEN `zXU`/`zUW` bits, the coincidence placement
    the CLOSED `zAtX1L` bit (F5), never vacuously (F2). The realized segment/point content of each
    held disjunct is supplied by `kvE2_sepBody_extract` (the O3 bundle) and the three-way meet cuts
    (`kvE2_sepSegLForSub'_at_sound`/`kvE2_sepSegRForSub'_at_sound`). -/
theorem kvE2_sepArr'_sound {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) {wo : KvE2SepWeakOrder sig}
    (hwo : wo ∈ kvE2_sepArr' qnf) :
    (∀ p ∈ wo, kvE2_sepDisjValidOwner p.1 p.2.1 = true) ∧
      (wo.flatMap (fun p => p.2.2)).Nodup := by
  have hv : kvE2_sepDisjValid qnf wo = true := (List.mem_filter.mp hwo).2
  rw [kvE2_sepDisjValid, Bool.and_eq_true, Bool.and_eq_true] at hv
  obtain ⟨⟨hall, _hcons⟩, hnodup⟩ := hv
  refine ⟨fun p hp => (List.all_eq_true.mp hall) p hp, ?_⟩
  exact of_decide_eq_true hnodup

end Bimodal.Metalogic.WeakCanonical.Kamp
