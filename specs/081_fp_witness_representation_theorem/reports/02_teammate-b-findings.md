# Research Report: Task #81 (Run 2) — Teammate B Findings
# Bundle Architecture and canonical_forward_F Analysis

**Date**: 2026-03-31
**Scope**: BFMCS architecture, canonical_forward_F, BFMCS.temporally_coherent, cross-family witnesses
**Files analyzed**:
- `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean`
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean`
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean`
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` (header + key sections)
- `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean`
- `Theories/Bimodal/Metalogic/Algebraic/ParametricRepresentation.lean`
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (later sections)

---

## The Answer: How Bundle Architecture Handles F-Witnesses

**The architecture requires each family to independently satisfy `forward_F`.**

The BFMCS structure holds a set of FMCS families. The predicate `BFMCS.temporally_coherent` requires that for **every** family `fam ∈ B.families`, that family **individually** must provide its own F-witnesses:

```lean
def BFMCS.temporally_coherent (B : BFMCS D) : Prop :=
  ∀ fam ∈ B.families,
    (∀ t : D, ∀ φ : Formula, Formula.some_future φ ∈ fam.mcs t →
      ∃ s : D, t ≤ s ∧ φ ∈ fam.mcs s) ∧
    (∀ t : D, ∀ φ : Formula, Formula.some_past φ ∈ fam.mcs t →
      ∃ s : D, s ≤ t ∧ φ ∈ fam.mcs s)
