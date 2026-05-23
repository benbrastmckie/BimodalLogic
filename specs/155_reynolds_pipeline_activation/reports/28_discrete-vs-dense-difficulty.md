# Why Discrete Temporal Completeness Is Fundamentally Harder Than Dense

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-23
**Focus**: Mathematical analysis of the difficulty gap between dense and discrete completeness

---

## 1. Why Dense Is Easier: The Chronicle Construction Just Works

The dense completeness proof (`completeness_dense` via `countermodel_dense`) uses the Burgess 1982 chronicle construction over the rationals. Given an unprovable formula phi, the proof builds a countermodel on Rat in essentially three steps: extend {neg phi} to an MCS, construct a chronicle (an omega-chain of finite temporal structures that kills every "potential counterexample"), and take the limit. The resulting structure lives on a dense linear order (the rationals), and the truth lemma transfers MCS membership to semantic truth.

The key reason this works cleanly is that **dense orders have no gaps**. A Dedekind-complete order (or more precisely, any order where Until and Since are being evaluated) has the property that every downward-closed proper subset with no maximum has its supremum present in the domain. On the rationals, the chronicle construction can always find witness points: if U(psi, eta) is in an MCS at point x, the C5 resolution lemma produces a witness y > x with psi in f(y) and eta at all intermediates. Because Rat is dense, "all intermediates" is a substantive constraint that properly resolves the Until formula. The construction never encounters a situation where two chains of points converge to different limits with nothing between them.

In the Lean formalization, `countermodel_dense` is essentially sorry-free (modulo upstream chronicle coherence lemmas). The proof composes `cantor_bfmcs_dense` with the parametric truth lemma, and the composition is direct. No game theory, no extended carriers, no gap analysis.

## 2. What Gaps Add: The Extended Carrier and Its Complications

The discrete case uses the same Burgess construction but over a domain that is meant to be isomorphic to the integers. The construction produces a limit domain (`limit_dom` subset of Rat) with a successor and predecessor on every point. The problem arises at `succ_cofinal`: the proof needs to show that iterating successor from any point a eventually reaches any point b above it (the `IsSuccArchimedean` property). Without this, the limit domain might not be order-isomorphic to Z, and the countermodel does not land on the correct frame class.

**The gap scenario is the obstruction.** The Burgess construction can produce a limit domain where the successor orbit {s^n(a) : n in Nat} converges (in the ambient rationals) to some limit L from below, while a predecessor chain {p^k(b)} descends to L from above, with no domain point at L. This is a **Dedekind gap**: the orbit points form a downward-closed set with no supremum in the domain. The successor function is well-defined on every domain point, but the domain has a "hole" that prevents the successor iterates from ever crossing to the other side.

The devastating fact, proved in reports 32-33, is that this gap scenario is **consistent with all temporal axioms**. In the constant-MCS case (where every domain point has the same maximally consistent set), the Z1 induction axiom G(G(phi) -> phi) -> (F(G(phi)) -> G(phi)) is trivially satisfied because F, G, P, H all collapse. The Prior-UZ axiom F(p) -> U(p, neg p) is vacuously satisfied in the discrete case because between consecutive successor points there are no intermediate domain points, so the Until guard is vacuous. The C5 resolution U(psi, eta) in f(x) -> exists y > x with psi in f(y) and eta at intermediates is resolved by the immediate successor. No temporal formula can "see across" the gap.

This is why the dense case avoids the problem entirely: on a dense order, there ARE intermediate points, the Until guard is substantive, and convergent sequences cannot create gaps (because the order is Dedekind-complete by construction on Rat).

## 3. Why the GHR93 Game Argument Is Necessary

Since the gap cannot be eliminated by temporal axioms or construction internals alone, a fundamentally different proof strategy is needed. The approach taken is the GHR93/Reynolds pipeline: instead of trying to prove the chronicle construction produces a gap-free model, prove that Until and Since are **expressively complete** over Prior structures (discrete linear orders satisfying the Prior-UZ and Prior-SZ axioms), then use this expressive completeness to **eliminate gaps** via model surgery.

The GHR93 argument (Gabbay, Hodkinson, Reynolds 1993, Section 8) proves that the temporal logic with Until, Since, and Stavi connectives is expressively complete over all linear orders. The proof uses Ehrenfeucht-Fraisse games adapted for temporal logic: custom n-round rank-r games G_{n;r}(M,xy; N,x'y') where Duplicator's winning condition requires preserving the order type, gap/point status, and rank-r formula agreement across game tuples.

**Why simpler arguments fail.** Kamp's theorem establishes that Until and Since alone are expressively complete over Dedekind-complete orders. The proof uses a composition method: any first-order monadic sentence can be decomposed into temporal formulas by induction on quantifier depth, with each quantifier elimination step relying on the ability to find witness points in the order. On Dedekind-complete orders, witnesses always exist. On orders with gaps, they may not: a first-order formula might distinguish two structures by detecting a gap that no temporal formula built from Until and Since alone can express. This is why Stavi introduced his additional connectives U_s and S_s, which explicitly quantify over gap-like configurations.

The GHR93 game argument works in two stages. First, Theorem 6 (the forward-to-backward transfer) proves that if Duplicator can win a forward game with enough rounds and rank, she can win a backward game with fewer rounds. This is proved by induction on the number of rounds n. Second, Reynolds's gap elimination (Theorem 14) uses the US expressive completeness result to show that on Prior structures, gaps between equivalence classes of a contemporaneous relation cannot exist, because one could perform "model surgery" -- replacing a bad interval (containing gap-ending classes) with a single class -- and derive a contradiction.

