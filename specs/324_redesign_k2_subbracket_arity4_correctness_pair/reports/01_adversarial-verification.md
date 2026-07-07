# Adversarial Verification: Task 324 Spawn-Analysis Grounding

**Task**: 324 — redesign_k2_subbracket_arity4_correctness_pair (lean4, hard mode, divergence audit)
**Session**: sess_1783431658_f50ffc
**Mode**: Read-only machine verification (no Lean edits, no `lake build`)
**Verified against**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean`
(6094 lines), `EANegation.lean`, `NfEFold.lean`, `VecEAClosure.lean`, and
`~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`.
**Reference grounding tier**: Tier 1 (literature-backed — Rabinovich 2014) + Tier 3
(implementation-backed — landed task-321 Stage A/B assets).

Every load-bearing claim in the binding spawn-analysis
(`specs/321.../reports/02_spawn-analysis.md`) and task 324's description was driven to a
file:line verdict against the actually-landed source. The spawn-analysis's structural
conclusions are **all machine-confirmed**; two carry precision refinements that the planner
must respect (see Corrections).

## Reference Grounding: Landed-Asset Map (Tier 3)

| Asset | Lean Identifier | Location | Kind / Direction | Status |
|---|---|---|---|---|
| Sub-fold-bit decoder | `kvE_subFoldBits` | NfMultiAnchorBridge.lean:5728 | def, `σ.2 ∘ nf0_assemble` | landed |
| Interior zones list | `kvE_subInteriorZones` | :5751 | def, `[zXU, zUW, zWT]` | landed |
| Nested sub-bracket | `kvE_subBracket` | :5779 | def, `Σ m, BracketFormula (m+1)` | landed |
| Sub-chain predicate | `kvE_subChain` | :5807 | def, `= (…).2.fChainPred` (upward Until) | landed |
| Sole connector | `kvE_subBracket_implies_subChain` | :5824 | thm, **bracket-holds → chain-at-point** | landed |
| Enriched body | `kvE2_body` | :5859 | private def, `ptSub σ = kvE_subChain …` | landed |
| k=2 carrier | `bracketEndChar_kvE2` | :5957 | def | landed |
| `two_eq` bridge | `bracketEndChar_kvE2_two_eq` | :5972 | thm (`rfl`) | landed |
| Discrimination | `kvE_subBracket_witnessCount` / `_ne_of_witnessCount_ne` | :5999 / :6016 | thm, Σ.1-length / injectivity | landed (Stage B) |
| k1v soundness template | `bracketEndChar_k1v_sound` | :2338 | `holds → ∃ w, nf_eval_nf M 1 3` | landed |
| k1v completeness template | `bracketEndChar_k1v_complete` | :2979 | `∃ w, nf_eval_nf M 1 3 → holds` | landed |

## Adversarial Self-Verification

| Claim | Source/Counterexample | Verification Method | Confidence | Verdict |
|-------|------------------------|----------------------|------------|---------|
| **C1** — `kvE_subBracket`/`kvE_subChain` supply only a strictly-upward Until chain from outer slot `u`; zXU=(x,v,u) below `u` structurally unreachable | `kvE_subChain` :5807 = `.2.fChainPred`; `fChainFrom_base`/`_step` (EANegation:580/:616) built solely from `Formula.untl` with `∃ s, x < s` (strictly forward); anchor point is the σ-witness slot `u` in `kvE2_body` (`ptSub σ`, :5919); honest order x<u<w<t makes zXU below `u` | lean source read (:5807, :5919, EANegation:580-676); Rabinovich Prop 3.5 (md:87-94) | High | **CONFIRMED** (with refinement — see Correction 1) |
| **C2** — sole connector `kvE_subBracket_implies_subChain` runs bracket-holds → chain-at-point, wrong direction for soundness | Signature :5824-5835: hyp `h : (…).2.holds M atomMap z0 z`, concl `∃ x0, … kvE_subChain.eval_at M atomMap x0 ∧ …`. Soundness needs the reverse: chain/eval-at-point → `∃ w, nf_eval_nf M 1 4` (cf. k1v template :2338) | direct signature read (:5824) vs k1v_sound signature (:2338) | High | **CONFIRMED** |
| **C3** — no arity-4 sub-bracket correctness pair exists among landed assets | Full enumeration of kvE/kvE2 lemmas after :5700 = {subFoldBits, subFoldBits_eq_destructors, subInteriorZones, subBracket, subChain, subBracket_implies_subChain, kvE2_body(+gate_fail), bracketEndChar_kvE2(+two_eq), witnessCount, ne_of_witnessCount_ne}. None has shape `holds ↔/→ ∃ w, nf_eval_nf M 1 4`. The two witnessCount lemmas are Σ.1-length/injectivity discrimination (:5999/:6016), not correctness | grep enumeration + signature inspection of every hit | High | **CONFIRMED** |
| **C4** — cited consume-do-not-rebuild locations still resolve | `nf_eval_depth1_fold_iff` :5187 ✓; `nf0_assemble` NfEFold.lean:180 ✓; `nf_quant_layer_fold_iff` NfEFold:391 ✓; `bracket_implies_fChainPred` EANegation:660 ✓; `existsBounded_right` VecEAClosure:265 ✓; k1v kit ~:2028-2825 ✓ (header :2022, extract :2150); k1v_sound :2338 ✓ / k1v_complete :2979 ✓ | `sed`/`grep` line-resolution on each cited file:line | High | **CONFIRMED** |
| **C5** — report `01_blocker-research-successor-k.md` §2 (Q1-Q3) is the binding successor-parameterized σ.2 design spec | File present; §2 at line 43 with Q1 (:45), Q2 (:90), Q3 (:157). Imposes: successor-parameterize the whole layer at `j+1` (carrier `BracketEndCharCarrierV sig (j+2)`), each sub `σ : NormalForm sig (j+1) 4`, `σ.2` read via `nf0_assemble` at gate instance `j=0`; `j=0` closes `two_eq` by `rfl` | report read (:43-172); consistency-checked against landed `kvE2_body`/`bracketEndChar_kvE2` (:5859/:5957) | High | **CONFIRMED** |
| **C6** — the proposed redesign (Since+Until pair, or anchor at x) is concretely grounded, not a deferred crux | Both options are literature-derived (see C7): "anchor at x" = the landed k1v bracket geometry (:2338 anchors over `(x,t)`, one arity down) lifted up; "Since+Until pair" = Prop 3.5's two-sided translation (`Formula.snce` already used in `kvE2_body` epL zPastX, :5893). Final choice deliberately deferred to proof-driven iteration | source cross-read (:5893, :2338) + Rabinovich Prop 3.5 | Medium | **CONFIRMED — grounded** (residual risk flagged, Correction 2) |
| **C7** — the all-three-zones `[zXU, zUW, zWT]` reachability requirement is correctly derived from the semantics | Def 3.1 (md:61-74): exists-forall formula = interval decomposition; σ:`NormalForm sig 1 4` over env [u,w,x,t] under x<u<w<t has exactly interior sub-intervals (x,u)=zXU, (u,w)=zUW, (w,t)=zWT. Faithful `nf_eval_nf M 1 4` demands a positive inner witness realizable in ANY of the three. Prop 3.5 (md:87-94): interval decomposition maps to nested Until **AND** Since — the Since branch is what reaches points below the anchor | Rabinovich Def 3.1, Prop 3.5, Cor 5.4; cross-checked vs `kvE_subInteriorZones` :5751-5760 | High | **CONFIRMED** |

**Source-coverage note (H3 No-Single-Source rule):** every structural verdict is backed by
BOTH the landed Lean source AND the Rabinovich text where semantics is load-bearing (C1, C6,
C7). No verdict rests on the spawn-analysis's own assertion alone.

## Corrections

No claim is **REFUTED**. Two claims are **CONFIRMED with precision refinements** the planner
must carry forward verbatim (misreading either reproduces the original defect pattern):

### Correction 1 — C1: distinguish "zone absent from the list" from "zone unreachable on read-back"

`kvE_subInteriorZones` (:5751-5760) **does** list all three zones including `zXU`, and
`kvE_subBracket` (:5787-5789) **does** emit `posSlots` for `zXU`'s positive fold bits. The defect
is **not** that `zXU` is forgotten. The defect is in the **read-back geometry**: `kvE_subChain`
= `fChainPred` is a single **upward** Until chain (EANegation:580/:616, built only from
`Formula.untl`, each step `∃ s, x < s`), and in `kvE2_body` it is anchored/evaluated at the outer
σ-witness slot point `u` (`ptSub σ`, :5919). Under the honest order `x < u < w < t`, `fChainPred`
at `u` constrains only points `> u` (toward w, t) — so `zUW=(u,w)` and `zWT=(w,t)` are reachable
but `zXU=(x,u)`, lying **below** the anchor, is not. Consequently the Phase-8 soundness
obligation (from `kvE_subChain` holding at `u`, reconstruct σ's full `nf_eval_nf M 1 4` including
a `zXU` witness below `u`) is unsatisfiable.

**Planner consequence:** the fix is **NOT** to add `zXU` to the zone list (already present).
The fix must change the **read-back geometry** so a witness below the anchor is expressible —
either restore Prop 3.5's Since half, or re-anchor at the lower endpoint `x` (see Correction 2).
Why k1v worked one arity down: `bracketEndChar_k1v` anchors its bracket over `(x,t)` at the lower
endpoint `x`, so a single upward chain reaches every interior zone `zXW`,`zWT`. `kvE2` broke this
by anchoring at an interior point `u`. This is the precise divergence root cause.

### Correction 2 — C6: the redesign is grounded, but the completeness direction is genuinely unproven (residual risk)

The two remedy options are literature-grounded and viable:

- **Anchor-at-x**: lift the landed k1v geometry (lower-endpoint anchor over `(x,t)`) one arity
  up. A single upward `fChainPred` then reaches all three interior zones. Likely the smaller
  delta; reuses the proven upward-only `fChainFrom` machinery unchanged.
- **Since+Until pair**: implement Prop 3.5's full two-sided translation — Until forward for
  zones above the anchor, `Since` backward for `zXU` below. `Formula.snce` is already in use in
  `kvE2_body` (:5893, epL/zPastX), so the machinery exists, but there is no landed
  `fChainFrom`-analog for the Since direction — it would need building.

**Residual risk (must be surfaced to the planner, not buried):** report §2/Q3 (:164-168) itself
states the reverse (completeness) direction — `nf_eval_nf` inner witnesses ⇒ `IntervalPattern.holds`
data (monotone enumeration, range/point/segment conditions) in the Lemma 5.3 (md:137-152) style —
is **genuinely unprobed at k≥2**. Neither remedy option has been machine-driven through
completeness. The original `kvE_subBracket` defect is precisely a construction that type-checked
and passed probes but had a latent soundness gap discovered only when the proof was driven. The
planner MUST budget the redesign as **proof-driven** (validate the construction by closing BOTH
soundness and completeness, per zone, with concrete per-zone reachability lemmas) and MUST NOT
accept a type-checking/probe-clean construction as done. This is the divergence-audit lesson.

## Divergence Audit (H5)

| Target | Churn | Last-attempted approach | Failure reason (machine-grounded) |
|---|---|---|---|
| Per-sub soundness crux (task 321 Phase 8) | 1 blocker record + spawn | Consume `kvE_subChain`-at-`u` to reconstruct `nf_eval_nf M 1 4` | Upward-only chain anchored at interior `u` cannot express `zXU` witness below `u` (Correction 1) |
| Sub-bracket correctness pair (arity 4) | 0 (never built) | — | Genuinely unbuilt; no `_sound`/`_complete` for `kvE_subBracket` exists (C3) |
| Joint per-sub channel (F1-F4 lineage) | 4 prior dispatches (F1-F4) | Flat `charK (nfk_projFresh σ)` literal | Positionally vacuous — subs sharing `nfk_projFresh` differ only at `σ.2` (probe P1 collapse :5647) |

**Root cause (postmortem):** a construction (`kvE_subBracket`) was landed as `[COMPLETED]` on
type-check + probe grounds **before** its correctness pair was attempted. The `zXU` gap is a
read-back-geometry defect invisible to type-checking, visible only when the soundness direction
is driven through `nf_eval_depth1_fold_iff`. The corrective discipline (encoded in task 324's
own description) is: co-design construction and correctness in one continuous proof-driven
dispatch; never accept probe-clean as correct.

## Sorry Inventory (context for do-not-consume constraint)

| Identifier | State | Location | Why do-not-consume |
|---|---|---|---|
| EANegation uniform-backward variant | carries `sorry` | EANegation.lean:1090 | machine-confirmed `sorry` at :1090; forbidden by constraint |
| EANegation uniform-backward variant | carries `sorry` | EANegation.lean:1249 | machine-confirmed `sorry` at :1249; forbidden by constraint |

The task's "No EANegation :1090/:1249" constraint is machine-justified: both lines are live
`sorry`s (grep-confirmed). Consuming them would import proof debt onto task 324's live path,
violating the zero-sorry mandate. The sanctioned consume targets (`bracket_implies_fChainPred`
:660, `fChainFrom_base`/`_step` :580/:616) are distinct lemmas and are not on that list.

## Type-Mismatch / Direction Analysis

| Obligation | Needed shape | Landed asset shape | Mismatch |
|---|---|---|---|
| Per-sub soundness | chain/eval-at-point → `∃ w, nf_eval_nf M 1 4` | `kvE_subBracket_implies_subChain`: bracket-holds → chain-at-point (:5824) | reversed direction (C2) + `nf_eval_nf` reconstruction absent |
| zXU realization | witness in `(x, v, u)`, below anchor `u` | upward `fChainPred` from `u` (:5807) | geometric: below-anchor unreachable (Correction 1) |
| Correctness pair | `holds ↔ ∃ w, nf_eval_nf M 1 4` | none | absent entirely (C3) |

## Planning Constraints (machine-grounded, for the /plan dispatch)

Distilled from verified findings — supersedes any softer phrasing in the spawn analysis:

1. **Redesign the read-back geometry, not the zone list.** `kvE_subInteriorZones` already lists
   `[zXU, zUW, zWT]`; the new construction (`kvE_subBracket2`/`kvE_subChain2`, additive) must make
   a witness **below the anchor** expressible. Do NOT "fix" by re-listing zones (Correction 1).
2. **Two literature-grounded options; choose by proof-driving both directions.** Anchor-at-`x`
   (lift k1v lower-endpoint geometry, single upward chain reaches all three zones) OR Since+Until
   pair (Prop 3.5 two-sided). Prefer the one that closes soundness AND completeness; do not commit
   on type-check alone.
3. **Deliver the full correctness pair** (C3 gap): a soundness lemma (`holds → ∃ x1,
   nf_eval_nf M 1 4 (Fin.cons x1 [w,x,t]) σ`) and a completeness lemma (reverse), the arity-4
   analog of `bracketEndChar_k1v_sound` (:2338) / `_complete` (:2979). Both standalone against
   `nf_eval_nf M 1 4`, NOT wired into the outer gate.
4. **Per-zone concrete reachability evidence is mandatory** (not a probe). One lemma/probe per
   zone `zXU`, `zUW`, `zWT` proving the new chain reaches it — the discipline whose absence caused
   this blocker.
5. **Completeness is the unbudgeted risk.** Report §2/Q3 flags it unprobed; construct
   `IntervalPattern.holds` witnesses in Lemma 5.3 (md:137-152) order-theoretic style. Size this as
   multi-phase, plausibly multi-dispatch; a single "prove the pair" phase repeats the sizing error.
6. **Do-not-edit / do-not-consume are exactly as landed.** Originals (`kvE_subBracket`,
   `kvE_subChain`, `kvE2_body`, `bracketEndChar_kvE2`, k1v kit :2028-2825) stay byte-identical and
   unreferenced by new work; add separately-named defs only. Do NOT re-point `kvE2_body`/
   `bracketEndChar_kvE2` (that is task 321's future /revise). Never consume EANegation :1090/:1249
   (live `sorry`s, machine-confirmed).
7. **Guards G1-G6 + F3 + literature-fidelity:** anchor count ≤ 2 (fixed `{x,t}`); Cor 5.4 F_i
   chains step-by-step with a Rabinovich citation per chain step; no `simp`/`omega`/`aesop` on
   chain-construction steps (`by omega` only for `Fin`-index typing); no provider-side pinning
   (F3); no `sorry` on any live path including WIP.
8. **Compatibility with the successor-parameterized read (C5):** the new construction must remain
   compatible with the `j+1` layer / `σ.2 ∘ nf0_assemble` read fixed at gate instance `j=0`
   (report §2/Q1-Q2); `two_eq`-style `rfl` bridge preserved.

## Overall Assessment

The spawn-analysis's four structural pillars (C1-C4) and its literature grounding (C7) are
**machine-confirmed**; the successor-parameterized design spec (C5) exists and binds; the
proposed redesign is **grounded, not deflection** (C6). This RESEARCHED status is well-founded.
The one substantive addition adversarial verification makes is **Correction 1** (the defect is
read-back geometry, not a missing zone) and **Correction 2 / Constraint 5** (completeness is a
real, unbudgeted, proof-driven risk that must not be accepted on type-check). Planning may
proceed with the eight constraints above binding.
