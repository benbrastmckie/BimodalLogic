# Teammate D: Metalogic State Audit

**Task**: 58 - Wire Completeness to FrameConditions
**Date**: 2026-03-27
**Focus**: Metalogic State Audit — What's actually proven? Are we solving the right problem?

---

## 1. Current Proven Results (Sorry-Free)

### Algebraic Infrastructure (All Sorry-Free)

| File | Theorem/Def | What It Proves |
|------|-------------|----------------|
| `UltrafilterChain.lean` | `boxClassFamilies_bundle_forward_F` | F(phi) in fam.mcs(t) → witness in SOME family at s > t |
| `UltrafilterChain.lean` | `boxClassFamilies_bundle_backward_P` | P(phi) in fam.mcs(t) → witness in SOME family at s < t |
| `UltrafilterChain.lean` | `boxClassFamilies_bundle_temporally_coherent` | Bundle-level temporal coherence for boxClassFamilies |
| `UltrafilterChain.lean` | `construct_bfmcs_bundle` | Build `BFMCS_Bundle` from any MCS (sorry-free!) |
| `UltrafilterChain.lean` | `mcs_neg_gives_countermodel` | neg(phi) ∈ M → phi ∉ eval_family.mcs(0) |
| `UltrafilterChain.lean` | `bundle_completeness_contradiction` | {neg(phi)} consistent → ∃ MCS not containing phi |
| `UltrafilterChain.lean` | `not_provable_implies_neg_consistent` | ⊬ phi → {neg(phi)} is consistent |
| `ParametricTruthLemma.lean` | `parametric_canonical_truth_lemma` | Full bidirectional truth lemma for BFMCS D |
| `ParametricTruthLemma.lean` | `parametric_shifted_truth_lemma` | Truth lemma for ShiftClosedParametricCanonicalOmega |
| `ParametricRepresentation.lean` | `parametric_algebraic_representation_conditional` | If phi not provable AND construct_bfmcs given → countermodel exists |
| `SuccExistence.lean` | `constrained_successor_seed_consistent` | Single-element successor seed is consistent (via G-lift) |
| `SuccExistence.lean` | `constrained_successor_succ` | Single-element successor satisfies Succ relation |
| `SuccChainFMCS.lean` | `single_brs_element_with_g_content_consistent` | Single-BRS seed is consistent (sorry-free) |
| `SuccChainFMCS.lean` | `f_nesting_is_bounded_restricted` | F-nesting is bounded within deferralClosure(phi) |

### Core Sorry-Free Completeness (Partial)

| File | Theorem | What It Provides |
|------|---------|-----------------|
| `Completeness/SuccChainCompleteness.lean` | `succ_chain_completeness` | Completeness against SUCC-CHAIN model (has sorryAx via Box backward case) |
| `SoundnessLemmas.lean` | Various | Component soundness proofs for individual axioms |
| `DiscreteSoundness.lean` | `axiom_discrete_valid` | All discrete axioms valid on discrete frames (sorry-free) |
| `DenseSoundness.lean` | Similar | Dense axioms valid on dense frames |

### The Algebraic Representation Path (Sorry-Free Core)

`consistent_implies_satisfiable` in `AlgebraicRepresentation.lean` gives: if a context is
consistent, then it is satisfiable in the Lindenbaum algebra model. This is the algebraic
completeness theorem and is sorry-free. However, it proves `(∀ MCS, phi ∈ M) → provable phi`,
**not** `valid_over Int phi → provable phi`.

---

## 2. Dependency Analysis of the 3 Sorries

All three sorries in `Theories/Bimodal/FrameConditions/Completeness.lean`:

```
dense_completeness_fc (line 120)
discrete_completeness_fc (line 163)
bundle_validity_implies_provability (line 214)
   ↑ completeness_over_Int delegates to this
```

### What `dense_completeness_fc` Needs

```
valid_dense_fc phi
  = ∀ D [AddCommGroup] [LinearOrder] [IsOrderedAddMonoid]
      [Nontrivial] [NoMaxOrder] [NoMinOrder] [DenselyOrdered]
      [DenseTemporalFrame D], valid_over D phi
→ Nonempty ([] ⊢ phi)
```

Strategy documented in file: "Dense completeness FOLLOWS from Int completeness" because any
formula valid over ALL dense frames is in particular valid over some specific D. But this
reduction requires choosing a D that is BOTH dense AND sufficient for completeness. Int is
NOT densely ordered. Rat would work, but the canonical construction is built for Int.

