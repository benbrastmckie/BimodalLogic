import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorFiberK

/-! # Depth-`k` Future-side exterior-negation clause layer — zone/admissibility (task 352, Phase 3.1)

The depth-`k` Future analog of the frozen k=2 zone/admissibility layer
(`ExteriorNegation.lean`, read-only byte-identical proof template): the zone-classification
and syntactic order-admissibility scaffolding over the `kvE2_futPos` cone, one fold-layer
deeper (`σ : NormalForm sig (k+1) 4` instead of `NormalForm sig 1 4`).

**What is genuinely depth-independent** (reused verbatim from the frozen public layer, already
in this module's transitive import closure via `ExteriorFiberK → ExteriorBracketK → …`):
the possible-zones list and the zone-classification theorem are pure `ZoneSpec 4` geometry over
the four base anchors `[x1, w, x, t]` — no dependence on the fold depth `k`. `kvE_futPossibleZones`
and `kvE_futZoneClass` are therefore thin depth-`k` surfaces over the frozen `kvE2_*` decls.

**What must be reformulated at depth `k`** (postmortem rule 1; guard G6): the admissibility
predicate. The frozen `kvE2_futAdmissible` reads quant bits through `nf0_assemble`, which is
lossless ONLY at depth 0 (NfEFold.lean:549-561). At depth `k` every such read is replaced by the
landed determinacy-core channel `kvE_subBit` (ExteriorBracketK.lean:302) / the Phase-2 fiber
navigation (`kvE_fiber`, `kvE_fiber_dropFresh` — ExteriorFiberK.lean), which reads σ's quant
layer fiber-existentially at FULL arity. Admissibility bits are a NAVIGATION channel (G6:
zone classification + admissibility bucketing), never a content source; clause content is
rendered downstream (Phase 3.2/3.3) via `kvE_fiberPosOn P` on the full fiber elements.

Purely additive NEW leaf module; no frozen file is touched (postmortem rule 5); the landed
determinacy core (ExteriorBracketK) and the FROZEN Phase-2 fiber interface (ExteriorFiberK) are
consumed unchanged (postmortem rule 6). -/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-! ## Zone classification at the exterior anchor (depth-independent geometry)

The point's zone over the four base anchors `[x1, w, x, t]` (with `x < w < t < x1`) is one of
nine order-possible specs. This is pure `ZoneSpec 4` model geometry — the fold depth `k` of the
sub plays no role — so the depth-`k` surface is the frozen public decl itself. -/

/-- **Depth-`k` possible zones** at exterior `x1`: the nine `ZoneSpec 4` specs an actual point
    can carry relative to `[x1, w, x, t]` with `x < w < t < x1`. Definitionally the frozen
    `kvE2_futPossibleZones` (ExteriorNegation.lean:902) — pure geometry, depth-independent. -/
def kvE_futPossibleZones : List (ZoneSpec 4) := kvE2_futPossibleZones

/-- **Depth-`k` zone-4 classification at exterior `x1`**: any point's `zoneHolds` spec over
    `[x1, w, x, t]` (with `x < w < t < x1`) is one of the nine possible zones. Reuses the frozen
    public `kvE2_futZoneClass` (ExteriorNegation.lean:915) — the statement mentions no fold
    depth, so it is the depth-`k` fact verbatim. -/
theorem kvE_futZoneClass {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (v x1 w x t : M.carrier)
    (hxw : x < w) (hwt : w < t) (htx1 : t < x1)
    (zs : ZoneSpec 4)
    (hz : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) zs v) :
    zs ∈ kvE_futPossibleZones :=
  kvE2_futZoneClass M v x1 w x t hxw hwt htx1 zs hz

/-! ## Syntactic order-admissibility (depth-`k`, fiber-navigated)

The depth-`k` reformulation of the frozen `kvE2_futAdmissible` (ExteriorNegation.lean:983). The
frozen predicate reads quant bits through `nf0_assemble`, which is lossless ONLY at depth 0; at
depth `k` every such read is replaced by the landed determinacy channel `kvE_subBit`
(ExteriorBracketK.lean:302) or the Phase-2 fiber navigation (`kvE_fiber` — ExteriorFiberK.lean),
which read σ's quant layer fiber-existentially at FULL arity (G6: navigation only). -/

/-- The **self zone** at exterior `x1`: the fresh point coincides with `x1` itself
    (head coupling `(false, false)` over the base future marking `kvE2_sep_zFutT3`).
    A model point realizes this zone iff it equals `x1` (both order couplings vacuous). -/
def kvE_futSelfZone : ZoneSpec 4 := Fin.cons (false, false) kvE2_sep_zFutT3

/-- **Order-admissibility of `σ`** (depth-`k`, syntactic, model-independent): the conjunction of
    the conditions a realizer at exterior `x1` FORCES on `σ : NormalForm sig (k+1) 4` —

    1. `zFutT3` zone marking of the atom base layer (`σ.1 : NormalForm sig 0 4`);
    2. off-fiber quant bits false (every bit-true full-arity sub sits on `σ`'s atom fiber);
    3. quant bits false on every order-impossible zone-4 spec (via the `kvE_subBit`
       determinacy channel — no `nf0_assemble`, postmortem rule 1);
    4. the self-zone fresh profile is well-defined (all self-zone-prescribed depth-`k` profiles
       coincide) — the depth-`k` faithful replacement for the frozen "self-zone carves exactly the
       fresh profile", since at depth `k` the endpoint profile is fiber-borne (`nfk_projFresh s :
       NormalForm sig k 1`), not a `σ.1` marginal (`σ.1` is the depth-0 atom layer).

    Conjuncts 2-4 read `σ.2`/`kvE_subBit` for admissibility bucketing only (G6); clause content
    is rendered downstream (Phase 3.2/3.3) via `kvE_fiberPosOn P` on the full fiber elements. -/
noncomputable def kvE_futAdmissible {sig : MonadicSignature} {k : Nat}
    (σ : NormalForm sig (k + 1) 4) : Bool :=
  decide (nf0_zoneSpec σ.1 = kvE2_sep_zFutT3) &&
  ((Finset.univ.toList (α := NormalForm sig k 5)).all fun s =>
    decide (nfk_dropFresh s = σ.1) || !(σ.2 s)) &&
  ((Finset.univ.toList (α := ZoneSpec 4)).all fun zs4 =>
    (kvE_futPossibleZones.any fun z => decide (zs4 = z)) ||
    ((Finset.univ.toList (α := NormalForm sig k 1)).all fun χ =>
      !(kvE_subBit σ zs4 χ))) &&
  ((Finset.univ.toList (α := NormalForm sig k 1)).all fun χ =>
    (Finset.univ.toList (α := NormalForm sig k 1)).all fun χ' =>
      !(kvE_subBit σ kvE_futSelfZone χ) || !(kvE_subBit σ kvE_futSelfZone χ') ||
        decide (χ = χ'))

/-- A realizer's fresh point carries `σ`'s atom-layer fresh profile (depth-0 read — the same
    statement as the frozen `kvE2_futFreshProfile`, ExteriorNegation.lean:996, since `σ.1` is the
    depth-0 atom layer at every fold depth). The full depth-`k` endpoint profile is fiber-borne
    (`nfk_projFresh` on the self-zone fiber bucket) and is assembled downstream in Phase 3.2. -/
theorem kvE_futFreshProfile {sig : MonadicSignature} {k : Nat}
    (M : OrderedMonadicStructure sig) (σ : NormalForm sig (k + 1) 4)
    (x1 w x t : M.carrier)
    (hatomσ : ∀ a : AtomKind sig 4,
      atom_eval M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) a ↔ σ.1 a = true) :
    nf_eval_nf M 0 1 (fun _ => x1) (nf0_projFresh σ.1) := by
  intro a
  match a with
  | .pred p i =>
    have hi : i = 0 := Subsingleton.elim i 0
    subst hi
    have h := hatomσ (.pred p 0)
    simpa only [atom_eval, Fin.cons_zero, nf0_projFresh] using h
  | .order i j h => exact absurd (Subsingleton.elim i j) h

/-- **A realizer forces admissibility**: if some exterior `x1 > t` realizes `σ` over
    `[x1, w, x, t]` (with `x < w < t`), then `σ` is order-admissible. Mirrors the frozen
    `kvE2_futRealizer_admissible` (ExteriorNegation.lean:1010) one fold-layer deeper: the atom
    channels (conjunct 1) are the same depth-0 reads; the quant channels (conjuncts 2-4) go
    through the landed `kvE_subBit_iff` / fold off-fiber clause instead of `nf0_assemble`. -/
theorem kvE_futRealizer_admissible {sig : MonadicSignature} {k : Nat}
    (M : OrderedMonadicStructure sig) (σ : NormalForm sig (k + 1) 4)
    (x1 w x t : M.carrier) (hxw : x < w) (hwt : w < t) (htx1 : t < x1)
    (hnf : nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    kvE_futAdmissible σ = true := by
  obtain ⟨⟨hA, -⟩, hoff⟩ := (nf_eval_nfk_iff_efold M _ σ).mp hnf
  -- hA : nf_eval_nf M 0 4 env σ.1  (definitionally: ∀ a, atom_eval M env a ↔ σ.1 a = true)
  -- hoff : ∀ s, nfk_dropFresh s ≠ σ.1 → σ.2 s = false
  rw [kvE_futAdmissible]
  simp only [Bool.and_eq_true]
  refine ⟨⟨⟨?_, ?_⟩, ?_⟩, ?_⟩
  · -- (1) zone marking: atom layer forced to zFutT3 (x1 above all of w, x, t)
    refine decide_eq_true ?_
    funext i
    have hgt : (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) i < x1 := by
      match i with
      | ⟨0, _⟩ => exact hwt.trans htx1
      | ⟨1, _⟩ => exact (hxw.trans hwt).trans htx1
      | ⟨2, _⟩ => exact htx1
    rw [kvE2_zoneBit_above M x1 (Fin.cons w (Fin.cons x (fun _ => t))) σ.1 hA i hgt]
    match i with
    | ⟨0, _⟩ => rfl
    | ⟨1, _⟩ => rfl
    | ⟨2, _⟩ => rfl
  · -- (2) off-fiber bits false
    rw [List.all_eq_true]
    intro s _
    by_cases hs : nfk_dropFresh s = σ.1
    · rw [decide_eq_true hs, Bool.true_or]
    · rw [hoff s hs, Bool.not_false, Bool.or_true]
  · -- (3) order-impossible zone bits false
    rw [List.all_eq_true]
    intro zs4 _
    by_cases hzp : ∃ z ∈ kvE_futPossibleZones, zs4 = z
    · obtain ⟨z, hzmem, hzeq⟩ := hzp
      rw [Bool.or_eq_true]
      exact Or.inl (List.any_eq_true.mpr ⟨z, hzmem, decide_eq_true hzeq⟩)
    · rw [Bool.or_eq_true]
      refine Or.inr ?_
      rw [List.all_eq_true]
      intro χ _
      cases hb : kvE_subBit σ zs4 χ with
      | false => rfl
      | true =>
        obtain ⟨v, hzv, -⟩ := (kvE_subBit_iff M _ σ hnf zs4 χ).mp hb
        exact absurd ⟨zs4, kvE_futZoneClass M v x1 w x t hxw hwt htx1 zs4 hzv, rfl⟩ hzp
  · -- (4) self-zone profile uniqueness
    rw [List.all_eq_true]
    intro χ _
    rw [List.all_eq_true]
    intro χ' _
    by_cases hbχ : kvE_subBit σ kvE_futSelfZone χ = true
    · by_cases hbχ' : kvE_subBit σ kvE_futSelfZone χ' = true
      · obtain ⟨v, hzv, hvχ⟩ := (kvE_subBit_iff M _ σ hnf kvE_futSelfZone χ).mp hbχ
        obtain ⟨v', hzv', hv'χ'⟩ := (kvE_subBit_iff M _ σ hnf kvE_futSelfZone χ').mp hbχ'
        have hvx1 : v = x1 := by
          have h0 := hzv 0
          have hn1 : ¬ v < x1 := fun hlt => absurd (h0.1.mp hlt) Bool.false_ne_true
          have hn2 : ¬ x1 < v := fun hlt => absurd (h0.2.mp hlt) Bool.false_ne_true
          exact le_antisymm (not_lt.mp hn2) (not_lt.mp hn1)
        have hv'x1 : v' = x1 := by
          have h0 := hzv' 0
          have hn1 : ¬ v' < x1 := fun hlt => absurd (h0.1.mp hlt) Bool.false_ne_true
          have hn2 : ¬ x1 < v' := fun hlt => absurd (h0.2.mp hlt) Bool.false_ne_true
          exact le_antisymm (not_lt.mp hn2) (not_lt.mp hn1)
        rw [hvx1] at hvχ
        rw [hv'x1] at hv'χ'
        have hχχ' : χ = χ' := nf_eval_unique M k 1 (fun _ => x1) χ χ' hvχ hv'χ'
        rw [hbχ, hbχ', hχχ']
        simp
      · rw [Bool.not_eq_true] at hbχ'
        rw [hbχ']
        simp
    · rw [Bool.not_eq_true] at hbχ
      rw [hbχ]
      simp

end Bimodal.Metalogic.WeakCanonical.Kamp
