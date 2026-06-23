# Syntactic VecEA_m Design: Replacing the Semantic IsVEA Predicate

- **Task**: 305 -- rabinovich_ea_formula_implementation
- **Type**: lean4
- **Session**: sess_1782280000_syntactic_vea
- **Agent**: lean-research-agent

---

## 1. Executive Summary

The semantic `IsVEA` predicate in `ArityReduction.lean` fails because negation of an existential projection is not an existential projection at arity >= 3. The correct fix is to define V-EA formulas as a **syntactic type** that directly encodes Rabinovich's Definition 3.1 at arbitrary arity m. This report designs a concrete `VecEA_m` type and traces through all four closure properties (disjunction, conjunction, negation, existential quantification) to verify feasibility. The design reuses all existing sorry-free infrastructure and eliminates the biconditional blocker that stopped plan v30 Phase 2.

### Key Design Choice: Option (d) -- Consecutive-Pair Decomposition

Of the four options enumerated in the task description:

- **(a) Inductive type mirroring V-EA syntax**: Overly complex. EA formulas are not inductively defined -- they are a single layer of existential quantifiers over an interval decomposition.
- **(b) Wrapper around `List (Fin m x Fin m x VVecEA2)`**: Pairs are unordered, creating redundancy and making operations awkward.
- **(c) Function `Fin m -> Fin m -> VVecEA2`**: This IS the failed `IsVEA` predicate in a different coat. Same negation problem.
- **(d) Consecutive-pair product**: A `VecEA_m` is a sequence of `m-1` VVecEA2 components, one for each consecutive pair `(z_k, z_{k+1})` of free variables, plus endpoint predicates at each free variable. Negation operates via de Morgan on the conjunction.

Option (d) is faithful to Rabinovich and avoids the existential-projection mismatch.

---

## 2. Root Cause Analysis: Why the Semantic `IsVEA` Failed

### The Current `IsVEA` Definition (ArityReduction.lean:69-79)

```lean
def IsVEA {sig : MonadicSignature} {m : Nat}
    (atomMap : Formula → sig.preds) (phi : MonadicFormula sig m) : Prop :=
  ∀ (i j : Fin m), i < j →
    ∃ (v : VVecEA2),
      ∀ (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (zi zj : M.carrier) (h_lt : zi < zj),
        v.holds M atomMap zi zj ↔
        ∃ (env : Fin m → M.carrier),
          env i = zi ∧ env j = zj ∧ eval M env phi
```

### The Negation Blocker (Arity >= 3)

At arity m >= 3, to show `IsVEA (.not phi)`, we need for each pair (i, j):

```
v'.holds zi zj ↔ ∃ env, env i = zi ∧ env j = zj ∧ ¬(eval M env phi)
```

From the IH (`IsVEA phi`), we have for the same pair (i, j):

```
v.holds zi zj ↔ ∃ env, env i = zi ∧ env j = zj ∧ eval M env phi
```

The negation gives:

```
¬(v.holds zi zj) ↔ ∀ env, env i = zi → env j = zj → ¬(eval M env phi)
```

But we need the EXISTENTIAL version: `∃ env, env i = zi ∧ env j = zj ∧ ¬(eval M env phi)`.

These are logically distinct:
- `¬∃ env, P(env)` = `∀ env, ¬P(env)` (no env satisfies P)
- `∃ env, ¬P(env)` (some env fails P)

At arity 2, `env` is uniquely determined by `(zi, zj)`, so the existential and universal collapse. At arity >= 3, there are unconstrained variables, and they do not.

### Why Lemma 3.2(2) Resolves This

Rabinovich's approach does NOT negate individual pairwise projections. Instead:

1. **Lemma 3.2(2)**: An m-variable EA formula is equivalent to a conjunction of 2-variable EA formulas:
   ```
   eval M env phi ↔ ∧_{k=0}^{m-2} v_k.holds M (env k) (env (k+1))
   ```
   where each `v_k` is a VVecEA2 capturing the interval (z_k, z_{k+1}).

2. **Negation via de Morgan**:
   ```
   ¬(eval M env phi) ↔ ∨_{k=0}^{m-2} ¬(v_k.holds M (env k) (env (k+1)))
   ```

3. **Prop 4.2 on each disjunct**: Each `¬(v_k.holds zi z_{i+1})` is a VVecEA2 by `neg_2var_vec_ea_indep`. The disjunction of VVecEA2s is V-EA by Lemma 3.4.

The critical difference: Prop 4.2 gives a FORWARD implication `¬v.holds → neg_v.holds`, which is SUFFICIENT for the conjunction-then-de-Morgan approach. We never need the backward direction because:

- The conjunction equivalence provides the biconditional at the formula level
- The negation of the conjunction uses de Morgan (exact, not approximate)
- Each de Morgan disjunct uses Prop 4.2 FORWARD only
- The resulting V-EA is correct by construction

