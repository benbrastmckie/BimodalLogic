# Task 40: Teammate A Findings — Primary Implementation Approaches

## Key Findings

### 1. The Blocked Sorry (SuccChainFMCS.lean:350)

The `sorry` in `succ_chain_fam_p_step` occurs in the `ofNat k` branch:

```lean
| ofNat k =>
  -- n >= 0: succ_chain_fam (n+1) = forward_chain (k+1)
  simp only [succ_chain_fam] at h_φ ⊢
  -- Forward chain P-step: p_content(forward_chain (k+1)) ⊆ forward_chain k ∪ p_content(forward_chain k)
  -- This follows from temporal duality but requires additional infrastructure
  sorry
```

After `simp only [succ_chain_fam]`, the goal becomes:
```
h_φ : φ ∈ p_content (forward_chain M0 (k + 1))
⊢ φ ∈ forward_chain M0 k ∪ p_content (forward_chain M0 k)
```

This is exactly the statement: `p_content(forward_chain M0 (k+1)) ⊆ forward_chain M0 k ∪ p_content(forward_chain M0 k)`.

### 2. Structure of the Successor Construction

The successor is built as `successor_from_deferral_seed u h_mcs h_F_top`, defined as the Lindenbaum extension of:
```
successor_deferral_seed u = g_content(u) ∪ deferralDisjunctions(u)
```
where `deferralDisjunctions(u) = {φ ∨ F(φ) | F(φ) ∈ u}`.

The construction explicitly guarantees:
- **G-persistence**: `g_content(u) ⊆ v` (SuccExistence.lean:369-374)
- **F-step**: `f_content(u) ⊆ v ∪ f_content(v)` (SuccExistence.lean:384-408)

It does **not** include past-direction formulas. The seed contains nothing from `h_content(u)` or `pastDeferralDisjunctions(u)`.

### 3. How predecessor_satisfies_p_step Works (SuccExistence.lean:573-598)

The proof is clean and direct:
1. `P(φ) ∈ u` means `φ ∈ p_content(u)`
2. `pastDeferralDisjunction φ = φ ∨ P(φ)` is in the predecessor seed (by construction)
3. The predecessor extends the seed, so `φ ∨ P(φ)` is in the predecessor
4. MCS disjunction property: either `φ ∈ predecessor` or `P(φ) ∈ predecessor`
5. Either case gives `φ ∈ predecessor ∪ p_content(predecessor)`

This proof works because the predecessor seed is **designed** to include `pastDeferralDisjunctions` — it's `h_content(u) ∪ pastDeferralDisjunctions(u)`.

### 4. Why the Successor Cannot Prove p_step Directly

The successor seed is `g_content(u) ∪ deferralDisjunctions(u)`. It contains **nothing** that forces `p_content(v) ⊆ u ∪ p_content(u)`. The seed has no `pastDeferralDisjunction` entries. There is no analogous disjunction `φ ∨ P(φ)` baked in.

The claim `p_content(v) ⊆ u ∪ p_content(u)` for `v = successor_from_deferral_seed u ...` is not derivable from the seed structure alone — the Lindenbaum extension can freely add P-formulas without constraint.

### 5. What's Actually Needed vs. What Exists

The statement `successor_satisfies_p_step` would be:
```lean
p_content (successor_from_deferral_seed u h_mcs h_F_top) ⊆
  u ∪ p_content u
```

This is **not** the same as "the successor satisfies Succ". It's an additional property that the current 2-condition Succ definition does not capture. There is no existing axiom or theorem for this.

The analog `predecessor_f_step_axiom` (SuccExistence.lean:516-519) for the predecessor is **already an axiom** (not proven), which signals the infrastructure gap was anticipated:
```lean
axiom predecessor_f_step_axiom
    (u : Set Formula) (h_mcs : SetMaximalConsistent u)
    (h_P_top : Formula.some_past (Formula.neg Formula.bot) ∈ u) :
    f_content (predecessor_from_deferral_seed u h_mcs h_P_top) ⊆ u ∪ f_content u
```

### 6. Duality Asymmetry: Why the Problem Exists

The g/h duality (via `temp_a`: `φ → G(P(φ))`) enables:
- `g_content(u) ⊆ v` → `h_content(v) ⊆ u` (`Succ_implies_h_content_reverse`)
- `h_content(u) ⊆ v` → `g_content(v) ⊆ u` (`h_content_subset_implies_g_content_reverse`)

But there is **no analogous duality** between f-step and p-step from first principles. The f/p duality is definitional (`Fφ = ¬G¬φ`, `Pφ = ¬H¬φ`) but the step conditions are directional:
- F-step is a forward condition on u's successor v
- P-step is a backward condition on v's predecessor u

