# Expressive Completeness of {U,S} over Integer Time: Detailed Study

## Summary

This report studies the "separation property" / "expressive completeness" of {Since, Until} over integer time, drawing from three primary sources:
- **[GHR94]**: Gabbay, Hodkinson, Reynolds 1994, *Temporal Logic: Mathematical Foundations*, Vol. 1, Chapters 9, 10, 12
- **[GHR93]**: Gabbay, Hodkinson, Reynolds 1993, "Temporal expressive completeness in the presence of gaps"
- **[R94]**: Reynolds 1994, "Axiomatising U and S over integer time"

The goal is to determine precisely what must be formalized in our ProofChecker codebase to complete the Reynolds pipeline for discrete completeness.

---

## 1. Framework (Chapter 9 of [GHR94])

### 1.1 What is the Separation Property?

**Definition 9.2.3** (GHR94, p.355): A set of temporal connectives has the *separation property* over a class T of linear flows of time iff every wff in the temporal language of these connectives is *separable* in the language over T. A wff A is separable if there exists an equivalent wff in the language that is a boolean combination of:
- **pure past** wffs (truth depends only on the past of the current time point),
- **pure future** wffs (truth depends only on the future), and
- **atomic** (pure present) wffs.

Intuitively, separation means every temporal formula can be "decomposed" so that no U appears inside an S and no S appears inside a U.

### 1.2 Separation = Expressive Completeness (Theorem 9.3.1 + 9.3.4)

**Theorem 9.3.1**: If L has P and F definable and L has the separation property over T, then L is expressively complete over T.

**Theorem 9.3.4**: If L is expressively complete over linear time, then L is separated.

The proof of 9.3.1 (separation implies expressive completeness) is the direction relevant to us. It proceeds by induction on quantifier depth m of the FO formula:
1. **Base (m=0)**: Quantifier-free FO formulas translate trivially.
2. **Inductive step**: Reduce to the case of a single existential quantifier. Introduce auxiliary predicates R_=, R_>, R_< to partition the domain relative to t. Use the induction hypothesis on subformulas. Use separation to eliminate the auxiliary predicates. The key insight: separation allows converting formulas with "mixed" predicates (that talk about both t and other points) into boolean combinations of pure past, pure future, and present formulas.

**Theorem 9.3.4** (expressive completeness implies separation) uses Lemma 9.3.2, which shows any monadic FO formula can be put into a "separated" normal form of disjunctions of conjunctions of interval-relativized sub-formulas.

### 1.3 The Generalized Separation Property (Section 9.4)

**Definition 9.4.1**: A generalized separation property replaces the past/present/future partition with an arbitrary finite partition into disjoint regions phi_1,...,phi_n. The generalized separation theorem (Theorem 9.4.2) states that if L has the generalized separation property and each region's existential quantifier is expressible, then L is expressively complete.

**Do we need it?** No. The integer case uses the standard (non-generalized) separation property. The generalized version is needed only for non-linear flows (Chapter 13) or certain branching time logics.

---

## 2. Core Result: Separation for {S,U} over Integer Time (Chapter 10, Section 10.2)

### 2.1 Main Theorem Statement

**Theorem 10.2.9** (Separation Theorem): Each wff in the language with {U, S} is equivalent, over the integer flow of time, to a separated wff.

**Theorem 10.2.10**: The language {U, S} is expressively complete over integer time.

*Proof of 10.2.10*: Follows immediately from the separation theorem 10.2.9 and Theorem 9.3.1 (separation implies expressive completeness for languages with F and P definable).

### 2.2 Full Proof Structure of the Separation Theorem

The proof is entirely syntactic: it shows how to REWRITE any {U,S}-formula into a separated equivalent by a sequence of elimination steps. The structure is a nested induction:

#### Layer 1: Junction Depth Induction (Lemma 10.2.8)

Define the *junction depth* of a wff as the maximum depth of alternation between U and S in the nesting. For example:
- `S(a /\ U(A, S(C,D)), S(S(C,D), E))` has junction depth 3
- A formula with no U inside S and no S inside U has junction depth 0 or 1

