# Teammate A Findings: deferralClosure Extension and BX12 Reduction Feasibility

**Task**: 93 — Close remaining BXCanonical sorries
**Focus**: Primary Approach — extend deferralClosure with `(⊤ U φ)` for each `F(φ)`, use BX12 to reduce `forward_F` to `forward_Until`
**Date**: 2026-04-13

---

## Key Findings

### 1. The 6 Active Sorry Sites

**File**: `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean`

| Line | Sorry | Path Status |
|------|-------|-------------|
| 497 | `bx_fmcs_forward_F` | Dead code (unrestricted) |
| 503 | `bx_fmcs_backward_P` | Dead code (unrestricted) |
| 586 | `bx_bfmcs_buc` forward | Dead code (unrestricted) |
| 591 | `bx_bfmcs_fuc` forward | Dead code (unrestricted) |
| 621 | `bx_bfmcs_restricted_buc` | **ACTIVE PATH** |
| 627 | `bx_bfmcs_restricted_fuc` | **ACTIVE PATH** |

The restricted temporal coherence (`bx_bfmcs_restricted_tc` at line 603-615) is **already proved** — it delegates to the two sorry sites above via `bx_fmcs_forward_F` and `bx_fmcs_backward_P`. This means `forward_F` and `backward_P` at lines 497/503 ARE on the active path indirectly (via `bx_bfmcs_restricted_tc`, which calls them).

Wait — re-reading line 603-615 more carefully: `bx_bfmcs_restricted_tc` calls `bx_fmcs_forward_F` at line 576, so lines 497 and 503 ARE on the active path through `bx_bfmcs_restricted_tc`.

**All 6 sorry sites are on the active path** through `bx_countermodel` → `bx_bfmcs_restricted_tc` / `bx_bfmcs_restricted_buc` / `bx_bfmcs_restricted_fuc`.

### 2. BX12 Exists and Is Already Proved at MCS Level

**File**: `Theories/Bimodal/Metalogic/BXCanonical/CanonicalChain.lean` lines 61-82

```lean
theorem F_imp_top_until_mcs {w : BXPoint} {ψ : Formula}
    (h : Formula.some_future ψ ∈ w.formulas) :
    Formula.untl (Formula.bot.imp Formula.bot) ψ ∈ w.formulas
```

This is exactly `F(ψ) → (⊤ U ψ)` at MCS level, where `⊤ = ⊥ → ⊥`. This lemma is already proved and available.

**Axiom**: `Axiom.F_until_equiv (φ : Formula)` at `Theories/Bimodal/ProofSystem/Axioms.lean` line 258:
```
BX12: F(φ) → (⊤ U φ)   [Axiom.F_until_equiv]
```
where `⊤ = Formula.bot.imp Formula.bot`.

### 3. deferralClosure Does NOT Include `(⊤ U φ)` for `F(φ)`

**File**: `Theories/Bimodal/Syntax/SubformulaClosure.lean` lines 806-810

```lean
def deferralClosure (phi : Formula) : Finset Formula :=
  baseDeferralClosure phi

def baseDeferralClosure (phi : Formula) : Finset Formula :=
  closureWithNeg phi ∪ deferralDisjunctionSet phi ∪ backwardDeferralSet phi ∪ serialityFormulas
```

- `deferralDisjunctionSet`: For each `F(χ)` in `closureWithNeg(phi)`, adds `χ ∨ F(χ)` (NOT `⊤ U χ`)
- `backwardDeferralSet`: For each `P(χ)`, adds `χ ∨ P(χ)`

There is also `extendedDeferralClosure` (line 812-814) which adds `untilDeferralSet` and `sinceDeferralSet`, but these are for Until/Since unfolding disjunctions `ψ ∨ (φ ∧ (φ U ψ))`, not for F-to-Until bridge.

**Critical gap**: `(⊤ U ψ)` is NOT in `subformulaClosure(root)` when `F(ψ)` is in it. The subformula relation for `F(ψ)` goes to `ψ` (inner), not to `⊤ U ψ`. Also `(⊤ U ψ)` is NOT in `deferralClosure(root)` as currently defined — neither the base set nor any of the union components add it.

### 4. The BX12 Reduction Chain for `bx_fmcs_forward_F`

