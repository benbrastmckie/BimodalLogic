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

/-- Arrangement validity relation, Bool-valued: slots of the SAME σ must appear in
    non-decreasing region rank; slots of different σ are unconstrained (that freedom IS
    the Lemma 3.2(1) interleaving enumeration). -/
def kvE2_sepSlotLe {sig : MonadicSignature} (a b : KvE2SepSlot sig) : Bool :=
  !(decide (kvE2_sepSlotSub a = kvE2_sepSlotSub b))
    || decide (kvE2_sepSlotRank a ≤ kvE2_sepSlotRank b)

/-- Arrangement validity: every ordered pair respects `kvE2_sepSlotLe`. -/
def kvE2_sepValid {sig : MonadicSignature} (l : List (KvE2SepSlot sig)) : Bool :=
  decide (l.Pairwise (fun a b => kvE2_sepSlotLe a b = true))

/-- LEFT interleaving set: all permutations of the joint left slot union that keep each
    σ's internal region order (Lemma 3.2(1), md:77 — exposed as a TOP-LEVEL def per the
    crux failed-closer-3 lesson). -/
noncomputable def kvE2_sepArrL {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) : List (List (KvE2SepSlot sig)) :=
  (kvE2_sepSlotsL qnf).permutations.filter kvE2_sepValid

/-- RIGHT interleaving set. -/
noncomputable def kvE2_sepArrR {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) : List (List (KvE2SepSlot sig)) :=
  (kvE2_sepSlotsR qnf).permutations.filter kvE2_sepValid

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

/-! ## The joint carrier (O1) -/

/-- **`kvE2_sepBody` — the joint separate-content shared-witness carrier** (task 321 v7
    Phase 7 O1; report 07 §2.2 Candidate A). Model-independent: disjuncts enumerate the
    joint interleavings `kvE2_sepArrL × kvE2_sepArrR` (Lemma 3.2(1), md:77), each a single
    FLAT bracket via `kvE2_sepDisjunct` (one shared `ptW`, per-σ E[Σ]-atom fresh slots,
    refined-conjunction segments, joint endpoint conjunction at the fixed anchors —
    Lemma 3.2(2), md:78: everything over the two free variables `(x, t)`).
    Gate-failure branch is the empty disjunction (its `holds` is `False`). -/
noncomputable def kvE2_sepBody {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) : VVecEA2 :=
  @dite _ (kvE2_sepGate qnf) (Classical.dec _)
    (fun _ =>
      { disjuncts :=
          (kvE2_sepArrL qnf).flatMap fun lL =>
            (kvE2_sepArrR qnf).map fun lR =>
              kvE2_sepDisjunct charBase charK qnf lL lR })
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
      ∃ lL ∈ kvE2_sepArrL qnf, ∃ lR ∈ kvE2_sepArrR qnf,
        (kvE2_sepDisjunct charBase charK qnf lL lR).2.holds M atomMap x t := by
  simp only [kvE2_sepBody]
  rw [dif_pos hg]
  exact VVecEA2.holds_flatMap_map M atomMap (kvE2_sepArrL qnf) (kvE2_sepArrR qnf)
    (kvE2_sepDisjunct charBase charK qnf) x t

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

/-- Rank monotonicity satisfies the validity relation (the `decide` right disjunct). -/
private theorem kvE2_sepSlotLe_of_rank {sig : MonadicSignature} {a b : KvE2SepSlot sig}
    (h : kvE2_sepSlotRank a ≤ kvE2_sepSlotRank b) : kvE2_sepSlotLe a b = true := by
  unfold kvE2_sepSlotLe
  rw [decide_eq_true h, Bool.or_true]