**Lemma 10.2.8**: Any wff is syntactically separable. Proof by induction on junction depth:
- Junction depth 0 or 1: already separated.
- Junction depth >= 2: Replace maximal S-subformulas within U-arguments by fresh atoms, apply Lemma 10.2.7, then resubstitute and use induction hypothesis (junction depth decreases by 1).

#### Layer 2: No S-within-U Elimination (Lemma 10.2.7)

**Lemma 10.2.7**: If D contains no S nested within a U, then D is syntactically separable. Proof by induction on the maximum depth n of nesting of Us beneath an S:
- n = 1: Use Lemma 10.2.6.
- n > 1: Replace sub-terms `U(X_ij, Y_ij)` inside the arguments of the outermost `U(A_i, B_i)` by fresh atoms, apply Lemma 10.2.6, then resubstitute and use induction hypothesis (nesting depth decreases).

#### Layer 3: Multiple U-formulas (Lemma 10.2.6)

**Lemma 10.2.6**: If the only appearances of U in D are in the forms U(A_i, B_i) where each A_i, B_i is built without S or U, then D is syntactically separable. Proof by induction on the number n of distinct U-subformulas:
- n = 1: Use Lemma 10.2.5.
- n > 1: Focus on U(A_n, B_n), replacing others by fresh atoms. Apply Lemma 10.2.5. In the resulting separated form, resubstitute and apply induction hypothesis to the pure-past parts.

#### Layer 4: Single U-formula (Lemma 10.2.5)

**Lemma 10.2.5**: If A and B are built without S or U and the only appearance of U in D is as U(A,B), then D is equivalent to a syntactically separated wff. Proof by induction on k = maximum number of nested Ss above any U(A,B):
- k = 0: already separated.
- k > 0: Apply Lemma 10.2.4 to the most deeply nested S(C,F) containing U(A,B), reducing the nesting depth.

#### Layer 5: Single S with U Beneath (Lemma 10.2.4)

**Lemma 10.2.4**: If S(C, F) contains U(A,B) only as a top-level subformula (not under any further S), then S(C,F) is equivalent to a separated wff with U only as U(A,B). Uses DNF/CNF rearrangement + distributivity of S over disjunction/conjunction (Lemma 10.2.1) to reduce to the 8 canonical cases of Lemma 10.2.3.

#### Layer 6: The Eight Eliminations (Lemma 10.2.3)

These are the atomic building blocks. Each handles one of the 8 possible patterns of S(a +/- U(A,B), q +/- U(A,B)):

| Case | Formula | Strategy |
|------|---------|----------|
| 1 | `S(a /\ U(A,B), q)` | Split on whether the A-witness is past/present/future of now |
| 2 | `S(a /\ ~U(A,B), q)` | Use Lemma 10.2.2 (~U equivalence), reduce to case 1 |
| 3 | `S(a, q \/ U(A,B))` | Negate and use case 2 |
| 4 | `S(a, q \/ ~U(A,B))` | Direct semantic argument |
| 5 | `S(a /\ U(A,B), q \/ U(A,B))` | Split on whether A is past or future |
| 6 | `S(a /\ ~U(A,B), q \/ U(A,B))` | Reduce to cases 3 and 5 |
| 7 | `S(a /\ U(A,B), q \/ ~U(A,B))` | Reduce to cases 4 and 8 |
| 8 | `S(a /\ ~U(A,B), q \/ ~U(A,B))` | Negate and reduce to case 5 |

Each elimination produces a formula where U(A,B) appears only at the top level (not under any S). These rely on two key lemma families:

**Lemma 10.2.1**: Distributivity laws for U and S over boolean connectives (valid over linear time).

**Lemma 10.2.2**: Negation of U/S in terms of G/H and U/S (valid specifically over **integer time**, using discreteness):
- `~U(A,B) <-> G(~A) \/ U(~A /\ ~B, ~A)`
- `~S(A,B) <-> H(~A) \/ S(~A /\ ~B, ~A)`

### 2.3 How the Integer Case Differs from the Real/Dedekind-Complete Case

The integer case (Section 10.2) is significantly SIMPLER than the Dedekind-complete case (Section 10.3):

