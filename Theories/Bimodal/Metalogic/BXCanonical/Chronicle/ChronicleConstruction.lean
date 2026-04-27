import Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleTypes
import Bimodal.Metalogic.BXCanonical.Chronicle.RRelation
import Bimodal.Metalogic.BXCanonical.Chronicle.PointInsertion
import Bimodal.Metalogic.BXCanonical.Chronicle.CounterexampleElimination
import Mathlib.Data.Rat.Defs
import Mathlib.Data.Rat.Denumerable

/-!
# Chronicle Construction (Omega-Chain and Claim 2.11)

This module implements the omega-chain construction from Burgess 1982 Section 2.
Starting from a singleton chronicle `{0 -> A0}` for a given MCS `A0`, we
iteratively eliminate all C5/C5' counterexamples by inserting new points,
producing in the limit a chronicle satisfying all conditions C0-C5/C5'.

## Main Results

- `singleton_chronicle`: The initial chronicle with a single point mapping to
  a given MCS.

- `omega_chain`: The omega-indexed sequence of chronicles, each extending the
  previous by eliminating one counterexample.

- `limit_chronicle`: The limit (union) of the omega-chain.

- `limit_satisfies_c0`: The limit chronicle satisfies C0 (all points map to MCS).

- `limit_satisfies_c5`: The limit chronicle satisfies C5 (all Until obligations
  have witnesses).

## Design Notes

The omega-chain construction uses the countability of potential counterexamples.
Each step either eliminates a counterexample (extending the domain) or leaves
the chronicle unchanged. The limit satisfies C5/C5' because every potential
counterexample is eventually addressed.

The construction indexes potential counterexamples by natural numbers using
an enumeration of `Rat x Formula x Formula x Bool`. Since both `Rat` and
`Formula` are countable, this enumeration exists.

## References

- Burgess 1982: "Axioms for tense logic II: Time periods", Section 2
-/

namespace Bimodal.Metalogic.BXCanonical.Chronicle

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle

/-! ## Singleton Chronicle

The initial chronicle with a single point at rational 0, mapping to a given MCS.
-/

/--
The **singleton chronicle** with domain {0} and f(0) = A for a given MCS A.
The interval function g is trivially defined (no adjacent pairs exist in a
singleton domain).
-/
noncomputable def singleton_chronicle (A : Set Formula) : Chronicle :=
  { f := fun _ => A
    g := fun _ _ => ∅
    dom := {(0 : Rat)} }

/--
The singleton chronicle satisfies C0 when A is an MCS.
-/
theorem singleton_c0 {A : Set Formula} (h_mcs : SetMaximalConsistent A) :
    (singleton_chronicle A).c0 := by
  intro x hx
  simp only [singleton_chronicle] at hx ⊢
  rw [Finset.mem_singleton] at hx
  subst hx
  exact h_mcs

/--
The domain of the singleton chronicle is {0}.
-/
theorem singleton_dom (A : Set Formula) :
    (singleton_chronicle A).dom = {(0 : Rat)} := rfl

/--
f(0) = A in the singleton chronicle.
-/
theorem singleton_f_zero (A : Set Formula) :
    (singleton_chronicle A).f 0 = A := rfl

/--
The singleton chronicle satisfies the full ChronicleInvariant (C0-C3) vacuously.
All pair/triple conditions are vacuously true since {0} has no pairs.
-/
theorem singleton_invariant {A : Set Formula} (h_mcs : SetMaximalConsistent A) :
    ChronicleInvariant (singleton_chronicle A) where
  hc0 := singleton_c0 h_mcs
  hc1 := by
    intro x y hx hy hxy
    simp only [singleton_chronicle, Finset.mem_singleton] at hx hy
    subst hx; subst hy; exact absurd hxy (lt_irrefl _)
  hc2' := by
    intro x y hadj
    obtain ⟨hx, hy, hxy, _⟩ := hadj
    simp only [singleton_chronicle, Finset.mem_singleton] at hx hy
    subst hx; subst hy; exact absurd hxy (lt_irrefl _)
  hc3 := by
    intro x y z hx hy hz hxy hyz
    simp only [singleton_chronicle, Finset.mem_singleton] at hx hy
    subst hx; subst hy; exact absurd hxy (lt_irrefl _)

/--
The singleton chronicle satisfies C4 vacuously: a singleton domain has no
pairs x < y, so the universal quantifier is vacuously true.
-/
theorem singleton_c4 (A : Set Formula) :
    (singleton_chronicle A).c4 := by
  intro x y hx hy hxy
  -- dom = {0}, so x = 0 and y = 0, contradicting x < y
  simp only [singleton_chronicle, Finset.mem_singleton] at hx hy
  subst hx; subst hy
  exact absurd hxy (lt_irrefl _)

/--
The singleton chronicle satisfies C4' vacuously (mirror of C4).
-/
theorem singleton_c4' (A : Set Formula) :
    (singleton_chronicle A).c4' := by
  intro x y hx hy hyx
  simp only [singleton_chronicle, Finset.mem_singleton] at hx hy
  subst hx; subst hy
  exact absurd hyx (lt_irrefl _)

/-! ## Countability of Potential Counterexamples

PotentialCounterexample is countable (all fields are countable) and infinite
(Rat embeds into it), hence Denumerable (bijection with Nat).
-/

/-- PotentialCounterexample is countable since all its fields are countable. -/
instance : Countable PotentialCounterexample :=
  Function.Injective.countable
    (f := fun pc => (pc.x, pc.y, pc.ξ, pc.η, pc.kind))
    (fun a b h => by
      cases a; cases b
      simp only [Prod.mk.injEq] at h
      obtain ⟨h1, h2, h3, h4, h5⟩ := h
      subst h1; subst h2; subst h3; subst h4; subst h5; rfl)

/-- PotentialCounterexample is infinite since Rat embeds into it. -/
instance : Infinite PotentialCounterexample :=
  Infinite.of_injective
    (fun (q : ℚ) => PotentialCounterexample.mk q 0 Formula.bot Formula.bot .c5_forward)
    (fun a b h => by injection h)

/-- PotentialCounterexample is Denumerable (countable + infinite). -/
noncomputable instance : Denumerable PotentialCounterexample :=
  Classical.choice (nonempty_denumerable _)

/-! ## Omega-Chain Construction

The key idea: enumerate all potential counterexamples
(Rat x Rat x Formula x Formula x PotentialCounterexampleKind)
and process them one at a time. At step n, process the n-th potential counterexample.
If it is an actual counterexample for the current chronicle, eliminate it.
Otherwise, leave the chronicle unchanged.

The enumeration exists because Rat, Formula, and PotentialCounterexampleKind
are all countable, making PotentialCounterexample Denumerable.
-/

/--
An enumeration of potential counterexamples. Uses the `Denumerable` instance
on `PotentialCounterexample` (which is countable and infinite, hence in
bijection with Nat) to assign a counterexample to each natural number.
-/
noncomputable def counterexample_enum : Nat → PotentialCounterexample :=
  fun n => Denumerable.ofNat PotentialCounterexample n

/--
The enumeration covers all potential counterexamples: for any
(x, y, xi, eta, kind), there exists n such that counterexample_enum n
matches that tuple. This follows from the surjectivity of
`Denumerable.ofNat`.
-/
theorem counterexample_enum_surjective :
    ∀ pc : PotentialCounterexample, ∃ n : Nat, counterexample_enum n = pc := by
  intro pc
  exact ⟨Encodable.encode pc, Denumerable.ofNat_encode pc⟩

/--
The counterexample enumeration (via Cantor unpairing) covers all potential
counterexamples above any threshold. For any pc and k, there exists n ≥ k
such that `counterexample_enum (Nat.unpair n).2 = pc`.

This is the key property needed for the limit argument: even if a counterexample's
canonical index j is below the step where its domain point enters, there exist
arbitrarily large steps n where counterexample j is re-processed.
-/
theorem counterexample_enum_surjective_above (pc : PotentialCounterexample) (k : Nat) :
    ∃ n : Nat, n ≥ k ∧ counterexample_enum (Nat.unpair n).2 = pc := by
  have ⟨j, hj⟩ := counterexample_enum_surjective pc
  exact ⟨Nat.pair k j, Nat.left_le_pair k j,
    by simp [Nat.unpair_pair, hj]⟩

/-! ## Omega-Chain: Iterated Counterexample Elimination -/

/--
The **omega-chain**: a sequence of chronicles indexed by Nat, where each
chronicle extends the previous one by eliminating a potential counterexample.

