# Task 356 — General-k `hexclExt` Exterior-Adjacency Discharge: Shape, Precedent, and Transcription Path

**Agent**: lean-research-agent · **Scope**: research only (no Lean/plan edits)
**Reference-grounding tier**: Tier 1 (literature-backed — Rabinovich 2014, Def 7.5 + Lemma 7.6)
**Verdict**: **GREEN-VIABLE.** Every composition input already exists sorry-free. The deliverable is a
near-mechanical general-`k` mirror of the *landed* k=2 discharge
`bracketEndChar_kvE2Ext_correct_two_prior_frag`. One genuine proof-risk site is flagged for
escalation (⇐-direction positive-witness positioning).

---

## TL;DR

- **What to build**: a new leaf module (proposed
  `NfMultiAnchorBridge/ExteriorGateAssembleK.lean`) delivering three things, each a one-fold-deeper
  mirror of the k=2 `ExteriorBracket.lean` originals:
  1. `bracketEndChar_kvExt` — the general-`k` **enriched composed gate** (interior carrier
     `bracketEndChar_kv` with the two adjacent exterior brackets conjoined at anchors `x`,`t`);
  2. `bracketEndChar_kvExt_holds_iff` — anchor-semantics bridge (**reuses**
     `VVecEA2.enrichEndpoints_holds` verbatim, since `bracketEndChar_kv … qnf : VVecEA2`);
  3. `bracketEndChar_kvExt_correct_prior` (the **`hexclExt` discharge** = the DoD lemma; the task's
     `bracketEndChar_kv_hexclExt_discharge`): the enriched-gate biconditional
     `holds ↔ ∃ w, nf_eval_nf M (k+2) 3 [w,x,t] qnf` carrying only
     `P, hcharK, h_UZ, h_SZ, hreal, hexcl` (+ six order bits) — with `hexclExt` **discharged
     internally** by the per-side bracket soundness lemmas.
- **Why it is viable**: the per-side general-`k` brackets `kvE_extBracketPast/Fut` and their
  `_sound` (D1/D2) + `_complete` (D3/D4) are **already landed sorry-free** in
  `ExteriorBracketAssembleK.lean` (tasks 349/351/352/354); the interior step soundness/completeness
  `bracketEndChar_kv_step_sound`/`_correct` are landed (task 355); the ⇐-direction discharge
  templates `kvE_futBundle_of_realizer`/`kvE_pastBundle_of_realizer` are landed (task 354).
- **Faithfulness**: this is Rabinovich Lemma 7.6 (chunk_0021:23) adjacency composition; at the shared
  free anchors `x,t` it **degenerates** to endpoint conjunction (no new seam existential) — the same
  347-adjudication verdict (b) already used at k=2. Confirmed against task-355 report Q1.
- **Index / base-rung fact (load-bearing for the plan)**: the AssembleK brackets live at
  `qnf : NormalForm sig (k+2) 3`, σ `: NormalForm sig (k+1) 4`. So this discharge is a ∀-`k` family
  covering interior depths **≥ 2** (the k=2 discharge is its `k=0` member). Interior depths 0 and 1
  are the already-delivered **base rungs** (`interiorGateTarget_zero`,
  `bracketEndChar_kv_correct_one_prior`), which carry **no** exterior obligation — the discharge
  neither needs nor can touch them.
- **Consumer / wiring**: the new file must be threaded into the import graph so `KampPrior.lean`
  sees it (currently the `NfMultiAnchorBridge.lean` aggregator stops at the k=2 `ExteriorBracket`;
  the general-`k` chain is not yet reachable from KampPrior). This wiring, and the KampPrior:351
  site-certificate reshape, is **task 357**'s consumer job; task 356 delivers the lemma.

---

## Literature Proof Structure (Rabinovich 2014)

**Source**: Rabinovich 2014, `~/Projects/Literature/sources/rabinovich_2014/chunk_0021.md`, Def 7.5
(line 17) + Lemma 7.6 (line 23). Read independently for this report.

- **Def 7.5** (`(z0,z1)-∨→∃∀` formula): a disjunction of forward-EA bracket formulas
  `[α0,β1,…,βn,αn](z0,z1)` for a *single* interval `(z0,z1)`.
- **Lemma 7.6** (closure): *"If φ1 is a (z0,z1)-∨→∃∀ formula and φ2 is a (z1,z2)-∨→∃∀ formula, then
  `(∃z1)^{<z2}_{>z0}(φ1 ∧ φ2)` is a (z0,z2)-∨→∃∀ formula."* — the adjacency composition that stitches
  a `(z0,z1)`-bracket to an **adjacent** `(z1,z2)`-bracket across the **shared endpoint z1**.

