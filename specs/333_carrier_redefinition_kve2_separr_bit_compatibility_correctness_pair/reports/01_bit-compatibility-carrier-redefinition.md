# Research Report: Bit-Compatibility Carrier Redefinition of `kvE2_sepArrL`/`kvE2_sepArrR` (task 333)

- **Task**: 333 - carrier_redefinition_kve2_separr_bit_compatibility_correctness_pair
- **Type**: lean4
- **Session**: sess_1783522894_0a5276
- **Predecessor**: task 321 (F4 correctness gate — closed as scoped PARTIAL, N2 verdict)
- **Date**: 2026-07-08

## Executive Summary

Task 321 reached a scoped PARTIAL closing the k=2 correctness gate on the *single-positive-sub*
fragment (N2 verdict) with **two tracked strategic sorries** remaining. Both, plus the deferred
multi-positive fragment, route to the SAME fix that this task must implement: **redefine the
interleaving-enumeration filter `kvE2_sepValid` (and consequently `kvE2_sepArrL`/`kvE2_sepArrR`)
with bit-compatibility filtering**, so that the disjunct enumeration only admits arrangements
whose per-interval segment content is compatible with every positive sub's fold-bit content.

**Verified build state (this research):** `lake build
Theories.Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness` returns
**exit 0** (green). The module (`SharedWitness.lean`, 1954 lines) contains **exactly two
`sorry`s** — at line **1820** (`kvE2_sepSingleton_coverage_left`) and line **1952**
(`kvE2_sepBody_singleton_complete_left`). The `git status --short` over the entire file_scope is
**clean** (do-not-edit assets byte-identical; HEAD = `443684ae6`, task 332 completion).

**The core obstruction (from the O4 CRUX RECORD, `SharedWitness.lean:1562-1655`):** the current
`kvE2_sepValid` (`:332`) is *arrangement-blind* — it filters permutations only by each σ's own
internal region-rank order and leaves **cross-σ slot placement completely free** (`kvE2_sepSlotLe`,
`:327-329`: "slots of different σ are unconstrained"). Consequently an admitted arrangement can
place τ's `zXU`-χ slot below σ's fresh slot, forcing a realized model point `v` with `x < v < x1`
carrying χ, at which the `hgate` forward-zone conjunct demands
`σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true` — a bit the carrier has **no channel** to supply
(all four gate clauses conclude `= false`; segments cover only open sub-intervals, never witness
points; the biconditional literals cover only at/exterior zones). The faithful repair, grounded
in **Rabinovich 2014 Lemma 3.2(1)** (the conjunction↔disjunction equivalence ranges over
*consistent interval-decomposition refinements*), is to admit an arrangement only when every
cross-σ slot placement matches a true bit of every other interior positive.

This redefinition **kills the current non-vacuity proof** (`kvE2_sepBody_nonvacuous`, `:918`,
which relies on the canonical identity interleaving always being admitted) and forces knock-on
rework of the O2/O3 membership/extraction plumbing. Non-vacuity must be re-established by
witnessing the *specific* bit-compatible arrangement that an honest model realizes.

---

## 1. Task 321 Lineage: What the Additive Path Exhausted

### 1.1 The route that landed (Phases 1-11, v7 plan)

The v7 "faithful separate-bracket" plan
(`specs/321_.../plans/07_v7-faithful-separate-bracket.md`) built a model-independent joint
carrier `kvE2_sepBody` (`SharedWitness.lean:551`) whose disjuncts are single FLAT brackets over
the joint interleaving product `kvE2_sepArrL × kvE2_sepArrR`. Phases 1-10 landed sorry-free:
- **Phase 7 (O1/O1b/O2):** carrier + non-vacuity + membership collapse (`:551`, `:918`, `:579`).
- **Phase 8 (O3):** shared-`w` + per-σ bundle extraction (`kvE2_sepDisjunct_extract` `:1232`,
  `kvE2_sepBody_extract` `:1369`, `kvE2_sepDisjunct_halves` `:1328`).
- **Phase 9 (O4):** derivable core (`kvE2_sep_zone4_consistent`, `kvE2_sepHgate_offFiber`,
  `kvE2_sepHgate_innerNine`, `kvE2_sepSegForm_excludes`) — but **O4 verdict FAIL** (crux
  record `:1562-1655`).
