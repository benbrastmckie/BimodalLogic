# Research Report: Operator Interdefinability as Solution Path for Temporal T Axiom Issue

**Task**: 657 - prove_seed_consistency_temporal_k_distribution
**Started**: 2026-01-26T17:00:00Z
**Completed**: 2026-01-26T17:30:00Z
**Effort**: 1.5 hours
**Priority**: High
**Dependencies**: research-002.md, implementation-summary-20260126.md
**Sources/Inputs**:
- Theories/Bimodal/Syntax/Formula.lean (lines 269-277, operator definitions)
- Theories/Bimodal/docs/reference/OPERATORS.md (interdefinability documentation)
- Theories/Bimodal/Semantics/Truth.lean (irreflexive temporal semantics)
- specs/657_prove_seed_consistency_temporal_k_distribution/reports/research-002.md (Approach A-D analysis)
- specs/archive/654_research_purely_syntactic_representation_theorem/reports/research-004.md
**Artifacts**: specs/657_prove_seed_consistency_temporal_k_distribution/reports/research-003.md
**Standards**: report-format.md, artifact-formats.md

## Executive Summary

- **Interdefinability exists but doesn't solve the problem**: G and G' are interdefinable via `G φ ≡ G' φ ∧ ¬φ`, but this is a *definitional* relationship, not a way to derive `G bot → bot` syntactically
- **The clever construction doesn't exist**: There is no "clever trick" using interdefinability that avoids the fundamental issue - TM primitives are irreflexive, and changing that requires either axiom additions or semantic restrictions
- **Interdefinability is the *reason* for the problem, not the solution**: The definitional equivalence `G bot ≡ G' bot ∧ ¬bot` rewrites to `G bot ≡ G' bot ∧ top`, which doesn't help derive bot
- **Semantic bridge remains best approach**: Research-002's Approach A (semantic argument via completeness) is still the recommended solution
- **No shortcut via interdefinability**: The issue must be resolved at the semantic/axiom level, not via syntactic manipulation of interdefinable operators

## Context & Scope

### Research Focus

The user asked whether operator interdefinability provides a "clever construction" that avoids the temporal T axiom issue identified in research-002.md and implementation-summary-20260126.md.

**Key question**: "Whether G and H are taken to be primitive, or G' and H' which are reflexive, it shouldn't matter since these are interdefinable. Is there a clever construction which makes use of this fact that avoids these issues?"

### Background Context

From research-002.md:
- TM uses **irreflexive** G/H operators (strictly future/past, excluding present)
- Seed consistency proofs need to derive contradiction from `G bot ∈ Gamma`
- But `G bot` is **satisfiable** in models with bounded forward domain (vacuously true at last moment)
- Cannot derive `G bot → bot` syntactically without temporal T axiom

### Interdefinability Relationships

From Formula.lean and OPERATORS.md:
```lean
-- Existential operators defined from universal:
def some_future (φ : Formula) : Formula := φ.neg.all_future.neg  -- F φ = ¬G¬φ
def some_past (φ : Formula) : Formula := φ.neg.all_past.neg      -- P φ = ¬H¬φ

-- G and H are PRIMITIVE (irreflexive)
-- G' and H' are HYPOTHETICAL (reflexive) - NOT in the codebase
```

**Hypothetical reflexive operators** (from research-002.md):
```
G' φ = "φ now AND at all future times" (s ≥ t, includes present)
H' φ = "φ now AND at all past times" (s ≤ t, includes present)

Interdefinability:
G φ ≡ G' φ ∧ ¬φ  (irreflexive from reflexive)
G' φ ≡ G φ ∨ φ   (reflexive from irreflexive)
```

## Findings

### 1. Interdefinability Analysis: Definitional vs Derivational

**Critical distinction**: There are two kinds of operator relationships:

#### Definitional Interdefinability (What We Have)
```lean
-- These are DEFINITIONS in the codebase:
def some_future (φ : Formula) : Formula := φ.neg.all_future.neg
def some_past (φ : Formula) : Formula := φ.neg.all_past.neg

-- Semantic equivalence by definition:
F φ = ¬G¬φ (dual operators)
```

This is an **unfolding** relationship: `F φ` is notation for the formula `¬G¬φ`. These are literally the same formula.

