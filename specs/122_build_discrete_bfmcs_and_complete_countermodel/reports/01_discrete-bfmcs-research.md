# Research Report: Discrete BFMCS and Nondense Countermodel Completion

**Task**: 122 - build_discrete_bfmcs_and_complete_countermodel
**Date**: 2026-05-11
**Session**: sess_1778518750_c8b856

## 1. The Sorry Target

### Type Signature

```lean
theorem dd_countermodel_chronicle_nondense_sorry
    (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (φ : Formula) (h_neg_in : φ.neg ∈ A)
    (h_not_box_dense : (Formula.box next_top.neg).neg ∈ A) :
    ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
      (_ : Nontrivial D) (F : TaskFrame D) (TM : TaskModel F)
      (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
      (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
      ¬truth_at TM Omega τ t φ
```

**Location**: `ChronicleToCountermodel.lean:828-836`

**Hypothesis meaning**:
- `h_not_box_dense : (Formula.box next_top.neg).neg ∈ A` means `¬□(F'T) ∈ A`, equivalently `◇(U(T,⊥)) ∈ A`. Some box-accessible world has the "immediate successor" property U(T,⊥).
- By S5 negative introspection: `□(¬□(F'T)) ∈ A`, so every box-equivalent MCS N also has `¬□(F'T)`, meaning `◇(U(T,⊥)) ∈ N`.

### How It Is Used

In `Completeness.lean:148-157`, `bx_completeness` case-splits on `□(F'T)`:
- Dense case (`□(F'T) ∈ M`): uses `dd_countermodel_chronicle_dense` (sorry-free)
- Non-dense case (`¬□(F'T) ∈ M`): uses `dd_countermodel_chronicle_nondense_sorry` (THE sorry)

This is the ONLY sorry on the critical path for `bx_completeness`.

## 2. Dense Case Pattern (Reference Architecture)

The dense case (`dd_countermodel_chronicle_dense`, lines 790-817) follows this pattern:

1. **FMCS on Q**: `cantor_fmcs_dense A h_mcs h_dense : FMCS Rat` via Cantor isomorphism
2. **Shifted FMCS**: `rooted_cantor_fmcs_dense N h_N h_box_N s : FMCS Rat` for each box-equivalent N, shifted so `mcs(s) = N`
3. **Box stability**: `box_stable_in_rooted_cantor_fmcs_dense` gives `□φ ∈ fam.mcs(t) ↔ □φ ∈ N`
4. **BFMCS**: `cantor_bfmcs_dense A h_mcs h_box_dense : BFMCS Rat` with families indexed by box-equivalent MCS's
   - `modal_forward`: via box stability transfer through box-equivalence
   - `modal_backward`: via contrapositive + `bx_modal_witness`
5. **Three restricted coherence conditions**:
   - `cantor_bfmcs_dense_restricted_tc`: F/P resolution via `limit_F_resolution`/`limit_P_resolution` + Cantor iso
   - `cantor_bfmcs_dense_restricted_buc`: backward Until/Since via C4/C4' contrapositive
   - `cantor_bfmcs_dense_restricted_fuc`: forward Until/Since via C5/C5' + Cantor iso guard
6. **Parametric representation**: `fully_restricted_parametric_representation_from_neg_membership` wires BFMCS + coherence into a countermodel

### Key Enabler for the Dense Case

The Cantor isomorphism `LimitDomSubtype ≃o Rat` is a BIJECTION. Every rational maps to a limit domain point. This makes all coherence proofs straightforward: witnesses from `limit_F_resolution`, `limit_satisfies_c5_strong`, etc. are automatically in the image of the isomorphism.

## 3. Existing Discrete Infrastructure

Task 123 produced:

- **`discrete_embed : Z -> LimitDomSubtype`** (strictly increasing, uses `NoMaxOrder`/`NoMinOrder`)
- **`discrete_fmcs : FMCS Z`** (sorry-free, forward_G/backward_H via `limit_forward_G`/`limit_backward_H`)
- **`discrete_f_at_zero`**: `discrete_fmcs.mcs(0) = A`
- **`box_stable_in_limit_f`**: works for ANY limit domain point (no density/discreteness assumption)

Additionally, the file contains extensive collapse equivalence infrastructure:
- `collapse_equiv`, `collapse_setoid`, `CollapseClass` with `LinearOrder`
- Orbit convexity, class separation, transitivity proofs
- `limitDomSubtype_succ/pred` with `SuccOrder`/`PredOrder`

