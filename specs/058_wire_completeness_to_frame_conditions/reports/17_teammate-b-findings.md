# Teammate B Findings: Lean Implementation Patterns for Bundle Truth Lemma

**Task 58**: Wire completeness to frame conditions
**Research Angle**: Lean 4 implementation — connecting BFMCS_Bundle to valid_over semantics

---

## Executive Summary

- The `parametric_shifted_truth_lemma` (ParametricTruthLemma.lean:325) is a complete, working truth lemma for `BFMCS D` but requires `B.temporally_coherent` which demands **same-family** F/P witnesses. The `BFMCS_Bundle` structure only has **bundle-level** F/P witnesses.

- There is a single, well-defined structural gap: `BFMCS_Bundle` has `bundle_forward_F`/`bundle_backward_P` but the truth lemma's G/H backward cases call `temporal_backward_G`/`temporal_backward_H` which require a `TemporalCoherentFamily` — a family where witnesses stay in the same FMCS.

- The `valid_over Int` definition (Validity.lean:53) requires a `TaskFrame Int` and `TaskModel`, a `WorldHistory`, and a shift-closed `Omega`. The `ParametricCanonicalTaskFrame Int` already satisfies this — it uses `ParametricCanonicalWorldState` (MCS subtypes) and is already a valid `TaskFrame Int`.

- The correct implementation path is a **new bundle-level truth lemma** (`bundle_shifted_truth_lemma`) that operates on `BFMCS_Bundle` instead of `BFMCS`, replacing the G/H backward cases with bundle-level contraposition. This is not a replacement of existing infrastructure — it is a parallel variant using weaker temporal hypotheses.

- The remaining sorry in `bundle_validity_implies_provability` (Completeness.lean:186) is genuine model-theoretic glue: it needs to instantiate `valid_over Int φ` at the `ParametricCanonicalTaskFrame Int` with `ShiftClosedParametricCanonicalOmega` as `Omega`, then apply the (to-be-written) bundle truth lemma to derive a contradiction.

---

## Code Analysis

### 1. `parametric_shifted_truth_lemma` — What It Proves and What It Needs

**Location**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean`, lines 325–458

**Statement** (line 325–330):
```lean
theorem parametric_shifted_truth_lemma (B : BFMCS D)
    (h_tc : B.temporally_coherent) (φ : Formula)
    (fam : FMCS D) (hfam : fam ∈ B.families)
    (t : D) :
    φ ∈ fam.mcs t ↔
    truth_at (ParametricCanonicalTaskModel D) (ShiftClosedParametricCanonicalOmega B)
      (parametric_to_history fam) t φ
```

**`B.temporally_coherent` usage** (lines 280–285 and 427–432):
In the G/H backward cases (the critical ones), the proof extracts `(h_forward_F, h_backward_P)` from `h_tc fam hfam` and wraps them into a `TemporalCoherentFamily`:
```lean
obtain ⟨h_forward_F, h_backward_P⟩ := h_tc fam hfam
let tcf : TemporalCoherentFamily D := {
  toFMCS := fam
  forward_F := h_forward_F
  backward_P := h_backward_P
}
```

`BFMCS.temporally_coherent` (TemporalCoherence.lean:146–152) demands that `forward_F` for family `fam` produces witnesses **within `fam` itself** (same family). `BFMCS_Bundle.bundle_forward_F` only guarantees existence of a witness **in some family `fam' ∈ families`** (possibly different from `fam`).

This is the exact structural mismatch.

### 2. `BFMCS_Bundle` Structure

**Location**: `UltrafilterChain.lean`, lines 2758–2786

Key fields:
```lean
bundle_forward_F : ∀ fam ∈ families, ∀ φ t, Formula.some_future φ ∈ fam.mcs t →
  ∃ fam' ∈ families, ∃ s > t, φ ∈ fam'.mcs s

bundle_backward_P : ∀ fam ∈ families, ∀ φ t, Formula.some_past φ ∈ fam.mcs t →
  ∃ fam' ∈ families, ∃ s < t, φ ∈ fam'.mcs s
```

The `construct_bfmcs_bundle` (line 2853) is sorry-free and produces a valid `BFMCS_Bundle`.

