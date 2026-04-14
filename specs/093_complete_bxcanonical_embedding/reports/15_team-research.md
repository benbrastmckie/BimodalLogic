# Research Report: Task #93 Round 15 — Team Synthesis

**Task**: 93 - Close BXCanonical embedding (6 sorry sites in RootScopedChain.lean)
**Date**: 2026-04-14
**Mode**: Team Research (4 teammates)
**Session**: sess_1776199559_f95298
**Focus**: Evaluate discharge_single_step + G(neg psi) impossibility approach; assess alternative chain constructions; identify the correct way forward

## Executive Summary

All 4 teammates converge on the same conclusion: the proposed "G(neg psi) impossibility" approach is **fatally flawed** — backward propagation of G-formulas from chain(n) to chain(0) does not hold for the forward chain. However, the investigation has crystallized the **precise obstruction** and the **exact lemma needed** to close forward_F.

### The Precise Obstruction

`rr_fwd_chain_F_propagate` (proved, RootScopedChain.lean:1071) reduces forward_F to: "F(psi) cannot persist forever in the chain without psi ever appearing." The `enriched_fwd_step` at psi's visit step gives only a disjunction: `psi in M' OR F(psi) in M'`. BX11 Case 3 can fire when another formula chi is BX11-earlier than psi, hijacking the direct witness slot. So `enriched_fwd_step_resolves_one` guarantees SOME formula is resolved at each step, but **not the scheduled target**.

### The Solution

Replace `enriched_fwd_step` with `ordered_discharge_step`: a step function that uses the BX11-earliest F-defect as the fold target. The key new theorem `target_stays_direct_in_fold` proves that when the target has the earliest BX11 witness, Cases 1 or 2 always fire (never Case 3), so the target is **guaranteed direct** (not F-wrapped). This is provable from `bx11_earlier_total` + the BX11 semantics: if psi_j's witness is at or before chi's witness, then F(psi_j and chi) or F(psi_j and F(chi)) hold — never F(F(psi_j) and chi).

### Alternative Approaches — All Rejected

| Alternative | Verdict | Reason |
|------------|---------|--------|
| G(neg psi) impossibility | **FATAL** | No backward G-propagation in forward chain |
| Dovetailing (Goldblatt) | Rejected | Same F-preservation problem; omega^2 adds complexity without solving it |
| Quasimodel-to-Int bridge | Rejected | sigma_le incompatible with g_content; finite chains can't form global FMCS |
| Zorn/Compactness | Rejected | forward_F is Sigma_1 (existential); not preserved by topological limits |
| Backward-first | Already implemented | `dd_chain` already uses rr_bwd_chain for t < 0; doesn't help |

## Part 1: Why G(neg psi) Impossibility Fails

### 1.1 The Fatal Gap (All 4 Teammates)

The argument claims: "G(neg psi) in chain(n) implies G(neg psi) in M_0 via backward propagation."

**This is false.** The forward chain has ONLY forward g_content propagation:
- `rr_fwd_chain_g_content_trans` (RootScopedChain.lean:689): g_content(chain(m)) subset chain(n) for m <= n
- There is NO reverse lemma and CANNOT be one — Lindenbaum extensions are irreversible

The backward chain (rr_bwd_chain) has backward g_content propagation (`bwd_chain_reverse_g`, CanonicalModel.lean:306), but this is the WRONG chain. The Approach 1 argument confuses forward and backward chain propagation directions.

### 1.2 Could the Argument Be Salvaged? (Teammate A)

Teammate A considered: even without backward propagation, could we show G(neg psi) never ENTERS any chain step?

G(neg psi) entering chain(n+1) requires either:
- G(neg psi) in g_content(chain(n)) — i.e., G(G(neg psi)) in chain(n)
- G(neg psi) added by the Lindenbaum extension

The Lindenbaum extension CAN freely add G(neg psi) if it's consistent with the seed `{target, compound} union g_content(M)`. Since F(psi) = neg G(neg psi) is NOT in the seed (unless G(F(psi)) in M, which isn't guaranteed), nothing prevents G(neg psi) from entering M' via the extension.

