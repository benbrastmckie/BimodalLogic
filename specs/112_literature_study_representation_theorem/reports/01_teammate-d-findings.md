# Research Findings: Task #112 — Teammate D (Strategic Horizons)

**Task**: 112 - Systematic literature study for the BX representation theorem
**Role**: Strategic Horizons — publication readiness, cross-task applicability, methodological lessons, missing literature, big-picture path assessment
**Date**: 2026-04-24
**Sources Read**:
- `literature/Burgess_1982b_Axioms_for_tense_logic_II_Time_periods.md`
- `literature/Venema_1993_Since_and_Until.md`
- `literature/Obendrauf_2024_Lean_Formalization_Coalition_Logic.md`
- `literature/Burgess_1984_Basic_Tense_Logic.md`
- `literature/Thomason_1984_Combinations_of_Tense_and_Modality.md`
- `specs/107_chain_design_diagnostics_for_representation_theorem/reports/15_team-research.md`
- `specs/107_chain_design_diagnostics_for_representation_theorem/plans/15_implementation-plan.md`
- `specs/ROADMAP.md`

---

## 1. Publication-Critical Citations and Claims

### Which sources enable which publishable claims

**Burgess (1982b) — "Axioms for Tense Logic II: Time Periods"**
This paper is tangentially relevant to BX formalization but is NOT a primary citation for the representation theorem. Its contribution is the period-based tense logic completeness result. The period-based semantics (Y, ⊆, <₁) is mathematically unrelated to the instant-based BX semantics in use. If the project ever extends to period-based semantics, this paper is essential; for the current scope, it provides only background on Burgess's methodology.

**Claim this enables**: "Burgess (1982b) extended his axiomatization technique to period-based structures, demonstrating the robustness of the chronicle construction approach across different temporal ontologies." Cite in related work section only.

