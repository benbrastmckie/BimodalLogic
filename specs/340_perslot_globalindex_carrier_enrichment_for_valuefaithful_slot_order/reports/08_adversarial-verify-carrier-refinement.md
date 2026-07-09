# Task 340 — Adversarial Verification (H4) of the Per-Slot Carrier Refinement Proposal

**Task**: 340 — Per-slot global-index carrier enrichment for value-faithful slot order
**Kind**: Independent adversarial verification (H4). Mandate: REFUTE report 07's load-bearing
claims and its 4-6 phase scope estimate before a multi-phase implementation commit. Default to
REFUTED when uncertain. No Lean edited.
**Agent**: lean-research-hard-agent
**Under scrutiny**: `reports/07_rabinovich-faithful-carrier-granularity.md` (proposal),
`reports/06_coinciding-anchor-design-gate.md` (prior "terminal" gate that was overturned).
**Sources verified by direct read**:
`SharedWitness.lean` (SW) §slots (152-322), §kernel (779-848), §validity (887-928),
§gidx/merge (1000-1043), §honest (2020-2350); `SubBracket2V.lean` §engine (445-658);
`337 .orchestrator-handoff.json` (blocker root_cause). `kvE2_ordRank` docstring confirmed via
`lean_hover_info` (SW:783).

---

## BOTTOM LINE: **GO-WITH-CAVEATS**

The *direction* is right and I could not refute it: the owner-block tuple `(3r,3r+1,3r+2)` is
genuinely unfaithful, per-slot granularity is genuinely required (Attacks 2/4/5 survive FOR the
proposal; the 337 handoff + source confirm the defect). **But two load-bearing claims are
overstated and the scope is under-counted:**

