# Fuel Approach Analysis: Task 67

## Summary

Ten implementation plans have been attempted for `bundle_validity_implies_provability`. Plans 1-7 focused on higher-level architecture (restricted truth lemma, coherence transfer, Z-chain wiring). The fuel-based termination issue first emerged explicitly in Plan 5 (Phase 6 blocked on "fuel exhaustion") and became the central blocking issue from Plan 6 onward. Plans 8-10 represent three distinct attempts to resolve the fuel sorries: dovetailing (blocked on F-persistence), wiring restricted chain (blocked on backward chain sorries first), and well-founded restructure (blocked on depth-increase under resolve). All approaches have failed, and the core problem is now well-characterized.

---

## Approaches Attempted

### Plan 1: Restricted BFMCS Construction
- **Approach**: Build `RestrictedBFMCS` structure wrapping restricted chain families; prove `restricted_bfmcs_temporally_coherent`; wire to completeness via restricted truth lemma.
- **Failure reason**: Phase 1 blocked - the `RestrictedTemporallyCoherentFamily` construction was identified as the correct path but the F/P witness lemmas in SuccChainFMCS had termination sorries using `decreasing_by sorry`. These were treated as low-risk/separate initially.
- **Could it work with modifications?**: The overall architecture is correct, but it depends on the fuel-exhaustion sorries being eliminated first.

### Plan 2: Restricted Coherence Path
- **Approach**: Same restricted coherence approach but with clearer phasing. Phase 4 explicitly planned to fill fuel-exhaustion sorries in `restricted_bounded_witness` using well-founded measure on F-nesting.
- **Failure reason**: Research showed these sorries were more complex than anticipated. The plan still referred to `decreasing_by sorry` sorries as cleanable but did not attempt them.
- **Could it work with modifications?**: Same dependency on fuel sorries.

### Plan 3: Termination-First Restricted Truth Lemma
- **Approach**: Explicitly prioritized filling the `decreasing_by sorry` blocks first. Analyzed that functions use `induction d generalizing k` but recursive calls pass `d' + n` or `d' + (n-1)` where `d' >= 1`, so depth does not strictly decrease.
- **Failure reason**: Handoff document (`01_termination-analysis.md`) shows the core issue was identified: when `d' = 1`, new depth equals old depth, so no lexicographic decrease is achievable with the current structure. Recommended switching to fuel-based approach (Option A).
- **Could it work with modifications?**: This plan identified the root cause and correctly pivoted to fuel. Phases 1-3 were completed; Phase 4 was partial.

