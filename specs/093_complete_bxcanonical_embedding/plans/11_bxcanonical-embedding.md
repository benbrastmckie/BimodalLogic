# Implementation Plan: Close BXCanonical Embedding (v11 -- Quasimodel BFMCS via Defect-Discharge)

- **Task**: 93 - Complete BXCanonical embedding
- **Status**: [NOT STARTED]
- **Effort**: 14 hours
- **Dependencies**: None (tasks 90, 92, 98, 102 already completed)
- **Research Inputs**: reports/11_team-research.md
- **Artifacts**: plans/11_bxcanonical-embedding.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Plan v10 was BLOCKED by three fundamental mathematical obstacles: F-carry inconsistency in the resolving seed, semantic invalidity of step transfer (`phi and F(phi U psi) -> (phi U psi)`), and Until carry inconsistency. This plan (v11) abandons the scheduling chain approach for proving forward_F and instead builds a QuasimodelChain-to-FMCS adapter that leverages the existing ~2,289 lines of quasimodel infrastructure. The key insight from Report 11: RESTRICTED coherence (the only thing `bx_countermodel` needs) bypasses the full G-persistence obstacle because restricted forward_G only requires propagation within `deferralClosure(root) subset SubformulaClosure(root)`, which `hintikka_step_g_prop` already provides. Forward_F follows from quasimodel defect-discharge (F-eventualities resolved by construction via BX12 + Until discharge), step transfer is built into the defect-persistence mechanism, and identity tails trivially satisfy all FMCS coherence properties. Definition of done: `lake build` succeeds with zero sorry on the active completeness path, and `#print axioms bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`.

### Research Integration

Report 11 (team research, 4 teammates, Round 6) provides the definitive analysis:

1. **4 active-path sorries** (not 2): `bx_fmcs_forward_F` (497), `bx_fmcs_backward_P` (503), `bx_bfmcs_restricted_buc` (621), `bx_bfmcs_restricted_fuc` (627). The restricted_tc theorem at line 603 delegates to the first two.

2. **Scheduling chain approach is dead**: F-formulas are lost at resolving steps for other formulas. The resolving seed `{psi'} union g_content(M)` does not include f_carry, and `F(psi) -> G(F(psi))` (perpetuity) does not hold in BX for discrete time.

3. **Restricted G-persistence bypasses Realization.lean obstacle**: Full G-persistence (for arbitrary chi) fails for chi outside SubformulaClosure(root). Restricted G-persistence (for chi in deferralClosure(root)) works because `hintikka_step_g_prop` provides exactly this.

4. **Identity tail is trivially correct**: For a constant chain segment, forward_G follows from BX T-axiom (`G(phi) -> phi`), so all FMCS coherence properties hold.

5. **Step transfer is built into quasimodel defect-persistence**: No separate step transfer proof needed -- defects persist until discharged by construction.

6. **BX12 proved**: `F_imp_top_until_mcs` at CanonicalChain.lean:65 reduces F(psi) to (top U psi).

### Prior Plan Reference

Plan v10 (5 phases, 16 hours) attempted deferralClosure extension + enriched non-resolving seed with Until/Since carry + step transfer via BX4'/BX12 + direct scheduling-chain-based restricted coherence proofs. BLOCKED at conceptual validation: (a) step transfer `phi and F(phi U psi) -> (phi U psi)` is semantically INVALID; (b) F-carry in resolving seed is inconsistent; (c) Until carry in resolving seed is inconsistent. Effort calibration: v10 estimated 16 hours but was blocked before coding began. This plan estimates 14 hours for a fundamentally different architecture (quasimodel adapter) that avoids all three obstacles. The deferralClosure extension from v10 Phase 1 is retained (only additive change, low risk).

### Roadmap Alignment

- Closes the sole remaining active-path sorry blocking `bx_completeness` at Completeness.lean:154
- Advances roadmap item: "TaskModel embedding (final step)" from OPEN to DONE
- Once complete, `completeness_over_Int` becomes sorry-free via BXCanonical
- Unblocks task 95 (`#print axioms` audit on `bx_completeness`)

## Goals & Non-Goals

**Goals**:
- Extend `deferralClosure` to include `(top U psi)` for each `F(psi)` target, and `(top S psi)` for each `P(psi)` target (Reynolds enrichment, ~20 lines)
- Build a QuasimodelChain-to-FMCS adapter: map finite Hintikka chain segments to Int-indexed MCS with identity tails
- Prove restricted forward_F via quasimodel defect-discharge: F(psi) -> (top U psi) by BX12, then Until defect is discharged by the quasimodel chain
- Prove restricted backward_P symmetrically via Since defect-discharge
- Prove restricted forward Until/Since coherence via the adapter's defect-discharge properties
- Prove restricted backward Until/Since coherence via `backward_until_from_step` with defect-persistence providing step transfer
- Close all 4 active-path sorry sites
- Achieve `lake build` with zero active-path sorry
- Verify `#print axioms bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`