### 3. `TaskModel` and `valid_over`

**`valid_over Int`** (Validity.lean:53–58):
```lean
def valid_over (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (φ : Formula) : Prop :=
  ∀ (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
    (τ : WorldHistory F) (h_mem : τ ∈ Omega) (t : D),
    truth_at M Omega τ t φ
```

The canonical model for instantiation is:
- `F` = `ParametricCanonicalTaskFrame Int` — already a `TaskFrame Int` (ParametricCanonical.lean)
- `M` = `ParametricCanonicalTaskModel Int` — already a `TaskModel F` (ParametricTruthLemma.lean:59)
- `Omega` = `ShiftClosedParametricCanonicalOmega B` — already `ShiftClosed` (ParametricHistory.lean:150)
- `τ` = `parametric_to_history B.eval_family`
- `h_mem` = needs a proof that `parametric_to_history B.eval_family ∈ ShiftClosedParametricCanonicalOmega B`
- `t` = `0`

The membership proof follows from `parametricCanonicalOmega_subset_shiftClosed` (ParametricHistory.lean:160), since `B.eval_family ∈ B.families`.

### 4. The G/H Backward Cases Analyzed Carefully

The G case backward direction in `parametric_shifted_truth_lemma` (lines 425–436):
```lean
-- Backward: (∀ s ≥ t, truth_at ... s ψ) → G ψ ∈ fam.mcs t
intro h_all
obtain ⟨h_forward_F, h_backward_P⟩ := h_tc fam hfam
let tcf : TemporalCoherentFamily D := { ... forward_F := h_forward_F ... }
have h_all_mcs : ∀ s : D, t < s → ψ ∈ fam.mcs s := ...
exact temporal_backward_G tcf t ψ h_all_mcs
```

`temporal_backward_G` (TemporalCoherence.lean:165–178) uses:
```lean
obtain ⟨s, h_lt, h_neg_phi_s⟩ := fam.forward_F t (Formula.neg φ) h_F_neg
have h_phi_s : φ ∈ fam.mcs s := h_all s h_lt
exact set_consistent_not_both (fam.is_mcs s).1 φ h_phi_s h_neg_phi_s
```

The key insight: `temporal_backward_G` uses `fam.forward_F` to get a witness `s` and then uses `h_all s h_lt` to get `φ ∈ fam.mcs s`. With bundle-level coherence, the witness `s` comes from a **different family** `fam'`, so `h_all s h_lt` only gives `φ ∈ fam.mcs s` (same family), but the contradiction needs `neg(φ) ∈ fam'.mcs s` and `φ ∈ fam'.mcs s`.

**This means the backward case proof strategy must change** for bundles, not just the coherence hypothesis.

### 5. The Correct Bundle Truth Lemma Strategy

For a bundle-level truth lemma, the G backward case must use a different proof:

```
-- Backward G case for bundles:
-- Assume ∀ s ≥ t, truth_at M Omega (parametric_to_history fam) s ψ
-- Need: G ψ ∈ fam.mcs t

-- By contraposition:
-- Assume G ψ ∉ fam.mcs t
-- By MCS maximality: neg(G ψ) ∈ fam.mcs t
-- By neg_all_future_to_some_future_neg: F(neg ψ) ∈ fam.mcs t
-- By bundle_forward_F: ∃ fam' ∈ families, ∃ s > t, neg(ψ) ∈ fam'.mcs s
-- Now apply IH to fam' at time s: neg(ψ) ∈ fam'.mcs s → ¬truth_at ... (parametric_to_history fam') s ψ
-- But parametric_to_history fam' is in Omega (ShiftClosedParametricCanonicalOmega)
-- And by definition of truth_at for box: all histories in Omega agree on ψ at time s
-- BUT: ψ is NOT box — ψ is the subformula of G ψ, not necessarily a box formula
-- So truth_at on different histories may differ for non-box formulas
```

This reveals a deeper subtlety: in standard temporal semantics, `G ψ` is evaluated along a SINGLE history `τ`. The truth lemma for G says: `G ψ ∈ fam.mcs t ↔ ∀ s ≥ t, truth_at M Omega τ s ψ` where `τ = parametric_to_history fam`. The history stays **fixed** — only the time changes.