The proposed approach:
1. `F(ψ) ∈ int_chain(M₀, h₀, t)` (hypothesis)
2. By BX12 (`F_imp_top_until_mcs`): `(⊤ U ψ) ∈ int_chain(M₀, h₀, t)`
3. By Until forward resolution (`bx_until_eventuality_resolution`): `∃ v : BXPoint, bx_le int_chain(t) v ∧ ψ ∈ v`
4. Need: `∃ s : Int, t < s ∧ ψ ∈ int_chain(M₀, h₀, s)`

**The gap at step 3→4**: `bx_until_eventuality_resolution` gives a `BXPoint v` with `bx_le` relation, but `v` is NOT necessarily of the form `int_chain(M₀, h₀, s)` for any `s`. The `bx_forward_witness` creates an arbitrary MCS via Lindenbaum, outside the int_chain.

This is the **fundamental blocker** for BX12 reduction: the int_chain is a specific sub-universe of BXPoints built by the scheduling construction. An arbitrary Lindenbaum extension landing at `ψ` has no reason to coincide with any `int_chain(M₀, h₀, s)`.

### 5. The `fwd_succ` Construction and forward_F

**File**: `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` lines 74-114

The `fwd_succ` has TWO branches:
- **Resolving branch** (`F(ψ) ∈ M`): extends `{ψ} ∪ g_content(M)` — ψ is resolved in the next step
- **Non-resolving branch** (`F(ψ) ∉ M`): extends `g_content(M) ∪ f_carry(M)` — F-formulas preserved

The `f_carry` mechanism (lines 52-68) preserves F-formulas through non-resolving steps:
```lean
def f_carry (M : Set Formula) : Set Formula :=
  {φ ∈ M | ∃ χ, φ = Formula.some_future χ}
```

This means `F(ψ) ∈ fwd_succ(M, h, target)` when `target ≠ ψ` — F-formulas survive non-resolving steps.

**Why forward_F is hard**: For `bx_fmcs_forward_F`, we need `∃ s > t` such that `ψ ∈ int_chain(M₀, h₀, s)`. The schedule `schedule_surjective_above` guarantees that ψ will eventually be the target of some step `n ≥ k`. But proving that F(ψ) persists from step t to step n (where ψ is resolved) requires:
- F(ψ) survives ALL non-resolving steps between t and n (via `fwd_succ_f_carry`)
- And is resolved at step n

The issue: **the resolving step (where schedule(n) = ψ) drops f_carry** — the resolving branch seed is `{ψ} ∪ g_content(M)`, NOT `{ψ} ∪ g_content(M) ∪ f_carry(M)`. So F(ψ) is not necessarily in `int_chain(n+1)` from the resolving step. But the RESOLVING step puts `ψ` itself (not `F(ψ)`) in the output — that IS what we want.

**The actual proof sketch**:
- Let `F(ψ) ∈ int_chain(t)`.
- By `schedule_surjective_above`, ∃ n ≥ t.toNat such that `schedule(n) = ψ`.
- Key: prove `F(ψ) ∈ fwd_chain(M₀, h₀, n)` where chain starts at t.
- This requires: F(ψ) persists from step t through all steps until step n (via f_carry when non-resolving).
- At step n (resolving), `ψ ∈ fwd_chain(n+1)` by `fwd_succ_resolves`.
- Then `int_chain(n+1)` (an Int step) has the answer with `n+1 > t`.

**The f_carry persistence induction** looks provable! For each step k between t and n:
- If `schedule(k) ≠ ψ`: the non-resolving branch is taken, `f_carry` is in the seed, so `F(ψ)` persists.
- If `schedule(k) = ψ` before step n: the resolving branch is taken at step k, `ψ ∈ fwd_chain(k+1)`. Done at step k+1 — no need to go to step n.

So the proof terminates at the FIRST resolving step, not necessarily step n. The schedule_surjective_above gives one such step, but if `F(ψ)` persists to the resolving step, we're done.

**The critical lemma needed**:
```lean
-- F(ψ) ∈ fwd_chain(m) and schedule(m) = ψ → ψ ∈ fwd_chain(m+1)
-- F(ψ) ∈ fwd_chain(m) and schedule(m) ≠ ψ → F(ψ) ∈ fwd_chain(m+1)
```

Both lemmas follow directly from `fwd_succ_resolves` and `fwd_succ_f_carry`! The proof should close by induction on the distance to the first resolving step.

### 6. The Strict vs Non-Strict Inequality Issue

