# Review: `feat/proof-mode-rewriting` (P0/P1/P2 only)

**Verdict: no-go for marking P2 complete.** I found no soundness blocker. Every proof the tactics produce is ordinary `DerivationTree`/`PlusDerivationTree` data that Lean's kernel checks, and there is no `sorry`, `admit`, `native_decide`, `unsafe` or `axiom` in the new files or the test file. But one frontend bug breaks the tactic's interface contract: it can silently fill in a formula or a piece of evidence that the rule didn't determine. That has to be fixed before approval.

**What this is based on:** I only read the code. I didn't build or run anything, as instructed. Statements about runtime behaviour below come from tracing the code paths. Several files changed while I was reading (for example, `Kit.ofEquality` and `formulaEqualityRewrite` appeared partway through). The line numbers are from my last read of each file.

## Findings

### F1 — High (bug): rule parameters get filled from arbitrary local variables
`Rewriting.lean:281-309` loops over every unassigned rule parameter. It assigns the first local variable whose type unifies with the parameter's type (lines 286-291). This applies to all parameters, not only side conditions that are propositions:
- A rule parameter of type `Formula` that the matched side didn't determine gets the first `Formula` variable in scope.
- A derivation premise whose type still contains a metavariable gets the first local derivation that unifies, which can also fix the formula inside it.

The check at `:347` ("undetermined formula parameter") runs inside `finishRewrite`, which happens after `resolveRuleParameters` (`:418`). By then the parameter is already filled, so the check never fires.

Concrete example: rewriting `provider : Γ ⊢ A` at a fact with `rule : ∀ X Y, ⊢[fc] X.imp (Y.imp X)` should fail because `Y` is undetermined. Instead it silently produces `Γ ⊢ A.imp A`, with `Y := A`.

`lsimp` makes the same call at `Simplification.lean:108`. There, the size-decrease check usually hides the problem, but nothing guarantees it will.

**Required fix:**
- Check the replacement for leftover metavariables before resolving any parameters.
- Only fill parameters from local hypotheses when the parameter is a proposition (frame gates); for `Formula`/`FrameClass`/derivation data, require the argument explicitly or fail.
- Turn any exposed parameter goals into synthetic-opaque goals; right now they are ordinary metavariables from `forallMetaTelescope`, which later unification can assign behind the user's back.
- Acceptance case: `fail_if_success lrewrite rule at provider as h` using the rule above.

### F2 — Medium (bug): new facts and exposed obligations aren't stated as the intended formula
- **Facts:** `finishRewrite` (`Rewriting.lean:350-352`) names the result of `modusPonens j proof source`. That result's formula comes from unifying `Formula.imp ?x ?y` against the kernel's `if flips then … else …` statement. So `?y` is `Step.wrap (Step.comp …) b`, not the `replacement` expression the planner computed. `lsimp` facts have the same problem (`Simplification.lean:125,137`). The goal path doesn't, because it types the new goal with `replacement` and checks it (`:354-357`). `lexact mapped` in the tests passes only because the two are definitionally equal.
- **Exposed obligations:** `:269-270` builds the obligation goal as `Step.demand certificate.step leaf`. The user sees a raw kernel expression instead of `□G(A→B)`.

The plan says `h'` is "a new derived fact" with the rewritten formula, and that the missing evidence is exposed as a real goal. **Required fix:**
- After an `isDefEq` check, give the fact the expected type `derivationType j Γ replacement` (`mkExpectedTypeHint`).
- Build the demanded formula from the planned demand word with `formulaApp`, check it is definitionally equal to `Step.demand …`, and use it as the obligation type.
- Pin both with `guard_hyp`/`guard_target` (syntactic form) in one existing example.

### F3 — Medium (bug): `lsimp` assigns the goal without checking it
`Simplification.lean:127-129` assigns `goal` from `modusPonens current certificate next` without the reconstruction check that `lrewrite` does (`Rewriting.lean:356`). A mismatch between planner and kernel would only show up as an error when the whole proof is checked at the end, not as an atomic failure of the tactic. **Fix:** reuse the same check, or route through `finishRewrite`.

### F4 — Medium (missing requirement / unclear contract): ambiguity is decided after scope discharge
`chooseRewriteOccurrence` (`Rewriting.lean:329-343`) only counts an occurrence as a candidate if the full `rewriteCertificate` succeeds, including scope conversion and direction. So if `p` appears twice and only one copy can be discharged, the tactic rewrites that one silently. The user never gets "missing scope" or "ambiguous" for the copy they may have meant. The plan lists ambiguous paths and missing scopes as separate atomic failures.

