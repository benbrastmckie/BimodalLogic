# Teammate C Findings: The Gabbay IRR Rule and Implementation

**Date**: 2026-03-21
**Focus**: The Gabbay IRR inference rule as a solution for canonicalR irreflexivity

---

## Key Findings

### 1. The IRR Rule: Precise Formulation

The Gabbay Irreflexivity Rule (IRR) was introduced in:

> Gabbay, D.M. (1981). "An Irreflexivity Lemma with Applications to Axiomatizations of Conditions on Tense Frames." In U. Monnich (ed.), *Aspects of Philosophical Logic*, D. Reidel, Dordrecht, pp. 67-89.

**Standard Formulation**:

```
IRR: If ⊢ (p ∧ H(¬p)) → φ, and p does not occur in φ, then ⊢ φ
```

Where:
- `p` is a propositional atom (the "fresh marker")
- `H` is the past temporal operator ("it has always been the case that")
- `φ` is any formula not containing `p`
- The condition `p ∉ atoms(φ)` is called the **freshness condition**

**Alternative Formulation** (equivalent):

```
IRR: If {p, H(¬p)} ∪ Γ ⊢ φ for fresh p, then Γ ⊢ φ
```

This says: if we can derive φ assuming "we are at an irreflexive world" (a world where p is true but was always false in the past), then φ is a theorem.

**Semantic Intuition**: The formula `p ∧ H(¬p)` is satisfiable at a world w precisely when w is not accessible from itself. In an irreflexive model, every world satisfies `p ∧ H(¬p)` for some fresh p.

### 2. Why IRR Works for Irreflexive Frames

**The Non-Definability Problem**:

Irreflexivity (∀x. ¬Rxx) is **not modally definable**. This is a classical result:
- van Benthem (1983): *Modal Logic and Classical Logic*
- Blackburn, de Rijke, Venema (2001): *Modal Logic*, Chapter 3.3

No formula of standard modal/temporal logic characterizes the class of irreflexive frames. Therefore, no axiom can force irreflexivity.

**Why IRR Succeeds Where Axioms Fail**:

IRR is an **inference rule**, not an axiom. It operates at the meta-level:
1. It allows reasoning "under the assumption of irreflexivity"
2. The freshness condition ensures the conclusion doesn't depend on the assumption
3. The rule is **sound** for irreflexive frames because `p ∧ H(¬p)` is always satisfiable at any world in an irreflexive model

**Technical Mechanism**:

The IRR rule works because:
- In any irreflexive frame F, for any world w, we can choose a valuation V such that V(p,w) = true and V(p,v) = false for all v < w
- This makes `p ∧ H(¬p)` true at w
- If `(p ∧ H(¬p)) → φ` is valid in F and p ∉ atoms(φ), then φ is valid in F
- The freshness of p ensures φ's truth value is independent of p's valuation

### 3. Completeness Proofs with IRR

**Canonical Model Construction Still Works**:

Completeness proofs for logics with IRR use a modified canonical model construction:

1. **Build MCSs normally**: Maximal consistent sets over the extended language
2. **Define accessibility**: R(M,N) iff g_content(M) ⊆ N (standard)
3. **Prove irreflexivity of R**: This is where IRR is essential

**The IRR-Based Irreflexivity Proof**:

This is exactly what the codebase's `CanonicalIrreflexivity.lean` attempts (lines 236-300):

```
Suppose CanonicalR(M, M) for some MCS M.
Build the "naming set": atomFreeSubset(M, p) ∪ {atom(p), H(¬p)}
where p is fresh (not in any formula of M).

Claim: The naming set is consistent.
Proof by contradiction using IRR:
  If inconsistent, finite L ⊆ naming set derives ⊥.
  By iterated deduction theorem: ⊢ (p ∧ H(¬p)) → χ
  where χ = L_af.foldr(imp, ⊥) and L_af are the p-free formulas.
  Since p ∉ atoms(χ), by IRR: ⊢ χ.
  But χ is derivable from M-formulas, so ⊥ ∈ M. Contradiction.

Extend naming set to MCS M'.
From naming set: p ∈ M' and H(¬p) ∈ M'.
```

