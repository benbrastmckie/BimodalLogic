# Teammate C Findings — Critic / Gaps & Blind Spots

**Task**: 90 — Decide between Option A (redefine bx_le) and Option B (Henkin closure)
**Date**: 2026-04-10
**Role**: Teammate C — Critic, Gaps and Blind Spots
**Artifact**: 01_teammate-c-findings.md

---

## Premise Verification

### Does BX11/temp_linearity exist right now?

**YES. Confirmed.** `Theories/Bimodal/ProofSystem/Axioms.lean:240-244`:

```lean
| temp_linearity (φ ψ : Formula) :
    Axiom (Formula.and (Formula.some_future φ) (Formula.some_future ψ) |>.imp
      (Formula.or (Formula.some_future (Formula.and φ ψ))
        (Formula.or (Formula.some_future (Formula.and φ (Formula.some_future ψ)))
          (Formula.some_future (Formula.and (Formula.some_future φ) ψ)))))
```

And its past dual `temp_linearity_past` is at Axioms.lean:249-253. Both are present
in the current HEAD. The docstring also reads: "NOT derivable from BX1-BX10 (see
LinearityDerivedFacts.lean counterexample)."

**Task 89's claim "re-adding temp_linearity" was the recommended action was made
against a state where temp_linearity was ABSENT.** Task 90's premise that the axiom
is already present is TRUE and confirms the state is different from what task 89 worked
against. Task 89's research was conducted against stale state where temp_linearity
was NOT in the axiom set.

### What is bx_le's current definition?

`Theories/Bimodal/Metalogic/BXCanonical/Frame.lean:61-62`:

```lean
def bx_le (w v : BXPoint) : Prop :=
  g_content w.formulas ⊆ v.formulas
```

This is the g_content-subset definition. It has NOT been changed. It is the same
definition that report 08 from task 86 concluded admits non-comparable MCS pairs.

### What changed between task 89 and task 90?

From git log (`git log --oneline -- Theories/Bimodal/ProofSystem/`):

- The Axioms.lean file was substantially modified in task 83 (commit `9f7eac088`,
  `3ea17f55e`, `9d6cf9a1d`, etc.) — this is when the BX axiom refactoring happened.
- The most recent substantial change to `Theories/Bimodal/` was **task 88**
  (commit `12d4e2bde`, 2026-04-09 10:29:38), which deleted `CanonicalEmbedding.lean`
  and relocated validity lemmas.

Task 91 (commit `68deabd2e`, 2026-04-10 12:01:33) rewrote `specs/ROAD_MAP.md` to
reflect the current architecture. **This is the critical change**: ROAD_MAP.md now
declares BXCanonical as the "active completeness path" and declares temp_linearity
(BX11) as present and part of the axiom system. The roadmap explicitly lists
Options A and B as the research framing for task 90.

**Summary of what changed**: Task 89 researched the system as it was BEFORE task 88
deleted CanonicalEmbedding.lean and before task 91 rewrote the roadmap. The roadmap
now assigns task 90+92 to close the 4 Frame.lean sorries. Whether this "supersedes"
task 89 depends on whether task 89's core mathematical claims are affected by the
deletion of CanonicalEmbedding.lean — they are NOT. The X-vs-G mismatch conclusion
from task 86 report 08 is unchanged.

**Critical finding**: Task 89 recommended re-adding temp_linearity. That axiom is
already present (has been since task 83). So task 89's Priority 1 recommendation was
based on a false premise — the axiom was already there. This means either:
(a) task 89 searched for temp_linearity and did not find it (false negative), or
(b) the task 89 research was conducted at a point before task 83 finalized the
    axiom set. Given commit timestamps, option (b) is plausible if task 89's research
    was done against an earlier checkout, but given the session date on the report
    (2026-04-10), option (a) seems more likely — the research failed to verify the
    axiom's presence.

**This is the most important finding in this report.** If temp_linearity is already
present, then task 89's entire "re-add temp_linearity" Priority 1 recommendation
collapses. The question becomes: given that BX11/temp_linearity IS in the axiom set,
why are the 4 Frame.lean sorries still open? The X-vs-G mismatch must persist even
with temp_linearity present, which is what task 86 report 08 Section 6 suggests
(temp_linearity was their Tier 3 / Approach C, NOT their primary recommendation).

---

## Unstated Assumptions

### Assumption 1: "BX contains everything Burgess/Xu needed"

