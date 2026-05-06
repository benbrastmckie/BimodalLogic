# Research Report: lemma_2_7 B ⊆ B' Gap for Guard Propagation

## 1. Burgess Construction vs Our Construction

### Burgess 2.7 (p.372)

**Statement**: Given R(A, B, C), U(ξ, η) ∈ A, η ∉ B. Then ∃ B', D, B'' with η ∈ B', ξ ∈ D, R(A, B', D), R(D, B'', C), and **B = B' ∩ D ∩ B''**.

**Seed D₀**: {S(α, β∧η) : α ∈ A, β ∈ B} ∪ B ∪ {ξ} ∪ {U(γ, β) : γ ∈ C, β ∈ B}

**After extending D₀ to MCS D**:
- ξ ∈ D (from seed), B ⊆ D (from seed)
- B' maximal with **B ⊆ B'** and r(A, B', D)
- B'' maximal with **B ⊆ B''** and r(D, B'', C)
- B = B' ∩ D ∩ B'' (by Lemma 2.5 absorption)

**Key**: η ∈ B' is claimed in the conclusion but Burgess does NOT explicitly prove it in the proof text. He says "much as in the proof of 2.6" and the actual construction seeds B' from B (not from {η}).

### Our lemma_2_7 (PointInsertion.lean:3616)

**Output type**:
```lean
∃ B' D B'', BurgessR3Maximal A B' D ∧ BurgessR3Maximal D B'' C ∧
  SetMaximalConsistent D ∧ eta ∈ D ∧ xi ∈ B'
```

**Seed**: Same as Burgess with extra 5th component `{snce(β∧xi, α) : β ∈ B, α ∈ A}`.

**Zorn step (lines 3724-3728)**:
- B' seeded from **DC({xi})** (not from B): `burgessR3Maximal_extension_exists h_mcs_A h_D_mcs h_dc_xi_dcs h_dc_xi_r3 h_no_univ_AD`
- B'' seeded from **B**: `burgessR3Maximal_extension_exists h_D_mcs h_mcs_C h_B_dcs h_r3_DBC h_no_univ_DC`

**Result**: DC({xi}) ⊆ B' (so xi ∈ B'), and B ⊆ B'' (from B seed). But **B ⊆ B' is NOT guaranteed**.

### Deviation Summary

| Property | Burgess | Our Code |
|----------|---------|----------|
| B' seed | B | DC({xi}) |
| B'' seed | B | B |
| B ⊆ B' | Yes (from seed) | **No** |
| B ⊆ B'' | Yes (from seed) | Yes |
| xi ∈ B' | Claimed (proof unclear) | Yes (from DC({xi}) ⊆ B') |
| B = B' ∩ D ∩ B'' | Yes (Lemma 2.5) | **Not provable** (B ⊆ B' fails) |

## 2. Root Cause: Absence of Burgess's A7a Axiom

### The Critical Axiom Difference

Burgess's A7a: `U(p,q) ∧ U(r,s) → U(p∧r, q∧s) ∨ U(p∧s, q∧s) ∨ U(q∧r, q∧s)`

All three disjuncts share the SAME guard `q∧s`.

Our BX7: `(φ U ψ) ∧ (χ U θ) → ((φ∧χ) U (ψ∧θ)) ∨ ((φ∧χ) U (ψ∧χ)) ∨ ((φ∧χ) U (φ∧θ))`

All three disjuncts share the SAME event `φ∧χ`.

**A7a was removed** (Axioms.lean:248-253) because it is **unsound under open-guard semantics** (our `t < r < s` strict inequality). Countermodel: φ=χ=⊤, ψ true only at s₁, θ true only at s₂ with s₁≠s₂ — no point satisfies ψ∧θ.

### Why A7a Matters for the Seed

Burgess's proof of seed consistency for Lemma 2.7 (p.372) applies A7a to derive:
```
U(γ∧γ', β∧U(γ∧γ',β)) ∈ A  and  U(ξ, η∧U(ξ,η)) ∈ A
```
Using A7a, all three disjuncts have guard `(β∧U(γ∧γ',β)) ∧ (η∧U(ξ,η))`, making elimination of two disjuncts feasible (the guard implies `β∧xi`, which contradicts `¬U(β∧xi, γ₀) ∈ A`).

With BX7 instead of A7a, the disjuncts have varying GUARDS (not a shared guard), and two of three disjuncts CANNOT be eliminated by the same argument. The current code works around this using BX13 enrichment and BX14 separation — a valid but fundamentally different proof path that gives DC({xi}) as seed (not B).

### Why DC(B ∪ {xi}) Cannot Be the Seed

To use `burgessR3Maximal_extension_exists` with seed DC(B ∪ {xi}), we need `burgessR3(A, DC(B ∪ {xi}), D)`. This requires:

For all φ ∈ DC(B ∪ {xi}), all δ ∈ D: `untl(φ, δ) ∈ A`

