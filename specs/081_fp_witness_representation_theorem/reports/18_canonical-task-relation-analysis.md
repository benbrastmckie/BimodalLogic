# Report 18: D-Parametric Canonical Task Relation — Team Analysis

**Date**: 2026-04-02
**Agents**: Explorer (codebase), Research (reports), Algebraic Critic, Bilateral Critic
**Scope**: Comprehensive analysis of all approaches to defining the canonical task relation with D parametric, including properties established toward defining a canonical frame.

---

## 1. Executive Summary

Five candidate definitions for the canonical task relation have been analyzed across four dimensions: (1) which TaskFrame axioms they satisfy, (2) whether they generalize from Int to parametric D, (3) whether they carry duration information, and (4) whether they support the completeness proof (specifically forward_F).

**Key finding**: The D-parametric generalization of the canonical task relation is algebraically **solved** — it exists in `ParametricCanonical.lean` with all three TaskFrame axioms proven sorry-free for arbitrary `D : Type* [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`. The blocker is NOT the frame definition but the construction of TemporalCoherentFamilies (forward_F/backward_P) to populate it.

**Critical structural insight**: Every g_content-based canonical task relation is inherently **duration-degenerate** — `task_rel(M, d₁, N)` is identical to `task_rel(M, d₂, N)` for all positive d₁, d₂. Duration sensitivity lives in the WorldHistory/Omega structure, not in task_rel. This is a consequence of TM's syntax having no duration-parameterized temporal operators.

---

## 2. The TaskFrame Axioms (Reference)

From `TaskFrame.lean` (line 93):

```lean
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  WorldState : Type
  task_rel : WorldState → D → WorldState → Prop
  nullity_identity : ∀ w u, task_rel w 0 u ↔ w = u
  forward_comp : ∀ w u v x y, 0 ≤ x → 0 ≤ y →
                 task_rel w x u → task_rel u y v → task_rel w (x + y) v
  converse : ∀ w d u, task_rel w d u ↔ task_rel u (-d) w
```

---

## 3. Candidate Definitions Analyzed

### Candidate A: Conjunctive Trichotomy (RECOMMENDED — PROVEN)

**Definition** (equivalent to existing `ParametricCanonical.lean:84`):

```
task_rel(M, d, N) :=
  (d > 0 → ExistsTask M.val N.val) ∧
  (d < 0 → ExistsTask N.val M.val) ∧
  (d = 0 → M = N)
```

where `ExistsTask M N := g_content M ⊆ N` and `g_content M = {φ | G(φ) ∈ M}`.

**Implementation**: In the codebase, the if-then-else form is used (requires decidable ordering):

```lean
def parametric_canonical_task_rel (M : ParametricCanonicalWorldState) (d : D)
    (N : ParametricCanonicalWorldState) : Prop :=
  if d > 0 then ExistsTask M.val N.val
  else if d < 0 then ExistsTask N.val M.val
  else M = N
```

**Axiom verification**:

| Axiom | Status | Proof Strategy |
|-------|--------|----------------|
| nullity_identity | PROVEN | At d=0, both `d > 0` and `d < 0` are false; remaining clause is `M = N` |
| forward_comp | PROVEN | Case split on (x=0,y=0), (x=0,y>0), (x>0,y=0), (x>0,y>0). The (x>0,y>0) case uses `canonicalR_transitive` which depends on **temp_4: G(φ) → G(G(φ))** |
| converse | PROVEN | Symmetry of the definition under d ↦ -d: `d > 0 ↔ -d < 0`, `d < 0 ↔ -d > 0`, `d = 0 ↔ -d = 0` |

**D-parametricity**: The only group-theoretic facts used are:
- `0 ≤ x ∧ 0 ≤ y ∧ x + y = 0 → x = 0 ∧ y = 0` (any ordered group)
- `d > 0 ↔ -d < 0` (any ordered group)
- `0 ≤ x ∧ 0 ≤ y → 0 ≤ x + y` (any ordered monoid)
- Trichotomy `d > 0 ∨ d = 0 ∨ d < 0` (any linear order)

All hold in any `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`.

**Duration sensitivity**: NONE. For any d₁ > 0 and d₂ > 0, `task_rel(M, d₁, N) = task_rel(M, d₂, N) = ExistsTask M.val N.val`. This is inherent — see Section 5.