The task description claims the BX axiom system contains BX4, BX5, BX6, BX7,
BX10, BX11, BX12, T — "everything Burgess 1982 / Xu 1988 needed." **This is
partially true but obscures a critical gap**: what Burgess/Xu needed is an axiom
set complete for the logic of linear temporal orders. The BX system has 37 axioms
targeting this goal. However, task 86 report 08 Section 7 specifically investigated
whether temp_linearity (BX11) is DERIVABLE from BX7 + other axioms, and concluded
it is "almost certainly impossible." This means BX7 does NOT subsume BX11.

More importantly: the task description's framing assumes completeness of the axiom
system implies the canonical model construction works. This is a significant
conceptual gap. Completeness means: if a formula is valid, it is provable. The
canonical model proof uses the axiom system to CONSTRUCT the model. Having the
right axioms and being able to execute the canonical model construction are
different things. The specific obstacle is that bx_le is defined via G-formula
content, not via Until-witness ordering, and the mismatch causes the guard
quantification to fail.

### Assumption 2: "The definitional mismatch is the only blocker"

The task description claims the 4 sorries are blocked solely by a "definitional
mismatch between bx_le := g_content-subset and the Until-witness ordering given
by BX7." This is a partial truth. The blockers documented in Frame.lean:590-622
include:

- (A) Until-induction axiom was removed — BUT task description says BX5+BX6+BX7
      provide it. This claim has NOT been verified. "Available" does not mean
      "derivable in this specific proof-theoretic form."
- (B) Global bx_le linearity is FALSE (proved in task 86 report 08). This
      remains true even with temp_linearity in the axiom set. The mismatch is
      structural: bx_le is about G-content, BX7/BX11 are about F/Until witnesses.
- (C) Chain-specific construction is blocked by X-vs-G mismatch.

The task description frames (B) as the "root cause" and claims Options A or B
solve it. But fixing the DEFINITION of bx_le (Option A) creates NEW blockers for
the G/H truth lemma proofs that currently work with g_content-based bx_le.

### Assumption 3: "Until-induction is derivable from BX5+BX6+BX7+BX10"

The Burgess-Xu Until-induction derivation is cited in the ROAD_MAP.md as the
"intended path forward." The BX5 self-accumulation + BX6 absorption is indeed
the classical proof-theoretic technique. However, this derivation has not been
formally verified in Lean 4. The claim in the ROAD_MAP says "the BX axiom set is
sufficient to derive the needed induction via BX5+BX6+BX7+BX10" — but this is
an ASSERTION, not a proof. Task 86's 12+ dead ends provide substantial evidence
that the derivation is harder than it looks. The task description treats this as
settled when it is actually the core open question.

### Assumption 4: "Closing 4 sorries gets us to bx_completeness"

Even if all 4 Frame.lean sorries are closed, `bx_completeness` (Completeness.lean:154)
remains sorry'd. The ROAD_MAP sorry inventory lists 6 total active-path sorries:
- Frame.lean:440 (Box modal-witness, separate from the 4)
- Frame.lean:653, 675, 690, 704 (the 4 Until/Since sorries)
- Completeness.lean:154 (TaskModel embedding)

Task 90 addresses at most 4 of the 6. bx_completeness requires all 6.

---

## Missing Options (C, D, E...)

### Option C: Abandon BXCanonical and Switch to Another Path

Task 89 concluded (98% confidence from 4 teammates) that BXCanonical is NOT on
the primary completeness path — the main path runs through
`FrameConditions/Completeness.lean` via dovetailed chains. The ROAD_MAP.md (task 91
rewrite, current HEAD) CONTRADICTS this, declaring BXCanonical as "the active
completeness path" and the legacy files as NOT on the active path.

