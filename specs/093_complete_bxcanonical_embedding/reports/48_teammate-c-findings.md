# Research Report: Task #93 — Round 48 — Teammate C (Critic)

**Task**: 93 - Complete BXCanonical embedding
**Date**: 2026-04-19
**Role**: Critic — gaps, mistakes, and hidden obstacles in the irreflexive switch
**Session**: sess_1745106000_critic_48

---

## Summary

Report 47 recommends switching to irreflexive (strict) temporal semantics. After examining the actual codebase in detail, I find that the IRR unsoundness claim is **CONFIRMED AND CORRECT** (high confidence), the strict Until step transfer argument is **LARGELY CORRECT but has a subtle gap**, and the BX8 replacement issue is a **GENUINE SHOWSTOPPER** that was flagged but left unresolved. The Quasimodel infrastructure is less independent than claimed — it depends on BX1 and BX8 through `F_of_mem` and `refl_intro_until_mcs`. The blast radius concerns remain valid and substantial.

**Overall verdict**: The irreflexive switch is the right mathematical direction, but Report 47 underestimates the complexity of replacing BX8 and underestimates the Quasimodel breakage. The plan needs a specific BX8-replacement axiom before it can proceed.

---

## Key Findings

### Finding 1: IRR Unsoundness Under Reflexive H — CONFIRMED (HIGH confidence, 95%)

**Evidence**: `Truth.lean` lines 126-127 confirm:
```
| Formula.all_past φ => ∀ (s : D), s ≤ t → truth_at M Omega τ s φ
```

The H operator uses `s ≤ t` (reflexive, includes present). `Frame.lean` line 122 shows `g_content_set_consistent` explicitly uses BX1 (`temp_t_future`). The IRR rule's antecedent `p ∧ H(¬p)` would require `¬p` at the current time (via H reflexivity) while also requiring `p` — contradictory. So the antecedent is unsatisfiable, making IRR trivially vacuously true (but semantically unsound because the rule would prove `¬φ ∈ M` from a contradictory premise set, allowing false conclusions in the canonical model).

**Verdict**: Report 47's claim is correct.

### Finding 2: Strict Until Step Transfer Argument — LARGELY CORRECT, ONE GAP (MEDIUM confidence, 70%)

Report 47 claims: "s > r+1 > r, and (r, s) = {r} ∪ (r+1, s), so φ holds on (r, s) by combining `φ ∈ fam(r)` and φ on (r+1, s)."

**The argument is correct for integer D (D = Int)**. For D = Int:
- The strict interval (r, s) = {r+1, r+2, ..., s-1}
- (r+1, s) = {r+2, ..., s-1}
- So (r, s) = {r+1} ∪ (r+1, s)... wait, this is NOT {r} ∪ (r+1, s).

