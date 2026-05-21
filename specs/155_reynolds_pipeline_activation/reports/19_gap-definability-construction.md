# Gap r-Definability for the Infimum of a Continuation Formula Set

**Task**: 155 -- Reynolds Pipeline Activation
**Date**: 2026-05-21
**Purpose**: Concrete construction for showing the infimum of S_C is r-definable when it falls on a gap

---

## 1. Problem Statement

GHR93 Claim 1 requires defining `c = inf S_C` where:
```
S_C = { t in [x,y] : C holds at all mu-points in (t, y) }
```

and `C` is defined by rank-r formulas (the interval type `X_{(a_n, y')}`). The infimum must live in `ExtendedCarrier M atomMap r`, which means that if it falls on a gap, that gap must be r-definable.

**The core question**: Can we find a SINGLE `StaviFormula D` of `stavi_depth D <= r` that satisfies `gap_definable_on_right M atomMap gamma D` (or `gap_definable_on_left`)?

---

## 2. Answer: The Gap Is C-Definable on the Right

The answer is **yes**, and the defining formula is C itself (or more precisely, a single StaviFormula encoding the interval type). The argument does NOT require an infinitary conjunction.

### 2.1 Why C Works as a Single Formula

The key insight from GHR93 p.116 (and the literature extraction in report 18):

> "If c is not an element of M, then c is a gap definable on the right by C."

Here is the precise argument:

