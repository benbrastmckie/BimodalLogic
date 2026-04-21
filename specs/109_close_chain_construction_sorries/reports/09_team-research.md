# Research Report: Task #109

**Task**: Close chain construction sorries for sorry-free completeness
**Date**: 2026-04-21
**Mode**: Team Research (4 teammates)
**Session**: sess_1776787407_73b01a

## Summary

Four teammates conducted the deepest analysis yet of the chain construction problem, combining first-principles semantic analysis, comprehensive literature survey, critical audit of 60+ prior research rounds, and systematic evaluation of all viable solution paths. The unanimous conclusion is a **root cause diagnosis** that reframes the entire problem:

**The ProofChecker's semantic convention (strict Until witness s > t with half-open guard [t,s)) is non-standard and appears nowhere in the temporal logic literature.** It is a hybrid of two established traditions that uniquely makes `ψ → φ U ψ` (BX8) invalid — the only convention with this property. Every chain-based completeness proof in the literature (Burgess 1984, Xu 1988, Goldblatt 1992) uses reflexive Until where BX8 is valid. Authors who use strict Until (Venema 1993, Reynolds 1996) employ fundamentally different proof architectures (quasimodels, IRR rule) that avoid chain constructions entirely.

**The recommended solution is full reflexive restoration** (Path B): change G/H from strict (<) to reflexive (≤) and Until/Since witness from strict (s > t) to reflexive (s ≥ t). This closes all 3 sorry sites, restores the complete Burgess-Xu axiomatization, and aligns with the dominant tradition in temporal logic. Estimated effort: 20-35 hours. The alternative — a hybrid with reflexive Until but irreflexive G — is blocked by BX10 unsoundness.

## Key Findings

### 1. The A2 Semantic Convention Is Non-Standard (ALL Teammates, VERY HIGH confidence)

The temporal logic literature has exactly two traditions:

| Convention | Witness | Guard | φ at t? | ψ → φ U ψ? | Used by |
|-----------|---------|-------|---------|-------------|---------|
| Strict (philosophical) | s > t | open (t,s) | NO | Not generally valid | Kamp, Venema, Reynolds |
| Reflexive (CS/LTL) | s ≥ t | half-open [t,s) | YES (unless s=t) | VALID | Burgess, Xu, Goldblatt, Pnueli |
| **ProofChecker A2** | **s > t** | **half-open [t,s)** | **YES** | **NOT VALID** | **No standard reference** |

The A2 hybrid combines the strictest witness requirement with a closed-at-start guard, uniquely making BX8 invalid. The SEP entry on temporal logic, Wikipedia, and all major textbooks describe only the two standard conventions. No author uses A2.

### 2. psi_imp_until Is Irreparable Under A2 Semantics (Teammates A, B, D, CERTAIN confidence)

Under A2: `φ U ψ` at t requires ∃s > t (strict). Having ψ at t provides no witness. No weaker replacement works:
- `φ ∧ F(ψ) → φ U ψ`: UNSOUND (φ not guaranteed at intermediate points)
- `G(φ ∨ ψ) ∧ φ ∧ F(ψ) → φ U ψ`: Sound but NOT in the current axiom system
- `F(ψ) → ⊤ U ψ`: Already BX12, but only gives trivial guard

The impact chain traces through 16+ downstream consumers including `backward_until_reflexive`, `or_until_imp`, `until_intro`, `refl_F`, and the base case of `backward_until_from_step`.

### 3. Reflexive-Until-Only (Path A/E) Is Blocked by BX10 (Teammate D, VERY HIGH confidence)

Making Until reflexive (s ≥ t) while keeping G/F irreflexive (s > t) breaks BX10: `(φ U ψ) → F(ψ)`. When the Until witness is s = t, F(ψ) needs a strictly future witness that doesn't exist. This eliminates all "partial restoration" approaches — you cannot decouple Until reflexivity from G/F reflexivity while retaining BX10.

### 4. The BX Axiom System Is Likely Incomplete for A2 Semantics (Teammates A, B, HIGH confidence)

With BX8 removed, there is no axiom that introduces `φ U ψ` from separate hypotheses about φ and ψ. BX12 only gives `⊤ U φ` from `F(φ)`. BX5/BX6 transform existing Until formulas. Without any Until-introduction axiom, the proof system cannot derive Until formulas from temporal hypotheses. The standard strict-Until axiomatization (Venema 1993) adds replacement axioms like `F(φ) → (¬φ) U φ` and uses the IRR rule — neither is present in BX.