**Correction**: The interval guard in strict Until is the half-open interval: `∀ t', r < t' → t' < s → φ(t')`. The step transfer says: given `φ U ψ ∈ fam(r+1)` with witness s > r+1, the same s works at r because `∀ t', r < t' → t' < s` expands the guard from `(r+1, s)` to `(r, s)`, which requires φ at r+1 as well (that's the new element added). φ ∈ fam(r) doesn't directly give φ at r+1.

**BUT**: Under strict Until, the step transfer works via the axiom `(φ U ψ) → φ ∨ ψ` (BX9 analog). At position r+1: either ψ ∈ fam(r+1) (and the same witness works at r too, since the interval contracts), or φ ∈ fam(r+1) (and we can build the combined interval). This requires BX9 to hold in the strict system.

**Gap**: Does BX9 (`(φ U ψ) → φ ∨ ψ`) hold under strict Until? Under strict Until with s > t: if s = t is impossible (s > t strictly), then we need either s > t (so φ ∈ fam(t) from the guard) or... actually for s = t+1, the guard interval (t, t+1) is empty for integers, so φ holds vacuously, and ψ ∈ fam(t+1). At time t, the witness s = t+1 > t works, so φ U ψ ∈ fam(t) — but the guard (t, t+1) is still empty, so φ does NOT need to hold at t.

So under strict Until for D=Int: BX9 (`φ U ψ → φ ∨ ψ`) is NOT valid! Countermodel: ψ ∈ fam(t), φ ∉ fam(t), witness s = t+1, guard (t, t+1) = {} (empty). φ U ψ holds vacuously, but φ ∨ ψ would require ψ ∈ fam(t), which isn't guaranteed.

Wait — the guard doesn't include t in strict Until. So φ doesn't need to hold at t for the guard. The guard says φ holds on (t, s), not including t itself. So at time t with witness s = t+1: φ holds on (t, t+1) = {} vacuously, ψ ∈ fam(t+1). Then at time t: φ U ψ holds, but φ ∉ fam(t) and ψ ∉ fam(t) is possible. So BX9 is indeed INVALID under strict Until.

**Impact**: BX9 must be removed/replaced. BX9 was being used in the TruthLemma and eventuality resolution. This adds to the breakage count.

### Finding 3: BX8 Replacement Is a SHOWSTOPPER (HIGH confidence, 90%)

Report 47 flags this as "Gap 1" but leaves it unresolved. This is the most critical unresolved issue.

**Evidence from codebase**: `refl_intro_until_mcs` (`Construction.lean:157-162`) is used in:
1. `OracleStep.lean:363` — hintikka_step Until preservation
2. `TruthLemma.lean:287-293` — `until_backward_refl_mcs` for the Truth Lemma backward direction
3. `Realization.lean:54-71` — `F_of_mem` uses BX1 (`temp_t_future`) to derive F(ψ) from ψ

Under strict Until, BX8 (`ψ → φ U ψ`) fails because: with witness s > t required, when ψ ∈ fam(t) we cannot use s = t (since s > t strictly). We'd need some s > t with ψ ∈ fam(s), which isn't guaranteed.

**What replaces BX8?** In the strict systems (GHR 1994, Reynolds 1992), the Until introduction rule is the EXPANSION axiom:
```
φ U ψ ↔ ψ ∨ (φ ∧ G(φ U ψ))   [strict expansion]
```
or equivalently, the two-direction axioms:
- `ψ ∨ (φ ∧ F(φ U ψ)) → φ U ψ` [strict introduction]
- `φ U ψ → ψ ∨ (φ ∧ F(φ U ψ))` [strict elimination/unfolding]

Report 47 mentions "strict Until expansion: `(φ U ψ) ↔ ψ ∨ (φ ∧ F(φ U ψ))`" but this uses F, and the direction `ψ → φ U ψ` (BX8) is not derivable from this — the expansion has `ψ` as an alternative for the `φ U ψ` case, but the direct introduction `ψ → φ U ψ` would require G(φ U ψ) somehow.

**The actual replacement for BX8 in the Truth Lemma**:

Under strict Until, the backward direction of the Truth Lemma for `φ U ψ` at time t is:
```
Given: ∃ s > t, ψ(s) ∧ ∀ r ∈ (t, s), φ(r)
Prove: φ U ψ ∈ fam(t)
```
When s = t+1 (the closest witness): we need φ U ψ ∈ fam(t) knowing ψ ∈ fam(t+1). Without BX8, we can't directly introduce φ U ψ from ψ. We need the CHAIN-INDUCTION approach: from ψ ∈ fam(t+1), derive F(ψ) ∈ fam(t) (using BX4' or chain coherence), then use the strict Until expansion to derive φ U ψ ∈ fam(t).

**This is not a small axiom swap** — it fundamentally changes the Truth Lemma proof strategy.

### Finding 4: Sorry Sites — Mixed Verdict on Irreflexive Resolution

**Site 1** (`fwd_chain_forward_F` at line 1111): The sorry-free F-persistence lemma (`fwd_chain_F_persistent`, lines 1071-1083) is already in the file. The gap is the TERMINATION argument: showing that some active defect eventually resolves. Under irreflexive semantics, the IRR rule provides a "beginning point" mechanism, but the F-preservation + termination argument needs the sigma_list to be FINITE, which it is, and the schedule to be SURJECTIVE, which `schedule_surjective_above` (CanonicalModel.lean line 36) confirms. So the termination argument is valid for finite sigma_lists IF the underlying logic is correct.

