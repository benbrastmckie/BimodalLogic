# Phase 1 Handoff — native_decide swaps + axiom re-verify (2026-07-24)

## Immediate Next Action

Phase 2: doc-surface reconciliation under **BRANCH A**. Edit
`Theories/Bimodal/Metalogic/Metalogic.lean:31,:32,:56` and
`Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean:36,:242,:283` + Axiom Classification
block (`:381-384`) to drop the `Lean.ofReduceBool`/`Lean.trustCompiler` caveat and state the
pristine set `[propext, Classical.choice, Quot.sound]` for both `completeness_dense` and
`completeness_discrete`. Record the Branch A adjudication (all 7 sites swapped, empty fallback
ledger) in the audit block. Then the two regression scans + chain lean_verify.

## Current State

- Phase 1 COMPLETED. Build green (full, 1789 jobs).
- All 7 in-cone native_decide sites swapped, first attempt each:
  - `Syntax/Formula.lean:265` → `rfl`
  - `Syntax/SubformulaClosure/TemporalFormulas.lean:561,:568,:639,:658` → `decide`
  - `Syntax/SubformulaClosure/TemporalFormulas.lean:597,:684` → `rfl`
- **Fallback ledger: EMPTY** (no site reverted; no compile blowup — TemporalFormulas 1.2s).
- **Branch decision: BRANCH A.** Kernel-level `#print axioms` (via `lake env lean`, fresh
  oleans) byte-lists, for ALL five Phase 1 verification targets
  (`completeness_discrete`, `completeness_dense`, `Formula.beq_refl`,
  `max_F_depth_deferralClosure_eq`, `max_P_depth_deferralClosure_eq`):
  `[propext, Classical.choice, Quot.sound]`
- Sorry count: 0 introduced; sorry_inventory empty.

## Key Decisions

- MCP `lean_verify` initially reported `Lean.ofReduceBool`/`Lean.trustCompiler` on
  `completeness_discrete` — this was a STALE LSP environment (server predated the rebuild).
  The plan's bounded discovery pass was run anyway: only remaining tactic-position
  `native_decide` sites are the 4 out-of-cone `Decidability/SignedFormula.lean` sites
  (`:126,:132,:133,:138`); the `Syntax/Subformulas.lean` grep hit is a migration comment,
  not an import. Kernel-level `lake env lean` + `#print axioms` is the authoritative
  measurement. Phase 2/3 verifications should prefer `lake env lean` `#print axioms` (or
  restart the LSP before `lean_verify`).
- Doc-surface prose still names the old expanded axiom set (Metalogic.lean:31,:32,:56;
  Completeness.lean:36,:242,:283,:381-384) — that reconciliation is Phase 2's charter, not
  Phase 1 scope.

## Sorry Inventory

[] (empty)

## References

- Plan: specs/375_kamp_completeness_final_assembly_axiom_audit/plans/01_final-assembly-axiom-audit.md
  (Phase 1 checklist now carries the full byte-listed verification transcript)
