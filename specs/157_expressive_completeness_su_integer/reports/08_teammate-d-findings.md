# Teammate D (Horizons) Findings: Task 157 Strategic Analysis

## Key Findings

### 1. The Circularity is Real but GHR94's Own Solution is Overlooked

After 8 rounds, every approach has hit the same wall: proving `snce_separable` (that S(sep, sep) is separable) requires temporal closure, which IS the axiom being proved. But GHR94's Lemma 10.2.8 proof does NOT use temporal closure at all. It uses a specific strategy that has been misunderstood in the formalization:

**What GHR94 10.2.8 actually does**: Given S(D₁, D₂) with junction_depth ≥ 2:
1. Find maximal U-subformulas U(Aᵢ, Bᵢ) in S(D₁, D₂)
2. Inside each U(Aᵢ, Bᵢ), find S-subformulas S(Eᵢⱼ, Fᵢⱼ) — these have JD ≤ d-2
3. Replace those S-subformulas with fresh atoms zᵢⱼ, producing U(A'ᵢ, B'ᵢ)
4. Apply Lemma 10.2.7 (no-S-in-U) to get separated E'
5. **Resubstitute S(Eᵢⱼ, Fᵢⱼ) for zᵢⱼ in each constituent of E'**
6. Each constituent now has JD ≤ d-1 (or d-2), so IH applies

The key insight: **step 5 does NOT create a single formula that needs temporal closure**. Instead, it creates individual constituents, each of which is independently shown separable by the IH. The separation of the whole is preserved because it's a boolean combination.

### 2. The "Constituent Substitution" Problem is the Wrong Frame

Previous attempts tried to prove `subst_formula_preserves_separated`, which is FALSE. But GHR94 never needs this. What it needs is:

- A separated formula E' is a boolean combination of: atoms, pure-future terms, pure-past terms
- When you substitute S(E,F) for atom z in a **pure-past** term, you get a formula of the form S(...) or boolean combination of S-formulas — still past-directed, with JD ≤ d-2
- When you substitute S(E,F) for atom z in a **pure-future** term, the z doesn't appear (because E' is separated and the atom z was introduced inside a U-argument, meaning z can only appear in past positions after separation)
- When you substitute for z appearing as a standalone atom in the boolean, you get S(E,F) directly, which has JD ≤ d-2

The critical point: **z cannot appear in the pure-future constituents** because z replaced something inside U-arguments, and separation moved all past-dependent subformulas out of U-arguments.

### 3. Case 7 is NOT the Real Blocker

Case 7 uses `all_separable` but this isn't the fundamental obstacle. Case 7 can be resolved by:
- Using GHR94 10.3.11.7's decomposition: S(a∧U, q∨¬U) ↔ S(a, B∧q) ∧ (A∨B∧U) ∨ S(S(a,B∧q)∧A∧(q∨¬U), q∨¬U)
- The first disjunct is trivially separable
- The second disjunct is Case 8 form — which is ALREADY proved non-circularly

The real blocker is `multi_U_formula_separable` (line 858 of Hierarchy.lean), which delegates to `all_separable`. This is needed for the hierarchy but currently circular.

### 4. The 9 Axioms Have a Natural Elimination Order

Not all 9 axioms are equally hard. There's a natural dependency:

1. **`snce_separable`** — the hardest; everything depends on this
2. **`untl_separable`** — dual of snce_separable; follows by symmetric argument
3. **`all_past_separable`** — follows from snce_separable (since H(φ) ↔ ¬S(⊤, ¬φ))
4. **`all_future_separable`** — follows from untl_separable (since G(φ) ↔ ¬U(⊤, ¬φ))
5. **4 proper separability axioms** — follow from syntactic → proper bridge
6. **atom preservation** — follows from tracking atoms through the construction

So the ONLY thing needed is `snce_separable`. Everything else derives.

## Recommended Approach

### The "Flat Hierarchy" Architecture

Instead of following GHR94's 4-level hierarchy (10.2.5 → 10.2.6 → 10.2.7 → 10.2.8), implement a **single well-founded induction** on junction_depth that directly handles the circularity. Here's the key insight that makes this work:

**Theorem** (`all_formulas_separable_aux`):
For all φ with `has_no_allpast_allfuture φ = true`, φ is separable.

**Proof by strong induction on junction_depth(φ)**:

