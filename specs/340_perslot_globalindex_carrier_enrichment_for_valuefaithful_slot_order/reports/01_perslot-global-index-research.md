# Blocker Analysis: Task #337

**Parent Task**: #337 - Build joint multi-owner disjunct bracket-holds engine for kvE2_sepDisjunct
**Generated**: 2026-07-08
**Blocker**: Task 339's cross-owner slot merge uses a 2-level sort key (region-rank primary,
owner merged-chain rank secondary). Honest models exhibit cross-region interleaving that this
2-level key cannot value-faithfully reproduce, so no additive 337 `.holds` builder can construct a
monotone witness sequence over the fixed 339 slot order.

## Root Cause

This verdict was independently reached and verified in report 06
(`specs/337_.../reports/06_residual-granularity-verdict.md`) via three `lean_run_code`
experiments; it is treated as ground truth here (not re-derived).

`kvE2_sepBody_holds_iff.mpr` (SharedWitness.lean:1041-1050) is the 337 builder obligation: for
some `wo ∈ kvE2_sepArr'`, construct one `IntervalPattern.holds` witness sequence
`witnesses : Fin n → M.carrier` that is globally strictly monotone in the concatenated slot-list
index order (`holds_eq_succ`, ExistsForallNF.lean:188-204). The honest completeness arrangement
`kvE2_sepCoincidentOrder` (SW:1619-1621) is the one this builder must serve, and its `coincident`
tag is a bit-selector only — every owner's full slot block, including above-anchor `lUW` slots, is
still present (SW:289-299).

Task 339's design (`specs/339_.../reports/02_holds-shape-design-spec.md`, §(b) and its "Residual
granularity note" at lines 112-121) explicitly flags that its `kvE2_sepSlotMergeLe` comparator
(SW:880-885) — lexicographic on `(kvE2_sepSlotRank s, kvE2_sepOwnerRank wo (kvE2_sepSlotSub s))`,
region-rank PRIMARY — is only a 2-level key, and that a case like `a < u' < b` (an owner σ's
`lUW` slot landing strictly between σ's own anchor `a` and another owner τ's anchor `b`) "is not
value-faithfully reproduced by ANY 2-level key." 339's own report calls this "bounded to 337, NOT
a 339 blocker" — i.e. it was deliberately deferred to 337's scope.

Report 06 confirms this deferred gap is a genuine, unconditional blocker for 337, not merely a
theoretical edge case:

- **Honest realizability** (SW:1415-1419, `kvE2_sepHonestBundleL`): an owner σ's `lUW` witness `u`
  is constrained ONLY by `x1_σ < u < w` — no relation to any other owner's anchor. So for owners
  σ, τ with anchors `a = x1_σ < b = x1_τ`, the honest model may realize `u` anywhere in `(a, w)`,
  including `a < u < b` (σ's region-2 point BELOW τ's region-1 anchor).
- **339's key mis-orders it** (Experiment A): region-primary `mergeSort` of
  `{σ.lX1(r1), σ.lUW(r2), τ.lX1(r1)}` yields `[σ.lX1, τ.lX1, σ.lUW]` — τ.x1 placed before σ.lUW
  unconditionally, forcing `a < b < u` on the witness sequence.
- **Contradiction** (Experiment B): the honest config `a < u < b` and the list-forced order
  `a < b < u` are simultaneously required and `omega`-refutable — no monotone witness exists.
- **Rank-independence** (Experiment C): both possible `kvE2_sepOwnerRank` assignments
  (`σ<τ` or `τ<σ`) keep τ.lX1 before σ.lUW, because region rank is primary and
  `kvE2_sepSlotRank` is a fixed static field. No choice of `wo ∈ kvE2_sepArr'` (which only
  permutes the secondary owner-rank key) can rescue the build.

**Category**: Missing prerequisite (carrier-layer redesign) — the plan references and depends on
carrier work (a per-slot global index) not yet done; 339's own design spec explicitly notes the
residual gap as out of its scope and belonging to 337/a follow-on task.

## Proposed New Task

### New Task 1: Per-slot global-index carrier enrichment for value-faithful slot order

- **Effort**: complex
- **Task Type**: lean4
- **Rationale**: 337's `.holds` builder cannot proceed until the carrier exposes a per-slot
  ordering key that reproduces the exact honest model value order across owners (not just within
  a region layer). This is the terminal carrier layer identified by report 06 §5: replacing
  339's derived 2-level `(region, ownerRank)` key with a single per-slot global index closes the
  gap for ALL honest interleavings (both the above-anchor case report 04 already handled and the
  below-anchor case report 06 newly proved unhandled), so no fifth carrier layer should be needed.
- **Depends on**: None (new-task-local). Built on already-COMPLETED tasks 338 and 339; the skill
  postflight wires this new task's own `dependencies` field to `[339]` and rewires parent task 337
  to depend on this new task, per the standard spawn postflight contract.

## Dependency Reasoning

Only one task is proposed, so there is no internal dependency graph to reason about among new
tasks. The single dependency relationship that matters is external to this spawn batch: the new
task depends on the already-completed task 339 (whose `KvE2SepWeakOrder` / `kvE2_sepOrderTypes` /
`kvE2_sepSlotMergeLe` / `kvE2_sepSlotsLOf/ROf` definitions are the exact carrier surface being
enriched — the new task reads and extends 339's committed definitions, it does not re-derive
them), and task 337 will in turn depend on this new task once postflight rewires it (337's
builder needs the enriched carrier's value-faithful order to exist before it can construct a
monotone witness).

