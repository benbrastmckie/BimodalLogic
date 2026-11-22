# Mutual design review

Date: 19 November 2026. Scope: future checked rewriting/simplification, richer temporal rules
and a pointed semantic backend for the public TM/TM⁺ proof mode. The
[joint plan](plan.md) is the proposed specification; these are design judgments, not proof
certificates or claims that the new tactics have been implemented.

## Process and model

Codex and **Claude Opus 5.5** wrote independent proposals against the same brief and pinned
source tree, then graded each other's proposals. Codex wrote A before reading B, and wrote
its review of B before reading Opus's grade of A. Opus received neither A nor Codex's grade
while writing B. Both proposals and both reviews are preserved in the
[archive](review/README.md).

Opus ran through the local Claude CLI with the explicit model `claude-opus-5-5`; returned
metadata identified the same canonical model and first-party provider. Its independent source
research allowed only Read/Grep/Glob tools. Review rounds used supplied source-audit packets
with tools disabled. No other model was substituted. Safe mode disabled local customizations.

Codex audited the actual source declarations and repository layers. The brief's initially
guessed time-shift/soundness paths were corrected from those sources before the peer-review
round. Later rounds reused that audit rather than repeating a broad source crawl.

## Fixed rubric and independent grades

Scores are out of 10 per category. The weighted total is
`3*C + 2.5*P + 2*R + 1.5*A + I`, out of 100.

| Category | Weight | Meaning |
| --- | --- | --- |
| C | 30% | Proof-theoretic/semantic correctness and source grounding |
| P | 25% | Scoped composition, opaque guarantees and retained premises |
| R | 20% | Reuse and disciplined extension boundaries |
| A | 15% | Bounded, predictable, explainable automation |
| I | 10% | Implementation clarity, validation economy and maintainability |

A 10 means no identified design blocker; 8 means strong with concrete gaps; 6 means major
obligations remain implicit; 4 or below means an unsound or unusable route. Any unresolved
soundness blocker vetoes readiness regardless of score. Scores are subjective; no target score
or agreement was required.

| Reviewer → independent proposal | C | P | R | A | I | Total |
| --- | --- | --- | --- | --- | --- | --- |
| [Codex → Opus B](review/codex-review-of-opus-b.md) | 7.5 | 7.5 | 8 | 6.5 | 6.5 | **73.5** |
| [Opus → Codex A](review/opus-review-of-codex-a.md) | 8 | 7 | 8 | 7 | 6 | **74** |

These initial grades remain unchanged after revision. They were useful because each proposal
had concrete gaps; neither designer treated a plausible architecture as an implementation spec.

## Findings and decisions in the joint revision

| Finding | Type | Decision |
| --- | --- | --- |
| A lacked typed scope-demand composition | Missing specification | Add closed positional transfer, demand monotonicity and nested demand composition (§3.2). |
| A required full equivalence; B omitted goal/fact direction | Missing specification | Direction depends on target role and polarity; one-way rules remain one-way (§3.1). |
| Whole-path TM transfer cannot cross stability | Missing specification | Transfer each closed TM step with arbitrary Plus arguments, add the native stability step, compose in Plus. |
| B placed soundness in the lower semantic layer | Actual layering defect | Keep pure clauses below the proof system; put soundness at layer 3 (§2, §6.2). |
| B used weak completeness as the wrong obstruction | Incorrect justification | Finite-context completeness is not excluded by weak completeness. The operational boundary is model truth versus derivation data and deliberate construction policy (§1). |
| Next/Previous need conditional rules and semantic covers | Missing specification | Use Base conditional congruence, preserve closed necessitation gates, add generic covering-time characterizations. |
| Initial scope conversions and capture were vague | Missing specification | Name the first proved routes; retain `using [...]`; fail on an unmet scoped demand (§3.3). |
| B's fact rewrite depended on the origin of a Lean local | Actual interface defect | Uniformly derive a new fact at the same Γ; context replacement is separate (§3.4). |
| Fresh-atom decrease did not justify all simp instances | Actual termination justification defect | Check the instantiated measure or require parametric evidence; count failed attempts and roll back on exhaustion (§4). |
| Frame-gated simp and explicit unfolding had no policy | Missing specification | Simp skips unavailable gates; explicit operations may expose them; concrete incompatible tags fail. |
| Transport omitted goal direction and repeated persistence | Missing specification | Separate fact/goal certificates; retain G/H guarantees with proved persistence across advances (§6.3–6.4). |
| Existing semantic shift, locality and morphism APIs were underused | Reuse gap | Reuse the audited APIs, preserving each theorem's exact fragment and indices. |
| B multiplied examples across milestones | Validation excess | One compact mechanism-driven suite across stages; no repeated whole-library builds (§8). |
| General native state-local promotion and boxed demand closure | Legitimate proof debt | Optional theorem work, not assumed capabilities or prerequisites for the first supported routes. |
| Semantic positional composition needed its own typed contract | Final Codex finding | Add point-predicate demands and a mixed world/time P4 prototype (§6.1). |

