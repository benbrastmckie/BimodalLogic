# Strategic Assessment: Task 98 (Teammate D — HORIZONS)

**Task**: 98 — Research filtration/quasimodel pivot for Until/Since truth lemma
**Round**: 3
**Role**: HORIZONS (long-term/strategic alignment)
**Date**: 2026-04-10
**Artifact**: 03_teammate-d-findings.md

---

## Roadmap Alignment

### The Project's Stated Long-Term Goal

The `ROAD_MAP.md` and `Theories/Bimodal/README.md` are explicit: the goal is
**a verified soundness and completeness proof for the BX bimodal logic TM over
reflexive linear temporal orders**, leading to a publication-quality Lean 4
formalization. The README already describes the project as "production-ready
with complete metalogic verification" — but that claim is aspirational for the
BX system. The actual sorry inventory tells the honest story: 6 active-path
sorries block `bx_completeness`, and 4 of those 6 are the Until/Since lemmas
that task 98 targets.

### Is Task 98 on the Critical Path?

Yes, but with a significant qualification: **task 98 has already done its job
as a research task**. It was spawned to answer a specific question — "can the
filtration/quasimodel approach bypass the g_content propagation obstruction?" —
and it answered that question conclusively across two rounds and five teammates.
The answer is: yes, a local Hintikka-set quasimodel works; the guard is trivial
at the Hintikka level; the sole remaining hard problem is combined seed
consistency for the realization lifting lemma; and that problem could not be
closed in the Phase 4 gate check.

What task 98 has NOT done is deliver sorry-free Lean code. It has delivered
research findings and a partial implementation (6 sorries in Realization.lean
documenting the gap). The question is whether the task should continue as an
implementation task, or whether the research deliverable should be declared
complete and the implementation work scoped as a new task.

### Scope Boundary Assessment

Task 98 was originally scoped as a **research** task (effort: 8-12 hours).
It has now accumulated:
- Round 1 research (01_filtration-quasimodel-pivot.md): research complete
- Round 2 team research (02_team-research.md): research complete
- Plan v1 and v2 (01 and 02 under plans/): two full implementation plans
- Partial implementation through phases 1-3 and part of 4 (commits 330d4449f through 661f20557)
- Round 3 team research (this round): underway

This is implementation scope, not research scope. The task has blurred the
research/implementation boundary in a way that creates strategic confusion
about what "completing task 98" means. This is the central strategic finding:

**Task 98 is research-complete. Its natural successor is a fresh implementation
task that inherits the Quasimodel scaffolding and targets combined seed
consistency specifically.**

---

## Adjacent Opportunities

### 1. Task 93 (Box Sorry + TaskModel Embedding) is Unblocked in Parallel

The sorry at `Frame.lean:440` (`bx_modal_witness`, Box direction) and
`Completeness.lean:154` (TaskModel embedding) are assigned to task 93 and
do NOT depend on the Until/Since sorries. `bx_completeness` needs both,
but the Box and TaskModel work is independent. If the Until/Since path is
genuinely expensive (40-80h for full quasimodel), **task 93 can begin now
and proceed in parallel** — closing 2 of 6 active-path sorries without any
dependency on the quasimodel outcome.

This is a concrete opportunity cost observation: every cycle spent on task 98's
Phase 4 gate check is a cycle not spent on task 93, which has a cleaner and
more standard proof structure (S5 Lindenbaum + constant-history avoidance is
well-understood).

### 2. Task 93 Provides a Semantic Alternative to the Quasimodel

The `Completeness.lean:154` sorry requires building a TaskModel from the BXPoint
canonical frame. If task 93 builds a full TaskModel construction (with
non-constant histories visiting multiple BXPoints), this is essentially a
**global quasimodel embedding** — the "Option C (defer)" from the implementation
summary. A working TaskModel embedding does NOT require the Until/Since truth
lemma to be proved inside BXCanonical; it requires the BXPoint canonical frame
to admit a TaskModel interpretation where Until/Since are semantically satisfied.

