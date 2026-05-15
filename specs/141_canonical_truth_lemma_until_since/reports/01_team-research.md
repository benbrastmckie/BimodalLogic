# Research Report: Task #141

**Task**: Canonical truth lemma Until/Since and ReflexiveCanonical infrastructure
**Date**: 2026-05-14
**Mode**: Team Research (4 teammates)

## Summary

The 8 sorries split into two sharply distinct groups: 2 in ReflexiveCanonical.lean that are immediately solvable with existing infrastructure (~30-60 lines each), and 6 in TruthLemma.lean that face a fundamental blocker — the open-guard semantics (Task 113) removed BX8/BX9, breaking the standard Burgess chain construction for Until/Since guard propagation. A critical discovery: `until_F_expansion` (cited in TruthLemma comments as key infrastructure) is itself sorry'd because it depends on removed axioms. The guard condition requires a novel direct argument using BX5 (self_accum_until) without routing through `until_F_expansion`. Additionally, "DovetailingChain.lean" (referenced in the task description) does not exist — the relevant infrastructure is spread across multiple BXCanonical files. The task description's claim that items 5-6 "close automatically" is approximately but not exactly correct — they need explicit proof wiring. Strategically, these 8 sorries may not currently propagate into `bx_completeness` since Transfer.lean falls back to the chronicle construction; this should be verified via `#print axioms bx_completeness` before heavy investment.

## Key Findings

### 1. Two Groups With Radically Different Difficulty (All teammates agree)

**Group A — ReflexiveCanonical.lean (2 sorries): Immediately solvable**

| Sorry | Proof Strategy | Lines | Risk |
|-------|---------------|-------|------|
| `canS5R_symm` (line 424) | modal_b + negation completeness + MCS consistency | ~20-30 | Very Low |
| `reflCanR_linear` (line 144) | Port F_from_witness to ReflCanDomain + BX11 (temp_linearity) | ~40-60 | Low |

**Group B — TruthLemma.lean (6 sorries): Deep blocker from open-guard semantics**

The 6 sorries all trace back to two root problems: (1) the intermediate guard condition for Until/Since forward, and (2) the backward direction (semantic witness → formula membership). Both are blocked by the removal of BX8/BX9 under open-guard semantics.

### 2. canS5R_symm: Clean 20-Line Proof (All teammates agree)

Proof by contrapositive using modal_b (`φ → □◇φ`):

1. Given `canS5R x y` (∀χ, □χ ∈ x.val → χ ∈ y.val) and □φ ∈ y.val, prove φ ∈ x.val
2. Suppose φ ∉ x.val. Then ¬φ ∈ x.val (negation completeness)
3. By modal_b on ¬φ: ¬φ → □◇(¬φ) is a theorem, so □◇(¬φ) ∈ x.val
4. ◇(¬φ) = ¬□(¬(¬φ)) = ¬□φ (by definition + classical logic)
5. So □(¬□φ) ∈ x.val. By canS5R x y: ¬□φ ∈ y.val
6. But □φ ∈ y.val. Contradiction with y.val consistent.

**Dependency note** (Teammate C): The proof needs `diamond_box_duality` from `Completeness.lean`, but `ReflexiveCanonical.lean` does not import it. Either add an import or re-derive the duality inline.

### 3. reflCanR_linear: Standard BX11 Argument (All teammates agree)

1. Assume ¬tempR_fwd y z and ¬tempR_fwd z y (incomparable)
2. Get ψ with Gψ ∈ y.val, ψ ∉ z.val (from ¬tempR_fwd y z via g_content definition)
3. Get χ with Gχ ∈ z.val, χ ∉ y.val (from ¬tempR_fwd z y)
4. Show F(¬ψ) ∈ x.val: Since ψ ∉ z.val but tempR_fwd x z, if G(ψ) ∈ x.val then ψ ∈ z.val (contradiction). So G(ψ) ∉ x.val, hence F(¬ψ) = ¬G(ψ) ∈ x.val
5. Similarly F(¬χ) ∈ x.val
6. Apply BX11 (temp_linearity) at x: case analysis leads to contradiction

**Prerequisite**: Port `F_from_witness` from BXCanonical/Frame.lean to ReflCanDomain. Teammate B confirms this is structurally identical to the existing G_backward_mcs pattern in WeakCanonical/TruthLemma.lean (lines 261-304).

### 4. Critical Discovery: until_F_expansion Is Sorry'd (Teammate D)

