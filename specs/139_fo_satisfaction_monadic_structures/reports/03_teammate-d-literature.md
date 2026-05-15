# Literature Gap Analysis: Task 139

**Task**: FO satisfaction for monadic structures — close k-equivalence sorry chain
**Date**: 2026-05-14
**Scope**: Identify gaps in `literature/` relevant to: Doets Lemma 1.1 (finiteness of depth-bounded formulas), EF-game formalization for `sum_preservation`, Hintikka/normal-form construction, and Lean 4 formalizations of FO logic

---

## Key Findings

### 1. Doets 1987 Thesis Is Already Present and Covers the Core Proof

The thesis (`Doets_1987_Completeness_and_Definability_thesis.md`) is present and contains the four chapters that matter most for Task 139:

- **Chapter 1 (Fraïssé-Ehrenfeucht Theory)**: Contains Definition 1.6.1 (n-characteristics / Hintikka formulas), Theorem 1.6.3 (equivalence of n-equivalence, truth of n-characteristics, and game winning), Lemma 1.7.1 (finiteness: only finitely many n-characteristics at each depth for finite languages). This is the direct source for `ktype_finite`.

- **Chapter 3 (Monadic Pi^1_1 Theories)**: Contains Lemma 1.1 (= Doets 1989 Lemma 1.1), Lemmas 1.3-1.5 (ordered sums and condensation arguments), Section 3.3 (complete orderings, reals, well-orderings). Lemma 1.4 (ordered sums preserve n-equivalence) is the direct source for `sum_preservation`.

- **Chapter 6 (Game Theory for Intensional Logics)**: Contains the modal analogue of n-characteristics — an exact-parallel to the monadic case needed in Task 139. The restricted EF game (Definition 6.2), n-characteristics for modal logic (Section 6.3), and the construction of exact-universal Kripke models (Theorems 6.6, 6.7) provide a worked-out Lean-approachable analogue of the linear-order case.

- **Chapter 7 (Completeness for Z-time)**: Contains Claim 9 (the Ehrenfeucht game used for truth-transfer in the ordered sum), which is the core of `doets_lemma_1_4`.

**Assessment**: The existing Doets thesis markdown is thorough and covers all the key proof steps. No additional Doets content is missing.

### 2. Doets 1989 Is Present and Covers the Published Version

`Doets_1989_Monadic_Pi11_Theories.md` is present as a full OCR of the paper. It contains:
- Lemma 1.1 (finitely many depth-≤n formulas up to equivalence) — the `ktype_finite` source
- Lemma 1.4/1.5 (ordered sums preserve n-equivalence) — the `sum_preservation` source
- Proof of the condensation argument for well-orderings (Section 4.4) — the model-replacement technique used in `chronicle_is_good`

**Assessment**: No gap here. The paper is present and well-extracted.

### 3. Reynolds 1992 (Already Present) Contains the Exact Doets Theorem Invocation

`Reynolds_1992_Axiomatization_Until_Since_without_IRR.md` (the full paper) is present. Section 8 ("Doets' Theorem") states the theorem as used in Reynolds' completeness proof, including the two conditions D1 and D2. This paper is the primary reference for how Doets' result connects to the temporal logic completeness proof. It is already in the literature folder.

### 4. Reynolds 1994 (Already Present) Contains the Discrete Case

`Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md` (the full paper) is present. Theorems 9 and 15 are the discrete analogues of the real-time Doets theorem. Section 6 defines the monadic FO language. Section 8 applies the Doets-style condensation. This is directly mapped to Task 139's proof targets (`chronicle_is_good`, `contemp_equiv_is_equiv`, `no_gaps_discrete`).

**Assessment**: No gap here.

---

## Literature Gaps

### Gap 1: No Reference for the Normal Form / DNF Construction (Doets 1.7.1 Formalization Path)

**What is missing**: The existing literature summaries cover *what* Doets 1.7.1 says (finitely many n-characteristics) but do not provide a step-by-step constructive proof of the **normal form / disjunctive normal form reduction** that is needed for the Lean formalization. Specifically:

- The induction step: every depth-(k+1) formula is equivalent to a Boolean combination of depth-k formulae of the form `∀xφ` and `∃xφ` for φ of depth k — is stated but not elaborated in the existing summaries.
- The claim that the enumeration is constructive (i.e., can be represented as a computable `Finset`) requires an explicit construction, not just a counting argument.

**Where to look**: Rosenstein's *Linear Orderings* (Academic Press, 1982) Chapter 6 gives a self-contained treatment of back-and-forth systems and Hintikka sentences for linear orders. This book is cited by Doets but not present in the literature folder. For the Lean formalization, Rosenstein Chapter 6 (specifically Theorem 6.22 and its proof) gives the clearest account of the normal form construction for linear orders with unary predicates.

**Priority**: MEDIUM. The Doets thesis Chapter 1 Sections 1.5-1.7 already contain enough to formalize `ktype_finite`. Rosenstein would help but is not strictly required.

### Gap 2: No Lean 4 Formalization of First-Order Logic Satisfaction Available in Literature

**What is missing**: The project has a custom `MonadicFormula` / `eval` type and Mathlib has `FirstOrder.Language.BoundedFormula` with `Realize`. The literature folder has no reference documenting the Mathlib first-order logic framework (`Mathlib.ModelTheory.Syntax`, `Mathlib.ModelTheory.Semantics`).

Critically: `FirstOrder.Language.BoundedFormula` in Mathlib (verified by local search) is structurally identical to `MonadicFormula sig n`:
- `BoundedFormula L α n` — bounded formula with `n` free variables (De Bruijn)
- `BoundedFormula.Realize` — Tarski satisfaction with `(α → M) → (Fin n → M) → Prop`
- The quantifier depth / complexity hierarchy is already in Mathlib via `FirstOrder.Language.BoundedFormula`

**Impact**: The team is reinventing infrastructure that already exists in Mathlib. If `MonadicFormula sig n` were replaced by or shown equivalent to `FirstOrder.Language.BoundedFormula (L_sig) Empty n` for a suitable language `L_sig`, then:
- The `eval` definition would follow from Mathlib's `Realize`
- Some finiteness results may already be in Mathlib (searched: `FirstOrder.Language.BoundedFormula Fintype` — no direct hits, but infrastructure exists)

**Priority**: HIGH for awareness; MEDIUM for action. The custom `MonadicFormula` approach is already implemented and correct; the Mathlib analogy is worth documenting but switching would be a large refactor.

**Recommended addition**: Add a short literature note documenting the Mathlib `ModelTheory` API (Mathlib.ModelTheory.Syntax, Semantics, Complexity modules) and its relation to the custom `MonadicFormula` definition. This would help future implementers know when to reach for Mathlib vs. project-local definitions.

### Gap 3: EF-Game Formalization — No Lean Reference Available

**What is missing**: `sum_preservation` requires the EF-game argument: if components are k-equivalent, their ordered sums are k-equivalent. This is Doets 1989 Lemma 1.4, proved via a direct "winning strategy" construction (Doets: "It is straightforward to describe a winning strategy for the second player in the Ehrenfeucht n-game between these sums...").

**Existing literature**: Mathlib has `FirstOrder.Language.PartialEquiv` (partial isomorphisms) and `Mathlib.ModelTheory.Fraisse` (Fraïssé limits, `IsFraisse`, `IsFraisseLimit`). However, Mathlib does **not** contain:
- Explicit EF-game winning strategies as inductive types
- `n`-round EF games over ordered structures
- The specific sum-preservation lemma for n-equivalence

**What would help**: 
1. Hirsch & Hodkinson (1997) "Step by step — building representations in algebraic logic" (JSL 62(1)) — already in the literature README as LOW priority. It covers game-theoretic model construction for cylindric algebras. While the context differs, the game strategy formalization technique is transferable. But this paper is complex and not directly on-point.
2. A direct formalization reference: the closest relevant work is the Mathlib Fraïssé module, which proves existence of Fraïssé limits using partial isomorphisms. The proof technique is related but the exact sum-preservation lemma is not there.

