# Phase 6B Analysis Handoff -- Hierarchy Theorem Approaches

## Status: BLOCKED -- Detailed Analysis Complete

## Session
sess_1779084016_ff70c0

## What Was Done
Thorough analysis of multiple approaches to proving `all_formulas_separable` without the 9 axioms in SeparationThm.lean. No code changes were committed because no approach yielded a provable theorem without circularity.

## Current Codebase State
- Build passes with 1647 jobs, 0 sorries in main stack, 9 axioms in SeparationThm.lean
- DedekindZ.lean: 539 lines, case3_equiv_Z_general proved, Cases 5-8 use `all_separable _`
- Hierarchy.lean: 1055 lines, abstract_untl/abstract_snce infrastructure complete
- All existing theorems are sound; axioms are placeholders for the GHR94 hierarchy

## Root Cause Analysis

### The Circularity
Every approach reduces to the same fundamental problem:

**To prove `.snce C F` is separable when C and F are separable (= `snce_separable` axiom), one needs to show `.snce C' F'` is separable when C', F' are syntactically separated.**

This `.snce C' F'` formula has:
- `no_S_nested_in_U` (separated formulas have S-free untl-args)
- Junction depth at most 1
- `.untl` nodes (with S-free args) potentially inside C', F'

Every approach to showing this separable eventually requires either:
1. The `snce_separable` axiom itself (circularity), or
2. A generalization of `elim_case_1_gen` that accepts non-U-free events (not available), or
3. A substitution-back argument that requires `all_past_separable` or `snce_separable` (circularity)

### Approaches Attempted and Why Each Fails

#### 1. Junction Depth Induction
- **Approach**: WF induction on `junction_depth (expand_temporal phi)`.
- **Works for**: JD >= 2 (abstract snce from untl-arg, JD decreases, IH applies).
- **Fails for**: JD = 1. After abstracting innermost `.snce C F` (with JD-0 children) from `.untl` arg, JD drops to 0 (separated). But substituting back `.snce C F` for the fresh atom creates JD = 1 again. The IH doesn't apply since JD didn't decrease.
- **With lex (JD, size)**: `.snce C F` is a subformula (smaller), so the snce itself is separable by IH. But `subst_formula(ψ, p, .snce C F)` is a different formula whose size may exceed the original.

#### 2. Structural Induction for no_S_nested_in_U_separable
- **Approach**: Structural induction on phi in the expanded fragment.
- **Works for**: atom, bot, imp, box (trivial), untl (S-free args → separated).
- **Fails for**: `.snce C F`. By IH, C and F are separable. Get separated C', F'. But `.snce C' F'` is a NEW formula, not a subformula of `.snce C F`. Can't apply structural IH.

#### 3. U-Count Induction (Lemma 10.2.6 style)
- **Approach**: Abstract one U(A,B) from `.snce C F`, reduce to n-1 U-types. By IH, the abstracted formula is separable. Get separated ψ. Substitute back.
- **Fails because**: `subst_formula(ψ, p, .untl A B)` where `.untl A B` is S-free: the substitution puts `.untl A B` inside `.snce`-args of ψ (breaking U-freeness) and inside `.all_past`-args (breaking U-freeness). Proving the substituted formula is separable requires `snce_separable` or `all_past_separable` (the axioms).

#### 4. case3_equiv_Z_general + Decomposition (Cases 5-8 direct proof)
- **Approach**: Prove Cases 5-8 directly using `case3_equiv_Z_general`, then show each RHS component is separable via Cases 1-4 + boolean closure.
- **Partial success**: The RHS has 3 disjuncts. Disjunct 1 (`S(a∧U, q)`) is handled by `elim_case_1_gen` (Case 1). Disjuncts 2/3 have `.snce` with U-free guards BUT complex events containing U(A,B).
- **Fails because**: The events contain U(A,B) in nested positions (inside ¬q, S(a∧U,q), etc.). Event-splitting creates ¬U(A,B) terms which are NOT U-free, preventing application of `elim_case_1_gen`.

#### 5. Event-Split + Multi-U Factoring
- **Approach**: Event-split on each U in the event, reducing to terminal cases with event = a_uf ∧ ±U₁ ∧ ... ∧ ±Uₙ.
- **Fails because**: The ¬U(A,B) terms (.imp (.untl A B) .bot) are NOT U-free. So the "U-free part" a_uf can't be cleanly separated from the U terms. `elim_case_1_gen` requires a U-free first argument.

