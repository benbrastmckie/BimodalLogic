# Task 374 — M2 Asset Sufficiency Adjudication for KampPrior:519/:522

**Session**: sess_1784133475_d9e662 · **Agent**: lean-research-hard-agent (H2/H3/H4) · **Date**: 2026-07-15
**Mode**: lean4 `--hard --lit` (Rabinovich 2014, doc_id `rabinovich_2014`, Lemma 5.3 / Cor 5.4(1))
**Reference-grounding tier**: Tier 1 (literature-backed, lean4 strict)

---

## Verdict (headline)

**PRIMARY (:519, the n=1 k≥2 arm): INSUFFICIENT.** The M2 assets landed by task 370
(`kampPrior_hreal_supply`, the `*Fib` de-folded carrier chain, `kampPrior_site_rungKFib_gate_match`)
do **not** suffice to discharge the general-k arm, for a precise, machine-groundable reason: the
two abstract char seams the entire `*Fib` certificate stack threads —
`hcharFib` (render-gated ↔, `ExteriorGateAssembleK.lean:574-578` / `KampPrior.lean:1073-1077`) and
`hcharFibSoundP` (w-universal unguarded →, `ExteriorGateAssembleK.lean:579-581` /
`KampPrior.lean:1080-1082` / `InteriorGateGeneralK.lean:2115`) — are **jointly refutable at every
nontrivial Prior model containing a realized render** (Gap B below), and the ↔ seam alone is
additionally uninstantiable at homogeneous Prior models by any fixed formula family (Gap A). No
choice of `charFib` can ever satisfy the hypothesis set at the instances the :519 arm needs, so the
certificates — though themselves sorry-free and axiom-clean — are uninstantiable at the consumption
site. Per the task description's own directive: **stop, and spawn a narrowly-scoped follow-up**
(seam re-signature of the additive `*Fib` sibling chain, NOT a carrier-trio re-open).