The `restricted_temporally_coherent` requires **strict** inequality: `∃ s > t` (not `s ≥ t`). The resolving step gives `ψ ∈ fwd_chain(n+1)` where `n+1 > t.toNat` (as a Nat). Converting to Int: `(n+1 : Int) > (t : Int)` when `t ≥ 0`. This gives strict inequality as needed.

For the `bx_fmcs_forward_F` signature, `t : Int` and we need `s : Int` with `t < s`. The resolving step gives `s = (n+1 : Int)` where `n ≥ t.toNat`, so `s ≥ t + 1 > t`. **Strict inequality is achievable**.

For `t < 0` (backward chain): `F(ψ) ∈ bwd_chain(-t)` via the forward chain at negative t... actually for negative t, `int_chain(t) = bwd_chain(-t)`. The backward chain doesn't have F-formula resolution built in. This is a potential problem.

### 7. The Backward Chain Problem for forward_F

For `t < 0`, `int_chain(M₀, h₀, t) = bwd_chain(M₀, h₀, (-t).toNat)`. The `bwd_pred` builds PREDECESSORS for resolving P-formulas (not F-formulas). There's NO analog of `f_carry` for F-formulas in the backward chain.

However: `bx_fmcs_forward_F` asks for `s > t` with `ψ ∈ int_chain(s)`. For `t < 0`, we can try `s = 0` (so `s > t`). We need `ψ ∈ M₀ = int_chain(0)`.

But `F(ψ) ∈ bwd_chain(-t)` and `bwd_chain` goes backward — forward witnesses are not guaranteed from backward chain members. The g_content propagation only goes FORWARD in the backward chain (g_content of later backwards steps is contained in earlier ones).

**Key insight for negative t**: `F(ψ) ∈ int_chain(t)` for `t < 0` means `F(ψ) ∈ bwd_chain(-t)`. By `bwd_chain_reverse_g` with appropriate reasoning:
- We can't directly get `ψ ∈ int_chain(s)` for any specific `s > t` from backward-chain membership alone
- BUT: `F(ψ) ∈ bwd_chain(-t)` means `F(ψ)` is in some MCS. From any MCS with `F(ψ)`, `bx_forward_witness` gives a BXPoint v with `ψ ∈ v`. But v is not a chain member.

**Alternative**: Use the scheduling approach from `int_chain` time 0. From time `t < 0`, the forward chain starting at 0 eventually resolves all F-formulas. But `F(ψ)` might not be in `M₀ = int_chain(0)`.

This is a genuine open problem for `t < 0` cases.

### 8. Restricted forward_F Is Actually Easier

The restricted version (`bx_bfmcs_restricted_tc`) only needs `forward_F` for `φ ∈ deferralClosure(root)`. The key use is in the truth lemma's G-backward case:
- `G(ψ) ∉ fam.mcs t` → `F(¬ψ) ∈ fam.mcs t` → need `∃ s > t, ¬ψ ∈ fam.mcs s`

So `φ = ¬ψ` where `ψ ∈ subformulaClosure(root)`, so `¬ψ ∈ closureWithNeg(root) ⊆ deferralClosure(root)`.

This means we only need `forward_F` for formulas that are negations of subformulas of root. These are all "small" formulas bounded by root's complexity. The scheduling construction needs to handle these.

### 9. The restricted_buc and restricted_fuc Sorries

**`bx_bfmcs_restricted_buc`** (line 621): needs `backward_until_since_coherent` for `φ U ψ ∈ subformulaClosure(root)`. Given witness pattern `(ψ at s ≥ t, φ on guard)`, derive `(φ U ψ) ∈ fam.mcs t`. This uses `backward_until_from_step` from `UntilSinceCoherence.lean`, which requires a step transfer property: `(φ U ψ) ∈ fam.mcs(r+1) ∧ φ ∈ fam.mcs r → (φ U ψ) ∈ fam.mcs r`.

**`bx_bfmcs_restricted_fuc`** (line 627): needs `forward_until_since_coherent` for `φ U ψ ∈ subformulaClosure(root)`. Given `(φ U ψ) ∈ fam.mcs t`, find `s ≥ t` with `ψ ∈ fam.mcs s` and φ on guard. This is actually close to being provable via `bx_until_eventuality_resolution` — which gives a BXPoint v with `ψ ∈ v.formulas`. The gap is that v must be a chain member.

---

## Recommended Approach

