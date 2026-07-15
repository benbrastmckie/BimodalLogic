# Task 369 — M1 endpoint-`Until` firing supply: bounded feasibility adjudication

Session: sess_1784091172_81406c · Agent: lean-research-hard-agent (H2/H3/H4)
Date: 2026-07-14 · Reference-grounding tier: **Tier 1** (literature `rabinovich_2014` + landed source)

---

## VERDICT (headline, unambiguous)

**M1 is NOT PROVABLE from its stated hypotheses. Fall back to M2 (de-folded interior carrier).**

The obligation `kvE_futPos_supply_of_endpoint` — upgrade the 1-type `Until` witness that `igEpR@t`
provides to a full arity-4 `σ`-witness using ONLY `hAmb` (syntactic EF-closure), `hcons`
(fiber-consistency), and depth-`(k+1)` saturation — cannot be discharged, because:

1. The **conclusion is arity-4-complete**: `temporal_truth M t (kvE_futPos P σ)` provably entails
   (via the landed driver `kampPrior_futRealizer_of_pos`, using only depth-`k` `P` facts) the
   existence of a full `nf_eval_nf M (k+1) 4 [x1,w,x,t] σ` realizer in **this** `M` future of `t`.
2. The **only model-carrier input at the site is arity-1**: `hepR` (the `igEpR@t` eval) fires only
   `Until(charK χ, ⊤)` over depth-`(k+1)` **1-types** `χ = nfk_projFresh σ` — the documented F1
   lossy fold (`igFoldBit` is `decide (∃ sub, qnf.2 sub ∧ zoneSpec sub = zs ∧ nfk_projFresh sub =
   χ)`, projecting arity-4 subs to arity-1 and discarding fiber identity).
3. **Every other hypothesis is model-independent**: `hAmb` (`kvE_ambientDeepAnchor_iff` — a purely
   syntactic `∀τ∀ρ∃σ'` closure with no `M`), `hcons` (`kvE_fiberConsistent` — docstring: "there is
   no model parameter"; its co-realization is an internal `∃ M` existential, not **this** `M`),
   `hmark`, `hfut` (syntactic Bool predicates). None can manufacture a specific-`M` arity-4 witness.
4. **`P` is a depth-`k` characterization, not a depth-`(k+1)` generator**: `ExistProviders.correct`
   is a biconditional that *reads back* depth-`k` realization at a fixed anchor; it neither creates
   points nor realizes depth-`(k+1)` types.
5. The **one ingredient that would bridge the arity-1 → arity-4 gap — depth-`(k+1)` saturation of
   the specific `M` future of `t` — is (a) NOT among M1's hypotheses, and (b) precisely the
   task-358 recursion's own conclusion** (`ExistProviders` at depth `k+1`, built by
   `kampPrior_existProviders_of_ih` from depth `k`). Assuming it is circular.

Confidence: **HIGH** (structural, source-grounded). See §Adversarial Self-Verification for the one
residual (a machine-certain refutation would need a *fiber-consistent* fold-collision witness; the
landed doppelgänger has `hcons = false`, so it does not by itself refute M1-under-`hcons` — the
verdict rests on the model-independence classification, not on the probe).

**Planner instruction:** produce an **M2 scope-and-document plan** (see §M2). Do NOT dispatch an
M1-build plan. Do NOT re-dispatch the current `kampPrior_hreal_supply` body against the existing
(or `hepR`-enriched) binder — it is provably under-provisioned.

---

## Findings — H3 Tier 1 lemma-level mapping table

