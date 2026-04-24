# Research Report: Task #107 — Path A Deep Dive: Critical Infrastructure Gaps

**Task**: 107 - Burgess chronicle construction for BX representation theorem
**Date**: 2026-04-24
**Mode**: Team Research (4 teammates)
**Focus**: Rigorous study of Path A (Direct BFMCS Truth Lemma over sparse X)

## Summary

This research round reveals that the obstacles to the direct truth lemma are **deeper than the domain type**. The chronicle construction itself has fundamental infrastructure gaps that affect BOTH the Rat-based (Path B) and sparse-X (Path A) approaches:

1. **The g function is never updated** in the omega-chain — it remains `fun _ _ => ∅` from the singleton chronicle
2. **There is no path from g_content(f(x)) to f(y)** — the fundamental chain for forward_G is broken
3. **C5 guard convention mismatch** — the chronicle uses open guard (x,y) but semantics require half-open [t,s)
4. **C4 may have a role reversal** relative to Burgess's formulation
5. **The semantic framework requires AddCommGroup** for the Box case (time_shift), making sparse X incompatible with the existing parametric truth lemma

**Path A as originally conceived (sparse X + existing BFMCS) is NOT viable.** The parametric framework's AddCommGroup requirement is not just at TaskFrame — it permeates ShiftClosed Omega, time_shift_preserves_truth, and the Box case of the truth lemma.

However, the research identifies a more promising direction: a **hybrid approach** that transplants Until/Since witnesses from the chronicle onto the already-working Int chain infrastructure.

## Key Findings

### 1. The g Function Is Never Updated (Teammate A — CRITICAL)

**The omega-chain's interval function g remains `fun _ _ => ∅` from the singleton chronicle and is NEVER updated during counterexample elimination.**

```
singleton_chronicle: g = fun _ _ => ∅
omega_chain step n+1: extends domain and f, but g is NOT modified
```

This means:
- C3 (`g_content(f(x)) ⊆ g(x,y)`) is **vacuously true** (g(x,y) = ∅ gives g_content(f(x)) ⊆ ∅ which is FALSE unless g_content is empty)
- Actually, C3 as stated may not hold at all with g = ∅
- The entire g-based reasoning (g_content propagation, interval decomposition) has **no foundation** in the current implementation

**Impact**: forward_G for domain points CANNOT be proved via g_content chains because the g function is trivial. This affects both Path A and Path B equally.

### 2. No Path from g_content(f(x)) to f(y) (Teammate A)

Even if g were properly maintained, the chronicle axioms provide:
- C3: `g_content(f(x)) ⊆ g(x,y)` — from point to interval
- But NO condition gives `g(x,y) ⊆ f(y)` — from interval to point

The Int chain handles this by construction: `f(n+1)` is a Lindenbaum extension of `g_content(f(n))`, so `g_content(f(n)) ⊆ f(n+1)` trivially. The chronicle's PointInsertion lemmas (lemma_2_4, lemma_2_6) DO construct f(z) as Lindenbaum extensions of g_content(f(x)), giving `g_content(f(x)) ⊆ f(z)`. But `g_content(f(z)) ⊆ f(y)` for the next point y is NOT guaranteed.

### 3. C5 Guard Convention Mismatch (Teammate D)

**The chronicle's C5 uses open guard (x < z < y)** — guards at STRICTLY intermediate domain points.
**The truth semantics use half-open guard [t ≤ r < s)** — guard includes the starting point t.

`limit_satisfies_c5_weak` provides **NO guard at all** — only witness existence (η ∈ f(y) for some y > x). The "weak" qualifier means exactly this: no guard formulas at intermediate points.

BX9 gives `(φ U ψ) → (φ ∨ ψ)` at the starting point, but this gives a disjunction, not the required φ(x). If ψ(x) holds but φ(x) doesn't, the half-open guard fails at x.

### 4. Potential C4 Convention Mismatch (Teammate D)

The codebase's C4 condition may have a **role reversal** relative to Burgess:
- Burgess: ¬(γ U δ) ∈ f(x) → for y > x, ∃z ∈ (x,y) with ¬δ ∈ f(z) (negation of the EVENT)
- Codebase: may encode the components differently due to the U(guard, event) vs U(event, guard) convention

This needs careful verification against the actual C4 definition in ChronicleTypes.lean.

### 5. AddCommGroup Permeates the Semantic Framework (Teammates B, C)

The AddCommGroup requirement is NOT just at TaskFrame. It appears in:
- **ShiftClosed Omega**: requires translation closure `t ∈ Ω → t + Δ ∈ Ω`
- **time_shift_preserves_truth**: 270 lines using `t + Δ`, `add_sub_cancel`
- **Box case of truth lemma**: uses time_shift to align diamond-witness timelines
- **WorldHistory.respects_task**: uses `t - s`

