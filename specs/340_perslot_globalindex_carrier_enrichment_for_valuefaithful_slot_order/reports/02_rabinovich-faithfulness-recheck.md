# Rabinovich Faithfulness Recheck: the Per-Slot Global-Index Carrier (Task 340)

**Task**: 340 — Per-slot global-index carrier enrichment for value-faithful slot order
**Role**: Agent A — LITERATURE FAITHFULNESS CHECK against Rabinovich (2014)
**Territory**: the paper only (Def 3.1, Lemma 3.2(1), §5 interval splitting, Def 7.13). Carrier
internals are Agent B's; the 337 `.holds` builder engine is Agent C's.
**Mode**: RESEARCH-ONLY (no Lean edited). Reference tier: **Tier 1 (literature, faithful transcription)**.
**Source**: `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`
(indexed `rabinovich_2014`).

> **Scope caveat (stated up front, H3/H4)**: all `md:` line numbers below point to the *summary
> markdown* of the 16-page paper, not the primary PDF text. Def 3.1 in the summary (md:61–74) is a
> paraphrase of the ordering constraints. Where a claim is load-bearing I note whether the summary
> alone suffices or whether a PDF check is advisable (see Adversarial §, Refutation R2).

---

## H3 Citation Table (source → carrier decision)

| # | Faithfulness claim | Rabinovich anchor (md line) | Carrier site (340) | Verdict |
|---|--------------------|-----------------------------|--------------------|---------|
| C1 | The witness is a **single strictly-increasing chain** `x_0 < … < x_n` over the chosen points, partitioning the chain into typed intervals | **Def 3.1**, md:63–74 ("ordering constraints on x_i"; md:74 "existentially chosen points partition the chain into intervals") | per-slot global index = total order on the full slot multiset | FAITHFUL |
| C2 | Merging several owners' decompositions yields a **disjunction over order-consistent interleavings**; each disjunct fixes one global order | **Lemma 3.2(1)**, md:77 ("Conjunction of ∃∀ ≡ disjunction of ∃∀") | `kvE2_sepArr'` filter over `kvE2_sepOrderTypes`; the enumeration `kvE2_sepIdxTuples n` | FAITHFUL |
| C3 | The multi-**owner** union (multiple reference points) is the intended object, not bare single-reference Def 3.1 | **Def 7.13**, md:202 (`(z_0,…,z_k,∞)`-∃∀); **Lemma 7.14**, md:204 | cross-owner slot multiset (`kvE2_sepSlotsLOf/ROf` over all owners) | FAITHFUL — but under-cited by the plan (see R1) |
| C4 | Index must be a **linear extension of each owner's region order** (`lXU<lX1<lUW` left, mirror right) | Def 3.1 interior/exterior β structure, md:66–74; the per-chain constraint | `kvE2_sepConsistentTuple` (`i₀<i₁<i₂` per owner) | FAITHFUL |
| C5 | Every position of a new point in the global order is a **separate case** — "for ALL possible positions i" | **§5 / Lemma 5.1**, md:161–173; Insight #2, md:213–219 | enumeration ranges over ALL order-consistent tuple assignments (`a<u'<b` included) | FAITHFUL |
| C6 | Coincidence of a meet point with an endpoint is an **explicit sub-case** (`r_0 = z_0`) | **Lemma 5.3 / §5**, md:151; INF formula md:149 | coincidence order-type + CLOSED `zAtX1L` zone bit (F5) | FAITHFUL |
| C7 | The **model** enters ONLY at realization; Dedekind completeness used in exactly one place (realizing `r_0 = inf{z | P_1(z)}`) | Insight #3, md:221–222; INF/`K+(P_1)(r_0)`, md:145–152 | model-value order deferred to the *witness* layer (task 337); carrier is model-independent | FAITHFUL — this is the 340/337 boundary |

---

## Q1 — Is the per-slot global-index carrier a faithful transcription of Def 3.1 / Lemma 3.2(1)?

**Yes, with a citation-precision caveat.** Def 3.1 (md:63–74) fixes a *single strictly-increasing
chain* `x_0 < … < x_n` over the existentially chosen points, and this chain partitions the linear
order into typed intervals (md:74). A **total order on the full slot multiset** (the per-slot global
index) is exactly this object: one point on the single chain. Lemma 3.2(1) (md:77) supplies the
*enumeration*: merging two owners' interval decompositions is a conjunction of ∃∀ formulas, which is
equivalent to a **disjunction** of ∃∀ formulas — i.e., a disjunction over the order-consistent ways
to interleave the two owners' chains into one global chain. The carrier's two-part shape maps
cleanly:

- **enumeration of order-types** (`kvE2_sepOrderTypes` / `kvE2_sepArr'`) ⟷ the disjunction of Lemma 3.2(1) (C2), and
- **per-slot global index within one order-type** (a `Nodup` linear extension of the per-owner region orders) ⟷ one strictly-increasing chain of Def 3.1 (C1, C4).

This is the correct, model-independent *normal-form* level. The index being an abstract ℕ tuple with
`Nodup` (cross-owner strictness) + per-owner monotonicity (`i₀<i₁<i₂`) is a faithful **finite
encoding of "a linear extension of the union of the per-owner chains."** Nothing about the encoding
reads a model value or a zone bit in the consistency conjunct (F5/LITMUS), matching the paper's
insistence that the normal form is a syntactic object.

**Divergence flag (under-citation, not unsoundness)**: the paper's chain in Def 3.1 is
*single-reference* (one `(z_0,…,z_m)` tuple of free variables). The Lean carrier's union is over
**multiple owners** = multiple reference points, whose proper authority is **Def 7.13**
`(z_0,…,z_k,∞)-∃∀` (md:202) and Lemma 7.14 (md:204), with Lemma 3.2(1) doing the *merge*. The 340
plan's H3 table (plan lines 75–76) grounds the single-chain/linear-extension claim on "Lemma 3.2(1),
md:77" alone; md:77 literally states only "conjunction ≡ disjunction," so the plan (a) attributes the
*chain* content to 3.2(1) when its primary home is **Def 3.1**, and (b) omits **Def 7.13** for the
multi-owner union. The prior 337 report (report 01, §1 and §4 table) gets this split right. The
mathematics of the carrier is faithful; the plan's citation grounding is imprecise and should be
tightened.

## Q2 — How does the paper handle the model-dependent value order in the ⇐ direction? (the crux)

**The paper cleanly separates a model-INDEPENDENT enumeration of order-types from a model-DEPENDENT
realization, and the 340/337 split sits exactly on that seam.**

Rabinovich's translation is a *syntactic equivalence* proven to hold in **all** Dedekind-complete
chains simultaneously (Prop 4.3, md:103–104: every FO formula ≡ a disjunction of ∃∀ formulas;
Prop 3.5, md:87–94: each one-free-variable ∃∀ ≡ a nested Until/Since TL formula). At this level
**no per-model choice is made** — the disjunction of order-types is fixed once and for all. That is
the **carrier** (task 340, `kvE2_sepArr'`), and it is correctly model-independent.

The model enters only when asking *whether a disjunct is true in a concrete M at a point t*. Then
`φ(t)` holds iff **some** disjunct's existential `∃ x_0 < … < x_n (types)` is realized in M — and in
the ⇐ (satisfaction/completeness) direction that existential is discharged by exhibiting **M's actual
points in M's own temporal order**. So the selection is:

- **existential in the statement** ("∃ a realized disjunct"), yet
- **canonically determined once M and the witness points are fixed** — the merged anchors *sorted by
  M's `<`* give exactly one order-type (the distinguished `kvE2_sepModelOrder` / honest arrangement).

Dedekind completeness is invoked in **exactly one place** (Insight #3, md:221–222): to realize the
INF meet point `r_0 = inf{z | P_1(z)}` (md:145–152), with `K+(P_1)(r_0)` covering the limit case. That
is purely a *realization* (per-M) obligation, never a normal-form one.

**Therefore the paper tells us WHERE the model-dependent witness selection must live: at the witness /
realization layer, per-M — i.e., task 337's monotone-witness construction — NOT in the carrier.** The
Phase 5 handoff reasoning in the 340 plan (lines 333–354) — "`kvE2_sepCoincidentOrder` has signature
`qnf → KvE2SepWeakOrder`, no `M`; the honest value order is inherently per-`M`, so the value-faithful
witness is task 337's construction" — is **exactly faithful** to the paper's own model boundary. The
boundary the implementer drew is not an arbitrary Lean convenience; it is Rabinovich's own
formula-level / realization-level seam.

## Q3 — Does the paper admit the `a < u' < b` cross-region interleaving?

**Yes, and admitting it is a faithfulness *repair*, not an over-generalization.** Def 3.1's chain is a
total order over the **union of all chosen points from all merged owners**, constrained *only* by each
owner's internal order (σ: `lXU<lX1<lUW`; τ: mirror). There is no constraint forcing one owner's
points to sit entirely above/below another owner's anchor. Lemma 3.2(1) (md:77) enumerates **all**
order-consistent interleavings, and §5 / Lemma 5.1 makes the case split explicitly "for ALL possible
positions i" of a new point in the global order (md:161–173; Insight #2, md:213–219: "which i the new
point corresponds to"). An interleaving in which σ's interior witness `lUW` (bounded only by
`x1_σ < u < w`, per the honest bound) lands **below** τ's anchor `b = x1_τ` is one such
order-consistent position — hence one of Rabinovich's disjuncts. The Phase-1 gate's concrete tuple
(σ=(0,2,3), τ=(1,4,5): τ.lXU idx 1 interleaved between σ.lXU idx 0 and σ.lX1 idx 2; σ.lUW idx 3 below
τ.lX1 idx 4) is a valid linear extension of both owners' region orders, so it is genuinely one of the
enumerated disjuncts.

