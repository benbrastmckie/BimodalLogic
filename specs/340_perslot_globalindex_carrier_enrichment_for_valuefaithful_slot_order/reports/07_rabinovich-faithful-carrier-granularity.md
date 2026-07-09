# Task 340 — Rabinovich-Faithful Carrier Granularity (Deep Recheck)

**Task**: 340 — Per-slot global-index carrier enrichment for value-faithful slot order
**Kind**: Hard-mode Lean research (H2/H3/H4/H5). Reference tier: **Tier 1 (literature, faithful
transcription)**. No Lean edited.
**Agent**: lean-research-hard-agent
**Sources verified by direct read**: Rabinovich 2014 md
(`/home/benjamin/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`);
`SharedWitness.lean` (SW) §slots/§carrier/§honest; `SubBracket2V.lean` (engine
`interleaveK`/`k1v_sorted_realizationK`); reports 05/06; 337 `.orchestrator-handoff.json`.

---

## VERDICT (up front)

**(a) Mathematically-correct carrier granularity per Rabinovich**: a **total order over the FULL
multiset of INDIVIDUAL points** — one distinct chain position per witness point, NOT per
(owner, region). Multiple points may carry the same base 1-type and remain distinct positions
(Def 3.1, PDF p.4 / md:61–74; strict chain `x_n > … > x_0`). A per-(owner,region) index is
UNfaithful whenever a region holds ≥2 points, because it (i) loses the interval-type
decomposition `β_j` between same-region points and (ii) cannot represent their strict order. The
only carrier constraints are: (α) linearly extend each owner's region partial order (all
`lXU` < the `lX1` anchor < all `lUW`); (β) at the honest disjunct reproduce M's value order over
the individual points. **Per-slot wins decisively; per-region is refuted.**