**Setup**: gamma is the infimum of S_C and gamma is a gap (not a carrier point). The set S_C = {t : C holds on all mu-points in (t,y)} is an upward-closed subset of [x,y] in ExtendedCarrier (if t is in S_C and t' > t, then (t',y) is a subset of (t,y), so C holds on (t',y) too).

**C above the gap (initial segment of complement)**: For any carrier point p with `p notin gamma.cut` (i.e., `extendPoint p > gamma`), we have `extendPoint p` is in S_C (since the gap is the infimum, anything above it is in S_C or has S_C elements arbitrarily close above). More precisely: since gamma = inf S_C, for any p above gamma, either p is in S_C (in which case C holds at p) or there exist elements of S_C arbitrarily close above gamma, and p is above all of them, so C holds at p by the upward-closure of the C-holding region. Actually, we need to be more careful:

The set S_C is upward-closed in ExtendedCarrier. The gap gamma = inf S_C. So every element strictly above gamma is either in S_C or is a lower bound of S_C (impossible since gamma is the greatest lower bound and the element is above gamma). Therefore every element above gamma is in S_C. In particular, for carrier points p with `p notin gamma.cut`:
- `extendPoint p > gamma` (by the order definition)
- `extendPoint p` is in S_C
- Therefore C holds at all mu-points in `(extendPoint p, y)`
- By `stavi_truth_mu_at_point`, this means `stavi_temporal_truth M atomMap p C` holds

This gives the first conjunct of `gap_definable_on_right`: there exists t not in gamma.cut such that C holds at all u not in gamma.cut with u <= t. In fact C holds at ALL carrier points above gamma.

**C fails cofinally below the gap**: Since gamma = inf S_C, for any t < gamma (i.e., t in gamma.cut), there exist elements below gamma that are NOT in S_C. Being not in S_C means C fails at some mu-point in (t, y). More precisely: if there were a final segment of the cut where C held throughout, then those elements would be in S_C (since C holds at all mu-points above them up to y), contradicting that they are below the infimum of S_C.

Wait -- we need to check the second conjunct of `gap_definable_on_right` more carefully.

### 2.2 Checking gap_definable_on_right

From EFGames.lean line 322:
```lean
def gap_definable_on_right ... (gamma : Gap M.carrier) (D : StaviFormula) : Prop :=
  (exists t, t notin gamma.cut /\ forall u, u notin gamma.cut -> u <= t ->
    stavi_temporal_truth M atomMap u D) /\
  not (exists t, t in gamma.cut /\ forall u, t <= u -> u in gamma.cut ->
    stavi_temporal_truth M atomMap u D)
```

**First conjunct** (D holds on an initial segment of the complement):
- Need: exists t notin gamma.cut such that D holds at all u notin gamma.cut with u <= t
- Take D = C (or a representative formula -- see Section 3)
- Since gamma = inf S_C and S_C is upward-closed, ALL carrier points p above gamma satisfy C(p)
- Take any p notin gamma.cut. Then for all u notin gamma.cut with u <= p, C(u) holds
- This works because "notin gamma.cut" for carrier points means "above the gap", and all such points are in the C-region

**Wait**: `gap_definable_on_right` uses `stavi_temporal_truth M atomMap u D`, which is the STANDARD (non-mu-relativized) truth on `M.carrier`. But S_C is defined using `stavi_temporal_truth_mu` on `ExtendedCarrier`. We need `stavi_truth_mu_at_point` (EFGames.lean line 1973) to bridge:

```lean
stavi_temporal_truth_mu M atomMap r (extendPoint m) A <->
  stavi_temporal_truth M atomMap m A
```

So for carrier points, mu-relativized truth equals standard truth. The gap definability conditions use standard truth on `M.carrier`, which equals mu-relativized truth at `extendPoint` by this lemma. This bridge works.

**Second conjunct** (D does NOT hold on any final segment of the cut):
- Need: NOT (exists t in gamma.cut such that D holds at all u >= t in gamma.cut)
- Suppose for contradiction that such t exists. Then C holds at all carrier points u with t <= u and u in gamma.cut
- But C holding at u (for carrier points u in the cut) means: C holds at all mu-points in (extendPoint u, y)
- If C holds at all mu-points in (extendPoint u, y), then extendPoint u is in S_C
- So all carrier points u >= t in gamma.cut are in S_C (when lifted to ExtendedCarrier)
- But these points are BELOW gamma (since they're in the cut), contradicting gamma = inf S_C
- Therefore no such final segment exists

**Conclusion**: C satisfies `gap_definable_on_right` at gamma.

### 2.3 But What Is "C" as a Single StaviFormula?

The interval type `C = X_{(a_n, y')}` is defined as: "for all rank-r formulas A, if A holds throughout (a_n, y'), then A holds at t". This is conceptually an infinitary conjunction.

However, we do NOT need to encode C as an infinitary conjunction. There are two approaches:

**Approach A (Prop-level C, construct gap from properties)**:
Define C as a Prop-valued predicate (not a formula). Show the infimum defines a gap. Then show the gap is r-definable by finding a SINGLE distinguishing formula D. The key insight: at the gap boundary, rank_type changes. Since there are finitely many rank-r types (by NormalForm finiteness), there exists a single formula D that distinguishes the two sides.

**Approach B (Single formula from rank_type change)**:
The gap gamma = inf S_C separates two regions with different rank_types. On one side (above gamma), all points satisfy C. On the other side (below gamma), C fails at some point. Since C failing means "some rank-r formula A holds throughout (a_n, y') but fails at t", we can extract that specific A using Classical.choose. But we need A to fail COFINALLY below gamma, not just at one point.

**Approach C (The actual GHR93 argument -- use C itself as the defining formula)**:
In GHR93, C is not really infinitary. `X_{(a_n, y')}` can be represented as a FINITE conjunction because there are only finitely many rank-r types (by NormalForm finiteness, `NormalForm sig r 1` is Fintype). The rank_type is determined by which NormalForm an element satisfies, and the interval type `X_{(s,t)}` is a finite disjunction of finitely many type-formulas. Each type-formula itself is a finite conjunction over `NormalForm`-determined atoms.

**Recommendation: Use Approach A** (Prop-level C, extract single distinguishing formula from rank_type difference). This avoids building formula-level C entirely.

---

## 3. Concrete Construction: Gap r-Definability from Rank-Type Change

### 3.1 The Key Finiteness Argument

At the gap gamma = inf S_C:
- Above gamma: every mu-point has the SAME rank_type pattern (they all satisfy C)
- Below gamma: mu-points eventually fail to satisfy C (some rank-r formula fails)

Since rank_type is a Set StaviFormula, and there are finitely many inequivalent rank-r formulas, there exists a single formula D that:
1. Holds at all carrier points just above the gap (in the complement of gamma.cut)
2. Fails cofinally below the gap (in gamma.cut)

**Extraction**: Use Classical.choice on the existential "there exists A of depth <= r such that A distinguishes the two sides."

### 3.2 The Concrete Lean Construction

```lean
/-- The continuation predicate C: a Prop-level predicate on ExtendedCarrier.
    C(t) holds iff all rank-r formulas that hold throughout (a_n, y')
    also hold at t. -/
private def continuation_holds {sig : MonadicSignature}
    {N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} (a_n y' : ExtendedCarrier N atomMap r)
    (t : ExtendedCarrier N atomMap r) : Prop :=
  ∀ A : StaviFormula, stavi_depth A ≤ r →
    (∀ v : ExtendedCarrier N atomMap r,
      a_n < v → v < y' → mu_holds v →
      stavi_temporal_truth_mu N atomMap r v A) →
    stavi_temporal_truth_mu N atomMap r t A

/-- The S_C set: elements t in [x',y'] where C holds on all mu-points
    in (t, y'). -/
private def continuation_set {sig : MonadicSignature}
    {N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} (x' y' a_n : ExtendedCarrier N atomMap r) :
    Set (ExtendedCarrier N atomMap r) :=
  { t | inClosedInterval x' y' t ∧
    ∀ u : ExtendedCarrier N atomMap r,
      t < u → u ≤ y' → mu_holds u →
      continuation_holds a_n y' u }
```

**Note**: The predicate `continuation_holds` above is equivalent to saying "t has the same rank_type as points in (a_n, y')" in a specific sense. It is a Prop, not a formula.

### 3.3 Constructing the Gap

When the infimum of S_C is not a carrier point, we construct the gap:

```lean
/-- When inf S_C falls strictly between carrier points, the
    left side of the Dedekind cut. -/
private def infimum_cut {sig : MonadicSignature}
    {N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} (S : Set (ExtendedCarrier N atomMap r))
    : Set N.carrier :=
  { p : N.carrier | ∀ s ∈ S, extendPoint p < s ∨ extendPoint p = s }
  -- Equivalently: { p | extendPoint p is a lower bound of S }
  -- More precisely:
  -- { p | extendPoint p ≤ inf S }
  -- Since we don't have inf, define as:
  -- { p | ∀ s ∈ S, extendPoint p ≤ s }
```

Actually, the cleaner definition is:

```lean
private def infimum_cut_of_upward_closed
    {sig : MonadicSignature}
    {N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} (S : Set (ExtendedCarrier N atomMap r))
    : Set N.carrier :=
  { p : N.carrier | ∀ s ∈ S, extendPoint p ≤ s }
```

This is a downward-closed subset of N.carrier (if p is in the set and q <= p, then extendPoint q <= extendPoint p <= s for all s in S).

### 3.4 Proving the Gap Is r-Definable

This is the crux. We need to find D : StaviFormula with stavi_depth D <= r satisfying gap_definable_on_right.

**Step 1: Extract a distinguishing formula.**

The gap separates two regions. Above the gap, continuation_holds holds for all mu-points (they're in S_C). Below the gap, for each point p in the cut, there exists some s_p in S_C with extendPoint p < s_p, and by the definition of S_C, C holds on (s_p, y'). But p is NOT in S_C (since p is below inf S_C), so C must fail at some mu-point in (extendPoint p, y').

"C fails at u" means: there exists A : StaviFormula with stavi_depth A <= r such that A holds throughout (a_n, y') but A fails at u.

So for each p in the cut, there exist u_p (a carrier point above p) and A_p (a formula of depth <= r) such that:
- A_p holds throughout (a_n, y')
- A_p fails at u_p
- u_p is in (extendPoint p, y')

**Step 2: Use finiteness to find a single formula.**

There are only finitely many rank_types (by `NormalForm sig r 1` being Fintype, there are at most `nfCount (Fintype.card sig.preds) r 1` many types). The complement of the gap's cut (carrier points above the gap) all satisfy C, hence have rank_type containing all interval-type formulas. Points below the gap fail to satisfy C, so their rank_types miss at least one such formula.

Since there are only finitely many candidates for the "missing formula", and the cut is infinite (the complement has no minimum, so the cut has no supremum -- therefore the cut is cofinal in some direction), by the pigeonhole principle there exists a SINGLE formula D of depth <= r that fails at cofinally many points in the cut.

**However**, there's a subtlety: the pigeonhole argument requires that the set of "failing formulas" is finite. This is where NormalForm finiteness is essential.

**Step 3: The formal pigeonhole argument.**

Define `Phi = { A : StaviFormula | stavi_depth A <= r ∧ A holds throughout (a_n, y') }`. While Phi as a Set StaviFormula is infinite (StaviFormula is an inductive type, not Fintype), we only care about Phi up to equivalence at rank r. The key fact:

For any two carrier points p, q with the same rank_type, the SAME formulas from Phi fail at both p and q. So the "pattern of Phi-failures" is determined by rank_type, and there are finitely many rank_types.

But we don't actually need the full pigeonhole. We can use a simpler argument:

**Simplified extraction**: 

For gap gamma = inf S_C, the complement (carrier points above gamma) has a fixed pattern: all formulas in Phi hold at all complement points. The cut (carrier points below gamma) has a different pattern: for each cut point p, at least one Phi-formula fails. We need ONE formula that fails cofinally in the cut.

Suppose no single Phi-formula fails cofinally. Then for each A in Phi, the set of cut-points where A fails is bounded above (has a supremum in the cut). Taking the maximum of these suprema over all A in Phi (finitely many up to equivalence), we'd get a point above which ALL Phi-formulas hold in the cut. But then all points above this maximum would satisfy C, making them members of S_C, contradicting them being below inf S_C.

**This argument uses**: the fact that there are finitely many inequivalent formulas of depth <= r (NormalForm finiteness), which means there are finitely many patterns of Phi-failure, and the "maximum of finitely many bounded-above sets is bounded above" principle.

### 3.5 Lean Code Skeleton

```lean
/-- The gap defined by inf S_C is r-definable.

    Given:
    - gamma : Gap N.carrier, the gap defined by the infimum cut
    - S_C is upward-closed and its infimum defines gamma
    - C is determined by rank-r formulas (from interval_types)

    Proof strategy:
    1. The complement of gamma.cut has C holding at all points
       (they're above inf S_C, hence in S_C, hence C holds)
    2. The cut has C failing cofinally (if C held on a final
       segment, those points would be in S_C, contradicting inf)
    3. "C failing" means some specific rank-r formula fails
    4. By NormalForm finiteness + pigeonhole, one formula D
       fails cofinally in the cut
    5. D satisfies gap_definable_on_right
-/
theorem infimum_gap_r_definable {sig : MonadicSignature}
    {N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat}
    (gamma : Gap N.carrier)
    -- The gap arises from the infimum of S_C
    (h_above : ∀ p : N.carrier, p ∉ gamma.cut →
      continuation_holds a_n y' (extendPoint p))
    (h_below : ∀ p : N.carrier, p ∈ gamma.cut →
      ¬ continuation_holds_on_interval p y')
    -- All formulas in Phi have depth ≤ r
    : r_definable_gap N atomMap gamma r := by
  -- Step 1: For each p in cut, extract the failing formula A_p
  -- ∀ p ∈ gamma.cut, ∃ A : StaviFormula, stavi_depth A ≤ r ∧
  --   (∀ v ∈ (a_n, y'), A^mu(v)) ∧ ¬ A^mu(extendPoint p)
  have h_fail : ∀ p ∈ gamma.cut,
      ∃ A : StaviFormula, stavi_depth A ≤ r ∧
        ¬ stavi_temporal_truth N atomMap p A := by
    intro p hp
    -- p ∈ cut means p is below gamma, so extendPoint p < gamma
    -- p is not in S_C (below inf), so C fails at some point in (p, y')
    -- Unfolding: ∃ A of depth ≤ r, A holds on (a_n, y') but fails at ...
    -- Actually, continuation_holds fails at p means:
    -- ∃ A, depth ≤ r, A holds on (a_n, y'), ¬ A at p
    exact h_below p hp  -- this gives the witness

  -- Step 2: Pigeonhole over finitely many rank_types
  -- There are finitely many functions {A : stavi_depth A ≤ r} → Bool
  -- (the rank_type determines which formulas hold).
  -- Points in the cut have rank_types that miss some formula.
  -- Points in the complement have rank_types that contain all formulas.
  -- If no single formula fails cofinally in the cut, then each failing
  -- formula has its failures bounded above. The maximum of finitely
  -- many bounds gives a point above which ALL formulas hold → contradiction.

  -- Step 3: Extract the single D
  -- By Classical.choice + the cofinal failure argument:
  obtain ⟨D, hD_depth, hD_holds_above, hD_fails_cofinal⟩ :
    ∃ D : StaviFormula, stavi_depth D ≤ r ∧
      (∀ p : N.carrier, p ∉ gamma.cut →
        stavi_temporal_truth N atomMap p D) ∧
      ¬ (∃ t ∈ gamma.cut, ∀ u, t ≤ u → u ∈ gamma.cut →
        stavi_temporal_truth N atomMap u D) := by
    -- Pigeonhole argument here
    sorry  -- See Section 4 for detailed proof sketch

  -- Step 4: Construct r_definable_gap
  refine ⟨D, hD_depth, Or.inr ?_⟩
  constructor
  · -- D holds on initial segment of complement
    obtain ⟨p₀, hp₀⟩ := gamma.nonempty
    -- complement has no min, so pick any point not in cut
    have h_compl : ∃ q, q ∉ gamma.cut := by
      by_contra h; push_neg at h
      exact gamma.proper (Set.eq_univ_of_forall h)
    obtain ⟨q, hq⟩ := h_compl
    exact ⟨q, hq, fun u hu hle => hD_holds_above u hu⟩
  · -- D does NOT hold on any final segment of cut
    exact hD_fails_cofinal
```

---

## 4. The Pigeonhole Argument in Detail

### 4.1 Finiteness of Distinguishing Formulas

**Claim**: The set of "rank-r truth patterns" is finite.

More precisely, the function `p ↦ rank_type N atomMap r (extendPoint p)` takes values in `Set StaviFormula`, but the number of distinct values is finite (bounded by `nfCount (Fintype.card sig.preds) r 1`).

**Status in codebase**: `NormalForm sig r 1` is `Fintype` (NormalForm.lean line 178). The connection between `NormalForm` and `rank_type` is partial -- the infrastructure exists at the FO level (`nf_characteristic`, `nf_exists_unique`) but the bridge to StaviFormula rank_types is not yet built.

### 4.2 Alternative: Direct Cofinal Extraction Without Pigeonhole

We can avoid the full NormalForm-to-StaviFormula bridge by using a different argument:

**Claim**: There exists D : StaviFormula with stavi_depth D <= r such that D holds at all complement points and fails cofinally in the cut.

**Proof**: The predicate `continuation_holds a_n y' (extendPoint p)` unfolds to:
```
∀ A, stavi_depth A ≤ r → (∀ v ∈ (a_n, y')_mu, A^mu(v)) → A(p)
```

Its negation at p is:
```
∃ A, stavi_depth A ≤ r ∧ (∀ v ∈ (a_n, y')_mu, A^mu(v)) ∧ ¬ A(p)
```

For each p in gamma.cut, let `D_p` be a formula witnessing the failure (via Classical.choose).

**Key claim**: There exists D such that `{p ∈ gamma.cut | D_p = D up to equiv}` is cofinal in gamma.cut.

**Proof of key claim by contradiction**: Suppose for each candidate D (of which there are finitely many up to equivalence), the set where D_p = D is bounded above in gamma.cut. Let `t_D` be an upper bound for each D. Since there are finitely many D (up to equivalence), let `t_max` be the maximum of all `t_D`. Then for any p in gamma.cut with p > t_max, the formula `D_p` does not equal any of the finitely many candidates -- contradiction.

**But wait**: D_p ranges over ALL StaviFormula of depth <= r, which is an INFINITE set. The pigeonhole only works if we quotient by equivalence.

### 4.3 The Right Finiteness Statement

We don't need full formula equivalence. We need: at each point p, the truth value of every formula of depth <= r is determined. The "truth pattern" at p is precisely `rank_type N atomMap r (extendPoint p)`. Two points with the same rank_type agree on all formulas of depth <= r (by `rank_type_eq_iff`, EFGames.lean line 901).

So the pigeonhole is over rank_types, not formulas. The number of distinct rank_types is at most `2^(number of inequivalent formulas of depth <= r)`, which is finite.

**Missing infrastructure**: We need `{ rank_type N atomMap r (extendPoint p) | p : N.carrier }` to be a finite set. This requires a finiteness result for rank_types.

### 4.4 Simpler Approach: Avoid Pigeonhole Entirely

Actually, we can simplify significantly. Instead of the pigeonhole, observe:

The formula `C'` from GHR93 (report 18, Section 2.3) is:
```
C' = neg C ∨ K^-(neg C)
```
where `K^-(X) = neg (S(top, neg X))`, all of which are encodable as a single StaviFormula of depth `stavi_depth(C) + 2 ≤ r + 2`.

**But** this has depth r+2, and we need depth <= r for gap_definable_on_right. So C' does not work directly.

Hmm. Let's re-read `r_definable_gap` -- it requires `stavi_depth D ≤ r`. And C has depth ≤ r. Can C itself serve as D?

**Yes, C can serve as D.** The continuation formula C itself has depth ≤ r (it's one of the formulas in Phi, which all have depth ≤ r). But C is a Prop-level predicate, not a single formula... unless we can realize it as one.

### 4.5 The Actual Single Formula: Using the Interval Type Directly

Re-reading the GHR93 argument more carefully:

The split point c is `inf{t : C holds on (t,y)}` where `C = X_{(a_n, y')}`. In the GHR93 framework, `X_{(a_n, y')}` is a single formula (a disjunction over the finitely many rank-r types realized in (a_n, y')). Each individual rank-r type `X_v` is also a single formula (the conjunction of all formulas in rank_type(v), which is finite by NormalForm finiteness).

So `C = X_{(a_n, y')}` IS a single StaviFormula of depth ≤ r. The continuation_holds predicate is the SEMANTIC condition "C(t) holds", where C is this specific formula.

If we can construct this single formula C, then:
- gap_definable_on_right with D = C is immediate from the infimum properties (Section 2.2)
- stavi_depth C ≤ r because C is a Boolean combination of rank-r formulas

**The construction of C as a single formula requires**:
1. Enumerating all rank-r types realized in (a_n, y') -- finite by NormalForm
2. For each type, constructing the characteristic formula -- finite conjunction
3. Taking the disjunction

This requires the NormalForm → StaviFormula bridge and a formula construction procedure.

---

## 5. Recommended Approach: Option B (Custom Infimum, Prop-Level C)

### 5.1 Why This Avoids the Formula Construction Problem

Instead of constructing C as a single formula, we:

1. Define `continuation_holds` as a Prop-level predicate
2. Define S_C using this predicate
3. Construct the infimum of S_C in ExtendedCarrier (either a point or a gap)
4. When the infimum is a gap, prove r-definability by extracting D from the rank_type change

For step 4, we use the fact that at the gap boundary, rank_types change. Since there are finitely many rank_types (by NormalForm finiteness), Classical.choose can extract a single formula D.

### 5.2 Lean Code Skeleton for the Full Construction

```lean
/-! ### Infimum Construction for S_C on ExtendedCarrier -/

/-- The continuation predicate (Prop-level, not a formula). -/
private def cont_holds {sig : MonadicSignature}
    {N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} (a_n y' : ExtendedCarrier N atomMap r)
    (t : ExtendedCarrier N atomMap r) : Prop :=
  ∀ A : StaviFormula, stavi_depth A ≤ r →
    (∀ v, a_n < v → v < y' → mu_holds v →
      stavi_temporal_truth_mu N atomMap r v A) →
    stavi_temporal_truth_mu N atomMap r t A

/-- The set S_C = {t ∈ [x',y'] : cont_holds holds at all mu-points in (t,y')}. -/
private def S_C {sig : MonadicSignature}
    {N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} (x' y' a_n : ExtendedCarrier N atomMap r) :
    Set (ExtendedCarrier N atomMap r) :=
  { t | inClosedInterval x' y' t ∧
    ∀ u, t < u → u ≤ y' → mu_holds u → cont_holds a_n y' u }

/-- S_C is nonempty: y' ∈ S_C (the condition is vacuous). -/
private theorem S_C_nonempty ... : (S_C x' y' a_n).Nonempty := by
  refine ⟨y', ⟨hx'y', le_refl y'⟩, ?_⟩
  intro u hy'u _huy' _hmu
  -- hy'u : y' < u contradicts huy' : u ≤ y'
  exact absurd (lt_of_lt_of_le hy'u _huy') (lt_irrefl u) -- adjust

/-- S_C is upward-closed within [x',y']. -/
private theorem S_C_upward_closed ... :
    ∀ t ∈ S_C x' y' a_n, ∀ t', t ≤ t' → inClosedInterval x' y' t' →
      t' ∈ S_C x' y' a_n := by
  intro t ht t' htt' ht'_int
  refine ⟨ht'_int, fun u ht'u huy' hmu => ht.2 u (lt_of_le_of_lt htt' ht'u) huy' hmu⟩

/-- The infimum cut: carrier points that are lower bounds of S_C. -/
private def inf_cut (S : Set (ExtendedCarrier N atomMap r)) : Set N.carrier :=
  { p | ∀ s ∈ S, (extendPoint p : ExtendedCarrier N atomMap r) ≤ s }

/-- When inf S_C is not a carrier point, it defines a Gap. -/
private theorem inf_cut_is_gap
    (h_not_point : ¬ ∃ p : N.carrier, IsGLB (S_C x' y' a_n)
      (extendPoint p : ExtendedCarrier N atomMap r)) :
    -- The cut is a valid Gap
    ∃ gamma : Gap N.carrier,
      gamma.cut = inf_cut (S_C x' y' a_n) := by
  -- Need to verify all Gap axioms:
  -- 1. nonempty: x' ≤ all s ∈ S_C, so if x' = extendPoint p for some p,
  --    then p ∈ inf_cut. If x' is a gap, then all carrier points below
  --    x' are in inf_cut.
  -- 2. proper: y' ∈ S_C, so if q ∉ gamma.cut, then extendPoint q > inf,
  --    hence q is not a lower bound. Needs ∃ q not in cut.
  -- 3. downward_closed: if p is a lower bound and q ≤ p, then q is too.
  -- 4. no_sup: if p = sup of cut and p ∈ cut, then extendPoint p = GLB of S_C
  --    as a point, contradicting h_not_point.
  -- 5. complement_no_min: if q = min of complement, then extendPoint q is
  --    the GLB of S_C as a point, contradicting h_not_point.
  sorry  -- See Section 5.3 for detailed proof

/-- The gap from inf S_C is r-definable. -/
private theorem inf_gap_is_r_definable
    {gamma : Gap N.carrier}
    (h_cut : gamma.cut = inf_cut (S_C x' y' a_n))
    -- Above gap: all complement points satisfy cont_holds
    (h_above : ∀ p : N.carrier, p ∉ gamma.cut →
      ∀ A, stavi_depth A ≤ r →
        (∀ v, a_n < v → v < y' → mu_holds v →
          stavi_temporal_truth_mu N atomMap r v A) →
        stavi_temporal_truth N atomMap p A)
    -- Below gap: each cut point fails some rank-r formula
    (h_below : ∀ p : N.carrier, p ∈ gamma.cut →
      ∃ A, stavi_depth A ≤ r ∧
        (∀ v, a_n < v → v < y' → mu_holds v →
          stavi_temporal_truth_mu N atomMap r v A) ∧
        ¬ stavi_temporal_truth N atomMap p A)
    : r_definable_gap N atomMap gamma r := by
  -- Step 1: By contradiction, find D failing cofinally in cut
  -- Suppose for all D of depth ≤ r, the failure set is bounded
  -- in gamma.cut. Then ∃ t ∈ gamma.cut above all failure sets.
  -- At t and above: all rank-r formulas that hold on (a_n, y')
  -- also hold at t, so cont_holds holds at t. But then t should
  -- be in S_C, contradicting t being below inf S_C.
  --
  -- The finiteness needed: there are finitely many rank_types,
  -- so "for all D" really means "for finitely many patterns".
  --
  -- Use NormalForm finiteness: the rank_type at a point is
  -- determined by its NormalForm characteristic. There are
  -- Fintype.card (NormalForm sig r 1) many distinct rank_types.
  -- Each rank_type determines a finite set of "failing formulas".
  -- Taking the sup over finitely many bounded sets gives a bound.
  sorry  -- Core pigeonhole argument, ~100-150 lines
```

### 5.3 Estimated Line Counts

| Component | Lines | Risk | Dependencies |
|-----------|-------|------|-------------|
| `cont_holds`, `S_C` definitions | 20-30 | Low | None |
| `S_C_nonempty`, `S_C_upward_closed` | 30-50 | Low | Order infrastructure |
| `inf_cut` definition + properties | 40-60 | Low | `extendPoint_le_iff` |
| `inf_cut_is_gap` (5 Gap axioms) | 100-150 | Medium | `h_not_point`, order lemmas |
| `inf_gap_is_r_definable` (pigeonhole) | 100-150 | **Medium-High** | NormalForm finiteness bridge |
| `infimum_in_extended_carrier` (wrapper) | 50-80 | Medium | Cases: point vs gap |
| Integration with `obtain_split_point_props` | 80-120 | Medium | Refactoring existing code |
| **Total** | **420-640** | **Medium** | |

### 5.4 Missing Infrastructure

1. **NormalForm-to-rank_type finiteness bridge** (CRITICAL, ~80-120 lines):
   Need to prove that the image of `rank_type N atomMap r` over carrier points is finite. This follows from NormalForm finiteness but requires connecting the FO normal form theory to StaviFormula truth. Status: partial -- `NormalForm sig r 1` is `Fintype` but the semantic connection to `rank_type` is not proved.

   **Alternative**: Instead of the full NormalForm bridge, prove directly that `{ A : StaviFormula | stavi_depth A ≤ r } / (logical equivalence at r)` is finite. Or use the fact that `rank_type` values are subsets of `{ A | stavi_depth A ≤ r }` and these subsets are determined by a finite number of "generators" (the NormalForm atoms).

   **Simplest alternative**: Just prove that there are finitely many distinct `rank_type` values using the NormalForm characteristic function. Each point has a unique NormalForm (by `nf_exists_unique`), and NormalForm is Fintype, so the number of distinct rank_types is bounded.

2. **Gap axiom verification for inf_cut** (~100-150 lines):
   Need to verify all 5 Gap axioms. The trickiest are `no_sup` and `complement_no_min`, which both reduce to: "if the infimum were achieved at a point, that contradicts `h_not_point`."

3. **stavi_truth_mu_at_point** (ALREADY PROVED at EFGames.lean line 1973):
   Bridges mu-relativized truth at extendPoint with standard truth on M.carrier. This is essential for converting between gap_definable (which uses standard truth) and the S_C condition (which uses mu-relativized truth).

---

## 6. Approach Comparison

| Approach | Lines | Risk | Key Difficulty |
|----------|-------|------|----------------|
| A: Full CCL on ExtendedCarrier | 750-1300 | High | General completeness is hard |
| **B: Custom infimum + prop-level C** | **420-640** | **Medium** | Pigeonhole needs NF bridge |
| C: Build C as single formula | 600-900 | High | NormalForm→StaviFormula encoding |
| D: Avoid infimum entirely | N/A | **Impossible** | d=a_bwd(n) is provably wrong approach |

**Recommendation: Approach B.** The custom infimum construction avoids general completeness infrastructure, and the Prop-level C avoids the formula construction problem. The main challenge (the pigeonhole/finiteness argument for gap r-definability) is unavoidable in any approach.

---

## 7. File Locations and Key Types

| Definition/Theorem | File | Line | Status |
|---|---|---|---|
| `Gap` structure | EFGames.lean | 257 | Proved |
| `r_definable_gap` | EFGames.lean | 334 | Proved |
| `gap_definable_on_right` | EFGames.lean | 322 | Proved |
| `gap_definable_on_left` | EFGames.lean | 308 | Proved |
| `ExtendedCarrier` | EFGames.lean | 356 | Proved |
| `extendedLinearOrder` | EFGames.lean | 377 | Proved |
| `rank_type` | EFGames.lean | 883 | Proved |
| `rank_type_eq_iff` | EFGames.lean | 901 | Proved |
| `mem_rank_type_iff` | EFGames.lean | 919 | Proved |
| `neg_mem_rank_type_of_not` | EFGames.lean | 933 | Proved |
| `stavi_truth_mu_at_point` | EFGames.lean | 1973 | Proved |
| `extendPoint_le_iff` | EFGames.lean | 478 | Proved |
| `extendPoint_lt_iff` | EFGames.lean | 1916 | Proved |
| `extendPoint_le_gap_iff` | EFGames.lean | 487 | Proved |
| `gap_ext` | EFGames.lean | 276 | Proved |
| `gap_cuts_total` | EFGames.lean | 283 | Proved |
| `NormalForm` Fintype | NormalForm.lean | 178 | Proved |
| `nf_exists_unique` | NormalForm.lean | 281 | Proved |
| `SplitPointProps` | ExpressivenessGeneral.lean | 137 | Proved (struct) |
| `obtain_split_point_props` | ExpressivenessGeneral.lean | 202 | Partial (sorries) |
| `left_formula_gap_detection` | EFGames.lean | 2404 | Sorry |
| `right_formula_gap_detection` | EFGames.lean | 2423 | Sorry |

---

## 8. Blocking Dependencies and Build Order

### Phase 1: Definitions (~50 lines)
- `cont_holds`, `S_C`, `inf_cut` definitions
- No dependencies beyond existing infrastructure

### Phase 2: S_C Properties (~80 lines)
- `S_C_nonempty`, `S_C_upward_closed`
- Depends on: Phase 1

### Phase 3: Gap Construction (~150 lines)
- `inf_cut_is_gap`: verify all 5 Gap axioms
- Depends on: Phase 2, `h_not_point` hypothesis

### Phase 4: r-Definability (~150 lines)
- `inf_gap_is_r_definable`: the pigeonhole argument
- Depends on: Phase 3, NormalForm finiteness bridge
- **BLOCKER**: Needs the NormalForm-to-rank_type finiteness connection

### Phase 5: Integration (~120 lines)
- `infimum_in_extended_carrier`: case split point vs gap
- Refactor `obtain_split_point_props` to use infimum-based c/d
- Depends on: Phase 4

### Critical Path

```
Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5
                                  ↑
                          NormalForm bridge (parallel)
```

The NormalForm bridge can be built in parallel and is the only non-trivial dependency.