By `dc_delta_B_controlled`, φ ∈ DC(B ∪ {xi}) means either φ ∈ B or ⊢ (b∧xi) → φ for some b ∈ B. The second case needs `untl(b∧xi, δ) ∈ A`.

We have `untl(b, δ) ∈ A` (from burgessR3(A, B, D)) and `untl(xi, δ) ∈ A` (from step 5d). But we CANNOT derive `untl(b∧xi, δ) ∈ A` from these:

- **BX7** gives a disjunction `untl(b∧xi, δ∧δ) ∨ untl(b∧δ, δ∧δ) ∨ untl(δ∧xi, δ∧δ)` — only one disjunct has guard b∧xi, and we can't force it.
- **BX1** (left-mono in guard = A2a) goes the WRONG way: strengthens guards, doesn't weaken them. From `untl(b∧xi, δ)` we could get `untl(b, δ)`, but not vice versa.
- **A7a** would give all disjuncts with guard b∧xi, but it's ABSENT from our system.

## 3. Whether B ⊆ B' Can Be Achieved

### Approach A: Change B' Seed to B

**What we have**: `burgessR3(A, B, D)` (line 3664) and `h_B_dcs : SetDeductivelyClosed B`. These satisfy `burgessR3Maximal_extension_exists` requirements.

**Result**: B ⊆ B' guaranteed, but xi ∈ B' is LOST.

**Can we recover xi ∈ B'?** Only if we can show `burgessR3(A, DC(B' ∪ {xi}), D)` — contradicting B' maximality. But this has the same conjunction problem: untl(b'∧xi, δ) ∈ A is not derivable from untl(b', δ) and untl(xi, δ).

The extra seed information `snce(β∧xi, α) ∈ D` (for β ∈ B) gives `burgessR(A, β∧xi, D)` for β ∈ **B** — but not for β ∈ B' \ B. So we cannot extend the argument to all of B'.

**Verdict**: xi ∈ B' is NOT recoverable when seeding from B alone.

### Approach B: Use DC(B ∪ {xi}) as Seed

**Requires**: `burgessR3(A, DC(B ∪ {xi}), D)` — needs `untl(b∧xi, δ) ∈ A` for all b ∈ B, δ ∈ D.

**Blocked**: As shown in Section 2, this requires A7a which is absent.

**Verdict**: Not achievable with the current axiom system.

### Approach C: Two-Phase Zorn (Most Promising)

**Phase 1**: Seed B' from B. Get B ⊆ B', BurgessR3Maximal(A, B', D). But xi ∉ B'.

**Phase 2**: Then observe that from the output of lemma_2_7, we need:
- BurgessR3Maximal(A, B', D) with B ⊆ B' (for Lemma 2.5 / C3)
- eta ∈ D
- xi ∈ B' is currently used NOWHERE at call sites

Looking at ALL call sites in CounterexampleElimination.lean (lines 986-988, 1012-1015, 1016-1019, 1152-1155, 1176-1180), the `xi ∈ B'` component is always **discarded** with `_`:
```lean
(fun ⟨B', D, B'', hB', hB'', hD, hη, _⟩ => ⟨B', D, B'', hB', hB'', hD, hη⟩)
```

The callers only need: BurgessR3Maximal(A, B', D), BurgessR3Maximal(D, B'', C), SetMaximalConsistent D, and eta ∈ D.

**Verdict**: xi ∈ B' is not needed by any caller. We can change the output type to include B ⊆ B' instead.

### Approach D: Add B = B' ∩ D ∩ B'' to Output

**Requires**: B ⊆ B' (from Approach C), B ⊆ D (from seed, already proven at line 3639), B ⊆ B'' (already proven, B'' seeded from B).

**Then**: Lemma 2.5 (burgessR3_absorption at RRelation.lean:591) gives: if R(A, B, C) with B ⊆ B' ∩ D ∩ B'' and R(A, B', D) and R(D, B'', C), then B = B' ∩ D ∩ B''.

