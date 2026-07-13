# Task 358 — Realization Recursion `nf_nvar_exist_all_depths` (Rabinovich Cor 5.4 within-bracket realizer)

**Agent**: lean-research-agent | **Date**: 2026-07-12 | **Type**: lean4 research (research-only, no Lean edited)
**Scope**: identify (1) the exact statement of `nf_nvar_exist_all_depths` and what the :361/:364 arms must prove; (2) the Rabinovich Cor 5.4 within-bracket realizer construction and its faithful Lean transcription path; (3) how the produced `hσ` feeds `kvE_{fut,past}Bundle_of_realizer` to discharge the eleven carried obligations; (4) the honest difficulty assessment and escalation boundary.

**Verdict up front**: Task 358 is a genuine open-mathematics task with a *single* hard core: the **positive within-bracket realizer production** — from a satisfied `bracketEndChar_kvExt` clause, PRODUCE an exterior anchor `x1` together with a full arity-4 realizer `nf_eval_nf M (k+1) 4 [x1,w,x,t] σ`. Everything downstream of that realizer (the converter, the consumer, the seam certificates, the provider shim) is **already landed and sorry-free**. The negation-direction chain machinery (Cor 5.4 `O_n` / `F_i` destructor) is also already landed generically. The un-landed piece is the *dual* (positive/existence) direction of the same Cor 5.4 selection at depth `k ≥ 2`, plus the arity-`≥3` (`| n+2 =>`) footprint arm.

---

## 1. The exact statement and what the two arms must prove

### 1.1 `nf_nvar_exist_all_depths` (KampPrior.lean:212–364)

```lean
noncomputable def nf_nvar_exist_all_depths
    {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p) :
    (k : Nat) → (n : Nat) → (sub_nf : NormalForm sig k (n + 1)) →
      ∃ (A : Formula),
        ∀ (M : OrderedMonadicStructure sig)
          (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
          (t : M.carrier),
          temporal_truth M atomMap t A ↔
          ∃ env : Fin n → M.carrier, nf_eval_nf M k (n + 1) (insertEnv env t) sub_nf
```

Recursion is `Nat.rec` on `k` (depth), NOT on `n`. The arm split on `n` sits *inside* the `k+1`
body:
- `| 0 =>` (n=0): trivial — `char_k1` directly (KampPrior:335–346). **Closed.**
- `| 1 =>` (n=1): **the critical strategic sorry (:361).**
- `| n+2 =>` (n≥2): **the footprint sorry (:364).**

The `k=0` base (line 224) is fully closed via `nf_nvar_exist_depth0_tl_fn`. So both open arms
live only in the `k+1` body, i.e. `sub_nf : NormalForm sig (k+1) (n+1)`.

### 1.2 What the `| 1 =>` arm (:361) must prove — the CRITICAL path

Target (with `sub_nf : NormalForm sig (k+1) 2`):
```
∃ A, ∀ M h_UZ h_SZ t,
  temporal_truth M atomMap t A ↔ ∃ env : Fin 1, nf_eval_nf M (k+1) 2 (insertEnv env t) sub_nf
```

This is invoked with `n=1` at KampPrior:273 (inside `ih_exist_1`), so the arm must succeed for
**all `k`**. The already-landed *site lemmas* decompose the RHS sorry-free (KampPrior:646–924):

1. `kampPrior_site_env_bridge` (:650) — `∃ env : Fin 1` ⟷ `∃ x` on `Fin.cons x (fun _ => t)`.
2. `kampPrior_site_trichotomy` (:677) — splits into **past** (`x < t`) / **diagonal** (`x = t`) /
   **future** (`t < x`) via `nf_zone_exists_trichotomy_k1`.
3. `kampPrior_site_perQnf_seam` (:694, `Iff.rfl`) — depth-`(k+1)` eval unfolds to the atom layer
   plus, per `qnf : NormalForm sig k 3` (depth `k`, one less), the coupled inner existential
   `∃ w, nf_eval_nf M k 3 (zoneEnv3 w x t) qnf`.

