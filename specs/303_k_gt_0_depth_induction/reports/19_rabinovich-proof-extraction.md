# Deep Analysis: Rabinovich 2014 -- Proof Extraction for Lean Formalization

**Task**: 303 - k_gt_0_depth_induction
**Purpose**: Step-by-step reference document extracting the EXACT proof mechanism from Rabinovich 2014 "A Simple Proof of Kamp's Theorem" for resolving the zone-3 existential transfer sorry in `PriorComposition.lean`.
**Source**: Rabinovich, A. (2014). *A Proof of Kamp's Theorem*. LMCS 10(1:14), pp. 1--16.
**Date**: 2026-06-19

---

## Part 1: The Overall Architecture

### 1.1 The Central Goal

Kamp's Theorem (Theorem 2.1): Over Dedekind complete chains, TL(Until, Since) is expressively equivalent to FOMLO (First-Order Monadic Logic of Order). The easy direction is TL -> FOMLO by structural induction on temporal formulas. The hard direction (FOMLO -> TL) is the paper's contribution.

### 1.2 Key Definitions

**Sigma-chain**: M = (T, <, I) where T is a domain with linear order < and interpretation I : Sigma -> P(T) for unary predicates.

**Exists-forall formula (Definition 3.1)**: A formula of the form

    psi(z_0, ..., z_m) := exists x_n ... exists x_1 exists x_0
      (ordering constraints on x_i and z_j)
      AND (alpha_j(x_j) holds at x_j, for j = 0..n)
      AND (beta_j holds along (x_{j-1}, x_j), for j = 1..n)
      AND (beta_{n+1} holds everywhere after x_n)
      AND (beta_0 holds everywhere before x_0)

where each alpha_j, beta_j is quantifier-free over Sigma. The i_0, ..., i_m specify where the free variables z_0, ..., z_m are positioned relative to the existentially quantified x_0, ..., x_n.

**Key idea**: This describes an **interval decomposition** of the chain -- existentially chosen witness points partition the chain into sub-intervals, each labeled by a "type" (alpha at points, beta along intervals).

**V-exists-forall formula (Definition 3.3)**: A formula equivalent to a disjunction of exists-forall formulas.

**Interval notation (Notation 5.2)**: `[alpha_0, beta_1, alpha_1, ..., beta_n, alpha_n](z_0, z_1)` abbreviates the exists-forall formula:

    exists x_0 ... exists x_n [(z_0 = x_0 < ... < x_n = z_1)
      AND alpha_j(x_j) for all j
      AND (forall y in (x_{j-1}, x_j)) beta_j(y) for all j]

This is the formula asserting: "there exist n-1 points between z_0 and z_1 partitioning the interval, with type alpha_j at the j-th point and type beta_j along the j-th sub-interval."

**K+(F)** ("next occurrence from above"): K+(F) holds at t iff t = inf{t' > t : F holds at t'}. Equivalently: there is no gap between t and the set of F-satisfying points above t. On Dedekind complete chains, this is a temporal formula: K+(F) = neg(True Until (neg F)).

**K-(F)** ("next occurrence from below"): K-(F) holds at t iff t = sup{t' < t : F holds at t'}. This is K-(F) = neg(True Since (neg F)).

**INF formula (Equation 5.2)**: Given endpoints z_0, z_1 and a predicate P_1:

    INF(z_0, r_0, z_1, P_1) := z_0 < r_0 < z_1
      AND (forall y in (z_0, r_0)) neg P_1(y)
      AND (P_1(r_0) OR K+(P_1)(r_0))

This defines r_0 as the infimum of {z in (z_0, z_1) : P_1(z)}. The disjunction P_1(r_0) OR K+(P_1)(r_0) handles the two sub-cases: either the infimum itself satisfies P_1, or it is a limit point (Dedekind completeness guarantees existence).

### 1.3 Closure Properties of Exists-Forall Formulas

**Lemma 3.2**:
1. Conjunction of EA-formulas is equivalent to a disjunction of EA-formulas.
2. Every EA-formula is equivalent to a conjunction of EA-formulas with at most two free variables.
3. For every EA-formula phi, the formula exists x phi is an EA-formula.

**Lemma 3.4**: The set of V-EA formulas is closed under disjunction, conjunction, and existential quantification.

**Proposition 3.5**: Every V-EA formula with one free variable is equivalent to a TL(Until, Since) formula. The proof: an EA-formula with one free variable z_k in a sequence x_0 < ... < x_n decomposes into the conjunction of:
- A_k AND (B_{k+1} Until (A_{k+1} AND (B_{k+2} Until ... (A_n AND Box B_{n+1})...)))
- A_k AND (B_{k-1} Since (A_{k-1} AND (B_{k-2} Since ... (A_0 AND overleftarrow-Box B_0)...)))

This is the direct mapping from interval decomposition to nested Until/Since.

### 1.4 Dependency Graph

```
                        Theorem 2.1 (Kamp's Theorem)
                                |
                        Theorem 4.4
                          /          \
                  Prop 4.3            Prop 3.5
                (structural ind)   (EA -> TL conversion)
                  /    |    \
              Atomic  Disj  Negation    Exists
                              |           |
                          Prop 4.2     Lemma 3.4
                     (negation closure)
                              |
                         Lemma 5.1
                    (interval splitting)
                       /         \
                  Lemma 5.3    Corollary 5.4
              (base: beta=True)  (reduction)
```

**What decreases**: The proof of Proposition 4.2 (and hence Lemma 5.1) uses induction on **n** (the number of existentially quantified witness points in the interval formula). The negation of an interval formula with n witnesses is shown equivalent to a disjunction of EA-formulas by case analysis, where each case reduces to negations of interval formulas with FEWER witnesses (< n).

### 1.5 The Induction Structure

The overall proof has TWO nested inductions:

1. **Outer induction (Proposition 4.3)**: Structural induction on FOMLO formula structure. Each case reduces to EA-formula manipulations. The negation case is the hard one, invoking Proposition 4.2.

2. **Inner induction (Lemma 5.1, proving Proposition 4.2)**: Induction on n, the number of witnesses in the interval formula. At each step, a new point z splits the interval, creating sub-interval formulas with fewer witnesses (< n). The inductive hypothesis applies to these sub-formulas.

---

## Part 2: Proposition 4.2 -- The Hard Part

### 2.1 Exact Statement

**Proposition 4.2** (Closure under negation): The negation of exists-forall formulas with at most two free variables is equivalent over Dedekind complete chains to a disjunction of exists-forall formulas.

### 2.2 Why "at most two free variables"?

By Lemma 3.2(2), every EA-formula is equivalent to a conjunction of EA-formulas with at most two free variables. Therefore, its negation is a disjunction of negations of such formulas. Each such negation has at most two free variables, which is exactly what Proposition 4.2 handles.

**Significance for the Lean formalization**: The "two free variables" constraint means the relevant exists-forall formula lives on an interval (z_0, z_1) with endpoints z_0 and z_1. In the Lean encoding, these correspond to the environment variables x and t (the two components of a 2-var NF evaluation).

### 2.3 Proof Method

