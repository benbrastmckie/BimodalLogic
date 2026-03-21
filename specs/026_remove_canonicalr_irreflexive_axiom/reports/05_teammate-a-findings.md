# Teammate A Findings: CanonicalR vs CanonicalTask Relationship

**Date**: 2026-03-21
**Focus**: Exact relationship between CanonicalR and CanonicalTask, axiom meaning analysis
**Session**: Task 26 continued research (Fundamental definitions investigation)

---

## Key Findings

### 1. CanonicalR and CanonicalTask Are DIFFERENT Concepts

**Critical discovery**: The user's assumption that "CanonicalR is just the existential witness of CanonicalTask" is **incorrect**. These are two distinct relations in the codebase:

| Relation | Definition | Type | Meaning |
|----------|------------|------|---------|
| `CanonicalR M N` | `g_content M ⊆ N` | `Set Formula → Set Formula → Prop` | N is a **generic future** of M (any d > 0) |
| `CanonicalTask M d N` | Integer-indexed Succ-chain | `Set Formula → Int → Set Formula → Prop` | N is **exactly d steps** from M |

**From `/Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` (line 63)**:
```lean
def CanonicalR (M M' : Set Formula) : Prop :=
  g_content M ⊆ M'
```

**From `/Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean` (line 167)**:
```lean
def CanonicalTask (u : Set Formula) (n : Int) (v : Set Formula) : Prop :=
  match n with
  | Int.ofNat k => CanonicalTask_forward u k v
  | Int.negSucc k => CanonicalTask_backward u (k + 1) v
```

### 2. The Actual Relationship: CanonicalR ↔ ∃ n ≥ 1, CanonicalTask

**From `/Theories/Bimodal/Metalogic/StagedConstruction/CanonicalRecovery.lean`**:

**Forward direction (PROVEN)**:
```
CanonicalTask_forward u n v (n ≥ 1) → CanonicalR u v
```

**Backward direction (SORRY/UNPROVEN)**:
```
CanonicalR u v → ∃ n ≥ 1, CanonicalTask_forward u n v
```

**Quote from CanonicalRecovery.lean (lines 232-238)**:
> The relationship between CanonicalR and CanonicalTask is:
>
> **Forward (proven)**: `CanonicalTask_forward_MCS u n v → (u = v ∨ CanonicalR u v)`
>   For n >= 1: `CanonicalTask_forward_MCS u n v → CanonicalR u v`
>
> **Backward (sorry)**: `CanonicalR u v → ∃ n ≥ 1, CanonicalTask_forward u n v`
>   Requires constructing a Succ-chain from g_content inclusion.

### 3. What Does `canonicalR_irreflexive_axiom` Actually Say?

**The axiom**:
```lean
axiom canonicalR_irreflexive_axiom :
  ∀ M : Set Formula, SetMaximalConsistent M → ¬CanonicalR M M
```

**What it actually prohibits**:
```
¬(g_content M ⊆ M)
```

This says: "The formulas that M claims hold at ALL future times are NOT all contained in M itself."

**This is NOT the same as**: `∀ d > 0, ¬CanonicalTask M d M`

### 4. The User's Objection: Is It Valid?

**User's claim**: The axiom prohibits `CanonicalTask M d M` for all d, which seems false because a constant world history would have `M` leading back to `M`.

**Analysis**:

**Point 1**: The axiom is about `CanonicalR`, not `CanonicalTask`. They are different.

**Point 2**: Even for `CanonicalTask`, the relationship needs careful analysis:
- `CanonicalTask M 0 M` is **always true** (nullity identity axiom)
- `CanonicalTask M d M` for d > 0 would require a Succ-chain from M back to M

**Point 3**: Can `CanonicalTask M d M` hold for d > 0?

If there exists a Succ-chain `M → M₁ → M₂ → ... → Mₙ = M`, this would form a cycle. But:
- Each `Succ` step requires `g_content Mᵢ ⊆ Mᵢ₊₁`
- If the chain returns to M, then `CanonicalR M M` by transitivity
- The axiom says `CanonicalR M M` is FALSE

**Conclusion**: The axiom's **consequence** is that no Succ-chain can form a cycle. This is stronger than just "no single step from M to M."

### 5. The Constant History Objection: Does It Apply?

**User's scenario**: A world history where the valuation never changes, so after d > 0 steps, the same formulas are true.

**Analysis**:

**Key insight**: "Same formulas being true" is about semantic valuation, but `CanonicalTask` is a **syntactic** relation on MCSs (maximal consistent sets).

**The distinction**:
- **Semantic level**: A model where the world state W satisfies the same formulas at all times t
- **Syntactic level**: MCSs M₀, M₁, M₂, ... along a Succ-chain

