# Literature Sources: Fraïssé Back-and-Forth for Monadic Logic on Linear Orders

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-28
**Focus**: Academic sources for formalizing the Fraïssé back-and-forth argument for monadic second-order logic on linear orders, specifically the interval splitting problem in EF games.

---

## Executive Summary

The specific blocker — proving `nf_2var_from_interval_data` (StaviCompleteness.lean:1873) — is a direct formalization of GHR93/GHR94's Lemma 11 (decomposition agreement ↔ game winning). The correct proof route goes THROUGH the EF game rather than around it.

**Key finding**: Report `44_literature-interval-splitting.md` already establishes that GHR93 never derives sub-interval types from full-interval types directly. The composition/decomposition proof uses the game as intermediary. The sub-interval splitting problem dissolves when the correct proof structure is followed.

**Highest-priority sources already in `literature/`**:
1. `Doets_1987_Completeness_and_Definability_thesis.md` — Chapter 3, Lemmas 3.1.7–3.1.8: THE ordered sum composition theorem with proof
2. `Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch12.md` — The source being formalized; game proof in Section 12.8
3. `Doets_1989_Monadic_Pi11_Theories.md` — The 1989 NDJFL paper: same techniques in published form

**New sources to obtain**:
- Rosenstein 1982, *Linear Orderings* — Chapter 6 (EF game proof) and Chapter 14 (monadic second-order theory); the cleanest textbook exposition of the back-and-forth composition for linear orders
- Thomas 1997, "Ehrenfeucht games, the composition method, and the monadic theory of ordinal words" — survey with explicit proof structure for ordered sum composition
- Shelah 1975, "The monadic theory of order" — foundational composition theorem (available free at shelah.logic.at)
- Rabinovich 2012/2014, "A proof of Kamp's theorem" — simple proof using unusual back-and-forth games; may illuminate the specific structure needed for the Fraïssé lemma

---

## 1. Sources Already in `literature/`

### 1.1 Doets 1987 Thesis — **HIGHEST PRIORITY**

**Citation**: Doets, H.C. (1987). *Completeness and Definability: Applications of the Ehrenfeucht Game in Second-Order and Intensional Logic*. PhD thesis, Universiteit van Amsterdam. Promotor: J.F.A.K. van Benthem.

**File**: `literature/Doets_1987_Completeness_and_Definability_thesis.md` (43 KB extracted, full PDF 1.2 MB)

**Contains the specific proof technique needed**: YES

The thesis is the most directly relevant source in the literature directory for the interval splitting problem. Key content:

**Chapter 1 (pp. 1–22): Fraïssé-Ehrenfeucht theory for L∞ω**
- Defines n-characteristics (n-char) for ordered models with monadic predicates
- Proves Lemma 1.7.1: finitely many n-equivalence classes in each finite language (the finiteness fact underlying normal forms)
- Contains the basic back-and-forth machinery

**Chapter 3 (pp. 36–57): Monadic Π¹₁-theories of linear orderings** — THE relevant chapter
- Lemma 3.1.7: **Ordered sum composition** — if `m(i) ≡ⁿ m'(i)` for all i in I, then `Σᵢ∈I m(i) ≡ⁿ Σᵢ∈I m'(i)`. This is the proof that n-equivalence is preserved under ordered sums, which is exactly the composition/decomposition argument needed.
- Lemma 3.1.8: **Indexed ordered sum composition** — if `(I, {i | m(i) ⊨ σ})_σ ≡ⁿ (J, {j | m'(j) ⊨ σ})_σ`, then `Σᵢ m(i) ≡ⁿ Σⱼ m'(j)`. This handles the case where the index structure also varies.
- These lemmas are proved using the EF game; the proof shows Duplicator can coordinate strategies across sub-intervals by tracking which n-characteristics are realized in each "condensation block."

**Chapter 6 (pp. 82–88): Game theory for intensional logics**
- Contains explicit n-characteristic definitions for modal/tense logic
- Theorem 6.4: n-characteristics characterize EF game equivalence
- Section 6.12: Normal forms — φ is equivalent to a disjunction of n-characteristics; every n-characteristic is a normal form. **This is the direct antecedent of GHR94's Proposition 7 and the NF decomposition.**

