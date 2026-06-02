# Literature Study: Chronicle Construction and Gap-Freedom

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-06-02
**Focus**: How the omega-chain construction ensures the limit is gap-free / successor-archimedean

---

## 0. Source Correction

GHR 1994 Vol 1 Chapter 9 is about the **separation property and expressive completeness**, not chronicle construction. It proves Theorem 9.3.1 (separation implies expressive completeness) and Theorem 9.3.4 (expressive completeness implies separation). It does not contain any chronicle or omega-chain construction.

The relevant sources for chronicle construction and gap elimination are:

- **Burgess 1984** "Basic Tense Logic" (Sections 1.8--1.12 for general chronicles; Section 2.6 for discrete completeness)
- **Reynolds 1994** "Axiomatizing U and S over Integer Time" (Sections 5--9: the full gap elimination pipeline)
- **Caleiro/Vigano/Volpe 2013** "Mosaic Method for Tense Modal Logic" (Definition 3.8--Theorem 3.13: omega-chain construction with defect curing)

---

## 1. How the Chronicle Omega-Chain Is Constructed

### Burgess 1984 (Section 1.10--1.12)

**Stage 0**: Fix a consistent formula phi_0. Take MCS C_0 containing phi_0. Set X_0 = {x_0}, R_0 = empty, T_0(x_0) = C_0.

**Stage n+1 (Killing Lemma)**: Among all "alive" requirements (pairs (x, F(psi)) or (x, P(psi)) whose witness has not been provided), take the one with least code number. Extend (X_n, R_n, T_n) by adding a new point y with xRy (or yRx) and T(y) = B where B is an MCS with T(x) ->3 B and psi in B.

**Stage omega**: Take X = union of X_n, R = union of R_n, T = union of T_n. T is a perfect chronicle on (X, R): every requirement F(psi) in T(x) has a witness, and every requirement P(psi) in T(x) has a witness, because the enumeration ensures every alive requirement is eventually killed.

### Caleiro et al. 2013 (Theorem 3.13)

Same pattern but with mosaics instead of MCS pairs:

- **STEP 0**: Pick a mosaic for Gamma as foundation. Build initial (F_0, delta_0).
- **STEP n+1**: Enumerate all defects (v, FA), (v, PA), (v, exists_A) in sigma. For each defect in (F_n, delta_n), cure it by adding points (Lemma 3.10). This produces (F_{n+1}, delta_{n+1}).
- **STEP omega**: Take unions F = union F_i, delta = union delta_i. By Lemma 3.12, the union preserves frame properties that each finite stage satisfies.

Key: for density (Dns), when curing vertical defects, additionally insert mosaics between ALL neighboring points (not just the defect pair). Condition SVDns ensures this is possible.

### Discrete Extension (Burgess 1984, Section 2.6)

Additional data: an S relation marking immediate successors. M now consists of quadruples (X, R, S, T) where:

- (d) xSy implies y immediately succeeds x in (X, R)
- (e) xSy implies T(x) ->3' T(y) (the "constrained successor" relation)

New requirements of form (e): "there exists y with xSy" and (f): "there exists y with ySx."

To kill (e): Take MCS B with T(x) ->3' B. Three cases:
1. x is maximum: add z after x with S(x,z), T(z) = B.
2. y immediately succeeds x and B = T(y): just add S(x,y) without new points.
3. y immediately succeeds x and B != T(y): B ->3 T(y) by the Lemma. Insert z between x and y, set S(x,z), T(z) = B.

**Critical invariant**: Once xSy is set, **no points are ever inserted between x and y**. This follows from parts (c) and (d) of the Lemma:
- (c) If A ->3' B and A ->3 C: either B = C or B ->3 C (nothing between A and B from above)
- (d) If C ->3 B and A ->3' B: either A = C or C ->3 A (nothing between A and B from below)

---

## 2. The Gap Problem and Why It Arises

### What the Burgess Construction Produces (Discrete Case)

Corollary 3 (Reynolds 1994, p.301): For every US/Z-consistent formula, there is a model whose flow of time is **countable, discrete, and without endpoints**. Reynolds does NOT claim the order is isomorphic to Z.

A countable discrete linear order without endpoints could be Z, or Z + Z, or Z * Q, or any other sum of copies of Z. The construction does not automatically prevent multiple Z-components.

### The Constant-MCS Scenario

If all domain points receive the same MCS B: every temporal formula is uniformly true or false everywhere. U(phi, psi) at x is resolved by y = succ(x) with no intermediates. All axioms (Z1, Prior-UZ) are vacuously satisfied because every future point has the same truth values. This means the construction never encounters a counterexample requiring a point in a gap between two Z-components. The gap is invisible to the temporal language.

**This is the fundamental reason succ_cofinal is hard to prove from temporal axioms alone.**

---

## 3. How Reynolds Proves Gap-Freedom (Theorem 14)

Reynolds does NOT prove gap-freedom at the construction level. Instead, he proves that **no Prior structure can have gaps between equivalence classes of any contemporaneous equivalence relation**. This is a semantic argument about the model, not a syntactic argument about the construction.

### Step Map (Reynolds 1994, Sections 6--8)

