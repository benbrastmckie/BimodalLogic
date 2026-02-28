# Research Report: Task 945 — Design Canonical Model Construction for TruthLemma

**Task**: 945 — Design canonical model construction for TruthLemma
**Date**: 2026-02-27
**Mode**: Team Research (2 teammates, Opus 4.6)
**Session**: sess_1772210334_244576

---

## Summary

The research team investigated the current state of the bimodal metalogic to identify what blocks the representation theorem and to evaluate construction strategies for a canonical model that satisfies the TruthLemma. Both teammates converged on the same diagnosis with no conflicts.

**The TruthLemma is not the problem.** `bmcs_truth_lemma` (TruthLemma.lean) is fully sorry-free across all six cases (atom, bot, imp, box, all_future, all_past). It holds for ANY BFMCS satisfying `B.temporally_coherent` and `is_modally_saturated B`.

**The problem is the BFMCS bundle construction.** The single blocking sorry is `fully_saturated_bfmcs_exists_int` (TemporalCoherentConstruction.lean:600), which must produce a BFMCS satisfying both temporal coherence (for ALL families) and modal saturation simultaneously. This combination is a genuine mathematical difficulty that has resisted 12+ approaches across tasks 812–932.

**Unanimous recommendation**: Bypass BFMCS entirely via FMP strong completeness (the `bigAnd(Gamma)` trick), achieving sorry-free strong completeness in an estimated 2–4 hours.

---

## Key Findings

### 1. Complete Sorry Inventory (Active Metalogic)

| # | File | Line | Declaration | Dependency Chain |
|---|------|------|-------------|------------------|
| 1 | DovetailingChain.lean | 1869 | `buildDovetailingChainFamily_forward_F` | → `temporal_coherent_family_exists_theorem` |
| 2 | DovetailingChain.lean | 1881 | `buildDovetailingChainFamily_backward_P` | → `temporal_coherent_family_exists_theorem` |
| 3 | TemporalCoherentConstruction.lean | 600 | `fully_saturated_bfmcs_exists_int` | → ALL BFMCS completeness + Representation |

Sorries 1–2 feed into Sorry 3, but Sorry 3 has an ADDITIONAL blocker beyond the DovetailingChain (see §2). Resolving 1–2 alone is insufficient.

**Files with 0 sorries**: TruthLemma.lean, Completeness.lean, Representation.lean, BFMCS.lean, BFMCSTruth.lean, ModalSaturation.lean, CanonicalFrame.lean, CanonicalFMCS.lean, SemanticCanonicalModel.lean, Construction.lean.

### 2. The Core Blocking Tension

The `fully_saturated_bfmcs_exists_int` theorem must produce a `BFMCS Int` satisfying:

```lean
(∀ gamma ∈ Gamma, gamma ∈ B.eval_family.mcs 0)  -- context preservation
∧ B.temporally_coherent                           -- ALL families: forward_F + backward_P
∧ is_modally_saturated B                          -- Diamond witnesses exist in bundle
```

**`temporally_coherent`** requires every family in the bundle to satisfy:
- `forward_F`: `F(φ) ∈ fam.mcs t → ∃ s ≥ t, φ ∈ fam.mcs s`
- `backward_P`: `P(φ) ∈ fam.mcs t → ∃ s ≤ t, φ ∈ fam.mcs s`

**`is_modally_saturated`** requires: whenever `◇ψ ∈ fam.mcs t` for some family, there must exist a witness family `fam'` in the bundle with `ψ ∈ fam'.mcs t`.

**The fundamental tension** (confirmed by both teammates independently):

Modal saturation creates **witness families** for each Diamond obligation. The standard approach uses **constant families** (`fam'.mcs s = W` for all `s`). But constant families **cannot be temporally coherent**: the set `{F(ψ), ¬ψ}` is consistent, so Lindenbaum can produce an MCS `W` containing both. Such `W` violates `F(ψ) → ψ` (which temporal saturation of a constant family requires). This impossibility is not a formalization artifact — it is a mathematical fact.

**Why the IH cross-dependency forces coherence on ALL families**: The Box case of the truth lemma applies the IH to all bundle families at the subformula. If the formula contains temporal operators (e.g., `Box(G(ψ))`), then the IH for `G(ψ)` at each witness family `fam'` requires temporal coherence of `fam'`. This is why `bmcs_truth_lemma` requires `B.temporally_coherent` universally, not just for the eval family.

