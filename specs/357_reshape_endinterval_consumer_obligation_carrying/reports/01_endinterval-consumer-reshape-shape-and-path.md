# Task 357 — EndInterval Consumer Reshape (obligation-carrying): Shape, Routing, and Wiring Path

**Agent**: lean-research-agent · **Scope**: research only (no Lean/plan edits)
**Reference-grounding tier**: Tier 1 (literature-backed — Rabinovich 2014, Cor 5.4 + Lemma 7.6, via tasks 355/356)
**Dependencies (both complete/green)**: task 355 (interior gate), task 356 (general-`k` `hexclExt` exterior-adjacency discharge)
**Verdict**: **GREEN-VIABLE for the reshape + fill + thread core; the "discharge at provider site" DoD item is an ESCALATION BOUNDARY** — the interior/exterior realization obligations are un-discharged at *every* depth in the current tree (even the k=2 rung `kampPrior_site_rung2_gate_match` carries them un-discharged, consumed only by the still-open `KampPrior.lean:361/364` sorries). See §7.

---

## TL;DR

- **The reshape is a faithful, obligation-carrying mirror** of what tasks 355/356 already landed. `EndIntervalCorrect` (unconditional, `CarrierK1V.lean:2179`) becomes `EndIntervalCorrectPrior`: a **depth-cased** `Prop` (like `InteriorGateAllK`, `InteriorGateGeneralK.lean:1239`) carrying the provider bundle + realization obligations at successor depths. This is the only well-typed shape — the obligation binders reference `qnf.1` / `igFoldBit qnf` / arity-4 `σ`, which only typecheck at `k = n+1` (the exact R1 typing tension resolved in task 355).
- **`endIntervalStep` body fill is DEPTH-CASED** on its `{k}` parameter (step maps `k → k+1`):
  - `k = 0` (→ depth 1): interior-only rung `bracketEndChar_kv atomMap h_surj charF 1` (or `bracketEndChar_k1v`); depth 1 carries **no** exterior obligation (base rung).
  - `k = m+1` (→ depth `m+2 ≥ 2`): the exterior-composed gate `bracketEndChar_kvExt atomMap h_surj charF Pbr` (task 356, `ExteriorGateAssembleK.lean:51`), which discharges `hexclExt` **internally**.
- **Signature threading is the core mechanical work**: the carrier `bracketEndChar_kv`/`bracketEndChar_kvExt` need `charF` (and `Pbr : ExistProviders sig atomMap m` for the exterior branch) as construction inputs. `endIntervalStep` (currently `atomMap, h_surj, rec` only) and `endInterval` must gain `charF` + a provider family; `EndIntervalCorrectPrior` carries them plus the obligation bundle. This is the "route the seven provider obligations up to the KampPrior recursion" move.
- **`endInterval_step_correct` (task 349 Phase 5) is provable GREEN NOW** by consuming `bracketEndChar_kvExt_correct_prior` (`ExteriorGateAssembleK.lean:106`) at the successor branch and `interiorGateTarget_one` / the depth-1 rung at `k=0`, **threading** the 7+4 obligations outward. This closes Phase 5 as an obligation-carrying contract — the same discipline as the k=2 rung.
- **The four extra task-356 obligations** (`hbrPastReal`, `hbrPastSat`, `hbrFutReal`, `hbrFutSat`, `ExteriorGateAssembleK.lean:142-167`) thread identically to `hreal`/`hexcl`. Their discharge site is `kvE_{fut,past}Bundle_of_realizer` (`ExteriorConverterK.lean:208` / `ExteriorConverterPastK.lean:177`) applied to a genuine exterior realizer produced by the provider recursion — **the same site that would discharge `hreal`/`hexcl`, which is the currently-open `KampPrior:361` sorry**.
- **Import reachability gap (must be fixed)**: the aggregator `NfMultiAnchorBridge.lean` imports only up to k=2 `ExteriorBracket` (line 47). `InteriorGateGeneralK`, `ExteriorBracketAssembleK`, `ExteriorConverter{,Past}K`, and the new `ExteriorGateAssembleK` are **not reachable** from `KampPrior`. Task 357 must thread them (add to the aggregator or a direct `KampPrior` import; all are acyclic leaves).

---

## 1. The current consumer (frozen) — `EndIntervalCorrect`

`CarrierK1V.lean:2179` (verified by read). Unconditional ∀-`k` biconditional:

```lean
def EndIntervalCorrect atomMap h_surj : Prop :=
  ∀ (k) (qnf : NormalForm sig k 3) (M) (x t) (six k0-mirror order bits on qnf.atom_assgn),
    (endInterval atomMap h_surj k qnf).holds M atomMap x t ↔
      ∃ w, nf_eval_nf M k 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf
```

Supplies **none** of `P`, `hcharK`, `h_UZ`, `h_SZ`, `hreal`, `hexcl`, `hexclExt`. `endInterval` (`:2159`) is `Nat.rec` with base `VVecEA2.singleton (bracketEndChar_k0 …)` (depth 0) and step `endIntervalStep` (`:2144`, the `⟨[]⟩` empty-disjunction placeholder). The `k=0` base `endInterval_zero_correct` (`:2199`) is already green. Task 355 report Q3 established (adversarially) that this unconditional shape is **unreachable at k≥2** (F1 information-blindness) and that the fix is a *two-sided* reshape — exactly this task.

---

## 2. The reshape shape — `EndIntervalCorrectPrior` (depth-cased, obligation-carrying)

Mirror `InteriorGateAllK` (`InteriorGateGeneralK.lean:1239`) verbatim in structure. A flat uniform ∀-`k` signature **cannot** quantify the obligations (they reference successor-only `qnf.1`/`igFoldBit`/arity-4 `σ`), so the target is a `k`-cased `Prop`:

```lean
def EndIntervalCorrectPrior atomMap h_surj charF : (k : Nat) → Prop
  | 0     => <clean, obligation-free depth-0 biconditional on endInterval …0>   -- = endInterval_zero_correct
  | 1     => <interior-only depth-1 biconditional>                              -- carries only h0 (charF 0 agreement); no exterior obligation
  | (m+2) => ∀ (qnf : NormalForm sig (m+2) 3) (six order bits on qnf.1)
               (P : ExistProviders sig atomMap (m+1)) (hcharK : charF (m+1) = fun χ => P.existF 0 χ)
               (Pbr : ExistProviders sig atomMap m)
               (M) (h_UZ) (h_SZ) (x t)
               (hreal) (hexcl)                       -- interior realization + within-[x,t] exclusion (task 355 shape)
               (hbrPastReal)(hbrPastSat)(hbrFutReal)(hbrFutSat),  -- task-356 exterior interface (∀-w-gated)
             (endInterval … (m+2) qnf).holds M atomMap x t ↔
               ∃ w, nf_eval_nf M (m+2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf
```

