# Deep Study: Verbrugge et al. 2004 — Completeness by Construction

## 1. Verbrugge's Adequate Set Construction (Theorem 6)

### The Adequate Set

A **Z-adequate set** Sigma (Definition 4) is a finite set of formulas closed under: (1) subformulas, (2) single negations, (3) containing G-bot and H-bot, and (4) if G-phi in Sigma and phi is not neg(G-psi), then G(neg(G-phi)) in Sigma (symmetrically for H). Given finite Phi with Phi not-provable-in-Z phi, the minimal Z-adequate set Sigma containing Phi union {neg-phi} is itself finite (Lemma 7). All MCS are then *relativized* to Sigma: Gamma is maximal Z-consistent *in Sigma* (Definition 5), meaning Gamma subset Sigma, Z-consistent, with no proper Z-consistent extension within Sigma. The redefined prec relation (Definition 6) strengthens the standard one: Gamma prec Delta iff (i) for each G-phi in Gamma, both phi and G-phi in Delta, and (ii) for each H-phi in Delta, both phi and H-phi in Gamma. This builds transitivity into the relation directly, compensating for the absence of GG-phi from Sigma.

### The Construction Step by Step

**Stage 0**: Create t_0 with Gamma_0 a maximal consistent extension of Phi union {neg-phi} within Sigma.

**Stage 1 (the maximal/minimal successor trick)**: Since Sigma is finite, the number of G- and H-formulas in Sigma is finite. Among all Delta with Gamma_0 prec Delta, there exist *maximal* Delta containing a maximal number of G-formulas and minimal number of H-formulas. Introduce t_r > t_0 with this maximal Gamma_r, and t_l < t_0 with a dually *minimal* Gamma_l (maximal H-formulas, minimal G-formulas).

**Stage 2+ (finite middle part)**: Treat neg-G-formulas in Gamma_l for which G-phi in Gamma_r. This is done formula-by-formula. For neg(G-phi) in Gamma_t with G-phi in Gamma_r (t < r), case (a): if neg(G(neg(G-phi))) in Gamma_t, use Lemma 9 and axiom Z1 to produce a new point t' > t with neg-phi and G-phi in Gamma_{t'}, permanently resolving neg(G-phi). Case (b): if neg(G(neg(G-phi))) not in Gamma_l, the adequate set closure (condition 4) forces either G(neg(G-phi)) in Gamma_l (contradicting P2 via Gamma_r) or phi = neg(G-psi) (contradicting maximality of Gamma_r). Both are inconsistent, so case (b) never actually arises. The key: each neg-G-formula is treated *once*, yielding a **finite stretch** between t_l and t_r.

**Cyclic tail extension**: Gamma_r is maximal, meaning any Gamma with Gamma_r prec Gamma has exactly the same G- and H-formulas as Gamma_r. Moving rightward from t_r, the same finite set of neg-G-formulas {neg(G-phi_1), ..., neg(G-phi_k)} recur cyclically (k >= 1 since neg(G-bot) is always present). These are resolved by cyclically inserting successors with neg(phi_i). This produces a Z-copy extending infinitely to the right. The mirror gives a Z-copy to the left.

### Why Intervals are Automatically Finite

The finiteness comes from **three interacting mechanisms**:

**(a) Finite adequate set**: Sigma is finite, so there are only finitely many distinct relativized MCS within Sigma. The construction only ever works with these.

**(b) Maximal/minimal successor choice**: By choosing Gamma_r with maximal G-content and Gamma_l with maximal H-content at Stage 1, the set of "unresolved" neg-G-formulas (those in Gamma_l but whose positive form is in Gamma_r) is finite and fixed.

**(c) Permanent resolution in case (a)**: When neg(G-phi) is resolved by inserting a point with G-phi in its MCS, no further treatment of neg(G-phi) is ever needed (the paper: "Hereafter, neg(G-phi) will not have to be treated again, because since G-phi in Gamma_{t'}, t' > u for any u with neg(G-phi) in Gamma_u"). Case (b) is vacuous. Therefore the middle part construction terminates in finitely many stages.

The result: a finite middle stretch t_l ... t_r, extended by two infinite tails (the cyclic construction), producing a model isomorphic to Z. The interval [t_l, t_r] has finitely many points by construction.

## 2. How Our Construction Differs

Our omega-chain (ChronicleConstruction.lean) enumerates ALL tuples (Rat x Rat x Formula x Formula x Kind) via Denumerable and processes them one at a time. The structural consequences:

**Unrestricted formula space**: We work with full (non-relativized) MCS over all formulas, not MCS restricted to a finite adequate set. The counterexample enumeration is over all formulas, not a finite subset.

**No maximal successor**: We never choose a successor with maximal G-content. Each elimination step (eliminate_potential_counterexample) inserts a fresh point whose MCS is determined by Lindenbaum extension of a seed set, without any maximality constraint on G-content.

**No finite middle part**: Since we process an infinite enumeration of all possible counterexamples, there is no point at which we can say "the middle part is finished." The construction produces a countable dense subset of Rat (in the dense case) or a countable discrete subset (in the discrete case).

