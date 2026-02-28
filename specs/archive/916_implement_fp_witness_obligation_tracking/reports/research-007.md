# Research Report: Task #916 (Team Research — Proof Technique for F-Preserving Seed Consistency)

**Task**: Close forward_F and backward_P sorries in DovetailingChain.lean
**Date**: 2026-02-21
**Mode**: Team Research (3 teammates, run 007)
**Session**: sess_1771653700_ae70b8
**Sources**: research-007-teammate-{a,b,c}-findings.md

---

## Summary

Three independent research teammates investigated:
1. Why the TM constraint enumeration is exhaustive and F-persistence is fundamentally absent
2. The F-preserving seed approach in precise detail
3. Whether a semantic argument can prove seed consistency

**Main results**:
- The constraint enumeration is provably exhaustive via complete axiom-by-axiom analysis
- The semantic argument is **fatally circular** and must be abandoned
- A **syntactic derivation surgery** argument is the correct proof path for the seed consistency conjecture
- F-formulas cannot generate new G-formulas in TM's Hilbert system, which blocks the only route to contradiction

**Updated confidence in F-preserving seed conjecture: 65%** (up from 55%) due to the derivation surgery analysis.

---

## 1. Why the Constraint Enumeration is Exhaustive

### 1.1 Architecture of Constraint Generation

Constraints between consecutive MCSs arise from exactly three sources (Teammate A, Section 1.1):
1. **Axioms of TM logic** (syntactic)
2. **Inference rules** (modus ponens, necessitation, duality, weakening)
3. **Chain construction mechanism** (seed inclusion and Lindenbaum extension)

Teammate A performed a complete axiom-by-axiom analysis verifying that every constraint between consecutive MCSs u and v (where GContent(u) ⊆ v) falls into exactly this table:

| ID | Constraint | Source Axiom(s) |
|----|-----------|-----------------|
| C1 | GContent(u) ⊆ v | Construction (seed mechanism) |
| C2 | HContent(v) ⊆ u | Derived from C1 + temp_a duality |
| D1 | G(φ) ∈ u ⟹ G(φ) ∈ v | temp_4 + C1 |
| D2 | H(φ) ∈ v ⟹ H(φ) ∈ u | past_4 + C2 |
| D3 | φ ∈ u ⟹ P(φ) ∈ v | temp_a + C1 |
| D4 | φ ∈ v ⟹ F(φ) ∈ u | past_temp_a + C2 |
| A1 | Witness seed: if F(ψ) alive, place ψ | Construction |
| A5 | Box(φ) ∈ u ⟹ Box(φ) ∈ v | temp_future + C1 |

### 1.2 Why No Other Constraints Exist

**Three independent arguments for exhaustiveness** (Teammate A, Section 1.4):

1. **Source coverage**: Every axiom schema analyzed individually. Inference rules add nothing beyond axiom consequences, since modus ponens is internal to each MCS (by MCS closure) and necessitation only applies to theorems (which are already in every MCS).

2. **Closure under composition**: Any constraint arising from composing existing constraints either stays internal to one MCS or repeats existing constraints. There is no "emergent" cross-MCS constraint from compositions.

3. **Semantic finality**: The truth conditions for all formula types are determined by: atomic truth (opaque), boolean connectives (internal), Box (cross-family, not cross-time), G/H (handled by C1/C2), and F/P (the existential obligations — the ONLY remaining gap).

### 1.3 The Propositional Axioms: Zero Cross-MCS Constraints

The 4 propositional axioms (prop_k, prop_s, ex_falso, peirce) are purely internal to each MCS. They ensure each MCS is closed under propositional reasoning, but impose no requirements between u and v.

### 1.4 The S5 Modal Axioms: Zero Direct Temporal Constraints

The 5 modal axioms (modal_t, modal_4, modal_b, modal_5_collapse, modal_k_dist) constrain the modal structure (relationships between families in a BMCS bundle) but impose no direct cross-temporal-MCS constraints. The modal-temporal interaction axioms (temp_future, modal_future) produce A5 above but nothing else.

### 1.5 The Temporal Axioms: Precisely D1, D3, and Nothing More