**Conclusion**: G(neg psi) impossibility cannot be proved. The argument is mathematically unsound.

## Part 2: The Actual State of the Code

### 2.1 What Is Already Proved (Confirmed by All Teammates)

| Theorem | File:Line | Status | What It Gives |
|---------|-----------|--------|---------------|
| `enriched_resolving_seed_consistent` | OrderedSeedConsistency.lean:70 | Proved | {psi, alpha} union g_content(M) consistent when F(psi and alpha) in M |
| `ordered_two_defect_seed_consistent` | OrderedSeedConsistency.lean | Proved | {psi_1, F(psi_2)} union g_content(M) consistent when F(psi_1 and F(psi_2)) in M |
| `temp_linearity_mcs` | OrderedSeedConsistency.lean | Proved | BX11 at MCS level (earliest witness) |
| `bx11_earlier_total` | RootScopedChain.lean:912 | Proved | BX11 ordering is total preorder |
| `enriched_fwd_fold_with_witness` | RootScopedChain.lean:280 | Proved | Tracks direct witness through BX11 fold |
| `enriched_fwd_step_resolves_one` | RootScopedChain.lean:622 | Proved | SOME formula directly resolved per step |
| `enriched_fwd_step_preserves` | RootScopedChain.lean:604 | Proved | F(psi) in M implies psi in M' OR F(psi) in M' |
| `rr_fwd_chain_F_propagate` | RootScopedChain.lean:1071 | Proved | **Reduces forward_F to "F(psi) can't persist forever"** |
| `no_new_f_defects` | OrderedSeedConsistency.lean:232 | Proved | F-obligation set is non-growing |
| `discharge_single_step` | RootScopedChain.lean:942 | Proved | Guaranteed target in M' (non-disjunctive) |
| `FF_imp_F` | RootScopedChain.lean:59 | Proved | F(F(psi)) -> F(psi) in BX |
| `F_mono`, `F_conj_comm_mcs` | RootScopedChain.lean | Proved | F-formula algebra |

### 2.2 The 6 Sorry Sites

| # | Line | Theorem | Dependency |
|---|------|---------|------------|
| 1 | 1139 | `rr_fwd_chain_forward_F` | **PRIMARY BLOCKER** |
| 2 | 1170 | `dd_fmcs_forward_F` (t<0) | Depends on #1 |
| 3 | 1177 | `dd_fmcs_backward_P` | Symmetric to #1 |
| 4 | 1230 | `dd_bfmcs_restricted_tc` | Depends on #1 + #3 |
| 5 | 1235 | `dd_bfmcs_restricted_buc` | **Independent high-risk** |
| 6 | 1240 | `dd_bfmcs_restricted_fuc` | Depends on #1 |

## Part 3: The Solution — Ordered Discharge Step

### 3.1 Core Insight (Unanimous Consensus)

The current `enriched_fwd_step` uses a BX11 fold that allows Case 3 (F-wrapping the target). This produces a DISJUNCTION for the target, making forward_F unprovable.

The fix: define `ordered_discharge_step` that:
1. Finds the BX11-earliest F-defect psi_j using `bx11_earlier_total`
2. Runs the BX11 fold with psi_j as the initial target
3. Proves BX11 Case 3 never fires for psi_j (because psi_j has the EARLIEST witness)
4. Gets `F(psi_j and compound) in M` where psi_j is guaranteed DIRECT in compound
5. Extends `{psi_j, compound} union g_content(M)` via Lindenbaum (consistent by `enriched_resolving_seed_consistent`)
6. Result: M' with psi_j in M' (**guaranteed, not disjunctive**) and g_content(M) subset M'

### 3.2 The Key New Lemma (Teammates A, B, D Agree)