**What's actually needed**: Either (a) prove `completeness_over_Int` and use the observation
that validity over Int implies provability (which is what `bundle_validity_implies_provability`
tries to do), or (b) directly instantiate the completeness proof at a dense D.

### What `discrete_completeness_fc` Needs

Same structure. Validity over all discrete frames → provability. The file notes that Int IS
discrete (it satisfies `SuccOrder`), so discrete completeness should follow from Int
completeness IF Int completeness is proven.

### What `bundle_validity_implies_provability` Needs

This is the core sorry (line 214 in `Completeness.lean`):

```lean
valid_over Int phi → Nonempty ([] ⊢ phi)
```

The proof sketch in the code:
1. `not_provable_implies_neg_consistent` → `{neg(phi)}` is consistent (sorry-free)
2. `bundle_completeness_contradiction` → some MCS M does not contain phi (sorry-free)
3. **GAP**: Need to show M corresponds to a model of `valid_over Int phi`

The sorry sits here: to use `valid_over Int phi`, we need to supply a concrete `TaskFrame Int`
model and history where phi is evaluated. The bundle construction (`construct_bfmcs_bundle`)
gives us a `BFMCS_Bundle` with `BundleTemporallyCoherent`, but converting this to a
`TaskFrame Int` model that satisfies `valid_over` requires `CanonicalTaskFrame` with
`BFMCS.temporally_coherent` (family-level, not bundle-level).

**The exact gap**: `parametric_shifted_truth_lemma` requires `BFMCS Int` with
`BFMCS.temporally_coherent` (family-level: F-witness in the SAME family). We have
`BFMCS_Bundle` with `BundleTemporallyCoherent` (bundle-level: F-witness in ANY family).
These are mathematically different.

### Are We Solving the Right Lemmas?

**The plan's current approach (Plan v17, Phase 1)**:
Build `restricted_bounded_witness` → fix `restricted_forward_chain_forward_F` → proceed.

**The actual blocker**: Multi-BRS seed consistency (`constrained_successor_seed_restricted_consistent`).
This is what prevents `RestrictedTemporallyCoherentFamily` from working for formulas with
multiple BRS elements. Single-BRS works, multi-BRS is unproven.

The plan is aimed at the **right** problem (family-level temporal coherence), but the
current implementation plan (v17) is blocked at Phase 1 by the same multi-BRS wall that
has blocked 21 previous approaches.

---

## 3. Problem Reframing: Are We Solving the Right Thing?

### The Real Question

The existing documentation (reports 77, 82-a, 82-b, 82-c) correctly identify the core
problem: there is a type mismatch between `BFMCS_Bundle` (what we can build) and
`BFMCS Int` (what the truth lemma needs).

**Restatement**: The sorry in `bundle_validity_implies_provability` is NOT about the
algebraic proof at all. It is about a semantic connection:

```
BFMCS_Bundle model  ←?→  valid_over Int semantics
```

The canonical model (`CanonicalTaskFrame`, `CanonicalTaskModel`, `CanonicalOmega`) is
already built and sorry-free. The truth lemma (`parametric_shifted_truth_lemma`) is
already proven for BFMCS with family-level coherence. The ONLY missing piece is:

> **Prove that `construct_bfmcs_bundle M h_mcs` can be WRAPPED into a `BFMCS Int`
> with `BFMCS.temporally_coherent`.**

Or alternatively:

> **Prove the truth lemma holds for `BFMCS_Bundle` (bundle-level coherence).**

### Why the Current Approach Targets the Wrong Layer

The current implementation plan (v17) aims to build `restricted_backward_chain` and
`constrained_predecessor_restricted` to eventually produce `construct_bfmcs_restricted`
(a `BFMCS Int` with family-level temporal coherence via the restricted construction).

This is the CORRECT mathematical approach but requires proving multi-BRS seed consistency,
which is the hard mathematical problem that has blocked all previous attempts.

### A Different Framing: Can We Adapt the Truth Lemma?

There is a potentially simpler path that no team report has fully analyzed:

**Question**: Can we prove a version of the truth lemma that uses `BFMCS_Bundle` directly,
without requiring family-level coherence?