```

The witness `s` must be in the **same** `fam.mcs`. There is no provision for cross-family witnesses here.

---

## canonical_forward_F Role

`canonical_forward_F` (in `CanonicalFrame.lean`) is **not about BFMCS families at all**. It operates at the level of raw MCS sets (not FMCS families), and constructs fresh witnesses via Lindenbaum:

```lean
theorem canonical_forward_F (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_F : Formula.some_future psi ∈ M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ ExistsTask M W ∧ psi ∈ W
```

**What it does**: Given `F(psi) ∈ M`, it constructs a fresh MCS `W` via:
1. Seeds `{psi} ∪ g_content(M)` (shown consistent by `forward_temporal_witness_seed_consistent`)
2. Extends via `set_lindenbaum` to get `W`
3. `W` satisfies `ExistsTask M W` (i.e., `g_content M ⊆ W`) and `psi ∈ W`

This is a **flat MCS-level** construction. Each F-obligation gets its **own independently-constructed witness MCS**.

**How it is used**: `canonical_forward_F` is used in the `SuccChainFMCS` and `UltrafilterChain` constructions to build families where individual time-indexed MCSs are stitched together via this witness mechanism. However, the critical question is whether the resulting FMCS satisfies **same-family** `forward_F` — that is, whether the witnesses stay **within** the same FMCS rather than jumping to freshly constructed ones.

---

## BFMCS.temporally_coherent: What It Actually Requires

`BFMCS.temporally_coherent` is a **family-level** condition: every family in the BFMCS must independently satisfy `forward_F` and `backward_P` with witnesses **within that same family's timeline** (`fam.mcs s` for the same `fam`).

This is used **directly** in the truth lemma's G/H backward cases:

```lean
-- Backward G case in ParametricTruthLemma.lean:
obtain ⟨h_forward_F, h_backward_P⟩ := h_tc fam hfam
let tcf : TemporalCoherentFamily D := {
  toFMCS := fam
  forward_F := h_forward_F
  backward_P := h_backward_P
}
exact temporal_backward_G tcf t psi h_all_mcs
```

The backward G proof is: assume `G(psi) ∉ fam.mcs t`, derive `F(neg psi) ∈ fam.mcs t`, apply `forward_F` to get `s` with `neg psi ∈ fam.mcs s`, then apply backward IH to `truth_at ... (parametric_to_history fam) s psi` — which evaluates along **the same history `parametric_to_history fam`**. A witness in a different family `fam'` would evaluate along `parametric_to_history fam'`, a **different history**, and would not produce the contradiction needed.

---

## Cross-Family Witnesses: Architecture Does NOT Support Them

**For the truth lemma, cross-family witnesses do not work.**

The semantic truth evaluation for `G(psi)` at `(fam, t)` is:
```
∀ s ≥ t, truth_at model Omega (to_history fam) s psi
```

This quantifies over times along the **single history `to_history fam`**. All witnesses must be in `fam` itself. A cross-family witness at `(fam', s)` lies along a **different history** and does not produce the needed contradiction in `temporal_backward_G`.

This is explicitly noted in `ParametricTruthLemma.lean` (lines 46-49):
> "Step 3 is the critical use of `forward_F`. The witness must be in the SAME family `fam`, because the semantic hypothesis (truth at all s ≥ t) is evaluated along the history `to_history(fam)`. A witness in a DIFFERENT family would be evaluated along a different history and would not produce the needed contradiction."

---

## The BFMCS_Bundle Alternative Structure

The codebase has recognized this gap. In `UltrafilterChain.lean`, there is an alternative structure `BFMCS_Bundle` (lines 3445–3472) with **bundle-level** F coherence:

```lean
bundle_forward_F : ∀ fam ∈ families, ∀ φ t, Formula.some_future φ ∈ fam.mcs t →
  ∃ fam' ∈ families, ∃ s > t, φ ∈ fam'.mcs s
```

The `construct_bfmcs_bundle` function builds this from `boxClassFamilies` using shifted `SuccChainFMCS` instances. This **bundle-level** coherence is sorry-free and provable.

However, the truth lemma requires **family-level** `BFMCS.temporally_coherent` (same-family witnesses). The `BFMCS_Bundle.bundle_forward_F` is **strictly weaker**: it gives a witness in some `fam'`, but not necessarily in `fam` itself.

The code explicitly documents this gap at UltrafilterChain.lean lines 3590-3592:
> "Step 3 requires `B.temporally_coherent` (family-level forward_F/backward_P). The sorry-free bundle construction provides only bundle-level coherence. The gap between bundle-level and family-level coherence is the remaining blocker."

---

## Implications for the F/P Witness Problem

1. **`canonical_forward_F` is not directly applicable to BFMCS families**. It constructs fresh MCS witnesses from flat MCSs, not within FMCS family timelines.

2. **The `BFMCS.temporally_coherent` predicate demands same-family witnesses**. This is non-negotiable given the structure of `temporal_backward_G`/`temporal_backward_H`.

3. **The sorry-free construction (`construct_bfmcs_bundle`) proves bundle-level coherence only**. Each `SuccChainFMCS` family in `boxClassFamilies` has the property that witnesses for F-obligations exist in **some** family of the bundle, but not provably in the same family.

4. **The core gap**: To prove `forward_F` for a specific FMCS (say `SuccChainFMCS M0`), we need: given `F(psi) ∈ (SuccChainFMCS M0).mcs t`, there exists `s ≥ t` with `psi ∈ (SuccChainFMCS M0).mcs s`. This requires knowing that the SuccChain construction at time `t+1, t+2, ...` eventually places `psi` within the **same** chain. Whether the SuccChain construction guarantees this depends on how the chain is built (e.g., dovetailed scheduling of F-obligations).

5. **The dovetailed chain approach** (noted at UltrafilterChain.lean lines 3685-3711) is the proposed path: build the chain via fair scheduling (using `Nat.unpair`) so every F-obligation is resolved within the same chain. This would yield family-level `forward_F` by construction.

---

## Confidence Level: High

The analysis is based on direct reading of the definitions and proof terms. The conclusions are:
- `BFMCS.temporally_coherent` requires same-family witnesses: **definitionally certain**
- `canonical_forward_F` operates on raw MCSs, not FMCS timelines: **definitionally certain**
- Cross-family witnesses cannot substitute for family-level witnesses in the truth lemma: **proven in code comments and by proof structure**
- The bundle-level vs family-level gap is the documented blocker: **explicitly stated in UltrafilterChain.lean**
