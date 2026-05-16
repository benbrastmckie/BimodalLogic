# Teammate A: Primary Implementation Approach for Reynolds Pipeline Activation

## Key Findings

### 1. Sorry Dependency Graph (Critical Path)

The sorry chain from `bx_completeness` to the remaining sorries is:

```
bx_completeness (Completeness.lean:162)
  → doets_countermodel_discrete (Transfer.lean:145, fallback)
    → NEEDS: chronicle_is_good (IntegerModel.lean:214)
      → NEEDS: very_good_implies_good (IntegerModel.lean:202)
        → NEEDS: finite_structures_good (foundation for one_class)
        → NEEDS: sum_preservation (DONE - task 154)
      → one_class (already proved, but calls finite_structures_good + contemp_equiv_is_equiv)
        → contemp_equiv_is_equiv transitivity (IntegerModel.lean:128)
          → NEEDS: finite_structures_good + sum_preservation
        → no_gaps_discrete (IntegerModel.lean:145)
          → NOT actually needed for one_class — one_class uses no_gaps_discrete 
            which is contrapositive: if not all equiv then boundary exists,
            but no_boundary_at_successor contradicts. So no_gaps_discrete IS needed.
    → NEEDS: ZIntervalStructure → TaskFrame Int bridge (Step 6, new code)
    → NEEDS: Truth transfer bridge (k_equiv implies eval agreement)
```

### 2. Analysis of Each Sorry

#### 2.1. `finite_structures_good` (IntegerModel.lean:90)

**Statement**: Every finite ordered monadic structure M is good (k-equivalent to some Z-interval structure).

**Proof strategy**: Since M is finite, it IS isomorphic to a finite interval of ℤ (after order-isomorphism to {0, 1, ..., n-1} ⊆ ℤ). The Z-interval structure Z has the same carrier (as a finite interval of ℤ) and the same interpretations. Then `k_equiv sig k M (Z.toOrdered sig)` follows because M and Z are order-isomorphic with matching predicate interpretations, which gives identical k-types.

**Key difficulty**: Building the order-isomorphism between a `Fintype` carrier with `LinearOrder` and a concrete Z-interval. Lean's `Fintype.equivFin` gives an equivalence to `Fin n` which is order-isomorphic to `{0, ..., n-1} ⊆ ℤ`.

**Confidence**: HIGH — this is standard and the Fintype/LinearOrder infrastructure is available in Mathlib.

#### 2.2. `contemp_equiv_is_equiv` — transitivity (IntegerModel.lean:128)

**Statement**: If a ~M b and b ~M c, then a ~M c. I.e., if M|[a,b] and M|[b,c] are very good, then M|[a,c] is very good.

**Reynolds 1994, Lemma 17 proof**: Suppose a < b < c (WLOG). Need to show M|[t,u] is good for any t ≤ u in [a,c]. Cases:
- If both t, u are in [a,b] or both in [b,c]: follows from very_good of M|[a,b] or M|[b,c].
- If t ≤ b ≤ u: M|[t,b] is good (from very_good of M|[a,b]) and M|[b+1,u] is good (from very_good of M|[b,c], since b+1 ∈ [b,c] in discrete order). Then M|[t,u] = M|[t,b] + M|[b+1,u] is a 2-element sum. By `doets_lemma_1_4` (sum_preservation), since each component is k-equiv to a Z-interval, the sum is k-equiv to the concatenation of two Z-intervals, which is itself a Z-interval.

**Key dependency**: `finite_structures_good` (for the successor case) + `doets_lemma_1_4` (sum_preservation, ALREADY PROVED in task 154).

**Confidence**: HIGH — the structure follows Reynolds directly.

#### 2.3. `no_gaps_discrete` (IntegerModel.lean:145)

**Statement**: If a and b are in different ~M classes, there exists c with c ~M a but succ(c) not ~M a.

