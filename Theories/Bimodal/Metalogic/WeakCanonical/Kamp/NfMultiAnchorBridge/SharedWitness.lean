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

/-- **Interior-restricted owner index** (task 342 Part I). The positive subs whose fresh
    point `x1` lies in one of the two INTERIOR outer zones (`x < x1 < w`, `w < x1 < t`).
    Rabinovich §5 (p.7) ψ0/ψ1/φ split: interiority is a construction invariant of φ — the
    interleaving index ranges over bracket witnesses only — never a hypothesis on realized
    types. A SINGLE two-zone order-preserving filter of `kvE2_sepPos` (the `kvE2_sepPosIn`
    pattern), so global enumeration order, `Nodup`, and the `zipIdx`/membership transfer
    machinery are inherited; a member's interiority is recovered definitionally via
    `List.mem_filter` (`kvE2_sepPosI_mem`), never hypothesized. -/
noncomputable def kvE2_sepPosI {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) : List (NormalForm sig 1 4) :=
  (kvE2_sepPos qnf).filter
    (fun σ => decide (nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3))

/-- Membership in the interior index = positivity + the interiority disjunction. -/
theorem kvE2_sepPosI_mem {sig : MonadicSignature} (qnf : NormalForm sig 2 3)
    (σ : NormalForm sig 1 4) :
    σ ∈ kvE2_sepPosI qnf ↔ σ ∈ kvE2_sepPos qnf ∧
      (nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3) := by
  simp [kvE2_sepPosI, List.mem_filter]

/-- Interior owners are positive owners. -/
theorem kvE2_sepPosI_subset {sig : MonadicSignature} {qnf : NormalForm sig 2 3}
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPosI qnf) : σ ∈ kvE2_sepPos qnf :=
  ((kvE2_sepPosI_mem qnf σ).mp hσ).1

/-- Interior owners are interior (the definitional recovery of the interiority
    disjunction — this replaces, and never resurrects, any interiority hypothesis). -/
theorem kvE2_sepPosI_zone {sig : MonadicSignature} {qnf : NormalForm sig 2 3}
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPosI qnf) :
    nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3 :=
  ((kvE2_sepPosI_mem qnf σ).mp hσ).2

/-- The interior index is duplicate-free: filtering preserves the `kvE2_sepPos` `Nodup`
    fact (itself a filter of the duplicate-free `Finset.univ.toList`; the file's private
    `kvE2_sepPos_nodup` states the intermediate step). -/
theorem kvE2_sepPosI_nodup {sig : MonadicSignature} (qnf : NormalForm sig 2 3) :
    (kvE2_sepPosI qnf).Nodup :=
  ((Finset.nodup_toList _).filter _ : (kvE2_sepPos qnf).Nodup).filter _

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
    the conjunction's witness multiset between `x` and the shared `w`).
    Task 342 Phase 2 (deliberate): stays mapping over `kvE2_sepPos`, NOT `kvE2_sepPosI` —
    semantically equivalent since non-interior owners contribute `[]`
    (`kvE2_sepPosI_flatMap_slotsLFor`); report 07 sanctions either anchor and the
    conservative diff is smaller. -/
noncomputable def kvE2_sepSlotsL {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) : List (KvE2SepSlot sig) :=
  (kvE2_sepPos qnf).flatMap kvE2_sepSlotsLFor

/-- Canonical joint RIGHT slot list (between the shared `w` and `t`). Stays over
    `kvE2_sepPos` (see `kvE2_sepSlotsL` — task 342 Phase 2 deliberate choice). -/
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
    positive owners). The `Fin N` domain of the per-slot value-rank family `G` (Phase 6).
    Task 342 Phase 2: re-anchored to flatMap over the interior index `kvE2_sepPosI` — the
    VALUE is unchanged (`kvE2_sepAllSlots_eq_pos`; non-interior owners contribute empty
    blocks), but the enumeration now ranges over bracket witnesses only, matching the
    Rabinovich §5 (p.7) interleaving-index scope. NOT defeq to the old body — proofs that
    decomposed the family over `kvE2_sepPos` repair by the one rewrite
    `kvE2_sepAllSlots_eq_pos`. -/
noncomputable def kvE2_sepAllSlots {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) : List (KvE2SepSlot sig) :=
  (kvE2_sepPosI qnf).flatMap kvE2_sepSlotBlock

/-- **Global per-individual-slot position** (Phase 6 `slotIndexOf`): the 0-based index of slot `s`
    in the full slot family. When `kvE2_sepAllSlots` is `Nodup` (see `kvE2_sepAllSlots_nodup`) this
    is a genuine injection on the family's members — the structural (model-independent) index the
    lex value-rank family `G` uses in its second coordinate. -/
noncomputable def kvE2_sepSlotIndexOf {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (s : KvE2SepSlot sig) : ℕ :=
  (kvE2_sepAllSlots qnf).idxOf s

/-- Block membership splits over the two region blocks. -/
theorem kvE2_sepMem_slotBlock {sig : MonadicSignature} (σ : NormalForm sig 1 4)
    (s : KvE2SepSlot sig) :
    s ∈ kvE2_sepSlotBlock σ ↔ s ∈ kvE2_sepSlotsLFor σ ∨ s ∈ kvE2_sepSlotsRFor σ := by
  rw [kvE2_sepSlotBlock, List.mem_append]

/-! ### Interior-index transfer foundation (task 342 Phase 1)

Non-interior owners contribute EMPTY slot blocks (the `else []` branches of
`kvE2_sepSlotsLFor`/`kvE2_sepSlotsRFor`), so flatMapping any slot-family builder over the
interior index `kvE2_sepPosI` yields the SAME VALUE as over the full `kvE2_sepPos`. The
equality is provable, not definitional — the `kvE2_sepPosI_flatMap_*` lemmas below are the
one-rewrite repair tool for the re-anchoring phases (task 342 Phases 2-4). -/

/-- Non-interior owners have no LEFT-region slots (the `else []` branch). -/
theorem kvE2_sepSlotsLFor_eq_nil {sig : MonadicSignature} {σ : NormalForm sig 1 4}
    (h1 : nf0_zoneSpec σ.1 ≠ kvE2_sep_zXW3) (h2 : nf0_zoneSpec σ.1 ≠ kvE2_sep_zWT3) :
    kvE2_sepSlotsLFor σ = [] := by
  rw [kvE2_sepSlotsLFor, if_neg h1, if_neg h2]

/-- Non-interior owners have no RIGHT-region slots (the `else []` branch). -/
theorem kvE2_sepSlotsRFor_eq_nil {sig : MonadicSignature} {σ : NormalForm sig 1 4}
    (h1 : nf0_zoneSpec σ.1 ≠ kvE2_sep_zXW3) (h2 : nf0_zoneSpec σ.1 ≠ kvE2_sep_zWT3) :
    kvE2_sepSlotsRFor σ = [] := by
  rw [kvE2_sepSlotsRFor, if_neg h1, if_neg h2]

/-- Non-interior owners have an empty slot block. -/
theorem kvE2_sepSlotBlock_eq_nil {sig : MonadicSignature} {σ : NormalForm sig 1 4}
    (h1 : nf0_zoneSpec σ.1 ≠ kvE2_sep_zXW3) (h2 : nf0_zoneSpec σ.1 ≠ kvE2_sep_zWT3) :
    kvE2_sepSlotBlock σ = [] := by
  rw [kvE2_sepSlotBlock, kvE2_sepSlotsLFor_eq_nil h1 h2, kvE2_sepSlotsRFor_eq_nil h1 h2]
  rfl

/-- A nonempty LEFT block forces interiority: a positive owner exhibiting a LEFT-region
    slot is a member of the interior index (contrapositive of the `else []` branches). -/
theorem kvE2_sepMem_posI_of_slotL {sig : MonadicSignature} {qnf : NormalForm sig 2 3}
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
theorem kvE2_sepMem_posI_of_slotR {sig : MonadicSignature} {qnf : NormalForm sig 2 3}
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
theorem kvE2_sepMem_posI_of_slot {sig : MonadicSignature} {qnf : NormalForm sig 2 3}
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

/-- **Key value-transfer lemma** (task 342 Phase 1): the full slot family over the interior
    index has the SAME VALUE as over all positive owners — non-interior owners contribute
    empty blocks. Not defeq: re-anchoring phases repair broken `rfl`/unfold proofs by this
    one rewrite. -/
theorem kvE2_sepPosI_flatMap_slotBlock {sig : MonadicSignature} (qnf : NormalForm sig 2 3) :
    (kvE2_sepPosI qnf).flatMap kvE2_sepSlotBlock
      = (kvE2_sepPos qnf).flatMap kvE2_sepSlotBlock := by
  rw [kvE2_sepPosI]
  refine kvE2_sep_flatMap_filter_of_vanish _ _ (fun σ _ hp => ?_)
  rw [decide_eq_false_iff_not, not_or] at hp
  exact kvE2_sepSlotBlock_eq_nil hp.1 hp.2

/-- LEFT-region value transfer: `kvE2_sepSlotsL`-shaped flatMaps re-anchor by one rewrite. -/
theorem kvE2_sepPosI_flatMap_slotsLFor {sig : MonadicSignature} (qnf : NormalForm sig 2 3) :
    (kvE2_sepPosI qnf).flatMap kvE2_sepSlotsLFor
      = (kvE2_sepPos qnf).flatMap kvE2_sepSlotsLFor := by
  rw [kvE2_sepPosI]
  refine kvE2_sep_flatMap_filter_of_vanish _ _ (fun σ _ hp => ?_)
  rw [decide_eq_false_iff_not, not_or] at hp
  exact kvE2_sepSlotsLFor_eq_nil hp.1 hp.2

/-- RIGHT-region value transfer. -/
theorem kvE2_sepPosI_flatMap_slotsRFor {sig : MonadicSignature} (qnf : NormalForm sig 2 3) :
    (kvE2_sepPosI qnf).flatMap kvE2_sepSlotsRFor
      = (kvE2_sepPos qnf).flatMap kvE2_sepSlotsRFor := by
  rw [kvE2_sepPosI]
  refine kvE2_sep_flatMap_filter_of_vanish _ _ (fun σ _ hp => ?_)
  rw [decide_eq_false_iff_not, not_or] at hp
  exact kvE2_sepSlotsRFor_eq_nil hp.1 hp.2

/-- **Universal re-anchoring repair tool** (task 342 Phase 2): the re-anchored slot family
    has the SAME VALUE as the old full-`kvE2_sepPos` flatMap. Every proof that decomposed
    `kvE2_sepAllSlots` over the full positive-owner list repairs by this one rewrite. -/
theorem kvE2_sepAllSlots_eq_pos {sig : MonadicSignature} (qnf : NormalForm sig 2 3) :
    kvE2_sepAllSlots qnf = (kvE2_sepPos qnf).flatMap kvE2_sepSlotBlock := by
  rw [kvE2_sepAllSlots, kvE2_sepPosI_flatMap_slotBlock]

/-- A slot of a positive owner's block is a member of the full slot family. The hypothesis
    stays over `kvE2_sepPos` (existing call sites compile unchanged): the slot itself forces
    interiority via `kvE2_sepMem_posI_of_slot`. -/
theorem kvE2_sepMem_allSlots {sig : MonadicSignature} (qnf : NormalForm sig 2 3)
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf)
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2_sepSlotBlock σ) :
    s ∈ kvE2_sepAllSlots qnf :=
  List.mem_flatMap.mpr ⟨σ, kvE2_sepMem_posI_of_slot hσ hs, hs⟩

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
  exact (kvE2_sepPosI_nodup qnf).imp (fun hne => kvE2_sep_blocks_disjoint hne)

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

/-- Refined-conjunction segment type for the left region at cut `i`.
    Task 342 Phase 2 (deliberate): stays mapping over `kvE2_sepPos`, NOT `kvE2_sepPosI` —
    semantically equivalent since non-interior owners contribute `⊤` conjuncts (the
    `else Formula.top` branches), but the anchors differ SYNTACTICALLY at the formula
    level, so re-anchoring would perturb formula-shape equalities for no semantic gain;
    report 07 sanctions either anchor and the conservative diff is smaller. -/
noncomputable def kvE2_sepSegLAt {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (qnf : NormalForm sig 2 3)
    (lL : List (KvE2SepSlot sig)) (i : Nat) : TemporalPred :=
  ⟨formula_conjList ((kvE2_sepPos qnf).map (kvE2_sepSegLForSub charBase lL i))⟩

/-- Refined-conjunction segment type for the right region at cut `j`. Stays over
    `kvE2_sepPos` (see `kvE2_sepSegLAt` — task 342 Phase 2 deliberate choice). -/
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
    the cartesian `foldr` product over the INTERIOR owner index `kvE2_sepPosI qnf` (task 342
    Phase 3 re-anchoring: the interleaving index ranges over bracket witnesses only — the §5
    (p.7) ψ0/ψ1/φ split makes interiority a construction invariant of φ; Lemma 3.2(1) states
    the closure without printed proof), with the tuple component ranging over
    `kvE2_sepIdxTuples n` (`n = |allSlots|`). Finite, terminating, `decide`-able. Enumerating
    index tuples alongside tags is what makes two differently-interleaving models yield DISTINCT
    weak orders; the order-CONSISTENCY of the tuple (per-owner `i₀<i₁<i₂` and cross-owner `Nodup`)
    is the cross-owner conjunct of `kvE2_sepDisjValid`. Replaces the abandoned `kvE2_sepArrL/R`
    carrier. -/
noncomputable def kvE2_sepOrderTypes {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) : List (KvE2SepWeakOrder sig) :=
  let n := (kvE2_sepAllSlots qnf).length
  (kvE2_sepPosI qnf).foldr
    (fun σ acc =>
      kvE2_sepSpikeOrderTypes.flatMap (fun tag =>
        (kvE2_sepIdxTuplesN n (kvE2_sepSlotBlock σ).length).flatMap
          (fun t => acc.map (fun wo => (σ, tag, t) :: wo))))
    [[]]

/-- σ's canonical (model) placement tag, read from its realized outer zone class. -/
noncomputable def kvE2_sepModelTag {sig : MonadicSignature}
    (σ : NormalForm sig 1 4) : KvE2SepSpikeOrderType :=
  if nf0_zoneSpec σ.1 = kvE2_sep_zXW3 then .strictBefore else .strictAfter

/-- The model weak order: each INTERIOR positive owner (task 342 Phase 3: the enumeration
    ranges over the interior index `kvE2_sepPosI`, matching `kvE2_sepOrderTypes`) tagged with its
    canonical zone-class placement AND its rank = its index in `kvE2_sepPosI` (via `zipIdx`, so
    the ranks are `0,1,…,n-1` — distinct, hence order-consistent). The strict per-owner tags
    remain honestly-undischargeable (the genuine Rabinovich `r_0=z_0` asymmetry, SW:1421-1429),
    so this stays a conditional disjunct. -/
noncomputable def kvE2_sepModelOrder {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) : KvE2SepWeakOrder sig :=
  (kvE2_sepPosI qnf).zipIdx.map
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

/-! ### Task 342 Phase 6 — tie-admitting validity infrastructure

The tie-collapse mechanism is forced by Def 3.1 (p.4: a single STRICT witness chain with free
variables pinned `z_k = x_{i_k}` and conjunction semantics); Lemma 3.2(1) states the closure
without printed proof; corroborated by the k=m split (p.7) and Def 7.5 (p.13). Tie classes are
INDEX-LEVEL DATA ONLY: they live in the weak order's payload tuples, and every emitted disjunct
remains a strict Def-3.1 bracket — one slot per tie class with a conjoined point type
(strict-quotient guard; the grouped builder is task 342 Phase 7). Admissible tie classes are
base-base and base-foreign-anchor within a region. Anchor-anchor ties are EXCLUDED by the
anchor-distinct conjunct below — a Lean-side, machine-checked pruning justified by the task-340
Phase 5A keystone `nf_eval_unique` route (distinct positive owners provably cannot share a fresh
anchor, so anchor-anchor tie order types are honestly unrealizable); this pruning has NO
Rabinovich counterpart (audit note D7). -/

/-- **Closed-zone leaf at a FOREIGN base type** (task 342 Phase 6): the foreign-type
    generalization of `kvE2_sepClosedLeafStub` — the anchor owner σ's CLOSED self-zone bit read
    at an arbitrary base type `χ` (its own fresh type is the `nf0_projFresh σ.1` instance,
    `kvE2_sepClosedLeafStub_eq_at`). LEFT-interior owners read the CLOSED `zAtX1L` bit; every
    other placement reads the CLOSED `zAtX1R` bit. F5: this is a CLOSED self-zone key read at
    the foreign base type — no OPEN key enters any coincident read. This is the validity read a
    base-anchor tie class imposes (the honest discharge at the foreign type is task 342
    Phase 8). -/
def kvE2_sepClosedLeafAt {sig : MonadicSignature}
    (σ : NormalForm sig 1 4) (χ : NormalForm sig 0 1) : Bool :=
  if nf0_zoneSpec σ.1 = kvE2_sep_zXW3 then
    kvE2_sepBits σ kvE2_sep_zAtX1L χ
  else
    kvE2_sepBits σ kvE2_sep_zAtX1R χ

/-- The forward stub is the own-fresh-type instance of the foreign-type leaf read. -/
theorem kvE2_sepClosedLeafStub_eq_at {sig : MonadicSignature} (σ : NormalForm sig 1 4) :
    kvE2_sepClosedLeafStub σ = kvE2_sepClosedLeafAt σ (nf0_projFresh σ.1) := rfl

/-- A slot is a fresh-witness ANCHOR slot (`lX1`/`rX1`) — the slot kinds whose payload index
    participates in the anchor-distinct conjunct. -/
def kvE2_sepSlotIsAnchor {sig : MonadicSignature} : KvE2SepSlot sig → Bool
  | .lX1 _ => true
  | .rX1 _ => true
  | _ => false

/-- The base type carried by a 1-type (base) slot; `none` for the anchor slots. -/
def kvE2_sepSlotBaseType {sig : MonadicSignature} :
    KvE2SepSlot sig → Option (NormalForm sig 0 1)
  | .lXU _ χ => some χ
  | .lX1 _ => none
  | .lUW _ χ => some χ
  | .lWT _ χ => some χ
  | .rXW _ χ => some χ
  | .rWX1 _ χ => some χ
  | .rX1 _ => none
  | .rX1T _ χ => some χ

/-- Anchor slots carry no base type. -/
theorem kvE2_sepSlotBaseType_eq_none_of_isAnchor {sig : MonadicSignature}
    {s : KvE2SepSlot sig} (h : kvE2_sepSlotIsAnchor s = true) :
    kvE2_sepSlotBaseType s = none := by
  cases s <;> simp_all [kvE2_sepSlotIsAnchor, kvE2_sepSlotBaseType]

/-- σ's fresh-anchor slot, by placement: `.lX1 σ` for a LEFT-interior owner, `.rX1 σ`
    otherwise. -/
def kvE2_sepAnchorSlot {sig : MonadicSignature} (σ : NormalForm sig 1 4) : KvE2SepSlot sig :=
  if nf0_zoneSpec σ.1 = kvE2_sep_zXW3 then .lX1 σ else .rX1 σ

/-- The anchor slot is owned by σ. -/
theorem kvE2_sepSlotSub_anchorSlot {sig : MonadicSignature} (σ : NormalForm sig 1 4) :
    kvE2_sepSlotSub (kvE2_sepAnchorSlot σ) = σ := by
  rw [kvE2_sepAnchorSlot]; split <;> rfl

/-- The anchor-slot family is injective (the slot constructor carries its owner). -/
theorem kvE2_sepAnchorSlot_injective {sig : MonadicSignature}
    {σ τ : NormalForm sig 1 4} (h : kvE2_sepAnchorSlot σ = kvE2_sepAnchorSlot τ) : σ = τ := by
  have := congrArg kvE2_sepSlotSub h
  rwa [kvE2_sepSlotSub_anchorSlot, kvE2_sepSlotSub_anchorSlot] at this

/-- An INTERIOR owner's anchor slot is a member of its slot block (the `.lX1`/`.rX1` entry of
    `kvE2_sepSlotsLFor`/`kvE2_sepSlotsRFor`). -/
theorem kvE2_sepAnchorSlot_mem_block {sig : MonadicSignature} {σ : NormalForm sig 1 4}
    (hzone : nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3) :
    kvE2_sepAnchorSlot σ ∈ kvE2_sepSlotBlock σ := by
  rw [kvE2_sepMem_slotBlock]
  rcases hzone with hz | hz
  · left
    rw [kvE2_sepAnchorSlot, if_pos hz, kvE2_sepSlotsLFor, if_pos hz]
    exact List.mem_append.mpr (Or.inr List.mem_cons_self)
  · right
    have hne : nf0_zoneSpec σ.1 ≠ kvE2_sep_zXW3 :=
      fun hc => kvE2_sep_zWT3_ne_zXW3 (hz.symm.trans hc)
    rw [kvE2_sepAnchorSlot, if_neg hne, kvE2_sepSlotsRFor, if_neg hne, if_pos hz]
    exact List.mem_append.mpr (Or.inr List.mem_cons_self)

/-- **Anchor payload projection** (task 342 Phase 6): the owner's ANCHOR-slot payload index,
    read from its per-slot tuple at the anchor's structural block position. Purely structural
    (`kvE2_sepBlockPos` is a syntactic `idxOf`); reads no zone bit, no model data
    (F4/F5/LITMUS clean). -/
noncomputable def kvE2_sepAnchorPayload {sig : MonadicSignature}
    (p : NormalForm sig 1 4 × KvE2SepSpikeOrderType × List ℕ) : ℕ :=
  p.2.2.getD (kvE2_sepBlockPos (kvE2_sepAnchorSlot p.1)) 0

/-- Reading the anchor payload off a `block.map g` payload returns `g` at the anchor slot
    (interior owners only — the anchor slot must be a block member). -/
theorem kvE2_sepAnchorPayload_map {sig : MonadicSignature} (g : KvE2SepSlot sig → ℕ)
    {σ : NormalForm sig 1 4} (tag : KvE2SepSpikeOrderType)
    (hzone : nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3) :
    kvE2_sepAnchorPayload (σ, tag, (kvE2_sepSlotBlock σ).map g)
      = g (kvE2_sepAnchorSlot σ) := by
  have hmem := kvE2_sepAnchorSlot_mem_block hzone
  have hlt : (kvE2_sepSlotBlock σ).idxOf (kvE2_sepAnchorSlot σ)
      < (kvE2_sepSlotBlock σ).length := List.idxOf_lt_length_of_mem hmem
  have hpos : kvE2_sepBlockPos (kvE2_sepAnchorSlot σ)
      = (kvE2_sepSlotBlock σ).idxOf (kvE2_sepAnchorSlot σ) := by
    rw [kvE2_sepBlockPos, kvE2_sepSlotSub_anchorSlot]
  rw [kvE2_sepAnchorPayload, hpos]
  rw [kvE2_sepBlockMap_getD σ g ⟨_, hlt⟩, List.idxOf_get]

/-- **Anchor-distinct conjunct (iii')** (task 342 Phase 6): the cross-owner ANCHOR payload
    indices are pairwise distinct. This is what remains of the old global-`Nodup` conjunct
    after ties are admitted: base slots may tie freely (with each other and with foreign
    anchors), but two ANCHORS never coincide. D7 (Lean-side pruning, no paper counterpart):
    the exclusion is justified by the task-340 Phase 5A keystone route (`nf_eval_unique` —
    distinct positive owners provably cannot share a fresh anchor), so anchor-anchor order
    types are honestly unrealizable and dropping them preserves completeness; soundness is
    untouched (fewer disjuncts). Reads no zone bit (abstract ℕ `Nodup`; F4/F5/LITMUS clean). -/
noncomputable def kvE2_sepAnchorDistinct {sig : MonadicSignature}
    (wo : KvE2SepWeakOrder sig) : Bool :=
  decide (wo.map kvE2_sepAnchorPayload).Nodup

/-- **Tie-class validity conjunct (iv)** (task 342 Phase 6): every payload tie involving an
    ANCHOR slot imposes the anchor owner's CLOSED-key read at the tied base slot's type — for
    each pair of slot occurrences with equal payload values where the first is the anchor slot
    of owner `σa` and the second is a base slot of type `χ` (foreign or own), the disjunct is
    admitted only when `kvE2_sepClosedLeafAt σa χ = true`. Base-base tie classes impose NO read
    (F5-clean by construction); anchor-anchor ties are already excluded by (iii'), and each
    class contains at most one anchor slot for the same reason. F5: the only key entering this
    read path is the CLOSED `zAtX1L`/`zAtX1R` self-zone key (via `kvE2_sepClosedLeafAt`) — no
    OPEN key enters any coincident read. Forced by Def 3.1 (p.4); Lemma 3.2(1) states the
    closure without printed proof; corroborated by the k=m split (p.7) and Def 7.5 (p.13). -/
noncomputable def kvE2_sepTieRead {sig : MonadicSignature}
    (wo : KvE2SepWeakOrder sig) : Bool :=
  wo.all fun p =>
    wo.all fun q =>
      (kvE2_sepSlotBlock p.1).zipIdx.all fun sj =>
        (kvE2_sepSlotBlock q.1).zipIdx.all fun sk =>
          if kvE2_sepSlotIsAnchor sj.1 && decide (p.2.2.getD sj.2 0 = q.2.2.getD sk.2 0) then
            match kvE2_sepSlotBaseType sk.1 with
            | some χ => kvE2_sepClosedLeafAt p.1 χ
            | none => true
          else true

/-- **Shared tie-conjunct discharge under a globally-`Nodup` payload** (task 342 Phase 6): for
    any weak order of the canonical `zipIdx`-map shape whose per-owner payload is `block.map g`
    with `g` globally duplicate-free over the slot family, BOTH new conjuncts hold — (iii')
    because the anchor payloads are a sub-selection of the duplicate-free family image, and
    (iv) vacuously because equal payload values force equal slots (all tie classes are
    singletons). This is the ONE repair lemma the three membership theorems share: their
    payloads (`kvE2_sepSlotIndexOf`, `kvE2_sepSlotHonestGIdx`) are globally `Nodup` (banked:
    `kvE2_sepAllSlots_map_slotIndexOf_nodup` / `_honestGIdx_nodup`). -/
theorem kvE2_sepValid_tie_of_nodup {sig : MonadicSignature} (qnf : NormalForm sig 2 3)
    (tagf : NormalForm sig 1 4 → KvE2SepSpikeOrderType) (g : KvE2SepSlot sig → ℕ)
    (hnd : ((kvE2_sepAllSlots qnf).map g).Nodup) :
    kvE2_sepAnchorDistinct ((kvE2_sepPosI qnf).zipIdx.map
        (fun p => (p.1, tagf p.1, (kvE2_sepSlotBlock p.1).map g))) = true ∧
      kvE2_sepTieRead ((kvE2_sepPosI qnf).zipIdx.map
        (fun p => (p.1, tagf p.1, (kvE2_sepSlotBlock p.1).map g))) = true := by
  have ginj := List.inj_on_of_nodup_map hnd
  constructor
  · -- (iii') anchor-distinct: anchor payloads are `g` at the (injective) anchor family.
    rw [kvE2_sepAnchorDistinct, decide_eq_true_eq, List.map_map]
    have hcongr : ((kvE2_sepPosI qnf).zipIdx.map
          (kvE2_sepAnchorPayload ∘
            (fun p => (p.1, tagf p.1, (kvE2_sepSlotBlock p.1).map g))))
        = (kvE2_sepPosI qnf).zipIdx.map (fun p => g (kvE2_sepAnchorSlot p.1)) := by
      apply List.map_congr_left
      intro p hp
      exact kvE2_sepAnchorPayload_map g (tagf p.1)
        (kvE2_sepPosI_zone (List.fst_mem_of_mem_zipIdx hp))
    rw [hcongr]
    have hfst : (kvE2_sepPosI qnf).zipIdx.map (fun p => g (kvE2_sepAnchorSlot p.1))
        = (kvE2_sepPosI qnf).map (fun σ => g (kvE2_sepAnchorSlot σ)) := by
      conv_rhs => rw [← List.zipIdx_map_fst 0 (kvE2_sepPosI qnf)]
      rw [List.map_map]
      rfl
    rw [hfst]
    have hposI : (kvE2_sepPosI qnf).Nodup :=
      List.Nodup.filter _ (List.Nodup.filter _ (Finset.nodup_toList _))
    refine List.Nodup.map_on (fun σ hσ τ hτ heq => ?_) hposI
    have hσa := kvE2_sepAnchorSlot_mem_block (kvE2_sepPosI_zone hσ)
    have hτa := kvE2_sepAnchorSlot_mem_block (kvE2_sepPosI_zone hτ)
    exact kvE2_sepAnchorSlot_injective
      (ginj (kvE2_sepMem_allSlots qnf (kvE2_sepPosI_subset hσ) hσa)
        (kvE2_sepMem_allSlots qnf (kvE2_sepPosI_subset hτ) hτa) heq)
  · -- (iv) tie-read: vacuous — equal `g`-values force equal slots (singleton classes).
    rw [kvE2_sepTieRead, List.all_eq_true]
    intro p hp
    rw [List.all_eq_true]
    intro q hq
    obtain ⟨p', hp', rfl⟩ := List.mem_map.mp hp
    obtain ⟨q', hq', rfl⟩ := List.mem_map.mp hq
    rw [List.all_eq_true]
    intro sj hsj
    rw [List.all_eq_true]
    intro sk hsk
    obtain ⟨hjlt, hjeq⟩ := List.getElem?_eq_some_iff.mp
      (List.mem_zipIdx_iff_getElem?.mp hsj)
    obtain ⟨hklt, hkeq⟩ := List.getElem?_eq_some_iff.mp
      (List.mem_zipIdx_iff_getElem?.mp hsk)
    split
    case isTrue hcond =>
      rw [Bool.and_eq_true, decide_eq_true_eq] at hcond
      obtain ⟨hanchor, heq⟩ := hcond
      have hread1 : ((kvE2_sepSlotBlock p'.1).map g).getD sj.2 0
          = g ((kvE2_sepSlotBlock p'.1).get ⟨sj.2, hjlt⟩) :=
        kvE2_sepBlockMap_getD p'.1 g ⟨sj.2, hjlt⟩
      have hread2 : ((kvE2_sepSlotBlock q'.1).map g).getD sk.2 0
          = g ((kvE2_sepSlotBlock q'.1).get ⟨sk.2, hklt⟩) :=
        kvE2_sepBlockMap_getD q'.1 g ⟨sk.2, hklt⟩
      simp only [List.get_eq_getElem, hjeq, hkeq] at hread1 hread2
      rw [hread1, hread2] at heq
      have hjm : sj.1 ∈ kvE2_sepSlotBlock p'.1 := hjeq ▸ List.getElem_mem hjlt
      have hkm : sk.1 ∈ kvE2_sepSlotBlock q'.1 := hkeq ▸ List.getElem_mem hklt
      have hslots : sj.1 = sk.1 :=
        ginj (kvE2_sepMem_allSlots qnf
            (kvE2_sepPosI_subset (List.fst_mem_of_mem_zipIdx hp')) hjm)
          (kvE2_sepMem_allSlots qnf
            (kvE2_sepPosI_subset (List.fst_mem_of_mem_zipIdx hq')) hkm) heq
      rw [← hslots, kvE2_sepSlotBaseType_eq_none_of_isAnchor hanchor]
    case isFalse => rfl

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

/-- **Per-disjunct validity** (faithful replacement of the additive `kvE2_sepValid`; task 342
    Phase 6: tie-admitting): a weak order is valid iff (i) every per-owner placement is admitted
    by the owner's arrangement-appropriate zone bit (the per-order-type read, F5), (ii) every
    owner's per-slot global-index tuple EXTENDS its region order (`kvE2_sepConsistentBlock`, the
    task-340 linear-extension conjunct), (iii') the cross-owner ANCHOR payload indices are
    pairwise distinct (`kvE2_sepAnchorDistinct` — D7: a Lean-side `nf_eval_unique`-certified
    pruning of the honestly-unrealizable anchor-anchor ties, no paper counterpart), AND (iv)
    every base-anchor payload tie is admitted by the anchor owner's CLOSED-key read at the tied
    base type (`kvE2_sepTieRead`; base-base ties impose no read). The former conjunct (iii) —
    global `Nodup` over the flattened payload — is GONE: it made the Lemma 3.2(1) equality-case
    order types unrepresentable (honest base-base slot ties and base-foreign-anchor ties realized
    NO disjunct at all — a machine-certified completeness hole). Ties are INDEX-LEVEL data only:
    each emitted disjunct remains a strict Def-3.1 bracket, one slot per tie class (strict-quotient
    guard; the grouped builder is Phase 7). Forced by Def 3.1 (p.4); Lemma 3.2(1) states the
    closure without printed proof; corroborated by the k=m split (p.7) and Def 7.5 (p.13). The
    consistency conjunct (ii) is what makes the a<u'<b cross-region interleaving admissible while
    keeping each owner's own slots region-ordered. Reads no zone bit in (ii)/(iii'); (iv) reads
    ONLY the CLOSED `zAtX1L`/`zAtX1R` self-zone keys (F5). NOT an additive filter over a flat
    slot union. -/
noncomputable def kvE2_sepDisjValid {sig : MonadicSignature}
    (_qnf : NormalForm sig 2 3) (wo : KvE2SepWeakOrder sig) : Bool :=
  wo.all (fun p => kvE2_sepDisjValidOwner p.1 p.2.1)
    && wo.all (fun p => kvE2_sepConsistentBlock p.1 p.2.2)
    && kvE2_sepAnchorDistinct wo
    && kvE2_sepTieRead wo

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
    (fun σ => (kvE2_sepSlotBlock σ).map (kvE2_sepSlotIndexOf qnf)) (kvE2_sepPosI qnf) 0
    (fun σ hσ => ?_)
  have h := kvE2_sepIdxTupleN_mem_of_forall_lt (kvE2_sepAllSlots qnf).length
    ((kvE2_sepSlotBlock σ).map (kvE2_sepSlotIndexOf qnf)) (fun y hy => by
      obtain ⟨s, hs, rfl⟩ := List.mem_map.mp hy
      exact kvE2_sepSlotIndexOf_lt qnf (kvE2_sepMem_allSlots qnf (kvE2_sepPosI_subset hσ) hs))
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
    on the enumeration index, where `wo.map Prod.fst = kvE2_sepPosI qnf` — task 342 Phase 3). -/
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

/-! ### Task 342 Phase 6 — tie-class grouping

Grouping the wo-sorted joint slot lists into maximal runs of equal merge key
(`kvE2_sepSlotGIdx wo` — the wo-payload index). On the `mergeSort`ed lists equal keys are
adjacent, so adjacent runs ARE the tie classes. Tie classes are INDEX-LEVEL data: the Phase-7
grouped builder emits ONE strict bracket slot per class with the conjoined point type
`formula_conjList (class.map (kvE2_sepSlotType charBase charK))` — the strict-quotient guard.
Forced by Def 3.1 (p.4: single strict witness chain, free variables pinned, conjunction
semantics); Lemma 3.2(1) states the closure without printed proof; corroborated by the k=m
split (p.7) and Def 7.5 (p.13). -/

/-- **Adjacent-run grouping kernel** (task 342 Phase 6, house pattern — this toolchain's
    `List.splitBy` ships without lemma support): groups a list into maximal runs of adjacent
    elements with equal `key`. On a key-sorted list (the only use site) the runs are exactly
    the key's equivalence classes. Structural recursion; abstract over the element type
    (reads no zone bit, no model data). -/
def kvE2_sepTieRuns {α : Type*} (key : α → ℕ) : List α → List (List α)
  | [] => []
  | [a] => [[a]]
  | a :: b :: rest =>
    match kvE2_sepTieRuns key (b :: rest) with
    | [] => [[a]]
    | c :: cs => if key a = key b then (a :: c) :: cs else [a] :: c :: cs

/-- Structural shape: grouping a cons yields a first run headed by the head element. -/
theorem kvE2_sepTieRuns_shape {α : Type*} (key : α → ℕ) :
    ∀ (l : List α) (x : α), ∃ t cs, kvE2_sepTieRuns key (x :: l) = (x :: t) :: cs
  | [], _ => ⟨[], [], rfl⟩
  | b :: rest, x => by
    obtain ⟨t, cs, heq⟩ := kvE2_sepTieRuns_shape key rest b
    by_cases hk : key x = key b
    · exact ⟨b :: t, cs, by rw [kvE2_sepTieRuns, heq]; simp only [if_pos hk]⟩
    · exact ⟨[], (b :: t) :: cs, by rw [kvE2_sepTieRuns, heq]; simp only [if_neg hk]⟩

/-- **Round trip**: flattening the tie classes returns the (sorted) input list — the grouping
    is a partition, losing and duplicating nothing. -/
theorem kvE2_sepTieRuns_flatten {α : Type*} (key : α → ℕ) :
    ∀ (l : List α), (kvE2_sepTieRuns key l).flatten = l
  | [] => rfl
  | [_] => rfl
  | a :: b :: rest => by
    have ih := kvE2_sepTieRuns_flatten key (b :: rest)
    obtain ⟨t, cs, heq⟩ := kvE2_sepTieRuns_shape key rest b
    rw [heq] at ih
    by_cases hk : key a = key b
    · rw [kvE2_sepTieRuns, heq]
      simp only [if_pos hk]
      simpa using ih
    · rw [kvE2_sepTieRuns, heq]
      simp only [if_neg hk]
      simpa using ih

/-- Every tie class is nonempty (each run is headed by an actual element). -/
theorem kvE2_sepTieRuns_ne_nil {α : Type*} (key : α → ℕ) :
    ∀ (l : List α), ∀ c ∈ kvE2_sepTieRuns key l, c ≠ []
  | [] => by simp [kvE2_sepTieRuns]
  | [a] => by simp [kvE2_sepTieRuns]
  | a :: b :: rest => by
    have ih := kvE2_sepTieRuns_ne_nil key (b :: rest)
    obtain ⟨t, cs, heq⟩ := kvE2_sepTieRuns_shape key rest b
    rw [heq] at ih
    intro c hc
    rw [kvE2_sepTieRuns, heq] at hc
    by_cases hk : key a = key b
    · simp only [if_pos hk] at hc
      rcases List.mem_cons.mp hc with rfl | h
      · exact List.cons_ne_nil _ _
      · exact ih c (List.mem_cons_of_mem _ h)
    · simp only [if_neg hk] at hc
      rcases List.mem_cons.mp hc with rfl | h
      · exact List.cons_ne_nil _ _
      · exact ih c h

/-- **Nodup keys ⟹ all classes are singletons**: when the key family is duplicate-free over
    the list, the grouping degenerates to the singleton partition — the tie-free case, under
    which the Phase-7 grouped builder coincides with the flat builder. -/
theorem kvE2_sepTieRuns_of_nodup {α : Type*} (key : α → ℕ) :
    ∀ (l : List α), (l.map key).Nodup → kvE2_sepTieRuns key l = l.map (fun a => [a])
  | [], _ => rfl
  | [_], _ => rfl
  | a :: b :: rest, hnd => by
    rw [List.map_cons, List.nodup_cons] at hnd
    have hne : key a ≠ key b := fun hc => hnd.1 (by
      rw [List.map_cons]
      exact hc ▸ List.mem_cons_self)
    have ih := kvE2_sepTieRuns_of_nodup key (b :: rest) hnd.2
    obtain ⟨t, cs, heq⟩ := kvE2_sepTieRuns_shape key rest b
    calc kvE2_sepTieRuns key (a :: b :: rest)
        = [a] :: kvE2_sepTieRuns key (b :: rest) := by
          rw [kvE2_sepTieRuns, heq]
          simp only [if_neg hne]
      _ = [a] :: (b :: rest).map (fun a => [a]) := by rw [ih]
      _ = (a :: b :: rest).map (fun a => [a]) := rfl

/-- **LEFT tie-class grouping** (task 342 Phase 6): the wo-sorted joint LEFT slot list grouped
    into maximal runs of equal wo-payload index (`kvE2_sepSlotGIdx wo`, the merge key). Equal
    keys are adjacent on the `mergeSort`ed list, so the runs are the tie classes. Consumed by
    the Phase-7 grouped disjunct builder: one strict bracket slot per class (strict-quotient
    guard — ties collapse the index, never the bracket). -/
noncomputable def kvE2_sepTieGroupedL {sig : MonadicSignature}
    (wo : KvE2SepWeakOrder sig) : List (List (KvE2SepSlot sig)) :=
  kvE2_sepTieRuns (kvE2_sepSlotGIdx wo) (kvE2_sepSlotsLOf wo)

/-- **RIGHT tie-class grouping** (right mirror of `kvE2_sepTieGroupedL`). -/
noncomputable def kvE2_sepTieGroupedR {sig : MonadicSignature}
    (wo : KvE2SepWeakOrder sig) : List (List (KvE2SepSlot sig)) :=
  kvE2_sepTieRuns (kvE2_sepSlotGIdx wo) (kvE2_sepSlotsROf wo)

/-- Round trip: the LEFT tie classes flatten back to the wo-sorted LEFT slot list. -/
theorem kvE2_sepTieGroupedL_flatten {sig : MonadicSignature} (wo : KvE2SepWeakOrder sig) :
    (kvE2_sepTieGroupedL wo).flatten = kvE2_sepSlotsLOf wo :=
  kvE2_sepTieRuns_flatten _ _

/-- Round trip: the RIGHT tie classes flatten back to the wo-sorted RIGHT slot list. -/
theorem kvE2_sepTieGroupedR_flatten {sig : MonadicSignature} (wo : KvE2SepWeakOrder sig) :
    (kvE2_sepTieGroupedR wo).flatten = kvE2_sepSlotsROf wo :=
  kvE2_sepTieRuns_flatten _ _

/-- Every LEFT tie class is nonempty. -/
theorem kvE2_sepTieGroupedL_ne_nil {sig : MonadicSignature} (wo : KvE2SepWeakOrder sig) :
    ∀ c ∈ kvE2_sepTieGroupedL wo, c ≠ [] :=
  kvE2_sepTieRuns_ne_nil _ _

/-- Every RIGHT tie class is nonempty. -/
theorem kvE2_sepTieGroupedR_ne_nil {sig : MonadicSignature} (wo : KvE2SepWeakOrder sig) :
    ∀ c ∈ kvE2_sepTieGroupedR wo, c ≠ [] :=
  kvE2_sepTieRuns_ne_nil _ _

/-- Nodup payload ⟹ every LEFT tie class is a singleton (the tie-free degenerate case). -/
theorem kvE2_sepTieGroupedL_of_nodup {sig : MonadicSignature} (wo : KvE2SepWeakOrder sig)
    (hnd : ((kvE2_sepSlotsLOf wo).map (kvE2_sepSlotGIdx wo)).Nodup) :
    kvE2_sepTieGroupedL wo = (kvE2_sepSlotsLOf wo).map (fun s => [s]) :=
  kvE2_sepTieRuns_of_nodup _ _ hnd

/-- Nodup payload ⟹ every RIGHT tie class is a singleton (the tie-free degenerate case). -/
theorem kvE2_sepTieGroupedR_of_nodup {sig : MonadicSignature} (wo : KvE2SepWeakOrder sig)
    (hnd : ((kvE2_sepSlotsROf wo).map (kvE2_sepSlotGIdx wo)).Nodup) :
    kvE2_sepTieGroupedR wo = (kvE2_sepSlotsROf wo).map (fun s => [s]) :=
  kvE2_sepTieRuns_of_nodup _ _ hnd

/-! ### Task 342 Phase 7 — meet-folded grouped disjunct builder

One STRICT bracket slot per tie class (the strict-quotient guard): a class's point type is
the CONJUNCTION (meet) of its members' slot types; segments reuse the flat per-cut refined
conjunctions evaluated at the flat prefix (segments already meet-fold across all owners per
cut — Phase 4 finding — so tie folding is point-type grouping + cut reindexing ONLY). Ties
collapse the INDEX, never the bracket: the emitted disjunct is a strict Def-3.1 bracket and
`IntervalPattern.holds` strictness is untouched. Forced by Def 3.1 (p.4: single strict
witness chain, free variables pinned, conjunction semantics); Lemma 3.2(1) states the
closure without printed proof; corroborated by the k=m split (p.7) and Def 7.5 (p.13). -/

/-- **Meet-folded point type of one tie class**: the conjunction of the members' slot types.
    A tie is ONE slot whose point realizes every tied type — never two slots with a weakened
    order (Def 3.1 conjunction semantics, p.4). -/
noncomputable def kvE2_sepClassType {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (c : List (KvE2SepSlot sig)) : TemporalPred :=
  ⟨formula_conjList (c.map (fun s => (kvE2_sepSlotType charBase charK s).formula))⟩

/-- Class-point evaluation: the meet-folded class type is realized iff EVERY member's slot
    type is realized at the point (conjunction semantics). -/
theorem kvE2_sepClassType_eval_iff {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (c : List (KvE2SepSlot sig))
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (y : M.carrier) :
    (kvE2_sepClassType charBase charK c).eval_at M atomMap y ↔
      ∀ s ∈ c, (kvE2_sepSlotType charBase charK s).eval_at M atomMap y := by
  simp only [kvE2_sepClassType, TemporalPred.eval_at]
  rw [formula_conjList_iff]
  constructor
  · intro hall s hs
    exact hall _ (List.mem_map_of_mem hs)
  · intro hall f hf
    obtain ⟨s, hs, rfl⟩ := List.mem_map.mp hf
    exact hall s hs

/-- **Per-class evaluation helper** (the one extraction-side deliverable owed to the 337
    re-plan): a realized meet-folded class point realizes EACH member's slot type. -/
theorem kvE2_sepClassType_eval_mem {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    {c : List (KvE2SepSlot sig)}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (y : M.carrier)
    (h : (kvE2_sepClassType charBase charK c).eval_at M atomMap y)
    {s : KvE2SepSlot sig} (hs : s ∈ c) :
    (kvE2_sepSlotType charBase charK s).eval_at M atomMap y :=
  (kvE2_sepClassType_eval_iff charBase charK c M atomMap y).mp h s hs

/-- Singleton-class evaluation: the meet of one slot type eval-equals the slot type
    (`formula_conjList [f]` is `f ∧ ⊤`, not `f` — eval-level only, never syntactic). -/
theorem kvE2_sepClassType_singleton_eval {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (s : KvE2SepSlot sig)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (y : M.carrier) :
    (kvE2_sepClassType charBase charK [s]).eval_at M atomMap y ↔
      (kvE2_sepSlotType charBase charK s).eval_at M atomMap y := by
  rw [kvE2_sepClassType_eval_iff]
  exact List.forall_mem_singleton

/-- Flattening the singleton partition returns the list (the tie-free degenerate shape). -/
private theorem kvE2_sep_flatten_map_singleton {α : Type*} (l : List α) :
    (l.map (fun a => [a])).flatten = l := by
  induction l with
  | nil => rfl
  | cons a t ih => simp [ih]

/-- **Grouped segment dispatcher** (task 342 Phase 7): cut `i` of the grouped LEFT list
    reuses the EXISTING flat per-cut refined conjunction at the flat prefix — the segment at
    grouped cut `i` is `kvE2_sepSegLAt` on `gL.flatten` at flat cut
    `((gL.take i).flatten).length` (segments between two members of one tie class disappear
    with the slot; segments already meet-fold across all owners per cut, so tie folding is
    point-type grouping + cut reindexing ONLY — no new segment machinery). Right mirror with
    the same boundary convention as `kvE2_sepSegs`. -/
noncomputable def kvE2_sepSegsG {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (qnf : NormalForm sig 2 3)
    (gL gR : List (List (KvE2SepSlot sig))) (i : Nat) : TemporalPred :=
  if i ≤ gL.length then
    kvE2_sepSegLAt charBase qnf gL.flatten ((gL.take i).flatten).length
  else
    kvE2_sepSegRAt charBase qnf gR.flatten ((gR.take (i - gL.length - 1)).flatten).length

/-- On the singleton partition the grouped dispatcher agrees with the flat dispatcher at
    every bracket-relevant cut (singleton prefixes flatten to length exactly `i`). -/
private theorem kvE2_sepSegsG_map_singleton {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (qnf : NormalForm sig 2 3)
    (lL lR : List (KvE2SepSlot sig)) (i : Nat) (hi : i ≤ lL.length + 1 + lR.length) :
    kvE2_sepSegsG charBase qnf (lL.map (fun s => [s])) (lR.map (fun s => [s])) i
      = kvE2_sepSegs charBase qnf lL lR i := by
  rw [kvE2_sepSegsG, kvE2_sepSegs]
  by_cases hle : i ≤ lL.length
  · rw [if_pos (by simpa using hle), if_pos hle,
      kvE2_sep_flatten_map_singleton, ← List.map_take, kvE2_sep_flatten_map_singleton,
      List.length_take]
    congr 1
    omega
  · rw [if_neg (by simpa using hle), if_neg hle,
      kvE2_sep_flatten_map_singleton, ← List.map_take, kvE2_sep_flatten_map_singleton,
      List.length_take, List.length_map]
    congr 1
    omega

/-- **Meet-folded grouped joint disjunct builder** (task 342 Phase 7; TOP-LEVEL per the crux
    failed-closer-3 lesson — no let-buried builders). One STRICT Def-3.1 bracket slot per
    tie class: the class point type is the meet `kvE2_sepClassType` of its members' slot
    types, the shared `ptW` and both endpoint predicates are unchanged, `kvE2_sepBracketN`
    is consumed AS-IS (generic over point-type lists), and segments ride the grouped
    dispatcher `kvE2_sepSegsG`. STRICT-QUOTIENT GUARD: tie classes are index-level data
    only — ties collapse the index, never the bracket, and `IntervalPattern.holds`
    strictness is untouched. Forced by Def 3.1 (p.4); Lemma 3.2(1) states the closure
    without printed proof; corroborated by the k=m split (p.7) and Def 7.5 (p.13). -/
noncomputable def kvE2_sepDisjunct' {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (gL gR : List (List (KvE2SepSlot sig))) : Σ n, VecEA2 n :=
  ⟨(gL.map (kvE2_sepClassType charBase charK)).length + 1
      + (gR.map (kvE2_sepClassType charBase charK)).length,
   { endpointLeft := kvE2_sepEpL charBase charK qnf
     endpointRight := kvE2_sepEpR charBase charK qnf
     bracket := kvE2_sepBracketN
       (gL.map (kvE2_sepClassType charBase charK))
       (kvE2_sepPtW charBase charK qnf)
       (gR.map (kvE2_sepClassType charBase charK))
       (kvE2_sepSegsG charBase qnf gL gR) }⟩

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

/-- Every `wo` in the enumeration index has owner-projection exactly the interior index
    `kvE2_sepPosI qnf` (task 342 Phase 3 re-anchoring). -/
theorem kvE2_sepOrderTypes_owners {sig : MonadicSignature} (qnf : NormalForm sig 2 3)
    {wo : KvE2SepWeakOrder sig} (hwo : wo ∈ kvE2_sepOrderTypes qnf) :
    wo.map Prod.fst = kvE2_sepPosI qnf := by
  rw [kvE2_sepOrderTypes] at hwo
  exact kvE2_sepOrderTypes_owners_aux' _ _ hwo

/-- Every INTERIOR positive owner appears in the wo-ordered owner list (rank-reordering
    permutes, never drops, the owner multiset): the membership fact the `kvE2_sepBody_extract`
    rewire consumes. A consumer holding only `σ ∈ kvE2_sepPos` plus a slot recovers the
    interior membership via `kvE2_sepMem_posI_of_slot` (nonempty blocks force interiority). -/
theorem kvE2_sepMem_orderOwners {sig : MonadicSignature} (qnf : NormalForm sig 2 3)
    {wo : KvE2SepWeakOrder sig} (hwo : wo ∈ kvE2_sepOrderTypes qnf)
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPosI qnf) :
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
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPosI qnf)
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2_sepSlotsLFor σ) :
    s ∈ kvE2_sepSlotsLOf wo := by
  rw [kvE2_sepSlotsLOf]
  exact (List.mergeSort_perm _ _).mem_iff.mpr
    (List.mem_flatMap.mpr ⟨σ, kvE2_sepMem_orderOwners qnf hwo hσ, hs⟩)

/-- **Point-level merge membership** (task 339, RIGHT mirror of `kvE2_sepSlotsLOf_mem`). -/
theorem kvE2_sepSlotsROf_mem {sig : MonadicSignature} (qnf : NormalForm sig 2 3)
    {wo : KvE2SepWeakOrder sig} (hwo : wo ∈ kvE2_sepOrderTypes qnf)
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPosI qnf)
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
          -- Task 342 Phase 7: meet-folded GROUPED disjuncts — one strict bracket slot per tie
          -- class (`kvE2_sepTieGroupedL/R wo`, the index-level tie classes), point type = the
          -- meet of the tied slot types (`kvE2_sepDisjunct'`). On a Nodup payload the groups
          -- are singletons and the disjunct agrees with the flat per-slot builder
          -- (`kvE2_sepDisjunct'_map_singleton_iff`). Strict-quotient guard: ties collapse the
          -- index, never the bracket.
          (kvE2_sepArr' qnf).map fun wo =>
            kvE2_sepDisjunct' charBase charK qnf
              (kvE2_sepTieGroupedL wo) (kvE2_sepTieGroupedR wo) })
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
        (kvE2_sepDisjunct' charBase charK qnf
          (kvE2_sepTieGroupedL wo) (kvE2_sepTieGroupedR wo)).2.holds M atomMap x t := by
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
    obtain ⟨u, hxu, _huw, hux1, hrel⟩ := hbelowXU χ (List.mem_filter.mp hχ).2
    exact ⟨u, hxu, hux1, hrel⟩
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

-- REMOVED (task 333 Phase 1 / R1): the dead conditional non-vacuity lemma
-- `kvE2_sepBody_nonvacuous`. Its hypothesis `hvalid : kvE2_sepDisjValid qnf (kvE2_sepModelOrder
-- qnf) = true` is NOT honestly attainable (the strict `kvE2_sepModelOrder` reads σ's OPEN
-- `zXU`/`zUW` bits at σ's own fresh type, FALSE at self-coincidence; the honest disjunct is the
-- coincidence order `kvE2_sepCoincidentOrder`). It had zero live consumers and is superseded by the
-- unconditional `kvE2_sepBody_complete` (this file). See plan 04, Phase 1.

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
    ((kvE2_sepPosI qnf).zipIdx.map
        (fun p => (p.1, g p.1, (kvE2_sepSlotBlock p.1).map f))).flatMap (fun p => p.2.2)
      = (kvE2_sepAllSlots qnf).map f := by
  rw [kvE2_sepAllSlots]; exact kvE2_sepZip_flatMap_aux g f (kvE2_sepPosI qnf) 0

/-- The honest COINCIDENCE (tie) arrangement: every positive owner placed at its own fresh anchor
    (Lemma 3.2(1) coincidence disjunct, md:77; §5 meet, md:168-173). -/
noncomputable def kvE2_sepCoincidentOrder {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) : KvE2SepWeakOrder sig :=
  (kvE2_sepPosI qnf).zipIdx.map
    (fun p => (p.1, KvE2SepSpikeOrderType.coincident,
      (kvE2_sepSlotBlock p.1).map (kvE2_sepSlotIndexOf qnf)))

/-- The coincidence arrangement is present in the enumeration index (F2, structural level): the
    all-coincident tag assignment with consecutive `zipIdx` ranks is reachable in the cartesian
    rank×tag enumeration (a `kvE2_sepOrderTypes_mem_aux` instance, `s = 0`). UNCONDITIONAL
    (task 342 Phase 4): both the order's `zipIdx` carrier and the enumeration fold range over
    the interior index `kvE2_sepPosI` — no owner-index coincidence hypothesis. -/
theorem kvE2_sepCoincidentOrder_mem_orderTypes {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) :
    kvE2_sepCoincidentOrder qnf ∈ kvE2_sepOrderTypes qnf := by
  rw [kvE2_sepCoincidentOrder, kvE2_sepOrderTypes]
  refine kvE2_sepOrderTypes_mem_aux' (fun _ => KvE2SepSpikeOrderType.coincident) _
    (fun σ => (kvE2_sepSlotBlock σ).map (kvE2_sepSlotIndexOf qnf)) (kvE2_sepPosI qnf) 0
    (fun σ hσ => ?_)
  have h := kvE2_sepIdxTupleN_mem_of_forall_lt (kvE2_sepAllSlots qnf).length
    ((kvE2_sepSlotBlock σ).map (kvE2_sepSlotIndexOf qnf)) (fun y hy => by
      obtain ⟨s, hs, rfl⟩ := List.mem_map.mp hy
      exact kvE2_sepSlotIndexOf_lt qnf
        (kvE2_sepMem_allSlots qnf (kvE2_sepPosI_subset hσ) hs))
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

/-! ### Task 342 Phase 8 (a) — F5 foreign-base CLOSED-key discharges

A base-anchor tie class reads the anchor owner's CLOSED self-zone bit at the FOREIGN base
type (`kvE2_sepClosedLeafAt`, Phase 6). The discharges below prove that read TRUE whenever
the foreign base type is honestly realized AT the anchor point — the tie-class situation
(equal honest values). **F5**: the only keys entering any coincident read are the CLOSED
`kvE2_sep_zAtX1L`/`kvE2_sep_zAtX1R` self-zone keys, routed through the preserved axiom-clean
coincidence discharges `kvE2_sepCoincidentAnchor_discharge` (LEFT) / `_R` (RIGHT) — no OPEN
key is read. Grounding: Rabinovich §5 (p.7) — the ψ₀/ψ₁/φ split routes non-interior
witnesses to atomic E[Σ] endpoint literals via Prop 3.5, and the shared-anchor meet-type
identification (md:168-173) makes the coincidence a DISCHARGED disjunct, never a refuted
inequality. Tie-collapse is forced by Def 3.1 (p.4); Lemma 3.2(1) states the closure
without printed proof; corroborated by the k=m split (p.7) and Def 7.5 (p.13). -/

/-- **Foreign-base CLOSED-key discharge, placement-dispatched** (task 342 Phase 8 (a)): for
    an INTERIOR owner σ realized at its anchor `a = x1_σ` (LEFT `x < x1_σ < w` or RIGHT
    `w < x1_σ < t`, recovered definitionally from the interior index `kvE2_sepPosI` — never
    hypothesized), any base type `χ` realized AT the anchor discharges σ's CLOSED self-zone
    leaf read at the foreign type: `kvE2_sepClosedLeafAt σ χ = true`. LEFT owners route
    through `kvE2_sepCoincidentAnchor_discharge` (CLOSED `zAtX1L` key); RIGHT owners through
    `_R` (CLOSED `zAtX1R` key). The anchor's own order bounds are read off σ's realized
    ordering channel (`nf0_zoneSpec`), never a formula literal (LITMUS). F5: no OPEN key
    enters this read. -/
theorem kvE2_sepClosedLeafAt_discharge {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    {σ : NormalForm sig 1 4} (hσI : σ ∈ kvE2_sepPosI qnf)
    (a : M.carrier)
    (hσ : nf_eval_nf M 1 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (χ : NormalForm sig 0 1)
    (hp : nf_eval_nf M 0 1 (fun _ => a) χ) :
    kvE2_sepClosedLeafAt σ χ = true := by
  obtain ⟨hσ_atom, -, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hσ
  rcases kvE2_sepPosI_zone hσI with hzone | hzone
  · -- LEFT-interior: x < x1_σ < w from σ's own realized ordering channel.
    have hbit_aw : (nf0_zoneSpec σ.1 ⟨0, by omega⟩).1 = true := by
      rw [congrFun hzone ⟨0, by omega⟩]; decide
    have hbit_xa : (nf0_zoneSpec σ.1 ⟨1, by omega⟩).2 = true := by
      rw [congrFun hzone ⟨1, by omega⟩]; decide
    have haw : a < w := by
      have h1 := hσ_atom (.order 0 (Fin.succ ⟨0, by omega⟩) (Fin.succ_ne_zero ⟨0, by omega⟩).symm)
      simp only [atom_eval, Fin.cons] at h1
      exact h1.mpr hbit_aw
    have hxa : x < a := by
      have h1 := hσ_atom (.order (Fin.succ ⟨1, by omega⟩) 0 (Fin.succ_ne_zero ⟨1, by omega⟩))
      simp only [atom_eval, Fin.cons] at h1
      exact h1.mpr hbit_xa
    rw [kvE2_sepClosedLeafAt, if_pos hzone]
    exact kvE2_sepCoincidentAnchor_discharge σ M a w x t hxa haw hwt hσ χ hp
  · -- RIGHT-interior: w < x1_σ < t (mirror; CLOSED `zAtX1R` key).
    have hbit_wa : (nf0_zoneSpec σ.1 ⟨0, by omega⟩).2 = true := by
      rw [congrFun hzone ⟨0, by omega⟩]; decide
    have hbit_at : (nf0_zoneSpec σ.1 ⟨2, by omega⟩).1 = true := by
      rw [congrFun hzone ⟨2, by omega⟩]; decide
    have hwa : w < a := by
      have h1 := hσ_atom (.order (Fin.succ ⟨0, by omega⟩) 0 (Fin.succ_ne_zero ⟨0, by omega⟩))
      simp only [atom_eval, Fin.cons] at h1
      exact h1.mpr hbit_wa
    have hat : a < t := by
      have h1 := hσ_atom (.order 0 (Fin.succ ⟨2, by omega⟩) (Fin.succ_ne_zero ⟨2, by omega⟩).symm)
      simp only [atom_eval, Fin.cons] at h1
      exact h1.mpr hbit_at
    rw [kvE2_sepClosedLeafAt,
      if_neg (fun hcon => kvE2_sep_zWT3_ne_zXW3 (hzone.symm.trans hcon))]
    exact kvE2_sepCoincidentAnchor_discharge_R σ M a w x t hxw hwa hat hσ χ hp

/-- **Tie-read intro rule** (task 342 Phase 8 (a)): conjunct (iv) holds once every
    anchor-involved payload tie is discharged at its partner's base type. Base-base tie
    classes impose NO read — machine-checked here: a non-anchor first slot short-circuits
    the guard (`isFalse` branch), and an anchor partner (`kvE2_sepSlotBaseType = none`)
    closes by the `none` match arm. Only `(anchor, base-χ)` pairs ever reach the CLOSED-key
    read (F5): the sole obligation forwarded to `hdis` is `kvE2_sepClosedLeafAt p.1 χ`. -/
theorem kvE2_sepTieRead_of_discharge {sig : MonadicSignature}
    (wo : KvE2SepWeakOrder sig)
    (hdis : ∀ p ∈ wo, ∀ q ∈ wo,
      ∀ sj ∈ (kvE2_sepSlotBlock p.1).zipIdx, ∀ sk ∈ (kvE2_sepSlotBlock q.1).zipIdx,
        kvE2_sepSlotIsAnchor sj.1 = true → p.2.2.getD sj.2 0 = q.2.2.getD sk.2 0 →
        ∀ χ, kvE2_sepSlotBaseType sk.1 = some χ → kvE2_sepClosedLeafAt p.1 χ = true) :
    kvE2_sepTieRead wo = true := by
  rw [kvE2_sepTieRead, List.all_eq_true]
  intro p hp
  rw [List.all_eq_true]
  intro q hq
  rw [List.all_eq_true]
  intro sj hsj
  rw [List.all_eq_true]
  intro sk hsk
  split
  case isTrue hcond =>
    rw [Bool.and_eq_true, decide_eq_true_eq] at hcond
    cases hbt : kvE2_sepSlotBaseType sk.1 with
    | some χ => exact hdis p hp q hq sj hsj sk hsk hcond.1 hcond.2 χ hbt
    | none => rfl
  case isFalse _ => rfl

/-- **Lemma 3.2(1) ⇐ (completeness) — `kvE2_sepBody_complete`** (task 334 Phase 8; generalized to
    right-interior owners in task 336; made UNCONDITIONAL in task 342 Part I). For an honest model
    realization, the honest COINCIDENCE (tie) arrangement is a VALID, PRESENT member of the
    faithful carrier `kvE2_sepArr'`; hence the carrier is NON-VACUOUS (`kvE2_sepArr' qnf ≠ []`) —
    the ⇐ direction of Lemma 3.2(1) (md:77): every honest arrangement selects its order-type
    disjunct (here the coincidence disjunct, §5 meet, md:168-173). The per-owner `rcases`
    dispatches each owner to its placement-appropriate closed-self-zone validator: LEFT →
    `kvE2_sepCoincidentOwner_valid_left` (`zAtX1L` bit, `kvE2_sepCoincidentAnchor_discharge`);
    RIGHT → `kvE2_sepCoincidentOwner_valid_right` (`zAtX1R` bit,
    `kvE2_sepCoincidentAnchor_discharge_R`), both routed through the placement-guarded
    `kvE2_sepClosedLeafStub`. Sorry-free, axiom-clean. Faithfulness: F2 (⇐ realized, non-vacuous),
    F1, F5 (closed vs open key discrimination), F6.

    Interiority is a CONSTRUCTION INVARIANT, not a hypothesis: the arrangement's owner index is
    the interior-restricted carrier `kvE2_sepPosI`, so each owner's placement — LEFT
    (`nf0_zoneSpec σ.1 = kvE2_sep_zXW3`, `x < x1 < w`) OR RIGHT (`kvE2_sep_zWT3`, `w < x1 < t`) —
    is recovered definitionally via `kvE2_sepPosI_zone` (`List.mem_filter`). Rabinovich §5 (p.7):
    the ψ0/ψ1/φ split routes non-interior positive witnesses to the atomic `E[Σ]` endpoint
    literals via Prop 3.5, so only interior owners enter the interleaving; an interiority
    hypothesis has no paper counterpart, and `kvE2_sepHonest_hLR_absurd` certifies that the
    former `hLR` hypothesis was inconsistent with every honest evaluation. -/
theorem kvE2_sepBody_complete {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    kvE2_sepArr' qnf ≠ [] := by
  apply List.ne_nil_of_mem (a := kvE2_sepCoincidentOrder qnf)
  rw [kvE2_sepArr', List.mem_filter]
  refine ⟨kvE2_sepCoincidentOrder_mem_orderTypes qnf, ?_⟩
  rw [kvE2_sepDisjValid, Bool.and_eq_true, Bool.and_eq_true, Bool.and_eq_true]
  refine ⟨⟨⟨?_, ?_⟩, ?_⟩, ?_⟩
  · -- (i) per-owner closed-self-zone validity, dispatched by placement (definitional
    -- interiority via `kvE2_sepPosI_zone` — a construction invariant of the owner index).
    rw [List.all_eq_true]
    intro p hp
    rw [kvE2_sepCoincidentOrder, List.mem_map] at hp
    obtain ⟨⟨σ, i⟩, hmem, rfl⟩ := hp
    have hσmem : σ ∈ kvE2_sepPosI qnf := List.fst_mem_of_mem_zipIdx hmem
    -- `p.2.1 = .coincident`, so `kvE2_sepDisjValidOwner p.1 p.2.1 = kvE2_sepClosedLeafStub σ`.
    show kvE2_sepDisjValidOwner σ KvE2SepSpikeOrderType.coincident = true
    rcases kvE2_sepPosI_zone hσmem with hzone | hzone
    · exact kvE2_sepCoincidentOwner_valid_left qnf M w x t hxw hwt h σ
        (kvE2_sepPosI_subset hσmem) hzone
    · exact kvE2_sepCoincidentOwner_valid_right qnf M w x t hxw hwt h σ
        (kvE2_sepPosI_subset hσmem) hzone
  · -- (ii) per-owner region-scoped consistency: the prefix-sum payload extends each region order.
    rw [List.all_eq_true]
    intro p hp
    rw [kvE2_sepCoincidentOrder, List.mem_map] at hp
    obtain ⟨⟨σ, k⟩, hmem, rfl⟩ := hp
    have hσmem : σ ∈ kvE2_sepPosI qnf := List.fst_mem_of_mem_zipIdx hmem
    exact kvE2_sepConsistentBlock_slotIndexOf qnf (kvE2_sepPosI_subset hσmem)
  · -- (iii') anchor-distinct: from the globally-Nodup prefix-sum payload.
    rw [kvE2_sepCoincidentOrder]
    exact (kvE2_sepValid_tie_of_nodup qnf (fun _ => KvE2SepSpikeOrderType.coincident)
      (kvE2_sepSlotIndexOf qnf) (kvE2_sepAllSlots_map_slotIndexOf_nodup qnf)).1
  · -- (iv) tie-class reads: vacuous — all classes are singletons under the global Nodup.
    rw [kvE2_sepCoincidentOrder]
    exact (kvE2_sepValid_tie_of_nodup qnf (fun _ => KvE2SepSpikeOrderType.coincident)
      (kvE2_sepSlotIndexOf qnf) (kvE2_sepAllSlots_map_slotIndexOf_nodup qnf)).2

/-- **Phase 1 (task 337) — the honest coincidence witness is a carrier member.** Factored from
    `kvE2_sepBody_complete`'s membership route: under an honest realization the COINCIDENCE
    arrangement `kvE2_sepCoincidentOrder qnf` (all-coincident tags, `zipIdx` ranks) is a VALID,
    PRESENT member of `kvE2_sepArr' qnf` — the ⇐-direction witness weak order this task's
    `.holds` builder plugs into `kvE2_sepBody_holds_iff.mpr`. UNCONDITIONAL (task 342 Part I):
    owner interiority is a construction invariant of the `kvE2_sepPosI` index (Rabinovich §5,
    p.7 — the ψ0/ψ1/φ split routes non-interior witnesses to the endpoint literals via Prop 3.5),
    recovered via `kvE2_sepPosI_zone`, never hypothesized. Additive; edits no carrier declaration.
    F5: validity reads only CLOSED self-zone bits (via the coincidence validators). -/
theorem kvE2_sepCoincidentOrder_mem_arr' {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    kvE2_sepCoincidentOrder qnf ∈ kvE2_sepArr' qnf := by
  rw [kvE2_sepArr', List.mem_filter]
  refine ⟨kvE2_sepCoincidentOrder_mem_orderTypes qnf, ?_⟩
  rw [kvE2_sepDisjValid, Bool.and_eq_true, Bool.and_eq_true, Bool.and_eq_true]
  refine ⟨⟨⟨?_, ?_⟩, ?_⟩, ?_⟩
  · rw [List.all_eq_true]
    intro p hp
    rw [kvE2_sepCoincidentOrder, List.mem_map] at hp
    obtain ⟨⟨σ, i⟩, hmem, rfl⟩ := hp
    have hσmem : σ ∈ kvE2_sepPosI qnf := List.fst_mem_of_mem_zipIdx hmem
    show kvE2_sepDisjValidOwner σ KvE2SepSpikeOrderType.coincident = true
    rcases kvE2_sepPosI_zone hσmem with hzone | hzone
    · exact kvE2_sepCoincidentOwner_valid_left qnf M w x t hxw hwt h σ
        (kvE2_sepPosI_subset hσmem) hzone
    · exact kvE2_sepCoincidentOwner_valid_right qnf M w x t hxw hwt h σ
        (kvE2_sepPosI_subset hσmem) hzone
  · rw [List.all_eq_true]
    intro p hp
    rw [kvE2_sepCoincidentOrder, List.mem_map] at hp
    obtain ⟨⟨σ, k⟩, hmem, rfl⟩ := hp
    have hσmem : σ ∈ kvE2_sepPosI qnf := List.fst_mem_of_mem_zipIdx hmem
    exact kvE2_sepConsistentBlock_slotIndexOf qnf (kvE2_sepPosI_subset hσmem)
  · -- (iii') anchor-distinct: from the globally-Nodup prefix-sum payload.
    rw [kvE2_sepCoincidentOrder]
    exact (kvE2_sepValid_tie_of_nodup qnf (fun _ => KvE2SepSpikeOrderType.coincident)
      (kvE2_sepSlotIndexOf qnf) (kvE2_sepAllSlots_map_slotIndexOf_nodup qnf)).1
  · -- (iv) tie-class reads: vacuous — all classes are singletons under the global Nodup.
    rw [kvE2_sepCoincidentOrder]
    exact (kvE2_sepValid_tie_of_nodup qnf (fun _ => KvE2SepSpikeOrderType.coincident)
      (kvE2_sepSlotIndexOf qnf) (kvE2_sepAllSlots_map_slotIndexOf_nodup qnf)).2

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

/-- **Foreign-base CLOSED-key discharge at the honest anchor value** (task 342 Phase 8 (a);
    the exact shape Phase 9's tie-read conjunct (iv) consumes): under an honest evaluation
    `h`, if base type `χ` is honestly realized AT an interior owner σ's honest anchor value
    `kvE2_sepAnchorVal qnf M w x t h σ` (equal honest values — the base-anchor tie-class
    situation), then the anchor owner's CLOSED self-zone leaf at the foreign type is TRUE.
    F5: reads only the CLOSED `zAtX1L`/`zAtX1R` keys via `kvE2_sepClosedLeafAt_discharge`. -/
theorem kvE2_sepClosedLeafAt_discharge_honest {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {σ : NormalForm sig 1 4} (hσI : σ ∈ kvE2_sepPosI qnf)
    (χ : NormalForm sig 0 1)
    (hp : nf_eval_nf M 0 1 (fun _ => kvE2_sepAnchorVal qnf M w x t h σ) χ) :
    kvE2_sepClosedLeafAt σ χ = true :=
  kvE2_sepClosedLeafAt_discharge qnf M w x t hxw hwt hσI _
    (kvE2_sepAnchorVal_spec qnf M w x t h σ
      (List.mem_filter.mp (kvE2_sepPosI_subset hσI)).2)
    χ hp

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
    obtain ⟨u, hxu, _huw, hux1, hrel⟩ := hbelowXU χ (List.mem_filter.mp hχ).2
    exact ⟨u, hxu, hux1, hrel⟩
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
      (fun v => x < v ∧ v < w ∧ nf_eval_nf M 0 1 (fun _ => v) χ)
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
    `(x, w)` — strictly BELOW the pivot `w` — and realizes `χ`. Direct from the anchor realization's
    `zXU` extraction, now carrying the restored below-pivot `v < w` bound (task 337 / report 13
    faithfulness audit; Def 3.1 ordering channel, PDF p.4; Figure 1 below-pivot bracket, PDF p.9).
    The old `v < anchorVal` bound remains DERIVABLE as `v < w < x1_σ` for right-interior owners
    (`w < x1_σ`), so any consumer wanting it is unaffected. -/
theorem kvE2_sepSlotValue_rXW_spec {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (σ : NormalForm sig 1 4) (hσpos : σ ∈ kvE2_sepPos qnf)
    (χ : NormalForm sig 0 1) (hχ : χ ∈ kvE2_sepS σ kvE_sub2_zXU) :
    x < kvE2_sepSlotValue qnf M w x t h (.rXW σ χ)
      ∧ kvE2_sepSlotValue qnf M w x t h (.rXW σ χ) < w
      ∧ nf_eval_nf M 0 1 (fun _ => kvE2_sepSlotValue qnf M w x t h (.rXW σ χ)) χ := by
  have hb : qnf.2 σ = true := (List.mem_filter.mp hσpos).2
  have hσ := kvE2_sepAnchorVal_spec qnf M w x t h σ hb
  obtain ⟨_, _, _, hbelowXU, _, _⟩ :=
    kvE_subBracket2_complete_extract σ M (kvE2_sepAnchorVal qnf M w x t h σ) w x t hσ
  haveI : Nonempty M.carrier := ⟨x⟩
  obtain ⟨v, hxv, hvw, _hvx1, hrel⟩ := hbelowXU χ (List.mem_filter.mp hχ).2
  exact Classical.epsilon_spec
    (p := fun v => x < v ∧ v < w ∧ nf_eval_nf M 0 1 (fun _ => v) χ) ⟨v, hxv, hvw, hrel⟩

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
  (kvE2_sepPosI qnf).zipIdx.map
    (fun p => (p.1, KvE2SepSpikeOrderType.coincident,
      (kvE2_sepSlotBlock p.1).map (kvE2_sepSlotHonestGIdx qnf M w x t h)))

/-- The honest order is present in the enumeration index (F2). A `kvE2_sepOrderTypes_mem_aux`
    instance (`s = 0`, all-coincident tag, honest tuple); every tuple component `< 3n` from
    `kvE2_ordRank_lt` feeding `kvE2_sepIdxTuple_mem_of_lt`. UNCONDITIONAL (task 342 Phase 4):
    carrier and enumeration fold both range over the interior index `kvE2_sepPosI`. -/
theorem kvE2_sepHonestOrder_mem_orderTypes {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    kvE2_sepHonestOrder qnf M w x t h ∈ kvE2_sepOrderTypes qnf := by
  rw [kvE2_sepHonestOrder, kvE2_sepOrderTypes]
  refine kvE2_sepOrderTypes_mem_aux' (fun _ => KvE2SepSpikeOrderType.coincident) _
    (fun σ => (kvE2_sepSlotBlock σ).map (kvE2_sepSlotHonestGIdx qnf M w x t h))
    (kvE2_sepPosI qnf) 0 (fun σ hσ => ?_)
  have h := kvE2_sepIdxTupleN_mem_of_forall_lt (kvE2_sepAllSlots qnf).length
    ((kvE2_sepSlotBlock σ).map (kvE2_sepSlotHonestGIdx qnf M w x t h)) (fun y hy => by
      obtain ⟨s, hs, rfl⟩ := List.mem_map.mp hy
      have hidx := kvE2_sepSlotIndexOf_lt qnf
        (kvE2_sepMem_allSlots qnf (kvE2_sepPosI_subset hσ) hs)
      rw [kvE2_sepSlotHonestGIdx, dif_pos hidx]
      exact kvE2_ordRank_lt _ _)
  rwa [List.length_map] at h

/-- **The honest order is a carrier member** (task 340 Phase 5B — the object task 337 consumes).
    Under an honest realization the value-rank honest order is a VALID, PRESENT member of
    `kvE2_sepArr' qnf`. UNCONDITIONAL (task 342 Part I): owner interiority is a construction
    invariant of the `kvE2_sepPosI` index (Rabinovich §5, p.7), recovered via
    `kvE2_sepPosI_zone`, never hypothesized. The `kvE2_sepDisjValid` conjuncts: (i)
    all-`.coincident` validity reuses `kvE2_sepCoincidentOwner_valid_left/right` VERBATIM
    (tuple-agnostic, CLOSED self-zone bit only); (ii) consistency via
    `kvE2_sepConsistentBlock_honest`; (iii')/(iv) via the shared tie discharge
    `kvE2_sepValid_tie_of_nodup` on the globally-`Nodup` value-rank payload
    (`kvE2_sepAllSlots_map_honestGIdx_nodup` — all tie classes are singletons here; task 342
    Phase 6). -/
theorem kvE2_sepHonestOrder_mem_arr' {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    kvE2_sepHonestOrder qnf M w x t h ∈ kvE2_sepArr' qnf := by
  rw [kvE2_sepArr', List.mem_filter]
  refine ⟨kvE2_sepHonestOrder_mem_orderTypes qnf M w x t h, ?_⟩
  rw [kvE2_sepDisjValid, Bool.and_eq_true, Bool.and_eq_true, Bool.and_eq_true]
  refine ⟨⟨⟨?_, ?_⟩, ?_⟩, ?_⟩
  · -- (i) per-owner closed-self-zone validity (all tags `.coincident`), reused verbatim
    -- (definitional interiority via `kvE2_sepPosI_zone` — a construction invariant of the index).
    rw [List.all_eq_true]
    intro p hp
    rw [kvE2_sepHonestOrder, List.mem_map] at hp
    obtain ⟨⟨σ, i⟩, hmem, rfl⟩ := hp
    have hσmem : σ ∈ kvE2_sepPosI qnf := List.fst_mem_of_mem_zipIdx hmem
    show kvE2_sepDisjValidOwner σ KvE2SepSpikeOrderType.coincident = true
    rcases kvE2_sepPosI_zone hσmem with hzone | hzone
    · exact kvE2_sepCoincidentOwner_valid_left qnf M w x t hxw hwt h σ
        (kvE2_sepPosI_subset hσmem) hzone
    · exact kvE2_sepCoincidentOwner_valid_right qnf M w x t hxw hwt h σ
        (kvE2_sepPosI_subset hσmem) hzone
  · -- (ii) per-owner region-scoped consistency via the value-rank monotonicity engine.
    rw [List.all_eq_true]
    intro p hp
    rw [kvE2_sepHonestOrder, List.mem_map] at hp
    obtain ⟨⟨σ, k⟩, hmem, rfl⟩ := hp
    have hσmem : σ ∈ kvE2_sepPosI qnf := List.fst_mem_of_mem_zipIdx hmem
    exact kvE2_sepConsistentBlock_honest qnf M w x t hxw hwt h (kvE2_sepPosI_subset hσmem)
  · -- (iii') anchor-distinct: from the globally-Nodup value-rank payload.
    rw [kvE2_sepHonestOrder]
    exact (kvE2_sepValid_tie_of_nodup qnf (fun _ => KvE2SepSpikeOrderType.coincident)
      (kvE2_sepSlotHonestGIdx qnf M w x t h)
      (kvE2_sepAllSlots_map_honestGIdx_nodup qnf M w x t h)).1
  · -- (iv) tie-class reads: vacuous — all classes are singletons under the global Nodup.
    rw [kvE2_sepHonestOrder]
    exact (kvE2_sepValid_tie_of_nodup qnf (fun _ => KvE2SepSpikeOrderType.coincident)
      (kvE2_sepSlotHonestGIdx qnf M w x t h)
      (kvE2_sepAllSlots_map_honestGIdx_nodup qnf M w x t h)).2

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
    have hex : ∃ q ∈ (kvE2_sepPosI qnf).zipIdx,
        ((fun p => decide (p.1 = σ)) ∘
          (fun p : NormalForm sig 1 4 × ℕ =>
            (p.1, KvE2SepSpikeOrderType.coincident,
              (kvE2_sepSlotBlock p.1).map (kvE2_sepSlotHonestGIdx qnf M w x t h)))) q = true := by
      have hm : σ ∈ (kvE2_sepPosI qnf).zipIdx.map Prod.fst := by
        rw [List.zipIdx_map_fst]; exact kvE2_sepMem_posI_of_slot hσ hs
      obtain ⟨q, hq, hq1⟩ := List.mem_map.mp hm
      exact ⟨q, hq, by simp [Function.comp, hq1]⟩
    obtain ⟨q, hq, hqp⟩ := hex
    cases hf : (kvE2_sepPosI qnf).zipIdx.find?
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

/-- The wo-ordered owner list projects into any list carrying wo's owner projection:
    `kvE2_sepOrderOwners wo` is a `mergeSort` permutation of `wo.map Prod.fst`. Generic over
    the owner list `L` (task 342 Phase 3): enumeration members supply `L = kvE2_sepPosI qnf`
    via `kvE2_sepOrderTypes_owners`; the Phase-4-pending honest order supplies its own direct
    `zipIdx` projection. -/
theorem kvE2_sepOrderOwners_mem_pos {sig : MonadicSignature}
    {L : List (NormalForm sig 1 4)}
    {wo : KvE2SepWeakOrder sig} (howners : wo.map Prod.fst = L)
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepOrderOwners wo) : σ ∈ L := by
  rw [kvE2_sepOrderOwners] at hσ
  have hperm := (List.mergeSort_perm wo (fun a b => decide (a.2.2.getD 0 0 ≤ b.2.2.getD 0 0))).map
    Prod.fst
  rw [howners] at hperm
  exact hperm.mem_iff.mp hσ

/-- Every slot of the joint LEFT list belongs to some owner's slot block (owners drawn from
    any list carrying wo's owner projection — see `kvE2_sepOrderOwners_mem_pos`). -/
theorem kvE2_sepSlotsLOf_mem_block {sig : MonadicSignature}
    {L : List (NormalForm sig 1 4)}
    {wo : KvE2SepWeakOrder sig} (howners : wo.map Prod.fst = L)
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2_sepSlotsLOf wo) :
    ∃ σ ∈ L, s ∈ kvE2_sepSlotBlock σ := by
  rw [kvE2_sepSlotsLOf] at hs
  obtain ⟨σ, hσ, hsσ⟩ := List.mem_flatMap.mp ((List.mergeSort_perm _ _).mem_iff.mp hs)
  exact ⟨σ, kvE2_sepOrderOwners_mem_pos howners hσ, by
    rw [kvE2_sepSlotBlock]; exact List.mem_append_left _ hsσ⟩

/-- Every slot of the joint RIGHT list belongs to some owner's slot block (mirror). -/
theorem kvE2_sepSlotsROf_mem_block {sig : MonadicSignature}
    {L : List (NormalForm sig 1 4)}
    {wo : KvE2SepWeakOrder sig} (howners : wo.map Prod.fst = L)
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2_sepSlotsROf wo) :
    ∃ σ ∈ L, s ∈ kvE2_sepSlotBlock σ := by
  rw [kvE2_sepSlotsROf] at hs
  obtain ⟨σ, hσ, hsσ⟩ := List.mem_flatMap.mp ((List.mergeSort_perm _ _).mem_iff.mp hs)
  exact ⟨σ, kvE2_sepOrderOwners_mem_pos howners hσ, by
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
  -- Task 342 Phase 4: the honest order's owner projection is read off its `zipIdx` carrier
  -- directly — now the interior index `kvE2_sepPosI`.
  have hwo : (kvE2_sepHonestOrder qnf M w x t h).map Prod.fst
      = kvE2_sepPosI qnf := by
    rw [kvE2_sepHonestOrder, List.map_map]
    exact List.zipIdx_map_fst 0 _
  refine (kvE2_sepSlotsLOf_mergeSorted _).imp_of_mem ?_
  intro a b ha hb hab
  obtain ⟨σ, hσ, haσ⟩ := kvE2_sepSlotsLOf_mem_block hwo ha
  obtain ⟨τ, hτ, hbτ⟩ := kvE2_sepSlotsLOf_mem_block hwo hb
  rw [kvE2_sepSlotMergeLe, decide_eq_true_eq] at hab
  by_contra hlt
  rw [not_le] at hlt
  exact absurd hab (not_le.mpr (kvE2_sepSlotGIdx_honestOrder_mono qnf M w x t h
    (kvE2_sepPosI_subset hτ) (kvE2_sepPosI_subset hσ) hbτ haσ hlt))

/-- **Value-sortedness of the joint RIGHT list on the honest order** (mirror). -/
theorem kvE2_sepSlotsROf_honest_valueSorted {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    (kvE2_sepSlotsROf (kvE2_sepHonestOrder qnf M w x t h)).Pairwise
      (fun a b => kvE2_sepSlotValue qnf M w x t h a ≤ kvE2_sepSlotValue qnf M w x t h b) := by
  -- Task 342 Phase 4: direct `zipIdx` owner projection onto `kvE2_sepPosI` (see LEFT mirror).
  have hwo : (kvE2_sepHonestOrder qnf M w x t h).map Prod.fst
      = kvE2_sepPosI qnf := by
    rw [kvE2_sepHonestOrder, List.map_map]
    exact List.zipIdx_map_fst 0 _
  refine (kvE2_sepSlotsROf_mergeSorted _).imp_of_mem ?_
  intro a b ha hb hab
  obtain ⟨σ, hσ, haσ⟩ := kvE2_sepSlotsROf_mem_block hwo ha
  obtain ⟨τ, hτ, hbτ⟩ := kvE2_sepSlotsROf_mem_block hwo hb
  rw [kvE2_sepSlotMergeLe, decide_eq_true_eq] at hab
  by_contra hlt
  rw [not_le] at hlt
  exact absurd hab (not_le.mpr (kvE2_sepSlotGIdx_honestOrder_mono qnf M w x t h
    (kvE2_sepPosI_subset hτ) (kvE2_sepPosI_subset hσ) hbτ haσ hlt))

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
    interior spine `kvE2_sepPosI`, task 342 Phase 3). -/
theorem kvE2_sepOrderOwners_nodup {sig : MonadicSignature} (qnf : NormalForm sig 2 3)
    {wo : KvE2SepWeakOrder sig} (hwo : wo ∈ kvE2_sepOrderTypes qnf) :
    (kvE2_sepOrderOwners wo).Nodup := by
  rw [kvE2_sepOrderOwners]
  have hperm : List.Perm
      ((wo.mergeSort (fun a b => decide (a.2.2.getD 0 0 ≤ b.2.2.getD 0 0))).map Prod.fst)
      (kvE2_sepPosI qnf) := by
    have hp := (List.mergeSort_perm wo
      (fun a b => decide (a.2.2.getD 0 0 ≤ b.2.2.getD 0 0))).map Prod.fst
    rwa [kvE2_sepOrderTypes_owners qnf hwo] at hp
  exact hperm.nodup_iff.mpr (kvE2_sepPosI_nodup qnf)

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

/-! ### Task 333 Phase 2 (R2) — soundness side-conditions over arbitrary `wo ∈ kvE2_sepArr'`

The `kvE2_sepBody_extract` side-conditions (`hpairL`/`hpairR`/`hnd`, the SW:6331-6340
shapes) quantify over EVERY valid weak order. The provable core lands here: conjunct (ii)
of `kvE2_sepDisjValid` (region-scoped payload consistency, `kvE2_sepConsistentBlock`)
reflects the merge-key sortedness of `kvE2_sepSlotsL/ROf wo` into SAME-OWNER rank order —
the `if`-true branch of `kvE2_sepSlotLe` — for arbitrary `wo ∈ kvE2_sepArr' qnf`, not just
the honest order. -/

/-- Consistency accessor (conjunct (ii) of `kvE2_sepDisjValid`): membership in the faithful
    carrier yields every owner's region-scoped payload consistency. Companion of
    `kvE2_sepArr'_sound`, which surfaces conjuncts (i)/(iii')/(iv) and discards (ii). -/
theorem kvE2_sepArr'_consistent {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) {wo : KvE2SepWeakOrder sig}
    (hwo : wo ∈ kvE2_sepArr' qnf) :
    ∀ p ∈ wo, kvE2_sepConsistentBlock p.1 p.2.2 = true := by
  have hv : kvE2_sepDisjValid qnf wo = true := (List.mem_filter.mp hwo).2
  rw [kvE2_sepDisjValid, Bool.and_eq_true, Bool.and_eq_true, Bool.and_eq_true] at hv
  exact fun p hp => (List.all_eq_true.mp hv.1.1.2) p hp

/-- `find?` at an owner key resolves to that owner's entry on any weak order whose owner
    projection is duplicate-free (every `kvE2_sepOrderTypes` member, via
    `kvE2_sepOrderTypes_owners` + `kvE2_sepPosI_nodup`). -/
private theorem kvE2_sep_find?_owner_entry {sig : MonadicSignature}
    {σ : NormalForm sig 1 4} {tag : KvE2SepSpikeOrderType} {t : List ℕ} :
    ∀ {wo : KvE2SepWeakOrder sig}, (wo.map Prod.fst).Nodup → (σ, tag, t) ∈ wo →
      wo.find? (fun q => decide (q.1 = σ)) = some (σ, tag, t) := by
  intro wo
  induction wo with
  | nil => intro _ hp; simp at hp
  | cons a l ih =>
    intro hnd hp
    rw [List.map_cons, List.nodup_cons] at hnd
    rcases List.mem_cons.mp hp with heq | hpl
    · subst heq
      exact List.find?_cons_of_pos (by simp)
    · have hne : ¬(a.1 = σ) := fun he => hnd.1 (by
        rw [he]
        exact List.mem_map_of_mem hpl)
      rw [List.find?_cons_of_neg (by simpa using hne)]
      exact ih hnd.2 hpl

/-- Payload read of the merge key on an enumeration member: for `(σ, tag, t) ∈ wo` with
    duplicate-free owners, the global index of an own slot `s` is `t`'s entry at `s`'s
    block position (the arbitrary-`wo` generalization of the honest-order bridge
    `kvE2_sepSlotGIdx_honestOrder`). -/
private theorem kvE2_sepSlotGIdx_read {sig : MonadicSignature}
    {wo : KvE2SepWeakOrder sig} (hnd : (wo.map Prod.fst).Nodup)
    {σ : NormalForm sig 1 4} {tag : KvE2SepSpikeOrderType} {t : List ℕ}
    (hp : (σ, tag, t) ∈ wo)
    {s : KvE2SepSlot sig} (hsub : kvE2_sepSlotSub s = σ) :
    kvE2_sepSlotGIdx wo s = t.getD (kvE2_sepBlockPos s) 0 := by
  unfold kvE2_sepSlotGIdx
  rw [hsub, kvE2_sep_find?_owner_entry hnd hp]
  simp only [Option.map_some, Option.getD_some]

/-- **Same-owner rank order from merge-key order** (the provable core of the R2 `hpair`
    side-conditions): on a valid weak order, two same-region slots of one owner whose merge
    keys are `≤`-ordered are rank-ordered — conjunct (ii) region-consistency reflected
    through the payload read. -/
private theorem kvE2_sep_rank_le_of_gidx_le {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) {wo : KvE2SepWeakOrder sig}
    (hwo : wo ∈ kvE2_sepArr' qnf)
    {σ : NormalForm sig 1 4} {tag : KvE2SepSpikeOrderType} {t : List ℕ}
    (hp : (σ, tag, t) ∈ wo)
    {a b : KvE2SepSlot sig} (ha : a ∈ kvE2_sepSlotBlock σ) (hb : b ∈ kvE2_sepSlotBlock σ)
    (hreg : kvE2_sepSlotRegionLeft a = kvE2_sepSlotRegionLeft b)
    (hle : kvE2_sepSlotGIdx wo a ≤ kvE2_sepSlotGIdx wo b) :
    kvE2_sepSlotRank a ≤ kvE2_sepSlotRank b := by
  by_contra hgt
  push_neg at hgt
  have hnd : (wo.map Prod.fst).Nodup := by
    rw [kvE2_sepOrderTypes_owners qnf (List.mem_filter.mp hwo).1]
    exact kvE2_sepPosI_nodup qnf
  have hcons := kvE2_sepArr'_consistent qnf hwo (σ, tag, t) hp
  rw [kvE2_sepConsistentBlock, decide_eq_true_eq] at hcons
  have hsa : kvE2_sepSlotSub a = σ := kvE2_sepSlotSub_of_mem_block ha
  have hsb : kvE2_sepSlotSub b = σ := kvE2_sepSlotSub_of_mem_block hb
  have hal : (kvE2_sepSlotBlock σ).idxOf a < (kvE2_sepSlotBlock σ).length :=
    List.idxOf_lt_length_of_mem ha
  have hbl : (kvE2_sepSlotBlock σ).idxOf b < (kvE2_sepSlotBlock σ).length :=
    List.idxOf_lt_length_of_mem hb
  have hga : (kvE2_sepSlotBlock σ).get ⟨_, hal⟩ = a := List.idxOf_get hal
  have hgb : (kvE2_sepSlotBlock σ).get ⟨_, hbl⟩ = b := List.idxOf_get hbl
  have hlt : t.getD ((kvE2_sepSlotBlock σ).idxOf b) 0
      < t.getD ((kvE2_sepSlotBlock σ).idxOf a) 0 :=
    hcons ⟨_, hbl⟩ ⟨_, hal⟩ (by rw [hga, hgb]; exact hreg.symm)
      (by rw [hga, hgb]; exact hgt)
  have hra : kvE2_sepSlotGIdx wo a = t.getD ((kvE2_sepSlotBlock σ).idxOf a) 0 := by
    rw [kvE2_sepSlotGIdx_read hnd hp hsa, kvE2_sepBlockPos, hsa]
  have hrb : kvE2_sepSlotGIdx wo b = t.getD ((kvE2_sepSlotBlock σ).idxOf b) 0 := by
    rw [kvE2_sepSlotGIdx_read hnd hp hsb, kvE2_sepBlockPos, hsb]
  rw [hra, hrb] at hle
  omega

/-- **Strict same-owner key order from rank order** (task 333 Route A, (b)): the
    contrapositive of the landed `kvE2_sep_rank_le_of_gidx_le` (ℕ: `¬ ≤` is `<`). On a
    valid weak order, two same-region slots of one owner with strictly ordered region ranks
    carry strictly ordered global merge keys — the fact that separates a same-owner
    anchor/base pair into DISTINCT tie classes (conjunct (ii) via
    `kvE2_sepArr'_consistent`; no cross-owner relation enters). -/
private theorem kvE2_sep_gidx_lt_of_rank_lt {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) {wo : KvE2SepWeakOrder sig}
    (hwo : wo ∈ kvE2_sepArr' qnf)
    {σ : NormalForm sig 1 4} {tag : KvE2SepSpikeOrderType} {t : List ℕ}
    (hp : (σ, tag, t) ∈ wo)
    {a b : KvE2SepSlot sig} (ha : a ∈ kvE2_sepSlotBlock σ) (hb : b ∈ kvE2_sepSlotBlock σ)
    (hreg : kvE2_sepSlotRegionLeft a = kvE2_sepSlotRegionLeft b)
    (hrk : kvE2_sepSlotRank a < kvE2_sepSlotRank b) :
    kvE2_sepSlotGIdx wo a < kvE2_sepSlotGIdx wo b := by
  by_contra hnlt
  push_neg at hnlt
  have hle := kvE2_sep_rank_le_of_gidx_le qnf hwo hp hb ha hreg.symm hnlt
  omega

/-- **Same-owner `hpairL` core** (task 333 Phase 2): on every valid weak order the joint
    LEFT slot list is `kvE2_sepSlotLe`-pairwise on SAME-OWNER pairs — merge-key sortedness
    reflected through conjunct (ii). This is the half of the `hpairL` side-condition that
    IS a consequence of `kvE2_sepDisjValid` membership. -/
theorem kvE2_sepSlotsLOf_pairwise_sameOwner {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) :
    ∀ wo ∈ kvE2_sepArr' qnf,
      (kvE2_sepSlotsLOf wo).Pairwise
        (fun a b => kvE2_sepSlotSub a = kvE2_sepSlotSub b → kvE2_sepSlotLe a b = true) := by
  intro wo hwo
  have howners : wo.map Prod.fst = kvE2_sepPosI qnf :=
    kvE2_sepOrderTypes_owners qnf (List.mem_filter.mp hwo).1
  refine (kvE2_sepSlotsLOf_mergeSorted wo).imp_of_mem ?_
  intro a b hma hmb hab hsub
  rw [kvE2_sepSlotsLOf] at hma hmb
  obtain ⟨σ, hσo, hsa⟩ := List.mem_flatMap.mp ((List.mergeSort_perm _ _).mem_iff.mp hma)
  obtain ⟨τ, hτo, hsb⟩ := List.mem_flatMap.mp ((List.mergeSort_perm _ _).mem_iff.mp hmb)
  have hsuba : kvE2_sepSlotSub a = σ := kvE2_sepSlotsLFor_sub hsa
  have hsubb : kvE2_sepSlotSub b = τ := kvE2_sepSlotsLFor_sub hsb
  have hστ : σ = τ := hsuba.symm.trans (hsub.trans hsubb)
  subst hστ
  have hσp : σ ∈ wo.map Prod.fst := by
    rw [howners]; exact kvE2_sepOrderOwners_mem_pos howners hσo
  obtain ⟨p, hpwo, hp1⟩ := List.mem_map.mp hσp
  have hpe : (σ, p.2.1, p.2.2) ∈ wo := by rw [← hp1]; exact hpwo
  have hle : kvE2_sepSlotGIdx wo a ≤ kvE2_sepSlotGIdx wo b := by
    simpa [kvE2_sepSlotMergeLe] using hab
  have hreg : kvE2_sepSlotRegionLeft a = kvE2_sepSlotRegionLeft b := by
    rw [kvE2_sepSlotsLFor_regionLeft σ hsa, kvE2_sepSlotsLFor_regionLeft σ hsb]
  have hba : a ∈ kvE2_sepSlotBlock σ := by
    rw [kvE2_sepSlotBlock]; exact List.mem_append_left _ hsa
  have hbb : b ∈ kvE2_sepSlotBlock σ := by
    rw [kvE2_sepSlotBlock]; exact List.mem_append_left _ hsb
  exact kvE2_sepSlotLe_same hsub
    (kvE2_sep_rank_le_of_gidx_le qnf hwo hpe hba hbb hreg hle)

/-- **Same-owner `hpairR` core** (RIGHT mirror of `kvE2_sepSlotsLOf_pairwise_sameOwner`). -/
theorem kvE2_sepSlotsROf_pairwise_sameOwner {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) :
    ∀ wo ∈ kvE2_sepArr' qnf,
      (kvE2_sepSlotsROf wo).Pairwise
        (fun a b => kvE2_sepSlotSub a = kvE2_sepSlotSub b → kvE2_sepSlotLe a b = true) := by
  intro wo hwo
  have howners : wo.map Prod.fst = kvE2_sepPosI qnf :=
    kvE2_sepOrderTypes_owners qnf (List.mem_filter.mp hwo).1
  refine (kvE2_sepSlotsROf_mergeSorted wo).imp_of_mem ?_
  intro a b hma hmb hab hsub
  rw [kvE2_sepSlotsROf] at hma hmb
  obtain ⟨σ, hσo, hsa⟩ := List.mem_flatMap.mp ((List.mergeSort_perm _ _).mem_iff.mp hma)
  obtain ⟨τ, hτo, hsb⟩ := List.mem_flatMap.mp ((List.mergeSort_perm _ _).mem_iff.mp hmb)
  have hsuba : kvE2_sepSlotSub a = σ := kvE2_sepSlotsRFor_sub hsa
  have hsubb : kvE2_sepSlotSub b = τ := kvE2_sepSlotsRFor_sub hsb
  have hστ : σ = τ := hsuba.symm.trans (hsub.trans hsubb)
  subst hστ
  have hσp : σ ∈ wo.map Prod.fst := by
    rw [howners]; exact kvE2_sepOrderOwners_mem_pos howners hσo
  obtain ⟨p, hpwo, hp1⟩ := List.mem_map.mp hσp
  have hpe : (σ, p.2.1, p.2.2) ∈ wo := by rw [← hp1]; exact hpwo
  have hle : kvE2_sepSlotGIdx wo a ≤ kvE2_sepSlotGIdx wo b := by
    simpa [kvE2_sepSlotMergeLe] using hab
  have hreg : kvE2_sepSlotRegionLeft a = kvE2_sepSlotRegionLeft b := by
    rw [kvE2_sepSlotsRFor_regionRight σ hsa, kvE2_sepSlotsRFor_regionRight σ hsb]
  have hba : a ∈ kvE2_sepSlotBlock σ := by
    rw [kvE2_sepSlotBlock]; exact List.mem_append_right _ hsa
  have hbb : b ∈ kvE2_sepSlotBlock σ := by
    rw [kvE2_sepSlotBlock]; exact List.mem_append_right _ hsb
  exact kvE2_sepSlotLe_same hsub
    (kvE2_sep_rank_le_of_gidx_le qnf hwo hpe hba hbb hreg hle)

/-! **R2 exact-shape discharge — NOT derivable from `kvE2_sepDisjValid` (task 333 Phase 2
blocker record, machine-checked residues).** The full `kvE2_sepBody_extract` shapes
(`hpairL`/`hpairR`: `Pairwise (kvE2_sepSlotLe · · = true)`; `hnd`:
`(… .map (kvE2_sepSlotGIdx wo)).Nodup`, SW:6331-6340) are FALSE over arbitrary
`wo ∈ kvE2_sepArr' qnf`:

* **Cross-owner half of `hpair`**: for a cross-owner sorted pair the relation is
  `kvE2_sepCompat a b`, which at a fresh-adjacent pair reads the fresh owner's OPEN
  `zXU`/`zUW` bit at the foreign 1-type (`kvE2_sepCompat_lX1_eq`). NO
  `kvE2_sepDisjValid` conjunct reads a cross-owner OPEN bit: (i) reads each owner's OWN
  tag bit at its OWN fresh type, (ii) is per-owner payload consistency, (iii') is
  anchor-payload distinctness, (iv) reads only CLOSED keys at payload ties. A valid `wo`
  placing a foreign `.lXU τ χ` payload below `.lX1 σ` with
  `kvE2_sepBits σ kvE_sub2_zXU χ = false` realizes the failure.
* **`hnd`**: base-base payload ties are DELIBERATELY admitted (conjunct (iii) removal —
  the Lemma 3.2(1) equality-case completeness repair; `kvE2_sepAnchorDistinct` docstring:
  "base slots may tie freely"). A tied payload duplicates the mapped `kvE2_sepSlotGIdx`
  value, so the `.map` is not `Nodup`.

This matches the carrier's own annotations: `kvE2_sepBody_extract` (SW:6320-6327) calls
`hnd` a restriction "to the TIE-FREE configuration" whose tie-admitting replacement "is
the Phases 8-10 arbitration item", and the task-334 note (SW:6313-6318) says the `hpair`
facts "hold whenever the canonical union is a single region-sorted block". The same-owner
`Pairwise` core above is the part of R2 that IS a validity consequence; the cross-owner
and no-tie halves are properties of the SPECIFIC realized weak order, to be threaded as
per-`wo` hypotheses (or discharged by the grouped tie-admitting extraction), never as
`∀ wo ∈ kvE2_sepArr'` lemmas. -/

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

-- NOTE (task 342 Phase 7): `kvE2_sepBody_complete_holds` (Phase 5D, the completeness
-- hand-off to task 337) is RELOCATED below the grouped/flat singleton-compatibility block —
-- post-rewire the carrier emits GROUPED disjuncts, and the flat `hdisj` is converted via
-- `kvE2_sepDisjunct'_map_singleton_iff` on the honest order's singleton tie classes
-- (`kvE2_sepHonestOrder_slotsLOf/ROf_gidx_nodup`). Statement unchanged.

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

/-! ### Task 337 Phase 3 — bracket point-type + segment match (the `.holds` construction)

The mpr dual of `kvE2_sepDisjunct_extract`: assemble `(kvE2_sepBracketN lL ptW lR segs).holds`
from a per-slot witness list. The generic construction below is the N-slot lift of the landed
k=3 template `k1v_bracket_construct3` (SubBracket2V.lean:720): a combined strictly-sorted
witness list `usL ++ w :: usR` (pivot `w` at position `|usL|` — the SINGLE interior
distinguished slot of the §5 bracket, PDF p.7), per-index point-type realizations on each
side, `ptW` at the pivot, and the per-gap segment obligations in `holds_eq_succ`'s three
shapes. All bounds ride the fixed endpoints `x`/`t` and the witness list itself (F4/LITMUS:
no `x1 < e_i` relative-position literal, no owner-to-owner chain). -/

/-- **Generic N-slot bracket construction** (Phase 3 structural core; Rabinovich Lemma 5.3,
    md:137-152 — per-region segment types; Def 3.1 strictly-increasing witnesses, md:61-74).
    Point types are read at the combined witness list `usL ++ w :: usR` in block slot-index
    order; the three `beta` families are supplied in exactly `IntervalPattern.holds_eq_succ`'s
    gap shapes. -/
private theorem kvE2_sepBracketN_construct {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (lL : List TemporalPred) (ptW : TemporalPred) (lR : List TemporalPred)
    (segs : Nat → TemporalPred)
    (x w t : M.carrier) (usL usR : List M.carrier)
    (hlenL : usL.length = lL.length) (hlenR : usR.length = lR.length)
    (hsort : (usL ++ w :: usR).Pairwise (· < ·))
    (hrange : ∀ u ∈ usL ++ w :: usR, x < u ∧ u < t)
    (hptL : ∀ (i : Nat) (hi : i < lL.length),
      (lL[i]'hi).eval_at M atomMap (usL[i]'(by omega)))
    (hptW : ptW.eval_at M atomMap w)
    (hptR : ∀ (j : Nat) (hj : j < lR.length),
      (lR[j]'hj).eval_at M atomMap (usR[j]'(by omega)))
    (hseg0 : ∀ y : M.carrier, x < y →
      y < (usL ++ w :: usR)[0]'(by simp) → (segs 0).eval_at M atomMap y)
    (hsegmid : ∀ (i : Nat) (hi : i + 1 < (usL ++ w :: usR).length) (y : M.carrier),
      (usL ++ w :: usR)[i]'(by omega) < y → y < (usL ++ w :: usR)[i + 1]'hi →
      (segs (i + 1)).eval_at M atomMap y)
    (hseglast : ∀ y : M.carrier,
      (usL ++ w :: usR)[(usL ++ w :: usR).length - 1]'(by simp) < y → y < t →
      (segs (usL ++ w :: usR).length).eval_at M atomMap y) :
    (kvE2_sepBracketN lL ptW lR segs).holds M atomMap x t := by
  have hlen : (usL ++ w :: usR).length = lL.length + lR.length + 1 := by
    simp only [List.length_append, List.length_cons, hlenL, hlenR]; omega
  simp only [kvE2_sepBracketN, BracketFormula.holds, BracketFormula.toIntervalPattern]
  rw [IntervalPattern.holds_eq_succ M atomMap _ _ x t
    (show lL.length + 1 + lR.length = lL.length + lR.length + 1 by omega)]
  refine ⟨fun i => (usL ++ w :: usR)[i.val]'(by have := i.isLt; omega), ?_, ?_, ?_, ?_, ?_, ?_⟩
  · -- Strict monotonicity in block slot-index order.
    intro i j hij
    exact List.pairwise_iff_getElem.mp hsort i.val j.val _ _ hij
  · -- Range: every witness strictly inside the fixed endpoints `(x, t)`.
    intro i
    exact hrange _ (List.getElem_mem _)
  · -- Point types: three-way index split around the shared `ptW` pivot at `|lL|`.
    intro i
    rcases Nat.lt_trichotomy i.val lL.length with hi | hi | hi
    · have ht := kvE2_sep_getElem_left lL lR ptW i.val hi
      have hu := kvE2_sep_getElem_left usL usR w i.val (by omega)
      simp only []
      rw [show ((lL ++ ptW :: lR)[i.val]'(by
            simp only [List.length_append, List.length_cons]; omega)) = lL[i.val]'hi from ht,
        show ((usL ++ w :: usR)[i.val]'(by have := i.isLt; omega))
            = usL[i.val]'(by omega) from hu]
      exact hptL i.val hi
    · have ht := kvE2_sep_getElem_mid lL lR ptW
      have hu := kvE2_sep_getElem_mid usL usR w
      simp only []
      rw [show ((lL ++ ptW :: lR)[i.val]'(by
            simp only [List.length_append, List.length_cons]; omega)) = ptW by
          rw [getElem_congr_idx hi]; exact ht,
        show ((usL ++ w :: usR)[i.val]'(by have := i.isLt; omega)) = w by
          rw [getElem_congr_idx (by omega : i.val = usL.length)]; exact hu]
      exact hptW
    · have hj : i.val - lL.length - 1 < lR.length := by have := i.isLt; omega
      have ht := kvE2_sep_getElem_right lL lR ptW (i.val - lL.length - 1) hj
      have hu := kvE2_sep_getElem_right usL usR w (i.val - lL.length - 1) (by omega)
      simp only []
      rw [show ((lL ++ ptW :: lR)[i.val]'(by
            simp only [List.length_append, List.length_cons]; omega))
            = lR[i.val - lL.length - 1]'hj by
          rw [getElem_congr_idx
            (by omega : i.val = lL.length + 1 + (i.val - lL.length - 1))]; exact ht,
        show ((usL ++ w :: usR)[i.val]'(by have := i.isLt; omega))
            = usR[i.val - lL.length - 1]'(by omega) by
          rw [getElem_congr_idx
            (by omega : i.val = usL.length + 1 + (i.val - lL.length - 1))]; exact hu]
      exact hptR (i.val - lL.length - 1) hj
  · -- First gap `(x, ws 0)`.
    intro y hxy hy0
    exact hseg0 y hxy hy0
  · -- Interior gaps `(ws i, ws (i+1))`.
    intro i y hlo hhi
    exact hsegmid i.val (by have := i.isLt; omega) y hlo hhi
  · -- Last gap `(ws last, t)`.
    intro y hlo hyt
    have h1 := hseglast y
      (lt_of_le_of_lt (le_of_eq (getElem_congr_idx (by simp only [Fin.val_mk]; omega))) hlo)
      hyt
    rwa [hlen] at h1

/-! ### Task 342 Phase 7 — grouped/flat singleton compatibility

When every tie class is a singleton (the tie-free case — any weak order whose
`kvE2_sepSlotGIdx` payload is duplicate-free over the merged chain), the meet-folded grouped
disjunct and the flat per-slot disjunct agree at `.holds` level: `formula_conjList [f]`
eval-equals `f` pointwise, and the grouped cut arithmetic collapses to the flat cuts. The
comparison is `.holds`-level, NOT syntactic (`formula_conjList [f]` is `f ∧ ⊤`). -/

/-- `.holds`-level congruence for `kvE2_sepBracketN` under pointwise eval-equivalent point
    types and equal (bracket-relevant) segment types. The two brackets carry syntactically
    DIFFERENT length expressions; both sides are normalized to a common witness count via
    `IntervalPattern.holds_eq_succ`. -/
private theorem kvE2_sepBracketN_holds_congr {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (aL bL aR bR : List TemporalPred) (ptW : TemporalPred)
    (segsA segsB : Nat → TemporalPred)
    (hL : aL.length = bL.length) (hR : aR.length = bR.length)
    (hptL : ∀ (i : Nat) (hia : i < aL.length) (hib : i < bL.length) (y : M.carrier),
      (aL[i]'hia).eval_at M atomMap y ↔ (bL[i]'hib).eval_at M atomMap y)
    (hptR : ∀ (j : Nat) (hja : j < aR.length) (hjb : j < bR.length) (y : M.carrier),
      (aR[j]'hja).eval_at M atomMap y ↔ (bR[j]'hjb).eval_at M atomMap y)
    (hseg : ∀ i : Nat, i ≤ aL.length + 1 + aR.length → segsA i = segsB i)
    (x t : M.carrier) :
    (kvE2_sepBracketN aL ptW aR segsA).holds M atomMap x t ↔
      (kvE2_sepBracketN bL ptW bR segsB).holds M atomMap x t := by
  -- Combined point-list reads agree at every index (three-way split at the pivot `|aL|`).
  have hpt : ∀ (i : Nat) (hia : i < aL.length + 1 + aR.length)
      (hib : i < bL.length + 1 + bR.length) (y : M.carrier),
      ((aL ++ ptW :: aR)[i]'(by
        simp only [List.length_append, List.length_cons]; omega)).eval_at M atomMap y ↔
      ((bL ++ ptW :: bR)[i]'(by
        simp only [List.length_append, List.length_cons]; omega)).eval_at M atomMap y := by
    intro i hia hib y
    rcases Nat.lt_trichotomy i aL.length with hi | hi | hi
    · rw [kvE2_sep_getElem_left aL aR ptW i hi,
        kvE2_sep_getElem_left bL bR ptW i (hL ▸ hi)]
      exact hptL i hi (hL ▸ hi) y
    · rw [show ((aL ++ ptW :: aR)[i]'(by
            simp only [List.length_append, List.length_cons]; omega)) = ptW by
          rw [getElem_congr_idx hi]; exact kvE2_sep_getElem_mid aL aR ptW,
        show ((bL ++ ptW :: bR)[i]'(by
            simp only [List.length_append, List.length_cons]; omega)) = ptW by
          rw [getElem_congr_idx (hi.trans hL)]; exact kvE2_sep_getElem_mid bL bR ptW]
    · have hja : i - aL.length - 1 < aR.length := by omega
      have hjb : i - bL.length - 1 < bR.length := by omega
      rw [show ((aL ++ ptW :: aR)[i]'(by
            simp only [List.length_append, List.length_cons]; omega))
            = aR[i - aL.length - 1]'hja by
          rw [getElem_congr_idx (by omega : i = aL.length + 1 + (i - aL.length - 1))]
          exact kvE2_sep_getElem_right aL aR ptW _ hja,
        show ((bL ++ ptW :: bR)[i]'(by
            simp only [List.length_append, List.length_cons]; omega))
            = bR[i - bL.length - 1]'hjb by
          rw [getElem_congr_idx (by omega : i = bL.length + 1 + (i - bL.length - 1))]
          exact kvE2_sep_getElem_right bL bR ptW _ hjb]
      rw [getElem_congr_idx (by omega : i - bL.length - 1 = i - aL.length - 1)]
      exact hptR (i - aL.length - 1) hja (by omega) y
  simp only [kvE2_sepBracketN, BracketFormula.holds, BracketFormula.toIntervalPattern]
  rw [IntervalPattern.holds_eq_succ M atomMap _ _ x t
      (show aL.length + 1 + aR.length = aL.length + aR.length + 1 by omega),
    IntervalPattern.holds_eq_succ M atomMap _ _ x t
      (show bL.length + 1 + bR.length = aL.length + aR.length + 1 by omega)]
  constructor
  · rintro ⟨ws, h1, h2, h3, h4, h5, h6⟩
    refine ⟨ws, h1, h2, fun i => (hpt i.val (by omega) (by omega) (ws i)).mp (h3 i),
      fun y hy1 hy2 => ?_, fun i y hy1 hy2 => ?_, fun y hy1 hy2 => ?_⟩
    · show (segsB 0).eval_at M atomMap y
      rw [← hseg 0 (by omega)]
      exact h4 y hy1 hy2
    · show (segsB (i.val + 1)).eval_at M atomMap y
      rw [← hseg (i.val + 1) (by omega)]
      exact h5 i y hy1 hy2
    · show (segsB (aL.length + aR.length + 1)).eval_at M atomMap y
      rw [← hseg (aL.length + aR.length + 1) (by omega)]
      exact h6 y hy1 hy2
  · rintro ⟨ws, h1, h2, h3, h4, h5, h6⟩
    refine ⟨ws, h1, h2, fun i => (hpt i.val (by omega) (by omega) (ws i)).mpr (h3 i),
      fun y hy1 hy2 => ?_, fun i y hy1 hy2 => ?_, fun y hy1 hy2 => ?_⟩
    · show (segsA 0).eval_at M atomMap y
      rw [hseg 0 (by omega)]
      exact h4 y hy1 hy2
    · show (segsA (i.val + 1)).eval_at M atomMap y
      rw [hseg (i.val + 1) (by omega)]
      exact h5 i y hy1 hy2
    · show (segsA (aL.length + aR.length + 1)).eval_at M atomMap y
      rw [hseg (aL.length + aR.length + 1) (by omega)]
      exact h6 y hy1 hy2

/-- **Singleton compatibility, core form** (task 342 Phase 7 exit obligation): on the
    singleton partition the grouped meet-folded disjunct agrees with the flat per-slot
    disjunct at `.holds` level. Point types: `formula_conjList [f]` eval-equals `f`
    (`kvE2_sepClassType_singleton_eval`); segments: grouped cuts collapse to flat cuts
    (`kvE2_sepSegsG_map_singleton`); endpoints and the shared `ptW` are shared verbatim. -/
theorem kvE2_sepDisjunct'_map_singleton_iff {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (lL lR : List (KvE2SepSlot sig))
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (x t : M.carrier) :
    (kvE2_sepDisjunct' charBase charK qnf
        (lL.map (fun s => [s])) (lR.map (fun s => [s]))).2.holds M atomMap x t ↔
      (kvE2_sepDisjunct charBase charK qnf lL lR).2.holds M atomMap x t := by
  have hptL' : ∀ (i : Nat)
      (hia : i < ((lL.map (fun s => [s])).map (kvE2_sepClassType charBase charK)).length)
      (hib : i < (lL.map (kvE2_sepSlotType charBase charK)).length) (y : M.carrier),
      ((((lL.map (fun s => [s])).map (kvE2_sepClassType charBase charK))[i]'hia).eval_at
          M atomMap y) ↔
        (((lL.map (kvE2_sepSlotType charBase charK))[i]'hib).eval_at M atomMap y) := by
    intro i hia hib y
    simp only [List.getElem_map]
    exact kvE2_sepClassType_singleton_eval charBase charK _ M atomMap y
  have hptR' : ∀ (j : Nat)
      (hja : j < ((lR.map (fun s => [s])).map (kvE2_sepClassType charBase charK)).length)
      (hjb : j < (lR.map (kvE2_sepSlotType charBase charK)).length) (y : M.carrier),
      ((((lR.map (fun s => [s])).map (kvE2_sepClassType charBase charK))[j]'hja).eval_at
          M atomMap y) ↔
        (((lR.map (kvE2_sepSlotType charBase charK))[j]'hjb).eval_at M atomMap y) := by
    intro j hja hjb y
    simp only [List.getElem_map]
    exact kvE2_sepClassType_singleton_eval charBase charK _ M atomMap y
  have hseg' : ∀ i : Nat,
      i ≤ ((lL.map (fun s => [s])).map (kvE2_sepClassType charBase charK)).length + 1
        + ((lR.map (fun s => [s])).map (kvE2_sepClassType charBase charK)).length →
      kvE2_sepSegsG charBase qnf (lL.map (fun s => [s])) (lR.map (fun s => [s])) i
        = kvE2_sepSegs charBase qnf lL lR i := by
    intro i hi
    exact kvE2_sepSegsG_map_singleton charBase qnf lL lR i (by simpa using hi)
  simp only [kvE2_sepDisjunct', kvE2_sepDisjunct, VecEA2.holds]
  refine and_congr Iff.rfl (and_congr Iff.rfl ?_)
  exact kvE2_sepBracketN_holds_congr M atomMap _ _ _ _ _ _ _
    (by simp) (by simp) hptL' hptR' hseg' x t

/-- All-singleton partitions with a given flatten are exactly the mapped singleton
    partition. -/
private theorem kvE2_sep_eq_map_singleton {α : Type*} :
    ∀ (g : List (List α)) (l : List α), (∀ c ∈ g, ∃ a, c = [a]) → g.flatten = l →
      g = l.map (fun a => [a])
  | [], l, _, hf => by subst hf; rfl
  | c :: g, l, hs, hf => by
    obtain ⟨a, rfl⟩ := hs c List.mem_cons_self
    rw [List.flatten_cons, List.singleton_append] at hf
    subst hf
    have ih := kvE2_sep_eq_map_singleton g g.flatten
      (fun c hc => hs c (List.mem_cons_of_mem _ hc)) rfl
    rw [List.map_cons, ← ih]

/-- **Singleton compatibility, plan shape** (task 342 Phase 7): when every tie class of
    `gL`/`gR` is a singleton and the classes flatten to `lL`/`lR`, the grouped meet-folded
    disjunct agrees with the flat per-slot disjunct at `.holds` level. The hypothesis shape
    is exactly what `kvE2_sepTieGroupedL/R_of_nodup` + `_flatten` produce on a `Nodup`
    payload. -/
theorem kvE2_sepDisjunct'_singleton_iff {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    {gL gR : List (List (KvE2SepSlot sig))} {lL lR : List (KvE2SepSlot sig)}
    (hgLs : ∀ c ∈ gL, ∃ s, c = [s]) (hgLf : gL.flatten = lL)
    (hgRs : ∀ c ∈ gR, ∃ s, c = [s]) (hgRf : gR.flatten = lR)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (x t : M.carrier) :
    (kvE2_sepDisjunct' charBase charK qnf gL gR).2.holds M atomMap x t ↔
      (kvE2_sepDisjunct charBase charK qnf lL lR).2.holds M atomMap x t := by
  rw [kvE2_sep_eq_map_singleton gL lL hgLs hgLf, kvE2_sep_eq_map_singleton gR lR hgRs hgRf]
  exact kvE2_sepDisjunct'_map_singleton_iff charBase charK qnf lL lR M atomMap x t

/-- flatMap is monotone under componentwise sublists. -/
private theorem kvE2_sep_flatMap_sublist {α β : Type*} (f g : α → List β)
    (h : ∀ a, List.Sublist (f a) (g a)) :
    ∀ l : List α, List.Sublist (l.flatMap f) (l.flatMap g)
  | [] => List.Sublist.refl _
  | a :: l => by
    simp only [List.flatMap_cons]
    exact (h a).append (kvE2_sep_flatMap_sublist f g h l)

/-- **Honest merged-chain key family is duplicate-free** (task 342 Phase 7, generic core):
    on the honest order the mergeSort key reader `kvE2_sepSlotGIdx` coincides with the
    value-faithful `kvE2_sepSlotHonestGIdx` on every block slot (halign bridge), whose
    global family is `Nodup`; any per-owner region sub-family union is a sublist of the full
    family, and the merged chain is a permutation of the union. Hence every honest tie class
    is a singleton (via `kvE2_sepTieGroupedL/R_of_nodup`). -/
private theorem kvE2_sepHonestOrder_merged_gidx_nodup {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (F : NormalForm sig 1 4 → List (KvE2SepSlot sig))
    (hFsub : ∀ σ, List.Sublist (F σ) (kvE2_sepSlotBlock σ)) :
    ((((kvE2_sepOrderOwners (kvE2_sepHonestOrder qnf M w x t h)).flatMap F).mergeSort
        (kvE2_sepSlotMergeLe (kvE2_sepHonestOrder qnf M w x t h))).map
      (kvE2_sepSlotGIdx (kvE2_sepHonestOrder qnf M w x t h))).Nodup := by
  -- The wo-ordered owner list is a permutation of the interior index.
  have hp2 : List.Perm (kvE2_sepOrderOwners (kvE2_sepHonestOrder qnf M w x t h))
      (kvE2_sepPosI qnf) := by
    have hperm := (List.mergeSort_perm (kvE2_sepHonestOrder qnf M w x t h)
      (fun a b => decide (a.2.2.getD 0 0 ≤ b.2.2.getD 0 0))).map Prod.fst
    rw [kvE2_sepOrderTypes_owners qnf
      (kvE2_sepHonestOrder_mem_orderTypes qnf M w x t h)] at hperm
    exact hperm
  -- The merged chain is a permutation of the interior-index block union.
  have hp1 : List.Perm
      (((kvE2_sepOrderOwners (kvE2_sepHonestOrder qnf M w x t h)).flatMap F).mergeSort
        (kvE2_sepSlotMergeLe (kvE2_sepHonestOrder qnf M w x t h)))
      ((kvE2_sepPosI qnf).flatMap F) :=
    (List.mergeSort_perm _ _).trans (hp2.flatMap_right F)
  rw [List.Perm.nodup_iff (hp1.map (kvE2_sepSlotGIdx (kvE2_sepHonestOrder qnf M w x t h)))]
  -- On the union the merge key reads the value-faithful index (halign bridge).
  have hcongr : ((kvE2_sepPosI qnf).flatMap F).map
        (kvE2_sepSlotGIdx (kvE2_sepHonestOrder qnf M w x t h))
      = ((kvE2_sepPosI qnf).flatMap F).map (kvE2_sepSlotHonestGIdx qnf M w x t h) := by
    apply List.map_congr_left
    intro s hs
    obtain ⟨σ, hσ, hsF⟩ := List.mem_flatMap.mp hs
    exact kvE2_sepSlotGIdx_honestOrder qnf M w x t h (kvE2_sepPosI_subset hσ)
      ((hFsub σ).subset hsF)
  rw [hcongr]
  -- The union is a sublist of the full family; transfer the global value-rank Nodup.
  have hsub : List.Sublist ((kvE2_sepPosI qnf).flatMap F) (kvE2_sepAllSlots qnf) := by
    show List.Sublist ((kvE2_sepPosI qnf).flatMap F)
      ((kvE2_sepPosI qnf).flatMap kvE2_sepSlotBlock)
    exact kvE2_sep_flatMap_sublist F kvE2_sepSlotBlock hFsub _
  exact List.Nodup.sublist (hsub.map (kvE2_sepSlotHonestGIdx qnf M w x t h))
    (kvE2_sepAllSlots_map_honestGIdx_nodup qnf M w x t h)

/-- The honest LEFT merged-chain `kvE2_sepSlotGIdx` payload is duplicate-free — every
    honest LEFT tie class is a singleton. -/
theorem kvE2_sepHonestOrder_slotsLOf_gidx_nodup {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    ((kvE2_sepSlotsLOf (kvE2_sepHonestOrder qnf M w x t h)).map
      (kvE2_sepSlotGIdx (kvE2_sepHonestOrder qnf M w x t h))).Nodup := by
  unfold kvE2_sepSlotsLOf
  exact kvE2_sepHonestOrder_merged_gidx_nodup qnf M w x t h kvE2_sepSlotsLFor
    (fun σ => by
      show List.Sublist (kvE2_sepSlotsLFor σ) (kvE2_sepSlotsLFor σ ++ kvE2_sepSlotsRFor σ)
      exact List.sublist_append_left _ _)

/-- The honest RIGHT merged-chain `kvE2_sepSlotGIdx` payload is duplicate-free — every
    honest RIGHT tie class is a singleton (right mirror). -/
theorem kvE2_sepHonestOrder_slotsROf_gidx_nodup {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    ((kvE2_sepSlotsROf (kvE2_sepHonestOrder qnf M w x t h)).map
      (kvE2_sepSlotGIdx (kvE2_sepHonestOrder qnf M w x t h))).Nodup := by
  unfold kvE2_sepSlotsROf
  exact kvE2_sepHonestOrder_merged_gidx_nodup qnf M w x t h kvE2_sepSlotsRFor
    (fun σ => by
      show List.Sublist (kvE2_sepSlotsRFor σ) (kvE2_sepSlotsLFor σ ++ kvE2_sepSlotsRFor σ)
      exact List.sublist_append_right _ _)

/-- **Phase 5D — the completeness hand-off to task 337** (RELOCATED here in task 342
    Phase 7; statement unchanged). Given an honest realization and the realization of the
    honest disjunct's own FLAT bracket (`hdisj`, the single 337-owned `.holds`), the
    separated body holds at the fixed endpoints `x`, `t`. Wires the Phase-5B carrier member
    `kvE2_sepHonestOrder_mem_arr'` into `kvE2_sepBody_holds_iff.mpr`; post-rewire the
    carrier's disjunct is GROUPED, and the honest order's `kvE2_sepSlotGIdx` payload is
    `Nodup` (`kvE2_sepHonestOrder_slotsLOf/ROf_gidx_nodup`), so its tie classes are
    singletons and the flat `hdisj` converts via `kvE2_sepDisjunct'_map_singleton_iff`.
    UNCONDITIONAL (task 342 Part I): owner interiority is a construction invariant of the
    `kvE2_sepPosI` index — no interiority hypothesis (Rabinovich §5, p.7;
    `kvE2_sepHonest_hLR_absurd` documents why none may return). Complete and axiom-clean UP
    TO the delegated `.holds` — the sanctioned Phase-5 completion boundary. Task 342
    Phase 9: this is the SINGLETON (tie-free degenerate) variant — the lex payload forces
    singleton tie classes, so the flat `hdisj` suffices; the PRIMARY completeness statement
    covering genuinely-tied honest models is `kvE2_sepBody_complete_holds'` below, stated
    over the tie-grouped disjunct of the tie-reporting order `kvE2_sepHonestOrder'`. -/
theorem kvE2_sepBody_complete_holds {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (hg : kvE2_sepGate qnf)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hdisj : (kvE2_sepDisjunct charBase charK qnf
        (kvE2_sepSlotsLOf (kvE2_sepHonestOrder qnf M w x t h))
        (kvE2_sepSlotsROf (kvE2_sepHonestOrder qnf M w x t h))).2.holds M atomMap x t) :
    (kvE2_sepBody charBase charK qnf).holds M atomMap x t := by
  rw [kvE2_sepBody_holds_iff charBase charK qnf hg M atomMap x t]
  refine ⟨kvE2_sepHonestOrder qnf M w x t h,
    kvE2_sepHonestOrder_mem_arr' qnf M w x t hxw hwt h, ?_⟩
  rw [kvE2_sepTieGroupedL_of_nodup _ (kvE2_sepHonestOrder_slotsLOf_gidx_nodup qnf M w x t h),
    kvE2_sepTieGroupedR_of_nodup _ (kvE2_sepHonestOrder_slotsROf_gidx_nodup qnf M w x t h)]
  exact (kvE2_sepDisjunct'_map_singleton_iff charBase charK qnf _ _ M atomMap x t).mpr hdisj

/-- **Phase-3 adversarial finding (task 337, cycle 11): the interior-restriction hypothesis
    `hLR` is INCONSISTENT with the honest evaluation `h`.** The characteristic depth-1 type
    `σ_w` of the configuration `(w; w, x, t)` — the shared witness read AT ITSELF — is always
    realized (witness `x1 := w`, `nf_characteristic_satisfies`), so `h`'s quantifier layer
    forces `qnf.2 σ_w = true`, i.e. `σ_w ∈ kvE2_sepPos qnf`. But `σ_w`'s ordering channel at
    the `w`-coordinate is the self-zone pair `(false, false)` (`w < w` is irreflexive), so
    `nf0_zoneSpec σ_w.1` is neither `kvE2_sep_zXW3` (which demands `(true, false)` there) nor
    `kvE2_sep_zWT3` (`(false, true)`) — contradicting `hLR σ_w`. The same construction at
    `x1 := x` / `x1 := t` populates `zAtX3` / `zAtT3`, so EVERY honest `qnf` has positive
    owners in at least three non-interior classes. Consequence: every completeness-layer
    theorem conditional on `h ∧ hLR` (`kvE2_sepBody_complete`,
    `kvE2_sepCoincidentOrder_mem_arr'`, `kvE2_sepBody_complete_holds`, and the task-337
    Phase-3/4 builders) is vacuously true as stated; a NON-vacuous completeness statement
    must carry the boundary/self-zone positive classes through the endpoint/pivot literal
    machinery (`kvE2_sepEpL`/`kvE2_sepEpR`/`kvE2_sepPtW` already enumerate their
    `kvE2_sepHasPos` bits) instead of excluding them by hypothesis. -/
theorem kvE2_sepHonest_hLR_absurd {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig)
    (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hLR : ∀ σ ∈ kvE2_sepPos qnf,
        nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3) :
    False := by
  -- The characteristic depth-1 type of `(w; w, x, t)`: always realized with witness `w`.
  have hreal : nf_eval_nf M 1 4 (Fin.cons w (Fin.cons w (Fin.cons x (fun _ => t))))
      (nf_characteristic M 1 4 (Fin.cons w (Fin.cons w (Fin.cons x (fun _ => t))))) :=
    nf_characteristic_satisfies M 1 4 _
  set σw : NormalForm sig 1 4 :=
    nf_characteristic M 1 4 (Fin.cons w (Fin.cons w (Fin.cons x (fun _ => t)))) with hσw
  -- `h`'s quantifier layer forces the bit: `σw` is a positive owner.
  have hbit : qnf.2 σw = true := (h.2 σw).mp ⟨w, hreal⟩
  have hmem : σw ∈ kvE2_sepPos qnf := by
    rw [kvE2_sepPos, List.mem_filter]
    exact ⟨Finset.mem_toList.mpr (Finset.mem_univ _), hbit⟩
  -- `σw`'s w-coordinate ordering pair is the self-zone `(false, false)`.
  have hzw : nf0_zoneSpec σw.1 ⟨0, by omega⟩ = (false, false) := by
    rw [hσw]
    show (nf_characteristic M 1 4 _ |>.1 (.order 0 (Fin.succ ⟨0, by omega⟩)
        (Fin.succ_ne_zero ⟨0, by omega⟩).symm),
      nf_characteristic M 1 4 _ |>.1 (.order (Fin.succ ⟨0, by omega⟩) 0
        (Fin.succ_ne_zero ⟨0, by omega⟩))) = (false, false)
    simp only [nf_characteristic]
    refine Prod.ext ?_ ?_ <;>
      · simp only [decide_eq_false_iff_not, atom_eval, Fin.cons]
        exact lt_irrefl w
  rcases hLR σw hmem with hz | hz
  · have h0 := congrFun hz ⟨0, by omega⟩
    rw [hzw] at h0
    exact absurd h0.symm (by rw [kvE2_sep_zXW3]; simp)
  · have h0 := congrFun hz ⟨0, by omega⟩
    rw [hzw] at h0
    exact absurd h0.symm (by rw [kvE2_sep_zWT3]; simp)

/-! ### Task 342 Phase 9 — the tie-REPORTING honest order and the target completeness statement

The Phase 5B/5C honest order (`kvE2_sepHonestOrder`) carries the LEX payload
`(model value, slot index)`: the index tiebreak makes every honest tie class a SINGLETON, so the
tie-admitting carrier machinery (Phases 6/7) is never exercised by it. Phase 9 installs the
value-ONLY payload `kvE2_sepSlotHonestVIdx` (drop the index tiebreak; `kvE2_ordRank` needs no
injectivity): its ranks are EQUAL exactly where honest slot VALUES coincide
(`kvE2_sepSlotHonestVIdx_eq_iff`), so a genuinely-tied honest model produces genuinely
non-singleton tie classes — the payload REPORTS the tie instead of breaking it. Tie classes
remain INDEX-LEVEL data only (strict-quotient guard): every emitted disjunct is a strict
Def-3.1 bracket, one slot per class, point type = the meet of the tied types. Forced by
Def 3.1 (p.4); Lemma 3.2(1) states the closure without printed proof; corroborated by the
k=m split (p.7) and Def 7.5 (p.13). Anchor-anchor ties stay excluded via the task-340
Phase 5A keystone route (`nf_eval_unique` — a Lean-side, machine-checked pruning with NO
Rabinovich counterpart, audit note D7). -/

/-- **Rank-equality reports value-equality** (task 342 Phase 9 payload keystone): under ANY
    family `g`, two indices have equal `kvE2_ordRank` iff their `g`-values are equal. The
    `mpr` is definitional (the strictly-smaller filter set depends only on the value); the
    `mp` is trichotomy + `kvE2_ordRank_strictMono`. This is what makes the value-only rank a
    TIE-REPORTING payload: equal indices exactly where values coincide. -/
theorem kvE2_ordRank_eq_iff {β : Type*} [LinearOrder β] {n : ℕ} (g : Fin n → β) (a b : Fin n) :
    kvE2_ordRank g a = kvE2_ordRank g b ↔ g a = g b := by
  constructor
  · intro hrank
    rcases lt_trichotomy (g a) (g b) with hlt | heq | hgt
    · exact absurd hrank (Nat.ne_of_lt (kvE2_ordRank_strictMono g hlt))
    · exact heq
    · exact absurd hrank.symm (Nat.ne_of_lt (kvE2_ordRank_strictMono g hgt))
  · intro hval
    unfold kvE2_ordRank
    simp only [hval]

/-- **The honest slot-VALUE family** (task 342 Phase 9): the plain (non-lex) value family over
    the full individual-slot enumeration — `V j = value((allSlots).get j)`. NOT injective in
    general: distinct slots may share an honest value (the tie the value-only rank reports). -/
noncomputable def kvE2_sepSlotV {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    Fin (kvE2_sepAllSlots qnf).length → M.carrier :=
  fun j => kvE2_sepSlotValue qnf M w x t h ((kvE2_sepAllSlots qnf).get j)

/-- The value family at an index is the slot value of the enumerated slot (definitional). -/
theorem kvE2_sepSlotV_get {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (j : Fin (kvE2_sepAllSlots qnf).length) :
    kvE2_sepSlotV qnf M w x t h j
      = kvE2_sepSlotValue qnf M w x t h ((kvE2_sepAllSlots qnf).get j) := rfl

/-- **The tie-reporting per-slot index** (task 342 Phase 9): slot `s`'s VALUE-ONLY rank
    `kvE2_ordRank (kvE2_sepSlotV …)` at its family position — the slot-index lex tiebreak of
    `kvE2_sepSlotHonestGIdx` is DROPPED (`kvE2_ordRank` needs no injectivity), so two slots
    receive EQUAL indices exactly when their honest values coincide
    (`kvE2_sepSlotHonestVIdx_eq_iff`). A new parallel definition; the banked lex machinery is
    untouched. Off-family defaults to `0`. -/
noncomputable def kvE2_sepSlotHonestVIdx {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (s : KvE2SepSlot sig) : ℕ :=
  if hs : kvE2_sepSlotIndexOf qnf s < (kvE2_sepAllSlots qnf).length then
    kvE2_ordRank (kvE2_sepSlotV qnf M w x t h) ⟨kvE2_sepSlotIndexOf qnf s, hs⟩
  else 0

/-- **Strict monotonicity of the tie-reporting index** (Phase 9 conjunct-(ii) engine): a
    strictly smaller honest value gives a strictly smaller value-only rank. Direct
    `kvE2_ordRank_strictMono` — needs only the single strict inequality. -/
theorem kvE2_sepSlotHonestVIdx_mono {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {a b : KvE2SepSlot sig} (ha : a ∈ kvE2_sepAllSlots qnf) (hb : b ∈ kvE2_sepAllSlots qnf)
    (hlt : kvE2_sepSlotValue qnf M w x t h a < kvE2_sepSlotValue qnf M w x t h b) :
    kvE2_sepSlotHonestVIdx qnf M w x t h a < kvE2_sepSlotHonestVIdx qnf M w x t h b := by
  have hal : kvE2_sepSlotIndexOf qnf a < (kvE2_sepAllSlots qnf).length :=
    kvE2_sepSlotIndexOf_lt qnf ha
  have hbl : kvE2_sepSlotIndexOf qnf b < (kvE2_sepAllSlots qnf).length :=
    kvE2_sepSlotIndexOf_lt qnf hb
  have hga : (kvE2_sepAllSlots qnf).get ⟨kvE2_sepSlotIndexOf qnf a, hal⟩ = a := List.idxOf_get hal
  have hgb : (kvE2_sepAllSlots qnf).get ⟨kvE2_sepSlotIndexOf qnf b, hbl⟩ = b := List.idxOf_get hbl
  unfold kvE2_sepSlotHonestVIdx
  rw [dif_pos hal, dif_pos hbl]
  apply kvE2_ordRank_strictMono
  rw [kvE2_sepSlotV_get, kvE2_sepSlotV_get, hga, hgb]
  exact hlt

/-- **The tie-reporting payload law** (task 342 Phase 9 — the deliverable this phase exists
    for): on family members, the value-only ranks are EQUAL exactly where the honest slot
    VALUES coincide. This is what makes honest tie classes non-singleton when the model
    genuinely ties — the payload reports the tie (Def 3.1 equality case, p.4) instead of
    breaking it with the slot-index tiebreak. -/
theorem kvE2_sepSlotHonestVIdx_eq_iff {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {a b : KvE2SepSlot sig} (ha : a ∈ kvE2_sepAllSlots qnf) (hb : b ∈ kvE2_sepAllSlots qnf) :
    kvE2_sepSlotHonestVIdx qnf M w x t h a = kvE2_sepSlotHonestVIdx qnf M w x t h b ↔
      kvE2_sepSlotValue qnf M w x t h a = kvE2_sepSlotValue qnf M w x t h b := by
  have hal : kvE2_sepSlotIndexOf qnf a < (kvE2_sepAllSlots qnf).length :=
    kvE2_sepSlotIndexOf_lt qnf ha
  have hbl : kvE2_sepSlotIndexOf qnf b < (kvE2_sepAllSlots qnf).length :=
    kvE2_sepSlotIndexOf_lt qnf hb
  have hga : (kvE2_sepAllSlots qnf).get ⟨kvE2_sepSlotIndexOf qnf a, hal⟩ = a := List.idxOf_get hal
  have hgb : (kvE2_sepAllSlots qnf).get ⟨kvE2_sepSlotIndexOf qnf b, hbl⟩ = b := List.idxOf_get hbl
  unfold kvE2_sepSlotHonestVIdx
  rw [dif_pos hal, dif_pos hbl, kvE2_ordRank_eq_iff,
    kvE2_sepSlotV_get, kvE2_sepSlotV_get, hga, hgb]

/-- **Honest consistency, tie-reporting payload** (Phase 9 conjunct (ii)): the payload
    `block.map kvE2_sepSlotHonestVIdx` extends every region order. Own-slot ties CANNOT occur:
    within a region the owner's rank-ordered slot values are STRICTLY increasing — its base
    witnesses lie strictly inside their sub-intervals, strictly separated from the own anchor
    (`kvE2_sepSlotValue_region_rank_mono`, fed by the honest bundles) — so the value-only ranks
    are strictly increasing (`kvE2_sepSlotHonestVIdx_mono`); ties can only be CROSS-owner. -/
theorem kvE2_sepConsistentBlock_honestV {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf) :
    kvE2_sepConsistentBlock σ
      ((kvE2_sepSlotBlock σ).map (kvE2_sepSlotHonestVIdx qnf M w x t h)) = true := by
  rw [kvE2_sepConsistentBlock, decide_eq_true_eq]
  intro j k hreg hrank
  rw [kvE2_sepBlockMap_getD, kvE2_sepBlockMap_getD]
  have hjmem : (kvE2_sepSlotBlock σ).get j ∈ kvE2_sepSlotBlock σ := List.get_mem _ _
  have hkmem : (kvE2_sepSlotBlock σ).get k ∈ kvE2_sepSlotBlock σ := List.get_mem _ _
  refine kvE2_sepSlotHonestVIdx_mono qnf M w x t h
    (kvE2_sepMem_allSlots qnf hσ hjmem) (kvE2_sepMem_allSlots qnf hσ hkmem) ?_
  exact kvE2_sepSlotValue_region_rank_mono qnf M w x t hxw hwt h hσ hjmem hkmem hreg hrank

/-- The anchor slot's honest value is its owner's canonical anchor value (both placement
    branches are definitional instances of `kvE2_sepSlotValue_lX1`/`_rX1`). -/
theorem kvE2_sepSlotValue_anchorSlot {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (σ : NormalForm sig 1 4) :
    kvE2_sepSlotValue qnf M w x t h (kvE2_sepAnchorSlot σ)
      = kvE2_sepAnchorVal qnf M w x t h σ := by
  rw [kvE2_sepAnchorSlot]; split <;> rfl

/-- **Base-slot honest realization** (Phase 9 conjunct-(iv) ingredient): every base slot of a
    positive owner's block realizes its base type AT its own honest slot value. Dispatches the
    block membership over the region-block constructors and reads each case off its banked
    Phase-6 value spec (the anchor slots carry no base type and are excluded by `hbt`). -/
theorem kvE2_sepSlotValue_baseType_spec {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {τ : NormalForm sig 1 4} (hτ : τ ∈ kvE2_sepPos qnf)
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2_sepSlotBlock τ)
    {χ : NormalForm sig 0 1} (hbt : kvE2_sepSlotBaseType s = some χ) :
    nf_eval_nf M 0 1 (fun _ => kvE2_sepSlotValue qnf M w x t h s) χ := by
  rw [kvE2_sepMem_slotBlock] at hs
  by_cases hz1 : nf0_zoneSpec τ.1 = kvE2_sep_zXW3
  · rw [kvE2_sepSlotsLFor, kvE2_sepSlotsRFor, if_pos hz1, if_pos hz1] at hs
    rcases hs with hL | hR
    · rcases List.mem_append.mp hL with h1 | h1
      · obtain ⟨χ', hχ', rfl⟩ := List.mem_map.mp h1
        simp only [kvE2_sepSlotBaseType, Option.some.injEq] at hbt
        subst hbt
        exact (kvE2_sepSlotValue_lXU_spec qnf M w x t hxw hwt h τ hτ hz1 _ hχ').2.2
      · rcases List.mem_cons.mp h1 with rfl | h1
        · simp [kvE2_sepSlotBaseType] at hbt
        · obtain ⟨χ', hχ', rfl⟩ := List.mem_map.mp h1
          simp only [kvE2_sepSlotBaseType, Option.some.injEq] at hbt
          subst hbt
          exact (kvE2_sepSlotValue_lUW_spec qnf M w x t hxw hwt h τ hτ hz1 _ hχ').2.2
    · obtain ⟨χ', hχ', rfl⟩ := List.mem_map.mp hR
      simp only [kvE2_sepSlotBaseType, Option.some.injEq] at hbt
      subst hbt
      exact (kvE2_sepSlotValue_lWT_spec qnf M w x t h τ hτ _ hχ').2.2
  · by_cases hz2 : nf0_zoneSpec τ.1 = kvE2_sep_zWT3
    · rw [kvE2_sepSlotsLFor, kvE2_sepSlotsRFor, if_neg hz1, if_neg hz1,
        if_pos hz2, if_pos hz2] at hs
      rcases hs with hL | hR
      · obtain ⟨χ', hχ', rfl⟩ := List.mem_map.mp hL
        simp only [kvE2_sepSlotBaseType, Option.some.injEq] at hbt
        subst hbt
        exact (kvE2_sepSlotValue_rXW_spec qnf M w x t h τ hτ _ hχ').2.2
      · rcases List.mem_append.mp hR with h1 | h1
        · obtain ⟨χ', hχ', rfl⟩ := List.mem_map.mp h1
          simp only [kvE2_sepSlotBaseType, Option.some.injEq] at hbt
          subst hbt
          exact (kvE2_sepSlotValue_rWX1_spec qnf M w x t hxw hwt h τ hτ hz2 _ hχ').2.2
        · rcases List.mem_cons.mp h1 with rfl | h1
          · simp [kvE2_sepSlotBaseType] at hbt
          · obtain ⟨χ', hχ', rfl⟩ := List.mem_map.mp h1
            simp only [kvE2_sepSlotBaseType, Option.some.injEq] at hbt
            subst hbt
            exact (kvE2_sepSlotValue_rX1T_spec qnf M w x t hxw hwt h τ hτ hz2 _ hχ').2.2
    · rw [kvE2_sepSlotsLFor, kvE2_sepSlotsRFor, if_neg hz1, if_neg hz1,
        if_neg hz2, if_neg hz2] at hs
      simp only [List.not_mem_nil, or_self] at hs

/-- **The tie-REPORTING honest order** (task 342 Phase 9): all interior owners
    `.coincident`-tagged with the value-ONLY rank payload `block.map kvE2_sepSlotHonestVIdx`.
    Structural mirror of `kvE2_sepHonestOrder` with the tie-reporting payload: where
    `kvE2_sepHonestOrder`'s lex tiebreak forces singleton tie classes, this order's payload
    is EQUAL exactly where honest values coincide, so a genuinely-tied honest model yields
    genuinely non-singleton tie classes under the tie-admitting carrier (Def 3.1 equality
    case, p.4). Tie classes remain index-level data only (strict-quotient guard). -/
noncomputable def kvE2_sepHonestOrder' {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) : KvE2SepWeakOrder sig :=
  (kvE2_sepPosI qnf).zipIdx.map
    (fun p => (p.1, KvE2SepSpikeOrderType.coincident,
      (kvE2_sepSlotBlock p.1).map (kvE2_sepSlotHonestVIdx qnf M w x t h)))

/-- The tie-reporting honest order is present in the enumeration index (F2): a
    `kvE2_sepOrderTypes_mem_aux'` instance (`s = 0`, all-coincident tags, value-rank tuple);
    every tuple component `< n` from `kvE2_ordRank_lt`. UNCONDITIONAL: carrier and enumeration
    fold both range over the interior index `kvE2_sepPosI`. -/
theorem kvE2_sepHonestOrder'_mem_orderTypes {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    kvE2_sepHonestOrder' qnf M w x t h ∈ kvE2_sepOrderTypes qnf := by
  rw [kvE2_sepHonestOrder', kvE2_sepOrderTypes]
  refine kvE2_sepOrderTypes_mem_aux' (fun _ => KvE2SepSpikeOrderType.coincident) _
    (fun σ => (kvE2_sepSlotBlock σ).map (kvE2_sepSlotHonestVIdx qnf M w x t h))
    (kvE2_sepPosI qnf) 0 (fun σ hσ => ?_)
  have h := kvE2_sepIdxTupleN_mem_of_forall_lt (kvE2_sepAllSlots qnf).length
    ((kvE2_sepSlotBlock σ).map (kvE2_sepSlotHonestVIdx qnf M w x t h)) (fun y hy => by
      obtain ⟨s, hs, rfl⟩ := List.mem_map.mp hy
      have hidx := kvE2_sepSlotIndexOf_lt qnf
        (kvE2_sepMem_allSlots qnf (kvE2_sepPosI_subset hσ) hs)
      rw [kvE2_sepSlotHonestVIdx, dif_pos hidx]
      exact kvE2_ordRank_lt _ _)
  rwa [List.length_map] at h

/-- **Anchor-distinct conjunct (iii′) for the tie-reporting order** (Phase 9): cross-owner
    ANCHOR payload indices are pairwise distinct. The 5A keystone route: distinct interior
    owners have distinct anchor VALUES (`kvE2_sepAnchor_injOn` via `nf_eval_unique` — the
    Lean-side pruning with no Rabinovich counterpart, D7), and the value-only rank is
    injective on distinct values (`kvE2_ordRank_eq_iff` both ways). Reads no zone bit. -/
theorem kvE2_sepHonestOrder'_anchorDistinct {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    kvE2_sepAnchorDistinct (kvE2_sepHonestOrder' qnf M w x t h) = true := by
  rw [kvE2_sepHonestOrder', kvE2_sepAnchorDistinct, decide_eq_true_eq, List.map_map]
  have hcongr : ((kvE2_sepPosI qnf).zipIdx.map
        (kvE2_sepAnchorPayload ∘
          (fun p => (p.1, KvE2SepSpikeOrderType.coincident,
            (kvE2_sepSlotBlock p.1).map (kvE2_sepSlotHonestVIdx qnf M w x t h)))))
      = (kvE2_sepPosI qnf).zipIdx.map
          (fun p => kvE2_sepSlotHonestVIdx qnf M w x t h (kvE2_sepAnchorSlot p.1)) := by
    apply List.map_congr_left
    intro p hp
    exact kvE2_sepAnchorPayload_map _ KvE2SepSpikeOrderType.coincident
      (kvE2_sepPosI_zone (List.fst_mem_of_mem_zipIdx hp))
  rw [hcongr]
  have hfst : (kvE2_sepPosI qnf).zipIdx.map
        (fun p => kvE2_sepSlotHonestVIdx qnf M w x t h (kvE2_sepAnchorSlot p.1))
      = (kvE2_sepPosI qnf).map
          (fun σ => kvE2_sepSlotHonestVIdx qnf M w x t h (kvE2_sepAnchorSlot σ)) := by
    conv_rhs => rw [← List.zipIdx_map_fst 0 (kvE2_sepPosI qnf)]
    rw [List.map_map]
    rfl
  rw [hfst]
  refine List.Nodup.map_on (fun σ hσ τ hτ heq => ?_) (kvE2_sepPosI_nodup qnf)
  have hσa := kvE2_sepAnchorSlot_mem_block (kvE2_sepPosI_zone hσ)
  have hτa := kvE2_sepAnchorSlot_mem_block (kvE2_sepPosI_zone hτ)
  have hveq := (kvE2_sepSlotHonestVIdx_eq_iff qnf M w x t h
    (kvE2_sepMem_allSlots qnf (kvE2_sepPosI_subset hσ) hσa)
    (kvE2_sepMem_allSlots qnf (kvE2_sepPosI_subset hτ) hτa)).mp heq
  rw [kvE2_sepSlotValue_anchorSlot, kvE2_sepSlotValue_anchorSlot] at hveq
  exact kvE2_sepAnchor_injOn qnf M w x t h
    (kvE2_sepPosI_subset hσ) (kvE2_sepPosI_subset hτ) hveq

/-- **Tie-class validity conjunct (iv) for the tie-reporting order** (Phase 9 — the conjunct
    the Phase 8 (a) discharges were shaped for): every anchor-involved payload tie is
    discharged. Route: `kvE2_sepTieRead_of_discharge` reduces (iv) to the per-(anchor,
    base-χ) obligation; equal value-only ranks give equal honest slot VALUES
    (`kvE2_sepSlotHonestVIdx_eq_iff`); the anchor slot's honest value is its owner's
    `kvE2_sepAnchorVal` and the base slot's value realizes χ
    (`kvE2_sepSlotValue_baseType_spec`), so χ is realized AT the anchor value — exactly
    `kvE2_sepClosedLeafAt_discharge_honest`. F5: the only key entering the read is the CLOSED
    self-zone key; base-base ties are read-free (machine-checked in the intro rule). -/
theorem kvE2_sepHonestOrder'_tieRead {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    kvE2_sepTieRead (kvE2_sepHonestOrder' qnf M w x t h) = true := by
  apply kvE2_sepTieRead_of_discharge
  intro p hp q hq sj hsj sk hsk hanch heq χ hbt
  rw [kvE2_sepHonestOrder'] at hp hq
  obtain ⟨p', hp', rfl⟩ := List.mem_map.mp hp
  obtain ⟨q', hq', rfl⟩ := List.mem_map.mp hq
  have hσI : p'.1 ∈ kvE2_sepPosI qnf := List.fst_mem_of_mem_zipIdx hp'
  have hτI : q'.1 ∈ kvE2_sepPosI qnf := List.fst_mem_of_mem_zipIdx hq'
  obtain ⟨hjlt, hjeq⟩ := List.getElem?_eq_some_iff.mp
    (List.mem_zipIdx_iff_getElem?.mp hsj)
  obtain ⟨hklt, hkeq⟩ := List.getElem?_eq_some_iff.mp
    (List.mem_zipIdx_iff_getElem?.mp hsk)
  have hread1 : ((kvE2_sepSlotBlock p'.1).map
        (kvE2_sepSlotHonestVIdx qnf M w x t h)).getD sj.2 0
      = kvE2_sepSlotHonestVIdx qnf M w x t h ((kvE2_sepSlotBlock p'.1).get ⟨sj.2, hjlt⟩) :=
    kvE2_sepBlockMap_getD p'.1 _ ⟨sj.2, hjlt⟩
  have hread2 : ((kvE2_sepSlotBlock q'.1).map
        (kvE2_sepSlotHonestVIdx qnf M w x t h)).getD sk.2 0
      = kvE2_sepSlotHonestVIdx qnf M w x t h ((kvE2_sepSlotBlock q'.1).get ⟨sk.2, hklt⟩) :=
    kvE2_sepBlockMap_getD q'.1 _ ⟨sk.2, hklt⟩
  simp only [List.get_eq_getElem, hjeq, hkeq] at hread1 hread2
  rw [hread1, hread2] at heq
  have hjm : sj.1 ∈ kvE2_sepSlotBlock p'.1 := hjeq ▸ List.getElem_mem hjlt
  have hkm : sk.1 ∈ kvE2_sepSlotBlock q'.1 := hkeq ▸ List.getElem_mem hklt
  -- Equal value-only ranks report equal honest slot VALUES (the tie-reporting law).
  have hveq : kvE2_sepSlotValue qnf M w x t h sj.1 = kvE2_sepSlotValue qnf M w x t h sk.1 :=
    (kvE2_sepSlotHonestVIdx_eq_iff qnf M w x t h
      (kvE2_sepMem_allSlots qnf (kvE2_sepPosI_subset hσI) hjm)
      (kvE2_sepMem_allSlots qnf (kvE2_sepPosI_subset hτI) hkm)).mp heq
  -- The anchor slot's honest value is its owner's canonical anchor value.
  have hanchval : kvE2_sepSlotValue qnf M w x t h sj.1
      = kvE2_sepAnchorVal qnf M w x t h p'.1 := by
    have hsub : kvE2_sepSlotSub sj.1 = p'.1 := kvE2_sepSlotSub_of_mem_block hjm
    cases hs1 : sj.1 with
    | lX1 ρ =>
      rw [hs1] at hsub
      simp only [kvE2_sepSlotSub] at hsub
      rw [hsub, kvE2_sepSlotValue_lX1]
    | rX1 ρ =>
      rw [hs1] at hsub
      simp only [kvE2_sepSlotSub] at hsub
      rw [hsub, kvE2_sepSlotValue_rX1]
    | lXU ρ χ' => rw [hs1] at hanch; simp [kvE2_sepSlotIsAnchor] at hanch
    | lUW ρ χ' => rw [hs1] at hanch; simp [kvE2_sepSlotIsAnchor] at hanch
    | lWT ρ χ' => rw [hs1] at hanch; simp [kvE2_sepSlotIsAnchor] at hanch
    | rXW ρ χ' => rw [hs1] at hanch; simp [kvE2_sepSlotIsAnchor] at hanch
    | rWX1 ρ χ' => rw [hs1] at hanch; simp [kvE2_sepSlotIsAnchor] at hanch
    | rX1T ρ χ' => rw [hs1] at hanch; simp [kvE2_sepSlotIsAnchor] at hanch
  -- The tied base slot realizes χ at its own honest value = the anchor value.
  have hχreal := kvE2_sepSlotValue_baseType_spec qnf M w x t hxw hwt h
    (kvE2_sepPosI_subset hτI) hkm hbt
  rw [← hveq, hanchval] at hχreal
  exact kvE2_sepClosedLeafAt_discharge_honest qnf M w x t hxw hwt h hσI χ hχreal

/-- **The tie-reporting honest order is a carrier member** (task 342 Phase 9 — the membership
    `kvE2_sepBody_complete_holds'` wires into the completeness hand-off). UNCONDITIONAL:
    owner interiority is a construction invariant of the `kvE2_sepPosI` index (Rabinovich §5,
    p.7), recovered via `kvE2_sepPosI_zone`, never hypothesized. The `kvE2_sepDisjValid`
    conjuncts: (i) all-`.coincident` validity reuses
    `kvE2_sepCoincidentOwner_valid_left/right` VERBATIM (tuple-agnostic, CLOSED self-zone
    bit only); (ii) consistency via `kvE2_sepConsistentBlock_honestV` (own-slot ties cannot
    occur — the owner's own region values are strictly separated); (iii′) anchor-distinct
    via the 5A keystone (D7 — Lean-side pruning, no paper counterpart); (iv) tie-class reads
    via the Phase 8 (a) foreign-base CLOSED-key discharges. Unlike
    `kvE2_sepHonestOrder_mem_arr'`, the tie conjuncts are NOT vacuous here: the payload
    admits genuine cross-owner ties, and (iv) discharges them honestly. -/
theorem kvE2_sepHonestOrder'_mem_arr' {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    kvE2_sepHonestOrder' qnf M w x t h ∈ kvE2_sepArr' qnf := by
  rw [kvE2_sepArr', List.mem_filter]
  refine ⟨kvE2_sepHonestOrder'_mem_orderTypes qnf M w x t h, ?_⟩
  rw [kvE2_sepDisjValid, Bool.and_eq_true, Bool.and_eq_true, Bool.and_eq_true]
  refine ⟨⟨⟨?_, ?_⟩, ?_⟩, ?_⟩
  · -- (i) per-owner closed-self-zone validity (all tags `.coincident`), reused verbatim
    -- (definitional interiority via `kvE2_sepPosI_zone` — a construction invariant).
    rw [List.all_eq_true]
    intro p hp
    rw [kvE2_sepHonestOrder', List.mem_map] at hp
    obtain ⟨⟨σ, i⟩, hmem, rfl⟩ := hp
    have hσmem : σ ∈ kvE2_sepPosI qnf := List.fst_mem_of_mem_zipIdx hmem
    show kvE2_sepDisjValidOwner σ KvE2SepSpikeOrderType.coincident = true
    rcases kvE2_sepPosI_zone hσmem with hzone | hzone
    · exact kvE2_sepCoincidentOwner_valid_left qnf M w x t hxw hwt h σ
        (kvE2_sepPosI_subset hσmem) hzone
    · exact kvE2_sepCoincidentOwner_valid_right qnf M w x t hxw hwt h σ
        (kvE2_sepPosI_subset hσmem) hzone
  · -- (ii) per-owner region-scoped consistency via the value-only monotonicity engine.
    rw [List.all_eq_true]
    intro p hp
    rw [kvE2_sepHonestOrder', List.mem_map] at hp
    obtain ⟨⟨σ, k⟩, hmem, rfl⟩ := hp
    have hσmem : σ ∈ kvE2_sepPosI qnf := List.fst_mem_of_mem_zipIdx hmem
    exact kvE2_sepConsistentBlock_honestV qnf M w x t hxw hwt h (kvE2_sepPosI_subset hσmem)
  · -- (iii′) anchor-distinct: the 5A keystone route (D7).
    exact kvE2_sepHonestOrder'_anchorDistinct qnf M w x t h
  · -- (iv) tie-class reads: the Phase 8 (a) foreign-base CLOSED-key discharges.
    exact kvE2_sepHonestOrder'_tieRead qnf M w x t hxw hwt h

/-- **The task-342 target completeness statement — `kvE2_sepBody_complete_holds'`** (report 07
    §4 shape; the PRIMARY completeness hand-off of this development). Given an honest
    realization and the realization of the tie-reporting honest order's own GROUPED disjunct
    (`hdisj`, taken over the tie-grouped `kvE2_sepTieGroupedL/R (kvE2_sepHonestOrder' …)` —
    NOT flattened through a singleton conversion), the separated body holds at the fixed
    endpoints. No `hLR`-style hypothesis: owners are drawn from the interior index
    `kvE2_sepPosI` (Rabinovich §5, p.7; `kvE2_sepHonest_hLR_absurd` certifies why no such
    hypothesis may return). Because `kvE2_sepHonestOrder'`'s payload reports ties, this
    statement covers genuinely-tied honest models — the models whose tie classes are
    non-singleton — which the Phase 7 singleton variant `kvE2_sepBody_complete_holds`
    (retained below as the degenerate flat-`hdisj` corollary shape) cannot express. Complete
    and axiom-clean UP TO the delegated `.holds` — the sanctioned completion boundary. -/
theorem kvE2_sepBody_complete_holds' {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (hg : kvE2_sepGate qnf)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hdisj : (kvE2_sepDisjunct' charBase charK qnf
        (kvE2_sepTieGroupedL (kvE2_sepHonestOrder' qnf M w x t h))
        (kvE2_sepTieGroupedR (kvE2_sepHonestOrder' qnf M w x t h))).2.holds M atomMap x t) :
    (kvE2_sepBody charBase charK qnf).holds M atomMap x t := by
  rw [kvE2_sepBody_holds_iff charBase charK qnf hg M atomMap x t]
  exact ⟨kvE2_sepHonestOrder' qnf M w x t h,
    kvE2_sepHonestOrder'_mem_arr' qnf M w x t hxw hwt h, hdisj⟩

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
    Lemma 3.2(1), md:77 at the interleaving membership). Task 342 Part I: the coverage
    hypotheses `hmemL`/`hmemR` quantify over the interior index `kvE2_sepPosI` (the carrier's
    own owner index); the bundle conclusions stay zone-guarded over `kvE2_sepPos`, with
    interiority upgraded via `kvE2_sepPosI_mem`. -/
theorem kvE2_sepDisjunct_extract {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    {lL lR : List (KvE2SepSlot sig)}
    (hmemL : ∀ σ ∈ kvE2_sepPosI qnf, ∀ s ∈ kvE2_sepSlotsLFor σ, s ∈ lL)
    (hpairL : lL.Pairwise (fun a b => kvE2_sepSlotLe a b = true))
    (hmemR : ∀ σ ∈ kvE2_sepPosI qnf, ∀ s ∈ kvE2_sepSlotsRFor σ, s ∈ lR)
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
    have hσI : σ ∈ kvE2_sepPosI qnf :=
      (kvE2_sepPosI_mem qnf σ).mpr ⟨hσpos, Or.inl hzone⟩
    obtain ⟨iσ, hiσ, hgetiσ⟩ := List.mem_iff_getElem.mp
      (hmemL σ hσI _ (kvE2_sep_lX1_mem_slotsLFor hzone))
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
        (hmemL σ hσI _ (kvE2_sep_lXU_mem_slotsLFor hzone hbit))
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
    have hσI : σ ∈ kvE2_sepPosI qnf :=
      (kvE2_sepPosI_mem qnf σ).mpr ⟨hσpos, Or.inr hzone⟩
    obtain ⟨jσ, hjσ, hgetjσ⟩ := List.mem_iff_getElem.mp
      (hmemR σ hσI _ (kvE2_sep_rX1_mem_slotsRFor hzone))
    have hjσm : jσ < (lR.map (kvE2_sepSlotType charBase charK)).length := by
      simp only [List.length_map]; omega
    refine ⟨ws ⟨(lL.map (kvE2_sepSlotType charBase charK)).length + 1 + jσ, by omega⟩,
      hmono _ _ (Fin.mk_lt_mk.mpr (by omega)), (hrange _).2, ?_, ?_⟩
    · have h1 := hpt' ((lL.map (kvE2_sepSlotType charBase charK)).length + 1 + jσ)
        (by omega)
      rwa [kvE2_sep_getElem_right _ _ _ jσ hjσm, List.getElem_map, hgetjσ] at h1
    · intro χ hbit
      obtain ⟨j', hj', hgetj'⟩ := List.mem_iff_getElem.mp
        (hmemR σ hσI _ (kvE2_sep_rWX1_mem_slotsRFor hzone hbit))
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

-- NOTE (task 333 Phase 2, Route A): the former side-condition-laden `kvE2_sepBody_extract`
-- (universal `hpairL`/`hpairR`/`hnd` over all `wo ∈ kvE2_sepArr' qnf` — FALSE for general
-- `qnf`, machine-checked blocker record above at the R2 section) and its tie-free singleton
-- conversion were REPLACED by the hypothesis-free tie-admitting pair
-- `kvE2_sepDisjunct'_extract` / `kvE2_sepBody_extract` below (after the tie-run index
-- lemmas they consume). `kvE2_sepTieGroupedL/R_of_nodup` and
-- `kvE2_sepDisjunct'_map_singleton_iff` remain — the completeness side still uses them.

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
      kvE2_sepAnchorDistinct wo = true ∧ kvE2_sepTieRead wo = true := by
  have hv : kvE2_sepDisjValid qnf wo = true := (List.mem_filter.mp hwo).2
  rw [kvE2_sepDisjValid, Bool.and_eq_true, Bool.and_eq_true, Bool.and_eq_true] at hv
  obtain ⟨⟨⟨hall, _hcons⟩, hanch⟩, htie⟩ := hv
  exact ⟨fun p hp => (List.all_eq_true.mp hall) p hp, hanch, htie⟩

/-! ## Task 342 Phase 8 (b) — honest non-interior evaluation pack

The endpoint/pivot honesty lemmas: from an honest evaluation `h`, the EXISTING literal
conjunctions `kvE2_sepEpL`/`kvE2_sepPtW`/`kvE2_sepEpR` evaluate at their fixed points
`x`/`w`/`t`. These are the obligations previously hidden behind `hLR`'s vacuity
(`kvE2_sepHonest_hLR_absurd`): every honest `qnf` has positive owners in non-interior
classes, and their content rides the endpoint/pivot literals — never the interleaving.
Grounding: Rabinovich §5 (p.7) — the ψ0/ψ1/φ split routes non-interior positive witnesses
to atomic E[Σ] endpoint literals via Prop 3.5 (pp.5,7); this section realizes exactly that
routing in Lean. NO new literal machinery: every case below discharges an EXISTING literal
family of the Part-I predicates (SW:886-946). The char-semantics hypotheses `hcb`/`hck`
are the abstract form of the concrete `nf_depth0_char_formula` correctness
(`nfPred_correct`) that the k1v template consumed (`CarrierK1V.lean:1672`). Witness bounds
come from realized zone membership (the arity-4 zoneHolds cons-iff helper,
`SubBracket2.lean:538`) and the honest realization's own order channel — never a chain
(LITMUS). -/

/-- Bool bridge: an order iff against `b = true` computes the `decide`. -/
private theorem kvE2_sep_decide_eq_of_iff {p : Prop} [Decidable p] {b : Bool}
    (h : p ↔ b = true) : decide p = b := by
  cases b with
  | true => exact decide_eq_true (h.mpr rfl)
  | false => exact decide_eq_false (fun hp => Bool.noConfusion (h.mp hp))

/-- Prefix-restriction evaluation (depth 0): a realized arity-`n` depth-0 NF restricts to
    a realized arity-`m` NF along `Fin.castLE` (the `nfk_take` atom channel is exactly the
    cast-atom read). -/
private theorem kvE2_sep_nfk_take_eval {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) {m n : Nat} (hmn : m ≤ n)
    (env : Fin n → M.carrier) (sub : NormalForm sig 0 n)
    (hs : nf_eval_nf M 0 n env sub) :
    nf_eval_nf M 0 m (fun i => env (Fin.castLE hmn i)) (nfk_take hmn sub) := by
  intro a
  match a with
  | .pred p i => exact hs (.pred p (Fin.castLE hmn i))
  | .order i j hne =>
    exact hs (.order (Fin.castLE hmn i) (Fin.castLE hmn j)
      (fun he => hne (Fin.castLE_injective hmn he)))

/-- **Depth-1 fresh-projection factor** (task 342 Phase 8 (b)): a realized depth-1 owner
    factors through its fresh depth-1 arity-1 projection at the witness point — the depth-1
    analog of `nf_eval_nf0_cons_factor`'s monadic channel (Def 4.1, PDF p.5: the E[Σ]-atom
    channel read at depth 1). The quant layer transports through `nf_characteristic` +
    `nf_eval_unique` (NormalForm.lean:215/245) and the prefix restriction. -/
theorem kvE2_sepProjFresh_eval {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) {n : Nat}
    (env : Fin n → M.carrier) (v : M.carrier)
    (σ : NormalForm sig 1 (n + 1))
    (hσ : nf_eval_nf M 1 (n + 1) (Fin.cons v env) σ) :
    nf_eval_nf M 1 1 (fun _ => v) (nfk_projFresh σ) := by
  have henv : ∀ u : M.carrier,
      (fun i => (Fin.cons u (Fin.cons v env) : Fin (n + 2) → M.carrier)
        (Fin.castLE (Nat.succ_le_succ (Nat.succ_le_succ (Nat.zero_le n))) i))
      = (Fin.cons u (fun _ => v) : Fin 2 → M.carrier) := by
    intro u
    funext i
    match i with
    | ⟨0, _⟩ => rfl
    | ⟨1, _⟩ => rfl
  refine ⟨?_, ?_⟩
  · -- Atom layer: the fresh predicate channel (arity-1 order atoms are uninhabited).
    intro a
    match a with
    | .pred p i =>
      have hi : i = 0 := Subsingleton.elim i 0
      subst hi
      exact hσ.1 (.pred p 0)
    | .order i j hne => exact absurd (Subsingleton.elim i j) hne
  · -- Quant layer: characteristic + uniqueness transport along the prefix restriction.
    intro sub
    simp only [decide_eq_true_eq]
    constructor
    · rintro ⟨u, hu⟩
      have hchar := nf_characteristic_satisfies M 0 (n + 2) (Fin.cons u (Fin.cons v env))
      have hbit : σ.2 (nf_characteristic M 0 (n + 2) (Fin.cons u (Fin.cons v env))) = true :=
        (hσ.2 _).mp ⟨u, hchar⟩
      have htake := kvE2_sep_nfk_take_eval M
        (Nat.succ_le_succ (Nat.succ_le_succ (Nat.zero_le n)))
        (Fin.cons u (Fin.cons v env)) _ hchar
      rw [henv u] at htake
      exact ⟨_, hbit, nf_eval_unique M 0 2 (Fin.cons u (fun _ => v)) _ _ htake hu⟩
    · rintro ⟨sub', hbit, rfl⟩
      obtain ⟨u, hu⟩ := (hσ.2 sub').mpr hbit
      have htake := kvE2_sep_nfk_take_eval M
        (Nat.succ_le_succ (Nat.succ_le_succ (Nat.zero_le n)))
        (Fin.cons u (Fin.cons v env)) sub' hu
      rw [henv u] at htake
      exact ⟨u, htake⟩

/-- Characteristic-type zone computation: the depth-1 arity-4 characteristic of the env
    `[v, w, x, t]` has fresh ordering channel given coordinatewise by the decidable order
    facts of `v` against `[w, x, t]` (Def 3.1 ordering channel, PDF p.4). -/
private theorem kvE2_sepCharZone3 {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (v w x t : M.carrier)
    (p0 p1 p2 : Bool × Bool)
    (h0l : (v < w) ↔ p0.1 = true) (h0r : (w < v) ↔ p0.2 = true)
    (h1l : (v < x) ↔ p1.1 = true) (h1r : (x < v) ↔ p1.2 = true)
    (h2l : (v < t) ↔ p2.1 = true) (h2r : (t < v) ↔ p2.2 = true) :
    nf0_zoneSpec (nf_characteristic M 1 4
        (Fin.cons v (Fin.cons w (Fin.cons x (fun _ => t))))).1
      = (Fin.cons p0 (Fin.cons p1 (fun _ => p2)) : ZoneSpec 3) := by
  have hco : ∀ (i : Fin 3) (pi : Bool × Bool),
      ((v < (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) i) ↔ pi.1 = true) →
      (((Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) i < v) ↔ pi.2 = true) →
      nf0_zoneSpec (nf_characteristic M 1 4
          (Fin.cons v (Fin.cons w (Fin.cons x (fun _ => t))))).1 i = pi := by
    intro i pi hl hr
    refine Prod.ext (@kvE2_sep_decide_eq_of_iff _ (Classical.dec _) _ ?_)
      (@kvE2_sep_decide_eq_of_iff _ (Classical.dec _) _ ?_)
    · simpa only [atom_eval, Fin.cons_zero, Fin.cons_succ] using hl
    · simpa only [atom_eval, Fin.cons_zero, Fin.cons_succ] using hr
  funext i
  match i with
  | ⟨0, hlt⟩ => exact hco ⟨0, hlt⟩ p0 h0l h0r
  | ⟨1, hlt⟩ => exact hco ⟨1, hlt⟩ p1 h1l h1r
  | ⟨2, hlt⟩ => exact hco ⟨2, hlt⟩ p2 h2l h2r

/-- Coordinate projection evaluation (arity 4): σ's depth-0 coordinate-`k` 1-type is
    realized at the env's `k`-th point (reads σ's realized atom layer only). -/
private theorem kvE2_sepProj4_eval {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (env : Fin 4 → M.carrier)
    (σ : NormalForm sig 1 4)
    (hσa : ∀ a : AtomKind sig 4, atom_eval M env a ↔ σ.1 a = true)
    (k : Fin 4) :
    nf_eval_nf M 0 1 (fun _ => env k) (kvE2_sepProj4 σ k) := by
  intro a
  match a with
  | .pred p i => exact hσa (.pred p k)
  | .order i j hne => exact absurd (Subsingleton.elim i j) hne

/-- Coordinate projection evaluation (arity 3, joint base): `qnf.1`'s coordinate-`k`
    1-type is realized at the env's `k`-th point. -/
private theorem kvE2_sepProj3_eval {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (env : Fin 3 → M.carrier)
    (r : NormalForm sig 0 3)
    (hr : ∀ a : AtomKind sig 3, atom_eval M env a ↔ r a = true)
    (k : Fin 3) :
    nf_eval_nf M 0 1 (fun _ => env k) (kvE2_sepProj3 r k) := by
  intro a
  match a with
  | .pred p i => exact hr (.pred p k)
  | .order i j hne => exact absurd (Subsingleton.elim i j) hne

/-- Ordering-channel fact (positive left bit): a realized owner's fresh witness sits
    BELOW env point `i` when its zone bit says so. -/
private theorem kvE2_sepZoneFact_lt {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (a w x t : M.carrier)
    (σ : NormalForm sig 1 4)
    (hσa : ∀ at4 : AtomKind sig 4,
      atom_eval M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) at4 ↔ σ.1 at4 = true)
    (i : Fin 3) (hbit : (nf0_zoneSpec σ.1 i).1 = true) :
    a < (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) i := by
  have h1 := hσa (.order 0 i.succ (Fin.succ_ne_zero i).symm)
  simp only [atom_eval, Fin.cons_zero, Fin.cons_succ] at h1
  exact h1.mpr hbit

/-- Ordering-channel fact (positive right bit): the fresh witness sits ABOVE env point
    `i`. -/
private theorem kvE2_sepZoneFact_gt {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (a w x t : M.carrier)
    (σ : NormalForm sig 1 4)
    (hσa : ∀ at4 : AtomKind sig 4,
      atom_eval M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) at4 ↔ σ.1 at4 = true)
    (i : Fin 3) (hbit : (nf0_zoneSpec σ.1 i).2 = true) :
    (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) i < a := by
  have h1 := hσa (.order i.succ 0 (Fin.succ_ne_zero i))
  simp only [atom_eval, Fin.cons_zero, Fin.cons_succ] at h1
  exact h1.mpr hbit

/-- Ordering-channel fact (negative left bit): the fresh witness is NOT below env point
    `i` (self-zone/boundary extraction seed). -/
private theorem kvE2_sepZoneFact_not_lt {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (a w x t : M.carrier)
    (σ : NormalForm sig 1 4)
    (hσa : ∀ at4 : AtomKind sig 4,
      atom_eval M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) at4 ↔ σ.1 at4 = true)
    (i : Fin 3) (hbit : (nf0_zoneSpec σ.1 i).1 = false) :
    ¬ a < (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) i := by
  have h1 := hσa (.order 0 i.succ (Fin.succ_ne_zero i).symm)
  simp only [atom_eval, Fin.cons_zero, Fin.cons_succ] at h1
  exact fun hc => Bool.noConfusion ((h1.mp hc).symm.trans hbit)

/-- Ordering-channel fact (negative right bit): the fresh witness is NOT above env point
    `i`. -/
private theorem kvE2_sepZoneFact_not_gt {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (a w x t : M.carrier)
    (σ : NormalForm sig 1 4)
    (hσa : ∀ at4 : AtomKind sig 4,
      atom_eval M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) at4 ↔ σ.1 at4 = true)
    (i : Fin 3) (hbit : (nf0_zoneSpec σ.1 i).2 = false) :
    ¬ (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) i < a := by
  have h1 := hσa (.order i.succ 0 (Fin.succ_ne_zero i))
  simp only [atom_eval, Fin.cons_zero, Fin.cons_succ] at h1
  exact fun hc => Bool.noConfusion ((h1.mp hc).symm.trans hbit)

/-- `kvE2_sepHasPos` introduction from an honest realization: a point `s` realizing the
    depth-1 arity-1 type `χ` whose characteristic owner lands in outer class `zs` marks the
    class bit positive (the σ-level literal driver, completeness direction). -/
private theorem kvE2_sepHasPos_of_realized {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig)
    (w x t s : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (zs : ZoneSpec 3)
    (hzs : nf0_zoneSpec (nf_characteristic M 1 4
        (Fin.cons s (Fin.cons w (Fin.cons x (fun _ => t))))).1 = zs)
    (χ : NormalForm sig 1 1)
    (hχ : nf_eval_nf M 1 1 (fun _ => s) χ) :
    kvE2_sepHasPos qnf zs χ = true := by
  have hreal := nf_characteristic_satisfies M 1 4
    (Fin.cons s (Fin.cons w (Fin.cons x (fun _ => t))))
  have hbit : qnf.2 (nf_characteristic M 1 4
      (Fin.cons s (Fin.cons w (Fin.cons x (fun _ => t))))) = true :=
    (h.2 _).mp ⟨s, hreal⟩
  have hproj : nfk_projFresh (nf_characteristic M 1 4
      (Fin.cons s (Fin.cons w (Fin.cons x (fun _ => t))))) = χ :=
    nf_eval_unique M 1 1 (fun _ => s) _ _
      (kvE2_sepProjFresh_eval M _ s _ hreal) hχ
  rw [kvE2_sepHasPos, List.any_eq_true]
  refine ⟨_, ?_, decide_eq_true hproj⟩
  rw [kvE2_sepPosIn, List.mem_filter]
  refine ⟨?_, decide_eq_true hzs⟩
  rw [kvE2_sepPos, List.mem_filter]
  exact ⟨Finset.mem_toList.mpr (Finset.mem_univ _), hbit⟩

/-- `kvE2_sepHasPos` elimination under an honest realization: a positive class bit yields
    a realized owner in that class whose fresh projection IS `χ`, realized at the owner's
    honest witness point. -/
private theorem kvE2_sepHasPos_witness {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig)
    (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (zs : ZoneSpec 3) (χ : NormalForm sig 1 1)
    (hb : kvE2_sepHasPos qnf zs χ = true) :
    ∃ (σ : NormalForm sig 1 4) (s : M.carrier),
      nf0_zoneSpec σ.1 = zs ∧
      nf_eval_nf M 1 4 (Fin.cons s (Fin.cons w (Fin.cons x (fun _ => t)))) σ ∧
      nf_eval_nf M 1 1 (fun _ => s) χ := by
  rw [kvE2_sepHasPos, List.any_eq_true] at hb
  obtain ⟨σ, hσmem, hproj⟩ := hb
  have hzone : nf0_zoneSpec σ.1 = zs :=
    of_decide_eq_true (List.mem_filter.mp hσmem).2
  have hbit : qnf.2 σ = true :=
    (List.mem_filter.mp (List.mem_filter.mp hσmem).1).2
  obtain ⟨s, hs⟩ := (h.2 σ).mpr hbit
  refine ⟨σ, s, hzone, hs, ?_⟩
  have hpf := kvE2_sepProjFresh_eval M _ s σ hs
  rwa [of_decide_eq_true hproj] at hpf

/-! ### σ-level (outer-class) literal honesty — the five `kvE2_sepHasPos` families

Positive bits discharge by exhibiting the class owner's honest witness (the σ_w route of
`kvE2_sepHonest_hLR_absurd`, now an obligation instead of a contradiction); negative bits
discharge because a witness would force the class characteristic positive
(`kvE2_sepHasPos_of_realized`), contradicting the bit. Prop 3.5 (pp.5,7): `Since`/`Until`
navigation rides the fixed endpoint as evaluation point — LITMUS-clean. -/

/-- `zPastX3` Since-literal honesty at `x`. -/
private theorem kvE2_sepHasPosLit_zPastX3 {sig : MonadicSignature}
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      temporal_truth M atomMap u (charK χ) ↔ nf_eval_nf M 1 1 (fun _ => u) χ)
    (χ : NormalForm sig 1 1) :
    temporal_truth M atomMap x
      (kvE2_sepLit (kvE2_sepHasPos qnf kvE2_sep_zPastX3 χ)
        (Formula.snce (charK χ) Formula.top)) := by
  cases hb : kvE2_sepHasPos qnf kvE2_sep_zPastX3 χ with
  | true =>
    show temporal_truth M atomMap x (Formula.snce (charK χ) Formula.top)
    obtain ⟨σ, s, hzone, hs, hχs⟩ := kvE2_sepHasPos_witness qnf M w x t h _ χ hb
    obtain ⟨hσ_atom, -, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
    have hsx := kvE2_sepZoneFact_lt M s w x t σ hσ_atom ⟨1, by omega⟩
      (by rw [congrFun hzone ⟨1, by omega⟩]; decide)
    exact ⟨s, hsx, (hck χ s).mpr hχs, fun r _ _ hf => hf⟩
  | false =>
    show temporal_truth M atomMap x (Formula.snce (charK χ) Formula.top).neg
    rintro ⟨s, hsx, hsχ, -⟩
    have hz := kvE2_sepCharZone3 M s w x t (true, false) (true, false) (true, false)
      (iff_of_true (hsx.trans hxw) rfl)
      (iff_of_false (lt_asymm (hsx.trans hxw)) (by decide))
      (iff_of_true hsx rfl) (iff_of_false (lt_asymm hsx) (by decide))
      (iff_of_true (hsx.trans (hxw.trans hwt)) rfl)
      (iff_of_false (lt_asymm (hsx.trans (hxw.trans hwt))) (by decide))
    have hpos := kvE2_sepHasPos_of_realized qnf M w x t s h kvE2_sep_zPastX3 hz χ
      ((hck χ s).mp hsχ)
    rw [hb] at hpos
    exact Bool.noConfusion hpos

/-- `zAtX3` at-literal honesty at `x`. -/
private theorem kvE2_sepHasPosLit_zAtX3 {sig : MonadicSignature}
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      temporal_truth M atomMap u (charK χ) ↔ nf_eval_nf M 1 1 (fun _ => u) χ)
    (χ : NormalForm sig 1 1) :
    temporal_truth M atomMap x
      (kvE2_sepLit (kvE2_sepHasPos qnf kvE2_sep_zAtX3 χ) (charK χ)) := by
  cases hb : kvE2_sepHasPos qnf kvE2_sep_zAtX3 χ with
  | true =>
    show temporal_truth M atomMap x (charK χ)
    obtain ⟨σ, s, hzone, hs, hχs⟩ := kvE2_sepHasPos_witness qnf M w x t h _ χ hb
    obtain ⟨hσ_atom, -, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
    have hnsx := kvE2_sepZoneFact_not_lt M s w x t σ hσ_atom ⟨1, by omega⟩
      (by rw [congrFun hzone ⟨1, by omega⟩]; decide)
    have hnxs := kvE2_sepZoneFact_not_gt M s w x t σ hσ_atom ⟨1, by omega⟩
      (by rw [congrFun hzone ⟨1, by omega⟩]; decide)
    have hseq : s = x := le_antisymm (not_lt.mp hnxs) (not_lt.mp hnsx)
    exact (hck χ x).mpr (hseq ▸ hχs)
  | false =>
    show temporal_truth M atomMap x (charK χ).neg
    intro hch
    have hz := kvE2_sepCharZone3 M x w x t (true, false) (false, false) (true, false)
      (iff_of_true hxw rfl) (iff_of_false (lt_asymm hxw) (by decide))
      (iff_of_false (lt_irrefl x) (by decide)) (iff_of_false (lt_irrefl x) (by decide))
      (iff_of_true (hxw.trans hwt) rfl)
      (iff_of_false (lt_asymm (hxw.trans hwt)) (by decide))
    have hpos := kvE2_sepHasPos_of_realized qnf M w x t x h kvE2_sep_zAtX3 hz χ
      ((hck χ x).mp hch)
    rw [hb] at hpos
    exact Bool.noConfusion hpos

/-- `zAtW3` at-literal honesty at the shared pivot `w`. -/
private theorem kvE2_sepHasPosLit_zAtW3 {sig : MonadicSignature}
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      temporal_truth M atomMap u (charK χ) ↔ nf_eval_nf M 1 1 (fun _ => u) χ)
    (χ : NormalForm sig 1 1) :
    temporal_truth M atomMap w
      (kvE2_sepLit (kvE2_sepHasPos qnf kvE2_sep_zAtW3 χ) (charK χ)) := by
  cases hb : kvE2_sepHasPos qnf kvE2_sep_zAtW3 χ with
  | true =>
    show temporal_truth M atomMap w (charK χ)
    obtain ⟨σ, s, hzone, hs, hχs⟩ := kvE2_sepHasPos_witness qnf M w x t h _ χ hb
    obtain ⟨hσ_atom, -, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
    have hnsw := kvE2_sepZoneFact_not_lt M s w x t σ hσ_atom ⟨0, by omega⟩
      (by rw [congrFun hzone ⟨0, by omega⟩]; decide)
    have hnws := kvE2_sepZoneFact_not_gt M s w x t σ hσ_atom ⟨0, by omega⟩
      (by rw [congrFun hzone ⟨0, by omega⟩]; decide)
    have hseq : s = w := le_antisymm (not_lt.mp hnws) (not_lt.mp hnsw)
    exact (hck χ w).mpr (hseq ▸ hχs)
  | false =>
    show temporal_truth M atomMap w (charK χ).neg
    intro hch
    have hz := kvE2_sepCharZone3 M w w x t (false, false) (false, true) (true, false)
      (iff_of_false (lt_irrefl w) (by decide)) (iff_of_false (lt_irrefl w) (by decide))
      (iff_of_false (lt_asymm hxw) (by decide)) (iff_of_true hxw rfl)
      (iff_of_true hwt rfl) (iff_of_false (lt_asymm hwt) (by decide))
    have hpos := kvE2_sepHasPos_of_realized qnf M w x t w h kvE2_sep_zAtW3 hz χ
      ((hck χ w).mp hch)
    rw [hb] at hpos
    exact Bool.noConfusion hpos

/-- `zAtT3` at-literal honesty at `t`. -/
private theorem kvE2_sepHasPosLit_zAtT3 {sig : MonadicSignature}
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      temporal_truth M atomMap u (charK χ) ↔ nf_eval_nf M 1 1 (fun _ => u) χ)
    (χ : NormalForm sig 1 1) :
    temporal_truth M atomMap t
      (kvE2_sepLit (kvE2_sepHasPos qnf kvE2_sep_zAtT3 χ) (charK χ)) := by
  cases hb : kvE2_sepHasPos qnf kvE2_sep_zAtT3 χ with
  | true =>
    show temporal_truth M atomMap t (charK χ)
    obtain ⟨σ, s, hzone, hs, hχs⟩ := kvE2_sepHasPos_witness qnf M w x t h _ χ hb
    obtain ⟨hσ_atom, -, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
    have hnst := kvE2_sepZoneFact_not_lt M s w x t σ hσ_atom ⟨2, by omega⟩
      (by rw [congrFun hzone ⟨2, by omega⟩]; decide)
    have hnts := kvE2_sepZoneFact_not_gt M s w x t σ hσ_atom ⟨2, by omega⟩
      (by rw [congrFun hzone ⟨2, by omega⟩]; decide)
    have hseq : s = t := le_antisymm (not_lt.mp hnts) (not_lt.mp hnst)
    exact (hck χ t).mpr (hseq ▸ hχs)
  | false =>
    show temporal_truth M atomMap t (charK χ).neg
    intro hch
    have hz := kvE2_sepCharZone3 M t w x t (false, true) (false, true) (false, false)
      (iff_of_false (lt_asymm hwt) (by decide)) (iff_of_true hwt rfl)
      (iff_of_false (lt_asymm (hxw.trans hwt)) (by decide))
      (iff_of_true (hxw.trans hwt) rfl)
      (iff_of_false (lt_irrefl t) (by decide)) (iff_of_false (lt_irrefl t) (by decide))
    have hpos := kvE2_sepHasPos_of_realized qnf M w x t t h kvE2_sep_zAtT3 hz χ
      ((hck χ t).mp hch)
    rw [hb] at hpos
    exact Bool.noConfusion hpos

/-- `zFutT3` Until-literal honesty at `t`. -/
private theorem kvE2_sepHasPosLit_zFutT3 {sig : MonadicSignature}
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      temporal_truth M atomMap u (charK χ) ↔ nf_eval_nf M 1 1 (fun _ => u) χ)
    (χ : NormalForm sig 1 1) :
    temporal_truth M atomMap t
      (kvE2_sepLit (kvE2_sepHasPos qnf kvE2_sep_zFutT3 χ)
        (Formula.untl (charK χ) Formula.top)) := by
  cases hb : kvE2_sepHasPos qnf kvE2_sep_zFutT3 χ with
  | true =>
    show temporal_truth M atomMap t (Formula.untl (charK χ) Formula.top)
    obtain ⟨σ, s, hzone, hs, hχs⟩ := kvE2_sepHasPos_witness qnf M w x t h _ χ hb
    obtain ⟨hσ_atom, -, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
    have hts := kvE2_sepZoneFact_gt M s w x t σ hσ_atom ⟨2, by omega⟩
      (by rw [congrFun hzone ⟨2, by omega⟩]; decide)
    exact ⟨s, hts, (hck χ s).mpr hχs, fun r _ _ hf => hf⟩
  | false =>
    show temporal_truth M atomMap t (Formula.untl (charK χ) Formula.top).neg
    rintro ⟨s, hts, hsχ, -⟩
    have hz := kvE2_sepCharZone3 M s w x t (false, true) (false, true) (false, true)
      (iff_of_false (lt_asymm (hwt.trans hts)) (by decide))
      (iff_of_true (hwt.trans hts) rfl)
      (iff_of_false (lt_asymm (hxw.trans (hwt.trans hts))) (by decide))
      (iff_of_true (hxw.trans (hwt.trans hts)) rfl)
      (iff_of_false (lt_asymm hts) (by decide)) (iff_of_true hts rfl)
    have hpos := kvE2_sepHasPos_of_realized qnf M w x t s h kvE2_sep_zFutT3 hz χ
      ((hck χ s).mp hsχ)
    rw [hb] at hpos
    exact Bool.noConfusion hpos

/-! ### Per-owner (inner-zone) literal honesty — the six `kvE2_sepBits` families

Each positive bit yields a genuine zone witness through the owner's realized fold channel
(`nf_eval_depth1_fold_iff`); each negative bit refutes the literal because a witness would
force the bit positive through the same channel. All zones here are placement-generic
boundary/exterior zones — the OPEN interior keys never appear (F5 stays confined to the
strict placements of conjunct (i)). -/

/-- Marker-clean private clone of the arity-4 zoneHolds cons-iff helper
    (`SubBracket2.lean:538`), byte-identical in content: `zoneHolds` over the anchor env
    `[a, w, x, t]` at a pointwise `Fin.cons` zone spec, unfolded to its four coordinate
    biconditionals (Def 3.1 ordering channel, PDF p.4). Cloned so the endpoint-honesty
    pack references no identifier carrying the open-key marker prefix — the F5 count
    guard stays mechanical. -/
private theorem kvE2_sepZone4_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (e0 e1 e2 e3 v : M.carrier)
    (p0 p1 p2 p3 : Bool × Bool) :
    zoneHolds M (Fin.cons e0 (Fin.cons e1 (Fin.cons e2 (fun _ => e3))) : Fin 4 → M.carrier)
      (Fin.cons p0 (Fin.cons p1 (Fin.cons p2 (fun _ => p3))) : ZoneSpec 4) v ↔
    (((v < e0) ↔ p0.1 = true) ∧ ((e0 < v) ↔ p0.2 = true)) ∧
    (((v < e1) ↔ p1.1 = true) ∧ ((e1 < v) ↔ p1.2 = true)) ∧
    (((v < e2) ↔ p2.1 = true) ∧ ((e2 < v) ↔ p2.2 = true)) ∧
    (((v < e3) ↔ p3.1 = true) ∧ ((e3 < v) ↔ p3.2 = true)) := by
  constructor
  · intro h
    have h0 := h ⟨0, by omega⟩
    have h1 := h ⟨1, by omega⟩
    have h2 := h ⟨2, by omega⟩
    have h3 := h ⟨3, by omega⟩
    simp only [Fin.cons] at h0 h1 h2 h3
    exact ⟨h0, h1, h2, h3⟩
  · rintro ⟨h0, h1, h2, h3⟩ i
    match i with
    | ⟨0, _⟩ => simpa only [Fin.cons] using h0
    | ⟨1, _⟩ => simpa only [Fin.cons] using h1
    | ⟨2, _⟩ => simpa only [Fin.cons] using h2
    | ⟨3, _⟩ => simpa only [Fin.cons] using h3

/-- `zPastX4` Since-literal honesty at `x` (per interior owner). -/
private theorem kvE2_sepOwnerLit_zPastX4 {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (σ : NormalForm sig 1 4) (a w x t : M.carrier)
    (hxa : x < a) (hxw : x < w) (hxt : x < t)
    (hs : nf_eval_nf M 1 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (χ : NormalForm sig 0 1) :
    temporal_truth M atomMap x
      (kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zPastX4 χ)
        (Formula.snce (charBase χ) Formula.top)) := by
  obtain ⟨-, h_zone, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
  cases hb : kvE2_sepBits σ kvE2_sep_zPastX4 χ with
  | true =>
    show temporal_truth M atomMap x (Formula.snce (charBase χ) Formula.top)
    obtain ⟨v, hz, hv⟩ := (h_zone kvE2_sep_zPastX4 χ).mpr hb
    obtain ⟨h0, h1, h2, h3⟩ := (kvE2_sepZone4_iff M a w x t v
      (true, false) (true, false) (true, false) (true, false)).mp hz
    exact ⟨v, h2.1.mpr rfl, (hcb χ v).mpr hv, fun r _ _ hf => hf⟩
  | false =>
    show temporal_truth M atomMap x (Formula.snce (charBase χ) Formula.top).neg
    rintro ⟨s, hsx, hsχ, -⟩
    have hz : zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t))))
        kvE2_sep_zPastX4 s := by
      refine (kvE2_sepZone4_iff M a w x t s
        (true, false) (true, false) (true, false) (true, false)).mpr ?_
      exact ⟨⟨iff_of_true (hsx.trans hxa) rfl,
          iff_of_false (lt_asymm (hsx.trans hxa)) (by decide)⟩,
        ⟨iff_of_true (hsx.trans hxw) rfl,
          iff_of_false (lt_asymm (hsx.trans hxw)) (by decide)⟩,
        ⟨iff_of_true hsx rfl, iff_of_false (lt_asymm hsx) (by decide)⟩,
        ⟨iff_of_true (hsx.trans hxt) rfl,
          iff_of_false (lt_asymm (hsx.trans hxt)) (by decide)⟩⟩
    have hbit : kvE2_sepBits σ kvE2_sep_zPastX4 χ = true :=
      (h_zone kvE2_sep_zPastX4 χ).mp ⟨s, hz, (hcb χ s).mp hsχ⟩
    rw [hb] at hbit
    exact Bool.noConfusion hbit

/-- `zAtX4` at-literal honesty at `x` (per interior owner). -/
private theorem kvE2_sepOwnerLit_zAtX4 {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (σ : NormalForm sig 1 4) (a w x t : M.carrier)
    (hxa : x < a) (hxw : x < w) (hxt : x < t)
    (hs : nf_eval_nf M 1 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (χ : NormalForm sig 0 1) :
    temporal_truth M atomMap x
      (kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zAtX4 χ) (charBase χ)) := by
  obtain ⟨-, h_zone, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
  cases hb : kvE2_sepBits σ kvE2_sep_zAtX4 χ with
  | true =>
    show temporal_truth M atomMap x (charBase χ)
    obtain ⟨v, hz, hv⟩ := (h_zone kvE2_sep_zAtX4 χ).mpr hb
    obtain ⟨h0, h1, h2, h3⟩ := (kvE2_sepZone4_iff M a w x t v
      (true, false) (true, false) (false, false) (true, false)).mp hz
    have hveq : v = x := le_antisymm
      (not_lt.mp (fun hc => Bool.noConfusion (h2.2.mp hc)))
      (not_lt.mp (fun hc => Bool.noConfusion (h2.1.mp hc)))
    exact (hcb χ x).mpr (hveq ▸ hv)
  | false =>
    show temporal_truth M atomMap x (charBase χ).neg
    intro hch
    have hz : zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t))))
        kvE2_sep_zAtX4 x := by
      refine (kvE2_sepZone4_iff M a w x t x
        (true, false) (true, false) (false, false) (true, false)).mpr ?_
      exact ⟨⟨iff_of_true hxa rfl, iff_of_false (lt_asymm hxa) (by decide)⟩,
        ⟨iff_of_true hxw rfl, iff_of_false (lt_asymm hxw) (by decide)⟩,
        ⟨iff_of_false (lt_irrefl x) (by decide), iff_of_false (lt_irrefl x) (by decide)⟩,
        ⟨iff_of_true hxt rfl, iff_of_false (lt_asymm hxt) (by decide)⟩⟩
    have hbit : kvE2_sepBits σ kvE2_sep_zAtX4 χ = true :=
      (h_zone kvE2_sep_zAtX4 χ).mp ⟨x, hz, (hcb χ x).mp hch⟩
    rw [hb] at hbit
    exact Bool.noConfusion hbit

/-- `zAtT4` at-literal honesty at `t` (per interior owner). -/
private theorem kvE2_sepOwnerLit_zAtT4 {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (σ : NormalForm sig 1 4) (a w x t : M.carrier)
    (hat : a < t) (hwt : w < t) (hxt : x < t)
    (hs : nf_eval_nf M 1 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (χ : NormalForm sig 0 1) :
    temporal_truth M atomMap t
      (kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zAtT4 χ) (charBase χ)) := by
  obtain ⟨-, h_zone, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
  cases hb : kvE2_sepBits σ kvE2_sep_zAtT4 χ with
  | true =>
    show temporal_truth M atomMap t (charBase χ)
    obtain ⟨v, hz, hv⟩ := (h_zone kvE2_sep_zAtT4 χ).mpr hb
    obtain ⟨h0, h1, h2, h3⟩ := (kvE2_sepZone4_iff M a w x t v
      (false, true) (false, true) (false, true) (false, false)).mp hz
    have hveq : v = t := le_antisymm
      (not_lt.mp (fun hc => Bool.noConfusion (h3.2.mp hc)))
      (not_lt.mp (fun hc => Bool.noConfusion (h3.1.mp hc)))
    exact (hcb χ t).mpr (hveq ▸ hv)
  | false =>
    show temporal_truth M atomMap t (charBase χ).neg
    intro hch
    have hz : zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t))))
        kvE2_sep_zAtT4 t := by
      refine (kvE2_sepZone4_iff M a w x t t
        (false, true) (false, true) (false, true) (false, false)).mpr ?_
      exact ⟨⟨iff_of_false (lt_asymm hat) (by decide), iff_of_true hat rfl⟩,
        ⟨iff_of_false (lt_asymm hwt) (by decide), iff_of_true hwt rfl⟩,
        ⟨iff_of_false (lt_asymm hxt) (by decide), iff_of_true hxt rfl⟩,
        ⟨iff_of_false (lt_irrefl t) (by decide), iff_of_false (lt_irrefl t) (by decide)⟩⟩
    have hbit : kvE2_sepBits σ kvE2_sep_zAtT4 χ = true :=
      (h_zone kvE2_sep_zAtT4 χ).mp ⟨t, hz, (hcb χ t).mp hch⟩
    rw [hb] at hbit
    exact Bool.noConfusion hbit

/-- `zFutT4` Until-literal honesty at `t` (per interior owner). -/
private theorem kvE2_sepOwnerLit_zFutT4 {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (σ : NormalForm sig 1 4) (a w x t : M.carrier)
    (hat : a < t) (hwt : w < t) (hxt : x < t)
    (hs : nf_eval_nf M 1 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (χ : NormalForm sig 0 1) :
    temporal_truth M atomMap t
      (kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zFutT4 χ)
        (Formula.untl (charBase χ) Formula.top)) := by
  obtain ⟨-, h_zone, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
  cases hb : kvE2_sepBits σ kvE2_sep_zFutT4 χ with
  | true =>
    show temporal_truth M atomMap t (Formula.untl (charBase χ) Formula.top)
    obtain ⟨v, hz, hv⟩ := (h_zone kvE2_sep_zFutT4 χ).mpr hb
    obtain ⟨h0, h1, h2, h3⟩ := (kvE2_sepZone4_iff M a w x t v
      (false, true) (false, true) (false, true) (false, true)).mp hz
    exact ⟨v, h3.2.mpr rfl, (hcb χ v).mpr hv, fun r _ _ hf => hf⟩
  | false =>
    show temporal_truth M atomMap t (Formula.untl (charBase χ) Formula.top).neg
    rintro ⟨s, hts, hsχ, -⟩
    have hz : zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t))))
        kvE2_sep_zFutT4 s := by
      refine (kvE2_sepZone4_iff M a w x t s
        (false, true) (false, true) (false, true) (false, true)).mpr ?_
      exact ⟨⟨iff_of_false (lt_asymm (hat.trans hts)) (by decide),
          iff_of_true (hat.trans hts) rfl⟩,
        ⟨iff_of_false (lt_asymm (hwt.trans hts)) (by decide),
          iff_of_true (hwt.trans hts) rfl⟩,
        ⟨iff_of_false (lt_asymm (hxt.trans hts)) (by decide),
          iff_of_true (hxt.trans hts) rfl⟩,
        ⟨iff_of_false (lt_asymm hts) (by decide), iff_of_true hts rfl⟩⟩
    have hbit : kvE2_sepBits σ kvE2_sep_zFutT4 χ = true :=
      (h_zone kvE2_sep_zFutT4 χ).mp ⟨s, hz, (hcb χ s).mp hsχ⟩
    rw [hb] at hbit
    exact Bool.noConfusion hbit

/-- `zAtWL` pivot-literal honesty at `w` (LEFT-interior owner, `a < w`). -/
private theorem kvE2_sepOwnerLit_zAtWL {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (σ : NormalForm sig 1 4) (a w x t : M.carrier)
    (haw : a < w) (hxw : x < w) (hwt : w < t)
    (hs : nf_eval_nf M 1 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (χ : NormalForm sig 0 1) :
    temporal_truth M atomMap w
      (kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zAtWL χ) (charBase χ)) := by
  obtain ⟨-, h_zone, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
  cases hb : kvE2_sepBits σ kvE2_sep_zAtWL χ with
  | true =>
    show temporal_truth M atomMap w (charBase χ)
    obtain ⟨v, hz, hv⟩ := (h_zone kvE2_sep_zAtWL χ).mpr hb
    obtain ⟨h0, h1, h2, h3⟩ := (kvE2_sepZone4_iff M a w x t v
      (false, true) (false, false) (false, true) (true, false)).mp hz
    have hveq : v = w := le_antisymm
      (not_lt.mp (fun hc => Bool.noConfusion (h1.2.mp hc)))
      (not_lt.mp (fun hc => Bool.noConfusion (h1.1.mp hc)))
    exact (hcb χ w).mpr (hveq ▸ hv)
  | false =>
    show temporal_truth M atomMap w (charBase χ).neg
    intro hch
    have hz : zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t))))
        kvE2_sep_zAtWL w := by
      refine (kvE2_sepZone4_iff M a w x t w
        (false, true) (false, false) (false, true) (true, false)).mpr ?_
      exact ⟨⟨iff_of_false (lt_asymm haw) (by decide), iff_of_true haw rfl⟩,
        ⟨iff_of_false (lt_irrefl w) (by decide), iff_of_false (lt_irrefl w) (by decide)⟩,
        ⟨iff_of_false (lt_asymm hxw) (by decide), iff_of_true hxw rfl⟩,
        ⟨iff_of_true hwt rfl, iff_of_false (lt_asymm hwt) (by decide)⟩⟩
    have hbit : kvE2_sepBits σ kvE2_sep_zAtWL χ = true :=
      (h_zone kvE2_sep_zAtWL χ).mp ⟨w, hz, (hcb χ w).mp hch⟩
    rw [hb] at hbit
    exact Bool.noConfusion hbit

/-- `zAtWR` pivot-literal honesty at `w` (RIGHT-interior owner, `w < a`). -/
private theorem kvE2_sepOwnerLit_zAtWR {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (σ : NormalForm sig 1 4) (a w x t : M.carrier)
    (hwa : w < a) (hxw : x < w) (hwt : w < t)
    (hs : nf_eval_nf M 1 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (χ : NormalForm sig 0 1) :
    temporal_truth M atomMap w
      (kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zAtWR χ) (charBase χ)) := by
  obtain ⟨-, h_zone, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
  cases hb : kvE2_sepBits σ kvE2_sep_zAtWR χ with
  | true =>
    show temporal_truth M atomMap w (charBase χ)
    obtain ⟨v, hz, hv⟩ := (h_zone kvE2_sep_zAtWR χ).mpr hb
    obtain ⟨h0, h1, h2, h3⟩ := (kvE2_sepZone4_iff M a w x t v
      (true, false) (false, false) (false, true) (true, false)).mp hz
    have hveq : v = w := le_antisymm
      (not_lt.mp (fun hc => Bool.noConfusion (h1.2.mp hc)))
      (not_lt.mp (fun hc => Bool.noConfusion (h1.1.mp hc)))
    exact (hcb χ w).mpr (hveq ▸ hv)
  | false =>
    show temporal_truth M atomMap w (charBase χ).neg
    intro hch
    have hz : zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t))))
        kvE2_sep_zAtWR w := by
      refine (kvE2_sepZone4_iff M a w x t w
        (true, false) (false, false) (false, true) (true, false)).mpr ?_
      exact ⟨⟨iff_of_true hwa rfl, iff_of_false (lt_asymm hwa) (by decide)⟩,
        ⟨iff_of_false (lt_irrefl w) (by decide), iff_of_false (lt_irrefl w) (by decide)⟩,
        ⟨iff_of_false (lt_asymm hxw) (by decide), iff_of_true hxw rfl⟩,
        ⟨iff_of_true hwt rfl, iff_of_false (lt_asymm hwt) (by decide)⟩⟩
    have hbit : kvE2_sepBits σ kvE2_sep_zAtWR χ = true :=
      (h_zone kvE2_sep_zAtWR χ).mp ⟨w, hz, (hcb χ w).mp hch⟩
    rw [hb] at hbit
    exact Bool.noConfusion hbit

/-- **Left-endpoint honesty** (task 342 Phase 8 (b)): under an honest evaluation `h`, the
    EXISTING joint left endpoint predicate `kvE2_sepEpL` evaluates at the fixed `x`.
    Rabinovich §5 (p.7): the ψ0/ψ1/φ split routes non-interior positive witnesses
    (`zPastX3`/`zAtX3` classes and the per-owner `zPastX4`/`zAtX4` exterior/boundary
    content) to atomic E[Σ] endpoint literals via Prop 3.5 (pp.5,7) — this lemma is that
    routing's completeness half, previously hidden behind `hLR`'s vacuity. `Since`
    navigation rides the fixed endpoint as evaluation point (LITMUS-clean); `hcb`/`hck`
    are the abstract char-semantics correctness hypotheses (`nfPred_correct` shape). -/
theorem kvE2_sepEpL_eval_of_honest {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      temporal_truth M atomMap u (charK χ) ↔ nf_eval_nf M 1 1 (fun _ => u) χ) :
    (kvE2_sepEpL charBase charK qnf).eval_at M atomMap x := by
  simp only [kvE2_sepEpL, TemporalPred.eval_at]
  rw [formula_conjList_iff]
  intro f hf
  rcases List.mem_append.mp hf with hf | hf
  · rcases List.mem_append.mp hf with hf | hf
    · rcases List.mem_cons.mp hf with rfl | hf
      · -- Joint head: `qnf.1`'s x-coordinate 1-type at `x`.
        have hp := kvE2_sepProj3_eval M (Fin.cons w (Fin.cons x (fun _ => t))) qnf.1 h.1
          ⟨1, by omega⟩
        exact (hcb _ x).mpr hp
      · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
        exact kvE2_sepHasPosLit_zPastX3 charK qnf M atomMap w x t hxw hwt h hck χ
    · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
      exact kvE2_sepHasPosLit_zAtX3 charK qnf M atomMap w x t hxw hwt h hck χ
  · obtain ⟨σ, hσmem, hfσ⟩ := List.mem_flatMap.mp hf
    have hσpos : qnf.2 σ = true := by
      rcases List.mem_append.mp hσmem with hσm | hσm <;>
        exact (List.mem_filter.mp (List.mem_filter.mp hσm).1).2
    have hσzone : nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3 := by
      rcases List.mem_append.mp hσmem with hσm | hσm
      · exact Or.inl (of_decide_eq_true (List.mem_filter.mp hσm).2)
      · exact Or.inr (of_decide_eq_true (List.mem_filter.mp hσm).2)
    obtain ⟨a, hs⟩ := (h.2 σ).mpr hσpos
    obtain ⟨hσ_atom, -, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
    have hxa : x < a := by
      rcases hσzone with hzone | hzone
      · have hgt := kvE2_sepZoneFact_gt M a w x t σ hσ_atom ⟨1, by omega⟩
          (by rw [congrFun hzone ⟨1, by omega⟩]; decide)
        exact hgt
      · have hgt := kvE2_sepZoneFact_gt M a w x t σ hσ_atom ⟨0, by omega⟩
          (by rw [congrFun hzone ⟨0, by omega⟩]; decide)
        exact hxw.trans hgt
    rcases List.mem_append.mp hfσ with hfσ | hfσ
    · rcases List.mem_cons.mp hfσ with rfl | hfσ
      · -- σ's own x-coordinate 1-type at `x`.
        have hp := kvE2_sepProj4_eval M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t))))
          σ hσ_atom ⟨2, by omega⟩
        exact (hcb _ x).mpr hp
      · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hfσ
        exact kvE2_sepOwnerLit_zPastX4 charBase M atomMap σ a w x t hxa hxw
          (hxw.trans hwt) hs hcb χ
    · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hfσ
      exact kvE2_sepOwnerLit_zAtX4 charBase M atomMap σ a w x t hxa hxw
        (hxw.trans hwt) hs hcb χ

/-- **Shared-pivot honesty** (task 342 Phase 8 (b)): under an honest evaluation `h`, the
    EXISTING shared interior-witness point type `kvE2_sepPtW` evaluates at the pivot `w`.
    The `zAtW3` class and the per-owner `zAtWL`/`zAtWR` self-zone literals are the pivot's
    boundary content (Rabinovich §5, p.7, via Prop 3.5, pp.5,7); positive bits are the σ_w
    route of `kvE2_sepHonest_hLR_absurd`, now an obligation instead of a contradiction. -/
theorem kvE2_sepPtW_eval_of_honest {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      temporal_truth M atomMap u (charK χ) ↔ nf_eval_nf M 1 1 (fun _ => u) χ) :
    (kvE2_sepPtW charBase charK qnf).eval_at M atomMap w := by
  simp only [kvE2_sepPtW, TemporalPred.eval_at]
  rw [formula_conjList_iff]
  intro f hf
  rcases List.mem_append.mp hf with hf | hf
  · rcases List.mem_append.mp hf with hf | hf
    · rcases List.mem_cons.mp hf with rfl | hf
      · -- Joint head: `qnf.1`'s w-coordinate 1-type at `w`.
        have hp := kvE2_sepProj3_eval M (Fin.cons w (Fin.cons x (fun _ => t))) qnf.1 h.1
          ⟨0, by omega⟩
        exact (hcb _ w).mpr hp
      · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
        exact kvE2_sepHasPosLit_zAtW3 charK qnf M atomMap w x t hxw hwt h hck χ
    · -- LEFT-interior owner blocks (`zAtWL` self-zone key at the pivot).
      obtain ⟨σ, hσm, hfσ⟩ := List.mem_flatMap.mp hf
      have hσpos : qnf.2 σ = true :=
        (List.mem_filter.mp (List.mem_filter.mp hσm).1).2
      have hzone : nf0_zoneSpec σ.1 = kvE2_sep_zXW3 :=
        of_decide_eq_true (List.mem_filter.mp hσm).2
      obtain ⟨a, hs⟩ := (h.2 σ).mpr hσpos
      obtain ⟨hσ_atom, -, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
      have haw : a < w := by
        have hlt := kvE2_sepZoneFact_lt M a w x t σ hσ_atom ⟨0, by omega⟩
          (by rw [congrFun hzone ⟨0, by omega⟩]; decide)
        exact hlt
      rcases List.mem_cons.mp hfσ with rfl | hfσ
      · have hp := kvE2_sepProj4_eval M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t))))
          σ hσ_atom ⟨1, by omega⟩
        exact (hcb _ w).mpr hp
      · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hfσ
        exact kvE2_sepOwnerLit_zAtWL charBase M atomMap σ a w x t haw hxw hwt hs hcb χ
  · -- RIGHT-interior owner blocks (`zAtWR` self-zone key at the pivot; mirror).
    obtain ⟨σ, hσm, hfσ⟩ := List.mem_flatMap.mp hf
    have hσpos : qnf.2 σ = true :=
      (List.mem_filter.mp (List.mem_filter.mp hσm).1).2
    have hzone : nf0_zoneSpec σ.1 = kvE2_sep_zWT3 :=
      of_decide_eq_true (List.mem_filter.mp hσm).2
    obtain ⟨a, hs⟩ := (h.2 σ).mpr hσpos
    obtain ⟨hσ_atom, -, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
    have hwa : w < a := by
      have hgt := kvE2_sepZoneFact_gt M a w x t σ hσ_atom ⟨0, by omega⟩
        (by rw [congrFun hzone ⟨0, by omega⟩]; decide)
      exact hgt
    rcases List.mem_cons.mp hfσ with rfl | hfσ
    · have hp := kvE2_sepProj4_eval M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t))))
        σ hσ_atom ⟨1, by omega⟩
      exact (hcb _ w).mpr hp
    · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hfσ
      exact kvE2_sepOwnerLit_zAtWR charBase M atomMap σ a w x t hwa hxw hwt hs hcb χ

/-- **Right-endpoint honesty** (task 342 Phase 8 (b), mirror of
    `kvE2_sepEpL_eval_of_honest`): under an honest evaluation `h`, the EXISTING joint
    right endpoint predicate `kvE2_sepEpR` evaluates at the fixed `t`. `zAtT3`/`zFutT3`
    classes and per-owner `zAtT4`/`zFutT4` content ride the at-`t` and `Until` literals
    (Rabinovich §5, p.7, via Prop 3.5, pp.5,7). -/
theorem kvE2_sepEpR_eval_of_honest {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      temporal_truth M atomMap u (charK χ) ↔ nf_eval_nf M 1 1 (fun _ => u) χ) :
    (kvE2_sepEpR charBase charK qnf).eval_at M atomMap t := by
  simp only [kvE2_sepEpR, TemporalPred.eval_at]
  rw [formula_conjList_iff]
  intro f hf
  rcases List.mem_append.mp hf with hf | hf
  · rcases List.mem_append.mp hf with hf | hf
    · rcases List.mem_cons.mp hf with rfl | hf
      · -- Joint head: `qnf.1`'s t-coordinate 1-type at `t`.
        have hp := kvE2_sepProj3_eval M (Fin.cons w (Fin.cons x (fun _ => t))) qnf.1 h.1
          ⟨2, by omega⟩
        exact (hcb _ t).mpr hp
      · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
        exact kvE2_sepHasPosLit_zAtT3 charK qnf M atomMap w x t hxw hwt h hck χ
    · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
      exact kvE2_sepHasPosLit_zFutT3 charK qnf M atomMap w x t hxw hwt h hck χ
  · obtain ⟨σ, hσmem, hfσ⟩ := List.mem_flatMap.mp hf
    have hσpos : qnf.2 σ = true := by
      rcases List.mem_append.mp hσmem with hσm | hσm <;>
        exact (List.mem_filter.mp (List.mem_filter.mp hσm).1).2
    have hσzone : nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3 := by
      rcases List.mem_append.mp hσmem with hσm | hσm
      · exact Or.inl (of_decide_eq_true (List.mem_filter.mp hσm).2)
      · exact Or.inr (of_decide_eq_true (List.mem_filter.mp hσm).2)
    obtain ⟨a, hs⟩ := (h.2 σ).mpr hσpos
    obtain ⟨hσ_atom, -, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
    have hat : a < t := by
      rcases hσzone with hzone | hzone
      · have hlt := kvE2_sepZoneFact_lt M a w x t σ hσ_atom ⟨0, by omega⟩
          (by rw [congrFun hzone ⟨0, by omega⟩]; decide)
        exact lt_trans hlt hwt
      · have hlt := kvE2_sepZoneFact_lt M a w x t σ hσ_atom ⟨2, by omega⟩
          (by rw [congrFun hzone ⟨2, by omega⟩]; decide)
        exact hlt
    rcases List.mem_append.mp hfσ with hfσ | hfσ
    · rcases List.mem_cons.mp hfσ with rfl | hfσ
      · -- σ's own t-coordinate 1-type at `t`.
        have hp := kvE2_sepProj4_eval M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t))))
          σ hσ_atom ⟨3, by omega⟩
        exact (hcb _ t).mpr hp
      · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hfσ
        exact kvE2_sepOwnerLit_zAtT4 charBase M atomMap σ a w x t hat hwt
          (hxw.trans hwt) hs hcb χ
    · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hfσ
      exact kvE2_sepOwnerLit_zFutT4 charBase M atomMap σ a w x t hat hwt
        (hxw.trans hwt) hs hcb χ

/-! ### Task 337 (plan 12) Phase 1 — primed tie-reporting order bridge + value-sortedness

The target `.holds` builder consumes the GROUPED tie-classes of the PRIMED order
`kvE2_sepHonestOrder'`, whose payload is the tie-REPORTING value-only rank
`kvE2_sepSlotHonestVIdx` (vs the unprimed order's tie-BREAKING `kvE2_sepSlotHonestGIdx`).
The banked value-sortedness (`kvE2_sepSlotsLOf_honest_valueSorted`, SW:4157) is stated for the
unprimed order only. These lemmas re-establish the merge-key bridge, monotonicity, and
value-nondecreasing sortedness for the PRIMED slot lists, mirroring SW:3995/4047/4157 verbatim
with the VIdx payload. Additive; no landed asset touched. -/

/-- **Primed halign bridge** (task 337 plan 12 Phase 1): under the tie-reporting honest order
    `kvE2_sepHonestOrder'`, the mergeSort key reader `kvE2_sepSlotGIdx` coincides with the
    tie-reporting value-only index `kvE2_sepSlotHonestVIdx` on every slot of every positive
    owner's block. Verbatim mirror of `kvE2_sepSlotGIdx_honestOrder` (SW:3995) with the VIdx
    payload. -/
theorem kvE2_sepSlotGIdx_honestOrder' {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf)
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2_sepSlotBlock σ) :
    kvE2_sepSlotGIdx (kvE2_sepHonestOrder' qnf M w x t h) s
      = kvE2_sepSlotHonestVIdx qnf M w x t h s := by
  have hsub : kvE2_sepSlotSub s = σ := kvE2_sepSlotSub_of_mem_block hs
  have hfind : (kvE2_sepHonestOrder' qnf M w x t h).find?
        (fun p => decide (p.1 = kvE2_sepSlotSub s))
      = some (σ, KvE2SepSpikeOrderType.coincident,
          (kvE2_sepSlotBlock σ).map (kvE2_sepSlotHonestVIdx qnf M w x t h)) := by
    rw [hsub, kvE2_sepHonestOrder', List.find?_map]
    have hex : ∃ q ∈ (kvE2_sepPosI qnf).zipIdx,
        ((fun p => decide (p.1 = σ)) ∘
          (fun p : NormalForm sig 1 4 × ℕ =>
            (p.1, KvE2SepSpikeOrderType.coincident,
              (kvE2_sepSlotBlock p.1).map (kvE2_sepSlotHonestVIdx qnf M w x t h)))) q = true := by
      have hm : σ ∈ (kvE2_sepPosI qnf).zipIdx.map Prod.fst := by
        rw [List.zipIdx_map_fst]; exact kvE2_sepMem_posI_of_slot hσ hs
      obtain ⟨q, hq, hq1⟩ := List.mem_map.mp hm
      exact ⟨q, hq, by simp [Function.comp, hq1]⟩
    obtain ⟨q, hq, hqp⟩ := hex
    cases hf : (kvE2_sepPosI qnf).zipIdx.find?
        ((fun p => decide (p.1 = σ)) ∘
          (fun p : NormalForm sig 1 4 × ℕ =>
            (p.1, KvE2SepSpikeOrderType.coincident,
              (kvE2_sepSlotBlock p.1).map (kvE2_sepSlotHonestVIdx qnf M w x t h)))) with
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

/-- **Primed halign monotonicity** (task 337 plan 12 Phase 2 ingredient): on the tie-reporting
    order the mergeSort key `kvE2_sepSlotGIdx` is strictly monotone in the slot value. Mirror of
    `kvE2_sepSlotGIdx_honestOrder_mono` (SW:4047) via the primed bridge + `kvE2_sepSlotHonestVIdx_mono`. -/
theorem kvE2_sepSlotGIdx_honestOrder'_mono {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {σ τ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf) (hτ : τ ∈ kvE2_sepPos qnf)
    {a b : KvE2SepSlot sig} (ha : a ∈ kvE2_sepSlotBlock σ) (hb : b ∈ kvE2_sepSlotBlock τ)
    (hlt : kvE2_sepSlotValue qnf M w x t h a < kvE2_sepSlotValue qnf M w x t h b) :
    kvE2_sepSlotGIdx (kvE2_sepHonestOrder' qnf M w x t h) a
      < kvE2_sepSlotGIdx (kvE2_sepHonestOrder' qnf M w x t h) b := by
  rw [kvE2_sepSlotGIdx_honestOrder' qnf M w x t h hσ ha,
      kvE2_sepSlotGIdx_honestOrder' qnf M w x t h hτ hb]
  exact kvE2_sepSlotHonestVIdx_mono qnf M w x t h
    (kvE2_sepMem_allSlots qnf hσ ha) (kvE2_sepMem_allSlots qnf hτ hb) hlt

/-- **Value-sortedness of the joint LEFT list on the tie-reporting order** (task 337 plan 12
    Phase 2): the primed merged LEFT slot list is `Pairwise` value-nondecreasing. Mirror of
    `kvE2_sepSlotsLOf_honest_valueSorted` (SW:4157) using the primed bridge/monotonicity. -/
theorem kvE2_sepSlotsLOf_honestOrder'_valueSorted {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    (kvE2_sepSlotsLOf (kvE2_sepHonestOrder' qnf M w x t h)).Pairwise
      (fun a b => kvE2_sepSlotValue qnf M w x t h a ≤ kvE2_sepSlotValue qnf M w x t h b) := by
  have hwo : (kvE2_sepHonestOrder' qnf M w x t h).map Prod.fst = kvE2_sepPosI qnf := by
    rw [kvE2_sepHonestOrder', List.map_map]
    exact List.zipIdx_map_fst 0 _
  refine (kvE2_sepSlotsLOf_mergeSorted _).imp_of_mem ?_
  intro a b ha hb hab
  obtain ⟨σ, hσ, haσ⟩ := kvE2_sepSlotsLOf_mem_block hwo ha
  obtain ⟨τ, hτ, hbτ⟩ := kvE2_sepSlotsLOf_mem_block hwo hb
  rw [kvE2_sepSlotMergeLe, decide_eq_true_eq] at hab
  by_contra hlt
  rw [not_le] at hlt
  exact absurd hab (not_le.mpr (kvE2_sepSlotGIdx_honestOrder'_mono qnf M w x t h
    (kvE2_sepPosI_subset hτ) (kvE2_sepPosI_subset hσ) hbτ haσ hlt))

/-- **Value-sortedness of the joint RIGHT list on the tie-reporting order** (mirror). -/
theorem kvE2_sepSlotsROf_honestOrder'_valueSorted {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    (kvE2_sepSlotsROf (kvE2_sepHonestOrder' qnf M w x t h)).Pairwise
      (fun a b => kvE2_sepSlotValue qnf M w x t h a ≤ kvE2_sepSlotValue qnf M w x t h b) := by
  have hwo : (kvE2_sepHonestOrder' qnf M w x t h).map Prod.fst = kvE2_sepPosI qnf := by
    rw [kvE2_sepHonestOrder', List.map_map]
    exact List.zipIdx_map_fst 0 _
  refine (kvE2_sepSlotsROf_mergeSorted _).imp_of_mem ?_
  intro a b ha hb hab
  obtain ⟨σ, hσ, haσ⟩ := kvE2_sepSlotsROf_mem_block hwo ha
  obtain ⟨τ, hτ, hbτ⟩ := kvE2_sepSlotsROf_mem_block hwo hb
  rw [kvE2_sepSlotMergeLe, decide_eq_true_eq] at hab
  by_contra hlt
  rw [not_le] at hlt
  exact absurd hab (not_le.mpr (kvE2_sepSlotGIdx_honestOrder'_mono qnf M w x t h
    (kvE2_sepPosI_subset hτ) (kvE2_sepPosI_subset hσ) hbτ haσ hlt))

/-- **Tie-class key constancy** (task 337 plan 12 Phase 1): every element of a single
    `kvE2_sepTieRuns` class shares the class key. A run only extends when the new head's key
    equals the current run head's, so class members carry one key — unconditionally (no
    sortedness needed). Structural induction mirroring `kvE2_sepTieRuns_ne_nil` (SW:2008). -/
theorem kvE2_sepTieRuns_key_const {α : Type*} (key : α → ℕ) :
    ∀ (l : List α), ∀ c ∈ kvE2_sepTieRuns key l, ∀ u ∈ c, ∀ v ∈ c, key u = key v
  | [] => by simp [kvE2_sepTieRuns]
  | [a] => by
      intro c hc u hu v hv
      rw [kvE2_sepTieRuns] at hc
      simp only [List.mem_singleton] at hc
      subst hc
      simp only [List.mem_singleton] at hu hv
      subst hu; subst hv; rfl
  | a :: b :: rest => by
      have ih := kvE2_sepTieRuns_key_const key (b :: rest)
      obtain ⟨tl, cs, heq⟩ := kvE2_sepTieRuns_shape key rest b
      intro c hc u hu v hv
      rw [kvE2_sepTieRuns, heq] at hc
      by_cases hk : key a = key b
      · simp only [if_pos hk] at hc
        rcases List.mem_cons.mp hc with rfl | hmem
        · have hbrun : ∀ z ∈ (b :: tl), key z = key b := fun z hz =>
            ih (b :: tl) (by rw [heq]; exact List.mem_cons_self) z hz b List.mem_cons_self
          have hall : ∀ z ∈ (a :: b :: tl), key z = key b := by
            intro z hz
            rcases List.mem_cons.mp hz with rfl | hz
            · exact hk
            · exact hbrun z hz
          rw [hall u hu, hall v hv]
        · exact ih c (by rw [heq]; exact List.mem_cons_of_mem _ hmem) u hu v hv
      · simp only [if_neg hk] at hc
        rcases List.mem_cons.mp hc with rfl | hmem
        · simp only [List.mem_singleton] at hu hv
          subst hu; subst hv; rfl
        · exact ih c (by rw [heq]; exact hmem) u hu v hv

/-- **Tie-class key strict monotonicity** (task 337 plan 13 Phase 3 / report 14 Q2): on a
    key-sorted list, `kvE2_sepTieRuns` yields runs whose keys STRICTLY increase across distinct
    classes — every member of an earlier class has a strictly smaller key than every member of a
    later class. The maximal-adjacent-run construction plus key-sortedness force the strict jump
    at each class boundary. Structural induction mirroring `kvE2_sepTieRuns_key_const`. -/
theorem kvE2_sepTieRuns_key_strictMono {α : Type*} (key : α → ℕ) :
    ∀ (l : List α), l.Pairwise (fun a b => key a ≤ key b) →
      (kvE2_sepTieRuns key l).Pairwise
        (fun c₁ c₂ => ∀ u ∈ c₁, ∀ v ∈ c₂, key u < key v)
  | [], _ => by simp [kvE2_sepTieRuns]
  | [a], _ => by simp [kvE2_sepTieRuns]
  | a :: b :: rest, hsort => by
      obtain ⟨t, cs, heq⟩ := kvE2_sepTieRuns_shape key rest b
      have hcons := List.pairwise_cons.mp hsort
      have ha : ∀ z ∈ b :: rest, key a ≤ key z := hcons.1
      have hbrest : (b :: rest).Pairwise (fun a b => key a ≤ key b) := hcons.2
      have ih := kvE2_sepTieRuns_key_strictMono key (b :: rest) hbrest
      rw [heq] at ih
      have ihcons := List.pairwise_cons.mp ih
      have hb_le : ∀ z ∈ b :: rest, key b ≤ key z := by
        intro z hz
        rcases List.mem_cons.mp hz with rfl | hz
        · exact le_refl _
        · exact (List.pairwise_cons.mp hbrest).1 z hz
      have hflat : ((b :: t) :: cs).flatten = b :: rest := by
        rw [← heq]; exact kvE2_sepTieRuns_flatten key (b :: rest)
      have hmem_brest : ∀ d ∈ (b :: t) :: cs, ∀ v ∈ d, v ∈ b :: rest := by
        intro d hd v hv
        rw [← hflat]
        exact List.mem_flatten.mpr ⟨d, hd, hv⟩
      rw [kvE2_sepTieRuns, heq]
      by_cases hk : key a = key b
      · simp only [if_pos hk]
        rw [List.pairwise_cons]
        refine ⟨?_, ihcons.2⟩
        intro d hd u hu v hv
        rcases List.mem_cons.mp hu with rfl | hu
        · have hbv : key b < key v := ihcons.1 d hd b List.mem_cons_self v hv
          omega
        · exact ihcons.1 d hd u hu v hv
      · simp only [if_neg hk]
        rw [List.pairwise_cons]
        refine ⟨?_, ih⟩
        intro d hd u hu v hv
        rw [List.mem_singleton] at hu
        have hvmem : v ∈ b :: rest := hmem_brest d hd v hv
        have hab : key a < key b := lt_of_le_of_ne (ha b List.mem_cons_self) hk
        rw [hu]
        exact lt_of_lt_of_le hab (hb_le v hvmem)

/-- **Tie-class index order from strict key order** (task 333 Route A, (a)): on a key-sorted
    list, members of distinct tie classes with strictly ordered keys sit in strictly ordered
    classes — the index-level read that replaces the refuted flat-list
    `kvE2_sep_index_lt_of_rank_lt` route for grouped disjuncts. Trichotomy: equal indices are
    refuted by within-class key constancy (`kvE2_sepTieRuns_key_const`), reversed indices by
    cross-class strict key monotonicity (`kvE2_sepTieRuns_key_strictMono` through
    `List.pairwise_iff_getElem`). -/
theorem kvE2_sepTieRuns_classIdx_lt {α : Type*} (key : α → ℕ) (l : List α)
    (hs : l.Pairwise (fun x y => key x ≤ key y))
    {i j : ℕ} (hi : i < (kvE2_sepTieRuns key l).length)
    (hj : j < (kvE2_sepTieRuns key l).length)
    {a b : α} (ha : a ∈ (kvE2_sepTieRuns key l)[i]) (hb : b ∈ (kvE2_sepTieRuns key l)[j])
    (hab : key a < key b) : i < j := by
  rcases Nat.lt_trichotomy i j with hlt | heq | hgt
  · exact hlt
  · exfalso
    subst heq
    have hconst := kvE2_sepTieRuns_key_const key l ((kvE2_sepTieRuns key l)[i])
      (List.getElem_mem hi) a ha b hb
    omega
  · exfalso
    have hstrict := kvE2_sepTieRuns_key_strictMono key l hs
    have hba := List.pairwise_iff_getElem.mp hstrict j i hj hi hgt b hb a ha
    omega

/-- **Route-A tie-admitting grouped extraction** (task 333 Phase 2, (c); the grouped analog
    of the flat template `kvE2_sepDisjunct_extract`): from a realized GROUPED disjunct of
    any valid weak order `wo ∈ kvE2_sepArr' qnf`, extract both joint endpoint realizations,
    the ONE shared witness `w` (the `ptW` slot at class position `|gL|`; `x < w < t` from
    the bracket's own range — FM-x1t), and at that same `w` the per-σ witness bundle for
    every positive interior σ of either class. Every point is read through the meet-folded
    class type (`kvE2_sepClassType_eval_mem`: a realized class point realizes EACH member's
    slot type — Def 3.1 conjunction semantics, Rabinovich 2014, p.4), so ties never obstruct
    the read: cross-owner ties merely enlarge a class's meet. Same-owner anchor/base
    separation needs NO cross-owner hypothesis — the strict same-owner key order
    `kvE2_sep_gidx_lt_of_rank_lt` (conjunct (ii) via `kvE2_sepArr'_consistent`) forces the
    `lXU`/`rWX1` slot into a STRICTLY earlier tie class than the `lX1`/`rX1` anchor
    (`kvE2_sepTieRuns_classIdx_lt` at the merge-sorted key order), and bracket monotonicity
    places its witness strictly below the fresh witness. Witness positions are read
    structurally off class indices (Def 3.1 monotone enumeration; §5 interleaving,
    Rabinovich 2014, p.7) — never an `x1 < e_i` literal (LITMUS). -/
theorem kvE2_sepDisjunct'_extract {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    {wo : KvE2SepWeakOrder sig} (hwo : wo ∈ kvE2_sepArr' qnf)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (x t : M.carrier)
    (h : (kvE2_sepDisjunct' charBase charK qnf
        (kvE2_sepTieGroupedL wo) (kvE2_sepTieGroupedR wo)).2.holds M atomMap x t) :
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
  -- Shared wo facts: enumeration membership, owner projection, merge-key sortedness
  -- (Bool merge key → Prop key order, the `simpa`-level bridge).
  have hwo' : wo ∈ kvE2_sepOrderTypes qnf := (List.mem_filter.mp hwo).1
  have howners : wo.map Prod.fst = kvE2_sepPosI qnf := kvE2_sepOrderTypes_owners qnf hwo'
  have hksortL : (kvE2_sepSlotsLOf wo).Pairwise
      (fun a b => kvE2_sepSlotGIdx wo a ≤ kvE2_sepSlotGIdx wo b) := by
    refine (kvE2_sepSlotsLOf_mergeSorted wo).imp ?_
    intro a b hab; rw [kvE2_sepSlotMergeLe, decide_eq_true_eq] at hab; exact hab
  have hksortR : (kvE2_sepSlotsROf wo).Pairwise
      (fun a b => kvE2_sepSlotGIdx wo a ≤ kvE2_sepSlotGIdx wo b) := by
    refine (kvE2_sepSlotsROf_mergeSorted wo).imp ?_
    intro a b hab; rw [kvE2_sepSlotMergeLe, decide_eq_true_eq] at hab; exact hab
  -- Destructure the realized grouped N-slot bracket (Def 3.1 monotone enumeration, p.4;
  -- skeleton transposed from the flat template).
  simp only [kvE2_sepDisjunct', kvE2_sepBracketN, BracketFormula.holds,
    BracketFormula.toIntervalPattern] at hbr
  rw [IntervalPattern.holds_eq_succ M atomMap _ _ x t
    (show ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length + 1
        + ((kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK)).length
      = ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length
        + ((kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK)).length + 1
      by omega)] at hbr
  obtain ⟨ws, hmono, hrange, hpt, -, -, -⟩ := hbr
  -- Canonical point-type reads (defeq re-typing; flat-template pattern).
  have hpt' : ∀ (i : Nat)
      (hi : i < ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length
        + ((kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK)).length + 1),
      (((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)
          ++ kvE2_sepPtW charBase charK qnf
            :: (kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK))[i]'(by
        simp only [List.length_append, List.length_cons]; omega)).eval_at M atomMap
        (ws ⟨i, hi⟩) := fun i hi => hpt ⟨i, hi⟩
  refine ⟨ws ⟨((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length,
      by omega⟩,
    (hrange _).1, (hrange _).2, ?_, ?_, ?_⟩
  · -- The shared `ptW` realization at class position `|gL|` (§5 bracket, p.7).
    have h1 := hpt'
      ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length (by omega)
    rwa [kvE2_sep_getElem_mid] at h1
  · -- LEFT-interior bundles: σ's fresh slot lies in some LEFT tie class.
    intro σ hσpos hzone
    have hσI : σ ∈ kvE2_sepPosI qnf :=
      (kvE2_sepPosI_mem qnf σ).mpr ⟨hσpos, Or.inl hzone⟩
    have hσp : σ ∈ wo.map Prod.fst := by rw [howners]; exact hσI
    obtain ⟨p, hpwo, hp1⟩ := List.mem_map.mp hσp
    have hpe : (σ, p.2.1, p.2.2) ∈ wo := by rw [← hp1]; exact hpwo
    have hmemX1 : (KvE2SepSlot.lX1 σ) ∈ kvE2_sepSlotsLOf wo :=
      kvE2_sepSlotsLOf_mem qnf hwo' hσI (kvE2_sep_lX1_mem_slotsLFor hzone)
    rw [← kvE2_sepTieGroupedL_flatten wo] at hmemX1
    obtain ⟨c, hc, hsc⟩ := List.mem_flatten.mp hmemX1
    obtain ⟨iσ, hiσ, hgetiσ⟩ := List.mem_iff_getElem.mp hc
    have hiσm : iσ
        < ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length := by
      simp only [List.length_map]; omega
    refine ⟨ws ⟨iσ, by omega⟩, (hrange _).1,
      hmono _ _ (Fin.mk_lt_mk.mpr hiσm), ?_, ?_⟩
    · -- σ's folded fresh point type through the class meet (Def 3.1 conjunction, p.4).
      have h1 := hpt' iσ (by omega)
      rw [kvE2_sep_getElem_left _ _ _ iσ hiσm, List.getElem_map, hgetiσ] at h1
      exact kvE2_sepClassType_eval_mem charBase charK M atomMap _ h1 hsc
    · -- Every `zXU`-positive 1-type strictly below the fresh witness: strict same-owner
      -- key order → strictly earlier tie class → bracket monotonicity.
      intro χ hbit
      have hmemU : (KvE2SepSlot.lXU σ χ) ∈ kvE2_sepSlotsLOf wo :=
        kvE2_sepSlotsLOf_mem qnf hwo' hσI (kvE2_sep_lXU_mem_slotsLFor hzone hbit)
      rw [← kvE2_sepTieGroupedL_flatten wo] at hmemU
      obtain ⟨d, hd, hsd⟩ := List.mem_flatten.mp hmemU
      obtain ⟨jχ, hjχ, hgetjχ⟩ := List.mem_iff_getElem.mp hd
      have hkey : kvE2_sepSlotGIdx wo (KvE2SepSlot.lXU σ χ)
          < kvE2_sepSlotGIdx wo (KvE2SepSlot.lX1 σ) :=
        kvE2_sep_gidx_lt_of_rank_lt qnf hwo hpe
          (by rw [kvE2_sepSlotBlock]
              exact List.mem_append_left _ (kvE2_sep_lXU_mem_slotsLFor hzone hbit))
          (by rw [kvE2_sepSlotBlock]
              exact List.mem_append_left _ (kvE2_sep_lX1_mem_slotsLFor hzone))
          rfl Nat.zero_lt_one
      have hain : (KvE2SepSlot.lXU σ χ) ∈ (kvE2_sepTieGroupedL wo)[jχ]'hjχ := by
        rw [hgetjχ]; exact hsd
      have hbin : (KvE2SepSlot.lX1 σ) ∈ (kvE2_sepTieGroupedL wo)[iσ]'hiσ := by
        rw [hgetiσ]; exact hsc
      have hji : jχ < iσ := kvE2_sepTieRuns_classIdx_lt (kvE2_sepSlotGIdx wo)
        (kvE2_sepSlotsLOf wo) hksortL hjχ hiσ hain hbin hkey
      have hjχm : jχ
          < ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length := by
        simp only [List.length_map]; omega
      refine ⟨ws ⟨jχ, by omega⟩, (hrange _).1,
        hmono _ _ (Fin.mk_lt_mk.mpr hji), ?_⟩
      have h1 := hpt' jχ (by omega)
      rw [kvE2_sep_getElem_left _ _ _ jχ hjχm, List.getElem_map, hgetjχ] at h1
      exact kvE2_sepClassType_eval_mem charBase charK M atomMap _ h1 hsd
  · -- RIGHT-interior bundles (mirrored): σ's fresh slot lies in some RIGHT tie class.
    intro σ hσpos hzone
    have hσI : σ ∈ kvE2_sepPosI qnf :=
      (kvE2_sepPosI_mem qnf σ).mpr ⟨hσpos, Or.inr hzone⟩
    have hσp : σ ∈ wo.map Prod.fst := by rw [howners]; exact hσI
    obtain ⟨p, hpwo, hp1⟩ := List.mem_map.mp hσp
    have hpe : (σ, p.2.1, p.2.2) ∈ wo := by rw [← hp1]; exact hpwo
    have hmemX1 : (KvE2SepSlot.rX1 σ) ∈ kvE2_sepSlotsROf wo :=
      kvE2_sepSlotsROf_mem qnf hwo' hσI (kvE2_sep_rX1_mem_slotsRFor hzone)
    rw [← kvE2_sepTieGroupedR_flatten wo] at hmemX1
    obtain ⟨c, hc, hsc⟩ := List.mem_flatten.mp hmemX1
    obtain ⟨jσ, hjσ, hgetjσ⟩ := List.mem_iff_getElem.mp hc
    have hjσm : jσ
        < ((kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK)).length := by
      simp only [List.length_map]; omega
    refine ⟨ws ⟨((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length
        + 1 + jσ, by omega⟩,
      hmono _ _ (Fin.mk_lt_mk.mpr (by omega)), (hrange _).2, ?_, ?_⟩
    · have h1 := hpt'
        (((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length + 1 + jσ)
        (by omega)
      rw [kvE2_sep_getElem_right _ _ _ jσ hjσm, List.getElem_map, hgetjσ] at h1
      exact kvE2_sepClassType_eval_mem charBase charK M atomMap _ h1 hsc
    · intro χ hbit
      have hmemU : (KvE2SepSlot.rWX1 σ χ) ∈ kvE2_sepSlotsROf wo :=
        kvE2_sepSlotsROf_mem qnf hwo' hσI (kvE2_sep_rWX1_mem_slotsRFor hzone hbit)
      rw [← kvE2_sepTieGroupedR_flatten wo] at hmemU
      obtain ⟨d, hd, hsd⟩ := List.mem_flatten.mp hmemU
      obtain ⟨j', hj', hgetj'⟩ := List.mem_iff_getElem.mp hd
      have hkey : kvE2_sepSlotGIdx wo (KvE2SepSlot.rWX1 σ χ)
          < kvE2_sepSlotGIdx wo (KvE2SepSlot.rX1 σ) :=
        kvE2_sep_gidx_lt_of_rank_lt qnf hwo hpe
          (by rw [kvE2_sepSlotBlock]
              exact List.mem_append_right _ (kvE2_sep_rWX1_mem_slotsRFor hzone hbit))
          (by rw [kvE2_sepSlotBlock]
              exact List.mem_append_right _ (kvE2_sep_rX1_mem_slotsRFor hzone))
          rfl Nat.zero_lt_one
      have hain : (KvE2SepSlot.rWX1 σ χ) ∈ (kvE2_sepTieGroupedR wo)[j']'hj' := by
        rw [hgetj']; exact hsd
      have hbin : (KvE2SepSlot.rX1 σ) ∈ (kvE2_sepTieGroupedR wo)[jσ]'hjσ := by
        rw [hgetjσ]; exact hsc
      have hji : j' < jσ := kvE2_sepTieRuns_classIdx_lt (kvE2_sepSlotGIdx wo)
        (kvE2_sepSlotsROf wo) hksortR hj' hjσ hain hbin hkey
      have hj'm : j'
          < ((kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK)).length := by
        simp only [List.length_map]; omega
      refine ⟨ws ⟨((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length
          + 1 + j', by omega⟩,
        hmono _ _ (Fin.mk_lt_mk.mpr (by omega)),
        hmono _ _ (Fin.mk_lt_mk.mpr (by omega)), ?_⟩
      have h1 := hpt'
        (((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length + 1 + j')
        (by omega)
      rw [kvE2_sep_getElem_right _ _ _ j' hj'm, List.getElem_map, hgetj'] at h1
      exact kvE2_sepClassType_eval_mem charBase charK M atomMap _ h1 hsd

/-- **O3 at carrier level — the hypothesis-free Route-A body extraction** (task 333
    Phase 2, (d)): extraction from any realized `kvE2_sepBody`, with NO universal
    side-conditions — every needed fact derives from the realized disjunct's own carrier
    membership `wo ∈ kvE2_sepArr' qnf` (no gate hypothesis — the gate-failure branch is the
    empty disjunction, whose `holds` is `False`). Routes through the O2 membership collapse
    `kvE2_sepBody_holds_iff` and the tie-admitting grouped extraction
    `kvE2_sepDisjunct'_extract`, which reads per-class witnesses through
    `kvE2_sepClassType_eval_mem` on the GROUPED disjunct — matching the tie-admitting
    carrier design the task-342 repair installed (base-base ties deliberately representable).
    The former tie-free singleton-conversion route and its universal `hpairL`/`hpairR`/`hnd`
    side-conditions (FALSE for general `qnf` — task 333 Phase-2 blocker record) are
    eliminated. Def 3.1 single strict witness chain (Rabinovich 2014, p.4); §5 interleaving
    (p.7). -/
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
    obtain ⟨wo, hwo, hd⟩ := h
    exact kvE2_sepDisjunct'_extract charBase charK qnf hwo M atomMap x t hd
  · rw [kvE2_sepBody_gate_fail charBase charK qnf hg] at h
    simp [VVecEA2.holds] at h

/-- **One value per LEFT tie class** (task 337 plan 12 Phase 1): all slots of a single
    tie class of the primed grouped LEFT list carry EQUAL honest slot value. Equal keys within
    the class (`kvE2_sepTieRuns_key_const`) become equal honest values through the primed bridge
    + the tie-reporting payload law `kvE2_sepSlotHonestVIdx_eq_iff` (SW:5857). -/
theorem kvE2_sepTieGroupedL_value_const {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {c : List (KvE2SepSlot sig)}
    (hc : c ∈ kvE2_sepTieGroupedL (kvE2_sepHonestOrder' qnf M w x t h))
    {u : KvE2SepSlot sig} (hu : u ∈ c) {v : KvE2SepSlot sig} (hv : v ∈ c) :
    kvE2_sepSlotValue qnf M w x t h u = kvE2_sepSlotValue qnf M w x t h v := by
  have hwo : (kvE2_sepHonestOrder' qnf M w x t h).map Prod.fst = kvE2_sepPosI qnf := by
    rw [kvE2_sepHonestOrder', List.map_map]; exact List.zipIdx_map_fst 0 _
  rw [kvE2_sepTieGroupedL] at hc
  have hkey : kvE2_sepSlotGIdx (kvE2_sepHonestOrder' qnf M w x t h) u
      = kvE2_sepSlotGIdx (kvE2_sepHonestOrder' qnf M w x t h) v :=
    kvE2_sepTieRuns_key_const _ _ c hc u hu v hv
  have huf : u ∈ kvE2_sepSlotsLOf (kvE2_sepHonestOrder' qnf M w x t h) := by
    rw [← kvE2_sepTieGroupedL_flatten (kvE2_sepHonestOrder' qnf M w x t h)]
    rw [kvE2_sepTieGroupedL]
    exact List.mem_flatten.mpr ⟨c, hc, hu⟩
  have hvf : v ∈ kvE2_sepSlotsLOf (kvE2_sepHonestOrder' qnf M w x t h) := by
    rw [← kvE2_sepTieGroupedL_flatten (kvE2_sepHonestOrder' qnf M w x t h)]
    rw [kvE2_sepTieGroupedL]
    exact List.mem_flatten.mpr ⟨c, hc, hv⟩
  obtain ⟨σ, hσ, huσ⟩ := kvE2_sepSlotsLOf_mem_block hwo huf
  obtain ⟨τ, hτ, hvτ⟩ := kvE2_sepSlotsLOf_mem_block hwo hvf
  rw [kvE2_sepSlotGIdx_honestOrder' qnf M w x t h (kvE2_sepPosI_subset hσ) huσ,
      kvE2_sepSlotGIdx_honestOrder' qnf M w x t h (kvE2_sepPosI_subset hτ) hvτ] at hkey
  exact (kvE2_sepSlotHonestVIdx_eq_iff qnf M w x t h
    (kvE2_sepMem_allSlots qnf (kvE2_sepPosI_subset hσ) huσ)
    (kvE2_sepMem_allSlots qnf (kvE2_sepPosI_subset hτ) hvτ)).mp hkey

/-- **One value per RIGHT tie class** (mirror of `kvE2_sepTieGroupedL_value_const`). -/
theorem kvE2_sepTieGroupedR_value_const {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {c : List (KvE2SepSlot sig)}
    (hc : c ∈ kvE2_sepTieGroupedR (kvE2_sepHonestOrder' qnf M w x t h))
    {u : KvE2SepSlot sig} (hu : u ∈ c) {v : KvE2SepSlot sig} (hv : v ∈ c) :
    kvE2_sepSlotValue qnf M w x t h u = kvE2_sepSlotValue qnf M w x t h v := by
  have hwo : (kvE2_sepHonestOrder' qnf M w x t h).map Prod.fst = kvE2_sepPosI qnf := by
    rw [kvE2_sepHonestOrder', List.map_map]; exact List.zipIdx_map_fst 0 _
  rw [kvE2_sepTieGroupedR] at hc
  have hkey : kvE2_sepSlotGIdx (kvE2_sepHonestOrder' qnf M w x t h) u
      = kvE2_sepSlotGIdx (kvE2_sepHonestOrder' qnf M w x t h) v :=
    kvE2_sepTieRuns_key_const _ _ c hc u hu v hv
  have huf : u ∈ kvE2_sepSlotsROf (kvE2_sepHonestOrder' qnf M w x t h) := by
    rw [← kvE2_sepTieGroupedR_flatten (kvE2_sepHonestOrder' qnf M w x t h)]
    rw [kvE2_sepTieGroupedR]
    exact List.mem_flatten.mpr ⟨c, hc, hu⟩
  have hvf : v ∈ kvE2_sepSlotsROf (kvE2_sepHonestOrder' qnf M w x t h) := by
    rw [← kvE2_sepTieGroupedR_flatten (kvE2_sepHonestOrder' qnf M w x t h)]
    rw [kvE2_sepTieGroupedR]
    exact List.mem_flatten.mpr ⟨c, hc, hv⟩
  obtain ⟨σ, hσ, huσ⟩ := kvE2_sepSlotsROf_mem_block hwo huf
  obtain ⟨τ, hτ, hvτ⟩ := kvE2_sepSlotsROf_mem_block hwo hvf
  rw [kvE2_sepSlotGIdx_honestOrder' qnf M w x t h (kvE2_sepPosI_subset hσ) huσ,
      kvE2_sepSlotGIdx_honestOrder' qnf M w x t h (kvE2_sepPosI_subset hτ) hvτ] at hkey
  exact (kvE2_sepSlotHonestVIdx_eq_iff qnf M w x t h
    (kvE2_sepMem_allSlots qnf (kvE2_sepPosI_subset hσ) huσ)
    (kvE2_sepMem_allSlots qnf (kvE2_sepPosI_subset hτ) hvτ)).mp hkey

/-- **O1 cross-class strict value monotonicity, LEFT** (task 337 plan 13 Phase 3 / report 14 Q5):
    the primed grouped LEFT tie classes carry STRICTLY increasing honest values across distinct
    classes — every member of an earlier class has strictly smaller value than every member of a
    later class. Assembles five landed Phase-1 assets: value-sortedness (`≤` between classes via
    `List.pairwise_flatten`), key strict monotonicity across runs
    (`kvE2_sepTieRuns_key_strictMono`), the primed bridge (`kvE2_sepSlotGIdx_honestOrder'`), and
    the tie-reporting payload law (`kvE2_sepSlotHonestVIdx_eq_iff`, giving `≠` from key-distinct).
    `≤` ∧ `≠` ⟹ `<`. Faithful to Rabinovich Lemma 5.3's strict inter-point chain (the merge
    absorbs ties, the order is not weakened). -/
theorem kvE2_sepTieGroupedL_strictMono {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    (kvE2_sepTieGroupedL (kvE2_sepHonestOrder' qnf M w x t h)).Pairwise
      (fun c₁ c₂ => ∀ u ∈ c₁, ∀ v ∈ c₂,
        kvE2_sepSlotValue qnf M w x t h u < kvE2_sepSlotValue qnf M w x t h v) := by
  set wo := kvE2_sepHonestOrder' qnf M w x t h with hwo_def
  have hwo : wo.map Prod.fst = kvE2_sepPosI qnf := by
    rw [hwo_def, kvE2_sepHonestOrder', List.map_map]; exact List.zipIdx_map_fst 0 _
  have hksort : (kvE2_sepSlotsLOf wo).Pairwise
      (fun a b => kvE2_sepSlotGIdx wo a ≤ kvE2_sepSlotGIdx wo b) := by
    refine (kvE2_sepSlotsLOf_mergeSorted wo).imp ?_
    intro a b hab; rw [kvE2_sepSlotMergeLe, decide_eq_true_eq] at hab; exact hab
  have hkey := kvE2_sepTieRuns_key_strictMono (kvE2_sepSlotGIdx wo)
    (kvE2_sepSlotsLOf wo) hksort
  have hvsorted := kvE2_sepSlotsLOf_honestOrder'_valueSorted qnf M w x t h
  rw [← hwo_def, ← kvE2_sepTieGroupedL_flatten wo, List.pairwise_flatten] at hvsorted
  have hvle := hvsorted.2
  rw [List.pairwise_iff_forall_sublist] at hkey hvle ⊢
  intro c₁ c₂ hsub u hu v hv
  have hle := hvle hsub u hu v hv
  have hklt := hkey hsub u hu v hv
  refine lt_of_le_of_ne hle ?_
  intro hval
  have hc1 : c₁ ∈ kvE2_sepTieGroupedL wo := hsub.subset (by simp)
  have hc2 : c₂ ∈ kvE2_sepTieGroupedL wo := hsub.subset (by simp)
  have hufl : u ∈ kvE2_sepSlotsLOf wo := by
    rw [← kvE2_sepTieGroupedL_flatten wo]; exact List.mem_flatten.mpr ⟨c₁, hc1, hu⟩
  have hvfl : v ∈ kvE2_sepSlotsLOf wo := by
    rw [← kvE2_sepTieGroupedL_flatten wo]; exact List.mem_flatten.mpr ⟨c₂, hc2, hv⟩
  obtain ⟨σ, hσ, huσ⟩ := kvE2_sepSlotsLOf_mem_block hwo hufl
  obtain ⟨τ, hτ, hvτ⟩ := kvE2_sepSlotsLOf_mem_block hwo hvfl
  have hkeq : kvE2_sepSlotGIdx wo u = kvE2_sepSlotGIdx wo v := by
    rw [hwo_def, kvE2_sepSlotGIdx_honestOrder' qnf M w x t h (kvE2_sepPosI_subset hσ) huσ,
        kvE2_sepSlotGIdx_honestOrder' qnf M w x t h (kvE2_sepPosI_subset hτ) hvτ]
    exact (kvE2_sepSlotHonestVIdx_eq_iff qnf M w x t h
      (kvE2_sepMem_allSlots qnf (kvE2_sepPosI_subset hσ) huσ)
      (kvE2_sepMem_allSlots qnf (kvE2_sepPosI_subset hτ) hvτ)).mpr hval
  omega

/-- **O1 cross-class strict value monotonicity, RIGHT** (mirror of `kvE2_sepTieGroupedL_strictMono`). -/
theorem kvE2_sepTieGroupedR_strictMono {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    (kvE2_sepTieGroupedR (kvE2_sepHonestOrder' qnf M w x t h)).Pairwise
      (fun c₁ c₂ => ∀ u ∈ c₁, ∀ v ∈ c₂,
        kvE2_sepSlotValue qnf M w x t h u < kvE2_sepSlotValue qnf M w x t h v) := by
  set wo := kvE2_sepHonestOrder' qnf M w x t h with hwo_def
  have hwo : wo.map Prod.fst = kvE2_sepPosI qnf := by
    rw [hwo_def, kvE2_sepHonestOrder', List.map_map]; exact List.zipIdx_map_fst 0 _
  have hksort : (kvE2_sepSlotsROf wo).Pairwise
      (fun a b => kvE2_sepSlotGIdx wo a ≤ kvE2_sepSlotGIdx wo b) := by
    refine (kvE2_sepSlotsROf_mergeSorted wo).imp ?_
    intro a b hab; rw [kvE2_sepSlotMergeLe, decide_eq_true_eq] at hab; exact hab
  have hkey := kvE2_sepTieRuns_key_strictMono (kvE2_sepSlotGIdx wo)
    (kvE2_sepSlotsROf wo) hksort
  have hvsorted := kvE2_sepSlotsROf_honestOrder'_valueSorted qnf M w x t h
  rw [← hwo_def, ← kvE2_sepTieGroupedR_flatten wo, List.pairwise_flatten] at hvsorted
  have hvle := hvsorted.2
  rw [List.pairwise_iff_forall_sublist] at hkey hvle ⊢
  intro c₁ c₂ hsub u hu v hv
  have hle := hvle hsub u hu v hv
  have hklt := hkey hsub u hu v hv
  refine lt_of_le_of_ne hle ?_
  intro hval
  have hc1 : c₁ ∈ kvE2_sepTieGroupedR wo := hsub.subset (by simp)
  have hc2 : c₂ ∈ kvE2_sepTieGroupedR wo := hsub.subset (by simp)
  have hufl : u ∈ kvE2_sepSlotsROf wo := by
    rw [← kvE2_sepTieGroupedR_flatten wo]; exact List.mem_flatten.mpr ⟨c₁, hc1, hu⟩
  have hvfl : v ∈ kvE2_sepSlotsROf wo := by
    rw [← kvE2_sepTieGroupedR_flatten wo]; exact List.mem_flatten.mpr ⟨c₂, hc2, hv⟩
  obtain ⟨σ, hσ, huσ⟩ := kvE2_sepSlotsROf_mem_block hwo hufl
  obtain ⟨τ, hτ, hvτ⟩ := kvE2_sepSlotsROf_mem_block hwo hvfl
  have hkeq : kvE2_sepSlotGIdx wo u = kvE2_sepSlotGIdx wo v := by
    rw [hwo_def, kvE2_sepSlotGIdx_honestOrder' qnf M w x t h (kvE2_sepPosI_subset hσ) huσ,
        kvE2_sepSlotGIdx_honestOrder' qnf M w x t h (kvE2_sepPosI_subset hτ) hvτ]
    exact (kvE2_sepSlotHonestVIdx_eq_iff qnf M w x t h
      (kvE2_sepMem_allSlots qnf (kvE2_sepPosI_subset hσ) huσ)
      (kvE2_sepMem_allSlots qnf (kvE2_sepPosI_subset hτ) hvτ)).mpr hval
  omega

/-- **O1 below-pivot range, per owner (LEFT)** (task 337 plan 13 Phase 3): every LEFT-region slot
    of a positive owner has honest value strictly inside `(x, w)` — the below-pivot bracket half
    (Rabinovich Figure 1, PDF p.9). For a left-interior owner the `.lXU`/`.lX1`/`.lUW` slots nest
    inside `(x, x1_σ) < x1_σ < (x1_σ, w)`; for a right-interior owner the `.rXW` slots sit in
    `(x, w)` by the landed Phase-2 below-pivot bound. Supplies the `usL`-last `< w` pivot fact O1
    needs (per-slot value specs, NOT value-sortedness — plan 12 line 140 mis-mitigation retracted). -/
theorem kvE2_sepSlotsLFor_value_bound {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf)
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2_sepSlotsLFor σ) :
    x < kvE2_sepSlotValue qnf M w x t h s
      ∧ kvE2_sepSlotValue qnf M w x t h s < w := by
  rw [kvE2_sepSlotsLFor] at hs
  by_cases hz1 : nf0_zoneSpec σ.1 = kvE2_sep_zXW3
  · rw [if_pos hz1, List.mem_append] at hs
    rcases hs with hs | hs
    · obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp hs
      have hspec := kvE2_sepSlotValue_lXU_spec qnf M w x t hxw hwt h σ hσ hz1 χ hχ
      have hanch := (kvE2_sepHonestAnchorBundleL qnf M w x t hxw hwt h σ hσ hz1).2.1
      exact ⟨hspec.1, lt_trans hspec.2.1 hanch⟩
    · rw [List.mem_cons] at hs
      rcases hs with rfl | hs
      · have hanch := kvE2_sepHonestAnchorBundleL qnf M w x t hxw hwt h σ hσ hz1
        rw [kvE2_sepSlotValue_lX1]
        exact ⟨hanch.1, hanch.2.1⟩
      · obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp hs
        have hspec := kvE2_sepSlotValue_lUW_spec qnf M w x t hxw hwt h σ hσ hz1 χ hχ
        have hanch := (kvE2_sepHonestAnchorBundleL qnf M w x t hxw hwt h σ hσ hz1).1
        exact ⟨lt_trans hanch hspec.1, hspec.2.1⟩
  · by_cases hz2 : nf0_zoneSpec σ.1 = kvE2_sep_zWT3
    · rw [if_neg hz1, if_pos hz2] at hs
      obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp hs
      have hspec := kvE2_sepSlotValue_rXW_spec qnf M w x t h σ hσ χ hχ
      exact ⟨hspec.1, hspec.2.1⟩
    · rw [if_neg hz1, if_neg hz2] at hs
      exact absurd hs (by simp)

/-- **O1 above-pivot range, per owner (RIGHT)** (mirror of `kvE2_sepSlotsLFor_value_bound`): every
    RIGHT-region slot of a positive owner has honest value strictly inside `(w, t)` — the
    above-pivot bracket half. Supplies the `w < usR`-first pivot fact. -/
theorem kvE2_sepSlotsRFor_value_bound {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf)
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2_sepSlotsRFor σ) :
    w < kvE2_sepSlotValue qnf M w x t h s
      ∧ kvE2_sepSlotValue qnf M w x t h s < t := by
  rw [kvE2_sepSlotsRFor] at hs
  by_cases hz1 : nf0_zoneSpec σ.1 = kvE2_sep_zXW3
  · rw [if_pos hz1] at hs
    obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp hs
    have hspec := kvE2_sepSlotValue_lWT_spec qnf M w x t h σ hσ χ hχ
    exact ⟨hspec.1, hspec.2.1⟩
  · by_cases hz2 : nf0_zoneSpec σ.1 = kvE2_sep_zWT3
    · rw [if_neg hz1, if_pos hz2, List.mem_append] at hs
      rcases hs with hs | hs
      · obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp hs
        have hspec := kvE2_sepSlotValue_rWX1_spec qnf M w x t hxw hwt h σ hσ hz2 χ hχ
        have hanch := (kvE2_sepHonestAnchorBundleR qnf M w x t hxw hwt h σ hσ hz2).2.1
        exact ⟨hspec.1, lt_trans hspec.2.1 hanch⟩
      · rw [List.mem_cons] at hs
        rcases hs with rfl | hs
        · have hanch := kvE2_sepHonestAnchorBundleR qnf M w x t hxw hwt h σ hσ hz2
          rw [kvE2_sepSlotValue_rX1]
          exact ⟨hanch.1, hanch.2.1⟩
        · obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp hs
          have hspec := kvE2_sepSlotValue_rX1T_spec qnf M w x t hxw hwt h σ hσ hz2 χ hχ
          have hanch := (kvE2_sepHonestAnchorBundleR qnf M w x t hxw hwt h σ hσ hz2).1
          exact ⟨lt_trans hanch hspec.1, hspec.2.1⟩
    · rw [if_neg hz1, if_neg hz2] at hs
      exact absurd hs (by simp)

/-- **O1 below-pivot range, merged LEFT list** (task 337 plan 13 Phase 3): every slot of the
    primed merged LEFT list has honest value strictly inside `(x, w)`. The list-level pivot/range
    fact the Phase-7 assembly reads for `usL`-last `< w` and the global `x < · < t` range. -/
theorem kvE2_sepSlotsLOf_honestOrder'_value_bound {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2_sepSlotsLOf (kvE2_sepHonestOrder' qnf M w x t h)) :
    x < kvE2_sepSlotValue qnf M w x t h s
      ∧ kvE2_sepSlotValue qnf M w x t h s < w := by
  have hwo : (kvE2_sepHonestOrder' qnf M w x t h).map Prod.fst = kvE2_sepPosI qnf := by
    rw [kvE2_sepHonestOrder', List.map_map]; exact List.zipIdx_map_fst 0 _
  rw [kvE2_sepSlotsLOf] at hs
  obtain ⟨σ, hσ, hsσ⟩ := List.mem_flatMap.mp ((List.mergeSort_perm _ _).mem_iff.mp hs)
  have hσpos : σ ∈ kvE2_sepPos qnf :=
    kvE2_sepPosI_subset (kvE2_sepOrderOwners_mem_pos hwo hσ)
  exact kvE2_sepSlotsLFor_value_bound qnf M w x t hxw hwt h hσpos hsσ

/-- **O1 above-pivot range, merged RIGHT list** (mirror of `kvE2_sepSlotsLOf_honestOrder'_value_bound`):
    every slot of the primed merged RIGHT list has honest value strictly inside `(w, t)`. -/
theorem kvE2_sepSlotsROf_honestOrder'_value_bound {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2_sepSlotsROf (kvE2_sepHonestOrder' qnf M w x t h)) :
    w < kvE2_sepSlotValue qnf M w x t h s
      ∧ kvE2_sepSlotValue qnf M w x t h s < t := by
  have hwo : (kvE2_sepHonestOrder' qnf M w x t h).map Prod.fst = kvE2_sepPosI qnf := by
    rw [kvE2_sepHonestOrder', List.map_map]; exact List.zipIdx_map_fst 0 _
  rw [kvE2_sepSlotsROf] at hs
  obtain ⟨σ, hσ, hsσ⟩ := List.mem_flatMap.mp ((List.mergeSort_perm _ _).mem_iff.mp hs)
  have hσpos : σ ∈ kvE2_sepPos qnf :=
    kvE2_sepPosI_subset (kvE2_sepOrderOwners_mem_pos hwo hσ)
  exact kvE2_sepSlotsRFor_value_bound qnf M w x t hxw hwt h hσpos hsσ

/-! ### Task 337 (plan 13) Phase 4 — O2: class point-type realization at the honest class value

The grouped bracket's LEFT/RIGHT point-type lists are `gL.map kvE2_sepClassType` /
`gR.map (…)`. `kvE2_sepBracketN_construct`'s `hptL`/`hptR` obligations require each class type to
evaluate at that class's honest witness value. Via `kvE2_sepClassType_eval_iff` this reduces to
every class MEMBER's slot type realizing at the (shared) class value; since one value per class
(`kvE2_sepTieGroupedL/R_value_const`), the class value is each member's OWN honest value, so the
obligation is the per-slot point-type discharge below. Base slots ride `hcb` + the banked value
specs; anchor slots ride the fresh-projection channel (`kvE2_sepProjFresh_eval` + `hck`) and the
CLOSED self-zone literal reads (`kvE2_sepOwnerLit_zAtX1L/R`). F5: only CLOSED `zAtX1L`/`zAtX1R`
keys enter; LITMUS-clean (all bounds ride `x`/`w`/`t`). -/

/-- `zAtX1L` self-zone literal honesty at a LEFT-interior owner's anchor value `a` (`x < a < w`):
    mirror of `kvE2_sepOwnerLit_zAtWL` reading the fresh-witness self-zone `v = a` instead of the
    pivot. -/
private theorem kvE2_sepOwnerLit_zAtX1L {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (σ : NormalForm sig 1 4) (a w x t : M.carrier)
    (hxa : x < a) (haw : a < w) (hwt : w < t)
    (hs : nf_eval_nf M 1 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (χ : NormalForm sig 0 1) :
    temporal_truth M atomMap a
      (kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zAtX1L χ) (charBase χ)) := by
  obtain ⟨-, h_zone, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
  cases hb : kvE2_sepBits σ kvE2_sep_zAtX1L χ with
  | true =>
    show temporal_truth M atomMap a (charBase χ)
    obtain ⟨v, hz, hv⟩ := (h_zone kvE2_sep_zAtX1L χ).mpr hb
    obtain ⟨h0, h1, h2, h3⟩ := (kvE2_sepZone4_iff M a w x t v
      (false, false) (true, false) (false, true) (true, false)).mp hz
    have hveq : v = a := le_antisymm
      (not_lt.mp (fun hc => Bool.noConfusion (h0.2.mp hc)))
      (not_lt.mp (fun hc => Bool.noConfusion (h0.1.mp hc)))
    exact (hcb χ a).mpr (hveq ▸ hv)
  | false =>
    show temporal_truth M atomMap a (charBase χ).neg
    intro hch
    have hat : a < t := haw.trans hwt
    have hz : zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t))))
        kvE2_sep_zAtX1L a := by
      refine (kvE2_sepZone4_iff M a w x t a
        (false, false) (true, false) (false, true) (true, false)).mpr ?_
      exact ⟨⟨iff_of_false (lt_irrefl a) (by decide), iff_of_false (lt_irrefl a) (by decide)⟩,
        ⟨iff_of_true haw rfl, iff_of_false (lt_asymm haw) (by decide)⟩,
        ⟨iff_of_false (lt_asymm hxa) (by decide), iff_of_true hxa rfl⟩,
        ⟨iff_of_true hat rfl, iff_of_false (lt_asymm hat) (by decide)⟩⟩
    have hbit : kvE2_sepBits σ kvE2_sep_zAtX1L χ = true :=
      (h_zone kvE2_sep_zAtX1L χ).mp ⟨a, hz, (hcb χ a).mp hch⟩
    rw [hb] at hbit
    exact Bool.noConfusion hbit

/-- `zAtX1R` self-zone literal honesty at a RIGHT-interior owner's anchor value `a` (`w < a < t`):
    mirror of `kvE2_sepOwnerLit_zAtX1L`. -/
private theorem kvE2_sepOwnerLit_zAtX1R {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (σ : NormalForm sig 1 4) (a w x t : M.carrier)
    (hwa : w < a) (hat : a < t) (hxw : x < w)
    (hs : nf_eval_nf M 1 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (χ : NormalForm sig 0 1) :
    temporal_truth M atomMap a
      (kvE2_sepLit (kvE2_sepBits σ kvE2_sep_zAtX1R χ) (charBase χ)) := by
  have hxa : x < a := hxw.trans hwa
  obtain ⟨-, h_zone, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hs
  cases hb : kvE2_sepBits σ kvE2_sep_zAtX1R χ with
  | true =>
    show temporal_truth M atomMap a (charBase χ)
    obtain ⟨v, hz, hv⟩ := (h_zone kvE2_sep_zAtX1R χ).mpr hb
    obtain ⟨h0, h1, h2, h3⟩ := (kvE2_sepZone4_iff M a w x t v
      (false, false) (false, true) (false, true) (true, false)).mp hz
    have hveq : v = a := le_antisymm
      (not_lt.mp (fun hc => Bool.noConfusion (h0.2.mp hc)))
      (not_lt.mp (fun hc => Bool.noConfusion (h0.1.mp hc)))
    exact (hcb χ a).mpr (hveq ▸ hv)
  | false =>
    show temporal_truth M atomMap a (charBase χ).neg
    intro hch
    have hz : zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t))))
        kvE2_sep_zAtX1R a := by
      refine (kvE2_sepZone4_iff M a w x t a
        (false, false) (false, true) (false, true) (true, false)).mpr ?_
      exact ⟨⟨iff_of_false (lt_irrefl a) (by decide), iff_of_false (lt_irrefl a) (by decide)⟩,
        ⟨iff_of_false (lt_asymm hwa) (by decide), iff_of_true hwa rfl⟩,
        ⟨iff_of_false (lt_asymm hxa) (by decide), iff_of_true hxa rfl⟩,
        ⟨iff_of_true hat rfl, iff_of_false (lt_asymm hat) (by decide)⟩⟩
    have hbit : kvE2_sepBits σ kvE2_sep_zAtX1R χ = true :=
      (h_zone kvE2_sep_zAtX1R χ).mp ⟨a, hz, (hcb χ a).mp hch⟩
    rw [hb] at hbit
    exact Bool.noConfusion hbit

/-- **LEFT anchor point-type honesty** (Phase 4): a LEFT-interior owner σ's folded fresh point
    type `kvE2_sepPtX1L` evaluates at its own honest anchor value. Head = the `charK`-projected
    fresh type (`kvE2_sepProjFresh_eval` + `hck`); the base literals ride the CLOSED `zAtX1L`
    self-zone reads (`kvE2_sepOwnerLit_zAtX1L`). -/
theorem kvE2_sepPtX1L_eval_of_honest {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      temporal_truth M atomMap u (charK χ) ↔ nf_eval_nf M 1 1 (fun _ => u) χ)
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf)
    (hz : nf0_zoneSpec σ.1 = kvE2_sep_zXW3) :
    (kvE2_sepPtX1L charBase charK σ).eval_at M atomMap
      (kvE2_sepAnchorVal qnf M w x t h σ) := by
  have hbσ : qnf.2 σ = true := (List.mem_filter.mp hσ).2
  have hspec := kvE2_sepAnchorVal_spec qnf M w x t h σ hbσ
  have hbundle := kvE2_sepHonestAnchorBundleL qnf M w x t hxw hwt h σ hσ hz
  simp only [kvE2_sepPtX1L, TemporalPred.eval_at]
  rw [formula_conjList_iff]
  intro f hf
  rcases List.mem_cons.mp hf with rfl | hf
  · exact (hck _ _).mpr (kvE2_sepProjFresh_eval M _ _ σ hspec)
  · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
    exact kvE2_sepOwnerLit_zAtX1L charBase M atomMap σ _ w x t hbundle.1 hbundle.2.1 hwt hspec hcb χ

/-- **RIGHT anchor point-type honesty** (Phase 4, mirror of `kvE2_sepPtX1L_eval_of_honest`). -/
theorem kvE2_sepPtX1R_eval_of_honest {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      temporal_truth M atomMap u (charK χ) ↔ nf_eval_nf M 1 1 (fun _ => u) χ)
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf)
    (hz : nf0_zoneSpec σ.1 = kvE2_sep_zWT3) :
    (kvE2_sepPtX1R charBase charK σ).eval_at M atomMap
      (kvE2_sepAnchorVal qnf M w x t h σ) := by
  have hbσ : qnf.2 σ = true := (List.mem_filter.mp hσ).2
  have hspec := kvE2_sepAnchorVal_spec qnf M w x t h σ hbσ
  have hbundle := kvE2_sepHonestAnchorBundleR qnf M w x t hxw hwt h σ hσ hz
  simp only [kvE2_sepPtX1R, TemporalPred.eval_at]
  rw [formula_conjList_iff]
  intro f hf
  rcases List.mem_cons.mp hf with rfl | hf
  · exact (hck _ _).mpr (kvE2_sepProjFresh_eval M _ _ σ hspec)
  · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
    exact kvE2_sepOwnerLit_zAtX1R charBase M atomMap σ _ w x t hbundle.1 hbundle.2.1 hxw hspec hcb χ

/-- **Per-slot point-type honesty** (Phase 4): every slot of a positive owner's block realizes
    its slot point type AT its own honest slot value. Base slots ride `hcb` + the banked value
    specs; anchor slots ride the folded fresh point types above. -/
theorem kvE2_sepSlotType_eval_at_value {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      temporal_truth M atomMap u (charK χ) ↔ nf_eval_nf M 1 1 (fun _ => u) χ)
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf)
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2_sepSlotBlock σ) :
    (kvE2_sepSlotType charBase charK s).eval_at M atomMap
      (kvE2_sepSlotValue qnf M w x t h s) := by
  rw [kvE2_sepMem_slotBlock] at hs
  by_cases hz1 : nf0_zoneSpec σ.1 = kvE2_sep_zXW3
  · rw [kvE2_sepSlotsLFor, kvE2_sepSlotsRFor, if_pos hz1, if_pos hz1] at hs
    rcases hs with hL | hR
    · rcases List.mem_append.mp hL with h1 | h1
      · obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp h1
        simp only [kvE2_sepSlotType, TemporalPred.eval_at]
        exact (hcb χ _).mpr
          (kvE2_sepSlotValue_lXU_spec qnf M w x t hxw hwt h σ hσ hz1 χ hχ).2.2
      · rcases List.mem_cons.mp h1 with rfl | h1
        · rw [kvE2_sepSlotValue_lX1]
          exact kvE2_sepPtX1L_eval_of_honest charBase charK qnf M atomMap w x t hxw hwt h
            hcb hck hσ hz1
        · obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp h1
          simp only [kvE2_sepSlotType, TemporalPred.eval_at]
          exact (hcb χ _).mpr
            (kvE2_sepSlotValue_lUW_spec qnf M w x t hxw hwt h σ hσ hz1 χ hχ).2.2
    · obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp hR
      simp only [kvE2_sepSlotType, TemporalPred.eval_at]
      exact (hcb χ _).mpr
        (kvE2_sepSlotValue_lWT_spec qnf M w x t h σ hσ χ hχ).2.2
  · by_cases hz2 : nf0_zoneSpec σ.1 = kvE2_sep_zWT3
    · rw [kvE2_sepSlotsLFor, kvE2_sepSlotsRFor, if_neg hz1, if_neg hz1,
        if_pos hz2, if_pos hz2] at hs
      rcases hs with hL | hR
      · obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp hL
        simp only [kvE2_sepSlotType, TemporalPred.eval_at]
        exact (hcb χ _).mpr
          (kvE2_sepSlotValue_rXW_spec qnf M w x t h σ hσ χ hχ).2.2
      · rcases List.mem_append.mp hR with h1 | h1
        · obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp h1
          simp only [kvE2_sepSlotType, TemporalPred.eval_at]
          exact (hcb χ _).mpr
            (kvE2_sepSlotValue_rWX1_spec qnf M w x t hxw hwt h σ hσ hz2 χ hχ).2.2
        · rcases List.mem_cons.mp h1 with rfl | h1
          · rw [kvE2_sepSlotValue_rX1]
            exact kvE2_sepPtX1R_eval_of_honest charBase charK qnf M atomMap w x t hxw hwt h
              hcb hck hσ hz2
          · obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp h1
            simp only [kvE2_sepSlotType, TemporalPred.eval_at]
            exact (hcb χ _).mpr
              (kvE2_sepSlotValue_rX1T_spec qnf M w x t hxw hwt h σ hσ hz2 χ hχ).2.2
    · rw [kvE2_sepSlotsLFor, kvE2_sepSlotsRFor, if_neg hz1, if_neg hz1,
        if_neg hz2, if_neg hz2] at hs
      simp only [List.not_mem_nil, or_self] at hs

/-- **LEFT class point-type honesty** (Phase 4 / O2): a primed grouped LEFT tie class realizes
    its meet-folded class type at the honest value of any of its members (all members share the
    value, `kvE2_sepTieGroupedL_value_const`). Feeds the `hptL` obligation of
    `kvE2_sepBracketN_construct`. -/
theorem kvE2_sepTieGroupedL_classType_eval {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      temporal_truth M atomMap u (charK χ) ↔ nf_eval_nf M 1 1 (fun _ => u) χ)
    {c : List (KvE2SepSlot sig)}
    (hc : c ∈ kvE2_sepTieGroupedL (kvE2_sepHonestOrder' qnf M w x t h))
    {s0 : KvE2SepSlot sig} (hs0 : s0 ∈ c) :
    (kvE2_sepClassType charBase charK c).eval_at M atomMap
      (kvE2_sepSlotValue qnf M w x t h s0) := by
  set wo := kvE2_sepHonestOrder' qnf M w x t h with hwo_def
  have hwo : wo.map Prod.fst = kvE2_sepPosI qnf := by
    rw [hwo_def, kvE2_sepHonestOrder', List.map_map]; exact List.zipIdx_map_fst 0 _
  rw [kvE2_sepClassType_eval_iff]
  intro s hs
  rw [kvE2_sepTieGroupedL_value_const qnf M w x t h hc hs0 hs]
  have hsf : s ∈ kvE2_sepSlotsLOf wo := by
    rw [← kvE2_sepTieGroupedL_flatten wo]; exact List.mem_flatten.mpr ⟨c, hc, hs⟩
  obtain ⟨σ, hσ, hsσ⟩ := kvE2_sepSlotsLOf_mem_block hwo hsf
  exact kvE2_sepSlotType_eval_at_value charBase charK qnf M atomMap w x t hxw hwt h hcb hck
    (kvE2_sepPosI_subset hσ) hsσ

/-- **RIGHT class point-type honesty** (Phase 4 / O2, mirror of
    `kvE2_sepTieGroupedL_classType_eval`). -/
theorem kvE2_sepTieGroupedR_classType_eval {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      temporal_truth M atomMap u (charK χ) ↔ nf_eval_nf M 1 1 (fun _ => u) χ)
    {c : List (KvE2SepSlot sig)}
    (hc : c ∈ kvE2_sepTieGroupedR (kvE2_sepHonestOrder' qnf M w x t h))
    {s0 : KvE2SepSlot sig} (hs0 : s0 ∈ c) :
    (kvE2_sepClassType charBase charK c).eval_at M atomMap
      (kvE2_sepSlotValue qnf M w x t h s0) := by
  set wo := kvE2_sepHonestOrder' qnf M w x t h with hwo_def
  have hwo : wo.map Prod.fst = kvE2_sepPosI qnf := by
    rw [hwo_def, kvE2_sepHonestOrder', List.map_map]; exact List.zipIdx_map_fst 0 _
  rw [kvE2_sepClassType_eval_iff]
  intro s hs
  rw [kvE2_sepTieGroupedR_value_const qnf M w x t h hc hs0 hs]
  have hsf : s ∈ kvE2_sepSlotsROf wo := by
    rw [← kvE2_sepTieGroupedR_flatten wo]; exact List.mem_flatten.mpr ⟨c, hc, hs⟩
  obtain ⟨σ, hσ, hsσ⟩ := kvE2_sepSlotsROf_mem_block hwo hsf
  exact kvE2_sepSlotType_eval_at_value charBase charK qnf M atomMap w x t hxw hwt h hcb hck
    (kvE2_sepPosI_subset hσ) hsσ

/-! ### Task 337 (plan 13) Phase 5 — O3(a): honest segment-evaluation family (standalone)

No banked completeness-direction segment-eval lemma exists, so these are NEW. The core reads the
owners' universal (β) layer of `h`: a per-σ exclusion segment `kvE2_sepSegForm σ zs` holds at any
interior point `y` that sits in σ's zone `zs` (relative to σ's honest anchor value), because a
bit-FALSE 1-type realized there would force the fold bit TRUE (contradiction). Everything is
generic in `y` and its zone position (Cor 5.4, md:154-157: exclusion throughout every realized
refined sub-interval). LITMUS-clean: all bounds ride `x`/`w`/`t` + the anchor value, never an
owner-to-owner chain. -/

/-- **Segment-exclusion honesty (core)** (Phase 5): under an honest owner realization at
    `[a, w, x, t]`, if `y` lies in σ's zone `zs`, then σ's exclusion segment
    `kvE2_sepSegForm σ zs` is realized at `y` — every bit-FALSE 1-type is excluded there. -/
theorem kvE2_sepSegForm_eval_of_honest {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (σ : NormalForm sig 1 4) (a w x t : M.carrier)
    (hspec : nf_eval_nf M 1 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (zs : ZoneSpec 4) (y : M.carrier)
    (hy : zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs y) :
    temporal_truth M atomMap y (kvE2_sepSegForm charBase σ zs) := by
  obtain ⟨-, h_zone, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hspec
  simp only [kvE2_sepSegForm]
  rw [formula_conjList_iff]
  intro f hf
  obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
  cases hbit : kvE2_sepBits σ zs χ with
  | true =>
    show temporal_truth M atomMap y Formula.top
    exact temporal_truth_top M atomMap y
  | false =>
    show temporal_truth M atomMap y (charBase χ).neg
    simp only [Formula.neg, temporal_truth]
    intro hch
    have hbt : kvE2_sepBits σ zs χ = true :=
      (h_zone zs χ).mp ⟨y, hy, (hcb χ y).mp hch⟩
    rw [hbit] at hbt
    exact Bool.noConfusion hbt

/-- **LEFT refined-segment honesty at a cut** (Phase 5): the LEFT-region refined-conjunction
    segment `kvE2_sepSegLAt lL i` is realized at any interior `y ∈ (x, w)` whose position relative
    to each left-interior owner's honest anchor matches the cut's structural read (`hbridge`).
    Right-interior owners contribute the uniform `(x, w)` (`kvE_sub2_zXU`) exclusion, discharged
    internally from `w < a`. Generic in `y` and `hbridge`; Phase 6 supplies the bridge from the
    class order. -/
theorem kvE2_sepSegLAt_eval_of_honest {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (lL : List (KvE2SepSlot sig)) (i : Nat) (y : M.carrier) (hxy : x < y) (hyw : y < w)
    (hbridge : ∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zXW3 →
      ((lL.take i).contains (.lX1 σ) = true → kvE2_sepAnchorVal qnf M w x t h σ < y) ∧
      ((lL.take i).contains (.lX1 σ) = false → y < kvE2_sepAnchorVal qnf M w x t h σ)) :
    (kvE2_sepSegLAt charBase qnf lL i).eval_at M atomMap y := by
  have hyt : y < t := hyw.trans hwt
  simp only [kvE2_sepSegLAt, TemporalPred.eval_at]
  rw [formula_conjList_iff]
  intro f hf
  obtain ⟨σ, hσ, rfl⟩ := List.mem_map.mp hf
  have hbσ : qnf.2 σ = true := (List.mem_filter.mp hσ).2
  have hspec := kvE2_sepAnchorVal_spec qnf M w x t h σ hbσ
  simp only [kvE2_sepSegLForSub]
  by_cases hz1 : nf0_zoneSpec σ.1 = kvE2_sep_zXW3
  · rw [if_pos hz1]
    have hbr := hbridge σ hσ hz1
    by_cases hcon : (lL.take i).contains (.lX1 σ) = true
    · rw [if_pos hcon]
      have hay := hbr.1 hcon
      apply kvE2_sepSegForm_eval_of_honest charBase M atomMap σ _ w x t hspec hcb
      refine (kvE2_sepZone4_iff M (kvE2_sepAnchorVal qnf M w x t h σ) w x t y
        (false, true) (true, false) (false, true) (true, false)).mpr ?_
      exact ⟨⟨iff_of_false (lt_asymm hay) (by decide), iff_of_true hay rfl⟩,
        ⟨iff_of_true hyw rfl, iff_of_false (lt_asymm hyw) (by decide)⟩,
        ⟨iff_of_false (lt_asymm hxy) (by decide), iff_of_true hxy rfl⟩,
        ⟨iff_of_true hyt rfl, iff_of_false (lt_asymm hyt) (by decide)⟩⟩
    · rw [if_neg hcon]
      have hya := hbr.2 (Bool.eq_false_iff.mpr hcon)
      apply kvE2_sepSegForm_eval_of_honest charBase M atomMap σ _ w x t hspec hcb
      refine (kvE2_sepZone4_iff M (kvE2_sepAnchorVal qnf M w x t h σ) w x t y
        (true, false) (true, false) (false, true) (true, false)).mpr ?_
      exact ⟨⟨iff_of_true hya rfl, iff_of_false (lt_asymm hya) (by decide)⟩,
        ⟨iff_of_true hyw rfl, iff_of_false (lt_asymm hyw) (by decide)⟩,
        ⟨iff_of_false (lt_asymm hxy) (by decide), iff_of_true hxy rfl⟩,
        ⟨iff_of_true hyt rfl, iff_of_false (lt_asymm hyt) (by decide)⟩⟩
  · by_cases hz2 : nf0_zoneSpec σ.1 = kvE2_sep_zWT3
    · rw [if_neg hz1, if_pos hz2]
      have hbnd := kvE2_sepHonestAnchorBundleR qnf M w x t hxw hwt h σ hσ hz2
      have hya : y < kvE2_sepAnchorVal qnf M w x t h σ := hyw.trans hbnd.1
      apply kvE2_sepSegForm_eval_of_honest charBase M atomMap σ _ w x t hspec hcb
      refine (kvE2_sepZone4_iff M (kvE2_sepAnchorVal qnf M w x t h σ) w x t y
        (true, false) (true, false) (false, true) (true, false)).mpr ?_
      exact ⟨⟨iff_of_true hya rfl, iff_of_false (lt_asymm hya) (by decide)⟩,
        ⟨iff_of_true hyw rfl, iff_of_false (lt_asymm hyw) (by decide)⟩,
        ⟨iff_of_false (lt_asymm hxy) (by decide), iff_of_true hxy rfl⟩,
        ⟨iff_of_true hyt rfl, iff_of_false (lt_asymm hyt) (by decide)⟩⟩
    · rw [if_neg hz1, if_neg hz2]
      exact temporal_truth_top M atomMap y

/-- **RIGHT refined-segment honesty at a cut** (Phase 5, mirror of `kvE2_sepSegLAt_eval_of_honest`):
    the RIGHT-region segment `kvE2_sepSegRAt lR j` is realized at any interior `y ∈ (w, t)` whose
    position relative to each right-interior owner's honest anchor matches the cut's structural
    read (`hbridge`). Left-interior owners contribute the uniform `(w, t)` (`kvE_sub2_zWT`)
    exclusion, discharged internally from `a < w`. -/
theorem kvE2_sepSegRAt_eval_of_honest {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (lR : List (KvE2SepSlot sig)) (j : Nat) (y : M.carrier) (hwy : w < y) (hyt : y < t)
    (hbridge : ∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zWT3 →
      ((lR.take j).contains (.rX1 σ) = true → kvE2_sepAnchorVal qnf M w x t h σ < y) ∧
      ((lR.take j).contains (.rX1 σ) = false → y < kvE2_sepAnchorVal qnf M w x t h σ)) :
    (kvE2_sepSegRAt charBase qnf lR j).eval_at M atomMap y := by
  have hxy : x < y := hxw.trans hwy
  simp only [kvE2_sepSegRAt, TemporalPred.eval_at]
  rw [formula_conjList_iff]
  intro f hf
  obtain ⟨σ, hσ, rfl⟩ := List.mem_map.mp hf
  have hbσ : qnf.2 σ = true := (List.mem_filter.mp hσ).2
  have hspec := kvE2_sepAnchorVal_spec qnf M w x t h σ hbσ
  simp only [kvE2_sepSegRForSub]
  by_cases hz1 : nf0_zoneSpec σ.1 = kvE2_sep_zXW3
  · rw [if_pos hz1]
    have hbnd := kvE2_sepHonestAnchorBundleL qnf M w x t hxw hwt h σ hσ hz1
    have hay : kvE2_sepAnchorVal qnf M w x t h σ < y := hbnd.2.1.trans hwy
    apply kvE2_sepSegForm_eval_of_honest charBase M atomMap σ _ w x t hspec hcb
    refine (kvE2_sepZone4_iff M (kvE2_sepAnchorVal qnf M w x t h σ) w x t y
      (false, true) (false, true) (false, true) (true, false)).mpr ?_
    exact ⟨⟨iff_of_false (lt_asymm hay) (by decide), iff_of_true hay rfl⟩,
      ⟨iff_of_false (lt_asymm hwy) (by decide), iff_of_true hwy rfl⟩,
      ⟨iff_of_false (lt_asymm hxy) (by decide), iff_of_true hxy rfl⟩,
      ⟨iff_of_true hyt rfl, iff_of_false (lt_asymm hyt) (by decide)⟩⟩
  · by_cases hz2 : nf0_zoneSpec σ.1 = kvE2_sep_zWT3
    · rw [if_neg hz1, if_pos hz2]
      have hbr := hbridge σ hσ hz2
      by_cases hcon : (lR.take j).contains (.rX1 σ) = true
      · rw [if_pos hcon]
        have hay := hbr.1 hcon
        apply kvE2_sepSegForm_eval_of_honest charBase M atomMap σ _ w x t hspec hcb
        refine (kvE2_sepZone4_iff M (kvE2_sepAnchorVal qnf M w x t h σ) w x t y
          (false, true) (false, true) (false, true) (true, false)).mpr ?_
        exact ⟨⟨iff_of_false (lt_asymm hay) (by decide), iff_of_true hay rfl⟩,
          ⟨iff_of_false (lt_asymm hwy) (by decide), iff_of_true hwy rfl⟩,
          ⟨iff_of_false (lt_asymm hxy) (by decide), iff_of_true hxy rfl⟩,
          ⟨iff_of_true hyt rfl, iff_of_false (lt_asymm hyt) (by decide)⟩⟩
      · rw [if_neg hcon]
        have hya := hbr.2 (Bool.eq_false_iff.mpr hcon)
        apply kvE2_sepSegForm_eval_of_honest charBase M atomMap σ _ w x t hspec hcb
        refine (kvE2_sepZone4_iff M (kvE2_sepAnchorVal qnf M w x t h σ) w x t y
          (true, false) (false, true) (false, true) (true, false)).mpr ?_
        exact ⟨⟨iff_of_true hya rfl, iff_of_false (lt_asymm hya) (by decide)⟩,
          ⟨iff_of_false (lt_asymm hwy) (by decide), iff_of_true hwy rfl⟩,
          ⟨iff_of_false (lt_asymm hxy) (by decide), iff_of_true hxy rfl⟩,
          ⟨iff_of_true hyt rfl, iff_of_false (lt_asymm hyt) (by decide)⟩⟩
    · rw [if_neg hz1, if_neg hz2]
      exact temporal_truth_top M atomMap y

/-! ### Task 337 (plan 13) Phase 6 — O3(b): gap discharge (the class-order bridge)

The Phase-5 segment family (`kvE2_sepSegLAt_eval_of_honest` / `…RAt…`) takes a per-owner
position bridge as a hypothesis. Phase 6 supplies that bridge from the class value order
(Phase 3): for a point `y` strictly between consecutive grouped-class witnesses, the anchor
slot `.lX1 σ` of a same-region owner sits in the flat prefix of the first `n` classes iff its
honest anchor value is below `y`. Reindexing `gL.flatten.take FC` to `(gL.take n).flatten`
(`kvE2_sep_take_flatten_prefix`) plus prefix/suffix value separation (`kvE2_sep_flatten_sep`)
reduce the bridge to two value-comparison hypotheses (`hprefix`/`hsuffix`) discharged in the
Phase-7 assembly from the gap bounds. LITMUS-clean: all bounds ride the anchor value and `y`,
never an owner-to-owner chain. -/

/-- Generic: the flat prefix of the first `n` sublists equals `flatten.take` at the prefix's
    own flattened length (whole-sublist cut alignment). -/
private theorem kvE2_sep_take_flatten_prefix {α : Type*} (L : List (List α)) (n : Nat) :
    (L.take n).flatten = L.flatten.take ((L.take n).flatten.length) := by
  induction L generalizing n with
  | nil => simp
  | cons a rest ih =>
    cases n with
    | zero => simp
    | succ m =>
      simp only [List.take_succ_cons, List.flatten_cons, List.length_append]
      rw [List.take_append, List.take_of_length_le (Nat.le_add_right _ _),
        Nat.add_sub_cancel_left, ← ih m]

/-- Generic: on a list of sublists whose blocks are strictly `R`-separated across the list
    (`Pairwise` of the cross-block order), every element of the first-`n` prefix relates by `R`
    to every element of the drop-`n` suffix. The value-separation kernel for the bridge. -/
private theorem kvE2_sep_flatten_sep {α : Type*} (R : α → α → Prop) (L : List (List α))
    (hmono : L.Pairwise (fun c₁ c₂ => ∀ u ∈ c₁, ∀ v ∈ c₂, R u v)) (n : Nat) :
    ∀ s ∈ (L.take n).flatten, ∀ s' ∈ (L.drop n).flatten, R s s' := by
  intro s hs s' hs'
  obtain ⟨c₁, hc₁, hsc₁⟩ := List.mem_flatten.mp hs
  obtain ⟨c₂, hc₂, hs'c₂⟩ := List.mem_flatten.mp hs'
  have hpw : (L.take n ++ L.drop n).Pairwise (fun c₁ c₂ => ∀ u ∈ c₁, ∀ v ∈ c₂, R u v) := by
    rw [List.take_append_drop]; exact hmono
  exact (List.pairwise_append.mp hpw).2.2 c₁ hc₁ c₂ hc₂ s hsc₁ s' hs'c₂

/-- **LEFT gap discharge** (Phase 6 / O3(b)): the LEFT grouped segment at grouped cut `n` is
    realized at any interior `y ∈ (x, w)` whose relation to the class values is fixed by the two
    gap hypotheses `hprefix` (first-`n` classes' slot values below `y`) and `hsuffix` (later
    classes' slot values above `y`). Builds the Phase-5 bridge for `kvE2_sepSegLAt_eval_of_honest`
    from those two facts. -/
theorem kvE2_sepSegLAt_gap_eval {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (n : Nat) (y : M.carrier) (hxy : x < y) (hyw : y < w)
    (hprefix : ∀ s ∈ ((kvE2_sepTieGroupedL (kvE2_sepHonestOrder' qnf M w x t h)).take n).flatten,
      kvE2_sepSlotValue qnf M w x t h s < y)
    (hsuffix : ∀ s ∈ ((kvE2_sepTieGroupedL (kvE2_sepHonestOrder' qnf M w x t h)).drop n).flatten,
      y < kvE2_sepSlotValue qnf M w x t h s) :
    (kvE2_sepSegLAt charBase qnf
        (kvE2_sepTieGroupedL (kvE2_sepHonestOrder' qnf M w x t h)).flatten
        (((kvE2_sepTieGroupedL (kvE2_sepHonestOrder' qnf M w x t h)).take n).flatten.length)
      ).eval_at M atomMap y := by
  set wo := kvE2_sepHonestOrder' qnf M w x t h with hwo_def
  set gL := kvE2_sepTieGroupedL wo with hgL_def
  apply kvE2_sepSegLAt_eval_of_honest charBase qnf M atomMap w x t hxw hwt h hcb
    gL.flatten ((gL.take n).flatten.length) y hxy hyw
  intro σ hσ hz
  rw [← kvE2_sep_take_flatten_prefix gL n]
  have hval : kvE2_sepSlotValue qnf M w x t h (.lX1 σ) = kvE2_sepAnchorVal qnf M w x t h σ :=
    kvE2_sepSlotValue_lX1 qnf M w x t h σ
  refine ⟨fun hc => ?_, fun hc => ?_⟩
  · have hmem : (KvE2SepSlot.lX1 σ) ∈ (gL.take n).flatten := List.contains_iff_mem.mp hc
    rw [← hval]; exact hprefix _ hmem
  · have hnmem : (KvE2SepSlot.lX1 σ) ∉ (gL.take n).flatten := by
      intro hm; rw [List.contains_iff_mem.mpr hm] at hc; exact Bool.noConfusion hc
    have hallmem : (KvE2SepSlot.lX1 σ) ∈ gL.flatten := by
      rw [hgL_def, kvE2_sepTieGroupedL_flatten]
      exact kvE2_sepSlotsLOf_mem qnf (kvE2_sepHonestOrder'_mem_orderTypes qnf M w x t h)
        ((kvE2_sepPosI_mem qnf σ).mpr ⟨hσ, Or.inl hz⟩) (kvE2_sep_lX1_mem_slotsLFor hz)
    have hsplit : gL.flatten = (gL.take n).flatten ++ (gL.drop n).flatten := by
      rw [← List.flatten_append, List.take_append_drop]
    rw [hsplit, List.mem_append] at hallmem
    rw [← hval]; exact hsuffix _ (hallmem.resolve_left hnmem)

/-- **RIGHT gap discharge** (Phase 6 / O3(b), mirror of `kvE2_sepSegLAt_gap_eval`): the RIGHT
    grouped segment at grouped cut `n` is realized at any interior `y ∈ (w, t)` fixed by the
    two RIGHT gap hypotheses. -/
theorem kvE2_sepSegRAt_gap_eval {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (n : Nat) (y : M.carrier) (hwy : w < y) (hyt : y < t)
    (hprefix : ∀ s ∈ ((kvE2_sepTieGroupedR (kvE2_sepHonestOrder' qnf M w x t h)).take n).flatten,
      kvE2_sepSlotValue qnf M w x t h s < y)
    (hsuffix : ∀ s ∈ ((kvE2_sepTieGroupedR (kvE2_sepHonestOrder' qnf M w x t h)).drop n).flatten,
      y < kvE2_sepSlotValue qnf M w x t h s) :
    (kvE2_sepSegRAt charBase qnf
        (kvE2_sepTieGroupedR (kvE2_sepHonestOrder' qnf M w x t h)).flatten
        (((kvE2_sepTieGroupedR (kvE2_sepHonestOrder' qnf M w x t h)).take n).flatten.length)
      ).eval_at M atomMap y := by
  set wo := kvE2_sepHonestOrder' qnf M w x t h with hwo_def
  set gR := kvE2_sepTieGroupedR wo with hgR_def
  apply kvE2_sepSegRAt_eval_of_honest charBase qnf M atomMap w x t hxw hwt h hcb
    gR.flatten ((gR.take n).flatten.length) y hwy hyt
  intro σ hσ hz
  rw [← kvE2_sep_take_flatten_prefix gR n]
  have hval : kvE2_sepSlotValue qnf M w x t h (.rX1 σ) = kvE2_sepAnchorVal qnf M w x t h σ :=
    kvE2_sepSlotValue_rX1 qnf M w x t h σ
  refine ⟨fun hc => ?_, fun hc => ?_⟩
  · have hmem : (KvE2SepSlot.rX1 σ) ∈ (gR.take n).flatten := List.contains_iff_mem.mp hc
    rw [← hval]; exact hprefix _ hmem
  · have hnmem : (KvE2SepSlot.rX1 σ) ∉ (gR.take n).flatten := by
      intro hm; rw [List.contains_iff_mem.mpr hm] at hc; exact Bool.noConfusion hc
    have hallmem : (KvE2SepSlot.rX1 σ) ∈ gR.flatten := by
      rw [hgR_def, kvE2_sepTieGroupedR_flatten]
      exact kvE2_sepSlotsROf_mem qnf (kvE2_sepHonestOrder'_mem_orderTypes qnf M w x t h)
        ((kvE2_sepPosI_mem qnf σ).mpr ⟨hσ, Or.inr hz⟩) (kvE2_sep_rX1_mem_slotsRFor hz)
    have hsplit : gR.flatten = (gR.take n).flatten ++ (gR.drop n).flatten := by
      rw [← List.flatten_append, List.take_append_drop]
    rw [hsplit, List.mem_append] at hallmem
    rw [← hval]; exact hsuffix _ (hallmem.resolve_left hnmem)

/-! ### Task 337 (plan 13) Phase 7 — O4: assembly (per-class witness list + the two public theorems)

The generic list helpers below build the per-class honest value list `usL`/`usR`
(one value per tie class, via `attach`+`head`), giving length, getElem, membership, and
prefix/suffix value-separation from the class strict order. They isolate the `attach`/`getElem`
mechanics from the model content so the bracket assembly reads at the class level. -/

/-- Generic: `gL[k] ∈ gL.drop k`. -/
private theorem kvE2_sep_getElem_mem_drop {α : Type*} (gL : List (List α)) (k : Nat)
    (hk : k < gL.length) : gL[k]'hk ∈ gL.drop k := by
  rw [List.drop_eq_getElem_cons hk]; exact List.mem_cons_self

/-- Generic: length of the per-class value list built by `attach`+`head`. -/
private theorem kvE2_sep_usOf_length {α β : Type*} (gL : List (List α)) (hne : ∀ c ∈ gL, c ≠ [])
    (Vf : α → β) :
    (gL.attach.map (fun p => Vf (p.1.head (hne p.1 p.2)))).length = gL.length := by
  rw [List.length_map, List.length_attach]

/-- Generic: the `k`-th per-class value is `Vf` of the `k`-th class's head. -/
private theorem kvE2_sep_usOf_getElem {α β : Type*} (gL : List (List α)) (hne : ∀ c ∈ gL, c ≠ [])
    (Vf : α → β) (k : Nat)
    (hk : k < (gL.attach.map (fun p => Vf (p.1.head (hne p.1 p.2)))).length) :
    (gL.attach.map (fun p => Vf (p.1.head (hne p.1 p.2))))[k]'hk
      = Vf ((gL[k]'(by simpa using hk)).head (hne _ (List.getElem_mem _))) := by
  rw [List.getElem_map, List.getElem_attach]

/-- Generic: every value of the per-class list is `Vf` of a member of some class. -/
private theorem kvE2_sep_usOf_mem {α β : Type*} (gL : List (List α)) (hne : ∀ c ∈ gL, c ≠ [])
    (Vf : α → β) {b : β} (hb : b ∈ gL.attach.map (fun p => Vf (p.1.head (hne p.1 p.2)))) :
    ∃ c ∈ gL, ∃ s ∈ c, b = Vf s := by
  obtain ⟨p, _, hpb⟩ := List.mem_map.mp hb
  exact ⟨p.1, p.2, p.1.head (hne p.1 p.2), List.head_mem _, hpb.symm⟩

/-- Generic prefix value bound: on a class-strictly-`<`-ordered list, all slots of the first `n`
    classes have `Vf` below `y`, given the `(n-1)`-th (boundary) class does. -/
private theorem kvE2_sep_take_flatten_lt {α β : Type*} [Preorder β] (Vf : α → β) (gL : List (List α))
    (hmono : gL.Pairwise (fun c₁ c₂ => ∀ u ∈ c₁, ∀ v ∈ c₂, Vf u < Vf v))
    (hne : ∀ c ∈ gL, c ≠ [])
    (n : Nat) (hn1 : 1 ≤ n) (hn : n ≤ gL.length) (y : β)
    (hbnd : ∀ s ∈ gL[n-1]'(by omega), Vf s < y) :
    ∀ s ∈ (gL.take n).flatten, Vf s < y := by
  intro s hs
  have hsplit : (gL.take n).flatten = (gL.take (n-1)).flatten ++ gL[n-1]'(by omega) := by
    rw [show gL.take n = gL.take (n-1) ++ [gL[n-1]'(by omega)] from by
      conv_lhs => rw [show n = (n-1)+1 by omega]
      rw [List.take_succ]; congr 1; rw [List.getElem?_eq_getElem (by omega)]; rfl]
    rw [List.flatten_append]; simp
  rw [hsplit, List.mem_append] at hs
  rcases hs with hs | hs
  · have hbmem : gL[n-1]'(by omega) ∈ gL.drop (n-1) := kvE2_sep_getElem_mem_drop gL (n-1) (by omega)
    have hs0 : (gL[n-1]'(by omega)).head (hne _ (List.getElem_mem _)) ∈ gL[n-1]'(by omega) :=
      List.head_mem _
    have hlt := kvE2_sep_flatten_sep (fun a b => Vf a < Vf b) gL hmono (n-1) s hs _
      (List.mem_flatten.mpr ⟨_, hbmem, hs0⟩)
    exact lt_trans hlt (hbnd _ hs0)
  · exact hbnd s hs

/-- Generic suffix value bound: on a class-strictly-`<`-ordered list, all slots of the classes from
    `n` onward have `Vf` above `y`, given the `n`-th (boundary) class does. -/
private theorem kvE2_sep_drop_flatten_gt {α β : Type*} [Preorder β] (Vf : α → β) (gL : List (List α))
    (hmono : gL.Pairwise (fun c₁ c₂ => ∀ u ∈ c₁, ∀ v ∈ c₂, Vf u < Vf v))
    (hne : ∀ c ∈ gL, c ≠ [])
    (n : Nat) (hn : n < gL.length) (y : β)
    (hbnd : ∀ s ∈ gL[n]'hn, y < Vf s) :
    ∀ s ∈ (gL.drop n).flatten, y < Vf s := by
  intro s hs
  have hsplit : gL.drop n = gL[n]'hn :: gL.drop (n+1) := by rw [List.drop_eq_getElem_cons hn]
  rw [hsplit, List.flatten_cons, List.mem_append] at hs
  rcases hs with hs | hs
  · exact hbnd s hs
  · have hbmem : gL[n]'hn ∈ gL.take (n+1) := by
      have h1 : (gL.take (n+1))[n]'(by rw [List.length_take]; omega) = gL[n]'hn := by
        rw [List.getElem_take]
      rw [← h1]; exact List.getElem_mem _
    have hs0 : (gL[n]'hn).head (hne _ (List.getElem_mem _)) ∈ gL[n]'hn := List.head_mem _
    have hlt := kvE2_sep_flatten_sep (fun a b => Vf a < Vf b) gL hmono (n+1) _
      (List.mem_flatten.mpr ⟨_, hbmem, hs0⟩) s hs
    exact lt_trans (hbnd _ hs0) hlt

/-- **Grouped bracket realization under honesty** (Phase 7 / O4): the meet-folded grouped bracket
    of the primed honest order is realized on `(x, t)`. Builds the per-class honest witness lists
    `usL`/`usR` (one value per tie class), discharges the strict order (O1), range, point types
    (O2), and per-gap segments (O3) into the private N-slot engine `kvE2_sepBracketN_construct`. -/
theorem kvE2_sepBracket_holds_of_honest {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      temporal_truth M atomMap u (charK χ) ↔ nf_eval_nf M 1 1 (fun _ => u) χ) :
    (kvE2_sepBracketN
        ((kvE2_sepTieGroupedL (kvE2_sepHonestOrder' qnf M w x t h)).map
          (kvE2_sepClassType charBase charK))
        (kvE2_sepPtW charBase charK qnf)
        ((kvE2_sepTieGroupedR (kvE2_sepHonestOrder' qnf M w x t h)).map
          (kvE2_sepClassType charBase charK))
        (kvE2_sepSegsG charBase qnf
          (kvE2_sepTieGroupedL (kvE2_sepHonestOrder' qnf M w x t h))
          (kvE2_sepTieGroupedR (kvE2_sepHonestOrder' qnf M w x t h)))
      ).holds M atomMap x t := by
  set wo := kvE2_sepHonestOrder' qnf M w x t h with hwo_def
  set gL := kvE2_sepTieGroupedL wo with hgL_def
  set gR := kvE2_sepTieGroupedR wo with hgR_def
  set Vf := kvE2_sepSlotValue qnf M w x t h with hVf_def
  have hneL : ∀ c ∈ gL, c ≠ [] := kvE2_sepTieGroupedL_ne_nil wo
  have hneR : ∀ c ∈ gR, c ≠ [] := kvE2_sepTieGroupedR_ne_nil wo
  have hmonoL : gL.Pairwise (fun c₁ c₂ => ∀ u ∈ c₁, ∀ v ∈ c₂, Vf u < Vf v) :=
    kvE2_sepTieGroupedL_strictMono qnf M w x t h
  have hmonoR : gR.Pairwise (fun c₁ c₂ => ∀ u ∈ c₁, ∀ v ∈ c₂, Vf u < Vf v) :=
    kvE2_sepTieGroupedR_strictMono qnf M w x t h
  have hbndL : ∀ s ∈ gL.flatten, x < Vf s ∧ Vf s < w := fun s hs =>
    kvE2_sepSlotsLOf_honestOrder'_value_bound qnf M w x t hxw hwt h
      (by rw [← kvE2_sepTieGroupedL_flatten wo]; exact hs)
  have hbndR : ∀ s ∈ gR.flatten, w < Vf s ∧ Vf s < t := fun s hs =>
    kvE2_sepSlotsROf_honestOrder'_value_bound qnf M w x t hxw hwt h
      (by rw [← kvE2_sepTieGroupedR_flatten wo]; exact hs)
  have hUL_len : (gL.attach.map (fun p => Vf (p.1.head (hneL p.1 p.2)))).length = gL.length :=
    kvE2_sep_usOf_length gL hneL Vf
  have hUR_len : (gR.attach.map (fun p => Vf (p.1.head (hneR p.1 p.2)))).length = gR.length :=
    kvE2_sep_usOf_length gR hneR Vf
  have huslen : (gL.attach.map (fun p => Vf (p.1.head (hneL p.1 p.2))) ++ w ::
      gR.attach.map (fun p => Vf (p.1.head (hneR p.1 p.2)))).length = gL.length + gR.length + 1 := by
    rw [List.length_append, List.length_cons, hUL_len, hUR_len]; omega
  -- LEFT segment discharger from boundary class values
  have segL : ∀ (n : Nat) (hn : n ≤ gL.length) (yv : M.carrier) (hxy : x < yv) (hyw : yv < w),
      (∀ (_ : 0 < n), ∀ s ∈ gL[n-1]'(by omega), Vf s < yv) →
      (∀ (hlt : n < gL.length), ∀ s ∈ gL[n]'hlt, yv < Vf s) →
      (kvE2_sepSegsG charBase qnf gL gR n).eval_at M atomMap yv := by
    intro n hn yv hxy hyw hpre hsuf
    rw [kvE2_sepSegsG, if_pos hn]
    apply kvE2_sepSegLAt_gap_eval charBase charK qnf M atomMap w x t hxw hwt h hcb n yv hxy hyw
    · rcases Nat.eq_zero_or_pos n with h0 | hpos
      · subst h0; intro s hs; simp only [List.take_zero, List.flatten_nil, List.not_mem_nil] at hs
      · exact kvE2_sep_take_flatten_lt Vf gL hmonoL hneL n hpos hn yv (hpre hpos)
    · rcases Nat.lt_or_ge n gL.length with hlt | hge
      · exact kvE2_sep_drop_flatten_gt Vf gL hmonoL hneL n hlt yv (hsuf hlt)
      · have hEq : n = gL.length := le_antisymm hn hge
        subst hEq; intro s hs
        rw [List.drop_length, List.flatten_nil] at hs; exact absurd hs List.not_mem_nil
  -- RIGHT segment discharger from boundary class values
  have segR : ∀ (n : Nat) (hn : n ≤ gR.length) (yv : M.carrier) (hwy : w < yv) (hyt : yv < t),
      (∀ (_ : 0 < n), ∀ s ∈ gR[n-1]'(by omega), Vf s < yv) →
      (∀ (hlt : n < gR.length), ∀ s ∈ gR[n]'hlt, yv < Vf s) →
      (kvE2_sepSegsG charBase qnf gL gR (gL.length + 1 + n)).eval_at M atomMap yv := by
    intro n hn yv hwy hyt hpre hsuf
    rw [kvE2_sepSegsG, if_neg (by omega), show gL.length + 1 + n - gL.length - 1 = n by omega]
    apply kvE2_sepSegRAt_gap_eval charBase charK qnf M atomMap w x t hxw hwt h hcb n yv hwy hyt
    · rcases Nat.eq_zero_or_pos n with h0 | hpos
      · subst h0; intro s hs; simp only [List.take_zero, List.flatten_nil, List.not_mem_nil] at hs
      · exact kvE2_sep_take_flatten_lt Vf gR hmonoR hneR n hpos hn yv (hpre hpos)
    · rcases Nat.lt_or_ge n gR.length with hlt | hge
      · exact kvE2_sep_drop_flatten_gt Vf gR hmonoR hneR n hlt yv (hsuf hlt)
      · have hEq : n = gR.length := le_antisymm hn hge
        subst hEq; intro s hs
        rw [List.drop_length, List.flatten_nil] at hs; exact absurd hs List.not_mem_nil
  refine kvE2_sepBracketN_construct M atomMap _ _ _ _ x w t
    (gL.attach.map (fun p => Vf (p.1.head (hneL p.1 p.2))))
    (gR.attach.map (fun p => Vf (p.1.head (hneR p.1 p.2))))
    (by rw [hUL_len, List.length_map]) (by rw [hUR_len, List.length_map])
    ?hsort ?hrange ?hptL ?hptW ?hptR ?hseg0 ?hsegmid ?hseglast
  case hsort =>
    refine List.pairwise_append.mpr ⟨?_, ?_, ?_⟩
    · rw [List.pairwise_iff_getElem]
      intro a b ha hb hab
      have haL : a < gL.length := by rw [hUL_len] at ha; exact ha
      have hbL : b < gL.length := by rw [hUL_len] at hb; exact hb
      rw [kvE2_sep_usOf_getElem gL hneL Vf a ha, kvE2_sep_usOf_getElem gL hneL Vf b hb]
      exact List.pairwise_iff_getElem.mp hmonoL a b haL hbL hab _ (List.head_mem _) _ (List.head_mem _)
    · rw [List.pairwise_cons]
      refine ⟨fun b hb => ?_, ?_⟩
      · obtain ⟨c, hc, s, hs, rfl⟩ := kvE2_sep_usOf_mem gR hneR Vf hb
        exact (hbndR s (List.mem_flatten.mpr ⟨c, hc, hs⟩)).1
      · rw [List.pairwise_iff_getElem]
        intro a b ha hb hab
        have haR : a < gR.length := by rw [hUR_len] at ha; exact ha
        have hbR : b < gR.length := by rw [hUR_len] at hb; exact hb
        rw [kvE2_sep_usOf_getElem gR hneR Vf a ha, kvE2_sep_usOf_getElem gR hneR Vf b hb]
        exact List.pairwise_iff_getElem.mp hmonoR a b haR hbR hab _ (List.head_mem _) _
          (List.head_mem _)
    · intro a ha b hb
      obtain ⟨c, hc, s, hs, rfl⟩ := kvE2_sep_usOf_mem gL hneL Vf ha
      have haw : Vf s < w := (hbndL s (List.mem_flatten.mpr ⟨c, hc, hs⟩)).2
      rw [List.mem_cons] at hb
      rcases hb with rfl | hb
      · exact haw
      · obtain ⟨c', hc', s', hs', rfl⟩ := kvE2_sep_usOf_mem gR hneR Vf hb
        exact haw.trans (hbndR s' (List.mem_flatten.mpr ⟨c', hc', hs'⟩)).1
  case hrange =>
    intro u hu
    rw [List.mem_append, List.mem_cons] at hu
    rcases hu with hu | (rfl | hu)
    · obtain ⟨c, hc, s, hs, rfl⟩ := kvE2_sep_usOf_mem gL hneL Vf hu
      have hb := hbndL s (List.mem_flatten.mpr ⟨c, hc, hs⟩)
      exact ⟨hb.1, hb.2.trans hwt⟩
    · exact ⟨hxw, hwt⟩
    · obtain ⟨c, hc, s, hs, rfl⟩ := kvE2_sep_usOf_mem gR hneR Vf hu
      have hb := hbndR s (List.mem_flatten.mpr ⟨c, hc, hs⟩)
      exact ⟨hxw.trans hb.1, hb.2⟩
  case hptL =>
    intro i hi
    have hiL : i < gL.length := by rw [List.length_map] at hi; exact hi
    rw [List.getElem_map, List.getElem_map, List.getElem_attach]
    exact kvE2_sepTieGroupedL_classType_eval charBase charK qnf M atomMap w x t hxw hwt h hcb hck
      (List.getElem_mem hiL) (List.head_mem _)
  case hptW =>
    exact kvE2_sepPtW_eval_of_honest charBase charK qnf M atomMap w x t hxw hwt h hcb hck
  case hptR =>
    intro j hj
    have hjR : j < gR.length := by rw [List.length_map] at hj; exact hj
    rw [List.getElem_map, List.getElem_map, List.getElem_attach]
    exact kvE2_sepTieGroupedR_classType_eval charBase charK qnf M atomMap w x t hxw hwt h hcb hck
      (List.getElem_mem hjR) (List.head_mem _)
  case hseg0 =>
    intro y hxy hy0
    apply segL 0 (Nat.zero_le _) y hxy ?_ ?_ ?_
    · rcases Nat.eq_zero_or_pos gL.length with h0 | hpos
      · rw [List.getElem_append_right (by rw [hUL_len]; omega)] at hy0
        simp only [hUL_len] at hy0
        rw [getElem_congr_idx (show (0 : Nat) - gL.length = 0 by omega),
          List.getElem_cons_zero] at hy0
        exact hy0
      · rw [List.getElem_append_left (by rw [hUL_len]; exact hpos), List.getElem_map,
          List.getElem_attach] at hy0
        exact lt_trans hy0
          (hbndL _ (List.mem_flatten.mpr ⟨_, List.getElem_mem hpos, List.head_mem _⟩)).2
    · intro hcontra; exact absurd hcontra (lt_irrefl 0)
    · intro hpos s hs
      rw [List.getElem_append_left (by rw [hUL_len]; exact hpos), List.getElem_map,
        List.getElem_attach] at hy0
      simp only [hVf_def]
      rw [kvE2_sepTieGroupedL_value_const qnf M w x t h (List.getElem_mem hpos) hs
        (List.head_mem _)]
      exact hy0
  case hsegmid =>
    intro i hi y hlo hhi
    rw [huslen] at hi
    rcases Nat.lt_or_ge i gL.length with hiL | hiG
    · -- LEFT gap
      rw [List.getElem_append_left (by rw [hUL_len]; exact hiL), List.getElem_map,
        List.getElem_attach] at hlo
      have hxlt : x < y := lt_trans
        (hbndL _ (List.mem_flatten.mpr ⟨_, List.getElem_mem hiL, List.head_mem _⟩)).1 hlo
      apply segL (i + 1) (by omega) y hxlt ?_ ?_ ?_
      · rcases Nat.lt_or_ge (i + 1) gL.length with hi1 | hi1
        · rw [List.getElem_append_left (by rw [hUL_len]; exact hi1), List.getElem_map,
            List.getElem_attach] at hhi
          exact lt_trans hhi
            (hbndL _ (List.mem_flatten.mpr ⟨_, List.getElem_mem hi1, List.head_mem _⟩)).2
        · rw [List.getElem_append_right (by rw [hUL_len]; omega)] at hhi
          simp only [hUL_len] at hhi
          rw [getElem_congr_idx (show i + 1 - gL.length = 0 by omega),
            List.getElem_cons_zero] at hhi
          exact hhi
      · intro _ s hs
        simp only [hVf_def]
        rw [kvE2_sepTieGroupedL_value_const qnf M w x t h
          (List.getElem_mem (show i < gL.length by omega)) hs (List.head_mem _)]
        exact hlo
      · intro hi1 s hs
        rw [List.getElem_append_left (by rw [hUL_len]; exact hi1), List.getElem_map,
          List.getElem_attach] at hhi
        simp only [hVf_def]
        rw [kvE2_sepTieGroupedL_value_const qnf M w x t h (List.getElem_mem hi1) hs
          (List.head_mem _)]
        exact hhi
    · -- RIGHT gap
      rw [show i + 1 = gL.length + 1 + (i - gL.length) by omega]
      rcases lt_or_eq_of_le hiG with hig | hie
      · -- i > gL.length
        apply segR (i - gL.length) (by omega) y ?_ ?_ ?_ ?_
        · rw [List.getElem_append_right (by rw [hUL_len]; omega)] at hlo
          simp only [hUL_len] at hlo
          rw [getElem_congr_idx (show i - gL.length = (i - gL.length - 1) + 1 by omega),
            List.getElem_cons_succ, List.getElem_map, List.getElem_attach] at hlo
          exact lt_trans
            (hbndR _ (List.mem_flatten.mpr ⟨_, List.getElem_mem
              (show i - gL.length - 1 < gR.length by omega), List.head_mem _⟩)).1 hlo
        · rw [List.getElem_append_right (by rw [hUL_len]; omega)] at hhi
          simp only [hUL_len] at hhi
          rw [getElem_congr_idx (show i + 1 - gL.length = (i - gL.length) + 1 by omega),
            List.getElem_cons_succ, List.getElem_map, List.getElem_attach] at hhi
          exact lt_trans hhi
            (hbndR _ (List.mem_flatten.mpr ⟨_, List.getElem_mem
              (show i - gL.length < gR.length by omega), List.head_mem _⟩)).2
        · intro _ s hs
          rw [List.getElem_append_right (by rw [hUL_len]; omega)] at hlo
          simp only [hUL_len] at hlo
          rw [getElem_congr_idx (show i - gL.length = (i - gL.length - 1) + 1 by omega),
            List.getElem_cons_succ, List.getElem_map, List.getElem_attach] at hlo
          simp only [hVf_def]
          rw [kvE2_sepTieGroupedR_value_const qnf M w x t h
            (List.getElem_mem (show i - gL.length - 1 < gR.length by omega)) hs (List.head_mem _)]
          exact hlo
        · intro hlt s hs
          rw [List.getElem_append_right (by rw [hUL_len]; omega)] at hhi
          simp only [hUL_len] at hhi
          rw [getElem_congr_idx (show i + 1 - gL.length = (i - gL.length) + 1 by omega),
            List.getElem_cons_succ, List.getElem_map, List.getElem_attach] at hhi
          simp only [hVf_def]
          rw [kvE2_sepTieGroupedR_value_const qnf M w x t h (List.getElem_mem hlt) hs
            (List.head_mem _)]
          exact hhi
      · -- i = gL.length (pivot on the left of the gap)
        rw [show i - gL.length = 0 by omega]
        apply segR 0 (Nat.zero_le _) y ?_ ?_ ?_ ?_
        · rw [List.getElem_append_right (by rw [hUL_len]; omega)] at hlo
          simp only [hUL_len] at hlo
          rw [getElem_congr_idx (show i - gL.length = 0 by omega), List.getElem_cons_zero] at hlo
          exact hlo
        · rw [List.getElem_append_right (by rw [hUL_len]; omega)] at hhi
          simp only [hUL_len] at hhi
          rw [getElem_congr_idx (show i + 1 - gL.length = 0 + 1 by omega),
            List.getElem_cons_succ, List.getElem_map, List.getElem_attach] at hhi
          exact lt_trans hhi
            (hbndR _ (List.mem_flatten.mpr ⟨_, List.getElem_mem
              (show 0 < gR.length by omega), List.head_mem _⟩)).2
        · intro hcontra; exact absurd hcontra (lt_irrefl 0)
        · intro hgRpos s hs
          rw [List.getElem_append_right (by rw [hUL_len]; omega)] at hhi
          simp only [hUL_len] at hhi
          rw [getElem_congr_idx (show i + 1 - gL.length = 0 + 1 by omega),
            List.getElem_cons_succ, List.getElem_map, List.getElem_attach] at hhi
          simp only [hVf_def]
          rw [kvE2_sepTieGroupedR_value_const qnf M w x t h (List.getElem_mem hgRpos) hs
            (List.head_mem _)]
          exact hhi
  case hseglast =>
    intro y hlast hyt
    rw [huslen]
    simp only [huslen, Nat.add_sub_cancel] at hlast
    rw [show gL.length + gR.length + 1 = gL.length + 1 + gR.length by omega]
    rcases Nat.eq_zero_or_pos gR.length with h0 | hpos
    · -- gR empty: the last witness is the pivot `w`
      rw [List.getElem_append_right (by rw [hUL_len]; omega)] at hlast
      simp only [hUL_len] at hlast
      rw [getElem_congr_idx (show gL.length + gR.length - gL.length = 0 by omega),
        List.getElem_cons_zero] at hlast
      apply segR gR.length (le_refl _) y hlast hyt ?_ ?_
      · intro hcontra; exact absurd (h0 ▸ hcontra) (lt_irrefl 0)
      · intro hlt; exact absurd hlt (lt_irrefl _)
    · -- gR nonempty: last witness is the last right class value
      rw [List.getElem_append_right (by rw [hUL_len]; omega)] at hlast
      simp only [hUL_len] at hlast
      rw [getElem_congr_idx (show gL.length + gR.length - gL.length = (gR.length - 1) + 1 by omega),
        List.getElem_cons_succ, List.getElem_map, List.getElem_attach] at hlast
      apply segR gR.length (le_refl _) y ?_ hyt ?_ ?_
      · exact lt_trans
          (hbndR _ (List.mem_flatten.mpr ⟨_, List.getElem_mem
            (show gR.length - 1 < gR.length by omega), List.head_mem _⟩)).1 hlast
      · intro _ s hs
        simp only [hVf_def]
        rw [kvE2_sepTieGroupedR_value_const qnf M w x t h
          (List.getElem_mem (show gR.length - 1 < gR.length by omega)) hs (List.head_mem _)]
        exact hlast
      · intro hlt; exact absurd hlt (lt_irrefl _)

/-- **The §2.1 target: grouped multi-owner disjunct `.holds` builder** (task 337 deliverable):
    under an honest evaluation of `qnf` at `[w, x, t]`, the meet-folded grouped joint disjunct of
    the tie-reporting primed order `kvE2_sepHonestOrder'` is realized on `(x, t)`. Assembles the
    two endpoints (Phase-8 pack) and the grouped bracket (`kvE2_sepBracket_holds_of_honest`) into
    the `VecEA2.holds` triple. Consumes the PRIMED order at the target site (tie-admitting). -/
theorem kvE2_sepDisjunct'_holds_of_honest {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      temporal_truth M atomMap u (charK χ) ↔ nf_eval_nf M 1 1 (fun _ => u) χ) :
    (kvE2_sepDisjunct' charBase charK qnf
        (kvE2_sepTieGroupedL (kvE2_sepHonestOrder' qnf M w x t h))
        (kvE2_sepTieGroupedR (kvE2_sepHonestOrder' qnf M w x t h))).2.holds M atomMap x t := by
  refine ⟨?_, ?_, ?_⟩
  · exact kvE2_sepEpL_eval_of_honest charBase charK qnf M atomMap w x t hxw hwt h hcb hck
  · exact kvE2_sepEpR_eval_of_honest charBase charK qnf M atomMap w x t hxw hwt h hcb hck
  · exact kvE2_sepBracket_holds_of_honest charBase charK qnf M atomMap w x t hxw hwt h hcb hck

/-- **Body corollary** (task 337 deliverable; consumed by task 335): the joint-disjunct body
    formula `kvE2_sepBody` is realized on `(x, t)` under honesty, by feeding the §2.1 builder into
    the task-342 completeness statement `kvE2_sepBody_complete_holds'` (which consumes the PRIMED
    tie-grouped disjunct). -/
theorem kvE2_sepBody_holds_of_honest {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (hg : kvE2_sepGate qnf)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      temporal_truth M atomMap u (charK χ) ↔ nf_eval_nf M 1 1 (fun _ => u) χ) :
    (kvE2_sepBody charBase charK qnf).holds M atomMap x t :=
  kvE2_sepBody_complete_holds' charBase charK qnf hg M atomMap w x t hxw hwt h
    (kvE2_sepDisjunct'_holds_of_honest charBase charK qnf M atomMap w x t hxw hwt h hcb hck)

/-! ## Phase 3 (task 333) — Per-σ kit application: bundles → sound kit → owner `nf_eval`

Thread the per-σ bundles produced by the hypothesis-free `kvE2_sepBody_extract` (Phase 2)
through the `_parts` reducers into the task-326 closer `kvE_subBracket2V_sound_of_parts`
(`SubBracket2V.lean:1290`, consume-only) to obtain each positive owner's `nf_eval`. This is a
kit APPLICATION, not a bit-proof: every `σ.2 (nf0_assemble … χ σ.1) = true` occurrence below
is the *antecedent* of a per-owner `bit ⟹ witness` implication carried by that owner's OWN
enumeration `σ.2` — self-owned, never a cross-σ goal (plan v4 Postmortem Constraints; the
deleted plan-02 R3 stays deleted). `hgate` is the explicit outer-gate hypothesis threaded
verbatim (the Amendment F3 pattern of `kvE_subBracket2V_sound_of_outer`,
`SubBracket2V.lean:1481`) — never assumed, never discharged vacuously here; its carrier-side
derivable pieces live in the Phase 9 (O4) section above and its assembly is downstream
(Phase 4 / task 335). Rabinovich 2014: Notation 5.2 bracket bundles (pp.7-8), Cor 5.4
bounded interior placement (p.9). -/

/-- **LEFT-interior kit application** (Phase 3): a realized left-class bundle at the shared
    witness, under `w < t`, yields the owner's depth-1 `nf_eval` at env `[x1, w, x, t]` by
    feeding the EXACT `kvE_subBracket2V_sound_of_parts` input 5-tuple produced by
    `kvE2_sepBundleL_parts` into the closer, `hgate` threaded verbatim (Amendment F3 — the
    `kvE_subBracket2V_sound_of_outer` composition pattern, `SubBracket2V.lean:1514-1517`).
    Instantiated at the standard `charBase = nf_depth0_char_formula atomMap h_surj`, under
    which the bundle's below-anchor witnesses unify with the closer's expected shapes with no
    coercion. Bounds ride the bracket's own ordering (FM-x1t; never a fresh-witness/slot
    relative-position formula literal — LITMUS). -/
theorem kvE2_sepBundleL_sound {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier) (hwt : w < t)
    (h : kvE2_sepBundleL (nf_depth0_char_formula atomMap h_surj) charK σ M atomMap w x)
    (hgate : ∀ a : M.carrier, x < a → a < t →
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap a →
      a < w ∧ w < t ∧
      nf_eval_nf M 0 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1 ∧
      (∀ τ : NormalForm sig 0 5, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false) ∧
      (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1),
        (∃ v : M.carrier,
          zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ) →
        σ.2 (nf0_assemble zs χ σ.1) = true) ∧
      (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1), zs ≠ kvE_sub2_zXU →
        σ.2 (nf0_assemble zs χ σ.1) = true →
        ∃ v : M.carrier,
          zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ)) :
    ∃ x1 : M.carrier,
      nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  obtain ⟨x1, hxx1, hx1t, hanchor, hbelow⟩ :=
    kvE2_sepBundleL_parts (nf_depth0_char_formula atomMap h_surj) charK σ M atomMap hwt h
  exact kvE_subBracket2V_sound_of_parts atomMap h_surj charK σ M w x t x1 hxx1 hx1t hanchor
    hbelow hgate

/-- **RIGHT-interior kit application** (Phase 3 — the plan-v4 MEDIUM-risk residual,
    discharged by the anticipated kit-application lemma). The landed closer
    `kvE_subBracket2V_sound_of_parts` (`SubBracket2V.lean:1290`) does NOT serve this class
    directly — three signature facts, each read off HEAD source:
    (a) its `hgate` conclusion opens with `a < w` (`SubBracket2V.lean:1305`), but
    `kvE2_sepBundleR` supplies the anchor with `w < x1`, so a truthful gate can never be fed
    the right bundle's anchor;
    (b) `kvE2_sepBundleR_parts` (SW above) deliberately drops the below-clause — no `hbelow`
    in the closer's `kvE_sub2_zXU` shape exists for this class (for a RIGHT-interior σ that
    pattern reads `x < v < w`, the zone-constant header above);
    (c) the bundle's witnesses live in the right-interior middle region `kvE2_sep_zWX1`
    (`w < v < x1`), a zone the left closer's gate-backward clause does not exempt.
    This lemma is the geometry-correct mirror, proved from scratch against the same engine
    (`nf_eval_depth1_fold_iff`, `CarrierKv.lean:466`): the gate's backward clause exempts
    `kvE2_sep_zWX1` (instead of `kvE_sub2_zXU`), whose witnesses the bundle supplies. The
    left closer's `a < w ∧ w < t` head conjuncts are NOT mirrored: in the right geometry the
    corresponding order facts (`w < a`, `a < t`) are already the gate's own antecedents, and
    `x < w` is this lemma's hypothesis. The bit `σ.2 (nf0_assemble kvE2_sep_zWX1 χ σ.1)` is
    consumed as the antecedent of the bundle's own `bit ⟹ witness` implication — self-owned,
    never a goal. NO filter weakened; `hgate` an explicit threaded hypothesis (Amendment F3),
    never assumed. Bounds ride the model order (`x < w < u < x1 < t`), never a formula
    literal (LITMUS). Rabinovich 2014: Notation 5.2 mirrored slot group (pp.7-8), Cor 5.4
    bounded interior placement (p.9). -/
theorem kvE2_sepBundleR_sound {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier) (hxw : x < w)
    (h : kvE2_sepBundleR (nf_depth0_char_formula atomMap h_surj) charK σ M atomMap w t)
    (hgate : ∀ a : M.carrier, w < a → a < t →
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap a →
      nf_eval_nf M 0 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1 ∧
      (∀ τ : NormalForm sig 0 5, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false) ∧
      (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1),
        (∃ v : M.carrier,
          zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ) →
        σ.2 (nf0_assemble zs χ σ.1) = true) ∧
      (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1), zs ≠ kvE2_sep_zWX1 →
        σ.2 (nf0_assemble zs χ σ.1) = true →
        ∃ v : M.carrier,
          zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ)) :
    ∃ x1 : M.carrier,
      nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  obtain ⟨x1, hwx1, hx1t, hpt, hbelow⟩ := h
  have hanchor :=
    kvE2_sepPtX1R_anchor (nf_depth0_char_formula atomMap h_surj) charK σ M atomMap x1 hpt
  obtain ⟨h_atom, h_off, h_fwd, h_bwd⟩ := hgate x1 hwx1 hx1t hanchor
  refine ⟨x1, ?_⟩
  rw [nf_eval_depth1_fold_iff]
  refine ⟨h_atom, ?_, h_off⟩
  intro zs χ
  refine ⟨fun hex => h_fwd zs χ hex, ?_⟩
  intro hbit
  by_cases hzs : zs = kvE2_sep_zWX1
  · -- Right-interior middle region `zWX1 = (w < v < x1)`: the bundle's own below-witness
    -- clause supplies a witness strictly between `w` and the anchor `x1` (Def 3.1, PDF p.4).
    subst hzs
    obtain ⟨u, hwu, hux1, hu⟩ := hbelow χ hbit
    refine ⟨u, ?_, (nfPred_correct M atomMap h_surj χ u).mp hu⟩
    -- `u` lies in `zWX1` relative to env `[x1, w, x, t]` under `x < w < u < x1 < t`.
    have hxu : x < u := hxw.trans hwu
    have hut : u < t := hux1.trans hx1t
    intro i
    match i with
    | ⟨0, _⟩ => exact ⟨iff_of_true hux1 rfl, iff_of_false (lt_asymm hux1) (by decide +revert)⟩
    | ⟨1, _⟩ => exact ⟨iff_of_false (lt_asymm hwu) (by decide +revert), iff_of_true hwu rfl⟩
    | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxu) (by decide +revert), iff_of_true hxu rfl⟩
    | ⟨3, _⟩ => exact ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by decide +revert)⟩
  · -- Every other zone: the gate's backward direction (analog of `kvE_gate` honesty).
    exact h_bwd zs χ hzs hbit

/-- **Per-σ kit application over a realized body** (Phase 3 terminus — the Phase 4 input
    shape): from any realized `kvE2_sepBody` (whose held disjunct rides an arbitrary
    `wo ∈ kvE2_sepArr' qnf` inside the hypothesis-free `kvE2_sepBody_extract`) and per-class
    gate families at the extracted shared pivot, EVERY positive interior owner's depth-1
    `nf_eval` is realized at that pivot: left class via `kvE2_sepBundleL_parts` →
    `kvE_subBracket2V_sound_of_parts` (`kvE2_sepBundleL_sound`), right class via the mirrored
    `kvE2_sepBundleR_sound`. The gate families quantify over the pivot because the extraction
    produces `w` existentially; each gate stays an explicit threaded hypothesis (Amendment F3
    — never assumed). All bits consumed are self-owned enumeration antecedents. -/
theorem kvE2_sepBody_kit_sound {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig)
    (x t : M.carrier)
    (h : (kvE2_sepBody (nf_depth0_char_formula atomMap h_surj) charK qnf).holds M atomMap x t)
    (hgateL : ∀ w : M.carrier, x < w → w < t →
      (kvE2_sepPtW (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap w →
      ∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zXW3 →
      ∀ a : M.carrier, x < a → a < t →
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap a →
      a < w ∧ w < t ∧
      nf_eval_nf M 0 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1 ∧
      (∀ τ : NormalForm sig 0 5, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false) ∧
      (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1),
        (∃ v : M.carrier,
          zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ) →
        σ.2 (nf0_assemble zs χ σ.1) = true) ∧
      (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1), zs ≠ kvE_sub2_zXU →
        σ.2 (nf0_assemble zs χ σ.1) = true →
        ∃ v : M.carrier,
          zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ))
    (hgateR : ∀ w : M.carrier, x < w → w < t →
      (kvE2_sepPtW (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap w →
      ∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zWT3 →
      ∀ a : M.carrier, w < a → a < t →
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap a →
      nf_eval_nf M 0 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1 ∧
      (∀ τ : NormalForm sig 0 5, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false) ∧
      (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1),
        (∃ v : M.carrier,
          zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ) →
        σ.2 (nf0_assemble zs χ σ.1) = true) ∧
      (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1), zs ≠ kvE2_sep_zWX1 →
        σ.2 (nf0_assemble zs χ σ.1) = true →
        ∃ v : M.carrier,
          zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ)) :
    (kvE2_sepEpL (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap x ∧
    (kvE2_sepEpR (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap t ∧
    ∃ w : M.carrier, x < w ∧ w < t ∧
      (kvE2_sepPtW (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap w ∧
      (∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zXW3 →
        ∃ x1 : M.carrier,
          nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) ∧
      (∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zWT3 →
        ∃ x1 : M.carrier,
          nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) := by
  obtain ⟨hEpL, hEpR, w, hxw, hwt, hptW, hL, hR⟩ :=
    kvE2_sepBody_extract (nf_depth0_char_formula atomMap h_surj) charK qnf M atomMap x t h
  refine ⟨hEpL, hEpR, w, hxw, hwt, hptW, ?_, ?_⟩
  · intro σ hσ hz
    exact kvE2_sepBundleL_sound atomMap h_surj charK σ M w x t hwt (hL σ hσ hz)
      (hgateL w hxw hwt hptW σ hσ hz)
  · intro σ hσ hz
    exact kvE2_sepBundleR_sound atomMap h_surj charK σ M w x t hxw (hR σ hσ hz)
      (hgateR w hxw hwt hptW σ hσ hz)

/-! ## Phase 4 (task 333) — Outer depth-2 fold `kvE2_outer_fold` (R4, the make-or-break)

Reassemble `∃ w, nf_eval_nf M 2 3 [w,x,t] qnf` from the per-σ realizations delivered by
`kvE2_sepBody_kit_sound` (Phase 3). There is NO landed depth-2 quant-layer fold engine
(`nf_quant_layer_fold_iff`, `NfEFold.lean:391`, folds depth-0 inner subs; the k=2 quant layer
ranges over depth-1 subs), so this theorem IS the assembly: it derives the outer atom layer
from the carrier's own endpoint/witness point types (`kvE2_sepEpL`/`kvE2_sepEpR`/`kvE2_sepPtW`
head conjuncts through `nfPred_correct`) plus the six outer order bits, zone-classifies the
positive subs through the extracted membership, discharges the two INTERIOR classes via the
Phase-3 kit, and threads the two genuinely provider-conditional residual families as explicit
hypotheses in the Amendment-F3 style (`kvE_subBracket2V_sound_of_outer` composition pattern):

- `hbdry` — realization of the five NON-interior positive placement classes
  (`zPastX3`/`zAtX3`/`zAtW3`/`zAtT3`/`zFutT3`). Their carrier content rides the σ-level
  `charK` E[Σ]-atom literals of `kvE2_sepEpL`/`kvE2_sepPtW`/`kvE2_sepEpR`, whose typing into
  arity-4 depth-1 evaluations is exactly the `ExistProviders.correct` step (c) of the
  navigated sub-chain sketch (`NavigatedSpine.lean:445`) — discharged downstream at the
  provider instantiation `charK := P.existF 0` (task 335), never assumed here.
- `hexcl` — the outer forward (exclusion) clause: negative subs are unrealized. The depth-2
  carrier pins per-σ content only up to (outer zone, projected 1-type) — the machine-checked
  information-loss record `bracketEndChar_kv_factors` (`CarrierKv.lean:422`) — so this clause
  is provider-conditional in exactly the A1 sense (`PriorInterface.lean:47-59`) and is
  threaded verbatim, never assumed and never discharged vacuously here.

Both families quantify over the pivot `w` because the extraction produces `w` existentially
(the same quantification pattern as `kvE2_sepBody_kit_sound`'s gate families). All bits
consumed remain self-owned enumeration antecedents; no filter is weakened; no `hgate` is
assumed. Rabinovich 2014: Def 3.1 (p.4) ordering/point-type split for the outer atom layer;
Lemma 3.2(2) anchor cap — the statement rides the two fixed anchors `(x,t)` (p.4); §5
bracket assembly with quantifier-free point types (pp.7-9). -/

/-- **Outer depth-2 fold** (task 333 Phase 4 — R4): from a realized `kvE2_sepBody`, the six
    outer order bits of `qnf.1` (the `BracketCarrierCorrectVPrior` bracket-zone hypotheses,
    `PriorInterface.lean:62-68` — the shape task 335's `bracketEndChar_kvE2_sound_two_prior`
    consumer supplies), the two per-class interior gate families (verbatim
    `kvE2_sepBody_kit_sound` shapes: left 6-conjunct excluding `kvE_sub2_zXU`, right
    4-conjunct excluding `kvE2_sep_zWX1` — the two geometries differ), the non-interior
    realization family `hbdry`, and the exclusion family `hexcl`, the depth-2 evaluation
    `∃ w, nf_eval_nf M 2 3 [w,x,t] qnf` is assembled at the extracted shared pivot.

    The proof derives (never assumes): the pivot and its bounds from the Phase-3 kit; the
    outer PREDICATE atom bits at each of `w`/`x`/`t` from the head conjuncts of
    `kvE2_sepPtW`/`kvE2_sepEpL`/`kvE2_sepEpR` through `formula_conjList_iff` +
    `nfPred_correct` (Def 3.1 point-type channel, p.4); the outer ORDER atom bits from
    `x < w < t` against the six order hypotheses; the positive-sub zone classification from
    `kvE2_sepPos` membership; and the interior realizations from the Phase-3 kit. Bounds ride
    the model order — never a fresh-witness relative-position formula literal (LITMUS). -/
theorem kvE2_outer_fold {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    (h_xy : qnf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig)
    (x t : M.carrier)
    (h : (kvE2_sepBody (nf_depth0_char_formula atomMap h_surj) charK qnf).holds M atomMap x t)
    (hgateL : ∀ w : M.carrier, x < w → w < t →
      (kvE2_sepPtW (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap w →
      ∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zXW3 →
      ∀ a : M.carrier, x < a → a < t →
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap a →
      a < w ∧ w < t ∧
      nf_eval_nf M 0 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1 ∧
      (∀ τ : NormalForm sig 0 5, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false) ∧
      (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1),
        (∃ v : M.carrier,
          zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ) →
        σ.2 (nf0_assemble zs χ σ.1) = true) ∧
      (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1), zs ≠ kvE_sub2_zXU →
        σ.2 (nf0_assemble zs χ σ.1) = true →
        ∃ v : M.carrier,
          zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ))
    (hgateR : ∀ w : M.carrier, x < w → w < t →
      (kvE2_sepPtW (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap w →
      ∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zWT3 →
      ∀ a : M.carrier, w < a → a < t →
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap a →
      nf_eval_nf M 0 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1 ∧
      (∀ τ : NormalForm sig 0 5, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false) ∧
      (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1),
        (∃ v : M.carrier,
          zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ) →
        σ.2 (nf0_assemble zs χ σ.1) = true) ∧
      (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1), zs ≠ kvE2_sep_zWX1 →
        σ.2 (nf0_assemble zs χ σ.1) = true →
        ∃ v : M.carrier,
          zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ))
    (hbdry : ∀ w : M.carrier, x < w → w < t →
      (kvE2_sepPtW (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap w →
      ∀ σ ∈ kvE2_sepPos qnf,
        ¬ (nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3) →
        ∃ x1 : M.carrier,
          nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexcl : ∀ w : M.carrier, x < w → w < t →
      (kvE2_sepPtW (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap w →
      ∀ σ : NormalForm sig 1 4, qnf.2 σ = false →
        ∀ x1 : M.carrier,
          ¬ nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    ∃ w : M.carrier,
      nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf := by
  obtain ⟨hEpL, hEpR, w, hxw, hwt, hptW, hLreal, hRreal⟩ :=
    kvE2_sepBody_kit_sound atomMap h_surj charK qnf M x t h hgateL hgateR
  -- Coordinate 1-types at the three outer points, extracted from the carrier's own
  -- point-type head conjuncts (Def 3.1 point-type channel, PDF p.4).
  have hprojW : nf_eval_nf M 0 1 (fun _ => w) (kvE2_sepProj3 qnf.1 ⟨0, by omega⟩) := by
    have h1 := hptW
    simp only [kvE2_sepPtW, TemporalPred.eval_at] at h1
    exact (nfPred_correct M atomMap h_surj _ w).mp
      ((formula_conjList_iff M atomMap w _).mp h1 _ List.mem_cons_self)
  have hprojX : nf_eval_nf M 0 1 (fun _ => x) (kvE2_sepProj3 qnf.1 ⟨1, by omega⟩) := by
    have h1 := hEpL
    simp only [kvE2_sepEpL, TemporalPred.eval_at] at h1
    exact (nfPred_correct M atomMap h_surj _ x).mp
      ((formula_conjList_iff M atomMap x _).mp h1 _ List.mem_cons_self)
  have hprojT : nf_eval_nf M 0 1 (fun _ => t) (kvE2_sepProj3 qnf.1 ⟨2, by omega⟩) := by
    have h1 := hEpR
    simp only [kvE2_sepEpR, TemporalPred.eval_at] at h1
    exact (nfPred_correct M atomMap h_surj _ t).mp
      ((formula_conjList_iff M atomMap t _).mp h1 _ List.mem_cons_self)
  refine ⟨w, ?_, ?_⟩
  · -- Outer atom layer at `[w,x,t]`: PREDICATE bits from the three coordinate 1-types,
    -- ORDER bits from `x < w < t` against the six order hypotheses.
    intro a
    match a with
    | .pred p ⟨0, _⟩ =>
      have h1 := hprojW (.pred p ⟨0, by omega⟩)
      simpa only [atom_eval, kvE2_sepProj3, Fin.cons_zero] using h1
    | .pred p ⟨1, _⟩ =>
      have h1 := hprojX (.pred p ⟨0, by omega⟩)
      simpa only [atom_eval, kvE2_sepProj3, Fin.cons_zero, Fin.cons_succ] using h1
    | .pred p ⟨2, _⟩ =>
      have h1 := hprojT (.pred p ⟨0, by omega⟩)
      simpa only [atom_eval, kvE2_sepProj3, Fin.cons_zero, Fin.cons_succ] using h1
    | .order ⟨0, _⟩ ⟨1, _⟩ hne =>
      refine iff_of_false ?_ (fun hc => Bool.false_ne_true (h_yx.symm.trans hc))
      simp only [atom_eval]
      exact lt_asymm hxw
    | .order ⟨0, _⟩ ⟨2, _⟩ hne =>
      refine iff_of_true ?_ h_yt
      simp only [atom_eval]
      exact hwt
    | .order ⟨1, _⟩ ⟨0, _⟩ hne =>
      refine iff_of_true ?_ h_xy
      simp only [atom_eval]
      exact hxw
    | .order ⟨1, _⟩ ⟨2, _⟩ hne =>
      refine iff_of_true ?_ h_xt
      simp only [atom_eval]
      exact hxw.trans hwt
    | .order ⟨2, _⟩ ⟨0, _⟩ hne =>
      refine iff_of_false ?_ (fun hc => Bool.false_ne_true (h_ty.symm.trans hc))
      simp only [atom_eval]
      exact lt_asymm hwt
    | .order ⟨2, _⟩ ⟨1, _⟩ hne =>
      refine iff_of_false ?_ (fun hc => Bool.false_ne_true (h_tx.symm.trans hc))
      simp only [atom_eval]
      exact lt_asymm (hxw.trans hwt)
    | .order ⟨0, _⟩ ⟨0, _⟩ hne => exact absurd rfl hne
    | .order ⟨1, _⟩ ⟨1, _⟩ hne => exact absurd rfl hne
    | .order ⟨2, _⟩ ⟨2, _⟩ hne => exact absurd rfl hne
  · -- Outer quant layer: forward via the exclusion family, backward via zone
    -- classification (interior classes through the Phase-3 kit, the rest through the
    -- non-interior realization family).
    intro σ
    constructor
    · rintro ⟨x1, hx1⟩
      by_contra hne
      exact hexcl w hxw hwt hptW σ (Bool.eq_false_iff.mpr hne) x1 hx1
    · intro hbit
      have hmem : σ ∈ kvE2_sepPos qnf := by
        simp only [kvE2_sepPos, List.mem_filter]
        exact ⟨Finset.mem_toList.mpr (Finset.mem_univ σ), hbit⟩
      by_cases hzL : nf0_zoneSpec σ.1 = kvE2_sep_zXW3
      · exact hLreal σ hmem hzL
      by_cases hzR : nf0_zoneSpec σ.1 = kvE2_sep_zWT3
      · exact hRreal σ hmem hzR
      exact hbdry w hxw hwt hptW σ hmem (by tauto)

-- ============================================================================
-- TASK 344: PIN-ANCHORED FRAGMENT FOLD  (ADDITIVE-ONLY — zero existing decls modified)
--   Spawned from task 335 blocker escalation 2 (sess_1783723095_edd5a7).
--   Grounding: reports/01_fragment-extractor-derivability.md (GO: pin-anchored _frag).
--   Deliverables: kvE2_sepGateAtPin_fragL / kvE2_sepGateAtPin_fragR /
--                 kvE2_sepBody_kit_sound_frag / kvE2_outer_fold_frag.
--   REFUTED (never attempt): the ∀-anchor segment-coverage extractor (report §1).
--   Consumer: task 335 Phase B (bracketEndChar_kvE2_correct_two_prior_frag).
--   341 GATE re-diff: everything below this banner is new; nothing above is touched.
-- ============================================================================

/-- **Single-positive-sub fragment predicate** (task 344 — local restatement of
    `OuterGate.kvE2_sepFragment`, `OuterGate.lean:191`). Restated here rather than imported
    because `OuterGate` imports `SharedWitness` (importing back would create a cycle); the two
    definitions are byte-identical and `OuterGate`'s definitional `rfl` bridges them at the 335
    consumption site. `qnf`'s positive-sub list is exactly the singleton `[σ0]` with `σ0`
    interior-zoned. Depends only on `qnf`, never on a model or provider. -/
def kvE2_sepFragment_frag {sig : MonadicSignature} (qnf : NormalForm sig 2 3) : Prop :=
  ∃ σ0 : NormalForm sig 1 4,
    kvE2_sepPos qnf = [σ0] ∧
    (nf0_zoneSpec σ0.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ0.1 = kvE2_sep_zWT3)

/-- **LEFT-interior parts closer at the PIN** (task 344 Phase 1 — the continuation-inlining
    wrapper). Inlines `kvE_subBracket2V_sound_of_parts`'s continuation (`SubBracket2V.lean:1324-1345`)
    with the four gate conjuncts supplied AT the specific pin `x1` (`x < x1 < w`), NOT as a ∀-anchor
    over `(x,t)` (whose universal form is REFUTED, report §1). The gate producer
    (`kvE2_sepGateAtPin_fragL`) extracts `x1` from the body and derives the four conjuncts at THAT
    pin, then calls this closer — the pin-specific forward conjunct (`h_fwd`) is never demanded at an
    arbitrary anchor. Additive; consumes `nf_eval_depth1_fold_iff`/`nfPred_correct` unchanged. -/
theorem kvE2_sepBundleL_sound_frag {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier) (hwt : w < t)
    (x1 : M.carrier) (hx1w : x1 < w)
    (hbelow : ∀ χ : NormalForm sig 0 1,
      σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true →
      ∃ u : M.carrier, x < u ∧ u < x1 ∧
        (⟨nf_depth0_char_formula atomMap h_surj χ⟩ : TemporalPred).eval_at M atomMap u)
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
    have huw : u < w := hux1.trans hx1w
    have hut : u < t := huw.trans hwt
    intro i
    match i with
    | ⟨0, _⟩ => exact ⟨iff_of_true hux1 rfl, iff_of_false (lt_asymm hux1) (by decide +revert)⟩
    | ⟨1, _⟩ => exact ⟨iff_of_true huw rfl, iff_of_false (lt_asymm huw) (by decide +revert)⟩
    | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxu) (by decide +revert), iff_of_true hxu rfl⟩
    | ⟨3, _⟩ => exact ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by decide +revert)⟩
  · exact h_bwd zs χ hzs hbit

/-- **RIGHT-interior parts closer at the PIN** (task 344 Phase 1 — mirror of
    `kvE2_sepBundleL_sound_frag`). Inlines `kvE2_sepBundleR_sound`'s continuation (`SW:9750-9776`)
    with the four gate conjuncts supplied at the specific pin `x1` (`w < x1 < t`), backward exception
    zone `kvE2_sep_zWX1`. The `x < w` head is this lemma's hypothesis. Additive. -/
theorem kvE2_sepBundleR_sound_frag {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier) (hxw : x < w)
    (x1 : M.carrier) (hwx1 : w < x1) (hx1t : x1 < t)
    (hbelow : ∀ χ : NormalForm sig 0 1,
      σ.2 (nf0_assemble kvE2_sep_zWX1 χ σ.1) = true →
      ∃ u : M.carrier, w < u ∧ u < x1 ∧
        (⟨nf_depth0_char_formula atomMap h_surj χ⟩ : TemporalPred).eval_at M atomMap u)
    (h_atom : nf_eval_nf M 0 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1)
    (h_off : ∀ τ : NormalForm sig 0 5, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false)
    (h_fwd : ∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1),
      (∃ v : M.carrier,
        zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
        nf_eval_nf M 0 1 (fun _ => v) χ) →
      σ.2 (nf0_assemble zs χ σ.1) = true)
    (h_bwd : ∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1), zs ≠ kvE2_sep_zWX1 →
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
  by_cases hzs : zs = kvE2_sep_zWX1
  · subst hzs
    obtain ⟨u, hwu, hux1, hu⟩ := hbelow χ hbit
    refine ⟨u, ?_, (nfPred_correct M atomMap h_surj χ u).mp hu⟩
    have hxu : x < u := hxw.trans hwu
    have hut : u < t := hux1.trans hx1t
    intro i
    match i with
    | ⟨0, _⟩ => exact ⟨iff_of_true hux1 rfl, iff_of_false (lt_asymm hux1) (by decide +revert)⟩
    | ⟨1, _⟩ => exact ⟨iff_of_false (lt_asymm hwu) (by decide +revert), iff_of_true hwu rfl⟩
    | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxu) (by decide +revert), iff_of_true hxu rfl⟩
    | ⟨3, _⟩ => exact ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by decide +revert)⟩
  · exact h_bwd zs χ hzs hbit

/-- **Point-location among strictly-monotone bracket witnesses** (task 344 Phase 1 — the
    combinatorial core of the pin-anchored forward-zone derivation). For a strictly monotone
    finite witness family `ws : Fin (k+1) → M.carrier`, any point `v` is EITHER one of the
    witnesses, OR below the first, OR strictly between two consecutive witnesses, OR above the
    last — exactly the four segment regions of `IntervalPattern.holds_eq_succ`
    (`ExistsForallNF.lean:197-203`). Model-general (rides `M.carrier`'s `LinearOrder`); carries
    no fold/bracket content. This converts an arbitrary model point of an interior forward-zone
    into the region whose landed segment/witness channel closes it. Additive. -/
theorem kvE2_sep_locate_witness {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) {k : Nat}
    (ws : Fin (k + 1) → M.carrier)
    (v : M.carrier) :
    (∃ i : Fin (k + 1), v = ws i) ∨
    (v < ws ⟨0, Nat.succ_pos k⟩) ∨
    (∃ i : Fin k, ws ⟨i.val, Nat.lt_succ_of_lt i.isLt⟩ < v ∧
      v < ws ⟨i.val + 1, Nat.succ_lt_succ i.isLt⟩) ∨
    (ws ⟨k, Nat.lt_succ_self k⟩ < v) := by
  classical
  by_cases hex : ∃ i : Fin (k + 1), v = ws i
  · exact Or.inl hex
  · push_neg at hex
    have htri : ∀ i : Fin (k + 1), ws i < v ∨ v < ws i := by
      intro i
      rcases lt_trichotomy (ws i) v with h | h | h
      · exact Or.inl h
      · exact absurd h.symm (hex i)
      · exact Or.inr h
    by_cases hlow : v < ws ⟨0, Nat.succ_pos k⟩
    · exact Or.inr (Or.inl hlow)
    · have h0 : ws ⟨0, Nat.succ_pos k⟩ < v := (htri ⟨0, Nat.succ_pos k⟩).resolve_right hlow
      have hSne : (Finset.univ.filter (fun i : Fin (k + 1) => ws i < v)).Nonempty :=
        ⟨⟨0, Nat.succ_pos k⟩, Finset.mem_filter.mpr ⟨Finset.mem_univ _, h0⟩⟩
      set m := (Finset.univ.filter (fun i : Fin (k + 1) => ws i < v)).max' hSne with hmdef
      have hmS := (Finset.univ.filter (fun i : Fin (k + 1) => ws i < v)).max'_mem hSne
      have hmv : ws m < v := (Finset.mem_filter.mp hmS).2
      by_cases hmk : m.val = k
      · right; right; right
        have hme : m = ⟨k, Nat.lt_succ_self k⟩ := Fin.ext hmk
        rwa [hme] at hmv
      · right; right; left
        have hmlt : m.val < k := lt_of_le_of_ne (Nat.lt_succ_iff.mp m.isLt) hmk
        refine ⟨⟨m.val, hmlt⟩, ?_, ?_⟩
        · have hme : (⟨m.val, Nat.lt_succ_of_lt hmlt⟩ : Fin (k + 1)) = m := Fin.ext rfl
          rw [hme]; exact hmv
        · have hnext : (⟨m.val + 1, Nat.succ_lt_succ hmlt⟩ : Fin (k + 1)) ∉
              Finset.univ.filter (fun i : Fin (k + 1) => ws i < v) := by
            intro hc
            have hle := Finset.le_max' _ _ hc
            rw [← hmdef] at hle
            have : m.val + 1 ≤ m.val := Fin.le_def.mp hle
            omega
          have hnv : ¬ (ws ⟨m.val + 1, Nat.succ_lt_succ hmlt⟩ < v) := fun hc =>
            hnext (Finset.mem_filter.mpr ⟨Finset.mem_univ _, hc⟩)
          exact (htri ⟨m.val + 1, Nat.succ_lt_succ hmlt⟩).resolve_left hnv

/-- **LEFT pin-anchored gate producer** (task 344 Phase 1 — the crux). From a realized
    `kvE2_sepBody` in the SINGLE-positive fragment (`hfrag`) with the sole positive sub `σ0`
    left-interior (`hz`), plus provider-correctness `hcorrK` at the pin (the `ExistProviders.correct`
    step 335 owns), the `kvE2_sepBody_kit_sound` conclusion is assembled by re-running the joint
    bracket extraction INLINE (keeping the segment components `holds_eq_succ` 4/5/6 discarded by
    `kvE2_sepBody_extract`), then deriving the four pin conjuncts and calling the landed
    `kvE2_sepBundleL_sound_frag`. Every conjunct is derived AT the extracted pin `x1` (`x < x1 < w`),
    NEVER at an arbitrary ∀-anchor (report §1 refutation). Additive; `hcorrK` an explicit
    hypothesis, never discharged. -/
theorem kvE2_sepGateAtPin_fragL {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    (h_xy : qnf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig)
    (x t : M.carrier)
    (σ0 : NormalForm sig 1 4)
    (hfrag : kvE2_sepPos qnf = [σ0])
    (hz : nf0_zoneSpec σ0.1 = kvE2_sep_zXW3)
    (hcorrK : ∀ (σ : NormalForm sig 1 4) (a : M.carrier),
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap a →
      nf_eval_nf M 1 1 (fun _ => a) (nfk_projFresh σ))
    (h : (kvE2_sepBody (nf_depth0_char_formula atomMap h_surj) charK qnf).holds M atomMap x t) :
    (kvE2_sepEpL (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap x ∧
    (kvE2_sepEpR (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap t ∧
    ∃ w : M.carrier, x < w ∧ w < t ∧
      (kvE2_sepPtW (nf_depth0_char_formula atomMap h_surj) charK qnf).eval_at M atomMap w ∧
      (∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zXW3 →
        ∃ x1 : M.carrier,
          nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) ∧
      (∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zWT3 →
        ∃ x1 : M.carrier,
          nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) := by
  set charBase := nf_depth0_char_formula atomMap h_surj with hcb
  by_cases hg : kvE2_sepGate qnf
  · rw [kvE2_sepBody_holds_iff charBase charK qnf hg M atomMap x t] at h
    obtain ⟨wo, hwo, hd⟩ := h
    obtain ⟨hepL, hepR, hbr⟩ := hd
    have hwo' : wo ∈ kvE2_sepOrderTypes qnf := (List.mem_filter.mp hwo).1
    have howners : wo.map Prod.fst = kvE2_sepPosI qnf := kvE2_sepOrderTypes_owners qnf hwo'
    have hksortL : (kvE2_sepSlotsLOf wo).Pairwise
        (fun a b => kvE2_sepSlotGIdx wo a ≤ kvE2_sepSlotGIdx wo b) := by
      refine (kvE2_sepSlotsLOf_mergeSorted wo).imp ?_
      intro a b hab; rw [kvE2_sepSlotMergeLe, decide_eq_true_eq] at hab; exact hab
    simp only [kvE2_sepDisjunct', kvE2_sepBracketN, BracketFormula.holds,
      BracketFormula.toIntervalPattern] at hbr
    rw [IntervalPattern.holds_eq_succ M atomMap _ _ x t
      (show ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length + 1
          + ((kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK)).length
        = ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length
          + ((kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK)).length + 1
        by omega)] at hbr
    obtain ⟨ws, hmono, hrange, hpt, hseg0, hsegMid, hsegLast⟩ := hbr
    have hpt' : ∀ (i : Nat)
        (hi : i < ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length
          + ((kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK)).length + 1),
        (((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)
            ++ kvE2_sepPtW charBase charK qnf
              :: (kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK))[i]'(by
          simp only [List.length_append, List.length_cons]; omega)).eval_at M atomMap
          (ws ⟨i, hi⟩) := fun i hi => hpt ⟨i, hi⟩
    have hwidx : ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length
        < ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length
          + ((kvE2_sepTieGroupedR wo).map (kvE2_sepClassType charBase charK)).length + 1 := by omega
    set w := ws ⟨((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length,
      hwidx⟩ with hwdef
    have hxw : x < w := (hrange _).1
    have hwt : w < t := (hrange _).2
    have hptW : (kvE2_sepPtW charBase charK qnf).eval_at M atomMap w := by
      have h1 := hpt' _ hwidx
      rwa [kvE2_sep_getElem_mid] at h1
    -- σ0's pin and bundle (single-positive: σ0 is the sole owner; no cross-σ slots)
    have hσ0pos : σ0 ∈ kvE2_sepPos qnf := by rw [hfrag]; exact List.mem_singleton_self _
    have hσ0true : qnf.2 σ0 = true := by
      have := hσ0pos; simp only [kvE2_sepPos, List.mem_filter] at this; exact this.2
    have hσI : σ0 ∈ kvE2_sepPosI qnf := (kvE2_sepPosI_mem qnf σ0).mpr ⟨hσ0pos, Or.inl hz⟩
    have hσp : σ0 ∈ wo.map Prod.fst := by rw [howners]; exact hσI
    obtain ⟨pp, hpwo, hp1⟩ := List.mem_map.mp hσp
    have hpe : (σ0, pp.2.1, pp.2.2) ∈ wo := by rw [← hp1]; exact hpwo
    have hmemX1 : (KvE2SepSlot.lX1 σ0) ∈ kvE2_sepSlotsLOf wo :=
      kvE2_sepSlotsLOf_mem qnf hwo' hσI (kvE2_sep_lX1_mem_slotsLFor hz)
    rw [← kvE2_sepTieGroupedL_flatten wo] at hmemX1
    obtain ⟨c, hc, hsc⟩ := List.mem_flatten.mp hmemX1
    obtain ⟨iσ, hiσ, hgetiσ⟩ := List.mem_iff_getElem.mp hc
    have hiσm : iσ < ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length := by
      simp only [List.length_map]; omega
    set x1 := ws ⟨iσ, by omega⟩ with hx1def
    have hxx1 : x < x1 := (hrange _).1
    have hx1w : x1 < w := hmono _ _ (Fin.mk_lt_mk.mpr hiσm)
    -- pin point type (folded through the class meet) and the charK anchor at the pin
    have hpin_raw := hpt' iσ (by omega)
    rw [kvE2_sep_getElem_left _ _ _ iσ hiσm, List.getElem_map, hgetiσ] at hpin_raw
    have hpt_pin := kvE2_sepClassType_eval_mem charBase charK M atomMap _ hpin_raw hsc
    have hanchor : (⟨charK (nfk_projFresh σ0)⟩ : TemporalPred).eval_at M atomMap x1 :=
      kvE2_sepPtX1L_anchor charBase charK σ0 M atomMap x1 hpt_pin
    -- below-witness clause: every zXU-positive 1-type strictly below the pin
    have hbelow : ∀ χ : NormalForm sig 0 1,
        σ0.2 (nf0_assemble kvE_sub2_zXU χ σ0.1) = true →
        ∃ u : M.carrier, x < u ∧ u < x1 ∧
          (⟨charBase χ⟩ : TemporalPred).eval_at M atomMap u := by
      intro χ hbit
      have hmemU : (KvE2SepSlot.lXU σ0 χ) ∈ kvE2_sepSlotsLOf wo :=
        kvE2_sepSlotsLOf_mem qnf hwo' hσI (kvE2_sep_lXU_mem_slotsLFor hz hbit)
      rw [← kvE2_sepTieGroupedL_flatten wo] at hmemU
      obtain ⟨d, hd, hsd⟩ := List.mem_flatten.mp hmemU
      obtain ⟨jχ, hjχ, hgetjχ⟩ := List.mem_iff_getElem.mp hd
      have hkey : kvE2_sepSlotGIdx wo (KvE2SepSlot.lXU σ0 χ)
          < kvE2_sepSlotGIdx wo (KvE2SepSlot.lX1 σ0) :=
        kvE2_sep_gidx_lt_of_rank_lt qnf hwo hpe
          (by rw [kvE2_sepSlotBlock]
              exact List.mem_append_left _ (kvE2_sep_lXU_mem_slotsLFor hz hbit))
          (by rw [kvE2_sepSlotBlock]
              exact List.mem_append_left _ (kvE2_sep_lX1_mem_slotsLFor hz))
          rfl Nat.zero_lt_one
      have hain : (KvE2SepSlot.lXU σ0 χ) ∈ (kvE2_sepTieGroupedL wo)[jχ]'hjχ := by
        rw [hgetjχ]; exact hsd
      have hbin : (KvE2SepSlot.lX1 σ0) ∈ (kvE2_sepTieGroupedL wo)[iσ]'hiσ := by
        rw [hgetiσ]; exact hsc
      have hji : jχ < iσ := kvE2_sepTieRuns_classIdx_lt (kvE2_sepSlotGIdx wo)
        (kvE2_sepSlotsLOf wo) hksortL hjχ hiσ hain hbin hkey
      have hjχm : jχ < ((kvE2_sepTieGroupedL wo).map (kvE2_sepClassType charBase charK)).length := by
        simp only [List.length_map]; omega
      refine ⟨ws ⟨jχ, by omega⟩, (hrange _).1,
        hmono _ _ (Fin.mk_lt_mk.mpr hji), ?_⟩
      have h1 := hpt' jχ (by omega)
      rw [kvE2_sep_getElem_left _ _ _ jχ hjχm, List.getElem_map, hgetjχ] at h1
      exact kvE2_sepClassType_eval_mem charBase charK M atomMap _ h1 hsd
    refine ⟨hepL, hepR, w, hxw, hwt, hptW, ?_, ?_⟩
    · intro σ hσ hzσ
      have hσeq : σ = σ0 := by rw [hfrag] at hσ; exact List.mem_singleton.mp hσ
      subst hσeq
      have h_off : ∀ τ : NormalForm sig 0 5, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false :=
        kvE2_sepHgate_offFiber qnf hg σ hσ0true
      -- gate clause (i): a positive sub's env-restriction equals `qnf.1`
      have hdrop : nf0_dropFresh σ.1 = qnf.1 := by
        by_contra hne
        rw [hg.1 σ hne] at hσ0true
        exact absurd hσ0true (by decide)
      -- the three outer points realize `qnf.1`'s coordinate 1-types (endpoint/point heads)
      have hprojW : nf_eval_nf M 0 1 (fun _ => w) (kvE2_sepProj3 qnf.1 ⟨0, by omega⟩) := by
        have h1 := hptW
        simp only [kvE2_sepPtW, TemporalPred.eval_at] at h1
        exact (nfPred_correct M atomMap h_surj _ w).mp
          ((formula_conjList_iff M atomMap w _).mp h1 _ List.mem_cons_self)
      have hprojX : nf_eval_nf M 0 1 (fun _ => x) (kvE2_sepProj3 qnf.1 ⟨1, by omega⟩) := by
        have h1 := hepL
        simp only [kvE2_sepEpL, TemporalPred.eval_at] at h1
        exact (nfPred_correct M atomMap h_surj _ x).mp
          ((formula_conjList_iff M atomMap x _).mp h1 _ List.mem_cons_self)
      have hprojT : nf_eval_nf M 0 1 (fun _ => t) (kvE2_sepProj3 qnf.1 ⟨2, by omega⟩) := by
        have h1 := hepR
        simp only [kvE2_sepEpR, TemporalPred.eval_at] at h1
        exact (nfPred_correct M atomMap h_surj _ t).mp
          ((formula_conjList_iff M atomMap t _).mp h1 _ List.mem_cons_self)
      have h_atom : nf_eval_nf M 0 4
          (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1 := by
        -- reconstruct σ.1 from its three Def-3.1 channels via per-atom congrFun bridges
        -- (the `nf0_assemble` order case does NOT simp-reduce — nested `Fin.cases` with motive —
        -- so we rewrite each σ.1 bit to a CLOSED qnf.1/zXW3 value before deciding it)
        have hpf : (nfk_projFresh σ).1 = nf0_projFresh σ.1 := by
          funext a
          match a with
          | .pred p i =>
            have hi : i = ⟨0, by omega⟩ := Subsingleton.elim i _
            subst hi; rfl
          | .order i j hij => exact absurd (Subsingleton.elim i j) hij
        obtain ⟨hc0a, -⟩ := hcorrK σ x1 hanchor
        -- normalize each raw σ.1 bit to a CLOSED value via congrFun on hdrop/hz
        -- (the `.succ` forms from mergeNF/zoneSpec are reduced back to Fin literals by
        --  `Fin.succ_mk` + `Nat.reduceAdd`, so the rewrites match the matched atom)
        intro a
        match a with
        | .pred p ⟨0, _⟩ =>
          have h1 := hc0a (.pred p ⟨0, by omega⟩)
          simpa only [atom_eval, Fin.cons_zero, atomKind_castLE, Fin.castLE] using h1
        | .pred p ⟨1, _⟩ =>
          have e := congrFun hdrop (AtomKind.pred p ⟨0, by omega⟩)
          simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ, Fin.succ_mk, Nat.reduceAdd] at e
          rw [e]
          have h1 := hprojW (.pred p ⟨0, by omega⟩)
          simpa only [atom_eval, kvE2_sepProj3, Fin.cons_zero, Fin.cons_succ] using h1
        | .pred p ⟨2, _⟩ =>
          have e := congrFun hdrop (AtomKind.pred p ⟨1, by omega⟩)
          simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ, Fin.succ_mk, Nat.reduceAdd] at e
          rw [e]
          have h1 := hprojX (.pred p ⟨0, by omega⟩)
          simpa only [atom_eval, kvE2_sepProj3, Fin.cons_zero, Fin.cons_succ] using h1
        | .pred p ⟨3, _⟩ =>
          have e := congrFun hdrop (AtomKind.pred p ⟨2, by omega⟩)
          simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ, Fin.succ_mk, Nat.reduceAdd] at e
          rw [e]
          have h1 := hprojT (.pred p ⟨0, by omega⟩)
          simpa only [atom_eval, kvE2_sepProj3, Fin.cons_zero, Fin.cons_succ] using h1
        | .order ⟨0, _⟩ ⟨1, _⟩ hne =>
          have hbit : σ.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ hne) = true := by
            simpa only [nf0_zoneSpec, kvE2_sep_zXW3, Fin.isValue, Fin.succ_mk, Nat.reduceAdd,
              Fin.cons_zero, Fin.cons_succ] using congrArg Prod.fst (congrFun hz ⟨0, by omega⟩)
          rw [hbit]; simp only [atom_eval, Fin.cons_zero, Fin.cons_succ]
          exact iff_of_true hx1w (by decide)
        | .order ⟨0, _⟩ ⟨2, _⟩ hne =>
          have hbit : σ.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ hne) = false := by
            simpa only [nf0_zoneSpec, kvE2_sep_zXW3, Fin.isValue, Fin.succ_mk, Nat.reduceAdd,
              Fin.cons_zero, Fin.cons_succ] using congrArg Prod.fst (congrFun hz ⟨1, by omega⟩)
          rw [hbit]; simp only [atom_eval, Fin.cons_zero, Fin.cons_succ]
          exact iff_of_false (lt_asymm hxx1) (by decide)
        | .order ⟨0, _⟩ ⟨3, _⟩ hne =>
          have hbit : σ.1 (.order ⟨0, by omega⟩ ⟨3, by omega⟩ hne) = true := by
            simpa only [nf0_zoneSpec, kvE2_sep_zXW3, Fin.isValue, Fin.succ_mk, Nat.reduceAdd,
              Fin.cons_zero, Fin.cons_succ] using congrArg Prod.fst (congrFun hz ⟨2, by omega⟩)
          rw [hbit]; simp only [atom_eval, Fin.cons_zero, Fin.cons_succ]
          exact iff_of_true (hx1w.trans hwt) (by decide)
        | .order ⟨1, _⟩ ⟨0, _⟩ hne =>
          have hbit : σ.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ hne) = false := by
            simpa only [nf0_zoneSpec, kvE2_sep_zXW3, Fin.isValue, Fin.succ_mk, Nat.reduceAdd,
              Fin.cons_zero, Fin.cons_succ] using congrArg Prod.snd (congrFun hz ⟨0, by omega⟩)
          rw [hbit]; simp only [atom_eval, Fin.cons_zero, Fin.cons_succ]
          exact iff_of_false (lt_asymm hx1w) (by decide)
        | .order ⟨2, _⟩ ⟨0, _⟩ hne =>
          have hbit : σ.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ hne) = true := by
            simpa only [nf0_zoneSpec, kvE2_sep_zXW3, Fin.isValue, Fin.succ_mk, Nat.reduceAdd,
              Fin.cons_zero, Fin.cons_succ] using congrArg Prod.snd (congrFun hz ⟨1, by omega⟩)
          rw [hbit]; simp only [atom_eval, Fin.cons_zero, Fin.cons_succ]
          exact iff_of_true hxx1 (by decide)
        | .order ⟨3, _⟩ ⟨0, _⟩ hne =>
          have hbit : σ.1 (.order ⟨3, by omega⟩ ⟨0, by omega⟩ hne) = false := by
            simpa only [nf0_zoneSpec, kvE2_sep_zXW3, Fin.isValue, Fin.succ_mk, Nat.reduceAdd,
              Fin.cons_zero, Fin.cons_succ] using congrArg Prod.snd (congrFun hz ⟨2, by omega⟩)
          rw [hbit]; simp only [atom_eval, Fin.cons_zero, Fin.cons_succ]
          exact iff_of_false (lt_asymm (hx1w.trans hwt)) (by decide)
        | .order ⟨1, _⟩ ⟨2, _⟩ hne =>
          have e := congrFun hdrop (AtomKind.order ⟨0, by omega⟩ ⟨1, by omega⟩
            (Fin.ne_of_val_ne (show (0 : ℕ) ≠ 1 by decide)))
          simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ, Fin.succ_mk, Nat.reduceAdd,
            h_yx] at e
          rw [e]; simp only [atom_eval, Fin.cons_zero, Fin.cons_succ]
          exact iff_of_false (lt_asymm (hxx1.trans hx1w)) (by decide)
        | .order ⟨2, _⟩ ⟨1, _⟩ hne =>
          have e := congrFun hdrop (AtomKind.order ⟨1, by omega⟩ ⟨0, by omega⟩
            (Fin.ne_of_val_ne (show (1 : ℕ) ≠ 0 by decide)))
          simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ, Fin.succ_mk, Nat.reduceAdd,
            h_xy] at e
          rw [e]; simp only [atom_eval, Fin.cons_zero, Fin.cons_succ]
          exact iff_of_true (hxx1.trans hx1w) (by decide)
        | .order ⟨1, _⟩ ⟨3, _⟩ hne =>
          have e := congrFun hdrop (AtomKind.order ⟨0, by omega⟩ ⟨2, by omega⟩
            (Fin.ne_of_val_ne (show (0 : ℕ) ≠ 2 by decide)))
          simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ, Fin.succ_mk, Nat.reduceAdd,
            h_yt] at e
          rw [e]; simp only [atom_eval, Fin.cons_zero, Fin.cons_succ]
          exact iff_of_true hwt (by decide)
        | .order ⟨3, _⟩ ⟨1, _⟩ hne =>
          have e := congrFun hdrop (AtomKind.order ⟨2, by omega⟩ ⟨0, by omega⟩
            (Fin.ne_of_val_ne (show (2 : ℕ) ≠ 0 by decide)))
          simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ, Fin.succ_mk, Nat.reduceAdd,
            h_ty] at e
          rw [e]; simp only [atom_eval, Fin.cons_zero, Fin.cons_succ]
          exact iff_of_false (lt_asymm hwt) (by decide)
        | .order ⟨2, _⟩ ⟨3, _⟩ hne =>
          have e := congrFun hdrop (AtomKind.order ⟨1, by omega⟩ ⟨2, by omega⟩
            (Fin.ne_of_val_ne (show (1 : ℕ) ≠ 2 by decide)))
          simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ, Fin.succ_mk, Nat.reduceAdd,
            h_xt] at e
          rw [e]; simp only [atom_eval, Fin.cons_zero, Fin.cons_succ]
          exact iff_of_true (hxx1.trans (hx1w.trans hwt)) (by decide)
        | .order ⟨3, _⟩ ⟨2, _⟩ hne =>
          have e := congrFun hdrop (AtomKind.order ⟨2, by omega⟩ ⟨1, by omega⟩
            (Fin.ne_of_val_ne (show (2 : ℕ) ≠ 1 by decide)))
          simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ, Fin.succ_mk, Nat.reduceAdd,
            h_tx] at e
          rw [e]; simp only [atom_eval, Fin.cons_zero, Fin.cons_succ]
          exact iff_of_false (lt_asymm (hxx1.trans (hx1w.trans hwt))) (by decide)
        | .order ⟨0, _⟩ ⟨0, _⟩ hne => exact absurd rfl hne
        | .order ⟨1, _⟩ ⟨1, _⟩ hne => exact absurd rfl hne
        | .order ⟨2, _⟩ ⟨2, _⟩ hne => exact absurd rfl hne
        | .order ⟨3, _⟩ ⟨3, _⟩ hne => exact absurd rfl hne
      have h_fwd : ∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1),
          (∃ v : M.carrier,
            zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
            nf_eval_nf M 0 1 (fun _ => v) χ) →
          σ.2 (nf0_assemble zs χ σ.1) = true := by sorry
      have h_bwd : ∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1), zs ≠ kvE_sub2_zXU →
          σ.2 (nf0_assemble zs χ σ.1) = true →
          ∃ v : M.carrier,
            zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
            nf_eval_nf M 0 1 (fun _ => v) χ := by sorry
      exact kvE2_sepBundleL_sound_frag atomMap h_surj σ M w x t hwt x1 hx1w hbelow
        h_atom h_off h_fwd h_bwd
    · intro σ hσ hzσ
      have hσeq : σ = σ0 := by rw [hfrag] at hσ; exact List.mem_singleton.mp hσ
      subst hσeq
      rw [hz] at hzσ
      exact absurd hzσ (by decide)
  · rw [kvE2_sepBody_gate_fail charBase charK qnf hg] at h
    simp [VVecEA2.holds] at h

end Bimodal.Metalogic.WeakCanonical.Kamp
