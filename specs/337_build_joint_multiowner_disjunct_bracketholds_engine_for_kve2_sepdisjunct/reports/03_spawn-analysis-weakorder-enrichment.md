# Blocker Analysis: Task #337

**Parent Task**: #337 - Build joint multi-owner disjunct `bracket.holds` engine for `kvE2_sepDisjunct`
**Generated**: 2026-07-08
**Blocker**: The task-334 weak-order type `KvE2SepWeakOrder` (SharedWitness.lean:694-695) records
only a per-owner tag relative to the shared point `w` and carries no cross-owner interleaving of
interior owners' fresh anchors, so task 337's `.holds` builder has no order data to consume for
merged, cross-owner-interleaved models. Confirmed faithful (not a Lean-encoding artifact) against
Rabinovich 2014 by reports 01 and 02.

## Root Cause

**Category**: Missing prerequisite (foundational carrier under-specification), confirmed via
faithfulness research, not a scope or design-ambiguity issue.

Task 337's plan v2 (Option A model-order merge, per report 01) hit a **Phase 1 structural block**:
building `(kvE2_sepDisjunct … slotsL slotsR).2.holds` for the model-order disjunct requires a
model-independent, monotone cross-owner slot order to realize via a joint sorted-realization
engine (generalizing `k1v_sorted_realizationK`, SubBracket2V.lean:633). No such order exists in
the landed carrier:

- `KvE2SepSpikeOrderType` (SW:679-686) is a 3-value **per-owner** tag
  (`strictBefore`/`strictAfter`/`coincident`).
- `KvE2SepWeakOrder := List (σ × KvE2SepSpikeOrderType)` (SW:694-695) is one `(owner, tag)` pair
  per positive owner, each tag checked only against **that owner's own** zone bits relative to
  `w` (`kvE2_sepDisjValidOwner`, SW:748-752) — there is no conjunct linking one owner's tag to
  another's into a single consistent global order.
- `kvE2_sepBody` (SW:821-837, esp. 835-836) **discards** the weak order `_wo` entirely and pins
  every disjunct to the fixed, model-independent flatMap concatenation `kvE2_sepSlotsL/R qnf`
  (SW:315-322) — i.e. today the enumeration (`kvE2_sepArr'`) supplies non-vacuity only; no
  disjunct actually realizes any cross-owner reordering.

**Report 01** (Rabinovich witness-ordering faithfulness) establishes that Rabinovich's witness
(Definition 3.1, md:63-74) is always a *single global monotone chain*, and that his merged
disjuncts (Lemma 3.2(1), md:77) each pin one global order over the **union** of both owners'
points — never a per-owner-independent tagging. This confirms the "bug is in the merge" diagnosis
and pins the fix as Option A (model-order realization), not permutation enumeration at the
`.holds` level.

**Report 02** (coincident-order and weak-order scope) sharpens this into an actionable scope:

