# Teammate A Findings: Sorry Analysis and Completion Path

## Sorry Catalog

### Critical Path Sorries (block `completeness_over_Int`)

| # | File | Line(s) | Sorry | On Critical Path? | Status |
|---|------|---------|-------|-------------------|--------|
| 1 | `CanonicalConstruction.lean` | 929 | `restricted_shifted_truth_lemma` Until case | **YES — PRIMARY BLOCKER** | Needs Until truth lemma |
| 2 | `CanonicalConstruction.lean` | 930 | `restricted_shifted_truth_lemma` Since case | **YES — PRIMARY BLOCKER** | Needs Since truth lemma |

### Upstream Sorries (feed into critical path but currently bypassed)

| # | File | Line(s) | Sorry | On Critical Path? | Status |
|---|------|---------|-------|-------------------|--------|
| 3 | `CanonicalConstruction.lean` | 632 | `canonical_truth_lemma` Until case | No (bypassed by restricted version) | Same structure as #1 |
| 4 | `CanonicalConstruction.lean` | 633 | `canonical_truth_lemma` Since case | No (bypassed by restricted version) | Same structure as #2 |
| 5 | `CanonicalConstruction.lean` | 782 | `shifted_truth_lemma` Until case | No (bypassed by restricted version) | Same structure as #1 |
| 6 | `CanonicalConstruction.lean` | 783 | `shifted_truth_lemma` Since case | No (bypassed by restricted version) | Same structure as #2 |
| 7 | `CanonicalConstruction.lean` | 1041 | `restricted_tc_family_to_fmcs` forward_G | No (dead code) | Cannot propagate G across independent Lindenbaum extensions |
| 8 | `CanonicalConstruction.lean` | 1045 | `restricted_tc_family_to_fmcs` backward_H | No (dead code) | Same issue |

### Soundness Sorries (UNSOUND axioms)

| # | File | Line(s) | Sorry | On Critical Path? | Status |
|---|------|---------|-------|-------------------|--------|
| 9 | `Soundness.lean` | 520 | `until_unfold` soundness | No | UNSOUND under reflexive semantics |
| 10 | `Soundness.lean` | 522 | `until_intro` soundness | No | UNSOUND under reflexive semantics |
| 11 | `Soundness.lean` | 524 | `until_induction` soundness | No | UNSOUND under reflexive semantics |
| 12 | `Soundness.lean` | 558 | `since_unfold` soundness | No | UNSOUND under reflexive semantics |
| 13 | `Soundness.lean` | 560 | `since_intro` soundness | No | UNSOUND under reflexive semantics |
| 14 | `Soundness.lean` | 562 | `since_induction` soundness | No | UNSOUND under reflexive semantics |
| 15 | `Soundness.lean` | 747-749 | Same 3 Until axioms (dense soundness) | No | Same unsoundness |
| 16 | `Soundness.lean` | 768-770 | Same 3 Since axioms (dense soundness) | No | Same unsoundness |
| 17 | `Soundness.lean` | 848 | `temporal_duality` (frame-class restriction) | No | Intentional; architectural limitation documented |

### SuccChainFMCS Sorries (deprecated/bypassed path)

| # | File | Line(s) | Sorry | On Critical Path? | Status |
|---|------|---------|-------|-------------------|--------|
| 18 | `SuccChainFMCS.lean` | 2190 | `g_content_union_brs_consistent` multi-BRS case | No | Deprecated; dovetailed chain bypasses this |
| 19 | `SuccChainFMCS.lean` | 2212 | `augmented_seed_consistent` | No | Depends on #18; also deprecated |
| 20 | `SuccChainFMCS.lean` | 2529 | `constrained_successor_seed_restricted_consistent` (THEOREM IS FALSE) | No | **Provably false** — documented counterexample |
| 21 | `SuccChainFMCS.lean` | 5833 | `restricted_backward_bounded_witness_fueled` fuel=0 | No | Semantically unreachable (fuel always sufficient) |
| 22 | `SuccChainFMCS.lean` | 5991 | `restricted_combined_bounded_witness_fueled` fuel=0 | No | Semantically unreachable |
| 23 | `SuccChainFMCS.lean` | 6187 | `restricted_combined_bounded_witness_P_fueled` fuel=0 | No | Semantically unreachable |

