# EANegation.lean Sorry Analysis

**Task**: 305 — rabinovich_ea_formula_implementation
**Date**: 2026-06-22
**Type**: Hard-mode research (H2/H3/H4)
**Focus**: Two sorry stubs in EANegation.lean, Rabinovich mapping, downstream chain

---

## 1. Sorry Inventory

| # | Theorem | File:Line | Rabinovich Ref | Status |
|---|---------|-----------|----------------|--------|
| S1 | `neg_bracket_is_vbracket` | EANegation.lean:1047 | Lemma 5.1, pp.7–11 | sorry |
| S2 | `neg_partialBracketExist_is_vbracket` | EANegation.lean:1172 | Corollary 5.4, p.9 | sorry |

### S1: `neg_bracket_is_vbracket` (Lemma 5.1 backward, β₀(r₀) case)

**Statement**: For all n and BracketFormula bf, there exists a VBracketFormula v
such that for ALL structures M with HasAttainedINF and ALL intervals (z₀,z₁):
`v.holds M z₀ z₁ ↔ ¬bf.holds M z₀ z₁`.

**Sorry location**: Inside the backward direction (`¬bf.holds → V.holds`) of the
`succ n ih` case. The proof finds the first α₀-point r₀ in (z₀,z₁) via
HasAttainedINF.first_occ, confirms β₀ on (z₀,r₀), and then case-splits on
β₀(r₀). The ¬β₀(r₀) branch is proved (CaseD fires with point type α₀∧¬β₀).
The sorry is in the β₀(r₀)=true branch at line 1047.

