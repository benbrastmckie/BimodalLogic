import FormalSystem.Metalogic.WeakCanonical.Kamp.Boneyard.VecEAArityFirewall
import FormalSystem.Metalogic.WeakCanonical.Kamp.EANegationClosure

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.

# Phase 4a: Arbitrary-Arity Negation Closure (model-dependent)

Rabinovich (2014), Proposition 4.2 generalized to arbitrary arity `m` via the
arity firewall (Lemma 3.2(2), Phase 2).

This file builds the **arbitrary-arity negation closure**: given a `VVecEA_m m`
formula `v` that fails on a strictly increasing environment `env`, it produces a
`VVecEA_m m` formula `v'` that holds on `env`. This is the genuine long pole:
negation closure at arbitrary arity, built *faithfully* via

  1. the Phase 2 `arity_firewall` (decompose arity-`m` into arity-≤2 components),
  2. De Morgan (¬(∀ ∧ ∀) ⇒ ∃ failing component),
  3. the Phase 3 arity-2 base `neg_2var_vec_ea` (negate the failing arity-2
     interval component),

and NOT via any NF-depth / arity-tower descent (the forbidden diverged routes).

## Construction overview

By `VecEA_m.arity_firewall`, an arity-`m` formula `vea` holds on `env` iff every
arity-1 endpoint component holds (at `env i`) and every arity-2 interval
component holds (on the pair `(env z_i, env z_{i+1})`). So `¬vea.holds env` gives,
by De Morgan, *some* failing component:

- a failing **endpoint** at position `i`: lift `(endpointTypes i).neg` back to an
  arity-`m` formula via `liftEndpoint`, which constrains only position `i`;
- a failing **interval** at `i`: negate the arity-2 component with
  `neg_2var_vec_ea` to obtain a `VVecEA2` holding on the pair, then lift each of
  its disjuncts back to arity `m` via `liftInterval`, which constrains only the
  pair `(z_i, z_{i+1})`.

The lift constructors place `⊤` endpoint predicates and trivial-`⊤` brackets at
every irrelevant position, so the lifted formula's `holds` reduces to the single
relevant arity-≤2 condition.

## Main definitions

- `VecEA_m.liftEndpoint`: lift a single endpoint predicate at position `i` to an
  arity-`m` `VecEA_m` (all other positions `⊤`).
- `VecEA_m.liftInterval`: lift a `VecEA2 k` onto interval `i` of an arity-`m`
  `VecEA_m` (all other positions `⊤`).
- `VVecEA_m.liftInterval`: lift a `VVecEA2` onto interval `i` (per disjunct).

## Main results

- `VecEA_m.liftEndpoint_holds`, `VecEA_m.liftInterval_holds`,
  `VVecEA_m.liftInterval_holds`: the lift-reduction lemmas.
- `neg_vec_ea_m` (**Prop 4.2 at arbitrary arity**, model-dependent): the negation
  closure. Off the live import path.

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Prop 4.2, Lemma 3.2(2).
-/

#exit

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical

/-! ## Lift constructors: arity-≤2 components back to arity-m -/

/-- Lift a single endpoint predicate `P` at position `i` to a `VecEA_m m`
    formula. All other endpoints are `⊤` and all interval brackets are the
    trivial-`⊤` bracket. Its `holds` reduces to `P` at `env i`. -/
def VecEA_m.liftEndpoint {m : Nat} (i : Fin m) (P : TemporalPred) : VecEA_m m :=
  { endpointTypes := fun j => if j = i then P else TemporalPred.top
    intervalBrackets := fun _ => ⟨0, BracketFormula.trivial TemporalPred.top⟩ }

