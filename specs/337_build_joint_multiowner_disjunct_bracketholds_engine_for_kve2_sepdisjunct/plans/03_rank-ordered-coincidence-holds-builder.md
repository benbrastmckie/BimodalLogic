# Implementation Plan v3: Task #337 — Rank-Ordered Coincidence `holds` Builder for `kvE2_sepDisjunct` (additive, on the task-338 enriched carrier)

- **Task**: 337 - Build the joint multi-owner disjunct bracket-`holds` engine for `kvE2_sepDisjunct`, delivering the ⇐-direction builder `kvE2_sepDisjunct_holds_of_honest`
- **Status**: [NOT STARTED]
- **Effort**: 4-5 hours
- **Dependencies**: 336 (COMPLETED — `kvE2_sepBody_complete` generalized `hL` → `hLR`), 338 (COMPLETED, axiom-clean — enriched `KvE2SepWeakOrder` with cross-owner rank; `kvE2_sepBody` now CONSUMES `wo` via `kvE2_sepSlotsLOf/ROf`)
- **Research Inputs**: specs/337_build_joint_multiowner_disjunct_bracketholds_engine_for_kve2_sepdisjunct/reports/01_rabinovich-witness-ordering-faithfulness.md; specs/337_build_joint_multiowner_disjunct_bracketholds_engine_for_kve2_sepdisjunct/reports/02_coincident-order-and-weakorder-scope.md; specs/338_enrich_separatedbody_weakorder_with_crossowner_anchor_order/summaries/01_weakorder-crossowner-enrichment-summary.md; specs/335_outer_gate_assembly_engine_kvE2_body/reports/02_spawn-analysis.md
- **Artifacts**: plans/03_rank-ordered-coincidence-holds-builder.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md; lean4.md (literature-fidelity-policy.md)
- **Type**: lean4
- **Lean Intent**: false

## Overview

This is the **v3 redesign** of task 337. The v2 plan (`plans/02_model-order-merge-bracket-holds.md`)
was BLOCKED at Phase 1 by a structural carrier-encoding gap: the task-334 weak-order carrier
`KvE2SepWeakOrder := List (σ × KvE2SepSpikeOrderType)` recorded only a **per-owner** placement tag
relative to the shared witness `w`, carried **no cross-owner order** on the interior owners' fresh
anchors `x1_σ`, and `kvE2_sepBody` **discarded** the weak order `_wo` and pinned every disjunct to the
FIXED flatMap `kvE2_sepSlotsL/R qnf`. Consequently no model-independent, `wo`-keyed,
strictly-monotone-realizable slot list existed, and the secondary tension (strict `kvE2_sepModelOrder`
validity is not honestly provable) blocked the intended Phase-5 route.

**Task 338 (COMPLETED, axiom-clean) fixed this at the foundation.** The carrier is now enriched and
`kvE2_sepBody` consumes `wo`. This plan is therefore **genuinely ADDITIVE** — it edits NO carrier
definition or lemma. It builds the missing ⇐-direction `.holds` realization on top of 338's verified
interface. The two faithful-witness principles from the reports are unchanged and now realizable:

- **Rabinovich Def 3.1** (report 01, md:63-74): the witness is a **single strictly-monotone chain**
  `x_0 < … < x_n` in **actual model order** — a global monotone merge of all owners' anchor points, NOT
  a permutation quantifier at the witness level. Realized here by generalizing `k1v_sorted_realizationK`
  (SubBracket2V.lean:633) from one owner to the merged anchor set.
- **Coincidence is a first-class disjunct** (report 02, Q1/Q3, Rabinovich Lemma 5.3 md:145-152): the
  honest completeness witness is the **coincidence** arrangement (each owner's fresh type realized AT
  its own anchor → the CLOSED self-zone bit is forced; the OPEN strict bits are not — the genuine
  Rabinovich `r_0 = z_0` asymmetry, SharedWitness.lean:1536-1544). Enumeration lives at the FORMULA
  level (`kvE2_sepArr'`, already landed); Option B (`List.mem_permutations` at the `.holds` level) is
  FORBIDDEN.

The task-338 orthogonality — the **placement tag** stays the 3-value per-owner type (F5:
strict→OPEN, coincident→CLOSED) while the **rank** ℕ is the independent merged-chain cross-owner
position (SharedWitness.lean:693-702) — is exactly what makes this additive builder feasible: the
honest `wo` uses **coincident tags** (honestly-valid via the preserved closed-channel discharges) with
**model-order ranks** (the true cross-owner anchor interleaving), so `kvE2_sepOrderOwners wo`
(mergeSort-by-rank, SharedWitness.lean:861-863) sequences the region blocks in genuine model order and
`kvE2_sepSlotsLOf/ROf wo` (SharedWitness.lean:869-876) become strictly-monotone-realizable.

### SCOPE CHECK — ADDITIVE, no carrier edits (REQUIRED determination)

**Determination**: this task is **entirely ADDITIVE**. It adds new private helpers and one public
builder to `SharedWitness.lean` and edits **no** existing declaration. The single authorized carrier
rewire that v2 could not perform (rewiring `kvE2_sepBody` to consume `wo`) was **already delivered by
task 338** and is a verified INPUT here. Every task-334/336/338 carrier definition and lemma is a
verified parametric INPUT.

