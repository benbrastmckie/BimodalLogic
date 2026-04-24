# Research Report: Verbrugge Step-by-Step Construction and Burgess Chronicle Gap Analysis

**Task**: #107 — Burgess chronicle construction for BX representation theorem
**Date**: 2026-04-23
**Mode**: Single-agent Lean research
**Focus**: Comparative analysis of Verbrugge 2004 step-by-step method vs. Burgess 1982 chronicle construction, with concrete Lean 4 redesign recommendations for 3 critical architectural gaps

---

## Executive Summary

The Verbrugge 2004 paper (de Jongh, Veltman, Verbrugge) presents a step-by-step completeness method for basic tense logics (G/H only, no Until/Since) that constructs models incrementally by inserting points to satisfy F/P obligations. This method does NOT directly address Until/Since, which means it cannot serve as a drop-in replacement for the Burgess chronicle construction. However, the Verbrugge step-by-step technique reveals the correct architectural pattern for fixing all three critical gaps identified in the team research, particularly the C5 witness insertion strategy.

The key insight: Verbrugge's method inserts witnesses **between existing points** using the non-branching property of the canonical relation, while the current implementation inserts witnesses **beyond all existing points**, producing vacuous satisfaction. The Burgess chronicle construction is the correct framework for Until/Since, but the implementation must adopt the "between existing points" insertion strategy from Verbrugge's approach (which is also what Burgess specifies in Lemmas 2.9-2.10).

---

## 1. Verbrugge's Construction vs. Burgess

### 1.1 What Verbrugge Actually Covers

The Verbrugge 2004 paper proves completeness for the following logics:

| Logic | Frame Class | Method |
|-------|-------------|--------|
| **Lin** | Arbitrary strict linear orders | Step-by-step (Theorem 1) |
| **P** | Successive strict linear orders | Step-by-step (Theorem 2) |
| **Q** | Dense successive (= rationals) | Step-by-step (Theorem 3) |
| **R** | Reals | Extension from Q (Theorem 4) |
| **D** | Discrete successive | Step-by-step with adequate sets (Theorem 5) |
| **Z** | Integers | C_adequate method (Theorem 6) |
| **Z x Z** | Two copies of Z | C_adequate with gap analysis (Theorem 7) |
| **Z x n** | n copies of Z | Axiom G_n characterization (Theorem 9) |

**Crucially**: All these logics use only G and H operators. Verbrugge does not address Until or Since at all. The paper explicitly works with the connective-poor language where F(phi) = neg G(neg phi) and P(phi) = neg H(neg phi), with no binary temporal connectives.

### 1.2 The Step-by-Step Method (Theorem 1)

The core Verbrugge construction for Lin (Theorem 1) proceeds as follows:

1. **Stage 0**: Create a single point t* with Gamma_{t*} = MCS extending Sigma union {neg phi}.

