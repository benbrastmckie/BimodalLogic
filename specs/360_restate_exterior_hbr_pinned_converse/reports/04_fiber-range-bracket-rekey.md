# Report 04 — Fiber-Range Bracket Re-Key (Phase 3c adjudication)

**Task**: 360 · **Session**: sess_1783950096_9d2925 · **Agent**: lean-research-hard-agent
**Date**: 2026-07-13 · **Blocker**: THIRD machine-refuted defect (`hslice*` supply pair FALSE as
shaped, phase-5 handoff) · **Mode**: hard (H3 Tier 1 literature-backed + Tier 3 frozen-template;
H4 adversarial verification against the ℤ-doppelgänger)

## Verdict (one paragraph)

The fiber-range re-key — restrict the depth-`k` exterior bracket range from admissible-only to
`kvE_{fut,past}Admissible σ && decide (nfk_dropFresh σ = qnf.1)` — is **FAITHFUL** (to both the
frozen k=2 template and Rabinovich's Def 7.13 single-disjunct segment discipline), and it is
**CONSUMER-COMPLETE: YES, machine-verified** — the decisive risk (the gate's ⇒-side `hexclExt`
discharge losing coverage of off-fiber bit-false σ) is closed by a zero-diagnostic `lean_run_code`
probe of the FULL future-side discharge under the re-keyed bracket: off-fiber σ are
**unrealizable at the pinned anchors** (fiber-forcing kernel), so dropping them from the bracket
loses nothing any consumer feeds it. The two landed `hexclSlice*` supply theorems survive with
their binders **verbatim unchanged** (stronger than the implementer's "unused antecedent" claim —
no edit at all). The fiber-restricted `hslice*` discharge at m = 0 is Probe A of the phase-5
dispatch (green end-to-end). The ℤ-doppelgänger countermodel is annihilated: its σ is off-fiber,
hence outside both the re-keyed range and the fiber-guarded binder.

## 1. Faithfulness adjudication (crux question 1)

### 1.1 The frozen k=2 template has the fiber conjunct; the depth-k rewrite dropped it

Direct comparison:

| | Frozen k=2 (`ExteriorBracket.lean`) | Depth-k current (`ExteriorBracketAssembleK.lean:78-99`) |
|---|---|---|
| Range filter | `kvE2_futMarked qnf` (`:369`) = zone-spec ∧ **`decide (nf0_dropFresh σ.1 = qnf.1)`** ∧ below-zone bit agreements (`:124-131`) | `kvE_futAdmissible σ` only — **fiber conjunct absent** |
| Clause key | per-σ bit `qnf.2 σ` inside the marked range | `kvE_futSliceMarked qnf σ` (blocker-1 fix) |
| Off-range σ handling (⇒) | realizer FORCES marking under pins (`kvE2_futMarked_of_realizer`, needs `henv`+`hbelow`; gate derives them via `kvE2_extGate_henv`/`_anyBit_iff`, `:721/:803`) | none needed while range was too wide — the defect |

The k=2 marking's three conjuncts map onto the depth-k design as: (1) zone-spec — subsumed by
`kvE_futAdmissible` (its first conjunct is `decide (nf0_zoneSpec σ.1 = kvE2_sep_zFutT3)`,
confirmed at ExteriorGateAssembleK:247-251); (2) **base/fiber agreement — the dropped conjunct,
restored by this re-key**; (3) below-zone bit agreements — its k=2 role (making the per-σ-BIT
key coherent) is subsumed at depth k by the slice keying + `kvE_futClause_sliceConstant`
(blocker-1 fix), so no depth-k analog is required. The widening is therefore a task-352
regression of exactly the blockers-1/2 family (depth-k rewrite silently dropping a frozen-template
constraint), not a generalization.

### 1.2 The codebase's own honesty bridge is fiber-disciplined

`nf_eval_nfk_iff_efold` (NfEFold.lean:627) decomposes honest evaluation of `qnf` into
`nf_eval_efold_k` — whose fold conjunct is **explicitly fiber-guarded**
(`∀ sub, nfk_dropFresh sub = qnf.1 → …`, NfEFold.lean:612) — plus off-fiber falsity
(`∀ sub, nfk_dropFresh sub ≠ qnf.1 → qnf.2 sub = false`). A bracket that carries honesty
obligations for off-fiber σ asserts content the disjunct does not own; the machine refutation
(free-env `kvE_futPos` truth for an off-fiber σ with no marked mate) is precisely this
mis-attribution surfacing.

### 1.3 Paper grounding (Tier 1)

Def 7.13 (Rabinovich 2014, p.15; chunk_0023:25-26): a multi-anchor formula is a conjunction
⋀_{i≤k} ϕi of per-adjacent-segment ∃∀ formulas **inside one normal-form disjunct** — the
disjunct simultaneously fixes the anchors' atomic environment and the per-segment content. The
negation device (Cor 5.4 observation, chunk_0015:39-41: `¬F0(z0) ∨ On(F1,…,Fn,z0,z1)` equivalent
to `¬∃z>z0 [α0,…,αn](z0,z)`; Lemma 7.8, chunk_0022:9-13) negates the SEGMENT bracket within that
same disjunct. Segment types quantified by a disjunct's exterior bracket therefore share the
disjunct's atom environment — the Lean fiber `nfk_dropFresh σ = qnf.1`. A bracket ranging over
σ from other atom environments (other disjuncts) has no counterpart in the paper.

## 2. Consumer-completeness (crux question 2 — DECISIVE), with machine evidence

The re-key **narrows** the range, i.e. the bracket formula promises LESS. The completeness
question per consumer: does every σ the consumer feeds the bracket satisfy the fiber filter
(narrowing lossless), or can a consumer supply an off-fiber σ (narrowing breaks it)?

### 2.1 The key fact: off-fiber σ are unrealizable at the pinned anchors

**Fiber-forcing kernel (Probe P1, `lean_run_code`, zero diagnostics)**: for any
`σ : NormalForm sig (k+1) 4` realized at `[x1,w,x,t]`, given the atom layer
`henv : nf_eval_nf M 0 3 [w,x,t] qnf.1`, one derives `nfk_dropFresh σ = qnf.1` in three landed
steps: `nf_eval_nf_atom_layer` → `nf_eval_nf0_cons_factor` → `nf_eval_unique M 0 3`. This is
the standalone form of the `offForce` have-block already inside `nf_eval_nfk_iff_efold`
(NfEFold.lean:634-641). Contrapositive: off-fiber σ cannot be realized at the pinned anchors —
at ANY x1, interior or exterior.

**Gate-level `henv` (Probe P2, zero diagnostics)**: inside the gate's ⇒-direction `hexclExt`
lambda, `henv` is derivable for the callback's ARBITRARY `w` from inventory already in scope:
`hInt` (interior gate `.holds` at `(x,t)`) destructured via `bracketEndChar_kv_succ_holds_iff`
gives the `igEpL`/`igEpR` heads (x- and t-projections); the callback's `hptW` gives the w-head;
`interiorGate_hcb` + `k1v_reconstruct_nf3` reassemble the depth-0 atom layer. This replicates
`bracketEndChar_kv_step_sound`'s own atom-layer block (InteriorGateGeneralK:1076-1113) with the
extracted w replaced by the callback's w; the `open private k1v_reconstruct_nf3 from …CarrierK1V`
precedent is at InteriorGateGeneralK:1030. It is the depth-k analog of the k=2 gate's
`kvE2_extGate_henv` (ExteriorBracket.lean:721) — same inventory, same recipe.

### 2.2 Per-consumer findings

| Consumer | How it touches the bracket range | Finding under the re-key | Evidence |
|---|---|---|---|
| **D1/D2** (`kvE_extBracket{Fut,Past}_sound`, AssembleK:148-186) | ⇒-side: extract per-σ clause for slice-unmarked σ | Statement gains per-σ antecedent `nfk_dropFresh σ = qnf.1`; same proof route (realizer→admissible; `_iff`; `if_neg`; `kvE_extNeg*_sound`) | Probe P5b: D1′ zero diagnostics |
| **Gate ⇒** (`bracketEndChar_kvExt_correct_prior` `hexclExt` discharge, GateAssembleK:194-214) | must refute EVERY bit-false σ realized strictly exterior — including off-fiber σ | **PRESERVED**: fiber dichotomy — off-fiber refuted by P1 kernel + P2 henv (realization impossible); in-fiber slice-unmarked by D1′/D2′; in-fiber slice-marked bit-false by `hexclSlice*` **verbatim** | **Probe P6: the FULL future-side discharge, zero diagnostics** |
| **Gate ⇐** (D3/D4 feed, GateAssembleK:226-257) | `hpos`: σ′ with `qnf.2 σ′ = true` under realized qnf; `hslice` callback | `hpos`-fed σ′ are realizable at the pinned anchors (`(h.2 σ′).mpr hbit`), hence in-fiber by the kernel with `henv := h.1` — never outside the narrowed range. `hslice` call site unchanged (`hsliceFut w hxw hwt h`) | Probe P7: D3′ zero diagnostics |
| **D3/D4** (`_complete`, AssembleK:202-272) | ⇐-side: per-σ honesty obligations over the range | Obligations REDUCED — exactly the machine-refuted off-fiber ones removed; slice-unmarked case consumes the fiber-augmented `hslice` (fiber available from the range filter) | Probe P7 |
| **EndIntervalConsumerK** (motive :139-150, threading :197-203) | carries `hslice*`/`hexclSlice*` binder text verbatim | mechanical binder-text update (`hslice*` only); threading identifiers unchanged | binder texts copied verbatim by design (:131-138 comment) |
| **KampPrior seam** (`kampPrior_site_rungK_gate_match`, :819/:854-884) | pure carrier: forwards eleven obligations to the gate | mechanical binder-text update (`hslice*` only); forwarding call unchanged. KampPrior:361 arm is a strategic sorry (309/358-owned) — no green consumer downstream breaks | :884 forwards binders by name |
| **ExteriorBracketK / PinnedConverse files** | docstring mentions only (grep-verified: no code reference) | none | grep sweep |

**Conclusion**: narrowing is lossless — every σ that reaches the bracket at a consumption site is
forced onto the fiber, and the removed obligations are exactly the machine-false ones. This is
the blocker-2 "can the producer supply it" check, answered affirmatively by elaboration, not
hand-waving.

### 2.3 Why the alternative (thread fiber as binder hypothesis WITHOUT narrowing) fails

With the wide range kept, the bracket formula still contains the clause
`kvE_extNegFut P σ` for off-fiber slice-unmarked σ. In the ℤ-doppelgänger structure that clause
is FALSE at `t` while `qnf` is honestly realized — so D3/D4's conclusion (bracket truth) is
semantically false and the gate's ⇐ direction is unprovable no matter what antecedents the
binders carry. Narrowing the range is forced; it is not one of two equivalent repair shapes.

## 3. Recommended repair (exact shapes)

### 3.1 Range predicate (both sides)

```lean
-- kvE_extBracketFut (ExteriorBracketAssembleK.lean:78-85)
(((Finset.univ.toList (α := NormalForm sig (k + 1) 4)).filter
    (fun σ => kvE_futAdmissible σ && decide (nfk_dropFresh σ = qnf.1))).map …)
-- kvE_extBracketPast (:92-99): kvE_pastAdmissible σ && decide (nfk_dropFresh σ = qnf.1)
```

Decidability of `nfk_dropFresh σ = qnf.1` (equality in `NormalForm sig 0 3`) confirmed by Probe
P4 (the k=2 template already uses `decide (nf0_dropFresh σ.1 = qnf.1)`). `nfk_dropFresh σ`
definitionally equals `nf0_dropFresh σ.atom_assgn` (NfEFold.lean:578) — use `nfk_dropFresh` to
match `kvE_futSliceId_of_end_zero`'s `hfib` input (ExteriorPinnedConverseK.lean:898) verbatim.
Note the filter is slice-invariant (slice-mates share `σ.1`, hence the fiber label), so clause
slice-constancy semantics are unchanged.

### 3.2 `_iff` lemmas

RHS becomes `∀ σ, kvE_futAdmissible σ = true → nfk_dropFresh σ = qnf.1 → …` (Probe P5a body —
mechanical, `decide_eq_true`/`decide_eq_true_eq` bookkeeping only).

### 3.3 D1/D2

Add per-σ antecedent `nfk_dropFresh σ = qnf.1` before `kvE_{fut,past}SliceMarked qnf σ = false`
(Probe P5b). Docstring: off-fiber exclusion is NOT D1/D2's job — it is internal to the gate via
the kernel.

### 3.4 D3/D4

`hslice` input gains `nfk_dropFresh σ = qnf.1 →` after the admissibility antecedent (Probe P7).

### 3.5 Gate (`ExteriorGateAssembleK.lean`)

1. Add `open private k1v_reconstruct_nf3 from …CarrierK1V` and a private gate-henv helper
   (Probe P2 statement/body verbatim; both sides share it).
2. `hslicePast`/`hsliceFut` binders (:158-169): insert `nfk_dropFresh σ = qnf.1 →` after the
   admissibility antecedent. **`hexclSlicePast`/`hexclSliceFut` binders (:170-183): UNCHANGED.**
3. ⇒-callback (:197-214): derive `henv` once (helper), then per side:
   `by_cases hfib : nfk_dropFresh σ = qnf.1` — off-fiber: kernel refutation (P1 three-liner);
   in-fiber: existing sliceMarked case split (D1′/D2′ with `hfib`, or `hexclSlice*` verbatim).
   Probe P6 is this exact assembly for the future side, zero diagnostics; the past side mirrors
   with `kvE_pastRealizer_admissible`/`kvE_extNegPast_sound` (all mirrors landed, used by
   current D2/D4).
4. ⇐-direction (:226-257): textually unchanged (the `hslice*` forwarding already passes the
   binder through; D3′/D4′ accept it).

### 3.6 Consumers (mechanical binder-text mirrors)

- `EndIntervalConsumerK.lean:139-150`: mirror the two `hslice*` binder updates (`_hslicePast`/
  `_hsliceFut` gain `nfk_dropFresh σ = qnf.1 →`); `:197-203` threading names unchanged.
- `KampPrior.lean:854-865` (`kampPrior_site_rungK_gate_match`): same mirror; `:884` unchanged.

### 3.7 Phase-5 re-dispatch (after 3c, NOT part of 3c)

`kvE_hsliceFut_supply_zero`/`kvE_hslicePast_supply_zero` in the two PinnedConverse files, binder
text verbatim at k := 0 WITH the fiber antecedent — Probe A of the phase-5 dispatch is the
standing machine evidence the route closes green (destructor → `kvE_{fut,past}SliceId_of_end_zero`
→ `kvE_futRealizer_admissible` + `kvE_fiberZoneList_congr` assembly; `hfib` now binder-supplied).

## 4. Territory (crux question 5 — every file Phase 3c touches)

| File | Edit |
|---|---|
| `Theories/…/NfMultiAnchorBridge/ExteriorBracketAssembleK.lean` | range filter ×2 (:78-99), `_iff` ×2 (:103-137), D1/D2 antecedent (:148-186), D3/D4 `hslice` antecedent (:202-272), module docstring |
| `Theories/…/NfMultiAnchorBridge/ExteriorGateAssembleK.lean` | `open private` + private gate-henv helper (new); `hslice*` binder text (:158-169); ⇒-callback fiber dichotomy (:194-214); binder docs |
| `Theories/…/NfMultiAnchorBridge/EndIntervalConsumerK.lean` | `_hslice*` binder text (:139-150) |
| `Theories/…/Kamp/KampPrior.lean` | `hslice*` binder text in `kampPrior_site_rungK_gate_match` (:854-865) |

NOT touched: `ExteriorBracket.lean` (frozen k=2), `InteriorGateGeneralK.lean`, `NfEFold.lean`,
`CarrierK1V.lean` (private lemma consumed via `open private`), both PinnedConverse files
(3c-read-only; Phase-5 re-dispatch adds the two `hslice*` supply theorems there),
`ExteriorNegation{,Past}K.lean`, `ExteriorConverter{,Past}K.lean`.

## 5. `hexclSlice*` survival (crux question 3)

**CONFIRMED — stronger than claimed.** The recommended re-key leaves the `hexclSlicePast`/
`hexclSliceFut` binder text verbatim unchanged (Probe P6 consumed the current text unmodified in
the discharge), so `kvE_hexclSliceFut_supply_zero` and `kvE_hexclSlicePast_supply_zero`
(committed `1bbb8d741`, axioms `[propext, Classical.choice, Quot.sound]`) survive with **zero
edits** — not even the "unused antecedent" the phase-5 handoff anticipated. Rationale for not
adding the fiber antecedent there: the ⇒-side discharge obtains σ's admissibility from the
realizer and never needs σ's fiber (off-fiber σ are refuted BEFORE the sliceMarked split), and
the m=0 supply route (`kvE_futSliceUnique_zero` + `hreal`) landed green without it.

## 6. m = 0 sufficiency + H4 non-refutation (crux question 4)

- **m = 0** (the task-358 KampPrior:361 seam's depth): the fiber-restricted `hsliceFut` discharge
  is exactly Probe A of the phase-5 dispatch (handoff §Probes: full prescribed route elaborates
  with EXACTLY ONE sorry at `hfib`; green end-to-end with `hfib` as antecedent). The re-keyed
  binder supplies `hfib`. `kvE_futSliceId_of_end_zero`'s remaining inputs (`hadm`, `h` ambient,
  `hend`/`hgap`/`hocc` destructor facts) are all binder-available (the `hslice*` binder is
  ambient-guarded by `nf_eval_nf M (m+2) 3 [w,x,t] qnf` — EndIntervalConsumerK:140). Past mirror:
  `kvE_pastSliceId_of_end_zero` landed (ExteriorPinnedConversePastK:513).
- **H4 against the ℤ-doppelgänger**: the countermodel's σ (honest char of the primed quadruple
  [100,1,0,2]) differs from `qnf.1` at the Q-at-w-slot (handoff defect record) — i.e.
  `nfk_dropFresh σ ≠ qnf.1`. Under the re-key it is (a) outside the bracket range, (b) outside
  the fiber-guarded `hslice*` binders (antecedent fails), and (c) still unrealizable at the
  pinned anchors (kernel), so it refutes nothing. The standing regression guard
  `kvE_futPinned_of_end_zero_refuted` is untouched. The refutation-family witnesses (σ′, τ) of
  blockers 1-2 remain handled as recorded (σ′ pinned-unrealizable; τ bit-true, out of scope).

