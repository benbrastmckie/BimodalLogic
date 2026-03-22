# Teammate A: CanonicalTask Theory Analysis

**Date**: 2026-03-22
**Task**: 29 — switch_to_reflexive_gh_semantics
**Focus**: CanonicalTask as primary notion in Task Semantics; implications for reflexive G/H proof architecture

---

## Key Findings

### 1. CanonicalTask vs CanonicalR (ExistsTask)

**CanonicalR (the secondary notion, better called ExistsTask)**:

```lean
def CanonicalR (M M' : Set Formula) : Prop :=
  g_content M ⊆ M'
```

This is a *duration-blind* binary relation. It records "M sees M' in the future" but carries no information about how far in the future. It corresponds semantically to "there exists a task of some positive duration from M to M'." For this reason, the user's suggestion to rename it `ExistsTask` is mathematically apt: it is the existential projection of the three-place relation onto the positive half-line.

**CanonicalTask (the primary notion)**:

```
CanonicalTask(u, 0, v)      ⟺  u = v
CanonicalTask(u, n+1, v)    ⟺  ∃ w, Succ(u, w) ∧ CanonicalTask(w, n, v)
CanonicalTask(u, -(n+1), v) ⟺  CanonicalTask(v, n+1, u)
```

This is a *duration-precise* ternary relation `MCS → ℤ → MCS → Prop`. It is built from the atomic **Succ** relation:

```
Succ(u, v)  ⟺  g_content(u) ⊆ v   (G-persistence)
            ∧   f_content(u) ⊆ v ∪ f_content(v)   (F-step)
```

where `f_content(u) = {φ | F φ ∈ u}`.

**Why CanonicalTask is primary**:

1. **Direct semantic match**: The `TaskFrame` structure requires `task_rel : WorldState → D → WorldState → Prop`. CanonicalTask directly instantiates this for `D = ℤ` without a duration pipeline. CanonicalR requires a separate (and currently axiom-dependent) duration characterization.

2. **CanonicalR is derived**: `CanonicalR(u, v) ⟺ ∃ n ≥ 1, CanonicalTask(u, n, v)`. The binary relation is the positive transitive closure of Succ. It is a corollary, not a primitive.

3. **F-obligation tracking**: The F-step condition in Succ tracks existential obligations explicitly. CanonicalR ignores these entirely, which is why it cannot support the single-step forcing theorem or bounded witness results.

4. **Duration-precise truth lemma**: With CanonicalTask:
   ```
   G φ ∈ u  ⟺  ∀ v, ∀ n > 0, CanonicalTask(u, n, v) → φ ∈ v
   F φ ∈ u  ⟺  ∃ v, ∃ n > 0, CanonicalTask(u, n, v) ∧ φ ∈ v
   ```
   These mirror the semantic definitions exactly. With CanonicalR, only the sign of the duration is captured.

---

### 2. Three-Place Task Relation Structure

The three-place structure `T(M, φ, N)` — using φ as the duration slot — is `CanonicalTask : Set Formula → ℤ → Set Formula → Prop`.

**Atomic unit: Succ**

Succ is built from two content extractors:

| Extractor | Definition | Already exists? |
|-----------|-----------|----------------|
| `g_content(u)` | `{φ \| G φ ∈ u}` | Yes (`TemporalContent.lean`) |
| `h_content(u)` | `{φ \| H φ ∈ u}` | Yes (`TemporalContent.lean`) |
| `f_content(u)` | `{φ \| F φ ∈ u}` | New (2-line definition) |
| `p_content(u)` | `{φ \| P φ ∈ u}` | New (2-line definition) |

The Succ condition adds F-step to the existing G-persistence condition of CanonicalR. This single addition enables:

- **Single-step forcing theorem**: If `F φ ∈ u` and `FF φ ∉ u`, then every Succ-successor v has `φ ∈ v`.
- **Bounded witness**: If `Fⁿ φ ∈ u` but `Fⁿ⁺¹ φ ∉ u`, then φ is reached within n Succ-steps.

