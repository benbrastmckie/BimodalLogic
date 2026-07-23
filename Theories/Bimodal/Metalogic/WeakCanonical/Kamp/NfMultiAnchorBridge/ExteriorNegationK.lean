import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorFiberK
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorFiberConsistencyK

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
open Bimodal.Metalogic.WeakCanonical.Separation
  (formula_conjList formula_conjList_iff formula_disjList formula_disjList_iff)

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
theorem kvE_futZoneClass {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
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
    2. every bit-true full-arity sub sits on `σ`'s atom fiber AND is depth-graded
       fiber-consistent (`kvE_fiberElemConsistent`, task 363: the D7 repair — the guard reads
       the sub's depth-≥1 inner `.2` marking, which no other channel reads; trivially true at
       `k = 0`, so the frozen m = 0 layer is untouched);
    3. quant bits false on every order-impossible zone-4 spec (via the `kvE_subBit`
       determinacy channel — no `nf0_assemble`, postmortem rule 1);
    4. the self-zone fresh profile is well-defined (all self-zone-prescribed depth-`k` profiles
       coincide) — the depth-`k` faithful replacement for the frozen "self-zone carves exactly the
       fresh profile", since at depth `k` the endpoint profile is fiber-borne (`nfk_projFresh s :
       NormalForm sig k 1`), not a `σ.1` marginal (`σ.1` is the depth-0 atom layer).

    Conjuncts 2-4 read `σ.2`/`kvE_subBit` for admissibility bucketing only (G6); clause content
    is rendered downstream (Phase 3.2/3.3) via `kvE_fiberPosOn P` on the full fiber elements.
    The task-363 consistency guard lives INSIDE conjunct 2's body (not as a fifth top-level
    conjunct) so every existing 4-conjunct destructuring — including the frozen m = 0 supply
    proofs — keeps its access paths. -/
noncomputable def kvE_futAdmissible {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (σ : NormalForm sig (k + 1) 4) : Bool :=
  decide (nf0_zoneSpec σ.1 = kvE2_sep_zFutT3) &&
  ((Finset.univ.toList (α := NormalForm sig k 5)).all fun s =>
    (decide (nfk_dropFresh s = σ.1) && kvE_fiberElemConsistent σ s) || !(σ.2 s)) &&
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
theorem kvE_futFreshProfile {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
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
theorem kvE_futRealizer_admissible {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
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
  · -- (2) marked subs are on-fiber AND fiber-consistent (task 363 conjunct)
    rw [List.all_eq_true]
    intro s _
    rw [Bool.or_eq_true]
    by_cases hb : σ.2 s = true
    · refine Or.inl ?_
      rw [Bool.and_eq_true]
      by_cases hs : nfk_dropFresh s = σ.1
      · refine ⟨decide_eq_true hs, ?_⟩
        obtain ⟨v, hv⟩ := (hnf.2 s).mpr hb
        exact kvE_fiberElemConsistent_of_realized M _ v σ s hnf hv
      · exact absurd hb (by rw [hoff s hs]; exact Bool.false_ne_true)
    · exact Or.inr (by rw [Bool.not_eq_true] at hb; rw [hb]; rfl)
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

/-! ## Generic model-side `D`-guarded `Until`-chain combinators (Cor 5.4 / Lemma 5.3 `O_n`)

Depth-`k` faithful generalization of the frozen `kvE2_futChain`/`kvE2_futChainBuild`/
`kvE2_futChainDestruct` (ExteriorNegation.lean:1108/1180/1435). The frozen versions HARDWIRE the
per-visited-item content formula to `nf_depth0_char_formula` (the depth-0 profile pin, which is
F2-DEAD at depth `k` — postmortem rule 3). Here the per-item rendering `itemF` and the
model-side occurrence predicate `Q` are ABSTRACT parameters, with the chain's distinctness
invariant `huniq` (frozen: `nf_profile_unique`) supplied by the caller. This keeps the Cor 5.4
`O_n` device faithful to the paper (`hD`/`hend`/min-pick sort are the paper's steps, no
`simp`/`omega` shortcut — guard G5) while the depth-`k` Future clause layer routes content
through `kvE_fiberPosOn P` (`itemF := P.existF 4` over fiber elements — G6). -/

/-- Abstract `D`-guarded `Until` chain over a list of items, each rendered by `itemF` and visited
    in order, terminating in `endF`. The generalization of `kvE2_futChain`
    (ExteriorNegation.lean:1108): `itemF` replaces the hardwired `nf_depth0_char_formula`. -/
noncomputable def kvE_futChainG {α : Type}
    (itemF : α → Formula) (endF D : Formula) : List α → Formula
  | [] => Formula.untl endF D
  | a :: rest =>
      Formula.untl
        (formula_conjList [itemF a, kvE_futChainG itemF endF D rest])
        D

/-- **Chain construction** (generic port of `kvE2_futChainBuild`, ExteriorNegation.lean:1180):
    from a `D`-uniform gap `(t, x1)`, an endpoint `endF` at `x1`, one occurrence in `(s, x1)`
    for each item in a nodup list `L` (via `Q`), the fact that occurrences force `itemF`
    (`hQF`), and item distinctness at a shared point (`huniq`), SOME permutation of `L` carries
    a true `D`-guarded chain at `s`. Min-witness sort via the shared `kvE_minPick`. -/
theorem kvE_futChainBuildG {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {α : Type} [DecidableEq α]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (itemF : α → Formula) (endF D : Formula) (t x1 : M.carrier)
    (Q : α → M.carrier → Prop)
    (hQF : ∀ a : α, ∀ r : M.carrier, Q a r → temporal_truth M atomMap r (itemF a))
    (huniq : ∀ (a a' : α) (r : M.carrier), Q a r → Q a' r → a = a')
    (hD : ∀ r : M.carrier, t < r → r < x1 → temporal_truth M atomMap r D)
    (hend : temporal_truth M atomMap x1 endF) :
    ∀ (n : Nat) (L : List α), L.length ≤ n → L.Nodup →
      ∀ s : M.carrier, s < x1 → (∀ r : M.carrier, s < r → t < r) →
      (∀ a ∈ L, ∃ r : M.carrier, s < r ∧ r < x1 ∧ Q a r) →
      ∃ l : List α, l.Perm L ∧
        temporal_truth M atomMap s (kvE_futChainG itemF endF D l) := by
  intro n
  induction n with
  | zero =>
    intro L hlen _ s hsx1 hbound _
    have hL : L = [] := by
      cases L with
      | nil => rfl
      | cons a l => simp at hlen
    subst hL
    refine ⟨[], List.Perm.refl [], ?_⟩
    simp only [kvE_futChainG]
    exact ⟨x1, hsx1, hend, fun r hsr hrx1 => hD r (hbound r hsr) hrx1⟩
  | succ n ih =>
    intro L hlen hnd s hsx1 hbound hocc
    by_cases hL : L = []
    · subst hL
      refine ⟨[], List.Perm.refl [], ?_⟩
      simp only [kvE_futChainG]
      exact ⟨x1, hsx1, hend, fun r hsr hrx1 => hD r (hbound r hsr) hrx1⟩
    · obtain ⟨a₀, ha₀mem, r₀, ⟨hsr₀, hr₀x1, hQ₀⟩, hmin⟩ :=
        kvE_minPick M
          (fun a r => s < r ∧ r < x1 ∧ Q a r) L hL hocc
      have htr₀ : t < r₀ := hbound r₀ hsr₀
      have hlen' : (L.erase a₀).length ≤ n := by
        have h1 := List.length_erase_of_mem ha₀mem
        have h2 : 0 < L.length := List.length_pos_of_mem ha₀mem
        omega
      obtain ⟨l', hl'perm, hl'truth⟩ := ih (L.erase a₀) hlen' (hnd.erase a₀) r₀ hr₀x1
        (fun r hr => htr₀.trans hr)
        (fun a ha => by
          obtain ⟨hne, haL⟩ := (List.Nodup.mem_erase_iff hnd).mp ha
          obtain ⟨r, ⟨_, hrx1, hQr⟩, hger⟩ := hmin a haL
          refine ⟨r, lt_of_le_of_ne hger ?_, hrx1, hQr⟩
          intro he
          exact hne (huniq a a₀ r hQr (he ▸ hQ₀)))
      refine ⟨a₀ :: l', (hl'perm.cons a₀).trans (List.perm_cons_erase ha₀mem).symm, ?_⟩
      simp only [kvE_futChainG]
      refine ⟨r₀, hsr₀, ?_,
        fun r hsr hrr₀ => hD r (hbound r hsr) (hrr₀.trans hr₀x1)⟩
      rw [formula_conjList_iff]
      intro f hf
      simp only [List.mem_cons, List.not_mem_nil, or_false] at hf
      rcases hf with rfl | rfl
      · exact hQF a₀ r₀ hQ₀
      · exact hl'truth

/-- **Chain destruction** (generic port of `kvE2_futChainDestruct`,
    ExteriorNegation.lean:1435): a true `D`-guarded chain at `s` yields an endpoint `x1 > s`
    satisfying `endF`, a `D`-uniform gap `(s, x1)` (given each visited item's `itemF` pointwise
    implies `D` via `himp`), and one `itemF`-occurrence in `(s, x1)` for every item in the
    chain's list. -/
theorem kvE_futChainDestructG {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {α : Type}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (itemF : α → Formula) (endF D : Formula) :
    ∀ (l : List α) (s : M.carrier),
      (∀ a ∈ l, ∀ r : M.carrier,
        temporal_truth M atomMap r (itemF a) → temporal_truth M atomMap r D) →
      temporal_truth M atomMap s (kvE_futChainG itemF endF D l) →
      ∃ x1 : M.carrier, s < x1 ∧ temporal_truth M atomMap x1 endF ∧
        (∀ r : M.carrier, s < r → r < x1 → temporal_truth M atomMap r D) ∧
        (∀ a ∈ l, ∃ r : M.carrier, s < r ∧ r < x1 ∧
          temporal_truth M atomMap r (itemF a)) := by
  intro l
  induction l with
  | nil =>
    intro s _ hch
    simp only [kvE_futChainG] at hch
    obtain ⟨x1, hsx1, hend, hgap⟩ := hch
    exact ⟨x1, hsx1, hend, hgap, by simp⟩
  | cons a rest ih =>
    intro s himp hch
    simp only [kvE_futChainG] at hch
    obtain ⟨r₀, hsr₀, hconj, hgap1⟩ := hch
    rw [formula_conjList_iff] at hconj
    have hitemr₀ : temporal_truth M atomMap r₀ (itemF a) := hconj _ (by simp)
    have hrest : temporal_truth M atomMap r₀ (kvE_futChainG itemF endF D rest) :=
      hconj _ (by simp)
    obtain ⟨x1, hr₀x1, hend, hgap2, hocc⟩ :=
      ih r₀ (fun a' ha' => himp a' (List.mem_cons_of_mem a ha')) hrest
    refine ⟨x1, hsr₀.trans hr₀x1, hend, ?_, ?_⟩
    · intro r hsr hrx1
      rcases lt_trichotomy r r₀ with hlt | heq | hgt
      · exact hgap1 r hsr hlt
      · exact heq ▸ himp a List.mem_cons_self r₀ hitemr₀
      · exact hgap2 r hgt hrx1
    · intro a' ha'
      rcases List.mem_cons.mp ha' with rfl | hmem
      · exact ⟨r₀, hsr₀, hr₀x1, hitemr₀⟩
      · obtain ⟨r, hr₀r, hrx1, hitem⟩ := hocc a' hmem
        exact ⟨r, hsr₀.trans hr₀r, hrx1, hitem⟩

/-! ## The depth-`k` Future clause family (content via `kvE_fiberPosOn P`, G6)

The depth-`k` analogs of the frozen clause defs `kvE2_futGapD`/`RayD`/`RayForm`/`End`/`Chain`/
`Pos`/`extNegFut` (ExteriorNegation.lean:1072–1140). Every content-bearing position renders
`P.existF 4` over FULL fiber elements `s : NormalForm sig k 5` through `kvE_fiberPosOn P`
(postmortem rule 3 / guard G6) — never a marginal characteristic formula. The visited-item
universe is swapped from the depth-0 profile universe (`kvE2_futGapList`/`RayList`) to the
Phase-2 fiber zone lists (`kvE_fiberZoneList σ zs4`), keyed by the Future gap head-coupling
`(true,false)`, ray `(false,true)`, and self `(false,false)` over `kvE2_sep_zFutT3`. The chain
device is the generic `kvE_futChainG` from the previous section (Cor 5.4 `O_n`, faithful). -/

/-- The Future **gap zone** spec `(t, x1)`: head coupling `(true, false)` over the base future
    marking (the point lies strictly below `x1`, strictly above `t`). -/
def kvE_futGapZone : ZoneSpec 4 := Fin.cons (true, false) kvE2_sep_zFutT3

/-- The Future **ray zone** spec `(x1, ∞)`: head coupling `(false, true)` over the base future
    marking (the point lies strictly above `x1`). -/
def kvE_futRayZone : ZoneSpec 4 := Fin.cons (false, true) kvE2_sep_zFutT3

/-- **Shifted item content** (depth-`k`, blocker-resolution): the canonical-expansion image of a
    fiber element `s` re-anchored so the model point plays the FRESH (index-0) fold role rather than
    the `P.existF 4` endpoint (index-4) role. Rabinovich Cor 5.4(2) re-anchoring (report 02,
    Deliverable 2): `temporal_truth r (kvE_futItemShift P s) ↔ ∃ env, nf_eval (Fin.cons r env) s`,
    i.e. `r` at index 0 — exactly σ's fold-slot convention (`nf_eval_efold_k`). Every interior
    gap/ray content position renders through this so the chain's walked points match σ's realizers. -/
noncomputable def kvE_futItemShift {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k) (s : NormalForm sig k 5) : Formula :=
  P.existF 4 (renameNF rot5Fwd rot5Bwd s)

/-- **Gap guard `D`** (depth-`k`): the full-fiber content disjunction over σ's gap-zone fiber
    elements — the shifted-`P.existF 4` analog of the frozen `kvE2_futGapD` (:1072). Empty gap
    bucket gives `⊥` (the "no gap points" guard). Content channel = `kvE_fiberPosOnShift P` (G6),
    re-anchored so gap points sit at the FRESH fold slot (Cor 5.4(2), report 02). -/
noncomputable def kvE_futGapD {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k) (σ : NormalForm sig (k + 1) 4) : Formula :=
  kvE_fiberPosOnShift P (kvE_fiberZoneList σ kvE_futGapZone)

/-- **Ray disjunction** (depth-`k`): the full-fiber content disjunction over σ's ray-zone fiber
    elements. Shifted-`P.existF 4` analog of `kvE2_futRayD` (:1079); ray points sit at the FRESH
    fold slot (Cor 5.4(2) re-anchoring, report 02). -/
noncomputable def kvE_futRayD {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k) (σ : NormalForm sig (k + 1) 4) : Formula :=
  kvE_fiberPosOnShift P (kvE_fiberZoneList σ kvE_futRayZone)

/-- **Exact-ray-content form** at the endpoint (depth-`k` analog of `kvE2_futRayForm`, :1088):
    every future point carries a ray fiber element (`¬F(¬D_ray)`), and each ray fiber element
    occurs (`F(P.existF 4 s)` for each `s` in the ray zone list). Content channel throughout. -/
noncomputable def kvE_futRayForm {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k) (σ : NormalForm sig (k + 1) 4) : Formula :=
  formula_conjList
    ((Formula.untl (kvE_futRayD P σ).neg Formula.top).neg ::
      (kvE_fiberZoneList σ kvE_futRayZone).map fun s =>
        Formula.untl (kvE_futItemShift P s) Formula.top)

/-- **Endpoint description** at `x1` (depth-`k` analog of `kvE2_futEnd`, :1098): the self-zone
    fiber content (the endpoint's own full-fiber realization, at the self zone
    `kvE_futSelfZone`) together with the exact ray content. The self-zone list carries a single
    fresh profile under admissibility (conjunct 4 uniqueness), so it IS the self bucket. -/
noncomputable def kvE_futEnd {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k) (σ : NormalForm sig (k + 1) 4) : Formula :=
  formula_conjList
    [kvE_fiberPosOnShift P (kvE_fiberZoneList σ kvE_futSelfZone),
     kvE_futRayForm P σ]

/-- **`D`-guarded `Until` chain** over a list of gap fiber elements (depth-`k` analog of
    `kvE2_futChain`, :1108): the generic `kvE_futChainG` instantiated with `itemF := P.existF 4`,
    the endpoint description, and the gap guard `D`. -/
noncomputable def kvE_futChain {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k) (σ : NormalForm sig (k + 1) 4)
    (l : List (NormalForm sig k 5)) : Formula :=
  kvE_futChainG (kvE_futItemShift P) (kvE_futEnd P σ) (kvE_futGapD P σ) l

/-- **Positive local-existence form** for σ (depth-`k` analog of `kvE2_futPos`, :1124):
    admissibility-gated disjunction over the permutations of σ's gap-zone fiber list of
    `D`-guarded chains ending in the endpoint description. Inadmissible σ gives `⊥` (sound
    because such σ has no exterior realizer — `kvE_futRealizer_admissible`). -/
noncomputable def kvE_futPos {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k) (σ : NormalForm sig (k + 1) 4) : Formula :=
  if kvE_futAdmissible σ = true then
    formula_disjList ((kvE_fiberZoneList σ kvE_futGapZone).permutations.map
      (kvE_futChain P σ))
  else Formula.bot

/-- **The Future-side complement clause family** (depth-`k`, the Phase-2 BINDING signature
    analog of `kvE2_extNegFut`, :1136): the negation of the positive local-existence form. -/
noncomputable def kvE_extNegFut {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k) (σ : NormalForm sig (k + 1) 4) : Formula :=
  (kvE_futPos P σ).neg

/-! ## Content-channel and navigation glue (blocker-resolution consumption)

The three leaf facts the depth-`k` `_sound`/`_complete` reduce their content obligation to:
the shifted-item correctness (Cor 5.4(2) re-anchoring via `kvE_anchorBridge`), the atom-layer
zone read-back (`nf_eval` at a fresh witness pins the witness's zone), and the fiber-zone-list
population (a realizer + a zoned point yields a listed fiber sub realized at that point). The
zone read-back is intrinsically side-agnostic; the Future-prefixed name avoids a same-namespace
clash with the Past mirror at final assembly. -/

/-- **Shifted-item correctness** (Cor 5.4(2), report 02 Deliverable 2): on Prior (UZ/SZ)
    structures the re-anchored content `kvE_futItemShift P s` holds at `r` iff `s` is realized
    with `r` as the FRESH (index-0) fold witness — `P.correct 4` composed with `kvE_anchorBridge`. -/
theorem kvE_futItemShift_correct {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k) (s : NormalForm sig k 5)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (r : M.carrier) :
    temporal_truth M atomMap r (kvE_futItemShift P s) ↔
      ∃ env : Fin 4 → M.carrier, nf_eval_nf M k 5 (Fin.cons r env) s := by
  rw [kvE_futItemShift, P.correct 4 _ M h_UZ h_SZ r]
  exact exists_congr fun env => kvE_anchorBridge M env r s

/-- **Gap/ray/self zone construction at exterior `x1`** (Future-named replica of the frozen
    private `kvE2_futZone4_of_above`, ExteriorNegation.lean:311): a point `v > t` sits in the
    zone-4 spec `Fin.cons p0 kvE2_sep_zFutT3` whose head coupling `p0` records `v`'s relation to
    the exterior anchor `x1`. -/
theorem kvE_futZone4_of_above {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (v x1 w x t : M.carrier)
    (hxw : x < w) (hwt : w < t) (htv : t < v)
    (p0 : Bool × Bool)
    (h0a : v < x1 ↔ p0.1 = true) (h0b : x1 < v ↔ p0.2 = true) :
    zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
      (Fin.cons p0 kvE2_sep_zFutT3) v := by
  intro i
  match i with
  | ⟨0, _⟩ => exact ⟨h0a, h0b⟩
  | ⟨1, _⟩ =>
    exact ⟨iff_of_false (lt_asymm (hwt.trans htv)) Bool.false_ne_true,
           iff_of_true (hwt.trans htv) rfl⟩
  | ⟨2, _⟩ =>
    exact ⟨iff_of_false (lt_asymm ((hxw.trans hwt).trans htv)) Bool.false_ne_true,
           iff_of_true ((hxw.trans hwt).trans htv) rfl⟩
  | ⟨3, _⟩ =>
    exact ⟨iff_of_false (lt_asymm htv) Bool.false_ne_true, iff_of_true htv rfl⟩

/-- **Atom-layer zone read-back** (Future-named copy of the side-agnostic navigation leaf; the
    read-back steps of `kvE_subBit_iff`, ExteriorBracketK.lean:332): a depth-`k` sub `s` realized
    at a witness `v` over `env` sits in the zone `nfk_zoneSpec s` of `v` relative to `env`. -/
theorem kvE_futZoneHolds_of_atom {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (M : OrderedMonadicStructure sig) (env : Fin 4 → M.carrier) (v : M.carrier)
    (s : NormalForm sig k 5)
    (hv : nf_eval_nf M k 5 (Fin.cons v env) s) :
    zoneHolds M env (nfk_zoneSpec s) v := by
  have hatom5 := nf_eval_nf_atom_layer M (Fin.cons v env) s hv
  intro i
  have h1 := hatom5 (.order 0 i.succ (Fin.succ_ne_zero i).symm)
  have h2 := hatom5 (.order i.succ 0 (Fin.succ_ne_zero i))
  simp only [atom_eval, Fin.cons_zero, Fin.cons_succ] at h1 h2
  exact ⟨h1, h2⟩

/-- **Fiber-zone-list population** (the `_sound`-direction content producer; mirrors the backward
    half of `kvE_subBit_iff`, ExteriorBracketK.lean:345): under a realized σ, any point `v` in
    zone `zs4` of `env` is realized by SOME listed fiber sub `s ∈ kvE_fiberZoneList σ zs4` at the
    fresh slot `Fin.cons v env`. The sub is `v`'s own characteristic; its zone/atom-fiber labels
    are read straight off the realized atom layer (navigation only, G6). -/
theorem kvE_fiberZoneList_realized {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (M : OrderedMonadicStructure sig) (env : Fin 4 → M.carrier)
    (σ : NormalForm sig (k + 1) 4)
    (hσ : nf_eval_nf M (k + 1) 4 env σ)
    (zs4 : ZoneSpec 4) (v : M.carrier) (hz : zoneHolds M env zs4 v) :
    ∃ s ∈ kvE_fiberZoneList σ zs4, nf_eval_nf M k 5 (Fin.cons v env) s := by
  obtain ⟨⟨hA, hfib⟩, -⟩ := (nf_eval_nfk_iff_efold M env σ).mp hσ
  set s : NormalForm sig k 5 := nf_characteristic M k 5 (Fin.cons v env) with hs
  have hsat : nf_eval_nf M k 5 (Fin.cons v env) s :=
    hs ▸ nf_characteristic_satisfies M k 5 (Fin.cons v env)
  have hatom5 : ∀ a, atom_eval M (Fin.cons v env) a ↔ s.atom_assgn a = true :=
    nf_eval_nf_atom_layer M (Fin.cons v env) s hsat
  have hd : nfk_dropFresh s = σ.1 := by
    have hfac := (nf_eval_nf0_cons_factor M env v s.atom_assgn).mp
      (nf_eval_nf_atom_layer M (Fin.cons v env) s hsat)
    exact nf_eval_unique M 0 4 env _ σ.1 hfac.2.2 hA
  have hbit : σ.2 s = true := (hfib s hd).mp ⟨v, hsat⟩
  have hzone : nfk_zoneSpec s = zs4 := by
    funext i
    have hzi := hz i
    have h1 := hatom5 (.order 0 i.succ (Fin.succ_ne_zero i).symm)
    have h2 := hatom5 (.order i.succ 0 (Fin.succ_ne_zero i))
    show (s.atom_assgn (.order 0 i.succ (Fin.succ_ne_zero i).symm),
          s.atom_assgn (.order i.succ 0 (Fin.succ_ne_zero i))) = zs4 i
    exact Prod.ext (Bool.eq_iff_iff.mpr (h1.symm.trans hzi.1))
      (Bool.eq_iff_iff.mpr (h2.symm.trans hzi.2))
  exact ⟨s, (kvE_fiberZoneList_mem σ zs4 s).mpr ⟨hbit, hzone⟩, hsat⟩

/-! ## Soundness of the depth-`k` Future clause family (Cor 5.4(2), ⟹) -/

/-- **Soundness** (depth-`k` analog of `kvE2_extNegFut_sound`, ExteriorNegation.lean:1243, one
    fold-layer deeper): if the complement clause holds at `t` (with `x < w < t`), then NO exterior
    `x1 > t` realizes σ over `[x1, w, x, t]`. Content routed through the shifted channel: gap/ray/
    self obligations discharge via `kvE_fiberPosOnShift_correct` / `kvE_futItemShift_correct` +
    `kvE_anchorBridge`, supplying σ's own realizer environment `[x1, w, x, t]` (report 02, Cor
    5.4(2) re-anchoring). The Cor 5.4 `O_n` chain is the generic `kvE_futChainBuildG`. -/
theorem kvE_extNegFut_sound {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (σ : NormalForm sig (k + 1) 4)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (hcl : temporal_truth M atomMap t (kvE_extNegFut P σ)) :
    ∀ x1 : M.carrier, t < x1 →
      ¬ nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  intro x1 htx1 hnf
  have hadm : kvE_futAdmissible σ = true :=
    kvE_futRealizer_admissible M σ x1 w x t hxw hwt htx1 hnf
  -- σ's fold layer: atom + on-fiber existential biconditional
  obtain ⟨⟨hA, hfib⟩, -⟩ :=
    (nf_eval_nfk_iff_efold M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ).mp hnf
  -- the gap `(t, x1)` is uniformly `D` (shifted gap content)
  have hD : ∀ r : M.carrier, t < r → r < x1 →
      temporal_truth M atomMap r (kvE_futGapD P σ) := by
    intro r htr hrx1
    rw [kvE_futGapD, kvE_fiberPosOnShift_correct P _ M h_UZ h_SZ r]
    have hz : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
        kvE_futGapZone r :=
      kvE_futZone4_of_above M r x1 w x t hxw hwt htr (true, false)
        (iff_of_true hrx1 rfl) (iff_of_false (lt_asymm hrx1) Bool.false_ne_true)
    obtain ⟨s, hsmem, hsrel⟩ :=
      kvE_fiberZoneList_realized M _ σ hnf kvE_futGapZone r hz
    exact ⟨s, hsmem, _, hsrel⟩
  -- endpoint description at `x1`
  have hend : temporal_truth M atomMap x1 (kvE_futEnd P σ) := by
    rw [kvE_futEnd, formula_conjList_iff]
    intro f hf
    simp only [List.mem_cons, List.not_mem_nil, or_false] at hf
    rcases hf with rfl | rfl
    · -- self-zone content at `x1`
      rw [kvE_fiberPosOnShift_correct P _ M h_UZ h_SZ x1]
      have hz : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
          kvE_futSelfZone x1 :=
        kvE_futZone4_of_above M x1 x1 w x t hxw hwt htx1 (false, false)
          (iff_of_false (lt_irrefl x1) Bool.false_ne_true)
          (iff_of_false (lt_irrefl x1) Bool.false_ne_true)
      obtain ⟨s, hsmem, hsrel⟩ :=
        kvE_fiberZoneList_realized M _ σ hnf kvE_futSelfZone x1 hz
      exact ⟨s, hsmem, _, hsrel⟩
    · -- exact ray content
      rw [kvE_futRayForm, formula_conjList_iff]
      intro g hg
      rcases List.mem_cons.mp hg with rfl | hg'
      · -- every future point carries a ray sub: `¬F(¬D_ray)`
        intro hF
        obtain ⟨u, hx1u, hnotD, -⟩ := hF
        apply hnotD
        rw [kvE_futRayD, kvE_fiberPosOnShift_correct P _ M h_UZ h_SZ u]
        have hz : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
            kvE_futRayZone u :=
          kvE_futZone4_of_above M u x1 w x t hxw hwt (htx1.trans hx1u) (false, true)
            (iff_of_false (lt_asymm hx1u) Bool.false_ne_true) (iff_of_true hx1u rfl)
        obtain ⟨s, hsmem, hsrel⟩ :=
          kvE_fiberZoneList_realized M _ σ hnf kvE_futRayZone u hz
        exact ⟨s, hsmem, _, hsrel⟩
      · -- each ray sub occurs above `x1`
        obtain ⟨s, hsmem, rfl⟩ := List.mem_map.mp hg'
        have hbit : σ.2 s = true := ((kvE_fiberZoneList_mem σ kvE_futRayZone s).mp hsmem).1
        have hzs : nfk_zoneSpec s = kvE_futRayZone :=
          ((kvE_fiberZoneList_mem σ kvE_futRayZone s).mp hsmem).2
        have hd : nfk_dropFresh s = σ.1 :=
          kvE_fiber_dropFresh M _ σ hnf s ((kvE_fiber_mem σ s).mpr hbit)
        obtain ⟨v, hv⟩ := (hfib s hd).mpr hbit
        have hzone := kvE_futZoneHolds_of_atom M _ v s hv
        rw [hzs] at hzone
        have hx1v : x1 < v := (hzone 0).2.mpr rfl
        refine ⟨v, hx1v, ?_, fun r _ _ => id⟩
        rw [kvE_futItemShift_correct P s M h_UZ h_SZ v]
        exact ⟨_, hv⟩
  -- each gap sub occurs in `(t, x1)`; realizer occurrence predicate `Q`
  have hocc : ∀ s ∈ kvE_fiberZoneList σ kvE_futGapZone, ∃ r : M.carrier,
      t < r ∧ r < x1 ∧ nf_eval_nf M k 5
        (Fin.cons r (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s := by
    intro s hsmem
    have hbit : σ.2 s = true := ((kvE_fiberZoneList_mem σ kvE_futGapZone s).mp hsmem).1
    have hzs : nfk_zoneSpec s = kvE_futGapZone :=
      ((kvE_fiberZoneList_mem σ kvE_futGapZone s).mp hsmem).2
    have hd : nfk_dropFresh s = σ.1 :=
      kvE_fiber_dropFresh M _ σ hnf s ((kvE_fiber_mem σ s).mpr hbit)
    obtain ⟨v, hv⟩ := (hfib s hd).mpr hbit
    have hzone := kvE_futZoneHolds_of_atom M _ v s hv
    rw [hzs] at hzone
    have hvx1 : v < x1 := (hzone 0).1.mpr rfl
    have htv : t < v := (hzone ⟨3, by omega⟩).2.mpr rfl
    exact ⟨v, htv, hvx1, hv⟩
  -- build the chain at `t` via the generic Cor 5.4 `O_n` builder
  obtain ⟨l, hlperm, hltruth⟩ :=
    kvE_futChainBuildG M atomMap (kvE_futItemShift P) (kvE_futEnd P σ) (kvE_futGapD P σ)
      t x1
      (fun s r => nf_eval_nf M k 5
        (Fin.cons r (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s)
      (fun s r hQ => (kvE_futItemShift_correct P s M h_UZ h_SZ r).mpr ⟨_, hQ⟩)
      (fun s s' r hQ hQ' => nf_eval_unique M k 5 _ s s' hQ hQ')
      hD hend
      (kvE_fiberZoneList σ kvE_futGapZone).length (kvE_fiberZoneList σ kvE_futGapZone) le_rfl
      (kvE_fiberZoneList_nodup σ kvE_futGapZone) t htx1 (fun r hr => hr) hocc
  refine hcl ?_
  rw [kvE_futPos, if_pos hadm, formula_disjList_iff]
  exact ⟨_, List.mem_map.mpr ⟨l, List.mem_permutations.mpr hlperm, rfl⟩, hltruth⟩

end Bimodal.Metalogic.WeakCanonical.Kamp
