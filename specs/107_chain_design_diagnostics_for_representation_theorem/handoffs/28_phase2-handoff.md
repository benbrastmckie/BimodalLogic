# Handoff: Task 107 Phase 2 Implementation

## Session Context
- **Session ID**: sess_1777252883_2d8267
- **Agent**: lean-implementation-agent
- **Plan**: specs/107_.../plans/28_implementation-plan.md (v15)
- **Phase**: 2 (Extend EliminationResult and Populate g in C5/C5')
- **Status**: Analysis complete, implementation not started

## Key Analysis Findings

### Circularity Between forward_G and C4

The codebase has a fundamental circular dependency:
1. `limit_forward_G` (ChronicleConstruction.lean:979) uses `limit_satisfies_c4` (line 1031)
2. `limit_satisfies_c4` (line 734) uses `omega_chain_c4_witness` -> `eliminate_C4_counterexample`
3. `eliminate_C4_counterexample` has sorry at the hard sub-case (line 329)

This means ALL of the following are sorry-tainted:
- `limit_forward_G` and `limit_backward_H`
- `cantor_fmcs` (forward_G/backward_H fields)
- `cantor_bfmcs` (through cantor_fmcs)
- `cantor_bfmcs_restricted_buc` (uses limit_satisfies_c4)
- `dd_countermodel_chronicle` (uses all of the above)

### Breaking the Cycle Requires g-Population

The circularity CANNOT be broken by proving C4 at the limit level (I explored this extensively). The reason: proving C4 at the limit for the hard case requires forward_G, which uses C4. A shortcut proof using BX2+BX12 was developed but ultimately requires forward_G in a sub-step (to derive G(neg(eta)) at y from G(neg(eta)) at x).

The correct approach (matching Burgess 1982) is to:
1. Maintain C0+C1+C2'+C3 (ChronicleInvariant) at every finite stage
2. Use C2' (R3Maximal for adjacent pairs) to prove the C4 hard case at the finite stage
3. Derive forward_G at the limit from C4 (as currently done)

This requires populating g-values at every elimination step (Phases 2-3).

### C4 Hard Case Resolution (Phase 5 Preview)

Once g-values are populated and R3Maximal is maintained (C2'), the C4 hard case at line 329 resolves as follows:

Given: G(gamma) in f(x), H(gamma) in f(y), neg(untl(gamma,delta)) in f(x), delta in f(y), x < y, adjacency(x,y)

1. R3Maximal(f(x), g(x,y), f(y)) from C2' (adjacent pair)
2. g(x,y) is an MCS by R3Maximal_is_mcs
3. Case split: gamma in g(x,y) vs gamma.neg in g(x,y) (MCS negation completeness)
4. BX2+BX12 argument: G(gamma) at x + gamma at x -> F(eta) implies untl(gamma,eta) at x.
   Since neg(untl(gamma,eta)) at x, we get neg(F(eta)) = G(neg(eta)) at x.
   R3Maximal gives rRelation(f(x), g(x,y)). For untl(gamma,delta.neg.neg) in...
   (the detailed argument needs the r-relation properties of g(x,y))

Alternatively: simply use g(x,y) as the MCS for the inserted point z. Since g(x,y) is an MCS containing gamma.neg (by case split), assign f(z) = g(x,y). Done.

Wait -- that's even simpler. If gamma.neg in g(x,y), then f(z) = g(x,y) works directly (it's an MCS with gamma.neg). If gamma in g(x,y), then we need a different argument (which may involve the r-relation).

### Forward Until Coherence (Phase 6 Preview)

`cantor_bfmcs_restricted_fuc` (lines 964, 968) needs:
- untl(phi,psi) at t -> exists s > t with psi at s AND phi at r for [t,s)

Base point (r=t): phi at t from until_guard. DONE (sorry-free).
Endpoint: exists s > t with psi at s from C5_weak. DONE (sorry-free).
Guard at intermediate r: phi at r for t < r < s. NEEDS g-function + C3.

With proper limit_g and limit_c3 (from Phase 4):
- C5 gives witness y with untl(phi,psi) persisting at intermediate domain points
- C3 gives g(x,y) subset f(z) for intermediate z
- The r-relation ensures phi in g(x,y) from untl(phi,psi) in f(x)

### Sorry Site Classification

| File | Lines | Type | Dependency |
|------|-------|------|------------|
| CounterexampleElimination.lean | 329 | C4 hard case (Until) | Blocks limit_satisfies_c4 |
| CounterexampleElimination.lean | 439 | C4' hard case (Since) | Blocks limit_satisfies_c4' |
| ChronicleToCountermodel.lean | 536, 541 | chronicle_fmcs forward_G/backward_H | DEAD CODE (use cantor_fmcs) |
| ChronicleToCountermodel.lean | 713, 716, 735, 738, 767, 770 | chronicle_bfmcs coherence | DEAD CODE (use cantor_bfmcs) |
| ChronicleToCountermodel.lean | 964 | cantor restricted_fuc Until | Needs full C5 with guard |
| ChronicleToCountermodel.lean | 968 | cantor restricted_fuc Since | Needs full C5' with guard |

Active sorry sites: 4 (lines 329, 439, 964, 968)
Dead code sorry sites: 8 (lines 536, 541, 713, 716, 735, 738, 767, 770)

### Implementation Approach for Phase 2

#### Step 1: Extend EliminationResult

Add a `g_agrees` field to EliminationResult:
```lean
g_agrees : ∀ a b, a ∈ χ.dom → b ∈ χ.dom → val.g a b = χ.g a b
```

This says: for pairs of points that were in the OLD domain, the g-values are preserved.

#### Step 2: Extend EliminationResult with g-validity for new pairs

For C5 elimination, the new point y is placed beyond all domain points. The only new adjacent pair is (max_old, y). We need:

```lean
c2'_new : ∀ a b, Adjacent val.dom a b →
  (a ∈ χ.dom → b ∈ χ.dom → R3Maximal (val.f a) (val.g a b) (val.f b)) →
  R3Maximal (val.f a) (val.g a b) (val.f b)
```

Or more practically: maintain the full ChronicleInvariant.

#### Step 3: Construct g-value for (max_old, y) in C5 elimination

The seed for R3Maximal construction:
1. Start with deductiveClosure(g_content(f(max_old)))
2. This is a DCS satisfying rRelation(f(max_old), -)
3. Need to also satisfy rRelationSince(f(y), -) for the three-argument version
4. Use `r3Maximal_extension_exists` with appropriate seed

The seed needs r3Relation(f(max_old), S, f(y)). Building this:
- For rRelation(f(max_old), S): the deductiveClosure of g_content(f(max_old)) works
  (by construction, for untl(gamma,delta) in f(max_old), G(gamma) gives gamma in g_content,
  and G(untl(gamma,delta)) via temp_4 gives untl(gamma,delta) in g_content)
  Hmm, this is not exactly right. Need to verify the r-relation carefully.

Actually, the simplest seed: use g_content(f(max_old)) ∩ h_content(f(y)). If this is consistent, its deductive closure is a DCS satisfying both rRelation from the left and rRelationSince from the right (by construction). Then extend to R3Maximal via Zorn.

The consistency of g_content(f(x)) ∩ h_content(f(y)) for x < y follows from... this may need a dedicated lemma (related to the connect_future/connect_past axioms BX4/BX4').

#### Step 4: Define new g for the extended chronicle

```lean
let new_g := fun a b =>
  if a ∈ χ.dom ∧ b ∈ χ.dom then χ.g a b  -- old pairs: carry forward
  else if (a = max_old ∧ b = y) then R3Max_val  -- new adjacent pair
  else ∅  -- non-adjacent or involving y but not adjacent
```

The non-adjacent pairs with y (e.g., any a < max_old and b = y) get g defined by C3:
g(a, y) = g(a, max_old) ∩ f(max_old) ∩ g(max_old, y)

But this only applies at the limit; at finite stages we can set them to the intersection.

### Key Files to Modify

1. `CounterexampleElimination.lean` - EliminationResult, elimination functions
2. `ChronicleConstruction.lean` - omega chain, limit construction
3. `ChronicleTypes.lean` - possibly extend ChronicleInvariant
4. `RRelation.lean` - may need new r-relation seed lemmas
5. `PointInsertion.lean` - may need new Lemma 2.4 variant with g-value output

### Estimated Remaining Work

- Phase 2 (C5/C5' g-population): 4-6 hours
- Phase 3 (C4/C4', density, g_prop g-population): 6-8 hours
- Phase 4 (g-immutability, limit_g, C3 at limit): 4-6 hours
- Phase 5 (C4 hard case closure): 2-4 hours
- Phase 6 (restricted_fuc closure): 2-4 hours
- Total: 18-28 hours

### Recommendation for Next Session

1. Start with proving the r-relation seed lemma: given MCS A and C with A < C in the chronicle order, g_content(A) ∩ h_content(C) is consistent, and its deductive closure satisfies r3Relation(A, -, C). This is the key building block.

2. Then extend EliminationResult with a minimal g-agreement field.

3. Modify C5 elimination to use the seed lemma + r3Maximal_extension_exists.

4. Verify with `lake build` at each step.
