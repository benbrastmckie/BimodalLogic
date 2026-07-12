# Task 352 — Teammate D Findings (Horizons: architecture, decomposition, roadmap fit)

**Task**: 352 — Build depth-`k` navigated exterior negation clause layer via `ExistProviders`
**Role**: Team research, angle D — recursion interaction, module architecture, decomposition, roadmap alignment
**Mode**: READ-ONLY. No `.lean` edits. All claims carry file:line evidence.
**Grounding**: plan v7 (all phases), PriorInterface.lean, ExteriorBracketK.lean, reports 10 & 11,
ROADMAP.md, state.json task descriptions (349/352/309). Import DAG confirmed via `grep`.

---

## Key Findings

1. **The clause layer is STANDALONE, parameterized by `P : ExistProviders sig atomMap k` — NOT
   mutual with the `endInterval` carrier.** The apparent mutuality flagged in the Phase-2 blocker
   (report 11 root cause 3: "the rung-`(k+1)` bracket recursively consumes rung-`k` formulas") is
   resolved by a dependency-inversion interface (`ExistProviders`, PriorInterface.lean:38-46) that
   **already exists and is already load-bearing** across the frozen provider layer
   (`ExteriorBracket.lean`, `OuterGate.lean`, `SharedWitness.lean`, `RefutationF2.lean` all
   reference it). 352 introduces **no new mutual recursion**.

2. **The genuine rung-`k` → rung-`(k+1)` fixpoint already lives in KampPrior's `Nat.rec`**, not in
   349 or 352. PriorInterface.lean:25 states it verbatim: *"The ∀k quantifier is NOT restated here:
   it lives in KampPrior's `Nat.rec`"* — i.e. `nf_nvar_exist_all_depths` (KampPrior.lean:212) is the
   `Nat.rec` that produces the concrete `ExistProviders` instance at each depth. Both task 352's
   clause layer and task 349's carrier sit **below** that recursion as provider-parametric leaf
   constructions. Neither needs to open a `mutual … end` block.

3. **The import DAG admits the new module cleanly (no cycle).** Confirmed positions:
   `Base → CarrierK1V → CarrierKv → PriorInterface` (defines `ExistProviders`); the frozen clause
   layer `Kamp/ExteriorNegation.lean` / `ExteriorNegationPast.lean` is LOW in the DAG (imports only
   `SharedWitness` + `ExteriorZoneTriage`; **0** `ExistProviders` references — it is depth-0
   hardwired to `σ : NormalForm sig 1 4`); `ExteriorBracketK.lean` (Phase-2 determinacy core,
   landed) imports `ExteriorBracket + NfEFold`. A new `ExteriorNegationK.lean` importing
   `PriorInterface` (for `ExistProviders`) + the frozen clause layer (byte-identical template) +
   `ExteriorBracketK` (determinacy core) closes no cycle — all three are strictly below it.

4. **Plan v7 was already architected for provider parameterization.** Phase 3's `endIntervalStep`
   signature already carries `(P : ExistProviders sig atomMap k)` (plan v7:515-518); Phase 5 is
   explicitly "provider-family parametric" (plan v7:603-612). The **only** gap was that the Phase-2
   *brackets* tried to build without the depth-`k` clause layer that `P.existF` feeds. 352 supplies
   exactly that. So 352 inserts one upstream dependency and re-scopes Phase 2's statement to add a
   `P` parameter — it does **not** force a deep restructure of 349's plan.

5. **352 is on the critical path to `completeness_discrete`.** The chain to the last live sorry is
   `352 → 349 Phase 2 re-dispatch → 349 endInterval_correct → 309 Phase 14/19 (retire
   KampPrior:361) → KampPrior:353/:354 n≥2 arm → completeness_discrete`. Per the ROADMAP Rabinovich
   coverage table, the depth-`k≥2` Cor 5.4 chain converter is *the sole open mathematical gap* in
   the entire formalization; 352 is its current frontier blocker.

---

## Mutual vs Standalone (with Lean structuring consequence)

### Verdict: STANDALONE, parameterized by `P : ExistProviders sig atomMap k`. Mutual is neither required nor desirable.

