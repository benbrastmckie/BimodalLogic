# Research Report: Task #107 — Detailed Plan Revision Analysis

**Task**: 107 - Burgess chronicle construction for BX representation theorem
**Started**: 2026-04-28T15:25:00Z
**Completed**: 2026-04-28T17:30:00Z
**Task Type**: lean4
**Domains**: logic
**Mode**: Team Research (4 teammates)

## Executive Summary

Four teammates independently investigated the five critical areas identified in report 37 (post-113 plan review). Three findings are unanimous and definitive:

1. **B_sub_A_of_burgessR3 is irrecoverable** — all teammates confirm with a concrete countermodel. The D0 seed set approach is dead.
2. **Nested bridging is genuinely unprovable** under open guard — the derivation requires BX9 at a fundamental step.
3. **FUC replacement is substantially harder than report 37 estimated** — `rRelation_guard_continues'` doesn't directly apply at the limit level; the C5 elimination needs structural strengthening.

Two strategic findings reshape the project direction:

4. **The actual sorry count is 30, not 23** — report 37 undercounted by 7 (3 extra non-chronicle + 4 algebraic path).
5. **An algebraic path with only 4 sorry stubs may offer a faster route to completeness** than the chronicle's 11 sorry sites across 6 files.

## 1. B_sub_A_of_burgessR3: Definitively Dead

**Status**: IRRECOVERABLE — all 3 technical teammates agree independently.

### The Mathematical Argument

Under open guard, `β U γ₀` at point t means γ₀ holds at some s > t and β holds on the **open** interval (t, s). On a discrete order (e.g., {0, 1}), the interval (0, 1) is **empty**, so the guard is vacuously satisfied. This means `untl(β, γ₀) ∈ A` is consistent with `β ∉ A`.

### Exhaustive Axiom Analysis (Teammate A + C)

Every available axiom path from `untl(β, γ₀) ∈ A` was checked:

| Axiom | What it gives | Why it fails |
|-------|--------------|--------------|
| BX10 (until_F) | F(γ₀) ∈ A | Information about γ₀, not β |
| BX5 (self_accum) | untl(β ∧ untl(β,γ₀), γ₀) ∈ A | Enriches guard, doesn't extract β |
| BX4 (connect_future) | β → G(P(β)) | Requires β ∈ A as premise (circular) |
| BX6 (absorb_until) | Operates on nested Until structure | Wrong direction |
| BX2 (left_mono) | Transforms guard | Doesn't extract it |
| BX3 (right_mono) | Transforms event | Doesn't extract guard |
| BX7 (linear_until) | Needs two Until formulas | Not applicable |

**No chain of these axioms can derive `β ∈ A` from `untl(β, γ₀) ∈ A`.**

### Concrete Countermodel (Teammate C)

Discrete 2-point order {0, 1}. MCS A at point 0 contains `untl(p, ⊤)` (vacuous guard on empty interval). But `p ∉ A`. The statement `B ⊆ A` is **semantically false** under open guard.

### Impact on Plan v21

Phase 1 tasks 1.2-1.5 are **completely invalidated**. The D0 consistency argument, `burgess_D0_elem_in_A_or_C`, and the entire Lemma 2.6 assembly chain all depend on B_sub_A.

**Confidence**: HIGH (unanimous across 3 technical teammates).

## 2. Recommended Replacement: Bypass D0 Entirely

**Source**: Teammate A (confirmed by B and C).

### The Strategy

Instead of reconstructing D0, use the existing sorry-free infrastructure directly:

1. **`lemma_2_6`** (PointInsertion.lean:242, sorry-free) — for endpoint construction: given A, C MCS with g_content(A) ⊆ C and δ ∉ C, produces MCS D with δ.neg ∈ D and g_content(A) ⊆ D.

2. **`burgessR3Maximal_exists_from_seed`** (RRelation.lean:1131, sorry-free) — for g-value construction: given a seed η satisfying burgessR/burgessRSince conditions plus η ∈ A, produces BurgessR3Maximal g-values via Zorn's lemma.

### The Critical Subproblem: Seed Identification

For each new adjacent pair after point insertion, a seed η must satisfy:
- `burgessR(A', η, C')` — for all γ ∈ C', untl(η, γ) ∈ A'
- `burgessRSince(C', η, A')` — for all α ∈ A', snce(η, α) ∈ C'
- `η ∈ A'`

Where these seeds come from for each c2' sorry site:

| Sorry site | Context | Seed source |
|-----------|---------|-------------|
| C5 (line 786) | Until witness insertion | η = β from Lemma 2.4 (already sorry-free) |
| C5' (line 824) | Since witness insertion | Mirror of above |
| C4 (line 864) | Splitting for neg-Until | η from old g-value's relationship with new endpoint |
| C4' (line 902) | Mirror | Mirror |
| g_prop (line 938) | g-function coherence | η from g_content ordering |
| h_prop (line 970) | h-function coherence | Mirror |