- **Phase 10:** decision gate → **N2 verdict** (single-positive-sub fragment).
- **Phase 11 (N2-A/N2-B):** singleton wrapper closed sorry-free; N2-B skeleton landed green
  with two tracked strategic sorries.

**Phases 12 (N2-C gate wrapper) and 13 (F4 adversarial + verdict record) are `[NOT STARTED]`.**

### 1.2 Why the additive path structurally could not close

The O4 CRUX RECORD (`:1562-1655`) and the three N2-B CRUX ADDENDA (`:609-768` in the plan;
`:1720-1795` inline) establish, with verbatim captured `lean_goal`s and five failed closers, that:

1. **Cross-σ obstruction (multi-positive):** for distinct left-interior positives σ ≠ τ with τ's
   `zXU`-χ slot interleaved below σ's fresh slot, the forward-zone conjunct
   `σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true` is *underdetermined* by the realized carrier
   (channel-exhaustion argument, `:1606-1616`). No **additive** gate clause repairs it:
   - a **conjunctive** cross-σ clause is sound-sufficient but breaks honest-derivability /
     non-vacuity (FM-vac, prohibited) — `:1618-1623`;
   - a **disjunctive** clause is *arrangement-blind* while the placement is arrangement-chosen —
     `:1624-1626`.
   - **The faithful repair is bit-compatibility FILTERING of the interleaving enumeration**
     (`:1627-1634`).
2. **∀-anchor obstruction (cross-σ-independent, survives at singleton size):** the six-conjunct
   `hgate` that all three landed soundness closers (`kvE_subBracket2V_sound`,
   `_sound_of_parts` `:1025`, `_sound_of_outer` `:1216`) demand is a **∀-anchor** statement whose
   conjunct `a < w` binds *every* `a ∈ (x,t)` realizing the `charK` anchor — FALSE at singleton
   size (`:1636-1642`). Task 321 *dissolved* this via `kvE2_sepSingleton_sound_of_parts_at`
   (`:1838`, sorry-free, axiom-clean), which consumes the six conjuncts only at the single
   extracted `x1`.

### 1.3 The exhaustion verdict (task 321 handoff, verbatim)

From `specs/321_.../.orchestrator-handoff.json`: "additive N2 single-dispatch close is
EXHAUSTED... the residue is provable-in-principle but requires a **six-piece coverage
construction** that decisively exceeds one additive dispatch... the clean uniform route is the
OUT-OF-SCOPE **bit-compatibility carrier redefinition of `kvE2_sepArrL`/`kvE2_sepArrR`**." The
handoff offered two options: (A) commission the six-piece coverage as a multi-dispatch follow-up,
or (B) escalate the bit-compatibility redefinition as a named successor task. **Task 333 IS option
B** — and per this task's own description, the redefinition subsumes BOTH the coverage residue and
the multi-positive fragment, because a bit-compatibility-filtered enumeration makes the
per-interval segment content align with per-zone σ exclusion so `h_fwd`/`h_bwd` follow uniformly
(the coverage lemma's six pieces 2-5 collapse).

---

## 2. Current Arrangement-Blind Definitions (What a Redefinition Must Replace)

All in `SharedWitness.lean`. **These are NOT do-not-edit** — `SharedWitness.lean` is task 321's
own additive file, so task 333 may edit it freely (it is the sole owner). The DO-NOT-EDIT
discipline binds only the imported `SubBracket2V`/`NavigatedSpine`/sibling-Kamp assets.

### 2.1 The validity relation and filter (the redefinition target)

```
kvE2_sepSlotLe (a b : KvE2SepSlot sig) : Bool           -- :327-329
  := !(decide (kvE2_sepSlotSub a = kvE2_sepSlotSub b))   -- distinct σ ⇒ unconstrained
     || decide (kvE2_sepSlotRank a ≤ kvE2_sepSlotRank b) -- same σ ⇒ non-decreasing rank

kvE2_sepValid (l : List (KvE2SepSlot sig)) : Bool        -- :332-333
  := decide (l.Pairwise (fun a b => kvE2_sepSlotLe a b = true))

kvE2_sepArrL qnf := (kvE2_sepSlotsL qnf).permutations.filter kvE2_sepValid  -- :338-340
kvE2_sepArrR qnf := (kvE2_sepSlotsR qnf).permutations.filter kvE2_sepValid  -- :343-345
```

**The defect is in `kvE2_sepSlotLe`'s first disjunct**: `!(sub a = sub b)` makes *any* cross-σ
ordering valid. Bit-compatibility filtering must ADD a cross-σ constraint: when slot `a` (owned by
τ, realizing χ in some region) precedes σ's fresh slot `.lX1 σ` (or sits in σ's region generally),
τ's placement must correspond to a **true** σ-bit for that (zone, χ) — i.e.
`kvE2_sepBits σ (region-of-a-relative-to-σ) χ = true`.

