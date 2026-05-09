# Teammate A Findings: Discreteness and ℤ Embedding (Round 3)

**Task**: 117 — Verify X is discrete without density elimination, find ℤ embedding
**Date**: 2026-05-08
**Focus**: Is the limit domain discrete? How to embed into ℤ?

## Key Findings

### 1. The Density Case Is a SEPARATE Counterexample Kind

`PotentialCounterexampleKind` (CE:570-575) has 5 variants:
```lean
inductive PotentialCounterexampleKind : Type where
  | c4_forward    -- C4: Until backward counterexample
  | c4_backward   -- C4': Since backward counterexample
  | c5_forward    -- C5: Until forward witness
  | c5_backward   -- C5': Since forward witness
  | density       -- Density: insert midpoint between adjacent x < y
```

The `.density` case is completely independent of C4a/C5a. It is the ONLY case that requires `SetConsistent (χ.g pc.x pc.y)` (the sorry at CE:3570). Removing `.density` from the enum removes the sorry.

### 2. CRITICAL PROBLEM: The Limit Domain May NOT Be Discrete Without Density

**C4a (forward) checks ALL pairs x < y, not just adjacent pairs** (CE:2917: "Now checks ALL pairs x < y, not just adjacent pairs"). When resolving a C4a counterexample between x and y, the implementation finds an adjacent pair (w, w_next) between x and y and inserts a midpoint z = (w + w_next)/2 using Lemma 2.6 splitting.

This midpoint insertion from C4a CAN cascade:
1. Initially x and y are adjacent. C4a inserts z between them.
2. Now (x, z) and (z, y) are adjacent pairs.
3. A C4a counterexample ¬U(γ', δ') ∈ f(x), δ' ∈ f(z) could exist.
4. This triggers another midpoint insertion between x and z.
5. This can cascade indefinitely.

**Whether the limit is dense or discrete depends on the formula content:**
- If the MCS values at inserted points happen to not contain any new C4a-triggering formulas, cascading stops and gaps persist (discrete).
- If new C4a-triggering formulas appear at every inserted point, cascading continues and fills every gap (dense).

**Burgess's paper does NOT claim discreteness for the base logic.** Burgess says (p. 372): "A finite chronicle cannot in general satisfy all cases of C4, C5" — the omega limit is needed. He does not say the limit is discrete. He just works on whatever X the construction produces.

**However**, Burgess's Claim 2.11 (truth lemma) works on X regardless of whether X is dense or discrete. The truth lemma only needs C0-C5 to be satisfied.

### 3. Where Density Is Actually Used in the Current Code

Density (`limit_dom_dense`) is used in exactly two places:

1. **`limitDomSubtype_denselyOrdered`** (ChronicleToCountermodel.lean:98-106): Instance for `DenselyOrdered (LimitDomSubtype A h_mcs)`, used by `cantor_iso` via `Order.iso_of_countable_dense`.

2. **C2' at the limit** (ChronicleConstruction.lean:963-991): The limit-level C2' property (BurgessR3Maximal for adjacent pairs) is currently proved VACUOUSLY — "the limit domain is dense, so there are no adjacent pairs." The proof uses `no_adjacent_in_dense` with `limit_dom_dense`.

**If we remove density, we MUST provide a non-vacuous proof of C2' at the limit.** This is the hidden cost of removing density. Adjacent pairs WILL exist in the limit domain, and we need `BurgessR3Maximal (limit_f x) (limit_g x y) (limit_f y)` for each adjacent pair (x, y).

### 4. C2' at the Limit Without Density: Is It Provable?

For each adjacent pair (x, y) in the limit domain, we need `BurgessR3Maximal (limit_f x) (limit_g x y) (limit_f y)`.

Since (x, y) are adjacent in the LIMIT domain, there are no limit-domain points between them. So `limit_g(x, y) = Set.univ` (vacuously, all formulas hold at all points between x and y since there are none).

