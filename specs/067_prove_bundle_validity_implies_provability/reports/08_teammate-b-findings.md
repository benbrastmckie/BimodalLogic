# Teammate B Findings: Completeness Wiring Infrastructure

## Sorry Analysis (Exact Goal and Context)

The sorry is in `bundle_validity_implies_provability` at
`Theories/Bimodal/FrameConditions/Completeness.lean:176-204`.

**The theorem signature**:
```lean
theorem bundle_validity_implies_provability (φ : Formula)
    (h_valid : valid_over Int φ) : Nonempty ([] ⊢ φ)
```

**The proof structure** (via `by_contra`):
```lean
by_contra h_not_prov
have h_cons := not_provable_implies_neg_consistent φ h_not_prov
have _h := bundle_completeness_contradiction φ h_cons
-- At this point: _h : ¬(∀ M : Set Formula, SetMaximalConsistent M → φ ∈ M)
-- But h_valid : valid_over Int φ
-- Need: derive contradiction between h_valid and _h
sorry
```

**Exact gap**: The proof has established that there exists an MCS `M` with `neg(phi) ∈ M`, which means `phi ∉ M`. The sorry needs to show this contradicts `valid_over Int phi`.

`valid_over Int phi` says:
```lean
∀ (F : TaskFrame Int) (M : TaskModel F)
  (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
  (τ : WorldHistory F) (h_mem : τ ∈ Omega) (t : Int),
  truth_at M Omega τ t phi
```

The gap is constructing a `TaskFrame Int`, `TaskModel`, `WorldHistory`, `Omega`, `τ`, `t` from a `BFMCS_Bundle` such that `phi` is false at some point — i.e., converting the algebraic MCS/BFMCS world into the semantic `TaskFrame`/`TaskModel` world.

## Existing Wiring Patterns

### `parametric_canonical_truth_lemma`

Located in `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean:207-351`.

This lemma states:
```lean
theorem parametric_canonical_truth_lemma
    (B : BFMCS D) (h_tc : B.temporally_coherent)
    (fam : FMCS D) (hfam : fam ∈ B.families)
    (t : D) (phi : Formula) :
    phi ∈ fam.mcs t ↔
      truth_at (ParametricCanonicalTaskModel D) (ParametricCanonicalOmega B)
        (parametric_to_history fam) t phi
```

This is exactly the bridge between MCS membership and semantic truth — it connects `phi ∈ fam.mcs t` to `truth_at ... phi`. The `ParametricCanonicalTaskModel D` is the canonical task model built from an FMCS.

**Critical dependency**: This requires `h_tc : B.temporally_coherent`, which is **family-level** coherence:
```lean
def BFMCS.temporally_coherent (B : BFMCS D) : Prop :=
  ∀ fam ∈ B.families,
    (∀ t φ, F(φ) ∈ fam.mcs t → ∃ s > t, φ ∈ fam.mcs s) ∧
    (∀ t φ, P(φ) ∈ fam.mcs t → ∃ s < t, φ ∈ fam.mcs s)
```
Witnesses must be **in the same family** `fam`.

### `parametric_shifted_truth_lemma`

Also in `ParametricTruthLemma.lean:367-499`. Same pattern but uses `ShiftClosedParametricCanonicalOmega B` rather than `ParametricCanonicalOmega B`. Also requires `h_tc : B.temporally_coherent`.

### `valid_over Int` definition

From `Theories/Bimodal/FrameConditions/Validity.lean:53-58`:
```lean
def valid_over (D : Type) ... (φ : Formula) : Prop :=
  ∀ (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
    (τ : WorldHistory F) (h_mem : τ ∈ Omega) (t : D),
    truth_at M Omega τ t φ
```

To derive contradiction from `valid_over Int phi`, we need to exhibit:
- A concrete `F : TaskFrame Int`
- A concrete `M : TaskModel F`
- A concrete `Omega`, `h_sc`, `τ`, `t`
- Then show `truth_at M Omega τ t phi` is false

The canonical constructions (`ParametricCanonicalTaskModel`, `ParametricCanonicalOmega`) provide exactly these, using a `BFMCS Int` with `temporally_coherent`.

### `construct_bfmcs_bundle`

Located in `UltrafilterChain.lean:2853-2864`. Builds a `BFMCS_Bundle` from an MCS using `boxClassFamilies`. It provides:
- `bundle_forward_F`: F(phi) at t implies witness **in some family** at s > t
- `bundle_backward_P`: P(phi) at t implies witness **in some family** at s < t

These are **bundle-level** (cross-family) properties, NOT family-level.

## Gap Analysis (Current vs Needed)

### What we have

- `construct_bfmcs_bundle M h_mcs`: A `BFMCS_Bundle` with:
  - `eval_family.mcs 0 = M`
  - `BundleTemporallyCoherent` (bundle-level: witnesses in ANY family)
- `not_provable_implies_neg_consistent`: Converts non-provability to consistency
- `bundle_completeness_contradiction`: Shows there is an MCS not containing phi
- `mcs_neg_gives_countermodel`: phi ∉ eval_family.mcs 0

### What we need to close the sorry

The sorry needs to construct a semantic model where `phi` is false. The chain is:

1. Get MCS `M` with `neg(phi) ∈ M` (done via Lindenbaum extension in `bundle_completeness_contradiction`)
2. Build `BFMCS_Bundle B` from `M` (done via `construct_bfmcs_bundle`)
3. Apply truth lemma: `neg(phi) ∈ M ↔ truth_at (ParametricCanonicalTaskModel Int) (ParametricCanonicalOmega B) (parametric_to_history B.eval_family) 0 (neg phi)` — **BLOCKED: needs family-level `temporally_coherent`**
4. From truth of `neg(phi)` at canonical model, phi is false there
5. Specialize `h_valid` to this concrete model to get `truth_at ... phi`
6. Contradiction

**Step 3 is the blocker**. `parametric_canonical_truth_lemma` requires `B.temporally_coherent` (family-level), but `construct_bfmcs_bundle` only provides `BundleTemporallyCoherent` (bundle-level).

### The family-level vs bundle-level gap

**Family-level** (what `temporally_coherent` requires):
```
F(phi) ∈ fam.mcs t → ∃ s > t, phi ∈ fam.mcs s  -- witness in SAME family
```

**Bundle-level** (what `BundleTemporallyCoherent` provides):
```
F(phi) ∈ fam.mcs t → ∃ fam' ∈ families, ∃ s > t, phi ∈ fam'.mcs s  -- witness in ANY family
```

The truth lemma backward case for `G` needs the family-level version because the semantic truth at `s` is evaluated along `parametric_to_history fam` (the same family's history), so a witness in a different family's MCS does not produce the needed contradiction.

## Proposed Solution Structure

There are three non-sorry approaches. They are ordered from most to least promising.

### Option 1: Alternative truth lemma using bundle coherence (Restricted Truth Lemma)

Observe that the sorry in `bundle_validity_implies_provability` only needs the **forward direction** of the truth lemma for `neg(phi) = phi.imp bot`:

```
neg(phi) ∈ M → truth_at ... 0 (neg phi)  [only forward direction needed]
```

However, as documented in `ParametricTruthLemma.lean:19-32`, the forward direction of `imp` uses the **backward IH** for the antecedent. For `neg(phi) = phi.imp bot`, the forward direction requires the backward direction for `phi`. The backward direction for `G`/`H` subcases of `phi` requires `forward_F` at the family level.

**Restricted approach**: If `phi` is restricted to formulas where the backward G/H cases don't arise (e.g., `phi` contains no `G` or `H`), this would sidestep the gap. However, we need completeness for ALL formulas.

**Deeper restricted approach**: Use the `deferralClosure(phi)` restriction. If `phi` ranges only over formulas in `deferralClosure(phi)` in the truth lemma induction, and if the bundle construction guarantees that for formulas in `deferralClosure(phi)`, the witnesses ARE in the same family, this could work. This requires understanding what `deferralClosure` means in this context — it would need to be specified.

### Option 2: Prove `boxClassFamilies` provides family-level coherence for specific families

The `boxClassFamilies` construction builds families as `shifted_fmcs(SuccChainFMCS(W), k)`. For a `SuccChainFMCS`, the temporal structure is very regular. It may be provable that each individual family in `boxClassFamilies` actually HAS family-level forward_F:

If `F(phi) ∈ fam.mcs t` where `fam = shifted_fmcs(SuccChainFMCS(W), k)`, does there exist `s > t` with `phi ∈ fam.mcs s`?

This would require `SuccChainFMCS` to have family-level temporal coherence. If `SuccChainFMCS` is a serial MCS chain where each step is the successor MCS, then F(phi) at t means phi holds at t+1 in the SAME chain — this IS family-level. This is very likely true given how `SuccChainFMCS` is constructed.

**Key question**: Does `SuccChainFMCS` already have family-level forward_F? If yes, then `boxClassFamilies` provides family-level coherence, and `parametric_canonical_truth_lemma` applies directly.

This should be investigated by reading `SuccChainFMCS` construction in `Bundle/SuccChainFMCS.lean`.

### Option 3: Bypass the truth lemma entirely

The sorry in `bundle_validity_implies_provability` appears in a `by_contra` proof. Instead of using the truth lemma, we could:

1. Show that if `phi` is valid over `Int` (as a `TaskFrame`), then it is in every MCS of every bundle
2. This is an alternative characterization of validity that avoids constructing the canonical model explicitly

But this alternative characterization is essentially the same difficulty.

### Confidence Assessment for Option 2

The `SuccChainFMCS` is built from a `SerialMCS` — a sequence of MCSes where each is the "next" successor. If `F(phi) ∈ mcs(t)`, then by the serial MCS property, `phi ∈ mcs(t+1)`. This would give family-level forward_F.

For the shifted family `shifted_fmcs(fam, k)`, `mcs(t) = fam.mcs(t - k)`, so `F(phi) ∈ fam.mcs(t)` gives `phi ∈ fam.mcs(t+1)` which is still in the same shifted family. This strongly suggests family-level coherence is provable for `boxClassFamilies`.

## Confidence Level

**High confidence** on the gap analysis: the sorry requires constructing a TaskFrame/TaskModel from the BFMCS_Bundle and applying the truth lemma, which needs `B.temporally_coherent` (family-level).

**Medium confidence** on Option 2 being the path forward: `SuccChainFMCS` likely provides family-level temporal coherence, making `boxClassFamilies` fully family-level coherent. This would close the gap without new axioms or sorry deferral. Requires reading `SuccChainFMCS.lean` to confirm.

**The critical file to read next**: `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` to verify whether `SuccChainFMCS` has family-level forward_F and backward_P properties.