**Venema (1993) — "Completeness via Completeness: Since and Until"**
This is a HIGH-PRIORITY citation. Venema's main contribution is showing that axiomatic completeness for S/U logics can be derived from expressive completeness, avoiding the Gabbay irreflexivity rule (IR). This is directly relevant because:
- Venema's **orthodox axiom systems** (B, BW, BN) use only MP, TG, and SUB — the same "orthodox" proof rules that BX uses.
- His proof strategy (obtain a linear model satisfying BW, then use Doets's theorem to replace it with a well-ordered one) illustrates the model-replacement technique that could apply to the BX sparse-X approach.
- The Stavi connectives (S', U') and expressive completeness of S'U' over all linear orders (Theorem 3.1) have direct implications for BX completeness: Venema shows that for the well-ordering and ω cases, the gap between "has a linear model" and "has the right kind of linear model" can be closed without strengthening the axiom system. This is exactly the structural challenge facing Path A (sparse X to desired frame class).

**Claim this enables**: "Following Venema (1993), we establish completeness over all strict linear orders without appealing to the irreflexivity rule, maintaining an orthodox derivation system (MP, TG, SUB)." This claim is high-value for publication because the orthodox/non-orthodox distinction is philosophically significant in the field.

**Obendrauf (2024) — "Lean Formalization of Completeness Proof for Coalition Logic with Common Knowledge"**
This is the most methodologically relevant source for HOW to structure the Lean formalization. Key insights:

1. **Typeclass hierarchy for logic extensions**: Obendrauf defines `Pformula`, `CLformula`, `Kformula`, `Cformula` typeclasses so that one canonical model construction serves CL, CLK, and CLC. This mirrors what BX needs: a parametric BFMCS family that works across different domain types. The existing `[AddCommGroup D]` parametricity in the BX codebase follows the same pattern Obendrauf uses.

2. **Closure definition subtlety**: Obendrauf discovered that changing the subformula closure requirement (all subformulas of `cl(φ)` members, not just subformulas of `φ`) was necessary for the truth lemma induction. This type of closure refinement under pressure from Lean's type system is exactly the situation facing BX in the guard convention mismatch (Phase 2 of the current plan).

3. **Set/Finset/List triplication**: Obendrauf reports that dealing with three different finite-set data types added "a lot of work" but each individual step was simple with Mathlib. The current BX formalization will face the same issue when constructing limit_g and proving C3 preservation — plan accordingly.

4. **`sorry` as paper omission, not incompleteness**: Obendrauf uses `sorry` in paper excerpts to mark omitted proofs, with all proofs complete in the repository. This is a useful citation to justify the current BX approach of using `sorry` as a placeholder during phase-by-phase development.

**Claim this enables**: "Our formalization follows the typeclass-based approach of Obendrauf et al. (2024), enabling reuse of canonical model infrastructure across related completeness theorems." Also: "The experience of Obendrauf et al. (2024) with Lean 4 formalization of completeness proofs confirms that finite-set arithmetic adds significant but tractable overhead."

**Burgess (1984) — "Basic Tense Logic" (Handbook of Philosophical Logic chapter)**
This is a survey chapter rather than a technical paper. Its value is different from the 1982 papers:
- Provides the authoritative statement of the instant-based completeness framework and its relation to period-based tense logic.
- The section on **Time and Modality** (§6.2) directly anticipates the BX bimodal combination: "The relations between tense and mood or modality is properly the topic of Richmond H. Thomason's chapter in this volume (II.3)." This provides scholarly framing for why BX combines tense and modality.
- The table of **Diodorean/Aristotelian modal fragments** (§6.2) shows that on **total orders**, the Diodorean fragment is S4.3 and the Aristotelian fragment is **S5**. This is directly relevant: BX uses S5 modality, and Burgess (1984) confirms that S5 is the "right" modal fragment for linear time. This is a strong citeable claim.
- The chronicle construction technique that forms the basis of the BX completeness approach is described informally in §5 on period-based tense logic, where Burgess discusses the interval structure I(X,R).

**Claim this enables**: "Burgess (1984) establishes that S5 is the Aristotelian modal fragment of linear tense logic, providing theoretical grounding for the BX combination of S5 with linear tense." This is a foundational citation for justifying the modal component of BX.

**Thomason (1984) — "Combinations of Tense and Modality" (Handbook chapter)**
This is a pivotal source for understanding the DESIGN SPACE that BX occupies. Key contributions:
- The **T×W framework** (Definition 6) and **Kamp frames** provide the mathematical context for combining tense and modality. BX is closest to a T×W system with the modality being S5.
- Thomason explicitly raises the T×W axiomatization problem: "As far as I know the problem of finding a reasonable axiomatization for T×W validity is open. I would expect the techniques discussed below, in connection with Kamp validity, to yield such an axiomatization." — This positions BX's completeness theorem as answering a long-standing open problem in the field.
- **Kamp frames** (Definition 9) with the one-way completion property (Figure 2) are structurally very similar to BX chronicle construction: inserting witness points between existing points. The diagram-completion property (condition 5 in Definition 10) is essentially what C4/C5 counterexample elimination achieves.
- The incompleteness of the naive T×W axioms (Kamp's formula (17), which requires the interpolation property of Figure 1) shows that naive bimodal combinations are incomplete and that additional structural axioms are needed. This directly justifies BX's complex axiom set (especially BX4-BX12).
- Thomason's neutral frames (Definition 10) and their completeness for the basic T×W axioms (AK0-AK13 + RK0-RK3) gives a direct precursor to the chronicle-based completeness strategy: neutral frames are exactly the kind of "locally Henkin" models that the chronicle constructs.

**Claim this enables**: "Thomason (1984) establishes the incompleteness of naive tense-modal combinations, motivating the additional axioms BX4-BX12 in our system. Our completeness proof via chronicle construction generalizes Thomason's neutral frame approach to the full S5+linear-tense bimodal setting."

---

## 2. Beyond Task 107 — Cross-Task Applicability

### Task 68: Dense Completeness (1 sorry in `dense_completeness_fc`)

**High applicability.** Venema (1993) provides the key missing ingredient for task 68. The challenge is:

- `dense_completeness_fc` cannot use the Int-based construction (Int is not dense).
- The Rat-based approach is the only known path, but the Rat construction has the GGp→Gp problem (dense orders validate this non-theorem).
- Venema's model-replacement technique: build a BW-consistent formula's model over any linear order, then use Doets's theorem (Theorem 3.8) to replace it with a well-ordered equivalent of the same first-order theory depth. This gives the RIGHT kind of model from any consistent model.

For dense completeness, the analogous argument would be: if `φ` is consistent, build any BX-consistent model (the Int chain works), then use density-preserving filtration or bisimulation to produce a dense model. Venema's approach via expressive completeness (Kamp's theorem) may provide the technical machinery to transfer the BX completeness result over arbitrary linear orders to dense linear orders specifically.

**Recommendation**: Task 68 research should study Venema (1993) Sections 3-4 and specifically the proof of Theorem 4.2, asking whether the model-replacement technique (Theorem 3.8) can be adapted to replace arbitrary-linear-order models with dense-order models.

### Task 109: Close 23 BXCanonical Sorries (5 critical-path)

**Moderate applicability.** The 5 critical-path sorries in `RootScopedChain.lean` are blocked by the semantic completeness vs. syntactic chain gap. Obendrauf (2024) and Thomason (1984) together suggest a direction:

- Thomason's neutral frames achieve completeness by building models from maximal consistent sets with a "one-way completion" diagram property. This is semantically cleaner than the BX chain approach.
- Obendrauf's truth lemma induction for common knowledge (Lemma 5, Section 8.4) shows how to handle a reflexive/transitive modality (common knowledge ≈ reflexive-transitive closure of K) in a filtered canonical model. The BX Box modality (S5) is similarly a reflexive-transitive equivalence relation.

**Recommendation**: The BXCanonical sorry sites may be resolvable by shifting from chain-based to filtered-canonical-model reasoning, as Thomason's neutral frames suggest. However, the ROADMAP already documents this approach and its dead ends. The Thomason reference confirms that the chronicle approach (task 107) is the historically correct path.

### Chronicle Approach (Task 107) Directly

Venema (1993) Lemma 4.1 is particularly relevant: **every BW-model is definably well-ordered**. The proof uses the fact that BW models satisfy `W` (well-ordering axiom), so S'U' formulas are equivalent to SU formulas on BW models, which means all definable sets have a least element. The analog for BX chronicle construction: the chronicle's limit domain is discrete and well-ordered in the sense that C4/C5 counterexample elimination terminates. Venema's lemma provides a formal template for arguing that the limit chronicle is "effectively well-behaved" even when the ambient domain is dense.

---

## 3. Methodological Lessons for Lean Formalization

### From Obendrauf (2024): Six Concrete Lessons

**Lesson 1 — Typeclass hierarchy before proof**: Define the typeclass hierarchy (`Pformula`, `CLformula`, etc.) BEFORE writing proofs. In BX terms: the `[AddCommGroup D]` typeclass approach is correct and should NOT be removed (consistent with the task 107 plan recommendation).

**Lesson 2 — Closure refinement is a Lean-specific surprise**: Obendrauf had to change the subformula closure definition partway through the truth lemma proof. The BX C5 guard mismatch (Phase 2 of the plan) is the same kind of Lean-specific surprise. Budget extra time for it.

**Lesson 3 — Set/Finset/List triplication is unavoidable**: Any proof involving finite sets over an inductively defined type requires three separate lemmas (one per datatype). The `limit_g` construction and the C3 limit proof will require this pattern.

**Lesson 4 — The `noncomputable` keyword signals mathematical choices**: Obendrauf's `noncomputable def phi_X_finset` signals that the definition involves Classical.choice. The BX formalization uses `set_lindenbaum` which is similarly noncomputable. This is acceptable but signals that the resulting completeness theorem has `Classical.choice` as an axiom — confirmed acceptable per the `#print axioms` target in task 95.

**Lesson 5 — Inductive truth lemma structure should follow the proof, not the syntax**: Obendrauf notes that a "deeper embedding using Lean's native ∀ and ∃ quantifiers may have been more natural" than the paper's finite conjunction/disjunction approach. This suggests that the BX direct truth lemma (Phase 5 of plan) should use Lean's semantic quantifiers directly rather than trying to mirror the paper proof's set-based notation.

**Lesson 6 — 6,000 lines for completeness of a moderately complex modal logic**: CLC (coalition logic + common knowledge) took ~6,000 lines. BX is comparable in complexity (35 axioms, bimodal). Expect 5,000-8,000 lines for the full sorry-free completeness proof, not 1,000-2,000. This is a realistic scope expectation.

### From Thomason (1984): Methodological Design Principle

Thomason's central insight: "We shouldn't expect the theory of time + X to be obtained by mechanically combining the theory of time and the theory of X." This is exactly the situation with BX: naively combining S5 (Box) with linear tense (G, H, U, S) does not give a complete system. The BX axioms BX4 (`connect_future`), BX5 (`self_accum_until`), and the modal-temporal interaction axioms (`modal_future`, `temp_future`) are precisely the "non-mechanical" axioms that capture the genuine interaction.

**Methodological lesson**: The BX completeness proof MUST use these interaction axioms in essential ways. Any proof that would work equally well for naive S5+tense is suspect. In particular, `temp_future` (□φ → G(□φ)) and BX4 (φ → G(P(φ))) should appear explicitly in the chronicle construction's invariant preservation arguments.

---

## 4. Missing Literature Recommendations

Based on reading these five sources, the following additional sources appear highly relevant and should be obtained:

### High Priority (appear in multiple sources, directly relevant to BX)

**Burgess, J.P. (1982). "Axioms for Tense Logic I: 'Since' and 'Until'."** Notre Dame Journal of Formal Logic 23(4), 367-374.
— This is the primary Burgess source. Venema cites it as [B] and uses it as the foundation for his completeness results (Theorem 3.5). The ROADMAP cites it but we do not have a markdown file for it. This is the SINGLE MOST IMPORTANT missing source. It axiomatizes S/U logic over all linear orders.

**Kamp, J.A.W. (1968). "Tense Logic and the Theory of Linear Order."** Doctoral dissertation, UCLA.
— Venema cites it as [K] for expressive completeness of SU over complete linear orders (Kamp's theorem, Theorem 3.1). This is the foundational result that enables Venema's proof technique. The Kamp dissertation is notoriously hard to obtain, but a copy or secondary presentation (e.g., Gabbay's handbook entry) would be valuable.

**Doets, K. (1989). "Monadic Π¹₁-Theories of Π¹₁-Properties."** Notre Dame Journal of Formal Logic 30, 224-240.
— Venema cites it as [D] for Theorem 3.8 (definably well-ordered linear models have well-ordered n-equivalents). This is the key technical lemma enabling model replacement. For task 68 dense completeness, this may be the most important missing source.

**Gabbay, D.M. and I.M. Hodkinson (1990). "An axiomatization of the temporal logic with Until and Since over the real numbers."** Journal of Logic and Computation, 1, 229-259.
— Venema cites it as [GH] as the direct precursor to his paper. The GH axiomatization uses the irreflexivity rule (IR) which Venema deliberately avoids. Understanding the IR approach and why it is undesirable (and why Venema's approach is better) directly informs the BX axiom design choices.

### Moderate Priority (cited once, likely useful)

**Xu, M. (1988). "On some U, S-tense logics."** Journal of Philosophical Logic 17, 181-202.
— The ROADMAP cites Xu as the simplification of Burgess's axiomatization. Not in our literature directory. Essential for validating the BX axiom choices (especially which axioms were simplified from Burgess's original).

**Thomason, R.H. (1981). Multiple papers cited in Thomason (1984)**:
- Thomason (1981c): Contains the completeness proof for neutral frames. This would directly inform the chronicle construction.

**Gurevich, Y. and Shelah, S. (to appear as of 1982)**: Decidability of the theory of trees with second-order quantification over maximal chains. Thomason mentions this as proving Ockhamist validity is decidable. Directly relevant to task 68 dense completeness.

**Neeley, P. (2021). "A Formalization of Dynamic Epistemic Logic."** Master's thesis, Carnegie Mellon University.
— Obendrauf cites this as the primary design reference for the CLC Lean formalization. It contains detailed accounts of design decisions for modal logic completeness proofs in Lean 4.

---

## 5. The Big Picture — Strategic Path Assessment

### Current State

The project has:
- **Sorry-free**: Soundness (all semantics), decidability/FMP infrastructure, most of the canonical frame and truth lemma
- **11 sorry sites** in the chronicle pathway (task 107) in three layers: g-function trivial, guard convention mismatch, domain extension
- **5 critical-path sorry sites** in BXCanonical (task 109) blocked by semantic-vs-syntactic gap
- **14 irreflexive-consequence sorry sites** in BXCanonical from BX1 removal
- **1 sorry** in dense completeness (task 68)

### How the Five Sources Collectively Reshape the Path

**Burgess (1982b) and Burgess (1984)**: Confirm that the chronicle construction is the historically correct approach. The period-based semantics paper (1982b) is not directly applicable, but it demonstrates Burgess's characteristic technique: build a well-chosen canonical frame from maximal consistent sets, then transfer to the desired model class. The 1984 survey confirms that S5 + linear tense is the right framework and that the bimodal combination is non-trivial.

**Venema (1993)**: Provides the most strategically valuable new information. His two key results for the BX project:

1. **Orthodox completeness over well-orderings (Theorem 4.2)**: If BX can be proved complete over any linear order (Path A sparse-X), Venema's technique (model replacement via Doets's Theorem 3.8) may allow automatic transfer to completeness over well-orderings and specific frame classes. This could enable a modular proof structure: first prove completeness over "some" linear order (the chronicle's sparse X), then use Venema-style filtration to transfer to desired subclasses.

2. **Expressive completeness bridge**: The BX Until/Since operators S and U generate a language that is Kamp-complete over Dedekind-complete linear orders (by Kamp's theorem). This means BX is already as expressively powerful as possible over its intended semantics. Any consistent BX formula is satisfiable in some model; the task is only to build the RIGHT model. Venema's approach separates the "has any model" question from the "has the right kind of model" question. This separation is precisely what the chronicle construction achieves, and Venema provides theoretical backing for this strategy.

**Obendrauf (2024)**: Provides a proof of existence — a Lean 4 completeness proof of a comparable complexity modal logic (CLC) has been successfully completed, sorry-free, in approximately 6,000 lines. This has two implications:
1. **Feasibility confirmation**: The BX formalization is feasible. The main obstacles are mathematical (the three-layer infrastructure problem), not Lean-specific.
2. **Technical template**: The Set/Finset/List triplication, typeclass hierarchy, and truth lemma induction structure from Obendrauf are directly applicable. The BX formalization should adopt these patterns immediately.

**Thomason (1984)**: Provides the most important LONG-TERM strategic insight. The Kamp incompleteness result (formula (17)) and the neutral frame completeness proof together establish that:
1. Simple T×W combinations are incomplete — the chronicle construction's additional axioms (BX4-BX12) are mathematically necessary, not just technically convenient.
2. The chronicle's "local Henkin" structure (inserting midpoints to eliminate counterexamples) mirrors Thomason's neutral frame "one-way completion" property. The chronicle construction is, in a precise sense, the canonical model theory that Thomason's 1984 chapter called for but didn't explicitly construct.

### Confidence Assessment

| Claim | Confidence | Based on |
|-------|-----------|---------|
| Venema's model-replacement technique is applicable to BX task 68 dense completeness | HIGH | Direct structural parallel (same S/U logic, same expressive completeness theorem) |
| Obendrauf's typeclass/closure patterns are correct for BX formalization | HIGH | Direct technical match |
| BX chronicle construction is the historically correct path to completeness | HIGH | Both Burgess (1984) and Thomason (1984) confirm this strategy |
| Venema's orthodox system avoidance of IR is publishable advantage | HIGH | Explicit statement in Venema (1993) Introduction |
| Burgess (1982) — the missing source — will confirm the BX axiom choices | HIGH | ROADMAP already cites it as the primary reference; the 1984 survey and 1982b are consistent with this |
| Thomason's neutral frames directly inspire the chronicle's diagram completion | MEDIUM | Structural parallel is strong, but the BX chronicle has additional S5 complexity |
| Doets (1989) model replacement applies to dense completeness (task 68) | MEDIUM | Requires verification that BX definably-well-ordered analog exists |

### Recommendation: Strategic Priority Adjustments

Based on the literature study, I recommend the following priority adjustments:

1. **Obtain Burgess (1982) "Axioms for Tense Logic I"** immediately. This is the foundational source that everything else builds on, and we do not have it. All five sources we studied cite it or presuppose it.

2. **Task 68 (dense completeness) may be more tractable than currently assessed.** Venema (1993) provides a direct technique (model replacement via Doets) that was not in the task 68 research. The current assessment ("needs Rat canonical model construction") may be an underestimate — a model-replacement argument might work more cleanly than building an entirely new canonical model.

3. **The chronicle construction (task 107) is the right approach, and the three-layer infrastructure problem (g-function, guard convention, domain extension) is the correct framing.** Nothing in the literature suggests a better alternative. The plan v5 (15_implementation-plan.md) is well-aligned with what the literature supports.

4. **Publication framing should emphasize orthodox derivation rules.** Venema's (1993) explicit concern about the irreflexivity rule (IR) shows this is a live issue in the field. The BX formalization's use of only MP, TG, and SUB is a publishable advantage that should be prominently stated.

5. **Scope: 5,000-8,000 lines for the full sorry-free completeness proof.** Based on Obendrauf's 6,000-line CLC formalization, and BX's comparable but slightly greater complexity, this is the realistic estimate. The current plan (55 hours, ~1,000 lines per phase) is consistent with this at the lower end if no new mathematical obstacles are encountered.

---

## Appendix: Quick Citation Reference for Paper Draft

| Claim in Paper | Cite |
|----------------|------|
| S5 is the modal fragment of linear tense logic | Burgess (1984, §6.2 table) |
| Orthodox axiom systems without IR are preferable | Venema (1993, Introduction) |
| Chronicle construction traces to Burgess (1982) | Burgess (1982) [OBTAIN], Burgess (1984, §5) |
| Naive tense-modal combinations are incomplete | Thomason (1984, §4, formula (17)) |
| Bimodal combination non-trivially interacts | Thomason (1984, §1: "shouldn't expect T+X from separate reflection") |
| Model replacement for dense/well-ordered completeness | Venema (1993, Theorem 4.2 + Doets (1989)) |
| Lean 4 completeness formalization is feasible at this scale | Obendrauf et al. (2024) |
| Typeclass-based reuse for related logics | Obendrauf et al. (2024, §7) |
| BX axioms BX4-BX12 are mathematically necessary | Thomason (1984, §4) [implicit via Kamp incompleteness] |
