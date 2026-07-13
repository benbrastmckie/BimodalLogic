# Faithful Pinned-Converse Repair — Task 360 (Round 2, post-refutation re-adjudication)

**Task**: 360 — restate_exterior_hbr_pinned_converse (Phase 3 [BLOCKED] escalation)
**Agent**: lean-research-hard-agent · **Mode**: --hard --lit (H3 Tier 1, H4 active)
**Date**: 2026-07-13 · **Session**: sess_1783950096_9d2925
**Inputs**: handoffs/phase-3-handoff-20260713T190000Z.md (canonical defect record),
`kvE_futPinned_of_end_zero_refuted` + salvage lemmas (ExteriorPinnedConverseK.lean, GREEN),
task-358 reports/03 §2.3–2.4/3.3/6, Rabinovich 2014 chunks 0015/0016/0022/0023 (read verbatim
this dispatch), ExteriorConverterK/ExteriorBracketAssembleK/ExteriorNegationK/
EndIntervalConsumerK/NormalForm.lean (read this dispatch).
**Scope**: research only — no production `.lean` edit; tree at green HEAD `be5086f6b`.

---

## TL;DR

- **Q1 (paper adjudication)**: Rabinovich's Cor 5.4(1)⇐ / 5.4(2) reconstruct ONLY
  walked-segment + endpoint content — his brackets `[α0,β1,…,αn](z0,z)` speak exclusively about
  the segment `(z0,z)` and its endpoints (chunk_0015:11–37; Figure 1, chunk_0016:15). Interior
  (other-segment) content is carried by the OTHER conjuncts of the Def 7.13 adjacent-segment
  decomposition (chunk_0023:25), never inferred from the chain. **The paper supplies NO
  interior-zone marks**; the faithful converse claim is exterior-slice + atom-layer agreement
  only. The machine refutation and the paper agree.
- **Q2 (repair)**: **Neither (a) nor (b) as posed survives adversarial checking.** (b) is
  unfaithful and has no true supplier (§3.2). (a) is the faithful *converse conclusion* but is
  insufficient alone, because the defect propagates one level up: the per-σ negative-clause
  bracket `kvE_extBracketFut P qnf` is an **unsatisfiable formula for every honest qnf**
  (it conjoins `kvE_futPos P τ` for the marked honest endpoint type τ with
  `¬ kvE_futPos P σ′` for the unmarked erased variant σ′, and `kvE_futPos P σ′ = kvE_futPos P τ`
  *syntactically* — the machine-proven `hPosEq` step of the refutation). No binder repair can
  make the gate biconditional true against an unsatisfiable formula.
