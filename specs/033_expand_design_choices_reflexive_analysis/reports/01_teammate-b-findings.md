# Teammate B Research Findings: Representation Theorem Challenges

**Date**: 2026-03-22
**Session**: sess_1774212234_48e1ac
**Task**: 33 - expand_design_choices_reflexive_analysis
**Focus**: Representation theorem challenges for irreflexive vs reflexive semantics

---

## Key Findings

1. **The irreflexivity axiom is now DEPRECATED and semantically FALSE** under the current codebase (reflexive semantics). `canonicalR_irreflexive_axiom` coexists with the proven theorem `canonicalR_reflexive`, creating an acknowledged inconsistency that is being phased out.

2. **The Gabbay IRR rule's role differs fundamentally** between the two semantics. Under strict semantics, IRR is needed as an external meta-rule to establish completeness for irreflexive frames; under reflexive semantics, IRR is used only as a proof technique for consistency arguments — the T-axiom does the heavy lifting for canonical reflexivity.

3. **Frame class collapse is real and confirmed**: Under reflexive semantics, all four extension axioms (DN, DF, SF, SP) are either trivially valid or subsumed. The three-variant completeness structure (Base / Dense / Discrete) collapses to a single architecture, which the current codebase now implements.

4. **The canonical model antisymmetry problem is the active blocker** (Phase 5/6 of Task 29). The transition from "irreflexivity → contradiction" to "antisymmetry → MCS equality → contradiction" requires new infrastructure at ~25 call sites.

5. **Irreflexivity is not modally definable** — confirmed by bisimulation argument (Blackburn-de Rijke-Venema). This is the mathematical root cause of all the proof complexity in the strict semantics case.

---

## Canonical Model Analysis

### Definition of CanonicalR

The canonical accessibility relation is:
```
CanonicalR M N  :=  g_content(M) ⊆ N
```
where `g_content(M) = {φ | G(φ) ∈ M}`.

**Under strict semantics** (`G φ` at t means `∀ s > t, φ(s)`):
- `G(φ) ∈ M` encodes φ holding at all strictly future times
- `CanonicalR M M` would require `g_content(M) ⊆ M`
- But: if `G(φ) ∈ M` then φ must hold at t, and the T-axiom `G(φ) → φ` is NOT an axiom
- Irreflexivity (`¬CanonicalR M M`) is "obviously semantically true" but not derivable from the axioms

**Under reflexive semantics** (`G φ` at t means `∀ s ≥ t, φ(s)`):
- The T-axiom `temp_t_future: G(φ) → φ` IS an axiom (valid by `s = t ≥ t`)
- `canonicalR_reflexive` is a **proven theorem**: MCS closure under modus ponens with `G(φ) → φ` gives `g_content(M) ⊆ M`
- The "irreflexivity" claim is now FALSE and flagged as deprecated

**Proof of `canonicalR_reflexive`** (lines 1206-1212 of CanonicalIrreflexivity.lean):
```lean
theorem canonicalR_reflexive (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    CanonicalR M M := by
  intro phi h_G_phi
  have h_t_axiom : (Formula.all_future phi |>.imp phi) ∈ M :=
    theorem_in_mcs h_mcs (.axiom _ _ (.temp_t_future phi))
  exact SetMaximalConsistent.implication_property h_mcs h_t_axiom h_G_phi
```

### FMCS Coherence Conditions

The FMCS structure (FMCSDef.lean) uses reflexive inequalities throughout:
- `forward_G`: G formulas at t propagate to times t' ≥ t (inclusive)
- `backward_H`: H formulas at t propagate to times t' ≤ t (inclusive)
- Comment: "Design Evolution: TM logic uses REFLEXIVE temporal operators with T-axioms"

Under strict semantics, these conditions would use strict inequalities (< for G-forward, > for H-backward), requiring separate handling of the boundary case at t = t'.

### Why Irreflexivity Is Not Modally Definable

The bisimulation argument (Blackburn-de Rijke-Venema, Chapter 3.3) establishes that no modal formula characterizes exactly the class of irreflexive frames. The argument:

1. Any formula φ valid on all irreflexive frames must be valid on ALL frames — since bisimilar frames satisfy the same modal formulas, and every irreflexive frame is bisimilar to a frame that has a reflexive loop.

2. Specifically: given an irreflexive frame F = (W, R), construct F' = (W × {0,1}, R') where R'((w,i), (v,j)) iff R(w,v). The "unfolding" includes self-loops. F and F' are modally bisimilar, so any modal formula true in F is true in F'.

3. Therefore no modal formula can distinguish "irreflexive" from "reflexive" — any axiom holding on all irreflexive frames also holds on frames with reflexive loops.

**Consequence for completeness**: The canonical model constructed from an arbitrary consistent set of axioms will satisfy CanonicalR M M under reflexive semantics. Under strict semantics, CanonicalR M M can only be ruled out by adding the Gabbay IRR meta-rule or an external axiom.

### The Gabbay IRR Rule

