# Task 40 - Teammate B Findings: Alternative Patterns and Prior Art

## Key Findings

### 1. The Exact Gap: One `sorry` in `succ_chain_fam_p_step`

The sole blocking `sorry` for the `ofNat k` case lives at
`Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean:350`:

```lean
theorem succ_chain_fam_p_step (M0 : SerialMCS) (n : Int) :
    p_content (succ_chain_fam M0 (n + 1)) ⊆
    (succ_chain_fam M0 n) ∪ p_content (succ_chain_fam M0 n) := by
  intro φ h_φ
  cases n with
  | ofNat k =>
    -- n >= 0: succ_chain_fam (n+1) = forward_chain (k+1)
    -- This requires successor_satisfies_p_step which is not yet proven
    simp only [succ_chain_fam] at h_φ ⊢
    sorry     -- <-- THE GAP
  | negSucc k => ...  -- backward case: uses predecessor_satisfies_p_step (proven)
```

The `negSucc` cases are fully proven via `backward_chain_p_step`, which delegates to
`predecessor_satisfies_p_step` (fully proven in `SuccExistence.lean:573–598`).

### 2. What Is Actually Needed

The missing property is:

```
p_content (forward_chain M0 (k+1)) ⊆
  (forward_chain M0 k) ∪ p_content (forward_chain M0 k)
```

That is, the **forward-constructed** successor `v = successor_from_deferral_seed u` must
satisfy `p_content v ⊆ u ∪ p_content u` (P-step backward through a forward-built pair).

### 3. Where the Chain Terminates

The sorry cascades to one dependent proof:
`succ_chain_canonicalTask_backward_MCS_P_from` (SuccChainFMCS.lean:742),
which internally calls `succ_chain_fam_p_step` (line 803).
All higher-level uses ultimately depend on this cascade. No other `sorry` block
in the production code depends on `successor_satisfies_p_step`.

---

## Alternative Approaches Evaluated

### Approach B: Prove `successor_satisfies_p_step` from the deferral seed structure

**Assessment: Medium Confidence — possible but not trivial.**

The `successor_from_deferral_seed u` is defined as:

```
Lindenbaum( g_content(u) ∪ {φ ∨ F(φ) | F(φ) ∈ u} )
```

The P-step condition requires: for any `φ` with `P(φ) ∈ v`, either `φ ∈ u` or `P(φ) ∈ u`.

The forward seed has **no past-direction content** — it does not include `h_content(u)` or any
`pastDeferralDisjunctions`. The seed says nothing directly about P-obligations in the extension.

However, there is a semantic argument:
- `P(φ) ∈ v` means `¬H(¬φ) ∈ v`.
- We have `g_content(u) ⊆ v` (from the seed), so via g/h duality
  (`g_content_subset_implies_h_content_reverse`), `h_content(v) ⊆ u`.
- If `H(¬φ) ∈ v` then `¬φ ∈ u`, giving `φ ∉ u`. But we don't have `H(¬φ) ∈ v`; we have its
  negation.
- The contrapositive approach: suppose `φ ∉ u` and `P(φ) ∉ u`. Can we derive `P(φ) ∉ v`?
  Not directly from the forward seed alone.

A promising path uses the axiom `temp_a` (φ → G(P(φ))): if `P(φ) ∉ u`, then by MCS
maximality `¬P(φ) ∈ u`, i.e., `H(¬φ) ∈ u`. Since `H(¬φ) ∈ u` means `¬φ ∈ h_content(u)`.
But `h_content(u)` is **not** in the forward seed. The duality theorem
`h_content_subset_implies_g_content_reverse` goes the other direction.

**Conclusion for Approach B**: The forward seed does not directly encode P-step. A proof
would need to derive it indirectly from axioms (temp_a / past_temp_a). This seems doable
but requires non-trivial axiomatic reasoning not already present in `SuccExistence.lean`.

### Approach A: Extend Succ to a 4-Condition Relation

**Definition change:**

```lean
def Succ (u v : Set Formula) : Prop :=
  g_content u ⊆ v        -- (1) G-persistence
  ∧ f_content u ⊆ v ∪ f_content v  -- (2) F-step
  ∧ h_content v ⊆ u      -- (3) H-persistence backward
  ∧ p_content v ⊆ u ∪ p_content u  -- (4) P-step
```

Note: Condition (3) is already derivable from (1) via duality (proven as
`Succ_implies_h_content_reverse` in `SuccRelation.lean:103`), so adding it is redundant
but harmless. Condition (4) is the critical addition.

**Impact Analysis — files that must change:**

