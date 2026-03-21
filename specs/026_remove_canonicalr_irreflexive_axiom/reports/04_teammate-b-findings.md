# Teammate B Findings: Implications of Switching to Reflexive Semantics for G and H

**Date**: 2026-03-21
**Focus**: Dense vs Discrete Frame Distinction Under Reflexive Semantics

---

## Key Findings

### 1. Dense vs Discrete Frame Distinction Under Reflexive Semantics

**Critical Finding**: Under reflexive semantics, the density axiom `Fφ → FFφ` becomes **trivially valid on ALL frames**, destroying the ability to distinguish dense from discrete frames.

**Analysis**:

Under **strict semantics** (`F(φ)` means "φ at some strictly future time s > t"):
- The density axiom `Fφ → FFφ` requires an intermediate witness
- If `F(φ)` holds at t with witness s > t, then `FF(φ)` requires s' with t < s' < s where `F(φ)` holds at s'
- This genuinely requires DenselyOrdered: ∀t < s, ∃u, t < u < s
- The axiom **characterizes** dense frames (valid on dense frames, invalid on discrete frames)

Under **reflexive semantics** (`F(φ)` means "φ at some time s ≥ t"):
- `F(φ)` at t can be witnessed by s = t (reflexive case)
- If `F(φ)` holds at t, witnessed by s = t (where φ holds now)
- Then `F(F(φ))` holds trivially: witnessed by s' = t, where `F(φ)` holds at t
- **No intermediate point needed** - the present witnesses itself
- The axiom becomes **trivially valid on ALL frames**

**Formal Demonstration**:

Let M be ANY model with reflexive semantics. Let t be any time where `F(φ)` holds.
- `F(φ)` at t means: ∃s ≥ t, φ holds at s
- For `FF(φ)` at t: need ∃s' ≥ t, `F(φ)` holds at s'
- Choose s' = t. By assumption, `F(φ)` holds at t.
- Therefore `FF(φ)` holds at t.

This makes `Fφ → FFφ` valid on **all** reflexive frames, regardless of density.

### 2. Proof-Theoretic Distinguishability

**Question**: Can a proof system using reflexive G/H still prove theorems that hold on discrete but not dense frames?

**Answer**: **NO** - the logic collapses.

Under reflexive semantics, the following axioms become trivially valid or derivable on ALL frames:

| Axiom | Meaning | Status Under Reflexive Semantics |
|-------|---------|----------------------------------|
| `Fφ → FFφ` (Density) | Future of future is reachable | **Trivially valid** (witness s = t) |
| `F(⊤)` (Seriality) | There exists a future time | **Trivially valid** (witness s = t) |
| `G(φ) → φ` (T-axiom) | What holds always holds now | **Valid** (by semantics) |

**The Seriality Problem**:

Under strict semantics:
- `F(⊤)` requires a strictly future time s > t to exist
- This is valid only on frames with NoMaxOrder

Under reflexive semantics:
- `F(⊤)` is witnessed by s = t for any time t
- Valid on ALL frames, even those with a maximum element

**Distinguishing Formulas Under Reflexive Semantics**:

The classic distinguishing formula for discreteness is the **discreteness forward axiom (DF)**:
```
(F⊤ ∧ φ ∧ Hφ) → F(Hφ)
```

This says: "If there's a future, and φ holds now and always held before, then there's a future moment where Hφ holds."

Under reflexive semantics:
- `F⊤` becomes trivially true (witness t itself)
- But the core content still requires the discrete structure
- However, the premise becomes weaker, affecting validity

**Conclusion**: Reflexive semantics severely diminishes the ability to distinguish frame classes. Dense vs discrete distinction requires strict semantics to maintain logical content.

### 3. Frame Correspondence Changes

**Standard Axioms Under Both Semantics**:

| Axiom | Strict Semantics | Reflexive Semantics |
|-------|------------------|---------------------|
| **T**: `G(φ) → φ` | NOT valid (future excludes now) | VALID (semantically built-in) |
| **4**: `G(φ) → GG(φ)` | Valid (transitivity) | Valid (transitivity) |
| **D**: `G(φ) → F(φ)` | Valid (if ∃ future) | Trivially valid |
| **B**: `φ → GF(φ)` | Valid (depends on structure) | Valid |
| **Density**: `Fφ → FFφ` | Characterizes dense frames | Trivially valid on ALL |
| **Seriality**: `F(⊤)` | Requires NoMaxOrder | Trivially valid on ALL |

**The T-Axiom Problem**:

Under reflexive semantics, `G(φ) → φ` is **analytically true**:
- `G(φ)` at t means: ∀s ≥ t, φ holds at s
- In particular, φ holds at s = t (since t ≥ t)
- Therefore `G(φ) → φ` is valid by definition