```
theorem target_stays_direct_in_fold
    {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (psi_j : Formula) (others : List Formula)
    (h_F_target : F(psi_j) in M)
    (h_earliest : forall chi in others, F(chi) in M -> bx11_earlier M psi_j chi) :
    -- The fold produces a compound where psi_j is direct (conjunct, not F-wrapped)
    exists compound, F(psi_j and compound) in M ...
```

**Why this is provable**: At each fold step, BX11 between `F(psi_j and accumulated)` and `F(chi)` gives three cases:
- Case 1: `F(psi_j and accumulated and chi)` — both direct, target stays direct
- Case 2: `F(psi_j and accumulated and F(chi))` — target direct, chi F-wrapped
- Case 3: `F(F(psi_j and accumulated) and chi)` — target F-wrapped, chi direct

Case 3 fires when chi's witness is EARLIER than psi_j's. But `h_earliest` says psi_j's witness is at or before chi's. Semantically, this rules out Case 3. Formally, `bx11_earlier M psi_j chi` means the MCS M contains the BX11 disjunct where psi_j is direct (Cases 1 or 2), not the one where psi_j is F-wrapped (Case 3).

**Estimated LOC**: ~50-80 lines, building on `enriched_fwd_fold_with_witness`.

### 3.3 Forward_F Proof Structure

With `ordered_discharge_step`:

1. Define new chain using `ordered_discharge_step` (resolve earliest F-defect at each step)
2. Run for exactly `sigma_list.length` steps (fixed-length, `Nat.rec`)
3. After `|sigma_list|` steps: terminal is defect-free (by pigeonhole — each formula targeted at most once, F-defect count strictly decreases by 1 per step, bounded by `|sigma_list|`)
4. Identity tail: chain(t) = terminal for t > N

Forward_F proof:
- F(psi) in chain(n). psi is an F-defect.
- By BX11 ordering, psi eventually becomes the earliest-witness defect at some step m >= n
- At step m: psi is the target, `ordered_discharge_step` guarantees psi in chain(m+1)
- For n >= N (identity tail): terminal is defect-free, so F(psi) in terminal implies psi in terminal

## Part 4: Conflicts Resolved

### 4.1 Alternative Approaches (Teammate A vs Teammate B)

**Teammate A**: Recommended Approach 2 (dovetailing) or Approach 3 (quasimodel bridge) after concluding Approach 1 fails.

**Teammate B**: Systematically rejected ALL 4 alternatives including dovetailing and quasimodel bridge. Converged on ordered defect-discharge chain.

**Resolution**: Teammate B's analysis is more thorough. Dovetailing doesn't solve the F-preservation problem (same disjunction issue at resolving steps). Quasimodel bridge is architecturally incompatible (sigma_le vs g_content, finite vs infinite chains). The ordered defect-discharge chain with `target_stays_direct_in_fold` is the ONLY viable path.

### 4.2 Backward Until Coherence Risk Level (All Teammates)

**Teammate C**: `restricted_buc` is completely unaddressed; the G(neg psi) argument says nothing about it.

**Teammate D**: `restricted_buc` at 45% confidence; recommends spawning task 96 as fallback.

**Teammate A/B**: Did not address Until coherence directly.