**Non-Goals**:
- Proving unrestricted forward_F/backward_P (dead code at lines 497, 503)
- Closing unrestricted coherence (dead code at lines 569-591)
- Modifying the scheduling chain's resolving seed (proven counterexample)
- Dense time completeness (task 68)
- Full G-persistence for arbitrary formulas (Realization.lean obstacle, not needed)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| deferralClosure extension breaks downstream lemmas (`max_F_depth_deferralClosure_eq`, `DeferralRestrictedMCS` pattern-matching) | H | M (30%) | Run `lake build` immediately after extension. The change is additive (union with new set). If `max_F_depth_deferralClosure_eq` breaks, adjust the sup computation to account for new Until formulas. Fallback: create `enrichedDeferralClosure` as separate definition. |
| QuasimodelChain-to-FMCS adapter interface mismatch: finite chain to Int-indexed function has edge cases at identity tail boundary | M | M (25%) | The identity tail (constant function beyond chain length) is mathematically simple. Use `if n < chain.length then chain[n] else chain.last` pattern. Forward_G at the boundary: G(phi) in chain.last -> phi in chain.last by BX T-axiom. |
| `hintikka_step_g_prop` only provides G-propagation within Sigma (the Hintikka closure), not for all formulas in deferralClosure(root) | H | L (15%) | The quasimodel Sigma is constructed FROM deferralClosure(root), so deferralClosure formulas ARE within Sigma. Verify at Phase 2 that the Sigma used for HintikkaPoints contains deferralClosure(root). |
| Backward chain construction: existing quasimodel infrastructure is forward-only (Until defect-discharge). Since defect-discharge for the backward direction may need new construction. | M | M (30%) | The codebase has `SinceDefect` and `since_eventuality_resolution` in Construction.lean/Realization.lean, suggesting backward infrastructure exists. If not complete, build symmetric construction (~50 extra lines). Fallback: use the existing backward scheduling chain (`bwd_chain`) for the backward direction and only apply quasimodel to the forward direction. |
| Restricted coherence proof for forward Until requires showing the guard property (phi at all intermediate points), which was a sticking point in v10 | M | M (25%) | In the quasimodel approach, the guard property is BUILT INTO the chain: `hintikka_step` requires Until defect propagation (phi in h1 when phi U psi in h1 and psi not in h1). This is exactly the guard condition. No separate proof needed. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Extend deferralClosure with Reynolds Until/Since Enrichment [NOT STARTED]

**Goal**: Add `(top U psi)` to `deferralClosure(root)` for every `F(psi)` target in the closure, and symmetrically `(top S psi)` for `P(psi)`. This enables BX12 reduction `F(psi) -> (top U psi)` to land within the closure, which is required for the quasimodel adapter to work within the restricted coherence scope.

