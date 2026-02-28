# Research Report: Prove canonical_task_rel_compositionality Cross-Sign Cases

- **Task**: 946 - Prove canonical_task_rel_compositionality cross-sign cases
- **Started**: 2026-02-27T12:00:00Z
- **Completed**: 2026-02-27T12:45:00Z
- **Effort**: 45 minutes
- **Dependencies**: None
- **Sources/Inputs**:
  - `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` (main file with 4 sorries)
  - `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` (CanonicalR, transitivity)
  - `Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean` (GContent, HContent defs)
  - `Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean` (FMCS structure)
  - `Theories/Bimodal/ProofSystem/Axioms.lean` (TM axiom schemata)
  - `Theories/Bimodal/Metalogic/Core/MCSProperties.lean` (temp_4_past, set_mcs_all_future_all_future)
  - `Theories/Bimodal/Boneyard/Metalogic_v5/Representation/TaskRelation.lean` (prior attempt)
  - `Theories/Bimodal/Semantics/TaskFrame.lean` (compositionality requirement)
  - `Theories/Bimodal/Semantics/WorldHistory.lean` (respects_task constraint)
- **Artifacts**:
  - `specs/946_canonical_task_rel_compositionality/reports/research-001.md` (this report)
- **Standards**: status-markers.md, artifact-management.md, tasks.md, report-format.md

## Project Context

- **Upstream Dependencies**: `canonicalR_transitive`, `canonicalR_past_reflexive`, `temp_4_past`, `set_mcs_all_future_all_future`, `set_mcs_all_past_all_past`, `set_mcs_implication_property`, `theorem_in_mcs`
- **Downstream Dependents**: `CanonicalTaskFrame` (requires compositionality), `to_history` (requires valid TaskFrame), `canonical_truth_lemma` (requires valid TaskFrame, though truth_at does not reference task_rel)
- **Alternative Paths**: The v5 Boneyard attempt (`TaskRelation.lean`) has identical sorries. The solution proposed below (strengthened definition) is novel.
- **Potential Extensions**: If successful, this pattern generalizes to any canonical task relation for tense logics with reflexive temporal operators.

## Executive Summary

- The 4 sorries in `canonical_task_rel_compositionality` occur at cross-sign duration cases (lines 155, 166, 203, 209 of `CanonicalConstruction.lean`).
- **Root cause identified**: The current `canonical_task_rel` definition is TOO WEAK for cross-sign compositionality. It conditions GContent/HContent inclusion on the sign of d, making the conditions vacuously true in the "wrong" direction.
- **Counter-model exists**: With the current definition, three MCSes M, N, V can be constructed where GContent(M) subset N and HContent(V) subset N, yet GContent(M) is NOT a subset of V. The current definition is not compositional for cross-sign cases.
- **Solution**: Strengthen the definition to require BOTH conditions unconditionally (remove sign-conditioning). This makes compositionality provable via standard transitivity using temp_4 and temp_4_past.
- The strengthened definition is still satisfied by `to_history` (FMCS families provide both forward_G and backward_H for all s <= t), and nullity still holds via T-axioms.
- All 4 sorries can be eliminated with this approach, and the same-sign proofs become uniform with the cross-sign proofs.

## Context & Scope

### Current Definition (CanonicalConstruction.lean:77-79)

```lean
def canonical_task_rel (M : CanonicalWorldState) (d : Int) (N : CanonicalWorldState) : Prop :=
  (d >= 0 -> GContent M.val subset N.val) /\
  (d <= 0 -> HContent N.val subset M.val)
```

For d > 0: only GContent(M) subset N is required; HContent condition is vacuous.
For d < 0: only HContent(N) subset M is required; GContent condition is vacuous.

### The 4 Sorry Locations

| # | Line | Sign conditions | Hypotheses | Goal |
|---|------|----------------|------------|------|
| 1 | 155 | x >= 0, y < 0, x+y >= 0 | GContent(M) subset N, HContent(V) subset N | GContent(M) subset V |
| 2 | 166 | x < 0, y >= 0, x+y >= 0 | GContent(N) subset V, HContent(N) subset M | GContent(M) subset V |
| 3 | 203 | x > 0, y <= 0, x+y <= 0 | HContent(V) subset N, GContent(M) subset N (from x > 0) | HContent(V) subset M |
| 4 | 209 | x <= 0, y > 0, x+y <= 0 | HContent(N) subset M, GContent(N) subset V (from y > 0) | HContent(V) subset M |

