# Research Report: Task #26 — Modal Non-Definability, Completeness, and the Gabbay IRR Rule

**Task**: remove_canonicalr_irreflexive_axiom
**Date**: 2026-03-21
**Mode**: Team Research (3 teammates)
**Session**: sess_1774122843_895759
**Focus**: What does modal non-definability of irreflexivity mean for completeness? Is the Gabbay IRR rule viable?

---

## Summary

All three research angles converge on a clear theoretical picture. Irreflexivity is provably not modally definable (Goldblatt-Thomason theorem), meaning **no set of modal axioms can characterize the class of irreflexive frames**. Despite this, complete axiomatizations for irreflexive semantics *do* exist through three mechanisms: (1) the Gabbay IRR inference rule, (2) hybrid logic with nominals, or (3) infinite axiom schemes. However, for ProofChecker's strict temporal semantics over dense linear orders, implementing the IRR rule faces a **fundamental blocker**: the canonical model proof requires the T-axiom (`H(φ) → φ`) which was intentionally excluded to preserve frame class distinctions.

---

## Key Findings

### 1. Modal Non-Definability: A Proven Theorem (Teammate A)

The **Goldblatt-Thomason Theorem** (1974) provides necessary and sufficient conditions for modal definability. Irreflexivity fails because:

- **Ultrafilter extension reflection fails**: Ultrafilter extensions can introduce reflexive points where none existed
- **Bisimulation invariance fails**: Two bisimilar models can differ on reflexivity at corresponding points