A direct syntactic completeness proof (extending Lindenbaum's lemma to produce a gap-free canonical model) does not work because the canonical model construction has no mechanism to prevent gaps. The game-theoretic approach sidesteps canonical models entirely: it works with arbitrary structures and proves an expressiveness result that applies uniformly.

## 4. The K^-(neg D) Formula and Cross-Structure Transfer

The specific blocker in the formalization is Claim 1 of GHR93 Section 8 (page 116), which sits at the heart of the inductive step of Theorem 6. The claim states: in any play of a game G_{m;r'}(M,xy; N,x'y') with r' > r where Duplicator uses a winning strategy, if Spoiler places the M-side infimum c among his choices, Duplicator's response must equal the N-side infimum d-bar.

The proof constructs the formula C' = neg C or K^-(neg C), where:
- C is the continuation predicate: C(t) holds iff every rank-r formula true throughout the mu-points of (a_n, y') is also true at t
- K^-(X) abbreviates neg S(top, neg X), meaning "X holds cofinally in the past"
- C' has rank r+1 (in GHR93 terms; rank r+2 in the Lean encoding where `stavi_depth(.std_snce A B) = max(depth A, depth B) + 2`)

**Why cross-structure reasoning is essential.** The argument must show that c (the infimum of the continuation set in M) and d (Duplicator's response, a point in N) satisfy the same formula C'. This is inherently cross-structural: C' is defined using the continuation predicate C, which describes the interval type of (a_n, y') in N, but c is the infimum of the corresponding set in M (where the interval type from N is evaluated via rank-r formula agreement). The M-side infimum c satisfies C'(c) by an analysis of the infimum: either c is not in the continuation set (so neg C(c) holds directly) or c achieves the infimum (so C holds above c but fails cofinally below c, giving K^-(neg C)(c)). The game's winning condition then transfers C'(c) = TRUE to C'(d) = TRUE, constraining d to equal d-bar.

The subtlety that consumed 19+ rounds of implementation is that this argument requires:
1. Constructing the M-side continuation set S_C^M (evaluating N's interval type in M)
2. Finding c = inf(S_C^M) as an element of the extended carrier
3. Using the pigeonhole principle to extract a single definable formula D_M from the (potentially infinite) continuation predicate
4. Building K^-(neg D_M) as a materialized Stavi formula at the correct depth
5. Proving its semantics match the predicate-level statement
6. Transferring via a rank-(r+2) game (the forward hypothesis)
7. Showing the transfer constrains d to equal d-bar

Each step requires infrastructure that does not exist in the dense case at all: the extended carrier (adjoining r-definable gaps), the rank embedding (mapping carrier points into the extended carrier), the pigeonhole construction (extracting a single formula from a finite type), and the Stavi formula semantics (evaluating temporal truth at gap points).

## 5. Known Simpler Approaches

There are essentially three approaches in the literature, none of which are truly simpler:

**Approach A: Direct Henkin construction (Task 129).** Build a canonical model where every point is a distinct MCS, guaranteeing IsSuccArchimedean by construction. This avoids the gap problem but requires a weak/reflexive completeness proof followed by a conservative extension argument. The effort is comparable and introduces its own technical difficulties (the reflexive truth lemma, the conservative extension theorem).

**Approach B: The GHR93/Reynolds pipeline (Task 155, current approach).** The full game-theoretic argument. Mathematically complete and well-understood, but requires approximately 4000-6000 lines of Lean across EF games, Stavi connectives, expressive completeness, and gap elimination. The infrastructure is reusable for other results.

**Approach C: Simplified Stavi proofs.** Rabinovich (2017) and others have given simplified proofs of Stavi's theorem using partition formulas rather than EF games. However, these still require the full extended carrier and gap-handling machinery; the simplification is in the composition method, not in the gap elimination. For the specific problem of discrete completeness, the gap elimination (Reynolds Theorem 14) would still need to be formalized.

There is no known proof of discrete temporal completeness that avoids reasoning about gaps entirely. The fundamental obstacle -- that the chronicle construction can produce gaps consistent with all axioms -- is intrinsic to the discrete setting. Any proof must either prevent gaps (Approach A) or eliminate them after the fact (Approaches B and C). The dense case is easier precisely because this entire layer of difficulty does not exist.

---

## Summary

The dense case is a direct chronicle-to-countermodel pipeline on the rationals: no gaps exist, no games are needed, no extended carriers arise. The discrete case requires proving that Until and Since can express every monadic first-order property over Prior structures (via EF games at rank r+2 with gap-point tracking in the extended carrier), then using this expressive power to show gaps cannot survive in the model (via Reynolds's model surgery argument). The specific formula K^-(neg D) sits at the crux because it is the rank-(r+2) temporal formula that semantically characterizes the infimum of the continuation set, enabling the cross-structure transfer that pins Duplicator's game response to the correct position. The difficulty is not an artifact of the formalization strategy; it reflects a genuine mathematical asymmetry between Dedekind-complete and gapped linear orders.

---

**Sources consulted**:
- GHR93: Gabbay, Hodkinson, Reynolds, "Temporal expressive completeness in the presence of gaps," Logic Colloquium '90, LNL 2, Springer, 1993, pp. 89-121
- Reynolds 1994: "Axiomatising U and S over Integer Time"
- Rabinovich 2017: "A Proof of Stavi's Theorem" (arXiv:1711.03876)
- Project reports 22, 26, 32, 33, 35 and plan v17
- Lean source: ExpressivenessGeneral.lean, EFGames.lean, ChronicleToCountermodel.lean, Completeness.lean