### 2.2 Supporting structure the filter reads

- **`KvE2SepSlot`** inductive (`:219-228`): 8 constructors; `l*` = left-interior σ slots,
  `r*` = right-interior σ slots; `lX1`/`rX1` are the fresh-witness E[Σ]-atom slots.
- **`kvE2_sepSlotSub`** (`:231`), **`kvE2_sepSlotRank`** (`:245-253`): owner and region rank.
- **`kvE2_sepBits σ zs χ := σ.2 (nf0_assemble zs χ σ.1)`** (`:152-154`): the fold-bit read — the
  quantity the compatibility filter must consult for cross-σ slots.
- **`kvE2_sepS σ zs`** (`:178-180`): the bit-TRUE 1-type enumeration (`filter kvE2_sepBits`) — σ's
  OWN slots are built from this, so σ-own slots are always bit-compatible by construction; only
  cross-σ placements need the new filter.
- **`kvE2_sepSlotsLFor`/`RFor`** (`:292-311`): per-σ canonical region blocks.
- **`kvE2_sepSlotsL`/`R`** (`:315-322`): joint `flatMap` over `kvE2_sepPos qnf`.
- **Zone constants** `kvE_sub2_zXU`/`zUW`/`zWT` (consumed from `SubBracket2.lean:123-133`),
  right-interior `kvE2_sep_zWX1` (`:109`), self/boundary/exterior zones (`:112-144`). The
  **placement-generic** reading (`:98-106`) is essential: `kvE_sub2_zXU` means "`x < v < x1`" for
  left-interior σ but "`x < v < w`" for right-interior σ — the filter must key on σ's outer zone
  class `nf0_zoneSpec σ.1`.

### 2.3 The refined-segment content (the compatibility target)

The segment content `kvE2_sepSegLForSub` (`:427-435`) / `kvE2_sepSegRForSub` (`:440-448`) already
keys σ's per-interval exclusion on **whether σ's fresh slot precedes the cut**
(`(lL.take i).contains (.lX1 σ)`). Bit-compatibility filtering makes this per-interval content
*consistent* across all σ simultaneously: an admitted arrangement is one where every cut's segment
conjunction is jointly realizable — which is exactly Rabinovich Lemma 3.2(1)'s "consistent
refinement" (see §6).

---

## 3. The Non-Vacuity Proof a Redefinition Breaks (Must Be Re-established)

`kvE2_sepBody_nonvacuous` (`:918-938`, and its two-level dependency chain) is the FM-vac guard:
an honest realization forces the gate-true branch with a NON-empty disjunct list.

**Current proof structure (why it breaks):**
- `kvE2_sepGate_holds_of_honest` (`:849-909`) — the gate holds honestly. **This survives**
  a filter change (the gate `kvE2_sepGate` `:532` is not redefined; only the *enumeration filter*
  is). Consumes `kvE_subBracket2V_gate_holds_of_honest` (`SubBracket2V.lean:1392`),
  `nf_eval_depth1_fold_iff` (`CarrierKv.lean:466`), `kvE2_sep_zone3_consistent` (`:775`).
- **The break point:** `kvE2_sepBody_nonvacuous` (`:926-938`) exhibits membership of a specific
  disjunct by using the **canonical identity interleaving** — `List.Perm.refl _` +
  `kvE2_sepSlotsL_valid qnf` (`:722`) / `kvE2_sepSlotsR_valid qnf` (`:734`). Those two `_valid`
  lemmas prove `kvE2_sepValid (kvE2_sepSlotsL qnf) = true` for the identity arrangement. **Under
  bit-compatibility filtering the identity arrangement is no longer necessarily admitted**
  (crux record `:1631`), so `kvE2_sepSlotsL_valid`/`_valid` become FALSE as stated and the
  membership witness must change.

