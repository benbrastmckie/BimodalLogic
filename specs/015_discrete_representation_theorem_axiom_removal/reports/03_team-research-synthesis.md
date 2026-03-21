# Team Research Synthesis: Multi-BFMCS Approach for Discrete Representation

**Task**: 15 - discrete_representation_theorem_axiom_removal
**Date**: 2026-03-21
**Team**: Teammate A (multi-BFMCS approach) + Teammate B (singleton cleanup)
**Status**: RESEARCHED - ready for revised planning

---

## Executive Summary

Both research threads independently confirmed the same core conclusion: the singleton
`modal_backward` sorry in `SuccChainBFMCS.lean` is **mathematically impossible** to
eliminate without changing the construction. The implementation produced by Task 14/15's
phases carries an unprovable axiom (`phi -> Box(phi)`), not just deferred debt.

The correct path forward requires:
1. Replacing the singleton BFMCS with a **multi-family modally saturated BFMCS**
2. Deprecating `SuccChainBFMCS.lean` and decoupling `DiscreteInstantiation.lean`
3. Using the existing sorry-free `closedFlags` + `saturated_modal_backward` infrastructure

---

## Confirmed Impossibility

**From Teammate A** (mathematical analysis):
The singleton `modal_backward` requires `phi ∈ MCS → Box(phi) ∈ MCS`. This is the
converse of the T-axiom, which TM logic does not have. An MCS can contain a contingent
formula `phi` without containing `Box(phi)`. Counterexample: `{Diamond(p), neg(p), phi}`
is consistent and extends to an MCS where `phi` holds but `Box(phi)` does not.

**From Teammate B** (codebase cross-reference):
ROAD_MAP.md already documents two independent dead ends for this same failure:
- "Dead End: Single-Family BFMCS modal_backward" — same impossibility, general case
- "Dead End: Singleton Bundle Modal Saturation" — same impossibility, CanonicalMCS case

The implementation in `SuccChainBFMCS.lean` repeated a known dead-end pattern.

---

## The Correct Construction

### Principle: Multi-Family Modally Saturated BFMCS

A BFMCS is **modally saturated** when for every `Diamond(psi)` in any family's MCS at
time `t`, there exists a *different* family in the bundle whose MCS at `t` contains `psi`
as a witness. With this property, `modal_backward` is provable by contraposition:

```
If phi in ALL families at t, but Box(phi) not in fam at t:
  -> neg(Box(phi)) in fam at t        (MCS negation completeness)
  -> Diamond(neg(phi)) in fam at t    (box_dne + contraposition)
  -> EXISTS fam' with neg(phi) at t   (modal saturation)
  -> neg(phi) in fam' at t            (by saturation)
  -> CONTRADICTION                    (phi in ALL families, including fam')
```

This proof is already implemented sorry-free as `saturated_modal_backward` in
`Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean`.

### Sorry-Free Infrastructure Already Available

| Component | File | Status |
|-----------|------|--------|
| `is_modally_saturated` predicate | `ModalSaturation.lean` | Sorry-free |
| `saturated_modal_backward` | `ModalSaturation.lean` | Sorry-free |
| `witness_exists_for_diamond` | `WitnessFamilyBundle.lean` | Sorry-free |
| `closedFlags M0` construction | `ClosedFlagBundle.lean` | Sorry-free |
| `closedFlags_closed_under_witnesses` | `ClosedFlagBundle.lean` | Sorry-free |
| `closedFlags_union_modally_saturated` | `SaturatedBFMCSConstruction.lean` | Sorry-free |
| `canonicalMCSBFMCS` (FMCS CanonicalMCS) | `CanonicalFMCS.lean` | Sorry-free (F/P/G/H) |
| `temporal_coherent_family_exists` | `CanonicalFMCS.lean` | Sorry-free |
| `MCSBoxContent_subset_of_CanonicalR` | `ChainFMCS.lean` | Sorry-free |

The missing piece is assembling these into a `BFMCS Int` with temporal coherence.

### The Domain Transfer Blocker

`DiscreteInstantiation.lean` requires `BFMCS Int`. The sorry-free saturation machinery
operates over `CanonicalMCS`. The gap:

- `CanonicalMCS` is uncountable (all MCS via Lindenbaum)
- `Int` is countable
- No bijection between them → full `FMCSTransfer` is impossible

**Available bridge**: `FMCSTransfer.lean` provides a retract-based transfer:
```lean
-- transferredFMCS.mcs d := canonicalMCSBFMCS.mcs (retract d)
-- where retract : Int -> CanonicalMCS
```

