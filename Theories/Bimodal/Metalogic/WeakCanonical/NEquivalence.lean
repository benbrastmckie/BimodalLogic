import Bimodal.Metalogic.WeakCanonical.ReflexiveCanonical
import Bimodal.Metalogic.WeakCanonical.ChronicleExtraction
import Bimodal.Metalogic.WeakCanonical.MonadicFO
import Bimodal.Metalogic.WeakCanonical.NormalForm
import Mathlib.Data.Sigma.Order

/-!
# k-Equivalence Framework and Chronicle Integration

Defines the k-equivalence framework for ordered monadic structures, connecting
the monadic FO definitions (from MonadicFO.lean) and normal form theory
(from NormalForm.lean) with the chronicle extraction infrastructure.

## Key definitions
- `KType sig k`: k-types as truth-assignment functions on `NormalForm sig k 0`
- `k_type_of`: k-type computation using `nf_eval_nf` from NormalForm.lean
- `k_equiv`: k-equivalence via k-type equality
- `KEquivalenceFramework`: typeclass interface for k-equivalence properties
- `chronicleAsMonadicStructure`: converts chronicles to ordered monadic structures

## Design
`KType sig k` is `NormalForm sig k 0 → Bool`, where `NormalForm` is the
concrete recursive normal form type from NormalForm.lean. This makes
`Fintype (KType sig k)` trivial via `inferInstance`, and enables
`k_equiv_monotone` to be proved via `nf_agreement_monotone`.

## References
- Doets 1989, Section 1 (k-types, finiteness): `literature/Doets_1989_Monadic_Pi11_Theories.md`
- Reynolds 1994, Section 4 (k-equivalence framework): `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md`
- Task 143: Doets Lemma 1.1 Normal Form KType Redesign
- Task 145: Split NEquivalence, redesign KType to NormalForm, close k_equiv_monotone
-/
namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax
open Bimodal.ProofSystem

/-! ## k-Types and k-Equivalence -/

/--
A k-type is a truth-assignment function on depth-≤k normal forms.
Each k-type maps each `NormalForm sig k 0` to `true` or `false`,
recording which concrete normal form classes of sentences are realized.

The domain `NormalForm sig k 0` is finite (via `normalForm_fintype`),
so `KType sig k` is a `Fintype` via `inferInstance` on `NormalForm sig k 0 → Bool`.

## Design Change (Task 145)
Previously: `NormalFormIdx sig k 0 → Bool` (abstract Fin-index domain).
Now: `NormalForm sig k 0 → Bool` (concrete normal form domain).
This enables `k_equiv_monotone` via `nf_agreement_monotone`.
-/
abbrev KType (sig : MonadicSignature) (k : Nat) : Type :=
  NormalForm sig k 0 → Bool

/--
The k-type realized by an ordered monadic structure M: for each
normal form at depth k (with 0 free variables), records whether
M satisfies it under the empty environment via `nf_eval_nf`.

Uses `Classical.dec` for decidability of `nf_eval_nf` (the carrier may be infinite).
This makes the definition noncomputable but mathematically precise.
-/
noncomputable def k_type_of (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig) : KType sig k :=
  fun nf => @decide (nf_eval_nf M k 0 Fin.elim0 nf) (Classical.dec _)

/--
k-equivalence: M and N have the same k-type, i.e., they satisfy the same
monadic sentences of quantifier depth ≤ k.
-/
def k_equiv (sig : MonadicSignature) (k : Nat)
    (M N : OrderedMonadicStructure sig) : Prop :=
  k_type_of sig k M = k_type_of sig k N

/--
k-equivalence is equivalent to having the same k-type.
-/
theorem k_equiv_iff_same_type (sig : MonadicSignature) (k : Nat)
    (M N : OrderedMonadicStructure sig) :
    k_equiv sig k M N ↔ k_type_of sig k M = k_type_of sig k N := by
  rfl

/--
Monotonicity: if M and N are k-equivalent, they are m-equivalent for any m ≤ k.