**Re-establishment strategy (for the planner):** non-vacuity must witness the *honest* arrangement
— the interleaving that matches the actual model's witness ordering. From an honest realization
`nf_eval_nf M 2 3 [w,x,t] qnf`, each positive σ produces a fresh witness `x1_σ` and its bit-true
1-types are realized at genuine model points ordered by `<`. That real ordering induces a specific
permutation of `kvE2_sepSlotsL qnf` that (a) respects each σ's internal rank and (b) is
bit-compatible (each cross-σ slot sits in a region where its owner's bit is true, because it is
realized at a real model point carrying that 1-type). This is a **new lemma**: "the honest
witness-order arrangement passes the redefined `kvE2_sepValid`," replacing
`kvE2_sepSlotsL_valid`/`_valid`. The supporting `flatMap`-pairwise machinery
(`kvE2_sep_pairwise_flatMap` `:611`, `kvE2_sepSlotLe_of_rank` `:631`, `_of_sub_ne` `:637`)
partially survives but the cross-σ totality lemma (`kvE2_sepSlotLe_of_sub_ne`, used at `:730`/`:742`)
is exactly what no longer holds unconditionally.

---

## 4. The Two Strategic Sorries

### 4.1 `kvE2_sepSingleton_coverage_left` (`SharedWitness.lean:1796-1820`, sorry @ 1820)

The single-anchor coverage residue. Full signature at `:1796-1819`. Produces three conjuncts AT
the single extracted anchor `x1` (NOT ∀-anchor):
```
h_atom : nf_eval_nf M 0 4 [x1,w,x,t] σ.1
h_fwd  : ∀ zs χ, (∃ v, zoneHolds M [x1,w,x,t] zs v ∧ nf_eval_nf M 0 1 (fun _=>v) χ)
                 → σ.2 (nf0_assemble zs χ σ.1) = true
h_bwd  : ∀ zs χ, zs ≠ kvE_sub2_zXU → σ.2 (nf0_assemble zs χ σ.1) = true
                 → ∃ v, zoneHolds M [x1,w,x,t] zs v ∧ nf_eval_nf M 0 1 (fun _=>v) χ
```
Consumed by `kvE2_sepSingleton_sound_of_parts_at` (`:1838`, sorry-free) inside
`kvE2_sepBody_singleton_sound_left` (`:1891`, wired at `:1920-1924`). Task 321 verdict: these are
true and provable-in-principle from the realized carrier `h`, but assembling them verified-green
needs **six interlocking pieces** (ADDENDUM-2, `:735-757` in plan):
1. **segment-surfacing extraction** — `kvE2_sepDisjunct_extract` (`:1232`) DISCARDS the segment
   realizations (`obtain ⟨ws, hmono, hrange, hpt, -, -, -⟩` at `:1259` — the last three
   `IntervalPattern.holds` components dropped); segments live only in the raw
   `IntervalPattern.holds` or via `kvE2_sepDisjunct_halves` (`:1328`);
2. **point→interval location map** (LITMUS-constrained: read slot INDICES, never `x1 < e_i`);
3. **bracket-segment→σ-`segForm` refinement** (`kvE2_sepSegLForSub` `:427`);
4. **depth-0 1-type mutual-exclusivity lemma** (witness-point case);
5. **exterior/boundary decoder** (endpoint predicates `kvE2_sepEpL` `:354` / `kvE2_sepEpR` `:376`
   cover exterior zones not tiled by segments);
6. **`h_bwd` witness construction**.

**Impact of the redefinition:** with bit-compatibility filtering, pieces 2-5 "collapse" (task
description; ADDENDUM-2 `:763-765`) — the per-interval segment content is aligned with per-zone σ
exclusion by construction, so `h_fwd`/`h_bwd` follow uniformly. This is the central efficiency
claim the planner must validate: the redefinition is not just for the multi-positive case; it is
the clean route to discharging THIS singleton sorry too.

### 4.2 `kvE2_sepBody_singleton_complete_left` (`SharedWitness.lean:1939-1952`, sorry @ 1952)

The O6 completeness lift. Full signature at `:1939-1951`. From σ's depth-1 realization at a shared
`w` (produced by the landed `kvE_subBracket2V_complete` `SubBracket2V.lean:1465`), rebuild the
joint carrier's `.holds` at singleton size — i.e. construct the single realized disjunct of the
(degenerate) interleaving product (the O2 arrangement realization). Task 321 deferred this as a
"self-contained assembly outside the extraction dispatch's scope." Under the redefinition, the
admitted arrangement for the honest model is uniquely determined by the witness ordering, so the
"which disjunct is realized" question has a canonical answer (dovetails with the §3 non-vacuity
re-establishment).

