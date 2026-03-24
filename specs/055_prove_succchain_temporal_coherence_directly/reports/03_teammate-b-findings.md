# Teammate B Research Findings: Cross-Family Witnesses and Semantic Approaches

**Task**: 55 - Prove SuccChain temporal coherence directly
**Date**: 2026-03-24
**Focus**: Cross-family witnesses, truth lemma dependency, semantic alternatives
**Session**: sess_1774386313_93d135

---

## Key Findings

### 1. The Sorry Chain is Already Bypassed (HIGH CONFIDENCE)

The critical discovery: **`boxClassFamilies_temporally_coherent` does NOT flow through
`f_nesting_is_bounded`**. Reading `UltrafilterChain.lean:1668-1679`:

```lean
theorem boxClassFamilies_temporally_coherent (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) :
    ∀ fam ∈ boxClassFamilies M0 h_mcs, ... := by
  intro fam hfam
  obtain ⟨W, h_W, k, _, rfl⟩ := hfam
  let tcf := SuccChainTemporalCoherent (MCS_to_SerialMCS W h_W)
  constructor
  · exact shifted_temporal_forward_F (SuccChainFMCS (MCS_to_SerialMCS W h_W)) tcf.forward_F k
  · exact shifted_temporal_backward_P (SuccChainFMCS (MCS_to_SerialMCS W h_W)) tcf.backward_P k
```

This calls `SuccChainTemporalCoherent` which calls `succ_chain_forward_F`
(`SuccChainFMCS.lean:1156-1159`), which calls `f_nesting_boundary`
(`SuccChainFMCS.lean:822`), which calls the sorry `f_nesting_is_bounded`
(`SuccChainFMCS.lean:735`).

So the sorry chain IS still present: `f_nesting_is_bounded → f_nesting_boundary →
succ_chain_forward_F → SuccChainTemporalCoherent → boxClassFamilies_temporally_coherent`.

However, **`temporal_theory_witness_exists` and `past_theory_witness_exists` are ALREADY
PROVEN** in `UltrafilterChain.lean:1158-1422` and never use `f_nesting_is_bounded`.
They are self-contained, sorry-free proofs.

### 2. Truth Lemma Dependency Analysis (HIGH CONFIDENCE)

The truth lemma (`ParametricTruthLemma.lean:170-309`) requires `B.temporally_coherent`
via `h_tc fam hfam` which destructs to `(h_forward_F, h_backward_P)`.

For the `all_future` (G) backward case (lines 280-289):
```lean
· intro h_all
  obtain ⟨h_forward_F, h_backward_P⟩ := h_tc fam hfam
  let tcf : TemporalCoherentFamily D := { toFMCS := fam, forward_F := h_forward_F, backward_P := h_backward_P }
  have h_all_mcs : ∀ s : D, t < s → ψ ∈ fam.mcs s := ...
  exact temporal_backward_G tcf t ψ h_all_mcs
```

The truth lemma uses `temporal_backward_G` (defined in `TemporalCoherence.lean:165`),
which in turn uses `fam.forward_F`. The backward G proof by contraposition is:
- Assume G(phi) not in `fam.mcs t`
- Get F(neg phi) in `fam.mcs t` (by MCS negation completeness)
- Get witness s > t with neg(phi) in `fam.mcs s` (via `forward_F`)
- Contradiction: phi AND neg(phi) in `fam.mcs s`

**The witness MUST be in the SAME family `fam`** — not a cross-family witness.
The proof type signature is:
```lean
structure TemporalCoherentFamily (D : Type*) ... extends FMCS D where
  forward_F : ∀ t : D, ∀ φ : Formula,
    Formula.some_future φ ∈ mcs t → ∃ s : D, t < s ∧ φ ∈ mcs s
```

The `s` index is within the SAME family's `mcs`. So cross-family witnesses cannot
directly satisfy this requirement.

### 3. Cross-Family Witnesses: Not Applicable as Stated (HIGH CONFIDENCE)

