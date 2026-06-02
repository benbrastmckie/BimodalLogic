# Teammate B Research Findings: Alternative Approaches for 3 Sorry Sites

**Task**: 164 — Prove tableau correctness theorem
**Focus**: Alternative proof strategies that avoid or sidestep the local-to-global gap

---

## Key Findings

### Finding 1: The Local-to-Global Gap is Structural — Not a Coincidence

After reading the full `untlNeg`/`snceNeg` rule implementation in `Tableau.lean` (lines 739–783), the gap is precisely characterised:

- `sat_untl_neg` (CountermodelExtraction.lean, lines 619–673) gives: for every `t'` in `timeOrd.futureOf t` (DIRECT successors only), either `F(event) ∈ b` or `F(guard) ∈ b` at `(w, t')`.
- But `branchTruth cm w t (.untl event guard)` uses `isTimeOrderedBefore` which is TRANSITIVE CLOSURE — it quantifies over all times reachable from `t`, not just direct successors.
- The gap: we have inductive obstruction coverage for direct successors only, but `¬ ∃ t' in transitive-closure, ...` requires denying all reachable times.

The `untlNeg` rule is Reynolds co-decomposition (from Reynolds 1992/1994): it branches over one direct successor at a time, propagating `F(U(e,g))` forward. Each branch either adds `F(event)` or `F(guard) ∧ F(U(e,g))` at that time. This is correct as a saturation rule but the current truth lemma formulation expects to reason about the full transitive closure semantics in one step.

### Finding 2: The `isTimeOrderedBefore` Definition Uses Fuel-Bounded Reachability

`isTimeOrderedBefore` (CountermodelExtraction.lean, lines 188–199) uses fuel-bounded DFS over `timeOrd.futureOf`. This means `t1 <ᵒʳᵈ t2` in `branchTruth` is defined as "reachable via the constraint graph". The constraint graph has only the edges added by `addFuture`/`addPast`, which are precisely the pairs introduced by rule applications.

**Critical observation**: The `timesBetween` function (lines 226–229) returns only times in `cm.times` (= `b.knownTimes`) that are strictly between `t` and `t'`. So `branchTruth` for `untl` never talks about times outside `knownTimes`. The semantics are entirely about the finite branch model.

### Finding 3: ALTERNATIVE APPROACH A — Direct Induction on Reachability

Rather than connecting `sat_untl_neg` (which covers direct successors) to the full semantic `¬ ∃ t'...` goal, we can prove the truth lemma for `untl` by induction on the fuel/depth of `isTimeOrderedBefore`.

**Strategy**: Define `¬branchTruth cm w t (.untl event guard)` by showing that for every `t'` reachable from `t` at any depth `d`:
1. Either `F(event) ∈ b` at `(w, t')` (by IH on `¬event`)
2. Or `F(guard) ∈ b` at `(w, t')` for all "between" times (using `F(U(e,g)) ∈ b` at `t'` plus induction)

This would require a helper lemma:
```lean
-- All times reachable from t have F(event) ∈ b or F(guard) ∈ b
-- (with F(U(e,g)) propagated to each reachable time by sat_untl_neg applied inductively)
lemma untlNeg_propagates (b : Branch) (timeOrd : TimeOrdering)
    (hSat : findUnexpanded b = none)
    (event guard : Formula) (w : WorldIndex) (t : TimeIndex)
    (hmem : ⟨.neg, .untl event guard, ⟨w, t⟩⟩ ∈ b) :
    ∀ t' : TimeIndex, isTimeOrderedBefore timeOrd t t' →
      ⟨.neg, event, ⟨w, t'⟩⟩ ∈ b ∨ ⟨.neg, .untl event guard, ⟨w, t'⟩⟩ ∈ b
```

This holds because: (a) `sat_untl_neg` gives it for direct successors; (b) the `untlNeg` rule is `persistent` — it re-includes `F(U(e,g)) @ (w, t)` in both branches; (c) by saturation, `F(U(e,g))` also propagates to future times via `untlNegAtTime` propagation in `untlPos` rule (lines 679–682 in Tableau.lean). So for any `t' > t`, `⟨.neg, .untl event guard, ⟨w, t'⟩⟩ ∈ b`.

**This is the key insight**: the Reynolds `untlNeg` rule propagates `F(U(e,g))` to ALL future times on the branch (via the `untlNegAtTime` auto-propagation in `untlPos` and via the persistent `sf` re-inclusion in untlNeg branches). A saturated branch has `F(U(e,g))` at every future time, and `sat_untl_neg` applied at each such time gives `F(event) ∨ F(guard)` at its direct successors, which covers all times.