The Gabbay IRR (Irreflexivity) rule (Gabbay 1981) states:
```
If ⊢ (p ∧ H(¬p)) → A  where p ∉ atoms(A),  then ⊢ A
```

**Purpose**: Provide a syntactic substitute for the non-modally-definable property of irreflexivity. The rule's "naming" intuition: at any time t, we can introduce a fresh atom p that marks "now" (p is true now) with H(¬p) meaning "p was never true before". In an irreflexive frame, this is consistent and allows indirect reasoning about the current moment.

**Implementation in the codebase** (CanonicalIrreflexivity.lean):

The IRR rule is used CONTRAPOSITIVELY in the naming set consistency proof. The argument pattern:
1. Assume naming set `{p-free formulas of M} ∪ {atom(p), H(¬p)}` is inconsistent
2. Some finite subset derives ⊥
3. By deduction theorem: `⊢ (atom(p) ∧ H(¬atom(p))) → (L_af.foldr (·.imp ·) ⊥)` where L_af are p-free
4. By IRR (p doesn't appear in the p-free conclusion): `⊢ (L_af.foldr (·.imp ·) ⊥)`
5. This theorem is in M (by MCS closure), so ⊥ ∈ M — contradicting M's consistency

This establishes naming set consistency without requiring global freshness of p.

**Key difference in roles**:
- Under strict semantics: IRR is required to ESTABLISH irreflexivity of the canonical model (via naming set → extend to M' → contradiction)
- Under reflexive semantics: IRR is used only internally in consistency arguments (the T-axiom provides the crucial path instead)

### Antisymmetry vs. Irreflexivity

Under reflexive semantics, the workhorse theorem in `CanonicalIrreflexivityAxiom.lean` is:

```lean
-- canonicalR_antisymmetric_strict: mutual accessibility is impossible
theorem canonicalR_antisymmetric_strict (M N : Set Formula)
    (hM : SetMaximalConsistent M) (hN : SetMaximalConsistent N)
    (h_MN : CanonicalR M N) (h_NM : CanonicalR N M) : False :=
  canonicalR_irreflexive M hM (canonicalR_transitive M N M hM h_MN h_NM)
```

This still invokes `canonicalR_irreflexive` (which is the axiom-based deprecated theorem). The proper replacement under fully reflexive semantics would require proving:
```
CanonicalR M N ∧ CanonicalR N M → M = N
```
This is a genuine antisymmetry statement (as a set-equality fact) that requires the Gabbay naming-set technique adapted for equality rather than contradiction.

---

## Completeness Proof Comparison

### Under Strict (Irreflexive) Semantics

**Required infrastructure** (complex):

1. **Gabbay IRR meta-rule** — must be added to the proof system or used as an external schema
2. **Naming set construction** — `atomFreeSubset(M, p) ∪ {p, H(¬p)}` for freshness
3. **Global freshness** — atom p must be fresh for the entire set M (not just a finite subset), which requires `Atom` type with infinite supply
4. **Two-MCS construction** — extend naming set to M' ≠ M, derive contradiction between M and M'
5. **Three completeness theorems** — separate proofs for Base/Dense/Discrete frame classes

**Historical failures** (documented in DirectIrreflexivity.lean):
- Path A (direct F-proof) is provably impossible: any theorem psi is in every MCS, so ¬psi cannot also be in M
- The naming set must be extended to a DIFFERENT MCS M' — the contradiction requires comparing M with M'
- String-type atoms prevented global freshness (every string appears in some tautology)

**Current status under strict semantics**: `canonicalR_irreflexive_axiom` — an unproven Lean axiom that bypasses the proof requirement. The 1254-line CanonicalIrreflexivity.lean contains the IRR infrastructure but the theorem is ultimately declared as an axiom.

**Why 1254 lines?** The file contains:
- `atomFreeSubset` and `namingSet` definitions
- `exists_fresh_for_finite_list` (freshness for finite subsets only)
- IRR-contrapositive argument for `naming_set_consistent`
- Extensive analysis of why direct proofs fail (Phase 2 analysis)
- The deprecated axiom at line 1240
- The new `canonicalR_reflexive` proof at line 1206

### Under Reflexive Semantics

**Required infrastructure** (simpler):

1. **T-axioms** — `temp_t_future: G(φ) → φ` and `temp_t_past: H(φ) → φ` (already valid axioms)
2. **No IRR rule needed** for canonical model reflexivity — it follows directly from T-axiom + MCS closure
3. **Single completeness theorem** — base axioms suffice, no frame class separation
4. **ParametricRepresentation** — works uniformly for all D

**Blocking issue** (Phase 5 of Task 29): The 25 call sites using `canonicalR_irreflexive` to derive contradictions need replacement with antisymmetry-based arguments. The antisymmetry proof itself requires new infrastructure.

### Frame Class Collapse

Under reflexive semantics, the following axioms (currently in the `Discrete` extension category) become trivially valid on ANY linear order:

| Axiom | Trivial proof under reflexive semantics |
|-------|----------------------------------------|
| **DN**: `GG(φ) → G(φ)` (density) | Taking r = s = t in `∀r≥t, ∀s≥r, φ(s)` gives `∀s≥t, φ(s)` by reflexivity |
| **DF**: `(F⊤ ∧ φ ∧ H(φ)) → F(H(φ))` (discreteness_forward) | s = t witnesses F(Hφ) since H(φ)(t) holds and t ≥ t |
| **SF**: `G(φ) → F(φ)` (seriality_future) | T-axiom: `G(φ) → φ`, so `φ(t)` witnesses `F(φ)` |
| **SP**: `H(φ) → P(φ)` (seriality_past) | T-axiom: `H(φ) → φ`, so `φ(t)` witnesses `P(φ)` |

**Evidence from codebase**: In the Axioms.lean file, DN (density) and the discrete axioms (discreteness_forward, seriality_future, seriality_past) are STILL classified as `Dense` and `Discrete` respectively rather than `Base`. This classification persists from the strict semantics era. Under a fully consistent reflexive semantics refactoring, these should all be reclassified as Base (or removed as redundant with T-axiom consequences).

**Important nuance**: The axioms are STILL IN THE SYSTEM. Their documentation comments still contain "under strict semantics" descriptions. The frame class collapse means:
- Valid_base ⊇ Valid_dense ∪ Valid_discrete (the strict hierarchy reverses)
- All three completeness variants prove the SAME thing (no distinction)
- The DovetailedBuild and discrete constructions become unnecessarily complex machinery for what reflexive semantics handles trivially

### The Three-Variant Completeness Problem

Under strict semantics, the codebase has three completeness theorems:
1. `BaseCompleteness`: for all linear orders (without density/discreteness)
2. `DenseCompleteness`: for densely ordered linear frames
3. `DiscreteCompleteness`: for discretely ordered linear frames (Z-like)

Each uses different frame conditions and different sets of axioms. The completeness pipeline:
- DovetailedBuild/DensityFrameCondition → DenseCompleteness (Rat-indexed)
- DiscreteSuccSeed/StagedExecution → DiscreteCompleteness (Int-indexed)
- CanonicalFMCS → BaseCompleteness (Int-indexed)

Under reflexive semantics, all three collapse to one: since DN, DF, SF, SP are all trivially valid, the three "extensions" add nothing. A single completeness proof over any linear order suffices.

---

## Evidence / References

### Direct Code Evidence

1. **`CanonicalIrreflexivity.lean` line 1240**: `axiom canonicalR_irreflexive_axiom` — the unproven axiom
2. **`CanonicalIrreflexivity.lean` line 1206**: `theorem canonicalR_reflexive` — the proven theorem, showing CanonicalR M M holds via T-axiom
3. **`CanonicalIrreflexivity.lean` line 1228**: Comment: "Under reflexive semantics (Task 29), the irreflexivity axiom is SEMANTICALLY FALSE"
4. **`FMCSDef.lean` line 95**: "forward_G: G formulas propagate to future times (reflexive)" and "The coherence conditions use REFLEXIVE inequalities (<= not <)"
5. **`Axioms.lean` lines 279-304**: `temp_t_future` and `temp_t_past` are base axioms, valid because reflexive semantics uses ≤
6. **`DirectIrreflexivity.lean`**: Exhaustive analysis showing Path A (direct proof from CanonicalR M M → ⊥) is impossible — any theorem is in every MCS
7. **`IRRSoundness.lean`**: Gabbay IRR rule soundness proof uses product frame construction to handle strict irreflexive frames
8. **`specs/029_switch_to_reflexive_gh_semantics/summaries/04_phases-5-6-status.md`**: Confirms Phase 5/6 are BLOCKED waiting for antisymmetry infrastructure

### Theoretical References Confirmed

- Blackburn-de Rijke-Venema Chapter 3.3: irreflexivity not modally definable (bisimulation argument)
- Gabbay 1981: IRR rule for irreflexive completeness
- The file comment in CanonicalIrreflexivity.lean: "van Benthem 1983, Blackburn-de Rijke-Venema 2001 Chapter 3.3"

### Task History

- Task 991: Switched to strict semantics (created the axiom-based approach)
- Task 967: Previously used reflexive semantics with T-axiom approach
- Task 29: Current return to reflexive semantics (partially complete — phases 1-4 done, 5-6 blocked)
- Tasks 18, 24: Dense/Discrete completeness theorems (now potentially redundant under reflexive)

---

## Confidence Level

**Overall**: HIGH

The evidence is directly from the codebase with line references. The frame class collapse analysis is corroborated by both the theoretical analysis (report 06) and the Axioms.lean classification structure. The blocking issue in Phase 5/6 is explicitly documented in the phase status report.

**Sub-area confidence**:
- Canonical model behavior under each semantics: HIGH (code is explicit)
- Frame class collapse: HIGH (trivial proofs available for each axiom)
- Gabbay IRR role and implementation: HIGH (file-level documentation is clear)
- Antisymmetry as the replacement for irreflexivity: HIGH (pattern described, but the proof itself is the blocker)
- Three-variant → one-variant collapse: HIGH (confirmed by both code classification and theoretical analysis)