1. **No K+/K- connectives needed**: Over integers, K+q = K-q = T (always true) because every point has an immediate successor. The Dedekind-complete case requires the connectives K+(q) = ~U(T, ~q) and K-(q) = ~S(T, ~q) to handle "arbitrarily close" properties near gaps.

2. **No Gamma connectives needed**: The integer case does not need the Gamma^+(B), Gamma^-(B) connectives of Section 10.3.

3. **No special atom c needed**: The Dedekind-complete case introduces a "relatively dense" atom c. Not needed for integers.

4. **Lemma 10.2.2 uses discreteness**: The equivalence `~U(A,B) <-> G(~A) \/ U(~A /\ ~B, ~A)` is specific to integer time (or more generally, discrete linear time). Over dense time, the negation of U requires different handling.

5. **Fewer elimination cases**: The 8 cases of Lemma 10.2.3 are simpler than the elimination lemmas of Section 10.3.

---

## 3. What We Already Have in the ProofChecker Codebase

### 3.1 The Table Translation (temporal -> FO): COMPLETE

**File**: `Theories/Bimodal/Metalogic/WeakCanonical/Table.lean`

- `table sig atomMap phi` : translates a temporal formula to `MonadicFormula sig 1` (FO with one free variable). Handles all 8 Formula constructors. FULLY IMPLEMENTED.
- `table_depth_bound` : quantifier depth of `table` is bounded by `operator_depth`. PROVED.
- `temporal_truth` : semantic interpretation of temporal formulas on `OrderedMonadicStructure`. DEFINED.
- `table_correctness` : `eval M (fun _ => t) (table sig atomMap phi) <-> temporal_truth M atomMap t phi`. FULLY PROVED (all 8 cases, sorry-free).

This gives us the TEMPORAL -> FO direction completely.

### 3.2 Monadic FO Infrastructure: COMPLETE

**File**: `Theories/Bimodal/Metalogic/WeakCanonical/MonadicFO.lean`

- `MonadicSignature`, `MonadicFormula sig n`, `MonadicSentence sig` : FO formulas with De Bruijn indices.
- `eval` : Tarski satisfaction.
- `OrderedMonadicStructure`, `ZStructure`, `ZIntervalStructure` : Carrier types.
- De Bruijn operations: `lift`, `weaken`, `insertEnv` with correctness lemmas.
- `atomCount`, `nfCount`, `NormalFormIdx` : Counting functions for Doets normal forms.

### 3.3 Normal Forms and k-Equivalence: COMPLETE

**File**: `Theories/Bimodal/Metalogic/WeakCanonical/NormalForm.lean`

- `NormalForm sig k n` : Recursive normal form type (Doets Definition 1.6.1).
- `nf_eval_nf` : Semantic evaluation of normal forms.
- `nf_exists_unique` : Each (M, env) satisfies exactly one normal form.
- `nf_agreement_monotone` : Agreement monotone in quantifier depth.
- `doets_lemma_1_1` : Bridge theorem -- k-type determines truth of depth-k formulas.
- `normalForm_card`, `normalForm_equiv_fin` : Cardinality and equivalence results.

**File**: `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean`

- `KType sig k`, `k_type_of`, `k_equiv` : k-equivalence via normal form agreement.
- `k_equiv_monotone` : If M ~_k N then M ~_m N for m <= k.
- `orderedSum` : Ordered sum construction on dependent sigma type.
- `KEquivalenceFramework.sum_preservation` : Doets Lemma 1.4 (ordered sum preserves k-equivalence). PROVED.

### 3.4 Integer Model Construction: MOSTLY COMPLETE

**File**: `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean`

- `good sig k M` : M is k-equivalent to a Z-interval structure. DEFINED.
- `very_good sig k M` : Every subinterval of M is good. DEFINED.
- `finite_structures_good` : All finite structures are good. PROVED.
- `contemp_equiv` : Contemporaneous equivalence relation (~_M). DEFINED.
- `contemp_equiv_is_equiv` : ~_M is an equivalence relation. PROVED.
- `one_class` : Main result -- M has only one ~_M class. PROVED.
- `chronicle_is_good` : The chronicle from Corollary 3 is good. PROVED (via one_class + very_good_implies_good).

### 3.5 Transfer and Completeness: PARTIAL

**File**: `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean`