But with bundle-level F witnesses, the witness `neg(ψ) ∈ fam'.mcs s` for a **different** family `fam'` does NOT give a contradiction with `truth_at M Omega (parametric_to_history fam) s ψ` evaluated along the **original** history `parametric_to_history fam`.

### 6. The Forward-Only Approach (Preferred Path)

Since completeness only requires the **forward direction** of the truth lemma (MCS membership → truth in model), the proof can avoid the problematic G/H backward cases entirely.

**Location hint**: `Completeness.lean` line 182–214 documents "Forward truth lemma core" approach.

The forward direction of the truth lemma suffices:
- `neg(φ) ∈ M` (from Lindenbaum construction)
- Forward truth lemma: `neg(φ) ∈ M → truth_at ... neg(φ)`
- `truth_at M Omega τ t (neg φ) = ¬ truth_at M Omega τ t φ`
- So `truth_at M Omega τ t φ` is false
- But `valid_over Int φ` says it is true at ALL models — contradiction

The forward-only truth lemma for bundles needs only:
1. **atom**: MCS membership → truth (trivial, same as existing)
2. **bot**: bot ∉ consistent MCS → False (trivial)
3. **imp**: MCS membership → truth (uses MCS closure, same as existing)
4. **box**: `box ψ ∈ fam.mcs t` → `∀ σ ∈ Omega, truth_at σ t ψ`
   - This uses `modal_forward` from BFMCS_Bundle — same as BFMCS
5. **G (all_future)**: `G ψ ∈ fam.mcs t` → `∀ s ≥ t, truth_at ... fam s ψ`
   - Uses `fam.forward_G` which is still available in `FMCS`
   - No change needed from the existing proof
6. **H (all_past)**: symmetric via `fam.backward_H`

The forward direction does NOT use `temporal_backward_G/H` at all. Those are only used in the backward direction.

**Conclusion**: The forward-only truth lemma for BFMCS_Bundle is identical to the existing `parametric_shifted_truth_lemma`'s forward cases. No new bundle-level coherence is needed for the forward direction.

---

## Implementation Path

### Step 1: Write `bundle_shifted_truth_lemma_forward` (Forward Direction Only)

This theorem states: `φ ∈ fam.mcs t → truth_at (ParametricCanonicalTaskModel Int) (ShiftClosedParametricCanonicalOmega_bundle B) (parametric_to_history fam) t φ`

where `ShiftClosedParametricCanonicalOmega_bundle` is defined analogously to `ShiftClosedParametricCanonicalOmega` but for `BFMCS_Bundle`:

```lean
def ShiftClosedBundleOmega (B : BFMCS_Bundle) :
    Set (WorldHistory (ParametricCanonicalTaskFrame Int)) :=
  { σ | ∃ (fam : FMCS Int) (_ : fam ∈ B.families) (delta : Int),
    σ = WorldHistory.time_shift (parametric_to_history fam) delta }
```

The forward direction proof is:
```lean
theorem bundle_shifted_truth_lemma_forward (B : BFMCS_Bundle)
    (fam : FMCS Int) (hfam : fam ∈ B.families)
    (t : Int) (phi : Formula) :
    phi ∈ fam.mcs t →
    truth_at (ParametricCanonicalTaskModel Int) (ShiftClosedBundleOmega B)
      (parametric_to_history fam) t phi
```

The proof proceeds by induction on `phi`. The key cases:
- **box**: Uses `B.modal_forward` instead of `B.modal_forward` (same since BFMCS_Bundle has this field)
- **all_future**: Uses `fam.forward_G t s ψ hts h_G` — unchanged from existing proof (line 422–424)
- **all_past**: Uses `fam.backward_H` — unchanged

The box case needs a slight adaptation: `ShiftClosedBundleOmega` uses `BFMCS_Bundle.families` not `BFMCS.families`, but the modal forward proof is structurally identical.

### Step 2: Wire to `bundle_validity_implies_provability`

