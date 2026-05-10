# Research Report: IsSuccArchimedean via Lexicographic Well-Founded Induction

- **Task**: 119 - Prove IsSuccArchimedean via Direct Connectivity Extraction
- **Status**: Research complete
- **Type**: lean4
- **Date**: 2026-05-09
- **Session**: sess_1778390562_26b744
- **Artifacts**: reports/01_connectivity-proof-research.md (this file)
- **Prior Research**: Task 118 reports (16+ rounds), task 118 plan (plans/02_issucc-archimedean-proof.md)

## Executive Summary

This research identifies a **concrete, complete proof strategy** for `limitDomSubtype_isSuccArchimedean` that avoids the gap lemma entirely. The proof uses well-founded induction on a lexicographic pair `(domN_count, birth_stage)` combined with descent through `pred(b)`. The key enabling lemma is **birth-monotonicity** (`birth(succ(z)) > birth(z)`), which is proven by contradiction using the sealing property of `U(T, bot)` guards. A critical bug in task 118's plan (Phase 3 uses `birth(q) - birth(current)` as WF measure, but birth(current) can exceed birth(q)) is identified and resolved.

## Key Finding: Lexicographic Pair Induction

### The Measure

For `a <= b` in `LimitDomSubtype` with `a.val, b.val in dom_N`:

```
measure(b) = (domN_count(b), birth(b))
```

where:
- `domN_count(b) = |{q in domN | a.val < q AND q <= b.val}|` (Finset.card)
- `birth(b) = Nat.find b.property` (earliest omega chain stage containing b.val)
- Ordered lexicographically on `Nat x Nat` (well-founded by `WellFounded.prod_lex`)

### Why It Works

When descending from `b` to `pred(b)`:

**Case 1** (`b.val in domN`): Since `a < b`, `b.val` is in the filter `{q in domN | a.val < q AND q <= b.val}` but NOT in `{q in domN | a.val < q AND q <= pred(b).val}` (because `b.val > pred(b).val`). So `domN_count(pred(b)) < domN_count(b)`. First component strictly decreases.

**Case 2** (`b.val not in domN`): The domN count might not decrease. But `birth(pred(b)) < birth(b)` (from birth-monotonicity: `birth(succ(z)) > birth(z)` applied to `z = pred(b)`, giving `birth(succ(pred(b))) = birth(b) > birth(pred(b))`). Second component strictly decreases while first is non-increasing.

In both cases, the lex pair strictly decreases.

### Task 118 Plan Bug

The task 118 plan (Phase 3) proposes WF measure `birth(q) - birth(current)` for the gap lemma. This is INCORRECT:

- For `current in (p, q) cap limit_dom` with `p, q` consecutive in `domN`, we have `birth(current) > N >= birth(q)`.
- So `birth(q) - birth(current)` is NOT a well-defined natural number (would be negative).
- The lex-pair approach avoids this entirely by NOT requiring the gap lemma.

## Key Lemma: Birth-Monotonicity

### Statement

```lean
birth(succ(z)) > birth(z)
```

for any `z : LimitDomSubtype A h_mcs`.

### Proof (by contradiction)

Suppose `succ(z).val in dom_{birth(z)}`. Then:

1. Both `z.val` and `succ(z).val` are in `dom_{birth(z)}`.
2. No `dom_{birth(z)}` elements exist strictly between them (since `dom_{birth(z)} subset limit_dom`, and no limit_dom elements exist between `z` and `succ(z)` by the successor property).
3. So `z.val` and `succ(z).val` are adjacent in `dom_{birth(z)}`.
4. `z.val` was born at `birth(z)`, so `z.val not in dom_{birth(z)-1}` (if `birth(z) > 0`). By `dom_new_unique`, `z.val` is the unique new element at stage `birth(z)`. Therefore `succ(z).val in dom_{birth(z)-1}`.
5. At any stage `s >= birth(z)`, the C5 counterexample `(z.val, 0, bot, top, c5_forward)` for `U(T, bot)` at `z.val` is NOT resolved:
   - For any candidate witness `y in dom_s` with `z.val < y`: the guard requires `bot in f_s(w)` for all `w in dom_s` between `z.val` and `y`. But `succ(z).val in dom_s` (since `succ(z).val in dom_{birth(z)} subset dom_s`), and `bot not in f_s(succ(z).val)` (since f-values are MCS, which never contain bot).