This is why the codebase intentionally uses strict semantics: the T-axiom would be trivially true, making it impossible to characterize reflexivity as a frame property (since it would hold on ALL frames).

**What Replaces the Distinction?**:

Under reflexive semantics, the only way to maintain frame class distinctions is through:

1. **Additional frame-theoretic axioms**: Explicitly stating `DenselyOrdered` or `SuccOrder` conditions
2. **Hybrid extensions**: Using nominals or other devices that can refer to specific times
3. **Metric temporal logic**: Using time-bounded operators like `F_{<ε}(φ)`

The pure modal approach loses its power to characterize frame properties like density.

### 4. Standard Practice in Major Temporal Logics

**Survey of Temporal Logics**:

| Logic | Semantics | Rationale |
|-------|-----------|-----------|
| **LTL** (Linear Temporal Logic) | **Reflexive** | Computer science standard; `G(φ)` = "φ now and always" |
| **CTL** (Computation Tree Logic) | **Reflexive** | State-based; current state counts as reachable |
| **Priorean Tense Logic** | **Strict** (traditionally) | Philosophical; distinguishes "now" from "future" |
| **US Logic** (Until-Since) | **Strict** | More expressive; strict versions more powerful |
| **Metric Temporal Logic** | **Varies** | Often reflexive with bounded operators |

**The LTL/CTL Convention**:

In computer science temporal logics (LTL, CTL, CTL*):
- The reflexive convention is standard
- `G(φ)` means "φ holds in the current state and all future states"
- Fixed-point definition: `G(φ) ↔ (φ ∧ XG(φ))`

However, this convention exists because:
1. These logics operate on **discrete transition systems** (Kripke structures)
2. The `X` (next) operator provides temporal separation
3. Frame class distinctions are not the primary concern

**The Philosophical Logic Convention**:

In philosophical temporal logic (Prior, Kamp, Burgess):
- The strict convention is more common
- Preserves the intuitive distinction: "future" ≠ "now"
- Enables meaningful axiom correspondence for frame properties

**Literature Consensus**:

From the Stanford Encyclopedia of Philosophy:
> "When the precedence relation is assumed reflexive, the fixed point definition of G is: Gφ ↔ (φ ∧ XGφ), but when the precedence is assumed irreflexive, the definition is: Gφ ↔ X(φ ∧ Gφ)."

> "The strict versions of S and U are more expressive than their reflexive counterparts on reflexive temporal orders."

**Conclusion**: There is NO universal consensus. Computer science uses reflexive; philosophical logic prefers strict. The choice depends on the application domain.

### 5. Why ProofChecker Uses Strict Semantics

From `Truth.lean` (lines 10-15):
```
**Strict Temporal Semantics**: As of Task #991, temporal operators G (all_future)
and H (all_past) use STRICT semantics (< instead of ≤), meaning "all strictly
future/past times" rather than "now and all future/past". This simplifies the
canonical model construction by making irreflexivity definitional, eliminates
the need for the T-axiom (Gφ → φ, Hφ → φ), and enables parametric representation
theorems for distinct frame classes (base, dense, discrete).
```

**The Design Rationale**:

1. **Frame Class Parametricity**: The codebase aims to have separate completeness theorems for base, dense, and discrete frame classes. This requires axioms that genuinely characterize these classes.

2. **Irreflexivity by Design**: Under strict semantics, the canonical relation R where `R(M,N)` iff g_content(M) ⊆ N is **automatically irreflexive** at the semantic level, because no MCS M can satisfy s > s.

3. **Non-Trivial Density Axiom**: The density axiom `Fφ → FFφ` is valid precisely on dense frames, not on all frames.

### 6. Formulas Valid on Discrete Reflexive but Not Dense Reflexive Frames

Even under reflexive semantics, some distinctions remain (though weakened):

**Discreteness Forward (DF)**:
```
(F⊤ ∧ φ ∧ Hφ) → F(Hφ)
```

This remains meaningful because:
- It asserts existence of an *immediate* successor where the full past is known
- On dense frames, there's no "next" moment, so Hφ propagation fails
- On discrete frames with immediate successors, the axiom holds

However, under reflexive semantics:
- The `F⊤` premise becomes trivial
- The formula simplifies but the core structure remains

**Atomic Discreteness Formulas**:

The formula characterizing that there's a "next" state:
```
F(φ) ∧ ¬φ → F(φ ∧ H¬φ)
```

This says: if φ holds in the future but not now, there's a first future moment where φ holds.

This is:
- **Valid** on discrete frames (first witness exists)
- **Invalid** on dense frames (no first witness between two distinct points)

This distinction survives reflexive semantics because it's about the *structure between points*, not about whether the present counts.

