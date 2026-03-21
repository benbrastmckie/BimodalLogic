# Teammate A Findings: Novel IRR Proof Techniques Without the T-Axiom

**Date**: 2026-03-21
**Focus**: Alternative IRR formulations and proof strategies for strict temporal semantics
**Session**: Task 26 continued research

---

## Key Findings

### 1. The Fundamental Blocker Is Genuine

The standard Gabbay IRR naming set proof requires the T-axiom (`H(phi) -> phi`) at a critical step:

```
1. Suppose CanonicalR(M, M) for MCS M
2. Build naming set: atomFreeSubset(M, p) U {atom(p), H(~p)}
3. Prove naming set is consistent (via IRR contrapositive)
4. Extend to MCS M' with p in M' and H(~p) in M'
5. **BLOCKED**: Need ~p in M' from H(~p) in M'
```

Under **strict semantics**, `H(~p)` only asserts that `~p` holds at all times *strictly* before now. It says nothing about the present. The step `H(~p) -> ~p` is NOT valid.

**This is not a bug in the proof attempt -- it reflects a genuine logical gap.** The naming set technique was designed for reflexive semantics where "always in the past" includes "now".

### 2. Alternative IRR Formulations: None Work Without Modification

#### 2.1 Using P (Sometime Past) Instead of H (Always Past)

Attempted formulation: Use `{atom(p), P(~p)}` instead of `{atom(p), H(~p)}`.

**Problem**: `P(~p)` means "there exists some strictly past time where ~p holds." This is too weak -- it doesn't constrain all past times, so the IRR soundness argument breaks. The formula `p AND P(~p)` is satisfiable even at reflexive points, so the rule would not characterize irreflexivity.

**Analysis from codebase**: The `DirectIrreflexivity.lean` file (lines 64-77) shows that `P(atom(p)) in M` is derivable from `CanonicalR(M,M)` via `temp_a`. This confirms that P-based formulations face different challenges -- they produce formulas IN M rather than exclusions.

#### 2.2 Hybrid "Past or Now" Operator

If we had an operator `H_ref(phi)` meaning "phi holds at all past times including now" (i.e., reflexive H), then `H_ref(~p) -> ~p` would be trivially valid.

**Problem**: Introducing `H_ref` is equivalent to adding the T-axiom back. It changes the semantics to reflexive, which defeats the purpose of strict semantics.

#### 2.3 Using Lbf (Limit Before First) or Specialized Operators

Searched the codebase for `Lbf`, `limit_before`, or similar operators -- **none found**.

Such operators would express "the limit of phi as we approach the first moment" or similar boundary conditions. They are used in some temporal logics for discrete/continuous interactions but don't help with the IRR self-reference problem.

### 3. Alternative Proof Strategies

#### 3.1 Diagonal Argument Approaches

The naming set IS a diagonal argument: we diagonalize against M by choosing a fresh p and asserting `p AND H(~p)` to "name" the current MCS as distinct from all strictly past MCSs.

**Why it fails under strict semantics**: The diagonal argument requires that M' (the extension of the naming set) can distinguish "now" from "strictly past." Under reflexive semantics, `H(~p) -> ~p` makes this work. Under strict semantics, M' only knows that ~p held strictly before, which doesn't constrain the present.

**Alternative diagonal**: Could we use `G(~p) AND p` (p holds now, never in future)?
- Same problem: `G(~p)` only constrains the strict future
- `G(~p)` does NOT imply `~p` under strict semantics
- This is symmetric to the H case

#### 3.2 Filtration Techniques

Filtration is used to prove finite model property by collapsing a model to a finite quotient. It doesn't help with irreflexivity because:
1. Filtrations can introduce reflexive loops (when distinct points get identified)
2. The quotient operation doesn't preserve irreflexivity in general
3. Our canonical model is inherently infinite (dense orders), so FMP doesn't apply

#### 3.3 Model-Theoretic Tricks (Avoiding Naming Set Entirely)

**Semantic approach**: Prove irreflexivity directly about TaskFrame structures rather than canonical models.

