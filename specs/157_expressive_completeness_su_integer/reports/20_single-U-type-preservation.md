# Single-U-Type Preservation Analysis

## Question

Can `single_U_formula_separable_noax` be strengthened so the separated witness
preserves `has_single_U_type`? This would make the theorem self-contained
(the depth >= 2 `.snce` case could use the IH directly).

## Case-by-Case Analysis

### Structural cases (atom, bot, imp, box, untl)

| Case | Preserves? | Justification |
|------|-----------|---------------|
| `.atom a` | YES | Witness is `.atom a` itself (no `.untl` nodes) |
| `.bot` | YES | Witness is `.bot` itself |
| `.imp a b` | YES | `imp_separable` produces `.imp a' b'`; preservation by `has_single_U_type_imp` |
| `.box _` | YES | Witness is `.box _` itself (separated, no change) |
| `.untl A B` | YES | Witness is `.untl A B` itself; `has_single_U_type_untl` applies |

### `.snce C F` at depth 0 (both C, F U-free)

**YES** -- Witness is `.snce C F` itself (already separated). No `.untl` nodes
exist since C, F are U-free. `has_single_U_type` holds vacuously.

### `.snce C F` at depth 1 (THE CRITICAL CASE)

The proof calls `snce_single_U_depth_one_separable`, which uses the event-split
decomposition and Cases 1-8. Analysis of each case's witness:

**Case 1: S(a ^ U(A,B), q)** -- witness is `case1_psi a q A B`:

```
or (or
  (and (and (and (snce a q) (snce a B)) B) (untl A B))
  (and (and A (snce a B)) (snce a q)))
(snce (and (and (and A q) (snce a B)) (snce a q)) q)
```

**PRESERVES** -- The only `.untl` node is `.untl A B`. All `.snce` subterms
have U-free arguments (since a, q, A, B are all U-free).

**Case 2: S(a ^ neg U(A,B), q)** -- witness from `elim_case_2_gen`:

```
or psi_l (case1_psi a q (neg_A ^ neg_B) (neg A))
```

where `psi_l` contains `.all_future (neg A)` which expands to:
```
.imp (.untl (.imp (.imp A .bot) .bot) (.imp .bot .bot)) .bot
```

**DOES NOT PRESERVE** -- The `.untl` inside `all_future(neg A)` has arguments
`(neg(neg A), top)`, not `(A, B)`. Additionally, `case1_psi` is called with
U-args `(neg A ^ neg B, neg A)`, producing `.untl (neg A ^ neg B) (neg A)`.

Root cause: `neg_until_equiv` decomposes `neg U(A,B)` as
`G(neg A) or U(neg A ^ neg B, neg A)`, introducing `.untl` with different args.

**Case 3: S(a, q v U(A,B))** -- uses Case 2 internally.
**DOES NOT PRESERVE** (inherits Case 2's problem).

**Case 4: S(a, q v neg U(A,B))** -- witness is:
```
and (neg (all_past (neg a))) (neg (case1_psi (neg a ^ neg q) (neg a) A B))
```

**PRESERVES** -- `all_past(neg a)` contains `.snce` but no `.untl` nodes.
The `case1_psi` variant contains only `.untl A B`.

**Cases 5-8** (DedekindZ.lean) -- all use `elim_case_2_gen` either directly
or indirectly:

| Case | Direct/Indirect Case 2 use | Preserves? |
|------|---------------------------|-----------|
| 5 | `snce_combined_notU_separable` -> `elim_case_2_gen` | NO |
| 6 | Complex; uses Case 5 recursively | NO |
| 7 | `snce_Ufree_event_qNotU_guard_separable` (Case 4 OK) + Case 8 (NO) | NO |
| 8 | `elim_case_2_gen` directly | NO |

### `.snce C F` at depth >= 2

Uses IH on C, F (producing separated witnesses) then box-normalizes and calls
`no_S_nested_in_U_separable_param` with `all_separable` callback. Even if we
strengthened the IH, the leaf case (`snce_single_U_depth_one_separable`) fails
to preserve single-U-type, breaking the chain.

### Box-normalization

`replace_box_with_top` **PRESERVES** `has_single_U_type` with box-normalized
args -- already proved as `replace_box_preserves_single_U_type` (Hierarchy.lean
line 2095).

### Boolean combinators

`or_separable`, `and_separable`, `neg_separable`, `imp_separable` all
**PRESERVE** `has_single_U_type` -- the witness is the corresponding boolean
combination of sub-witnesses, and the existing helper lemmas
(`has_single_U_type_or`, etc.) apply.

## Blocker: Case 2 Witnesses Contain Foreign `.untl` Nodes

The fundamental obstacle is `elim_case_2_gen`. Its proof decomposes
`neg U(A,B)` via `neg_until_equiv`:

```
neg U(A,B)  <->  G(neg A)  or  U(neg A ^ neg B, neg A)
```

Both disjuncts introduce `.untl` with arguments other than `(A, B)`:
- `G(neg A) = neg(untl(neg(neg A), top))` -- has `.untl (neg neg A) top`
- `U(neg A ^ neg B, neg A)` -- has `.untl (neg A ^ neg B) (neg A)`

These foreign `.untl` nodes propagate into the final witness, preventing
`has_single_U_type _ A B`.

## Feasibility Assessment: Solution A FAILS

**Solution A cannot work with the current proof architecture.** The
single-U-type preservation requirement fails at the depth-1 leaf case
because Cases 2, 3, 5, 6, 7, 8 produce witnesses with `.untl` nodes
whose arguments differ from `(A, B)`.

### Could an alternative Case 2 proof fix this?

Potentially, but it would require a fundamentally different approach:
instead of using `neg_until_equiv` (which introduces foreign `.untl` types),
one would need to find a separated formula for `S(a ^ neg U(A,B), q)`
that uses ONLY `.untl A B` (or no `.untl` at all).

This is a deep mathematical question about whether the separated equivalent
of `S(a ^ neg U(A,B), q)` can be expressed using only `U(A,B)` (not
`U(neg A ^ neg B, neg A)` or `G(neg A)`). On integer time, this is
unlikely because `neg_until_equiv` is the canonical decomposition.

### Alternative approach: weaken the requirement

Instead of requiring `has_single_U_type psi A B` on the witness, consider:
1. Tracking `no_S_nested_in_U` preservation (already established)
2. Using `U_nesting_depth <= 1` preservation (the witness `.untl` args
   are all U-free since a, q, A, B are U-free)

Both of these are already available and suffice for the depth >= 2 case
to call `lemma_10_2_6_self_contained` instead of `all_separable`.

## Estimated LOC (if attempting anyway)

| Component | Difficulty | Est. LOC |
|-----------|-----------|---------|
| Case 1 preservation proof | Easy | ~20 |
| Case 4 preservation proof | Easy | ~20 |
| Boolean combinator proofs | Already done | 0 |
| replace_box_with_top proof | Already done | 0 |
| **Case 2 redesign** | **Infeasible with current approach** | **N/A** |

## Recommendation

Abandon Solution A. The depth >= 2 case should instead use the existing
`lemma_10_2_6_self_contained` (which works with `no_S_nested_in_U` +
`U_nesting_depth <= 1`) or `no_S_nested_in_U_separable_noax` directly.
The callback chain that currently uses `all_separable` can be replaced
without requiring single-U-type preservation on the witnesses.