/-- Distinct owning subs satisfy the validity relation (the negated left disjunct). -/
private theorem kvE2_sepSlotLe_of_sub_ne {sig : MonadicSignature} {a b : KvE2SepSlot sig}
    (h : kvE2_sepSlotSub a ≠ kvE2_sepSlotSub b) : kvE2_sepSlotLe a b = true := by
  unfold kvE2_sepSlotLe
  rw [decide_eq_false h, Bool.not_false, Bool.true_or]

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
private theorem kvE2_sepSlotsLFor_pairwise {sig : MonadicSignature}
    (σ : NormalForm sig 1 4) :
    (kvE2_sepSlotsLFor σ).Pairwise (fun a b => kvE2_sepSlotLe a b = true) := by
  unfold kvE2_sepSlotsLFor
  split
  · refine List.pairwise_append.mpr ⟨?_, ?_, ?_⟩
    · exact List.pairwise_map.mpr
        (kvE2_sep_pairwise_of_forall fun _ _ => kvE2_sepSlotLe_of_rank (Nat.zero_le _))
    · refine List.pairwise_cons.mpr ⟨?_, ?_⟩
      · intro b hb
        obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hb
        exact kvE2_sepSlotLe_of_rank (Nat.le_succ 1)
      · exact List.pairwise_map.mpr
          (kvE2_sep_pairwise_of_forall fun _ _ => kvE2_sepSlotLe_of_rank (Nat.le_refl _))
    · intro s hs b _
      obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hs
      exact kvE2_sepSlotLe_of_rank (Nat.zero_le _)
  · split
    · exact List.pairwise_map.mpr
        (kvE2_sep_pairwise_of_forall fun _ _ => kvE2_sepSlotLe_of_rank (Nat.le_refl _))
    · exact List.Pairwise.nil

/-- σ's canonical RIGHT block respects the region-rank order (`WX1* < x1 < X1T*`). -/
private theorem kvE2_sepSlotsRFor_pairwise {sig : MonadicSignature}
    (σ : NormalForm sig 1 4) :
    (kvE2_sepSlotsRFor σ).Pairwise (fun a b => kvE2_sepSlotLe a b = true) := by
  unfold kvE2_sepSlotsRFor
  split
  · exact List.pairwise_map.mpr
      (kvE2_sep_pairwise_of_forall fun _ _ => kvE2_sepSlotLe_of_rank (Nat.le_refl _))
  · split
    · refine List.pairwise_append.mpr ⟨?_, ?_, ?_⟩
      · exact List.pairwise_map.mpr
          (kvE2_sep_pairwise_of_forall fun _ _ => kvE2_sepSlotLe_of_rank (Nat.zero_le _))
      · refine List.pairwise_cons.mpr ⟨?_, ?_⟩
        · intro b hb
          obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hb
          exact kvE2_sepSlotLe_of_rank (Nat.le_succ 1)
        · exact List.pairwise_map.mpr
            (kvE2_sep_pairwise_of_forall fun _ _ => kvE2_sepSlotLe_of_rank (Nat.le_refl _))
      · intro s hs b _
        obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hs
        exact kvE2_sepSlotLe_of_rank (Nat.zero_le _)
    · exact List.Pairwise.nil

/-- The positive-sub spine is duplicate-free (`Finset.univ.toList` + filter). -/
private theorem kvE2_sepPos_nodup {sig : MonadicSignature} (qnf : NormalForm sig 2 3) :
    (kvE2_sepPos qnf).Nodup :=
  (Finset.nodup_toList _).filter _

/-- The canonical LEFT slot list is a valid arrangement (identity interleaving). -/
private theorem kvE2_sepSlotsL_valid {sig : MonadicSignature} (qnf : NormalForm sig 2 3) :
    kvE2_sepValid (kvE2_sepSlotsL qnf) = true := by
  unfold kvE2_sepValid
  refine decide_eq_true ?_
  unfold kvE2_sepSlotsL
  refine kvE2_sep_pairwise_flatMap (kvE2_sepPos_nodup qnf)
    (fun σ _ => kvE2_sepSlotsLFor_pairwise σ) ?_
  intro a _ b _ hab s hs y hy
  exact kvE2_sepSlotLe_of_sub_ne (by
    rw [kvE2_sepSlotsLFor_sub hs, kvE2_sepSlotsLFor_sub hy]; exact hab)

/-- The canonical RIGHT slot list is a valid arrangement (identity interleaving). -/
private theorem kvE2_sepSlotsR_valid {sig : MonadicSignature} (qnf : NormalForm sig 2 3) :
    kvE2_sepValid (kvE2_sepSlotsR qnf) = true := by
  unfold kvE2_sepValid
  refine decide_eq_true ?_
  unfold kvE2_sepSlotsR
  refine kvE2_sep_pairwise_flatMap (kvE2_sepPos_nodup qnf)
    (fun σ _ => kvE2_sepSlotsRFor_pairwise σ) ?_
  intro a _ b _ hab s hs y hy
  exact kvE2_sepSlotLe_of_sub_ne (by
    rw [kvE2_sepSlotsRFor_sub hs, kvE2_sepSlotsRFor_sub hy]; exact hab)

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