**SECONDARY (:522, the n≥2 arm): route (b) is REFUTED; recommend route (a)-amended.**
Route (b) ("restate `nf_nvar_exist_all_depths` so call sites only require n ∈ {0,1}") is foreclosed
by machine evidence: the `ExistProviders` bundle (`PriorInterface.lean:38-45`) demands the
**all-arity** converter family, and the gate machinery :519 depends on consumes `P.existF 4`
(arity-5 converters, n=4 ≥ 2) at 38 sites (e.g. `ExteriorNegationK.lean:375`, via
`kvE_futPos`/`kvE_pastPos`). Restating to n ≤ 1 would break the provider instantiation
`kampPrior_existProviders_of_ih` (`KampPrior.lean:1278`) and with it the entire :519 gate route.
Route (a) is viable only in an amended form: :522 is **not a corollary** of the :519 machinery
(peeling one variable leaves a single existential relative to n+2 anchors — a multi-anchor
generalization the current 3-anchor/arity-4 machinery does not cover); the paper-faithful
resolution is one arity-general engine (Rabinovich Lemma 5.3's induction on n) discharging both
arms together. Recommendation: **route (a)-amended** — the spawned follow-up states its char/seam
engine arity-generally so :519 (n=1) is its first instance and :522 (n≥2) follows by the same
n-induction.

**Critical-path correction (H4 contradiction, resolved against the task description):** the claim
":522 is off the critical path — `completeness_discrete` only invokes n ∈ {0,1}" is TRUE for direct
invocations (verified: the only external term-level calls are n=1 at `KampPrior.lean:407` and
`:597/:606` inside `nf_characterizable_temporal_prior`; nothing calls n ≥ 2 directly) but FALSE for
the provider-mediated route: at gate depth _k ≥ 1 (site depth ≥ 3), `Pbr : ExistProviders sig
atomMap _k` requires the recursion at depth _k for **all n** including n=4, which lands in the
`| n+2 =>` sorry arm (:522) at lower depths. Only the depth-0 bundle
(`kampPrior_existProviders_zero`, `KampPrior.lean:1409`) is green. **:519 at site depths ≥ 3 and
:522 at lower depths are mutually entangled** under the current machinery.

---

## Findings

### H3 Tier-1 lemma mapping table (Rabinovich 2014 → Lean obligations)

| Source | Prop/Location | Lean Identifier | Type Signature (abbrev.) | Status |
|--------|---------------|-----------------|--------------------------|--------|
| Rabinovich 2014 | Lemma 5.3 (chunk_0014, lines 3-41): `∃x1…∃xn (z0<x1<…<xn<z1) ∧ ⋀ Pi(xi)` reducible to a ∨⃗∃∀ formula `On`, by induction on n over Dedekind-complete chains | `nf_nvar_exist_all_depths` (`KampPrior.lean:346-522`) — the all-depth all-arity existential converter | `(k n : Nat) → (sub_nf : NormalForm sig k (n+1)) → ∃ A, ∀ M h_UZ h_SZ t, temporal_truth M atomMap t A ↔ ∃ env : Fin n → M.carrier, nf_eval_nf M k (n+1) (insertEnv env t) sub_nf` | PARTIAL: k=0 arm green; n=0 arm green; n=1 arms k∈{0,1} green (`kampPrior_case1_arm_k0/_k1`, `KampPrior.lean:271/301`); n=1 k≥2 arm **sorry :519**; n≥2 arm **sorry :522** |
| Rabinovich 2014 | Cor 5.4(1)⇐ (chunk_0015, lines 9-41): witness `y2 > y1` extracted **directly from the `Until` firing** `(αn ∧ βn+1 Until αn+1)` — F_i are unary TL formulas; anchor relations carried by bracket position, never by an anchor-pinning per-point formula | `bracketEndChar_kvFib_realize_futT` / `_realize_pastX` (`InteriorGateGeneralK.lean:1565/1597`) — render-free endpoint→arity-4 extraction | endpoint eval (`igEpRFib`@t / `igEpLFib`@x) + char-soundness seam → `∃ x1 (> t / < x), nf_eval_nf M (k+1) 4 [x1,w,x,t] σ` | LANDED sorry-free (task 370 Phase 3); axioms `{propext, Classical.choice, Quot.sound}` |
| Rabinovich 2014 | Cor 5.4 F_i-chain (per-round provider threading, PDF p.7/p.9) | `ExistProviders` (`PriorInterface.lean:38-45`) + shim `kampPrior_existProviders_of_ih` (`KampPrior.lean:1278`) | `existF : (n : Nat) → NormalForm sig k (n+1) → Formula` + UZ/SZ-conditional correctness — **all-arity field** | Structure landed; instantiable green only at depth 0 (`kampPrior_existProviders_zero`, `KampPrior.lean:1409`); depth ≥ 1 all-arity instantiation requires the :522 arm at lower depths |
| Rabinovich 2014 | Lemma 5.3 case split via `inf` (Dedekind completeness), K⁺ closure operators | `kampPrior_hreal_supply` (`InteriorHrealSupplyK.lean:61-102`) — row-5 interior realizer supply, seven-zone case split | under `hAmb`, per-w carrier evals (`igPtWFib`@w, `igEpLFib`@x, `igEpRFib`@t), per-w char seam, interior seams `hIntL`/`hIntR`, zone-consistency seam → `∀ σ marked fiber-consistent, ∃ x1, nf_eval_nf M (k+1) 4 [x1,w,x,t] σ` | LANDED sorry-free (task 370); verified this session: axioms `{propext, Classical.choice, Quot.sound}` |
| Rabinovich 2014 | Lemma 3.2(2)/§5 bracket `[α0,…,αn](z0,z1)` two-fixed-endpoint framing | `kampPrior_site_rungKFib_gate_match` (`KampPrior.lean:1058-1181`) → `bracketEndChar_kvExtFib_correct_prior` (`ExteriorGateAssembleK.lean:559-660`) | 6 order-atom hyps + `hcharFib` + `hcharFibSoundP` + rows 5-13 obligations → `(bracketEndChar_kvExtFib …).holds M atomMap x t ↔ ∃ w, nf_eval_nf M (k+2) 3 [w,x,t] qnf` | LANDED sorry-free, verified this session — but **hypothesis set uninstantiable** at the :519 site (Gaps A/B below); zero non-definitional callers (grep-confirmed, corroborating task 370 report 02 §2) |
| Rabinovich 2014 | (divergence) — the paper never demands a per-point formula whose truth set equals an anchor-relative realizer set | `hcharFib` / `hcharFibSoundP` binders (locations in Verdict above) | see Gap A / Gap B | **REFUTED as signed** — the un-Rabinovich element of the M2 stack; the follow-up's target |

### Q1 — PRIMARY (:519): the precise goal, the assets, and the gap ledger

**Goal shape at `KampPrior.lean:519`** (term-mode match arm `| _k + 2, _sub_nf =>` inside the
`| k+1, n` body at n=1; expected type pinned by the def signature `KampPrior.lean:350-357` and
byte-parallel to the landed k≤1 siblings `KampPrior.lean:275-281/305-311`):

```
⊢ ∃ (A : Formula),
    ∀ (M : OrderedMonadicStructure sig)
      (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
      (t : M.carrier),
      temporal_truth M atomMap t A ↔
      ∃ env : Fin 1 → M.carrier, nf_eval_nf M (_k + 3) 2 (insertEnv env t) _sub_nf
```

In scope: `atomMap`, `h_surj`, the depth-(_k+2) recursion IH (`ih_exist_1`, `exist_tl_fn_k`,
`char_k1`, `char_k1_correct`, `KampPrior.lean:399-455`), and recursive calls
`nf_nvar_exist_all_depths atomMap h_surj k' n' sub` at any smaller depth k'.

**What IS in place (the sufficient part).** All verified `lean_verify`-clean this session
(axioms exactly `{propext, Classical.choice, Quot.sound}`, no `sorryAx`):

| Obligation (ledger row) | Supply | Location | Status |
|--------------------------|--------|----------|--------|
| row 5 `hreal` (interior realizer, all seven zones) | `kampPrior_hreal_supply` | `InteriorHrealSupplyK.lean:61` | GREEN, render-free |
| rows 8-9 `hslice*` general-m | `kvE_hsliceFut_supply` / `kvE_hslicePast_supply` | `ExteriorDeepSliceSupplyK.lean:131/161` | GREEN (render-downstream, sanctioned) |
| rows 12-13 `hexclDeep*` general-m | `kvE_hexclDeepFut_supply` / `kvE_hexclDeepPast_supply` | `ExteriorDeepExclSupplyK.lean:77/107` | GREEN (task 370 Phase 8) |
| per-qnf gate certificate | `kampPrior_site_rungKFib_gate_match` | `KampPrior.lean:1058` | GREEN as a conditional theorem |
| render-free endpoint extraction | `bracketEndChar_kvFib_realize_futT/_pastX` | `InteriorGateGeneralK.lean:1565/1597` | GREEN |
| only remaining sorries in the whole Kamp tree | — | `KampPrior.lean:519/:522` | (the `ExteriorPinnedProbe358K.lean:70` "sorry." grep hit is prose in a doc comment, not code) |

**Gap ledger (the insufficient part):**

**Gap B (FATAL, High confidence — the joint seam refutation).** For **any** `charFib` family, any
Prior model `M` with ≥ 2 carrier points, and any `x < t` such that some in-scope `qnf`-render is
realized at a witness `w0` (e.g. `qnf* :=` the depth-(k+2) characteristic 3-type of `(w0,x,t)`,
realized by `nf_characteristic_satisfies`, `NormalForm.lean`; it satisfies the six bracket
order-atom hypotheses since `x < w0 < t`), the hypothesis pair {`hcharFib`, `hcharFibSoundP`} is
jointly false:

1. Let `σ* : NormalForm sig (k+1) 4` be the characteristic fiber of `(w0, w0, x, t)` — realized at
   `[w0,w0,x,t]`, with order atoms `(0<1) = false` and `(1<0) = false` (positions 0 and 1 coincide).
2. `hcharFib qnf*` instantiated at `w := w0` (render realized) and `(σ*, u := w0)` gives
   `temporal_truth M atomMap w0 (charFib (k+1) σ*)` by the `.mpr` direction.
3. `hcharFibSoundP` — which is **not** qnf-guarded, **not** order-guarded, and `∀ w` outermost
   (`ExteriorGateAssembleK.lean:579-581`) — instantiated at any `w' ≠ w0` concludes
   `nf_eval_nf M (k+1) 4 [w0, w', x, t] σ*`. Its atom layer demands `(w0 < w') ↔ false` and
   `(w' < w0) ↔ false`; linearity with `w' ≠ w0` forces one true. Contradiction.

Since the arm's ⇐ direction is exercised exactly when a realization (hence a realized
characteristic render) exists, the hypotheses are needed precisely where they are refutable. Every
route through the `*Fib` stack carries one of the two seams (`step_sound` carries `hcharFibSoundP`,
`InteriorGateGeneralK.lean:2115`; `step_complete` carries render-gated `hcharFib`,
`InteriorGateGeneralK.lean:1743-1747`; `correct_prior` and `gate_match` carry both). **No
instantiation exists; the M2 stack cannot be applied at :519 as signed.**

