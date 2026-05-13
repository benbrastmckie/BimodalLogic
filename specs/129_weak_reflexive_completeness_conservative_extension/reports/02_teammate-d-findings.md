# Teammate D (Horizons) — Strategic Analysis for Task 129

**Task**: 129 — Weak/reflexive completeness and conservative extension
**Date**: 2026-05-13
**Role**: Horizons researcher — long-term alignment, strategic direction, creative approaches

---

## Key Findings

### 1. Reynolds 1994 Is the Closer Match, Not Doets 1989

The existing plan cites "Doets Claims 9-11" as the compression pipeline. However, Reynolds 1994 ("Axiomatising U and S over Integer Time") provides a **directly applicable** construction for our exact logic (US over Z, with Prior-UZ/Prior-SZ, discrete without endpoints). Reynolds's proof (Theorem 15 + Theorem 18):

1. Start from a Burgess-Xu linear model M (countable, discrete, no endpoints, Prior axioms valid)
2. Define "good" = has a k-equivalent with integer flow
3. Define "very good" = all subintervals are good
4. Define contemporaneous equivalence ~M using "very good" subintervals
5. Show ~ classes don't end at gaps (using Prior-UZ/SZ — Theorem 14)
6. Show the structure is very good (~ has one class) → therefore good → Z-model exists

This is cleaner than adapting Doets's general monadic Π₁¹ machinery (which handles scattered orderings, well-orderings, complete orderings, etc.) to our specific case. Reynolds already did the adaptation.

**Confidence**: High. Reynolds cites Doets via Venema 1991 "Completeness via completeness" and uses the same n-equivalence technique but specialized to integers.

### 2. The Doets Paper Handles a Different (Broader) Problem

Doets 1989 proves conservation results for monadic Π₁¹ theories over various order types: scattered orderings (§2), ω (§3), complete orderings (§4), well-orderings (§4.4), reals (§4.9), and well-founded trees (§5). The key mechanism is:

- Define ~R condensation (Lemma 1.3) based on whether intervals have n-equivalents of the desired type
- Show the condensation has certain density properties
- Use definability + induction/completeness to collapse the condensation to a single class

The Doets paper's Section 3 (Theorem 3.1) handles ω using definable induction. Section 4 handles complete orderings. Neither directly handles Z (the integers), though Z is handled implicitly via Corollary 4.4 (well-ordered + reverse well-ordered gives Z). Reynolds 1994 is the explicit Z specialization.

**Confidence**: High. This is a factual observation about the paper's scope.

### 3. "Follow Doets Closely" Should Mean "Follow the Reynolds Specialization"

The user's directive says "follow Doets closely rather than reinventing the wheel." The most faithful reading: use the Reynolds 1994 proof, which IS the Doets construction specialized to Z. Reynolds cites Doets explicitly, uses the same n-equivalence/condensation/lexicographic-sum machinery, but adds the Prior-axiom gap elimination (Lemmas 6-13) that is specific to US temporal logic over integers.

The pipeline is:
1. Burgess-Xu strong completeness → linear model M₀ satisfying F (Corollary 3)
2. Prior-UZ/SZ → no definable gaps → contemporaneous equivalences don't end at gaps (Theorem 14)
3. "Very good" condensation → one class → Z-model (Theorem 15)
4. Expressive completeness preserves truth through the construction (Theorem 18)

**Confidence**: High.

---

## Roadmap Alignment Analysis

### Critical Path Impact

Task 129 is THE critical-path task. The roadmap (updated 2026-05-13) states:

> Critical path: Task 129 (weak/reflexive completeness, PLANNED) → task 122 (discrete BFMCS) → sorry-free bx_completeness.

Success on task 129 unblocks:
- **Task 122**: discrete BFMCS on Z (sorry-free)
- **Task 130**: archive ~40 dead sorries to Boneyard
- **Task 131**: module reorganization (depends on 129 landing new modules)
- **Full `bx_completeness`**: sorry-free for first time

### Roadmap Phases Affected

1. **Phase 1 (Sorry-Free Completeness)**: Task 129 is item 1 of 3. Direct enabler.
2. **Phase 2 (Frame Hierarchy)**: Task 126 depends on 129. The Doets/Reynolds Z-model construction should produce a `TaskModel` whose frame satisfies `SuccOrder`, `PredOrder`, `IsSuccArchimedean` — exactly the Integer tier in the planned hierarchy.
3. **Phase 3 (Expressive Extensions)**: Doets n-equivalence machinery may be useful for transfer results between frame classes.
4. **Phase 4 (Algebraic Representation)**: Not directly affected.
5. **Phase 5 (Publication Quality)**: Doets-style argument is well-accepted in the temporal logic community (see below).

