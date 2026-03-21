# Teammate B Findings: Eliminating the CanonicalR "Distraction"

**Date**: 2026-03-21
**Focus**: Practical refactoring path — replacing CanonicalR with CanonicalTask throughout
**Session**: Task 26 continued research (report 18)

---

## Key Findings

### 1. CanonicalR Usage Map: All 69 Files Categorized

A full-codebase scan reveals CanonicalR appears in 69 Lean files. The uses fall into exactly four categories:

| Category | File Count | Pattern | Can be eliminated? |
|----------|-----------|---------|-------------------|
| **Primitive definition site** | 1 | `CanonicalR M N := g_content M ⊆ N` in `CanonicalFrame.lean` | Keep (definition source) |
| **F/P witness extraction** | ~25 | `∃ W, SetMaximalConsistent W ∧ CanonicalR M W ∧ psi ∈ W` | YES — replace with `∃ d > 0, CanonicalTask M d W` |
| **Irreflexivity/antisymmetry** | ~30 | `¬CanonicalR M M`, `CanonicalR M N ∧ CanonicalR N M → ⊥` | YES — replace with `∀ d > 0, ¬CanonicalTask M d M` |
| **Preorder definition (StagedPoint.le)** | ~15 | `p.mcs = q.mcs ∨ CanonicalR p.mcs q.mcs` | YES — replace with `∃ d ≥ 0, CanonicalTask p.mcs d q.mcs` |

**Critical observation**: CanonicalR appears in the `parametric_canonical_task_rel` definition as the case-dispatch target for `d > 0` and `d < 0`. This is the deepest form of the "distraction": the duration-parametric task relation still delegates to a duration-agnostic binary relation. The refactoring must sever this dependency.

### 2. The Distraction Analysis: What CanonicalR Obscures

The user's characterization of CanonicalR as a "Kripke semantics artifact" is precisely correct. Here is the technical diagnosis:

**What CanonicalR is**: A two-place relation `M N : Set Formula → Prop := g_content M ⊆ N`. This is the standard Kripke accessibility relation from modal logic — the "sees" relation where M "sees" N in the future.

**What CanonicalR obscures**: The *duration* component. When `canonical_forward_F` produces a witness W with `CanonicalR M W`, it gives us "M sees W in the future" — but says nothing about *how far* in the future. The duration is completely discarded. This is appropriate for the Lindenbaum construction (which is duration-agnostic by nature) but creates an impedance mismatch when the target framework is `TaskFrame D` (which is duration-explicit).

**The Kripke vs TaskFrame impedance**:

```
Kripke modal logic:   M sees W     (binary, no duration)
TaskFrame D:          M --d--> W   (ternary, duration explicit)
```

The `parametric_canonical_task_rel` bridges this gap by case-splitting on sign:
```lean
if d > 0 then CanonicalR M.val N.val    -- loses duration magnitude
else if d < 0 then CanonicalR N.val M.val
else M = N
```

This is the "duration-coarse" approximation: all positive durations are treated identically. The distraction is that CanonicalR is used here as if it were the fundamental concept, when really it is a derived concept (the positive-duration existential projection of CanonicalTask).

**What CanonicalTask makes explicit**: The sentence `CanonicalTask M n N` says "there is a Succ-chain of exactly n steps from M to N." This is a duration-precise statement that directly matches the TaskFrame interface. CanonicalR by contrast says "there exists some positive-duration chain from M to N" — the duration is hidden in an existential.

### 3. Can CanonicalR be Derived from CanonicalTask?

**Yes, in the discrete setting.** The derivation is:

```lean
def CanonicalR_derived (M N : Set Formula) : Prop :=
  ∃ n : Nat, n ≥ 1 ∧ CanonicalTask_forward M n N
```

This is provably equivalent to the current `CanonicalR M N` definition via:
- **Forward direction** (`CanonicalTask → CanonicalR`): Already proven in `CanonicalRecovery.lean` as `canonicalTask_forward_MCS_pos_implies_canonicalR`. Any Succ-chain of ≥1 steps implies `g_content M ⊆ N`.
- **Backward direction** (`CanonicalR → CanonicalTask`): Currently marked `sorry` in `CanonicalRecovery.lean`. This is the gap that needs to be filled.

The backward direction sorry reflects a genuine proof obligation: the Lindenbaum witness produced by `canonical_forward_F` gives `g_content M ⊆ W` but does not (yet) provide a Succ-chain from M to W. Filling this sorry requires showing that any CanonicalR witness can be connected via a Succ-chain — which is true because the Succ relation is defined to capture exactly the one-step CanonicalR step (the MCS constructed by `canonical_forward_F` satisfies the Succ condition by construction of the witness seed).