This is worth making precise: the four Frame.lean sorries prove properties of
the BXPoint canonical frame under `bx_le`. The TaskModel embedding (task 93)
constructs a full semantic model. If the TaskModel's truth conditions can be
shown to agree with the BXPoint frame's combinatorial properties, the Until/Since
truth lemma might be derivable at the model level (via truth semantics) rather
than at the frame level (via `bx_le` combinatorics). This is a genuine
alternative path that the previous research rounds have not fully explored.

### 3. The Quasimodel Infrastructure is Already Valuable for Automation

The SubformulaClosure, HintikkaPoint, and Construction modules completed in
phases 1-3 (commits 330d4449f, bce8f9f38, 661f20557) are sorry-free and
represent real infrastructure. Even if the realization lifting lemma is never
closed, the quasimodel construction could serve as a **model-checking procedure**:
given a formula and a finite Hintikka set, check whether the formula is satisfied
in some quasimodel. This connects to `Automation/` and the decidability proof
(task 95 depends on task 93, which depends on task 92). The Quasimodel
infrastructure may independently strengthen `Metalogic/Decidability.lean` by
providing a finite certificate for satisfiability.

### 4. Legacy Code Archival (Task 94) Is Completely Unblocked

Task 94 (archive UltrafilterChain.lean, FrameConditions/Completeness.lean, etc.)
depends only on task 91, which is COMPLETED. Task 94 would drop ~210 sorries
from the total sorry count and clean the codebase significantly. This is a
pure opportunity cost: task 94 can be executed right now and provides immediate
visible progress. The roadmap explicitly calls task 91 a prerequisite, which is
satisfied.

---

## Alternative Completeness Strategies

### Alternative 1: Modal Fragment First (Tractable Subset)

The truth lemma for `{atom, bot, imp, box, G, H}` (without Until/Since) is
**entirely sorry-free** in the current codebase. The four sorry cases in
`TruthLemma.lean` all delegate to the four `Frame.lean` helpers which are the
Until/Since cases. A "modal fragment completeness" theorem for the G/H/Box
fragment would be:

```
theorem bx_modal_fragment_completeness (φ : Formula) (hφ : no_until_since φ) :
    valid φ → Nonempty (DerivationTree [] φ)
```

This theorem is essentially provable **today** because the truth lemma for
the modal fragment is complete. The two remaining sorries that touch this
fragment are `Frame.lean:440` (Box direction, task 93) and
`Completeness.lean:154` (TaskModel embedding, task 93). If task 93 closes
those two, the modal fragment completeness is achievable within weeks.

**Strategic value**: Publishing modal fragment completeness as an intermediate
result, then extending to Until/Since, is standard academic practice in
the tense-logic literature. It would constitute a genuine publication milestone
even before Until/Since are resolved.

### Alternative 2: Filtration via Quotient Construction (Finite Model Property Route)

The FMP module (`Metalogic/Decidability.lean`, tasks 82 and the ROAD_MAP
note on FMP) is separate from the canonical model completeness path. The ROAD_MAP
notes that `fmp_contrapositive` does not bridge to completeness "without a
truth lemma connecting validity to closure MCS membership." However, this
presumes the standard bridge.