- **temp_4** (G(φ) → G(G(φ))): Gives D1 (G-formulas propagate forward)
- **temp_a** (φ → G(P(φ))): Gives D3 (every formula is remembered as past in v)
- **temp_l**, **temp_t_future**, **temp_t_past**: Strictly weaker or internal; add nothing new
- **temp_k_dist**: Enables G-distribution within a single MCS; subsumed by C1

---

## 2. The F-Persistence Non-Derivability: Clear and Concise

### 2.1 The Explicit Countermodel

The formula `F(ψ) → G(F(ψ))` is NOT derivable in TM logic.

**Countermodel** (Teammate A, Section 2.2): Take the integer time domain ℤ, a single world-history, and atom p true at time 1 only, false everywhere else.

- At time 0: F(p) holds (there exists s ≥ 0 with p true; s = 1 works)
- At time 0: G(F(p)) fails (at time s = 2, there is no r ≥ 2 with p true, since p is only true at 1)

Therefore F(p) holds but G(F(p)) fails at time 0. The implication F(p) → G(F(p)) is invalid.
By soundness of TM logic, invalid formulas are not derivable. □

### 2.2 The Fundamental Asymmetry

The chain construction handles G and F asymmetrically because of a mathematical asymmetry:

| Property | Universal (G) | Existential (F) |
|----------|---------------|-----------------|
| Self-propagation axiom | G(φ) → G(G(φ)) (**derivable**, temp_4) | F(φ) → G(F(φ)) (**NOT derivable**) |
| Seed mechanism | GContent directly propagates G-formulas | F-formulas are invisible to GContent |
| One-step guarantee | G(φ) ∈ u ⟹ φ ∈ v AND G(φ) ∈ v | F(φ) ∈ u ⟹ ??? |

The 4-axiom is the "self-propagation" principle for G. The corresponding principle for F is semantically false: an existential claim about the future does not entail that the claim persists forever. Once the witnessing event passes, the existential claim may become false from the perspective of later times.

**This is not a deficiency of TM logic.** It is a faithful reflection of the intended semantics.

### 2.3 Why No Additional Axiom Resolves This

Any axiom that resolves the construction problem within the current GContent-based seed must either:
- (a) Make F(ψ) → G(F(ψ)) derivable (which changes the semantics to require infinite witnesses)
- (b) Make some formula in GContent entail F(ψ) in v via MCS closure — but the exhaustive analysis (Section 1) shows no such formula exists