Why exactly one task suffices (Task Minimization Principle): the fix is a single coherent carrier
change confined to one file (`SharedWitness.lean`) — replacing one comparator/index representation
and re-proving the small number of lemmas that reference it by name. Splitting this into "design
the index" + "implement the index" + "re-prove downstream lemmas" would not reduce risk, because
the design constraints (linear-extension-of-region-order consistency, no F5/LITMUS violation,
preservation of `mergeSort_perm` membership) can only be validated against the actual definitions,
not in the abstract — exactly the reasoning report 06 itself applies in recommending a single
"escalation-contingency carrier change" rather than a phased sequence of separate tasks. The
design-first gate (see below) is planning-internal to this one task, not a separate predecessor
task, because the gate's conclusion (index shape) directly determines the definitions the same
task must then implement — splitting them would only recreate the same 339-style
"design-spec-now, implement-later" handoff friction across a task boundary for no risk reduction.

## Scope for the New Task (from report 06 §5, verified — not re-derived here)

**File scope**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean`

**Core change**: replace the derived 2-level key with a single PER-SLOT GLOBAL INDEX reflecting
the model value order of the point each slot realizes, so `mergeSort` reproduces the exact honest
value order (a total order on the full slot multiset, not a region×owner product):

| Item (SW line) | Change |
|---|---|
| `KvE2SepWeakOrder` (694-695) + `kvE2_sepOrderTypes` (706-711) | Enrich to carry a per-slot global index (total order on the merged slot multiset); enumeration ranges over order-consistent global interleavings of individual slots. |
| `kvE2_sepSlotMergeLe` (880-885) | Collapse to a single-level compare on the per-slot global index; drop the region-primary lex. |
| `kvE2_sepOwnerRank` (868-870) | Replaced/supplemented by a per-slot index reader keyed on the slot (not the owner). |
| `kvE2_sepSlotsLOf/ROf` (896-904) | Sort the flatMap base by the global-index key; `mergeSort_perm` membership preserved. |
| `kvE2_sepDisjValid[Owner]` (748-759) | Add a consistency conjunct: the per-slot global index must EXTEND each owner's own region order (`lXU < lX1 < lUW` left, mirror right) — a linear-extension-of-partial-order constraint. |
| `kvE2_sepCoincidentOrder` (1619-1621) + `kvE2_sepBody_complete` (1590) | The honest completeness witness must supply the global index consistent with the model value order. |
| `kvE2_sepHonestBundleL/R` (1408, 1460) | Extend to yield the cross-owner value order of the extracted witnesses (currently only per-owner `(x, x1_σ, w)` bounds); thread the carrier's total order into the index. |

**Re-prove**: `kvE2_sepBody` / `_holds_iff` / `_nonvacuous` / `_extract`, `kvE2_sepDisjunct_extract`.

**Must preserve**: 339's `mergeSort_perm` membership route (`kvE2_sepSlotsLOf_mem`/`ROf_mem`); the
⇒-extraction lemmas (a global index extending each owner's region order still gives same-owner
`rank < rank ⟹ index < index`); the no-collapse property (`kvE2_sepModelOrder` and
`kvE2_sepCoincidentOrder` remain proven members of `kvE2_sepArr'`); and task 337 Phase-1's
`kvE2_sepCoincidentOrder_mem_arr'` (SW:1733).

**Design-first / terminality requirement**: the new task's own planning phase must OPEN with a
design gate (mirroring 339's Phase 1 pattern) proving the per-slot index is FULLY value-faithful —
i.e. it reproduces the exact honest value order for the cross-region interleaving case `a < u' < b`
that broke 339 — and is faithful to Rabinovich Def 3.1's single global chain, establishing this is
the TERMINAL carrier layer (no fifth carrier layer needed) before any implementation phase begins.

**Acceptance**: sorry-free; axiom-clean (`lean_verify` → `{propext, Classical.choice, Quot.sound}`
only, no `sorryAx`); full `lake build` green; F1-F7 faithfulness invariants preserved (especially
F5 zone-key non-conflation and the LITMUS at NavigatedSpine.lean:437 — no `x1 < e_i` relative-
position literal). No load-bearing task-334/336/338/339 result destroyed.

**Recommended mode**: strong `--hard` candidate — foundational faithful-transcription work,
terminal carrier layer, quality-over-speed priority (per report 06's own framing).

## After Completion

Once the new task is complete, resume the parent task #337 with `/implement 337`.

The blocker will be resolved because: with a value-faithful per-slot global index in the carrier,
`kvE2_sepSlotsLOf/ROf`'s merged order will equal the honest model's actual value order for every
honest arrangement (including the below-anchor interleaving case report 06 proved 339's 2-level
key cannot handle), so the monotone witness required by `holds_eq_succ` becomes constructible via
the boundary-linked merged-anchor engine `k1v_sorted_realizationK` (SubBracket2V.lean:633) —
completing exactly the construction 339's own report 02 anticipated but flagged as needing a
per-slot index first.