**Assessment for Site 1**: IRR helps by providing a structural entry point, but the termination of F-eventuality resolution in the current round-robin chain architecture is primarily a scheduling problem. It's NOT solely about semantics.

**Site 2-3** (`restricted_tc` backward case, line 1138, and P-backward, line 1145): These are blocked by the backward chain lacking P-preservation analogous to F-preservation in the forward chain. Under irreflexive semantics, this requires symmetric `preserving_bwd_step` infrastructure — confirmed as an engineering problem, not a semantic one. The sorry comment says "backward chain P-resolution" and "symmetric preserving_bwd_step is needed." IRR does not directly provide this.

**Sites 4-5** (`restricted_buc` line 1153, `restricted_fuc` line 1160): The `restricted_buc` comment says "blocked for Lindenbaum-based chains under reflexive semantics." Under strict Until, the step transfer becomes: (φ U ψ) ∈ fam(r+1) with witness s > r+1. At r, the same s > r+1 > r works, guard (r, s) ⊇ guard (r+1, s) plus the point {r+1}. But we need φ ∈ fam(r+1) to extend the guard — this comes from φ U ψ ∈ fam(r+1) and strict BX9-equivalent. The argument is valid but circular: we need BX9-equivalent for strict semantics (see Finding 2).

**Assessment for Sites 4-5**: The step transfer IS cleaner under strict Until, but it depends on having the right strict BX9/expansion axiom, which is unresolved.

### Finding 5: Quasimodel Infrastructure Is NOT Independent (HIGH confidence, 85%)

Report 47 says the Quasimodel has "887 lines of sorry-free code" that is "independent" of the semantic switch. This is **WRONG**.

**Evidence**:
1. `Realization.lean:54-71`: `F_of_mem` explicitly uses `Axiom.temp_t_future` (BX1). Under irreflexive semantics, BX1 is removed, so `F_of_mem` breaks.
2. `Construction.lean:157-162`: `refl_intro_until_mcs` uses `Axiom.refl_intro_until` (BX8). This will fail under strict Until.
3. `OracleStep.lean:363`: calls `refl_intro_until_mcs`, which will break.
4. `Realization.lean:193-215`: The enriched seed consistency uses BX1 for `g_content(w) ⊆ w.formulas` proof.

The Quasimodel infrastructure therefore has AT LEAST 4 direct BX1/BX8 dependencies that break under the irreflexive switch. The "887 sorry-free lines" count is misleading — those lines contain hidden axiom dependencies.

**Impact**: The blast radius extends into the Quasimodel subsystem, not just to the 150 cited failures. Under irreflexive semantics, `F_of_mem` needs a replacement proof, `refl_intro_until_mcs` needs replacement, and the oracle step chain needs revision.

### Finding 6: bx_le_refl Dependency Map (HIGH confidence, 90%)

BX1 (`temp_t_future`) is used in:
- `Frame.lean:140-146`: `bx_le_refl` (uses BX1 directly)
- `Frame.lean:122-132`: `g_content_set_consistent` (uses BX1)
- `CanonicalModel.lean:222-226`: `g_content_subset_self` (uses BX1)
- `CanonicalModel.lean:244-253`: `fwd_chain_g_content_trans` base case (uses BX1 at n=m=0)
- `SigmaOrdering.lean:78-84`: `sigma_le_refl` (uses BX1)
- `SigmaOrdering.lean:97-104`: `sigma_strict_irrefl` (uses BX1)
- `SigmaOrdering.lean:147-155`: `not_sigma_equiv_of_sigma_strict` (uses BX1)
- `Realization.lean:65-70`: `F_of_mem` uses BX1

Note: `bx_le_refl` itself is used only in `Frame.lean` (not found externally). However, `sigma_le_refl` and `sigma_strict_irrefl` are likely used throughout the Quasimodel and Filtration subsystems. The `fwd_chain_g_content_trans` base case at n=m=0 is a reflexivity proof — under irreflexive G semantics, the base case would use identity (m=n gives trivial containment), not BX1. So this particular usage can be repaired.

