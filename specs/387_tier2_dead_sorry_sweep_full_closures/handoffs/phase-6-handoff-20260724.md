# Phase 6 Handoff — task 387 (tier2_dead_sorry_sweep_full_closures)

## Immediate Next Action

Phase 7: excise the whole 6-declaration set of `Bundle/UntilSinceCoherence.lean` to
`Boneyard/SorriedDeclExcisions/UntilSinceCoherence.lean` (both 3-link chains move together;
live file becomes docstring-only; do NOT drop the import in `ChronicleToCountermodelBasic.lean:3`).

## Current State

- Phases 1-6 complete; 7-8 remaining.
- Phase 6 excised the 3 singleton dead sorried decls (`doets_lemma_1_5`, `bx_le_refl`,
  `succ_reaches_dom_N`; 4 statement sorries) to
  `Theories/Bimodal/Boneyard/SorriedDeclExcisions/SingletonSorriedDecls.lean` (401 lines,
  `#exit` at line 41) and fixed the stale ChronicleToCountermodel.lean header.
- Full `lake build` green (1789 jobs); axiom baseline byte-identical on
  `completeness_discrete`: `[propext, Classical.choice, Quot.sound]`.
- Sorry census: OrderedSum 1 → 0, Frame 1 → 0, ChronicleToCountermodel 6 → 4 (remaining 4
  are the kept compile-live `chronicle_gap_contradiction` sorries).

## Key Decisions

- Verbatim regions extracted via sed (byte-verbatim by construction); moved code retains its
  original comments verbatim, including pre-existing task-number mentions behind `#exit`.
- Stale-header fix extended to two additional stale mentions of the nonexistent
  `limitDomSubtype_isSuccArchimedean_axiom` (the `limitDomSubtype_isSuccArchimedean`
  docstring and the Collapse-Based Discrete Pipeline section header) — same stale-claim
  family, comment-only.
- Delta vs. plan expectation: `limit_f_some_future_of_lt` / `limit_f_not_G_neg_of_mem` were
  verified against git HEAD to have had zero code consumers BEFORE this phase — they are
  pre-existing sorry-free private orphans, not freshly orphaned (the excision touched nothing
  after their position). Left in place per the SETTLED pre-existing-orphan policy. Phase 8
  keep-set spot-check should note this when checking `chronicle_gap_contradiction` liveness
  (it is live via `succ_cofinal`/`succ_embed_surjective`, not via these two helpers).

## Sorry Inventory

Empty. No sorries introduced or inherited by this task's dispatches; all excised sorries are
archived behind `#exit` (never compiled).