This is why the biconditional for VVecEA2 negation was never the real issue -- the real issue was using pairwise existential projections instead of a conjunction equivalence.

---

## 3. H3 Mapping Table: Rabinovich Concept -> Proposed Lean 4 Type/Function

| Rabinovich Concept | Section | Proposed Lean 4 | Status | Notes |
|-------------------|---------|-----------------|--------|-------|
| EA formula, m free vars | Def 3.1 | `VecEA_m (m : Nat)` | NEW | Consecutive-pair product of VVecEA2s |
| V-EA formula, m free vars | Def 3.3 | `VecEA_m` (inherently disjunctive via VVecEA2) | NEW | Each component is already V-EA |
| EA formula, 2 free vars | Def 3.1 (m=2) | `VVecEA2` | EXISTS | VecEAFormula.lean, sorry-free |
| V-EA formula, 2 free vars | Def 3.3 (m=2) | `VVecEA2` | EXISTS | VecEAFormula.lean, sorry-free |
| Bracket notation [alpha,beta,...] | Not. 5.2 | `BracketFormula` | EXISTS | VecEAFormula.lean, sorry-free |
| Lemma 3.2(1): conjunction closure | p.4 | `VVecEA2.conj_struct` | EXISTS | VecEAClosure.lean, sorry-free |
| Lemma 3.2(2): arity reduction | p.4 | `VecEA_m.toConjVVecEA2` | NEW | Trivial: consecutive components |
| Lemma 3.2(3): existential closure | p.4 | `VecEA_m.existClosure` | NEW | Absorb first variable |
| Lemma 3.4: V-EA closure (disj) | p.4 | `VVecEA2.disj` | EXISTS | VecEAFormula.lean, sorry-free |
| Lemma 3.4: V-EA closure (conj) | p.4 | `VVecEA2.conj_struct` | EXISTS | VecEAClosure.lean, sorry-free |
| Lemma 3.4: V-EA closure (exists) | p.4 | `VecEA_m.existClosure` | NEW | Extends Lemma 3.2(3) |
| Prop 3.5: V-EA 1-var -> TL | p.5 | `ExistsForallSpec.translate_correct` | EXISTS | RabinovichTranslation.lean, sorry-free |
| Prop 4.2: negation closure (2-var) | p.6 | `neg_2var_vec_ea_indep` | EXISTS | NegationIndep.lean, sorry-free |
| Prop 4.3: FO -> V-EA | p.6 | `fo_to_vecEA_m` | NEW | Structural induction on MonadicFormula |
| Theorem 4.4: Kamp's theorem | p.6 | `kamp_prior_expressive_completeness` | MODIFY | Replace sorry with Prop 4.3 + Prop 3.5 |
| Lemma 5.1: bracket negation | p.7-11 | `neg_interval_formula_indep` | EXISTS | NegationIndep.lean, sorry-free |
| INF formula | p.8,10 | `prior_hasAttainedINF` | EXISTS | PriorINF.lean, sorry-free |

---

## 4. Concrete Type Signatures

### 4.1 VecEA_m: The Core Type

```lean
/-- A V-EA formula at arity m (Rabinovich Def 3.1/3.3, generalized).

    Represents a formula with m ordered free variables z_0 < z_1 < ... < z_{m-1}
    as a product of m-1 VVecEA2 components, one per consecutive pair, plus
    endpoint predicates at each free variable position.

    The semantics: `holds M atomMap env` iff `env` is strictly increasing AND
    each endpoint predicate holds at the corresponding env value AND
    each interval component holds on its consecutive pair.

    At m = 0: trivially true (no constraints).
    At m = 1: a single endpoint predicate (no interval components).
    At m = 2: equivalent to VVecEA2 (one interval component + two endpoints).
    At m >= 3: product of m-1 VVecEA2 components.

    This type is NOT an inductive/recursive type -- it is a flat product.
    Negation operates via de Morgan on the conjunction of components. -/
structure VecEA_m (m : Nat) where
  /-- Endpoint predicates at each free variable position.
      endpointPred k holds at z_k. -/
  endpointPreds : Fin m → TemporalPred
  /-- Interval components: for each k < m-1, a VVecEA2 capturing the
      V-EA formula on the interval (z_k, z_{k+1}). -/
  intervalComponents : Fin (m - 1) → VVecEA2
```

### 4.2 Semantics

```lean
/-- A VecEA_m formula holds on an environment if:
    1. The environment is strictly increasing
    2. Each endpoint predicate holds at its position
    3. Each interval component holds on its consecutive pair -/
def VecEA_m.holds {sig : MonadicSignature} {m : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (vea : VecEA_m m) (env : Fin m → M.carrier) : Prop :=
  (∀ i j : Fin m, i < j → env i < env j) ∧
  (∀ k : Fin m, (vea.endpointPreds k).eval_at M atomMap (env k)) ∧
  (∀ k : Fin (m - 1),
    (vea.intervalComponents k).holds M atomMap (env ⟨k, by omega⟩) (env ⟨k + 1, by omega⟩))
```

