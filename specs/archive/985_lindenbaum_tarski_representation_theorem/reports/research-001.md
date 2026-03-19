# Research Report: Lindenbaum-Tarski Algebraic Representation Theorem

**Task**: 985 — Develop Lindenbaum-Tarski algebraic representation theorem approach
**Date**: 2026-03-17
**Mode**: Team Research (2 teammates)
**Session**: sess_1773709815_8170ec

---

## Summary

The project already has a substantial, entirely sorry-free algebraic infrastructure for the
Lindenbaum-Tarski approach in `Theories/Bimodal/Metalogic/Algebraic/`. The existing
`algebraic_representation_theorem` proves `AlgSatisfiable φ ↔ AlgConsistent φ` (an ultrafilter
of the Lindenbaum algebra contains [φ] iff ¬φ is not provable). However, this does NOT yet
establish a representation theorem that connects to Kripke frame semantics over linear orders.

The research identifies a clear 5-phase path for task 985: construct a canonical Stone-style
Kripke frame from ultrafilters, prove a truth lemma, establish frame condition correspondences,
and derive completeness theorems for all three variants (base, dense, discrete). This approach
**bypasses the domain mismatch problem** that blocks the BFMCS pipeline (tasks 977/978/982) by
avoiding the `TaskFrame` / `D`-indexed architecture entirely.

---

## Key Findings

### What Already Exists (all sorry-free)

| Component | File | What is Proven |
|-----------|------|----------------|
| `LindenbaumAlg` | `LindenbaumQuotient.lean` | Quotient `Formula / ProvEquiv`; lifted neg, imp, and, or, box, G, H |
| `BooleanAlgebra LindenbaumAlg` | `BooleanStructure.lean` | Full Boolean algebra instance |
| G, H, □ as interior operators | `InteriorOperators.lean` | Deflationary, monotone, idempotent via T and 4 axioms |
| MCS ↔ Ultrafilter bijection | `UltrafilterMCS.lean` | `mcsToUltrafilter`, `ultrafilterToSet`, roundtrip lemmas |
| `AlgSatisfiable ↔ AlgConsistent` | `AlgebraicRepresentation.lean` | Main algebraic representation theorem |

### What Is Missing for Full Representation Theorem

1. **Canonical Kripke frame** (`(Ultrafilter LindenbaumAlg, R_G, R_H)`): not yet defined
2. **Truth lemma for the algebraic canonical frame**: `[φ] ∈ U ↔ U ⊨ φ` in the Stone frame
3. **Linearity proof**: the canonical accessibility relation R_G is a strict linear order
4. **Frame condition correspondence**: density axiom (DN) forces R_G dense; discreteness (DF) forces successor structure
5. **Connection to `valid`/`valid_dense`/`valid_discrete`**: the Stone frame belongs to the right class

---

## Mathematical Approach: Jónsson-Tarski / Stone Duality

### Theoretical Foundation

The classical Jónsson-Tarski theorem (1951/52) for Boolean Algebras with Operators (BAOs) states:
every BAO embeds into the complex algebra of its ultrafilter frame. This means the Lindenbaum
algebra (a BAO with operators G, H, □) is fully represented by a canonical Kripke frame whose
worlds are its ultrafilters.

Goldblatt (1976) extended this to descriptive frames, and the connection between Stone duality
(compact Hausdorff totally disconnected spaces = Stone spaces of Boolean algebras) and modal
logic canonical models is by now standard (see Blackburn-de Rijke-Venema, Chapter 5).

### The Canonical Frame Construction

Define the canonical Stone frame:
- **Worlds**: `AlgWorld := Ultrafilter LindenbaumAlg` (already defined in `AlgebraicRepresentation.lean`)
- **Future accessibility**: `R_G U V ↔ ∀ φ, G_quot [φ] ∈ U → [φ] ∈ V`
- **Past accessibility**: `R_H U V ↔ ∀ φ, H_quot [φ] ∈ V → [φ] ∈ U`

Equivalently, using the MCS bijection: `R_G Γ Δ ↔ {φ | Gφ ∈ Γ} ⊆ Δ`

Duality: `R_G U V ↔ R_H V U` (follows from the temporal duality axioms in the proof system).

### Truth Lemma

The algebraic truth function `algTrueAt U φ := [φ] ∈ U.carrier` is already defined.