The TruthLemma comments cite `until_F_expansion` as key infrastructure. But `until_F_expansion` (TemporalDerived.lean:455) depends on:
- `until_unfold_thm` (TemporalDerived.lean:381) — sorry'd because BX9 was removed
- `refl_F` (TemporalDerived.lean:431) — sorry'd because `α → F(α)` is not valid under irreflexive/open-guard semantics

**Consequence**: The documented proof approach for the guard condition (routing through `until_F_expansion`) does not work. An alternative approach using BX5 (self_accum_until) directly is required.

### 5. DovetailingChain.lean Does Not Exist (Teammate C, confirmed)

The task description says "Port DovetailingChain.lean chain construction to ReflCanDomain." **No such file exists** anywhere in the codebase. The relevant infrastructure is spread across:
- `BXCanonical/Filtration/DefectChain.lean` — defect-discharge chain (BXPoint-based)
- `BXCanonical/CanonicalChain.lean` — MCS-level BX lemmas
- `BXCanonical/Frame.lean` — `bx_until_eventuality_resolution`, `bx_forward_witness`

The implementer must reconstruct chain infrastructure from these sources, adapting from BXPoint types to ReflCanDomain.

### 6. The Until Forward Guard Condition: The Deep Blocker (All teammates)

The `until_forward_mcs` sorry requires: given U(ψ₁,ψ₂) ∈ x.val and witness y with ψ₁ ∈ y.val and tempR_fwd x y, prove ∀z, tempR_fwd x z → tempR_fwd z y → ψ₂ ∈ z.val.

**Why it's hard**: `tempR_fwd` is defined as g_content set inclusion (not a successor relation). There is no step-induction principle. The standard approach (Burgess 1982) used BX8/BX9 which were removed.

**Two competing approaches identified**:

**Approach 1 — Burgess §2.4 enriched seed** (Teammate A):
- Replace current witness seed `{ψ₁} ∪ g_content(x)` with enriched seed `{ψ₁} ∪ {S(α, ψ₂) | α ∈ x.val} ∪ g_content(x)`
- Use BX13 (enrichment_until) to prove consistency
- The Since formulas encode the guard condition into the witness construction
- Intermediate guard then follows from S-F duality
- **Risk**: Medium-high. Requires new seed consistency proof.

**Approach 2 — Direct BX5 chain argument** (Teammate D):
- Use BX5 (self_accum_until) directly without routing through until_F_expansion
- Port `defect_step_self_accum` from DefectChain.lean
- Work with BX5/BX6/BX10/BX4 (all valid under open-guard)
- **Risk**: Medium-high. The chain construction needs adaptation for infinite ReflCanDomain.

**Both approaches face the same fundamental obstacle**: converting U(ψ₁,ψ₂) ∈ x.val into G(U(ψ₁,ψ₂)) ∈ x.val (so it propagates via g_content to intermediate z). U does not imply G in general.

### 7. until_backward_mcs: Type Mismatch With Truth Lemma (Teammate C)

The existing `until_backward_mcs` has type: `U(ψ₁,ψ₂) ∉ x.val → ¬(∃ y, semantic Until)`. But truth_lemma line 548 needs the direction: `(semantic Until) → U(ψ₁,ψ₂) ∈ x.val`. These are contrapositives (logically equivalent) but require different proof strategies. The task description conflates them.

Additionally, the codebase comments explicitly flag: `until_backward_mcs` / `since_backward_mcs` are "NOT needed for the chronicle+Reynolds pipeline." If the implementation focuses on the pipeline path, these may be deferrable.

### 8. Strategic: Do These Sorries Actually Propagate Into bx_completeness? (Teammate D)

`doets_countermodel_discrete` in Transfer.lean currently **falls back** to `dd_countermodel_chronicle_discrete` (BXCanonical pipeline), which is sorry-free post-task-129. The TruthLemma is used only within the WeakCanonical module and may not be on the `bx_completeness` critical path.

**Recommendation**: Before heavy investment in the Until/Since guard condition, run `#print axioms bx_completeness` to verify whether these sorries actually propagate. If they don't, the ReflexiveCanonical sorries (Group A) should still be closed (low effort, high value), but the TruthLemma sorries (Group B) may be deprioritized relative to tasks 139/140.

### 9. Infrastructure Already Available (Teammates C, D confirm)