1. **Claim A ("halign becomes provable") is too strong.** The engine output is *strict*
   (`Pairwise (· < ·)`, no ties); the lex `(value, j)` tiebreak fixes the carrier RANK's
   *injectivity*, but that is a combinatorial fact — it does **not** manufacture distinct MODEL
   POINTS. The genuine `halign` obligation is an alignment against a strict realized chain, which
   the tiebreak does not by itself discharge. The **foreign-witness-at-anchor coincidence**
   (report 06's own R3, backed by real infrastructure `kvE2_sepCoincidentAnchor_discharge`) is
   left completely unaddressed by the per-slot proposal. **This is the fourth under-shoot risk.**
2. **The 4-6 phase estimate is REFUTED.** Corrected estimate: **7-10 H8 phases** (evidence below).

Not a NO-GO: the kernel (`kvE2_ordRank` + lt/strictMono/injective) and the anchor keystone
genuinely survive verbatim, and the granularity diagnosis is correct. But the proposal must be
amended with two mandatory design elements (§Missing Design) before the implementation commit.

---

## Evidence per attack

### Attack 1 (HIGHEST PRIORITY) — M-value ties and the `interleaveK` tie-break — **PARTIALLY REFUTED (genuine gap found)**

**What the engine actually produces.** `k1v_sorted_realizationK` (SubBracket2V:633-658) returns
`ps` with `(interleaveK ps).Pairwise (· < ·)` — a **strictly increasing** chain (proven via
`k1v_stitch_regions` :492, which threads `Pairwise (· < ·)` across region blocks separated by the
interior anchors `sep = e.2.1`, SubBracket2V:457). Within a region, `k1v_sorted_realization`
value-sorts (`(p.2.2.map Prod.snd).Pairwise (· < ·)`, :575). So the engine's realized order has
**NO M-value ties anywhere in the output** — every point is distinct. The 337 handoff `root_cause`
confirms the consumer: the `.holds` "needs a strictly-monotone `ws` realizing each slot's
`charBase`-χ type at its mergeSort position."

**Why the lex tiebreak does not settle `halign`.** Report 07 (and the SW:773-776 kernel docstring)
justify the `(value, j)` lex order by "distinct owners may share witness values, so value alone is
NOT a strict order; the index tiebreak makes it one." True — but that gives the *rank* injectivity
(`kvE2_ordRank_injective`, SW:825, verified general). It does **not** give the engine two distinct
POINTS for two tied slots. When two distinct slots genuinely share an M-value, the engine's strict
chain has **one** point where the carrier's `kvE2_sepSlotsLOf` (SW:1034) lists **two** slots — the
two lists differ in length, so their equality (`halign`) is **false**. The tiebreak is provably
*inert* for realizability — report 06 itself said exactly this (SW:92-98: "the tiebreak is inert
for realizability... route through the keystone, not the lex tiebreak"). Report 07 re-imports the
tiebreak as if it resolved the realizability alignment; it does not.

**The concrete tie mode that survives.** Anchors are injective (keystone `kvE2_sepAnchor_injOn`,
SW:2042 — verified), so two *anchors* never tie. But a **foreign depth-0 base witness** χ (an
`lXU`/`lUW`/`rWX1`/`rX1T` slot, each carrying a `NormalForm sig 0 1` type, SW:220-227) realizable
in `(x1_σ, w)` can be realizable **only at a point equal to some other owner's anchor** `x1_τ`
(depth-0 and depth-1 realizations are independent, so no uniqueness excludes it). Report 06's R3
flags this as REAL and hands it to 337's meet-type channel (`kvE2_sepCoincidentAnchor_discharge`,
whose very existence proves the codebase treats this coincidence as reachable). In that case χ has
no distinct interior point; the strict engine chain cannot host it as its own bracket point.

**What "value_j" even is.** For an anchor slot `lX1 σ`, `value = x1_σ = kvE2_sepAnchorVal`
(well-defined, SW:2020). For a base-witness slot, the type χ has **no canonical M-value** — the
honest bundle (`kvE2_sepHonestAnchorBundleL/R`, SW:2290/2329) only gives `∃ u, ... ∧ nf_eval χ at
u` (a Classical.choose point). So report 07's `G j = (value_j, j)` is **underspecified for base
slots**: `value_j` must be bound to a realization point. The only assignment that makes `halign`
hold is `value_j := the engine's realized point for slot j` — which forces the honest order to be
**defined from the engine output** (a data-flow inversion), not a self-contained enum member. If
instead `value_j` is any *other* canonical value, two base witnesses can share `value_j` while the
engine realizes them at distinct points in an order **unrelated to slot index j** → `halign` fails.

**Net.** In the coincidence-free case, with `value_j` bound to engine points, ties cannot occur
(engine points distinct), the tiebreak is vacuous, and `halign` reduces to "value-rank order =
value order" — provable. So Claim A is **not universally false**. But as *stated* (blanket "halign
becomes provable, tiebreak resolves shared values") it is **refuted**: it conflates rank
injectivity with realized-point alignment, omits the value_j→engine-point binding (data-flow
inversion), and does not handle the foreign-witness-at-anchor coincidence. **Gap confirmed at the
same seam.**

### Attack 2 — Region-order vs value-order conflict — **SURVIVES (proposal is sound on this axis)**

The honest bundles pin realization intervals: `kvE2_sepHonestAnchorBundleL` (SW:2296-2302) gives,
for a LEFT owner σ, every `zXU` base type a witness `u ∈ (x, x1_σ)` and every `zUW` base type a
witness `u ∈ (x1_σ, w)`; `kvE2_sepHonestAnchorBundleR` mirrors it. So **within an owner**, M-value
order already respects region order: `lXU` values `< x1_σ < lUW` values. Consequently a per-slot
value rank **automatically** satisfies the per-owner consistency conjunct (the `i₀<i₁<i₂`
generalization of `kvE2_sepConsistentTuple`, SW:902) and **is** a linear extension of each owner's
region partial order. Cross-owner interleaving is unconstrained by design (that is the whole point
of per-slot). I found **no** model in which an honest `lUW` value violates its own owner's region
order. The scenario the attack proposed — "an lUW slot with smaller M-value than one of that
owner's lXU slots" — cannot arise because the two live in disjoint intervals `(x1_σ,w)` vs
`(x,x1_σ)`. Attack 2 does **not** refute the proposal.

### Attack 3 — Type-change blast radius / scope — **REFUTES the 4-6 estimate**

**Containment holds** (one point in the proposal's favour): `KvE2SepWeakOrder` (SW:701) is
referenced **only** in `SharedWitness.lean` (`grep -rl` across the whole `NfMultiAnchorBridge`
directory returns only SW). `SubBracket2V.lean` and the other 9 files never touch the tuple.

**But within SW the payload `(ℕ × ℕ × ℕ)` is load-bearing far beyond the honest layer:**

| Consumer | Refs | Depends on 3-tuple shape? | Must rebuild? |
|---|---|---|---|
| `KvE2SepWeakOrder` type (SW:701) + distinguishability `example` (715) | — | yes | yes |
| `kvE2_sepConsistentTuple` (validity conjunct ii, SW:902) | 8 | **yes** (`t.1<t.2.1<t.2.2`) | yes |
| `kvE2_sepDisjValid` Nodup (conjunct iii, `p.2.2.1`, SW:917) | — | **yes** | yes |
| `kvE2_sepIdxTuples` (`[0,3n)³` enum, SW:734) + `_mem_of_lt` richness (757) | 11 | **yes** (`3*n` bound) | yes |
| `kvE2_sepPlaceholderTuple` (SW:728) | 16 | yes | yes/retire |
| `kvE2_sepModelOrder` (**soundness side**, SW:859) + `_mem` proofs | — | yes | yes |
| `kvE2_sepCoincidentOrder` + `_mem_arr'` (SW:1927, 1966) | 18 | yes (destructures tuple) | yes |
| `kvE2_sepSlotGIdx` (SW:1006) + `kvE2_sepSlotMergeLe` | 6/8 | yes | yes |
| `kvE2_sepHonestTuple`/`Order` + 3 mem proofs + `same_owner_mono`/`cross_region` | 18 | yes | yes |

Report 06's memory-candidate #3 ("membership is tuple-agnostic") is **only true for conjunct (i)**
(the tag validator `kvE2_sepDisjValidOwner`, SW:890, reads the tag not the tuple). Conjuncts (ii)
consistency and (iii) Nodup are tuple-shaped and change. Crucially, the type change touches the
**soundness-side** `kvE2_sepModelOrder`/`kvE2_sepCoincidentOrder` membership proofs, not just the
completeness-side honest order — so **three** membership theorems must be re-proved against a new
enumeration, plus validity, plus the richness lemma, plus the halign proof, plus the coincidence
re-integration. Report 07's "only the index layer + one halign proof / 4-6 phases" **under-counts**
by treating the coincident-order channel and soundness-side model-order as reused verbatim, when
both destructure the tuple and assert the `i₀<i₁<i₂` / `[0,3n)³` shape that per-slot changes.
**Corrected estimate: 7-10 phases** (see §Corrected scope).

### Attack 4 — Decidability / enumeration finiteness — **SURVIVES (no decidability loss), but confirms non-trivial enum rebuild**

Per-slot count is **bounded**: `kvE2_sepS σ z = Finset.univ.toList.filter …` (SW:178) has length
`≤ |NormalForm sig 0 1|`, a `Fintype` — finite and model-independent as a *bound*. So the total
slot count `N` is finite, and a per-slot index payload `List ℕ` (or `List (KvE2SepSlot × ℕ)`) has
`DecidableEq`, so `kvE2_sepArr'_decidable` (SW:927, `inferInstanceAs Decidable …`) is preserved.
**Decidability is NOT lost.** However: (a) the `kvE2_sepIdxTuples` bound `3*n` (SW:734-737) is
wrong for per-slot and must become `N`; (b) the enumeration must range over per-slot assignments
(a genuinely new finiteness + `_mem_of_lt`-style richness lemma), and its cardinality blows up from
polynomial `(3n)³`/owner to a per-slot assignment space. Attack 4 does not refute the proposal, but
the enum rebuild is real work feeding the Attack-3 under-count (it is not a trivial re-arity).

### Attack 5 — Does the kernel docstring genuinely specify `(value, j)` lex? — **SURVIVES (genuine internal evidence)**

`lean_hover_info` on `kvE2_ordRank` (SW:783, col 5) returns the attached docstring verbatim:
*"The honest order uses `g = (model value, slot index)` in the lex order."* with signature
`{β : Type u_1} [LinearOrder β] {n : ℕ} (g : Fin n → β) (i : Fin n) : ℕ`. This is genuine
internal evidence on the actual declaration (not a post-hoc reading), and the kernel is fully
general as report 07 claims — it re-instantiates at the slot family with no code change. The
kernel + `kvE2_ordRank_lt/_strictMono/_injective` (SW:788-832) and the anchor keystone
(`kvE2_sepAnchor_injOn`, SW:2042) genuinely survive verbatim.

---

## Missing design elements (the proposal must add these BEFORE committing)

1. **`value_j` binding + data-flow direction.** The proposal must specify that a base slot's rank
   key is the **engine-realized point** (or prove the honest Classical-chosen bundle points can be
   threaded consistently into BOTH the carrier index and the engine `regions`). This is a
   data-flow inversion (honest order partly defined from engine output), NOT a local index-layer
   arity change. **Bounded but larger than claimed** (+~2 phases: a value-assignment lemma and a
   "carrier index = value rank of realized points" bridge).

2. **Per-slot meet-type fold for the foreign-witness-at-anchor coincidence.** When a base slot's
   only realization is an anchor value, the strict engine chain has no distinct point for it;
   `kvE2_sepSlotsLOf` must then **drop/fold** that slot (via the `coincident` tag /
   `kvE2_sepCoincidentAnchor_discharge` channel, SW ~1695-region) to keep `halign`'s two lists the
   same length. Report 06 punted this to 337 as a coarse tag-level residual; under the *fine*
   per-slot merge, folding one slot is now slot-order surgery, and it reopens whether
   `kvE2_sepSlotsLFor` (a fixed function of σ, SW:292) can stay model-independent — or whether the
   realized slot list must become model-dependent (variable length). **This is the load-bearing
   risk of a fourth under-shoot.** It must be designed explicitly; if it forces a model-dependent
   slot list, the "bounded refinement" framing weakens toward a partial carrier rebuild.

---

## Corrected scope estimate

| Phase | Content | New vs report-07 |
|---|---|---|
| A | Carrier payload type change + per-slot enumeration + `_mem_of_lt` richness (new `N` bound) | rebuild |
| B | `kvE2_sepConsistentTuple`/`kvE2_sepDisjValid` (ii)+(iii) generalized to per-slot region-monotone + global Nodup | rebuild |
| C | `kvE2_sepSlotGIdx` per-slot read + `kvE2_sepSlotMergeLe` | rebuild |
| D | **Soundness-side** `kvE2_sepModelOrder` + `kvE2_sepCoincidentOrder` membership re-proofs | **omitted by 07** |
| E | `value_j` = realized-point binding lemma + honest per-slot order via `kvE2_ordRank` over slot family | **partly omitted by 07** |
| F | `kvE2_sepHonestOrder_mem_arr'` re-proof (per-slot Nodup via `kvE2_ordRank_injective`) | rebuild |
| G | `halignL/R` (mergeSort-by-gidx = engine value order), coincidence-free case | the "one new proof" |
| H | **Per-slot meet-type fold** for foreign-witness-at-anchor coincidence | **omitted by 07 — risk** |
| I | `regionsL/R` assembly + `hbdry` endpoint alignment (may be 337's, depends on carrier) | 07 defers |
| (J) | 337 Phase-1 destructure re-thread | optional |

**Realistic: 7-10 H8 phases** (vs report 07's 4-6). The delta is Phases D (soundness re-proofs),
E (value binding), and H (coincidence fold) — none of which report 07 costs in.

---

## Per-attack verdict table

| # | Attack | Verdict | Evidence |
|---|--------|---------|----------|
| 1 | M-value ties / `interleaveK` tie-break match | **PARTIALLY REFUTED — gap found** | engine `Pairwise (· < ·)` strict (SubBracket2V:646); lex tiebreak gives rank-injectivity not distinct points; foreign-witness-at-anchor (06 R3, `kvE2_sepCoincidentAnchor_discharge`) unaddressed; `value_j` for base slots underspecified |
| 2 | Region-order vs value-order conflict | **SURVIVES (proposal sound)** | honest bundles pin `lXU∈(x,x1_σ)`, `lUW∈(x1_σ,w)` (SW:2296-2302) ⇒ value rank is a per-owner linear extension |
| 3 | Type-change blast radius / 4-6 phases | **REFUTES the estimate** | tuple load-bearing in validity (ii)+(iii), enum, soundness `kvE2_sepModelOrder`, coincident-order (18 refs); 3 membership re-proofs; corrected 7-10 |
| 4 | Decidability / enumeration finiteness | **SURVIVES (no loss), enum rebuild real** | `kvE2_sepS` bounded by `Fintype`; `List ℕ` has `DecidableEq`; `3*n` bound wrong → `N`, new richness lemma |
| 5 | Kernel docstring `(value, j)` lex genuine? | **SURVIVES** | `lean_hover_info` SW:783 confirms docstring on actual decl; kernel fully general |

## Missing design element (summary)

- **(a)** A `value_j`→realized-point binding (data-flow inversion) — bounded, +~2 phases.
- **(b)** A per-slot meet-type fold for the foreign-witness-at-anchor coincidence — **the fourth
  under-shoot risk**; may reopen model-independence of the slot list. Must be designed before commit.

## Corrected phase estimate: **7-10 H8 phases** (report 07's 4-6 is refuted).

## VERDICT: **GO-WITH-CAVEATS**

Proceed with the per-slot refinement — the diagnosis is correct and the kernel/keystone survive —
**but only after** the plan (i) explicitly designs the `value_j`→engine-point binding and its
data-flow direction, (ii) explicitly designs the per-slot coincidence fold (or proves the
coincidence is gate-excluded), (iii) budgets the soundness-side membership re-proofs, and (iv)
re-sizes to 7-10 phases. Committing to a 4-6 phase "index-layer-only" plan risks a fourth
under-shoot at the same seam via the unhandled foreign-witness-at-anchor coincidence.
