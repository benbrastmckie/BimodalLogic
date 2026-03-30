# Research Report: Task #69 — f_preserving_seed_consistent is FALSE

**Task**: 69 - close_z_chain_forward_f
**Date**: 2026-03-30
**Mode**: Team Research (2 teammates)
**Session**: sess_1774909076_ee27d4
**Focus**: Rigorous mathematical analysis of f_preserving_seed_consistent

---

## Summary

**CRITICAL FINDING**: `f_preserving_seed_consistent` (line 1372) is **mathematically false**. A concrete counterexample proves the theorem cannot hold as stated. The F-preserving seed approach — including ALL of `F_unresolved_theory M` in the seed — is too aggressive. Some F-formulas are genuinely inconsistent with `{phi} ∪ temporal_box_seed M`.

**However**, bundle-level temporal coherence (`boxClassFamilies_bundle_forward_F`, line 3588) is **already proven and sorry-free**. The correct path forward is to wire completeness through `BFMCS_Bundle` instead of the chain-level `Z_chain_forward_F`.

---

## The Counterexample

### Setup

Let the logic have atoms `p` and `q`. Let M be an MCS where:
- `F(p) ∈ M` — "p eventually"
- `F(q) ∈ M` — "q eventually"
- `p ∉ M` — p false now
- `q ∉ M` — q false now
- `G(p → G(¬q)) ∈ M` — "always: if p then always ¬q"

### M is a Valid MCS

This is satisfiable by the model:
- Time 0 (= M): p false, q false
- Time 1: q true (satisfies F(q))
- Time 2: p true (satisfies F(p))
- Time 3+: p false, q false

G(p → G(¬q)) holds at time 0: at every future time t, if p(t) then ¬q holds at all times ≥ t. This is satisfied because p only holds at time 2, and q is false at all times ≥ 2.

### The Seed is Inconsistent

`f_preserving_seed M p = {p} ∪ temporal_box_seed M ∪ F_unresolved_theory M`

The seed contains:
1. **p** ∈ {phi} (the witness formula)
2. **G(p → G(¬q))** ∈ G_theory M ⊆ temporal_box_seed M (since G(p → G(¬q)) ∈ M)
3. **F(q)** ∈ F_unresolved_theory M (since F(q) ∈ M and q ∉ M)

### Derivation of ⊥

```
[p, G(p → G(¬q)), F(q)] ⊢ ⊥
```

1. `G(p → G(¬q)) → (p → G(¬q))` — T-axiom (temp_t_future)
2. From `G(p → G(¬q))`: `p → G(¬q)` — modus ponens
3. From `p` and `p → G(¬q)`: `G(¬q)` — modus ponens
4. `G(¬q) → ¬q` — T-axiom (temp_t_future)
5. From `G(¬q)`: `¬q` — modus ponens
6. Note: `¬q = neg(q)` and `G(¬q) = G(neg q) = neg(F(q))`
7. From step 3: `neg(F(q))`. From seed: `F(q)`. Together: `⊥`.

All three premises are in the seed. Therefore the seed is **inconsistent**. ∎

### Why This Invalidates the Theorem

The theorem `f_preserving_seed_consistent` claims that `f_preserving_seed M phi` is consistent whenever `F(phi) ∈ M` (M is MCS). The counterexample shows an MCS M and formula phi = p where the seed is inconsistent. Therefore the theorem is false.

### Semantic Explanation

The issue is that the F-preserving seed tries to force ALL unresolved F-formulas into the successor world simultaneously. But some F-formulas may require resolution BEFORE phi, not after. In the counterexample:
- q must hold before p (since after p, G(¬q) makes q impossible)
- At a world where p holds (the witness), F(q) cannot be satisfied at that world or any future world
- Therefore `{p, F(q)}` is inconsistent when `G(p → G(¬q))` is in the temporal box seed

---

## Teammate Findings

### Teammate A — G-Lift Mechanism Analysis

**Key findings** (HIGH confidence):
1. `G_lift_from_context` requires ALL context elements to be G-liftable — no partial lift exists
2. `temporal_theory_witness_consistent` works because extracting phi leaves a homogeneous G-liftable context
3. F-formulas fundamentally break G-lifting: F(psi) ∈ M does NOT imply G(F(psi)) ∈ M
4. The comment at line 2024 already admits: "under the given hypotheses, f_preserving_seed is inconsistent"

**Proposed approaches**: Strong induction (70%), weaker seed (65%), different formulation (80%)

### Teammate B — Alternative Proof Strategies

**Key findings** (MEDIUM-HIGH confidence):
1. The `neg(phi)` vs `G(neg(phi))` problem is mathematically fundamental, not a proof artifact
2. All extraction-based approaches hit the same wall
3. The absorption argument (Case phi ∈ M: trivial; Case phi ∉ M: hard) is correct but incomplete
4. F-formulas cannot be shown "semantically harmless" in general (confirmed by counterexample)

**Recommended**: Hybrid semantic-syntactic approach or bundle-level coherence

### Points of Agreement
1. G-lift requires homogeneous G-liftable context ✓
2. `neg(phi)` vs `G(neg(phi))` is a real mathematical barrier ✓
3. The theorem may not be provable as stated ✓ (now confirmed FALSE)
4. Bundle-level coherence is the correct alternative ✓