The review also preserved useful ideas from each proposal: B's demand algebra and conditional
Next route; A's source reuse, layer discipline, stable context and two-direction transport.
The corrected plan retains both without introducing a new universal logic framework.

## Joint-plan review and readiness

[Codex's independent joint-plan review](review/codex-review-of-joint-plan.md) gives
**87/100**: C=9, P=8.5, R=9, A=8.5, I=8. Its semantic-demand clarification was added during
closeout; the score was not retroactively raised.

[Opus's joint-plan review](review/opus-review-of-joint-plan.md) gives **82.5/100**:
C=8.5, P=8, R=8.5, A=8, I=8. Neither reviewer identified a soundness blocker. Opus required
several further specification changes; its score remains the pre-closeout grade.

| Final finding | Closeout change |
| --- | --- |
| `Step` was written only for TM | Parameterize the small adapter by language, native judgment family and implication; the same path compiler serves TM/Plus. |
| `ofTMSubst` cannot transfer a metalevel `demandMono` function | Transfer closed formula schemas; construct Plus demand monotonicity from its own necessitation and transferred K. Use G/H for Base X/Y monotonicity. |
| Composite certificate and equivalence projection were implicit | State `pathTransfer` and lift the appropriate closed conjunction projection through the composed demand. |
| Scope conversions were underspecified | Enumerate exact matches, single-letter boxed conversions and homogeneous iterations. Defer arbitrary mixed-word conversion search. |
| S2 could confuse strict G with present truth | Pin success to `[F A,G(A→F B),G(B→F C)]⊢F C`; require refusal for `[A,G(A→F B)]⊢F B`. |
| Transfer source and semantic import layers needed checks | Require all closed transfer rows in P0; distinguish generic clauses from concrete, individually classified Plus modules. |
| Transport table omitted direction | Record Iff for every audited existing route. The one-way test uses an explicitly supplied one-way theorem. |
| Completeness dependency guard had been omitted | Reuse existing `assert_not_exists` at native roots for named completeness declarations; add no CI framework and no impossible core-axiom guard. |
| Simplification measure/orientation/defaults were ambiguous | Use primitive constructor count after view preparation; registered orientation is fixed; skip non-decreasing rules, fail on no change, roll back exhaustion. |
| Explicit operation defaults differed without explanation | State the distinction once: step/unfold exposes frame premises; rewrite requires its explicit expose option. |

A final source spot-check confirmed that both `nextConsequence` and `prevConsequence` exist,
but their types are contextual functions rather than the closed formulas required by `Step`.
The table now cites `untilMonoEvent`/`sinceMonoEvent` at guard ⊥ instead. It also corrected
the fully qualified boxed-invariance name to `FormalSystem.PlusLanguage.box_global`:
the shorter `PlusTruth.box_global` in historical drafts/reviews is inaccurate.

The final closeout checks these changes without requesting a higher score. The independent
grades remain visible; agreement or a particular grade was never an acceptance criterion.

[Opus's closeout](review/opus-closeout.md) confirms all eight requested changes and the
semantic demand kernel, with no identified soundness or design blocker. Three final points
were incorporated: name the existing per-language conjunction projections rather than pretend
they follow from `Step.imp`; use a genuinely proved disjunction-introduction theorem as the
one-way fixture; identify repeated-state detection as defensive. No extra scoring round was
requested after these clarifications.

Readiness is staged: begin P0 theorem/API prototypes; later stages depend on their stated gates.
No new derivation, semantic theorem or performance result is established by this design review.

## Validation of this documentation change

- Rechecked the affected source names, closed-versus-contextual types, transport directions
  and PDF fingerprint. This is an API/source audit, not type-checking the proposed new lemmas.
- Checked local Markdown links and the focused README-lint gate.
- Checked whitespace with `git diff --check`.
- No Lean source changed and no Lean library build or new test run was needed.

Last verified: 2026-11-19 (design and documentation only).