### Alignment Grade: Perfect

Task 129 aligns exactly with the roadmap's primary goal. No conflict with any planned evolution.

---

## Doets Machinery Reuse Potential

### What Could Be Reused

| Component | Current Use | Potential Reuse |
|-----------|------------|-----------------|
| n-equivalence (=ₖ) | Truth preservation through construction | Frame correspondence results (task 126), transfer between frame classes |
| Ordered sums (Σ) | Building Z from pieces | General model construction toolkit |
| Condensation (Lemma 1.3) | Quotient of reflexive model | Bulldozing in other contexts |
| "Good/very good" classification | Proving Z-model exists | Other frame types (ω, Q, R) |
| Contemporaneous equivalence | Gap elimination | Dense completeness improvements |
| Lexicographic sum preservation | Sum preserves =ₖ | General model surgery |

### Reynolds-Specific Components

| Component | Reuse Potential |
|-----------|----------------|
| Prior-axiom gap elimination (Lemmas 6-13) | Directly needed for our Prior-UZ/SZ axioms |
| Expressive completeness of US over Prior structures (Theorem 5) | Could strengthen other completeness results |
| "Bad points" analysis (Lemmas 10-12) | Specific to Z construction, limited reuse |
| Substructure replacement (Lemma 12) | General model surgery technique |

### Assessment

Medium reuse potential. The n-equivalence and condensation techniques are mathematically general, but formalizing them at full Doets generality would add ~500-1000 lines beyond what task 129 needs. **Recommendation**: build task-129-specific modules but with clean interfaces that could be generalized later. The n-characteristic and ordered sum definitions should be general; the gap elimination and Z-construction can be specific.

**Confidence**: Medium. Reuse depends on future task needs that may change.

---

## Module Design Recommendations

### Recommended Structure

```
Metalogic/WeakCanonical/
├── WeakOperators.lean          -- G_w, H_w, F_w, P_w definitions
├── WeakAxioms.lean             -- Weak axioms derivable in strict system
├── WeakMCS.lean                -- Weak MCS + Lindenbaum
├── WeakCanonicalModel.lean     -- Canonical model + truth lemma
├── NEquivalence.lean           -- n-characteristics, =ₖ relation, basic lemmas
├── OrderedSum.lean             -- Ordered sums, condensation (Doets §1)
├── GapElimination.lean         -- Prior-axiom gap analysis (Reynolds §7)
├── IntegerModel.lean           -- "Good/very good" + Z-construction (Reynolds §8)
├── Transfer.lean               -- Conservative extension argument
├── Integration.lean            -- Wire into ChronicleToCountermodel
└── WeakCanonical.lean          -- Root import
```

### Why This Structure Over Alternatives

**(a) Task-specific `WeakCanonical/`** (current plan) — chosen. Simple, direct, minimal risk.

**(b) General `DoetsFramework/`** — rejected for task 129. Too much scope creep. The generality adds ~500 lines without advancing the sorry closure. Can be factored out later if tasks 126/68 need it.

**(c) Separate n-equivalence library** — deferred. NEquivalence.lean and OrderedSum.lean should be written with clean, general signatures (not WeakCanonical-specific types) so they CAN be extracted later, but they live under WeakCanonical/ for now.

### Key Design Decisions

1. **NEquivalence.lean should use `Fin n → Prop` or `Finset Formula` for n-characteristics**, not a custom inductive type. This matches Mathlib conventions and enables reuse.

2. **OrderedSum.lean should define `OrderedSum` as a general construction on `LinearOrder`**, even if it's only used for one case in task 129. The extra generality is free and prevents later refactoring.

3. **WeakCanonicalModel.lean can reuse `SetMaximalConsistent` and `set_lindenbaum` from `Core/MaximalConsistent.lean`** — no need to duplicate Lindenbaum infrastructure. The "weak" part is just that the axiom set includes G_w→φ and the accessibility relation is reflexive.

**Confidence**: High for structure; Medium for specific file splits (may merge some during implementation).

---

## Downstream Task Implications

### Task 122 (Discrete BFMCS on Z)

Task 129's deliverable is `limitDomSubtype_isSuccArchimedean` sorry-free. Task 122 then builds `dd_countermodel_chronicle_nondense_sorry` using the discrete pipeline. **No design constraint** from task 122 on task 129's internal structure — only the type signature of the integration point matters.

