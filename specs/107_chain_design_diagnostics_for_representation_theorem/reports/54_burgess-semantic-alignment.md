# Burgess Semantic Alignment: Task #107

- **Task**: 107 - chain_design_diagnostics_for_representation_theorem
- **Date**: 2026-05-04
- **Purpose**: Determine whether Burgess 1982 uses closed-guard or open-guard semantics for Until/Since, confirm alignment with our implementation, and identify all semantic departure points relevant to the representation theorem construction difficulties.
- **Key sources**: Burgess 1982 paper (Section 1.2), Truth.lean, Axioms.lean, Reports 36, 53

---

## Executive Summary

**Burgess 1982 uses open-guard semantics** — exactly the same semantics our implementation uses. The definitions match verbatim: strict witness (`t < s` / `s < t`) and open-guard interval (strict on both sides: `∀r, t < r < s → φ(r)`). The previous reports' frequent references to "Burgess's closed-guard semantics" conflate the axiomatic concept of guard-at-base-point (`until_guard`/`since_guard` axioms, correctly removed in task 113) with the semantic definition. A3a/A4a (preserved as BX13/BX14) ARE valid under open-guard and ARE present in our system. The construction difficulties stem from proof engineering challenges (syntactically chaining BX13+BX14 in the chronicle context) rather than semantic mismatch.

**Recommendation**: No semantic change needed. Proceed with Xu-style simplified seed `B ∪ {¬δ}` or the full Burgess D₀ chain using BX13+BX14 — both approaches work under the current open-guard semantics. The blocker is proof formalization, not semantic correctness.

---

## 1. Closed vs. Open Guard: The Definitive Answer

### 1.1 Burgess 1982 Semantics (Section 1.2)

From the paper, verbatim (line 39):

> $$V(U(\alpha,\beta)) = \{x : \exists y(x < y \wedge y \in V(\alpha) \wedge \forall z(x < z < y \supset z \in V(\beta)))\}$$

This definition has THREE components:
1. **Strict witness**: `x < y` — the event must occur at a STRICTLY future time
2. **Event at witness**: `y ∈ V(α)` — the first argument α holds at the witness point y
3. **Open guard**: `∀z(x < z < y ⊃ z ∈ V(β))` — the guard β holds on the STRICTLY OPEN interval between x and y (both inequalities are strict)

The guard is `β` on `(x, y)` — open at both ends. Neither x nor y need satisfy β.

**This is open-guard semantics.** There is no ambiguity.

### 1.2 Our Implementation (Truth.lean lines 127-128)

```lean
| Formula.untl φ ψ => ∃ s : D, t < s ∧ truth_at M Omega τ s ψ ∧
    ∀ r : D, t < r → r < s → truth_at M Omega τ r φ
```

This matches Burgess exactly:
- `t < s`: strict witness ✓
- `truth_at ... s ψ`: event ψ at witness ✓
- `∀r, t < r → r < s → truth_at ... r φ`: guard φ on open interval (t,s) ✓

**The semantics are identical.** Both use open-guard on strictly open intervals.

### 1.3 What "Closed Guard" Actually Refers To

The previous reports (36, 53, and many others) often used "closed-guard semantics" to refer to a SEMANTICS where the guard formula φ must hold at the current point t when `untl(φ, ψ)` holds at t. This property would be encoded in the axiom `until_guard: (φ U ψ) → φ`.

This axiom was:
- Present in the original (half-open guard) semantics where the Until guard covered `[t, s)` (t included)
- Correctly identified as unsound under open guard `(t, s)` (t excluded) in task 113
- Archived in `Boneyard/ClosedGuardLegacy/ClosedGuardAxioms.lean`

**Burgess's semantics does NOT satisfy `until_guard`.** Under Burgess's open-guard semantics, `U(α, β)` at x does NOT imply β(x). Countermodel: at a point x where `¬β(x)`, there exists some y > x with α(y) and β on (x,y) — then U(α,β)(x) holds but β(x) falsified.

### 1.4 Key Clarification: Burgess ≠ Closed Guard

