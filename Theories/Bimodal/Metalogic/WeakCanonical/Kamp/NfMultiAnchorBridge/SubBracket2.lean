import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SubBracket

/-! Extracted from NfMultiAnchorBridge.lean lines 6107-6733.
Task-324 anchor-at-`x` corrected sub-bracket: `kvE_subBracket2`, `kvE_subChain2`, zone specs
`kvE_sub2_z{XU,UW,WT}`, kill-switch/soundness/completeness kit. Sanctioned token edits
(research Finding 4): removed `private ` from `kvE_sub2_zXU`, `kvE_sub2_zUW`, `kvE_sub2_zWT`,
`kvE_sub2_zoneHolds_cons_iff`. -/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation
  (nf_depth0_char_formula nf_depth0_char_formula_correct
   formula_conjList formula_conjList_iff)

/-! ## Task 324 (redesign): anchor-at-`x` corrected sub-bracket — arity-4 correctness pair

Additive, separately-named redesign of the k=2 sub-bracket (task 324 Phase 1; plan
`plans/01_arity4-correctness-pair-plan.md`). The landed `kvE_subBracket`/`kvE_subChain`
(:5779/:5807) anchor the strictly-upward `fChainPred` at the interior σ-witness slot `u`: `u`'s own
point type sits at the TOP of the ascending witness list `posSlots ++ [u]`, so a witness in
`zXU = (x, v, u)` lying BELOW `u` is structurally inexpressible (task-321 Phase 8 machine-grounded
blocker; adversarial-verification Correction 1: the defect is read-back geometry, not a missing
zone). This redesign LIFTS the landed k1v LOWER-endpoint geometry one arity up: `bracketEndChar_k1v`
(:1940) anchors its bracket `bracketFromLists lL ptW lR` over `(x, t)` at the lower endpoint `x`,
with the middle `w`-slot BETWEEN the two witness lists, so a single upward `fChainPred` from `x`
reaches every interior zone. Here `u` plays the role of k1v's `w`: `u`'s own slot is placed in the
MIDDLE of the ascending witness list, BETWEEN the below-anchor `zXU` slots and the above-anchor
`zUW`/`zWT` slots (`leftSlots ++ uSlot :: rightSlots`, the arity-4 lift of k1v's `lL ++ ptW :: lR`).
A single upward `fChainPred` evaluated at the lower endpoint `x` then reaches all three interior
zones `zXU` (below `u`), `zUW`, `zWT` (above `u`) in ascending order — the below-anchor witness the
landed construction could not express.

Every landed asset stays byte-identical AND unreferenced: this block reads `σ.2` through the depth-0
`nf0_assemble` fold engine DIRECTLY (consume-do-not-rebuild; the same Def-4.1 fold, PDF p.5, that the
landed `kvE_subFoldBits` :5730 and the k1v carrier :1946 read — inlined here so the new construction
depends on no task-321 sub-bracket symbol) and rebinds the three interior zone specs locally via the
same `mk4` pattern as `kvE_subInteriorZones` :5751. No `simp`/`omega`/`aesop` in the body (the
`omega` is a `Fin`-index typing obligation in a proof term, identical to the landed `bracketFromLists`
:1900 and `kvE_subBracket` :5798). Rabinovich Def 3.1 (md:61-74), Def 4.1 (PDF p.5), §5 bracket
`[α_0, …, α_n](z_0, z_1)` (PDF p.7), Cor 5.4 recursive chain (md:154-157). -/
noncomputable def kvE_subBracket2 {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4) : Σ m, BracketFormula (m + 1) :=
  -- Sub-level fold-bit read (Def 4.1, PDF p.5): `σ.2 ∘ nf0_assemble` at the gate instance j = 0,
  -- inlined (consume-do-not-rebuild) so no landed sub-bracket symbol is referenced.
  let bits : ZoneSpec 4 → NormalForm sig 0 1 → Bool :=
    fun zs χ => σ.2 (nf0_assemble zs χ σ.1)
  let allTypes : List (NormalForm sig 0 1) := Finset.univ.toList
  -- Interior zone specs relative to σ's env `[u, w, x, t]` under honest order `x < u < w < t`
  -- (coords 0 ↦ u, 1 ↦ w, 2 ↦ x, 3 ↦ t), rebound locally (matches `kvE_subInteriorZones` :5751).
  let ltz : Bool × Bool := (true, false)   -- v < env i
  let gtz : Bool × Bool := (false, true)   -- env i < v
  let mk4 : Bool × Bool → Bool × Bool → Bool × Bool → Bool × Bool → ZoneSpec 4 :=
    fun p0 p1 p2 p3 => Fin.cons p0 (Fin.cons p1 (Fin.cons p2 (fun _ => p3)))
  let zXU : ZoneSpec 4 := mk4 ltz ltz gtz ltz   -- x < v < u  (BELOW anchor u)
  let zUW : ZoneSpec 4 := mk4 gtz ltz gtz ltz   -- u < v < w  (ABOVE anchor u)
  let zWT : ZoneSpec 4 := mk4 gtz gtz gtz ltz   -- w < v < t  (ABOVE anchor u)
  -- Below-anchor interior positives → left witness slots (Def 3.1 md:61-74; k1v `lL` one arity up).
  let leftSlots : List TemporalPred :=
    (allTypes.filter (fun χ => bits zXU χ)).map (fun χ => (⟨charBase χ⟩ : TemporalPred))
  -- Above-anchor interior positives → right witness slots (k1v `lR` one arity up), zone order.
  let rightSlots : List TemporalPred :=
    [zUW, zWT].flatMap (fun zs =>
      (allTypes.filter (fun χ => bits zs χ)).map (fun χ => (⟨charBase χ⟩ : TemporalPred)))
  -- `u`'s own middle slot: the anchor point type BETWEEN left and right slots (k1v `ptW` at `w`,
  -- §5 bracket PDF p.7, one arity up). THIS mid-placement is the anchor-at-`x` corrective change.
  let uSlot : TemporalPred := ⟨charK (nfk_projFresh σ)⟩
  -- Interior-negative bits → segment exclusion conjuncts (real segments, G3), all three zones.
  let segExcl : TemporalPred :=
    ⟨formula_conjList
      ([zXU, zUW, zWT].flatMap (fun zs =>
        allTypes.map fun χ => if bits zs χ then Formula.top else (charBase χ).neg))⟩
  ⟨leftSlots.length + rightSlots.length,
    { pointTypes := fun i =>
        (leftSlots ++ uSlot :: rightSlots)[i.val]'(by
          have := i.isLt
          simp only [List.length_append, List.length_cons]
          omega)
      segmentTypes := fun _ => segExcl }⟩

