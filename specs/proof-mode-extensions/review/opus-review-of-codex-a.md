# Peer review of Proposal A (Codex), graded by Opus 5.5

Scope of this review: I made no tool calls this round. Claims about source declarations come from the brief's verified audit and the two proposals. Where A and B name different declarations, I flag the conflict for re-verification and do not pick a winner.

## Verdict

A is accurate and conservative, and it is well grounded in the audited semantic APIs. I found no route in A that would be unsound. Both backends build kernel-checked terms, and A never turns a semantic proof into a native one. A also gets several layering and reuse points right that B got wrong.

A's weakness is that it describes the native rewrite discipline in prose rather than as a typed composition algebra:
- `RewriteCertificate` is only a top-level `ProvIff`.
- The scope table says what each position needs but gives no premise types and no composition law.
- Every rewrite must be a full equivalence.
- The acceptance gates are a list of stories rather than concrete tests.

These are specification gaps, not soundness defects. They do block starting Milestone 2 with confidence.

## Scores

| Cat | Score | Main evidence and deductions |
|---|---|---|
| **C** (×3) | **8** | **Correct:** strict G/H/F/P; guard-first U/S with an open interval; the ZTime/Base asymmetry of `unfoldForward`/`unfoldBackward`; `unfoldBackwardSince` read correctly; conditional Next at Base; whole-□/⊡ state-locality; `.Base.Sat` includes regularity; `Conservativity.plus_soundness_in` with its correct namespace and layer; a TM `TruthCorr` is not a Plus certificate. **Deductions:** no Next/Prev semantic characterization; the local certificate type is ambiguous; Plus availability of the derived wrappers is not audited; `plusStateLocal_stab_iff` is not reconciled with B's `stab_of_stateLocal` / `isPlusStateLocal_box/stab`. |
| **P** (×2.5) | **7** | **Strong:** opaque providers; no Γ mutation; facts keep their point indices; goal transport must rebuild the original conclusion; transport covers preserved facts. **Deductions:** no demand-word composition law or demand monotonicity; no initial set of stronger-to-weaker discharge rules; equivalence-only rewriting; no story for how a rewrite inside an existing `lmodal_intro`/`ltemporal_intro` body gets its scoped premise; the examples are prose stories, not typed examples. |
| **R** (×2) | **8** | **Strong:** reuses `TruthClauses`, the `TruthCorr`/`TruthIso`/`TruthAntiIso` family, `HistMorphism.plus_invariance` and `ofTMSubst`; keeps the existing layers and enum; no new framework. **Deductions:** says nothing about how `ofTMSubst` transfer interleaves with ⊡ steps (F3); the global certificate cache adds new infrastructure with no consumer yet. |
| **A** (×1.5) | **7** | **Strong:** fuel counts matching attempts, not successes; repeated states are rejected; failures are transactional; ambiguous occurrences report candidate paths; no silent semantic fallback; registration checks kinds. **Deductions:** `lsimp` behavior for frame-gated rules is unspecified; "one-way phases" are not enumerated; no seed rule set; no way to freeze an `lsimp` run into an explicit script; the frame gate for `luntil unfold` is not specified. |
| **I** (×1) | **6** | **Good:** validation economy, a sensible rejection list, honest open obligations. **Deductions:** milestones have no per-milestone acceptance tests; the rejection matrix gives no concrete formulas, frame classes or outcome semantics (refusal vs exposed goal); measurements have no thresholds; no plan at the level of new declarations. |

**Weighted total: 3·8 + 2.5·7 + 2·8 + 1.5·7 + 6 = 74 / 100.**

## Readiness

- **Milestone 1 (inventory, prototypes):** ready.
- **Milestone 2 onward:** not ready until F1–F3 below are specified.
- **Soundness blockers:** none. Every native and semantic step is proof-producing.
- **Main risk:** the design may promise routes whose congruence premises have the wrong shape. That would surface during implementation as rewrites that cannot be built.

## Findings

**F1. A scoped certificate type and composition law are missing.** Class (b), high priority.
- `RewriteCertificate fc Γ old new := ProvIff fc Γ old new` is correct only at the whole formula.
- The §3 table says what each scope needs but gives no premise type for a hole under □/G/U, and no rule for composing a chain like □∘G.
- Specify:
  - a per-constructor step theorem with an explicit premise demand;
  - demand monotonicity (from `⊢ P→Q`, derive `⊢ D P → D Q`);
  - path composition as a word over demands;
  - goals use the backward direction of the whole-formula certificate, facts use forward.