The BFMCS structure provides cross-family witnesses for the **box operator** (modal),
where `modal_forward` says box phi in ANY family implies phi in ALL families. This works
because the box semantic is "truth in all accessible worlds" and all families are
mutually accessible.

For temporal operators G and H, the semantic is "truth at all FUTURE/PAST times", which
is a property of a SINGLE timeline. Each FMCS is one timeline. Cross-family witnesses
would change the semantics: instead of "at some future time in THIS timeline", it would
mean "at some future time in SOME timeline", which is not what G/H means.

**Cross-family witnesses cannot replace same-family `forward_F`** without changing the
truth lemma's semantics.

### 4. The Real Blocker: `succ_chain_forward_F` Calls `f_nesting_is_bounded` (HIGH CONFIDENCE)

The sorry chain in `succ_chain_forward_F` (`SuccChainFMCS.lean:811-847`):

```
succ_chain_forward_F (n : Int) (phi : Formula)
  (h_F : Formula.some_future phi ∈ succ_chain_fam M0 n) :
  ∃ m : Int, n < m ∧ phi ∈ succ_chain_fam M0 m
```

This is the EXACT statement of `TemporalCoherentFamily.forward_F`. It calls
`f_nesting_boundary` (line 822/774), which calls `f_nesting_is_bounded` (sorry).

The `temporal_theory_witness_exists` theorem ALREADY proves this existential claim
at the MCS level: given F(phi) ∈ M, there exists W (a full MCS) with phi ∈ W and
G-theory/box-theory agreement with M. The witness W corresponds to the MCS at
the next time step, not an arbitrary time in the chain.

### 5. The Bypass: Use `temporal_theory_witness_exists` as `succ_chain_forward_F` (MEDIUM-HIGH CONFIDENCE)

The algebraic approach from `temporal_theory_witness_exists` provides a witness MCS W
with `phi ∈ W`. The challenge is: how does W become `succ_chain_fam M0 m` for some m > n?

**Key insight**: The forward chain is built by iterating
`constrained_successor_from_seed`, which constructs the NEXT MCS using the temporal
seed. The `temporal_theory_witness_exists` shows that the SEED `{phi} ∪ G_theory(M) ∪
box_theory(M)` is consistent, which is exactly what the seed construction uses.

The constrained successor construction (`WitnessSeed.lean` or `SuccExistence.lean`)
uses a seed that includes G-theory and box-theory elements to produce the next MCS.
This means:

If `F(phi) ∈ succ_chain_fam M0 n`, then `phi ∈ succ_chain_fam M0 (n+1)` IF
the seed used at step n includes phi (via its deferral disjunction `phi ∨ F(phi)`).

**The deferral problem**: The `constrained_successor_from_seed` uses deferral
disjunctions `phi ∨ F(phi)`. The successor might pick `F(phi)` instead of `phi`,
deferring the witness. This is the phase-3 blocker mentioned in the delegation.

### 6. Deflationary Approach: Bypass `SuccChainTemporalCoherent` Entirely (HIGH CONFIDENCE)

Looking at `boxClassFamilies_temporally_coherent` (lines 1668-1679), the structure is:

```
For each fam ∈ boxClassFamilies M0:
  fam = shifted_fmcs (SuccChainFMCS W) k
  → use shifted_temporal_forward_F with SuccChainFMCS W's forward_F
```

The key function `shifted_temporal_forward_F` (`UltrafilterChain.lean:301-310`) takes
any `f : FMCS Int` and its `forward_F` proof, then lifts it to the shifted version.

**The deflationary approach**: Prove `succ_chain_forward_F` using
`temporal_theory_witness_exists` DIRECTLY, bypassing the `f_nesting_is_bounded` chain.

