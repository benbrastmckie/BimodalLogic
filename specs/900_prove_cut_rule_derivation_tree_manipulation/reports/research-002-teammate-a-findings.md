# Teammate A Findings: Cut Elimination and Derivation Composition

## Key Findings

### 1. Cut Elimination Is Not Needed -- The Problem Is Semantic, Not Proof-Theoretic

The blocker is **not** a missing cut rule or derivation composition infrastructure. The codebase already has everything needed for proof composition:

- **Deduction theorem** (`deduction_theorem`): Converts `A :: Gamma |- B` to `Gamma |- A -> B`
- **Implication transitivity** (`imp_trans`): Chains `|- A -> B` and `|- B -> C` to `|- A -> C`
- **Generalized necessitation** (`generalized_modal_k`, `generalized_temporal_k`, `generalized_past_k`)
- **addFormula_preserves_consistent_of_theorem**: If `|- phi` and `S` is consistent, then `insert phi S` is consistent
- **T-axioms**: `|- Box psi -> psi`, `|- G psi -> psi`, `|- H psi -> psi`

The real blocker is that the `boxPositive` case in `processWorkItem_preserves_consistent` adds `psi` to ALL families at the current time, but needs to show `SetConsistent (insert psi entry.formulas)` for **every** entry, including those at families where `Box psi` is NOT present.

### 2. New Theorem: `insert_consistent_of_derivable_parent` (VERIFIED, compiles)

I have verified that the following theorem compiles in Lean 4 with zero sorries:

```lean
noncomputable def insert_consistent_of_derivable_parent
    {S : Set Formula} {parent child : Formula}
    (h_S_cons : SetConsistent S)
    (h_parent_in : parent ∈ S)
    (h_derives : |- parent.imp child) :
    SetConsistent (insert child S)
```

**This theorem says**: If `S` is consistent, `parent` is in `S`, and `|- parent -> child` is a theorem, then `insert child S` is consistent.

**Proof strategy**: Assume `L` from `insert child S` derives bot. If `child` is not in `L`, `L` is from `S`, contradicting `SetConsistent S`. If `child` is in `L`, use the deduction theorem to get `(L \ {child}) |- child -> bot`, then weaken `|- parent -> child` to context `(L \ {child})`, modus ponens gives `parent :: (L \ {child}) |- bot`, contradicting `SetConsistent S` since all those formulas are in `S`.

**Three verified corollaries** (also compile with zero sorries):

```lean
-- If Box psi is in S, then insert psi S is consistent
insert_psi_consistent_of_box_psi_in : SetConsistent S -> Box psi in S -> SetConsistent (insert psi S)

-- If G psi is in S, then insert psi S is consistent
insert_psi_consistent_of_g_psi_in : SetConsistent S -> G psi in S -> SetConsistent (insert psi S)

-- If H psi is in S, then insert psi S is consistent
insert_psi_consistent_of_h_psi_in : SetConsistent S -> H psi in S -> SetConsistent (insert psi S)
```

These corollaries directly solve the compatibility obligation IF the parent formula (Box/G/H psi) is present in the target entry.

### 3. The Deep Problem: Parent Formula Absent at Target Positions

The `insert_consistent_of_derivable_parent` theorem requires `parent in S`. For the `boxPositive` case:
- At the processing family `f`: `Box psi` IS in `entry.formulas` (by `h_in_seed`). **SOLVED.**
- At other families `f' != f`: `Box psi` is NOT in `entry.formulas`. **NOT SOLVED.**

**Why simply propagating `Box psi` to other families does not work either**: Inserting `Box psi` into `entry.formulas` at `f'` faces the same problem -- we need `SetConsistent (insert (Box psi) entry.formulas)` at `f'`, which requires some formula already in that entry to derive `Box psi`. There is no such formula.

**Concrete counterexample showing the general approach fails**: Consider:
- Family 0, time 0: `{Box p}` (consistent)
- Family 1, time 0: `{neg p}` (consistent)
- Processing `Box p` at family 0 tries to add `p` to family 1
- But `{neg p, p}` is **inconsistent**

The key question is: **can this situation actually arise during worklist processing?**

