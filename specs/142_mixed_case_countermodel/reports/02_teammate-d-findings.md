# Teammate D (Horizons): Strategic Assessment — Task 142

**Task**: Mixed-case countermodel for bx_completeness
**Date**: 2026-05-15
**Session**: sess_1778871005_29226d
**Role**: Strategic horizons analysis

## 1. Strategic Assessment

### 1.1 How Critical Is This Sorry?

**Very high — but not uniquely blocking.** The `dd_countermodel_chronicle_mixed_sorry` is one of 6 sorries on the critical path to sorry-free `bx_completeness`. The others are:

- 3 sorries in `NEquivalence.lean` (task 139 → task 145): `ktype_finite`, `k_type_of`, `finite_types`
- 2 sorries in `Table.lean` (task 140 → task 148): `table`, `table_depth_bound`

Tasks 147 and 148 (the table correctness pipeline) are already in IMPLEMENTING status and estimated at only 2-5 hours combined. These are likely to close before task 142.

**Key insight**: Even if task 142 is resolved, `bx_completeness` still depends on 5 other sorries (tasks 139/145 and 140/148). However, 142 is the *mathematically hardest* remaining sorry and the most likely to become a long-term blocker.

**The `#print axioms bx_completeness` output** (Completeness.lean:182) currently shows `sorryAx` alongside standard axioms. Removing this is the project's primary publication milestone.

### 1.2 The Project Already Has a Sorry-Free Completeness

An underappreciated fact: **`fmp_completeness` in Correctness.lean:100 is already sorry-free**. It establishes:

```
∀ ClosureMCSBundle φ, φ ∈ S.carrier → Nonempty (DerivationTree [] φ)
```

This is completeness over the finite filtered model (closure MCS bundles), not over arbitrary TaskFrame models. The gap between `fmp_completeness` and `bx_completeness` is the semantic bridge: showing that validity over all `TaskFrame D` models implies validity over all `ClosureMCSBundle` worlds.

**Strategic implication**: The project can claim a form of completeness NOW (`fmp_completeness`). The `bx_completeness` result adds semantic completeness over the intended class of models (TaskFrame structures on ordered abelian groups). This is stronger but the FMP result already provides decidability.

### 1.3 Comparison with Existing Formalizations

The Obendrauf et al. 2024 formalization of Coalition Logic with Common Knowledge (ITP 2024) is the closest comparable work in Lean 4. Key differences:

| Feature | Obendrauf CLC | ProofChecker TM |
|---------|--------------|-----------------|
| Logic | Coalition + epistemic (S5-like) | Tense (U,S,G,H) + S5 modal |
| Temporal operators | None | Full Until/Since with irreflexive semantics |
| Completeness | Sorry-free | 6 sorries remaining |
| Proof technique | Henkin filtration | Chronicle construction (Burgess 1982) |
| Lines of code | ~3000 (estimated) | 130+ live .lean files |
| Mixed-density issue | N/A | Central blocker |

**Publication value**: A sorry-free completeness proof for TM with irreflexive Until/Since over combined dense/discrete/mixed frames would be, to our knowledge, the **first such formalization in any proof assistant**. The mixed-case resolution would be mathematically novel.

## 2. Creative Approaches (Ranked by Promise)

### Rank 1: FMP Bridge Strategy (HIGH promise, MODERATE effort)

Instead of resolving the mixed case within the chronicle construction, bridge `fmp_completeness` to `bx_completeness` directly:

1. `fmp_completeness` gives: `(∀ ClosureMCSBundle φ, φ ∈ S.carrier) → ⊢ φ`
2. Soundness gives: `⊢ φ → valid φ` (frame-class specific, but available)
3. Need: `valid φ → ∀ ClosureMCSBundle φ, φ ∈ S.carrier`

This direction (valid → all MCS contain φ) is the **contrapositive** of what the FMP already proves. The FMP proves: `¬⊢φ → ∃ MCS, φ ∉ S.carrier`. This is equivalent to `(∀ MCS, φ ∈ S.carrier) → ⊢φ`. So:

```
valid φ → ⊢ φ    (what we want: bx_completeness)
```

The FMP already gives `(∀ closure MCS, φ ∈ carrier) → ⊢ φ`. If we can show `valid φ → (∀ closure MCS, φ ∈ carrier)`, we're done.