**Gap A (design-level, Medium-High confidence — the ↔ seam alone is also uninstantiable).** Even
if `hcharFibSoundP` were re-signed away, `hcharFib`'s render-gated ↔ demands, in a homogeneous
Prior model (e.g. ℤ with all monadic predicates constant — UZ/SZ hold: for everywhere-true ψ take
`s = t+1` with an empty open interval, `PriorDefs.lean:22/:33`), a fixed formula
`charFib (k+1) σ*` whose truth set equals the realizer set `{w0}` of the AtW characteristic fiber.
Truth sets of fixed formulas in shift-homogeneous models are shift-invariant (∅ or all of ℤ);
`{w0}` is neither. (Pen-and-paper automorphism argument, not machine-verified — flagged
accordingly.) Consequence for the follow-up: it does not suffice to guard the soundness seam; the
↔ seam itself must be decomposed so that order content is certified **structurally** (zone /
bracket position — the shape `bracketEndChar_kvFib_realize_futT` already exhibits, where `x1 > t`
comes from the native `Until` firing, faithful to chunk_0015 lines 23-29) and only unary content
rides the formula. This is exactly Rabinovich's design: the F_i are unary; anchor relations live
in the bracket sequence.

**Gap C (entanglement, High confidence).** `Pbr : ExistProviders sig atomMap _k` at gate depth
_k ≥ 1 (site depth ≥ 3) requires all-arity converters at depth _k — `P.existF 4` is consumed over
arity-5 fiber elements by `kvE_futChain`/`kvE_fiberPosOn` (`ExteriorNegationK.lean:225/351/375`,
38 sites total) inside `kvE_futPos`/`kvE_pastPos`, which appear in the rows 8-9 binders and the
landed drivers `kampPrior_futRealizer_of_pos` (`KampPrior.lean:1662`). Instantiating from the
recursion via `kampPrior_existProviders_of_ih` hits the `| n+2 =>` arm (:522) at lower depths.
Green only at depth 0 (`kampPrior_existProviders_zero`).

