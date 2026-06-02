# Reynolds 1994: How the Completeness Proof Ensures Z-Isomorphism

## The Core Problem

Reynolds proves weak completeness of US/Z (Until-Since over integer time).
Given a consistent formula A0, he must produce a model with flow of time
isomorphic to Z. The starting model M0 (from Burgess-Xu, Corollary 3) has
flow that is merely countable, discrete, and without endpoints -- but it
could be Z + Z, Z * omega, or other non-standard discrete orders. The
challenge is showing the flow is actually Z.

## Reynolds' Strategy: Not a Direct Construction

Reynolds does NOT construct the integer model by building an omega-chain or
iterating a successor function. Instead, he uses a two-phase indirect
argument:

**Phase 1 (Sections 5-7):** Start from Burgess-Xu linear model M0. Show that
the Prior axioms (Prior-UZ, Prior-SZ) eliminate all "definable gaps" --
including gaps between equivalence classes of any contemporaneous equivalence
relation. This is Theorem 14.

**Phase 2 (Section 8):** Define a specific contemporaneous equivalence
relation ~M ("very good equivalence") on M0. Use Theorem 14 to show ~M has
only one equivalence class. Since every finite subinterval of M0 is "good"
(k-equivalent to a Z-interval), and ~M witnesses this, M0 itself is good:
k-equivalent to Z for any k. Since k exceeds the quantifier depth of A0's
table, truth of A0 transfers.

## The Gap Elimination Technique (Theorem 14)

This is the heart of the paper and corresponds directly to our
IsSuccArchimedean problem.

### What is a "gap"?

A gap in a discrete order is a Dedekind cut where the "lower" side has no
maximum and the "upper" side has no minimum -- equivalently, a point where
the successor orbit from below never reaches the elements above. In our
formalization, NOT IsSuccArchimedean implies the existence of such a gap.

### How does Reynolds eliminate gaps?

The argument proceeds through Lemmas 6-13 in a specific logical chain:

1. **Lemma 6 (Gap detection via temporal formula R):** By expressive
   completeness of U and S over Prior structures (Theorem 5), the monadic
   formula rho(x) = "x's ~-class ends in a gap on the right" has a temporal
   equivalent R. This is possible because Prior structures have no definable
   gaps, so U and S capture all monadic properties.

2. **Lemma 7 (R-intervals are open):** The maximal intervals where R holds
   are open intervals with excluded endpoints in M. Proof uses Prior-U
   applied to R itself: if R stops holding, either there's a last R-point
   (impossible -- rho implies R continues past the gap) or a first non-R
   point (which is the excluded endpoint).

3. **Lemma 8 (No first/last class in R-interval):** Within a maximal
   R-interval, there is no first or last ~-class. This uses Prior-U applied
   to formulas that would distinguish the first/last class.

4. **Lemma 9 (Homogeneity):** All ~-classes within a maximal R-interval are
   elementarily equivalent as substructures of M. If a temporal formula held
   in one class but not another, a formula distinguishing "classes where A
   occurs" would hold up to a gap and fail after it, contradicting Prior-U.

5. **Lemmas 10-11 (Bad interval structure):** A "bad point" is where R or L
   (its mirror) holds. Bad points only occur in non-singleton intervals
   where both R and L hold. Any formula true at the start of a ~-class in a
   bad interval holds throughout the entire bad interval.

6. **Lemma 12 (Model surgery preserves truth):** Replace a whole bad interval
   Q0 with a single ~-class I from it. The resulting structure N = Q- u I u
   Q+ satisfies the same temporal formulas at all shared points. This is
   proved by induction on formula construction, using Lemma 9 (homogeneity)
   and Lemma 11 (saturation) to handle the U and S cases.

7. **Lemma 13 (Contradiction):** In N, the class I still satisfies R (by
   Lemma 7). But R detects gap-ending classes, and I's class in N ends at
   the boundary with Q+ (at a real point q, not a gap). Contradiction: R
   cannot hold in a class that doesn't end at a gap.

### The key insight