### Approach 1 (Cleanest): Prove forward_F via Scheduling Induction

**Core idea**: Induct on the number of steps to the first F(ψ)-resolving step in the forward chain.

**For `t ≥ 0`** (forward chain case):
1. `F(ψ) ∈ fwd_chain(t.toNat)`
2. By `schedule_surjective_above ψ t.toNat`, get `n ≥ t.toNat` with `schedule(n) = ψ`
3. Prove by induction on `(n - t.toNat)`: `F(ψ)` persists from step t to step n
   - Base: `n = t.toNat`, `schedule(n) = ψ`, so the FIRST step already resolves ψ → `ψ ∈ fwd_chain(n+1)`
   - Inductive: `schedule(n) ≠ ψ` implies non-resolving, so `F(ψ) ∈ fwd_chain(n+1)` by f_carry
   - Wait, this induction runs on `m` going from `t.toNat` to `n`. For each `m < n` with `schedule(m) ≠ ψ`: `F(ψ) ∈ fwd_chain(m+1)`. For `m = n` with `schedule(n) = ψ`: `ψ ∈ fwd_chain(n+1)`.
   - Actually need FIRST resolving step — use `Nat.find` or well-founded recursion on `n - t.toNat`
4. Conclusion: `ψ ∈ fwd_chain(n+1) = int_chain(n+1)` with `n+1 > t.toNat ≥ 0`, so `(n+1 : Int) > t`.

**For `t < 0`** (backward chain case): This is harder. One approach:
- `F(ψ) ∈ bwd_chain(-t.toNat)` (a backward chain MCS)
- By `bx_forward_witness` applied at the BXPoint level: get MCS `N` with `g_content(bwd_chain(-t.toNat)) ⊆ N` and `ψ ∈ N`
- But N is not a chain member

Alternative for `t < 0`: Use `F(ψ) ∈ bwd_chain(-t)` plus the observation that `bx_forward_witness` gives an MCS `N` via Lindenbaum, then build a fresh `int_chain(N, h_N)` starting at 0 from `N`. But this fresh chain is in a different `bx_bfmcs` family.

**The negative-t approach that might work**: Use BX4' (`φ → H(F(φ))`). If `F(ψ) ∈ bwd_chain(-t)`, then by BX4 direction: `G(F(ψ)) ∈ bwd_chain(-t-k)` for some earlier chain members? No, BX4 is about connectedness, not G-propagation of F.

**Actually**: Use h_content propagation. `H(F(ψ)) ∈ bwd_chain(-t)` would give `F(ψ) ∈ bwd_chain(-t - k)` for all k. But we need the FORWARD direction.

**Simpler for `t < 0`**: Since `bx_bfmcs_restricted_tc` only needs this for `φ ∈ deferralClosure(root)`, and the BFMCS families have their own `int_chain`, we can use the shifted_bx_fmcs structure. For `shifted_bx_fmcs N h_N s`, the chain at time `t` is `int_chain(N, h_N, t-s)`. If `t < s`, then `t - s < 0`, which is the backward-chain case for the inner chain. The `forward_F` question becomes about `int_chain(N, h_N, t-s)`.

