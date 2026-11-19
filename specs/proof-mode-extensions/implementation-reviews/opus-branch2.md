I'm giving branch 2 a **NO-GO** for now, at **78.0/100**. I found no logical defect in the new temporal rules: every one I traced is built from existing source theorems, and the operand order and frame gates are right. Three fixes are needed first, and each is small: one shared-tactic regression in `lapply`, two required refusal tests, and long lines that will trip the linter.

This is a read-only source review. Bash was disabled, so I couldn't run `git diff` against fc85c61. I read the changed files in full and worked out the delta from them and the new declarations. I did not build anything.

## Grades

| Axis | Score | Basis |
|---|---|---|
| C: source grounding/correctness (30%) | 8.0 | Rule directions match the sources; one `lapply` regression (M1) |
| P: compositionality (25%) | 8.5 | Providers stay opaque and are never unfolded; whole-context reflection; TM⁺ rules are transferred one schema at a time |
| R: reuse (20%) | 7.5 | Good reuse of existing machinery; two frame-gate implementations; unused inclusive equivalences |
| A: predictable automation (15%) | 7.5 | Deterministic and bounded; `lapply` hole collection is less careful than the `lrewrite` version |
| I: clarity/validation economy (10%) | 6.5 | 8 compact examples, but two required refusals and several new code paths are untested |

**Total: 3(8) + 2.5(8.5) + 2(7.5) + 1.5(7.5) + 6.5 = 78.0**

## What I checked against the sources

- **Fold/unfold directions:** `unfoldForward` is integer-time only and goes U → one-step disjunction. `unfoldBackward` is Base and goes the other way. `unfoldBackwardSince` is integer-time and goes S → disjunction despite its name. `TemporalComposition.lean:75-99` uses each one correctly, always guard first, event second. The Since fold is the time reflection of the Base Until fold.
- **Monotonicity argument order:** `untilMonoGuard ⊤ g e` turns `F e` into `U g e`, so `untilIntro` is right. `untilMonoEvent ψ φ ⊥` gives `Xψ → Xφ`, so `nextOfAllFuture` asserts no successor. `nextKeep` takes `X ⊤` only from `succIndicatorAt` behind the integer-time gate.
- **Progress rules:** `progressConsequence` necessitates the closed rule, then applies G-distribution three times. Temporal 4 keeps the target weakening inside the persistent body. Past versions are closed time reflections of the future ones.
- **Reflection:** TM `reflectContext` recurses over the context (deduction, closed reflection, reverse deduction); TM⁺ reuses `liftContext`. The goal-direction form uses the involution. A reflected fact is weakened only into a context that contains the reflected context, so `[G p] ⊢ H p` from `[G p] ⊢ G p` fails as the plan requires.
- **Derived views:** every TM⁺ view matches the TM definition word for word, and each has `rfl` pins for its expansion, its time mirror and the TM embedding. `PlusFormula.after` already existed. `TemporalViews` imports only `PlusLanguage.Formula` and is registered at layer 0. The no-completeness guard (`assert_not_exists`) is kept.

## Findings

**M1 (medium): new `lapply` hole collection, `Basic.lean:62,87-92` and `Meta.lean:135-140`.**
- Every unassigned elaboration hole is turned into a locked (synthetic-opaque) goal. Locked holes can't be filled by later unification. This is the first problem.
- Take a rule with an implicit formula that appears only in its premises, such as ψ in `leadsToTrans`, `futureConsequence` or `nextOfAllFuture`. `lexact` on a premise can no longer fill ψ, though it could before this change. The goal order (premises first, hole last) makes it worse.
- Second problem: unlike `prepareRewriteRule`, the collection doesn't filter by `firstNewIndex`. It can capture metavariables that existed before the call, or pending elaboration jobs.
- Minimum fix: lock only Prop and derivation-typed holes created in this call (index ≥ the counter snapshot). Leave undetermined formula holes unlocked, or reject them as `resolveRuleParameters` does. Add one example that uses `lprogress using leadsToTrans` or `lapply futureConsequence`.

