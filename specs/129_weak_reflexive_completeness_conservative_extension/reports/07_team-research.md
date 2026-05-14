# Research Report: Task #129

**Task**: 129 — Weak/reflexive completeness and conservative extension for discrete frames
**Date**: 2026-05-14
**Mode**: Team Research (4 teammates)
**Session**: sess_1778772971_e25ab1

## Summary

Four-teammate investigation evaluating report 06's multi-relation mathematical analysis and whether a better approach exists. The central findings: (1) report 06's core claim is **confirmed correct** — the single-relation approach has a fatal flaw in the G-forward direction, and the multi-relation design is mathematically sound; (2) an **alternative path** was identified: bypass the reflexive canonical model entirely by using the existing Burgess chronicle as input to Reynolds Theorem 15, exactly as Reynolds 1994 does; (3) several **implementation gaps** in the current codebase were found, including a type signature bug in `until_backward_mcs`, missing linearity/transitivity proofs, and a true sorry burden of ~19 (not the headline 9).

---

## Key Findings

### 1. Report 06 Is Correct: Multi-Relation Is Mathematically Necessary (All Teammates)

All four teammates independently verified report 06's core claim. The single-relation approach (Path 2: `reflCanR` + `y ≠ x` for strict temporal semantics) has a **fatal flaw in the G-forward direction**:

- `Gψ ∈ x` does NOT imply `ψ ∧ Gψ ∈ x` because `Gψ → ψ` is not a theorem of strict TM
- No axiom bridges the gap: Z1, BX5, temp_4 were all checked — none yield `Gψ → ψ`
- Semantic counterexample: two-point model `{0, 1}` with `ψ` false at 0, true at 1 — `Gψ` holds at 0 but `ψ` does not
- The only way to make a single relation work would be to define R via `g_content` (not `g_w_content`), but this loses reflexivity, breaking the Reynolds construction

The multi-relation design (separating `reflCanR` for the frame preorder from `tempR_fwd`/`tempR_bwd` for truth evaluation) is the only approach that simultaneously provides:
- Reflexivity for Reynolds Theorem 15 (`reflCanR_refl` — proved)
- Correct G-forward truth lemma (`G_forward_mcs` — 4 lines, sorry-free)
- Correct G-backward truth lemma (`G_backward_mcs` — 48 lines, sorry-free)

**Confidence: HIGH (90%)**. Adjusted downward from report 06's 95% because the original plan text is internally contradictory (says both "R via G_w" and "using g_content, not g_w_content"), suggesting the plan author may have had a slightly different mental model than what report 06 analyzes. The mathematical conclusion is unchanged.

### 2. Reynolds Does NOT Build a Canonical Model — He Uses Burgess's Chronicle (Teammates B, D)

The most significant new finding: **Reynolds 1994 does not construct any canonical model.** His Theorem 18 (the completeness result) proceeds:

1. Given consistent ¬φ, invoke Burgess-Xu Corollary 3 to get a countable discrete linear model M₀ with Prior-UZ/SZ valid everywhere
2. Apply Theorem 15 (the "good/very good" compression) to M₀ to produce a Z-model N
3. N satisfies the same monadic sentences up to depth k, so N ⊨ ¬φ

The "starting model" M₀ is a **Burgess chronicle** — the same type of construction this project already has in `BXCanonical/Chronicle/`. Reynolds never touches the canonical model's accessibility relation. The term "reflexive canonical model" is this project's innovation, not Reynolds's.