### Goal States (from lean_goal)

**Sorry 1 (line 155)**:
```
hMN_R : CanonicalR M.val N.val         -- GContent(M) subset N
hNV_bwd_R : HContent V.val subset N.val -- HContent(V) subset N
goal: GContent M.val subset V.val
```

**Sorry 2 (line 166)**:
```
hNV_R : CanonicalR N.val V.val          -- GContent(N) subset V
hMN_bwd_R : HContent N.val subset M.val -- HContent(N) subset M
goal: GContent M.val subset V.val
```

**Sorry 3 (line 203)**:
```
hNV_bwd_R : HContent V.val subset N.val -- HContent(V) subset N
hx : 0 < x                              -- x > 0 (so GContent(M) subset N available from hMN_fwd)
goal: HContent V.val subset M.val
```

**Sorry 4 (line 209)**:
```
hMN_bwd_R : HContent N.val subset M.val -- HContent(N) subset M
hy : 0 < y                               -- y > 0 (so GContent(N) subset V available from hNV_fwd)
goal: HContent V.val subset M.val
```

## Findings

### Finding 1: Cross-Sign Compositionality is NOT Provable with Current Definition

The hypotheses in cross-sign cases provide information about DIFFERENT content types at the intermediate node N. For example in Sorry 1: GContent(M) subset N (forward content) and HContent(V) subset N (backward content). The goal GContent(M) subset V requires connecting M to V, but the only connection point is N, which does not provide the necessary bridge.

**Counter-model for Sorry 1**: Consider propositional variable p. Construct three MCSes:
- M: G(p) in M, p in M (an MCS where p always holds in the future)
- N: G(p) in N, p in N (consistent with being a future of M)
- V: NOT(p) in V, P(NOT(p)) in V (an MCS where p fails)

Verification that hypotheses hold:
- GContent(M) subset N: G(phi) in M implies phi in N. For phi=p, G(p) in M and p in N. For general phi, this constrains what must be in N. Constructible via Lindenbaum.
- HContent(V) subset N: H(psi) in V implies psi in N. H(p) cannot be in V (since H(p)->p by T-axiom, contradicting NOT(p) in V). So this constraint is satisfiable.
- Goal fails: p in GContent(M) (since G(p) in M) but p NOT in V (since NOT(p) in V).

No TM axiom (including temp_a, temp_l, MF, TF) provides a derivation from these hypotheses alone to force p into V.

### Finding 2: The v5 Boneyard Attempt Has Identical Sorries

`Theories/Bimodal/Boneyard/Metalogic_v5/Representation/TaskRelation.lean` defines a similar canonical_task_rel with time arithmetic and has 4 sorries in the compositionality proof at lines 151, 164, 167, 174. This confirms the cross-sign issue is a recurring structural problem, not a missing-lemma issue.

### Finding 3: Strengthened Definition Resolves All 4 Sorries

**Proposed definition**:
```lean
def canonical_task_rel (M : CanonicalWorldState) (d : Int) (N : CanonicalWorldState) : Prop :=
  GContent M.val subset N.val /\ HContent N.val subset M.val
```

This removes all sign-conditioning. The relation now requires:
1. All G-formulas of M are satisfied at N (forward propagation)
2. All H-formulas of N are satisfied at M (backward propagation)

**Why this works for compositionality**: Given hMN: (GContent(M) subset N, HContent(N) subset M) and hNV: (GContent(N) subset V, HContent(V) subset N), prove (GContent(M) subset V, HContent(V) subset M):

- **GContent(M) subset V**: For phi in GContent(M), we have G(phi) in M. By temp_4 (G(phi) -> G(G(phi))), G(G(phi)) in M. So G(phi) in GContent(M) subset N, giving G(phi) in N. Then phi in GContent(N) subset V. This is exactly `canonicalR_transitive` applied twice.

- **HContent(V) subset M**: For phi in HContent(V), we have H(phi) in V. By temp_4_past (H(phi) -> H(H(phi))), H(H(phi)) in V. So H(phi) in HContent(V) subset N, giving H(phi) in N. Then phi in HContent(N) subset M. This is the symmetric version of the transitivity argument.

