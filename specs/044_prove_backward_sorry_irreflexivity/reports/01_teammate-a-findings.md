# Teammate A Findings: Primary Implementation Approach for Task 44

- **Task**: 44 - Prove backward sorry and make irreflexivity derivable
- **Focus**: Primary implementation approach
- **Date**: 2026-03-23

---

## Key Findings

### 1. The Backward Sorry Location

The sorry is in `Boneyard/Metalogic/StagedConstruction/CanonicalRecovery.lean` (line 159):

```lean
theorem canonicalR_implies_canonicalTask_forward
    {u v : Set Formula}
    (h_mcs_u : SetMaximalConsistent u)
    (h_mcs_v : SetMaximalConsistent v)
    (h_R : ExistsTask u v) :
    ∃ n : Nat, n ≥ 1 ∧ CanonicalTask_forward u n v := by
  sorry
```

This is in the **Boneyard** (`Boneyard/Metalogic/StagedConstruction/`). The active codebase is `Theories/Bimodal/Metalogic/Bundle/`. The main infrastructure for CanonicalTask lives in `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean` and related files.

### 2. What ExistsTask M N Means

`ExistsTask M N` is defined in `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean`:
```lean
def ExistsTask (M M' : Set Formula) : Prop :=
  g_content M ⊆ M'
```
i.e., for all φ, if `G(φ) ∈ M` then `φ ∈ M'`.

`ExistsTask M N` is **NOT the same** as `Succ M N`. The Succ relation (defined in `SuccRelation.lean`) additionally requires the F-step condition:
```lean
def Succ (u v : Set Formula) : Prop :=
  g_content u ⊆ v ∧ f_content u ⊆ v ∪ f_content v
```

So `ExistsTask M N` → `∃ n ≥ 1, CanonicalTask_forward M n N` requires constructing a Succ-chain, NOT just a single Succ step. That's the core difficulty.

### 3. The Fundamental Gap

The backward direction is genuinely hard. `ExistsTask M N` only says `g_content M ⊆ N`. It does NOT guarantee that the F-obligations of M are resolved or deferred in N. The Succ relation requires **both** conditions.

**Example of why it's hard**: Suppose `F(φ) ∈ M` and `F(φ) ∉ N`. Is `φ ∈ N`? Only if the F-obligation is resolved. But with just `g_content M ⊆ N`, we have no guarantee about F-obligations at all.

The comment in CanonicalRecovery.lean states the construction requires:
1. `successor_exists` to construct each intermediate world
2. A convergence argument showing the chain eventually reaches v
3. F-nesting depth bounds for termination

### 4. The Current Approach: Successor Existence via Deferral Seeds

The active codebase (`SuccExistence.lean`) provides:
- `successor_exists`: For MCS u with F(⊤) ∈ u, there exists MCS v with Succ(u,v)
- This uses the **successor_deferral_seed** = `g_content(u) ∪ {φ ∨ F(φ) | F(φ) ∈ u}`
- The seed's consistency requires `successor_deferral_seed_consistent_axiom` (an axiom)

The key existing machinery:
- `bounded_witness` (CanonicalTaskRelation.lean:588): If F^n(φ) ∈ u, F^(n+1)(φ) ∉ u, and chain of n steps, then φ ∈ v
- `f_nesting_boundary` (mentioned as an axiom, task 36 targets proving it via Fischer-Ladner closure)
- `single_step_forcing` (SuccRelation.lean:233): Handles depth-1 cases

### 5. Why the Backward Direction Cannot Use a Single Succ Step

A key insight: `ExistsTask M N` can hold **without** `Succ M N`. The canonical model (CanonicalFrame.lean) constructs witnesses for `F(φ)` by taking `W = Lindenbaum({φ} ∪ g_content(M))`. This gives `ExistsTask M W` but does NOT give `Succ M W` because the F-step condition may fail.

Concretely: if `F(ψ) ∈ M` and `ψ ∉ W` and `F(ψ) ∉ W`, then the F-step condition `f_content M ⊆ W ∪ f_content W` fails.

