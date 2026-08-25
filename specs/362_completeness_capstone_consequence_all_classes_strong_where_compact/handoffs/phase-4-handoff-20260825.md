# Phase 4 handoff — Base set-layer mirror and Dedekind prose softening

**Next action**: Phase 5 (tracking table in the repo-root `FormalSystem/Metalogic.lean`) and
Phase 6 (`latex/subfiles/04-Metalogic.tex`) — genuinely parallel, disjoint files.

**State**: scope extension TAKEN. Four new defs in `SetConsequence.lean`
(`StrongCompletenessBase`, `CompactBase`, `SatisfiableBaseSet`, `ModelExistenceBase`), each an
exact mirror of its Dense sibling modulo the relation/validity symbol and the dropped
`[DenselyOrdered D]` binder. One new theorem `strongCompletenessBase_of_compact` in
`StrongCompleteness.lean`, with the `engine` hypothesis kept live. Full `lake build` green
(2493 jobs).

**Verified**: `#print axioms strongCompletenessBase_of_compact` reports exactly
`[propext, Classical.choice, Quot.sound]`. `CompactBase` occurs exactly once in code, as that
theorem's hypothesis; `engine` is still an explicit argument. No "refuted, not merely unproved"
phrasing survives in a Dedekind context.

**Key decisions**: the Dedekind softening touched four sites, not the two the plan named — the
module-docstring class bullet, fact 2 of `consequence_completeness_dedekind_of_engine`, and the
`completeness_dedekind_of_engine` and `consequence_completeness_dedekind` docstrings, all of
which asserted the same over-strong claim. A "three distinct statuses" paragraph (open /
machine-refuted / unavailable-on-Reynolds's-terms) was added to the module docstring.

**Deviations**: one, annotated on the plan — the S2-S5 spawn note is recorded in the Lean
docstring without task numbers, because `no-task-references-in-deliverables.md` forbids them
outside `specs/**`. Substance preserved in full; numbered references go in the task summary.