**The C5/C5' seeds are already solved.** The C4/C4' and g_prop/h_prop seeds are the real mathematical work.

**Confidence**: MEDIUM-HIGH (infrastructure exists and is sorry-free; seed identification per case needs verification).

## 3. Nested Bridging Lemma: Genuinely Unprovable

### Why It Fails (Teammate B)

The nested version needs: from `untl(γ, untl(γ,δ)) ∈ A`, derive `untl(γ,δ) ∈ A`.

The derivation chain:
1. Start: `untl(γ, untl(γ,δ)) ∈ A`
2. Want to apply BX6: `untl(γ, γ ∧ untl(γ,δ)) → untl(γ,δ)` ✓
3. Need BX3 to go from `untl(γ, untl(γ,δ))` to `untl(γ, γ ∧ untl(γ,δ))`
4. BX3 requires `G(untl(γ,δ) → (γ ∧ untl(γ,δ)))`, which requires `⊢ untl(γ,δ) → γ`
5. This is exactly **BX9** (removed) ✗

**Confidence**: HIGH.

### Where It's Called

- CounterexampleElimination.lean:422 — C4 hard case, sub-case 1a (w_next < y, Until in f(w_next))
- CounterexampleElimination.lean:537 — C4' mirror

### Four Options (Teammate B analysis)

| Option | Description | Effort | Viability |
|--------|------------|--------|-----------|
| A | Restructure search to find δ directly | 6-10h | LOW — nested case is structurally inherent |
| B | Strengthen c2' to BurgessR3Maximal | 8-15h | MEDIUM — maximality may resolve via Zorn |
| C | Induction on domain size | 20-30h | LOW — major restructuring |
| D | Prove limit-level C4 independently via density | 4-8h | MEDIUM-HIGH — density means no adjacent pairs at limit |

**Recommended**: Investigate Option D first (cheapest), fall back to Option B if needed.

**Key insight (Teammate B)**: At the limit level, the domain is dense (no adjacent pairs). The c2' condition is vacuous at the limit. If `limit_satisfies_c4` can be proved WITHOUT depending on finite-stage nested bridging, the sorry stubs become dead code.

**Action item**: Trace the dependency chain from `limit_satisfies_c4` to determine if it transitively depends on `burgessR3_gamma_not_in_B_nested`.

## 4. FUC Replacement: Harder Than Estimated

### Report 37's Underestimate (Teammate B)

Report 37 estimated 2-4 hours for BX9 replacement in FUC. **The actual effort is 12-18 hours.**

### Why `rRelation_guard_continues'` Doesn't Directly Apply

`rRelation_guard_continues'` (RRelation.lean:130) has type:
```
rRelation A B → untl(γ,δ) ∈ A → δ ∉ B → γ ∈ B ∧ untl(γ,δ) ∈ B
```

This requires `rRelation(limit_f(t), limit_f(r))`, but:
1. `rRelation` is NOT established between arbitrary limit_f pairs
2. c2' gives `burgessR3`, not `rRelation` — these are **fundamentally different concepts** (Teammate C independently flagged this)
3. The bridge between burgessR3 and rRelation is not formalized

### The Correct Fix (Teammate B)

Strengthen the C5 elimination to **track guards at intermediate points**:

1. Add `c5_forward_guard` field to `EliminationResult` (CounterexampleElimination.lean:735)
2. When processing C5 counterexample `untl(ξ,η) ∈ f(x)` at stage n:
   - Insert new point y with η ∈ f(y)
   - The g-value for (x,y) contains ξ (via burgessR3 construction)
   - For existing domain points r between x and y: C3 gives g(x,y) ⊆ f(r), so ξ ∈ f(r)
3. At subsequent stages: new points inherit guard via C4 + chronicle invariants
4. Build `limit_satisfies_c5_full` (replacing `limit_satisfies_c5_weak`)

The guard propagation at the limit follows from **monotonicity of the omega chain**: once ξ ∈ f_n(r), it remains at all subsequent stages.

### rRelation vs burgessR3 Bridge (Teammate C)

The codebase has two r-relation concepts that are conflated in reports:

| Concept | Type | Direction |
|---------|------|-----------|
| `rRelation A B` | Obligation propagation | A → B: resolve Until obligations from A in B |
| `burgessR3 A B C` | Content-based | B × C → A: products of B,C elements become Until in A |

The FUC proof needs a connection between Cantor-embedded MCS assignments and `rRelation`. The chronicle's C3 condition provides this indirectly, but the bridge is **not yet formalized** — a hidden complexity unaddressed in any prior plan.