## 7. H3 lemma-level mapping (Tier 1, 5-column)

| Source | Prop/Location | Lean Identifier | Type Signature (essence) | Status |
|---|---|---|---|---|
| Rabinovich 2014 | Def 7.13, p.15 (chunk_0023:25-26): multi-anchor formula = conjunction of per-adjacent-segment ∃∀ formulas inside ONE disjunct | `kvE_extBracketFut`/`kvE_extBracketPast` (re-keyed range) | `ExistProviders → NormalForm sig (k+2) 3 → Formula`; range = admissible ∧ `nfk_dropFresh σ = qnf.1` | REPAIR TARGET (Phase 3c) |
| Rabinovich 2014 | Cor 5.4 observation, p.9 (chunk_0015:39-41): `¬F0 ∨ On` ≡ `¬∃z>z0 [α0,…,αn](z0,z)` — negation per SEGMENT bracket within the disjunct | `kvE_extNegFut`/`kvE_extNegPast` asserted only for in-fiber slice-unmarked σ | (unchanged clause; range membership changes) | LANDED clause; range fix pending |
| Rabinovich 2014 | Lemma 7.8, p.14 (chunk_0022:9-13): negation of bracket over canonical expansions | slice-keyed if-then-else (blocker-1 fix, unchanged) | — | LANDED |
| Rabinovich 2014 | Def 7.7, p.14 (chunk_0022:5): canonical expansion — truth at a point is a complete pinned datum | `nf_eval_nfk_iff_efold` off-fiber falsity conjunct; `nf_characteristic`/`nf_eval_unique` | `nf_eval_nf M (k+1) n env qnf ↔ efold ∧ ∀ sub, off-fiber → qnf.2 sub = false` | LANDED (NfEFold.lean:627) |
| Rabinovich 2014 | Cor 5.4(1)⇐, p.9 (chunk_0015:11-37): milestone reconstruction at the segment endpoint | `kvE_futSliceId_of_end_zero` (`hfib` input :898) / `kvE_pastSliceId_of_end_zero` | needs `hfib : nfk_dropFresh σ = qnf.1` — supplied by the re-keyed binder | LANDED; consumed at Phase-5 re-dispatch |
| Frozen template | k=2 marking fiber conjunct | `kvE2_futMarked`/`kvE2_pastMarked` (`decide (nf0_dropFresh σ.1 = qnf.1)`, ExteriorBracket.lean:127/140) | — | LANDED (parity restored by 3c) |
| Frozen template | k=2 gate-level pins | `kvE2_extGate_henv` (ExteriorBracket.lean:721) | depth-k analog = Probe P2 (new private helper) | PROBED GREEN |

