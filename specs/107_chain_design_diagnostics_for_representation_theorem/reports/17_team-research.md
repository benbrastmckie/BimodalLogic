# Research Report: Task #107 — g_content_chain_property Resolution

**Task**: 107 - Burgess chronicle construction for BX representation theorem
**Date**: 2026-04-25
**Mode**: Team Research (4 teammates)
**Focus**: Resolve the g_content_chain_property obstacle

## Summary

All four teammates converge on a single diagnosis: **the codebase's g function is architecturally wrong.** Burgess uses a BINARY interval function g(x,y) maintained as part of the chronicle structure with the decomposition identity C3: `g(x,z) = g(x,y) ∩ f(y) ∩ g(y,z)`. The codebase defines `limit_g(x,y) = deductiveClosure(g_content(limit_f(x)))` — a UNARY function of x only. This architectural divergence is the root cause of the g_content_chain_property sorry and all downstream blockers.

**The fix**: Rebuild the omega-chain to maintain (f, g) PAIRS at every step, with C3 as the maintained invariant. When a new point z is inserted between x and y, g(x,y) is SPLIT into g(x,z) and g(z,y) via R-relation decomposition. The g_content chain property then falls out automatically from C3.

## Key Findings

### 1. Burgess's Binary g Function (Teammate B — Root Cause)

In Burgess 1982, the chronicle is a tuple (dom, f, g) where:
- f : dom → MCS (assigns MCS to each domain point)
- g : dom × dom → Set Formula (assigns formula sets to intervals between adjacent points)
- **C3 (decomposition)**: g(x,z) = g(x,y) ∩ f(y) ∩ g(y,z) for x < y < z

This C3 gives g_content propagation for FREE:
- g_content(f(x)) ⊆ g(x,y) (from C2/R-relation)
- g(x,y) ⊆ f(y) (from C3 with z = y: g(x,y) = g(x,y) ∩ f(y) ∩ g(y,y), so g(x,y) ⊆ f(y))

Wait — actually C3 as stated requires three distinct points. The key property is more subtle: Burgess maintains the R-relation between f(x) and g(x,y) (C2), and g(x,y) is defined to include g_content(f(x)). When z is inserted between x and y, g(x,y) is split into g(x,z) and g(z,y) with the decomposition identity preserved.

The truth lemma's G case uses: G(φ) ∈ f(x) → φ ∈ g_content(f(x)) → φ ∈ g(x,x₁) (for adjacent x < x₁, by C2/R-relation) → φ ∈ f(x₁) (from C3 or a consequence of the R-relation structure). Then temp_4 keeps G(φ) alive through intermediate points.

### 2. The Current Construction Is Fundamentally Asymmetric (Teammate A)

The Int chain maintains g_content(chain(n)) ⊆ chain(n+1) by construction: each chain(n+1) is a Lindenbaum extension of g_content(chain(n)). This is a FORWARD-only property.

The chronicle inserts points at arbitrary positions, creating both forward and backward obligations:
- Forward: g_content(f(x)) ⊆ f(z) when z is inserted after x — satisfiable by seed design
- **Backward: g_content(f(z)) ⊆ f(y) when z is inserted before existing y** — requires modifying f(y), which risks inconsistency

The two-pass approach (extend f(y) to include g_content(f(z))) is UNSOUND because g_content(f(z)) ∪ f(y) can be inconsistent under strict semantics.

### 3. g_content_chain_property IS FALSE for Current Construction (Teammate C)

Confirmed: the omega-chain inserts points with seeds from the triggering point only. Existing MCS are never modified. Therefore g_content(f(z)) ⊆ f(y) fails when z was inserted between x and y after f(y) was already fixed.

This is not just unproven — it is **provably false** for the current construction.

### 4. The Fix: Full (f, g) Pair Construction (Teammates B, D)

Rebuild the omega-chain to match Burgess's actual construction:

