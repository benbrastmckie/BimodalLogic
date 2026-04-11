# Round 3 Critic Findings: Task 98 Critical Interrogation

- **Task**: 98 — Research filtration or quasimodel pivot for Until/Since truth lemma
- **Round**: 3 (CRITIC role)
- **Teammate**: C
- **Date**: 2026-04-11
- **Artifact**: 03_teammate-c-findings.md

---

## Preamble: What I Actually Read

Before accepting any prior team summary, I read the following sources directly:

1. `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` (full)
2. `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean` (full)
3. `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/HintikkaPoint.lean` (full)
4. `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/SubformulaClosure.lean` (full)
5. `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/LocusControl.lean` (full)
6. `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` (lines 1–440 and 580–707)
7. `specs/098_.../plans/02_quasimodel-pivot-plan.md` (full)
8. `specs/098_.../summaries/02_implementation-complete.md` (full)
9. `specs/098_.../reports/02_team-research.md` (full)
10. `specs/098_.../reports/02_teammate-c-findings.md` (full, the prior Critic report)

---

## Unvalidated Assumptions

### A1: "Combined seed consistency" is formulated correctly

The plan v2 summary states the blocking problem as:

> The enriched seed `h_{i+1}.formulas ∪ g_content(v_i.formulas)` must be provably
> consistent in order to extract `v_{i+1}` via Lindenbaum.

**What I found**: Reading `Construction.lean:44-51` directly, `hintikka_step` has exactly three
clauses: G-propagation, H-backward, and Until-defect propagation. There is NO clause in
`hintikka_step` that directly implies `g_content(v_i) ⊆ h_{i+1}.formulas` for the infinite
`g_content` of a BXPoint. The assumption embedded in sub-phase 4b is that:

> `hintikka_step h_i h_{i+1}` guarantees G(χ) ∈ h_i → χ ∈ h_{i+1}

which is correct (first clause). But `g_content(v_i)` contains G-formulas from the FULL BXPoint
`v_i`, not just those projected into Sigma. The seed `h_{i+1}.formulas ∪ g_content(v_i.formulas)`
unions a FINITE Hintikka set with a potentially INFINITE g_content. The consistency proof
would need to show this combined infinite/finite set is consistent.

**Validation status**: The summary says `enriched_seed_consistent_until` (Realization.lean:140)
is "sorry-free." I verified this — it IS sorry-free. But that lemma proves consistency for the
seed `{¬(φ U ψ)} ∪ g_content(w) ∪ h_content(v)` which is a DIFFERENT pattern from
`h_{i+1}.formulas ∪ g_content(v_i)`. The two seeds have different structures. This distinction
was not clearly drawn in the round 2 summary, which claimed:

> "The enriched seed lemmas are sorry-free but the full realization chain construction
> is not yet assembled."

**This conflates two distinct consistency claims.** The sorry-free single-step seeds are NOT
directly reusable for the chain-step construction. The round 2 report's claim that "reusing
the same seed pattern" suffices is UNVALIDATED.

### A2: "hintikka_step has Until persistence built into its definition"

The round 2 synthesis (confirmed 4x by all teammates) states:

> The `hintikka_step` relation has Until persistence built into its definition, making the
> guard proof trivial at the Hintikka level.

**What I found**: Reading `Construction.lean:50-51`:

```
(∀ φ ψ : Formula, Formula.untl φ ψ ∈ h1.formulas → ψ ∉ h1.formulas →
  φ ∈ h1.formulas ∧ Formula.untl φ ψ ∈ h2.formulas)
```

This says: if `(φ U ψ) ∈ h1` and `ψ ∉ h1`, then `φ ∈ h1` AND `(φ U ψ) ∈ h2`.

**The guard claim `φ ∈ h_i` is trivially true** — `φ ∈ h_i` is read directly from the third
clause of `hintikka_step`. The team is correct about this.

**BUT**: the `hintikka_step` definition has a gap that no report examined. The definition
requires `hintikka_step h1 h2` to hold as a PRECONDITION. The chain construction in Phase 4a
must PRODUCE a chain where consecutive steps satisfy `hintikka_step`. No proof of existence
of such a chain appears in `Construction.lean` — the "quasimodel_chain_exists" theorem listed
in the docstring is described only in comments (lines 86-109), not proved. The claim
"quasimodel chain existence follows from BX axioms applied at the MCS level" at line 90 is
stated but not proved. This is a hole in the scaffolding that the round 2 team did not flag.

