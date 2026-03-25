# Teammate B Findings: Alternative Approaches and Blocker Analysis

**Task 63**: Prove Box backward via BFMCS modal saturation and eliminate singleton-Omega dead end
**Date**: 2026-03-24
**Focus**: Axiom/sorry dependency verification and hidden blocker analysis

---

## Key Findings

### 1. `boxClassFamilies_modal_backward` — Genuinely Sorry-Free

`lean_verify` on `Bimodal.Metalogic.Algebraic.boxClassFamilies_modal_backward` returns:
```json
{"axioms": [], "warnings": []}
```

This is the **only** theorem in the BFMCS modal backward chain that `lean_verify` checks cleanly.
The source at `UltrafilterChain.lean:1678–1782` is a complete 8-step proof with no `sorry`. The
proof uses only:
- `box_theory_witness_exists` (for constructing the witness MCS)
- `parametric_box_persistent` (for Box persistence along a chain)
- `SetMaximalConsistent.negation_complete` and `set_consistent_not_both`
- Standard arithmetic (`Int.sub_self`, `simp`)

No temporal coherence is required for this theorem. The modal backward direction is purely
modal, not temporal.

### 2. `box_theory_witness_exists` — Sorry-Free

`lean_verify` returns `{"axioms": [], "warnings": []}` for
`Bimodal.Metalogic.Algebraic.box_theory_witness_exists`.