6. When the counterexample is processed at some stage `s >= birth(z)`, since it is NOT resolved, the C5 walk runs. The walk finds the domain-successor of `z.val` in `dom_s`. No `dom_s` elements exist in `(z.val, succ(z).val)` (since `dom_s subset limit_dom`), so the domain-successor is `succ(z).val` or something beyond it.
7. Since condition (i) for `U(T, bot)` requires `bot in g_s(z.val, domain_succ)`, which is impossible (g-values are consistent), the walk takes the SPLIT case and inserts a midpoint in `(z.val, domain_succ)`.
8. This midpoint is in `(z.val, succ(z).val)` (or `(z.val, domain_succ)` if domain_succ > succ(z).val, but the midpoint is still > z.val). In either case, the midpoint enters `limit_dom` (since `dom_{s+1} subset limit_dom`).
9. If the midpoint is in `(z.val, succ(z).val)`: contradiction with no limit_dom between `z` and `succ(z)`.
10. If domain_succ > succ(z).val: then the midpoint = `(z.val + domain_succ) / 2`. Since `z.val < succ(z).val < domain_succ`, the midpoint = `(z.val + domain_succ) / 2 > z.val`. If this midpoint is <= succ(z).val: it's in `(z.val, succ(z).val]` which gives limit_dom in `(z.val, succ(z).val)` (contradiction) or equals `succ(z).val` (possible but `succ(z).val` is already in dom_s, and the midpoint is NEW, not in dom_s, contradiction). If the midpoint > succ(z).val: then it's a new limit_dom element above `succ(z).val`, which is fine but doesn't directly help.

Wait, step 10 has an issue. If `domain_succ > succ(z).val`, the midpoint might be above `succ(z).val` and not cause a contradiction.

Let me reconsider. The domain-successor of `z.val` in `dom_s` is the smallest element of `dom_s` strictly greater than `z.val`. Since `succ(z).val in dom_s` (by assumption), and no `dom_s` elements exist in `(z.val, succ(z).val)`, the domain-successor of `z.val` in `dom_s` is `succ(z).val`.

So the walk processes the adjacent pair `(z.val, succ(z).val)` in `dom_s`. Condition (i) requires `bot in g_s(z.val, succ(z).val)`, which is impossible. The split case inserts the midpoint `(z.val + succ(z).val) / 2` into the domain. This midpoint is strictly between `z.val` and `succ(z).val`, and it's in `dom_{s+1} subset limit_dom`. This contradicts the successor property (no limit_dom between `z` and `succ(z)`).

CONTRADICTION. So `succ(z).val not in dom_{birth(z)}`, i.e., `birth(succ(z)) > birth(z)`.

This argument is rigorous. The key steps are:
1. If `succ(z).val in dom_{birth(z)}`, then `succ(z).val` is the `dom_s`-successor of `z.val` (for any `s >= birth(z)`).
2. The C5 counterexample `U(T, bot)` at `z.val` is NOT resolved at stage `s`.
3. The C5 walk inserts a midpoint in `(z.val, succ(z).val)`.
4. This contradicts the successor property.

### Formalizing Birth-Monotonicity

The proof requires:
- `Nat.find` for birth stage definition
- `Nat.find_spec` for the key property
- `omega_chain_dom_mono_le` for dom_s containment
- `limit_dom_has_succ` structure for the successor property
- The argument that the C5 counterexample is not resolved (requires `bot_not_in_mcs`)
- The argument that the C5 walk inserts in `(z.val, succ(z).val)` (requires tracing through the C5 walk structure)

Step 5-9 of the contradiction proof requires extracting information from the omega chain construction, specifically:
- `counterexample_enum_surjective_above` to get a processing stage
- `omega_chain_c5_witness` to get the witness properties
- Showing the witness is in `(z.val, succ(z).val)` contradicts the successor property

**Estimated effort for birth-monotonicity lemma**: 50-80 lines of Lean.

**Alternative (simpler) approach**: Instead of fully tracing through the C5 walk, prove the CONTRAPOSITIVE: if `succ(z).val in dom_n` for some `n`, then `birth(succ(z)) <= n`. Then show `succ(z).val not in dom_{birth(z)}` by contradiction using the C5 sealing argument (which shows a new limit_dom element would be inserted between z and succ(z)).

