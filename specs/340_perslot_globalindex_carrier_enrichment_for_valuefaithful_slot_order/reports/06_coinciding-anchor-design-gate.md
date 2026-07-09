# Task 340 Phase 5 — Coinciding-Anchor DESIGN GATE

**Task**: 340 — Per-slot global-index carrier enrichment for value-faithful slot order
**Kind**: DESIGN GATE (analysis + Rabinovich faithfulness proof, mirroring task 339 Phase 1).
No Lean edited. Reference tier: **Tier 1 (literature, faithful transcription)**.
**Session**: sess_1783561356_89aa2d_340_gate
**Sources verified by direct read**: `SharedWitness.lean` (SW), `SubBracket2V.lean`,
`NormalForm.lean:245` (`nf_eval_unique`), Rabinovich 2014 md (Def 3.1 md:61-74, Lemma 3.2 md:77,
§5 meet md:145-175, Def 7.13 md:202).

---

## GATE VERDICT: **PASS** (with a corrected diagnosis)

The layout is fully settled with **no remaining fork**. The blocking "coinciding-anchor decision"
**dissolves**: the premise that two owners' anchors can coincide is **false**. There is a single
honest order — `coincident` tags on every owner + a value-rank **owner-block** tuple
`(3r, 3r+1, 3r+2)` where `r = kvE2_ordRank` of the anchor family. The carrier is **terminal**
(no carrier change). The residual meet-type coincidence (a *foreign base witness* landing at an
anchor — a different phenomenon) is a 337 realization obligation with an already-proven discharge
mechanism, **not** a carrier fork.

---

## KEYSTONE FINDING (the fork dissolves)

**Claim (verified): distinct positive owners have distinct anchors.** For `σ ≠ τ ∈ kvE2_sepPos qnf`,
their fresh anchors satisfy `x1_σ ≠ x1_τ`.

**Proof.** `kvE2_sepPos qnf = (Finset.univ.toList).filter (qnf.2 ·)` (SW:193-195); `Finset.toList`
is `Nodup` and `filter` preserves it, so **owners are pairwise distinct as normal forms**. Owner
`σ`'s anchor `x1_σ` is `Classical.choose` of `(h_quant σ).mpr hb`, giving
`hσ : nf_eval_nf M 1 4 (Fin.cons x1_σ (Fin.cons w (Fin.cons x (fun _ => t)))) σ` (the exact shape
`kvE2_sepHonestBundleL/R` extract, SW:1570 / SW:1622). If `x1_σ = x1_τ =: a` then the single
environment `[a,w,x,t]` realizes **both** `σ` and `τ` at depth 1, arity 4. `nf_eval_unique`
(`NormalForm.lean:245`, general over `k n`: any env realizes a unique normal form) gives
`σ = τ` — contradiction. ∎

**Consequence.** The anchor family `g : Fin n → M.carrier`, `g k = x1_{σₖ}`, is **injective** and
**strictly totally orderable**. Coinciding anchors NEVER arise. Therefore:
- plain `kvE2_ordRank g` (SW:783) is a **strict** total order — no ties;
- the value-rank owner-block tuple is well-defined and its induced slot chain is M-value-monotone;
- there is **nothing to bifurcate on**.

**Where the handoff mis-stepped.** Handoff #2 point 3 wrote "when two anchors COINCIDE
(`x1_σ = x1_{σ'}`, which SW:1585 says is possible)". SW:1585 is `refine ⟨x1, hxx1, hx1w, ?_, ?_⟩`
inside `kvE2_sepHonestBundleL` — it asserts nothing about two anchors coinciding. The real crux
lives at SW:1652-1666 (`kvE2_sepFreshAnchor_ne_baseChiPoint`) and concerns a **foreign depth-0 base
witness** `χ` coinciding with an anchor — an entirely different object from a second owner's anchor.
The handoff conflated the two coincidences; that conflation manufactured a fork that does not exist.

---

## H3 Citation Table (faithfulness claim → Rabinovich anchor → carrier site)