**Step 1**: Redefine Chronicle to carry both f and g as maintained state
- `f : dom → Set Formula` (MCS at each point)
- `g : dom → dom → Set Formula` (interval sets between adjacent points)

**Step 2**: Each omega-chain step maintains the invariant:
- C0: f(x) is MCS for all x ∈ dom
- C1: g(x,y) is deductively closed and consistent for adjacent x < y
- C2: R-relation holds between f(x) and g(x,y) for adjacent x < y
- C3: Decomposition identity for non-adjacent triples

**Step 3**: When inserting z between x and y:
- f(z) is constructed via PointInsertion (Lindenbaum extension of controlled seed)
- g(x,y) is SPLIT into g(x,z) and g(z,y) via R-relation decomposition
- The split preserves C2 and C3

**Step 4**: In the limit:
- limit_f(x) = f_n(x) for the first n where x ∈ dom_n (unchanged)
- limit_g(x,y) = g_n(x,y) for the first n where both x,y are adjacent in dom_n... BUT adjacency changes as new points are inserted
- Actually: limit_g needs careful definition accounting for adjacency changes

### 5. Estimated Effort

Teammate D recommends 30 hours for Phase 1 (up from plan v6's 25h). The work includes:
- Redefine ChronicleTypes to include binary g (modify existing structure)
- Redefine eliminate_potential_counterexample to return updated g
- Implement g-splitting when inserting between adjacent points
- Define limit_g properly for the limit chronicle
- Prove C2/C3 preservation through omega-chain steps
- Prove g_content_chain_property from the maintained invariant

## Synthesis

### The Architecture Fix

```
CURRENT (broken):
  Chronicle = { dom, f, g }     where g = fun _ _ => ∅ (trivial)
  omega_chain step: returns { dom', f', g }  (g unchanged)
  limit_g = deductiveClosure(g_content(limit_f(x)))  (unary, wrong)

CORRECT (Burgess):
  Chronicle = { dom, f, g }     where g is a binary interval function
  omega_chain step: returns { dom', f', g' }  (g updated via splitting)
  limit_g = g_n(x,y) for appropriate n  (binary, from construction)
```

### Why This Works

With a proper binary g maintained through the construction:
1. C2 gives: g_content(f(x)) ⊆ g(x,y) for adjacent x < y
2. C3 decomposition gives: g(x,y) relates to f at intermediate points
3. temp_4 (Gφ → GGφ) keeps G(φ) alive: G(φ) ∈ f(x) → G(φ) ∈ g(x,y) → G(φ) ∈ f(y) → ...
4. At the final point: φ exits from G(φ) via g_content

The chain property g_content(f(x)) ⊆ f(y) follows from chaining through adjacent pairs:
g_content(f(x)) ⊆ g(x,x₁) ⊆ f(x₁) → temp_4 keeps G(φ) → g_content(f(x₁)) ⊆ g(x₁,x₂) ⊆ f(x₂) → ... → f(y)

### Open Question: g-Splitting

The hardest part is defining how g(x,y) splits when z is inserted between x and y. Burgess handles this via the R-relation:
- g(x,z) must satisfy R(f(x), g(x,z))
- g(z,y) must satisfy R(f(z), g(z,y))
- The decomposition g(x,y) = g(x,z) ∩ f(z) ∩ g(z,y) should hold (or similar)

The PointInsertion lemmas (lemma_2_4, lemma_2_6) may already provide the mechanism for constructing the split g values. This needs verification against the code.

## Teammate Contributions

| Teammate | Angle | Status | Key Contribution |
|----------|-------|--------|-----------------|
| A | Two-pass analysis | completed | Two-pass unsound; temp_4 circular; fundamental asymmetry identified |
| B | Burgess's actual proof | completed | Binary g with C3 decomposition is the root fix; codebase g is unary (wrong) |
| C | Chain property critique | completed | Property IS FALSE for current construction; cannot be weakened |
| D | Elegant solution | completed | Full (f, g) pair construction; 30h estimate; h_content enriched seed mechanism |