| File | Change Required | Scope |
|------|----------------|-------|
| `SuccRelation.lean` | Add conditions (3) and (4); new accessors | Minor |
| `SuccExistence.lean` | `successor_succ` must prove condition (4) | **Major** |
| `SuccExistence.lean` | `predecessor_succ` must prove conditions (3) and (4) | Moderate |
| `SuccChainFMCS.lean` | `forward_chain_succ` / `backward_chain_pred` must supply (4) | Upstream of gap |
| `CanonicalTaskRelation.lean` | No change — `h_p_step` already in `step` constructor | None |
| `SuccChainTruth.lean` | No change to existing proofs | None |
| `SuccChainWorldHistory.lean` | No change — `backward_chain_p_step` already proven | None |
| `Completeness/SuccChainCompleteness.lean` | No change | None |

The most painful change is in `SuccExistence.lean`. The current
`successor_succ` proof is:

```lean
theorem successor_succ ... :
    Succ u (successor_from_deferral_seed u h_mcs h_F_top) :=
  ⟨successor_satisfies_g_persistence ...,
   successor_satisfies_f_step ...⟩
```

To add condition (4), we need `successor_satisfies_p_step` — which is exactly the theorem
that is currently unproven (the sorry target). So Approach A does not avoid the hard
proof; it just moves the sorry to a slightly different location.

**Key observation**: Conditions (3) and (4) on `Succ u v` have different proof sources:
- Condition (3) is proven from (1) via `g_content_subset_implies_h_content_reverse` — **free**.
- Condition (4) for **backward-constructed** predecessors is proven via
  `predecessor_satisfies_p_step` — **already done**.
- Condition (4) for **forward-constructed** successors — **unproven**, same gap as Approach B.

---

## Symmetry Exploitation

The codebase has near-perfect symmetry between the future and past directions. Evidence:

| Future | Past |
|--------|------|
| `g_content` | `h_content` |
| `f_content` | `p_content` |
| `deferralDisjunctions` | `pastDeferralDisjunctions` |
| `successor_deferral_seed` | `predecessor_deferral_seed` |
| `successor_from_deferral_seed` | `predecessor_from_deferral_seed` |
| `successor_satisfies_f_step` | `predecessor_satisfies_p_step` ✓ |
| (missing) `successor_satisfies_p_step` | (missing) `predecessor_satisfies_f_step` |
| `G_neg_implies_not_F` | `H_neg_implies_not_P` |
| `neg_FF_implies_GG_neg_in_mcs` | `neg_PP_implies_HH_neg_in_mcs` |
| `single_step_forcing` | `single_step_forcing_past` |
| `temp_a` (φ → G(P(φ))) | `past_temp_a` (φ → H(F(φ))) |

The pattern for `predecessor_satisfies_p_step` (proven) is:
1. `P(φ) ∈ u` → `pastDeferralDisjunction φ = φ ∨ P(φ) ∈ predecessor_deferral_seed u`
2. Lindenbaum extension contains the seed
3. MCS disjunction property → `φ ∈ predecessor` or `P(φ) ∈ predecessor`
4. Done.

The **analog** `successor_satisfies_p_step` would state:
```
p_content (successor_from_deferral_seed u ...) ⊆ u ∪ p_content u
```

This says: the **forward-built** successor `v` satisfies P-step going **back** to `u`.

The predecessor construction achieves `predecessor_satisfies_p_step` because
`pastDeferralDisjunctions(u)` is **baked into the predecessor seed**. By symmetry,
to get `successor_satisfies_p_step`, we would need to bake `h_content(v)` or
`pastDeferralDisjunctions(v)` into the **successor** seed — but `v` doesn't exist yet
when constructing the seed from `u`.

**This asymmetry is fundamental**: the successor seed can encode forward-direction obligations
(F-step) from the source world `u`, but cannot easily encode backward-direction obligations
(P-step) for the not-yet-known target world `v`.

---

## Impact Analysis for Approach A (Extending Succ)

### Proofs That Use `Succ` Directly

Searched all `.lean` files matching `Succ` in `Theories/`:

**Critical proofs of `Succ u v`** (must establish all 4 conditions):
1. `successor_succ` (SuccExistence.lean:413) — needs new P-step proof
2. `predecessor_succ` (SuccExistence.lean:524) — can add (4) from `predecessor_satisfies_p_step`

**Proofs that consume `Succ`** (need updated accessors):
3. `Succ_implies_CanonicalR` — unchanged (uses condition 1 only)
4. `Succ_implies_h_content_reverse` — unchanged (uses condition 1 via duality)
5. `single_step_forcing` — unchanged (uses conditions 1 and 2)
6. `single_step_forcing_past` — unchanged (uses condition 1 + externally provided P-step)
7. `succ_chain_fam_succ` (SuccChainFMCS.lean:276) — unchanged structurally
8. `forward_chain_succ` (SuccChainFMCS.lean:192) — would now implicitly provide P-step
9. `backward_chain_pred` (SuccChainFMCS.lean:252) — would now implicitly provide P-step