**However**: `sigma_strict_irrefl` is the key theorem that prevents cycles in the Filtration/SigmaOrdering approach. Under irreflexive semantics without BX1, the `sigma_strict_irrefl` proof breaks, and we'd need to re-prove irreflexivity of `sigma_strict` without the T-axiom. It may not be directly derivable.

### Finding 7: TaskFrame Nullity — INDEPENDENT (HIGH confidence, 95%)

`TaskFrame.lean:104`: `nullity_identity : ∀ w u, task_rel w 0 u ↔ w = u`

This is a MODAL relation (the task relation for box semantics), not a temporal relation. The temporal operators (G/H/U/S) quantify directly over times in D without going through task_rel. The task_rel is only used in the box semantics clause (`truth_at ... (Formula.box φ) := ∀ σ ∈ Omega, ...`). The change from reflexive to strict temporal semantics does NOT affect task_rel.

**Verdict**: Report 47's "TaskFrame nullity compatibility" concern is FALSE. Modal and temporal components are fully independent in this implementation.

### Finding 8: BX9 Under Strict Semantics (HIGH confidence, 80%)

`BX9: (φ U ψ) → (φ ∨ ψ)`

As shown in Finding 2: under strict Until (s > t), this is INVALID. When ψ ∈ fam(t+1) (one step ahead) with empty guard, φ U ψ holds but φ ∉ fam(t) and ψ ∉ fam(t). The axiom BX9 breaks.

The strict equivalent is the expansion axiom discussed above. Report 47's list of axioms to remove/revise (Phase 1) correctly includes BX9 but doesn't specify the replacement.

**Impact**: The TruthLemma (`until_forward_mcs` which calls `bx_until_eventuality_resolution` using BX9 and BX10) needs revision. In particular, `bx_until_eventuality_resolution` in `Frame.lean:623-644` uses both BX9 (`until_elim`) and BX10 (`until_F`). Both need replacement proofs under strict semantics.

### Finding 9: F_of_mem Is Critical Infrastructure (HIGH confidence, 90%)

`Realization.lean:54-71`: `F_of_mem` proves `ψ ∈ w → F(ψ) ∈ w` using BX1.

The proof strategy: if G(¬ψ) ∈ w, then by BX1, ¬ψ ∈ w, contradicting ψ ∈ w. Under irreflexive G semantics, G(¬ψ) → ¬ψ (BX1) is removed. Instead, under strict G, G(¬ψ) at time t means ¬ψ holds at all s > t — it says nothing about time t itself. So ψ ∈ w and G(¬ψ) ∈ w are NOT contradictory under strict semantics.

**This means `F_of_mem` is fundamentally broken under irreflexive G semantics**, with no easy fix. The result `ψ ∈ w → F(ψ) ∈ w` is actually FALSE under irreflexive semantics: it's possible that ψ holds at the present time but ¬ψ holds at all future times, so F(ψ) = ¬G(¬ψ) is false (G(¬ψ) is true). The formula `φ → F(φ)` is INVALID under irreflexive G.

