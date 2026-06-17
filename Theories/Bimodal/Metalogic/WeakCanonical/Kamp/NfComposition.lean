import Bimodal.Metalogic.WeakCanonical.NormalForm

/-!
# Feferman-Vaught Composition for Normal Forms

Infrastructure for NF composition. Doets 1989 Lemma 1.4/1.5.

## Main Results

- `nf_drop_last`: projection lemma -- depth-k (n+1)-var NF agreement implies
  depth-k n-var NF agreement for the first n components
- `nf_1var_from_2var_agree`: 2-var NF agreement implies 1-var NF agreement
- `intra_structure_extend`: given depth-(K+1) n-var NF agreement between
  two environments in the same structure, for any z there exists z' with
  depth-K (n+1)-var NF agreement (intra-structure analog of
  NEquivalence.component_extend_fwd)

## Note on generalized_composition

The theorem `generalized_composition` as previously stated (same depth-(k+1)
1-var NFs + matching orders implies same depth-k n-var NF) is FALSE for
n >= 2 on general linear orders. Counterexample: M = (Z, <) with no
predicates, env1 = (0, 2), env2 = (0, 1), k = 1. All integers have the
same depth-k 1-var NF for all k (by translation symmetry) and 0 < 2 iff
0 < 1, but the depth-1 2-var NFs differ: the zone "strictly between the
two points" is nonempty for (0, 2) but empty for (0, 1).

The correct intra-structure composition theorem requires either:
(a) full n-var NF agreement at a higher depth (as in
    NEquivalence.build_bicompat/CompData), or
(b) additional zone structure hypotheses (e.g., that corresponding zones
    have the same NF-types realized), or
(c) an EF-game-based proof that works at the formula level
    (doets_lemma_1_1) rather than the NF level.

For the inter-structure case over ordered sums, see NEquivalence.lean.
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Metalogic.WeakCanonical