The full truth lemma states: for any `U : AlgWorld` and formula φ:
```
[φ] ∈ U ↔ U satisfies φ in the algebraic canonical frame
```

Proof by structural induction on φ:
- **Atoms, ⊥, connectives**: Follow directly from ultrafilter properties (a filter is prime / an ultrafilter is an ultrafilter: closed under ∧, closed under ∨ (one side), complement).
- **G-case (→)**: If `[Gφ] ∈ U` and `R_G U V`, then `[φ] ∈ V` by definition of R_G.
- **G-case (←)**: If `[Gφ] ∉ U`, then `[Fφ] ∈ U` (ultrafilter completeness). Construct a **G-witness** V:
  - Take `Σ := {ψ | [Gψ] ∈ U} ∪ {¬φ}`
  - Show Σ is consistent using the K-axiom and [Fφ] ∈ U
  - Extend to MCS V via `set_lindenbaum` (already available in `Core/MaximalConsistent.lean`)
  - V satisfies: `R_G U V` (by construction of Σ) and `[φ] ∉ V` (¬φ ∈ V)

This is the **existential Lindenbaum lemma for modal logic** — the G-witness construction
is the modal-logic version of Henkin witnesses.

### Frame Properties from Algebraic Axioms

Using the interior operator properties already proven:

| Frame Property | Source | Algebraic Fact Already Proven |
|----------------|--------|-------------------------------|
| Reflexivity of R_G | T-axiom `Gφ → φ` | `G_interior.le_self`: `[Gφ] ≤ [φ]` |
| Transitivity of R_G | 4-axiom `Gφ → GGφ` | `G_interior.idempotent`: `G(G(a)) = G(a)` |
| R_G ↔ converse of R_H | Temporal duality axioms | Derivable from duality axioms |

**Reflexivity proof**: From `G_interior.le_self` (G is deflationary): if `[Gφ] ∈ U` then `[φ] ∈ U`
(since `[Gφ] ≤ [φ]` and U is an ultrafilter, hence an upset). So `R_G U U`.

**Transitivity proof**: From `G_interior.idempotent`: `G(G(a)) = G(a)`, so `[G(Gφ)] = [Gφ]`. If
`R_G U V` and `R_G V W`, then for any φ with `[Gφ] ∈ U`: `[Gφ] ∈ U → [φ] ∈ V` (by R_G U V) and
`G_quot [φ] = [Gφ]` (lifting is well-defined), so transitivity follows.

**Linearity** (R_G is a total preorder): This is the **hardest step**. The temporal logic axioms
include linearity principles (e.g., the Diodorean formula or explicit linearity axioms). However,
the exact set of TM axioms that force linearity needs verification. The existing BFMCS approach
handles this through a staged construction; the algebraic approach can leverage the MCS linearity
results already established in the BFMCS infrastructure (since ultrafilters/MCSs are linearly
ordered by the temporal ordering from the BFMCS bundle).

**Recommended strategy**: Use the existing `CanonicalMCS` linear order (established in the Bundle/
approach) to endow the set of ultrafilters with a linear order, then show this order equals R_G.
This is the **hybrid approach** that leverages existing work rather than re-proving linearity.

---

## Frame Condition Correspondence (Dense and Discrete Extensions)

### Dense Completeness

The **density axiom DN**: `Fφ → F(Fφ)` (some_future φ → some_future (some_future φ))

Algebraic identity in LindenbaumAlg: `F_quot(a) ≤ F_quot(F_quot(a))` for all a

When DN is in the proof system, this identity holds in LindenbaumAlg. This forces the
canonical frame to be **densely ordered**:

```
Theorem: If DN ∈ axioms, then ∀ U V : AlgWorld, R_G U V → ∃ W, R_G U W ∧ R_G W V
```

**Proof sketch**: Given `R_G U V`, use DN to build W:
- Take `T(U,V) := {ψ | [Gψ] ∈ U} ∪ {φ | [φ] ∈ V}`
- Show T(U,V) consistent using DN: if `[Fψ] ∈ U` then `[F(Fψ)] ∈ U` (from DN)
- Extend to MCS W; then `R_G U W` and `R_G W V`

This gives: the algebraic canonical frame built from the dense proof system is a **dense linear order**.
No Cantor isomorphism, no TimelineQuot, no domain transfer needed.

