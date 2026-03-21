# Teammate B Findings: Alternative Approaches

- **Task**: 990 - Representation theorem design for parametric durations
- **Researcher**: Teammate B
- **Focus**: Alternative approaches and prior art
- **Completed**: 2026-03-17

---

## Key Findings

### Finding 1: The Literature Has Three Distinct Strategies for D

Prior art in temporal and metric temporal logic uses three strategies for handling the duration/time domain D in completeness theorems. These map directly onto the choices facing this project:

**Strategy A: D is fixed a priori** (e.g., LTL fixes N or Z)
The most common approach for computational temporal logic. D is a specific known structure. No representation theorem needed to characterize D — just build the canonical model over that structure. This is what the project currently does for discrete completeness (D = Int) and dense completeness (D = Rat via TimelineQuot). The downside: validity must be stated over a fixed D, losing generality.

**Strategy B: D is axiomatically characterized from syntax** (Prior, Burgess, Reynolds)
The "axiomatic characterization" approach: completeness theorems for `N_t`, `Q_t`, `R_t` etc., where the axioms (DENSE, WELLORD, NOEND, etc.) *characterize* which D the logic is complete for. D is not constructed from syntax — rather, axioms constrain the class of allowed D. The canonical model can use *any* D satisfying the axioms. This matches the project's `CanonicalDomain.lean` pipeline: DN axiom characterizes dense orders, so TimelineQuot (≃o Q) works as D for dense completeness.

**Strategy C: D is derived from the canonical algebra** (Montanari & de Rijke 1995, two-sorted MTL)
The "free abelian group" approach, most relevant to this task. In two-sorted metric temporal logic, the displacement component uses the *free abelian group* over algebraic displacement variables as D in the canonical model. D emerges from the proof theory, not from external characterization. This is the closest prior art to the "D-from-syntax" question.

### Finding 2: Montanari & de Rijke 1995 — The Closest Prior Art

The 1995 paper "Completeness Results for Two-Sorted Metric Temporal Logics" (AMAST) is the most relevant prior work. Key points:

- **Two-sorted frames**: Formulas range over time instants; *displacement parameters* range over an ordered abelian group D.
- **Canonical model strategy**: "Taking the free abelian group over algebraic variables as the displacement component, by taking the familiar canonical model as the temporal component, and by linking them."
- **Result**: MTLo is sound and complete for the class of *all MTLo-frames* — universally quantifying over D (any ordered abelian group), not a specific one.
- **Key insight**: The completeness theorem is *parametric in D* — valid means valid for all ordered abelian group D, and the proof constructs a countermodel by letting D be the free abelian group on displacement witnesses.

This is strong evidence that **D-parametric completeness** (holding for *all* ordered abelian groups D, not just Int or Rat) is achievable and has been done in the MTL literature. The project's current `ParametricRepresentation.lean` matches this philosophy exactly.

### Finding 3: BAO/Stone Duality Does Not Directly Produce D

The Jónsson-Tarski representation theorem for Boolean algebras with operators (BAOs) and the associated Stone duality work as follows:

1. Build the Lindenbaum-Tarski algebra from formulas (already done: `LindenbaumQuotient.lean`)
2. Stone duality identifies the frame worlds with *ultrafilters* of the algebra (already done: `UltrafilterMCS.lean`)
3. Modal operators become relation-based via the canonical extension
4. The resulting frame has world states (ultrafilters) and accessibility relations

**Critical limitation**: For pure propositional modal logic, BAO/Stone duality gives a Kripke frame (worlds + accessibility relations). It does *not* intrinsically produce an ordered abelian group D. The duration structure D must come from somewhere else. In the project's case, D is needed because the *task frame* has `task_rel : W × D → Set W`, going beyond standard Kripke semantics. Stone duality alone cannot produce D — it only gives the world structure.

The project's `AlgebraicRepresentation.lean` and `ParametricCanonical.lean` have correctly realized this: the algebraic path gives worlds (MCS ultrafilters), and D remains an external parameter. This is the right design.

### Finding 4: Category-Theoretic / Presheaf Approach

Lawvere's approach to time uses a *category* as the time structure. Temporal Type Theory (Schultz & Spivak, arXiv:1710.10258) builds semantics in the topos of sheaves on a "translation-invariant quotient of the standard interval domain." Key observations:

- Duration does *not* emerge from pure category structure — the interval domain is postulated as a specific object (related to R).
- Presheaf models naturally handle *behavior over time windows* but require fixing what "time" means externally.
- For a proof-theoretic completeness theorem of TM logic, presheaf/topos approaches would require substantially more infrastructure and would not resolve the D question.
- **Assessment**: Not suitable as an alternative for this project. The topos approach is better suited for continuous systems with real-valued time than for discrete/dense modal logic completeness.

### Finding 5: "Since/Until" Logic Over Arbitrary Linear Orders (Burgess, Venema, Reynolds)

The completeness theory for tense logic with Since and Until over *arbitrary* linear orders (Burgess 1982, Reynolds 1994, Venema's interval logic work) takes the following approach:

- The canonical model is built over an *abstract* linear order (not Int or Rat specifically).
- Completeness holds for the *class* of all linear orders satisfying the axioms.
- No single duration group D is derived — instead, the semantics ranges over *all* such structures.

This is closest to the project's base-logic completeness challenge: the base TM axioms characterize no specific D, so the completeness theorem must hold for all valid D. The `ParametricRepresentation.lean` conditional theorem (`parametric_algebraic_representation_conditional`) is the right architecture.

### Finding 6: The Domain Mismatch Is a Known Difficulty

The search confirms the domain mismatch (canonical world domain ≠ semantic domain D) is a recognized challenge in the literature. The standard resolution in two-sorted MTL (Montanari & de Rijke) is exactly what the project's `ParametricCanonical.lean` does:
- World states are drawn from syntax (MCS)
- Displacement D is kept abstract (parametric)
- The task relation is defined using CanonicalR (forward accessibility) plus sign-based case analysis

This is the correct and standard approach, confirmed by prior art.

---

## Recommended Approach

**Recommendation: D should be parametric with axioms constraining its structure — not constructed from pure syntax.**

The codebase has already correctly implemented this in `ParametricRepresentation.lean` and `ParametricCanonical.lean`. The evidence strongly supports continuing this approach:

1. **Montanari & de Rijke precedent**: The closest prior art (two-sorted MTL completeness) uses exactly the D-parametric approach, treating D as an abstract ordered abelian group and proving completeness universally over all such D.

2. **D-from-syntax is infeasible for TM base logic**: TM syntax (`box`, `all_future`, `all_past`) has no explicit duration terms. Unlike MTL which has displacement variables in its syntax, TM base logic cannot express "this task took duration d" in the formula language. There is no basis in syntax from which to construct an ordered abelian group.

3. **Stone duality does not produce D**: BAOs give you worlds (ultrafilters/MCSs), not durations. The duration group is genuinely external to the propositional modal/temporal structure.

4. **The axiom characterization approach IS D-parametric**: For discrete and dense extensions, the DN/DF axioms do not produce a specific D — they characterize *which class* of D the logic is sound for. Completeness constructs a *witness* D (Int or Rat) but the theorem holds over the class. This is consistent with D remaining parametric.

5. **The conditional theorem design is standard**: `parametric_algebraic_representation_conditional` requiring a `construct_bfmcs` argument is analogous to how MTL completeness works: the abstract parametric theorem + instantiation for specific D. This matches standard practice.

### For the Representation Theorem Design

The representation theorem should be stated as:

```
∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D],
  valid_over D φ → ⊢ φ
```

With the proof strategy:
1. Lindenbaum-Tarski construction gives MCS worlds (D-independent)
2. D remains abstract (parametric), satisfying the typeclasses
3. Canonical task relation uses CanonicalR with sign-based dispatch on D
4. Instantiate for specific D (Int, Rat) only for the dense/discrete extensions

This is already the architecture in `ParametricRepresentation.lean`. The design is correct.

---

## Evidence / Examples

### Example 1: Montanari & de Rijke Canonical Model Construction

From "Completeness Results for Two-Sorted Metric Temporal Logics" (AMAST 1995):

> "Our strategy is to construct a canonical-like model by taking the **free abelian group over algebraic variables** as the displacement component, by taking the familiar canonical model as the temporal component, and by linking them."

This shows that in the closest analogous setting (metric temporal logic with ordered abelian group displacements), the displacement domain D in the canonical model is NOT the same as any syntactically-derived object — it is either a free abelian group or a parameter. The completeness theorem is proven for the *class* of all ordered abelian group frames.

### Example 2: Stanford Encyclopedia — Parametric Characterization

From the Stanford Encyclopedia of Philosophy (Temporal Logic):

> "By extending the list of axioms with one or several of the above principles one can axiomatize the logics of various natural models of time"

Specific axiom-to-domain correspondences:
- `DENSE` → ℚ_t (dense orders)
- `DENSE + COMPL` → ℝ_t (Dedekind-complete dense orders)
- `WELLORD + ...` → ℕ_t (well-ordered)

This is the "Strategy B" (D axiomatically characterized) approach used in the project's `CanonicalDomain.lean`. The domain characterization is indirect: axioms constrain the *class* of D, and Cantor's theorem picks the *canonical representative* (Q or Z).

### Example 3: BAO/Stone Duality — Confirms D Is External

The Jónsson-Tarski/Goldblatt algebraic approach gives (via canonical extension and Stone duality):
- **Input**: Lindenbaum-Tarski Boolean algebra with operators (G, H, □)
- **Output**: Frame = Stone space (ultrafilters) + accessibility relations derived from operators

The frame has NO duration component — just worlds and relations. The task frame's duration group D must be added independently. This confirms that BAO/Stone duality is insufficient on its own for TM base completeness and that D-parametric is the right design.

### Example 4: TM Syntax Has No Duration Terms

The project's `Formula` type:
```lean
inductive Formula where
  | atom : String -> Formula
  | bot : Formula
  | imp : Formula -> Formula -> Formula
  | box : Formula -> Formula
  | all_past : Formula -> Formula
  | all_future : Formula -> Formula
```

No `after(d, φ)`, no duration constants, no duration variables. This is structurally different from MTL/MITL where duration bounds appear in the syntax. There is *no syntactic material* to derive an ordered abelian group from. D-from-syntax is therefore a non-starter for base TM logic.

---

## Confidence Level

**High** — for the recommendation that D should be parametric (not syntax-derived).

**Reasoning**:
1. The prior art (Montanari & de Rijke 1995) provides a direct precedent for D-parametric completeness in exactly the relevant setting (metric temporal logic over ordered abelian groups).
2. The project's codebase already correctly implements the D-parametric architecture in `ParametricRepresentation.lean` and `ParametricCanonical.lean`, and this architecture is sound.
3. The structural impossibility of D-from-syntax (no duration terms in TM syntax) is clear.
4. The BAO/Stone duality approach confirms that algebraic methods give MCS worlds but not D.

**Medium** — for which specific instantiation strategy for D is best (Int vs. free abelian group vs. TimelineQuot).

**Reasoning**: The choice between using Int (for discrete), TimelineQuot ≃o Rat (for dense), or a more abstract free abelian group construction for base completeness is architecturally significant and depends on what sorries are most tractable. This is a detailed implementation question beyond pure prior art research.

**Caveat**: The two-sorted nature of MTL (explicit displacement variables in syntax) means Montanari & de Rijke's free abelian group construction does not directly apply to TM base logic (which has no displacement syntax). For TM base logic, the cleanest approach is to prove completeness relative to D = Int as a specific witness (already done in `BaseCompleteness.lean` with the sorry-free `temporal_coherent_family_exists_CanonicalMCS`).

---

## Appendix: Summary Table of Alternative Approaches

| Approach | D Source | Feasibility for TM | Evidence |
|----------|----------|---------------------|----------|
| D parametric (current) | External type parameter | **High** — already implemented | Montanari & de Rijke 1995 |
| D from syntax | Formula language | **Not feasible** — TM has no duration syntax | Architecture analysis |
| BAO/Stone duality | Lindenbaum algebra | Gives worlds only, not D | Jónsson-Tarski, Goldblatt |
| D from order-isomorphism | Cantor/Z-char theorem | **Works for dense/discrete** — needs axiomatic extension | Current CanonicalDomain.lean |
| Presheaf/topos | Interval domain postulated | Excessive infrastructure | Schultz & Spivak 2017 |
| Two-sorted MTL | Free abelian group | Requires duration syntax | Montanari & de Rijke 1995 |

The D-parametric approach (column 1) is the correct and standard design for the TM base representation theorem.
