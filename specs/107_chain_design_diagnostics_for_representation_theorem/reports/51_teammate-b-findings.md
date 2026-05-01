# Teammate B: Alternative Approaches — Task 107

**Date**: 2026-05-01
**Role**: Alternative pattern analysis and assumption challenge
**Focus**: Challenge "dead code" conclusion, evaluate alternative resolution paths

## Key Findings

### 1. CRITICAL: Sorries 1-3 Are NOT Dead Code — They Are Missing Wiring

**Confidence: HIGH**

The audit (report 50) claims lemma_2_6_splitting and lemma_2_7 are "dead code with zero callers." This conclusion is dangerously wrong. They have zero callers because **the callers haven't been wired up yet**, not because they're unnecessary.

**Evidence from Burgess's paper:**

- **Lemma 2.9** (C4 counterexample elimination) explicitly calls **Lemma 2.6** in the n=0 case: "By C2' we have R(f(x), g(x,y), f(y)) and so we can apply **2.6** to A = f(x), B = g(x,y), C = f(y) to obtain B', D, B''."

- **Lemma 2.10** (C5 counterexample elimination, n>0 case) explicitly calls **Lemma 2.7 or 2.8**: "the hypotheses either of **2.7** or else of **2.8** must hold... So we can obtain B', D, B'' as in the conclusion of 2.7."

The codebase has:
- `eliminate_C4_counterexample` (CounterexampleElimination.lean:304) — the C4 hard case (line 412) has `sorry` exactly where Burgess calls Lemma 2.6
- `eliminate_C5_counterexample` (CounterexampleElimination.lean:167) — currently handles ONLY the n=0 case (places witness beyond all domain points), completely omitting the n>0 case that needs Lemma 2.7/2.8

**The correct diagnosis**: lemma_2_6_splitting and lemma_2_7 are the exact lemmas needed to close sorries 4-5 (C4 hard case) and partially needed for a proper n>0 C5 elimination. They have zero callers because the call sites are the sorry sites themselves.

### 2. The C4 Sorry IS Solvable Via Lemma 2.6 + c2'

**Confidence: HIGH**

The C4 hard case (line 412) needs to find an MCS D with `γ.neg ∈ D` when `γ ∈ f(x)` AND `γ ∈ f(y)`. The code already:
1. Finds the rightmost w with `neg(untl(γ,δ)) ∈ f(w)` (lines 367-384)
2. Finds w_next, the successor of w (lines 388-406)
3. Has the adjacent pair (w, w_next)