### 4. Analysis: Can Contradictory Positions Arise?

The seed starts from a single consistent formula `phi` at position `(0, 0)`. All other formulas and positions are created by worklist processing.

**How `neg p` could appear at family 1**: Only via `boxNegative` processing. If `neg(Box p)` is at some position, processing it creates a new family with `{neg p}`.

**How `Box p` could appear at family 0**: It must be a subformula of the original `phi` or of some processed formula.

**Can both appear?**: For `Box p` and `neg(Box p)` to both be in the seed at the same time, they must be at DIFFERENT positions (same position would violate per-entry consistency). The worklist processes them in some order:

1. If `Box p` is processed FIRST: `p` is added to all EXISTING families. Family 1 does not exist yet (it is created later by `neg(Box p)` processing). So `p` is NOT added to family 1. Later, `neg(Box p)` creates family 1 with `{neg p}`. No conflict.

2. If `neg(Box p)` is processed FIRST: Family 1 is created with `{neg p}`. Later, `Box p` tries to add `p` to ALL families INCLUDING family 1. Conflict: `{neg p, p}` is inconsistent!

**CONCLUSION**: The conflict CAN arise depending on processing order. The current algorithm is potentially unsound for maintaining per-entry `SeedConsistent`.

### 5. Recommended Solutions (Ordered by Preference)

#### Solution A: Process Positive Before Negative (Algorithm Constraint) -- RECOMMENDED

Ensure that `boxPositive` work items are always processed BEFORE `boxNegative` work items for the same base formula. This prevents the counterexample scenario.

**Implementation**: Sort the worklist so positive modal items have priority. Since the worklist is fuel-based (not well-founded), this is a simple ordering change.

**Why it works**: If `Box psi` is processed before `neg(Box psi)`, then when `psi` is added to all families, no family yet contains `neg psi`. Later, when `neg(Box psi)` creates a new family with `neg psi`, the work item for `neg psi` at the new family does NOT trigger adding `neg psi` to existing families (it only adds to the new family).

**Risk**: Requires proving that the ordering constraint is maintained, and that it does not affect termination or closure properties.

#### Solution B: Weaken SeedConsistent to GlobalSeedConsistent -- CLEANEST MATHEMATICALLY

Replace per-entry `SeedConsistent` with a global consistency invariant:

```lean
def GlobalSeedConsistent (seed : ModelSeed) : Prop :=
  SetConsistent (Set.iUnion (fun i =>
    if h : i < seed.entries.length then seed.entries[i].formulas else {}))
```

This says: the union of ALL formula sets across all entries is consistent.

**Why per-entry consistency follows at the end**: After the Lindenbaum extension step, each entry is extended to an MCS. Per-entry consistency is needed there, but it follows from global consistency because each entry's formulas are a subset of the globally consistent union.

**Wait -- this is WRONG.** `{p, neg p}` has a globally consistent union `{p, neg p}` only if it is consistent, which it is NOT. Global consistency does not help if individual entries can contain contradictions.

Actually, the point of global consistency is different. It says: the union of formulas across ALL entries is consistent. This means no finite subset from any combination of entries can derive bot. In particular, for any single entry, its formulas are a subset of the global union, so they are consistent. **Global consistency implies per-entry consistency.**

But can global consistency be maintained? When `Box p` adds `p` to a family that contains `neg p`, the global union now contains `{p, neg p, ...}`, which is inconsistent. So global consistency would also be violated.

**CONCLUSION**: Global consistency has the same problem. The issue is fundamental.

#### Solution C: Track Which Formulas Originate from the Same Source (Provenance Invariant)

Maintain an invariant that all formulas at all positions are jointly consistent with the original formula `phi`:

```lean
def ProvenanceConsistent (seed : ModelSeed) (phi : Formula) : Prop :=
  forall entry in seed.entries,
    SetConsistent (insert phi entry.formulas)
```

**Why this helps**: If all entries are consistent WITH `phi`, and `psi` is derivable from `phi` (e.g., via T-axiom from `Box psi` which is derivable from `phi`), then by `insert_consistent_of_derivable_parent`, adding `psi` to any entry is safe -- because `phi` is compatible with the entry, and `phi -> ... -> psi` is a theorem chain.