**Concretely**: Given `F(U(e,g)) @ (w, t) ∈ b` and `t' > t`:
- By propagation through `untlNeg`/`untlPos` auto-prop: `F(U(e,g)) @ (w, t') ∈ b`
- By `sat_untl_neg` at `t'`: for all `t'' ∈ futureOf(t')`: `F(event) @ (w, t'') ∨ F(guard) @ (w, t'') ∈ b`
- But `t'` itself must be covered — it is covered by `sat_untl_neg` applied at `t`'s predecessor in the chain from `t` to `t'`

Actually the cleanest approach: prove by induction on `fuel` that `isTimeOrderedBefore timeOrd t t' fuel = true` implies `⟨.neg, .untl event guard, ⟨w, t'⟩⟩ ∈ b`. Then for such `t'`, `sat_untl_neg` applied at `t'` shows `F(event) ∨ F(guard)` at all direct successors of `t'`. But we need `F(event) ∨ F(guard)` at `t'` itself (for the "no event witness" part) — this requires knowing `F(event) @ t'`, which comes from the branch at `t'` being a direct successor of some ancestor time.

### Finding 4: ALTERNATIVE APPROACH B — Change `branchTruth` for Until to Use Direct Edges

The root mismatch is that `branchTruth` uses `isTimeOrderedBefore` (transitive closure) while `sat_untl_neg` gives direct-edge properties. The cleanest fix is to **redefine `branchTruth` for `untl`/`snce` to use direct constraints** from the `timeOrdering.futureOf` instead of transitive closure.

The semantic content of `F(U(e,g)) @ (w, t)` in the Reynolds co-decomposition is:
- For EVERY chain from `t` to some future `t_e`, either `F(event) @ t_e` OR for some link `t_k → t_{k+1}` in that chain, `F(guard) @ t_{k+1}` (with `F(U(e,g)) @ t_{k+1}`)

This is more accurately captured by a direct-edge based semantics:
```
¬ ∃ t' with t <_direct t', branchTruth event at t' 
    ∧ ∀ t'' with t <_direct* t'' <_direct* t', branchTruth guard at t''
```
But this weakens the semantics: the `branchTruth` model would no longer correctly represent the original `Until` semantics (which does use transitive closure of time ordering).

**This approach risks soundness — not recommended without careful analysis.**

### Finding 5: ALTERNATIVE APPROACH C — Prove Propagation Lemma First (RECOMMENDED)

The cleanest path forward that does not require changing existing definitions:

**Step 1**: Prove the "F(U(e,g)) propagates to all future branch times" lemma:
```lean
theorem untlNeg_persists (b : Branch) (timeOrd : TimeOrdering)
    (hSat : findUnexpanded b = none)
    (event guard : Formula) (w : WorldIndex) (t : TimeIndex)
    (hmem : ⟨.neg, .untl event guard, ⟨w, t⟩⟩ ∈ b) :
    ∀ t' ∈ b.knownTimes, isTimeOrderedBefore timeOrd t t' →
      ⟨.neg, .untl event guard, ⟨w, t'⟩⟩ ∈ b
```

**Evidence**: In `applyRule .untlNeg` (Tableau.lean, lines 739–757), both branches re-include `sf` (the original `F(U(e,g)) @ (w, t)`). This means after `untlNeg` expansion at time `t`, the source formula is never removed. Furthermore, `applyRule .untlPos` at any future time includes `untlNegProps` (lines 679–682): formulas from `branch.untlNegFormulas` at the same time get propagated to fresh future times. These two facts together mean `F(U(e,g))` appears at every future branch time reachable from `t`.

**Step 2**: Use the propagation lemma to apply `sat_untl_neg` inductively:
- For any `t'` with `isTimeOrderedBefore t t'`, we have `⟨.neg, .untl e g, ⟨w, t'⟩⟩ ∈ b`
- By `sat_untl_neg` at `t'`: for all `t'' ∈ futureOf(t')`: `F(event) @ (w, t'') ∨ F(guard) @ (w, t'') ∈ b`
- Now `¬branchTruth cm w t (.untl event guard)` follows because: for any alleged witness `t_e` (time where `event` would hold), `isTimeOrderedBefore t t_e` means `t_e` is in the chain; the chain to `t_e` goes through some time `t'` with `isTimeOrderedBefore t t'` and `t_e ∈ futureOf(t')`. At `t'`, `sat_untl_neg` gives `F(event) @ t_e`, so by IH (on formulas smaller than `untl e g`), `¬branchTruth cm w t_e event`.

**Step 3**: For the "guard must hold at intermediate times" part: for each intermediate `t''` between `t` and `t_e`, we have `⟨.neg, .untl e g, ⟨w, t''⟩⟩ ∈ b` (by propagation). By `sat_untl_neg` at the predecessor of `t''`, we get `F(guard) @ t''`, so by IH `¬branchTruth cm w t'' guard`.

### Finding 6: `blocking_terminates` — Concrete Approach