**File**: `Theories/Bimodal/Metalogic/Algebraic/ParametricCanonical.lean` (lines 84-205, sorry-free)


### Candidate B: Non-Strict Inequality Form

**Definition**:
```
task_rel(M, d, N) := (0 ≤ d → g_content(M) ⊆ N) ∧ (d ≤ 0 → g_content(N) ⊆ M)
```

**Axiom verification**:

| Axiom | Status | Issue |
|-------|--------|-------|
| nullity_identity | **FAILS** | At d=0: gives `g_content(M) ⊆ N ∧ g_content(N) ⊆ M`, which does NOT imply `M = N` (g_content is a proper subset of M in general). Conversely, `M = N` implies `g_content(M) ⊆ M`, which requires the T-axiom `G(φ) → φ` to hold as set membership — this IS available via `temp_t_future` and `existsTask_reflexive`, BUT the equivalence `g_content(M) ⊆ N ∧ g_content(N) ⊆ M ↔ M = N` is still false. |
| forward_comp | N/A | |
| converse | N/A | |

**Verdict**: REJECTED. Nullity fails in both directions for non-identical MCS with matching g_content.


### Candidate C: If-Then-Else (Current Int Version)

**Definition**: Same as A but uses `if-then-else` syntax.

```lean
if d > 0 then ExistsTask M.val N.val
else if d < 0 then ExistsTask N.val M.val
else M = N
```

**Difference from A**: Requires `Decidable (d > 0)` and `Decidable (d < 0)`. For `Int` and `Rat`, decidability is automatic. For `Real`, decidability is not constructively available.

**Resolution**: In Lean 4 with `Classical.dec`, this is always available. The conjunctive form A avoids the issue entirely and is logically equivalent classically.

**File**: `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` (lines 156-159, Int-specific)

**Verdict**: WORKS for Int. Generalization requires either Classical.dec or switching to form A.


### Candidate D: Duration-Transfer (WorldState = D)

**Definition**: 
```
WorldState := D
task_rel w d u := w + d = u
```

**Axiom verification**:

| Axiom | Status | Proof Strategy |
|-------|--------|----------------|
| nullity_identity | PROVEN | `w + 0 = u ↔ w = u` by `add_zero` |
| forward_comp | PROVEN | `w + x = u ∧ u + y = v → w + (x+y) = v` by `add_assoc` |
| converse | PROVEN | `w + d = u ↔ u + (-d) = w` by group theory |

**Advantage**: Algebraically clean. Compositionality is literally `add_assoc`.

**Fatal flaw**: Conflates world states with time indices. WorldState should be MCS (truth configurations), not temporal positions. A history becomes `τ(t) = t₀ + t` — a trivial translation that carries no logical content. The valuation cannot depend on the MCS content because there are no MCS.

**File**: Referenced in CanonicalConstruction.lean comments (lines 71-77) as `DurationTransfer.canonicalTaskFrame`. Exists somewhere in codebase but is acknowledged as semantically wrong.

**Verdict**: REJECTED. Algebraically clean but semantically vacuous.


### Candidate E: Stability-Enriched (Hypothetical)

**Definition**: `task_rel(M, d, N)` encodes "φ is stable for duration d" — a quantitative temporal relation.

**Algebraic obstacle**: TM's syntax has no duration-parameterized operators. There is no `G_d(φ)` meaning "φ holds for exactly d time units." The operators G and H are qualitative (always/sometimes in future/past), not quantitative. To make task_rel duration-sensitive would require extending TM to a metric temporal logic or duration calculus — a fundamentally different logic.

**Within TM**: Any canonical task relation definable from MCS content via g_content, h_content, f_content, or p_content is necessarily duration-degenerate because these extractors don't reference durations.

**Verdict**: REQUIRES EXTENDING THE LOGIC. Not achievable within TM as formalized.

---

## 4. The Existing D-Parametric Implementation

`ParametricCanonical.lean` provides the complete sorry-free D-parametric canonical frame:

```lean
def ParametricCanonicalTaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] : TaskFrame D where
  WorldState := ParametricCanonicalWorldState  -- {M : Set Formula // SetMaximalConsistent M}
  task_rel := parametric_canonical_task_rel     -- sign-based ExistsTask
  nullity_identity := parametric_task_rel_nullity_identity
  forward_comp := ...                           -- uses canonicalR_transitive (temp_4)
  converse := parametric_task_rel_converse
```