**Critical observation**: `discrete_f`, `discrete_embed`, and `discrete_fmcs` carry an `h_discrete` parameter but it is UNUSED (marked with underscore prefix). The construction works for ANY chronicle, regardless of density/discreteness. This is because `embed_forward`/`embed_backward` only use `NoMaxOrder`/`NoMinOrder` on `LimitDomSubtype`, which hold unconditionally.

## 4. The Mixed Case Problem

The hypothesis `¬□(F'T) ∈ A` does NOT imply `U(T,⊥) ∈ A`. It means `◇(U(T,⊥)) ∈ A` — some box-accessible world has U(T,⊥). There are three sub-cases:

### Case A: `□(U(T,⊥)) ∈ A` (Purely Discrete)
Every box-equivalent N has `U(T,⊥)`. All chronicles are discrete. Natural home: D = Z.

### Case B: `U(T,⊥) ∈ A` but `□(U(T,⊥)) ∉ A` (Mixed from A's perspective)
A is discrete but some box-equivalent N has `F'T = ¬U(T,⊥)`. Different chronicles have different discreteness properties.

### Case C: `F'T ∈ A` but `□(F'T) ∉ A` (Dense locally, discrete elsewhere)
A's chronicle is dense but some box-equivalent N's chronicle is discrete.

### Why D Cannot Be Both Q and Z

- **U(T,⊥) truth on Q**: Requires an interval (t, u) with ⊥ at all intermediate rationals. Since every rational maps to an MCS (which never contains ⊥), U(T,⊥) is ALWAYS FALSE on Q. So families with U(T,⊥) in their MCS cannot satisfy the truth lemma on Q.

- **F'T truth on Z**: F'T = ¬U(T,⊥). On Z, U(T,⊥) is ALWAYS TRUE (n+1 is the immediate integer successor with no integers between n and n+1). So F'T is ALWAYS FALSE on Z. Families with F'T in their MCS cannot satisfy the truth lemma on Z.

**Conclusion**: The mixed case (Cases B and C) cannot use D = Q or D = Z for ALL families simultaneously.

## 5. Recommended Approach: Refine the Case Split

### Observation

`box(F'T) ∨ box(U(T,⊥))` is NOT a BX theorem (box doesn't distribute over disjunction). So Cases B/C are logically consistent in BX.

However, the completeness theorem `bx_completeness` is contrapositive: we need to find ONE countermodel. We can refine the case split:

```
rcases SetMaximalConsistent.negation_complete hM_mcs (Formula.box next_top) with
  h_box_discrete | h_not_box_discrete
```

This gives:
1. `□(F'T) ∈ M` — dense case (already done)
2. `□(U(T,⊥)) ∈ M` — purely discrete case (doable on Z)
3. `¬□(F'T) ∈ M ∧ ¬□(U(T,⊥)) ∈ M` — mixed case

But cases 2 and 3 overlap with the current nondense case. We need a three-way split:

```
Dense:    □(F'T) ∈ M             → countermodel on Q (done)
Discrete: □(U(T,⊥)) ∈ M         → countermodel on Z (task 122 core)
Mixed:    ¬□(F'T) ∧ ¬□(U(T,⊥))  → countermodel on ??? (hardest)
```

### Can the Mixed Case Be Eliminated?

By MCS completeness: `□(F'T) ∈ M ∨ ¬□(F'T) ∈ M` and `□(U(T,⊥)) ∈ M ∨ ¬□(U(T,⊥)) ∈ M`.

Since `F'T = ¬U(T,⊥)`, every MCS has either `F'T` or `U(T,⊥)`, so `□(F'T ∨ U(T,⊥))` is a theorem (necessitation of tautology). But `□(F'T) ∨ □(U(T,⊥))` does NOT follow.

However, `¬□(F'T) ∈ M` means `◇(U(T,⊥)) ∈ M` (diamond of discreteness). And `¬□(U(T,⊥)) ∈ M` means `◇(F'T) ∈ M` (diamond of density). Both coexist: diamond-accessible worlds have both discrete and dense temporal structure.

**Key question**: Is `◇(U(T,⊥)) ∧ ◇(F'T)` satisfiable in a valid BX model?

Yes. Consider a model on Q where one world history has discrete time structure (values only at integers) and another has dense time structure. The S5 accessibility sees both, so the diamond formulas hold.

So the mixed case IS genuinely possible and cannot be eliminated by logical reasoning within BX.

### Handling the Mixed Case: Universal Embedding into Q

**Strategy**: Use D = Q for the nondense case (both mixed and purely discrete sub-cases).

The key insight: we don't need U(T,⊥) to be TRUE in the countermodel for the purely discrete families. We need `¬φ` to be true at the evaluation point. The truth lemma relates MCS membership to semantic truth for formulas in the SUBFORMULA closure of φ. If U(T,⊥) is NOT a subformula of φ (which it usually isn't — it involves the specific top_formula and bot constructors), then we don't need U(T,⊥) to match between MCS membership and semantic truth.

