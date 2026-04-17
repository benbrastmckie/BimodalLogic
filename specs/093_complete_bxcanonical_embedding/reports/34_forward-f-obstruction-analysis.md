# Forward_F Obstruction Analysis: Three Paths Forward

- **Task**: 93 - Complete BXCanonical embedding
- **Date**: 2026-04-17
- **Status**: Research report for user-directed deep study
- **Context**: After 33 research rounds + 3 implementation attempts, the multi-defect `forward_F` and `backward_P` sorries remain open. This report details the obstruction and three viable resolution paths.

## 1. The Obstruction

### What We Need

```lean
theorem defect_fwd_chain_forward_F ... :
    -- Given: F(ψ) ∈ chain(n), ψ ∈ defects (a finite list)
    -- Need: ∃ s > n, ψ ∈ chain(s)
```

For a forward chain indexed by ℕ, if `F(ψ)` holds at step `n`, then ψ must actually appear at some later step `s`. This is the "forward eventuality" property required for temporal completeness.

### What We Have (sorry-free)

| Lemma | Statement | File:Line |
|-------|-----------|-----------|
| `defect_fwd_chain_mcs` | Each chain element is MCS | ~2008 |
| `defect_fwd_chain_g_content_step` | g_content(chain(n)) ⊆ chain(n+1) | ~2047 |
| `defect_fwd_chain_F_obligation_persists` | F(ψ) ∈ chain(n) → F(ψ) ∈ chain(n+1) | ~2061 |
| `defect_fwd_chain_F_obligation_constant` | F(ψ) ∈ chain(n) → F(ψ) ∈ chain(m) for m ≥ n | ~2077 |
| `self_resolving_fwd_step` | Given F(ψ) ∈ M, builds M' with ψ ∈ M' AND F(ψ) ∈ M' AND g_content(M) ⊆ M' | ~1961 |
| `F_and_self_F_mcs` | F(ψ) ∈ M → F(ψ ∧ F(ψ)) ∈ M | ~1950 |
| `defect_fwd_step_choice_singleton` | Single-defect forward_F proved | ~2155 |

### Why It's Blocked

The chain uses `defect_fwd_step_choice` which wraps `resolving_enriched_fwd_exists` via `Classical.choice`. At each step:
- SOME defect `w ∈ defects` is resolved: `w ∈ chain(n+1)`
- ALL F-obligations are preserved: `F(χ) ∈ chain(n) → F(χ) ∈ chain(n+1)`

But `Classical.choice` is opaque — we cannot force `w = ψ`. The BX11 fold processes defects sequentially; at each fold step, "case 3" can F-wrap the current compound (`F(A) ∧ B → F(F(A) ∧ B)`), shifting the resolved witness away from ψ. There is no contradiction in ψ being perpetually deferred: `¬ψ ∈ chain(n)` and `F(ψ) ∈ chain(n)` are simultaneously consistent ("ψ is false now but eventually true" — the chain just never delivers).

### Approaches Exhaustively Rejected

| # | Approach | Why it fails |
|---|----------|-------------|
| 1 | Round-robin + `defect_fwd_step` | F-obligations killed for non-target defects (seed lacks f_carry) |
| 2 | Round-robin + `enriched_fwd_step` | Disjunctive preservation: ψ ∈ M' ∨ F(ψ) ∈ M' allows perpetual right disjunct |
| 3 | `target_resolving_fwd_exists_strong` | Requires target `bx11_earlier` than ALL others; fails in 3-cycles (non-transitive tournament) |
| 4 | Round-robin + `self_resolving_fwd_step` | Target resolved but other F-obligations killed; F(ψ) may not survive to ψ's targeting step |
| 5 | Enriched seed `{target} ∪ g_content ∪ f_carry` | Seed can be inconsistent: G(p→q), G(¬q) in g_content derive ¬p, contradicting target=p |
| 6 | Pigeonhole on unresolved count | Formulas "fall out" and re-enter; measure not monotone |
| 7 | Contradiction from "ψ never resolved" | No contradiction: consistent for ψ to be perpetually deferred |

---

## 2. Path A: Quasimodel Bridge (Recommended)

### Overview

Replace the BX11-fold-based chain with a chain extracted from a **quasimodel tableau**. This is the standard approach in temporal logic completeness proofs (Goldblatt, Reynolds, Gabbay-Hodkinson-Reynolds).

### How It Works

A quasimodel is a finite graph of "atoms" (maximal consistent type descriptions) with edges satisfying temporal coherence. The model is extracted by "unfolding" the quasimodel into an ω-chain (or ℤ-chain).