### Task 130 (Boneyard Archival)

Once task 129 closes the sorry, task 130 can archive:
- BXCanonical pipeline (~17 sorries, mathematically false under irreflexive semantics)
- Chronicle dead-end proof attempts
- Possibly some of the `succ_cofinal` infrastructure that becomes obsolete

**Recommendation**: The chronicle construction (`ChronicleConstruction.lean`, `PointInsertion.lean`, etc.) should NOT be archived. It remains the primary completeness mechanism; task 129 only replaces the `IsSuccArchimedean` proof, not the entire chronicle.

### Task 131 (Module Reorganization)

Task 129 adds `Metalogic/WeakCanonical/` (~10-12 new files, ~1200-1750 lines). Task 131 should place this alongside the existing `Metalogic/BXCanonical/` and `Metalogic/Core/` in the hierarchy. **Design implication**: keep WeakCanonical/ self-contained with minimal cross-imports, so task 131 can reorganize without untangling dependencies.

### Task 126 (Frame Hierarchy)

The four-tier hierarchy (Base → Dense/Discrete → Integer) needs the Doets Z-model to land in the Integer tier. **Design implication**: the Transfer.lean theorem should produce a `TaskModel` with explicit `SuccOrder`, `PredOrder`, `IsSuccArchimedean`, `IsPredArchimedean` instances on `ℤ`, matching Mathlib typeclasses that task 126 will use.

The existing plan already notes: "Prove auxiliary lemma: Z with standard `<` satisfies `SuccOrder`, `PredOrder`, `IsSuccArchimedean`, `IsPredArchimedean`, `Nontrivial` (these are standard Mathlib instances for Z)." This is correct and aligns with task 126.

**Confidence**: High.

---

## Publication Considerations

### Is the Doets/Reynolds Approach Accepted?

**Yes, strongly.** The approach is well-established in the temporal logic community:

1. **Doets 1989** is published in the Notre Dame Journal of Formal Logic (top venue for this area)
2. **Reynolds 1994** explicitly uses this technique for US over Z — our exact case
3. **Venema 1991** ("Completeness via completeness") applies the same method
4. **Gabbay, Hodkinson, Reynolds 1994** (the definitive textbook) includes these techniques
5. The Venema 2001 survey mentions Ehrenfeucht game techniques as standard

Reviewers in modal/temporal logic will recognize the Doets-Reynolds approach as canonical for integer completeness.

### Alternative Approaches and Reviewer Expectations

| Approach | Status | Reviewer Reaction |
|----------|--------|-------------------|
| **Doets/Reynolds n-equivalence** (our choice) | Well-established, no IRR rule | Strongly accepted |
| **IRR rule (Gabbay 1981)** | Works but non-orthodox | Some reviewers prefer orthodox systems; we avoid IRR |
| **Chronicle + direct Z1 argument** (what task 123 tried) | Novel, failed due to constant-MCS gap | Would need extensive justification; reviewers would question it |
| **Sahlqvist canonicity + bulldozing** | Standard for basic tense logic; unclear for US+Prior | Accepted if formalized, but more complex |

### Formalization Novelty

To our knowledge, **no prior Lean 4 formalization of the Doets compression or Reynolds Z-construction exists**. This is publishable as:
1. A case study in formalizing classical temporal logic completeness
2. The first sorry-free mechanized proof of US completeness over Z
3. An example of the "detour through reflexive semantics" technique in a proof assistant

**Confidence**: High.

---

## Creative/Unconventional Approaches

### 1. Generic Doets Theorem (Theorem 1.2) Instantiation

Instead of building a task-129-specific pipeline, formalize Doets's Theorem 1.2 generically:

> If every model of Σ + Lₖ-definably-φ has an n-equivalent satisfying Σ + ∀Rφ(R) for each n, then the first-order schema suffices to prove all monadic Π₁¹-consequences.

Then instantiate with Σ = BX axioms, φ = IsSuccArchimedean, and prove condition (ii) using the Reynolds construction.

**Trade-off**: +500-800 lines to formalize generically, but produces a reusable conservation theorem applicable to other frame properties. Could enable task 126 (Sahlqvist correspondence) to use the same framework.

**Recommendation**: Not for task 129 (too much scope creep), but note this as a future possibility. The specific Reynolds construction is cleaner for the immediate goal.

**Confidence**: Medium (feasible but significant additional work).

### 2. Direct Reynolds Construction Without Weak Operators