The formula `A` is assembled as: diagonal characteristic ∨ (disjunction over `qnf` of the
`bracketEndChar_*` clause), i.e. exactly the object `endIntervalPrior atomMap h_surj charF Pfam k`
(EndIntervalConsumerK.lean:69) supplies. Its correctness is the depth-cased
`EndIntervalCorrectPrior` (:95) proved sorry-free by `endInterval_step_correct` (:171) —
**but obligation-carrying**: at arm `m+2` it *assumes* `hreal`/`hexcl`/`hbrPastReal`/`hbrPastSat`/
`hbrFutReal`/`hbrFutSat` (the interior realization/exclusion + the four task-356 exterior bracket
obligations). Retiring :361 = **instantiating this consumer and *discharging* those eleven
obligations** (seven interior via `kampPrior_site_rungK_gate_match` KampPrior:816; four exterior).
The provider `P`/`Pbr`/`charF` are supplied by the landed shim `kampPrior_existProviders_of_ih`
(:972) fed the recursion's own IH family (`fun n sub => nf_nvar_exist_all_depths … j n sub`,
structurally available for every `j ≤ k` — the F-A ∀k fact recorded at :944).

**Corrected arm-indexing (machine finding, KampPrior:627–644, binding).** The per-`qnf`
population at KampPrior match-arm `k` sits at **depth `k`, arity 3**. Consequently:
- arm `k=0` closes by the *unconditional* rung `bracketEndChar_kv_correct_zero_prior`
  (certificate `kampPrior_site_rung0_match`);
- arm `k=1` closes by the *unconditional* rung `bracketEndChar_kv_correct_one_prior` (`h0` only;
  certificate `kampPrior_site_rung1_match`) — the fragment predicate `kvE2_sepFragment` does not
  even type here, so **F-i coverage is vacuous at k=1**;
- arm `k=2` (and, uniformly, `kampPrior_site_rungK_gate_match` for all `k`) is where the
  interior+exterior obligations actually bite — this is the depth-`≥3` per-qnf obligation. This is
  the locus of the real content.

So the **critical mathematical content of :361 is exactly the discharge of the arm-`k≥2`
obligations** — i.e. producing the genuine realizer `hσ` at the reconstructed exterior anchor.

### 1.3 What the `| n+2 =>` arm (:364) must prove — the FOOTPRINT

`sub_nf : NormalForm sig (k+1) (n+1)` with `n ≥ 2` (arity `≥ 3`). Off the critical path (the
terminus only needs `n = 0, 1`), but it **shares the recursive constant**, so it taints
`#print axioms` until retired. Two viable routes:
- **(a) Uniform reduction (preferred).** The def's own design note (KampPrior:203–211, 229–236)
  gives the identity `Fin.cons x (insertEnv env t) = insertEnv (Fin.cons x env) t`: the `n`-var
  existential at depth `k+1` arity `n+1` reduces to an `(n+1)`-var existential at depth `k`
  arity `n+2`, available from the IH at depth `k`. A uniform disjunction-over-NF construction that
  does NOT special-case `n` would let :361 and :364 share one implementation. This is the honest
  target for a clean footprint.
- **(b) Multi-anchor generalization.** If the k=1 site machinery cannot be lifted to arity `≥3`
  cheaply, :364 needs the genuine multi-anchor (`x1 < … < xn`) increasing-sequence realizer —
  Rabinovich's full Lemma 5.1 rather than the two Cor-5.4 endpoint instances. This is strictly
  harder and is a candidate escalation boundary (see §4).

**Recommendation**: the planner should first attempt (a) — fold `| 1 =>` and `| n+2 =>` into one
arity-generic construction keyed off the same `endIntervalPrior`/provider machinery — and only
fall to (b) if the arity lift is blocked. The task-357 carrier layer already threads arity via the
`NormalForm sig … 5`/`… 4` fiber shapes, which is encouraging for (a).

---

## 2. Rabinovich Cor 5.4 within-bracket realizer — construction and Lean transcription

### 2.1 The mathematics (Literature Proof Structure)

**Source**: Rabinovich, *A Proof of Kamp's Theorem* (2014), §5 "Proof of Proposition …",
`~/Projects/Literature/sources/rabinovich_2014/` chunks 0013–0016, 0021, 0023.
**Strategy**: reduce "no witness sequence inside a bracket" to a single `inf`/`sup`-selected point
(Dedekind completeness), definable by a bounded `∨→∃∀` (equivalently TL(Until,Since)) formula.