**Unresolved**: The `t < 0` case for `bx_fmcs_forward_F` requires either:
- A separate argument using P-formulas and backward chain symmetry
- Or restricting to only needing it for the restricted case (which is all that's actually required)

### Approach 2: Restrict to Only What the Active Path Needs

Since `bx_bfmcs_restricted_tc` is what's actually called from `bx_countermodel`, and it calls `bx_fmcs_forward_F` without restriction, we may need to refactor. Options:

**Option A**: Prove `bx_fmcs_forward_F` in full (handling both t ≥ 0 and t < 0 cases).

**Option B**: Create a helper:
```lean
theorem bx_fmcs_forward_F_nonneg (M₀ : ...) (h₀ : ...) (t : Nat) (ψ : Formula)
    (h_F : F(ψ) ∈ fwd_chain(M₀, h₀, t)) :
    ∃ s > t, ψ ∈ fwd_chain(M₀, h₀, s)
```
And a separate approach for negative t (using that bwd_chain MCSes have some F-formula structure).

### Concrete Code Changes Needed

**Step 1: Prove f_carry persistence lemma** (in CanonicalModel.lean or new file):
```lean
-- Key inductive lemma
theorem fwd_chain_f_carry_persist (M₀ : ...) (h₀ : ...) (ψ : Formula)
    (m n : Nat) (h_le : m ≤ n)
    (h_F : F(ψ) ∈ fwd_chain(m))
    (h_no_resolve : ∀ k, m ≤ k → k < n → schedule(k) ≠ ψ) :
    F(ψ) ∈ fwd_chain(n) := by
  induction n with
  | zero => ...
  | succ k ih =>
    rcases Nat.eq_or_lt_of_le h_le with h_eq | h_lt
    · ...
    · apply fwd_succ_f_carry
      · exact h_no_resolve k ... rfl
      · exact ih ...
```

**Step 2: Prove forward_F for fwd_chain** (nonneg case):
```lean
theorem bx_fmcs_forward_F_fwd (M₀ : ...) (h₀ : ...) (t : Nat) (ψ : Formula)
    (h_F : F(ψ) ∈ fwd_chain(M₀, h₀, t)) :
    ∃ s : Nat, t < s ∧ ψ ∈ fwd_chain(M₀, h₀, s)
-- Use schedule_surjective_above to get first resolving step
-- Use fwd_chain_f_carry_persist for persistence
-- Use fwd_succ_resolves for the resolving step
```

**Step 3: Handle negative t in bx_fmcs_forward_F**:
This requires more thought. One approach: prove that `F(ψ) ∈ bwd_chain(k)` implies `F(ψ) ∈ M₀` (via g_content propagation on F-formulas, if `G(F(ψ)) ∈ M₀`), then reduce to the nonneg case from M₀. But this requires `G(F(ψ)) ∈ bwd_chain(k)` which is not guaranteed.

**Alternative for negative t**: Since `bwd_chain` steps use `bwd_pred` which propagates `h_content` backward (for H-formulas), and BX4' says `φ → H(F(φ))`, if `F(ψ) ∈ M` then `H(F(ψ)) ∈ M`? NO — BX4' is `φ → H(F(φ))`, not `F(ψ) → H(F(ψ))`.

**Actual approach for negative t**: Since `g_content(bwd_chain(k)) ⊆ bwd_chain(k-1)`, if `G(F(ψ)) ∈ bwd_chain(k)` then `F(ψ) ∈ bwd_chain(k-1)`, propagating forward. Use `bx_forward_witness` on the BXPoint `bwd_chain(k)` to get a Lindenbaum extension with `ψ`, then build a new shifted_bx_fmcs starting from this extension at time `(t - 1)`. But this gives a DIFFERENT chain, not the existing `int_chain`.

**This is the fundamental impossibility**: `bx_fmcs_forward_F` for negative t appears to require either a different chain construction or an additional property of the backward chain.

### 10. deferralClosure Extension Assessment

The task proposes: Add `(⊤ U φ)` to `deferralClosure` for each `F(φ)` in it.

**Assessment**: Adding `(⊤ U φ)` to `deferralClosure` would NOT directly help close `bx_fmcs_forward_F`. The role of `deferralClosure` is in the RESTRICTED coherence (`restricted_temporally_coherent`) — it bounds which formulas need `forward_F`. Extending it would INCREASE the set of formulas requiring `forward_F`, making the task harder.

The BX12 reduction `F(φ) → (⊤ U φ)` gives that `(⊤ U φ) ∈ MCS` whenever `F(φ) ∈ MCS`. Then `bx_until_eventuality_resolution` gives a witness BXPoint (not a chain member). The chain membership gap remains.

**The proposed approach in the task description does not directly close the sorry.** The BX12 reduction reduces `forward_F` to an Until witness, but the witness is outside the chain. To close the sorry, we need either:
1. A direct scheduling argument (Approach 1 above), or
2. Modifying the chain to be the "minimum" resolution (e.g., well-founded induction on `schedule_surjective_above`)

---

## Evidence / Examples

### BX12 Already Available
`F_imp_top_until_mcs` at `CanonicalChain.lean:65` proves `F(ψ) → (⊤ U ψ)` at MCS level. PROVED, no work needed here.

### fwd_succ_f_carry Is Proved
`fwd_succ_f_carry` at `CanonicalModel.lean:108-114` proves F-formulas persist through non-resolving steps. PROVED, this is the key building block for the scheduling induction.

### schedule_surjective_above Is Proved
`schedule_surjective_above` at `CanonicalModel.lean:44-47` guarantees any formula is eventually scheduled. PROVED.

### The Gap Is Only chain-membership
The chain at time `s = n+1` (Int) is `fwd_chain(n+1)`. If we can show `ψ ∈ fwd_chain(n+1)` and `(n+1 : Int) > t`, this closes `bx_fmcs_forward_F` for `t ≥ 0`.

For `t < 0`: the backward chain does NOT have F-formula resolution. The sorry for `bx_fmcs_forward_F` may be genuinely provable only via a workaround like:
- Establishing that for ANY MCS with `F(ψ)`, the first step of `fwd_chain` starting from it resolves ψ with probability 1 under the schedule (but probability arguments don't apply here).
- Using the fact that the BFMCS families include shifted chains — a family starting at time `t` can resolve F(ψ) at step `t+1`.

---

## Confidence Level

| Component | Assessment | Confidence |
|-----------|------------|------------|
| BX12 lemma exists | `F_imp_top_until_mcs` at line 65 | HIGH (proved) |
| fwd_chain f_carry persistence (t ≥ 0) | Can be proved by induction | HIGH |
| bx_fmcs_forward_F for t ≥ 0 | Schedulable and provable | HIGH (75%) |
| bx_fmcs_forward_F for t < 0 | Backward chain has no F-resolution | LOW (20%) |
| restricted_buc closure | Needs step transfer for Until | MEDIUM (50%) |
| restricted_fuc closure | Needs chain membership for witness | MEDIUM (40%) |
| Overall sorry closure | All 6 sorrries | MEDIUM (40%) |

---

## Open Questions

1. **Negative t case for bx_fmcs_forward_F**: Is there a way to use `connect_past` axiom (BX4': `φ → H(F(φ))`) to propagate `F(ψ)` from bwd_chain members back to `M₀`, then use the fwd_chain? Specifically: if `F(ψ) ∈ bwd_chain(k)`, does `F(ψ) ∈ M₀`? Answer: only if `G(F(ψ)) ∈ M₀`, which requires `G(F(ψ)) ∈ bwd_chain(0) = M₀`. But `bwd_chain` drops f_carry in resolving steps. Unclear.

2. **Step transfer for restricted_buc**: The step transfer `(φ U ψ) ∈ fam.mcs(r+1) ∧ φ ∈ fam.mcs r → (φ U ψ) ∈ fam.mcs r` is the key for backward Until. For the int_chain, does the seed enrichment with `untilCarry` (from Plan 08) provide this? The plan says yes (Plan 08 Phase 2) but this remains the highest-risk component.

3. **Does `(⊤ U φ)` in the seed help for forward_fuc?**: For `restricted_fuc`, given `(⊤ U ψ) ∈ fam.mcs t` (by BX12 applied to `F(ψ)`), `bx_until_eventuality_resolution` gives a witness v. If the chain happens to contain v at some step, we're done. But the scheduling approach (not BX12) is what gives chain membership.

4. **Is the strict inequality gap real?**: The BX12/Until approach gives `s ≥ t` (reflexive Until), but `restricted_temporally_coherent` requires `s > t`. Under BX8 (reflexive Until), if `ψ ∈ fam.mcs t` already, then `s = t` satisfies `s ≥ t` but not `s > t`. However, if `ψ ∉ fam.mcs t`, then the resolving step gives `s > t`. This case split: if `ψ ∈ chain(t)`, `s > t` with `ψ ∈ chain(t+1)` follows trivially (since chain(t+1) contains `fwd_succ` which has `g_content(chain(t)) ⊆ chain(t+1)`, and from `ψ ∈ chain(t)` we get `G(ψ) ∈ chain(t)` if G(ψ) ∈ chain(t)... this doesn't directly work). Actually: if `ψ ∈ chain(t)`, we still need to find `s > t` with `ψ ∈ chain(s)`. The schedule will eventually have `schedule(n) = ψ` for some `n ≥ t.toNat`, and `ψ ∈ chain(n+1)` directly. No issue.

5. **restricted_tc vs forward_F**: `bx_bfmcs_restricted_tc` (the ALREADY PROVED sorry-free version at line 603) delegates to `bx_fmcs_forward_F` (line 576). But line 603 has NO sorry — it uses `bx_fmcs_forward_F` which DOES have sorry. So fixing `bx_fmcs_forward_F` automatically closes `bx_bfmcs_restricted_tc`. This is the CORRECT priority ordering.