#### 6. untl_in_snce_guard Measure
- **Approach**: Define a measure counting `.untl` nodes in `.snce`-guard positions. `case3_equiv_Z_general` moves U from guard to event, strictly decreasing this measure.
- **Promising**: The measure DOES decrease when applying case3_equiv_Z_general.
- **Fails because**: The base case (0 U in guards) still needs to show `.snce(event, U-free-guard)` is separable when the event has `.untl` nodes. This requires handling multiple U-types in the event, which runs into the same event-splitting problem (approach 5).

#### 7. Model Modification (abstract_untl_correct / abstract_snce_correct)
- **Approach**: Use `abstract_untl_correct` to relate `phi` to an abstracted version via model modification. The abstracted version is separated. Compose equivalences.
- **Fails because**: `abstract_untl_correct` gives: `int_truth M t phi ↔ int_truth M' t phi_abs`. This is equivalence at model M and M', not global `int_equiv`. The `subst_correctness` roundtrip gives the identity (phi = subst(abs, p, .untl A B) = phi).

### What Would Work

Based on the analysis, the circularity can ONLY be broken by one of:

1. **Generalized Case 1/Case 2**: Prove `elim_case_1_gen` for events `a` that are SEPARABLE (not just U-free). This requires constructing a new explicit separated equivalent for S(separable_event ∧ U(A,B), U-free-guard). The construction must handle the case where the event contains ¬U terms and S-formulas.

2. **Direct Separated Construction**: For `.snce C F` where C, F are separated and have `.untl` with S-free args: directly construct a separated formula equivalent to `.snce C F`, without going through abstraction/substitution. This would essentially implement the GHR94 Normal Form construction for integer time.

3. **Semantic Argument**: Prove that `.snce C F` is separable by a semantic argument (e.g., showing it defines a Boolean combination of past and future definable sets), rather than a syntactic construction. This would be a fundamentally different proof strategy.

4. **Combined Induction**: Use a well-founded induction on a composite measure that simultaneously handles structural depth, U-count, and guard-U-count, avoiding the need for the individual temporal closure axioms. The measure must strictly decrease at EVERY recursive call, including the compose-back step.

### Recommendation for Next Agent

**Option A (Most Promising)**: Implement approach (1) -- Generalized Case 1. The key is constructing a separated equivalent for `S(event ∧ U(A,B), guard)` where `event` is separable (may contain ¬U and S-formulas) and `guard` is U-free. The construction:
- Factor the event into boolean combinations of atoms, pure-past S-formulas (U-free args), and pure-future U-formulas (S-free args, including ¬U terms).
- Each pure-future U-formula is itself separated (untl with S-free args is separated; ¬untl with S-free args is .imp of separated → separated).
- The S-formulas in the event have U-free args (from separation).
- Use `since_distrib_or_left` to distribute the S over the disjunctive structure.
- Each resulting S-formula has an event that is an atom or a pure-past/future formula, making it directly separable.

**Option B (Fallback)**: Accept the 9 axioms as sound placeholders and focus on other work. The axioms are mathematically justified by Kamp's theorem and the GHR94 separation theorem for integers.

## Files Examined
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` (9 axioms)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` (1055 lines, abstract_untl/snce infrastructure)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ.lean` (539 lines, case3_equiv_Z_general)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/NormalForm.lean` (455 lines, lemma_10_2_4)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean` (Cases 1-4 proved)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/TemporalClosure.lean` (expand_temporal, JD analysis)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Defs.lean` (junction_depth, no_S_nested_in_U)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/FormulaOps.lean` (subst_formula, subst_correctness)

## Key Definitions (for quick reference)
- `junction_depth`: mutual recursive with `junction_depth_U`, `junction_depth_S`
- `no_S_nested_in_U`: untl args are S-free, recurses through everything else
- `case3_equiv_Z_general`: S(event, q ∨ U(A,B)) ↔ case3_rhs (for arbitrary event)
- `elim_case_1_gen`: S(a ∧ U(A,B), q) with U-free a, q and S-free A, B → separated
- `elim_case_2_gen`: S(a ∧ ¬U(A,B), q) with U-free a, q and S-free A, B → separated
- `expand_temporal`: replaces all_past/all_future with ¬(snce/untl) equivalents
- `abstract_untl`, `abstract_snce`: replace temporal subformulas with fresh atoms