**Proof strategy**: Since a ≁ b, WLOG a < b (or use symmetry). The set S = {x | a ~M x} is a class. Since a ∈ S and b ∉ S, and S is bounded above (by b), and the order is discrete, there's a maximum element c of S ∩ [a,b] (well-ordered downward from b). Then c ~M a but succ(c) ∉ S, i.e., ¬(a ~M succ(c)).

Actually, looking more carefully: we don't need well-foundedness. Since a ~M a, the class of a intersects [a,b]. Since b is not in the class, there must be a "boundary" — a largest c in [a,b] with a ~M c. In a discrete order, succ(c) exists and succ(c) ≤ b (since c < b). Then a ≁ succ(c).

**Key issue**: We need to formalize "there exists a largest c in the class within [a,b]". This uses the fact that ~M classes are intervals (convex). If the class of a is the interval [a, d] for some d, then c = d works. But formalizing convexity of classes requires showing ~M partitions into intervals.

**Alternative approach**: Use the contrapositive directly. The one_class theorem already proves this by contradiction anyway (no_gaps_discrete + no_boundary_at_successor). We can use the simple argument: by classical logic, either all points between a and b are equivalent to a, or some first failure exists. In the discrete case, if a ~M x for all x ∈ [a,b-1] but a ≁ b, then c = b-1 works (since succ(b-1) = b). More generally, use strong induction on the distance between a and b.

**Confidence**: MEDIUM — the mathematical argument is clear but formalizing "first failure in a discrete order" requires careful handling.

#### 2.4. `very_good_implies_good` (IntegerModel.lean:202)

**Statement**: If M is countable and very good, then M is good (k-equivalent to a Z-interval).

**Reynolds Lemma 16 proof**: If M is finite, done by `finite_structures_good`. If M is countably infinite:
- Case 1 (M has a beginning a₀ but no end): Choose a cofinal sequence a₀ < a₁ < a₂ < ... covering all of M. Each M|[aᵢ, aᵢ₊₁-1] is good (by very_good). Take Z_i ≡_k M|[aᵢ, aᵢ₊₁-1] with Z_i a finite interval of ℤ. By sum_preservation (doets_lemma_1_4), M ≡_k Σ(Z_i), and Σ(Z_i) is a half-infinite interval of ℤ.
- Case 2 (M has no beginning or end): Split at any point a₀, apply Case 1 on both halves, then combine.
- Case 3 (M has both endpoints): M is finite (in discrete case) → done.

**Key dependencies**: `finite_structures_good` + `doets_lemma_1_4` (sum_preservation).

**Key difficulty**: Constructing the cofinal sequence and showing the lexicographic sum of Z-intervals is itself a Z-interval. This uses `Countable` + `NoMaxOrder` to build the sequence, and the fact that a concatenation of consecutive Z-intervals is a Z-interval.

**Confidence**: MEDIUM-HIGH — the proof is constructive but involves nontrivial Lean plumbing (sequences, sum_preservation application).

#### 2.5. `chronicle_is_good` (IntegerModel.lean:214)

**Statement**: The chronicle-as-monadic-structure is good at any depth k.

**Proof strategy**: 
1. The chronicle (ChronicleAsPriorModel) has: Countable domain, SuccOrder, PredOrder, NoMaxOrder, NoMinOrder.
2. By `one_class`, all points are contemporaneously equivalent (one ~M class).
3. Having one class means M is very good (every subinterval is between equivalent points).
4. By `very_good_implies_good`, M is good.

But wait — `one_class` requires the sorries above to be closed. The dependency chain is:
- `chronicle_is_good` uses `one_class` + `very_good_implies_good`
- `one_class` uses `no_gaps_discrete` + `no_boundary_at_successor` + `contemp_equiv_is_equiv`
- `no_boundary_at_successor` uses `finite_structures_good`
- `contemp_equiv_is_equiv` transitivity uses `finite_structures_good` + `doets_lemma_1_4`
- `very_good_implies_good` uses `finite_structures_good` + `doets_lemma_1_4`