1. **Q1 (coincident vs strict)**: Rabinovich's Lemma 5.3 inductive step (md:145-152, the `r_0 = z_0`
   sub-case of `INF(z_0,r_0,z_1,P_1)`) and Insight #2 (md:213-219, case split over "all possible
   positions i") make witness↔reference-point **coincidence a first-class disjunct**, on equal
   footing with strict interior placement. There is no genericity/distinctness assumption
   anywhere in the paper excluding ties. `kvE2_sepCoincidentOrder` is therefore a faithful target,
   and the task-334 finding that strict `kvE2_sepModelOrder` is not honestly provable (SW:1421-1429)
   is a genuine semantic fact (Rabinovich's own `r_0 = z_0` branch), not an encoding bug.
2. **Q2 (cross-owner scope, the decisive question)**: Rabinovich enumerates the **full cross-owner
   interleaving** — each merged disjunct is a total description of one global order over all
   merged points (Lemma 3.2(1) + §5's "for ALL possible positions i", md:77, 168-219). The Lean
   carrier records only **per-owner tags relative to `w`**, with two owners whose anchors
   interleave differently (`x1_σ < x1_τ` vs `x1_τ < x1_σ`) **indistinguishable** to the carrier.
   This is a genuine **faithfulness under-specification**, confirmed independently by the
   task-334 Phase 6 deletion of the FALSE flatMap scaffolds `kvE2_sepSlotsL_valid`/`_valid`
   ("the identity interleaving of the flat union … need not be cross-σ compat", SW:1038-1044).
3. **Q3 (is the enrichment direction faithful)**: **Yes, and required** — provided the enrichment
   (a) carries a genuine cross-owner order on the merged anchor multiset, and (b) keeps
   coincidence as a first-class disjunct alongside strict cross-owner interleavings (neither
   collapsing to coincidence-only nor forcing strict-only).
4. **Q4 (scope reality check)**: the type-level changes to `KvE2SepSpikeOrderType`/
   `KvE2SepWeakOrder` are the **only** truly invalidating edits; they cascade to body changes in
   `kvE2_sepOrderTypes`, `kvE2_sepDisjValidOwner`/`kvE2_sepDisjValid`, `kvE2_sepModelOrder`,
   `kvE2_sepCoincidentOrder`, and — the central change — `kvE2_sepBody` itself, which must be
   rewired to **consume** `_wo` instead of discarding it. **No proved completeness or soundness
   result is lost**: `kvE2_sepBody_complete`, the honest bundles, and the per-owner coincidence
   validity lemmas are reused/extended, not invalidated.

This is squarely a **missing prerequisite** for task 337: the `.holds` builder task 337 was
chartered to write (an *additive* builder consuming the existing carrier) cannot be written
against a carrier that structurally cannot express the data the builder needs to consume. The
fix is foundational carrier work, out of task 337's additive-builder charter, and belongs in a
dedicated predecessor task.

## Proposed New Tasks

### New Task 1: Enrich separated-body weak-order with cross-owner anchor order

- **Effort**: 6-8 hours
- **Task Type**: lean4
- **Rationale**: This is the sole missing prerequisite blocking task 337. Task 337's `.holds`
  builder needs a weak-order value it can consume to realize each disjunct's cross-owner slot
  order; the landed carrier cannot express that data at all (per-owner tags only, SW:694-695).
  Enriching the carrier is foundational, type-level, faithful-transcription work (confirmed by
  reports 01/02) that is out of scope for task 337's additive-builder charter.
- **Depends on**: None (task 334 and task 336, whose results this task treats as verified inputs,
  are both already COMPLETED — no live intra-project dependency).

## Dependency Reasoning

- **Task 337 depends on New Task 1**: Task 337's `.holds` builder must pattern-match on / consume
  the weak-order value `_wo` to select each disjunct's cross-owner slot order (per report 02 Q3,
  "carried by the enriched `wo` and consumed by the disjunct builder, which today ignores it"). The
  *shape* of the enriched `KvE2SepWeakOrder`/`KvE2SepSpikeOrderType` and the semantics of the new
  cross-owner consistency conjunct in `kvE2_sepDisjValid` are implementation decisions New Task 1
  must make, and task 337's builder logic (how it maps a consumed order onto
  `k1v_sorted_realizationK`'s merged-anchor input) is written directly against those decisions —
  not merely after them. This is why task 337 is re-dispatched only *after* New Task 1 completes,
  per the skill postflight's parent-dependency wiring.
- No other new tasks are proposed, so there are no independent-task pairs to reason about.

**File Footprint Overlap Check**: New Task 1's `file_scope` is
`["Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean"]`, the
same file task 337 itself will edit. This is expected and intentional (the enrichment and the
builder are sequential edits to the same central file) — it is exactly what the postflight's
parent-task dependency edge encodes, not a hidden intra-`new_tasks` overlap (there is only one
new task in this spawn, so no pairwise overlap check applies within `new_tasks[]`).

## Scope Detail (for the implementer)

Per report 02's impacted-definitions table (Q4):

**Type-level changes (invalidating, cascading)**:
- `KvE2SepSpikeOrderType` (SW:679-686): enrich the 3-value per-owner tag to also encode relative
  order among all positive owners' interior witnesses (not just each owner's own placement
  relative to `w`).
- `KvE2SepWeakOrder` (SW:694-695): enrich `List (σ × KvE2SepSpikeOrderType)` to carry a genuine
  cross-owner order on the merged anchor multiset.

**Body changes (signatures/return types preserved)**:
- `kvE2_sepOrderTypes` (SW:706-711): from independent cartesian `3^|pos|` product to enumeration
  of order-consistent global interleavings.