Looking at `ParametricTruthLemma.lean` (which is sorry-free), the backward direction for
`all_future` is:
```
-- Need: G(ψ) ∈ fam.mcs t when ψ is true at all s ≥ t in fam
-- Proof: Assume G(ψ) ∉ fam.mcs t
-- → F(neg ψ) ∈ fam.mcs t (MCS negation completeness)
-- → ∃ s > t, neg ψ ∈ fam.mcs s  [needs SAME-family forward_F]
-- → neg ψ ∈ fam.mcs s AND ψ ∈ fam.mcs s  [contradiction in same MCS]
```

The bundle-level version breaks at step 3: we'd get `neg ψ ∈ fam'.mcs s` for a DIFFERENT
family `fam'`, so there's no contradiction.

This confirms: the truth lemma INHERENTLY requires family-level coherence. No adaptation
of the truth lemma to bundle-level coherence is possible without changing the semantics.

---

## 4. Alternative Paths to Sorry-Free Completeness

### Path A: Solve Multi-BRS Consistency (The Hard Path)

Prove `constrained_successor_seed_restricted_consistent` for arbitrary BRS size.
- Known to work for BRS = 1 element (single_brs_element_with_g_content_consistent)
- Blocked for BRS ≥ 2 by the G-lift barrier (G(x) ∉ M for BRS elements x)
- Multiple previous attempts failed (approaches 4, 8, 9, 21 in the catalog)
- **Assessment**: Hard. Possibly requires a fundamentally new technique.

### Path B: Deferral Disjunction Seeds (Untested, Promising)

Replace bare `psi` in BRS with `psi ∨ F(psi)` in the successor seed. Since
`psi ∨ F(psi)` is a deferral disjunction, it IS in the original MCS, making
consistency trivial. The question is whether the successor construction still
resolves F-obligations.

- **Key observation**: `f_nesting_is_bounded_restricted` is sorry-free. The bounded
  witness theorem knows how to extract `psi` when the chain contains `psi ∨ F(psi)`
  and `F(psi)` eventually leaves the closure.
- **Untested**: No report has attempted this variant. It is "untested, not blocked."
- **Assessment**: Medium potential. 2-4 hours to test; if it works, it solves the
  consistency problem at its root.

### Path C: Reduce 3 Sorries to 1 (Achievable Immediately)

The 3 sorries reduce to 1:
- `dense_completeness_fc` can call `bundle_validity_implies_provability` (Int embeds
  in dense orders: valid over ALL dense D → valid over some specific D, which with right
  choice → valid over Int models)
- `discrete_completeness_fc` can do the same (Int is discrete)
- Only `bundle_validity_implies_provability` needs the actual proof

This doesn't SOLVE the problem but clarifies the scope. The comment in Completeness.lean
(lines 253-276) already says this; it just isn't implemented because the "model-theoretic
glue" is the same hard problem.

### Path D: Weak Completeness via Algebraic Bypass (False Lead)

The `bundle_completeness_contradiction` theorem is sorry-free and proves:
```
not_provable → ∃ MCS M, phi ∉ M
```
This gives **syntactic completeness**: (∀ MCS M, phi ∈ M) → provable phi.
This is NOT what we need. We need: valid_over Int phi → provable phi.
The bridge between these two is EXACTLY the truth lemma.
- **Assessment**: Not viable for the stated goal.

### Path E: Use CanonicalTaskFrame Directly (Potential)

The `CanonicalTaskFrame : TaskFrame Int` is sorry-free. The `CanonicalTaskModel` is
sorry-free. The `ShiftClosedCanonicalOmega` is sorry-free. The `parametric_shifted_truth_lemma`
is sorry-free.

**Question**: Can we build a sorry-free `BFMCS Int` (not just `BFMCS_Bundle`) with
`BFMCS.temporally_coherent` for ANY MCS, without solving multi-BRS consistency?

The `SuccChainFMCS` gives forward_G and backward_H but NOT forward_F and backward_P.
The `RestrictedTemporallyCoherentFamily` gives forward_F and backward_P but requires
multi-BRS consistency.

Is there any construction that gives ALL FOUR without multi-BRS consistency? The Z-chain
(`OmegaFMCS`) in `UltrafilterChain.lean` attempted this but has 4 sorries in the crossing
cases (lines 2347, 2369, 2383, 2485, 2494). Those sorries are about G/H propagation
through the chain, which is a separate obstruction.

**Assessment**: The Z-chain path has different sorries but may be tractable (G/H propagation
through a concatenation of forward+backward chains is a concrete engineering problem, not
the G-lift wall).

---

