# Phase 4 Handoff — Task 191

**Status**: Phases 1-4 COMPLETED. `Kalmar.lean` is now feature-complete for the schematic
Kalmar soundness theorem (the highest-value deliverable per the plan's rollback note). Zero
sorries anywhere; all key theorems depend only on `[propext, Classical.choice, Quot.sound]`.

## Completed
- `PropForm.lean` (Phase 1): deep embedding, `isTaut`, `isTaut_iff_forall_eval`, `denote`.
- `Kalmar.lean` (Phases 2-4, ~330 lines): `neg_imp_intro`, `litDenote`/`litCtx` machinery,
  `kalmar_step` (full 3-case `imp` induction), `PropForm.vars_nodup`, `elim_vars`
  (head-elimination via `deduction_theorem` + `classical_merge`), `tautology_derivable'`
  (tree-valued, `⊢ f.denote env`), `tautology_derivable` (Prop, `|-! f.denote env`),
  `tautology_derivable_fc'`/`tautology_derivable_fc` (generalized to arbitrary `fc` via
  `DerivationTree.lift (FrameClass.base_le fc)` — no Base-only residue, all internal lemmas
  built at Base and lifted only at the very end), and two in-file sanity examples
  (`A.imp(B.imp A)` and `(□A).imp(□A)` via manual reification).

## Next Action (Phase 5, then Phase 6)
Phase 5 (`Decidable.lean`) is the plan's designated scope-cut candidate. If continuing:
- `Formula.isPropositional : Formula → Bool` (atom/bot/imp only)
- `Formula.reify` via `Formula.atoms` (`Syntax/Formula.lean:700`), round-trip lemma
- Trivial-frame truth lemma (`Semantics/WorldHistory.lean:172` `trivial`/`universal_trivialFrame`,
  `TaskFrame.trivial_frame`) + completeness direction via `Soundness.lean:1023`
- `instDecidableDerivable` (hypothesis-carrying `def`, not instance)

Phase 6 (`prop_decide` tactic + tests + umbrella wiring) depends only on Phase 4 per the
plan's wave table — it does NOT require Phase 5. If time-constrained, Phase 6 can proceed
directly using `tautology_derivable'`/`tautology_derivable`/`tautology_derivable_fc`/
`tautology_derivable_fc'` as the four apply-targets for the tactic's four goal shapes
(`⊢ φ`, `⊢[fc] φ`, `|-! φ`, `|-![fc] φ`).

## Deviations
None — plan followed exactly through Phase 4.