The proof reduces to Lemma 5.1 via a decomposition of the EA-formula with two free variables into:
- psi_1(z_0): the "past part" from z_0 to z_k (one free variable)
- psi_2(z_1): the "future part" from z_k to z_1 (one free variable)
- phi(z_0, z_1): the "interval part" from z_0 to z_1 (two free variables)

The negation neg psi is equivalent to neg psi_1 OR neg psi_2 OR neg phi. The first two are EA-formulas by Proposition 3.5 (V-EA with one free variable = TL formula = atomic in canonical expansion = EA). The third is handled by Lemma 5.1.

### 2.4 How It Relates to Lemma 5.1

Lemma 5.1 handles the exact formula:

    neg [alpha_0, beta_1, alpha_1, ..., beta_n, alpha_n](z_0, z_1)

This is the negation of the interval formula phi(z_0, z_1) described above. All the complexity of Proposition 4.2 reduces to proving Lemma 5.1.

---

## Part 3: Lemma 5.1 -- The Interval Splitting Core

### 3.1 Exact Statement

**Lemma 5.1**: The negation of any formula of the form

    exists x_0 ... exists x_n [(z_0 = x_0 < ... < x_n = z_1)
      AND alpha_j(x_j) for j=0..n
      AND (forall y)_{>x_{j-1}}^{<x_j} beta_j(y) for j=1..n]       (5.1)

where alpha_j, beta_j are quantifier-free, is equivalent (over Dedekind complete chains) to a disjunction of EA-formulas.

In interval notation: neg [alpha_0, beta_1, ..., beta_n, alpha_n](z_0, z_1) is V-EA.

### 3.2 Proof Organization

The proof is structured in three layers:

1. **Lemma 5.3** (Base case): All beta_i are True. Only point-type constraints alpha_j remain. Uses Dedekind completeness (INF formula) to find the infimum of P_1-satisfying points.

2. **Corollary 5.4** (Intermediate): Handles a restricted form where alpha_0 and alpha_n are present but beta_n is True (the last interval segment is unconstrained). Uses Lemma 5.3 plus a recursive unfolding via F_i formulas.

3. **Lemma 5.1** (Full): Three-case decomposition based on what fails at the left endpoint z_0. Each case reduces to sub-problems with fewer witnesses, handled by the inductive hypothesis.

### 3.3 Case Decomposition (Full Proof of Lemma 5.1)

Assume (z_0, z_1) is non-empty. The negation neg [alpha_0, beta_1, ..., beta_n, alpha_n](z_0, z_1) is the disjunction of three cases:

**Case 1**: neg alpha_0(z_0) OR K+(neg beta_1)(z_0).
- Meaning: Either the endpoint z_0 fails the type constraint alpha_0, OR the first interval type beta_1 fails immediately (z_0 is not separated from a neg beta_1 point).
- This is directly expressible as a V-EA formula (in the canonical expansion, neg alpha_0 and K+(neg beta_1) are atomic).
- In this case, neg [alpha_0, ...](z_0, z_1) is equivalent to True.

**Case 2**: alpha_0(z_0) AND beta_1 holds along all of (z_0, z_1).
- Meaning: The first type constraint succeeds at z_0 and beta_1 holds throughout -- but then there is no z in (z_0, z_1) breaking beta_1, so no witness point x_1 can be placed in the "right" way.
- The negation reduces to: neg [alpha_1, beta_2, ..., beta_n, alpha_n](z, z_1) for all z > z_0, which by Corollary 5.4(2) is equivalent to a V-EA formula.

**Case 3**: alpha_0(z_0) AND neg K+(neg beta_1)(z_0), AND there exists x in (z_0, z_1) with neg beta_1(x).
- Meaning: The type alpha_0 holds at z_0, beta_1 holds "for a while" above z_0 (not immediately violated), but eventually fails at some point x.
- This is the hard case. It uses Dedekind completeness to find:
  r_0 = inf{z in (z_0, z_1) : neg beta_1(z)}
- The INF formula (5.3) defines r_0:

      INF^{neg beta_1}(z_0, z, z_1) := z_0 < z < z_1
        AND (forall y in (z_0, z)) beta_1(y)
        AND (neg beta_1(z) OR K+(neg beta_1)(z))

- Case 3 is described by:
  alpha_0(z_0) AND neg K+(neg beta_1)(z_0) AND (exists z in (z_0, z_1)) INF^{neg beta_1}(z_0, z, z_1)

- The negation reduces to:
  (exists z in (z_0, z_1)) [INF^{neg beta_1}(z) AND neg [alpha_0, beta_1, alpha_1, ..., beta_{n+1}, alpha_{n+1}](z_0, z_1)]

### 3.4 The Induction on n (Full Detail)

**The key reduction in Case 3**: After finding z = r_0 (the INF point), the negation

    neg [alpha_0, beta_1, alpha_1, ..., beta_{n+1}, alpha_{n+1}](z_0, z_1)

is shown equivalent (given the INF condition) to:

    (exists z)_{>z_0}^{<z_1} (INF^{neg beta_1}(z) AND phi(z) AND conjunction of neg A_i AND conjunction of neg B_i)

where A_i, B_i are the sub-interval formulas defined as:

**A_i definitions** (i = 1, ..., n):

    A_i^-(z_0, z) := [alpha_0, beta_1, ..., beta_i, alpha_i](z_0, z)        (left sub-interval)
    A_i^+(z, z_1) := [alpha_i, beta_{i+1}, ..., beta_{n+1}, alpha_{n+1}](z, z_1)  (right sub-interval)
    A_i(z_0, z, z_1) := A_i^-(z_0, z) AND A_i^+(z, z_1)

**B_i definitions** (i = 1, ..., n+1):

    B_i^-(z_0, z) := [alpha_0, beta_1, ..., beta_{i-1}, alpha_{i-1}, beta_i](z_0, z)   (left, ending with beta_i)
    B_i^+(z, z_1) := [beta_i, alpha_i, beta_{i+1}, ..., beta_{n+1}, alpha_{n+1}](z, z_1)  (right, starting with beta_i)
    B_i(z_0, z, z_1) := B_i^-(z_0, z) AND B_i^+(z, z_1)

**The equivalence** (when (z_0, z_1) is non-empty):

    [alpha_0, beta_1, ..., beta_{n+1}, alpha_{n+1}](z_0, z_1)
      <=> (forall z)_{>z_0}^{<z_1} (disjunction over i of A_i) OR (disjunction over i of B_i)

    [alpha_0, beta_1, ..., beta_{n+1}, alpha_{n+1}](z_0, z_1)
      <=> (exists z)_{>z_0}^{<z_1} (disjunction over i of A_i) OR (disjunction over i of B_i)

Therefore:

    (exists z)_{>z_0}^{<z_1} phi(z)
      AND neg [alpha_0, beta_1, ..., beta_{n+1}, alpha_{n+1}](z_0, z_1)
    is equivalent to:
    (exists z)_{>z_0}^{<z_1} (phi(z) AND conjunction of neg A_i AND conjunction of neg B_i)

**Why this reduces the induction parameter**: Each A_i and B_i involves FEWER witness points than the original formula:
- A_i^- has i witness points, A_i^+ has n-i witness points (both < n for 0 < i < n)
- B_i^- has i-1 witness points, B_i^+ has n-i+1 witness points (both fewer than n+1)