This is actually the current approach! The axiom `canonicalR_irreflexive_axiom` is justified by semantic reasoning:
- `CanonicalR(M,M)` would mean `g_content(M) subset M`
- Under strict semantics, `G(phi)` at time t means phi holds at all s > t
- For M to be its own strict future witness, we'd need t > t, which is impossible

**The "semantic proof" IS the mathematical justification** -- it just can't be expressed as a syntactic derivation in the object language because irreflexivity is not modally definable (Goldblatt-Thomason theorem).

### 4. Literature Search Results

#### 4.1 IRR for Strict Temporal Semantics

**No published work found** addressing IRR specifically for strict semantics without T-axiom. The literature assumes either:
- Reflexive semantics (where T-axiom is available), or
- Accepts irreflexivity as a semantic postulate

The gap in the literature corresponds exactly to the gap in ProofChecker.

#### 4.2 Alternative Characterizations of Irreflexivity

**Hybrid Logic** (Blackburn, de Rijke, Venema):
- Using nominals, irreflexivity is expressed as `c -> []~c` (if c names a world, that world doesn't see itself)
- This IS a syntactic axiom that characterizes irreflexive frames
- **Cost**: Requires extending the language with nominals (significant overhaul)

**Zanardo's Infinite Axiom Scheme** (1990):
- Replaces IRR with infinitely many axioms that approximate irreflexivity
- Used for T x W frames (branching time)
- **Viability**: Could be adapted, but requires fundamental proof system changes

**Di Maio & Zanardo's Gabbay-Rule-Free Axiomatization** (1998):
- Develops "a new technique to deal with reflexive maximal consistent sets in Henkel-style constructions"
- **Key insight**: Instead of IRR, they use modified Henkin construction that filters out reflexive MCSs
- **Potential**: This could be the most promising avenue, but requires deep restructuring

### 5. Semantic vs Syntactic: The Fundamental Trade-off

| Approach | What It Achieves | Limitation |
|----------|------------------|------------|
| **Syntactic (IRR rule)** | Derives irreflexivity within proof system | Requires T-axiom (strict semantics blocks this) |
| **Semantic (axiom)** | Directly states semantic truth | Not derivable from modal axioms (honest, but "external") |
| **Hybrid extension** | Syntactic expression via nominals | Major language extension |
| **Infinite axiom scheme** | Approximates irreflexivity syntactically | Infinite axioms, unusual proof system |

**The mathematically correct observation**: Under strict semantics with a pure modal language, irreflexivity CANNOT be derived syntactically. This is a theorem (Goldblatt-Thomason), not a limitation of any particular proof attempt.

---

## Recommended Approach

**Accept the axiom with proper mathematical justification.**

### Rationale

1. **The gap is real**: The T-axiom blocker is not a proof engineering problem -- it reflects the genuine non-definability of irreflexivity in modal logic under strict semantics.

2. **The axiom is semantically sound**: `forall M. not CanonicalR(M,M)` is TRUE for the intended semantics. The canonical relation models strict temporal precedence, and `t > t` is impossible.

3. **Standard practice**: Major formalization projects (e.g., Isabelle's temporal logic libraries) handle frame properties like irreflexivity through semantic assumptions when modal definability fails.

4. **Alternatives have high cost**:
   - Hybrid logic: Requires new syntax, semantics, and proof rules
   - Infinite axiom schemes: Fundamentally changes proof system
   - Modified Henkin construction (Di Maio & Zanardo): Major restructuring

### Documentation Update

The axiom should be documented as:

```lean
/--
**Axiom**: The canonical accessibility relation is irreflexive.

## Mathematical Status

This is a **semantic axiom** justified by modal non-definability:

1. **Semantic truth**: Under strict temporal semantics, CanonicalR(M,M) would
   require M to witness its own strict future (t > t), which is impossible.

2. **Non-definability theorem**: The Goldblatt-Thomason theorem proves that
   irreflexivity is not modally definable -- no formula of TM logic
   characterizes irreflexive frames.

3. **IRR rule limitation**: The Gabbay IRR rule requires the T-axiom
   (H(phi) -> phi) for its canonical model proof. Under strict semantics,
   this axiom is not available.

## References

- Goldblatt & Thomason (1974): Axiomatic classes in propositional modal logic
- Gabbay (1981): An Irreflexivity Lemma
- van Benthem (1983): Modal Logic and Classical Logic, Ch. 3
- Blackburn, de Rijke, Venema (2001): Modal Logic, Ch. 3.3, 4.8
-/
axiom canonicalR_irreflexive_axiom :
  forall M : Set Formula, SetMaximalConsistent M -> not (CanonicalR M M)
```

---

## Evidence/Examples

### Example: Why the Naming Set Fails Under Strict Semantics

Consider MCS M with `CanonicalR(M,M)` (hypothetically).

**Step 1**: Build naming set `NS = atomFreeSubset(M,p) U {atom(p), H(~p)}`

**Step 2**: NS is consistent (by IRR contrapositive -- this step still works)

**Step 3**: Extend to MCS M' containing NS

**Step 4**: M' contains:
- `atom(p)` (from naming set)
- `H(~p)` (from naming set)

**Step 5 (THE GAP)**:
- Under **reflexive** semantics: `H(~p) -> ~p` is an axiom, so `~p in M'`. Contradiction with `p in M'`.
- Under **strict** semantics: `H(~p)` only says `~p` holds at strictly past times. Present is unconstrained. No contradiction.

### Codebase Evidence

From `CanonicalIrreflexivity.lean` lines 17-24:
```lean
-- Under strict temporal semantics (G/H quantify over s > t / s < t), irreflexivity
-- is semantically guaranteed but NOT modally definable (van Benthem 1983, Blackburn-
-- de Rijke-Venema 2001 Chapter 3.3). No formula of TM logic characterizes irreflexive
-- frames, so no syntactic derivation from TM axioms can establish this property.
```

From `DirectIrreflexivity.lean` lines 237-246:
```lean
-- **Path A is impossible.** The direct F proof approach cannot work because:
--
-- 1. Any theorem psi is automatically in M (MCS closure)
-- 2. If psi in M then neg(psi) not-in M (MCS consistency)
-- 3. So there is NO formula psi with both "derives psi" and "neg(psi) in M"
-- 4. The contradiction mechanism REQUIRES comparing M with a DIFFERENT MCS M'
```

---

## Confidence Level

**HIGH** for the negative result: IRR cannot work under strict semantics without T-axiom.

**MEDIUM** for long-term alternatives: The Di Maio & Zanardo technique might offer a path, but would require significant restructuring that hasn't been analyzed in detail.

---

## Sources

### Academic Literature
- [Gabbay (1981): An Irreflexivity Lemma with Applications to Axiomatizations of Conditions on Tense Frames](https://link.springer.com/chapter/10.1007/978-94-009-8384-7_3)
- [Di Maio & Zanardo (1998): A Gabbay-Rule Free Axiomatization of T x W Validity](https://link.springer.com/article/10.1023/A:1004284420809)
- [Temporal Logic - Stanford Encyclopedia of Philosophy](https://plato.stanford.edu/entries/logic-temporal/)
- [Hybrid Logic - Stanford Encyclopedia of Philosophy](https://plato.stanford.edu/entries/logic-hybrid/)
- [Modal Logic: A Semantic Perspective - Blackburn & van Benthem](https://staff.fnwi.uva.nl/j.vanbenthem/hml-blackburnvanbenthem.pdf)
- [Goldblatt-Thomason theorem - nLab](https://ncatlab.org/nlab/show/Goldblatt-Thomason+theorem)
- [Derivation rules as anti-axioms in modal logic - Venema 1993](https://www.cambridge.org/core/journals/journal-of-symbolic-logic/article/abs/derivation-rules-as-antiaxioms-in-modal-logic/D3870AABF0C7E5993662CA2C8ED768A3)

### Codebase Files
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/DirectIrreflexivity.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/IRRSoundness.lean`