- **JD = 0**: φ is syntactically separated already (no S-U nesting).

- **JD ≥ 1**: φ is a boolean combination of atoms, S(C₁,C₂), and U(C₁,C₂).

  For S(C₁,C₂) (the only non-trivial case by duality):
  - If no U appears in C₁, C₂: already separated
  - If U appears: Find maximal S-subformulas S(Eᵢⱼ, Fᵢⱼ) inside U-arguments. These have JD ≤ JD(φ) - 2.
  - Replace each with fresh atom zᵢⱼ → produces S(C'₁, C'₂) with `no_S_nested_in_U`
  - Apply `no_S_nested_separable` (proved separately, see below) to get separated E'
  - E' = bool(atoms, pure_future_terms, pure_past_terms)
  - **For each past term P in E'**: substitute zᵢⱼ back with S(Eᵢⱼ, Fᵢⱼ). Result has JD ≤ max(JD(P without z), JD(S(Eᵢⱼ,Fᵢⱼ))) ≤ JD(φ) - 2 + 1 = JD(φ) - 1. Apply IH.
  - **For each future term F in E'**: z atoms don't appear (they were from inside U-args, separation pushed them to past positions). No substitution needed. Already pure future.
  - Reassemble: boolean combination of separable = separable.

**`no_S_nested_separable`**: For φ with no S nested in any U, φ is separable.

This is Lemmas 10.2.5-10.2.7 combined. The key: this does NOT need `snce_separable` or any temporal closure axiom because:
- Structural induction on φ in the expanded fragment
- Base cases: trivial
- `.untl a b`: a, b are S-free (by `no_S_nested_in_U`), so `.untl a b` is already separated
- `.snce C F`: Apply Cases 1-8 to pull all U out from under this S. The Cases 1-8 are already proved. After pulling out, S has U-free arguments → separated.
  
  Wait — this is the crux. When we apply Cases 1-8, the RESULT contains new S-formulas whose arguments may have U. Specifically, case1_psi contains terms like `S(a, q)`, `S(a, B)`, `S(A∧q∧S(a,B)∧S(a,q), q)`. The deepest nested S-term `S(A∧q∧S(a,B)∧S(a,q), q)` has S-in-event... but with U-free arguments (since A, B, q are atoms/U-free).

  Actually, in the specific case of `no_S_nested_in_U` formulas: the U-arguments A, B ARE S-free. The result of Cases 1-8 has U(A,B) only at top level (not under S) and all new S-terms have U-free arguments. So the result IS separated.

  The issue was that the intermediate formula (after a SINGLE case application) might have MULTIPLE U-types. But that's exactly what Lemma 10.2.6 handles, and it works without temporal closure because:
  - Abstract n-1 U-types to atoms → single U → 10.2.5 → separated
  - In the separated form, substitute U back for atoms in past constituents
  - The past constituents now have n-1 U-types → IH on U-count

  This is purely syntactic and never needs temporal closure because U-arguments are always S-free (maintained by the `no_S_nested_in_U` condition and by the elimination cases).

**The bottom line**: `no_S_nested_separable` can be proved WITHOUT temporal closure axioms. Then the JD induction handles the general case. The temporal closure axioms become derivable.

### Concrete Implementation Plan

1. **Prove `no_S_nested_separable`** (~400 LOC in Hierarchy.lean)
   - Combined induction on (U-count, S-nesting-above-U)
   - Use Cases 1-8 to handle the S case
   - Use Lemma 10.2.6's atom-substitution trick for multi-U
   - Key insight: separation produces past constituents where U-atoms appear; substituting U(Aᵢ,Bᵢ) for atom qᵢ in a past constituent S(E,F) gives S(E',F') where E',F' have n-1 U-types and satisfy `no_S_nested_in_U` (since original U-args were S-free and elimination cases preserve this). IH applies.

2. **Prove `junction_depth_separable`** (~200 LOC)
   - Strong induction on JD
   - JD=0,1: trivial
   - JD≥2: abstract S from U-args, apply `no_S_nested_separable`, substitute back into past constituents, IH on JD

3. **Derive all 9 axioms** (~50 LOC)
   - `snce_separable`: `all_formulas_separable (.snce φ ψ)`
   - Others: similar one-liners
   - Proper sep bridge: syntactically_separated → properly_separated (for expanded formulas)