/-- **Anchor-at-`x` sub-chain predicate**. The Cor 5.4
    F_i-chain predicate of the redesigned sub-bracket — `fChainPred` is available because
    `kvE_subBracket2` returns the `(m+1)` shape. Evaluated at the lower endpoint `x`, its ascending
    Until-chain reaches `zXU` (below `u`), then `u`, then `zUW`/`zWT` (above `u`) — the below-anchor
    witness the landed `kvE_subChain` :5807 could not express. Rabinovich Cor 5.4 (md:154-157). -/
noncomputable def kvE_subChain2 {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4) : TemporalPred :=
  (kvE_subBracket2 charBase charK σ).2.fChainPred

/-- **Definitional bridge / `two_eq`-style rfl compatibility check at j = 0** (task 324 Phase 1;
    R3). Confirms the redesigned sub-chain is definitionally the `fChainPred` of the anchor-at-`x`
    sub-bracket, and that the whole construction elaborates and reduces at the concrete gate instance
    j = 0 (the depth-0 `nf0_assemble` read). The successor-parameterized carrier depth is `j + 2`
    (subs `σ : NormalForm sig (j+1) 4`); at j = 0 this is the landed `NormalForm sig 1 4` instance,
    and the bridge closes by `rfl` — any successor-threading depth mismatch would fail it immediately
    (the `bracketEndChar_kvE2_two_eq` :5972 discipline, one arity up). -/
theorem kvE_subChain2_eq_fChainPred {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4) :
    kvE_subChain2 charBase charK σ = (kvE_subBracket2 charBase charK σ).2.fChainPred := rfl

/-! ### Phase 2 — Per-zone reachability kill-switch

The design-validation gate (Risk R1) for the anchor-at-`x` geometry. Each interior zone gets one
concrete, machine-verified reachability lemma against the *chosen* geometry — NOT a `#eval`/
type-check probe. The lemmas semantically drive the `kvE_subBracket2` bracket: whenever it holds on
an interval, its strictly increasing witnesses (Def 3.1 monotone enumeration, PDF p.4) place the
`zXU`-positive witnesses BELOW the anchor `u`-slot and the `zUW`/`zWT`-positive witnesses ABOVE it —
the below-anchor witness the landed `kvE_subChain` :5807 could not express. Rabinovich Prop 3.5
(md:87-94, the ∃-witness → Until folding of an ascending chain) and §5 bracket `[α_0,…,α_n](z_0,z_1)`
(PDF p.7). The three interior zone specs are rebound here as defeq clones of the def's internal
`let`s (and of `kvE_subInteriorZones` :5751); `mk4 ltz ltz gtz ltz` etc. with `ltz = (true, false)`
(`v < env i`) and `gtz = (false, true)` (`env i < v`). -/

/-- Interior zone `zXU = (x < v < u)` — BELOW the anchor `u`. Defeq to `kvE_subBracket2`'s internal
    `zXU` and to `kvE_subInteriorZones` :5751. Rabinovich Def 3.1 (md:61-74). -/
def kvE_sub2_zXU : ZoneSpec 4 :=
  Fin.cons (true, false) (Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false))))

/-- Interior zone `zUW = (u < v < w)` — ABOVE the anchor `u`. Rabinovich Def 3.1 (md:61-74). -/
def kvE_sub2_zUW : ZoneSpec 4 :=
  Fin.cons (false, true) (Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false))))

/-- Interior zone `zWT = (w < v < t)` — ABOVE the anchor `u`. Rabinovich Def 3.1 (md:61-74). -/
def kvE_sub2_zWT : ZoneSpec 4 :=
  Fin.cons (false, true) (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (true, false))))

/-- Below-anchor witness slots of `kvE_subBracket2` (`leftSlots`, defeq to the def's internal
    `let`). One witness point type per `zXU`-positive fold bit. Rabinovich Def 3.1 (md:61-74). -/
private noncomputable def kvE_sub2_leftSlots {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (σ : NormalForm sig 1 4) : List TemporalPred :=
  ((Finset.univ.toList : List (NormalForm sig 0 1)).filter
    (fun χ => σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1))).map (fun χ => (⟨charBase χ⟩ : TemporalPred))

/-- Above-anchor witness slots of `kvE_subBracket2` (`rightSlots`, defeq to the def's internal
    `let`), in zone order `zUW, zWT`. Rabinovich Def 3.1 (md:61-74). -/