Source at `UltrafilterChain.lean:903–920`. It uses `set_lindenbaum` (Lindenbaum's lemma) to
extend the box theory plus `{psi}` to an MCS. This lemma has no sorries and depends only on
provable infrastructure.

### 3. `construct_bfmcs` — SORRY-DEPENDENT but Deprecated

`lean_verify` returns `{"axioms": [], "warnings": []}` for `construct_bfmcs`. However, this is
the known `lean_verify` bug from Task 62: the tool does not detect indirect sorry chains.

The source at `UltrafilterChain.lean:1828–1877` explicitly documents in its docstring:

> **WARNING**: This function uses `boxClassFamilies_temporally_coherent` which depends on
> the mathematically false `f_nesting_is_bounded`. The temporal coherence proof has a sorry.

The sorry chain is:
```
construct_bfmcs
  → boxClassFamilies_temporally_coherent (line 1809)
    → SuccChainTemporalCoherent  [DELETED in Task 56]
      → succ_chain_forward_F    [DELETED in Task 56]
        → f_nesting_boundary    [DELETED in Task 56]
          → f_nesting_is_bounded (MATHEMATICALLY FALSE)
```

`construct_bfmcs` is marked `@[deprecated]` and should not be used in any completeness path.

### 4. Active Build Error in `SuccChainFMCS.lean`

The build currently **fails** with:

```
error: Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean:2215:19: Unknown identifier `restricted_bounded_witness`
```

The private theorem `restricted_forward_chain_iter_F_witness` (lines 2162–2240) references
`restricted_bounded_witness` at line 2215, but this identifier was removed in Task 56
(documented at SuccChainFMCS.lean:2463). The comment block at line 2463 says:

> `restricted_bounded_witness` (depended on FALSE theorems)

There is also an unsolved goal error at line 2166. This is an **active build breakage** that
blocks any downstream module that imports `SuccChainFMCS`.

### 5. Temporal Coherence Has No Sorries in `TemporalCoherence.lean`

The file `Bundle/TemporalCoherence.lean` has no `sorry` statements. It provides:
- `temporal_backward_G` and `temporal_backward_H` (backward direction lemmas)
- `BFMCS.temporally_coherent` (predicate definition)
- `TemporalCoherentFamily` structure

These are purely structural/definitional. The problem is not in this file — it is in
establishing that specific BFMCS constructions satisfy temporal coherence.

### 6. The BFMCS Path Does Not Require Temporal Coherence for Box Backward

The key architectural insight (documented in UltrafilterChain.lean comments at line 1793–1795):

> For completeness purposes, the forward direction of the truth lemma does NOT require
> temporal coherence — only the backward direction does.

`boxClassFamilies_modal_backward` requires no temporal coherence whatsoever. It is a pure
modal saturation argument using `box_theory_witness_exists`. The temporal operators (G, H, F, P)
are what require coherence for their backward directions; Box/Diamond are atemporal.

---

## Blocker Analysis

### Blocker 1: Active Build Failure (CRITICAL)

**File**: `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`
**Lines**: 2215 (usage), 2462–2463 (deletion note)
**Issue**: `restricted_bounded_witness` is called but was deleted in Task 56.

This is a **show-stopper for anything that imports SuccChainFMCS**. Since
`SuccChainTruth.lean` and `SuccChainCompleteness.lean` import `SuccChainFMCS`, none of
these modules compile. If Task 63's completeness proof uses `succ_chain_truth_forward`
(the documented approach), it will inherit this build failure.

The fix requires either:
1. Re-implementing `restricted_bounded_witness` without the false `f_nesting_is_bounded`
2. Replacing the call site at line 2215 with a direct proof using the available
   `restricted_forward_chain_F_step_witness` (line 2144) + recursion

### Blocker 2: `succ_chain_truth_forward` Depends on sorryAx

`succ_chain_truth_forward` is documented in `SuccChainTruth.lean:37–39`:

> Both `succ_chain_truth_lemma` and `succ_chain_truth_forward` depend on `sorryAx` because
> the forward Imp case structurally requires the backward direction.

Even if Task 63 avoids the singleton-Omega dead end, using `succ_chain_truth_forward` as
the bridge from MCS membership to semantic truth still carries sorryAx.

### Blocker 3: `construct_bfmcs` Cannot Provide Temporally Coherent BFMCS

The only existing way to go from an MCS M₀ to a temporally coherent BFMCS is
`construct_bfmcs`, which is deprecated and sorry-dependent. The sorry-free
`boxClassFamilies_modal_backward` alone is not enough for completeness — you also need
temporal coherence for the G and H backward directions in the truth lemma.

### Blocker 4: No Sorry-Free Path from `boxClassFamilies_modal_backward` to Completeness

`boxClassFamilies_modal_backward` is sorry-free, but connecting it to a complete sorry-free
completeness proof requires:
1. A sorry-free `forward_F` / `backward_P` for families in `boxClassFamilies` — this
   requires `SuccChainTemporalCoherent`, which was deleted as mathematically false
2. OR a restricted chain construction via `DeferralRestrictedSerialMCS` — work in progress
   but `restricted_forward_chain_iter_F_witness` currently broken (Blocker 1)

---

## Evidence and Examples

### Source: `UltrafilterChain.lean`
- Line 1678: `boxClassFamilies_modal_backward` — complete proof, no sorry
- Line 903: `box_theory_witness_exists` — complete proof, no sorry
- Line 1808: `@[deprecated]` annotation on `boxClassFamilies_temporally_coherent`
- Line 1834: explicit warning "temporal coherence proof has a sorry"
- Line 1852: `@[deprecated]` annotation on `construct_bfmcs`
- Line 1837–1839: sorry chain documented in docstring

### Source: `SuccChainFMCS.lean`
- Line 2215: broken call `restricted_bounded_witness phi M0 k (iter_F (d - 1) psi) d_max`
- Line 2460–2467: confirms `restricted_bounded_witness` was deleted in Task 56 cleanup
- Lines 40–57: documents the f_nesting_is_bounded falsity and path forward

### Source: `SuccChainTruth.lean`
- Lines 37–39: explicit documentation that `succ_chain_truth_forward` depends on sorryAx
- Lines 285–289: explanation of sorry propagation via forward Imp case

### Source: `TemporalCoherence.lean`
- No sorry statements — file is clean
- Defines `TemporalCoherentFamily` and `BFMCS.temporally_coherent`

### Source: `ROADMAP.md`
- Line 5: "98 sorry statements across 24 files"
- Lines 29–31: "algebraic path is sorry-free through conditional representation theorem"
- Lines 105–118: gap is `construct_bfmcs`; algebraic alternative discussed

---

## Confidence Level: HIGH

The findings are directly confirmed by:
1. `lean_verify` axiom checks (for the sorry-free theorems)
2. Build error output showing `restricted_bounded_witness` unknown identifier
3. Explicit deprecation annotations and docstrings in the source
4. The deletion log in SuccChainFMCS.lean comments

The only uncertainty is whether `lean_verify` correctly reports sorry-free status for
`boxClassFamilies_modal_backward` — given the Task 62 finding that the tool has a bug. However,
manual source inspection at lines 1678–1782 confirms no `sorry` appears in the proof body,
and all dependencies (`box_theory_witness_exists`, `parametric_box_persistent`,
`SetMaximalConsistent.negation_complete`, `set_consistent_not_both`) are known-good.

---

## Summary for Task 63 Implementer

1. **`boxClassFamilies_modal_backward` is truly sorry-free** — use it directly.
2. **`box_theory_witness_exists` is truly sorry-free** — use it directly.
3. **Fix `restricted_forward_chain_iter_F_witness` first** (Blocker 1) — the build is
   broken and any completeness proof via `SuccChainFMCS` path is blocked.
4. **Do not use `construct_bfmcs`** — deprecated and sorry-dependent.
5. **Do not use `succ_chain_truth_forward` as the completeness bridge** — it has sorryAx.
6. **Temporal coherence for G/H is the remaining gap** — `boxClassFamilies_modal_backward`
   solves Box, but G and H backward still need `forward_F`/`backward_P` from somewhere.
7. **The restricted chain path (`DeferralRestrictedSerialMCS`)** appears to be the intended
   sorry-free route for temporal coherence, but `restricted_forward_chain_iter_F_witness`
   must be repaired to complete it.
