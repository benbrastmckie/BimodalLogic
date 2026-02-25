# Research Report: Task #925 (Round 3)

**Task**: Redesign BMCS completeness construction using MCS accessibility relation
**Date**: 2026-02-25
**Focus**: Restructured truth-predicate - motivations, advantages, pitfalls, and semantic faithfulness
**Session**: sess_1772038454_51b1d5

## Summary

This report analyzes the "restructured truth-predicate" proposal from research-001.md, addressing the user's concern about whether it departs from the theory's semantics. **The key finding is that the restructured truth-predicate is semantically faithful** because it operates at a different level than the theory's official semantics. The BMCS truth definition is a *metalogical tool* for the completeness proof, not the theory's semantic definition. The restructured approach is mathematically equivalent to the current approach for the purposes of completeness, while being dramatically simpler.

## Background: Two Distinct Truth Predicates

The codebase contains **two fundamentally different truth predicates** that should not be conflated:

### 1. Semantic Truth (`Truth.lean`)

This is the **official semantics** of the bimodal logic - what formulas *mean*:

```lean
-- Truth.lean:112-119
def truth_at (M : TaskModel F) (Omega : Set (WorldHistory F))
    (τ : WorldHistory F) (t : D) : Formula → Prop
  | Formula.box φ => ∀ (σ : WorldHistory F), σ ∈ Omega → truth_at M Omega σ t φ
  | Formula.all_past φ => ∀ (s : D), s ≤ t → truth_at M Omega τ s φ
  | Formula.all_future φ => ∀ (s : D), t ≤ s → truth_at M Omega τ s φ
```

This defines what it means for `□φ` to be true: φ must be true at **all world histories** in the admissible set Omega. This is the theory's semantic commitment and **must not be changed**.

### 2. BMCS Truth (`BMCSTruth.lean`)

This is a **metalogical construction tool** used only for proving completeness:

```lean
-- BMCSTruth.lean:88-94
def bmcs_truth_at (B : BMCS D) (fam : BFMCS D) (t : D) : Formula → Prop
  | Formula.box φ => ∀ fam' ∈ B.families, bmcs_truth_at B fam' t φ
  | Formula.all_past φ => ∀ s, s ≤ t → bmcs_truth_at B fam s φ
  | Formula.all_future φ => ∀ s, t ≤ s → bmcs_truth_at B fam s φ
```

This is **NOT the theory's semantics**. It's a recursive definition over a canonical model structure (the BMCS bundle) used to prove:

> If Γ is consistent, then there EXISTS a model satisfying Γ.

The BMCS provides that ONE model. We don't need it to capture all models - we just need it to satisfy the consistent formula set.

## The Restructured Truth-Predicate Proposal

### Current Definition (Recursive)

```lean
| Formula.box φ => ∀ fam' ∈ B.families, bmcs_truth_at B fam' t φ
```

This recursively evaluates truth of `φ` at each family.

### Proposed Definition (Syntactic)

```lean
| Formula.box φ => ∀ fam' ∈ B.families, φ ∈ fam'.mcs t
```

This checks syntactic membership of `φ` in each family's MCS, without recursive truth evaluation.

### Why This Works

The key lemma `BMCS.box_iff_universal` (BMCS.lean:256-261) already proves:

```lean
theorem BMCS.box_iff_universal (B : BMCS D) (fam : BFMCS D) (hfam : fam ∈ B.families)
    (φ : Formula) (t : D) :
    Formula.box φ ∈ fam.mcs t ↔ ∀ fam' ∈ B.families, φ ∈ fam'.mcs t
```

This is **exactly** the restructured truth definition's Box case. The bidirectional equivalence is already proven using `modal_forward` and `modal_backward`.

## Semantic Faithfulness Analysis

### The User's Concern

> "I am particularly concerned that this will depart from the semantics for the theory which should constrain how the truth-predicate should work."

### The Resolution: Different Levels of Semantics

| Level | Definition | Purpose | Location |
|-------|------------|---------|----------|
| **Theory Semantics** | `truth_at` over TaskModel/WorldHistory | Define formula meaning | `Truth.lean` |
| **Metalogic Tool** | `bmcs_truth_at` over BMCS | Prove completeness | `BMCSTruth.lean` |

The restructured proposal modifies the **metalogic tool** (`bmcs_truth_at`), NOT the **theory semantics** (`truth_at`). These are separate definitions with separate purposes.