### 5. The g_content Opacity Problem Is Genuine and Structural (ALL Teammates, CERTAIN confidence)

`g_content(M) = {α | G(α) ∈ M}`. Under irreflexive G, `G(α) ∈ M` does NOT imply `α ∈ M`, so `g_content(M) ⊄ M`. F-formulas and Until-formulas are not G-formulas, so they are invisible to g_content propagation and can be permanently destroyed by Lindenbaum extension at any chain step. This has been confirmed by:
- Semantic counterexample (F(φ) at t = -1, G(F(φ)) fails)
- Exhaustive audit of all 35 BX axioms
- 19+ failed chain construction approaches over 60+ research rounds

Under reflexive G, `g_content(M) ⊆ M` holds via the T-axiom, making the Lindenbaum seed much richer and preventing silent F-obligation destruction.

### 6. The Backward Until Problem Has a DOUBLE Obstruction (Teammates A, C, VERY HIGH confidence)

Sorry #2 (`restricted_buc`) faces two independent obstacles:
1. **Shared with sorry #1**: g_content opacity destroys F/Until obligations
2. **Unique to sorry #2**: `psi_imp_until` is sorry'd (semantically invalid under A2), breaking the base case of backward Until induction

Under irreflexive Until, the base case (witness at s = t) is impossible. The induction base becomes s = t + 1, which reduces entirely to the "step transfer" property: `(φ U ψ) ∈ chain(r+1) ∧ φ ∈ chain(r) → (φ U ψ) ∈ chain(r)`. This is semantically valid but not derivable from g_content alone.

### 7. 33 Approaches Cataloged; Only 5 Ever Tested in Lean (Teammate C, HIGH confidence)

Teammate C's critical audit identified 33 distinct approaches across 60+ research rounds. Only 5 made it to actual Lean implementation. Key orphaned work:
- **Ordered Seed Consistency Theorem** (`OrderedSeedConsistency.lean`): Proved sorry-free, never used in any chain construction. The 3-cycle problem blocked one application but doesn't invalidate the theorem.
- **Strategy C** (direct witness contradiction): 60% confidence, never implemented
- **F-tower compound** (self-resolving BX11 fold): Novel idea, estimated 650 LOC, never attempted

The research has been going in circles: Reports 07-08 (task 109) rediscovered what Reports 13-16 (task 93) had already established.

### 8. Full Reflexive Restoration (Path B) Is the Consensus Recommendation (Teammates B, C, D, HIGH confidence)

Under full reflexive semantics (G: ≤, H: ≥, Until: s ≥ t, Since: s ≤ t):
- All 35 BX axioms remain sound (verified by Teammate D against each axiom)
- BX8 can be restored (ψ → φ U ψ valid with witness s = t)
- BX1 (G(φ) → φ) becomes valid, closing `bx_le_refl` sorry
- `psi_imp_until` and `psi_imp_since` become provable
- The Ordered Seed Consistency approach from task 93 report 13 becomes viable
- Aligns with Burgess (1984), Goldblatt (1992), Xu (1988)

**Implementation estimate**: 20-35 hours across 5 phases:
1. Semantic restoration in Truth.lean (5-8h)
2. Axiom system update (3-5h)
3. Soundness re-proofs (5-8h)
4. Close sorry sites (5-10h)
5. Verification (2-4h)

## Synthesis

### Conflicts Resolved

**Conflict 1: Augment axiom system vs. change semantics?**
- Teammate A recommends augmenting the axiom system with a strict-Until introduction axiom
- Teammates B, D recommend changing the semantics to reflexive
- **Resolution**: Axiom augmentation cannot close sorry #2 (backward Until) because `psi_imp_until` is semantically invalid regardless of what axioms are added — the issue is the semantic definition, not the proof system. Only changing the semantics resolves all 3 sorries. Teammate A's analysis supports this indirectly by showing the current system is incomplete.

**Conflict 2: Full reflexive (Path B) vs. semantic completeness (Path C)?**
- Teammates B, D recommend Path B (reflexive restoration, 20-35h)
- Teammate C notes both are viable but flags that Path B has been deferred for 60+ rounds
- **Resolution**: Path B is preferred due to 2x lower effort and full reuse of existing infrastructure. Path C (40-60h) is the principled fallback if the user requires irreflexive semantics for philosophical reasons. The key advantage of Path B is that it aligns with ALL standard completeness proofs in the literature — there is no precedent for chain-based completeness under A2 semantics.

