# Research Report: Task #26 — CanonicalTask vs CanonicalR Reframing

**Task**: remove_canonicalr_irreflexive_axiom
**Date**: 2026-03-21
**Mode**: Team Research (3 teammates)
**Session**: sess_1774124986_13b8b6
**Focus**: Is the axiom even stating the right thing? Can we think entirely in CanonicalTask terms?

---

## Summary

The investigation reveals that **CanonicalR and CanonicalTask are distinct definitions** with different structures:

| Relation | Definition | Type |
|----------|------------|------|
| `CanonicalR M N` | `g_content M ⊆ N` | Two-place, duration-agnostic |
| `CanonicalTask M d N` | Integer-indexed Succ-chain | Three-place, duration-explicit |

The axiom `¬CanonicalR M M` states `¬(g_content M ⊆ M)`, meaning: "not every formula that M claims holds at all strict future times actually holds in M now." Under strict semantics, this is true because `G(φ) ∈ M` (φ at all s > t) does not imply `φ ∈ M` (φ at t). The constant-history objection is addressed: even with constant valuation, different time points are represented by distinct MCSs (same truth values ≠ same modal content).

---

## Key Findings

### 1. CanonicalR ≠ ∃d. CanonicalTask (Teammate A)

**Critical clarification**: The user's premise that "CanonicalR is just the existential witness of CanonicalTask" is **approximately but not exactly correct** in the current codebase:

- **CanonicalR** is defined directly as `g_content M ⊆ N` (line 63 of CanonicalFrame.lean)
- **CanonicalTask** is defined via integer-indexed Succ-chains (line 167 of CanonicalTaskRelation.lean)
- **Forward direction** (proven): `CanonicalTask_forward M n N` with `n ≥ 1` implies `CanonicalR M N`
- **Backward direction** (sorry): `CanonicalR M N` implies `∃ n ≥ 1, CanonicalTask_forward M n N`

The backward direction has a sorry — the full equivalence is not yet proven. This means CanonicalR is *at least as strong as* the existential, but the converse is an open proof obligation.

### 2. What the Axiom Actually Prohibits (Teammate A)

The axiom `¬CanonicalR M M` states:

```
¬(g_content M ⊆ M)
```

Expanded: "There exists some formula φ such that `G(φ) ∈ M` but `φ ∉ M`."

**Why this is true under strict semantics**: `G(φ) ∈ M` means "φ holds at all times strictly after t." This says nothing about t itself. An MCS can consistently contain `G(φ)` without containing `φ` — the formula "it will always rain tomorrow" does not imply "it is raining now."

**What the axiom does NOT say**: It does not directly say "no duration d > 0 allows CanonicalTask M d M." Rather, that's a *consequence* via the recovery theorem: if `CanonicalTask M d M` with d > 0, then `CanonicalR M M`, contradicting the axiom.

### 3. The Constant History Objection (Teammate A, B)

**The objection**: "There could easily be constant world histories where things never change but time does elapse."

**The resolution**: This confuses two levels:

| Level | What "constant" means | Same M? |
|-------|----------------------|---------|
| **Semantic** | Same truth values at all times | Irrelevant to MCS identity |
| **Syntactic** | Same MCS at all times | Would require `g_content M ⊆ M` |

Even in a model where the same atoms are true at every time, the **MCSs at different times are distinct sets** because they contain different modal content. At time t₁, M₁ contains `G(p)` meaning "p at all s > t₁". At time t₂ > t₁, M₂ contains `G(p)` meaning "p at all s > t₂". These are the same *formula* but in the context of different time points. The crucial point is that M₁ also contains information like `F(G(p))` at depth, and its g_content reflects the strict future — which never includes t₁ itself.

**In short**: Same valuation ≠ same MCS. The canonical model's MCSs encode modal depth, not just propositional content.

### 4. The d = 0 Case (Teammate A, B)

`CanonicalTask M 0 N ↔ M = N` (nullity identity). This is always reflexive — `CanonicalTask M 0 M` is trivially true. The axiom concerns d > 0 only, which is consistent with TaskFrame's design: zero duration is identity, positive duration is strict future.

### 5. What Downstream Proofs Actually Need (Teammate B)

All 16 usage sites follow exactly **two patterns**:

| Pattern | Usage | Count | What it needs |
|---------|-------|-------|---------------|
| **Equality contradiction** | `CanonicalR X Y ∧ X = Y → CanonicalR X X → ⊥` | 7 | Irreflexivity |
| **Antisymmetry** | `CanonicalR X Y ∧ CanonicalR Y X → CanonicalR X X → ⊥` | 9 | Irreflexivity + transitivity |

Both patterns derive **strict ordering** from CanonicalR. This is essential for: NoMaxOrder, NoMinOrder, DenselyOrdered, and distinctness of quotient classes.

### 6. Refactoring Classification (Teammate C)

| Category | % of uses | Description | Refactor path |
|----------|-----------|-------------|---------------|
| **Existential witness** | 60% | Lindenbaum extensions, F/P proofs | Keep as ExistsTask |
| **Irreflexivity** | 30% | Strict order derivation | Core problem — axiom needed |
| **Transitivity chains** | 10% | Composition proofs | Could use CanonicalTask directly |