### 4.3 Key Operations

#### Disjunction (from Lemma 3.4)

```lean
/-- Disjunction of VecEA_m formulas: pointwise disjunction of interval
    components. Requires both formulas to have the same arity. -/
def VecEA_m.disj {m : Nat} (v1 v2 : VecEA_m m) : VecEA_m m :=
  -- Not a simple pointwise operation because the endpoint predicates
  -- must be handled. The disjunction of two VecEA_m is represented as
  -- a List (VecEA_m m) externally, or handled via VVecEA_m.
  -- See VVecEA_m below.
  sorry -- Design note: use VVecEA_m instead
```

Better: define a disjunctive wrapper:

```lean
/-- V-VecEA at arity m: a disjunction of VecEA_m formulas.
    This is the arity-m analogue of VVecEA2. -/
structure VVecEA_m (m : Nat) where
  disjuncts : List (VecEA_m m)

def VVecEA_m.holds {sig : MonadicSignature} {m : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (v : VVecEA_m m) (env : Fin m → M.carrier) : Prop :=
  ∃ vea ∈ v.disjuncts, vea.holds M atomMap env
```

#### Negation (via de Morgan + Prop 4.2)

```lean
/-- Negate a single VecEA_m conjunct (one VecEA_m disjunct).

    The negation of endpointPred(0) ∧ ... ∧ endpointPred(m-1) ∧ interval(0) ∧ ... ∧ interval(m-2)
    is by de Morgan:
    ¬endpointPred(0) ∨ ... ∨ ¬endpointPred(m-1) ∨ ¬interval(0) ∨ ... ∨ ¬interval(m-2)

    Each ¬endpointPred(k) is a trivial VecEA_m with negated endpoint.
    Each ¬interval(k) is a VVecEA2 via Prop 4.2 (neg_2var_vec_ea_indep).
    The disjunction produces a VVecEA_m. -/
def VecEA_m.neg {m : Nat} (vea : VecEA_m m) : VVecEA_m m :=
  -- Case 1: endpoint failures (m disjuncts)
  let endpointCases : List (VecEA_m m) :=
    (List.finRange m).map fun k =>
      { endpointPreds := fun j => if j = k then (vea.endpointPreds k).neg
                                  else TemporalPred.top
        intervalComponents := fun _ => VVecEA2.trivialTrue }
  -- Case 2: interval failures (m-1 disjuncts)
  -- For each interval component k, negate it via Prop 4.2
  let intervalCases : List (VecEA_m m) :=
    (List.finRange (m - 1)).flatMap fun k =>
      let negComp := neg_2var_vec_ea_indep (vea.intervalComponents k)
      -- Each disjunct of negComp becomes a VecEA_m with that VVecEA2 at position k
      negComp.disjuncts.map fun ⟨n, vea2⟩ =>
        { endpointPreds := fun _ => TemporalPred.top
          intervalComponents := fun j =>
            if j = k then ⟨[⟨n, vea2⟩]⟩ else VVecEA2.trivialTrue }
  ⟨endpointCases ++ intervalCases⟩

/-- Negate a VVecEA_m (disjunction): negate each disjunct, conjoin results. -/
def VVecEA_m.neg {m : Nat} (v : VVecEA_m m) : VVecEA_m m :=
  -- ¬(d_1 ∨ d_2 ∨ ... ∨ d_k) = ¬d_1 ∧ ¬d_2 ∧ ... ∧ ¬d_k
  -- Each ¬d_i is a VVecEA_m. The conjunction is a VVecEA_m via conj.
  v.disjuncts.foldl (fun acc d => acc.conj (d.neg)) VVecEA_m.trivialTrue
```

#### Conjunction (from Lemma 3.4)

```lean
/-- Conjunction of VVecEA_m formulas: Cartesian product of disjunct lists,
    conjoining each pair pointwise. -/
def VVecEA_m.conj {m : Nat} (v1 v2 : VVecEA_m m) : VVecEA_m m :=
  { disjuncts := v1.disjuncts.flatMap fun vea1 =>
      v2.disjuncts.map fun vea2 =>
        { endpointPreds := fun k => (vea1.endpointPreds k).conj (vea2.endpointPreds k)
          intervalComponents := fun k =>
            VVecEA2.conj_struct (vea1.intervalComponents k) (vea2.intervalComponents k) } }
```

#### Existential Closure (Lemma 3.2(3) / Lemma 3.4)