### UltrafilterChain Sorries (bypassed by dovetailed path)

| # | File | Line(s) | Sorry | On Critical Path? | Status |
|---|------|---------|-------|-------------------|--------|
| 24 | `UltrafilterChain.lean` | 3762 | `succ_chain_restricted_forward_F` | No (bypassed) | Dovetailed chain has sorry-free `forward_F` |
| 25 | `UltrafilterChain.lean` | 3772 | `succ_chain_restricted_backward_P` | No (bypassed) | Dovetailed chain has sorry-free `backward_P` |

### Other Metalogic Sorries

| # | File | Line(s) | Sorry | On Critical Path? | Status |
|---|------|---------|-------|-------------------|--------|
| 26 | `Completeness.lean` | 135 | `dense_completeness_fc` | No | Separate problem (Int is not dense) |
| 27 | `Completeness.lean` | 238 | `bfmcs_from_mcs_temporally_coherent` | No (bypassed) | Old path; dovetailed path replaces this |
| 28 | `ParametricTruthLemma.lean` | 356,359 | Parametric truth lemma Until/Since | No (not on dovetailed path) | Same structure as #1/#2 |
| 29 | `ParametricTruthLemma.lean` | 512,515 | Parametric shifted truth lemma Until/Since | No | Same structure as #1/#2 |
| 30 | `RestrictedTruthLemma.lean` | 121 | `restricted_chain_G_step` | No | Dead code; documented as unnecessary |
| 31 | `RestrictedTruthLemma.lean` | 168 | `restricted_chain_H_step` | No | Dead code; zero references |
| 32 | `TruthPreservation.lean` | 263,281 | FMP truth preservation | No | Pending FMP redesign |
| 33 | `SuccChainTruth.lean` | 311 | Box backward in singleton-Omega | No | Documents why bundling is necessary |
| 34 | `SimplifiedChain.lean` | 195 | G-lift for restricted seed | No | Deprecated approach |
| 35 | `DiscreteCompleteness.lean` | 179-188 | SuccOrder/PredOrder/IsSuccArchimedean | No | Separate project (discrete timeline quotient) |

### Example/Demo Sorries (non-critical)

| # | File | Line(s) | Sorry | On Critical Path? | Status |
|---|------|---------|-------|-------------------|--------|
| 36 | `Demo.lean` | 69 | Example sorry | No | Pedagogical placeholder |
| 37 | `TemporalProofs.lean` | 180,194 | Example temporal proofs | No | Exercise placeholders |
| 38 | `ModalProofs.lean` | 168,183,196,249,256 | Example modal proofs | No | Exercise placeholders |

---

## Critical Path Analysis

### The completeness call chain

```
completeness_over_Int                          -- Completeness.lean:472
  └── dovetailed_bundle_validity_implies_provability  -- Completeness.lean:430
        ├── construct_dovetailed_bfmcs_bundle   -- sorry-free (DovetailedChain.lean)
        ├── dovetailed_bfmcs_restricted_temporally_coherent  -- sorry-free!
        │     ├── DovetailedFMCS_forward_F      -- sorry-free (dovetailed chain)
        │     └── DovetailedFMCS_backward_P     -- sorry-free (dovetailed chain)
        └── restricted_shifted_truth_lemma      -- CanonicalConstruction.lean:800
              ├── atom, bot, imp, box, all_future, all_past  -- all sorry-free
              ├── untl (Until)  → SORRY (line 929)  ← PRIMARY BLOCKER
              └── snce (Since)  → SORRY (line 930)  ← PRIMARY BLOCKER
```

