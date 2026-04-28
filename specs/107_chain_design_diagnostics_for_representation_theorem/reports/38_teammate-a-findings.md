# Teammate A Findings: D0 Seed Reconstruction and B_sub_A Gap

**Task**: 107 — Burgess chronicle construction for BX representation theorem
**Focus**: Phase 1 blockers — D0 seed set reconstruction and B_sub_A_of_burgessR3 invalidity
**Date**: 2026-04-28

## Key Findings

### 1. B_sub_A_of_burgessR3 Is Genuinely IRRECOVERABLE Under Open Guard

The removed `B_sub_A_of_burgessR3` (PointInsertion.lean, pre-removal line 777) proved:

```
burgessR3(A, B, C) → B ⊆ A
```

Its proof was simple: pick any γ₀ ∈ C (e.g., ⊤). For β ∈ B, burgessRSet gives `untl(β, γ₀) ∈ A`. By `until_guard_in_mcs`: `β ∈ A`. The crux was the `until_guard` axiom: `(φ U ψ) → φ`.

**Under open guard, this derivation has no substitute.** The available axioms that extract information from `untl(β, γ₀)` are:
- **BX10** (`until_F`): `untl(β, γ₀) → F(γ₀)` — gives information about γ₀, not β
- **BX5** (`self_accum_until`): `untl(β, γ₀) → untl(β ∧ untl(β, γ₀), γ₀)` — enriches the guard, doesn't extract β
- **BX4** (`connect_future`): `φ → G(P(φ))` — needs φ ∈ A as input, circular if we're trying to prove β ∈ A
- **BX6** (`absorb_until`): operates on nested Until structure, irrelevant here
- **BX7** (`linear_until`): needs two Until formulas, not one

**No chain of these axioms can derive `β ∈ A` from `untl(β, γ₀) ∈ A`.** The fundamental issue: under open guard `(t,s)`, having `β U γ₀` at time t means β holds on the open interval (t,s), but **β need not hold at t itself**. This is a semantic fact, not a proof gap — the STATEMENT `B ⊆ A` is **false** under open guard semantics.

**Counterexample sketch**: Consider a discrete order {0, 1, 2}. Let β be "atomic p" and γ₀ be ⊤. At time 0, p U ⊤ holds with witness s=1 and guard interval (0,1) which is empty (no points strictly between 0 and 1 in {0,1,2}). So `untl(p, ⊤) ∈ f(0)` but p need not be in f(0). The guard is vacuously satisfied.

**Confidence**: HIGH — this is a genuine mathematical impossibility, not a missing proof technique.

### 2. B_sub_C_of_burgessR3 Is Similarly Irrecoverable

The mirror `B_sub_C_of_burgessR3` used `since_guard_in_mcs` which is equally invalid. Same reasoning applies: `β S α ∈ C` does not imply `β ∈ C` under open guard.

### 3. The D0 Seed Set Definition Can Be Restored But Its Consistency Proof CANNOT

The original D0 seed (pre-removal line 726 of PointInsertion.lean):

```lean
def burgess_D0 (A B C : Set Formula) (delta : Formula) : Set Formula :=
  {φ | ∃ α ∈ A, ∃ β ∈ B, φ = Formula.snce β α} ∪
  B ∪
  ({delta.neg} : Set Formula) ∪
  {φ | ∃ β ∈ B, ∃ γ ∈ C, φ = Formula.untl β γ}
```

The membership lemmas (`B_subset_burgess_D0`, `neg_delta_in_burgess_D0`, `untl_in_burgess_D0`, `snce_in_burgess_D0`) are purely set-theoretic and can be trivially restored.

**However**, the consistency proof (`burgess_D0_consistent`, pre-removal line 820) was `sorry` even before removal. The plan's Phase 1.2 outlined a proof strategy that depended on `burgess_D0_elem_in_A_or_C` (pre-removal line 802), which in turn depended on `B_sub_A_of_burgessR3` and `B_sub_C_of_burgessR3`. Since both are irrecoverable, the **entire consistency argument collapses**.