The sorry in `blocking_terminates` (Saturation.lean, lines 654–663) needs:
1. Subformula property for expanded branches (not just initial branches)
2. Pigeonhole argument over time types

**Current state**: `subformula_property` (lines 635–644) only covers the initial branch. The generalized version is needed.

**Approach**: Define the subformula closure of a branch as `⋃_{sf ∈ b} Formula.subformulas sf.formula` and prove it is preserved by rule application. Then:
- Each "time type" `timeType b t` is a subset of `{(s, f) | s : Sign, f ∈ subformulaClosure}` 
- There are at most `2 * n` elements in the closure (where `n = |subformulaClosure|`), so at most `2^(2n)` distinct time types
- By pigeonhole: any branch with more than `2^(2n)` distinct time points has a blocked time
- Therefore `findBlockedTime b ord ≠ none` for large enough branches, guaranteeing termination

**Concrete fuel bound**: The current `soundFuel φ` definition (line 255) uses `n * 2^n` where `n = |subformulaClosure φ|`. This is reasonable but the proof needs:
```lean
-- Generalized subformula property
theorem subformula_prop_generalized (b b' : Branch) (sf : SignedFormula)
    (h_expand : b' ∈ someExpansionOf b)  -- b' is reachable from b by rule applications
    (h_mem : sf ∈ b') :
    sf.formula ∈ branchSubformulaClosure b
```

**Simplification**: Rather than proving the full generalized property, we can prove a weaker version: "after at most `soundFuel φ` steps from the initial branch `[F(φ)]`, either the expansion terminates or `findBlockedTime` fires". This sidesteps the need to track individual formula provenance and focuses on the pigeonhole argument over time types.

### Finding 7: The Mosaic Method (Caleiro et al. 2013) — Not Worth Pursuing for These Sorries

The Caleiro-Vigano-Volpe mosaic paper addresses a logic with G/H/∀ operators (not U/S), organized around 6-tuples of "mosaics" in a two-dimensional grid (temporal × modal). Translating this to the current Lean formalization would require:
- Replacing the tableau system with a mosaic-based one (architectural change)
- Defining points, coherence conditions, saturation conditions on the Lean types
- Re-proving all saturation invariants in the mosaic framework

This is a complete redesign, not a fix for 3 sorry sites. The paper is relevant for future completeness proofs (Theorem 3.13 gives satisfiability iff mosaic structure exists) but does not help with the immediate proof obligations.

### Finding 8: Libkin (Finite Model Theory) — Relevant to `blocking_terminates`

Libkin Chapter 3 (EF games, rank-k types) and Chapter 7 (MSO games) are relevant to `blocking_terminates`. The key insight from Section 3.4 is that "the number of distinct rank-k types is finite" (Theorem 3.15), which corresponds directly to "the number of distinct time types is finite" in our setting.