**Critical implication**: The existing BXCanonical chronicle already provides Corollary 3's output:
- Countable ✓ (chronicle is on the rationals)
- Discrete without endpoints ✓ (chronicle construction)
- Prior-UZ/SZ valid everywhere ✓ (they're axioms, in every MCS; truth lemma gives validity)

The `succ_cofinal` sorry is in the code path that tries to prove IsSuccArchimedean of the chronicle — but **Reynolds Theorem 15 does not need IsSuccArchimedean**. It only needs the three properties above. This means the existing chronicle can serve as the starting point for Theorem 15, bypassing the sorry without proving it.

**Confidence: HIGH.**

### 3. Two Viable Paths Forward, With Clear Trade-offs (Synthesis)

**Path A: Chronicle + Reynolds Compression (follows Reynolds literally)**

```
Consistent ¬φ
  → (Lindenbaum) MCS Γ containing ¬φ  
  → (Burgess-Xu, existing BXCanonical) countable discrete model M₀
    with Prior-UZ/SZ valid everywhere
  → (Reynolds Theorem 15, NEW) Z-model N with N ≡_k M₀
  → N ⊨ ¬φ
```

Pros:
- Matches the literature exactly
- Skips 6 Until/Since truth lemma sorries (Burgess's chronicle handles them)
- No multi-relation vs. single-relation debate
- Less new code: only Theorem 15 infrastructure (n-equivalence, good/very good, gap elimination)

Cons:
- Burgess chronicle has constant-MCS regions → harder gap elimination (definability gap open)
- Must verify existing chronicle provides exactly Corollary 3's output (may have its own sorries)
- Gap elimination requires expressive completeness or a substitute (Reynolds Lemmas 6-13)

**Path B: Reflexive Canonical Model + Reynolds Compression (current approach)**

```
Consistent ¬φ
  → (Lindenbaum) MCS Γ containing ¬φ
  → (Reflexive canonical model, g_w_content-based R)
  → (Truth lemma via tempR_fwd/tempR_bwd)
  → (Reynolds Theorem 15) Z-model N
  → Transfer back to strict semantics
```

Pros:
- Distinct MCS → no definability gap → simpler gap elimination
- G/H truth lemma already sorry-free (multi-relation works)
- Prior-UZ/SZ valid by construction (axioms in every MCS)
- Already partially built

Cons:
- 6 Until/Since truth lemma sorries remain (chain construction infrastructure)
- Novel approach (not in the literature) → needs careful publication framing
- More infrastructure than Path A if chronicle is reusable

### 4. Weak Until Semantics Is Degenerate — Rules Out "Weak Truth Then Transfer" (Teammate B)

An alternative considered: define truth in the canonical model using weak (reflexive) semantics, then transfer to strict. This approach FAILS because weak Until is degenerate:

- `U_w(ψ₁, ψ₂)` at x under reflexive semantics requires ψ₂ at x itself (since x ≤ x < y for witness y > x)
- This means `U_w(ψ₁, ψ₂) → ψ₂` is valid in weak semantics — not true in strict TM
- `U_w(ψ₁, ⊥)` reduces to `ψ₁` at x (trivial "Next" operator) — semantically degenerate

This definitively rules out the "purely weak truth then transfer" approach. The multi-relation design (strict truth via `tempR_fwd`, reflexive frame via `reflCanR`) is the correct resolution.

### 5. Implementation Gaps Found (Teammate C)

**Bug**: `until_backward_mcs` (TruthLemma.lean:450) has the wrong type signature. It states the forward direction with a negated hypothesis: "if U(ψ₁,ψ₂) ∉ x, then ∃y with tempR_fwd x y ∧ ψ₁ ∈ y ∧ guard." The truth lemma's backward case needs the opposite: from semantic witnesses, recover syntactic membership. This is a genuine implementation bug, not just an unfilled sorry.

**Missing proofs**:
- `reflCanR` linearity — needed for Reynolds, not proved, not discussed
- `tempR_fwd` transitivity — provable via temp_4 (Teammate C worked through the argument), not proved in codebase
- `tempR_bwd_imp_reflCanR_bwd` — no backward bridge lemma exists
- Coherence between frame preorder and temporal relations for Reynolds intervals

**True sorry burden**: The headline 9 sorries undercounts. Including vacuous definitions (`good := True`, `very_good := True`, `k_equiv := True`, `table` returning `.atom` for everything), the actual gap count is ~19. The IntegerModel/OrderedSum/Table files have phantom proofs that prove nothing about the real definitions.

### 6. Publication Framing Recommendation (Teammate D)

The multi-relation design is novel but can be presented as a formalization insight:

> "We formalize the Reynolds 1994 completeness proof for US over ℤ in Lean 4. Our construction uses a content-separated canonical model with a reflexive frame preorder (for the good/very-good classification) and strict temporal relations (for the truth lemma). This separation, which does not appear in Reynolds's pen-and-paper proof, is necessary in the formal setting because g_w_content ⊊ g_content — the reflexive content set is strictly contained in the strict content set, and no axiom of TM bridges the gap."

The closest standard reference is BdRV §4.5 (bulldozing), where the canonical model is built with the standard (possibly reflexive) relation and then transformed. The project's approach is more sophisticated: separate the relations at definition time rather than transforming post-hoc.

---

## Synthesis

### Conflicts Resolved

**1. Alternative path viability**: Teammates B and D both identified the chronicle + Reynolds path. Teammate B noted the chronicle already satisfies Corollary 3's requirements. The conflict with the current approach (which invested in a new canonical model) was resolved by recognizing these are **complementary, not competing**: the n-equivalence/compression infrastructure (Theorem 15) is needed regardless of the starting model, and the choice of starting model is a tactical decision about which makes Theorem 15 easier.

**2. Confidence level**: Teammate A gave HIGH, Teammate C gave 90% (adjusting report 06's 95%). Resolution: **90% is more appropriate** — the plan text's internal contradiction means we can't be 100% sure we're analyzing what the plan author intended. The mathematical conclusion (multi-relation is necessary for any approach defining truth via g_content) is not affected.

**3. `tempR_fwd` transitivity**: Teammate C initially flagged non-transitivity as a concern, then retracted after working through the proof: `tempR_fwd x z ∧ tempR_fwd z y → tempR_fwd x y` holds via temp_4 (`Gψ → GGψ`). The concern became an **action item**: prove `tempR_fwd_trans` as a lemma.

### Gaps Identified

1. **Strategic choice not yet made**: Chronicle (Path A) vs. reflexive canonical model (Path B) as the starting point for Theorem 15. This is the most important open decision.

2. **Coherence between relations**: Whether `tempR_fwd`/`tempR_bwd` truth evaluation is "compatible" with `reflCanR` intervals in the Reynolds construction. Needed for Path B only.

3. **Gap elimination complexity**: Path A (chronicle) needs Reynolds Lemmas 6-13 or a substitute. Path B (canonical model) may simplify this via distinct-MCS discriminating property. No formal analysis of which is actually easier in Lean 4.

4. **Linearity of `reflCanR`**: Not proved, needed for Reynolds. Presumably follows from BX11 (temporal linearity axiom) but nobody has attempted the proof.

### Recommendations

**1. Keep multi-relation design if continuing with Path B.** Report 06 is correct — it is the only viable relation architecture for combining a reflexive frame preorder with strict temporal truth evaluation in the canonical model.

**2. Drop the equivalence lemma.** The proposed equivalence `tempR_fwd x y ↔ (reflCanR x y ∧ y ≠ x)` is neither provable nor needed. Don't spend time on it.

**3. Fix `until_backward_mcs` before proceeding.** The wrong type signature will block any attempt to close the Until truth lemma.

**4. Prove `tempR_fwd_trans` and `reflCanR_linear`.** These are straightforward lemmas (temp_4 for transitivity, BX11 for linearity) that are structural prerequisites for the Reynolds argument.

**5. Make the strategic choice between Path A and Path B.** Key factors:
- If Until/Since chain construction looks tractable → Path B (reflexive canonical model)
- If Until/Since truth lemma proves too hard → Fall back to Path A (chronicle + Theorem 15)
- The n-equivalence infrastructure (Doets Lemma 1.4, k-types, ordered sums) is shared between both paths

**6. Frame the approach for publication as "content-separated canonical model"** — a formalization insight motivated by the g_w_content ⊊ g_content distinction.

---

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Primary (verification) | completed | high | Exhaustive axiom check confirming Path 2 flaw; sorry inventory verified; G forward/backward sorry-free confirmed |
| B | Alternatives | completed | high | Weak Until degeneracy (kills purely-weak approach); chronicle + Reynolds as alternative path; literature shows no standard reference uses reflexive canonical model |
| C | Critic | completed | medium-high | `until_backward_mcs` type bug; missing linearity/transitivity proofs; true sorry burden ~19; coherence gap between frame preorder and truth relations; `tempR_fwd` IS transitive via temp_4 |
| D | Horizons | completed | high | Reynolds uses Burgess-Xu not canonical model; "content-separated canonical model" framing; no downstream task conflicts; publication strategy |

---

## References

**Primary**:
- Reynolds, M. (1994). "Axiomatising U and S over Integer Time." — `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md` — Theorem 15 (Z-compression), Theorem 18 (completeness), Corollary 3 (Burgess-Xu)
- Doets, K. (1989). "Monadic Π₁¹-Theories." — `literature/Doets_1989_Monadic_Pi11_Theories.md` — Lemma 1.4 (ordered sum n-equivalence)

**Secondary**:
- Blackburn, de Rijke, Venema (2002). "Modal Logic." Ch. 4 — `literature/Blackburn_deRijke_Venema_2002_Modal_Logic_ch4_completeness.md` — §4.5 bulldozing for strict order completeness
- Burgess, J.P. (1982). "Axioms for Tense Logic I." — `literature/Burgess_1982_Axioms_for_tense_logic_Since_and_Until.md` — Chronicle construction, Corollary 3
- Hodkinson, I. & Reynolds, M. (2006). "Temporal Logic." Handbook Ch. 11 — `literature/Hodkinson_Reynolds_2006_Temporal_Logic_Handbook_Ch11.md`

**Codebase**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ReflexiveCanonical.lean` — relation definitions, frame properties
- `Theories/Bimodal/Metalogic/WeakCanonical/TruthLemma.lean` — truth definition, partial truth lemma (6 sorries)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` — existing Burgess chronicle infrastructure
- `Theories/Bimodal/ProofSystem/Axioms.lean` — TM axiom system (no `Gψ → ψ`)