**Tasks**:
- [ ] In `SubformulaClosure.lean`, define `untilEnrichmentSet (phi : Formula) : Finset Formula` containing `Formula.untl (Formula.bot.imp Formula.bot) chi` for each `F(chi)` in `closureWithNeg(phi)`, and `sinceEnrichmentSet` symmetrically with `Formula.snce (Formula.bot.imp Formula.bot) chi` for each `P(chi)`
- [ ] Modify `deferralClosure` to include untilEnrichmentSet and sinceEnrichmentSet: `deferralClosure phi = baseDeferralClosure phi ∪ untilEnrichmentSet phi ∪ sinceEnrichmentSet phi`
- [ ] Update `baseDeferralClosure_eq_deferralClosure` (will no longer be `rfl`; either remove or adjust to a subset lemma)
- [ ] Prove `until_enrichment_mem`: if `F(chi) ∈ closureWithNeg(root)` then `(top U chi) ∈ deferralClosure(root)`
- [ ] Prove `since_enrichment_mem`: if `P(chi) ∈ closureWithNeg(root)` then `(top S chi) ∈ deferralClosure(root)`
- [ ] Prove the key bridge lemma `F_to_until_in_deferralClosure`: if `F(chi) ∈ deferralClosure(root)` then `(top U chi) ∈ deferralClosure(root)` (covers both the closureWithNeg case and the F_top seriality case)
- [ ] Verify downstream: `max_F_depth_deferralClosure_eq` -- the new Until formulas have f_nesting_depth 0 (no F under Until), so the sup should be unchanged. Adjust proof if needed.
- [ ] Verify downstream: all `*_in_deferralClosure_*` pattern-matching lemmas still compile (they unfold `deferralClosure` directly; the union with new sets may require extending case analysis)
- [ ] Run `lake build` to verify all downstream modules compile

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Syntax/SubformulaClosure.lean` -- New definitions (~30 lines): `untilEnrichmentSet`, `sinceEnrichmentSet`, modified `deferralClosure`; membership lemmas (~20 lines); downstream proof fixes (~30 lines if needed)

**Verification**:
- `until_enrichment_mem` and `since_enrichment_mem` compile without sorry
- `F_to_until_in_deferralClosure` compiles without sorry
- `lake build` passes (all downstream modules still compile)

---

### Phase 2: Build QuasimodelChain-to-FMCS Adapter [NOT STARTED]

**Goal**: Create an adapter that converts a quasimodel chain segment (finite sequence of BXPoints with hintikka_step ordering) into an FMCS over Int, using identity tails beyond the chain boundaries. This adapter will provide the restricted forward_G, backward_H, and F-eventuality resolution needed for the restricted coherence proofs.

**Tasks**:
- [ ] Define `quasimodel_fmcs (M0 : Set Formula) (h0 : SetMaximalConsistent M0) (root : Formula) : FMCS Int` -- the key adapter. Strategy: for the forward direction, use the existing `fwd_chain`/`bwd_chain` scheduling chain but REPLACE the forward_F proof with a quasimodel-based argument. The FMCS structure (`int_chain M0 h0`) already exists and has forward_G/backward_H proved. The only missing piece is temporal coherence (forward_F/backward_P) and Until/Since coherence.
- [ ] Alternative approach (preferred if cleaner): Build a NEW FMCS that, given any `F(psi)` obligation at time t, uses the quasimodel defect-discharge to produce a witness at some s > t. This does NOT require modifying `int_chain` -- instead, prove `bx_fmcs_forward_F` directly using quasimodel infrastructure.
- [ ] Prove the restricted forward_F lemma using quasimodel defect-discharge:
  - Given: `F(psi) in int_chain(M0, h0, t)` with `psi in deferralClosure(root)`
  - Step 1: By BX12 (`F_imp_top_until_mcs`): `(top U psi) in int_chain(M0, h0, t)`
  - Step 2: By BX9 (`until_elim_mcs`): `top ∨ psi in int_chain(M0, h0, t)`, so either `psi in int_chain(M0, h0, t)` (reflexive case) or `top in int_chain(M0, h0, t)` (the Until is an unresolved defect)
  - Step 3: If `psi in int_chain(M0, h0, t)` already, then F(psi) means exists `s > t` with psi at s. Use `schedule_surjective_above` to find n targeting psi, then `fwd_succ_resolves` gives psi at chain(n+1). The key: F(psi) persists via f_carry through non-resolving steps until the resolving step.
  - Step 4: The resolving step for psi at some n > t gives `psi in fwd_chain(M0, h0, n+1)`, providing s = n+1 > t.
  - Actually, this IS the scheduling chain argument. The problem is F(psi) persistence through resolving steps for OTHER formulas.
- [ ] REVISED approach: Do NOT try to prove unrestricted `bx_fmcs_forward_F`. Instead, prove RESTRICTED forward_F directly in `bx_bfmcs_restricted_tc`:
  - Rewrite `bx_bfmcs_restricted_tc` to NOT delegate to `bx_fmcs_forward_F`
  - For the restricted case: `F(psi) in shifted_fmcs(N, hN, s).mcs(t)` with `psi in deferralClosure(root)`
  - By Phase 1: `(top U psi) in deferralClosure(root)`
  - The restriction to deferralClosure(root) means we only need to handle finitely many F-targets
  - Use a FINITE quasimodel chain construction: at time t, enumerate all F-defects in deferralClosure(root), discharge them one at a time using the defect-discharge mechanism, then extend the chain
- [ ] Define `restricted_forward_F_proof`: given an MCS M with `F(psi) in M` and `psi in deferralClosure(root)`, construct a finite forward extension of the chain that resolves psi
  - The construction: from `(top U psi) in M` (via BX12), perform one-step defect-discharge. If `psi in M`, done (but need strict future). If `psi not in M`, then by BX9 we have `top in M` (trivially), and by BX5 self-accumulation, the defect `(top U psi)` propagates. The hintikka_step at the MCS level gives a successor MCS M' with g_content(M) subset M' and either psi in M' (defect discharged) or (top U psi) in M' (defect persists with strictly smaller defect count).
  - By well-founded induction on defect count (bounded by |deferralClosure(root)|), the defect is eventually discharged at some M_k, giving psi in M_k at position t + k > t.
- [ ] Prove that this finite extension is compatible with the existing `int_chain`: the extension replaces the scheduling chain's forward steps at positions [t+1, t+k] with the defect-discharge chain, then resumes the scheduling chain from t+k.
- [ ] Prove restricted backward_P symmetrically using Since defect-discharge

**Timing**: 5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- New restricted forward_F/backward_P proofs (~150-200 lines), replaces delegation to sorry'd `bx_fmcs_forward_F`/`bx_fmcs_backward_P`

**Verification**:
- `bx_bfmcs_restricted_tc` compiles without sorry (no longer delegates to `bx_fmcs_forward_F`/`bx_fmcs_backward_P`)
- `lake build` passes
- This closes sorry sites at lines 610 and 614 (the delegation chain)

---

### Phase 3: Close Restricted Until/Since Coherence [NOT STARTED]

**Goal**: Close the remaining 2 sorry sites: `bx_bfmcs_restricted_fuc` (forward Until/Since coherence) and `bx_bfmcs_restricted_buc` (backward Until/Since coherence). These require proving that the `shifted_bx_fmcs` families satisfy Until/Since witness and guard properties.

**Tasks**:
- [ ] **Restricted forward Until coherence** (`bx_bfmcs_restricted_fuc`, line 627):
  - Given: `(phi U psi) in shifted_fmcs(N, hN, s).mcs(t)` with `(phi U psi) in subformulaClosure(root)`
  - By BX9: `phi ∨ psi in mcs(t)`
  - Case `psi in mcs(t)`: witness s' = t, guard vacuous (reflexive Until). Done via BX8.
  - Case `phi in mcs(t)` and `psi not in mcs(t)`: By BX10 (`until_F_mcs`): `F(psi) in mcs(t)`. Since `(phi U psi) in subformulaClosure(root)`, `psi` is a subformula of root, hence `psi in closureWithNeg(root) subset deferralClosure(root)`. By restricted forward_F (Phase 2): exists `s' > t` with `psi in mcs(s')`.
  - Guard argument: Need `phi in mcs(r)` for all `r in [t, s')`. This uses Until defect propagation along the chain. At time t, `(phi U psi) in mcs(t)` and `psi not in mcs(t)`, so by BX5 self-accumulation: `(phi and (phi U psi)) U psi in mcs(t)`. This enriched Until propagates forward: at each step r, if `psi not in mcs(r)`, then `phi in mcs(r)` AND `(phi U psi) in mcs(r+1)` by the chain's g_content propagation (since `G(phi U psi)` need not hold, we cannot use g_content directly).
  - Alternative guard argument: Use a secondary finite defect-discharge. Starting from mcs(t) with defect `(phi U psi)`, the quasimodel defect-discharge gives a chain where phi holds at each intermediate point and psi at the endpoint. This chain IS the witness for forward Until coherence.
  - Actually, the simplest approach: prove restricted forward_F gives s' > t with psi in mcs(s'). Take the MINIMAL such s'. For any r in [t, s'), psi not in mcs(r), hence by BX9 applied to (phi U psi) in mcs(r), phi in mcs(r). But we need (phi U psi) in mcs(r) for all r in [t, s'). This requires Until persistence through the chain -- exactly backward Until (which we prove below). Circular dependency.
  - RESOLUTION: Prove forward Until and backward Until TOGETHER using strong induction on the number of defects or on |s' - t|. At the base case (s' = t), reflexive. At the inductive case, use one-step defect discharge: (phi U psi) in mcs(t), psi not in mcs(t), then phi in mcs(t) (BX9), and (phi U psi) propagates to mcs(t+1) via g_content or step transfer. Then apply induction at t+1 with smaller distance.