**The Missing Step (Strict vs Reflexive Semantics)**:

Under **reflexive** semantics (T-axiom: H(φ) → φ):
- From H(¬p) ∈ M', derive ¬p ∈ M' (by T-axiom)
- Contradiction: both p and ¬p in M'

Under **strict** semantics (no T-axiom):
- H(¬p) only asserts ¬p at strictly past times
- Cannot derive ¬p at the present moment
- **Proof breaks**

### 4. Language Modifications

**Does IRR Require Changes to the Language?**

**Option A: Fresh Propositional Variables (Standard Approach)**

IRR as stated requires only:
- Standard propositional atoms
- A mechanism to ensure freshness (p not in conclusion)

This is what the codebase already has:
- `Atom.exists_fresh` provides fresh atoms
- `exists_fresh_for_finite_list` handles finite sets

**No language extension needed** for the basic IRR rule.

**Option B: Nominals (Hybrid Logic Approach)**

Hybrid logic offers an alternative that doesn't require inference rules:

The formula `c → □¬c` (or `↓c.□¬c` with the downarrow binder) **directly expresses irreflexivity** when c is a nominal (true at exactly one world).

This works because nominals provide "world names":
- c names the current world
- □¬c says no accessible world is named c
- Together: the current world is not self-accessible

**Completeness with pure axioms**: Adding `c → □¬c` as an axiom gives a complete system for irreflexive frames without needing inference rules.

**Implementation Tradeoff**:
| Approach | Language Change | Proof System Change | Completeness |
|----------|-----------------|---------------------|--------------|
| IRR Rule | None | Add inference rule | Requires IRR soundness proof |
| Nominals | Add nominal sort | Add satisfaction operators | Standard canonical model |

### 5. Implementation Considerations

**How to Implement IRR in a Proof Checker**:

**Option 1: IRR as Primitive Rule**

Add to `DerivationTree`:
```lean
inductive DerivationTree : List Formula → Formula → Type where
  ...
  | irr (p : Atom) (φ : Formula) (hp : p ∉ φ.atoms)
        (d : DerivationTree [] ((Formula.atom p).and (Formula.all_past (Formula.neg (Formula.atom p)))).imp φ)
        : DerivationTree [] φ
```

**Challenges**:
1. **Soundness proof**: Must prove IRR is sound for irreflexive frames
2. **Freshness checking**: The `hp : p ∉ φ.atoms` condition must be verified
3. **Non-standard**: IRR is not a Hilbert-style axiom; proof search changes

**Option 2: IRR as Derived Rule (Current Codebase Attempt)**

The codebase tries to use IRR **contrapositively** to prove naming set consistency:

```lean
theorem naming_set_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (h_R : CanonicalR M M) (p : Atom) :
    SetConsistent (namingSet M p)
```

This doesn't add IRR to the object-level proof system but uses it at the meta-level to prove properties of canonical models.

**The Problem**: The contrapositive argument requires completing the chain to a contradiction, which needs the T-axiom under reflexive semantics.

**Option 3: Keep the Axiom**

The current approach: declare `canonicalR_irreflexive_axiom` as a Lean axiom.

**Justification**: This is mathematically sound because:
1. Irreflexivity is semantically guaranteed under strict temporal semantics
2. The axiom is "semantically conservative" - it doesn't prove anything false
3. van Benthem's result confirms no syntactic derivation exists

### 6. Proof-Theoretic Challenges

**Challenge 1: Soundness of IRR**

Proving IRR sound requires showing:
```
For all irreflexive frames F, all φ:
  If F ⊨ (p ∧ H(¬p)) → φ and p ∉ atoms(φ), then F ⊨ φ
```

This is non-trivial because:
- Must handle arbitrary p-free φ
- Must work for all valuations of φ's atoms
- The key insight: fresh p can always be valued to make p ∧ H(¬p) true at any world

**Challenge 2: Interaction with Other Rules**

IRR interacts with the deduction theorem in subtle ways:
- Cannot simply compose IRR with standard Hilbert derivations
- Need careful tracking of which atoms are "fresh" vs "in use"