A **filtration completeness** proof works differently: instead of building an
infinite canonical model and proving the truth lemma, one builds a finite
filtrated model directly from the non-provable formula and proves that the
filtration satisfies the formula. For TM with Until/Since, the standard
filtration for tense logics (see Gabbay-Hodkinson-Reynolds "Temporal Logic"
Ch. 4, or Fine's filtration technique) produces a finite pre-linear order
on equivalence classes of subformulas. The key question is whether the BX
axioms (specifically BX5-BX10 for Until/Since) are preserved under filtration.

Prior task 98 round 1 research noted filtration would "cascade-break
box_preserved_along_bx_le." However, **this is the global filtration assessment.**
A local filtration applied only to the Until/Since subformula closure, keeping
the BXPoint frame intact for Box/G/H, might avoid the cascade. This differs
from what round 1 assessed. The distinction:

- **Global filtration** (rounds 1 and 2 correctly rejected): Replace BXPoint
  frame with a quotient frame. High cascade cost.
- **Local filtration of Until/Since witness set** (not previously evaluated):
  Within the proof of `bx_until_eventuality_resolution`, construct a finite
  linearly ordered subset of BXPoints sufficient to witness the Until chain,
  using the subformula closure Sigma as a finiteness bound. This does NOT
  change the ambient frame — it just argues that a finite witness subframe
  exists inside the infinite BXPoint frame.

The Quasimodel subfolder already has SubformulaClosure and HintikkaPoint. The
question is whether the realization of a Hintikka chain into BXPoints can be
finitely bounded. If `|Sigma|` bounds the chain length, then Well-Founded
induction on `Fintype.card Sigma` would close the termination proof for the
chain recursion — which is exactly the open issue in the implementation summary
("explicit well-founded recursion on defect_count needs a termination proof").

**Concrete suggestion**: Define `defect_count (h : HintikkaPoint Sigma) : ℕ`
as the number of Until-formulas `φ U ψ ∈ h.formulas` with `ψ ∉ h.formulas`.
Show that `hintikka_step h1 h2` implies `defect_count h2 < defect_count h1`
(one Until obligation resolved per step). Since `defect_count` is bounded by
`Fintype.card Sigma`, the chain terminates in at most `|Sigma|` steps. This
provides the constructive termination proof that the implementation summary
identified as missing. It does not require new axioms and operates entirely
at the HintikkaPoint level (no combined seed consistency needed for termination).

### Alternative 3: Algebraic Completeness via STSA (Task 992 Direction)

Task 992 researched Shift-Closed Tense S5 Algebras (STSAs) as a representation
theorem target. The algebraic approach to completeness does not build a canonical
model — instead it proves that every consistent formula is satisfied in some
STSA, using the Lindenbaum-Tarski quotient.

For the **Until/Since operators**, the algebraic approach requires extending
the STSA signature with residuated pairs `(U, \bar{U})` and `(S, \bar{S})`
satisfying the BX axiom equations algebraically. This is the Boolean Algebra
with Operators (BAO) approach to tense logic completeness. Goldblatt's 1992
paper "Logics of Time and Computation" uses exactly this for linear tense logics
without Until/Since; extending it to Until/Since requires the BAO equations for
the reflexive Until operator.

This alternative is **long-range** (estimated 60-120h in task 992's analysis),
but it would produce a structurally cleaner completeness proof that does not
depend on the quasimodel infrastructure at all. It also connects to the
already-existing `AlgebraicRepresentation.lean` and would unify the algebraic
and canonical-model completeness approaches.

**Strategic assessment**: Task 992 is in RESEARCHED state. If the quasimodel
path is abandoned, the STSA direction is the most principled long-range
alternative. However, it does not provide a near-term (weeks) path to closing
the four Frame.lean sorries.

---

## Strategic Recommendation

### Go/No-Go on Task 98 as an Implementation Task

**Recommendation: PARTIAL CLOSE of task 98 as a research task; spin off a new
focused implementation task.**

The rationale:

1. Task 98 was scoped as a research task (8-12h). It has delivered research
   findings that fully answer the original research questions. The CONDITIONAL
   GO from round 1 and the quasimodel scaffolding from the implementation
   attempt are both genuine deliverables.

2. The Phase 4 gate check failure is not a research failure — it is an
   implementation boundary that correctly identifies the scope of remaining work.
   The gate check mechanism worked as intended.

3. The remaining work (combined seed consistency + termination proof for
   `defect_count`) is an **implementation task**, not a research task. It
   has a clear definition: prove the defect_count termination lemma, prove
   combined seed consistency, close 4 Frame.lean sorries, close 6
   Realization.lean sorries.

4. Task 98's research findings (rounds 1-3) provide all the necessary context
   for a new plan. A fresh `/plan 92` drawing on task 98's three rounds of
   research would produce a correctly-scoped implementation plan.

### Immediate Recommended Actions (Ordered by Strategic Value)

**Action 1 (highest ROI, unblocked today)**: Execute task 94. Archive the
~210-sorry legacy files. This immediately drops the project's total sorry count
by ~210 and makes the codebase's actual state (6 active-path sorries) legible.
Cost: low, fully mechanical.

**Action 2 (highest research-to-implementation leverage)**: Begin task 93 in
parallel with any continued task 98 work. The Box sorry at `Frame.lean:440`
and the TaskModel embedding at `Completeness.lean:154` are independent, well-
scoped, and their resolution unlocks the modal fragment completeness milestone.

**Action 3 (if continuing quasimodel path)**: Spin off a new task (call it
task 99) specifically targeting:
  (a) Prove `defect_count` termination: `hintikka_step h1 h2 → defect_count h2 < defect_count h1`
  (b) Prove combined seed consistency: `h_i.formulas ∪ g_content(v_{i-1}.formulas)` consistent
  (c) Assemble the realization chain from (a) and (b)

This scoping is more honest than continuing to stretch task 98 (a research
task) into a multi-week implementation effort.

**Action 4 (if not continuing quasimodel path)**: Accept the four Frame.lean
sorries as documented technical debt. Mark them with a comment referencing
task 98's research as the explanation. Close task 92 as PARTIAL with the 4
sorries explicitly labelled as pending task 93's TaskModel embedding (which
provides the semantic alternative). Proceed to publication on the modal
fragment result.

### The Core Strategic Question

There is a question the previous research rounds have avoided naming directly:

**Is this project pursuing completeness for TM (the full bimodal logic with
Until/Since) or for the G/H/Box fragment?**

The README says "complete metalogic verification" and lists Until/Since as
primitive operators in the syntax. The BimodalReference.tex presumably gives
the full formal specification. But the actual publication-ready result that
is achievable in the near term (1-3 months) is completeness for the G/H/Box
fragment, with Until/Since pending 40-120h of additional work.

This is not a failure — it is the honest state of a research formalization.
The right strategic move is to:
1. Document the modal fragment completeness milestone explicitly in the roadmap
2. Continue the Until/Since work as a separate, correctly-scoped effort
3. Avoid conflating the two in task status reporting

---

## Confidence Level

**High confidence (90%)** on the following assessments:
- Task 98's research deliverable is complete; the remaining work is implementation
- Task 94 and task 93 are immediately actionable and high-value
- The defect_count termination approach is the right lever for the quasimodel realization chain
- Modal fragment completeness (G/H/Box) is achievable in the near term

**Medium confidence (65%)** on the following:
- The "local filtration of Until/Since witness set" alternative (Alternative 2 variant)
  — this has not been formally evaluated; it could be blocked by something the
  prior rounds didn't surface, but it deserves explicit investigation before
  the quasimodel path is declared the only option
- The TaskModel embedding (task 93) providing a semantic alternative to the
  quasimodel frame-level proof — depends on the exact form of the embedding,
  which task 93 has not yet designed

**Lower confidence (50%)** on:
- The STSA algebraic alternative (Alternative 3) providing a shorter path than
  the quasimodel — the BAO equations for reflexive Until are non-standard and
  the Lean formalization cost is unknown

---

## Summary for Synthesis

The HORIZONS assessment: task 98 has earned a research DONE designation.
The project should restructure around three parallel tracks:

1. **Near-term (weeks)**: Task 94 (archive legacy) + Task 93 (Box + TaskModel)
2. **Medium-term (months)**: New task 99 targeting defect_count termination +
   combined seed consistency (inherits quasimodel scaffolding from task 98)
3. **Long-range (parallel research)**: Revisit STSA algebraic completeness
   (task 992 direction) as an alternative that bypasses the canonical-model
   machinery entirely

The Until/Since truth lemma is worth finishing — it is on the critical path to
the publication claim. But continuing to route that work through task 98
(a research task) rather than a dedicated implementation task is an organizational
misalignment that should be corrected now, at round 3.