**Derived properties** (all sorry-free):
- `parametric_task_rel_nullity`: reflexivity at d=0
- `parametric_task_rel_pos`: for d > 0, task_rel ↔ ExistsTask
- `parametric_task_rel_zero`: task_rel at d=0 ↔ M = N  
- `parametric_task_rel_neg`: for d < 0, task_rel ↔ ExistsTask in reverse

**What's missing**: The frame exists but has no histories. To populate it, we need FMCS families that are TemporalCoherentFamilies, which requires proving forward_F — the same blocker.

---

## 5. Why Duration-Degeneracy is Structural

**Theorem** (informal): Any canonical task relation definable from MCS temporal content is duration-degenerate.

**Proof sketch**: Let `R(M, d, N)` be a canonical task relation where for d > 0, `R(M, d, N)` depends only on the logical content of M and N (not on d). The temporal operators G, H, F, P quantify over *all* future/past times or *some* future/past time — they don't reference specific durations. Therefore:

- `g_content(M) = {φ | G(φ) ∈ M}` — duration-independent
- `f_content(M) = {φ | F(φ) ∈ M}` — duration-independent
- Any Boolean combination of these is duration-independent

Since `R(M, d, N)` must be definable from M and N's formula content, it cannot depend on d.

**Consequence**: Duration structure enters through WorldHistory (`states : D → WorldState`) and Omega (the set of admissible histories), NOT through task_rel. The task relation is a constraint on which transitions are permitted; the specific timing is carried by the history indexing.

---

## 6. Critic Analysis: Bilateral Zorn Approach

The critic agent identified **three fatal flaws** in the proposed bilateral consistent-family Zorn approach:

### Fatal Flaw 1: Maximality ≠ MCS

Adding `ψ = F(χ)` to `f(t₀)` creates an F-obligation requiring χ somewhere in the future. This is a **multi-point extension** — you must simultaneously extend f(t₀) and some f(s) for s ≥ t₀. The Zorn partial order (pointwise inclusion of individual sets) provides no mechanism for coordinated multi-point extensions while maintaining both consistency AND temporal coherence.

The DovetailedChain.lean (lines 300-601) documents exactly this problem: F-formulas are NOT G-liftable, so the seed consistency argument that works for g_content fails for f_content.

### Fatal Flaw 2: Chain Union May Break Forward_G

In the union family `(⋃_i f_i)(t)`, new G-formulas may enter at time t that weren't in any individual f_i(t). These impose membership requirements at ALL future times t'. The union at t' was computed independently and may not satisfy these new requirements.

Specifically: `g_content(⋃_i f_i(t))` may be strictly larger than `⋃_i g_content(f_i(t))`. The first includes formulas G(φ) that appeared in later chain members at time t; these G(φ) formulas require φ at all future times, but the union at those times may not contain φ.

### Fatal Flaw 3: Seed Requires MCS

`temporal_theory_witness_consistent` (UltrafilterChain.lean:2167) requires `h_mcs : SetMaximalConsistent M`. The proof uses:
- G-lifting (`G_lift_from_context`) — needs MCS closure
- Negation completeness — needs MCS maximality
- `some_future_excludes_all_future_neg` — needs MCS

A consistent (non-maximal) set has none of these. The bilateral approach cannot use this theorem for its seed construction.

### Fatal Flaw 4: Box Modality Unaddressed

The Box operator quantifies over ALL histories in Omega (the BFMCS bundle). A single temporal family says nothing about Box coherence. The `boxClassFamilies` construction builds bundles from MCS in the same box-class — this is structurally different from Zorn maximization of a single family.

---

## 7. What Actually Works: The Sorry-Free Infrastructure