---

## Recommended Approach

**Keep Strict Semantics** - Switching to reflexive semantics would:

1. **Destroy frame class distinctions**: Density axiom becomes trivially valid
2. **Break the parametric architecture**: Cannot have separate dense/discrete completeness
3. **Require redesign**: Would need alternative mechanisms to characterize frames

**Accept the Axiom (Path C)**: The `canonicalR_irreflexive_axiom` is the correct formalization because:

1. **Strict semantics necessitates it**: Irreflexivity is semantically guaranteed but not syntactically derivable
2. **Modal non-definability**: Van Benthem's theorem proves no modal formula characterizes irreflexivity
3. **Preserves frame distinctions**: Keeping strict semantics preserves the ability to distinguish dense from discrete

---

## Evidence/Examples

### Example 1: Density Trivialization

**Strict semantics** (current):
```
Model M with discrete time ℤ:
- At t = 0: F(p) holds (witnessed by t = 1 where p is true)
- Does FF(p) hold? Need s with 0 < s < 1 where F(p) holds
- No such s exists in ℤ
- Fφ → FFφ is INVALID
```

**Reflexive semantics** (hypothetical):
```
Model M with discrete time ℤ:
- At t = 0: F(p) holds (witnessed by t = 1 where p is true)
- Does FF(p) hold? Need s with 0 ≤ s where F(p) holds
- Take s = 0. F(p) holds at 0 (as assumed)
- FF(p) holds trivially
- Fφ → FFφ is VALID (even on discrete frames!)
```

### Example 2: T-Axiom Triviality

**Strict semantics**:
```
G(φ) at t = "∀s > t, φ holds at s"
Does G(φ) → φ hold?
- G(φ) says nothing about t itself
- φ might not hold at t
- T-axiom is NOT valid (characterizes reflexive frames)
```

**Reflexive semantics**:
```
G(φ) at t = "∀s ≥ t, φ holds at s"
Does G(φ) → φ hold?
- G(φ) implies φ at s = t (since t ≥ t)
- T-axiom is TRIVIALLY valid (on all frames)
```

### Example 3: Seriality Trivialization

**Strict semantics**:
```
F(⊤) at t = "∃s > t"
Valid only when there's a strictly greater element
Characterizes NoMaxOrder
```

**Reflexive semantics**:
```
F(⊤) at t = "∃s ≥ t"
Always valid: witness s = t
Trivial on ALL frames
```

---

## Confidence Level

**HIGH** for the following findings:
- Density axiom becomes trivial under reflexive semantics
- T-axiom becomes trivial under reflexive semantics
- Strict semantics is necessary for frame class parametricity
- No consensus in literature (domain-dependent choice)

**MEDIUM** for:
- Whether hybrid extensions could recover distinctions under reflexive semantics
- Whether alternative axiom schemas could characterize density reflexively

**LOW** for:
- Complete enumeration of all formulas distinguishing frame classes
- Performance/complexity implications of alternative approaches

---

## Summary

Switching from strict to reflexive semantics would fundamentally compromise the codebase's ability to distinguish frame classes. The density axiom `Fφ → FFφ` and seriality `F(⊤)` become trivially valid on ALL frames under reflexive semantics, not just on their intended frame classes.

The strict semantics design is intentional and mathematically motivated:
1. It preserves frame correspondence for density/discreteness
2. It enables separate completeness theorems for different frame classes
3. It aligns with philosophical temporal logic tradition

The cost of strict semantics is that irreflexivity becomes semantically guaranteed but not syntactically derivable. The `canonicalR_irreflexive_axiom` is the correct formalization of this semantic truth.

---

## Sources

- [Temporal Logic (Stanford Encyclopedia of Philosophy)](https://plato.stanford.edu/entries/logic-temporal/)
- [Modal Logic (Stanford Encyclopedia of Philosophy)](https://plato.stanford.edu/entries/logic-modal/)
- [Linear Temporal Logic - Wikipedia](https://en.wikipedia.org/wiki/Linear_temporal_logic)
- [Temporal Logic - Wikipedia](https://en.wikipedia.org/wiki/Temporal_logic)
- [A Survey on Temporal Logics (Konur 2010)](https://arxiv.org/pdf/1005.3199)
- [Modal and temporal logic lecture notes (Bezhanishvili, Hodkinson, Kupke)](https://staff.fnwi.uva.nl/n.bezhanishvili/ML-2016/ML-slides.pdf)
- [Frame Definability (Open Logic Project)](https://builds.openlogicproject.org/content/normal-modal-logic/frame-definability/frame-definability.pdf)
- [Tense or Temporal Logic (Muller)](https://d-nb.info/1114824291/34)