The key difference from the current approach: the quasimodel construction handles eventuality discharge (forward_F) at the **graph level** before unfolding, using a fairness/scheduling argument on the finite graph. The unfolded chain inherits forward_F by construction.

### What Exists in the Codebase

The project already has quasimodel infrastructure:
- `Theories/Bimodal/Metalogic/Quasimodel/` — quasimodel definitions
- `Theories/Bimodal/Metalogic/Bundle/` — FMCS bundle, temporal coherence, witness seeds
- `defect_count` in quasimodel — tracks Until/Since defect discharge (different from F-defects)
- `hintikka_step` — single step in quasimodel unfolding

### What Would Need to Be Built

1. **F-defect tracking in quasimodel** (~200 LOC): Extend `defect_count` to track F-formula defects alongside Until/Since defects. Define `f_defect_count(atom) = |{ψ : F(ψ) ∈ atom ∧ ψ ∉ atom}|`.

2. **F-defect discharge lemma** (~150 LOC): Prove that the quasimodel unfolding resolves F-defects. At each step in the unfolding, either (a) some F-defect is resolved, or (b) the current atom has no F-defects. Since the quasimodel is finite and the unfolding visits each atom infinitely often (by the fairness property), every F-defect is eventually resolved.

3. **Chain extraction** (~200 LOC): Extract an ω-chain from the quasimodel unfolding. Prove the chain satisfies forward_F by the F-defect discharge lemma.

4. **Bridge to BXCanonical** (~300 LOC): Connect the quasimodel-derived chain to the BXCanonical canonical model. Show that the quasimodel chain can serve as `dd_fmcs` (the family of MCS indexed by ℤ).

5. **Backward_P symmetric construction** (~150 LOC): Symmetric argument for P-defects.

### Estimated Effort

800–1200 lines of new Lean code. 15–25 hours.

### Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Quasimodel fairness argument doesn't formalize cleanly | 20% | H | The quasimodel already has `defect_count` for Until/Since; F-defect is simpler (no guard condition) |
| Bridge to BXCanonical is non-trivial | 30% | M | The bridge only needs to show the extracted chain satisfies the same properties that dd_fmcs needs |
| Quasimodel infrastructure is incomplete | 15% | H | Read `Quasimodel/` directory thoroughly first |

### Key Questions to Research

1. Does `hintikka_step` already handle F-defect discharge, or only Until/Since?
2. How does the quasimodel unfolding ensure fairness (all atoms visited infinitely often)?
3. Can the quasimodel chain be used directly as `dd_fmcs`, or is an intermediate translation needed?
4. What is the relationship between `Quasimodel/` and `BXCanonical/`? Are they independent proof paths, or does BXCanonical depend on Quasimodel?

---

## 3. Path B: Scheduling-Based fwd_succ Chain

### Overview

Replace the BX11-fold chain with a chain that uses `fwd_succ` (single-target Lindenbaum extension) at every step, cycling through defects in round-robin order. The key challenge: proving that F-obligations survive between a defect's consecutive targeting steps.

### How It Works

Define the chain as:
```
chain(0) = M₀
chain(n+1) = fwd_succ(chain(n), defects[n % |defects|])
```

At step `n`, the target is `defects[n % |defects|]`. `fwd_succ` with this target produces M' with:
- g_content(chain(n)) ⊆ M'
- When `F(target) ∈ chain(n)`: seed includes target, so target ∈ M' (the target IS resolved)
- f_carry mechanism: when `F(target) ∉ chain(n)`, all existing F-obligations are preserved via f_carry

### The Critical Question

When `F(target) ∈ chain(n)` (resolving mode), `fwd_succ` uses `temporal_witness_seed = {target} ∪ g_content(M)`. This does NOT include f_carry. So other F-obligations may be killed.

**Specifically**: does `fwd_succ M hM ψ` preserve `F(χ)` for `χ ≠ ψ` when `F(ψ) ∈ M`?

