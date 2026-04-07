# Research Report: Task #83 — Completeness Proof Strategies (Round 30)

**Task**: Close Restricted Coherence Sorries
**Date**: 2026-04-07
**Mode**: Team Research (4 teammates, Opus model)
**Session**: sess_1775592661_d0e23e

## Summary

Four teammates investigated three representation-based completeness strategies (quasimodel, F-nesting depth induction, tuple-based construction) plus critical analysis. **The most important finding is not about any specific approach but about a foundational issue: `F_until_equiv` is unsound under the current mixed semantics**, with a confirmed sorry in Soundness.lean:770. This reframes the entire forward_F problem.

## Critical Finding: F_until_equiv Unsoundness (Teammate D)

**Confirmed by codebase inspection.** The axiom `F(ψ) → ⊤ U ψ` (`F_until_equiv`) has a sorry in `Soundness.lean:770` with the comment: *"SEMANTIC GAP: Under reflexive semantics, F(ψ) includes present but Until requires strict future."*

**The issue**: Under the current mixed semantics:
- `F(ψ)` at time t means ∃ s ≥ t, ψ(s) — **includes s = t** (reflexive G/H)
- `⊤ U ψ` at time t means ∃ s > t, ψ(s) — **strictly future** (strict Until)

When the only witness for F(ψ) is the present time (s = t), there is no strictly future witness for Until. **The axiom is not valid under mixed semantics.**

**Cascading impact**:
1. `F_to_until_in_chain` (FiniteDeferral.lean) depends on this axiom — entire finite deferral approach rests on unsound foundation
2. `P_since_equiv` has the same sorry (line 786)
3. The forward_F problem may be a *symptom* of the deeper semantics mismatch, not an independent proof gap

**Recommendation**: Resolve F_until_equiv BEFORE pursuing any approach that converts between F and Until.

## Key Findings by Approach

### 1. Quasimodel Approach (GHR 1994) — Teammate A

**Probability: 30-40%** (Teammate A: 35-45%, Teammate D: 20-30%)

**Correction to Report 24**: Report 24 incorrectly stated TM uses "strict temporal semantics." G/H are actually reflexive (Truth.lean:125-126 uses `t ≤ s`). This makes GHR 1994 *closer* to applicable than Report 24 concluded.

**Detailed analysis of the eliminative fixpoint (Appendix A.4-A.6)**:
- Teammate A worked through the GHR eliminative construction in extensive detail
- The argument initially appeared to break the circularity: G(neg(ψ)) follows from maximality + the eliminative property (types with unfulfillable F-obligations are eliminated)
- **But the deterministic type graph (x_content_restricted) is too constrained**: With only one successor per type, the reachable set is just the deterministic chain — proving F-witnesses exist in this chain IS the forward_F problem
- Enriching the graph with non-deterministic edges reintroduces the Until-through-detours problem from Report 24 Section 1.5

**Alternative proposed**: Direct forward_F via saturation on the existing deterministic chain (~400-600 lines). Use the cycle's restricted theories + a local G-saturation argument. Still faces the same gap.

### 2. F-Nesting Depth Induction — Teammate B

**Probability: 5-10%** — **Conclusively non-viable.**

Teammate B rigorously proved this approach cannot work:

- `Fd(neg(neg(ψ))) = Fd(ψ)` — the measure is **constant** along the dependency chain
- The circularity `forward_F(ψ) → backward_G(neg(ψ)) → forward_F(neg(neg(ψ)))` is a **fixed point**, not a descent
- No natural measure decreases through this chain because the chain goes through logical negation, which preserves ALL sensible measures
- `complexity` is the only measure that changes — but it **increases** (neg(neg(ψ)) has sizeof + 4)
- Quotienting by logical equivalence doesn't help: no natural well-ordering on Boolean algebra makes complement strictly smaller

**Key insight (Section 6.1)**: F-nesting depth COULD work as a termination measure in architectures that avoid backward_G (like quasimodel), because witnessing F(ψ) gives ψ which has strictly smaller Until-nesting depth. The measure fails specifically because of the deterministic chain architecture.

### 3. Tuple-Based Construction (User's Proposal) — Teammate C

**Probability: 35-45%** (Teammate C: MEDIUM, Teammate D: 25-35%)

