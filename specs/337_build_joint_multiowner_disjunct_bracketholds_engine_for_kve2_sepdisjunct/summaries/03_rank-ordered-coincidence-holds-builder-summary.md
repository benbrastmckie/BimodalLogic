# Implementation Summary v3: Task #337 — Rank-Ordered Coincidence `holds` Builder

- **Status**: PARTIAL (Phase 1 delivered green + axiom-clean; Phases 2-6 BLOCKED — structural
  carrier/engine mismatch requiring an out-of-scope task-338 carrier edit)
- **Plan**: `plans/03_rank-ordered-coincidence-holds-builder.md`
- **File touched (additive only)**:
  `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean`

## Phase executed

### Phase 1 — honest coincidence carrier membership (COMPLETED, green, axiom-clean)

Delivered the additive lemma
`kvE2_sepCoincidentOrder_mem_arr'` (SharedWitness.lean:1733), factored from
`kvE2_sepBody_complete`'s verified membership route:

```
kvE2_sepCoincidentOrder qnf ∈ kvE2_sepArr' qnf
```

under an honest interior realization (`h`, `hLR`, `x < w < t`). This is the exact ⇐-direction
membership witness a `.holds` builder plugs into `kvE2_sepBody_holds_iff.mpr`. It edits no carrier
declaration. `#print axioms` (via `lake env lean`) confirms it depends only on
`[propext, Classical.choice, Quot.sound]` — **no `sorryAx`**. Full `lake build` of the module is
green.

## Blocker (Phases 2-6) — concretely grounded

The ⇐-direction `.holds` builder `kvE2_sepDisjunct_holds_of_honest` cannot be constructed additively
for the joint multi-owner (≥2 interior owners) case, because the task-338 carrier's slot list and the
region engine are structurally incompatible:

1. **Engine interface** — `k1v_sorted_realizationK` (SubBracket2V.lean:633) requires the region list
   to be boundary-linked, `hlink : List.Chain' (fun a b => a.2.1 = b.1) regions` (:637), and emits the
   witness list `interleaveK ps` in that **merged-anchor** order (:646, 453-457).
2. **Carrier slot list** — `kvE2_sepSlotsLOf wo = (kvE2_sepOrderOwners wo).flatMap kvE2_sepSlotsLFor`
   (SharedWitness.lean:869-871) is a **per-owner block concatenation**. `wo`'s rank reorders whole
   owner blocks (mergeSort, :861-863); it never interleaves individual slots across owners.
3. **Bracket requirement** — `IntervalPattern.holds_eq_succ` (ExistsForallNF.lean:188) requires one
   `witnesses : Fin (N+1) → M.carrier` strictly monotone in **block slot-index order** AND realizing
   each slot's point type.

Concrete Lean grounding (`lean_run_code`, not analysis-only):

- Block-order 2-owner region list `[(x,a),(a,w),(x,b),(b,w)]` (x<a<b<w) fails `Chain'` by `decide`
  (σ's last region ends at `w`, τ's first starts at `x ≠ w`) — engine rejects it.
- Merged-gap list `[(x,a),(a,b),(b,w)]` passes `Chain'` (`decide`) — engine accepts — but its
  `interleaveK` output is in merged order, mixing owners' base points, ≠ block slot order.
- Block-order monotonicity is contradictory: a τ.zXU base point `p ∈ (x,b)` (possibly `p < a`) sits
  after every σ.zUW point `u ∈ (a,w)` (`u > a`); monotone forces `u < p`, but `a<u, p<a, u<p ⊢ False`
  (`omega`) — a realizable model configuration.

**Root cause**: `kvE2_sepSlotsLOf/ROf wo` orders slots by (owner-rank, within-owner region). Faithful
strictly-monotone realization (Rabinovich Def 3.1 single merged chain) requires ordering ALL slots by
actual model position, merging owners' base points — which a per-owner block flatMap cannot express.
Task 338 added the cross-owner rank but kept the slot list a per-owner block concatenation.

**Resolution (out of scope, new task recommended)**: redesign `kvE2_sepSlotsLOf`/`kvE2_sepSlotsROf`
(SharedWitness.lean:869-876) into a genuine cross-owner slot MERGE keyed by each slot's merged-chain
position, then re-prove the dependent 338 lemmas (`kvE2_sepBody_holds_iff`, `_extract`,
`kvE2_sepDisjunct_extract` index reads). This is a **task-338 carrier edit**, explicitly forbidden by
this ADDITIVE task (Non-Goals :169-173; Rollback :474-476 directs STOP + scope question). After that
carrier redesign, v3 Phases 3-5 become realizable and Phase 1's membership lemma feeds directly in.

## Verification

- `lake build Bimodal.…SharedWitness` — green (only pre-existing warnings).
- `#print axioms kvE2_sepCoincidentOrder_mem_arr'` = `[propext, Classical.choice, Quot.sound]`.
- No `sorry`/`admit`/new `axiom`/vacuous placeholder introduced anywhere.
- Additive-only: exactly one new declaration; every task-334/336/338 INPUT untouched.
