# Literature Study: Discrete Completeness in Burgess 1982 and Venema 1993

## Focus

How do Burgess and Venema handle the discrete case in completeness proofs for SU-tense logic, and what proof technique ensures the constructed model has no gaps (is isomorphic to Z or omega)? What is the analogue of `IsSuccArchimedean` in the literature?

## 1. Burgess 1982: The Chronicle Construction

Burgess proves completeness for SU-tense logic over arbitrary linear orders (J_0 for K_0) using a **step-by-step chronicle extension** method. The core construction works as follows:

**Chronicles.** A chronicle is a pair (f, g) where f maps rational numbers to MCSs and g maps pairs to deductively closed sets describing "what holds throughout the interval." The key conditions are:

- **(C2')** Adjacent points satisfy the maximality relation R(f(x), g(x,y), f(y))
- **(C3)** Interval labels compose: g(x,z) = g(x,y) intersect f(y) intersect g(y,z)
- **(C4a/b)** Counterexample elimination for negated Until/Since
- **(C5a/b)** Witness existence for Until/Since

**Omega-chain construction.** Starting from a single-point chronicle, Burgess iteratively eliminates counterexamples to C4 and C5. Each step adds a single rational number to the domain and defines f and g on the enlarged domain. The limit of this omega-chain is a perfect chronicle on a subset of Q.

**Key point: Burgess does NOT construct discrete models in the 1982 paper.** Section 1.6 states that discrete completeness follows by "routine adaptation" of the base construction when adding the discreteness axiom G'bot /\ H'bot (equivalent to next_top /\ prev_top). He does not spell out how the discrete construction ensures gap-freedom.

## 2. Burgess 1984: Discrete Completeness via Successor Freezing

The 1984 Handbook chapter (Section 2.6) gives the explicit discrete construction for basic G,H-tense logic with axioms A6a,b (the discrete axioms p /\ Hp -> GL v FHp and mirror).

**The successor relation S.** Burgess augments chronicles with a new binary relation S on the domain, where xSy means "x is immediately followed by y AND no further points will ever be inserted between them." The construction is:

- Quadruples (X, R, S, T) where R is a total order, T a coherent chronicle, and S marks "frozen" successor pairs
- **xSy implies y immediately succeeds x in (X,R)** and T(x) ->* T(y) (the "immediate successor" MCS relation)
- Once xSy is established, no point is ever inserted between x and y

**The ->* relation.** For any MCS A, Burgess constructs B with A ->* B satisfying: whenever Fy in A, then y v Fy in B. This is the key lemma. The discrete axiom A6a forces: if A ->* B, then B ->* C implies either B = C or B -> C. In other words, the immediate successor is unique up to the comparability forced by discreteness.

**Killing requirements.** When "freezing" a successor pair (x,z):
- If x is maximal, add a fresh point z after x with xSz
- If x has an existing successor y, either set xSy (if the MCSs match) or insert z between x and y with xSz

**Gap prevention.** This is the critical mechanism: the S relation ensures that between any two S-frozen points, no further points are ever inserted. The "killing lemma" for basic requirements (forms 1.8a,b) is checked to never require insertion between S-frozen pairs -- this follows from properties (c) and (d) of the ->* lemma.

**Result: the limit domain is isomorphic to Z.** Since every point eventually gets an S-successor and an S-predecessor, and S-pairs are never separated, the limit domain with the S relation is a discrete linear order without endpoints. It is isomorphic to Z because it is countable, discrete, and has no endpoints.

**This is the literature's analogue of IsSuccArchimedean:** the S relation guarantees that every point is finitely many successor steps from every other point reachable by S-chains. There are no "gaps" because every interval is eventually filled with a finite chain of S-frozen points.

## 3. Venema 1993: Completeness via Definable Well-Ordering

Venema takes a completely different approach for well-orders and omega. Instead of building a discrete model directly, he:

1. **Starts from Burgess' base completeness** (Theorem 3.5) to get a linear model M satisfying all BW-axioms (Burgess + the well-ordering axiom W: Fp -> U(p, not p))
2. **Shows M is definably well-ordered** (Lemma 4.1): any first-order definable subset has a smallest element. The proof uses the Stavi connectives U', S' and shows they collapse to bot in BW-models (no gaps means U' is vacuously false)
3. **Applies Doets' theorem** (Theorem 3.8): a definably well-ordered model has an n-equivalent well-ordered model for all n
4. **Transfers satisfiability** by choosing n = quantifier depth of phi's first-order translation

For omega specifically (Theorem 4.3, system BN = BW + D for discreteness):
- If phi is BN-consistent, then phi /\ box(D) is BW-consistent
- By Theorem 4.2, this has a well-ordered model M with box(D) valid
- But a well-order satisfying discreteness is isomorphic to omega (Lemma 3.3)

**Key insight: Venema avoids constructing a discrete model directly.** He proves completeness for well-orders (which are inherently gap-free by definition) and then specializes to omega by adding discreteness. The gap-freedom question never arises because well-orders have no gaps by definition.

## 4. Why Discrete Completeness Is Harder Than Dense

Dense completeness is straightforward: the omega-chain construction naturally produces a subset of Q, which is dense. No extra work is needed -- the domain is dense because Q is dense and the construction uses rational midpoints.

Discrete completeness requires:
1. **Ensuring discreteness**: every point must have an immediate successor and predecessor
2. **Ensuring gap-freedom**: the domain must be isomorphic to Z (or omega), not Z + Z or some other discrete order with gaps

The dense case has neither problem. Problem (1) is handled by the discrete axioms. Problem (2) -- gap-freedom / IsSuccArchimedean -- is the hard part that requires either:
- **Burgess' approach**: The S-relation freezing mechanism in the omega-chain, which structurally prevents gaps
- **Venema's approach**: Detour through well-orders and Doets' theorem, sidestepping the gap question entirely

## 5. Implications for the Lean Formalization

The Lean formalization's sorry chain traces through:
```
completeness_discrete -> succ_embed_surjective -> limitDomSubtype_isSuccArchimedean
  -> succ_cofinal -> chronicle_gap_contradiction [sorry]
```

The codebase follows a Burgess-style chronicle construction on Q, then needs to prove the limit domain's LimitDomSubtype satisfies IsSuccArchimedean.

**Burgess 1984 approach (direct):** The key missing ingredient is the S-relation. Burgess' construction explicitly tracks which successor pairs are "frozen" and proves that the killing lemma never needs to insert points between frozen pairs. The current formalization lacks this S-relation tracking. Adding it would require:
- Augmenting the chronicle structure with an S relation
- Proving the ->* successor MCS lemma with parts (c) and (d)
- Showing the killing lemmas respect S-frozen pairs
- Concluding IsSuccArchimedean from the S-chain covering the domain

**Venema 1993 approach (indirect):** This requires:
- Proving definable well-orderedness of BW-models (needs Stavi connective collapse, already partially formalized)
- Formalizing Doets' theorem on n-equivalents (substantial new infrastructure)
- The transfer via n-equivalence (needs EF games, also partially formalized)

**Current codebase alignment:** The codebase has partial infrastructure for both:
- ChronicleExtraction.lean has the Burgess chronicle + Prior-UZ/SZ validity
- NEquivalence.lean, EFGames/, StaviConnectives.lean have partial Venema infrastructure
- The ChronicleNoGaps.lean (Boneyard) sketched a hybrid approach using Prior-UZ to derive a contradiction from a gap

**Recommended path:** The Burgess 1984 S-relation approach is more direct and aligns with the existing chronicle construction. The key technical step is proving that once xSy is established, the killing lemma for C4/C5 counterexamples never requires insertion between x and y. This follows from parts (c) and (d) of the ->* lemma: if T(x) ->* T(y) and we need to insert a witness for Fy in T(x), either the witness is already T(y) or it goes beyond T(y) -- but never between x and y.

## 6. The Axioms Critical for Discrete (Not Needed for Dense)

| Axiom | Burgess | Purpose |
|-------|---------|---------|
| G'bot /\ H'bot (1982) | Discreteness | Every point has immediate successor/predecessor |
| p /\ Hp -> GL v FHp (1984, A6a) | Successor uniqueness | The ->* relation has comparison property (c) |
| p /\ Gp -> HL v PGp (1984, A6b) | Predecessor uniqueness | Mirror of above |
| Prior-UZ: Fp -> U(p, not p) | Well-ordering (Venema's W) | First p-point reachable in finite steps |
| Prior-SZ: Pp -> S(p, not p) | Mirror of W for past | Last p-point reachable in finite steps |

The Prior-UZ/SZ axioms (equivalent to Venema's W for well-ordering) are the axioms that specifically prevent gaps. In a discrete order, Prior-UZ says: if p holds in the future, then there is a first future p-point, and everything between here and there satisfies not-p. This forces any cut in the domain to have a least element on one side -- exactly the archimedean property.