private noncomputable def kvE_sub2_rightSlots {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (σ : NormalForm sig 1 4) : List TemporalPred :=
  [kvE_sub2_zUW, kvE_sub2_zWT].flatMap (fun zs =>
    ((Finset.univ.toList : List (NormalForm sig 0 1)).filter
      (fun χ => σ.2 (nf0_assemble zs χ σ.1))).map (fun χ => (⟨charBase χ⟩ : TemporalPred)))

/-- **Anchor-at-`x` point-type extraction**. Whenever the redesigned bracket
    `kvE_subBracket2` holds on `(z_0, z_1)`, there is an anchor witness `w` realizing the `u`-slot
    type `charK (nfk_projFresh σ)`, with every `zXU`-positive point type realized strictly BELOW
    `w` and every `zUW`/`zWT`-positive point type realized strictly ABOVE `w`. This is the arity-4
    lift of `k1v_bracket_extract` :2150 (bullets 1-3, point-type reachability only; the constant
    `segExcl` segment types are irrelevant to point conditions). Rabinovich §5 bracket (PDF p.7),
    Def 3.1 monotone witness enumeration (PDF p.4). -/
private theorem kvE_subBracket2_extract {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (z0 z1 : M.carrier)
    (h : (kvE_subBracket2 charBase charK σ).2.holds M atomMap z0 z1) :
    ∃ w : M.carrier, z0 < w ∧ w < z1 ∧
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap w ∧
      (∀ χ : NormalForm sig 0 1,
        σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true →
        ∃ u : M.carrier, z0 < u ∧ u < w ∧
          (⟨charBase χ⟩ : TemporalPred).eval_at M atomMap u) ∧
      (∀ χ : NormalForm sig 0 1,
        (σ.2 (nf0_assemble kvE_sub2_zUW χ σ.1) = true ∨
         σ.2 (nf0_assemble kvE_sub2_zWT χ σ.1) = true) →
        ∃ u : M.carrier, w < u ∧ u < z1 ∧
          (⟨charBase χ⟩ : TemporalPred).eval_at M atomMap u) := by
  -- Point-type list of the anchor-at-`x` bracket: `leftSlots ++ uSlot :: rightSlots`.
  set lL := kvE_sub2_leftSlots charBase σ with hlL
  set lR := kvE_sub2_rightSlots charBase σ with hlR
  -- The constructed bracket's point-type function (rfl: the def sets `pointTypes` to exactly this).
  have hpt_eq : (kvE_subBracket2 charBase charK σ).2.pointTypes =
      fun i => (lL ++ (⟨charK (nfk_projFresh σ)⟩ : TemporalPred) :: lR)[i.val]'(by
        have hlt := i.isLt
        have hf : (kvE_subBracket2 charBase charK σ).fst = lL.length + lR.length := rfl
        simp only [List.length_append, List.length_cons]
        omega) := rfl
  -- Unfold `holds` to the `n+1` existential witness form (Def 3.1, PDF p.4).
  simp only [BracketFormula.holds, BracketFormula.toIntervalPattern] at h
  rw [IntervalPattern.holds_eq_succ M atomMap _ _ z0 z1
      (show (kvE_subBracket2 charBase charK σ).1 + 1 = (lL.length + lR.length) + 1 from rfl)] at h
  obtain ⟨ws, hmono, hrange, hpt, _, _, _⟩ := h
  -- Nat-indexed point-type view (proof-irrelevant reindexing), rewritten by `hpt_eq`.
  have hpt' : ∀ (i : Nat) (hi : i < lL.length + lR.length + 1),
      ((lL ++ (⟨charK (nfk_projFresh σ)⟩ : TemporalPred) :: lR)[i]'(by
        simp only [List.length_append, List.length_cons]; omega)).eval_at M atomMap
        (ws ⟨i, hi⟩) := by
    intro i hi
    have hi' := hpt ⟨i, hi⟩
    simp only [hpt_eq] at hi'
    exact hi'
  refine ⟨ws ⟨lL.length, by omega⟩, (hrange ⟨lL.length, by omega⟩).1,
    (hrange ⟨lL.length, by omega⟩).2, ?_, ?_, ?_⟩
  · -- Anchor `uSlot` at index `lL.length` (§5 bracket middle slot, PDF p.7).
    have helem : (lL ++ (⟨charK (nfk_projFresh σ)⟩ : TemporalPred) :: lR)[lL.length]'(by
        simp only [List.length_append, List.length_cons]; omega)
        = (⟨charK (nfk_projFresh σ)⟩ : TemporalPred) := by
      rw [List.getElem_append_right (Nat.le_refl _)]
      simp only [Nat.sub_self, List.getElem_cons_zero]
    have := hpt' lL.length (by omega)
    rwa [helem] at this
  · -- Below-anchor: each `zXU`-positive point type realized strictly inside `(z0, w)`.
    intro χ hχ
    have hmem : (⟨charBase χ⟩ : TemporalPred) ∈ lL := by
      rw [hlL, kvE_sub2_leftSlots]
      exact List.mem_map.mpr
        ⟨χ, List.mem_filter.mpr ⟨Finset.mem_toList.mpr (Finset.mem_univ _), hχ⟩, rfl⟩
    obtain ⟨j, hj, hjeq⟩ := List.mem_iff_getElem.mp hmem
    refine ⟨ws ⟨j, by omega⟩, (hrange ⟨j, by omega⟩).1,
      hmono ⟨j, by omega⟩ ⟨lL.length, by omega⟩ (Fin.mk_lt_mk.mpr hj), ?_⟩
    have := hpt' j (by omega)
    rw [List.getElem_append_left hj, hjeq] at this
    exact this
  · -- Above-anchor: each `zUW`/`zWT`-positive point type realized strictly inside `(w, z1)`.
    intro χ hχ
    have hmem : (⟨charBase χ⟩ : TemporalPred) ∈ lR := by
      rw [hlR, kvE_sub2_rightSlots]
      rcases hχ with h1 | h1
      · exact List.mem_flatMap.mpr ⟨kvE_sub2_zUW, List.mem_cons.mpr (Or.inl rfl),
          List.mem_map.mpr ⟨χ, List.mem_filter.mpr
            ⟨Finset.mem_toList.mpr (Finset.mem_univ _), h1⟩, rfl⟩⟩
      · exact List.mem_flatMap.mpr ⟨kvE_sub2_zWT,
          List.mem_cons.mpr (Or.inr (List.mem_cons.mpr (Or.inl rfl))),
          List.mem_map.mpr ⟨χ, List.mem_filter.mpr
            ⟨Finset.mem_toList.mpr (Finset.mem_univ _), h1⟩, rfl⟩⟩
    obtain ⟨j, hj, hjeq⟩ := List.mem_iff_getElem.mp hmem
    refine ⟨ws ⟨lL.length + 1 + j, by omega⟩,
      hmono ⟨lL.length, by omega⟩ ⟨lL.length + 1 + j, by omega⟩ (Fin.mk_lt_mk.mpr (by omega)),
      (hrange ⟨lL.length + 1 + j, by omega⟩).2, ?_⟩
    have helem : (lL ++ (⟨charK (nfk_projFresh σ)⟩ : TemporalPred) :: lR)[lL.length + 1 + j]'(by
        simp only [List.length_append, List.length_cons]; omega) = lR[j]'hj := by
      rw [List.getElem_append_right (by omega)]
      simp only [show lL.length + 1 + j - lL.length = j + 1 by omega, List.getElem_cons_succ]
    have := hpt' (lL.length + 1 + j) (by omega)
    rw [helem, hjeq] at this
    exact this

