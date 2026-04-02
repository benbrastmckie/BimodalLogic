# Research Report: Task #83 (Round 5)

**Task**: Close Restricted Coherence Sorries
**Date**: 2026-04-02
**Mode**: Team Research (2 teammates)
**Session**: sess_1775196120_r5math
**Focus**: First-principles rethinking via Task Semantics — what is the mathematically correct construction?

## Summary

Both teammates independently converge on a fundamental diagnosis: the step-by-step chain construction (`succ_chain_fam`) is categorically wrong for Task Semantics. The persistent failure of all chain-based approaches is not a technical gap but a category error from transplanting Kripke-style techniques into a richer semantic framework. The mathematically correct path forward is a **two-phase construction**: build the canonical frame (where forward_F is trivially true), then extract linear histories as paths through it. Alternatively, the language can be enriched with Until/Since operators to make the chain construction work via established methods.

## Key Findings

### 1. The Chain Construction Is Categorically Wrong for Task Semantics (Both teammates, HIGH)

Task Semantics evaluates truth at a model-history-time triple `(M, τ, t)`. The temporal operators G/H quantify over times along the SAME history. The box operator quantifies over ALL admissible histories at the current time.

The current approach tries to build a single history (Z-indexed chain of MCS) that internally resolves all F-obligations. After five rounds of research, every variant of this approach hits the same blocker: **Lindenbaum extensions are non-constructive and can add G(¬ψ), permanently killing F(ψ)**. This is not a fixable deficiency — it reflects the fundamental gap between:

- **g_content propagation** (universal, self-reinforcing via temp_4: G(φ) → G(G(φ)))
- **F-obligation resolution** (existential, no self-reinforcing mechanism)

The G/F asymmetry is the ∀/∃ asymmetry in the semantics. G-formulas create a "ratchet" — once true, true forever. F-formulas have no such ratchet. This is why g_content propagates across Succ steps but F-obligations can be killed.

### 2. Standard Temporal Logic Completeness Uses Two-Phase Construction (Teammate B, HIGH)

The standard completeness proof for basic tense logic Kt (Goldblatt 1992, Venema 1993, Burgess 1982) does NOT build a linear chain directly:

**Phase 1 — Canonical Frame**: Build the full canonical frame (worlds = all MCS, temporal accessibility = g_content inclusion). F-witnesses exist trivially — each F(φ) ∈ M gets its own witness MCS via Lindenbaum({φ} ∪ g_content(M)). This is exactly `canonical_forward_F` in the codebase.

**Phase 2 — Path Extraction**: Extract a linear history as a path through the canonical frame. Different techniques exist:
- Burgess (1982): step-by-step construction with constraints from already-placed points
- Xu (1988): constructive method for Since/Until logic
- de Jongh/Veltman/Verbrugge: "completeness by construction" with maximal-G successor selection

The codebase's approach of constructing the chain directly and then trying to prove F-resolution is working at the wrong level of abstraction. The canonical frame already solves the F-witness problem — the task is to extract linear structure from it.

### 3. Bundle-Level forward_F Is Already Sorry-Free (Teammate A, HIGH)

The gap is precisely between:
- **Bundle-level**: F(φ) ∈ fam.mcs(t) → ∃ fam' ∈ bundle, ∃ s ≥ t, φ ∈ fam'.mcs(s) — **PROVEN**
- **Family-level**: F(φ) ∈ fam.mcs(t) → ∃ s ≥ t, φ ∈ fam.mcs(s) — **SORRY** (same family witness)

The truth lemma evaluates along a single history, so it needs the same-family witness. This is the representation-theoretic content: can every family in the bundle be made temporally self-coherent?

### 4. Perpetual Deferral IS Semantically Consistent (Both teammates, HIGH)

An MCS can contain F(ψ) and ¬ψ at every time step without contradiction. F(ψ) = ¬G(¬ψ) says "ψ holds at some future time ≥ now", and ¬ψ says "ψ is false now". These are compatible: ψ is false now but should be true eventually. The chain construction has no mechanism to prevent the Lindenbaum extension from perpetually choosing ¬ψ at each step.

No proof-theoretic argument within a single chain can rule out perpetual deferral. The chain construction **MUST** be modified to force resolution.

### 5. The G-Wrapping Blocker Is Fundamental (Both teammates, HIGH)

