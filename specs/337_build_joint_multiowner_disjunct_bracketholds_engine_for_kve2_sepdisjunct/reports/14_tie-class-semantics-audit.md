# Report 14 — Tie-Class Semantics: Faithfulness Audit vs. Rabinovich (2014)

**Task**: 337 | **Session**: sess_1783639750_29c89e_337 | **Type**: lean4 research (read-only)
**Blocker (as posed)**: "which rank key must `kvE2_sepTieGroupedL` group by for O1 strict
cross-class monotonicity to be both provable and faithful."
**Primary source**: `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`
(md line numbers below; PDF consulted where the markdown mangles subscripts — flagged inline).
**Companion**: Report 13 (`.rXW` carrier fix — CONFIRMED, LANDED as Phase 2, green, axiom-clean).
This report does NOT re-litigate the pivot bounds (report 13 Q1/Q2/Q4); it settles the orthogonal
tie-class grouping-key question.

---

## Bottom line (verdict up front)

**Verdict = (b), verging on (c): the `(A)↔(C)` bridge EXISTS and is ALREADY PROVED. There is no
drift, and no landed asset needs editing. O1's cross-class strict monotonicity is provable and
faithful from Phase-1 assets that are already on disk and green.** The implementer's stop was a
**misreading**, not a real semantic gap: the blocker text conflated the carrier merge key (A)
`kvE2_sepSlotGIdx` with the injective model key (B) `kvE2_sepSlotHonestGIdx`, whose `_injOn` lemma
(SW:3840) and value-layer docstring (SW:376, ~3526-3530) describe a `(value, slotIndex)` **lex**
rank that forces singleton tie classes. The builder does **not** use (B). It uses the PRIMED tie-
reporting order `kvE2_sepHonestOrder'` (SW:5974), whose stored payload **is** the value-only rank
(C) `kvE2_sepSlotHonestVIdx` (SW:5831), and on that order the merge key (A) equals (C) by the proved
bridge `kvE2_sepSlotGIdx_honestOrder'` (SW:7868).

**The grouping key `kvE2_sepTieGroupedL` uses (A) `kvE2_sepSlotGIdx wo` (SW:2054-2056), and that is
CORRECT — do not change it.** The fix is a single **additive** lemma (cross-class strict
monotonicity) assembling five landed Phase-1 lemmas. It touches nothing owned by tasks 340/342.

**The one real trap**: two OTHER weak orders in the file — `kvE2_sepModelOrder` (SW:1476,
syntactic-injective payload) and the UNPRIMED `kvE2_sepHonestOrder` (SW:3891, (B)-injective payload)
— both force singleton classes. Wiring the grouped builder to either instead of `kvE2_sepHonestOrder'`
breaks ties and makes O1 FALSE. This is the single most important guardrail (see Q3, Q5).

---

## The three keys, disambiguated (foundation for everything below)

