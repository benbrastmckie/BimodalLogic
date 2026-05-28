# Elements of Finite Model Theory -- Chapters 3 and 7

**Leonid Libkin** (2004). *Elements of Finite Model Theory*. Springer. ISBN 3-540-21202-7.

Extracted: Chapter 3 (Ehrenfeucht-Fraisse Games) and Chapter 7 (Monadic Second-Order Logic and Automata).

---

## Chapter 3: Ehrenfeucht-Fraisse Games

### 3.1 First Inexpressibility Proofs

Standard model-theoretic tools (compactness, Lowenheim-Skolem) prove inexpressibility over arbitrary structures but do not always work for **finite** models.

**Proposition 3.1**: Connectivity of arbitrary graphs is not FO-definable (via compactness).

**Proposition 3.2**: Compactness fails over finite models. There is a theory T with no finite models whose every finite subset has a finite model (take T = {lambda_n | n >= 0} where lambda_n says "at least n elements").

**Proposition 3.3**: EVEN is not FO-definable (over empty vocabulary), proved by compactness + Lowenheim-Skolem.

**Lemma 3.4**: For every finite structure A, there is a sentence Phi_A such that B |= Phi_A iff B is isomorphic to A. (Hence every two finite structures agreeing on all FO sentences are isomorphic.)

**Methodology**: To show a property P is not FO-expressible over finite structures, find families {A_k} and {B_k} such that:
- A_k and B_k agree on all FO sentences of a certain complexity class L[k],
- A_k has property P and B_k does not.

---

### 3.2 Definition and Examples of Ehrenfeucht-Fraisse Games

**The game**: Two players -- **spoiler** and **duplicator** -- play on structures A and B.

Each round:
1. Spoiler picks a structure (A or B).
2. Spoiler picks an element from that structure.
3. Duplicator responds with an element from the other structure.

**Definition 3.5 (Partial isomorphism)**: Given sigma-structures A, B and tuples a = (a_1, ..., a_n), b = (b_1, ..., b_n), the pair (a, b) defines a partial isomorphism if:
- a_i = a_j iff b_i = b_j (equality preservation)
- a_i = c^A iff b_i = c^B (constant preservation)
- (a_{i_1}, ..., a_{i_k}) in P^A iff (b_{i_1}, ..., b_{i_k}) in P^B (relation preservation)

**Winning condition**: After n rounds with moves (a_1, ..., a_n) and (b_1, ..., b_n), the duplicator wins iff the map a_i -> b_i is a partial isomorphism.

**Notation**: A equiv_n B means the duplicator has an n-round winning strategy.

#### Games on Linear Orders

**Theorem 3.6**: Let k > 0, and let L_1, L_2 be linear orders of length at least 2^k. Then L_1 equiv_k L_2.

##### Proof #1 (Distance-based induction)

Expand vocabulary with min and max constants. The duplicator maintains:
1. If d(a_j, a_l) < 2^{k-i}, then d(b_j, b_l) = d(a_j, a_l).
2. If d(a_j, a_l) >= 2^{k-i}, then d(b_j, b_l) >= 2^{k-i}.
3. a_j <= a_l iff b_j <= b_l.

When spoiler plays into an interval, the duplicator responds preserving these conditions. Key case analysis: if the spoiler's move falls close to a previously played point, duplicate exactly; if far from all points, respond at the midpoint of the corresponding interval.

##### Proof #2 (Composition method) -- KEY FOR OUR PURPOSES

**Lemma 3.7 (Composition Lemma for Linear Orders)**: Let L_1, L_2, a in L_1, b in L_2 be such that:
- L_1^{<=a} equiv_k L_2^{<=b}, and
- L_1^{>=a} equiv_k L_2^{>=b}.

Then (L_1, a) equiv_{k-1} (L_2, b).

*Proof*: The duplicator's strategy is to use the winning strategy for L_1^{<=a} equiv_k L_2^{<=b} when spoiler plays in the left part, and the winning strategy for L_1^{>=a} equiv_k L_2^{>=b} when spoiler plays in the right part. By the remark preceding the lemma, the duplicator always responds to a by b and to b by a.

**Proof of Theorem 3.6 using composition**: By induction on k. For the induction step, assume L_1 and L_2 have length at least 2^k. When spoiler plays a in L_1, find b in L_2 such that:
- If L_1^{<=a} has length < 2^{k-1}: choose b with d(min^{L_2}, b) = d(min^{L_1}, a), so L_1^{<=a} isomorphic to L_2^{<=b}. Both right parts have length >= 2^{k-1}, so by IH, L_1^{>=a} equiv_{k-1} L_2^{>=b}.
- If L_1^{>=a} has length < 2^{k-1}: symmetric case.
- If both parts have length >= 2^{k-1}: choose b so that both parts of L_2 have length >= 2^{k-1}, and apply IH to both.