### Plan 4: Bypass Z-Chain via Restricted TC Family
- **Approach**: Abandon Z-chain; use `RestrictedTemporallyCoherentFamily` directly. Blocked immediately in Phase 1 because `F_top = F(neg bot)` is NOT in `deferralClosure(phi)` for general `phi`.
- **Failure reason**: `some_future_in_deferralClosure_is_in_closureWithNeg` proved that any F-formula in `deferralClosure` must be in `closureWithNeg`, and `F_top` is not a subformula of general `phi`. This makes `DeferralRestrictedSerialMCS` construction impossible for general `phi`.
- **Could it work with modifications?**: No, not without extending the closure definition (Plan 5's approach).

### Plan 5: Extend deferralClosure with Seriality Formulas
- **Approach**: Add `{F_top, P_top, neg bot}` to `deferralClosure` by definition. Phases 1-5 completed (extended closure, updated 16+ call sites, proved `build_restricted_serial_mcs_from_neg_consistent`). Phase 6 blocked.
- **Failure reason**: Phase 6 blocked on "fuel exhaustion" in `restricted_bounded_witness_fueled`. The fuel=0 base case has a sorry that is semantically unreachable (B*B+1 initial fuel always suffices) but cannot be proved without significant restructuring.
- **Could it work with modifications?**: The infrastructure from this plan is the foundation for all later plans. The architecture is correct but blocked on fuel sorries.

### Plan 6: Well-Founded Recursion with Fair Scheduling Backup
- **Approach (Primary)**: Replace fuel-based recursion with `termination_by (closure_F_bound phi * closure_F_bound phi - k, d)`. Phase 1 completed (analysis). Phase 2 blocked.
- **Failure reason**: Three approaches failed:
  1. `h_fuel_pos` hypothesis: recursive call with `fuel' = 0` makes invariant unprovable
  2. Strong induction on `d`: new depth `d' + (n-1)` can equal old depth `n+1`
  3. Lexicographic measure `(B*B - k, B - d)`: `k`'s upper bound is what we're proving (circular)
  The fundamental issue: termination argument is **semantic** (fuel suffices globally) not **syntactic** (measure decreases locally).
- **Backup (Dovetailing)**: Identified as Plan 8.
- **Could it work with modifications?**: The well-founded approach is the cleanest but requires tracking "levels resolved" rather than current depth, which requires significant restructuring.

### Plan 7: Wire Restricted Chain to Z-chain
- **Approach**: Prove transfer-back lemma (`psi ∈ deferralClosure → psi ∈ extendToMCS → psi ∈ M.world`) and define `restricted_Z_chain`. Research identified that backward chain had sorries at lines 3944 and 4001.
- **Failure reason**: Required first fixing the backward chain sorries (Phases 1-2 of Plan 9 fixed these), then the fuel sorries.
- **Could it work with modifications?**: After fixing fuel sorries, this architecture may still be viable. The transfer-back argument is mathematically sound.

### Plan 8: Dovetailed OmegaFMCS Construction (Segerberg's Bulldozing)
- **Approach**: Replace `omega_chain_forward` with `omega_chain_true_dovetailed_forward` that resolves ALL F-obligations round-robin using `Nat.unpair`. Added `Infinite Formula` and `Denumerable Formula` instances to use `Denumerable.ofNat` for formula enumeration. Phases 1-2 completed.
- **Failure reason (Phase 3 blocked)**: The fairness lemma `obligation_eventually_resolved` cannot be proven because **F-formula persistence is not guaranteed**. The witness construction `temporal_theory_witness_exists` extends `{phi} ∪ G_theory(M) ∪ box_theory(M)` without preserving F-formulas. Specifically, if `F(psi) ∈ M` with `psi ≠ target`, then `G(neg(psi))` might be added during Lindenbaum extension, making `F(psi) ∉ W`. F-obligations can be "lost" during chain extension.
- **Could it work with modifications?**: Would require modifying witness construction to preserve all F-formulas in seed, but this creates circular dependencies (preserving F(psi) requires already having psi's witness).

### Plan 9: Fix Backward Chain (v9)
- **Approach**: Fix two sorry sites in backward chain construction (`constrained_predecessor_restricted_g_persistence_reverse` at line 3944 and `constrained_predecessor_restricted_f_step_forward` at line 4001), then address fuel-exhaustion sorries.
- **Phases 1-2 COMPLETED**: Both backward chain sorries were proven using `f_step_blocking_alt_restricted`.
- **Phase 3 BLOCKED**: The four fuel-exhaustion sorries (lines 2913, 5527, 5683, 5879). Analysis confirmed these are all in `fuel=0` base cases and are semantically unreachable with initial fuel `B*B+1`.
- **Could it work with modifications?**: Phases 1-2 are done. Only the fuel sorries remain.

### Plan 10: Well-Founded Restructure (v10, current)
- **Approach**: Replace all four fueled lemmas with well-founded recursion using measure `(B*B - k, d)`. Two-fuel approach (resolve_fuel, defer_fuel) was attempted.
- **Failure reason**: The fundamental challenge is **depth can increase on resolve**:
  - Old depth: `d = n + 1`
  - After resolving to `k+1`, get new boundary `d'` for inner formula
  - New tracking depth: `d' + (n - 1)`
  - For decrease: need `d' + (n-1) < n+1`, i.e., `d' < 2`
  - But `d' >= 1` and can be up to `B-1` (up to `closure_F_bound phi - 1`)
  The termination argument requires tracking "levels resolved" (F's peeled off), not current depth.
- **Could it work with modifications?**: Yes, but requires restructuring to use nested induction: outer on `levels_remaining` (F's to peel), inner on `defers_at_current_level` (bounded by B). Each resolve decreases outer, resets inner; each defer decreases inner.

---

## Pattern Analysis

**Common themes across all 10 plans**:

1. **Architecture is correct, infrastructure is blocked**: Every plan from Plan 2 onward correctly identifies the restricted coherence path as the right mathematical approach. The obstacle is consistently in the termination argument for witness lemmas, not in the high-level proof strategy.

2. **Fuel approaches all fail at the same point**: When fuel is used for termination, the `fuel=0` base case cannot be proved because the semantic argument (sufficient fuel is always provided) cannot be expressed syntactically without threading an invariant.

3. **The depth-increase problem is fundamental**: The resolve step in `restricted_bounded_witness_fueled` replaces `iter_F(n+1, theta)` with `iter_F(n, resolved_formula)` where the new formula has its own depth `d'`. The total depth `d' + (n-1)` can be equal to or larger than the original `n+1`. This breaks every simple measure.

4. **Two successful paths identified but not implemented**:
   - **Nested strong induction**: Outer induction on "levels remaining" (total F-depth to peel), inner on "defers at current level" (bounded by B).
   - **Fuel-sufficient invariant**: Thread `h_fuel_ge : fuel ≥ work_remaining` where `work_remaining = levels_remaining * B + defers_at_level`. Requires proving the invariant is maintained at each recursive call.

5. **F-persistence blocks dovetailing**: The dovetailing approach (Plan 8) failed because F-obligations can disappear from the chain during Lindenbaum extension. This is a separate fundamental blocker for the Z-chain approach.

---

## Recommendation

**Fuel approaches should be abandoned** in their current form. The `fuel=0` sorry cannot be eliminated without restructuring the recursion itself.

**Two viable untried variations remain**:

### Option A: Nested Strong Induction (Recommended)
Replace fuel-based recursion with a double induction:
- Outer: induction on `levels_remaining = f_nesting_depth(theta)` (total F-wrappers to peel from theta to reach the base formula)
- Inner: induction on `defers_at_level` (how many times we defer at the current nesting level, bounded by `closure_F_bound phi`)

When we **resolve** at level `n+1`, we reduce to level `n` (outer decreases). When we **defer** at level `n`, we advance the chain position (inner decreases, bounded by B). This is a proper lexicographic induction that Lean's termination checker should accept.

**Key insight**: Instead of `d = f_nesting_depth(iter_F(depth, theta))` as the measure (which can increase after resolve), use `levels_remaining = f_nesting_depth(theta)` which is a fixed property of the target formula.

### Option B: External Unreachability Lemma (Lower Risk)
Prove a single external lemma:
```lean
lemma restricted_bounded_witness_fuel_sufficient (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k theta_init : Formula)
    (d : Nat) (fuel : Nat)
    (h_fuel_init : fuel = closure_F_bound phi * closure_F_bound phi + 1)
    (h_d_lt : d < closure_F_bound phi) : fuel > 0
```
This can be proved by showing `B*B+1 > 0` trivially. But the deeper invariant needed is:
```lean
fuel ≥ (closure_F_bound phi - levels_resolved) * closure_F_bound phi + defers_at_current_level
```
This requires instrumenting the recursive calls with invariant proofs, which is approximately the same complexity as Option A.

**Option A is cleaner** because it eliminates the fuel parameter entirely rather than patching it.

---

## Confidence Level

**High** - The pattern of failures is completely consistent across 10 plans spanning multiple research and implementation sessions. The root cause (depth-increase under resolve; no simple decreasing measure) is precisely documented in the v10 summary and Plan 6 Phase 2 analysis. The two remaining options (nested induction, fuel-invariant) are identified by the research but not yet attempted.

The key technical claim to verify before implementing Option A: **`f_nesting_depth(theta)` is strictly less than `f_nesting_depth(iter_F(n+1, theta))`** for `n >= 0`. If this holds (which it should since `iter_F` wraps additional F's), then outer induction on `f_nesting_depth(theta)` works.