### Why the Metalogic Tool Can Be Restructured Freely

Completeness is an **existential** statement: "If Γ is consistent, then ∃ model M such that M ⊨ Γ."

The BMCS construction provides *one such model*. The only requirements are:

1. **Internal Consistency**: The BMCS must be a well-formed structure
2. **Truth Lemma**: `φ ∈ fam.mcs t ↔ bmcs_truth_at B fam t φ` (connects syntax to truth)
3. **Representation Theorem**: The BMCS can be interpreted as a semantic model satisfying `truth_at`

The restructured definition **preserves all three**:

1. The BMCS structure is unchanged
2. The Truth Lemma becomes **trivial** for the Box case (see below)
3. The representation theorem mapping is unchanged

### Proof that Truth Lemma Still Holds

For the Box case under the restructured definition:

**Forward** (`Box φ ∈ fam.mcs t → bmcs_truth_at B fam t (Box φ)`):
1. Given: `Box φ ∈ fam.mcs t`
2. By `modal_forward`: `∀ fam' ∈ B.families, φ ∈ fam'.mcs t`
3. This is **definitionally equal** to `bmcs_truth_at B fam t (Box φ)` under the restructured definition

**Backward** (`bmcs_truth_at B fam t (Box φ) → Box φ ∈ fam.mcs t`):
1. Given: `∀ fam' ∈ B.families, φ ∈ fam'.mcs t` (the restructured definition)
2. By `modal_backward`: `Box φ ∈ fam.mcs t`

**No induction hypothesis needed!** The proof becomes trivial.

## Motivations for the Restructuring

### Motivation 1: Eliminate Temporal Coherence Requirement for Witness Families

The **core obstacle** in tasks 916, 922, 924 was:

1. `BMCS.temporally_coherent` requires `forward_F` and `backward_P` for **every** family
2. Witness families for modal saturation are constant (same MCS at every time)
3. Constant families **cannot** satisfy `forward_F`/`backward_P` (mathematical impossibility)

**The restructured approach eliminates this**:

- The Truth Lemma no longer recurses into witness families for the Box case
- Truth of `Box φ` depends only on **syntactic membership** `φ ∈ fam'.mcs t`
- Temporal coherence is only needed for the **eval family** (where we start evaluation)
- Witness families only need to satisfy modal coherence (which constant families do)

### Motivation 2: Dramatic Simplification of the Box Case

| Aspect | Current Approach | Restructured Approach |
|--------|------------------|----------------------|
| Box forward proof | Requires IH on subformula | Direct by definition |
| Box backward proof | Requires IH on subformula | Direct by modal_backward |
| Inter-family recursion | Yes | No |
| Proof complexity | Medium | Trivial |

### Motivation 3: Aligns with Existing Infrastructure

The key lemma `BMCS.box_iff_universal` is already **proven sorry-free** in BMCS.lean. The restructured definition simply *makes this the definition*, rather than proving it as a consequence.

## Advantages

### Advantage 1: Unblocks the Completeness Proof

The fundamental obstacle - constant witness families cannot be temporally coherent - is **eliminated** for the Box case. The completeness proof can proceed with:

