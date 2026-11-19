# Opus 5.5 independent review: `feat/proof-mode-semantics` (branch 3, P4/P5)

**Readiness: NO-GO as the branch stands.** It becomes GO once H1 and M1 are fixed (both are small) and the pending integration gates pass. M2 must be either implemented or recorded as deferred before the P4 box is ticked.

**Grade: 82.5/100.**

| Criterion | Score | Weight | Points |
| --- | ---: | ---: | ---: |
| C: correctness and source grounding | 8.0 | ×3 | 24.0 |
| P: composition | 8.8 | ×2.5 | 22.0 |
| R: reuse | 8.5 | ×2 | 17.0 |
| A: predictable, bounded automation | 7.8 | ×1.5 | 11.7 |
| I: clarity and validation economy | 7.8 | ×1 | 7.8 |

I reviewed the actual integrated files at HEAD plus the untracked branch-3 files, using Read/Grep only. I ran no build and no check. Where I say a test passes, that comes from your statement that the tests currently compile, not from me.

## What I checked and found correct
- **Signed-path kernel** (`Semantics/ProofModeRules.lean:176-274`):
  - `Step.comp` combines polarity with exclusive-or and nests demands outermost first. All four sign cases of `compTransfer` are real proofs.
  - Fact and goal directions in `rewriteFact`/`rewriteGoal`/`…OfIff` match the plan's role/polarity table.
  - The frontend's choice `reverse := (goalRole != flips) != symm` (`SemanticRewriting.lean:329`) gives all eight role/polarity/`←` combinations correctly.
  - A wrong frontend `flips` count is caught at `mkAppOptM` against `S.flips`.
- **Demands:** □, ⊡, G/H and the X/Y cover demands match their clauses exactly. ⊡ uses `p.history.state p.time = σ.state p.time`. Until/Since use G/H, and the guard only ever appears on the open interval.
- **Turning formula evidence into Lean families** (`truthRelationFamily`): comparisons are made per point at the leaves by `samePoint` before formulas. A point-specific `Iff` cannot meet a quantified demand; `alignFamily`, plus the descent that fails at the leaf, rejects it. The `∀ p : Point` families work through `matchPointParameters`, which assigns only Point parameters whose components are read from that same point (eta), and never guesses a second point.
- **Next/Previous** use covering times (`⋖`) and uniqueness of the cover. There is no successor function or ZTime assumption, and `lstep` only uses a cover taken from an existing X/Y fact.
- **Strict U/S:** the witness and cases commands keep the order, the event and the guard on the open interval. The inclusive lemmas handle the endpoint correctly.
- **Soundness seam:** it requires an explicit `fc.Sat F` and accepts an abstract Γ, and it keeps the exact model, history and time. There is no route from semantic proofs back to native derivations: `factJudgment`, `applyRule` and `semanticApply` reject derivation data. Completeness is guarded by `assert_not_exists`.
- **`applyRule`:** only holes created by this call become goals. Proof premises are synthetic-opaque; data goals are natural and come last.
- **Transport:** the target point comes only from the `hR` evidence. Unresolved points or data are an error; only PUnit environments and StateLocal premises are filled automatically. A one-way certificate is never inverted. Reflection moves to `M.rev`, `τ.rev`, `-t`, and a same-model result needs an explicit certificate.
- **Rank progress** keeps the occurrence premise and works over any preorder. Semantic `linvariant` refuses to invent an induction rule.

## Findings

**H1 (High; functional regression, not soundness): `SemanticRewriting.lean:435-444`**
- **Problem:** this adds a second command elaborator for `register_lrewrite`. Lean tries the newest command elaborator first and moves to the next one *only* on `unsupportedSyntax`. Native declarations make `readEvidence` → `instantiateSchema` throw an ordinary error ("expected indexed semantic truth…"). So any module that imports `Semantic` (including the root aggregator) can no longer register native rules.
- **Why nothing fails today:** the only native registrations are in `Simplification.lean:23-32`, which is built before this file. No test exercises the regression.
- **Minimum fix:** in `registerSemanticRule`, check first whether the declaration's telescope ends in a native `judgment?`. If it does, throw `throwUnsupportedSyntax` from `CommandElabM`, outside `liftTermElabM`. Alternatively, use one registrar that dispatches on the conclusion. Add one native `register_lrewrite` line to the test file after the `Semantic` import.

**M1 (Medium-Low; the review record and the code disagree): `SemanticRewriting.lean:390`**
- **Problem:** `formulaEqualityRewriteProof fake raw symm path` is called without `resolveParameters`, so equality rewrites fall back to the native `resolveRuleParameters`. That resolver matches local side premises with plain `isDefEq`. `codex-branch3.md:24-25` says the semantic resolver is passed here; the current source does not do that.
- **Fix:** pass `(resolveParameters := resolveSemanticParameters)`.