| Component | File:Line | Status |
|-----------|-----------|--------|
| `ParametricCanonicalTaskFrame D` | ParametricCanonical.lean:198 | SORRY-FREE |
| `temporal_theory_witness_consistent` | UltrafilterChain.lean:2167 | SORRY-FREE |
| `temporal_theory_witness_exists` | UltrafilterChain.lean:2212 | SORRY-FREE |
| `ultrafilter_F_resolution` | UltrafilterChain.lean:947-1273 | SORRY-FREE |
| `existsTask_transitive` (via temp_4) | CanonicalFrame.lean:199 | SORRY-FREE |
| `existsTask_reflexive` (via temp_t) | CanonicalIrreflexivity.lean:153 | SORRY-FREE |
| `canonical_forward_F` (flat model) | CanonicalFrame.lean:139 | SORRY-FREE |
| `forward_G` / `backward_H` in FMCS | FMCSDef.lean:111,119 | SORRY-FREE |
| `temporal_backward_G` (contraposition) | TemporalCoherence.lean:165 | SORRY-FREE (given forward_F) |
| `canonical_truth_lemma` | CanonicalConstruction.lean:723 | SORRY-FREE (given temporally_coherent) |
| `shifted_truth_lemma` | CanonicalConstruction.lean:873 | SORRY-FREE (given temporally_coherent) |

**The single sorry**: `bfmcs_from_mcs_temporally_coherent` — proving forward_F and backward_P at the family level.

---

## 8. The Real Gap: From Frame to Family

The canonical frame (Candidate A / ParametricCanonical) is complete and sorry-free. The truth lemma is complete and sorry-free (given temporal coherence). The gap is constructing temporally coherent families.

The approaches to closing this gap divide into:

### Path 1: Restricted F-Nesting (Current Best — Report 10/17)
- Work within deferralClosure(φ) where F-nesting is bounded
- Max-depth obligations MUST resolve in one step (FF outside closure)
- Downward induction on depth gives termination
- Requires: proving the fuel=0 branch unreachable (~200 LOC)
- Estimated total: ~800 LOC

### Path 2: Ultrafilter + Fair Scheduling
- Use sorry-free `ultrafilter_F_resolution` for single-step witnesses
- Fair scheduling (enumerate obligations) ensures every F-obligation targeted
- Requires: composing single-step witnesses into a chain with forward_F
- Estimated total: ~1000 LOC

### Path 3: Stability / Intersecting Histories (New Direction)
- Define stability operator: Stab(φ) at (τ, x) ≡ ∀σ ∈ Ω, σ(x) = τ(x) → M,σ,x ⊨ φ
- StabF(φ) ≡ ∀σ through same state, σ eventually achieves φ
- In canonical model: σ(x) = τ(x) means same MCS at time x
- StabF(φ) becomes a property of the MCS alone, not the history
- Requires: defining stability semantics, proving it decomposes F-obligations
- Estimated total: UNKNOWN — novel approach, needs careful development

---

## 9. Conclusions and Recommendations

1. **The D-parametric canonical task frame is SOLVED.** `ParametricCanonicalTaskFrame` exists, is sorry-free, and works for any ordered abelian group D. No further work needed on the frame definition.

2. **Duration-degeneracy is unavoidable** within TM's syntax. Enriching the task relation with duration information requires extending the logic itself.

3. **The bilateral Zorn approach has fatal flaws** as identified by the critic. It cannot be fixed without addressing the multi-point extension problem, the chain union coherence problem, and the MCS requirement for seed consistency.

4. **The most mathematically sound path** remains the restricted F-nesting approach (Path 1), which has clear proof strategy, bounded scope, and builds on sorry-free infrastructure.

5. **The stability/intersecting-histories direction** (Path 3) is mathematically interesting but requires careful development. The key insight — that StabF(φ) is a property of the MCS alone — could bypass the F-persistence problem entirely, but needs to be connected to the existing proof infrastructure.

---

## Appendix: File Index

| File | Lines | Role |
|------|-------|------|
| `Semantics/TaskFrame.lean` | ~260 | Abstract TaskFrame definition |
| `Metalogic/Algebraic/ParametricCanonical.lean` | ~250 | D-parametric canonical frame (sorry-free) |
| `Metalogic/Bundle/CanonicalConstruction.lean` | ~1020 | Int-specific canonical frame + truth lemma |
| `Metalogic/Bundle/CanonicalFrame.lean` | ~250 | ExistsTask, transitivity, forward_F (flat) |
| `Metalogic/Bundle/CanonicalIrreflexivity.lean` | ~240 | Reflexivity under T-axiom |
| `Metalogic/Bundle/TemporalCoherence.lean` | ~220 | TemporalCoherentFamily, backward lemmas |
| `Metalogic/Bundle/FMCSDef.lean` | ~130 | FMCS structure |
| `Metalogic/Algebraic/UltrafilterChain.lean` | ~3714 | Ultrafilter infrastructure (mostly sorry-free) |