**Why it's stuck**: CaseD constructs `bf_m.prepend alpha_0.neg (alpha_0.conj
beta_0.neg)`. This requires ¬β₀(r₀) at the prepended point. When β₀(r₀)
holds, no existing case in the V-bracket `result` fires. Adding a CaseE with
point type `alpha_0.conj beta_0` fails the forward direction: knowing
¬rightPart(r₀,z₁) does not imply ¬rightPart(x₀,z₁) for x₀ > r₀.

### S2: `neg_partialBracketExist_is_vbracket` (Corollary 5.4 backward, n+1)

**Statement**: For all n and BracketFormula bf, there exists a VBracketFormula v
such that for ALL M with HasAttainedINF:
`v.holds M z₀ z₁ ↔ ¬bf.partialBracketExist M z₀ z₁`.

**Sorry location**: The n+1 case, backward direction (`¬partialBracketExist →
V.holds`) at line 1172. The V-bracket v_suff was constructed from
`neg_orderedPointsExist_is_vbracket 1 fChainPred` (Lemma 5.3). The forward
direction is proved. The backward direction needs:
`¬partialBracketExist → ¬orderedPointsExist 1 fChainPred → v_suff.holds`

**Why it's stuck**: The contrapositive asks: `orderedPointsExist 1 fChainPred
→ partialBracketExist`. I.e., if x₀ ∈ (z₀,z₁) has fChainPred(x₀), then
∃ z, bf.holds(z₀,z). Two gaps:

1. **Missing first segment**: fChainPred encodes pointTypes and segmentTypes
   via nested Until from the first witness onward, but does NOT include
   segmentTypes(0) on (z₀,x₀). So fChainPred(x₀) ↛ bf.holds(z₀,z).

2. **Unbounded Until witnesses**: The nested Until in fChainPred can produce
   witnesses s₁,...,sₙ past z₁. We need them in (z₀,z) for some z < z₁.

---

## 2. H3 Reference Grounding Table

| Rabinovich Ref | Lean Theorem | File:Line | Status | Gap |
|---|---|---|---|---|
| Lemma 5.3 (p.8) | `neg_orderedPointsExist_is_vbracket` | EANegation:347 | ✅ sorry-free | — |
| Corollary 5.4 forward (p.9) | `neg_partialBracketExist_sufficient` | EANegation:725 | ✅ sorry-free | — |
| Corollary 5.4 biconditional (p.9) | `neg_partialBracketExist_is_vbracket` | EANegation:1079 | ❌ sorry (S2) | Missing first segment + unbounded Until |
| Lemma 5.1 forward (model-dep) | `neg_interval_formula` | EANegationClosure:237 | ✅ sorry-free | — |
| Lemma 5.1 biconditional (pp.7–11) | `neg_bracket_is_vbracket` | EANegation:826 | ❌ sorry (S1) | β₀(r₀) case decomposition mismatch |
| Corollary 5.4 forward (model-dep) | `neg_bounded_exists` | EANegationClosure:328 | ✅ sorry-free | — |
| Prop 4.2 single (model-dep) | `neg_vecEA2` | EANegationClosure:482 | ✅ sorry-free | — |
| Prop 4.2 full (model-dep) | `neg_2var_vec_ea` | EANegationClosure:556 | ✅ sorry-free | — |
| Prop 3.5 (VecEA2 → TL) | `VVecEA2.translateLeft/Right` | VecEATranslation | ✅ sorry-free | — |
| Bracket witness decomposition | `bracket_implies_fChainPred` | EANegation:660 | ✅ sorry-free | — |
| BracketFormula.prepend | `BracketFormula.prepend_holds` | EANegation:135 | ✅ sorry-free | — |
| BracketFormula.prepend inverse | `BracketFormula.prepend_holds_inv` | EANegation:223 | ✅ sorry-free | — |

---

## 3. Root Cause Analysis

### S1: Structural mismatch with Rabinovich's decomposition

Rabinovich's Lemma 5.1 bracket notation `[α₀, β₁, ..., αₙ](z₀, z₁)` places
α₀ at the **endpoint** z₀. The Lean `BracketFormula` places all point types at
**interior** witnesses (existentially chosen in (z₀,z₁)). This changes the
decomposition strategy.

**Rabinovich's approach** (pp.9–10): Case-split on where the first **segment
type** β₁ fails in (z₀,z₁):
- Case 1: endpoint failure (¬α₀(z₀) — trivial since α₀ is at the endpoint)
- Case 2: β₁ holds everywhere in (z₀,z₁) — no witness possible, use Cor 5.4
- Case 3: β₁ fails at r₀ = inf{x: ¬β₁(x)} — split at r₀, use IH on shorter brackets

**Lean's approach**: Case-split on where the first **point type** α₀ occurs,
then sub-split on β₀ at that point. This gets stuck when α₀(r₀) ∧ β₀(r₀)
because the prepend point type `α₀ ∧ ¬β₀` doesn't match.

**Rabinovich never hits this problem** because his decomposition finds the first
β₁ failure, not the first α₀ occurrence. When β₁ holds everywhere, the case
reduces to Corollary 5.4 (partial bracket negation), not a point-type case split.

### S2: fChainPred doesn't encode the first segment

The fChainPred construction (BracketFormula.fChainFrom) builds F_i from index 0
forward via nested Until. It encodes:
- F_n = pointTypes(n) ∧ ∃s>x, segmentTypes(n+1) on (x,s)
- F_i = pointTypes(i) ∧ ∃s>x, F_{i+1}(s) ∧ segmentTypes(i+1) on (x,s)

This starts at the **first witness**, omitting segmentTypes(0) on (z₀,w₀).
The forward direction `bracket → fChainPred` works because the bracket provides
the first segment. The backward direction fails because fChainPred(x₀) doesn't
guarantee β₀ on (z₀,x₀).

Rabinovich avoids this because his F-chain starts from the **endpoint** z₀
(where α₀ is placed), so the first segment is built into the F-chain structure.

---

## 4. Dependency Between S1 and S2

**S1 does NOT depend on S2 in the current code.** Neither sorry calls the other.

**However, a correct fix for S1 requires S2.** Restructuring S1's decomposition
to find the first β₀ failure point (matching Rabinovich) yields a sub-case where
β₀ holds everywhere in (z₀,z₁). In this sub-case:

```
¬bf.holds(z₀,z₁) = ¬(∃ x₀ ∈ (z₀,z₁), α₀(x₀) ∧ rightPart(x₀,z₁))
                   = ¬partialBracketExist(combined_bracket, z₀, z₁)