---

## 5. Phase 12 (N2-C) and Phase 13 (F4) Requirements

### 5.1 Phase 12 — gate wrapper (currently `[NOT STARTED]`)

**Goal** (v7 plan `:770-808`): discharge `BracketCarrierCorrectVPrior`
(`PriorInterface.lean:60`) — either the full multi-positive statement (if the redefinition
delivers it) or, minimally, the singleton fragment
`kvE2_sepBody_correct_singleton`. The predicate (grounded, read from `PriorInterface.lean`) is:
```
BracketCarrierCorrectVPrior atomMap carrier :=
  ∀ qnf (6 order hyps h_xy/h_yt/h_xt/h_yx/h_ty/h_tx) M h_UZ h_SZ x t,
    (carrier qnf).holds M atomMap x t ↔
      ∃ w, nf_eval_nf M k 3 (Fin.cons w (Fin.cons x (fun _=>t))) qnf     -- k = 2 here
```
Note: the predicate is stated over a `BracketEndCharCarrierV sig k`, whereas `kvE2_sepBody`
produces a `VVecEA2` directly. The wrapper must either bridge `VVecEA2` into the carrier framing
or state the biconditional in the same shape. The two directions are exactly
`kvE2_sepBody_singleton_sound_left` (`:1891`) + `kvE2_sepBody_singleton_complete_left` (`:1939`)
once their sorries are discharged. Tasks: depth-2 unfold via `nf_eval_nf`
(`NormalForm.lean:198-207`); atom-layer reconstruction at `[w,x,t]` **re-derived additively per
D2** (do NOT de-privatize `k1v_reconstruct_nf3` `CarrierK1V.lean:918`; `nf_eval_depth1_fold_iff`
`CarrierKv.lean:466` is the available fold reference). FM-vac: honest antecedent, not a vacuity
device.

### 5.2 Phase 13 — F4 `ℤ` adversarial + integrity sweep + verdict record (`[NOT STARTED]`)

**Goal** (v7 plan `:810-848`): instantiate the F4 `ℤ` counterexample
(`M=ℤ`, `p={0}`, `r={13}`, `x=10`, `t=20`, `σ''=char[14,16,11,20]` vs honest `char[14,15,10,20]`
marked false) against `kvE2_sepBody` and prove the LHS is FALSE at `(10,20)`. **The test MUST
discriminate**: if the LHS still holds, completeness lost the `σ.2` dependence → reopen Phase 11;
NEVER weaken the test. The F4 counterexample is a single-σ discriminator, so it runs meaningfully
regardless of FULL vs N2 scope. Then land the final GO/NO-GO verdict record (F1-F4 house style)
and the full integrity sweep (build green, additive diff, byte-identical do-not-edit assets, no
sorry on any live path, axiom-clean via `lean_verify`, LITMUS grep + no-nesting audit). The GO
verdict unblocks task 309 Phase 13.4 and the `KampPrior.lean:351` strategic-sorry hook rewire
(both downstream, out of scope).

---

## 6. Faithfulness Constraints (Binding, from task 321)

Grounded against `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`:

- **Lemma 3.2(1)** (md:77): "Conjunction of exists-forall formulas is equivalent to a disjunction
  of exists-forall formulas." The exists-forall form (md:65-72) is an **interval decomposition**
  (md:74): existentially chosen points partition the chain into intervals, each labeled by a
  quantifier-free type. The disjunction of Lemma 3.2(1) therefore ranges over the **consistent
  interleavings** of the conjuncts' chosen points — a refinement is admissible iff each resulting
  sub-interval's label is jointly consistent with every conjunct's interval type there. **This is
  the literature warrant for bit-compatibility filtering**: dropping an arrangement whose slot
  placement forces an inconsistent per-interval label is faithful to Lemma 3.2(1), not an ad-hoc
  restriction. Cite md:77 at the redefined filter.
- **Lemma 5.1** (md:134-135, quantifier-free point types md:68-72): point types remain
  `charBase χ` (depth-0) / `charK (nfk_projFresh σ)` (E[Σ]-atom) ONLY — no `fChainPred`, no
  bracket-in-bracket (no-nesting, `NavigatedSpine.lean:43-48`). The redefinition must NOT
  introduce nested structure into point types; it constrains only which permutations are enumerated.
