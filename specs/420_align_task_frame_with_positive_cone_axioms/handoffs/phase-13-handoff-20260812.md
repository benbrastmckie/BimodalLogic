# Phase 13 handoff — task 420

**Immediate next action**: Phase 14 — the atomic batch. Every one of the 14 sites now has citable
lemmas from Phases 10-13; the batch discovers no proofs.

**State**: `lake build` green, exit 0, 2331 jobs. Phases 1-13 landed and committed.

**Required pre-batch green commit** (do this BEFORE opening the batch): the apparatus
(`Fib`/`cone`/`Seg`/`DirectedFamily`/`IsFiber`/`IsSegment`) and the three Props
(`Spherical`/`Serial`/`Interpolates`) currently sit *after* the `TaskFrame` structure
(TaskFrame.lean:177). A structure field's type may only mention earlier declarations, so they
must be hoisted above it. That hoist is a pure relocation and stays green — commit it separately.

**Deferred binder changes to apply inside the batch**: `natFrame` and `genericNatFrame` need
`[SuccOrder D] [NoMaxOrder D]`. Propagation is confined to `WorldHistory.universalNatFrame`
(zero consumers); `genericNatFrame` has zero consumers. The two filtration sites already carry
their binders (Phase 13.2).

**Caveat (b) still open**: `nullity_identity` stays as-is — re-check `specs/decisions/` at batch
time; as of 2026-08-12 the joint decision had not landed.
