# Teammate B Findings: Alternative Approaches (B, C, D)

**Task**: 109 - Close chain construction sorries
**Focus**: Alternative approaches B (round-robin), C (BX11 transitivity), D (quasimodel run-composition)
**Date**: 2026-04-20

---

## Key Findings

- **Approach B (round-robin targeting)** is definitively dead: the infrastructure `target_stays_direct_in_fold` requires `phi` to beat ALL others via `bx11_earlier`, but there is no guarantee this ever holds for a fixed phi when other defects are co-persistent.
- **Approach C (BX11 transitivity)** is technically open but likely intractable: `bx11_earlier` is NOT a total preorder (it is not transitive from BX11 alone), and proving transitivity would require a non-trivial new axiom or structural argument not present in BX.
- **Approach D (quasimodel run-composition)** is the most structurally sound path: `hintikka_chain_exists` is already proved sorry-free (given an oracle), and the `HintikkaStepOracle` is the only remaining gap — specifically the `defect_mono` hypothesis for the oracle discharge.
- The "enriched seed" fix for Path D (adding `neg(phi U psi)` for non-defect Until formulas) is credible but requires closing two `sorry`s in `Realization.lean` related to `BX1` reflexivity under irreflexive semantics — a separate obstacle that Path D **does not bypass**, it merely shifts the burden.
- The quasimodel infrastructure in `BXCanonical/Quasimodel/` has substantial sorry-free machinery: `hintikka_chain_exists`, `chain_step_seed_consistent`, `HintikkaRawChain`, `QuasimodelChain` — all sorry-free. The gap is the oracle instantiation.

---

## Approach B Analysis: Round-Robin + target_stays_direct_in_fold

### What the Infrastructure Provides

`target_stays_direct_in_fold` (RootScopedChain.lean:948) guarantees that if:
1. `F(target) ∈ M`
2. `F(chi) ∈ M` for all `chi ∈ others`
3. `bx11_earlier M target chi` for ALL `chi ∈ others`

then there exists `M'` with `target ∈ M'` (not just `target ∈ M' ∨ F(target) ∈ M'`).

`bx11_earlier_total` (RootScopedChain.lean:851) guarantees totality: for any two F-defects phi, chi, either phi is bx11_earlier than chi or vice versa.

### Why Round-Robin Fails

The round-robin idea is: at phi's designated step, if phi beats all others, apply `target_stays_direct_in_fold`. If phi does not beat all others, accept F(phi) preservation and wait.

**Obstacle 1**: There is no guarantee that "phi beats all others" ever holds simultaneously. `bx11_earlier_total` gives pairwise comparisons, but the BX11 ordering depends on the MCS content, and at each step the MCS changes. At step k+1 when we have a different MCS M', the pairwise comparisons reset. Nothing guarantees that M' has phi beating all others.

**Obstacle 2**: Even if we accept the round-robin deferral, we need phi's step to eventually fire with phi beating all others. This requires a finite-descent argument on the number of formulas that beat phi — exactly the same problem as the original blocker. The round-robin structure provides no additional termination guarantee.

**Obstacle 3**: The comment at RootScopedChain.lean:448-459 confirms: "The round-robin chain approach has been archived to `Boneyard/QuasimodelOracle/RoundRobinChain.lean`. It is confirmed dead after 40 rounds of research: the depth-0 base case of `forward_F` is blocked by the BX11 perpetual deferral obstruction."

**Verdict**: Approach B is confirmed dead. The archived infrastructure validates this conclusion.

---

## Approach C Analysis: BX11 Transitivity

### The Claim

If `bx11_earlier` is transitive, then it's a total preorder on F-defects (total by `bx11_earlier_total`, transitive by hypothesis). A total preorder on a finite set has a minimum element. If phi is the minimum, then `target_stays_direct_in_fold` can always be applied with phi as target.

### Is bx11_earlier Transitive?