**Confidence**: MEDIUM (mathematical argument is sound, Lean engineering is substantial).

## 5. Density Clarification

**Status**: Resolved (Teammate C).

| Level | Domain structure | Density status |
|-------|-----------------|----------------|
| Finite stages | Finite set of rationals | DISCRETE — no intermediate points between adjacent pairs |
| Limit | Union of all finite stages | DENSE — proved sorry-free (`limit_dom_dense`, ChronicleConstruction.lean:698) |
| Lemma 2.6 application | At finite stages | Does NOT require density |

**Key clarification**: Lemma 2.6 (point insertion) operates at **finite stages** where the domain is discrete. The density of the limit domain is a **consequence** of the omega-chain construction, not a prerequisite. The D0 consistency argument (or its replacement) does not need density.

**Confidence**: HIGH.

## 6. Corrected Sorry Count

**Report 37 claimed**: 11 chronicle + 12 non-chronicle = 23 total.

**Actual count** (Teammate C, verified by grep):

| Path | File | Count | Details |
|------|------|-------|---------|
| Chronicle | CounterexampleElimination.lean | 7 | 6 c2' + 1 density |
| Chronicle | RRelation.lean | 2 | Nested bridging (INVALID) |
| Chronicle | ChronicleToCountermodel.lean | 2 | FUC Until + Since |
| **Chronicle subtotal** | | **11** | Matches report 37 |
| Non-chronicle | RootScopedChain.lean | 3 | |
| Non-chronicle | Filtration/SigmaOrdering.lean | 3 | |
| Non-chronicle | TruthLemma.lean | 2 | |
| Non-chronicle | Frame.lean | 1 | |
| Non-chronicle | Quasimodel/Construction.lean | 2 | |
| Non-chronicle | Quasimodel/Realization.lean | 4 | |
| **Non-chronicle subtotal** | | **15** | Report 37 said 12 (off by 3) |
| Algebraic | InteriorOperators.lean | 1 | `temp_k_dist` (may be a BX axiom) |
| Algebraic | TenseS5Algebra.lean | 3 | `temp_a`, `temp_l` removals |
| **Algebraic subtotal** | | **4** | Not in report 37 |
| **GRAND TOTAL** | | **30** | Report 37 said 23 (off by 7) |

## 7. Strategic Assessment

### The Algebraic Path (Teammate D)

Teammate D identified 4 sorry stubs on a separate algebraic completeness path:

| File | Line | Sorry | Notes |
|------|------|-------|-------|
| InteriorOperators.lean | 83 | `temp_k_dist` | Comment says "derivable from BX" |
| TenseS5Algebra.lean | 195 | `temp_a` | "removed in BX" — needs new proof |
| TenseS5Algebra.lean | 278 | `temp_l` | "removed in BX" — needs new proof |
| TenseS5Algebra.lean | 320 | `temp_l` | "removed in BX" — needs new proof |

If these are fixable under the current axiom system (15-25 hours estimated), they provide a **faster route to sorry-free completeness** than the chronicle's 11 sorry sites across 6 files.

**Risk**: The `temp_a` and `temp_l` claims of BX-derivability are **unverified**. They were temporary axioms from an earlier system. They may or may not be derivable from BX1-BX12.

**Recommendation**: A targeted 2-4 hour spike to verify BX-derivability of `temp_a`, `temp_k_dist`, and `temp_l` before committing to the full chronicle plan revision.

### Paper Status (Teammate D)

The paper's LaTeX references are **stale** — `04-Metalogic.tex` claims completeness as "Proven" but points to non-existent files. The actual theorems depend on `sorryAx`. The paper should either:
- Fix algebraic path sorries and claim completeness, OR
- Downgrade completeness to "Conjectured" and publish with sorry-free soundness + decidability

### Revised Time Estimate

| Source | Chronicle estimate | Basis |
|--------|-------------------|-------|
| Report 37 | 69-90h | Bottom-up phase analysis |
| Teammate C | 100-150h | Trajectory + hidden complexity |
| Teammate D | 120-200h | 37-round pattern analysis |

**Consensus**: The B_sub_A gap and rRelation/burgessR3 bridge are **research problems**, not coding tasks. Each has open mathematical questions. **100-150 hours** is realistic for the chronicle path, with significant variance.

## 8. Synthesis: What the Revised Plan Must Address

### Hard Constraints (unanimous)

1. **D0 is dead** — cannot reconstruct the seed set consistency argument without B_sub_A
2. **Use `burgessR3Maximal_exists_from_seed` directly** — already sorry-free
3. **Nested bridging needs a workaround** — the lemma is unprovable under open guard
4. **FUC needs structural strengthening** of C5 elimination, not a simple BX9 swap
5. **The rRelation/burgessR3 bridge must be explicitly addressed** in the plan