- `kvE2_sepDisjValidOwner`/`kvE2_sepDisjValid` (SW:748-759): add a cross-owner consistency
  conjunct on the global order (semantics change; downstream conclusions strengthen).
- `kvE2_sepModelOrder` (SW:719-721): encode the strict cross-owner global order (remains a
  conditional, honestly-undischargeable disjunct — this is expected and matches Rabinovich's own
  `r_0 = z_0` asymmetry, not a bug to "fix away").
- `kvE2_sepCoincidentOrder` (SW:1433-1435): the all-coincidence **global** order in the enriched
  type (remains the honest completeness disjunct).
- `kvE2_sepBody` (SW:821-837, esp. 835-836) — **the central change**: today `map fun _wo =>
  kvE2_sepDisjunct … (kvE2_sepSlotsL qnf) (kvE2_sepSlotsR qnf)` discards `wo` and uses fixed
  slots; must instead consume `wo` to realize each disjunct's own cross-owner slot order.

**Downstream proof repair (statement survives; proof re-run or reused as component)**:
- `kvE2_sepBody_complete` (SW:1592-1611) — conclusion `kvE2_sepArr' qnf ≠ []` survives; proof
  re-run through `kvE2_sepCoincidentOrder` membership.
- `kvE2_sepCoincidentOwner_valid_left`/`_valid_right` (SW:1465, 1539) — reused as-is as the
  per-owner component of the enriched coincidence validity.
- `kvE2_sepHonestBundleL`/`kvE2_sepHonestBundleR` (SW:1211, 1257) — reused/extended, exactly the
  raw per-owner anchor-bound data needed to establish cross-owner order.
- Membership lemmas `kvE2_sepModelOrder_mem_orderTypes` (SW:791-794),
  `kvE2_sepCoincidentOrder_mem_orderTypes` (SW:1456-1459), and `_mem_aux` helpers — statements
  survive if type names survive; proofs re-run against the new enumeration body.
- `kvE2_sepArr'_sound` (SW:2594-2601) — conclusion **strengthens**: per-owner-only validity
  statement gains a cross-owner consistency conjunct once `kvE2_sepDisjValid` is enriched.

**No genuinely invalidated (load-bearing) result**: the strict-model-order completeness route was
already known honestly non-dischargeable (SW:1421-1429), and the FALSE flatMap scaffolds were
already removed in task-334 Phase 6.

**Must preserve throughout**: coincidence remains a first-class disjunct alongside strict
cross-owner interleavings — neither collapsing the carrier to coincidence-only (breaks the
soundness direction task 337 needs) nor forcing strict-only (breaks the honest completeness
witness `kvE2_sepBody_complete` already relies on).

**Acceptance criteria**:
- Sorry-free.
- Axiom-clean: `lean_verify` → `{propext, Classical.choice, Quot.sound}` only, no `sorryAx`.
- Full `lake build` green.
- All seven faithfulness invariants F1-F7 preserved, especially F5 (no open/closed zone-key
  conflation) and the LITMUS test at `NavigatedSpine.lean:437` (witness bounds must come from the
  bracket range, never an `x1 < e_i` relative-position literal on a raw chain).

**Hard-mode candidacy note**: This task is a strong `--hard` candidate. It is foundational,
faithful-transcription work (transcribing Rabinovich's merged-disjunct global order into a Lean
type), and task 337 has already hit a Phase-1 structural block across **two plan versions**
(plans/01 and plans/02) without completing a phase — exactly the `--hard` trigger conditions
listed in CLAUDE.md ("2+ plan versions exist for the same task without convergence" and
"task has been in [IMPLEMENTING]/blocked for 3+ dispatch cycles").

## After Completion

Once New Task 1 is complete, resume the parent task #337 with `/implement 337`.

The blocker will be resolved because: task 337's `.holds` builder will then have a weak-order
value (`KvE2SepWeakOrder`) that actually carries a cross-owner order on the merged anchor
multiset, consumed by a rewired `kvE2_sepBody`, giving the builder concrete order data to map
onto `k1v_sorted_realizationK`'s merged-anchor input — resolving the Phase 1 structural block
that stalled plans/01 and plans/02.
