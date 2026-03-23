# Task 34: Teammate A Findings - Provability Analysis of predecessor_f_step_axiom

## Key Findings

### 1. The Axiom Statement (Mathematical Precision)

The axiom in `SuccExistence.lean:652-655` states:

```lean
axiom predecessor_f_step_axiom
    (u : Set Formula) (h_mcs : SetMaximalConsistent u)
    (h_P_top : Formula.some_past (Formula.neg Formula.bot) ∈ u) :
    f_content (predecessor_from_deferral_seed u h_mcs h_P_top) ⊆ u ∪ f_content u
```

**In mathematical terms**:
- Let `u` be an MCS with `P(T) ∈ u` (seriality assumption)
- Let `v = predecessor_from_deferral_seed u` (the Lindenbaum extension of `h_content(u) ∪ pastDeferralDisjunctions(u)`)
- **Goal**: For all `φ`, if `F(φ) ∈ v`, then either `φ ∈ u` or `F(φ) ∈ u`

This ensures that F-obligations in the predecessor are "bounded" by the successor u.

### 2. The h/g Duality Infrastructure

**What exists** (`WitnessSeed.lean:322-381`):

1. **`g_content_subset_implies_h_content_reverse`**: If `g_content(M) ⊆ M'`, then `h_content(M') ⊆ M`
   - Uses `temp_a`: `φ → G(P(φ))`

2. **`h_content_subset_implies_g_content_reverse`**: If `h_content(M) ⊆ M'`, then `g_content(M') ⊆ M`
   - Uses `past_temp_a`: `φ → H(F(φ))`

**Key mechanism**: The h/g duality works through the interaction axioms:
- `temp_a: φ → G(P(φ))` - present truth implies universal future of past
- `past_temp_a: φ → H(F(φ))` - present truth implies universal past of future

### 3. Why h/g Duality Does NOT Extend to f/p Content

**The fundamental asymmetry**:

| Duality | Transfer Direction | Axiom Used |
|---------|-------------------|------------|
| g→h | `g_content(u) ⊆ v` implies `h_content(v) ⊆ u` | `φ → G(P(φ))` |
| h→g | `h_content(u) ⊆ v` implies `g_content(v) ⊆ u` | `φ → H(F(φ))` |
| f→p | **None** | No axiom `F(φ) → ?` exists |
| p→f | **None** | No axiom `P(φ) → ?` exists |

**Why no f/p duality exists**:

1. **Existential operators are witnesses, not constraints**: The axioms `temp_a` and `past_temp_a` work because they constrain *universal* operators. For example, `φ → G(P(φ))` says that if φ holds now, then G(P(φ)) must hold - this provides leverage because G is universal.

2. **No forcing axiom for F**: There is no axiom of the form `F(φ) → ?` that would allow us to derive membership constraints from F-membership. The existential future F(φ) only asserts existence of a witness, not universal properties.

3. **Duality mismatch**: The f/g duality `f_content_iff_not_neg_in_g_content` (`φ ∈ f_content(M) ↔ ¬φ ∉ g_content(M)`) is about *negation*, not about *transfer between worlds*.

### 4. The Predecessor Construction Analysis

**Predecessor deferral seed** (`SuccExistence.lean:157-158`):
```
predecessor_deferral_seed(u) = h_content(u) ∪ pastDeferralDisjunctions(u)
```

where `pastDeferralDisjunctions(u) = {φ ∨ P(φ) | P(φ) ∈ u}`.

**Lindenbaum extension**:
The predecessor `v = lindenbaumMCS_set(predecessor_deferral_seed(u), h_cons)` is a maximal consistent set extending the seed.

**What the seed guarantees**:
1. `h_content(u) ⊆ v` (by `lindenbaumMCS_set_extends`)
2. Each `pastDeferralDisjunction φ ∈ v` for `P(φ) ∈ u`

**What the seed does NOT guarantee**:
- **F-content is unconstrained**: The seed contains NO formulas involving F (existential future). The Lindenbaum extension can freely add any F(φ) that is consistent with the seed.

### 5. Proof Attempts and Why They Fail

**Attempt 1: Via f/g duality**

