# Teammate B Findings: Alternative Approaches for CanonicalEmbedding:418

## Key Findings

### 1. The Bidirectional Truth Bridge Dependency Is Fundamental

The imp case of any truth bridge necessarily requires BOTH directions for subformulas. Examining `fragment_truth_iff` (CanonicalEmbedding.lean:213-266) reveals the precise dependency:

- **Forward direction** for `psi.imp chi`: given `psi.imp chi in w` and `truth_at psi`, need `truth_at chi`. This uses the **backward** IH for psi (to get `psi in w` from `truth_at psi`) and the **forward** IH for chi.
- **Backward direction** for `psi.imp chi`: given `truth_at psi -> truth_at chi`, need `psi.imp chi in w`. This uses the **forward** IH for psi (to test membership) and the **backward** IH for chi.

Therefore, any truth bridge for USF formulas MUST be bidirectional. A forward-only truth bridge is insufficient because it cannot handle the imp case (the forward direction of imp requires the backward direction for the antecedent). This eliminates the entire class of "use only forward truth bridge + validity" approaches.

### 2. The Constant-History Backward G Failure Is Mathematical, Not Technical

On `constant_history w`, all times map to `w`. Therefore:

- `truth_at G(phi) at (constant_history w, t)` reduces to `forall s >= t, truth_at phi at (constant_history w, s)`
- By backward IH, this gives `phi in w` (since states(s) = w for all s)
- But we need `G(phi) in w`, which requires `phi in v` for ALL `v` with `bx_le w v` (by `G_iff_mcs`)
- `phi in w` does NOT imply `G(phi) in w` -- counterexample: p in w but G(p) not in w

This is not a gap in proof technique. The constant-history model genuinely cannot distinguish `G(phi)` from `phi` because it has only one world state visible at all times.

### 3. The Two-Point History Has the Same Backward G Problem

A two-point history with `states(0) = w` and `states(t) = v` for t > 0 (where `bx_le w v`) improves over constant histories by distinguishing time 0 from later times. However:

- `truth_at G(phi) at (two_point w v, 0)` means `phi` true at time 0 (state w) and all t > 0 (state v)
- Backward IH gives `phi in w` and `phi in v`
- But `G_iff_mcs` requires `phi in u` for ALL `u` with `bx_le w u`, not just `v`
- The two-point history only probes ONE specific successor `v`

**Unless** the omega (set of admissible histories) is rich enough that the box quantifier compensates. But box and G are independent modalities -- box quantifies over histories in omega, while G quantifies over times within a single history.

### 4. No Proof-Theoretic Shortcut Exists for Case B

I investigated several purely proof-theoretic approaches to bypass the semantic argument:

**Contrapositive reduction**: `valid(psi -> chi)` implies `valid(neg chi -> neg psi)`. If we could apply the IH to the contrapositive, we'd get `derivable(neg chi -> neg psi)`, from which `derivable(psi -> chi)` follows by reverse contraposition (available as `rcp` in Propositional.lean). However, the contrapositive formula `(chi.imp bot).imp (psi.imp bot)` has `sizeOf = 3 + sizeOf(chi) + sizeOf(psi) + 2*sizeOf(bot)`, which is STRICTLY LARGER than `sizeOf(psi.imp chi) = 1 + sizeOf(psi) + sizeOf(chi)`. The IH does not apply.

**Strong completeness reduction**: `valid(psi -> chi)` means `psi |= chi` (semantic consequence). Strong completeness would give `[psi] |- chi`, then deduction theorem gives `|- psi -> chi`. But strong completeness for the USF fragment IS what we're proving -- circular.

**Custom well-founded measure**: Temporal depth `td(psi.imp chi) = max(td(psi), td(chi))`, so the contrapositive has the same temporal depth and larger size. No lexicographic measure makes the contrapositive smaller.

**Using `not valid(psi)` constructively**: The hypothesis `not valid(psi)` gives a countermodel for psi. Combined with `valid(psi -> chi)`, in the countermodel chi is vacuously implied. This gives no information about chi's derivability or membership in any MCS.

### 5. The Critical Architecture: Canonical Model Must Visit All bx_le Successors

For a bidirectional truth bridge for G(phi) to work at MCS w, the model must ensure that the truth of `G(phi)` at w captures exactly `G_iff_mcs`: `G(phi) in w <-> forall v, bx_le w v -> phi in v`.

The semantic truth `truth_at G(phi) at (tau, t)` means `forall s >= t, truth_at phi at (tau, s)`. For backward direction, we need the map `s -> tau.states(s)` to be surjective onto `{v | bx_le w v}`.