| # | Faithfulness claim | Rabinovich anchor | Carrier site (340) | Verdict |
|---|--------------------|-------------------|--------------------|---------|
| G1 | The witness is a single **strict** chain `x_n > … > x_0` of existential points | Def 3.1, p.4 / md:61-74 ("ordering constraints on x_i"; strict distinct `x_i`) | anchor family `g k = x1_{σₖ}`, provably injective (keystone) | FAITHFUL |
| G2 | **Reference points `z_j` may collapse onto a chain point `x_i`** (`z_k = x_{i_k}`); the `r_0 = z_0` sub-case is explicit | Lemma 5.3 / §5, md:151 ("Sub-cases: r_0 = z_0 or r_0 ∈ (z_0,z_1)"); §5 meet md:168-173 | `coincident` tag + CLOSED `zAtX1L`/`zAtX1R` bit, discharged by `kvE2_sepCoincidentAnchor_discharge` (SW:1695) | FAITHFUL |
| G3 | Merging owners = **disjunction over order-consistent interleavings** | Lemma 3.2(1), p.4 / md:77 | `kvE2_sepOrderTypes` / `kvE2_sepArr'` filter over `kvE2_sepIdxTuples n` | FAITHFUL |
| G4 | Multi-**owner** union (multiple reference points) is the object | Def 7.13, p.15 / md:202; Lemma 7.14 md:204 | cross-owner slot multiset `kvE2_sepSlotsLOf/ROf` | FAITHFUL |
| G5 | Global order is a **linear extension of each owner's region order** (`lXU<lX1<lUW`) | Def 3.1 interior/exterior β, md:66-74 | `kvE2_sepConsistentTuple` (`i₀<i₁<i₂`, SW:902) | FAITHFUL |
| G6 | The `a<u'<b` cross-region interleave is one of the "for ALL positions i" disjuncts | §5 / Lemma 5.1, md:161-173 | block tuple: `i₂(σ)=3r_σ+2 < 3r_τ+1=i₁(τ)` when `r_σ<r_τ` | FAITHFUL |
| G7 | Model contact (value order) lives at **realization**, once; Dedekind completeness used once | Insight #3, md:221-222; INF md:145-152 | value rank `kvE2_ordRank g` is per-M (needs `h`); the enum `kvE2_sepArr'` stays model-independent | FAITHFUL (the 340/337 seam) |

---

## The five gate questions

### Q1 — Representative M-value per (owner, region-rank). **SETTLED.**