**Validation status**: The claim that `hintikka_step` exists is true. The claim that chains
satisfying `hintikka_step` can be CONSTRUCTED is UNVALIDATED. `Construction.lean` contains
only MCS-level lemmas (BX9, BX5, BX10, BX4 etc.), not the actual chain construction theorem.

### A3: "sigma_signature round-trip proves guard transfer"

The plan v2, sub-phase 4c states:

> `guard_transfer`: for each intermediate BXPoint v_i, `phi in h_i.formulas` implies
> `phi in v_i.formulas` via `sigma_signature_mem` (since phi is in Sigma by subformula closure)

**What I found**: Reading `HintikkaPoint.lean:154-157`:

```lean
theorem sigma_signature_mem {w : BXPoint} {Sigma : Finset Formula}
    {h_neg : ∀ f ∈ Sigma, Formula.neg f ∈ Sigma} {f : Formula} :
    f ∈ (sigma_signature w Sigma h_neg).formulas ↔ f ∈ Sigma ∧ f ∈ w.formulas
```

This says: `f ∈ sigma_signature(w, Sigma)` iff `f ∈ Sigma AND f ∈ w.formulas`.

For guard transfer, we need: given `phi ∈ h_i.formulas` and `h_i = sigma_signature(v_i, Sigma)`,
conclude `phi ∈ v_i.formulas`. The round-trip claim is:

> `phi ∈ h_i.formulas` ↔ (`phi ∈ Sigma` AND `phi ∈ v_i.formulas`)

So `phi ∈ h_i.formulas` IMPLIES `phi ∈ v_i.formulas`. **This direction is sound** — it follows
directly from `sigma_signature_mem`.

