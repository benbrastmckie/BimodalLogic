# Report 09 — Task 349 Boneyard-Correctness Audit

**Scope**: read-only audit of every file in
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Boneyard/` (18 `.lean` files).
**Question** (user): "is faithful Rabinovich machinery wrongly archived; carrier-aware restore verdicts."
**Mode**: lean-research-hard (H2/H3/H4/H5). No files edited or moved.
**Cross-refs**: reports 05 (faithful architecture), 06 (Phase-3 gate), 07 (faithfulness deep-check),
08 (design resolution, §Q4 already covers arity/liftInterval restore). This report does **not**
re-derive those; it audits the whole Boneyard for *correct-archival* and adds the
completeness-direction files 05–08 did not weigh.

> Citation convention: the `rabinovich_2014` corpus rule prefers page citation, but the source md
> has no page markers, so I cite by construct name + md line (matching reports 05–08), e.g.
> "Prop 3.5 (md:137)". Section anchors: §3 md:137, §4 md:145, §5 md:195, §7 md:367.

---

## 0. Bottom line (H4-hardened)

**The archival is essentially CORRECT. The endChar effort did NOT bury the faithful carrier asset
it should have built on.** The genuinely faithful depth-`k` carrier object — Rabinovich's Def 7.13
"conjunction of adjacent two-endpoint pieces, never a one-point read" (md:451) — exists **GREEN and
LIVE** as `nf_zone_flatten_navigable(_correct)` (Base.lean:667/687), and has **never** been in the
Boneyard. What the endChar effort repeatedly re-invented was the *refuted single-point* line
(`navPieceForm_correct`, a machine-checked non-theorem, report 06 §NON-THEOREM / report 07:150 row),
now correctly archived as `NavigatedEndCharSinglePoint.lean`. So the hypothesis "faithful machinery
is buried and endChar re-invented it" is **refuted for the carrier**: the correct asset was live all
along; the buried thing was the *wrong* (single-point) asset.

**Two nuances that qualify "correct":**

1. **Three Boneyard files are not actually dead — they are still on the live build.** Live
   `Kamp/Prop43.lean:1–2` imports `Boneyard.VecEA_m` and `Boneyard.EAVecNegationClosure`
   (transitively `Boneyard.VecEAArityFirewall`), and live
   `NfMultiAnchorBridge/NavigatedEndChar.lean:4` imports `Boneyard.NavigatedEndCharSinglePoint`.
   These are **directory-quarantined but compiled**, so they need **no restore** to be reachable —
   the "buried" framing does not apply to them.
2. **The task's own hypothesis mis-groups one faithful file.** `VecEAArityFirewall` is listed with
   "refuted probes" — it is **not** a probe. It is sorry-free Lemma 3.2(2) (the arity firewall,
   md:115/177), faithful, and live-imported. Corrected below.

**Net**: 15 KEEP-ARCHIVED, 0 RESTORE-NOW-unconditional, 3 RESTORE-IF-carrier/downstream (all in the
**completeness / Theorem-4.4 direction**, none on the endChar step). No faithful *carrier* asset is
buried. Only orphaned *completeness-direction* conveniences (`RabinovichTranslation`,
`SeparationBridge`) are restore candidates, and each has a live substrate (their cores are already
live), so even those are low-stakes.

---

## 1. Per-file verdict table

Real-sorry = genuine tactic `sorry` (not docstring prose); confirmed by
`grep -nE 'sorry'` isolating comment/docstring lines. **Only 2 of 18 files carry a real tactic
sorry** (`EndpointNegation:160`, `FOToVEA:118`); the other 16 are sorry-free green.

| file | archived | LOC | real-sorry | key exports | faithful? (Rabinovich md:) | verdict | reason |
|------|----------|----:|:----------:|-------------|----------------------------|---------|--------|
| `NavigatedEndCharSinglePoint` | **session** (f54d7df93, v6 Ph1) | 308 | 0 (gated) | `navPieceForm`, `endChar(_correct)(_step)`, `endCharStep` | reads a 2-free-var object at ONE point → **UNFAITHFUL** (Def 7.13 md:451 demands 2-endpoint) | **KEEP-ARCHIVED** | machine-refuted single-point line (`navPieceForm_correct` non-theorem; report 06 §NON-THEOREM, 07:150). Kept compiled via live NavigatedEndChar.lean:4 for history. |
| `NfZoneDepthK1Probe` | **session** (Wave 1) | 151 | 0 | `interior_bracket_cannot_realize_exterior_sub_k1` (+3) | refutation of a *non-*Rabinovich flattening shortcut | **KEEP-ARCHIVED** | sorry-free NO-GO gate (report 40 §3.2); negative knowledge only. |
| `NfZoneNavProbe` | **session** (Wave 1) | 185 | 0 | `no_x_independent_formula_captures_future_zone_k1` (+3) | refutation of a non-Rabinovich navigation shortcut | **KEEP-ARCHIVED** | sorry-free NO-GO gate (plan v40 Ph16); negative knowledge only. |
| `VecEAArityFirewall` | **session** | 142 | 0 | `VecEA_m.arity_firewall`, `endpointComponent(_holds)`, `intervalComponent(_holds)` | **FAITHFUL** = Lemma 3.2(2) (md:115/177) | **KEEP-ARCHIVED** (already live-imported) | task mis-groups as "probe"; it is green Lemma 3.2(2), transitively live via Prop43.lean. No restore needed. |
| `VecEA_m` | **session** | 659 | 0 | `VecEA_m`/`VVecEA_m`, `existClosure(_correct)`, `existClosureLeft`, `toVecEA2`, `toVVecEA2` | **FAITHFUL** arity-`m` VEA infra (Prop 4.3 substrate, md:169) | **KEEP-ARCHIVED** (already live-imported) | live-imported by Prop43.lean:1 + NfZoneDepthK.lean. Not buried. |
| `EAVecNegationClosure` | **session** | 296 | 0 | `neg_vec_ea_m`, `neg_vecEA_m`, `liftEndpoint/liftInterval(_holds)` | **FAITHFUL** = Prop 4.2 at arbitrary arity via firewall (md:165/177) | **KEEP-ARCHIVED** (already live-imported) | live-imported by Prop43.lean:2. Report 08 §Q4: `liftInterval` is the **wrong tool for the carrier** (arity-`m` VVecEA_m ≠ carrier VVecEA2). Correct as completeness-direction infra. |
| `NegationIndep` | **session** | 365 | 0 | `neg_2var_vec_ea_indep(_correct)`, `neg_vecEA2_indep`, `neg_interval_formula_indep` | **FAITHFUL** model-independent Prop 4.2 / Lemma 5.1 (md:165/207) | **KEEP-ARCHIVED** | its **own** docstring (lines 347–361): live model-dependent `neg_2var_vec_ea` (EANegationClosure.lean:722, sorry-free) **suffices**; indep path "introduces no new sorry" but is not needed. Redundant stronger variant. |
| `RabinovichTranslation` | **session** | 302 | 0 | `ExistsForallSpec(.translate/.future_chain/.past_chain/.translate_correct)`, `translateSpecs(_correct)` | **FAITHFUL** = Prop 3.5 (md:137), the Theorem-4.4 (md:185) TL half | **RESTORE-IF-Cprime** (ergonomic; core already live) | orphaned wrapper over LIVE `Translation.lean` (`translateEF1_correct:243`, `translateVEF1_correct:310`). Prop 3.5 substance is **not** buried; only the `ExistsForallSpec` convenience is. Downstream 350/309 (FO→TL) may consume it, esp. under C′. |
| `ArityReduction` | prior (305) | 110 | 0 | `IsVEA`, `isVEA_ex` | partial Prop 4.3 (md:169) — `fo_isVEA` NOT built | **KEEP-ARCHIVED** | existential closure only; full Prop 4.3 blocked on backward Prop 4.2; superseded by `EAVecNegationClosure` route. No live consumer. |
| `EndpointNegation` | prior (305) | 162 | **1** (:160) | `neg_vecEA2_is_vvecEA2` | Lemma 5.1 at VecEA2 level (md:207) | **KEEP-ARCHIVED** | the 1 sorry is a documented off-critical-path BracketFormula obstruction (lines 143–159); superseded by sorry-free live `EANegationClosure`. |
| `FOToVEA` | prior (305) | 149 | **1** (:118) | `nf_exist_to_temporal(_correct)`, `predFormula(_correct)` | narrowed NF→TL (Prop 3.5-adjacent) | **KEEP-ARCHIVED** | remaining sorry (`nf_exist_to_temporal_correct`); superseded by live sorry-free `Prop43`/`NfDepth0Generalized`/`NfToVecEA`. |
| `NfExistTL` | prior (305) | 321 | 0 | `nf_characterizable_temporal_prior_combined`/`_partA`, `nf_succ_char_formula`, `nf_quant_clause_tl` | faithful NF→TL induction (Prop 3.5/4.3 assembly) | **KEEP-ARCHIVED** | **superseded** by LIVE `nf_characterizable_temporal_prior` (KampPrior.lean:407) + live `Prop43.lean`. Same export names now live. |
| `Prop43` (Boneyard) | prior (305) | 196 | 0 | `nf_succ_char_formula(_correct)`, `nf_quant_clause_tl`, `nf_2var_exist_depth0_tl_fn` | faithful depth-(k+1) char (Prop 4.3 assembly) | **KEEP-ARCHIVED** | **duplicate** of LIVE `Kamp/Prop43.lean` (same exports); this is the old copy. |
| `KampComposition` | prior (305) | 213 | 0 | `pred_agree_cross`, `cross_extend_fwd/bwd_1var`, `exist_transfer_nvar_constenv` | Feferman–Vaught composition (Doets 1989, not Rabinovich) | **KEEP-ARCHIVED** | task-305 NF-composition route superseded by the NF-zone approach (NfZoneDepthK/NfToVecEA live). |
| `NfComposition` | prior (305) | 646 | 0 | `nf_drop_last(_cross)`, `intra_structure_extend`, `constenv_2var_determines` | Feferman–Vaught composition (Doets) | **KEEP-ARCHIVED** | documents `generalized_composition` **FALSE** for n≥2 (self-refuted, lines ~22–40); superseded route. |
| `WitnessCount` | prior (305) | 147 | 0 | `temporal_truth_transfer`, `depth2_quant_transfer`, `nf_depth0_char_iff_eval` | NF-transfer infra (support) | **KEEP-ARCHIVED** | support lemmas for the abandoned composition route; no live consumer. |
| `ZoneBridge` | prior (305) | 513 | 0 | `zone_bridge_above_x/between_tx/below_t/eq_x/eq_t`, `reconstruct_nf_eval_3var` | zone decomposition (support) | **KEEP-ARCHIVED** | KampBypass-era zone bridges; superseded by live `VecEADecomp`/`NfZoneDepthK`. |
| `SeparationBridge` | prior (earliest) | 199 | 0 | `neg_until_equiv_prior`, `neg_since_equiv_prior` | **FAITHFUL** GHR94 Lemma 10.2.2 on **Prior** structures | **RESTORE-IF-Cprime** (completeness ¬U/¬S on Prior) | orphaned; its live sibling `neg_until_equiv`/`neg_since_equiv` (Separation/NegationEquiv.lean:41/101) is **integer-time only** and is actively used (DedekindZ/Cases.lean). The **Prior** generalization here is unique. Needed if the completeness negation runs over Prior-UZ/SZ. |

---

## 2. The genuinely-dead list (correctly archived — CONFIRMED)

- **Refuted probes (sorry-free NO-GO gates):** `NfZoneDepthK1Probe`
  (`interior_bracket_cannot_realize_exterior_sub_k1`), `NfZoneNavProbe`
  (`no_x_independent_formula_captures_future_zone_k1`). Each is a *machine-checked refutation* of a
  non-Rabinovich shortcut; retaining them prevents re-attempting the same dead route. **Confirmed
  dead.** (Task correctly lists these.)
- **Refuted single-point scaffold:** `NavigatedEndCharSinglePoint` — the `endChar_correct_step`
  `k+1` obligation reduces exactly to `navPieceForm_correct`, a machine-checked non-theorem by
  parameter independence (report 04; report 06 §NON-THEOREM; report 07:150). A closed `Formula`
  read only at witness `w` cannot see the anchor layer at `{x,t}`. **Confirmed superseded** by the
  live two-endpoint `nf_zone_flatten_navigable`. Kept compiled (live import at NavigatedEndChar.lean:4)
  purely so the non-theorem narrative does not rot.
- **Superseded assembly duplicates:** `Prop43` (Boneyard) is a stale copy of live `Kamp/Prop43.lean`;
  `NfExistTL` is superseded by live `nf_characterizable_temporal_prior` (KampPrior.lean:407);
  `FOToVEA` (1 sorry) and `EndpointNegation` (1 sorry) are superseded by sorry-free live equivalents.
- **Abandoned composition route (Doets 1989, not Rabinovich):** `NfComposition` (self-documents its
  central lemma is FALSE for n≥2), `KampComposition`, `WitnessCount`, `ZoneBridge`. Superseded by the
  NF-zone approach. **Confirmed dead.**
- **Redundant stronger variant:** `NegationIndep` (model-independent Prop 4.2/5.1) — its own docstring
  concedes the live model-dependent path suffices. **Confirmed correctly parked.**
- **Partial scaffold:** `ArityReduction` (`fo_isVEA` never built). **Confirmed correctly parked.**

**Note on the task's grouping:** `VecEAArityFirewall` is listed among "refuted probes" in the task
prompt — this is **incorrect**. It is sorry-free faithful Lemma 3.2(2) and is live-imported; it is
not a NO-GO probe. See §3.

---

## 3. The wrongly-buried / restore-conditioned list

There is **no faithful carrier asset that was wrongly buried** — the carrier's faithful object
(`nf_zone_flatten_navigable`) is live. The items below are **completeness-direction** faithful
machinery whose restore is carrier/downstream-conditioned. All restores are **cycle-safe** (they sit
strictly below their consumers; verified via import chains — see report 08 §Q4 for the arity chain).

### 3a. Already reachable — NO restore action needed (only re-labeling)
- **`VecEA_m`, `EAVecNegationClosure`, `VecEAArityFirewall`** are already imported by live
  `Kamp/Prop43.lean`; `VecEA_m`/`NfZoneDepthK.lean`. They compile on every `lake build`. They are
  faithful (Prop 4.3 substrate / Prop 4.2-at-arity-m / Lemma 3.2(2)). **Action**: none required; if
  the v7 re-plan wants them "live" for the completeness direction, it merely relocates the `.lean`
  files out of `Boneyard/` and rewrites `import …Boneyard.X` → `import …X` in Prop43.lean and
  NfZoneDepthK.lean. **Do NOT** wire them into the endChar *carrier* (report 08 §Q4: `liftInterval`
  is the wrong tool — its `VVecEA_m`/free-env semantics ≠ the carrier's existential-witness VVecEA2).

### 3b. RESTORE-IF-Cprime (Prior-guarded closed-formula `charF` route)
- **`RabinovichTranslation`** (Prop 3.5, md:137; Theorem 4.4 TL half, md:185). Green, orphaned.
  Restore step: `git mv Boneyard/RabinovichTranslation.lean ..` (imports only `Kamp.Translation`,
  which is live → **no cycle**). Consumed by the FO→TL wrap that C′'s closed-formula `charF`
  ultimately feeds, and by downstream 350/309. **Adversarial caveat (§4)**: its *substance* is
  already live in `Translation.lean` (`translateEF1_correct`), so this is an ergonomic convenience,
  not a missing theorem.
- **`SeparationBridge`** (GHR94 Lemma 10.2.2 on **Prior** structures). Green, orphaned. Restore step:
  `git mv` (imports only `PriorDefs`, live → no cycle). Consumed by any completeness negation that
  must state ¬U/¬S over Prior-UZ/SZ rather than integer time. **Adversarial caveat (§4)**: the live
  integer-time siblings `neg_until_equiv`/`neg_since_equiv` (NegationEquiv.lean) already exist and
  are used; restore only if the Prior generalization is actually invoked.

### 3c. RESTORE-IF-D — none
Direction D (Prop-valued carrier threading `nf_zone_flatten_navigable`/Step-A) consumes **only
already-live green assets** (`endCharStep_quant_reduceA` NavigatedEndChar.lean:281;
`nf_zone_flatten_navigable_correct` Base.lean:687). **No Boneyard file is a D prerequisite** (report
08 §Q5). D needs zero restores.

---

## 4. Adversarial Self-Verification (H4)

I applied the Claim Verification Bar to every load-bearing claim and actively tried to refute each
RESTORE verdict by hunting for a live duplicate. Verification method for lean4 claims = direct
source line/type read (the source is authority; MCP hover unnecessary) or import-grep.

| Claim | Source / counter-probe | Verification Method | Confidence |
|-------|------------------------|---------------------|:----------:|
| Only 2/18 files have a real tactic sorry (`EndpointNegation:160`, `FOToVEA:118`) | per-file `grep -nE 'sorry'` isolating comment lines | grep + line inspection | High |
| Boneyard is **not** fully orphaned: 3 live files import it | grep of live `import …Boneyard` lines (Prop43.lean:1–2, NavigatedEndChar.lean:4) | lean_local_search-equiv grep hit | High |
| `VecEA_m`/`EAVecNegationClosure`/`VecEAArityFirewall` are transitively live-compiled | import chain Prop43.lean → Boneyard.{VecEA_m,EAVecNegationClosure} → VecEAArityFirewall | import-grep | High |
| Faithful **carrier** object is live, never buried (`nf_zone_flatten_navigable`, Base.lean:667/687) | reports 05:275, 07:150 row-6; grep of live NfZoneFlattenNavigable/Base | source read + report cross-ref | High |
| `RabinovichTranslation` (Prop 3.5) substance is already LIVE | `translateEF1_correct` Translation.lean:243; `translateVEF1_correct`:310; `translate_eq_translateEF1` (Boneyard) wraps it | direct source read | High |
| `SeparationBridge` has a live **integer-time** sibling, but the **Prior** form is unique | `neg_until_equiv`/`neg_since_equiv` NegationEquiv.lean:41/101 (used DedekindZ/Cases.lean); Prior variants only in Boneyard | grep (live vs Boneyard) | High |
| `NfExistTL`/`Prop43`(Boneyard) are superseded by live namesakes | `nf_succ_char_formula` KampPrior.lean:67; live `Kamp/Prop43.lean`; `nf_characterizable_temporal_prior` KampPrior.lean:407 | grep of live defs | High |
| `liftInterval`/arity machinery is the wrong tool for the endChar carrier (not a bury of a needed carrier asset) | report 08 §Q4 (VVecEA_m ≠ VVecEA2; VecEA_m.holds free-env); plan 06:107–108 "LEAVE ARCHIVED" | report + source cross-ref | High |
| Task prompt mis-groups `VecEAArityFirewall` as a "refuted probe" | file is sorry-free Lemma 3.2(2), live-imported; no `sorry`, no NO-GO verdict in file | direct source read | High |
| `NegationIndep` redundant (live model-dependent suffices) | file's own docstring lines 347–361 | direct source read | High |
| D needs zero Boneyard restores | report 08 §Q5; D-assets all live | report cross-ref | Medium (D's Phase-4/5 discharge itself not yet proved — orthogonal to this audit) |

**Refutation attempts against my RESTORE verdicts (self-challenge):**
- *RabinovichTranslation RESTORE-IF-Cprime*: **partially refuted** — Prop 3.5 is already live in
  `Translation.lean`; the Boneyard file is only an `ExistsForallSpec` wrapper. Downgraded from
  "wrongly buried faithful theorem" to "orphaned convenience." Still worth restoring for C′/350
  ergonomics, but nothing mathematical is missing from the live tree.
- *SeparationBridge RESTORE-IF-Cprime*: **not refuted** for the Prior form (no live Prior duplicate),
  but **contextually softened** — a live integer-time family exists, so restore only if completeness
  negation is stated over Prior structures. Not needed for endChar.
- *"Wrongly buried faithful machinery" (the task's central hypothesis)*: **refuted for the carrier.**
  The buried single-point line was the *unfaithful* one; the faithful two-endpoint carrier was never
  buried. The only faithful buried items are completeness-direction, and each has a live substrate.

**Contradiction Log.** No unresolved contradiction with reports 05–08. This report **confirms and
extends** report 08 §Q4/§Q5 (which analyzed only the arity/liftInterval files as *carrier* vehicles)
by (a) adding the completeness-direction files (`SeparationBridge`, `RabinovichTranslation`,
`NegationIndep`) it did not weigh, and (b) documenting that three "Boneyard" files are still on the
live build — a fact orthogonal to, and consistent with, 08's "cycle-safe to restore, but pointless
for the carrier."

---

## 5. Downstream (tasks 350 / 309)

Tasks 350/309 consume the endChar result feeding `nf_nvar_exist_all_depths` (KampPrior.lean:212) and
the FO→TL(U,S) wrap (Theorem 4.4, md:185). Their needs:
- **Carrier result** (whichever of D/C′ lands): already flows through live KampPrior. No Boneyard
  dependency.
- **FO→TL wrap**: consumes Prop 3.5. Live substance in `Translation.lean`; `RabinovichTranslation`'s
  `ExistsForallSpec`/`translateSpecs` is an ergonomic layer 350 may prefer to restore.
- **Completeness negation over Prior**: if stated over Prior-UZ/SZ, wants `SeparationBridge`'s
  `neg_until_equiv_prior`/`neg_since_equiv_prior` and the arity-`m` negation closure
  (`EAVecNegationClosure`, already live-imported). None of this is on the endChar critical path.

**Carrier-decision implication for v7 synthesis**: the D-vs-C′ choice is **not** gated by any
Boneyard restore. D restores nothing. C′ optionally relocates `RabinovichTranslation` (+
`SeparationBridge` if Prior-negation is needed) — both cycle-safe, both with live substrates. The
re-plan should therefore restore **exactly**: nothing for D; `RabinovichTranslation` (and
conditionally `SeparationBridge`) for C′; and it should **relabel** (not rewire-into-carrier) the
already-live `VecEA_m`/`EAVecNegationClosure`/`VecEAArityFirewall` if it wants them out of `Boneyard/`.