The representative for **all three** zones of owner `σ` is the single anchor value `x1_σ`
(region-1's unambiguous witness, `(h_quant σ).mpr hb`, cf. SW:1570). The block tuple
`(3r, 3r+1, 3r+2)` positions σ's *entire* three-zone band by `r = rank(x1_σ)`; the two interior
slots (r=0 `lXU`, r=2 `lUW`) do **not** get their own sort key — they reserve the two indices
flanking σ's anchor index `3r+1`. This is the faithful choice because (a) the coarse carrier
assigns one index per (owner, region) zone (SW:939-1013), so it *cannot* interleave individual
interior witnesses across owners anyway, and (b) interior witnesses are constrained only to
`(x, x1_σ)` / `(x1_σ, w)` — their sole fixed reference is `x1_σ`, so clustering them adjacent to it
is canonical. Picking a *separate* interior representative M-value (handoff step 1's alternative)
would re-introduce the 339 region-primary interleaving defect and buys nothing.

### Q2 — Bifurcation rule. **SETTLED: there is no bifurcation.**

- **Not** a clean per-model dichotomy (all-distinct → strict / any-coincidence → coincident).
- **Not** a finer per-pair merge.
- It is a **non-fork**: exactly one honest order for every honest interior realization —
  `coincident` tags on all owners (forced by the empirical finding SW:1755-1763: at σ's own anchor
  its own fresh type holds, so the CLOSED bit is TRUE while the strict-tag OPEN bits are *not*
  dischargeable), and value-rank block tuples (forced by monotone realizability of the slot chain).

**Does the lex `(value, index)` tie-break sidestep or hide the crux?** It does **neither — it is
unnecessary.** A tie-break only matters when values can tie; the keystone shows anchor values never
tie, so plain value rank is already injective. (The lex family remains a *safe* implementation
choice: its 2nd coordinate makes `kvE2_ordRank_injective` hold structurally even before invoking the
keystone. But it does not "hide" an anchor-coincidence crux, because none exists.) What the handoff
feared — that a lex order forces strict separation the model can't realize when `x1_σ = x1_τ` — is
moot: `x1_σ = x1_τ ⟹ σ = τ`.

**Why region-primary (`kvE2_sepCoincidentOrder`, SW:1767) is NOT the witness 337 realizes.** Its
placeholder tuple `(k, n+k, 2n+k)` groups *all* owners' region-0 slots below *all* anchors below
*all* region-2 slots. With distinct interleaved anchors `x1_A < x1_B`, owner B's region-0 witness
`∈ (x, x1_B)` can exceed the anchor `x1_A`, so "all region-0 < all anchors" fails — the merged slot
list `kvE2_sepSlotsLOf` is **non-monotone** and 337 cannot realize it in general. It stays a proven
member (harmless, the degenerate/single-owner case); the general witness must be the block order.

### Q3 — Faithfulness proof. **PASS.**

Map to Def 3.1's `ψ(z_0,…,z_m) := ∃x_n…∃x_0 (x_n > … > x_0) ∧ α_j(x_j) ∧ β_j`-along-intervals
(p.4 / md:61-74):
- **Strict chain `x_i`** ↔ owners' anchors `x1_σ`, **provably distinct** (keystone) — a genuine
  strict chain, exactly Def 3.1's `x_n > … > x_0`. The value-rank block order **is** this chain.
- **`α_j(x_j)`** (type at the point) ↔ each anchor realizing its owner's depth-1 type.
- **`β_j` along `(x_{j-1}, x_j)`** ↔ interior region-0/region-2 base types realized between
  consecutive anchors (the honest bundles, SW:1556/1608).
- **`a<u'<b` interleave** ↔ Lemma 3.2(1)/§5 "for ALL positions i" (md:161-173): owner σ's region-2
  slot below owner τ's anchor is `3r_σ+2 < 3r_τ+1` for `r_σ<r_τ`, an order-consistent linear
  extension (G6). Admitting it *repairs* task 339's dropped disjunct.
- **Coincident tags ≠ soundness dodge.** The `z_k = x_{i_k}` collapse (a *reference* point `z`
  coinciding with a chain point `x_i`, Def 3.1 free `z_j`; the `r_0 = z_0` sub-case, md:151) is
  precisely a **foreign base witness realized AT an anchor** — discharged, not refuted, by
  `kvE2_sepCoincidentAnchor_discharge` (SW:1695) via the CLOSED self-zone channel §5 meet
  (md:168-173). This is a *legitimate disjunct of the Lemma 3.2(1) enumeration* (the point genuinely
  realizes both the depth-1 fresh type and the depth-0 χ, the existential `charK`), so routing to
  `coincident` is the paper's meet-type identification, **not** a way to avoid an obligation. The
  strict chain of `x_i` (anchors) and the collapse of `z_j` (foreign witnesses) onto them are the
  paper's *two distinct* mechanisms; the carrier keeps them distinct (block tuple = strict `x_i`
  chain; coincident tag/CLOSED bit = `z_j` collapse). FAITHFUL.

### Q4 — Membership + monotonicity coverage. **PASS (one bounded 337 residual).**

- **Membership** (`kvE2_sepHonestOrder ∈ kvE2_sepArr'`): all three `kvE2_sepDisjValid` conjuncts
  (SW:913-917) discharge —
  - (i) tag validity: every tag `.coincident` → `kvE2_sepCoincidentOwner_valid_left/right`
    (SW:1788/1862) reused **verbatim** (they read only the tuple-independent CLOSED bit; needs
    `hLR`);
  - (ii) `i₀<i₁<i₂`: `3r < 3r+1 < 3r+2` by `omega`;
  - (iii) `i₀`-`Nodup` (only `i₀` is required, SW:917): `i₀ = 3·r`, `r` injective via
    `kvE2_ordRank_injective` (SW:825), `3·(·)` injective → `Nodup`.
  - enumeration membership: `kvE2_ordRank_lt` (SW:788) gives `3r+2 < 3n` → `kvE2_sepIdxTuple_mem_of_lt`
    (SW:757) → `kvE2_sepOrderTypes_mem_aux` (SW:935). Both branches (block + the retained
    region-primary) land in `kvE2_sepArr'`. **No gap.**
- **Monotonicity** (`kvE2_sepSlotsLOf/ROf` reproduce M-value order): the merge key
  `kvE2_sepSlotGIdx` (SW:1006) on the honest `wo` is the block index; `mergeSort` yields owner bands
  in anchor order; the `a<u'<b` step `i₂(σ) < i₁(τ) ⟺ r_σ < r_τ ⟺ x1_σ < x1_τ` via
  `kvE2_ordRank_strictMono` (SW:807) + the keystone (lex = value order since anchors distinct).
  **No gap.**
- **Bundle** `hpos/hlink/hnd/hreal` for `k1v_sorted_realizationK` (SubBracket2V.lean:633-646):
  `regions` = consecutive distinct-anchor intervals; `hpos` (strict `a_i < a_{i+1}`) and `hlink`
  (boundary-linked) from the keystone (anchors strictly ordered) + `kvE2_ordRank_strictMono`; `hnd`
  from per-zone base-type list `Nodup`; `hreal` from the honest bundles + clustering freedom.
  **RESIDUAL (337, bounded, not a carrier fork):** every slot — including each `lX1` anchor — is a
  *strict* bracket point (`kvE2_sepBracketN` point types `lL ++ ptW :: lR`, SW:602-608; `lX1 σ ↦
  kvE2_sepPtX1L`, SW:281). If a *foreign base witness* is realizable **only** at an anchor point,
  that slot cannot be a distinct strict point and must fold into the anchor's segment via the
  meet-type (CLOSED-zone) discharge. This is 337's `.holds` obligation and its mechanism already
  exists (`kvE2_sepCoincidentAnchor_discharge`); it requires **no carrier change** — the block
  layout and `coincident` tags are exactly what feed it.

### Q5 — Concrete def + proof skeleton + phase sizing. Below.

---

## Concrete Lean-ready targets for the next dispatch

All model-dependent (take `M w x t` and the realization `h`), like the completeness-side witness
should be (report 02 Q2 — the value order is inherently per-M).

```lean
-- KEYSTONE (Phase 5A): distinct owners ⟹ distinct anchors.
noncomputable def kvE2_sepAnchorVal {sig} (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (σ : NormalForm sig 1 4) : M.carrier            -- Classical.choose ((h.2 σ).mpr _), default x off-pos

theorem kvE2_sepAnchor_injOn {sig} (qnf M w x t h) :
    ∀ σ ∈ kvE2_sepPos qnf, ∀ τ ∈ kvE2_sepPos qnf,
      kvE2_sepAnchorVal qnf M w x t h σ = kvE2_sepAnchorVal qnf M w x t h τ → σ = τ
-- proof: both anchors realize their owner at [a,w,x,t]; nf_eval_unique M 1 4 … ⟹ σ = τ.

-- ANCHOR FAMILY + RANK (Phase 5A):
--   n := (kvE2_sepPos qnf).length
--   g : Fin n → M.carrier ×ₗ Fin n := fun k => (kvE2_sepAnchorVal … ((kvE2_sepPos qnf).get k), k)
--   r k := kvE2_ordRank g k        -- strict; injective via 2nd coord AND via keystone

-- HONEST ORDER (Phase 5B):
noncomputable def kvE2_sepHonestOrder {sig} (qnf M w x t h) : KvE2SepWeakOrder sig :=
  let n := (kvE2_sepPos qnf).length
  let g  : Fin n → M.carrier ×ₗ Fin n := fun k => (kvE2_sepAnchorVal qnf M w x t h ((kvE2_sepPos qnf).get k), k)
  (kvE2_sepPos qnf).zipIdx.map (fun p =>
    (p.1, KvE2SepSpikeOrderType.coincident,
     let r := kvE2_ordRank g ⟨p.2, by …⟩; (3*r, 3*r+1, 3*r+2)))

theorem kvE2_sepHonestOrder_mem_orderTypes (qnf M w x t h) :
    kvE2_sepHonestOrder qnf M w x t h ∈ kvE2_sepOrderTypes qnf
-- via kvE2_sepOrderTypes_mem_aux with gt = block tuple, hb from kvE2_ordRank_lt → kvE2_sepIdxTuple_mem_of_lt.

theorem kvE2_sepHonestOrder_mem_arr' (qnf M w x t h)
    (hxw : x < w) (hwt : w < t)
    (hLR : ∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3) :
    kvE2_sepHonestOrder qnf M w x t h ∈ kvE2_sepArr' qnf
-- structural mirror of kvE2_sepCoincidentOrder_mem_arr' (SW:1966): (i) coincident validators VERBATIM;
-- (ii) omega on 3r<3r+1<3r+2; (iii) Nodup via kvE2_ordRank_injective on i₀=3r.

-- MONOTONICITY (Phase 5C):
theorem kvE2_sepHonestOrder_monotone (qnf M w x t h) …
--   kvE2_sepSlotGIdx (honest wo) reproduces the block order; the a<u'<b link
--   i₂(σ)<i₁(τ) ⟺ r_σ<r_τ ⟺ x1_σ<x1_τ via kvE2_ordRank_strictMono + keystone.
--   Feeds List.sorted_mergeSort / List.mergeSort_perm for kvE2_sepSlotsLOf/ROf.

-- ENGINE BUNDLE (Phase 5D):  regions = consecutive distinct-anchor intervals.
theorem kvE2_sepHonestBundle_export (qnf M w x t h) … :
    ∃ regions, (∀ r ∈ regions, r.1 < r.2.1) ∧ List.Chain' (·.2.1 = ·.1) regions ∧
      (∀ r ∈ regions, r.2.2.Nodup) ∧ (∀ r ∈ regions, ∀ χ ∈ r.2.2, ∃ u, r.1<u ∧ u<r.2.1 ∧ …)
-- hpos/hlink from keystone + strictMono; hnd from zone base-type Nodup; hreal from honest bundles.
-- This is the object k1v_sorted_realizationK (SubBracket2V.lean:633) consumes; the .holds is 337's.
```

### Phase sizing (H8, one agent-run each)

| Phase | Content | Key lemmas consumed | Est. lines |
|-------|---------|---------------------|-----------|
| 5A | `kvE2_sepAnchorVal` + **keystone** `kvE2_sepAnchor_injOn` + anchor family / rank | `nf_eval_unique`, `Finset.nodup_toList`, `kvE2_ordRank_lt/_injective` | 90-140 |
| 5B | `kvE2_sepHonestOrder` def + `_mem_orderTypes` + `_mem_arr'` | `kvE2_sepOrderTypes_mem_aux`, `kvE2_sepIdxTuple_mem_of_lt`, `kvE2_sepCoincidentOwner_valid_left/right` (verbatim), `kvE2_ordRank_injective` | 160-220 |
| 5C | `kvE2_sepHonestOrder_monotone` (slot merge = value order; `a<u'<b`) | `kvE2_ordRank_strictMono`, keystone, `List.sorted_mergeSort`/`mergeSort_perm` | 150-260 |
| 5D | `kvE2_sepHonestBundle_export` (hpos/hlink/hnd/hreal) | keystone, `kvE2_sepHonestBundleL/R`, `kvE2_ordRank_strictMono` | 150-260 |

340's sorry-free deliverable ends at 5D (the bundle). The `.holds` (incl. any meet-type folding for
a foreign witness forced onto an anchor) is 337's, via `kvE_subBracket2V_sound_of_parts`
(SubBracket2V.lean:1025) → `kvE2_sepBody_holds_iff.mpr` (SW:1122).