Every attempted enrichment of the Lindenbaum seed faces the same obstacle. The `forward_temporal_witness_seed_consistent` proof works for a single target via G-wrapping:

> If {ψ} ∪ g_content(M) ⊢ ⊥, then g_content(M) ⊢ ¬ψ. G-wrap: G(¬ψ) ∈ M. But F(ψ) ∈ M. Contradiction.

Adding F-formulas or deferral disjunctions to the seed breaks G-wrapping because:
- F(χ) ∈ M does not imply G(F(χ)) ∈ M
- Deferral disjunctions (χ ∨ F(χ)) are in M but not G-wrappable
- Multiple targets {ψ₁, ψ₂, ...} cannot all be G-wrapped simultaneously

This is not a limitation of any specific approach — it is a fundamental limitation of the G-wrapping proof technique when applied to existential temporal formulas.

### 6. The Linearity Axiom Provides Structural Constraints But Not Resolution (Teammate B, HIGH)

The linearity axiom `F(a) ∧ F(b) → F(a ∧ b) ∨ F(a ∧ F(b)) ∨ F(F(a) ∧ b)` constrains how F-obligations interact. Combined with temp_4, it makes the blocking relation acyclic (proven in round 3). But it does NOT force F-resolution — it only constrains the ORDER of resolution when it occurs.

### 7. History Theory via Zorn Faces Circularity (Teammate A, MEDIUM)

Teammate A explored constructing "maximal consistent history theories" (specifying formula membership at all times simultaneously) via Zorn's lemma. The hope: if a maximal history theory has F(φ) at time t but no witness, we could extend it — violating maximality.

However, showing the extension is consistent requires the backward G direction (G(ψ) ∉ MCS → F(¬ψ) → witness), which itself requires forward_F. The circularity is the same one that blocks the chain construction, now appearing at a higher level of abstraction.

## Synthesis

### Conflicts Resolved

**Conflict 1: Primary recommended approach**

- Teammate A: Canonical frame path extraction (build canonical frame, extract linear paths)
- Teammate B: TargetedFMCS with enriched seed (Track A), or Until/Since enrichment (Track B)

**Resolution**: The canonical frame path extraction IS the two-phase construction from the literature that Teammate B identifies as the standard approach. Teammate A's recommendation and Teammate B's Finding 4 are the same approach from different angles. The enriched seed approach (Teammate B, Track A) faces the G-wrapping blocker identified by both teammates and is unlikely to work without new proof techniques.

**Conflict 2: Is language enrichment needed?**

- Teammate A: Not explored in depth
- Teammate B: Until/Since enrichment would resolve the blocker structurally (Track B)

**Resolution**: Language enrichment is a viable fallback if the canonical frame path extraction approach proves too complex. Adding Until/Since has well-understood completeness proofs (Burgess/Xu) and eliminates the F-witness problem by decomposing F into constructive steps. However, it requires substantial refactoring of the formula type, proof system, and soundness proofs.

### Gaps Identified

1. **Path extraction feasibility**: Neither teammate provides a complete proof that linear paths can be extracted from the canonical frame while maintaining all FMCS properties. The key open question: given an MCS M₀ in the canonical frame, can we construct a Z-indexed path σ : Z → MCS such that σ(0) = M₀, g_content(σ(n)) ⊆ σ(n+1) for all n, h_content(σ(n+1)) ⊆ σ(n) for all n, and forward_F/backward_P hold?

2. **Zorn circularity**: Teammate A's history theory approach faces circularity. Can this be broken? The finitary witness argument (Finding 5) suggests a potential direction but does not close.

3. **Iterative chain replacement**: Teammate A proposes replacing chain tails when perpetual deferral is detected. This avoids the seed consistency problem but may disturb other deferred obligations. Processing in topological order of the blocking relation may mitigate this, but no formal argument is given.

4. **Constrained successor + forced target**: Teammate A's Finding 10 proposes combining constrained_successor_from_seed (which handles f_step) with a forced target. The consistency argument does not close, but is the closest to a single-seed solution.

## Recommendations

### Tier 1: Canonical Frame Path Extraction (PRIMARY)

**Why**: Both teammates and the temporal logic literature converge on this. The canonical frame already has sorry-free forward_F (via `canonical_forward_F`). The task is to extract linear structure, not to prove a property that is fighting the construction.