The argument would be:
1. F(phi) ∈ succ_chain_fam M0 n = M (some MCS)
2. By `temporal_theory_witness_exists(M)`: ∃ W with phi ∈ W and G_theory(M) ⊆ W
3. W is consistent and has G(a) ∈ W for all G(a) ∈ M
4. The NEXT chain element is built using the seed `G_theory(M) ∪ box_theory(M)`
5. Since W agrees on G_theory and phi ∈ W, the chain's next element can contain phi
   IF phi gets selected (not deferred)

**The deferral gap**: Step 4→5 requires showing that the constrained successor does
NOT always defer phi. This is not guaranteed by the construction.

### 7. Alternative: Direct Witness from Temporal Theory (MEDIUM CONFIDENCE)

Instead of connecting W to the existing SuccChain, prove `succ_chain_forward_F`
by building a NEW chain that starts from W:

1. F(phi) ∈ succ_chain_fam M0 n = M_n
2. temporal_theory_witness_exists → W with phi ∈ W and box_class_agree(M_n, W)
3. But we need W to be at index n+1 in the SAME chain

The chain is DETERMINISTIC: `forward_chain M0 k = constrained_successor^k(M0)`.
A newly constructed W from temporal_theory_witness_exists is NOT guaranteed to equal
`forward_chain M0 (n+1)`.

This is the fundamental tension: the truth lemma needs a SAME-FAMILY witness
(a specific chain index), but the algebraic existence proof only gives an ABSTRACT MCS.

### 8. Literature Patterns (MEDIUM CONFIDENCE)

Standard completeness proofs for combined temporal-modal logics (e.g., Gabbay-Hodkinson
approach for S5 + LTL) handle this by:

**Method A (Standard)**: Build the temporal model as a FULL saturated structure where
each world M_n is constructed to contain both G-theory AND all F-obligations. This
requires the construction at each step to explicitly resolve F-formulas (not defer them).
The deferral strategy in the current code's constrained_successor is unusual.

**Method B (Filtration)**: Use a finite model property approach where the temporal
witnesses are bounded by the closure of the target formula. This maps to the
`f_nesting_is_bounded_restricted` approach (which IS proven for RestrictedMCS).

**Method C (Bundle models)**: Use infinite families where temporal witnesses are
found by a selection function. This maps to what the algebraic approach suggests:
the bundle contains enough families that for each F(phi), SOME family witnesses phi.

The current code uses Method A partially but with deferral, which is the source of
the sorry.

---

## Truth Lemma Dependency Analysis

The dependency graph for `temporal_backward_G`:

```
temporal_backward_G (TemporalCoherence.lean:165)
  requires: forward_F : F(phi) ∈ fam.mcs t → ∃ s > t, phi ∈ fam.mcs s
    satisfied by: SuccChainTemporalCoherent.forward_F
      = succ_chain_forward_F (SuccChainFMCS.lean:811)
        calls: f_nesting_boundary (line 822)
          calls: f_nesting_is_bounded (line 735) ← SORRY
```

The dependency is purely within a single FMCS family — no cross-family information flows
through this path.

---

## Cross-Family Feasibility Assessment

**Cross-family witnesses cannot help with `forward_F`** because:
1. `BFMCS.temporally_coherent` requires per-family forward_F (not cross-family)
2. The truth lemma's `temporal_backward_G` uses `tcf.forward_F` which produces a same-family witness
3. The time index `s` in `forward_F` MUST be an index in the SAME family's mcs function

Cross-family witnesses ARE used for the **box operator** in `BFMCS.diamond_witness`
and `boxClassFamilies_modal_forward/backward`, but these are fundamentally different.

The only way cross-family information could help is through BUNDLE-LEVEL temporal
coherence (finding a DIFFERENT family with phi at some s > t), but this would require
redefining `BFMCS.temporally_coherent` to allow cross-family witnesses, and then
rewriting the truth lemma to match. This is major surgery.

---

## Recommended Approach with Rationale

### Primary Recommendation: Fix `succ_chain_forward_F` via `temporal_theory_witness_exists`