Crucially, task 339's region-primary key was the **unfaithful under-approximation**: it *dropped* this
disjunct (report 06's `omega`-refutation). The enrichment restores an order-type the paper's Lemma
3.2(1) enumeration always contained. Admitting it at the carrier level is **sound because the carrier
does not assert it holds** — it asserts only that it is an enumerable order-type; the *model* then
selects which disjunct is realized (Q2). Over-approximation at the normal-form level is precisely what
Lemma 3.2(1) does; soundness is recovered at the witness level (337). Faithful.

## Q4 — Is the per-slot global index the TERMINAL representation?

**Yes at the carrier level.** A total order on the full slot multiset is the *finest* structure Def 3.1
offers: you cannot refine a total order over a fixed finite point set further. The owners' region
structure fixes ≤3 slots per side per owner, so the point set is finite and fixed; a linear extension
of the union is maximally expressive. The region×owner product key (339) was a *coarsening* of this;
the per-slot index reaches the ceiling. So **no fifth carrier layer is needed** — the plan's Phase-1
proof #5 (terminality) is faithful.

Two "finer structures" in the paper that a faithful transcription must still account for — and does,
*outside* the index:

1. **Point/interval types (α_j, β_j)** — Def 3.1 labels not just order but types at points and along
   intervals. The carrier carries these in the `KvE2SepSpikeOrderType` + zone bits (`zXU`/`zUW`
   strict, `zAtX1L` coincident), separate from the index. Present, not missing.
2. **Dedekind-INF meet point / limit case** (md:145–152, 221–222) — `r_0` may be a limit point not in
   the chosen set, and its `r_0 = z_0` coincidence sub-case (md:151). The finite carrier encodes the
   coincidence via the CLOSED `zAtX1L` order-type bit (C6); the *limit realization* (`K+(P_1)(r_0)`)
   is a **witness-level** (per-M, Dedekind-completeness) obligation, not a carrier order-type. This is
   consistent with Q2: the carrier is terminal; the Dedekind realization lives in 337.

So terminality holds for the *carrier*, with the explicit understanding that the Dedekind-completeness
realization obligation is (correctly) deferred to the witness layer — exactly where md:221–222 places
the sole use of completeness.

---

## H4 — Adversarial Self-Verification (attempt to REFUTE the faithfulness verdict)

**Claim Verification Table**

| Claim | Verification / counterexample probe | Method | Confidence |
|-------|-------------------------------------|--------|------------|
| Total order on full multiset ⟷ Def 3.1 single chain | md:63–74 states the chain explicitly; a total order over a fixed finite point set is exactly it | direct paraphrase read (summary) | High |
| Enumeration of order-types ⟷ Lemma 3.2(1) disjunction | md:77 literal; multi-owner merge is a conjunction of the owners' ∃∀ decompositions | direct read + inference | High |
| `a<u'<b` is one of Rabinovich's disjuncts | md:161–173 "for ALL positions i"; only intra-owner order constrains the interleave | direct read + inference | High |
| Model-dependent selection belongs at the witness layer (337), not the carrier | md:221–222 "Dedekind completeness used in exactly one place"; translation is all-chains-simultaneously (md:103–115) | direct read | High |
| Multi-owner union is Def 7.13 territory (plan under-cites) | md:202 `(z_0,…,z_k,∞)`-∃∀; plan cites only Def 3.1 / Lemma 3.2(1) | cross-check plan vs paper | Medium-High |
| Weak-order + coincidence bit does not admit ties the paper forbids | md:151 `r_0=z_0` sub-case; `Nodup` keeps witnesses strict, ties confined to endpoint self-zone | inference; encoding is Agent B's to confirm | Medium |

**Refutations attempted:**

- **R1 (lands — imprecision, not unsoundness)**: The 340 plan attributes the single-global-chain /
  linear-extension claim to "Lemma 3.2(1), md:77," but md:77 states only "conjunction ≡ disjunction."
  The chain content is **Def 3.1** (md:63–74) and the multi-owner union is **Def 7.13** (md:202). The
  carrier is mathematically faithful; the *citation grounding* is loose and should be corrected to
  Def 3.1 (chain) + Lemma 3.2(1) (disjunction/merge) + Def 7.13 (multi-reference union).

- **R2 (residual risk — summary vs PDF)**: The verdict rests on the *summary* paraphrase of Def 3.1.
  The summary flattens whether the free reference points `z_j` are themselves interleaved into the
  chain, the exact exterior-interval `β_0 / β_{n+1}` treatment (md:69–70), and whether the chain is
  literally strict. If the PDF's Def 3.1 places `z_j` inside the chain in a way the carrier's
  slot/owner split does not model, a subtle divergence could exist. **Recommended check**: confirm
  against the PDF that (a) the chain is over the existential witnesses `x_i` with `z_j` as bounding
  reference points, and (b) the multi-owner union corresponds to Def 7.13's `(z_0,…,z_k,∞)` structure.
  This does not currently overturn the verdict; it is the one open H3-rigor gap.

- **R3 (does NOT land — over-admission)**: One might argue admitting `a<u'<b` is unsound over-generalization.
  Rejected: over-approximation at the normal-form level is exactly Lemma 3.2(1)'s behavior; the model
  selects the realized disjunct (Q2), and *not* admitting it (339) was the actual unfaithfulness. The
  only genuine unsoundness would be admitting an interleaving that violates an owner's internal region
  order — prevented by `kvE2_sepConsistentTuple` — but verifying that the `i₀<i₁<i₂ ⟷ lXU<lX1<lUW`
  encoding is correct is **Agent B's territory**, not decidable from the paper. I flag the dependency;
  I do not certify the encoding.

- **R4 (does NOT land — weak vs strict)**: The carrier is a `KvE2SepWeakOrder` with a coincidence bit,
  while Def 3.1's chain is strict. Rejected as a refutation: §5's `r_0 = z_0` sub-case (md:151) shows
  the paper *does* handle endpoint coincidence, realized here via the CLOSED `zAtX1L` bit, while
  `Nodup` on the cross-owner index keeps witnesses strictly ordered. Faithful **provided** the
  coincidence bit is only ever the endpoint-meet case — enforced by F5's CLOSED-only discipline (Agent
  B to confirm the encoding actually restricts it).

