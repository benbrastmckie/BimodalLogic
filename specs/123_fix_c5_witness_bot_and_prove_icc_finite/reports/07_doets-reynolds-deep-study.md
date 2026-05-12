# Deep Study: Doets 1987 and Reynolds 1994

## The Sorry Site

The codebase sorry (line 1303 of `ChronicleToCountermodel.lean`) needs: given a succ-orbit `s^[n](a)` bounded above by `b`, find a domain point `c` with `c.val = L` (the supremum in R) such that `s^[n](a) < c` for all `n`. The obstacle is ruling out that L falls in a "gap" of the domain -- a limit point in R with no corresponding rational in `limit_dom`.

## Doets 1987 (Chapter 7)

### Axioms

Doets axiomatizes Z-time with: **trans** (`Gp -> GGp`), **succ** (`FT; PT`), **r-lin** (`Fp -> G(Fp v p v Pp)`), **l-lin** (`Pp -> H(Pp v p v Fp)`), and two **modified Lob** axioms (`G(Gp -> p) -> (FGp -> Gp)` and its mirror). These are axioms for F/P, not U/S. Our codebase uses U/S with the Burgess-Xu axioms plus Prior-UZ/SZ and discreteness, which is strictly more expressive. The mapping is: Doets's trans/succ/r-lin/l-lin correspond to standard linear-order properties derivable from Burgess-Xu, while his modified Lob axioms serve the role our Prior axioms serve -- forcing finite intervals.

### The Modified Lob Axiom

`G(Gp -> p) -> (FGp -> Gp)` says: if every future point where `Gp` holds also satisfies `p`, then `p` being eventually always true implies `p` is always true from now. Contrapositive: if `Fp` (equivalently `~G~p`) and `FG~p` both hold, then some point satisfying `G~p` also satisfies `~(G~p -> ~p)`, i.e., both `G~p` and `p`. This forces bounded definable sets to have maxima (Claim 10), which is the discrete analogue of "no definable gaps."

### Claims 9-11: The Proof Architecture

**Claim 9**: Given the Henkin model `(M, R, V)` satisfying the axioms, Doets constructs `N = sum_{A in M/~} A*` where each equivalence class `A` under the reflexive-transitive closure is replaced by either a singleton (irreflexive point) or a copy of `(Z, <)` containing all "shapes" (propositional-variable patterns) that occur in `A`. The Ehrenfeucht game argument shows: if `x in A` and `n in A*` have the same shape, then for all formulas phi over VAR_chi, `M |= phi[x]` iff `N |= phi[n]`. Player II's strategy maintains the invariant that matched pairs `(y, m)` always share the same equivalence class membership and the same shape. This works because `A*` has order type zeta and every shape occurring in `A` appears unboundedly often in `A*`.

**Claim 10**: The modified Lob axiom forces definable subsets of `N` that are bounded to have extrema. If `phi^N` is non-empty and upward bounded, it has a maximum. Proof: take `n` satisfying `phi` and `m < n`. Then `m` satisfies `F(phi)` and `FG(~phi)`. The modified Lob axiom (with `~phi` for `p`) gives `~G(G(~phi) -> ~phi)` at `m`, yielding `k > m` with both `G(~phi)` and `phi` -- the maximum.

**Claim 11**: Using `k = rank(chi)`, the set `T` of k-characteristics in `N` is finite. `T+` collects those whose carrier is upward bounded (each has a maximum by Claim 10). A submodel `A` of order type zeta is carved out: a finite set `A_0` of extremal points, an omega-tail `A+` above them, an omega*-tail `A-` below. Every non-bounded k-type appears infinitely often in both tails. The proof that `A |= psi[x]` iff `N |= psi[x]` (for rank-k formulas and `x in A`) is by induction: if `N |= F(psi)[x]`, some `y > x` has `N |= psi[y]` with k-type tau; by construction of `A`, some `z > x` in `A` shares that k-type, so `N |= psi[z]`, and by induction hypothesis `A |= psi[z]`.

### Could Claims 10-11 Apply to Our Construction?

In principle yes, but there are two barriers:

1. **Claim 9 requires the Ehrenfeucht game for tense logic.** The n-characteristic `[[a]]^n` is a tense-logical formula coding game-theoretic behavior. Formalizing this requires: (a) defining the restricted Ehrenfeucht game for tense logic (Chapter 6), (b) proving the equivalence between game-winning, formula satisfaction, and n-characteristics (Theorem 6.4), (c) constructing the ordered sum `N`. This is a substantial formalization undertaking -- the game theory alone (Chapters 1 and 6) spans ~50 pages.

2. **Claim 11 is a condensation/extraction argument** that produces a submodel of type zeta from one of type `sum of zeta's and 1's`. The key insight is that finitely many k-types exist, bounded types have extrema, and unbounded types can be sampled infinitely often. This is cleaner than our current real-analysis approach but requires the full n-characteristic machinery.

### Does Doets Require Kamp's Theorem?

**No.** Doets works entirely with F/P (the basic temporal language), not U/S. His proof never invokes expressive completeness. The n-characteristics are tense-logical formulas built from F, P, and propositional connectives. This is a significant advantage: no dependency on Kamp's theorem or Stavi connectives.

## Reynolds 1994 (Sections 5-8)

### The Contemporaneous Equivalence Relation

For a structure M in a finite language, Reynolds defines `a ~_M b` iff `a = b`, or `a < b` and `M|[a,b]` is "very good" (every subinterval `M|[t,u]` is "good"), or symmetrically. "Good" means: there exists `N =_k M|[t,u]` whose flow of time is an interval of Z. The definition is contemporaneous because `~_M` depends only on the substructure between `a` and `b`.

### Theorem 14: No Gaps Between Classes