**Why the mutuality is only apparent.** The faithful Rabinovich Def-7.5 rung-`(k+1)` bracket
consumes rung-`k` *formulas* (a closed-`Formula` characterizing each depth-`k` sub). The naive read
is: "rung-`(k+1)` needs rung-`k`, so define them together (mutual/well-founded recursion)." But the
rung-`k` formula source is precisely what `ExistProviders sig atomMap k` abstracts:

```lean
-- PriorInterface.lean:38-46
structure ExistProviders (sig) (atomMap) (k : Nat) where
  existF  : (n : Nat) → NormalForm sig k (n + 1) → Formula
  correct : ∀ n sub M h_UZ h_SZ t,
      temporal_truth M atomMap t (existF n sub) ↔
        ∃ env, nf_eval_nf M k (n + 1) (insertEnv env t) sub
```

`P.existF` converts a depth-`k` sub into a closed Formula whose truth is the existential over that
sub — this **is** the "rung-`k` recursive formula source" the bracket needs (report 10 adversarial
§2). Passing `P` as a *parameter* breaks the definitional cycle by **dependency inversion**: the
depth-`k` clause layer depends on the abstraction `ExistProviders`, not on any concrete carrier. The
concrete instance is supplied later (by KampPrior's `Nat.rec`, downstream), closing the loop at the
**value level**, never at the definitional level.

Crucially, `ExistProviders` is at depth `k` (not `k+1`): `ExistProviders sig atomMap k` handles
`NormalForm sig k (n+1)` subs — exactly matching task 352's prescribed signature
(`P : ExistProviders sig atomMap k`, feeding the rung-`(k+1)` layer). This is the correct rung
offset.

### Lean structuring consequence — STANDALONE (chosen; correct)

- New leaf module(s) `ExteriorNegationK.lean` / `ExteriorNegationPastK.lean` under
  `NfMultiAnchorBridge/`, each taking `P : ExistProviders sig atomMap k` and building depth-`k`
  clause facts. Imports: `PriorInterface` + frozen clause layer (template) + `ExteriorBracketK`
  (determinacy core). **No import cycle** (Key Finding 3).
- **No `mutual … end` block, no well-founded recursion spanning two objects.** `endInterval`'s
  termination stays the existing value-level `Nat.rec` on `k` (v6 skeleton, CarrierK1V:2159, already
  green).
- 352 is **independently buildable and verifiable** — it needs only the `ExistProviders` interface,
  not the concrete `endInterval` carrier. This is the decisive decomposition win: 352 can land,
  build GREEN, and be axiom-audited *before* 349 Phase 2 re-dispatch even begins.
- Preserves every frozen-file boundary and the additive-new-module discipline (`git diff` on the 7
  providers stays EMPTY).

### Lean structuring consequence — MUTUAL (rejected)

- Would require a `mutual` block (or shared-measure well-founded recursion) spanning the clause
  layer AND `endIntervalStep`/`endInterval`. **Lean `mutual` blocks cannot span files** — this would
  collapse `ExteriorNegationK` + `CarrierK1V` (and the ~2000-line clause rebuild) into one module,
  destroying the frozen-file boundaries and the 352/349 task separation.
- Correctness proofs would also become mutual theorems; the green value-level `Nat.rec` skeleton
  would be discarded for a well-founded recursion carrying a heavier termination obligation (plan v7
  Risk table flags exactly this for Phase 5).
- Reopens strike-2 signature tension (plan v7:229-231): without the `ExistProviders` abstraction
  there is no clean channel for the rung-`k` formula source, which is what forced v6 Phase 3 to
  `[BLOCKED]`.

**Bottom line for 352's implementers**: build the clause layer as a pure function of an abstract
`P : ExistProviders sig atomMap k`. Never reference `endInterval`/`endIntervalStep`/`BracketEndCharCarrierV`
inside 352. The user's adjudicated resolution (a) (report 11:40-46) is architecturally sound and is
the only option that keeps the DAG acyclic, the frozen files untouched, and 352 independently
shippable.

---

## Impact on Plan v7 Phase DAG

352 does **not** force a plan-v7 rewrite. It inserts one upstream dependency and re-scopes Phase 2's
*statement* (add the `P` parameter). Phases 3-6 already thread `P` and need no change.

### Corrected DAG (349 with 352 spliced in)

```
Phase 1  [COMPLETED]  general-k fold bridge (NfEFold) + ExteriorBracketK determinacy core
   │        (nf_eval_nfk_iff_efold; nfk_truncD, kvE_subBit_iff, kvE_futAnyBit — all landed green)
   ▼
════ TASK 352 (external prerequisite; 349 now depends on it) ════════════════════
   depth-k clause layer parameterized by P : ExistProviders sig atomMap k
   consumes ExteriorBracketK core UNCHANGED; frozen clause layer as byte-identical template
   EXPOSES: bracket-buildable depth-k clause facts (habove/hbelow at NormalForm sig k 1)
════════════════════════════════════════════════════════════════════════════════
   ▼
Phase 2  [re-dispatch]  kvE_extBracketPast/Fut + _sound/_complete
   │        NOW takes P : ExistProviders as a bracket parameter; consumes 352's clause facts
   │        (statement re-scope: byte-identical k=2 shape + the P parameter — the ONLY plan edit)
   ▼
Phase 3  endIntervalStep general-k body + EndIntervalCorrectPrior
   │        signature ALREADY has (P : ExistProviders sig atomMap k) — no change (plan v7:515)
   ▼
Phase 4  step soundness + completeness (k=2 gate at depth k)          [unchanged]
   ▼
Phase 5  recursion close — Nat.rec + endInterval_correct              [already provider-parametric]
   ▼
Phase 6  axiom audit + whole-tree build                               [unchanged]
```

### What actually changes in plan v7

- **Phase 2**: statement re-scoped to `kvE_extBracketPast (P) …` etc. The landed determinacy core
  (`ExteriorBracketK.lean`) is consumed verbatim; the four bracket lemmas now discharge against
  352's clause facts instead of trying to reuse the depth-0-hardwired frozen layer.
- **Dependency table**: add "Task 352" as the blocker of Phase 2 (Wave 2 becomes: 352 → Phase 2).
- **No other phase changes.** Phases 3/4/5 already anticipated `P`; the plan's own Phase-2 BLOCKER
  block (v7:448-451) lists resolution (a) as "take `P : ExistProviders` as a bracket parameter" —
  the plan foresaw this exact splice.

**Recommendation**: when 352 lands, drive 349 via `/implement 349` (Phase 2 re-dispatch). A full
`/revise 349` is only warranted if 352's exposed interface differs in shape from the plan's
`habove : nf_eval_nf M k 1` prescription — restate Phase 2's task list then, at the implementer's
discretion (matches report 11:69-71).

---

## Proposed 352 Decomposition (phases + line estimates + deps)

**One task, five phases with a parallel wave.** NOT sub-tasks: the Past/Future sides share a
skeleton (Phase 1) and a common interface exposition (Phase 4); splitting into separate tasks would
fragment those shared pieces. The frozen layer being rebuilt is
`kvE2_futPos`/`kvE2_extNegFut` + `_sound`/`_complete` (ExteriorNegation.lean:1124/1136/1243/1484)
and its Past mirrors (ExteriorNegationPast.lean) — a clean Future/Past symmetry.

| Phase | Deliverable | Est. lines | Depends on |
|-------|-------------|-----------:|------------|
| **1. Shared depth-`k` clause skeleton + `P` plumbing** | The depth-`k` analog of `nf0_assemble`'s coordinatization, made lossless at depth `k` via the `P.existF` channel (removes the depth-0 hardwiring, blocker root cause 1). Establishes the clause-fact interface both sides consume. Consumes `ExteriorBracketK` core (`nfk_truncD`, `kvE_subBit_iff`, `kvE_futAnyBit`) UNCHANGED. | ~300-450 | — |
| **2. Future side clause layer** (`ExteriorNegationK.lean`) | `kvE_futPos_k` / `kvE_extNegFut_k` + `_sound` + `_complete` over `P`. Mirror ExteriorNegation.lean at depth `k`. Likely splits **2a `_sound` / 2b `_complete`** (each a chain-step-heavy Rabinovich proof, like 349 Phase 4). | ~500-700 | 1 |
| **3. Past side clause layer** (`ExteriorNegationPastK.lean`) | Past mirrors of Phase 2. Structurally symmetric. **Parallelizable with Phase 2** under an H7 territory contract (disjoint files: `ExteriorNegationK.lean` vs `ExteriorNegationPastK.lean`). Likely splits **3a/3b**. | ~500-700 | 1 |
| **4. Interface exposition (bracket-buildable facts)** | Package per-side clause facts into the exact shape 349 Phase 2 consumes: `habove`/`hbelow` at `NormalForm sig k 1` / `nf_eval_nf M k 1`. This is 352's definition-of-done deliverable. | ~200-350 | 2, 3 |
| **5. Axiom audit + whole-tree build** | `lean_verify` axiom-clean on every headline decl; frozen-file diffs EMPTY; FORBIDDEN grep clean; confirm the interface is citable by 349 Phase 2. | ~0-50 | 4 |

**Total: ~1500-2250 lines**, matching the ~2000+ estimate (report 11:37, 352 description).

### Dependency graph (diamond with one parallel wave)

```
Wave 1:  Phase 1  (skeleton + P plumbing)
             │
        ┌────┴────┐
Wave 2: Phase 2   Phase 3      ← PARALLEL (H7 territory: two disjoint side-modules)
        (Future)  (Past)
        └────┬────┘
Wave 3:  Phase 4  (interface exposition)
             │
Wave 4:  Phase 5  (audit)
```

**Dispatch count**: plan for ~7-9 agent runs (Phases 2 and 3 each likely 2a/2b, mirroring the k=2
layer's pos/extNeg/sound/complete structure and 349's per-direction phase-splitting under H8 sizing).

**Sizing note (H8)**: Phase 1 and Phase 4 are within a single-run budget. Phases 2/3 at 500-700 lines
exceed the ~100-500 target and should be pre-declared as splitting by proof direction — declare this
in the plan so an overrun is a planned sub-dispatch, not a churn signal.

---

## Roadmap Alignment

**352 is the current frontier of the `kamp_theorem_formalization` endgame.** The ROADMAP's Rabinovich
coverage table (ROADMAP.md:42-53) marks every paper artifact as landed sorry-free **except** the
depth-`k≥2` instance of the Cor 5.4 `F_i`-chain converter — "the sole open gap … exactly where all
current work is concentrated. By this proxy the formalization is in its last chapter." That gap is
`nf_nvar_exist_all_depths` at KampPrior.lean:351/:361 (n=1 arm) and :353/:354 (n≥2 arm) — the only
two live sorries blocking `completeness_discrete` (ROADMAP.md:30).

### The dependency chain to the last sorry

```
352 (depth-k clause layer, ExistProviders channel)          ← THIS TASK
  → 349 Phase 2 re-dispatch (four bracket lemmas close)
    → 349 Phases 3-6 (endInterval / endInterval_correct, general-k)   [task 349, BLOCKED on 352]
      → 309 Phase 14/19 (consume endInterval_correct; retire KampPrior:361 n=1 sorry) [task 309, BLOCKED]
        → KampPrior:353/:354 (n≥2 arm: prove or restate for n≤1)
          → completeness_discrete sorry-free
```

352 unblocks 349, which unblocks 309's final arm, which is the last mile of the discrete-completeness
proof. Per ROADMAP.md:36 the whole tail is "~11-18 focused dispatches … a bounded endgame, not an
open research problem."

### Adjacent items 352 must coordinate with

- **Task 309 (`offdiag_two_anchor_fi_chain`, BLOCKED) — the tight interface contract.** 309's
  Phase-14 work (in KampPrior, NO-EDIT from 349/352) is what SUPPLIES the concrete
  `P : ExistProviders sig atomMap k` via `nf_nvar_exist_all_depths`'s `Nat.rec`. **352 must expose
  its interface consuming `P` in EXACTLY the `ExistProviders` shape at PriorInterface.lean:38-46** —
  the same shape 309's provider instance satisfies. If 352 invents a bespoke provider record instead
  of consuming the canonical `ExistProviders`, 309's instantiation won't fit and the chain breaks.
  This is the single most important cross-task constraint. 309's v9 open work (Phases 15-19: provider
  shim → hrealI/hrealB/hexcl discharge → kvE2Ext gate consumption → ∀k lift + :361 retirement) is the
  direct consumer.