The strategy was: if some finite L ⊆ D0 derives ⊥, separate the components:
- B elements → in A (by B ⊆ A) ✗ **INVALID**
- Until formulas untl(β, γ) → in A (by burgessRSet) ✓
- Since formulas snce(β, α) → in C (by burgessRSetSince) ✓
- neg(delta) → handled separately

Without B ⊆ A and B ⊆ C, elements of B itself cannot be located in either A or C. The elements of B are **the core problem** — they live in the interval DCS, which under open guard is genuinely distinct from both endpoint MCSs.

### 4. What Remains Viable from Phase 1 Infrastructure

From PointInsertion.lean (all sorry-free, untouched by task 113):

| Theorem | Line | Status | Notes |
|---------|------|--------|-------|
| `dc_delta_B_controlled` | 491 | ✓ sorry-free | Decomposes DC({δ}∪B) elements |
| `BurgessR3Maximal_extension_fails` | 545 | ✓ sorry-free | Maximality prevents consistent extensions |
| `dc_delta_B_burgessR3` | 562 | ✓ sorry-free | Extension preserves burgessR3 |
| `mcs_no_proper_dcs_extension` | 460 | ✓ sorry-free | MCS blocks proper DCS extensions |
| `R3Maximal_is_mcs` | 446 | ✓ sorry-free | R3Maximal B is an MCS |
| `r3Maximal_neg_of_not_mem` | 429 | ✓ sorry-free | Negation completeness |
| `lemma_2_4` | 150 | ✓ sorry-free | Until witness endpoint |
| `lemma_2_5b` | 217 | ✓ sorry-free | g_content ordering transitivity |
| `lemma_2_6` | 242 | ✓ sorry-free | Counterexample insertion |
| `dcs_neg_union_consistent` | 367 | ✓ sorry-free | DCS neg-extension consistent |

From RRelation.lean:

| Theorem | Line | Status | Notes |
|---------|------|--------|-------|
| `burgessR3Maximal_exists_from_seed` | 1131 | ✓ sorry-free | Key existence via Zorn |
| `burgessR3_absorption` | 584 | ✓ sorry-free | Non-adjacent pair burgessR3 |
| `burgessR3_gamma_not_in_B` | 834 | ✓ sorry-free | C4 bridging (direct delta) |
| `burgessR3_gamma_not_in_B_since` | 849 | ✓ sorry-free | C4' bridging (Since) |
| `c4_hard_case_G_neg_delta` | 629 | ✓ sorry-free | G(¬δ) from hard case |
| `rRelation_guard_continues'` | 130 | ✓ sorry-free | Guard continuation |

INVALID stubs retained:

| Theorem | Line | Status | Notes |
|---------|------|--------|-------|
| `burgessR3_gamma_not_in_B_nested` | 1169 | ✗ sorry | Nested bridging (Until) |
| `burgessR3_gamma_not_in_B_since_nested` | 1183 | ✗ sorry | Nested bridging (Since) |

### 5. The Nested Bridging Lemma Has a Simple Fix

`burgessR3_gamma_not_in_B_nested` (RRelation.lean:1169) states:

```
burgessR3(A, B, C) ∧ ¬(γ U δ) ∈ A ∧ (γ U δ) ∈ C → γ ∉ B
```

The old proof used `untl_absorb_nested`: `(γ U (γ U δ)) → (γ U δ)`, which requires the guard at the junction point.

**But there's a simpler proof that works under open guard**:

Suppose γ ∈ B. By burgessR3, for any β ∈ B and any θ ∈ C: `untl(β, θ) ∈ A`. Take β = γ and θ = (γ U δ), noting that (γ U δ) ∈ C. Then:

```
untl(γ, γ U δ) ∈ A
```

By BX6 (absorb_until): `untl(γ, γ ∧ (γ U δ)) → (γ U δ)`.

Wait — BX6 is `(φ U (φ ∧ (φ U ψ))) → (φ U ψ)`, not `(φ U (φ U ψ)) → (φ U ψ)`. The guard shape doesn't match.