**M2 (Medium; unmet plan detail, §5.1 "Duals/weak variants" semantic route)**
- **Problem:** there are no semantic characterizations of `weakUntil`/`weakSince`/`release`/`trigger`. Only the inclusive views (`ProofModeIntervals`) exist, and `Semantic.lean:7-9` does not import that module; only the test does.
- **Fix:** add about four generic `_iff` lemmas. Each needs a definitional pin against the literal TM wrapper, which puts the event first. Then import `ProofModeIntervals` from the aggregator or the root, or record the deferral explicitly in the ledger.

**L1 (Low; index hygiene): `SemanticMeta.lean:133-146`**
- **Problem:** `indexedDefEq` only walks through `Iff`/`And`/`Or`/`∀`. For `Not` (not reducible), `Exists` and other connectives it falls back to `isDefEq`. Truth that ignores its indices (⊥, ⊤, □) can then let a local hypothesis at another history discharge a semantic side premise. The result is still a valid proof, but it breaks the stated rule that indices are compared by name.
- **Fix:** unfold `Not` and add an `Exists` binder case. Otherwise, reject any premise that contains truth at an unhandled position.

**L2 (Low; diagnostics): `SemanticRewriting.lean:306-313`**
- **Problem:** the catch-all in `demandProof` turns specific failures (pending side conditions, language mismatch, one-way direction) into the generic "missing indexed semantic scope evidence".
- **Fix:** keep the first error and report it when the descent fails.

**L3 (Low; clarity): `SemanticRewriting.lean:342`**
- **Problem:** with `obligations := expose`, the exposed goal is shown in raw kernel form: `Step.demand (Step.comp …) (IffAt …) ⟨…⟩`.
- **Fix:** before creating the goal, unfold `Step.*Demand`, `IffAt`, `OrientedAt` and the `Point` projections. The result is definitionally equal.

**L4 (Low; a test that proves less than it claims): `Tests/…/ProofModeExtensionsTest.lean:354`**
- **Problem:** the "bare `F p`" refusal is rejected only because `F p` does not match `.stab ?φ`. It never reaches the state-locality check in `stateLocalProof`.
- **Fix:** aim this line at `plus_iffTransport_stateLocal` with a same-time `SameStateNow`. This changes one line and adds no test.

**L5 (Low; test gaps for refusals the code already makes)**
- **Missing:** semantic refusals for:
  - `lexact` of ⊥/□ at another history;
  - `keeping` a point-local fact;
  - the semantic twin of `[A, G(A→F B)] ⊢ F B`.
- **Fix:** add at most two `fail_if_success` lines inside the existing S2 twin and soundness examples.

**L6 (Low; usability): `SemanticCore.lean:482`, `SemanticSimplification.lean:59`**
- **Problem:** rules are elaborated with no expected type and `mayPostpone := false`, so generic clause theorems need an explicit `(L := Formula)`. Semantic `lsimp` also re-elaborates every rule for every occurrence.
- **Fix:** elaborate each rule once per run, or postpone instance resolution until the conclusion has been unified with the goal.

**L7 (Low; reuse and clarity)**
- `SemanticTransport.lean:74,225,243` adds private `judgment?` (which shadows the native name), `present` and `transactional`, duplicating `SemanticCore` and `SemanticMeta`. `truthJudgment?` already strips `mdata`.
- `SemanticCore.lean:92-97` is an empty, stale section header left after the wrappers moved to `ProofModeTemporalRules`.

**L8 (Low; dispatch): `SemanticRewriting.lean:449`, `SemanticSimplification.lean:110`**
- **Problem:** `lrewrite`/`lsimp … at h` choose native or semantic handling by the main goal, not by `h`. A semantic fact cannot be rewritten while a native goal is the main goal, and vice versa.
- **Fix:** dispatch on `h`'s type when `at` is present, or document the limitation.

## Status of the P4/P5 ledger
- **P4:**
  - **Met:** clause helpers, Next/Previous over covering times, the modal/temporal/U-S frontend, the explicit soundness seam, strict indices, and the mixed □/⊡/G rewrite prototype.
  - **Open:** M2 (semantic duals) and the layer, README and inventory registration for the new `Semantics/` files that import `PlusLanguage/*`.
- **P5:**
  - **Met:** typed fact/goal/iff transport over the existing correspondence routes, `keeping` across repeated advances, the two-provider composition twin, and rank progress with its occurrence and endpoint premises.
  - **Open:** only the L4/L5 refusal-fixture gaps.
- **Integration:** H1 must be fixed. Gates, counts, the axiom audit and the README/inventory/book sync have not been run, and I am not claiming them.

The historical grades stay as recorded. Codex's 87.2 and this 82.5 differ mainly because of H1 and the M1 mismatch between the record and the source.