**This is a critical contradiction between task 89 and task 91.** One of them is
wrong about the actual development strategy. Task 91 is MORE RECENT (committed
after task 89's research) and REWROTE the roadmap with explicit code verification.
The task 91 summary explicitly states that the "active completeness path flows
through Metalogic/BXCanonical/" and the legacy files are "not imported by
BXCanonical." This appears authoritative — but task 89's concern about Path C vs
Path B was based on a now-stale architecture (pre-task-91 roadmap).

**Option C is still viable as a meta-option**: abandon the BXCanonical approach
and reconstruct completeness differently. This has not been formally evaluated
with the current architecture.

### Option D: Weaken the 4 Lemma Statements

The current statements quantify over ALL BXPoints: `∀ u : BXPoint, bx_le w u →
bx_le u v ∧ ¬bx_le v u → φ ∈ u.formulas`. This is a strong statement.

An alternative: weaken the guard quantification to cover only the specific MCS
chain that will be used in the completeness proof. This was "Approach A" in task
86 report 08 Section 6 (chain-specific truth lemma), and is distinct from both
Options A and B. It does NOT require redefining bx_le, and does NOT require
Henkin enrichment. It requires changing the semantic interface of the truth lemma
for Until/Since.

**This option appears to have been deliberately abandoned** in the current
architecture. The current lemma statements are the strong universal ones. The
question is whether this was a deliberate design decision or an oversight.

### Option E: Derive F(φ) ↔ ⊤ U φ from the BX Axioms

Task 86 report 08 Section 7 explicitly identifies the gap: `F(φ) → ⊤ U φ` is
needed to bridge BX11 (F-witness linearity) to BX7 (Until-witness linearity), but
this direction appears underivable without additional infrastructure. BX12 gives
the direction `F(φ) → (⊤ U φ)`. Actually, BX12 IS this direction: `F_until_equiv`
is `(Formula.some_future φ).imp (Formula.untl (Formula.bot.imp Formula.bot) φ)` at
Axioms.lean:258-259. This is exactly `F(φ) → (⊤ U φ)`.

**Significant finding**: BX12 already provides the bridge that task 86 report 08
Section 7 called "underivable." This means the gap analysis in task 86 report 08
was incomplete or wrong on this specific point. With BX12 in the system, the
derivation `F(φ) → (⊤ U φ)` is trivially available (it's a primitive axiom).

This raises a NEW question: if BX12 bridges F to U, can BX7 + BX11 + BX12 together
yield bx_le interval linearity? This combination has apparently not been explored.

### Option F: External Proof of Interval Linearity via BX7+BX11+BX12

If BX12 gives `F(φ) → ⊤ U φ`, and BX11 gives F-witness linearity, and BX7 gives
Until-witness linearity, then there MAY be a path to proving that for BXPoints w
and v where `bx_le w v`, the interval [w, v) is linearly ordered. This is a weaker
claim than global bx_le linearity (which task 86 report 08 proved false), and it
may be exactly what is needed for the until-backward sorry.

This option has NOT been explored and represents a genuine gap in the prior research.

---

## Obstacle Resurfacing: X-vs-G Mismatch

### Does the X-vs-G mismatch apply to Option B (Henkin closure)?

In Option B, bx_le remains the g_content-subset definition. The enrichment adds
new canonical points to witness Until eventualities. **The X-vs-G mismatch
resurfaces in the guard propagation**: even with a Henkin-enriched MCS, showing
that at every intermediate point u ∈ [w, v), φ holds requires that φ U ψ propagates
forward through bx_le steps. The propagation requires `G(φ U ψ) ∈ w` for the
formula to be in the g_content, but there is no axiom that gives `φ U ψ → G(φ U ψ)`.

BX5 gives `(φ U ψ) → ((φ ∧ (φ U ψ)) U ψ)`, which shows the guard enriches itself.
But this is a formula transformation within the same point — it does NOT give
`G(φ U ψ) ∈ w` from `(φ U ψ) ∈ w`.

**The guard propagation problem is NOT solved by Henkin enrichment alone.** Option B
solves the EXISTENCE of a witness point but not the GUARD CONDITION. The task
description appears not to distinguish these two separate problems.

### Does the mismatch apply to Option A (redefine bx_le)?

Option A redefines bx_le via Until-witnesses. This potentially solves the guard
propagation problem BY DEFINITION — if bx_le is now defined in terms of Until
witnesses, then the guard condition becomes "φ holds at every Until-witness
between w and v," which is constrained by BX7. However:

1. The G truth lemma would need to be reproved. `bx_G_forward` currently uses
   `h_le : g_content(w) ⊆ v` to conclude `φ ∈ v` from `G(φ) ∈ w`. Under a
   new definition, this direct inclusion is lost.
2. `bx_le_refl` and `bx_le_trans` would need reproof with the new definition.
3. The existing sorry-free infrastructure (box preservation, modal witness, etc.)
   depends on the g_content characterization.

Task 86 task 88 commit message explicitly states "Until-witness chain bx_le does
NOT solve guard propagation — interval linearity not guaranteed, X-vs-G mismatch
persists under any single global ordering." This is evidence from an ATTEMPTED
implementation (not just analysis) that Option A fails.

---

## Equivalence Proof: Sketched or Hoped?

The ROAD_MAP.md says Option A requires "proving the two definitions equivalent
using BX10 + BX12 + BX4 + BX1." This is sketched at a high level but has not
been formally verified. The claim requires:

1. If `g_content(w) ⊆ v` (old definition), then `w ≤_U v` (Until-witness order)
2. If `w ≤_U v` (Until-witness order), then `g_content(w) ⊆ v`

For direction (1): BX10 says `(φ U ψ) ∈ w → F(ψ) ∈ w`, and BX12 says
`F(φ) ∈ w → (⊤ U φ) ∈ w`. Direction (1) requires that G-formula content forces
Until-witness ordering — this is NOT trivially implied. G-content inclusion says
"everything I necessitate you have," while Until-witness ordering says "every
Until eventuality I have, you are at or before its witness." These are different
properties.

For direction (2): Until-witness ordering says at every Until witness I can see,
you can also see. But G-content inclusion requires that every G-formula in me
holds in you. These are again different.

**Assessment**: The equivalence is HOPED, not sketched. No concrete proof path
exists for either direction. The claim "equivalent using BX10 + BX12 + BX4 + BX1"
appears to be a heuristic based on the semantics, not a verified proof-theoretic
relationship.

---

## Is There a Formal Countermodel?

### Countermodel for global bx_le linearity

Task 86 report 08 Section 2 gives a SEMANTIC argument for why global bx_le
linearity is false: "Consider two MCS w and v where G(p) ∈ w, p ∉ v (so NOT
bx_le w v) and G(q) ∈ v, q ∉ w (so NOT bx_le v w)." However, this is an
existence argument, not a formal countermodel. The report acknowledges it only
says "such MCS can exist" but doesn't CONSTRUCT them. Task 89's task 89 Teammate
C also noted "no formal countermodel has been constructed to prove impossibility
rigorously."

**Status**: No formal Lean 4 countermodel exists. The non-linearity of bx_le is
an informal mathematical claim (albeit a convincing one) without a verified
formal countermodel.

### Countermodel for Option A failure

Similarly, the task 88 Phase 2 NO-GO ("Until-witness chain bx_le does not solve
guard propagation") is based on an attempted IMPLEMENTATION that failed, but no
formal impossibility proof exists. It is possible that a different implementation
of Option A could succeed.

### What this means for confidence

The absence of formal countermodels means the 10% confidence estimate from task
89 could be wrong in EITHER direction. The obstacles are empirically strong but
theoretically non-rigorous. A determined implementer might find a path that task
86/88 missed.

---

## True Critical Path to bx_completeness

From the ROAD_MAP.md (task 91 rewrite, current HEAD), the active-path sorry
inventory lists exactly 6 sorries blocking bx_completeness:

| # | Location | Description |
|---|----------|-------------|
| 1 | Frame.lean:440 | Box modal-witness (S5 closure argument) |
| 2 | Frame.lean:653 | bx_until_eventuality_resolution (forward Until) |
| 3 | Frame.lean:675 | bx_until_backward (backward Until) |
| 4 | Frame.lean:690 | bx_since_eventuality_resolution (forward Since) |
| 5 | Frame.lean:704 | bx_since_backward (backward Since) |
| 6 | Completeness.lean:154 | TaskModel embedding (final step) |

Task 90 targets sorries 2-5. Sorry 1 is assigned to task 93. Sorry 6 is also
assigned to task 93. **Task 90 alone cannot deliver bx_completeness.**

Furthermore, sorry 6 (Completeness.lean:154) is blocked by an ENTIRELY DIFFERENT
problem: embedding BXPoints into a TaskModel requires constructing non-constant
histories. Completeness.lean:143-148 documents the constant-history anti-pattern
(rejected, see task 88). The TaskModel embedding requires:
- Choosing D (e.g., Int)
- Defining non-constant histories visiting multiple BXPoints
- Showing the G/H temporal truth bridges work on non-constant histories

This is a substantial independent problem that Options A and B do not address.

**Critical path in order**: close sorries 2-5 (task 90+92), close sorry 1 (task 93),
close sorry 6 (task 93) — only then does bx_completeness become sorry-free.

---

## Cost-of-Wrong Analysis

### If we pick Option A and it fails after 40 hours

Evidence that Option A has already failed: Task 88 Phase 2 explicitly committed a
NO-GO on "Until-witness chain bx_le" (commit `24005ad80`, message: "Phase 2 NO-GO:
Until-witness chain bx_le does not solve guard propagation — interval linearity
not guaranteed, X-vs-G mismatch persists under any single global ordering"). This
was an implementation attempt that failed.

If Option A is attempted again and fails:
- Fallback: Option B (Henkin enrichment) — this is explicitly the other option
- Risk: 40 hours lost with no sorry reduction
- Compounding risk: Option A changes the definition of bx_le, potentially
  invalidating 20+ existing sorry-free lemmas that depend on g_content-subset.
  If the definition change is reverted, all that work is lost.
- Worst case: Option A implementation partially succeeds (closes 2 of 4 sorries
  but breaks other lemmas) and creates a net-negative sorry count.

### If we pick Option B and it fails after 40 hours

Option B (Henkin enrichment) adds new machinery (enriched BXPoints with witness
witnesses) without changing the existing g_content-based definition. Failure modes:
- The enrichment successfully produces witness MCS but fails at guard propagation
  (the X-vs-G mismatch resurfaces as analyzed above)
- Fallback: The enrichment machinery can likely be reused in another approach
  (chain-specific guard, Approach A from task 86 report 08)
- Lower risk than Option A because it does NOT invalidate existing sorry-free work

**Option B has a lower cost-of-being-wrong** because it is additive (new lemmas
alongside existing infrastructure) rather than definitional (redefining bx_le).

### The 40-hour vs 8-16-hour discrepancy

Task 89 claimed re-adding temp_linearity would reduce the task from 40-80h to
8-16h. But temp_linearity is ALREADY IN THE AXIOM SET. So the 8-16h estimate
should apply to the CURRENT STATE. Either:
(a) task 89 was wrong and 8-16h was too optimistic even WITH temp_linearity, or
(b) task 89 was right and the current task (with temp_linearity present) should
    be tractable in 8-16h using standard canonical model techniques.

This is directly testable: if bx_le is provably linear (given temp_linearity is
in the axiom set), then standard canonical model techniques should close the 4
sorries. The fact that they remain open DESPITE temp_linearity being present
strongly suggests option (a) — the optimistic 8-16h estimate was incorrect, or
there is a different structural problem that temp_linearity alone does not solve.

---

## Questions That Should Be Asked

1. **Is bx_le actually linear given that temp_linearity (BX11) is in the axiom
   set?** This is now a concrete Lean 4 question: can we prove
   `theorem bx_le_linear : ∀ w v : BXPoint, bx_le w v ∨ bx_le v w`? If YES, the
   4 sorries become straightforward. If NO, explain precisely which step fails.

2. **What exactly blocked the Option A implementation in task 88 Phase 2?**
   The commit message says "interval linearity not guaranteed" — but with BX11
   in the axiom set, does this conclusion change? Task 88 ran before BX11 was
   fully integrated.

3. **What is the proof-theoretic derivation of Until-induction from BX5+BX6+BX7+BX10?**
   The ROAD_MAP asserts this is "sufficient" but no derivation is provided.
   A concrete Lean 4 attempt to derive the key step would resolve the question.

4. **Does BX12 (`F(φ) → (⊤ U φ)`) combined with BX7+BX11 yield interval linearity?**
   Task 86 report 08 identified `F(φ) → (⊤ U φ)` as a gap, but BX12 IS this
   axiom. This combination has not been explored.

5. **What does `bx_until_eventuality_resolution` look like if we assume bx_le is
   linear?** Can we sketch the proof in 20 lines? If so, the task reduces to
   first proving bx_le linearity (which should follow from BX11).

6. **Is there a Lean 4 proof that `g_content(w) ⊆ v → ∃ t, w ≤ t` (i.e., bx_le
   linearity on the interval)** using BX11 + BX12? If this specific lemma is
   provable, the backward sorry closes immediately.

7. **Why is sorry #6 (Completeness.lean:154, TaskModel embedding) not receiving
   attention?** Closing all 4 Frame.lean sorries still leaves this sorry open.
   Options A and B are irrelevant to sorry #6. Is there a plan for it?

8. **Are the task 89 teammates aware that temp_linearity is already present?**
   If task 89's core recommendation (Priority 1: re-add temp_linearity) was based
   on a false premise, the entire task 89 analysis needs re-evaluation. The 10%
   confidence estimate may be significantly wrong.

9. **Has anyone actually attempted to prove bx_le linearity using the current
   axiom set?** This seems like the most direct diagnostic: `lean_multi_attempt`
   with `exact bx_le_linear` after adding BX11 to the context. A failed proof
   attempt would give concrete error messages identifying the actual gap.

---

## Confidence Assessments

### High confidence findings

- **BX11/temp_linearity IS in the current axiom set** (Axioms.lean:240-244).
  Confidence: 100%. Directly verified.

- **bx_le is still defined as g_content-subset** (Frame.lean:61-62).
  Confidence: 100%. Directly verified.

- **Task 89's "re-add temp_linearity" recommendation was based on a false premise.**
  Confidence: 90%. The axiom is present; task 89's session date (2026-04-10) should
  have seen it, suggesting a verification failure, not a state difference.

- **Closing the 4 Frame.lean sorries does NOT give bx_completeness without also
  closing Frame.lean:440 and Completeness.lean:154.**
  Confidence: 100%. The sorry table in ROAD_MAP has 6 entries, not 4.

- **Option B has lower cost-of-being-wrong than Option A** because it is additive.
  Confidence: 85%.

- **BX12 provides F(φ) → (⊤ U φ)**, which is the exact bridge that task 86
  report 08 Section 7 claimed was "underivable." This represents a gap in the
  prior research.
  Confidence: 100% (BX12 is explicitly this implication in Axioms.lean:258-259).

### Medium confidence findings

- **The X-vs-G mismatch persists even with temp_linearity**, blocking guard
  propagation in both options.
  Confidence: 70%. The mismatch is structural (different formula classes), but
  BX12 may provide a bridge that hasn't been explored.

- **Option A has already failed in practice** (task 88 Phase 2 NO-GO).
  Confidence: 75%. The NO-GO was for a specific implementation; a different
  approach to Option A might succeed.

### Low confidence findings

- **Whether bx_le is provably linear given the current axiom set** (including BX11).
  Confidence: insufficient data. This is the KEY QUESTION that must be answered
  first. If linear: Options A and B are both tractable. If not linear: the mismatch
  analysis holds.

- **The true effort estimate for closing the 4 sorries.**
  Confidence: low. The 40-80h vs 8-16h range reflects genuine uncertainty about
  whether the BX11 + BX12 combination provides a clean path.

---

## Summary for Synthesis

The two most important findings from this critical analysis are:

1. **temp_linearity (BX11) is already in the axiom set.** Task 89's Priority 1
   recommendation (re-add it) was based on a false premise. This means the 4
   Frame.lean sorries have been open DESPITE BX11 being present. The question is
   why — and answering it (by attempting bx_le linearity from BX11) is the
   diagnostic next step.

2. **BX12 provides `F(φ) → (⊤ U φ)`**, which is the exact bridge that task 86
   report 08 called "almost certainly impossible to derive." This bridge exists
   as a primitive axiom. The BX7 + BX11 + BX12 combination for interval linearity
   has not been explored and may be the missing piece.

These two findings together suggest that the true obstacle may be narrower than
the "X-vs-G mismatch" framing implies. Before committing to either Option A or
Option B (both of which are expensive), the diagnostic question should be:

**Can `bx_le_linear` be proved using the current axiom set (including BX11 + BX12)?**

If yes, neither Option A nor Option B is needed — standard canonical model
techniques close the 4 sorries directly.

If no, identify exactly which step fails — this will distinguish whether Option A
(redefine the ordering) or Option B (enrich the points) addresses the root cause.

---

## References

- `Theories/Bimodal/ProofSystem/Axioms.lean:240-244` — BX11 temp_linearity
- `Theories/Bimodal/ProofSystem/Axioms.lean:258-259` — BX12 F_until_equiv
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean:61-62` — bx_le definition
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean:590-706` — 4 sorry sites + analysis
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean:154` — 6th sorry
- `specs/ROAD_MAP.md` — Active-path architecture (task 91 rewrite, verified)
- `specs/archive/086_close_bxcanonical_completeness_sorries/reports/08_bxle-linearity-research.md` — bx_le linearity analysis (task 86)
- `specs/089_close_frame_lean_eventuality_sorries/reports/01_team-research.md` — task 89 team findings (declared stale by task 90)
- `git log --oneline -- Theories/Bimodal/ProofSystem/` — axiom file history
