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
  List (NormalForm sig 1 4 × KvE2SepSpikeOrderType × (ℕ × ℕ × ℕ))

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
    ([(σ, KvE2SepSpikeOrderType.coincident, (0, 1, 2)),
      (τ, KvE2SepSpikeOrderType.coincident, (3, 4, 5))]
        : KvE2SepWeakOrder sig)
      ≠ [(σ, KvE2SepSpikeOrderType.coincident, (3, 4, 5)),
         (τ, KvE2SepSpikeOrderType.coincident, (0, 1, 2))] := by
  simp

/-- **Per-slot global-index tuple** (task 340): for an owner at merged-chain position `k` in an
    `n`-owner arrangement, the region-primary placeholder index tuple `(k, n+k, 2n+k)` — the global
    indices of its region-rank-0/1/2 slots. Behavior-preserving: `giOf = regionRank·n + k`
    reproduces 339's region-primary/owner-secondary order EXACTLY (Phase 2). Consistency
    `i₀<i₁<i₂` holds (`k < n+k < 2n+k`). Phase 5 replaces this with the honest model value order. -/
def kvE2_sepPlaceholderTuple (n k : ℕ) : ℕ × ℕ × ℕ := (k, n + k, 2 * n + k)

/-- **Finite tuple index range** (task 340): all `(ℕ × ℕ × ℕ)` global-index tuples with each
    component `< 3n`. Finite, `DecidableEq`, `decide`-able; contains every `kvE2_sepPlaceholderTuple
    n k` for `k < n` and every order-consistent interleaving over `n` owners' ≤3 region ranks. This
    is the per-slot index the enumeration ranges over, replacing the single `List.range n` rank. -/
def kvE2_sepIdxTuples (n : ℕ) : List (ℕ × ℕ × ℕ) :=
  (List.range (3 * n)).flatMap (fun a =>
    (List.range (3 * n)).flatMap (fun b =>
      (List.range (3 * n)).map (fun c => (a, b, c))))

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
    (a, b, c) ∈ kvE2_sepIdxTuples n := by
  rw [kvE2_sepIdxTuples, List.mem_flatMap]
  refine ⟨a, List.mem_range.mpr ha, ?_⟩
  rw [List.mem_flatMap]
  refine ⟨b, List.mem_range.mpr hb, ?_⟩
  rw [List.mem_map]
  exact ⟨c, List.mem_range.mpr hc, rfl⟩

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
  let n := (kvE2_sepPos qnf).length
  (kvE2_sepPos qnf).foldr
    (fun σ acc =>
      kvE2_sepSpikeOrderTypes.flatMap (fun tag =>
        (kvE2_sepIdxTuples n).flatMap (fun t => acc.map (fun wo => (σ, tag, t) :: wo))))
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
  let n := (kvE2_sepPos qnf).length
  (kvE2_sepPos qnf).zipIdx.map
    (fun p => (p.1, kvE2_sepModelTag p.1, kvE2_sepPlaceholderTuple n p.2))

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
def kvE2_sepConsistentTuple (t : ℕ × ℕ × ℕ) : Bool := decide (t.1 < t.2.1 ∧ t.2.1 < t.2.2)

/-- **Per-disjunct validity** (faithful replacement of the additive `kvE2_sepValid`): a weak order
    is valid iff (i) every per-owner placement is admitted by the owner's arrangement-appropriate
    zone bit (the per-order-type read, F5), (ii) every owner's per-slot global-index tuple EXTENDS
    its region order (`kvE2_sepConsistentTuple`, the task-340 linear-extension conjunct), AND (iii)
    the cross-owner anchor-base indices `i₀` are pairwise distinct (`Nodup`) — the per-owner extension
    plus distinct anchor bases give a genuine total order over the union (Lemma 3.2(1), md:77: one
    consistent global order). The consistency conjunct (ii) is what makes the a<u'<b cross-region
    interleaving admissible while keeping each owner's own slots region-ordered. Reads no zone bit in
    (ii)/(iii). NOT an additive filter over a flat slot union. -/
def kvE2_sepDisjValid {sig : MonadicSignature}
    (_qnf : NormalForm sig 2 3) (wo : KvE2SepWeakOrder sig) : Bool :=
  wo.all (fun p => kvE2_sepDisjValidOwner p.1 p.2.1)
    && wo.all (fun p => kvE2_sepConsistentTuple p.2.2)
    && decide (wo.map (fun p => p.2.2.1)).Nodup

/-- **The faithful carrier** (replacing `kvE2_sepArrL/R`): the valid order-type disjuncts, the
    per-order-type filter of the disjunction index (Lemma 3.2(1), md:77). -/
noncomputable def kvE2_sepArr' {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) : List (KvE2SepWeakOrder sig) :=
  (kvE2_sepOrderTypes qnf).filter (kvE2_sepDisjValid qnf)

