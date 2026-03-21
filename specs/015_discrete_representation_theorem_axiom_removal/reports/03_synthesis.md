# Synthesis Report: Task 15 Team Research

**Task**: 15 - discrete_representation_theorem_axiom_removal
**Date**: 2026-03-21
**Session**: sess_1774113018_b8c88f
**Teammates**:
- Teammate A: Multi-BFMCS construction approach and correct architecture
- Teammate B: Singleton BFMCS cleanup and ROAD_MAP.md documentation

---

## Consensus: The Singleton Approach Is a Dead End

Both teammates independently confirm the same core finding:

**`SingletonBFMCS.modal_backward` (SuccChainBFMCS.lean line 94) is mathematically impossible to prove.** It requires `phi ∈ MCS → Box(phi) ∈ MCS`, which is the converse of the T-axiom (`Box(phi) → phi`). TM logic does not have this converse. The sorry is not an implementation gap — it is a proof-theoretic impossibility for contingent formulas in any normal modal logic.

This failure was already documented in ROAD_MAP.md under two prior dead ends (Single-Family BFMCS modal_backward, Singleton Bundle Modal Saturation). Task 15's implementation repeated the same error.

---

## Key Synthesis Findings

### 1. What Needs to Be Removed / Deprecated

| File | Action | Reason |
|------|--------|--------|
| `SuccChainBFMCS.lean` | Deprecate + mark as dead end | Singleton approach is impossible; sorry at line 94 is unprovable |
| `DiscreteInstantiation.lean` lines 2, 178-197 | Remove import + unconditional theorem | `discrete_representation_unconditional` inherits the sorry |
| `SuccChainBFMCS.lean` lines 17-19 | Correct misleading comment | Claims modal_backward is "trivial via T-axiom" — this is backwards |

The **conditional theorem** `discrete_representation_conditional` in `DiscreteInstantiation.lean` is sound and must be preserved. Only the unconditional version (which uses `construct_bfmcs_impl` from the singleton) should be removed.

### 2. The Correct Replacement Architecture

Teammate A identified the complete sorry-free infrastructure that already exists:

**Sorry-free components available**:
- `saturated_modal_backward` (`ModalSaturation.lean`) — key theorem, complete, no sorry
- `closedFlags_union_modally_saturated` (`SaturatedBFMCSConstruction.lean`) — MCS-level saturation
- `closedFlags_closed_under_witnesses` (`ClosedFlagBundle.lean`) — witness existence
- `temporal_coherent_family_exists` (`CanonicalFMCS.lean`) — temporally coherent FMCS over CanonicalMCS

**What still needs work**:
- Lifting MCS-level saturation to BFMCS-level modal saturation over CanonicalMCS
- Temporal coherence for witness families (constant families are INVALID — documented in `WitnessFamilyBundle.lean`)
- Domain transfer from CanonicalMCS to Int (the fundamental bottleneck)

### 3. The Domain Transfer Bottleneck

The `construct_bfmcs` callback in `DiscreteInstantiation.lean` requires `BFMCS Int`. The natural sorry-free construction produces `BFMCS CanonicalMCS`. These cannot be naively reconciled:

- CanonicalMCS is not countable (contains all Lindenbaum MCSes)
- Int is countable
- `FMCSTransfer.lean` provides a transfer lemma via retract functions, but requires sorry-free F/P witnesses in the Int chain

`IntFMCSTransfer.lean` documents this bottleneck explicitly at lines 100-134 with the `singleFamilyBFMCS_Int` sorry.

### 4. Forward Path Options

**Option 1: Multi-family BFMCS over CanonicalMCS + FMCSTransfer retract to Int**

The `FMCSTransfer` pattern uses `transferredFMCS.mcs d := canonicalMCSBFMCS.mcs (retract d)` where `retract : Int → CanonicalMCS` maps each integer to an MCS in the chain. This is the path outlined in `IntFMCSTransfer.lean`. Temporal coherence for G/H transfers; F/P witnesses inherit from the all-MCS domain.

Estimated effort: Medium. Requires:
1. Construct multi-family BFMCS over CanonicalMCS (closedFlags + ChainFMCS for witness families)
2. Apply FMCSTransfer retract to get BFMCS Int

**Option 2: Change DiscreteInstantiation to accept BFMCS CanonicalMCS**

Change the signature of `discrete_representation_conditional` to be D-parametric (it already is via `ParametricRepresentation.lean`). The issue is CanonicalMCS lacks `AddCommGroup`, required by the parametric framework.

This would require either adding a group structure to CanonicalMCS (complex) or using a different parametrization. Not recommended without further research.

