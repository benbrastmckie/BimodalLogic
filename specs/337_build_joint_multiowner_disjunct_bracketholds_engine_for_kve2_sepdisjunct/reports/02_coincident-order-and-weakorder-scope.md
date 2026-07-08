# Faithfulness Report 02: Coincident-vs-Strict Order & Weak-Order Cross-Owner Scope

**Task**: 337 — build joint multi-owner disjunct `bracket.holds` engine for `kvE2_sepDisjunct`
**Mode**: RESEARCH-ONLY (no Lean files edited)
**Builds on**: `reports/01_rabinovich-witness-ordering-faithfulness.md` (Option A = model-order merge
is faithful per Rabinovich Def 3.1)
**Source**: Rabinovich 2014, *A Proof of Kamp's Theorem*, LMCS 10(1:14) — indexed `rabinovich_2014`
(`~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`)
**Lean**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean`
(the task prompt's `SharedWitness.lean:NNN` line numbers were verified against this file; they match)

---

## TL;DR VERDICT

1. **Faithfulness of coincident vs strict**: **COINCIDENT-WEAK is faithful.** Rabinovich's normal
   form fixes a *strict* chain **among the existential witnesses `x_0 < … < x_n`** (Def 3.1,
   md:65-68), but the *enclosing disjunction* over interleavings/positions treats a witness
   **coinciding with a reference point** (`r_0 = z_0`) as a **first-class disjunct**, on equal
   footing with the strict interior placement `r_0 ∈ (z_0,z_1)` (Lemma 5.3 inductive step, md:145-152;
   Insight #2, md:213-219). There is **no genericity/distinctness assumption** in the paper that
   excludes coincidences. Therefore `kvE2_sepCoincidentOrder` is a faithful target, and the
   honest-provability gap for strict `kvE2_sepModelOrder` (task-334 finding, SW:1421-1429) is a
   **genuine semantic fact, not a Lean encoding artifact** — it is exactly Rabinovich's `r_0 = z_0`
   sub-case (the witness sits AT the anchor, so the CLOSED/meet bit is forced and the OPEN strict
   bits are not).

2. **v3 weak-order-enrichment direction faithful?**: **YES — with one required refinement.**
   Enriching the carrier to record a **cross-owner order on the merged anchor multiset** is faithful
   and, in fact, *mandatory* for faithfulness (see Q2): Rabinovich's merged disjuncts each pin a
   **single global order of the UNION of both owners' points**, not independent per-owner tags.
   Retargeting non-vacuity/completeness onto `kvE2_sepCoincidentOrder` is faithful **for the honest
   completeness witness**. The one refinement: coincidence must remain a **first-class disjunct
   alongside strict cross-owner interleavings** (both are valid Rabinovich disjuncts) — faithfulness
   does **not** permit *collapsing* the carrier to coincidence-only, nor does it *demand* strict-only.

3. **The live obstruction is confirmed in source.** `kvE2_sepBody` (SW:835-836) maps over
   `kvE2_sepArr'` but **discards the weak order `_wo`** and pins every disjunct to the **fixed,
   model-independent flatMap concatenation** `kvE2_sepSlotsL/R qnf` (SW:315-322). So today the
   enumeration supplies **non-vacuity only**; no disjunct realizes any cross-owner reordering. This
   is precisely why a fixed slot order cannot be monotone-realized across honest models whose anchors
   interleave differently.

---

## Q1 — Weak order (coincidences allowed) or strict total order? Cite Rabinovich exactly.

**Rabinovich uses BOTH, at two different levels — and the level that governs the merged
multi-owner carrier is the WEAK (coincidence-inclusive) disjunction.**

