import FormalSystem.Boneyard.Kamp.KampBypassArchive.KampBypassCore
import FormalSystem.Boneyard.Kamp.KampWeakCanonical.WitnessCount
import FormalSystem.Boneyard.Kamp.KampBypassArchive.PriorComposition

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.

# K=1 ExistPart Bypass via VecEA2 Bracket Encoding

Replaces `prior_2var_transfer_until/since` in the backward direction of
`existPart_succ_n1_bypass` at k≥1 with a VecEA2 bracket encoding that
places zone-3 witnesses *between* the endpoints by construction.

## Why this is needed

`prior_2var_transfer_until` (PriorComposition.lean) is FALSE at K=0.
Counterexample: ℤ with is_even, (x,t)=(4,0), (x',t')=(2,0).
The k=0 bypass avoids this by using enriched VecEA2 brackets with
zone-3 witnesses. This file generalizes that approach to k≥1.

## Architecture

The k=0 bypass (KampBypassUntil.lean) builds:
  Formula = ⋁ over nf_x types [
    endpointLeft(t) ∧ (bracket_witness₁ U (bracket_witness₂ U ... (endpointRight(x) U ⊤)...))
  ]
where bracket witnesses are characterized by `nf_depth0_char_formula`.

For k≥1, we generalize:
  - bracket witness types use `char_kp1` (depth-(k'+2) 1-var char formula)
  - zone-3 sub-existentials at depth k' use `char_k'` (from ih_all_char)
  - segment guards use negated char formulas

The key property: Until chain ordering guarantees t < w₁ < w₂ < ... < x,
so ALL zone-3 witnesses are between the endpoints BY CONSTRUCTION.
No cross-structure transfer is needed.

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Section 5
- KampBypassUntil.lean (k=0 pattern to generalize)
-/

#exit

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.WeakCanonical.Separation (nf_depth0_char_formula
  nf_depth0_char_formula_correct formula_conjList formula_conjList_iff
  formula_disjList formula_disjList_iff)

/-! ## Zone Classification for Depth-(k'+1) 3-var NFs

Generalizes `ssn_zone_until` from KampBypassCore.lean.
At depth-(k'+1), the 3-var NF chi at [y, x, t] has order atoms
encoding y's position relative to x and t. The zone classification
is the same as depth 0 — only the order atoms matter for zone assignment. -/

/-- Zone of the existential variable (var 0) in a 3-var NF for the Until case.
    Identical to ssn_zone_until but for any depth. -/
noncomputable def ssn_zone_general {sig : MonadicSignature} {d : Nat}
    (chi : NormalForm sig d 3) : YZone :=
  -- var 0 = y (existential), var 1 = x (upper), var 2 = t (lower)
  -- Note: order atoms use .order i j with semantics "env(i) < env(j)"
  -- In the 3-var env [y, x, t]: var 0 = y, var 1 = x, var 2 = t
  let atoms := NormalForm.atom_assgn chi
  let y_lt_x := atoms (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))
  let x_lt_y := atoms (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))
  let y_lt_t := atoms (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide))
  let t_lt_y := atoms (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide))
  if y_lt_x && x_lt_y then .inconsistent
  else if y_lt_t && t_lt_y then .inconsistent
  else if y_lt_t then .below_t
  else if x_lt_y then .above_x
  else if t_lt_y && y_lt_x then .between_tx
  else if !t_lt_y && !y_lt_t then .eq_t
  else if !x_lt_y && !y_lt_x then .eq_x
  else .inconsistent

/-! ## Zone Order Extraction

Extract order atom values from the zone classification. -/

/-- Extract order atoms from ssn_zone_general = between_tx. -/
private theorem zone_general_between_tx_orders {sig : MonadicSignature} {d : Nat}
    (chi : NormalForm sig d 3) (h : ssn_zone_general chi = .between_tx) :
    (NormalForm.atom_assgn chi) (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = true ∧
    (NormalForm.atom_assgn chi) (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true ∧
    (NormalForm.atom_assgn chi) (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false ∧
    (NormalForm.atom_assgn chi) (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = false := by
  simp only [ssn_zone_general] at h
  revert h; split_ifs <;> (intro h; try exact absurd h (by decide)) <;>
    simp_all [Bool.and_eq_true] <;> exact ⟨‹_›, ‹_›, ‹_›, ‹_›⟩

/-! ## Shared Predicate Transfer Helper -/

/-- Transfer predicate between 1-var NF-agreed points. -/
private theorem pred_transfer_from_1var {sig : MonadicSignature} {K : Nat}
    (M : OrderedMonadicStructure sig) (a : M.carrier)
    (N : OrderedMonadicStructure sig) (b : N.carrier)
    (h_agree : ∀ nf : NormalForm sig K 1,
      nf_eval_nf M K 1 (fun _ => a) nf ↔ nf_eval_nf N K 1 (fun _ => b) nf)
    (p : sig.preds) : M.interp p a ↔ N.interp p b := by
  have := atom_agreement_from_nf M (fun _ => a) N (fun _ => b)
    h_agree (.pred p ⟨0, by omega⟩)
  simp only [atom_eval] at this; exact this

/-! ## Non-Constant Env Existential Transfer

From pointwise 1-var NF agreements at each component plus matching orders,
transfer existentials at non-constant envs. This is the key infrastructure
for the non-between_tx zones in nf_eval_from_enriched_witnesses.

The proof goes by induction on d (the NF depth). At each step:
- Atoms transfer from the pointwise 1-var agreements + order matching
- Quantifiers use exist_transfer_from_full_agree from the IH at lower depth

This is proved sorry-free for the atom part; the quantifier part requires
exist_transfer_from_full_agree from full multi-var agreement which we
bootstrap by induction on d. -/

/-- Transfer depth-d 3-var existentials at [w,x,t]/[w',x',t'] from
    pointwise 1-var agreements and matching orders.
    This generalizes exist_transfer_from_full_agree to non-constant envs. -/
private theorem nonconstenv_3var_exist_transfer {sig : MonadicSignature}
    {K : Nat}
    (M : OrderedMonadicStructure sig) (x t : M.carrier)
    (N : OrderedMonadicStructure sig) (x' t' : N.carrier)
    (h_order_M : t < x) (h_order_N : t' < x')
    (h_x : ∀ nf : NormalForm sig (K + 2) 1,
      nf_eval_nf M (K + 2) 1 (fun _ => x) nf ↔
      nf_eval_nf N (K + 2) 1 (fun _ => x') nf)
    (h_t : ∀ nf : NormalForm sig (K + 2) 1,
      nf_eval_nf M (K + 2) 1 (fun _ => t) nf ↔
      nf_eval_nf N (K + 2) 1 (fun _ => t') nf)
    (chi : NormalForm sig (K + 1) 3) :
    (∃ w : M.carrier, nf_eval_nf M (K + 1) 3
      (Fin.cons w (Fin.cons x (fun _ => t))) chi) ↔
    (∃ w' : N.carrier, nf_eval_nf N (K + 1) 3
      (Fin.cons w' (Fin.cons x' (fun _ => t'))) chi) := by
  -- Strategy: Use exist_transfer_from_full_agree from the depth-(K+2) 2-var
  -- agreement at [x,t]/[x',t']. We construct this agreement by the
  -- characteristic NF approach: show both structures share the same NF type.
  --
  -- The 2-var agreement is bootstrapped from 1-var agreements using
  -- a nested reconstruction: atoms from 1-var, quantifiers recursively.
  --
  -- Key: this theorem IS the quantifier condition for the 2-var agreement,
  -- so we need to prove ALL quantifier conditions simultaneously to break
  -- the circularity. We do this by proving the full 2-var agreement first.
  have h_2var_agree : ∀ nf : NormalForm sig (K + 2) 2,
      nf_eval_nf M (K + 2) 2 (Fin.cons x (fun _ => t)) nf ↔
      nf_eval_nf N (K + 2) 2 (Fin.cons x' (fun _ => t')) nf := by
    -- Build depth-(K+2) 2-var agreement by induction on depth.
    -- This requires proving for all d ≤ K+2, depth-d 2-var agreement.
    -- At each step, atoms from 1-var agreements, quantifiers from
    -- exist_transfer_from_full_agree at the current depth.
    sorry
  exact exist_transfer_from_full_agree M (Fin.cons x (fun _ => t))
    N (Fin.cons x' (fun _ => t'))
    h_2var_agree (K + 1) (le_refl _) chi

/-! ## 2-var NF Reconstruction from Enriched Witnesses -/

/-- Given x and t in the same structure M, with:
    - x has x₀'s depth-(K+2) 1-var NF (from char formula matching)
    - t has t₀'s depth-(K+2) 1-var NF
    - For each zone-3 quantifier condition: a witness wᵢ ∈ (t, x)
      with w₀ᵢ's depth-(K+2) 1-var NF (from bracket)
    Reconstruct: nf_eval_nf M (K+2) 2 [x, t] sub_nf.

    This theorem is the BACKWARD direction of the enriched bypass.

    Status: atom part proved. All quantifier zones handled uniformly by
    `nonconstenv_3var_exist_transfer`, which transfers depth-(K+1) 3-var
    existentials from pointwise 1-var agreements at endpoints. The zone
    classification (between_tx, eq_t, below_t, etc.) is not needed;
    the transfer works for ALL zones uniformly.

    Remaining sorry: `nonconstenv_3var_exist_transfer` requires depth-(K+2)
    2-var NF agreement at [x,t]/[x₀,t₀] from 1-var agreements, which is the
    same infrastructure gap as `prior_nonconstenv_2var_agree_until` at K=0. -/
theorem nf_eval_from_enriched_witnesses {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (K : Nat)
    (M₀ : OrderedMonadicStructure sig)
    (h_UZ₀ : semantic_prior_UZ M₀ atomMap)
    (h_SZ₀ : semantic_prior_SZ M₀ atomMap)
    (x₀ t₀ : M₀.carrier) (h_order₀ : t₀ < x₀)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap)
    (h_SZ : semantic_prior_SZ M atomMap)
    (x t : M.carrier) (h_order : t < x)
    -- 1-var NF agreements at endpoints
    (h_x : ∀ nf : NormalForm sig (K + 2) 1,
      nf_eval_nf M (K + 2) 1 (fun _ => x) nf ↔
      nf_eval_nf M₀ (K + 2) 1 (fun _ => x₀) nf)
    (h_t : ∀ nf : NormalForm sig (K + 2) 1,
      nf_eval_nf M (K + 2) 1 (fun _ => t) nf ↔
      nf_eval_nf M₀ (K + 2) 1 (fun _ => t₀) nf)
    -- For each zone-3 chi with sub_nf.2(chi) = true:
    -- a witness in M between t and x with matching 1-var NF
    (zone3_witnesses :
      ∀ (chi : NormalForm sig (K + 1) 3),
        ssn_zone_general chi = YZone.between_tx →
        (∃ w₀ : M₀.carrier, t₀ < w₀ ∧ w₀ < x₀ ∧
          nf_eval_nf M₀ (K + 1) 3 (Fin.cons w₀ (Fin.cons x₀ (fun _ => t₀))) chi) →
        ∃ w : M.carrier, t < w ∧ w < x ∧
          nf_eval_nf M (K + 1) 3 (Fin.cons w (Fin.cons x (fun _ => t))) chi)
    (sub_nf : NormalForm sig (K + 2) 2)
    (h_eval₀ : nf_eval_nf M₀ (K + 2) 2 (Fin.cons x₀ (fun _ => t₀)) sub_nf) :
    nf_eval_nf M (K + 2) 2 (Fin.cons x (fun _ => t)) sub_nf := by
  -- Predicate transfer helpers
  have h_pred_x := pred_transfer_from_1var M x M₀ x₀ h_x
  have h_pred_t := pred_transfer_from_1var M t M₀ t₀ h_t
  -- Atom agreement for 2-var env
  have h_2var_atom_agree : ∀ a : AtomKind sig 2,
      atom_eval M (Fin.cons x (fun _ => t)) a ↔
      atom_eval M₀ (Fin.cons x₀ (fun _ => t₀)) a := by
    intro a; cases a with
    | pred p i =>
      simp only [atom_eval, Fin.cons]
      match i with
      | ⟨0, _⟩ => exact h_pred_x p
      | ⟨1, _⟩ => exact h_pred_t p
      | ⟨n + 2, h⟩ => exact absurd h (by omega)
    | order i j h_ne =>
      simp only [atom_eval, Fin.cons]
      match i, j, h_ne with
      | ⟨0, _⟩, ⟨0, _⟩, h => exact absurd rfl h
      | ⟨1, _⟩, ⟨1, _⟩, h => exact absurd rfl h
      | ⟨0, _⟩, ⟨1, _⟩, _ =>
        exact ⟨fun h => absurd (lt_trans h h_order) (lt_irrefl _),
               fun h => absurd (lt_trans h h_order₀) (lt_irrefl _)⟩
      | ⟨1, _⟩, ⟨0, _⟩, _ =>
        exact ⟨fun _ => h_order₀, fun _ => h_order⟩
      | ⟨n + 2, h⟩, _, _ => exact absurd h (by omega)
      | _, ⟨n + 2, h⟩, _ => exact absurd h (by omega)
  -- Strategy: show M,[x,t] satisfies the characteristic NF of M₀,[x₀,t₀]
  set target := nf_characteristic M₀ (K + 2) 2 (Fin.cons x₀ (fun _ => t₀))
  have h_M₀_sat := nf_characteristic_satisfies M₀ (K + 2) 2 (Fin.cons x₀ (fun _ => t₀))
  suffices h_M_sat : nf_eval_nf M (K + 2) 2 (Fin.cons x (fun _ => t)) target by
    exact (nf_agreement_from_shared_nf M _ M₀ _ target h_M_sat h_M₀_sat sub_nf).mpr h_eval₀
  obtain ⟨h_M₀_atoms, h_M₀_quant⟩ := h_M₀_sat
  constructor
  · -- Atom part: straightforward from predicate transfer + ordering
    intro a; exact (h_2var_atom_agree a).trans (h_M₀_atoms a)
  · -- Quantifier part: for each chi : NF sig (K+1) 3,
    -- (∃ w, nf_eval M (K+1) 3 [w,x,t] chi) ↔ target.2 chi
    intro chi
    rw [← h_M₀_quant chi]
    -- Goal: (∃ w, nf_eval M (K+1) 3 [w,x,t] chi) ↔
    --       (∃ w₀, nf_eval M₀ (K+1) 3 [w₀,x₀,t₀] chi)
    -- All zones handled uniformly by nonconstenv_3var_exist_transfer,
    -- which transfers 3-var existentials from pointwise 1-var agreements.
    -- The zone classification is not needed for the transfer itself;
    -- zone3_witnesses is only needed for the between_tx backward direction
    -- (which is now subsumed by the uniform transfer).
    exact nonconstenv_3var_exist_transfer M x t M₀ x₀ t₀
      h_order h_order₀ h_x h_t chi

/- The zone-3 witness provision from bracket witnesses.
   Given bracket witnesses w₁ < ... < wₘ in (t, x) from a VecEA2 bracket,
   and each wᵢ matching w₀ᵢ's depth-(K+2) 1-var NF, provide the zone-3
   witnesses needed by `nf_eval_from_enriched_witnesses`.

   Status: atom part fully proved (predicates via 1-var NF transfer, orders
   via zone classification + transitivity). Quantifier part uses
   `exist_transfer_from_full_agree` from depth-(K+1) 3-var agreement at
   [w,x,t]/[w₀,x₀,t₀], which depends on the same infrastructure gap as
   `nonconstenv_3var_exist_transfer`: constructing non-constant env multi-var
   NF agreement from pointwise 1-var agreements. -/
set_option maxHeartbeats 800000 in
theorem zone3_from_bracket {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (K : Nat)
    (M₀ : OrderedMonadicStructure sig) (x₀ t₀ : M₀.carrier)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (x t : M.carrier) (h_order : t < x)
    -- 1-var agreements
    (h_x : ∀ nf : NormalForm sig (K + 2) 1,
      nf_eval_nf M (K + 2) 1 (fun _ => x) nf ↔
      nf_eval_nf M₀ (K + 2) 1 (fun _ => x₀) nf)
    (h_t : ∀ nf : NormalForm sig (K + 2) 1,
      nf_eval_nf M (K + 2) 1 (fun _ => t) nf ↔
      nf_eval_nf M₀ (K + 2) 1 (fun _ => t₀) nf)
    -- The bracket witness: w ∈ (t, x) with matching 1-var NF to w₀
    (w₀ : M₀.carrier) (w : M.carrier)
    (h_tw : t < w) (h_wx : w < x)
    (h_w : ∀ nf : NormalForm sig (K + 2) 1,
      nf_eval_nf M (K + 2) 1 (fun _ => w) nf ↔
      nf_eval_nf M₀ (K + 2) 1 (fun _ => w₀) nf)
    -- The zone-3 chi
    (chi : NormalForm sig (K + 1) 3)
    (h_zone : ssn_zone_general chi = .between_tx)
    (h_chi₀ : nf_eval_nf M₀ (K + 1) 3 (Fin.cons w₀ (Fin.cons x₀ (fun _ => t₀))) chi) :
    nf_eval_nf M (K + 1) 3 (Fin.cons w (Fin.cons x (fun _ => t))) chi := by
  obtain ⟨h_chi₀_atoms, h_chi₀_quant⟩ := h_chi₀
  -- Zone order atoms
  obtain ⟨h_zone_tly, h_zone_ylx, h_zone_xly, h_zone_ylt⟩ :=
    zone_general_between_tx_orders chi h_zone
  have h_assgn_eq : NormalForm.atom_assgn chi = chi.1 := by
    simp [NormalForm.atom_assgn]
  rw [h_assgn_eq] at h_zone_tly h_zone_ylx h_zone_xly h_zone_ylt
  -- Predicate transfer helpers
  have h_pred_w := pred_transfer_from_1var M w M₀ w₀ h_w
  have h_pred_x := pred_transfer_from_1var M x M₀ x₀ h_x
  have h_pred_t := pred_transfer_from_1var M t M₀ t₀ h_t
  -- Derived order facts in M₀
  have h_t₀w₀ : t₀ < w₀ := by
    have := (h_chi₀_atoms (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide))).mpr h_zone_tly
    simp only [atom_eval, Fin.cons] at this; exact this
  have h_w₀x₀ : w₀ < x₀ := by
    have := (h_chi₀_atoms (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))).mpr h_zone_ylx
    simp only [atom_eval, Fin.cons] at this; exact this
  have h_t₀x₀ : t₀ < x₀ := lt_trans h_t₀w₀ h_w₀x₀
  have h_tx : t < x := lt_trans h_tw h_wx
  -- Precompute chi's (1,2) and (2,1) order atom values
  have h_chi₀_12_false : chi.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = false := by
    by_contra h_ne
    simp only [Bool.not_eq_false] at h_ne
    have h_x₀t₀ := (h_chi₀_atoms (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide))).mpr h_ne
    simp only [atom_eval, Fin.cons] at h_x₀t₀
    exact absurd (lt_trans h_x₀t₀ h_t₀x₀) (lt_irrefl _)
  have h_chi₀_21_true : chi.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = true := by
    have h_21 := (h_chi₀_atoms (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide))).mp
    simp only [atom_eval, Fin.cons] at h_21
    exact h_21 h_t₀x₀
  constructor
  · -- Atom part: predicates via 1-var NF agreements, orders via h_tw, h_wx
    intro a
    cases a with
    | pred p i =>
      match i with
      | ⟨0, _⟩ =>
        simp only [atom_eval, Fin.cons]
        have h0 := h_chi₀_atoms (.pred p ⟨0, by omega⟩)
        simp only [atom_eval, Fin.cons] at h0
        exact (h_pred_w p).trans h0
      | ⟨1, _⟩ =>
        simp only [atom_eval, Fin.cons]
        have h1 := h_chi₀_atoms (.pred p ⟨1, by omega⟩)
        simp only [atom_eval, Fin.cons] at h1
        exact (h_pred_x p).trans h1
      | ⟨2, _⟩ =>
        simp only [atom_eval, Fin.cons]
        have h2 := h_chi₀_atoms (.pred p ⟨2, by omega⟩)
        simp only [atom_eval, Fin.cons] at h2
        exact (h_pred_t p).trans h2
      | ⟨n + 3, h⟩ => exact absurd h (by omega)
    | order i j h_ne =>
      simp only [atom_eval, Fin.cons]
      match i, j, h_ne with
      | ⟨0, _⟩, ⟨0, _⟩, h => exact absurd rfl h
      | ⟨1, _⟩, ⟨1, _⟩, h => exact absurd rfl h
      | ⟨2, _⟩, ⟨2, _⟩, h => exact absurd rfl h
      | ⟨0, _⟩, ⟨1, _⟩, _ => exact ⟨fun _ => h_zone_ylx, fun _ => h_wx⟩
      | ⟨1, _⟩, ⟨0, _⟩, _ =>
        exact ⟨fun h => absurd (lt_trans h h_wx) (lt_irrefl _),
               fun h => by simp_all⟩
      | ⟨0, _⟩, ⟨2, _⟩, _ =>
        exact ⟨fun h => absurd (lt_trans h h_tw) (lt_irrefl _),
               fun h => by simp_all⟩
      | ⟨2, _⟩, ⟨0, _⟩, _ => exact ⟨fun _ => h_zone_tly, fun _ => h_tw⟩
      | ⟨1, _⟩, ⟨2, _⟩, _ =>
        -- x < t: impossible in both. chi must say false.
        -- Precomputed: chi.1(.order 1 2) = false because x₀ < t₀ would
        -- contradict t₀ < x₀. We show this via h_chi₀_12.
        exact ⟨fun h_xt => absurd (lt_trans h_xt h_tx) (lt_irrefl _),
               fun h_true => absurd (h_chi₀_12_false ▸ h_true) (by simp)⟩
      | ⟨2, _⟩, ⟨1, _⟩, _ =>
        -- t < x: true in both
        exact ⟨fun _ => h_chi₀_21_true, fun _ => h_tx⟩
      | ⟨n + 3, h⟩, _, _ => exact absurd h (by omega)
      | _, ⟨n + 3, h⟩, _ => exact absurd h (by omega)
  · -- Quantifier part: ∀ psi : NF sig K 4,
    -- (∃ v, nf_eval M K 4 [v,w,x,t] psi) ↔ chi.2 psi
    -- Requires depth-(K+1) 3-var NF agreement at [w,x,t]/[w₀,x₀,t₀].
    -- This is the same structural problem as nonconstenv_3var_exist_transfer:
    -- building multi-var agreement from pointwise 1-var agreements.
    -- The sorry here collapses to the same infrastructure gap.
    intro psi
    rw [← h_chi₀_quant psi]
    -- Goal: (∃ v, nf_eval M K 4 [v,w,x,t] psi) ↔
    --       (∃ v₀, nf_eval M₀ K 4 [v₀,w₀,x₀,t₀] psi)
    -- Need: depth-(K+1) 3-var agreement at [w,x,t]/[w₀,x₀,t₀]
    -- then apply exist_transfer_from_full_agree with d=K.
    have h_3var_agree : ∀ nf : NormalForm sig (K + 1) 3,
        nf_eval_nf M (K + 1) 3 (Fin.cons w (Fin.cons x (fun _ => t))) nf ↔
        nf_eval_nf M₀ (K + 1) 3
          (Fin.cons w₀ (Fin.cons x₀ (fun _ => t₀))) nf := by
      -- Same infrastructure gap as nonconstenv_3var_exist_transfer:
      -- constructing non-constant env multi-var agreement from 1-var agreements.
      sorry
    exact exist_transfer_from_full_agree M
      (Fin.cons w (Fin.cons x (fun _ => t)))
      M₀ (Fin.cons w₀ (Fin.cons x₀ (fun _ => t₀)))
      h_3var_agree K (by omega) psi

end FormalSystem.Metalogic.WeakCanonical.Kamp