So neg A_i = neg A_i^- OR neg A_i^+ is a disjunction of negations of formulas with FEWER witnesses. By the inductive hypothesis, each is V-EA. Similarly for neg B_i.

**Formal induction claims** (from the paper, page 11):

By the inductive hypothesis:
- **(a)**: neg A_i is equivalent to a V-EA formula for i = 1, ..., n.
- **(b)**: neg B_i is equivalent to a V-EA formula for i = 2, ..., n.

Additionally:
- **(c)**: neg B_1^- and neg B_{n+1}^+ are equivalent to V-EA formulas (by the induction basis, since they have 0 witnesses).
- **(d)**: INF^{neg beta_1}(z) AND neg B_1^+(z, z_1) is equivalent to INF^{neg beta_1}(z), because if INF^{neg beta_1}(z) holds then beta_1 holds on (z_0, z) and for no x > z, beta_1 holds along [z, x). So B_1^+ (which requires beta_1 on some interval starting at z) fails. Wait -- this is more subtle.

Actually, (d) says: INF^{neg beta_1}(z) AND neg B_1^+(z, z_1) is equivalent to INF^{neg beta_1}(z), because B_1^+(z, z_1) = beta_1 holds on (z, z_1) and [alpha_1, ...](some subinterval), but if neg beta_1 holds at (or just after) z, then B_1^+ fails automatically. Actually the paper says more precisely:

**(d)**: INF^{neg beta_1}(z) AND neg B_1^+(z, z_1) is equivalent to INF^{neg beta_1}(z), because if INF^{neg beta_1}(z) holds, then for no x > z does beta_1 hold along [z, x), so B_1^+(z, z_1) is false. Therefore neg B_1^+(z, z_1) is true. (This uses the definition of INF: neg beta_1(z) OR K+(neg beta_1)(z) means beta_1 fails at or immediately after z.)

**(e)**: INF^{neg beta_1}(z) AND neg B_{n+1}^-(z_0, z) is equivalent to INF^{neg beta_1}(z) AND neg B_{n+1}^-(z_0, z). The paper observes: "beta_1 holds on (z_0, z)" (from INF) AND "neg B_{n+1}^-(z_0, z)" reduces by case 2 analysis: beta_1 holds on (z_0, z) means the condition for case 2 applies to the sub-formula, making neg B_{n+1}^-(z_0, z) equivalent to a V-EA formula.

Since V-EA formulas are closed under conjunction, disjunction, and existential quantification (Lemma 3.4), the entire expression is V-EA.

### 3.5 Summary of What Decreases

The induction is on **n** (the number of INTERIOR witness points in the interval formula). When we negate [alpha_0, beta_1, ..., beta_{n+1}, alpha_{n+1}](z_0, z_1) (which has n+1 interior witnesses x_1, ..., x_{n+1} between z_0 and z_1 -- but actually n witnesses since z_0 = x_0 and z_1 = x_n), the case analysis produces sub-formulas A_i^+/-, B_i^+/- each with STRICTLY FEWER interior witnesses. The base case (n=0) is immediate: neg [alpha_0](z_0, z_1) with z_0 = z_1 is neg alpha_0(z_0), which is atomic.

---

## Part 4: Lemma 5.3 -- The Base Case

### 4.1 Exact Statement

**Lemma 5.3**: neg exists x_1 ... exists x_n (z_0 < x_1 < ... < x_n < z_1) AND P_i(x_i) for i=1..n is equivalent to a V-EA formula O_n(P_1, ..., P_n, z_0, z_1) over Dedekind complete chains.

This is the special case of Lemma 5.1 where all beta_i = True and all alpha_i (except at x_1, ..., x_n) are True.

### 4.2 Proof by Induction on n

**Base** (n=1): neg (exists x_1)_{>z_0}^{<z_1} P_1(x_1) is equivalent to (forall y)_{>z_0}^{<z_1} neg P_1(y). This is an EA-formula (universally quantified atomic formula on the open interval).

**Inductive step** (n -> n+1): Assume O_n is defined and is V-EA. We construct O_{n+1}.

**Case 1**: P_1 does not occur in (z_0, z_1). Then O_{n+1}(P_1, ..., P_{n+1}, z_0, z_1) should be equivalent to True (the negation of the existential is true because x_1 cannot exist). Formally: (forall y)_{>z_0}^{<z_1} neg P_1(y). This is a V-EA formula.

**Case 2**: If Case 1 does not hold, let r_0 = inf{z in (z_0, z_1) : P_1(z)}. By Dedekind completeness, r_0 exists.

**Key use of Dedekind completeness**: r_0 is guaranteed to exist precisely because the set {z in (z_0, z_1) : P_1(z)} is non-empty (Case 1 failed) and has a lower bound (z_0). On non-Dedekind-complete chains (like Q), r_0 might not exist, and the proof fails.

r_0 is definable by the V-EA formula:

    INF(z_0, r_0, z_1, P_1) := z_0 < r_0 < z_1
      AND (forall y)_{>z_0}^{<r_0} neg P_1(y)
      AND (P_1(r_0) OR K+(P_1)(r_0))

**Sub-case r_0 = z_0**: Not possible since z_0 < r_0 < z_1 by definition.

Actually, two sub-cases:
- **r_0 satisfies P_1**: Then r_0 plays the role of x_1 = the first witness. The remaining witnesses x_2, ..., x_{n+1} must exist in (r_0, z_1) with P_i(x_i) for i=2..n+1. Negating this gives O_n(P_2, ..., P_{n+1}, r_0, z_1), which is V-EA by the inductive hypothesis.
- **r_0 does not satisfy P_1**: Then K+(P_1)(r_0) holds, meaning P_1 is satisfied arbitrarily close to (but above) r_0. In this case r_0 itself cannot be x_1, but ANY point just above r_0 satisfying P_1 would work. The negation reduces to O_n on the interval (r_0, z_1).

**O_{n+1} formula**: The disjunction of:
1. (forall y)_{>z_0}^{<z_1} neg P_1(y)    -- "(z_0, z_1) is empty of P_1"
2. K+(P_1)(z_0) AND O_n(P_2, ..., P_n, z_0, z_1)    -- "P_1 starts at z_0, recurse"
3. (exists r_0)_{>z_0}^{<z_1} (INF(z_0, r_0, z_1, P_1) AND O_n(P_2, ..., P_n, r_0, z_1))

Each disjunct is V-EA (by inductive hypothesis + Lemma 3.4 closure), so O_{n+1} is V-EA.

### 4.3 Role of K+(P) in the INF Formula

K+(P_1)(r_0) asserts: r_0 = inf{t' > r_0 : P_1(t')}. In words: the infimum of the P_1-satisfying set is a limit point of the set from above, not an actual member. This handles the case where the infimum exists but is not itself a P_1-point (possible in dense linear orders).

In the Lean formalization, `semantic_prior_UZ` is the analog of this: given existence of a temporal-formula-satisfying point above t, UZ gives the FIRST occurrence (infimum behavior). The formula `char_fn d nf_1` plays the role of P_1.

---

## Part 5: Corollary 5.4

### 5.1 Exact Statement