**Why three arms, not two** (unlike `InteriorGateAllK`'s two arms): the exterior-composed gate `bracketEndChar_kvExt` exists only at interior depths **≥ 2** (its brackets need `σ : NormalForm sig (m+1) 4` with sub-subs `s : NormalForm sig m 5`). Depth 1 has **no** exterior residue — it is a base rung. So the cases are: `0` (clean), `1` (interior-only), `m+2` (exterior-composed, full bundle). Task 356 report §"Index / base-rung fact" confirms: "this discharge is a ∀-`k` family covering interior depths ≥ 2; interior depths 0 and 1 are the already-delivered base rungs, which carry no exterior obligation."

**Obligation list**: the depth-`(m+2)` arm's binders are the **union** of task 355's seven interior binders (`P, hcharK, h_UZ, h_SZ, hreal, hexcl` + the internalized `hexclExt`) and task 356's four exterior binders (`hbr*`), plus `Pbr`. `hexclExt` is **NOT** an input binder in this arm — `bracketEndChar_kvExt_correct_prior` discharges it internally. The exact obligation types are copied verbatim from `ExteriorGateAssembleK.lean:106-167` (they are already stated at the matching depth-index `(k+2)`, `k := m`).

---

## 3. The `endIntervalStep` body fill (`CarrierK1V.lean:2144`)

Current: `fun _ => (⟨[]⟩ : VVecEA2)` (sanctioned placeholder). Fill (depth-cased on the implicit `{k}`):

```lean
noncomputable def endIntervalStep {sig} {k : Nat}
    (atomMap) (h_surj)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)   -- NEW
    (Pfam : <provider family, see §4>)                    -- NEW (exterior branch only)
    (rec : BracketEndCharCarrierV sig k) : BracketEndCharCarrierV sig (k + 1) :=
  match k with
  | 0      => bracketEndChar_kv atomMap h_surj charF 1          -- depth 1, interior-only rung
  | (m+1)  => bracketEndChar_kvExt atomMap h_surj charF (Pbr m) -- depth m+2, exterior-composed (task 356)
```

- The step **does not thread the arity-3 IH `rec`** — consistent with task 355 Phase 7's finding ("the step does NOT thread the arity-3 IH; Phases 4/5 realize interior content via the provider `P`"). `rec` may be dropped or ignored.
- `bracketEndChar_kvExt atomMap h_surj charF Pbr : BracketEndCharCarrierV sig ((m)+2) = BracketEndCharCarrierV sig ((m+1)+1)` — depth matches the step codomain `k+1` at `k=m+1`. ✔ (depth-index reconciliation, §6).
- `bracketEndChar_kvExt`'s **def** (`ExteriorGateAssembleK.lean:51`) needs only `charF` and `Pbr : ExistProviders sig atomMap m` — the heavier `P : ExistProviders sig atomMap (m+1)` appears only in the *correctness* theorem, not the carrier. So the carrier fill needs `charF` + `Pbr` (depth `m`).

**Consequence**: `endInterval` (`:2159`) must gain `charF` (+ the provider family), which propagates to `EndIntervalCorrectPrior`. This is the mechanical heart of the "two-sided reshape."

---

## 4. Obligation routing up to `KampPrior.lean` (where providers/UZ/SZ live)

The providers are **constructible and landed** at KampPrior (task 309 Phase 16):
- `kampPrior_existProviders_of_ih` (`KampPrior.lean:895`) builds `ExistProviders sig atomMap j` from the recursion's IH family, all arities, sorry-free; `…_correct` (`:912`) gives `existF n sub`'s biconditional for **every** arity `n` (including arity-5, `n=4`, needed for `hbr*`).
- Depth-1 bundle `kampPrior_existProviders_one_of_ih` (`:1000`) and concrete depth-0 `kampPrior_existProviders_zero` (`:~1030`) exist.
- `semantic_prior_UZ`/`_SZ` are in scope throughout `nf_nvar_exist_all_depths` (`KampPrior.lean:89-98, 299-313, 381+`).

`nf_nvar_exist_all_depths` (`KampPrior.lean:~230-364`) is the recursion where `char_k1`/providers/UZ/SZ are built; its `| 1 =>` arm (`:361`) and `| n+2 =>` arm (`:364`) are the still-open `sorry`s. The **k=2 supply precedent** to mirror is the rung table + site certificates (`KampPrior.lean:620-798`):

| arm k | depth | rung lemma | conditionality | site cert |
|-------|-------|-----------|----------------|-----------|
| 0 | 0 | `bracketEndChar_kv_correct_zero_prior` | unconditional | `kampPrior_site_rung0_match` |
| 1 | 1 | `bracketEndChar_kv_correct_one_prior` | `h0` only | `kampPrior_site_rung1_match` |
| 2 | 2 | `bracketEndChar_kvE2Ext_correct_two_prior_frag` (`hexclExt` internal) | `hfrag`+`hrealI`/`hrealB`/`hexcl`+bits | `kampPrior_site_rung2_gate_match` (`:761`) |
| ≥3 | ≥3 | **none (GO-k1 gap)** | — | — |

**Task 357 adds the general-`k` rung**: a site certificate `kampPrior_site_rungK_gate_match` analogous to `:761`, restating `bracketEndChar_kvExt_correct_prior`'s biconditional against the per-`qnf` seam, **carrying** the 7+4 obligations (exactly as rung2 carries `hrealI`/`hrealB`/`hexcl`). This uniformly subsumes the k=2 arm and fills arms k≥3.

---

## 5. Discharge sites for all 11 obligations

| Obligation | Origin | Discharge mechanism | Landed? |
|-----------|--------|---------------------|---------|
| `P`, `hcharK`, `Pbr` | provider bundle | `kampPrior_existProviders_of_ih` (`:895`) + `hcharK` via `…_existF0_char` (`:936`) | **YES** |
| `h_UZ`, `h_SZ` | Prior hypotheses | in scope at `nf_nvar_exist_all_depths` | **YES** |
| six order bits | seam typing | the per-`qnf` seam (`kampPrior_site_rung*` pattern) | **YES** |
| `hreal` (interior realization) | task 355 (`InteriorGateGeneralK.lean:1258`) | provider `existF 3` / `P.correct` at arity-4 + Rabinovich Cor 5.4 inf/sup witness selection | **NO — un-landed at every depth** |
| `hexcl` (within-`[x,t]` exclusion) | task 355 | same site | **NO** |
| `hbrPastReal`/`hbrFutReal` | task 356 (`:142`/`:155`) | first conjunct of `kvE_{past,fut}Bundle_of_realizer` from a genuine exterior realizer | **NO (needs exterior realizer)** |
| `hbrPastSat`/`hbrFutSat` | task 356 (`:147`/`:160`) | second conjunct of `kvE_{past,fut}Bundle_of_realizer` | **NO (needs exterior realizer)** |

**Critical finding (adversarially verified)**: the interior/exterior realization obligations are **not discharged anywhere** in the current tree. The k=2 rung `kampPrior_site_rung2_gate_match` (`:761`) *carries* `hrealI`/`hrealB`/`hexcl` un-discharged; its only consumer is the `KampPrior:361`/`:364` **sorry** arms. Task 356 itself documented that the four `hbr*` are "not derivable from `h`" locally (an unmarked `σ`, `qnf.2 σ = false`, is realized at no interior `x1`) — they require the **outer recursion's** exterior witness. That outer recursion is `nf_nvar_exist_all_depths`, whose `n≥1` arms are the open sorries. `kvE_{fut,past}Bundle_of_realizer` is only the *converter*: given a genuine realizer `hσ : nf_eval_nf M (m+1) 4 [x1,w,x,t] σ`, it yields the `hbr*` conjuncts (verified read, `ExteriorConverterK.lean:208-227`). The missing piece is **producing `hσ`** — the un-landed realization mathematics (task 309 Phase 14 successor).

---

## 6. Depth-index reconciliation (must be nailed)

- `endIntervalStep {k} : BracketEndCharCarrierV sig k → BracketEndCharCarrierV sig (k+1)`; at the step, `qnf : NormalForm sig (k+1) 3`.
- `bracketEndChar_kvExt {k'} : … → BracketEndCharCarrierV sig (k'+2)` (`ExteriorGateAssembleK.lean:56`); `qnf : NormalForm sig (k'+2) 3`, sub `σ : NormalForm sig (k'+1) 4`, sub-sub `s : NormalForm sig k' 5`.
- Alignment: at `k = m+1`, codomain depth `k+1 = m+2 = k'+2` with `k' = m`. ✔ The exterior gate applies exactly at step-parameter `k ≥ 1`; `k = 0` (depth 1) uses the interior-only rung. The k=2 discharge is the `k'=0` member — a direct cross-check.
- `bracketEndChar_kvExt_correct_prior` feeds `bracketEndChar_kv_step_correct` at its implicit `{k} := m+1` so `σ : NormalForm sig (m+1) 4` lines up (task 356 summary §"Depth-index resolution", confirmed by read).
- `EndIntervalCorrect`'s env `Fin.cons w (Fin.cons x (fun _ => t))` matches the rung certs' `zoneEnv3 w x t` (`NfZoneDepthK.lean:207`) — confirm defeq (`rfl`) during wiring; minor.
- Order-bit form: `EndIntervalCorrect` reads `qnf.atom_assgn (.order …)`; the successor arms of `InteriorGateAllK`/`bracketEndChar_kvExt_correct_prior` read `qnf.1 (.order …)`. `NormalForm.atom_assgn` is defeq to `qnf.1 (.order …)` at successor depth (noted `CarrierK1V.lean:2174`, `PriorInterface.lean:53`) — the bits transfer without a rewrite.

---

## 7. Green-viability verdict and escalation boundary

**Green-viable NOW (recommended primary deliverable)** — closes task 349 Phase 5:
1. Add `charF` + provider family to `endIntervalStep`/`endInterval`; depth-case the `endIntervalStep` body (§3).
2. Define `EndIntervalCorrectPrior` as the 3-arm depth-cased obligation-carrying `Prop` (§2).
3. Prove `endInterval_step_correct` (Phase 5): `k=0` via the depth-1 interior rung (`interiorGateTarget_one`/`bracketEndChar_kv_correct_one_prior`); `k=m+1` by **consuming** `bracketEndChar_kvExt_correct_prior` and **threading** the 7+4 obligations outward. All inputs are landed sorry-free ⇒ green, axiom-clean.
4. Thread the new modules into the import graph (fix the aggregator reachability gap) and add the general-`k` site certificate `kampPrior_site_rungK_gate_match` (carrying, mirroring rung2).

This is faithful to the entire existing architecture, which is **obligation-carrying up to the KampPrior sorry** — an obligation-carrying `EndIntervalCorrectPrior` is the consistent, correct shape and is exactly what task 355 (`InteriorGateAllK`) and task 356 (`bracketEndChar_kvExt_correct_prior`) delivered.

**ESCALATION BOUNDARY (the DoD "four extra obligations discharged at the provider site")**: actually *discharging* `hreal`/`hexcl`/`hbr*` (rather than carrying them) requires retiring the `KampPrior:361`/`:364` sorries, which is blocked on the **un-landed realization recursion** (`nf_nvar_exist_all_depths` `n≥1` arms) — the Rabinovich Cor 5.4 inf/sup witness-selection that produces the genuine interior/exterior realizers `hσ` that `kvE_{fut,past}Bundle_of_realizer` converts. This mathematics is **not among task 357's landed dependencies (355, 356)** and is un-discharged at every depth including k=2. **Recommendation**: the implementer should verify early whether the realization content is available at the `nf_nvar_exist_all_depths` recursion. If it is not (expected), deliver the obligation-carrying reshape (which fully closes Phase 5 green) and **mark the full-discharge / `KampPrior:361` retirement `[BLOCKED]`**, routing to a spawn for the realization recursion (task 309 Phase 14 successor). **Do NOT land a `sorry` or vacuous definition to force the discharge** (zero-debt gate; escalation clause).

---

## 8. Reference-Grounding Mapping Table (5 columns)

| Source | Prop / Location | Lean Identifier (file:line) | Type Signature (verified by read) | Status |
|--------|-----------------|-----------------------------|-----------------------------------|--------|
| task 349 (consumer, frozen) | unconditional ∀-k contract | `EndIntervalCorrect` (`CarrierK1V.lean:2179`) | `∀ k qnf M x t (6 bits), (endInterval …k qnf).holds ↔ ∃w …` | RESHAPE TARGET → `EndIntervalCorrectPrior` |
| task 349 | step carrier hole | `endIntervalStep` (`CarrierK1V.lean:2144`) | `atomMap h_surj (rec) : BracketEndCharCarrierV sig (k+1)`; body `⟨[]⟩` | FILL TARGET (depth-cased §3) |
| task 349 | k=0 base (green) | `endInterval_zero_correct` (`CarrierK1V.lean:2199`) | depth-0 biconditional via `singleton_holds` | REUSE (k=0 arm) |
| task 355 | ∀-k obligation motive | `InteriorGateAllK` (`InteriorGateGeneralK.lean:1239`) | 2-arm cased `Prop`; successor arm = 7-obligation biconditional | STRUCTURE TEMPLATE for `EndIntervalCorrectPrior` |
| task 355 | ∀-k obligation gate | `bracketEndChar_kv_correct_prior` (`InteriorGateGeneralK.lean:1288`) | `∀k, InteriorGateAllK …` | interior-half consumer |
| task 355 | depth-1 interior rung | `interiorGateTarget_one` (`:102`) / `bracketEndChar_kv_correct_one_prior` (`PriorInterface.lean:95`) | `BracketCarrierCorrectVPrior … (bracketEndChar_kv …1)`, `h0` only | k=1 arm discharge |
| task 356 | **exterior-composed carrier** | `bracketEndChar_kvExt` (`ExteriorGateAssembleK.lean:51`) | `atomMap h_surj charF Pbr : BracketEndCharCarrierV sig (k+2)` | endIntervalStep k=m+1 body |
| task 356 | **`hexclExt`-internal discharge** | `bracketEndChar_kvExt_correct_prior` (`ExteriorGateAssembleK.lean:106`) | `holds ↔ ∃w, nf_eval_nf M (k+2) 3 …`; carries `P,hcharK,Pbr,h_UZ,h_SZ,hreal,hexcl` + **4 `hbr*`** + bits | Phase-5 successor consumer |
| task 354 | ⇐ discharge template (Future) | `kvE_futBundle_of_realizer` (`ExteriorConverterK.lean:208`) | from realizer `hσ` of σ at `[x1,w,x,t]` → (`hbrFutReal`-shape ∧ `hbrFutSat`-shape) | discharges `hbrFut*` (given `hσ`) |
| task 354 | ⇐ discharge template (Past) | `kvE_pastBundle_of_realizer` (`ExteriorConverterPastK.lean:177`) | mirror | discharges `hbrPast*` (given `hσ`) |
| task 309 P16 | provider bundle (landed) | `kampPrior_existProviders_of_ih` (`KampPrior.lean:895`), `…_correct` (`:912`) | builds `ExistProviders sig atomMap j`, all arities | supplies `P`/`Pbr`/`hcharK` |
| task 309 P15 | k=2 supply precedent | `kampPrior_site_rung2_gate_match` (`KampPrior.lean:761`) | rung-2 biconditional CARRYING `hfrag`+`hrealI`/`hrealB`/`hexcl` | rung template to mirror; **carries, not discharges** |
| task 309 | realization recursion (OPEN) | `nf_nvar_exist_all_depths` `\|1=>`/`\|n+2=>` (`KampPrior.lean:361`/`:364`) | `sorry` | **BLOCKER for actual discharge** |
| — | aggregator (reachability gap) | `NfMultiAnchorBridge.lean:47` | imports up to k=2 `ExteriorBracket` only | ADD general-k modules |

---

## 9. Faithful transcription / wiring path (step-ordered)

1. **Fix import reachability**: add `ExteriorGateAssembleK` (and its transitive deps `InteriorGateGeneralK`, `ExteriorBracketAssembleK`, `ExteriorConverter{,Past}K`) to the `NfMultiAnchorBridge.lean` aggregator (or a direct `KampPrior` import). All are acyclic additive leaves (verified: `ExteriorGateAssembleK` imports only `InteriorGateGeneralK` + `ExteriorBracketAssembleK`). This makes `CarrierK1V` — which the aggregator already imports at line 30 — able to see the general-k carriers, and makes `KampPrior` see the discharge lemma.
   - **Watch**: `CarrierK1V.lean` currently sits *above* `InteriorGateGeneralK`/`ExteriorGateAssembleK` in the import order (aggregator line 30 vs the un-imported general-k files). Filling `endIntervalStep` with `bracketEndChar_kvExt` makes `CarrierK1V` **depend on** `ExteriorGateAssembleK`. Verify this does not create a cycle (`ExteriorGateAssembleK` imports `InteriorGateGeneralK`, which imports `CarrierKv`/`PriorInterface`… confirm none transitively import `CarrierK1V`). If a cycle appears, the reshaped `endInterval`/`EndIntervalCorrectPrior` must move to a **new leaf module** below `ExteriorGateAssembleK` rather than staying in `CarrierK1V` — flag for the planner.
2. **Reshape `endIntervalStep`** (§3): add `charF` + provider-family params; depth-case the body.
3. **Reshape `endInterval`** (`:2159`): thread `charF` + provider family through the `Nat.rec`.
4. **Define `EndIntervalCorrectPrior`** (§2): 3-arm depth-cased `Prop`, obligation types copied verbatim from `ExteriorGateAssembleK.lean:106-167` (already at the right depth-index).
5. **Prove `endInterval_step_correct`** (task 349 Phase 5): `k=0` via `bracketEndChar_kv_correct_one_prior`; `k=m+1` via `bracketEndChar_kvExt_correct_prior`, threading obligations. Reuse `endInterval_zero_correct` for `k=0` base of the full `EndIntervalCorrectPrior` induction.
6. **Add the general-k site certificate** `kampPrior_site_rungK_gate_match` (mirror `:761`), carrying the 11 obligations.
7. **Attempt the discharge** at the `nf_nvar_exist_all_depths` recursion IF the realization content is present; otherwise **escalate `[BLOCKED]`** per §7 (do not sorry).
8. **Verify**: `lake build` full-tree GREEN; `lean_verify EndIntervalCorrectPrior` / `endInterval_step_correct` axioms exactly `[propext, Classical.choice, Quot.sound]`.

---

## 10. Literature Proof Structure (Rabinovich 2014 — inherited, not re-derived)

**Source**: task 355 report §"Literature Proof Structure" + task 356 report §"Literature Proof Structure" (both read chunk_0015 Cor 5.4 / chunk_0021 Lemma 7.6 independently; not re-read here per grounding instruction).

- **Cor 5.4 (single-bracket interior)** → the interior gate `bracketEndChar_kv`; the within-bracket bounded witness `(∃z)^{<z1}_{>z0}` is the `hreal`/`hexcl` content.
- **Lemma 7.6 (adjacency composition)** → the `hexclExt` exterior residue, discharged by the two adjacent brackets in `bracketEndChar_kvExt` (degenerate at free anchors `x,t` = endpoint conjunction via `enrichEndpoints`).
- **Step map for task 357** is a *wiring* map (no new mathematics): (1) route providers up, (2) case the carrier by depth, (3) consume the two landed discharge lemmas, (4) thread the realization obligations to where the recursion supplies witnesses.
- **Formalization challenge**: the realization witnesses (`hσ`) that `kvE_{fut,past}Bundle_of_realizer` needs are the un-landed inf/sup selection (Cor 5.4) — the §7 escalation boundary.

---

## 11. Adversarial self-checks performed

| Claim | Verification | Confidence |
|-------|--------------|------------|
| `EndIntervalCorrect` is unconditional; no `EndIntervalCorrectPrior` exists | Read `CarrierK1V.lean:2179-2190`; matches task 355 Q3 grep (0 hits) | High |
| `bracketEndChar_kvExt` def needs only `charF`+`Pbr` (not `P`) | Read `ExteriorGateAssembleK.lean:51-60` | High |
| `bracketEndChar_kvExt_correct_prior` carries 4 extra `hbr*` beyond the 7 | Read `ExteriorGateAssembleK.lean:106-167` (binders enumerated) | High |
| Exterior gate exists only at depth ≥ 2 ⇒ 3-arm cased target | `qnf : NormalForm sig (k+2) 3` in the def; depth-1 has no exterior residue (task 356 report) | High |
| `hbr*`/`hreal`/`hexcl` NOT discharged anywhere; k=2 rung carries them | Read `kampPrior_site_rung2_gate_match:761` (carries `hrealI/hrealB/hexcl`); its consumer is the `:361` sorry | High |
| `nf_nvar_exist_all_depths` n≥1 arms are open sorries | Read `KampPrior.lean:361, 364` | High |
| Providers constructible (P/Pbr/hcharK) | Read `kampPrior_existProviders_of_ih:895` + `_correct:912` (all arities) | High |
| `kvE_{fut,past}Bundle_of_realizer` needs a genuine realizer `hσ` (converter only) | Read `ExteriorConverterK.lean:208-227` / `PastK:177-194` | High |
| Import reachability gap (aggregator stops at k=2 `ExteriorBracket`) | Read `NfMultiAnchorBridge.lean:29-47` (no general-k imports) | High |
| Filling `endIntervalStep` may invert the `CarrierK1V` ↔ `ExteriorGateAssembleK` import order | Aggregator imports `CarrierK1V` at line 30; general-k files un-imported ⇒ order risk | Medium (flagged for planner) |

No `sorry`/deferral/axiom route is recommended. Every "carries / discharges / exists" claim cites a read Lean signature.

---

## 12. Files read (evidence base, absolute paths)

- `…/NfMultiAnchorBridge/CarrierK1V.lean` (2090-2216: `endIntervalStep`/`endInterval`/`EndIntervalCorrect`/base; 365, 433-445: carrier/`bracketEndChar_k1v`)
- `…/NfMultiAnchorBridge/InteriorGateGeneralK.lean` (1200-1332: `InteriorGateAllK`, `bracketEndChar_kv_correct_prior`, consumability example; 1258-1275: obligation binders)
- `…/NfMultiAnchorBridge/ExteriorGateAssembleK.lean` (full: `bracketEndChar_kvExt`, `_holds_iff`, `_correct_prior` with 4 `hbr*`)
- `…/NfMultiAnchorBridge/ExteriorConverterK.lean` (180-227: `kvE_futBundle_of_realizer`), `ExteriorConverterPastK.lean` (150-197: `kvE_pastBundle_of_realizer`)
- `…/NfMultiAnchorBridge/PriorInterface.lean` (38-108: `ExistProviders`, `BracketCarrierCorrectVPrior`, `bracketEndChar_kv_correct_{zero,one}_prior`)
- `…/Kamp/KampPrior.lean` (300-364: `nf_nvar_exist_all_depths` + open sorries; 606-798: rung table + site certs `rung0/1/2`; 849-1030: Phase-16 provider instantiation)
- `…/Kamp/NfMultiAnchorBridge.lean` (imports — reachability gap)
- `specs/355_.../reports/01_…md`, `specs/355_.../plans/02_…md`, `specs/356_.../reports/01_…md`, `specs/356_.../summaries/01_…md` (grounding, inherited)
