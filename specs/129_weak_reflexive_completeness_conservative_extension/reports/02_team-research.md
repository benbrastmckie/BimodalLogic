# Research Report: Task #129

**Task**: 129 — Weak/reflexive completeness and conservative extension for discrete frames
**Date**: 2026-05-13
**Mode**: Team Research (4 teammates)
**Session**: sess_1778713502_d74974

## Summary

Four-teammate investigation of the Doets construction for task 129, studying the paper precisely, auditing existing infrastructure, identifying gaps in the existing plan, and evaluating strategic alignment. The central finding is that **Reynolds 1994 — not raw Doets 1989 — is the correct primary reference**, as Reynolds directly axiomatizes US over Z using the same n-equivalence technique but specialized to our exact case. The existing plan has several critical gaps: the "weak system" is architecturally confused (resolved by using the same axiom system with a different canonical model relation), the integration strategy targets the wrong level (should bypass the chronicle, not patch `succ_cofinal`), and the Doets compression is both misidentified ("Claims 9-11" don't exist) and unnecessarily complex for the discrete case. The Reynolds discrete argument (Theorem 15) is dramatically simpler than the Doets Section 4 dense condensation, avoiding shuffling constructions entirely.

---

## Key Findings

### 1. Reynolds 1994, Not Raw Doets 1989 (Teammates A, D)

The existing plan references "Doets Claims 9-11" which do not exist in the paper (Doets uses local claim numbering per section). More importantly, **Doets's Section 4 (complete orderings) uses a dense condensation argument** designed for producing ℝ-type models, not Z. Reynolds 1994 ("Axiomatising U and S over Integer Time") provides the exact construction needed: a "good/very good" contemporaneous equivalence argument that directly targets Z, using Prior-UZ/SZ for gap elimination. Reynolds explicitly cites and uses the Doets technique but specializes it to our logic.

**Reynolds's Theorem 15 proof** (the core construction):
1. Define "good" = has a k-equivalent with integer flow
2. Define "very good" = all subintervals are good
3. Define contemporaneous equivalence ~M via "very good" intervals
4. Show ~-classes don't end at gaps (Theorem 14, using Prior-UZ/SZ)
5. Show ~-classes don't end at points (finite discrete intervals are trivially good, so by transitivity, c ~ c+1 always)
6. Therefore one equivalence class → M is good → Z-model exists

This avoids the dense shuffling construction entirely (Doets Section 4 Claims 3-4).

**Confidence**: HIGH.

### 2. The "Weak System" Is the Same Axiom System with a Different R (Teammates A, B, C)

The existing plan oscillates between treating G_w as a derived operator (making "weak completeness" circular) and as a primitive in a separate system (never properly defined). The resolution:

- **The axiom system is unchanged.** G_w(φ) := φ ∧ G(φ) is a definitional abbreviation. `SetMaximalConsistent`, `set_lindenbaum`, all MCS properties, and `DerivationTree` are reused without modification.
- **The canonical model's accessibility relation changes.** Instead of `x R y ↔ ∀ψ, G(ψ) ∈ x → ψ ∈ y` (possibly irreflexive), define `x R y ↔ ∀ψ, G_w(ψ) ∈ x → ψ ∈ y`. This is reflexive because G_w(ψ) → ψ is a propositional tautology, hence in every MCS.
- **"Weak completeness" is not a separate theorem.** The construction builds one canonical model (domain = all MCS of the unchanged system), proves a truth lemma for this model with reflexive R, then applies the Reynolds compression to produce a Z-countermodel.

No separate "WeakConsistent", "WeakMaximalConsistent", or "WeakAxioms" types are needed. The only new definition is the reflexive R on the existing MCS domain.

**Confidence**: HIGH. Teammate B verified by reading the exact Lean type signatures.

### 3. Integration Must Bypass the Chronicle Entirely (All Teammates)

The existing plan's Phase 7 proposes closing the sorry at `succ_cofinal` (ChronicleToCountermodel.lean:1885). All four teammates independently identified this as wrong:

- The sorry is deep inside the Burgess chronicle construction, trying to prove IsSuccArchimedean of the chronicle's limit domain
- The Doets/Reynolds approach **does not fix the chronicle** — it provides a completely separate completeness proof
- The correct integration: create a new `doets_countermodel_discrete` theorem (producing ∃ D, ∃ F : TaskFrame D, ∃ M : TaskModel F, ... ¬truth_at M ...) and replace the call to `dd_countermodel_chronicle_discrete` in `bx_completeness` with the new theorem
- The old `succ_cofinal` sorry becomes dead code, archivable in task 130

**Confidence**: HIGH. The sorry site's type signature (`limitDomSubtype_isSuccArchimedean`) is specific to the chronicle's `LimitDomSubtype`, which the Doets construction never touches.

### 4. Expressive Completeness Is Free in the Canonical Model (Synthesis)

Reynolds uses Kamp's expressive completeness theorem (Theorem 5: US is expressively complete over Prior structures) extensively in Lemmas 6-13 (gap elimination). Formalizing expressive completeness would be substantial (~500+ lines).

**Key insight**: In the weak canonical model, where every point is a distinct MCS, **every subset of the domain is approximated by definable subsets** (for any two points x ≠ y, there exists a formula φ with φ ∈ x and φ ∉ y). This means we don't need full expressive completeness — the canonical model's discriminating property replaces it.

Specifically, Reynolds's gap elimination arguments (Lemmas 6-13) can be simplified in the canonical model because:
- "Find a temporal formula R characterizing 'class ends at gap'" → In the canonical model, any property of points IS characterized by a formula (from MCS membership)
- Prior-UZ applied to any formula φ gives: Fφ → U(φ, ¬φ) — no gap before the first point satisfying φ
- This eliminates all definable gaps; in the canonical model, all gaps are definable

**Confidence**: MEDIUM-HIGH. The simplification is sound in principle but the formal details need working through during implementation.

### 5. n-Equivalence = Subformula Closure Agreement (Teammates A, C)

Doets's "n-equivalence" is first-order quantifier rank ≤ n agreement. For our modal/temporal logic, this translates to:

- **n-characteristic of a point x**: the set σ(x) = {ψ ∈ Sub(φ) ∪ {¬ψ | ψ ∈ Sub(φ)} | ψ ∈ x}, where Sub(φ) is the subformula closure of the target formula φ
- **n-equivalence of models**: agreement on all Boolean combinations of n-characteristics at all points, respecting the order structure
- **Finiteness**: Sub(φ) is finite (the existing `SubformulaClosure` Finset in the codebase), so there are at most 2^|Sub(φ)| n-characteristics

The connection to monadic first-order logic: each temporal formula has a "table" (first-order translation) with quantifier depth bounded by the modal nesting depth. Subformula closure agreement at depth d implies monadic sentence agreement at quantifier depth d+1 (roughly). For the Reynolds argument, we need k ≥ quantifier depth of the table of the target formula, which is bounded by the modal depth.

**Confidence**: HIGH for the mathematical correspondence. MEDIUM for the exact Lean formalization details.

### 6. Effort Estimate: 45-65 Hours Realistic (All Teammates)

| Component | Existing Plan | Revised Estimate | Notes |
|-----------|--------------|-----------------|-------|
| Weak operators + canonical model | 6h (Phases 1-2) | 8-10h | R definition, reflexivity, transitivity, linearity, truth lemma |
| n-Equivalence infrastructure | 0h (not in plan) | 8-12h | n-characteristics, finite partition, ordered sum preservation |
| Reynolds compression (good/very good) | 10h (Phase 4) | 12-18h | Contemporaneous equivalence, gap elimination (simplified), one-class argument |
| Transfer theorem | 4h (Phase 5) | 3-5h | Contrapositive wiring |
| Integration | 5h (Phases 6-7) | 4-6h | New `doets_countermodel_discrete`, update `bx_completeness` |
| **Total** | **40h** | **45-65h** | Depends on n-equivalence difficulty |

The n-equivalence infrastructure (ordered sums, preservation lemmas) is the new component not in the original plan. The Reynolds "good/very good" argument replaces the Doets Section 4 shuffling construction and should be simpler, but the gap elimination (even simplified for the canonical model) requires careful Prior-UZ/SZ analysis.

**Confidence**: MEDIUM. Lean formalization effort is inherently hard to estimate.

---

## Synthesis

### Conflicts Resolved

**1. Doets Section 3 vs. Section 4**: Teammates A and C disagreed on whether Section 3 (ω, definable induction) or Section 4 (complete orderings, condensation) applies. **Resolution**: Neither directly — Reynolds 1994 Theorem 15 provides the correct Z-specific argument. It uses elements of both (discrete structure from Section 3's setting, condensation/equivalence from Section 4's technique) but is simpler than either.

**2. Need for weak operators**: Teammate D suggested Reynolds may not need weak operators at all (using expressive completeness + Prior axioms directly on a Burgess-Xu model). Teammate C argued the "weak system" is circular. **Resolution**: Weak operators are needed but only as a canonical model technique, not as a separate system. The Burgess-Xu model (chronicle) loses the distinct-MCS property, creating the constant-MCS gap that started this whole problem. The weak canonical model restores distinct MCS by construction. Once we have the canonical model with reflexive R, the Reynolds Theorem 15 argument applies (with expressive completeness replaced by the canonical model's discriminating property).

**3. Density of quotient order**: Teammate C raised that the Doets Section 4 argument requires a dense quotient order, which isn't guaranteed. **Resolution**: The Reynolds Theorem 15 argument avoids the density question entirely — it uses "good/very good" and the discrete structure (classes can't end at gaps or at points) instead of the dense condensation. This is why Reynolds is the right reference, not Doets Section 4.

### Gaps Identified

**1. Until/Since truth lemma under reflexive R**: The truth lemma for Until(φ,ψ) in the weak canonical model needs: if Until(φ,ψ) ∉ x, construct a chain of MCS witnessing the failure. Under reflexive R, the witness y=x is allowed (so Until(φ,ψ) ∉ x implies ψ ∉ x, otherwise y=x works). The full truth lemma for Until requires the Lindenbaum extension for the "no witness" case. This was under-analyzed in the existing plan but is solvable using standard Henkin arguments. **Estimated impact**: 2-4 extra hours for Until/Since cases.

**2. Ordered sum n-equivalence preservation**: Lemma 1.4 / Lemma 1.5 of Doets (n-equivalence preserved by ordered sums) must be formalized for temporal logic, not first-order logic. This requires an induction on formula structure showing truth at a point in an ordered sum depends only on the n-type of the surrounding components. **Estimated impact**: 5-8 hours (the mathematical core of the construction).

**3. Contemporaneous equivalence definability**: Reynolds Lemma 17 defines ~M using a formula ε(x,y) in the monadic language. In the canonical model, this can be simplified (the equivalence can be defined directly from MCS properties), but the formal definition and proof that it's a contemporaneous equivalence need careful treatment. **Estimated impact**: 3-5 hours.

### Recommendations

**1. Follow Reynolds (1994) as the primary reference**, with Doets (1989) Section 1 for the ordered sum/condensation framework. The complete proof pipeline is:

```
Step 1: Consistent ¬φ → MCS A₀ (set_lindenbaum, existing)
Step 2: Build weak canonical model (all MCS, R via G_w, reflexive)
Step 3: Truth lemma (standard Henkin with reflexive R)
Step 4: Reynolds Theorem 15 on the canonical model:
  4a: Define "good" (k-equivalent to Z-interval)
  4b: Define "very good" (all subintervals good)
  4c: Define ~M contemporaneous equivalence
  4d: Show ~-classes don't end at gaps (Prior-UZ/SZ + canonical model discriminating property)
  4e: Show ~-classes don't end at points (finite = good + transitivity)
  4f: One class → M is good → Z-model N exists
Step 5: N is Z with strict <, satisfying all frame conditions
Step 6: By k-equivalence, N ⊨ ¬φ → countermodel → ¬valid_discrete(φ)
```

**2. Module structure**: `Metalogic/WeakCanonical/` with clean interfaces:

```
WeakOperators.lean        — G_w, H_w, F_w, P_w as Formula abbreviations (~80 lines)
ReflexiveCanonical.lean   — Canonical model with reflexive R, truth lemma (~600 lines)
NCharacteristic.lean      — Subformula closure types, finiteness (~200 lines)
OrderedSum.lean           — Ordered sums, n-equivalence preservation (Doets §1) (~350 lines)
GapElimination.lean       — Prior-UZ/SZ no-gap argument (Reynolds §7 simplified) (~400 lines)
IntegerModel.lean         — Good/very good, one-class, Z-model (Reynolds §8) (~300 lines)
Transfer.lean             — Contrapositive + countermodel construction (~120 lines)
Integration.lean          — doets_countermodel_discrete, wire to bx_completeness (~80 lines)
WeakCanonical.lean        — Root import (~15 lines)
```

**Total**: ~2150 lines (± 500 depending on n-equivalence difficulty)

**3. Preserve the chronicle construction.** The Doets approach replaces `dd_countermodel_chronicle_discrete` at the completeness level, not the entire chronicle pipeline. The chronicle remains used for the dense completeness path and as the structural framework. Only the discrete IsSuccArchimedean sorry becomes dead code.

---

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|-----------------|
| A | Primary (Doets study) | completed | high | Step-by-step mapping of Doets Section 4 to our setting; identified n-equivalence = subformula closure; corrected "Claims 9-11" misidentification |
| B | Alternatives (Infrastructure) | completed | high | Full infrastructure audit; confirmed MCS 100% reusable; Integration Option B (bypass chronicle); classified all alternatives as non-viable |
| C | Critic | completed | high | Identified weak system circularity, integration level mismatch, density concern, Until/Since gap, time underestimate |
| D | Horizons (Strategic) | completed | high | Reynolds 1994 as primary reference; module design recommendations; publication acceptability; downstream task analysis |

---

## References

**Primary**:
- Reynolds, M. (1994). "Axiomatising U and S over Integer Time." — `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md` — Theorem 15 (Z-model construction), Theorem 14 (no gaps), Theorem 18 (weak completeness)
- Doets, K. (1989). "Monadic Π₁¹-Theories of Π₁¹-Properties." Notre Dame J. Formal Logic 30(2). — `literature/Doets_1989_Monadic_Pi11_Theories.md` — Lemmas 1.3-1.5 (condensation, ordered sum n-equivalence), Theorem 1.2 (conservation theorem)

**Secondary**:
- Burgess, J.P. (1982). "Axioms for Tense Logic I: Since and Until." — `literature/Burgess_1982_Axioms_for_tense_logic_Since_and_Until.pdf` — Strong completeness for linear time (Corollary 3 in Reynolds)
- Venema, Y. (1991). "Many-Dimensional Modal Logics, Ch. 2." — `literature/Venema_1991_Many_Dimensional_Modal_Logics_ch2.md` — "Completeness via completeness" technique
- Hodkinson, I. & Reynolds, M. (2006). "Temporal Logic." Handbook of Modal Logic, Ch. 11. — `literature/Hodkinson_Reynolds_2006_Temporal_Logic_Handbook_Ch11.md` — Survey of Doets/Reynolds techniques

**Codebase**:
- Sorry site: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean:1885` (`succ_cofinal`)
- MCS infrastructure: `Theories/Bimodal/Metalogic/Core/MaximalConsistent.lean` (`SetMaximalConsistent`, `set_lindenbaum`)
- Axiom system: `Theories/Bimodal/ProofSystem/Axioms.lean` (41 constructors including `z1`, `prior_UZ`, `prior_SZ`)
- Truth semantics: `Theories/Bimodal/Semantics/Truth.lean` (`truth_at` with strict `<`)
- Validity: `Theories/Bimodal/Semantics/Validity.lean` (`valid_discrete`)