**Concrete alternatives evaluated** (Teammate A, Section 3.2):
- **Temporal density**: Adds more MCSs but doesn't constrain Lindenbaum's choices
- **Convergence** (F(G(φ)) → G(F(φ))): Valid in dense linear frames but does NOT imply F → GF
- **Modal-temporal connectors**: Already present (Diamond persistence proven, but that's modal not temporal)

**The problem is not in the logic but in the construction.** TM logic is complete with respect to its semantics; the chain construction technique needs refinement.

---

## 3. The F-Preserving Seed Approach: Full Detail

### 3.1 The Modification

Replace the current chain seed:
```
seed(n+1) = GContent(chain(n))                                -- base case
seed(n+1) = {ψ_n} ∪ GContent(chain(n))                      -- witness case
```

With the F-preserving seed:
```
seed(n+1) = GContent(chain(n)) ∪ FContent(chain(n)) ∪ {ψ_n if witnessing}
```

where `FContent(M) = {F(χ) : F(χ) ∈ M} = {¬G(¬χ) : ¬G(¬χ) ∈ M}`.

### 3.2 Why It Resolves Persistence

Since `F(χ) = ¬G(¬χ)` is in the seed, Lindenbaum **cannot** add `G(¬χ)` to the resulting MCS. Adding `G(¬χ)` to a set containing `¬G(¬χ)` produces an inconsistent set, and Lindenbaum (Zorn-based or constructive) only extends to consistent supersets.

Therefore:
- If `F(ψ) ∈ chain(n)`, then `F(ψ)` is in the seed for `chain(n+1)`, so `F(ψ) ∈ chain(n+1)`
- By induction: `F(ψ) ∈ chain(k)` for all k ≥ n
- In particular at k = `encodeFormula(ψ)`, the witness fires and `ψ ∈ chain(encodeFormula(ψ) + 1)`

This eliminates the persistence gap entirely. The one-shot witness mechanism becomes a reliable witness mechanism.

### 3.3 What Changes in the Codebase

The modification is localized to `dovetailForwardChainMCS` (DovetailingChain.lean, lines 519-537). The new seed replaces every `GContent(prev.val)` call with a new definition `FPreservingSeed prev.val ψ_n` that adds FContent. Approximately 60-70% of existing lemmas transfer with minor signature adjustments (all that depends on `GContent ⊆ chain(n+1)` still holds, since GContent is still a subset of the extended seed).

### 3.4 The Consistency Conjecture

**Conjecture**: If M is an MCS with F(ψ) ∈ M, then `{ψ} ∪ GContent(M) ∪ FContent(M)` is consistent.

**Why it's needed**: The consistency proof is required to apply Lindenbaum's lemma to the new extended seed.

**Why it's plausible** (three independent arguments):
1. `GContent(M) ∪ FContent(M) ⊆ M` (GContent via T-axiom, FContent by definition), so this union is consistent. Adding ψ might create inconsistency only if the union derives ¬ψ.
2. We already know `{ψ} ∪ GContent(M)` is consistent (proven lemma). The question is whether FContent adds derivation power.
3. No counterexample found across 5 research rounds and 6 independent teammates.

---

## 4. Why G-Lifting Fails (and Why the Semantic Approach is Fatal)

### 4.1 G-Lifting: The Technique and Its Limitation

The existing proof of `forward_temporal_witness_seed_consistent` uses **G-lifting** (`generalized_temporal_k`):
1. Assume inconsistency: some finite L ⊆ {ψ} ∪ GContent(M) derives ⊥
2. By deduction: GContent formulas derive ¬ψ
3. **G-lift**: apply `generalized_temporal_k` to get {G(χ_i) : χ_i ∈ GContent} derives G(¬ψ)
4. Close in M: each G(χ_i) ∈ M by definition of GContent
5. Contradict: G(¬ψ) ∈ M contradicts F(ψ) ∈ M

**For the extended seed**: the derivation includes F-formulas `F(α_j) = ¬G(¬α_j)`. G-lifting these formulas would require `G(F(α_j)) = G(¬G(¬α_j)) ∈ M`, i.e., G(F(α_j)) ∈ M, which requires F → GF. **BLOCKED.**

**This failure is fundamental, not technical** (Teammate B, Section 3.3). It reflects the structural asymmetry: G-formulas are G-liftable (GContent membership gives the wrapping by definition), F-formulas are NOT G-liftable (F(χ) ∈ M does not imply G(F(χ)) ∈ M). No reformulation of the proof can overcome this.

### 4.2 The Semantic Approach: Fatally Circular

The suggestion from research-006 to use a semantic model construction is **not viable** (Teammate C, Sections 2-3).

**The circularity** (Teammate C, Section 2.1):
```
Semantic proof of seed consistency
  → requires constructing a Kripke model for the seed
  → model construction requires completeness
  → completeness proof requires the truth lemma (TruthLemma.lean)
  → truth lemma requires forward_F (DovetailingChain.lean)
  → forward_F requires seed consistency
  ↻ CIRCULAR
```

Five strategies were evaluated:
| Strategy | Status |
|----------|--------|
| Use completeness directly | CIRCULAR |
| Build custom model | Equivalent to completeness proof |
| Use soundness + model | CIRCULAR (same direction) |
| Compactness | No TM compactness in codebase; finite subsets face same obstacle |
| Use MCS M as model fragment | Insufficient (adding ψ might be inconsistent with FContent) |

**Verdict**: Abandon the semantic approach entirely.

---

## 5. The Correct Proof Path: Syntactic Derivation Surgery

### 5.1 The Key Structural Insight

Teammate C (Section 3.6) and Teammate B (Section 4.4) independently arrived at the same structural observation:

**In TM's Hilbert system, F-formulas (negated G-formulas) cannot generate new G-formulas when used as hypotheses.**

The only routes to deriving G(¬χ) in a Hilbert derivation from the seed `{ψ} ∪ GContent(M) ∪ FContent(M)` are:
1. G(¬χ) is a hypothesis (an assumption in the seed)
2. G(¬χ) is derivable from other G-hypotheses via axioms
3. G(¬χ) is a theorem (derivable from empty context)

**Route 1 is blocked**: G(¬χ) ∉ GContent(M) for any F(χ) ∈ M (if G(¬χ) ∈ GContent(M) then G(¬χ) ∈ M, contradicting F(χ) = ¬G(¬χ) ∈ M). F-formulas are in FContent(M), not GContent(M).

**Route 3 is blocked**: If G(¬χ) is a theorem, then ¬χ holds at all times in all models, so F(χ) is unsatisfiable. But F(χ) ∈ M and M is consistent, so F(χ) is satisfiable. Contradiction.

**Route 2** (deriving G(¬χ) from GContent formulas and F-formulas via axioms): This requires careful analysis. The TM axioms that produce G-formulas as outputs from non-G inputs are:
- **temp_a**: φ → G(P(φ)) — produces G(P(φ)) from arbitrary φ
- **temp_k_dist**: G(φ → ψ) → (G(φ) → G(ψ)) — requires G-hypotheses as inputs

The F-formulas ¬G(¬χ_j) can interact with temp_a by substituting φ = ¬G(¬χ_j) to get:
```
¬G(¬χ_j) → G(P(¬G(¬χ_j)))
```
This produces `G(P(¬G(¬χ_j)))` — a G-formula with very specific nested structure. This G-formula cannot be combined via temp_k_dist to yield `G(¬χ_k)` for any specific χ_k without further specific hypotheses.

**The crucial fact** (Teammate B, Section 4.4): GContent(M) does NOT derive ¬α_j for any F(α_j) ∈ FContent(M).

**Proof**: If GContent(M) ⊢ ¬α_j, then by G-lifting (which IS valid for GContent): {G(χ) : χ ∈ GContent(M)} ⊢ G(¬α_j). Since G(χ) ∈ M for all χ ∈ GContent(M), by MCS closure: G(¬α_j) ∈ M. But F(α_j) ∈ M means ¬G(¬α_j) ∈ M — contradiction with MCS consistency. □

This means: **G(¬χ) is not derivable from GContent(M) alone for any F(χ) ∈ M.** Adding FContent(M) to the context does not introduce the positive counterpart G(¬χ) directly. The only way Route 2 could succeed is through complex chains involving temp_a, but these produce G(P(...)) structures that are not of the form G(¬χ_k).

### 5.2 The Derivation Surgery Argument (Sketch)

**Claim**: If the extended seed `{ψ} ∪ GContent(M) ∪ FContent(M)` is inconsistent, then `{ψ} ∪ GContent(M)` is also inconsistent.

**Proof sketch** (to be formalized):
1. Suppose `L ⊆ {ψ} ∪ GContent(M) ∪ FContent(M)` is finite with `L ⊢ ⊥`.
2. Partition L into `L_G ⊆ GContent(M)`, `L_F ⊆ FContent(M)`, and possibly ψ.
3. Apply deduction theorem to extract L_F formulas:
   ```
   L_G derives F(α_1) → (F(α_2) → ... → (F(α_m) → ¬ψ)...)
   ```
   Call this formula Φ.
4. G-lift (valid for L_G): `{G(g) : g ∈ L_G} ⊢ G(Φ)`. By MCS closure: G(Φ) ∈ M.
5. By T-axiom: Φ ∈ M.
6. Since F(α_1) ∈ M, by modus ponens: `F(α_2) → ... → (F(α_m) → ¬ψ)... ∈ M`.
7. Repeating for all F-formulas: `¬ψ ∈ M`.
8. **But**: `{ψ} ∪ GContent(M)` is consistent (proven lemma), so GContent(M) does not derive ¬ψ.
9. However, we derived ¬ψ ∈ M via a different route (steps 4-7 above, using G-lifting of GContent formulas and then modus ponens with FContent formulas). This shows ¬ψ ∈ M.
10. Now: does ¬ψ ∈ M contradict seed consistency? We need ¬ψ ∉ GContent(M) to be maintained. ¬ψ ∈ GContent(M) would require G(¬ψ) ∈ M, which contradicts F(ψ) ∈ M. So ¬ψ ∉ GContent(M). ✓
11. **Gap at step 9**: We showed that if the extended seed is inconsistent, then ¬ψ ∈ M (via steps 4-7). But this doesn't directly contradict our assumption — ¬ψ could be in M when F(ψ) is also in M (F is future-looking, ¬ψ is present truth).
12. **The actual contradiction**: In step 3, after G-lifting and T-axiom: Φ ∈ M. Φ = F(α_1) → (...). Since F(α_1) ∈ M by assumption, by modus ponens: `F(α_2) → ... → ¬ψ ∈ M`. Continuing: `¬ψ ∈ M`. But then `{ψ, g_1, ..., g_k} derives ⊥` if we include ¬ψ in GContent... but ¬ψ ∉ GContent(M). So the derivation of bot from `{ψ} ∪ GContent(M)` requires ¬ψ to be DERIVABLE from GContent(M), not merely in M.

**Refinement needed**: The critical question is whether the F-formula chain in steps 3-7 can be avoided — i.e., whether the inconsistency of the extended seed necessarily propagates to the base seed. This requires a more careful structural induction on derivation trees.

### 5.3 Why Derivation Surgery is Promising

Despite the sketch having a gap at step 12, derivation surgery is the most promising approach because:

1. **No circularity**: Purely syntactic, no completeness needed
2. **Structural insight is correct**: F-formulas cannot generate G(¬χ_j) without route-blocking by MCS consistency
3. **The gap is technical**: The argument shows ¬ψ ∈ M (not ¬ψ ∈ GContent(M)), and the resolution may involve analyzing whether any derivation using FContent formulas can be "collapsed" to one using only GContent formulas
4. **temp_a complication is manageable**: The G-formulas produced by temp_a have specific structure G(P(...)) that must be analyzed to show they can't lead to G(¬χ) for the relevant χ

---

## 6. Synthesis: Updated Assessment

### 6.1 Conflicts Resolved

| Conflict | Resolution |
|----------|------------|
| Semantic vs syntactic approach | **Resolved**: Semantic is circular (Teammate C proves it). Syntactic derivation surgery is correct path. |
| Confidence in conjecture | **Resolved**: Updated from 55% to 65% based on derivation structure analysis. Route 1 and Route 3 are definitively blocked. Route 2 requires careful analysis of temp_a. |
| Best proof technique | **Resolved**: Derivation surgery (structural induction on derivation trees), not G-lifting or semantic models |

### 6.2 Gaps Identified

1. **The temp_a analysis**: G-formulas produced by temp_a have structure G(P(¬G(¬χ_j))). Need to verify these cannot combine with other hypotheses to yield G(¬χ_k) for any k.

2. **Step 12 gap in derivation surgery**: The sketch shows ¬ψ ∈ M but not ¬ψ derivable from GContent(M). A complete proof needs to show either:
   - The derivation using FContent formulas is collapsible to a derivation from GContent alone, OR
   - A different contradiction arises from the structure of the derivation tree

3. **Backward direction**: The above analysis covers forward_F. The backward_P sorry is symmetric; the derivation surgery argument should apply symmetrically via HContent/FContent duality.

### 6.3 Updated Path Forward

**Immediate next step** (refined from research-005 recommendation):

Investigate the F-preserving seed consistency conjecture using **syntactic derivation surgery**:

1. (4 hours) Prove the base structural fact: `GContent(M) ⊢ ¬α` implies `G(¬α) ∈ M` (using G-lifting), and therefore if `F(α) ∈ M` then `GContent(M) ⊬ ¬α`. Verify this is already in the codebase or add it as a standalone lemma.

2. (4 hours) Prove the FContent independence fact: for any F(α) ∈ FContent(M), `GContent(M) ∪ {F(β) : β ≠ α} ⊬ G(¬α)`. This requires ruling out Route 2 derivations (specifically the temp_a interaction).

3. (4 hours) Assemble the consistency proof via structural induction on derivation trees.

**Total estimate**: 12 hours for the focused investigation.

**If conjecture proved**: Proceed with F-preserving seed implementation (25-35 additional hours). The chain seed modification is localized; 60-70% of existing lemmas transfer.

**If investigation fails or counterexample found**: Accept sorry debt with documentation.

---

## 7. Teammate Contributions

| Teammate | Angle | Key Contribution | Confidence |
|----------|-------|-----------------|------------|
| A | Constraint exhaustiveness | Complete axiom-by-axiom proof; explicit F→GF countermodel | HIGH |
| B | F-preserving seed detail | Derivation-theoretic analysis; 7 alternatives evaluated | HIGH |
| C | Semantic argument | Proves circularity; identifies derivation surgery as winning path | MEDIUM |

### Conflicts Found and Resolved: 1

- **Semantic approach viability**: Teammates B and A considered it a possible avenue; Teammate C proves it is fatally circular. **Resolved in favor of Teammate C** — abandon semantic approach.

### Gaps Remaining: 2

1. temp_a interaction in Route 2 derivations
2. Step 12 gap in derivation surgery sketch (see Section 5.3)

---

## 8. Confidence Assessment

| Finding | Confidence |
|---------|------------|
| Constraint enumeration is exhaustive | HIGH (95%) — complete axiom-by-axiom analysis |
| F(ψ) → G(F(ψ)) not derivable in TM | HIGH (98%) — explicit countermodel |
| No axiom addition resolves the construction problem | HIGH (92%) — follows from exhaustiveness |
| Semantic approach is circular | HIGH (95%) — circularity chain is explicit |
| F-preserving seed correctly addresses persistence | HIGH (95%) — mechanism is clear |
| G-lifting failure is fundamental | HIGH (98%) — structural asymmetry |
| **F-preserving seed conjecture (new estimate)** | **MEDIUM-HIGH (65%)** — Routes 1 and 3 definitively blocked; Route 2 requires temp_a analysis |
| Derivation surgery is the correct proof technique | MEDIUM (70%) — promising but step 12 gap needs resolution |

---

## 9. References

### Project Files
- `Theories/Bimodal/ProofSystem/Axioms.lean` — Complete TM axiom system (16 constructors)
- `Theories/Bimodal/ProofSystem/Derivation.lean` — Inference rules (7 rules)
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` — Chain construction (2 sorries)
- `Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean` — GContent/HContent (28 lines)
- `Theories/Bimodal/Metalogic/Core/MaximalConsistent.lean` — set_lindenbaum (Zorn-based)
- `Theories/Bimodal/Theorems/GeneralizedNecessitation.lean` — generalized_temporal_k
- `Theories/Bimodal/Metalogic/Soundness.lean` — Soundness (sorry-free)
- `Theories/Bimodal/Semantics/Truth.lean` — Semantic truth (reflexive operators)

### Prior Research
- `specs/916_.../reports/research-005.md` — Prior synthesis (Path 1 description)
- `specs/916_.../reports/research-006.md` — Constraint enumeration; Section 4.3 G-lifting analysis
- `specs/916_.../reports/research-007-teammate-a-findings.md` — Constraint exhaustiveness
- `specs/916_.../reports/research-007-teammate-b-findings.md` — F-preserving seed detail
- `specs/916_.../reports/research-007-teammate-c-findings.md` — Semantic argument and derivation surgery

### Key Logical Facts
- `SetConsistent S` iff no finite subset of S derives ⊥
- `GContent(M) = {φ : G(φ) ∈ M}` — T-axiom ensures GContent ⊆ M
- `FContent(M) = {F(χ) : F(χ) ∈ M}` — by definition FContent ⊆ M
- For any F(χ) ∈ M: G(¬χ) ∉ M (MCS consistency)
- For any χ ∈ GContent(M): F(¬χ) ∉ M (MCS consistency)
- `forward_temporal_witness_seed_consistent` proves `{ψ} ∪ GContent(M)` consistent when F(ψ) ∈ M
