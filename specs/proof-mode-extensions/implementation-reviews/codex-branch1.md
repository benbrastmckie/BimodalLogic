# Codex review: rewriting branch, first draft

Scope: native P0/P1/P2 code on `feat/proof-mode-rewriting`, before reading Opus's independent
review. Opus authored the original congruence kernel; Codex authored the frontend, casts,
finite scope adapters, Boolean seeds, registration and simplifier. P3–P5 are separate branches.

## Grade

| Category | /10 | Assessment |
| --- | --- | --- |
| C | 8.5 | Closed signed transfers compose in all four cases; Plus substitution is checked at its actual target type; conditional Next does not invent existence. Native and data-equality routes are separate. Final adversarial matching/equality checks and axiom reporting remain. |
| P | 8.5 | Fact rewriting retains Γ; goals use the reverse whole-formula implication; scoped equivalence projects through a proved demand word. Opaque providers appear as local/constant references. Equality occurrence policy needs to match the logical policy. |
| R | 8.5 | One kit/path compiler serves TM and Plus, stability is a native step, scope conversions and seeds reuse existing source theorems. Semantic replay can reuse positions but is not claimed implemented here. |
| A | 8 | Explicit rule order, concrete-instance decrease, finite traversal/match/scope budgets, no speculative simp side goals, and transaction rollback are implemented. Equality matching and frame-gate adversarial examples need final verification. |
| I | 7.5 | Core modules and compact examples compile; original proof-mode examples retain compatibility. The generated inventory/root, final source gates, review closeout and broader integration evidence are still outstanding. |

**84.75/100** (`25.5 + 21.25 + 17 + 12 + 7.5`). This is a draft implementation review, not a
completion certificate. No identified soundness blocker; do not mark branch completion until
the items below and applicable integration checks are resolved.

## Required closeout

1. **Equality occurrence consistency:** the logical route rejects ambiguity, whereas the initial
   equality route delegates to Lean's rewrite traversal. Verify/pin a common occurrence contract,
   including an explicit path, without changing Γ. Distinguish literal formula equality from a
   point-specific logical equivalence.
2. **Registration and concrete gates:** validate the actual declaration telescope, retain frame
   premises, and prove that an impossible concrete Dense/ZTime gate is rejected even in expose
   mode. The current helper uses kernel-reduced `decide`, never `native_decide`.
3. **Validate the finite conversions and Eq simp path:** exercise them with the existing shared
   fixtures where possible. No need for a profile-by-constructor Cartesian test suite.
4. **Repository integration:** finish READMEs/root/count owners, source/axiom audit, affected
   integration targets and existing gates. Record what passed rather than treating a dependency
   job count as hundreds of builds.

The pure kernel's construction is sound by inspection and elaboration: `Step.comp` lifts the
inner closed transfer through the outer demand, then uses the correctly swapped outer transfer.
Plus `demandMono` is built from Plus necessitation/K, and its X/Y cases use G/H event monotonicity.
No proof value is evaluated to recover its assumptions, and no model truth is accepted as native
derivation data. Integration must preserve those properties.

Last updated: 2026-11-19.