**Resolution**: `restricted_buc` (sorry #5) is an **independent obstacle** from forward_F. It requires a separate proof strategy (seed enrichment with Until formulas, or backward chain construction). Phases 1-3 of the plan should be executed first to close sorries #1-4 and #6. If `restricted_buc` remains blocked, spawn task 96. Closing 5 of 6 sorries is a substantial and publishable result.

## Part 5: What Has Changed Since Round 14

### 5.1 Confirmed Findings
- The ordered defect-discharge chain approach is still correct (Round 14 consensus holds)
- `enriched_resolving_seed_consistent` is the mathematical heart of the solution
- BX11 ordering provides the correct defect resolution order
- No simpler alternative exists

### 5.2 New Insights from Round 15
1. **G(neg psi) impossibility is definitively dead** — no backward G-propagation in forward chain
2. **The precise obstruction is identified**: `enriched_fwd_step_resolves_one` gives SOME witness, not the target; BX11 Case 3 can hijack the target's direct slot
3. **The exact fix is specified**: `target_stays_direct_in_fold` + `ordered_discharge_step` replacing `enriched_fwd_step`
4. **The t < 0 case** (sorry #2) should be deferred until sorry #1 is closed; the positive chain solution will likely inform it
5. **Until coherence (sorry #5) is independent** and should not block implementation of Phases 1-3
6. **Literature alignment is strong** — Burgess/Xu/Goldblatt all use the same BX11 ordering approach; this is the first Lean 4 formalization

## Part 6: Recommended Implementation Strategy

### Phase 1: Close forward_F (~8 hours, HIGH confidence 90%)
1. Prove `target_stays_direct_in_fold` (~50-80 LOC)
2. Define `ordered_discharge_step` using the fold with earliest-witness target
3. Define new forward chain using `ordered_discharge_step` with `Nat.rec` for `|sigma_list|` steps
4. Prove defect-free terminal (pigeonhole + `no_new_f_defects`)
5. Prove `rr_fwd_chain_forward_F` for the new chain
6. Close `dd_fmcs_forward_F` (t >= 0 case)

### Phase 2: Close backward_P and restricted_tc (~4 hours, HIGH confidence 85%)
7. Prove backward_P by symmetric argument (h_content, P-defects, BX11')
8. Close `dd_fmcs_backward_P`
9. Close `dd_bfmcs_restricted_tc` (follows from forward_F + backward_P)

### Phase 3: Close restricted_fuc (~4 hours, MEDIUM-HIGH confidence 75%)
10. Prove forward Until coherence via forward_F + BX9 + BX10

### Phase 4: Close restricted_buc (~8 hours, MEDIUM confidence 45%)
11. Attempt Path C: extend seed consistency to include Until formulas
12. Fallback: spawn task 96

### Phase 5: Close dd_fmcs_forward_F t<0 case (~2 hours, MEDIUM confidence 60%)
13. Bridge backward chain F(psi) to M_0 using chain connectivity axioms

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Primary approach | completed | HIGH | Definitive refutation of G(neg psi) impossibility; identified precise BX11 Case 3 obstruction; confirmed `rr_fwd_chain_F_propagate` reduces forward_F to "F(psi) can't persist forever" |
| B | Alternatives | completed | HIGH | Systematically rejected all 4 alternatives; confirmed Sigma_1 nature of forward_F defeats compactness; identified `target_stays_direct_in_fold` as the key ~50 LOC theorem |
| C | Critic | completed | HIGH | Found 6 critical gaps in proposed approach; validated existing proved lemmas against code; identified that `restricted_buc` and `restricted_fuc` are completely unaddressed |
| D | Horizons | completed | HIGH | Literature alignment confirmed (Burgess/Xu/Goldblatt); no existing Lean 4 BX completeness formalization; recommended Nat.rec termination; identified fallback strategy for restricted_buc |

## References

- Burgess (1982/1984) "Axioms for Tense Logic: Since and Until" — original BX completeness
- Xu (1988) "On some U, S-tense logics" — simplified axiomatization
- Goldblatt (1992) "Logics of Time and Computation" — standard textbook
- Verbrugge, de Jongh, Veltman (2004) "Completeness by Construction" — Amsterdam constructive method
- Venema (1993) "Temporal Logic" survey — comprehensive treatment
- [SEP: Burgess-Xu Axiomatic System](https://seop.illc.uva.nl/entries/logic-temporal/burgess-xu.html)
- Report 13: `specs/093_complete_bxcanonical_embedding/reports/13_long-term-solution.md`
- Report 14: `specs/093_complete_bxcanonical_embedding/reports/14_team-research.md`
- Plan v14: `specs/093_complete_bxcanonical_embedding/plans/14_bxcanonical-embedding.md`
- Implementation summary v14: `specs/093_complete_bxcanonical_embedding/summaries/14_implementation-summary.md`
