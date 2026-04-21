# Research Report: Task #109

**Task**: Close chain construction sorries for sorry-free completeness
**Date**: 2026-04-21
**Mode**: Team Research (4 teammates)
**Session**: sess_1776784827_35a901

## Summary

Four teammates conducted rigorous first-principles research into the 3 remaining sorry sites blocking sorry-free `bx_completeness`. The unanimous finding across all 4 teammates: **the Lindenbaum-based chain construction under irreflexive semantics fundamentally cannot satisfy any of the 3 coherence conditions.** The core obstruction is that `F(φ) → G(F(φ))` is not derivable in BX (verified against all 35 axioms), so F-obligations are invisible to `g_content` propagation and can be silently destroyed by `Classical.choice` at any non-resolving step. Additionally, Teammates C and D discovered that sorry #2 (backward Until) has a **deeper foundation problem**: `psi_imp_until` (ψ → φ U ψ) is itself sorry'd in TemporalDerived.lean because it is semantically invalid under irreflexive Until.

## Key Findings

### 1. The Core Obstruction: F(φ) → G(F(φ)) Is Not Derivable (All Teammates, HIGH confidence)

The schedule + monotonicity contrapositive strategy from Report 07 fails at a precise point:

- **What works**: `schedule_surjective_above` gives m ≥ n with schedule(m) = φ. If F(φ) ∈ chain(m), then `fwd_succ_resolves` gives φ ∈ chain(m+1). Done.
- **What fails**: If F(φ) drops before the scheduled step m, the contrapositive of `fwd_chain_F_not_return` does NOT give φ at the drop point. F(φ) can be killed because `set_lindenbaum` freely adds G(¬φ) at non-resolving steps — this is consistent with the seed `{ψ} ∪ g_content(M)` because F(φ) ∉ g_content(M) when G(F(φ)) ∉ M.

The precise chain of reasoning:
1. `g_content(M) = {α | G(α) ∈ M}` — F(φ) ∈ g_content(M) iff G(F(φ)) ∈ M
2. F(φ) → G(F(φ)) would mean "if φ eventually holds, then φ always-eventually holds" — the "infinitely often" property
3. This is NOT sound on ℤ: take φ = atom at time 0 only; F(φ) holds at t = -1 but G(F(φ)) fails
4. No BX axiom (checked all 35) derives this; BX5 is about Until, temp_4 gives G(φ)→G(G(φ)) not G(F(φ)) from F(φ), BX12 converts F to Until but Until is equally invisible to g_content

**Consequence**: At any non-resolving step (schedule(n) ≠ φ), the Lindenbaum extension can add G(¬φ) to the successor MCS, permanently killing F(φ) without φ ever appearing. The `fwd_chain_F_not_return` theorem (already proved) confirms: once F(φ) is absent, G(¬φ) propagates via g_content forever.

### 2. The Enriched Seed Approach Fails (Teammates A, C, HIGH confidence)

Two variants analyzed:

**Full f_content enrichment**: `{ψ} ∪ g_content(M) ∪ f_content(M)` where f_content = {α | F(α) ∈ M}. This can be **inconsistent**: if F(φ) ∈ M and F(¬φ) ∈ M simultaneously (valid in any MCS where neither G(φ) nor G(¬φ) holds), then both φ and ¬φ are in f_content.

**Single F-obligation enrichment**: `{F(ψ), ψ} ∪ g_content(M)`. The consistency proof breaks at a specific step: from a hypothetical inconsistency L' ∪ {F(ψ)} ⊢ ⊥ with L' ⊆ g_content(M), the generalized temporal K argument gives G(G(¬ψ)) ∈ M, but reducing G(G(¬ψ)) → G(¬ψ) requires the temporal T-axiom G(φ) → φ — which was removed under irreflexive semantics.

### 3. psi_imp_until Is Sorry'd — Backward Until Foundation Problem (Teammates C, D, VERY HIGH confidence)

**Critical discovery**: `backward_until_reflexive` in UntilSinceCoherence.lean depends on `psi_imp_until` from TemporalDerived.lean, which is **marked sorry** with the comment "Under irreflexive semantics, ψ → (φ U ψ) is NOT valid."