What it needs next (and is sorry'd):
- `BurgessR3Maximal(f(w), g(w, w_next), f(w_next))` — this is c2'
- Apply `lemma_2_6_splitting` with δ = γ to get D with `γ.neg ∈ D`

**This is exactly Burgess Lemma 2.9, n=0 case.**

The c2' condition provides `R(f(w), g(w, w_next), f(w_next))` for the adjacent pair, which is the precondition for Lemma 2.6.

### 3. The C5 Elimination Is Architecturally Incomplete

**Confidence: HIGH**

The current `eliminate_C5_counterexample` only handles the n=0 case (no domain points after x). It places the witness y beyond ALL domain points. This is correct for the initial singleton chronicle, but in later stages when there are points after x, Burgess requires:

- **n>0 case**: Check if the immediate successor x' of x already satisfies certain conditions. If not, apply **Lemma 2.7 or 2.8** to INSERT a point between x and x'.

The codebase sidesteps this by just appending points beyond the domain, which means:
- The C5 witness is always placed AFTER all existing points
- The guard condition (ξ at intermediate points) is never explicitly established

This is why `limit_satisfies_c5_weak` only gives the endpoint witness without the guard.

### 4. The FUC/FSC Sorry Can Be Resolved via limit_g (No Code Changes to C5 Needed)

**Confidence: MEDIUM**

Despite the incomplete C5 elimination, the FUC/FSC sorry (lines 615, 619) may be resolvable without fixing C5. Here's why:

The `limit_g(x,y)` is defined as `{φ | ∀ z ∈ dom, x < z → z < y → φ ∈ limit_f(z)}` — the set of formulas holding at ALL intermediate points.

For `U(φ, ψ) ∈ limit_f(t)`:
1. `limit_satisfies_c5_weak` gives witness `s > t` with `ψ ∈ limit_f(s)` (sorry-free)
2. We need: `φ ∈ limit_f(r)` for all `r` with `t < r < s` (the guard)

**The key insight**: At the limit, the domain is dense. For EVERY point r between t and s in the limit domain, if `φ ∉ limit_f(r)` then `φ.neg ∈ limit_f(r)` (MCS). Then `limit_satisfies_c4` (sorry-free) applied to `neg(U(φ,ψ)) ∈ f(x)` would give... wait, we DON'T have `neg(U(φ,ψ)) ∈ f(x)`.

Actually, the argument for the forward direction is:
- Given `U(φ, ψ) ∈ limit_f(t)`, C5_weak gives witness s with `ψ ∈ limit_f(s)`
- The guard `φ ∈ limit_f(r)` for t < r < s does NOT follow automatically
- This requires `φ ∈ limit_g(t, s)`, which requires the C5 elimination to establish the guard

So this path requires either:
(a) Proving that the C5 witness y has `ξ ∈ limit_g(t, y)` (guard in interval), OR
(b) A separate argument at the limit level

**Path (a)** requires fixing the C5 elimination to actually establish the guard. This means implementing the full Burgess Lemma 2.10 (n>0 case with Lemma 2.7/2.8).

**Path (b)**: An induction argument. Since `U(φ,ψ) ∈ limit_f(t)`, by BX5: `U(φ, ψ ∧ U(φ,ψ)) ∈ limit_f(t)`. The C5 witness gives s with `ψ ∧ U(φ,ψ) ∈ limit_f(s)`. Now `U(φ,ψ) ∈ limit_f(s)`, so we can recurse. At each intermediate point r between t and s in limit_dom, either:
- `ψ ∧ U(φ,ψ) ∈ limit_f(r)` (which gives `φ ∈ limit_f(r)` by... hmm, not directly)

Actually this gets circular. The clean path is (a).

### 5. The Density Gap Sorry in splitting_seed_consistent IS the Real Problem

**Confidence: HIGH**

The `splitting_seed_consistent` (PointInsertion.lean:889-906) uses seed `{β.neg} ∪ g_content(A) ∪ h_content(C)` and has a sorry in the inconsistent sub-case of g_content_sub_B. 

But `lemma_2_6_splitting` (lines 908-933) calls this and is **already sorry-free given its dependencies**! The only sorry propagation comes from `splitting_seed_consistent`. If `splitting_seed_consistent` is sorry-free, then `lemma_2_6_splitting` is sorry-free.

**Burgess's D0 seed avoids this entirely**. Burgess's seed for Lemma 2.6 is:
```
D0 = {S(α,β) : α ∈ A, β ∈ B} ∪ B ∪ {¬δ} ∪ {U(γ,β) : γ ∈ C, β ∈ B}
```

This includes ALL of B, not g_content/h_content. The consistency proof uses A5a + A4a + A3a (BX5 + BX14 + BX13 in the codebase) and does NOT require proving g_content(A) ⊆ B. **The density gap sorry is an artifact of a non-Burgess seed construction.**

Plan v35 Phase 3 correctly identifies this as the fix, but report 50 incorrectly dismisses it as dead code.

## Alternative Approaches (Ranked by Feasibility)

### Approach 1: Implement Burgess D0 Seed + Wire Lemma 2.6 into C4 (RECOMMENDED)

**Feasibility: HIGH** | **Effort: 8-12h** | **Risk: LOW**

1. Replace `splitting_seed_consistent` with Burgess's actual D0 seed and consistency proof (A5a + A4a + A3a chain)
2. This makes `lemma_2_6_splitting` sorry-free
3. Wire `lemma_2_6_splitting` into `eliminate_C4_counterexample` at line 412
4. Need c2' at finite stages — use `burgessR3Maximal_from_g_content_sub` (sorry-free)
5. Mirror for C4' at line 510

This closes sorries 1-5. The approach directly follows Burgess's paper.

**Why c2' is available without omega_chain changes**: For adjacent pair (w, w_next), we need `BurgessR3Maximal(f(w), g(w, w_next), f(w_next))`. The g-values at adjacent pairs are set during point insertion. If `g_content(f(w)) ⊆ f(w_next)` holds for adjacent pairs, then `burgessR3Maximal_from_g_content_sub` (RRelation.lean:1505) produces the BurgessR3Maximal. BUT: the current code sets `g' = χ.g` for new chronicles (line 187, 324 in CounterexampleElimination.lean), meaning g is NOT extended when new points are inserted. The g-function is just carried over unchanged. This means g(w, w_next) may be empty for newly-adjacent pairs.

**Gap identified**: The point insertion code doesn't assign g-values for newly created adjacent pairs. Burgess's construction explicitly sets g'(x,z) = B', g'(z,y) = B'' (from Lemma 2.6). The codebase's C4 and C5 elimination functions carry g unchanged: `(∀ a b, χ'.g a b = χ.g a b)`. This means c2' cannot hold for newly-created adjacent pairs because g wasn't extended.

**This is a deeper architectural issue**: The g-function should be EXTENDED at each point insertion to include B', B'' from Lemma 2.6 (for C4 elimination) or Lemma 2.4 (for C5 elimination). Currently, only f is extended (new point gets an MCS), while g stays the same.

**Resolution**: The fact that `limit_g` is defined independently (as intersection of all intermediate f-values) means g doesn't need to be threaded through finite stages — it's defined purely from f at the limit. The `limit_g` definition is correct. The question is whether finite-stage c2' is needed for C4 elimination.

**Critical realization**: The C4 elimination happens AT finite stages. If g(w, w_next) is empty (because g was never extended), then `BurgessR3Maximal(f(w), ∅, f(w_next))` is what c2' would require. But `BurgessR3Maximal(A, ∅, C)` requires `burgessR3(A, ∅, C)`, which is vacuously true. And ∅ can only be maximal if `r(A, {δ}, C)` fails for every δ — i.e., for every δ, there exists γ ∈ C with `U(γ, δ) ∉ A`. This seems unlikely to be generally true.

**Alternative within Approach 1**: Instead of relying on c2' from the chronicle's g-function, we can use `burgessR3Maximal_from_g_content_sub` directly with `g_content(f(w)) ⊆ f(w_next)`. The question is whether this g_content inclusion holds for adjacent pairs. Since f is assigned by the chronicle and g_content is derived from f, this depends on how f(w_next) was constructed. If w_next was inserted via C5 elimination using lemma_2_4, then g_content(f(w)) ⊆ f(w_next) holds by construction (lemma_2_4 ensures g_content(A) ⊆ C).

But if w and w_next are original points that were never separated by a point insertion, g_content(f(w)) ⊆ f(w_next) is not guaranteed. We would need to verify this.

### Approach 2: Full Burgess-Faithful Implementation (C5 n>0 + C4 + FUC)

**Feasibility: MEDIUM** | **Effort: 20-30h** | **Risk: MEDIUM**

1. Implement Burgess Lemma 2.7 (Until-formula splitting) using BX7 (since A7a was removed as unsound)
2. Implement Burgess Lemma 2.8 as variant
3. Rewrite `eliminate_C5_counterexample` to handle n>0 case (insert between existing points using 2.7/2.8)
4. Extend g-function during point insertion
5. Implement Burgess D0 seed for Lemma 2.6
6. Wire Lemma 2.6 into C4 elimination
7. FUC/FSC follows from proper C5 with guard

This is the most mathematically correct approach but requires significant infrastructure changes.

**Key blocker**: Lemma 2.7 requires A7a, which was removed as unsound. The BX7 alternative needs verification.

### Approach 3: Bypass C5 Guard via Direct Limit Argument

**Feasibility: LOW** | **Effort: 15-25h** | **Risk: HIGH**

Try to prove FUC/FSC without fixing C5 elimination, using:
1. limit_satisfies_c5_weak for endpoints
2. Some form of BX5-based propagation at the limit
3. Dense domain properties

This is speculative and may not work. The core issue is that without explicit guard establishment, there's no way to prove φ holds at arbitrary intermediate points.

## Cruft Assessment

### Genuinely Archivable
- `g_content_sub_B` (PointInsertion.lean:839) — only needed for the non-Burgess seed
- `h_content_sub_B` (PointInsertion.lean:861) — dual of above
- `splitting_seed_consistent` (PointInsertion.lean:889) — the non-Burgess seed consistency
- `G_conj_strengthen` and `H_conj_strengthen` (PointInsertion.lean:802, 815) — helpers for non-Burgess approach

These can be archived to Boneyard once the Burgess D0 seed replaces the current seed.

### DO NOT Archive
- `lemma_2_6_splitting` (PointInsertion.lean:908) — NEEDED by C4 elimination
- `lemma_2_7` (PointInsertion.lean:1032) — NEEDED by full C5 elimination (n>0 case)
- `right_mono_until_mcs` (PointInsertion.lean:968) — helper for Lemma 2.7
- `untl_conj_eta_of_g_content` (PointInsertion.lean:985) — helper for Lemma 2.7

### Dead Code Outside Chronicle/
- `bx_le_refl` sorry in Frame.lean:205 — dead under irreflexive semantics
- 3 sorries in SigmaOrdering.lean (82, 99, 143) — Filtration path, not on critical path
- 2 sorries in TruthLemma.lean (296, 321) — not on chronicle critical path

## Evidence Summary

| Claim | Evidence | Confidence |
|-------|----------|------------|
| lemma_2_6 IS needed by C4 | Burgess 2.9 n=0 case explicitly calls 2.6 | HIGH |
| lemma_2_7 IS needed by C5 n>0 | Burgess 2.10 n>0 case explicitly calls 2.7/2.8 | HIGH |
| Burgess D0 seed eliminates density gap | Burgess consistency proof uses A5a+A4a+A3a, no g_content⊆B | HIGH |
| g-function not extended at point insertion | CounterexampleElimination.lean lines 187, 324: g unchanged | HIGH |
| FUC requires guard from C5 | Claim 2.11 proof: C5a gives η ∈ g(x,y), C3 gives g(x,y) ⊆ f(z) | HIGH |
| A7a removed, Lemma 2.7 needs BX7 | Report 50: "A7a unsound, removed ~500 lines" | HIGH |