Replacing D=Rat with a sparse X that lacks AddCommGroup would break ALL of these, not just TaskFrame. **Path A (sparse X with existing parametric framework) is definitively NOT viable.**

### 6. Soundness Requires AddCommGroup (Teammate C)

The soundness theorem `valid φ → Nonempty (DerivationTree ∅ φ)` quantifies over `[AddCommGroup D]`. A separate `soundness_lo` for bare linear orders would require proving all BX axioms valid on arbitrary strict linear orders — possible but non-trivial.

## Synthesis: The Real State of Affairs

### What's Actually Broken

The chronicle construction has **three layers of problems**, from deepest to shallowest:

**Layer 1 (Deepest): The g function is trivial.**
The interval function g = ∅ means C3 is vacuous and forward_G has no foundation. This must be fixed regardless of the domain type strategy.

**Layer 2: Guard conventions don't match.**
C5 provides open guards; semantics need half-open. C5_weak provides no guards at all. The existing sorry sites are downstream of this mismatch.

**Layer 3 (Shallowest): Domain extension / density.**
The extended_limit_f design and the GGp→Gp concern. This layer only matters once Layers 1 and 2 are resolved.

### Revised Understanding of the 11 Sorry Sites

The sorry sites aren't just "waiting for the right domain type." They're blocked by fundamental infrastructure gaps:

| Sorry Site | Root Cause |
|-----------|------------|
| forward_G (line 192) | g function trivial, no g_content chain |
| backward_H (line 196) | Mirror of forward_G |
| box_stable (line 234) | Depends on forward_G + backward_H |
| restricted_tc F/P (lines 320, 323) | Depends on C5_weak (no guard) |
| restricted_buc Until/Since (lines 342, 345) | C4 convention unclear + no backward Until argument |
| restricted_fuc Until/Since (lines 374, 377) | C5 guard mismatch + no forward Until argument |
| C4 sub-case 1a (lines 289, 355) | Needs g function for C3 invariant |

### The Hybrid Approach (from Teammate A)

Teammate A identified a potentially elegant solution: **transplant Until/Since witnesses from the chronicle onto the sorry-free Int chain.**

The Int chain already provides:
- FMCS over Z with sorry-free forward_G and backward_H
- Box stability (sorry-free)
- The parametric truth lemma works for G, H, Box cases

What it lacks: Until/Since coherence (the Int chain has no Until/Since witnesses).

The chronicle provides: Until/Since witnesses via C5/C5' counterexample elimination.

**Hybrid idea**: Build the Int chain (over Z) from the root MCS A. Then, for each Until/Since obligation, use the chronicle's witness-insertion mechanism to show that witnesses exist along the chain. This avoids:
- The domain type problem (D = Int, which has AddCommGroup)
- The density concern (Z is discrete, GGp→Gp fails on Z)
- The g function gap (forward_G is already sorry-free on the Int chain)
- The guard mismatch (needs investigation)

**Open question**: Can chronicle-style Until/Since witnesses be embedded into the Int chain's MCS family? The Int chain builds MCS via forward/backward Lindenbaum extensions; the chronicle inserts midpoints. These are fundamentally different constructions. Reconciling them is non-trivial.

## Recommendations

### Immediate Priority: Fix the g Function (Layer 1)

Before any domain type strategy can work, the chronicle must maintain a non-trivial g function through the omega-chain. This means:
1. Define how g is initialized when inserting a new point z between x and y
2. Track g(x,z) and g(z,y) via R-relation decomposition
3. Prove that g_content(f(x)) ⊆ f(z) when z is inserted as a Lindenbaum extension of g_content(f(x))
4. Define limit_g for the omega limit

This is essential infrastructure regardless of whether we pursue Path A, Path B, the hybrid approach, or any other strategy.

### Secondary Priority: Resolve Guard Convention (Layer 2)

Clarify the C4/C5 conventions and either:
- Align the chronicle conditions with the half-open [t,s) semantics
- Or prove that open-guard C5 + BX9 is sufficient for half-open truth semantics

### Tertiary Priority: Domain Type Strategy (Layer 3)

Only after Layers 1-2 are resolved does the density concern become actionable. At that point, evaluate:
- Can forward_G be proved for domain points with the fixed g function?
- Does the hybrid approach (Int chain + chronicle witnesses) work?
- Is a separate general-completeness theorem achievable?

## Teammate Contributions

| Teammate | Angle | Status | Key Contribution |
|----------|-------|--------|-----------------|
| A | g_content chain | completed | g function is trivial (never updated) — fundamental gap |
| B | Box/BFMCS | completed | AddCommGroup permeates semantic framework; sparse X not viable |
| C | Lean definitions | completed | Soundness needs AddCommGroup; all 11 sorries are shared |
| D | Until/Since | completed | C5 guard mismatch; C4 potential role reversal; backward Until unresolved |