The **only** remaining sorries on the critical path are the Until and Since cases of `restricted_shifted_truth_lemma`. Everything else in the chain is either sorry-free or has been successfully bypassed by the dovetailed construction.

---

## Soundness Problem Deep-Dive

### Why 6 axioms are unsound under reflexive temporal semantics

The semantic interpretation of Until is:

```
truth_at (φ U ψ) t = ∃ s ≥ t, truth ψ s ∧ ∀ r, t ≤ r ≤ s → truth φ r
```

Key: This uses **weak inequality** (`t ≤ s`, `t ≤ r`), meaning `t` itself is included in both the witness range and the guard range. This is the "reflexive" semantics.

#### `until_unfold`: `(φ U ψ) → ψ ∨ (φ ∧ G(φ U ψ))`

**Unsound** because the deferral case requires `G(φ U ψ)`, meaning `(φ U ψ)` at ALL future times. But the original `(φ U ψ)` only guarantees a witness in `[t, s_w]`. For `s > s_w`, there's no guarantee that `(φ U ψ)` holds.

**Counterexample**: φ=⊤ on {0,1}, ψ at {1}, φ=⊥ at {2+}. Then `(φ U ψ)(0)` holds (witness s=1) but `G(φ U ψ)(0)` fails because at time 2, there's no future witness for ψ where φ holds in between.

#### `until_intro`: `ψ ∨ (φ ∧ G(φ U ψ)) → (φ U ψ)`

**Unsound** because `ψ(t)` alone doesn't give `(φ U ψ)(t)` under reflexive semantics. The semantic definition requires `∀ r, t ≤ r ≤ s → truth φ r`, and with s=t (the ψ-at-t witness), this requires `φ(t)`. But `ψ(t)` doesn't imply `φ(t)`.

#### `until_induction`: `G(ψ → χ) ∧ G((φ ∧ χ) → G(χ)) → ((φ U ψ) → χ)`

**Unsound** because the induction premise `G((φ ∧ χ) → G(χ))` only gives forward propagation: if χ holds and φ holds, then χ holds at all future times. But this doesn't give χ at the *current* time t from the Until witness.

### Critical observation: Unsoundness does NOT block completeness

The soundness sorries are on the **soundness** theorem, not the **completeness** theorem. The completeness proof uses these axioms *syntactically* within MCS reasoning:

1. `until_induction` is used in `until_witness_seed_consistent` (WitnessSeed.lean:340-474) to prove that `{ψ} ∪ g_content(M)` is consistent when `(φ U ψ) ∈ M`. This proof is **sorry-free** — it operates purely within the proof system.

2. `canonical_forward_U` (CanonicalFrame.lean:205) uses `until_witness_seed_consistent` to build a witness MCS where ψ holds. This is also **sorry-free**.

3. The dovetailed chain's `forward_dovetailed_forward_F` (DovetailedChain.lean:661) uses Until persistence to resolve F-obligations. This is **sorry-free**.

**The unsound axioms are only a problem for the soundness direction.** For completeness, the axioms work as intended as syntactic proof rules within MCS theory. If the axioms are reformulated (a separate task), the soundness sorries can be filled without affecting the completeness path.

---

## Truth Lemma Completion Strategy

### What the Until case needs (line 929)

The goal at `restricted_shifted_truth_lemma` Until case is:

```
⊢ (φ.untl ψ) ∈ fam.mcs t ↔ truth_at CanonicalTaskModel (ShiftClosedCanonicalOmega B) (to_history fam) t (φ.untl ψ)
```

Expanding the semantics:

```
(φ U ψ) ∈ fam.mcs t ↔ ∃ s ≥ t, truth_at ... s ψ ∧ ∀ r, t ≤ r ≤ s → truth_at ... r φ
```