**Gap D (missing general-m supplies, High confidence).** Ledger rows 6, 10, 11 have only m=0
supplies: `hexcl` (row 6) has **no** general-m supply anywhere (grep-confirmed; the only landed
interior-supply leaf is `kampPrior_hreal_supply` = row 5); `hexclSlicePast/Fut` (rows 10-11) exist
only as `kvE_hexclSlicePast_supply_zero` / `kvE_hexclSliceFut_supply_zero`
(`ExteriorPinnedConversePastK.lean:769` / `ExteriorPinnedConverseK.lean:1250`).

**Gap E (arm-assembly scaffolding, High confidence).** The gate certificate covers only the
per-qnf interior existential `∃ w, nf_eval_nf M (_k+2) 3 [w,x,t] qnf`. The arm itself needs the
general-k analogs of the k≤1 assembly stack — trichotomy arms `kampArm_{past,diag,future}_k{0,1}`
(`AggregateHookDischarge.lean:1686-1747/2087`, `AggregateOffDiagK1.lean:1456/1485`), aggregate
carriers (`aggAtomK1*`, `aggPop1/aggPop1F`), and translation glue — none of which exist at general
k (`kampArm_*_kv`: zero hits). At k≤1 this scaffolding took tasks 349/350/358/309 to land per
fixed depth.

