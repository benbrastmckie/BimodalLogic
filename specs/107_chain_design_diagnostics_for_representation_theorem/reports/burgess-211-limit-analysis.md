# Burgess 1982 Section 2.11 — Claim 2.11 & Limit Construction: Exact Mapping to Codebase

**Research Agent**: lean-research-agent
**Date**: 2026-05-03
**Status**: Critical deviations flagged; exact implementation path identified

---

## 1. Burgess Section 2.11 — Exact Text and Mapping

### 1.1 Burgess's Text (p. 373)

> **2.11 Claim**: (+) in fact holds for all α.
>
> **Proof**: By induction on the complexity of α. As a sample we treat the case α = U(β, γ).
>
> If α ∈ f(x), then by C5a there is a y ∈ X with x < y and γ ∈ f(y) and β ∈ g(x, y). If z ∈ X and x < z < y, then by C3 we have g(x, y) ⊆ f(z), whence β ∈ f(z). By induction hypothesis y ∈ V(γ) and z ∈ V(β) for any z with x < z < y, whence x ∈ V(α).
>
> If instead ∼α ∈ f(x), then for any y ∈ X with x < y and y ∈ V(γ), we have by induction hypothesis γ ∈ f(y), and hence by C4a there must be a z ∈ X with x < z < y and ∼β ∈ f(z), whence by induction hypothesis z ∉ V(β). It follows that x ∉ V(α) as required.

### 1.2 Exact Code Mapping

| Burgess Element | Our Code | Match? |
|---|---|---|
| `X = union dom f_n` | `limit_dom A h_mcs` (line 482) | ✓ Match |
| `f = union f_n` | `limit_f A h_mcs` (line 490) | ✓ Match |
| `g = union g_n` | `limit_g A h_mcs` (line 837) | ✗ **Deviation** |
| Valuation `(+)` | `cantor_f` + BFMCS truth evaluation | ✓ Match |
| C5a at limit | `limit_satisfies_c5_weak` (line 569) | ✗ Weak only |
| C4a at limit | `limit_satisfies_c4` (line 743) | ✓ Match |
| C3 at limit | `limit_c3` (line 852) | ✓ Match (by construction) |
| Truth lemma proof | Comments only (lines 1194–1210); **no theorem proved** | ✗ Missing |

**Key observation**: Burgess says `g = union g_n`. Our code defines `limit_g` directly as an intersection of limit_f values, NOT as a union of finite-stage g_n. This is a structural deviation discussed in Section 4.

---

## 2. Burgess's Limit Construction — What He Prescribes

### 2.1 The Three Unions (Burgess p. 373, para before 2.11)

Burgess:
> We now let X be the union of the sets dom f_n, and f and g the unions of the f_n and g_n respectively. Then (f, g) satisfies C0–C5.

**What this means mathematically**:

1. **Union of domains**: `X = ⋃_n dom(f_n)`. Since each is finite and they're nested, X is countable.

2. **Union of point functions**: `f(x) = f_n(x)` for some/any n with x ∈ dom(f_n). This is well-defined because `f_{n+1}` agrees with `f_n` on old points (extension property).

3. **Union of interval functions**: `g(x,y) = g_n(x,y)` for some/any n with x,y ∈ dom(f_n) AND the pair (x,y) present in stage-n's definition.

