# Branch2 closeout: GO (conditional)

The original 78/100 and NO-GO stay as the historical record. This is a closeout status, not a new score.

At source level, M1–M3 are closed. GO depends on the pending post-M1 checks actually passing. `Basic.lean` is shared and `applyDerivationProof`'s signature changed, so the pre-M1 full build no longer covers this code. The post-M1 run needs every importer of `ProofMode/Basic` (Modal, Discrete, Rewriting, TemporalComposition, etc.), both test targets with `--wfail`, the linter, and the inventory/count sync. Until that has run, the fixes are reviewed, not verified.

## Blocking findings

**M1 is correct as written.**
- `MetavarDecl.index` is assigned from `mvarCounter` at creation. Capturing the counter before `elaborateProof` and filtering `index < firstNewIndex` therefore excludes pre-existing goals and keeps both elaboration holes and telescope parameters.
- Only Prop and judgment-typed parameters are made `syntheticOpaque`. Data stays `.natural` and is scheduled after the premises, so `lexact` on a premise can assign it.
- `getMainGoal` prunes assigned data goals afterwards.

**M2 is correct.** The reflection refusal is discriminating:
- `d` reflects to `[(atom p).allPast] ⊢ (atom q).somePast`. Its conclusion matches the goal, but its context does not.
- A conclusion-only reflection would therefore succeed, and the `fail_if_success` would catch it.
- The Dense `luntil unfold` refusal has its positive control in the `hZ : ZTime ≤ fc` example.

**M3 is accepted as reported.**

## Remaining findings (non-blocking, all actionable)

1. **Low, test strength.** Both new refusals use bare `fail_if_success`, which passes on *any* failure, including a broken `ltime_reflect using` path. Confirm that a positive `ltime_reflect using d` with a non-empty context exists somewhere in the suite. If it doesn't, add the mirror case: goal `[(atom p).allPast] ⊢ (atom q).somePast` with `ltime_reflect using d`. That one example makes the M2 refusal meaningful.
2. **Low, latent.** `applyDerivationProof` never synthesizes instance-implicit binders. `forallMetaTelescopeReducing` makes them `.synthetic`, and the code then either locks them as proof goals or demotes them to natural data goals. This is harmless while native rules use explicit Prop gates (`ZTime ≤ fc`) rather than instance arguments. Either add a `synthesizeInstMVarCore` pass for `.instImplicit` binders, or document the restriction.
3. **Low, latent.** `applyTemporalProofCore` computes `rest` before `applyDerivationProof`'s `withMainContext` prunes assigned head goals. If the goal list starts with an assigned goal, `fresh` comes out one short, a premise is silently dropped, and the user gets a later "unassigned metavariable" error. The current callers (`applyTemporalRule`, `timeReflectUsing`) already prune via their own `withMainContext`, so this can't happen today. Because `applyTemporalProof` is public, add `let _ ← getMainGoal` at the top of the core.
4. **Low.** In the judgment branch of `timeReflectUsing`, unassigned holes in the `using` term are neither surfaced as goals nor refused. Add an `instantiateMVars fact |>.hasExprMVar` check with a clear error.
5. **Low.** `source.language == judgment.language` is structural equality, with no `instantiateMVars` or defeq. It could spuriously refuse when the same language appears in a different syntactic form. `isDefEq` (or at least instantiating first) is safer.
6. **Nit.** `catch _ => throwError "... is false for this concrete frame class"` relabels every resolver error as falsity, including failures for an abstract `fc`. Either preserve the original error or narrow the catch.
7. **Process.** The packet doesn't say that the `futureConsequence` regression failed before the M1 fix. Note whether it was observed red, or mark it as "added post-fix, not observed red."
8. **Audit.** Every other caller of `applyDerivationProof` or `applyTemporalProof` must capture `mvarCounter` *before* elaborating or constructing its own proof term. A caller that captures it afterwards would silently orphan its holes. The compiler will flag the arity change, but not a counter captured too late.

None of these reopen M1–M3. Items 1 and 3 are the cheapest worthwhile fixes before the ledger update. The rest can be deferred and recorded in the ledger.