/-- **O1b — non-vacuity of the joint carrier** (fresh analog of
    `kvE_subBracket2V_nonvacuous`, `SubBracket2V.lean:1425`; FM-vac): for a `qnf` arising
    from an actual model realization under `x < w < t`, the depth-2 gate holds, so the
    carrier takes the gate-true branch and its `disjuncts` list is the NON-empty
    interleaving product (the canonical identity interleaving of each side is always a
    member). Hence `(kvE2_sepBody …).holds` is not definitionally `False` and no later
    direction can close vacuously. Rabinovich Prop 4.2 (md:100-101). -/
theorem kvE2_sepBody_nonvacuous {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    (kvE2_sepBody charBase charK qnf).disjuncts ≠ [] := by
  have hgate := kvE2_sepGate_holds_of_honest qnf M w x t hxw hwt h
  simp only [kvE2_sepBody]
  split
  case isTrue _ =>
    apply List.ne_nil_of_mem
    apply List.mem_flatMap.mpr
    refine ⟨kvE2_sepSlotsL qnf,
      List.mem_filter.mpr
        ⟨List.mem_permutations.mpr (List.Perm.refl _), kvE2_sepSlotsL_valid qnf⟩, ?_⟩
    apply List.mem_map.mpr
    exact ⟨kvE2_sepSlotsR qnf,
      List.mem_filter.mpr
        ⟨List.mem_permutations.mpr (List.Perm.refl _), kvE2_sepSlotsR_valid qnf⟩, rfl⟩
  case isFalse hg =>
    exact absurd hgate hg

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
    rw [decide_eq_true hsub.symm, Bool.not_true, Bool.false_or, decide_eq_true_eq] at hle
    omega

/-- The two interior outer classes are distinct (index-0 order bits differ). -/
private theorem kvE2_sep_zWT3_ne_zXW3 : kvE2_sep_zWT3 ≠ kvE2_sep_zXW3 := by
  intro h
  have h0 := congrFun h (0 : Fin 3)
  simp only [kvE2_sep_zWT3, kvE2_sep_zXW3, Fin.cons_zero, Prod.mk.injEq] at h0
  exact Bool.false_ne_true h0.1

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

/-- Arrangement-membership transfer: a slot of some positive σ's canonical block occurs in
    every LEFT interleaving (permutation membership; Lemma 3.2(1), md:77). -/
private theorem kvE2_sep_mem_arrL {sig : MonadicSignature}
    {qnf : NormalForm sig 2 3} {lL : List (KvE2SepSlot sig)}
    (hL : lL ∈ kvE2_sepArrL qnf) {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf)
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2_sepSlotsLFor σ) : s ∈ lL := by
  obtain ⟨hperm, -⟩ := List.mem_filter.mp hL
  exact (List.mem_permutations.mp hperm).mem_iff.mpr
    (List.mem_flatMap.mpr ⟨σ, hσ, hs⟩)

/-- Arrangement-membership transfer, RIGHT side. -/
private theorem kvE2_sep_mem_arrR {sig : MonadicSignature}
    {qnf : NormalForm sig 2 3} {lR : List (KvE2SepSlot sig)}
    (hR : lR ∈ kvE2_sepArrR qnf) {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf)
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2_sepSlotsRFor σ) : s ∈ lR := by
  obtain ⟨hperm, -⟩ := List.mem_filter.mp hR
  exact (List.mem_permutations.mp hperm).mem_iff.mpr
    (List.mem_flatMap.mpr ⟨σ, hσ, hs⟩)

/-- A valid LEFT interleaving is pairwise-ordered under the region-rank relation. -/
private theorem kvE2_sep_arrL_pairwise {sig : MonadicSignature}
    {qnf : NormalForm sig 2 3} {lL : List (KvE2SepSlot sig)}
    (hL : lL ∈ kvE2_sepArrL qnf) :
    lL.Pairwise (fun a b => kvE2_sepSlotLe a b = true) := by
  have hv := (List.mem_filter.mp hL).2
  unfold kvE2_sepValid at hv
  exact of_decide_eq_true hv