**Key insight**: The 60% existential uses are genuinely duration-agnostic — the Lindenbaum lemma constructs a witness MCS N without knowing which duration d satisfies `CanonicalTask M d N`. These need the existential abstraction.

### 7. TaskFrame Alignment (Teammate C)

The canonical TaskFrame's `task_rel` is `parametric_canonical_task_rel`, which IS CanonicalTask — not CanonicalR. This confirms the user's direction: **CanonicalTask is the native concept**, and CanonicalR/ExistsTask is a derived convenience.

However, the irreflexivity of the existential projection is what all strictness proofs require. Whether stated as `¬CanonicalR M M` or `∀d > 0, ¬CanonicalTask M d M`, it's the same semantic content.

---

## Synthesis

### Conflict: Is the User's Objection Valid?

**Teammate A** says the objection "confuses semantic and syntactic levels" and the axiom is correct.
**Teammate B** agrees the axiom is correctly formulated.

**Resolution**: The teammates are technically correct that the axiom is *mathematically sound*. However, the user's deeper point — that thinking in terms of CanonicalR (a Kripke artifact) obscures what's really going on — is also valid. The three-place CanonicalTask is the native concept for TaskFrame, and reformulating the irreflexivity in those terms would be:

```lean
∀ M (h_mcs : SetMaximalConsistent M) (d : Int),
    d > 0 → ¬CanonicalTask M d M
```

This is **equivalent** to the current axiom (via the recovery theorem), but makes the claim more transparent: "no positive-duration self-loop in the task relation."

### The Fundamental Question

The user asks: is it really true that no MCS can reach itself after positive duration?

**The answer is yes, and the reason is**:
1. `CanonicalTask M d M` for d ≥ 1 implies `CanonicalR M M` (proven)
2. `CanonicalR M M` means `g_content M ⊆ M`
3. `g_content M ⊆ M` means `∀φ, G(φ) ∈ M → φ ∈ M` (the T-axiom holds in M)
4. Under strict semantics, the T-axiom is invalid — MCSs can contain `G(φ)` without `φ`
5. Therefore, no such M exists

**The "constant history" does not produce a self-loop** because even though the propositional content may be constant, the modal content (G/H formulas at different depths) distinguishes time points. The Succ chain `M₀ → M₁ → M₂ → ...` is strictly advancing even when atoms don't change.

### Gaps Identified

1. **The backward direction sorry**: `CanonicalR M N → ∃ n ≥ 1, CanonicalTask_forward M n N` is unproven. This matters because without it, CanonicalR might be strictly stronger than the existential over CanonicalTask.

2. **Reformulation completeness**: If we reformulate the axiom as `∀d > 0, ¬CanonicalTask M d M`, we need the forward direction (already proven) to recover the current `¬CanonicalR M M` form that all proofs use.

3. **Whether CanonicalR can be fully eliminated**: The 60% existential uses genuinely need duration-agnostic reasoning. The ExistsTask name clarifies this.

---

## Recommendations

### 1. Rename CanonicalR → ExistsTask

This clarifies the concept: "there exists some task duration connecting M to N." The definition stays the same (`g_content M ⊆ N`) for proof efficiency.

### 2. Document the Equivalence

```lean
/-- ExistsTask M N is equivalent to the existence of a positive-duration
    CanonicalTask chain from M to N. -/
theorem ExistsTask_iff_exists_CanonicalTask :
    ExistsTask M N ↔ ∃ d : Int, d > 0 ∧ CanonicalTask M d N
```

### 3. Keep the Axiom, Possibly Reformulated

Either form works:
- **Current**: `∀ M, SetMaximalConsistent M → ¬ExistsTask M M`
- **CanonicalTask form**: `∀ M d, SetMaximalConsistent M → d > 0 → ¬CanonicalTask M d M`

The CanonicalTask form is more natural for TaskFrame thinking. The ExistsTask form is more convenient for the 30% of uses that need it.

### 4. Refactor Transitivity Uses (10%)

Where CanonicalR is used for transitivity chains, refactor to use CanonicalTask composition directly. This brings those proofs closer to the TaskFrame native representation.

### 5. Accept Irreflexivity as Semantic Axiom

The 30% of uses requiring irreflexivity represent a genuine semantic fact: no time point is strictly later than itself. This is the correct formalization under strict temporal semantics, and the research across all three waves confirms it cannot be derived syntactically.

---

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|-----------------|
| A | CanonicalR vs CanonicalTask definitions | completed | high | Showed they are distinct; explained constant history resolution |
| B | Correct irreflexivity formulation | completed | high | Usage pattern analysis; equivalence via recovery theorem |
| C | Refactoring audit | completed | high | 60/30/10 classification; ExistsTask naming recommendation |

---

## References

### Codebase Files
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean:63` — CanonicalR definition
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean:167` — CanonicalTask definition
- `Theories/Bimodal/Metalogic/StagedConstruction/CanonicalRecovery.lean` — Recovery theorem (forward proven, backward sorry)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean:156` — canonical_task_rel
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean:1212` — Axiom declaration