The core issue is that `succ_chain_forward_F` currently uses the sorry
`f_nesting_is_bounded`. The `temporal_theory_witness_exists` theorem ALREADY proves the
key consistency fact needed. The missing piece is connecting the abstract MCS witness
to a concrete chain index.

**Proposed new proof of `succ_chain_forward_F`**:

The key insight is that `temporal_theory_witness_exists` gives us W with phi ∈ W and
`G_theory(M_n) ⊆ W`. Now observe:

- M_n = succ_chain_fam M0 n is an arbitrary MCS
- `temporal_theory_witness_exists` gives W = MCS with phi ∈ W and G-theory agreement
- We need: phi ∈ succ_chain_fam M0 m for some m > n

The approach: Instead of proving phi is at a SPECIFIC index m, create a NEW succ-chain
from W and use the bundle structure. In `boxClassFamilies`, each chain W gives a family
`shifted_fmcs (SuccChainFMCS W) k`. The temporal coherence for THIS family follows from
`SuccChainTemporalCoherent W`.

But `SuccChainTemporalCoherent W` also calls `succ_chain_forward_F` — we'd be circular.

### Secondary Recommendation: Restrict to RestrictedMCS context

The proven `f_nesting_is_bounded_restricted` works for `RestrictedMCS phi M` where
M ⊆ closureWithNeg phi. The function `succ_chain_forward_F` is called from
`SuccChainTemporalCoherent`, which is used in `boxClassFamilies_temporally_coherent`.

**If the base MCS M0 can be taken as a RestrictedMCS** (built within the closure of some
target formula chi), then `f_nesting_boundary_restricted` applies and the sorry chain
is broken.

However, this requires the completeness proof to start from a target formula chi and
build M0 within closureWithNeg chi. Looking at `DiscreteCompleteness.lean` and
`SuccChainCompleteness.lean`, the base MCS is built from the negation of the target
formula, so RestrictedMCS structure IS available at the start.

**Effort**: Medium. Requires threading the RestrictedMCS constraint through
`SuccChainFMCS → SuccChainTemporalCoherent → boxClassFamilies_temporally_coherent`.

### Tertiary Recommendation: Direct temporal_theory replacement (HIGH EFFORT)

Completely replace `succ_chain_forward_F` with a non-constructive proof using
`temporal_theory_witness_exists`:

1. F(phi) ∈ succ_chain_fam M0 n
2. temporal_theory_witness_exists → W with phi ∈ W, G_theory agreement, box_class_agree
3. succ_chain_fam M0 (n+1) is the constrained successor of succ_chain_fam M0 n
4. **Need**: phi ∈ constrained_successor_from_seed(M_n)

Step 4 requires showing that the constrained successor DOES include phi when F(phi) ∈ M_n.
This is exactly what the deferral construction was supposed to handle, but fails for.

The `temporal_theory_witness_exists` proof strategy (deducing consistency of the seed)
could be adapted to show that the constrained_successor seed is consistent with phi
included. But the constrained_successor uses `deferralDisjunctions` (phi ∨ F(phi)),
not phi directly. The Lindenbaum extension from this seed might pick F(phi) not phi.

---

## References to Specific Theorems and Line Numbers