**In the dense setting**, the analog of CanonicalR is:
```lean
∃ q : ℚ, q > 0 ∧ DenseTask M q N
```
where DenseTask uses the Cantor isomorphism. This is equivalent to `tᴹ < tᴺ` in TimelineQuot ordering.

### 4. What Happens to the Irreflexivity Axiom Under Reformulation?

The current axiom:
```lean
axiom canonicalR_irreflexive_axiom :
    ∀ (M : Set Formula), SetMaximalConsistent M → ¬CanonicalR M M
```

Under the CanonicalTask reformulation, this becomes:
```lean
axiom canonicalTask_irreflexive_axiom :
    ∀ (M : Set Formula) (n : Nat), SetMaximalConsistent M →
    n ≥ 1 → ¬CanonicalTask_forward M n M
```

**Key insight**: These two formulations are provably equivalent, given the recovery theorem:
- `canonicalTask_irreflexive → canonicalR_irreflexive`: If `CanonicalR M M`, then by the backward direction (currently sorry), `∃ n ≥ 1, CanonicalTask M n M`, contradicting the CanonicalTask form.
- `canonicalR_irreflexive → canonicalTask_irreflexive`: If `CanonicalTask M n M` with n ≥ 1, then by `canonicalTask_forward_MCS_pos_implies_canonicalR`, `CanonicalR M M`, contradicting the CanonicalR form.

**Consequence**: The irreflexivity axiom can be equivalently stated in either language. The CanonicalTask form is more transparent for the TaskFrame development because it directly says "no positive-duration self-loop."

**Semantic justification preserved**: Under strict temporal semantics, `CanonicalTask M n M` with n ≥ 1 would require a Succ-chain of n forward steps from M back to M. Each Succ step satisfies `g_content u ⊆ v` (CanonicalR). Transitivity gives `g_content M ⊆ M`, which requires the T-axiom (`G(φ) → φ`), invalid under strict semantics. The semantic justification is unchanged — no time point is strictly later than itself.

### 5. The Negative Duration Symmetry and H/P Proofs

The converse symmetry of CanonicalTask:
```
CanonicalTask M n N ↔ CanonicalTask N (-n) M
```

gives us `CanonicalR_past` for free:
```lean
def CanonicalR_past_derived (M N : Set Formula) : Prop :=
  ∃ n : Nat, n ≥ 1 ∧ CanonicalTask_backward M n N
  -- equivalently: ∃ n : Nat, n ≥ 1 ∧ CanonicalTask_forward N n M
```

This means:
- `CanonicalR_past M N` = "N can reach M in at least 1 forward step"
- This is just `CanonicalR N M` restated — `CanonicalR_past M N ↔ CanonicalR N M`

In the codebase, `CanonicalR_past` is defined in `CanonicalFrame.lean:71` as `h_content M ⊆ N`. The converse reformulation:
```
CanonicalR_past_derived M N  ↔  CanonicalR_past M N
```
requires showing `h_content M ⊆ N ↔ ∃ n ≥ 1, CanonicalTask N n M`.

**For H/P direction proofs**: The negative duration symmetry simplifies proofs because `canonical_backward_H` (if H(φ) ∈ M and CanonicalR_past M W, then φ ∈ W) becomes:

```lean
-- In CanonicalTask terms:
canonical_backward_H_task : ∀ M W (h_mcs_M : ...) (h_mcs_W : ...) (n : Nat) (h_pos : n ≥ 1)
    (h_task_back : CanonicalTask W n M)  -- W reaches M in n forward steps
    (phi : Formula) (h_H : Formula.all_past phi ∈ M),
    phi ∈ W
```

This eliminates the separate `CanonicalR_past` concept by expressing past-direction lemmas as forward-direction CanonicalTask (with argument swapped). The net effect is a single primitive (`CanonicalTask`) covering both future and past, with sign encoding direction.

### 6. Refactoring Strategy: Concrete Steps

**Phase 1 — Fill the backward direction sorry** (prerequisite for everything else):

In `CanonicalRecovery.lean`, the theorem `canonicalR_implies_canonicalTask_forward` needs a proof. The strategy:
1. From `CanonicalR M N` (i.e., `g_content M ⊆ N`), show `Succ M W` for some W via `canonical_forward_F` applied to any formula `F(⊤) ∈ M` (seriality gives this).
2. Show that the W produced by `canonical_forward_F` satisfies `Succ M W` (not just `CanonicalR M W`).
3. For the full backward direction, one step suffices: `CanonicalTask M 1 N` when `Succ M N`.