**Definition** (RootScopedChain.lean:845):
```
bx11_earlier M phi chi :=
  F(phi ∧ chi) ∈ M   [case 1: phi at least as early as chi]
  ∨ F(phi ∧ F(chi)) ∈ M  [case 2: phi strictly earlier than chi]
```

**Question**: Does `bx11_earlier M phi chi ∧ bx11_earlier M chi rho → bx11_earlier M phi rho`?

Consider case 2 of both:
- `F(phi ∧ F(chi)) ∈ M` (phi strictly before chi)
- `F(chi ∧ F(rho)) ∈ M` (chi strictly before rho)

We want to show `F(phi ∧ F(rho)) ∈ M` or `F(phi ∧ rho) ∈ M`.

By BX11 (temp_linearity), `F(phi ∧ F(chi)) ∈ M` and `F(phi ∧ F(rho)) ∈ M` stand in a linear order — but we're not given `F(phi ∧ F(rho)) ∈ M`, that's what we're trying to derive.

The issue: From `F(phi ∧ F(chi)) ∈ M`, we can extract `F(phi) ∈ M` and `F(F(chi)) ∈ M`. From `FF(chi) → F(chi)` (BX3/temp_4), we get `F(chi) ∈ M`. Similarly `F(chi ∧ F(rho)) ∈ M` gives `F(rho) ∈ M`.

Now we need to show phi's witness is ≤ rho's witness. BX11 gives us: `F(phi) ∧ F(F(rho))` implies `F(phi ∧ F(rho)) ∨ F(phi ∧ F(F(rho))) ∨ F(F(phi) ∧ F(rho))`.

The problem: there is no BX axiom that chains the intermediary chi to eliminate it and conclude phi < rho. We need to know that phi's time-witness is before rho's time-witness, but chi's witness mediates between them — and BX11 only gives pairwise comparisons at the level of F-formulas in the current MCS.

**Transitivity counterexample sketch**:
Consider M where `F(phi ∧ F(chi)) ∈ M` (phi at t1, chi at t2, t1 < t2) and `F(chi ∧ F(rho)) ∈ M` (chi at t3, rho at t4, t3 < t4), but **t1 > t3** (the phi-witness is after the first chi-witness). Then phi is "before" chi in one sense, chi is "before" rho in another, but phi may not be before rho. The frame-level semantics allow this if there are multiple chi-witnesses.

**Verdict**: `bx11_earlier` is NOT provably transitive from BX axioms. Transitivity would require knowing that the specific witnesses for phi < chi and chi < rho can be chained, which the MCS encoding does not capture (it only records existence, not identity of witnesses). Approach C is likely blocked without a deeper structural argument.

**Practical obstruction**: Even if we could prove transitivity, the proof would need to work at the MCS level with BX11 as the only temporal-linearity axiom. A Lean proof of `bx11_earlier_transitive` would likely require a long BX11-chasing argument not obviously provable.

---

## Approach D Analysis: Quasimodel Run-Composition

### The Architecture

The quasimodel approach does NOT require a single infinite chain. Instead:
1. Use `hintikka_chain_exists` to build a finite chain discharging a specific Until-defect `(phi, psi)`
2. The chain ends at a point where `psi ∈ last.formulas`
3. Compose multiple such chains to handle all defects

The **key theorem** `hintikka_chain_exists` (Construction.lean:592) is already proved sorry-free:

```lean
theorem hintikka_chain_exists
    {Sigma : Finset Formula} {phi psi : Formula}
    (oracle : HintikkaStepOracle (Sigma := Sigma) phi psi)
    (h0 : HintikkaPoint Sigma) (w0 : BXPoint)
    (h0_sub : ∀ f ∈ h0.formulas, f ∈ w0.formulas)
    (h_target : Formula.untl phi psi ∈ h0.formulas) :
    ∃ c : HintikkaRawChain Sigma,
      c.head = h0 ∧ psi ∈ c.last.formulas ∧ ChainWitnessed c
```

This is sorry-free — the termination argument on `defect_count` is complete.

### The Oracle Gap

`HintikkaStepOracle` (Construction.lean:475) requires:

```lean
def HintikkaStepOracle {Sigma : Finset Formula} (phi psi : Formula) : Prop :=
  ∀ h : HintikkaPoint Sigma,
    Formula.untl phi psi ∈ h.formulas → psi ∉ h.formulas →
    ∃ wh' : WitnessedHintikka Sigma, hintikka_step h wh'.point ∧
      (psi ∈ wh'.point.formulas ∨
        (Formula.untl phi psi ∈ wh'.point.formulas ∧
          defect_count wh'.point < defect_count h))
```

The oracle must produce a next point either:
- Reaching the witness `psi` directly, OR
- Preserving the target defect with strictly smaller `defect_count`

**The `defect_count` decrease requirement is the oracle gap**: for the decrease branch, we need `untilDefectSet h2 ⊆ untilDefectSet h1` (from `hintikka_step_target_decrease` at Construction.lean:273). This is the `defect_mono` hypothesis.

### What defect_mono Requires

`defect_mono : untilDefectSet h2 ⊆ untilDefectSet h1` means: every Until-defect present in the successor point was already a defect in the predecessor. Equivalently: no NEW Until-defects appear at the step.

A new Until-defect `phi U psi` at `h2` means: `phi U psi ∈ h2.formulas` AND `psi ∉ h2.formulas`, but `phi U psi ∉ h1.formulas` or `psi ∈ h1.formulas`. Since `h2` is obtained by Lindenbaum extension from a seed, new Until-formulas can enter `h2` if the Lindenbaum extension chooses to include them.

### The Enriched Seed Fix

Prior research (team report) suggested: add `neg(phi U psi)` for all non-defect Until formulas in Sigma to the oracle's Lindenbaum seed. This prevents Lindenbaum from introducing `phi U psi` as a new defect when `phi U psi ∉ h1.formulas`.

**Analysis of this fix**:

For `phi U psi` that is a NON-defect at h1 (meaning either `phi U psi ∉ h1.formulas` or `psi ∈ h1.formulas`):
- Case A: `phi U psi ∉ h1.formulas`. Adding `neg(phi U psi)` to the seed forces `phi U psi ∉ h2.formulas`, so this formula cannot become a new defect.
- Case B: `psi ∈ h1.formulas`. If `psi ∈ h2.formulas` then not a defect. If `psi ∉ h2.formulas`, then `phi U psi` being in `h2` would create a defect. But is `phi U psi ∈ h2.formulas` possible? If we add `neg(phi U psi)` to seed, we force `phi U psi ∉ h2.formulas`.

**Consistency challenge**: Can `neg(phi U psi)` be consistently added to the seed? We need:
- `{neg(phi U psi)} ∪ [other seed elements]` is consistent.
- Since `phi U psi ∉ h1.formulas` (case A), by MCS: `neg(phi U psi) ∈ h1.formulas` (or the MCS closure has it). So adding it is consistent as it's already in the MCS. ✓
- For case B: `psi ∈ h1.formulas`. We want to add `neg(phi U psi)`. Is this consistent with the seed that includes `psi`? Yes — `psi` and `neg(phi U psi)` can coexist (psi is now but until says strictly future psi, or reflexive depending on axioms).

**BUT** there is a critical obstruction at `Realization.lean:195-197`:

```lean
· -- alpha ∈ g_content(w): G(alpha) ∈ w → alpha ∈ w (BX1 removed under irreflexive semantics)
  -- Sorry'd (non-critical Quasimodel path)
  sorry
```

The sorries in `Realization.lean` at lines 67, 73, 197, 249 are for `F_of_mem`, `P_of_mem`, and `enriched_seed_consistent_until/since`. These are needed for the oracle instantiation phase (Realization lifting). The enriched seed fix must produce consistent seeds, but the seed consistency proofs require BX1 (`G(phi) → phi`) which is absent under irreflexive semantics.

### What Approach D Actually Needs

Path D (quasimodel run-composition) for `fwd_chain_forward_F` would need:

