# Task 334 Handoff 04 — Faithfulness / Divergence Audit (H5 + H3)

- **Session**: lean-research-hard-agent (H2+H3+H4+H5), read-only audit. No `Theories/` edits.
- **Question adjudicated**: Is task 334's blocker (the unconditional single-point inequality
  `p ≠ x1_σ`) a **genuine mathematical obstruction**, or an **artifact** of a Lean construction
  that drifted from Rabinovich's actual technique?
- **Primary source**: Rabinovich 2014, *A Proof of Kamp's Theorem*
  (`Literature/sources/rabinovich_2014/…md`), read in full. Def 3.1 (md:61-74),
  Lemma 3.2 (md:76-79), §5 (md:119-173, 213-219).

---

## 1. VERDICT

**SELF-INFLICTED ARTIFACT.** The blocker dissolves under the faithful construction. The
unconditional inequality `p ≠ x1_σ` is demanded ONLY by representing the multi-owner conjunction
as a **single `mergeSort` keyed on one point per slot** (`fun a b => pt a ≤ pt b`), which forces a
total order over a witness multiset that Rabinovich **never totally-orders**. The paper combines
conjuncts (owners) by **Lemma 3.2(1) disjunction over interval-decomposition refinements**, where
a coincidence of two owners' witnesses is a *separate disjunct that identifies the points* (a
shared anchor carrying the conjoined type), not a tie to be refuted by an inequality.

**Honest caveat (why not "trivial patch"):** the faithful construction IS the ROADMAP's Option B
(interval-typed rebuild, ~700-1050 lines). So this audit does not hand back a one-line fix — it
**re-grounds Option B as the faithful transcription of Def 3.1 + Lemma 3.2(1)**, not a speculative
"fifth carrier gamble." That reframing is the actionable result: the escalation is no longer
"single-point carrier #5 vs. architecture gamble" (Rec-1) — it is "the single-point joint sort was
the *divergence*; the paper's region-partitioned disjunction is the *correct* construction, and it
directly reuses the already-proven `k1v_sorted_realization` region induction."

**Confidence: HIGH** (paper read in full; both faithful Lean anchors — `k1v_sorted_realization`,
`k1v_sorted_realization3` — read at source, not by name; the extractor's strict-open channels
read at SubBracket2.lean:614-624).

---

## 2. The paper's actual witness-ordering & tie-handling technique

### 2a. Ordering is a region-partitioned interval decomposition, not a point sort (Def 3.1, md:61-74)

