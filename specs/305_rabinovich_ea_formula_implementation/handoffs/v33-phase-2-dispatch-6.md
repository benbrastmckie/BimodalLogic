# Phase 2 Dispatch 6 Handoff

## Status: PARTIAL

## Immediate Next Action
Fix the remaining build errors in the helper lemmas `buildRight_top_of_mono` and `buildLeft_top_of_mono` (Fin bound proofs inside refine blocks), then fix the forward direction proof (witness extraction and monotonicity) and the backward direction's `convert` calls.

## Current State
- File: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfDepth0Generalized.lean` (~1200 lines)
- The single sorry at line 574 (old) has been replaced with a full proof structure
- The proof uses `translateEF1` with a rank function defined via `nf_lt_bool` and `Finset.filter`
- Helper lemmas `buildRight_top_of_mono` and `buildLeft_top_of_mono` are defined but have Fin bound issues
- The rank infrastructure (injectivity, surjectivity, monotonicity, reflection) compiles except for proof-irrelevance issues that were fixed using `h_no_cycle`/`h_lt_acyclic`

## Architecture Decisions
1. **Rank function**: Defined as `nf_rank i = card { j | nf_lt_bool j i = true }` using `Finset.filter` on `Finset.univ`
2. **nf_lt_bool**: A Bool-valued function `fun j i => if h : j = i then false else sub_nf (.order j i h)` to avoid Prop/Bool coercion issues with `Finset.filter`
3. **nf_order_irrel**: Proof irrelevance for NF order atoms (used extensively)
4. **h_lt_acyclic**: Helper proving `nf_lt_bool i j = true -> nf_lt_bool j i = false` using `nf_lt_bool` directly (avoids proof-irrelevance issues)
5. **Forward direction**: Uses `h_extract_right`/`h_extract_left` to extract witnesses from buildRight_spec/buildLeft_spec chains, then builds `pts` piecewise (left witnesses, t, right witnesses) and proves monotonicity using chain transitivity helpers
6. **Backward direction**: Uses `buildRight_top_of_mono`/`buildLeft_top_of_mono` helper theorems to build the chains from a monotone `pts` function

## Key Obstacles Encountered
- **Prop vs Bool in Finset.filter**: Lean 4's `Finset.filter` requires `DecidablePred`, so using `Prop`-valued predicates with `dite` fails. Fixed by using `nf_lt_bool` which returns `Bool`
- **Proof irrelevance of NF order**: `AtomKind.order` takes a proof term, making `subst`, `rw`, and `▸` fragile. Fixed by using `h_lt_acyclic` which works with `nf_lt_bool` values instead of raw NF order atoms
- **Fin bound proofs inside refine/exact blocks**: `by omega` inside anonymous constructor `⟨...⟩` sometimes fails to see local hypotheses. Fixed by pre-computing bounds as `have` before the refine

## Sorry Inventory
No explicit `sorry` keywords remain in the file. The current build failures are type errors and tactic failures in proofs that are structurally written but have mechanical issues.

## Remaining Build Errors (~20)
1. **Helper lemmas (lines 328-378)**: `omega` and `No goals to be solved` in `buildRight_top_of_mono`/`buildLeft_top_of_mono` - Fin bound proofs inside `refine` blocks
2. **Forward direction (lines 886-976)**: Unsolved goals in witness extraction conversion, `List.get_map` (should be `List.getElem_map`), omega failures
3. **Backward direction (lines 1020+)**: `List.map_congr_left` argument and `convert` calls