**The key benefit of Approach A**: once `Succ` carries P-step, the `CanonicalTask_backward_MCS_P.step`
constructor could extract it from `h_succ.4` instead of needing a separate `h_p_step` argument.
This would simplify `succ_chain_fam_p_step` — the sorry becomes trivial:
```lean
| ofNat k =>
  exact (succ_chain_fam_succ M0 (Int.ofNat k)).4 h_φ
```

**But** this just pushes the sorry to `successor_succ` needing to prove `successor_satisfies_p_step`.

### Estimate of Total Proof Changes

- **Lines added**: ~50–80 (new accessors, 4-condition constructor, `successor_satisfies_p_step`)
- **Lines changed**: ~20 (update `Succ` definition, update two `⟨..., ...⟩` constructor sites)
- **Proof repair**: Minimal — all existing proofs access Succ via projections `.1`, `.2` or
  named accessors (`g_persistence`, `f_step`). Adding conditions (3) and (4) doesn't break
  existing proofs as long as constructors are updated.

---

## Alternative Definitions

### Alt-1: Axiomatize `successor_satisfies_p_step` (Matching Existing Pattern)

The codebase already uses axioms for semantically justified but hard-to-prove properties:
- `successor_deferral_seed_consistent_axiom`
- `predecessor_deferral_seed_consistent_axiom`
- `predecessor_f_step_axiom`
- `p_nesting_boundary`

Following this pattern, one could add:

```lean
axiom successor_satisfies_p_step_axiom
    (u : Set Formula) (h_mcs : SetMaximalConsistent u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    p_content (successor_from_deferral_seed u h_mcs h_F_top) ⊆ u ∪ p_content u
```

**Semantic justification**: In a discrete linear frame where `Succ u v`, the P-obligations
in `v` must resolve to `u` or remain as P-obligations in `u`, by the frame condition that
`v`'s past witnesses are at `u` or earlier.

This pattern already exists for the dual: `predecessor_f_step_axiom` does exactly the
symmetric thing for the predecessor.

**Confidence: High** — this is the minimal-disruption approach, consistent with existing
axiom usage, and semantically sound.

### Alt-2: 4-Condition Succ Without Extending the Relation

Keep `Succ` as a 2-condition relation but add a separate `SuccFull` predicate:

```lean
def SuccFull (u v : Set Formula) : Prop :=
  Succ u v ∧ h_content v ⊆ u ∧ p_content v ⊆ u ∪ p_content u
```

Prove `SuccFull` for the specific `succ_chain_fam` pairs without changing `Succ`.
This is more surgical but adds an indirection layer.

### Alt-3: Reformulate the Successor Seed to Include Past Obligations

Extend the successor seed to:

```
g_content(u) ∪ deferralDisjunctions(u) ∪ h_content_formulas_needed
```

But this is circular: h_content of `v` is not available before `v` is constructed.
This approach is **not viable**.

---

## Evidence / Code References

| Claim | Location |
|-------|----------|
| Succ 2-condition definition | `SuccRelation.lean:60–61` |
| `predecessor_satisfies_p_step` (proven) | `SuccExistence.lean:573–598` |
| The sorry gap | `SuccChainFMCS.lean:350` |
| `backward_chain_p_step` uses predecessor's p_step | `SuccChainFMCS.lean:264–270` |
| `predecessor_f_step_axiom` (analogous axiom pattern) | `SuccExistence.lean:516–519` |
| `single_step_forcing_past` requires P-step as explicit arg | `SuccRelation.lean:360` |
| `CanonicalTask_backward_MCS_P` requires P-step in step | `CanonicalTaskRelation.lean:631` |
| g/h duality: g_content ⊆ implies h_content reverse | `WitnessSeed.lean:324–350` |
| Symmetry: all future/past pairs are mirrored | `SuccRelation.lean:272–503` |

---

## Confidence Level

- **Gap identification**: High — single `sorry` at SuccChainFMCS.lean:350, forward case only
- **Approach A (extend Succ) impact**: High — requires `successor_satisfies_p_step` regardless
- **Approach B (prove from seed)**: Medium — indirect derivation via axioms possible but non-trivial
- **Alt-1 (axiom pattern)**: High — semantically sound, consistent with existing codebase pattern
- **Symmetry observation (asymmetry is fundamental)**: High — forward seed cannot encode P-step for v
- **Best recommendation**: Alt-1 (add `successor_satisfies_p_step_axiom`) mirrors existing
  `predecessor_f_step_axiom` exactly, resolves the sorry with minimal disruption, and is
  consistent with the project's approach to semantic justification of hard completeness properties