**Strategy / Step Map** (as realized in this codebase):

1. A witness realizing an unmarked sub at a point **strictly outside `[x,t]`** is exactly the object
   Lemma 7.6 composes across an adjacent bracket. The single-bracket interior characterization
   (Cor 5.4) structurally cannot handle it — the interior gate `bracketEndChar_kv` genuinely carries
   it outward as the `hexclExt` binder (task-355 report Q1, CONFIRMED). — **[Rabinovich] Lemma 7.6**
2. The exterior arrangements `x1 < x` and `x1 > t` belong to the **adjacent intervals** `(-∞,x)` and
   `(t,∞)`, each with its own Def-7.5 bracket. — **[Rabinovich] Def 7.5**
3. **Degeneration at shared free anchors** (the codebase design decision, 347 adjudication verdict
   (b)): the `(∃z1)^{<z2}_{>z0}` composition, taken at the *free* anchors `x,t` rather than a bound
   seam variable, reduces to plain endpoint **conjunction** — no new seam existential is introduced
   at the rung. This is realized by `VVecEA2.enrichEndpoints` (ExteriorBracket.lean:623). — **derived**
4. Per-side bracket soundness kills every bit-false σ at every exterior `x1` on its side; this is the
   `hexclExt` discharge. — **[Rabinovich] Lemma 7.10** (navigated positive/complement clauses),
   realized as `kvE_extBracket{Past,Fut}_sound`.

### Lean-specific translation considerations

- Rabinovich's bound seam existential `(∃z1)^{<z2}_{>z0}` is **not** transcribed at this rung: the
  codebase uses the free-anchor degeneration (endpoint conjunction). This is a *deliberate, already
  ratified* deviation (settled at k=2); the plan must flag it as the intended shape, not a shortcut.
- The `(z0,z1)`-relative forward-EA class is **not closed under negation** (Lemma 7.8 preamble,
  chunk_0022:3); the whole point of Lemma 7.6 is that only the bounded/adjacent composition re-enters
  the class. This is why `hexclExt` is a genuine separate lemma, not interior-gate work.

---

## Reference-Grounding Mapping Table (5 columns)

| Source | Prop / Location | Lean Identifier (file:line) | Type Signature (verified by read) | Status |
|--------|-----------------|-----------------------------|-----------------------------------|--------|
| Rabinovich | Lemma 7.6 adjacency (chunk_0021:23) | **DELIVERABLE** `bracketEndChar_kvExt_correct_prior` (new) | enriched `holds ↔ ∃w, nf_eval_nf M (k+2) 3 [w,x,t] qnf`, carrying `P,hcharK,h_UZ,h_SZ,hreal,hexcl` + order bits; `hexclExt` internal | **TO BUILD** (mirror of k=2 `_correct_two_prior_frag`) |
| Rabinovich | Def 7.5 / degenerate 7.6 endpoint conj | **DELIVERABLE** `bracketEndChar_kvExt` (new) | `bracketEndChar_kv … (k+2) qnf).enrichEndpoints (kvE_extBracketPast P qnf) (kvE_extBracketFut P qnf) : VVecEA2` | **TO BUILD** (mirror of `bracketEndChar_kvE2Ext`, ExteriorBracket.lean:661) |
| — | endpoint-conj semantics | `VVecEA2.enrichEndpoints` / `_holds` (ExteriorBracket.lean:623/632) | `holds ↔ v.holds ∧ pL@z0 ∧ pR@z1` — **generic over VVecEA2** | REUSABLE VERBATIM (carrier is `VVecEA2`) |
| Rabinovich | Lemma 7.10 future exterior residue | `kvE_extBracketFut_sound` (ExteriorBracketAssembleK.lean:113) | `… qnf.2 σ = false → ∀ x1, t < x1 → ¬ nf_eval_nf M (k+1) 4 [x1,w,x,t] σ` | LANDED, sorry-free (D1) |
| Rabinovich | Lemma 7.10 past exterior residue | `kvE_extBracketPast_sound` (ExteriorBracketAssembleK.lean:135) | `… qnf.2 σ = false → ∀ x1, x1 < x → ¬ nf_eval_nf M (k+1) 4 [x1,w,x,t] σ` | LANDED, sorry-free (D2) |
| Rabinovich | Def 7.5 re-establishment (⇐) | `kvE_extBracketFut_complete` / `kvE_extBracketPast_complete` (AssembleK:168/210) | takes `hpos/hneg/hreal/hsat` → `temporal_truth … (kvE_extBracket… P qnf)` | LANDED, sorry-free (D3/D4) |
| task 354 | ⇐ discharge template (Future) | `kvE_futBundle_of_realizer` (ExteriorConverterK.lean:208) | from realizer of σ at `[x1,w,x,t]` yields both `hreal`+`hsat` slices | LANDED, sorry-free |
| task 354 | ⇐ discharge template (Past) | `kvE_pastBundle_of_realizer` (ExteriorConverterPastK.lean:177) | mirror | LANDED, sorry-free |
| task 355 | interior soundness (⇒) — the `hexclExt` consumer | `bracketEndChar_kv_step_sound` (InteriorGateGeneralK.lean:1043) | takes `hreal,hexcl,hexclExt` → `holds → ∃w …` | LANDED, sorry-free |
| task 355 | interior step biconditional | `bracketEndChar_kv_step_correct` (InteriorGateGeneralK.lean:1165) | adds `P,hcharK,h_UZ,h_SZ` → `holds ↔ ∃w …` | LANDED, sorry-free |
| task 355 | ∀-k obligation-carrying gate | `bracketEndChar_kv_correct_prior` (InteriorGateGeneralK.lean:1288) | `∀k, InteriorGateAllK …` — carries `hexclExt` binder outward | LANDED; **its `hexclExt` is what 356 discharges** |
| k=2 precedent | THE template to mirror | `bracketEndChar_kvE2Ext_correct_two_prior_frag` (ExteriorBracket.lean:1069) | enriched k=2 gate biconditional, `hexclExt` internal, carries `hfrag,hrealI,hrealB,hexcl`+bits | LANDED, sorry-free — the discharge blueprint |
| — | carrier alias | `BracketEndCharCarrierV sig k := NormalForm sig k 3 → VVecEA2` (CarrierK1V.lean:365) | — | confirms `enrichEndpoints` applies at general k |