## Complete Proof Structure

### File: ChronicleToCountermodel.lean

```lean
/-! ### Birth Stage Infrastructure -/

/-- Birth stage: earliest omega chain stage containing a point. -/
noncomputable def birth_stage (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (x : Rat) (hx : x ∈ limit_dom A h_mcs) : Nat :=
  @Nat.find (fun n => x ∈ (omega_chain_val A h_mcs n).dom)
    (fun n => Classical.dec _) hx

theorem birth_stage_spec ...
theorem birth_stage_min ...
theorem birth_stage_le ...

/-! ### Birth-Monotonicity -/

/-- Key lemma: birth(succ(z)) > birth(z) for any z in LimitDomSubtype. -/
theorem succ_birth_gt (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ...)
    (z : LimitDomSubtype A h_mcs) :
    birth_stage A h_mcs (Order.succ z).val (Order.succ z).property >
    birth_stage A h_mcs z.val z.property := by
  -- Proof by contradiction using C5 sealing

/-! ### IsSuccArchimedean via Lex Induction -/

noncomputable def limitDomSubtype_isSuccArchimedean ... := by
  constructor
  intro a b hab
  obtain ⟨na, hna⟩ := a.property
  obtain ⟨nb, hnb⟩ := b.property
  set N := max na nb
  -- ... existing setup ...

  -- Handle a = b
  rcases eq_or_lt_of_le hab with rfl | hab_lt
  · exact ⟨0, rfl⟩
  · -- Define measure components
    let domN := (omega_chain_val A h_mcs N).dom
    let birth := fun (z : LimitDomSubtype A h_mcs) =>
      birth_stage A h_mcs z.val z.property
    let domN_count := fun (z : LimitDomSubtype A h_mcs) =>
      (domN.filter (fun q => decide (a.val < q ∧ q ≤ z.val))).card
    let measure := fun (z : LimitDomSubtype A h_mcs) =>
      (domN_count z, birth z)

    -- Well-founded induction on lex pair
    suffices ∀ b' : LimitDomSubtype A h_mcs,
        a < b' → ∃ n, Order.succ^[n] a = b' by
      exact this b hab_lt

    intro b'
    -- Use WF recursion on measure(b')
    refine WellFounded.induction
      (WellFounded.prod_lex wellFounded_lt wellFounded_lt)
      (measure b') (fun p ih => ?_)
    -- ... show measure(pred(b')) < measure(b') ...
    -- ... apply IH to pred(b') or conclude succ(a) = b' if a = pred(b') ...
```

### Key Lemma Dependencies

```
birth_stage                    -- Nat.find on limit_dom membership
  ├── birth_stage_spec         -- x ∈ dom_{birth(x)}
  ├── birth_stage_min          -- x ∉ dom_m for m < birth(x)
  └── birth_stage_le           -- x ∈ dom_n → birth(x) ≤ n
succ_birth_gt                  -- birth(succ(z)) > birth(z)
  ├── birth_stage_spec
  ├── omega_chain_dom_mono_le
  ├── limit_dom_has_succ       -- (for successor property)
  ├── counterexample_enum_surjective_above
  ├── omega_chain_c5_witness   -- (or limit_satisfies_c5_strong)
  └── bot_not_in_mcs
limitDomSubtype_isSuccArchimedean
  ├── succ_birth_gt
  ├── limitDomSubtype_succ_pred     -- succ(pred(b)) = b
  ├── limitDomSubtype_pred_lt       -- pred(b) < b
  ├── limitDomSubtype_le_pred_of_lt -- a < b → a ≤ pred(b)
  ├── WellFounded.prod_lex
  └── Finset.card_lt_card          -- for domN_count decrease
```

## Verified Lean Infrastructure

The following have been verified to compile in the current codebase:

