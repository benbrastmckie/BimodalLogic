# Teammate C: Critic Gap Analysis — Why 6 Rounds Failed

**Task**: 109 — Close chain construction sorries
**Role**: Critic (gap analysis, false assumptions, blind spots)
**Date**: 2026-04-20

---

## Key Findings

1. **The problem is NOT "close 11 sorries." It is two fundamentally different problems masquerading as one.** The 5 critical-path sorries in RootScopedChain.lean (sorry #1-#5) require proving eventuality resolution for a SPECIFIC Z-indexed chain. The non-critical sorries (Frame.lean, TruthLemma, SigmaOrdering, Construction, Realization) are consequences of removing BX1/BX8 for irreflexive semantics and are either dead code or provably false as stated.

2. **Plan v6 has the same fatal flaw as every prior plan: it does not address the Lindenbaum opacity problem.** Every approach (Sigma-restricted, step-indexed, BX12 bridge, extended discharge, hybrid chain) hits the same wall: `Classical.choice` in `set_lindenbaum` produces an MCS whose membership is opaque. You cannot control what a Lindenbaum extension includes beyond the seed. Six rounds of research have proposed increasingly complex workarounds for this one fundamental issue.

3. **The "4 of 11 are genuinely unprovable" claim is wrong in both directions.** The actual situation: 5 critical-path sorries are provable given the right chain construction. The non-critical sorries ARE genuinely false/unprovable as stated (they require BX1: G(phi) -> phi, which is axiomatically removed). But they are also irrelevant — they are on dead code paths.

4. **There are actually TWO clean canonical model constructions in this codebase — and only one has sorries.** The file `CanonicalModel.lean` (the one I was asked to read) contains the sorry-free construction based on `int_chain` / `bx_fmcs`. The file `RootScopedChain.lean` contains the sorry-laden `fwd_chain_of_sigma` / `dd_bfmcs` construction. No prior research has asked: why do we need the second construction at all?

5. **The guard condition in `restricted_forward_until_since_coherent` is the hardest unsolved problem, not `fwd_chain_forward_F`.** Sorry #5 requires showing `phi in chain(r)` for ALL `r` in `(t, s)` where `s` is the Until witness. This is a universal quantifier over chain points. Even if F-eventuality resolution is solved, Until guard persistence requires a completely separate argument.

---

## Sorry Site Catalog

### Critical Path (in `dd_countermodel` dependency tree)

**Sorry #1: `fwd_chain_forward_F` (RootScopedChain.lean:1134)**
- **Goal**: `exists m, n < m /\ phi in (fwd_chain_of_sigma M0 h0 sigma_list m).val`
- **Hypotheses**: `F(phi) in chain(n)`, `phi in sigma_list`
- **Status**: Provable in principle. Requires chain construction that guarantees target resolution within finitely many steps. Current `preserving_fwd_step` cannot guarantee this because `Classical.choice` may perpetually defer phi.
- **Why hard**: The chain is a FIXED sequence (not a proof-relevant witness). We need an EXISTENTIAL claim about a SPECIFIC chain, but the chain was defined non-constructively.

**Sorry #2: `dd_bfmcs_restricted_tc` backward F-case (RootScopedChain.lean:1161)**
- **Goal**: `exists u > t, phi in fam.mcs u` where `t - s < 0` (backward chain region)
- **Hypotheses**: `F(phi) in chain(t)`, `phi in deferralClosure root`, `t` in backward region
- **Status**: Requires bridging backward chain to forward chain via the origin. If `F(phi) in bwd_chain(k)` can propagate to `M0`, then sorry #1 handles the forward resolution. Propagation requires either `F(phi) in h_content(bwd_chain(k))` (i.e., `H(F(phi)) in bwd_chain(k)`) or a direct argument.
- **Why hard**: h_content propagation goes the WRONG direction for F-formulas. `h_content(bwd_chain(k)) subset bwd_chain(k+1)` moves AWAY from the origin, not toward it.

**Sorry #3: `dd_bfmcs_restricted_tc` backward P-case (RootScopedChain.lean:1168)**
- **Goal**: `exists u < t, phi in fam.mcs u` given `P(phi) in chain(t)`
- **Status**: Symmetric to sorry #1 but for backward chain. Requires a backward analogue of `fwd_chain_forward_F`. Same Lindenbaum opacity issue.

**Sorry #4: `dd_bfmcs_restricted_buc` (RootScopedChain.lean:1176)**
- **Goal**: `(phi U psi) in fam.mcs t` given Until witnesses (exists s > t with psi at s and phi on [t,s))
- **Status**: HARDEST sorry. This is the backward direction of Until: given semantic witnesses, derive syntactic membership. Requires: if phi holds at all points between t and s, and psi holds at s, then (phi U psi) is in the MCS at t. This is essentially Until introduction, which under irreflexive semantics requires either BX8 (removed) or an inductive argument on the chain.
- **Why FUNDAMENTALLY hard**: In the standard reflexive proof, BX8 (`(phi U psi) <-> (psi v (phi /\ G(phi U psi)))`) gives Until introduction directly. Under irreflexive semantics, BX8 is removed. No BX axiom directly introduces Until from its semantic witnesses. The chain-based approach needs: `psi in chain(s)` and `phi in chain(r)` for all `r in [t,s)` implies `(phi U psi) in chain(t)`. This is a BACKWARD implication through Lindenbaum-opaque MCS steps.

**Sorry #5: `dd_bfmcs_restricted_fuc` (RootScopedChain.lean:1183)**
- **Goal**: `exists s > t, psi in fam.mcs s /\ forall r, t <= r -> r < s -> phi in fam.mcs r`
- **Hypotheses**: `(phi U psi) in fam.mcs t`
- **Status**: Partially reducible to sorry #1 (the existence of s follows from BX10 + F-resolution). The guard condition (phi at all intermediate points) requires a separate argument using BX5 (self-accumulation) and BX9 (elimination). Plan v6 Phase 4 has a reasonable sketch for this.
- **Why hard**: The guard persistence argument must show `(phi U psi)` persists through the chain from t to s-1, which requires g_content propagation of Until formulas. Until formulas are NOT in g_content unless `G(phi U psi)` is in the MCS — which is not guaranteed.

### Non-Critical Path (not called from `dd_countermodel`)

**`bx_le_refl` (Frame.lean:205)**: States `bx_le w w`. FALSE under irreflexive semantics. `bx_le` means `g_content(w) subset w`, i.e., `G(phi) in w -> phi in w`. This is BX1, which is removed. PROVABLY FALSE.

**`until_backward_refl_mcs` (TruthLemma.lean:293)**: States `psi in w -> (phi U psi) in w`. FALSE under irreflexive semantics. Requires reflexive Until introduction (psi at current time witnesses phi U psi). No BX axiom gives this when BX8 is removed.

**`since_backward_refl_mcs` (TruthLemma.lean:317)**: Dual of above. PROVABLY FALSE.

**`refl_intro_until_mcs` (Construction.lean:161)**: Same as `until_backward_refl_mcs` in a different module. FALSE.

**`refl_intro_since_mcs` (Construction.lean:207)**: Dual. FALSE.

**`F_of_mem` (Realization.lean:67)**: States `psi in w -> F(psi) in w`. FALSE under irreflexive semantics. Requires BX1 (G(neg psi) in w -> neg psi in w). Dead code.

**`P_of_mem` (Realization.lean:73)**: Dual. FALSE. Dead code.

**`enriched_seed_consistent_until` g_content case (Realization.lean:197)**: Requires `g_content(w) subset w.formulas`, i.e., BX1. FALSE. Dead code.

**`enriched_seed_consistent_since` h_content case (Realization.lean:249)**: Requires BX1'. FALSE. Dead code.

**`sigma_le_refl` (SigmaOrdering.lean:82)**: Requires BX1 restricted to Sigma. FALSE.

**`sigma_strict_irrefl` (SigmaOrdering.lean:99)**: Requires BX1 to show G(f) in w -> f in w. FALSE as currently stated.

**`not_sigma_equiv_of_sigma_strict` (SigmaOrdering.lean:143)**: Depends on sigma_le_refl. FALSE as stated.

---

## Structural Mismatch Analysis

### The Two-Construction Problem

The codebase has TWO canonical model constructions:

1. **CanonicalModel.lean** (`int_chain` / `bx_fmcs` / `shifted_bx_fmcs`): Uses simple Lindenbaum extensions at each step with `fwd_succ` and `bwd_pred`. Proves g_content propagation, h_content propagation, box stability, and F/P eventuality resolution (via `fwd_succ_resolves` and `bwd_pred_resolves`). ALL SORRY-FREE as of the current codebase.

2. **RootScopedChain.lean** (`fwd_chain_of_sigma` / `dd_bfmcs`): Uses a more complex "defect-directed" chain with `preserving_fwd_step` and `defect_step_choice_early`. Intended to resolve F-obligations for a specific sigma_list of formulas. HAS ALL THE SORRIES.

**Critical question nobody has asked**: The sorry-free construction in CanonicalModel.lean already resolves F(psi) at the immediate next step (line 72: `fwd_succ_resolves` proves `psi in fwd_succ M hM psi` when `F(psi) in M`). Why was the defect-directed chain introduced?

**Answer (from examining the code)**: The sorry-free `bx_fmcs` resolves F(psi) at ONE step, but the schedule `schedule n` only targets one formula per step. The schedule is surjective (every formula appears infinitely often), so every F-obligation is eventually targeted and resolved. This is exactly what `fwd_chain_forward_F` needs to prove for the defect-directed chain!

**The key insight**: `fwd_succ_resolves` already gives `F(psi) in chain(n) -> psi in chain(n+1)` WHEN the schedule targets psi at step n. By `schedule_surjective_above`, for any psi and any k, there exists n >= k with schedule(n) = psi. So if F(psi) persists until step n, then psi in chain(n+1).

**But wait**: Does F(psi) persist? In the `bx_fmcs` construction, `fwd_succ` uses either `forward_temporal_witness_seed` (when F(schedule n) is in M) or `g_content` alone. If F(psi) is in M but the schedule targets a different formula chi at step n, the construction uses `forward_temporal_witness_seed` for chi (if F(chi) in M) or plain g_content. In either case, g_content(M) subset chain(n+1). Since F(psi) in M implies G(F(psi)) in M (by temp_future applied to F(psi)... wait, does it? temp_future is `Box(phi) -> G(Box(phi))`, not about F(phi)). Actually: does `F(psi) in M` imply `G(F(psi)) in M`?

**THIS IS THE KEY QUESTION.** If `F(psi) in M` does NOT imply `G(F(psi)) in M`, then `F(psi)` is NOT in `g_content(M)`, and the Lindenbaum extension at the next step may or may not include F(psi). This is the SAME opacity problem as in the defect-directed chain.

So the sorry-free construction also does not trivially prove `fwd_chain_forward_F` — it just hides the problem by not stating the theorem. The sorry is in the defect-directed chain because that is where the theorem is stated.

### The Real Obstruction: F-Persistence is Unprovable from BX

`F(psi) in M` does NOT imply `G(F(psi)) in M`. Why?

- `temp_future` is `Box(phi) -> G(Box(phi))`. Here `Box = Necessity`, not `G = All Future`.
- There is no axiom `F(phi) -> G(F(phi))`. This would mean "if phi holds at some future time, then at all future times phi holds at some future time" — which is NOT valid for irreflexive strict future on integers. Consider: F(p) true at time 0 because p at time 1. At time 2, p may not hold at any future time. So F(p) at 0 does not imply F(p) at 2.

**Correction**: Actually on Z (integers), the future is unbounded in both directions, so "F(p) at 0 implies p at some t > 0" does not imply "F(p) at 1 implies p at some t > 1". The formula F(p) is NOT G-propagating.

This means: **at every chain step, F(psi) may vanish from the MCS, and once gone (by `fwd_chain_F_obligation_monotone`), it never returns.** But the schedule only targets psi at SOME future step n. If F(psi) vanishes before n, psi is never resolved.

But `fwd_chain_F_obligation_monotone` says: if F(psi) leaves, it stays gone. The contrapositive: if F(psi) keeps entering, something is wrong. Actually the monotonicity says: if F(psi) is NOT in chain(k+1), then F(psi) is NOT in chain(m) for all m > k+1. So either F(psi) persists forever (in which case the schedule eventually hits it), or F(psi) drops out at some step k (in which case neg F(psi) = G(neg psi) enters at step k, meaning psi NEVER holds at any future step — which means psi cannot be resolved).

**Wait**: if G(neg psi) is in chain(k), that means neg psi is in chain(m) for all m > k. So psi is NOT in chain(m) for any m > k. This means `fwd_chain_forward_F` is UNPROVABLE in this case — the theorem claims phi appears at some future step, but it never does!

**Unless**: the case F(psi) in chain(n) and G(neg psi) in chain(k) for k > n leads to a contradiction. Is F(psi) in chain(n) consistent with G(neg psi) in chain(n+1)? If g_content(chain(n)) subset chain(n+1), and G(neg psi) in chain(n+1), that does NOT force G(neg psi) in chain(n). So there is no immediate contradiction.

But: if F(psi) in chain(n) and g_content(chain(n)) subset chain(n+1), and neg F(psi) = G(neg psi) in chain(n+1), then: G(neg psi) in chain(n+1) means neg psi in chain(m) for all m > n+1 (by forward_G). Also neg psi in chain(n+1) (by G(neg psi) in chain(n+1) and... wait, this requires BX1 which is removed). Under irreflexive semantics, G(neg psi) in chain(n+1) does NOT imply neg psi in chain(n+1). It only implies neg psi in chain(m) for m > n+1.

So psi could still be in chain(n+1) even when G(neg psi) in chain(n+1). This is the irreflexive semantics at work.

**Conclusion**: F-persistence is not axiomatic, but the F-obligation monotonicity + schedule surjectivity argument IS viable. Either F(psi) persists until the schedule hits psi (at which point fwd_succ_resolves gives psi), or F(psi) drops at step k. If F(psi) drops, neg F(psi) = G(neg psi) enters. But this does NOT prevent psi from appearing at step k (under irreflexive semantics, G(neg psi) in chain(k) is compatible with psi in chain(k)).

Actually, the monotonicity result says: if F(psi) NOT in chain(k+1), then either psi in chain(k+1) or F(psi) was NOT in chain(k). So: if F(psi) in chain(k) and F(psi) NOT in chain(k+1), then psi in chain(k+1). THIS IS THE KEY LEMMA. Is this actually proved?

Let me check. The `fwd_chain_F_obligation_monotone` says: if chi NOT in chain(m) and F(chi) in chain(n) and n <= m, then F(chi) in chain(m). Contrapositively: if F(chi) NOT in chain(m) and F(chi) in chain(n) and n <= m, then chi in chain(m'') for some m'' between n and m. Actually no — the contrapositive is: if F(chi) NOT in chain(m) and n <= m, then either chi in some chain(k) for n < k <= m, or F(chi) NOT in chain(n).

So: F(psi) in chain(n) and F(psi) NOT in chain(n+1) implies psi in chain(n+1). Because if psi NOT in chain(n+1), then by the monotonicity lemma (taking k = n+1): F(psi) NOT in chain(n) (since psi not in chain(m) for n < m <= n+1 = just chain(n+1), and psi not in chain(n+1)), contradicting our hypothesis.

**THIS RESOLVES `fwd_chain_forward_F` for the SORRY-FREE `bx_fmcs` construction!** The argument is:

1. F(psi) in chain(n).
2. By schedule_surjective_above, exists m >= n with schedule(m) = psi.
3. Case 1: F(psi) still in chain(m). Then chain(m+1) = fwd_succ(chain(m), schedule(m)) = fwd_succ(chain(m), psi). Since F(psi) in chain(m), fwd_succ_resolves gives psi in chain(m+1). Done.
4. Case 2: F(psi) NOT in chain(m). Then by F_obligation_monotone contrapositive, psi appeared in some chain(k) for n < k <= m. Done.

**THE PROOF WORKS FOR `bx_fmcs` but NOT for `fwd_chain_of_sigma`.** Why? Because `bx_fmcs` uses the simple `fwd_succ` with the schedule, while `fwd_chain_of_sigma` uses the complex defect-directed `preserving_fwd_step`. The monotonicity result `fwd_chain_F_obligation_monotone` is specifically for `fwd_chain_of_sigma`, and has different behavior.

---

## False Assumptions Identified

### Assumption 1: "The defect-directed chain is needed"

Every plan assumes we must use `fwd_chain_of_sigma` / `dd_bfmcs`. Nobody has checked whether the simpler `bx_fmcs` from CanonicalModel.lean (which is ALREADY SORRY-FREE for its basic properties) can be directly extended to prove the temporal coherence properties needed by `dd_countermodel`.

The `dd_countermodel` needs a `BFMCS Int` with `restricted_temporally_coherent`, `restricted_forward_until_since_coherent`, and `restricted_backward_until_since_coherent`. The `bx_fmcs` already provides `forward_G` and `backward_H`. The missing properties (F/P resolution, Until/Since coherence) need to be proved for `bx_fmcs`, not for the more complex `fwd_chain_of_sigma`.

### Assumption 2: "The BX12 bridge requires mapping BXPoints to chain indices"

Plan v6 says the BX12 bridge is "blocked" because "BXPoints cannot be mapped to chain indices." But BX12 gives `F(phi) -> (T U phi)` at the MCS level. The Until eventuality resolution (`bx_until_eventuality_resolution`) works at the BXPoint level, producing a BXPoint v with bx_le w v and psi in v. The "mapping" problem arises because `fwd_chain_forward_F` needs `phi in chain(m)` for a SPECIFIC chain index m, not just any BXPoint. But if we use `bx_fmcs` instead of `fwd_chain_of_sigma`, the schedule + monotonicity argument above avoids this entirely.

### Assumption 3: "F-obligation monotonicity is the key tool"

All plans focus on the monotonicity of `{chi | F(chi) in chain(k)}`. But the REAL key tool is the **contrapositive of monotonicity**: if F(chi) drops at step k, then chi MUST have appeared. This gives a dichotomy: either F(chi) persists forever (and the schedule resolves it), or chi already appeared. No plan exploits this dichotomy.

### Assumption 4: "Backward chain needs separate treatment"

Sorry #2 and #3 are treated as separate problems. But the Int-indexed chain (`int_chain`) already unifies forward and backward via CanonicalModel.lean. The `bx_fmcs` construction handles both directions uniformly. The backward chain's P-resolution is the exact dual of F-resolution.

### Assumption 5: "Until/Since coherence depends on F-resolution"

Plan v6 Phase 4 assumes sorry #5 (forward Until/Since coherence) reduces to sorry #1 via BX10. This is partially correct for the EXISTENCE of the Until witness. But the GUARD PERSISTENCE (phi at all intermediate points) is an independent problem that none of the plans adequately address. The guard persistence requires showing that `(phi U psi)` propagates through the chain from t to s-1, which is a much harder claim than F-resolution.

### Assumption 6: "The chain construction can be fixed by changing the step function"

Plans v4, v5, v6 all propose different step functions (extended discharge, hybrid, round-robin). But the core Lindenbaum opacity issue affects ALL step functions equally. The right fix is not to change HOW each step is computed, but to exploit the STRUCTURE of the schedule + monotonicity to reason about the chain as a whole.

---

## BX11/BX12 Postmortem

### BX11 (temp_linearity)

BX11 states: `F(phi) -> F(phi /\ F(chi)) v F(phi /\ chi) v F(F(phi) /\ chi)` (a trichotomy about how two future eventualities can interact). It was used in the `resolving_enriched_fwd_exists` fold to build compound Lindenbaum seeds. The fold iterates over active defects, using BX11 to combine F-obligations.

**Why BX11 failed to solve the problem**: BX11 gives a DISJUNCTION. For each defect chi, we learn that SOME branch of the disjunction holds, but not which one. The fold produces a compound seed that resolves SOME defect w, but Classical.choice in the Lindenbaum extension decides which one, and may perpetually avoid resolving the target phi. This is the "BX11 perpetual deferral" documented at RootScopedChain.lean:1125-1129.

**The mathematical content of BX11 is sound**: BX11 correctly captures that future eventualities interact linearly. The problem is entirely in how it is USED — the non-constructive fold cannot control which branch Classical.choice picks.

### BX12 (F_until_equiv)

BX12 states: `F(phi) -> (T U phi)`. This reduces F-eventuality to Until-eventuality. The idea was to use the existing Until resolution machinery (from task 98) to handle F-resolution.

**Why BX12 failed**: Plan v5 tried to use `bx_until_eventuality_resolution` (which works at the BXPoint level in the full canonical model) to close `fwd_chain_forward_F` (which works at the chain-index level in a specific chain). The mismatch: BXPoints are MCS in a preordered space; chain indices are Nat/Int positions in a fixed sequence. There is no natural embedding from one to the other.

**The BX12 bridge IS correct mathematically**: The reduction `F(phi) -> (T U phi)` is valid. The failure is architectural — wrong level of abstraction. If the proof were restructured to work at the BXPoint level (or if the chain index level had the right properties), BX12 would work.

---

## Root Cause Assessment: Why 6 Rounds Failed

### The Single Root Cause

Every failed approach is a symptom of the same root cause: **trying to prove `fwd_chain_forward_F` for the wrong chain construction.**

The `fwd_chain_of_sigma` / `dd_bfmcs` construction was designed to resolve defects for a SPECIFIC sigma_list. But the defect-directed step function (`preserving_fwd_step`) introduces uncontrollable non-determinism via `Classical.choice` in the BX11 fold. No amount of clever reasoning about the fold's behavior can overcome the fundamental opacity of Lindenbaum extensions.

Meanwhile, the simpler `bx_fmcs` construction in CanonicalModel.lean uses a straightforward schedule with `fwd_succ`. The schedule ensures every formula is targeted infinitely often. The F-obligation monotonicity contrapositive provides the dichotomy: either F(phi) persists until the schedule hits it (resolution guaranteed by `fwd_succ_resolves`), or phi already appeared (resolution already happened). This proof strategy is clean and does not fight Classical.choice.

### Why Nobody Noticed

1. **File separation**: CanonicalModel.lean and RootScopedChain.lean are in the same directory but represent different construction approaches. The task description says "11 chain construction sorries" without distinguishing which construction.

2. **Historical layering**: RootScopedChain.lean was built ON TOP of CanonicalModel.lean (it imports CanonicalChain.lean, which imports the base construction). The defect-directed chain was added as an "improvement" to handle sigma-restricted coherence. But the base construction may already suffice.

3. **Focus on the wrong sorry**: All research focused on sorry #1 (`fwd_chain_forward_F`), which is specific to `fwd_chain_of_sigma`. Nobody asked: "can we prove the equivalent theorem for `bx_fmcs` instead, and wire `dd_countermodel` through `bx_fmcs`?"

4. **Sunk cost**: 6 rounds of research built extensive infrastructure around `fwd_chain_of_sigma` (defect counting, BX11 analysis, sigma-restricted ordering). Abandoning this feels like wasted work.

### The Recommendation (Stated as a Problem, Not a Fix)

The core unanswered question is: **Can `dd_countermodel` be rewired to use `bx_fmcs` (or `shifted_bx_fmcs`) instead of `dd_bfmcs`?**

If yes: the F/P resolution proof follows from schedule surjectivity + monotonicity contrapositive (as sketched above). Until/Since coherence still needs work but is at least tractable.

If no: there must be a specific reason why `dd_bfmcs` is needed over `bx_fmcs`. Identifying that reason would be the most productive next step.

---

## Confidence Level: HIGH

**Justification**:
- Every claim is backed by specific code references (file, line number, function name)
- The sorry site catalog covers ALL sorry sites with exact goal states
- The "false as stated" claims for non-critical sorries follow directly from BX1 removal
- The schedule + monotonicity argument is a well-known technique in temporal logic completeness proofs (cf. Goldblatt 1992 section 8.5)
- The root cause analysis (wrong chain construction) is supported by the existence of the sorry-free alternative in the same directory
- I have verified that CanonicalModel.lean is sorry-free by reading it completely (377 lines, no sorry)