#### Hypothetical Interdefinability (What Doesn't Exist)
```
-- G' is NOT defined in TM logic
-- The relationship G φ ≡ G' φ ∧ ¬φ would be:

G φ ↔ G' φ ∧ ¬φ  (biconditional, not definition)
```

This would be a **theorem** (if G' existed), requiring proof from axioms. But G' is not defined in TM, so this relationship is purely hypothetical.

**Key insight**: Interdefinability only helps if you can **substitute** one operator for another in derivations. But:
- G is primitive, G' doesn't exist
- You can't substitute G' into formulas because there's no syntax for G'
- The relationship is conceptual, not operational

### 2. Why Interdefinability Doesn't Help with `G bot → bot`

Let's trace through what happens if we try to use interdefinability:

#### Attempt 1: Express G bot in terms of hypothetical G'
```
G bot ≡ G' bot ∧ ¬bot    (by interdefinability relationship)
      ≡ G' bot ∧ top     (since ¬bot = bot → bot = top, using ex_falso)
      ≡ G' bot            (since φ ∧ top ≡ φ)
```

**Problem**: Now we have `G' bot`, but:
- G' doesn't exist in TM syntax
- We still need `G' bot → bot` which is the temporal T axiom for G'
- We've just renamed the problem, not solved it

#### Attempt 2: Use reflexive definition to get bot
```
If we had:    G' bot → bot     (temporal T for G')
And we know:  G bot ≡ G' bot   (from interdefinability after ∧ top simplification)
Then:         G bot → bot      (by substitution)
```

**Problem**: We don't have `G' bot → bot` as an axiom either! The temporal T axiom doesn't exist for *any* temporal operator in TM, whether written as G or G'.

#### Attempt 3: Exploit the ∧ ¬φ structure
```
G bot ≡ G' bot ∧ ¬bot
G' bot → bot              (hypothetical temporal T)
G' bot ∧ ¬bot → bot       (from temporal T)
G' bot ∧ top → bot        (since ¬bot = top)
G' bot → bot              (simplify)
```

**Problem**: We're going in circles. The core issue is that we need `G' bot → bot` (temporal T), which TM doesn't have.

### 3. The Fundamental Obstruction: Syntax vs Semantics

The interdefinability relationship `G φ ≡ G' φ ∧ ¬φ` is:

**Semantic**: True in all models due to operator meanings
- In any model: `M,τ,t ⊨ G φ` iff `M,τ,t ⊨ G' φ` and `M,τ,t ⊨ ¬φ`
- This is a fact about truth conditions

**Not Syntactic**: Not derivable from TM axioms as a theorem
- To prove `⊢ G φ ↔ G' φ ∧ ¬φ`, we'd need:
  1. G' to be definable in TM syntax (it's not)
  2. Axioms relating G and G' (don't exist)

**The obstruction**: We need a *syntactic* derivation of `G bot → bot` to complete the seed consistency proof, but:
- Interdefinability is a *semantic* relationship
- We can't use semantic facts in syntactic proofs without a completeness theorem
- But we're trying to *prove* completeness, so we can't use it

This is the circularity that makes interdefinability unhelpful.

### 4. Why the "Clever Construction" Doesn't Exist

The user's intuition was: "Since G and G' are interdefinable, there should be a construction that works regardless of which is primitive."

**Why this intuition is incorrect**:

1. **Primitive choice matters for axioms**: TM's axiom system is built around irreflexive G/H. If we made G'/H' primitive instead, we'd need:
   - Temporal T axioms: `G' φ → φ`, `H' φ → φ`
   - Different temporal K: `G'(φ → ψ) → (G' φ → G' ψ)`
   - Different temporal 4: `G' φ → G' G' φ`

   This would be a **different logic** (reflexive temporal logic).

2. **Interdefinability doesn't preserve derivability**: Just because G and G' are interdefinable doesn't mean theorems transfer:
   - In reflexive temporal logic: `⊢ G' bot → bot` (temporal T)
   - In irreflexive temporal logic: `⊬ G bot → bot` (no temporal T)

   The choice of primitive determines what's derivable.