---

## The exact deliverable shape

The interior-gate `hexclExt` binder that must be discharged (InteriorGateGeneralK.lean:1193, carried
outward by `bracketEndChar_kv_correct_prior`):

```lean
(hexclExt : ∀ w : M.carrier, x < w → w < t →
  (igPtW (nf_depth0_char_formula atomMap h_surj) (charF k) qnf.1 (igFoldBit qnf)).eval_at M atomMap w →
  ∀ σ : NormalForm sig k 4, qnf.2 σ = false →
    ∀ x1 : M.carrier, ¬ (x ≤ x1 ∧ x1 ≤ t) →
      ¬ nf_eval_nf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
```

The deliverable is the general-`k` enriched-gate correctness theorem (proposed
`bracketEndChar_kvExt_correct_prior`), mirroring `bracketEndChar_kvE2Ext_correct_two_prior_frag`
one fold deeper. Its heart — the internal `hexclExt` discharge — is the **exact k=2 pattern**
(ExteriorBracket.lean:1120-1129), reindexed:

```lean
-- inside the ⇒ direction, building the hexclExt lambda fed to bracketEndChar_kv_step_sound:
intro w hxw hwt hptW σ hbit x1 hguard hnf
rcases not_and_or.mp hguard with hx | ht
· exact kvE_extBracketPast_sound P M h_UZ h_SZ qnf w x t hxw hwt hPastBr σ hbit x1 (not_le.mp hx) hnf
· exact kvE_extBracketFut_sound  P M h_UZ h_SZ qnf w x t hxw hwt hFutBr  σ hbit x1 (not_le.mp ht) hnf
```

The guard split `¬(x ≤ x1 ∧ x1 ≤ t)` → `x1 < x ∨ t < x1` via `not_and_or.mp` + `not_le.mp` is
verbatim from the k=2 proof.

**Depth-index reconciliation (must be nailed by the implementer).** State the discharge at
`bracketEndChar_kv … (k+2)`, `qnf : NormalForm sig (k+2) 3`, so that σ `: NormalForm sig (k+1) 4`
matches the AssembleK bracket lemmas exactly (no reindex needed). This makes the discharge a ∀-`k`
family at interior depths `k+2 ≥ 2`. To feed `bracketEndChar_kv_step_correct` (whose successor
index is `(·)+1`), instantiate its `k := k+1` so its σ `: NormalForm sig (k+1) 4` aligns. The k=2
discharge is the `k = 0` member of this family (`qnf : NormalForm sig 2 3`), which is a direct
cross-check that the indices line up.