/-- A valid RIGHT interleaving is pairwise-ordered under the region-rank relation. -/
private theorem kvE2_sep_arrR_pairwise {sig : MonadicSignature}
    {qnf : NormalForm sig 2 3} {lR : List (KvE2SepSlot sig)}
    (hR : lR ∈ kvE2_sepArrR qnf) :
    lR.Pairwise (fun a b => kvE2_sepSlotLe a b = true) := by
  have hv := (List.mem_filter.mp hR).2
  unfold kvE2_sepValid at hv
  exact of_decide_eq_true hv

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
    (hL : lL ∈ kvE2_sepArrL qnf) (hR : lR ∈ kvE2_sepArrR qnf)
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
      (kvE2_sep_mem_arrL hL hσpos (kvE2_sep_lX1_mem_slotsLFor hzone))
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
        (kvE2_sep_mem_arrL hL hσpos (kvE2_sep_lXU_mem_slotsLFor hzone hbit))
      have hji : jχ < iσ := kvE2_sep_index_lt_of_rank_lt (kvE2_sep_arrL_pairwise hL)
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
      (kvE2_sep_mem_arrR hR hσpos (kvE2_sep_rX1_mem_slotsRFor hzone))
    have hjσm : jσ < (lR.map (kvE2_sepSlotType charBase charK)).length := by
      simp only [List.length_map]; omega
    refine ⟨ws ⟨(lL.map (kvE2_sepSlotType charBase charK)).length + 1 + jσ, by omega⟩,
      hmono _ _ (Fin.mk_lt_mk.mpr (by omega)), (hrange _).2, ?_, ?_⟩
    · have h1 := hpt' ((lL.map (kvE2_sepSlotType charBase charK)).length + 1 + jσ)
        (by omega)
      rwa [kvE2_sep_getElem_right _ _ _ jσ hjσm, List.getElem_map, hgetjσ] at h1
    · intro χ hbit
      obtain ⟨j', hj', hgetj'⟩ := List.mem_iff_getElem.mp
        (kvE2_sep_mem_arrR hR hσpos (kvE2_sep_rWX1_mem_slotsRFor hzone hbit))
      have hji : j' < jσ := kvE2_sep_index_lt_of_rank_lt (kvE2_sep_arrR_pairwise hR)
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
    `kvE2_sepDisjunct_extract`. -/