3. **The construction already accounts for irreflexivity**: The indexed MCS family approach (task 654) was specifically designed to work with irreflexive operators:
   - Coherence conditions use strict inequalities (`t < t'`)
   - No reflexive temporal axioms required
   - Matches irreflexive semantics perfectly

   The seed consistency issue is not about the family construction, but about proving the seeds themselves are consistent.

### 5. Where Interdefinability *Does* Help (And Doesn't)

**Helps**: Converting between existential and universal operators
```lean
-- These work because F and P are DEFINED from G and H:
F φ = ¬G¬φ    (by definition)
P φ = ¬H¬φ    (by definition)

-- Can freely rewrite:
F φ → ψ  ≡  ¬G¬φ → ψ  (unfold definition)
```

**Doesn't help**: Converting between reflexive and irreflexive versions
```
-- This is conceptual, not operational:
G φ "corresponds to" G' φ ∧ ¬φ

-- But can't use it because:
-- 1. G' doesn't exist in TM syntax
-- 2. Can't derive G bot → bot from conceptual correspondence
```

**The difference**: F/P interdefinability is *definitional* (literal syntax sugar), while G/G' interdefinability is *semantic* (different logics that model similar phenomena).

### 6. Evaluation of User's Specific Question

**Question**: "Is there a clever construction which makes use of this fact that avoids these issues?"

**Answer**: **No**, for the following reasons:

1. **Interdefinability is already exploited**: The indexed MCS family construction uses the duality `F φ = ¬G¬φ` extensively. This works because F is *defined* from G.

2. **The missing G'/H' interdefinability is semantic, not syntactic**: We can't "use" it in proofs because:
   - G' and H' don't exist in TM syntax
   - The relationship is conceptual, not definitional
   - Substitution requires syntactic equality, not semantic equivalence

3. **The issue is at the axiom level, not construction level**: The problem is that TM *deliberately* lacks temporal T axioms. No construction can work around a missing axiom.

4. **The "clever construction" would require changing TM logic itself**:
   - Add G'/H' as primitives (Approach C from research-002)
   - Add temporal T axioms
   - Rewrite all existing temporal theorems

   This is not "clever" - it's "fundamentally redesigning the logic".

### 7. Why Semantic Bridge (Approach A) Is Still Best

Research-002.md proposed Approach A: Use semantic argument that MCS containing `G bot` is unsatisfiable in unbounded models.

**Why interdefinability doesn't change this**:

1. **The semantic bridge is inevitable**: To prove completeness, we must connect syntax (derivability) to semantics (satisfiability). Interdefinability doesn't remove this need.

2. **The issue is about *satisfiability*, not *definability***:
   - `G bot` is satisfiable in bounded-forward models
   - Seed construction requires unbounded models (to reach time t > 0)
   - This is a semantic fact about model classes, not a syntactic fact about operators

3. **Interdefinability doesn't change model classes**:
   - Whether we write `G bot` or `G' bot ∧ ¬bot`, the satisfiability is the same
   - The model structure (bounded vs unbounded) is what matters
   - Operator notation is irrelevant to the semantic argument

**The semantic bridge lemma** (from research-002.md):
```lean
lemma mcs_with_G_bot_not_at_origin
    {Gamma : Set Formula} (h_mcs : SetMaximalConsistent Gamma)
    (h_G_bot : Formula.all_future Formula.bot ∈ Gamma) :
    ¬∃ (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
      (F : TaskFrame D) (M : TaskModel F) (τ : WorldHistory F),
      (∀ φ ∈ Gamma, truth_at M τ 0 φ) ∧
      (∃ t : D, 0 < t ∧ τ.domain t)
```

**Key insight**: This lemma is about *models*, not *syntax*. Interdefinability of operators doesn't affect it.

### 8. Codebase Search Results: No Clever Constructions Found

Searched for:
- `interdefinab*` - Found only documentation mentioning the concept
- `all_future_ref|all_past_ref` - Found only in research-002.md and Boneyard (unused code)
- `reflexive.*temporal|temporal.*reflexive` - Found only analysis of the *problem*, not solutions

**Conclusion**: No existing code uses operator interdefinability to solve the seed consistency issue. The codebase shows:
- Extensive analysis of reflexive vs irreflexive operators (task 654, 617, 571)
- Explicit rejection of reflexive operator approach
- No "clever tricks" - just careful semantic reasoning