However, the reverse direction (needed for Phase 5's `realize_chain_step_sigma`) requires
`h_i = sigma_signature(v_i, Sigma)`, which is NOT freely given — it must be proved as part of
the realization construction. Specifically, constructing `v_{i+1}` from `h_{i+1}` must guarantee
`sigma_signature(v_{i+1}, Sigma) = h_{i+1}`, which requires showing the Lindenbaum extension
doesn't add any Sigma-formulas that weren't in `h_{i+1}`. This uses local maximality of `h_{i+1}`
within Sigma, which IS proved in HintikkaPoint.lean. So this assumption is likely sound.

**Validation status**: Likely sound, but the construction (`realize_chain_step_sigma`) has not
been attempted yet. The gate check was hit before reaching this step.

### A4: "Cascade cost too high" for bx_le redefinition

The round 2 summary (Teammate D, confirmed by synthesis) states:

> Redefining `bx_le` via Until-witness ordering — cascade cost too high
> (breaks every sorry-free proof in Frame.lean:140-583).

**What I found**: Reading `Frame.lean:140-583`, I counted the sorry-free theorems:

- `bx_le_refl` (line 140)
- `bx_le_trans` (line 153)
- `bx_forward_witness` (line 164)
- `bx_backward_witness` (line 176)
- `bx_G_forward` (line 192)
- `bx_G_backward` (line 208)
- `bx_H_forward` (line 266)
- `bx_H_backward` (line 277)
- `bx_modal_equiv_refl/symm/trans` (line 332-342)
- `bx_modal_witness` (line 358) — contains one sorry (modal_witness, scope of task 93)
- `box_preserved_along_bx_le` (around line 490)
- `bx_modal_equiv_of_bx_le` (around line 538)

Of these, WHICH ones actually use `bx_le` in their PROOF body (not just statement)?

- `bx_le_refl`: uses the definition `g_content ⊆` directly. If `bx_le` is redefined, this proof needs complete rewriting.
- `bx_le_trans`: same.
- `bx_G_forward` (line 192-195): literally `h_le h_G` — one line using `bx_le := g_content ⊆`. If `bx_le` is redefined, this needs rework.
- `bx_H_forward` (line 266-270): calls `g_content_subset_implies_h_content_reverse` with `h_le`. Depends on `bx_le` definition.
- `bx_forward_witness` (line 164-171): builds `v` with `g_content(w) ⊆ v` explicitly. This is the SEED for `bx_le`. If definition changes, this needs rewriting.
- `bx_backward_witness` (line 176-185): same.
- `bx_G_backward`, `bx_H_backward`: same pattern.

**The round 2 claim of "10+ theorems" is roughly accurate but has not been counted precisely.**
The actual number is approximately 8-10 theorems that would require proof rewriting (not just
statement rewriting). The "cascade cost" claim is validated but the claim "10+" may be an
overestimate — it is closer to 8. This does not substantially change the conclusion, but the
vagueness was noted as a question.

### A5: "Until-induction axiom was removed in refactoring"

The round 2 summary and Realization.lean docstring both state:

> The Until-induction axiom `(ψ ∨ (φ ∧ X(θ)) → θ) → (φ U ψ → θ)` was removed from BX
> during refactoring (BX5-BX7 were added instead).

**What I found**: Reading `Axioms.lean:1-100`, the axioms listed are BX1-BX12. There is no
Until-induction axiom. The claim it "was removed" is consistent with the current Axioms.lean.
However, I cannot validate the claim without access to the refactoring history (git log).

More importantly: the Realization.lean docstring lists this as one of four things that would
close the sorries. If the axiom WERE added back (as a BX13), would it actually close them?
Reading the sorry at line 282: we need `φ ∈ u` given `φ ∈ u'` and `bx_le u' u`. Until-induction
`(ψ ∨ (φ ∧ X(θ)) → θ) → (φ U ψ → θ)` is a schema over arbitrary θ. Instantiating θ := φ at
the specific point u would require a successor/next-step relation X, which BX does not have
(it is for dense orders). So the induction axiom in its standard form with X does not apply here.

**The "removed axiom" alternative is correctly ruled out but the reason stated in the Realization.lean
docstring is subtly wrong** — it says "removed in refactoring" but the correct reason is
"inapplicable on dense orders (no X operator)."

### A6: "bx_le totality is definitely false"

All four round 2 teammates claim bx_le totality is DEFINITELY false, providing a countermodel
argument (two atoms p, q with G(p) ∈ w, p ∉ v AND G(q) ∈ v, q ∉ w).

**What I found**: This countermodel argument is valid at the semantic level. Two MCS
descriptions can be given that cannot be jointly extended to a linear model where g_content
inclusion is total. The claim is mathematically sound.

**BUT the phrase "REALLY unfixable" in the task prompt deserves scrutiny**: The question is
not whether bx_le is currently total (it isn't) but whether a DIFFERENT definition of bx_le
could make totality available. The round 2 research considers one specific redefinition
(until-witness ordering) and finds it has a transitivity gap. It does not consider WHETHER
there exists ANY definition of bx_le that: (a) supports all existing G/H/Box theorems and
(b) is total. This is a stronger question that was not investigated.

**Validation status**: The specific bx_le definition is provably non-total. The round 2
research's dismissal of redefinition as "cascade too high" was about cost, not impossibility.
There is an unexamined possibility: a bx_le definition that is TOTAL BY CONSTRUCTION (using
an explicit canonical linear extension of the partial order) would support all existing proofs
if bx_G_forward, bx_H_forward etc. can be rephrased in terms of the new definition. This
was not investigated.

---

## Unasked Questions

### Q1: Is the "combined seed consistency" problem actually the gate check problem?

The implementation summary says the gate was hit at "chain-level combined seed consistency."
But reading `Realization.lean`, the implementation was NOT ATTEMPTED beyond the existing code.
The sorries are from the previous partial implementation. The gate check was actually a
PROSPECTIVE assessment ("if we tried sub-phase 4b, we predict it would fail") rather than an
EMPIRICAL failure of a Lean proof attempt.

**Why this matters**: A prospective assessment of difficulty is not the same as an actual
failed proof attempt. It is possible that the chain-level seed consistency proof is easier than
predicted, because the plan v2 never ran far enough to test it.

### Q2: Does `hintikka_step` as defined in Construction.lean actually support the chain existence proof?

`Construction.lean` contains:
- MCS-level lemmas (until_elim_mcs, self_accum_mcs, etc.)
- The `hintikka_step` DEFINITION
- Comments describing what "quasimodel_chain_exists" should prove

But there is NO proved theorem `quasimodel_chain_exists`. The comments at lines 86-109 describe
the intended theorem using comments like "rather than constructing this explicitly" and
"the key mathematical content is in Realization.lean." This means the Hintikka chain existence
at the abstract level is NOT PROVED — it exists only as a design intent.

The plan v2 says sub-phase 4a proves `hintikka_chain_exists` using well-founded recursion on
`defect_count`. This is a NEW proof required, not an existing one. The round 2 summary's
statement that "the quasimodel scaffolding is substantially correct" obscures the fact that
the scaffolding exists at the DEFINITION level but not at the THEOREM level.

### Q3: Is the guard condition statement in the target theorems (Frame.lean:637) correct for a non-total order?

The four Frame.lean sorry targets have this guard condition:

```lean
∀ u : BXPoint, bx_le w u → bx_le u v ∧ ¬bx_le v u → φ ∈ u.formulas
```

This says: for ANY u in the interval [w, v) (under the non-total `bx_le`), `φ ∈ u`. The
"interval" here is `{u | bx_le w u ∧ bx_le u v ∧ ¬bx_le v u}`, which is a perfectly sensible
definition even for a non-total order.

**But the quasimodel approach produces a SPECIFIC finite chain** `v_0, ..., v_k`, not a proof
about ALL elements of [w, v) under the full `bx_le`. The plan v2 says at sub-phase 5a step 7:

> "Locus-control for arbitrary strict-interval points u: use sigma_signature projection of u
> into the Hintikka chain to transfer the guard"

This is the locus-control lemma — the hardest part of the construction, already identified as
load-bearing in round 1 research. The round 2 team treated this as a solved problem ("using
sigma_signature projection of u"), but the projection does not automatically restrict u to
one of the chain points. It only says u's Sigma-signature is a HintikkaPoint in Sigma — it
does NOT say that HintikkaPoint appears as some h_i in the specific constructed chain.

**This locus-control gap is unresolved and was not investigated in the implementation attempt.**

### Q4: Is there any shorter path that avoids building the full chain?

One alternative not fully explored: if the target theorem's guard condition could be WEAKENED
or RESTATED equivalently in a form that the quasimodel approach directly produces, the locus-
control step might be avoided. For example:

The current statement requires `φ ∈ u` for ALL u in [w, v). The quasimodel only proves `φ ∈ v_i`
for the constructed chain. If TruthLemma.lean's `until_iff_mcs` only requires the EXISTENCE of
v and the guard on a FINITE set of intermediate points (not all intermediate BXPoints), then
the guard condition in Frame.lean could be weakened without breaking completeness.

This was not investigated. Reading `TruthLemma.lean` (not in scope of this file read) would
be needed to determine whether the guard semantics match.

### Q5: What is the actual mathematical content of "locus control"?

Round 1 research (report 01) identifies locus control as the key load-bearing claim:

> "`u`'s Σ-signature is determined up to quasimodel-index by `bx_le w u ∧ bx_le u v_k`"

This is true "if and only if Σ-signatures are totally ordered by the Burgess-Xu one-step
relation." The report says this is "exactly the quasimodel's defining property."

**But Hintikka sets in the quasimodel are finitely many and form a DIRECTED graph, not
necessarily a total order.** The quasimodel defines a ONE-STEP relation `hintikka_step`
which is not symmetric. An arbitrary BXPoint u with `bx_le w u` and `bx_le u v_k` has a
Sigma-signature that is a HintikkaPoint in Sigma, but that HintikkaPoint may not be one
of the specific `h_i` in the constructed chain from `h_0` to `h_k`. Locus control requires
showing that the Sigma-signature of u is in fact some `h_i` — i.e., that the quasimodel
chain is exhaustive for all intermediate Sigma-signatures.

This is a non-trivial claim that was listed as "load-bearing" in round 1 research but was
NEVER PROVED or even given a proof sketch in the round 2 team research or the plan v2.

### Q6: Could task 98 be closed as PARTIAL now, with a clean handoff?

Task 98 was originally created as a RESEARCH task ("research filtration or quasimodel pivot").
Looking at the sorry inventory:
- 6 sorries in Realization.lean (from prior Phase 4 partial)
- 4 sorries in Frame.lean
- 1 sorry in Completeness.lean (task 93 scope)

The task 98 deliverable is a research report recommending an approach. Phases 1-3 and 6 of
the implementation were ALREADY done before this task's plan was created (they were done in
prior implementation sessions for task 92 and related tasks). The research artifact (reports
01 and 02) is complete.

**The question is whether task 98 should be continuing to attempt implementation.** The task
description says "research report recommending approach" but the plan.v2 is an IMPLEMENTATION
plan. There is scope creep: task 98 started as research, grew into implementation planning,
and then tried to execute the implementation. The "gate check" was hit during an attempted
implementation that arguably belongs in a separate task.

---

## Methodology Critique

### MC1: Round 2 converged too quickly on the quasimodel recommendation

All four round 2 teammates converged on the same conclusion with high confidence (85-95%).
Looking at the teammate assignments:
- Teammate A: Primary (BX11 analysis) — found BX11 doesn't help
- Teammate B: Alternatives — found all 5 alternatives fail
- Teammate C (round 2): Critic — confirmed quasimodel is standard technique
- Teammate D: Horizons — strategic confirmation

**The methodology issue**: A proper critical review would have had at least one teammate argue
FOR each alternative rather than against all of them. Assigning Teammate D to "Horizons"
(strategic confirmation) when what was needed was a Devil's Advocate who seriously investigated
whether bx_le redefinition COULD work was a methodological gap. Teammate B's 65% confidence
assessment of `until_compatible` redefinition was dropped in the synthesis, replaced by
Teammate D's 90% dismissal. The higher-confidence pessimist won, but pessimists being highly
confident does not mean they are correct.

### MC2: The "sorry-free" claim about enriched_seed_consistent is misleading

All reports repeatedly state "the enriched seed lemmas are sorry-free" as evidence that the
core consistency proof technology exists. But reading Realization.lean carefully:

- `enriched_seed_consistent_until` (line 140) proves: `{¬(φ U ψ)} ∪ g_content(w) ∪ h_content(v)` is consistent
- `enriched_seed_consistent_since` (line 193) proves: the dual

These are sorry-free, but they are proofs for SPECIFIC SEEDS used in the `until_backward`
and `since_backward` functions (lines 300-404). They are NOT used in `until_eventuality_resolution`
or `since_eventuality_resolution`. The chain step seed `h_{i+1}.formulas ∪ g_content(v_i)`
is a THIRD distinct seed pattern that appears NOWHERE in the existing sorry-free code.

**The round 2 team consistently treated the existence of sorry-free single-step seeds as
evidence that the chain-step seed would also be provable. This is a logical gap.** The
single-step seeds are simpler because they have a single `¬(φ U ψ)` anchor that provides
the consistency argument. The chain-step seed has no such anchor.

### MC3: "Combined seed consistency" was declared "the sole remaining hard sub-problem" without proof

The round 2 synthesis states:

> The sole remaining hard sub-problem is combined seed consistency for the realization
> lifting lemma.

**This claim is made without providing a proof strategy or even a sketch.** It is not "the
sole remaining hard problem" — it is one of several open problems. The locus-control lemma
(Q3, Q5 above) is equally hard and equally unresolved. Calling it "sole" created false
confidence that once combined seed consistency is resolved, the rest would follow. This
contributed to the plan v2 being optimistic about the timeline.

### MC4: The "cascade-cost" comparison was done asymmetrically

Round 1 report §2 (cascade cost audit) counted the cost of the bx_le redefinition approach
as "breaking 10+ theorems." Round 2 confirmed this. But the audit compared:

- bx_le redefinition: ~8-10 theorems need rework, medium confidence on transitivity gap
- Quasimodel approach: listed as "zero cascade cost"

The quasimodel approach's IMPLEMENTATION cost (locus control, chain existence, chain
realization) was not systematically included in the comparison. Round 1 §4 estimated 25-45h
total; round 2 plan estimated 20-35h. But neither estimate accounts for the locus-control
lemma's proof difficulty, which is the hardest part and was identified as "load-bearing" but
given no effort estimate.

**The comparison is structurally biased toward the quasimodel approach because it counted
the cascade costs of alternatives but not the construction costs of the quasimodel.**

### MC5: No implementation was actually attempted for Phase 4

The implementation summary says "implementation halted at Phase 4 gate check." But reading the
code:
- Realization.lean has 6 sorries, all from the PREVIOUS implementation session (commit 661f20557)
- The v2 plan session added ZERO code to Realization.lean
- The gate check was "hit" before any Phase 4 code was written

This means the gate check is a PREDICTION, not an EMPIRICAL RESULT. The plan v2 said "if
realize_chain_step's consistency proof fails, HALT." The implementation session decided to
pre-halt rather than attempt the proof and fail. This is appropriate caution but should be
clearly distinguished from "the proof was attempted and failed."

---

## Recommendation

### Should task 98 be closed as PARTIAL, re-researched, or abandoned?

**Recommendation: PARTIAL CLOSURE with clean handoff task.**

#### Rationale

Task 98 has produced substantial value:
- Round 1 and round 2 research reports are high quality
- Phases 1-3 and 6 of implementation were completed (sorry-free SubformulaClosure,
  HintikkaPoint, Construction, and module wiring)
- The quasimodel approach recommendation is sound

The blocking issues are:
1. Locus-control lemma (unresolved, not even sketched at proof level)
2. Chain existence theorem (not proved, only scaffolded)
3. Chain-step seed consistency (not attempted, may or may not be hard)
4. Combined seed consistency is actually a compound problem, not sole problem

**These are implementation problems, not research problems.** Task 98 as a RESEARCH task has
delivered its mandate: it identified the quasimodel approach as the correct path and built
the Hintikka-level infrastructure. The remaining work is hard implementation work on:
- `hintikka_chain_exists` (well-founded recursion on defect_count)
- `realize_chain_step` (chain-level seed consistency)
- locus-control for arbitrary intermediate BXPoints

These should be a NEW task focused on implementation, not a continued research task.

#### What this task should NOT do

It should NOT be re-researched (round 3 research), because the research findings are sound.
The open questions are mathematical/implementation questions, not research questions:
- "Is locus control provable?" is a Lean formalization challenge, not a research gap
- "Is chain-step seed consistent?" is a mathematics question best answered by attempting the proof

A round 3 research session risks producing a 3rd synthesis report that gives even more
detailed analysis of problems already correctly identified, while adding marginal value.

#### The one genuine research gap

The ONE open research question worth investigating before attempting implementation is:

**Can the guard condition in Frame.lean's target theorems be restated in a weaker form that
matches what the quasimodel construction actually produces, without breaking TruthLemma.lean?**

Specifically: does the completeness proof in `until_iff_mcs` (TruthLemma.lean) require that
the guard holds for ALL intermediate BXPoints, or only for the CONSTRUCTED CHAIN of witnesses?
If the guard can be weakened to "there exists a chain of intermediate witnesses satisfying φ,"
then locus control is unnecessary and the proof strategy simplifies dramatically.

This could be answered in 2-3 hours by reading TruthLemma.lean, and would determine whether
the hardest open problem (locus control) is actually necessary.

---

## Confidence Level

**High confidence (90%)**:
- The quasimodel approach is correct and the existing scaffolding is pointed in the right direction
- The locus-control lemma is a genuine unresolved obstacle
- The chain existence theorem needs to be proved (it is currently only designed)
- The round 2 team was not wrong, just incomplete

**Medium confidence (70%)**:
- Chain-step seed consistency is actually harder than single-step (based on structural analysis)
- Task 98 should be closed PARTIAL with handoff rather than re-researched
- The guard condition in Frame.lean may be overly strong and could be weakened

**Lower confidence (50%)**:
- Whether a bx_le redefinition that is total by construction and preserves G/H is achievable
  (this was not seriously investigated and deserves at least a brief examination)
- Whether the combined seed consistency problem reduces to an already-proved lemma via
  a different arrangement of the proof terms

---

## Summary

The round 2 team research is largely correct but the three most important findings it MISSED are:

1. **`Construction.lean` has no proved chain existence theorem.** The quasimodel chain
   construction is designed but unproved. This was presented as "scaffolding" but the hard
   existence proof using well-founded recursion on `defect_count` was never written.

2. **Locus control is harder than presented.** The round 2 synthesis assumed sigma_signature
   projection automatically handles arbitrary intermediate BXPoints. It does not — the
   projection gives a HintikkaPoint but does not place it in the constructed chain.

3. **The gate check was a prediction, not a proof failure.** The implementation session
   pre-halted rather than attempting Phase 4. This is prudent but means the "combined seed
   consistency" obstruction has not been empirically confirmed.

The correct next action is: close task 98 as PARTIAL, create a new implementation task
focused specifically on `hintikka_chain_exists` (Phase 4a) and `realize_chain_step` (Phase 4b),
and read TruthLemma.lean before the next implementation attempt to determine whether the
locus-control lemma is required or whether the guard condition can be weakened.