- **LITMUS** (no `x1 < e_i` relative-position literal on any live path): the compatibility filter
  reads arrangement slot **indices** and **fold bits** (`kvE2_sepBits`), never a model-order
  literal between the fresh witness and a slot. This is explicitly satisfiable — the obstruction
  is "a missing arrangement-bit compatibility constraint, not a positioning literal"
  (crux record `:1644-1645`).
- **No-nesting audit**: every point-type position is `charBase χ` or `charK (nfk_projFresh σ)`.
- **Anchor cap 2** (Lemma 3.2(2), md:78): everything over the two free variables `(x, t)`.
- **Zero-debt**: NO new sorries, NO `sorry` deferral, NO new axioms. Final state must be
  axiom-clean `[propext, Classical.choice, Quot.sound]` and sorry-free on all live paths.

---

## 7. Suggested Phasing Guidance for the Planner

This is a **carrier RE-DEFINITION** (not additive), so the plan cannot be strictly append-only
within `SharedWitness.lean` — but it remains confined to `SharedWitness.lean` (+ its existing
umbrella import). Suggested phase decomposition:

1. **Redefine `kvE2_sepSlotLe`/`kvE2_sepValid`** with the cross-σ bit-compatibility clause.
   Define the compatibility predicate: a slot owned by τ realizing χ, when placed in a region
   relative to another positive σ, must satisfy `kvE2_sepBits σ (σ-relative-zone) χ = true`.
   Re-key on `nf0_zoneSpec σ.1` for placement-generic reading. Verify `kvE2_sepArrL`/`ArrR`
   still compute. (Stopping condition: definitions type-check, `lake build` green.)
2. **Re-establish non-vacuity** (`kvE2_sepBody_nonvacuous` analog): prove the honest
   witness-order arrangement passes the redefined `kvE2_sepValid`, replacing
   `kvE2_sepSlotsL_valid`/`_valid` (`:722`/`:734`). This is the FM-vac gate — highest-risk phase.
3. **Repair O2/O3 plumbing**: `kvE2_sepBody_holds_iff` (`:579`), `kvE2_sepDisjunct_extract`
   (`:1232`, likely needs the segment realizations SURFACED now, not discarded at `:1259`),
   `kvE2_sepBody_extract` (`:1369`), membership lemmas (`:1187`/`:1196`/`:1205`/`:1214`).
4. **Discharge `kvE2_sepSingleton_coverage_left`** (`:1796`) — with the redefinition, the six-piece
   coverage collapses; `h_fwd`/`h_bwd` follow from the now-consistent per-interval segments.
5. **Discharge `kvE2_sepBody_singleton_complete_left`** (`:1939`) — O6 single-disjunct realization
   at the honest arrangement.
6. **Lift to full multi-positive** correctness pair (the deferred fragment) — both directions
   over ≥2 interior positives.
7. **Phase 12 (N2-C→FULL gate wrapper)**: `BracketCarrierCorrectVPrior` discharge.
8. **Phase 13 (F4 adversarial + verdict record + integrity sweep)**.

**Per-phase invariants:** `lake build` green; `lean_verify` axiom-clean on new symbols; LITMUS
grep (`grep -nE "fChainPred|x1[[:space:]]*<[[:space:]]*e"`) 0 live hits; no-nesting audit;
`git diff --stat` touches only `SharedWitness.lean` (+ umbrella if needed).

---