### Transcription path (concrete, step-ordered)

1. **New leaf module** `NfMultiAnchorBridge/ExteriorGateAssembleK.lean`, importing
   `…NfMultiAnchorBridge.InteriorGateGeneralK` (interior step + carrier) and
   `…NfMultiAnchorBridge.ExteriorBracketAssembleK` (per-side brackets). These two do not import each
   other → acyclic. `enrichEndpoints`/`enrichEndpoints_holds` are reachable transitively
   (AssembleK → ExteriorBracketK → ExteriorBracket). Purely additive.
2. **`bracketEndChar_kvExt`** (def): mirror ExteriorBracket.lean:661 — `enrichEndpoints` of the
   interior carrier at `(k+2)` with `kvE_extBracketPast P qnf` (left) and `kvE_extBracketFut P qnf`
   (right). Reconcile `charF` vs `P`: bake `charF (k+1) := fun χ => P.existF 0 χ` (the `hcharK`
   convention) so the interior carrier and the brackets share `P`.
3. **`bracketEndChar_kvExt_holds_iff`**: one-line reuse of `VVecEA2.enrichEndpoints_holds`
   (mirror ExteriorBracket.lean:674). Near-trivial.
4. **`bracketEndChar_kvExt_correct_prior`** (the DoD lemma):
   - **⇒**: destructure via `_holds_iff` → interior `.holds` + past bracket @x + future bracket @t;
     feed `bracketEndChar_kv_step_sound` with the inline `hexclExt` lambda shown above (the two
     `_sound` lemmas). Mirror ExteriorBracket.lean:1106-1129.
   - **⇐**: from `⟨w, h⟩` derive `x<w<t` from the realized order bits; re-establish interior via the
     completeness half of `bracketEndChar_kv_step_correct`; re-establish the two brackets via
     `kvE_extBracket{Past,Fut}_complete`, feeding `hreal`/`hsat` from
     `kvE_{fut,past}Bundle_of_realizer` and `hpos`/`hneg` from the realized qnf. Mirror
     ExteriorBracket.lean:1130-1171.
5. **Verify**: `lake build` full-tree GREEN; `lean_verify bracketEndChar_kvExt_correct_prior` axioms
   exactly `[propext, Classical.choice, Quot.sound]`.

---

## Target insertion point (KampPrior.lean:351)

- `KampPrior.lean:351` sits in the `| 1 =>` arm of the `match n` inside
  `nf_nvar_exist_all_depths` (KampPrior.lean:347-361); it is currently an open `sorry` (line 361).
- The rung table (KampPrior.lean:624) records: arm k=2 consumes the k=2 discharge
  `bracketEndChar_kvE2Ext_correct_two_prior_frag` via site certificate
  `kampPrior_site_rung2_gate_match`; **arms k ≥ 3 have NO rung** (the pre-committed GO-k1 gap). The
  general-`k` discharge `bracketEndChar_kvExt_correct_prior` is precisely what fills arms k ≥ 3 and
  can uniformly subsume the k=2 arm.
- **Reachability gap (wiring TODO, task 357 scope)**: the `NfMultiAnchorBridge.lean` aggregator
  currently imports only up to the k=2 `ExteriorBracket` (line 47). The general-`k` files
  (`InteriorGateGeneralK`, `ExteriorBracketAssembleK`, `ExteriorConverter{,Past}K`, and the new
  `ExteriorGateAssembleK`) are **not yet reachable** from `KampPrior`. The consumer reshape (task
  357) must add the new discharge module to the import chain (aggregator or a direct KampPrior
  import) and build the general-`k` site certificate analog of `kampPrior_site_rung2_gate_match`.

---

## What is NOT task 356 (scope fences)

- `hreal`/`hexcl` (interior realization + within-`[x,t]` cone exclusion) **remain threaded** by the
  discharge, exactly as `hrealI`/`hrealB`/`hexcl` remain at the k=2 rung. They are discharged by the
  provider instantiation at the KampPrior recursion (task 309 Phase 14 / task 357), not here.
- The KampPrior:351 site wiring + `EndIntervalCorrectPrior`-style consumer reshape is **task 357**.
- No interior-gate mathematics is touched (that was task 355). This is exterior-bracket-layer work,
  a sibling to tasks 348/351/352/354.

---

## Escalation risk (single flagged site)