2. **Stage n+1**: Process formula phi_n from an enumeration (where each formula appears infinitely often). For each point t in T_n:
   - If neg G(phi_n) in Gamma_t and no witness exists yet:
     - Find the **maximal such t** (furthest right with the obligation).
     - Use Lemma 4 to get Delta with Gamma_t prec Delta and neg phi_n in Delta.
     - **Insert Delta between t and t's immediate successor in T_n** (if t has one).
     - The non-branching property (Lemma 3) ensures Delta prec Gamma_{t'} where t' is t's current successor.

3. **Limit**: T = union of all T_n satisfies conditions (a)-(d).

**Key architectural feature**: The witness Delta is inserted **between existing points**, not beyond all of them. The non-branching property of the canonical relation (from axioms L1/L2) guarantees that the new point can be ordered consistently with the existing structure.

### 1.3 How This Differs from Burgess

Burgess's chronicle construction operates in a richer language (with Until and Since) and requires a fundamentally more complex data structure:

| Feature | Verbrugge | Burgess |
|---------|-----------|--------|
| Language | G, H only | G, H, Until, Since |
| Data structure | Function f: T -> MCS | Pair (f, g) where f: dom -> MCS, g: (x,y) -> DCS |
| Ordering | Canonical prec relation | Rational number ordering |
| Insertion target | Between existing points | Between existing points (via rationals) |
| Interval tracking | Not needed | Binary DCS g(x,y) tracks interval content |
| Conditions | (a)-(d) only | C0-C5 and C4 (backward r-relation) |

The g function in Burgess is the crucial addition: it tracks what formulas hold throughout the open interval (x,y) between consecutive domain points. This is essential for Until semantics because Until(gamma, delta) at x requires gamma to hold at all intermediate points between x and the delta-witness.

### 1.4 Verbrugge's "Between" Strategy in Detail

In Theorem 1, Stage n+1, the critical passage reads:

> "So, suppose for all t' > t, phi_n in Gamma_{t'}. By Lemma 4, there is a Delta such that Gamma prec Delta and neg phi_n in Delta. Add to T_n a node u as a new immediate successor to t with Delta = Gamma_u. If t is not maximal in T_n, we are done too. For, assume t' to be the immediate successor of t in T_n, so G(phi_n) in Gamma_{t'} and phi_n in Gamma_{t'}. Then, since prec is not branching to the future, Gamma_{t'} prec Delta or Gamma_{t'} = Delta or Delta prec Gamma_{t'}. The first case cannot apply, since G(phi_n) in Gamma_{t'} and neg phi_n in Delta, but neither can the second, because phi_n in Gamma_{t'} and neg phi_n in Delta; thus Delta prec Gamma_{t'}."

This is a **proof by elimination using the non-branching property**: when inserting a new point between existing points, the three-way comparison (forward, equal, backward) is resolved to show the new point sits in the correct position.

**The current implementation fails to do this**. Instead of inserting between existing points, `eliminate_C5_counterexample` uses `exists_rat_gt_finset` to place the new point beyond ALL existing points, making the guard condition vacuously satisfied.

---

## 2. C4 in Verbrugge and Burgess

### 2.1 Verbrugge Does Not Need C4

Verbrugge's construction does not have a binary interval function g, so there is no notion of C4 (backward r-relation from interval to point). The conditions (a)-(d) in Theorem 1 are:

- (a) t* satisfies the root MCS
- (b) If t < t', then Gamma_t prec Gamma_{t'}
- (c) If neg G(phi) in Gamma_t, there exists t' > t with neg phi in Gamma_{t'}
- (d) Mirror of (c) for H

These conditions do not involve intervals at all. The temporal ordering is maintained solely through the prec relation between MCS.

### 2.2 C4 in Burgess is Essential

Burgess's C4 condition (Section 2) states:

> **(C4a)** Whenever x, y in dom f and x < y and neg U(gamma, delta) in f(x) and gamma in f(y), there is some z in dom f with x < z < y and neg delta in f(z).

This is the **counterexample resolution** condition: if Until(gamma, delta) fails at x (i.e., neg U(gamma, delta) in f(x)) but gamma holds at a later point y, then the guard delta must fail at some intermediate point z. This condition is used in the truth claim (2.11) for the backward direction of the Until case:

> "If instead ~alpha in f(x), then for any y in X with x < y and y in V(gamma), we have by induction hypothesis gamma in f(y), and hence by C4a there must be a z in X with x < z < y and ~beta in f(z), whence by induction hypothesis z not in V(beta). It follows that x not in V(alpha) as required."

Without C4, the truth claim cannot be proved for Until formulas in the backward direction. The current implementation omits C4 entirely, which is why `limit_satisfies_c5_weak` is unprovable.

### 2.3 Why C4 Is Structurally Necessary

The interaction between C4 and C5 in Burgess is:

- **C5** (forward): U(xi, eta) in f(x) implies there exists y > x with eta in f(y) and eta in g(x,y). This gives the **forward witness**.
- **C4** (backward): neg U(gamma, delta) in f(x) and gamma in f(y) implies there exists z between x and y with neg delta in f(z). This gives the **backward counterexample**.

Together, they ensure the model is "complete" with respect to Until truth conditions in both directions. The counterexample elimination lemmas (2.9 for C4, 2.10 for C5) build the chronicle incrementally, and the limit satisfies both because every counterexample is eventually eliminated.