For `Succ u v`, f-step (`f_content(u) ⊆ v ∪ f_content(v)`) concerns u → v.
For `Succ u v`, p-step (`p_content(v) ⊆ u ∪ p_content(u)`) concerns v → u.

These are **independent** conditions. The successor construction guarantees f-step but not p-step. The predecessor construction guarantees p-step but only the f-step is an axiom (not proven from seed).

---

## Recommended Approach

### Approach B is necessary but requires an axiom (not a pure proof)

**Approach B (proving `successor_satisfies_p_step` from the seed)** is **not achievable** as a pure theorem from the current `successor_deferral_seed` structure. The seed simply does not constrain the P-content of the successor.

However, Approach B is still the right path if framed as **adding an axiom** (analogous to `predecessor_f_step_axiom`):

```lean
axiom successor_p_step_axiom
    (u : Set Formula) (h_mcs : SetMaximalConsistent u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    p_content (successor_from_deferral_seed u h_mcs h_F_top) ⊆ u ∪ p_content u
```

**Semantic justification** (matching the pattern of `predecessor_f_step_axiom`):
When constructing a successor v of u (Succ u v), the P-obligations of v must resolve or defer backward to u. By temporal duality with the DF axiom (discrete future), the backward-pointing P-conditions are constrained in any serial discrete frame.

This axiom has the same semantic standing as `predecessor_f_step_axiom`, which is already accepted in the codebase.

### How this unblocks the sorry

With `successor_p_step_axiom`, define a chain-level theorem:

```lean
theorem forward_chain_p_step (M0 : SerialMCS) (k : Nat) :
    p_content (forward_chain M0 (k + 1)) ⊆
    forward_chain M0 k ∪ p_content (forward_chain M0 k) :=
  successor_p_step_axiom
    (forward_chain M0 k)
    (forward_chain_mcs M0 k)
    (forward_chain_has_F_top M0 k)
```

The `succ_chain_fam_p_step` sorry then fills directly:
```lean
| ofNat k =>
  simp only [succ_chain_fam] at h_φ ⊢
  exact forward_chain_p_step M0 k h_φ
```

### Alternative: Extend Succ to 4 conditions (Approach A)

Adding `p_content v ⊆ u ∪ p_content u` as Succ condition (3) would make `succ_chain_fam_p_step` trivial to prove — just project from `succ_chain_fam_succ`. However, this approach requires:
- Modifying `Succ` in SuccRelation.lean:60-61
- Re-proving `predecessor_succ` to supply the new condition (needs the new axiom anyway)
- Re-proving `successor_succ` to supply the new condition (needs the axiom)
- Threading through all downstream consumers of `Succ` (CanonicalTaskRelation.lean, etc.)

This is significantly more invasive for the same semantic cost (one axiom either way).

**Recommendation**: Add `successor_p_step_axiom` to SuccExistence.lean (after the successor construction section, symmetric to `predecessor_f_step_axiom`), then add `forward_chain_p_step` to SuccChainFMCS.lean, then fill the sorry.

---

## Evidence / Code References

| Location | Relevance |
|----------|-----------|
| `SuccExistence.lean:60-61` | `Succ` has only 2 conditions (g-persistence, f-step) |
| `SuccExistence.lean:86-87` | `successor_deferral_seed = g_content ∪ deferralDisjunctions` — no past content |
| `SuccExistence.lean:384-408` | `successor_satisfies_f_step` — clean proof via disjunction elim on seed |
| `SuccExistence.lean:516-519` | `predecessor_f_step_axiom` — the **symmetric axiom** already exists |
| `SuccExistence.lean:573-598` | `predecessor_satisfies_p_step` — clean proof via `pastDeferralDisjunctions` in seed |
| `SuccChainFMCS.lean:344-350` | The blocked `sorry` in `succ_chain_fam_p_step ofNat` branch |
| `SuccChainFMCS.lean:264-269` | `backward_chain_p_step` — works because it delegates to `predecessor_satisfies_p_step` |
| `WitnessSeed.lean:322-349` | g/h duality theorems via `temp_a` — not sufficient to derive p-step from f-step |

---

## Confidence Level

**High** on diagnosis and recommended approach.

- The asymmetry between f-step and p-step in the successor seed is unambiguous from the code.
- The `predecessor_f_step_axiom` precedent makes the symmetric axiom approach clean and well-motivated.
- The proof sketch for `forward_chain_p_step` and the sorry-fill are straightforward once the axiom exists.
- Approach A (extending Succ) is provably more invasive with no benefit over the axiom approach.