Uses Cantor unpairing: at step n+1, process `counterexample_enum (Nat.unpair n).2`.
This ensures every counterexample index j is processed at infinitely many steps
(for all i, step `Nat.pair i j + 1` processes counterexample j). This is essential
because a counterexample (x, ξ, η) can only be eliminated when x is already in the
domain, and x may enter the domain at a later step than the counterexample's first
enumeration index.

- omega_chain 0 = singleton_chronicle A
- omega_chain (n+1) = eliminate_potential_counterexample (omega_chain n) (enum (unpair n).2)
-/
noncomputable def omega_chain (A : Set Formula) (h_mcs : SetMaximalConsistent A) :
    (n : Nat) → { χ : Chronicle // χ.c0 }
  | 0 => ⟨singleton_chronicle A, singleton_c0 h_mcs⟩
  | n + 1 =>
    let prev := omega_chain A h_mcs n
    let pc := counterexample_enum (Nat.unpair n).2
    let result := eliminate_potential_counterexample prev.val prev.property pc
    ⟨result.val, result.c0⟩

/--
Extract the chronicle at step n.
-/
noncomputable def omega_chain_val (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (n : Nat) : Chronicle :=
  (omega_chain A h_mcs n).val

/--
The chronicle at step n satisfies C0.
-/
theorem omega_chain_c0 (A : Set Formula) (h_mcs : SetMaximalConsistent A) (n : Nat) :
    (omega_chain_val A h_mcs n).c0 :=
  (omega_chain A h_mcs n).property

/--
The domain is monotonically increasing along the omega-chain.
-/
theorem omega_chain_dom_mono (A : Set Formula) (h_mcs : SetMaximalConsistent A) (n : Nat) :
    (omega_chain_val A h_mcs n).dom ⊆ (omega_chain_val A h_mcs (n + 1)).dom := by
  simp only [omega_chain_val, omega_chain]
  exact (eliminate_potential_counterexample
    (omega_chain A h_mcs n).val
    (omega_chain A h_mcs n).property
    (counterexample_enum (Nat.unpair n).2)).dom_sub

/--
The point function agrees on old domain points across the chain.
-/
theorem omega_chain_f_agrees (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (n : Nat) (x : Rat) (hx : x ∈ (omega_chain_val A h_mcs n).dom) :
    (omega_chain_val A h_mcs (n + 1)).f x = (omega_chain_val A h_mcs n).f x := by
  simp only [omega_chain_val, omega_chain]
  exact (eliminate_potential_counterexample
    (omega_chain A h_mcs n).val
    (omega_chain A h_mcs n).property
    (counterexample_enum (Nat.unpair n).2)).f_agrees x hx

/--
The interval function agrees on old domain pairs across the chain.
-/
theorem omega_chain_g_agrees (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (n : Nat) (a b : Rat)
    (ha : a ∈ (omega_chain_val A h_mcs n).dom)
    (hb : b ∈ (omega_chain_val A h_mcs n).dom) :
    (omega_chain_val A h_mcs (n + 1)).g a b = (omega_chain_val A h_mcs n).g a b := by
  simp only [omega_chain_val, omega_chain]
  exact (eliminate_potential_counterexample
    (omega_chain A h_mcs n).val
    (omega_chain A h_mcs n).property
    (counterexample_enum (Nat.unpair n).2)).g_agrees a b ha hb

/--
Domain monotonicity extends transitively: for m ≤ n, dom(m) ⊆ dom(n).
-/
theorem omega_chain_dom_mono_le (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    {m n : Nat} (h : m ≤ n) :
    (omega_chain_val A h_mcs m).dom ⊆ (omega_chain_val A h_mcs n).dom := by
  induction h with
  | refl => exact Finset.Subset.refl _
  | step h ih => exact Finset.Subset.trans ih (omega_chain_dom_mono A h_mcs _)

/--
f agreement extends transitively: for m ≤ n and x in dom(m), f_n(x) = f_m(x).
-/
theorem omega_chain_f_agrees_le (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    {m n : Nat} (h : m ≤ n) (x : Rat)
    (hx : x ∈ (omega_chain_val A h_mcs m).dom) :
    (omega_chain_val A h_mcs n).f x = (omega_chain_val A h_mcs m).f x := by
  induction h with
  | refl => rfl
  | step h ih =>
    rw [omega_chain_f_agrees A h_mcs _ x (omega_chain_dom_mono_le A h_mcs h hx)]
    exact ih

/--
g agreement extends transitively: for m ≤ n and a,b in dom(m), g_n(a,b) = g_m(a,b).
This is the g-immutability property at the omega chain level: once a g-value is set
for a pair of domain points, it never changes in subsequent stages.
-/
theorem omega_chain_g_agrees_le (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    {m n : Nat} (h : m ≤ n) (a b : Rat)
    (ha : a ∈ (omega_chain_val A h_mcs m).dom)
    (hb : b ∈ (omega_chain_val A h_mcs m).dom) :
    (omega_chain_val A h_mcs n).g a b = (omega_chain_val A h_mcs m).g a b := by
  induction h with
  | refl => rfl
  | step h ih =>
    rw [omega_chain_g_agrees A h_mcs _ a b
      (omega_chain_dom_mono_le A h_mcs h ha)
      (omega_chain_dom_mono_le A h_mcs h hb)]
    exact ih

/--
C5 witness at step n+1: if `counterexample_enum (Nat.unpair n).2` is a c5_forward
counterexample with x ∈ dom(n) and U(ξ,η) ∈ f_n(x), then a witness exists in dom(n+1).

This directly exposes the `c5_forward_witness` field of `EliminationResult`.
-/
theorem omega_chain_c5_witness (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (n : Nat) (x : Rat) (ξ η : Formula)
    (hx : x ∈ (omega_chain_val A h_mcs n).dom)
    (h_until : Formula.untl ξ η ∈ (omega_chain_val A h_mcs n).f x)
    (hn_eq : counterexample_enum (Nat.unpair n).2 = ⟨x, 0, ξ, η, .c5_forward⟩) :
    ∃ y ∈ (omega_chain_val A h_mcs (n + 1)).dom,
      x < y ∧ η ∈ (omega_chain_val A h_mcs (n + 1)).f y := by
  -- Abbreviate the elimination result at step n+1
  set pc := counterexample_enum (Nat.unpair n).2 with hpc_def
  set result := eliminate_potential_counterexample
    (omega_chain_val A h_mcs n)
    (omega_chain_c0 A h_mcs n)
    pc with hresult_def
  -- omega_chain_val(n+1) = result.val
  have h_eq : omega_chain_val A h_mcs (n + 1) = result.val := rfl
  rw [h_eq]
  -- Extract c5_forward_witness from result
  have h_kind : pc.kind = .c5_forward := by rw [hn_eq]
  have h_mem : pc.x ∈ (omega_chain_val A h_mcs n).dom := by
    rw [show pc.x = x from by rw [hn_eq]]; exact hx
  have h_unt : Formula.untl pc.ξ pc.η ∈ (omega_chain_val A h_mcs n).f pc.x := by
    rw [show pc.ξ = ξ from by rw [hn_eq], show pc.η = η from by rw [hn_eq],
        show pc.x = x from by rw [hn_eq]]
    exact h_until
  obtain ⟨y, hy_dom, hy_lt, hy_η⟩ := result.c5_forward_witness h_kind h_mem h_unt
  have hpc_x : pc.x = x := by rw [hn_eq]
  have hpc_η : pc.η = η := by rw [hn_eq]
  refine ⟨y, hy_dom, ?_, ?_⟩
  · rwa [hpc_x] at hy_lt
  · rwa [hpc_η] at hy_η

/--
C5' witness at step n+1 (mirror for Since).
-/
theorem omega_chain_c5'_witness (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (n : Nat) (x : Rat) (ξ η : Formula)
    (hx : x ∈ (omega_chain_val A h_mcs n).dom)
    (h_since : Formula.snce ξ η ∈ (omega_chain_val A h_mcs n).f x)
    (hn_eq : counterexample_enum (Nat.unpair n).2 = ⟨x, 0, ξ, η, .c5_backward⟩) :
    ∃ y ∈ (omega_chain_val A h_mcs (n + 1)).dom,
      y < x ∧ η ∈ (omega_chain_val A h_mcs (n + 1)).f y := by
  set pc := counterexample_enum (Nat.unpair n).2 with hpc_def
  set result := eliminate_potential_counterexample
    (omega_chain_val A h_mcs n)
    (omega_chain_c0 A h_mcs n)
    pc with hresult_def
  have h_eq : omega_chain_val A h_mcs (n + 1) = result.val := rfl
  rw [h_eq]
  have h_kind : pc.kind = .c5_backward := by rw [hn_eq]
  have h_mem : pc.x ∈ (omega_chain_val A h_mcs n).dom := by
    rw [show pc.x = x from by rw [hn_eq]]; exact hx
  have h_snc : Formula.snce pc.ξ pc.η ∈ (omega_chain_val A h_mcs n).f pc.x := by
    rw [show pc.ξ = ξ from by rw [hn_eq], show pc.η = η from by rw [hn_eq],
        show pc.x = x from by rw [hn_eq]]
    exact h_since
  obtain ⟨y, hy_dom, hy_lt, hy_η⟩ := result.c5_backward_witness h_kind h_mem h_snc
  have hpc_x : pc.x = x := by rw [hn_eq]
  have hpc_η : pc.η = η := by rw [hn_eq]
  refine ⟨y, hy_dom, ?_, ?_⟩
  · rwa [hpc_x] at hy_lt
  · rwa [hpc_η] at hy_η

/--
C4 witness at step n+1: if `counterexample_enum (Nat.unpair n).2` is a c4_forward
counterexample with x, y ∈ dom(n), x < y, neg(untl(ξ,η)) ∈ f_n(x), η ∈ f_n(y),
then a witness z with ξ.neg ∈ f_{n+1}(z) exists in dom(n+1).
-/
theorem omega_chain_c4_witness (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (n : Nat) (x y : Rat) (ξ η : Formula)
    (hx : x ∈ (omega_chain_val A h_mcs n).dom)
    (hy : y ∈ (omega_chain_val A h_mcs n).dom)
    (hxy : x < y)
    (h_neg_until : (Formula.untl ξ η).neg ∈ (omega_chain_val A h_mcs n).f x)
    (h_event : η ∈ (omega_chain_val A h_mcs n).f y)
    (hn_eq : counterexample_enum (Nat.unpair n).2 = ⟨x, y, ξ, η, .c4_forward⟩) :
    ∃ z ∈ (omega_chain_val A h_mcs (n + 1)).dom,
      x < z ∧ z < y ∧ ξ.neg ∈ (omega_chain_val A h_mcs (n + 1)).f z := by
  set pc := counterexample_enum (Nat.unpair n).2 with hpc_def
  set result := eliminate_potential_counterexample
    (omega_chain_val A h_mcs n)
    (omega_chain_c0 A h_mcs n)
    pc with hresult_def
  have h_eq : omega_chain_val A h_mcs (n + 1) = result.val := rfl
  rw [h_eq]
  have h_kind : pc.kind = .c4_forward := by rw [hn_eq]
  have h_mem_x : pc.x ∈ (omega_chain_val A h_mcs n).dom := by
    rw [show pc.x = x from by rw [hn_eq]]; exact hx
  have h_mem_y : pc.y ∈ (omega_chain_val A h_mcs n).dom := by
    rw [show pc.y = y from by rw [hn_eq]]; exact hy
  have h_lt : pc.x < pc.y := by
    rw [show pc.x = x from by rw [hn_eq], show pc.y = y from by rw [hn_eq]]; exact hxy
  have h_nu : (Formula.untl pc.ξ pc.η).neg ∈ (omega_chain_val A h_mcs n).f pc.x := by
    rw [show pc.ξ = ξ from by rw [hn_eq], show pc.η = η from by rw [hn_eq],
        show pc.x = x from by rw [hn_eq]]
    exact h_neg_until
  have h_ev : pc.η ∈ (omega_chain_val A h_mcs n).f pc.y := by
    rw [show pc.η = η from by rw [hn_eq], show pc.y = y from by rw [hn_eq]]
    exact h_event
  obtain ⟨z, hz_dom, hxz, hzy, hz_neg⟩ :=
    result.c4_forward_witness h_kind h_mem_x h_mem_y h_lt h_nu h_ev
  have hpc_x : pc.x = x := by rw [hn_eq]
  have hpc_y : pc.y = y := by rw [hn_eq]
  have hpc_ξ : pc.ξ = ξ := by rw [hn_eq]
  refine ⟨z, hz_dom, ?_, ?_, ?_⟩
  · rwa [hpc_x] at hxz
  · rwa [hpc_y] at hzy
  · rwa [hpc_ξ] at hz_neg

/--
C4' witness at step n+1 (mirror for Since).
-/
theorem omega_chain_c4'_witness (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (n : Nat) (x y : Rat) (ξ η : Formula)
    (hx : x ∈ (omega_chain_val A h_mcs n).dom)
    (hy : y ∈ (omega_chain_val A h_mcs n).dom)
    (hyx : y < x)
    (h_neg_since : (Formula.snce ξ η).neg ∈ (omega_chain_val A h_mcs n).f x)
    (h_event : η ∈ (omega_chain_val A h_mcs n).f y)
    (hn_eq : counterexample_enum (Nat.unpair n).2 = ⟨x, y, ξ, η, .c4_backward⟩) :
    ∃ z ∈ (omega_chain_val A h_mcs (n + 1)).dom,
      y < z ∧ z < x ∧ ξ.neg ∈ (omega_chain_val A h_mcs (n + 1)).f z := by
  set pc := counterexample_enum (Nat.unpair n).2 with hpc_def
  set result := eliminate_potential_counterexample
    (omega_chain_val A h_mcs n)
    (omega_chain_c0 A h_mcs n)
    pc with hresult_def
  have h_eq : omega_chain_val A h_mcs (n + 1) = result.val := rfl
  rw [h_eq]
  have h_kind : pc.kind = .c4_backward := by rw [hn_eq]
  have h_mem_x : pc.x ∈ (omega_chain_val A h_mcs n).dom := by
    rw [show pc.x = x from by rw [hn_eq]]; exact hx
  have h_mem_y : pc.y ∈ (omega_chain_val A h_mcs n).dom := by
    rw [show pc.y = y from by rw [hn_eq]]; exact hy
  have h_lt : pc.y < pc.x := by
    rw [show pc.x = x from by rw [hn_eq], show pc.y = y from by rw [hn_eq]]; exact hyx
  have h_ns : (Formula.snce pc.ξ pc.η).neg ∈ (omega_chain_val A h_mcs n).f pc.x := by
    rw [show pc.ξ = ξ from by rw [hn_eq], show pc.η = η from by rw [hn_eq],
        show pc.x = x from by rw [hn_eq]]
    exact h_neg_since
  have h_ev : pc.η ∈ (omega_chain_val A h_mcs n).f pc.y := by
    rw [show pc.η = η from by rw [hn_eq], show pc.y = y from by rw [hn_eq]]
    exact h_event
  obtain ⟨z, hz_dom, hyz, hzx, hz_neg⟩ :=
    result.c4_backward_witness h_kind h_mem_x h_mem_y h_lt h_ns h_ev
  have hpc_x : pc.x = x := by rw [hn_eq]
  have hpc_y : pc.y = y := by rw [hn_eq]
  have hpc_ξ : pc.ξ = ξ := by rw [hn_eq]
  refine ⟨z, hz_dom, ?_, ?_, ?_⟩
  · rwa [hpc_y] at hyz
  · rwa [hpc_x] at hzx
  · rwa [hpc_ξ] at hz_neg

/-! ## Limit Chronicle

The limit of the omega-chain is defined by taking:
- dom = union of all dom(n)
- f(x) = f_n(x) for any n such that x in dom(n)
- g(x,y) = g_n(x,y) for appropriate n

Since the domains are increasing and f agrees on old points, the limit
is well-defined.
-/

/--
The **limit domain**: union of all domains in the omega-chain.
Note: This is potentially infinite (countable), so we model it as a Set Rat
rather than a Finset Rat.
-/
noncomputable def limit_dom (A : Set Formula) (h_mcs : SetMaximalConsistent A) :
    Set Rat :=
  { x | ∃ n : Nat, x ∈ (omega_chain_val A h_mcs n).dom }

/--
The **limit point function**: for each x in the limit domain, f(x) is
f_n(x) for the first n such that x in dom(n).
-/
noncomputable def limit_f (A : Set Formula) (h_mcs : SetMaximalConsistent A) :
    Rat → Set Formula :=
  fun x =>
    have : Decidable (∃ n, x ∈ (omega_chain_val A h_mcs n).dom) :=
      Classical.dec _
    if h : ∃ n, x ∈ (omega_chain_val A h_mcs n).dom
    then (omega_chain_val A h_mcs h.choose).f x
    else ∅

/--
The limit f is well-defined: for any n with x in dom(n), f_n(x) equals the
limit value.
-/
theorem limit_f_eq (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (x : Rat) (n : Nat) (hx : x ∈ (omega_chain_val A h_mcs n).dom) :
    limit_f A h_mcs x = (omega_chain_val A h_mcs n).f x := by
  -- Unfold the definition
  unfold limit_f
  have h_ex : ∃ m, x ∈ (omega_chain_val A h_mcs m).dom := ⟨n, hx⟩
  simp only [h_ex, dite_true]
  -- Now goal is: (omega_chain_val A h_mcs (Classical.choose h_ex)).f x =
  --              (omega_chain_val A h_mcs n).f x
  -- Let m = Classical.choose h_ex, with x ∈ dom(m).
  set m := Classical.choose h_ex with hm_def
  have hxm : x ∈ (omega_chain_val A h_mcs m).dom := Classical.choose_spec h_ex
  -- The goal is f_m(x) = f_n(x) (modulo definitional unfolding of m)
  -- Use transitivity through max(m, n)
  have h1 := omega_chain_f_agrees_le A h_mcs (Nat.le_max_left m n) x hxm
  have h2 := omega_chain_f_agrees_le A h_mcs (Nat.le_max_right m n) x hx
  -- h1 : f_{max m n}(x) = f_m(x), h2 : f_{max m n}(x) = f_n(x)
  rw [← h2, h1]

/--
Every point in the limit domain maps to an MCS.
-/
theorem limit_c0 (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (x : Rat) (hx : x ∈ limit_dom A h_mcs) :
    SetMaximalConsistent (limit_f A h_mcs x) := by
  obtain ⟨n, hn⟩ := hx
  rw [limit_f_eq A h_mcs x n hn]
  exact omega_chain_c0 A h_mcs n x hn

/--
A in the limit: A = f(0) in the limit chronicle.
-/
theorem limit_f_zero (A : Set Formula) (h_mcs : SetMaximalConsistent A) :
    limit_f A h_mcs 0 = A := by
  have h0 : (0 : Rat) ∈ (omega_chain_val A h_mcs 0).dom := by
    simp only [omega_chain_val, omega_chain, singleton_chronicle]
    exact Finset.mem_singleton.mpr rfl
  rw [limit_f_eq A h_mcs 0 0 h0]
  simp only [omega_chain_val, omega_chain, singleton_chronicle]

/--
0 is in the limit domain.
-/
theorem zero_mem_limit_dom (A : Set Formula) (h_mcs : SetMaximalConsistent A) :
    (0 : Rat) ∈ limit_dom A h_mcs := by
  exact ⟨0, by simp [omega_chain_val, omega_chain, singleton_chronicle]⟩

/-! ## C5 Satisfaction in the Limit

The key theorem: the limit chronicle satisfies C5 (every Until obligation
has a witness). The proof uses the surjectivity of the counterexample
enumeration: for any potential C5 counterexample (x, xi, eta), there
exists n such that counterexample_enum n = (x, 0, xi, eta, c5_forward).
At step n+1, this counterexample is either eliminated (a witness is
inserted) or it was already not a counterexample (a witness already exists).
-/

/--
The limit chronicle satisfies C5: for every x in the limit domain and
every xi U eta in limit_f(x), there exists a witness y in the limit domain
with y > x and eta in limit_f(y).

The full guard condition (xi at intermediate points) requires the interval
function g, which is handled in the integration phase. Here we prove the
weaker version: a witness y with eta in f(y) exists.
-/
theorem limit_satisfies_c5_weak (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (x : Rat) (hx : x ∈ limit_dom A h_mcs)
    (ξ η : Formula)
    (h_until : Formula.untl ξ η ∈ limit_f A h_mcs x) :
    ∃ y ∈ limit_dom A h_mcs, x < y ∧ η ∈ limit_f A h_mcs y := by
  -- x ∈ limit_dom means x ∈ dom(n₀) for some n₀
  obtain ⟨n₀, hn₀⟩ := hx
  -- By surjective_above, there exists n ≥ n₀ such that the counterexample
  -- (x, 0, ξ, η, c5_forward) is processed at step n+1.
  obtain ⟨n, hn_ge, hn_eq⟩ := counterexample_enum_surjective_above
    ⟨x, 0, ξ, η, .c5_forward⟩ n₀
  -- x ∈ dom(n) since n ≥ n₀
  have hx_n : x ∈ (omega_chain_val A h_mcs n).dom :=
    omega_chain_dom_mono_le A h_mcs hn_ge hn₀
  -- U(ξ,η) ∈ f_n(x) by f-agreement on old domain points
  have h_until_n : Formula.untl ξ η ∈ (omega_chain_val A h_mcs n).f x := by
    rw [omega_chain_f_agrees_le A h_mcs hn_ge x hn₀]
    rwa [← limit_f_eq A h_mcs x n₀ hn₀]
  -- omega_chain_c5_witness gives us a witness in dom(n+1)
  obtain ⟨y, hy_dom, hy_lt, hy_η⟩ :=
    omega_chain_c5_witness A h_mcs n x ξ η hx_n h_until_n hn_eq
  -- Transfer to the limit
  exact ⟨y, ⟨n + 1, hy_dom⟩, hy_lt,
    by rw [limit_f_eq A h_mcs y (n + 1) hy_dom]; exact hy_η⟩

/--
Mirror: the limit chronicle satisfies C5' (Since witnesses).
-/
theorem limit_satisfies_c5'_weak (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (x : Rat) (hx : x ∈ limit_dom A h_mcs)
    (ξ η : Formula)
    (h_since : Formula.snce ξ η ∈ limit_f A h_mcs x) :
    ∃ y ∈ limit_dom A h_mcs, y < x ∧ η ∈ limit_f A h_mcs y := by
  obtain ⟨n₀, hn₀⟩ := hx
  obtain ⟨n, hn_ge, hn_eq⟩ := counterexample_enum_surjective_above
    ⟨x, 0, ξ, η, .c5_backward⟩ n₀
  have hx_n : x ∈ (omega_chain_val A h_mcs n).dom :=
    omega_chain_dom_mono_le A h_mcs hn_ge hn₀
  have h_since_n : Formula.snce ξ η ∈ (omega_chain_val A h_mcs n).f x := by
    rw [omega_chain_f_agrees_le A h_mcs hn_ge x hn₀]
    rwa [← limit_f_eq A h_mcs x n₀ hn₀]
  obtain ⟨y, hy_dom, hy_lt, hy_η⟩ :=
    omega_chain_c5'_witness A h_mcs n x ξ η hx_n h_since_n hn_eq
  exact ⟨y, ⟨n + 1, hy_dom⟩, hy_lt,
    by rw [limit_f_eq A h_mcs y (n + 1) hy_dom]; exact hy_η⟩

/-! ## F/P Resolution in the Limit

Key derived properties: F(phi) and P(phi) formulas in the limit domain
are resolved by witnesses, using BX12 to convert F to Until and then
applying C5_weak.
-/

/--
F-resolution for the limit: F(phi) in limit_f(x) implies there exists
y > x in limit_dom with phi in limit_f(y).

Proof: F(phi) in limit_f(x) -> (top U phi) in limit_f(x) by BX12.
Then limit_satisfies_c5_weak gives y > x with phi in limit_f(y).
-/
theorem limit_F_resolution (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (x : Rat) (hx : x ∈ limit_dom A h_mcs)
    (φ : Formula)
    (h_F : Formula.some_future φ ∈ limit_f A h_mcs x) :
    ∃ y ∈ limit_dom A h_mcs, x < y ∧ φ ∈ limit_f A h_mcs y := by
  -- BX12: F(phi) -> (top U phi) where top = bot.imp bot
  have h_mcs_x := limit_c0 A h_mcs x hx
  have h_bx12 : DerivationTree [] ((Formula.some_future φ).imp
      (Formula.untl (Formula.bot.imp Formula.bot) φ)) :=
    DerivationTree.axiom [] _ (Axiom.F_until_equiv φ)
  have h_until : Formula.untl (Formula.bot.imp Formula.bot) φ ∈ limit_f A h_mcs x :=
    SetMaximalConsistent.implication_property h_mcs_x
      (theorem_in_mcs h_mcs_x h_bx12) h_F
  -- Apply C5_weak
  exact limit_satisfies_c5_weak A h_mcs x hx _ φ h_until

/--
P-resolution for the limit: P(phi) in limit_f(x) implies there exists
y < x in limit_dom with phi in limit_f(y).

Proof: P(phi) in limit_f(x) -> (top S phi) in limit_f(x) by BX12'.
Then limit_satisfies_c5'_weak gives y < x with phi in limit_f(y).
-/
theorem limit_P_resolution (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (x : Rat) (hx : x ∈ limit_dom A h_mcs)
    (φ : Formula)
    (h_P : Formula.some_past φ ∈ limit_f A h_mcs x) :
    ∃ y ∈ limit_dom A h_mcs, y < x ∧ φ ∈ limit_f A h_mcs y := by
  -- BX12': P(phi) -> (top S phi) where top = bot.imp bot
  have h_mcs_x := limit_c0 A h_mcs x hx
  have h_bx12' : DerivationTree [] ((Formula.some_past φ).imp
      (Formula.snce (Formula.bot.imp Formula.bot) φ)) :=
    DerivationTree.axiom [] _ (Axiom.P_since_equiv φ)
  have h_since : Formula.snce (Formula.bot.imp Formula.bot) φ ∈ limit_f A h_mcs x :=
    SetMaximalConsistent.implication_property h_mcs_x
      (theorem_in_mcs h_mcs_x h_bx12') h_P
  -- Apply C5'_weak
  exact limit_satisfies_c5'_weak A h_mcs x hx _ φ h_since

/-! ## Limit Domain Density

The limit domain is dense: between any two domain points there exists another.
This follows from the density counterexample enumeration: for any adjacent pair
(x, y) in dom_n, the density counterexample ⟨x, y, bot, bot, .density⟩ is
eventually processed, inserting z = (x+y)/2.

With the generalized C4 (all pairs x < y, not just adjacent), density ensures
that C4 counterexamples are properly handled: at any finite stage the domain is
finite, so counterexamples can be enumerated and eliminated.
-/

/--
The limit domain is dense: for any x < y in limit_dom, there exists z in
limit_dom with x < z < y.

Proof: x enters dom at stage n₀, y at stage m₀. At stage max(n₀, m₀), both
are in the domain. The density counterexample ⟨x, y, bot, bot, .density⟩ is
enumerated at some step n ≥ max(n₀, m₀). At step n+1, if x and y are adjacent
in dom_n, z = (x+y)/2 is inserted. If not adjacent, some w already exists
between them in dom_n ⊆ limit_dom.
-/
theorem limit_dom_dense (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (x y : Rat) (hx : x ∈ limit_dom A h_mcs) (hy : y ∈ limit_dom A h_mcs)
    (hxy : x < y) :
    ∃ z ∈ limit_dom A h_mcs, x < z ∧ z < y := by
  -- Get stages where x and y enter the domain
  obtain ⟨nx, hnx⟩ := hx
  obtain ⟨ny, hny⟩ := hy
  set n₀ := max nx ny with hn₀_def
  have hx_n₀ : x ∈ (omega_chain_val A h_mcs n₀).dom :=
    omega_chain_dom_mono_le A h_mcs (le_max_left nx ny) hnx
  have hy_n₀ : y ∈ (omega_chain_val A h_mcs n₀).dom :=
    omega_chain_dom_mono_le A h_mcs (le_max_right nx ny) hny
  -- At stage n₀, either x and y are adjacent or there's already a point between them
  -- Find step n ≥ n₀ where density counterexample ⟨x, y, bot, bot, .density⟩ is processed
  obtain ⟨n, hn_ge, hn_eq⟩ := counterexample_enum_surjective_above
    ⟨x, y, Formula.bot, Formula.bot, .density⟩ n₀
  -- At step n, x and y are still in the domain
  have hx_n : x ∈ (omega_chain_val A h_mcs n).dom :=
    omega_chain_dom_mono_le A h_mcs hn_ge hx_n₀
  have hy_n : y ∈ (omega_chain_val A h_mcs n).dom :=
    omega_chain_dom_mono_le A h_mcs hn_ge hy_n₀
  -- The elimination result at step n+1 uses the density_witness field
  set pc := counterexample_enum (Nat.unpair n).2 with hpc_def
  set result := eliminate_potential_counterexample
    (omega_chain_val A h_mcs n)
    (omega_chain_c0 A h_mcs n)
    pc with hresult_def
  -- Extract key properties from the pc = ⟨x, y, bot, bot, .density⟩ encoding
  have h_kind : pc.kind = .density := by rw [hn_eq]
  have h_pc_x : pc.x = x := by rw [hn_eq]
  have h_pc_y : pc.y = y := by rw [hn_eq]
  have h_mem_x : pc.x ∈ (omega_chain_val A h_mcs n).dom := h_pc_x ▸ hx_n
  have h_mem_y : pc.y ∈ (omega_chain_val A h_mcs n).dom := h_pc_y ▸ hy_n
  have h_lt : pc.x < pc.y := h_pc_x ▸ h_pc_y ▸ hxy
  -- Use the density_witness field of the elimination result
  obtain ⟨z, hz_dom, hxz, hzy⟩ := result.density_witness h_kind h_mem_x h_mem_y h_lt
  -- omega_chain_val(n+1) = result.val
  have h_step : omega_chain_val A h_mcs (n + 1) = result.val := rfl
  exact ⟨z, ⟨n + 1, h_step ▸ hz_dom⟩, h_pc_x ▸ hxz, h_pc_y ▸ hzy⟩

/-! ## C4 Satisfaction in the Limit

The limit chronicle satisfies C4: for any x < y in limit_dom, if
neg(untl(gamma, delta)) in limit_f(x) and delta in limit_f(y), then
there exists z in limit_dom with x < z < y and gamma.neg in limit_f(z).

The proof parallels limit_satisfies_c5_weak: use surjectivity of the
counterexample enumeration to find a step where the counterexample is
processed. At that step, either the witness already exists or one is
inserted by eliminate_C4_counterexample.
-/

/--
The limit chronicle satisfies C4 (generalized Burgess C4a): for all x < y in
limit_dom, if neg(untl(ξ,η)) in limit_f(x) and η in limit_f(y), then there
exists z in limit_dom with x < z < y and ξ.neg in limit_f(z).
-/
theorem limit_satisfies_c4 (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (x y : Rat) (hx : x ∈ limit_dom A h_mcs) (hy : y ∈ limit_dom A h_mcs)
    (hxy : x < y) (ξ η : Formula)
    (h_neg_until : (Formula.untl ξ η).neg ∈ limit_f A h_mcs x)
    (h_event : η ∈ limit_f A h_mcs y) :
    ∃ z ∈ limit_dom A h_mcs, x < z ∧ z < y ∧ ξ.neg ∈ limit_f A h_mcs z := by
  -- Get stages where x and y enter the domain
  obtain ⟨nx, hnx⟩ := hx
  obtain ⟨ny, hny⟩ := hy
  set n₀ := max nx ny with hn₀_def
  have hx_n₀ : x ∈ (omega_chain_val A h_mcs n₀).dom :=
    omega_chain_dom_mono_le A h_mcs (le_max_left nx ny) hnx
  have hy_n₀ : y ∈ (omega_chain_val A h_mcs n₀).dom :=
    omega_chain_dom_mono_le A h_mcs (le_max_right nx ny) hny
  -- Find step n ≥ n₀ where the C4 counterexample ⟨x, y, ξ, η, .c4_forward⟩ is processed
  obtain ⟨n, hn_ge, hn_eq⟩ := counterexample_enum_surjective_above
    ⟨x, y, ξ, η, .c4_forward⟩ n₀
  have hx_n : x ∈ (omega_chain_val A h_mcs n).dom :=
    omega_chain_dom_mono_le A h_mcs hn_ge hx_n₀
  have hy_n : y ∈ (omega_chain_val A h_mcs n).dom :=
    omega_chain_dom_mono_le A h_mcs hn_ge hy_n₀
  -- Transfer formula membership to stage n using f-agreement
  have h_nu_n : (Formula.untl ξ η).neg ∈ (omega_chain_val A h_mcs n).f x := by
    rw [omega_chain_f_agrees_le A h_mcs hn_ge x hx_n₀]
    rw [omega_chain_f_agrees_le A h_mcs (le_max_left nx ny) x hnx]
    rwa [← limit_f_eq A h_mcs x nx hnx]
  have h_ev_n : η ∈ (omega_chain_val A h_mcs n).f y := by
    rw [omega_chain_f_agrees_le A h_mcs hn_ge y hy_n₀]
    rw [omega_chain_f_agrees_le A h_mcs (le_max_right nx ny) y hny]
    rwa [← limit_f_eq A h_mcs y ny hny]
  -- Apply omega_chain_c4_witness
  obtain ⟨z, hz_dom, hxz, hzy, hz_neg⟩ :=
    omega_chain_c4_witness A h_mcs n x y ξ η hx_n hy_n hxy h_nu_n h_ev_n hn_eq
  -- Transfer to the limit
  exact ⟨z, ⟨n + 1, hz_dom⟩, hxz, hzy,
    by rw [limit_f_eq A h_mcs z (n + 1) hz_dom]; exact hz_neg⟩

/--
Mirror: the limit chronicle satisfies C4' (Since).
-/
theorem limit_satisfies_c4' (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (x y : Rat) (hx : x ∈ limit_dom A h_mcs) (hy : y ∈ limit_dom A h_mcs)
    (hyx : y < x) (ξ η : Formula)
    (h_neg_since : (Formula.snce ξ η).neg ∈ limit_f A h_mcs x)
    (h_event : η ∈ limit_f A h_mcs y) :
    ∃ z ∈ limit_dom A h_mcs, y < z ∧ z < x ∧ ξ.neg ∈ limit_f A h_mcs z := by
  obtain ⟨nx, hnx⟩ := hx
  obtain ⟨ny, hny⟩ := hy
  set n₀ := max nx ny with hn₀_def
  have hx_n₀ : x ∈ (omega_chain_val A h_mcs n₀).dom :=
    omega_chain_dom_mono_le A h_mcs (le_max_left nx ny) hnx
  have hy_n₀ : y ∈ (omega_chain_val A h_mcs n₀).dom :=
    omega_chain_dom_mono_le A h_mcs (le_max_right nx ny) hny
  obtain ⟨n, hn_ge, hn_eq⟩ := counterexample_enum_surjective_above
    ⟨x, y, ξ, η, .c4_backward⟩ n₀
  have hx_n : x ∈ (omega_chain_val A h_mcs n).dom :=
    omega_chain_dom_mono_le A h_mcs hn_ge hx_n₀
  have hy_n : y ∈ (omega_chain_val A h_mcs n).dom :=
    omega_chain_dom_mono_le A h_mcs hn_ge hy_n₀
  have h_ns_n : (Formula.snce ξ η).neg ∈ (omega_chain_val A h_mcs n).f x := by
    rw [omega_chain_f_agrees_le A h_mcs hn_ge x hx_n₀]
    rw [omega_chain_f_agrees_le A h_mcs (le_max_left nx ny) x hnx]
    rwa [← limit_f_eq A h_mcs x nx hnx]
  have h_ev_n : η ∈ (omega_chain_val A h_mcs n).f y := by
    rw [omega_chain_f_agrees_le A h_mcs hn_ge y hy_n₀]
    rw [omega_chain_f_agrees_le A h_mcs (le_max_right nx ny) y hny]
    rwa [← limit_f_eq A h_mcs y ny hny]
  obtain ⟨z, hz_dom, hyz, hzx, hz_neg⟩ :=
    omega_chain_c4'_witness A h_mcs n x y ξ η hx_n hy_n hyx h_ns_n h_ev_n hn_eq
  exact ⟨z, ⟨n + 1, hz_dom⟩, hyz, hzx,
    by rw [limit_f_eq A h_mcs z (n + 1) hz_dom]; exact hz_neg⟩

/-! ## Limit Interval Function

The limit interval function assigns a deductively closed set to each pair
of domain points x < y. Under the correct three-way C3 (Burgess 1982 p. 372):

  g(x,z) = g(x,y) ∩ f(y) ∩ g(y,z)  for all x < y < z in dom

The g values for ADJACENT pairs (x,y) are constructed during point insertion
(Lemmas 2.4, 2.6 produce R3-maximal DCS). The g values for NON-ADJACENT
pairs are DEFINED by C3: g(x,z) = g(x,y) ∩ f(y) ∩ g(y,z).

**Design**: The correct limit_g retrieves g_n(x,y) from the first stage n
where both x and y are in dom_n. This is well-defined because g values are
immutable once set (g-immutability from omega_chain_g_agrees_le).

**Key Consequence of True C3**: g(x,z) ⊆ f(y) for all x < y < z in dom.
This is IMMEDIATE from the three-way intersection (f(y) is a factor).
See `c3_interval_subset_point` in ChronicleTypes.lean.
-/

/--
The **limit interval function**: for each pair (x, y) of rationals,
retrieves g_n(x,y) from the first stage n where both x and y are in dom_n.

This is well-defined because omega_chain_g_agrees_le ensures g values are
immutable once set: for m ≤ n with x,y ∈ dom(m), g_n(x,y) = g_m(x,y).
-/
noncomputable def limit_g (A : Set Formula) (h_mcs : SetMaximalConsistent A) :
    Rat → Rat → Set Formula :=
  fun x y =>
    have : Decidable (∃ n, x ∈ (omega_chain_val A h_mcs n).dom ∧
                           y ∈ (omega_chain_val A h_mcs n).dom) :=
      Classical.dec _
    if h : ∃ n, x ∈ (omega_chain_val A h_mcs n).dom ∧
                 y ∈ (omega_chain_val A h_mcs n).dom
    then (omega_chain_val A h_mcs h.choose).g x y
    else ∅

/--
The limit g is well-defined: for any n with x,y in dom(n), g_n(x,y) equals
the limit value.
-/
theorem limit_g_eq (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (x y : Rat) (n : Nat)
    (hx : x ∈ (omega_chain_val A h_mcs n).dom)
    (hy : y ∈ (omega_chain_val A h_mcs n).dom) :
    limit_g A h_mcs x y = (omega_chain_val A h_mcs n).g x y := by
  unfold limit_g
  have h_ex : ∃ m, x ∈ (omega_chain_val A h_mcs m).dom ∧
                    y ∈ (omega_chain_val A h_mcs m).dom := ⟨n, hx, hy⟩
  simp only [h_ex, dite_true]
  set m := Classical.choose h_ex with hm_def
  have hm := Classical.choose_spec h_ex
  have h1 := omega_chain_g_agrees_le A h_mcs (Nat.le_max_left m n) x y hm.1 hm.2
  have h2 := omega_chain_g_agrees_le A h_mcs (Nat.le_max_right m n) x y hx hy
  rw [← h2, h1]

/-! ## g_content / h_content Duality

The key bridge between forward (G) and backward (H) temporal propagation:
for MCS A and B, g_content(A) ⊆ B if and only if h_content(B) ⊆ A.

This duality means we only need to establish one direction of the
temporal chain property; the other follows automatically.
-/

/--
Forward duality: g_content(A) ⊆ B implies h_content(B) ⊆ A for MCS A, B.

Proof: Suppose H(ψ) ∈ B and ψ ∉ A. Then ¬ψ ∈ A (MCS).
By BX4 (connect_future): ¬ψ → G(P(¬ψ)), so G(P(¬ψ)) ∈ A.
Hence P(¬ψ) ∈ g_content(A) ⊆ B. Now P(¬ψ) = ¬H(ψ^{nn}),
so H(ψ^{nn}) ∉ B. But H(ψ) → H(ψ^{nn}) (past necessitation of DNI
+ past K distribution), so H(ψ^{nn}) ∈ B. Contradiction.
-/
theorem g_content_sub_imp_h_content_sub {A B : Set Formula}
    (h_mcs_A : SetMaximalConsistent A) (h_mcs_B : SetMaximalConsistent B)
    (h_gAB : g_content A ⊆ B) :
    h_content B ⊆ A := by
  intro ψ hψ
  -- hψ : H(ψ) ∈ B, i.e., ψ ∈ h_content(B)
  -- Need: ψ ∈ A
  by_contra h_not
  -- ¬ψ ∈ A by MCS negation completeness
  have h_neg_ψ : ψ.neg ∈ A := by
    rcases SetMaximalConsistent.negation_complete h_mcs_A ψ with h | h
    · exact absurd h h_not
    · exact h
  -- BX4: ¬ψ → G(P(¬ψ))
  have h_GP : Formula.all_future (Formula.some_past ψ.neg) ∈ A :=
    connect_future_mcs h_mcs_A ψ.neg h_neg_ψ
  -- P(¬ψ) ∈ g_content(A) ⊆ B
  have h_P_neg_ψ_B : Formula.some_past ψ.neg ∈ B := h_gAB h_GP
  -- P(¬ψ) = ¬H(ψ.neg.neg), so H(ψ.neg.neg) ∉ B
  -- P(α) = some_past α = (all_past α.neg).neg
  -- so P(¬ψ) = (all_past (ψ.neg).neg).neg = (H(ψ.neg.neg)).neg
  have h_H_nn_not : Formula.all_past ψ.neg.neg ∉ B :=
    SetMaximalConsistent.neg_excludes h_mcs_B _ h_P_neg_ψ_B
  -- But H(ψ) → H(ψ.neg.neg) by: ⊢ ψ → ψ.neg.neg (dni) + past necessitation + past K
  have h_dni : DerivationTree [] (ψ.imp ψ.neg.neg) :=
    Bimodal.Theorems.Combinators.dni ψ
  have h_H_dni : DerivationTree [] (Formula.all_past (ψ.imp ψ.neg.neg)) :=
    Bimodal.Theorems.past_necessitation _ h_dni
  have h_H_dist : DerivationTree [] ((Formula.all_past (ψ.imp ψ.neg.neg)).imp
      (Formula.all_past ψ |>.imp (Formula.all_past ψ.neg.neg))) :=
    Bimodal.Theorems.past_k_dist ψ ψ.neg.neg
  have h_H_nn : Formula.all_past ψ.neg.neg ∈ B := by
    have h1 := theorem_in_mcs h_mcs_B h_H_dni
    have h2 := theorem_in_mcs h_mcs_B h_H_dist
    have h3 := SetMaximalConsistent.implication_property h_mcs_B h2 h1
    exact SetMaximalConsistent.implication_property h_mcs_B h3 hψ
  exact h_H_nn_not h_H_nn

/--
Backward duality: h_content(B) ⊆ A implies g_content(A) ⊆ B for MCS A, B.

Proof: Suppose G(ψ) ∈ A and ψ ∉ B. Then ¬ψ ∈ B (MCS).
By BX4' (connect_past): ¬ψ → H(F(¬ψ)), so H(F(¬ψ)) ∈ B.
Hence F(¬ψ) ∈ h_content(B) ⊆ A. Now F(¬ψ) = ¬G(ψ^{nn}),
so G(ψ^{nn}) ∉ A. But G(ψ) → G(ψ^{nn}) (temporal necessitation of DNI
+ temporal K distribution), so G(ψ^{nn}) ∈ A. Contradiction.
-/
theorem h_content_sub_imp_g_content_sub {A B : Set Formula}
    (h_mcs_A : SetMaximalConsistent A) (h_mcs_B : SetMaximalConsistent B)
    (h_hBA : h_content B ⊆ A) :
    g_content A ⊆ B := by
  intro ψ hψ
  -- hψ : G(ψ) ∈ A, i.e., ψ ∈ g_content(A)
  -- Need: ψ ∈ B
  by_contra h_not
  have h_neg_ψ : ψ.neg ∈ B := by
    rcases SetMaximalConsistent.negation_complete h_mcs_B ψ with h | h
    · exact absurd h h_not
    · exact h
  -- BX4': ¬ψ → H(F(¬ψ))
  have h_ax : DerivationTree [] (ψ.neg.imp (ψ.neg.some_future.all_past)) :=
    DerivationTree.axiom [] _ (Axiom.connect_past ψ.neg)
  have h_HF : Formula.all_past (Formula.some_future ψ.neg) ∈ B :=
    SetMaximalConsistent.implication_property h_mcs_B
      (theorem_in_mcs h_mcs_B h_ax) h_neg_ψ
  -- F(¬ψ) ∈ h_content(B) ⊆ A
  have h_F_neg_ψ_A : Formula.some_future ψ.neg ∈ A := h_hBA h_HF
  -- F(¬ψ) = ¬G(ψ.neg.neg), so G(ψ.neg.neg) ∉ A
  have h_G_nn_not : Formula.all_future ψ.neg.neg ∉ A :=
    SetMaximalConsistent.neg_excludes h_mcs_A _ h_F_neg_ψ_A
  -- But G(ψ) → G(ψ.neg.neg) by DNI + temporal necessitation + temporal K
  have h_dni : DerivationTree [] (ψ.imp ψ.neg.neg) :=
    Bimodal.Theorems.Combinators.dni ψ
  have h_G_dni : DerivationTree [] (Formula.all_future (ψ.imp ψ.neg.neg)) :=
    DerivationTree.temporal_necessitation _ h_dni
  have h_G_dist : DerivationTree [] ((Formula.all_future (ψ.imp ψ.neg.neg)).imp
      (Formula.all_future ψ |>.imp (Formula.all_future ψ.neg.neg))) :=
    DerivationTree.axiom [] _ (Axiom.temp_k_dist ψ ψ.neg.neg)
  have h_G_nn : Formula.all_future ψ.neg.neg ∈ A := by
    have h1 := theorem_in_mcs h_mcs_A h_G_dni
    have h2 := theorem_in_mcs h_mcs_A h_G_dist
    have h3 := SetMaximalConsistent.implication_property h_mcs_A h2 h1
    exact SetMaximalConsistent.implication_property h_mcs_A h3 hψ
  exact h_G_nn_not h_G_nn

/-! ## Forward_G / Backward_H for Domain Points

The key coherence properties for the truth lemma (ParametricTruthLemma.lean).
The FMCS structure requires forward_G as a field (it IS an input to the
truth lemma, not a consequence).

**Proof** (plan v12, Phase 4): Uses the generalized C4 + C0 argument.

G(φ) = all_future(φ). In an MCS, G(φ) implies G(φ^{nn}) (by DNI + temporal
necessitation + K distribution). Then F(neg φ) = neg(G(φ^{nn})) ∉ MCS. By
BX10 contrapositive, (⊤ U neg φ) ∉ MCS. By MCS negation completeness,
neg(⊤ U neg φ) ∈ MCS. Applying generalized C4 (for ALL pairs x < y, not just
adjacent): neg(untl(⊤, neg φ)) ∈ f(x) and neg φ ∈ f(y) gives ⊤.neg ∈ f(z)
for some z. Since ⊤ is a theorem, ⊤ and ⊤.neg both in f(z) contradicts C0.

The prior obstruction (plan v11) was that C4 only applied to adjacent pairs,
making it vacuously true at the dense limit. Plan v12 Phase 1 fixed this by
generalizing C4 to all pairs x < y (matching Burgess 1982 C4a).
-/

/--
Forward_G for domain points: G(φ) ∈ limit_f(x) and x < y implies φ ∈ limit_f(y).

**Proof**: By contradiction using generalized C4 + C0. See section docstring.
-/
theorem limit_forward_G (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (x y : Rat) (hx : x ∈ limit_dom A h_mcs) (hy : y ∈ limit_dom A h_mcs)
    (hxy : x < y) (φ : Formula) (h_G : Formula.all_future φ ∈ limit_f A h_mcs x) :
    φ ∈ limit_f A h_mcs y := by
  -- Proof by contradiction using generalized C4 + C0.
  by_contra h_not
  have h_mcs_x := limit_c0 A h_mcs x hx
  have h_mcs_y := limit_c0 A h_mcs y hy
  -- φ ∉ limit_f(y), so φ.neg ∈ limit_f(y) by MCS negation completeness
  have h_neg_phi : φ.neg ∈ limit_f A h_mcs y := by
    rcases SetMaximalConsistent.negation_complete h_mcs_y φ with h | h
    · exact absurd h h_not
    · exact h
  -- Step 1: G(φ) ∈ f(x) implies G(φ^{nn}) ∈ f(x) by DNI + temporal necessitation + K
  have h_dni : DerivationTree [] (φ.imp φ.neg.neg) :=
    Bimodal.Theorems.Combinators.dni φ
  have h_G_dni : DerivationTree [] (Formula.all_future (φ.imp φ.neg.neg)) :=
    DerivationTree.temporal_necessitation _ h_dni
  have h_G_dist : DerivationTree [] ((Formula.all_future (φ.imp φ.neg.neg)).imp
      (Formula.all_future φ |>.imp (Formula.all_future φ.neg.neg))) :=
    DerivationTree.axiom [] _ (Axiom.temp_k_dist φ φ.neg.neg)
  have h_G_nn : Formula.all_future φ.neg.neg ∈ limit_f A h_mcs x := by
    have h1 := theorem_in_mcs h_mcs_x h_G_dni
    have h2 := theorem_in_mcs h_mcs_x h_G_dist
    have h3 := SetMaximalConsistent.implication_property h_mcs_x h2 h1
    exact SetMaximalConsistent.implication_property h_mcs_x h3 h_G
  -- Step 2: G(φ^{nn}) ∈ f(x) means F(φ.neg) ∉ f(x)
  -- Because F(φ.neg) = φ.neg.neg.all_future.neg = neg(G(φ^{nn}))
  -- (some_future psi = psi.neg.all_future.neg, so some_future φ.neg = φ.neg.neg.all_future.neg)
  have h_F_not : Formula.some_future φ.neg ∉ limit_f A h_mcs x := by
    -- some_future φ.neg = φ.neg.neg.all_future.neg definitionally
    -- and h_G_nn : φ.neg.neg.all_future ∈ limit_f x
    show φ.neg.neg.all_future.neg ∉ limit_f A h_mcs x
    intro h_abs
    exact set_consistent_not_both h_mcs_x.1 (φ.neg.neg.all_future) h_G_nn h_abs
  -- Step 3: (⊤ U φ.neg) ∉ f(x) by BX10: (⊤ U φ.neg) → F(φ.neg)
  set top := Formula.bot.imp Formula.bot with htop_def
  have h_bx10 : DerivationTree [] ((Formula.untl top φ.neg).imp (Formula.some_future φ.neg)) :=
    DerivationTree.axiom [] _ (Axiom.until_F top φ.neg)
  have h_until_not : Formula.untl top φ.neg ∉ limit_f A h_mcs x := by
    intro h_in
    exact h_F_not (SetMaximalConsistent.implication_property h_mcs_x
      (theorem_in_mcs h_mcs_x h_bx10) h_in)
  -- Step 4: neg(⊤ U φ.neg) ∈ f(x) by MCS negation completeness
  have h_neg_until : (Formula.untl top φ.neg).neg ∈ limit_f A h_mcs x := by
    rcases SetMaximalConsistent.negation_complete h_mcs_x (Formula.untl top φ.neg) with h | h
    · exact absurd h h_until_not
    · exact h
  -- Step 5: Apply generalized C4 with γ = ⊤, δ = φ.neg
  -- neg(untl(⊤, φ.neg)) ∈ f(x), φ.neg ∈ f(y), x < y
  -- → ∃ z ∈ limit_dom, x < z < y, ⊤.neg ∈ f(z)
  obtain ⟨z, hz_dom, _hxz, _hzy, h_top_neg⟩ :=
    limit_satisfies_c4 A h_mcs x y hx hy hxy top φ.neg h_neg_until h_neg_phi
  -- Step 6: ⊤.neg ∈ f(z) contradicts C0 (f(z) is MCS hence consistent)
  have h_mcs_z := limit_c0 A h_mcs z hz_dom
  -- ⊤ = bot → bot is a theorem, hence ⊤ ∈ f(z)
  have h_top_in : top ∈ limit_f A h_mcs z := by
    apply theorem_in_mcs h_mcs_z
    exact DerivationTree.axiom [] _ (Axiom.ex_falso Formula.bot)
  -- ⊤ ∈ f(z) and ⊤.neg ∈ f(z) contradicts consistency
  exact set_consistent_not_both h_mcs_z.1 top h_top_in h_top_neg

/--
Backward_H for domain points (dual of forward_G).
H(φ) ∈ limit_f(x) and y < x implies φ ∈ limit_f(y).

**Proof**: Mirror of forward_G using generalized C4' + C0. Uses BX10' (since_P)
and past temporal necessitation.
-/
theorem limit_backward_H (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (x y : Rat) (hx : x ∈ limit_dom A h_mcs) (hy : y ∈ limit_dom A h_mcs)
    (hyx : y < x) (φ : Formula) (h_H : Formula.all_past φ ∈ limit_f A h_mcs x) :
    φ ∈ limit_f A h_mcs y := by
  -- Mirror of forward_G using C4' + C0.
  by_contra h_not
  have h_mcs_x := limit_c0 A h_mcs x hx
  have h_mcs_y := limit_c0 A h_mcs y hy
  have h_neg_phi : φ.neg ∈ limit_f A h_mcs y := by
    rcases SetMaximalConsistent.negation_complete h_mcs_y φ with h | h
    · exact absurd h h_not
    · exact h
  -- H(φ) → H(φ^{nn}) by DNI + past necessitation + past K
  have h_dni : DerivationTree [] (φ.imp φ.neg.neg) :=
    Bimodal.Theorems.Combinators.dni φ
  have h_H_dni : DerivationTree [] (Formula.all_past (φ.imp φ.neg.neg)) :=
    Bimodal.Theorems.past_necessitation _ h_dni
  have h_H_dist : DerivationTree [] ((Formula.all_past (φ.imp φ.neg.neg)).imp
      (Formula.all_past φ |>.imp (Formula.all_past φ.neg.neg))) :=
    Bimodal.Theorems.past_k_dist φ φ.neg.neg
  have h_H_nn : Formula.all_past φ.neg.neg ∈ limit_f A h_mcs x := by
    have h1 := theorem_in_mcs h_mcs_x h_H_dni
    have h2 := theorem_in_mcs h_mcs_x h_H_dist
    have h3 := SetMaximalConsistent.implication_property h_mcs_x h2 h1
    exact SetMaximalConsistent.implication_property h_mcs_x h3 h_H
  -- P(φ.neg) ∉ f(x) because P(φ.neg) = φ.neg.neg.all_past.neg = neg(H(φ^{nn}))
  have h_P_not : Formula.some_past φ.neg ∉ limit_f A h_mcs x := by
    show φ.neg.neg.all_past.neg ∉ limit_f A h_mcs x
    intro h_abs
    exact set_consistent_not_both h_mcs_x.1 (φ.neg.neg.all_past) h_H_nn h_abs
  -- (⊤ S φ.neg) ∉ f(x) by BX10': (⊤ S φ.neg) → P(φ.neg)
  set top := Formula.bot.imp Formula.bot with htop_def
  have h_bx10' : DerivationTree [] ((Formula.snce top φ.neg).imp (Formula.some_past φ.neg)) :=
    DerivationTree.axiom [] _ (Axiom.since_P top φ.neg)
  have h_since_not : Formula.snce top φ.neg ∉ limit_f A h_mcs x := by
    intro h_in
    exact h_P_not (SetMaximalConsistent.implication_property h_mcs_x
      (theorem_in_mcs h_mcs_x h_bx10') h_in)
  have h_neg_since : (Formula.snce top φ.neg).neg ∈ limit_f A h_mcs x := by
    rcases SetMaximalConsistent.negation_complete h_mcs_x (Formula.snce top φ.neg) with h | h
    · exact absurd h h_since_not
    · exact h
  -- Apply C4' with γ = ⊤, δ = φ.neg, at (x, y) with y < x
  obtain ⟨z, hz_dom, _hyz, _hzx, h_top_neg⟩ :=
    limit_satisfies_c4' A h_mcs x y hx hy hyx top φ.neg h_neg_since h_neg_phi
  have h_mcs_z := limit_c0 A h_mcs z hz_dom
  have h_top_in : top ∈ limit_f A h_mcs z := by
    apply theorem_in_mcs h_mcs_z
    exact DerivationTree.axiom [] _ (Axiom.ex_falso Formula.bot)
  exact set_consistent_not_both h_mcs_z.1 top h_top_in h_top_neg

/-! ## Claim 2.11: Truth Claim

The truth claim states that the valuation V(alpha) = {x : alpha in f(x)}
satisfies the bimodal truth conditions for all formulas, by induction
on formula complexity:

- Atom: V(p) = {x : p in f(x)} by definition
- Bot: V(bot) = empty (since f(x) is consistent for all x)
- Imp: V(phi -> psi) = V(phi)^c union V(psi) (by MCS imp property)
- Box: V(box phi) = {x : forall y ~ x, phi in f(y)} (by MCS box property)
- G: V(G phi) = {x : forall y > x, phi in f(y)} (by g_content and C3)
- H: V(H phi) = {x : forall y < x, phi in f(y)} (by h_content and C3')
- Until: V(phi U psi) = {x : exists y > x, psi(y) and forall z in (x,y), phi(z)}
  Forward direction: from phi U psi in f(x), get witness y by C5
  Backward direction: from the semantic condition, phi U psi in f(x) by C5-completeness
- Since: Mirror of Until
-/

/-! ## Chronicle Model Construction

Package the limit chronicle into a structure suitable for the completeness
theorem. The key output is: given any MCS A, there exists a model where
A is satisfied (at point 0).
-/

/--
Given an MCS A, the limit chronicle construction produces:
1. A set of points (limit_dom) containing 0
2. A point function (limit_f) mapping each point to an MCS
3. The property that A = limit_f(0)
4. C5/C5' satisfaction (Until/Since witnesses exist)

This is the key input for the completeness theorem: any consistent formula
belongs to some MCS A, and the chronicle model witnesses its satisfiability.
-/
theorem chronicle_model_exists (A : Set Formula) (h_mcs : SetMaximalConsistent A) :
    ∃ (D : Set Rat) (f : Rat → Set Formula),
      (0 : Rat) ∈ D ∧
      f 0 = A ∧
      (∀ x ∈ D, SetMaximalConsistent (f x)) ∧
      (∀ x ∈ D, ∀ ξ η : Formula,
        Formula.untl ξ η ∈ f x →
        ∃ y ∈ D, x < y ∧ η ∈ f y) ∧
      (∀ x ∈ D, ∀ ξ η : Formula,
        Formula.snce ξ η ∈ f x →
        ∃ y ∈ D, y < x ∧ η ∈ f y) :=
  ⟨limit_dom A h_mcs,
   limit_f A h_mcs,
   zero_mem_limit_dom A h_mcs,
   limit_f_zero A h_mcs,
   limit_c0 A h_mcs,
   fun x hx ξ η h => limit_satisfies_c5_weak A h_mcs x hx ξ η h,
   fun x hx ξ η h => limit_satisfies_c5'_weak A h_mcs x hx ξ η h⟩

end Bimodal.Metalogic.BXCanonical.Chronicle