The proof is by *reductio*: assume a gap exists, use expressive completeness
to detect it via a temporal formula R, then use model surgery to collapse the
bad interval to a single class. The surgery preserves Prior-U/SZ validity
(any counterexample in N is also one in M). But in the surgered model N, the
"gap" is gone (replaced by a real boundary point), yet R still claims to
detect a gap. Contradiction.

## Connection to IsSuccArchimedean

Reynolds' Theorem 14 says: "In a Prior structure, no contemporaneous
equivalence class ends at a gap." In Section 8, he defines ~M by "very
goodness" (k-equivalence to Z-intervals) and shows it is contemporaneous.
Then:

- If M is not very good, there exist a, b with M|[a,b] not good.
- So a and b are in different ~M classes.
- By Theorem 14, a's class cannot end at a gap.
- So a's class includes some c but not succ(c).
- But M|[c, c+1] is a finite structure (2 elements), hence good.
- So c ~M succ(c) -- contradiction.

This last step is exactly our `no_boundary_at_successor` argument, and the
overall structure matches our `one_class` theorem. The crucial point: Reynolds
does NOT prove IsSuccArchimedean directly. He proves "no gaps in equivalence
classes" (Theorem 14), then derives "one equivalence class" (Theorem 15) as a
consequence, and finally uses k-equivalence transfer to get a Z-model.

## What Corresponds to IsSuccArchimedean?

In our formalization, the chain is:
- `gap_of_not_succ_archimedean`: NOT IsSuccArchimedean implies existence of
  a Dedekind Gap
- `no_gaps_discrete` (= Reynolds Theorem 14): Prior-UZ/SZ eliminate all gaps
- Therefore: Prior-UZ/SZ imply IsSuccArchimedean

Reynolds never uses the term "Archimedean" or "cofinal." His equivalent
concept is **"very good"** = "every subinterval is k-equivalent to a
Z-interval." The one-class theorem shows that the entire structure is very
good, which in a countable discrete order without endpoints implies the flow
is Z (up to k-equivalence, which suffices for transferring A0's truth).

## Critical Axioms for Gap-Freedom

1. **Prior-UZ: Fp -> U(p, ~p)** -- If p holds eventually, there is a first
   future p-point with ~p in between. This is the discrete strengthening of
   Prior-U and is used throughout Lemmas 7-13.

2. **Prior-SZ: Pp -> S(p, ~p)** -- Mirror of Prior-UZ for the past.

3. **Discreteness axioms: U(T, bot), S(T, bot)** -- Ensure every point has
   an immediate successor and predecessor.

4. **Burgess-Xu axioms** -- Ensure linearity of the underlying order.

The Prior axioms are the sole mechanism for gap elimination. They work by
forcing any temporal property that "holds up to a gap and fails after" to
reach a contradiction: if B holds up to the gap and ~B is true arbitrarily
soon after, Prior-U gives either a last B-point (impossible if B is
inherently open-ended) or a first ~B-point where K-(B) holds, which then
generates further contradictions via the gap structure.

## Implications for the Sorry Chain

The existing Lean formalization already has:
- `gap_of_not_succ_archimedean` (sorry-free)
- `no_gaps_discrete` delegating to model surgery (sorry-free)
- `one_class` combining these (sorry-free)
- `very_good_of_archimedean` (sorry-free)

The remaining sorry chain `succ_embed_surjective -> limitDomSubtype_isSuccArchimedean -> succ_cofinal -> chronicle_gap_contradiction` concerns the chronicle construction path, not the Reynolds pipeline path. The Reynolds pipeline in Transfer.lean (`countermodel_discrete_reynolds`) appears to bypass the chronicle sorry by using k-equivalence transfer rather than constructing a literal Z-indexed model.

The correct path forward is to ensure the Reynolds pipeline
(`countermodel_discrete_reynolds` in Transfer.lean) is used as the primary
completeness path, with the chronicle construction as a secondary (or
deprecated) approach. The Reynolds approach avoids needing literal
IsSuccArchimedean for the limit domain because it works via k-equivalence
transfer: the model's flow need not BE Z, it just needs to AGREE with Z on
sentences up to depth k.