So the order of closure must be:
1. `finite_structures_good` (foundation)
2. `contemp_equiv_is_equiv` transitivity (uses #1 + sum_preservation)
3. `no_gaps_discrete` (uses #2)
4. `one_class` (already proved using #2 and #3 — will work once they're closed)
5. `very_good_implies_good` (uses #1 + sum_preservation)
6. `chronicle_is_good` (uses #4 + #5)

**Confidence**: HIGH — once the five prerequisites are closed, this is straightforward.

### 3. Step 6: ZIntervalStructure → TaskFrame Int Bridge

The existing `dd_countermodel_chronicle_discrete` uses `ParametricCanonicalTaskFrame Int` which is built from BFMCS/FMCS infrastructure. The Reynolds pipeline produces a `ZIntervalStructure sig` with carrier ℤ. We need to go from this to `TaskFrame Int`.

**Key insight from Reynolds Theorem 18**: The completeness argument uses:
1. Chronicle M₀ satisfies ¬φ at root (via `temporal_truth`)
2. k = operator_depth(φ) + 1
3. By `chronicle_is_good`, ∃ Z-interval Z with k_equiv sig k M₀ Z
4. Since k > quantifier_depth(table(φ)), and k_equiv implies agreement on sentences of depth ≤ k, both M₀ and Z satisfy the same monadic sentences of depth ≤ k
5. `∃t, eval M₀ (fun _ => t) (table sig atomMap φ.neg)` is a sentence of depth ≤ k
6. Therefore `∃t, eval Z (fun _ => t) (table sig atomMap φ.neg)` also holds
7. By `table_correctness`, this means `∃t, temporal_truth Z atomMap t φ.neg`

**The bridge needed**: Convert `ZIntervalStructure sig` (with carrier = ℤ, predicate interpretations, and a chosen point where ¬φ is true in temporal_truth sense) into the existential `∃ (F : TaskFrame Int) (TM : TaskModel F) (Omega : Set (WorldHistory F)) ...`.

**Simplest approach**: Define a "trivial" TaskFrame on Int:
- `WorldState = Unit` (single world state)
- `task_rel _ d _ = True` (all durations allowed — or use identity)
- Actually: `task_rel w d u ↔ w = u` (deterministic, single state)
- `WorldHistory`: domain = all of ℤ (convex), states = const Unit
- `ShiftClosed`: trivially, since there's only one history
- `valuation`: derived from the Z-interval's predicate interpretation at each time point
- `truth_at`: for atoms, uses `valuation`; for temporal operators, quantifies over the ℤ order

Wait — `truth_at` uses `WorldHistory` and `Omega` in a complex way for the box modality. The box operator requires: `∀ τ' ∈ Omega, truth_at M Omega τ' t φ`. So we need a single-world-history Omega where all temporal formulas work.

**Better approach**: Use the existing `ParametricCanonicalTaskFrame Int` infrastructure! Since the Z-interval gives us a valuation on ℤ (for each atom, whether it's true at each integer), we can construct:
- A single FMCS (family of MCS indexed by Int) where each MCS at position `n : Int` contains exactly the formulas true at `n` in the Z-model
- Then use the existing parametric representation machinery

**Even simpler approach** (recommended): Since the goal is `¬truth_at TM Omega τ t φ`, and the Z-model tells us temporal_truth gives ¬φ at some point, we can build a **minimal TaskFrame** that makes `truth_at` agree with `temporal_truth` on the Z-model:

```lean
-- Minimal TaskFrame Int: single world state, identity task relation
def minimalTaskFrame : TaskFrame Int where
  WorldState := Unit
  task_rel _ d _ := d = 0  -- wrong: not compositional

-- Actually for compositionality: all states equal
def trivialTaskFrame : TaskFrame Int where
  WorldState := Unit
  task_rel _ _ _ := True  -- ∀ w d u, True → need nullity_identity: True ↔ (w = u) FAILS
```

Actually this doesn't work because `nullity_identity` requires `task_rel w 0 u ↔ w = u`, which with a single world state means `True ↔ True`, which is fine when WorldState = Unit.

Wait: `task_rel w 0 u ↔ w = u` with `w u : Unit` means `task_rel () 0 () ↔ () = ()` = `task_rel () 0 () ↔ True`. So `task_rel () 0 ()` must be True. And for `forward_comp`: if all task_rel are True, then forward_comp is trivially satisfied. And for `converse`: True ↔ True.

So:
```lean
def singletonTaskFrame : TaskFrame Int where
  WorldState := Unit
  task_rel _ _ _ := True
  nullity_identity w u := ⟨fun _ => Subsingleton.elim w u, fun _ => trivial⟩
  forward_comp _ _ _ _ _ _ _ _ _ := trivial
  converse _ _ _ := ⟨fun _ => trivial, fun _ => trivial⟩
```

Then:
- `TaskModel` valuation: `valuation () a := Z.interp (atomMap (.atom a)) t₀` where t₀ is... no, we need the valuation to depend on time.

Wait, `truth_at` is defined as:
```
truth_at M Omega τ t φ
```
where `τ : WorldHistory F` and `t : D`. The key is that `truth_at` for atoms uses `M.valuation (τ.states t ht) a`. So the time enters via the world history's state assignment.

So we need a WorldHistory where `states t _ = ...` encodes the Z-model's information. But WorldState = Unit means `states` is always `()`. Then `valuation () a` is fixed, not time-dependent!

**This means the trivial TaskFrame approach doesn't work for atoms that vary over time.**

**Correct approach**: We need WorldState to encode enough to distinguish time points. The cleanest way:

```lean
def zModelTaskFrame (Z : ZIntervalStructure sig) : TaskFrame Int where
  WorldState := Int  -- world state = time index
  task_rel w d u := u = w + d  -- deterministic time advancement
  nullity_identity w u := ⟨fun h => by omega, fun h => by subst h; ring⟩
  forward_comp w u v x y _ _ h1 h2 := by subst h1; subst h2; ring
  converse w d u := ⟨fun h => by omega, fun h => by omega⟩
```

Then:
```lean
def zModelTaskModel (Z : ZIntervalStructure sig) (atomMap : sig.preds → Formula) :
    TaskModel (zModelTaskFrame Z) where
  valuation (w : Int) (a : Atom) := Z.interp (atomMap (.atom a)) w
```

WorldHistory:
```lean
def zModelHistory (Z : ZIntervalStructure sig) : WorldHistory (zModelTaskFrame Z) where
  domain := fun _ => True  -- all of Int
  convex := fun _ _ _ _ _ _ _ => trivial
  states t _ := t  -- state at time t = t itself
  respects_task s t _ _ _ := by simp [zModelTaskFrame]; ring
```

ShiftClosed with Omega = {zModelHistory Z} ∪ shifts:
Actually, `ShiftClosed Omega` requires that for any `τ ∈ Omega` and shift `d`, the shifted history `τ.shift d ∈ Omega`. With the deterministic frame where state = time, shift d maps states(t) = t to states(t+d) = t+d, which is the same as (states ∘ (+d)). So Omega = {all shifted copies} = {all translations of the identity history} which is just all histories of the form `states t _ := t + c` for various c. But actually with WorldState = Int and states t = t, a shift by d gives states' t = t + d (a different world state for the same physical time). This still satisfies respects_task since (t+d) + (s - t) = s + d = states' s. So Omega = Set.univ works if we define it carefully.

Actually, let me look at how the existing code handles it:

The existing `dd_countermodel_chronicle_discrete` uses:
- `ParametricCanonicalTaskFrame Int` with `WorldState = ParametricCanonicalWorldState` (pairs of MCS)
- A specific `ShiftClosedParametricCanonicalOmega`
- Complex truth lemma connecting `truth_at` to MCS membership

For the Reynolds pipeline, we need something MUCH simpler. The key insight:

**We need `truth_at TM Omega τ t φ ↔ temporal_truth Z atomMap t φ`**

With WorldState = Int, task_rel w d u iff u = w + d, states t = t:
- `truth_at` for atoms: `M.valuation (τ.states t ht) a = M.valuation t a`
- `truth_at` for G φ: `∀ s > t, truth_at M Omega τ s φ` (since domain = all of Int and there's one world history)
- `truth_at` for U(φ,ψ): `∃ s > t, truth_at M Omega τ s φ ∧ ∀ r, t < r → r < s → truth_at M Omega τ r ψ`
- `truth_at` for □φ: `∀ τ' ∈ Omega, truth_at M Omega τ' t φ`

For the Z-model where the box operator has a fixed semantics (from atomMap), we need box to be handled correctly. In `temporal_truth`, box is: `M.interp (atomMap (.box φ)) t`. In `truth_at`, box is the modal operator (universal over accessible worlds).

**Critical insight**: The `temporal_truth` definition treats `box φ` as an atomic predicate: `temporal_truth M atomMap t (.box φ) = M.interp (atomMap (.box φ)) t`. This means in the Z-model, box formulas are treated as propositional atoms — their truth at each point is simply read from the interpretation, NOT computed as a universal quantification over worlds.

So for the TaskFrame bridge, we need `truth_at TM Omega τ t (.box φ)` to equal `Z.interp (atomMap (.box φ)) t`. This means:
- For box, `truth_at` needs ALL world histories in Omega to agree: `∀ τ' ∈ Omega, truth_at M Omega τ' t φ`.
- With a singleton Omega (or Omega where all histories agree), this collapses to `truth_at M Omega τ t φ`.

**The simplest valid approach**: Use Omega = {τ} (singleton set). Then:
- `ShiftClosed {τ}` requires `τ.shift d ∈ {τ}` for all d, which means τ must be shift-invariant.
- With states t = t, shift by d gives states' t = states (t - d) = t - d ≠ t for d ≠ 0.

This doesn't work. We need Omega to contain all shifts.

**Alternative**: Omega = Set.univ (all valid world histories). Then ShiftClosed is trivial. But `truth_at` for box becomes: `∀ τ' (with valid history), truth_at M Omega τ' t φ`. This is TOO STRONG — it makes box a universal truth, not just the Z-model's interpretation.

**The fundamental mismatch**: `truth_at` for box quantifies over worlds, while `temporal_truth` for box just reads from the interpretation. The Reynolds pipeline produces a Z-model where box sub-formulas are handled via their MCS membership (since atomMap maps box subformulas to predicate symbols). The truth transfer from the chronicle to Z preserves the TABLE translation, which encodes box as an atom. But `truth_at` in the Lean semantics computes box as `∀ τ' ∈ Omega, truth_at ...`.

**Resolution**: The existing infrastructure handles this correctly. The `ParametricCanonicalTaskFrame` with `ParametricCanonicalTaskModel` and the BFMCS coherence conditions ensure that `truth_at` agrees with MCS membership. The Z-model inherits these from the chronicle.

**Recommended approach for Step 6**: Rather than building a minimal TaskFrame from scratch, **reuse the existing chronicle fallback infrastructure but with the Z-model's valuation**. The Z-model gives us a sequence of MCS assignments on ℤ (each `fmcs n` contains exactly the formulas true at integer n). We can construct a discrete FMCS over Int that matches the Z-model, then feed it into `ParametricCanonicalTaskFrame Int` + the restricted parametric truth lemma.

Actually, the SIMPLEST approach may be different:

**Key observation**: The existing `dd_countermodel_chronicle_discrete` already produces a sorry-free countermodel IF `succ_cofinal` were closed. The Reynolds pipeline's purpose is to BYPASS `succ_cofinal` entirely. But the existing proof structure of `dd_countermodel_chronicle_discrete` doesn't use `chronicle_is_good` or the Reynolds pipeline at all — it goes through BFMCS coherence.

So the Reynolds pipeline in `doets_countermodel_discrete` needs to produce the same output type but via a DIFFERENT path. The cleanest way is:

1. Use `chronicle_is_good` to get Z ≡_k chronicle
2. Show ¬φ is true in the Z-model (via k-equivalence + table_correctness)
3. From the Z-model, construct an FMCS on Int (MCS at each integer = set of formulas true at that point in Z)
4. Use existing `ParametricCanonicalTaskFrame Int` + truth lemma

But step 3 requires showing that the formulas true at each integer in the Z-model form an MCS. This is non-trivial.

**SIMPLEST PATH (recommended)**: Since the existing code already has the fallback to `dd_countermodel_chronicle_discrete`, and that function's only sorry is `succ_cofinal`, and the Reynolds pipeline produces a Z-model that DOESN'T need `succ_cofinal` — the simplest approach is to verify the proof-theoretic argument:

The k-equivalence between the chronicle and Z means they satisfy the same monadic sentences of quantifier depth ≤ k. The existential sentence `∃t, table(¬φ)(t)` has quantifier depth = operator_depth(¬φ) + 1 ≤ k. Since this sentence holds in the chronicle (by table_correctness + the fact that ¬φ is true at the root), it also holds in Z. Then by table_correctness applied to Z, ¬φ is true at some point in Z.

But we need to get from "¬φ is true at some point in Z as temporal_truth" to "¬truth_at ... φ" in the TaskFrame semantics. This is the real bridge.

### 4. The Missing Bridge: k_equiv → eval Agreement

**Critical missing theorem** (needed for truth transfer):

```lean
theorem k_equiv_preserves_eval (sig : MonadicSignature) (k : Nat)
    (M N : OrderedMonadicStructure sig)
    (h_equiv : k_equiv sig k M N)
    (α : MonadicFormula sig 0) (h_depth : α.quantifier_depth ≤ k) :
    eval M Fin.elim0 α ↔ eval N Fin.elim0 α
```

This theorem states that k-equivalent structures agree on all sentences of quantifier depth ≤ k. It's the standard Ehrenfeucht-Fraïssé theorem.

**Proof approach**: By induction on quantifier depth, using the normal form theory. Every sentence of quantifier depth ≤ k is equivalent to a Boolean combination of statements that are determined by the k-type. Since M and N have the same k-type (k_equiv), they agree.

More concretely: Each sentence α of depth ≤ k can be put in normal form: it's a disjunction of characteristic sentences (k-types). The truth of α is determined by which k-type the structure has. Since M and N have the same k-type, they agree on α.

**Implementation**: This requires showing that `eval M Fin.elim0 α` can be expressed in terms of `nf_eval_nf M k 0 Fin.elim0 _` for appropriate normal forms. This is the classical "formula to normal form" compilation.

**Difficulty**: HIGH — this is a significant piece of model-theoretic infrastructure. The NormalForm.lean file has the evaluation machinery but not the explicit compilation from MonadicFormula to NormalForm.

### 5. Alternative: Direct Truth Transfer Without eval Bridge

Instead of proving the general `k_equiv_preserves_eval` theorem, we can take a shortcut specific to the `table` translation:

**Observation**: The `table` function produces a `MonadicFormula sig 1` (one free variable). The existential closure `∃t, table(φ)(t)` is a sentence. If we can show that `nf_eval_nf` captures existential closures of table formulas, we avoid the general eval bridge.

Actually, there's an even simpler approach:

**The chronicle's MCS at root contains ¬φ. Via the parametric truth lemma machinery already proved, this means `temporal_truth (chronicleAsMonadicStructure M sig atomMap) atomMap root_point φ` is false. The table_correctness theorem then tells us `eval chronicle_structure env (table sig atomMap φ.neg)` is true at root_point. Since `table(φ.neg)` has quantifier depth ≤ operator_depth(φ.neg) ≤ k (by table_depth_bound), and the chronicle is k-equiv to Z, the same evaluation holds in Z. By table_correctness applied backwards, `temporal_truth Z atomMap some_point φ.neg` holds in Z.**

But the gap remains: we need `k_equiv_preserves_eval` (or something equivalent) to transfer the table formula evaluation.

## Recommended Approach

### Phase 1: Foundation (finite_structures_good)
- Prove by constructing an explicit order-isomorphism from the finite structure to a Z-interval
- Use `Fintype.equivFin` + `Fin.val` embedding into ℤ
- Show atom interpretation agreement gives k_equiv via identity on k-types
- **Estimated effort**: 2-3 hours

### Phase 2: Transitivity + One-Class Chain
- Close `contemp_equiv_is_equiv` transitivity using Reynolds Lemma 17 argument
- Close `no_gaps_discrete` using discrete induction
- Both depend on Phase 1 + sum_preservation (already done)
- **Estimated effort**: 3-4 hours

### Phase 3: very_good_implies_good
- Implement Reynolds Lemma 16 proof (cofinal sequence + sum_preservation)
- Requires careful Lean plumbing for the countable enumeration
- **Estimated effort**: 3-4 hours

### Phase 4: chronicle_is_good
- Chain: one_class → very_good → good
- **Estimated effort**: 1 hour (once phases 1-3 done)

### Phase 5: k_equiv_preserves_eval + Truth Transfer Bridge
- This is the hardest new piece
- Prove that k-equivalent structures agree on formulas of bounded quantifier depth
- Then wire: chronicle truth → table eval → k_equiv transfer → Z eval → table_correctness → Z temporal truth
- **Estimated effort**: 4-6 hours

### Phase 6: TaskFrame Int Bridge
- Define `zModelTaskFrame` and `zModelTaskModel` 
- OR: Construct FMCS from Z-model and use existing ParametricCanonical infrastructure
- Prove `truth_at` agrees with `temporal_truth` on the Z-model
- **Estimated effort**: 4-6 hours

### Phase 7: Wire Transfer.lean
- Replace the fallback with the full pipeline
- Verify `#print axioms bx_completeness` shows no sorryAx
- **Estimated effort**: 1-2 hours

## Evidence/Examples

- Reynolds 1994, Theorem 15 (Section 8, pp. 129-131): The proof assumes finite structures are good (trivially), proves Lemma 16 (very_good → good) via lexicographic sum, defines ~M via "very good subintervals", proves ~M is contemporaneous (Lemma 17), proves one-class (end of Section 8 using Prior axioms + no gaps).
- Reynolds 1994, Theorem 18 (Section 9, p. 131): The completeness proof chains: Burgess-Xu → chronicle → finite language restriction → Theorem 15 → Z-model → table transfer.
- Doets 1989, Lemma 1.4 (p. 227): Sum preservation. Already proved in task 154.
- The existing codebase already has all definitions in place; only proofs are missing.

## Confidence Level

**Overall**: MEDIUM-HIGH

- Phases 1-4 (closing IntegerModel sorries): HIGH confidence — Reynolds and the existing code structure make the path clear
- Phase 5 (k_equiv_preserves_eval): MEDIUM confidence — significant new infrastructure, but well-understood model theory
- Phase 6 (TaskFrame bridge): MEDIUM confidence — the box modality handling is the main challenge; may require careful integration with existing ParametricCanonical machinery
- Phase 7 (wiring): HIGH confidence — mechanical once phases 1-6 complete

**Total estimated effort**: 18-26 hours across all phases.