/-- The lifted endpoint formula holds on `env` iff `P` holds at `env i`. -/
theorem VecEA_m.liftEndpoint_holds {sig : MonadicSignature} {m : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (i : Fin m) (P : TemporalPred) (env : Fin m → M.carrier) :
    (VecEA_m.liftEndpoint i P).holds M atomMap env ↔
    P.eval_at M atomMap (env i) := by
  simp only [VecEA_m.holds, VecEA_m.liftEndpoint]
  constructor
  · intro ⟨hep, _⟩
    have h := hep i
    simpa using h
  · intro hP
    refine ⟨?_, ?_⟩
    · intro j
      by_cases hj : j = i
      · subst hj; simpa using hP
      · simp only [hj, if_false]
        exact TemporalPred.eval_at_top M atomMap (env j)
    · intro j
      exact (BracketFormula.trivial_holds M atomMap TemporalPred.top _ _).mpr
        (fun y _ _ => TemporalPred.eval_at_top M atomMap y)

/-- Lift a `VecEA2 k` onto interval `i` of an arity-`m` `VecEA_m`. The endpoint
    predicates `endpointLeft`/`endpointRight` are placed at positions `z_i` and
    `z_{i+1}`, and the bracket on interval `i`; every other endpoint is `⊤` and
    every other bracket is the trivial-`⊤` bracket. Its `holds` reduces to the
    `VecEA2` holding on the pair `(env z_i, env z_{i+1})`. -/
def VecEA_m.liftInterval {m k : Nat} (i : Fin (m - 1)) (vea2 : VecEA2 k) :
    VecEA_m m :=
  { endpointTypes := fun j =>
      if j.val = i.val then vea2.endpointLeft
      else if j.val = i.val + 1 then vea2.endpointRight
      else TemporalPred.top
    intervalBrackets := fun j =>
      if j.val = i.val then ⟨k, vea2.bracket⟩
      else ⟨0, BracketFormula.trivial TemporalPred.top⟩ }

/-- The lifted interval formula holds on a strictly increasing `env` iff the
    `VecEA2` holds on the pair `(env z_i, env z_{i+1})`. -/
theorem VecEA_m.liftInterval_holds {sig : MonadicSignature} {m k : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (i : Fin (m - 1)) (vea2 : VecEA2 k) (env : Fin m → M.carrier) :
    (VecEA_m.liftInterval i vea2).holds M atomMap env ↔
    vea2.holds M atomMap (env ⟨i.val, by omega⟩) (env ⟨i.val + 1, by omega⟩) := by
  simp only [VecEA_m.holds, VecEA_m.liftInterval, VecEA2.holds]
  constructor
  · intro ⟨hep, hbr⟩
    refine ⟨?_, ?_, ?_⟩
    · -- endpointLeft at z_i
      have h := hep ⟨i.val, by omega⟩
      simpa using h
    · -- endpointRight at z_{i+1}
      have h := hep ⟨i.val + 1, by omega⟩
      have hne : ¬(i.val + 1 = i.val) := by omega
      rw [if_neg hne, if_pos rfl] at h
      exact h
    · -- bracket on interval i
      have h := hbr i
      rw [if_pos rfl] at h
      exact h
  · intro ⟨hL, hR, hbf⟩
    refine ⟨?_, ?_⟩
    · intro j
      by_cases hj0 : j.val = i.val
      · rw [if_pos hj0]
        have : env j = env ⟨i.val, by omega⟩ := by congr 1; exact Fin.ext hj0
        rw [this]; exact hL
      · rw [if_neg hj0]
        by_cases hj1 : j.val = i.val + 1
        · rw [if_pos hj1]
          have : env j = env ⟨i.val + 1, by omega⟩ := by congr 1; exact Fin.ext hj1
          rw [this]; exact hR
        · rw [if_neg hj1]
          exact TemporalPred.eval_at_top M atomMap (env j)
    · intro j
      by_cases hj : j.val = i.val
      · rw [if_pos hj]
        have h1 : env ⟨j.val, by omega⟩ = env ⟨i.val, by omega⟩ := by congr 1; exact Fin.ext hj
        have h2 : env ⟨j.val + 1, by omega⟩ = env ⟨i.val + 1, by omega⟩ := by
          have : j.val + 1 = i.val + 1 := by omega
          congr 1; exact Fin.ext this
        rw [h1, h2]; exact hbf
      · rw [if_neg hj]
        exact (BracketFormula.trivial_holds M atomMap TemporalPred.top _ _).mpr
          (fun y _ _ => TemporalPred.eval_at_top M atomMap y)

/-- Lift a `VVecEA2` onto interval `i` (disjunct-wise). -/
def VVecEA_m.liftInterval {m : Nat} (i : Fin (m - 1)) (v : VVecEA2) :
    VVecEA_m m :=
  { disjuncts := v.disjuncts.map fun ⟨_, vea2⟩ => VecEA_m.liftInterval i vea2 }

/-- The lifted `VVecEA2` holds on `env` iff the `VVecEA2` holds on the pair. -/
theorem VVecEA_m.liftInterval_holds {sig : MonadicSignature} {m : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (i : Fin (m - 1)) (v : VVecEA2) (env : Fin m → M.carrier) :
    (VVecEA_m.liftInterval i v).holds M atomMap env ↔
    v.holds M atomMap (env ⟨i.val, by omega⟩) (env ⟨i.val + 1, by omega⟩) := by
  simp only [VVecEA_m.holds, VVecEA_m.liftInterval, VVecEA2.holds, List.mem_map]
  constructor
  · rintro ⟨vea_m, ⟨⟨k, vea2⟩, hmem, heq⟩, hh⟩
    refine ⟨⟨k, vea2⟩, hmem, ?_⟩
    rw [← heq] at hh
    exact (VecEA_m.liftInterval_holds M atomMap i vea2 env).mp hh
  · rintro ⟨⟨k, vea2⟩, hmem, hh⟩
    exact ⟨VecEA_m.liftInterval i vea2, ⟨⟨k, vea2⟩, hmem, rfl⟩,
      (VecEA_m.liftInterval_holds M atomMap i vea2 env).mpr hh⟩

/-! ## Arbitrary-arity negation closure (Prop 4.2 generalized) -/

/-- Singleton `VVecEA_m` from a single endpoint-failure lift. -/
def VVecEA_m.ofEndpoint {m : Nat} (i : Fin m) (P : TemporalPred) : VVecEA_m m :=
  { disjuncts := [VecEA_m.liftEndpoint i P] }

theorem VVecEA_m.ofEndpoint_holds {sig : MonadicSignature} {m : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (i : Fin m) (P : TemporalPred) (env : Fin m → M.carrier) :
    (VVecEA_m.ofEndpoint i P).holds M atomMap env ↔
    P.eval_at M atomMap (env i) := by
  simp only [VVecEA_m.holds, VVecEA_m.ofEndpoint, List.mem_singleton]
  constructor
  · rintro ⟨vea, heq, hh⟩
    rw [heq] at hh
    exact (VecEA_m.liftEndpoint_holds M atomMap i P env).mp hh
  · intro hP
    exact ⟨VecEA_m.liftEndpoint i P, rfl,
      (VecEA_m.liftEndpoint_holds M atomMap i P env).mpr hP⟩

/-- **Proposition 4.2 at arbitrary arity** (Rabinovich 2014, via Lemma 3.2(2)),
    model-dependent, single `VecEA_m` conjunct.

    If an arity-`m` formula `vea` fails on a strictly increasing environment
    `env`, then some `VVecEA_m m` formula holds on `env`. Faithfully built via
    the arity firewall (decompose to arity ≤ 2), De Morgan (extract a failing
    component), and the arity-2 base `neg_2var_vec_ea`. -/
theorem neg_vecEA_m {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h_INF : HasAttainedINF M atomMap)
    {m : Nat} (vea : VecEA_m m) (env : Fin m → M.carrier)
    (henv_mono : StrictMono env)
    (h_neg : ¬vea.holds M atomMap env) :
    ∃ v : VVecEA_m m, v.holds M atomMap env := by
  -- Decompose ¬holds via the arity firewall + De Morgan.
  rw [VecEA_m.arity_firewall M atomMap vea env] at h_neg
  -- h_neg : ¬((∀ i, endpointComponent i holds) ∧ (∀ i, intervalComponent i holds))
  rw [not_and_or] at h_neg
  rcases h_neg with h_ep_fail | h_br_fail
  · -- Some endpoint component fails.
    push_neg at h_ep_fail
    obtain ⟨i, hi⟩ := h_ep_fail
    -- hi : ¬(endpointComponent i).holds (fun _ => env i)
    rw [VecEA_m.endpointComponent_holds M atomMap vea i (env i)] at hi
    -- hi : ¬(endpointTypes i).eval_at (env i)
    refine ⟨VVecEA_m.ofEndpoint i (vea.endpointTypes i).neg, ?_⟩
    rw [VVecEA_m.ofEndpoint_holds M atomMap i _ env]
    exact (TemporalPred.eval_at_neg' M atomMap (vea.endpointTypes i) (env i)).mpr hi
  · -- Some interval component fails.
    push_neg at h_br_fail
    obtain ⟨i, hi⟩ := h_br_fail
    -- hi : ¬(intervalComponent i).holds (env2 (env z_i) (env z_{i+1}))
    rw [VecEA_m.intervalComponent_holds M atomMap vea i _ _] at hi
    -- hi : ¬(intervalBrackets i).2.holds (env z_i) (env z_{i+1})
    set a := env ⟨i.val, by omega⟩ with ha
    set b := env ⟨i.val + 1, by omega⟩ with hb
    have hab : a < b := by
      rw [ha, hb]; exact henv_mono (by simp [Fin.lt_def])
    -- Lift the failing bracket into a VecEA2 (top endpoints) and negate it.
    have h_neg2 : ¬(VecEA2.fromBracket (vea.intervalBrackets i).2).holds M atomMap a b := by
      rw [VecEA2.fromBracket_holds]; exact hi
    obtain ⟨v2, hv2⟩ := neg_vecEA2 h_INF _ (VecEA2.fromBracket (vea.intervalBrackets i).2)
      a b hab h_neg2
    refine ⟨VVecEA_m.liftInterval i v2, ?_⟩
    rw [VVecEA_m.liftInterval_holds M atomMap i v2 env]
    rw [← ha, ← hb]; exact hv2

/-- Negate every disjunct of a `VVecEA_m`, conjoining the resulting closures. -/
private theorem neg_vecEA_m_list {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h_INF : HasAttainedINF M atomMap)
    {m : Nat} (env : Fin m → M.carrier) (henv_mono : StrictMono env)
    (ds : List (VecEA_m m))
    (h_neg : ∀ d ∈ ds, ¬d.holds M atomMap env) :
    ∃ v : VVecEA_m m, v.holds M atomMap env := by
  induction ds with
  | nil =>
    -- Empty disjunction: produce a trivially-true VVecEA_m via liftEndpoint ⊤.
    -- m may be 0; handle by a top-endpoint-at-every-position formula.
    refine ⟨⟨[{ endpointTypes := fun _ => TemporalPred.top
                intervalBrackets := fun _ =>
                  ⟨0, BracketFormula.trivial TemporalPred.top⟩ }]⟩, ?_⟩
    refine ⟨_, List.mem_singleton.mpr rfl, ?_, ?_⟩
    · intro j; exact TemporalPred.eval_at_top M atomMap (env j)
    · intro j
      exact (BracketFormula.trivial_holds M atomMap TemporalPred.top _ _).mpr
        (fun y _ _ => TemporalPred.eval_at_top M atomMap y)
  | cons d ds ih =>
    have h_neg_d : ¬d.holds M atomMap env := h_neg d (List.mem_cons_self ..)
    obtain ⟨v_d, hv_d⟩ := neg_vecEA_m h_INF d env henv_mono h_neg_d
    have h_neg_rest : ∀ d' ∈ ds, ¬d'.holds M atomMap env :=
      fun d' hm => h_neg d' (List.mem_cons_of_mem d hm)
    obtain ⟨v_rest, hv_rest⟩ := ih h_neg_rest
    exact ⟨v_d.conj v_rest, VVecEA_m.conj_holds M atomMap v_d v_rest env hv_d hv_rest⟩

/-- **Proposition 4.2 at arbitrary arity** (Rabinovich 2014), model-dependent.

    The negation of a `VVecEA_m m` formula produces a `VVecEA_m m` formula on a
    strictly increasing environment, on structures with `HasAttainedINF`. This
    is the arbitrary-arity negation closure — the genuine long pole of this development,
    built faithfully via the Phase 2 arity firewall and the Phase 3 arity-2 base,
    with NO NF-depth / arity-tower descent.

    Off the live import path (wired into Prop 4.3 in Phase 4b/4c). -/
theorem neg_vec_ea_m {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h_INF : HasAttainedINF M atomMap)
    {m : Nat} (v : VVecEA_m m) (env : Fin m → M.carrier)
    (henv_mono : StrictMono env)
    (h_neg : ¬v.holds M atomMap env) :
    ∃ v' : VVecEA_m m, v'.holds M atomMap env := by
  simp only [VVecEA_m.holds] at h_neg
  push_neg at h_neg
  exact neg_vecEA_m_list h_INF env henv_mono v.disjuncts h_neg

end FormalSystem.Metalogic.WeakCanonical.Kamp