### 6. The Semantics Mismatch (Critical Context)

**Task 29 introduced reflexive semantics**: `ExistsTask M M` is now **true** for all MCS M (via T-axiom: G(φ) → φ). This makes `ExistsTask` a preorder, NOT a strict order.

The irreflexivity axiom `existsTask_irreflexive_axiom` is explicitly marked as:
- **Deprecated** (inconsistent with reflexive semantics)
- **Axiom** (not proven)
- Used only in Layer 2 (order-theoretic enhancements, not completeness path)

This is documented in `CanonicalIrreflexivity.lean` as an "inconsistency ISOLATED to order-theoretic enhancements."

### 7. The Phase 7 Task: Make Irreflexivity Derivable

The plan was: once the backward sorry is proven, derive `existsTask_irreflexive` from `canonicalTask_irreflexive` (which is already proven via the axiom).

But this approach has a circularity problem: `canonicalTask_irreflexive` USES `existsTask_irreflexive_axiom`. So Phase 7 was about creating a non-axiom derivation.

From `CanonicalIrreflexivity.lean`:
```lean
-- canonicalTask_irreflexive_pos uses existsTask_irreflexive_axiom
-- canonicalTask_forward_pos_implies_canonicalR is PROVEN (no axiom)
-- So the chain: CanonicalTask M n M → ExistsTask M M → contradiction
-- needs existsTask_irreflexive_axiom at the end
```

The idea would be: if the backward sorry is proven, then:
1. `ExistsTask M M` (which is true by reflexivity) implies `∃ n ≥ 1, CanonicalTask M n M`
2. But `canonicalTask_forward_pos_implies_canonicalR` says CanonicalTask M n M → ExistsTask M M
3. So ExistsTask M M is derivable independently...

Wait — but ExistsTask M M is ALREADY PROVEN via reflexive semantics (existsTask_reflexive). The whole Task 26 completed the migration to reflexive semantics.

**Crucial insight**: Under reflexive semantics, `ExistsTask M M` is TRUE. The irreflexivity axiom contradicts this. The Phase 7 goal of "making irreflexivity derivable" is therefore **semantically impossible** under reflexive semantics.

### 8. Current State of CanonicalIrreflexivity.lean

The file at `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` shows:
- `existsTask_irreflexive_axiom` is defined as an `axiom` (custom, not proven)
- All theorems using it are marked `@[deprecated]`
- The `canonicalTask_irreflexive_pos/neg` theorems ARE proven but via the deprecated axiom
- Task 26's summary says Phase 7 was "SKIPPED - Blocked by Phase 6"

---

## Recommended Approach

### For Phase 6 (Backward Sorry)

The backward sorry in the Boneyard is in a **superseded file** that is being archived (task 43 is archiving StagedConstruction to Boneyard). The sorry is NOT on the publication path.

**However**, if the task is to prove `ExistsTask M N → ∃ n ≥ 1, CanonicalTask M n N` in the active codebase, the approach would be:

**Strategy**: Use f-nesting depth induction with the successor deferral seed construction.

Given `ExistsTask M N` (i.e., `g_content M ⊆ N`) and MCS M, N:

1. **Use seriality**: If F(⊤) ∈ M, use `successor_exists` to build a Succ-chain
2. **F-nesting depth**: For each F-obligation `F(φ) ∈ M`, build a successor where either φ is resolved or F(φ) is deferred
3. **Convergence**: The chain converges to N because g_content obligations persist (G-persistence), and F-obligations terminate by nesting depth bounds
4. **Key lemma needed**: `f_nesting_boundary_axiom` gives finite nesting depth, bounding chain length

The technical difficulty is that ExistsTask does not directly give a Succ step — we need to BUILD a chain by iterating `successor_exists`, showing eventually the chain "hits" N.

**This is provably impossible in general**: There's no reason why the successor deferral seed construction from M would eventually produce N specifically. It produces SOME successor, not necessarily N.

### Why the Backward Sorry May Be Unprovable

`ExistsTask M N` only says `g_content M ⊆ N`. This is a SEMANTIC accessibility fact. The backward direction would mean that semantic accessibility implies the existence of a syntactic Succ-chain reaching N specifically. But:

1. The successor deferral seed from M produces a NEW MCS, not necessarily N
2. There could be multiple MCS extending `{φ | G(φ) ∈ M}` — Lindenbaum produces one, but N is another
3. The chain could reach the "right g_content" but at a different MCS

**Conclusion**: The backward sorry `ExistsTask M N → ∃ n ≥ 1, CanonicalTask M n N` is likely **false** in the canonical model as constructed. Two distinct MCS can both extend g_content(M) without being connected by a Succ-chain.

### For Phase 7 (Irreflexivity)

Under reflexive semantics (T-axiom, introduced in Task 29), `ExistsTask M M` is **provably true**. The irreflexivity axiom is inconsistent with this. Therefore:

- `ExistsTask M M` cannot be derived as false from `canonicalTask_irreflexive`
- Phase 7 goal is semantically impossible under current semantics
- The axiom `existsTask_irreflexive_axiom` introduces inconsistency (documented in code)

**Recommended approach for Phase 7**: Instead of making irreflexivity derivable, the right move is to **delete** `existsTask_irreflexive_axiom` and all its dependents (Layer 2 order-theoretic enhancements). This is exactly what Task 26's TODO says should happen next (it's on the critical path in TODO.md).

---

## Evidence/Examples

### CanonicalRecovery.lean sorry (Boneyard, not active):
```lean
theorem canonicalR_implies_canonicalTask_forward
    {u v : Set Formula}
    (h_mcs_u : SetMaximalConsistent u)
    (h_mcs_v : SetMaximalConsistent v)
    (h_R : ExistsTask u v) :
    ∃ n : Nat, n ≥ 1 ∧ CanonicalTask_forward u n v := by
  sorry  -- BONEYARD: never on publication path
```

### Active codebase shows ExistsTask is reflexive, not irreflexive:
```lean
-- CanonicalIrreflexivity.lean
theorem existsTask_reflexive (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    ExistsTask M M  -- PROVEN (no axiom)

axiom existsTask_irreflexive_axiom :
    ∀ (M : Set Formula), SetMaximalConsistent M → ¬ExistsTask M M  -- AXIOM, contradicts above!
```

### canonicalTask_irreflexive is deprecated (uses inconsistent axiom):
```lean
@[deprecated "Under reflexive semantics (Task 29), ExistsTask is reflexive. This theorem uses the deprecated irreflexivity axiom."]
theorem canonicalTask_irreflexive (M : Set Formula) (n : Int)
    (h_mcs : SetMaximalConsistent M) (h_nonzero : n ≠ 0) :
    ¬CanonicalTask M n M
```

---

## Confidence Level

**High confidence** on the analysis.

**Key conclusions**:
1. The backward sorry in CanonicalRecovery.lean is in the Boneyard — it's a superseded file being archived (task 43)
2. The backward sorry as stated is likely **semantically false** in the canonical model as constructed
3. Phase 7 (make irreflexivity derivable) is **impossible** under reflexive semantics
4. The real task for "task 44" should be reframed: instead of proving backward sorry, the goal should be **deleting** the inconsistent `existsTask_irreflexive_axiom` and its Layer 2 dependents
5. The production path has ZERO sorries (`publication_path_sorries: 0` in TODO.md)

**Alternative reframing**: If the task is intended to work in the Boneyard's StagedConstruction (strict semantics), the backward sorry might be provable using the `f_nesting_boundary_axiom` + bounded witness construction. But even then, showing the chain reaches a SPECIFIC N is questionable — it can show a chain SOMEWHERE, not to N in particular.

The strongest feasible version of Phase 6 would be:
- For any MCS M with ExistsTask M N, construct a Succ-successor M' from M (using `successor_exists`)
- Show that g_content(M) ⊆ M' (from seed construction)
- Show ExistsTask M' N (using transitivity and the fact that g_content transfers)
- This gives a 1-step chain M→M' but does NOT mean M' = N

So the theorem as stated (reaching N specifically) appears unprovable without additional structure.