Let me reconsider. We have `untl(γ, γ U δ) ∈ A`. What we need is `(γ U δ) ∈ A` to get a contradiction with `¬(γ U δ) ∈ A`.

Actually, BX6 states: `(γ U (γ ∧ (γ U δ))) → (γ U δ)`. We have `untl(γ, γ U δ)`, not `untl(γ, γ ∧ (γ U δ))`.

Can we strengthen it? From `untl(γ, γ U δ)`: at some future s, `(γ U δ)(s)` with γ on (t,s). At s, by BX5: `(γ U δ)(s) → (γ ∧ (γ U δ)) U δ)(s)`. But this doesn't give us `γ(s)` at point s.

**Actually, the fix IS available through BX3 (right monotonicity)**:

We have `untl(γ, γ U δ) ∈ A`. By BX5 self-accumulation applied to `γ U δ`: `(γ U δ) → (γ ∧ (γ U δ)) U δ`. This means `G((γ U δ) → (γ ∧ (γ U δ)) U δ)` is a theorem. By BX3 (right_mono_until):

```
G((γ U δ) → (γ ∧ (γ U δ)) U δ) → (untl(γ, γ U δ) → untl(γ, (γ ∧ (γ U δ)) U δ))
```

Hmm, this doesn't directly simplify. Let me try a different approach.

**Direct contradiction approach**: We have `¬(γ U δ) ∈ A` and suppose γ ∈ B. From burgessR3: `untl(γ, γ U δ) ∈ A` (taking the Until formula with γ as guard and `(γ U δ)` as event, since `(γ U δ) ∈ C`).

Now apply BX10 (until_F): `untl(γ, γ U δ) → F(γ U δ)`. So `F(γ U δ) ∈ A`.

But `¬(γ U δ) ∈ A`. Does `¬(γ U δ)` imply `G(¬(γ U δ))`? Not without axiom 4 for Until, which we don't have. And `¬(γ U δ)` does NOT imply `¬F(γ U δ)` in general — `¬(γ U δ)` says it's false at the current point, not at all future points.

So this direct approach fails. The nested bridging lemma is NOT trivially fixable.

**However**: examining CounterexampleElimination.lean:421-422, the call context is:
- `h_mcs_w` : MCS for f(w)
- `h_r3_wn` : burgessR3(f(w), g(w, w_next), f(w_next))
- `hw_neg_until` : ¬(γ U δ) ∈ f(w)
- `h` : (γ U δ) ∈ f(w_next) (because w_next is the successor of the rightmost point with ¬(γ U δ))

So we need: γ ∉ g(w, w_next) given burgessR3(f(w), g(w, w_next), f(w_next)), ¬(γ U δ) ∈ f(w), and (γ U δ) ∈ f(w_next).

The issue: the existing `burgessR3_gamma_not_in_B` (RRelation.lean:834) uses `h_neg_until : ¬(γ U δ) ∈ A` and `h_delta : δ ∈ C` to conclude γ ∉ B. But here we have `(γ U δ) ∈ C` (the whole Until formula in C), not `δ ∈ C`.

**Alternative approach**: Maybe the C4 elimination logic can be restructured to avoid the nested case entirely. Instead of using the rightmost w with ¬(γ U δ), look for the rightmost w where the SIMPLE bridging lemma applies. The call site at line 421 is reached when w_next < y and (γ U δ) ∈ f(w_next). But if (γ U δ) ∈ f(w_next), then by BX10, F(δ) ∈ f(w_next). This means at some future point beyond w_next, δ holds. The question is whether we can find a domain point with δ directly.

**Key insight**: The countability of the domain is important here. Between w_next and y, there may be further domain points. If we can find a domain point v with δ ∈ f(v), we can use the simple bridging lemma `burgessR3_gamma_not_in_B` with the adjacent pair (w, w_next) where δ might not be in f(w_next) but we can instead use a different splitting strategy.

**This is the area that needs the most careful mathematical work in the plan revision.**

### 6. The D0 Consistency Argument Needs a Completely New Strategy

Given that B ⊆ A and B ⊆ C are both false under open guard, the consistency proof for D0 needs a fundamentally different approach. Here are the viable options:

**Option A: Abandon D0 entirely, use `burgessR3Maximal_exists_from_seed` directly**

The key theorem `burgessR3Maximal_exists_from_seed` (RRelation.lean:1131) takes a seed element η with:
1. `burgessR(A, η, C)` — for all γ ∈ C, untl(η, γ) ∈ A
2. `burgessRSince(C, η, A)` — for all α ∈ A, snce(η, α) ∈ C
3. `η ∈ A`

This produces a BurgessR3Maximal(A, B, C) with no need for D0 at all.

The question is: **where does the seed η come from?** In C5 elimination, η = β where U(γ,β) ∈ A, and β comes from Lemma 2.4. The seed construction there is already sorry-free.

For the general Lemma 2.6 splitting needed in Phase 2 (counterexample elimination), the D0 construction was intended to provide g-values for new adjacent pairs. But if we can instead identify appropriate seeds for `burgessR3Maximal_exists_from_seed`, we bypass D0 entirely.

**Option B: Weaker D0 using BurgessR3Maximal properties directly**

Instead of proving B ⊆ A and B ⊆ C, use the **maximality** of B. BurgessR3Maximal(A, B, C) means:
1. B is a DCS
2. burgessR3(A, B, C) holds
3. No proper DCS extension satisfies burgessR3

From (3), we know that for any δ ∉ B, DC({δ} ∪ B) does NOT satisfy burgessR3(A, -, C). The `BurgessR3Maximal_extension_fails` theorem (PointInsertion.lean:545) captures this.

The revised strategy: instead of putting neg(delta) into a seed set D0 and proving D0 consistent, use `dcs_neg_union_consistent` (PointInsertion.lean:367) to get `{δ.neg} ∪ B` consistent, then check if the deductive closure satisfies burgessR3.

If `DC({δ.neg} ∪ B)` satisfies burgessR3(A, -, C), it contradicts maximality. So DC({δ.neg} ∪ B) does NOT satisfy burgessR3(A, -, C). This means there exists some β' ∈ DC({δ.neg} ∪ B) and γ' ∈ C with `untl(β', γ') ∉ A`, or some β' ∈ DC({δ.neg} ∪ B) and α' ∈ A with `snce(β', α') ∉ C`.

