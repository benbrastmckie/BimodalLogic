# Handoff: g_sub_f_insert Implementation

## Status: IN PROGRESS

## What Was Done

Added `g_sub_f_insert` field to `EliminationResult` (CounterexampleElimination.lean:635):
```lean
g_sub_f_insert : ∀ a b, Adjacent χ.dom a b → ∀ w ∈ val.dom, w ∉ χ.dom →
    a < w → w < b → χ.g a b ⊆ val.f w
```

This property states: when a point w is inserted between adjacent (a,b) in the old domain, the old interval set g(a,b) flows into f'(w). This follows from B ⊆ D in all splitting lemmas (2.6, 2.7, 2.8).

### Cases handled (8 out of 18):
- **6 val=χ cases** (lines 977, 1339, 1626, 1946, 2201, 2442): Vacuously true since val.dom = χ.dom means w ∈ val.dom ∧ w ∉ χ.dom is impossible.
- **n=0 C5 case** (line 755→759): Vacuously true since y is placed after ALL old domain points, so no old adjacent pair (a,b) has a < y < b.
- **Walk Case A** (line 917→923): Same as n=0 — y after all old points.

### Cases remaining (9 sorry sites):
- **Walk Case B, η ∈ f(u_next)** (line 977): val=χ, already handled
- **Walk Case B, η ∉ f(u_next)** (line 1150): z = midpoint(u_max, u_next). Need χ.g(u_max, u_next) ⊆ D. The splitting result `h_split_result_u` produces D with B ⊆ D from lemma_2_6/2_7/2_8, but this fact is not currently exposed through the existential.
- **Not condition (i)** (line 1323): z = midpoint(pc.x, x'). Need χ.g(pc.x, x') ⊆ D. Same issue — B ⊆ D is inside splitting lemmas but not in `h_split_result`.
- **C5 backward cases** (lines 1449, 1582, 1753, 1930): Mirror of forward cases.
- **C4 forward/backward cases** (lines 2186, 2427): z = midpoint of adjacent pair. Need old g ⊆ new f.
- **Density case** (line 2594): z = midpoint. f(z) = χ.f(pc.x) (reusing existing MCS). Need χ.g(pc.x, pc.y) ⊆ χ.f(pc.x). This is NOT generally true and may need a different approach — the density case just copies f(pc.x), it doesn't include old g-values in the seed.

## How to Complete the Remaining Cases

### Strategy for splitting cases (lines 1150, 1323, and mirrors):

Enrich the `h_split_result` existential in the elimination to include `χ.g a b ⊆ D`:

**Current** (e.g., "Not condition (i)" at ~line 1144):
```lean
have h_split_result : ∃ B' D B'' : Set Formula,
    BurgessR3Maximal (χ.f pc.x) B' D ∧
    BurgessR3Maximal D B'' (χ.f x') ∧
    SetMaximalConsistent D ∧
    pc.η ∈ D
```

**Needed**:
```lean
have h_split_result : ∃ B' D B'' : Set Formula,
    BurgessR3Maximal (χ.f pc.x) B' D ∧
    BurgessR3Maximal D B'' (χ.f x') ∧
    SetMaximalConsistent D ∧
    pc.η ∈ D ∧
    χ.g pc.x x' ⊆ D
```

Each subcase of h_split_result calls a splitting lemma (2.6, 2.7, 2.8) that internally proves B ⊆ D. The enrichment requires:
1. In each subcase, extract the `h_B_sub_D` fact from the splitting lemma
2. Add it as the 5th conjunct in the existential
3. In the g_sub_f_insert proof, access `h_split_prop.2.2.2.2` for the subset fact

For lemma_2_7: `B ⊆ D` is at line 3639-3641 (exposed in the theorem output as part of the proof, but NOT in the return type). The return type is `∃ B' D B'', R3M(A,B',D) ∧ R3M(D,B'',C) ∧ MCS D ∧ η ∈ D ∧ B ⊆ B'`. Note: `B ⊆ B'` IS returned, but `B ⊆ D` is proved internally. Since `B ⊆ D` follows from `B ⊆ {lemma_2_7_seed ...} ⊆ D`, and this is proved at lines 3639-3641, the simplest fix is to enrich lemma_2_7's return type to also include `B ⊆ D`. Similar for lemma_2_6 and lemma_2_8.