theorem kvE2_sepBody_extract {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
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
    obtain ⟨lL, hL, lR, hR, hd⟩ := h
    exact kvE2_sepDisjunct_extract charBase charK qnf hL hR M atomMap x t hd
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

/-! ## Phase 11 (N2-A) — singleton carrier wrapper

**Verdict N2 (Phase 10 decision gate):** the correctness pair is closed on the
single-positive-sub fragment — `qnf` with at most one positive sub. Under this restriction
the joint carrier `kvE2_sepBody` degenerates to a single σ's bracket: with one interior
positive there are no cross-σ slots (the exact configuration in which the Phase 9 O4 crux
vanishes). O1 collapses to a *reuse* of the landed `kvE2_sepBody` (D1 — purely additive; the
carrier is NOT re-defined, no interleaving enumeration is introduced). The non-vacuity analog
restates `kvE2_sepBody_nonvacuous` for the wrapper (FM-vac: an honest realization forces the
gate-true branch with a NON-empty disjunct list, so no later direction closes vacuously). -/

/-- The single-positive-sub restriction predicate (Phase 10 verdict N2): at most one positive
    sub. This is the honest antecedent under which Phase 11/12 close the gate — NOT a vacuity
    device (a realizable `qnf` satisfying it is exhibited by `kvE2_sepSingleton_satisfiable`). -/
def kvE2_sepSingleton {sig : MonadicSignature} (qnf : NormalForm sig 2 3) : Prop :=
  ∀ σ σ' : NormalForm sig 1 4, qnf.2 σ = true → qnf.2 σ' = true → σ = σ'

/-- **N2-A singleton carrier wrapper.** A restriction of the landed joint carrier
    `kvE2_sepBody` (reuse of Phase 7's def, per the plan's N2-A choice) — the degeneration is
    a *scope* on the same object, not a new construction. Definitionally equal to
    `kvE2_sepBody` (`kvE2_sepBody_singleton_eq`), so every landed structural lemma
    (`_holds_iff`, `_extract`, `_nonvacuous`) transfers verbatim. -/
noncomputable def kvE2_sepBody_singleton {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) : VVecEA2 :=
  kvE2_sepBody charBase charK qnf

@[simp] theorem kvE2_sepBody_singleton_eq {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) :
    kvE2_sepBody_singleton charBase charK qnf = kvE2_sepBody charBase charK qnf := rfl

/-- **Non-vacuity analog for the singleton wrapper** (FM-vac; fresh analog of
    `kvE2_sepBody_nonvacuous`): a `qnf` arising from an actual model realization under
    `x < w < t` forces the wrapper onto the gate-true branch with a NON-empty disjunct list. -/
theorem kvE2_sepBody_singleton_nonvacuous {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    (kvE2_sepBody_singleton charBase charK qnf).disjuncts ≠ [] :=
  kvE2_sepBody_nonvacuous charBase charK qnf M w x t hxw hwt h

/-! ## Phase 11 (N2-B) — singleton extraction + O4-at-minimum-size + both directions

**Configuration:** one interior positive σ (`kvE2_sepSingleton`), left-interior class
(`nf0_zoneSpec σ.1 = kvE2_sep_zXW3` — the class the landed task-326 kit serves). With a single
σ there are no cross-σ slots, so the Phase-9 O4 residue (a bit required at a CROSS-σ slot point)
has no instances; the derivation reduces to ONE σ against σ's OWN segments.

**Consumed (live inputs):** the landed per-σ closers `kvE_subBracket2V_sound_of_parts`
(`SubBracket2V.lean:1025`) and `kvE_subBracket2V_complete` (`:1465`); the O3 extraction
`kvE2_sepBody_extract` + `kvE2_sepBundleL_parts`; and the Phase-9 derivable core
(`kvE2_sepHgate_offFiber`, `kvE2_sep_zone4_consistent`, `kvE2_sepSegForm_excludes`).

**D3 discipline:** negatives are routed through the depth-2 gate's off-fiber / zone-consistency
clauses (`kvE2_sepGate` clauses (i)/(ii)) ONLY — never a Prop 4.2 pointwise-existence form.

**O4 residue (the make-or-break, isolated as a tracked strategic sorry).** The six-conjunct
per-anchor content that `kvE2_sepSingleton_sound_of_parts_at` (the ∀-anchor dissolver) consumes
is supplied ONLY at the single extracted anchor `x1`. This section derives the carrier-determined
conjuncts directly (conjunct (ii) `w < t`; conjunct (iv) inner off-fiber via
`kvE2_sepHgate_offFiber`; `x1 < w`/`hbelow` from the bundle) and isolates the remaining three —
σ.1's arity-4 base at `[x1,w,x,t]`, the forward-zone conjunct (`SubBracket2V.lean:1873-1877`), and
its backward mate — into the single-anchor `kvE2_sepSingleton_coverage_left`. Even at singleton
size those three require the FULL bracket interval-decomposition coverage of `(x,t)` (every model
point is a σ-own bracket slot, a segment-covered open sub-interval, or an exterior/boundary
endpoint point), which is present in the realized carrier `h` but NOT surfaced by the landed
`kvE2_sepBody_extract` bundle facts. The sorry is a DELIBERATE division boundary (skeleton),
tightly scoped to that one lemma, provable-in-principle from `h`, documented here, and tracked in
the dispatch handoff `sorry_inventory` with a follow-up. -/

/-- **D3 negatives — outer off-fiber** (gate clause (i)): a sub whose atom-layer restriction to
    `[w,x,t]` disagrees with `qnf.1` is negative. The admitted negatives channel (no Prop 4.2
    pointwise form). Sorry-free. -/
theorem kvE2_sepSingleton_neg_offFiber {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (hg : kvE2_sepGate qnf)
    (σ : NormalForm sig 1 4) (hoff : nf0_dropFresh σ.1 ≠ qnf.1) :
    qnf.2 σ = false :=
  hg.1 σ hoff

/-- **D3 negatives — outer inconsistent zone** (gate clause (ii)): a sub whose fresh witness sits
    in an inconsistent outer placement is negative. Sorry-free. -/
theorem kvE2_sepSingleton_neg_zone {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (hg : kvE2_sepGate qnf)
    (σ : NormalForm sig 1 4) (hncons : ¬ kvE2_sepOuterConsistent (nf0_zoneSpec σ.1)) :
    qnf.2 σ = false :=
  hg.2.1 σ hncons

/-- **The joint gate holds whenever the singleton carrier holds** (the extraction pre-step):
    a non-empty `.holds` forces the gate-true branch, since the gate-false branch has empty
    disjuncts (`kvE2_sepBody_gate_fail`) whose `VVecEA2.holds` is `False`. Sorry-free. -/
theorem kvE2_sepBody_singleton_gate {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (x t : M.carrier)
    (h : (kvE2_sepBody_singleton charBase charK qnf).holds M atomMap x t) :
    kvE2_sepGate qnf := by
  by_contra hng
  rw [kvE2_sepBody_singleton_eq, kvE2_sepBody_gate_fail charBase charK qnf hng] at h
  simp [VVecEA2.holds] at h

/-- **N2-B single-anchor coverage for the left-interior singleton σ** (task 321 v7 Phase 11;
    the additive residue consumed by the ∀-anchor dissolver `kvE2_sepSingleton_sound_of_parts_at`).

    From the realized joint carrier `h` — whose bracket carries the refined-conjunction segment
    realizations on every open sub-interval of `(x,t)` (`kvE2_sepSegLForSub`/`kvE2_sepSegRForSub`,
    surfaced through `kvE2_sepDisjunct_halves`) plus the boundary/exterior content in the endpoint
    predicates `kvE2_sepEpL`/`kvE2_sepEpR` — and the single extracted anchor `x1`, produces the
    three carrier-coverage conjuncts AT `x1` (NOT the ∀-anchor form): σ.1's arity-4 base at
    `[x1,w,x,t]` (h_atom), the forward-zone fold-bit forcing (h_fwd), and the backward-zone
    witness realization (h_bwd) — exactly the residue `kvE2_sepSingleton_sound_of_parts_at`
    demands. This REPLACES the second dispatch's ∀-anchor `hgate` assembly, whose conjunct
    `a < w` binds every anchor in `(x,t)` and is therefore FALSE at singleton size (an honest
    model may realize the `charK` anchor above `w`); routing through the single extracted `x1`,
    where `x1 < w` genuinely holds, is the correct wiring.

    STRATEGIC SORRY (skeleton division boundary — five-condition test met: deliberate division,
    tightly scoped to this one lemma, documented, tracked in the dispatch handoff, build-green).
    Provable-in-principle from `h` (the segments/endpoints ARE present in the realized carrier).
    Assumes the singleton bracket's interval-decomposition coverage of `(x,t)`: every model point
    is a σ-own bracket slot (bit-true point type + depth-0 1-type mutual exclusivity), a
    segment-covered open sub-interval (`kvE2_sepSegForm_excludes` on the refined segments, keyed
    by whether σ's fresh slot precedes the cut), or an exterior/boundary point (decoded from the
    endpoint predicates). Deferred because assembling it verified-green requires surfacing the
    currently-discarded bracket segment realizations (a new extraction beyond
    `kvE2_sepBody_extract`), the point→interval location map, the bracket-segment→σ-`segForm`
    refinement, the 1-type exclusivity lemma, the exterior-endpoint decoder, and the h_bwd witness
    construction — jointly exceeding one additive dispatch (verbatim residue goals in the N2-B
    CRUX ADDENDUM-2 below). Follow-up: task 321 Phase 11 N2-B single-anchor coverage; the clean
    uniform route is the out-of-scope bit-compatibility carrier redefinition of
    `kvE2_sepArrL`/`kvE2_sepArrR`. -/
theorem kvE2_sepSingleton_coverage_left {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (hg : kvE2_sepGate qnf)
    (M : OrderedMonadicStructure sig)
    (x t w : M.carrier)
    (σ : NormalForm sig 1 4)
    (hσpos : qnf.2 σ = true)
    (hzone : nf0_zoneSpec σ.1 = kvE2_sep_zXW3)
    (x1 : M.carrier) (hxx1 : x < x1) (hx1w : x1 < w) (hwt : w < t)
    (hpt : (kvE2_sepPtX1L (nf_depth0_char_formula atomMap h_surj) charK σ).eval_at M atomMap x1)
    (h : (kvE2_sepBody (nf_depth0_char_formula atomMap h_surj) charK qnf).holds M atomMap x t) :
    nf_eval_nf M 0 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1 ∧
    (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1),
      (∃ v : M.carrier,
        zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
        nf_eval_nf M 0 1 (fun _ => v) χ) →
      σ.2 (nf0_assemble zs χ σ.1) = true) ∧
    (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1), zs ≠ kvE_sub2_zXU →
      σ.2 (nf0_assemble zs χ σ.1) = true →
      ∃ v : M.carrier,
        zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
        nf_eval_nf M 0 1 (fun _ => v) χ) := by
  sorry

/-- **Single-anchor soundness closer** (task 321 v7 Phase 11 N2-B; the ∀-anchor-obstruction
    dissolver). A mechanical specialization of the landed `kvE_subBracket2V_sound_of_parts`
    (`SubBracket2V.lean:1025`) whose consumed six-conjunct `hgate` is supplied ONLY at the
    single extracted anchor `x1` — not the ∀-anchor form. The landed closer's body uses `hgate`
    only at the extracted anchor (`SubBracket2V.lean:1058`: `obtain … := hgate x1 hxx1 hx1t
    hanchor`), so this specialization is BODY-VERBATIM (lines 1059-1080) with the six-tuple
    passed directly instead of applied from a universally-quantified hypothesis.

    Rationale (Phase 11 N2-B crux, verbatim `lean_goal` below the crux record): the ∀-anchor
    `hgate` that `kvE_subBracket2V_sound_of_parts` demands is UNPROVABLE at singleton size — the
    conjunct `a < w` binds EVERY `a ∈ (x,t)` realizing `charK (nfk_projFresh σ)`, but the
    singleton carrier's right-region content excludes only depth-0 `charBase` 1-types, never the
    depth-1 anchor `charK (nfk_projFresh σ)`, so an honest model may realize the anchor above `w`
    (the Phase-9 SECOND, cross-σ-INDEPENDENT obstruction, `:1636-1642`, which the singleton
    restriction does NOT remove). This closer removes that obstruction by only ever needing the
    six conjuncts at the ONE extracted `x1` (where `x1 < w` genuinely holds). Sorry-free. -/
theorem kvE2_sepSingleton_sound_of_parts_at {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier)
    (x1 : M.carrier)
    (hbelow : ∀ χ : NormalForm sig 0 1,
        σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true →
        ∃ u : M.carrier, x < u ∧ u < x1 ∧
          (⟨nf_depth0_char_formula atomMap h_surj χ⟩ : TemporalPred).eval_at M atomMap u)
    (haw : x1 < w) (hwt : w < t)
    (h_atom : nf_eval_nf M 0 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1)
    (h_off : ∀ τ : NormalForm sig 0 5, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false)
    (h_fwd : ∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1),
        (∃ v : M.carrier,
          zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ) →
        σ.2 (nf0_assemble zs χ σ.1) = true)
    (h_bwd : ∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1), zs ≠ kvE_sub2_zXU →
        σ.2 (nf0_assemble zs χ σ.1) = true →
        ∃ v : M.carrier,
          zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ) :
    ∃ x1' : M.carrier,
      nf_eval_nf M 1 4 (Fin.cons x1' (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  refine ⟨x1, ?_⟩
  rw [nf_eval_depth1_fold_iff]
  refine ⟨h_atom, ?_, h_off⟩
  intro zs χ
  refine ⟨fun hex => h_fwd zs χ hex, ?_⟩
  intro hbit
  by_cases hzs : zs = kvE_sub2_zXU
  · subst hzs
    obtain ⟨u, hxu, hux1, hu⟩ := hbelow χ hbit
    refine ⟨u, ?_, (nfPred_correct M atomMap h_surj χ u).mp hu⟩
    have huw : u < w := hux1.trans haw
    have hut : u < t := huw.trans hwt
    intro i
    match i with
    | ⟨0, _⟩ => exact ⟨iff_of_true hux1 rfl, iff_of_false (lt_asymm hux1) (by decide +revert)⟩
    | ⟨1, _⟩ => exact ⟨iff_of_true huw rfl, iff_of_false (lt_asymm huw) (by decide +revert)⟩
    | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxu) (by decide +revert), iff_of_true hxu rfl⟩
    | ⟨3, _⟩ => exact ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by decide +revert)⟩
  · exact h_bwd zs χ hzs hbit

/-- **Both directions, FORWARD (O5 soundness)** for the left-interior singleton σ: the singleton
    carrier's `.holds` at the fixed endpoints yields σ's depth-1 realization at a shared witness
    `w`. Pipeline: `kvE2_sepBody_extract` (O3) → the pre-`parts` bundle (for the single anchor
    `x1` with `x1 < w`) → the ∀-anchor dissolver `kvE2_sepSingleton_sound_of_parts_at`, with the
    three single-anchor coverage conjuncts supplied by `kvE2_sepSingleton_coverage_left`.
    Rabinovich Cor 5.4 (md:154-157). -/
theorem kvE2_sepBody_singleton_sound_left {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig) (x t : M.carrier)
    (σ : NormalForm sig 1 4)
    (hσpos : qnf.2 σ = true)
    (hzone : nf0_zoneSpec σ.1 = kvE2_sep_zXW3)
    (h : (kvE2_sepBody_singleton (nf_depth0_char_formula atomMap h_surj) charK qnf).holds
        M atomMap x t) :
    ∃ w : M.carrier, x < w ∧ w < t ∧
      ∃ x1 : M.carrier,
        nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  have hg : kvE2_sepGate qnf :=
    kvE2_sepBody_singleton_gate _ charK qnf M atomMap x t h
  rw [kvE2_sepBody_singleton_eq] at h
  obtain ⟨_hepL, _hepR, w, hxw, hwt, _hptW, hbundleL, _hbundleR⟩ :=
    kvE2_sepBody_extract (nf_depth0_char_formula atomMap h_surj) charK qnf M atomMap x t h
  refine ⟨w, hxw, hwt, ?_⟩
  have hmem : σ ∈ kvE2_sepPos qnf := (kvE2_sepPos_mem qnf σ).mpr hσpos
  have hbL := hbundleL σ hmem hzone
  -- Extract the single left-interior anchor `x1` from the pre-`parts` bundle, which STILL
  -- carries `x1 < w` (hx1w) — the fact `kvE2_sepBundleL_parts` drops but the single-anchor
  -- closer `kvE2_sepSingleton_sound_of_parts_at` requires. This dissolves the ∀-anchor
  -- obstruction (second-dispatch N2-B crux): the six conjuncts are supplied ONLY at this `x1`.
  obtain ⟨x1, hxx1, hx1w, hpt, hbelow⟩ := hbL
  have h_off : ∀ τ : NormalForm sig 0 5, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false :=
    kvE2_sepHgate_offFiber qnf hg σ hσpos
  obtain ⟨h_atom, h_fwd, h_bwd⟩ :=
    kvE2_sepSingleton_coverage_left atomMap h_surj charK qnf hg M x t w σ hσpos hzone
      x1 hxx1 hx1w hwt hpt h
  exact kvE2_sepSingleton_sound_of_parts_at atomMap h_surj charK σ M w x t x1 hbelow hx1w hwt
    h_atom h_off h_fwd h_bwd

/-- **Both directions, BACKWARD (O6 completeness)** for the left-interior singleton σ: σ's
    depth-1 realization at a shared witness `w` under the honest order rebuilds the singleton
    carrier's `.holds`. Pipeline: the landed `kvE_subBracket2V_complete` (`:1465`) produces the
    per-σ bracket `.holds`; the singleton-carrier reconstruction lifts it to
    `kvE2_sepBody_singleton`.

    STRATEGIC SORRY (skeleton division boundary): the lift from the per-σ bracket `.holds`
    (`kvE_subBracket2V`) to the joint `kvE2_sepBody` `.holds` at singleton size — constructing the
    single realized disjunct of the degenerate interleaving product. Deferred because that
    construction (the O2 arrangement realization at singleton size) is a self-contained assembly
    outside this dispatch's extraction scope. Follow-up: task 321 Phase 11 N2-B O6 lift (singleton
    disjunct realization). The consumed `kvE_subBracket2V_complete` order/anchor inputs are
    supplied honestly from the realization. -/
theorem kvE2_sepBody_singleton_complete_left {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (hg : kvE2_sepGate qnf)
    (M : OrderedMonadicStructure sig) (x t w : M.carrier)
    (σ : NormalForm sig 1 4)
    (hσpos : qnf.2 σ = true)
    (hsingle : kvE2_sepSingleton qnf)
    (h : ∃ x1 : M.carrier,
        nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    (kvE2_sepBody_singleton (nf_depth0_char_formula atomMap h_surj) charK qnf).holds
      M atomMap x t := by
  sorry

end Bimodal.Metalogic.WeakCanonical.Kamp