### Discrete Completeness

The **discreteness axiom DF**: `(F⊤ ∧ φ ∧ Hφ) → F(Hφ)`

When DF is in the proof system, the canonical frame R_G has a **covering property**
(immediate successor structure):

```
Theorem: If DF ∈ axioms, then ∀ U, ∃ V, R_G U V ∧ ∀ W, R_G U W → R_G V W ∨ V = W
```

**Caution**: This is the most complex case. The canonical frame with DF needs to be shown to
have SuccOrder structure (immediate successors). Teammate B noted that even in the algebraic
approach, this requires establishing that DF forces there are no strict intermediate elements
between adjacent ultrafilters. This is closely related to the `succ_le_of_lt` coverness lemma
that is currently sorry'd in `DiscreteTimeline.lean` (task 974's blocker).

**However**: The algebraic setting may make this easier to prove because the worlds are
abstract ultrafilters rather than the concrete DiscreteTimelineQuot construction. The
characterization is: two ultrafilters U < V are adjacent iff there is no W with U < W < V,
which translates to: the ideal `{[φ] | [φ] ∈ U but [φ] ∉ V}` cannot be extended while
maintaining MCS properties. This is potentially provable using the DF algebraic identity
without the DiscreteTimelineQuot infrastructure.

---

## The Strategic Advantage: Bypassing the Domain Mismatch

### Current BFMCS Pipeline (blocked)

```
Formula not derivable
    → [¬φ] consistent
    → Extend to MCS S₀
    → Build BFMCS over CanonicalMCS
    → ??? [GAP: domain mismatch]
    → Cantor: TimelineQuot ≃o ℚ
    → Truth lemma in dense domain
    → Dense countermodel
```

The gap is: truth lemma proven for D = Int, but density requires D = TimelineQuot ≃o ℚ.

### Algebraic Pipeline (proposed, no domain mismatch)

```
Formula not derivable
    → ¬φ consistent
    → By algebraic_representation_theorem: ∃ ultrafilter U with [¬φ] ∈ U
    → By truth lemma (algebraic): U ⊨ ¬φ in the Stone canonical frame
    → By frame condition theorem: Stone frame is dense (when DN ∈ axioms)
    → Stone frame is a dense linear order
    → valid_dense φ is refuted by the Stone frame
    → Completeness proved
```

**No D-domain, no BFMCS, no TimelineQuot, no Cantor isomorphism needed.** The algebraic
representation theorem already provides the ultrafilter. The truth lemma connects ultrafilter
membership to semantic truth. The frame condition proves the Stone frame is the right type.

---

## Synthesis: Conflicts and Resolutions

### Conflict 1: Stone Frame vs TaskFrame

**Teammate A** (algebraic focus): "The Stone frame avoids TaskFrame entirely — no D type needed."
**Teammate B** (infrastructure focus): "Unclear if Stone frame satisfies the exact TaskFrame interface (nullity_identity, forward_comp, converse)."

**Resolution**: The algebraic approach should NOT attempt to satisfy the `TaskFrame` interface.
Instead, it should define a new, separate **completeness theorem** using the Stone frame semantics
(`algTrueAt`) that is already defined in `AlgebraicRepresentation.lean`. The result would be a
parallel completeness result alongside the BFMCS approach, not a replacement.

This means defining:
- `valid_alg φ := ∀ U : AlgWorld, algTrueAt U φ`
- Proving `valid_alg φ ↔ valid φ` (equivalence with standard validity)

OR simply proving the contrapositive directly:
- If ¬⊢ φ, then ∃ U : AlgWorld such that ¬algTrueAt U φ, and U's frame is a dense/discrete linear order.

### Conflict 2: Linearity via Algebra vs. Leveraging BFMCS

**Teammate A**: Suggests hybrid approach using MCS linear ordering from BFMCS.
**Teammate B**: Emphasizes Stone duality as an independent route.

**Resolution**: The hybrid approach is recommended for the base and dense cases (lower risk).
The pure algebraic linearity proof can be attempted for the discrete case where BFMCS has sorries.
Concretely: use the `CanonicalMCS` partial order (established by BFMCS) to show the ultrafilters
have a linear order compatible with R_G.

### Conflict 3: Discrete Case and Task 974