The existing plan builds weak operators G_w, H_w, etc. and a separate "weak" axiom system. But Reynolds 1994 doesn't use weak operators at all — he works directly with the strict Burgess-Xu system + Prior-UZ/SZ. His proof:

1. Burgess-Xu strong completeness gives a linear model (Corollary 3)
2. Gap elimination uses Prior axioms (§7) — no weak semantics needed
3. Very-good condensation gives Z-model (§8) — pure model theory

The "weak canonical model" approach (Phases 1-3 of the current plan) adds ~800 lines to build infrastructure that Reynolds's proof doesn't need. The existing plan's Phases 1-3 are essentially building a reflexive Henkin canonical model from scratch, then quotienting it. Reynolds skips this by using the Burgess-Xu canonical model directly (which already exists as the Chronicle construction!) and doing model surgery.

**Critical question**: Can we adapt the existing Chronicle countermodel (which already produces a discrete linear model satisfying all axioms) instead of building a new Henkin model? If so, Phases 1-3 of the plan (~800 lines, ~18 hours) could be replaced by a much shorter argument that takes the Chronicle output and applies Reynolds's condensation.

**Trade-off**: This would eliminate the "weak" infrastructure entirely. The construction would be:
1. From consistent ¬φ, get a Chronicle countermodel M (already exists, modulo the sorry)
2. But wait — the sorry IS the thing we're trying to close. We need IsSuccArchimedean of M, which is exactly what we can't prove about the Chronicle model.

So this doesn't work as stated. The weak canonical model is needed because the Chronicle construction loses the distinct-MCS property that enables gap elimination. The existing report (Section 8, "Key Insight: The Definability Gap") explains this correctly.

**However**, there's a subtlety: Reynolds's proof doesn't build a "weak" canonical model either. He starts from the Burgess-Xu strong completeness theorem (which gives a linear model via chronicle-like construction), then applies gap elimination using Prior axioms. The gap elimination works because Reynolds uses **expressive completeness** (Kamp's theorem for US over Prior structures) to translate between temporal and monadic formulas, making ALL subsets "definable" in the relevant sense.

This suggests: **the correct approach may not need weak operators at all**, but instead needs:
1. A canonical-model-based linear countermodel (the Chronicle model, or a standard Henkin model)
2. Expressive completeness of US relative to monadic logic over Prior structures
3. Reynolds's condensation argument using n-equivalence

The weak operator approach in the existing plan is one way to get (1) without the Chronicle's constant-MCS problem. But Reynolds achieves (1) via Burgess-Xu directly. The difference: Reynolds's starting model is Burgess's chronicle, which CAN have constant MCS, but Reynolds doesn't need distinct MCS — he uses expressive completeness + Prior axioms to eliminate gaps, not the definability gap argument.

**This is a significant insight**: the existing plan's "definability gap" analysis (Section 8) may be solving the wrong problem. The Reynolds proof avoids the definability gap entirely by using expressive completeness + Prior axioms for gap elimination, rather than relying on canonical model points being distinct MCS.

**Recommendation**: This deserves careful analysis. If Reynolds's approach truly avoids the need for weak operators, the implementation could be ~800 lines shorter. But the Lean formalization of expressive completeness (Kamp's theorem) could be substantial.

**Confidence**: Medium-Low (this needs careful mathematical verification before committing to it).

### 3. Use Mathlib's `Finpartition` for Condensation

Mathlib has `Finpartition` and related constructs. The condensation step (Doets Lemma 1.3) produces a partition of the model into convex classes. If we can represent this using Mathlib's partition infrastructure, we get lemmas about partition refinement for free.

**Recommendation**: Check `Mathlib.Order.Partition.Finpartition` and related files. Even if not directly usable, the API patterns should inform our design.

**Confidence**: Low (Mathlib's partition infrastructure may not match our needs precisely).

---

## Confidence Summary

| Finding | Confidence |
|---------|------------|
| Reynolds 1994 is the closer match than raw Doets 1989 | High |
| Roadmap alignment is perfect | High |
| Module should be under `Metalogic/WeakCanonical/` | High |
| Publication acceptability of Doets/Reynolds approach | High |
| Clean separation for downstream tasks | High |
| Reuse potential of n-equivalence framework | Medium |
| Specific file splits in module design | Medium |
| Generic Theorem 1.2 not worth the scope creep now | Medium |
| Reynolds proof may not need weak operators | Medium-Low |
| Mathlib partition reuse | Low |