**TaskFrame axiom compliance** (all three satisfied by definition):

1. *Nullity identity*: `CanonicalTask(u, 0, v) ↔ u = v` — by definition.
2. *Forward compositionality*: Succ-chains of lengths x and y concatenate to a chain of length x+y — by induction on x.
3. *Converse*: `CanonicalTask(u, d, v) ↔ CanonicalTask(v, -d, u)` — by definition of the negative case.

**Reflexivity**: `CanonicalTask(u, 0, u)` holds because the nullity case is `u = u`. The three-place relation is reflexive at duration zero by definition, with no need for any axiom or proof.

**Successor existence** (the non-trivial ingredient): Under discrete axioms (base + DF + seriality), for any MCS u with `F⊤ ∈ u`, there exists v with `Succ(u, v)`. The seed is `g_content(u) ∪ {φ ∨ Fφ | Fφ ∈ u}`. The DF axiom guarantees this seed is consistent; Lindenbaum's lemma extends it to an MCS.

---

### 3. Implications for Reflexive Semantics

The central insight for Task 29 is that **the three-place CanonicalTask relation sidesteps the entire reflexivity/irreflexivity debate for CanonicalR**.

**Why the debate arose**: Task 29 switches to reflexive G/H semantics, which adds T-axioms `G φ → φ` and `H φ → φ`. Under these axioms, `CanonicalR M M` holds (since `g_content(M) ⊆ M` follows from the T-axiom). The existing proofs relied on `canonicalR_irreflexive_axiom` (later `canonicalR_strict` theorem), which becomes false. This broke NoMaxOrder, NoMinOrder, DenselyOrdered, and the Antisymmetrization quotient structure.

**Why CanonicalTask avoids this**:

1. **Reflexivity at zero is definitional**: `CanonicalTask(u, 0, u)` is `u = u`. No T-axiom or antisymmetry is needed.

2. **Strict ordering is duration-based**: In the integer-duration framework, `n = 0` means identity and `n > 0` means strictly forward. The question "is M before N?" becomes "does `CanonicalTask(M, n, N)` hold for some n > 0 with N ≠ M?" Duration carries the strictness, not the relation itself.

3. **NoMaxOrder via Succ existence**: To show every quotient class has something strictly above it, one only needs to show `Succ(M, N)` for some N with N ≠ M (or equivalently, N not in the same Antisymmetrization class as M). Under discrete axioms, seriality (`F⊤ ∈ M`) gives successor existence. The successor N produced by the deferral seed `g_content(M) ∪ {φ ∨ Fφ | Fφ ∈ M}` is generally distinct from M because F-obligations create differences in f_content.

4. **The fresh-G-formula approach (from Report 07) is compatible**: Report 07 identified Option D as the cleanest fix for the quotient proofs: use seed `g_content(M) ∪ {G(p)}` for a fresh atom p to produce W with `G(p) ∈ W` and `p ∉ M`, giving `¬CanonicalR W M`. In the CanonicalTask framework, this becomes: W is produced by a one-step Succ construction (the fresh G(p) forces the G-persistence condition to carry p across), so `CanonicalTask(M, 1, W)` holds, and since p ∉ M but p ∈ g_content(W), `CanonicalTask(W, 1, M)` fails. This gives strict ordering in the quotient.

**The core shift**: Under the CanonicalTask framework, the antisymmetry question for the Antisymmetrization quotient becomes: "For the Succ-chain witness W, does `CanonicalTask(W, n, M)` fail for all n > 0?" This is the same as "does g_content propagate back to M through any Succ-chain?" The fresh atom p argument shows it does not when p ∉ M.

---

### 4. Recommended Refactoring Direction

The Task 29 proof architecture should shift from CanonicalR-centric to CanonicalTask-centric in the following way:

**Immediate (for Phase 5-6 blockers)**:

The current blocker is proving strict ordering properties (NoMaxOrder, NoMinOrder, DenselyOrdered) for the Antisymmetrization quotient under reflexive semantics. The CanonicalTask framework suggests:

1. **Define `f_content` and `Succ`** (2 trivial definitions in `TemporalContent.lean` and a new `SuccRelation.lean`). These are independent of any axiom changes and carry no proof obligations.

2. **Replace the canonicalR_irreflexive_axiom usage** with a per-witness `¬CanonicalR W M` proof using the fresh atom approach (Option D from Report 07). This uses the Succ construction (the seed `g_content(M) ∪ {G(p)}` is exactly a Succ seed with one extra G-formula).

3. **Restate NoMaxOrder, NoMinOrder, DenselyOrdered** in terms of Succ-successor existence, which is provable directly from seriality/density axioms without needing to reason about the absence of intermediates (the covering lemma problem that blocked Task 974).

**Medium-term (for full architecture refactoring)**:

1. Define `CanonicalTask` inductively from `Succ` in a new `CanonicalTask.lean`.
2. Prove the three TaskFrame axioms.
3. Replace `parametric_canonical_task_rel` (the duration-coarse relation currently used for truth lemma wiring) with `CanonicalTask` for the discrete case.
4. The truth lemma becomes: `G φ ∈ u ↔ ∀ v, ∀ n > 0, CanonicalTask(u, n, v) → φ ∈ v` — a direct semantic transcription.
5. The `canonicalR_irreflexive_axiom` and related Gabbay infrastructure in `CanonicalIrreflexivity.lean` (1254 lines) can be removed or reduced to a single derivation from CanonicalTask.

**What remains hard**: Successor existence (proving the deferral seed is consistent under DF + seriality) is the main proof obligation. This replaces the covering lemma challenge with a more tractable one: the seed is consistent because DF prevents F-obligations from being vacuously un-deferrable. The argument is analogous to the standard Lindenbaum construction.

---

## Summary Table

| Aspect | CanonicalR (ExistsTask) | CanonicalTask (primary) |
|--------|------------------------|------------------------|
| Arity | Binary: `MCS → MCS → Prop` | Ternary: `MCS → ℤ → MCS → Prop` |
| Duration | Implicit (sign only) | Explicit (integer distance) |
| Reflexivity under T-axiom | `CanonicalR M M` holds (problematic) | `CanonicalTask M 0 M` holds (definitional, harmless) |
| Irreflexivity at n>0 | Breaks under T-axiom | Strict for n>0 with distinct MCS (by Succ structure) |
| Antisymmetry | FALSE in general | Not needed — duration carries strictness |
| TaskFrame compliance | Requires duration pipeline (axiomatized) | Direct (3 definitional checks) |
| F-obligation tracking | None | Via F-step condition |
| Covering lemma | Needed for SuccOrder construction | Bypassed (Succ is defined directly) |
| Relationship | Derived: `CanonicalR(u,v) ↔ ∃ n≥1, CanonicalTask(u,n,v)` | Primary |

---

## Confidence Level

**High** for the mathematical theory (sections 1-2): The CanonicalTask construction is fully worked out in the Task 6 reports with complete proofs. The TaskFrame axiom compliance, Single-Step Forcing Theorem, and CanonicalR recovery are all rigorously proven.

**Medium-high** for the implication for Task 29 (sections 3-4): The argument that CanonicalTask sidesteps the reflexivity/antisymmetry debate is mathematically sound. The specific claim that the fresh-G-formula approach (Option D from Report 07) integrates cleanly with the Succ construction is well-supported but hasn't been mechanically verified in Lean yet.

**Medium** for the effort estimates in section 4: Successor existence (the deferral seed consistency) is characterized as "hard" in the Task 6 reports, and the interaction with the existing BFMCS/bundle infrastructure may surface unexpected complications.

The key actionable insight is: **defining `f_content` and `Succ` is trivial and risk-free, and these two definitions enable the fresh-G-formula approach to work for the Phase 5 NoMaxOrder/NoMinOrder blockers without needing to prove the full CanonicalTask theory**.
