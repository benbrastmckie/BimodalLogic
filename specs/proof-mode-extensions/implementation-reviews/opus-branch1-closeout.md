# Closeout review: `feat/proof-mode-rewriting`, first branch (P0–P2 source)

**Scope.** I read only the packet: the current source for `Meta`, `Positions`, `Rewriting`, `RuleRegistry` and `Simplification`, plus the extension test file. I did not build anything. The README and user-guide changes were not in the packet, so the documentation claims for F4, F6 and F7 are unverified. The original 68.5 stands and is not re-graded.

## Verdict: **GO for the first branch's source**, with two conditions

1. The `run_elab validateScopeAdapters` compile, which is still being checked, must succeed.
2. The full-library `--wfail` build must pass on the final source.

I found no remaining blocker. The items under "Remaining defects" below are hardening work. N1 is the one I would fix before merging. It is a few lines and finishes the F1 contract.

Repo gates, counts, the book and the completion ledger are still pending, as stated. P3–P5 (temporal and semantic frontends) belong to later branches and are not counted against this one.

## F1–F10 resolution

| # | Status | Evidence |
|---|---|---|
| F1 | **Resolved** (one gap, see N1) | `rewriteCertificate` rejects `replacement.hasExprMVar` before `resolveRuleParameters` runs (`nativeRewrite`, `lsimp`, equality path). In `resolveRuleParameters`: any undetermined parameter type throws; locals are searched only for `isProp` types; non-Prop data that isn't a derivation throws; derivation premises stay pending; pending goals become `syntheticOpaque`; without `expose`, pending goals cause an error. Both `fail_if_success` cases for `weakeningSchema` are present and would have succeeded before the fix. |
| F2 | **Resolved** | Facts use `isDefEq` followed by `mkExpectedTypeHint` against `derivationType … replacement`, in `finishRewrite` and in the `lsimp` fact path. The exposed obligation is rebuilt from `certificate.word` with `formulaApp`, checked against `Step.demand`, and typed with the readable formula. Pinned by `guard_target =ₛ` / `guard_hyp :ₛ`. |
| F3 | **Resolved** | The `lsimp` goal path checks `inferType result` against `goal.getType` before assigning. |
| F4 | **Resolved** (behaviour changed) | Both `chooseRewriteOccurrence` and the equality path count formula matches only, with state restored per probe. Discharge failure on the unique match is reported atomically. The fixture `A.and A.allFuture` makes the match accessible at only one occurrence, and that occurrence must now be selected by explicit path. |
| F5 | **Resolved**, with residue N2 | `rigidOperatorArgs?` rejects a metavariable head, always restores, and rejects any assignment to original metavariables or any leftover fresh metavariable. A head-metavariable conclusion throws. The iff check restores on failure. Registration runs under `withNewMCtxDepth`, and the duplicate `isDefEq` is gone. |
| F6 | **Resolved** | `reverse != registered`. There is no test, which was optional. |
| F7 | **Resolved** | `positionChildren` reads only exact head constants; the `whnf` fallback is removed. `Position.replace` rebuilds the view operator. `primitiveSize` still uses `whnf`, which is correct because it only measures size. |
| F8 | **Resolved** | `baseSinceFoldPrototype` uses `time_reflection` of `DiscreteUnfolding.unfoldBackward` at `⊢` (Base). It type-checks only if `unfoldBackward` is stated at Base; you report that the affected suite passed with it. The ledger should record that it lives in the test module. The soundness-seam example is present. |
| F9 | **Resolved** (minimum met) | The product fixture runs: □→G (`boxToFuture`), G→GG (`gTransitivity`), and exact X at Base (the `nextBody` suggestion is `next`, so `source == target`). Double negation and `futureCollapse` run on the fact direction: the root collapse happens first, then `doubleNegationIff` under the event, closed through the G route. The validator covers all `scopeConvert` routes in both languages, including □→⊡ in Plus with a `stab` leaf. Still not run: Lean `Iff` rejection, and the Plus versions of `liftClosed` and `prev`/`since` (see N4). |
| F10 | **Resolved** | The rewrite trace logs the rule, path, demand, route, frame, role, reversal and output. The simp trace logs skip reasons and counters. Not traced: how each parameter or frame gate was discharged (local, `decide`, or exposed). This is a known limitation. |