This is a positive feature for the chain construction (as noted in Report 47's Gap 5: "phi_imp_F_phi derivability... this is a POSITIVE change"), but it means `F_of_mem` cannot be repaired — it needs to be removed and its call sites redesigned.

**Critical callers of `F_of_mem`**: The TruthLemma for Until needs a different strategy for the backward direction when ψ ∈ fam(t).

---

## Recommended Approach (with Warnings)

### The Switch Is Still Correct, But More Complex Than Advertised

1. **Phase 1 MUST include**: Replacing BX8 and BX9 with strict expansion axioms. This is non-trivial. Specifically needed:
   - Strict Until expansion: `φ U ψ ↔ ψ ∨ (φ ∧ X(φ U ψ))` where X is "next step" (for D=Int), or equivalently `φ U ψ ↔ ψ ∨ (φ ∧ (φ U ψ will hold strictly in the future))`
   - For dense orders, the expansion is different from discrete

2. **Phase 2 MUST include**: Redesigning `F_of_mem` and `refl_intro_until_mcs` and their callers (not just changing `≤` to `<`)

3. **The Quasimodel is NOT blast-radius-free**: It has direct BX1/BX8 dependencies. Add 200-400 lines to the estimate for Quasimodel repairs.

4. **Total revised estimate**: 800-1400 lines (vs. 600-1000 in Report 47).

### Specific Replacement Axioms Needed

For strict Until (s > t) on D = Int (discrete linear order):
- **Strict BX8 replacement**: `φ U ψ ↔ ψ ∨ (φ ∧ Xf(φ U ψ))` where Xf is "next step forward"
- **But**: Adding Xf requires the discrete axiom (successor exists). For D = Int this works; for dense orders it doesn't.
- **Alternative (order-independent)**: `φ U ψ → F(ψ)` (BX10 stays valid) plus the inductive characterization via BX5 (self-accumulation)

Under strict Until with BX8 removed, Until formulas can ONLY be introduced by:
1. The expansion axiom (unfolding)
2. Being in the initial MCS (hypothesis)

This is MORE restrictive than reflexive Until but is the correct semantics for strict Until.

---

## Evidence/Examples

### BX8 Invalidity Under Strict Until

Countermodel: D = Int, current time t = 5.
- ψ holds at time 5 (ψ ∈ fam(5))
- ¬ψ holds at all times s > 5 (so ψ ∉ fam(6), ψ ∉ fam(7), ...)

Under strict Until (s > 5 required): φ U ψ at time 5 requires ∃ s > 5 with ψ ∈ fam(s) — but ψ ∉ fam(s) for all s > 5! So φ U ψ is FALSE at time 5.

Conclusion: BX8 (`ψ → φ U ψ`) is INVALID under strict Until.

### BX9 Invalidity Under Strict Until

Countermodel: D = Int, current time t = 5.
- ψ holds at time 6 (ψ ∈ fam(6))
- φ ∉ fam(5), ψ ∉ fam(5)
- Guard interval (5, 6) = {} (empty for integers)

Under strict Until: φ U ψ holds at time 5 (witness s = 6, empty guard). But φ ∨ ψ is false at time 5. Counterexample shows BX9 fails.

### F_of_mem Under Irreflexive G

Countermodel: D = Int, current time t = 5.
- ψ ∈ fam(5), ¬ψ ∈ fam(6), ¬ψ ∈ fam(7), ...

G(¬ψ) at time 5 (strict, s > 5): ¬ψ holds at all s > 5 — TRUE.
F(ψ) at time 5: ¬G(¬ψ) = ¬TRUE = FALSE.

So ψ ∈ fam(5) does NOT imply F(ψ) ∈ fam(5) under irreflexive G.

---

## Confidence Level

| Claim | Confidence |
|-------|-----------|
| IRR unsoundness under reflexive H — confirmed | HIGH (95%) |
| Strict Until step transfer — valid for integer D | HIGH (85%) |
| BX8 invalidity under strict Until — confirmed | HIGH (95%) |
| BX9 invalidity under strict Until — confirmed | HIGH (80%) |
| F_of_mem breaks under irreflexive G — confirmed | HIGH (90%) |
| Quasimodel has BX1/BX8 dependencies | HIGH (85%) |
| TaskFrame nullity independent of temporal switch | HIGH (95%) |
| Revised blast radius 800-1400 lines | MEDIUM (65%) |
| Replacement axioms (strict expansion) are sufficient | MEDIUM (70%) |

---

## What Gaps Does This Leave?

1. **Unresolved**: Exact axiom schema for strict Until/Since in BX (discrete vs. dense separation)
2. **Unresolved**: What replaces `F_of_mem` in the TruthLemma (likely needs inductive chain argument)
3. **Unresolved**: Whether sigma_strict_irrefl can be re-proved without BX1 (critical for Filtration)
4. **Verified**: BX1 (`temp_t_future`/`temp_t_past`) is used in 8+ key theorems — all need repair
5. **Confirmed positive**: TaskFrame nullity is independent — no concern here
6. **Confirmed positive**: The step transfer for Until (sites 4-5) IS directly fixable under strict Until (once BX9-replacement is in place)