Both teammates agree: the discrete case faces the same challenge as the existing sorries in
DiscreteTimeline.lean. However, the algebraic approach may make the coverness lemma easier
(working with abstract ultrafilters rather than a concrete timeline quotient).

**Resolution**: Treat discrete completeness as a stretch goal for task 985. Focus the main effort
on base and dense completeness first, then assess whether the algebraic approach actually
simplifies the discrete case.

---

## Recommended Implementation Plan

### Phase 1: Canonical Stone Frame Definition
**New file**: `Theories/Bimodal/Metalogic/Algebraic/StoneCanonicalFrame.lean`
- Define `algR_G : AlgWorld → AlgWorld → Prop`
- Define `algR_H : AlgWorld → AlgWorld → Prop`
- Define satisfaction `algSatisfies : AlgWorld → Formula → Prop` (inductive, by structural recursion)
- Prove R_G reflexive and transitive (from existing interior operator properties)
- Prove duality: `algR_G U V ↔ algR_H V U`

### Phase 2: Algebraic Truth Lemma
**Same file or `AlgTruthLemma.lean`**:
- Theorem: `∀ U : AlgWorld, ∀ φ : Formula, [φ] ∈ U ↔ algSatisfies U φ`
- Proof by structural induction
- G-witness construction (the Lindenbaum extension for modal contexts)
- H-witness construction (symmetric)
- Leverage `set_lindenbaum` from `Core/MaximalConsistent.lean`

### Phase 3: Base Representation Theorem
- Prove: R_G is a linear order on AlgWorld (hybrid: use MCS linear ordering)
- Combine with truth lemma and existing `algebraic_representation_theorem`
- Derive: `∀ φ, ¬⊢ φ → ∃ U : AlgWorld, ¬algSatisfies U φ`

### Phase 4: Dense Extension
- Prove: When DN ∈ axioms (dense proof system), R_G is densely ordered
- G-witness density construction (interpolating ultrafilter)
- Derive: `valid_dense φ → ⊢_dense φ` (dense completeness via algebraic route)

### Phase 5: Discrete Extension (stretch goal)
- Analyze whether DF forces immediate successors among ultrafilters
- Compare difficulty to `succ_le_of_lt` in DiscreteTimeline.lean
- Derive: `valid_discrete φ → ⊢_discrete φ` if coverness proves tractable

### Parallel Track: Documentation
- Update `Algebraic/README.md` to document the extended scope of the algebraic approach
- Add cross-references from `DenseCompleteness.lean` and `DiscreteCompleteness.lean`

---

## Gaps Identified

1. **G-witness consistency proof**: The key lemma `{ψ | Gψ ∈ U} ∪ {¬φ}` is consistent when
   `[Fφ] ∈ U`. This is standard in modal logic but needs Lean 4 verification using the K-axiom
   and Lindenbaum's lemma.

2. **Linearity of R_G**: The canonical frame is a preorder; linearity requires axioms governing
   the temporal ordering. The exact set of TM base axioms forcing linearity needs identification.

3. **Connection to `valid` definitions**: The `valid_dense`/`valid_discrete` definitions in
   `Semantics/Validity.lean` quantify over all TaskFrame-based models; showing the Stone frame
   is included in this quantification (or that completeness can be stated independently) requires
   bridging work.

4. **Discrete coverness**: Possibly needs the same argument as task 974, just in a different
   (potentially cleaner) setting.

---

## Teammate Contributions

| Teammate | Focus | Status | Confidence |
|----------|-------|--------|------------|
| A | Classical algebraic approach, Jónsson-Tarski, concrete implementation steps | completed | 8/10 |
| B | Existing BFMCS analysis, domain mismatch characterization, algebraic bypass route | completed | 7/10 |

---

## References

- Jónsson, B. & Tarski, A. (1951/1952). Boolean Algebras with Operators. *AJM* 73/74.
- Goldblatt, R. (1976). Varieties of Complex Algebras. *APAL* 44.
- Blackburn, de Rijke, Venema (2001). *Modal Logic*. CUP. Chapters 4-5.
- van Benthem, J. (1980). Canonical Modal Logics and Ultrafilter Extensions. *JSL* 44.
- Venema, Y. Temporal Logic (survey chapter).
- Existing codebase: `Theories/Bimodal/Metalogic/Algebraic/` (all files)