#### Forward direction: `(φ U ψ) ∈ fam.mcs t → ∃ s ≥ t, ...`

**Strategy**: Use `until_unfold` to decompose `(φ U ψ)` in the MCS:
- Either `ψ ∈ fam.mcs t` (base case: witness s=t, use IH on ψ)
- Or `φ ∈ fam.mcs t ∧ G(φ U ψ) ∈ fam.mcs t` (deferral case)

In the deferral case, `G(φ U ψ) ∈ fam.mcs t` means `(φ U ψ) ∈ fam.mcs s` for all `s ≥ t` (by `forward_G`). But we need to find a *specific* witness where ψ holds.

**Key mechanism**: The dovetailed chain guarantees that `F(ψ)` obligations are resolved. If `(φ U ψ) ∈ fam.mcs t`, then by `until_implies_F_in_mcs` (which uses until_induction with χ=⊥), either ψ eventually appears, or `(φ U ψ)` persists forever — but the latter leads to `F(ψ)` being permanently unresolved, contradicting the dovetailed chain's fair scheduling.

**Problem**: The `restricted_shifted_truth_lemma` works at the BFMCS level (multiple families), not directly at the dovetailed chain level. The `forward_G` property of the FMCS gives `(φ U ψ) ∈ fam.mcs s` for all `s ≥ t`, and the restricted temporal coherence gives F-witness resolution. But we need to thread this through the semantics.

**Concrete approach**:
1. From `(φ U ψ) ∈ fam.mcs t`, derive `F(ψ) ∈ fam.mcs t` (via `until_implies_F_in_mcs`, sorry-free)
2. By restricted temporal coherence (forward_F), `∃ s ≥ t, ψ ∈ fam.mcs s`
3. By IH on ψ: `truth_at ... s ψ`
4. For the guard: between t and s, need `φ` true at all intermediate points
5. By `until_unfold` at each intermediate r: either `ψ ∈ fam.mcs r` (but we chose s as first witness) or `φ ∈ fam.mcs r`
6. By IH on φ: `truth_at ... r φ`

**Challenge in step 5**: We need ψ NOT in fam.mcs r for r < s, or at least φ in fam.mcs r. The `until_unfold` axiom gives `ψ ∨ (φ ∧ G(φ U ψ))`. If ψ holds at r < s, we can take r as the witness instead. If not, φ holds at r.

**Actually, we can take the EARLIEST witness**: Let s₀ be the smallest s ≥ t with ψ ∈ fam.mcs s. Then for all r with t ≤ r < s₀, ψ ∉ fam.mcs r, so by until_unfold, φ ∈ fam.mcs r. Also at s₀, by until_unfold, either ψ ∈ fam.mcs s₀ (yes, our witness) — but we also need φ at s₀ for the closed-interval semantics (t ≤ r ≤ s).

**Subtlety**: The semantic definition requires `∀ r, t ≤ r ≤ s → truth φ r`. This includes r = s. But at s, we have ψ, and until_unfold gives `ψ ∨ (φ ∧ G(φ U ψ))`. If ψ holds, that tells us nothing about φ at s.

**Resolution**: Look at the semantic definition more carefully:
```
| Formula.untl φ ψ => ∃ s : D, t ≤ s ∧ truth_at ... s ψ ∧ ∀ r : D, t ≤ r → r ≤ s → truth_at ... r φ
```
The guard requires φ at ALL r in [t, s], including s itself. So we need both `ψ(s)` and `φ(s)`.

This is achievable: at s₀ (first witness), `(φ U ψ) ∈ fam.mcs s₀` (by forward_G from t to s₀), and `ψ ∈ fam.mcs s₀`. By until_unfold: `ψ ∨ (φ ∧ G(φ U ψ))`. Since ψ holds, the disjunct is true. But we also need φ.

**Alternative**: Use `until_connectedness` axiom: `φ ∧ (χ U ψ) → χ U (ψ ∧ (φ U ψ))`. This doesn't directly help.