- `mkSigFrom phi` : Build MonadicSignature from formula. DEFINED.
- `mkAtomMap phi` : Build atom map. DEFINED.
- `doets_countermodel_discrete` : Main theorem. Currently FALLS BACK to chronicle construction; Reynolds pipeline steps are commented out.

### 3.6 What Is NOT Implemented

The FO -> TEMPORAL direction (the inverse translation) is NOT implemented anywhere. There is no:
- Definition of "separated wff"
- Implementation of the 8 elimination lemmas
- Inductive separation procedure
- Statement or proof of expressive completeness as a Lean theorem

---

## 4. What We Need to Build

### 4.1 Critical Question: Do We Actually Need Expressive Completeness?

**NO. We do not need to formalize expressive completeness to complete the Reynolds pipeline.**

Here is the reasoning:

#### Reynolds' Theorem 18 (Completeness) uses the following chain:

1. **Corollary 3** (Burgess-Xu): Given consistent formula A_0, get a Prior structure M_0 (countable, discrete, no endpoints, Prior-UZ/SZ valid). **STATUS: DONE** (ChronicleExtraction.lean).

2. **Theorem 15**: M_0 (Prior structure, finite language) has for each k an integer-flowed structure Z satisfying the same monadic sentences of depth <= k. **STATUS: NEARLY DONE** (IntegerModel.lean -- `chronicle_is_good` proved).

3. **Final transfer**: Let k = 1 + quantifier_depth(table(A_0)). Then Z ~_k M, so Z satisfies the same depth-k sentences. The table of A_0 has depth <= k, so Z |= exists t. table(A_0)(t) iff M |= exists t. table(A_0)(t). By table_correctness, Z |= A_0(b) for some b. **STATUS: NEEDS BRIDGING** (ZIntervalStructure -> TaskFrame).

**Expressive completeness is used by Reynolds only INSIDE the proof of Theorem 15**, specifically in the gap-elimination argument (Lemmas 6-14 in [R94]). Let us trace exactly where.

#### Where Reynolds Uses Expressive Completeness

Reynolds uses expressive completeness in three places within the proof of Theorem 14 ("~_M classes do not end at gaps"):

1. **Lemma 6** (line ~538 of [R94]): "By the expressive completeness of U and S there is temporal R true in any Prior structure exactly where rho(x) is." Here rho(x) is a monadic FO formula with one free variable that says "x's ~-class ends in a gap on the right."

2. **Lemma 7** (line ~588): "Let B be the temporal formula saying that the ~-class we are now in begins with a point satisfying R /\ K-(~R). B exists by expressive completeness."

3. **Lemma 8** (line ~598): "By expressive completeness, the formula rho(x) /\ ~exists z(y < z < x /\ rho(z)) has a temporal equivalent."

4. **Lemma 9** (line ~625): "Using expressive completeness and ~, find B which is true at points only if A occurs somewhere in their ~-class."

5. **Lemma 11** (line ~700): "Using z and expressive completeness we can find a temporal formula C which is true only at points within a u-class after some ~B in that class."

#### But We Have Already Bypassed This!

**The `one_class` theorem in IntegerModel.lean proves directly (without gaps) that M has only one ~_M class.** This uses the discreteness of the flow and the ordered sum decomposition. The gap-elimination chain (Lemmas 6-14) is precisely the machinery needed when there MIGHT be gaps -- but in our codebase, the `one_class` proof handles this differently, using `doets_lemma_1_4` (sum preservation) and `no_boundary_at_successor` directly.

The key insight: **In the discrete case, the gap-elimination argument is trivially bypassed because discrete orders without endpoints have no gaps at all.** Every point has an immediate successor and predecessor. If a ~_M class "ended" somewhere, it would have to end at a point c whose successor c+1 is in a different class. But M|[c, c+1] is finite (2 elements), hence very good, hence c ~_M c+1 by transitivity. Contradiction.

This is exactly what `one_class` proves, and it does NOT use expressive completeness.

### 4.2 What Remains for the Reynolds Pipeline

The remaining gap is NOT expressive completeness but rather the **truth transfer bridge**:

1. **From `chronicle_is_good`** we get: exists Z : ZIntervalStructure sig, k_equiv sig k (chronicle_as_monadic) (Z.toOrdered sig).

