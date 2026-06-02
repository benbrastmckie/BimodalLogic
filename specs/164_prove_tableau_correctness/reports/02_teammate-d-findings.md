# Teammate D Findings: Strategic (Horizons) Angle
## Task 164 — Prove Tableau Correctness Theorem

**Researcher**: Teammate D (Horizons / Long-Term Alignment)
**Date**: 2026-06-01
**Scope**: Strategic questions about deferral vs. resolution, project roadmap alignment, and lessons from the Obendrauf (2024) Lean 4 coalition logic formalization

---

## Key Findings

### 1. Current State: 3 Sorry Sites Remain

Phase 1-3 of the implementation plan are marked COMPLETED. What remains:

| Sorry | File | Description | Phase Needed |
|-------|------|-------------|--------------|
| `truthLemma_neg` (untl) | CountermodelExtraction.lean L838 | F(U(event,guard)) case blocked: transitive-closure gap | Phase 4 |
| `truthLemma_neg` (snce) | CountermodelExtraction.lean L842 | Mirror of untl | Phase 4 |
| `blocking_terminates` | Saturation.lean L663 | Pigeonhole termination argument | Phase 5/6 |

The three are structurally independent: `blocking_terminates` has no dependency on the truth lemma chain.

### 2. Downstream Task Impact Analysis

From the TODO.md dependency table:

```
Wave 2: tasks 164, 186, 192, 196, 230, 242  (depend on Wave 1)
Wave 3: tasks 95, 176, 193, 231, 245, 246   (depend on Wave 2, including 192)
Wave 4: tasks 177, 178, 243, 244, 247, 254  (depend on Wave 3 + 242 + 245 + 246)
```

Task 242 ("Tableau-derived proof step extraction") and task 246 ("Lean REPL tableau bridge") are in Wave 2, along with task 164. These are part of the tableau-training topic cluster: they generate ProofStepRecord JSONL from tableau-proved formulas for ML training data. Task 247 ("End-to-end training loop validation") depends on 242, 245, and 246.

**The critical finding**: Task 164's sorry sites do NOT block Wave 2 or downstream tableau-training tasks. Tasks 242 and 246 depend on the *working* decision procedure (which exists), not on its formal *correctness proofs*. The `decide` function generates valid proof steps and countermodels already; `branchTruthLemma` sorries do not affect runtime behavior.

**What IS blocked by the 3 sorries**: The claim that `decide_complete` is formally verified. This matters for:
- Publication claims ("sorry-free correctness of the decision procedure")
- Task 95 (verification audit, Wave 3) which likely checks for sorry sites
- Any theorem that needs to transitively import `branchTruthLemma` as a dependency

### 3. Should These 3 Sorries Be Resolved NOW?

**Strategic answer**: The `blocking_terminates` sorry should be resolved relatively soon (before task 95 audit). The two `truthLemma_neg` sorries can be deferred without blocking the tableau-training pipeline, but deferral shifts them to task 165 scope (semantic FMP), where the same difficulty appears.

**Argument for resolving NOW** (truthLemma_neg):
- The blocker is precisely identified in the plan (Phase 4 BLOCKER section): the structural IH on formula cannot provide F(U(event,guard)) propagation through the transitive closure of `isTimeOrderedBefore`. Four potential fix paths are documented.
- The fix most likely to work is option (d): modify `untlNeg` rule to always include F(event) in branch 2. This is a rule engine change (1 line in Tableau.lean) that makes `sat_untl_neg_strong` trivial, which then closes the truth lemma case.
- The cost of deferral: any downstream formalization of semantic properties that depends on `branchTruthLemma` inherits these sorries.

**Argument for deferring** (truthLemma_neg):
- The `SemanticCountermodel` is a separate layer from the `valid` definition; `decide_complete` as currently architected still requires a semantic bridge (Nat-indexed vs. polymorphic D), which is itself non-trivial work regardless of whether the truth lemma sorries are resolved.
- The project's critical path (see ROADMAP.md) is discrete completeness via the Reynolds bypass (task 202). Tableau correctness is important for the "decision procedure as a tool" story but is not on the completeness critical path.
- Task 165 (semantic FMP) will face the same Until/Since filtration difficulty. Insights from that work may simplify the truth lemma approach here.

**Recommendation**: Resolve `blocking_terminates` now (independent, no blockers, uses established Mathlib pigeonhole infrastructure already in the codebase). Defer `truthLemma_neg` sorries with a documented structural fix path, contingent on rule engine modification.

### 4. Is Partial Correctness Sufficient for the Project's Goals?

The project has two distinct goals with different requirements:

**Goal A: ML training data generation** (tasks 242, 246, 247)
- Requires: `decide` works correctly at runtime
- Does NOT require: formal proof of `decide_complete` or `branchTruthLemma`
- Status: Already satisfied. The sorries are in proof objects, not in executable code.

**Goal B: Publication-quality formal verification**
- Requires: Sorry-free correctness chain
- Status: `decide_sound` is sorry-free. `decide_complete` and `decide_terminates` carry sorries.
- Impact: README claim "sorry-free (tableau)" is currently misleading; the procedure works but its completeness is formally unverified.

