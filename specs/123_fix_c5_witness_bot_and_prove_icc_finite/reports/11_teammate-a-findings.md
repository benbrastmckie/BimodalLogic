# Teammate A Findings: Doets Henkin Approach Assessment

## Key Findings

### 1. Doets 1987 Architecture vs Current Burgess Architecture

The Doets proof (Chapter 7, pp. 89-93) has a fundamentally different architecture from the current Burgess chronicle construction:

| Aspect | Burgess (Current) | Doets 1987 |
|--------|-------------------|------------|
| Model construction | Omega-chain: iteratively insert Rat points, each assigned an MCS | Henkin: M = all MCS, R = temporal accessibility, then refine |
| Domain elements | Rationals with MCS labels | MCS themselves ARE the points |
| Linearity | Achieved by construction (rationals are linear) | Proved from axioms (Claims 6-8), then restricted to linear part |
| Constant-MCS gap | POSSIBLE: different Rat points can have identical MCS labels | IMPOSSIBLE: distinct points ARE distinct MCS by construction |
| Z-shape expansion | Not needed (domain is Rat or Int) | Claims 9-11: expand equivalence classes to zeta-shapes, then compress |
| Key tool | Counterexample elimination (C5/C5' resolution) | Ehrenfeucht games (n-characteristics) |

The Doets approach avoids the constant-MCS gap entirely because each point in M is a distinct MCS. The "gap" in the current Burgess construction arises precisely because two different rational positions can be assigned the same MCS label, making temporal axioms unable to distinguish them. In Doets, this is structurally impossible.

### 2. Doets Proof Structure (Claims 1-11)

The proof proceeds in three stages:

**Stage A: Henkin Model (Claims 1-5)**
- Start with non-derivable chi
- Build M = all MCS (for axioms: trans, succ, r-lin, l-lin, modified Lob)
- Define R: xRy iff for all phi, G(phi) in x implies phi in y
- Truth lemma (Claim 4): (M,R,V) |= phi[x] iff phi in x
- Axiom effects: R is transitive (Claim 6), no min/max (Claim 7), upper-bound comparability (Claim 8)

**Stage B: Z-Shape Expansion (Claims 9)**
- Define equivalence: x ~ y iff x = y or (xRy and yRx)
- Quotient M/~ is a linear order (from Claims 6-8)
- Restrict to points comparable to the chi-falsifying element m
- For each equivalence class A: if |A| = 1 and not aRa, A* = A; otherwise A* = (Z, <, V_A) where V_A realizes all shapes occurring in A with each shape unbounded
- N = sum over M/~ of A*
- Claim 9: same-shape elements in A and A* satisfy the same formulas (by Ehrenfeucht game)

**Stage C: Compression to Z (Claims 10-11)**
- Claim 10 (Maximum Principle): every bounded definable set has a maximum (from modified Lob / Z1)
- Use n-characteristics to classify points; bounded characteristics have maxima
- Build A = A^- union A_0 union A^+ of order type zeta
- Claim 11: A satisfies the same rank-k formulas as N (by induction on subformulas)

### 3. Codebase Reusability Assessment

**Highly Reusable (exists, sorry-free):**
- `SetMaximalConsistent` definition and properties (Core/MaximalConsistent.lean)
- `set_lindenbaum`: Lindenbaum's lemma (extends consistent set to MCS)
- `SetConsistent`, `SetMaximalConsistent.closed_under_derivation`
- `SetMaximalConsistent.negation_complete`, `.implication_property`
- `SetMaximalConsistent.conjunction_iff`, `.disjunction_iff`
- `SetMaximalConsistent.box_closure`, `.box_box` (modal closure)
- Axiom definitions (Axioms.lean): all temporal axioms including Z1, Prior-UZ/SZ
- `theorem_in_mcs`: derivable formulas are in every MCS
- Soundness infrastructure (SoundnessLemmas.lean): Z1 validity proofs
- `DerivationTree` infrastructure (Derivation.lean)

**Partially Reusable:**
- `limit_forward_G`, `limit_backward_H` (G/H propagation on limit domain) -- the PATTERN is reusable but would need new versions for a Doets-style R relation
- Truth lemma framework (ParametricTruthLemma.lean) -- the structure is the same but the coherence conditions would differ
- `ParametricCanonicalTaskFrame`, `ParametricCanonicalTaskModel` -- final countermodel assembly, highly reusable once we have a BFMCS family

**NOT Reusable (Burgess-specific):**
- Chronicle types, omega-chain construction, counterexample elimination
- `limit_dom`, `limit_f`, `omega_chain_val`
- `succ_cofinal`, `succ_orbit_convex`, `succ_embed`, all the IsSuccArchimedean machinery
- The entire `ChronicleToCountermodel.lean` except the final `dd_countermodel_chronicle_*` wiring

### 4. Effort Estimate for Full Doets Implementation

| Component | Lines (est.) | Difficulty | Notes |
|-----------|-------------|------------|-------|
| R relation on MCS | 50-100 | Low | Direct from G(phi) in x => phi in y |
| Truth lemma (Claim 4) | 100-200 | Medium | Standard, reuses MCS properties |
| Transitivity (Claim 6) | 30-50 | Low | Direct from trans axiom |
| No min/max (Claim 7) | 30-50 | Low | Direct from succ axiom |
| Linearity (Claim 8) | 100-200 | Medium | Case analysis from r-lin/l-lin |
| Equivalence, quotient (pre-Claim 9) | 100-200 | Medium | Setoid, quotient order |
| Z-shape expansion (Claim 9) | 300-500 | High | Ehrenfeucht games, shape realization |
| Maximum principle (Claim 10) | 100-200 | Medium | Uses Z1 (modified Lob) |
| n-characteristics, A construction (Claims 10-11) | 300-500 | High | Complex combinatorics |
| Compression (Claim 11) | 200-300 | Medium-High | Induction on formula rank |
| Integration with ParametricCanonical | 100-200 | Medium | Wire into existing countermodel |
| **TOTAL** | **1400-2500** | **High** | **3-6 weeks full-time** |

### 5. The Core Question: Does Doets Solve the Current Sorry?

**No, not directly.** The current sorry is in `succ_cofinal` (line 1869 of ChronicleToCountermodel.lean), within the Burgess chronicle construction's discrete case. Implementing Doets would be a REPLACEMENT of the chronicle construction for the Z-completeness case, not a patch to it.

The question is: does the Doets approach make the Z-completeness proof sorry-free without needing IsSuccArchimedean?

**Answer: Yes, but at enormous cost.** Doets avoids IsSuccArchimedean entirely because:
1. The Henkin model M has order type that is a sum of equivalence classes
2. Each equivalence class is expanded to a Z-shape (order type zeta)
3. The compression argument (Claims 10-11) uses Z1 semantically, not IsSuccArchimedean
4. The final model has order type zeta = Z, so the Int isomorphism is trivial

However, the compression argument requires Ehrenfeucht game infrastructure (n-characteristics, game-theoretic equivalence) which is approximately 500-800 lines of new Lean code and represents significant conceptual complexity.

### 6. Comparison: Doets vs Closing the Current Sorry

| Approach | Effort | Risk | Reward |
|----------|--------|------|--------|
| Close sorry in succ_cofinal (Z1 gap elimination) | 2-4 hours | Medium (discriminating formula difficulty) | Discrete case sorry-free |
| Full Doets implementation | 3-6 weeks | Low (well-understood math) but high (formalization overhead) | Z-completeness from scratch, cleaner architecture |
| Doets as ADDITION (separate theorem) | 3-6 weeks | Low | Both chronicle and Doets completeness available |

## Recommended Approach

**Do NOT pursue full Doets implementation for task 123.** The effort-to-reward ratio is extremely unfavorable: 3-6 weeks of work to achieve what the Z1 gap elimination can achieve in 2-4 hours.

**Instead, recommend a two-phase strategy:**

**Phase 1 (Immediate, task 123):** Close the sorry in `succ_cofinal` using the Z1 axiom that is ALREADY in the system (Axiom.z1, added in recent commits). The key insight from the Doets analysis is that the maximum principle (Claim 10) is the correct mathematical tool, and it works via Z1 semantics applied through `theorem_in_mcs`. The discriminating formula difficulty is real but solvable: use the formula `U(T, bot)` itself (which holds at ALL discrete-case limit_dom points by `h_discrete`), combined with the specific MCS differences forced by the counterexample resolution process.

**Phase 2 (Future roadmap item):** Implement Doets as a SEPARATE completeness theorem alongside the chronicle construction. This would:
- Provide an independent verification of Z-completeness
- Enable frame definability results (Doets Chapter 5 connections)
- Be cleaner for teaching/exposition
- Potentially simplify the mixed-case sorry (where chronicle needs different domain types)

### Coexistence Analysis

The Doets approach CAN coexist with the chronicle construction:

```
Metalogic/
  BXCanonical/           -- Burgess chronicle (existing)
    Chronicle/           -- Omega-chain construction
    Completeness.lean    -- bx_completeness (uses chronicle)
  DoetsCanonical/        -- Doets Henkin (future)
    HenkinModel.lean     -- M = MCS, R = accessibility
    ZShapeExpansion.lean  -- Claim 9
    Compression.lean     -- Claims 10-11
    Completeness.lean    -- doets_completeness (independent)
```

Both would produce the same end result (countermodel existence), but via different routes. The chronicle construction gives models on Rat (dense) or Int (discrete). The Doets construction gives models directly on Z.

## Evidence/Examples

**Evidence for the sorry-closing approach (Phase 1):**

The Z1 axiom is already in the system and available:
```lean
-- Axioms.lean:397
| z1 (φ : Formula) :
    Axiom ((φ.all_future.imp φ).all_future.imp
      (φ.all_future.some_future.imp φ.all_future))

-- ChronicleToCountermodel.lean:1532
private theorem z1_in_mcs (φ : Formula) {S : Set Formula}
    (h_mcs : SetMaximalConsistent S) :
    z1_formula φ ∈ S :=
  theorem_in_mcs h_mcs (z1_derivation φ)
```

The backward_G truth lemma is already proved (line 1707), breaking the circular dependency that was previously blocking the semantic approach. The infrastructure for the gap elimination (orbit_below_L, h_lt_pred_chain, backward_F, backward_P) is all in place.

**Evidence for Doets effort estimate:**

The Ehrenfeucht game infrastructure alone (Chapter 6) requires:
- n-characteristics definition (recursive on formula rank)
- Game-theoretic equivalence theorem (6.4)
- Exact-universal model construction (6.6)
- Canonical map and p-morphism (6.7)
- Exactness proof (6.8)

None of this exists in the codebase. The game theory is Chapter 6 (7 pages of dense mathematics), and the compression argument (Claims 10-11 of Chapter 7) depends on it entirely.

## Confidence Level

**High confidence (85%)** in the assessment that:
1. The current sorry CAN be closed without Doets (via Z1 gap elimination)
2. Full Doets implementation would take 3-6 weeks
3. The two approaches can coexist
4. Doets should be a FUTURE roadmap item, not a task 123 deliverable

**Medium confidence (65%)** in the specific discriminating formula strategy for the Z1 gap elimination. The mathematical argument is sound (Doets Claim 10 confirms this), but the Lean formalization of "there exists a formula distinguishing orbit from non-orbit points" may require careful interaction with the omega-chain construction internals.

## ROADMAP Implications

A future Doets implementation would naturally enable:

1. **Z-completeness (independent proof):** A second, cleaner proof of completeness for integer time, independent of the chronicle construction.

2. **Frame definability:** Doets Chapter 5 connects to Sahlqvist correspondence theory. The exact-universal model (6.6) enables systematic frame definability results for temporal logics.

3. **Mixed-case resolution:** The Doets approach does not have the "different domain types" problem of the mixed case. The Henkin model M is a single linear order regardless of whether individual MCS's are dense or discrete. This could potentially eliminate the `dd_countermodel_chronicle_mixed_sorry`.

4. **N-characteristics and normal forms:** Doets 6.12 gives normal forms for temporal formulas relative to Kripke models over finite partial orderings. This is a powerful tool for decidability and complexity results.

5. **Conservation theorems:** Chapter 3 of Doets provides monadic Pi^1_1 conservation results for linear orderings. These connect to the ProofChecker's existing decidability infrastructure (Metalogic/Decidability/).

**Recommended ROADMAP items:**
- `[FUTURE]` Implement Doets Henkin completeness for Z-time (Metalogic/DoetsCanonical/)
- `[FUTURE]` Frame definability via exact-universal models (Metalogic/FrameDefinability/)
- `[FUTURE]` Investigate Doets for mixed-case resolution (eliminate mixed_sorry)