**(b) Correct Lean carrier**: replace the per-owner `(ℕ × ℕ × ℕ)` payload with a **per-individual-
slot global index**, computed as `kvE2_ordRank` of the FULL slot family under the lex key
`(M-value, slot-enumeration-index)` — exactly the construction `kvE2_ordRank`'s own docstring
already names ("`g = (model value, slot index)` in the lex order", SW:781–782) but which the
landed code instantiates only at the **anchor/owner** family (`kvE2_sepAnchorFam`, `n` = #owners),
not the slot family (`N` = #individual slots). The carrier TYPE must change:
`ℕ×ℕ×ℕ` → a per-slot index (recommended: a global `List (KvE2SepSlot × ℕ)` assignment, or a
per-owner `List ℕ`).

**(c) Preserved vs rebuilt**: The mathematical kernel survives **verbatim** — `kvE2_ordRank` +
`kvE2_ordRank_lt/_strictMono/_injective` (SW:783–832) are already fully general (`Fin n → β`,
any `LinearOrder β`; hover-confirmed), and just re-instantiate at the slot family. The slot
enumeration, the realization engine, and the tag/coincidence discharge are all untouched. What
is **rebuilt** is the INDEX LAYER (type payload, `kvE2_sepIdxTuples`, `kvE2_sepSlotGIdx`,
`kvE2_sepConsistentTuple`, `kvE2_sepHonestTuple`/`Order`, membership plumbing) plus ONE genuinely
new alignment proof. This is a **BOUNDED refinement of Phases 2–5, not a fuller carrier rebuild**;
estimate **4–6 H8 phases**.

**(d) 340→337→335 seam**: **Restored.** Per-slot value-faithful gidx makes
`kvE2_sepSlotsLOf(honestOrder)` (mergeSort by gidx) equal to the engine's value-sorted
`interleaveK ps` order, so the previously-unprovable `halignL/R` becomes provable; the whole
337 Phase-1 destructure (`hpos/hlink/hnd/hreal/halign/hbdry`) then discharges, and 337's joint
`.holds` engine unblocks 335. The acyclic seam holds.

---

## H3 Reference-Grounding Table (faithfulness claim → Rabinovich anchor → carrier site → status)

| Source loc (PDF p / md line) | Rabinovich proposition | Lean identifier / carrier site | Type / shape | Status |
|---|---|---|---|---|
| Def 3.1, p.4 / md:65–72 | ∃∀-formula posits INDIVIDUAL points `x_n>…>x_0`, each with type `α_j`, interval type `β_j` between consecutive points | `KvE2SepSlot` (SW:219) individual slots; `kvE2_sepSlotType` (SW:277) | `inductive … deriving DecidableEq` | FAITHFUL (slot layer) |
| Def 3.1, p.4 / md:65,74 | Strict chain: distinct `x_i`; two points may share a base type yet be distinct positions | full-slot order (target) vs current per-owner tuple | `ℕ×ℕ×ℕ` per owner (SW:702) | **DEFECT** — 3 indices/owner, ties within region |
| Lemma 3.2(1), p.4 / md:77 | Conjunction of ∃∀-formulas = disjunction of ∃∀-formulas; enumerates INTERLEAVINGS of the individual points into one strict chain | `kvE2_sepOrderTypes` (SW:841), `kvE2_sepArr'` (SW:921) | `List (KvE2SepWeakOrder sig)` | PARTIAL — interleaves owners, ties slots |
| Def 3.1 interior/exterior `β`, md:66–74 | Interval-type decomposition requires knowing individual point boundaries | `kvE2_sepConsistentTuple` (`i₀<i₁<i₂`, SW:902) | `ℕ×ℕ×ℕ → Bool` | INCOMPLETE — orders 3 region ranks only |
| §5 / Lemma 5.1, p.7–9 / md:161–173 | Insertion point `z` corresponds to a specific position `i`; negation ranges over ALL individual positions `i` (`A_i⁻ ∧ A_i⁺`) | cross-region `a<u'<b` interleave (report 06 G6) | `kvE2_sepSlotMergeLe` (SW:1021) | FAITHFUL intent, blocked by tie |
| Def 7.13, p.15 / md:202; Lemma 7.14 md:204 | Multi-reference-point (`z_0,…,z_k,∞`) framing — the multi-owner union is the object | `kvE2_sepSlotsLOf/ROf` (SW:1034/1040) merged chain | `List (KvE2SepSlot sig)` | FAITHFUL |
| Insight #3, md:221–222; INF md:145–152 | Model contact (value order) enters once, at realization; Dedekind completeness used once | `kvE2_ordRank g` needs `h`; enum stays model-independent | `Fin n → β → ℕ` | FAITHFUL (the 340/337 seam) |

*Citation note*: the Literature entry is a faithful section-level summary; md line anchors are
verified by direct read, PDF pages are the paper's known structure (concordant with report 06's
PDF-page citations).

---

## Literature Proof Structure (the ground truth, Q1–Q3)

**Def 3.1 (PDF p.4 / md:61–74).** `psi(z_0,…,z_m) := ∃x_n…∃x_0 [ ordering constraints on x_i,z_j ]
∧ (α_j(x_j) at x_j, j=0..n) ∧ (β_j along (x_{j-1},x_j), j=1..n) ∧ (β_{n+1} after x_n) ∧ (β_0 before
x_0)`. The `x_j` are **individual existential points in a strict order** `x_0<x_1<…<x_n`
(md:65,74). The `α_j` are quantifier-free types and **need not be distinct across `j`** — two
points `x_i≠x_j` may satisfy `α_i=α_j` yet occupy distinct chain positions. Each consecutive pair
is separated by its own interval type `β_j`. **Consequence (Q1)**: the faithful "slot chain" is a
**total order over the full multiset of individual points**, at **per-slot granularity**. A
per-region (or per-owner-region) grouping is unfaithful the moment a region contains ≥2 points,
because it collapses those distinct positions to one index and discards the `β` between them.

**Lemma 3.2(1) (PDF p.4 / md:77).** Conjoining two ∃∀-formulas forces merging their two strict
point-chains into **all order-consistent interleavings** — a total order over the **union
multiset** of individual points, each interleaving a disjunct (Q2). Nothing in the paper permits
collapsing same-region points to one index: doing so erases the interval decomposition that
Def 3.1 and §5 depend on.

**§5 / Lemma 5.1 (PDF p.7–9 / md:161–173).** Negation-by-insertion splits an interval at a point
`z` that corresponds to a **specific individual position `i`** (`A_i⁻(z_0,z) ∧ A_i⁺(z,z_1)`,
md:168–171); the negation quantifies over ALL positions `i`. This is per-individual-point
bookkeeping; it is undefinable over a per-region grouping.

**Def 7.13 (PDF p.15 / md:202).** Multi-reference-point framing confirms the joint object is a
single order over the union of all owners' individual points (Q3). **Conclusion (Q3)**: the
mathematically correct carrier is a **value-ranked total order over the FULL individual-slot
multiset across all owners and regions**, with the ONLY constraints (α) it linearly extends each
owner's region order (`lXU` < `lX1` < `lUW`), and (β) at the honest arrangement it reproduces M's
value order. This is confirmed, not corrected.

---

## Findings — the Lean carrier (Q4–Q5)

### The confirmed defect (root cause)

- Slot layer is already per-individual: `kvE2_sepSlotsLFor` (SW:292) emits a **list** —
  `(kvE2_sepS σ zXU).map (.lXU σ) ++ .lX1 σ :: (kvE2_sepS σ zUW).map (.lUW σ)` — so one
  (owner, region) holds MANY base slots.
- But `kvE2_sepSlotRank` (SW:245) gives every `.lXU` rank 0 and every `.lUW` rank 2, and
  `kvE2_sepSlotGIdx` (SW:1006) reads the owner tuple `t` **at that region rank** (`0↦t.1`,
  `1↦t.2.1`, `_↦t.2.2`). Hence every `.lXU` of an owner returns the same `t.1` — a **TIE**.
- `kvE2_sepHonestTuple` (SW:2095) = `(3r, 3r+1, 3r+2)` with `r = kvE2_ordRank (kvE2_sepAnchorFam …)`
  — `kvE2_ordRank` is applied to the **anchor family** (owner granularity, `n`=#owners), never to
  the slot family. So the value-rank kernel exists but is wired one level too coarse.
- `kvE2_sepSlotsLOf` (SW:1034) mergeSorts by that tied key, so within-region slots stay in
  `Finset.univ.toList` enumeration order (`kvE2_sepS`, SW:178), NOT M-value order.
- The engine `k1v_sorted_realizationK` (SubBracket2V:633) produces per-region point lists that are
  `Pairwise (· < ·)` in **M-value** (it internally value-sorts each region via
  `k1v_sorted_realization`). Aligning the carrier's tied order with the engine's value order
  (`halignL/R`) is therefore unprovable whenever a region holds ≥2 slots — precisely the 337
  Phase-1 blocker (`.orchestrator-handoff.json` root_cause).

### Correct Lean representation (Q4)

`kvE2_sepSlotGIdx wo s` must become a **per-individual-slot global index** = the rank of `s` in
the M-value order of the FULL slot multiset, tie-broken by the slot's enumeration index:

```
G : Fin N → (M.carrier × ℕ)        -- N = total individual slots; G j = (value_j, j)  (lex)
kvE2_sepSlotGIdx_honest s = kvE2_ordRank G (slotIndexOf s)
```

This is the kernel's own documented use (SW:781–782). Because the second lex component (the slot
index) is injective, `G` is injective with NO value-distinctness hypothesis — resolving the exact
"distinct owners may share witness values" crux flagged at SW:774. Then `kvE2_sepSlotsLOf`
(mergeSort by this gidx) reproduces the engine's value order **exactly**.

**Carrier TYPE must change**: `ℕ×ℕ×ℕ` (3 per owner) → a per-slot index. Recommended representation:
a global assignment enumerated as `List (KvE2SepSlot sig × ℕ)` (indices `< N`), or equivalently a
per-owner `List ℕ` whose length is the owner's slot-block length. Because slots-per-owner is
model-data-dependent (`kvE2_sepS` counts), the fixed 3-arity is fundamentally wrong; the payload
must be variable-arity over the individual slots.

### Preserved vs Rebuilt (Q5)

**PRESERVED VERBATIM (re-instantiate, do not re-prove):**
- `kvE2_ordRank`, `kvE2_ordRank_lt`, `kvE2_ordRank_strictMono`, `kvE2_ordRank_injective`
  (SW:783–832) — fully general `{β}[LinearOrder β]{n}(g:Fin n→β)`, **hover-confirmed**. Instantiate
  at the slot family (N) instead of the anchor family (n). THE keystone.
- Slot enumeration: `KvE2SepSlot`, `kvE2_sepSlotSub`, `kvE2_sepSlotRank`, `kvE2_sepS`,
  `kvE2_sepBits`, `kvE2_sepSlotsLFor/RFor` (SW:152–311) — already individual-slot; unchanged.
- Realization engine: `interleaveK` (SubBracket2V:453), `k1v_stitch_regions` (:492),
  `k1v_sorted_realizationK` (:633) — already per-slot value-sorting; unchanged.
- Tag/coincidence discharge: `kvE2_sepClosedLeafStub` (SW:880),
  `kvE2_sepCoincidentOwner_valid_left/right`, coincidence discharges — tuple-agnostic; reused
  verbatim (per SW:2086–2088, 2143).
- `kvE2_sepAnchor_injOn` (SW:2042) + `kvE2_sepAnchorFam` — anchor distinctness (report 06 keystone).
  Becomes a special case / feeds the anchor sub-order; retained.
- `kvE2_sepSlotsLOf_mem` (SW:1092, via `List.mergeSort_perm`) — form-preserved.

**REBUILT (arity/wiring change, proof scaffolding reused):**
- Carrier payload type `ℕ×ℕ×ℕ` in `KvE2SepWeakOrder` (SW:702) → per-slot index.
- `kvE2_sepIdxTuples` (SW:734) and `kvE2_sepIdxTuple_mem_of_lt` (SW:757) → per-slot index
  enumeration + membership (same `List.mem_flatMap`/`List.mem_range` technique, new arity).
- `kvE2_sepSlotGIdx` (SW:1006) → read per-slot index directly.
- `kvE2_sepConsistentTuple` (SW:902) → generalize to: per-owner **region-rank monotonicity**
  (every `lXU`-gidx < the anchor-gidx < every `lUW`-gidx) + global `Nodup`; consumed via
  `kvE2_ordRank_strictMono`/`_injective`. NB within-region order is FREE in the enum (value-set at
  the honest disjunct), so the constraint is the region PARTIAL order, not a 3-chain.
- `kvE2_sepHonestTuple`/`kvE2_sepHonestOrder` + `_mem_orderTypes`/`_mem_arr'` (SW:2095–2159) →
  per-slot `kvE2_ordRank` honest index; reuse `kvE2_sepOrderTypes_mem_aux` + `kvE2_ordRank_lt`.
- **NEW proof (the crux that was unprovable)**: `halignL/R` — `kvE2_sepSlotsLOf(honestOrder)`
  (mergeSort by per-slot gidx) = engine `interleaveK ps` value order. Now provable: both are the
  M-value order over individual slots, tie-broken identically by slot index.

**Scope**: BOUNDED refinement of Phases 2–5. Suggested H8 phases:
- **P-A** carrier type + per-slot index enumeration + `mem_of_lt` generalization (~200–300 lines).
- **P-B** `kvE2_sepSlotGIdx` rebuild + consistency = region-partial-order + Nodup via ordRank
  lemmas (~200 lines).
- **P-C** honest per-slot order via `kvE2_ordRank` over the full slot family + membership (~200–400).
- **P-D** `halignL/R` alignment proof (the hardest; ~300–500 lines) — mergeSort-by-gidx =
  engine value order.
- **(P-E optional)** re-thread 337 Phase-1 destructure inputs.

### Impact on 337/335 (Q6)

With per-slot value-faithful gidx: `kvE2_sepSlotsLOf(honestOrder)` = engine's `interleaveK ps`
order ⇒ `halignL/R` provable; `hbdry` (endpoint boundary alignment) follows from the region
skeleton. The region-skeleton preconditions `hpos/hlink/hnd/hreal` were already largely derivable
(report 06 SW:2255–2257: from the anchor keystone + `kvE2_ordRank_strictMono` + honest bundles
`kvE2_sepHonestBundleL/R`); `hnd` (per-region base-type `Nodup`) is strengthened for free because
distinct slots now have distinct indices. So 337's Phase-1 bundle
`kvE2_sepHonest_engineInputs` discharges, 337's joint `.holds` builder proceeds, and the acyclic
**340→337→335** seam is restored.

---

## Adversarial Self-Verification (H4)

**Refutation attempt**: *"Per-slot total order is NOT required — per-region suffices, because each
realizable region actually contains exactly one slot (so no ties arise), or because the engine
already value-sorts within a region so the carrier index need not."*

**Test 1 — can `kvE2_sepS σ zs` select ≥2 χ?** `kvE2_sepS σ zs = Finset.univ.toList.filter
(kvE2_sepBits σ zs)` (SW:178); `kvE2_sepBits σ zs χ = σ.2 (nf0_assemble zs χ σ.1)` (SW:152) — an
unconstrained `Bool` read. There is NO cardinality bound forcing ≤1. For any signature with ≥2
atoms, `NormalForm sig 0 1` has ≥2 elements and the bit can fire on several simultaneously (an
owner whose (x,x1) interval realizes two distinct base 1-types). The engine's own `hreal`
(SubBracket2V:638) gives **each** such χ its **own** witness point, `Pairwise (· < ·)`. So ≥2
**distinct individual points per region genuinely ARISE in a realizable honest disjunct.** The
"exactly one slot" escape is **false**.

**Test 2 — can the engine's internal within-region sort absolve the carrier?** No.
`kvE2_sepSlotsLOf` (SW:1034) is a mergeSort that **commits the carrier to a specific total slot
order** consumed downstream (337's `.holds`). If gidx ties within-region slots, that committed
order is enumeration order, while the engine emits value order — the two lists differ, so
`halign` (their equality) is false. The carrier cannot delegate an order it has already asserted.

**Which side wins**: **Per-slot required; per-region refuted.** Both escapes fail; and Def 3.1 /
Lemma 3.2(1) independently mandate individual-point granularity. Report 06's design gate PASS was
correct on the **anchor keystone** (distinct owners ⇒ distinct anchors ⇒ `kvE2_ordRank` strict on
the anchor family) but **over-generalized** it: it declared the owner-block tuple `(3r,3r+1,3r+2)`
"terminal", which is exactly the region-by-owner product task 340's description forbade. Its G5
verdict ("linear extension of each owner's region order", FAITHFUL) is true as a **constraint**
but silent on the tuple's **arity** — the actual defect.

### Claim Verification Table

| Claim | Source / Counterexample | Verification Method | Confidence |
|---|---|---|---|
| ∃∀ points are individual, same type ⇒ distinct positions | Def 3.1 md:65,74 | direct md read | High |
| Merging = interleaving individual points (total order over union) | Lemma 3.2(1) md:77 | direct md read | High |
| `kvE2_ordRank` is fully general `Fin n→β`, any `LinearOrder β` | SW:783 | **lean_hover_info-confirmed type signature** | High |
| Kernel docstring already names `g=(value, slot index)` lex fix | SW:781–782 | lean_hover_info-confirmed | High |
| Honest tuple applies ordRank at ANCHOR family, not slots | SW:2095–2102 | direct source read | High |
| `kvE2_sepSlotGIdx` reads tuple at region rank ⇒ within-region tie | SW:1006–1013 | direct source read | High |
| `kvE2_sepS` filter can select ≥2 χ (realizable ≥2 slots/region) | SW:152,178 | direct source read + definitional argument | High |
| Engine value-sorts within region (`Pairwise (· < ·)`) | SubBracket2V:633 (`hsortps`/`interleaveK`) | direct source read | High |
| `halign` unprovable under tie; provable under per-slot gidx | 337 handoff root_cause; SW:1034 vs engine | cross-read (handoff + source) | High |
| Preserved-asset generality (ordRank family re-instantiates) | SW:788–832 | direct source read | High |
| Seam 340→337→335 restored | report 06 SW:2255–2257 + handoff missing-list | cross-read | Medium-High |

**Contradiction Log**: One resolved. Report 06 ("carrier is terminal; no carrier change", SW:18)
vs task-340 description + 337 handoff ("carrier-granularity gap"). Resolution (precedence:
primary source Def 3.1 + confirmed 337 blocker outrank a derived gate opinion): report 06's
terminality claim is **incorrect at slot granularity**; its anchor-keystone finding is correct and
preserved. No unresolved contradictions.

---

## H5 note

`focus_prompt` did not contain "divergence"/"audit" as mode triggers, but this report functions as
the anti-churn deliverable: the definitive per-slot design so the next round does not under-shoot
granularity a fourth time. Divergence summary — target `kvE2_sepSlotGIdx`/carrier-tuple: churn ≈3
(339 region-primary lex → 340 per-owner-region tuple → still tied); root cause: `kvE2_ordRank`
wired at owner/anchor granularity while the slot layer is per-individual; corrected Lean-ready
target: `kvE2_sepSlotGIdx s := kvE2_ordRank G (slotIndexOf s)` with `G j = (value_j, j)` lex over
`Fin N` (full slot multiset).