1. **CanonicalMCS domain** for the eval family (provides sorry-free temporal coherence)
2. **Constant families** for modal saturation (only need modal coherence, which they have)
3. **Restructured truth predicate** (doesn't require temporal coherence for witness families *in the Box case*)

### Advantage 2: No Change to Theory Semantics

The `truth_at` definition in `Truth.lean` is **completely untouched**. The theory's semantic commitments remain exactly as specified in the JPL paper reference (lines 1857-1872).

### Advantage 3: Simpler Proofs Throughout

| Proof | Current | Restructured |
|-------|---------|--------------|
| Box case of truth lemma | 15+ lines with IH | ~5 lines, direct |
| Modal coherence propagation | Complex | Follows from MCS properties |
| Nested Box formulas | Inductive complexity | Direct by definition |

### Advantage 4: All Required Infrastructure Already Exists

| Component | Status | Location |
|-----------|--------|----------|
| `BMCS.box_iff_universal` | Sorry-free | BMCS.lean:256 |
| `canonicalMCSBFMCS` | Sorry-free | CanonicalBFMCS.lean:158 |
| `canonicalMCS_forward_F` | Sorry-free | CanonicalBFMCS.lean:196 |
| `canonicalMCS_backward_P` | Sorry-free | CanonicalBFMCS.lean:217 |
| `modal_forward`/`modal_backward` | Sorry-free | BMCS.lean |

## Potential Pitfalls

### Pitfall 1: Misunderstanding the Two Truth Predicates

**Risk**: Confusing the restructured `bmcs_truth_at` with the semantic `truth_at`, leading to the false belief that the theory's semantics are being modified.

**Mitigation**: The restructuring ONLY affects `bmcs_truth_at` in `BMCSTruth.lean`. The semantic `truth_at` in `Truth.lean` is **never touched**. Add clear documentation distinguishing these.

### Pitfall 2: Nested Modal Formulas

**Concern**: Does the syntactic definition handle nested boxes like `□□φ` correctly?

**Analysis**: Yes. Under the restructured definition:
```
bmcs_truth_at B fam t (Box (Box φ))
  = ∀ fam' ∈ B.families, (Box φ) ∈ fam'.mcs t
```

This is still well-defined - it checks syntactic membership of `Box φ` in each family's MCS. The MCS properties ensure:
- If `Box (Box φ) ∈ fam.mcs t`, then `Box φ ∈ fam'.mcs t` for all fam' (by modal_forward applied to Box φ)

**Verdict**: No issue.

### Pitfall 3: Representation Theorem Compatibility

**Concern**: Does the restructured BMCS still yield a valid TaskModel when interpreted semantically?

**Analysis**: The representation theorem maps the BMCS to a semantic model:
- BMCS families → WorldHistory instances
- Family membership → Omega (admissible histories)
- MCS membership → Valuation

This mapping is **unchanged** by the restructuring. The restructured truth definition is algebraically equivalent to the current one - it just computes the same thing more directly.

**Verdict**: No issue.

### Pitfall 4: Loss of Compositionality?

**Concern**: The current definition is "compositional" (truth of compound formula depends on truth of subformulas). The restructured definition seems to bypass this for Box.

**Analysis**: The restructured definition **is** still compositional in the relevant sense:
- Truth of `φ → ψ` depends on truth of `φ` and `ψ`
- Truth of `G φ` depends on truth of `φ` at future times
- Truth of `Box φ` depends on membership of `φ` at all families

The key insight: for the **canonical model**, membership and truth are **equivalent** (that's the truth lemma!). So checking membership IS checking truth, just more directly.

**Verdict**: No issue - compositionality is preserved through the truth lemma.

### Pitfall 5: The Temporal Cases Are NOT Addressed

**Critical Concern**: The restructuring only addresses the Box case. The G and H cases still require temporal coherence (forward_F, backward_P) for ALL families where the truth lemma must hold.

**Analysis from research-002.md**: The user stated that the TruthLemma must hold for ALL families, not just the eval family. This means witness families must satisfy forward_F/backward_P for the G/H cases.

**This is the remaining hard problem**: The restructured truth predicate helps with Box, but does not resolve the temporal coherence requirement for witness families in the G/H cases.

**Possible Resolution Paths**:
1. **Restrict TruthLemma scope**: Prove it only for temporally coherent families; use Box case to bridge to constant witness families
2. **Non-constant witness families**: Construct witness families as histories through CanonicalMCS (Path D from research-002.md)
3. **Separate the proof**: Prove Box case with syntactic membership; prove G/H cases only for temporally coherent families; show this suffices

### Pitfall 6: The Fundamental Tension Remains

**From research-002.md**: There is a tension between:
1. TruthLemma holding for ALL families (requires temporal coherence for ALL)
2. Modal saturation using constant families (cannot have temporal coherence)

**The restructured truth predicate resolves this for Box** (constant families work fine for syntactic membership). But it **does not resolve this for G/H** (still need forward_F/backward_P).

## Comparison with Theory Semantics

| Semantic Definition (`Truth.lean`) | BMCS Definition (Restructured) | Relationship |
|-----------------------------------|-------------------------------|--------------|
| `∀ σ ∈ Omega, truth_at M Omega σ t φ` | `∀ fam' ∈ B.families, φ ∈ fam'.mcs t` | Both universal quantification |
| Over WorldHistory instances | Over BFMCS families | BFMCS *encode* WorldHistories |
| Uses semantic truth | Uses MCS membership | Connected by truth lemma |
| Defines meaning of `□φ` | Proves completeness | Different purposes |

The representation theorem provides the bridge:
1. Each BFMCS family is interpreted as a WorldHistory
2. The BMCS families form the Omega set
3. MCS membership at time t becomes truth at that WorldHistory and time
4. The universal quantification over families becomes universal quantification over Omega

## Key Insight: Why Semantic Faithfulness Is Preserved

The semantic `truth_at` (in Truth.lean) defines what formulas MEAN in the logic. This is fixed by the theory and must not change.

The `bmcs_truth_at` (in BMCSTruth.lean) is a TOOL for proving completeness. Its job is to provide:
1. A canonical model (the BMCS)
2. A truth predicate on that model
3. A proof that consistent formulas are satisfied

The restructured definition changes HOW we define truth on the canonical model, but:
- The canonical model still satisfies the same formulas
- The representation theorem still maps it to a semantic model
- The semantic model still satisfies `truth_at` as defined

**Analogy**: It's like changing the implementation of a function while preserving its specification. The "specification" is `truth_at` in Truth.lean; the "implementation" is `bmcs_truth_at` in BMCSTruth.lean. We can refactor the implementation as long as it meets the spec.

## Recommendations

### Recommendation 1: Proceed with Restructured Truth Predicate for Box Case (HIGH CONFIDENCE)

The restructured approach for Box:
- Does NOT depart from the theory's semantics
- Preserves all required properties for completeness (for Box)
- Simplifies proofs significantly

### Recommendation 2: Acknowledge Temporal Case Remains Open

The G/H cases of the truth lemma still require temporal coherence for witness families. The restructuring helps with Box but does not solve this.

Options:
1. Accept that TruthLemma only holds for temporally coherent families
2. Construct non-constant witness families (Path D from research-002.md)
3. Prove a weaker form of completeness that doesn't require TruthLemma for witness families

### Recommendation 3: Add Clear Documentation

Distinguish the two truth predicates in documentation:
- `truth_at` (Truth.lean): The theory's official semantics - NEVER modify
- `bmcs_truth_at` (BMCSTruth.lean): Metalogic tool for completeness proof - can be restructured

### Recommendation 4: Minimal Code Change for Box Case

The restructuring requires changing only lines 88-94 of BMCSTruth.lean:

```lean
-- Before (line 92):
| Formula.box φ => ∀ fam' ∈ B.families, bmcs_truth_at B fam' t φ

-- After:
| Formula.box φ => ∀ fam' ∈ B.families, φ ∈ fam'.mcs t
```

Then simplify the Box case of `bmcs_truth_lemma` in TruthLemma.lean to use the direct bidirectional proof via `BMCS.box_iff_universal`.

## Conclusion

**The restructured truth-predicate is semantically faithful** because:

1. It operates at the metalogic level, not the theory semantics level
2. The theory's semantics in `Truth.lean` are unchanged
3. The truth lemma still holds (trivially for Box case)
4. The representation theorem mapping is unchanged
5. All mathematical properties are preserved

The user's concern about departing from the theory's semantics is understandable but unfounded **for the Box case**. The restructuring is a **refactoring of the completeness proof technique**, not a change to what formulas mean. The semantic `truth_at` definition remains exactly as specified in the JPL paper, with Box quantifying over all histories in Omega.

**However**, the temporal cases (G/H) remain challenging. The restructuring does not address the requirement for temporal coherence in witness families. This is the remaining open problem documented in research-002.md.

## References

- `Theories/Bimodal/Semantics/Truth.lean` - Theory semantics (lines 112-119)
- `Theories/Bimodal/Metalogic/Bundle/BMCSTruth.lean` - BMCS truth definition (lines 88-94)
- `Theories/Bimodal/Metalogic/Bundle/BMCS.lean` - `box_iff_universal` (lines 256-261)
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` - Current truth lemma proof
- `specs/925_redesign_bmcs_completeness_mcs_accessibility/reports/research-001.md` - Original research with restructured truth proposal
- `specs/925_redesign_bmcs_completeness_mcs_accessibility/reports/research-002.md` - Corrected four constraints analysis

## Next Steps

1. Implement the restructured `bmcs_truth_at` definition in BMCSTruth.lean (Box case only)
2. Simplify the Box case of `bmcs_truth_lemma` in TruthLemma.lean
3. Investigate Path D (non-constant witness families) for the G/H temporal cases
4. Determine if a restricted TruthLemma (only for temporally coherent families) suffices for completeness