```lean
/-- Existential closure: VecEA_m (m+1) -> VecEA_m m.

    Quantifying out variable z_0 from a (m+1)-variable formula:
    The interval component for (z_0, z_1) gets absorbed into the
    endpoint predicate for z_1 (now z_0 in the reduced formula).

    The key operation: ∃ z_0 < z_1, endpointPred(0)(z_0) ∧ interval(0)(z_0, z_1)
    produces a new VVecEA2 at z_1 that existentially bounds the left endpoint. -/
def VecEA_m.existClosure {m : Nat} (vea : VecEA_m (m + 1)) : VVecEA_m m :=
  -- Absorb the first variable:
  -- New endpoint(k) = old endpoint(k+1) for k = 0..m-1
  -- New interval(k) = old interval(k+1) for k = 0..m-2
  -- The absorbed part (endpoint(0) + interval(0)) contributes to the
  -- semantics via existential quantification
  sorry -- Detailed construction in Section 5
```

### 4.4 Prop 4.3: Structural Induction

```lean
/-- Proposition 4.3 (Rabinovich): Every MonadicFormula at arity m is equivalent
    to a VVecEA_m on Prior structures. -/
noncomputable def fo_to_vecEA_m
    {sig : MonadicSignature} {m : Nat}
    (atomMap : Formula → sig.preds)
    (phi : MonadicFormula sig m) :
    { v : VVecEA_m m //
      ∀ (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (env : Fin m → M.carrier)
        (h_ord : ∀ i j : Fin m, i < j → env i < env j),
        v.holds M atomMap env ↔ eval M env phi } :=
  match phi with
  | .atom p i => -- Trivial VecEA_m with predicate at position i
      sorry
  | .lt i j => -- Order atom: trivial if i < j, false otherwise
      sorry
  | .not alpha =>
      let ⟨v_alpha, h_alpha⟩ := fo_to_vecEA_m atomMap alpha
      ⟨v_alpha.neg, sorry⟩  -- Uses VVecEA_m.neg (de Morgan + Prop 4.2)
  | .and alpha beta =>
      let ⟨v_alpha, h_alpha⟩ := fo_to_vecEA_m atomMap alpha
      let ⟨v_beta, h_beta⟩ := fo_to_vecEA_m atomMap beta
      ⟨v_alpha.conj v_beta, sorry⟩  -- Uses VVecEA_m.conj
  | .all alpha =>
      -- all phi = not (ex (not phi))
      let ⟨v_not_alpha, _⟩ := fo_to_vecEA_m atomMap (.not alpha)  -- IH on not alpha
      let v_ex := VVecEA_m.existClosure_list v_not_alpha  -- Existential closure
      ⟨v_ex.neg, sorry⟩  -- Negate again
  | .ex alpha =>
      let ⟨v_alpha, h_alpha⟩ := fo_to_vecEA_m atomMap alpha  -- IH at arity m+1
      ⟨VVecEA_m.existClosure_list v_alpha, sorry⟩  -- Existential closure
```

### 4.5 Specialization to Arity 1 and Translation

```lean
/-- At arity 1, a VecEA_m 1 has no interval components and a single endpoint
    predicate. It is equivalent to a temporal predicate. -/
def VVecEA_m.toTemporal (v : VVecEA_m 1) : Formula :=
  -- Disjunction of endpoint predicates
  formula_disjList (v.disjuncts.map fun vea => (vea.endpointPreds ⟨0, by omega⟩).formula)

/-- At arity 2, a VecEA_m 2 has one interval component (a VVecEA2).
    It is translatable to a temporal formula via Prop 3.5. -/
def VVecEA_m.toFormulaArity2 (v : VVecEA_m 2) : Formula :=
  -- Each disjunct has endpointPreds and one VVecEA2
  -- Use VVecEA2.translateLeft for the interval component
  -- Combine with endpoint predicates
  sorry -- Uses existing VecEATranslation.lean infrastructure

/-- Theorem 4.4 bridge: fo_to_vecEA_m at arity 1 produces a
    temporal formula via VVecEA_m.toTemporal. -/
noncomputable def fo_to_temporal
    {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (phi : MonadicFormula sig 1) :
    { A : Formula //
      ∀ (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        temporal_truth M atomMap t A ↔ eval M (fun _ => t) phi } :=
  let ⟨v, hv⟩ := fo_to_vecEA_m atomMap phi
  ⟨v.toTemporal, sorry⟩ -- Correctness from hv + toTemporal semantics
```

---

## 5. Detailed Design for Existential Closure

The existential closure `VecEA_m (m+1) -> VVecEA_m m` is the most complex operation. It must absorb the first variable (De Bruijn index 0, corresponding to z_0 in the ordered sequence) into an existential quantifier.

### The Problem

Given `vea : VecEA_m (m+1)` with semantics:
```
vea.holds M env <->
  (env strictly increasing) ∧
  (∀ k, endpointPred(k) holds at env(k)) ∧
  (∀ k < m, intervalComponent(k).holds (env k) (env (k+1)))
```