- **Acceptance:**
  - A term-mode test turns `Γ ⊢ □G(A→B)` and `Γ ⊢ □G(B→A)` into `Γ ⊢ □G A ↔ □G B`.
  - `[p↔q, G p] ⊢ G q` fails with the exposed goal `Γ ⊢ G(p→q)` (or its iff form).
  - A closed rewrite under the path [G, X] at `.Base` succeeds without any ZTime hypothesis.

**F2. Rewriting is equivalence-only, with no polarity-aware monotone rewriting.** Class (b), bordering on (d).
- Several useful Base rules hold in one direction only: `futureCollapse` (FFA→FA), `untilImpF`, and the Dense-gated GG→G. A one-way scoped fact such as `G(A→B)` is also unusable under A's `ProvIff` discipline, even at positive positions.
- A's "one-way phases" are about orienting an equivalence; they do not cover implication-only rules.
- **Change:** add implication certificates whose direction follows the parity of the path.
- **Acceptance:**
  - `[F F A] ⊢ F A` succeeds via the oriented rule at a positive position, at `.Base`.
  - The same rule at an antecedent position is refused with a parity diagnostic.

**F3. The design does not say how TM and Plus congruence steps combine.** Class (b), high priority for P and R.
- "Transfer TM schemas with `ofTMSubst`" works step by step. It cannot work for a whole path that crosses ⊡, because the enclosing context is not a TM formula.
- Contextual premises would also need `ofTMSubst` applied over Γ.
- **Change:** specify that each non-⊡ step is a closed TM theorem transferred by `ofTMSubst`, that the ⊡ step uses `stab_k`, and that composition happens in Plus.
- **Acceptance:**
  - One rewriter proves a Plus rewrite along the path [□, ⊡, G] with arguments that contain ⊡.
  - A source check shows no duplicated Plus congruence module apart from the ⊡ step.

**F4. Next/Prev are missing from the scope table and from the semantic clauses.** Class (b).
- The X event position may use an X demand (`nextK`, any fc) or a G demand (`untilMonoEvent`). Closed premises should always take the G route so they never pick up a ZTime gate.
- The prose gets this right, but the table hides it under "future-scoped".
- `TruthClauses` has no `next`/`prev` characterization, so the semantic temporal layer has nothing to work with at discrete points.
- The source of `ZTime ≤ fc` for `luntil unfold` is unspecified.
- **Acceptance:**
  - `[X(A→B), X A] ⊢ X B` and `[G X A] ⊢ G X B` (from a closed `⊢ A↔B`) both succeed at `.Base`.
  - `next_iff`/`prev_iff` (using Covby, at Base) have `rfl` pins against `Formula.next` and `PlusFormula.next`, or are explicitly deferred.
  - `luntil unfold` at `.Dense` fails to elaborate.

**F5. A requires registered discharge rules but names none.** Class (b).
- The principle is right: stronger-to-weaker scope conversions must be registered, proved rules.
- With no initial rules, though, a `□(A↔B)` fact cannot discharge an F or G demand.
- **Change:** name the first set:
  - □→W for W over {□, G, H, ⊡}, via `modal4`, `temporalFutureDerived`, `temporalPastDerived` and `box_stab`;
  - G→G⁺ via `gTransitivity`;
  - native StateLocal→⊡ as a new theorem.
- **Acceptance:**
  - `[□(A↔B), F(C∧A)] ⊢ F(C∧B)` succeeds.
  - `⊢⁺ (□p ∧ ¬q) → ⊡(□p ∧ ¬q)` holds, or is documented as deferred.
  - A request to discharge ⊡ for `F p` is refused.

**F6. The transport interface has no type, and its direction is implicit.** Class (b).
- A's prose distinguishes fact transport from goal transport correctly but gives no signature.
- **Change:** define a source→target fact certificate and a target→source goal certificate (or an Iff-based one), each with a fragment predicate backed by a theorem. Record for each existing instance whether it is an Iff or one-directional: `truthAt_of_truthCorr`, `timeShift_preserves_truth`, StateLocal, and `plus_invariance`.
- **Acceptance:**
  - A one-directional certificate is accepted on a fact and refused on a goal, with a diagnostic.
  - State-equality transport of a bare `F p` is rejected.
  - A model mismatch is rejected.