But `valid φ` means φ holds in ALL TaskFrame models. A closure MCS is NOT a TaskFrame model — it's a syntactic object. So we need to show that every closure MCS can be "realized" as a point in some TaskFrame model. This is essentially the representation theorem (task 8, task 992), which is itself blocked by similar issues.

**Verdict**: This approach is circular unless we can establish the bridge independently. However, it suggests that the right abstraction might bypass the mixed case entirely.

### Rank 2: Decidability-First Approach (MEDIUM promise, LOW-MEDIUM effort)

The decidability module is sorry-free. The `findCountermodel` function (CountermodelExtraction.lean:174) can computationally find countermodels for invalid formulas. Could we use this to prove `bx_completeness` computationally?

The approach would be:
1. If φ is valid, the tableau closes → `allClosed` → φ is provable (by proof extraction)
2. If φ is invalid, the tableau opens → countermodel exists → φ is not valid

The issue: the decision procedure uses fuel-bounded tableau search. It doesn't produce a TaskFrame countermodel — only a `SimpleCountermodel` (atom assignments). The `branchTruthLemma` (CountermodelExtraction.lean:149) is a stub (`∀ sf ∈ b, True` — trivially true).

**What's needed**: A sorry-free `branch_truth_lemma` that shows the saturated branch describes a genuine model. This is standard tableau completeness but hasn't been formalized.

**Verdict**: Completing the tableau-to-model bridge would give bx_completeness without ANY chronicle construction. This is a fundamentally different architecture. Estimated effort: 15-25 hours to establish the bridge properly. However, it would produce a weaker model (propositional/finite) rather than the intended TaskFrame model.

### Rank 3: Restructure to Eliminate the Three-Way Split (HIGH promise, HIGH effort)

The three-way case split (dense/discrete/mixed) is an architectural choice, not a mathematical necessity. The base Burgess construction works for ALL linear orders. The case split only exists because:

1. Dense case needs D = ℚ (Cantor isomorphism)
2. Discrete case needs D = ℤ (successor embedding)
3. Mixed case can't use either

**Alternative**: Use a single domain D for all cases. The most natural choice is D = ℚ (the rationals), since:
- Every countable linear order without endpoints embeds into ℚ (order-preserving injection)
- The Burgess limit domain is always a countable subset of ℚ (by construction)
- The BFMCS families just need `FMCS ℚ`, not density or discreteness of each family's internal structure

The challenge is defining `FMCS ℚ` for a discrete chronicle. The chronicle's limit domain is countable without endpoints but discrete. An order-preserving injection into ℚ exists but isn't surjective, so the gap-filling problem arises.

**Verdict**: This is the mathematically correct approach but requires new infrastructure (gap-filling FMCS). It's what the existing research (Strategy C/E in the prior report) already identified. 30-50 hours.

### Rank 4: Conservative Extension (LOW promise, UNCERTAIN effort)