#### Step map

1. **Lemma 5.3 (chunk_0014)** — `¬∃ x1…xn (z0 < x1 < … < xn < z1) ∧ ⋀ Pi(xi)` is equivalent
   over Dedekind-complete chains to a `∨→∃∀` formula `On(P1,…,Pn,z0,z1)`. Proof by induction on
   `n`; inductive step selects **`r0 = inf{z ∈ (z0,z1) | P1(z)}`** (exists by Dedekind
   completeness) and recurses `On(P2,…,Pn, r0, z1)`.
2. **The `INF` definability (5.3, chunk_0016)** — `r0` is the *unique* `z` satisfying
   `INF^{¬β1}(z0,z,z1) := z0 < z < z1 ∧ (∀y)_{z0<y<z} β1(y) ∧ (¬β1(z) ∨ K⁺(¬β1)(z))`. This is the
   bounded within-bracket witness-selection formula — the mathematical heart of the realizer.
3. **Corollary 5.4 (chunk_0013/0015)** — two dual statements:
   - 5.4(1): `¬(∃z)_{z0<z<z1}[α0,β1,α1,…,αn](z0,z)` ≡ `∨→∃∀` — proved by defining
     compound predicates `Fi(xi)` (the `F`-chain) so that "there is `z` with the bracket on
     `(z0,z)`" iff `F0(z0)` and there is an increasing `x1 < … < xn` in `(z0,z1)` with `Fi(xi)`;
     then apply Lemma 5.3. Uses **Until**, holds for `TL(Until, K⁻)`.
   - 5.4(2): the mirror (future→past) — uses **Since**, holds for `TL(Since, K⁺)`.
4. **`Fi` chain (chunk_0015 lines 9–41)** — `Fi(x) = αi ∧ (β_{i+1} Until F_{i+1})`, base
   `Fn = αn ∧ (β_{n+1} Until ⊤)`. This *absorbs* each bracket segment into an Until, collapsing
   the multi-point existence into Lemma 5.3's single-`inf` selection.

#### Dependencies
- Cor 5.4 depends on Lemma 5.3 (both parts) and on the `INF`/`Fi` definability.
- Lemma 5.1 (the full negation) depends on Cor 5.4(1)/(2) for its Case 2/Case 3 (chunk_0016).
- **Dedekind completeness is load-bearing** at exactly one place: the existence of `r0` (the
  `inf`/`sup`). In the Lean model this is the `OrderedMonadicStructure` completeness /
  `HasAttainedINF`-style property (referenced EANegation.lean:532).

### 2.2 What is ALREADY landed (do not re-derive)

| Rabinovich object | Lean landing | File:line | Status |
|---|---|---|---|
| `Fi` chain (k=1 instance) | `BracketFormula.fChainFrom` / `fChainPred` | EANegation.lean:552 / :567 | **CLOSED** |
| `Fi` base semantics | `fChainFrom_base` | EANegation.lean:580 | **CLOSED** |
| Cor 5.4 chain destructor (generic, ∀ depth) | `kvE_futChainDestructG` (+ past dual) | ExteriorNegationK.lean:293 | **CLOSED (sorry-free)** |
| depth-`k` future clause family `O_n`/`Fi` | `kvE_futChainG`, `kvE_futGapZone`, … | ExteriorNegationK.lean:333+ | **CLOSED** |
| within-bracket `sup` selection (k=2 sub) | `kvE_subChain2_eq_fChainPred` | SubBracket2.lean:102 | **CLOSED** |

The generic destructor `kvE_futChainDestructG` (ExteriorNegationK.lean:293) is precisely the
Cor 5.4 mechanism: given a true `D`-guarded chain at `s`, it yields **`x1 > s` with `endF(x1)`, a
`D`-uniform gap `(s,x1)`, and one item-occurrence per chain element**. That is the *negation*
(`¬∃z` ↔ `∨→∃∀`) direction — the "no interior witness ⇒ chain reconstruction" reading.

### 2.3 What is OPEN — the positive realizer production