**Required (pick one):**
- Decide ambiguity from occurrences that match the formula only, and report why each was rejected; or
- Document "unique dischargeable occurrence" as the intended behaviour, mention skipped matches in the error/trace, and add one acceptance case.

### F5 — Medium-low (bug): metavariable state leaks while reading evidence; registry validation is weak
- `readRewriteEvidence` (`Rewriting.lean:150-165`): `operatorArgs?` probes using unification. If a rule's conclusion is headed by a metavariable, the probe assigns it (`?φ := □?x`, up to 64 levels deep). In the iff check at `:164`, the first `isDefEq` can succeed and leave its assignments behind when the second fails.
- Because `validateRewriteDeclaration` (`RuleRegistry.lean:37-44`) uses the same reader, a generic `(h : ⊢ φ) : ⊢ φ` would register as an equivalence rule.

**Fix:**
- Instantiate metavariables and reject conclusions whose head is a metavariable.
- Save and restore state around the iff check as a whole.
- Validate inside `withNewMCtxDepth`.
- Remove the redundant duplicate `isDefEq` at `RuleRegistry.lean:41-42`.

### F6 — Low (bug): `←` can't reverse a rule registered as reversed
`Simplification.lean:89` computes `reverse || registeredOrientation`. With `boxConjIff` (registered as reversed), `lsimp only [← boxConjIff]` behaves exactly like the unarrowed form. **Fix:** use exclusive-or (`!=`).

### F7 — Medium-low (spec deviation): composite views are expanded silently
For operators without a registered view (such as `iff`, `top`, `after`, TM `weakUntil`/`release`, user definitions), `positionChildren` (`Positions.lean:78-80`) reduces the head with `whnf` and enumerates its primitive positions. `Position.replace` (`:83-84`) then rebuilds the formula from primitive constructors.

So rewriting inside `A ↔ B` quietly works on one copy of a duplicated argument and loses the `iff` form. The paths refer to a tree the user can't see. The plan requires an explicit unfold or a proved operator-level congruence for views that duplicate arguments, plus a trace of the expanded occurrences.

**Fix:** stop the `whnf` fallback for known duplicating wrappers, or trace the expanded occurrences. Document whichever you choose.

### F8 — Medium (missing P0 item): no Base Since fold
The P0 go/no-go criterion and the ledger (`implementation.md:20-21`) both include the "Base Since fold" prototype. I found no such theorem in this branch. Either add the closed theorem, or record in `implementation.md` that it moves to P3, with the reason. It is a P0 prototype, not just P3 frontend work.

### F9 — Medium (missing tests): several routes the planner depends on are never run
- **Finite scope routes** (`scopeConvert`, `Rewriting.lean:211-243`): none are exercised — not □→G/H/⊡, not the `modal4`/`gTransitivity`/`hTransitivity` iteration, and none of the TM⁺ adapters. The tactic calls these declarations through `mkAppOptM` with argument lists that are only checked when the tactic runs. A signature change in any of them would only surface interactively, which the plan says must not happen.
- **Exact conditional Next** (`exactNext`, `:65-70`): the R3 case "X(A→B) maps an existing X A at Base" isn't tested.
- Not exercised:
  - Boolean seeds (`doubleNegationIff`, `conjunctionSelfIff`);
  - FFA→FA in its supported direction;
  - rejection of a Lean `Iff` as native evidence.

**Minimum to add (about two examples):**
1. One `lsplit` example covering box→future (`mapping : Γ ⊢ (A.imp B).box` applied to `provider : Γ ⊢ A.allFuture`), G→GG iteration, and an exact `X(A→B)` at Base.
2. One `lsimp` step using `doubleNegationIff` together with `futureCollapse` (fact direction).

That keeps the suite small, as you asked.

### F10 — Low (diagnostics)
The plan asks for an opt-in trace of the applied theorem, path, evidence route, frame obligation and output.
- `proofMode.rewrite` (`Rewriting.lean:276`) logs the path and demand but not the rule or the route taken (exact / closed / conversion / exposed).
- `proofMode.simp` (`Simplification.lean:134`) logs only counters.
- `catch _ => attemptState.restore` (`:117`) throws away every skip reason.
- In automatic mode, the error reports only the last occurrence's failure (`Rewriting.lean:337`).