The proof proceeds through a chain of lemmas (6-13). The key steps:

- **Lemma 6** (expressive completeness): The formula `R` detecting right-gaps of ~-classes exists as a U/S-formula in any Prior structure, because the Prior axioms eliminate Stavi-connective definable gaps, making U/S expressively complete (Theorem 5).

- **Lemma 7**: Maximal R-intervals are open with excluded endpoints in M (using Prior-U to rule out gap-bounded stretches without first/last points).

- **Lemma 9**: Within any maximal R-interval, every temporal formula that holds somewhere in one ~-class holds somewhere in every ~-class. This uses expressive completeness to convert monadic properties into temporal formulas, then Prior-U to prevent the formula from holding in some classes but not others.

- **Lemma 12**: Replacing a whole bad interval by a single ~-class preserves all temporal formulas (induction on formula construction, using Lemma 9's uniformity).

- **Lemma 13**: The replacement structure N is still a Prior structure, yet R holds in the surviving class -- contradicting that R detects right-gaps (the class, now in a structure where its right endpoint is a genuine boundary, doesn't end at a gap).

### Role of Expressive Completeness

**Critical.** Reynolds's proof depends on Theorem 5: U/S is expressively complete over Prior structures. This is used at three points: constructing the gap-detecting formula R (Lemma 6), showing formula-uniformity across ~-classes (Lemma 9), and in the gap-class replacement argument (Lemma 12). Without expressive completeness, the proof collapses.

Theorem 5 itself depends on Theorem 4 (Stavi connective completeness for all linear flows), attributed to Gabbay-Pnueli-Shelah-Stavi 1980 with first published proof in Gabbay-Hodkinson-Reynolds 1993. The argument: in a Prior structure, U'(A,B) is equivalent to bot (gaps cannot exist), so every {U,S,U',S'}-formula reduces to a {U,S}-formula.

### Could We Adapt Just Theorem 14?

Not easily. The gap-freeness argument is the conceptual heart, but it requires:
1. Expressive completeness of U/S over Prior structures (Theorem 5)
2. Which requires Stavi connective completeness (Theorem 4)
3. Which requires either the Gabbay separation theorem or a direct combinatorial proof

The minimal dependency chain is: Stavi connectives -> expressive completeness over all linear flows -> Prior structures eliminate Stavi connectives -> U/S expressively complete over Prior structures -> gap-detection formula exists -> Theorem 14.

## Comparison and Feasibility Assessment

### Formalization Footprint

**Doets**: Requires formalizing the Ehrenfeucht game for tense logic (~200 lines for game definition, ~300 lines for n-characteristics and Theorem 6.4, ~200 lines for Claims 9-11). Total estimate: 700-1000 lines of new Lean. No dependency on Kamp's theorem or Stavi connectives.

**Reynolds**: Requires formalizing expressive completeness of U/S over Prior structures. This means: defining Stavi connectives, proving their expressive completeness for all linear flows (a deep result), then showing Prior axioms collapse them to bot. Total estimate: 1500-2500 lines, with the Stavi/expressive completeness machinery being reusable but expensive.

### Mathematical Elegance

Doets's proof is more elegant: it works entirely within the F/P language, uses classical model-theoretic tools (EF games, condensations), and the final extraction (Claim 11) is a clean finite combinatorial argument. Reynolds's proof is more "applied" -- it works with U/S directly and produces Z-models from arbitrary discrete models, but pays for this with the expressive completeness dependency.

### Fit with Existing Codebase

**Reynolds fits better structurally.** Our codebase already works with U/S, uses the Burgess-Xu result (Reynolds's Theorem 2 / our Corollary 3), and has Prior-UZ/SZ as axioms. The contemporaneous equivalence relation ~_M is defined using k-equivalence of substructures, which maps naturally to our `limit_dom` subtype construction. The "very good interval" concept is close to our existing notion of intervals admitting Z-isomorphisms.

**Doets requires a language shift.** His proof works with F/P, and the n-characteristics are F/P formulas. Our formulas are U/S. To apply Doets, we would need either (a) an F/P sublanguage extraction, or (b) extending n-characteristics to U/S (which Doets does not do and which would complicate the game theory).

### Prohibitive Dependencies

**Reynolds**: Expressive completeness (Kamp's theorem generalized via Stavi connectives). This is a major theorem in its own right. However, the dependency is narrower than it appears: we only need that U'(A,B) is equivalent to bot in Prior structures, which follows from the semantic definition of U' plus Prior-U. The full power of Kamp's theorem is not needed -- only the Stavi elimination argument, which is a one-page proof given Prior-U validity.

**Doets**: The Ehrenfeucht game for tense logic (Chapter 6) and n-characteristics. Less mathematically deep but requires substantial formalization of game-theoretic concepts not currently in our codebase or Mathlib.

## Recommendation

**Neither method should be adopted wholesale.** Both are overkill for the specific sorry site.

The sorry at line 1303 asks: given a monotone bounded sequence in `limit_dom` (cast to R), show its supremum is realized by a domain point. This is a property of the omega-chain construction, not a consequence of axioms. The fix should come from proving that `limit_dom` is closed under limits of its own succ-orbits -- a construction-specific property of the Burgess chronicle.

If a more radical architectural change is desired, Doets's approach (Claims 10-11) has the smallest dependency footprint because it avoids expressive completeness entirely. But it requires building n-characteristic infrastructure that has no other use in the codebase. Reynolds's approach integrates better with the existing U/S framework but requires proving expressive completeness, which is a 1500+ line detour.

The most pragmatic path: prove the sorry directly from properties of the omega-chain construction, treating it as a closure property of `limit_dom` rather than a consequence of temporal-logical axioms.