Dependency chain:
```
bx_bfmcs_restricted_buc
  → backward_until_from_step (base case)
    → backward_until_reflexive
      → psi_imp_until [SORRY — semantically invalid under irreflexive Until]
```

Under irreflexive Until, the witness must be at a **strictly future** time, so ψ at the current time does not witness (φ U ψ). This is not a proof gap — it is a semantic fact. The entire backward Until induction infrastructure needs redesign for irreflexive semantics.

Additionally, no BX axiom introduces (φ U ψ) from F(ψ) alone under irreflexive semantics. BX12 gives F(ψ) → ⊤ U ψ, but ⊤ U ψ → φ U ψ requires strengthening the guard from ⊤ to φ, which BX2 (left_mono_until) cannot do (it weakens, not strengthens).

### 4. Sorry #3 Depends on Sorry #1 + Guard Persistence (All Teammates, HIGH confidence)

For `restricted_fuc`, given (φ U ψ) ∈ fam.mcs(t):
1. BX10 gives F(ψ) ∈ fam.mcs(t)
2. Sorry #1 (if closed) would give ψ ∈ fam.mcs(s) for some s > t
3. The guard condition (φ ∈ fam.mcs(r) for all r ∈ [t,s)) is NOT guaranteed

BX5 gives (φ U ψ) → ((φ ∧ (φ U ψ)) U ψ), and BX9 gives the current-time disjunction. But propagating (φ U ψ) forward through the chain requires G(φ U ψ) ∈ chain(t), which is not derivable from (φ U ψ) alone. The guard persistence faces the same g_content opacity: Until formulas are not G-formulas and don't propagate through the chain.

### 5. All Three Sorries Share One Root Cause (All Teammates, HIGH confidence)

| Sorry | What's Needed | Why It Fails |
|-------|---------------|--------------|
| #1 (restricted_tc) | F(φ) persists to scheduled step | G(F(φ)) not derivable from F(φ); Lindenbaum can kill F(φ) |
| #2 (restricted_buc) | (φ U ψ) introduced from witnesses | psi_imp_until sorry'd; no step transfer for Until |
| #3 (restricted_fuc) | (φ U ψ) guard persists through chain | G(φ U ψ) not derivable from (φ U ψ); same opacity |

The common denominator: **g_content propagation only preserves G-formulas**, and none of F(φ), (φ U ψ), or (φ S ψ) are G-formulas. The Lindenbaum extension at each step is unconstrained beyond the g_content seed, allowing `Classical.choice` to destroy any non-G-formula.

## Synthesis

### Conflicts Resolved

**Conflict 1: Is the one-step preservation lemma provable?**
- Teammate B initially explored `fwd_succ_F_or_resolves` (φ ∈ result ∨ F(φ) ∈ result)
- Teammate A showed rigorously that this is NOT provable: G(¬φ) is consistent with the seed when G(G(¬φ)) ∉ M
- **Resolution**: The one-step preservation lemma is not provable. All 4 teammates converge on this conclusion.

**Conflict 2: Is sorry #2 fundamentally different from #1 and #3?**
- Teammates A, B focused on the shared g_content opacity
- Teammates C, D found the additional psi_imp_until foundation problem
- **Resolution**: Sorry #2 has a DOUBLE obstruction — the shared g_content opacity PLUS the sorry'd base case for backward Until under irreflexive semantics. It is strictly harder than #1 and #3.

**Conflict 3: What is the correct path forward?**
- Teammate A recommends reflexive semantics restoration or GHR-style completeness
- Teammate B recommends marking #2 as [BLOCKED], focusing on #1 and #3
- Teammate C recommends decomposing into 3 sub-tasks
- Teammate D recommends the semantic completeness approach (full MCS space)
- **Resolution**: All agree the current architecture cannot close the sorries. The divergence is on which alternative to pursue. The two viable paths are: (A) reflexive semantics restoration, or (B) semantic completeness with the full MCS space. Path A is simpler but changes the logic; Path B is principled but expensive.

### Gaps Identified

1. **Has anyone verified whether `bx_forward_witness` (Frame.lean) provides the semantic F-resolution needed?** If it does, the semantic completeness approach (Path B) may have existing infrastructure.

2. **Can `restricted_tc` be proved for the CROSS-REGION case?** Even if forward F-resolution works within fwd_chain, the cross-region case (F in backward region, P in forward region) needs additional analysis.