### F11 — Low (future work or optional)
- `adaptProof` (`Meta.lean:216-221`) only lifts derivations proved at Base. A rule stated at a fixed frame class like Dense can't be reused at a larger concrete class even when `≤` is decidable. This is fine for P2 as long as gated rules take a `(h : X ≤ fc)` parameter, as `density` does. P3 should either keep to that convention or add decidable lifting.
- Each rule term is re-elaborated for every (occurrence × rule) attempt in `lsimp`, and up to three times in `nativeRewrite` (`:402,407,414`). This is bounded but wasteful.
- `liftClosed`'s Next/Previous error branch (`:206`) can't be reached, because closed evidence always takes the G/H route. That is correct behaviour; maybe add a comment.

## What checks out against the plan
- **Kernel** (`Congruence.lean`):
  - `Step.comp` handles all four polarity combinations generically and nests demands outermost-first.
  - Every transfer-table row is tied to its closed source schema, including `nextK`/`prevK` and the G/H route with guard ⊥ for X/Y.
  - TM⁺ reuse happens step by step via `ofTMSubst`, with stability proved natively; the substitution pins are definitional.
  - Next/Previous demand monotonicity never asserts X(P→Q).
- **Direction:** `reverseOriginal = goal ⊕ flips ⊕ symm` (`Rewriting.lean:253`) matches the plan's polarity table. I checked fact/goal × positive/negative × `←` by hand.
- **Equivalences** are projected through `lceImp`/`rceImp` and lifted through the composed demand monotonicity. Formula equality goes through `Eq.mp`/`Eq.mpr` or `Kit.ofEquality` only. A Lean `Iff` falls through to the "expected a native rewrite rule" error.
- **Scope handling:** current-only evidence can't enter a scope. The finite conversion table has no chaining. Closed evidence through X takes the G route. Γ stays the same for facts.
- **Frame gates:** concrete incompatible classes are rejected even with `expose`; available or decidable gates are discharged; abstract ones are exposed only on request.
- **`lsimp`:** decrease is checked on the actual instantiated whole formula, orientation is fixed, budgets are enforced, failures roll back, and "no change" fails.
- **State:** saving and restoring around `nativeRewrite`, `nativeSimp`, each simp attempt and each occurrence probe is correct.
- **Opaque providers:** they are only referenced, never unfolded. `assert_not_exists` guards are present at both roots.

## Grades (fixed rubric)

| Category | Score | Main deductions |
|---|---|---|
| C — correctness / source grounding (×3) | 6.5 | F1 (invents formulas/evidence), F2/F3 (fact/obligation types, missing goal check), F5 state leak, F8 missing P0 item |
| P — compositionality / scoped opaque reuse (×2.5) | 7.5 | Kernel and stepwise TM⁺ reuse are strong; F7 hidden view expansion; scope routes never run (F9) |
| R — reusability (×2) | 7.0 | Generic kernel and one shared planner; output types aren't the expected formulas (F2); the iff projection pairing lives in the frontend rather than the kernel |
| A — bounded / predictable automation (×1.5) | 6.5 | Budgets, decrease and rollback are good; F4 dischargeability-based choice, F6, natural-metavariable goals, silent skips (F10) |
| I — clarity / validation economy / maintainability (×1) | 6.5 | Compact and well documented; coverage gaps on the most fragile routes (F9), repeated elaboration |

**Weighted total:** 3(6.5) + 2.5(7.5) + 2(7.0) + 1.5(6.5) + 6.5 = **68.5 / 100**

## Before P2 can be approved
1. Fix F1, with the acceptance case.
2. Fix F2 and F3 (expected-type fact, readable obligation, goal check in `lsimp`).
3. Resolve F4: change the behaviour or document it with a test.
4. Fix F5 and F6 (small fixes).
5. Add the about-two compact examples from F9.
6. Add the Base Since fold or record its deferral (F8).

F7 and F10 can be documented as known limits for this branch.

The README, root import, inventory, count updates and the completion ledger (`implementation.md:20-37`, still all unchecked) are bookkeeping that is still in progress. I didn't count them against the score. Final gates and the full-library build haven't run and aren't claimed. The overall P0–P5 goal is not complete; P3–P5 belong to the temporal and semantics branches.