- **Naming-drift flag (coordination risk).** Task 349's *description* promises the citable name
  `endChar_correct` ("downstream task 309 Phase 18/19 can cite endChar_correct by name"), but plan v7
  renamed the object to `endInterval` / `endInterval_correct` (plan v7:67-73). 309's plan/description
  may cite the stale `endChar_correct`. Flag this so 309's Phase-14/19 consumption points at
  `endInterval_correct` (or 349 exports a `endChar_correct` alias). Not 352's deliverable, but 352
  sits on the path and should surface it.

- **Task 350** (downstream FO→TL wrap, per plan v7:150) — not on 352's immediate path; the top-level
  ≤1-free `TemporalPred` extraction. No coordination needed now.

- **Frozen k=2 clause layer** (`Kamp/ExteriorNegation.lean` / `ExteriorNegationPast.lean`) — the
  byte-identical proof template. 352 references it read-only; its `git diff` must stay EMPTY.

### Broader arc served

352 advances the `kamp_theorem_formalization` topic directly: it is the depth-`k` generalization of
the Prop-4.2 uniform negation/exclusion channel (plan v7 H3 table, Rabinovich Prop 4.2, md:165) that
the k=2 layer already realizes. Landing it converts the last "pending (general `k`)" row of the
plan's Source-to-Implementation mapping (v7:163) into "transcribed," which is the load-bearing input
for the Cor 5.4 chain the whole discrete-completeness endgame turns on.