Using `intChainMCS M h_mcs` as the retract gives an Int-indexed FMCS where:
- G/H coherence transfers (proven sorry-free in `IntBFMCS.lean`)
- F/P coherence requires dovetailing (the documented gap in `IntBFMCS.lean`)

### Witness Family Temporal Coherence Constraint

Constant witness families (mapping all times to the same witness MCS) are invalid for
temporal coherence. `{G(psi), neg(psi)}` is consistent, so a constant family containing
`G(psi)` would violate `forward_G`. This rules out the simplest multi-family approach.

Valid options for witness families:
1. **ChainFMCS** (Flag-based): Each Flag is a totally ordered chain, giving a valid FMCS
2. **FMCSTransfer retract**: Transfer the CanonicalMCS family structure to Int via retract
3. **Generalize the parametric framework**: Allow CanonicalMCS as D (requires AddCommGroup)

---

## Recommended Next Actions

### Immediate: Deprecate Dead-End Artifacts

1. Add DEPRECATED banner to `SuccChainBFMCS.lean` marking `SingletonBFMCS` and
   `construct_bfmcs_impl` as dead ends
2. Remove `import Bimodal.Metalogic.Bundle.SuccChainBFMCS` from `DiscreteInstantiation.lean`
3. Comment out or remove `discrete_representation_unconditional` (which depends on the sorry)
4. Add dead-end entry to ROAD_MAP.md for the singleton BFMCS approach

### Planning: Revised Implementation Plan (v2)

The revised plan should target the following construction for `construct_bfmcs_impl`:

**Phase A**: Build modally saturated `BFMCS CanonicalMCS`
- Use `canonicalMCSBFMCS` as the base family (sorry-free F/P/G/H)
- Add witness families from `closedFlags M0` (sorry-free saturation)
- Prove `is_modally_saturated` for the resulting bundle
- Derive `modal_forward` (T-axiom, trivial) and `modal_backward` (via `saturated_modal_backward`)

**Phase B**: Transfer to `BFMCS Int`
- Define `retract : Int -> CanonicalMCS` using `intChainMCS M0`
- Use `FMCSTransfer` to lift families from CanonicalMCS to Int
- Verify temporal coherence survives the transfer (G/H: yes; F/P: needs dovetailing)
- Alternative: change `discrete_representation_conditional` to accept `BFMCS CanonicalMCS`
  if the parametric framework can be generalized

**Phase C**: Wire to `DiscreteInstantiation.lean`
- Implement sorry-free `construct_bfmcs_impl`
- Restore `discrete_representation_unconditional`

### Risk Assessment

| Approach | F/P Sorry | Modal Sorry | Effort |
|----------|-----------|-------------|--------|
| Singleton (current) | 4 axioms | 1 sorry (impossible) | Done (broken) |
| Multi-family + FMCSTransfer | dovetailing gap | 0 | High |
| Multi-family + CanonicalMCS D | 0 | 0 | Medium (parametric refactor) |

The CanonicalMCS-as-D path has the lowest sorry cost but requires verifying that
the parametric framework in `ParametricRepresentation.lean` works with a non-group
preorder. `CanonicalFMCS.lean` already demonstrates this is possible for the FMCS
level - the question is whether `ParametricCanonical` / `ParametricHistory` require
`AddCommGroup`.

---

## Files to Modify in Next Phase

| File | Action |
|------|--------|
| `Bundle/SuccChainBFMCS.lean` | Add DEPRECATED banner; mark SingletonBFMCS as dead end |
| `Algebraic/DiscreteInstantiation.lean` | Remove SuccChainBFMCS import; revert to conditional-only |
| `ROAD_MAP.md` | Add dead-end entry for Task 15 singleton approach |
| New: `Bundle/ModallyCoherentBFMCS.lean` | Multi-family BFMCS construction over CanonicalMCS |
| New: `Algebraic/DiscreteRepresentation.lean` | Sorry-free `construct_bfmcs_impl` using new construction |

---

## Confidence Assessment

- **High confidence**: Singleton approach is impossible, multi-family is necessary
- **High confidence**: `saturated_modal_backward` provides the sorry-free modal_backward
- **High confidence**: `closedFlags` provides the sorry-free saturation content
- **Medium confidence**: FMCSTransfer retract path can close the F/P gap
- **Medium confidence**: CanonicalMCS-as-D parametric generalization is feasible
- **Low confidence**: Timeline estimate for full sorry elimination (high complexity)