**Critically**: C4 elimination (Lemma 2.9) inserts points **between existing points** using Lemma 2.6 (for the n=0 base case) and induction on the number of intermediate domain points (for n=m+1). This is exactly the "between existing points" pattern from Verbrugge's construction.

---

## 3. Non-Domain Extension

### 3.1 Verbrugge's Approach: No Extension Needed

Verbrugge's construction produces a countable linear order T = union of T_n, which may be dense, discrete, or have other structural properties depending on the logic. For the rationals (Theorem 3 for Q), the construction explicitly creates density:

> "At the odd stages density is taken care of as follows: Let t, u be any two successive points of T_n. A new point v between each such t and u is added."

The model is defined **only over T**. There is no extension to non-domain points. The valuation V is defined by V(p_i) = {t in T : p_i in Gamma_t}. The truth conditions are checked only at points in T.

### 3.2 Burgess's Approach: Domain-Only Model

Burgess's construction similarly defines the model only over X = union of dom(f_n). The valuation is:

> "V(alpha) = X for all valuations in (X, <) -- the order being the usual order on the rationals -- by letting x in V(alpha) iff alpha in f(x)."

The model (X, <) is a substructure of the rationals. There is NO extension to non-domain rationals. The truth claim 2.11 states that the valuation V(alpha) = {x : alpha in f(x)} satisfies the semantic truth conditions for all formulas, but only for x in X.

### 3.3 The Current Implementation's Mistake

The current `extended_limit_f` in `ChronicleToCountermodel.lean` (lines 99-104) assigns the root MCS A to all non-domain rationals:

```lean
noncomputable def extended_limit_f (A : Set Formula) (h_mcs : SetMaximalConsistent A) :
    Rat → Set Formula :=
  fun x =>
    if h : ∃ n, x ∈ (omega_chain_val A h_mcs n).dom
    then (omega_chain_val A h_mcs h.choose).f x
    else A
```

This is provably wrong under strict semantics. If G(phi) in A and t' is a non-domain rational with t < t', then `forward_G` requires phi in `extended_limit_f(t') = A`, which demands G(phi) -> phi (the T-axiom for G). But G does not have the T-axiom under strict (irreflexive) semantics.

**The fix**: Use a `Set Rat`-indexed model (or equivalently, a `Subtype`-indexed model over limit_dom). The BFMCS should be constructed over `{ x : Rat // x in limit_dom A h_mcs }` or the chronicle domain should be dense enough that the model over the domain points is the full model. Burgess's construction produces a model over a subset of the rationals; the integration layer should not extend to all rationals.

---

## 4. Guard Propagation and the C5 Problem

### 4.1 Verbrugge Does Not Have Guards

Since Verbrugge only handles G/H, there is no guard condition. The F-obligation at t (neg G(phi) in Gamma_t) requires only a single witness t' > t with neg phi in Gamma_{t'}. There is no requirement about intermediate points.

### 4.2 Burgess's C5 Guard via the Interval Function g

Burgess's C5 requires not just a witness y with eta in f(y), but also that the guard eta holds throughout the interval (x, y). This is encoded through the interval function g:

> **(C5a)** Whenever x in dom f and U(xi, eta) in f(x), there is some y in dom f with x < y and xi in f(y) and eta in g(x, y).

The condition "eta in g(x,y)" means eta is in the DCS assigned to the interval from x to y. By C3, g(x,z) = g(x,y) intersect f(y) intersect g(y,z) for x < y < z, so eta propagates to all intermediate intervals and points.

### 4.3 How Burgess Eliminates C5 Counterexamples (Lemma 2.10)

Lemma 2.10 in Burgess handles C5 counterexamples by **induction on the number of domain points after x**:

**Case n = 0** (no points after x): Apply Lemma 2.4 to A = f(x), obtaining B and C with eta in B, xi in C, and R(A, B, C). Set y = x+1, f'(y) = C, g'(x,y) = B.

