# Blocker Analysis: Task #379

**Parent Task**: #379 - rearchitect_kampprior_k2_onto_unary_esigma_encoding
**Generated**: 2026-07-17
**Blocker**: Phase 7 (Prop 4.3 structural induction) cannot close its negation case: the
endpoint-pinned Phase-6 negation engine (`prop42_veeSat_negation`, gated by
`EndpointPinnedCapTrivial`) cannot represent the arbitrary-pin, non-trivial-cap objects that
`pairProject` emits. The orchestration verdict estimated ~870–1230 lines of new construction
(Lemma 3.2(1) interleavings, Lemma 3.4 ∧-closure, an arbitrary-pin Prop 4.2 negation bridge)
before Phase 7 can proceed.

## Root Cause

Category: **design ambiguity / possible scope divergence**, not a pure "missing prerequisite."

Two prior artifacts already narrow this, and must not be re-derived:

1. `reports/05_conjunction-closure-load-bearing-verdict.md` adversarially confirmed that
   Lemma 3.2(1)/Lemma 3.4-conjunction are genuinely **load-bearing** — the "no conjunction case
   in Prop 4.3" argument for treating them as off-path is a non-sequitur, both because (a) the
   repo's `MonadicFormula` (`MonadicFO.lean:63-70`) has `and` primitive at every arity (mirror
   image of Rabinovich's `{¬,∨,∃}` basis) and (b) even in Rabinovich's own basis, the **negation
   case itself** (PDF p.6: "Since ∨∃∀ formulas are closed under conjunction (Lemma 3.4), we
   obtain that ¬φ is equivalent to a disjunction of ∃∀ formulas") consumes Lemma 3.4, which is
   proved from Lemma 3.2(1) (PDF p.5, "By (1) and (3) of Lemma 3.2").

2. `reports/06_phase4-unblock-construction.md` (this session's construction plan) adjudicated
   that the "canonicalize to `EndpointPinnedCapTrivial`" shortcut is **provably unsound** for
   non-trivial caps (folding real cap content to vacuous discards exactly what negation must
   invert), and prescribed the only sound route: a direct arbitrary-pin Prop 4.2 negation built
   on native Lemma 3.2(1)/3.4 machinery, at ~870–1230 lines total.

**However — the user's gating constraint applies here with real force.** Tasks 377/378 carry a
binding, repeated constraint: "It is ESSENTIAL to maintain full faithfulness with Rabinovich to
avoid attempting to prove novel mathematics." Task 377's own ruling
(`specs/377_transcribe_rabinovich_faithful_nf_encoding/reports/01_faithful-nf-encoding-ruling.md:271,433`)
diagnosed a structurally analogous prior gap (`nf_eval_nf -> VecEA2` needing "Feferman-Vaught
composition") as **self-inflicted by a type-first architecture Rabinovich never uses** — Rabinovich's
Prop 4.3 (PDF p.6) inducts over FORMULAS with processed depth folded into a unary E[Σ]-atom
(Def 4.1, PDF p.5), so composition is structural, never a theorem. Task 379 Phases 2–7 already
adopted this formula-first fix. The present blocker resurfaces a smaller-scale version of the same
worry one level down: is the ~870–1230-line construction genuinely Rabinovich's own mathematics
(Lemma 3.2(1) is his lemma, PDF p.4; Prop 4.2's general form is proved in his own Section 5, PDF
pp.7–11), or has the *architecture chosen inside task 379* (not the paper) manufactured an
avoidable obligation?

**Concrete grounds for suspecting avoidable scope, found this session and not yet resolved:**

- `Prop42ExistsForall.lean:23-28` states outright: *"We do **not** extend `VecEA2` to carry caps
  — that would be canonical-form machinery beyond Rabinovich."* `EndpointPinnedCapTrivial`
  (`:75-86`) exists specifically to bridge the Phase-3 `∃∀`-object into the **legacy** `VecEA2`
  bracket type — a repo-internal translation target, not a restriction Rabinovich's Prop 4.2
  itself imposes. Rabinovich's Def 3.1 object (PDF p.4) is stated for **arbitrary** free
  variables/pins from the start; "endpoint-pinned" is where THIS repo's translation-to-`VecEA2`
  choice narrowed it.
- Lemma 3.2(2)'s ≤2-free-variable cap (`ExistsForallLemmas.lean`, `augTarget_iff`, PROVED this
  program) reduces an r-ary object to a 2-ary one but does **not** currently guarantee the two
  target free variables land at the chain **endpoints** — it is this residual "arbitrary pin
  among 2 vars" gap, not an r-ary gap, that defeats `prop42_veeSat_negation`. It is not yet
  established whether `augTarget`'s reduction could instead be restated/re-targeted to always
  produce endpoint pins (which would let Phase 7 route through the *existing*, already-proved
  endpoint-pinned engine with **no** new interleaving machinery at all).
- Report 06's ~500–650-line Lemma 3.2(1) construction (enumerate all order-preserving merge
  patterns of two chains) is **this session's own proposed proof method**, invented without
  reading Rabinovich's actual proof text for Lemma 3.2(1)/Prop 4.2 (pp.4–5, 7–11) in detail. A
  faithful transcription of Rabinovich's own argument could be smaller, differently shaped, or
  could reveal that Prop 4.2's general-pin case is already what he proves directly (Section 5,
  pp.7–11) without ever routing through a standalone Lemma 3.2(1) combinatorial merge.