**M2 (medium): required refusals missing from the test file (plan §8 rows T1 and T2).**
- T1: nothing checks that Dense-time `luntil unfold` is rejected. Line 177 tests the `linduction` refusal, which goes through `applyTemporalRuleCore`, not `integerTimeGate`.
- T2: nothing checks that reflecting only the conclusion is refused.
- Minimum fix: add `fail_if_success` lines to the existing examples at 167-172 and 211-214, e.g. `fail_if_success ltime_reflect using h` on `[G p] ⊢ H p`. The example count doesn't change.

**M3 (low, will block the linter): lines over 100 characters.**
- `TemporalComposition.lean:601, 614, 625, 638`; the project enables the Mathlib standard linter set.
- The same lines 592-642 reopen two namespaces four times and contain a stray blank line at 591.
- Fix: merge them into one TM section and one TM⁺ section, and wrap the lines.

**L1 (low): the inclusive equivalences are unused, `TemporalComposition.lean:597-642`.** They are definitional identity. The test uses `inclusiveUntil_expand` instead. Either drop them or have one test use them through `ltemporal_dual using`.

**L2 (low): misleading test comment, `ProofModeExtensionsTest.lean:201`.** `forwardInvariant`'s `hFrame` is an explicit parameter, not a hole inserted by elaboration. The example therefore doesn't exercise the new hole collection at all. Correct the comment; the M1 test covers the mechanism.

**L3 (low): two frame-gate policies.**
- `discreteFrame` (`Discrete.lean:41-54`) ignores a `hZ` certificate already in context; `integerTimeGate` (`Temporal.lean:172-181`) uses it.
- So `lstep` and `luntil unfold` behave differently with the same `hZ` in scope.
- Keeping the old proof terms for `lstep` is defensible. Either document the difference in the command table or have `discreteFrame` try the local certificate first.

**L4 (low): `timeReflectUsing` elaborates its term twice, `Temporal.lean:659-666`.** That breaks the elaborate-once rule. Elaborate once and branch on the type.

**L5 (low, docs):**
- Description placeholders remain at `Theorems/ProofMode/README.md:22` and `PlusLanguage/README.md:53`.
- `implementation.md` and `source-inventory.md` still describe P3 as staged or pending.
- `Modal.lean:108` says "(using, then keeping)" in errors for `lmodal_intro`, which has no keeping.

**Info:** `viewPairs` (`Temporal.lean:568`) leaves out `before` and `after`. A reflected goal therefore displays `reflectTime (before …)`. That is correct, just less readable.

## Deliberate limits, not bugs

- `keeping` accepts only G P / H P facts; carrying an X fact goes through `lstep` at integer time.
- `ltemporal_dual view` unfolds every exact occurrence; folding matches only the literal expansion.
- Inclusive Until/Since is a derived definition, not new syntax.
- Forward unfolding is integer-time only.
- No semantic features or native rank progress are on this branch.

## P3 requirement audit

Present: Until/Since fold, cases and introduction; exact duals and the inclusive translation; Base vs integer-time gates; contextual reflection; the generic `using rule` route; progress consequence and cases; `keeping`; the TM⁺ view choice, documented. The original `lprogress`, `luntil`, `lsince`, `linvariant` and `lstep` forms are preserved (the low-priority `lprogress using rule` doesn't shadow the list form).

Missing: only the T1 and T2 refusals (M2).

Untested but present:
- `luntil intro` / `lsince intro`
- the Since fold/unfold path
- `lprogress consequence` and `lprogress trans`
- `ltime_reflect using` on a fact
- `ltemporal_dual view` in both directions
- `keeping` for `lstep` and `ltemporal_intro`

One fixture combining `ltemporal_dual weakUntil` with a fold would cover the view code most cheaply.

## Remaining checks

1. Targeted build of `TemporalComposition`, the Automation modules and the shared test, especially the TM⁺ substitution checks for the four-argument transfers and `nextKeep`.
2. Rebuild `ProofModeTest.lean` after the M1 fix to confirm the original scripts still pass.
3. Linter and warning budget after M3; docstrings on public declarations look complete.
4. Module-invariant and layer checks, plus the README placeholders.