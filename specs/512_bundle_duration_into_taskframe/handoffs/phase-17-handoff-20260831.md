# Phase 17 handoff — `Examples/TemporalStructures.lean`

**Status**: [COMPLETED]. Build 0, test build 0, invariants ALL CHECKS PASSED (C15: all 46 paper
anchors resolve), zero sorry.

## Immediate next action
Phase 18 — `FrameConditions/`, `ValidOver` deletion, and the aggregators.

## The one thing Phase 20 must not miss
Generalized field notation dispatches on the **syntactic head of the declared type**. Every
`F.forward_comp` / `F.nullity` style call on a now-`FrameOver`-typed frame stops resolving and
needs a qualified `ParamTaskFrame.foo F …` until the namespace moves. Phase 20's relocation of
`namespace ParamTaskFrame`'s derived-lemma block into `FrameOver`/`TaskFrame` is what restores
dot notation tree-wide, and it is the largest remaining piece of work. The block contains at
least: `forward_comp`, `interpolates`, `nullity`, `backward_comp`, `limit_of_shift`,
`limit_of_succOrder`, `spherical_of_finite`, `exists_uniform_radius_of_finite`,
`sInter_nonempty_of_directed_of_univ_or_singleton`, the `*_of_total` / `*_of_permissive` /
`*_of_subsingleton` discharge helpers, `trivialFrame`, and `HF.isStepPath`.

## Carry-forward
- Scope: 55 occurrences, only 5 type ascriptions. The plan's frame list for this file was
  inherited from research F5's tree-wide inventory and named six frames that live elsewhere.
- No `@[reducible]` was added to the ℤ frames; `intOrder` is the reducible constant that R1/R3
  actually requires, and it already is one.