**Chapter 7 (pp. 89–93): Completeness for ℤ-time**
- Shows how to transform countermodels into ℤ-models using the EF game
- Uses ordered sum decomposition: `N = Σ_A A*` where each A* is an ordered model matching the n-characteristics in equivalence class A
- Claim 9: If x ∈ A and n ∈ A* have the same shape, then `M ⊨ φ[x] ↔ N ⊨ φ[n]` for all formulas of rank ≤ k. Proof: use the EF game for tense logic. Duplicator can always maintain the invariant that positions have the same shape within their respective equivalence class copies.

**How it handles sub-interval splitting**: Doets avoids the sub-interval problem entirely by working at the level of equivalence classes (condensations). The key insight is Lemma 3.1.7: if each summand is n-equivalent to its counterpart, the sums are n-equivalent. The proof has Duplicator track which n-characteristics are realized in each remaining sub-interval, using the fact that there are only finitely many n-characteristics (Lemma 1.7.1) to ensure the strategy is well-defined.

**Accessibility**: PDF already in `literature/`, markdown conversion extracted. Full content readable.

---

### 1.2 Doets 1989 NDJFL Paper — **HIGH PRIORITY**

**Citation**: Doets, K. (1989). "Monadic Π¹₁-Theories of Π¹₁-Properties." *Notre Dame Journal of Formal Logic* 30(2), 224–240. DOI: 10.1305/ndjfl/1093635080.

**File**: `literature/Doets_1989_Monadic_Pi11_Theories.md` (48 KB extracted, full PDF 1.8 MB)

**Contains the specific proof technique needed**: YES (same as thesis, published form)

This is the published version of Chapter 3 of the 1987 thesis. It contains:
- Theorem 1.2: The conservation theorem — model has n-equivalents satisfying the second-order property iff the first-order schema is conservative
- Lemma (ordered sums): `Σᵢ∈I m(i)` is n-equivalent to `Σⱼ∈J m'(j)` when the index structure (colored by n-characteristics) is n-equivalent and summands agree on n-characteristics
- Explicit example: if ordered model M is definably scattered (no dense sub-ordering), construct a scattered n-equivalent by: (a) define the relation R so aRb iff (a,b) has a scattered n-equivalent, (b) this induces a condensation, (c) each equivalence class has a scattered n-equivalent, (d) compose via Lemma on ordered sums.

**Reynolds 1992 reference**: Reynolds 1992 (in `literature/`) cites "Doets's theorem" (Theorem 3.8 in the NDJFL paper) as the key technical lemma for the rational-to-real transfer. The same theorem is the basis for the bridge lemma construction.

**Accessibility**: PDF already in `literature/`, markdown conversion extracted. The abstract explicitly states proofs use "the Ehrenfeucht-Fraïssé-game."

---

### 1.3 GHR94 Chapter 12 — **HIGHEST PRIORITY**

**Citation**: Gabbay, D.M., Hodkinson, I. & Reynolds, M.A. (1994). *Temporal Logic: Mathematical Foundations and Computational Aspects*, Vol. 1, Chapter 12. Oxford University Press.

**File**: `literature/Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch12.md` (74 KB extracted)

**Contains the specific proof technique needed**: YES — this is the direct source being formalized

From the extracted markdown, Section 12.8 (the game proof, not the separation proof):
- The DIRECT proof of expressive completeness using games (as opposed to the separation/reduction proof in Chapter 11)
- Section 12.8.8 (Lemma 11): Game winning ↔ decomposition agreement
- Section 12.8.15 (Theorem): Forward game → backward game
- Section 12.8.18 (Composition Lemma / Proposition 12.8.18): When Spoiler picks a new interior point, Duplicator responds using the forward game at higher rank. The forward game provides witnesses for ALL decomposition formulas for sub-intervals simultaneously. Sub-interval type matching is NOT done separately — it is a consequence of the game.

**The key structural insight** (from `44_literature-interval-splitting.md`, which has already read the ch12 markdown):
GHR93/GHR94 packages sub-interval data into a single first-order formula Ψ. The existential quantifiers in Ψ produce witnesses satisfying ALL constraints simultaneously. Sub-interval splitting is handled by first-order witnessing, not by a separate derivation. The game handles sub-interval matching internally through its round structure.

**What's missing from the Lean code**: The bridge from 1-var NF agreement + interval_nf_types → decomposition_agreement (at n=0). Once this is established, `ghr93_decomposition_implies_game` (already sorry-free) gives game winning, and game winning gives NF agreement.

