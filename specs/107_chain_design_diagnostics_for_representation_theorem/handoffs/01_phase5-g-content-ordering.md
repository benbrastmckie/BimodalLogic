# Handoff: Phase 5 -- g-Content Ordering Challenge

## Session: sess_1777430894_36ad0b

## Status

Phase 5 is PARTIAL. The key infrastructure theorem `burgessR3Maximal_from_g_content_sub` has been added and compiles. But using it to close the sorry sites requires resolving a mathematical challenge with g_content ordering at finite stages of the omega chain.

## What Was Accomplished

### New theorem in RRelation.lean (lines 1419-1497)

Added `burgessR3Maximal_from_g_content_sub`:
```
theorem burgessR3Maximal_from_g_content_sub {A C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A) (h_mcs_C : SetMaximalConsistent C)
    (h_gc : g_content A ⊆ C) :
    ∃ B : Set Formula, BurgessR3Maximal A B C
```

This is the core infrastructure: given two MCS A, C with `g_content(A) ⊆ C`, BurgessR3Maximal(A, B, C) exists. The proof uses the tautology `top = bot.imp bot` as seed:
- `burgessR(A, top, C)`: from `g_content(A) ⊆ C`, for all `gamma in C`, `G(neg gamma) not in A`, so `F(gamma) in A`, then `F_until_equiv` gives `U(top, gamma) in A`.
- `burgessRSince(C, top, A)`: from `g_content(A) ⊆ C`, for all `alpha in A`, BX4 gives `G(P(alpha)) in A`, so `P(alpha) in g_content(A) ⊆ C`, then `P_since_equiv` gives `S(top, alpha) in C`.

Also added helper lemmas `F_mem_of_g_content_sub` and `P_mem_of_g_content_sub`.

Build passes: `lake build` succeeds (723 jobs).

## The Core Challenge

The 7 c2' sorry sites in CounterexampleElimination.lean require constructing `BurgessR3Maximal(f(a), g'(a,b), f(b))` for new adjacent pairs (a, b) created by each elimination function. The theorem `burgessR3Maximal_from_g_content_sub` handles this IF `g_content(f(a)) ⊆ f(b)`.

### When it works (x = x_max)

For the C5 forward case: lemma_2_4 applied to f(x) gives C with `g_content(f(x)) ⊆ C`. The new point y > all dom. The adjacent pair is (x_max, y). IF x = x_max, then the pair is (x, y) and `g_content(f(x)) ⊆ f(y) = C`. Apply `burgessR3Maximal_from_g_content_sub`. Done.

### When it fails (x < x_max)

If x < x_max, the adjacent pair is (x_max, y), and we need `g_content(f(x_max)) ⊆ f(y)`. We only have `g_content(f(x)) ⊆ f(y)`. The g_content ordering does NOT chain through finite stages: `g_content(f(x)) ⊆ f(y)` does NOT imply `g_content(f(x_max)) ⊆ f(y)`.

### Key mathematical insight

The g_content ordering (`g_content(f(a)) ⊆ f(b)` for a < b) is NOT maintained at finite stages of the omega chain because:
1. The singleton chronicle starts with g = empty_set
2. Each elimination step uses g = chi.g (unchanged)
3. So g never gets constructed, and g_content ordering between adjacent MCS is never established

This is the ROOT CAUSE identified in the research (report 42): g-values are never constructed.

### Why g_content ordering is needed

To construct BurgessR3Maximal(A, B, C), we MUST have `g_content(A) ⊆ C`. Without this:
- `burgessR3(A, S, C)` for any DCS S requires `F(gamma) in A` for all `gamma in C`
- `F(gamma) in A` iff `G(neg gamma) not in A` iff `neg gamma not in g_content(A)`
- If `g_content(A) not subset C`, there exists gamma in C with `neg gamma in g_content(A)`, giving `G(neg gamma) in A` and `F(gamma) not in A`
- So the theorem seed approach FAILS

### Density case (self-pair)

The density sorry site requires BurgessR3Maximal(f(x), B, f(x)) (same MCS on both sides). This needs `g_content(f(x)) ⊆ f(x)`, which is the T-axiom G(phi) -> phi. This is INVALID under irreflexive semantics. So the density case requires a fundamentally different approach.

## Proposed Solutions

### Option A: Change point placement (recommended for C5)

Modify `eliminate_C5_counterexample` to place y BETWEEN x and x_next (or after x if x is max), instead of at the maximum. Then:
- (x, y) pair: `g_content(f(x)) ⊆ C` from lemma_2_4. Use `burgessR3Maximal_from_g_content_sub`.
- (y, x_next) pair: Need Lemma 2.6 splitting of the old g(x, x_next). This is the Phase 5/Phase 8 splitting infrastructure.

This approach merges Phase 6 and Phase 8 into a single solution.

### Option B: Propagate g_content via Lemma 2.5b chain (hard)

Prove that g_content ordering chains through finite stages. This requires showing that the properly-constructed g-values from Option A give `g_content(f(a)) ⊆ f(b)` for all a < b (not just adjacent pairs). This follows from C3 (three-way intersection) at the limit but needs to be established at finite stages.

### Option C: Modify omega chain to NOT require c2' at finite stages (major refactor)

Remove c2' from EliminationResult and instead:
1. Track g-values separately
2. Prove c2' at the LIMIT (where C5 is satisfied and g_content ordering is available)
3. Use a weaker invariant at finite stages

This is a large structural change to ChronicleConstruction.lean.

### Option D: For density, construct g via empty DCS (possible)

For the density self-pair case (BurgessR3Maximal(A, B, A)):
- Check whether any formula eta in A satisfies burgessR(A, eta, A)
- If not, BurgessR3Maximal(A, empty_DCS, A) where empty_DCS = deductiveClosure({top})
- The maximality of empty_DCS needs to be proved: show no formula can be added

## Files Modified

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` -- added `burgessR3Maximal_from_g_content_sub`, `F_mem_of_g_content_sub`, `P_mem_of_g_content_sub` (lines 1419-1497)

## Recommendation

Run `/revise 107` to revise the plan. The plan v26 assumes g_content ordering is easy to establish, but it requires either:
1. Changing point placement (merging Phases 6 and 8 into a single splitting-based approach)
2. A fundamentally different invariant at finite stages (major refactor)

The simplest path forward is Option A: change C5/C5' elimination to place the new point adjacent to x (not at the max), and use Lemma 2.6 splitting for the other half of the split pair. This unifies the Phase 6 and Phase 8 approaches.