**Better approach**: The "first witness" argument may need refinement. The issue is that the MCS contains ALL formulas or their negations. At the witness s₀ where ψ ∈ fam.mcs s₀, we also have `(φ U ψ) ∈ fam.mcs s₀` (by forward_G). By until_unfold, we get the disjunction. But the disjunction doesn't force φ(s₀).

**Wait — re-examine the semantics**: Under reflexive semantics with `t ≤ r ≤ s` requiring φ, the "weak until" variant doesn't need φ at the witness point. Let me re-check...

The definition says: `∃ s, t ≤ s ∧ truth ψ s ∧ ∀ r, t ≤ r → r ≤ s → truth φ r`

So `∀ r, t ≤ r ∧ r ≤ s → truth φ r`. With r=s: need `truth φ s`. With r=t: need `truth φ t`. The guard covers the full closed interval [t,s] including endpoints.

This means semantically, `(φ U ψ)(t)` requires: ∃ s ≥ t with ψ(s) and φ on all of [t,s].

For the MCS-to-semantics direction: We need `φ ∈ fam.mcs r` for all `r ∈ [t,s]`. At s₀, we have `(φ U ψ) ∈ fam.mcs s₀` (by G-propagation since `G(φ U ψ) ∈ fam.mcs t` in the deferral case). By until_unfold at s₀: `ψ(s₀) ∨ (φ(s₀) ∧ G(φ U ψ)(s₀))`. Since ψ ∈ fam.mcs s₀, the first disjunct fires... but this gives us NO information about φ(s₀).

**This is the core difficulty.** The axiom `until_unfold` only gives `ψ ∨ (φ ∧ G(φ U ψ))`, so at the witness point, we get ψ but not necessarily φ.

**Solution approaches**:

1. **Weaken the semantic definition** to half-open interval `[t, s)` instead of `[t, s]`. Then φ at s is not needed. But this changes the semantics everywhere.

2. **Strengthen the axioms** to match the closed-interval semantics. E.g., `until_unfold` should be: `(φ U ψ) → (ψ ∧ φ) ∨ (φ ∧ G(φ U ψ))`. This ensures φ holds at the base case too.

3. **Use a different decomposition**. Instead of until_unfold, use the syntactic content of the MCS directly. If `(φ U ψ) ∈ M` where M is MCS, we can derive properties of φ and ψ within M using the proof system.

4. **Change the forward direction proof to not rely on until_unfold.** Instead, use the restricted temporal coherence to get the witness, and use the proof system properties to establish the guard.

**Recommended approach**: Option 2 (fix axioms) combined with a semantic adjustment if needed. The `until_unfold` axiom as stated is genuinely unsound, and the forward truth lemma direction relies on a decomposition that the current axioms don't cleanly support. Fixing the axioms to match the reflexive semantics is the right solution.

#### Backward direction: `∃ s ≥ t, truth ψ s ∧ ∀ r ∈ [t,s], truth φ r → (φ U ψ) ∈ fam.mcs t`

**Strategy**: Given a semantic witness (s, truth of ψ at s, truth of φ on [t,s]):
1. By IH on ψ: `ψ ∈ fam.mcs s`
2. By IH on φ for each r: `φ ∈ fam.mcs r` for all r ∈ [t,s]
3. Need to derive `(φ U ψ) ∈ fam.mcs t` from these MCS memberships

This requires `until_intro`: `ψ ∨ (φ ∧ G(φ U ψ)) → (φ U ψ)`.

**But until_intro is marked UNSOUND.** Does the backward direction use it?

Yes: the standard backward argument would be:
- If s = t: ψ ∈ fam.mcs t and φ ∈ fam.mcs t, apply until_intro (ψ case)
- If s > t: φ ∈ fam.mcs t, and by induction hypothesis (φ U ψ) ∈ fam.mcs (t+1), hence G(φ U ψ) ∈ fam.mcs t (needs backward G argument), then apply until_intro (φ ∧ G(φ U ψ) case)