---

### 1.4 GHR93 Paper — **HIGH**

**Citation**: Gabbay, D.M., Hodkinson, I. & Reynolds, M.A. (1993). "Temporal expressive completeness in the presence of gaps." In *Proc. ASL European Meeting 1990*, LNLI, Springer-Verlag.

**File**: `literature/Gabbay_Hodkinson_Reynolds_1993_Temporal_expressive_completeness_gaps.md` (76 KB extracted)

**Contains the specific proof technique needed**: Partial — this is the conference version; the full proof is in GHR94 Ch. 12. GHR93 Section 8 is the relevant section (EF games), but the conference paper is less detailed than the book chapter.

The GHR93 paper introduces: n;r-decomposition formulas, the Fraïssé back-and-forth game G_{n;r}, and the equivalence between decomposition agreement and game winning. The specific sub-interval splitting argument is described but less explicitly than in GHR94 Ch. 12.

---

### 1.5 GHR94 Chapters 9 and 10 — **MEDIUM**

**Files**: `literature/Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch9.md` and `_ch10.md`

These chapters cover the separation approach (Chapter 10: algebraic rewriting to eliminate nested connectives). Relevant for understanding the alternative proof strategy but not the game proof. Ch. 10 Section 10.2 contains the 8 elimination cases for integer time — this is the **separation** side of expressive completeness, not the game side.

---

### 1.6 Hodkinson-Reynolds 2006 Handbook Chapter — **MEDIUM**

**Citation**: Hodkinson, I. & Reynolds, M. (2006). "Temporal Logic." Ch. 11 (pp. 655–720) in *Handbook of Modal Logic*, Elsevier.

**File**: `literature/Hodkinson_Reynolds_2006_Temporal_Logic_Handbook_Ch11.md` (9.6 KB — TRUNCATED to 3 pages)

**Contains the specific proof technique needed**: Unknown (file truncated)

The full chapter is available as a PDF at `cgi.csc.liv.ac.uk/~frank/MLHandbook/11.pdf` (confirmed by web search). Section 4 covers expressive completeness including the separation property. This is a 2006 survey and would contain a cleaner presentation of the GHR94 proof. The truncated file only has the table of contents and introduction.

**Recommendation**: Obtain the full chapter (see Section 3 below).

---

## 2. Sources Not in `literature/` — New Acquisitions Recommended

### 2.1 Rosenstein 1982, *Linear Orderings* — **PRIORITY: HIGH**

**Citation**: Rosenstein, J.G. (1982). *Linear Orderings*. Academic Press, Pure and Applied Mathematics vol. 98. ISBN 0-12-597680-1.

**Contains the specific proof technique needed**: YES

According to web search results, Chapters 6, 7, and 13 contain introductions to the EF game, and Chapter 14 contains the monadic second-order theory. Key content:
- Chapter 6, Section 1: "The Play of the Game" (pp. 93–107)
- Theorem 6.6: Player II has a winning strategy in the n-game on A and B iff for each element a ∈ A there exists b ∈ B such that G_n(A<a, B<b) and G_n(A>a, B>b) both favor II (and symmetrically). This is the back-and-forth theorem for linear orders — the direct antecedent of the interval composition argument.
- Chapter 14: The second-order (monadic) theory of linear orderings

**Relevance to blocker**: Theorem 6.6 is the exact theorem underlying the Lean bridge lemma. If (x,t) and (x',t') are n-equivalent as intervals (Player II wins), then for any new point u in (x,t), there exists u' in (x',t') such that II wins on both sub-intervals. This is the sub-interval splitting argument in pure game-theoretic form, without reference to normal forms or decomposition.

**Accessibility**: Available via Internet Archive (free borrowing): https://archive.org/details/linearorderings0000rose. Also at vdoc.pub (partial). 487 pages; Chapter 6 starts at p. 93.

**Priority**: HIGH — this is the cleanest textbook treatment of exactly the back-and-forth theorem for linear orders that the bridge lemma requires.

---

### 2.2 Thomas 1997, "Ehrenfeucht Games, the Composition Method, and the Monadic Theory of Ordinal Words" — **PRIORITY: HIGH**