**Corollary 5.4**:
1. neg (exists z)_{>z_0}^{<z_1} [alpha_0, beta_1, ..., beta_n, alpha_n](z_0, z) is V-EA over Dedekind complete chains.
2. neg (exists z)_{>z_0}^{<z_1} [alpha_0, beta_1, ..., beta_n, alpha_n](z, z_1) is V-EA over Dedekind complete chains.

### 5.2 Proof

Define:

    F_n := alpha_n
    F_{i-1} := alpha_{i-1} AND (beta_i Until F_i)    for i = 1, ..., n

Observe: [alpha_0, beta_1, ..., alpha_n](z_0, z) holds iff F_0(z_0) holds and there is an increasing sequence x_1 < ... < x_n in (z_0, z_1) such that F_i(x_i) for all i. The direction F_0(z_0) => existence of witnesses is proved by induction on n: the Until modality in F_{i-1} produces the witness x_i.

The reduction then states:

    neg (exists z)_{>z_0}^{<z_1} [alpha_0, ..., alpha_n](z_0, z)

is equivalent to:

    neg F_0(z_0) OR O_n(F_1, ..., F_n, z_0, z_1)

where O_n is from Lemma 5.3. Since each F_i is a temporal formula (expressible via nested Until/Since), neg F_0 is a V-EA formula, and O_n is a V-EA formula by Lemma 5.3, the entire expression is V-EA.

### 5.3 Significance

Corollary 5.4 provides the reduction tool for Case 2 of Lemma 5.1's proof. When beta_1 holds everywhere along (z_0, z_1) (Case 2), the negation reduces to Corollary 5.4's form.

---

## Part 6: Mapping to the Lean Formalization

### 6.1 Concept Mapping Table

| Rabinovich Concept | Lean Equivalent | File | Notes |
|---|---|---|---|
| Sigma-chain M = (T, <, I) | `OrderedMonadicStructure sig` | MonadicFO.lean | sig : MonadicSignature provides the predicates |
| Unary predicate P(x) | `M.interp p t` | MonadicFO.lean | p : sig.preds, t : M.carrier |
| Quantifier-free formula alpha_j | `AtomKind sig n -> Bool` | NormalForm.lean:58 | Depth-0 normal form: truth assignment to atoms |
| Exists-forall formula | No direct encoding | -- | The Lean formalization does NOT use Rabinovich's EA normal form |
| V-exists-forall | No direct encoding | -- | V-EA closure is NOT formalized |
| Interval type [alpha_0, ..., alpha_n](z_0, z_1) | No direct encoding | -- | The Lean proof bypasses interval decomposition |
| Number n (witnesses in interval) | NOT the induction parameter | -- | Lean uses DEPTH (k) as induction parameter, not witness count |
| Depth k (quantifier depth) | `k : Nat` in `NormalForm sig k n` | NormalForm.lean:134 | The primary induction parameter in the Lean proof |
| n-variable NF type | `NormalForm sig k n` | NormalForm.lean:134 | k = depth, n = arity (number of free variables) |
| nf_eval_nf | `nf_eval_nf M k n env nf` | NormalForm.lean:198 | Depth-0: atom truth. Depth-(k+1): atoms + existential conditions |
| nf_characteristic | `nf_characteristic M k n env` | NormalForm.lean:215 | The unique NF satisfied by M,env at depth k |
| z_0, z_1 (endpoints) | `t, x` (env variables) | PriorComposition.lean | t = second component, x = first component of 2-var env |
| "Negation closure" | Zone-3 existential transfer | PriorComposition.lean:197-220 | The analog of Prop 4.2: transferring existentials across structures |
| Prior-UZ/SZ | `semantic_prior_UZ`/`semantic_prior_SZ` | PriorDefs.lean:22,33 | First/last occurrence axioms on Prior structures |
| K+(P) | `semantic_prior_UZ` consequence | PriorDefs.lean | UZ gives the first occurrence; K+(P) = the infimum operator |
| INF formula | Implicit in Prior-UZ/SZ | -- | semantic_prior_UZ directly provides the infimum witness |
| char_fn d nf_1 | `char_fn d nf_1` parameter | PriorComposition.lean:259 | Temporal formula characterizing depth-d 1-var NF type nf_1 |
| Depth induction (Lean outer) | `Nat.strong_induction_on K` | PriorComposition.lean:271 | Strong induction on K for 2-var non-constant env agreement |

### 6.2 Where the Mapping Is Exact

1. **Structures**: OrderedMonadicStructure exactly corresponds to Sigma-chains. The signature (predicates) is matched. Linear order is the underlying order.

2. **Normal forms**: `NormalForm sig k n` exactly captures the depth-k n-variable "type" of a point/tuple. At depth 0 it is an atom truth assignment; at depth k+1 it adds existential conditions. This is Doets' n-characteristic, which is a different formalization than Rabinovich's EA-formulas but captures the SAME information.

3. **Prior-UZ/SZ**: These correspond precisely to the role of K+/K- and Dedekind completeness in Rabinovich. Both provide "first/last occurrence" guarantees. The Prior axioms are STRONGER than Dedekind completeness alone -- they apply to ALL temporal formulas, not just atomic predicates.

4. **Characteristic formulas (char_fn)**: These correspond to Rabinovich's use of TL-definable predicates. Each NF type is characterized by a temporal formula, enabling the Prior-UZ/SZ machinery to work with NF types just as Rabinovich works with P_i predicates.

### 6.3 Where the Mapping Breaks Down

**CRITICAL STRUCTURAL DIFFERENCE**: Rabinovich's proof uses induction on **n** (witness count), while the Lean formalization uses induction on **k** (quantifier depth). These are fundamentally different induction principles.

1. **Rabinovich's induction on n**: When negating [alpha_0, ..., alpha_n](z_0, z_1), a new point z splits the interval. The sub-formulas A_i^+/- have FEWER witnesses (< n). The depth of the formulas is constant throughout.

2. **Lean's induction on k**: At depth k+2, the 2-var NF has quantifier conditions about depth-(k+1) 3-var existentials. Each such existential involves a depth-(k+1) NF, whose own quantifier conditions are at depth k. This is a DEPTH descent, not a witness-count descent.

**Why this matters for zone-3**: In Rabinovich, when we split the interval at a point z, we get sub-intervals with the SAME DEPTH but fewer witnesses. In the Lean formalization, when we introduce a witness w between t and x, we get a 3-var environment [w, x, t] whose quantifier conditions involve 4-var existentials at one LOWER depth. The witness count (arity) goes UP while the depth goes DOWN.

3. **The termination argument differs**: Rabinovich terminates because n (witnesses) decreases. Lean terminates because k (depth) decreases to 0 where everything is purely atomic.

4. **Structural commitment in Lean**: The `NormalForm sig k n` encoding commits to depth-first decomposition. A depth-(k+1) n-var NF specifies: atoms on n variables, PLUS for each depth-k (n+1)-var NF, whether an (n+1)-th variable exists satisfying it. This creates a tree structure where depth decreases by 1 for each existential quantifier, while arity increases by 1.

### 6.4 Why This Structural Difference Is Not Fatal

Despite the different induction principles, the underlying mathematical content is compatible. The key observation:

**Rabinovich's proof works at the FORMULA level** (exists-forall formulas), while the **Lean formalization works at the SEMANTIC level** (normal form agreement). These are two representations of the same mathematical fact.

