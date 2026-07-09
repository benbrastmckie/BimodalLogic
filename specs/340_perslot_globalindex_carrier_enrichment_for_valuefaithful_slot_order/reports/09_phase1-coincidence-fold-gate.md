# Task 340 Phase 1 — Coincidence-Fold DESIGN GATE

**Task**: 340 — Per-slot global-index carrier enrichment for value-faithful slot order
**Kind**: DESIGN GATE (paper only; no Lean edited). Reference tier: **Tier 1 (literature, faithful
transcription)**. Session: sess_1783561356_89aa2d_340.
**Sources verified by direct read**: `SharedWitness.lean` (SW) — slots (152-322), engine-facing
carrier (679-1043), coincidence machinery (1640-1996), anchor keystone (2006-2120);
`SubBracket2V.lean` engine (`interleaveK` 453-457, `k1v_stitch_regions` 492, `k1v_realizationK_build`
560-621, `k1v_sorted_realizationK` 633-658); `NormalForm.lean:245` (`nf_eval_unique`);
`NfEFold.lean:162,283` (`nf0_projFresh`, `nf_eval_nf0_cons_factor`); `NavigatedSpine.lean:437`
(LITMUS); Rabinovich 2014 md (Def 3.1 md:61-74; Lemma 3.2(1) md:77; §5/Lemma 5.3 meet md:145-173;
Insight #3 md:221-222).

---

## GATE VERDICT: **PASS** (resolution (a))

The foreign-witness-at-anchor meet folds faithfully through the EXISTING `coincident` tag /
`kvE2_sepCoincidentAnchor_discharge` channel, WITHOUT reopening model-independence of the slot
list. The load-bearing risk (report 08 element 2) is discharged by a fact already proven in the
codebase — the **uniqueness collapse** — which report 08 did not exploit. `kvE2_sepSlotsLFor`
stays a fixed function of σ; `kvE2_sepArr'` membership stays model-independent; the only new
model-dependence is (i) the value-RANK index (already intended by Phase 6's value_j binding) and
(ii) a fold/dedup at the JOINT `kvE2_sepSlotsLOf` layer, which already consumes the
model-dependent `wo` and which mirrors the engine's inherently model-dependent chain length.
Design element 1 (value_j → engine-point binding, no LITMUS literal) is also confirmed. **On this
PASS, Phase 9's approach is fixed (see "Concrete Lean shape" below); implementation phases 2-10
may proceed.**

---

## The load-bearing risk, restated precisely

- Engine `k1v_sorted_realizationK` (SubBracket2V:633-646) emits `interleaveK ps`, a STRICTLY
  increasing chain (`Pairwise (·<·)`). Its `hreal` obligation (`:639`, `:566`) requires every base
  type χ in a region to have a witness **STRICTLY INTERIOR** to that inter-anchor interval
  (`r.1 < u ∧ u < r.2.1`). A type realizable only AT an anchor cannot be fed as a region-interior
  type.
- Carrier `kvE2_sepSlotsLOf wo` (SW:1034) = `(flatMap kvE2_sepSlotsLFor).mergeSort (mergeLe wo)` —
  a mergeSort **permutation** of the fixed union, so its length is model-independent and it cannot
  drop a slot.
- If a base slot `.lUW σ χ` is realizable only at some anchor value `x1_τ`, the engine chain hosts
  `x1_τ` ONCE (as the separator carrying `.lX1 τ`), while the carrier lists TWO slots
  (`.lUW σ χ` and `.lX1 τ`). `halign` (Phase 8 list-equality of carrier slots ↔ engine points)
  then mismatches on length. The lex `(value, slot-index)` tiebreak makes the two slots' RANKS
  distinct (adjacent) but does NOT merge the two M-points — so the tiebreak is **inert** for this
  (report 06 SW:92-98; report 08 Attack 1, both correct).

---

## Why it PASSES — the uniqueness collapse (the fact report 08 missed)

**Claim.** A foreign base type χ (a `.lXU/.lUW/.rWX1/.rX1T` slot of owner σ) can be realized at
another owner τ's fresh anchor `x1_τ` **only if χ = `nf0_projFresh τ.1`** (τ's OWN fresh base
type). This is not a conjecture — it is the contrapositive of a landed, axiom-clean theorem.

**Proof (already in the codebase).** τ's anchor `x1_τ` realizes τ at env `[x1_τ, w, x, t]`; by
`nf_eval_nf0_cons_factor` (NfEFold:283) its unique depth-0 arity-1 base type at `x1_τ` is
`nf0_projFresh τ.1` (SW:1679-1680 extracts exactly this). By `nf_eval_unique` (NormalForm:245,
fully general over depth/arity — hover/read confirmed: any env realizes a UNIQUE normal form), any
χ with `nf_eval_nf M 0 1 (fun _ => x1_τ) χ` satisfies `χ = nf0_projFresh τ.1`. This IS
`kvE2_sepFreshAnchor_ne_baseChiPoint` (SW:1667-1681): `χ ≠ nf0_projFresh σ.1 ⟹ p ≠ x1`. Its own
docstring (SW:1659-1666) names the residual verbatim: "distinct positive owners may carry the same
base type, and a foreign owner's χ-witness may coincide exactly with another owner's fresh anchor."

**Consequences that collapse the whole risk.**

1. **The meet is never an "extra distinct type" at the anchor.** By uniqueness, a point realizes
   at most one base 1-type. Every base slot that meets `x1_τ` carries the SAME type
   `nf0_projFresh τ.1` — which the anchor `.lX1 τ` already realizes. So "multiple foreign witnesses
   at one anchor" (H4 stress) collapses to "several slots, all of the same type, all at `x1_τ`",
   never a multi-type overload. There is nothing new to realize at the meet point.

2. **The existing channel already discharges it — with no `p ≠ x1` obligation.**
   `kvE2_sepCoincidentAnchor_discharge` (SW:1695-1717) takes ANY χ realized at `x1` and proves
   `kvE2_sepBits σ kvE2_sep_zAtX1L χ = true` via the extractor's generic zone-forward channel — the
   Rabinovich §5 meet identification (its docstring cites md:168-173). Because the foreign meet
   forces χ = `nf0_projFresh τ.1`, the FOREIGN meet is literally the SAME discharge already used for
   an owner's OWN fresh-type coincidence in `kvE2_sepCoincidentOwner_valid_left/right`
   (SW:1788-1819) — invoked at τ instead of σ. **No new machinery.** The honest arrangement is
   already the all-`coincident` order `kvE2_sepCoincidentOrder` (SW:1767), whose
   `kvE2_sepArr'`-membership (`kvE2_sepCoincidentOrder_mem_arr'`, SW:1966) is tag-based and
   tuple-agnostic.

3. **`kvE2_sepSlotsLFor` (SW:292) stays a FIXED function of σ.** It is a syntactic filter
   (`kvE2_sepS σ z = Finset.univ.toList.filter (kvE2_sepBits …)`, SW:178) — no M appears. The fold
   does NOT delete any per-owner slot; it operates only on the JOINT ordering.

---

## Where the (bounded, acceptable) model-dependence lives

The fold reconciles length at the **joint** `kvE2_sepSlotsLOf` layer, NOT at `kvE2_sepSlotsLFor`:

| Object | Model-dependent? | Gate impact |
|--------|------------------|-------------|
| `kvE2_sepSlotsLFor σ` (per-owner slot LIST, SW:292) | **NO** (syntactic filter) | PASS criterion met |
| `kvE2_sepArr'` membership of honest `wo` (SW:1966) | **NO** (tag/index-tuple structure) | PASS criterion met |
| value-RANK index `kvE2_sepSlotGIdx` / value_j | YES — **intended** (Phase 6 data-flow inversion, report 08 elt 1) | already accepted |
| joint fold `kvE2_sepSlotsLOf` length | YES — **mirrors the engine's model-dependent chain** | acceptable (already consumes `wo`) |

`kvE2_sepSlotsLOf` is ALREADY the `wo`-consuming, model-dependent object; making its meet-case a
value-keyed **dedup** (collapse adjacent equal-value slots to their anchor representative) is within
the same model-dependence it already has. It does not touch the two objects the gate requires to
stay fixed. The engine chain is model-dependent regardless (it is a list of real M-points); the
folded carrier list simply tracks it. This is the faithful `z_k = x_{i_k}` collapse (Def 3.1's free
reference points `z_j`; §5 sub-case `r_0 = z_0`, md:151), a legitimate disjunct of the Lemma 3.2(1)
enumeration (md:77) — an admitted arrangement, not an unmet obligation.

---

## H3 citation table (faithfulness claim → Rabinovich anchor → Lean site)

| Faithfulness claim | Rabinovich anchor | Lean site | Verdict |
|--------------------|-------------------|-----------|---------|
| A reference/base point may collapse onto a chain point (`z_k = x_{i_k}`); sub-case `r_0 = z_0` explicit | §5 / Lemma 5.3, md:145-152 (**md:151** "r_0 = z_0 or r_0 ∈ (z_0,z_1)"); meet md:168-173 | `kvE2_sepCoincidentAnchor_discharge` (SW:1695) via CLOSED `zAtX1L`/`zAtX1R` | FAITHFUL |
| Two points may share a base 1-type yet occupy distinct chain positions (⇒ per-slot granularity) | Def 3.1, md:65,74 | `KvE2SepSlot` per-slot layer (SW:219, 292) | FAITHFUL |
| Merge = disjunction over order-consistent interleavings; the coincident interleaving is one disjunct | Lemma 3.2(1), md:77 | `kvE2_sepOrderTypes` / `kvE2_sepArr'` (SW:841, 921) incl. `kvE2_sepCoincidentOrder` | FAITHFUL |
| Uniqueness of the type at a point (forces foreign meet ⟹ χ = anchor's fresh type) | (model-theoretic; Def 3.1 single strict chain of typed points) | `nf_eval_unique` (NormalForm:245); `kvE2_sepFreshAnchor_ne_baseChiPoint` (SW:1667) | FAITHFUL |
| Model contact (value order) enters once, at realization; index stays structural | Insight #3, md:221-222 | value_j bound to engine point (Phase 6); enum model-independent | FAITHFUL |
| No relative-position literal | LITMUS (NavigatedSpine.lean:437 "No `x1 < e_i` … introduced") | value order = M.carrier `LinearOrder` over already-extracted witnesses | FAITHFUL (F4) |

---

## Design element 1 — value_j → engine-point binding (confirmed, no LITMUS literal)

The honest order is defined FROM the engine realizer (data-flow inversion, report 08 elt 1):
`value(.lX1 σ) := kvE2_sepAnchorVal σ` (= `x1_σ`, SW:2020); `value(.lUW σ χ) :=` the engine-realized
point for that slot (from `k1v_sorted_realizationK`'s `ps`, or the honest bundle
`kvE2_sepHonestAnchorBundleL/R`); a FOLDED base slot gets `value = x1_τ` (the anchor it meets). The
global index is `kvE2_ordRank G (slotIndexOf s)` with `G j = (value_j, j)`, ranked by M.carrier's
`LinearOrder` over these **already-extracted** M-points. No object-level `x1 < e_i` normal-form
literal is emitted — the comparison is meta-level on realized points, matching the F4/LITMUS
discipline confirmed at NavigatedSpine:437. Consistency (region-monotonicity) is automatic: honest
bundles pin `lXU ∈ (x,x1_σ)`, `lUW ∈ (x1_σ,w)` (report 08 Attack 2 SURVIVES), and a folded slot's
value `x1_τ` lies in `(x1_σ,w)` because χ ∈ σ's zUW region forces `x1_σ < x1_τ < w`.

---

## H4 — adversarial self-verification (worst-case configurations)

**Mandate: construct the worst foreign-witness-at-anchor configuration and try to break the fold.**

| Adversarial configuration | Outcome | Why the fold holds |
|---------------------------|---------|--------------------|
| Multiple foreign witnesses (χ₁,χ₂ of σ) meeting the SAME anchor `x1_τ` | **CANNOT break** | `nf_eval_unique` ⇒ at most one base type per point ⇒ χ₁=χ₂=`nf0_projFresh τ.1`; no multi-type overload; all fold to `x1_τ`'s one position carrying that single type |
| Foreign witness of σ meeting a DIFFERENT owner τ's anchor (σ≠τ) | **CANNOT break** | uniqueness forces χ=`nf0_projFresh τ.1`; identical to τ's own fresh-type coincidence; `kvE2_sepCoincidentAnchor_discharge` at τ closes it (SW:1695) |
| Several distinct owners σ₁,σ₂ each holding a slot for χ=`nf0_projFresh τ.1`, all meeting `x1_τ` | **CANNOT break** | all same type at same point; dedup keeps one anchor representative; each slot's `.holds` discharged at `x1_τ` |
| Fold moves `.lUW σ χ` to `x1_τ` — does it violate σ's region order? | **No** | χ∈σ's zUW ⇒ realizable only in `(x1_σ,w)`; `x1_τ∈(x1_σ,w)` ⇒ `x1_σ<x1_τ`; region-monotone preserved |
| Does dropping χ from engine interior lists break `hnd`/`hreal`/`hpos`? | **No** | χ is simply not fed as an interior type; engine build is strictly SMALLER; anchors stay strictly ordered (keystone `kvE2_sepAnchor_injOn`, SW:2042) |
| Does the fold disturb `kvE2_sepArr'` membership of `wo`? | **No** | membership reads tags + index tuples, not the folded slot list; `kvE2_sepCoincidentOrder_mem_arr'` (SW:1966) reused verbatim |

**Claim Verification Table**

| Claim | Verification method | Confidence |
|-------|---------------------|------------|
| `nf_eval_unique` general over depth/arity | direct read NormalForm:245-250 | High |
| Foreign meet ⟹ χ = `nf0_projFresh τ.1` | `kvE2_sepFreshAnchor_ne_baseChiPoint` read (SW:1667-1681) | High |
| Anchor point's base type IS `nf0_projFresh τ.1` | `nf_eval_nf0_cons_factor` use at SW:1679-1680, 1816 | High |
| `kvE2_sepCoincidentAnchor_discharge` handles ANY χ at the anchor | direct read SW:1695-1717 | High |
| `kvE2_sepSlotsLFor` is a syntactic (model-independent) filter | direct read SW:178, 292-311 | High |
| `kvE2_sepSlotsLOf` is a mergeSort permutation (cannot self-drop) | direct read SW:1034-1036 | High |
| Engine `hreal` demands STRICT interior witnesses | direct read SubBracket2V:566, 639 | High |
| `interleaveK` lists each anchor once (as separator) | direct read SubBracket2V:453-457 | High |
| Honest arrangement is all-`coincident`, membership tuple-agnostic | SW:1755-1782, 1966 | High |
| No `x1 < e_i` literal in value binding | LITMUS NavigatedSpine:437 + meta-level compare | High |

**Contradiction log.** Report 06 R3 ("no carrier change; discharged at 337") vs report 08 element 2
("may reopen model-independence of `kvE2_sepSlotsLFor`"). Resolution by precedence (a landed Lean
theorem outranks a prose risk flag): the uniqueness collapse `kvE2_sepFreshAnchor_ne_baseChiPoint`
(SW:1667) shows the foreign meet is NOT independent slot-order surgery — it forces χ = the anchor's
own fresh type and routes through the SAME existing channel. Report 08's concern is real ONLY if
the fold were placed on `kvE2_sepSlotsLFor`; placed on the already-model-dependent joint
`kvE2_sepSlotsLOf` (a dedup mirroring the engine), `kvE2_sepSlotsLFor` and `kvE2_sepArr'` stay
fixed. **RESOLVED in favour of report 06's "no carrier fork", refined: the joint list dedup is
model-dependent, but `kvE2_sepSlotsLFor` and `kvE2_sepArr'` are not.** No unresolved contradiction.

---

## Concrete Lean shape for Phase 9 (fixed by this PASS)

```lean
-- (1) Fold predicate is DECIDABLE/syntactic at the candidate level: a base slot .lXU/.lUW σ χ
--     is a fold-candidate iff ∃ τ ∈ kvE2_sepPos qnf, χ = nf0_projFresh τ.1.
--     (Whether it FIRES is model-witnessed: χ realized only at x1_τ. By nf_eval_unique the
--      type identity is forced, so the fold target is unambiguous.)

-- (2) value_j binding (Phase 6) already assigns a folded base slot the anchor's value x1_τ,
--     so under kvE2_ordRank G the folded slot and .lX1 τ share the M-VALUE (distinct lex ranks,
--     but adjacent). The fold is therefore a value-keyed collapse of that adjacent pair/run.

-- (3) Model-dependent JOINT folded list (mirrors interleaveK ps length); kvE2_sepSlotsLFor UNCHANGED:
noncomputable def kvE2_sepSlotsLOf_folded {sig} (wo) (M …) : List (KvE2SepSlot sig) :=
  -- keep the anchor representative of each value-class; drop base slots whose value equals an anchor's
  (kvE2_sepSlotsLOf wo).foldForValueMeets …    -- collapse runs with equal realized M-value

-- (4) halign (coincidence case, Phase 9) — a Forall₂ correspondence, NOT raw list equality:
theorem halignL_fold {sig} (qnf M w x t h) (ps) (hps : … from k1v_sorted_realizationK) :
    List.Forall₂ (fun s p => nf_eval_nf M 0 1 (fun _ => p)
                              (kvE2_sepSlotBaseType s))
      (kvE2_sepSlotsLOf_folded (kvE2_sepHonestOrder qnf M w x t h) M …)
      (interleaveK ps)
-- folded-away base slots' .holds discharged AT the anchor via
--   kvE2_sepCoincidentAnchor_discharge τ M x1_τ w x t … χ hp   (χ = nf0_projFresh τ.1, by uniqueness).
```

Phase 8 proves the coincidence-FREE case (`kvE2_sepSlotsLOf_folded = kvE2_sepSlotsLOf`, a plain
permutation, list-equality with `interleaveK ps`); Phase 9 extends to the meet case via the fold
above. If, contrary to this analysis, an implementation attempt finds the fold cannot be confined to
the joint layer (i.e. `kvE2_sepSlotsLFor` or `kvE2_sepArr'` membership is forced model-dependent),
that is a Phase-1-gate regression and MUST escalate — not be papered with a `sorry`/placeholder.

---

## Memory candidates

1. In this weak-canonical construction, a foreign depth-0 base type χ coincides with another
   owner's fresh anchor `x1_τ` ONLY IF χ = `nf0_projFresh τ.1` — forced by `nf_eval_unique`
   (NormalForm:245) via `kvE2_sepFreshAnchor_ne_baseChiPoint` (SW:1667). The §5 `z_k = x_{i_k}` meet
   is therefore never a multi-type overload; the existing `kvE2_sepCoincidentAnchor_discharge`
   (SW:1695) channel absorbs it with no new machinery.
2. A meet-type fold can preserve carrier model-independence by placing the fold on the JOINT,
   `wo`-consuming, already-model-dependent list (`kvE2_sepSlotsLOf`, a dedup mirroring the engine
   chain) rather than on the per-owner syntactic slot list (`kvE2_sepSlotsLFor`) or the
   `kvE2_sepArr'` membership — the two objects that must stay model-independent.
3. The engine `hreal` (SubBracket2V:566/639) demands STRICT interior witnesses, so a type
   realizable only at an anchor is simply not fed to any region — the engine build shrinks, and the
   carrier fold (not an engine double-count) is what reconciles `halign` length.

**GATE VERDICT: PASS (resolution a).** Fold mechanism: uniqueness-collapse ⇒ existing
`coincident`/`kvE2_sepCoincidentAnchor_discharge` channel ⇒ model-dependent dedup confined to the
joint `kvE2_sepSlotsLOf`; `kvE2_sepSlotsLFor` and `kvE2_sepArr'` membership stay fixed; value-rank
model-dependence is intended. Grounded in Rabinovich §5 (md:151, 168-173) + Lemma 3.2(1) (md:77).
Design element 1 confirmed (value_j←engine point; no `x1 < e_i` LITMUS literal).