Suppose `F(φ) ∈ v`. By `f_content_iff_not_neg_in_g_content`:
- `F(φ) ∈ v` iff `¬φ ∉ g_content(v)` iff `G(¬φ) ∉ v`

We know `g_content(v) ⊆ u` from `h_content_subset_implies_g_content_reverse`.
- This tells us: if `G(ψ) ∈ v`, then `ψ ∈ u`

**The gap**: From `G(¬φ) ∉ v`, we cannot conclude anything about u. The duality goes the wrong direction - it tells us what G-formulas in v imply about u, not what absence of G-formulas in v implies.

**Attempt 2: Contrapositive via G content**

Suppose neither `φ ∈ u` nor `F(φ) ∈ u`. Then:
- `¬φ ∈ u` (by MCS negation completeness)
- `G(¬φ) ∈ u`? NO - we cannot conclude this without additional axioms

The T-axiom gives `G(ψ) → ψ`, not `ψ → G(ψ)`.

**Attempt 3: Via past_temp_a**

If `¬φ ∈ u`, then by `past_temp_a`: `H(F(¬φ)) ∈ u`.
- So `F(¬φ) ∈ h_content(u) ⊆ v`

This gives us `F(¬φ) ∈ v`. But having `F(¬φ) ∈ v` does NOT imply `F(φ) ∉ v`. An MCS can contain both `F(ψ)` and `F(¬ψ)` (different witnesses at different future times).

**Attempt 4: Via seriality chain**

The seriality axiom `P(T) ∈ u` ensures past exists, but doesn't constrain which F-formulas can enter v.

### 6. Mathematical Analysis: Is the Axiom True?

**Semantic argument (from SuccExistence.lean:639-644)**:

In a discrete linear order, if `v` is the immediate predecessor of `u` (i.e., `Succ(v, u)`), and `F(φ) ∈ v`, then the witness for `F(φ)` must be:
- Either `u` (the immediate successor), giving `φ ∈ u`
- Or some later world (beyond u), giving `F(φ) ∈ u` (deferred)

**Why this doesn't translate to a proof**:

The semantic argument relies on the **frame structure** (discrete linear order with u as immediate successor of v). But:

1. The Lindenbaum construction is **syntax-driven**: It adds formulas to achieve maximal consistency, without reference to a specific frame.

2. The resulting MCS `v` is **not yet interpreted** in any frame - it's a raw syntactic object.

3. To prove `f_content(v) ⊆ u ∪ f_content(u)`, we would need to show that the enumeration-based Lindenbaum process cannot add F-formulas that violate this. But the enumeration is arbitrary (Classical.choose), so we have no control.

### 7. What Would Be Needed to Prove It

**Option A: Constrained Lindenbaum construction**

Instead of arbitrary Lindenbaum extension, use a construction that tracks F-formula witnesses and ensures they align with the successor u. This would require:
- An F-content-aware extension procedure
- Proof that consistency allows such selective extension
- Significant new infrastructure

**Option B: f/p transfer lemma (new axiom or derived)**

A lemma like:
```lean
theorem f_content_transfer_from_h_seed
    (M M' : Set Formula) (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_seed : h_content M ⊆ M') :
    f_content M' ⊆ M ∪ f_content M
```

This is essentially the axiom restated. To prove it, we would need an axiom like `φ → H(G(φ))` or `F(φ) → P(F(φ))`, neither of which is in standard temporal logic.

**Option C: Accept as semantic axiom**

Accept that this property is **semantically valid** in discrete linear frames but **not syntactically derivable** from the MCS closure properties alone. The axiom bridges the gap between syntax and semantics.

## Proof Attempts (Code-Level)

### Attempted Proof Strategy 1: Via g_content duality

