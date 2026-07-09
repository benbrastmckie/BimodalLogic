# Report 07 — hLR Inconsistency Root Cause and Coincidence-Merge Adjudication (Rabinovich-grounded)

**Task**: 337 (Phase 3 blocker research, cycle 12)
**Session**: sess_1783610916_b79fd5
**Reference grounding tier**: 1 (literature — Rabinovich 2014, *A Proof of Kamp's Theorem*, LMCS 10(1:14), read verbatim from the PDF, pages 4–16; the markdown chunk was consulted but the PDF is the citation authority)
**Mandate**: research only; no edits to `SharedWitness.lean`. The machine-checked certificate `kvE2_sepHonest_hLR_absurd` (SW:4618) is taken as ground truth and not re-litigated.

Line references: `SW:` = `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean`, `EA:` = `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ExistsForallNF.lean`, `NS:` = `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/NavigatedSpine.lean`. Page numbers are PDF pages of Rabinovich 2014.

---

## 1. Rabinovich grounding

### 1.1 The verbatim source constructs

**Definition 3.1 (p. 4), the ∃∀-formula.** Quoted (notation lightly ASCII-ized):

> ψ(z_0, …, z_m) := ∃x_n … ∃x_1 ∃x_0
>   (⋀_{k=0}^m z_k = x_{i_k}) ∧ (x_n > x_{n−1} > ⋯ > x_1 > x_0)  "ordering of x_i and z_j"
>   ∧ ⋀_{j=0}^n α_j(x_j)  "Each α_j holds at x_j"
>   ∧ ⋀_{j=1}^n (∀y)_{>x_{j−1}}^{<x_j} β_j(y)  "Each β_j holds along (x_{j−1}, x_j)"
>   ∧ (∀y)_{>x_n} β_{n+1}(y) ∧ (∀y)^{<x_0} β_0(y)

Two load-bearing features:
1. **The witness chain is STRICT** (`x_n > … > x_0`). There is no non-strict variant anywhere in the paper.
2. **Every free variable is PINNED to a witness point** (`z_k = x_{i_k}`), so the type asserted at a reference point is the point type `α_{i_k}` of the chain slot it is pinned to. Types "at an anchor" are carried **at the anchor's own chain position**, never by a separate interior witness.

**Lemma 3.2(1) (p. 4)**: "Conjunction of ∃∀-formulas is equivalent to a disjunction of ∃∀-formulas." The paper offers this as immediate ("It is clear that"). The only mechanism available under Definition 3.1 is: enumerate all order types of the combined witness sets — **including the equality cases** — and in each disjunct where two witnesses coincide, they become ONE chain slot whose point type is the **conjunction** of the two point types (α ∧ α′), with interval types conjoined on overlapping segments. The equality cases cannot be dropped: a model in which the two conjuncts are realized only with coinciding witnesses satisfies the conjunction but no all-strict interleaving disjunct.

**Section 5 opening decomposition (p. 7)**. The ∃∀-formula ψ(z_0, z_1) with pinnings `z_0 = x_m`, `z_1 = x_k` is split (case k ≠ m, w.l.o.g. m < k) into a conjunction of exactly three parts, quoted in structure:
1. **ψ_0(z_0)**: the witnesses `x_0 < ⋯ < x_m` at and below `z_0` (with `z_0 = x_m`) — a **one-free-variable** ∃∀-formula;
2. **ψ_1(z_1)**: the witnesses `x_k < ⋯ < x_n` at and above `z_1` (with `z_1 = x_k`) — a one-free-variable ∃∀-formula;
3. **φ(z_0, z_1)**: `∃x_m…∃x_k [(z_0 = x_m < x_{m+1} < ⋯ < x_k = z_1) ∧ ⋀ α_j(x_j) ∧ ⋀ (∀y)_{>x_{j−1}}^{<x_j} β_j(y)]` — only the **strictly interior** witnesses plus the two pinned endpoints.

Then, verbatim (p. 7):

> "The first two formulas are ∃∀-formulas with one free variable. Therefore, (by Proposition 3.5) they are equivalent to TL(Until, Since) formulas (in the signature E[Σ]). Hence, their negations are equivalent (over the canonical expansions) to atomic (and hence to ∃∀) formulas."

This is the decisive sentence for the root-cause question: **everything not strictly interior to (z_0, z_1) is packaged into one-free-variable formulas that become ATOMIC literals in the canonical expansion, evaluated at the endpoints.** Only φ — the strictly-interior bracket — enters the interval/interleaving analysis (Lemma 5.1). The source never restricts what types may be realized; it routes non-interior content to a different syntactic channel.

**The coincident-reference-point case (p. 7, case k = m)**: "If k = m, then ψ is equivalent to z_0 = z_1 ∧ ψ′(z_0) …" — coincidence of reference points is handled by an explicit **formula-level case split** (the negation is `z_0 < z_1 ∨ z_1 < z_0 ∨ ∃x_0[z_0 = x_0 ∧ z_1 = x_0 ∧ ¬A′(x_0)]`). Coincidence is a disjunct of the order-type enumeration, not a relaxation of chain strictness.

**Notation 5.2 (p. 8)** and formula (5.1) (p. 7): `[α_0, β_1, …, β_n, α_n](z_0, z_1)` abbreviates the strictly-interior bracket with `z_0 = x_0 < x_1 < ⋯ < x_n = z_1` — endpoints pinned, interior strict.

**Notation 7.9 (p. 14)**: `[α_0, β_1 …, α_{n−1}, β_n, α_n, β_{n+1}](z_0, ∞)` with `∃x_n…∃x_1∃x_0 z_0 = x_0 ∧ (x_n > ⋯ > x_0) ∧ …` — again endpoint type α_0 asserted AT the reference point, interior strict.

**Definition 7.13 (p. 15), verbatim**:

> "Let (z_0, z_1, …, z_k) be a sequence of distinct variables. A formula is (z_0, z_1, …, z_k, ∞)-∃∀ formula if it is a conjunction ⋀_{i≤k} φ_i, where φ_k is (z_k, ∞)-∃∀ formula and φ_i is (z_i, z_{i+1})-∃∀ formulas for i < k. A formula is a (z_0, z_1, …, z_k, ∞)-∨∃∀ formula if it is equivalent to a disjunction of (z_0, z_1, …, z_k, ∞)-∃∀ formulas."

**Definition 7.13 contains no union, meet, or merge of types.** It is the segment-wise conjunction of per-interval bracket formulas between DISTINCT reference points. Its role (Lemma 7.14, p. 15) is to decompose a multi-reference-point formula into independent per-segment brackets — it is the source license for the outer `x < w < t` two-segment architecture of `kvE2_sepBody` (endpoints at x, t; pivot at w; one bracket per segment side), NOT for coincidence merging. The blocker report's phrase "Rabinovich Def 7.13 union" is a **misattribution** (adjudicated in §3 and the Contradiction Log).

### 1.2 Lemma-level mapping table (H3 Tier 1, 5-column)

| Source construct | Source location | Lean counterpart | SW line | Faithful? |
|---|---|---|---|---|
| Strict witness chain `x_n > ⋯ > x_0` | Def 3.1, p. 4 | `IntervalPattern.holds` strict-monotone witness family | EA:106-132 | **Y** — strictness is source-mandated, not a Lean artifact |
| Free-variable pinning `z_k = x_{i_k}` (types carried AT reference points) | Def 3.1 p. 4; Notation 7.9 p. 14 (`z_0 = x_0`) | endpoint/pivot literals `kvE2_sepEpL`/`kvE2_sepEpR`/`kvE2_sepPtW` carrying `kvE2_sepHasPos` bits for `zPastX3`/`zAtX3` (EpL), `zAtW3` (PtW), `zAtT3`/`zFutT3` (EpR) | SW:886-903, 908-925, 932-946 | **Y** as a channel; **partial** as used — the completeness layer bypasses it with `hLR` instead of routing boundary-class owners through it |
| §5 three-way split: non-interior witnesses → one-free-variable formulas → ATOMIC E[Σ] literals at endpoints | §5 p. 7 (ψ_0/ψ_1/φ + the "atomic" sentence); Prop 3.5 p. 5 | non-interior owners contribute NO slots (`kvE2_sepSlotsLFor`/`RFor` return `[]` off the two interior classes) and NO segments (`kvE2_sepSegLForSub`/`R` return `Formula.top`); their content rides the `kvE2_sepLit` biconditional literals | SW:292-311, 959-980, 173 | **Y** — the syntax layer already implements the source split exactly |
| Bracket `[α_0, β_1, …, α_n](z_0, z_1)` | (5.1) p. 7; Notation 5.2 p. 8 | `kvE2_sepBracketN` / `kvE2_sepDisjunct` (points `lL ++ ptW :: lR`, per-index segments) | SW:1009-1031 | **Y** |
| Multi-reference-point segment-wise conjunction | **Def 7.13 p. 15**; Lemma 7.14 p. 15 | outer `x < w < t` architecture of `kvE2_sepBody` (EpL at x, PtW at w, EpR at t, left/right segment regions) | SW:994-1001, 1645-1664 | **Y** — but Def 7.13 licenses ONLY this segmentation; it says nothing about coincident points |
| Conjunction closure = disjunction over order types of combined witnesses, INCLUDING equality cases | Lemma 3.2(1) p. 4; equality-case template §5 p. 7 (k = m split) | `kvE2_sepOrderTypes`/`kvE2_sepArr'` order-type disjunction — but conjunct (iii) `(wo.flatMap …).Nodup` (SW:1354) admits **all-distinct payloads only**; tie order types are unrepresentable | SW:1277-1288, 1350-1360 | **Partial** — interleaving disjunction present; equality cases MISSING (§3) |
| Coincidence handled by case split + conjoined point type at the single shared slot | Def 3.1 (single chain) + Lemma 3.2(1) equality cases; §5 k = m case p. 7 | `.coincident` tag + `kvE2_sepClosedLeafStub` closed self-zone meet channel | SW:1316-1330 | **Partial** — the anchor-coincidence meet channel exists (task 336) and is the right §5-style mechanism, but only for owner-anchor self-coincidence; base-slot tie classes (base–base, base–foreign-anchor) have no representation |
| Interior restriction on all realized positive types | **ABSENT from source** | `hLR` hypothesis | SW:2451, 2495, 3099, 4255 (and the certificate SW:4618-4653) | **N** — artifact; no source counterpart (§2) |
| Dedekind INF point (5.2)/(5.3) | Lemma 5.3 p. 8, (5.3) p. 10 | negation-closure side (`EANegationClosure.lean`), not this completeness layer | — | n/a for this blocker |

## 2. Root cause: `hLR` is a Lean-layer artifact, not an encoding of anything in Rabinovich

**Statement.** `hLR : ∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3` demands that EVERY positive owner of the depth-2 quantifier layer be strictly interior. It has no analogue in the source, and the source's own structure predicts its unsatisfiability.

**Evidence, source side.**
- In Rabinovich, the bracket's interior witnesses are interior **by construction of φ** (§5 split, p. 7): the decomposition SELECTS the interior witnesses `x_m < ⋯ < x_k` into φ and ROUTES everything else (`x_j ≤ z_0`, `x_j ≥ z_1`, and the pinned endpoint types themselves) into ψ_0/ψ_1/endpoint α's, which become **atomic E[Σ] literals at the endpoints** (p. 7, quoted in §1.1). There is no hypothesis anywhere in the paper of the form "all realized types are interior" — the paper has no object corresponding to "the set of all realized depth-1 types" at all. Its brackets carry a *chosen finite list* of types, interior by the way φ was carved out.
- The Lean layer's `kvE2_sepPos qnf` (SW:193) is a different kind of object: the FULL enumeration of positive owners of a characteristic-style depth-2 normal form. For an honest `qnf`, this enumeration provably contains the boundary self-types (`σ_w` at `x1 = w`, and the analogues at `x1 = x`, `x1 = t`): that is exactly the certificate `kvE2_sepHonest_hLR_absurd` (SW:4618), whose `σ_w` is the Lean incarnation of Def 3.1's pinned point `z = x_{i_k}` — the source explicitly expects a "witness" sitting AT a reference point, carrying its type there.

**Evidence, Lean side (why `hLR` was introduced mechanically).** The arrangement carrier quantifies validity over ALL owners: `wo.map Prod.fst = kvE2_sepPos qnf` (SW:1563), and `kvE2_sepDisjValid` conjunct (i) runs `kvE2_sepDisjValidOwner p.1 p.2.1` for every owner (SW:1350-1354). `kvE2_sepDisjValidOwner` (SW:1326-1330) and its `.coincident` leaf `kvE2_sepClosedLeafStub` (SW:1316-1321) have branches ONLY for the two interior classes (the `else` branch reads the `zAtX1R` key, whose honest discharge lemmas `kvE2_sepCoincidentOwner_valid_left/right` require `nf0_zoneSpec σ.1 = zXW3/zWT3`). With no honest validator for the five non-interior classes, the completeness lemmas (`kvE2_sepBody_complete` SW:2445, `kvE2_sepCoincidentOrder_mem_arr'` SW:2489, `kvE2_sepHonestOrder_mem_arr'` SW:3095, `kvE2_sepBody_complete_holds` SW:4249) added `hLR` to force every owner into a dischargeable branch. The two conflated notions:

> source: "the witnesses **this bracket mentions** are interior (by the §5 carve-out)"
> Lean: "**all positive owners of qnf** are interior (by hypothesis)"

The first is a construction invariant; the second is a falsifiable claim about honest models — and `kvE2_sepHonest_hLR_absurd` falsifies it. **Verdict: `hLR` is an artifact of indexing the arrangement carrier by `kvE2_sepPos` (all owners) instead of its interior sub-list, combined with a validity predicate that lacks the source's endpoint routing for non-interior owners.**

Note the non-interior owners' *syntactic* channel is already fully landed and source-faithful: `kvE2_sepEpL` carries `zPastX3` (Since-navigated) and `zAtX3` literals (SW:892-895), `kvE2_sepPtW` carries `zAtW3` literals (SW:937-938), `kvE2_sepEpR` carries `zAtT3` and `zFutT3` (Until-navigated) literals (SW:913-917); slot and segment contributions of non-interior owners are already `[]`/`⊤` (SW:292-311, 959-980). The defect is confined to the carrier/validity layer and the four `hLR`-carrying theorem statements.

## 3. Does the source merge coincident points? (the crux)

**Answer: yes — by conjoining point types at a single slot of a single STRICT chain, with the coincidence pattern enumerated as its own disjunct of the order-type disjunction. Never by relaxing chain strictness, and never via Def 7.13.**

Grounding, per sub-question:

**(a) Two same-type slots of different owners sharing a single realizing point.** Under Def 3.1 there is only ONE existential chain per ∃∀-formula, strictly ordered. When two ∃∀-formulas are conjoined (Lemma 3.2(1)), the equivalent disjunction ranges over order types of the combined witness variables; the order types with `x_i = y_j` are legitimate disjuncts, and in such a disjunct the two variables collapse to ONE chain slot whose point type is `α_i ∧ α′_j` (quantifier-free formulas are closed under ∧ — Def 3.1 requires only that α's be quantifier-free) and whose adjacent interval types are the conjunctions of the overlapping β's. This is a **meet at the formula level** (conjunction of type formulas = intersection of their extensions). The §5 `k = m` case (p. 7) is the paper's own worked instance of the pattern: coincidence appears as an explicit disjunct with a single shared point. So: two same-type slots of different owners sharing a realizer is licensed **iff the arrangement disjunct groups them into one slot with the conjoined type** — a distinct disjunct from the strict interleavings.

**(b) A base witness value coinciding with a foreign anchor.** Same license, same mechanism: the base-type slot χ of owner σ and the fresh-anchor slot of owner τ collapse to one chain slot with point type `χ ∧ (τ's anchor point type)`. Cycle 8 established the model-side fact ("resolution (a) is FALSE": the tie is honestly possible), and the task-340 Phase 5A keystone (SW:2522-2529, `nf_eval_unique`) establishes the only exclusion the source needs no case for: **anchor–anchor ties are impossible** (distinct owners have distinct fresh anchors). So the tie classes the corrected carrier must represent are exactly: base–base ties and base–foreign-anchor ties, within one region.

**What Def 7.13 does and does not license.** Def 7.13 (verbatim in §1.1) requires the reference points to be **distinct variables** and produces a conjunction of per-segment brackets. It licenses the outer `x < w < t` segmentation of `kvE2_sepBody` and nothing about coincident interior points. Cycle 8's "meet-type folding" intuition was **correct in substance but cited to the wrong definition**: the license is Def 3.1 (single strict chain, quantifier-free α's closed under ∧) + Lemma 3.2(1) (equality cases of the interleaving disjunction) + the §5 `k = m` case-split template. This matters practically: Def 7.13's "distinct variables" clause, read as governing slots, would FORBID merging; read correctly (it governs the outer reference points x, w, t — which are strict by `hxw`/`hwt`), it is silent on slots. Any plan that had tried to derive slot-merge rules from Def 7.13 would have been fighting the wrong text.

**Consequence for `IntervalPattern.holds`.** Its strict monotonicity (EA:106-132) is faithful and must NOT be weakened. The current carrier's gap is one level up: `kvE2_sepDisjValid`'s conjunct (iii) `(wo.flatMap (fun p => p.2.2)).Nodup` (SW:1354) makes every slot occupy a distinct chain position in every disjunct, so the equality-case disjuncts of Lemma 3.2(1) are unrepresentable. In a tie model, the honest witness family realizes no all-strict disjunct — completeness fails — and this failure is INDEPENDENT of the `hLR` defect. Both must be fixed for a non-vacuous Phase 3-4.

## 4. Corrected target definition

Two-part redesign. Part I removes `hLR`; Part II adds the tie classes. Both are upstream carrier changes (see §5 for why this is a spawned task).

### Part I — interior-restricted arrangement carrier (replaces `hLR`)

**New definition** (order-preserving filter, so `Nodup`/`zipIdx` foundations transfer):

```
noncomputable def kvE2_sepPosI {sig : MonadicSignature} (qnf : NormalForm sig 2 3) :
    List (NormalForm sig 1 4) :=
  (kvE2_sepPos qnf).filter
    (fun σ => decide (nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3))
```

**Re-anchored declarations** (each switches its owner index from `kvE2_sepPos` to `kvE2_sepPosI`): `kvE2_sepAllSlots` (SW:348), `kvE2_sepOrderTypes` (SW:1277), `kvE2_sepModelOrder` (SW:1296), the owner-projection lemma `wo.map Prod.fst = …` (SW:1563), `kvE2_sepSlotsLOf_mem`/`ROf_mem` (SW:1585/1595), `kvE2_sepCoincidentOrder` (SW:2292), `kvE2_sepHonestOrder` (SW:3063) and its 340 Phase 5A-5C rank machinery. Values of `kvE2_sepSlotsL/R`, `kvE2_sepAllSlots` are unchanged (non-interior blocks are `[]`), but definitional-equality-sensitive proofs must be re-checked. `kvE2_sepSegLAt`/`SegRAt` (SW:986/992) may keep mapping over `kvE2_sepPos` (non-interior contributions are `⊤`) or switch for uniformity — semantically equivalent either way.

**Which literals carry `zAtX3`/`zAtW3`/`zAtT3`: the ones that already exist.** No new literal machinery: `kvE2_sepEpL` (SW:895) carries `zAtX3` at x, `kvE2_sepPtW` (SW:938) carries `zAtW3` at w, `kvE2_sepEpR` (SW:914) carries `zAtT3` at t (with `zPastX3`/`zFutT3` on the Since/Until navigated literals, SW:892-893/916-917). Because `kvE2_sepLit` is biconditional (`if bit then f else f.neg`, SW:173) and the bits are the HONEST `kvE2_sepHasPos` values of `qnf` (not hypothesized away), the always-realized characteristics land on the POSITIVE side of these literals — the Phase 3-4 engine discharges them from `h` at the endpoint/pivot evaluation points (the same Prop 3.5 atomic-in-E[Σ] route the source states on p. 7).

**What replaces `hLR`: nothing.** In `kvE2_sepBody_complete` (SW:2445), `kvE2_sepCoincidentOrder_mem_arr'` (SW:2489), `kvE2_sepHonestOrder_mem_arr'` (SW:3095), `kvE2_sepBody_complete_holds` (SW:4249), delete the `hLR` hypothesis. In the conjunct-(i) proofs, the `rcases hLR σ hσmem` step is replaced by the interiority disjunction extracted from `List.mem_filter` on `σ ∈ kvE2_sepPosI qnf` — the exact same case split, now definitionally available. `kvE2_sepDisjValidOwner`/`kvE2_sepClosedLeafStub` need no non-interior branch (non-interior owners no longer appear in `wo`). `kvE2_sepDisjunct_extract` (SW:4667) hypotheses `hmemL`/`hmemR` restate over `kvE2_sepPosI` membership; its conclusion is already zone-guarded and unchanged.

*Rejected minimal alternative (recorded for the planner)*: keep `wo` over all of `kvE2_sepPos` and add a non-interior `true` branch to `kvE2_sepDisjValidOwner`. Sound (dead tags multiply the disjunction by identical disjuncts — slots `[]`, segments `⊤`) and a much smaller edit, but unfaithful: the source's interleaving index (Lemma 3.2(1)) ranges over bracket witnesses only, and the phantom entries would carry meaningless placement tags through every later structural lemma. Per the user directive (faithfulness over expedience), Part I as stated is the recommendation; the alternative is the documented fallback if the re-anchoring blast proves larger than estimated.

### Part II — tie-class weak orders and meet-folded disjuncts (the Lemma 3.2(1) equality cases)

**What the slot lists must become.** The per-owner slot lists themselves (`kvE2_sepSlotsLFor`/`RFor`, SW:292-311) are already correct — the merge belongs to the arrangement layer, matching the source (merging is a property of an order type, not of the slot inventory):

1. **Index payloads become tie-admitting**: replace conjunct (iii) `Nodup` (SW:1354) by "Nodup across distinct anchor slots" + explicit tie classes: a valid weak order partitions each region's slots into an ordered sequence of nonempty tie classes (equal payload entries = same class). Anchor–anchor ties stay excluded (keystone 5A, `nf_eval_unique`); admissible ties are base–base and base–anchor within a region.
2. **The disjunct builder folds tie classes**: `kvE2_sepDisjunct` (SW:1020) builds bracket point types from grouped slots — one bracket position per tie class, point type `formula_conjList (class.map (kvE2_sepSlotType charBase charK))` (Def 3.1 meet: quantifier-free α's conjoined at the single strict slot). `kvE2_sepBracketN` (SW:1009) and the banked `kvE2_sepBracketN_construct` (SW:4521) are generic over point-type lists and survive unchanged.
3. **Validity of a tie class** extends the landed §5 meet channel: a base–anchor tie class is validated by the anchor owner's CLOSED self-zone bit at the tied base type (the `kvE2_sepClosedLeafStub` pattern, SW:1316-1321, generalized from the owner's own fresh type to the foreign base type); base–base tie classes need no self-zone key at all (two type slots demanding one witness of the conjoined type — no open/closed key involved, F5-clean by construction).
4. **The honest order selects its tie pattern from the model**: `kvE2_sepHonestOrder`'s value-rank payload (340 Phase 5B/5C) reports EQUAL indices exactly where honest values coincide, so the honest arrangement is the tie-folded disjunct the Phase 3-4 engine (`kvE2_sepHonest_engineInputs` SW:3952, `kvE2_sepHonest_witnesses` SW:4141, base realizers SW:3503/3522) realizes with strictly monotone per-class witnesses — `IntervalPattern.holds` strictness untouched.

**Corrected completeness shape to plan against** (Phase 5D successor):

```
theorem kvE2_sepBody_complete_holds' …
    (hg : kvE2_sepGate qnf) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hdisj : (kvE2_sepDisjunct' charBase charK qnf
        (kvE2_sepTieGroupedL (kvE2_sepHonestOrder' qnf M w x t h))
        (kvE2_sepTieGroupedR (kvE2_sepHonestOrder' qnf M x w t h))).2.holds M atomMap x t) :
    (kvE2_sepBody' charBase charK qnf).holds M atomMap x t
```

— no `hLR`; owners in the arrangement are `kvE2_sepPosI` members; `hdisj` remains the single delegated `.holds` that task 337's engine proves (now over the tie-grouped honest order), and the boundary-class content is discharged inside `hdisj`'s endpoint/pivot conjuncts from `h`.

## 5. Blast radius

All lines in `SharedWitness.lean` unless noted. Tasks 336/338/339/340 are COMPLETED; edits below to their landed declarations are cross-task decisions.

**(i) Additive-only** (new declarations, no landed statement changes):
- `kvE2_sepPosI` + transfer lemmas (`Nodup`, membership, `map Prod.fst` variants).
- Tie-class grouping functions (`kvE2_sepTieGroupedL/R`) and the grouped disjunct builder wrapper; `kvE2_sepBracketN` (SW:1009) and banked `kvE2_sepBracketN_construct` (SW:4521) reused as-is.
- New tie-class validity discharges (generalizing `kvE2_sepCoincidentAnchor_discharge`/`_R` to foreign base types).
- Endpoint/pivot honesty lemmas (honest `h` ⟹ `EpL`/`PtW`/`EpR` literal evaluation), consumed inside the Phase 3-4 engine — new obligations, previously hidden behind vacuity.

**(ii) Genuinely breaking** (landed carrier/statement edits):

| Declaration | SW line | Owning task | Nature of change |
|---|---|---|---|
| `kvE2_sepAllSlots` | 348 | 340 (P3/6 foundation) | owner index → `kvE2_sepPosI` (value unchanged; defeq-sensitive proofs re-checked) |
| `kvE2_sepOrderTypes` | 1277 | 334 P1-2 / 340 | owner index → `kvE2_sepPosI`; payload tuples tie-admitting |
| `kvE2_sepModelOrder` | 1296 | 334/338 | owner index → `kvE2_sepPosI` |
| `kvE2_sepDisjValid` conjunct (iii) | 1350-1354 | 336/340 | `Nodup` → anchor-distinct + tie-class wellformedness |
| `kvE2_sepArr'` | 1358 | 334/336 | inherits both |
| `kvE2_sepDisjunct` | 1020 | 337 P2 (landed) | slot-list arguments → tie-grouped lists (or a primed successor consuming groups) |
| `kvE2_sepBody`, `kvE2_sepBody_holds_iff` | 1645, 1682 | 334/338 | disjunct map over corrected carrier |
| owner-projection + membership lemmas | 1563, 1571, 1585, 1595 | 339 | restate over `kvE2_sepPosI` |
| `kvE2_sepCoincidentOrder` (+ `_mem_orderTypes`) | 2292 | 334/337 P1 | owner index; `hLR` dropped from `_mem_arr'` (2489) |
| `kvE2_sepBody_complete` | 2445 | 334/336 | drop `hLR` (statement change) |
| `kvE2_sepHonestOrder` + 5A-5C rank machinery | 3063, 2531ff | 340 | owner index; value-rank payload reports honest ties instead of forcing distinctness |
| `kvE2_sepHonestOrder_mem_arr'` | 3095 | 340 P5B | drop `hLR`; tie-class validity conjunct |
| `kvE2_sepBody_complete_holds` | 4249 | 340 P5D | drop `hLR`; tie-grouped `hdisj` |
| `kvE2_sepDisjunct_extract` | 4667 | 321 v7 P8 | hypotheses restated over `kvE2_sepPosI`; per-class witness extraction |
| `kvE2_sepHonest_hLR_absurd` | 4618 | 337 c11 | RETAINED verbatim as the design-guard certificate (documents why `hLR` variants must never return) |

Doc-only: `OuterGate.lean:28` (references `kvE2_sepBody_complete`'s `hLR` in prose).

**Spawned-task recommendation: YES.** The breaking set reaches into the landed carriers of four COMPLETED tasks (336, 338, 339, 340) and rewrites the completeness interface that 337's own Phases 3-4 consume. Under the task-system's cross-task rules this is not a 337-local edit: recommend `/spawn 337` with a dedicated upstream task ("interior-restricted, tie-admitting arrangement carrier for kvE2_sep — hLR removal per report 07"), with 337 Phases 3-4 re-planned against the corrected interface afterward. Banked 337 assets survive: `kvE2_sepHonest_engineInputs`, `kvE2_sepHonest_witnesses`, `kvE2_sepBracketN_construct`, `kvE2_sepHonestBaseRealizerL/R`, the halign trio, value-sortedness, Nodup foundations, `kvE2_sepCoincidentOrder_mem_arr'` (restated without `hLR` but proof-shape-identical), and `kvE2_sepHonest_hLR_absurd` (as guard).

## Adversarial Self-Verification

Refutation attempts against the proposed redesign, then the claim table.

**Attempt 1 — a σ_w-style always-realized characteristic against the corrected design.** The certificate's engine: `nf_characteristic` at a pinned configuration is always realized, forcing a positive owner in a class the hypothesis excludes. The corrected design excludes NO class by hypothesis: boundary/exterior owners are routed to literals whose bits are their honest `kvE2_sepHasPos` values (biconditional `kvE2_sepLit`, SW:173), so `σ_w` makes `HasPos zAtW3 (nfk_projFresh σ_w) = true` and the PtW literal is the POSITIVE `charK` atom — an honest obligation discharged from `h` at w, not a contradiction. Interior-class characteristics are realized only when the model has an interior point of that type, in which case the honest witness discharges the zone bits. The empty-interior edge case (no interior positive owners, e.g. discrete gaps): `kvE2_sepOrderTypes` over `[]` is `[[]]` and `kvE2_sepDisjValid [] = true` (all three conjuncts vacuous/`Nodup []`), so `kvE2_sepArr' ≠ []` non-vacuously. **No σ_w-style refutation found.**

**Attempt 2 — F5 (no open/closed zone-key conflation).** Tie-class folding: base–anchor classes read the anchor owner's CLOSED self-zone key (the landed `kvE2_sepClosedLeafStub` discipline, SW:1308-1321, extended to the foreign base type); base–base classes read no self-zone key. Strict placements keep their OPEN keys (SW:1328-1329). One place needs design care in the plan: the generalized discharge for a foreign base type on an anchor must read the anchor owner's closed bit at the FOREIGN type χ, not at its own fresh projection — a new lemma, but the same key family; no open key enters any coincident read. **Survives, with the flagged obligation.**

**Attempt 3 — LITMUS (NS:437: no `x1 < e_i` relative-position literal; witness bounds from the bracket range only).** Part I is index re-anchoring plus hypothesis deletion — no formulas added. Part II folds point types (conjunction of quantifier-free α's) and changes an abstract ℕ-payload wellformedness condition (SW:1338-1339-style compares); tie classes are payload equalities, model-free. Witness bounds continue to ride `IntervalPattern.holds`'s own range (EA:106-132). **No relative-position literal is introduced anywhere. Survives.**

**Attempt 4 — the certificate itself.** `kvE2_sepHonest_hLR_absurd` consumes `hLR` as a hypothesis; the corrected statements have no `hLR` or any zone-restriction hypothesis on `kvE2_sepPos`, so the certificate cannot re-derive `False` against them. Residual vacuity risk relocates to `hdisj` (if the honest tie-grouped disjunct were unrealizable, Phase 5D' would be conditionally vacuous again). Checked: cycle-8's tie possibility is exactly what Part II makes realizable (the honest order reports its own ties; per-class witnesses are strict), and the strict/`r_0 = z_0`-asymmetric tags remain honestly-undischargeable exactly as the landed comment states (SW:1296-1300 doc) — the honest route goes through the tie/coincident channel, as it already does today. **The redesign is not refuted by the certificate; the one relocation risk is named and answered by Part II.**

**Attempt 5 — refute my own root-cause reading of the source.** Alternative reading: "Rabinovich's Lemma 5.1 negation analysis assumes interior witnesses, so hLR faithfully encodes that assumption." Rejected on the text: Lemma 5.1's brackets have interior witnesses because §5's decomposition (p. 7) PUT only interior witnesses there, having already routed the rest to ψ_0/ψ_1 — an output of the construction, not an input hypothesis. `hLR` restricts a completeness-side enumeration (`kvE2_sepPos`) that has no counterpart object in the paper. **Reading stands.**

### Claim Verification Table

| Claim | Source/Counterexample | Verification Method | Confidence |
|---|---|---|---|
| Def 3.1 witness chain is strict, free variables pinned (`z_k = x_{i_k}`) | Rabinovich p. 4, Def 3.1 (verbatim) | PDF page read (pp. 4) | High |
| Def 7.13 is segment-wise conjunction over DISTINCT reference points; contains no union/merge of types | Rabinovich p. 15, Def 7.13 (verbatim quoted in §1.1) | PDF page read (p. 15) | High |
| §5 routes non-interior witnesses to one-free-variable formulas that become ATOMIC E[Σ] literals | Rabinovich p. 7 (ψ_0/ψ_1/φ split + "atomic" sentence, quoted) | PDF page read (p. 7) | High |
| Coincidence licensed as equality-case disjuncts with conjoined point types on one strict chain | Def 3.1 + Lemma 3.2(1) p. 4; k = m case split p. 7 | PDF page read; Lemma 3.2(1) is asserted without proof in-source — mechanism inferred as the only one consistent with Def 3.1 (flagged) | Medium-High |
| `IntervalPattern.holds` requires strictly monotone witnesses | EA:106-132 | bounded file read (definition verbatim) | High |
| `hLR` appears in exactly 4 landed theorem statements + the certificate | SW:2451, 2495, 3099, 4255, 4622 | grep over SharedWitness.lean (all `hLR` hits enumerated) | High |
| Non-interior owners contribute `[]` slots and `⊤` segments already | SW:292-311 (`else []` both lists), SW:959-980 (`else Formula.top`) | bounded file read | High |
| `kvE2_sepLit` is biconditional (`false` bit ⟹ negation) | SW:173 | bounded file read | High |
| Validity conjunct (iii) forbids all payload ties | SW:1350-1354 (`(wo.flatMap …).Nodup`) | bounded file read | High |
| `kvE2_sepConsistentBlock` is vacuous on empty blocks (non-interior owners pass conjunct (ii)) | SW:703-710 (`∀ j k : Fin (block σ).length` with block `[]`) | bounded file read | High |
| Anchor–anchor ties impossible (keystone) | SW:2522-2529 (task 340 P5A, `nf_eval_unique`) | bounded file read of banner + delegation-context bank list | High |
| EpL/PtW/EpR already enumerate all five non-interior classes' HasPos literals | SW:892-895, 913-917, 937-938 | bounded file read | High |
| `wo.map Prod.fst = kvE2_sepPos qnf` (carrier ranges over ALL owners) | SW:1560-1563 | grep + bounded read | High |

### Contradiction Log

- **Blocker report / delegation ("Rabinovich Def 7.13 union") vs. Def 7.13 verbatim text (p. 15)**: RESOLVED by primary-source precedence — Def 7.13 has no union operation; the coincidence-merge license is Def 3.1 + Lemma 3.2(1) equality cases (+ §5 k = m template). The substance of the "meet-type folding" proposal survives; its citation is corrected. Downstream instruction: plans must cite Def 3.1/Lemma 3.2(1) for slot folding and Def 7.13 only for the outer x < w < t segmentation.
- **Lemma 3.2(1) has no in-source proof** ("It is clear that", p. 4): the equality-case mechanism is the unique reading consistent with Def 3.1's single strict chain, and the paper's own k = m split (p. 7) instantiates it; flagged Medium-High rather than High. No resolving text exists in this paper; Kamp 1968 was not needed since the construction does not defer there for this point.

### Recommendations modified after verification

- Initial draft attributed coincidence-merging to Def 7.13 (following the delegation's framing); corrected to Def 3.1 + Lemma 3.2(1) after the p. 15 verbatim read.
- Initial draft considered the minimal `kvE2_sepDisjValidOwner`-guard fix as the primary recommendation; demoted to documented fallback after the §5 (p. 7) read showed the source's interleaving index ranges over bracket witnesses only, making the interior-restricted carrier (Part I) the faithful shape — per the binding user directive.

## Revised direction

None required — the verification pass corrected citations and recommendation ranking (logged above) but did not overturn the search direction.
