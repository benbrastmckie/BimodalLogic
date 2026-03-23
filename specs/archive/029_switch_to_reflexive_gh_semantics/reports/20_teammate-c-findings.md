# Teammate C Findings: Theoretical Foundations — Reflexive Temporal Logic

## Key Findings

1. **IRR is unsound under reflexive semantics** — the antecedent `p ∧ H(¬p)` is unsatisfiable when H quantifies over s ≤ t, since H(¬p) at t requires ¬p at t, contradicting p at t.

2. **The T-axiom (Gφ → φ, Hφ → φ) is valid and already present** — axioms `temp_t_future` and `temp_t_past` exist in `Axioms.lean` (lines 290, 304). Their soundness proofs are complete in `Soundness.lean` (lines 248-267).

3. **`canonicalR_reflexive` is already proven** — in `CanonicalIrreflexivity.lean` lines 1206-1212. The proof uses the T-axiom: G(φ) ∈ M → φ ∈ M by modus ponens with `Gφ → φ`.

4. **The `canonicalR_irreflexive_axiom` introduces an active INCONSISTENCY** — the codebase simultaneously asserts `CanonicalR M M` (proven theorem, line 1206) and `¬CanonicalR M M` (axiom, line 1492). This makes the entire system unsound.

5. **The substitution lemma (Phase 5.0) has a sorry** — `derivation_subst` in `Substitution.lean` line 386 has an incomplete case for the IRR constructor. This blocks the fresh G-atom approach.

6. **The IRR soundness proof has a sorry** — `irr_sound_dense_at_domain` in `IRRSoundness.lean` line 322 ends with `sorry`. The comment at line 310-321 explicitly explains why: under reflexive semantics (≤ ordering), H(¬p) at t includes t itself, making `p ∧ H(¬p)` unsatisfiable.

7. **The completeness path does NOT fundamentally require IRR** — completeness for reflexive temporal logic over reflexive linear orders uses the T-axiom to guarantee reflexivity of the canonical relation. The standard axiomatization is Kt + T-axiom + linearity + density/discreteness extensions.

## IRR Unsoundness Proof

### Formal Statement

**Claim**: The IRR rule is unsound on reflexive frames.

**IRR rule**: From `⊢ (p ∧ H(¬p)) → φ` where p ∉ atoms(φ), infer `⊢ φ`.

**Countermodel**: Take any reflexive frame (D, ≤) with at least one point t.

- The antecedent is `p ∧ H(¬p)` where H(¬p) at t means ∀s ≤ t, ¬p(s).
- Since t ≤ t (reflexivity), H(¬p) at t requires ¬p(t).
- But p at t is also required by the conjunction.
- Therefore `p ∧ H(¬p)` is **unsatisfiable** at every point in every reflexive frame.
- Since the antecedent is always false, `(p ∧ H(¬p)) → φ` is vacuously true for ALL φ.
- So the premise `⊢ (p ∧ H(¬p)) → φ` is satisfied for ANY φ, including ⊥.
- But `⊢ ⊥` is obviously not valid.
- Therefore IRR is **unsound** on reflexive frames.

### Where the soundness proof breaks

In `IRRSoundness.lean` lines 306-322, the proof needs to construct a witness satisfying `p ∧ H(¬p)` at time t. Under strict semantics (< ordering), this works: set p true only at t, then H(¬p) at t means ∀s < t, ¬p(s), which is satisfied. Under reflexive semantics (≤ ordering), H(¬p) at t means ∀s ≤ t, ¬p(s), which includes t itself — contradicting p(t). The proof correctly ends with `sorry` and a comment explaining this.

## Correct Axiomatization

### Current axiom set (from Axioms.lean)

The codebase already has the correct axiom set for reflexive temporal logic:

**Propositional**: prop_k, prop_s, ex_falso, peirce (classical)
**Modal S5**: modal_t, modal_4, modal_b, modal_5_collapse, modal_k_dist
**Temporal base**: temp_k_dist, temp_4, temp_a, temp_l, temp_linearity
**Temporal T-axioms**: temp_t_future (Gφ → φ), temp_t_past (Hφ → φ) — **correct for reflexive semantics**
**Modal-temporal interaction**: modal_future, temp_future
**Dense extension**: density (GGφ → Gφ)
**Discrete extension**: discreteness_forward, seriality_future, seriality_past

This is the standard axiomatization for reflexive tense logic over linear orders:
- **Kt.T** = minimal tense logic + T-axioms (reflexive frames)
- **+ linearity** (temp_linearity) = reflexive linear orders
- **+ density** = reflexive dense linear orders
- **+ discreteness + seriality** = reflexive discrete linear orders without endpoints

