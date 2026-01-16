# Lean Library Research: Refactoring Canonical Model Construction in `Completeness.lean`

## 1. Research Scope

- **Task**: 468: Remove or refactor the existing infinite canonical model code in `Completeness.lean`.
- **Topic**: Investigate the canonical model construction in `Theories/Bimodal/Metalogic/Completeness.lean` and identify refactoring opportunities using the `mathlib4` library.
- **Focus**: The core of the investigation is on the implementation of Lindenbaum's Lemma and the associated machinery for maximal consistent sets.

## 2. Analysis of `Completeness.lean`

The file `Theories/Bimodal/Metalogic/Completeness.lean` implements a proof of the completeness theorem for a bimodal logic using a canonical model. The key components of this implementation are:

- **Custom Logical Framework**: It defines `SetConsistent` and `SetMaximalConsistent` from first principles for `Set Formula`.
- **Lindenbaum's Lemma from Scratch**: It contains a custom proof of Lindenbaum's Lemma (`set_lindenbaum`) which shows that any `SetConsistent` set of formulas can be extended to a `SetMaximalConsistent` set.
- **Direct Application of Zorn's Lemma**: The proof of `set_lindenbaum` is a direct, manual application of Zorn's Lemma. It requires several helper lemmas like `consistent_chain_union` to prove that the union of a chain of consistent sets is consistent.
- **Countable Language**: The file includes an instance for `Countable Formula`, which is significant as it opens the door for constructive (non-Zorn) proofs.

While functional, this from-scratch implementation is verbose and duplicates a more general pattern already available in `mathlib`.

## 3. `mathlib` Alternatives and Refactoring Strategy

The core of the "infinite canonical model" code is the machinery for extending a consistent set to a maximal one. This pattern is a specific instance of a more general mathematical concept: extending a filter to an ultrafilter. `mathlib` has a robust library for this.

### Primary Refactoring Strategy: Use `mathlib`'s Filter and Ultrafilter Theory

The most idiomatic and powerful refactoring is to replace the custom consistency framework with `mathlib`'s filter library.

- **Relevant `mathlib` Module**: `Mathlib.Order.Filter.Basic`
- **Key Definitions**:
    - `Filter α`: A structure representing a filter on a type `α`. A filter is a collection of subsets that is upwards-closed and closed under intersection.
    - `Ultrafilter (f : Filter α)`: A proposition stating that a filter `f` is maximal (i.e., it is not the bottom filter and any filter larger than it is equal to it).
- **The Key Theorem**:
    - `Filter.exists_le_ultrafilter (f : Filter α) : ∃ u, Ultrafilter u ∧ f ≤ u`: This theorem, present in `mathlib`, is the **Ultrafilter Principle**. It is proven using Zorn's Lemma and is the direct `mathlib` analogue of the custom `set_lindenbaum` theorem.

### Implementation Plan for Refactoring

1.  **Define a `Filter` of Theories**: Show that the collection of deductively closed supersets of a given consistent set of formulas `S` forms a `Filter (Set Formula)`. The sets in the filter would be the "theories" extending `S`.
2.  **Apply the Ultrafilter Principle**: Use `Filter.exists_le_ultrafilter` on the filter defined in step 1. This will yield an `Ultrafilter`.
3.  **Prove Equivalence**: Prove that a set of formulas `M` belongs to this `Ultrafilter` if and only if it is a `SetMaximalConsistent` set. The properties of ultrafilters (e.g., for any set `A`, either `A` or its complement is in the ultrafilter) correspond directly to the properties of maximal consistent sets (e.g., for any formula `φ`, either `φ` or `¬φ` is in the set).
4.  **Replace Custom Code**: This approach would replace the entire "Lindenbaum Infrastructure" and "Chain Union Consistency" sections of `Completeness.lean` (approx. 70-80 lines of complex proofs) with a few lines of code that leverage the `mathlib` library.

### Benefits of this Approach

- **Code Reduction**: Drastically reduces the amount of boilerplate code for applying Zorn's Lemma.
- **Increased Readability and Maintainability**: The code becomes more declarative, relying on a standard, well-tested library. It will be more familiar to anyone with `mathlib` experience.
- **Generality**: It connects the logic-specific concept of maximal consistent sets to the more general mathematical concept of ultrafilters, which is a conceptual improvement.

### Secondary Refactoring Strategy: Constructive Lindenbaum's Lemma

- **Leverage Countability**: The instance `Countable Formula` can be used to provide a constructive proof of Lindenbaum's Lemma, avoiding Zorn's Lemma entirely.
- **Algorithm**:
    1. Enumerate all formulas `φ₀, φ₁, φ₂, ...` (possible because `Formula` is countable).
    2. Define a sequence of sets `S₀, S₁, S₂, ...` starting with the initial consistent set `S`.
    3. Iteratively define `Sₙ₊₁` as `insert φₙ Sₙ` if it is consistent, and `insert (¬φₙ) Sₙ` otherwise (with proofs that this preserves consistency).
    4. The union `⋃ Sₙ` is the desired maximal consistent set.
- **`mathlib` Support**: `mathlib` has infrastructure for working with countable and encodable types which would aid this approach.

## 4. Recommendation

The **primary strategy** of refactoring to use `mathlib`'s `Filter` and `Ultrafilter` library is strongly recommended. It is the most idiomatic, robust, and maintainable solution. It replaces a significant amount of custom, complex code with a single, powerful theorem from the library. This will make `Completeness.lean` shorter, clearer, and better integrated with the `mathlib` ecosystem.

The constructive approach is a valid alternative and would also be a good refactoring, but the ultrafilter approach is more general and aligns better with the algebraic style of `mathlib`.