Alternatively, since `lemma_2_7` already returns `B ⊆ B'` and `B'` comes from BurgessR3Maximal_extension_exists with seed B, we could try: `B ⊆ B'` from return, then... no, we need `B ⊆ D`, not `B ⊆ B'`.

### Strategy for density case (line 2594):

The density case uses `f(z) = f(pc.x)` — it just copies an existing MCS. The old g-value g(pc.x, pc.y) is NOT guaranteed to be a subset of f(pc.x). This case requires a DIFFERENT approach:

From BurgessR3Maximal(f(pc.x), g(pc.x, pc.y), f(pc.y)) and the fact that g is SDC:
- burgessRSet(f(pc.x), g, f(pc.y)): ∀ β ∈ g, ∀ γ ∈ f(pc.y), untl β γ ∈ f(pc.x)
- This does NOT give g ⊆ f(pc.x)

So `g(pc.x, pc.y) ⊆ f(pc.x)` is NOT true in general for the density case. The g_sub_f_insert property as currently stated may be too strong for the density case.

**Fix**: Either weaken g_sub_f_insert to only apply when the new point's f-value INCLUDES the old g-value (true for splittings but not for density), OR modify the density case to use a seed that includes the old g-value.

The simplest fix for the density case: change `f(z) = f(pc.x)` to use a Lindenbaum extension of `g(pc.x, pc.y) ∪ f(pc.x)_seed` that includes the old g-value. But this changes the density elimination structure.

Alternatively, just weaken the g_sub_f_insert to exclude density cases:
```lean
g_sub_f_insert : pc.kind = .c5_forward ∨ pc.kind = .c5_backward ∨ 
    pc.kind = .c4_forward ∨ pc.kind = .c4_backward →
    ∀ a b, Adjacent χ.dom a b → ...
```

But this makes the omega chain invariant harder since density steps also insert points.

**Best approach**: For the density case, the inserted point z has f(z) = f(pc.x). The g_sub_f_insert should hold vacuously for density IF we can show g(pc.x, pc.y) ⊆ f(pc.x). But this isn't generally true. 

HOWEVER: in the omega chain, when we need ξ ∈ f(w) for a point w inserted by a DENSITY step: the density step only inserts points to break adjacency (for C4/density satisfaction). The density insertion doesn't change f-values of existing points. For the C5 guard propagation, we need ξ ∈ f(w) where w was inserted between adjacent (a,b) in [x,y]. If this was a density insertion, f(w) = f(a) (or f(b)). But ξ might not be in f(a).

This suggests the g_sub_f_insert approach may not be sufficient for density cases. A different approach for those: prove that ξ propagates through f-values at OLD domain points (which the "not actual" C5 check establishes for the omega chain), and then handle new domain points differently depending on whether they were inserted by a splitting or density step.

## Key File Locations

- EliminationResult definition: CounterexampleElimination.lean:602-637
- g_sub_f_insert field: CounterexampleElimination.lean:635-637
- lemma_2_4 (n=0 C5): PointInsertion.lean:158
- lemma_2_4_with_guard (n=0 C5 + guard): PointInsertion.lean:4836
- lemma_2_6_splitting: PointInsertion.lean:2798 (B ⊆ D at line 2817)
- lemma_2_7: PointInsertion.lean:3616 (B ⊆ D at line 3639, B ⊆ B' at line 3631)
- lemma_2_8: PointInsertion.lean:3977 (B ⊆ D at line 4000)
- limit_satisfies_c5_strong: ChronicleConstruction.lean:1291 (sorry at 1301)
- limit_satisfies_c5'_strong: ChronicleConstruction.lean:1303 (sorry at 1313)

## Build Status

`lake build` passes with 11 sorry sites total:
- 2 in ChronicleConstruction.lean (the original target)
- 9 in CounterexampleElimination.lean (g_sub_f_insert)

## Recommended Next Steps

1. **Enrich splitting lemma return types** to include `B ⊆ D` (or enrich h_split_result existentials in the elimination)
2. **Fill in the 9 g_sub_f_insert sorry sites** using the enriched facts
3. **Handle density case** separately (may need to weaken g_sub_f_insert or modify density elimination)
4. **Prove omega chain guard invariant** in ChronicleConstruction.lean
5. **Close the 2 limit sorry sites** using the invariant
