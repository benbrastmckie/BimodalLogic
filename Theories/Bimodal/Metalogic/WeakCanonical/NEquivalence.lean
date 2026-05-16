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
Helper: `AtomKind sig 0` is empty (no predicate atoms since `Fin 0` is empty,
no order atoms since distinct elements of `Fin 0` don't exist).
-/
private theorem atomKind_zero_elim {sig : MonadicSignature} (a : AtomKind sig 0) : False :=
  match a with
  | .pred _ i => Fin.elim0 i
  | .order i _ _ => Fin.elim0 i

/--
Helper: `AtomKind sig 1` has no order atoms. Every atom at `Fin 1` is a
predicate atom `.pred p 0` since `Fin 1` has no pair of distinct elements.
-/
private theorem atomKind_one_pred_only {sig : MonadicSignature} (a : AtomKind sig 1) :
    ∃ p, a = .pred p 0 := by
  cases a with
  | pred p i => exact ⟨p, by congr; exact Fin.eq_zero i⟩
  | order i j h => exact absurd (Fin.eq_zero i ▸ Fin.eq_zero j ▸ rfl) h

/--
Bi-directional witness compatibility: at each quantifier level, for any element
in one ordered sum, there exists a matching element in the other ordered sum
with atom agreement and recursive compatibility for the extended environments.

Defined by recursion on depth `d`. At depth 0 (no quantifier steps), trivially True.
At depth `d+1`, provides forward and backward witness oracles that produce matching
elements with atom agreement plus recursive BiCompat at depth `d`.
-/
private noncomputable def BiCompat (sig : MonadicSignature) :
    Nat → (n : Nat) → (I : Type) → [LinearOrder I] →
    (ms ms' : I → OrderedMonadicStructure sig) →
    (env_M : Fin n → (orderedSum sig I ms).carrier) →
    (env_N : Fin n → (orderedSum sig I ms').carrier) → Prop
  | 0, _, _, _, _, _, _, _ => True
  | d + 1, n, I, _, ms, ms', env_M, env_N =>
    (∀ (j : I) (c' : (ms' j).carrier), ∃ (c : (ms j).carrier),
      (∀ ak : AtomKind sig (n + 1),
        atom_eval (orderedSum sig I ms) (Fin.cons (show (orderedSum sig I ms).carrier from ⟨j, c⟩) env_M) ak ↔
        atom_eval (orderedSum sig I ms') (Fin.cons (show (orderedSum sig I ms').carrier from ⟨j, c'⟩) env_N) ak) ∧
      BiCompat sig d (n + 1) I ms ms'
        (Fin.cons (show (orderedSum sig I ms).carrier from ⟨j, c⟩) env_M)
        (Fin.cons (show (orderedSum sig I ms').carrier from ⟨j, c'⟩) env_N)) ∧
    (∀ (j : I) (c : (ms j).carrier), ∃ (c' : (ms' j).carrier),
      (∀ ak : AtomKind sig (n + 1),
        atom_eval (orderedSum sig I ms) (Fin.cons (show (orderedSum sig I ms).carrier from ⟨j, c⟩) env_M) ak ↔
        atom_eval (orderedSum sig I ms') (Fin.cons (show (orderedSum sig I ms').carrier from ⟨j, c'⟩) env_N) ak) ∧
      BiCompat sig d (n + 1) I ms ms'
        (Fin.cons (show (orderedSum sig I ms).carrier from ⟨j, c⟩) env_M)
        (Fin.cons (show (orderedSum sig I ms').carrier from ⟨j, c'⟩) env_N))

/--
Component extension: from component depth-(K+1) r-var NF agreement and an element
`c'` in `ms' j`, find `c` in `ms j` such that the extended environments share
depth-K (r+1)-var component NF agreement.
-/
private theorem component_extend_fwd {sig : MonadicSignature}
    {K r : Nat} {I : Type} [LinearOrder I] (j : I)
    (ms ms' : I → OrderedMonadicStructure sig)
    (eM : Fin r → (ms j).carrier) (eN : Fin r → (ms' j).carrier)
    (h : ∀ nf : NormalForm sig (K + 1) r,
      nf_eval_nf (ms j) (K + 1) r eM nf ↔ nf_eval_nf (ms' j) (K + 1) r eN nf)
    (c' : (ms' j).carrier) :
    ∃ c : (ms j).carrier, ∀ nf : NormalForm sig K (r + 1),
      nf_eval_nf (ms j) K (r + 1) (Fin.cons c eM) nf ↔
      nf_eval_nf (ms' j) K (r + 1) (Fin.cons c' eN) nf := by
  have hM := nf_characteristic_satisfies (ms j) (K + 1) r eM
  have hN := nf_characteristic_satisfies (ms' j) (K + 1) r eN
  have heq := nf_eval_unique (ms' j) (K + 1) r eN _ _ ((h _).mp hM) hN
  obtain ⟨_, hMq⟩ := hM; obtain ⟨_, hNq⟩ := heq ▸ hN
  set ch := nf_characteristic (ms' j) K (r + 1) (Fin.cons c' eN)
  obtain ⟨c, hc⟩ := ((hMq ch).trans (hNq ch).symm).mpr
    ⟨c', nf_characteristic_satisfies ..⟩
  exact ⟨c, nf_agreement_from_shared_nf _ _ _ _ ch hc
    (nf_characteristic_satisfies ..)⟩

/-- Symmetric version of `component_extend_fwd`: find c' given c. -/
private theorem component_extend_bwd {sig : MonadicSignature}
    {K r : Nat} {I : Type} [LinearOrder I] (j : I)
    (ms ms' : I → OrderedMonadicStructure sig)
    (eM : Fin r → (ms j).carrier) (eN : Fin r → (ms' j).carrier)
    (h : ∀ nf : NormalForm sig (K + 1) r,
      nf_eval_nf (ms j) (K + 1) r eM nf ↔ nf_eval_nf (ms' j) (K + 1) r eN nf)
    (c : (ms j).carrier) :
    ∃ c' : (ms' j).carrier, ∀ nf : NormalForm sig K (r + 1),
      nf_eval_nf (ms j) K (r + 1) (Fin.cons c eM) nf ↔
      nf_eval_nf (ms' j) K (r + 1) (Fin.cons c' eN) nf := by
  have hM := nf_characteristic_satisfies (ms j) (K + 1) r eM
  have hN := nf_characteristic_satisfies (ms' j) (K + 1) r eN
  have heq := nf_eval_unique (ms' j) (K + 1) r eN _ _ ((h _).mp hM) hN
  obtain ⟨_, hMq⟩ := hM; obtain ⟨_, hNq⟩ := heq ▸ hN
  set ch := nf_characteristic (ms j) K (r + 1) (Fin.cons c eM)
  obtain ⟨c', hc'⟩ := ((hMq ch).trans (hNq ch).symm).mp
    ⟨c, nf_characteristic_satisfies ..⟩
  exact ⟨c', nf_agreement_from_shared_nf _ _ _ _ ch
    (nf_characteristic_satisfies ..) hc'⟩

/--
Atom agreement for extended environments: given existing atom agreement,
index matching, and pred+order agreement for the new element c/c',
derive atom agreement at n+1 vars.
-/
private theorem extend_atoms {sig : MonadicSignature}
    {n : Nat} {I : Type} [LinearOrder I]
    {ms ms' : I → OrderedMonadicStructure sig}
    {env_M : Fin n → (orderedSum sig I ms).carrier}
    {env_N : Fin n → (orderedSum sig I ms').carrier}
    (h_idx : ∀ p : Fin n, (env_M p).1 = (env_N p).1)
    (h_atoms : ∀ a : AtomKind sig n,
      atom_eval (orderedSum sig I ms) env_M a ↔ atom_eval (orderedSum sig I ms') env_N a)
    (j : I) (c : (ms j).carrier) (c' : (ms' j).carrier)
    -- Pred agreement for the new element
    (h_pred : ∀ p : sig.preds, (ms j).interp p c ↔ (ms' j).interp p c')
    -- Order agreement for the new element vs all existing elements (both directions)
    (h_ord_fwd : ∀ k : Fin n,
      @LT.lt (orderedSum sig I ms).carrier (orderedSum sig I ms).carrier_order.toLT
        ⟨j, c⟩ (env_M k) ↔
      @LT.lt (orderedSum sig I ms').carrier (orderedSum sig I ms').carrier_order.toLT
        ⟨j, c'⟩ (env_N k))
    (h_ord_bwd : ∀ k : Fin n,
      @LT.lt (orderedSum sig I ms).carrier (orderedSum sig I ms).carrier_order.toLT
        (env_M k) ⟨j, c⟩ ↔
      @LT.lt (orderedSum sig I ms').carrier (orderedSum sig I ms').carrier_order.toLT
        (env_N k) ⟨j, c'⟩) :
    ∀ ak : AtomKind sig (n + 1),
      atom_eval (orderedSum sig I ms) (Fin.cons (show (orderedSum sig I ms).carrier from ⟨j, c⟩) env_M) ak ↔
      atom_eval (orderedSum sig I ms') (Fin.cons (show (orderedSum sig I ms').carrier from ⟨j, c'⟩) env_N) ak := by
  intro ak
  cases ak with
  | pred p idx =>
    simp only [atom_eval]
    cases idx using Fin.cases with
    | zero => simp only [Fin.cons_zero]; exact h_pred p
    | succ k => simp only [Fin.cons_succ]; exact h_atoms (.pred p k)
  | order idx1 idx2 hne =>
    simp only [atom_eval]
    cases idx1 using Fin.cases with
    | zero =>
      cases idx2 using Fin.cases with
      | zero => exact absurd rfl hne
      | succ k => simp only [Fin.cons_zero, Fin.cons_succ]; exact h_ord_fwd k
    | succ k1 =>
      cases idx2 using Fin.cases with
      | zero =>
        simp only [Fin.cons_zero, Fin.cons_succ]
        exact h_ord_bwd k1
      | succ k2 =>
        simp only [Fin.cons_succ]
        have h' : k1 ≠ k2 := fun heq => hne (by simp [heq])
        exact h_atoms (.order k1 k2 h')

/--
Generalized lifting lemma: ordered-sum NF agreement from atom-level compatibility,
component sentence-level equivalence, and bi-directional witness compatibility.

The `h_atoms` hypothesis provides atom agreement for the current environments.
The `h_bc : BiCompat` hypothesis provides a recursive witness oracle that, at each
quantifier level, finds matching elements with atom agreement and recursive
compatibility for the extended environments. This terminates because depth
decreases at each level.

The inductive step at depth `d+1` extracts witnesses from `BiCompat`, applies the IH
at depth `d` with `n+1` vars (using the extracted atom agreement and recursive
BiCompat), and transfers the NF evaluation.
-/
private noncomputable def sum_nf_lift_gen (sig : MonadicSignature) :
    ∀ (d : Nat) (n : Nat) (I : Type) [inst_lo : LinearOrder I]
    (ms ms' : I → OrderedMonadicStructure sig)
    (h_comp : ∀ (m : Nat), m ≤ d + n → ∀ i, ∀ nf : NormalForm sig m 0,
      nf_eval_nf (ms i) m 0 Fin.elim0 nf ↔ nf_eval_nf (ms' i) m 0 Fin.elim0 nf)
    (env_M : Fin n → (orderedSum sig I ms).carrier)
    (env_N : Fin n → (orderedSum sig I ms').carrier)
    (h_atoms : ∀ a : AtomKind sig n,
      atom_eval (orderedSum sig I ms) env_M a ↔
      atom_eval (orderedSum sig I ms') env_N a)
    (h_bc : BiCompat sig d n I ms ms' env_M env_N)
    (nf : NormalForm sig d n),
    nf_eval_nf (orderedSum sig I ms) d n env_M nf ↔
    nf_eval_nf (orderedSum sig I ms') d n env_N nf := by
  intro d; induction d with
  | zero =>
    intro n I _ ms ms' _ env_M env_N h_atoms _ nf
    simp only [nf_eval_nf]
    exact ⟨fun hM a => (h_atoms a).symm.trans (hM a),
           fun hN a => (h_atoms a).trans (hN a)⟩
  | succ d ih_d =>
    intro n I _inst ms ms' h_comp env_M env_N h_atoms h_bc nf
    obtain ⟨atom_assgn, quant_assgn⟩ := nf
    obtain ⟨h_bc_fwd, h_bc_bwd⟩ := h_bc
    simp only [nf_eval_nf]
    have use_ih (j : I) (c : (ms j).carrier) (c' : (ms' j).carrier)
        (hat : ∀ ak : AtomKind sig (n+1),
          atom_eval (orderedSum sig I ms) (Fin.cons (show _ from ⟨j, c⟩) env_M) ak ↔
          atom_eval (orderedSum sig I ms') (Fin.cons (show _ from ⟨j, c'⟩) env_N) ak)
        (hbc : BiCompat sig d (n+1) I ms ms'
          (Fin.cons (show _ from ⟨j, c⟩) env_M)
          (Fin.cons (show _ from ⟨j, c'⟩) env_N))
        (snf : NormalForm sig d (n+1)) :
        nf_eval_nf (orderedSum sig I ms) d (n+1)
          (Fin.cons (show _ from ⟨j, c⟩) env_M) snf ↔
        nf_eval_nf (orderedSum sig I ms') d (n+1)
          (Fin.cons (show _ from ⟨j, c'⟩) env_N) snf :=
      @ih_d (n+1) I _inst ms ms' (fun m hm => h_comp m (by omega)) _ _ hat hbc snf
    constructor
    · intro ⟨hM_at, hM_qt⟩
      exact ⟨fun a => (h_atoms a).symm.trans (hM_at a), fun sub_nf => by
        rw [← hM_qt sub_nf]; constructor
        · rintro ⟨⟨j, c'⟩, hc'⟩; obtain ⟨c, hat, hbc⟩ := h_bc_fwd j c'
          exact ⟨⟨j, c⟩, (use_ih j c c' hat hbc sub_nf).mpr hc'⟩
        · rintro ⟨⟨j, c⟩, hc⟩; obtain ⟨c', hat, hbc⟩ := h_bc_bwd j c
          exact ⟨⟨j, c'⟩, (use_ih j c c' hat hbc sub_nf).mp hc⟩⟩
    · intro ⟨hN_at, hN_qt⟩
      exact ⟨fun a => (h_atoms a).trans (hN_at a), fun sub_nf => by
        rw [← hN_qt sub_nf]; constructor
        · rintro ⟨⟨j, c⟩, hc⟩; obtain ⟨c', hat, hbc⟩ := h_bc_bwd j c
          exact ⟨⟨j, c'⟩, (use_ih j c c' hat hbc sub_nf).mp hc⟩
        · rintro ⟨⟨j, c'⟩, hc'⟩; obtain ⟨c, hat, hbc⟩ := h_bc_fwd j c'
          exact ⟨⟨j, c⟩, (use_ih j c c' hat hbc sub_nf).mpr hc'⟩⟩

/--
Sentence-level sum NF agreement: if components are k-equivalent (agree on all
sentence-level NFs at depths ≤ k), then the ordered sums agree on all
sentence-level NFs at depth k.

This is the bootstrap approach that avoids the order atom problem by working
only at n=0, where `AtomKind sig 0` is empty. The quantifier step uses
component transfer and `nf_agreement_from_shared_nf` to find matching witnesses.

Proof by induction on k:
- k=0: `AtomKind sig 0` is empty, so both sides are vacuously true.
- k+1: Atom part is vacuously true. Quantifier part: for each `sub_nf` at depth k
  with 1 variable, show existential transfer between the ordered sums. Given
  `⟨i,a⟩` satisfying `sub_nf`, use component (k+1)-equivalence to find `b` in
  `ms' i` with the same depth-k 1-var component NF. Then show the ordered-sum-level
  NF characteristics match using a lifting argument.
-/
private noncomputable def sum_nf_agree_sentence (sig : MonadicSignature) :
    ∀ (k : Nat) (I : Type) [inst : LinearOrder I]
    (ms ms' : I → OrderedMonadicStructure sig)
    (h_comp : ∀ (m : Nat), m ≤ k → ∀ i, ∀ nf : NormalForm sig m 0,
      nf_eval_nf (ms i) m 0 Fin.elim0 nf ↔ nf_eval_nf (ms' i) m 0 Fin.elim0 nf)
    (nf : NormalForm sig k 0),
    nf_eval_nf (orderedSum sig I ms) k 0 Fin.elim0 nf ↔
    nf_eval_nf (orderedSum sig I ms') k 0 Fin.elim0 nf := by
  intro k
  induction k with
  | zero =>
    intro I _ ms ms' _ nf
    -- At depth 0, n=0: nf_eval_nf is ∀ a : AtomKind sig 0, ...
    -- AtomKind sig 0 is empty, so both sides are vacuously true
    simp only [nf_eval_nf]
    constructor
    · intro _ a; exact (atomKind_zero_elim a).elim
    · intro _ a; exact (atomKind_zero_elim a).elim
  | succ k ih_k =>
    intro I inst_lo ms ms' h_comp nf
    obtain ⟨atom_assgn, quant_assgn⟩ := nf
    simp only [nf_eval_nf]
    -- Both atom parts are vacuously true (AtomKind sig 0 is empty)
    -- The quantifier part needs existential transfer at depth k, 1 var
    constructor
    · intro ⟨_, h_qt_M⟩
      refine ⟨fun a => (atomKind_zero_elim a).elim, ?_⟩
      intro sub_nf
      rw [← h_qt_M sub_nf]
      -- Need: (∃ y in orderedSum ms', ...) ↔ (∃ x in orderedSum ms, ...)
      constructor
      · -- Backward: ms' → ms
        rintro ⟨⟨i, b⟩, hb_eval⟩
        -- Use component transfer to find a in ms i
        have hMi := nf_characteristic_satisfies (ms i) (k + 1) 0 Fin.elim0
        have hNi := nf_characteristic_satisfies (ms' i) (k + 1) 0 Fin.elim0
        have h_comp_agree : nf_characteristic (ms i) (k + 1) 0 Fin.elim0 =
            nf_characteristic (ms' i) (k + 1) 0 Fin.elim0 := by
          apply nf_eval_unique (ms' i) (k + 1) 0 Fin.elim0
          · exact (h_comp (k + 1) le_rfl i _).mp hMi
          · exact hNi
        obtain ⟨_, hMi_q⟩ := hMi
        obtain ⟨_, hNi_q⟩ := h_comp_agree ▸ hNi
        -- Extract component-level quantifier transfer
        -- hMi_q, hNi_q use Fin.cons/Fin.elim0; convert to (fun _ => x) via show
        have h_q_ms_to_ms' : ∀ snf : NormalForm sig k (0 + 1),
            (∃ x, nf_eval_nf (ms i) k (0 + 1) (Fin.cons x Fin.elim0) snf) ↔
            (∃ y, nf_eval_nf (ms' i) k (0 + 1) (Fin.cons y Fin.elim0) snf) :=
          fun snf => (hMi_q snf).trans (hNi_q snf).symm
        have h_q_ms'_to_ms : ∀ snf : NormalForm sig k (0 + 1),
            (∃ y, nf_eval_nf (ms' i) k (0 + 1) (Fin.cons y Fin.elim0) snf) ↔
            (∃ x, nf_eval_nf (ms i) k (0 + 1) (Fin.cons x Fin.elim0) snf) :=
          fun snf => (hNi_q snf).trans (hMi_q snf).symm
        -- Get b's depth-k 1-var component NF
        have hb_comp := nf_characteristic_satisfies (ms' i) k (0 + 1) (Fin.cons b Fin.elim0)
        set char_b := nf_characteristic (ms' i) k (0 + 1) (Fin.cons b Fin.elim0)
        -- Transfer to find a with same NF in ms i
        have ⟨a, ha_comp⟩ := (h_q_ms'_to_ms char_b).mp ⟨b, hb_comp⟩
        -- a and b share the same depth-k 1-var component NF
        have h_agree_comp := nf_agreement_from_shared_nf
          (ms i) (Fin.cons a Fin.elim0) (ms' i) (Fin.cons b Fin.elim0) char_b ha_comp hb_comp
        -- Need to construct BiCompat and apply sum_nf_lift_gen
        sorry
      · -- Forward: ms → ms'
        rintro ⟨⟨i, a⟩, ha_eval⟩
        have hMi := nf_characteristic_satisfies (ms i) (k + 1) 0 Fin.elim0
        have hNi := nf_characteristic_satisfies (ms' i) (k + 1) 0 Fin.elim0
        have h_comp_agree : nf_characteristic (ms i) (k + 1) 0 Fin.elim0 =
            nf_characteristic (ms' i) (k + 1) 0 Fin.elim0 := by
          apply nf_eval_unique (ms' i) (k + 1) 0 Fin.elim0
          · exact (h_comp (k + 1) le_rfl i _).mp hMi
          · exact hNi
        obtain ⟨_, hMi_q⟩ := hMi
        obtain ⟨_, hNi_q⟩ := h_comp_agree ▸ hNi
        have h_q_ms_to_ms' : ∀ snf : NormalForm sig k (0 + 1),
            (∃ x, nf_eval_nf (ms i) k (0 + 1) (Fin.cons x Fin.elim0) snf) ↔
            (∃ y, nf_eval_nf (ms' i) k (0 + 1) (Fin.cons y Fin.elim0) snf) :=
          fun snf => (hMi_q snf).trans (hNi_q snf).symm
        have ha_comp := nf_characteristic_satisfies (ms i) k (0 + 1) (Fin.cons a Fin.elim0)
        set char_a := nf_characteristic (ms i) k (0 + 1) (Fin.cons a Fin.elim0)
        have ⟨b, hb_comp⟩ := (h_q_ms_to_ms' char_a).mp ⟨a, ha_comp⟩
        have h_agree_comp := nf_agreement_from_shared_nf
          (ms i) (Fin.cons a Fin.elim0) (ms' i) (Fin.cons b Fin.elim0) char_a ha_comp hb_comp
        -- Need to construct BiCompat and apply sum_nf_lift_gen
        sorry
    · intro ⟨_, h_qt_N⟩
      refine ⟨fun a => (atomKind_zero_elim a).elim, ?_⟩
      intro sub_nf
      rw [← h_qt_N sub_nf]
      constructor
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
        have h_q_ms_to_ms' : ∀ snf : NormalForm sig k (0 + 1),
            (∃ x, nf_eval_nf (ms i) k (0 + 1) (Fin.cons x Fin.elim0) snf) ↔
            (∃ y, nf_eval_nf (ms' i) k (0 + 1) (Fin.cons y Fin.elim0) snf) :=
          fun snf => (hMi_q snf).trans (hNi_q snf).symm
        have ha_comp := nf_characteristic_satisfies (ms i) k (0 + 1) (Fin.cons a Fin.elim0)
        set char_a := nf_characteristic (ms i) k (0 + 1) (Fin.cons a Fin.elim0)
        have ⟨b, hb_comp⟩ := (h_q_ms_to_ms' char_a).mp ⟨a, ha_comp⟩
        have h_agree_comp := nf_agreement_from_shared_nf
          (ms i) (Fin.cons a Fin.elim0) (ms' i) (Fin.cons b Fin.elim0) char_a ha_comp hb_comp
        sorry
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
        have h_q_ms'_to_ms : ∀ snf : NormalForm sig k (0 + 1),
            (∃ y, nf_eval_nf (ms' i) k (0 + 1) (Fin.cons y Fin.elim0) snf) ↔
            (∃ x, nf_eval_nf (ms i) k (0 + 1) (Fin.cons x Fin.elim0) snf) :=
          fun snf => (hNi_q snf).trans (hMi_q snf).symm
        have hb_comp := nf_characteristic_satisfies (ms' i) k (0 + 1) (Fin.cons b Fin.elim0)
        set char_b := nf_characteristic (ms' i) k (0 + 1) (Fin.cons b Fin.elim0)
        have ⟨a, ha_comp⟩ := (h_q_ms'_to_ms char_b).mp ⟨b, hb_comp⟩
        have h_agree_comp := nf_agreement_from_shared_nf
          (ms i) (Fin.cons a Fin.elim0) (ms' i) (Fin.cons b Fin.elim0) char_b ha_comp hb_comp
        sorry

/--
Sum preservation: k-equivalence of components implies k-equivalence of ordered sums.
-/
private noncomputable def sum_preservation_proof (sig : MonadicSignature) :
    ∀ (k : Nat) (I : Type) [LinearOrder I]
    (ms ms' : I → OrderedMonadicStructure sig),
    (∀ i, k_equiv sig k (ms i) (ms' i)) →
    k_equiv sig k (orderedSum sig I ms) (orderedSum sig I ms') := by
  intro k I _ ms ms' h_comp
  unfold k_equiv k_type_of
  funext nf
  simp only [decide_eq_decide]
  have h_comp' : ∀ (m : Nat), m ≤ k → ∀ i, ∀ nf' : NormalForm sig m 0,
      nf_eval_nf (ms i) m 0 Fin.elim0 nf' ↔ nf_eval_nf (ms' i) m 0 Fin.elim0 nf' := by
    intro m hm i nf'
    have h_m_equiv : k_equiv sig m (ms i) (ms' i) := k_equiv_monotone sig hm (h_comp i)
    unfold k_equiv k_type_of at h_m_equiv
    have h_pt := congr_fun h_m_equiv nf'
    simp only [decide_eq_decide] at h_pt
    exact h_pt
  exact sum_nf_agree_sentence sig k I ms ms' h_comp' nf

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