**Wait** — this reasoning is incorrect. The restricted truth lemma quantifies over `subformulaClosure root`, where root = φ. If U(T,⊥) is not in the subformula closure of φ, its truth value doesn't matter. But U(T,⊥) COULD appear in the subformula closure if φ mentions Until.

Actually, the restricted coherence conditions only require temporal coherence, forward Until/Since, and backward Until/Since for formulas in `deferralClosure(root)`. U(T,⊥) = Until(top_formula, bot) would only be relevant if `Until(top_formula, bot)` is in the deferral closure of φ. For a generic φ, this is not the case.

**However**, the BFMCS construction itself has requirements (modal_forward, modal_backward) that don't depend on specific formulas. These need box stability, which works for any chronicle.

**The problem with D = Q for discrete families**: Even ignoring U(T,⊥) truth, the `discrete_fmcs` FMCS is on Z, not Q. We'd need to define an FMCS on Q for each family. For a chronicle where U(T,⊥) holds at all domain points, the Cantor isomorphism is NOT available (the domain is discrete, not dense). We'd need a different embedding into Q.

### Better Approach: D = Q for EVERYONE, But Skip the Isomorphism

**Universal Q-embedding strategy**:

For ANY MCS N (dense or discrete), the limit domain `LimitDomSubtype N h_N` has:
- `Countable`, `NoMaxOrder`, `NoMinOrder`, `Nonempty`

Define `universal_f_Q : Q -> Set Formula` by picking an arbitrary strictly increasing embedding `LimitDomSubtype -> Q` (NOT a bijection) and assigning MCS values to embedded points. For non-embedded rationals, assign some default MCS.

**Problem**: forward_G needs `G(φ) ∈ f(t)` to imply `φ ∈ f(t')` for ALL t' > t. If t' maps to a "default" MCS, we need the default to contain φ. But G(φ) is in one MCS and we'd need it in all future MCS's — this requires the default to be connected to the chronicle, which is not guaranteed.

This doesn't work.

### Recommended Approach: Purely Discrete on Z + Defer Mixed Case

**Pragmatic recommendation**: Implement the purely discrete case (where `□(U(T,⊥)) ∈ A`) as a BFMCS on Z. This is the analog of the dense case and is structurally sound. For the mixed case (`¬□(F'T) ∧ ¬□(U(T,⊥))`), mark it as a separate sorry with a clear docstring.