- **Recommended repair (faithful third option, subsuming (a))**: **slice-quotient the
  clause keying** (Rabinovich Def 7.13 discipline: a clause's negation footprint must equal
  its content footprint) — re-key the bracket's per-σ if-then-else from `qnf.2 σ` to
  "some admissible slice-mate of σ is qnf-marked" — and replace the refuted §2.4 converse by
  the **exterior-slice identification theorem** `kvE_futSliceId_of_end_zero` (σ★ := the honest
  endpoint characteristic, qnf-marked, atom-layer- and exterior-zone-equal to σ). The four
  `hbr*` obligations are then **eliminated** (report 03 §3.2's preferred shrink), replaced at
  general k by ONE true-shaped slice-honesty obligation, **discharged at m = 0**.
- **m = 0 sufficiency for 358:361**: YES — §5 gives the complete per-case consumption route;
  every supplier is landed or probe-validated. The σ′ witness satisfies (does not refute)
  every statement of the recommended shape (§7, H4 rows V1–V5).

---

## 1. Q1 — what Rabinovich's construction actually establishes

### 1.1 The bracket's footprint is the segment, nothing else

Cor 5.4(1) (chunk_0015:11): "there is z ∈ (z0, z1) such that
[α0, β1, α1, β2, …, αn−1, βn, αn](z0, z) **iff** F0(z0) and there is an increasing sequence
x1 < ⋯ < xn in an open interval (z0, z1) such that Fi(xi)". The ⇐ induction (chunk_0015:19–37)
reconstructs the endpoint `z` from the Until-witness `y2` and the milestone `xn+1` — every fact
consumed and every fact produced is about `z0`, the open interval, and the endpoint. The bracket
formula on the left side asserts a partition/labeling of `(z0, z)` ONLY. Figure 1
(chunk_0016:15) states this explicitly for the composite:
`B2(z0, z, z1) := [α0,β1,α1,β2,β2](z0, z) ∧ [β2,β2,α2,β3,α3](z, z1)` — content about the region
left of `z0` or right of `z1` simply does not occur in either conjunct.

### 1.2 Negation is applied per segment bracket, never per full type

Lemma 5.1 / Lemma 7.8 (chunk_0015:45–47, chunk_0022:9–13) negate exactly ONE bracket:
`¬[α0,β1,…,αn](z0,z1)`. The Case 2 route (chunk_0016:17) consumes Cor 5.4(2) for "there is no
z ∈ (z0,z1) such that [α1,β2,…,αn](z,z1)" — again a *segment* formula. Def 7.13
(chunk_0023:25) then decomposes any multi-anchor formula into a conjunction of per-adjacent-
segment formulas `ϕi(zi, zi+1)` plus a final `(zk, ∞)`-formula. Consequence: in the paper, **the
object whose negation the O_n device expresses always has exactly the expressive footprint the
O_n device can see.** There is no step anywhere that asserts "¬(segment content) because the
enclosing TYPE (which also carries other-segment content) is not realized".

### 1.3 The project's divergence, precisely located

The in-tree bracket (ExteriorBracketAssembleK.lean:46–53) conjoins, over ALL admissible
`σ : NormalForm sig (k+1) 4`:

```
if qnf.2 σ = true then kvE_futPos P σ else kvE_extNegFut P σ
```

The clause formulas `kvE_futPos`/`kvE_extNegFut` depend on σ only through its **exterior
slice** — `(σ.1, gap/ray/self zone lists)` (ExteriorNegationK.lean:363–428: `GapD`, `RayForm`,
`End`, `Chain`, `Pos` read `σ.2` exclusively via `kvE_fiberZoneList σ` at the three exterior
zones). The keying predicate `qnf.2 σ`, however, distinguishes σ's by **interior marking** the
clause cannot express. This footprint mismatch is the exact unfaithful step relative to
Def 7.13, and the σ′ witness is its Curry-Howard invoice.

**Q1 answer**: the paper's construction supplies exterior-segment (gap-interval + endpoint +
ray) content only; the faithful claim of the converse is atom-layer + exterior-zone fold
agreement. The §2.4 full-σ conclusion over-claimed by exactly the six interior zones — which is
what `kvE_futPinned_of_end_zero_refuted` proves.

---

## 2. The structural finding beyond the handoff: the honest bracket is unsatisfiable

The handoff records that σ′ refutes the §2.4 converse and the weakened `qnf.2 σ = true`
conclusion. Chaining the machine-proven facts one level up gives a strictly stronger result
that the repair must confront:

1. `kvE_futPos P σ′ = kvE_futPos P τ` **as formulas** — machine-proven (`hPosEq`,
   ExteriorPinnedConverseK.lean:585–590, via `kvE_fiberZoneList_congr` +
   `kvE_futAdmissible_of_subMarking`).
2. For the honest qnf (`nf_characteristic M 2 3 [w,x,t]`): `qnf.2 τ = true` (τ pinned-realized,
   `nf_characteristic_satisfies`; the probe's `kvE_probe_endpoint_totality` machine-validates
   this) and `qnf.2 σ′ = false` (σ′ realizable at NO `[y,w,x,t]`: any y satisfying σ′.1 carries
   x1's complete atomic profile — `NormalForm sig 0 4` prescribes every predicate — so
   `e = nf_characteristic M 0 5 [w,x1,w,x,t]` transfers to `[w,y,w,x,t]` with the same witness
   `w`, and the fold fails at the unmarked `e`; see V4 in §7 for status).
3. Both τ and σ′ pass the admissibility filter (machine-proven `hτadm`, `hadm'`), so BOTH
   appear in the bracket's conjunction (ExteriorBracketAssembleK.lean:50–53 filters
   `Finset.univ` by `kvE_futAdmissible` only).
4. Therefore `kvE_extBracketFut P qnf` contains the conjuncts `kvE_futPos P τ` **and**
   `(kvE_futPos P τ).neg` — it is **unsatisfiable at every point of every model**.