### 3. The DovetailingChain: Why Forward_F/Backward_P Fail Over Int

The DovetailingChain (`DovetailingChain.lean`) builds `M_{n+1}` from `GContent(M_n)`. The formula `F(ψ) = ¬G(¬ψ)` is **not** captured by `GContent` (which only captures G-formulas). Lindenbaum's non-constructive extension at step `n+1` is free to include `G(¬ψ)`, killing the F-obligation from `M_n`.

Forward_G and backward_H **are** fully proven (including all cross-sign cases via GContent/HContent duality). The 2 sorries are structurally inherent to the linear sequential chain over Int and cannot be resolved within that architecture.

### 4. Why CanonicalMCS Achieves Temporal Coherence "For Free" (Single Family)

`CanonicalFMCS.lean` provides a sorry-free `FMCS CanonicalMCS` where `forward_F` holds trivially. The structural explanation:

- **Int chain (sequential)**: witnesses must be placed IN a single linear sequence; later constructions corrupt earlier F-obligations via GContent truncation.
- **CanonicalMCS (parallel)**: each F-obligation `F(φ) ∈ w.world` produces a **fresh independent** Lindenbaum extension `W` from `{φ} ∪ GContent(w.world)`. Since `W` is an MCS, it is automatically a domain element. No later construction touches `W`. The preorder condition `w ≤ W` holds by construction (`GContent(w.world) ⊆ W.world`).

The structural difference is **sequential vs. parallel witness construction**, not the domain type per se.

**Why CanonicalMCS does not solve the BFMCS bundle problem**: A BFMCS over CanonicalMCS needs MULTIPLE families for modal diversity. The identity-mapping family (`fam.mcs(v) = v.world`) gives sorry-free temporal coherence but produces no modal diversity — all such families agree at every point, so `modal_backward` fails. Constant witness families fail temporal coherence (same impossibility as over Int). The selection function approach (monotone `σ : CanonicalMCS → CanonicalMCS`) fails because Lindenbaum witnesses cannot be controlled to land in the image of `σ`. The CanonicalMCS domain solves the SINGLE-FAMILY temporal coherence problem but has the SAME modal saturation + coherence combination problem for bundles.

### 5. The Banned MCS-Membership Approach

`bmcs_truth_lemma_mcs` (archived to `Boneyard/Bundle/MCSMembershipCompleteness.lean`) broke the IH cross-dependency by defining Box as flat MCS membership (`φ ∈ fam'.mcs t` rather than recursive truth). This only needed eval-family temporal coherence. However, this approach was deliberately banned (Task 931) because it establishes completeness with respect to a non-standard validity notion, not the standard `⊨` from `Bimodal.Semantics.Validity`. This approach is not to be revisited.

### 6. The FMP Alternative: Sorry-Free Weak Completeness Exists

`SemanticCanonicalModel.lean` provides sorry-free weak completeness via finite models (`fmp_weak_completeness`). This depends only on `propext`, `Classical.choice`, `Quot.sound` — no `sorryAx`. The FMP approach uses a fundamentally different architecture: a single finite Kripke model, no bundle, no temporal coherence requirement, finite subformula closure. It avoids the bundle problem entirely.

---

## Design Space Analysis: Three Paths

### Path 1: Weaken Temporal Coherence Requirement

**Idea**: Reformulate the truth lemma to require temporal coherence only for the specific family being evaluated, breaking the IH cross-dependency.

**Analysis**: The IH cross-dependency is structural and cannot be avoided while keeping the recursive truth definition with Box quantifying over all families. Specifically, proving `Box(G(ψ))` at `fam` requires the truth lemma for `G(ψ)` at every `fam'`, which requires temporal coherence of `fam'`. Any reformulation that breaks this dependency either changes the Box semantics (the banned MCS-membership approach) or changes the truth definition to something non-standard.

**Verdict**: Blocked without changing fundamental semantics. The banned MCS-membership approach IS the correct way to execute this path, and it has been deliberately rejected for semantic alignment reasons.

### Path 2: Non-Constant Temporally Coherent Witness Families