**Approach**:
1. In the canonical frame (CanonicalFrame.lean), define a "canonical history through M₀" as a Z-indexed function σ : Z → MCS satisfying:
   - σ(0) = M₀
   - ∀n, g_content(σ(n)) ⊆ σ(n+1) (forward G-persistence = ExistsTask)
   - ∀n, h_content(σ(n+1)) ⊆ σ(n) (backward H-persistence)
   - ∀n ∀ψ, F(ψ) ∈ σ(n) → ∃m ≥ n, ψ ∈ σ(m) (forward_F)
   - ∀n ∀ψ, P(ψ) ∈ σ(n) → ∃m ≤ n, ψ ∈ σ(m) (backward_P)
2. Prove such histories exist by construction:
   - Use the canonical frame's forward witnesses (canonical_forward_F) at each step
   - Schedule resolution of deferralClosure formulas via round-robin
   - At resolution steps, use the canonical witness (which is guaranteed to exist and be consistent with g_content)
   - The key insight: instead of arbitrary Lindenbaum extension, USE the canonical_forward_F witness directly as the next chain element
3. Show this construction gives an FMCS satisfying all required properties
4. Wire into the parametric representation theorem

**Key technical question**: When we use `canonical_forward_F` to get a witness W for F(ψ) ∈ M (with ψ ∈ W and g_content(M) ⊆ W), does W also satisfy the Succ relation with M? The Succ relation requires both g_persistence AND f_step. The canonical_forward_F witness satisfies g_persistence by construction. Does it satisfy f_step?

**Estimated effort**: 12-18 hours (new infrastructure but mathematically clean)

### Tier 2: Iterative Chain Replacement (FALLBACK)

**Why**: Uses existing infrastructure more directly.

**Approach**:
1. Start with the existing constrained_successor chain (sorry-free, satisfies Succ)
2. For each F-obligation F(ψ_k) in deferralClosure(root) (finitely many), if perpetually deferred:
   - Replace the chain tail from step n_k onward with a targeted resolution chain
   - The targeted chain uses {ψ_k} ∪ g_content(current) as seed (proven consistent)
   - Process in topological order of blocking relation
3. Each replacement preserves prior resolutions (they occur before the replacement point)
4. By induction on the finite number of unresolved obligations: after finitely many replacements, all are resolved

**Risk**: Replacement may disturb other deferred obligations. Topological ordering mitigates but doesn't eliminate this.

**Estimated effort**: 8-12 hours

### Tier 3: Language Enrichment with Until/Since (CLEAN SOLUTION)

**Why**: Eliminates the F-witness problem structurally. Well-understood mathematics.

**Approach**:
1. Add Until (U) and Since (S) operators to Formula type
2. Define F(φ) := ⊤ U φ, P(φ) := ⊤ S φ
3. Add Until/Since axioms
4. Completeness follows Burgess/Xu methodology

**Cost**: Substantial refactoring of formula type, proof system, soundness, and all downstream code. But the completeness proof becomes standard.

**Estimated effort**: 20-30 hours (heavy refactoring)

### What NOT to Pursue

- **Direct proof of `succ_chain_restricted_forward_F` via the existing chain**: This is impossible. Perpetual deferral is semantically consistent and no chain-level argument can rule it out.
- **Enriched seed approaches**: The G-wrapping blocker is fundamental. Five rounds of research have confirmed this from multiple angles.
- **FMP approach**: Explicitly excluded by the user. Not relevant to the representation-theoretic aim.

## Teammate Contributions

| Teammate | Angle | Status | Key Contribution |
|----------|-------|--------|-----------------|
| A | First-principles via Task Semantics | completed | Canonical frame path extraction, history theory Zorn analysis, iterative chain replacement |
| B | Alternative constructions & blocker diagnosis | completed | Literature survey (Kt two-phase), G/F asymmetry diagnosis, Until/Since analysis, enriched seed impossibility |

## References

- Goldblatt (1992): Logics of Time and Computation — canonical frame approach for tense logic
- Venema (1993): Derivation rules as anti-axioms in modal logic — canonical model construction
- Burgess (1982): Axioms for tense logic — completeness with Since/Until
- Xu (1988): Axioms of tense logic with Since and Until — constructive completeness
- de Jongh/Veltman/Verbrugge: "Completeness by construction" for tense logic over Z
- Thomason (1984): Combinations of tense and modality — bundled completeness
- Prior research reports: 01 through 04 in specs/083_close_restricted_coherence_sorries/reports/