**Conclusion**: the blocker cannot be safely decomposed straight into "build the ~870–1230-line
construction" without first checking whether that scope is (a) genuinely Rabinovich's own
mathematics, faithfully transcribed, or (b) an artifact of this repo's `EndpointPinnedCapTrivial`/
`VecEA2`-translation choice that a smaller reconciliation (e.g., re-targeting `augTarget` to
produce endpoint pins, or transcribing Rabinovich's actual pp.7-11 Prop 4.2 proof directly) would
eliminate or shrink. This is precisely a **design-ambiguity** blocker, and the first spawned task
must resolve it before any heavy construction is authorized.

## Proposed New Tasks

### New Task 1: Adjudicate Rabinovich faithfulness of the Phase 7 negation-case unblock scope
- **Effort**: 3-4 hours
- **Task Type**: lean4
- **Rationale**: A short, read-and-adjudicate probe (no `Theories/` edits) that determines whether
  the ~870–1230-line construction proposed in `reports/06_phase4-unblock-construction.md` is
  genuinely required faithful transcription, or whether the repo's own `EndpointPinnedCapTrivial`
  restriction (a translation-to-legacy-`VecEA2` artifact, per `Prop42ExistsForall.lean:23-28`) has
  manufactured an avoidable obligation. This directly instantiates the binding no-novel-mathematics
  constraint from the task-377/378 lineage and must run before any heavy construction is
  authorized.
- **Depends on**: None.

**Description (verbatim for implementer)**: Re-derive, from Rabinovich's own text (cite by PDF
page only; the companion `.md` transcription is corrupt), the actual proof methods of: Lemma
3.2(1) (conjunction of `∃∀`-formulas ⟺ disjunction of `∃∀`-formulas, PDF p.4), Lemma 3.4's
conjunction-closure step (PDF p.5, "By (1) and (3) of Lemma 3.2"), and Prop 4.2's general
(non-endpoint-restricted) negation-closure proof (Section 5, PDF pp.7–11 — NOT just the p.6
statement). Cross-check each against:
1. `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop42ExistsForall.lean:1-90` (docstring +
   `EndpointPinnedCapTrivial`) — confirm/refute that this restriction is a repo-internal
   `VecEA2`-translation artifact rather than a feature of Rabinovich's own Prop 4.2 statement.