This means the history through w must visit ALL bx_le successors of w. Since there are potentially uncountably many BXPoints, this seems to require:

- Either an uncountable duration type D (so the history can visit uncountably many states)
- Or collapsing bx_le classes (so fewer states need to be visited)
- Or a fundamentally different model construction

## Recommended Approaches

### Approach A: Parametric History Through bx_le Chain (Recommended, 60% Confidence)

**Idea**: Instead of constant_history or two-point history, build a "canonical history" through w that visits a cofinal set of bx_le successors.

**Construction**:
1. For MCS w, define `bx_le_successors w = {v : BXPoint | bx_le w v}`
2. Choose D = type with enough cardinality to enumerate all successors (or use an ordinal-indexed chain)
3. Build history `canonical_history w` where `states` visits all elements of `bx_le_successors w`
4. For backward G: truth at all future times gives phi in all successors, exactly matching `G_iff_mcs`

**Challenge**: The duration type D is universally quantified in `valid`. We need this to work for ALL D. But the canonical model uses a SPECIFIC D (Int in the base case). The trick: since `valid` quantifies over ALL D, we can instantiate with a D large enough to visit all successors. Any D with `|D| >= |BXPoint|` suffices. Using D = the ordinal of BXPoint (or simply BXPoint itself, if it has the right structure) would work.

**Key risk**: Building a `WorldHistory canonical_task_frame` where `states` maps each `t : D` to a specific BXPoint and `respects_task` is satisfied. The task relation is `d != 0 or w = u`, so distinct times can map to any pair of states. This is permissive and should work.

**Effort estimate**: 12-20 hours. Requires defining the canonical history, proving the truth bridge for all USF formulas, and connecting to the sorry site.

### Approach B: Restructure as Proof by Strong Induction on Total Formula Complexity (45% Confidence)

**Idea**: Replace structural induction with well-founded induction on a complexity measure that allows the imp case to invoke the IH on "morally simpler" formulas, even if structurally larger.

**Observation**: The imp case fails because we case-split on `valid(psi)` and Case B needs a semantic argument. What if instead we never case-split? The IH gives `valid(alpha) -> derivable(alpha)` for ALL alpha with measure < measure(psi.imp chi). If we define measure so that BOTH psi and chi have smaller measure, we can attempt:

1. By excluded middle on `valid(chi)`:
   - If `valid(chi)`: apply IH to chi, get `derivable(chi)`, then `derivable(psi -> chi)` by prop_s. Done.
   - If `not valid(chi)`: we have `valid(psi -> chi)` and `not valid(chi)`. By the semantics, there exists a model where chi is false. In any such model, psi must also be false (otherwise psi -> chi would be falsified). So `not valid(psi)` as well.

In the "neither valid" sub-case: both `not valid(psi)` and `not valid(chi)`. We need `derivable(psi -> chi)`. Can we get this proof-theoretically?

From `not valid(psi)`, by contrapositive of IH: `not derivable(psi)` OR `psi` has measure >= current. But by construction, `psi` has smaller measure, so the contrapositive gives `not valid(psi) -> not derivable(psi)`. Similarly for chi.

This gives us `not derivable(psi)` and `not derivable(chi)`. But we need `derivable(psi -> chi)`. There's no propositional principle that derives `derivable(psi -> chi)` from `not derivable(psi)` and `not derivable(chi)`.

**Assessment**: This approach is stuck at the same point. Changing the induction measure doesn't help because the imp case fundamentally needs to relate validity to derivability at the current level, which requires a semantic argument (countermodel construction or truth bridge).

### Approach C: Use Existing Parametric Infrastructure (ParametricRepresentation) for USF (55% Confidence)

**Idea**: The `Algebraic/ParametricRepresentation.lean` module provides the "main" completeness theorem, contingent on having a temporally coherent BFMCS. For USF formulas, the temporal coherence requirements are simpler (no Until/Since eventualities). If we can show that a BFMCS for a USF formula has its temporal coherence obligations satisfied trivially (since Until/Since are absent), the parametric representation theorem would close the sorry.

**Key question**: Does `ParametricTruthLemma` handle G/H correctly? Looking at the module description ("G/H proved, Until/Since not in scope for the parametric truth lemma"), yes -- the parametric truth lemma covers G and H.