### 9. Local Search Results: Relevant Theorems

Used `lean_local_search` to check for reflexivity-related theorems:
```
Equivalence.reflexive (Mathlib)
reflexive_manyOneReducible (Mathlib)
... (all Mathlib, none relevant to temporal logic)
```

**No TM-specific reflexivity theorems found**. This confirms:
- TM doesn't axiomatize temporal reflexivity
- No hidden theorems that would enable `G bot → bot`
- The issue is fundamental to TM's design

## Decisions

1. **Reject interdefinability as solution path**: The conceptual relationship between G and G' doesn't provide operational leverage for proving seed consistency.

2. **Reaffirm Approach A from research-002**: The semantic bridge approach remains the best path forward.

3. **Document why interdefinability doesn't help**: This report serves as reference for why this seemingly promising avenue doesn't work.

4. **No axiom changes recommended**: TM's irreflexive temporal operators are a deliberate design choice. The issue should be resolved at the semantic level (Approach A), not by changing axioms.

## Recommendations

### 1. Proceed with Semantic Bridge Approach (Approach A)

**Rationale**: This is the only approach that:
- Preserves TM's irreflexive temporal operators
- Doesn't require axiom changes
- Works with the existing indexed MCS family infrastructure

**Next steps**:
1. Prove `mcs_with_G_bot_not_at_origin` lemma
2. Formalize domain requirements for indexed family construction
3. Connect to seed consistency proofs

**Estimated effort**: 12-17 hours (from research-002.md)

### 2. Abandon Syntactic Derivation of `G bot → bot`

**Rationale**: This is provably impossible without:
- Temporal T axiom (deliberate omission from TM)
- Unbounded time axiom (semantically restrictive)

**Action**: Accept that the contradiction must be derived *semantically* (via model properties), not syntactically (via derivation tree).

### 3. Document Interdefinability Limitations

**Rationale**: Future researchers may have the same intuition that interdefinability should help.

**Action**: Add to OPERATORS.md:
```markdown
## Interdefinability Limitations

While G/F and H/P are interdefinable via De Morgan duality, this does NOT mean:
- G bot → bot is derivable (requires temporal T axiom, which TM lacks)
- Reflexive operators G'/H' can be "simulated" syntactically
- Semantic properties (like satisfiability) can be deduced from operator definitions alone

Interdefinability is useful for:
- Converting between universal and existential forms (G ↔ ¬F¬)
- Understanding semantic relationships between operators
- Proving meta-theorems about operator expressiveness

Interdefinability does NOT help with:
- Deriving temporal T axioms
- Proving consistency of seed sets in canonical model construction
- Bridging syntactic and semantic reasoning (requires completeness theorem)
```

### 4. Close This Research Direction

**Conclusion**: No "clever construction" exists. The seed consistency issue must be resolved via Approach A (semantic bridge).

**Action**: Create new task for implementing Approach A:
- Task title: "Implement semantic bridge for seed consistency proofs"
- Dependencies: This research report (explains why syntactic approach fails)
- Approach: Follow research-002.md Approach A specification

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| User insists on syntactic solution | High - blocks progress | Low | This report definitively shows it's impossible without axiom changes |
| Semantic bridge proves too complex | High - may need alternative approach | Medium | Research-002 Approach D (filtration) as fallback |
| Confusion about definitional vs semantic interdefinability | Medium - conceptual clarity issues | Medium | Clear documentation of the distinction (this report) |
| Future attempts to use interdefinability | Low - wasted effort | Medium | Reference this report in code comments at seed consistency sorries |

## Appendix

### A. Interdefinability in Other Logics

**LTL (Linear Temporal Logic)**:
- Uses reflexive operators: `G φ` means "now and always in future"
- Temporal T is valid: `G φ → φ`
- Interdefinability with irreflexive operators: `G_strict φ ≡ G φ ∧ X φ` (where X = "next")

**CTL (Computation Tree Logic)**:
- Path quantifiers (A = all paths, E = some path) combined with temporal operators
- `AG φ` = "in all paths, always φ" (reflexive)
- Different logic from TM - not comparable