2. **From `doets_lemma_1_1`** (bridge theorem): k_equiv implies agreement on all depth-k monadic sentences.

3. **From `table_correctness`**: eval on table(phi) iff temporal_truth.

4. **Missing**: Package the Z-interval structure as a `TaskFrame Int` / `TaskModel` with a valuation that makes phi false. This requires:
   - Converting `ZIntervalStructure.intervalCarrier` (a subtype of Z) to `Int`
   - Building a `TaskFrame` and `TaskModel` over `Int`
   - Relating `temporal_truth` on the `OrderedMonadicStructure` to `truth_at` on the `TaskModel`

This is an infrastructure/packaging task, not a deep mathematical theorem.

---

## 5. How This Connects to Reynolds Theorem 14

### 5.1 What Reynolds Theorem 14 Says

**Theorem 14**: Suppose that ~ is a contemporaneous equivalence relation on a Prior structure M. Then the ~-classes do not end at gaps.

### 5.2 The Specific Instance Reynolds Needs

Reynolds defines ~_M by: a ~_M b iff M|[a,b] (or M|[b,a]) is very good. The contemporaneity of this relation follows from the fact that the definition depends only on the substructure between a and b.

Reynolds then uses Theorem 14 to show that in a discrete Prior structure, ~_M has only one class (Theorem 15 proof). This is because:
1. If there were two classes, they would be separated by a boundary.
2. In a discrete structure, the boundary is between some c and c+1.
3. M|[c, c+1] is finite, hence very good, so c ~_M c+1.
4. But c and c+1 are in different classes. Contradiction.

### 5.3 Expressive Completeness Is NOT Needed for the Discrete Case

The gap-elimination chain (Lemmas 6-14) handles the case where the ~-classes might end at GAPS in the flow of time. But in a discrete linear order without endpoints, there are no gaps. Every point has immediate neighbors.

The argument at step (2) above -- "the boundary is between some c and c+1" -- is immediate in a discrete order. In a dense or Dedekind-complete order, the boundary COULD be at a gap, and that's where the full force of Theorem 14 (and hence expressive completeness) is needed.

### 5.4 Could a Restricted Version Suffice?

If we ever needed expressive completeness (which we do not for the discrete case), the specific instances used by Reynolds are:
- Translating specific monadic formulas rho(x) that describe gap-related properties of ~-classes
- These formulas have bounded quantifier depth (depending on the ~ definition)
- The ~ definition involves only the predicates from the finite language

A restricted version covering "all monadic formulas with quantifier depth <= k over a finite signature" would suffice. But again, this is moot for the integer case.

---

## 6. The 1993 Paper [GHR93]

### 6.1 Content Overview

The 1993 paper has a different focus than the textbook: it is about expressive completeness over flows of time with GAPS.

Key results:
- **Theorem 3**: {U, S, U', S'} is expressively complete for ALL linear flows of time (including those with gaps).
- **Lemma 2**: Over flows with only ISOLATED gaps, {U,S} alone is expressively complete (because U' can be defined from U,S, and gap-detection connectives).
- **Lemma 3**: {U,S} is NOT expressively complete over general linear time (demonstrated by a flow with a single non-isolated gap).
- **Theorem 5 (= our Theorem 5 in [R94])**: {U,S} is expressively complete for the class of Prior structures. Proof: by Theorem 3, {U,S,U',S'} is complete over all linear flows. In Prior structures, U'(A,B) <-> bot (because U'(A,B) requires a definable gap, but Prior axioms preclude definable gaps). So {U,S} alone suffices.
- **Section 8**: Contains the full GAME-THEORETIC proof of Theorem 3, using Ehrenfeucht-Fraisse games. This is a very different proof technique from the syntactic separation of [GHR94] Chapter 10.

### 6.2 Does It Contain a Simpler Proof?

**No.** The 1993 paper's proof of expressive completeness (Section 8) is:
1. More general (covers all linear flows, not just integers)
2. More complex (uses Ehrenfeucht-Fraisse games, gap hierarchies, Stavi connectives)
3. Longer (the game proof spans pages 108-118)