```

This requires Corollary 5.4 (neg_partialBracketExist_is_vbracket = S2).

**Correct fix order: S2 first, then S1.**

**S2 is self-contained** — it requires only:
- Lemma 5.3 (neg_orderedPointsExist_is_vbracket) — ✅ sorry-free
- A modified fChainPred or direct construction

---

## 5. Proposed Fixes

### Fix for S2 (Corollary 5.4 backward)

**Option A — Modified fChainPred**: Redefine fChainPred to include
segmentTypes(0). Define:

```
fullChainPred(x₀) := segmentTypes(0)-condition on (z₀,x₀) ∧ fChainPred(x₀)
```

The segmentTypes(0) condition can be expressed as a BracketFormula with 1
witness at x₀ having point type fChainPred and segment type segmentTypes(0).
Apply Lemma 5.3 to `¬orderedPointsExist 1 fullChainPred`. The bounding issue
(Until witnesses past z₁) resolves because on a Prior structure, the bracket
witnesses reconstruct a partial bracket.

**Option B — Direct construction**: Don't use orderedPointsExist/fChainPred
at all. Instead, use `neg_bracket_is_vbracket` (S1, once fixed) to handle
¬bf.holds(z₀,z) for each z, then quantify over z via HasAttainedINF. This
makes S2 depend on S1 instead.

**Recommended: Option A** (avoids circular dependency).

### Fix for S1 (Lemma 5.1, β₀(r₀) case)

**Restructure the decomposition** to match Rabinovich:

1. Find r₀ = first point where segmentTypes(0) **fails** in (z₀,z₁) via
   HasAttainedINF.first_occ with `segmentTypes(0).neg`.

2. **Case A** (no α₀ in (z₀,z₁)): `BracketFormula.trivial alpha_0.neg` — same
   as current CaseA. V-bracket trivially.

3. **Case B** (β₀ holds everywhere in (z₀,z₁)): ¬bf.holds reduces to
   `¬partialBracketExist` for a bracket encoding `∃ x₀, α₀(x₀) ∧
   rightPart(x₀,z₁)` with segment type β₀. Apply **S2** (Corollary 5.4).

4. **Case C** (β₀ fails at r₀): β₀ on (z₀,r₀). By HasAttainedINF, either
   ¬β₀(r₀) or β₀(r₀) with K+(¬β₀)(r₀). Sub-cases:

   - **C1** (¬β₀(r₀)): Bracket fails because segmentTypes(0) fails at r₀.
     Use INF-bracket infrastructure (already in EANegationClosure.lean:
     `inf_bracket_formula`, `inf_formula_is_vbracket`).

   - **C2** (limit point): β₀(r₀) holds but ¬β₀ holds arbitrarily close above
     r₀. On HasAttainedINF structures, this can't happen (the infimum is
     attained). So this case is vacuous.

5. **No β₀(r₀)=true problem**: The Rabinovich-aligned decomposition never
   encounters the β₀(r₀)=true sub-case that blocks the current approach.
   Case B (β₀ everywhere) uses Corollary 5.4 instead of point-type analysis.

### Estimated Effort

| Fix | Lines | Complexity | Dependencies |
|-----|-------|-----------|--------------|
| S2 (Option A) | ~100–150 | Medium | Lemma 5.3 only |
| S1 (restructure) | ~150–250 | Medium-High | S2 (fixed) + inf_formula_is_vbracket |

---

## 6. Forward-Only Alternative (EANegationClosure.lean)

EANegationClosure.lean already contains **sorry-free, model-dependent, forward-only**
versions of both theorems:

| Theorem | Lines | Status |
|---------|-------|--------|
| `neg_interval_formula` (Lemma 5.1 fwd) | 237–312 | ✅ sorry-free |
| `neg_bounded_exists` (Cor 5.4 fwd) | 328–456 | ✅ sorry-free |
| `neg_vecEA2` (Prop 4.2 single) | 482–521 | ✅ sorry-free |
| `neg_2var_vec_ea` (Prop 4.2 full) | 556–565 | ✅ sorry-free |

These prove: given M with ¬bf.holds, **there exists** a VBracketFormula that
holds. The VBracketFormula is model-dependent (existential over v, chosen per M).

**Key difference from S1/S2**: The biconditional versions need a **single fixed**
V-bracket formula that works for ALL models. The forward-only versions pick a
different v per model, which is why they avoid the β₀(r₀) problem.

**How `neg_interval_formula` avoids β₀(r₀)**: It uses `bf.tail` (drop first
point type and segment type, yielding a BracketFormula with n witnesses) and
applies the IH to ¬bf.tail on (r₀,z₁). The β₀(r₀) case falls into Case B1
(lines 279–299) where the tail bracket fails, and prepending r₀ works because
the V-bracket is model-specific.

---

## 7. Downstream Sorry Chain

### Current sorry chain (PriorComposition path):

```
EANegation.lean (S1, S2)
  │  ↑ NOT currently imported
  │
PriorComposition.lean
  ├── prior_2var_transfer_until    (line 131, sorry)
  └── prior_2var_transfer_since    (line 162, sorry)
        │
        ▼
KampBypass.lean
  └── existPart_succ_n1_bypass     (line 421)
      ├── k=0: existPart_succ_n1_bypass_k0  ← sorry-free
      └── k>0: uses prior_2var_transfer_{until,since} ← SORRY
            │
            ▼
KampMutualInduction.lean
  ├── existPart_succ               (line 290)
  ├── kamp_mutual_induction        (line 388)
  └── nf_2var_exist_formula_prior_filled (line 421)
            │
            ▼
KampPrior.lean
  └── kamp_expressive_completeness_prior  ← Final theorem