`BurgessR3Maximal A (Set.univ) C` means:
- `ClosedUnderDerivation (Set.univ)` — TRUE (Set.univ contains everything, so closure is trivial)
- `∀ β, Set.univ ⊆ B → ...` — maximality condition with B ⊇ Set.univ means B = Set.univ

Actually, `BurgessR3Maximal` is defined at ChronicleTypes.lean. Let me check what it requires:

The key question is: does `BurgessR3Maximal (limit_f x) (Set.univ) (limit_f y)` hold?

`Set.univ` is CUD (trivially). It IS maximal among CUD sets with the r-relation property, because Set.univ is the largest possible set. The r-relation `r(A, Set.univ, C)` requires `∀ β ∈ Set.univ, U(γ, β) ∈ A` for all γ ∈ C, i.e., `∀ β, U(γ, β) ∈ A` for all γ ∈ C. This is a strong condition that may or may not hold.

**Wait** — `R(A, B, C)` means B is MAXIMAL with respect to r(A, —, C). If `B = Set.univ`, then B IS maximal (nothing is larger). But r(A, Set.univ, C) requires `∀ γ ∈ C, U(γ, β) ∈ A` for ALL β. This is NOT always true. So `BurgessR3Maximal (limit_f x) (Set.univ) (limit_f y)` requires verifying the r-relation holds for Set.univ, which is a very strong condition.

**This is problematic.** If `limit_g(x,y) = Set.univ` for adjacent (x,y), and `BurgessR3Maximal` requires the r-relation to hold, then we need `r(limit_f(x), Set.univ, limit_f(y))` which means `∀ β, ∀ γ ∈ limit_f(y), U(γ, β) ∈ limit_f(x)`. This is extremely unlikely to hold in general.

**However**, we need to check how C2' is actually threaded through the omega chain. The omega chain maintains C2' at every finite stage. At finite stages, every adjacent pair has a proper g-value (from BurgessR3Maximal via Zorn). The question is whether adjacent pairs that persist into the limit retain their finite-stage g-values.