**Sufficiency verdict: INSUFFICIENT.** Gaps A/B are design-level (no proof effort against the
current signatures can succeed — the hypotheses are false at the needed instances); Gaps C/D/E are
volume/dependency gaps that survive even after a seam fix. Per the task description: the
implementation plan's Phase 1 (bounded feasibility adjudication) should machine-confirm Gap B with
a small refutation probe (style: `RefutationF2.lean` / `ExteriorPinnedProbe358K.lean`; ingredients
all named: `nf_characteristic_satisfies`, the order-atom evaluation, two-point models), then STOP
and `/spawn` the follow-up.

**Exact missing statement (the follow-up's target).** Re-sign the `*Fib` sibling chain's char
seams (`step_sound`/`step_complete`/`correct_prior`/`gate_match` — all additive task-370 siblings,
NOT frozen, per task 370 report 02 §3 blast-radius table) to an anchor-contextual, zone-decomposed
interface, stated arity-generally:

```
-- replaces hcharFib + hcharFibSoundP; sketch, to be refined by the follow-up's own Phase 1
(hcharFibZone : ∀ w, x < w → w < t →
  carrier-eval context at (w, x, t) →                 -- igPtWFib@w, igEpLFib@x, igEpRFib@t
  ∀ (σ : NormalForm sig (k+1) 4), zone-admissible σ →
  ∀ x1, zoneHolds M [w,x,t] (nf0_zoneSpec σ.1) x1 →   -- order content: structural, from the zone
    (temporal_truth M atomMap x1 (charFib (k+1) σ) ↔
      fiber-and-pred content of σ at x1 relative to the certified anchor 1-types))
```

with the order atoms of `nf_eval_nf` reconstructed from `zoneHolds` + the anchors' carrier-certified
1-types (the pattern `step_complete`'s `hz'` fold biconditional already uses,
`InteriorGateGeneralK.lean:1775-1795`), and the fiber layer discharged recursively from an
arity-general provider engine (Rabinovich Lemma 5.3's n-induction) — which simultaneously supplies
`existF 4` at lower depths, dissolving Gap C and settling :522 by the same induction.

### Q2 — SECONDARY (:522): call-site verification and route adjudication

**Verified call-site inventory** (term-level, comments excluded):
- `KampPrior.lean:407` — the recursion's own `ih_exist_1`, calls `n := 1`.
- `KampPrior.lean:597/:606` — `nf_characterizable_temporal_prior`, calls `n := 1` via
  `nf_nvar_exist_all_depths_fn`; this is the sole entry the `BXCanonical/Completeness.lean`
  chain consumes (`Completeness.lean:357` names it as the dependency; `:369` records the sorryAx
  inheritance from :519/:522 as the sole completeness blocker).
- No caller anywhere passes `n ≥ 2` (repo-wide grep). The `n := 0` case is exercised only through
  the match's own `| 0 =>` arm, which is green.

So the direct-invocation claim in the task description is CONFIRMED, but see the critical-path
correction in the Verdict: the provider route makes :522-at-lower-depths a prerequisite of
:519-at-site-depth ≥ 3. Route adjudication:

- **Route (b) — restate to n ∈ {0,1}: REFUTED.** `ExistProviders.existF` is an all-arity field
  (`PriorInterface.lean:40`); `kampPrior_existProviders_of_ih` (`KampPrior.lean:1278`) requires the
  all-arity ih family; `P.existF 4` has 38 consumption sites. A n≤1 restatement type-breaks the
  planned provider instantiation and with it the :519 gate route. (It would also ripple through
  `nf_nvar_exist_all_depths_fn` `:525`, `_fn_correct` `:533`, and `:597`.)
- **Route (a) — corollary of the :519 machinery: viable only AMENDED.** :522 is not literally a
  corollary: peeling `∃ env : Fin (n+2)` leaves a single existential relative to n+2 anchors,
  outside the current 3-anchor (`qnf : NF _ 3`) / arity-4 (`σ : NF _ 4`) machinery. The amendment:
  the spawned follow-up's char/provider engine is stated arity-generally (per Rabinovich Lemma 5.3,
  which is an induction on n, chunk_0014 lines 7-41), so :519 is its n=1 instance and :522 its
  n ≥ 2 instances. **Recommended: route (a)-amended.** If the follow-up lands its engine, both
  arms retire together; if the engine is refuted at n=1, :522 was unreachable anyway.

### Q3 — Frozen-boundary constraints (confirmed)

| Frozen asset | Location | What it forbids |
|--------------|----------|-----------------|
| `bracketEndChar_kv` definition (the folded carrier) | `CarrierKv.lean:240-249` (the `k+1` branch body `:244-249` is the cited `:246-249` defeq surface) | any edit to the `kv_body` instantiation, its fold-bit lambda, or the off-fiber clause — the `rfl` bridges depend on byte-identity |
| Defeq bridge #1 `bracketEndChar_kv_succ_eq` (pure `rfl`) | `InteriorGateGeneralK.lean:339-351` | any change to `igBody` or `bracketEndChar_kv` that breaks `simp only [bracketEndChar_kv]; rfl` |
| Defeq bridge #2 | `CarrierKv.lean:294-351` (per task-370 handoff verification field) | same byte-identity discipline on the `bracketEndChar_k1v`/`kv_body` seam |
| Carrier trio | `Base.lean` / `CarrierK1V.lean` / `CarrierKv.lean` | no refactor before both sorries land (task-374 constraint) |
| Folded gate certificate | `kampPrior_site_rungK_gate_match`, `KampPrior.lean:941` | byte-identical (its consumer `EndIntervalConsumerK.lean:248` is live) |

**Constraint tension to surface at planning:** the task-374 constraint "no refactor of
`InteriorGateGeneralK.lean`" conflicts with the only viable fix, which re-signs the **additive
`*Fib` sibling binders inside that file** (`step_sound` `:2101/2115`, `step_complete` `:1733`,
plus `ExteriorGateAssembleK.lean:559-581` and `KampPrior.lean:1058-1082`). Task 370's Phase-7
divergence audit (report 02 §3) already classified exactly these as freely-editable additive
siblings, disjoint from the frozen defeq surfaces. The spawn should carry re-scoped constraints
making the sibling/frozen distinction explicit rather than file-granular.

---

## Literature Proof Structure (Tier 1)

Rabinovich 2014, corpus `rabinovich_2014` (26 chunks; Lemma 5.3 = chunk_0014, Cor 5.4(1) =
chunk_0015):

1. **Lemma 5.3** (chunk_0014 lines 3-41): `¬∃x1…∃xn (z0<x1<…<xn<z1) ∧ ⋀ Pi(xi)` is equivalent
   over Dedekind-complete chains to a ∨⃗∃∀ formula `On(P1,…,Pn,z0,z1)`. Induction on **n** (the
   number of interval witnesses — the Lean recursion's arity dimension, i.e. the :522 axis, NOT
   the depth axis): basis n=1 is a single ∀; step n→n+1 case-splits on `r0 = inf{z ∈ (z0,z1) |
   P1(z)}` (Dedekind completeness) into (1) P1 absent, (2) `K⁺(P1)(z0)` with `On(P2,…)` at the
   same left anchor, (3) `∃ r0` definable by an INF formula with `On(P2,…)` re-anchored at r0.
   **Lean translation note:** the induction is on n with all Pi simultaneously — corroborating
   the route (a)-amended recommendation that one arity-general engine must serve both :519 and
   :522.
2. **Cor 5.4(1)** (chunk_0015 lines 9-41): `¬(∃z ∈ (z0,z1)) [α0,β1,…,βn,αn](z0,z)` is a ∨⃗∃∀
   formula, via: bracket-satisfaction ⇔ `F0(z0)` ∧ an increasing F_i-witness sequence; the ⇐
   induction extracts the next witness **directly from the `Until` firing** (`y1` satisfies
   `αn ∧ βn+1 Until αn+1`, hence `∃ y2 > y1` with `αn+1` at `y2` and `βn+1` along `(y1,y2)` —
   lines 23-29). **Lean translation note:** this is the shape `bracketEndChar_kvFib_realize_futT`
   faithfully implements (native `untl` semantics fire the witness; order content structural).
   The paper carries **unary** F_i and encodes anchor relations positionally; it has no analog of
   a per-point arity-4 characteristic formula with a truth-set-equals-realizer-set demand — the
   `hcharFib`/`hcharFibSoundP` seams are the M2 stack's deviation from the source and are exactly
   where the refutation bites.
3. **Prior/discreteness note:** the codebase replaces Dedekind completeness (the paper's `inf`)
   with the UZ/SZ first/last-occurrence conditions (`PriorDefs.lean:22/:33`) — the discrete
   analog; this substitution is already load-tested by the landed k≤1 arms and is not implicated
   in the gaps.

---

## Adversarial Self-Verification

| Claim | Source/Counterexample | Verification Method | Confidence |
|-------|------------------------|----------------------|------------|
| `hcharFibSoundP` is w-universal, unguarded, qnf-independent as signed | binder text `ExteriorGateAssembleK.lean:579-581`, `KampPrior.lean:1080-1082`, `InteriorGateGeneralK.lean:2115` | direct source read (three sites, byte-consistent) | High |
| Gap B joint refutation (hcharFib + hcharFibSoundP false at any M with ≥2 points and a realized render) | constructed counterexample: `qnf*`/`σ*` characteristic types, `w' ≠ w0` order-atom violation; realization of characteristic NFs is `nf_characteristic_satisfies` | `lean_local_search` hit (`Bimodal.Metalogic.WeakCanonical.nf_characteristic_satisfies`, NormalForm.lean) + order-atom binder shapes read at `KampPrior.lean:1064-1069`; the closing contradiction is a 3-step pen-and-paper argument over read signatures, not yet a compiled probe — hence plan Phase 1 must compile it | High (argument), machine-probe pending |
| Gap A homogeneity refutation of `hcharFib` alone | uniform-ℤ automorphism/shift-invariance argument; UZ/SZ hold at uniform models (read `PriorDefs.lean:22-39`: everywhere-true ψ take s=t+1, empty interval; everywhere-false ψ vacuous) | pen-and-paper over read definitions; NOT machine-verified | Medium-High |
| All four M2 supply theorems are sorry-free and axiom-clean | `kampPrior_hreal_supply`, `bracketEndChar_kvExtFib_correct_prior`, `kvE_hsliceFut_supply`, `kvE_hexclDeepFut_supply`, `kampPrior_site_rungKFib_gate_match` | `lean_verify` this session: all exactly `{propext, Classical.choice, Quot.sound}`, no warnings | High |
| Only sorries in the Kamp tree are `KampPrior.lean:519/:522` | repo grep; the `ExteriorPinnedProbe358K.lean:70` hit is prose ("never a sorry") inside a doc comment | grep + context read `:60-75` | High |
| `P.existF 4` is consumed by the gate machinery (Gap C premise) | `ExteriorNegationK.lean:375` (`P.existF 4 (renameNF rot5Fwd rot5Bwd s)` inside `kvE_futChain`), `:225/:351` doc-comments; 38 grep hits for `existF 4` | grep + definition read of `kvE_futPos` (`ExteriorNegationK.lean:429-435`) | High |
| No external caller passes n ≥ 2 to `nf_nvar_exist_all_depths` | term-level call inventory: `:407` (n=1), `:597/:606` (n=1); wrapper `_fn` has exactly one caller (`:597`) | repo-wide grep, comments excluded | High |
| Rows 6/10/11 lack general-m supplies | only `_zero` variants exist (`ExteriorPinnedConversePastK.lean:769`, `ExteriorPinnedConverseK.lean:1250`); no interior `hexcl` supply leaf | grep for `hexcl.*supply` declarations | High |
| No non-definitional caller of the `*Fib` certificate stack exists (so the seams were never instantiation-tested) | grep for `kampPrior_hreal_supply`/`kampPrior_site_rungKFib_gate_match` consumers: doc-comments only | grep, corroborated by task 370 report 02 §2 ("Architectural note") | High |
| Rabinovich fires witnesses from `Until`, carries unary F_i, no per-point arity-4 char | chunk_0015 lines 23-29 direct quote; chunk_0014 lines 7-41 (n-induction) | corpus chunk reads this session | High |
| Goal shape at :519 as stated | term-mode arm — `lean_goal` returns no tactic goals (expected for term-mode `sorry`); shape derived from def signature `:350-357` + sibling arms `:275-281/:305-311` | `lean_goal` probe + source read | High |

**Contradiction Log.**
1. **Task description (":522 off the critical path") vs machine evidence (provider entanglement,
   Gap C)** — RESOLVED, machine evidence prevails (precedence: compiled source > task-description
   prose). Both are recorded: the direct-invocation sense is true; the provider-route sense is
   false. The plan must not treat :522 as freely deferrable if it adopts the provider-based :519
   route at site depths ≥ 3.
2. **Task 370 report 02 residual (b) ("`hcharFibSound` plausibly satisfiable at instantiation,
   Medium") vs this report's Gap B (jointly refutable, High)** — RESOLVED in favor of Gap B: report
   02 explicitly deferred the check ("the resolving check not yet performed"); this session
   performed it via the counterexample construction. Report 02's THREADABLE verdict for :116 is
   unaffected (and indeed :116 landed); what falls is only its optimism about the seam's eventual
   dischargeability.
3. **Task-374 constraint ("no refactor of InteriorGateGeneralK.lean") vs the only viable fix
   (re-sign `*Fib` siblings inside that file)** — UNRESOLVED at research level; surfaced to
   planning. Downstream risk: a plan that honors the constraint literally cannot fix Gaps A/B; the
   resolving decision is the spawn's re-scoped constraint language (sibling-level, not
   file-level).

**Recommendations modified after verification:** an earlier draft direction ("proceed to construct
the general-k arm from the M2 assets, mirroring `kampPrior_case1_arm_k1`") was **withdrawn** after
the Gap B counterexample construction — constructing the arm against refutable hypotheses would
have been analysis-free churn into a wall. The deliverable pivoted to the refutation +
follow-up-target specification above.

---

## Recommended next steps

1. `/plan 374`: Phase 1 = the bounded feasibility adjudication the task description mandates,
   executed as a **refutation probe** (compile Gap B: `example … : False` from the seam pair + a
   two-point/ℤ instance + `nf_characteristic_satisfies`; ~30-60 lines, one dispatch). Expected
   outcome: REFUTED, matching this report.
2. On refutation: STOP per the task directive; `/spawn 374` one narrowly-scoped follow-up:
   **"Arity-general zone-decomposed char engine for the de-folded carrier"** — re-sign the
   `*Fib` sibling seams (exact signature sketch in §Q1), build the provider/char engine by
   Rabinovich Lemma 5.3's n-induction, discharging :519 (n=1 instance) and :522 (n≥2 instances)
   together; constraints re-scoped to sibling-level (frozen: `bracketEndChar_kv` body, both `rfl`
   bridges, carrier trio, `kampPrior_site_rungK_gate_match`).
3. Do NOT dispatch a direct proof attempt at :519 against the current signatures, and do NOT
   re-open the carrier design — both are refuted paths (this report; task 358 report 11).

## References

- `specs/358_realization_recursion_nf_nvar_exist_all_depths/reports/11_render-cluster-divergence-audit.md` (H5 prior diagnosis; M1 refuted, M2 chosen)
- `specs/370_m2_defolded_interior_carrier_redesign/reports/02_phase7-divergence-audit.md` (seam threading; residual (b) = the check this report resolves)
- `specs/370_m2_defolded_interior_carrier_redesign/.orchestrator-handoff.json` (M2 completion verification)
- rabinovich_2014 chunk_0014 (Lemma 5.3), chunk_0015 (Cor 5.4(1))