At the semantic level, "transferring a depth-(k+1) 3-var existential" is equivalent to "showing that the interval decomposition patterns match." The Prior-UZ/SZ axioms provide exactly the density/completeness properties needed to find matching witnesses.

The Lean formalization does NOT need to replicate Rabinovich's proof structure. Instead, it needs to use the SAME MATHEMATICAL INGREDIENTS:
- Prior-UZ/SZ for witness placement (analog of INF formula + Dedekind completeness)
- Characteristic formulas for type identification (analog of alpha_j, beta_j predicates)
- Zone decomposition for case analysis (analog of the three cases in Lemma 5.1)
- Recursive depth descent for quantifier transfer (analog of the induction on n, but using depth instead)

---

## Part 7: The Key Insight for Zone-3

### 7.1 What Does Rabinovich's Proof ACTUALLY Do at the Zone-3 Step?

In Rabinovich's proof of Lemma 5.1, Case 3 (the zone-3 analog), the key steps are:

1. **Find the splitting point r_0**: Use Dedekind completeness (INF formula) to locate the first point where beta_1 fails in the interval (z_0, z_1).

2. **Decompose the negation at r_0**: Once r_0 is found, the negation of [alpha_0, ...](z_0, z_1) is equivalent to a conjunction of negations of SUB-interval formulas A_i, B_i, each with fewer witnesses.

3. **Apply the inductive hypothesis**: Each neg A_i, neg B_i is V-EA by the IH (fewer witnesses).

In the Lean formalization's zone-3, the analogous steps are:

1. **Find the witness w' in N**: Given w in (t, x) in structure M, use Prior-UZ to find the FIRST occurrence w' > t' of a point matching w's depth-(K+1) 1-var NF type. Prior-SZ on h_x bounds w' < x'.

2. **Prove w' satisfies the same 3-var NF as w**: This requires atoms (from 1-var matching + order placement) AND quantifier conditions (from depth descent).

3. **Transfer the quantifier conditions**: For each depth-K 4-var sub-NF, transfer the existential between [v, w, x, t] and [v', w', x', t']. This is done by recursive depth descent: at depth K-1 by the strong IH, at depth 0 by atomic transfer.

### 7.2 Should We Use Witness-Count Induction Instead of Depth Induction?

**No.** The Lean formalization's depth induction is correctly aligned with its encoding. The NormalForm type is defined by recursion on depth, not on witness count. Changing the induction principle would require restructuring the entire NormalForm infrastructure.

However, understanding Rabinovich's witness-count induction illuminates WHY depth induction works: at each depth level, the quantifier conditions involve one MORE variable but one LESS depth. The termination is by the lexicographic order (depth, ...) where depth strictly decreases. The arity increase is bounded by the fact that depth-0 NFs are purely atomic (no quantifier conditions to transfer).

### 7.3 The CORRECT Induction Principle for Closing the Sorry

The sorry in `PriorComposition.lean` requires:

```
Goal: (exists w, nf_eval M (K+1) 3 [w,x,t] sub_nf)
      <-> (exists w', nf_eval N (K+1) 3 [w',x',t'] sub_nf)
```

The correct approach uses `Nat.strong_induction_on K` (already in place), with the following structure for zone-3:

**Step 1 -- Witness placement via Prior-UZ/SZ**:
- Get w's depth-(K+1) 1-var type via nf_characteristic
- Use `cross_extend_bwd_1var` from h_t to transfer "existence above t'" to N
- Use `cross_extend_bwd_1var` from h_x to transfer "existence below x'" to N
- Apply `semantic_prior_UZ` at N, t' with char_fn (K+1) nf_w to get first occurrence w' > t'
- Bound w' < x' using the below-x' witness, concluding t' < w' < x' (zone 3 placement)

**Step 2 -- Atom part of w's 3-var NF**:
- Predicates at w': from depth-(K+1) 1-var agreement w/w' (via char_fn + Prior-UZ) and M's satisfaction of sub_nf
- Predicates at x': from h_x (depth-(K+2) 1-var agreement)
- Predicates at t': from h_t
- Orders w'/x'/t': from zone placement (t' < w' < x')

**Step 3 -- Quantifier part of w's 3-var NF**:
For each sub4 : NormalForm sig K 4, prove:
```
(exists v, nf_eval M K 4 [v,w,x,t] sub4) <-> (exists v', nf_eval N K 4 [v',w',x',t'] sub4)
```

This is a depth-K 4-var existential transfer. It follows from having depth-(K+1) 3-var FULL agreement at [w,x,t]/[w',x',t']. To establish this 3-var agreement without circularity:

**Key maneuver**: From `ih_strong` at m = K-1 (when K >= 1):
- `ih_strong` gives depth-(K+1) 2-var agreement at [x,t]/[x',t'] (since m+2 = K+1 and K-1 < K)

Wait -- actually this is wrong. ih_strong gives: for all m < K, the theorem holds at m. The theorem at m gives depth-(m+2) 2-var agreement. So at m = K-1, it gives depth-(K+1) 2-var agreement. But the OUTER theorem is proving depth-(K+2) 2-var agreement. So ih_strong at K-1 gives one-lower depth 2-var, which is EXACTLY what we need.

From depth-(K+1) 2-var agreement at [x,t]/[x',t']:
- Its quantifier condition gives: for each NF_K_3 : NormalForm sig K 3, (exists y in M, nf_eval M K 3 [y,x,t] NF_K_3) <-> (exists y' in N, nf_eval N K 3 [y',x',t'] NF_K_3)
- Take NF_K_3 = nf_characteristic M K 3 [w,x,t]. The M-side is witnessed by w.
- So there exists w_nf in N with nf_eval N K 3 [w_nf, x', t'] (nf_char M K 3 [w,x,t])
- By nf_agreement_from_shared_nf: FULL depth-K 3-var agreement at [w,x,t]/[w_nf,x',t']

This gives depth-K 3-var agreement, whose quantifier condition gives: for each sub4 : NF (K-1) 4, the existential transfers between [v,w,x,t] and [v',w_nf,x',t']. But we need the transfer for [v',w',x',t'], not [v',w_nf,x',t'].

**The bridge**: w' (from Prior-UZ) and w_nf (from nf_extend) both have the same depth-K 1-var NF type as w (both match w at depth K+1 or K respectively, and depth-(K+1) agreement implies depth-K agreement by monotonicity). But having the same 1-var type does NOT give the same 3-var type for the pair (w?, x', t').

**Resolution**: Use `nf_extend_bwd` from the depth-(K+1) 2-var agreement at [x,t]/[x',t'] to find, for EACH w in M, a w_nf in N with depth-K 3-var full agreement. Then prove nf_eval N (K+1) 3 [w_nf, x', t'] sub_nf by:
- atoms: from depth-K 3-var agreement (atom part transfers since depth-0 agreement is embedded in depth-K agreement, and atoms are depth-0 data)

Wait, but we need depth-(K+1) 3-var, not depth-K 3-var. The atom part of the depth-(K+1) 3-var NF is the same as any depth-K 3-var NF (atoms are independent of depth). So the atom part follows from the depth-K 3-var agreement. The quantifier part asks about depth-K 4-var existentials, which follow from the depth-K 3-var agreement's own quantifier conditions (depth-(K-1) 4-var).