**Verdict**: Partial correctness (`decide_sound` sorry-free) IS sufficient for Goal A. For Goal B, the two `truthLemma_neg` sorries must be addressed eventually, but the project roadmap places this in Phase 5 (Publication quality, task 95) not on the current critical path.

### 5. Would Restructuring branchTruth Semantics Help?

The plan's Phase 4 BLOCKER notes option (c): "Modifying `branchTruth` for `untl` to quantify over `futureOf` (direct successors) instead of `isTimeOrderedBefore` (transitive closure), then proving a separate step-wise-to-transitive bridge lemma."

This is actually the most architecturally sound path. Here is why:

The real semantics uses:
```
truth_at (untl event guard) at t
  ↔ ∃ s, t < s ∧ truth_at event s ∧ ∀ r, t < r < s → truth_at guard r
```

The `branchTruth` currently uses `isTimeOrderedBefore` (transitive closure of `futureOf`). If `branchTruth` for `untl` used:
```
∃ t' ∈ futureOf t, branchTruth event t' ∧ ∀ t'' ∈ timesBetween t t', branchTruth guard t''
```
then `sat_untl_neg` (which provides results about `futureOf t` direct successors) would be exactly what the truth lemma needs.

The separate bridge lemma would need to show that direct-successor-based semantics agrees with transitive-closure-based semantics for the extracted model structure. This is provable because the `SemanticCountermodel`'s time ordering is constructed from tableau expansions, where the transitive closure of `futureOf` equals the set of all times reachable from the root.

**This is not a workaround—it is the correct semantics** for the finite branch model. The branch model's time structure is a dag (directed acyclic graph), and direct successors in the dag are the correct analogue of the semantic "next future point."

### 6. Lessons from Obendrauf (2024) — Coalition Logic in Lean 4

The Obendrauf paper formalizes completeness of CLC (Coalition Logic with Common Knowledge) in Lean 4, achieving a fully sorry-free formalization. Key architectural lessons relevant to task 164:

**6.1 Canonical-then-filter pattern**

Obendrauf uses a two-stage approach:
1. Build an infinite canonical model where every consistent formula is satisfied
2. Filter through the formula closure to get a finite model

This is structurally analogous to the bimodal project's approach (BXCanonical + filtration), but for a logic without temporal operators. The key insight Obendrauf emphasizes: **small implementation choices in closure definitions can have unintended effects in the truth lemma** (Section 8.2, p. 9). Their fix was to require subformulas of ALL elements of cl(φ) to be in cl(φ), not just subformulas of φ itself. The same care is needed for the bimodal closure.

**6.2 Datatype-level clarity (Set vs. Finset vs. List)**

Obendrauf notes they needed three versions of many lemmas—one for Set, one for Finset, one for List—because Lean requires explicit datatype conversions. The `branchTruth` and `SemanticCountermodel` use a mix of `List` and function-based representations. If the truth lemma bridge requires working with both, explicit Finset/Set conversion lemmas will be needed in the same way.

**6.3 Generic typeclass abstractions reduce redundancy**

Obendrauf wraps propositional logic in a `Pformula` typeclass, so the same Lindenbaum lemmas work for CL, CLC, and CLK. For the bimodal project, the existing `FrameClass` abstraction plays a similar role. The `decide_complete` semantic bridge could benefit from a similar abstraction: define a typeclass for "satisfies the branch structure" that both `SemanticCountermodel` and `TaskFrame Int` instantiate.

**6.4 Common knowledge path as inductive proposition**

The most interesting structural similarity: Obendrauf encodes the common knowledge accessibility path as an inductive predicate `C_path`, which allows structural induction over the path. The bimodal `isTimeOrderedBefore` function uses a fuel parameter instead. If `isTimeOrderedBefore` were replaced by a `Relation.TransGen`-based definition, the truth lemma induction could use Mathlib's `Relation.TransGen.head_induction_on` for cleaner structural proofs.

### 7. Mathlib Infrastructure for the Remaining Sorries

**7.1 blocking_terminates — Pigeonhole**

The pattern already exists in the codebase at `Claim1.lean:815`:
```lean
obtain ⟨i, j, hij, h_same_nf⟩ := Fintype.exists_ne_map_eq_of_card_lt nf_map h_card
```
The same `Fintype.exists_ne_map_eq_of_card_lt` can be applied here. The structure would be:
1. Define a `TimeType` as a `Finset SignedFormula` (the formulas true at a time point)
2. Show `TimeType` is a `Fintype` with `card ≤ 2^(2n)` where `n = (subformulaClosure φ).card`
3. Map each time point in the branch to its `TimeType`
4. Apply `Fintype.exists_ne_map_eq_of_card_lt` with the fuel bound

The main prerequisite is the generalized subformula property (formulas expanded during rule application stay within the subformula closure), which the current `subformula_property` only proves for the initial branch. A generalized version tracking all rule applications is needed, but the inline comment confirms this is feasible.

**7.2 truthLemma_neg (untl/snce) — Transitive closure**