```lean
theorem predecessor_f_step_attempted
    (u : Set Formula) (h_mcs : SetMaximalConsistent u)
    (h_P_top : Formula.some_past (Formula.neg Formula.bot) ∈ u) :
    f_content (predecessor_from_deferral_seed u h_mcs h_P_top) ⊆ u ∪ f_content u := by
  intro φ h_F_φ_in_pred
  let v := predecessor_from_deferral_seed u h_mcs h_P_top
  let h_mcs_v := predecessor_from_deferral_seed_mcs u h_mcs h_P_top
  -- h_F_φ_in_pred : F(φ) ∈ v
  -- We know: h_content(u) ⊆ v, hence g_content(v) ⊆ u
  have h_g_v_sub_u : g_content v ⊆ u :=
    h_content_subset_implies_g_content_reverse u v h_mcs h_mcs_v
      (predecessor_satisfies_h_persistence u h_mcs h_P_top)
  -- Goal: φ ∈ u ∨ F(φ) ∈ u
  -- From F(φ) ∈ v, by duality: G(¬φ) ∉ v
  have h_G_neg_not_in_v : Formula.all_future (Formula.neg φ) ∉ v := by
    intro h_contra
    -- If G(¬φ) ∈ v, then ¬φ ∈ g_content(v) ⊆ u
    have h_neg_φ_in_u : Formula.neg φ ∈ u := h_g_v_sub_u h_contra
    -- Also F(φ) ∈ v means ¬G(¬φ) ∈ v
    have h_F_eq : Formula.some_future φ = Formula.neg (Formula.all_future (Formula.neg φ)) := rfl
    rw [h_F_eq] at h_F_φ_in_pred
    exact set_consistent_not_both h_mcs_v.1 _ h_contra h_F_φ_in_pred
  -- STUCK: We know G(¬φ) ∉ v, but this doesn't help us conclude φ ∈ u or F(φ) ∈ u
  sorry
```

**Failure point**: Having `G(¬φ) ∉ v` tells us nothing about u.

### Attempted Proof Strategy 2: Contrapositive

```lean
-- Suppose φ ∉ u and F(φ) ∉ u
-- Then ¬φ ∈ u (negation completeness)
-- And G(¬φ) ∈ u? NO - cannot derive without 4-axiom or similar
-- STUCK
```

**Failure point**: No axiom derives G-membership from raw membership.

## Missing Infrastructure

### Minimal Lemma That Would Close the Gap

```lean
/-- Hypothetical lemma: F-content of h-seed extension is bounded by original MCS -/
theorem h_seed_extension_f_content_bounded
    (u v : Set Formula) (h_mcs_u : SetMaximalConsistent u) (h_mcs_v : SetMaximalConsistent v)
    (h_seed_extends : h_content u ⊆ v) :
    f_content v ⊆ u ∪ f_content u
```

This is exactly the axiom. No smaller lemma appears to suffice.

### What Axiom Would Make It Provable

If we had an axiom of the form:
```
φ → H(G(φ))  -- "Present truth implies past universal future"
```

Then from `¬φ ∈ u`, we could derive `H(G(¬φ)) ∈ u`, so `G(¬φ) ∈ h_content(u) ⊆ v`.
With `G(¬φ) ∈ v`, we get `F(φ) ∉ v`, contradiction.

**But** `φ → H(G(φ))` is NOT a valid axiom in temporal logic (it's only valid in degenerate frames).

## Confidence Level

**High** confidence that `predecessor_f_step_axiom` is NOT provable from current infrastructure.

**Justification**:
1. Systematic analysis of h/g duality shows it only transfers universal operators
2. No axiom or lemma in the codebase connects existential content to world relationships
3. Multiple proof attempts all reach the same dead end: knowing what's NOT in v doesn't constrain what's in u
4. The existing `predecessor_f_step_axiom` is marked with extensive documentation acknowledging this gap (SuccExistence.lean:586-651)
5. The symmetric `successor_p_step_axiom` was identified as needed in Task 40 research with identical analysis

## Recommendations

1. **Accept as necessary axiom**: The axiom captures a semantic property of discrete linear frames that doesn't follow from MCS closure alone.

2. **Strengthen documentation**: The semantic justification in SuccExistence.lean:639-644 is sound. Consider adding a formal comment about why syntactic proof is blocked.

3. **Consider architectural alternatives**: If axiom-freedom is required:
   - Constrained Lindenbaum construction (significant new infrastructure)
   - Direct semantic model construction bypassing MCS (different completeness approach)

4. **Note symmetry with successor_p_step_axiom**: Task 40 identified the need for a symmetric axiom `successor_p_step_axiom`. Both axioms have the same justification and the same proof blockers.