**Option 3: Accept task as [BLOCKED] pending multi-family BFMCS construction**

Given that the correct infrastructure requires substantial new work (multi-family over CanonicalMCS + temporal coherence for witness families + FMCSTransfer), Task 15 may be more appropriately [BLOCKED] pending a focused task on the multi-family BFMCS construction.

The immediate cleanup (deprecate singleton, remove unconditional theorem) can be done now. The sorry-free `discrete_representation_unconditional` requires the multi-family work.

---

## Recommended Actions (Prioritized)

### Immediate (this task)

1. **Add ROAD_MAP.md dead end entry** for "Singleton BFMCS for Discrete Representation (Task 15)" — Teammate B provides the full text, which should be inserted after the existing "Singleton Bundle Modal Saturation" dead end (line 968)

2. **Deprecate `SuccChainBFMCS.lean`** — add DEPRECATED banner to the module docstring documenting the impossibility and referencing the ROAD_MAP dead end

3. **Revert `DiscreteInstantiation.lean`** — remove the import of `SuccChainBFMCS` and the `discrete_representation_unconditional` theorem (or comment it out with a reference to the blocker)

### Follow-up task (new spawn)

4. **Spawn a focused task** for multi-family BFMCS over CanonicalMCS with temporal coherence for witness families, to eventually provide a sorry-free `construct_bfmcs_impl`

The key insight from Teammate A is that `saturated_modal_backward` is already proven sorry-free — the gap is purely in constructing a modally saturated BFMCS with valid temporal coherence for the witness families.

---

## ROAD_MAP.md Entry (Ready to Insert)

Insert after line 968 of `specs/ROAD_MAP.md` (after the "Singleton Bundle Modal Saturation" entry):

```markdown
### Dead End: Singleton BFMCS for Discrete Representation (Task 15)

**Status**: ABANDONED
**Tried**: 2026-03-21
**Related Tasks**: Task 15 (discrete_representation_theorem_axiom_removal)

*Rationale*: Task 15's implementation plan (Option B from research) attempted to wrap
SuccChainFMCS as a singleton BFMCS to implement the `construct_bfmcs` callback required
by `discrete_representation_conditional`.

**What We Tried**:
Created `SuccChainBFMCS.lean` with `SingletonBFMCS` wrapping a single FMCS family.
`modal_forward` (T-axiom direction) was proven successfully. `modal_backward` was
attempted with the reasoning "phi in all families (just one family) implies Box phi
via MCS T-axiom closure."

**Why It Failed**:
`modal_backward` requires: if phi holds in all families (the singleton), then Box(phi)
holds in that family. This reduces to `phi ∈ MCS → Box(phi) ∈ MCS`, i.e., `phi → Box(phi)`.
This is the CONVERSE of the T-axiom, which TM logic does NOT have. The proof obligation
is mathematically impossible for contingent formulas. This is the same fundamental failure
as the earlier "Single-Family BFMCS modal_backward" dead end.

**Evidence**:
- [SuccChainBFMCS.lean line 94](Theories/Bimodal/Metalogic/Bundle/SuccChainBFMCS.lean) — sorry at modal_backward
- [Task 15 synthesis](specs/015_discrete_representation_theorem_axiom_removal/reports/03_synthesis.md) — team research
- Related dead end: "Single-Family BFMCS modal_backward" above

**Lesson**:
The singleton bundle approach for modal_backward is blocked by the same impossibility
regardless of the underlying FMCS construction (SuccChainFMCS, CanonicalMCS, or any other).
No single-family construction can circumvent the need for multiple families to witness modal_backward.

**Superseded By**: The `construct_bfmcs` callback for discrete representation requires a
multi-family BFMCS with genuine modal saturation. The key theorem `saturated_modal_backward`
in `ModalSaturation.lean` is already sorry-free — what is needed is a modally saturated
BFMCS with valid temporal coherence for witness families (non-constant `mcs` functions).

---
```

---

## Status Recommendation

Task 15 should be marked **[BLOCKED]** with the blocker being:

> Multi-family BFMCS construction with valid temporal coherence for witness families needed to provide sorry-free `construct_bfmcs_impl`. `saturated_modal_backward` already exists; the gap is lifting MCS-level saturation (`closedFlags_union_modally_saturated`) to BFMCS-level with temporally coherent witness families over a suitable domain (CanonicalMCS or Int).

The immediate cleanup (deprecate SuccChainBFMCS, remove unconditional theorem from DiscreteInstantiation, add ROAD_MAP entry) should be committed, and the status updated to [RESEARCHED] with the blocker documented. The unconditional sorry-free theorem requires a follow-up task.