**Conflict 3: Is the Ordered Seed Consistency approach still viable?**
- Teammate C notes it was proved but never used (orphaned infrastructure)
- Teammate A confirms the theorem is correct
- Teammate D suggests it becomes viable under reflexive semantics
- **Resolution**: The theorem is correct. The 3-cycle problem blocked one USE of it (finding a global BX11 minimum) but not the theorem itself. Under reflexive semantics, the defect-discharge chain construction from task 93 report 13 becomes viable end-to-end. Under A2 semantics, the 3-cycle problem and the separate backward Until obstruction make it insufficient.

### Gaps Identified

1. **Has anyone verified soundness of BX axioms under ≤ directly?** Teammate D checked all axioms conceptually but not in Lean. A quick soundness check (1-2 hours) before committing to Path B would de-risk Phase 3.

2. **Can strict semantics be recovered as derived operators?** If the paper requires strict-future G, define `G_strict(φ) = G(φ) ∧ ¬φ` in the metatheory after proving completeness for reflexive G. This preserves the philosophical intent while using reflexive semantics for the proof.

3. **Is the BX11 3-cycle problem avoidable for the finite defect set?** The counterexample used arbitrary formulas. Within `deferralClosure(root)`, structural constraints may prevent 3-cycles. This is relevant only if pursuing Path C or staying with A2 semantics.

4. **Several TemporalDerived.lean sorries may be closable now**: `G_bot_absurd` and `H_bot_absurd` should be provable from seriality axioms under current semantics, regardless of the reflexive/irreflexive choice. These haven't been audited.

### Recommendations

**Primary (Path B — Full Reflexive Restoration)**:
1. Change Truth.lean: four `<` become `≤` (G/H/Until/Since)
2. Restore BX8/BX8' in Axioms.lean
3. Re-prove soundness (minor restructuring, ~5-8h)
4. Close all sorry sites using Ordered Seed Consistency approach + restored BX8
5. Verify with `lake build`

**Fallback (Path C — Semantic Completeness)**:
If irreflexive semantics must be preserved, build new canonical model using full MCS space with `bx_forward_witness` for F-resolution and quasimodel-style Until coherence. Estimated 40-60 hours.

**Not recommended**: Further research on closing sorries under A2 semantics with the current chain construction. The obstruction is structural and has been confirmed by 33 distinct approaches over 60+ rounds.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|-----------------|
| A | First-principles semantics | completed | high | psi_imp_until dependency chain (16+ consumers); Ordered Seed Consistency verification; axiom incompleteness analysis |
| B | Literature survey | completed | high | **A2 convention non-standard** finding; two-tradition taxonomy; Venema/Reynolds strict-Until axioms identified |
| C | Critical audit | completed | very high | **33 approaches cataloged**, 28 never tested; Ordered Seed Consistency orphaned; research-in-circles diagnosis |
| D | Solution architecture | completed | high | **BX10 blocks Path A/E** (critical discovery); Path B implementation sketch with 5-phase plan |

## References

### Codebase
- `Theories/Bimodal/Semantics/Truth.lean` — semantic definitions (lines 125-130)
- `Theories/Bimodal/ProofSystem/Axioms.lean` — all 35 BX axioms
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` — 3 sorry sites
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` — g_content, bx_forward_witness, bx_le_refl sorry
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` — fwd_succ, schedule chain
- `Theories/Bimodal/Theorems/TemporalDerived.lean` — psi_imp_until (sorry'd)
- `Theories/Bimodal/Metalogic/Bundle/UntilSinceCoherence.lean` — backward_until_from_step
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` — coherence definitions
- `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` — forward_temporal_witness_seed

### Literature
- Burgess (1982/1984) — reflexive G/H and Until/Since; constructive chain completeness
- Xu (1988) — simplified Burgess-Xu; reflexive conventions
- Goldblatt (1992) — canonical model with schedule; reflexive temporal operators
- Venema (1993) — strict-ordering extensions; F(φ) → (¬φ) U φ axiom
- Reynolds (1996, 2003) — strict Until with quasimodels and IRR rule
- GHR (1994, Ch. 6) — quasimodel unraveling technique
- de Jongh/Veltman/Verbrugge — completeness by construction for tense logics
- Stanford Encyclopedia of Philosophy: Temporal Logic supplement

### Prior Research
- Task 93 (51 rounds): Irreflexive semantics transition, forward_F obstruction discovery
- Task 93 Report 13: Ordered Seed Consistency Theorem (proved, never used in chain construction)
- Task 109 Reports 01-08: All chain-based approaches exhaustively explored under A2 semantics