### What the IRR rule was compensating for

Under **irreflexive** (strict) semantics, the T-axioms are invalid, and IRR was needed to:
1. Prove `canonicalR_irreflexive` — ensuring the canonical relation is strict
2. Derive strictness witnesses for NoMaxOrder, NoMinOrder, DenselyOrdered
3. Enable the antisymmetrization quotient to work correctly

Under **reflexive** semantics, the T-axioms directly provide:
1. `canonicalR_reflexive` — g_content(M) ⊆ M (already proven)
2. The canonical relation is a preorder (reflexive + transitive via temp_4)
3. The antisymmetrization quotient gives a partial order automatically

**IRR is no longer needed. It should be removed from the proof system entirely.**

## Completeness Without IRR

### The completeness path under reflexive semantics

The canonical model construction for reflexive temporal logic is actually **simpler** than for irreflexive:

1. **MCS construction**: Standard Lindenbaum extension (unchanged)
2. **Canonical relation**: `CanonicalR M N ⟺ g_content(M) ⊆ N` (unchanged)
3. **Reflexivity**: `CanonicalR M M` — provable from T-axiom (already done, line 1206)
4. **Transitivity**: `CanonicalR M N ∧ CanonicalR N P → CanonicalR M P` — from temp_4 (standard)
5. **Truth lemma**: φ ∈ M ⟺ M ⊨ φ — standard induction (unchanged by reflexivity)
6. **Quotient**: Antisymmetrization of the preorder gives LinearOrder

### What changes for the quotient order properties

The downstream properties (NoMaxOrder, NoMinOrder, DenselyOrdered) currently use `canonicalR_irreflexive` to get strictness. Under reflexive semantics:

- **NoMaxOrder**: Need ∃W, M < W (strict). Seriality gives ∃W, M ≤ W. Need M ≠ W (in quotient).
- **NoMinOrder**: Same, dual direction.
- **DenselyOrdered**: Need ∃W, M < W < N (strict). Density gives non-strict witnesses.

The fresh G-atom approach (plan v4 Phase 5.2) addresses this: construct W with `g_content(M) ∪ {G(q)}` where q is chosen so that q ∈ g_content(W) but q ∉ M. This gives `CanonicalR M W` (from g_content(M) ⊆ W) but `¬CanonicalR W M` (since q ∈ g_content(W) \ M).

### Does the completeness proof path use IRR anywhere?

Yes — **extensively**. The `canonicalR_irreflexive` theorem (backed by the axiom) is used at **54+ call sites** across the metalogic:

| File | Uses | Purpose |
|------|------|---------|
| `DovetailedTimelineQuot.lean` | ~12 | Quotient order strictness |
| `SaturatedChain.lean` | ~8 | Chain construction strictness |
| `CantorApplication.lean` | ~3 | NoMaxOrder, NoMinOrder, DenselyOrdered |
| `ClosureSaturation.lean` | ~2 | Saturation step strictness |
| `FMCSTransfer.lean` | ~2 | Transfer lemma strictness |
| `CanonicalSerialFrameInstance.lean` | ~2 | Serial frame strictness |
| `DiscreteTimeline.lean` | ~2 | Discrete successor strictness |
| `TimelineQuotCanonical.lean` | ~1 | Quotient canonical construction |
| `IncrementalTimeline.lean` | ~1 | Timeline construction |

All of these use the same pattern: if `CanonicalR M N` and `CanonicalR N M`, then `CanonicalR M M` by transitivity, contradicting `canonicalR_irreflexive`. This pattern needs to be replaced with per-witness strictness arguments.

## Plan v4 Reassessment

### Phases that are OBSOLETE

| Phase | Description | Status | Assessment |
|-------|-------------|--------|------------|
| 5.0 | Substitution lemma | PARTIAL (1 sorry) | **LIKELY UNNECESSARY** — see below |
| IRR soundness | IRR rule soundness proof | sorry | **OBSOLETE** — IRR should be removed, not proved sound |

**Why the substitution lemma may be unnecessary**: The substitution lemma was designed to close sorries in the fresh G-atom approach (exists_strict_fresh_atom). But the sorries at lines 1283 and 1294 are in `exists_strict_fresh_atom`, which tries to find an atom q with ¬q ∈ M and G(¬q) ∉ M. The current proof approach (contradiction from h_no_such) is on the right track but incomplete.