The un-landed piece is the **dual/positive** use of the same selection: from a *satisfied*
`bracketEndChar_kvExt` clause (the `.holds` side firing at a candidate anchor produced by the
chain destructor), build the **genuine arity-4 realizer**
`hσ : nf_eval_nf M (k+1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ`.

Concretely the recursion must, at match-arm `k ≥ 2`:
1. Run the chain destructor to obtain the exterior anchor `x1` (past: `x1 < x`; future: `t < x1`)
   — this is `kvE_{fut,past}ChainDestructG`, already landed.
2. At `x1`, assemble the **atom layer** (`nf_eval_nf M 0 4 [x1,w,x,t] σ.1`) and the **per-fiber
   biconditional** `(∃ y, nf_eval_nf M k 5 [y,x1,w,x,t] s) ↔ σ.2 s = true` for every fiber
   `s : NormalForm sig k 5` with `nfk_dropFresh s = σ.1`, then fold via `nf_eval_nfk_iff_efold`
   into `hσ`. (This is literally the body of `kvE_extNegFut_complete`, ExteriorConverterK.lean:158–188,
   which currently *carries* `hreal`/`hsat` as hypotheses.)
3. The fiber content at step 2 is where the **`inf`/`sup` within-bracket selection recurses one
   depth down** (`k → k` fiber, arity 5): each positive fiber bit `σ.2 s = true` must be witnessed
   by an actual `y`, which is again a within-bracket selection in the fiber interval. **This is the
   genuinely open recursion** — the depth induction that produces witnesses at every fiber level.

