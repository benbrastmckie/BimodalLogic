# Branch 3 closeout

Scope: P4/P5 on `feat/proof-mode-semantics`, stacked on temporal commit `1f545ea`.
The [completion audit](../completion-audit.md) maps all P0–P5 requirements to the implementation.

## Reviews and dispositions

Codex's initial grade is **87.2/100**. Opus 5.5's independent initial grade is
**82.5/100, NO-GO**. Both [Codex](codex-branch3.md) and [Opus](opus-branch3.md) reports remain
unchanged as historical assessments. Opus's [source closeout](opus-branch3-closeout.md) gives
GO, conditional on the actual final checks; it does not raise the original score.

- **H1, fixed:** semantic registration explicitly declines a native conclusion from CommandElabM,
  allowing native command fallback. A native registration after the semantic import is in the
  shared suite. A separate monomorphic semantic registration/normalization probe also passes.
- **M1, fixed during review:** semantic formula equality passes the indexed resolver into the
  common equality planner. Negative and positive controls exercise gated equality; the same-point
  condition succeeds while other-point conditions under negation/exists are refused.
- **M2, implemented:** four generic release/trigger/weak U/S truth lemmas plus eight literal
  event-first TM/Plus pins are in `ProofModeIntervals`, imported by the semantic aggregator.
- **L1, hardened:** nominal comparison covers Not, Exists, forall and the Boolean connectives;
  unsupported semantic positions require explicit proof. Bounded alias unfolding stops at truth
  heads. Exactly identical types remain reusable without unfolding.
- **L2/L3, fixed:** leaf failures retain their cause. Exposed demands show quantified truth rather
  than raw Step records. Presentation reduces only known Point projections and is checked defeq.
- **L4/L5, strengthened:** the locality refusal reaches the recognizer through SameStateNow;
  current-only advance, local keeping and history-erasing Top refusals have focused examples.
- **L7, refactored:** transaction/point helpers live in SemanticMeta. Redundant judgment aliases
  and the stale wrapper section were removed. Transport's distinct judgment presentation preserves
  model/history provider constants instead of delta-unfolding their data.
- **L6/L8, documented policies:** explicit carriers for generic rules; bounded per-attempt
  freshening; backend selected from the main goal. Mixed-kind facts use a matching `have` subproof.
  Caching remains an optional measured optimization, as the plan specifies.

The native registrar accepts native tree conclusions only, not bare formula-data equalities;
Opus's final registrar-shape question therefore requires no additional dispatch case.
The registration regression was tested after its fix, not observed red against the old source.

## Reuse and trust

Pure semantic transfers, covers, persistence, rank and one-way transports are generic over the
existing clause capabilities. Explicit temporal wrappers remain lower-layer reusable lemmas.
The only native adapter applies the existing soundness theorem with the exact frame/model/point
and abstract Γ environment. Native proof-mode roots retain their completeness dependency guards.
No new axiom, sorry, unsafe or native_decide is introduced. A source scan and representative
axiom prints (including the new duals) confirm only the existing standard Lean axioms.

## Validation

- Final `lake build FormalSystem BimodalTest.Automation.ProofModeTest
  BimodalTest.Automation.ProofModeExtensionsTest --wfail`: passed.
- Final `lake exe runLinter FormalSystem`: passed, without suppressions or baselines.
- Final full `scripts/check-module-invariants.sh`: **ALL CHECKS PASSED**, including builds,
  the enforced environment linter, layer/import checks, generated root and tool roots.
  The script separately reports its existing non-enforced other-root linter TODOs; this is not
  a claim that every optional repository-wide linter is clean.
- Shared regression suite uses the actual integrated syntax; no probe-only parser survives in
  tracked tests. The semantic/native registration probe and the guide's Lean example compile.
- Post-fix axiom audit: signed composition and covers use propext; the audited rank, transport,
  inclusive/dual and soundness results use subsets of propext, Classical.choice and Quot.sound.
- Final generated root, README inventories, automation map and book status counts are current.
  README lint: PASS. `typst-sync-check.sh`: PASS, all four checks. `git diff --check`: clean.

Checks reused the pinned Lean/Mathlib RAM cache. Lake's ~3,000 job total includes cached
prerequisites; only changed modules rebuilt. Review fixes justified affected reruns. No clean
build or exhaustive operator/profile test matrix was introduced.

## Prototype baseline

For opaque guarantees □G(A→B) and □G(A∨C), consuming □G(B∨C), the generated consumer has
**2,233 native / 931 semantic expression nodes**, counting parameter types and repeated syntax
without sharing. The counter traverses only the generated consumer; it never follows constant
bodies. This is a structural baseline on the pinned toolchain, not a runtime or asymptotic promise.
Both providers are local references. The original native simplifier trace baseline remains in
the branch-1 closeout. The shared extension module compiles in about 2–3 seconds with dependencies
cached in the recorded runs.