2. `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ExistsForallLemmas.lean` (`augTarget`,
   `augTarget_iff`, `augTarget_forward`, `augTarget_backward`, the Lemma 3.2(2) ≤2-free-var
   reduction) — determine whether `augTarget`'s reduction target could instead be re-stated to
   always land the 2 free variables at chain endpoints (eliminating the arbitrary-pin case for
   Phase 7's negation obligation entirely), and if so, estimate the size of that re-statement
   versus the report-06 construction.
3. `reports/06_phase4-unblock-construction.md` §§1-3 (the proposed order-preserving-interleaving
   construction) — determine whether it matches Rabinovich's actual proof shape for Lemma 3.2(1)
   and Prop 4.2's general case, or is a heavier reinvention.

Produce an explicit **GO / RECONCILE** verdict as the deliverable (a probe report under this
task's own `specs/{NNN}_{SLUG}/reports/`, plus an optional small `.lean` scratch file under the
same directory if needed to check a specific claim — no `Theories/` edits):
- **GO**: the report-06 construction (or a corrected version of it) is confirmed as faithful
  transcription of Rabinovich's own Lemma 3.2(1)/3.4/Prop 4.2 arguments, genuinely required at
  roughly the scoped size, and is the minimal route. Record the corrected Lean signatures/line
  estimates if they differ from report 06.
- **RECONCILE**: the arbitrary-pin obligation is avoidable — e.g., `augTarget` can be re-targeted
  to always yield endpoint pins, or Rabinovich's actual Prop 4.2 proof is materially smaller/
  differently shaped than report 06's proposal. Record the concrete smaller construction plan
  (with its own Lean signatures and line estimate) to be used instead.

Cite Rabinovich by PDF page only throughout. Do not edit `Theories/`. `lake build` must remain
unaffected by this task (read-only against the live spine; any scratch `.lean` file lives under
`specs/`, never imported).

### New Task 2: Construct the Phase 7 negation-case unblock per Task 1's verdict
- **Effort**: 14-20 hours (3-4 sub-dispatches; sub-decompose via `/plan` into per-lemma phases,
  mirroring Phase 7's own "crux" sizing precedent)
- **Task Type**: lean4
- **Rationale**: Delivers whichever construction Task 1's adjudication authorizes — either the
  report-06 GO-path construction (Lemma 3.2(1) interleavings, Lemma 3.4 ∧-closure, arbitrary-pin
  Prop 4.2 negation bridge) or the smaller RECONCILE-path construction Task 1 identifies — so
  that Phase 7's negation case has a sound engine to close against.
- **Depends on**: New Task 1, because Task 2's entire construction target (which lemmas to build,
  at what signatures, and at what size) is determined by Task 1's GO/RECONCILE verdict — this is
  not merely "Task 1 must finish first," it is that the concrete Lean signatures, proof method, and
  scope Task 2 implements are the direct output of Task 1's adjudication.

**Description (verbatim for implementer)**: FIRST, read the probe report produced by the
adjudication task (the task this depends on) in full. Its verdict determines which of the two
branches below applies — do not skip this precondition check.

- **If the verdict is GO**: build, in this dependency order (mirrors
  `reports/06_phase4-unblock-construction.md` §§1-4, sub-decomposed into separate green, committed
  sub-steps per the project's crux-phase-sizing precedent):
  1. Native Lemma 3.2(1) on `ExistsForallFormula` — `conjInterleave` + `conjInterleave_iff`
     (conjunction of two `efSat` ⟺ disjunction via order-preserving chain interleavings, ~500–650
     lines per report 06 unless Task 1 corrected this estimate).
  2. Native Lemma 3.4 ∧-closure — `veeConj` + `veeConj_iff` (distribute ∧ over the two disjunct
     lists, apply step 1 pointwise, ~120–180 lines).
  3. Arbitrary-pin Prop 4.2 negation bridge — `efSat_negation_general` then
     `prop42_veeSat_negation_general` (De Morgan over the disjunct list, single-object negation by
     case analysis over order patterns, reassemble via step 2, ~250–400 lines).
  4. Re-attempt Phase 7's negation case using the new engine.
- **If the verdict is RECONCILE**: build the smaller, concrete construction plan Task 1's report
  specifies instead (e.g., a re-targeted `augTarget` that always yields endpoint pins, or a direct
  transcription of Rabinovich's actual Prop 4.2 general-case proof from PDF pp.7–11) — follow that
  report's own signatures/line estimates rather than report 06's.
- **If Task 1's report indicates neither branch cleanly resolves** (e.g., a genuine tie or new
  ambiguity surfaced during adjudication): do not force either construction; escalate this task to
  `[BLOCKED]` citing the specific unresolved question, per the standard error-handling protocol.

Every deliverable lives in new file(s) under
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` (name provisional, e.g. `ConjInterleave.lean`,
`Prop42NegationGeneral.lean`), off the live import path until Phase 7 rewires onto it — mirroring
how `Prop43.lean`/`Prop42ExistsForall.lean` already sit off-path. `lake build` must stay EXIT 0 at
the existing job count throughout; no new axiom/sorry may appear on `completeness_discrete`'s
axiom trace. No `sorry`, no vacuous placeholder, no `Prop43Structural.lean` hole. Cite Rabinovich
by PDF page only. Durable-anchor headers only (no task-number references in `Theories/` files).
Once this task lands, resume parent task #379 at Phase 7 (`/implement 379`).

## Dependency Reasoning

- **Task 2 depends on Task 1**: Task 1's adjudication does not just gate a go/no-go switch — its
  output report supplies the actual Lean signatures, proof method, and scope that Task 2
  transcribes. Task 2 literally cannot be scoped or planned correctly without Task 1's concrete
  findings (corrected line estimates, corrected signatures, or an entirely different smaller
  construction if RECONCILE). This is an implementation-detail dependency, not a mere ordering
  constraint.
- **File-footprint overlap check**: Task 1's `file_scope` is empty (probe/read-only; any scratch
  `.lean` lives under its own `specs/` reports directory, not `Theories/`). Task 2's `file_scope`
  targets new files under `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/`. No overlap exists
  between the two `file_scope` arrays, so no auto-added dependency edge was needed beyond the
  explicit one already declared above.

## After Completion

Once both spawned tasks are complete, resume the parent task #379 with `/implement 379`.

The blocker will be resolved because: Phase 7's negation case will have a sound negation engine
that covers the arbitrary-pin objects `pairProject` produces — either the report-06 construction
(if Task 1 confirms GO) or a smaller, equally sound reconciliation (if Task 1 finds the obligation
was an artifact of the repo's `EndpointPinnedCapTrivial`/`VecEA2`-translation choice rather than of
Rabinovich's own mathematics). Either way, Phase 7 no longer needs to force a `sorry` or invent
novel mathematics beyond what Task 1 has adjudicated as faithful.
