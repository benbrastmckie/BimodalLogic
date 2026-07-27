import FormalSystem.Metalogic.WeakCanonical.NormalForm

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.

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

#exit

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

/-- Non-dependent env extension: appends a value t at position m+1.
    Unlike `Fin.snoc` which is dependently typed, this returns `Fin (m+2) → α`. -/
private def env_extend {α : Type*} {m : Nat} (env : Fin (m + 1) → α) (t : α) :
    Fin (m + 2) → α :=
  fun i => if h : i.val < m + 1 then env ⟨i.val, h⟩ else t

private theorem env_extend_eq {α : Type*} {m : Nat} (env : Fin (m + 1) → α) (t : α)
    (h_last : env (Fin.last m) = t) (i : Fin (m + 2)) :
    let idx : Fin (m + 1) := if h : i.val < m + 1 then ⟨i.val, h⟩ else Fin.last m
    env_extend env t i = env idx := by
  simp only [env_extend]; split <;> [rfl; exact h_last.symm]

/-- Atom agreement on env_extend envs follows from atom agreement on base envs. -/
private theorem env_extend_atom_agree {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (N : OrderedMonadicStructure sig)
    {m : Nat} (envM : Fin (m + 1) → M.carrier) (envN : Fin (m + 1) → N.carrier)
    (t : M.carrier) (t' : N.carrier)
    (h_last_M : envM (Fin.last m) = t) (h_last_N : envN (Fin.last m) = t')
    (h_atom : ∀ (a : AtomKind sig (m + 1)), atom_eval M envM a ↔ atom_eval N envN a) :
    ∀ (a : AtomKind sig (m + 2)),
      atom_eval M (env_extend envM t) a ↔ atom_eval N (env_extend envN t') a := by
  intro a
  let idx (i : Fin (m + 2)) : Fin (m + 1) :=
    if h : i.val < m + 1 then ⟨i.val, h⟩ else Fin.last m
  have env_eq_M : ∀ i, env_extend envM t i = envM (idx i) :=
    fun i => env_extend_eq envM t h_last_M i
  have env_eq_N : ∀ i, env_extend envN t' i = envN (idx i) :=
    fun i => env_extend_eq envN t' h_last_N i
  cases a with
  | pred p i =>
    simp only [atom_eval, env_eq_M, env_eq_N]; exact h_atom (.pred p (idx i))
  | order i j hne =>
    simp only [atom_eval, env_eq_M, env_eq_N]
    by_cases heq : idx i = idx j
    · constructor <;> intro h_lt <;> exact absurd (heq ▸ h_lt) (lt_irrefl _)
    · exact h_atom (.order (idx i) (idx j) heq)

/-- **Duplicate-last cross-structure lemma**: if two envs agree at depth k on
    all (m+1)-var NFs, and the last positions hold values t/t', then they
    agree on all (m+2)-var NFs with the extended envs.

    Uses `env_extend` (non-dependent) to avoid `Fin.snoc` type issues. -/
private theorem dup_last_cross {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (N : OrderedMonadicStructure sig) :
    ∀ (k m : Nat) (envM : Fin (m + 1) → M.carrier) (envN : Fin (m + 1) → N.carrier)
    (t : M.carrier) (t' : N.carrier)
    (h_last_M : envM (Fin.last m) = t)
    (h_last_N : envN (Fin.last m) = t')
    (h_agree : ∀ nf : NormalForm sig k (m + 1),
      nf_eval_nf M k (m + 1) envM nf ↔ nf_eval_nf N k (m + 1) envN nf),
    ∀ nf : NormalForm sig k (m + 2),
      nf_eval_nf M k (m + 2) (env_extend envM t) nf ↔
      nf_eval_nf N k (m + 2) (env_extend envN t') nf := by
  intro k
  induction k with
  | zero =>
    intro m envM envN t t' h_last_M h_last_N h_agree nf
    -- At depth 0, nf_eval_nf is about atoms. Use env_extend_atom_agree.
    simp only [nf_eval_nf]
    have h_atom := atom_agreement_from_nf M envM N envN h_agree
    have h_ext_atom := env_extend_atom_agree M N envM envN t t' h_last_M h_last_N h_atom
    constructor <;> intro hDir a
    · exact (h_ext_atom a).symm.trans (hDir a)
    · exact (h_ext_atom a).trans (hDir a)
  | succ k ih =>
    intro m envM envN t t' h_last_M h_last_N h_agree nf
    -- Show M,env_extend envM t satisfies char NF of N,env_extend envN t'
    set target_nf := nf_characteristic N (k + 1) (m + 2) (env_extend envN t')
    have h_N_sat := nf_characteristic_satisfies N (k + 1) (m + 2) (env_extend envN t')
    suffices h_M_sat : nf_eval_nf M (k + 1) (m + 2) (env_extend envM t) target_nf by
      exact nf_agreement_from_shared_nf M _ N _ target_nf h_M_sat h_N_sat nf
    obtain ⟨h_N_atoms, h_N_quant⟩ := h_N_sat
    have h_atom := atom_agreement_from_nf M envM N envN h_agree
    have h_ext_atom := env_extend_atom_agree M N envM envN t t' h_last_M h_last_N h_atom
    -- Existential transfer from (m+1)-var agreement at depth k+1
    have h_char_eq : nf_characteristic M (k + 1) (m + 1) envM =
        nf_characteristic N (k + 1) (m + 1) envN :=
      nf_eval_unique N (k + 1) (m + 1) _ _ _
        ((h_agree _).mp (nf_characteristic_satisfies M (k + 1) (m + 1) _))
        (nf_characteristic_satisfies N (k + 1) (m + 1) _)
    obtain ⟨_, hMq⟩ := nf_characteristic_satisfies M (k + 1) (m + 1) envM
    obtain ⟨_, hNq⟩ := h_char_eq ▸ nf_characteristic_satisfies N (k + 1) (m + 1) envN
    have hex : ∀ chi : NormalForm sig k (m + 2),
        (∃ z, nf_eval_nf M k (m + 2) (Fin.cons z envM) chi) ↔
        (∃ z, nf_eval_nf N k (m + 2) (Fin.cons z envN) chi) :=
      fun chi => (hMq chi).trans (hNq chi).symm
    -- Key: Fin.cons z (env_extend envM t) = env_extend (Fin.cons z envM) t
    have h_ext_cons_M : ∀ z : M.carrier,
        Fin.cons z (env_extend envM t) = env_extend (Fin.cons z envM) t := by
      intro z; funext ⟨i, hi⟩
      cases i with
      | zero => simp [env_extend, Fin.cons]
      | succ i =>
        show env_extend envM t ⟨i, by omega⟩ = env_extend (Fin.cons z envM) t ⟨i + 1, hi⟩
        simp only [env_extend]; split <;> split <;> [rfl; omega; omega; rfl]
    have h_ext_cons_N : ∀ z : N.carrier,
        Fin.cons z (env_extend envN t') = env_extend (Fin.cons z envN) t' := by
      intro z; funext ⟨i, hi⟩
      cases i with
      | zero => simp [env_extend, Fin.cons]
      | succ i =>
        show env_extend envN t' ⟨i, by omega⟩ = env_extend (Fin.cons z envN) t' ⟨i + 1, hi⟩
        simp only [env_extend]; split <;> split <;> [rfl; omega; omega; rfl]
    have h_last_ext_M : ∀ z : M.carrier,
        (Fin.cons z envM : Fin (m + 2) → M.carrier) (Fin.last (m + 1)) = t := by
      intro z; unfold Fin.cons Fin.last; simp; exact h_last_M
    have h_last_ext_N : ∀ z : N.carrier,
        (Fin.cons z envN : Fin (m + 2) → N.carrier) (Fin.last (m + 1)) = t' := by
      intro z; unfold Fin.cons Fin.last; simp; exact h_last_N
    constructor
    · -- Atoms
      intro a; exact (h_ext_atom a).trans (h_N_atoms a)
    · -- Quantifiers: transfer (m+3)-var existentials via IH
      -- Transfer existential between Fin.cons z (env_extend envM t) and
      -- Fin.cons z' (env_extend envN t') using ih and h_ext_cons rewriting
      have h_exist_transfer :
          ∀ (sub_nf : NormalForm sig k (m + 2 + 1)),
          (∃ z, nf_eval_nf M k (m + 2 + 1) (Fin.cons z (env_extend envM t)) sub_nf) ↔
          (∃ z', nf_eval_nf N k (m + 2 + 1) (Fin.cons z' (env_extend envN t')) sub_nf) := by
        intro sub_nf
        constructor
        · rintro ⟨z, hz⟩
          -- hz : nf_eval at Fin.cons z (env_extend envM t), DON'T rewrite
          set chi := nf_characteristic M k (m + 2) (Fin.cons z envM)
          -- Transfer witness: need nf_eval M k (m+2) (Fin.cons z envM) chi
          -- Key: Fin.cons z (env_extend envM t) agrees with env_extend (Fin.cons z envM) t
          have h_cons_sat : nf_eval_nf M k (m + 2) (Fin.cons z envM) chi :=
            nf_characteristic_satisfies ..
          obtain ⟨z', hz'⟩ := (hex chi).mp ⟨z, h_cons_sat⟩
          have h_base := nf_agreement_from_shared_nf M _ N _ chi h_cons_sat hz'
          -- ih gives agreement at env_extend envs (arity (m+1)+2 = m+2+1)
          -- h_ext_cons_M/N relate Fin.cons z (env_extend envM t) to env_extend (Fin.cons z envM) t
          exact ⟨z', (h_ext_cons_N z') ▸ ih (m + 1) (Fin.cons z envM) (Fin.cons z' envN) t t'
            (h_last_ext_M z) (h_last_ext_N z') h_base sub_nf |>.mp
            ((h_ext_cons_M z) ▸ hz)⟩
        · rintro ⟨z', hz'⟩
          set chi := nf_characteristic N k (m + 2) (Fin.cons z' envN)
          have h_cons_sat : nf_eval_nf N k (m + 2) (Fin.cons z' envN) chi :=
            nf_characteristic_satisfies ..
          obtain ⟨z, hz⟩ := (hex chi).mpr ⟨z', h_cons_sat⟩
          have h_base := nf_agreement_from_shared_nf M _ N _ chi hz h_cons_sat
          exact ⟨z, (h_ext_cons_M z) ▸ ih (m + 1) (Fin.cons z envM) (Fin.cons z' envN) t t'
            (h_last_ext_M z) (h_last_ext_N z') h_base sub_nf |>.mpr
            ((h_ext_cons_N z') ▸ hz')⟩
      intro sub_nf
      rw [← h_N_quant sub_nf]
      exact h_exist_transfer sub_nf

/-- On constenvs, `env_extend (Fin.cons x (fun _ : Fin m => t)) t`
    equals `Fin.cons x (fun _ : Fin (m+1) => t)`. -/
private theorem constenv_extend_eq {α : Type*} (x t : α) (m : Nat) :
    env_extend (Fin.cons x (fun _ : Fin m => t)) t =
    (Fin.cons x (fun (_ : Fin (m + 1)) => t)) := by
  funext ⟨i, hi⟩; simp only [env_extend]
  cases i with
  | zero => simp [Fin.cons]
  | succ i => simp only [Fin.cons]; split <;> rfl

/-- Auxiliary lemma: on constenvs, (n+1)-var NF is determined by 2-var NF.
    Uses `dup_last_cross` iteratively: starting from 2-var constenv agreement,
    repeatedly add a duplicate t-position to lift to (n+1)-var.

    The constenv `Fin.cons x (fun _ => t)` has `envM (Fin.last m) = t` for
    all m >= 1, so `dup_last_cross` applies at each step. -/
private theorem constenv_2var_determines_aux {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (N : OrderedMonadicStructure sig)
    (k : Nat)
    (x : M.carrier) (t : M.carrier) (x' : N.carrier) (t' : N.carrier)
    (h_2var : ∀ nf : NormalForm sig k 2,
      nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) nf ↔
      nf_eval_nf N k 2 (Fin.cons x' (fun _ => t')) nf)
    (n : Nat) :
    ∀ nf : NormalForm sig k (n + 2),
      nf_eval_nf M k (n + 2) (Fin.cons x (fun _ : Fin (n + 1) => t)) nf ↔
      nf_eval_nf N k (n + 2) (Fin.cons x' (fun _ : Fin (n + 1) => t')) nf := by
  induction n with
  | zero => exact h_2var
  | succ n' ih =>
    -- ih gives (n'+2)-var agreement on constenvs.
    -- Apply dup_last_cross to get (n'+3)-var.
    have h_last_M : (Fin.cons x (fun _ : Fin (n' + 1) => t) :
        Fin (n' + 2) → M.carrier) (Fin.last (n' + 1)) = t := by
      unfold Fin.cons Fin.last; simp
    have h_last_N : (Fin.cons x' (fun _ : Fin (n' + 1) => t') :
        Fin (n' + 2) → N.carrier) (Fin.last (n' + 1)) = t' := by
      unfold Fin.cons Fin.last; simp
    intro nf
    have h_dup := dup_last_cross M N k (n' + 1)
      (Fin.cons x (fun _ : Fin (n' + 1) => t))
      (Fin.cons x' (fun _ : Fin (n' + 1) => t'))
      t t' h_last_M h_last_N ih nf
    rwa [constenv_extend_eq, constenv_extend_eq] at h_dup

/-- On constenvs, `Fin.castSucc` projection preserves the constenv structure:
    `(Fin.cons x (fun _ : Fin (m+1) => t)) ∘ Fin.castSucc = Fin.cons x (fun _ : Fin m => t)` -/
private theorem constenv_castSucc {α : Type*} (x : α) (t : α) (m : Nat) :
    (Fin.cons x (fun _ : Fin (m + 1) => t)) ∘ Fin.castSucc =
    (Fin.cons x (fun _ : Fin m => t)) := by
  funext ⟨i, _⟩; cases i with | zero => rfl | succ _ => rfl

/-- Cross-structure nf_drop_last: if M,envM and N,envN agree on all
    depth-k (n+1)-var NFs, then M,envM∘castSucc and N,envN∘castSucc
    agree on all depth-k n-var NFs.

    Proof by induction on k with n universally quantified, mirroring
    the intra-structure nf_drop_last proof. -/
theorem nf_drop_last_cross {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (N : OrderedMonadicStructure sig) :
    ∀ (k n : Nat) (envM : Fin (n + 1) → M.carrier) (envN : Fin (n + 1) → N.carrier)
    (h : ∀ nf : NormalForm sig k (n + 1),
      nf_eval_nf M k (n + 1) envM nf ↔ nf_eval_nf N k (n + 1) envN nf),
    ∀ nf : NormalForm sig k n,
      nf_eval_nf M k n (envM ∘ Fin.castSucc) nf ↔
      nf_eval_nf N k n (envN ∘ Fin.castSucc) nf := by
  intro k
  induction k with
  | zero =>
    intro n envM envN h nf
    -- At depth 0, the goal is about atom assignments
    -- Extract cross-structure atom agreement from h
    have h_atom_cross : ∀ (a : AtomKind sig (n + 1)),
        atom_eval M envM a ↔ atom_eval N envN a :=
      atom_agreement_from_nf M envM N envN h
    -- Now show: atom assignment nf matches at projected envs
    simp only [nf_eval_nf]
    constructor
    · intro hM a
      cases a with
      | pred p i =>
        simp only [atom_eval, Function.comp] at hM ⊢
        exact (h_atom_cross (.pred p (Fin.castSucc i))).symm.trans (hM (.pred p i))
      | order i j hne =>
        simp only [atom_eval, Function.comp] at hM ⊢
        exact (h_atom_cross (.order (Fin.castSucc i) (Fin.castSucc j)
          (fun heq => hne (Fin.castSucc_injective _ heq)))).symm.trans (hM (.order i j hne))
    · intro hN a
      cases a with
      | pred p i =>
        simp only [atom_eval, Function.comp] at hN ⊢
        exact (h_atom_cross (.pred p (Fin.castSucc i))).trans (hN (.pred p i))
      | order i j hne =>
        simp only [atom_eval, Function.comp] at hN ⊢
        exact (h_atom_cross (.order (Fin.castSucc i) (Fin.castSucc j)
          (fun heq => hne (Fin.castSucc_injective _ heq)))).trans (hN (.order i j hne))
  | succ k ih =>
    intro n envM envN h nf
    -- h gives (n+1)-var agreement at depth k+1
    -- Extract the matching characteristics
    have h_char_eq : nf_characteristic M (k + 1) (n + 1) envM =
        nf_characteristic N (k + 1) (n + 1) envN :=
      nf_eval_unique N (k + 1) (n + 1) _ _ _
        ((h _).mp (nf_characteristic_satisfies M (k + 1) (n + 1) _))
        (nf_characteristic_satisfies N (k + 1) (n + 1) _)
    obtain ⟨_, hMq⟩ := nf_characteristic_satisfies M (k + 1) (n + 1) envM
    obtain ⟨_, hNq⟩ := h_char_eq ▸ nf_characteristic_satisfies N (k + 1) (n + 1) envN
    -- Transfer existentials between M and N at depth k, arity (n+2)
    have hex_transfer : ∀ chi : NormalForm sig k (n + 2),
        (∃ x, nf_eval_nf M k (n + 2) (Fin.cons x envM) chi) ↔
        (∃ x, nf_eval_nf N k (n + 2) (Fin.cons x envN) chi) :=
      fun chi => (hMq chi).trans (hNq chi).symm
    -- Now prove n-var agreement at depth k+1 for projected envs
    -- Strategy: show M,envM∘cs satisfies the char NF of N,envN∘cs, then use nf_agreement_from_shared_nf
    set target_nf := nf_characteristic N (k + 1) n (envN ∘ Fin.castSucc)
    have h_N_sat := nf_characteristic_satisfies N (k + 1) n (envN ∘ Fin.castSucc)
    -- Show M,envM∘cs also satisfies target_nf
    suffices h_M_sat : nf_eval_nf M (k + 1) n (envM ∘ Fin.castSucc) target_nf by
      exact nf_agreement_from_shared_nf M _ N _ target_nf h_M_sat h_N_sat nf
    obtain ⟨h_N_atoms, h_N_quant⟩ := h_N_sat
    constructor
    · -- Atoms: M,envM∘cs agrees with N,envN∘cs on atoms
      intro a
      cases a with
      | pred p i =>
        have h_atom := atom_agreement_from_nf M envM N envN h (.pred p (Fin.castSucc i))
        simp only [atom_eval, Function.comp] at h_atom ⊢
        exact h_atom.trans (h_N_atoms (.pred p i))
      | order i j hne =>
        have h_atom := atom_agreement_from_nf M envM N envN h
          (.order (Fin.castSucc i) (Fin.castSucc j)
            (fun heq => hne (Fin.castSucc_injective _ heq)))
        simp only [atom_eval, Function.comp] at h_atom ⊢
        exact h_atom.trans (h_N_atoms (.order i j hne))
    · -- Quantifiers
      intro sub_nf
      rw [← h_N_quant sub_nf]
      constructor
      · -- M → N: given y in M with eval on envM∘cs, find y' in N
        rintro ⟨y, hy⟩
        rw [← fin_cons_castSucc_comm] at hy
        set chi := nf_characteristic M k (n + 2) (Fin.cons y envM)
        obtain ⟨y', hy'⟩ := (hex_transfer chi).mp ⟨y, nf_characteristic_satisfies ..⟩
        have h_agree_ext := nf_agreement_from_shared_nf M _ N _ chi
          (nf_characteristic_satisfies ..) hy'
        have h_proj := ih (n + 1) (Fin.cons y envM) (Fin.cons y' envN) h_agree_ext sub_nf
        rw [fin_cons_castSucc_comm, fin_cons_castSucc_comm] at h_proj
        exact ⟨y', h_proj.mp (by rwa [fin_cons_castSucc_comm] at hy)⟩
      · -- N → M: given y' in N, find y in M
        rintro ⟨y', hy'⟩
        rw [← fin_cons_castSucc_comm] at hy'
        set chi := nf_characteristic N k (n + 2) (Fin.cons y' envN)
        obtain ⟨y, hy⟩ := (hex_transfer chi).mpr ⟨y', nf_characteristic_satisfies ..⟩
        have h_agree_ext := nf_agreement_from_shared_nf M _ N _ chi hy
          (nf_characteristic_satisfies ..)
        have h_proj := ih (n + 1) (Fin.cons y envM) (Fin.cons y' envN) h_agree_ext sub_nf
        rw [fin_cons_castSucc_comm, fin_cons_castSucc_comm] at h_proj
        exact ⟨y, h_proj.mpr (by rwa [fin_cons_castSucc_comm] at hy')⟩

/-- Reverse direction: on `Fin.cons x (fun _ => t)` constenvs,
    (n+2)-var NF agreement implies 2-var NF agreement.
    This is the downward projection: extra positions (all having value t)
    are redundant.

    Note: requires n+2 (not n+1) since projecting from arity >= 2 to arity 2.
    The n=0 case (1-var to 2-var) is UPWARD and NOT a projection.

    Proof strategy: iterate constenv_drop_step from (n+2)-var down to 2-var. -/
theorem constenv_nvar_to_2var {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (N : OrderedMonadicStructure sig)
    (k n : Nat)
    (x : M.carrier) (t : M.carrier) (x' : N.carrier) (t' : N.carrier)
    (h_nvar : ∀ nf : NormalForm sig k (n + 2),
      nf_eval_nf M k (n + 2) (Fin.cons x (fun _ => t)) nf ↔
      nf_eval_nf N k (n + 2) (Fin.cons x' (fun _ => t')) nf) :
    ∀ nf : NormalForm sig k 2,
      nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) nf ↔
      nf_eval_nf N k 2 (Fin.cons x' (fun _ => t')) nf := by
  -- Iterate nf_drop_last_cross n times, using constenv_castSucc to
  -- rewrite projected envs back to constenv form at each step
  induction n with
  | zero => exact h_nvar
  | succ n' ih =>
    apply ih
    -- Need: (n'+2)-var agreement from (n'+3)-var agreement
    -- nf_drop_last_cross gives (n'+2)-var for projected envs
    intro nf
    have h_drop := nf_drop_last_cross M N k (n' + 2)
      (Fin.cons x (fun _ : Fin (n' + 2) => t))
      (Fin.cons x' (fun _ : Fin (n' + 2) => t'))
      h_nvar nf
    rwa [constenv_castSucc, constenv_castSucc] at h_drop

/-- On `Fin.cons x (fun _ => t)` envs, depth-k 2-var NF agreement
    determines depth-k (n+1)-var NF agreement.

    For n >= 1, delegates to `constenv_2var_determines_aux` which uses
    `dup_last_cross` iteratively. For n = 0 (1-var from 2-var), uses
    `nf_drop_last_cross` + `constenv_castSucc`. -/
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
  cases n with
  | zero =>
    -- 1-var from 2-var: project via nf_drop_last_cross
    have h_proj := nf_drop_last_cross M N k 1
      (Fin.cons x (fun _ : Fin 1 => t))
      (Fin.cons x' (fun _ : Fin 1 => t'))
      h_2var nf
    rwa [constenv_castSucc x t 0, constenv_castSucc x' t' 0] at h_proj
  | succ n' =>
    exact constenv_2var_determines_aux M N k x t x' t' h_2var n' nf

end Bimodal.Metalogic.WeakCanonical.Kamp