We need `VVecEA_m m` with semantics:
```
result.holds M env' <->
  ∃ x, vea.holds M (Fin.cons x env')
```

where `Fin.cons x env'` prepends x as the new variable z_0.

### The Construction

After substituting `Fin.cons x env'`:
```
∃ x,
  (x < env'(0) < env'(1) < ... < env'(m-1)) ∧      -- ordering
  (endpointPred(0) at x) ∧                           -- endpoint at x
  (∀ k > 0, endpointPred(k) at env'(k-1)) ∧         -- shifted endpoints
  (intervalComponent(0).holds x (env'(0))) ∧          -- interval (x, z_1)
  (∀ k > 0, k < m, intervalComponent(k).holds (env'(k-1)) (env'(k)))  -- shifted intervals
```

The existential quantifier `∃ x` ranges over `x < env'(0)`. The terms involving x are:
- `endpointPred(0) at x`
- `intervalComponent(0).holds x (env'(0))`

These can be absorbed: the existential quantification `∃ x < env'(0), endpointPred(0)(x) ∧ intervalComponent(0).holds(x, env'(0))` produces a new condition at env'(0). This condition involves VVecEA2 existential closure (Lemma 3.4/3.2(3) -- `existsBounded_right` from VecEAClosure.lean or similar).

The result:
```lean
def VecEA_m.existClosure {m : Nat} (vea : VecEA_m (m + 1)) : VVecEA_m m :=
  -- The absorbed existential modifies the first endpoint and removes the first interval
  -- New endpointPred(0) = absorbed(endpointPred(0), intervalComponent(0))
  -- New endpointPred(k) = old endpointPred(k+1) for k > 0
  -- New intervalComponent(k) = old intervalComponent(k+1) for k >= 0
  sorry -- Implementation requires VVecEA2 left-existential closure
```

The required VVecEA2 operation: given `v : VVecEA2` and `p : TemporalPred`, construct a `TemporalPred` tp such that:
```
tp.eval_at M atomMap z1 <-> ∃ z0 < z1, p.eval_at M atomMap z0 ∧ v.holds M atomMap z0 z1
```

This is a temporal predicate because v.holds is definable via buildRight/buildLeft (Prop 3.5), and the existential is expressed as `∃ z0 < z1, p(z0) ∧ future_chain(z0)`, which is `p Since future_chain` or similar temporal construction.

Actually, looking at the existing infrastructure: `VVecEA2.translateLeft` (VecEATranslation.lean) already translates VVecEA2 to temporal formulas that capture the "left endpoint is the evaluation point" case. The existential closure amounts to existentially quantifying the left endpoint, which produces a `True Since (...)` temporal formula.

---

## 6. Correctness Argument: Why Only the Forward Direction of Prop 4.2 is Needed

This is the central insight that makes the syntactic VecEA_m approach work where the semantic IsVEA approach failed.

### The Semantic IsVEA Approach (Failed)

Required: For each pair (i,j), a VVecEA2 v such that `v.holds ↔ ∃ env, ... eval phi`. Negation requires: `neg_v.holds ↔ ∃ env, ... ¬eval phi`. This needs the BICONDITIONAL for VVecEA2 negation.

### The Syntactic VecEA_m Approach (Proposed)

The correctness theorem for `fo_to_vecEA_m` is:

```
v.holds M atomMap env ↔ eval M env phi
```

For the negation case (`phi = .not alpha`):

1. By IH: `v_alpha.holds env ↔ eval M env alpha`
2. Therefore: `eval M env (.not alpha) ↔ ¬(eval M env alpha) ↔ ¬(v_alpha.holds env)`
3. `v_alpha.holds env` is a conjunction: `∧_k endpoint_k ∧ ∧_k interval_k`
4. `¬(v_alpha.holds env)` is `∨_k ¬endpoint_k ∨ ∨_k ¬interval_k` (de Morgan, exact)
5. Each `¬interval_k = ¬(vvecEA2_k.holds z_k z_{k+1})`
6. By `neg_2var_vec_ea_indep_correct` (FORWARD ONLY): `¬(vvecEA2_k.holds z_k z_{k+1}) → (neg_2var_vec_ea_indep vvecEA2_k).holds z_k z_{k+1}`
7. The constructed VVecEA_m uses `neg_2var_vec_ea_indep` for each interval component

For the FORWARD direction of the correctness theorem:
```
¬(v_alpha.holds env) → neg_v.holds env
```
This follows from step 6 (FORWARD of Prop 4.2) + de Morgan.

For the BACKWARD direction of the correctness theorem:
```
neg_v.holds env → ¬(v_alpha.holds env)
```
Each disjunct of neg_v asserts that SOME component fails. If an endpoint predicate is negated (case 1), then the conjunction in v_alpha fails at that endpoint. If an interval component is negated (case 2), then `(neg_2var_vec_ea_indep vvecEA2_k).holds z_k z_{k+1}` holds. We need: this implies `¬(vvecEA2_k.holds z_k z_{k+1})`.