**Priority**: HIGH for `sum_preservation`. The EF-game argument is the core missing piece. The existing literature (Doets 1989 Lemma 1.4 proof sketch) provides the mathematical content, but no Lean formalization guide exists.

**Assessment**: This is a genuine formalization gap. The most pragmatic path is to prove `sum_preservation` directly by a structural induction on the EF-game depth, following Doets 1989's proof sketch word-by-word, without needing a general EF-game framework.

### Gap 4: Hintikka Formula Construction for Monadic FO (vs. Modal Logic Analogue)

**What is missing**: The existing literature has a clear account of n-characteristics for modal logic (Doets 1987 Chapter 6) and for general first-order logic (Doets 1987 Chapter 1), but not a self-contained treatment specific to **monadic FO over linear orders with unary predicates**. The monadic case is simpler (one sort, one binary relation, finitary predicates) but the simplification is scattered across the sources rather than concentrated.

The formula in Doets 1987 Definition 1.6.1 (the `[[a]]^n` construction for general FO) needs to be specialized to the monadic case. For the project's needs, the relevant specialization is:

- At depth 0 with 1 free variable: the n-characteristic is a conjunction of literals `P_i(x_0)` or `¬P_i(x_0)` for each predicate `P_i`
- At depth 1 with 1 free variable: `[[a]]^1 = [[a]]^0 ∧ ∀y(x_0 < y → [[y]]^0) ∧ ∀y(y < x_0 → [[y]]^0) ∧ ∃y(x_0 < y ∧ [[y]]^0) ∧ ∃y(y < x_0 ∧ [[y]]^0)`

This specialization does not appear explicitly in any of the existing literature summaries.

**Priority**: MEDIUM. This is required for the "Hintikka approach" to `k_type_of` (Alternative 2 in 01_teammate-d-findings.md). If the Tarski semantics approach (Strategy 1) is used instead, this gap is less critical.

---

## Recommended Additions to `literature/`

### Priority 1 (HIGH): Mathlib ModelTheory Documentation Note

**Add**: A short reference note `Mathlib_ModelTheory_BoundedFormula.md` documenting:
- `FirstOrder.Language.BoundedFormula L α n` — the Mathlib analogue of `MonadicFormula sig n`
- `BoundedFormula.Realize` — the Tarski satisfaction analogue of `eval`
- How to construct a `FirstOrder.Language` for a monadic signature (finite functions = empty, finite relations = `sig.preds`)
- Cross-reference to `Mathlib.ModelTheory.Complexity` for quantifier rank / depth
- Relevant Lean source: `Mathlib/ModelTheory/Syntax.lean`, `Mathlib/ModelTheory/Semantics.lean`

**Rationale**: Without this documentation, future agents will continue to build parallel infrastructure. The Mathlib framework may already prove or make trivial some of the lemmas needed for Task 139.

**Effort**: Low (documentation only, no new math).

### Priority 2 (HIGH): Rosenstein 1982 Chapter 6 (Linear Orderings, Back-and-Forth)

**Citation**: Rosenstein, J. G. (1982). *Linear Orderings*. Academic Press, New York.

