# Phase 5-6 Handoff: Truth Transfer + TaskFrame Construction

**Task**: 155 - reynolds_pipeline_activation
**Phase**: 5-6 (Truth Transfer via Existential Closure + TaskFrame Int Construction)
**Session**: sess_1778994101_edb9a1
**Status**: COMPLETED with 4 sorry's (2 structural bridging lemmas)

## What Was Done

Replaced the chronicle fallback in `Transfer.lean` with the full Reynolds pipeline:

1. **`k_equiv_preserves_sentence`** (PROVED, no sorry):
   k-equivalent structures agree on all monadic sentences of depth <= k.
   Direct application of `doets_lemma_1_1` with k-type equality.

2. **`truth_transfer`** (PROVED, no sorry):
   The core transfer lemma. Given k-equiv between M and N, temporal truth of
   psi at some point in M implies temporal truth of psi at some point in N.
   Proof: existential closure of table(psi), depth bound, k-equiv transfer,
   extract witness, table_correctness backwards.

3. **`unboundedZIntervalEquiv`** (PROVED, no sorry):
   OrderIso between Z.intervalCarrier (with lo=none, hi=none) and Z.

4. **`zIntervalTaskFrame`** (PROVED, no sorry):
   TaskFrame Int with Unit WorldState, task_rel = True everywhere.

5. **`zIntervalHistory`** (PROVED, no sorry):
   Universal WorldHistory with domain = True, states = ().

6. **`doets_countermodel_discrete`** (REWIRED):
   Full Reynolds pipeline replacing the chronicle fallback.
   Steps: extract chronicle -> build Z-interval (lo=none, hi=none, inline
   from chronicle_is_good) -> k_equiv_of_iso -> chronicle_truth (sorry) ->
   truth_transfer -> z_interval_countermodel (sorry).

## Remaining Sorries (4)

### 1. `chronicle_temporal_truth` (line 186)
**What**: `temporal_truth (chronicle) atomMap_fwd t psi <-> psi in fmcs t`
**Why sorry'd**: Full inductive truth lemma for the chronicle requiring:
- Atom case: atomMap_fwd/atomMap_rev section property
- Box case: single S5 class => box is identity
- Temporal cases: Prior-UZ/SZ validity in the chronicle
**To close**: ~100-150 lines of induction on formula structure.

### 2. `z_interval_countermodel` (line 286)
**What**: `temporal_truth (Z.toOrdered) atomMap_fwd s phi.neg -> not truth_at TM Omega tau z phi`
**Why sorry'd**: Inductive correspondence between `temporal_truth` on an
ordered monadic structure and `truth_at` on the TaskFrame Int. The atom/temporal
cases are straightforward (order matches), but the box case requires handling
the single S5 class semantics.
**To close**: ~100-150 lines of induction on formula structure.

### 3. `Nonempty sig.preds` (line 332)
**What**: `phi.predFormulas` is nonempty
**Why sorry'd**: Requires showing that any formula phi where phi.neg is in a
consistent set A must have at least one atom or box subformula. Minor.
**To close**: ~20 lines. Prove that purely bot/imp formulas are either
tautologies or contradictions, contradicting MCS membership.

### 4. `h_chronicle_truth` (line 371)
**What**: `temporal_truth M_chron atomMap_fwd chron.root_point phi.neg`
**Why sorry'd**: Instance of sorry 1 (chronicle_temporal_truth). Once sorry 1
is proved, this follows by applying it with the appropriate arguments.
**To close**: Direct application of `chronicle_temporal_truth` once proved.

## Key Decisions

1. Used `Set.univ` for Omega instead of singleton (avoids WorldHistory ext issues)
2. Used `task_rel = fun _ _ _ => True` (simplest valid TaskFrame for Unit WorldState)
3. Inlined the Z-interval construction from `chronicle_is_good` to retain `lo=none, hi=none` info
4. Did NOT attempt the full chronicle truth lemma (out of scope for phases 5-6)

## Verification

- `lake build`: passes with zero errors
- `truth_transfer`: fully proved, no sorry
- `k_equiv_preserves_sentence`: fully proved, no sorry
- Chronicle fallback: REMOVED from Transfer.lean
- Pipeline structure: correct and complete

## Next Action

The 4 remaining sorries are self-contained and can be closed independently:
- Sorry 1+4: Chronicle truth lemma (standard, ~150 lines)
- Sorry 2: truth_at <-> temporal_truth correspondence (standard, ~150 lines)
- Sorry 3: Nonempty predFormulas (minor, ~20 lines)

None of these depend on task 157 or Phase 3. They are purely infrastructure.