**Case n = m+1** (x' is x's immediate successor): Three subcases:
- (i) If eta and U(xi, eta) in f(x') and eta in g(x, x'): reduce to n = m by replacing x with x'.
- (ii) If xi in f(x') and eta in g(x, x'): done (x' is already a witness).
- If neither (i) nor (ii): apply Lemma 2.7 or 2.8 to insert a point z = (x + x')/2 **between x and x'**, with f'(z) = D, g'(x,z) = B', g'(z,x') = B''.

**The critical feature**: The new point z is placed at the midpoint (x + x')/2, which is between x and its immediate successor x'. The interval function g is split: g(x, x') is replaced by g(x, z) and g(z, x'), with C3 ensuring consistency.

### 4.4 The Current Implementation's Vacuous C5

The current `eliminate_C5_counterexample` uses `exists_rat_gt_finset` to place the witness y beyond ALL domain points. This means:

1. No intermediate domain points exist between x and y.
2. The guard condition "for all z in dom, x < z < y implies gamma in f(z)" is **vacuously true** (no such z exists).
3. The C5 condition is satisfied trivially, but the model does not actually enforce the guard.

When the chronicle is converted to a countermodel over the rationals (or a dense domain), this vacuous satisfaction breaks down: there will be non-domain rationals between x and y where gamma need not hold, violating the semantic Until truth condition.

### 4.5 How to Fix the Insertion Strategy

The fix requires implementing Burgess's Lemma 2.10 correctly:

1. When x has an immediate successor x' in the current domain:
   - Check if x' already serves as a witness or passes the Until obligation forward.
   - If not, insert a new point z = (x + x')/2 between x and x', using Lemma 2.7 or 2.8 to construct the MCS and interval DCS for z.

2. The interval function g must be properly maintained:
   - When inserting z between x and x', replace g(x, x') with g(x, z) and g(z, x').
   - Lemma 2.7 provides the split: R(f(x), g(x,z), f(z)) and R(f(z), g(z,x'), f(x')).
   - C3 ensures g(x, x') = g(x, z) intersect f(z) intersect g(z, x').

3. The Lemma 2.10 induction on the number of points after x ensures termination: at each step, either the number of points after x decreases (by replacing x with x'), or a new point is inserted at a specific position (between x and x').

---

## 5. Strict Semantics Compatibility

### 5.1 Verbrugge Assumes Irreflexive Semantics

Verbrugge's paper works with **strict linear orders** throughout (Definition 3(iv): "transitive, irreflexive and connected"). This is compatible with the irr_until branch's strict G/H semantics.

### 5.2 Burgess Uses Strict Semantics for Until/Since

Burgess's semantics (Section 1.2) is:

> V(U(alpha, beta)) = {x : exists y (x < y and y in V(alpha) and forall z (x < z < y implies z in V(beta)))}

This is **strict** Until semantics: x < y (not x <= y), and the guard covers the open interval (x, y), not the closed interval [x, y]. The guard does NOT include x itself (x < z, not x <= z) and does NOT include y (z < y, not z <= y).

### 5.3 Adaptation for the irr_until Branch

The irr_until branch uses strict Until semantics (x < y, guard on open interval), which matches Burgess's semantics directly. The key BX axioms used are:

| BX Axiom | Burgess Axiom | Role |
|----------|---------------|------|
| BX4 (connect_future) | Not in A1-A7 | phi -> G(P(phi)), used for seed construction |
| BX5 (self_accum_until) | A5a | U(p,q) -> U(p, q and U(p,q)) |
| BX6 (absorb_until) | A6a | U(q and U(p,q), q) -> U(p,q) |
| BX7 (linear_until) | A7a | Linearity of Until |
| BX9 (until_elim) | Derived from A3a | U(p,q) -> p or q (at strict current point) |
| BX10 (until_F) | Derived | U(p,q) -> F(q) |
| BX12 (F_until_equiv) | Derived | F(p) -> T U p |

**A3a adaptation**: Burgess's A3a (`p and U(q,r) -> U(q and S(p,r), r)`) is NOT valid under strict semantics. The implementation correctly replaces A3a's role with BX4 (connect_future) in Lemma 2.4. This substitution is already implemented and does not require further changes.

**No additional strict-semantics adaptations are needed** for the chronicle construction, because:
1. Burgess's own semantics is strict.
2. The BX axioms on the irr_until branch are the correct strict-semantics axioms.
3. The chronicle conditions C0-C5 are defined in terms of set membership (MCS/DCS), not in terms of the semantic truth conditions, so they are independent of reflexive vs. irreflexive semantics.

---

## 6. Concrete Lean 4 Design Recommendations

### 6.1 ChronicleTypes.lean: Add C4/C4' and Modify ValidChronicle

**Add C4 condition** (Burgess Section 2, C4a):

```lean
/-- **C4**: Backward counterexample condition.
If neg U(gamma, delta) in f(x) and gamma in f(y) with x < y,
then there exists z in dom with x < z < y and neg delta in f(z).

This is the backward direction of the Until truth condition:
if Until(gamma, delta) fails at x but gamma holds at a later point y,
the guard delta must fail at some intermediate point z. -/
def Chronicle.c4 (chi : Chronicle) : Prop :=
  forall x in chi.dom,
    forall y in chi.dom,
      x < y ->
      forall (gamma delta : Formula),
        (Formula.untl gamma delta).neg in chi.f x ->
        gamma in chi.f y ->
        exists z in chi.dom, x < z /\ z < y /\ delta.neg in chi.f z

/-- **C4'**: Mirror of C4 for Since. -/
def Chronicle.c4' (chi : Chronicle) : Prop :=
  forall x in chi.dom,
    forall y in chi.dom,
      y < x ->
      forall (gamma delta : Formula),
        (Formula.snce gamma delta).neg in chi.f x ->
        gamma in chi.f y ->
        exists z in chi.dom, y < z /\ z < x /\ delta.neg in chi.f z
```

**Add C4/C4' to ValidChronicle**:

```lean
structure ValidChronicle extends Chronicle where
  hc0 : toChronicle.c0
  hc1 : toChronicle.c1
  hc2 : toChronicle.c2
  hc2' : toChronicle.c2'
  hc3 : toChronicle.c3
  hc4 : toChronicle.c4     -- NEW
  hc4' : toChronicle.c4'   -- NEW
  hc5 : toChronicle.c5
  hc5' : toChronicle.c5'
```

**Additionally**: Modify C5 to include the interval function requirement. The current C5 only checks guard at intermediate domain points. The correct C5 from Burgess requires eta in g(x,y):

```lean
/-- **C5** (full Burgess): Forward Until witness with interval DCS. -/
def Chronicle.c5_full (chi : Chronicle) : Prop :=
  forall x in chi.dom,
    forall (xi eta : Formula),
      Formula.untl xi eta in chi.f x ->
      exists y in chi.dom, x < y /\ xi in chi.f y /\ eta in chi.g x y
```

This change propagates the guard condition through the interval function g, ensuring non-vacuous satisfaction when the domain is later interpreted as a dense model.

### 6.2 CounterexampleElimination.lean: Redesign Insertion Strategy

**Replace endpoint insertion with between-point insertion**. The current strategy (insert beyond all points) must be replaced with Burgess's Lemma 2.9/2.10 strategy.

**For C4 counterexamples** (Lemma 2.9): Add `eliminate_C4_counterexample`:

```lean
/-- Lemma 2.9: Given a C4 counterexample (x, y, gamma, delta),
insert a point z between x and y with neg delta in f(z).

Case n=0 (no points between x and y): Use Lemma 2.6 on
R(f(x), g(x,y), f(y)) and delta not in g(x,y) to get
D with neg delta in D. Insert z = (x+y)/2 with f(z) = D,
g(x,z) = B', g(z,y) = B''.

Case n=m+1 (x' is x's immediate successor, x < x' < y):
If neg U(gamma, delta) in f(x'): reduce to case n=m (replace x with x').
If U(gamma, delta) in f(x'): delta in f(x') (else not a counterexample),
  gamma' = delta and U(gamma, delta) in f(x'), use A3a-equivalent to
  get neg U(gamma', delta) in f(x), reduce to n=0 case (replace gamma
  with gamma', y with x'). -/
noncomputable def eliminate_C4_counterexample {chi : Chronicle}
    (h_valid : chi.c0 /\ chi.c1 /\ chi.c2' /\ chi.c3)
    (ce : C4Counterexample chi) :
    exists chi' : Chronicle,
      chi.dom subset chi'.dom /\
      (forall x in chi.dom, chi'.f x = chi.f x) /\
      chi'.c0 /\ chi'.c1 /\ chi'.c2' /\ chi'.c3 /\
      -- The counterexample is eliminated
      (exists z in chi'.dom, ce.x < z /\ z < ce.y /\ ce.delta.neg in chi'.f z)
```

**For C5 counterexamples** (Lemma 2.10): Redesign `eliminate_C5_counterexample`:

```lean
/-- Lemma 2.10 (corrected): Given a C5 counterexample (x, xi, eta),
insert a witness using the correct Burgess strategy.

Case n=0 (no points after x): Apply Lemma 2.4 to A = f(x),
get B, C with eta in B, xi in C. Set y = x+1, f(y) = C, g(x,y) = B.

Case n=m+1 (x' is x's immediate successor):
  (i) If eta and U(xi,eta) in f(x') and eta in g(x,x'):
      replace x with x' (reduce to n=m).
  (ii) If xi in f(x') and eta in g(x,x'): x' is the witness.
  (iii) Otherwise: apply Lemma 2.7 or 2.8 to insert z = (x+x')/2
       between x and x'. -/
noncomputable def eliminate_C5_counterexample_v2 {chi : Chronicle}
    (h_valid : chi.c0 /\ chi.c1 /\ chi.c2' /\ chi.c3)
    (ce : C5Counterexample chi) :
    exists chi' : Chronicle,
      chi.dom subset chi'.dom /\
      (forall x in chi.dom, chi'.f x = chi.f x) /\
      chi'.c0 /\ chi'.c1 /\ chi'.c2' /\ chi'.c3 /\
      -- C5 witness exists
      (exists y in chi'.dom, ce.x < y /\ ce.eta in chi'.f y /\
        ce.xi in chi'.g ce.x y)
```

**Key design decision**: The induction on n (number of points after x) is well-founded because the domain is finite at each step. Lean's `Finset.card` provides the decreasing measure. The recursion terminates because case (i) decreases n, case (ii) terminates immediately, and case (iii) inserts between x and x' (not after x'), maintaining the property that the relevant portion of the domain shrinks.

### 6.3 ChronicleToCountermodel.lean: Fix extended_limit_f

**Option A: Subtype-indexed model (RECOMMENDED)**

Replace `BFMCS Rat` with `BFMCS (Subtype (limit_dom A h_mcs))`:

```lean
/-- The chronicle FMCS over the limit domain subtype.
No extension to non-domain rationals is needed. -/
noncomputable def chronicle_fmcs_subtype (A : Set Formula)
    (h_mcs : SetMaximalConsistent A) :
    FMCS { x : Rat // x in limit_dom A h_mcs } where
  mcs := fun x => limit_f A h_mcs x.val
  is_mcs := fun x => limit_c0 A h_mcs x.val x.property
  forward_G := by
    intro t t' phi h_lt h_G
    -- G(phi) in limit_f(t.val), t.val < t'.val, need phi in limit_f(t'.val)
    -- Both t and t' are in limit_dom, so this follows from the chronicle's
    -- g_content structure: G(phi) in f(t) implies phi in g(t, ...) implies
    -- phi in f(t') for any t' > t in the domain.
    ...
  backward_H := ...
```

This requires showing that `{ x : Rat // x in limit_dom A h_mcs }` has the requisite algebraic structure (AddCommGroup, LinearOrder, IsOrderedAddMonoid, Nontrivial). The limit_dom is a countable dense subset of Q, so:

- **LinearOrder**: Inherited from Rat via Subtype.
- **AddCommGroup**: This is the challenging part. The limit_dom is NOT necessarily closed under addition (x, y in limit_dom does not imply x + y in limit_dom). Two approaches:
  (a) Ensure the chronicle construction produces an additive subgroup (by explicitly closing limit_dom under rational addition during the omega-chain construction).
  (b) Use a different algebraic structure that does not require additive closure.

**Option B: Dense chronicle domain**

Modify the omega-chain construction to interleave density steps (as in Verbrugge's Theorem 3 for Q): at odd stages, insert density witnesses between every pair of adjacent domain points. This ensures limit_dom is a countable dense linear order, which is isomorphic to Q by Cantor's theorem. Then the model over limit_dom IS a model over Q (up to isomorphism).

**Option C: Direct quotient**

Use the chronicle's interval function g to define truth at non-domain rationals. For non-domain r, define limit_f(r) as the MCS obtained by Lindenbaum extension of g(x, y) where x and y are the adjacent domain points bracketing r. This preserves g_content coherence and avoids the T-axiom problem.

**Recommendation**: Option B (dense chronicle domain) is the cleanest approach because:
1. It requires no algebraic structure on a subtype.
2. It produces a model over Q directly.
3. The density step is straightforward (Verbrugge's proof for Q, Theorem 3, gives the exact template).
4. The integration with the existing BFMCS Rat infrastructure is seamless.

The density insertion step at each odd stage:
```lean
-- For each pair of adjacent domain points x < y in chi.dom:
-- Find MCS Delta with Gamma_x prec Delta prec Gamma_y
-- (exists by the density property of the canonical prec relation,
--  which follows from the Q axiom GG(phi) -> G(phi))
-- Insert v = (x+y)/2 with f(v) = Delta, g(x,v) and g(v,y) derived from g(x,y)
```

For this to work with Until/Since, the density insertion must also maintain C4/C5. This is where the interval function g becomes essential: when inserting v between x and y, split g(x,y) into g(x,v) and g(v,y) using Lemma 2.6's machinery.

### 6.4 ChronicleConstruction.lean: Fix limit_satisfies_c5_weak

The fix has two parts:

**Part 1: Correct counterexample enumeration**

The current `counterexample_enum` must enumerate **both C4 and C5 counterexamples**. Extend `PotentialCounterexample` to include a C4 variant:

```lean
inductive PotentialCounterexampleKind
  | c4_forward  -- C4a counterexample: neg U(gamma, delta) at x, gamma at y
  | c4_backward -- C4b counterexample: neg S(gamma, delta) at x, gamma at y
  | c5_forward  -- C5a counterexample: U(xi, eta) at x, no witness
  | c5_backward -- C5b counterexample: S(xi, eta) at x, no witness

structure PotentialCounterexample where
  x : Rat
  y : Rat  -- for C4; unused for C5
  phi1 : Formula  -- gamma/xi
  phi2 : Formula  -- delta/eta
  kind : PotentialCounterexampleKind
```

**Part 2: Fix the limit C5 proof**

Once the counterexample elimination inserts witnesses between existing points (not beyond them), and C4 counterexamples are also eliminated, the limit_satisfies_c5_weak proof becomes:

1. For any x in limit_dom with U(xi, eta) in limit_f(x):
2. x is in some omega_chain_val(n0).dom.
3. The counterexample enumeration covers (x, _, xi, eta, c5_forward) at some index k.
4. At step max(n0, k) + 1, the C5 counterexample at x has been processed.
5. Either a witness was already present, or one was inserted (with proper guard via g).
6. The witness persists in the limit because f agrees on old domain points.

The guard condition (xi at intermediate points) requires the interval function g. The proof must show that the g values propagate correctly through the limit. This is where the C3 condition (interval decomposition) is essential: when new points are inserted, the interval function is updated consistently.

---

## 7. Dependency Structure of the Fixes

The three architectural gaps have the following dependency structure:

```
[C4 addition]
     |
     v
[C5 insertion redesign] -----> [extended_limit_f fix]
     |                               |
     v                               v
[limit_satisfies_c5_weak proof]  [chronicle_fmcs forward_G/backward_H]
     |                               |
     v                               v
[chronicle_bfmcs_restricted_fuc] [chronicle_bfmcs_restricted_tc]
     |                               |
     +-------------------------------+
                    |
                    v
           [dd_countermodel_chronicle]
                    |
                    v
              [bx_completeness]
```

**Recommended execution order**:

1. **Phase 1** (Foundation): Add C4/C4' to ValidChronicle. Implement C4 counterexample elimination (Lemma 2.9). This is the prerequisite for everything else.

2. **Phase 2** (Insertion Redesign): Redesign C5 counterexample elimination to insert between existing points (Lemma 2.10 with induction). This requires Lemma 2.7 and 2.8 to be sorry-free. Close the D2 sorry in lemma_2_7.

3. **Phase 3** (Domain Extension): Either make the domain dense (Option B) or switch to subtype-indexed model (Option A). This fixes extended_limit_f and makes forward_G/backward_H provable.

4. **Phase 4** (Limit Properties): Prove limit_satisfies_c5_weak and limit_satisfies_c5'_weak using the corrected insertion strategy and C4.

5. **Phase 5** (Integration): Close the restricted coherence conditions and complete dd_countermodel_chronicle.

---

## 8. Effort Estimates

| Phase | Description | Estimated Hours | Key Difficulty |
|-------|-------------|----------------|----------------|
| 1 | Add C4/C4', implement Lemma 2.9 | 8-12 | Lemma 2.6_strong (seed consistency with h_content) |
| 2 | Redesign C5 elimination, close Lemma 2.7 D2 | 12-18 | BX7 three-way case analysis under strict semantics |
| 3 | Fix domain extension (dense domain or subtype) | 6-10 | Algebraic instances for subtype, or density maintenance |
| 4 | Prove limit C5/C5' | 8-12 | Tracking g-values through omega-chain limit |
| 5 | Close restricted coherence, complete integration | 10-15 | Transfer from chronicle C5 to FMCS Until coherence |
| **Total** | | **44-67** | |

These estimates supersede the team research estimate of 35-55 hours. The increase reflects the additional complexity of the density insertion step and the Lemma 2.7 D2 case under strict semantics.

---

## 9. Key Insight: Why Verbrugge's Method Matters

Although Verbrugge's paper does not cover Until/Since, it provides the correct **architectural pattern** for the construction:

1. **Insert between existing points** (not beyond them). Verbrugge's Theorem 1 proves this works for G/H obligations using the non-branching property. Burgess's Lemmas 2.9-2.10 extend this to Until/Since obligations using the interval function g.

2. **Use density for domain extension**. Verbrugge's Theorem 3 shows how to interleave density steps with obligation-resolution steps to produce a dense model. This eliminates the non-domain extension problem entirely.

3. **The induction on intermediate points** is the correct structure for Lemma 2.10. Verbrugge's construction implicitly uses this (each new point is inserted between its predecessor and successor), and Burgess makes it explicit with the n=0 base case and n=m+1 inductive case.

The current implementation's fundamental error -- inserting witnesses beyond all existing points -- is precisely the pattern that both Verbrugge and Burgess avoid. Fixing this single architectural choice (from "insert beyond" to "insert between") resolves all three critical gaps simultaneously:

- **C4**: Can be maintained because counterexample insertion (Lemma 2.9) inserts between existing points, preserving the backward r-relation.
- **Non-domain extension**: Eliminated if the domain is made dense, because every rational is a domain point (or arbitrarily close to one).
- **Vacuous C5**: Eliminated because witnesses are inserted with proper guard conditions at intermediate points, not placed where no intermediate points exist.

---

## References

- Burgess, J.P. (1982). "Axioms for tense logic I: Since and Until." *Notre Dame Journal of Formal Logic*, 23(4), 367-374.
- de Jongh, D., Veltman, F., and Verbrugge, R. (2004). "Completeness by construction for tense logics of linear time." Manuscript / Liber Amicorum contribution.
- Task 107 team research report: `specs/107_*/reports/07_team-research.md`