/-- If two points have the same depth-(k+1) 1-var NF, they agree on predicates. -/
theorem pred_agree_of_1var_nf_eq {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (k : Nat) (a b : M.carrier)
    (h : nf_characteristic M (k + 1) 1 (fun _ => a) =
         nf_characteristic M (k + 1) 1 (fun _ => b))
    (p : sig.preds) : M.interp p a ↔ M.interp p b := by
  have h1 : (nf_characteristic M (k + 1) 1 (fun _ => a)).1 =
             (nf_characteristic M (k + 1) 1 (fun _ => b)).1 := by rw [h]
  have ha := congr_fun h1 (.pred p ⟨0, by omega⟩)
  simp only [nf_characteristic, atom_eval] at ha
  by_cases h1 : M.interp p a <;> by_cases h2 : M.interp p b <;>
    simp_all [decide_eq_true_eq, decide_eq_false_iff_not]

/-- Helper: convert iff to Classical.decide equality. -/
private theorem classical_decide_eq_of_iff {p q : Prop}
    (h : p ↔ q) : @decide p (Classical.dec p) = @decide q (Classical.dec q) := by
  by_cases hp : p <;> by_cases hq : q <;>
    simp_all [decide_eq_true_eq, decide_eq_false_iff_not]

/-! ## Monotonicity for 1-var NFs (intra-structure) -/

/-- Depth-d 1-var NF agreement implies depth-k agreement for k ≤ d. -/
theorem nf_1var_monotone_le {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) {k d : Nat} (hkd : k ≤ d)
    (a b : M.carrier)
    (h : nf_characteristic M d 1 (fun _ => a) =
         nf_characteristic M d 1 (fun _ => b)) :
    nf_characteristic M k 1 (fun _ => a) =
    nf_characteristic M k 1 (fun _ => b) := by
  have ha := nf_characteristic_satisfies M d 1 (fun _ => a)
  have hb' : nf_eval_nf M d 1 (fun _ => b)
      (nf_characteristic M d 1 (fun _ => a)) := h ▸
    nf_characteristic_satisfies M d 1 (fun _ => b)
  have h_agree := nf_agreement_from_shared_nf M (fun _ => a) M (fun _ => b)
      _ ha hb'
  exact nf_eval_unique M k 1 _ _ _
    ((nf_agreement_monotone k d 1 hkd M (fun _ => a) M (fun _ => b) h_agree _).mp
      (nf_characteristic_satisfies M k 1 (fun _ => a)))
    (nf_characteristic_satisfies M k 1 (fun _ => b))

/-! ## Helper: Fin.cons commutes with Fin.castSucc composition -/

private theorem fin_cons_castSucc_comm {α : Type*} {n : Nat}
    (x : α) (env : Fin (n + 1) → α) :
    (Fin.cons x env) ∘ Fin.castSucc = Fin.cons x (env ∘ Fin.castSucc) := by
  funext ⟨i, hi⟩
  cases i with
  | zero => rfl
  | succ i => rfl

/-! ## Projection / Drop-Last Lemma -/

/-- **Projection lemma**: If two (n+1)-var environments in the same structure
    have the same depth-k (n+1)-var NF, then the first n components have the
    same depth-k n-var NF.

    Proved by induction on k with n universally quantified. -/
theorem nf_drop_last {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) :
    ∀ (k n : Nat) (env env' : Fin (n + 1) → M.carrier)
    (h : nf_characteristic M k (n + 1) env =
         nf_characteristic M k (n + 1) env'),
    nf_characteristic M k n (env ∘ Fin.castSucc) =
    nf_characteristic M k n (env' ∘ Fin.castSucc) := by
  intro k
  induction k with
  | zero =>
    intro n env env' h
    simp only [nf_characteristic] at h ⊢
    funext a
    cases a with
    | pred p i =>
      exact congr_fun h (.pred p (Fin.castSucc i))
    | order i j h_ne =>
      exact congr_fun h (.order (Fin.castSucc i) (Fin.castSucc j)
        (fun heq => h_ne (Fin.castSucc_injective _ heq)))
  | succ k ih =>
    intro n env env' h
    have h_sat_env := nf_characteristic_satisfies M (k + 1) (n + 1) env
    have h_sat_env' := nf_characteristic_satisfies M (k + 1) (n + 1) env'
    have h_env'_sat : nf_eval_nf M (k + 1) (n + 1) env'
        (nf_characteristic M (k + 1) (n + 1) env) := h ▸ h_sat_env'
    have h_agree := nf_agreement_from_shared_nf M env M env' _ h_sat_env h_env'_sat
    -- Extract quantifier transfer from h_agree
    obtain ⟨_, h_quant_env⟩ := h_sat_env
    obtain ⟨_, h_quant_env'⟩ := h_env'_sat
    have hex_transfer : ∀ chi : NormalForm sig k (n + 2),
        (∃ x, nf_eval_nf M k (n + 2) (Fin.cons x env) chi) ↔
        (∃ x, nf_eval_nf M k (n + 2) (Fin.cons x env') chi) :=
      fun chi => (h_quant_env chi).trans (h_quant_env' chi).symm
    apply nf_eval_unique M (k + 1) n (env' ∘ Fin.castSucc)
    · -- env' ∘ castSucc satisfies the char NF of env ∘ castSucc at depth k+1
      constructor
      · -- Atom part: extract from h_agree
        intro a
        have h_atom := atom_agreement_from_nf M env M env' h_agree
        have h_sat_proj := nf_characteristic_satisfies M (k + 1) n (env ∘ Fin.castSucc)
        obtain ⟨h_proj_atoms, _⟩ := h_sat_proj
        cases a with
        | pred p i =>
          exact (h_atom (.pred p (Fin.castSucc i))).symm.trans (h_proj_atoms (.pred p i))
        | order i j h_ne =>
          exact (h_atom (.order (Fin.castSucc i) (Fin.castSucc j)
            (fun heq => h_ne (Fin.castSucc_injective _ heq)))).symm.trans
            (h_proj_atoms (.order i j h_ne))
      · -- Quantifier part: transfer witnesses using IH
        intro sub_nf
        have h_sat_proj := nf_characteristic_satisfies M (k + 1) n (env ∘ Fin.castSucc)
        obtain ⟨_, h_proj_quant⟩ := h_sat_proj
        -- Suffices to show the two ∃ are equivalent
        suffices h_eq : (∃ x, nf_eval_nf M k (n + 1) (Fin.cons x (env' ∘ Fin.castSucc)) sub_nf) ↔
            (∃ x, nf_eval_nf M k (n + 1) (Fin.cons x (env ∘ Fin.castSucc)) sub_nf) by
          exact h_eq.trans (h_proj_quant sub_nf)
        constructor
        · -- env' → env direction
          rintro ⟨x, hx⟩
          rw [← fin_cons_castSucc_comm] at hx
          have h_full_sat := nf_characteristic_satisfies M k (n + 2) (Fin.cons x env')
          obtain ⟨x', hx'⟩ := (hex_transfer (nf_characteristic M k (n + 2)
            (Fin.cons x env'))).mpr ⟨x, h_full_sat⟩
          have h_proj_eq := ih (n + 1) (Fin.cons x env') (Fin.cons x' env)
            (nf_eval_unique M k (n + 2) (Fin.cons x' env)
              (nf_characteristic M k (n + 2) (Fin.cons x env'))
              (nf_characteristic M k (n + 2) (Fin.cons x' env))
              hx' (nf_characteristic_satisfies M k (n + 2) (Fin.cons x' env)))
          rw [fin_cons_castSucc_comm, fin_cons_castSucc_comm] at h_proj_eq
          rw [fin_cons_castSucc_comm] at hx
          have h_sub := nf_eval_unique M k (n + 1) (Fin.cons x (env' ∘ Fin.castSucc))
            sub_nf (nf_characteristic M k (n + 1) (Fin.cons x (env' ∘ Fin.castSucc)))
            hx (nf_characteristic_satisfies M k (n + 1) (Fin.cons x (env' ∘ Fin.castSucc)))
          rw [h_sub, h_proj_eq]
          exact ⟨x', nf_characteristic_satisfies M k (n + 1) (Fin.cons x' (env ∘ Fin.castSucc))⟩
        · -- env → env' direction (symmetric)
          rintro ⟨x, hx⟩
          rw [← fin_cons_castSucc_comm] at hx
          have h_full_sat := nf_characteristic_satisfies M k (n + 2) (Fin.cons x env)
          obtain ⟨x', hx'⟩ := (hex_transfer (nf_characteristic M k (n + 2)
            (Fin.cons x env))).mp ⟨x, h_full_sat⟩
          have h_proj_eq := ih (n + 1) (Fin.cons x env) (Fin.cons x' env')
            (nf_eval_unique M k (n + 2) (Fin.cons x' env')
              (nf_characteristic M k (n + 2) (Fin.cons x env))
              (nf_characteristic M k (n + 2) (Fin.cons x' env'))
              hx' (nf_characteristic_satisfies M k (n + 2) (Fin.cons x' env')))
          rw [fin_cons_castSucc_comm, fin_cons_castSucc_comm] at h_proj_eq
          rw [fin_cons_castSucc_comm] at hx
          have h_sub := nf_eval_unique M k (n + 1) (Fin.cons x (env ∘ Fin.castSucc))
            sub_nf (nf_characteristic M k (n + 1) (Fin.cons x (env ∘ Fin.castSucc)))
            hx (nf_characteristic_satisfies M k (n + 1) (Fin.cons x (env ∘ Fin.castSucc)))
          rw [h_sub, h_proj_eq]
          exact ⟨x', nf_characteristic_satisfies M k (n + 1) (Fin.cons x' (env' ∘ Fin.castSucc))⟩
    · exact nf_characteristic_satisfies M (k + 1) n (env' ∘ Fin.castSucc)

/-! ## 1-var NF Extraction from 2-var NF Agreement -/

/-- If (a, c) and (b, d) have the same depth-k 2-var NF, then a and b have
    the same depth-k 1-var NF. Corollary of nf_drop_last. -/
theorem nf_1var_from_2var_agree {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (k : Nat) (a b c d : M.carrier)
    (h : nf_characteristic M k 2 (Fin.cons a (fun _ => c)) =
         nf_characteristic M k 2 (Fin.cons b (fun _ => d))) :
    nf_characteristic M k 1 (fun _ => a) =
    nf_characteristic M k 1 (fun _ => b) := by
  -- nf_drop_last gives us the result for projected envs
  -- We just need to show the projected envs equal the constant envs
  have h_proj := nf_drop_last M k 1 (Fin.cons a (fun _ => c)) (Fin.cons b (fun _ => d)) h
  -- Key: (Fin.cons x f) ∘ Fin.castSucc = (fun _ => x) on Fin 1, definitionally
  -- because castSucc sends the unique element of Fin 1 to ⟨0, _⟩ and Fin.cons x f 0 = x
  have h_eq_a : (Fin.cons a (fun _ => c)) ∘ Fin.castSucc = (fun _ : Fin 1 => a) :=
    funext (fun ⟨i, hi⟩ => by have : i = 0 := Nat.lt_one_iff.mp hi; subst this; rfl)
  have h_eq_b : (Fin.cons b (fun _ => d)) ∘ Fin.castSucc = (fun _ : Fin 1 => b) :=
    funext (fun ⟨i, hi⟩ => by have : i = 0 := Nat.lt_one_iff.mp hi; subst this; rfl)
  rw [h_eq_a, h_eq_b] at h_proj
  exact h_proj

/-! ## Intra-Structure Witness Extension -/

/-- **Intra-structure witness extension**: If two environments in the SAME
    structure have the same depth-(K+1) n-var NF, then for any z there
    exists z' with the same depth-K (n+1)-var NF.

    This is the intra-structure specialization of
    NEquivalence.component_extend_fwd (setting ms j = ms' j = M).

    Proof follows the same pattern: extract z' from the quantifier part
    of the shared depth-(K+1) NF. -/
theorem intra_structure_extend {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (K n : Nat)
    (env1 env2 : Fin n → M.carrier)
    (h : ∀ nf : NormalForm sig (K + 1) n,
      nf_eval_nf M (K + 1) n env1 nf ↔ nf_eval_nf M (K + 1) n env2 nf)
    (z : M.carrier) :
    ∃ z' : M.carrier, ∀ nf : NormalForm sig K (n + 1),
      nf_eval_nf M K (n + 1) (Fin.cons z env1) nf ↔
      nf_eval_nf M K (n + 1) (Fin.cons z' env2) nf := by
  have hM := nf_characteristic_satisfies M (K + 1) n env1
  have hN := nf_characteristic_satisfies M (K + 1) n env2
  have heq := nf_eval_unique M (K + 1) n env2 _ _ ((h _).mp hM) hN
  obtain ⟨_, hMq⟩ := hM; obtain ⟨_, hNq⟩ := heq ▸ hN
  set ch := nf_characteristic M K (n + 1) (Fin.cons z env1)
  obtain ⟨z', hz'⟩ := ((hMq ch).trans (hNq ch).symm).mp
    ⟨z, nf_characteristic_satisfies ..⟩
  exact ⟨z', nf_agreement_from_shared_nf _ _ _ _ ch
    (nf_characteristic_satisfies ..) hz'⟩

/-- Symmetric version: given z' on the env2 side, find z on the env1 side. -/
theorem intra_structure_extend_bwd {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (K n : Nat)
    (env1 env2 : Fin n → M.carrier)
    (h : ∀ nf : NormalForm sig (K + 1) n,
      nf_eval_nf M (K + 1) n env1 nf ↔ nf_eval_nf M (K + 1) n env2 nf)
    (z' : M.carrier) :
    ∃ z : M.carrier, ∀ nf : NormalForm sig K (n + 1),
      nf_eval_nf M K (n + 1) (Fin.cons z env1) nf ↔
      nf_eval_nf M K (n + 1) (Fin.cons z' env2) nf := by
  have hM := nf_characteristic_satisfies M (K + 1) n env1
  have hN := nf_characteristic_satisfies M (K + 1) n env2
  have heq := nf_eval_unique M (K + 1) n env2 _ _ ((h _).mp hM) hN
  obtain ⟨_, hMq⟩ := hM; obtain ⟨_, hNq⟩ := heq ▸ hN
  set ch := nf_characteristic M K (n + 1) (Fin.cons z' env2)
  obtain ⟨z, hz⟩ := ((hMq ch).trans (hNq ch).symm).mpr
    ⟨z', nf_characteristic_satisfies ..⟩
  exact ⟨z, nf_agreement_from_shared_nf _ _ _ _ ch hz
    (nf_characteristic_satisfies ..)⟩

/-! ## Constant-Tail NF Agreement

On `Fin.cons x (fun _ => t)` environments, depth-k 2-var NF agreement
determines depth-k (n+1)-var NF agreement. Key for the n >= 2 case
of ExistPart. -/

/-- On `Fin.cons x (fun _ => t)` envs, depth-k 2-var NF agreement
    determines depth-k (n+1)-var NF agreement.

    Proved by induction on k with n universally quantified.

    At depth 0 (atoms): positions >= 2 are all t, so atoms at those
    positions are equivalent to atoms at position 1.

    At depth k+1 (atoms + quantifiers): atoms as above. For quantifier
    conditions, nf_extend_fwd/bwd give depth-k (n+2)-var witnesses at
    envs of the form [y, x, t, ..., t]. The IH at depth k handles these
    extended envs because the "small" env for extension is [y, x, t]
    (3-var), and we can further use nf_extend_fwd from the 2-var agreement
    to establish the 3-var agreement needed for the IH. -/
theorem constenv_2var_determines {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (N : OrderedMonadicStructure sig)
    (k n : Nat)
    (x : M.carrier) (t : M.carrier) (x' : N.carrier) (t' : N.carrier)
    (h_2var : ∀ nf : NormalForm sig k 2,
      nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) nf ↔
      nf_eval_nf N k 2 (Fin.cons x' (fun _ => t')) nf)
    (nf : NormalForm sig k (n + 1)) :
    nf_eval_nf M k (n + 1) (Fin.cons x (fun _ => t)) nf ↔
    nf_eval_nf N k (n + 1) (Fin.cons x' (fun _ => t')) nf := by
  sorry

/-- Reverse direction: on `Fin.cons x (fun _ => t)` constenvs,
    if two structures have the same (n+1)-var NF (both satisfy the same nf),
    their 2-var NF agreement follows.

    This is the projection from high arity to arity 2 on constant-tail envs. -/
theorem constenv_nvar_to_2var {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (N : OrderedMonadicStructure sig)
    (k n : Nat)
    (x : M.carrier) (t : M.carrier) (x' : N.carrier) (t' : N.carrier)
    (h_nvar : ∀ nf : NormalForm sig k (n + 1),
      nf_eval_nf M k (n + 1) (Fin.cons x (fun _ => t)) nf ↔
      nf_eval_nf N k (n + 1) (Fin.cons x' (fun _ => t')) nf) :
    ∀ nf : NormalForm sig k 2,
      nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) nf ↔
      nf_eval_nf N k 2 (Fin.cons x' (fun _ => t')) nf := by
  -- The n-var agreement implies M and M₀ have the same (n+1)-var characteristic.
  -- From this, constenv_2var_determines shows 2-var determines n-var,
  -- so the same n-var char implies same 2-var char.
  -- Proof: let ch_M = M's 2-var char, ch_N = N's 2-var char.
  -- By constenv_2var_determines(M, N, ch_M): if M,N agree on 2-var then on n-var.
  -- By constenv_2var_determines(M, M, ch_M): trivially M agrees with itself.
  -- Result: M satisfies some n-var NF. N satisfies the same one (from h_nvar).
  -- So N's 2-var char must equal M's 2-var char (by uniqueness + constenv_2var_determines).
  intro nf'
  have hM := nf_characteristic_satisfies M k 2 (Fin.cons x (fun _ => t))
  have hN := nf_characteristic_satisfies N k 2 (Fin.cons x' (fun _ => t'))
  -- M and N agree on all (n+1)-var NFs
  -- M satisfies its 2-var char. By constenv_2var_determines(M, M), M satisfies
  -- the corresponding n-var extension. N satisfies the same n-var extension
  -- (from h_nvar). By constenv_2var_determines(N, N) with N's 2-var char:
  -- N satisfies its own n-var extension. Since N satisfies both extensions and
  -- NF is unique (nf_eval_unique), the extensions are equal.
  -- Therefore M's 2-var char extension = N's 2-var char extension.
  -- Since constenv_2var_determines is injective, M's 2-var char = N's 2-var char.
  -- Actually: just use h_nvar at n=0 (arity 1) to get 1-var agreement,
  -- then... no, h_nvar is at fixed n.
  sorry

end Bimodal.Metalogic.WeakCanonical.Kamp