Consequences:
- The completeness direction "qnf realized ⇒ bracket true at t" (`kvE_extBracketFut_complete`,
  and everything downstream: `bracketEndChar_kvExt_correct_prior`, `endInterval_step_correct`,
  the KampPrior :845–870 mirror, task-349 v8 Phase 6's target, task-358's :361 route) is
  **false as a mathematical statement** for every honest qnf with a realized exterior
  configuration. It is currently rescued only by its false `hbrFutSat`-shaped hypotheses:
  the SAME witness pair (σ′, e) makes the Phase-1 GUARDED `hbrFutSat` false (e is on-fiber,
  pinned-realizable at witness `w`, unmarked in σ′, and every guard antecedent holds — the
  refutation theorem's conjuncts are verbatim the guard set). So Phase 5's
  `kvE_hbrFutSat_supply_zero` is unprovable, confirming the handoff's blast-radius warning.
  (`hbrFutReal` is NOT refuted by σ′ — erasure only shrinks the marked set — but it is
  eliminated anyway under the repair.)
- **No repair that keeps per-σ clause keying can succeed.** This structurally rules out
  candidate (b): even if an interior-marking supplier antecedent existed (it does not — §3.2),
  the bracket formula itself remains unsatisfiable for honest qnf, so the gate biconditional
  stays false regardless of how the converse's hypotheses are strengthened.
- The frozen k=2 layer (`kvE2_extBracketFut`, ExteriorBracket.lean:364) uses the same per-σ
  keying pattern and should be audited for the same defect (out of this task's scope; flagged
  for the orchestrator — see §8).

---

## 3. Q2 — adjudication of the repair candidates

### 3.1 Candidate (a) — weaken the conclusion: FAITHFUL but insufficient alone

(a)'s conclusion (atom-layer pinning + exterior-zone fold agreement) is exactly what
Cor 5.4(1)⇐ + the endpoint description license (§1.1), and σ′ does not refute it (σ′'s
exterior lists equal τ's — machine-proven `hgapL`/`hrayL`/`hselfL`). Phase 2's
`kvE_futAtomPinned_zero` and the four `*_of_realizer` lemmas are its landed core. **But** a
bare conclusion-weakening leaves the unsatisfiable bracket (§2) in place: the weakened converse
cannot discharge `kvE_extNegFut σ′` at the D3 site because `¬ kvE_futPos σ′` is FALSE at `t`
(σ′'s chain fires — machine-proven). (a) alone therefore does not restore any provable
consumption chain.

### 3.2 Candidate (b) — interior-marking supplier antecedent: UNFAITHFUL and unavailable

- **Paper side**: no step in §5/§7 supplies interior-segment content from chain truth (§1.2).
  An interior-marking antecedent has no Rabinovich counterpart to transcribe.
- **Supply side**: the only in-tree data that could pin σ.2's interior bits is honesty relative
  to a realizer — i.e. (part of) the conclusion. The natural `qnf.2 σ = true` link is
  unavailable at the consumption site (the interesting σ there are unmarked, report 03 §2.4
  consequence (b)), and `qnf.2 σ` does not determine σ's interior bits anyway (σ′ and τ share
  qnf, differ interiorly). Threading "σ's interior marking is honest" as an antecedent from
  KampPrior:361 would be threading a model-dependent predicate with no formula-level or
  recursion-level supplier — precisely the 354→356→357 mistake shape (obligation without a
  discharge site) in new clothing.
- **And** (b) inherits §2's structural kill: per-σ keying stays unsatisfiable.

### 3.3 The faithful repair — slice-quotient the clause keying + slice-identification converse

Restore the Def 7.13 footprint discipline: **the clause key must be a function of the same
data as the clause formula.** Concretely (new defs, Future side; Past mirrors symmetric):

```lean
/-- Exterior-slice equality: same atom layer, same three exterior zone lists.
    The clause family kvE_futPos/kvE_futEnd/kvE_futGapD/kvE_extNegFut is constant on
    slice classes of admissible σ (proof: kvE_fiberZoneList_congr pattern, landed). -/
def kvE_futSliceEq {sig : MonadicSignature} {k : Nat}
    (σ' σ : NormalForm sig (k + 1) 4) : Bool :=
  decide (σ'.1 = σ.1) &&
  decide (kvE_fiberZoneList σ' kvE_futGapZone  = kvE_fiberZoneList σ kvE_futGapZone) &&
  decide (kvE_fiberZoneList σ' kvE_futRayZone  = kvE_fiberZoneList σ kvE_futRayZone) &&
  decide (kvE_fiberZoneList σ' kvE_futSelfZone = kvE_fiberZoneList σ kvE_futSelfZone)

/-- σ's exterior slice is qnf-marked: some admissible slice-mate carries the bit. -/
def kvE_futSliceMarked {sig : MonadicSignature} {k : Nat}
    (qnf : NormalForm sig (k + 2) 3) (σ : NormalForm sig (k + 1) 4) : Bool :=
  (Finset.univ.toList (α := NormalForm sig (k + 1) 4)).any
    (fun σ' => kvE_futAdmissible σ' && kvE_futSliceEq σ' σ && qnf.2 σ')
```

and re-key the bracket (ExteriorBracketAssembleK.lean:53):

```lean
if kvE_futSliceMarked qnf σ = true then kvE_futPos P σ else kvE_extNegFut P σ
```

This is pure syntax (decidable over the NF fintype, exactly the `Finset.univ.toList.filter`
idiom already in the file). Faithfulness: a negative clause `¬ kvE_futPos P σ` is now asserted
iff **no marked type carries σ's segment content** — which is the paper's
"¬∃z [segment](t, z)" (Cor 5.4's negated object), never "type σ is unrealized". The honest
bracket becomes satisfiable: σ′'s conjunct flips to the positive `kvE_futPos P σ′
(= kvE_futPos P τ)`, true at `t`.

**The converse to implement** (replaces the refuted §2.4 statement; this is the exact restated
signature):

```lean
/-- Exterior-slice identification at m = 0 (Rabinovich Cor 5.4(1)⇐ + Cor 5.4(2)
    re-anchoring, under the Def 7.13 segment discipline): at a destructor-selected
    exterior endpoint carrying the endpoint/walk truths, under the level-up ambient,
    the endpoint's HONEST complete type σ★ is qnf-marked, pinned-realized at
    [x1,w,x,t], and agrees with σ on the atom layer and on every exterior-zone
    marking. (σ★ := nf_characteristic M 1 4 [x1,w,x,t].) -/
theorem kvE_futSliceId_of_end_zero {sig : MonadicSignature}
    {atomMap : Formula → sig.preds}
    (P : ExistProviders sig atomMap 0)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (qnf : NormalForm sig 2 3) (σ : NormalForm sig 1 4)
    (hadm : kvE_futAdmissible σ = true)
    (hfib : nfk_dropFresh σ = qnf.1)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)   -- AMBIENT
    (x1 : M.carrier) (htx1 : t < x1)
    (hend : temporal_truth M atomMap x1 (kvE_futEnd P σ))               -- endpoint
    (hgap : ∀ r : M.carrier, t < r → r < x1 →
      temporal_truth M atomMap r (kvE_futGapD P σ))                     -- destructor
    (hocc : ∀ s ∈ kvE_fiberZoneList σ kvE_futGapZone, ∃ r : M.carrier,
      t < r ∧ r < x1 ∧ temporal_truth M atomMap r (kvE_futItemShift P s)) :
    ∃ σ' : NormalForm sig 1 4,
      qnf.2 σ' = true ∧
      nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ' ∧
      σ'.1 = σ.1 ∧
      ∀ s : NormalForm sig 0 5,
        (nfk_zoneSpec s = kvE_futGapZone ∨ nfk_zoneSpec s = kvE_futRayZone ∨
         nfk_zoneSpec s = kvE_futSelfZone) → σ'.2 s = σ.2 s
```

(The last conjunct + `kvE_fiberZoneList_congr` yields `kvE_futSliceEq σ' σ = true`; the
`hpos` antecedent is not needed — Phase 2 already showed the atom layer consumes only
`hadm`/`hfib`/`h`/`hend`.)

**Reconstruction-side companion** (the internal-`hexclExt`-style discharge for the soundness
direction; closes with landed machinery because `nf_eval_nf` at depth ≥ 1 forces the FULL
marking, so a realized σ is literally unique):

```lean
/-- m = 0 slice uniqueness: two σ's realized at (possibly different) exterior
    endpoints over the same [w,x,t] with equal exterior slices are EQUAL.
    Route: nf_eval_unique pins σ = characteristic at its endpoint; slice-equal atom
    layers give the two endpoints the same complete atomic profile; depth-0 interior
    fiber elements transfer between profile-equal endpoints with the SAME witness;
    exterior zones agree by hypothesis. -/
theorem kvE_futSliceUnique_zero … :
    kvE_futSliceEq σ' σ = true →
    nf_eval_nf M 1 4 (Fin.cons x1  …) σ →
    nf_eval_nf M 1 4 (Fin.cons x1' …) σ' →
    σ' = σ
```

**Proof route of `kvE_futSliceId_of_end_zero`** (all suppliers landed or probe-validated;
per-zone case list is FIXED):
1. σ★ := `nf_characteristic M 1 4 [x1,w,x,t]`; `nf_characteristic_satisfies` gives the pinned
   realization; `(h.2 σ★).mp` gives `qnf.2 σ★ = true` (probe (b) mechanism).
2. `σ★.1 = σ.1`: Phase-2 `kvE_futAtomPinned_zero` (σ.1 realized at `[x1,w,x,t]`) +
   `nf_eval_unique` at depth 0 against σ★'s atom layer.
3. Gap-zone agreement, σ ⊆ σ★: `hocc` places each listed s free-env at r ∈ (t,x1); the probe's
   `kvE_probe_gapItem_pinned` upgrade (on-fiber + zone + placement + pinned atom layer →
   pinned realization via `nf_eval_nf0_cons_factor`) → σ★ marks s (honest). σ★ ⊆ σ: s realized
   at v ∈ (t,x1) → `hgap` at v gives a σ-listed s″ free-env at v → upgrade → depth-0
   `nf_eval_unique` forces s″ = s → s σ-listed.
4. Ray agreement: σ ⊆ σ★ via `hend`'s per-item ray conjuncts (+ upgrade, probe
   `kvE_probe_rayItem_pinned`); σ★ ⊆ σ via `hend`'s `¬F(¬D_ray)` conjunct (every point above
   x1 carries a σ-listed ray element) + uniqueness.
