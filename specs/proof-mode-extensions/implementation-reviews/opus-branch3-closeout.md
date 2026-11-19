# Closeout: Opus 5.5 branch3 review

**Historical grade: 82.5/100, NO-GO (H1/M1/M2).** The grade is unchanged. This is a source-only closeout of the packet as given, with no tools or builds run.

## Verdict: **GO at source level**, conditional on the post-fix gates

I found no remaining blocking findings in the packet source. Release closeout still depends on gates the packet says have not run yet:

- the final affected integration build with `--wfail`, after the test line-wrapping edit;
- the linter, count and source gates;
- README/book sync and the axiom audit, re-run after the fixes.

The pre-review passes do not cover the final tree. Until those runs exist, this is GO on source only.

## Original findings

**H1: closed.**
- The native check now produces a `Bool` inside `liftTermElabM`, and `throwUnsupportedSyntax` is raised in `CommandElabM`. Command fallback therefore sees the unsupported-syntax exception and restores state before trying the native elaborator.
- Validation is skipped for native conclusions, so the native path receives no semantic diagnostics.
- The shared test covers the import order where Semantic loads before the native registrar.

**M1: closed by inspection.**
- `semanticEqualityCertificate` passes `(resolveParameters := resolveSemanticParameters)` explicitly.
- The fake `Base`/empty-context judgment only carries the formula into `formulaEqualityRewriteProof`.
- The result is lifted by `congrArg` over `truthType j`. Under `Eq.mpr` for goals and `Eq.mp` for facts, the direction is correct.
- `indexedDefEq` refuses the `bot`/`top` index erasure that plain `isDefEq` would accept, because both sides unfold to the same propositional body.

**M2: closed.**
- I checked all four generic clauses against `untl_clause`/`snce_clause` and the guard-first `untl` argument order. In `luntil`, `Formula.untl A B` has guard `A` and event `B`. Release and trigger negate both arguments correctly and keep strict open intervals with no inclusive endpoints.
- The eight literal pins are definitional instantiations with `e := ()`. They are kernel-checked by construction, so they also pin `Formula.release`/`trigger`/`weakUntil`/`weakSince` to the event-first order.

## Non-blocking (minimal fixes, no new matrix)

1. **The M1/L1 fixture is negative-only, so it does not discriminate.**
   - Both `fail_if_success` lines would also pass if the equality path could never discharge a Prop-gated side condition at all.
   - Minimal fix: one positive control after the existing negatives, in the same example:
     ```lean
     have _okNot : ¬ TruthAt M τ t Formula.bot := fun h => h
     lrewrite _eqNot at provider as rewritten
     guard_hyp rewritten :ₛ TruthAt M τ t B
     ```
     Leave `lexact provider` unchanged.
   - The source fix stands on inspection either way. This only makes the regression meaningful.

2. **`logicalHead` can unfold past a truth head.**
   - The loop stops only at logical connectives. An alias that unfolds to `TruthAt …` keeps unfolding through `TruthAt` itself.
   - The refusal then depends on `containsTruth` finding residue in the unfolded body. Recursive match alternatives make that likely, but nothing guarantees it.
   - Minimal fix: return early in `logicalHead` when `current` is an application of any `containsTruth` constant. The existing fall-through then refuses it explicitly.
   - I could not construct a concrete bypass, so this is hardening only.

3. **Registrar shape question (confirm, no change expected).**
   - If the native `register_lrewrite` accepts conclusions that `judgment?` does not recognize (for example, bare formula-data equalities), the semantic registrar now claims them first.
   - It either validates them into the shared extension or raises a semantic error instead of falling through.
   - If native never accepts such shapes, nothing needs to change.

## Accepted as documented
- **L6:** per-attempt freshening with no cache is accepted as a bounded policy, not a deferred P4 feature.
- **L2–L5, L7, L8:** consistent with the packet descriptions. In particular, the `presentDemand` output is guarded by `isDefEq` against `expected`, and the final `inferType certificate` check covers the display/`direct` rewrite.