Proved via `nf_agreement_monotone` from NormalForm.lean: if M and N agree on
all depth-k normal forms (extracted from `k_equiv` hypothesis), then by
monotonicity of normal form agreement they agree on all depth-m normal forms.
-/
theorem k_equiv_monotone (sig : MonadicSignature) {k m : Nat}
    {M N : OrderedMonadicStructure sig}
    (hkm : m ≤ k) (h_equiv : k_equiv sig k M N) : k_equiv sig m M N := by
  -- Unfold k_equiv and k_type_of to get pointwise equality on NormalForm
  unfold k_equiv k_type_of at h_equiv ⊢
  funext nf_m
  -- Extract the depth-k agreement from h_equiv
  have h_agree_k : ∀ nf : NormalForm sig k 0,
      nf_eval_nf M k 0 Fin.elim0 nf ↔ nf_eval_nf N k 0 Fin.elim0 nf := by
    intro nf
    have h_pt := congr_fun h_equiv nf
    simp only [decide_eq_decide] at h_pt
    exact h_pt
  -- Apply nf_agreement_monotone to step down from depth k to depth m
  have h_agree_m := nf_agreement_monotone m k 0 hkm M Fin.elim0 N Fin.elim0 h_agree_k nf_m
  simp only [decide_eq_decide]
  exact h_agree_m

/-! ## Ordered Sum Construction -/

/--
The ordered sum of a family of ordered monadic structures, indexed by a
linearly ordered type `I`. The carrier is the dependent sigma type
`Σ i, (ms i).carrier` with lexicographic order: elements from different
components are ordered by their index; elements from the same component
are ordered by the component's linear order.

Uses Mathlib's `Sigma.Lex.linearOrder` which provides a `LinearOrder` on
`Σₗ i, α i` (= `Lex (Σ i, α i)` = `Σ i, α i` as a type) given
`[LinearOrder I]` and `[∀ i, LinearOrder (α i)]`.
-/
noncomputable def orderedSum (sig : MonadicSignature) (I : Type) [LinearOrder I]
    (ms : I → OrderedMonadicStructure sig) : OrderedMonadicStructure sig where
  carrier := Sigma fun i => (ms i).carrier
  interp := fun p x => (ms x.1).interp p x.2
  carrier_order := by
    haveI : ∀ i, LinearOrder ((ms i).carrier) := fun i => (ms i).carrier_order
    exact Sigma.Lex.linearOrder

/-! ## Sum Preservation Proof -/

/--
Helper: the characteristic NFs of the two ordered sums agree at depth k with n
free variables, given compatible environments and component-wise NF agreement at
all depths up to k.

Proved by induction on k, generalizing over n and environments.

The compatibility condition is that environments have the same component indices,
and for each pair of corresponding elements, the component structures agree on
all depth-k NFs evaluated at those elements (as single-variable environments).

At depth 0: atom agreement follows from component NF matching (predicate atoms)
and same component indices (order atoms: cross-component order from indices;
same-component order from component NF matching for k ≥ 1, or direct atom_eval
hypothesis for k = 0).