**The key observation**: Since all formulas in the seed are ultimately derived from the original `phi` via subformula decomposition, we can chain: `phi -> ... -> Box psi -> psi`. If `phi in S` and `|- phi -> psi` (via multi-step derivation), then `insert psi S` is consistent.

But `phi` is NOT in every entry's formulas. It is only at `(0, 0)`.

**REFINED VERSION**: Track that every entry contains a formula that is "compatible" with the processing chain from `phi`.

This is getting complex. Let me propose the simplest correct solution.

#### Solution D: Use `addFormula_preserves_consistent_of_theorem` for Theorems -- PARTIAL FIX

If `psi` happens to be a THEOREM (derivable from empty context), then `addFormula_preserves_consistent_of_theorem` applies directly. But `psi` is generally NOT a theorem (it is an arbitrary subformula).

#### Solution E: Modify Algorithm to Only Add `psi` Where `Box psi` Is Present -- CORRECT AND SIMPLE

**DO NOT add `psi` to ALL families.** Instead, add `psi` only to the family where `Box psi` is processed. Create work items for `Box psi` at other families (so that when those are processed, `psi` gets added there too via T-axiom).

```lean
| .boxPositive psi =>
    -- Add Box psi to current position (already there by h_in_seed)
    let seed1 := state.seed.addFormula item.famIdx item.timeIdx (Formula.box psi) .universal_target
    -- Add psi to CURRENT family only (justified by T-axiom)
    let seed2 := seed1.addFormula item.famIdx item.timeIdx psi .universal_target
    -- Create work items for Box psi at ALL OTHER families
    let familyIndices := seed2.familyIndices
    let newWork := familyIndices.map (fun f => ⟨Formula.box psi, f, item.timeIdx⟩)
                   ++ [⟨psi, item.famIdx, item.timeIdx⟩]
    (newWork, { state with seed := seed2 })
```

When `Box psi` is processed at family `f'`, the same logic applies: `Box psi` is in the entry (from being a work item that got added to the seed), so `psi` can be added via T-axiom.

**But wait**: Work items need their formula to already be in the seed at their position (by the strengthened `WorklistInvariant`). If we create a work item `(Box psi, f', t)`, we need `Box psi` to be in the seed at `(f', t)`. But we just said we do NOT add `Box psi` to other families...

**REVISED**: Propagate `Box psi` to all families (adding it to their entries), THEN create work items for `Box psi` at each family:

```lean
| .boxPositive psi =>
    let seed1 := state.seed.addFormula item.famIdx item.timeIdx (Formula.box psi) .universal_target
    let familyIndices := seed1.familyIndices
    -- Add Box psi to ALL families first
    let seed2 := familyIndices.foldl (fun s f =>
        s.addFormula f item.timeIdx (Formula.box psi) .universal_target) seed1
    -- Create work items for Box psi at each family (to process further)
    let newWork := familyIndices.map (fun f => ⟨Formula.box psi, f, item.timeIdx⟩)
    (newWork, { state with seed := seed2 })
```

Now when work item `(Box psi, f', t)` is processed: `Box psi` is already in the entry (from foldl above), so `h_in_seed` holds. The `boxPositive` case fires again, adds `psi` to `f'` (justified by T-axiom since `Box psi` is in the entry).

**BUT**: Adding `Box psi` to family `f'` still requires the compatibility proof! We need `SetConsistent (insert (Box psi) entry.formulas)` at `f'`. This has the SAME problem.

### 6. The Root Cause and True Solution

**Root cause**: `SeedConsistent` (per-entry consistency) is the WRONG invariant for a worklist algorithm that propagates formulas across positions. Propagating formulas to entries that might contain their negations is fundamentally incompatible with maintaining per-entry consistency.

**True solution**: Change what the consistency invariant means. The seed is not meant to represent final consistent sets -- it is a **PRE-SEED** that will be extended to MCSs via Lindenbaum's lemma. What matters is not that each entry is individually consistent, but that the FINAL model (after Lindenbaum extension) is consistent.

The correct invariant is one of:

1. **Theorem consistency**: Every formula added to the seed is `FormulaConsistent` (on its own). This is weaker than `SeedConsistent` but sufficient for the Lindenbaum extension to work, because each formula can individually be extended to an MCS.

2. **Pairwise consistency with the original formula**: For every entry, `{phi} union entry.formulas` is consistent, where `phi` is the original formula. This ensures that the Lindenbaum extension starting from `phi` can include all seed formulas.

3. **Abandon per-entry consistency entirely during worklist processing**. Prove `SeedConsistent` at the END of processing by showing the completed seed (with all closures) is consistent. This would use the closure properties (ModalClosed, GClosed, HClosed) to argue consistency via a semantic/model-theoretic argument.

**My recommendation is option 3**: Prove `SeedConsistent` as a CONSEQUENCE of the completed seed's closure properties, not as an invariant maintained during processing. This is mathematically cleaner and avoids the cross-position compatibility problem entirely.

The argument: the completed seed has properties ModalClosed, GClosed, HClosed. By the soundness theorem, any model satisfying these closure properties is consistent (because the logic is sound). Therefore the seed entries, which are subsets of what the model assigns to each world/time, are consistent.

## Recommended Approach

**Prove `SeedConsistent` as a post-condition of `buildSeedComplete`, not as a loop invariant of `processWorklist`.**

### Concrete Steps

1. **Remove `SeedConsistent` from `WorklistInvariant`**. Replace with a weaker invariant like `FormulaConsistent` for every formula in the seed.

2. **Complete Phase 5 (closure proofs) first**. Prove `ModalClosed`, `GClosed`, `HClosed` for the output of `buildSeedComplete`.

3. **Prove `SeedConsistent` from closure properties**. The argument: if the completed seed has all closures, and the original formula is consistent, then each entry is consistent. This follows from a semantic argument: the closed seed can be seen as a description of a Kripke model, and soundness ensures no entry derives bot.

4. **Alternatively**: Use the `insert_consistent_of_derivable_parent` theorem (verified, compiles) to prove consistency entry-by-entry in the completed seed. In the completed seed, every entry at time `t` contains `Box psi` (by ModalClosed) whenever `psi` is there. So the entries are self-consistent.

### Step 4 Detailed Plan

After Phase 5, `ModalClosed` gives us: if `Box psi` is at `(f, t)`, then `psi` is at `(f', t)` for all `f'`. But also (by the algorithm): if `Box psi` is at `(f, t)`, then `Box psi` was derived from some formula and is `FormulaConsistent`.

For the completed seed, we can prove per-entry consistency by induction on the formulas in each entry:
- Start with the empty set (consistent)
- Add formulas one by one
- For each formula `chi` added to entry at `(f, t)`:
  - Either `chi` is a theorem (use `addFormula_preserves_consistent_of_theorem`)
  - Or `chi` is derivable from some other formula already in the entry (use `insert_consistent_of_derivable_parent`)

The key insight from ModalClosed: whenever `psi` is in an entry, `Box psi` is ALSO in that entry (because the seed is ModalClosed). So every `psi` has its "parent" `Box psi` in the same entry, and the T-axiom derivation justifies its presence.

Wait -- ModalClosed says: if `Box psi` at `(f, t)`, then `psi` at `(f', t)` for all `f'`. It does NOT say: if `psi` at `(f', t)`, then `Box psi` at `(f', t)`. The direction is wrong!

**CORRECTED**: We need to track not just that `psi` is everywhere, but that `Box psi` is everywhere. This is a separate closure property:

```lean
def BoxPropagated (seed : ModelSeed) : Prop :=
  forall f t psi,
    Formula.box psi in seed.getFormulas f t ->
    forall f', seed.hasPosition f' t ->
      Formula.box psi in seed.getFormulas f' t
```

If we add this to the algorithm (propagate `Box psi` to all families when processing `boxPositive`), then in the completed seed, every entry that contains `psi` (from ModalClosed) also contains `Box psi` (from BoxPropagated, since `Box psi` triggered the addition of `psi`). Then `insert_consistent_of_derivable_parent` applies.

But adding `Box psi` to entries still requires the compatibility proof...

**FINAL RESOLUTION**: The bootstrapping problem resolves if we process Box formulas before their contents. In the completed seed:

1. `FormulaConsistent(Box psi)` (maintained as a per-formula invariant)
2. `Box psi` is at ALL families (by BoxPropagated)
3. `psi` is at ALL families (by ModalClosed)

For per-entry consistency, process the formulas in the completed seed by "level":
- Level 0: The original formula `phi` at `(0, 0)`. Singleton, consistent.
- Level 1: Direct subformulas from decomposition. Each is FormulaConsistent.
- Level 2: Propagated formulas. Each is derivable from a Level 1 formula via T-axiom.

The consistency of the completed seed follows from the fact that all formulas in each entry are derivable from the original formula `phi` via the axioms and rules of the logic. Since `phi` is consistent and the logic is sound, no entry can be inconsistent.

**THIS is the correct argument, and it requires formalizing "all formulas are consequences of phi".**

## Evidence

### Verified Compilations (zero sorries)
- `insert_consistent_of_derivable_parent` -- NEW theorem, verified compilation
- `insert_psi_consistent_of_box_psi_in` -- corollary using T-axiom
- `insert_psi_consistent_of_g_psi_in` -- corollary using temporal T-axiom
- `insert_psi_consistent_of_h_psi_in` -- corollary using temporal T-axiom

### Verified Local Declarations
- `box_inner_consistent` -- proven
- `all_future_inner_consistent` -- proven
- `all_past_inner_consistent` -- proven
- `neg_box_neg_inner_consistent` -- proven
- `neg_future_neg_inner_consistent` -- proven
- `neg_past_neg_inner_consistent` -- proven
- `addFormula_seed_preserves_consistent` -- proven, requires `h_compat` hypothesis
- `addFormula_preserves_consistent_of_theorem` -- proven
- `foldl_addFormula_preserves_consistent` -- proven
- `imp_trans` -- proven in Combinators.lean
- `deduction_theorem` -- proven in DeductionTheorem.lean
- `generalized_modal_k` -- proven in GeneralizedNecessitation.lean

### Mathlib Patterns Found
- Mathlib does NOT have formalizations of Hilbert-style proof system metatheorems
- The proof infrastructure is entirely custom to this codebase
- `FirstOrder.Language.Theory.IsMaximal` in Mathlib is for first-order logic, different setting

### Key Axioms Available
- `Axiom.modal_t`: `|- Box phi -> phi`
- `Axiom.modal_4`: `|- Box phi -> Box Box phi`
- `Axiom.modal_k_dist`: `|- Box(phi -> psi) -> (Box phi -> Box psi)`
- `Axiom.modal_b`: `|- phi -> Box Diamond phi`
- `Axiom.modal_5_collapse`: `|- Diamond Box phi -> Box phi`
- `Axiom.temp_t_future`: `|- G phi -> phi`
- `Axiom.temp_t_past`: `|- H phi -> phi`
- `Axiom.temp_k_dist`: `|- G(phi -> psi) -> (G phi -> G psi)`

## Confidence Level

**Medium-High** for the overall analysis, **High** for the `insert_consistent_of_derivable_parent` theorem.

The analysis reveals that the blocker is deeper than initially characterized. It is not about missing proof composition infrastructure (which is complete), but about the fundamental incompatibility between per-entry consistency invariants and cross-position formula propagation. The solution requires either:

1. An algorithm modification that ensures parent formulas are present before children (with a proof that this ordering is achievable), OR
2. Weakening the consistency invariant during worklist processing and proving consistency as a post-condition of the completed seed, OR
3. A completely different approach to the consistency argument.

My recommendation is option 2 (post-condition consistency), with the `insert_consistent_of_derivable_parent` theorem as a key building block for the final consistency proof after closure properties are established.

## Appendix: Why Pure Cut Elimination Does Not Apply

"Cut elimination" in sequent calculus is about removing the cut rule while preserving provability. This codebase uses a Hilbert-style system where "cut" is implicit via modus ponens + deduction theorem. The infrastructure for derivation composition is already complete. The blocker is about set-theoretic consistency preservation under formula insertion across structurally unrelated positions in a model seed -- a problem that has no analog in standard cut elimination theory.