| # | Source (paper / landed lemma) | Prop / Location | Lean Identifier | Type Signature (abbreviated) | Status |
|---|-------------------------------|-----------------|-----------------|------------------------------|--------|
| 1 | Landed carrier | `InteriorGateGeneralK.lean:318-332` | `igFoldBit` | `NormalForm sig (k+1) 3 → ZoneSpec 3 → NormalForm sig k 1 → Bool`, `= decide (∃ sub, qnf.2 sub ∧ nf0_zoneSpec (atom_assgn sub)=zs ∧ nfk_projFresh sub=χ)` | **Read-confirmed lossy** (∃-projection to arity-1 `nfk_projFresh`) |
| 2 | Landed carrier | `InteriorGateGeneralK.lean:219-225` | `igEpR` | FutT conjunct `= igLit (b igZFutT χ) (Formula.untl (charK χ) ⊤)` over `χ : NF sig (k+1) 1` | **Read-confirmed arity-1** (fires `Until` on 1-types) |
| 3 | Landed carrier | `InteriorGateGeneralK.lean:209-215` | `igEpL` | PastX conjunct `= igLit (b igZPastX χ) (Formula.snce (charK χ) ⊤)` | **Read-confirmed arity-1** (past mirror, `Since`) |
| 4 | Landed carrier | `InteriorGateGeneralK.lean:243-248` | `igPtW` | AtW-zone-only: `igLit (b igZAtW χ) (charK χ)` over 1-types | **Read-confirmed lossy** (root cause F1) |
| 5 | Landed def | `ExteriorNegationK.lean:429-435` | `kvE_futPos` | `... := if kvE_futAdmissible σ then disjList over gap-zone perms of (D-guarded Until chain ending in kvE_futEnd) else ⊥` | **Read-confirmed arity-4-complete** (chain of arity-5 gap fibers + endpoint self-fiber) |
| 6 | Landed lemma | `ExteriorPinnedConverseK.lean:252-263` | `kvE_futPos_of_realizer` | `hσ : nf_eval_nf M (k+1) 4 [x1,w,x,t] σ → temporal_truth M t (kvE_futPos P σ)` | **Read-confirmed realizer-gated** (forward: realizer ⇒ firing) |
| 7 | Landed driver | `KampPrior.lean:1662-1716` | `kampPrior_futRealizer_of_pos` | `hpos : temporal_truth M t (kvE_futPos P σ)` + depth-`k` `hreal`/`hsat` `→ ∃ x1>t, nf_eval_nf M (k+1) 4 [x1,w,x,t] σ` | **Read-confirmed converse** (firing ⇒ realizer; `hreal`/`hsat` are depth-`k`, from `P`) |
| 8 | Landed guard | `ExteriorAmbientDeepAnchorK.lean:109-165` | `kvE_ambientDeepAnchor` / `_iff` | `= true ↔ ∀τ marked ∀ρ deep ∃σ' marked, σ'.2 (swapNF01 ρ)` — **no `M`, no `temporal_truth`** | **Read-confirmed syntactic** (hAmb has zero model content) |
| 9 | Landed guard | `ExteriorFiberConsistencyK.lean:74-96` | `kvE_fiberConsistent` / `_ElemConsistent` | per-fiber honesty; co-realization is internal `∃ M env u` — docstring: **"Model-independent … no model parameter"** | **Read-confirmed model-independent** (hcons cannot pin **this** `M`) |
| 10 | Landed interface | `PriorInterface.lean:38-45` | `ExistProviders.correct` | `temporal_truth M t (existF n sub) ↔ ∃ env, nf_eval_nf M k (n+1) (insertEnv env t) sub` | **Read-confirmed depth-`k` tester** (characterization, not generator) |
| 11 | Landed probe (sorry-free) | `ExteriorPinnedProbeM1K.lean:610-626` | `kvE_probeM1_sliceId_superseded` | fold side identical honest vs fake, fake has no marked mate | **`lean_verify` = `[propext, Classical.choice, Quot.sound]`** (no `sorryAx`) |
| 12 | Landed probe | `ExteriorFiberConsistencyProbeK.lean:305` | `kvE_probe363_qnfG1_antecedent_fails` | fake `m1sigma` has `kvE_fiberConsistent = false` | **Read-confirmed** — the probe fake is excluded by `hcons` (see H4) |
| 13 | rabinovich_2014 | Cor 5.4(1)⇐ (chunk_0015 L23-29) | — | witness `y2` fired directly off `βn+1 Until αn+1`; **no fold**, full bracket sequence carried | **Literature** — the paper never folds; Lean's fold IS the divergence |