### Why This Should Work When 7 Previous Approaches Failed

The previous approaches all tried to prove `snce_separable` directly by induction and hit circularity at the substitution-back step. The fix is:

1. **Split the problem**: Prove `no_S_nested_separable` first (no temporal closure needed), then use it for the general case.
2. **Constituent substitution, not formula substitution**: Don't try `subst_formula_preserves_separated`. Instead, identify the boolean structure of the separated form and substitute into individual constituents.
3. **Track where atoms land**: After separation, atoms from U-abstractions land in past constituents only. This is a structural property of the elimination cases (they push U to top level, leaving S-terms with U-free arguments).

## Creative/Unconventional Ideas

### A. Quotient-Based Approach
Instead of constituent substitution, define a "separated form" datatype:
```lean
inductive SepForm where
  | atom : Atom → SepForm
  | pure_past : Formula → SepForm  -- U-free argument to S
  | pure_future : Formula → SepForm  -- S-free argument to U
  | neg : SepForm → SepForm
  | conj : SepForm → SepForm → SepForm
```
The `realize` function maps SepForm to Formula. Prove the hierarchy produces SepForms. Substitution into SepForm.pure_past is well-defined and produces a new SepForm (by IH). This avoids the `is_syntactically_separated` boolean predicate entirely and makes the structural argument more natural in Lean.

### B. Direct snce_separable via DNF
Given S(φ', ψ') where φ', ψ' are syntactically separated:
- Put φ' in DNF (disjunction of conjunctions of atoms/S-terms/U-terms/¬S-terms/¬U-terms)
- Distribute: S(φ₁ ∨ φ₂, ψ') ↔ S(φ₁, ψ') ∨ S(φ₂, ψ')
- Each conjunctive clause has form: S(lit₁ ∧ ... ∧ litₙ, ψ')
- Each literal is an atom, ¬atom, S-term (U-free args), ¬S-term, U-term (S-free args), or ¬U-term
- S-terms with U-free args in the event of a larger S: these are past-only, can be treated as atoms for separation purposes
- U-terms with S-free args: these are exactly Cases 1-8
- After pulling out U-terms via Cases 1-8, result has no U in S → separated

This is essentially implementing 10.2.4-10.2.5 directly for separated inputs, without the full hierarchy.

### C. Semantic Proof (Radical)
Prove that any formula over (Z, <) defines a "star-free" set (union of boolean combinations of cylinders). Star-free sets are closed under since/until. This gives `snce_separable` semantically. Would require significant new infrastructure but is mathematically clean.

## Strategic Assessment

### Realistic Evaluation

**Probability of success for "Flat Hierarchy" approach**: 70-80%. The mathematical argument is correct (GHR94's proof IS non-circular). The risk is in the formalization complexity:
- Constituent identification in Lean (need a way to decompose boolean combinations)
- Tracking that atoms from U-abstraction don't appear in pure-future positions
- U-count induction for 10.2.6 (multi-U) requires the atom-substitution trick

**Estimated effort**: 600-1000 lines of Lean, 2-3 focused implementation rounds.

**Risk factors**:
1. The `no_S_nested_separable` proof requires a multi-level induction (U-count × S-nesting). Getting the well-founded relation right in Lean is tricky.
2. Constituent substitution requires either the SepForm approach or careful analysis of `is_syntactically_separated` structure.
3. Proving that elimination cases keep U-args S-free requires threading freeness hypotheses through 8 cases.

**Minimum viable path**: Prove ONLY `is_separable` temporal closure (4 axioms), leaving `is_properly_separable` (4 axioms) and atom preservation (1 axiom) as follow-up. This eliminates the main circularity and is the highest-value target. The proper sep bridge is a separate (easier) problem.

**Fallback**: If the full hierarchy proves too complex to formalize, the 9 axioms are mathematically sound. The current codebase has sorry-free ExpressiveCompleteness with axiomatically-justified separation. This is already a significant formal result. The axioms can be documented as "trusted mathematical facts" pending full formalization.

## Confidence Level

**Medium-High** (70%). The mathematical path is clear and correct. The implementation complexity is substantial but manageable. The key risk is formalization overhead (constituent tracking, well-founded induction setup), not mathematical correctness. The SepForm approach (Idea A) could significantly reduce this risk by making the structural argument more natural.