**Faithful transcription path (recommended):**
- Reuse `kvE_{fut,past}ChainDestructG` for the anchor (do not rebuild — Cor 5.4 negation side).
- The positive/existence side is the **converse** the codebase flags as still open
  (EANegation.lean:530–536: "if `¬∃z bracket`, then no F-chain witnesses … would reconstruct a
  bracket"). Land the missing converse as a `HasAttainedINF`-driven lemma: the `inf` point `r0`
  from `INF^{¬β1}` (chunk_0016) exists by the model's Dedekind completeness, and *at* `r0` the
  fiber realizer is assembled. Mirror the k=1 closed instance (`fChainFrom`/`partialBracketExist`,
  EANegation.lean:571) upward to arity-5 fibers.
- Prove `hreal`/`hbr*Real` by feeding the produced `hσ` through the **already-landed converters**
  (§3). Prove `hexcl`/`hbr*Sat` by the exclusion/backward reading of the same fold
  (`nf_eval_nfk_iff_efold` off-fiber branch — already used in the converters' `hoff` step).

---

## 3. How `hσ` feeds `kvE_{fut,past}Bundle_of_realizer` to discharge the obligations

The two converters are **pure readers** — they take the realizer as INPUT and emit the exterior
bracket conjuncts. They are landed sorry-free; the missing piece is only their *argument* `hσ`.

```lean
theorem kvE_futBundle_of_realizer (M) (σ : NormalForm sig (k+1) 4) (x1 w x t)
    (hσ : nf_eval_nf M (k+1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    (∀ s, σ.2 s = true → ∃ v, nf_eval_nf M k 5 (Fin.cons v (Fin.cons x1 (Fin.cons w …))) s) ∧
    (∀ s, nfk_dropFresh s = σ.1 → (∃ v, …) → σ.2 s = true)
```
(ExteriorConverterK.lean:208; past dual ExteriorConverterPastK.lean:177.) Proof body = one
`nf_eval_nfk_iff_efold` destruct + a `by_cases` on the drop-fresh condition. **Both conjuncts fall
out of `hσ` mechanically.**

**Obligation → converter map** (the four task-356 exterior obligations of
`EndIntervalCorrectPrior`/`kampPrior_site_rungK_gate_match`):

| Gate obligation (KampPrior:845–870) | Discharged by | Direction |
|---|---|---|
| `hbrPastReal` (`x1 < x`, `σ.2 s = true → ∃ v`) | `kvE_pastBundle_of_realizer hσ` .1 | past, forward |
| `hbrPastSat` (`x1 < x`, `∃ v → σ.2 s = true`) | `kvE_pastBundle_of_realizer hσ` .2 | past, backward |
| `hbrFutReal` (`t < x1`, `σ.2 s = true → ∃ v`) | `kvE_futBundle_of_realizer hσ` .1 | future, forward |
| `hbrFutSat` (`t < x1`, `∃ v → σ.2 s = true`) | `kvE_futBundle_of_realizer hσ` .2 | future, backward |

The seven interior obligations (`hreal`/`hexcl` + the internalized `hexclExt`) route through
`kampPrior_site_rungK_gate_match` → `bracketEndChar_kvExt_correct_prior`
(ExteriorGateAssembleK.lean:106); `hexclExt` is discharged internally by that lemma (NOT an input
binder — KampPrior:807–809). So the entire discharge reduces to: **produce `hσ` at the anchor `x1`
the chain destructor reconstructs, for each admissible `σ`.**

**Subtlety for the planner (quantifier reconciliation).** The gate obligations quantify `x1`
universally (`∀ x1, t < x1 → …`), but a realizer `hσ` exists only at the *selected* anchor. The
reconciliation is that the outer recursion applies the converter at the specific `x1` produced by
`kvE_futChainDestructG`, and the `∀x1` obligation shape is the *interface* the composed gate
consumes; at non-selected `x1` the fiber antecedent is discharged by the exclusion reading. Confirm
this alignment early — it is the one place the "converter is pure" story meets the "obligation is
∀-quantified" gate shape. (This is exactly what the Phase-5 discharge template comment at
ExteriorConverterK.lean:192–207 asserts is sound.)

**Consumers are green and ready** (obligation-carrying, sorry-free):
- `endInterval_step_correct` / `EndIntervalCorrectPrior` (EndIntervalConsumerK.lean:171 / :95).
- `kampPrior_site_rungK_gate_match` (KampPrior.lean:816) — the general-`k` supply-site seam.
- provider shim `kampPrior_existProviders_of_ih` (KampPrior.lean:972) + its correctness bridges.

Retiring :361 is: instantiate `endInterval_step_correct` with the shim-provider family and the
produced realizer, discharging all eleven obligations at the `k+1` recursion body; then the arm
returns `⟨endIntervalPrior …, proof⟩`.

---

## 4. Honest difficulty assessment and escalation boundary

**Difficulty: genuinely HARD open mathematics — confirmed.** This is not mechanical threading.
The single hard core is the **positive within-bracket realizer recursion** (§2.3 step 3): a depth
induction that, at each fiber level, uses Dedekind-completeness `inf`/`sup` selection to produce an
actual witness `y`. The k=1 instance is closed (`fChainFrom`/`fChainPred`); the k≥2 fiber-level
recursion (arity 5) is the open piece. Realistic size: comparable to the landed k=1/k=2 negation
machinery (hundreds of lines), because the destructor and converters already exist and the work is
the *converse* (existence) direction plus the depth recursion.

**What de-risks it** (large amount of landed scaffold):
- Cor 5.4 chain destructor is generic over depth (`kvE_futChainDestructG`) — the anchor is free.
- Both converters are pure readers — the obligation discharge is mechanical *given* `hσ`.
- The provider shim + all seam certificates + the obligation-carrying consumer are green.
- The k=2 template (`SubBracket2.lean`, `ExteriorBracket.lean`) is a byte-level model for the
  general-k fiber selection.

**What is genuinely uncertain** (honest unknowns):
1. **The fiber-level existence converse** (EANegation.lean:530–536, explicitly flagged
   "we prove the converse using `HasAttainedINF`") — whether the `inf`/`sup` selection composes
   cleanly through the arity-5 fiber fold at general depth, or whether coupling between fiber
   witnesses forces a genuine multi-anchor (Lemma 5.1) argument. **This is the primary risk.**
2. **The `| n+2 =>` arity lift** (§1.3) — whether the arity-generic reduction (route a) works, or
   whether arity `≥3` needs the full increasing-sequence realizer (route b, Lemma 5.1).
3. **The ∀x1 / selected-x1 quantifier reconciliation** (§3 subtlety) — low risk but must be pinned.

**Escalation boundary (zero-debt, per task mandate).** If either (1) the fiber-level converse or
(2) the arity lift **cannot close green**, the correct move is **`[BLOCKED]` with a documented
sub-piece**, NOT a strategic `sorry` and NOT a vacuous `def`. Suggested decomposition if blocked:
- Spawn a sub-task for the **fiber-level `HasAttainedINF` existence converse** (the arity-5,
  general-depth mirror of EANegation.lean:571) as an isolated lemma — this is the true atom of
  difficulty and is the natural blocker to escalate.
- Keep `| n+2 =>` (:364) as a *separate* follow-up if route (a) fails: it is off the critical path,
  so the critical terminus (`completeness_discrete`) can go green on :361 alone **only if** :364 is
  also retired for a clean `#print axioms` — so :364 cannot simply be deferred without keeping
  `sorryAx` in the footprint. If :364 must be split out, the parent task stays `[BLOCKED]` (clean
  footprint not yet achievable), never `[COMPLETED]` with a carried sorry.

**Definition of done (unchanged from task brief):** `nf_nvar_exist_all_depths` sorry-free at all
depths (:361 and :364 retired); the shim-provider instantiation discharges
`hreal`/`hexcl`/`hbr*` at the `k+1` recursion body; `#print axioms completeness_discrete` =
`[propext, Classical.choice, Quot.sound]` (plus the acceptable `ofReduceBool`/`trustCompiler` from
`native_decide` in the Syntax layer). Verify with `lean_verify` on the fully-qualified terminus.

---

## 5. Stable-contract note (task 341 concurrency)

Task 341 is concurrently refactoring `NfMultiAnchorBridge/`. Per the task brief, treat the
**lemma interfaces** as the stable contract, not file locations. The load-bearing interfaces this
task consumes (do not re-derive; re-locate by name if 341 moves them):
- `kvE_futBundle_of_realizer` / `kvE_pastBundle_of_realizer` (the converters).
- `kvE_futChainDestructG` / `kvE_pastChainDestruct*` (the Cor 5.4 anchor destructor).
- `bracketEndChar_kvExt_correct_prior` (the interior+exterior composed gate).
- `endInterval_step_correct` / `EndIntervalCorrectPrior` (the obligation-carrying consumer).
- `kampPrior_site_rungK_gate_match` + `kampPrior_existProviders_of_ih` (the KampPrior seam + shim).

**FILE SCOPE**: task 358 edits **only** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean`
(the `| 1 =>` :361 and `| n+2 =>` :364 arms). It CONSUMES the carrier/converter layers.

---

## 6. Tactic Survey Results (advisory)

No tactic sweep was run against live goals (research-only; the target arms are `sorry`, so
`lean_goal`/`lean_multi_attempt` at :361 would only echo the stated obligation). The construction
is definitional/assembly, not tactic-closable:
- The realizer fold is `nf_eval_nfk_iff_efold`-driven (`.mpr ⟨⟨hA, hfib⟩, hoff⟩`) — NOT `simp`/
  `aesop` territory; the converters already show the exact term shape.
- `omega` is used for the `Fin`-index bookkeeping in the site lemmas (KampPrior:657–665) — reusable.
- The anchor `inf`/`sup` existence is a `HasAttainedINF`/Dedekind-completeness lemma application,
  not automation.
**Forbidden per literature-fidelity policy**: do NOT attempt to `simp`/`omega`/`aesop` past the
`inf`/`sup` selection step — it is the faithful Rabinovich content and must be transcribed
explicitly (mirror `fChainFrom`, EANegation.lean:552).

---

## 7. Bottom line

Task 358 has **one hard core**: the positive, general-depth, within-bracket realizer recursion
(Rabinovich Cor 5.4 `inf`/`sup` selection, the *converse* of the already-landed chain destructor,
lifted to arity-5 fibers). Produce `hσ` there and the eleven carried obligations discharge
mechanically through the two landed converters and the green obligation-carrying consumer. The
`| n+2 =>` footprint arm should be folded into an arity-generic construction (route a) or, failing
that, escalated as a separate blocker. Zero-debt: if the fiber-level converse or the arity lift
cannot close green, mark `[BLOCKED]` and spawn the isolated `HasAttainedINF` fiber-existence
sub-task — never a strategic sorry or vacuous def.