**Both chains use already-proven lemmas**: `canonicalR_transitive` (from CanonicalFrame.lean) and its past analog (provable symmetrically using temp_4_past).

### Finding 4: Strengthened Definition is Compatible with All Existing Code

**Nullity (d=0)**: Requires GContent(M) subset M and HContent(M) subset M. Both hold via T-axioms (canonicalR_reflexive and canonicalR_past_reflexive). No change needed.

**to_history construction (CanonicalConstruction.lean:245-264)**: respects_task requires canonical_task_rel for s <= t (duration t-s >= 0).
- GContent(mcs s) subset mcs t: by FMCS.forward_G (s <= t). Already proved.
- HContent(mcs t) subset mcs s: by FMCS.backward_H (s <= t). The current proof handles backward via the s=t shortcut (since only s <= t pairs arise). With the strengthened definition, we need this for ALL s <= t. FMCS.backward_H provides exactly this: H(phi) in mcs(t) implies phi in mcs(s) for s <= t.

**canonical_truth_lemma**: Does not reference canonical_task_rel at all. Unaffected.

### Finding 5: Same-Sign Proofs Also Simplify

With the strengthened definition, the existing same-sign forward case (x >= 0, y >= 0) would no longer need the `by_cases` on signs within the proof. The compositionality proof becomes a single uniform argument for ALL cases:

```lean
theorem canonical_task_rel_compositionality
    (M N V : CanonicalWorldState) (x y : Int)
    (hMN : canonical_task_rel M x N) (hNV : canonical_task_rel N y V) :
    canonical_task_rel M (x + y) V := by
  obtain (hMN_fwd, hMN_bwd) := hMN
  obtain (hNV_fwd, hNV_bwd) := hNV
  constructor
  . -- GContent(M) subset V via transitivity
    exact canonicalR_transitive M.val N.val V.val M.property hMN_fwd hNV_fwd
  . -- HContent(V) subset M via past transitivity
    -- Need: canonicalR_past_transitive (or inline argument using temp_4_past)
    intro phi h_H_phi
    have h_mcs_V := V.property
    have h_H4 := temp_4_past phi  -- H phi -> HH phi
    have h_HH_in_V := set_mcs_implication_property h_mcs_V (theorem_in_mcs h_mcs_V h_H4) h_H_phi
    have h_Hphi_in_N := hNV_bwd h_HH_in_V  -- H(phi) in HContent(V) subset N
    exact hMN_bwd h_Hphi_in_N               -- phi in HContent(N) subset M
```

### Finding 6: Helper Lemma canonicalR_past_transitive Should Be Added

The forward transitivity `canonicalR_transitive` already exists. The backward analog is needed:

```lean
theorem canonicalR_past_transitive (M M' M'' : Set Formula)
    (h_mcs_M'' : SetMaximalConsistent M'')
    (h_R1 : HContent M'.val subset M.val)
    (h_R2 : HContent M''.val subset M'.val) :
    HContent M''.val subset M.val
```

This is the exact dual of `canonicalR_transitive` using `temp_4_past` instead of `temp_4`. It should be added to `CanonicalFrame.lean`.

## Sorry Characterization

### Current State
- 4 sorries in `CanonicalConstruction.lean` (lines 155, 166, 203, 209)
- All are cross-sign cases in `canonical_task_rel_compositionality`

### Transitive Impact
- `CanonicalTaskFrame` inherits sorry status (uses compositionality)
- `to_history` depends on CanonicalTaskFrame
- `CanonicalOmega` depends on to_history
- `canonical_truth_lemma` depends on CanonicalOmega
- All downstream theorems using the canonical truth lemma are affected

### Remediation Path
All 4 sorries are eliminated by strengthening the `canonical_task_rel` definition to remove sign-conditioning. This is a local change (affects only the definition, nullity proof, compositionality proof, and to_history proof). No new axioms or complex lemmas are required -- only temp_4_past transitivity.

### Publication Status
These sorries block publication. Remediation priority: high. Estimated implementation effort: 1-2 hours.

## Decisions

- **The current definition is mathematically incorrect** (too weak for compositionality). This is not a proof difficulty but a definition design error.
- The fix is to strengthen the definition, not to find clever proofs for the current definition.

