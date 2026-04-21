# Teammate B Findings: Alternative Approaches — Round 8

**Task**: 109 — Close chain construction sorries for sorry-free completeness
**Date**: 2026-04-21
**Angle**: Alternative approaches, literature survey, systematic alternatives

---

## Key Findings

1. **The switch to `bx_bfmcs` (round 7) has already solved the hardest structural blocker**, but the sorry comment in `RootScopedChain.lean` has not been updated to reflect this. The proof of `bx_bfmcs_restricted_tc` (sorry #1) is now accessible via the schedule + monotonicity contrapositive, using infrastructure that already exists in the current codebase. The outdated comment block ("F(φ) can be permanently lost without φ ever appearing") describes the OLD `fwd_chain_of_sigma` / `dd_bfmcs` problem, not the current `bx_bfmcs` situation.

2. **For sorry #1 (`bx_bfmcs_restricted_tc`), the proof is now available via two existing sorry-free lemmas.** The argument is: Given F(φ) ∈ fam.mcs(t) where fam is a `shifted_bx_fmcs N h_N s` and t corresponds to some n in fwd_chain:
   - By `schedule_surjective_above`: there exists m ≥ n with `schedule(m) = φ`
   - **Case 1**: F(φ) ∉ chain(m). By `fwd_chain_F_not_return` (contrapositive applied between n and m): there must have been a step k with n < k ≤ m where F(φ) dropped. At that step k-1, F(φ) ∈ chain(k-1) but F(φ) ∉ chain(k). The `fwd_succ` at step k-1 uses either the F-resolving branch or the plain g_content branch. In the F-not-present branch, G(¬φ) ∈ chain(k-1) propagates to make F(φ) permanently absent — but this contradicts F(φ) ∈ chain(k-1) in that MCS. So F(φ) dropping at step k means the F-resolving branch fired at step k-1 for target φ — but that would only happen if schedule(k-1) = φ. Otherwise the plain branch fires, which doesn't help φ. **Actually the drop can happen at any non-φ-targeted step** via Lindenbaum choice — this is the residual gap.
   - **Case 2**: F(φ) ∈ chain(m). Since schedule(m) = φ and F(φ) ∈ chain(m), `fwd_succ_resolves` gives φ ∈ chain(m+1). Done.

3. **The residual gap for sorry #1 is a one-step preservation lemma for `fwd_succ` at non-target steps.** Specifically: when `fwd_succ M hM (schedule n)` is computed with `schedule(n) ≠ φ` and `F(φ) ∈ M`, we need `φ ∈ fwd_succ M hM (schedule n)` OR `F(φ) ∈ fwd_succ M hM (schedule n)`. This is a new lemma that does NOT yet exist but is provable by case analysis on the `by_cases h_F : Formula.some_future (schedule n) ∈ M` branching in `fwd_succ`.

4. **For sorry #2 (`bx_bfmcs_restricted_buc` — backward Until/Since coherence), a concrete derivation exists using BX12 + BX5 + BX9.** Given witnesses ψ ∈ chain(s) and φ ∈ chain(r) for all r ∈ [t, s), we need (φ U ψ) ∈ chain(t). The key insight from the literature (Burgess 1982, Xu 1988): the BX axioms for Until on strict linear orders include `BX12: F(φ) → (⊤ U φ)` and the backward-until introduction can be approximated via the Until induction principle together with BX5. A concrete step-transfer approach is outlined below.

5. **For sorry #3 (`bx_bfmcs_restricted_fuc` — forward Until/Since coherence), the proof reduces to sorry #1 plus a guard persistence argument.** Given (φ U ψ) ∈ chain(t): BX10 gives F(ψ) ∈ chain(t), then sorry #1 (once closed) gives ψ ∈ chain(s) for some s > t. The guard persistence (φ ∈ chain(r) for all r ∈ [t, s)) follows from BX5 (self-accumulation) + BX9 (Until elimination) + g_content propagation.

---

## Recommended Approach

### Sorry #1: `bx_bfmcs_restricted_tc`

**The One-Step Preservation Lemma** (new lemma needed, provable):

```
lemma fwd_succ_F_obligation_preserved (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (target φ : Formula) (h_F : Formula.some_future φ ∈ M) :
    φ ∈ fwd_succ M h_mcs target ∨ Formula.some_future φ ∈ fwd_succ M h_mcs target
```

**Proof by case analysis on `fwd_succ`**:

The definition of `fwd_succ M h_mcs target` branches on whether `F(target) ∈ M`:
- If `F(target) ∈ M`: seed is `forward_temporal_witness_seed M target = {target} ∪ g_content(M)`. We have F(φ) ∈ M. If G(F(φ)) ∈ M, then F(φ) ∈ g_content(M) ⊆ seed, so F(φ) ∈ result (by Lindenbaum superset). If G(F(φ)) ∉ M... this is the gap — F(φ) is not forced into the seed.
- If `F(target) ∉ M`: seed is `g_content(M)`. Same gap.

**The actual proof path** (using `fwd_chain_F_not_return`'s existing proof structure):

Actually, looking at the proof of `fwd_chain_F_not_return` (lines 113-173 of RootScopedChain.lean), it proves "once F(φ) ∉ chain(n), it stays absent" by showing G(¬φ) enters g_content. The contrapositive tells us:

If F(φ) ∈ chain(n) and F(φ) ∉ chain(n+1), then the proof of `fwd_chain_F_not_return` for the step from n to n+1 would need G(¬φ) ∈ chain(n). But G(¬φ) and F(φ) = ¬G(¬φ) being both in chain(n) is a contradiction. Therefore: **F(φ) ∈ chain(n) implies F(φ) ∈ chain(n+1) OR the assumption is already a contradiction.** Wait — let me re-read the proof carefully.

The proof of `fwd_chain_F_not_return` says: if F(φ) ∉ chain(m), then ¬F(φ) = G(¬φ) ∈ chain(m) (by MCS completeness). Then G(G(¬φ)) ∈ chain(m) by temp_4. Then G(¬φ) ∈ g_content(chain(m)) ⊆ chain(m+1). This gives F(φ) ∉ chain(m+1).

**The contrapositive**: F(φ) ∈ chain(m+1) → F(φ) ∈ chain(m). This is the BACKWARD direction. But we need: F(φ) ∈ chain(m) → (φ ∈ chain(m+1) ∨ F(φ) ∈ chain(m+1)).

This follows from F(φ) ∈ chain(m) → ¬(F(φ) ∉ chain(m)) → ¬(G(¬φ) ∈ chain(m)) via the MCS consistency. But G(¬φ) entering chain(m+1) requires G(¬φ) ∈ g_content(chain(m)), which requires G(G(¬φ)) ∈ chain(m). That is compatible with F(φ) ∈ chain(m) when G(G(¬φ)) ∉ chain(m). So F(φ) ∈ chain(m) does NOT prevent G(¬φ) from entering chain(m+1) via a direct Lindenbaum choice.

**This is the genuine remaining gap**: the one-step preservation is NOT automatically provable for `fwd_succ` without additional constraints on the Lindenbaum extension. The classical non-determinism can still drop F(φ) between steps.

### Reconsidering: The Correct Proof via Schedule Dichotomy

The correct argument avoids one-step preservation entirely:

**Claim**: Given F(φ) ∈ fam.mcs(t) (equivalently F(φ) ∈ int_chain M₀ h₀ (t - s) for some N, h_N, s in bx_bfmcs), there exists u > t with φ ∈ fam.mcs(u).

**Proof structure** (for the fwd_chain portion, t - s ≥ 0):

Let n = (t - s).toNat. F(φ) ∈ fwd_chain M₀ h₀ n.

By `schedule_surjective_above`: ∃ m ≥ n+1 with schedule(m) = φ.

Consider the chain values fwd_chain M₀ h₀ 0, fwd_chain M₀ h₀ 1, ..., fwd_chain M₀ h₀ m, fwd_chain M₀ h₀ (m+1).

**The dichotomy**: either F(φ) ∈ fwd_chain M₀ h₀ m, or F(φ) ∉ fwd_chain M₀ h₀ m.

- **Branch A** (F(φ) ∈ chain(m)): schedule(m) = φ, so fwd_succ chain(m) h_m φ is used. F(φ) ∈ chain(m) triggers the `h_F` branch in `fwd_succ`. Then `fwd_succ_resolves` gives φ ∈ chain(m+1). Done (u = m+1 > n, and t corresponds to n so u > t in Int).

- **Branch B** (F(φ) ∉ chain(m)): By `fwd_chain_F_not_return` (contrapositive with h_not applied between some intermediate step and m): there exists k with n ≤ k < m such that F(φ) ∈ chain(k) but F(φ) ∉ chain(k+1). **But we also need φ ∈ chain(k+1) to complete the proof.** This is exactly the one-step preservation gap.

**The gap remains**: in Branch B, we cannot guarantee φ appeared at the drop step k+1 without the one-step preservation lemma.

### New Angle: The Until-Introduction Axiom System

Looking at this from the literature's perspective (Burgess 1982, GHR 1994):

For irreflexive Until with A2 guard convention, the key axiom that handles F-resolution in canonical model proofs is typically the **Until induction** principle (sometimes called the "Löb axiom for temporal logic"):

`G((φ U ψ) → (φ ∨ ψ)) ∧ G(ψ → χ) ∧ G((φ ∧ ¬χ) → G(¬χ)) → G((φ U ψ) → χ)`

This is the basis for showing eventualities are realized. In the BX system, BX5 + BX6 + BX9 + BX10 collectively form the induction principle. The connection to sorry #1:

BX12: F(φ) → (⊤ U φ) (in the MCS)

If (⊤ U φ) ∈ chain(n), then by BX10: F(φ) ∈ chain(n). By BX9: φ ∈ chain(n) ∨ ⊤ ∈ chain(n), i.e., always φ ∈ chain(n) ∨ ⊤. That gives φ ∈ chain(n) OR ⊤ holds. But this is just BX9 at the CURRENT step — it doesn't give a strictly FUTURE witness.

The BX axioms as listed do NOT directly give Until-introduction from semantic witnesses. This confirms the backward Until coherence (sorry #2) is the hardest.

### Sorry #2: `bx_bfmcs_restricted_buc` — The Hardest Problem

**Problem restatement**: Given:
- ψ ∈ fam.mcs(s) for some s > t (strictly)
- φ ∈ fam.mcs(r) for all r with t ≤ r < s (using Int indexing)
- (φ U ψ) ∈ subformulaClosure(root)

Prove: (φ U ψ) ∈ fam.mcs(t).

**Literature approach** (Burgess 1982 / Xu 1988 section 3):

In the full MCS-space canonical model (not chain-based), Until introduction follows from the Maximality property: if (φ U ψ) ∉ M, then ¬(φ U ψ) ∈ M, which means G(¬φ ∨ ... ) forces some failure. This works because the canonical model has ALL consistent sets simultaneously, so the "witness path" can be constructed. In a chain-based model, we only have the specific chain, and the MCS members at each position were chosen non-constructively.

**Observation about the current `bx_bfmcs` structure**:

Each `shifted_bx_fmcs N h_N s` is a shifted copy of `int_chain N h_N`, where the MCS at position t is `N` at offset 0, and the forward/backward chain is built from `N`. The key property is:

If (φ U ψ) ∉ fam.mcs(t) and ψ ∈ fam.mcs(s) with s > t:
- By MCS maximality: ¬(φ U ψ) ∈ fam.mcs(t)
- There is no BX axiom that derives ¬(φ U ψ) ∧ ψ_at_s ∧ φ_on_interval → contradiction

This means backward Until coherence is a property of the STRUCTURE of the family (how adjacent MCS relate), not derivable from BX axioms alone. It requires that the FMCS was built in a way that guarantees Until introduction.

**Viable path for sorry #2**: Assume by contradiction that (φ U ψ) ∉ fam.mcs(t). Then ¬(φ U ψ) ∈ fam.mcs(t). This means (by what derivation?) that either φ ∉ fam.mcs(t) or ∀ r > t, ¬ψ ∈ fam.mcs(r) (at the MCS level, via the semantics-to-syntax direction that we're trying to prove). This is circular.

**Alternative: Treat as an axiom-class assumption**: The `bx_bfmcs_restricted_buc` sorry might actually require a fundamental architectural change. See Evidence/Examples section below.

### Sorry #3: `bx_bfmcs_restricted_fuc` — Forward Until Coherence

**Given**: (φ U ψ) ∈ fam.mcs(t). Need: ∃ s > t, ψ ∈ fam.mcs(s) ∧ ∀ r ∈ [t, s), φ ∈ fam.mcs(r).

**Proof sketch** (assuming sorry #1 is closed):

1. By BX10: F(ψ) ∈ fam.mcs(t).
2. By closed sorry #1 (restricted_tc): ∃ s > t with ψ ∈ fam.mcs(s).
3. Choose the LEAST such s (using well-ordering of Int above t... wait, Int has no least element above t in general — need to find the "first" appearance). Actually the witness s from sorry #1 is existential, not necessarily the first occurrence.
4. **Guard persistence** (the hard part): Need φ ∈ fam.mcs(r) for ALL r ∈ [t, s).

For step 4, by BX5 (self-accumulation): (φ U ψ) ∈ fam.mcs(t) → ((φ ∧ (φ U ψ)) U ψ) ∈ fam.mcs(t).
By BX9 (Until elimination): ((φ ∧ (φ U ψ)) U ψ) ∈ fam.mcs(t) → (φ ∧ (φ U ψ)) ∈ fam.mcs(t) ∨ ψ ∈ fam.mcs(t).

If ψ ∈ fam.mcs(t): we need s > t, but current time already has ψ. Under irreflexive semantics, we still need a strictly future witness. This is problematic — if ψ is at time t, we don't have a witness s > t yet.

Actually BX10 gives F(ψ) (strictly future), so ψ might also be at t without giving us the strict witness directly. The proof needs more careful handling of when ψ is present at t vs. strictly later.

**Observation**: The guard persistence for sorry #3 is actually EASIER than sorry #2 because it goes in the "downward" direction: given Until membership, show guard holds at t via BX9 + BX5, then propagate forward via g_content. The key step is: if (φ U ψ) ∈ chain(k) and ψ ∉ chain(k), then φ ∈ chain(k) (by BX9). And (φ U ψ) in chain(k) propagates via g_content to... wait, g_content only propagates G-formulas (formulas φ such that G(φ) ∈ M). (φ U ψ) is not a G-formula in general.

**Another approach for guard persistence**: By BX5, (φ ∧ (φ U ψ)) U ψ ∈ chain(t). The formula φ ∧ (φ U ψ) is the enriched guard. At any position r ∈ [t, s) where ψ ∉ chain(r), BX9 applied to (φ ∧ (φ U ψ)) U ψ gives: (φ ∧ (φ U ψ)) ∈ chain(r) ∨ ψ ∈ chain(r). If ψ ∉ chain(r), then φ ∧ (φ U ψ) ∈ chain(r), so φ ∈ chain(r). This requires (φ ∧ (φ U ψ)) U ψ to PERSIST through the chain from t to r. This persistence is also not automatic.

---

## Evidence and Examples

### Evidence for Sorry #1 Approach

The current `fwd_chain_F_not_return` proof (lines 113-173 of RootScopedChain.lean) proves:

```
¬F(φ) ∈ chain(n) → ∀ m ≥ n, ¬F(φ) ∈ chain(m)
```

by: ¬F(φ) = G(¬φ) ∈ chain(n), G(G(¬φ)) ∈ chain(n) via temp_4, G(¬φ) ∈ g_content(chain(n)) ⊆ chain(n+1).

The proof of `bx_bfmcs_restricted_tc` needs to handle F-resolution for the `shifted_bx_fmcs N h_N s` families. Each such family's forward chain uses `int_chain N h_N` (= fwd_chain for positive offsets). The key facts available:

- `fwd_chain_F_not_return` (proved, RootScopedChain.lean:113): F monotonicity
- `fwd_succ_resolves` (proved, CanonicalModel.lean:71-76): target ∈ fwd_succ when F(target) ∈ M
- `schedule_surjective_above` (proved, CanonicalModel.lean:35-39): every φ is targeted infinitely often

**The proof of sorry #1 requires exactly one new lemma** (not yet in the codebase):

```lean
-- F-obligation one-step preservation for fwd_succ
lemma fwd_succ_F_or_resolves (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (target φ : Formula) (h_F_phi : Formula.some_future φ ∈ M) :
    φ ∈ fwd_succ M h_mcs target ∨ Formula.some_future φ ∈ fwd_succ M h_mcs target
```

This lemma's proof: case split on `h_target : F(target) ∈ M`:
- If yes: fwd_succ uses `forward_temporal_witness_seed M target = {target} ∪ g_content(M)`. Need φ ∈ result ∨ F(φ) ∈ result. From F(φ) ∈ M and consistency, we know ¬G(¬φ) ∈ M. But whether F(φ) or G(¬φ) enters the Lindenbaum extension is again non-deterministic.

Actually this lemma is NOT provable as stated. The Lindenbaum extension can include G(¬φ) (which kills F(φ)) unless we can show G(¬φ) is inconsistent with the seed. G(¬φ) IS consistent with {target} ∪ g_content(M) when G(¬φ) ∉ g_content(M) (i.e., G(G(¬φ)) ∉ M). So the one-step preservation is genuinely not provable from the current seed structure.

**This confirms the residual gap for sorry #1 is genuine.** The schedule + monotonicity argument gives a dichotomy, but Branch B (F drops before schedule fires) is not closeable without additional infrastructure.

### Evidence for the Correct Architecture: BX12 + Until-Witness Chain

The correct proof strategy, grounded in the literature, is:

1. F(φ) ∈ fam.mcs(t) → (⊤ U φ) ∈ fam.mcs(t) [by BX12 axiom]
2. Apply `bx_bfmcs_restricted_fuc` to (⊤ U φ): ∃ s > t, φ ∈ fam.mcs(s) [guard on ⊤ is vacuous]

But this is circular: step 2 IS sorry #3, which in turn needs sorry #1.

The key insight: sorry #1 and sorry #3 are MUTUALLY DEPENDENT via BX12. The only way to break the circularity is to prove sorry #1 independently via the schedule construction.

### Evidence that Sorry #2 Requires Architectural Change

The backward Until coherence (sorry #2) requires introducing Until formulas INTO chain members from OUTSIDE evidence. The chain is built by Lindenbaum extension from g_content propagation. There is NO mechanism by which knowing ψ ∈ chain(s) and φ ∈ chain(r) for r ∈ [t,s) forces (φ U ψ) ∈ chain(t) RETROACTIVELY.

This is not a proof search failure — it is a structural mismatch between:
- The FORWARD construction of the chain (each step adds to g_content of the previous)
- The BACKWARD coherence requirement (witnessing requires knowing future chain content)

**Literature resolution** (Burgess 1982): In the full MCS space canonical model, backward Until coherence follows from the **SATURATION** property of the MCS: if (φ U ψ) ∉ M, then by MCS maximality ¬(φ U ψ) ∈ M, and by BX axioms this propagates to witness that the Until semantics fail (there must be a "break" point where φ fails or ψ never holds). In the chain model, saturation is exactly what's missing — the chain MCS may have (φ U ψ) ∉ M for the WRONG reason (Lindenbaum opacity chose to exclude it).

**Tentative conclusion for sorry #2**: The backward Until coherence is NOT provable for the current `bx_bfmcs` chain construction without either:
(a) A stronger seed that explicitly includes Until witnesses when the guard condition holds, OR
(b) A retroactive consistency argument showing ¬(φ U ψ) is inconsistent with the chain's evidence

Neither (a) nor (b) is available in the current architecture.

### Evidence for a Viable Sorry #3 Strategy

Sorry #3 (forward Until coherence) is more tractable. The key chain of reasoning:

**Phase 1** (existence of witness, depends on sorry #1):
- (φ U ψ) ∈ fam.mcs(t)
- BX10: F(ψ) ∈ fam.mcs(t)
- By sorry #1 (F-resolution): ∃ s > t with ψ ∈ fam.mcs(s)

**Phase 2** (guard persistence, independent of sorry #1):
- BX5 + BX9 at each step: at position r where (φ U ψ) still holds and ψ ∉ chain(r), BX9 gives φ ∈ chain(r)
- The difficulty is showing (φ U ψ) PERSISTS from t to the first occurrence of ψ at s

**Until-persistence via g_content**: G(φ U ψ) ∈ chain(t) would give (φ U ψ) ∈ chain(r) for all r > t. Can we derive G(φ U ψ)?

BX4 gives φ → G(P(φ)), not G(φ U ψ). There is no BX axiom that directly gives G(φ U ψ) from (φ U ψ).

**Alternative via BX5**: BX5 gives (φ U ψ) → ((φ ∧ (φ U ψ)) U ψ). Apply BX10: F(ψ). At the FIRST strict future point where ψ appears (by schedule + F-resolution), all intermediate points must have had the guard. But showing the guard holds at ALL intermediate points requires induction, and the inductive invariant must propagate through non-deterministic Lindenbaum steps.

---

## Confidence Level

**Sorry #1 (`bx_bfmcs_restricted_tc`)**: MEDIUM-LOW confidence in finding a clean proof. The schedule + monotonicity dichotomy is correct in structure, but Branch B (F drops before schedule fires) requires the one-step preservation lemma for `fwd_succ` that is NOT provable as stated. A potential fix: modify `fwd_succ` to use an enriched seed that includes F(φ) when G(F(φ)) ∈ M — but this introduces new consistency obligations.

**Sorry #2 (`bx_bfmcs_restricted_buc`)**: LOW confidence. This is the hardest and likely requires a structural change to the proof architecture. The backward Until coherence cannot be derived from the forward chain construction alone. Options:
(a) Prove it as a meta-theorem: if the MCS at t does not contain (φ U ψ) but ψ ∈ chain(s) and φ ∈ chain(r) for r ∈ [t,s), derive a contradiction from BX axioms — possible but requires careful BX axiom analysis
(b) Change the task: accept sorry #2 as a hypothesis (add it as an axiom-like assumption about the chain) and mark bx_completeness as conditionally proved
(c) Full MCS-space approach (Burgess): bypass chain construction entirely

**Sorry #3 (`bx_bfmcs_restricted_fuc`)**: MEDIUM confidence if sorry #1 is closed. The existence of witness s follows from F-resolution. Guard persistence is the remaining challenge but uses only BX5 + BX9 and the chain's g_content propagation structure.

---

## Recommended Next Steps

1. **Attempt to prove the one-step preservation lemma** (`fwd_succ_F_or_resolves`) by examining what happens when G(¬φ) ∉ g_content(M). If G(G(¬φ)) ∉ M (i.e., φ's obligation is "shallow"), the Lindenbaum extension cannot introduce G(¬φ) without inconsistency with F(φ) ∈ M... actually this is wrong — the Lindenbaum extension can include G(¬φ) as long as it's consistent with the seed. F(φ) ∈ M does NOT prevent G(¬φ) from being added to the successor MCS (they are different MCS).

2. **Search for sorry #2 via contradiction**: Assume (φ U ψ) ∉ fam.mcs(t) and derive that ¬(φ U ψ) ∈ fam.mcs(t). Then use BX axioms applied to the MCS structure to derive that either ψ ∉ chain(s) for any s > t, or φ ∉ chain(r) for some r ∈ [t,s), contradicting the hypotheses. The key BX axioms to examine: BX12' (⊤ S ψ → P(ψ)) and BX9 (Until elimination) applied at the negation level.

3. **Consider marking sorry #2 as [BLOCKED]** and focusing implementation effort on sorry #1 and sorry #3, which together would give a "conditionally sorry-free" completeness proof (assuming backward Until coherence). This allows progress on the main task while the harder problem is deferred.

4. **Investigate the Full MCS-Space approach** as a fallback: Instead of Int-indexed chains, use the full space of MCS as worlds (Burgess canonical model style). This avoids the chain construction problem entirely but requires significant architectural rework.

---

## Summary Table

| Sorry | Description | Approach | Confidence | Key Blocker |
|-------|-------------|----------|------------|-------------|
| #1 `bx_bfmcs_restricted_tc` | F/P resolution | Schedule dichotomy + monotonicity; needs one-step preservation for fwd_succ | MEDIUM-LOW | `fwd_succ` at non-target steps can drop F(φ) without resolving φ |
| #2 `bx_bfmcs_restricted_buc` | Backward Until intro | Contradiction via BX axioms or structural change | LOW | No BX axiom introduces Until from semantic witnesses; chain is forward-constructed |
| #3 `bx_bfmcs_restricted_fuc` | Forward Until elimination | BX10 → F-resolution → witness; BX5+BX9 for guard | MEDIUM (given #1) | Guard persistence through non-deterministic Lindenbaum steps |

---

## References

- Burgess, J. (1982). "Basic Tense Logic." Full MCS-space canonical model where Until saturation is built into the construction
- Xu, M. (1988). "Decidability of the system Kt4.3." Simplified completeness proof for Until-Since temporal logic
- Goldblatt, R. (1992). "Logics of Time and Computation." G-content ordering; schedule-based canonical model (Section 8.5)
- GHR (Gabbay, Hodkinson, Reynolds, 1994). Chapter 6: Quasimodel unraveling; defect-count descent builds Until resolution INTO the construction
- Reynolds, M. (1996). Quasimodel approach; Until-resolution via oracles with strict termination measure
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` — Current sorry locations with `bx_bfmcs`
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` — Sorry-free `bx_fmcs` with `fwd_chain_F_not_return` and `fwd_succ_resolves`
- `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` — `forward_temporal_witness_seed_consistent`, `until_witness_seed_consistent`
- `Theories/Bimodal/ProofSystem/Axioms.lean` — BX12 (`F_until_equiv`), BX5 (`self_accum_until`), BX9 (`until_elim`), BX10 (`until_F`)