**Within a single exists-forall disjunct: STRICT.** Definition 3.1 (md:63-74) writes
`psi(z_0,…,z_m) := ∃ x_n … ∃ x_0 (ordering constraints on x_i and z_j) ∧ α_j(x_j) ∧ β_j on (x_{j-1},x_j)`.
The "ordering constraints" fix a **strictly increasing chain** `x_0 < x_1 < … < x_n` of the
existentially chosen points (md:74: "existentially chosen points partition the chain into
intervals"). So *among the interior witnesses of one disjunct*, order is strict — no ties.

**Across the disjunction (the level that matters here): WEAK / coincidence-inclusive.** The
coincidence of a witness with a **reference point** is a first-class disjunct, not excluded:

- **Lemma 5.3, inductive step (md:145-152)** — the decisive citation. Let
  `r_0 = inf{z ∈ (z_0,z_1) | P_1(z)}` (exists by Dedekind completeness, md:146). `r_0` is definable by
  `INF(z_0,r_0,z_1,P_1) := z_0 < r_0 < z_1 ∧ (∀y)^{<r_0}_{>z_0} ¬P_1(y) ∧ (P_1(r_0) ∨ K+(P_1)(r_0))`
  (md:149). The construction then **splits into sub-cases `r_0 = z_0` OR `r_0 ∈ (z_0,z_1)`**
  (md:151). The `r_0 = z_0` branch is exactly a **coincidence** of the special (meet) point with the
  reference/anchor point — carried as a legitimate disjunct.
- **`P_1(r_0) ∨ K+(P_1)(r_0)` (md:149)** — the meet point either *satisfies* `P_1` (the coincidence:
  the type is realized AT `r_0`) or is a strict limit approached from above (`K+`). Both are kept.
  This is the §5 "meet channel" the Lean `zAtX1L`/`zAtX1R` CLOSED bits encode.
- **Insight #2 (md:213-219)** — "The negation then requires showing that for **ALL possible positions
  i** … which existential witness [the new point] replaces or sits between." The enumeration over
  positions `i` explicitly includes the boundary/coincident positions, not only strict-interior ones.

**Mapping to Lean.** The Lean "coincidence" is owner `σ`'s χ-witness sitting **at its own fresh
anchor `x1_σ`** (`kvE2_sepCoincidentOrder`, SW:1431-1435). This is Rabinovich's `r_0 = z_0` /
`P_1(r_0)` sub-case: the fresh base type is realized AT the anchor, forcing the CLOSED self-zone bit
`kvE2_sepBits σ zAtX1L (nf0_projFresh σ.1)` (SW:730-743, discharged by the preserved axiom-clean
`kvE2_sepCoincidentAnchor_discharge`), while the OPEN `zXU`/`zUW` bits read by the strict tags are
**not** forced (SW:1421-1428, the handoff-05 open-vs-closed discrimination). This is a real semantic
asymmetry that Rabinovich's `P_1(r_0)` branch predicts — **not** a Lean encoding accident.

**Q1 answer**: The faithful frame is a **weak order allowing witness↔reference coincidences as
first-class disjuncts**. `kvE2_sepCoincidentOrder` is a faithful target. Strict `kvE2_sepModelOrder`
is *also* a faithful disjunct (Rabinovich's strict-interior placement), but it is **not the unique
faithful one** and is **not honestly forced** — the honest-provability gap is Rabinovich's own
`r_0 = z_0` coincidence, a semantic fact, not an encoding problem.

---

## Q2 — Does the enumerated order data include CROSS-owner order, or only per-owner order vs a
shared anchor?

**Rabinovich's disjuncts encode the FULL CROSS-OWNER (global) order; the Lean carrier today encodes
only PER-OWNER tags relative to the shared anchor `w`. This is a faithfulness UNDER-specification.**

**Rabinovich side — one global chain per disjunct.** The normal form (Def 3.1, md:65) is a *single*
global increasing chain `x_0 < … < x_n`. When two owners' interval decompositions are merged, Lemma
3.2(1) (md:77, "conjunction of ∃∀ formulas ≡ **disjunction** of ∃∀ formulas") produces a disjunction
in which **each disjunct is itself an exists-forall formula over the UNION of both owners' points** —
i.e. each disjunct pins down one global order of *all* the merged points, including the *relative
order between the two owners' interior witnesses*. The §5 case split "for ALL possible positions i"
(md:168-173, 218-219) is precisely the enumeration of **where each new point falls in the existing
global chain**, i.e. the complete interleaving. There is no per-owner-independent tagging in the
paper: a disjunct is a *total* description of one merged order.

**Lean side — per-owner tags, no cross-owner link.** `KvE2SepWeakOrder := List (NormalForm sig 1 4 ×
KvE2SepSpikeOrderType)` (SW:694-695): one `(σ, tag)` pair per positive owner. The tag's *doc* claims
to describe "the relative placement of the foreign owner τ's χ-witness against σ's fresh anchor
`x1_σ`" (SW:676-678), but the **validity predicate reads only σ's OWN zone bits**:
`kvE2_sepDisjValidOwner σ .strictBefore = kvE2_sepBits σ kvE_sub2_zXU …`,
`.strictAfter = … zUW …`, `.coincident = kvE2_sepClosedLeafStub σ` (SW:748-752). So each owner's tag
is checked **against that owner's own decomposition relative to `w`** — there is **no conjunct linking
σ's tag to τ's tag** into a consistent global order. Two owners whose anchors interleave differently
(`x1_σ < x1_τ` vs `x1_τ < x1_σ`) are **indistinguishable** to the carrier. The enumeration
`kvE2_sepOrderTypes` (SW:706-711) is the **independent cartesian product** `3^|pos|` of per-owner
tags, not the set of consistent global interleavings.

**Q2 answer**: Rabinovich enumerates the **full cross-owner interleaving** (one global order per
disjunct). The Lean carrier records **only per-owner tags relative to the shared point `w`** and
therefore **under-specifies** the Rabinovich data. The faithful Lean weak-order **MUST be enriched to
carry a cross-owner order on the merged anchor multiset** — the implementation's diagnosis is correct,
and "the bug is elsewhere / a per-owner tag suffices" is **refuted**.

---

## Q3 — Is the proposed v3 direction the faithful construction?

**YES, the v3 weak-order-enrichment direction is faithful — provided it (a) enriches to a genuine
cross-owner order on the merged anchor multiset [Q2], and (b) keeps witness↔anchor coincidence as a
first-class disjunct rather than collapsing to coincidence-only or forcing strict-only [Q1].**

- **Enrich `KvE2SepWeakOrder`/`kvE2_sepOrderTypes`/`kvE2_sepArr'` to carry cross-owner order**:
  **FAITHFUL and REQUIRED.** Rabinovich's merged disjuncts each fix a global order of the union of
  points (Q2, Lemma 3.2(1) md:77 + §5 md:168-219). The enriched enumeration should range over
  **order-consistent global interleavings of the merged anchor multiset**, with the interior
  witnesses strictly ordered among themselves (Def 3.1, md:65) and **witness=anchor coincidences
  admitted as boundary disjuncts** (Lemma 5.3, md:145-152).

- **Retarget non-vacuity/completeness onto `kvE2_sepCoincidentOrder`**: **FAITHFUL for the honest
  completeness witness.** When each owner's fresh type is realized AT its own anchor, the honest
  global order IS the all-coincidence disjunct (Rabinovich's `P_1(r_0)` branch, md:149); this is what
  `kvE2_sepBody_complete` (SW:1592-1611) already exploits via `kvE2_sepCoincidentOwner_valid_left/right`.

- **Does faithfulness instead demand STRICT order (coincidences excluded by genericity)?** **NO.**
  There is no genericity/distinctness hypothesis anywhere in Rabinovich 2014. The Dedekind-completeness
  use (md:146, 221-222) *creates* the meet point `r_0` and explicitly admits `r_0 = z_0` and
  `P_1(r_0)` — i.e. it *manufactures* coincidences rather than excluding them. Strict order is one
  admissible placement, not a required one.

**Caveat for the planner (soundness direction).** The enriched carrier must still **enumerate strict
cross-owner interleavings** as disjuncts (they are valid Rabinovich disjuncts and are the honest
witness for models where the two owners' fresh types are realized in the *open* interval, strictly
interleaved). The completeness proof selects the coincident disjunct; the soundness proof (O3, the
`.holds` realization this task must build) must be able to realize **whichever** global order the
model actually exhibits — this is the "single monotone merge in true model order" of report 01's
Option A, now correctly *carried by* the enriched `wo` and *consumed by* the disjunct builder (which
today ignores it, SW:835-836).

---

## Q4 — Scope reality check: task-334 defs/lemmas impacted (extended vs invalidated)

Verified signatures in `SharedWitness.lean`. "Invalidated" = statement-breaking (type/conclusion
changes, existing proof no longer type-checks against the new statement). "Extended" =
statement/signature survives, proof re-run against new bodies, or the result is reused as-is.

### Definitions that MUST change

| Def | Line | Change | Statement impact |
|-----|------|--------|-----------------|
| `KvE2SepSpikeOrderType` | 679-686 | 3-value per-owner tag (`strictBefore/strictAfter/coincident`) is insufficient to encode cross-owner order; either enrich to carry relative order among all owners, or supplement with a separate global-order structure | **Type-level change** (INVALIDATING for everything that pattern-matches its constructors, incl. `kvE2_sepDisjValidOwner` SW:748-752, `kvE2_sepSpikeOrderTypes` SW:690-691) |
| `KvE2SepWeakOrder` | 694-695 | `List (σ × tag)` → must carry a cross-owner order on the merged anchor multiset (e.g. an ordered/indexed structure, or a tag enriched with relative position) | **Type-level change** (INVALIDATING for the abbrev's users, but most treat it opaquely as "a list of placements") |
| `kvE2_sepOrderTypes` | 706-711 | independent cartesian `3^|pos|` product → enumeration of **order-consistent global interleavings** | signature `List (KvE2SepWeakOrder)` **preserved** if the type name survives; **body changes**, cardinality/content changes |
| `kvE2_sepDisjValidOwner` / `kvE2_sepDisjValid` | 748-752 / 757-759 | per-owner-only validity → add a **cross-owner consistency** conjunct on the global order | `kvE2_sepDisjValid : … → Bool` signature **preserved**; **semantics change** (new conjunct) → downstream conclusions strengthen |
| `kvE2_sepModelOrder` | 719-721 | per-owner `kvE2_sepModelTag` map → must encode the strict cross-owner global order | body change; remains a (conditional, honestly-undischargeable) strict disjunct |
| `kvE2_sepCoincidentOrder` | 1433-1435 | "every owner coincident" → the all-coincidence **global** order in the enriched type | body change; remains the honest completeness disjunct |
| `kvE2_sepBody` | 821-837 | **THE CENTRAL CHANGE**: currently `map fun _wo => kvE2_sepDisjunct … (kvE2_sepSlotsL qnf) (kvE2_sepSlotsR qnf)` **discards `wo`** and uses **fixed** slots (SW:835-836); must consume `wo` to realize each disjunct's cross-owner slot order | returns `VVecEA2` — **signature preserved**; body substantially rewritten. Also implicates the fixed `kvE2_sepSlotsL/R` (SW:315-322) which are `flatMap` concatenations in owner-list order |

### Lemmas — EXTENDED (statement survives; proof re-run or result reused)

- **`kvE2_sepBody_complete`** (SW:1592-1611): conclusion `kvE2_sepArr' qnf ≠ []` **survives** iff
  `kvE2_sepArr'` keeps its name/return type. Proof re-run: still routes through
  `kvE2_sepCoincidentOrder` membership + per-owner coincidence validity. The all-coincidence *global*
  order must remain a member and remain valid — it should, since coincidence is a consistent global
  order. **EXTENDED, not invalidated.**
- **`kvE2_sepCoincidentOwner_valid_left`** (SW:1465) / **`_valid_right`** (SW:1539): per-owner CLOSED
  self-zone bit validity. **Reused as-is** as the per-owner component of the enriched coincidence
  validity; may need a cross-owner-consistency add-on lemma. **EXTENDED (reused).**
- **`kvE2_sepHonestBundleL`** (SW:1211) / **RIGHT bundle** (SW:1257): extract per-owner anchor bounds
  `x1_σ ∈ (x,w)` etc. — **exactly the raw data needed to establish a cross-owner global order**.
  **Reused/extended, not broken.**
- **`kvE2_sepModelOrder_mem_orderTypes`** (SW:791-794), **`kvE2_sepCoincidentOrder_mem_orderTypes`**
  (SW:1456-1459), and their `_mem_aux` helpers (SW:774-788, 1439-1453): membership in the enumeration.
  Statements survive if the type name survives; **proofs re-run** against the new enumeration body.
- **`kvE2_sepBody_gate_fail`** (SW:840-847), **`kvE2_sepBody_holds_iff`** (SW:855+): structural;
  survive with re-proof against the new body.

### Lemmas — STATEMENT-AFFECTED (conclusion changes)

- **`kvE2_sepArr'_sound`** (SW:2594-2601): current conclusion `∀ p ∈ wo, kvE2_sepDisjValidOwner p.1
  p.2 = true` is **per-owner**. Once `kvE2_sepDisjValid` gains a cross-owner conjunct, faithful
  soundness must also assert **cross-owner consistency**. **STATEMENT CHANGES (strengthens).**
- **`kvE2_sepArr'_mem_modelOrder`** (SW:800-805): hypothesis
  `hvalid : kvE2_sepDisjValid qnf (kvE2_sepModelOrder qnf) = true` changes shape once
  `kvE2_sepModelOrder`/`kvE2_sepDisjValid` are enriched. Note: this lemma is **already a dead path for
  completeness** (strict `hvalid` is not honestly provable, SW:1421-1428); enrichment does not revive
  it. It remains a **true conditional**, not a usable completeness route. **STATEMENT-AFFECTED, but
  not a loss** (nothing usable was resting on it).

### Genuinely INVALIDATED (a result is lost)

- **None that was load-bearing.** The strict-model-order completeness route
  (`kvE2_sepArr'_mem_modelOrder`, SW:800) was already known non-dischargeable honestly (SW:1421-1429),
  so its conditional status is unchanged. The FALSE flatMap scaffolds
  (`kvE2_sepSlotsL_valid`/`_valid`) were **already removed** in task-334 Phase 6 (SW:1038-1044) as
  "the identity interleaving of the flat union need not be cross-σ compat" — this is the *same*
  cross-owner-consistency gap this report identifies, confirming the diagnosis independently.

**Net scope**: The **type-level changes to `KvE2SepSpikeOrderType`/`KvE2SepWeakOrder`** are the only
truly invalidating edits, and they cascade to enumeration/validity bodies. **No proved completeness
or soundness *result* is lost** — the completeness path (`kvE2_sepBody_complete` via
`kvE2_sepCoincidentOrder`) is **preserved and re-proved**, and the honest per-owner bundles and
coincidence-validity lemmas are **reused as components**. The bulk of the work is (1) enriching the
carrier type + enumeration + validity to carry/check cross-owner order, and (2) rewiring
`kvE2_sepBody` to **consume `wo`** (the currently-discarded weak order) so each disjunct realizes its
own global slot order instead of the fixed concatenation `kvE2_sepSlotsL/R qnf`.

---

## Key Citations

**Rabinovich 2014** (`rabinovich_2014`):
- **Def 3.1** (md:63-74) — strict chain `x_0 < … < x_n` *within* a disjunct. [Q1]
- **Lemma 3.2(1)** (md:77) — conjunction ≡ disjunction of ∃∀; each merged disjunct is one global
  order over the union of points. [Q2, Q3]
- **Lemma 3.2(2)** (md:78) — reduction to ≤ two free variables `(z_0,z_1)`. [scope]
- **Lemma 5.3 inductive step** (md:145-152) — `r_0 = inf{…}`, `INF` formula `… ∧ (P_1(r_0) ∨
  K+(P_1)(r_0))`, **sub-cases `r_0 = z_0` OR `r_0 ∈ (z_0,z_1)`** — coincidence is a first-class
  disjunct; **no genericity assumption**. [Q1, Q3 — decisive]
- **Insight #2** (md:213-219) — case split "for ALL possible positions i" = full interleaving
  enumeration. [Q2]
- **Insight #3 / Role of Dedekind completeness** (md:221-222) — completeness *manufactures* the meet
  point (and its `K+` limit / coincidence), does not exclude ties. [Q1, Q3]

**SharedWitness.lean**:
- `KvE2SepSpikeOrderType` per-owner tag (SW:679-686); `kvE2_sepSpikeOrderTypes` (SW:690-691).
- `KvE2SepWeakOrder := List (σ × tag)` (SW:694-695) — per-owner, no cross-owner link. [Q2]
- `kvE2_sepOrderTypes` independent cartesian `3^|pos|` (SW:706-711). [Q2]
- `kvE2_sepModelOrder` (SW:719-721); `kvE2_sepModelTag` (SW:714-716).
- `kvE2_sepDisjValidOwner`/`kvE2_sepDisjValid` read only σ's OWN bits (SW:748-759). [Q2, Q4]
- `kvE2_sepArr'` = filter of orderTypes (SW:763-765).
- `kvE2_sepSlotsLFor/RFor` per-owner blocks (SW:292-311); `kvE2_sepSlotsL/R` = `flatMap`
  concatenation in owner-list order (SW:315-322) — the fixed model-independent slots. [Obstruction]
- `kvE2_sepBody` **discards `_wo`, pins fixed slots** (SW:821-837, esp. 835-836). [Obstruction — Q4]
- Task-334 Phase 8 honest-provability finding: strict `kvE2_sepModelOrder` NOT honestly provable;
  coincident is the honest disjunct (SW:1421-1429). [Q1]
- `kvE2_sepCoincidentOrder` (SW:1431-1435); `kvE2_sepBody_complete` via coincidence (SW:1592-1611);
  `kvE2_sepCoincidentOwner_valid_left/right` (SW:1465, 1539). [Q4]
- `kvE2_sepArr'_sound` per-owner conclusion (SW:2594-2601). [Q4 — statement-affected]
- Removed FALSE flatMap scaffolds, "identity interleaving need not be cross-σ compat" (SW:1038-1044) —
  independent confirmation of the cross-owner-consistency gap. [Q2, Q4]