---

## Confidence

| Claim | Basis | Confidence |
|-------|-------|:----------:|
| Standalone (parameterized by `P`), not mutual | `ExistProviders` defined + already used as an inversion interface (PriorInterface.lean:38; referenced in ExteriorBracket/OuterGate/SharedWitness/RefutationF2); the ∀k fixpoint explicitly delegated to KampPrior's `Nat.rec` (PriorInterface.lean:25) | **High** |
| New `ExteriorNegationK` module admits no import cycle | DAG confirmed: frozen clause layer imports only SharedWitness+ExteriorZoneTriage (0 ExistProviders refs); PriorInterface/ExteriorBracketK are below a new leaf module | **High** |
| 352 does not force a deep plan-v7 restructure | Phase 3 signature already carries `P` (v7:515); Phase 5 already "provider-family parametric" (v7:603); only Phase 2's statement gains `P` | **High** |
| `ExistProviders` rung offset (`k`, feeding rung `k+1`) is correct | `existF : … NormalForm sig k (n+1) → Formula` (PriorInterface.lean:40); task 352 sig prescribes `P : ExistProviders sig atomMap k` | **High** |
| Proposed 5-phase / diamond decomposition with Future‖Past parallel wave | Frozen layer's Future/Past + pos/extNeg/sound/complete symmetry (ExteriorNegation.lean:1124/1136/1243/1484 + Past mirrors); H7/H8 sizing | **Medium-High** (line estimates are structural extrapolation from the k=2 layer's size, not a landed build) |
| 352 on the critical path to `completeness_discrete` | ROADMAP.md:30/36/42-53 (sole open gap = depth-`k≥2` Cor 5.4 converter); dependency chain 352→349→309→KampPrior:353 | **High** |
| 309 ⇄ 352 `ExistProviders`-shape contract is the key coordination risk | 309 description v9 (Phases 15-19, provider shim + ∀k lift); PriorInterface.lean:32-37 (provider = "what the outer recursion supplies at KampPrior:351") | **Medium-High** |

**Adversarial self-check.** The one place I did not machine-verify: I did not build a skeleton
`ExteriorNegationK` to confirm the depth-`k` clause facts are *constructible* over `P.existF` in
practice — that is 352's implementation work and is explicitly out of scope for read-only research.
My verdict rests on (i) the architecture being an application of the *already-proven* `ExistProviders`
inversion pattern (not a novel construct) and (ii) report 10's machine-confirmed determinacy GO
(`nf_eval_unique M k` uniform at full arity 4). The residual risk is construction/typechecking scale
(~2000 lines), which the decomposition front-loads into the Phase-1 skeleton gate — consistent with
the user's adjudicated resolution (a) and report 11's blocker isolation. No carrier-type question is
reopened; the mutual-vs-standalone question resolves decisively to standalone.
