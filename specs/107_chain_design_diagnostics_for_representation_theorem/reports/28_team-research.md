# Research Report: Task #107 — Final Blockers: g-Field, Circularity, Guard Convention

**Task**: 107 - Burgess chronicle construction for BX representation theorem
**Date**: 2026-04-25
**Mode**: Team Research (4 teammates, Opus)
**Session**: sess_1777155190_c7d7c9

## Summary

Three interconnected structural issues block the final 4 sorry sites. All four teammates converge on the diagnosis but diverge on the resolution path. The key findings:

1. **g_prop + temp_4 chaining does NOT work** (Teammate A): g_prop is adjacent-only, the limit is dense (g_prop vacuous), and g_prop never modifies existing f-values. The handoff's proposed resolution is invalid.

2. **Burgess's construction DOES populate g-values** (Teammate B): Every point insertion in Burgess creates g-values via Lemma 2.4/2.6. The codebase's empty-g approach is a fundamental divergence from Burgess, not an intentional simplification.

3. **Guard convention mismatch is real** (Teammate C): Codebase uses half-open `[t,s)`, Burgess uses open `(t,s)`. BX9 requires half-open (soundness depends on `t ≤ t`). But `U(φ,ψ) → φ` (needed for the base point) is valid under half-open but NOT derivable from current BX axioms.

4. **Sorry contamination is broader than reported** (Teammate D): The 2 C4 hard-case sorries contaminate the ENTIRE omega chain — `#print axioms` shows `sorryAx` in `limit_forward_G`, `cantor_fmcs`, all restricted coherence conditions. Previous claims of "sorry-free" were incorrect at the axiom level.

## The Three Blockers (Detailed)

### Blocker 1: Empty g-Field

The Chronicle structure has `g : Rat → Rat → Set Formula`, but:
- `singleton_chronicle` sets `g := fun _ _ => ∅`
- Every elimination function passes `chi.g` unchanged
- g-values are never populated at any stage

Burgess's construction populates g at every step:
- Lemma 2.4 (C5 elimination): Produces g(x,y) as R-maximal DCS
- Lemma 2.6 (C4 elimination): Produces g(x,z), g(z,y) splitting
- C3 defines non-adjacent g-values from adjacent ones

Without g, there is no C3 at the limit, and the Until guard at intermediate points cannot be established.

### Blocker 2: forward_G Circularity

`limit_forward_G` is proved via `limit_satisfies_c4`. But C4 with γ=⊤ always triggers the hard sub-case (G(⊤) is a theorem in every MCS). The hard sub-case (line 329) is sorry'd and its resolution requires forward_G — circular.

The g_prop mechanism cannot break this circle because:
- g_prop is adjacent-only (vacuous at the dense limit)
- g_prop inserts intermediate points but never changes f(y)
- f-values are immutable once a point enters the domain

### Blocker 3: Half-Open Guard Base Point

The codebase's Until semantics: `∃s, t < s ∧ ψ@s ∧ ∀r, t ≤ r → r < s → φ@r`

The guard includes the base point t (half-open `[t,s)`). To close restricted_fuc, we need `φ ∈ f(t)` from `untl(φ,ψ) ∈ f(t)`. BX9 gives `φ ∨ ψ`, not `φ` alone. The axiom `U(φ,ψ) → φ` is valid under half-open semantics but not in the current BX axiom system.

Changing to open guard is IMPOSSIBLE — BX9 soundness breaks.

## Resolution: Two-Phase Approach

### Phase 1: Add `until_guard` Axiom + Fix C4 Hard Case (8-12 hours)

**Step 1a**: Add axioms `until_guard : untl φ ψ → φ` and `since_guard : snce φ ψ → φ` to the BX system. These are sound under the half-open semantics (take `r = t` in the guard, since `t ≤ t`). This resolves the base-point gap. (~2h)

**Step 1b**: Fix the C4 hard sub-case by passing `ChronicleInvariant` (including C2') into the elimination function. Use R3Maximal_is_mcs to get g(x,y) as MCS, case-split on γ ∈ g(x,y):
- γ ∉ g(x,y): γ.neg ∈ g(x,y) by negation completeness, use as f(z). Done.
- γ ∈ g(x,y): Derive contradiction. If G(γ) ∈ f(x) and γ ∈ g(x,y), then by rRelation properties... (needs careful analysis, may require g to be non-empty)

**PROBLEM**: The C4 hard case uses g(x,y), but g is always empty. So even with C2', g(x,y) = ∅, which is NOT an MCS. R3Maximal_is_mcs requires R3Maximal(f(x), g(x,y), f(y)), but R3Maximal of ∅ is false.

**This means the C4 hard case CANNOT be fixed without populating g.**

### Phase 2: Populate g-Values (15-20 hours)

Modify each elimination function to also set g-values:
- C5 elimination: Use Lemma 2.4 to produce g(x,y) as R-maximal DCS
- C4 elimination: Use Lemma 2.6 to produce g(x,z), g(z,y)
- Density/g_prop: Define g for new pairs via C3 or fresh R-maximal construction
- Prove g-immutability
- Define proper `limit_g` as union of finite-stage g-values
- Prove C3 at the limit

With proper g + C3 + `until_guard`, all 4 sorry sites close:
- C4 hard case: R3Maximal of non-empty g gives MCS, negation completeness gives γ.neg
- restricted_fuc: `until_guard` for base point + C3 for intermediates

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Finding |
|----------|-------|--------|------------|-------------|
| A | g_prop+temp_4 | completed | HIGH | **g_prop approach INVALID** — adjacent-only, vacuous at limit, never modifies f(y) |
| B | Burgess g-values | completed | HIGH | **Burgess DOES populate g** — Lemma 2.4/2.6 produce g-values at every step |
| C | Guard convention | completed | HIGH | **Half-open vs open mismatch** — need `until_guard` axiom for base point |
| D | Holistic strategy | completed | HIGH | **Sorry contamination** via omega chain — all limit lemmas depend on sorryAx |

## Recommendation

**The minimum path to sorry-free `dd_countermodel_chronicle` requires populating g-values.** There is no shortcut. The empty-g approach was a simplification that must now be undone.

Estimated total remaining effort: **18-24 hours**.

1. Add `until_guard`/`since_guard` axioms (2h)
2. Redesign elimination functions to produce g-values (8-10h)
3. Prove g-immutability + define proper limit_g (3-4h)
4. Prove C3 at the limit (2-3h)
5. Close all 4 sorry sites (3-5h)

## References

- Burgess 1982, Lemma 2.4: C5 elimination produces g(x,y) via R-maximal construction
- Burgess 1982, Lemma 2.6: C4 elimination produces g(x,z), g(z,y) via three-way decomposition
- Truth.lean:127-128: Half-open guard `t ≤ r`
- Burgess 1982, line 39: Open guard `x < z < y`
- CounterexampleElimination.lean:329, 439: C4 hard sub-case sorry sites
- ChronicleToCountermodel.lean:964, 968: restricted_fuc sorry sites