---

## H4 — Adversarial self-verification

**Mandate: try to REFUTE (a) the bifurcation's necessity and (b) my own "no-fork" dissolution.**

**Claim Verification Table**

| Claim | Refutation probe | Method | Confidence |
|-------|------------------|--------|------------|
| Distinct owners ⟹ distinct anchors | Try `σ≠τ` with `x1_σ=x1_τ`: forced `σ=τ` by uniqueness | `nf_eval_unique` (NormalForm.lean:245, general `k n`) — read | High |
| Owners are pairwise distinct | `kvE2_sepPos` could carry dups | `Finset.univ.toList.filter` is `Nodup` (SW:195) — read | High |
| Tags are uniformly `.coincident` (no strict-tag branch) | Could `kvE2_sepModelOrder` (strict) be honest instead? | Empirical finding SW:1755-1763 (`lean_goal`-grounded): OPEN bits not forced — read | High |
| Only `i₀` needs `Nodup` (so tuples free elsewhere) | Does validity force `i₁`/`i₂` distinct? | `kvE2_sepDisjValid` third conjunct is `(wo.map ·.2.2.1).Nodup` (SW:917) — read | High |
| Region-primary `kvE2_sepCoincidentOrder` is non-monotone for interleaved anchors | Construct A,B with `x1_A<x1_B`, B's region-0 witness `> x1_A` | value trace on `kvE2_sepSlotGIdx` — inference | High |
| Block layout expresses `a<u'<b` | `i₂(σ)<i₁(τ)` iff `r_σ<r_τ` iff `x1_σ<x1_τ` | arithmetic on `3r±k` + `kvE2_ordRank_strictMono` | High |
| `lX1` anchors are strict bracket points (meet residual is real) | Are anchors boundaries instead? | `kvE2_sepBracketN` (SW:602) + `kvE2_sepSlotType .lX1` (SW:281) — read | High |