5. Self agreement: `hend`'s self conjunct is a disjunction over σ's self list (empty list = ⊥,
   so nonemptiness is forced); coincidence `kvE_futSelfZone_coincide` pins the witness to x1;
   uniqueness identifies the listed element with σ★'s self element; admissibility conjunct 4
   bounds σ's self list to one profile.

### 3.4 Interface consequence: the hbr* obligations disappear

With the re-keyed bracket, the D3/D4 negative case changes from "prove `kvE_extNegFut σ` for
each unmarked σ" (false for σ′) to "prove it for each **slice-unmarked** σ": by_contra the
chain fires → `kvE_futChainDestructG` → endpoint x1 + `hend`/`hgap`/`hocc` →
`kvE_futSliceId_of_end_zero` → a marked slice-mate exists → contradicts slice-unmarked. **No
`hreal`/`hsat`/`hbr*` binder is consumed.** At m = 0 the entire four-obligation family is
eliminated from D3/D4 → gate → `EndIntervalCorrectPrior` → KampPrior :845–870 (all task-360
territory, already re-threaded once in Phase 1). At general k, the destructed facts cannot yet
be converted (level-descent, out of scope), so ONE new true-shaped obligation is carried per
side:

```lean
-- general-k carried obligation (replaces hbrFutReal + hbrFutSat), Future side:
(hsliceFut : ∀ w, x < w → w < t →
  nf_eval_nf M (m + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf →
  ∀ σ, kvE_futAdmissible σ = true →
    temporal_truth M atomMap t (kvE_futPos (Pfam m) σ) →
    ∃ σ', kvE_futAdmissible σ' = true ∧ kvE_futSliceEq σ' σ = true ∧ qnf.2 σ' = true)
```