**But the depth-K 4-var existentials are NOT the same as depth-(K-1) 4-var existentials.** This is the depth gap.

### 7.4 The Real Resolution (Combining Prior-UZ and nf_extend)

The correct resolution requires recognizing that we have TWO sources of information:

1. **w_nf** (from nf_extend_bwd via ih_strong): has depth-K 3-var full agreement with w at [w,x,t]/[w_nf,x',t']. This gives depth-(K-1) 4-var existential transfer but NOT depth-K 4-var.

2. **w'** (from Prior-UZ): has depth-(K+1) 1-var agreement with w. In the correct zone (t' < w' < x'). But only 1-var information, not 3-var.

The key insight is that **w_nf might not be in zone 3** (it might be outside (t', x')), while **w' IS in zone 3 but lacks 3-var information**. Neither alone suffices.

**The resolution uses a DIFFERENT approach**: Instead of trying to merge w_nf and w', use the `generalExistPart_from_classical` pattern. This pattern observes:

For any sub_nf, the formula characterizing "exists w, nf_eval M (K+1) 3 [w,x,t] sub_nf" is either universally true (on all Prior structures realizing the same 2-var NF at [x,t]) or universally false. This is because the characteristic formula from `existPart_succ_n1_bypass` gives a TEMPORAL FORMULA equivalent to the existential.

Therefore: if M satisfies the existential, and N satisfies the same depth-(K+2) 2-var NF at [x,t]/[x',t'] (which is EXACTLY what the outer theorem is proving), then N also satisfies the existential.

**But wait -- the outer theorem IS what we're proving.** So we can't use its conclusion to prove its quantifier conditions. This IS circular.

### 7.5 Breaking the Circularity -- The Actual Mechanism

The circularity is broken by the `generalExistPart_from_classical` approach combined with the ALREADY PROVED `existPart_succ_n1_bypass` theorem:

Look at `existPart_succ_n1_bypass` in KampBypass.lean (lines 421-888). This theorem proves that for depth k+1, arity 2, the existential `exists x, nf_eval M (k+1) 2 [x, t] sub_nf` is characterizable by a temporal formula A, where:
- A is constructed using char_kp1 (characteristic formulas for depth-(k+1) 1-var types)
- A's correctness depends on `prior_2var_transfer_until/since` from PriorComposition.lean

And `prior_2var_transfer_until/since` in PriorComposition.lean contains the sorry.

So the dependency is: existPart_succ_n1_bypass DEPENDS on prior_nonconstenv_2var_agree_until/since (which contain the sorry). The sorry IS inside the proof of these transfer theorems.

**The actual structure**: The sorry position is:
```
prior_nonconstenv_2var_agree_until:
  for all K, for all nf : NF (K+2) 2,
    nf_eval M (K+2) 2 [x, t] nf <-> nf_eval N (K+2) 2 [x', t'] nf
```

The proof uses Nat.strong_induction_on K. At K=0:
- Goal: depth-2 2-var agreement
- Quantifier condition: depth-1 3-var existentials
- These are handled by the K=0 case of existPart_succ_n1_bypass (which is sorry-free via existPart_succ_n1_bypass_k0)

At K > 0:
- Goal: depth-(K+2) 2-var agreement
- Quantifier condition: depth-(K+1) 3-var existentials
- ih_strong gives: for all m < K, the theorem at m. So at m = K-1: depth-(K+1) 2-var agreement at [x,t]/[x',t']
- The depth-(K+1) 3-var existential should be handled by existPart_succ_n1_bypass at depth k' = K (since k'+1 = K+1), but that theorem REQUIRES prior_2var_transfer, which IS the theorem being proved (at the same K).

**THE ACTUAL FIX**: The sorry should be closed by showing that the depth-(K+1) 3-var existential transfer can be proved using ONLY:
1. ih_strong at m < K (gives depth < K+2 2-var agreement)
2. The Prior-UZ/SZ axioms
3. The characteristic formulas char_fn at d <= K+1
4. The generic nf_extend_bwd/fwd machinery

WITHOUT requiring the full prior_nonconstenv_2var_agree at the same K.

Here is how: the depth-(K+1) 3-var existential asks about a point w in [w,x,t]. By zone decomposition:

- **Zones 1,5** (w < t or w > x): The existential `exists w, nf_eval M (K+1) 3 [w,x,t] sub_nf with w < t` means w is on the "constant-env side" of t. Using `cross_extend_bwd_1var` from h_t gives w' with depth-(K+1) 2-var agreement at [w,t]/[w',t']. But we need 3-var at [w',x',t'], not 2-var at [w',t']. From ih_strong at m=K-1: depth-(K+1) 2-var at [x,t]/[x',t']. Combined with the depth-(K+1) 2-var at [w,t]/[w',t'] and the depth-(K+1) 2-var at [x,t]/[x',t'], we can reconstruct the 3-var NF at [w',x',t'] by showing atoms match (from 1-var projections) and quantifiers match (from the depth-K 3-var agreement obtained via nf_extend on ih_strong).

- **Zones 2,4** (w = t or w = x): Use t' or x' directly.

- **Zone 3** (t < w < x): The hard case. Use Prior-UZ/SZ to find w' with the right 1-var type and the right zone placement. Then use `nf_extend_bwd` from ih_strong at m=K-1 to get depth-K 3-var agreement between [w,x,t] and some w_nf. Use the depth-K 3-var agreement to transfer the QUANTIFIER conditions at depth K-1. The ATOM conditions transfer via 1-var agreement at w/w'.

For the depth-K 4-var quantifier conditions in the zone-3 case: from depth-K 3-var full agreement at [w,x,t]/[w_nf,x',t'], its quantifier condition gives depth-(K-1) 4-var existential transfer for [v,w,x,t]/[v',w_nf,x',t']. But we need depth-K 4-var, not depth-(K-1).

**THE FUNDAMENTAL ISSUE**: We need depth-(K+1) 3-var NF agreement, but can only get depth-K 3-var from the infrastructure. The GAP of 1 depth level cannot be bridged purely algebraically.

### 7.6 What Would Need to Change

There are two possible resolutions:

**Resolution A: Restructure the induction to carry a stronger IH.**

Instead of proving "depth-(K+2) 2-var agreement at [x,t]/[x',t']" by strong induction on K, prove the following stronger statement simultaneously:

For all K, for all n >= 1: "depth-(K+1) (n+1)-var existential transfer at [w, x, t]/[w', x', t'] from depth-(K+2) 1-var agreement at x/x' and t/t', given Prior-UZ/SZ and char_fn up to depth K+1."

This gives the 3-var existential transfer as a SPECIAL CASE (n=2) of the general statement. The general statement is proved by a DOUBLE induction: outer on K (depth), inner on n (arity) -- which is closer to Rabinovich's structure.

But the Lean formalization already has this structure in `kamp_mutual_induction` (KampMutualInduction.lean). The `ExistPart(k)` definition IS the general existential transfer for all n >= 1. And `existPart_succ` already handles the n >= 2 case via `constenv_2var_determines`.

The problem is that `existPart_succ` at n=1 delegates to `existPart_succ_n1_bypass`, which in turn calls `prior_2var_transfer_until/since`, which wraps `prior_nonconstenv_2var_agree_until/since` -- the theorem with the sorry.

**Resolution B: Close the sorry directly using the available infrastructure.**

The sorry asks: given depth-(K+1) 2-var agreement from ih_strong at K-1, and depth-(K+2) 1-var agreement at x/x' and t/t', prove depth-(K+1) 3-var existential transfer.

What we need to show is that for a specific sub_nf, either:
- sub_nf is satisfiable, and we can find a witness w' in N matching w from M
- sub_nf is unsatisfiable, and neither structure has a witness

For the zone-3 case specifically: given w in M with t < w < x satisfying sub_nf, we need w' in N with t' < w' < x' satisfying sub_nf.

The key observation that resolves this: **the quantifier part of the depth-(K+1) 3-var NF at [w',x',t'] reduces, via nf_extend_bwd from ih_strong, to depth-K 4-var existentials. These depth-K 4-var existentials can themselves be transferred zone-by-zone using the SAME recursive scheme. The recursion terminates at depth 0 where everything is purely atomic.**

This is essentially a proof by strong induction on K where the quantifier transfer at depth K+1 delegates to the transfer at depth K (via nf_extend and zone decomposition), which delegates to depth K-1, and so on down to depth 0.

**Implementation sketch**:

```lean
-- Inside strong induction body at K:
-- After finding w' via Prior-UZ with t' < w' < x' and matching depth-(K+1) 1-var type:
-- Prove nf_eval N (K+1) 3 [w',x',t'] sub_nf:

-- Atom part: from 1-var agreement + orders (straightforward)

-- Quantifier part: for each sub4 : NF K 4:
-- Need: (exists v, nf_eval M K 4 [v,w,x,t] sub4) <-> (exists v', nf_eval N K 4 [v',w',x',t'] sub4)

-- From ih_strong at m=K-1: depth-(K+1) 2-var at [x,t]/[x',t']
-- From this: exists w_nf with depth-K 3-var full agreement at [w,x,t]/[w_nf,x',t']
-- The quantifier condition of depth-K 3-var agreement gives:
--   (exists v, nf_eval M (K-1) 4 [v,w,x,t] chi4) <-> (exists v', nf_eval N (K-1) 4 [v',w_nf,x',t'] chi4)

-- But we need depth-K 4-var, not depth-(K-1) 4-var. The depth gap remains.

-- HOWEVER: nf_eval N K 4 [v',w',x',t'] sub4 decomposes into:
--   atoms at [v',w',x',t'] matching sub4.1 (from 1-var agreements + orders)
--   AND for each sub5 : NF (K-1) 5:
--     (exists u', nf_eval N (K-1) 5 [u',v',w',x',t'] sub5) <-> sub4.2 sub5

-- The depth-(K-1) 5-var existentials follow from depth-K 4-var full agreement
-- at [v',w',x',t'] (which we're constructing)... STILL CIRCULAR AT THIS LEVEL.
```

The circularity is only broken if we can show that the ENTIRE n-var NF at depth K+1 for [w',x',t'] matches sub_nf using information available at depth <= K.

### 7.7 Recommended Approach

The most promising approach, combining Rabinovich's mathematical insight with the Lean encoding:

**Prove a helper lemma** (the "zone-3 NF reconstruction lemma"):

```
Given:
- depth-(K+2) 1-var agreement at x/x', t/t', w/w'
- Prior-UZ/SZ on M and N
- ih_strong: for all m < K, depth-(m+2) 2-var agreement at [x,t]/[x',t']
- orders: t < w < x, t' < w' < x'

Prove: for all nf3 : NF (K+1) 3,
  nf_eval M (K+1) 3 [w,x,t] nf3 <-> nf_eval N (K+1) 3 [w',x',t'] nf3
```

This is proved by strong induction on K (inside the existing strong induction, reusing ih_strong):

- **K=0**: depth-1 3-var NF = atoms + depth-0 4-var existentials. Atoms from 1-var agreement. Depth-0 4-var is purely atomic: the existential asks for a point with specific predicates and orders. Transfer by zone decomposition on v and direct Prior-UZ/SZ density arguments.

- **K > 0**: depth-(K+1) 3-var NF = atoms + depth-K 4-var existentials. Atoms as above. For the depth-K 4-var existentials: need to show `(exists v, nf_eval M K 4 [v,w,x,t] sub4) <-> (exists v', nf_eval N K 4 [v',w',x',t'] sub4)`. This requires depth-(K+1) 3-var agreement at [w,x,t]/[w',x',t'], which is what we're proving... UNLESS we use nf_extend.

From ih_strong at m=K-1: depth-(K+1) 2-var at [x,t]/[x',t']. This gives (via quantifier condition): for each chi3 : NF K 3, the existential `(exists y, nf_eval M K 3 [y,x,t] chi3) <-> (exists y', nf_eval N K 3 [y',x',t'] chi3)`. For chi3 = nf_char M K 3 [w,x,t], we get w_nf with depth-K 3-var full agreement at [w,x,t]/[w_nf,x',t'].

Now apply this lemma recursively at K-1 (using the strong IH): since w/w_nf have the same depth-K 3-var NF type at [w,x,t]/[w_nf,x',t'], and w/w' have the same depth-(K+1) 1-var type, what about w'/w_nf?

From depth-K 3-var at [w,x,t]/[w_nf,x',t'], project to 1-var: w_nf has same depth-K 1-var type as w. From depth-(K+1) 1-var at w/w': by monotonicity, w' has same depth-K 1-var type as w. So w' and w_nf have the same depth-K 1-var type.

But depth-K 1-var matching does NOT imply depth-K 3-var matching at the env (..., x', t').

**The final insight (from Rabinovich applied to the Lean setting)**: The transfer of the depth-K 4-var existentials does not require FULL depth-(K+1) 3-var agreement at [w,x,t]/[w',x',t']. It only requires the EXISTENTIAL to transfer. Using nf_extend_bwd from the depth-K 3-var agreement at [w,x,t]/[w_nf,x',t']:

For each sub4, `(exists v, nf_eval M K 4 [v,w,x,t] sub4)` is equivalent to `sub_nf_3.2 sub4 = true` (where sub_nf_3 is the depth-K 3-var NF of [w,x,t] in M). Similarly, `(exists v', nf_eval N K 4 [v',w_nf,x',t'] sub4)` is equivalent to `sub_nf_3.2 sub4 = true` (by the depth-K 3-var agreement). So the existentials transfer between [v,...] and [v',w_nf,...].

But we need the transfer for w', not w_nf! The question reduces to: does `(exists v', nf_eval N K 4 [v',w',x',t'] sub4) = (exists v', nf_eval N K 4 [v',w_nf,x',t'] sub4)`?

If w' and w_nf have the same depth-K 3-var NF at (...,x',t'), then yes. But we don't know that.

**HOWEVER**: We DO know that w' and w_nf have the same depth-K 1-var type. For the depth-K 4-var existential at [v',w',x',t'], the only thing that matters about w' (as opposed to w_nf) is:
- The predicates at w' (same as w_nf, from depth-K 1-var agreement)
- The order of w' relative to x', t' (same as w_nf? NOT necessarily)
- The quantifier conditions involving w' (depth-(K-1) 5-var existentials -- but these are at one lower depth)

The orders ARE the same: both w' and w_nf are in (t', x') if we can verify this. w' is in (t', x') by Prior-UZ construction. w_nf is... well, nf_extend_bwd does NOT guarantee any particular zone for w_nf.

**This is the crux of the problem**: w_nf from nf_extend_bwd has the right NF type but might be in the wrong zone. w' from Prior-UZ is in the right zone but might have the wrong NF type for 3-var.

**THE SOLUTION**: Do not use Prior-UZ for w'. Instead, use nf_extend_bwd to get w_nf, and then VERIFY that w_nf is in the right zone. If the depth-K 3-var NF at [w,x,t] encodes "w > t" and "w < x" in its atom part, then w_nf must also satisfy "w_nf > t'" and "w_nf < x'" (since the atom part of the depth-K 3-var NF records these orders, and the 3-var agreement preserves atoms).

YES! This is the key:
- The depth-K 3-var NF at [w,x,t] records the orders: `w > t` and `w < x` as atom values.
- The depth-K 3-var agreement at [w,x,t]/[w_nf,x',t'] preserves all atoms.
- Therefore: `w_nf > t'` and `w_nf < x'`.

So w_nf IS in zone 3 (t' < w_nf < x'). We don't need Prior-UZ at all for the witness! nf_extend_bwd already provides a correctly-placed witness.

### 7.8 The Corrected Proof Strategy

```
-- Inside strong induction body at K, quantifier part:
-- Goal: (exists w, nf_eval M (K+1) 3 [w,x,t] sub_nf) <-> (exists w', nf_eval N (K+1) 3 [w',x',t'] sub_nf)

-- Forward direction: exists w in M -> exists w' in N
rintro ⟨w, hw⟩
-- hw : nf_eval M (K+1) 3 [w,x,t] sub_nf

-- From ih_strong at m = K-1 (when K >= 1):
-- depth-(K+1) 2-var agreement at [x,t]/[x',t']
-- Its quantifier condition: for each chi3 : NF K 3:
--   (exists y, nf_eval M K 3 [y,x,t] chi3) <-> (exists y', nf_eval N K 3 [y',x',t'] chi3)

-- Take chi3 = nf_characteristic M K 3 [w,x,t]
-- M-side is witnessed by w
-- So exists w_nf in N with nf_eval N K 3 [w_nf,x',t'] (nf_char M K 3 [w,x,t])
-- By nf_agreement_from_shared_nf: depth-K 3-var FULL agreement at [w,x,t]/[w_nf,x',t']

-- From depth-K 3-var agreement (atom part):
-- w_nf > t' (from atom w > t in M, preserved by agreement)
-- w_nf < x' (from atom w < x in M, preserved by agreement)
-- So w_nf is in zone 3: t' < w_nf < x'

-- Now prove: nf_eval N (K+1) 3 [w_nf,x',t'] sub_nf

-- Atom part: from depth-K 3-var agreement (atoms at depth K >= atoms at all depths)
-- More precisely: depth-K 3-var agreement implies all atoms match.
-- sub_nf is depth-(K+1), but its atom part (.1) is the same kind (AtomKind sig 3 -> Bool).
-- From hw : sub_nf.1 records the atom values at [w,x,t] in M.
-- From depth-K 3-var agreement: the same atoms hold at [w_nf,x',t'] in N.
-- So sub_nf.1 is satisfied at [w_nf,x',t'] in N.

-- Quantifier part: for each sub4 : NF K 4:
-- (exists v', nf_eval N K 4 [v',w_nf,x',t'] sub4) <-> sub_nf.2 sub4 = true
-- From hw: sub_nf.2 sub4 = true <-> exists v in M, nf_eval M K 4 [v,w,x,t] sub4
-- From depth-K 3-var FULL agreement at [w,x,t]/[w_nf,x',t']:
--   Its quantifier condition gives: for each chi4 : NF (K-1) 4:
--     (exists v, nf_eval M (K-1) 4 [v,w,x,t] chi4) <-> (exists v', nf_eval N (K-1) 4 [v',w_nf,x',t'] chi4)
-- But we need depth-K, not depth-(K-1). GAP.
```

The depth gap persists. From depth-K 3-var agreement, we only get depth-(K-1) 4-var existential transfer, not depth-K.

### 7.9 Final Assessment

The sorry CANNOT be closed by purely algebraic NF machinery with a single level of strong induction on K. The depth gap (need depth K, have depth K-1 from nf_extend) is fundamental.

To close the sorry, one of the following structural changes is needed:

1. **Enrich the IH**: Instead of proving just 2-var agreement, prove (n+1)-var agreement for all n simultaneously. This means proving `for all K, for all n, depth-(K+2) (n+1)-var agreement at [env]/[env']` where env has specific structure. But `constenv_2var_determines` already handles the constant-env case, and the non-constant-env case is exactly the problem.

2. **Use the Prior-UZ approach WITH a secondary induction inside the quantifier part**: Prove the depth-(K+1) 3-var NF evaluation at [w',x',t'] by a SECONDARY induction inside the proof, where at each step we use nf_extend to drop one depth level and the secondary IH to handle the lower depth. This secondary induction on depth descends from K+1 to 0, and at each level uses nf_extend to get one more variable while dropping one depth level. At depth 0, everything is atomic and the transfer is direct.

3. **Rethink the formalization architecture**: The `prior_nonconstenv_2var_agree_until/since` theorem may not be the right abstraction. Instead, prove the existential transfer DIRECTLY inside `existPart_succ_n1_bypass` using a double induction (on depth K and on the "reconstruction depth" d), avoiding the 2-var agreement intermediary.

**Option 2 is the most promising** and aligns most closely with how Rabinovich's proof actually works. The secondary induction is precisely the "recursive depth descent" described in report 17 (Section 4), and corresponds to Rabinovich's induction on n (witness count) reinterpreted as a depth descent in the Lean setting.

---

## Summary of Findings

1. Rabinovich's proof uses induction on **witness count n**, while the Lean formalization uses induction on **quantifier depth k**. These are different but compatible induction principles.

2. The zone-3 sorry requires proving depth-(K+1) 3-var existential transfer between structures. The available infrastructure gives depth-K 3-var full agreement (via nf_extend from ih_strong at K-1), creating a depth gap of 1.

3. The depth gap CANNOT be bridged by purely algebraic NF manipulation. It requires either (a) a secondary depth induction inside the quantifier part, or (b) enriching the inductive hypothesis to carry more information.

4. Prior-UZ/SZ witness placement is NOT sufficient alone -- it gives 1-var type matching in the right zone, but the quantifier part of the 3-var NF requires additional depth-level information.

5. The nf_extend_bwd approach gives the right NF type match AND the right zone placement (via atom preservation), but at one lower depth than needed.

6. A secondary induction on "reconstruction depth" d (from K+1 down to 0) inside the quantifier part appears to be the correct mechanism. At each level d: atoms from the matched NF types, quantifier conditions from the depth-(d-1) version of the same argument, terminating at d=0 where everything is atomic.

7. This secondary induction corresponds to Rabinovich's recursive interval-splitting argument, where at each level the negation produces sub-interval formulas with fewer witnesses (=lower depth in the Lean encoding).