**Connection to quasimodel**: Teammate C identified the user's construction as essentially a reinvention of the quasimodel approach with different terminology:
- Tuple = type/atom
- Task = eventuality pointer
- Timeline = run
- Duration resolution = unraveling

**Novel element**: The explicit constraint-satisfaction framing for duration assignment via difference constraints over ℤ.

**Duration resolution IS always satisfiable** (Teammate C's main positive result):
- The F-constraint graph is a DAG: each F-task goes from a formula to a strict subformula (lower complexity)
- The system of difference constraints (t_j - t_i ≥ 1 for F, t_i - t_j ≥ 1 for P) has no positive-weight cycles
- Bellman-Ford confirms satisfiability

**Conflict with Teammate D**: Teammate D argues duration resolution is "forward_F in disguise" — the constraint system is satisfiable for individual constraints, but the universal G/H propagation constraints (chi must hold at ALL future times) are NOT difference constraints. Unrolling from finite tuples to infinite ℤ-indexed model IS the completeness proof.

**Resolution**: Both are partially right. The tuple/constraint framing correctly handles the EXISTENTIAL temporal operators (F, P, witnesses). The gap is in the UNIVERSAL operators (G, H) — converting meta-level "phi at all future times" to object-level "G(phi) in the tuple" is still the fundamental obstacle. However, the witness-first philosophy genuinely addresses the push/pull mismatch.

**Gaps identified**:
1. Until/Since handling underspecified (intermediate-position constraints, not just endpoints)
2. G(F(ψ)) propagation creates infinite task instances (finitely many TYPES but infinitely many INSTANCES)
3. Truth lemma remains the hardest part (~500 lines)
4. Process termination guaranteed by finiteness of subformula closure

### 4. Root Cause Confirmation — All Teammates

All four teammates independently confirmed the root cause:

> **The deterministic chain is PUSH-based (x_content determines successor), but F-resolution is PULL-based (obligation needs future witness). The push doesn't guarantee the pull.**

Specifically, the gap is between:
- **Meta-level**: `neg(ψ) ∈ chain(s) for all s > t` (set membership at every position)
- **Object-level**: `G(neg(ψ)) ∈ chain(t)` (specific formula in specific set)

This conversion requires the Truth Lemma, which assumes temporal coherence (including forward_F), creating the circularity.

**Lean-specific amplification** (Teammate D, Section 1.3): In pen-and-paper proofs, `neg(neg(ψ))` is identified with `ψ` via DNE. In Lean, they are syntactically distinct (`sizeof(neg(neg(ψ))) = sizeof(ψ) + 4`), making Reynolds-style induction on formula complexity impossible without quotienting.

## Conflicts Resolved

### Conflict 1: Duration Resolution Viability

| Position | Teammate C | Teammate D |
|----------|-----------|-----------|
| Claim | Duration resolution always satisfiable | Duration resolution = forward_F in disguise |
| Argument | F-constraint DAG, Bellman-Ford | G/H propagation not a difference constraint |

**Resolution**: The existential constraints (F/P witness placement) are satisfiable. The universal constraints (G/H propagation compatibility) are the unresolved gap. The tuple construction correctly separates these concerns, which is genuine progress, but does not close the universal-to-existential gap.

### Conflict 2: Quasimodel Success Probability

| Position | Teammate A | Teammate D |
|----------|-----------|-----------|
| Probability | 35-45% | 20-30% |
| Reasoning | Eliminative fixpoint shows promise | Report 24 Section 1.5 already disproved |

**Resolution**: 30-40%. Report 24's analysis was based on incorrect semantics identification (called G/H "strict" when they are reflexive). The eliminative fixpoint argument is more promising than Report 24 suggested, but the deterministic type graph limitation is real. The approach could work with a NON-deterministic type graph, but that reintroduces the Until-through-detours problem.

### Conflict 3: F_until_equiv Impact

Teammate D raised this as a potential showstopper. No other teammate analyzed it. **This is the highest-priority finding and should be addressed first before any approach is pursued.**

## The Fundamental Obstacle (Synthesis)

The obstacle is the **gap between meta-level universal quantification and object-level G-membership** in a logic with **mixed semantics** (reflexive G/H, strict U/S). This combination:
- Is non-standard (no published proof covers exactly this combination)
- Creates a mismatch between F (reflexive: ∃ s ≥ t) and Until (strict: ∃ s > t)
- Makes `F_until_equiv` unsound, undermining the F-to-Until conversion that all chain-based approaches rely on

**Published proofs use uniform semantics**: Burgess (1984) uses all-reflexive. GHR (1994) uses all-reflexive or all-strict. Reynolds (2003) identifies neg(neg(ψ)) with ψ.

## Recommendations (Priority Order)

### 1. IMMEDIATE: Resolve F_until_equiv Soundness (Priority: Critical)

Before ANY other work, resolve the semantic mismatch:

| Option | Description | Impact | Effort |
|--------|-------------|--------|--------|
| (a) Reflexive Until | Change U semantics to ∃ s ≥ t | Makes F_until_equiv sound; largest refactor | 2000-5000 lines |
| (b) Strict G/H | Change G/H semantics to s > t / s < t | Makes F strict, matches U; removes T-axioms | 2000-5000 lines |
| (c) Remove F_until_equiv | Drop axiom, find alternative strategy | Minimal refactor but collapses finite deferral | 500-1000 lines |
| (d) Stronger seriality | Add axiom: F(ψ) → X(F(ψ) ∨ ψ) | Forces F-witness to shift forward | 200-500 lines |

**Option (a) or (b)** aligns with published proofs and gives highest confidence. **Option (d)** is cheapest and preserves existing infrastructure.

### 2. SHORT-TERM: Explore the User's Witness-First Philosophy (Priority: High)

The user's tuple/construction is the right *philosophy* (pull witnesses, then assemble) even if the specific formalization needs refinement. The next step is to formalize it as a modified quasimodel:

1. Define extended Fischer-Ladner closure with G-closure (Appendix A.1 of Teammate A)
2. Use the eliminative fixpoint (Teammate A, Section A.3) on a type graph with NON-deterministic edges (allowing g_content detours)
3. Handle Until persistence explicitly (not via F_until_equiv)
4. Estimated: 1500-2500 lines

### 3. MEDIUM-TERM: Novel Until Induction Instantiation (Priority: Medium)

Teammate D's Section 6 identifies a potentially viable path: use `until_induction` with a carefully chosen χ within the finite deferral cycle, avoiding the need for full backward_G. This requires a new mathematical idea about which χ to use. Estimated: 500-1000 lines if a viable χ is found.

### 4. DO NOT PURSUE

- **F-nesting depth induction**: Conclusively non-viable (Teammate B)
- **Any approach relying on F_until_equiv** without resolving its soundness
- **Decidability-based completeness**: Module uses Classical.em, not real proof extraction (Teammate D)
- **Any approach requiring neg(neg(ψ)) < ψ** in complexity

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Quasimodel (GHR 1994) | completed | LOW-MEDIUM | Detailed eliminative fixpoint analysis; found it ultimately blocked by deterministic type graph |
| B | F-nesting depth induction | completed | LOW | Conclusive proof of non-viability; key insight that measure works in non-chain architectures |
| C | Tuple construction (user) | completed | MEDIUM | Duration resolution satisfiability proof; connection to quasimodel identified; Until gap flagged |
| D | Devil's advocate | completed | N/A | **Critical**: F_until_equiv unsoundness confirmed; fundamental obstacle precisely characterized |

## References

- Burgess (1984): Completeness for tense logic with Until/Since, reflexive semantics
- GHR (1994), Chapter 6: Quasimodel construction with eliminative fixpoint
- Reynolds (2003): Hierarchical completeness via formula complexity induction
- Goldblatt (1992): Standard textbook, reflexive semantics throughout
- Report 24: Quasimodel-filtration study (partially incorrect semantics identification corrected here)
- Report 28: Forward_F blocker analysis
- Report 29: Cycle approach + decidability assessment

## Appendix: Verified Codebase Facts

1. `F_until_equiv_valid` sorry at Soundness.lean:770 — **confirmed**
2. `P_since_equiv_valid` sorry at Soundness.lean:786 — **confirmed**
3. G/H use reflexive semantics (Truth.lean:125-126, `t ≤ s`) — **confirmed**
4. Until/Since use strict semantics (`t < s` / `s < t`) — **confirmed**
5. `G_neg_kills_until` in FiniteDeferral.lean — **sorry-free, confirmed**
6. `neg(neg(ψ))` has `sizeof(ψ) + 4` in Lean representation — **confirmed**