/-- The carrier's validity predicate is decidable, so `kvE2_sepArr'` is `decide`-able. -/
instance kvE2_sepArr'_decidable {sig : MonadicSignature} (qnf : NormalForm sig 2 3) :
    DecidablePred (fun wo : KvE2SepWeakOrder sig => kvE2_sepDisjValid qnf wo = true) :=
  fun wo => inferInstanceAs (Decidable (kvE2_sepDisjValid qnf wo = true))

/-- **Structural non-emptiness helper** (generalized over rank bound `n`, tag map `f`, and the
    `zipIdx` start `s`): the `(tag, rank)` assignment tagging each owner by `f` and ranking it by its
    consecutive `zipIdx` index `s, s+1, …` — all `< n` — is reachable in the cartesian rank×tag
    enumeration. Both `kvE2_sepModelOrder` and `kvE2_sepCoincidentOrder` are instances (`s = 0`,
    `n = |pos|`). -/
private theorem kvE2_sepOrderTypes_mem_aux {sig : MonadicSignature} (n : ℕ)
    (f : NormalForm sig 1 4 → KvE2SepSpikeOrderType)
    (gt : ℕ → ℕ × ℕ × ℕ)
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

/-- The model-order disjunct is present in the enumeration index (F2, structural level). -/
theorem kvE2_sepModelOrder_mem_orderTypes {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) :
    kvE2_sepModelOrder qnf ∈ kvE2_sepOrderTypes qnf := by
  rw [kvE2_sepModelOrder, kvE2_sepOrderTypes]
  exact kvE2_sepOrderTypes_mem_aux _ kvE2_sepModelTag
    (kvE2_sepPlaceholderTuple (kvE2_sepPos qnf).length) (kvE2_sepPos qnf) 0
    (fun i hi => by simpa using kvE2_sepPlaceholderTuple_mem (kvE2_sepPos qnf).length i hi)

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
  (wo.mergeSort (fun a b => decide (a.2.2.1 ≤ b.2.2.1))).map Prod.fst

/-- **Owner merged-chain rank read** (task 339): σ's merged-chain rank as recorded in `wo` (338's
    per-owner rank field, consumed AS-IS). Owners not present in `wo` default to `0` (never occurs
    on the enumeration index, where `wo.map Prod.fst = kvE2_sepPos qnf`). -/
def kvE2_sepOwnerRank {sig : MonadicSignature}
    (wo : KvE2SepWeakOrder sig) (σ : NormalForm sig 1 4) : ℕ :=
  ((wo.find? (fun p => decide (p.1 = σ))).map (fun p => p.2.2.1)).getD 0

/-- **Per-slot global index reader** (task 340): the single global index of slot `s` under `wo` —
    read from the owner's per-slot index tuple `(i₀,i₁,i₂)` at `s`'s region rank. Owners not in `wo`
    default to tuple `(0,0,0)` (never occurs on the enumeration index). This is the abstract ℕ the
    single-level merge key compares — a total order on the full slot multiset (Rabinovich Def 3.1
    single global chain), NOT a region×owner product. Reads no zone bit (F5 clean); never a model
    relative-position literal (F4/LITMUS clean — the index is structural carrier data). -/
def kvE2_sepSlotGIdx {sig : MonadicSignature}
    (wo : KvE2SepWeakOrder sig) (s : KvE2SepSlot sig) : ℕ :=
  let t := ((wo.find? (fun p => decide (p.1 = kvE2_sepSlotSub s))).map
    (fun p => p.2.2)).getD (0, 0, 0)
  match kvE2_sepSlotRank s with
  | 0 => t.1
  | 1 => t.2.1
  | _ => t.2.2

/-- **Single-level per-slot global-index merge key** (task 340): compares two slots by their global
    index `kvE2_sepSlotGIdx wo`. Region rank is NO LONGER primary — a region-2 slot of one owner can
    precede a region-1 slot of another (the honest `a<u'<b` cross-region case, report 06, that the
    dropped 339 region-primary lex could not express). The index is a total order over the union of
    all owners' points (Def 3.1 single global chain), constrained to extend each owner's region order
    by the `kvE2_sepDisjValid` consistency conjunct. Abstract ℕ compare; F4/F5/LITMUS clean. -/
def kvE2_sepSlotMergeLe {sig : MonadicSignature}
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
  exact kvE2_sepOrderTypes_owners_aux _ _ hwo

/-- Every positive owner appears in the wo-ordered owner list (rank-reordering permutes, never
    drops, the owner multiset): the membership fact the `kvE2_sepBody_extract` rewire consumes. -/