### Recommended Plan Structure

**Phase 0 (2-4h): Algebraic Path Triage**
- Verify whether `temp_a`, `temp_k_dist`, `temp_l` are derivable from BX1-BX12
- If yes: fast-track the algebraic path (15-25h total) as the publication completeness route
- If no: commit to the chronicle path below

**Phase 1 (15-25h): Seed-Based g-Construction**
- Replace D0 approach with direct seed identification for each c2' site
- C5/C5' seeds from Lemma 2.4 (already solved)
- C4/C4' seeds: new mathematical work using g_content ordering + the old g-value's relationship with the new endpoint
- g_prop/h_prop seeds: analogous

**Phase 2 (4-8h): Nested Bridging Resolution**
- First: trace `limit_satisfies_c4` dependency chain
- If independent of finite-stage nested bridging: delete sorry stubs (they become dead code at the limit)
- If dependent: strengthen c2' to BurgessR3Maximal (infrastructure exists)

**Phase 3 (12-18h): FUC Strengthening**
- Add `c5_forward_guard` field to `EliminationResult`
- Prove guard propagation at each stage via C3 interval containment
- Build `limit_satisfies_c5_full`
- Formalize rRelation/burgessR3 bridge for the Cantor embedding

**Phase 4 (5-8h): Density Self-Pair + Cleanup**
- Address the density self-pair sorry (CounterexampleElimination.lean:1086)
- Update Completeness.lean documentation (stale "4 total" claim)
- Complete task 113 Phase 5 remnants if not yet done

**Total**: 38-63 hours (chronicle path, assuming Phase 0 doesn't redirect to algebraic path)

### Conflicts Resolved

| Conflict | Resolution |
|----------|-----------|
| Sorry count (23 vs 30) | 30 is correct — report 37 missed 3 non-chronicle + 4 algebraic |
| FUC effort (2-4h vs 12-18h) | 12-18h is correct — rRelation_guard_continues' doesn't directly apply |
| Time estimate (69-90h vs 100-150h vs 120-200h) | 100-150h for full chronicle, but the revised plan targets 38-63h by tightening scope and using existing infrastructure |
| B_sub_A recoverable? | No — definitively irrecoverable (unanimous) |
| Algebraic path viability | UNKNOWN — needs 2-4h triage spike |

### Gaps Identified

1. **Seed identification for C4/C4' cases** — the most mathematically uncertain part. The old g-value's relationship with the new endpoint needs careful analysis.
2. **rRelation/burgessR3 bridge formalization** — no plan or report has addressed this explicitly.
3. **`limit_satisfies_c4` dependency trace** — determines whether nested bridging is even needed.
4. **Algebraic path BX-derivability** — unverified claims about temp_a/temp_l.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key contribution |
|----------|-------|--------|------------|-----------------|
| A | Primary (D0/B_sub_A) | Completed | HIGH | B_sub_A irrecoverable; bypass via burgessR3Maximal_exists_from_seed |
| B | Alternatives (nested/FUC) | Completed | MEDIUM | FUC needs structural C5 strengthening; nested bridging may be moot at limit |
| C | Critic | Completed | HIGH | Sorry count correction (30 not 23); rRelation/burgessR3 bridge gap |
| D | Horizons | Completed | MEDIUM | Algebraic path (4 sorries) faster than chronicle; paper decoupling |

## References

### Primary Sources
- PointInsertion.lean: lines 242 (lemma_2_6), 460-596 (maximality infrastructure)
- RRelation.lean: lines 130 (rRelation_guard_continues'), 1131 (burgessR3Maximal_exists_from_seed), 1169-1191 (nested bridging sorry stubs)
- CounterexampleElimination.lean: lines 422, 537 (nested bridging calls), 786-970 (c2' sorry sites), 1086 (density)
- ChronicleToCountermodel.lean: lines 615, 619 (FUC sorry sites)
- ChronicleConstruction.lean: line 698 (limit_dom_dense)
- InteriorOperators.lean: line 83 (algebraic sorry)
- TenseS5Algebra.lean: lines 195, 278, 320 (algebraic sorries)
- Axioms.lean: full axiom inventory (33 constructors, BX8/BX9 removed)

### Teammate Reports
- [38_teammate-a-findings.md] — D0 seed + B_sub_A gap analysis
- [38_teammate-b-findings.md] — Nested bridging + FUC replacement analysis
- [38_teammate-c-findings.md] — Sorry audit + axiom verification + time estimate
- [38_teammate-d-findings.md] — Strategic assessment + algebraic path + paper status