---

## The bounded adjudication (the heart of the task)

### What `hepR` actually supplies (arity-1)

`igEpR@t.eval_at M atomMap t` (landed def, `InteriorGateGeneralK.lean:219-225`) is a conjunction
whose FutT block is, for every depth-`(k+1)` 1-type `χ`:
`igLit (igFoldBit qnf igZFutT χ) (Formula.untl (charK χ) ⊤)`. For the target `σ`'s projection
`χ_σ := nfk_projFresh σ` (arity-1), since `qnf.2 σ = true` and `σ`'s zone is FutT,
`igFoldBit qnf igZFutT χ_σ = true` (by the `igFoldBit` ∃-definition, witnessed by `σ` itself), so
`hepR` yields `temporal_truth M t (Until(charK χ_σ, ⊤))` = **∃ v > t with depth-`(k+1)` 1-type
`= χ_σ`**. That is the *entire* model content: a single future point whose **arity-1** type matches
`σ`'s fresh projection. No ordering among future points, no arity-4/arity-5 relational fiber.

### What the conclusion actually demands (arity-4)

`temporal_truth M t (kvE_futPos P σ)` unfolds (`kvE_futPos`, `ExteriorNegationK.lean:429`;
admissible branch) to a disjunction over permutations `l` of `σ`'s gap-zone fiber list of the
**`D`-guarded `Until` chain** `kvE_futChain P σ l`, each ending in `kvE_futEnd P σ`. For it to hold
at `t` there must exist a genuine ordered sequence `t < r_1 < … < x1` in `M` where each `r_i`
realizes an **arity-5 depth-`k` gap fiber** `s_i` (via `kvE_futItemShift_correct`,
`ExteriorNegationK.lean:456`: `↔ ∃ env, nf_eval_nf M k 5 (Fin.cons r_i env) s_i`) and `x1` realizes
the endpoint self-fiber + ray. Equivalently (driver #7): **`∃ x1>t, nf_eval_nf M (k+1) 4
[x1,w,x,t] σ` in this `M`.** This is an arity-4 relational realization existence claim.

### The gap and why no hypothesis closes it

| Hypothesis | Arity / model content | Can it produce the arity-4 future realizer? |
|------------|-----------------------|---------------------------------------------|
| `hepR` (`igEpR@t`) | arity-1 model witnesses (1-type future points) | **No** — F1 fold loss; 1-type ≠ arity-4 fiber; many fiber-consistent `σ'` share `χ_σ` |
| `hAmb` | **none** (syntactic EF-closure, no `M`) | **No** (`kvE_ambientDeepAnchor_iff`, `:131`) |
| `hcons` | **none** (model-independent; internal `∃ M`) | **No** (`kvE_fiberConsistent` docstring, `:73`) |
| `hmark`, `hfut` | **none** (Bool predicates on `qnf`/`σ`) | **No** |
| `P` | depth-`k` realization **tester** (biconditional) | **No** — reads back depth-`k`, creates nothing at depth `k+1` |
| depth-`(k+1)` saturation of `M` | **would** close it | **NOT a hypothesis of M1; = recursion's own goal (circular)** |

The upgrade `arity-1 → arity-4` is a genuine *level* gap. The only object type that closes it —
a depth-`(k+1)` model-saturation/existence fact for the specific `M` future of `t` — is absent and
would be circular (it is a strictly stronger sibling of the very `ExistProviders (k+1)` the
recursion is constructing). Hence **no term of the goal type exists from these hypotheses**: M1 is
not provable, and (given a fiber-consistent fold-collision `M`) not even always true.

### Why `hcons` does NOT rescue M1 (the task-363 guard's true reach)

`hcons` was introduced (task 363) to exclude the **landed** doppelgänger `qnfG1`
(`ExteriorPinnedProbeM1K.lean:628-669`), which is projection-invisible (`igFoldBit qnfG1 =
igFoldBit m1qnf`) yet unrealized — and indeed `kvE_probe363_qnfG1_antecedent_fails` certifies
`kvE_fiberConsistent m1sigma = false`. But `kvE_fiberConsistent σ` constrains only `σ`'s **internal
fiber coherence** (marked inner forms have realizable mates among `σ`'s own fibers); it says nothing
about **distinctness of `σ`'s fold projection from other fiber-consistent types**. Two distinct
fiber-consistent arity-4 types can share `(zone, nfk_projFresh)` — the fold sees only that pair.
So a fiber-consistent fold-collision survives `hcons`, and the model-level ambiguity ("does `M`
realize `σ`, or a fold-mate `σ''`?") persists. `hcons` narrows the *syntactic ambient population*
we must supply for; it does not supply the *specific-`M` witness*.

### Rabinovich fidelity (Tier 1)

`rabinovich_2014` Cor 5.4(1)⇐ (chunk_0015 L23-29) fires the future witness **directly off
`βn+1 Until αn+1`** and carries the **full ordered bracket sequence** `[α0,β1,…,βn,αn]` — it never
folds the interior population into `(zone × 1-type)` bits. The Lean encoding's `igFoldBit` fold is
exactly the deviation: it discards the arity-4 fiber, so the paper's `Until`-firing (faithful in the
source) is insufficient in the folded encoding to rebuild `σ`. This points the fix at **de-folding /
carrying the full fiber (M2)**, not at inventing a firing oracle over the fold (M1).

---

## M2 — the fallback the planner should scope (do NOT implement)

**M2 = a de-folded interior carrier** that retains full arity-4 fiber content at the endpoints, so
the render's fiber layer is directly readable and the `σ`-realizer is extracted from the endpoint
eval with **no** arity-1 → arity-4 upgrade (the paper-faithful "carry the whole bracket sequence"
shape).

### M2 scope (explicit, for a scope-and-document plan)

1. **Carrier redesign locus** — `InteriorGateGeneralK.lean`: `igEpL/igEpR/igPtW` (`:209/:219/:243`)
   and `igFoldBit` (`:318`) must be replaced (or paralleled) by variants keyed on the full arity-4
   fiber `σ : NF (k+1) 4` rather than the projected `(zone, χ : NF (k+1) 1)` pair. `igBody`
   (`:290`) and `igMkDisjunct` (`:276`) consume them.
2. **Frozen-boundary collision (the hard part)** — the fold is baked into the **frozen private
   carrier** `bracketEndChar_kv`'s `k+1` branch (`CarrierKv.lean:246-249`), and
   `bracketEndChar_kv_succ_eq` (`InteriorGateGeneralK.lean:339-351`) is a pure `rfl` against it.
   A de-folded carrier therefore either (a) modifies the frozen `bracketEndChar_kv` — breaking the
   byte-for-byte defeq the entire downstream is locked to — or (b) builds a **parallel non-folded
   carrier** and re-proves the whole correctness chain (`igBody_holds_iff` `:359`, `step_sound`
   `:1043`, its fiber delegation `:1150-1165`, `igFoldBit_realize_iff` `:563` analog).
3. **Render bridge** — `igFoldBit_realize_iff` (`:563`, the render-gated bridge M1 routed around)
   is replaced by a de-folded `endpoint → arity-4 realizer` extraction that needs no render.
4. **Assembly + binders** — `ExteriorGateAssembleK.lean:337-338` (render production) and the
   `KampPrior.lean:955-1000` row-5/6 binders (`hreal`/`hexcl`) re-typed to the de-folded endpoint
   evals; the drivers `kampPrior_{fut,past}Realizer_of_pos` (`:1662/:1721`) re-wired.
5. **Downstream re-verification** — `InteriorHrealSupplyK.lean` (`kampPrior_hreal_supply` body,
   currently the `:116` strategic sorry), `ExteriorDeepExclSupplyK.lean:105/133` (rows 12-13
   general-`m` arms, currently sorried and render-dependent), and every leaf citing the render.

### M2 cost signal

This is a **carrier-redesign refactor crossing the frozen-carrier boundary** — the audit's
explicit "larger refactor of `InteriorGateGeneralK.lean` … only if M1 is refuted." It is
substantially larger than a leaf addition and touches files the whole Phase 1-4 tree is byte-locked
against. The scope-and-document plan should size it as **multi-phase** and flag the frozen-boundary
decision (modify-frozen vs parallel-carrier) as its Phase 0 architectural gate.

### Optional Phase-0 certainty gate (recommended, cheap)

Before committing to the full M2 refactor, a **bounded probe** converts this report's HIGH-confidence
verdict to machine-certain: extend `ExteriorPinnedProbeM1K.lean` with a **fiber-consistent**
fold-collision witness — a `σ` with `kvE_fiberConsistent σ = true` and a model `M` where the
`igEpR@t` fold fires but `nf_eval_nf M (k+1) 4 [x1,w,x,t] σ` fails at every `x1 > t` — mirroring the
existing `kvE_probeM1_interiorGuard_identical` / `m1_no_marked_mate` cast but passing `hcons`. If
such a witness lands sorry-free, M1 is *refuted* (not merely unprovable-from-these-hypotheses),
locking the M2 decision. This probe is one leaf, no frozen-boundary risk.

---

## Adversarial Self-Verification (H4)

I stress-tested the NOT-PROVABLE verdict by trying to construct M1 or find a hidden bridge.

| Claim | Source / Counterexample tried | Verification Method | Confidence |
|-------|-------------------------------|---------------------|------------|
| `kvE_futPos P σ` at `t` entails a full arity-4 `σ`-realizer in this `M` (conclusion is not a weak 1-type claim) | Tried: maybe the driver adds hypotheses that weaken `kvE_futPos`. It does not — `hreal`/`hsat` are depth-`k` (from `P`); `hpos` alone carries the arity-4 content | `lean_hover_info`-confirmed type signature (`kampPrior_futRealizer_of_pos`, KampPrior.lean:1662-1681) | High |
| `hepR` supplies only arity-1 model witnesses | Read `igEpR` FutT conjunct: `Until(charK χ, ⊤)` over `χ : NF (k+1) 1` | `lean_local_search` + source read (InteriorGateGeneralK.lean:219-225); `igFoldBit` ∃-projection to `nfk_projFresh` (`:318`) | High |
| `hAmb`, `hcons`, `hfut`, `hmark` carry zero specific-`M` content | Tried: maybe `kvE_fiberConsistent`'s co-realization pins `M`. It is an internal `∃ M` (any model), explicitly "no model parameter" | Source read + docstring (ExteriorFiberConsistencyK.lean:73-96; ExteriorAmbientDeepAnchorK.lean:131) | High |
| `P` cannot generate depth-`(k+1)` witnesses | Read `ExistProviders.correct` — biconditional depth-`k` tester at fixed anchor | Source read (PriorInterface.lean:41-45) | High |
| depth-`(k+1)` saturation is unavailable / circular | It is the recursion's own conclusion (`ExistProviders (k+1)` via `kampPrior_existProviders_of_ih` from depth `k`) | Traced against audit §Postmortem + handoff line 27; M1 signature carries only `P : … k` | High |
| **The landed probe directly refutes M1** | **REFUTED (my own claim rejected)** — `kvE_probe363_qnfG1_antecedent_fails` gives the probe fake `kvE_fiberConsistent = false`, so `hcons` excludes it | `lean_verify` (probe sorry-free) + source read (ExteriorFiberConsistencyProbeK.lean:305) | High |
| A *fiber-consistent* fold-collision witness exists (would make refutation machine-certain) | **Could not verify** — no such witness is landed; constructing one is the recommended Phase-0 probe | Not yet performed — deferred to M2 Phase-0 gate | Medium |
| Rabinovich fires from `Until` with no fold (the encoding's fold is the divergence) | Re-read chunk_0015 L23-29, chunk_0014 | Direct literature quote | High |

**Contradiction Log.** One contradiction was found and resolved: the task framing and the crux-A
handoff (line 57) present the landed probe as evidence a naive supply "is refuted," which could read
as a direct M1 refutation. Applying the precedence *landed-source > handoff prose*: the probe's fake
has `hcons = false` (`kvE_probe363_qnfG1_antecedent_fails`), so it does **not** refute M1-under-`hcons`.
Resolution: the verdict is re-grounded on the **model-independence classification** of M1's
hypotheses (rows above), which is airtight, rather than on the probe. The probe remains valid
*supporting* evidence that fold-firing alone is insufficient at the pre-`hcons` level.

**Residual (honest).** This is a non-provability argument about a fixed hypothesis set — HIGH
confidence, not certainty. The single unresolved check is whether a **fiber-consistent** fold
collision can be exhibited in a concrete model (Medium). It does not change the verdict direction:
M1 is not provable *from these hypotheses* regardless, because the bridging object (depth-`(k+1)`
model saturation of this `M`) is absent and circular. The Phase-0 probe (§M2) upgrades HIGH → certain
and is cheap. **Recommendations modified after verification:** dropped the initial framing "the
landed probe proves M1 false"; replaced with the model-independence argument + the Phase-0
fiber-consistent-witness recommendation.

**Anti-analysis (H2) note.** No `sorry`-deferral, axiom introduction, or placeholder is recommended.
The current `kampPrior_hreal_supply:116` strategic sorry is NOT endorsed as a resting state; M2 (or
its Phase-0 refutation probe) is the sorry-free path. If the planner cannot scope M2 sorry-free, the
correct terminus is `[BLOCKED]` for user review, not a retained sorry.

---

## Files inspected (machine grounding)

- `InteriorGateGeneralK.lean` — `:209/:219/:243` (igEpL/igEpR/igPtW), `:318-332` (igFoldBit ∃-def),
  `:339-351` (`bracketEndChar_kv_succ_eq` rfl to frozen carrier), `:290` (igBody)
- `ExteriorNegationK.lean` — `:429-435` (kvE_futPos), `:409-423` (kvE_futEnd/futChain), `:456-465`
  (kvE_futItemShift_correct)
- `ExteriorPinnedConverseK.lean` — `:252-263` (kvE_futPos_of_realizer, realizer-gated)
- `KampPrior.lean` — `:1662-1716` (kampPrior_futRealizer_of_pos driver), `:955-1000` (row-5/6 binders)
- `ExteriorAmbientDeepAnchorK.lean` — `:109-165` (kvE_ambientDeepAnchor + `_iff`, syntactic)
- `ExteriorFiberConsistencyK.lean` — `:74-96` (kvE_fiberConsistent/ElemConsistent, model-independent)
- `PriorInterface.lean` — `:38-45` (ExistProviders.correct, depth-`k` tester)
- `InteriorHrealSupplyK.lean` — `:40-116` (kampPrior_hreal_supply statement + strategic sorry body)
- `ExteriorPinnedProbeM1K.lean` — `:600-669` (doppelgänger probe; `lean_verify` sorry-free),
  `:842` (kvE_probeM1_interiorGuard_identical)
- `ExteriorFiberConsistencyProbeK.lean` — `:305` (kvE_probe363_qnfG1_antecedent_fails)
- `CarrierKv.lean` — `:82-84` (nfk_projFresh), `:246-249` (frozen fold in bracketEndChar_kv)
- Source-of-truth: task-358 audit `reports/11`, crux-A handoff `phase-5-crux-a-handoff-20260714.md`
- Literature: `rabinovich_2014` chunk_0014 (Lemma 5.3), chunk_0015 (Cor 5.4(1)⇐)