3. **Is there an axiom addition that is minimal and sound?** A new axiom like `F(φ) ∧ G(φ → F(φ)) → G(F(φ))` might close the gap without changing the semantics fundamentally. This needs soundness verification.

4. **Does the finiteness of deferralClosure(root) help?** The restricted coherence conditions only quantify over formulas in deferralClosure(root), which is finite. Could a dovetailed construction that resolves all obligations in each omega-block work?

### Recommendations

**Immediate (this task)**:
- Mark task 109 as [BLOCKED] with full documentation of the structural impossibility
- Update the sorry comments in RootScopedChain.lean to accurately describe the obstruction (the current comments still reference outdated strategies)

**Design Decision Required** (new task):
Choose between two paths:

**Path A: Reflexive Semantics Restoration** (Teammate A's recommendation)
- Add back temporal T-axiom G(φ) → φ, making G reflexive (≤ instead of <)
- This restores g_content_subset_self, enables F(φ) → G(F(φ)) derivation via G-closure
- Makes the schedule-based chain proof work directly for all 3 sorries
- Aligns with Burgess (1984) who uses reflexive G
- **Cost**: Changes the semantics, requires re-proving soundness, updating frame conditions
- **Effort**: ~10-15 hours

**Path B: Semantic Completeness (Full MCS Space)** (Teammate D's recommendation)
- Build canonical model using ALL MCS as time points, ordered by g_content inclusion
- F-resolution follows from `bx_forward_witness` (already sorry-free in Frame.lean)
- Until coherence from BX axioms applied at MCS level directly
- Avoids chain construction entirely
- Aligns with Goldblatt (1992), GHR (1994)
- **Cost**: Re-engineers the entire BFMCS/canonical model architecture
- **Effort**: ~30-50 hours

**Path C: Dovetailed Finite-Obligation Chain** (Gap #4, speculative)
- Exploit finiteness of deferralClosure(root) to build a chain that resolves ALL obligations in each omega-block
- At each block of |deferralClosure(root)| steps, explicitly target every formula
- Would need a new `fwd_succ_enriched` that includes all current F-obligations as targets
- **Problem**: Enriched seed consistency is unproven (Finding #2)
- **Effort**: Unknown, may hit the same wall

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|-----------------|
| A | Primary chain analysis | completed | high | Exhaustive proof that enriched seeds fail; concrete counterexample for irreflexive wall; BX axiom audit |
| B | Literature + alternatives | completed | medium-low | Until-introduction axiom analysis; one-step preservation attempt (showed it fails); BX12 path analysis |
| C | Critic / gap analysis | completed | very high | **psi_imp_until sorry'd** (backward Until foundation problem); verified g_content definition; enriched seed inconsistency via F(φ)∧F(¬φ) |
| D | Strategic horizons | completed | high | Confirmed Case B of schedule+monotonicity is wrong; semantic completeness path analysis; ROADMAP dead-end catalog |

## References

### Codebase
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` — fwd_succ, fwd_chain, schedule (sorry-free)
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` — bx_bfmcs, 3 sorry sites
- `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` — forward_temporal_witness_seed_consistent
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` — coherence definitions
- `Theories/Bimodal/Metalogic/Bundle/UntilSinceCoherence.lean` — backward_until_from_step, backward_until_reflexive
- `Theories/Bimodal/Theorems/TemporalDerived.lean` — psi_imp_until (SORRY)
- `Theories/Bimodal/ProofSystem/Axioms.lean` — all 35 BX axioms
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` — g_content definition, bx_forward_witness

### Literature
- Goldblatt (1992) "Logics of Time and Computation" — g_content ordering, schedule-based canonical model
- GHR (1994, Ch. 6) — Quasimodel unraveling, defect-count descent
- Reynolds (1996) — Quasimodel approach for first-order temporal logic
- Burgess (1982/1984) — Basic tense logic, reflexive G completeness on linear orders
- Xu (1988) — Decidability of Kt4.3, simplified Until completeness

### Prior Research
- Task 93 (51 rounds): Irreflexive semantics transition, forward_F obstruction discovery
- Task 109 reports 01-07: All chain-based approaches exhaustively explored
- ROADMAP dead ends #3, #24, #25, #30, #36: Document specific failure modes