**Warning**: This may not be provable without showing that CanonicalR witnesses can be taken to be Succ-witnesses — which requires the forward_F Lindenbaum witness to satisfy the full Succ condition, not just `g_content M ⊆ N`. Specifically, Succ additionally requires `f_content M ⊆ N ∪ f_content N` (the F-step condition). This is a non-trivial obligation.

**Phase 2 — Reformulate parametric_canonical_task_rel** (the core refactoring):

Replace:
```lean
def parametric_canonical_task_rel (M : ParametricCanonicalWorldState) (d : D)
    (N : ParametricCanonicalWorldState) : Prop :=
  if d > 0 then CanonicalR M.val N.val
  else if d < 0 then CanonicalR N.val M.val
  else M = N
```

With a CanonicalTask-based version (for D = ℤ):
```lean
def canonical_task_rel_int (M : ParametricCanonicalWorldState) (n : Int)
    (N : ParametricCanonicalWorldState) : Prop :=
  CanonicalTask M.val n N.val
```

This is duration-precise and directly matches the TaskFrame interface. For generic D, the parametric version is still needed, but the CanonicalTask form becomes the *canonical* (pun intended) instantiation for D = ℤ.

**Phase 3 — Eliminate CanonicalR from StagedPoint.le**:

In the staged construction, `StagedPoint.le` is defined as:
```
p ≤ q  ⟺  p.mcs = q.mcs ∨ CanonicalR p.mcs q.mcs
```

Replace with:
```
p ≤ q  ⟺  ∃ n : Int, n ≥ 0 ∧ CanonicalTask p.mcs n q.mcs
```

This makes the duration explicit in the preorder. Since `CanonicalTask M 0 M ↔ M = M` (identity), the n=0 case handles equality. The n>0 cases handle strict advancement.

**Phase 4 — Reformulate irreflexivity axiom** (final cleanup):

Replace `canonicalR_irreflexive_axiom` with `canonicalTask_irreflexive_axiom` as described in section 4. The CanonicalR form can then be *derived* as a theorem (via the forward direction of the recovery theorem, which is already proven).

### 7. What Is Gained by the Refactoring

| Benefit | Description |
|---------|-------------|
| **Conceptual clarity** | A single primitive (CanonicalTask) replaces two-place CanonicalR + three-place CanonicalTask |
| **Direct TaskFrame alignment** | `task_rel` is literally `CanonicalTask`; no duration-coarsening needed |
| **Irreflexivity becomes a theorem** | Once the backward sorry is filled, `¬CanonicalR M M` is derivable from `¬CanonicalTask M n M` and the recovery theorem |
| **Past direction unified** | CanonicalR_past disappears; past is just negative-duration CanonicalTask |
| **Duration visible throughout** | Proof obligations become more explicit about what duration a witness lives at |

---

## Distraction Analysis

### The Kripke Artifact Diagnosis