The blocker text (and the file's own value-layer docstrings) blur three distinct ℕ-valued rank
functions. Verified against source:

| Key | Decl (SW) | Layer | Reads | Tie behavior |
|-----|-----------|-------|-------|--------------|
| **(A)** `kvE2_sepSlotGIdx wo s` | 1920-1924 | carrier (`wo`-parametric) | the ℕ stored in `wo`'s payload tuple at `s`'s block position (`t.getD (kvE2_sepBlockPos s) 0`) | **whatever the payload encodes** — tie-admitting for a general carrier `wo`, injective if the payload is injective |
| **(B)** `kvE2_sepSlotHonestGIdx …` | 3807-3813 | model | `kvE2_ordRank` of `kvE2_sepSlotG` = `(value, slotIndex)` **lex** | **INJECTIVE** (`_injOn`, SW:3840) — every class a singleton |
| **(C)** `kvE2_sepSlotHonestVIdx …` | 5831-5837 | model | `kvE2_ordRank` of `kvE2_sepSlotV` = the **value alone** (no index tiebreak) | **collapses genuine ties** — `_eq_iff` (SW:5865): equal rank ↔ equal value |

Critical structural fact the blocker text missed: **(A) is not a fixed model-independent number — it
is a *reader* of whatever ℕ the caller stored in `wo`.** Its model-(in)dependence is entirely
inherited from the `wo` argument:

- On `kvE2_sepModelOrder` (SW:1478-1479), the stored payload is `block.map (kvE2_sepSlotIndexOf qnf)`
  — the **syntactic, model-independent, globally injective** slot index (`kvE2_sepSlotIndexOf_injOn`,
  SW:657) → (A) is injective → all singletons.
- On the UNPRIMED `kvE2_sepHonestOrder` (SW:3894-3896), the payload is `block.map kvE2_sepSlotHonestGIdx`
  = (B) → (A) = (B) → injective → all singletons.
- On the PRIMED `kvE2_sepHonestOrder'` (SW:5977-5979), the payload is `block.map kvE2_sepSlotHonestVIdx`
  = (C) → **(A) = (C) → ties collapse exactly at model-value coincidences.**

So "is (A) model-independent?" has no single answer; it depends which `wo` is fed. The grouped
builder's obligation is to feed `kvE2_sepHonestOrder'`, and then (A) is model-dependent and
tie-collapsing exactly as faithfulness requires.

---

## Q1 — The correct grouping key

**Answer: the faithful key is (C) — merge exactly the model-coincident points — and the code
ALREADY groups by (C) on the honest path, routed through (A) by the proved bridge. The dangerous
"unmerged coincidence" disjunct CANNOT occur.**

Rabinovich's chain is over **actual points of the model**. Def 3.1 (md:109-111) forms the point
witnesses with the existential prefix `∃x0 … ∃xn`; Lemma 5.3 (md:225) states the witness demand as a
**strict** chain of individual points `z0 < x1 < ··· < xn < z1` with `Pi(xi)`. Two witnesses
"coincide" iff they are the SAME point of the chain = the SAME value; a coincident point carries the
**conjunction** of the coinciding types (Def 3.1's conjunctive body; Figure 1's shared `β2` at the
pivot, md:299, is one point whose demand is the meet of the two brackets). Therefore the faithful
merge key is **the model value** — precisely (C). A model-INDEPENDENT syntactic key (e.g.
`kvE2_sepSlotIndexOf`, the payload of `kvE2_sepModelOrder`) would be UNFAITHFUL: it cannot know which
points coincide in a given M, so it would either split one model point into two chain positions or
fail to merge two genuinely-equal points.

Now the two disjuncts the orchestrator flagged, checked on `wo = kvE2_sepHonestOrder'`:

1. *"share an (A)-index yet differ in value"* — cannot happen. On the honest order (A) = (C)
   (bridge, SW:7868), and `kvE2_sepSlotHonestVIdx_eq_iff` (SW:5865) is an **iff**: equal (C) ⟺ equal
   `kvE2_sepSlotValue`. So one class = one value. (This is exactly what the landed
   `kvE2_sepTieGroupedL_value_const` / `…R…` prove, SW:8013 / 8043.)
2. *"equal values but different (A)-indices, leaving a coincidence unmerged"* — **the dangerous
   one; also cannot happen.** By the same iff, equal `kvE2_sepSlotValue` ⟹ equal (C) ⟹ equal (A).
   And `kvE2_sepSlotsLOf` is `mergeSort`ed by (A) (SW:1947), so equal-(A) slots are **contiguous**;
   `kvE2_sepTieRuns` groups maximal adjacent equal-key runs (SW:1971-1977), so equal-value slots land
   in ONE class. No coincidence escapes. O1 is therefore NOT unprovable-as-stated.

*Paper citation*: Def 3.1 (md:109-111); Lemma 5.3 strict point chain (md:225); Figure 1 pivot meet
(md:299, PDF p.9). The paper settles that merging is by coincidence of model points (= value),
which (C) implements and the honest order routes through (A).

---

## Q2 — Does O1 even hold?

**Answer: YES. On `kvE2_sepHonestOrder'`, (A)-classes coincide with (C)-classes EXACTLY, the bridge
is a NAMED, PROVED lemma, and distinct classes carry strictly increasing values. Every ingredient is
landed and green.**

The bridge is **not** absent — it is `kvE2_sepSlotGIdx_honestOrder'` (SW:7868-7914):

> `kvE2_sepSlotGIdx (kvE2_sepHonestOrder' qnf M w x t h) s = kvE2_sepSlotHonestVIdx qnf M w x t h s`
> for `s ∈ kvE2_sepSlotBlock σ`, `σ ∈ kvE2_sepPos qnf`.

Its proof is pure `find?`/`getD` bookkeeping (the honest order's payload literally *is* the
`block.map kvE2_sepSlotHonestVIdx` list), so the bridge is **near-definitional**, not a hard
theorem. Cross-class strict monotonicity then assembles from five LANDED lemmas:

1. `kvE2_sepTieRuns_key_const` (SW:7976) — one (A)-key per class.
2. `kvE2_sepSlotGIdx_honestOrder'` (SW:7868) — (A) = (C) on the honest path.
3. `kvE2_sepSlotHonestVIdx_eq_iff` (SW:5865) — equal (C) ⟺ equal value (⟹ **distinct** classes have
   **distinct** values, contrapositive).
4. `kvE2_sepSlotsLOf_honestOrder'_valueSorted` / `…ROf…` (SW:7935 / 7954) — the whole slot list is
   `Pairwise (value ≤ value)`.
5. `kvE2_sepTieGroupedL_value_const` / `…R…` (SW:8013 / 8043) — one value per class (so the
   class-head value represents the class).

Distinct adjacent classes differ in (A)-key (tieRuns boundary) → differ in (C) → differ in value
(3); combined with `≤` (4) this is strict `<`. Hence the class-head value list is
`Pairwise (· < ·)`. The pivot ends `last(usL) < w < first(usR)` are the report-13 value bounds
(LEFT slot values `< w` after the LANDED Phase-2 `.rXW` fix; RIGHT slot values `> w`), so the full
`(usL ++ w :: usR).Pairwise (· < ·)` — the exact `hsort` hypothesis of `kvE2_sepBracketN_construct`
(SW:5371) — holds. **O1 is TRUE and provable.**

*Named bridge*: `kvE2_sepSlotGIdx_honestOrder'` (SW:7868). It exists; it is proved; it is green.

---

## Q3 — Is the carrier/model split itself the drift?

**Answer: NO. The split is faithful, and task 342 built it correctly — BUT there are three weak
orders in the file with different payloads, and only the PRIMED one is tie-reporting. The drift risk
is a WIRING error (feeding the wrong order), not the architecture.**

`KvE2SepWeakOrder = List (NormalForm × KvE2SepSpikeOrderType × List ℕ)` (SW:1282-1283) genuinely
ENCODES arrangements: the `List ℕ` payload is the per-slot index tuple, and `kvE2_sepOrderTypes`
(SW:1455-1463) enumerates ALL tag × index-tuple assignments (a finite `decide`-able disjunction).
The model then SELECTS one disjunct. This mirrors Rabinovich's method exactly: Prop 4.3 (md:169) and
Lemma 3.2(1) (md:117) express formulas as **disjunctions of →∃∀ formulas** — arrangements enumerated
syntactically, one realized by the true model. Merging is at the model (Def 3.1's points ARE model
points), never post-hoc syntactic. So the enumerate-carrier / select-in-model architecture is
faithful; no drift there.

The subtlety task 342 introduced (Phase 9) is that the SELECTED order must carry the **value-only**
payload (C) to be tie-reporting. Three orders exist:

| Order | Decl (SW) | Payload | (A) on it | Tie behavior |
|-------|-----------|---------|-----------|--------------|
| `kvE2_sepModelOrder` | 1476 | `kvE2_sepSlotIndexOf` (syntactic) | injective | **singletons** — UNFAITHFUL if fed to the grouped builder |
| `kvE2_sepHonestOrder` (unprimed) | 3891 | (B) `kvE2_sepSlotHonestGIdx` | injective | **singletons** — the value+index lex tiebreak breaks genuine ties |
| `kvE2_sepHonestOrder'` (primed) | 5974 | (C) `kvE2_sepSlotHonestVIdx` | = (C) | **tie-reporting** — the ONLY faithful choice |

All Phase-1 halign assets (SW:7863-8070) are stated on the **primed** order, so the plan's intent is
correct. The drift would materialize only if an implementer wired O1 to `kvE2_sepModelOrder` or the
unprimed `kvE2_sepHonestOrder` — exactly the surfaces the (B) `_injOn` docstring (SW:3836-3838)
tempts one toward. **Guardrail: the grouped builder MUST consume `kvE2_sepHonestOrder'`.**

*Paper citation*: Prop 4.3 (md:169), Lemma 3.2(1) (md:117) — disjunction-over-arrangements; Def 3.1
(md:109-111) — points are model points, merged by coincidence. The paper quantifies over
arrangements and merges in the model; the carrier/model split reproduces this. No drift.

---

## Q4 — Strictness (re-confirmation)

**Answer: YES — re-confirmed, consistent with report 13 Q4. The chain is STRICT after merging, and
the merge (not a weakening of `<`) absorbs ties. `Pairwise (· < ·)` on MERGED class values is the
faithful demand.**

Lemma 5.3 (md:225) is a strict chain `z0 < x1 < ··· < xn < z1`; Def 3.1 (md:109-111) enumerates
distinct points. Coincidences are absorbed by MERGING two witnesses into one point with a conjoined
type — Figure 1's shared `β2` at the pivot (md:299) is the paradigm: one point, meet of demands. The
grouped builder mirrors this: one strict bracket slot per class with conjoined point type
`formula_conjList (class.map kvE2_sepSlotType)` (SW:1960-1961). After this quotient the surviving
representatives are pairwise DISTINCT points, so `Pairwise (· < ·)` on class-head values is exactly
Rabinovich's strict inter-point demand — not an over-strengthening. Weakening `<` to `≤` would be the
unfaithful move (report 13 Q4); merging is the faithful one, and it is where ties go.

*Paper citation*: Lemma 5.3 (md:225); Def 3.1 (md:109-111); Figure 1 (md:299, PDF p.9).

---

## Q5 — Verdict and minimal faithful fix

**Verdict: (b) — the (A)↔(C) bridge exists and is already proved (`kvE2_sepSlotGIdx_honestOrder'`,
SW:7868); it verges on (c) because the primed order is CONSTRUCTED so the bridge is near-definitional
(its payload literally is the (C) list). Grouping-key change (verdict (a)) is UNNECESSARY and would
be a gratuitous edit to a landed 342 asset. O1 is faithful as stated (not verdict (d)).**

### The fix is a single ADDITIVE lemma (no landed asset edited)

Add one lemma (and its RIGHT mirror) — *cross-class strict value monotonicity* — of shape:

```
theorem kvE2_sepTieGroupedL_headValue_strictMono … :
  ((kvE2_sepTieGroupedL (kvE2_sepHonestOrder' qnf M w x t h)).map
      (fun c => kvE2_sepSlotValue qnf M w x t h (c.head …))).Pairwise (· < ·)
```

Proof skeleton (all inputs landed & green):
- Adjacent classes `c₁, c₂`: their heads `u₁ ∈ c₁`, `u₂ ∈ c₂` sit in the value-sorted flattened list
  (`kvE2_sepSlotsLOf_honestOrder'_valueSorted`, SW:7935) with `u₁` before `u₂`, giving
  `value u₁ ≤ value u₂`.
- Distinctness: the (A)-keys of `c₁`, `c₂` differ (tieRuns boundary; `kvE2_sepTieRuns_key_const`
  SW:7976 for intra-class constancy + the `if key a = key b` split for inter-class difference); via
  the bridge (SW:7868) their (C)-values differ; via `kvE2_sepSlotHonestVIdx_eq_iff` (SW:5865)
  `value u₁ ≠ value u₂`.
- `≤` ∧ `≠` ⟹ `<`.

Then feed the resulting `(usL ++ w :: usR).Pairwise (· < ·)` (usL/usR = class-head values) plus the
report-13 pivot bounds into `kvE2_sepBracketN_construct`'s `hsort` (SW:5371). Nothing in tasks
340/342 is edited; plan 13's authorization scope (the three `.rXW` sites only) is not exceeded,
because a NEW additive lemma touches no existing declaration.

### Landed assets CONSUMED (read-only; none edited)

- (A) `kvE2_sepSlotGIdx` (SW:1920) — task 340; `kvE2_sepTieGroupedL/R` (SW:2054/2059) — task 342 Ph6.
- (C) `kvE2_sepSlotHonestVIdx` (SW:5831) + `_eq_iff` (SW:5865); `kvE2_sepHonestOrder'` (SW:5974) —
  task 342 Ph9.
- Bridge `kvE2_sepSlotGIdx_honestOrder'` (SW:7868), `_mono` (SW:7919), `valueSorted` L/R
  (SW:7935/7954), `key_const` (SW:7976), `value_const` L/R (SW:8013/8043) — task 337 plan 12/13 Ph1
  (LANDED, green per `.return-meta.json` build_passed).

### Additive?

**Yes — strictly additive.** The blocker was epistemic (a misread of which order/key the builder
uses), not structural. No `Classical.epsilon` value is re-pinned; no definition changes; no
re-authorization needed. Estimate: two short lemmas (~15-25 lines each) plus the `hsort` assembly
already scaffolded by report 13's Phase-2 pivot bounds.

---

## LITMUS (NavigatedSpine:437) and F1-F7 — fix is clean

- **LITMUS (no `x1 < e_i` relative-position literal)**: the proposed lemma introduces **no order
  literal at all** — it manipulates ℕ ranks (A)/(C) and the already-existing `kvE2_sepSlotValue`
  comparisons that ride the fixed endpoints `x`/`w`/`t`. No fresh/anchor point is pinned against an
  existential point. **LITMUS clean, trivially.**
- **F1 (QF/E[Σ] point types)**: untouched — the lemma reads ranks and values, not formula literals;
  point types (`kvE2_sepSlotType`) are unchanged.
- **F2/F3 (non-vacuity)**: each class is nonempty (`kvE2_sepTieGroupedL_ne_nil`, SW:2074), so
  `c.head` is total on the class list; the witness values genuinely exist.
- **F4/F5 (no model literal buried / no OPEN key)**: (A) reads carrier payload (F5-clean per SW:1918);
  (C)/value comparisons are the same channel the four faithful branches and Phase-1 already use.
- **F6/F7**: the quotient (one slot per class, conjoined type) is Rabinovich's coincidence merge
  (Figure 1, md:299), not a novel coupling.

---

## Evidence index (file:line)

- Three keys: (A) `SharedWitness.lean:1920-1924`; (B) `:3807-3813` + `_injOn :3840`; (C) `:5831-5837`
  + `_eq_iff :5865-5879`.
- Grouping: `kvE2_sepTieGroupedL/R :2054-2061`; `kvE2_sepTieRuns :1971-1977`; sorted list
  `kvE2_sepSlotsLOf :1945-1947` (mergeSort by (A)).
- Three orders: `kvE2_sepModelOrder :1476-1479` (syntactic payload); `kvE2_sepHonestOrder :3891-3896`
  (B payload); `kvE2_sepHonestOrder' :5974-5979` (C payload — the faithful one).
- **Proved bridge**: `kvE2_sepSlotGIdx_honestOrder' :7868-7914`; `_mono :7919-7930`.
- Phase-1 landed assets: `valueSorted` L/R `:7935-7951 / :7954-7970`; `key_const :7976`;
  `value_const` L/R `:8013-8040 / :8043-8070`.
- O1 consumer: `kvE2_sepBracketN_construct :5365`, `hsort :5371`; region-route precedent
  `kvE2_sepHonest_witnesses :5000-5017` (already yields a strict `interleaveK` chain).
- Report 13 pivot bounds (LANDED Phase 2): `.rXW` value `< w`.
- Paper: Def 3.1 md:109-111; Lemma 3.2(1) md:117; Prop 4.3 md:169; Lemma 5.3 md:225; Figure 1 md:299
  (PDF p.9); Def 7.13 md:451.

*Note on the markdown source*: subscripts in the Lemma 5.1/5.3/Cor 5.4 formula bodies (md:207-247)
are mangled, but the load-bearing citations — the strict chain `z0 < x1 < ··· < xn < z1` (md:225),
the existential prefix of Def 3.1 (md:109-111), and Figure 1's `β2` meet (md:299) — survive legibly.
The `(A)=(C)` determination rests on the Lean bridge (SW:7868, machine-checked), not on the mangled
paper formulas, so no PDF re-extraction was required to settle the verdict.