**F7. Rewriting inside existing scope tactics is unspecified.** Class (b).
- Inside the body of `lmodal_intro` or `ltemporal_intro`, outer locals cannot be used. A scoped premise therefore has to be captured with `using [...]` at the scope boundary.
- A only says it preserves the `using` discipline.
- **Acceptance:**
  - Inside a □-intro body, a rewrite with an outer `A↔B` is refused with a message naming the required `□(A↔B)` capture.
  - The same rewrite succeeds once that fact has been captured.

**F8. Acceptance gates and enforcement are not concrete.** Class (b), affects I.
- Each milestone needs named tests with a specified outcome mode (`fail_if_success` or an exposed goal) and a frame class.
- The one-way rule (no semantic-to-native route) has no enforcement. The fix is an import-graph check that bans completeness and `BXCanonical` imports from `Automation/ProofMode` and `Theorems/ProofMode`.
- **Acceptance:** one compact test file per milestone; one CI import check.

**F9. Some source names conflict and need reconciliation.** Class (b), small.
- Audit release/trigger/weakUntil/weakSince on `PlusFormula`; the brief requires this.
- Reconcile the StateLocal lemma names that A and B give.
- Verify whether a Plus time-shift theorem exists. B tags `plusTruthAt_timeShift` as existing source; A lists Plus transport under time reindexing as possibly needing a new theorem.
- **Acceptance:** an inventory table of exact declaration names with `file:line` at commit `81ae7a6`.

**F10. `lsimp` frame gating, phases and caching are unspecified.** Class (b) for gating and phases, (d) for the cache.
- **Change:** gated rules fire only when their gate is decidable or already in context, and never spawn goals mid-run. Enumerate the phases. Drop the global certificate cache from the initial milestones in favor of auxiliary constants.
- **Acceptance:**
  - `lsimp` at `.Dense` logs a skip for a ZTime-only rule.
  - When fuel runs out, the original goal is left unchanged and the attempt count is reported.

## Where A is better than B

1. **Layering.** A puts the soundness adapters in `Metalogic/`, at layer 3. B puts its semantic layer in `Semantics/ProofMode/` and lets it import `soundness_in`. That violates the brief's rule that the soundness bridge stays above Semantics. This is an actual defect in B.
2. **Reuse of semantic transport.** A reuses `TruthCorr`/`TruthIso`/`TruthAntiIso` and `HistMorphism.plus_invariance`, and warns that a TM correspondence does not certify stability. B omits this whole family and builds ad hoc `sReflect`/`sShift` rows.
3. **No TM/Plus duplication.** A uses `ofTMSubst` and requires that Plus arguments containing ⊡ work without copying the rewriter. B proposes TM and TM⁺ twin modules, which will drift.
4. **Goal and fact point discipline.** A says eliminating an existential leaves the goal at its original point, that advancing to another point requires a theorem that rebuilds the goal, and that ambient facts are not silently copied to new points. B's transport table covers facts only.
5. **Automation details.** A counts attempts rather than successes, rejects repeated states, and leaves the goal untouched when a run fails.
6. **Smaller points.** A notes that a progress rank needs evidence that the event occurs. It records that `.Base.Sat` includes regularity. It defers Γ replacement instead of shipping B's awkward replace mode.

## Risks in my own B that A exposes

- **Layering.** B's semantic layer imports soundness from inside `Semantics/`, which the brief forbids. It should move to `Metalogic/` or `Automation/`.
- **Twin modules.** B's TM/Plus twin modules duplicate code. Rewriting Plus formulas with ⊡ arguments should go through `ofTMSubst` step by step, as F3 describes.
- **Fact-only transport.** B's transport rows only move facts. B needs explicit goal-direction certificates.
- **Possibly overclaimed sources.** B tags `plusTruthAt_timeShift` and `truthAt_rev` as existing source and proposes a new TM⁺ `box_const` analogue. A is more cautious here, so I should re-verify these and prefer `TruthAntiIso` if it subsumes `truthAt_rev`.
- **Unworkable guard.** B's `assert_not_exists` on bridges that produce `Classical.choice` cannot work, because `Classical.choice` is a core axiom. Comparing with A's lack of any enforcement made this visible. The guard should become an import-graph check that names the completeness modules.