**Wait -- this IS the backward direction of Prop 4.2.**

However, there is a subtler argument available. The backward direction is actually:

```
(neg_2var_vec_ea_indep v).holds z0 z1 → ¬(v.holds z0 z1)
```

This is equivalent to showing that `v.holds z0 z1` and `(neg_2var_vec_ea_indep v).holds z0 z1` cannot both hold. This is DISJOINTNESS of v and neg_v.

For the specific construction in `neg_2var_vec_ea_indep`:
- Case 1a: `endpointLeft.neg` holds → `endpointLeft` fails → v.holds fails (v requires endpointLeft)
- Case 1b: `endpointRight.neg` holds → `endpointRight` fails → v.holds fails
- Case 2/3: `neg_interval_formula_indep` holds → the bracket part fails → v.holds fails

Each case is a direct contradiction with one of v's conjuncts. This is straightforward to prove because:
- `tp.neg.eval_at` and `tp.eval_at` are contradictory (by TemporalPred.eval_at_neg')
- `neg_interval_formula_indep` holds only when the bracket fails (by construction in NegationIndep.lean, the forward direction IS "bracket fails → neg holds", and the backward direction IS "neg holds → bracket fails" because the neg formula witnesses a point where the bracket's universal property fails)

**Assessment**: The backward direction `neg_2var_vec_ea_indep_backward` IS needed and IS provable. It is approximately 100-150 lines of case analysis on the three-case construction. The claim in the handoff that "only the forward direction is proved" is correct, but the backward direction is provable without any new theoretical ideas.

---

## 7. Architecture Assessment: What to Archive vs. Preserve

### Files to PRESERVE (sorry-free, reused directly)

| File | Lines | Role in New Architecture |
|------|------:|------------------------|
| VecEAFormula.lean | 769 | Core types: BracketFormula, VecEA2, VVecEA2, splitting ops |
| VecEAClosure.lean | 386 | Lemma 3.4: conj_struct, disj closure, existential closure |
| NegationIndep.lean | 328 | Model-independent Lemma 5.1 + Prop 4.2 (forward direction) |
| EANegationClosure.lean | ~500 | Model-dependent Lemma 5.1 / Prop 4.2, supporting infrastructure |
| EANegation.lean | ~1300 | Lemma 5.3, Cor 5.4, prepend/prependAll, inf_bracket_formula |
| PriorINF.lean | ~200 | HasAttainedINF, prior_hasAttainedINF |
| RabinovichTranslation.lean | ~300 | Prop 3.5: ExistsForallSpec.translate_correct |
| VecEATranslation.lean | ~200 | VVecEA2 -> temporal Formula bridge |
| Translation.lean | ~400 | buildRight, buildLeft infrastructure |
| ExistsForallNF.lean | ~270 | TemporalPred, IntervalPattern, VEF types |
| NfToVecEA.lean | varies | Depth-0 NF -> VecEA2 bridge |
| VecEADecomp.lean | varies | Depth-0 zone decomposition |
| KampPrior.lean | ~380 | Main theorem; k=0 and k=1 cases preserved |

### Files to ARCHIVE to Boneyard

| File | Lines | Reason |
|------|------:|--------|
| ArityReduction.lean | 110 | Contains failed `IsVEA` predicate. `isVEA_ex` is correct but superseded by VecEA_m.existClosure. The predicate formulation is fundamentally flawed for negation at arity >= 3. |

### Files ALREADY in Boneyard

The Boneyard already contains 8+ files (FOToVEA, NfExistTL, EndpointNegation, KampComposition, NfComposition, SeparationBridge, WitnessCount, ZoneBridge, Prop43). These remain archived.

---

## 8. Estimated Line Counts

| Component | File | Est. Lines | Risk |
|-----------|------|------:|:----:|
| VecEA_m type + semantics | VecEAGeneral.lean (NEW) | 80-120 | Low |
| VVecEA_m type + disj/conj | VecEAGeneral.lean (NEW) | 60-100 | Low |
| VecEA_m.neg (de Morgan + Prop 4.2) | VecEAGeneral.lean (NEW) | 100-180 | Medium |
| neg_2var_vec_ea_indep_backward | NegationIndep.lean (MODIFY) | 100-150 | Medium |
| VecEA_m.existClosure | VecEAGeneral.lean (NEW) | 150-250 | High |
| VVecEA_m.neg correctness | VecEAGeneral.lean (NEW) | 80-150 | Medium |
| VVecEA_m.conj correctness | VecEAGeneral.lean (NEW) | 50-80 | Low |
| fo_to_vecEA_m (Prop 4.3) | StructuralInduction.lean (NEW) | 200-350 | Medium |
| fo_to_temporal (arity-1 specialization) | StructuralInduction.lean (NEW) | 80-150 | Low |
| KampPrior.lean rewiring | KampPrior.lean (MODIFY) | 50-100 | Low |
| **Total** | | **950-1630** | |

---

## 9. Risk Assessment

### High Risk: Existential Closure (VecEA_m.existClosure)

**Risk**: The absorption of the first variable requires constructing a temporal predicate that captures `∃ z_0 < z_1, p(z_0) ∧ v.holds(z_0, z_1)`. This existential is bounded (z_0 < z_1), so it is expressible as `p Since (v.translateLeft)` or via `VBracketFormula.existsBounded_right` (VecEAClosure.lean). However, the VVecEA2 infrastructure works with `holds M atomMap z0 z1`, which requires two concrete carrier elements. Converting to a temporal predicate at z_1 only requires expressing the existential over z_0 as a temporal formula.

**Mitigation**: The existing `bracketBuildRight` (VecEATranslation.lean) converts bracket formulas to temporal formulas with the left endpoint as the evaluation point. A "buildLeft" variant would handle the right endpoint. The Since modality provides exactly the bounded existential: `p Since q` holds at z_1 iff `∃ z_0 < z_1, q(z_0) ∧ ∀ y ∈ (z_0, z_1), p(y)`.

**Alternative mitigation**: At arity 1, the existential closure produces arity 0 (a sentence). The only case that matters for KampPrior is `MonadicFormula sig 1`, which under the `.ex` constructor produces `MonadicFormula sig 2`. The IH at arity 2 gives `VVecEA_m 2`, which has one interval component (a VVecEA2). The existential closure absorbs the first variable, producing `VVecEA_m 1` (just an endpoint predicate, no interval components). This is the simplest possible case.

### Medium Risk: neg_2var_vec_ea_indep_backward

**Risk**: Proving that `(neg_2var_vec_ea_indep v).holds z0 z1 → ¬(v.holds z0 z1)` requires case-splitting on which disjunct of `neg_2var_vec_ea_indep v` holds and showing it contradicts some conjunct of `v.holds z0 z1`.

**Mitigation**: The construction in `neg_vecEA2_indep` (NegationIndep.lean:188-200) has three clear cases:
- case1a: `endpointLeft.neg` → contradicts `endpointLeft` in v.holds
- case1b: `endpointRight.neg` → contradicts `endpointRight` in v.holds
- case23: bracket negation → contradicts bracket in v.holds

Each case is a direct `TemporalPred.eval_at_neg'` contradiction. The inductive structure of `neg_interval_formula_indep` (line 61-84) means we also need the backward direction for `neg_interval_formula_indep`: that `(neg_interval_formula_indep n bf).holds z0 z1 → ¬(bf.holds z0 z1)`. This is provable by the same case analysis: each disjunct of the construction witnesses a specific failure of bf.holds.

### Low Risk: VecEA_m type definition and structural induction

The type definition is a simple product structure. The structural induction follows Rabinovich's cases exactly, with each case delegating to an existing closure operation. The arity-1 specialization is the simplest case.

---

## 10. Ordering Constraint Design Decision

### The Problem

The VecEA_m semantics require `env` to be strictly increasing. But `MonadicFormula.eval` has no ordering constraint on the environment. For Prop 4.3 to work, we need:

```
v.holds M atomMap env ↔ eval M env phi
```

where `v.holds` requires strictly increasing env but `eval` does not.

### The Resolution

Rabinovich's EA formulas are defined for ORDERED free variables `z_0 < z_1 < ... < z_{m-1}`. The structural induction in Prop 4.3 produces equivalence only when variables are ordered. For Kamp's theorem, this is fine: we only need the arity-1 case (one variable, ordering is vacuous) and the arity-2 case (two ordered variables z_0 < z_1).

The correctness theorem should be:

```lean
noncomputable def fo_to_vecEA_m ... :
    { v : VVecEA_m m //
      ∀ M h_UZ h_SZ (env : Fin m → M.carrier),
        (∀ i j : Fin m, i < j → env i < env j) →  -- ordering precondition
        (v.holds M atomMap env ↔ eval M env phi) }
```

For the `.lt i j` atomic case: if `i < j`, then `env i < env j` is guaranteed by the ordering precondition, so it holds. If `i >= j`, then `env i >= env j` by the ordering precondition (contrapositively), so `env i < env j` is false. The VecEA_m for `.lt i j` is either trivially true or trivially false depending on whether `i < j`.

For the `.ex` case: the sub-formula has arity m+1. The IH applies with an ordered environment `(x, env(0), ..., env(m-1))`. The ordering requires `x < env(0)`. This is exactly the bounded existential that the existential closure handles.

Wait -- but the De Bruijn convention has variable 0 as the INNERMOST bound variable. Under `.ex alpha`, `alpha` has arity m+1, and `eval M env (.ex alpha) = ∃ x, eval M (Fin.cons x env) alpha`. The environment `Fin.cons x env` has `(Fin.cons x env) 0 = x` and `(Fin.cons x env) (k+1) = env k`. For this to be ordered, we need `x < env 0 < env 1 < ...`, i.e., x is the SMALLEST.

This works perfectly with the VecEA_m existential closure design: absorbing variable 0 (the first/smallest in the ordering) produces a bounded existential `∃ x < env(0), ...`.

---

## 11. Alternative: Predicate-Based Approach with Biconditional Fix

Before committing to the full VecEA_m type, consider whether fixing just the backward direction of Prop 4.2 would unblock the semantic `IsVEA` predicate approach.

### What would be needed

1. `neg_2var_vec_ea_indep_backward`: ~100-150 lines (same as in the VecEA_m approach)
2. Modify `IsVEA` to carry both forward and backward VVecEA2 simultaneously
3. Or: use the biconditional directly at arity 2 and handle arity >= 3 via a different predicate

### Why this still does not work at arity >= 3

Even with the full biconditional for VVecEA2 negation at arity 2, the `IsVEA` predicate at arity >= 3 fails:

The negation of `∃ env, env i = zi ∧ env j = zj ∧ eval M env phi` is `∀ env, env i = zi → env j = zj → ¬(eval M env phi)`, NOT `∃ env, env i = zi ∧ env j = zj ∧ ¬(eval M env phi)`.

The biconditional for VVecEA2 at arity 2 does not help because the issue is the existential quantifier over the unconstrained variables in the projection, not the VVecEA2 negation per se.

### Verdict

The predicate-based approach is fundamentally incompatible with negation at arity >= 3. The VecEA_m type (or any approach based on Lemma 3.2(2)'s conjunction decomposition) is necessary.

---

## 12. Recommended Implementation Order

1. **neg_2var_vec_ea_indep_backward** (~100-150 lines in NegationIndep.lean)
   - Prove the backward direction of Prop 4.2
   - This is needed by both the VecEA_m approach and as standalone progress
   - Low risk, well-understood case analysis

2. **VecEA_m type + VVecEA_m wrapper** (~140-220 lines in VecEAGeneral.lean)
   - Define the types and basic operations (holds, disj, conj)
   - Low risk, straightforward product type

3. **VecEA_m.neg** (~100-180 lines in VecEAGeneral.lean)
   - De Morgan decomposition + Prop 4.2 (both directions)
   - Medium risk, requires careful case bookkeeping

4. **VecEA_m.existClosure** (~150-250 lines in VecEAGeneral.lean)
   - Absorb first variable via bounded existential
   - High risk, requires interfacing with VVecEA2 translation

5. **fo_to_vecEA_m (Prop 4.3)** (~200-350 lines in StructuralInduction.lean)
   - Structural induction using closure operations from steps 2-4
   - Medium risk, case-by-case application of closure lemmas

6. **Arity-1 specialization + KampPrior rewiring** (~130-250 lines)
   - Extract temporal formula from VVecEA_m 1
   - Bridge with existing nf_to_formula for KampPrior
   - Low risk

---

## 13. Connection to Existing isVEA_ex

The existing `isVEA_ex` theorem (ArityReduction.lean:91-109) proves that the semantic IsVEA predicate is closed under existential quantification. This theorem is CORRECT -- the existential case does not have the negation problem. It should be preserved as evidence that the existential case works, but it will be superseded by `VecEA_m.existClosure` in the new architecture.

The key difference: `isVEA_ex` shifts variable indices (pair (i,j) in `.ex phi` maps to pair (i.succ, j.succ) in phi), while `VecEA_m.existClosure` absorbs the first variable position. Both handle the same mathematical content (Lemma 3.2(3) / Lemma 3.4 existential closure) but with different representations.

---

## 14. Summary

The semantic `IsVEA` predicate approach is structurally unable to handle negation at arity >= 3 because existential projections do not commute with negation. The correct replacement is a syntactic `VecEA_m` type encoding a V-EA formula as a product of consecutive-pair VVecEA2 components. This design:

- Directly encodes Rabinovich's Lemma 3.2(2) as a trivial decomposition (the components ARE the consecutive-pair conjunction)
- Handles negation via de Morgan + Prop 4.2 (forward direction from NegationIndep.lean + provable backward direction)
- Handles existential closure by absorbing the first variable via bounded existential
- Reuses all existing sorry-free infrastructure (VVecEA2, VecEAClosure, NegationIndep, RabinovichTranslation, PriorINF)
- Requires archiving only ArityReduction.lean (110 lines)
- Estimated 950-1630 new lines across 2 new files + 2 modified files