| Theorem | File | Lines | Status |
|---------|------|-------|--------|
| `f_nesting_is_bounded` | SuccChainFMCS.lean | 731-735 | SORRY (mathematically false) |
| `f_nesting_boundary` | SuccChainFMCS.lean | 755-759 | Depends on sorry |
| `succ_chain_forward_F` | SuccChainFMCS.lean | 811-847 | Depends on sorry |
| `SuccChainTemporalCoherent` | SuccChainFMCS.lean | 1156-1159 | Depends on sorry |
| `boxClassFamilies_temporally_coherent` | UltrafilterChain.lean | 1668-1679 | Depends on sorry |
| `temporal_theory_witness_exists` | UltrafilterChain.lean | 1158-1190 | PROVED, sorry-free |
| `past_theory_witness_exists` | UltrafilterChain.lean | 1393-1422 | PROVED, sorry-free |
| `temporal_backward_G` | TemporalCoherence.lean | 165-178 | PROVED, sorry-free |
| `temporal_backward_H` | TemporalCoherence.lean | 191-204 | PROVED, sorry-free |
| `shifted_temporal_forward_F` | UltrafilterChain.lean | 301-310 | PROVED, sorry-free |
| `f_nesting_is_bounded_restricted` | SuccChainFMCS.lean | 693-709 | PROVED for RestrictedMCS |
| `f_nesting_boundary_restricted` | SuccChainFMCS.lean | 711-736 | PROVED for RestrictedMCS |

---

## Synthesis

The sorry chain flows through `f_nesting_is_bounded` (which is FALSE for arbitrary MCS
but TRUE for RestrictedMCS). The `temporal_theory_witness_exists` approach bypasses
this by using a Lindenbaum-extension existential argument, but it produces an ABSTRACT
witness MCS W, not a specific chain index.

The fundamental question is: can we replace the constructive `succ_chain_forward_F`
(which finds an explicit index m > n) with a non-constructive proof (which merely
asserts existence of some m)?

Answer: YES, because `forward_F` is:
```lean
forward_F : ∀ t : D, ∀ φ : Formula, Formula.some_future φ ∈ mcs t → ∃ s : D, t < s ∧ φ ∈ mcs s
```

This is an EXISTENTIAL claim. The proof does NOT need to find a specific index — it
only needs to show EXISTENCE. The current proof finds the index m = n + d where d is
from `f_nesting_boundary`. A new proof using `temporal_theory_witness_exists` could
instead show that m = n + 1 works (phi IS in the next step), IF we can prove the
constrained_successor includes phi when F(phi) is in the source MCS.

**The key missing lemma**: `constrained_successor_includes_F_witnesses`
```
If F(phi) ∈ M, then phi ∈ constrained_successor_from_seed M h_mcs h_F_top
```

This would give m = n + 1 always (phi appears at the NEXT step), replacing the
entire sorry chain. This is provable via `temporal_theory_witness_consistent` (already
proven) IF we can show the constrained_successor's seed is consistent with phi.

**Reading `SuccExistence.lean:474-538` confirms**: `constrained_successor_from_seed`
uses seed:
```
g_content(u) ∪ deferralDisjunctions(u) ∪ p_step_blocking_formulas(u)
```
where `deferralDisjunctions(u) = {phi ∨ F(phi) | F(phi) ∈ u}`.

This is NOT `{phi} ∪ G_theory(M) ∪ box_theory(M)`. The seed contains the DISJUNCTION
`phi ∨ F(phi)`, and `constrained_successor_satisfies_f_step` (`SuccExistence.lean:512`)
shows that by MCS disjunction_elim, either phi ∈ succ or F(phi) ∈ succ. The successor
MAY defer phi.

**Conclusion**: The `constrained_successor_includes_F_witnesses` lemma is NOT provable
from the current construction — phi might be deferred indefinitely. This confirms why
`f_nesting_is_bounded` was needed (to show the iteration eventually terminates), and
why it fails for arbitrary MCS.

**The correct fix MUST bypass the iterative construction entirely** and use the
Lindenbaum-based existential approach. The successor chain needs to be built with a
DIFFERENT seed that forces phi to be included (not deferred), analogously to how
`temporal_theory_witness_exists` builds W with `{phi} ∪ G_theory(M)`.

This is exactly what the primary recommendation in the team research synthesis suggests:
replace `succ_chain_forward_F` with a direct application of `temporal_theory_witness_exists`,
but the NEW chain element (at index n+1) must be built via Lindenbaum extension of
`{phi} ∪ G_theory(M_n)`, not via `constrained_successor_from_seed`. This requires
refactoring the forward chain construction itself.