CanonicalR is a Kripke artifact in the precise sense that it is the product of standard canonical model construction for **modal** logic (specifically Kripke's completeness theorem for normal modal logics). In that setting:
- The canonical accessibility relation R(M, N) captures "M entails A, so N satisfies A"
- R is two-place (no duration)
- The completeness theorem produces a Kripke frame (W, R), not a TaskFrame (W, D, task_rel)

The bimodal tense logic being formalized here uses a **TaskFrame** — a structure native to the G/H tense operators interpreted over a *duration-typed* temporal order. TaskFrames are not Kripke frames. The canonical construction for TaskFrames should proceed directly via CanonicalTask (the native concept), not via CanonicalR (the Kripke concept borrowed from modal logic).

The "distraction" occurs because:
1. The codebase builds CanonicalR first (following the Kripke tradition)
2. Then constructs CanonicalTask on top of it (via Succ-chains that require CanonicalR)
3. Then uses `parametric_canonical_task_rel` which calls back to CanonicalR for the d≠0 cases

This circular dependency (CanonicalTask built from Succ which uses CanonicalR, then CanonicalTask recovers CanonicalR) is the architectural manifestation of the "distraction."

### What Clarity is Gained by Thinking Purely in CanonicalTask Terms

The clean picture becomes:

```
Primary concept:  CanonicalTask M n N  =  "N is n Succ-steps from M"
                  (n = 0: M = N; n > 0: forward chain; n < 0: backward chain)

Derived concepts:
  CanonicalR M N    := ∃ n > 0, CanonicalTask M n N    (existential projection)
  CanonicalR_past M N := ∃ n > 0, CanonicalTask N n M  (= CanonicalR N M)
  M ≤ N (preorder)  := ∃ n ≥ 0, CanonicalTask M n N   (non-negative reach)

Axiom (or proof once backward sorry filled):
  ∀ M n, n > 0 → ¬CanonicalTask M n M                 (no positive-duration self-loop)
```

The F/P witness lemmas then become:
```lean
-- Instead of: ∃ W, CanonicalR M W ∧ psi ∈ W
-- State as: ∃ W, (∃ n ≥ 1, CanonicalTask_forward M n W) ∧ psi ∈ W
-- Or, keeping CanonicalR as a defined abbreviation: ∃ W, ExistsTask M W ∧ psi ∈ W
```

The Lindenbaum construction still produces a witness without a specific duration — it gives CanonicalR. But we now know CanonicalR is a **derived** concept, not primitive. The axiom for irreflexivity is about CanonicalTask directly.

---

## Refactoring Strategy Summary

| Step | Action | Difficulty | Impact |
|------|--------|-----------|--------|
| 1 | Fill backward sorry in CanonicalRecovery.lean | High | Unlocks all downstream reformulations |
| 2 | Rename CanonicalR to ExistsTask with docstring clarifying it's derived | Low | Documentation only |
| 3 | Reformulate `parametric_canonical_task_rel` for D=ℤ to use CanonicalTask directly | Medium | Core refactoring |
| 4 | Replace StagedPoint.le's CanonicalR with CanonicalTask-based preorder | Medium | Dense construction |
| 5 | Reformulate irreflexivity axiom in CanonicalTask terms | Low | Conceptual clarity |
| 6 | Derive old CanonicalR irreflexivity as theorem via forward recovery | Low | Axiom reduction |

**Critical dependency**: Steps 3-6 all depend on Step 1 (filling the backward sorry). Without the sorry, CanonicalR cannot be proven equivalent to the existential over CanonicalTask, and the refactoring is incomplete.

---

## Confidence Level

**High confidence** on:
- The distraction diagnosis (CanonicalR is a Kripke artifact in a non-Kripke setting)
- The theoretical equivalence of CanonicalR and `∃ n ≥ 1, CanonicalTask M n N`
- The concrete refactoring steps (Phases 1-4)
- The negative duration symmetry giving CanonicalR_past for free

**Medium confidence** on:
- The feasibility of filling the backward sorry (it requires showing Lindenbaum witnesses satisfy the full Succ condition, which is a non-trivial proof obligation not yet attempted)
- Whether Step 3 (reformulating parametric_canonical_task_rel) can be done without breaking the truth lemma proofs (those proofs use the existing definition's case structure)

**Low confidence** on:
- Timeline for the refactoring (the backward sorry could be hard; see the warning in Phase 1 above)

---

## Summary

CanonicalR is a two-place duration-agnostic relation (`g_content M ⊆ N`) that originates from Kripke semantics for modal logic. In the TaskFrame setting — where the native concept is the three-place duration-explicit `CanonicalTask M n N` — CanonicalR is a "duration shadow" that discards the duration information. The refactoring path is:

1. Establish CanonicalTask as the primitive concept
2. Define CanonicalR as the derived concept `∃ n ≥ 1, CanonicalTask M n N`
3. Reformulate the irreflexivity axiom in CanonicalTask terms (equivalent formulation, but semantically cleaner)
4. Keep CanonicalR (renamed ExistsTask) as a convenient abbreviation for the F/P witness extraction lemmas, which are inherently duration-agnostic

The irreflexivity axiom survives the refactoring in the equivalent form `∀ M n, n > 0 → ¬CanonicalTask M n M`. Once the backward sorry in CanonicalRecovery.lean is filled, this can be derived from the CanonicalR form (or vice versa), making one of the two formulations redundant. Which to keep as primitive is a design choice — the CanonicalTask form is more honest to the TaskFrame framework.

---

## References

**Codebase files examined**:
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean:63` — CanonicalR definition
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean:167` — CanonicalTask definition
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/StagedConstruction/CanonicalRecovery.lean` — Recovery theorem (forward proven, backward sorry)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/ParametricCanonical.lean:85-89` — parametric_canonical_task_rel (the core distraction site)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean:1212` — axiom declaration
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCanonical.lean` — StagedPoint.le and irreflexivity usage

**Reference reports**:
- `specs/006_canonical_taskframe_completeness/reports/18_dense-three-place-task-relation.md` — Dense CanonicalTask construction
- `specs/006_canonical_taskframe_completeness/reports/19_role-in-representation-theorems.md` — Role in completeness pipeline
- `specs/026_remove_canonicalr_irreflexive_axiom/reports/05_team-research.md` — Prior synthesis on CanonicalR vs CanonicalTask