By Lemma 3.7, (L_1, a) equiv_{k-1} (L_2, b). QED.

**This is the core composition pattern**: splitting a structure at a point, showing equivalence of the parts, and composing the strategies.

---

### 3.3 Games and the Expressive Power of FO

**Definition 3.8 (Quantifier rank)**: qr(phi) is the depth of quantifier nesting.
- qr(atomic) = 0
- qr(phi_1 or phi_2) = max(qr(phi_1), qr(phi_2))
- qr(not phi) = qr(phi)
- qr(exists x phi) = qr(phi) + 1

**FO[k]** = all FO formulae of quantifier rank up to k.

**Theorem 3.9 (Ehrenfeucht-Fraisse)**: The following are equivalent:
1. A and B agree on FO[k].
2. A equiv_k B.

**Corollary 3.10**: A property P of finite sigma-structures is not expressible in FO iff for every k, there exist A_k equiv_k B_k such that A_k has P and B_k does not.

**Corollary 3.12**: EVEN is not FO-expressible over linear orders. (Pick A_k of length 2^k and B_k of length 2^k + 1; by Theorem 3.6, A_k equiv_k B_k.)

---

### 3.4 Rank-k Types

**Lemma 3.13**: If sigma is finite, then up to logical equivalence, FO[k] over sigma contains only finitely many formulae in m free variables.

**Definition 3.14 (Types)**: The rank-k m-type of a tuple a over structure A is:

    tp_k(A, a) = {phi in FO[k] | A |= phi(a)}

A rank-k m-type is any set of formulae of the form tp_k(A, a) with |a| = m.

**Theorem 3.15**: 
(a) The number of different rank-k m-types is finite.
(b) There exist FO[k] formulae alpha_1(x), ..., alpha_r(x) enumerating all rank-k types, such that every FO[k] formula is equivalent to a disjunction of some alpha_i's.

**Corollary 3.16**: The equivalence relation equiv_k is of finite index.

**Corollary 3.17**: A property P is expressible in FO iff there exists k such that for every A, B: if A in P and A equiv_k B, then B in P. (Games are **complete** for FO-definability.)

---

### 3.5 Proof of the Ehrenfeucht-Fraisse Theorem

**Back-and-forth relations**: Define a family of relations simeq_k:
- A simeq_0 B iff A and B satisfy the same atomic sentences.
- A simeq_{k+1} B iff:
  - **forth**: for every a in A, there exists b in B such that (A, a) simeq_k (B, b);
  - **back**: for every b in B, there exists a in A such that (A, a) simeq_k (B, b).

**Theorem 3.18**: The following are equivalent:
1. A and B agree on FO[k].
2. A equiv_k B (game equivalence).
3. A simeq_k B (back-and-forth equivalence).

*Proof sketch*:
- (2 => 3): By induction on k, using the game strategy to produce the back-and-forth witnesses.
- (3 => 1): By induction on k. For quantifier-rank k+1 sentences of the form exists x phi(x), use the forth condition to find matching witnesses.
- (1 => 2): By induction using type-defining formulae.

---

### 3.6 More Inexpressibility Results

**Corollary 3.19**: Connectivity of finite graphs is not FO-definable (reduction from EVEN over linear orders).

**Proposition 3.20**: Testing if a finite graph is a tree is not FO-definable (game argument with distance-based invariant on successor graphs with components).

---

### 3.7 Bibliographic Notes