```lean
theorem bundle_validity_implies_provability (φ : Formula)
    (h_valid : valid_over Int φ) : Nonempty ([] ⊢ φ) := by
  by_contra h_not_prov
  -- Step 1: neg(φ) is consistent
  have h_cons := not_provable_implies_neg_consistent φ h_not_prov
  -- Step 2: Extend to MCS and build BFMCS_Bundle
  have h_extend := set_lindenbaum {Formula.neg φ} h_cons
  obtain ⟨M, h_extends, h_mcs⟩ := h_extend
  let B := construct_bfmcs_bundle M h_mcs
  -- Step 3: neg(φ) ∈ B.eval_family.mcs 0 = M
  have h_neg_in_M : Formula.neg φ ∈ M := h_extends (Set.mem_singleton _)
  have h_neg_in_eval : Formula.neg φ ∈ B.eval_family.mcs 0 := by
    rw [construct_bfmcs_bundle_eval_at_zero]; exact h_neg_in_M
  -- Step 4: Build the canonical model ingredients
  let F := ParametricCanonicalTaskFrame Int
  let Mm := ParametricCanonicalTaskModel Int
  let Omega := ShiftClosedBundleOmega B
  -- Step 5: Show Omega is ShiftClosed
  have h_sc : ShiftClosed Omega := shiftClosedBundleOmega_is_shift_closed B
  -- Step 6: The eval history is in Omega
  let τ := parametric_to_history B.eval_family
  have h_mem : τ ∈ Omega := by
    exact ⟨B.eval_family, B.eval_family_mem, 0, by simp [WorldHistory.time_shift, add_zero]⟩
  -- Step 7: Apply valid_over to get truth of φ
  have h_truth_phi := h_valid F Mm Omega h_sc τ h_mem 0
  -- Step 8: Apply forward truth lemma to neg(φ) to get truth of neg(φ)
  have h_truth_neg_phi := bundle_shifted_truth_lemma_forward B B.eval_family
    B.eval_family_mem 0 (Formula.neg φ) h_neg_in_eval
  -- Step 9: Contradiction: truth of neg(φ) = ¬ truth of φ
  simp only [truth_at] at h_truth_neg_phi
  exact h_truth_neg_phi h_truth_phi
```

### Step 3: Dense and Discrete Completeness

Once `completeness_over_Int` is sorry-free, the dense and discrete theorems follow by noting that `valid_dense φ → valid_over Int φ` (Int is discrete, Rat is dense and Int embeds into Rat). However, the current sorry for dense/discrete completeness in `Completeness.lean` uses a different argument. The simplest fix is to prove:
- `valid_over_dense_implies_valid_over_Int`: dense validity implies Int validity
- `valid_over_discrete_implies_valid_over_Int`: discrete validity implies Int validity

### Step 4: The ShiftClosed Omega for BFMCS_Bundle

The `ShiftClosedBundleOmega` proof of shift-closure is identical to `shiftClosedParametricCanonicalOmega_is_shift_closed` (ParametricHistory.lean:150–156) since the only difference is the source bundle type. The proof structure is:

```lean
theorem shiftClosedBundleOmega_is_shift_closed (B : BFMCS_Bundle) :
    ShiftClosed (ShiftClosedBundleOmega B) := by
  intro σ h_mem Δ'
  obtain ⟨fam, hfam, delta, h_eq⟩ := h_mem
  refine ⟨fam, hfam, delta + Δ', ?_⟩
  subst h_eq
  exact time_shift_parametric_to_history_compose fam delta Δ'
```

This reuses `time_shift_parametric_to_history_compose` from `ParametricHistory.lean`.

---

## Dependencies and Risks

### Dependencies (All Existing, Sorry-Free)

| Component | File | Status |
|-----------|------|--------|
| `construct_bfmcs_bundle` | UltrafilterChain.lean:2853 | Sorry-free |
| `boxClassFamilies_bundle_forward_F` | UltrafilterChain.lean:2643 | Sorry-free |
| `boxClassFamilies_bundle_backward_P` | UltrafilterChain.lean:2688 | Sorry-free |
| `ParametricCanonicalTaskFrame Int` | ParametricCanonical.lean | Sorry-free |
| `ParametricCanonicalTaskModel Int` | ParametricTruthLemma.lean:59 | Sorry-free |
| `parametric_to_history` | ParametricHistory.lean:61 | Sorry-free |
| `time_shift_parametric_to_history_compose` | ParametricHistory.lean:131 | Sorry-free (private) |
| `not_provable_implies_neg_consistent` | UltrafilterChain.lean:2950 | Sorry-free |
| `set_lindenbaum` | Core MCS | Sorry-free |