**Idea**: Build witness families that are not constant but still temporally coherent (satisfying forward_F/backward_P), avoiding the impossibility of constant families.

**Analysis**: Any such family requires its own forward_F/backward_P proof. Over Int, this means another DovetailingChain-like construction with the same 2 inherent sorries. Over CanonicalMCS, the selection function approach fails because Lindenbaum witnesses cannot be controlled. The depth-stratified temporal coherence idea (reformulating the truth lemma to require coherence only for formulas up to depth `d`, with constant families working at depth 0) is speculative and unexplored, but estimated at 8–20 hours with 40–60% success probability. Its formalization complexity is high and it would require restructuring the truth lemma proof entirely.

**Verdict**: The only unexplored sub-path (depth stratification) is speculative with uncertain success. All other sub-paths have been tried across 12+ approaches.

### Path 3: FMP Strong Completeness via bigAnd(Gamma)

**Idea**: Extend the sorry-free FMP weak completeness to strong completeness using the standard conjunction trick for finite contexts, completely bypassing the BFMCS construction.

**Mathematical argument**:
1. `fmp_weak_completeness` establishes: `(⊨ φ) → (⊢ φ)` (sorry-free)
2. For finite context `Gamma : List Formula`, define `bigAnd(Gamma)` = conjunction of all formulas in Gamma
3. `Gamma ⊨ φ` implies `⊨ (bigAnd(Gamma) → φ)` (standard semantic consequence argument)
4. By `fmp_weak_completeness`: `⊢ (bigAnd(Gamma) → φ)`
5. `Gamma ⊢ bigAnd(Gamma)` by repeated conjunction introduction
6. By modus ponens (cut): `Gamma ⊢ φ`

**Infrastructure needed**: `bigAnd : List Formula → Formula` (fold with conjunction), conjunction introduction for lists, bridge between `semantic_consequence Gamma φ` and `⊨ (bigAnd(Gamma) → φ)`. The deduction theorem already exists.

**Verdict**: This is the recommended path. Sorry-free, bounded effort (2–4 hours), 90%+ success probability. It sidesteps the BFMCS problem entirely and achieves the meta-theoretic goal of strong completeness.

---

## Synthesis

### Conflicts Resolved

No conflicts between teammates. Both independently:
- Identified `fully_saturated_bfmcs_exists_int` as the sole blocker
- Confirmed the truth lemma is sorry-free
- Confirmed the constant-family impossibility (mathematical, not formalization)
- Identified the IH cross-dependency as the structural reason all families need temporal coherence
- Recommended Path 3 (FMP strong completeness) unanimously

### Gaps Identified

1. **BFMCS temporal + modal combination**: No known solution. Depth-stratified temporal coherence is unexplored but speculative.
2. **DovetailingChain forward_F/backward_P**: Inherent to linear chain architecture over Int. Resolving these 2 sorries is a separate long-term project (20–40 hours, omega-squared construction).
3. **CanonicalMCS BFMCS**: Temporal coherence is solved for a single FMCS, but constructing a FULL BFMCS over CanonicalMCS with modal saturation has not been attempted — and faces the same modal saturation combination problem as over Int.

### Key Architectural Insight for Task 945

The task description says "once the right construction is found, establishing the TruthLemma will be easy." This is accurate: the TruthLemma itself IS easy given the right BFMCS. The question is finding a construction that yields such a BFMCS with the right properties.

The research shows that the **CanonicalMCS** is the "right construction" for a **single temporally coherent family** — and this has already been implemented sorry-free in `CanonicalFMCS.lean`. The challenge is extending this to a BUNDLE for modal saturation. No sorry-free BFMCS construction over any domain has been found that satisfies both temporal coherence universally and modal saturation.