An exists-forall formula picks points `x_0 < x_1 < … < x_n` **strictly increasing by
definitional constraint** (md:65-70), with types `α_j` **AT** each point and types `β_j` **ALONG**
each open interval `(x_{j-1}, x_j)`, plus `β_0` before `x_0` and `β_{n+1}` after `x_n`
(md:66-74). The points **partition** the chain into typed intervals (md:74, "interval
decomposition"). Strictness is NOT derived from any distinctness lemma — it is *definitional*, and
it is *unbreakable* because the α-points are fixed boundaries and every interval witness is
**strictly interior** to an open `(x_{j-1}, x_j)`.

### 2b. Multiple owners combine by DISJUNCTION, never by a joint sort (Lemma 3.2(1), md:77)

> "Conjunction of exists-forall formulas is equivalent to a **disjunction** of exists-forall
> formulas."

This is the load-bearing citation. A conjunction of two owners' decompositions is rewritten as a
**finite disjunction**, one disjunct per relative order-type of the merged points. There is **no
"joint multi-owner sort" in the paper at all** (answering the task's question 3): the joint flat
witness list is a Lean-representation construct with no paper analogue.

### 2c. Coincidence of two owners' witnesses = a specific disjunct that IDENTIFIES the points

When a point of owner A coincides with a point of owner B, the paper does not order them — that
order-type disjunct treats them as **one shared point `x_j` carrying the conjunction (meet)
`α_A ∧ α_B`** (this is the §5 "which `i` the new point corresponds to" case analysis, md:168-173,
213-219: inserting a point case-splits on which existential witness it *coincides with* or sits
between). Distinct disjuncts place them in strict order with the appropriate `β` interval between.
Within each disjunct strict increase holds **by construction** — identified points are one point,
so no tie ever arises.

### 2d. Where does distinctness come from in the paper? (task question 2)

It does **not** come from a distinctness assumption on the model. Def 3.1's strict order is
definitional (chosen points); coincidences are *absorbed into the disjunction* (2c). The **only**
use of Dedekind completeness (md:146, 221-222) is the `INF` formula defining `r_0 = inf{z | P_1(z)}`
— a witness-*existence* mechanism, **not** a point-distinctness or general-position assumption. So
the model is **never** asked to keep two owners' arbitrary-type witnesses apart. This directly
refutes "the paper needs point-distinctness the model must supply": it needs none.

---

## 3. Divergence table (H3 — centred on witness-ordering / tie-handling)

| Paper construct (Def/Lemma/§ + line) | What the paper actually does | What the Lean construction does (site) | FAITHFUL / DIVERGENT | If divergent: the faithful alternative |
|---|---|---|---|---|
| **Def 3.1** interval decomposition (md:61-74) | Fixed α-points partition the chain; interval witnesses **strictly interior** to open `(x_{j-1},x_j)` | `k1v_sorted_realization3` partitions into per-region lists `S_XU/S_UW/S_WT`, each strictly inside `(x,x1)/(x1,w)/(w,t)`, stitched around FIXED anchors `x1,w` (SubBracket2V:379-402) | **FAITHFUL** | — (this is the reference implementation of the pattern) |
| **Def 3.1** strict order source (md:65-70, definitional) | Strictness is definitional; interior points cannot hit an anchor | Single-owner: distinctness from `Nodup` + `nf_eval_unique` (NormalForm:245) per region; anchor-coincidence impossible by strict interior (CarrierK1V:1447-1478) | **FAITHFUL** | — |
| **Lemma 3.2(1)** conjunction ≡ **disjunction** (md:77) | Multi-owner combined as a finite disjunction over merge order-types; each disjunct a single region-partitioned decomposition | `kvE2_sepSlotsL := (kvE2_sepPos qnf).flatMap kvE2_sepSlotsLFor` — **flattens ALL owners into ONE list** (SharedWitness:315-317) | **DIVERGENT** (core) | Disjoin over the finite anchor order-types; per disjunct, re-use the region partition of `k1v_sorted_realization3` over the **merged** anchor set |
| **Lemma 3.2(1)** ordering of the merged list | No total order; order-type is a *disjunct choice*, coincidences identified | Retired `kvE2_sepJointSortedL/R` used `List.mergeSort (fun a b => pt a ≤ pt b)` — a **single total point order** (SharedWitness:893,900 note the retirement) | **DIVERGENT** (root cause) | Anchors are fixed boundaries; never sort foreign witnesses against a private anchor `x1_σ` |
| **§5 coincidence handling** (md:168-173, 213-219) | Coinciding witnesses → shared point carrying **meet type** (α at the anchor / closed channel) | `kvE_subBracket2_complete_extract` has **only strict-open zone channels** `zXU/zUW/zWT` (SubBracket2:614-624; `x<v<x1`, `x1<v<w`, …). **No point-coincidence (closed) channel.** | **DIVERGENT** | Add a point-type channel: at coincidence `v = x1_σ`, discharge by "`x1_σ` realizes `χ`" (TRUE — see §4) |
| Tie-refutation obligation | Paper has **none** — no inequality between two owners' witnesses ever asserted | `kvE2_sepFreshAnchor_ne_baseChiPoint` demands unconditional `p ≠ x1_σ` (SharedWitness ~:1133, reduced form) to feed the strict-open channel | **DIVERGENT (the blocker itself)** | Obligation deleted; replaced by a **case split** (coincident → point channel; distinct → open channel), both dischargeable |

---

## 4. If artifact: the concrete faithful construction to build (Option B, re-scoped)

**Shape.** Replace the single joint `mergeSort` over `kvE2_sepSlotsL/R` with a **disjunction over
the finite set of relative order-types of the merged anchor set** `{ x1_σ : σ ∈ kvE2_sepPos } ∪ {w}`.
Within each disjunct:

1. The merged anchors are FIXED boundaries partitioning `(x, t)` into open regions — exactly the
   `k1v_sorted_realization3` pattern (SubBracket2V:379), but with `k` anchors instead of `{x1, w}`.
2. Each region gets a per-region **Nodup** type list realized strictly interior, fed to the
   already-proven insertion induction **`k1v_sorted_realization`** (CarrierK1V:1447). Distinctness
   is per-region-per-owner (type-driven via `nf_eval_unique`), which IS available — the joint
   version's error was demanding it *across* owners *at an anchor*.
3. **Coincidence disjunct** (`x1_σ = x1_τ`, or a foreign χ-witness at `x1_σ`): the anchor is a
   shared point carrying the meet type. Discharge via a NEW **point-type channel** on the
   extractor: at `v = x1_σ`, prove `nf_eval_nf M 0 1 (fun _ => x1_σ) χ`. This is **provable**, and
   the very fact handoff 03 cited as making the coincidence *unpreventable* is what makes it
   *dischargeable*: `charK = P.existF 0` is existential (NavigatedSpine:411), so `x1_σ` genuinely
   realizes BOTH σ's depth-1 fresh type AND the foreign depth-0 base χ at that point. The bug
   becomes the discharge witness.

**Which Lean sites change:**
- **New** (largest): a multi-anchor lift of `k1v_sorted_realization3` — `k`-region partition +
  disjunction over anchor order-types. Reuses `k1v_sorted_realization` verbatim per region.
- **Extend**: `kvE_subBracket2_complete_extract` (SubBracket2:606) — add a closed/point-type
  channel alongside the three strict-open zone channels (lines 619-624).
- **Retire/replace**: `kvE2_sepSlotsL/R` flatMap-to-single-sort (SharedWitness:315-322) and the
  retired `kvE2_sepJointSortedL/R` mergeSort site.
- **Reuse unchanged (preserved assets):** `kvE2_sepCompat`/`kvE2_sepCompat_lX1_eq`
  (SharedWitness:385,409 — the cross-σ fold-bit predicate, still correct per disjunct);
  `kvE2_sepFreshAnchor_ne_baseChiPoint` in its **reduced** form (`χ ≠ nf0_projFresh σ.1 → p ≠ x1_σ`)
  — the interval typing supplies the base-type inequality by construction for the non-coincident
  disjuncts; Task 333's compat leaves and `kvE2_sepHonestBundleL`.

**Rough size:** consistent with Option B's `~700-1050 lines` (specs/305 report 37 §4.4). The
per-region engine already exists, so the net-new is the multi-anchor partition + order-type
disjunction + the point-type channel.

**Does it reuse `k1v_sorted_realization3`'s approach?** Yes — directly. Option B is not a
green-field rebuild; it is the generalization of the *already-faithful* three-region construction
from a single owner's `{x1, w}` anchors to the merged multi-owner anchor set, wrapped in the
Lemma 3.2(1) disjunction that the single-point carrier omitted.

---

## 5. Adversarial self-verification (H4) — what the pass changed

Applied the Claim Verification Bar to every load-bearing claim; challenged the verdict in BOTH
directions.

| Claim | Source / counterexample tested | Verification method | Confidence |
|---|---|---|---|
| Paper orders witnesses by definitional strict interval decomposition, not a derived point sort | Def 3.1 md:65-74 | Paper read in full | High |
| Multi-owner conjunction handled by disjunction, not a joint sort | Lemma 3.2(1) md:77; §5 md:168-173 | Paper read in full | High |
| Paper needs NO model point-distinctness; only completeness for `INF` | md:146, 221-222 | Paper read in full | High |
| `k1v_sorted_realization3` is faithful (region partition, strict interior, no anchor-tie) | SubBracket2V:379-402 | Source read (not name) | High |
| Single-owner distinctness is type-driven (`Nodup`+`nf_eval_unique`), unavailable across owners | CarrierK1V:1462-1469; NormalForm:245 | Source read | High |
| `kvE2_sepSlotsL` flattens all owners into one list (no paper analogue) | SharedWitness:315-317 | Source read | High |
| Extractor channels are strict-open only; no closed/point channel | SubBracket2:614-624 | Source read (`x<v<x1` etc.) | High |
| Coincidence disjunct is DISCHARGEABLE (not a relocated false inequality) | `charK` existential, NavigatedSpine:411 (via handoff 03) | Code-cited; logically derived | Medium-High |

**Adversarial challenge 1 — "does the faithful alternative REALLY avoid the obligation, or just
relocate it?"** Pushed hard on the `v = x1_σ` case. It is genuinely avoided, not relocated: the
obligation `p ≠ x1_σ` is *deleted* and replaced by a **case split**. The `p = x1_σ` branch does
not need any inequality — it needs `x1_σ` to realize `χ`, which is TRUE (existential `charK`; the
point provably realizes both types). So the pass **strengthened** the verdict: the exact fact that
made the blocker "unpreventable" (a point can realize both a fresh depth-1 and a base depth-0 type)
is what discharges the coincidence disjunct. This inversion was the main thing the adversarial pass
produced.

**Adversarial challenge 2 — "could the paper's technique, faithfully transcribed, ALSO need some
distinctness (making the blocker real)?"** Checked every distinctness-adjacent step: Def 3.1 strict
order (definitional, not model-imposed), §5 insertion (case-splits on coincidence rather than
excluding it), the sole Dedekind-completeness use (existence, not distinctness). No transcription
of the paper needs an unconditional cross-owner point inequality. So the "GENUINE OBSTRUCTION"
branch is refuted with paper evidence.

**Adversarial challenge 3 — "am I contradicting handoff 03?"** Not on mechanism — on framing.
Handoff 03's *code* facts are all correct (strict channels; existential `charK`; coincidence
possible; no discriminator lemma). Its verdict "the single-point joint sort is genuinely invalid"
is TRUE **and is precisely the point**: the single-point sort is invalid *because it is the
divergence*. Handoff 03's Option D ("non-mergeSort arrangement = architecture pivot") and this
audit's faithful construction are the **same** target; the audit supplies the missing paper
grounding that recasts it from "pivot/gamble" to "faithful Def-3.1 construction that reuses the
proven region engine." Contradiction resolved by precedence (paper as ground truth over the
Lean-internal "no fifth carrier" heuristic).

**What would raise confidence to maximal:** (a) a Lean spike proving the point-type channel on
`kvE_subBracket2_complete_extract` at `v = x1_σ` closes (turns Medium-High → High); (b) confirming
the anchor-order-type disjunction is already carried by the `VVecEA2` disjunction (rule N5) so the
selected disjunct always names an existing branch (SubBracket2V:377 suggests it is). Neither is
required to act on the verdict.

---

## 6. Bottom line for plan revision

The blocker is an **artifact of the single-point joint mergeSort**, which has **no analogue in
Rabinovich** — the paper combines owners by Lemma 3.2(1) disjunction over interval-decomposition
refinements and never totally-orders the merged witness set. **Proceed with Option B**, but
re-scoped as *the faithful construction*: a multi-anchor lift of the already-proven
`k1v_sorted_realization3` region partition, disjoined over anchor order-types, plus a point-type
channel discharging coincidences. This is not a fifth speculative carrier — it is the first
faithful transcription of the paper's conjunction handling.