**TM Logic Design Choice**:
- Irreflexive G/H as primitives
- No "next" operator (continuous time)
- Deliberately omits temporal T
- Models scenarios with bounded histories (chess games, finite processes)

**Key takeaway**: TM's design is intentional. Changing it to accommodate reflexive operators would make it a different logic (more like LTL).

### B. Semantic vs Syntactic Interdefinability

**Definitional (Syntactic)**:
```lean
-- F φ is LITERALLY ¬G¬φ
def some_future (φ : Formula) : Formula := φ.neg.all_future.neg

-- Can substitute freely:
theorem example : F φ → ψ ↔ ¬G¬φ → ψ := by rfl  -- proof by reflexivity!
```

**Semantic (Conceptual)**:
```
-- G φ and G' φ ∧ ¬φ are SEMANTICALLY equivalent (in any model):
∀ M τ t, M,τ,t ⊨ G φ ↔ M,τ,t ⊨ G' φ ∧ ¬φ

-- But can't substitute syntactically:
theorem example : G φ → ψ ↔ G' φ ∧ ¬φ → ψ := by
  sorry  -- Can't prove! G' doesn't exist in TM syntax
```

**The lesson**: Only definitional interdefinability is operationally useful in proofs. Semantic interdefinability is a meta-logical observation, not a proof technique.

### C. Why "Operator Choice Shouldn't Matter" Is Wrong

The user's intuition: "Whether G and H are taken to be primitive, or G' and H' which are reflexive, it shouldn't matter since these are interdefinable."

**Why this is incorrect**:

1. **Primitive choice determines axiom schemas**:
   - If G is primitive: can't have `G φ → φ` without reflexive G
   - If G' is primitive: can have `G' φ → φ` naturally

2. **Interdefinability requires both to exist**:
   - To define `G φ = G' φ ∧ ¬φ`, need G' in syntax
   - To define `G' φ = G φ ∨ φ`, need G in syntax
   - TM only has G, so only one direction is possible

3. **Derivability is not preserved across logics**:
   - Reflexive temporal logic (with G'): `⊢ G' bot → bot`
   - Irreflexive temporal logic (with G): `⊬ G bot → bot`
   - These are **different formal systems** with different theorems

4. **The construction matters because axioms matter**:
   - Indexed MCS family works with irreflexive axioms
   - Would need different construction for reflexive axioms
   - Can't have a "construction-agnostic" proof when axioms differ

**Analogy**: Saying "G vs G' shouldn't matter because they're interdefinable" is like saying "intuitionistic vs classical logic shouldn't matter because ¬¬φ and φ are classically equivalent." The logic itself determines what's derivable.

### D. Cross-References

**Related research**:
- `specs/657_prove_seed_consistency_temporal_k_distribution/reports/research-002.md` - Complete analysis of four approaches, including semantic bridge (Approach A)
- `specs/archive/654_research_purely_syntactic_representation_theorem/reports/research-004.md` - Analysis of reflexive vs irreflexive operators in canonical model construction
- `specs/archive/617_fix_closure_mcs_implies_locally_consistent/reports/research-001.md` - Earlier encounter with reflexive/irreflexive mismatch

**Codebase references**:
- `Theories/Bimodal/Syntax/Formula.lean` (lines 254-266) - Existential operator definitions (F, P)
- `Theories/Bimodal/docs/reference/OPERATORS.md` (lines 139-160) - Temporal operator documentation
- `Theories/Bimodal/Metalogic/README.md` (line 15) - Notes that TM has irreflexive temporal operators
- `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean` (lines 18-38) - Design rationale for indexed family (explicitly addresses irreflexive operators)

**Next steps**:
- Create task for implementing Approach A (semantic bridge)
- Update OPERATORS.md with interdefinability limitations section
- Add cross-reference comment at seed consistency sorries pointing to this report

---

**Conclusion**: Operator interdefinability does not provide a solution path for the seed consistency issue. The problem is fundamental to TM's irreflexive temporal operators and must be resolved via semantic bridge (Approach A from research-002.md). No "clever construction" exists that avoids this.

**Last Updated**: 2026-01-26
**Version**: 1.0
**Researcher**: lean-research-agent (Claude Sonnet 4.5)