If YES: round-robin forward_F is trivially proved.
If NO: F-obligations die at resolving steps, and the approach fails (same as #1 in rejected list).

### What Would Need to Be Built

1. **Determine `fwd_succ` F-preservation** (~50 LOC research): Read `fwd_succ` definition carefully. Check whether the resolving-mode seed includes f_carry. If it does, this path is short. If not, check whether f_carry can be added without breaking consistency.

2. **If f_carry IS preserved in resolving mode**: Define the round-robin chain (~30 LOC) and prove forward_F (~50 LOC). Total: ~130 LOC.

3. **If f_carry is NOT preserved**: Attempt to modify `fwd_succ` to include f_carry in the resolving seed. Prove consistency of `{target} ∪ f_carry(M) ∪ g_content(M)` when `F(target) ∈ M`. This requires showing `{target} ∪ {F(χ) : F(χ) ∈ M} ∪ g_content(M)` is consistent. The consistency proof likely needs the same BX11 argument that is already blocked — see approach #5 in the rejected list. If so, this path collapses into Path A.

### Estimated Effort

If `fwd_succ` preserves f_carry: 2–4 hours, ~130 LOC.
If not: likely collapses to Path A or is blocked.

### Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| `fwd_succ` doesn't preserve f_carry in resolving mode | 70% | H (path dies) | Check the definition before investing further |
| Modified seed is inconsistent | 60% | H (path dies) | Counterexample from #5 suggests high risk |
| Round-robin doesn't produce a valid FMCS chain | 15% | M | The chain still has g_content propagation; FMCS structure should be preserved |

### Key Questions to Research

1. **CRITICAL**: What is the exact seed used by `fwd_succ` when `F(target) ∈ M`? Does it include f_carry?
2. If not, is `{target} ∪ f_carry(M) ∪ g_content(M)` provably consistent when `F(target) ∈ M`?
3. Does the counterexample from approach #5 apply here? (G(p→q), G(¬q) in g_content making {p, f_carry} inconsistent)
4. What is the exact signature and guarantees of `fwd_succ_resolves` (if it exists)?

---

## 4. Path C: Self-Resolving BX11 Fold

### Overview

Modify the BX11 fold to use `ψ ∧ F(ψ)` as the initial compound (instead of just `ψ`) when processing the defect list. This makes case 3 (F-wrapping) preserve `F(ψ)` even when ψ is not directly resolved. The goal: show that for the target formula, either ψ ∈ M' (resolved) or the fold produces enough structure to guarantee eventual resolution.

### How It Works

The existing BX11 fold (in `resolving_enriched_fwd_exists`) starts with compound `β₀ = target` and processes each other defect `χ`:
- **Case 1**: `bx11_earlier M target χ` — compound becomes `target ∧ χ`, both stay direct
- **Case 2**: `bx11_earlier M χ target` — compound becomes `χ ∧ F(target)` or `F(target) ∧ χ`, target gets F-wrapped
- **Case 3**: Neither — compound gets modified, target may be lost

With `β₀ = ψ ∧ F(ψ)`:
- If β₀ stays direct: `ψ ∧ F(ψ) ∈ M'` → `ψ ∈ M'` AND `F(ψ) ∈ M'` (resolved + preserved!)
- If β₀ gets F-wrapped: `F(ψ ∧ F(ψ)) ∈ M'` → `F(ψ) ∈ M'` (by F-monotonicity, since `ψ ∧ F(ψ) → F(ψ)` by right projection; so `F(ψ ∧ F(ψ)) → F(F(ψ)) → F(ψ)` by phi_imp_F_phi argument). F-obligation preserved but ψ not resolved.

The outcome: either ψ ∈ M' (done!) or F(ψ) ∈ M' (try again next step). This is the SAME disjunction as `enriched_fwd_step_preserves`. The self-resolving compound doesn't help for the multi-defect case.

### What Could Make This Work

The compound `ψ ∧ F(ψ)` is "stickier" than bare `ψ` — it takes MORE case-3 hits to fully F-wrap it. After one F-wrapping: `F(ψ ∧ F(ψ))`. After extraction: `F(ψ)`. At the next step, we restart with `ψ ∧ F(ψ)` again. The net effect: identical to enriched_fwd_step.

**Novel idea**: What if we use `ψ ∧ F(ψ) ∧ F(F(ψ)) ∧ F(F(F(ψ))) ∧ ...` as the compound? An infinitely nested F-tower? This is not well-defined for finite formulas. But for a FIXED nesting depth d: `β₀ = ψ ∧ F(ψ) ∧ F²(ψ) ∧ ... ∧ Fᵈ(ψ)`. Each case-3 hit strips one layer. After d hits, ψ is F-wrapped to `Fᵈ⁺¹(ψ)`. If d ≥ |defects| - 1 (at most |defects|-1 case-3 hits in one fold), then ψ survives the entire fold.

**Claim**: With compound `β₀ = ψ ∧ F(ψ) ∧ F²(ψ) ∧ ... ∧ Fᵈ(ψ)` where d = |defects| - 1, the fold over the remaining defects cannot F-wrap all layers. At most |defects| - 1 other formulas participate. Each can trigger at most one case-3 hit. After |defects| - 1 hits, one layer remains direct. Therefore ψ ∈ M'.

### What Would Need to Be Built

1. **F-tower lemma** (~50 LOC): `F(ψ) ∈ M → F(ψ ∧ F(ψ) ∧ ... ∧ Fᵈ(ψ)) ∈ M` by repeated application of `F_and_self_F` and F-monotonicity.

2. **Modified BX11 fold** (~200 LOC): A variant of `resolving_enriched_fwd_exists` that starts with the F-tower compound. Prove that with tower depth ≥ |others|, the fold cannot F-wrap all layers.

3. **Layer stripping analysis** (~300 LOC): At each fold step where case 3 fires, one layer is stripped. Prove: (a) each case-3 hit removes exactly one layer, (b) the remaining layers still guarantee ψ if any direct layer survives, (c) with d ≥ |others|, at least one layer survives.

4. **Chain integration** (~100 LOC): Replace `defect_fwd_step_choice` with the F-tower variant. Prove forward_F.

5. **Backward_P symmetric** (~200 LOC): P-tower with `P(ψ) ∧ P²(ψ) ∧ ...`.

### Estimated Effort

600–900 lines. 10–18 hours.

### Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Case-3 hit strips MORE than one layer | 40% | H | Read the BX11 fold carefully; the compound transformation may not be a simple "strip one layer" |
| F-tower consistency proof fails for large d | 20% | H | F-tower is just iterated phi_imp_F_phi + F_mono; should be straightforward |
| BX11 fold has non-local effects on the compound | 50% | H | The fold modifies the ENTIRE compound, not just one layer; careful analysis needed |
| The "at most |others| case-3 hits" claim is wrong | 30% | H | Multiple others could trigger case-3 in sequence, with compound effects |

### Key Questions to Research

1. **CRITICAL**: When case 3 fires on compound `A ∧ B`, what exactly happens? Is the result `F(A) ∧ B`, `A ∧ F(B)`, or `F(A ∧ B)`? The specific transformation determines whether layer stripping works.
2. Does `bx11_earlier_total` guarantee that for EVERY pair, one beats the other? (Yes, confirmed.) Does this mean exactly |others| case-3 hits in the worst case?
3. Is the F-tower formula `ψ ∧ F(ψ) ∧ F²(ψ) ∧ ... ∧ Fᵈ(ψ)` a valid formula in the syntax? (Yes, finite conjunction of finite formulas.)
4. Can the BX11 fold output be analyzed structurally to track which "layers" survive?

---

## 5. Comparison Matrix

| Criterion | Path A (Quasimodel) | Path B (fwd_succ) | Path C (F-tower fold) |
|-----------|--------------------|--------------------|----------------------|
| **Estimated LOC** | 800–1200 | 130 (if fwd_succ works) | 600–900 |
| **Estimated hours** | 15–25 | 2–4 (if works) | 10–18 |
| **Success probability** | 70–80% | 30% (high risk of collapse) | 40–50% |
| **Novelty risk** | Low (standard technique) | Low (if works) | High (non-standard) |
| **Infrastructure reuse** | High (Quasimodel/ exists) | Medium (fwd_succ exists) | Low (new fold variant) |
| **Backward_P symmetric** | Free (same technique) | Free (same technique) | Medium (P-tower needed) |
| **Side benefits** | Connects quasimodel to BXCanonical path | None | Better understanding of BX11 fold |

## 6. Recommended Research Order

1. **Path B first** (1–2 hours): Check `fwd_succ` definition. If it preserves f_carry in resolving mode, this is the fastest path. If not, move on.

2. **Path C second** (4–6 hours): Analyze the BX11 fold transformation in detail. Determine whether the F-tower approach is mathematically sound. If the layer-stripping analysis works, this is the most elegant solution.

3. **Path A as fallback** (15–25 hours): If B and C are blocked, the quasimodel bridge is the standard approach with highest success probability. Read `Quasimodel/` and `Bundle/` directories thoroughly before starting.

## 7. Current State Summary

### Files

- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` — 2292 lines, 8 sorries (6 original at lines 1413/1457/1464/1517/1522/1527, 2 new at lines 2196/2289)
- Self-resolving infrastructure: lines 1938–1996 (sorry-free)
- Forward chain: lines 1998–2196 (forward_F sorry at 2196)
- Backward chain: lines 2198–2289 (backward_P sorry at 2289)

### Build

`lake build` passes (950 jobs). All existing sorry-free code remains sorry-free.

### Single-Defect Case

When `defects = [ψ]`, forward_F IS proved (`defect_fwd_step_choice_singleton`, line ~2155). The obstruction is ONLY for |defects| ≥ 2.