The FMP route provides an ALTERNATIVE "right construction": a finite Kripke model built from the subformula closure of `bigAnd(Gamma)`. In this construction, the TruthLemma holds (it's proven in `SemanticCanonicalModel.lean`) and strong completeness follows by the conjunction argument. This IS a construction where "the TruthLemma is easy" — it was designed from the start to make it hold.

---

## Recommendations

### Primary: Pursue Path 3 (FMP Strong Completeness)

Extend `fmp_weak_completeness` to `fmp_strong_completeness` via `bigAnd(Gamma)`. This is:
- **Sorry-free** (no new sorries, no new axioms)
- **Bounded effort** (~2–4 hours)
- **High confidence** (90%+)
- **Achieves the meta-theoretic goal** (sorry-free strong completeness from standard validity)

Files to create/modify: `FMP/SemanticCanonicalModel.lean` (or a new `FMP/StrongCompleteness.lean`), `Metalogic.lean`.

### Secondary: If BFMCS Completeness Is Required

The only unexplored avenue for a BFMCS construction satisfying the standard TruthLemma is depth-stratified temporal coherence. This would:
- Reformulate `bmcs_truth_lemma` using well-founded induction on formula depth
- Define `temporally_coherent_upto d` (coherence for formulas of depth < d)
- Show constant witness families satisfy `temporally_coherent_upto 0` (vacuously)
- Build the BFMCS inductively by depth

Estimated: 8–20 hours, 40–60% success probability.

### What NOT to Pursue

- **DovetailingChain forward_F/backward_P directly**: 12+ attempts failed; fundamental mathematical obstacle
- **Constant witness families with temporal coherence**: Provably impossible (counterexample: `{F(ψ), ¬ψ}`)
- **MCS-membership Box semantics**: Deliberately banned (Task 931); archived to Boneyard
- **Int-indexed BFMCS over constant families**: Same impossibility

---

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| metalogic-analyst (A) | Current metalogic state, sorry inventory, representation gaps | completed | high |
| construction-analyst (B) | Alternative constructions, structural analysis (sequential vs parallel), literature survey | completed | high |

### Conflicts Between Teammates

None. Both teammates independently reached the same conclusions.

---

## Evidence (Verified via lean_local_search)

| Lemma / Definition | Exists? | File | Sorry-Free? |
|--------------------|---------|------|-------------|
| `fully_saturated_bfmcs_exists_int` | Yes | TemporalCoherentConstruction.lean | NO (sorry at line 600) |
| `bmcs_truth_lemma` | Yes | TruthLemma.lean | YES |
| `canonical_forward_F` | Yes | CanonicalFrame.lean | YES |
| `canonical_backward_P` | Yes | CanonicalFrame.lean | YES |
| `canonicalMCSBFMCS` (via `canonicalMCSBFMCS_root_contains`) | Yes | CanonicalFMCS.lean | YES |
| `fmp_weak_completeness` | Yes | FMP/SemanticCanonicalModel.lean | YES |
| `bmcs_truth_lemma_mcs` | Yes | Boneyard only | BANNED |
| `buildDovetailingChainFamily_forward_F` | Yes (sorry) | DovetailingChain.lean | NO (line 1869) |
| `buildDovetailingChainFamily_backward_P` | Yes (sorry) | DovetailingChain.lean | NO (line 1881) |
| `GContent_subset_implies_HContent_reverse` | Yes | DovetailingChain.lean | YES |
| `saturated_modal_backward` | Yes | ModalSaturation.lean | YES |
| `forward_temporal_witness_seed_consistent` | Yes (as `ForwardTemporalWitnessSeed`) | DovetailingChain.lean | YES |

---

## File References

| File | Role | Sorry Count |
|------|------|-------------|
| TruthLemma.lean | Sorry-free truth lemma (all 6 cases) | 0 |
| TemporalCoherentConstruction.lean | `fully_saturated_bfmcs_exists_int` (the sorry) | 1 |
| DovetailingChain.lean | forward_F, backward_P sorries; forward_G, backward_H proven | 2 |
| CanonicalFrame.lean | canonical_forward_F/P (sorry-free) | 0 |
| CanonicalFMCS.lean | Sorry-free FMCS over CanonicalMCS (single family) | 0 |
| SemanticCanonicalModel.lean | FMP weak completeness (sorry-free) | 0 |
| Completeness.lean | BFMCS completeness chain (sorry-free given construction) | 0 |
| Representation.lean | Standard semantics bridge (sorry-free given construction) | 0 |
| ModalSaturation.lean | Modal saturation infrastructure (sorry-free) | 0 |
| BFMCS.lean | BFMCS structure definition | 0 |
| BFMCSTruth.lean | bmcs_truth_at (standard recursive truth definition) | 0 |
| Construction.lean | constantBFMCS, Lindenbaum infrastructure | 0 |