**What makes it additive — cite the exact live lines (verified against SharedWitness.lean, 2722 lines,
post-338):**

- **The carrier already consumes `wo`.** `kvE2_sepBody` (SharedWitness.lean:933-952) maps
  `fun wo => kvE2_sepDisjunct charBase charK qnf (kvE2_sepSlotsLOf wo) (kvE2_sepSlotsROf wo)` over
  `kvE2_sepArr' qnf` (:950-951). The v2 root bug (`fun _wo => … kvE2_sepSlotsL/R qnf`, old :835-836) is
  GONE. No rewire is needed or permitted.
- **`kvE2_sepBody_holds_iff`** (SharedWitness.lean:970-988) already states
  `.holds ↔ ∃ wo ∈ kvE2_sepArr' qnf, (kvE2_sepDisjunct charBase charK qnf (kvE2_sepSlotsLOf wo) (kvE2_sepSlotsROf wo)).2.holds M atomMap x t`
  (:977-980). This builder's conclusion IS the ⇐ witness of that iff — it plugs in with no edit.
- **`kvE2_sepDisjunct`** is parametric in `lL lR : List (KvE2SepSlot sig)` (SharedWitness.lean:613-615);
  building `.holds` for `(kvE2_sepSlotsLOf wo) (kvE2_sepSlotsROf wo)` touches no existing declaration.
- **`kvE2_sepDisjunct_extract`** (SharedWitness.lean:1979-1998) is the parametric `{lL lR}` extractor;
  it demands exactly `hmemL/hpairL/hmemR/hpairR` (:1984-1987). Its **mirror builder** discharges the
  same shape — no extractor edit.
- **`kvE2_sepArr'` membership for the coincidence arrangement is already proven.**
  `kvE2_sepBody_complete` (SharedWitness.lean:1693-1725) shows `kvE2_sepCoincidentOrder qnf ∈ kvE2_sepArr' qnf`
  under `hLR`, via `kvE2_sepCoincidentOrder_mem_orderTypes` (:1555) + coincidence validity
  (`kvE2_sepCoincidentOwner_valid_left` :1566 / `_valid_right` :1640) + Nodup ranks (:1718-1725).
- **The engine is landed.** `k1v_sorted_realizationK` (SubBracket2V.lean:633-646) consumes
  `regions : List (M.carrier × M.carrier × List (NormalForm sig 0 1))` with `hpos/hlink/hnd/hreal` and
  returns `ps` + `(interleaveK ps).Pairwise (· < ·)` (:646) plus per-region realizer facts (:641-644) —
  the exact monotone-merge primitive over the merged anchor set.
- **Honest bundles are landed INPUTS.** `kvE2_sepHonestBundleL` (SharedWitness.lean:1337-1370, private)
  gives `x1 ∈ (x,w)` + `zXU` realizers in `(x,x1)` + `zUW` realizers in `(x1,w)`;
  `kvE2_sepHonestBundleR` (:1389-1400, private) gives `x1 ∈ (w,t)` + `zWX1` realizers in `(w,x1)` +
  `zWT` realizers in `(x1,t)`.

**Conclusion**: All six phases are additive. There is NO authorized-or-otherwise carrier edit in this
plan. The v2 Phase-5 rewire is superseded — **done by task 338**. If any step appears to require editing
a task-334/336/338 INPUT, STOP and surface it as a scope question rather than weakening a verified
INPUT.

### Choice of the honest `wo` (REVISION REQUIREMENT 2)

The honest witness `wo ∈ kvE2_sepArr' qnf` this builder targets is the **model-order-ranked coincidence
arrangement**: every positive owner carries the `.coincident` **tag** (so validity is discharged by the
CLOSED self-zone bit — honestly provable; the strict OPEN bits are not, SharedWitness.lean:1536-1544)
paired with a **rank equal to the model order of its fresh anchor** `x1_σ` in the merged ascending
chain (so `kvE2_sepOrderOwners wo` = the owners sequenced in true model order, making the region list
monotone). Tag and rank are orthogonal in the 338 carrier (SharedWitness.lean:693-702), so this is a
legitimate, valid, enumeration-reachable member.

- **Where anchors follow `kvE2_sepPos` order**: this arrangement IS `kvE2_sepCoincidentOrder qnf`
  (SharedWitness.lean:1548-1550, ranks = `zipIdx` = `kvE2_sepPos` index), already proven
  `∈ kvE2_sepArr' qnf` by `kvE2_sepBody_complete` — use it directly.
- **Where anchors interleave against `kvE2_sepPos`** (the case that blocked v2): the ranks are the
  **strict cross-owner interleaving** of the anchors (a permutation of `0..n-1`). Same all-coincident
  tags → same validity discharge; Nodup ranks → still valid; reachable in the cartesian enumeration
  (each owner independently picks tag `.coincident` and its model rank). This requires a small new
  membership helper generalizing `kvE2_sepOrderTypes_mem_aux` (SharedWitness.lean:810-832, currently
  `zipIdx`-shaped only) to an arbitrary Nodup rank assignment — additive, no carrier edit.

Both are available first-class members per task 338 (BOTH `kvE2_sepModelOrder` and
`kvE2_sepCoincidentOrder` are machine-checked `kvE2_sepOrderTypes` members; no collapse). Coincidence
stays first-class; we never collapse to coincidence-only nor force strict-only (report 02 Q3 refinement).