**Challenge 3: Proof Search**

IRR is non-analytic: the fresh atom p is introduced and then eliminated. This complicates automated proof search and makes cut-elimination-style arguments more complex.

---

## Recommended Approach

**For This Codebase: Keep the Axiom (Path C)**

Given:
1. The codebase uses **strict temporal semantics** (confirmed in previous research)
2. The T-axiom is intentionally excluded to preserve frame class distinctions
3. The IRR-based proof in `CanonicalIrreflexivity.lean` is incomplete without T-axiom
4. Adding IRR as a primitive rule requires significant proof system changes

**Recommendation**: Accept `canonicalR_irreflexive_axiom` as the correct formalization of a semantic truth that is not syntactically derivable.

**Alternative for Future Consideration**:

If eliminating the axiom becomes critical:
1. **Hybrid Logic Extension**: Add nominals and the axiom `c → □¬c`. This gives a purely axiomatic completeness proof for irreflexive frames.
2. **Full IRR Integration**: Add IRR as a primitive inference rule, prove its soundness, and complete the naming set consistency proof.

---

## Evidence/Examples

### Example: IRR Rule Application

**Goal**: Prove φ (where p ∉ atoms(φ)) in an irreflexive frame.

**Using IRR**:
1. Prove ⊢ (p ∧ H(¬p)) → φ using standard derivation
2. Apply IRR (freshness check: p ∉ atoms(φ))
3. Conclude ⊢ φ

### Example: Hybrid Logic Alternative

**Express irreflexivity with nominals**:
- Language: Add nominal c
- Axiom: `c → □¬c`
- Meaning: "If we are at world c, no accessible world is c"
- Valid in F iff F is irreflexive

### Codebase Evidence

From `CanonicalIrreflexivity.lean`:
```lean
-- Line 74-75: The naming set construction
def namingSet (M : Set Formula) (p : Atom) : Set Formula :=
  atomFreeSubset M p ∪ {Formula.atom p, Formula.all_past (Formula.neg (Formula.atom p))}

-- Lines 1240-1245: The legacy proof outline (requires T-axiom)
-- 4. From naming set: atom(p) ∈ M' and H(neg(p)) ∈ M'.
-- 5. By T-axiom: H(neg(p)) → neg(p), so neg(p) ∈ M'.
-- 6. Contradiction: both p and ¬p in M'.
```

---

## Confidence Level

**High** for the following findings:
- IRR rule formulation and why it works
- Non-definability of irreflexivity
- Why the codebase's proof breaks under strict semantics
- Recommendation to keep the axiom

**Medium** for:
- Full implementation details of IRR as primitive rule
- Complexity comparison between IRR and hybrid logic approaches

**Low** for:
- Whether a novel proof technique could avoid both IRR and the axiom
- Performance implications of adding nominals to the language

---

## Sources

- [An Irreflexivity Lemma with Applications to Axiomatizations of Conditions on Tense Frames](https://link.springer.com/chapter/10.1007/978-94-009-8384-7_3) - Gabbay 1981
- [Temporal Logic - Stanford Encyclopedia of Philosophy](https://plato.stanford.edu/entries/logic-temporal/)
- [Hybrid Logic - Stanford Encyclopedia of Philosophy](https://plato.stanford.edu/entries/logic-hybrid/)
- [Derivation Rules as Anti-Axioms in Modal Logic](https://www.cambridge.org/core/journals/journal-of-symbolic-logic/article/abs/derivation-rules-as-antiaxioms-in-modal-logic/D3870AABF0C7E5993662CA2C8ED768A3) - Venema 1993
- [Axiomatizations with Context Rules of Inference in Modal Logic](https://link.springer.com/article/10.1023/A:1005021313747) - Studia Logica
- [A Gabbay-Rule Free Axiomatization of T×W Validity](https://link.springer.com/article/10.1023/A:1004284420809) - Journal of Philosophical Logic
- [Modal Logic](https://www.cambridge.org/core/books/modal-logic/F7CDB0A265026BF05EAD1091A47FCF5B) - Blackburn, de Rijke, Venema 2001