## Recommendations

### Recommendation 1: Strengthen canonical_task_rel Definition (Priority: HIGH)

Replace:
```lean
def canonical_task_rel (M : CanonicalWorldState) (d : Int) (N : CanonicalWorldState) : Prop :=
  (d >= 0 -> GContent M.val subset N.val) /\
  (d <= 0 -> HContent N.val subset M.val)
```

With:
```lean
def canonical_task_rel (M : CanonicalWorldState) (d : Int) (N : CanonicalWorldState) : Prop :=
  GContent M.val subset N.val /\ HContent N.val subset M.val
```

### Recommendation 2: Add canonicalR_past_transitive Lemma

Add to `CanonicalFrame.lean`:
```lean
theorem canonicalR_past_transitive (M M' M'' : Set Formula)
    (h_mcs : SetMaximalConsistent M'')
    (h_R1 : CanonicalR_past M M') (h_R2 : CanonicalR_past M' M'') :
    CanonicalR_past M M''
```

Where `CanonicalR_past M M'` = `HContent M subset M'`. Wait -- note that the composition goes: HContent(M'') subset M' and HContent(M') subset M implies HContent(M'') subset M. The correct signature depends on the direction convention.

Actually, looking at the goal: we need HContent(V) subset M from HContent(V) subset N and HContent(N) subset M. This is NOT the same as CanonicalR_past transitivity (which is HContent(M) subset M' and HContent(M') subset M'' implies HContent(M) subset M''). The HContent chain goes in the REVERSE direction.

The correct helper:
```lean
theorem HContent_chain_transitive (M N V : Set Formula)
    (h_mcs_V : SetMaximalConsistent V)
    (hNV : HContent V subset N) (hMN : HContent N subset M) :
    HContent V subset M
```

Proof: phi in HContent(V) means H(phi) in V. By temp_4_past, H(H(phi)) in V, so H(phi) in HContent(V) subset N, so H(phi) in N, so phi in HContent(N) subset M.

### Recommendation 3: Rewrite Compositionality Proof

Replace the entire case-analysis proof with the uniform two-line argument using canonicalR_transitive and HContent_chain_transitive.

### Recommendation 4: Update to_history backward case

The current backward case in to_history uses `le_antisymm` to force s = t. With the strengthened definition, this should instead use `fam.backward_H` directly for the general s <= t case.

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| Strengthened definition breaks other code | Low | grep confirms canonical_task_rel only used in CanonicalConstruction.lean and its immediate consumers |
| canonicalR_past_transitive / HContent chain proof fails | Very Low | The argument is symmetric to canonicalR_transitive which is already proven |
| to_history backward case with general s <= t fails | Very Low | FMCS.backward_H provides exactly this property |

## Appendix

### Key Axioms Used

| Axiom | Lean Name | Statement | Role |
|-------|-----------|-----------|------|
| Temporal 4 | `temp_4` | G(phi) -> G(G(phi)) | Enables GContent transitivity |
| Temporal 4 Past | `temp_4_past` | H(phi) -> H(H(phi)) | Enables HContent transitivity |
| Temporal T Future | `temp_t_future` | G(phi) -> phi | Nullity (reflexivity) |
| Temporal T Past | `temp_t_past` | H(phi) -> phi | Nullity (past reflexivity) |

### Key Existing Lemmas

| Lemma | File | Type |
|-------|------|------|
| `canonicalR_transitive` | CanonicalFrame.lean | GContent chain transitivity |
| `canonicalR_reflexive` | CanonicalFrame.lean | GContent self-inclusion for MCS |
| `canonicalR_past_reflexive` | CanonicalFrame.lean | HContent self-inclusion for MCS |
| `set_mcs_all_future_all_future` | MCSProperties.lean | G(phi) in S => G(G(phi)) in S |
| `set_mcs_all_past_all_past` | MCSProperties.lean | H(phi) in S => H(H(phi)) in S |
| `set_mcs_implication_property` | MCSProperties.lean | MCS modus ponens |
| `theorem_in_mcs` | MaximalConsistent.lean | Theorems are in every MCS |

### File Paths

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/ProofSystem/Axioms.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Core/MCSProperties.lean`