**Refutations attempted:**

- **R1 — "a per-pair merge is forced" (attempted, DOES NOT LAND).** Construct a model where owners
  A,B share an anchor and C is distinct, forcing A,B to merge while C stays split. *Refuted:* the
  construction is impossible — `x1_A = x1_B ⟹ A = B` (keystone). No mixed coincidence configuration
  over *distinct* owners exists. The per-pair merge has nothing to merge.

- **R2 — "the clean dichotomy is needed" (attempted, MOOT).** If some anchors coincided and some
  didn't, neither simple layout (block / region-primary) would be monotone → a dichotomy or finer
  merge would be forced. *Moot:* the antecedent ("some anchors coincide") is unsatisfiable. Both the
  dichotomy and the merge are answers to a non-question.

- **R3 — "my dissolution is wrong: foreign-witness coincidence still forks the carrier" (attempted,
  DOES NOT LAND, but narrows the claim).** A foreign base witness forced onto an anchor makes two
  distinct-`gidx` slots share an M-point, breaking the strict bracket. *Does the carrier need to
  change?* No: this is discharged at the *realization* layer (337) by the existing meet-type channel
  (`kvE2_sepCoincidentAnchor_discharge`, SW:1695), which the `coincident` tag + CLOSED bit already
  select. The carrier *layout* (block tuple, coincident tags) is exactly the input that channel
  consumes. So R3 relocates work to 337 (already its territory) but does **not** reopen the carrier
  fork or defeat terminality. It is logged as the one bounded downstream residual, not a gate
  failure.