1. **Oracle instantiation**: Discharge `HintikkaStepOracle phi psi` for the specific `phi, psi` coming from F-defects. This requires:
   - Building the next Hintikka point via Lindenbaum extension on a controlled seed
   - The enriched seed fix (add `neg` for non-defect Until formulas)
   - Proving the seed is consistent: blocked by `sorry` in `enriched_seed_consistent_until` (Realization.lean:197)

2. **Defect monotonicity from the enriched seed**: Even with the enriched seed fix, we must show `defect_count wh'.point < defect_count h` — this requires showing the target defect `phi U psi` has `psi ∈ wh'.point.formulas` (reached) OR the defect set strictly shrank. The strict-shrinkage needs `defect_mono`.

3. **Run-composition**: After getting the finite chain from `hintikka_chain_exists`, use it to step the infinite chain. This layer does not exist yet.

4. **Connecting to `fwd_chain_forward_F`**: The chain constructed in the quasimodel lives in `BXCanonical/Quasimodel/` at the `BXPoint` level, not at the `Set Formula` level of `fwd_chain_of_sigma`. A translation layer is needed.

### Sorries in the Quasimodel (The Oracle Discharge Path)

The sorries blocking oracle discharge:
- `F_of_mem` (Realization.lean:67): `psi ∈ w → F(psi) ∈ w`. Blocked: needs BX1 (G(phi) → phi), removed under irreflexive semantics.
- `P_of_mem` (Realization.lean:73): Dual of above. Same block.
- `enriched_seed_consistent_until` (Realization.lean:197): `G(alpha) ∈ w → alpha ∈ w`. Same block.
- `enriched_seed_consistent_since` (Realization.lean:249): Dual. Same block.
- `refl_intro_until_mcs` (Construction.lean:161): `psi ∈ w → phi U psi ∈ w`. Under irreflexive semantics, BX9 says `phi U psi → phi ∨ psi`, NOT `psi → phi U psi`. This sorry is correct: the converse direction is absent.

The BX1 (`G(phi) → phi`) removal is a genuine obstacle. Under irreflexive semantics, an MCS can contain G(phi) without phi — because the world doesn't see itself. This creates a fundamental gap in the Realization lifting proof structure.

### Is the Enriched Seed Fix Sufficient for `defect_mono`?

The enriched seed fix (add `neg(phi U psi)` for non-defect Until formulas) would prevent NEW Until-defects from appearing in `h2`. This would give `defect_mono`. But the fix requires consistent seed, blocked by the BX1 sorry.

**Alternative**: Instead of adding `neg(phi U psi)`, observe that `hintikka_step` (Construction.lean:44) includes Until-defect propagation:

```lean
-- Until defect propagation: if phi U psi ∈ h1 and psi ∉ h1, then
--   phi ∈ h1 and phi U psi ∈ h2
```

This propagates existing defects forward, but does NOT say h2 cannot have new defects. The enriched seed fix would need to block new defects from entering, requiring a seed control mechanism.

### Deeper Structural Analysis for Approach D

The connection between the quasimodel path (BXPoint level) and `fwd_chain_forward_F` (Set Formula / Nat chain level) is non-trivial. The `fwd_chain_forward_F` theorem says: given `F(phi) ∈ chain(n)`, find `m > n` with `phi ∈ chain(m)`. The quasimodel path provides: given `phi U psi ∈ h0.formulas`, find a finite Hintikka chain ending with `psi ∈ last.formulas`.

The correspondence between F-defects in `fwd_chain_of_sigma` and Until-defects in HintikkaPoints needs a bridge lemma — specifically: `F(phi) ∈ M` corresponds to `(top U phi) ∈ h` via BX12 (`F(phi) → (top U phi)`). This bridge exists via `F_until_equiv` (Axioms.lean:252).

However, constructing the HintikkaPoint sequence from the fwd_chain and then realizing it back at the Set Formula level would require:
- Projecting each `fwd_chain_of_sigma` MCS to a HintikkaPoint via `sigma_signature`
- Showing consecutive MCS steps satisfy `hintikka_step`
- Extracting a sub-chain where `phi ∈ last.formulas`