**Path**:
1. Build a BFMCS from the MCS w (containing neg(psi.imp chi))
2. The BFMCS temporal coherence for G/H is satisfied (these are covered by the main infrastructure)
3. Since phi is USF, no Until/Since temporal coherence is needed
4. Apply parametric representation theorem to get a countermodel
5. Contradiction with validity

**Challenge**: The BFMCS construction in `Bundle/Construction.lean` builds a temporally coherent family, which may have its own sorry dependencies for the "temporal coherence" part. Need to verify whether the G/H temporal coherence (without Until/Since) is sorry-free.

**Effort estimate**: 8-15 hours. Mostly integration work connecting existing infrastructure.

## Evidence

### Bidirectional necessity for imp truth bridge
```lean
-- From fragment_truth_iff, imp case (CanonicalEmbedding.lean:228-242):
-- Forward: uses backward IH for psi (ih_ψ.mpr)
-- Backward: uses forward IH for psi (ih_ψ.mp) and backward IH for chi (ih_χ.mpr)
```

### Constant-history collapse
```lean
-- truth_at G(phi) at (constant_history w, t) expands to:
-- forall s >= t, truth_at phi at (constant_history w, s)
-- Since constant_history.states s _ = w for all s,
-- this collapses to: forall s >= t, truth_at phi at (w, s)
-- On constant history, phi at (w, s) = phi at (w, t) (same state)
-- So G(phi) at (w, t) = phi at (w, t) -- cannot distinguish G(phi) from phi
```

### Size comparison for contrapositive
```
sizeOf(psi.imp chi) = 1 + sizeOf(psi) + sizeOf(chi)
sizeOf((chi.imp bot).imp (psi.imp bot))
  = 1 + (1 + sizeOf(chi) + 1) + (1 + sizeOf(psi) + 1)
  = 5 + sizeOf(chi) + sizeOf(psi)
  > sizeOf(psi.imp chi)  -- strictly larger, IH fails
```

### Relevant sorry-free infrastructure
- `G_iff_mcs` (TruthLemma.lean:124): bidirectional, sorry-free
- `H_iff_mcs` (TruthLemma.lean:137): bidirectional, sorry-free
- `box_iff_mcs` (TruthLemma.lean:150): bidirectional, sorry-free
- `imp_iff_mcs` (TruthLemma.lean:74): bidirectional, sorry-free
- `fragment_truth_iff` (CanonicalEmbedding.lean:213): bidirectional for temporal-free, sorry-free
- `fragment_completeness` (CanonicalEmbedding.lean:310): sorry-free
- `canonical_task_frame` (CanonicalEmbedding.lean:108): sorry-free, permissive task_rel
- `bx_le_refl` (Frame.lean): sorry-free
- `bx_le_trans` (Frame.lean): sorry-free
- `bx_G_forward` (TruthLemma.lean): sorry-free
- `bx_G_backward` (TruthLemma.lean): sorry-free

### Key axioms available
- BX1 `temp_t_future`: `G(phi) -> phi` (reflexivity)
- BX4 `connect_future`: `phi -> G(P(phi))` (temporal connectedness)
- `temp_k_dist`: `G(phi -> psi) -> (G(phi) -> G(psi))` (distribution)
- `temp_4`: `G(phi) -> G(G(phi))` (transitivity)
- prop_s, prop_k, ex_falso, peirce (classical propositional base)
- Deduction theorem: `[A] |- B` iff `|- A -> B` (Core/DeductionTheorem.lean, sorry-free)

## Confidence Level

**Overall**: Medium (50%)

The problem is genuinely difficult. All approaches that avoid a proper canonical model construction face the same fundamental barrier: the imp case of the truth bridge requires bidirectionality, and the backward direction for G requires the model to capture the full bx_le successor set. No purely proof-theoretic shortcut exists because the imp case mixes syntactic (MCS membership) and semantic (truth) reasoning inextricably.

**Approach A** (canonical history through bx_le chain) is the most mathematically sound but requires significant infrastructure. It essentially re-derives part of the parametric completeness proof specifically for the USF fragment.

**Approach C** (leverage existing parametric infrastructure) is the most practical if the G/H temporal coherence in the BFMCS construction is already sorry-free. This should be the first thing to check: examine `ParametricTruthLemma.lean` and `Bundle/Construction.lean` for their sorry status on G/H cases.

**The two-point WorldHistory approach from prior research (v4 plan)** has a fundamental gap in the backward G direction that has not been resolved. The plan acknowledges this ("may need G_iff_mcs directly rather than going through semantic truth") but does not provide a concrete solution. The v4 plan's Strategy C ("alternative model" with richer omega) is essentially Approach A from this report.