**Critical about g**: At finite stage n, g_n is defined primarily for adjacent pairs (via BurgessR3Maximal / C2'). For non-adjacent pairs, g_n is defined by C3 from adjacent pairs. When a new point z is inserted between x and y:
- New adjacent pairs (x,z) and (z,y) get NEW g-values (B', B'' from Lemma 2.6).
- The OLD pair (x,y) is no longer adjacent.
- For any triple involving z, C3 DETERMINES the new g-values.
- For the updated g(x,y), Burgess says: "let C3 determine the other values of g'(w,z) and g'(z,w)". This IMPLICITLY means g(x,y) must be UPDATED to equal g(x,z) ∩ f(z) ∩ g(z,y).

### 2.2 How C3 is Maintained at Finite Stages

Burgess Lemma 2.9 (C4 elimination, Case n=0):
> Set f'(z) = D. Set g'(x,z) = B', g'(z,y) = B'', and **let C3 determine the other values of g'(w,z) and g'(z,w)**.

**Our code's deviation**: In `CounterexampleElimination.lean` (lines 903–923, density case), g is completely unchanged (`χ.g` is preserved verbatim). In C5 elimination (line 187), g is also unchanged. There is NO "C3 determination" step when inserting new points.

**Flag**: This is a **critical deviation**. Our finite-stage chronicles likely violate C3 after point insertion, though C3 may still hold vacuously for triples involving the new point if old g-values happen to satisfy the identity.

### 2.3 How C3 at the Limit Works for Burgess

At the limit:
- The domain X is dense (no adjacent pairs).
- C2' is vacuously true.
- C3 still applies to ALL triples x < y < z in X.
- For any x < z in X, there are infinitely many intermediate points y₁, y₂, ...
- g(x,z) = g(x,y₁) ∩ f(y₁) ∩ g(y₁,z)
         = g(x,y₁) ∩ f(y₁) ∩ [g(y₁,y₂) ∩ f(y₂) ∩ g(y₂,z)]
         = ... (iterated intersection)

Since X is countable and dense, g(x,z) ends up being the intersection of f(y) for ALL y between x and z, plus the g-values at infinitesimal adjacent pairs (which don't exist, so C3 reduces to an infinite intersection).

Our `limit_g` (line 837):
```lean
def limit_g x z := { φ | ∀ y ∈ limit_dom, x < y → y < z → φ ∈ limit_f y }
```
This IS mathematically equivalent to the infinite C3 intersection. So at the LIMIT, our definition coincides with Burgess's union-of-g_n construction.

**Verification**: `limit_c3` (line 852) proves this explicitly:
```lean
theorem limit_c3 : limit_g x z = limit_g x y ∩ limit_f y ∩ limit_g y z
```
Proof: both sides equal `{φ | ∀ w ∈ limit_dom, x < w < z → φ ∈ limit_f w}`.

**Conclusion**: The deviation is at FINITE STAGES only. At the limit, our `limit_g` is correct and equivalent to Burgess.

---

## 3. The Truth Lemma (Claim 2.11) — What Burgess Proves

### 3.1 Forward Direction: U(ξ,η) ∈ f(x) → Semantic Until

**Burgess's chain**:
1. U(ξ,η) ∈ f(x)
2. C5a: ∃y > x with η ∈ f(y) and ξ ∈ g(x,y)
3. For any z with x < z < y: C3 → g(x,y) ⊆ f(z) → ξ ∈ f(z)
4. By IH: y ∈ V(η), z ∈ V(ξ) for all intermediate z
5. Therefore x ∈ V(U(ξ,η))

**Our code's blocker**: `limit_satisfies_c5_weak` (line 569) gives:
```lean
∃ y ∈ limit_dom, x < y ∧ η ∈ limit_f y
```
It does NOT guarantee ξ ∈ g(x,y).

The missing theorem is `limit_satisfies_c5_full`:
```lean
∃ y ∈ limit_dom, x < y ∧ η ∈ limit_f y ∧
  ∀ z ∈ limit_dom, x < z → z < y → ξ ∈ limit_f z
```

**Key insight for proving `limit_satisfies_c5_full` WITHOUT finite-stage g-tracking**:

Since our `limit_g` is defined as `{φ | ∀ w, x < w < z → φ ∈ limit_f w}`, the guard condition ξ ∈ limit_f(z) for ALL intermediate z is EXACTLY what limit_g captures. So if we can show:

```
U(ξ,η) ∈ limit_f(x) → ∃y > x [η ∈ limit_f(y) ∧ ξ ∈ limit_g(x,y)]
```

then by `limit_c3_interval_subset_point` (line 877):
```lean
limit_g x z ⊆ limit_f y  for x < y < z
```
we get ξ ∈ limit_f(y) for all intermediate y automatically.

**So the REAL missing piece is**: showing that the C5 witness y from finite-stage elimination has the property that ξ ∈ limit_g(x,y). This requires linking the finite-stage g_n(x,y) (where ξ was placed during C5 elimination) to the limit intersection.

### 3.2 Backward Direction: ¬U(ξ,η) ∈ f(x) → Semantic ¬Until

**Burgess's chain**:
1. ¬U(ξ,η) ∈ f(x)
2. Suppose for contradiction x ∈ V(U(ξ,η))
3. Then ∃y > x with η ∈ f(y) (semantically) and ξ ∈ f(z) for all x < z < y
4. By IH: η ∈ f(y)
5. C4a applies: ¬U(ξ,η) ∈ f(x), η ∈ f(y), x < y → ∃z, x < z < y, ¬ξ ∈ f(z)
6. But from (3), ξ ∈ f(z) for all intermediate z — contradiction.

**Our code**: `limit_satisfies_c4` (line 743) is already proved sorry-free and gives exactly the C4a property needed. The backward direction is therefore UNBLOCKED once the forward direction works.

### 3.3 What Our Truth Lemma Should Look Like

A direct transcription of Burgess Claim 2.11 for our limit chronicle:

```lean
theorem claim_2_11 (α : Formula) (x : Rat) (hx : x ∈ limit_dom A h_mcs) :
    α ∈ limit_f A h_mcs x ↔ truth_at_model α x
```

But we don't have a `truth_at_model` for the limit chronicle directly. Instead, the truth lemma is proved via the Cantor isomorphism in `ChronicleToCountermodel.lean`. The three coherence conditions (restricted_tc, restricted_buc, restricted_fuc) ARE the truth lemma components.

---

## 4. Critical Deviations from Burgess

### Deviation 1: Finite-Stage g-Value Maintenance (SEVERITY: HIGH)

**Burgess**: When inserting point z between x and y, g'(x,y) is UPDATED by C3.

**Our code**: g is preserved unchanged in all elimination functions.
- C5 elimination (line 187): `χ.g` preserved verbatim
- Density insertion (line 903): `χ.g` preserved verbatim
- `g_agrees` (line 698): only guarantees g unchanged for OLD pairs

**Evidence**: In density case:
```lean
exact { val := ⟨fun q => if q = z then χ.f pc.x else χ.f q, χ.g, insert z χ.dom⟩, ...
```
No update to g(x,y), g(x,z), or g(z,y).

**Impact**: C3 may be violated at finite stages after point insertion. However:
- C3 is not explicitly checked in the finite-stage invariant (only c0 and c2' are tracked).
- At the limit, our `limit_g` definition bypasses finite-stage C3 entirely.

**Verification required**: Does `c3_interval_subset_point` hold at finite stages? Yes (if C3 holds). Does C3 actually hold after elimination? UNSURE — needs proof or counterexample.

### Deviation 2: g = Union of g_n vs. limit_g as Intersection (SEVERITY: MEDIUM)

**Burgess**: g at the limit is the union (increasing limit) of the finite g_n values.

**Our code**: `limit_g` is defined as intersection of limit_f values, not as a limit of g_n.

**Why this is OK**: As argued in Section 2.3, the two definitions are mathematically equivalent at the dense limit. Burgess's union-of-g_n, iterated through C3, converges to exactly `{φ | ∀ intermediate y, φ ∈ f(y)}`.

**Why this is a deviation**: The proof paths differ. Burgess proves C5 at the limit by: "g_n(x,y) contains ξ at some finite stage, and g is the union, so ξ ∈ g(x,y)". Our code must prove: "the C5 witness y is such that ξ appears in all intermediate f(z), so by definition ξ ∈ limit_g(x,y)".

### Deviation 3: c2' Threading Through omega_chain (SEVERITY: HIGH)

**Burgess**: At finite stages, C2' (maximality at adjacent pairs) is maintained.

**Our code**: `omega_chain` only carries `c0` as invariant (line 253):
```lean
noncomputable def omega_chain (A : Set Formula) (h_mcs : SetMaximalConsistent A) :
    (n : Nat) → { χ : Chronicle // χ.c0 }
```

The `EliminationResult` structure includes a `c2'` field (line 702), but ALL 10 call sites are `sorry` (lines 756, 768, 794, 806, 834, 845, 872, 883, 918, 931).

**Impact**: Without c2', we cannot prove that g-values at adjacent pairs are maximal, and therefore cannot prove that ξ ∈ g_n(x,y) persists when the pair (x,y) is later split by new points.

### Deviation 4: Cantor Isomorphism Instead of Direct Limit Domain (SEVERITY: LOW)

**Burgess**: The model is built directly on the countable union X ⊆ ℚ.

**Our code**: The limit domain is mapped through a Cantor isomorphism to ALL of ℚ. The countermodel uses `cantor_f` (line 202) and `rooted_cantor_fmcs` (line 306).

**Assessment**: This is an implementation detail, not a mathematical deviation. The Cantor isomorphism preserves order structure, and truth is invariant under order isomorphism. This is acceptable.

---

## 5. What to Implement — Following Burgess Exactly

### 5.1 Immediate Priority: Close c2' Sorries (Phase 4)

**Files**: `CounterexampleElimination.lean` (lines 756, 768, 794, 806, 834, 845, 872, 883, 918, 931)

**What Burgess does**:
- C5 forward (Lemma 2.4): New adjacent pair (x, y) gets g(x,y) = B where B is from Lemma 2.4 and satisfies BurgessR3Maximal(f(x), B, C).
- C4 forward (Lemma 2.6): Old adjacent pair (x,y) is split into (x,z) and (z,y). g'(x,z) = B' and g'(z,y) = B'' where B', B'' come from Lemma 2.6 and satisfy maximality.
- Density: New adjacent pairs need maximal DCSs. Since density doesn't use a specific δ, use `burgessR3Maximal_from_g_content_sub` to construct from g_content.

**Implementation path**:
1. Modify `eliminate_C5_counterexample` to return the interval BCS B along with the witness.
2. Define g'(x,y) = B for the new adjacent pair.
3. Prove BurgessR3Maximal for the new pair using Lemma 2.4 output.
4. For C4: use Lemma 2.6 output B', B'' for new adjacent pairs.
5. Update `EliminationResult` to carry g-assignments for new pairs.

### 5.2 Thread c2' Through omega_chain (Phase 4e)

**File**: `ChronicleConstruction.lean`

**What Burgess does**: The sequence `(f_n, g_n)` is in F (the set of chronicles satisfying C0–C3), so each stage satisfies C2'.

**What to implement**:
1. Change `omega_chain` return type:
   ```lean
   (n : Nat) → { χ : Chronicle // χ.c0 ∧ χ.c2' }
   ```
2. Base case: singleton chronicle satisfies c2' vacuously (already proved as `singleton_c2'` at line 116).
3. Step case: use `EliminationResult.c2'` from the elimination function.

### 5.3 Prove limit_satisfies_c5_full (Phase 5a)

**File**: `ChronicleConstruction.lean` (new theorem, ~line 593)

**Burgess's approach**:
1. U(ξ,η) ∈ limit_f(x) means U(ξ,η) ∈ f_n(x) for some finite n.
2. At some stage m ≥ n, the counterexample (x, ξ, η, c5_forward) is processed.
3. C5 elimination gives witness y with η ∈ f_{m+1}(y) and ξ ∈ g_{m+1}(x,y).
4. By c2' maximality, g-values persist: for all stages k ≥ m+1, if (x,y) remains adjacent, ξ ∈ g_k(x,y).
5. When (x,y) is split by new points, C3 propagates ξ into all sub-intervals.
6. At the limit, ξ ∈ g(x,y) where g is the union of g_k.
7. By C3 at the limit, ξ ∈ f(z) for all intermediate z.

**Our adapted approach** (since we don't track finite g_n to limit):
1. U(ξ,η) ∈ limit_f(x) → U(ξ,η) ∈ f_n(x) for some n.
2. At stage m ≥ n where the counterexample is processed, elimination gives witness y with η ∈ f_{m+1}(y).
3. **KEY**: At stage m+1, the witness y is ADJACENT to x (since y is placed beyond all current points). So by c2', g_{m+1}(x,y) satisfies BurgessR3Maximal.
4. **CRITICAL LEMMA NEEDED**: `burgessR3_implies_guard_in_interval`: If BurgessR3Maximal(f(x), g(x,y), f(y)) and U(ξ,η) ∈ f(x), then ξ ∈ g(x,y).
   - Proof: By maximality, g(x,y) contains all formulas consistent with the r-relation. Since U(ξ,η) ∈ f(x), the r-relation requires that for all γ ∈ f(y), U(ξ,γ) ∈ f(x). In particular, if η ∈ f(y), then ξ must be in g(x,y) for the interval to properly propagate the Until obligation. Wait, need to verify this...
   - Actually, the r-relation says: for all γ,δ, if U(γ,δ) ∈ f(x), then δ ∈ g(x,y) OR (γ ∈ g(x,y) AND U(γ,δ) ∈ g(x,y)). Since η = δ ∈ f(y) and g(x,y) ⊆ f(y) is NOT guaranteed at adjacent pairs... hmm.
   - Let me think again. The BurgessR3 relation says: for all β ∈ g(x,y), for all γ ∈ f(y), U(β,γ) ∈ f(x). This is not directly about ξ.
   - For C5, the witness construction (Lemma 2.4) ensures g(x,y) contains β (from the BX5 self-accumulation). Specifically, in the proof of Lemma 2.4, the B constructed satisfies r(f(x), B, f(y)), and by maximality, B is as large as possible. The key question: does ξ ∈ B?
   - Looking at Burgess's C5 elimination: "We can apply 2.4 to A = f(x) obtaining B, C. Set y = x + 1, f'(y) = C, g'(x,y) = B". The lemma 2.4 construction ensures η ∈ C and β ∈ B for the appropriate β. But which β? In the C5 case for U(ξ,η), β needs to be ξ (the guard).
   - Actually, the guard placement in g is NOT automatic from Lemma 2.4. Lemma 2.4 gives a B that is R-maximal with β ∈ B. For C5, β is the guard. But WHICH guard? In our open-guard semantics, the Until U(ξ,η) requires ξ at intermediate points. The r-relation (as we've defined it with obligation propagation) is about formulas that MUST continue to hold in the interval.

This reveals a **fundamental gap**: Our `BurgessR3` definition (`burgessR3`) says:
```lean
def burgessRSet A B C := ∀ β ∈ B, ∀ γ ∈ C, Formula.untl β γ ∈ A
```
This means: B is a set of formulas such that for any β in B and any γ in C, U(β,γ) is in A. It does NOT say that the specific guard ξ (from U(ξ,η)) is in B.

For the C5 witness to carry the guard, we need a STRONGER property: if U(ξ,η) ∈ A, then the R-maximal B with respect to A and C must contain ξ. Is this true?

Let me check: By BX5 (self_accumulation), U(ξ,η) ∈ A implies U(ξ ∧ U(ξ,η), η) ∈ A. If B is R-maximal and doesn't contain ξ, can it be extended? If ξ is consistent with the r-relation when added to B, then B wasn't maximal. So we need to show: adding ξ to B preserves burgessR3(f(x), B ∪ {ξ}, f(y)).

This requires a lemma: `guard_in_r_maximal`: If U(ξ,η) ∈ A and B is R3Maximal(A, B, C) with η ∈ C, then ξ ∈ B.

**THIS LEMMA DOES NOT CURRENTLY EXIST** in our codebase. It is a research gap.

### 5.4 Alternative: Bypass Finite-Stage g-Tracking (Contingency)

Since the finite-stage g-tracking is complex and the limit_g definition is clean, we can try a direct limit argument for `limit_satisfies_c5_full`:

1. U(ξ,η) ∈ limit_f(x)
2. `limit_satisfies_c5_weak` gives y > x with η ∈ limit_f(y)
3. **Claim**: For all z ∈ limit_dom with x < z < y, ξ ∈ limit_f(z).
4. Proof by contradiction: Suppose some intermediate z has ξ ∉ limit_f(z). Then ξ.neg ∈ limit_f(z) (by MCS negation completeness).
5. By `limit_satisfies_c4` (C4 at the limit): ¬U(ξ,η) ∈ limit_f(x), ξ.neg ∈ limit_f(z), and x < z... wait, C4 requires ¬U(ξ,η) ∈ f(x) AND η ∈ f(z). But we have U(ξ,η) ∈ f(x), not ¬U(ξ,η).

This direct approach FAILS. We cannot derive a contradiction because C4 only applies to ¬U formulas.

**Another approach** (from plan v54 contingency):
Since `limit_g(x,y) = {φ | ∀ z ∈ (x,y) ∩ limit_dom, φ ∈ limit_f(z)}`, the guard ξ ∈ limit_f(z) for all intermediate z is EQUIVALENT to ξ ∈ limit_g(x,y). So:
```lean
limit_satisfies_c5_full ↔ ∃y > x, η ∈ limit_f(y) ∧ ξ ∈ limit_g(x,y)
```

So we need to show: U(ξ,η) ∈ limit_f(x) → ∃y > x, η ∈ limit_f(y) ∧ ξ ∈ limit_g(x,y).

Now, `limit_g(x,y)` is defined as the set of formulas holding at ALL intermediate points. If we can show that the C5 witness y is such that ξ holds at all points between x and y, we're done.

But why would ξ hold at all intermediate points? Because:
1. At the finite stage where y is created, it is placed beyond all existing points. So there are NO intermediate points between x and y at that stage.
2. When new points are later inserted between x and y, they come from C4 or density elimination.
3. **Density insertions**: New midpoint z = (x+y)/2 gets f(z) = f(x) (in density case) or some D (in C4 case). If f(x) contains ξ (does it?), then ξ ∈ f(z).
   - Wait, does f(x) contain ξ? We only know U(ξ,η) ∈ f(x). Under open guard, U(ξ,η) does NOT imply ξ ∈ f(x).
   - But by BX5, U(ξ,η) ∈ f(x) implies U(ξ ∧ U(ξ,η), η) ∈ f(x), which implies ξ ∧ U(ξ,η) ∈ f(x) by BX9? No, BX9 is removed...
   - Under open guard, U(ξ,η) → ξ is INVALID. So we cannot conclude ξ ∈ f(x).
4. **C4 insertions**: If a point z is inserted because of a C4 counterexample involving some other formulas, f(z) is an MCS constructed via Lemma 2.6. There is no guarantee that ξ ∈ f(z).

This reveals another gap: we cannot guarantee that newly inserted points between x and y contain ξ, unless ξ is specifically required by the insertion construction.

**Wait** — but Burgess's construction DOES guarantee this! How?

Re-read Burgess's C3: "g(x,z) = g(x,y) ∩ f(y) ∩ g(y,z)". If ξ ∈ g(x,y) (from the initial C5 construction), then when a new point w is inserted between x and y:
- g(x,y) is updated to g(x,w) ∩ f(w) ∩ g(w,y).
- For this to contain ξ, we need ξ ∈ g(x,w), ξ ∈ f(w), and ξ ∈ g(w,y).

But g(x,w) and g(w,y) are constructed from the r-relation to maximize content. And f(w) is an MCS. The C3 constraint forces f(w) to contain ξ (since ξ must be in the intersection). So f(w) MUST contain ξ.

**This is the magic**: C3 at finite stages ENSURES that when a point is inserted between x and y, and ξ ∈ g(x,y), the new f(w) contains ξ. Our code does NOT enforce this because we don't update g(x,y) when inserting new points.

### 5.5 The Path Forward

Given the above analysis, there are two paths to `limit_satisfies_c5_full`:

**Path A (Burgess-faithful)**: Fix finite-stage g-maintenance.
1. When inserting point z between x and y, define new g'(x,z) and g'(z,y) appropriately.
2. Update g'(x,y) by C3: g'(x,y) = g'(x,z) ∩ f(z) ∩ g'(z,y).
3. Maintain c2' for new adjacent pairs.
4. Then at the limit, g(x,y) is the decreasing limit of g_n(x,y), and ξ ∈ g_n(x,y) for the stage where C5 created the witness.
5. This gives ξ ∈ g(x,y) at the limit.
6. By C3 at the limit, ξ ∈ f(z) for all intermediate z.

**Path B (Direct limit argument)**: Use our `limit_g` definition.
1. U(ξ,η) ∈ limit_f(x)
2. C5 witness exists: y > x with η ∈ limit_f(y)
3. `limit_g(x,y)` is defined as intersection of intermediate f-values.
4. We need to show ξ ∈ limit_g(x,y), i.e., ξ ∈ limit_f(z) for all z ∈ (x,y) ∩ limit_dom.
5. For any such z: z entered the domain at some stage. At that stage, z is placed relative to x and y.
6. If z is placed by density: f(z) = f(some_existing_point). Need to trace whether that point contains ξ.
7. If z is placed by C4: f(z) = D from Lemma 2.6. Need to show ξ ∈ D.
8. If z is placed by C5: f(z) = C from Lemma 2.4. Need to show ξ ∈ C.

Path B seems harder because it requires case analysis on WHY each intermediate point was inserted.

**Recommendation**: Follow Path A (Burgess-faithful). The changes needed:
1. Modify chronicle elimination functions to properly update g by C3.
2. Prove c2' for new adjacent pairs.
3. Then `limit_satisfies_c5_full` follows by: g-values persist at adjacent pairs, and when split, C3 propagates them to sub-intervals.

---

## 6. Implementation Details for Phase 4 and 5

### 6.1 Phase 4b: c2' for C5 Elimination

In `eliminate_C5_counterexample` (line 167), currently:
```lean
refine ⟨⟨fun q => if q = y then C else χ.f q, χ.g, insert y χ.dom⟩, ...
```

Burgess requires: g'(x,y) = B from Lemma 2.4.

Modified construction:
```lean
refine ⟨⟨fun q => if q = y then C else χ.f q,
          fun a b => if a = x ∧ b = y then B else χ.g a b,
          insert y χ.dom⟩, ...
```

Then prove `c2'` for the new pair (x,y) using Lemma 2.4's output.

### 6.2 Phase 4c: c2' for C4 Elimination

In `eliminate_C4_counterexample`, Burgess:
> Set f'(z) = D. Set g'(x,z) = B', g'(z,y) = B''.

Current code needs g-update for new pairs (x,z) and (z,y), and C3-update for old pair (x,y).

### 6.3 Phase 5a: limit_satisfies_c5_full

Once c2' is maintained at finite stages, the proof of `limit_satisfies_c5_full` follows Burgess's pattern:

```lean
theorem limit_satisfies_c5_full (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (x : Rat) (hx : x ∈ limit_dom A h_mcs) (ξ η : Formula)
    (h_until : Formula.untl ξ η ∈ limit_f A h_mcs x) :
    ∃ y ∈ limit_dom A h_mcs, x < y ∧ η ∈ limit_f A h_mcs y ∧
      ∀ z ∈ limit_dom A h_mcs, x < z → z < y → ξ ∈ limit_f A h_mcs z := by
  -- 1. Find stage n where x ∈ dom(n) and U(ξ,η) ∈ f_n(x)
  obtain ⟨n₀, hn₀⟩ := hx
  -- 2. Find stage m ≥ n₀ where counterexample (x, ξ, η) is processed
  obtain ⟨m, hm_ge, hm_eq⟩ := counterexample_enum_surjective_above ⟨x, 0, ξ, η, .c5_forward⟩ n₀
  -- 3. At stage m+1, C5 elimination gives witness y with η ∈ f_{m+1}(y)
  obtain ⟨y, hy_dom, hy_lt, hy_η⟩ := omega_chain_c5_witness ...
  -- 4. By c2' at stage m+1, adjacent pair (x,y) has BurgessR3Maximal
  have h_c2' := (omega_chain_c2' A h_mcs (m+1))
  -- 5. From BurgessR3Maximal and U(ξ,η) ∈ f(x), derive ξ ∈ g_{m+1}(x,y)
  have h_ξ_g : ξ ∈ (omega_chain_val A h_mcs (m+1)).g x y :=
    guard_in_r_maximal h_c2' h_until ...
  -- 6. g persists and propagates: ξ ∈ limit_g(x,y) by monotonicity
  have h_ξ_limit_g : ξ ∈ limit_g A h_mcs x y := ...
  -- 7. By C3 at limit, ξ ∈ limit_f(z) for all intermediate z
  refine ⟨y, ⟨m+1, hy_dom⟩, hy_lt, hy_η, fun z hz hxz hzy => ...⟩
```

**Critical missing lemma**: `guard_in_r_maximal` needs to be proved or identified.

### 6.4 Phase 5b: FUC/FSC in ChronicleToCountermodel

The FUC sorry at line 615 and FSC sorry at line 619 become straightforward once `limit_satisfies_c5_full` is available. The proof template in the plan v54 (lines 449–463) is correct:

1. Transfer U(φ,ψ) from cantor point to limit_f coordinate via `cantor_iso.symm`.
2. Apply `limit_satisfies_c5_full`.
3. Transfer witness y and guard property back to rational coordinates via `cantor_iso`.
4. `limit_c3_interval_subset_point` propagates guard to all intermediate cantor points.

---

## 7. Summary of Findings

### What Matches Burgess
- Limit domain as union of finite domains ✓
- Limit point function as union of finite f_n ✓
- C3 at limit defined by three-way intersection ✓ (though via different construction)
- C4/C4' satisfaction via counterexample elimination ✓
- Truth lemma proof structure ✓ (in comments)

### What Deviates from Burgess
1. **Finite-stage g-maintenance**: Our code preserves g unchanged during elimination; Burgess updates g by C3. **FLAGGED** — this is the root cause blocking `limit_satisfies_c5_full`.
2. **limit_g definition**: Defined as intersection of f-values rather than union of g_n. **ACCEPTABLE** — mathematically equivalent at the dense limit.
3. **c2' not threaded through omega_chain**: Only c0 is maintained. **FLAGGED** — 10 `sorry` sites in `CounterexampleElimination.lean`.
4. **Missing guard-in-maximal lemma**: No proof that R3Maximal interval sets contain the guard formula from Until obligations. **FLAGGED** — research gap.

### Exact Implementation Path
1. **Phase 4a-d**: Close the 10 c2' sorries by updating g in elimination functions per Burgess's C3-determination rule.
2. **Phase 4e**: Thread c2' through omega_chain (add `∧ χ.c2'` to return type).
3. **Research gap**: Prove or locate `guard_in_r_maximal`: If BurgessR3Maximal(f(x), g(x,y), f(y)) and U(ξ,η) ∈ f(x) and η ∈ f(y), then ξ ∈ g(x,y).
4. **Phase 5a**: Prove `limit_satisfies_c5_full` using c2' + guard lemma + C3 propagation.
5. **Phase 5b**: Close FUC/FSC sorries using `limit_satisfies_c5_full` with Cantor transfer.

### Estimated Effort
- c2' closure (10 sorries): 8–12 hours
- guard_in_r_maximal research/proof: 4–6 hours
- limit_satisfies_c5_full: 4–6 hours
- FUC/FSC closure: 2–3 hours
- Total: **18–27 hours** (consistent with plan v54 estimate of 24–33 hours for the critical path)

---

## 8. Appendix: Line References

| File | Line | Content |
|---|---|---|
| `Burgess_1982_...md` | 236–247 | Claim 2.11 text |
| `Burgess_1982_...md` | 238–239 | Limit construction paragraph |
| `ChronicleConstruction.lean` | 482 | `limit_dom` definition |
| `ChronicleConstruction.lean` | 490 | `limit_f` definition |
| `ChronicleConstruction.lean` | 837 | `limit_g` definition |
| `ChronicleConstruction.lean` | 852 | `limit_c3` proof (sorry-free) |
| `ChronicleConstruction.lean` | 569 | `limit_satisfies_c5_weak` (weak only) |
| `ChronicleConstruction.lean` | 253 | `omega_chain` carries only `c0` |
| `CounterexampleElimination.lean` | 756 | c2' sorry: C5 forward elimination |
| `CounterexampleElimination.lean` | 768 | c2' sorry: C5 forward no-elim |
| `CounterexampleElimination.lean` | 794 | c2' sorry: C5 backward elimination |
| `CounterexampleElimination.lean` | 806 | c2' sorry: C5 backward no-elim |
| `CounterexampleElimination.lean` | 834 | c2' sorry: C4 forward elimination |
| `CounterexampleElimination.lean` | 845 | c2' sorry: C4 forward no-elim |
| `CounterexampleElimination.lean` | 872 | c2' sorry: C4 backward elimination |
| `CounterexampleElimination.lean` | 883 | c2' sorry: C4 backward no-elim |
| `CounterexampleElimination.lean` | 918 | c2' sorry: density elimination |
| `CounterexampleElimination.lean` | 931 | c2' sorry: density no-elim |
| `ChronicleToCountermodel.lean` | 615 | FUC sorry (forward Until coherence) |
| `ChronicleToCountermodel.lean` | 619 | FSC sorry (forward Since coherence) |
| `ChronicleTypes.lean` | 369–375 | `c2'` definition (BurgessR3Maximal at adjacent pairs) |
| `ChronicleTypes.lean` | 383–386 | `c3` definition (three-way intersection) |

---

*Report compiled from direct source inspection following Burgess 1982 text.*