The textbook's Chapter 10.2 proof for integers via syntactic separation is considerably simpler.

### 6.3 Relevance to Our Theorem 14 Context

The 1993 paper's Theorem 5 (= Reynolds' Theorem 5) is the exact result that Reynolds cites. Its proof is trivial once you have Theorem 3:

> "By the expressive completeness of {U,S,U',S'} over all linear structures, it suffices to prove that for any {U,S,U',S'}-formula B', there is a {U,S}-formula B such that B' <-> B is valid in all Prior structures. [...] We claim that U'(A,B) <-> bot is valid in all Prior structures."

This argument is a 5-line proof that depends on:
1. {U,S,U',S'} is expressively complete over all linear time (Theorem 3 / [GHR94] Chapter 11)
2. In Prior structures, U'(A,B) is always false (1 line: U'(A,B) requires a definable gap; Prior-U precludes this).

For our purposes, even Theorem 5 is not needed (as argued in Section 5 above).

---

## 7. Estimated Effort if Formalization Were Required

Even though we do NOT need to formalize expressive completeness for the current pipeline, here is an estimate of what it would take:

### 7.1 The Syntactic Separation Approach (Chapter 10.2)

| Component | Estimated LOC | Difficulty |
|-----------|---------------|------------|
| Separated wff definition | 50 | Low |
| Distributivity lemmas (10.2.1) | 200 | Medium |
| Negation of U/S lemmas (10.2.2) | 200 | Medium |
| 8 elimination lemmas (10.2.3) | 800-1200 | High (each ~100-150 lines) |
| Lemma 10.2.4 (single S with U) | 150 | Medium |
| Lemma 10.2.5 (single U formula) | 100 | Medium |
| Lemma 10.2.6 (multiple U formulas) | 100 | Medium |
| Lemma 10.2.7 (no S within U) | 100 | Medium |
| Lemma 10.2.8 (junction depth) | 150 | Medium |
| Theorem 10.2.9 (separation) | 20 | Low |
| Theorem 10.2.10 + 9.3.1 (expressive completeness) | 300 | High |
| **Total** | **2200-2600** | **~3-4 weeks** |

### 7.2 The Game-Theoretic Approach (1993 Paper, Section 8)

This would be significantly harder: EF-games, gap hierarchies, relativisation of connectives, game strategy composition. Estimated 4000-6000 LOC and 6-8 weeks.

### 7.3 The Theorem 5 Shortcut (Reynolds/GHR93)

If we only need expressive completeness for Prior structures:
1. Take {U,S,U',S'} expressively complete for all linear time as an AXIOM (sorry)
2. Prove U'(A,B) <-> bot in Prior structures (50 lines)
3. Derive {U,S} expressively complete for Prior structures (20 lines)

This is essentially what Reynolds does. But since we do not need it at all for the discrete case, even this shortcut is unnecessary.

---

## 8. Recommendations

### 8.1 For the Current Pipeline (Task 155)

**Do NOT formalize expressive completeness.** The `one_class` theorem already handles the discrete case without it. Focus instead on:

1. **ZIntervalStructure -> TaskFrame bridge**: The actual missing piece. Convert the k-equivalent Z-interval structure to a TaskModel counterexample.

2. **Truth transfer**: Connect `temporal_truth` on `OrderedMonadicStructure` to `truth_at` on `TaskModel` via `table_correctness`.

3. **Packaging**: Wire `chronicle_is_good` -> `doets_lemma_1_1` -> `table_correctness` -> countermodel.

### 8.2 For Future Work (Dense/Dedekind-Complete Completeness)

If the project later tackles completeness over real-valued or Dedekind-complete flows, expressive completeness WILL be needed (for the gap-elimination argument). At that point:
- The syntactic separation approach (Chapter 10.3) is the most tractable
- It requires the K+/K- and Gamma connectives
- The 8 elimination cases become more complex but structurally similar
- Estimated additional 3000-4000 LOC beyond the integer case

### 8.3 Summary Table