theorem kvE2_sepMem_orderOwners {sig : MonadicSignature} (qnf : NormalForm sig 2 3)
    {wo : KvE2SepWeakOrder sig} (hwo : wo ∈ kvE2_sepOrderTypes qnf)
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf) :
    σ ∈ kvE2_sepOrderOwners wo := by
  rw [kvE2_sepOrderOwners]
  have hperm := (List.mergeSort_perm wo (fun a b => decide (a.2.2.1 ≤ b.2.2.1))).map Prod.fst
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

/-- The honest COINCIDENCE (tie) arrangement: every positive owner placed at its own fresh anchor
    (Lemma 3.2(1) coincidence disjunct, md:77; §5 meet, md:168-173). -/
noncomputable def kvE2_sepCoincidentOrder {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) : KvE2SepWeakOrder sig :=
  let n := (kvE2_sepPos qnf).length
  (kvE2_sepPos qnf).zipIdx.map
    (fun p => (p.1, KvE2SepSpikeOrderType.coincident, kvE2_sepPlaceholderTuple n p.2))

/-- The coincidence arrangement is present in the enumeration index (F2, structural level): the
    all-coincident tag assignment with consecutive `zipIdx` ranks is reachable in the cartesian
    rank×tag enumeration (a `kvE2_sepOrderTypes_mem_aux` instance, `s = 0`). -/
theorem kvE2_sepCoincidentOrder_mem_orderTypes {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) :
    kvE2_sepCoincidentOrder qnf ∈ kvE2_sepOrderTypes qnf := by
  rw [kvE2_sepCoincidentOrder, kvE2_sepOrderTypes]
  exact kvE2_sepOrderTypes_mem_aux _ (fun _ => KvE2SepSpikeOrderType.coincident)
    (kvE2_sepPlaceholderTuple (kvE2_sepPos qnf).length) (kvE2_sepPos qnf) 0
    (fun i hi => by simpa using kvE2_sepPlaceholderTuple_mem (kvE2_sepPos qnf).length i hi)

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
  · -- (ii) per-owner index-tuple consistency: each placeholder `(k, n+k, 2n+k)` extends region order.
    rw [List.all_eq_true]
    intro p hp
    rw [kvE2_sepCoincidentOrder, List.mem_map] at hp
    obtain ⟨⟨σ, k⟩, hmem, rfl⟩ := hp
    have hσmem : σ ∈ kvE2_sepPos qnf := List.fst_mem_of_mem_zipIdx hmem
    have hn : 0 < (kvE2_sepPos qnf).length := List.length_pos_of_mem hσmem
    simp only [kvE2_sepConsistentTuple, kvE2_sepPlaceholderTuple, decide_eq_true_eq]
    omega
  · -- (iii) cross-owner Nodup: the anchor-base indices `i₀ = 0,1,…,n-1` are pairwise distinct.
    rw [decide_eq_true_eq, kvE2_sepCoincidentOrder, List.map_map]
    have : ((kvE2_sepPos qnf).zipIdx.map
        ((fun p => p.2.2.1) ∘ fun p =>
          (p.1, KvE2SepSpikeOrderType.coincident,
            kvE2_sepPlaceholderTuple (kvE2_sepPos qnf).length p.2)))
        = (kvE2_sepPos qnf).zipIdx.map Prod.snd := by
      apply List.map_congr_left; intro p _; rfl
    rw [this, List.zipIdx_map_snd]
    exact List.nodup_range'

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
    have hn : 0 < (kvE2_sepPos qnf).length := List.length_pos_of_mem hσmem
    simp only [kvE2_sepConsistentTuple, kvE2_sepPlaceholderTuple, decide_eq_true_eq]
    omega
  · rw [decide_eq_true_eq, kvE2_sepCoincidentOrder, List.map_map]
    have : ((kvE2_sepPos qnf).zipIdx.map
        ((fun p => p.2.2.1) ∘ fun p =>
          (p.1, KvE2SepSpikeOrderType.coincident,
            kvE2_sepPlaceholderTuple (kvE2_sepPos qnf).length p.2)))
        = (kvE2_sepPos qnf).zipIdx.map Prod.snd := by
      apply List.map_congr_left; intro p _; rfl
    rw [this, List.zipIdx_map_snd]
    exact List.nodup_range'

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
      (wo.map (fun p => p.2.2.1)).Nodup := by
  have hv : kvE2_sepDisjValid qnf wo = true := (List.mem_filter.mp hwo).2
  rw [kvE2_sepDisjValid, Bool.and_eq_true, Bool.and_eq_true] at hv
  obtain ⟨⟨hall, _hcons⟩, hnodup⟩ := hv
  refine ⟨fun p hp => (List.all_eq_true.mp hall) p hp, ?_⟩
  exact of_decide_eq_true hnodup

end Bimodal.Metalogic.WeakCanonical.Kamp
