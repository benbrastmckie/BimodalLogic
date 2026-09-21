# Phase 2 Handoff

- Next action: Phase 3, new `<lean-appendix-dependent-fields>` section after the structures
  section.
- Done: `lean-appendix-structures` restructured into three subsections (binder triple, the
  `TemporalOrder` instance-bracket fields plus the `CoeSort` coercion, and the two-layer
  `FrameOver` / `TaskFrame` frame). All four gates green.
- Deviation: the `TaskModel` excerpt was REMOVED from the structures section in this phase and
  is owed to Phase 3's histories section, where the valuation reading lives. The prose in the
  structures section forward-references `TaskModel F` and `WorldHistory F` by name only.
- Deviation: the binder paragraph says "a derived theorem later in this appendix" instead of
  `@lean-appendix-derived-theorem`, because that label does not exist until Phase 5. Phase 5
  must restore the label reference.
- Two spans failed Check 1 on first pass and were fixed by the source's own spelling rather than
  by whitelist: `#check @soundness` and `(t : F.Duration.carrier)`.