### Research Integration

Newly integrated report/summary: `specs/338_.../summaries/01_weakorder-crossowner-enrichment-summary.md`
(task 338 delivered the enriched carrier: `KvE2SepWeakOrder = List (NormalForm sig 1 4 × KvE2SepSpikeOrderType × ℕ)`,
`kvE2_sepBody` consuming `wo` via `kvE2_sepSlotsLOf/ROf`, re-proved `kvE2_sepBody_holds_iff`/`_nonvacuous`/`_extract`,
both order members no-collapse). Also newly integrated: `reports/02_coincident-order-and-weakorder-scope.md`
(coincidence is faithful and honestly forced; cross-owner order is mandatory and now carried by the
338 rank; retarget onto `kvE2_sepCoincidentOrder`). The v2-integrated
`reports/01_rabinovich-witness-ordering-faithfulness.md` (Option A = faithful witness; enumeration at
the formula level; generalize `k1v_sorted_realizationK`) is carried forward unchanged. The
v1-integrated `specs/335_.../reports/02_spawn-analysis.md` is retained for the verified-INPUT boundary.

### Prior Plan Reference

v2 plan `plans/02_model-order-merge-bracket-holds.md` is superseded. Its Phase-1 [BLOCKED] note is the
precise motivation for task 338, which has now landed the carrier enrichment the blocker demanded (its
resolution option (1): "enrich the carrier's weak-order encoding to carry the cross-owner anchor
order"). v2's Phases 1-4 proof skeleton (region assembly → engine → `IntervalPattern.holds_eq_succ.mpr`
point-type/segment match → endpoint discharge → verification gate) is carried forward and re-based onto
338's `kvE2_sepSlotsLOf/ROf wo` (replacing v2's undefinable model-independent `sortedL/sortedR`). v2's
Phase 5 (carrier rewire) is DELETED — task 338 performed it.

### Roadmap Alignment

No ROADMAP.md consulted (roadmap flag not set). Advances the `kamp_theorem_formalization` topic by
landing the faithful (Option A) completeness-side joint bracket engine on the enriched carrier,
unblocking parent task 335 Phases 2-4.

## Goals & Non-Goals

**Goals**:
- Choose and construct the honest witness `wo ∈ kvE2_sepArr' qnf` (the model-order-ranked coincidence
  arrangement; `kvE2_sepCoincidentOrder qnf` where anchors follow `kvE2_sepPos`, otherwise the
  model-order-ranked coincidence member), sorry-free and axiom-clean, reusing the 338/336 coincidence
  validity discharges as INPUTS.
- Generalize `k1v_sorted_realizationK` (one owner) to a **joint region list over the merged anchor set**
  of all positive owners, sequenced by `kvE2_sepOrderOwners wo`, producing one globally-monotone witness
  (`interleaveK ps`, `Pairwise (· < ·)`) from the honest bundles L/R.
- Deliver a sorry-free `kvE2_sepDisjunct_holds_of_honest` concluding
  `∃ wo ∈ kvE2_sepArr' qnf, (kvE2_sepDisjunct charBase charK qnf (kvE2_sepSlotsLOf wo) (kvE2_sepSlotsROf wo)).2.holds M atomMap x t`
  (the exact ⇐ witness shape of `kvE2_sepBody_holds_iff`, SharedWitness.lean:977-980), from the honest
  depth-2 evaluation + `x < w < t` + `hLR`.
- Deliver the small additive corollary `kvE2_sepBody_holds_of_honest` = builder + membership +
  `kvE2_sepBody_holds_iff.mpr`, exposing `(kvE2_sepBody charBase charK qnf).holds M atomMap x t` — the
  object task 335 consumes.
- `lean_verify` axiom-clean (`{propext, Classical.choice, Quot.sound}`, no `sorryAx`); full `lake build`
  green.
- Preserve F1-F7 (esp. F5 no open/closed zone-key conflation — coincident tags read only the CLOSED
  `zAtX1L`/`zAtX1R` self-zone bits; LITMUS NavigatedSpine:437 — no `x1 < e_i` relative-position literal,
  witness/segment bounds from the bracket range `x`/`w`/`t` and the engine's interior guarantees, never
  an owner-to-owner chain).

**Non-Goals**:
- **Do NOT** re-enumerate permutations at the `.holds` level (`List.mem_permutations` / Option B). The
  formula-level enumeration `kvE2_sepArr'` already lands the faithful disjunction (Lemma 3.2(1), md:77);
  duplicating it at the witness level is forbidden by the research (report 01 §2).
- **Do NOT** re-derive the carrier. Task 338's enriched `KvE2SepWeakOrder`, `kvE2_sepOrderTypes`,
  `kvE2_sepDisjValid`, `kvE2_sepArr'`, `kvE2_sepOrderOwners`, `kvE2_sepSlotsLOf/ROf`, `kvE2_sepBody`,
  `kvE2_sepBody_holds_iff`, `kvE2_sepBody_extract`, and both order members are **verified INPUTS**.
- **Do NOT** edit ANY task-334/336/338 definition or lemma. This task is ADDITIVE — new helpers + one
  builder + one corollary only. (There is no authorized carrier edit in v3; 338 already did it.)