## 8. Adversarial Self-Verification

### Claim Verification Table

| Claim | Source/Counterexample | Verification Method | Confidence |
|---|---|---|---|
| Fiber-forcing kernel closes at depth k (off-fiber σ unrealizable at pinned anchors given henv) | `offForce` recipe NfEFold:634-641 | `lean_run_code` Probe P1 — zero diagnostics | High |
| Gate-level henv derivable for the callback's arbitrary w from `hInt`+`hptW` | step_sound's own block (InteriorGateGeneralK:1076-1113); `open private` precedent :1030 | `lean_run_code` Probe P2 — zero diagnostics | High |
| Re-keyed range predicate is decidable/elaborates | k=2 uses same `decide` on `nf0_dropFresh` | `lean_run_code` Probe P4 — zero diagnostics | High |
| Re-keyed `_iff`, D1′, D3′ close by the existing routes | current D1/D3 bodies | `lean_run_code` Probes P5a/P5b/P7 — zero diagnostics | High |
| **Gate ⇒ `hexclExt` discharge complete under the narrowed range with `hexclSlice*` verbatim** | the decisive consumer risk | `lean_run_code` Probe P6 (full future-side composite) — zero diagnostics | High |
| Past side mirrors P6/P5/P7 | every future lemma used has a landed Past mirror consumed by current D2/D4 (`kvE_pastRealizer_admissible`, `kvE_extNegPast_sound`, `kvE_pastSliceMarked_iff`, `kvE_pastClause_sliceConstant`); kernel/henv are side-agnostic | structural mirror argument (NOT separately probed) | Medium-High |
| `hexclSlice*` supply theorems survive with zero edits | binder text unchanged in P6 | Probe P6 consumed the verbatim binder; landed theorems commit `1bbb8d741` | High |
| m=0 fiber-restricted `hslice*` discharge closes | phase-5 handoff Probe A transcript (exactly-one-sorry-at-`hfib` isolation) | machine record cited, not re-run this dispatch (re-verified at Phase-5 re-dispatch) | Medium-High |
| Countermodel σ is off-fiber, hence annihilated | handoff defect record (Q-at-w-slot mismatch between σ.1 and the real-anchor layer) | analytic, from the recorded construction + the new antecedent | High |
| Def 7.13/Cor 5.4 fiber discipline reading | chunk_0023:25-26, chunk_0015:39-41, chunk_0022:3-13 read directly this dispatch (not via report 02 alone) | corpus chunk reads; hazard note honored (no md:NN cites; PDF-page + chunk cites) | High |
| No other code consumer of the bracket exists | grep sweep: `ExteriorBracketK`/PinnedConverse hits are docstrings only | repo-wide grep | High |