```

### Planned integration (once S1/S2 fixed):

The model-independent biconditional neg_bracket_is_vbracket (S1) and
neg_partialBracketExist_is_vbracket (S2) would enable:

1. **VVecEA2 negation closure** (model-independent) → Prop 4.2 biconditional
2. **VVecEA2 → temporal formula** via translateLeft/translateRight (Prop 3.5)
3. **2-var existential characterization** at arbitrary depth via enriched VecEA2 bypass
4. **Replace prior_2var_transfer_until/since** with formula-level equivalence

### Alternative downstream path (generalized enriched bypass):

Even WITHOUT fixing S1/S2, the PriorComposition sorry stubs can potentially
be eliminated by generalizing the enriched bypass formula from depth 0 to
arbitrary depth. The generalized bypass at depth k+2 would use:

- CharPart(k+2) for 1-var char formulas (from charPart_succ, sorry-free)
- ExistPart(k+1) at n=2 for 3-var temporal formulas (from IH + arity climbing)

Both directions of the temporal formula equivalence can be proved from the
enriched VecEA2 construction without needing model-independent negation closure.
However, this requires ~500–800 lines of new code generalizing the depth-0
KampBypassCore/K0/KPos machinery.

---

## 8. H4 Adversarial Verification

### Challenge 1: "S1 can be fixed by just adding CaseE"

**REFUTED.** Adding CaseE with point type `alpha_0.conj beta_0` at r₀ fails
the forward direction. If CaseE.holds(z₀,z₁), we get r₀ with α₀(r₀) ∧ β₀(r₀)
∧ ¬α₀ on (z₀,r₀) ∧ v_r.holds(r₀,z₁). For ¬bf.holds(z₀,z₁), we need: for ALL
x₀ > r₀ with α₀(x₀) and β₀ on (z₀,x₀), rightPart(x₀,z₁) fails. But
¬rightPart(r₀,z₁) says nothing about rightPart(x₀,z₁) for x₀ ≠ r₀.

### Challenge 2: "The forward-only versions suffice to eliminate PriorComposition sorry"

**PARTIALLY CONFIRMED.** The forward-only versions prove: M ⊨ ¬vvecEA2 →
∃ v', M ⊨ v'. This gives model-dependent V-brackets. For the transfer
theorem, we'd need: translate v' to temporal formula B, then B holds on M →
B holds on M₀ (by 1-var agreement) → contradiction. This works because B is
a fixed temporal formula once v' is chosen. But v' depends on M, and we need
to show that B = translate(v') also contradicts the original VVecEA2 on M₀.
Since v' was constructed as the negation pattern of the SAME VVecEA2 structure
(which holds on M₀), the contradiction follows. **Confidence: HIGH** but the
proof requires careful construction (~300 lines).

### Challenge 3: "S2 is independent of S1"

**CONFIRMED.** S2 (Corollary 5.4 backward) does not call or depend on S1
(Lemma 5.1 biconditional). It depends only on Lemma 5.3
(neg_orderedPointsExist_is_vbracket), which is sorry-free. The proposed fix
(modified fChainPred with β₀ segment) is self-contained.

---

## 9. Recommendations

### Priority order:

1. **Fix S2 first** (Corollary 5.4 backward, ~100–150 lines). Self-contained,
   unblocks S1. Modify fChainPred to include segmentTypes(0).

2. **Fix S1 second** (Lemma 5.1, ~150–250 lines). Restructure decomposition to
   find first β₀ failure point. Use S2 for the "β₀ everywhere" sub-case.

3. **Then eliminate PriorComposition sorry stubs** by either:
   - (a) Building model-independent Prop 4.2 from fixed S1+S2, then rewiring
     existPart_succ_n1_bypass, or
   - (b) Generalizing the enriched bypass formula to arbitrary depth using
     ExistPart IH (bypasses S1+S2 entirely but is more code)

### Path (a) is cleaner; path (b) is more self-contained.

---

## 10. File Map

| File | Role | Sorry count |
|------|------|-------------|
| EANegation.lean | Biconditional negation closure (S1, S2) | 2 |
| EANegationClosure.lean | Forward-only negation closure | 0 |
| PriorComposition.lean | 2-var semantic transfer stubs | 2 |
| KampBypass.lean | Enriched bypass formula + correctness | 0 (uses PriorComp sorry) |
| KampMutualInduction.lean | Mutual induction CharPart∧ExistPart | 0 (uses KampBypass sorry) |
| KampPrior.lean | Final Kamp completeness theorem | 0 (uses KampMutualInd) |
| VecEATranslation.lean | VecEA2 → temporal (Prop 3.5) | 0 |
| VecEAClosure.lean | VBracket/VVecEA2 closure lemmas | 0 |
