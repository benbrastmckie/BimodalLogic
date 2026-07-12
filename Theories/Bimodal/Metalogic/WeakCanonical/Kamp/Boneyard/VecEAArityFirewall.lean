import Bimodal.Metalogic.WeakCanonical.Kamp.Boneyard.VecEA_m

/-!
# Lemma 3.2(2): The Arity Firewall

Rabinovich (2014), Lemma 3.2(2):
*"Every exists-forall formula is equivalent to a conjunction of exists-forall
formulas with at most two free variables."*

This is the structural guarantee that **arity never exceeds 2** in the negation
closure of the faithful Rabinovich path. It is the one genuinely missing piece
(report 37 §4.4) that *prevents* the arity tower: it decomposes an arity-`m`
`VecEA_m` formula into a conjunction of arity-≤2 components, each of which is
either a single endpoint predicate (arity 1) or a single interval bracket
(arity 2), evaluated only on the relevant sub-environment.

## Main Definitions

- `VecEA_m.endpointComponent`: the arity-1 component for free variable `z_i`
  (a `VecEA_m 1` carrying only the `i`-th endpoint predicate).
- `VecEA_m.intervalComponent`: the arity-2 component for the interval
  `(z_i, z_{i+1})` (a `VecEA_m 2` carrying only the `i`-th interval bracket,
  with trivial `⊤` endpoints).

## Main Results

- `VecEA_m.endpointComponent_holds`: the arity-1 component holds on `fun _ => env i`
  iff the `i`-th endpoint predicate holds at `env i`.
- `VecEA_m.intervalComponent_holds`: the arity-2 component holds on the pair
  `env2 (env z_i) (env z_{i+1})` iff the `i`-th interval bracket holds.
- `VecEA_m.arity_firewall` (**Lemma 3.2(2)**): the arity-`m` formula holds on
  `env` iff *all* its arity-1 endpoint components hold *and* *all* its arity-2
  interval components hold. Every component on the right-hand side has at most
  two free variables.

No NF-depth parameter; no recursion on a depth index; arity is capped at 2 by
construction.

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Lemma 3.2(2) (md:78)
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-! ## Arity-1 endpoint component -/

/-- The arity-1 component carrying only the `i`-th endpoint predicate of a
    `VecEA_m m` formula. It has one free variable and no interval brackets. -/
def VecEA_m.endpointComponent {m : Nat} (vea : VecEA_m m) (i : Fin m) :
    VecEA_m 1 :=
  { endpointTypes := fun _ => vea.endpointTypes i
    intervalBrackets := fun j => absurd j.isLt (by omega) }

/-- The arity-1 endpoint component holds on the singleton environment
    `fun _ => env i` iff the original `i`-th endpoint predicate holds at `env i`. -/
theorem VecEA_m.endpointComponent_holds {sig : MonadicSignature} {m : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (vea : VecEA_m m) (i : Fin m) (x : M.carrier) :
    (vea.endpointComponent i).holds M atomMap (fun _ => x) ↔
    (vea.endpointTypes i).eval_at M atomMap x := by
  simp only [VecEA_m.holds, VecEA_m.endpointComponent]
  constructor
  · intro ⟨hep, _⟩
    exact hep ⟨0, by omega⟩
  · intro hep
    refine ⟨?_, ?_⟩
    · intro j
      have hj0 : j = ⟨0, by omega⟩ := Fin.ext (by omega)
      subst hj0; exact hep
    · intro j; exact absurd j.isLt (by omega)

/-! ## Arity-2 interval component -/

/-- The arity-2 component carrying only the `i`-th interval bracket of a
    `VecEA_m m` formula. It has two free variables, trivial `⊤` endpoint
    predicates, and the single bracket between `z_i` and `z_{i+1}`. -/
def VecEA_m.intervalComponent {m : Nat} (vea : VecEA_m m) (i : Fin (m - 1)) :
    VecEA_m 2 :=
  { endpointTypes := fun _ => TemporalPred.top
    intervalBrackets := fun _ => vea.intervalBrackets i }

/-- The arity-2 interval component holds on the pair environment
    `env2 a b` iff the original `i`-th interval bracket holds on `(a, b)`. -/
theorem VecEA_m.intervalComponent_holds {sig : MonadicSignature} {m : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (vea : VecEA_m m) (i : Fin (m - 1)) (a b : M.carrier) :
    (vea.intervalComponent i).holds M atomMap (env2 a b) ↔
    (vea.intervalBrackets i).2.holds M atomMap a b := by
  simp only [VecEA_m.holds, VecEA_m.intervalComponent]
  constructor
  · intro ⟨_, hbr⟩
    have h := hbr ⟨0, by omega⟩
    simpa only [env2_zero, env2_one] using h
  · intro hbr
    refine ⟨?_, ?_⟩
    · intro j; exact TemporalPred.eval_at_top M atomMap _
    · intro j
      have hj0 : j = ⟨0, by omega⟩ := Fin.ext (by omega)
      subst hj0
      simpa only [env2_zero, env2_one] using hbr

/-! ## Lemma 3.2(2): the arity firewall -/

/-- **Lemma 3.2(2)** (Rabinovich 2014, md:78): the arity firewall.

    An arity-`m` `VecEA_m` formula holds on `env` iff the conjunction of its
    arity-1 endpoint components (one per free variable, on `fun _ => env i`)
    and its arity-2 interval components (one per consecutive pair, on
    `env2 (env z_i) (env z_{i+1})`) all hold.

    Every formula on the right-hand side has **at most two free variables**.
    This caps arity at 2 in the negation closure and prevents the arity tower:
    there is no recursion on a depth index and no appeal to arity ≥ 3. -/
theorem VecEA_m.arity_firewall {sig : MonadicSignature} {m : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (vea : VecEA_m m) (env : Fin m → M.carrier) :
    vea.holds M atomMap env ↔
    (∀ i : Fin m,
      (vea.endpointComponent i).holds M atomMap (fun _ => env i)) ∧
    (∀ i : Fin (m - 1),
      (vea.intervalComponent i).holds M atomMap
        (env2 (env ⟨i.val, by omega⟩) (env ⟨i.val + 1, by omega⟩))) := by
  simp only [VecEA_m.holds]
  constructor
  · intro ⟨hep, hbr⟩
    refine ⟨?_, ?_⟩
    · intro i
      exact (vea.endpointComponent_holds M atomMap i (env i)).mpr (hep i)
    · intro i
      exact (vea.intervalComponent_holds M atomMap i _ _).mpr (hbr i)
  · intro ⟨hep_c, hbr_c⟩
    refine ⟨?_, ?_⟩
    · intro i
      exact (vea.endpointComponent_holds M atomMap i (env i)).mp (hep_c i)
    · intro i
      exact (vea.intervalComponent_holds M atomMap i _ _).mp (hbr_c i)

end Bimodal.Metalogic.WeakCanonical.Kamp