**Step 1**: Expressive completeness of {U, S} over Prior structures (Theorem 5). Since Prior-U eliminates Stavi connectives (U'(A,B) <-> bot in any Prior structure), {U,S} has the same expressive power as {U, S, U', S'}.

**Step 2**: Define "bad points" -- points whose contemporaneous-equivalence class ends at a gap. Define R (resp. L) as the temporal formula detecting a right-ending (resp. left-ending) gap. R exists by expressive completeness.

**Step 3**: Structural analysis of bad intervals (Lemmas 6--11):
- Lemma 7: Maximal intervals of R are open with excluded endpoints in M.
- Lemma 8: No first or last class in a bad interval (by Prior-U contradiction).
- Lemma 9: If a formula holds somewhere in one class, it holds somewhere in every class of the interval. All classes are elementarily equivalent.
- Lemma 10: Bad points only occur in non-singleton intervals where both R and L hold throughout.
- Lemma 11: If a formula holds at the start of a class in a bad interval, it holds throughout the interval.

**Step 4**: Surgery argument (Lemma 12). Replace an entire bad interval Q_0 (containing multiple equivalence classes) with a single class I. The resulting structure N = Q^- union I union Q^+ satisfies the same temporal formulas as M at every point.

**Step 5**: Contradiction (Lemma 13). In N, R still holds on I (by Lemma 12). But N is a Prior structure (all Prior-U/S instances inherited from M). In N, I is a single equivalence class. A single class cannot end at a gap (by definition of Prior structures). So R cannot hold on I. Contradiction.

**Step 6**: Conclusion (Theorem 14). No contemporaneous equivalence relation on a Prior structure has classes ending at gaps.

### Application to Integers (Theorem 15, Section 8)

Define the equivalence relation ~_M: a ~_M b iff M|[a,b] is "very good" (every subinterval is k-equivalent to an interval of Z for suitable k). This is contemporaneous by construction (Lemma 17). By Theorem 14, ~_M classes don't end at gaps. Since the non-gap transition between classes requires c and c+1 to be in different classes, but M|[c, c+1] is trivially very good (finite), transitivity of ~ forces them into the same class. Therefore M is a single ~_M class, hence very good, hence good, hence k-equivalent to Z.

---

## 4. Successor Stability in the Construction

### The Claim

"Once succ(q) = s is established at a finite stage, no further points appear between q and s in the limit."

### Verification Against Literature

**TRUE, and proved by Burgess.** Section 2.6 of Burgess 1984 states explicitly: "It is also necessary to check that when xSy we never need to insert a point between x and y in order to kill a requirement of form 1.8a or b. Reviewing the construction of Section 2.2 above, this follows from parts (c), (d) of the Lemma above."

Parts (c) and (d) say:
- (c) If A ->3' B (A is the S-predecessor of B): any C with A ->3 C satisfies B = C or B ->3 C. So any point that must be R-after A is either B itself or R-after B. Nothing goes between.
- (d) Mirror: any C with C ->3 B satisfies C = A or C ->3 A. Nothing goes between from below.

**However**: This only prevents insertion between S-linked pairs. It does NOT prevent the existence of pairs of points in the limit domain that were never S-linked. The gap scenario involves two Z-chains that were constructed independently and never joined by S-links.

### What Successor Stability Does NOT Give

Successor stability ensures that within a single Z-component (a maximal succ-connected suborder), the succ/pred structure is preserved in the limit. It does NOT ensure that the entire limit domain is a single Z-component. That is the content of IsSuccArchimedean, which requires the separate Reynolds gap elimination argument.

---

## 5. Discreteness and U(T, bot)

The formula U(T, bot) says "there exists a next moment" (immediate successor). In the discrete case, the axiom G(U(T, bot)) ensures every point has an immediate successor, and the dual H(S(T, bot)) ensures every point has an immediate predecessor. This gives SuccOrder and PredOrder on the limit domain.

But SuccOrder + PredOrder + NoMinOrder + NoMaxOrder does NOT imply IsSuccArchimedean. The order Z + Z satisfies all four but is not succ-archimedean.

The role of discreteness is:
1. It ensures each pair of adjacent points has a specific MCS-to-MCS transition (the ->3' relation)
2. It ensures U(phi, psi) witnesses are at the immediate next point (no intermediates)
3. Combined with the Prior axioms, it ensures no definable gaps -- but proving THIS requires the full Reynolds pipeline (Theorems 5, 14, 15)

---

## 6. Summary of Findings

| Question | Answer |
|----------|--------|
| How is the omega-chain constructed? | Burgess killing lemma: enumerate alive requirements, kill one per stage, take union at omega |
| What violations drive construction? | C5 defects (F(psi) without witness), C4 defects (neg-U without counterexample), S-requirements |
| How is gap-freedom proved? | NOT at construction level. Reynolds Theorem 14: Prior structures have no gaps between equivalence classes. Surgery argument replacing bad intervals by single classes |
| Is there an explicit successor-orbit coverage proof? | Theorem 15 (Reynolds): define ~_M as "very good" equivalence, show single-class by Theorem 14, deduce Z-isomorphism |
| Successor stability claim? | True for S-linked pairs (Burgess Lemma (c),(d)). Does NOT cover cross-component gaps |
| What plays the role of discreteness? | U(T, bot) gives SuccOrder/PredOrder. Combined with Prior axioms, eliminates definable gaps. But the proof requires expressive completeness (Theorem 5) and the surgery lemma (Lemma 12) |

### Implication for Lean Proof

The `succ_cofinal` sorry CANNOT be closed by a construction-level argument. The limit domain CAN have multiple Z-components consistent with all temporal axioms under strict semantics (the constant-MCS case). The Reynolds gap elimination pipeline (Theorems 5, 14, 15) is the necessary and sufficient tool. This requires:
1. Expressive completeness of {U,S} over Prior structures (Theorem 5) -- depends on {U, S, U', S'} expressive completeness (Theorem 4/GHR93)
2. Contemporaneous equivalence gap elimination (Theorem 14) -- the 8-lemma argument
3. Very-good equivalence construction (Theorem 15) -- lexicographic sum + k-equivalence

Estimated Lean formalization: 2000--3000 lines for the full pipeline.