For `blocking_terminates`, the finite type argument from Libkin 3.4 directly applies:
- A "time type" in our setting is exactly a rank-0 MSO type (it's just the set of signed subformulas at that time)
- The finite number of distinct types bounds the number of distinct time points before a type must repeat
- Pigeonhole gives the bound

However, Libkin does not provide the specific Lean proof infrastructure — the connection must be made manually through the subformula property.

---

## Recommended Approach

### For `truthLemma_neg` untl/snce cases: Propagation Lemma First

**Recommended**: Implement "Approach C" (Finding 5):

1. Prove `untlNeg_persists`: `F(U(e,g)) @ (w,t) ∈ b` implies `F(U(e,g)) @ (w,t') ∈ b` for all `t'` in `knownTimes` with `isTimeOrderedBefore t t'`. This follows from the `untlNeg` rule being persistent (both branches re-include `sf`) and `untlPos` auto-propagating `untlNegFormulas` to fresh times.

2. Prove the truth lemma for `untl` by structural induction on the `isTimeOrderedBefore` fuel:
   - Base: fuel = 0 means `t' = t` (no successor), no witness exists
   - Step: `isTimeOrderedBefore t t' (fuel+1)` = either direct edge or through intermediate. By propagation, `F(U(e,g)) @ t'` is in branch. By `sat_untl_neg` at `t'`, all direct successors of `t'` have `F(event) ∨ F(guard)`. Apply IH.

3. The snce case is symmetric (past direction).

**Caution**: The proof requires checking that the "between" times predicate in `branchTruth` (`timesBetween`) is consistent with the `sat_untl_neg` output. `timesBetween` uses `isTimeOrderedBefore` transitively, while `sat_untl_neg` gives coverage at `futureOf` (direct edges). The inductive argument must track both simultaneously.

### For `blocking_terminates`: Separate Fuel-Bound Lemma

**Recommended**: Rather than proving the full termination theorem in one step, decompose into:

1. `branchSubformulaClosure_preserved`: Every formula in a branch derived from `[F(φ)]` is a subformula of `φ`. (Induction on rule applications, verified per rule.)

2. `timeType_bounded`: `(timeType b t).length ≤ 2 * n` where `n = |subformulaClosure φ|`.

3. `timeTypes_finite`: There are at most `4^n` distinct time types.

4. `blocking_fires_eventually`: For any branch derived from `[F(φ)]` with more than `4^n` distinct time points, `findBlockedTime b ord ≠ none`.

5. `blocking_terminates` follows from (4) plus the fuel bound.

Step (1) is the hardest and requires case analysis over all rules (about 25 cases). Steps (2–4) are finite combinatorics. Step (5) connects the finite type bound to `expandBranchWithFuel`.

**Alternative simpler bound**: Use `soundFuel φ = min (n * 2^n) 100000` as is, and prove that `expandBranchWithFuel b fuel` for `fuel ≥ soundFuel φ` always returns `some _`. This only requires showing that 100000 is large enough for any formula the system would practically encounter, which can be verified computationally for the test cases. But this is not a fully general proof.

---

## Evidence and Examples

### Evidence that `F(U(e,g))` propagates to future times

From `applyRule .untlNeg` (Tableau.lean lines 749–757):
```lean
| t' :: _ =>
  let branch1 := [SignedFormula.neg event targetLabel, sf]  -- sf re-included
  let branch2 := [SignedFormula.neg guard targetLabel,
                   SignedFormula.neg (.untl event guard) targetLabel, sf]  -- sf re-included
  (.branching [branch1, branch2], timeOrd)
```
Both branches include `sf` (the source `F(U(e,g)) @ (w,t)`), so the formula is never consumed.

From `applyRule .untlPos` (Tableau.lean lines 679–682):
```lean
let untlNegProps := branch.untlNegFormulas.filterMap fun usf =>
  if usf.label.time == l.time then
    let prop := SignedFormula.neg usf.formula { world := usf.label.world, time := freshTime }
    if branch.contains prop then none else some prop
  else none
```
When a new time `freshTime` is introduced by `untlPos`, all `F(U(...))` formulas at the same time are propagated to `freshTime`. This propagation means `F(U(e,g))` appears at every future time introduced for the same world.

### Evidence for the gap in current sorry

From CountermodelExtraction.lean lines 831–838:
```lean
| untl event guard ih_event ih_guard =>
  -- BLOCKED: sat_untl_neg gives F(event) ∨ F(guard) at each direct successor,
  -- but the Until semantics uses transitive closure (isTimeOrderedBefore). For direct
  -- successors where only F(guard) holds, we cannot negate branchTruth event.
  -- Requires F(U(event,guard)) propagation tracking or modified branchTruth semantics.
  simp only [branchTruth]
  sorry
```
The comment accurately identifies the gap. Our "Approach C" addresses it by proving `F(U(e,g))` is at `t'` for ALL reachable `t'`, so `sat_untl_neg` can be applied at `t'` directly.

---

## Confidence Level

**For `truthLemma_neg` untl/snce**:
- Approach C (propagation lemma) is **HIGH confidence** as a correct strategy
- The two auto-propagation mechanisms (`untlNeg` re-includes `sf`; `untlPos` propagates `untlNegFormulas`) are clearly visible in the rule application code
- The main proof effort is formalizing the propagation lemma, which requires carefully tracking `b.untlNegFormulas` and `ancestorTimes` relationships through rule applications
- Estimated complexity: 2–3 new auxiliary lemmas, medium difficulty each (similar to `sat_box_pos` complexity)

**For `blocking_terminates`**:
- The decomposed approach (steps 1–5 above) is **MEDIUM confidence** as a complete strategy
- Step 1 (generalized subformula property) requires case analysis over all 25+ rules — tedious but straightforward
- Steps 2–4 are finite combinatorics in Lean, manageable but may require Finset lemmas
- Step 5 requires connecting the pigeonhole bound to the fuel parameter in `expandBranchWithFuel` — may require careful induction
- Estimated complexity: 4–6 new lemmas, several at medium-to-high difficulty

**Mosaic method**: NOT recommended as an alternative approach for these 3 sorry sites. It requires architectural redesign.

---

## Appendix: Key File Locations

- `CountermodelExtraction.lean`: Sorry sites at lines 838 (untl) and 842 (snce). Saturation lemmas `sat_untl_neg`/`sat_snce_neg` at lines 619–725.
- `Tableau.lean`: `untlNeg` rule at lines 739–757. Auto-propagation of `untlNegFormulas` at lines 679–682. `snceNeg` rule at lines 760–783.
- `Saturation.lean`: `blocking_terminates` sorry at line 663. `findBlockedTime` at SignedFormula.lean line 710. `subformula_property` initial-branch version at lines 635–644.
- `SignedFormula.lean`: `timeType`, `isSubsetBlocked`, `findBlockedTime` at lines 606–711.