This approach:
1. Eliminates the current monolithic sorry
2. Reduces to a more focused sorry (mixed case only)
3. Provides a template for the mixed case solution
4. May be sufficient if the mixed case is later shown to be handleable by a different technique (e.g., ultraproduct methods or Goldblatt's approach)

### Alternative: Succ-Based FMCS for the Full Nondense Case

For the purely discrete case (`□(U(T,⊥)) ∈ A`), the succ-based approach works:

1. Every box-equivalent N has `U(T,⊥) ∈ N` (from `□(U(T,⊥)) ∈ A` + box-equiv + modal_t)
2. By `discrete_propagate_fwd/bwd` (base BX axioms), `G(U(T,⊥)) ∈ N` and `H(U(T,⊥)) ∈ N`
3. So `U(T,⊥) ∈ limit_f(x)` for all x in N's chronicle
4. `limitDomSubtype_succ` gives deterministic successor on N's domain
5. Define FMCS on Z via succ-iteration from the root point
6. Coherence proofs use the successor structure directly

**For temporal coherence (F/P)**: If `F(φ) ∈ fmcs.mcs(n)`, then by `limit_F_resolution`, exists y > embed(n) with φ at y. Since U(T,⊥) holds everywhere, the succ function gives deterministic access to y's successor chain. The key: either y IS in the succ-orbit of embed(n) (so y = embed(n+k) for some k), or y is in a later orbit. In either case, by G-propagation of the chronicle, there exists a later embedded point with φ.

**Wait** — this doesn't work directly either. `limit_F_resolution` gives a witness y with φ, but G-propagation doesn't guarantee φ persists at later points. F(φ) just means φ holds at SOME future point, not that G(φ) holds.

Actually, for the F(φ) case: we have F(φ) at embed(n). By `limit_F_resolution`, exists y in limit_dom with y > embed(n) and φ ∈ limit_f(y). Now define `m = collapse(y)` (the integer assigned to y's succ-orbit). Since the collapse is order-preserving, m > n (or m = n if y is in the same orbit as embed(n)). But if the succ-iteration mapping is `embed(n) -> succ^0(root) = orbit representative, then embed(n+1) = succ(embed(n))`, the embedding follows the succ chain. Then y is either in the orbit at integer m >= n, and `fmcs.mcs(m) = limit_f(repr(m))` where repr(m) is the representative of the orbit containing y.

The issue: `φ ∈ limit_f(y)` doesn't imply `φ ∈ limit_f(repr(m))` unless y = repr(m) or we have propagation.

**This is precisely the coherence problem identified in the task 123 plan (Phase 3).** The plan proposed handling it by direct proof for the xi=bot case and limit_satisfies_c5_strong for the general case, noting the subtleties.

## 6. Detailed Assessment: What Needs to Be Built

### For the Purely Discrete Case (`□(U(T,⊥)) ∈ A`)

The following definitions/lemmas are needed, mirroring the dense case:

| Component | Dense Equivalent | Effort |
|-----------|-----------------|--------|
| `box_discrete_gives_discreteness` | `box_dense_gives_density` | Low — mirror proof |
| `box_stable_in_discrete_f` | `box_stable_in_cantor_f_dense` | Low — via `box_stable_in_limit_f` |
| `shifted_discrete_fmcs` | `shifted_cantor_fmcs_dense'` | Low — `mcs t := discrete_f(t + offset)` |
| `rooted_discrete_fmcs` | `rooted_cantor_fmcs_dense` | Low — compose chronicle + shift |
| `rooted_discrete_fmcs_at_s` | `rooted_cantor_fmcs_dense_at_s` | Low — arithmetic |
| `box_stable_in_rooted_discrete_fmcs` | `box_stable_in_rooted_cantor_fmcs_dense` | Low |
| `discrete_bfmcs` | `cantor_bfmcs_dense` | Medium — families + modal coherence |
| `discrete_bfmcs_restricted_tc` | `cantor_bfmcs_dense_restricted_tc` | HIGH — coherence on Z |
| `discrete_bfmcs_restricted_buc` | `cantor_bfmcs_dense_restricted_buc` | HIGH — C4/C4' on Z |
| `discrete_bfmcs_restricted_fuc` | `cantor_bfmcs_dense_restricted_fuc` | HIGH — C5/C5' on Z |
| `dd_countermodel_chronicle_discrete` | `dd_countermodel_chronicle_dense` | Low — wire together |

### The Three Hard Components

The three restricted coherence conditions are the main challenge. The core difficulty: `discrete_embed` is NOT surjective onto `LimitDomSubtype`. Witnesses from `limit_F_resolution`, `limit_satisfies_c4/c4'`, `limit_satisfies_c5_strong/c5'_strong` land on arbitrary limit domain points, which may not be in the image of the embedding.

**Approach options for coherence**:

A. **Collapse-based FMCS** (task 123 plan Phase 3-4, not implemented): Use the collapse equivalence to define a surjection `LimitDomSubtype -> Z`. Representatives of each orbit class serve as the Z-indexed MCS. Coherence proofs transport through the collapse.

B. **Succ-based embedding** (when `U(T,⊥)` holds everywhere): Map `n : Z` to `succ^n(root)` for positive n and `pred^|n|(root)` for negative n. This gives deterministic access to the successor structure. Coherence follows because U(T,⊥) witnesses are immediate successors.

C. **Direct proof on the current `discrete_embed`**: For each coherence property, show that witnesses can be "rounded" to the nearest embedded point. This requires showing that embedded points are "dense enough" to capture all relevant witnesses.

**Recommendation**: Option B (succ-based) is the most natural for the purely discrete case. The succ-based embedding aligns with the mathematical structure and gives the tightest correspondence between Z and the limit domain.

## 7. Completeness Proof Structure Assessment

### Base Logic (BX)

**`bx_completeness`** in `Completeness.lean`:
- Dense case: sorry-free via `dd_countermodel_chronicle_dense`
- Nondense case: THE SORRY via `dd_countermodel_chronicle_nondense_sorry`

The nondense case covers both purely discrete and mixed subcases. Resolving it requires either:
1. Handling both subcases together (very hard — mixed case needs novel techniques)
2. Refining the case split to separate purely discrete from mixed

### Dense Extension Completeness

Not on the current critical path. Would require a separate `valid_dense` predicate and `dense_completeness` theorem. The dense case of `bx_completeness` already shows the pattern.

### Discrete Extension Completeness

Not on the current critical path. Would require `valid_discrete` (quantifying over discrete ordered abelian groups), `discrete_completeness`, and soundness/completeness of `prior_UZ`/`prior_SZ` axioms.

### Other Gaps Beyond Task 122

| File | Sorry Count | On Critical Path? |
|------|-------------|-------------------|
| `ChronicleToCountermodel.lean:836` | 1 | YES (the target) |
| `TruthLemma.lean:296,321` | 2 | No (dead code, old approach) |
| `RootScopedChain.lean:186,193,198` | 3 | No (dead code, bypassed by chronicle) |
| `Frame.lean:205` | 1 | No (dead code) |
| `SuccRelation.lean:548,617,625` | 3 | No (not imported by Completeness) |
| `SuccExistence.lean:466,771,845` | 3 | No (not imported by Completeness) |
| `Filtration/SigmaOrdering.lean` | 3 | No (decidability, not completeness) |
| `Quasimodel/Construction.lean` | 2 | No (alternative approach) |
| `Quasimodel/Realization.lean` | 4 | No (alternative approach) |
| `ConservativeExtension/Lifting.lean` | ~12 | No (extension, not base) |

**Only 1 sorry is on the critical path for `bx_completeness`**: `dd_countermodel_chronicle_nondense_sorry`.

## 8. Recommended Task Revision

### Option 1: Full Nondense Case (Ambitious)

**Scope**: Fill in `dd_countermodel_chronicle_nondense_sorry` completely, handling both purely discrete and mixed subcases. 

**Difficulty**: Very high. The mixed case requires novel techniques not present in the codebase.

**Not recommended** for a single task.

### Option 2: Refine Case Split + Discrete Case (Recommended)

**Scope**:
1. Refine the case split in `bx_completeness` to three cases: `□(F'T)`, `□(U(T,⊥))`, neither
2. Implement the purely discrete case (`□(U(T,⊥)) ∈ A`) as `dd_countermodel_chronicle_discrete`
3. Leave the mixed case as a more focused sorry

**Approach for the discrete case**:
- Use succ-based embedding (map n to succ^n(root))
- Build `BFMCS Z` mirroring `cantor_bfmcs_dense`
- Prove coherence using the successor structure

**Estimated effort**: 15-25 hours

**Deliverable**: Reduce `bx_completeness` from 1 sorry (broad) to 1 sorry (mixed case only)

### Option 3: Purely Discrete on Z (Minimal Viable)

**Scope**: Build `BFMCS Z` and wire it into a new theorem `dd_countermodel_chronicle_discrete`, WITHOUT changing the Completeness.lean case split. The nondense sorry remains but has a clear path forward.

**Difficulty**: Medium-high (coherence proofs are still needed)

**Deliverable**: Infrastructure that a later task can plug into Completeness.lean

## 9. Risks and Blockers

1. **Coherence on Z is the hardest part**: The three restricted coherence conditions require careful proof that witnesses from the limit domain can be captured by the Z-indexed FMCS. The succ-based approach is most promising but requires detailed verification.

2. **The mixed case is genuinely open**: No known approach in the codebase handles families with different temporal structures (some dense, some discrete) in a single BFMCS. This may require ultraproduct methods, a new semantic framework, or a BX theorem showing the mixed case is impossible.

3. **Task 123 plan vs. reality**: The plan's Phases 3-5 (coherence, BFMCS, cleanup) were marked [COMPLETED] but the actual implementation used a simpler approach (direct embedding) that doesn't include the collapse-based BFMCS. The coherence infrastructure from the plan is NOT in the codebase.

4. **The `discrete_embed` is too weak for coherence**: The current `discrete_embed` picks arbitrary increasing points via `exists_gt`. This doesn't align with the successor structure needed for Until/Since coherence. A succ-based embedding is needed instead.
