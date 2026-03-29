# Teammate A Findings: Plan 07 Mathematical Verification

## Summary

Plan 07 is mathematically sound in its core approach — the transfer-back lemma is already implemented and sorry-free, and the restricted forward chain infrastructure is solid. However, the plan has a significant unacknowledged gap: the backward chain construction (Phases 3) has two open `sorry`s in lemmas that `constrained_predecessor_restricted_succ` depends on, and the `SuccChainFMCS` used in `bfmcs_from_mcs_temporally_coherent` is constructed from **full unrestricted chains** (`forward_chain`/`backward_chain` over arbitrary `SerialMCS`), not restricted chains — Plan 07's restricted Z_chain approach requires a new integration path that is more complex than the plan acknowledges.

## Key Findings

### 1. Transfer-Back Lemma Analysis

**Status: Already implemented and sorry-free.**

The transfer-back property exists at two levels:

- `DeferralRestrictedSerialMCS.extendToMCS_transfer_back` (lines 3180–3203): Proves that if `psi ∈ deferralClosure phi` and `psi ∈ M.extendToMCS`, then `psi ∈ M.world`. The proof uses DRM maximality correctly via contradiction, and is **sorry-free**.

- `restricted_forward_chain_transfer_back` (lines 3211–3237): A more general version proving the same for any consistent superset T of `restricted_forward_chain phi M0 k`. Also **sorry-free**.

The DRM maximality property (`M.is_drm.2`) is already formalized as:
```lean
-- If psi ∈ deferralClosure and psi ∉ M.world, then insert psi M.world is inconsistent
h_mcs.2 psi h_in_dc h_not_in_M : ¬SetConsistent (insert psi M.world)
```

**Plan 07 Phase 1 is redundant** — the key lemma it proposes to prove (`extendToMCS_transfer_back`) already exists at line 3180.

### 2. Scope Coverage Analysis

**deferralClosure definition** (SubformulaClosure.lean:695):
```lean
def deferralClosure (phi : Formula) : Finset Formula :=
  closureWithNeg phi ∪ deferralDisjunctionSet phi ∪ backwardDeferralSet phi ∪ serialityFormulas
```

This is a **finite** set — it contains all subformulas, their negations, deferral disjunctions (chi ∨ F(chi) and chi ∨ P(chi) for F/P formulas in the closure), and seriality formulas (F_top, P_top, neg bot, etc.).

**Critical scope issue for Plan 07 Phase 4 (restricted_Z_chain_forward_F):**

The plan identifies a case split at lines 188–191:
- Case 1: `F(psi) ∈ deferralClosure phi` → use transfer-back → `restricted_forward_chain_forward_F` → done
- Case 2: `F(psi) ∉ deferralClosure phi` → "need alternative argument"

The plan notes this as a concern but does not provide a resolution. For the completeness proof specifically, the families in `boxClassFamilies` are `shifted_fmcs (SuccChainFMCS S) delta` where `S` is an arbitrary `SerialMCS`. The MCS at any time point can contain **any** formula — including F(psi) for psi outside the deferralClosure of the original formula phi. When the restricted Z_chain is `extendToMCS` of restricted chain elements, the extension (via Lindenbaum) can add arbitrary formulas, including F-formulas outside deferralClosure.

This is a real gap, not a minor concern.

### 3. Backward Chain Assessment

**Status: Significant infrastructure exists but two sorries remain.**

The backward chain predecessor construction is substantially implemented (lines 3295–4012):

- `f_step_blocking_formulas_restricted` — defined, sorry-free
- `constrained_predecessor_restricted` — defined via `deferral_restricted_lindenbaum`, sorry-free
- `constrained_predecessor_restricted_is_mcs` — sorry-free
- `constrained_predecessor_restricted_h_persistence` — sorry-free
- `constrained_predecessor_restricted_p_step` — sorry-free
- `P_top_in_restricted_predecessor` — sorry-free

**BUT two critical lemmas have `sorry`:**

1. `constrained_predecessor_restricted_g_persistence_reverse` (line 3944): "if G(chi) ∈ predecessor, then chi ∈ u" — the comment admits this is a non-trivial proof that the author could not complete. The sorry is structural, not cosmetic.

2. `constrained_predecessor_restricted_f_step_forward` (line 4001): the case "chi ∉ u and F(chi) ∉ u but F(chi) ∈ predecessor" is unresolved with sorry.

Since `constrained_predecessor_restricted_succ` (line 4009) directly invokes both of these, **Plan 07 Phase 3 has hidden sorry debt that is not acknowledged**.

### 4. Integration Analysis

**The central integration gap Plan 07 misunderstands:**

`bfmcs_from_mcs_temporally_coherent` needs to prove temporal coherence for families in `boxClassFamilies`. Looking at the definition:

```lean
-- UltrafilterChain.lean:1553
noncomputable def boxClassFamilies (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) :
    Set (FMCS Int) :=
  { f | ∃ (W : Set Formula) (h_W : SetMaximalConsistent W) (k : Int),
    box_class_agree M0 W ∧
    f = shifted_fmcs (SuccChainFMCS (MCS_to_SerialMCS W h_W)) k }
```

Each family is `shifted_fmcs (SuccChainFMCS S) delta` where `SuccChainFMCS S` is built from `forward_chain`/`backward_chain` over a plain `SerialMCS S` — **not** from a `DeferralRestrictedSerialMCS`.

```lean
-- SuccChainFMCS.lean:980
noncomputable def SuccChainFMCS (M0 : SerialMCS) : FMCS Int where
  mcs := succ_chain_fam M0      -- uses forward_chain / backward_chain
  is_mcs := succ_chain_fam_mcs M0
  forward_G := succ_chain_forward_G_le M0
  backward_H := succ_chain_backward_H_le M0
  -- NO forward_F or backward_P fields!
```

The `FMCS` structure only requires `forward_G` and `backward_H` — **temporal coherence (`forward_F` and `backward_P`) is NOT part of the `FMCS` structure**. It's handled separately via `BFMCS.temporally_coherent`.

To use Plan 07's restricted Z_chain approach, you would need to either:
1. Replace `SuccChainFMCS` entirely with a new FMCS built from restricted chains — requiring proof that each full `SerialMCS` can be turned into a `DeferralRestrictedSerialMCS` (this is non-trivial: which phi to restrict to?)
2. OR prove `succ_chain_forward_F` separately for `forward_chain`/`backward_chain` and wire it in.

Plan 07's Phase 5 proposes creating a `restricted_Z_chain_family` as a new FMCS, but the connection to the actual families in `boxClassFamilies` is left entirely unaddressed. The plan says "Wire to `bfmcs_from_mcs_temporally_coherent`" without specifying how the restricted chain over phi relates to the unrestricted chain built for an arbitrary MCS W with `box_class_agree M0 W`.

## Recommended Approach

Plan 07 identifies the correct mathematical mechanism (transfer-back via DRM maximality) but has three problems:

1. **Phase 1 is already done** — `extendToMCS_transfer_back` exists and is sorry-free (line 3180).

2. **Phase 3 has hidden sorry debt** — `constrained_predecessor_restricted_g_persistence_reverse` and `constrained_predecessor_restricted_f_step_forward` have structural sorries that need resolution before Phase 3 can be considered complete.

3. **Phase 5 integration is underspecified** — the connection between a restricted Z_chain (over a fixed phi) and the `boxClassFamilies` structure (which uses arbitrary MCS W) is the hardest part of the plan and receives the least treatment.

**Most viable path**: Fix Phase 3's two sorry lemmas first (they are well-defined problems), then address the formula-phi relationship between `SuccChainFMCS` and the restricted chain. The transfer-back machinery (Phase 1) can be skipped — it's done.

**Alternative**: Rather than building restricted_Z_chain_family as a separate FMCS, prove `succ_chain_forward_F` directly for the `succ_chain_fam` using the restricted chain transfer-back approach: given `F(psi) ∈ succ_chain_fam M0 t`, the restricted chain for `phi = M0.world_formula` (if such exists) can provide the witness. This avoids the Phase 5 integration complexity.

## Confidence Level

**Medium** — The mathematical content of Plan 07 (transfer-back via DRM maximality) is sound and partially implemented. The sorry-free status of Phase 1 is confirmed. However, the backward chain sorries and the Phase 5 integration gap are real obstacles that the plan does not adequately address. The overall plan is not "ready to implement" as-is; Phases 3 and 5 need significant revision.

## References

- `SuccChainFMCS.lean:3116–3203` — extendToMCS and transfer-back (already sorry-free)
- `SuccChainFMCS.lean:3067–3075` — restricted_forward_chain_forward_F (sorry-free)
- `SuccChainFMCS.lean:3856–3944` — constrained_predecessor_restricted_g_persistence_reverse (sorry)
- `SuccChainFMCS.lean:3954–4001` — constrained_predecessor_restricted_f_step_forward (sorry)
- `SuccChainFMCS.lean:4006–4011` — constrained_predecessor_restricted_succ (depends on both sorries above)
- `SuccChainFMCS.lean:980–984` — SuccChainFMCS definition (no forward_F/backward_P)
- `UltrafilterChain.lean:1553–1557` — boxClassFamilies definition
- `UltrafilterChain.lean:2853–2858` — construct_bfmcs_bundle definition
- `SubformulaClosure.lean:695–696` — deferralClosure definition
- `Completeness.lean:220–226` — bfmcs_from_mcs_temporally_coherent (the sorry to eliminate)
- `TemporalCoherence.lean:216–219` — BFMCS.temporally_coherent definition