**Problem**: until_intro `ψ → (φ U ψ)` is unsound because it doesn't require φ(t). But in the backward direction, we DO have φ(t) from the semantic hypothesis (φ on [t,s] includes t). So we could use a strengthened version: `(ψ ∧ φ) → (φ U ψ)`. But the current axiom accepts bare ψ.

**For the backward direction**: The axiom's unsoundness (accepting bare ψ without φ) is actually stronger than what we need. Since we have both ψ and φ at the witness, the axiom would work. The issue is only with SOUNDNESS (the axiom proves too much), not with COMPLETENESS (it proves enough).

Actually wait — the axiom being unsound means it proves things that are not semantically valid. For completeness, we need: if something is valid, it's provable. The axiom being too strong (proving invalid things) doesn't block completeness — it blocks soundness. So **until_intro's unsoundness does NOT block the backward direction of the truth lemma**.

We can use until_intro freely in MCS reasoning for completeness. The only issue is that the final `completeness_over_Int` theorem's statement says `valid_over Int φ → provable φ`, and if the proof system is unsound, then some provable φ might not be valid. But that's a soundness problem, not a completeness problem.

**Revised backward direction strategy**:
- s = t: Use `until_intro` with ψ case. `ψ ∈ fam.mcs t` → `(φ U ψ) ∈ fam.mcs t`.
- s > t: Induction on (s - t). At each step, use `until_intro` with the `φ ∧ G(φ U ψ)` case. Need `G(φ U ψ) ∈ fam.mcs t`, which requires `(φ U ψ) ∈ fam.mcs r` for all r ≥ t — this comes from the induction hypothesis applied at t+1.

**But wait**: G is "forall future" under reflexive semantics. `G(φ U ψ) ∈ fam.mcs t` means `(φ U ψ) ∈ fam.mcs s` for all s ≥ t. We'd need to prove this via backward_G (the temporal backward G function). The restricted_temporal_backward_G function requires showing `(φ U ψ) ∈ fam.mcs s` for ALL s ≥ t, not just s > t. This is circular.

**Alternative backward approach**: Use well-founded induction on the interval [t, s_witness]. At the witness s: ψ ∈ fam.mcs s, so by until_intro, (φ U ψ) ∈ fam.mcs s. At s-1: φ ∈ fam.mcs (s-1), and (φ U ψ) ∈ fam.mcs s means G(φ U ψ) ∈ fam.mcs (s-1)? No — G(φ U ψ) ∈ fam.mcs (s-1) means (φ U ψ) at all times ≥ s-1, we only have it at s.

**The backward direction is genuinely hard.** It requires showing (φ U ψ) at t given witnesses, and the standard approach uses strong induction backward from s to t. At each step k (going from s down to t):
- If k = s: ψ ∈ fam.mcs s, use until_intro
- If k < s: φ ∈ fam.mcs k, and (φ U ψ) ∈ fam.mcs (k+1) by IH. We need (φ U ψ) ∈ fam.mcs k.

To get (φ U ψ) ∈ fam.mcs k from φ ∈ fam.mcs k and (φ U ψ) ∈ fam.mcs (k+1):
- We need until_intro's second disjunct: `φ ∧ G(φ U ψ) → (φ U ψ)`
- `G(φ U ψ) ∈ fam.mcs k` would need (φ U ψ) at ALL times ≥ k, but we only have it at k+1, k+2, ..., s (by IH from s down). We don't have it at k (that's what we're trying to prove) or at times > s.

**This doesn't work with G.** The issue is that `G(φ U ψ)` is too strong — it asserts φ U ψ at all future times, not just at k+1.

**What works instead**: A specialized axiom like:
`φ(t) ∧ (φ U ψ)(t+1) → (φ U ψ)(t)` (discrete step)