---

## The Correct Path: Bundle-Level Temporal Coherence

### Already Proven (Sorry-Free)

| Theorem | Line | Status |
|---------|------|--------|
| `temporal_theory_witness_exists` | 1155 | ✅ Sorry-free |
| `boxClassFamilies_bundle_forward_F` | 3588 | ✅ Sorry-free |
| `boxClassFamilies_bundle_backward_P` | 3633 | ✅ Sorry-free |
| `boxClassFamilies_bundle_temporally_coherent` | 3675 | ✅ Sorry-free |
| `construct_bfmcs_bundle` | ~3799 | ✅ Sorry-free |

### Why Bundle-Level Works

Bundle-level coherence sidesteps the F-persistence problem entirely:
1. Given `F(phi) ∈ fam.mcs(t)`, use `temporal_theory_witness_exists` to get witness W with `phi ∈ W`
2. W is a NEW MCS with `box_class_agree(fam.mcs(t), W)`
3. Build a new family from W (via `SuccChainFMCS`)
4. This new family is in `boxClassFamilies M0` (same box class)
5. `phi ∈ new_family.mcs(t+1)`

The witness is in a DIFFERENT family, not the same chain. This avoids the F-persistence problem because we never need F-formulas to survive Lindenbaum extensions.

### What's Blocked (Dead Ends)

| Theorem | Line | Status | Reason |
|---------|------|--------|--------|
| `f_preserving_seed_consistent` | 1372 | ❌ FALSE | Counterexample above |
| `temporal_theory_witness_F_preserving` | 2114 | ❌ Depends on false theorem | |
| `omega_step_forward_F_preserving` | 4751 | ❌ Depends on false theorem | |
| `omega_F_preserving_forward_F_resolution` | 4928 | ❌ Built on false foundation | |
| `Z_chain_forward_F` | 3400 | ❌ Sorry (line 3422) | |
| `omega_true_dovetailed_forward_F_resolution` | 5150 | ❌ Sorry (line 5186) | Same F-persistence issue |

---

## Recommended Strategy

### Phase 1: Delete Dead Code
Remove or mark as deprecated:
- `f_preserving_seed_consistent` and its sorry-laden proof
- `temporal_theory_witness_F_preserving`
- `omega_step_forward_F_preserving`
- `omega_chain_F_preserving_forward_with_inv` and related
- `F_persistence_through_chain`
- `omega_F_preserving_forward_F_resolution`

### Phase 2: Wire Completeness Through BFMCS_Bundle
The completeness proof needs to use `BFMCS_Bundle` (bundle-level coherence) instead of `BFMCS` (family-level coherence). This means:
1. Check what `construct_bfmcs` provides vs what `construct_bfmcs_bundle` provides
2. Adapt the completeness proof in `Completeness.lean` to use bundle-level coherence
3. Verify that truth lemma and satisfaction work with bundle-level witnesses

### Phase 3: Clean Up Z_chain
Either:
- Remove Z_chain-related sorries and mark them as superseded by bundle approach
- Or keep Z_chain for non-temporal-coherence purposes (G-theory propagation, box class)

---

## Dependency Analysis

The sorry chain from `f_preserving_seed_consistent`:
```
f_preserving_seed_consistent (FALSE)
  → temporal_theory_witness_F_preserving (FALSE)
    → omega_step_forward_F_preserving (FALSE)
      → omega_chain_F_preserving_forward (FALSE)
        → F_persistence_through_chain (vacuously true, built on false chain)
        → omega_F_preserving_forward_F_resolution (vacuously true)
```

The clean path:
```
temporal_theory_witness_exists (PROVEN)
  → boxClassFamilies_bundle_forward_F (PROVEN)
    → boxClassFamilies_bundle_temporally_coherent (PROVEN)
      → construct_bfmcs_bundle (PROVEN)
        → completeness (needs wiring)
```

---

## Confidence Assessment

| Finding | Confidence |
|---------|------------|
| `f_preserving_seed_consistent` is false | **100%** — concrete counterexample |
| Bundle-level coherence is the correct path | **95%** — already sorry-free |
| Completeness can be wired through bundles | **85%** — depends on truth lemma adaptation |
| Dead code can be safely removed | **90%** — may affect downstream definitions |

---

## References

- Lines 1066-1082: `G_lift_from_context` mechanism
- Lines 1110-1149: `temporal_theory_witness_consistent` (working base case)
- Lines 1275-1276: `f_preserving_seed` definition
- Lines 1372-2102: `f_preserving_seed_consistent` (FALSE, with sorries)
- Lines 3476-3684: Bundle-level temporal coherence (PROVEN)
- Lines 3786-3810: `construct_bfmcs_bundle` (PROVEN)
- Lines 4928-4985: `omega_F_preserving_forward_F_resolution` (built on false foundation)
- Lines 5150-5186: `omega_true_dovetailed_forward_F_resolution` (sorry, same issue)

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | G-lift mechanism analysis | completed | high |
| B | Alternative proof strategies | completed | medium-high |

The synthesis identifies the counterexample from combining both teammates' analyses of the structural barriers. Teammate A's finding that G-lift requires homogeneous context + Teammate B's observation that F-formulas are "not semantically harmless" together pointed to the counterexample construction.