**But we need the POSITIVE result**: construct a BurgessR3Maximal(A, B', C) with δ.neg ∈ B'. This requires a DIFFERENT B', not an extension of the current B.

**Option C (Recommended): Direct application of `lemma_2_6` + `burgessR3Maximal_exists_from_seed`**

`lemma_2_6` (PointInsertion.lean:242) already gives us: if g_content(A) ⊆ C and δ ∉ C, there exists MCS D with δ.neg ∈ D and g_content(A) ⊆ D.

For the chronicle construction, we don't need the g-value to contain δ.neg — we need the g-value to be a BurgessR3Maximal DCS. The δ.neg requirement is for the ENDPOINT (the new f(z)), not the interval.

The actual construction should be:
1. Insert a new point z with f(z) = D (from lemma_2_6)
2. For the new adjacent pairs (x,z) and (z,y), construct new g-values using `burgessR3Maximal_exists_from_seed`
3. The seeds for (x,z) come from the intersection of the old g(x,y) with the new f(z)
4. The seeds for (z,y) come similarly

This is exactly what the c2' sorry sites in CounterexampleElimination.lean are about (lines 786, 824, 864, 902, 938, 970). They need g-construction for new adjacent pairs.

## Recommended Approach

### For Phase 1 (D0/Lemma 2.6):

**ABANDON the D0 seed set entirely.** It cannot be made consistent under open guard because the core property B ⊆ A is false.

Instead, the plan should:

1. **Use `lemma_2_6` for endpoint construction** (already sorry-free): Given A, C MCS with g_content(A) ⊆ C and δ ∉ C, get MCS D with δ.neg ∈ D and g_content(A) ⊆ D.

2. **Use `burgessR3Maximal_exists_from_seed` for g-value construction** (already sorry-free): Given appropriate seeds from the splitting context, construct BurgessR3Maximal g-values for new adjacent pairs.

3. **The critical subproblem**: Finding the seeds for step 2. For each new adjacent pair after splitting, identify a formula η that satisfies:
   - `burgessR(A', η, C')` for the appropriate endpoints A', C'
   - `burgessRSince(C', η, A')`
   - `η ∈ A'`

   This is the REAL mathematical content that the plan must address. The seeds come from the old g-value's relationship with the new endpoint.

### For the Nested Bridging (burgessR3_gamma_not_in_B_nested):

**Restructure CounterexampleElimination.lean** to avoid the nested case. The current code (line 420-422) reaches the nested case when w_next has `(γ U δ) ∈ f(w_next)` but δ ∉ f(w_next). Instead:

- Option 1: Continue the search past w_next to find a domain point where δ holds directly (possible because F(δ) ∈ f(w_next) by BX10).
- Option 2: Use `rRelation_guard_continues'` on the adjacent pair (w_next, w_next_next) to propagate the Until obligation further.
- Option 3: Prove a weaker version of the nested lemma that uses additional structural information from the chronicle (e.g., g_content ordering).

### For the Self-Pair Sorry (line 1086):

This is a genuinely different problem: need `burgessR3(f(x), g(x,y), f(x))` (self-pair, same endpoint on both sides) from `burgessR3(f(x), g(x,y), f(y))`. This requires showing that the Until and Since conditions that hold from f(x) to f(y) also hold from f(x) to f(x). This is **not obviously true** — f(x) and f(y) are different MCSs, and the conditions are anti-monotone in C.

## Evidence/Examples

### File References

| File | Key Lines | Content |
|------|-----------|---------|
| PointInsertion.lean | 1-596 | Full file, all sorry-free infrastructure + removal comments |
| RRelation.lean | 130-136 | `rRelation_guard_continues'` — BX9 replacement for FUC |
| RRelation.lean | 584-598 | `burgessR3_absorption` — non-adjacent pair burgessR3 |
| RRelation.lean | 834-843 | `burgessR3_gamma_not_in_B` — simple C4 bridging (works) |
| RRelation.lean | 1131-1154 | `burgessR3Maximal_exists_from_seed` — key existence |
| RRelation.lean | 1169-1177 | `burgessR3_gamma_not_in_B_nested` — INVALID sorry stub |
| CounterexampleElimination.lean | 340-433 | C4 elimination with nested bridging call at 421-422 |
| CounterexampleElimination.lean | 1080-1086 | Self-pair density sorry |
| ChronicleToCountermodel.lean | 604-619 | FUC sorry sites (Until/Since guard) |
| Boneyard/ClosedGuardLegacy/ClosedGuardRRelation.lean | 1-130 | Archived invalid lemmas with explanations |

### Git Archaeology

- Pre-removal commit: `6bfb80e74^` (parent of task 113 Phase 1)
- D0 definition at pre-removal PointInsertion.lean line 726
- B_sub_A_of_burgessR3 at pre-removal PointInsertion.lean line 777
- burgess_D0_consistent at pre-removal PointInsertion.lean line 820 (was already `sorry`)

## Confidence Level

| Finding | Confidence | Rationale |
|---------|------------|-----------|
| B_sub_A is irrecoverable | **HIGH** | Semantic counterexample exists; no axiom chain can bridge the gap |
| D0 consistency proof strategy must change | **HIGH** | Directly depends on irrecoverable B_sub_A |
| Nested bridging needs restructuring | **MEDIUM** | The fix path (restructuring CounterexampleElimination) is plausible but unverified |
| `burgessR3Maximal_exists_from_seed` bypass works | **MEDIUM-HIGH** | The theorem is sorry-free and general, but seed identification for each case needs verification |
| Self-pair sorry is a distinct problem | **HIGH** | Not addressed by D0 changes; needs its own treatment |

**Overall**: The D0 approach is dead. The `burgessR3Maximal_exists_from_seed` bypass is the viable path. The critical open question is seed identification for the 7 c2' sorry sites.