/-- **KILL-SWITCH — `zXU` reachability (BELOW the anchor)**. For every
    `zXU`-positive fold bit `χ`, whenever `kvE_subBracket2` holds on `(z_0, z_1)` there is a witness
    `u` realizing `charBase χ` strictly BELOW the anchor witness `w` (which realizes the `u`-slot
    type). This is the exact obligation the landed `kvE_subChain` :5807 (upward-only, anchored at
    `u`) could not meet — the below-anchor witness is now expressible. Rabinovich Prop 3.5
    (md:87-94), §5 bracket (PDF p.7). -/
theorem kvE_subBracket2_reaches_zXU {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (z0 z1 : M.carrier) (χ : NormalForm sig 0 1)
    (hbit : σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true)
    (h : (kvE_subBracket2 charBase charK σ).2.holds M atomMap z0 z1) :
    ∃ u w : M.carrier, z0 < u ∧ u < w ∧ w < z1 ∧
      (⟨charBase χ⟩ : TemporalPred).eval_at M atomMap u ∧
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap w := by
  obtain ⟨w, hz0w, hwz1, hanchor, hleft, _⟩ :=
    kvE_subBracket2_extract charBase charK σ M atomMap z0 z1 h
  obtain ⟨u, hz0u, huw, hu⟩ := hleft χ hbit
  exact ⟨u, w, hz0u, huw, hwz1, hu, hanchor⟩

/-- **KILL-SWITCH — `zUW` reachability (ABOVE the anchor)**. For every
    `zUW`-positive fold bit `χ`, whenever `kvE_subBracket2` holds on `(z_0, z_1)` there is a witness
    `u` realizing `charBase χ` strictly ABOVE the anchor witness `w`. Reuses the proven upward
    monotone enumeration unchanged. Rabinovich Prop 3.5 (md:87-94). -/
theorem kvE_subBracket2_reaches_zUW {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (z0 z1 : M.carrier) (χ : NormalForm sig 0 1)
    (hbit : σ.2 (nf0_assemble kvE_sub2_zUW χ σ.1) = true)
    (h : (kvE_subBracket2 charBase charK σ).2.holds M atomMap z0 z1) :
    ∃ w u : M.carrier, z0 < w ∧ w < u ∧ u < z1 ∧
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap w ∧
      (⟨charBase χ⟩ : TemporalPred).eval_at M atomMap u := by
  obtain ⟨w, hz0w, hwz1, hanchor, _, hright⟩ :=
    kvE_subBracket2_extract charBase charK σ M atomMap z0 z1 h
  obtain ⟨u, hwu, huz1, hu⟩ := hright χ (Or.inl hbit)
  exact ⟨w, u, hz0w, hwu, huz1, hanchor, hu⟩

/-- **KILL-SWITCH — `zWT` reachability (ABOVE the anchor)**. For every
    `zWT`-positive fold bit `χ`, whenever `kvE_subBracket2` holds on `(z_0, z_1)` there is a witness
    `u` realizing `charBase χ` strictly ABOVE the anchor witness `w`. Rabinovich Prop 3.5
    (md:87-94). -/
theorem kvE_subBracket2_reaches_zWT {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (z0 z1 : M.carrier) (χ : NormalForm sig 0 1)
    (hbit : σ.2 (nf0_assemble kvE_sub2_zWT χ σ.1) = true)
    (h : (kvE_subBracket2 charBase charK σ).2.holds M atomMap z0 z1) :
    ∃ w u : M.carrier, z0 < w ∧ w < u ∧ u < z1 ∧
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap w ∧
      (⟨charBase χ⟩ : TemporalPred).eval_at M atomMap u := by
  obtain ⟨w, hz0w, hwz1, hanchor, _, hright⟩ :=
    kvE_subBracket2_extract charBase charK σ M atomMap z0 z1 h
  obtain ⟨u, hwu, huz1, hu⟩ := hright χ (Or.inr hbit)
  exact ⟨w, u, hz0w, hwu, huz1, hanchor, hu⟩

/-! ### Phase 3 — Soundness: atom-layer recovery channel + interior-fold ≤ per zone

Soundness building blocks consumed by Phase 4's `kvE_subBracket2_sound` assembly. Two channels:

* **Atom-layer recovery channel** (`kvE_subBracket2_implies_subChain2`): the arity-4 corrected
  analog of the landed holds→chain-at-point connector `kvE_subBracket_implies_subChain` :5824,
  now instantiating the PROVEN `BracketFormula.bracket_implies_fChainPred` (EANegation:660) at the
  *corrected* `kvE_subBracket2`. Whenever the redesigned bracket holds on `(z0, z)`, its
  `fChainPred` (= `kvE_subChain2`, def :6170) is satisfied at a witness `x0` STRICTLY inside
  `(z0, z)`, recovered from the bracket's OWN interval pattern — the F-chain predicate that
  carries σ.1's order + predicate structure over the chain's evaluation points (report §2 probe 6).
  No provider environment rebinds the anchors (Amendment F3); the positions ARE the bracket
  witnesses, quantified by the temporal semantics. Rabinovich Cor 5.4 (md:154-157).

* **Interior-fold ≤ per zone** (`kvE_subBracket2_fold_zXU/_zUW/_zWT`): for each interior zone,
  a POSITIVE fold bit `σ.2 (nf0_assemble z* χ σ.1) = true` is REALIZED by the Phase-2 reachability
  evidence (`kvE_subBracket2_reaches_z*`) as an honest normal-form witness. Reading the point
  types through `charBase := nf_depth0_char_formula atomMap h_surj`, the char-formula realization
  `⟨charBase χ⟩.eval_at` is bridged to the actual `nf_eval_nf M 0 1` evaluation via the correctness
  lemma `nfPred_correct` (NfToVecEA:69) — the exact `hchar` bridge the k1v soundness template
  :2370 uses. `zXU` places its witness strictly BELOW the anchor `w` (the below-anchor witness the
  landed construction could not express); `zUW`/`zWT` strictly ABOVE. Rabinovich Cor 5.4
  (md:154-157) step-by-step; no `simp`/`omega`/`aesop` on chain steps. -/

/-- **Atom-layer recovery channel**. The corrected arity-4 holds→chain-at-point
    connector: instantiates the PROVEN `BracketFormula.bracket_implies_fChainPred` (EANegation:660)
    at the redesigned `kvE_subBracket2`. Whenever the bracket holds on `(z0, z)`, `kvE_subChain2`
    (its `fChainPred`, def :6170) holds at a witness `x0` strictly inside `(z0, z)`, and every point
    strictly below `x0` satisfies the leading segment type. This recovers σ.1's order + predicate
    structure over the chain's evaluation points WITHOUT any provider environment (Amendment F3):
    the anchor positions are the bracket witnesses, quantified by the temporal semantics. Arity-4
    analog of the landed `kvE_subBracket_implies_subChain` :5824. Rabinovich Cor 5.4 (md:154-157). -/
theorem kvE_subBracket2_implies_subChain2 {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (z0 z : M.carrier)
    (h : (kvE_subBracket2 charBase charK σ).2.holds M atomMap z0 z) :
    ∃ x0 : M.carrier, z0 < x0 ∧ x0 < z ∧
      (kvE_subChain2 charBase charK σ).eval_at M atomMap x0 ∧
      (∀ y : M.carrier, z0 < y → y < x0 →
        ((kvE_subBracket2 charBase charK σ).2.segmentTypes ⟨0, by omega⟩).eval_at M atomMap y) :=
  (kvE_subBracket2 charBase charK σ).2.bracket_implies_fChainPred M atomMap z0 z h

/-- **Interior-fold ≤ — `zXU` (BELOW anchor)**. A positive `zXU` fold bit is
    realized as an honest `nf_eval_nf M 0 1` witness `u` strictly BELOW the anchor witness `w`.
    The Phase-2 `kvE_subBracket2_reaches_zXU` supplies the below-anchor char-formula witness; the
    `nfPred_correct` (NfToVecEA:69) bridge — with `charBase = nf_depth0_char_formula atomMap h_surj`
    — converts the char-formula realization to the actual normal-form evaluation, exactly as the
    k1v soundness template's `hchar` :2370. Rabinovich Cor 5.4 (md:154-157). -/
theorem kvE_subBracket2_fold_zXU {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig)
    (z0 z1 : M.carrier) (χ : NormalForm sig 0 1)
    (hbit : σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true)
    (h : (kvE_subBracket2 (nf_depth0_char_formula atomMap h_surj) charK σ).2.holds M atomMap z0 z1) :
    ∃ u w : M.carrier, z0 < u ∧ u < w ∧ w < z1 ∧
      nf_eval_nf M 0 1 (fun _ => u) χ ∧
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap w := by
  obtain ⟨u, w, hz0u, huw, hwz1, hu, hw⟩ :=
    kvE_subBracket2_reaches_zXU (nf_depth0_char_formula atomMap h_surj) charK σ M atomMap z0 z1 χ
      hbit h
  exact ⟨u, w, hz0u, huw, hwz1, (nfPred_correct M atomMap h_surj χ u).mp hu, hw⟩

/-- **Interior-fold ≤ — `zUW` (ABOVE anchor)**. A positive `zUW` fold bit is
    realized as an honest `nf_eval_nf M 0 1` witness `u` strictly ABOVE the anchor witness `w`
    (Phase-2 `kvE_subBracket2_reaches_zUW` + the `nfPred_correct` bridge). Rabinovich Cor 5.4
    (md:154-157). -/
theorem kvE_subBracket2_fold_zUW {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig)
    (z0 z1 : M.carrier) (χ : NormalForm sig 0 1)
    (hbit : σ.2 (nf0_assemble kvE_sub2_zUW χ σ.1) = true)
    (h : (kvE_subBracket2 (nf_depth0_char_formula atomMap h_surj) charK σ).2.holds M atomMap z0 z1) :
    ∃ w u : M.carrier, z0 < w ∧ w < u ∧ u < z1 ∧
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap w ∧
      nf_eval_nf M 0 1 (fun _ => u) χ := by
  obtain ⟨w, u, hz0w, hwu, huz1, hw, hu⟩ :=
    kvE_subBracket2_reaches_zUW (nf_depth0_char_formula atomMap h_surj) charK σ M atomMap z0 z1 χ
      hbit h
  exact ⟨w, u, hz0w, hwu, huz1, hw, (nfPred_correct M atomMap h_surj χ u).mp hu⟩

/-- **Interior-fold ≤ — `zWT` (ABOVE anchor)**. A positive `zWT` fold bit is
    realized as an honest `nf_eval_nf M 0 1` witness `u` strictly ABOVE the anchor witness `w`
    (Phase-2 `kvE_subBracket2_reaches_zWT` + the `nfPred_correct` bridge). Rabinovich Cor 5.4
    (md:154-157). -/
theorem kvE_subBracket2_fold_zWT {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig)
    (z0 z1 : M.carrier) (χ : NormalForm sig 0 1)
    (hbit : σ.2 (nf0_assemble kvE_sub2_zWT χ σ.1) = true)
    (h : (kvE_subBracket2 (nf_depth0_char_formula atomMap h_surj) charK σ).2.holds M atomMap z0 z1) :
    ∃ w u : M.carrier, z0 < w ∧ w < u ∧ u < z1 ∧
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap w ∧
      nf_eval_nf M 0 1 (fun _ => u) χ := by
  obtain ⟨w, u, hz0w, hwu, huz1, hw, hu⟩ :=
    kvE_subBracket2_reaches_zWT (nf_depth0_char_formula atomMap h_surj) charK σ M atomMap z0 z1 χ
      hbit h
  exact ⟨w, u, hz0w, hwu, huz1, hw, (nfPred_correct M atomMap h_surj χ u).mp hu⟩

/-! ### Phase 4 — Soundness: off-fiber falsity gate + standalone assembly

The standalone soundness lemma `kvE_subBracket2_sound`, assembled against `nf_eval_nf M 1 4` via
`nf_eval_depth1_fold_iff` (:5187 — the inside-out Def-4.1-p.6 fold, Prop 4.3 p.6, rule N2). It is
STANDALONE: the outer gate-shaped hypothesis (analogous to `kvE_gate` :5015) is an EXPLICIT
hypothesis, NEVER wired to the real outer gate (Amendment F3: no provider-side pinning; the
anchor positions ARE the bracket witnesses, quantified by the temporal semantics).

Division of labour (the honest content split, per the redesign's Correction-1 thesis):

* The **bracket construction** discharges the BELOW-ANCHOR (`zXU`) existence witnesses — the
  witnesses the landed `kvE_subChain` :5807 (upward-only, anchored at `u`) structurally could not
  express. Given a positive `zXU` fold bit, `kvE_subBracket2_extract`'s below-clause supplies a
  witness strictly BELOW the anchor, converted to an honest `nf_eval_nf M 0 1` via the
  `nfPred_correct` bridge (NfToVecEA:69, the k1v `hchar` :2370) and placed in zone `zXU` relative
  to the honest env `[a, w, x, t]`. Rabinovich Def 3.1 monotone enumeration (PDF p.4), §5 bracket
  (PDF p.7).

* The **explicit gate hypothesis** carries the remaining honest fold conditions the redesigned
  bracket does not itself encode (it has no endpoint char-formula conjuncts and conflates the two
  above-anchor zones): the atom layer, the off-fiber falsity clause, the forward zone honesty for
  every zone, and the backward direction for every zone EXCEPT `zXU`. This is the analog of
  `kvE_gate`'s per-sub off-fiber/consistency honesty, taken as an explicit standalone hypothesis
  (Amendment F3). It does NOT contain the `zXU` existence witnesses — those are the bracket's
  signature contribution — so the construction is genuinely load-bearing. -/

/-- **Standalone soundness of the redesigned sub-bracket**. Whenever the
    anchor-at-`x` bracket `kvE_subBracket2` holds on the FIXED endpoints `(x, t)`, and the explicit
    outer gate-shaped hypothesis `hgate` supplies the honest fold conditions it does not itself
    encode, there is a depth-1 witness `x1` realizing the arity-4 evaluation `nf_eval_nf M 1 4` at
    the honest env `[x1, w, x, t]`. STANDALONE: `hgate` is an explicit hypothesis, never wired to
    the real outer gate (Amendment F3 — no provider pinning; the anchor is the bracket's own
    witness). The bracket's OWN contribution is the below-anchor (`zXU`) existence witnesses
    (Correction 1: the below-anchor witness the landed `kvE_subChain` :5807 could not express).
    Assembled via `nf_eval_depth1_fold_iff` (:5187), reusing the `bracketEndChar_k1v_sound` :2338
    template shape one arity up. Rabinovich Def 3.1 (md:61-74), Prop 3.5 (md:87-94), Cor 5.4
    (md:154-157). -/
theorem kvE_subBracket2_sound {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier)
    (h : (kvE_subBracket2 (nf_depth0_char_formula atomMap h_surj) charK σ).2.holds
        M atomMap x t)
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
  -- Extract the anchor `a` (§5 bracket middle witness, PDF p.7) and the below-anchor witness
  -- clause from the redesigned bracket (Def 3.1 monotone enumeration, PDF p.4).
  obtain ⟨a, hxa, hat, hanchor, hbelow, _habove⟩ :=
    kvE_subBracket2_extract (nf_depth0_char_formula atomMap h_surj) charK σ M atomMap x t h
  -- Feed the anchor to the explicit gate hypothesis (Amendment F3: no provider pinning).
  obtain ⟨haw, hwt, h_atom, h_off, h_fwd, h_bwd⟩ := hgate a hxa hat hanchor
  refine ⟨a, ?_⟩
  -- Assemble the depth-1 evaluation from the honest fold conditions (Def 4.1 p.6 note; the
  -- inside-out fold of `nf_eval_depth1_fold_iff` :5187, Prop 4.3 p.6 — rule N2).
  rw [nf_eval_depth1_fold_iff]
  refine ⟨h_atom, ?_, h_off⟩
  -- Zone matching: forward from the gate; backward from the gate for every zone EXCEPT the
  -- below-anchor `zXU`, whose witnesses are supplied by the bracket (Correction 1).
  intro zs χ
  refine ⟨fun hex => h_fwd zs χ hex, ?_⟩
  intro hbit
  by_cases hzs : zs = kvE_sub2_zXU
  · -- Below-anchor zone `zXU = (x < v < a)`: the bracket's own below-witness clause supplies a
    -- witness strictly below the anchor `a` (Def 3.1, PDF p.4; the redesign's signature witness).
    subst hzs
    obtain ⟨u, hxu, hua, hu⟩ := hbelow χ hbit
    refine ⟨u, ?_, (nfPred_correct M atomMap h_surj χ u).mp hu⟩
    -- `u` lies in `zXU` relative to env `[a, w, x, t]` under honest order `x < u < a < w < t`.
    have huw : u < w := hua.trans haw
    have hut : u < t := huw.trans hwt
    intro i
    match i with
    | ⟨0, _⟩ => exact ⟨iff_of_true hua rfl, iff_of_false (lt_asymm hua) (by decide +revert)⟩
    | ⟨1, _⟩ => exact ⟨iff_of_true huw rfl, iff_of_false (lt_asymm huw) (by decide +revert)⟩
    | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxu) (by decide +revert), iff_of_true hxu rfl⟩
    | ⟨3, _⟩ => exact ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by decide +revert)⟩
  · -- Every other zone: the gate's backward direction (analog of `kvE_gate` honesty).
    exact h_bwd zs χ hzs hbit

/-! ### Phase 5 — Completeness: fold extraction of inner witnesses

The reverse-direction raw material. Starting from an honest depth-1 realization
`nf_eval_nf M 1 4 (Fin.cons x1 [w, x, t]) σ` at the anchor `x1`, `nf_eval_depth1_fold_iff`
(:5187 — the inside-out Def-4.1-p.6 fold, Prop 4.3 p.6) is driven FORWARD (`.mp`) to
decompose the realization into (a) the atom layer, (b) the per-zone fold conditions
`(∃ v, zoneHolds env zs v ∧ nf_eval_nf M 0 1 v χ) ↔ σ.2 (nf0_assemble zs χ σ.1) = true`, and
(c) the off-fiber falsity clause. The `.mpr` half of each interior-zone fold condition then
EXTRACTS, per positive fold bit, an honest depth-0 inner witness `v` together with its order
position relative to the anchor `x1` — the below-anchor `zXU` witness `x < v < x1` (the
redesign's Correction-1 signature datum, now extractable in the completeness direction too),
and the above-anchor `zUW` (`x1 < v < w`) and `zWT` (`w < v < t`) witnesses. This is the
monotone witness-enumeration data Phase 6 folds into `IntervalPattern.holds`; the three
interior zones are kept SEPARATE at source (the soundness `_extract` conflated `zUW`/`zWT`
into one disjunction — extraction supplies the finer, per-zone data Phase 6's per-slot
enumeration needs). The `zoneHolds`-to-inequalities conversion is the arity-4 lift of the
landed `k1v_zoneHolds_cons_iff` :2041 (Def 3.1 ordering channel, PDF p.4: the only channel
through which a quantified witness meets the fixed env points). No `simp`/`omega`/`aesop` on
chain steps (`by omega` is `Fin`-index typing in the cons-iff helper; `simp only [Fin.cons]`
is index reduction, byte-identical to the k1v helper). Rabinovich Def 4.1 (PDF p.5-6),
Prop 4.2 (md:100-101), Def 3.1 (md:61-74). -/

/-- `zoneHolds` over the arity-4 anchor env `[x1, w, x, t]` at a pointwise `Fin.cons` zone spec,
    unfolded to its four coordinate biconditionals — the arity-4 lift of `k1v_zoneHolds_cons_iff`
    :2041 (Def 3.1 ordering channel, PDF p.4). -/
theorem kvE_sub2_zoneHolds_cons_iff {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
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

/-- Below-anchor extraction: a `zXU` witness over the anchor env `[x1, w, x, t]` lies strictly
    inside `(x, x1)` — BELOW the anchor `x1` — AND strictly below the pivot `w` (its coord-1 /
    `w`-coordinate zone bit is `(true, false)`, decoding to `v < w`; Def 3.1 ordering channel,
    PDF p.4; Figure 1 below-pivot bracket, PDF p.9; the Correction-1 below-anchor datum,
    extractable in the completeness direction). Task 337 restores the `v < w` conjunct that the
    prior version discarded (report 13 faithfulness audit). -/
private theorem kvE_sub2_zoneHolds_zXU {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (x1 w x t v : M.carrier)
    (hz : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) kvE_sub2_zXU v) :
    x < v ∧ v < w ∧ v < x1 := by
  obtain ⟨hp0, hp1, hp2, _⟩ :=
    (kvE_sub2_zoneHolds_cons_iff M x1 w x t v (true, false) (true, false) (false, true)
      (true, false)).mp hz
  exact ⟨hp2.2.mpr rfl, hp1.1.mpr rfl, hp0.1.mpr rfl⟩

/-- Above-anchor extraction: a `zUW` witness over the anchor env `[x1, w, x, t]` lies strictly
    inside `(x1, w)` — ABOVE the anchor `x1`, below `w` (Def 3.1, PDF p.4). -/
private theorem kvE_sub2_zoneHolds_zUW {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (x1 w x t v : M.carrier)
    (hz : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) kvE_sub2_zUW v) :
    x1 < v ∧ v < w := by
  obtain ⟨hp0, hp1, _, _⟩ :=
    (kvE_sub2_zoneHolds_cons_iff M x1 w x t v (false, true) (true, false) (false, true)
      (true, false)).mp hz
  exact ⟨hp0.2.mpr rfl, hp1.1.mpr rfl⟩

/-- Above-anchor extraction: a `zWT` witness over the anchor env `[x1, w, x, t]` lies strictly
    inside `(w, t)` — ABOVE `w` (Def 3.1, PDF p.4). -/
private theorem kvE_sub2_zoneHolds_zWT {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (x1 w x t v : M.carrier)
    (hz : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) kvE_sub2_zWT v) :
    w < v ∧ v < t := by
  obtain ⟨_, hp1, _, hp3⟩ :=
    (kvE_sub2_zoneHolds_cons_iff M x1 w x t v (false, true) (false, true) (false, true)
      (true, false)).mp hz
  exact ⟨hp1.2.mpr rfl, hp3.1.mpr rfl⟩

/-- **Completeness fold-extraction of inner witnesses**. Driving
    `nf_eval_depth1_fold_iff` (:5187) FORWARD on an honest depth-1 realization at the anchor
    `x1` yields the raw material for the reverse direction: the atom layer, the off-fiber
    falsity clause, the forward zone-honesty channel (every genuine zone witness marks its
    fold bit positive — consumed by the Phase-7 arrangement closure), and — per interior zone,
    kept SEPARATE — the monotone inner-witness enumeration Phase 6 folds into
    `IntervalPattern.holds`: each positive `zXU` fold bit yields a witness strictly BELOW the
    anchor (`x < v < x1`, the Correction-1 signature datum), each positive `zUW`/`zWT` bit a
    witness strictly ABOVE (`x1 < v < w`, resp. `w < v < t`), all as honest `nf_eval_nf M 0 1`
    evaluations. Rabinovich Def 4.1 (PDF p.5-6), Prop 4.2 (md:100-101), Def 3.1 (md:61-74). -/
theorem kvE_subBracket2_complete_extract {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig)
    (x1 w x t : M.carrier)
    (h : nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    (∀ a : AtomKind sig 4,
        atom_eval M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) a ↔ σ.1 a = true) ∧
    (∀ τ : NormalForm sig 0 5, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false) ∧
    (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1),
        (∃ v : M.carrier,
          zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ) →
        σ.2 (nf0_assemble zs χ σ.1) = true) ∧
    (∀ χ : NormalForm sig 0 1, σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true →
        ∃ v : M.carrier, x < v ∧ v < w ∧ v < x1 ∧ nf_eval_nf M 0 1 (fun _ => v) χ) ∧
    (∀ χ : NormalForm sig 0 1, σ.2 (nf0_assemble kvE_sub2_zUW χ σ.1) = true →
        ∃ v : M.carrier, x1 < v ∧ v < w ∧ nf_eval_nf M 0 1 (fun _ => v) χ) ∧
    (∀ χ : NormalForm sig 0 1, σ.2 (nf0_assemble kvE_sub2_zWT χ σ.1) = true →
        ∃ v : M.carrier, w < v ∧ v < t ∧ nf_eval_nf M 0 1 (fun _ => v) χ) := by
  -- Forward fold decomposition (Prop 4.3 p.6, rule N2): atom layer + zone conditions + off-fiber.
  obtain ⟨h_atom, h_zone, h_off⟩ := (nf_eval_depth1_fold_iff M _ σ).mp h
  refine ⟨h_atom, h_off, fun zs χ hex => (h_zone zs χ).mp hex, ?_, ?_, ?_⟩
  · -- `zXU` below-anchor inner witnesses (Def 3.1 monotone enumeration, PDF p.4).
    intro χ hbit
    obtain ⟨v, hz, hv⟩ := (h_zone kvE_sub2_zXU χ).mpr hbit
    obtain ⟨hxv, hvw, hvx1⟩ := kvE_sub2_zoneHolds_zXU M x1 w x t v hz
    exact ⟨v, hxv, hvw, hvx1, hv⟩
  · -- `zUW` above-anchor inner witnesses.
    intro χ hbit
    obtain ⟨v, hz, hv⟩ := (h_zone kvE_sub2_zUW χ).mpr hbit
    obtain ⟨hx1v, hvw⟩ := kvE_sub2_zoneHolds_zUW M x1 w x t v hz
    exact ⟨v, hx1v, hvw, hv⟩
  · -- `zWT` above-`w` inner witnesses.
    intro χ hbit
    obtain ⟨v, hz, hv⟩ := (h_zone kvE_sub2_zWT χ).mpr hbit
    obtain ⟨hwv, hvt⟩ := kvE_sub2_zoneHolds_zWT M x1 w x t v hz
    exact ⟨v, hwv, hvt, hv⟩

end Bimodal.Metalogic.WeakCanonical.Kamp
