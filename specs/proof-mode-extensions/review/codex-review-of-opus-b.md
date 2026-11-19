# Codex review of Opus proposal B

Date: 2026-11-19. Reviewed independent proposal B before seeing Opus's grade of proposal A. Source baseline is `81ae7a6`. Scores are subjective design assessments, not formal correctness certificates.

| Category | Score /10 | Evidence and deductions |
| --- | ---: | --- |
| Correctness and source grounding | 7.5 | The demand-transfer kernel, conditional Next route, strict unfolding asymmetry and most source citations are strong. The completeness argument is misstated; one claimed-new Plus theorem already exists; implication-only normalization and the soundness layer need correction. |
| Compositionality | 7.5 | Opaque statements, explicit demands, parity and full-context reflection are good. Rewriting has inconsistent defaults for identically typed locals; semantic goal transport and keeping persistent facts across repeated advances are not fully specified. |
| Reusability | 8.0 | Small transfer interfaces and TruthClauses reuse are valuable. The semantic layer imports upward, new semantic syntax duplicates the existing frontend, and some proposed APIs duplicate existing transport support. |
| Automation | 6.5 | Ordered discharge and fuel are concrete. Fresh-atom size checks do not establish instantiated decrease; fuel accounting, exhaustion/rollback and goal-versus-fact direction require a tighter contract. |
| Implementation/validation economy | 6.5 | Dependencies and named theorem debt are explicit. Eighteen cases per milestone implies excessive duplication; repository integration constraints and prototype gates need more precision. |

Weighted total: **73.5/100** (`3×7.5 + 2.5×7.5 + 2×8 + 1.5×6.5 + 6.5`). Readiness: **revise before implementation**. The typed theorem kernel is a promising basis, but the architecture and normalization contract are not ready to freeze.

## Findings

### B1 — actual architectural defect: soundness is placed below its dependencies

Proposal B §0 places semantic modules under `Semantics/ProofMode/` and permits importing `soundness_in`/`plus_soundness_in` there. `ORGANISATION.md` puts Semantics at layer 1 and Metalogic/Automation at layer 3. `TruthTransport.lean` explicitly guards against ProofSystem imports. This introduces the very upward dependency the plan claims to avoid.

Revision: keep pure semantic clause/transport wrappers at layer 1; put native-to-semantic soundness consumers at the layer-3 seam, imported by Automation. Acceptance: the existing layer/cycle gate must remain unchanged and pass; a pure semantic module must not acquire derivation constructors in its import closure.

### B2 — actual mathematical misstatement: weak completeness is not the reason to forbid the reverse bridge

Proposal B §1 says weak completeness makes even a theoretical route unavailable for contextual goals. Here Γ is a finite list. Global finite-context consequence can be internalized into a closed implication and handled by weak completeness plus deduction. The genuine issue is that truth in one chosen model is not all-model validity; furthermore the design intentionally forbids completeness-based extraction into native data.

Revision: distinguish model-specific truth, validity over a frame class, finite-context consequence, and computational native derivation construction. Keep the reverse bridge absent for those actual reasons. Acceptance: no statement that weak completeness alone prevents finite-context completeness.

### B3 — missing specification with correctness consequences: signed rewrites must include target role

Proposal B correctly mentions goal reversal, but its simp seed discussion says `FFA → FA` can simplify positive positions without distinguishing goals from facts. A positive fact can move FFA to FA; replacing a positive goal FFA by FA would need the false converse on integer time.

Revision: make goal/fact role an input to certificate planning. Required hole implication for `A ↦ B` is A→B for positive facts/negative goals, B→A for negative facts/positive goals. Equivalence supplies both. Acceptance: a minimal temporal-collapse test succeeds in the supported fact direction and rejects the opposite goal direction. This must not be inferred from a Boolean "positive" tag alone.

### B4 — missing specification: contextual rewrite defaults depend on provenance

Proposal B §2.5 gives the same `lrw e at h` form different behavior for a derived local and an object assumption. Current `lstart`, `lintro` and ordinary Lean `have` ultimately provide locals of native derivation type; that type alone does not reliably distinguish their origins. Discovering that distinction by unfolding proof values violates the opaque-interface goal.