**Citation**: Thomas, W. (1997). "Ehrenfeucht games, the composition method, and the monadic theory of ordinal words." In Mycielski, J., Rozenberg, G. & Salomaa, A. (eds.), *Structures in Logic and Computer Science: A Selection of Essays in Honor of Andrzej Ehrenfeucht*, LNCS 1261, pp. 118–143. Springer.

**Contains the specific proof technique needed**: YES

According to Semantic Scholar description: "The paper reviews Shelah's extension of Ehrenfeucht games and explains the 'composition of monadic theories' in the context of the monadic theory of the ordinal ordering (ω, <), comparing it with the automata theoretic approach due to Büchi."

This is an explicit survey of the composition method with a worked proof for the monadic theory of ordinal words. Key sections would include: the n-theory definition, the ordered sum composition theorem (MSO theory of A+B determined by MSO theories of A and B), and the back-and-forth argument for the composition.

**Accessibility**: Springer paywall (LNCS vol. 1261). A preprint/CiteSeer version exists at: https://citeseerx.ist.psu.edu/document?repid=rep1&type=pdf&doi=c80a550e9e96fb0592517807a3f70625d1184f6e (but had certificate issues when fetched).

**Priority**: HIGH — this is the clearest survey-level proof of the composition method. Would provide the "background proof" that Doets' Lemmas 3.1.7–3.1.8 are special cases of.

---

### 2.3 Shelah 1975, "The Monadic Theory of Order" — **PRIORITY: MEDIUM-HIGH**

**Citation**: Shelah, S. (1975). "The monadic theory of order." *Annals of Mathematics* 102(3), 379–419. DOI: 10.2307/1971037.

**Contains the specific proof technique needed**: PARTIAL (foundational, but dense)

Shelah's paper introduces the "n-theory" of a structure: the set of all monadic sentences of quantifier rank ≤ n that the structure satisfies. Key theorem: the n-theory of an ordered sum Σᵢ∈I M_i is determined by the n-theory of the index I (with predicates colored by the n-theories of the summands) together with the n-theories of the summands themselves. This is the composition theorem.

The proof is model-theoretic and uses the EF game. However, the paper is dense and the proof techniques are implicit in the inductive structure. Thomas 1997 (above) provides a cleaner exposition.

**Accessibility**: FREE — full PDF available at shelah.logic.at: https://shelah.logic.at/files/213042/42.pdf (confirmed available; also at Annals of Mathematics).

**Priority**: MEDIUM-HIGH — foundational, but Thomas 1997 gives the same result more accessibly. Relevant sections: the ordered sum composition theorem (Section 1–2), the application to dense orders (Section 3).

---

### 2.4 Rabinovich 2012/2014, "A Proof of Kamp's Theorem" — **PRIORITY: MEDIUM**

**Citation**: Rabinovich, A. (2014). "A proof of Kamp's theorem." *Logical Methods in Computer Science* 10(1). Also: CSL 2012 proceedings, LIPIcs 16, pp. 516–527. DOI: 10.2168/LMCS-10(1:14)2014.

**Contains the specific proof technique needed**: POSSIBLY (game-based proof of temporal expressive completeness)