- **Do NOT** target strict `kvE2_sepModelOrder` for the honest witness — its strict tags are not
  honestly provable (SharedWitness.lean:1536-1544). Use the coincident-tag arrangement.
- **Do NOT** touch `OuterGate.lean` or `KampPrior.lean` — task 335's consumption is a separate
  re-dispatch.
- **Do NOT** generalize beyond the left-OR-right interior owner class (`hLR`).
- No bare `sorry`/`admit`, no vacuous placeholder (`def X := True`), no gate-modulo-assumed hypothesis.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Model-order-ranked coincidence member membership (`kvE2_sepOrderTypes_mem_aux` :810 is `zipIdx`-shaped only) | M | M | For the common case (anchors follow `kvE2_sepPos`) reuse `kvE2_sepCoincidentOrder` directly (`∈ kvE2_sepArr'` already proven, `kvE2_sepBody_complete` :1693-1725). For interleaved anchors, add a small additive helper generalizing `kvE2_sepOrderTypes_mem_aux` to an arbitrary Nodup rank permutation (each owner independently picks tag `.coincident` + its model rank; the `List.mem_flatMap`/`mem_map` skeleton at :824-832 carries over). Additive — no carrier edit. |
| Merged-anchor region list mis-orders across owners (the interleave the redesign targets) | H | L | Build the region list in `kvE2_sepOrderOwners wo` order (mergeSort-by-rank, :861-863), where the rank IS the model anchor order — so the region list is monotone by construction; `hlink` chains via shared boundaries `x < x1_{first} < … < w < … < t`; `hpos` from `hxw`/`hwt` + honest-bundle anchor bounds. Never place all of one owner's witnesses before another's — the rank order fixes this (the exact v2 blocker, now resolved by 338's rank). |
| Phase 3 (point-type + segment matching) overflows one agent run | H | M | Largest phase; build point-type realizations and the segment families as separate green `have`s; if overflow looms, checkpoint the point-type helper as its own committed sorry-free lemma and split the segment matcher into a follow-on green sub-step (never a `sorry`). |
| `ws` re-indexing of `interleaveK ps` into the `kvE2_sepSlotsLOf wo ++ ptW :: kvE2_sepSlotsROf wo` slot order | H | M | Mirror the extractor's index arithmetic (`kvE2_sepDisjunct_extract` :2004-2018, pivot `ptW` at `(kvE2_sepSlotsLOf wo).map … .length`) in reverse; the `interleaveK` block/separator structure (SubBracket2V.lean:453-457) aligns with the owner-block layout of `kvE2_sepOrderOwners wo`. |
| `hLR` case split (left vs right interior) doubles region-mapping work | M | M | Handle the two zones symmetrically (as task 336's `rcases hLR … with hzone | hzone`): left → `kvE2_sepHonestBundleL` `(x,x1)`/`(x1,w)` regions, right → `kvE2_sepHonestBundleR` `(w,x1)`/`(x1,t)` regions; the merged region list consumes both uniformly in rank (model) order. |
| Faithfulness regression: `x1 < e_i` literal (LITMUS NS:437) or F5 open/closed key conflation | H | L | All witness/segment bounds from region endpoints `x`/`w`/`t` and engine interior guarantees (`hreal`), never an owner-to-owner chain; coincident tags read ONLY the CLOSED self-zone bits (`kvE2_sepClosedLeafStub` :767-772); reuse honest bundles verbatim (they satisfy F1-F7); Phase 6 re-audits. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |

Fully sequential: each phase consumes the sorry-free auxiliary lemma of the previous. Each phase is
sized to one agent run.

### Phase 1: Choose + construct the honest `wo` and prove `wo ∈ kvE2_sepArr' qnf` [COMPLETED]

**Goal**: From the honest depth-2 evaluation `h` + `hLR`, produce the honest witness weak order
`wo : KvE2SepWeakOrder sig` — the model-order-ranked coincidence arrangement — together with a proof
`wo ∈ kvE2_sepArr' qnf`. Deliver as a sorry-free additive helper (suggested
`kvE2_sepHonestOrder_mem_arr'` returning `⟨wo, hmem⟩`, or, in the anchors-follow-`kvE2_sepPos` route,
directly reuse `kvE2_sepCoincidentOrder qnf` + `kvE2_sepBody_complete`'s membership route).

**Tasks**:
- [ ] Verify on start (grep + one `lean_hover_info` each): `kvE2_sepBody_holds_iff` conclusion shape
      (:977-980); `kvE2_sepArr'` (:796-798); `kvE2_sepCoincidentOrder` (:1548-1550);
      `kvE2_sepCoincidentOrder_mem_orderTypes` (:1555); `kvE2_sepCoincidentOwner_valid_left` (:1566) /
      `_valid_right` (:1640); `kvE2_sepDisjValid` (:790-792); `kvE2_sepOrderTypes_mem_aux` (:810);
      `kvE2_sepBody_complete` coincidence-membership route (:1693-1725); `hLR` shape (:1699-1700).
- [ ] Primary route (anchors follow `kvE2_sepPos`): set `wo := kvE2_sepCoincidentOrder qnf`; obtain
      `wo ∈ kvE2_sepArr' qnf` by replaying `kvE2_sepBody_complete`'s `List.mem_filter` argument
      (`kvE2_sepCoincidentOrder_mem_orderTypes` + `kvE2_sepDisjValid` via the L/R coincidence
      validators + Nodup ranks). Reuse, do not re-derive.
- [ ] General route (interleaved anchors): construct the all-coincident-tag weak order with ranks =
      model order of the anchors `x1_σ` (extracted per owner from the honest bundles). Prove membership
      via a small additive generalization of `kvE2_sepOrderTypes_mem_aux` to a Nodup rank permutation,
      and validity via the same coincidence validators (tags identical) + Nodup of the permuted ranks.
- [ ] Verify each `have` with `mcp__lean-lsp__lean_goal`; keep sorry-free.

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` — add the
  honest-order + membership helper(s) (additive; near the other honest-completeness lemmas after
  `kvE2_sepBody_complete`).

**Verification**:
- Helper compiles sorry-free; `lean_verify` shows no `sorryAx`.
- The produced `wo` satisfies `wo ∈ kvE2_sepArr' qnf` (feeds `kvE2_sepBody_holds_iff.mpr`).
- Only CLOSED self-zone bits are read for validity (F5); no `x1 < e_i` literal.

---

### Phase 2: Merged-anchor engine-region assembly in `kvE2_sepOrderOwners wo` order [BLOCKED]

**BLOCKER** (Phase 2 — structural carrier/engine mismatch; concretely grounded):

- **What failed**: The engine `k1v_sorted_realizationK` (SubBracket2V.lean:633) cannot be wired to
  realize `(kvE2_sepDisjunct … (kvE2_sepSlotsLOf wo) (kvE2_sepSlotsROf wo)).2.holds` for the joint
  multi-owner (≥2 interior owners) case. The two interfaces are structurally incompatible:
  - The engine REQUIRES `hlink : List.Chain' (fun a b => a.2.1 = b.1) regions` (SubBracket2V.lean:637)
    and PRODUCES the witness list `interleaveK ps` in that boundary-linked MERGED-anchor order
    (SubBracket2V.lean:646, 453-457).
  - The task-338 carrier slot list is `kvE2_sepSlotsLOf wo = (kvE2_sepOrderOwners wo).flatMap
    kvE2_sepSlotsLFor` (SharedWitness.lean:869-871) — a per-owner BLOCK concatenation. The rank in
    `wo` reorders whole owner blocks (mergeSort by rank, :861-863); it NEVER interleaves individual
    slots across owners.
  - `kvE2_sepBracketN`/`IntervalPattern.holds_eq_succ` (ExistsForallNF.lean:188) require ONE
    `witnesses : Fin (N+1) → M.carrier` that is (1) strictly monotone in BLOCK slot-index order AND
    (3) realizes each slot's point type at its block index.
- **What was tried** (concrete, `lean_run_code`-grounded, not analysis-only):
  1. Block-order 2-owner region list `[(x,a),(a,w),(x,b),(b,w)]` (owners σ then τ, x<a<b<w):
     `¬ List.Chain' (fun p q => p.2.1 = q.1) …` proved by `decide` — the engine's `hlink` precondition
     is UNSATISFIABLE in block order (σ's last region ends at `w`, τ's first starts at `x ≠ w`).
  2. Merged-gap region list `[(x,a),(a,b),(b,w)]` IS `Chain'`-linked (`decide`) — engine accepts it —
     but `interleaveK` then emits MERGED order, mixing owners' base points inside each gap, NOT the
     per-owner block order the bracket point types are indexed by.
  3. Block-order monotonicity is contradictory: a τ.zXU base point `p ∈ (x,b)` (possibly `p < a`) sits
     at a block index AFTER every σ.zUW point `u ∈ (a,w)` (so `u > a`); monotone forces `u < p`, but
     `a < u`, `p < a`, `u < p` ⊢ `False` (`omega`) — a realizable model configuration.
- **Why stuck (root cause)**: `kvE2_sepSlotsLOf/ROf wo` orders slots by (owner-rank, within-owner
  region). Faithful strictly-monotone realization (Rabinovich Def 3.1 single merged chain) requires
  ordering ALL slots by actual MODEL POSITION, merging different owners' base points. A per-owner
  block flatMap fundamentally cannot express that cross-owner point interleaving. Task 338 added the
  cross-owner RANK but kept the slot list a per-owner block concatenation, so the ⇐-builder is not
  realizable for ≥2 owners whose base-witness intervals interleave.
- **What is needed**: Change `kvE2_sepSlotsLOf`/`kvE2_sepSlotsROf` (task-338 carrier defs,
  SharedWitness.lean:869-876) from `(kvE2_sepOrderOwners wo).flatMap kvE2_sepSlotsLFor/RFor` into a
  genuine cross-owner slot MERGE keyed by each slot's merged-chain position (so block-index order =
  merged model order, matching `interleaveK`). Then re-prove the dependent 338 lemmas
  (`kvE2_sepBody_holds_iff`, `_extract`, `kvE2_sepDisjunct_extract`'s `hmemL/hpairL` reads). This is a
  CARRIER EDIT — explicitly OUT OF SCOPE for this ADDITIVE task (Non-Goals :169-173; Rollback
  :474-476: "If any step appears to require editing a task-334/336/338 INPUT … STOP and surface it as
  a scope question"). Recommend a new task to redesign the 338 carrier's slot list as a cross-owner
  merge, after which this v3 builder plan (Phases 3-5) becomes realizable.
- **Prohibited**: No `sorry`, no `def X := True`, no `.holds` modulo an assumed monotonicity/anchor
  hypothesis, no gate-modulo-assumed-hypothesis restricted-to-≤1-owner builder (Non-Goals :179).

**Original goal (superseded by blocker)**: Build the merged-anchor region list …

**Goal**: Build the merged-anchor region list
`regions : List (M.carrier × M.carrier × List (NormalForm sig 0 1))`, sequenced by
`kvE2_sepOrderOwners wo` (mergeSort-by-rank, :861-863 → true model order), from the honest bundles, and
discharge the four `k1v_sorted_realizationK` preconditions (`hpos`, `hlink`, `hnd`, `hreal`). Deliver as
a sorry-free private helper (suggested `kvE2_sepHonestOrder_regions`).

**Tasks**:
- [ ] For each `σ ∈ kvE2_sepOrderOwners wo`, `rcases hLR σ (kvE2_sepMem_orderOwners qnf hwo' hσ) with hzone | hzone`:
      LEFT → `kvE2_sepHonestBundleL qnf M w x t hxw hwt h σ … hzone` yields `x1_σ ∈ (x,w)` + `zXU`/`zUW`
      realizers; RIGHT → `kvE2_sepHonestBundleR …` yields `x1_σ ∈ (w,t)` + `zWX1`/`zWT` realizers.
- [ ] Assemble one region per consecutive gap of the sorted merged anchor set
      `{x} ∪ {x1_σ : σ ∈ pos} ∪ {w} ∪ {t}`, ordered by rank (= model order), matching the block/separator
      layout `interleaveK` expects (SubBracket2V.lean:453-457).
- [ ] Discharge `hpos` (`r.1 < r.2.1`) from `hxw`/`hwt` + honest-bundle anchor bounds; `hlink`
      (`List.Chain' (·.2.1 = ·.1)`) from shared boundaries; `hnd` (`r.2.2.Nodup`) from the per-owner
      type-list nodup (`kvE2_sepS` filter dedup); `hreal` from the honest-bundle interior realizers.
- [ ] Verify each `have` with `lean_goal`; keep sorry-free.

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` — add
  `kvE2_sepHonestOrder_regions` (private helper).

**Verification**:
- Helper compiles sorry-free; `lean_verify` no `sorryAx`.
- Region boundaries are exactly `x`/interior anchors/`w`/`t` in `kvE2_sepOrderOwners wo` (rank/model)
  order (no `x1 < e_i` literal introduced).

---

### Phase 3: Joint engine invocation + global monotone bracket witness [NOT STARTED]

**Goal**: Apply `k1v_sorted_realizationK` to the Phase-2 regions, obtain `ps` +
`(interleaveK ps).Pairwise (· < ·)`, define the bracket witness `ws : Fin (N+1) → M.carrier` re-indexed
to the `kvE2_sepSlotsLOf wo ++ ptW :: kvE2_sepSlotsROf wo` slot order, and prove strict monotonicity +
range `x < ws i < t`. Deliver as a sorry-free private helper (suggested
`kvE2_sepHonestOrder_witnesses`).

**Tasks**:
- [ ] `obtain ⟨ps, hf, hsorted⟩ := k1v_sorted_realizationK M regions hpos hlink hnd hreal` (consuming
      the Phase-2 helper).
- [ ] Define `ws` by re-indexing `interleaveK ps` into the bracket slot order
      `(kvE2_sepSlotsLOf wo).map … ++ ptW :: (kvE2_sepSlotsROf wo).map …`, pivot `ptW` at index
      `(kvE2_sepSlotsLOf wo).map … .length` (mirror `kvE2_sepDisjunct_extract`'s index arithmetic
      :2004-2018 in reverse).
- [ ] Prove strict monotonicity `∀ i j, i < j → ws i < ws j` from `hsorted` (`interleaveK` pairwise,
      SubBracket2V.lean:646).
- [ ] Prove range `∀ i, x < ws i ∧ ws i < t` from region positivity/link (leftmost block lower bound
      `x`, rightmost block upper bound `t`).
- [ ] Verify each step with `lean_goal`; keep sorry-free.

**Timing**: 0.75 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` — add
  `kvE2_sepHonestOrder_witnesses` (private helper).

**Verification**:
- Helper compiles sorry-free; `lean_verify` no `sorryAx`.
- `ws` indexing agrees with `kvE2_sepDisjunct`'s `lL ++ ptW :: lR` layout for `lL = kvE2_sepSlotsLOf wo`,
  `lR = kvE2_sepSlotsROf wo` (pivot at `|kvE2_sepSlotsLOf wo|`).

---

### Phase 4: Point-type + segment matching → `kvE2_sepDisjunct … (kvE2_sepSlotsLOf wo) (kvE2_sepSlotsROf wo)).2.holds` [NOT STARTED]

**Goal**: From the Phase-3 witness sequence, prove every point-type realization and the
`kvE2_sepSegs` segment families, then close
`(kvE2_sepDisjunct charBase charK qnf (kvE2_sepSlotsLOf wo) (kvE2_sepSlotsROf wo)).2.holds` via
`IntervalPattern.holds_eq_succ.mpr` (ExistsForallNF.lean:188). Deliver as a sorry-free private helper
(suggested `kvE2_sepHonestOrder_bracket_holds`). Largest phase.

**Tasks**:
- [ ] `rw [IntervalPattern.holds_eq_succ …]` and `refine ⟨ws, ?_, ?_, ?_, ?_, ?_, ?_⟩` to expose the six
      mpr obligations (mono, range, point types, the three `beta` segment families) — dual to the
      extractor's `obtain ⟨ws, hmono, hrange, hpt, -, -, -⟩` (:2009).
- [ ] Mono + range: discharge from the Phase-3 helper directly.
- [ ] Point types: for each slot `i`, evaluate `(kvE2_sepSlotsLOf wo).map … ++ ptW :: (kvE2_sepSlotsROf wo).map …)[i]`
      at `ws i` — left slots from `kvE2_sepHonestBundleL` fresh-point realizers, pivot `kvE2_sepPtW`
      from the shared `w`, right slots from `kvE2_sepHonestBundleR`; positions read via the
      `kvE2_sepOrderOwners wo` (rank) order.
- [ ] Segments: for each inter-witness gap + the two boundary gaps, realize the refined-conjunction
      segment type from the region-interior realizers threaded through the engine's `ps` per-region
      guarantees (`hreal` content, `hf` Forall₂ at :641-644).
- [ ] Verify each `have` with `lean_goal`; keep sorry-free. If nearing an agent-run boundary, commit the
      point-type portion as a standalone green lemma and continue segments as a follow-on green sub-step.

**Timing**: 1.5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` — add
  `kvE2_sepHonestOrder_bracket_holds` (private helper).

**Verification**:
- Helper compiles sorry-free; `lean_verify` no `sorryAx`.
- Segment bounds come from region endpoints/engine guarantees, not owner-to-owner chains
  (LITMUS NS:437); F5 closed/open keys unconflated.

---

### Phase 5: Endpoint discharge + assemble builder `kvE2_sepDisjunct_holds_of_honest` + body corollary [NOT STARTED]

**Goal**: Discharge the endpoint conjuncts `kvE2_sepEpL`@x and `kvE2_sepEpR`@t from the honest
evaluation `h`, assemble the three-part `VecEA2.holds`, and state + prove the builder
`kvE2_sepDisjunct_holds_of_honest` (the ⇐ witness of `kvE2_sepBody_holds_iff`) plus the corollary
`kvE2_sepBody_holds_of_honest`, sorry-free.

**Tasks**:
- [ ] Prove `(kvE2_sepEpL charBase charK qnf).eval_at M atomMap x` and
      `(kvE2_sepEpR charBase charK qnf).eval_at M atomMap t` from the atom-layer of `h` over `[w,x,t]`
      (the same data the extractor destructures as `hepL`/`hepR`, :1991-1992/:1999; add a small private
      `have` if no direct helper exists).
- [ ] State `kvE2_sepDisjunct_holds_of_honest` (signature mirroring `kvE2_sepGate_holds_of_honest`
      :1264 + `kvE2_sepBody_complete` :1693 — `charBase`, `charK`, `qnf`, `M`, `atomMap`, `w x t`,
      `hxw`, `hwt`, `hLR`, `h`) concluding
      `∃ wo ∈ kvE2_sepArr' qnf, (kvE2_sepDisjunct charBase charK qnf (kvE2_sepSlotsLOf wo) (kvE2_sepSlotsROf wo)).2.holds M atomMap x t`.
- [ ] `refine ⟨wo, hmem, hepL, hepR, ?_⟩` (from Phase 1's `wo`/`hmem`); close the bracket via the
      Phase-4 helper.
- [ ] Add the corollary `kvE2_sepBody_holds_of_honest`:
      `(kvE2_sepBody charBase charK qnf).holds M atomMap x t`, proven by
      `(kvE2_sepBody_holds_iff charBase charK qnf (kvE2_sepGate_holds_of_honest …) M atomMap x t).mpr`
      applied to `kvE2_sepDisjunct_holds_of_honest`.
- [ ] Verify each `have` with `lean_goal`; keep sorry-free.

**Timing**: 0.75 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` — add the
  builder `kvE2_sepDisjunct_holds_of_honest` + corollary `kvE2_sepBody_holds_of_honest`.

**Verification**:
- Both compile sorry-free; `lean_verify` no `sorryAx` (full audit in Phase 6).
- Builder conclusion is the ⇐ witness shape of `kvE2_sepBody_holds_iff` (:977-980), over
  `kvE2_sepSlotsLOf/ROf wo` (NOT any fixed flatMap).
- Corollary discharges `kvE2_sepBody.holds` — the object task 335 consumes.

---

### Phase 6: Axiom-cleanliness gate + F1-F7 faithfulness audit + full build [NOT STARTED]

**Goal**: Run the explicit axiom-cleanliness gate, audit F1-F7 preservation, confirm every task-334/336/338
INPUT is byte-for-byte untouched, and pass a full project build.

**Tasks**:
- [ ] `lean_verify` on `kvE2_sepDisjunct_holds_of_honest`, `kvE2_sepBody_holds_of_honest`, and each
      Phase-1..4 helper; confirm each returns `{propext, Classical.choice, Quot.sound}` with **no
      `sorryAx`**.
- [ ] Grep the diff for `sorry`/`admit`/new `axiom`/vacuous `:= True` — must be NONE.
- [ ] F1-F7 checklist: F1 (region types stay QF); F2 (non-vacuous — realizers from honest bundles, not
      placeholders); F3/F4 (witnesses region-interior, no new anchors, no `x1 < e_i` literal); F5 (no
      open/closed zone-key conflation — coincident tags read only the CLOSED `zAtX1L`/`zAtX1R` bits, as
      in task 336); LITMUS NavigatedSpine:437 (all witness/segment bounds from the bracket range
      `x`/`w`/`t` and engine interior guarantees, never a chain).
- [ ] `git diff` gate: confirm the change is EXCLUSIVELY the Phase-1..5 additive helpers + builder +
      corollary; every existing declaration (esp. all task-334/336/338 INPUT defs/lemmas —
      `kvE2_sepBody`, `kvE2_sepBody_holds_iff`, `kvE2_sepBody_extract`, `kvE2_sepArr'`,
      `kvE2_sepSlotsLOf/ROf`, `kvE2_sepOrderOwners`, `kvE2_sepDisjunct_extract`, `kvE2_sepArr'_sound`,
      `kvE2_sepBody_complete`, `kvE2_sepHonestBundleL/R`, both order members) is UNMODIFIED.
- [ ] Full `lake build` green.

**Timing**: 0.5 hours

**Depends on**: 5

**Files to modify**:
- None (verification-only; fixups surfaced by the audit excepted, and only to the new additive
  declarations).

**Verification**:
- `lean_verify` on all delivered declarations axiom-clean, no `sorryAx`.
- Full `lake build` succeeds.
- F1-F7 checklist passes; every INPUT declaration untouched (`git diff` = additive-only).

---

## Testing & Validation

- [ ] `lake build` of the `NfMultiAnchorBridge/` target (and full project in Phase 6) succeeds.
- [ ] `lean_verify` on `kvE2_sepDisjunct_holds_of_honest`, `kvE2_sepBody_holds_of_honest`, and every
      auxiliary helper returns `{propext, Classical.choice, Quot.sound}` with no `sorryAx`.
- [ ] No bare `sorry`/`admit`, no new `axiom`, no vacuous definition anywhere in the diff.
- [ ] The change is ADDITIVE: every task-334/336/338 INPUT def/lemma is byte-for-byte unmodified
      (`git diff` shows only new declarations).
- [ ] The builder's conclusion is the ⇐ witness shape of `kvE2_sepBody_holds_iff` (:977-980) over
      `kvE2_sepSlotsLOf/ROf wo`; the corollary discharges `kvE2_sepBody.holds`.
- [ ] No `List.mem_permutations` at the `.holds` level (Option B forbidden).
- [ ] The honest `wo` uses coincident tags (F5 closed-channel validity) with model-order ranks; strict
      `kvE2_sepModelOrder` is NOT the honest target.
- [ ] F1-F7 faithfulness checklist passes (F5 closed/open discrimination; LITMUS NS:437 no `x1 < e_i`
      literal; witness/segment bounds from the bracket range and engine guarantees).

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` — additive
  only: the honest-order + membership helper (Phase 1), `kvE2_sepHonestOrder_regions` (Phase 2),
  `kvE2_sepHonestOrder_witnesses` (Phase 3), `kvE2_sepHonestOrder_bracket_holds` (Phase 4), the builder
  `kvE2_sepDisjunct_holds_of_honest` + corollary `kvE2_sepBody_holds_of_honest` (Phase 5). NO existing
  declaration edited.
- `specs/337_.../plans/03_rank-ordered-coincidence-holds-builder.md` (this file).
- `specs/337_.../summaries/03_rank-ordered-coincidence-holds-builder-summary.md` (on completion).
- **Downstream**: task 335 re-dispatches Phases 2-4 to consume `kvE2_sepBody_holds_of_honest` (and the
  underlying `kvE2_sepDisjunct_holds_of_honest`) via the already-landed `kvE2_sepBody_holds_iff`.

## Rollback/Contingency

- ALL phases are additive to `SharedWitness.lean`. To revert any phase: delete the new declaration(s);
  the file returns to its post-task-338 green state with every INPUT untouched. There is no carrier
  edit to roll back.
- If Phase 4 cannot close within one agent run: commit the point-type helper as a standalone sorry-free
  lemma (green checkpoint), then continue the segment matcher as a follow-on green sub-step. Never commit
  a bare `sorry`, a vacuous placeholder, or a `.holds` modulo an assumed segment obligation (honest
  RESCOPE discipline).
- If Phase 1's general (interleaved-anchor) membership helper proves larger than expected, checkpoint the
  primary route (`kvE2_sepCoincidentOrder`, anchors follow `kvE2_sepPos`) as a committed green partial
  builder covering that case, and surface the interleaved-anchor generalization as a follow-on green
  sub-step — never as a `sorry`.
- If any step appears to require editing a task-334/336/338 INPUT def/lemma (rather than adding a new
  helper), STOP and surface it as a scope question rather than weakening a verified INPUT. This task is
  ADDITIVE by construction — such a need signals a design error, not an authorized edit.
