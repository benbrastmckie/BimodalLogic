# Phase 3 Handoff

- Next action: Phase 4, new `<lean-appendix-recursion>` section between the dependent-fields
  section and `lean-appendix-tactics`.
- Done: `== Dependent Fields and Subtypes <lean-appendix-dependent-fields>` added before the
  tactics section, with three subsections (`PartialHistory` and the dependent `states` field,
  predicates rather than structures, models over a frame). The `TaskModel` excerpt owed by
  Phase 2 landed here. All four gates green.
- `{w | M.valuation w p}` does NOT resolve under Check 1, so it is carried as a compiled
  didactic block (which Check 1 does not scan) rather than as an inline span or a whitelist
  entry. `{x : A // p x}` likewise failed and was replaced by prose plus the source's own
  `{τ : PartialHistory F // τ.IsTotal}`.
- Phase 4 should add a `@lean-appendix-recursion` reference back into the final paragraph of
  "Models over a Frame", which currently names `TruthAt` without the cross-reference.