But this project uses reflexive G semantics where `G` means "all times ≥ t" (weak inequality). There's no discrete successor axiom for Until.

**The fundamental issue**: The backward direction requires an induction principle that matches the closed-interval semantics. The current `until_intro` axiom uses G (all future times), which is too strong for a finite backward induction.

### Key insight for resolution

The reflexive semantics with closed intervals creates a mismatch with the standard Burgess-Xu axiomatization, which was designed for **strict** temporal ordering (`<` rather than `≤`). Under strict ordering:
- `G(φ)` means φ at all strictly future times
- `(φ U ψ)(t)` means ∃ s > t with ψ(s) and φ on (t, s]
- `until_intro`: `ψ → (φ U ψ)` is sound because the guard interval (t, s] is empty when s=t (there's no r with t < r ≤ t)

The project uses **reflexive** (weak) ordering throughout, which changes the semantics fundamentally. The axioms need reformulation to match.

---

## Recommendations

### 1. PRIMARY: Fix axiom semantics alignment (blocks everything)

The root cause of both the soundness sorries AND the truth lemma difficulties is the mismatch between reflexive temporal semantics and strict-ordering axioms.

**Two options**:

**Option A — Switch to strict temporal semantics for Until/Since**:
Change truth_at to:
```
| Formula.untl φ ψ => ∃ s, t < s ∧ truth ψ s ∧ ∀ r, t < r → r < s → truth φ r
```
This makes the Burgess-Xu axioms sound, and the truth lemma follows standard arguments. **Risk**: Requires updating ALL semantic proofs, F/P equivalences, and the dovetailed chain.

**Option B — Reformulate axioms for reflexive semantics**:
Replace the 6 unsound axioms with reflexive-compatible versions:
- `until_unfold`: `(φ U ψ) → (ψ ∧ φ) ∨ (φ ∧ G(φ U ψ))` (add φ to base case)
- `until_intro`: `(ψ ∧ φ) ∨ (φ ∧ G(φ U ψ)) → (φ U ψ)` (require φ ∧ ψ)
- `until_induction`: reformulate to match reflexive intervals

**Recommendation**: **Option A is safer.** The standard literature on Until uses strict ordering. The reflexive semantics was a design choice for G/H (where it simplifies seriality), but Until/Since work better with strict ordering. Since Until/Since are new additions (this task), changing their semantics is low-risk.

### 2. SECONDARY: Fill truth lemma sorries (after axiom fix)

Once the axiom/semantics alignment is fixed, the truth lemma Until/Since cases should follow the standard pattern:
- Forward: decompose via until_unfold, use dovetailed chain's F-resolution for witness
- Backward: induction on witness distance, use until_intro

### 3. NON-CRITICAL: Soundness sorries will resolve with axiom fix

The 12 soundness sorries (#9-16) will become provable once axioms match the semantics.

### 4. LOW-PRIORITY: Fuel=0 unreachable branches (#21-23)

These are semantically unreachable. Could be filled with `absurd` if we prove the fuel bound is always sufficient, or left as documentation.

### 5. OUT OF SCOPE: Dense completeness, discrete timeline, FMP

Sorries #26, #32, #35 are separate projects.

---

## Summary

| Category | Count | Blocks completeness? |
|----------|-------|---------------------|
| Critical path (truth lemma U/S) | 2 | **YES** |
| Soundness (unsound axioms) | 12 | No (soundness direction only) |
| Bypassed paths (old chain) | 9 | No (dovetailed chain bypasses) |
| Dead code | 4 | No |
| Semantically unreachable | 3 | No |
| Separate projects | 3 | No |
| Examples/demos | 7 | No |
| **Total** | **~40** | |

The single blocker for `completeness_over_Int` is the Until/Since cases of `restricted_shifted_truth_lemma` (2 sorries), and the root cause is the mismatch between reflexive temporal semantics and strict-ordering axioms.