Actually — the limit_g is defined as `{φ | ∀ y ∈ limit_dom, x < y' → y' < y → φ ∈ limit_f(y')}`. For a pair (x, y) that is adjacent in the limit but NOT adjacent at any finite stage (because they were separated at finite stages but the intermediate points were... no, that doesn't make sense — once a point is added it stays).

If (x, y) is adjacent in the LIMIT, then NO point was ever inserted between them in ANY finite stage. So (x, y) was adjacent in all finite stages where both x and y were present. At those finite stages, g_n(x, y) was set by Lemma 2.6 splitting, and BurgessR3Maximal holds for g_n(x, y).

But `limit_g(x, y) ≠ g_n(x, y)` in general — limit_g is defined by the universal quantification over limit_dom points between x and y, while g_n is the finite-stage g-value. When (x,y) is adjacent in the limit, limit_g(x,y) = Set.univ, but g_n(x,y) for the finite stage where (x,y) was created could be a proper subset.

**THIS IS THE CORE ISSUE**: The limit g-function (`limit_g`) and the finite-stage g-functions (`g_n`) diverge for adjacent pairs that persist to the limit. The limit_g becomes Set.univ (vacuously), but the finite-stage g_n was a proper CUD set with BurgessR3Maximal. The current code sidesteps this by making ALL pairs non-adjacent (via density), so limit_g is always "correct."

### 5. The ℤ Embedding: Mathlib's `orderIsoIntOfLinearSuccPredArch`

Mathlib provides exactly the theorem needed (in `Mathlib.Order.SuccPred.LinearLocallyFinite`):

```lean
noncomputable def orderIsoIntOfLinearSuccPredArch
    [SuccOrder ι] [PredOrder ι] [IsSuccArchimedean ι]
    [NoMaxOrder ι] [NoMinOrder ι] [hι : Nonempty ι] :
    ι ≃o ℤ
```

Requirements:
- `SuccOrder ι` — a successor function exists
- `PredOrder ι` — a predecessor function exists
- `IsSuccArchimedean ι` — iterating succ reaches any larger element
- `NoMaxOrder ι` — no maximum (already proved for LimitDomSubtype)
- `NoMinOrder ι` — no minimum (already proved for LimitDomSubtype)
- `Nonempty ι` — non-empty (already proved for LimitDomSubtype)

**For LimitDomSubtype to satisfy these**: The domain would need to be discrete (every element has an immediate successor and predecessor). This is exactly the `SuccOrder` and `PredOrder` requirement. If the domain IS discrete, `IsSuccArchimedean` follows from countability + linear order.

**If the domain is NOT guaranteed discrete** (i.e., C4a cascading might make it dense), this embedding does not apply.

### 6. Burgess 1982 on Discreteness

Re-reading Burgess carefully (p. 372-373):

- Lemma 2.9 (C4a counterexample): inserts z "lying between x and y" — specifically z = x + y/2 or x + x'/2 in the proof.
- Lemma 2.10 (C5a counterexample): inserts y "after x" — specifically y = x + 1 in Case n=0.
- The construction builds (f_n, g_n) by "repeated application of 2.9 and 2.10."
- Section 1.6 lists "Density: F'⊤" as a VARIANT requiring extra axioms.
- The base construction does NOT add density points explicitly.

However, Burgess does NOT claim the base construction produces a discrete order. He works with whatever X the construction gives. The truth lemma (Claim 2.11) works on any linear order.

**The key Burgess insight**: The construction uses rationals as an ambient space for CONVENIENCE (midpoints z = (x+y)/2 are easy to compute). The resulting X could be dense or discrete depending on how C4a counterexamples cascade. For the DENSE variant, Burgess would add density elimination to ensure X is dense. For the base logic, X is "whatever the counterexample elimination produces."

### 7. Alternative: Could X Be Made Discrete by Construction?

Instead of using z = (x+y)/2 for C4a insertions, we could use a construction that avoids creating cascading density. For example:
- Use integer coordinates: start at 0, insert at integer locations
- Maintain a discrete invariant at every finite stage

But this would require changing the PointInsertion infrastructure, which is sorry-free and working. A large refactor.

## Summary and Recommendation

**The premise that X is naturally discrete for the base logic is UNCERTAIN.** C4a midpoint insertions can cascade, potentially making X dense in the limit. Burgess does not claim discreteness.

**Two approaches remain viable:**

1. **Keep the current construction, extend to all of Rat (Round 1 approach)**: Define f(q) for non-domain rationals via Lindenbaum extension, use D = Rat with existing parametric infrastructure. The density case becomes dead code (we don't need X to be dense, just Rat).

2. **Restructure to use finite-stage g-values at the limit**: Instead of `limit_g(x,y) = {φ | ∀ w ∈ limit_dom, x < w → w < y → φ ∈ limit_f(w)}`, use the finite-stage g-values directly: `limit_g(x,y) = g_n(x,y)` for the stage n where (x,y) became adjacent. This preserves BurgessR3Maximal at adjacent pairs. Then the domain can be anything (dense or discrete) and C2' holds non-vacuously.

**Approach 2 is more faithful to Burgess** but requires reworking the limit g-function definition and all its downstream lemmas.

## Confidence Level

**HIGH** on the density case identification and removal mechanics.

**HIGH** on the ℤ embedding theorem existence in Mathlib.

**MEDIUM** on whether X is actually discrete — the cascading C4a issue means X's structure depends on formula content, not just the construction method.

**Key finding that undermines the "X is discrete" premise**: C4a counterexample elimination inserts midpoints that can cascade, and Burgess does not claim discreteness for the base logic. The embedding X ≅ ℤ requires proving X is discrete, which may not hold.