**Contradiction log**: none between the paper and the 340/337 boundary decision. The only tension is
R1 (citation imprecision in the plan) and R2 (summary-vs-PDF residual), neither of which reverses the
verdict.

---

## VERDICT

The 340/337 split is **faithful** to Rabinovich (2014). The per-slot global-index carrier — a `Nodup`
total order on the full cross-owner slot multiset that linearly extends each owner's region order
(`lXU<lX1<lUW`) — is a correct finite encoding of Def 3.1's single strictly-increasing chain (md:63–74),
enumerated over all order-consistent interleavings by Lemma 3.2(1) (md:77) and generalized to multiple
owners by Def 7.13 (md:202); it is the **terminal** carrier representation, since a total order on a
fixed finite point set cannot be refined further. The `a < u' < b` cross-region interleaving is one of
Rabinovich's own "for ALL positions i" disjuncts (md:161–173), so admitting it *repairs* task 339's
unfaithful under-approximation rather than over-generalizing. Decisively, the paper tells us **where the
model-dependent witness selection must live**: the translation is a syntactic all-chains-simultaneously
equivalence (md:103–115) whose sole model contact is *realizing* the existential chain — and the INF
meet point — in a concrete Dedekind-complete M (md:221–222), i.e., at the witness layer. That is exactly
task 337's per-M monotone-witness construction, and the Phase-5 handoff (model-independent
`kvE2_sepCoincidentOrder` cannot carry a per-M value order) sits precisely on Rabinovich's formula-level
/ realization-level seam. Two caveats temper the endorsement: (R1) the 340 plan's H3 table mis-grounds
the single-chain claim on Lemma 3.2(1) alone and omits Def 3.1 / Def 7.13 — a citation-precision fix,
not a math error; and (R2) the verdict rests on the summary markdown, so a PDF check of Def 3.1's
reference-point placement and Def 7.13's union is the one outstanding H3-rigor item before the
faithfulness claim is fully closed.
