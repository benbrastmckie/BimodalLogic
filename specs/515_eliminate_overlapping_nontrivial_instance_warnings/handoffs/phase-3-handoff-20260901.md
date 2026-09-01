# Phase 3 Handoff — TruthLemma.lean (Class B ownership)

**Next action**: Phase 4 tree-wide acceptance (forced full `--no-share` build + `lake test` +
`comm -13` no-new-warning check).

**Section-structure re-confirmation (the finding that makes this a two-line edit)**: verified
against the live pre-edit source — `end Invariance` at `:335` closes the section opened above
`:74`, and `section Countermodel` opens at `:343`, eight lines later. The `:74`
`variable … [Nontrivial D]` is therefore out of scope inside `section Countermodel`, and `:345`'s
`{D : Type}` is that section's only introduction of `D`. Corroborated by the compiler: the
pre-edit diagnostic reported exactly 2 `[Nontrivial D]` instances (not 3) and no
`AddCommGroup`/`LinearOrder` overlap. No "which `D`" hazard exists at any of the three sites.

**Ownership decision (recorded)**: the `section Countermodel` header binder at `:345-346` owns
`[Nontrivial D]`; the `variable [Nontrivial D]` formerly at `:351` is deleted. Three grounds:
1. The `:348-350` comment states a requirement about *scope*, not position — that `[Nontrivial D]`
   be declared in its own right rather than recovered from `[NoMaxOrder D]`, so the `omit` clause
   cannot strip nontriviality with the density instances. `:346` satisfies it identically: it is
   equally absent from the `omit` list. Only the comment's anchor moves; its claims are preserved.
2. `:346` is the codebase-wide duration-group bundle shape (`{D : Type} [AddCommGroup D]
   [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]`), matching `TruthLemma.lean:74`,
   `Decidable.lean:136`, `FlowFrame.lean:449`, and 33 other files.
3. It is the binder-order-preserving choice: `interpInvariantAt_regionHistory`'s surviving
   `[Nontrivial D]` keeps the baseline's slot; the alternative permutes it to the end.

**State**: `:351` deleted; the `:348-350` comment rewritten to document the surviving `:346`
binder. `:346` untouched (`  [IsOrderedAddMonoid D] [Nontrivial D]`). The `omit` clause (now `:367`)
still lists exactly `[Fintype ι] [DenselyOrdered D] [NoMaxOrder D] [NoMinOrder D]` and does not
mention `Nontrivial D`. `git diff --stat`: 3 insertions / 4 deletions.

**Evidence**: `lake env lean` exit 0; `Overlapping instance parameters` 3 -> 0;
`automatically included section variable` 2 -> 0; total file warnings 9 -> 4 (all four the
pre-existing `push_neg` deprecations at :193, :223, :254, :266); 0 errors. One-hop dependent
`Bridge/Valuation.lean` builds clean with no source edit (guarded build exit 0, 1409 jobs); its
three residual warnings are byte-identical to the pre-edit baseline set.

**Decisions**: none beyond the plan. No deviations.