Actually, Lemma 2.5 as formalized gives `burgessR3(A, B₁₂, C)` from `B₁₂ ⊆ B₁ ∩ D ∩ B₂`, which shows the C3 identity B₁₂ = B' ∩ D ∩ B'' holds when B₁₂ = B and B is maximal. The maximality of B (from BurgessR3Maximal(A, B, C)) combined with B ⊆ B' ∩ D ∩ B'' and burgessR3(A, B' ∩ D ∩ B'', C) gives B = B' ∩ D ∩ B''.

This provides the C3 identity needed for guard propagation.

## 4. Recommended Fix

### Step 1: Change B' Seed from DC({xi}) to B

In `lemma_2_7` (PointInsertion.lean:3721-3725), change:
```lean
-- CURRENT (line 3721-3725):
-- Step 8: BurgessR3Maximal via Zorn from DC({xi})
obtain ⟨B', _, _, h_B'_max⟩ := burgessR3Maximal_extension_exists h_mcs_A h_D_mcs
    h_dc_xi_dcs h_dc_xi_r3 h_no_univ_AD
```
to:
```lean
-- PROPOSED:
-- Step 8: BurgessR3Maximal via Zorn from B (Burgess-aligned: B ⊆ B')
obtain ⟨B', h_B_sub_B', _, h_B'_max⟩ := burgessR3Maximal_extension_exists h_mcs_A h_D_mcs
    h_B_dcs h_r3_ABD h_no_univ_AD
```

### Step 2: Change Output Type

From:
```lean
∃ B' D B'', BurgessR3Maximal A B' D ∧ BurgessR3Maximal D B'' C ∧
  SetMaximalConsistent D ∧ eta ∈ D ∧ xi ∈ B'
```
To:
```lean
∃ B' D B'', BurgessR3Maximal A B' D ∧ BurgessR3Maximal D B'' C ∧
  SetMaximalConsistent D ∧ eta ∈ D ∧ B ⊆ B'
```

### Step 3: Remove DC({xi}) Infrastructure

Lines 3693-3720 (the `by_cases h_xi_cons` split and DC({xi}) construction) can be simplified since we no longer need to prove `burgessR3(A, DC({xi}), D)`. The proof becomes:
```lean
obtain ⟨B', h_B_sub_B', _, h_B'_max⟩ := burgessR3Maximal_extension_exists h_mcs_A h_D_mcs
    h_B_dcs h_r3_ABD h_no_univ_AD
obtain ⟨B'', h_B_sub_B'', _, h_B''_max⟩ := burgessR3Maximal_extension_exists h_D_mcs h_mcs_C
    h_B_dcs h_r3_DBC h_no_univ_DC
exact ⟨B', D, B'', h_B'_max, h_B''_max, h_D_mcs, h_eta_D, h_B_sub_B'⟩
```

### Step 4: Also Remove the Degenerate Case

The entire `by_cases h_xi_cons` split (lines 3693-3806) with the inconsistent-xi degenerate case can be removed. The B-seeded Zorn works regardless of xi consistency.

### Step 5: Update Call Sites

All call sites in CounterexampleElimination.lean already discard `xi ∈ B'`. They would need to either:
- Also discard `B ⊆ B'` (if not needed at call site), or
- Thread `B ⊆ B'` through for guard propagation purposes

### Step 6: Mirror for lemma_2_7_since

The Since mirror `lemma_2_7_since` (PointInsertion.lean:4483) needs the same change.

## 5. Impact on FUC/FSC Closure

With B ⊆ B':
- When point z is inserted between x and y (where g(x,y) = B):
  - g(x,z) = B' with B ⊆ B'
  - f(z) = D with B ⊆ D  
  - g(z,y) = B'' with B ⊆ B''
  - Lemma 2.5: B = B' ∩ D ∩ B'' (the C3 identity)
- If guard ∈ B (from enriched lemma_2_4):
  - guard ∈ B' (since B ⊆ B')
  - guard ∈ D (since B ⊆ D)
  - guard ∈ B'' (since B ⊆ B'')
- At all further insertion steps, guard propagates through B ⊆ B' at each level
- At the limit: guard ∈ limit_g(x,y) = ∩{f(w) : x < w < y}

This unblocks Phase 2 (guard propagation through omega chain) and ultimately Phase 6 (FUC/FSC).

## 6. Estimated Effort

| Change | File | Effort |
|--------|------|--------|
| Change B' seed & output type | PointInsertion.lean:3616-3734 | 1-2 hours |
| Remove degenerate case | PointInsertion.lean:3735-3806 | 30 min |
| Mirror for lemma_2_7_since | PointInsertion.lean:4483+ | 1-2 hours |
| Update call sites (CE.lean) | CounterexampleElimination.lean | 1-2 hours |
| Verify `lake build` | All | 30 min |
| **Total** | | **3-7 hours** |

## 7. Key Files and Lines

- `PointInsertion.lean:3616` — `lemma_2_7` theorem
- `PointInsertion.lean:3724-3725` — B' Zorn seed (the line to change)
- `PointInsertion.lean:3727-3728` — B'' Zorn seed (already correct)
- `PointInsertion.lean:2863` — `lemma_2_7_seed` definition
- `PointInsertion.lean:3204` — `lemma_2_7_seed_consistent`
- `PointInsertion.lean:4483` — `lemma_2_7_since` (mirror)
- `RRelation.lean:760` — `burgessR3Maximal_extension_exists` 
- `RRelation.lean:591` — `burgessR3_absorption` (Lemma 2.5)
- `RRelation.lean:1593` — `burgessR3Maximal_with_guard`
- `CounterexampleElimination.lean:986-1019,1152-1180` — call sites
- `ChronicleToCountermodel.lean:634,638` — FUC/FSC sorry sites
- `Axioms.lean:226-253` — BX7 vs A7a (the axiom gap)
