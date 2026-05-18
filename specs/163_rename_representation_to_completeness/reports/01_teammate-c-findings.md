# Teammate C (Critic) Findings: Task 163

**Task**: Rename representation theorems to completeness in Algebraic module / refactor for genuine Jónsson-Tarski representation
**Date**: 2026-05-18
**Angle**: Gaps, shortcomings, and blind spots

## Key Findings

### 1. CRITICAL: Since/Until Are NOT Normal Operators — Standard J-T Does Not Apply Directly

The standard Jónsson-Tarski representation theorem applies to **Boolean Algebras with (normal, additive) Operators** (BAOs). In BAOs, each operator `f` is:
- **Normal**: `f(0) = 0` (maps bottom to bottom)
- **Additive**: `f(a + b) = f(a) + f(b)` (distributes over join)

The TM logic's **Since** and **Until** operators are **binary** and **not normal/additive in both arguments**. Specifically:

- `U(event, guard)` holds if there exists a future witness for `event` with `guard` holding at all intermediaries
- `S(event, guard)` is the past mirror

These have a mixed quantifier structure (existential for the witness, universal for intermediaries). They are **not** BAO operators in any standard sense. The guards argument is under a universal quantifier nested inside an existential — this creates a non-monotone dependency that cannot be captured by additive operators.

**The existing STSA typeclass captures only G/H/box/sigma — it has no Since/Until operators at all.** A genuine representation theorem would need to account for the *full* operator signature including Since/Until.

### 2. The STSA Typeclass Is Incomplete for Full TM Logic

The current `STSA` typeclass in `TenseS5Algebra.lean` defines:
- `box : α → α` (unary)
- `G : α → α` (unary)
- `H : α → α` (unary)
- `sigma : α → α` (involution)

**Missing**: There are no `Until` or `Since` operators in the STSA typeclass. These are binary operators (`Formula → Formula → Formula`) in the syntax. For a genuine representation theorem that covers the full logic, you would need:
- `untl : α → α → α` (binary operator for Until)
- `sinc : α → α → α` (binary operator for Since)
- Axioms governing their interaction with G, H, box, sigma

**However**, the non-normal/non-additive nature of Since/Until means they cannot be straightforwardly added as BAO operators. The algebraic semantics for Since/Until requires a different algebraic framework — possibly along the lines of Venema's work on **temporal algebras** (1991 thesis, Chapter 2) which introduces specific algebraic structures for these operators.

### 3. Existing Sorries Block the STSA Instance

There are **6 sorries** across the Algebraic/ module:

| File | Count | Nature |
|------|-------|--------|
| `TenseS5Algebra.lean` | 3 | `TA_quot` (temp_a), `TL_quot` (temp_l), `linearity_quot` (temp_linearity) |
| `InteriorOperators.lean` | 1 | `G_monotone` (temp_k_dist) |
| `LindenbaumQuotient.lean` | 2 | `provEquiv_all_future_congr` (temp_k_dist, 2 instances) |

All 6 sorries stem from **two missing derivations**:
1. `temp_k_dist`: G distributes over implication (K-axiom for G). Needed in 3 places.
2. `temp_a` / `temp_l` / `temp_linearity`: Temporal axioms that were "removed in BX" — suggesting these aren't directly derivable from the Burgess-Xu system.

**Impact**: The `lindenbaumSTSA` instance (proving the Lindenbaum algebra is an STSA) depends on all these sorries. Any representation theorem building on STSA inherits these blockers. A genuine J-T representation would inherit them too.

### 4. Scope Mismatch: Task 163 vs. User's Actual Goal

Task 163 as written is a **small renaming task** (7 theorem renames, 4 call site updates, 2 file renames). But the user's focus prompt describes a much larger project:

- Research how to refactor Algebraic/ for genuine Jónsson-Tarski representation
- Study prior art for tense logics with Since/Until
- Decide what to keep, rename, archive, or delete

These are fundamentally different scopes. The rename task is a few hours of work; the representation theorem research and refactoring is a major mathematical and engineering effort. **The task description should be updated, or this should spawn a new task.**

### 5. The "Representation" vs. "Completeness" Distinction Is Mathematically Correct But Implementation Is Subtle

The user correctly identifies that the current "representation" theorems are really **completeness** theorems (contrapositive: not provable → countermodel exists). A genuine Jónsson-Tarski representation theorem would state:

> Every STSA embeds into the complex algebra of some relational structure (frame).

This is a **purely algebraic** statement with no mention of provability. The current `algebraic_representation_theorem` at `AlgebraicRepresentation.lean:180` states:

```
AlgSatisfiable φ ↔ AlgConsistent φ
```

which is `∃ ultrafilter U, [φ] ∈ U ↔ ⊬ ¬φ` — clearly a completeness theorem.

### 6. Linearity Axiom May Not Be First-Order Preservable