**The sorry site**: The single remaining sorry (line 1303 of ChronicleToCountermodel.lean) needs to find a domain point at the real-valued limit L of a succ-orbit. The proof establishes: the succ-orbit {succ^n(a)} converges to some L in R, and the pred-orbit {pred^k(b)} is bounded below, and these two sequences are separated. The gap: proving that a domain point actually exists at value L. In Verbrugge's construction, this problem simply does not arise because finiteness of the adequate set ensures that only finitely many distinct MCS appear in any tail, forcing cyclic repetition and making IsSuccArchimedean trivial.

## 3. Could We Modify Our Construction to Use Adequate Sets?

Adopting Verbrugge's adequate sets would require:

**Redefining MCS**: Replace `SetMaximalConsistent` with `SetMaximalConsistentIn Sigma` throughout the chronicle construction. This touches ChronicleTypes.lean (Chronicle structure, c0-c5 conditions), RRelation.lean (rRelation, rMaximal), PointInsertion.lean (all Lindenbaum extensions), and CounterexampleElimination.lean.

**Adding Stage 1**: Insert a maximal/minimal successor selection phase between singleton creation and the omega-chain. This is new code with no current analog.

**Restricting the enumeration**: Change the omega-chain to enumerate only counterexamples within Sigma, making it finite rather than omega-indexed. This changes the fundamental structure from a countable limit to a finite construction.

**Rebuilding the truth lemma**: The restricted truth lemma (RestrictedParametricTruthLemma.lean) would need to work with Sigma-relativized MCS instead of full MCS.

This is essentially a ground-up rebuild of the chronicle pipeline.

## 4. The Maximal Successor Trick

The "maximal successor" choice is the heart of why Verbrugge's intervals are finite. When Gamma_r has maximal G-content among all successors of Gamma_0, any further successor Gamma with Gamma_r prec Gamma necessarily has exactly the same G-formulas as Gamma_r. This means:

- Moving rightward from t_r, no new G-formulas appear or disappear.
- The set of neg-G-formulas needing treatment is fixed and finite.
- Each neg-G-formula can be resolved cyclically (the tail extension).

Our construction does nothing analogous. Each eliminate_potential_counterexample call produces a fresh MCS via Lindenbaum extension with no constraint on G-content relative to neighbors. The G-content of successive domain points can vary arbitrarily, preventing the stabilization argument.

## 5. Can We Extract Just the Finiteness Argument?

**No, not directly.** The finiteness of intervals in Verbrugge is a structural consequence of working within a finite formula space (the adequate set). Our construction works in the full infinite formula space. We cannot retroactively prove that our limit domain has the "adequate set property" because:

- Our MCS are full MCS (infinite sets of formulas), not Sigma-relativized.
- Our counterexample enumeration processes ALL formula pairs, not just those in a finite Sigma.
- The omega-chain adds points addressing counterexamples from the entire formula language.

However, we can extract a *different* argument for IsSuccArchimedean that does not require adequate sets. The sorry requires proving: if the succ-orbit from a is bounded above by b, then some succ-iterate reaches b. The construction-specific fact needed is: for any accumulation point L of the succ-orbit in R, there exists a domain point at L. This follows if we can show: whenever infinitely many domain points accumulate toward L from below, the omega-chain eventually inserts a point at (or above) L that "caps" the accumulation. This is a property of how eliminate_potential_counterexample places new rational points relative to existing ones, not an adequate-set property.

## 6. Formalization Cost Estimate

**Full Verbrugge adoption**: approximately 2000-3000 lines of new Lean code:
- New Sigma-relativized MCS infrastructure: ~400 lines
- Adequate set definition and closure properties: ~300 lines  
- Maximal/minimal successor existence and selection: ~400 lines
- Finite middle part construction with case (a)/(b) analysis: ~500 lines
- Cyclic tail extension: ~300 lines
- New truth lemma for restricted MCS: ~500 lines
- Modifications to existing files: ~500 lines across ChronicleTypes, RRelation, PointInsertion, CounterexampleElimination

**Blast radius**: ChronicleConstruction.lean (complete rewrite), ChronicleToCountermodel.lean (complete rewrite), ChronicleTypes.lean (major modifications), CounterexampleElimination.lean (major modifications), PointInsertion.lean (major modifications). Approximately 5-6 files with deep changes, plus downstream effects in the completeness theorem integration.

**Alternative**: Fix the sorry directly by proving the accumulation-point property of the omega-chain. This requires approximately 50-100 lines of new code in ChronicleToCountermodel.lean and touches only that file. The argument: use the fact that the counterexample enumeration covers all (x, xi, eta) tuples, so for any accumulation point L, there exist domain points arbitrarily close to L on both sides, and the discrete-case hypothesis (U(T,bot) in all MCS) forces an immediate successor to exist, which the omega-chain must eventually provide.

## 7. Recommendation

**Do not adopt Verbrugge's method.** The construction solves a different problem (completeness of Z, a pure tense logic without Until/Since) and its finiteness mechanism (adequate sets with finitely many relativized MCS) is incompatible with our setting (bimodal logic TM with full Until/Since operators requiring unrestricted MCS). The cost of adoption is a complete rewrite of the chronicle pipeline (~3000 lines changed, ~2500 lines new), while the single sorry it would resolve can likely be fixed with ~100 lines of construction-specific reasoning about accumulation points in the omega-chain.