The substitution lemma would help prove "if q is fresh for M, then substituting q preserves derivability from M." But a simpler approach exists: use the **countability of atoms** and the fact that MCSes are proper subsets of the set of all formulas. Since there are countably infinite atoms but each MCS is consistent (hence doesn't contain all formulas), there must exist atoms in the desired configuration. This is a counting/cardinality argument, not a substitution argument.

### Phases that REMAIN NECESSARY

| Phase | Description | Assessment |
|-------|-------------|------------|
| 5.1 | Fresh atom seed consistency | **NEEDED** — but the approach should be simplified |
| 5.2 | Strict witness theorems | **NEEDED** — core of the per-witness strictness approach |
| 5.3 | Update quotient order proofs | **NEEDED** — 54+ call sites to fix |
| 5.4 | Update remaining call sites | **NEEDED** — see enumeration above |
| 5.5 | Remove axiom | **NEEDED** — critical to restore soundness |
| 6 | T-axiom simplification for DiscreteSuccSeed | **NEEDED** — separate from IRR |

### Phase that should be ADDED

| New Phase | Description | Priority |
|-----------|-------------|----------|
| **Remove IRR from proof system** | Delete the `irr` constructor from `DerivationTree`, remove IRR from `height`, `isDenseCompatible`, `isDiscreteCompatible` | **HIGH** — IRR is unsound under reflexive semantics |
| **Remove IRR soundness** | Delete `IRRSoundness.lean` or gut it | **HIGH** — the module is proving soundness of an unsound rule |
| **Fix Soundness.lean** | Remove the IRR case from `soundness_dense_valid` and `soundness_dense` | **HIGH** — these have sorries precisely because IRR is unsound |

## What Actually Needs To Be Done (Revised Task List)

### Critical Path (restoring soundness)

1. **Remove IRR from DerivationTree** (`Derivation.lean`)
   - Delete the `irr` constructor
   - Update `height`, `isDenseCompatible`, `isDiscreteCompatible`
   - This will cause compile errors at all IRR usage sites

2. **Delete or gut IRRSoundness.lean**
   - The entire file is proving soundness of an unsound rule
   - Can be preserved as historical documentation if desired

3. **Fix Soundness.lean**
   - Remove the `irr` case from `soundness_dense_valid` (line 671-688)
   - Remove the `irr` case from `soundness_dense` (line 604-606)
   - This eliminates 2 of the 7 sorries in Soundness.lean

4. **Fix Substitution.lean** (if needed)
   - The sorry at line 386 is in the IRR case of `derivation_subst`
   - If IRR is removed from DerivationTree, this sorry disappears automatically

### Per-Witness Strictness Path (replacing universal irreflexivity)

5. **Prove `exists_strict_fresh_atom`** (lines 1283, 1294 of CanonicalIrreflexivity.lean)
   - Current approach is on the right track but needs completion
   - Alternative: direct cardinality argument (countably many atoms, MCS can't contain all)

6. **Prove `fresh_Gp_seed_consistent`** (line 1405 of CanonicalIrreflexivity.lean)
   - The Case 2 (G(q) ∉ L) is already done
   - Case 1 (G(q) ∈ L) needs the substitution lemma or alternative approach

7. **Replace all 54+ `canonicalR_irreflexive` call sites** with per-witness strictness
   - Pattern: instead of deriving contradiction from `CanonicalR M M`, use the specific construction's witness to show non-equality in quotient
   - This is the bulk of the work

8. **Delete `canonicalR_irreflexive_axiom`** (line 1492) — restores consistency

### Independent Work

9. **Phase 6**: `discreteImmediateSuccSeed_consistent_axiom` — separate from IRR, uses T-axiom directly

## Confidence Level

**High confidence** in the theoretical analysis:
- IRR unsoundness on reflexive frames is a textbook result (the argument is simple and airtight)
- The T-axiom approach for canonical reflexivity is standard (Goldblatt 1992, BdRV 2001)
- The per-witness strictness approach is sound in principle

**Medium confidence** in the implementation assessment:
- The 54+ call site count is from grep and may include comments/documentation
- The substitution lemma necessity depends on which approach is taken for `exists_strict_fresh_atom`
- The cardinality-based alternative for fresh atoms needs verification against the Lean formalization

**Key risk**: The per-witness strictness approach requires each of the 54+ call sites to have access to a specific strict witness. Some sites may use irreflexivity in ways that are harder to refactor (e.g., obtaining strictness from an arbitrary `CanonicalR` pair rather than from a constructed witness). These cases would need careful analysis.
