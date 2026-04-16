# Implementation Summary: Close BXCanonical Embedding (v22)

- **Task**: 93 - Complete BXCanonical embedding
- **Status**: [PARTIAL]
- **Plan**: plans/22_bxcanonical-embedding.md
- **Phases Completed**: 0 of 5 (Phase 2 partial, Phases 1/3/4/5 blocked)

## What Was Accomplished

### New Theorems (sorry-free, build-passing)

Two new theorems were added to `RootScopedChain.lean`:

1. **`target_resolving_fwd_exists_strong`** (line ~1137): When target is bx11_earlier than all other F-defects, there exists M' with:
   - target directly in M' (not disjunctive)
   - F(chi) in M' for ALL other chi (F-obligations fully preserved)
   - g_content(M) in M'

   This strengthens `target_stays_direct_in_fold` by upgrading the disjunctive chi-in-M'-or-F(chi)-in-M' guarantee to the unconditional F(chi)-in-M' guarantee, using phi-implies-F(phi).

2. These theorems compile without sorry and pass `lean_verify` with clean axiom set.

### Mathematical Analysis (Phase 1 gate check)

Thorough analysis of the fold-order trick and extended-seed approaches revealed fundamental mathematical obstructions:

#### Dead End 1: Extended seed {target} union g_content(M) union f_carry(M)

**Proved inconsistent by counterexample.** Consider MCS M with:
- F(psi) in M, F(chi) in M
- G(psi implies G(neg chi)) in M

Then {psi, F(chi)} union g_content(M) contains both psi and (psi implies G(neg chi)) (from g_content). From psi and the implication: G(neg chi) in M'. From G(neg chi) by temp_t: neg chi in M'. But F(chi) = neg G(neg chi) and G(neg chi) both in M', contradiction with consistency of M'.

This proves that adding f_carry to the forward temporal witness seed does NOT always yield a consistent set. The reason: G-lifting of F-formulas is impossible because G(F(chi)) is not guaranteed from F(chi).

#### Dead End 2: Fold-order trick (processing target last)

When target is processed last in the BX11 fold, BX11 at the last step gives:
- Case 1: F(beta AND target) - target is a direct conjunct (good)
- Case 2: F(beta AND F(target)) - target is F-wrapped (bad)
- Case 3: F(F(beta) AND target) - target is a direct conjunct (good)

Cases 1 and 3 resolve target directly. But Case 2 can fire when target is strictly "later" than the compound beta, and we cannot control which BX11 disjunct holds in the MCS.

#### Dead End 3: Defect-count decrease argument

The F-obligation set {chi in sigma_list | F(chi) in chain(m)} is CONSTANT (never grows by no_new_f_defects, never shrinks by F-obligation persistence). The "defect count" {chi | F(chi) in chain(m) AND chi not-in chain(m)} can fluctuate: formulas can be resolved then lost again. So defect count is NOT a valid well-founded measure.

#### Dead End 4: BX11 ordering convergence

Even with `target_resolving_fwd_exists_strong` (which resolves the bx11-earliest defect while preserving all F-obligations), forward_F requires showing that every formula eventually becomes bx11-earliest. The BX11 ordering depends on the MCS at each step and can change arbitrarily. There is no guarantee that a given formula ever becomes the earliest, even as the chain continues forever.

### Root Cause of All 6 Sorries

All 6 sorries depend on the same fundamental gap: proving `rr_fwd_chain_forward_F`. The chain step (enriched_fwd_step via resolving_enriched_fwd_exists) provides only a DISJUNCTIVE guarantee: target in M' OR F(target) in M'. The choice is made by Classical.choice during Lindenbaum extension and cannot be controlled. No purely syntactic argument can prove that psi is eventually directly present, because:

1. The Lindenbaum extension is non-deterministic
2. F(psi) and neg(psi) are syntactically consistent (they mean "psi holds in the future" and "psi doesn't hold now")
3. Both can persist forever in an omega-chain without contradiction

The fundamental issue is that forward_F is a SEMANTIC property (relating to the meaning of F as "eventually") that cannot be derived from SYNTACTIC properties of individual MCS chain steps. Proving it requires either:

(a) A chain construction where target resolution is deterministic (not disjunctive), OR
(b) A semantic/model-theoretic argument that breaks the syntax-semantics barrier

### Remaining Path Forward

The most promising approach not yet explored:

**Approach (a): Deterministic target resolution via BX11-ordered chain**

Define a new chain step using `target_resolving_fwd_exists_strong` that always resolves the bx11-earliest F-defect. This gives deterministic target resolution. The remaining gap is proving that every formula eventually becomes bx11-earliest. This may require:

- An analysis of how the BX11 ordering changes across chain steps
- Possibly a semantic argument using the restricted truth lemma for G/H-formulas (which don't need forward_F) to constrain the BX11 ordering evolution
- A "pumping" argument showing that if a formula is perpetually non-earliest, some derived G-formula would force a contradiction

**Approach (b): Quasimodel or filtration bridge**

Instead of proving forward_F for the chain directly, construct the BFMCS using a tree-based canonical model (where forward_F is trivial) and then linearize using a semantic argument.

## Files Modified

- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean`: Added `target_resolving_fwd_exists_strong` (2 new sorry-free theorems, ~25 lines)
- `specs/093_complete_bxcanonical_embedding/plans/22_bxcanonical-embedding.md`: Updated phase status markers

## Verification

- `lake build`: Passes (modulo existing 6 sorry warnings)
- `lean_verify target_resolving_fwd_exists_strong`: Clean axiom set (propext, Classical.choice, Quot.sound)
- Sorry count: Unchanged at 6
- No new axioms introduced