The confusion originated from the co-occurrence of two facts:
1. Burgess's **axioms** A3a/A4a were (erroneously) thought to be invalid under open-guard semantics
2. Our **axioms** `until_guard`/`since_guard` were correctly removed as unsound under open-guard

But these are DIFFERENT axioms! A3a/A4a ≠ until_guard/since_guard. And A3a/A4a ARE valid under open-guard semantics (Section 2 below).

---

## 2. A3a/A4a Validity Under Open-Guard Semantics

### 2.1 A3a (BX13/enrichment_until)

**Burgess form** (event-first convention): `p ∧ U(q, r) → U(q ∧ S(p, r), r)`

**Our form** (guard-first convention): `p ∧ untl(φ, ψ) → untl(φ, ψ ∧ snce(φ, p))`

**Proof of validity under open guard**: 
Assume untl(φ, ψ) at t: ∃s > t: ψ(s) ∧ ∀r(t < r < s): φ(r). Need untl(φ, ψ ∧ snce(φ, p)) at t.

Use SAME witness s. At s: ψ(s) ✓. Now snce(φ, p) at s: need ∃s' < s: p(s') ∧ ∀r(s' < r < s): φ(r). Take s' = t: p(t) ✓ (hypothesis). ∀r(t < r < s): φ(r) ✓ (from Until guard on (t,s), which is exactly the Since guard (t,s)). **Result: snce(φ, p) holds at s.** Guard φ on (t,s) unchanged. **Valid.**

### 2.2 A4a (BX14/separation_until)

**Burgess form**: `U(p, q) ∧ ¬U(p, r) → U(q ∧ ¬r, q)`

**Our form**: `untl(q, p) ∧ ¬untl(r, p) → untl(q, q ∧ ¬r)`

**Proof of validity under open guard**:
Assume untl(q, p) at t: ∃s₀ > t: p(s₀) ∧ ∀u(t < u < s₀): q(u). Also ¬untl(r, p) at t.

Apply ¬untl(r, p) to witness s₀ (where p(s₀) holds, matching the event of the negated Until): Since untl(r, p) would require ∃s₁ > t: p(s₁) ∧ ∀u(t < u < s₁): r(u), the negation for s₀ means: either ¬p(s₀) (contradiction!) or ∃u₀ ∈ (t, s₀) with ¬r(u₀). Since p(s₀) ✓, the second case yields u₀ ∈ (t, s₀) with ¬r(u₀).

Now (q ∧ ¬r)(u₀): since q holds at all points in (t, s₀), and u₀ ∈ (t, s₀), q(u₀) ✓. ¬r(u₀) ✓. Guard: q on (t, u₀) ⊆ (t, s₀) → all points satisfy q. **Valid.**

### 2.3 Status in Codebase

| Burgess | Our Code | Constructor | Soundness Proof | Status |
|---------|----------|-------------|-----------------|--------|
| A3a | BX13 | `enrichment_until` | In Soundness.lean | **Present, valid** |
| A4a | BX14 | `separation_until` | `separation_until_valid` (line 625) | **Present, valid** |

**Both axioms are present and sound.** The concern in some earlier reports that "A3a/A4a are not valid under open-guard semantics" was incorrect — they ARE valid, and our codebase correctly includes them.

---

## 3. All Semantic Differences Between Burgess and Our Implementation

### 3.1 Identified Differences

| # | Aspect | Burgess 1982 | Our Implementation | Impact |
|---|--------|-------------|-------------------|--------|
| 1 | **Argument order** | U(event, guard) | untl(guard, event) | **Cosmetic** — just notation |
| 2 | **Guard semantics** | Open: (x, y) strict both sides | Open: (t, s) strict both sides | **NONE** — identical |
| 3 | **Witness inequality** | Strict: x < y | Strict: t < s | **NONE** — identical |
| 4 | **Until/Since axioms** | A1a–A7a (7 axioms × 2) | BX1–BX14 (12 axioms × 2, minus removed) | **Substantive differences exist** (see below) |
| 5 | **DCS definition** | Contains all consequences; consistency NOT required | SetConsistent ∧ ClosedUnderDerivation | **Moderate** — affects maximality edge cases |
| 6 | **BX7 vs A7a** | A7a: fixed event in all disjuncts | BX7: varying events per disjunct | **Correct fix** for open-guard |
| 7 | **Removed axioms** | A1a-A7a all present | BX8, BX9, until_guard, since_guard removed | **Correct removal** — unsound under open guard |
| 8 | **Frame reflexivity** | Strict: no reflexivity assumed | Strict: irreflexive | **NONE** — identical |

### 3.2 Detailed Analysis of Axiom Differences

**BX7 vs A7a (linearity)**:
Burgess A7a: `U(p,q) ∧ U(r,s) → U(p∧r, q∧s) ∨ U(p∧s, q∧s) ∨ U(q∧r, q∧s)`
Our BX7: `untl(φ,ψ) ∧ untl(χ,θ) → untl(φ∧χ, ψ∧θ) ∨ untl(φ∧χ, ψ∧χ) ∨ untl(φ∧χ, φ∧θ)`

In A7a, all three disjuncts have the same event (`p∧r` after normalization). In BX7, the events vary per disjunct. A7a is unsound under open-guard because when witnesses differ, no single point satisfies both events. BX7 is the sound correction. **This is a deliberate, correct difference.**

**Removed axioms** (correctly removed in task 113):
- BX8/BX8' (`until_step`/`since_step`): `untl(φ, ψ) → φ ∨ ψ ∧ untl(φ, ψ → χ) → ...`. Unsound because step reasoning requires the guard at the endpoint.
- BX9/BX9' (`until_elim`/`since_elim`): `untl(φ, ψ) → φ ∨ ψ`. Unsound because under open guard, neither φ(t) nor ψ(t) is guaranteed.
- `until_guard`/`since_guard`: `untl(φ, ψ) → φ`. Unsound because the guard is on (t,s), excluding t.

**DCS definition difference**:
Burgess: DCS S means "S contains all its consequences" — no consistency requirement. Our DCS adds SetConsistent. This matters for the Zorn maximality step in BurgessR3Maximal when facing inconsistent extension candidates. However, in practice, the constructions only target CONSISTENT DCSs, so this difference mainly affects edge-case reasoning.

---

## 4. Root Causes of Representation Theorem Difficulties

### 4.1 Primary Blocker: D₀ Consistency Proof Engineering

The chronicle construction's point insertion functions (Lemma 2.6 for C4, Lemma 2.7 for C5 nested case) require proving consistency of the "seed set" D₀:

```
D₀ = {snce(β, α) : α ∈ A, β ∈ B} ∪ B ∪ {¬δ} ∪ {untl(β, γ) : γ ∈ C, β ∈ B}
```

This set mixes formulas from THREE different MCSs/DCSs:
- `untl(β, γ)` formulas from MCS A (via burgessR3)
- `snce(β, α)` formulas from MCS C (via burgessRSince)
- B-elements that are in BOTH A and C (since B ⊆ A ∩ C)

**The "mixed A/C problem"**: Standard consistency arguments work within a single MCS (if all formulas are in A, they're consistent). When formulas come from different MCSs, joint consistency requires a single "container" formula that proves all of them consistent simultaneously.

**Burgess's solution**: Chain A5a (BX5) → A4a (BX14) → A3a (BX13) to build a SINGLE Until formula in A whose event contains all components of D₀. Then the consistency criterion (BX10/until_F) proves the event is consistent, hence D₀ is consistent.

**Why this is hard to formalize**: While each individual step is valid under open-guard semantics, SYNTHESIZING them into a complete Lean proof requires:
1. Careful translation of argument order conventions at each step
2. Propositional simplification lemmas (e.g., `⊢ (φ ∧ ψ) ∧ ¬(φ ∧ χ) → ψ ∧ ¬χ` given φ)
3. Guard monotonicity arguments to simplify the Since/Until guards
4. The consolidation step (reducing many Seed formulas to one conjunction) which requires DCS closure properties

**This is a proof engineering challenge, not a semantic mismatch.**

### 4.2 Secondary Blocker: g-Value Construction

From report 53: the point insertion functions produce only the endpoint MCS (D) but discard the interval DCS (g-values). In Burgess, the interval DCS is co-constructed — Lemma 2.6/2.7 produce B', D, B'' together (the new g-values). Our code separates these, constructing D first and attempting to reconstruct B', B'' afterward, which creates the c2' sorry sites.

**This is an architecture/formalization issue, not a semantic mismatch.**

### 4.3 What Is NOT a Blocker

1. **A3a/A4a validity**: Solved. They ARE valid under open-guard, ARE present as BX13/BX14, and have sorry-free soundness proofs.
2. **Until/Since semantics**: Solved. Our semantics matches Burgess exactly.
3. **Frame reflexivity**: Solved. Both use strict (irreflexive) order.
4. **Argument order**: Solved. The mapping is a purely mechanical convention switch, well-documented in report 53's "Argument Convention Warning" section.

---

## 5. Workarounds and Paths Forward

### 5.1 Path A: Full Burgess D₀ Chain (Recommended if resources allow)

Formalize the exact Burgess Lemma 2.6 proof using our existing BX13/BX14 axioms. This requires:

1. **BX5 application** (self_accum_until) on `untl(β, γ) ∈ A` to get `untl(β∧untl(β,γ), γ) ∈ A`
2. **BX14 application** (separation_until) on result + `¬untl(β∧δ, γ) ∈ A` to get `untl(β∧untl(β,γ), (β∧untl(β,γ))∧¬(β∧δ)) ∈ A`
3. **Propositional simplification**: The event simplifies to `β∧untl(β,γ)∧¬δ` (since `β∧untl(β,γ)→β` and `¬(β∧δ)∧β→¬δ`)
4. **BX13 application** (enrichment_until) with `α ∈ A` to get `untl(β∧untl(β,γ), β∧untl(β,γ)∧¬δ∧snce(β∧untl(β,γ), α)) ∈ A`
5. **BX10 application** (until_F) to get consistency of the event
6. **Implication lemma**: The event implies ζ, establishing ζ is consistent

Estimated effort: Medium-Hard (3-5 hours of focused proof writing).

### 5.2 Path B: Xu-Style Simplified Seed (Recommended for speed)

Use `{¬δ} ∪ B` as the seed instead of the full Burgess D₀. This avoids the "mixed A/C problem" entirely.

1. **Seed**: `{¬δ} ∪ B` — provably consistent via `dcs_neg_union_consistent` (already proven sorry-free)
2. **Construct D**: Lindenbaum extension of the seed
3. **Prove `r(A, ⊤, D)`**: For all γ ∈ D, need `untl(⊤, γ) ∈ A` i.e., `F(γ) ∈ A`
   - For γ ∈ B: from burgessR3, `untl(β, γ) ∈ A` → `F(γ) ∈ A` via BX10
   - For γ = ¬δ: from `left_mono_contrapositive_neg_delta`, either `¬δ ∈ A` or `F(¬δ) ∈ A`. If `¬δ ∈ A`, then from BX4: `G(P(¬δ)) ∈ A` →... this needs working out but seems tractable
4. **Prove `r(D, ⊤, C)`**: Mirror argument
5. **Extend to BurgessR3Maximal** via Zorn

Estimated effort: Medium (2-4 hours). The challenge is step 3, proving that D = Lindenbaum(B ∪ {¬δ}) satisfies the r-relations. This may require showing that B already contains sufficient temporal content (P(α) for α ∈ A, F(γ) for γ ∈ C) — which is what Xu's Lemma 2.3 proves using A3a.

However, since we HAVE A3a (BX13), we CAN prove an analog of Xu's Lemma 2.3, making Path B feasible.

### 5.3 Path C: Keep g-Values During Elimination (Architectural fix)

The "missing g-values" issue (Phase 3 from report 53) requires restructuring the elimination functions to co-construct endpoint MCS AND interval DCS together. This is the correct long-term approach, matching Burgess's architecture.

### 5.4 What Must NOT Change

**Do NOT change the semantics.** Both Burgess and our code use open-guard semantics. Changing to "closed-guard" (half-open [t,s) guard covering the base point) would be a regression — it would:
1. Contradict Burgess's own semantics (Section 1.2)
2. Require re-adding unsound axioms (until_guard, until_elim)
3. Break the existing soundness proofs for the current BX axiom set
4. Deviate from Kamp 1968, Xu 1988, Reynolds 1992 (all use open-guard)

The correct path is to work WITH the current open-guard semantics and formalize the proof using BX13/BX14.

---

## 6. Summary Table: The Five Critical Questions

| Question | Answer |
|----------|--------|
| 1. Does Burgess use closed or open guard? | **Open guard.** His definition uses `x < z < y` (strict both sides), the classic open-interval guard. |
| 2. How does our implementation handle this? | **Identically.** `∀r, t < r < s → φ(r)` — open guard on (t,s). |
| 3. What are all semantic differences? | **Minimal.** The core semantics match. Differences are axiomatic (BX7 vs A7a, removed BX8/BX9/until_guard), DCS consistency requirement, and argument order convention. None affect semantic validity of the construction. |
| 4. Why are A3a/A4a (BX13/BX14) blocking? | **They aren't.** Both axioms are present, valid, and have soundness proofs. The blocker is the PROOF ENGINEERING of chaining them in the chronicle construction, not their validity. |
| 5. Workaround or change semantics? | **Workaround preserves open-guard.** Both the full Burgess D₀ chain (Path A) and the Xu-style simplified seed (Path B) work under current semantics. No semantic change needed. |

---

## Appendix A: Complete Axiom Mapping

### Burgess 1982 Axioms → Our BX System

| Burgess (event-first) | Our Code (guard-first) | Status |
|----------------------|------------------------|--------|
| A1a: `G(p→q) → (U(p,r)→U(q,r))` | BX2: `(φ→χ) ∧ G(φ→χ) → (untl(φ,ψ)→untl(χ,ψ))` | Present |
| A2a: `G(p→q) → (U(r,p)→U(r,q))` | BX3: `G(φ→ψ) → (untl(χ,φ)→untl(χ,ψ))` | Present |
| A3a: `p ∧ U(q,r) → U(q∧S(p,r),r)` | BX13: `p ∧ untl(φ,ψ) → untl(φ, ψ∧snce(φ,p))` | **Present** |
| A4a: `U(p,q) ∧ ¬U(p,r) → U(q∧¬r,q)` | BX14: `untl(q,p) ∧ ¬untl(r,p) → untl(q, q∧¬r)` | **Present** |
| A5a: `U(p,q) → U(p, q∧U(p,q))` | BX5: `untl(φ,ψ) → untl(φ∧untl(φ,ψ), ψ)` | Present |
| A6a: `U(q∧U(p,q),q) → U(p,q)` | BX6: `untl(φ, φ∧untl(φ,ψ)) → untl(φ,ψ)` | Present |
| A7a: `U(p,q)∧U(r,s) → D₁∨D₂∨D₃` | BX7: different disjuncts (varying events) | Present, **corrected** |

### Removed From Our System (Archived in Boneyard)

| Axiom | Reason |
|-------|--------|
| BX8: `untl(φ, ψ) → φ ∨ (ψ ∧ untl(φ, ψ→χ))` → ... | Unsound under open guard (guard doesn't cover base point) |
| BX9: `untl(φ, ψ) → φ ∨ ψ` | Unsound under open guard |
| `until_guard`: `untl(φ, ψ) → φ` | Unsound under open guard |
| `since_guard`: `snce(φ, ψ) → φ` | Unsound under open guard |

---

## Appendix B: Key Files

- **Burgess paper**: `literature/Burgess_1982_Axioms_for_tense_logic_Since_and_Until.md`
- **Semantics**: `Theories/Bimodal/Semantics/Truth.lean` (lines 127-130 for Until/Since)
- **Axioms**: `Theories/Bimodal/ProofSystem/Axioms.lean` (BX13 at line 175, BX14 at line 193)
- **Soundness**: `Theories/Bimodal/Metalogic/Soundness.lean` (line 625 for `separation_until_valid`)
- **Archived axioms**: `Theories/Bimodal/Boneyard/ClosedGuardLegacy/ClosedGuardAxioms.lean`
- **DCS definition**: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` (line 82)
- **BurgessR3Maximal**: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` (line 320)
- **Report 36**: Detailed analysis of D₀ consistency under BX axioms
- **Report 53**: Implementation analysis of current sorry sites