The `hintikka_step` condition for `sigma_signature` projections would require verifying the Until-defect propagation property, which is essentially what we're trying to prove.

---

## Comparative Assessment

| Criterion | Approach A (G(neg w) seed) | Approach B (round-robin) | Approach C (transitivity) | Approach D (quasimodel) |
|-----------|---------------------------|--------------------------|---------------------------|-------------------------|
| Mathematical soundness | High (finite descent on S) | Low (confirmed dead) | Unknown (transitivity unproved) | High (hintikka_chain_exists done) |
| Existing infrastructure | High (90% done in RootScopedChain) | None (archived as dead) | None | Medium (oracle gap remains) |
| Effort required | Low-Medium | N/A | High (new theorem needed) | High (oracle + translation) |
| Risk of failure | Low (seed consistency is main risk) | Certain failure | High | Medium |
| Sorries to close | 1 main (seed consistency) | N/A | 2+ (transitivity proof) | 4+ (BX1 sorries + oracle + translation) |
| Avoids step transfer? | No (still needs #4) | N/A | No | Yes (for Until coherence) |
| Avoids BX11 non-determinism? | Yes (S monotone descent) | No | No | Yes (different construction) |

---

## Recommended Approach

**Approach A** remains the best path for closing `fwd_chain_forward_F`, and Path D (quasimodel) is a viable but higher-effort alternative for the Until/Since coherence sorries (#2 and #5).

**Strategy refinement**:

1. For sorry #1 (`fwd_chain_forward_F`): Pursue **Approach A** (G(neg w) enriched seed). The mathematically correct proof is:
   - Add `G(neg w)` to the seed when resolving defect w
   - This forces `F(w) ∉ chain(k+1)` — w permanently exits the F-obligation set
   - The F-obligation set S strictly decreases at each step
   - By finiteness of sigma_list, S eventually reaches empty or {phi}
   - The sole remaining sorry in seed consistency is tractable under irreflexive semantics

2. For sorry #4 (`dd_bfmcs_restricted_buc`): Consider adapting the **quasimodel path** specifically for backward Until/Since coherence, which is the hardest sorry and where run-composition most clearly avoids the step-transfer issue.

3. **Approach B**: Definitively archived. Do not revisit.

4. **Approach C**: Not recommended unless Approach A fails. The transitivity proof would be a major new result requiring deep BX axiom analysis.

---

## Confidence Level

- **Approach B dead**: High confidence (confirmed by codebase comment + analysis)
- **Approach C intractable**: Medium-high confidence (transitivity not provable from BX11 alone, but not formally disproved)
- **Approach D viable but costly**: High confidence (infrastructure solid, gap is oracle discharge which has 4+ additional sorries tied to BX1 removal)
- **Approach A is best**: High confidence

---

## Open Questions

1. **BX1 removal impact on quasimodel**: Can the `F_of_mem` and `enriched_seed_consistent_until` sorries be closed without BX1 under irreflexive semantics? If not, Path D cannot instantiate the oracle, making the entire quasimodel approach circular for this codebase.

2. **Transitivity counterexample**: Can a concrete BX model (MCS M) be constructed where `bx11_earlier M phi chi` and `bx11_earlier M chi rho` but NOT `bx11_earlier M phi rho`? This would definitively kill Approach C.

3. **Oracle via BX12**: Since `F(phi) → (top U phi)` (BX12), can the quasimodel oracle be instantiated directly from the `defect_step_early` infrastructure in RootScopedChain.lean, avoiding the Realization.lean sorries?

4. **Seed consistency for G(neg w)**: For Approach A, is the enriched seed `{beta', G(neg w)} ∪ g_content(M)` consistent? The key question is whether `w ∧ G(neg w)` is consistent — under irreflexive semantics it is (w now, neg w at all strictly future times), and this needs formal verification.