### Challenges raised and resolved

1. *"Does the gate ⇒ need exclusion for off-fiber σ that the narrowed D1/D2 no longer provide?"*
   — Yes it does (`hexclExt` is per-σ over ALL bit-false σ, InteriorGateGeneralK:1067-1073), and
   this was the genuine break risk. Resolved constructively: off-fiber realization is impossible
   (P1+P2), verified by the composite P6. Had the kernel or the gate-henv failed to elaborate,
   the recommendation would have been REVERSED.
2. *"Is the k=2 conjunct-3 (below-zone bit agreements) also needed at depth k?"* — No: its k=2
   role was to make the per-σ-BIT key coherent inside the marked range; depth k keys by slice
   with clause slice-constancy (blocker-1 fix), which quantifies over admissible slice-mates
   irrespective of deep bits. No consumer probe required it (P6/P7 closed without it).
3. *"Could `kvE_futSliceMarked` itself need re-keying to fiber-filtered mates?"* — No:
   `kvE_futSliceEq` requires `σ'.1 = σ.1`, so slice-mates share the fiber label; for in-range σ
   all mates are automatically in-fiber. Filter is slice-invariant.

### Contradiction log

None. No contradictions between the frozen template, the paper chunks, the phase-5 defect
record, and the probe results.

## 9. Recommendation to the orchestrator

Proceed with Phase 3c as specified in §3 (revise plan, then dispatch): it is a Phase-3b-territory
re-key plus one new private gate helper — every load-bearing composition step is already
machine-elaborated (P1/P2/P4/P5a/P5b/P6/P7, all zero diagnostics). Then re-dispatch Phase 5 for
the `hslice*` supply pair (Probe A route). Expected end state: `hexclSlice*` pair untouched-green,
`hslice*` pair green at m=0, gate/consumer/KampPrior seam green with the eleven-obligation carry
discipline intact, countermodel family fully out of scope.

## Memory candidates

1. Off-fiber σ are unrealizable at pinned anchors: the three-step kernel
   (`nf_eval_nf_atom_layer` → `nf_eval_nf0_cons_factor` → `nf_eval_unique`) makes narrowing any
   per-σ conjunction range to the qnf-fiber LOSSLESS for consumers that only ever feed realized
   σ — check this before carrying honesty obligations for off-fiber types.
2. Gate-level atom-layer pins (`henv`) are re-derivable inside obligation lambdas from the
   interior gate `.holds` + the callback's `igPtW`, replicating step_sound's own block via
   `open private k1v_reconstruct_nf3` — no binder-signature change needed to gain environment
   agreement at an arbitrary interior witness.
