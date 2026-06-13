# Ehrenfeucht-Fraisse Games, the Composition Method, and the Monadic Theory of Ordinal Words

**Wolfgang Thomas** (1997). In J. Mycielski, G. Rozenberg, A. Salomaa (eds.), *Structures in Logic and Computer Science: A Selection of Essays in Honor of A. Ehrenfeucht*, LNCS 1261, pp. 118--143. Springer. DOI: [10.1007/3-540-63246-8_8](https://doi.org/10.1007/3-540-63246-8_8)

RWTH Aachen, Germany.

**PDF Status**: Not obtained. The Springer link requires subscription/purchase. The Semantic Scholar page (fd64187f0efa6ab5af30633543213d99d729cab0) does not provide an open-access PDF.

---

## Overview (from secondary sources)

This is a survey paper connecting three major threads in the theory of definability over linear structures:

1. **Ehrenfeucht-Fraisse games** as the fundamental tool for characterizing logical equivalence.
2. **The composition method** (Feferman-Vaught theorem and its specializations) as the key technique for reducing game arguments on complex structures to game arguments on simpler components.
3. **Monadic theories of ordinal words** -- the decidability and definability theory for monadic second-order logic (MSO) interpreted over ordinal-indexed sequences.

Thomas is a leading authority on the connections between automata theory, logic on words, and the composition method. His other papers [231]-[233] in Libkin's bibliography develop these themes systematically.

---

## Known Content (reconstructed from citations and related work)

### The Composition Method for Linear Structures

The composition method, in the context of this paper, refers to the following general principle:

**Feferman-Vaught Theorem** (specialized to linear orders): If a structure A is decomposed into parts A_1, ..., A_n (e.g., by cutting a linear order at distinguished points), then the theory of A (up to a given quantifier rank) is determined by:
- The theories of the individual parts A_i (up to the same or related quantifier rank), and
- The way the parts are assembled (the "index structure").

For **linear orders** specifically:
- Cutting at a point a decomposes (L, a) into L^{<=a} and L^{>=a}.
- The rank-k type of (L, a) is determined by the rank-k types of L^{<=a} and L^{>=a}.
- This is Lemma 3.7 of Libkin (2004), attributed to the composition method tradition.

For **ordinal words** (labeled ordinals):
- An ordinal alpha decomposes as a sequence of segments.
- The MSO theory of the ordinal word is determined by the MSO types of the segments and their ordinal arrangement.
- This connects to Buchi's work on decidability of MSO over ordinals.

### Automata on Ordinal Words

Thomas's work extends the classical Buchi theorem (MSO = regular languages on omega-words) to transfinite words indexed by ordinals:
- **Ordinal automata**: automata that process words of ordinal length, with limit transitions at limit ordinals.
- **Composition**: the type of an ordinal word of length alpha + beta is determined by the types of the alpha-prefix and the beta-suffix.
- **Decidability**: the MSO theory of specific ordinals (like omega, omega^2, etc.) is decidable via the automata-composition connection.

### EF Games on Ordinals

The EF game on ordinals uses the same basic structure as on finite linear orders, but requires handling limit points:
- When the spoiler plays a limit ordinal, the duplicator must respond with a point whose neighborhoods "look the same" up to the relevant quantifier rank.
- The composition method reduces this to: the type of the interval below the limit point is determined by the types of its initial segments.

---

## Relevance to the ProofChecker Project

### 1. Composition for Interval Splitting

Thomas's paper provides the general framework for understanding how the composition method applies to linear temporal structures. The key principle:

> When a new point z is inserted into an interval [a, b] of a linear order, the EF-type of the resulting structure ([a, b], z) is determined by the EF-types of [a, z] and [z, b].

This is precisely the principle needed for the "fan problem" in the BX completeness proof: when extending a model by inserting a new time point, the temporal types of the sub-intervals determine the temporal type of the whole.

### 2. Monadic Theory and Temporal Logic

The connection between MSO on linear orders and temporal logic (via Kamp's theorem and its extensions) means that Thomas's composition results for MSO directly inform the composition structure needed for Until/Since temporal logic.

### 3. Ordinal Extensions

For the BX project, which works with general linear orders (not just naturals or reals), Thomas's treatment of ordinal words is relevant: it shows how the composition method extends beyond omega to arbitrary well-ordered (and more general) linear structures.

---

## Key References in Thomas's Paper

Based on Libkin's bibliography and the paper's context:

- **Buchi** (1962): MSO decidability over omega.
- **Ehrenfeucht** (1961): The game characterization of elementary equivalence.
- **Fraisse** (1954): Back-and-forth characterization of elementary equivalence.
- **Feferman-Vaught** (1959): The composition theorem for generalized products.
- **Shelah** (1975): Monadic theory of order (decidability results).
- **Thomas** (1982, 1990, 1997): Series of papers developing the automata-logic-composition connection for words and trees.

---

## Obtaining the Paper

Possible access routes:
- **Springer**: https://link.springer.com/chapter/10.1007/3-540-63246-8_8 (paywall, ~$30)
- **Library access**: Available through most university library Springer subscriptions.
- **Interlibrary loan**: Standard ILL request for LNCS 1261.
- **Author contact**: Wolfgang Thomas at RWTH Aachen (though he may be retired).