H4 check: σ′ satisfies this (σ' := τ). The obligation is implied by lower-level correctness
(it is Cor 5.4(1)⇒'s content at the next depth) and is **discharged at m = 0 by
`kvE_futSliceId_of_end_zero` + chain destruction** — the revised Phase 5 supply theorem.

The soundness direction (D1) weakens to slice-level exclusion; per-σ exclusion for
bit-false-but-slice-marked σ is recovered where consumed via `kvE_futSliceUnique_zero` + the
already-carried interior-style `hreal` binder ("marked ⇒ realizable", EndIntervalConsumerK
:117–122): a marked slice-mate σ' is realizable at some x1′, uniqueness collapses σ' = σ,
contradiction with the bit split. This is the same shape as task-348's internal `hexclExt`
discharge at the frozen k=2 layer.

---

## 4. Literature Proof Structure (Tier 1)

Rabinovich 2014, §5 + §7, mapped to the repair:

| Step | Paper statement | Role in repair |
|---|---|---|
| S1 | Cor 5.4(1) observation (chunk_0015:11): ∃z with bracket(z0,z) iff F0(z0) ∧ milestones Fi(xi) in (z0,z1) | The chain device + destructor (landed: `kvE_futChainG`, `kvE_futChainDestructG`) |
| S2 | Cor 5.4(1)⇐ induction (chunk_0015:19–37): Until-witness y2, min/case-split vs milestone xn+1 | Realizer engine (landed: `kampPrior_fChain_realize*`, task 358 P2) |
| S3 | `¬F0(z0) ∨ On(F1,…,Fn,z0,z1)` (chunk_0015:39–41) as the negation device | `kvE_extNegFut` — asserted per SEGMENT content; the re-keying restores this |
| S4 | Cor 5.4(2) mirror (chunk_0015:43), consumed in Lemma 5.1 Case 2 (chunk_0016:17) | Fresh-slot re-anchoring (landed: `kvE_futItemShift_correct`) |
| S5 | INF definability eq. 5.3 (chunk_0016:19) | `HasAttainedINF` (landed, arity 2) |
| S6 | Def 7.7 canonical expansion (chunk_0022:5): truth at a point = complete pinned datum | `nf_characteristic`/`_satisfies`/`nf_eval_unique` — the σ★ construction |
| S7 | Def 7.13 (chunk_0023:25): multi-anchor formula = conjunction of per-adjacent-segment formulas; negation applies per segment (Lemma 7.8) | **The repair's core**: clause key must have the clause's footprint → slice quotient |

## 5. m = 0 sufficiency for task 358's `:361` arm

The `:361` arm needs (report 03 §4–5 route): per-qnf endpoint-char correctness at the m+2 arm
instantiated at m = 0, then the carrier→formula fold. Under the repair, every case has a
supplier:

| Consumption case (per admissible σ, honest ambient) | Route | Supplier status |
|---|---|---|
| slice-marked σ: positive clause `kvE_futPos σ` true at t | marked slice-mate σ' realizable (ambient fold `(h.2 σ').mp` / carried `hreal`-interior) → `kvE_futPos_of_realizer` + clause slice-constancy | LANDED (both) |
| slice-unmarked σ: negative clause `¬kvE_futPos σ` true at t | by_contra → destructor → `kvE_futSliceId_of_end_zero` → marked slice-mate → contradiction | NEW (this repair), suppliers landed |
| reconstruction (formula true → realizable σ marked) | realized σ = characteristic (`nf_eval_unique`) → its clause must be positive → marked slice-mate σ' → σ' realizable (`hreal`) → `kvE_futSliceUnique_zero` → σ' = σ marked | NEW lemma, suppliers landed |
| marked-σ pinned realization at the SPECIFIC destructor endpoint (if a downstream consumer needs it) | slice-id gives σ★ realized at x1 with `kvE_futSliceEq σ★ σ`; if σ marked and realizable, uniqueness gives σ = σ★ | corollary of the two NEW lemmas |

No step consumes interior-zone marks from chain truth; no step is refuted by σ′ (H4 §7).
The Past mirror (`:361`'s Past half and Phase 4) is symmetric — the defect and repair transfer
verbatim (`kvE_pastPos`/`kvE_pastEnd`/`kvE_pastGapD` have the same slice-only footprint,
EndIntervalConsumerK :133–161).

**Answer**: the recommended conclusion (slice identification + slice-keyed bracket) closes
358's `:361` m = 0 arm's exterior obligations completely, and does so with a SMALLER threaded
interface than today (four false binders → one true binder per side, discharged at m = 0).

## 6. H3 mapping table (5-column, Tier 1)

| Paper construction (chunk/section) | Claim | In-tree lemma or gap | m = 0 specialization | Faithfulness note |
|---|---|---|---|---|
| Cor 5.4(1)⇐ milestone reconstruction (chunk_0015:11–37) | chain truth at anchor ⇔ ∃ endpoint realizing the SEGMENT bracket | `kvE_futChainDestructG` (LANDED) + `kvE_futSliceId_of_end_zero` (NEW) | destructor facts → honest endpoint type identification | Conclusion must be segment-slice, NOT full-type realization — §2.4 over-claimed; refuted + paper-confirmed |
| Cor 5.4(2) re-anchoring (chunk_0015:43, chunk_0016:17) | mirror bracket anchored at right endpoint | `kvE_futItemShift_correct` (LANDED); Past mirror files | same | Faithful as landed |
| `¬F0 ∨ On` negation device (chunk_0015:39–41) | negation of a SEGMENT bracket is ∨∃∀ | `kvE_extNegFut` (LANDED) — but keyed per full σ at the bracket (GAP) | re-key by `kvE_futSliceMarked` (NEW def) | Negation footprint must equal content footprint (Lemma 5.1/7.8 negate brackets, never types) — the per-σ keying is THE divergence |
| Def 7.7 canonical expansion (chunk_0022:5) | truth at a point is a complete pinned datum | `nf_characteristic`/`_satisfies`/`nf_eval_unique` (LANDED, NormalForm.lean:215/224/245) | σ★ construction; realized σ is unique | Faithful; also yields `kvE_futSliceUnique_zero` (NEW) for the soundness side |
| Def 7.13 adjacent-segment decomposition (chunk_0023:25) | multi-anchor content = conjunction of per-segment formulas; interior content lives in OTHER conjuncts | interior gate + interior obligations (`hreal`/`hexcl`, EndIntervalConsumerK:117–128) — already segment-scoped | unchanged | The exterior converse must NOT be asked to supply interior marks; candidate (b) is unfaithful |
| Lemma 5.3 first-point re-anchoring (chunk_0014, per report 03) | INF-definable re-anchoring | `HasAttainedINF.first_occ` (LANDED) | unchanged | Faithful as landed |

## 7. Adversarial Self-Verification (H4)

| Claim | Source/Counterexample | Verification Method | Confidence |
|---|---|---|---|
| C1. §2.4 converse false at m=0; every hypothesis reads σ.2 through exterior zone lists only | `kvE_futPinned_of_end_zero_refuted` | Read of the GREEN machine proof (ExteriorPinnedConverseK.lean:498–617) + clause defs (ExteriorNegationK.lean:363–428) | High |
| C2. Paper's ⇐ reconstructs segment content only; negation applies per segment bracket | chunk_0015:11–43, chunk_0016:15–17, chunk_0023:25 | direct literature read this dispatch (all four chunks) | High |
| C3. `kvE_futPos P σ′ = kvE_futPos P τ` syntactically | `hPosEq` step | Read of machine proof (:585–590) | High |
| C4. Honest `qnf.2 σ′ = false` (σ′ realizable at no y) | same-witness transfer of `e` to any profile-matching y | reasoning over `nf_characteristic` def (NormalForm.lean:216–222, read) + completeness of depth-0 NFs; NOT machine-run — mandatory probe P1 in the revised plan's Phase 0 | Medium |
| C5. Honest bracket unsatisfiable (conjoins F ∧ ¬F) | C3 + C4 + bracket range = all admissible σ | Read of `kvE_extBracketFut` (:46–53) confirming range and keying | High (conditional on C4) |
| C6. Phase-1 GUARDED `hbrFutSat` false at m=0 | σ′ + e: refutation conjuncts are verbatim the guard antecedents | Read: refutation statement (:504–514) vs restated binder (EndIntervalConsumerK:175–…, ExteriorConverterK:143–152) | High |
| C7. `hbrFutReal` (guarded) NOT refuted by σ′ | erasure shrinks the marked set; τ honest | reasoning over the σ′ construction; not load-bearing (Real half eliminated anyway) | Medium |
| C8. Slice-id theorem provable at m=0 with landed suppliers | §3.3 route steps 1–5 | per-step supplier existence checked by Read (`nf_eval_nf0_cons_factor`, probe lemmas (b)/(c), `kvE_futSelfZone_coincide`, `nf_eval_unique`, destructor conclusions); composite NOT machine-run — mandatory probe P2 | Medium |
| C9. Slice-uniqueness at m=0 (realized σ unique = characteristic; interior same-witness transfer between profile-equal endpoints) | `nf_eval_nf` depth-(k+1) fold quantifies ALL subs (NormalForm.lean:203–207, read); depth-0 elements' endpoint dependence is atomic-profile-only | Read of `nf_eval_nf`/`nf_eval_unique`; transfer argument NOT machine-run — mandatory probe P3 | Medium |
| C10. Clause family constant on slice classes (re-keyed bracket well-behaved) | `hGapDeq`/`hEndEq`/`hPosEq` machine-proven for the σ′/τ pair; general lemma is the same `kvE_fiberZoneList_congr` pattern | Read of the landed invariance lemmas (:379–476) | High |
| C11. Recommended obligation `hsliceFut` true at σ′; slice-keyed honest bracket satisfiable at σ′'s conjunct | σ' := τ | direct check against the machine witness | High |

**Mandated refutation attempt against the recommendation** (the delegation's H4 requirement):
I re-ran the σ′ witness against every statement of the recommended shape. (i)
`kvE_futSliceId_of_end_zero` at σ := σ′: conclusion asserts a marked slice-mate — τ is one;
TRUE. (ii) re-keyed bracket at honest qnf: σ′'s conjunct is positive (`kvE_futPos τ`), true at
t; no F ∧ ¬F pair remains, since slice-mates always receive the SAME clause. (iii) `hsliceFut`
at σ′: satisfied by τ. (iv) `kvE_futSliceUnique_zero`: vacuous at σ′ (unrealizable). The
surviving attack surface is C4/C8/C9 (Medium, not machine-run); all three are assigned as
mandatory Phase-0 probes (P1: compile `qnf.2 σ′ = false` on the P3M probe model; P2: the
slice-id composite on P3M; P3: the same-witness interior transfer lemma) in the plan revision —
the same probe discipline whose absence caused the C8 defect. No claim in this report rests on
an unverified "mathlib/paper likely has this"; every cited declaration was existence-checked by
Read in this dispatch.

**Contradiction log**: report 03 §2.3 item 3 + §2.4 claimed the full-σ converse closes at m=0;
`kvE_futPinned_of_end_zero_refuted` proves it false. Resolution per precedence: machine-checked
refutation > report-level reasoning — §2.4 is superseded by §3.3 of this report. Second
contradiction: plan v1 "settled decision 4" (interface stays obligation-carrying; fix is
antecedent repair, not interface redesign) vs §2's unsatisfiability finding. Resolution: the
plan itself scopes settled decisions "do not re-open without a concrete machine
counterexample" — the refutation + hPosEq chain IS that counterexample; decision 4 is
re-opened, and the redesign is confined to files already in task-360's declared territory.

## 8. Recommended plan-revision deltas (for /revise)

1. **Phase 3 (replaces refuted target)**: `kvE_futSliceEq`/`kvE_futSliceMarked` defs +
   slice-constancy of the clause family + `kvE_futSliceId_of_end_zero` (signature in §3.3) +
   `kvE_futSliceUnique_zero`. New Phase-0-style probes P1–P3 gate it.
2. **Phase 3b (new)**: re-key `kvE_extBracket{Fut,Past}` (ExteriorBracketAssembleK.lean:53/:66);
   re-prove D1 (slice-level) and D3/D4 (negative case via slice-id at m=0 route, general-k via
   the carried `hslice*` binder); drop `hreal`/`hsat` from `kvE_extNegFut_complete`'s D3 usage
   (the converter lemma itself may remain for general-k tooling). Only in-territory files:
   ExteriorBracketAssembleK, ExteriorGateAssembleK, EndIntervalConsumerK, KampPrior:845–870
   (grep confirmed no other consumer of the brackets: ExteriorBracketK/GateAssembleK/
   BracketAssembleK only).
3. **Phase 4**: Past mirror of 1–2.
4. **Phase 5**: supply theorems become the m=0 discharges of `hsliceFut`/`hslicePast`
   (destruct `kvE_*Pos` → slice-id), NOT the four `kvE_hbr*_supply_zero` (two of which are
   provably false).
5. **Flag to orchestrator**: audit the frozen k=2 layer (`kvE2_extBracketFut`,
   ExteriorBracket.lean:364 and its 348-era consumers at KampPrior:351) for the same per-σ
   keying defect; task 349 v8 Phase 6 must consume the slice-keyed interface.
6. **Preserved assets unchanged**: the refutation theorem, the four `*_of_realizer` supply
   lemmas, the three invariance lemmas, Phase-2 atom pinning, the destructor, and the realizer
   engine are all consumed as-is by the repair.

## Appendix — evidence anchors

- Machine: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorPinnedConverseK.lean`
  (:498–617 refutation; :585–590 hPosEq; :379–476 invariance; :125–209 Phase-2);
  `ExteriorBracketAssembleK.lean` (:46–53 bracket keying; :168–215 D3);
  `ExteriorConverterK.lean` (:127–213 guarded `_complete`; :231–248 bundle);
  `ExteriorNegationK.lean` (:346–428 clause family; :453–472 zone semantics);
  `EndIntervalConsumerK.lean` (:95–201 obligation motive);
  `Metalogic/WeakCanonical/NormalForm.lean` (:199–250 `nf_eval_nf`/`nf_characteristic`/
  `nf_eval_unique`).
- Literature: `~/Projects/Literature/sources/rabinovich_2014/chunk_0015.md` (:11–43),
  `chunk_0016.md` (:15–19), `chunk_0022.md` (:5, :9–13), `chunk_0023.md` (:25).
- Task artifacts: `specs/360_…/handoffs/phase-3-handoff-20260713T190000Z.md`;
  `specs/360_…/plans/01_restate-hbr-pinned-converse.md` (Phase-3 BLOCKER block);
  `specs/358_…/reports/03_pinned-converse-adjudication.md` (§2.3–2.4 superseded; §3.2 shrink
  direction confirmed and extended).