## Remaining defects

### N1 — Low-medium: elaborator-introduced metavariables bypass the F1 checks
`elaborateRewriteRule` resolves only the `forallMetaTelescope` parameters. When `elaborateProof` (`Term.elabTerm`) elaborates a rule with leading implicit binders, it fills them eagerly with natural metavariables that are not in `parameters`.

- **Formula implicits:** these are still caught by the replacement check.
- **Implicit Prop gates or derivation premises** (for example `{h : Dense ≤ fc}`): these are never resolved, never exposed and never rejected. The tactic "succeeds" with a hole in the proof term. The failure then appears later as "don't know how to synthesize implicit" at the end of the `by` block. That is the non-atomic failure F1 was meant to remove, and a natural Prop metavariable left in the term can still be assigned by later unification.

The repo's `density` takes its gate explicitly, so current fixtures are unaffected.

**Fix:**
- Append the unassigned metavariables of the elaborated `proof` to `parameters`, or check them separately.
- In `finishRewrite`, assert that every metavariable in the instantiated certificate is in `pending ∪ obligations ∪ {next}`.

### N2 — Low: a successful iff check can specialise the rule
In `readRewriteEvidence`, `isDefEq lhs[0]! rhs[1]!` / `isDefEq lhs[1]! rhs[0]!` may assign rule metavariables, and the assignments are kept on success. For example, `(X→Y) ∧ (Z→X)` becomes an "equivalence" with `Y := Z`. The result is sound, because it is an instance of the rule. But registration accepts such a rule as an equivalence, which goes beyond F5's "no assignment to existing source metas".

**Fix:** run the converse comparison read-only, under `withNewMCtxDepth`, or compare the instantiated expressions directly.

### N3 — Low: the `expose` catch is too broad
In `rewriteCertificate`, `catch error => … route := "exposed"` turns *any* failure from `scopeConvert` or the following `adaptProof` into a scope obligation. That includes frame and context mismatches, and cases where `certificate.word` is empty. The result is still sound, since the user must prove the obligation, but the diagnostic is misleading.

Also, when the route is exposed, the rule's own pending parameters (premises and gates) are still exposed even though `e.proof` is no longer used. The user gets orphan goals.

**Fix:**
- Expose only when the missing piece is a scope.
- Drop the parameter goals when the evidence is replaced by an obligation.

### N4 — Low: validator coverage is narrower than "all builders"
`validateScopeAdapters` covers `scopeConvert` only. The following are still checked only when the tactic runs: the per-position step table in `onePosition` (in particular the `since`/`until`-guard/`prev`/`pastEvent`/`settledPossibility` arities in both languages), `liftClosed` `Scope.rule` for Plus, and the Plus `lceImp`/`rceImp` paths in `evidenceArrow`.

**Fix:** use the same mechanism. Fold `pathCertificate` over every `positionNames` entry per language, check the type of `Step.transfer`, and add one closed-lift route per scope.

### N5 — Low: rule terms are elaborated up to three times, and the probe isn't isolated
`nativeRewrite` elaborates `raw` only to test for `Eq`, then elaborates the term again. Any metavariables or postponed problems from the discarded probe stay in the state. A term with a stuck instance could then fail at the end of the `by` block.

**Fix:** wrap the probe in `withoutModifyingState`, or elaborate once and pass the result along.

### N6 — Cleanup
- `chooseRewriteOccurrence` has unused parameters (`_goalRole`, `_expose`, and `first`, which no caller uses).
- `equalityRewrite` assigns the goal path without a checked assignment. It is safe by construction, because `j.formula` is read from the goal.
- The `seen` repeat check in `lsimp` is redundant given the strict decrease. It is harmless.

## Not verified or pending (not claimed)
- The validator compile and the post-fix full `--wfail` build.
- README and user-guide wording for formula-first ambiguity (F4), xor orientation (F6), and explicit unfolding of views (F7).
- The `implementation.md` ledger, inventory, counts and gates.
- Whether `fail_if_success` cases fail for the intended reason. They don't pin error messages; using `#guard_msgs` on the F1 and F4 cases would make them more precise.

**Summary:** F1–F10 are correctly addressed in the source. There are no soundness or contract blockers for the first branch. Fix N1 before merging if possible. N2–N6 are hardening and cleanup.