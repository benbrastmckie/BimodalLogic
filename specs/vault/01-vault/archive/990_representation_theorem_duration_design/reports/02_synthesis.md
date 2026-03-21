# Research Synthesis: Task #990 — Representation Theorem Duration Design

**Task**: 990 - Representation theorem design for parametric durations
**Date**: 2026-03-17
**Authors**: Teammate A (primary approaches) + Teammate B (alternative approaches)
**Session**: sess_1773784228_7938b0

---

## Synthesis

Both teammates converge on the same conclusion from independent angles:

**D should be parametric with axioms constraining its structure. It should NOT be constructed from pure syntax.**

### Points of Agreement

| Question | Teammate A | Teammate B | Verdict |
|----------|-----------|-----------|---------|
| D-from-syntax feasible for base logic? | No — no characterization theorem | No — TM syntax has no duration terms | **Not feasible** |
| D-parametric correct for base logic? | Yes — no domain mismatch | Yes — matches Montanari & de Rijke 1995 | **Yes** |
| Density/discreteness: constrain D or build D? | Constrain canonical accessibility relation | Axiomatically characterize class of D | **Constrain/characterize** |
| Current `ParametricRepresentation.lean`? | Correct and sorry-free (conditional) | Correct, matches prior art | **Keep as primary path** |
| D-from-syntax (DFromCantor.lean) role? | Optional specialization result | Works for dense/discrete extensions | **Keep as auxiliary** |

### The Core Decision

The TM representation theorem should be stated as:

```
∀ (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D],
  ¬⊢ φ → ∃ countermodel over D-parametric canonical frame
```

This is exactly `parametric_algebraic_representation_conditional` in `ParametricRepresentation.lean`.

For the dense extension: specialise to D with `[DenselyOrdered D]` and add that the DN axiom forces the canonical accessibility relation to be dense (algebraic witness construction). For the discrete extension: specialise to D with `[SuccOrder D]` plus DF-axiomatic forcing.

### What the Literature Confirms

1. **Henkin/BdRV tradition**: Worlds = MCSs, accessibility = formula-content inclusion, D is external. (Teammate A)
2. **Montanari & de Rijke 1995**: Closest prior art for two-sorted metric temporal logic uses D-parametric completeness over all ordered abelian groups. (Teammate B)
3. **Stanford Encyclopedia**: Qt is complete for ⟨Q,<⟩ treated as a given structure; the density axiom constrains which models satisfy the logic, it does not produce Q from scratch. (Both)
4. **BAO/Stone duality**: Gives worlds (ultrafilters), NOT duration D. D must be added externally. (Both)

### Implications for Task 990 Design

1. **Do NOT** attempt to construct D from syntax for the base logic — the base axioms provide insufficient order-theoretic structure.
2. **DO** keep `ParametricRepresentation.lean` as the primary completeness path.
3. **DO** use `DFromCantor.lean` only as an auxiliary result showing the dense canonical timeline satisfies the required group axioms (enabling instantiation of the parametric theorem with D = TimelineQuot ≃o Q).
4. **The conditional representation theorem form is correct**: separate the abstract parametric result from the concrete BFMCS construction for specific D values.
5. **For base completeness (task 987)**: instantiate with D = Int via the sorry-free `temporal_coherent_family_exists_CanonicalMCS` path.

---

## Recommendation

**Architecture: D-Parametric Primary, D-from-Syntax Auxiliary**

The representation theorem for TM base logic and all extensions should be parametric in D. The density and discreteness axioms constrain which D satisfies the logic's frame conditions, but do not construct D. This is standard in the literature and eliminates the domain mismatch problems that have blocked tasks 977, 978, and 982.

**Confidence**: High (both researchers independently confirmed this conclusion from different literature angles).