**Even in a "constant" model**:
- M₀ contains `G(φ)` (φ holds at all future times)
- M₁ = Succ(M₀) must contain all of `g_content(M₀)` = {ψ : G(ψ) ∈ M₀}
- But `G(G(φ)) ∈ M₀` by Temporal 4 axiom, so `G(φ) ∈ M₁`
- M₁ also contains `φ` (since `G(φ) → φ` would hold under reflexive semantics, but NOT under strict semantics!)

**The catch**: Under **strict** semantics:
- `G(φ) ∈ M` means φ holds at all **strictly future** times
- M does NOT necessarily contain φ itself
- So `g_content(M) ⊆ M` would require every "always future" formula to hold **now**
- This is semantically FALSE: just because φ holds at all t' > t doesn't mean φ holds at t

### 6. The d = 0 Case

**Question**: What does `CanonicalTask M 0 N` mean?

**Answer**: It means `M = N` (nullity identity).

**From CanonicalTaskRelation.lean (lines 230-236)**:
```lean
@[simp]
theorem CanonicalTask_nullity_identity (u v : Set Formula) :
    CanonicalTask u 0 v ↔ u = v := by
  -- 0 : Int = Int.ofNat 0
  show CanonicalTask_forward u 0 v ↔ u = v
  exact CanonicalTask_forward_zero u v
```

**For `canonical_task_rel` in TaskFrame** (line 156-159):
```lean
def canonical_task_rel (M : CanonicalWorldState) (d : Int) (N : CanonicalWorldState) : Prop :=
  if d > 0 then CanonicalR M.val N.val
  else if d < 0 then CanonicalR N.val M.val
  else M = N  -- d = 0
```

**Implication**: `canonical_task_rel M 0 M` is **always true** (M = M). The irreflexivity concerns `d > 0` or `d < 0`, not `d = 0`.

---

## Recommended Approach

### Understanding the Axiom's Role

The axiom `canonicalR_irreflexive_axiom` encodes a **semantic truth** about strict temporal semantics:

1. **Semantically**: `G(φ)` at time t means φ holds at all s > t (strictly greater)
2. **For self-accessibility**: `g_content(M) ⊆ M` would require all "strictly future" truths to be "present" truths
3. **This is impossible**: The strict inequality s > t can never be satisfied by s = t

### The Axiom Is Correctly Formulated

The axiom is NOT claiming that time cannot loop back. It's claiming that the **canonical accessibility relation** (which models `g_content ⊆`) cannot be reflexive.

**Why this doesn't conflict with "constant histories"**:
- A constant semantic history has the same **truth values** at each time
- But the **MCSs** at each time are still **distinct** sets (they contain different modal formulas like `G^n(φ)`)
- The Succ relation connects M₀ to M₁ to M₂ etc. as a **chain**, not a cycle
- Even if valuations are constant, the MCSs form a strict order

---

## Evidence/Examples

### Example: Why CanonicalR M M Fails Under Strict Semantics

Consider MCS M with `G(p) ∈ M` (p will hold at all strictly future times).

For `CanonicalR M M` to hold, we need `g_content M ⊆ M`.

Since `G(p) ∈ M`, we have `p ∈ g_content M`.

For `g_content M ⊆ M`, we need `p ∈ M`.

**But under strict semantics**: `G(p) ∈ M` does NOT imply `p ∈ M`.

The formula `G(p)` only asserts that p holds at times **strictly after** now. The present is unconstrained.

Therefore: There exists an MCS M where `G(p) ∈ M` but `p ∉ M` (M asserts "p will hold in the future but doesn't hold now").

For this M: `p ∈ g_content M` but `p ∉ M`, so `g_content M ⊄ M`, so `¬CanonicalR M M`. ✓

### Example: CanonicalTask Chain Cannot Cycle

Suppose `CanonicalTask M d M` holds for some d > 0.

By the forward direction theorem: `CanonicalTask_forward_MCS M d M → CanonicalR M M`.

But `canonicalR_irreflexive_axiom` says `¬CanonicalR M M`.

Therefore: No such d exists. CanonicalTask chains are acyclic.

---

## Confidence Level

**HIGH** for the definitional analysis:
- CanonicalR ≠ ∃d. CanonicalTask (they are separate definitions)
- The axiom is about CanonicalR, not CanonicalTask directly
- The constant history objection confuses semantic and syntactic levels

**MEDIUM** for implications:
- The backward direction (CanonicalR → ∃ n. CanonicalTask) is still sorry
- The full relationship between the two concepts has gaps

---

## Sources

### Codebase Files
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` — CanonicalR definition (line 63)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean` — CanonicalTask definition (lines 96-170)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/StagedConstruction/CanonicalRecovery.lean` — Relationship between CanonicalR and CanonicalTask
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` — canonical_task_rel in TaskFrame (lines 156-159)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean` — Axiom declaration
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean` — Succ relation definition

### Related Research
- Previous teammate findings: `04_teammate-a-findings.md` (IRR techniques)
- Team synthesis: `04_team-research.md` (comprehensive analysis)