- **R4 — "block layout `hreal` is unrealizable even with distinct anchors" (attempted, DOES NOT
  LAND).** Consecutive owner bands need room between `x1_{rₖ}` and `x1_{rₖ₊₁}`. *Refuted:* anchors
  are strictly ordered and distinct (keystone), so `(x1_{rₖ}, x1_{rₖ₊₁})` is a nonempty open
  interval; the honest bundles + `k1v_sorted_realizationK`'s per-region interior realization
  (clustering) fill it. This is the same freedom `k1v_sorted_realization3` already uses for `k=3`.

**Contradiction log.** One tension surfaced and was resolved by precedence: **handoff #2 point 3
("two anchors can coincide") vs `nf_eval_unique` + `kvE2_sepPos` Nodup**. Resolution — *primary
source (the proven Lean lemma) outranks a prose handoff assertion*; the handoff mis-cited SW:1585
and conflated anchor-coincidence with foreign-witness-coincidence. **RESOLVED in favour of the
lemma:** no anchor coincidence, no fork. No unresolved contradiction remains.

**Recommendations modified after verification:** (1) do **not** build a two-branch bifurcated
selector; build the single `kvE2_sepHonestOrder`. (2) The lex `(value,index)` family may be kept for
a structural `Injective`, but the *monotonicity/realizability* proofs must route through the
**keystone** (`kvE2_sepAnchor_injOn`), not through the lex tiebreak — the tiebreak is inert for
realizability. (3) Land the keystone (Phase 5A) FIRST; every later phase depends on it.

---

## Memory candidates

1. In this canonical-model construction, distinct positive owners provably have distinct fresh
   anchors: owners are `Finset.univ.toList.filter` (Nodup), each anchor realizes its owner at
   `[x1,w,x,t]` at depth 1, and `nf_eval_unique` (NormalForm.lean:245, general over depth/arity)
   forces equal-anchor ⟹ equal-owner. Kills any "coinciding-anchor" fork at the anchor level.
2. Two *different* coincidences must not be conflated: (a) two owners' **anchors** coinciding —
   impossible (uniqueness); (b) a **foreign depth-0 base witness** landing at an anchor — real,
   handled by the `coincident` tag + CLOSED `zAtX1L` bit (`kvE2_sepCoincidentAnchor_discharge`),
   the Rabinovich §5 `z_k = x_{i_k}` meet (md:151,168-173). Only (b) exists.
3. `kvE2_sepDisjValid` requires `Nodup` on **`i₀` only** (`wo.map ·.2.2.1`), not on `i₁`/`i₂`; and the
   honest-order **tags are uniformly `.coincident`** (SW:1755-1763), so `kvE2_sepCoincidentOwner_valid_*`
   are reusable verbatim across any value-faithful tuple layout — membership is tuple-agnostic;
   the tuple choice is purely a monotonicity/realizability decision.
