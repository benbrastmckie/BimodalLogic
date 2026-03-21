# Bundle (Archived)

**Status**: ARCHIVED

Earlier BFMCS construction approaches that were superseded.

## Contents

- CoherentConstruction.lean - Coherent bundle construction
- FinalConstruction.lean - Final construction attempt
- SaturatedConstruction.lean - Saturation-based construction
- RecursiveSeed.lean - Recursive seed approach
- TemporalChain.lean - Temporal chain infrastructure
- CanonicalQuotientApproach/ - Quotient-based approach
- RecursiveSeed/ - Recursive seed subdirectory
- Various other construction attempts

## Singleton BFMCS Files (Task 15)

The following files were moved here on 2026-03-21 as part of Task 15:

### SuccChainBFMCS.lean

**Reason**: The singleton BFMCS approach has an **unprovable** `modal_backward` sorry.

The `modal_backward` property requires `phi in MCS -> Box phi in MCS`, which is the
converse of the T-axiom and does NOT hold for contingent formulas in TM logic.

**Counterexample**: An MCS can contain `phi` without containing `Box phi`. For
instance, `{Diamond(neg p), neg p, phi}` is consistent and extends to an MCS
where `phi` holds but `Box phi` does not.

**Superseded By**: Multi-family modally saturated BFMCS approach via
`ModallyCoherentBFMCS.lean` using `saturated_modal_backward` from
`ModalSaturation.lean`.

### IntFMCSTransfer.lean

**Reason**: Depends on SuccChainBFMCS and inherits its fundamental limitation.

The `construct_bfmcs_from_mcs_Int` function creates a single-family BFMCS Int,
which cannot satisfy `modal_backward` for the same reason as SuccChainBFMCS.

**Superseded By**: Task 15 Phases 3-4 create `ClosedFlagIntBFMCS.lean` using
MCS-level saturation from `ModallyCoherentBFMCS.lean`.

### Do Not Use These Files

These files are preserved for historical reference only. Do NOT:
- Import these modules in new code
- Copy constructions from these files
- Try to "fix" the modal_backward sorry (it is mathematically impossible)

## See Also

- [Active Bundle/](../../../Theories/Bimodal/Metalogic/Bundle/) - Current BFMCS implementation
- [Boneyard README](../README.md) - Archive overview
- Task 15 plan: specs/015_discrete_representation_theorem_axiom_removal/plans/03_domain-correct-plan.md

---

*Archived: Superseded by active Bundle/ implementation*