1. **Order.succ = limitDomSubtype_succ**: `Order.succ a = limitDomSubtype_succ A h_mcs h_discrete a` (by rfl)
2. **iterate composition**: `Function.iterate_add_apply Order.succ n2 n1 a` gives `succ^[n2 + n1] a = succ^[n2] (succ^[n1] a)`
3. **succ_le_iff**: `Order.succ_le_iff_of_not_isMax` works for showing `succ a ≤ b ↔ a < b` (when a is not max)
4. **pred < b**: `limitDomSubtype_pred_lt` gives `pred(b) < b` as subtype elements
5. **pred val < b val**: `pb.val < b.val` follows directly from `pb < b`
6. **birth via Nat.find**: `Nat.find` with `Classical.dec _` compiles correctly
7. **Finset filter**: `domN.filter (fun q => decide (a.val < q ∧ q ≤ b.val) = true)` type-checks
8. **base case**: Finset.card = 0 with `b.val ∈ filter` gives contradiction via `Finset.card_eq_zero`
9. **WF product**: `WellFounded.prod_lex wellFounded_lt wellFounded_lt` gives `WellFounded (Prod.Lex (· < ·) (· < ·))`

## Approach Comparison

| Approach | Status | Lines Est. | Key Difficulty |
|----------|--------|-----------|----------------|
| Task 118 plan (birth(q)-birth(current)) | INCORRECT | N/A | WF measure undefined when birth(current) > birth(q) |
| Gap lemma + domN induction | Correct but complex | 200-300 | Gap lemma requires separate proof |
| **Lex pair (domN_count, birth)** | **CORRECT, SIMPLE** | **120-180** | **Birth-monotonicity is the main lemma (50-80 lines)** |
| Dual-chain real analysis | Correct but very complex | 300+ | Requires formalizing convergence in R |
| WellFoundedGT | IMPOSSIBLE | N/A | LimitDomSubtype ~ Z, not WF |
| LocallyFiniteOrder | CIRCULAR | N/A | Equivalent to IsSuccArchimedean |

## Estimated Implementation Effort

| Component | Lines | Difficulty |
|-----------|-------|-----------|
| Birth stage infrastructure (def + 3 lemmas) | 20-30 | Low |
| Birth-monotonicity (succ_birth_gt) | 50-80 | Medium-High |
| Main theorem (lex WF induction) | 40-60 | Medium |
| Finset cardinality bookkeeping | 10-20 | Low |
| **Total** | **120-190** | **Medium** |

## Risks

1. **Birth-monotonicity formalization**: The contradiction argument requires extracting C5 walk behavior (always splits for U(T, bot), midpoint falls between z and succ(z)). This involves tracing through `counterexample_enum_surjective_above` and `omega_chain_c5_witness` to show the C5 is unresolved and the walk inserts in the sealed interval. The mathematical argument is solid but the Lean formalization may require 80+ lines due to the multi-step extraction.

2. **Nat.find issues**: `Nat.find` requires `DecidablePred`, which we provide via `Classical.dec`. This should work but might have definitional equality issues with `set` or `simp`.

3. **Finset card bookkeeping**: The lex measure decrease proof requires showing `domN_count(pred(b)) <= domN_count(b)` in all cases and strict decrease in Case 1. This is routine Finset manipulation but verbose.

## Confidence Assessment

| Finding | Confidence |
|---------|------------|
| Lex pair measure is correct and well-founded | **HIGH** |
| Birth-monotonicity is mathematically true | **HIGH** |
| Birth-monotonicity is formalizable in Lean | **MEDIUM-HIGH** (depends on C5 walk extraction complexity) |
| Task 118 plan Phase 3 is buggy | **HIGH** (birth(current) > birth(q) is demonstrated) |
| Total effort 120-190 lines | **MEDIUM** (could be 200+ if birth-monotonicity is harder than expected) |
| No gap lemma needed | **HIGH** (lex descent handles both inter-gap and intra-gap cases) |

## Recommendation

Proceed with implementation using the lex-pair approach. The implementation should be structured in 3 phases:

1. **Phase 1: Birth stage infrastructure** (~30 lines, low risk)
2. **Phase 2: Birth-monotonicity lemma** (~80 lines, medium risk)
3. **Phase 3: Main theorem** (~60 lines, low risk given Phase 2)

If Phase 2 proves difficult, a fallback approach: define `birth_succ_gt` as sorry and complete Phase 3 around it, then revisit Phase 2. The sorry would be localized to a single clear mathematical claim rather than the sprawling `limitDomSubtype_isSuccArchimedean`.