| Question | Answer |
|----------|--------|
| Do we need expressive completeness for discrete case? | **NO** |
| Why not? | `one_class` bypasses gap elimination; discrete orders have no gaps |
| What DO we need? | ZIntervalStructure -> TaskFrame bridge |
| Where is the actual blocker? | Transfer.lean line ~140: packaging Z-model as TaskFrame |
| What does Reynolds' line 700 use? | EC to find temporal C for gap-class properties |
| Is this on our critical path? | No -- `one_class` avoids this argument entirely |
| Estimated LOC if we DID need it? | 2200-2600 (syntactic separation for integers) |

---

## Appendix A: Literature Proof Structure

### Source: [GHR94] Chapter 10.2, Separation for S,U over Integer Time

**Strategy**: Syntactic rewriting via nested induction on formula structure

### Step Map

1. **Lemma 10.2.1**: Distributivity of U,S over boolean connectives -- [GHR94] p.368
2. **Lemma 10.2.2**: Negation of U,S equivalences (integer-specific) -- [GHR94] p.368
3. **Lemma 10.2.3**: Eight elimination cases for S(...U(A,B)...) -- [GHR94] pp.368-371
4. **Lemma 10.2.4**: Separation of S(C,F) with top-level U(A,B) -- [GHR94] pp.371-372
5. **Lemma 10.2.5**: Single U-formula, induction on S-nesting depth -- [GHR94] p.372
6. **Lemma 10.2.6**: Multiple U-formulas, induction on count -- [GHR94] pp.372-373
7. **Lemma 10.2.7**: No S-within-U, induction on U-nesting depth -- [GHR94] pp.373-374
8. **Lemma 10.2.8**: General case, induction on junction depth -- [GHR94] pp.374-375
9. **Theorem 10.2.9**: Separation theorem (follows from Lemma 10.2.8) -- [GHR94] p.375
10. **Theorem 10.2.10**: Expressive completeness (from 10.2.9 + 9.3.1) -- [GHR94] p.375

### Dependencies

- Step 3 depends on Steps 1, 2
- Step 4 depends on Step 3
- Step 5 depends on Step 4
- Step 6 depends on Step 5
- Step 7 depends on Step 6
- Step 8 depends on Step 7
- Step 9 depends on Step 8
- Step 10 depends on Step 9 and Theorem 9.3.1

### Potential Formalization Challenges

- **Step 3 (8 eliminations)**: Each case requires careful semantic reasoning about "where is the U-witness relative to now?" The proofs mix syntactic rewriting with semantic argument. Formalizing all 8 cases is tedious but mechanizable.
- **Step 2 (negation of U)**: Uses discreteness in an essential way. The proof that `~U(A,B) <-> G(~A) \/ U(~A /\ ~B, ~A)` over integers requires showing that in a discrete order, if U(A,B) fails, either A never holds in the future (G(~A)) or there is a first point where ~A /\ ~B holds with ~A holding thereafter until some further ~A.
- **Theorem 9.3.1 (separation -> expressive completeness)**: This is a separate induction on quantifier depth of FO formulas. It introduces auxiliary predicates R_=, R_>, R_< and uses separation to eliminate them. This step is conceptually clean but technically involved.

## Appendix B: Codebase File Map

| File | Role | Status |
|------|------|--------|
| `WeakCanonical/MonadicFO.lean` | FO formulas, signatures, eval | Complete |
| `WeakCanonical/NormalForm.lean` | Doets normal forms, bridge theorem | Complete |
| `WeakCanonical/NEquivalence.lean` | k-types, k-equiv, ordered sum, sum_preservation | Complete |
| `WeakCanonical/Table.lean` | Table translation temporal->FO, table_correctness | Complete |
| `WeakCanonical/OrderedSum.lean` | Doets Lemma 1.4 (wrapper), 1.5 (sorry) | 1.4 done, 1.5 sorry |
| `WeakCanonical/IntegerModel.lean` | good/very_good, gap elimination, one_class, chronicle_is_good | Complete |
| `WeakCanonical/ChronicleExtraction.lean` | Prior structure from MCS, Corollary 3 | Complete |
| `WeakCanonical/Transfer.lean` | Countermodel construction, mkSigFrom, mkAtomMap | Partial (falls back) |
| `WeakCanonical/FrameProperties.lean` | Frame property lemmas | Complete |
| `WeakCanonical/ReflexiveCanonical.lean` | Reflexive canonical model | Complete |