## 8. Risk Register

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| Non-vacuity re-establishment (Phase 2) fails — honest arrangement not expressible as a single admitted permutation | HIGH (this is the new make-or-break) | The honest model DOES induce a real total order on all witnesses; the induced permutation is bit-compatible by construction (each slot realized at a real point carrying its 1-type). If it cannot be shown to pass the filter, the filter is too strong — re-examine the compatibility predicate. Do NOT weaken to a vacuous filter. |
| Redefined `kvE2_sepValid` breaks `Decidable`/computability of the `filter` | MEDIUM | Keep the compatibility clause `Bool`-valued and `decide`-based (as the current `kvE2_sepSlotLe`); `kvE2_sepBits` is already `Bool`. |
| O2/O3 plumbing rework larger than expected (extract must now surface segments) | MEDIUM | The segment realizations already exist in the raw `IntervalPattern.holds` (dropped at `:1259`); surfacing them is a signature change to `kvE2_sepDisjunct_extract`, not new mathematics. |
| Coverage collapse (Phase 4) does not actually follow from the redefinition | MEDIUM | Validate the collapse claim early (Phase 1 sanity check on a 2-positive instance) before committing to the full plan; ADDENDUM-2 `:763-765` asserts it but task 321 did not execute it. |
| Multi-positive lift (Phase 6) hits a NEW cross-σ obstruction not seen at singleton | LOW-MEDIUM | The redefinition was designed precisely against the cross-σ crux; but the ∀-anchor obstruction (§1.2.2) must still be dissolved per-σ via the `_sound_of_parts_at` pattern (`:1838`) generalized to multiple anchors. |
| F4 test (Phase 13) fails to discriminate against the new carrier | LOW | If LHS-TRUE, completeness lost `σ.2` dependence → reopen completeness; never weaken the test (v7 plan `:847`). |

---

## 9. Ground-Truth Reference Index (all verified this session)

| Symbol / fact | Location |
|---|---|
| `kvE2_sepValid` / `kvE2_sepSlotLe` (redefinition target) | `SharedWitness.lean:327-333` |
| `kvE2_sepArrL` / `kvE2_sepArrR` | `SharedWitness.lean:338-345` |
| `kvE2_sepBody` (carrier) | `SharedWitness.lean:551-561` |
| `kvE2_sepGate` (depth-2 gate, unchanged) | `SharedWitness.lean:532-540` |
| `kvE2_sepBody_nonvacuous` (breaks) | `SharedWitness.lean:918-938` |
| `kvE2_sepSlotsL_valid` / `_valid` (canonical-identity, breaks) | `SharedWitness.lean:722` / `:734` |
| `kvE2_sepBits` (fold-bit read for filter) | `SharedWitness.lean:152-154` |
| `kvE2_sepS` (bit-true 1-type enum) | `SharedWitness.lean:178-180` |
| `kvE2_sepSegLForSub` / `RForSub` (per-interval σ exclusion) | `SharedWitness.lean:427` / `:440` |
| `kvE2_sepDisjunct_extract` (discards segments @ :1259) | `SharedWitness.lean:1232` |
| `kvE2_sepDisjunct_halves` (surfaces bracket halves) | `SharedWitness.lean:1328` |
| **Sorry 1** `kvE2_sepSingleton_coverage_left` | `SharedWitness.lean:1796` (sorry @ 1820) |
| `kvE2_sepSingleton_sound_of_parts_at` (∀-anchor dissolver, sorry-free) | `SharedWitness.lean:1838` |
| `kvE2_sepBody_singleton_sound_left` (forward, wired) | `SharedWitness.lean:1891` |
| **Sorry 2** `kvE2_sepBody_singleton_complete_left` | `SharedWitness.lean:1939` (sorry @ 1952) |
| **O4 CRUX RECORD** (bit-compatibility fix rationale) | `SharedWitness.lean:1562-1655` |
| `BracketCarrierCorrectVPrior` (Phase 12 target) | `PriorInterface.lean:60` |
| `kvE_subBracket2V_sound_of_parts` (consumed) | `SubBracket2V.lean:1025` |
| `kvE_subBracket2V_complete` (consumed for O6) | `SubBracket2V.lean:1465` |
| `kvE_subBracket2V_correctness_pair` (per-σ kit) | `SubBracket2V.lean:1855` |
| v7 plan (Phases 12/13 + N2 appendix + crux addenda) | `specs/321_.../plans/07_v7-faithful-separate-bracket.md` |
| Rabinovich Lemma 3.2(1) (filter warrant) | `rabinovich_2014/...md:77` |
| Rabinovich Lemma 5.1 (quantifier-free point types) | `rabinovich_2014/...md:72, :134` |

**Note on file_scope path**: the task's third file_scope entry
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/SubBracket2V.lean` does not exist at that path;
the actual file is at `.../Kamp/NfMultiAnchorBridge/SubBracket2V.lean` (covered by the directory
entry). No `SubBracket2V.lean` exists directly under `Kamp/`.

**Concurrency**: do NOT run this task concurrently with 321/332 (file_scope overlap on
`SharedWitness`/`NfMultiAnchorBridge`). Task 332 is COMPLETED (HEAD); task 321 is closed PARTIAL.
Tree is clean — safe to proceed.