**Relevant section**: Chapter 6 ("n-equivalence and EF games for linear orders"), specifically:
- Theorem 6.5 (n-characteristics for linear orders)
- Theorem 6.22 (`ω ≡^∞ (OR, <)` — Ehrenfeucht's theorem, proved in `Doets_1989_Monadic_Pi11_Theories.md` Appendix as Corollary)
- Lemma 6.5 (lexicographic sums preserve n-equivalence — the source for Doets Lemma 1.4)

**Why needed**: This is the primary textbook source for the EF-game theory needed by `sum_preservation`. The monadic case with unary predicates is Rosenstein's Chapter 7 ("Colored linear orderings"). This is the constructive proof guide for formalizing `doets_lemma_1_4`.

**Access**: Academic Press, 1982. ISBN 0-12-597680-1. Available used (~$30-50). Also: full text available via library systems (Z-Library catalog number exists but institutional access required).

**Priority**: HIGH for `sum_preservation` formalization.

### Priority 3 (MEDIUM): Burgess & Gurevich 1985 (Decision Problem for Linear Temporal Logic)

**Citation**: Burgess, J. P. & Gurevich, Y. (1985). "The decision problem for linear temporal logic." *Notre Dame Journal of Formal Logic* 26(2), 115–128.

**Relevant content**: This paper (referenced in Doets 1989 footnote) contains:
- Property I (Doets 4.7 in Doets 1989) — first identified here by Gurevich
- The proof that the monadic FO theory of (ℝ,<) is decidable, using condensation arguments that parallel the completeness proof
- Doets cites this as overlap with his own work; understanding the original is useful for clarity on Property I (needed for the dense case, not the discrete case)

**Priority**: MEDIUM. Only needed if dense completeness (over ℝ or ℚ) is pursued. For Task 139 (discrete/integer case), this is not blocking.

**Access**: Notre Dame Journal of Formal Logic. DOI: 10.1305/ndjfl/1093869802. Available via Project Euclid.

### Priority 4 (MEDIUM): Existing Literature — Sections Not Yet in Summaries

**Reynolds 1992 Sections 5-8**: The existing summary for `Reynolds_1992_Axiomatization_Until_Since_without_IRR.md` is a FULL OCR conversion of the paper (all 10 sections are present). However, Section 8 ("Doets' Theorem") gives the clearest statement of the two conditions (D1 = no gaps, D2 = dense singletons) and the proof of `chronicle_is_good`. This section should be explicitly cross-referenced in the literature README under "For Task 139 implementers."

**Doets 1987 Chapter 1 Sections 1.6-1.7**: These sections (n-characteristics and the Finite Case lemma) are the direct source for `ktype_finite`. They are present in the thesis markdown but should be flagged explicitly in the literature README as "primary source for NEquivalence.lean formalization."

**Effort**: Low (README update only, no new files).

---

## Online Resources Found

### Lean 4 / Mathlib Formalizations of FO Logic

1. **Mathlib `ModelTheory` module** (actively developed, part of Mathlib4):
   - `Mathlib.ModelTheory.Syntax` — `Language`, `Term`, `BoundedFormula` (De Bruijn, identical structure to project's `MonadicFormula`)
   - `Mathlib.ModelTheory.Semantics` — `Structure`, `Realize`, `Formula.Realize`
   - `Mathlib.ModelTheory.Fraisse` — Partial isomorphisms, Fraïssé limits, `IsFraisse`
   - `Mathlib.ModelTheory.Complexity` — Formula complexity, `IsPrenex`, `IsQF`
   - Source: `https://leanprover-community.github.io/mathlib4_docs/Mathlib/ModelTheory/`
   - **Status**: Confirmed present via `lean_leansearch` (found `FirstOrder.Language.BoundedFormula`, `PartialEquiv`, `IsFraisse`)
   - **Gap**: No EF-game winning strategy formalization; no sum-preservation lemma; no `Fintype` instance for bounded-depth formulas

2. **FormalizedFormalLogic/Foundation** (GitHub):
   - Lean 4 modal logic project with S5 completeness via Henkin models
   - Already listed in README.md under "Machine-Checked Formalizations"
   - **Relevant for Task 139**: Their treatment of formula depth and Fintype instances may provide implementation patterns
   - **Status**: Open source, actively developed

3. **Obendrauf 2024** (already in literature):
   - ~6,000 lines Lean 4 coalition logic completeness
   - Does NOT contain FO satisfaction or monadic language formalization
   - Relevant for canonical model patterns but not for Task 139's monadic FO layer

4. **No Lean 4 formalization of EF games found**:
   - Searched via `lean_leansearch` for "Ehrenfeucht-Fraisse game Lean 4" — no results
   - Mathlib's `ModelTheory.Fraisse` covers Fraïssé limits but not the finite-round EF game
   - The closest is `FirstOrder.Language.PartialEquiv` (partial isomorphisms, back-and-forth)
   - **Conclusion**: No off-the-shelf Lean 4 EF-game library exists; `sum_preservation` requires original formalization

5. **Zhan et al. 2025 "A Unifying Framework for Linear Temporal Logics in Lean"** (arXiv 2507.01780):
   - Listed in README as MEDIUM priority
   - Free on arXiv
   - Trace-based, not axiomatic — treats LTL semantically via `ω`-words
   - **Not directly relevant** to Task 139's monadic FO layer; more relevant to later tasks involving semantic completeness
   - Worth obtaining but not blocking

### Papers Cited in Doets/Reynolds That Could Help

1. **Karp, C. R. (1965)** "Finite-quantifier equivalence" in *The Theory of Models*, North-Holland.
   - The original source for the `I_α` back-and-forth system definition (Doets Chapter 1 Definition 1.2.1)
   - Not needed for formalization; the content is fully captured in Doets Chapter 1

2. **Scott, D. (1965)** "Logic with denumerably long formulas and finite strings of quantifiers" in *The Theory of Models*, North-Holland.
   - The original source for Scott sentences / Scott rank (Doets Chapter 1 Section 1.9)
   - The Scott-sentence construction is an analogue of the Hintikka formula construction
   - **Not needed** for Task 139; the `ktype_finite` formalization uses simpler depth-bounded characteristics, not full Scott sentences

3. **Fraïssé, R. (1955)** "Sur quelques classifications des relations..."
   - Historical origin, fully superseded by textbook treatments
   - Not needed

---

## Assessment of Existing Literature PDFs

Several PDFs in `literature/` have content beyond what the markdown summaries cover. Specifically:

- **`Hodkinson_Reynolds_2006_Temporal_Logic_Handbook_Ch11.md`**: The markdown is TRUNCATED — it contains only the Table of Contents + Introduction (Sections 1 only, pages 656-657). Pages 658-712 (Sections 2-6) are NOT included. Section 4 ("Expressive power") covers Kamp's theorem and separation; Section 5 ("Temporal reasoning") Section 5.8 covers filtration and FMP. Section 5.1 covers Hilbert systems. These sections (especially 4.2-4.4 on expressive completeness) are relevant to Task 139's `table_correctness` step (Task 140). **However**: acquiring the full chapter requires Elsevier subscription or ILL — this is a known limitation noted in the README.

- **All other PDFs**: The Doets, Reynolds, and Burgess PDFs appear to have been fully converted to markdown (OCR with corrections). No additional hidden content.

---

## Confidence Level

**HIGH** on the following conclusions:
- Existing literature (`Doets_1987`, `Doets_1989`, `Reynolds_1992`, `Reynolds_1994`) already covers all the mathematical content needed for Task 139
- No additional papers are *required* to close the `ktype_finite` and `k_equiv_monotone` sorries
- `sum_preservation` (Doets Lemma 1.4) has no existing Lean 4 formalization to draw on; it requires original work following Doets 1989's proof sketch
- The Mathlib `ModelTheory` module is the most significant undocumented resource that could simplify implementation

**MEDIUM** on the following:
- Whether Rosenstein 1982 Chapter 6/7 would provide a meaningfully clearer guide to formalizing `sum_preservation` than Doets 1989 directly
- Whether the Hintikka/normal-form approach to `ktype_finite` is worth pursuing over the direct Tarski semantics approach

**Recommendation**: No new papers are required before implementation of Task 139 can proceed. The two recommended additions (Mathlib ModelTheory note and Rosenstein reference) would improve clarity but are not blocking. The primary gap is implementation guidance (formalization strategy), not mathematical content.