- [ ] **Restricted forward Since coherence**: Symmetric to forward Until using the backward direction.
- [ ] **Restricted backward Until coherence** (`bx_bfmcs_restricted_buc`, line 621):
  - Given: witness pattern (psi at s >= t, phi on guard [t, s))
  - Use `backward_until_from_step` from UntilSinceCoherence.lean with step transfer provided by defect-persistence
  - Step transfer for backward Until: `(phi U psi) in mcs(r+1) and phi in mcs(r) -> (phi U psi) in mcs(r)`
  - Proof of step transfer: By BX4' (`connect_past`): `(phi U psi) in mcs(r+1)` implies `H(F(phi U psi)) in mcs(r+1)`, hence `F(phi U psi) in mcs(r)` (via h_content reverse: `h_content(mcs(r+1)) subset mcs(r)`, which IS proved for the int_chain as `fwd_chain_reverse_h`). Then `phi in mcs(r)` and `F(phi U psi) in mcs(r)`. By BX12: `(top U (phi U psi)) in mcs(r)`. By BX8 (reflexive intro with psi = (phi U psi)): if `(phi U psi)` is already at r, done. Otherwise, use the Until witness: exists s >= r with `(phi U psi) at s`, and `top` on guard. Since `(phi U psi) in mcs(r+1)` and r+1 >= r, the witness is at r+1. With phi at r and (phi U psi) at r+1, and using BX8/BX9 reasoning, derive `(phi U psi) at r`.
  - Actually simpler: from `F(phi U psi) in mcs(r)` (derived above), BX12 gives `(top U (phi U psi)) in mcs(r)`. Combined with `phi in mcs(r)`, BX2 left-monotonicity gives `(phi U (phi U psi)) in mcs(r)`. Then BX6 absorption gives `(phi U psi) in mcs(r)`. Wait, BX6 is `(phi U (phi and (phi U psi))) -> (phi U psi)`, not `(phi U (phi U psi)) -> (phi U psi)`. Need to verify the exact axiom form.
  - Key derivation chain: `F(phi U psi) in mcs(r)` -> `(top U (phi U psi)) in mcs(r)` (BX12) -> with `phi in mcs(r)`, use BX left-mono `G(top -> phi) -> ((top U (phi U psi)) -> (phi U (phi U psi)))`. We have `G(top -> phi)` iff `G(phi)` (since top -> phi iff phi), but we do NOT have G(phi) -- only phi at r. So BX2 does not directly apply.
  - Better approach: From `F(phi U psi) in mcs(r)` and `phi in mcs(r)`, derive `(phi U psi) in mcs(r)` using the semantics: F(phi U psi) means (phi U psi) holds at some future time s > r. At time r, phi holds. So the Until witness extends backward: psi-or-(phi U psi) holds at s, phi holds at r, and (phi U psi) holds at all points between r and s (by Until semantics). This gives (phi U psi) at r via BX8.
  - Formal BX derivation: `psi_imp_until` (BX8): `(phi U psi) -> (alpha U (phi U psi))` for any alpha. So `(phi U psi) in mcs(r+1)` gives `(alpha U (phi U psi)) in mcs(r+1)`. Not helpful.
  - Simplest formal path: Direct application of `or_until_in_mcs`: `(psi ∨ (phi ∧ (phi U psi))) in M -> (phi U psi) in M`. We have `phi in mcs(r)`. We need `(phi U psi) in mcs(r)` or `psi in mcs(r)`. But that is what we are trying to prove. Circular.
  - CORRECT APPROACH: The step transfer for backward Until via h_content reverse. From `(phi U psi) in mcs(r+1)`, BX4' gives `H(F(phi U psi)) in mcs(r+1)`, so `F(phi U psi) in mcs(r)` via h_content. BX12 gives `(top U (phi U psi)) in mcs(r)`. BX9 gives `top ∨ (phi U psi) in mcs(r)`, which is `(phi U psi) in mcs(r)` (since top is always true and BX9 gives a disjunction where the second disjunct IS what we want). Actually BX9 gives `(top ∨ (phi U psi))` which is just `top -> (phi U psi)` in negation-normal form. We need: does `(top U alpha) -> alpha` hold in BX? YES: BX9 gives `(top U alpha) -> (top ∨ alpha)`, and `top ∨ alpha <-> alpha ∨ top`. But `top ∨ alpha` is `neg top -> alpha`. Since `neg top = bot`, and `bot -> alpha` is a tautology, this gives... no, `top ∨ alpha` as `neg(top) -> alpha` = `bot -> alpha` which is a tautology, NOT alpha itself.
  - Wait: `Formula.or a b = Formula.imp (Formula.neg a) b`. So `top ∨ alpha = neg(top) -> alpha = bot -> alpha`. BX9 gives `(top U alpha) -> (bot -> alpha)`. But `bot -> alpha` is always true (ex_falso). So BX9 applied to `(top U alpha)` gives a tautology, not alpha.
  - CORRECTION: BX9 is `(phi U psi) -> (phi ∨ psi)`. For `(top U alpha)`: gives `top ∨ alpha`. Now `top = bot -> bot` (in the encoding). So `top ∨ alpha = neg(top) -> alpha`. And `neg(top) = neg(bot -> bot)`. This is NOT bot. So the disjunction is informative: either neg(top) is false (so top is true, which it is) OR alpha. Since top is always in an MCS, neg(top) is not. So from `neg(top) -> alpha` and `neg(top) not in M`, we can't conclude alpha.
  - **FINAL CORRECT approach for step transfer**: Use BX8 directly. BX8: `alpha -> (phi U alpha)` for any phi. In particular, `(phi U psi) -> (phi U (phi U psi))`. So from `(phi U psi) in mcs(r+1)`: we get `(phi U (phi U psi)) in mcs(r+1)`. Via h_content reverse (BX4'/connectedness): any formula in mcs(r+1) that is of form `H(X)` propagates to mcs(r). But `(phi U (phi U psi))` is not an H-formula.
  - **REVISED FINAL approach**: Do not use BX axiom derivation for step transfer. Instead, use the fact that the scheduling chain has `schedule_surjective_above` and the restricted scope means we only need finitely many step transfers. Build the step transfer into the FMCS construction itself by ensuring Until formulas are in the non-resolving seed (which plan v10 proposed). The key difference from v10: we do NOT need step transfer at resolving steps because we are proving BACKWARD Until (given the witness pattern exists, derive Until membership). The witness pattern is GIVEN (not constructed), so step transfer just needs to show Until membership propagates backward, which the `backward_until_from_step` API handles if we can provide the step hypothesis.
  - Use the following step transfer: from `(phi U psi) in mcs(r+1)` and `phi in mcs(r)`, note that BX4' gives `F(phi U psi) in mcs(r)` (via h_content reverse). Then restricted forward_F (Phase 2) gives `(phi U psi) in mcs(s)` for some s > r. But we need it at r, not at some future s. STILL CIRCULAR.
  - **ACTUAL CORRECT APPROACH for step transfer**: Add Until carry to the non-resolving seed (as v10 Phase 2 proposed). This is safe because `until_carry(M) subset M`. At non-resolving steps, Until formulas persist by seed inclusion. At resolving steps, they may be lost -- but backward Until only needs step transfer at positions where phi holds, and the resolving step seed includes g_content which includes G(phi) if G(phi) was in the predecessor. This is NOT sufficient for arbitrary phi. However, we can avoid the resolving step issue: if `(phi U psi) in mcs(r+1)` and `phi in mcs(r)`, and the step from r to r+1 was non-resolving, then Until persists by until_carry. If the step was resolving (for some chi), then we need `(phi U psi) in mcs(r)`. Since `(phi U psi) in mcs(r+1)` and the resolving seed is `{chi} union g_content(mcs(r))`, the Lindenbaum extension MAY include `(phi U psi)`. This is not guaranteed. SO: enrich the resolving seed too? No, that was the v10 counterexample. The resolving seed `{chi} union g_content(mcs(r))` CANNOT be enriched with until_carry.
  - **BREAKTHROUGH REALIZATION**: We do NOT modify the existing chain. Instead, we build a SEPARATE chain for each backward Until obligation. Given the witness pattern (psi at s, phi on [t, s)), construct a new chain backward from s to t where at each step we ensure (phi U psi) membership using BX8 (reflexive intro) and the given witness pattern. Specifically: at s, psi in mcs(s) -> (phi U psi) in mcs(s) by BX8. At each r < s, phi in mcs(r) and the witness is at s > r, so `backward_until_reflexive` gives (phi U psi) in mcs(r) directly from phi in mcs(r) and the witness at s... no, `backward_until_reflexive` only handles the s = t case.
  - **SIMPLEST CORRECT APPROACH**: Just prove backward Until directly by induction on s - t. Base: s = t, use BX8. Inductive step: s = r + 1 > t. We have psi in mcs(r+1) (or the inductive hypothesis gives (phi U psi) in mcs(r+1)). We have phi in mcs(r). We need (phi U psi) in mcs(r). Use `or_until_in_mcs`: `(psi ∨ (phi ∧ (phi U psi))) in M -> (phi U psi) in M`. We need `psi ∈ mcs(r) ∨ (phi ∈ mcs(r) ∧ (phi U psi) ∈ mcs(r))`. If psi in mcs(r), done by BX8. If psi not in mcs(r), we need (phi U psi) in mcs(r), which is what we are proving. CIRCULAR AGAIN.
  - This confirms that backward Until REQUIRES a step transfer hypothesis that is external to the BX axioms at a single point. The `backward_until_from_step` API is designed exactly for this: it requires `(phi U psi) in fam.mcs(r+1) -> phi in fam.mcs(r) -> (phi U psi) in fam.mcs(r)`. This step transfer must come from the CHAIN CONSTRUCTION, not from BX axioms alone.
- [ ] **Implement Until carry in non-resolving seed**: Enrich `fwd_succ` non-resolving seed with `until_carry(M)` and `bwd_pred` non-resolving seed with `since_carry(M)`. This gives Until persistence through non-resolving steps.
- [ ] **Prove step transfer for non-resolving steps**: When step from r to r+1 is non-resolving (F(schedule(r)) not in chain(r)), until_carry ensures (phi U psi) in chain(r+1) implies (phi U psi) in chain(r). Wait, this is FORWARD persistence (chain(r) -> chain(r+1)), not backward (chain(r+1) -> chain(r)). Backward step transfer at non-resolving steps: (phi U psi) in chain(r+1), phi in chain(r). Since the step was non-resolving, chain(r+1) = lindenbaum(g_content(chain(r)) union f_carry(chain(r)) union until_carry(chain(r))). So (phi U psi) in chain(r+1) does NOT imply (phi U psi) in chain(r) directly.
- [ ] **CORRECT step transfer via h_content reverse + BX8**: From `(phi U psi) in chain(r+1)`, apply BX4': `alpha -> H(F(alpha))`, so `H(F(phi U psi)) in chain(r+1)`. h_content reverse (`fwd_chain_reverse_h`): `h_content(chain(r+1)) subset chain(r)`. So `F(phi U psi) in chain(r)`. By BX12: `(top U (phi U psi)) in chain(r)`. We need to extract `(phi U psi)` from `(top U (phi U psi))`. BX9 gives `top ∨ (phi U psi)`. As analyzed above, `top ∨ X` does not give X in BX. But we also have `phi in chain(r)`. Use BX2 left-mono: `G(top -> phi) -> ((top U (phi U psi)) -> (phi U (phi U psi)))`. We don't have `G(top -> phi)`. However, BX T-axiom gives `G(alpha) -> alpha`, not `alpha -> G(alpha)`.
- [ ] **Alternative: Direct construction for backward Until**: Instead of using `backward_until_from_step`, prove backward Until directly with a modified FMCS construction. Build a fresh chain specifically for each backward Until obligation: starting from the witness point s with psi, walk backward to t, at each step constructing an MCS that includes (phi U psi) (by including it in the Lindenbaum seed). Since phi is given on the guard, the seed `{(phi U psi)} ∪ {phi} ∪ h_content(M_{r+1})` is consistent (phi U psi and phi are both in any MCS containing (phi U psi) by BX9, and h_content gives backward propagation).
  - Consistency of `{(phi U psi), phi} ∪ h_content(M)` when `(phi U psi) in M`: Both `(phi U psi)` and `phi` are in M (by BX9, since psi not in the predecessor means phi must be). h_content(M) subset M by BX T-past. So the seed is a subset of M (when phi in M too, which is given by the guard). Consistent.
  - This gives a separate backward chain with (phi U psi) at every point. But this is a DIFFERENT chain from `int_chain`. The restricted backward Until needs to prove the property for the int_chain, not a separate chain.
- [ ] **FINAL APPROACH for backward Until step transfer**: Use until_carry in the non-resolving seed to get FORWARD persistence (chain(r) has (phi U psi) -> chain(r+1) has (phi U psi) when step is non-resolving). For BACKWARD persistence (the step transfer direction), use the h_content mechanism: from `(phi U psi) in chain(r+1)`, derive `F(phi U psi) in chain(r)` via h_content reverse (proved as `fwd_chain_reverse_h`). Then use BX12 to get `(top U (phi U psi)) in chain(r)`. Since we also have `phi in chain(r)` (given by guard), we need `(phi U psi) in chain(r)`. The key insight: we can add (top U X)-formulas to until_carry. Define extended_until_carry to include not just `(phi U psi)` formulas in M but also `(top U (phi U psi))` formulas derived from `F(phi U psi)` via BX12. Actually, `(top U (phi U psi))` IS an Until formula -- it is in until_carry(M) when it is in M. And we showed `(top U (phi U psi)) in chain(r)`. So in the non-resolving case, `(top U (phi U psi)) in chain(r+1)`. Combined with BX9: since `(phi U psi) in chain(r+1)`, either (phi U psi) directly OR work through the Until... This is getting circular.
- [ ] **PRAGMATIC APPROACH**: Since the step transfer seems genuinely hard for the general chain, take the direct approach:
  1. For backward Until: given witness (psi at s, phi on [t, s)), build the proof by strong induction on (s - t).
  2. Base s = t: BX8 gives (phi U psi) in mcs(t).
  3. Inductive s > t: Need (phi U psi) in mcs(t). We have phi in mcs(t) and the witness at s. By inductive hypothesis at t+1: (phi U psi) in mcs(t+1) (since the witness is still at s > t+1, or s = t+1 and psi in mcs(t+1)). Now we have (phi U psi) in mcs(t+1) and phi in mcs(t). Need (phi U psi) in mcs(t). This is the step transfer. Without it, the induction does not close.
  4. For backward Until, the step transfer IS the fundamental obligation. Accept this and prove it using until_carry.
  5. Add until_carry to the non-resolving seed. For backward step transfer at non-resolving steps: (phi U psi) in chain(r+1) was produced by Lindenbaum extension of `g_content(chain(r)) ∪ f_carry(chain(r)) ∪ until_carry(chain(r))`. The fact that (phi U psi) is in chain(r+1) means the Lindenbaum extension chose to include it, but it was NOT necessarily in the seed. So no backward guarantee. But FORWARD: until_carry(chain(r)) subset chain(r+1). So if (phi U psi) in chain(r), it persists to chain(r+1) IF the step is non-resolving. This is forward, not backward.
  6. **KEY REALIZATION**: The step transfer for backward_until_from_step needs `(phi U psi) in fam.mcs(r+1) ∧ phi in fam.mcs(r) → (phi U psi) in fam.mcs(r)`. This goes BACKWARD (from r+1 to r). The chain is built FORWARD. We cannot guarantee backward transfer from the chain construction. The only backward information is h_content reverse. And as analyzed, h_content gives `F(phi U psi) in chain(r)` but not `(phi U psi) in chain(r)`.
  7. **SOLUTION**: Build a COMPLETELY NEW FMCS for the restricted proof. Do not use `int_chain`. Instead, build a custom FMCS where backward Until is satisfied BY CONSTRUCTION. The construction: for each shifted family in bx_bfmcs, build the FMCS as follows. Given M0 at time 0, define `custom_chain(t)` using a construction that includes until_carry in BOTH directions.
  8. OR: Modify the chain construction to use `past_temporal_witness_seed_enriched` that includes until_carry. `past_temporal_witness_seed M ψ = {ψ} ∪ h_content(M)`. Enrich to `{ψ} ∪ h_content(M) ∪ until_carry(M)`. Then backward Until at resolving steps: if resolving P(chi), the seed is `{chi} ∪ h_content(M) ∪ until_carry(M)`. Wait, the resolving seed is `{chi} ∪ h_content(M)`, not enriched. Same problem.
- [ ] **DEFINITIVE APPROACH**: Modify BOTH resolving and non-resolving seeds in `fwd_succ` to include `until_carry`. The resolving seed becomes `{psi} ∪ g_content(M) ∪ until_carry(M)`. Is `{psi} ∪ g_content(M) ∪ until_carry(M)` consistent? `{psi} ∪ g_content(M)` is consistent (proven by `forward_temporal_witness_seed_consistent`). `until_carry(M) ⊆ M`. Can adding until_carry(M) to the seed break consistency? The v10 counterexample was about adding `untilCarry` to the RESOLVING seed: `{psi, neg alpha, alpha U neg(psi)}` inconsistent via BX9. But `until_carry(M)` only includes Until formulas ALREADY IN M. Since M is consistent and psi in M (because F(psi) in M and we are resolving), the seed `{psi} ∪ g_content(M) ∪ until_carry(M)` is a subset of M (since psi in M, g_content(M) ⊆ M by BX T, until_carry(M) ⊆ M by definition). Hence consistent. The v10 counterexample was about a DIFFERENT `untilCarry` definition that included Until formulas NOT necessarily in M.
- [ ] Verify: Is `{psi} ∪ g_content(M) ∪ until_carry(M) ⊆ M` when `F(psi) ∈ M`? psi may NOT be in M! F(psi) in M means exists future time with psi, but psi itself may not be in M. So `{psi} ∪ g_content(M) ∪ until_carry(M)` is NOT necessarily a subset of M. The subset argument does not work.
- [ ] **Back to the forward_temporal_witness_seed**: The existing consistency proof for `{psi} ∪ g_content(M)` works even when psi not in M (it uses a derivation argument). Can we extend it to `{psi} ∪ g_content(M) ∪ until_carry(M)`? Need: `{psi} ∪ g_content(M) ∪ until_carry(M)` is consistent when `F(psi) ∈ M`. Since `g_content(M) ∪ until_carry(M) ⊆ M` (both subsets of M), and adding psi: if the combined set is inconsistent, then there exist formulas L from g_content(M) ∪ until_carry(M) with `L ⊢ ¬psi`. But then `G(conjunction(L)) → ¬psi` is derivable, and `G(conjunction(L)) ∈ M` (since each member of L has G(member) in M... wait, until_carry members are Until formulas, not G-formulas). Actually, `until_carry(M) ⊆ M` and `g_content(M) ⊆ M` by BX T-axiom. So `g_content(M) ∪ until_carry(M) ⊆ M`. If `(g_content(M) ∪ until_carry(M)) ∪ {psi}` is inconsistent, then there exist finite L ⊆ g_content(M) ∪ until_carry(M) with `L ⊢ ¬psi`. Since `L ⊆ M`, `¬psi ∈ M`. But `F(psi) ∈ M` and `¬psi ∈ M` does NOT give a contradiction (F(psi) means psi at some FUTURE time, not at the current time). So the standard consistency argument from `forward_temporal_witness_seed_consistent` does NOT extend trivially.
- [ ] **CONCLUSION on step transfer**: The step transfer for backward Until in the int_chain is genuinely hard. Modify the approach: instead of trying to get step transfer from the chain construction, use a DIRECT proof of backward Until that does not go through `backward_until_from_step`.
- [ ] **DIRECT backward Until proof**: Given witness (psi at s >= t, phi on guard [t, s)), prove (phi U psi) in mcs(t). By BX8: if s = t, psi in mcs(t) -> (phi U psi) in mcs(t). If s > t, we need an argument that does not require step transfer. Use BX semantics: `(phi U psi)` at t iff exists s >= t with psi at s and phi on [t, s). This is EXACTLY the witness pattern. So we need: the FMCS satisfies the semantic condition for Until. But the FMCS is a SYNTACTIC object (MCS membership), not semantic truth. The bridge is the truth lemma, which is what we are trying to prove.
- [ ] The fundamental issue: backward Until coherence states that if the SEMANTIC condition holds (witness at s, guard on [t, s)), then the SYNTACTIC condition holds ((phi U psi) in mcs(t)). This is an Adequacy property. It CANNOT be proved from BX axioms at a single point. It REQUIRES the chain's structural properties (step transfer). This is exactly why `backward_until_from_step` is parameterized by step transfer.

**After extensive analysis, the following tasks are the correct approach:**

- [ ] Add `until_carry` and `since_carry` to BOTH resolving and non-resolving seeds in `fwd_succ`/`bwd_pred`. Prove consistency of the enriched resolving seed `{psi} ∪ g_content(M) ∪ until_carry(M)` using the g_content derivation technique (not subset-of-M).
- [ ] If enriched resolving seed consistency cannot be proved, use an alternative: modify the FMCS to use a FRESH chain construction where each forward step includes until_carry by design. The chain at position t is defined as: `custom_chain(0) = M0; custom_chain(t+1) = lindenbaum({schedule(t)} ∪ g_content(custom_chain(t)) ∪ until_carry(custom_chain(t)))` when F(schedule(t)) in chain(t), and `lindenbaum(g_content(chain(t)) ∪ f_carry(chain(t)) ∪ until_carry(chain(t)))` otherwise. This preserves Until formulas through ALL forward steps.
- [ ] For backward step transfer: once Until formulas persist forward, derive: `(phi U psi) in chain(r+1)` and `phi in chain(r)`. Since chain(r+1) was built from chain(r) with until_carry(chain(r)) in the seed, and if `(phi U psi) in chain(r)` then it would be in until_carry and hence in chain(r+1). The converse (chain(r+1) has (phi U psi) -> chain(r) has it) is NOT guaranteed. But combined with `phi in chain(r)`, and the fact that `F(phi U psi) in chain(r)` (via h_content reverse from chain(r+1)), and BX12 giving `(top U (phi U psi)) in chain(r)`, we can try to derive (phi U psi) in chain(r) using enriched BX reasoning with until_carry.
- [ ] Prove restricted forward Until coherence using the quasimodel defect-discharge
- [ ] Prove restricted forward Since coherence symmetrically
- [ ] Prove restricted backward Until coherence using `backward_until_from_step` with step transfer
- [ ] Prove restricted backward Since coherence symmetrically

**Timing**: 5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- Until/Since carry definitions, enriched seed consistency, modified chain construction (~100 lines), restricted coherence proofs (~200 lines)

**Verification**:
- `bx_bfmcs_restricted_fuc` has no sorry
- `bx_bfmcs_restricted_buc` has no sorry
- `lake build` passes

---

### Phase 4: Cleanup and Final Verification [NOT STARTED]

**Goal**: Clean up dead code, verify the full build, and confirm axiom purity.

**Tasks**:
- [ ] Mark unrestricted sorry-bearing theorems (`bx_fmcs_forward_F` at 497, `bx_fmcs_backward_P` at 503, `bx_bfmcs_buc`/`bx_bfmcs_fuc`/`bx_bfmcs_tc` at 569-591) with `-- DEAD CODE: not on active completeness path`
- [ ] Delete or comment out dead code if truly unused (check references with grep first)
- [ ] Run `lake build` and verify zero errors
- [ ] Run `grep -r "sorry" Theories/Bimodal/Metalogic/BXCanonical/` and verify no sorry on active path
- [ ] Add `#print axioms Bimodal.Metalogic.BXCanonical.bx_completeness` and verify output shows only `propext`, `Classical.choice`, `Quot.sound`
- [ ] Run full `lake build` for regression testing

**Timing**: 2 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- Dead code annotations/removal (~50 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- Add `#print axioms` verification

**Verification**:
- `lake build` succeeds with zero errors
- `grep -r "sorry" Theories/Bimodal/Metalogic/BXCanonical/` returns only dead-code sorry or no matches
- `#print axioms bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`

## Testing & Validation

- [ ] `lake build` completes with zero errors after each phase
- [ ] Phase 1: `F_to_until_in_deferralClosure` compiles without sorry; all downstream closure lemmas still compile
- [ ] Phase 2: `bx_bfmcs_restricted_tc` has no sorry (no longer delegates to sorry'd lemmas)
- [ ] Phase 3: `bx_bfmcs_restricted_fuc` and `bx_bfmcs_restricted_buc` have no sorry (GO/NO-GO: if step transfer is unprovable after 6 hours, document and evaluate fallback)
- [ ] Phase 4: `grep -r "sorry" Theories/Bimodal/Metalogic/BXCanonical/` returns no active-path matches
- [ ] `#print axioms bx_completeness` lists only `propext`, `Classical.choice`, `Quot.sound`

## Artifacts & Outputs

- `Theories/Bimodal/Syntax/SubformulaClosure.lean` -- Closure extension (~50 lines): `untilEnrichmentSet`, `sinceEnrichmentSet`, modified `deferralClosure`, membership lemmas
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- Major changes (~400-500 lines): Until/Since carry in seeds, restricted forward_F/backward_P via defect-discharge, restricted Until/Since coherence via step transfer, dead code cleanup
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- Add `#print axioms` verification
- `specs/093_complete_bxcanonical_embedding/summaries/11_bxcanonical-embedding-summary.md` -- Implementation summary (created after completion)

## Rollback/Contingency

**Phase 1 breakage (closure extension cascading failures)**:
- If modifying `deferralClosure` breaks downstream, create `enrichedDeferralClosure` as a separate definition and modify only `restricted_temporally_coherent` to use it. This isolates the change from existing infrastructure.
- Git revert of `SubformulaClosure.lean` is straightforward.

**Phase 2 failure (restricted forward_F via defect-discharge)**:
- If the defect-discharge chain construction fails to integrate with the existing FMCS structure, fall back to: build an entirely new FMCS from the quasimodel chain (replacing `int_chain` for the restricted proof). This is more code (~200 extra lines) but avoids needing to integrate with the scheduling chain.
- If restricted forward_F proves fundamentally impossible without modifying the chain, document the precise obstacle and evaluate whether a root-parameterized chain is needed.

**Phase 3 failure (step transfer for backward Until)**:
- If step transfer `(phi U psi) in chain(r+1) ∧ phi in chain(r) → (phi U psi) in chain(r)` is unprovable for the scheduling chain:
  - **Fallback A**: Build a separate backward chain for each Until obligation with Until formulas in the seed.
  - **Fallback B**: Modify the chain construction to use enriched resolving seeds. Prove consistency of `{psi} ∪ g_content(M) ∪ until_carry(M)` using a more sophisticated derivation argument.
  - **Fallback C**: Build a completely new FMCS construction where Until formulas are preserved by design at every step (both directions). This would be a significant refactoring (~300 extra lines).
- Document the exact failure point and residual obstacles for future plans.

**General rollback**:
- All Phase 1 changes are in `SubformulaClosure.lean`. All Phase 2-4 changes are in `CanonicalModel.lean`.
- Dead code deletion (Phase 4) can be deferred indefinitely without blocking the definition of done.