Revision: use a uniform derived-fact rewrite producing a new named proof at unchanged Γ. Any later cut/context-replacement operation must have explicit syntax and typed context correspondence. Acceptance: two opaque inputs with the same judgment type behave the same regardless of how their proof bodies were obtained.

### B5 — automation defect: one fresh-atom instantiation cannot certify decreasing size

Proposal B §2.7 marks rules decreasing by comparing one fresh-atom instance. A rule that duplicates a metavariable can grow after substituting a large formula even if the small instance decreases. Fuel preserves termination, but the classification and O(n) claims are not justified by that sample.

Revision: test the chosen well-founded measure on the actual instantiated before/after formulas, or prove a schematic decrease theorem. Count failed matches and scope-discharge attempts, specify what happens at exhaustion, and bound unification/elaboration via Lean's normal resource controls. Make default exhaustion atomic with an unchanged goal. Acceptance: a substitution-growth case and a cyclic-rule case terminate with the documented result; no silent partial-normal-form claim.

### B6 — source-reuse correction: Plus box constancy is already present

Proposal B §4.2 marks the Plus analogue of `Truth.box_const` as new theorem work. `PlusTruth.box_global` already compares box truth across arbitrary histories/times; `box_time_invariant`, `plusTruthAt_timeShift` and `stab_state_only` are in the same source file. `PlusReversal.plusTruthAt_rev` is also available in `PlusLanguage/PlusReversal.lean`.

Revision: consume the existing results. A genuinely general Plus truth correspondence beyond these concrete routes remains separate proof debt. Acceptance: the implementation map distinguishes existing adapters from new theorem work.

### B7 — missing compositional contract: goal transport and persistent context

The transport table documents facts, while a semantic focus change also needs a way to reconstruct the original conclusion. The design does not specify how `ladvance` retains a G-guarantee for a second eventuality step rather than merely obtaining its body at the first witness.

Revision: distinguish existential elimination (original goal unchanged), eventuality bind (goal reconstructed by a proved rule), and arbitrary point changes (explicit goal-transport theorem). Introduce explicit `keeping`/transport evidence for selected persistent facts; native G4 and the generic semantic future-persistence proof provide reusable routes. Acceptance: compose two opaque eventuality providers with a retained G-assumption across two advances, and reject the same operation on a bare point-local fact.

### B8 — validation-economy problem

Proposal B §7 suggests about eighteen examples in one file per milestone. Six milestones would accumulate roughly 108 examples, many from a language/frame/outcome Cartesian product. The user explicitly asked for a compact meaningful suite. The blanket statement that no full build is needed also ignores the actual standard counter generator's need for a built root module.

Revision: one shared set of mechanism-driven scenario families, reusing fixtures and only adding cases for distinct proof obligations. Use touched-module checks while developing; one appropriate integration build at milestone/merge, reusing caches. This design-only task requires no library rebuild.

### B9 — scope and unresolved-theorem decisions

Native `stabOfStateLocal`, the demand-word congruence and boxed-discharge theorem are legitimate new theorem obligations, not source defects. They should have prototype gates before tactic plumbing. Directional matching, automatic demand weakening, context replacement and the new `s*` syntax need explicit decisions rather than being implicitly bundled into the first release. The closed/local distinction and no-inspection-of-provider-bodies constraint should stay non-negotiable.

## Ideas from B to adopt

1. A demand-transfer theorem at each operator, composed into a certificate, is more precise than a collection of ad hoc scope checks.
2. Conditional Next congruence at Base, with a G/H route for closed theorems, avoids unnecessary ZTime restrictions.
3. `FFA → FA` and Dense-only `GGA → GA` are excellent tests against false temporal equivalences.
4. Whole-context reflection can reuse the existing liftContext architecture after its exact typed transformation is proved.
5. A future-introduction rule combining persistent guard and eventual event is a useful compositional Until operation even before discrete unfolding.
6. The existing reversal and Plus time-shift support reduces the amount of new semantic mathematics required.

No request here is to replace the core with stronger proof search. The revisions should make small theorem applications predictable and reusable.