If `isTimeOrderedBefore` were refactored to use `Relation.TransGen`, the following Mathlib lemmas would apply:
- `Relation.TransGen.head_induction_on`: induction on the first step of a transitive path
- `Relation.TransGen.trans_right`: transitivity

However, this is a refactoring of `CountermodelExtraction.lean`'s time model, which is significant work. The simpler fix (option d: modify `untlNeg` rule to add F(event) to branch 2) does not require any refactoring of the time model.

### 8. Recommended Approach

**Priority 1 (resolve now)**: `blocking_terminates`
- Approach: Generalize `subformula_property` to track formulas through all rule applications, then apply `Fintype.exists_ne_map_eq_of_card_lt`
- Precedent: `Claim1.lean:815` shows the exact pattern in this codebase
- Estimated effort: 1-2 phases (generalized subformula property + pigeonhole application)

**Priority 2 (resolve via rule engine fix)**: `truthLemma_neg` (both)
- Approach: Modify `untlNeg` rule in `Tableau.lean` to include `F(event)` in branch 2 (option d from the Phase 4 BLOCKER). This makes `sat_untl_neg_strong` trivial and closes both truth lemma cases.
- Risk: Rule engine change may affect soundness proof of the rule. Must verify that adding F(event) to branch 2 of untlNeg keeps the rule sound (it should be, since F(U(event,guard)) implies F(event) semantically under irreflexive Until).
- Alternative if rule change is unacceptable: Refactor `branchTruth` for `untl` to use `futureOf` direct successors instead of `isTimeOrderedBefore` transitive closure.

**Priority 3 (defer)**: Full `decide_complete` semantic bridge (Nat-indexed → polymorphic D)
- This is the hardest component and is not on the critical path for ML training data generation
- Can be deferred to task 95 (verification audit) or task 165 (semantic FMP) scope

---

## Evidence and Examples

### Obendrauf Lesson 1: Closure Subtlety

From Obendrauf Section 8.2, p. 9:
> "The closure definition illustrates that small implementation choices early in the formalization process can have unintended effects later in the proof that may not be immediately obvious."

They adjusted their closure requirement from "subformulas of φ" to "subformulas of ALL elements of cl(φ)" because the truth lemma induction needed to apply to arbitrary elements of the closure, not just to φ itself.

The analogous issue in task 164: `subformula_property` is currently proved only for the initial branch (trivially, since it contains only `F(φ)`). The generalized version needed for `blocking_terminates` requires tracking all rule applications. This is exactly the closure-subtlety issue Obendrauf encountered.

### Obendrauf Lesson 2: Typeclass Reusability

From Obendrauf Section 7:
> "In Lean lemmas and definitions only apply to the syntax they are defined on... Our formalization therefore gives special attention to reusability using the typeclass system."

The bimodal project could benefit from making the "branch model instantiates semantic model" bridge a typeclass instance. This would allow the `branchTruthLemma` to be stated more cleanly and would make the semantic bridge from `branchTruth` to `valid` a matter of providing the right instance.

### Pigeonhole in Claim1.lean

The existing pigeonhole usage at `Claim1.lean:815`:
```lean
obtain ⟨i, j, hij, h_same_nf⟩ := Fintype.exists_ne_map_eq_of_card_lt nf_map h_card
```
uses `nf_map : Fin n → SomeType` and `h_card : Fintype.card SomeType < n` to find two distinct indices mapping to the same value. For `blocking_terminates`, `nf_map` would be `TimeIndex → TimeType` (time point to its signed-formula set), and `h_card` would be the bound `2^(2*(subformulaClosure φ).card)`.

---

## Confidence Level

| Assessment | Confidence |
|-----------|-----------|
| 3 remaining sorries are the correct inventory | High — verified by grep of sorry sites |
| blocking_terminates is independently solvable now | High — pigeonhole pattern established in codebase |
| truthLemma_neg fix via untlNeg rule modification is sound | Medium — semantics of untlNeg rule must be verified |
| branchTruth refactor to futureOf semantics is viable | Medium — depends on how time ordering is constructed |
| 3 sorries do NOT block ML training pipeline | High — execute path doesn't use sorry branches |
| Deferring truthLemma_neg is strategically safe | Medium — creates technical debt that appears in task 165 |
| Obendrauf typeclass approach is directly applicable | Medium — bimodal has different formula type, but pattern transfers |

---

## Summary for Planner

The strategic picture is:

1. **Resolve `blocking_terminates` now** using `Fintype.exists_ne_map_eq_of_card_lt` (precedent at Claim1.lean:815). Requires a generalized subformula property as prerequisite.

2. **Fix `truthLemma_neg` via a 1-line rule engine change**: Add `F(event)` to branch 2 of `untlNeg` rule in `Tableau.lean`. This avoids the transitive-closure induction difficulty entirely. Must verify soundness of the modified rule.

3. **Defer the semantic bridge** (`branchTruth` ↔ `valid` via concrete `TaskFrame Int`). Not blocking ML training pipeline. Deferred to task 95 scope.

4. **No sorry deferral is acceptable** for the rule engine approach — the fix is structurally sound and avoids option B sorry deferral.

5. The broader completeness critical path (Reynolds bypass, task 202) is unaffected by task 164's sorry sites.