Since modal formulas cannot distinguish bisimilar structures (van Benthem's Theorem), **no modal formula can express irreflexivity**. This is not a limitation of any particular proof system — it is a mathematical theorem about the expressive power of modal logic.

**Consequence**: Any attempt to axiomatize irreflexivity using only Hilbert-style axioms (schemas + Modus Ponens + Necessitation) is provably impossible. This places irreflexivity entirely outside Sahlqvist correspondence theory.

### 2. How GL Achieves Completeness Without an Irreflexivity Axiom (Teammate B)

**GL (Gödel-Löb Logic)** is the paradigm example of a complete logic for irreflexive frames:

| Component | GL | ProofChecker's Temporal Logic |
|-----------|-----|-------------------------------|
| Frame class | Transitive, converse well-founded | Strict linear orders (irreflexive, transitive, connected, dense) |
| Key axiom | Löb: `□(□φ → φ) → □φ` | None available |
| Technique | Tree unraveling of canonical model | Canonical model + saturation |
| Finite model property | **Yes** | **No** (dense orders are infinite) |

GL's technique works because:
1. The Löb axiom semantically forces converse well-foundedness
2. In **finite** models, converse well-foundedness = irreflexivity
3. GL has the finite model property, so restricting to finite models loses no theorems

**This technique does NOT transfer** to ProofChecker because:
- No Löb-like axiom is available for strict temporal semantics
- Dense linear orders require infinite models (no FMP)
- The canonical model cannot be tree-unraveled in the same way

### 3. The Gabbay IRR Rule: Formulation and Viability (Teammate C)

**Precise formulation** (Gabbay 1981):

```
IRR: If ⊢ (p ∧ H(¬p)) → φ, and p ∉ atoms(φ), then ⊢ φ
```

Equivalently: `If {p, H(¬p)} ∪ Γ ⊢ φ for fresh p, then Γ ⊢ φ`

**Why it works**: On an irreflexive frame, for any world w, we can consistently set `V(p,w) = true` and `V(p,v) = false` for all v < w. The freshness condition ensures φ's truth value is independent of p's valuation. The rule is **sound** because `p ∧ H(¬p)` is satisfiable at every world in every irreflexive frame.

**The fundamental blocker for ProofChecker**:

The codebase already has ~1200 lines in `CanonicalIrreflexivity.lean` attempting the IRR-based proof. The construction proceeds:

1. Suppose `CanonicalR(M, M)` for some MCS M
2. Build naming set: `atomFreeSubset(M, p) ∪ {atom(p), H(¬p)}`
3. Prove naming set is consistent (using IRR contrapositively)
4. Extend to MCS M' containing both `p` and `H(¬p)`
5. **Need**: Derive `¬p ∈ M'` from `H(¬p) ∈ M'`
6. Under **reflexive** semantics: T-axiom gives `H(¬p) → ¬p`, done
7. Under **strict** semantics: `H(¬p)` only constrains strictly past times — **cannot derive ¬p**

**This is not a bug in the proof attempt — it reflects a genuine logical gap**. Under strict semantics, "always in the past" does not include "now", so the naming set cannot generate the required contradiction.

### 4. Three Viable Paths Forward

| Path | Approach | Language Change | Proof System Change | Viability |
|------|----------|-----------------|---------------------|-----------|
| **A** | Gabbay IRR as primitive rule | None needed | Add inference rule to `DerivationTree` | Medium — requires soundness proof + new proof technique for strict semantics |
| **B** | Hybrid logic with nominals | Add nominal sort | Add satisfaction operators + axiom `c → □¬c` | Medium — significant language extension |
| **C** | Keep the axiom | None | None | High — mathematically sound, honest about non-definability |

---

## Synthesis

### Conflicts Resolved

**No significant conflicts.** All three teammates agree on the theoretical picture:
- Irreflexivity is provably not modally definable (unanimous, high confidence)
- GL's technique does not transfer (unanimous)
- The T-axiom blocker is genuine (unanimous)

**Minor divergence**: Teammate B rates IRR as "Medium-High viability" while Teammates A and C rate it lower. Resolution: IRR is theoretically principled but faces a **concrete implementation blocker** (the strict-semantics gap in step 5-7 above). The rule itself is sound, but completing the canonical model proof requires either:
- (a) A novel proof technique that avoids needing `H(¬p) → ¬p`, or
- (b) An alternative use of IRR that doesn't go through the naming set construction

### Gaps Identified

1. **Novel proof techniques**: Is there a way to use IRR under strict semantics that avoids the T-axiom dependency? No teammate found existing literature addressing this specific combination.

2. **Infinite axiom scheme**: Zanardo (1990) showed strict temporal logic can be axiomatized without IRR using infinitely many axioms. This approach was mentioned but not deeply investigated.

3. **The Di Maio & Zanardo approach**: A Gabbay-rule-free axiomatization of T×W validity exists. Its applicability to the ProofChecker's specific frame class was not fully assessed.

### The Mathematically Correct Path Forward

The user asked for "the most mathematically correct path forward." The answer depends on what "correct" means:

**If "correct" means "no axioms beyond what the proof system can derive"**:
→ Path A (IRR rule) is the principled answer, but it requires solving the strict-semantics gap — an open problem for this specific frame class. The rule itself needs no language changes (fresh atoms already exist), but it does require extending the proof system beyond pure Hilbert-style.

**If "correct" means "mathematically sound and honest about limitations"**:
→ Path C (keep the axiom) is the best answer. The axiom states a semantic truth (`∀M. ¬CanonicalR(M,M)`) that is:
- Guaranteed by the strict ordering semantics
- Provably not derivable from any modal axioms (Goldblatt-Thomason)
- Standard practice in the literature when IRR is not available

**If "correct" means "eliminate the axiom with a purely axiomatic system"**:
→ Path B (hybrid logic with nominals) achieves this. The formula `c → □¬c` directly expresses irreflexivity when `c` is a nominal. This converts the semantic postulate into a syntactic axiom — but at the cost of extending the language significantly.

### Recommendations

1. **Short term**: Keep `canonicalR_irreflexive_axiom` with documentation citing Goldblatt-Thomason and the strict-semantics gap as justification. This is mathematically honest and standard practice.

2. **Medium term**: Investigate whether a novel proof technique can use IRR under strict semantics without the T-axiom. This is a genuine research question.

3. **Long term**: If the proof system is ever extended to hybrid logic (nominals), irreflexivity becomes axiomatizable and the Lean axiom can be eliminated.

---

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|-----------------|
| A | Modal definability theory | completed | high | Goldblatt-Thomason analysis, bisimulation witness |
| B | Complete axiom systems (GL, Grz) | completed | high | GL technique analysis, why it doesn't transfer |
| C | Gabbay IRR rule implementation | completed | high | Precise formulation, strict-semantics blocker identification |

---

## References

### Primary Sources
- Goldblatt & Thomason (1974). Axiomatic classes in propositional modal logic
- Gabbay, D.M. (1981). An Irreflexivity Lemma with Applications to Axiomatizations of Conditions on Tense Frames
- van Benthem, J. (1983). Modal Logic and Classical Logic
- Blackburn, de Rijke, Venema (2001). Modal Logic, Ch. 3.3, 4.8
- Segerberg, K. (1971). An Essay in Classical Modal Logic
- Solovay, R. (1976). Provability interpretations of modal logic
- Zanardo (1990). Gabbay-rule-free axiomatization

### Online Resources
- [Provability Logic — Stanford Encyclopedia of Philosophy](https://plato.stanford.edu/entries/logic-provability/)
- [Temporal Logic — Stanford Encyclopedia of Philosophy](https://plato.stanford.edu/entries/logic-temporal/)
- [Hybrid Logic — Stanford Encyclopedia of Philosophy](https://plato.stanford.edu/entries/logic-hybrid/)
- [Goldblatt-Thomason theorem — nLab](https://ncatlab.org/nlab/show/Goldblatt-Thomason+theorem)
- [Derivation rules as anti-axioms — Venema 1993](https://www.cambridge.org/core/journals/journal-of-symbolic-logic/article/abs/derivation-rules-as-antiaxioms-in-modal-logic/D3870AABF0C7E5993662CA2C8ED768A3)
- [A Gabbay-Rule Free Axiomatization of T×W Validity](https://link.springer.com/article/10.1023/A:1004284420809)