## 5. Big Picture: What Does the Project Need?

### For "Sorry-Free Completeness"

The project needs exactly ONE of these:
1. A sorry-free `BFMCS Int` with `BFMCS.temporally_coherent` for any MCS (family-level)
2. A modified truth lemma that works with `BFMCS_Bundle` (bundle-level) — mathematically
   requires changing semantics, not viable
3. A direct proof that skips the truth lemma entirely — not possible (truth lemma is the
   only bridge between MCS membership and validity)

The cleanest statement is:
> **We need family-level temporal coherence.** We have bundle-level. This gap is the
> entire task 58 problem, and it has been correctly identified. We are NOT solving the
> wrong problem.

### What the Codebase Is Missing

Looking at the Z-chain construction (`OmegaFMCS`), the sorries (lines 2347, 2369, 2383,
2485, 2494) are about:
- Lines 2347, 2369: G(phi) propagation from backward chain to forward chain (crossing case)
- Line 2383: `Z_chain_backward_H` (H-propagation in backward direction)
- Lines 2485, 2494: `Z_chain_forward_F` and `Z_chain_backward_P` (F/P witness existence)

These are DIFFERENT from the multi-BRS wall. They are about:
- Does G(phi) persist when crossing the "seam" between forward and backward chains?
- Do F/P obligations get resolved by the omega-enumeration construction?

The omega-enumeration construction (described at line 1865+) was designed to resolve
F/P obligations "by construction" through dovetailing. But it was never completed into
a full proof.

---

## 6. Confidence Level: HIGH

### Summary Verdict

**We are NOT pointing at the wrong problem.** The task is correctly framed: the 3 sorries
in `FrameConditions/Completeness.lean` all reduce to the single sorry in
`bundle_validity_implies_provability`, which requires family-level temporal coherence.
This has been correctly identified.

**The problem with our approach**: We keep cycling through approaches that require
multi-BRS consistency (the G-lift wall) without solving it. The current plan (v17)
is the same pattern.

**Two genuinely untested alternatives exist**:

1. **Deferral disjunction seeds (Path B)**: Replace BRS elements `psi` with `psi ∨ F(psi)`
   in the successor seed. Since `psi ∨ F(psi)` is already in the MCS (as a deferral
   disjunction), consistency is trivial. The question is whether forward_F still works.
   This has never been attempted and is not blocked.

2. **Complete the Z-chain (Path E variation)**: The `OmegaFMCS` in `UltrafilterChain.lean`
   was designed to give family-level temporal coherence through omega-enumeration. The
   sorries there (G/H crossing case and F/P witness existence) are DIFFERENT from the
   multi-BRS wall. The crossing case sorry (lines 2347, 2369) might be solvable by
   tracking G/H theory through the chain join point.

**Recommendation**: Before attempting another plan version of the restricted construction
path, AUDIT the Z-chain sorries specifically:
- Are lines 2347 and 2369 actually hard (G-lift barrier), or are they engineering problems
  (G(phi) should propagate through the seam because M0 contains G(phi) and the forward
  chain starts from M0)?
- If the crossing case requires G_theory(M0) ⊆ G_theory(chain(n)) for all n, and if this
  IS provable for the forward chain (it is, by construction), then G(phi) propagation
  across the seam from backward to forward may be straightforward.

This is a 1-2 hour targeted audit that could reveal a shorter path than multi-BRS.

---

## Appendix: Sorry Count by File (Metalogic)

| File | Sorries |
|------|---------|
| `Algebraic/UltrafilterChain.lean` | 7 actual sorry calls (others are comments/docs) |
| `Bundle/SuccChainFMCS.lean` | ~10 actual sorry calls |
| `Bundle/SuccChainTruth.lean` | 1 actual sorry call (imp backward case, intentional documentation) |
| `Bundle/CanonicalConstruction.lean` | 2 actual sorry calls (forward_G/backward_H in restricted_tc_family_to_fmcs) |
| `Algebraic/RestrictedTruthLemma.lean` | 3 actual sorry calls (G propagation through chain) |
| `FrameConditions/Completeness.lean` | 3 actual sorry calls (the targets) |
| `Metalogic/Soundness.lean` | 5 sorries (density/discreteness/seriality axioms — separate task) |
| All Parametric/Algebraic files | 0 sorries |

The sorry-free algebraic infrastructure is extensive and robust. The gaps are all in the
temporal coherence layer (family-level F/P witness existence).