Extend BX with the axiom `□(F'⊤) ∨ □(U(⊤,⊥))` (every modal class is uniformly dense or uniformly discrete). Prove this extension is conservative over BX (doesn't prove anything new about the original language). Then the mixed case is eliminated in the extended system.

**Problem**: The formula `□(F'⊤) ∨ □(U(⊤,⊥))` is NOT a BX theorem (confirmed in prior research, Section 8). Adding it as an axiom changes the logic — it eliminates models with mixed modal classes, which ARE genuine models of BX. So the extension is NOT conservative. This approach fails.

### Rank 5: Proof by Contradiction (VERY LOW promise)

Show the mixed case hypotheses (¬□(F'⊤) ∧ ¬□(U(⊤,⊥))) are inconsistent in BX. This was thoroughly analyzed in the prior research (Section 3.1) and confirmed to be satisfiable. The mixed case is genuine — it corresponds to real models where different accessible worlds have different temporal structures. No contradiction is derivable.

## 3. Adjacent Opportunities

### 3.1 Shared Infrastructure with Task 126 (Frame Hierarchy)

Task 126 proposes a four-tier frame hierarchy: Base → Dense/Discrete → Integer. The mixed case is inherently a "Base tier" phenomenon — it arises when we don't assume uniform density or discreteness. If task 126 were implemented first, the hierarchy might provide natural abstractions for handling mixed-density models.

However, task 126 has its own dependencies (tasks 123, 129) and is estimated at 15-25 hours. Doing 126 first would delay 142 without directly solving it.

### 3.2 Tasks 147/148 Should Complete First

Tasks 147 (De Bruijn substitution lemmas) and 148 (table_correctness temporal cases) are already in IMPLEMENTING/RESEARCHED status and are estimated at only 3.5-5 hours combined. They close 5 of the 6 critical-path sorries. **Completing these first narrows the sorry gap to just task 142**, making it the singular focus for sorry-free `bx_completeness`.

**Recommendation**: Prioritize 147 → 148 → 142.

### 3.3 No Reusable Infrastructure for Other Tasks

The mixed-case resolution (gap-filling FMCS on ℚ) is highly specific to the completeness proof. It doesn't create reusable infrastructure for tasks 143/145/146 (normal form), 127 (time addition), 128 (interior operator), or 953 (bilateral system). The only adjacent beneficiary would be task 8 (genuine truth_at completeness), which needs similar model construction.

## 4. Risk Analysis

### 4.1 Effort Estimate Risk

The prior research estimated 30-50 hours for the direct construction (Strategy C). This is likely **optimistic** for the following reasons:

1. **Gap-filling is mathematically subtle**: The prior research (Sections 4.3-4.5) identified multiple failed attempts at gap-filling. The correct approach is not obvious.
2. **BFMCS modal_backward is the crux**: Even with a gap-filling strategy, proving `modal_backward` requires showing that EVERY box-equivalent MCS N gets a valid family, including N with the "wrong" density.
3. **No existing infrastructure**: Unlike dense (Cantor iso) and discrete (succ embedding), there's no existing gap-filling code. Everything must be built from scratch.
4. **Restricted truth lemma interaction**: The restricted truth lemma only tracks `deferralClosure(φ)`, but the BFMCS construction needs coherence for ALL box formulas (for modal_forward/backward).

**Realistic estimate**: 40-80 hours, with 30% risk of exceeding 100 hours.

### 4.2 Fallback Options

If the mixed case proves fundamentally harder than expected:

1. **Document and defer**: Mark the sorry with a comprehensive mathematical explanation. The project can still claim completeness for the dense and discrete fragments, plus FMP completeness for the full logic.

2. **Restrict the completeness statement**: Prove `bx_completeness` for the fragment where `□(F'⊤) ∨ □(U(⊤,⊥))` holds. This covers all "pure" models and is publishable as a strong partial result.

3. **Use `native_decide` + FMP bridge**: If we can formalize the bridge from `valid φ` to `∀ ClosureMCSBundle, φ ∈ carrier`, we get `bx_completeness` without the chronicle construction at all. This would be a significant architectural shift but might be more tractable.

### 4.3 Architecture Risk

The current three-way split architecture creates a maintenance burden. Any changes to the BFMCS structure, Formula type, or temporal semantics must be propagated to three separate constructions (dense, discrete, mixed). If the mixed case solution is complex (80+ hours of new code), this creates ongoing tech debt.

## 5. Recommendation

**Proceed with the direct construction on ℚ (Strategy C/E from prior research), but AFTER completing tasks 147 and 148.**

**Rationale**:
1. 147/148 are easy wins that narrow the sorry gap to 1
2. The FMP bridge (Rank 1) is intellectually attractive but probably circular
3. The decidability-first approach (Rank 2) would bypass the problem but produce a weaker result
4. The direct construction on ℚ (Rank 3) is the mathematically correct solution and the only one that produces the intended `TaskFrame D` countermodel
5. A restructuring to eliminate the three-way split would be ideal but is too disruptive at this stage

**Specific next steps for task 142**:
1. Formally verify that `box(F'T) ∨ box(U(T,⊥))` is NOT a BX theorem (use the decidability procedure on a small counterexample)
2. Design the gap-filling FMCS: define `universal_fmcs : FMCS ℚ` that works for any chronicle
3. Prove forward_G and backward_H for the gap-filled FMCS
4. Build the mixed BFMCS using gap-filled families
5. Wire into the restricted truth lemma

**Insurance**: If after 60 hours the gap-filling approach is stalling, pivot to documenting the sorry with full mathematical analysis and claiming a "dense/discrete completeness" result.

## Confidence Level

**Medium**. The strategic direction is clear (direct construction on ℚ), but the mathematical difficulty of gap-filling remains uncertain. The 30-50 hour estimate could easily double.