The STSA `linearity` axiom at line 119-121 encodes:
```
Fa ⊓ Fb ≤ F(a ⊓ b) ⊔ F(a ⊓ Fb) ⊔ F(Fa ⊓ b)
```

This is the algebraic version of temporal linearity. For the J-T representation to work, the ultrafilter frame must validate this. Whether the ultrafilter frame of an arbitrary STSA satisfying this axiom actually has a linear temporal order is a non-trivial question. The Goldblatt-Hodkinson-Venema (2003) paper in the literature shows that canonicity does NOT always imply elementary determination — there exist canonical varieties that are not elementarily generated.

For TM logic specifically, Wolter (2000, cited in GHV2003) proved the converse of Fine's theorem holds for **all normal extensions of linear tense logic**. This is encouraging, but TM logic with Since/Until goes beyond basic tense logic.

### 7. Literature Gap: No J-T Representation for Since/Until Algebras

Examining the `literature/` directory:
- **Venema 1991** (Many-Dimensional Modal Logics): Discusses algebraic semantics for temporal logics, including Since/Until. Chapters 2 and Appendices A-B are available.
- **Venema 1993** (Since and Until): Focuses on axiomatization/completeness, not representation.
- **de Rijke & Venema 1995** (Sahlqvist for BAOs): Covers Sahlqvist identities for BAOs, canonicity. Since/Until axioms may not be Sahlqvist.
- **Goldblatt, Hodkinson, Venema 2003**: Negative result — canonical varieties need not be elementarily generated. BUT this is for specific pathological cases.

**Missing from literature/**:
- Venema's PhD thesis Chapter 3+ which likely contains the temporal algebra representation theory
- Jónsson & Tarski 1951/1952 original papers
- Any specific treatment of representation theorems for algebras with Since/Until

### 8. Atom Structures vs. Ultrafilter Frames

The standard J-T representation uses the **atom structure** of a BAO — the set of atoms with relations induced by the operators. For non-atomic algebras (like Lindenbaum algebras, which are typically atomless), one must use **ultrafilter frames** instead. The existing code already uses ultrafilters (`UltrafilterMCS.lean`), which is the right approach.

However, for the representation to be an *embedding* (injective homomorphism) rather than just a homomorphism, additional care is needed. The existing `mcsToUltrafilter`/`ultrafilterToSet` bijection is a good foundation, but it only establishes correspondence for the specific Lindenbaum algebra, not for arbitrary STSAs.

## Recommended Approach

1. **Split into two tasks**: Keep task 163 as the simple rename (small, well-defined). Create a NEW task for the J-T representation research and implementation.

2. **Resolve the 6 existing sorries first** (or at least `temp_k_dist`): The STSA instance is incomplete without them. Any representation theorem building on STSA inherits these blockers.

3. **Study Venema 1991 Ch.2 carefully**: This is the most relevant algebraic treatment of temporal operators including Since/Until. The `literature/` directory has it. The key question is whether Venema defines an algebraic structure that includes Since/Until and proves a representation theorem for it.

4. **Consider a "BAO with residuated pairs" approach**: Since/Until may be treatable as *residuals* of the G/H operators (U is related to F, S to P). Residuated lattice theory may provide a path to representation.

5. **Do NOT delete existing completeness proofs**: The existing `AlgebraicRepresentation.lean` and `ParametricRepresentation.lean` are valuable completeness results. Rename them (task 163) but keep them as the primary tool for proving unprovable formulas have countermodels.

6. **Archive candidates for Boneyard**: None of the current Algebraic/ files are dead code — they all serve the completeness proof pipeline. The only archival candidates would be if you create *new* files that supersede old ones during the representation refactoring.

## Evidence/Examples

- `TenseS5Algebra.lean:57-121`: STSA typeclass — no Since/Until operators
- `TenseS5Algebra.lean:195,278,320`: Three `sorry` placeholders for temporal axioms "removed in BX"
- `InteriorOperators.lean:83`: `sorry` for `temp_k_dist`
- `LindenbaumQuotient.lean:177,182`: Two `sorry` placeholders for `temp_k_dist`
- `AlgebraicRepresentation.lean:180-189`: The "representation" theorem is actually `AlgSatisfiable φ ↔ AlgConsistent φ` — a completeness theorem
- `Goldblatt_Hodkinson_Venema_2003_BAOs_Modal_Logic.md:1-15`: J-T representation overview and the canonicity/elementarity distinction
- `Venema_1993_Since_and_Until.md:25`: Orthodox axiomatizations needed for algebraic properties like ultraproduct closure

## Confidence Level

**HIGH** for the mathematical concerns (Since/Until non-normality, STSA incompleteness, sorry blockers). These are structural issues that any implementation will face.

**MEDIUM** for the scope assessment. The user may already plan to address these in stages, and the rename-first approach is sensible.

**LOW** for the specific recommendation about residuated pairs — this is speculative and needs verification against Venema 1991.
