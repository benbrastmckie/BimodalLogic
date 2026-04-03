# Archived T-Axiom Dependent Code

**Archived**: 2026-04-03 (Task 83, Phase 1)

## Reason

These functions depend on the T-axiom (`G(phi) -> phi` / `H(phi) -> phi`), which is
NOT valid under strict temporal semantics. The project migrated from reflexive to
strict semantics in Task 81 (March 2026), making these proofs unsound.

All archived functions contain `sorry` placeholders where `temp_t_future` or
`temp_t_past` axioms were previously invoked.

## Archived Files

### TargetedChainArchive.lean
Functions from `Metalogic/Bundle/TargetedChain.lean`:
- `targeted_forward_chain_forward_G`: G(phi) propagation in forward chains (used T-axiom at final step)
- `targeted_backward_chain_backward_H`: H(phi) propagation in backward chains (used T-axiom at final step)
- `targeted_fam_forward_G`: G(phi) propagation over Int-indexed families (used T-axiom)
- `targeted_fam_backward_H`: H(phi) propagation over Int-indexed families (used T-axiom)
- `TargetedFMCS`: FMCS construction using above functions
- `TargetedFMCS_at_zero`: Base case property

### CanonicalConstructionArchive.lean
Functions from `Metalogic/Bundle/CanonicalConstruction.lean`:
- `restricted_tc_family_to_fmcs.forward_G`: FMCS field requiring T-axiom for G-propagation across independent Lindenbaum extensions
- `restricted_tc_family_to_fmcs.backward_H`: FMCS field requiring T-axiom for H-propagation

### TruthPreservationArchive.lean
Functions from `Metalogic/Decidability/FMP/TruthPreservation.lean`:
- `mcs_all_future_closure`: G(psi) in closure MCS implies psi in closure MCS (false under strict semantics)
- `mcs_all_past_closure`: H(psi) in closure MCS implies psi in closure MCS (false under strict semantics)
- `filtration_all_future_forward`: Filtration lemma depending on `mcs_all_future_closure`
- `filtration_all_past_forward`: Filtration lemma depending on `mcs_all_past_closure`

## Status

This code is preserved for historical reference only. It does NOT compile and
should NOT be imported by active Lean files.

## Related

- Task 81: Strict semantics migration
- Task 83: Completeness via representation theorem (uses restricted coherence instead)
- Task 82: FMP truth preservation redesign (will replace filtration lemmas)