The one place the transcription is **not** purely mechanical is the **⇐-direction positive-witness
positioning** (`hpos`). At k=2, ExteriorBracket.lean:1147-1153 positions the exterior realizer using
the k=2-specific marking zone bits (`kvE2_futMarked`/`kvE2_pastMarked`, `zPastX3`/`zFutT3`). The
general-`k` bracket filters instead on the **order predicate** `kvE_futAdmissible`/`kvE_pastAdmissible`
and the AssembleK header (lines 20-23) prescribes `kvE_futRealizer_admissible` as the replacement for
`kvE2_futMarked_of_realizer` in the `_sound` path — but the `_complete` (⇐) path's `hpos` needs the
realizer *positioned strictly exterior* (`t < x1` / `x1 < x`). At k=2 that positioning came from the
marking's zone bit; at general `k` the corresponding fact must come from `kvE_futAdmissible`
semantics + the realized qnf's arity-4 order layer. If this positioning does not go through by the
line-by-line mirror the AssembleK header promises, that is the escalation point: **mark [BLOCKED]
with the exact goal state and route to a targeted spawn — do NOT land a `sorry` or a vacuous
definition.** (Note: the ⇒ direction — the actual `hexclExt` discharge, which is what KampPrior:351
and task 357 most need — has no such risk; it is a verbatim reindexed mirror.)

---

## Adversarial checks performed

| Claim | Verification | Confidence |
|-------|--------------|------------|
| Per-side general-k brackets + `_sound`/`_complete` exist sorry-free | Read ExteriorBracketAssembleK.lean in full; `grep -c sorry` = 0 | High |
| `enrichEndpoints_holds` reusable at general k | `BracketEndCharCarrierV := NormalForm sig k 3 → VVecEA2` (CarrierK1V:365); `enrichEndpoints_holds` is generic over `VVecEA2` (ExteriorBracket:632) | High |
| Discharge pattern is the verbatim k=2 guard-split | Side-by-side read of ExteriorBracket.lean:1120-1129 vs the target `hexclExt` binder (InteriorGateGeneralK:1193) | High |
| ⇐ templates `kvE_{fut,past}Bundle_of_realizer` exist | Read ExteriorConverterK.lean:208 (+ PastK:177 signature listing) | High |
| Import chain acyclic + reachable | Read import headers of KampPrior, aggregator, InteriorGateGeneralK, ExteriorBracketK, AssembleK | High |
| Discharge covers depths ≥ 2 only; 0/1 are base rungs | AssembleK bracket typed at `NormalForm sig (k+2) 3`; base rungs `interiorGateTarget_zero`/`_one` carry no exterior binder | High |
| No pre-existing `bracketEndChar_kvExt`/discharge partial | `grep -rln` across Theories = 0 hits | High |
| ⇐ `hpos` positioning is the one non-mechanical site | Compared k=2 `kvE2_*Marked` zone-bit positioning (ExteriorBracket:1147) vs general-k `kvE_*Admissible` order predicate | Medium |

No sorry/deferral/axiom route is recommended anywhere. Every "exists / reusable" claim cites a read
Lean signature; the faithfulness claim is anchored to chunk_0021:23 read verbatim.

---

## Files read (evidence base, absolute paths)

- `/home/benjamin/Projects/Literature/sources/rabinovich_2014/chunk_0021.md`
- `/home/benjamin/Projects/BimodalLogic/specs/355_build_depthk_interior_gate_correctness/reports/01_rabinovich-faithfulness-and-deliverable-shape.md`
- `…/NfMultiAnchorBridge/InteriorGateGeneralK.lean` (1040-1200, 1270-1332)
- `…/NfMultiAnchorBridge/ExteriorBracket.lean` (1-70, 615-690, 1040-1173) — k=2 discharge template
- `…/NfMultiAnchorBridge/ExteriorBracketAssembleK.lean` (full) — general-k per-side brackets
- `…/NfMultiAnchorBridge/ExteriorBracketK.lean` (1-60) — determinacy core + residual note
- `…/NfMultiAnchorBridge/ExteriorConverterK.lean` (200-227) + `ExteriorConverterPastK.lean` (signatures)
- `…/NfMultiAnchorBridge/OuterGate.lean` (grep 20-410) — k=2 sound/correct frags + hexclExt binder
- `…/NfMultiAnchorBridge/CarrierKv.lean` (grep) — carrier type
- `…/Kamp/KampPrior.lean` (300-375, 600-640) — insertion point + rung table
- `…/Kamp/NfMultiAnchorBridge.lean` (imports) — aggregator reachability