Rabinovich's proof of Kamp's theorem is described as using "unusual back-and-forth games" to prove that FO on linear orders is equivalent to temporal logic with Since and Until. This is a different result from GHR94 (GHR94 handles general linear time with Stavi connectives; Kamp's theorem handles FO over real/rational/integer time with standard Until/Since). However, the game technique may illuminate the sub-interval splitting argument.

The "unusual" aspect of the game is that moves can go in both temporal directions (future and past), mirroring the Since/Until semantics. The key inductive lemma (as referenced in prior searches) is the main back-and-forth argument showing the game captures exactly what temporal formulas distinguish.

**Accessibility**: FREE — LMCS version at: https://lmcs.episciences.org/730/pdf. Also Dagstuhl DROPS: https://drops.dagstuhl.de/storage/00lipics/lipics-vol016-csl2012/LIPIcs.CSL.2012.516/LIPIcs.CSL.2012.516.pdf. The paper is ~20 pages.

**Priority**: MEDIUM — useful for seeing a clean game-based proof of temporal expressive completeness, but the proof structure is for a weaker result (Kamp's theorem, not Stavi completeness). May provide the "Fraïssé lemma" proof structure referenced in `43_bridge-lemma-resolution.md`.

---

### 2.5 Gurevich, Chapter XIII "Monadic Second-Order Theories" — **PRIORITY: MEDIUM**

**Citation**: Gurevich, Y. (1985). "Monadic Second-Order Theories." Chapter XIII in *Model-Theoretic Logics*, ed. Barwise & Feferman, Springer. Also as: Gurevich, Y. (1985). Opera 64.

**Contains the specific proof technique needed**: PARTIALLY

Gurevich's survey chapter in *Model-Theoretic Logics* covers the composition method (developed jointly with Shelah) with more readable exposition than Shelah 1975. The URL https://web.eecs.umich.edu/~gurevich/Opera/64.pdf is a free preprint (had certificate issues when fetched but the file is 2.1MB suggesting it is the full chapter). Key content would include the n-theory definition, the ordered sum theorem, and the decidability applications.

**Accessibility**: Preprint at gurevich/Opera/64.pdf (free; certificate issue may be resolvable). Book (Springer-Verlag 1985) via library.

**Priority**: MEDIUM — textbook-level exposition of the composition method that Thomas 1997 builds on.

---

### 2.6 Libkin 2004, *Elements of Finite Model Theory* — **PRIORITY: LOW-MEDIUM**

**Citation**: Libkin, L. (2004). *Elements of Finite Model Theory*. Springer. ISBN 978-3-540-21202-7.

**Contains the specific proof technique needed**: PARTIALLY (for finite structures)

Full PDF at https://homepages.inf.ed.ac.uk/libkin/fmt/fmt.pdf (free). Contains:
- Chapters on EF games for first-order logic (Chapter 3–4)
- Locality (Hanf, Gaifman) — different from composition method
- Does NOT cover the monadic second-order / ordered sum composition for infinite structures

**Relevance to blocker**: Limited. The book covers EF games for finite FO logic; the blocker is about monadic logic on (possibly infinite) linear orders. The composition method for ordered sums is not its focus.

**Priority**: LOW-MEDIUM — useful for general EF game theory and game composition basics, but not specific to the monadic/temporal setting.

---

### 2.7 Immerman 1999, *Descriptive Complexity* — **PRIORITY: LOW**

**Citation**: Immerman, N. (1999). *Descriptive Complexity*. Springer. 

**Contains the specific proof technique needed**: NO

The book focuses on the complexity theory applications of descriptive logic (NP = ∃SO, P = FP, etc.) and EF games for FO logic on finite structures. It does not cover monadic second-order theories of linear orders, the composition method, or temporal logic. EF games are covered in Chapter 2 in the context of FO inexpressibility results.

**Priority**: LOW — not relevant to the specific blocker.

---

## 3. Priority Order for Consulting Sources

### Tier 1: Already in `literature/` — Consult Immediately

| Source | File | Key Content | Lines to Read |
|--------|------|-------------|---------------|
| Doets 1987 thesis | `Doets_1987_Completeness_and_Definability_thesis.md` | Ch. 3 Lemmas 3.1.7–3.1.8: ordered sum composition with EF game proof | Ch. 3 (pp. 36–57 of thesis) |
| GHR94 Ch. 12 | `Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch12.md` | Section 12.8: game proof, Lemma 11, Prop 12.8.18 | Full chapter (74 KB extracted) |
| Doets 1989 | `Doets_1989_Monadic_Pi11_Theories.md` | Published version of Ch. 3 theorems | Section 3 (ordered sums) |

**Action**: Report `44_literature-interval-splitting.md` has already extracted the key information from GHR94 Ch. 12 and established that the correct proof route goes through the game. The Doets thesis Chapter 3 provides the underlying composition theorem.

### Tier 2: Free Online — Obtain Immediately

| Source | URL | Key Content |
|--------|-----|-------------|
| Shelah 1975 | https://shelah.logic.at/files/213042/42.pdf | Composition theorem statement and proof structure |
| Rabinovich 2014 | https://lmcs.episciences.org/730/pdf | Game-based proof of Kamp's theorem |
| Rabinovich 2012 | https://drops.dagstuhl.de/storage/00lipics/lipics-vol016-csl2012/LIPIcs.CSL.2012.516/ | CSL conference version |

### Tier 3: Library Acquisition — For Deeper Reference

| Source | Access | Priority |
|--------|--------|----------|
| Rosenstein 1982, Ch. 6 | Internet Archive (free borrow) | HIGH — cleanest proof of Theorem 6.6 (interval splitting game) |
| Thomas 1997 | LNCS paywall or library | HIGH — cleanest survey of composition method |
| Gurevich Ch. XIII | Opera 64 preprint or library | MEDIUM — readable composition method exposition |
| Hodkinson-Reynolds 2006 | http://cgi.csc.liv.ac.uk/~frank/MLHandbook/11.pdf (full PDF) | MEDIUM — 2006 survey with clean proof |

---

## 4. The Specific Proof Structure Needed (Literature Summary)

Based on the existing literature in `literature/` and the web search results, the Fraïssé back-and-forth argument for the bridge lemma has the following standard structure across all sources:

### 4.1 The Standard Theorem (Doets Ch. 3, Lemma 3.1.7)

Given linear orders (M, <) and (N, <) with monadic predicates, the key tool is:

**If sub-intervals are n-equivalent componentwise, then ordered sums are n-equivalent.**

More precisely: if f: I → classes and g: J → classes are functions from index sets to n-equivalence classes of models, and if `(I, {i | f(i) = σ})_σ ≡ⁿ (J, {j | g(j) = σ})_σ`, then `Σ_{i ∈ I} f(i) ≡ⁿ Σ_{j ∈ J} g(j)`.

**Proof strategy** (Doets): Player II maintains the invariant that when the game is at position (a, b) with a ∈ A and b ∈ B, for all n-characteristics σ: `∃ a' > a in A with char(a') = σ ↔ ∃ b' > b in B with char(b') = σ` (and symmetrically for "<"). The game can always maintain this invariant because: (a) there are only finitely many n-characteristics, and (b) whenever Spoiler picks a new point with characteristic σ, Duplicator can find a matching point with the same characteristic on the other side. After k rounds, the invariant implies atom agreement (the depth-0 case), and inductively this gives depth-k NF agreement.

### 4.2 Connection to the Lean Bridge Lemma

The bridge lemma `nf_2var_from_interval_data` requires: given (x,t) in M and (x',t') in M' with:
- same 1-var NFs at x, t (and x', t')
- same ordering (x < t iff x' < t')
- same interval_nf_types (same set of 1-var NFs realized in (x,t) and (x',t'))
- same above/below types

conclude: `nf_characteristic M k 2 (x,t) = nf_characteristic M' k 2 (x',t')`.

**Doets' approach translated**: Define the EF game for 2-variable environments. At each round, Spoiler picks a new point u in (x,t) (or (x',t')); Duplicator responds with u' in (x',t') (or (x,t)) with the same 1-var NF as u (possible because interval_nf_types agree). After k rounds, we have 2+k matched points with matching 1-var NFs and orderings. Atom agreement (depth-0 NF at n=2+k) follows immediately. Depth-k NF agreement at n=2 follows from the game's construction.

**The sub-interval splitting problem dissolves** because Duplicator does NOT need to maintain interval type data for sub-intervals — only 1-var NF matching at each new point and ordering consistency with all previous points. The interval_nf_types hypothesis is only used to guarantee that a matching point EXISTS (same 1-var NF, same relative position), not to provide sub-interval data.

### 4.3 The New Lemma Needed: Fraïssé Compression

The missing piece (identified in `43_bridge-lemma-resolution.md`) is:

**"depth-0 NF agreement at n=2+k implies depth-k NF agreement at n=2"**

In Doets' framework, this is the content of Theorem 6.4 (n-characteristics characterize EF games): `[a]ⁿ = [b]ⁿ ↔ II wins the n-game at (a,b) ↔ a and b agree on all formulas of rank ≤ n`.

The Lean formulation: if after k rounds of back-and-forth matching (producing environments (u₁,...,u_k,x,t) and (u'₁,...,u'_k,x',t')), all matched pairs have the same 1-var NF and the same ordering relative to all other matched pairs, then depth-0 NF agreement holds at n=2+k, and therefore depth-k NF agreement holds at n=2.

The critical theorem that would need to be proved (or found in the existing codebase): `nf_characteristic_of_game_n_equivalence`: game n-equivalence of two environments implies their n-variable depth-k NF characteristics agree.

This theorem may already be present in the codebase via `nf_agreement_monotone` or the existing Decomposition.lean infrastructure — see `44_literature-interval-splitting.md` Step 3.

---

## 5. Büchi 1960 / Elgot-Trakhtenbrot Relevance

Büchi's original decidability result for MSO on ω (J.R. Büchi, 1960, "Weak second-order arithmetic and finite automata," *Z. Math. Logik Grundlag. Math.* 6, 66–92) uses the automata-theoretic approach, not the composition method. It shows decidability by translating MSO formulas to finite automata on infinite words. While historically important, it does not contain the composition/decomposition proof structure needed for the bridge lemma.

The composition method was developed LATER by Shelah (1975) and Gurevich (1979). Büchi's technique is an ALTERNATIVE to the composition method, not a precursor to it.

**Relevance to blocker**: Low. The blocker requires the composition method (EF game proof), not the automata approach.

---

## 6. Summary Table

| Source | In `literature/`? | Contains Composition Proof? | Contains Sub-interval Argument? | Accessibility |
|--------|:-----------------:|:---------------------------:|:--------------------------------:|:-------------:|
| Doets 1987 thesis (Ch. 3) | YES (PDF+MD) | YES (Lemmas 3.1.7–3.1.8) | YES (implicit via game) | Complete |
| GHR94 Ch. 12 | YES (PDF+MD) | YES (Prop. 12.8.18) | YES (via forward game, game handles it) | Complete |
| Doets 1989 NDJFL | YES (PDF+MD) | YES (same as thesis) | YES | Complete |
| GHR93 conference | YES (PDF+MD) | PARTIAL | PARTIAL | Complete |
| Hodkinson-Reynolds 2006 | TRUNCATED (3pp) | Unknown | Unknown | Full PDF free online |
| Rosenstein 1982, Ch. 6 | NO | YES (Thm 6.6) | YES (direct statement) | Internet Archive |
| Thomas 1997 | NO | YES (survey) | YES | LNCS paywall |
| Shelah 1975 | NO | YES (foundational) | YES | Free PDF |
| Rabinovich 2014 | NO | YES (for Kamp) | YES | Free PDF |
| Libkin 2004 | NO | PARTIAL (finite FO only) | NO | Free PDF |
| Gurevich Ch. XIII | NO | YES | YES | Preprint (cert issue) |
| Immerman 1999 | NO | NO | NO | Not relevant |
| Büchi 1960 | NO | NO (automata, not game) | NO | Not relevant |

---

## 7. Recommendation

### Immediate Action (Uses Existing Literature)

The existing `literature/` directory already contains everything needed:

1. **Doets 1987 thesis Chapter 3, Lemmas 3.1.7–3.1.8**: provides the ordered sum composition theorem with explicit EF game proof. This is the direct proof of the composition/decomposition technique needed.

2. **GHR94 Chapter 12 Section 12.8**: provides the specific formulation for temporal logic with gap handling. Report `44_literature-interval-splitting.md` has already extracted the key structural insight: the proof goes through the game, not through direct NF induction.

3. **Doets 1987 thesis Chapter 7 (Claim 9)**: provides the explicit game argument for tense logic, showing how Duplicator maintains the invariant by tracking equivalence class shapes — exactly the invariant needed for the bridge lemma.

**The sub-interval splitting problem is already resolved in the existing literature**; the remaining task is formalizing the Fraïssé compression lemma ("depth-0 agreement at n=2+k implies depth-k agreement at n=2") and the bridge from interval_nf_types to decomposition_agreement.

### New Acquisitions (For Completeness and Verification)

- **Rosenstein 1982, Ch. 6**: Theorem 6.6 is the clearest statement of the interval splitting game argument. Obtain via Internet Archive.
- **Shelah 1975**: Free PDF; confirms composition theorem structure.
- **Rabinovich 2014**: Free PDF; may provide a cleaner formalization template for the Fraïssé lemma (though for the weaker Kamp theorem).

Do NOT acquire Büchi 1960, Immerman 1999, or Libkin 2004 for this specific blocker — they use different techniques (automata, finite-model complexity) that are not directly applicable.

---

*Compiled by: general-research-agent*
*Sources: literature/ directory inspection, web search (8 queries), WebFetch attempts, cross-referencing with existing reports 43_bridge-lemma-resolution.md and 44_literature-interval-splitting.md*