| Item | Status | Location |
|------|--------|----------|
| `until_F_expansion` | EXISTS but sorry'd | TemporalDerived.lean:455 |
| `g_content_closed_derivation` | EXISTS, sorry-free | ReflexiveCanonical.lean:280-298 |
| `forward_temporal_witness_seed_consistent` | EXISTS, sorry-free | Bundle/WitnessSeed.lean |
| BX5 (self_accum_until) | EXISTS, sorry-free | Axioms.lean |
| BX6 (bx6_absorption) | EXISTS, sorry-free | Axioms.lean |
| BX11 (temp_linearity) | EXISTS, sorry-free | Axioms.lean |
| BX13 (enrichment_until) | EXISTS, sorry-free | Axioms.lean |
| modal_b | EXISTS, sorry-free | Axioms.lean |

## Synthesis

### Conflicts Resolved

| Conflict | Resolution | Reasoning |
|----------|------------|-----------|
| Approach for guard condition | Recommend Burgess §2.4 enriched seed (Approach 1) | The Since-based encoding is more principled and matches the literature. Direct BX5 chain (Approach 2) faces the same G-propagation obstacle. |
| Whether items 5-6 close automatically | Partially automatic — need explicit proof wiring | Teammate C verified: lines 548/563 have their own sorry placeholders with independent comments. |
| Priority of Until/Since vs ReflexiveCanonical sorries | Close ReflexiveCanonical first, then assess TruthLemma | Group A is immediately solvable; Group B has fundamental obstacles and may not be on critical path. |
| Whether until_backward_mcs is needed | Verify via `#print axioms` before investing | If not on bx_completeness critical path, defer. |

### Gaps Identified

1. **Open-guard compatibility**: The standard Burgess/Reynolds chain construction assumed BX8/BX9. The open-guard replacement using BX5/BX6/BX10/BX4 needs a novel proof that has not been done in the literature for this exact setting.

2. **Import dependency for canS5R_symm**: Needs `diamond_box_duality` from Completeness.lean. Either add import or re-derive.

3. **Semantic precision of tempR_fwd for Until**: `tempR_fwd` is non-strict (g_content inclusion). Until's witness should be at a strict future. Need to verify the definition handles this correctly.

4. **No chain termination argument for ReflCanDomain**: DefectChain.lean uses finite Sigma + defect-count induction. ReflCanDomain has no finiteness constraint. A different well-foundedness argument is needed.

5. **until_backward_mcs type direction**: Proves contrapositive of what truth_lemma needs. The implementation must handle the proof direction carefully.

### Recommendations

1. **Close canS5R_symm immediately** — ~20 lines, very low risk, independent.

2. **Port F_from_witness to ReflCanDomain** — ~10 lines, prerequisite for reflCanR_linear. Mirror G_backward_mcs pattern.

3. **Close reflCanR_linear** — ~50 lines using F_from_witness + BX11.

4. **Verify critical path** — Run `#print axioms bx_completeness` before investing in TruthLemma sorries.

5. **If on critical path**: Implement Burgess §2.4 enriched seed for until_forward_mcs using BX13 (enrichment_until). Design the seed as `{ψ₁} ∪ {S(α, ψ₂) | α ∈ x.val}` and prove consistency.

6. **If NOT on critical path**: Close only Group A (2 sorries), document Group B as deferred, and prioritize tasks 139/140 which directly unblock the Reynolds pipeline.

7. **Do NOT use until_F_expansion** — it is sorry'd. Use BX5 (self_accum_until) directly.

8. **Do NOT reference DovetailingChain.lean** — it doesn't exist. Source chain infrastructure from DefectChain.lean + Frame.lean.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary: Burgess §2.4 enriched seed, proof sketches for all 8 | completed | high (Group A), medium (Group B) |
| B | Alternatives: BXCanonical comparison, g_content propagation analysis | completed | high |
| C | Critic: DovetailingChain nonexistence, items 5-6 not automatic, import gaps | completed | high |
| D | Horizons: Open-guard blocker discovery, strategic priority, critical path question | completed | high (Group A), medium (Group B) |

## References

- Burgess 1982, "Axioms for Tense Logic I: Since and Until", Section 2.4 (enrichment seed construction)
- Reynolds 1992, "An Axiomatization for Until and Since over the Reals without the IRR Rule", Section 4
- Hodkinson & Reynolds 2006, "Temporal Logic" (Handbook of Modal Logic, Ch. 11)
- Blackburn, de Rijke & Venema 2002, *Modal Logic*, Section 4.2 (S5 canonical models), Section 7.2 (Since/Until)
- Venema 1993, "Derivation Rules as Anti-Axioms in Modal Logic" (expressive completeness approach)
- Caleiro, Vigano & Volpe 2013, "A Mosaic Method for Temporal Tense Modal Logic" (alternative completeness)