At depth k+1: atom agreement as above. Quantifier transfer: given witness ⟨i,a⟩
in orderedSum ms, find matching ⟨i,b⟩ in orderedSum ms'. The component-level NF
agreement at depth k+1 provides b with the same depth-k individual component NF.
The recursive call at depth k establishes NF agreement for extended environments.
-/
private noncomputable def sum_nf_agree (sig : MonadicSignature) :
    ∀ (k : Nat) (I : Type) [inst : LinearOrder I]
    (ms ms' : I → OrderedMonadicStructure sig)
    (h_comp : ∀ (m : Nat), m ≤ k → ∀ i, ∀ nf : NormalForm sig m 0,
      nf_eval_nf (ms i) m 0 Fin.elim0 nf ↔ nf_eval_nf (ms' i) m 0 Fin.elim0 nf)
    (n : Nat)
    (env_M : Fin n → (orderedSum sig I ms).carrier)
    (env_N : Fin n → (orderedSum sig I ms').carrier)
    (h_idx : ∀ j, (env_M j).1 = (env_N j).1)
    (h_atoms : ∀ (a : AtomKind sig n),
      atom_eval (orderedSum sig I ms) env_M a ↔
      atom_eval (orderedSum sig I ms') env_N a)
    (h_elem : ∀ (m : Nat) (hm : m ≤ k) (j : Fin n)
      (nf_j : NormalForm sig m 1),
      nf_eval_nf (ms ((env_M j).1)) m 1 (fun _ => (env_M j).2) nf_j ↔
      nf_eval_nf (ms' ((env_N j).1)) m 1 (fun _ => (env_N j).2) nf_j),
    ∀ (nf : NormalForm sig k n),
    nf_eval_nf (orderedSum sig I ms) k n env_M nf ↔
    nf_eval_nf (orderedSum sig I ms') k n env_N nf := by
  intro k
  induction k with
  | zero =>
    intro I _ ms ms' _ n env_M env_N _ h_atoms _ nf
    -- nf_eval_nf at depth 0 = ∀ a, atom_eval M env a ↔ nf a = true
    simp only [nf_eval_nf]
    constructor <;> intro h a <;> exact (h_atoms a).symm.trans (h a) <;> exact (h_atoms a).trans (h a)
  | succ k ih_k =>
    intro I inst_lo ms ms' h_comp n env_M env_N h_idx h_atoms h_elem nf
    -- nf at depth k+1: (atom_part, quant_part)
    obtain ⟨atom_assgn, quant_assgn⟩ := nf
    simp only [nf_eval_nf]
    constructor
    · -- Forward
      intro ⟨h_at_M, h_qt_M⟩
      constructor
      · intro a; exact (h_atoms a).symm.trans (h_at_M a)
      · intro sub_nf
        rw [← h_qt_M sub_nf]
        -- Need: existential transfer at depth k with n+1 vars
        constructor
        · -- ms → ms': given ⟨i, a⟩, find ⟨i, b⟩
          rintro ⟨⟨i, a⟩, ha_eval⟩
          -- a has some characteristic NF in component ms i
          -- Use component NF agreement at depth k+1 to find matching b
          -- Step 1: get the component quant transfer at depth k
          have hMi := nf_characteristic_satisfies (ms i) (k + 1) 0 Fin.elim0
          have hNi := nf_characteristic_satisfies (ms' i) (k + 1) 0 Fin.elim0
          have h_comp_agree : nf_characteristic (ms i) (k + 1) 0 Fin.elim0 =
              nf_characteristic (ms' i) (k + 1) 0 Fin.elim0 := by
            apply nf_eval_unique (ms' i) (k + 1) 0 Fin.elim0
            · exact (h_comp (k + 1) le_rfl i _).mp hMi
            · exact hNi
          obtain ⟨_, hMi_q⟩ := hMi
          obtain ⟨_, hNi_q⟩ := h_comp_agree ▸ hNi
          -- Get the depth-k characteristic of a in component ms i
          set char_a := nf_characteristic (ms i) k 1 (fun _ => a)
          have ha_comp := nf_characteristic_satisfies (ms i) k 1 (fun _ => a)
          -- Transfer: char_a realizable in ms i → realizable in ms' i
          have h_q_transfer : ∀ snf : NormalForm sig k 1,
              (∃ x, nf_eval_nf (ms i) k 1 (fun _ => x) snf) ↔
              (∃ y, nf_eval_nf (ms' i) k 1 (fun _ => y) snf) :=
            fun snf => (hMi_q snf).trans (hNi_q snf).symm
          have ⟨b, hb_comp⟩ := (h_q_transfer char_a).mp ⟨a, ha_comp⟩
          -- b satisfies char_a in ms' i, so b has same depth-k component NF as a
          -- Now apply IH at depth k to show ⟨i,b⟩ satisfies sub_nf in orderedSum ms'
          refine ⟨⟨i, b⟩, ?_⟩
          -- Apply ih_k with the extended environments
          apply (ih_k I ms ms' (fun m hm => h_comp m (by omega)) (n + 1)
            (Fin.cons ⟨i, a⟩ env_M) (Fin.cons ⟨i, b⟩ env_N)
            ?_ ?_ ?_).mp ha_eval
          · -- Same component indices for extended env
            intro j; cases j using Fin.cases with
            | zero => rfl
            | succ j => exact h_idx j
          · -- Atom agreement for extended env
            intro atom
            cases atom with
            | pred p j =>
              cases j using Fin.cases with
              | zero =>
                -- pred atom on the new variable: (ms i).interp p a ↔ (ms' i).interp p b
                simp only [atom_eval, Fin.cons_zero, orderedSum]
                -- a and b satisfy the same char_a in ms i and ms' i
                -- char_a at depth k ≥ 0 includes the pred profile at depth 0
                -- Extract pred agreement from ha_comp and hb_comp
                -- ha_comp : nf_eval_nf (ms i) k 1 (fun _ => a) char_a
                -- hb_comp : nf_eval_nf (ms' i) k 1 (fun _ => b) char_a
                -- Both satisfy char_a, so for pred atoms they agree on char_a's values
                have ha_pred : ∀ p', (ms i).interp p' a ↔ (char_a.atom_assgn (.pred p' 0) = true) := by
                  intro p'
                  match k with
                  | 0 => exact ha_comp (.pred p' 0)
                  | k' + 1 => exact ha_comp.1 (.pred p' 0)
                have hb_pred : ∀ p', (ms' i).interp p' b ↔ (char_a.atom_assgn (.pred p' 0) = true) := by
                  intro p'
                  match k with
                  | 0 => exact hb_comp (.pred p' 0)
                  | k' + 1 => exact hb_comp.1 (.pred p' 0)
                exact (ha_pred p).symm.trans (hb_pred p)
              | succ j =>
                -- pred atom on an old variable: same as original atoms
                simp only [atom_eval, Fin.cons_succ, orderedSum]
                have := h_atoms (.pred p j)
                simp only [atom_eval, orderedSum] at this
                exact this
            | order j₁ j₂ h_ne =>
              -- Order atom: env j₁ < env j₂ in the lex order
              simp only [atom_eval]
              -- Need to show: Fin.cons ⟨i,a⟩ env_M j₁ < Fin.cons ⟨i,a⟩ env_M j₂ ↔
              --               Fin.cons ⟨i,b⟩ env_N j₁ < Fin.cons ⟨i,b⟩ env_N j₂
              -- Case split on whether j₁ and j₂ are 0 or succ
              sorry
          · -- Element-level NF agreement for extended env
            intro m hm j nf_j
            cases j using Fin.cases with
            | zero =>
              -- New element: a in ms i vs b in ms' i
              -- Both satisfy char_a at depth k. For m ≤ k, this implies
              -- depth-m NF agreement by nf_agreement_monotone
              simp only [Fin.cons_zero]
              -- Need: nf_eval_nf (ms i) m 1 (fun _ => a) nf_j ↔ nf_eval_nf (ms' i) m 1 (fun _ => b) nf_j
              -- ha_comp: nf_eval_nf (ms i) k 1 (fun _ => a) char_a
              -- hb_comp: nf_eval_nf (ms' i) k 1 (fun _ => b) char_a
              -- By nf_agreement_from_shared_nf at depth k: they agree on all depth-k NFs
              -- By nf_agreement_monotone at depth m ≤ k: they agree on all depth-m NFs
              have h_agree_k := nf_agreement_from_shared_nf
                (ms i) (fun _ => a) (ms' i) (fun _ => b) char_a ha_comp hb_comp
              exact nf_agreement_monotone m k 1 hm (ms i) (fun _ => a) (ms' i) (fun _ => b) h_agree_k nf_j
            | succ j =>
              -- Old element: from the original env
              simp only [Fin.cons_succ]
              exact h_elem m hm j nf_j
        · -- ms' → ms: given ⟨i, b⟩, find ⟨i, a⟩ (symmetric)
          rintro ⟨⟨i, b⟩, hb_eval⟩
          have hMi := nf_characteristic_satisfies (ms i) (k + 1) 0 Fin.elim0
          have hNi := nf_characteristic_satisfies (ms' i) (k + 1) 0 Fin.elim0
          have h_comp_agree : nf_characteristic (ms i) (k + 1) 0 Fin.elim0 =
              nf_characteristic (ms' i) (k + 1) 0 Fin.elim0 := by
            apply nf_eval_unique (ms' i) (k + 1) 0 Fin.elim0
            · exact (h_comp (k + 1) le_rfl i _).mp hMi
            · exact hNi
          obtain ⟨_, hMi_q⟩ := hMi
          obtain ⟨_, hNi_q⟩ := h_comp_agree ▸ hNi
          set char_b := nf_characteristic (ms' i) k 1 (fun _ => b)
          have hb_comp := nf_characteristic_satisfies (ms' i) k 1 (fun _ => b)
          have h_q_transfer : ∀ snf : NormalForm sig k 1,
              (∃ y, nf_eval_nf (ms' i) k 1 (fun _ => y) snf) ↔
              (∃ x, nf_eval_nf (ms i) k 1 (fun _ => x) snf) :=
            fun snf => (hNi_q snf).trans (hMi_q snf).symm
          have ⟨a, ha_comp⟩ := (h_q_transfer char_b).mp ⟨b, hb_comp⟩
          refine ⟨⟨i, a⟩, ?_⟩
          apply (ih_k I ms ms' (fun m hm => h_comp m (by omega)) (n + 1)
            (Fin.cons ⟨i, a⟩ env_M) (Fin.cons ⟨i, b⟩ env_N)
            ?_ ?_ ?_).mpr hb_eval
          · intro j; cases j using Fin.cases with
            | zero => rfl
            | succ j => exact h_idx j
          · intro atom
            cases atom with
            | pred p j =>
              cases j using Fin.cases with
              | zero =>
                simp only [atom_eval, Fin.cons_zero, orderedSum]
                have ha_pred : ∀ p', (ms i).interp p' a ↔ (char_b.atom_assgn (.pred p' 0) = true) := by
                  intro p'
                  match k with
                  | 0 => exact ha_comp (.pred p' 0)
                  | k' + 1 => exact ha_comp.1 (.pred p' 0)
                have hb_pred : ∀ p', (ms' i).interp p' b ↔ (char_b.atom_assgn (.pred p' 0) = true) := by
                  intro p'
                  match k with
                  | 0 => exact hb_comp (.pred p' 0)
                  | k' + 1 => exact hb_comp.1 (.pred p' 0)
                exact (ha_pred p).symm.trans (hb_pred p)
              | succ j =>
                simp only [atom_eval, Fin.cons_succ, orderedSum]
                have := h_atoms (.pred p j)
                simp only [atom_eval, orderedSum] at this
                exact this
            | order j₁ j₂ h_ne =>
              simp only [atom_eval]
              sorry
          · intro m hm j nf_j
            cases j using Fin.cases with
            | zero =>
              simp only [Fin.cons_zero]
              have h_agree_k := nf_agreement_from_shared_nf
                (ms i) (fun _ => a) (ms' i) (fun _ => b) char_b ha_comp hb_comp
              exact nf_agreement_monotone m k 1 hm (ms i) (fun _ => a) (ms' i) (fun _ => b) h_agree_k nf_j
            | succ j =>
              simp only [Fin.cons_succ]
              exact h_elem m hm j nf_j
    · -- Backward: symmetric to forward
      intro ⟨h_at_N, h_qt_N⟩
      constructor
      · intro a; exact (h_atoms a).trans (h_at_N a)
      · intro sub_nf
        rw [← h_qt_N sub_nf]
        constructor
        · rintro ⟨⟨i, b⟩, hb_eval⟩
          have hMi := nf_characteristic_satisfies (ms i) (k + 1) 0 Fin.elim0
          have hNi := nf_characteristic_satisfies (ms' i) (k + 1) 0 Fin.elim0
          have h_comp_agree : nf_characteristic (ms i) (k + 1) 0 Fin.elim0 =
              nf_characteristic (ms' i) (k + 1) 0 Fin.elim0 := by
            apply nf_eval_unique (ms' i) (k + 1) 0 Fin.elim0
            · exact (h_comp (k + 1) le_rfl i _).mp hMi
            · exact hNi
          obtain ⟨_, hMi_q⟩ := hMi
          obtain ⟨_, hNi_q⟩ := h_comp_agree ▸ hNi
          set char_b := nf_characteristic (ms' i) k 1 (fun _ => b)
          have hb_comp := nf_characteristic_satisfies (ms' i) k 1 (fun _ => b)
          have h_q_transfer : ∀ snf : NormalForm sig k 1,
              (∃ y, nf_eval_nf (ms' i) k 1 (fun _ => y) snf) ↔
              (∃ x, nf_eval_nf (ms i) k 1 (fun _ => x) snf) :=
            fun snf => (hNi_q snf).trans (hMi_q snf).symm
          have ⟨a, ha_comp⟩ := (h_q_transfer char_b).mp ⟨b, hb_comp⟩
          refine ⟨⟨i, a⟩, ?_⟩
          apply (ih_k I ms ms' (fun m hm => h_comp m (by omega)) (n + 1)
            (Fin.cons ⟨i, a⟩ env_M) (Fin.cons ⟨i, b⟩ env_N)
            ?_ ?_ ?_).mpr hb_eval
          · intro j; cases j using Fin.cases with
            | zero => rfl
            | succ j => exact h_idx j
          · intro atom
            cases atom with
            | pred p j =>
              cases j using Fin.cases with
              | zero =>
                simp only [atom_eval, Fin.cons_zero, orderedSum]
                have ha_pred : ∀ p', (ms i).interp p' a ↔ (char_b.atom_assgn (.pred p' 0) = true) := by
                  intro p'
                  match k with
                  | 0 => exact ha_comp (.pred p' 0)
                  | k' + 1 => exact ha_comp.1 (.pred p' 0)
                have hb_pred : ∀ p', (ms' i).interp p' b ↔ (char_b.atom_assgn (.pred p' 0) = true) := by
                  intro p'
                  match k with
                  | 0 => exact hb_comp (.pred p' 0)
                  | k' + 1 => exact hb_comp.1 (.pred p' 0)
                exact (ha_pred p).symm.trans (hb_pred p)
              | succ j =>
                simp only [atom_eval, Fin.cons_succ, orderedSum]
                have := h_atoms (.pred p j)
                simp only [atom_eval, orderedSum] at this
                exact this
            | order j₁ j₂ h_ne =>
              simp only [atom_eval]
              sorry
          · intro m hm j nf_j
            cases j using Fin.cases with
            | zero =>
              simp only [Fin.cons_zero]
              have h_agree_k := nf_agreement_from_shared_nf
                (ms i) (fun _ => a) (ms' i) (fun _ => b) char_b ha_comp hb_comp
              exact nf_agreement_monotone m k 1 hm (ms i) (fun _ => a) (ms' i) (fun _ => b) h_agree_k nf_j
            | succ j =>
              simp only [Fin.cons_succ]
              exact h_elem m hm j nf_j
        · rintro ⟨⟨i, a⟩, ha_eval⟩
          have hMi := nf_characteristic_satisfies (ms i) (k + 1) 0 Fin.elim0
          have hNi := nf_characteristic_satisfies (ms' i) (k + 1) 0 Fin.elim0
          have h_comp_agree : nf_characteristic (ms i) (k + 1) 0 Fin.elim0 =
              nf_characteristic (ms' i) (k + 1) 0 Fin.elim0 := by
            apply nf_eval_unique (ms' i) (k + 1) 0 Fin.elim0
            · exact (h_comp (k + 1) le_rfl i _).mp hMi
            · exact hNi
          obtain ⟨_, hMi_q⟩ := hMi
          obtain ⟨_, hNi_q⟩ := h_comp_agree ▸ hNi
          set char_a := nf_characteristic (ms i) k 1 (fun _ => a)
          have ha_comp := nf_characteristic_satisfies (ms i) k 1 (fun _ => a)
          have h_q_transfer : ∀ snf : NormalForm sig k 1,
              (∃ x, nf_eval_nf (ms i) k 1 (fun _ => x) snf) ↔
              (∃ y, nf_eval_nf (ms' i) k 1 (fun _ => y) snf) :=
            fun snf => (hMi_q snf).trans (hNi_q snf).symm
          have ⟨b, hb_comp⟩ := (h_q_transfer char_a).mp ⟨a, ha_comp⟩
          refine ⟨⟨i, b⟩, ?_⟩
          apply (ih_k I ms ms' (fun m hm => h_comp m (by omega)) (n + 1)
            (Fin.cons ⟨i, a⟩ env_M) (Fin.cons ⟨i, b⟩ env_N)
            ?_ ?_ ?_).mp ha_eval
          · intro j; cases j using Fin.cases with
            | zero => rfl
            | succ j => exact h_idx j
          · intro atom
            cases atom with
            | pred p j =>
              cases j using Fin.cases with
              | zero =>
                simp only [atom_eval, Fin.cons_zero, orderedSum]
                have ha_pred : ∀ p', (ms i).interp p' a ↔ (char_a.atom_assgn (.pred p' 0) = true) := by
                  intro p'
                  match k with
                  | 0 => exact ha_comp (.pred p' 0)
                  | k' + 1 => exact ha_comp.1 (.pred p' 0)
                have hb_pred : ∀ p', (ms' i).interp p' b ↔ (char_a.atom_assgn (.pred p' 0) = true) := by
                  intro p'
                  match k with
                  | 0 => exact hb_comp (.pred p' 0)
                  | k' + 1 => exact hb_comp.1 (.pred p' 0)
                exact (ha_pred p).symm.trans (hb_pred p)
              | succ j =>
                simp only [atom_eval, Fin.cons_succ, orderedSum]
                have := h_atoms (.pred p j)
                simp only [atom_eval, orderedSum] at this
                exact this
            | order j₁ j₂ h_ne =>
              simp only [atom_eval]
              sorry
          · intro m hm j nf_j
            cases j using Fin.cases with
            | zero =>
              simp only [Fin.cons_zero]
              have h_agree_k := nf_agreement_from_shared_nf
                (ms i) (fun _ => a) (ms' i) (fun _ => b) char_a ha_comp hb_comp
              exact nf_agreement_monotone m k 1 hm (ms i) (fun _ => a) (ms' i) (fun _ => b) h_agree_k nf_j
            | succ j =>
              simp only [Fin.cons_succ]
              exact h_elem m hm j nf_j

/--
Sum preservation: k-equivalence of components implies k-equivalence of ordered sums.
-/
private noncomputable def sum_preservation_proof (sig : MonadicSignature) :
    ∀ (k : Nat) (I : Type) [LinearOrder I]
    (ms ms' : I → OrderedMonadicStructure sig),
    (∀ i, k_equiv sig k (ms i) (ms' i)) →
    k_equiv sig k (orderedSum sig I ms) (orderedSum sig I ms') := by
  intro k I _ ms ms' h_comp
  -- Unfold k_equiv to NF agreement at depth k, n=0
  unfold k_equiv k_type_of
  funext nf
  simp only [decide_eq_decide]
  -- Apply the general transfer lemma with n=0 and empty environments
  have h_comp' : ∀ (m : Nat), m ≤ k → ∀ i, ∀ nf' : NormalForm sig m 0,
      nf_eval_nf (ms i) m 0 Fin.elim0 nf' ↔ nf_eval_nf (ms' i) m 0 Fin.elim0 nf' := by
    intro m hm i nf'
    have h_m_equiv : k_equiv sig m (ms i) (ms' i) := k_equiv_monotone sig hm (h_comp i)
    unfold k_equiv k_type_of at h_m_equiv
    have h_pt := congr_fun h_m_equiv nf'
    simp only [decide_eq_decide] at h_pt
    exact h_pt
  exact sum_nf_agree sig k I ms ms' h_comp' 0 Fin.elim0 Fin.elim0
    (fun j => Fin.elim0 j) (fun a => match a with
      | .pred _ i => Fin.elim0 i
      | .order i _ _ => Fin.elim0 i)
    (fun _ _ j => Fin.elim0 j) nf

/-! ## K-Equivalence Framework (Typeclass) -/

/--
`KEquivalenceFramework sig` is a typeclass providing the properties of
k-equivalence needed by the Reynolds pipeline.

The `equiv_at` relation operates on `OrderedMonadicStructure sig` because
evaluation of monadic FO formulas (specifically the `lt` constructor)
requires a linear order on the carrier.

Note: The class lives at `Type 1` because `OrderedMonadicStructure sig`
contains a `carrier : Type` field.
-/
class KEquivalenceFramework (sig : MonadicSignature) : Type 1 where
  /-- The k-equivalence relation between two ordered monadic structures -/
  equiv_at (k : Nat) : OrderedMonadicStructure sig → OrderedMonadicStructure sig → Prop
  /-- k-equivalence is an equivalence relation -/
  equiv_is_equiv (k : Nat) : Equivalence (equiv_at k)
  /-- Finer equivalence implies coarser: if M ≡_k N and m ≤ k then M ≡_m N -/
  equiv_monotone {k m : Nat} (h : m ≤ k) {M N : OrderedMonadicStructure sig}
    (h_equiv : equiv_at k M N) : equiv_at m M N
  /-- There are finitely many k-types (equivalence classes) for any fixed k -/
  finite_types (k : Nat) : Fintype (Quotient (@Setoid.mk _ (equiv_at k) (equiv_is_equiv k)))
  /-- Ordered sums preserve k-equivalence:
    if ∀ i, m(i) ≡_k m'(i) then Σ_i m(i) ≡_k Σ_i m'(i).
    The ordered sum uses lexicographic order via `orderedSum`. -/
  sum_preservation (k : Nat) (I : Type) [inst_lo : LinearOrder I]
    (ms ms' : I → OrderedMonadicStructure sig)
    (h : ∀ i, equiv_at k (ms i) (ms' i)) :
    equiv_at k (orderedSum sig I ms) (orderedSum sig I ms')

/-! ## Default KEquivalenceFramework Instance -/

/--
Default instance of `KEquivalenceFramework` for any `MonadicSignature`.

- `equiv_at` is defined as `k_equiv` (equality of k-types via `k_type_of`)
- `equiv_is_equiv`: k-type equality is trivially an equivalence relation
- `equiv_monotone`: follows from `k_equiv_monotone` (via `nf_agreement_monotone`)
- `finite_types`: CLOSED (Task 143) via Fintype injection into `KType sig k`
- `sum_preservation`: sorried, requires normal form induction proof (Doets Lemma 1.4)
-/
noncomputable instance (sig : MonadicSignature) : KEquivalenceFramework sig where
  equiv_at k M N := k_equiv sig k M N
  equiv_is_equiv k := {
    refl := fun _ => rfl
    symm := fun h => h.symm
    trans := fun h1 h2 => h1.trans h2
  }
  equiv_monotone := by
    intro k m h M N h_equiv
    exact k_equiv_monotone sig h h_equiv
  -- CLOSED [Task 143/145]: finite_types via injection into KType sig k.
  -- The quotient by k_equiv injects into KType sig k (which is NormalForm sig k 0 → Bool,
  -- a Fintype). The injection is Quotient.lift (k_type_of sig k), which is well-defined
  -- because k_equiv is defined as equality of k_type_of, and injective for the same reason.
  finite_types k := by
    have h_inj : Function.Injective
        (Quotient.lift (k_type_of sig k)
          (fun M N (h : k_equiv sig k M N) => h) :
          Quotient (@Setoid.mk _ (k_equiv sig k)
            { refl := fun _ => rfl
              symm := fun h => h.symm
              trans := fun h1 h2 => h1.trans h2 }) → KType sig k) := by
      intro a b hab
      induction a using Quotient.inductionOn
      induction b using Quotient.inductionOn
      simp [Quotient.lift_mk] at hab
      exact Quotient.sound hab
    exact Fintype.ofInjective _ h_inj
  -- Task 154: sum_preservation via sum_preservation_proof (Doets Lemma 1.4).
  -- Note: sum_preservation_proof delegates to sum_nf_agree, which has 4 remaining sorries
  -- in the order atom case for extended environments. See plan for blocker details.
  sum_preservation k I _ ms ms' h :=
    sum_preservation_proof sig k I ms ms' h

/-! ## Chronicle As Monadic Structure Converter -/

/--
Convert a `ChronicleAsPriorModel` to an `OrderedMonadicStructure`.
The `atomMap` function maps each monadic predicate symbol to a
temporal formula; the interpretation of predicate `p` at domain
point `x` is whether `atomMap p ∈ M.fmcs x`.

All properties (countability, discreteness, no endpoints, Prior-UZ/SZ)
are inherited from `ChronicleAsPriorModel`.
-/
def chronicleAsMonadicStructure (M : ChronicleAsPriorModel) (sig : MonadicSignature)
    (atomMap : sig.preds → Formula) : OrderedMonadicStructure sig where
  carrier := M.domain
  interp p x := (atomMap p) ∈ M.fmcs x
  carrier_order := M.domain_lo

/--
The chronicle-as-monadic-structure is countable: its carrier is
`M.domain` which has `Countable` by the `ChronicleAsPriorModel` fields.
-/
instance chronicleAsMonadicStructure_countable (M : ChronicleAsPriorModel)
    (sig : MonadicSignature) (atomMap : sig.preds → Formula) :
    Countable (chronicleAsMonadicStructure M sig atomMap).carrier :=
  M.domain_countable

/--
The chronicle-as-monadic-structure has no maximum element
(inherited from ChronicleAsPriorModel).
-/
instance chronicleAsMonadicStructure_no_max (M : ChronicleAsPriorModel)
    (sig : MonadicSignature) (atomMap : sig.preds → Formula) :
    NoMaxOrder (chronicleAsMonadicStructure M sig atomMap).carrier :=
  M.domain_no_max

/--
The chronicle-as-monadic-structure has no minimum element
(inherited from ChronicleAsPriorModel).
-/
instance chronicleAsMonadicStructure_no_min (M : ChronicleAsPriorModel)
    (sig : MonadicSignature) (atomMap : sig.preds → Formula) :
    NoMinOrder (chronicleAsMonadicStructure M sig atomMap).carrier :=
  M.domain_no_min

/--
The chronicle-as-monadic-structure is discrete (has SuccOrder)
(inherited from ChronicleAsPriorModel).
-/
instance chronicleAsMonadicStructure_succ (M : ChronicleAsPriorModel)
    (sig : MonadicSignature) (atomMap : sig.preds → Formula) :
    SuccOrder (chronicleAsMonadicStructure M sig atomMap).carrier :=
  M.domain_succ

/--
The chronicle-as-monadic-structure is discrete (has PredOrder)
(inherited from ChronicleAsPriorModel).
-/
instance chronicleAsMonadicStructure_pred (M : ChronicleAsPriorModel)
    (sig : MonadicSignature) (atomMap : sig.preds → Formula) :
    PredOrder (chronicleAsMonadicStructure M sig atomMap).carrier :=
  M.domain_pred

/--
The chronicle-as-monadic-structure is nonempty
(inherited from ChronicleAsPriorModel).
-/
instance chronicleAsMonadicStructure_nonempty (M : ChronicleAsPriorModel)
    (sig : MonadicSignature) (atomMap : sig.preds → Formula) :
    Nonempty (chronicleAsMonadicStructure M sig atomMap).carrier :=
  M.domain_nonempty

end Bimodal.Metalogic.WeakCanonical