- The composition method (Proof #2 of Theorem 3.6) is a special case of the **Feferman-Vaught Theorem**.
- It is discussed further in **Exercise 3.15** (composition for Cartesian products and disjoint unions) and in **Chapter 7** (for MSO).
- For a recent survey of the composition method, see Makowsky [177].

### Exercise 3.15 (Composition for Products and Disjoint Unions)

Given A_1 equiv_k A_2 and B_1 equiv_k B_2, show that:
- A_1 x B_1 equiv_k A_2 x B_2 (Cartesian product)
- A_1 ⊔ B_1 equiv_k A_2 ⊔ B_2 (disjoint union)

This is the general composition principle: **equivalence is preserved by structure-combining operations**.

---

## Chapter 7: Monadic Second-Order Logic and Automata

### 7.1 Second-Order Logic and Its Fragments

**Definition 7.1 (Second-order logic, SO)**: Extends FO with second-order variables (ranging over subsets and relations) and quantification over them.

**Definition 7.2 (MSO -- Monadic Second-Order)**: Restriction of SO where all second-order variables have arity 1 (range over subsets of the universe).

Every MSO formula is equivalent to one in the normal form: Q_1 X_1 ... Q_n X_n Q_1 x_1 ... Q_l x_l psi, where Q_i are second-order quantifiers, Q_j are first-order quantifiers, and psi is quantifier-free.

**Definition 7.3 (Existential MSO = exists-MSO)**: MSO formulae of the form exists X_1 ... exists X_n phi, where phi is FO.

**Definition 7.4 (MSO quantifier rank)**: Same as FO but with qr(exists X phi) = qr(forall X phi) = qr(phi) + 1.

---

### 7.2 MSO Games and Types

**MSO rank-k m,l-type**: For a structure A, m-tuple a, and l-tuple of subsets V:

    mso-tp_k(A, a, V) = {phi(x, X) in MSO[k] | A |= phi(a, V)}

**Proposition 7.5**: There exist only finitely many MSO rank-k m,l types, with defining formulae alpha_i.

**Definition 7.6 (MSO game)**: Like the EF game but with two kinds of moves:
- **Point move**: spoiler picks element from A or B; duplicator responds in the other.
- **Set move**: spoiler picks a subset of A or B; duplicator responds with a subset of the other.

Duplicator wins if after k rounds, the point moves define a partial isomorphism that also preserves the set memberships.

**Theorem 7.7**: mso-tp_k(A, a_0, V_0) = mso-tp_k(B, b_0, U_0) iff (A, a_0, V_0) equiv_k^{MSO} (B, b_0, U_0).

**Proposition 7.9**: A property P is expressible in MSO iff there exists k such that for every A, B with P, if A has P and B doesn't, the spoiler wins the k-round MSO game.

---

### 7.3 Composition for MSO (Lemma 7.11) -- KEY RESULT

**Lemma 7.11 (Composition for disjoint unions)**: Let A be the disjoint union of A_1 and A_2, and B the disjoint union of B_1 and B_2. If A_1 equiv_k^{MSO} B_1 and A_2 equiv_k^{MSO} B_2, then A equiv_k^{MSO} B.

*Proof sketch*:
- **Point move**: If spoiler plays a in A_1, duplicator uses winning strategy for A_1 equiv_k^{MSO} B_1 to find response b in B_1.
- **Set move**: If spoiler plays U in A, decompose U = U_1 ∪ U_2 where U_i = U ∩ A_i. Use the individual winning strategies to find responses V_1 and V_2. Response is V = V_1 ∪ V_2.

**Application (Proposition 7.12)**: EVEN is not MSO-expressible (over empty vocabulary).

*Proof by induction on k*: For |A|, |B| >= 2^{k+1}, given spoiler's set move U in A:
1. |U| <= 2^k: pick V in B with |V| = |U|. By IH, U equiv_k^{MSO} V and A-U equiv_k^{MSO} B-V. Compose.
2. |A-U| <= 2^k: symmetric.
3. Both |U| and |A-U| > 2^k: find V in B with both |V| and |B-V| >= 2^k. Apply IH to both. Compose.

---

### 7.4 MSO on Strings and Regular Languages

Strings over alphabet Sigma are represented as structures M_s = ({1, ..., n}, <, (P_a)_{a in Sigma}) where P_a = positions labeled a.

**Theorem 7.21 (Buchi)**: A language is definable in MSO iff it is regular.

*Proof (MSO -> automaton)*: Given MSO sentence Phi of quantifier rank k:
- States = rank-k MSO types {tau_0, ..., tau_m}.
- Initial state = tau_0 (type of empty string).
- Transition: tau_j in delta(tau_i, a) iff there exist strings s with mso-tp_k(M_s) = tau_i and mso-tp_k(M_{s.a}) = tau_j.
- **Key composition argument**: If M_{s_1} equiv_k^{MSO} M_{t_1} and M_{s_2} equiv_k^{MSO} M_{t_2}, then M_{s_1.s_2} equiv_k^{MSO} M_{t_1.t_2}. (This is the string version of Lemma 7.11.)
- The automaton is deterministic because composition preserves type uniqueness.

*Proof (automaton -> MSO)*: Given DFA A = (Q, q_0, F, delta), construct exists-MSO sentence guessing sets X_0, ..., X_{m-1} (one per state) that partition the universe and simulate transitions.

**Corollary 7.22**: Over strings, MSO = exists-MSO.

### 7.5 FO on Strings and Star-Free Languages

**Definition 7.25 (Star-free languages)**: Built from emptyset, a (for a in Sigma) using union (+), complement (overline), and concatenation (.).

**Theorem 7.26 (McNaughton-Papert)**: A language is definable in FO iff it is star-free.

*Proof (star-free -> FO)*: By induction on the star-free expression. Concatenation L(e_1) . L(e_2) becomes: exists x (phi_1(x) AND phi_2(x)), where phi_1 relativizes to {y | y <= x} and phi_2 to {y | y > x}.

*Proof (FO -> star-free)*: By induction on quantifier rank k.
- For exists x phi(x) where qr(phi) = k: define S_Phi = {(tau_i, tau_j) | for some s and position p, M_s |= phi(p), tp_k(M_s^{<=p}) = tau_i, tp_k(M_s^{>p}) = tau_j}.
- Then L(Phi) = Union over (tau_i, tau_j) in S_Phi of L(Psi_i) . L(Psi_j).
- **Key composition step**: this uses the same composition argument as Theorem 7.21: splitting a string at a point and determining truth from the types of the two parts.

**Corollary 7.27**: There exist regular languages which are not star-free (e.g., (aa)* because EVEN is not FO-definable over linear orders).

---

### 7.6 Tree Automata

Extension of string automata to trees (ranked and unranked). MSO over trees = regular tree languages (Theorem 7.30).

### 7.7 Complexity of MSO

**Proposition 7.35**: For each level Sigma^p_i or Pi^p_i of the polynomial hierarchy, there is a complete problem expressible in MSO.

**Corollary 7.36**: Over strings and trees, evaluating MSO sentences is fixed-parameter linear.

**Theorem 7.37 (Courcelle)**: For structures of bounded treewidth, MSO model-checking is fixed-parameter linear.

**Nonelementary blow-up**: Converting MSO to automata gives automata of size bounded by a tower of exponentials of height proportional to the number of quantifier alternations. This is inherently nonelementary.

---

### 7.8 Bibliographic Notes

- **Composition method**: used in proofs of Proposition 7.12 (EVEN not MSO-definable), Theorems 7.21 (Buchi) and 7.26 (McNaughton-Papert). These are special cases of the **Feferman-Vaught Theorem** [79].
- For more on the composition method: Makowsky [177], as well as Exercises 7.25 and 7.26.
- Theorem 7.21 is due to **Buchi** [27]; the proof follows Ladner [160].
- Theorem 7.26 was proved by **McNaughton and Papert** [182]; the game-based proof follows Thomas [233].
- Thomas [232, 233] (references [231]-[233] are Wolfgang Thomas's work on EF games, composition, and monadic theories) -- this is the Thomas 1997 paper that connects these themes.

---

## Key Insights for the ProofChecker Project

### 1. Composition Lemma for Linear Orders (Lemma 3.7)

**Statement**: If L_1^{<=a} equiv_k L_2^{<=b} and L_1^{>=a} equiv_k L_2^{>=b}, then (L_1, a) equiv_{k-1} (L_2, b).

**Mechanism**: The duplicator plays in whichever sub-structure the spoiler's move falls into, using the appropriate winning strategy. The point a/b serves as the "interface" between the two strategies.

**For interval splitting**: When a new point is inserted into a matched configuration of two linear orders, the EF game on the whole structure reduces to EF games on the sub-intervals. The composition lemma guarantees that if corresponding sub-intervals are equivalent, the whole structures with the new point are equivalent (with one fewer round).

### 2. Composition for MSO (Lemma 7.11)

Extends the composition principle to MSO: for disjoint unions, if components are MSO-equivalent, the union is MSO-equivalent. The key subtlety is handling **set moves**: a set chosen in the union is decomposed into its intersections with the components.

### 3. The Composition Method in Proofs

Three theorems proved via composition in this book:
- **Theorem 3.6** (linear orders of sufficient length are EF-equivalent): split at spoiler's move, apply IH to parts.
- **Theorem 7.21** (Buchi: MSO = regular on strings): types compose under concatenation.
- **Theorem 7.26** (McNaughton-Papert: FO = star-free): existential quantification splits string at witness, types of parts determine truth.

All three follow the same pattern:
1. **Split** the structure at a point.
2. **Determine types** of the resulting parts.
3. **Compose** the types to determine the type of the whole.

### 4. Types as the Composition Interface

The finite number of rank-k types (Theorem 3.15, Proposition 7.5) is what makes composition work: there are only finitely many possible "behaviors" for a sub-structure, so the composition can be described by a finite table.

For the BX project: the rank-k types of sub-intervals of a linear order form a finite set, and the type of the whole interval is determined by the types of its parts together with the type of the splitting point. This is exactly the principle needed for the interval splitting / fan problem.