### New Proofs Required

1. **`ShiftClosedBundleOmega`** — definition (5 lines)
2. **`shiftClosedBundleOmega_is_shift_closed`** — proof (8 lines, identical structure to existing)
3. **`bundle_shifted_truth_lemma_forward`** — forward direction only induction (≈80 lines, copy/adapt)
4. **`bundle_validity_implies_provability`** — wiring (≈30 lines, outline above)

### Risks

**Risk 1 (Medium)**: The forward truth lemma box case uses `B.modal_forward` which in `BFMCS_Bundle` has the same type as in `BFMCS`. However, the Omega quantification for the backward case of box (when proving `box ψ ∈ fam.mcs t` from truth) would require knowing that all histories in `ShiftClosedBundleOmega` correspond to families in `B.families`. This is guaranteed by definition.

**Risk 2 (Low)**: The `WorldHistory.time_shift` membership proof at Step 6 needs `time_shift f 0 = f`. This follows from `parametric_to_history_eq_time_shift_zero` (ParametricHistory.lean:145).

**Risk 3 (Low)**: The contradiction at Step 9 requires `truth_at M Omega τ 0 (neg φ) = ¬ truth_at M Omega τ 0 φ`. By unfolding `truth_at` for `neg φ = (φ.imp bot)`:
```
truth_at ... (φ.imp bot) = truth_at ... φ → truth_at ... bot = truth_at ... φ → False = ¬ truth_at ... φ
```
This is definitional/propositional, provable by `simp [truth_at]`.

**Risk 4 (Medium)**: The `ShiftClosedBundleOmega` needs to work with `ParametricCanonicalTaskFrame Int` specifically (not polymorphic D). The existing `parametric_to_history` is polymorphic but the bundle is `BFMCS_Bundle` with `FMCS Int`. This should type-check directly.

---

## Confidence Levels

| Finding | Confidence | Rationale |
|---------|------------|-----------|
| The only sorry is in `bundle_validity_implies_provability` | High | Verified by reading Completeness.lean:186–214 |
| Forward direction of truth lemma is sorry-free for BFMCS_Bundle | High | Forward cases don't use temporal coherence |
| `ParametricCanonicalTaskFrame Int` + `ParametricCanonicalTaskModel Int` is the right canonical model | High | Already used in `parametric_shifted_truth_lemma` |
| `ShiftClosedBundleOmega` proof is a simple copy | High | Structurally identical to existing proof |
| Step 9 contradiction via `truth_at` for neg unfolds correctly | Medium | Depends on how `neg` unfolds in `truth_at` — need to verify `neg φ = φ.imp bot` reduces |
| Dense/discrete completeness via Int embedding | Medium | The logical argument is clear but the Lean types may need care (valid_dense vs valid_over Int) |

---

## Key Insight for Implementation

The critical observation: **the forward direction of the truth lemma does not use `forward_F` or `backward_P` at all**. These are only used in the backward (MCS ← truth) direction, specifically in the G/H backward cases via `temporal_backward_G/H`. Since completeness only requires the forward direction (MCS membership → semantic truth) to derive a contradiction from `valid_over Int φ`, the bundle-level coherence is completely irrelevant to the proof.

The existing `parametric_shifted_truth_lemma` could have its forward direction extracted and directly applied to `BFMCS_Bundle` by:
1. Defining `ShiftClosedBundleOmega` analogously for `BFMCS_Bundle`
2. Proving `ShiftClosed` for it (identical proof)
3. Copying the forward direction cases from `parametric_shifted_truth_lemma` with `BFMCS_Bundle` replacing `BFMCS` as the bundle type

The box forward case needs `B.modal_forward` which `BFMCS_Bundle` has. The G/H forward cases need only `fam.forward_G`/`fam.backward_H` which come from the `FMCS` structure — always available.
