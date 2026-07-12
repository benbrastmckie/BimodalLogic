# Task 352 — Realizability-Transfer Blocker Adjudication (Research Fork)

**Agent**: lean-research-hard-agent | **Date**: 2026-07-12 | **Mode**: hard (H2/H3/H4/H5), lit
**Reference grounding tier**: **Tier 1** (literature-backed — Rabinovich 2014, Lemma 5.1/5.3, Cor 5.4, Def 7.5/7.7/7.13)
**Verdict**: **NO-GO** for an additive free-env→fixed-env transfer lemma. The transfer is a **genuine F2-style impossibility at depth k≥1** (H4-confirmed). The **only faithful fix is a multi-anchor (endpoint-pinned) converter at task-349 level** — NOT additive to `ExteriorFiberK.lean`, NOT the reindex bridge.

---

## TL;DR

The prior obstruction is **real and correctly diagnosed**, and it is on the **IMPOSSIBLE side of the
F2 boundary**, one rung up in the *environment* dimension. The requested "shared free-env→fixed-env
anchor-coherence / realizability-transfer lemma"

```
(∃ env', nf_eval M k 5 (Fin.cons r env') s)  →  (∃ y, nf_eval M k 5 (Fin.cons y [x1,w,x,t]) s)
```

is **false in a general model** and its Lean obligation **reduces exactly to `env4 = env'`**
(H4-verified via `convert … using 3`; `aesop` fails). The information it demands was destroyed by
`ExistProviders.existF`'s single-anchor existential design (`PriorInterface.lean:40-45`:
`∃ env : Fin n → M.carrier, …` quantifies all non-walked anchors). No lemma can recover discarded
information — that is the F2 truncation-shadow boundary.

**Rabinovich never performs this transfer.** His completeness proof (Cor 5.4(1) ⇐) avoids it by two
mechanisms: (1) bracket point-types `α_i, β_i` are **quantifier-free** (Lemma 5.1) → point
realizability is env-free; (2) the interior witness `r0 = inf{z ∈ (z0,z1) | P1(z)}` is **uniquely
determined** (Lemma 5.3 Case 3, `INF`) and **becomes the fixed left endpoint** of the recursive
sub-bracket `On(P2,…,Pn, r0, z1)`. Anchors are always a *determined ascending chain*, never a free
tuple. The Lean encoding's env-existential occurrence is a **faithfulness deviation faithful only to
`_sound`** (build FROM a realizer), **not to `_complete`** (reconstruct at fixed anchors).

**The faithful fix** is to feed the `_complete` reconstruction a converter that **pins the 4 anchors
`[x1,w,x,t]` and quantifies only the fresh point** — the depth-k arity-5 analog of the already-landed
two-anchor carrier `BracketCarrierCorrectVPrior` (`PriorInterface.lean:60-73`, which pins `x,t` and
quantifies only witness `w`). That converter is a **task-349 deliverable**, not additive to 352's
`ExteriorFiberK.lean`.

---

## Reference Grounding — Lemma-Level Mapping Table (H3 Tier 1)

| Source (Rabinovich 2014) | Prop / Location | Lean Identifier | Type Signature (verified) | Status |
|---|---|---|---|---|
| Bracket `[α0,β1,…,αn](z0,z1)`, **point types `αi,βi` quantifier-free**, interior x1<…<xn quantified between fixed z0,z1 | Lemma 5.1 / Notation 5.2 (chunk_0013:31-33,53); Def 7.5 (chunk_0021:17) | `ExistProviders.existF` + `insertEnv env t` | `existF n : NormalForm sig k (n+1)→Formula`; `correct`: `∃ env, nf_eval (insertEnv env t) sub` — pins `t`, **quantifies `env`** | Confirmed (`PriorInterface.lean:40-45`) |
| `¬∃x1…∃xn (z0<x1<…<xn<z1)∧⋀Pi(xi)` ≡ `On(P1,…,Pn,z0,z1)` — the negated existential | Lemma 5.3 (chunk_0014:3) | fold conjunct `nf_eval_efold_k` | `∀ sub, nfk_dropFresh sub = qnf.1 → ((∃ x, nf_eval (Fin.cons x env) sub) ↔ qnf.2 sub)` — fresh at index 0, **`env` FIXED** | Confirmed (`NfEFold.lean:608-613`) |
| **Determinacy: `r0 = inf{z∈(z0,z1)\|P1(z)}` UNIQUE, pinned by `INF(z0,r0,z1,P1)`; `r0` BECOMES endpoint of `On(P2,…,Pn,r0,z1)`** | **Lemma 5.3 Case 2/3** (chunk_0014:19-35) | `semantic_prior_UZ`/`SZ` (first/last-occurrence = infimum existence) | `∃ s, t<s ∧ ψ@s ∧ ∀ r∈(t,s), ¬ψ@r` (first occurrence) | Confirmed (`PriorDefs.lean:22,33`) — supplies **infimum existence only**, not saturation |
| Completeness (⇐) reconstructs endpoint `z` from the **actual** increasing sequence via the Until-chain; recursion on **bracket length** (intra-rung), NOT on env-transfer | Cor 5.4(1) proof (chunk_0015:11-41) | `kvE_futChainG`/`BuildG`/`DestructG` (landed) | Until/Since chain over the fiber list | Confirmed (chain infra green; handoffs) |
| Two-fixed-endpoint carrier: **pins BOTH `x,t`, quantifies only witness `w`** (the anchor-pinning `_complete` needs) | Lemma 3.2(2)+§5 bracket (PDF p.4/p.7) | `BracketCarrierCorrectVPrior` | `(carrier qnf).holds M atomMap x t ↔ ∃ w, nf_eval M k 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf` | Confirmed (`PriorInterface.lean:60-73`) — **arity-3; the arity-5 analog is the missing task-349 piece** |
| Nested `(z0,…,zk,∞)` bracket: depth = **nesting of quantifier-free-point brackets at re-anchored endpoints** | Def 7.13/Lemma 7.10 (chunk_0023/0024) | depth-k σ (`NormalForm sig (k+1) 4`) | 4 fixed anchors + 1 fresh per rung | Confirmed (structural) |

---

## Deliverable 1 — Rabinovich's completeness-direction argument for the interior-witness → fixed-anchor transfer

**Finding: Rabinovich AVOIDS the transfer; he never realizes a joint type at a free tuple. The
env-existential occurrence is SUFFICIENT in the source only because the source keeps the anchors
DETERMINED via infimum determinacy and re-anchoring — a coherence fact the Lean `_complete` obligation
does not currently possess.**

### The source's mechanism, exact locations

**(a) Point types are quantifier-free (Lemma 5.1, chunk_0013:31-33).** Lemma 5.1 is stated for
formulas "`[α0, β1, …, αn](z0,z1)` where `αi, βi` are quantifier free." Realizability of a
quantifier-free `Pi` at a point depends only on that point's atom-type — **env-independent**. The
depth of Kamp's construction is therefore *not* carried inside a point type; it is carried by
**nesting** brackets (Def 7.13, `(z0,z1,…,zk,∞)`, chunk_0023).

**(b) The interior witness is the infimum, not a free existential (Lemma 5.3 Case 2/3,
chunk_0014:19-35).** In the inductive step defining `On+1(P1,…,Pn+1, z0, z1)`:
> Case 2: `r0 = inf{z ∈ (z0,z1) | P1(z)}` (such `r0` exists by **Dedekind completeness**). … Note
> `r0 = z0` iff `K⁺(P1)(z0)`.
> (3) `(∃r0)_{z0<r0<z1}[ INF(z0,r0,z1,P1) ∧ On(P2,…,Pn, r0, z1) ]`.

`r0` is **uniquely determined** (`INF(z0,r0,z1,P1)` pins it to the infimum) and **becomes the new left
endpoint** of the recursive sub-bracket `On(P2,…,Pn, r0, z1)`. The "interior witness" is re-anchored
into an *endpoint*. There is no free interior environment at any rung.

**(c) The ⇐ (completeness) direction consumes the ACTUAL sequence, re-anchoring, never transferring
(Cor 5.4(1) proof, chunk_0015:11-41).** The observation is proved
`⇐` by induction on **bracket length**: given the genuine increasing sequence `x1<…<xn+1` realizing
the (quantifier-free) `Fi`, it *constructs* the endpoint `z` by walking the Until-chain
(`F_{i-1} := α_{i-1} ∧ (β_i Until F_i)`), pinning each next witness `y2 > y1` to an actual sequence
point via order case-splits (`if y2 ≤ xn+1 … else xn+1 ∈ (y1,y2)`). The anchors are `z0` (fixed
outer) and the constructed `z`; the interior points stay as the *actual* realizers and are never
transported to a foreign tuple.

### Why this makes the env-existential "sufficient" in the source but not in the Lean `_complete`

The Lean `semantic_prior_UZ`/`SZ` hypotheses (`PriorDefs.lean:22,33`) are **exactly Rabinovich's
Dedekind-completeness `r0`-existence** ("every future occurrence of ψ has a first occurrence") — the
determinacy INPUT of Lemma 5.3 Case 2. They pin the **first occurrence of a single formula `ψ`**
(a depth-0/marginal, temporal_truth channel). They do **not** provide *joint depth-k realizability at a
fixed anchor tuple* — the source never needs that, because its point types are quantifier-free (a)
and its recursion re-anchors (b,c). The Lean encoding, by representing depth with **env-dependent
arity-5 depth-k subs** evaluated against the shared anchor tuple, creates a realizability obligation
Rabinovich's architecture structurally sidesteps.

**Adjudication of the user's faithfulness question:** the interior existential is **faithful to the
`_sound`/negation-formula being characterized** (the bracket's `∃x1…∃xn` interior — report 02
Deliverable 3.3 is correct *for that direction*). It is **NOT faithful to the `_complete`
reconstruction**, where the source pins witnesses as infima and re-anchors. The resolution the user
anticipated — *"normal-form determinacy pins env′ = the fixed env up to the relevant bits, and/or the
fixed anchor is itself one of the existential witnesses"* — is **exactly how Rabinovich avoids the
transfer**: his `r0` is a determined witness that becomes the anchor. But that determinacy lives in a
**multi-anchor / re-anchored converter**, which `ExistProviders.existF` (single-anchor) discards.

## Deliverable 2 — Is the transfer lemma already in the tree under a non-obvious name?

**Adversarial search performed (grep on the MATH, not the naming); result: NO — verified none exists,
and the closest existing object proves the transfer is the WRONG tool.**

Searched (the math, per the false-negative warning): `realizab`, `homogen`, `saturat`,
`anchor.*coher`/`coher.*anchor`, `env.*independ`, `transfer`, plus `nf_eval_unique` corollaries and
`SharedWitness` generalizations. Findings:

- **`nfk_dropFresh` (`NfEFold.lean:578-580`)** — the fiber label — is `nf0_dropFresh sub.atom_assgn`,
  codomain `NormalForm sig 0 n` (**depth-0 only**). So `nfk_dropFresh s = σ.1` constrains env′ and
  `[x1,w,x,t]` to agree **only at the depth-0 atom characteristic**, never deeper. This is the
  mechanical root of the impossibility.
- **`nf_eval_unique` (`NormalForm.lean:245`)** — determinacy of a normal form at a **fixed** env. It
  needs *two realizers at the SAME env*; it cannot bridge two *different* envs. Used by
  `nf_eval_nfk_iff_efold`'s off-fiber clause and by `kvE_pastCarry`, always at a fixed env.
- **`SharedWitness.lean`** (task 321, k=2) — the cited candidate template. It builds
  `∃ w, ⋀_σ (per-σ realization at that same w)` (module doc:4-6) as a **flat** joint carrier whose
  **point types are quantifier-free / E[Σ]-atom ONLY** (doc:14-18, "no chain predicate in any
  point-type position (FM-merge), no bracket-in-bracket"). It works **precisely because** k=2's
  profiles are env-free (Lemma 5.1). Its argument **does NOT generalize**: at depth k≥1 the arity-5
  subs are not quantifier-free, so they cannot be flattened into atom point-types, and the shared-
  witness conjunction cannot be assembled. This is the same wall the handoffs record ("k=2 avoided it
  via arity-1 env-free profiles").
- **`kvE_pastCarry` (`ExteriorNegationPastK.lean:511-533`)** and the Future mirror — the `_sound`
  workhorse — require `hfib` *already bound to the FIXED env*; they are the (⇐)-consumer, not a
  producer of the transfer.
- **`BracketCarrierCorrectVPrior` (`PriorInterface.lean:60-73`)** — the closest existing object: it
  **pins two anchors and quantifies one witness**. This is the correct *shape*, but arity-3 (task
  349/321), not arity-5, and it is a **carrier**, not derivable from `ExistProviders`.

**Verified conclusion: the transfer lemma does not exist in the tree, and cannot — see Deliverable 4.**

## Deliverable 3 — GO/NO-GO with the exact statement, and H4 attempt at the real obligation

### H4: attempted the key step at the real obligation shape (not asserted)

Scratch probe (`TransferProbe352.lean`, built against the real imports, `lean_goal` + `lean_multi_attempt`,
then removed — tree left clean). Stated the transfer with exactly the hypotheses the `_complete`
reconstruction possesses:

```lean
theorem transfer_probe (M) {k} (σ : NormalForm sig (k+1) 4) (env4 : Fin 4 → M.carrier)
    (hAtom4 : nf_eval_nf M 0 4 env4 σ.1)
    (s : NormalForm sig k 5) (hlabel : nfk_dropFresh s = σ.1)
    (r : M.carrier) (env' : Fin 4 → M.carrier)
    (hocc : nf_eval_nf M k 5 (Fin.cons r env') s) :
    ∃ y, nf_eval_nf M k 5 (Fin.cons y env4) s
```

`lean_goal` at the obligation: `⊢ ∃ y, nf_eval_nf M k 5 (Fin.cons y env4) s`, with the ONLY link
between `env4` and `env'` being depth-0 agreement with `σ.1` (`hAtom4`; and `hocc`'s atom layer +
`hlabel`). Attempts (`lean_multi_attempt`):

| Attempt | Result |
|---|---|
| `exact ⟨r, hocc⟩` | **type mismatch** `Fin.cons r env'` vs `Fin.cons r env4` |
| `refine ⟨r, ?_⟩; convert hocc using 3` | residual goal **`⊢ env4 = env'`** (the entire content) |
| `aesop` | **failed to prove the goal after exhaustive search** |
| `exact ⟨r, hAtom4 ▸ hocc⟩` | invalid (no equality) |

**The transfer's proof obligation IS `env4 = env'`** — the false claim that a free interior tuple
equals the fixed anchor tuple.

### Impossibility argument (F2 truncation-shadow, one rung up, in the env dimension)

`hlabel : nfk_dropFresh s = σ.1` (depth-0 only) + `hAtom4` give `env4` and `env'` agreeing **only at
the depth-0 atom characteristic `σ.1`**. But `nf_eval_nf M k 5 (Fin.cons y env4) s` evaluates `s` at
depth k with `env4` **consed under every quantifier** (`lean_hover_info` on `nf_eval_nf`: depth-(k+1)
"for each sub-normal-form, existential realization matches", each sub at `Fin.cons x env`). For k≥1,
`s` detects deeper joint content of the anchor coordinates that `σ.1` does not record. Concretely (the
`RefutationF2` witness family, machine-proved in a concrete ℤ model, lifted to the env dimension):
take `s` asserting a **depth-1** property of anchor coordinate 1 (e.g. "has a P-successor"); `env'`
coordinate-1 has one (so `hocc` holds) while `env4` coordinate-1 (`= x1`) has none, so `s` fails at
`(y, env4)` for **all** `y`. Both realize `σ.1` (a depth-0 char blind to "has a P-successor"). LHS
true, RHS false. This is `f2_sub_proj_eq` (`RefutationF2.lean:471`: two subs depth-0-indistinguishable,
depth-1-distinct) / `f2_carrier_eq` (`:582`) **one rung up**: there it is two *subs* sharing a marginal;
here it is two *environments* sharing `σ.1`. **Same information boundary → genuine impossibility.**

`h_UZ`/`h_SZ` do not rescue it: they are first/last-occurrence (infimum existence) of a **single
formula ψ** (`PriorDefs.lean:22,33`), the depth-0 navigation channel — not joint depth-k saturation at
a fixed tuple. (Adversarially confirmed: the `_sound`/`_complete` statements quantify over a **general**
`OrderedMonadicStructure` with only `h_UZ`/`h_SZ`; no canonical-model saturation is even in scope.)

### VERDICT: **NO-GO** for the requested additive transfer lemma.

The requested "SHARED, side-agnostic free-env→fixed-env transfer lemma additive to `ExteriorFiberK.lean`"
**does not exist and cannot be written**: its content is `env4 = env'`, false at depth k≥1, and the
information was destroyed by `ExistProviders.existF`'s single-anchor quantification. No additive lemma
recovers discarded information (F2 boundary). This confirms and sharpens both reclose handoffs.

## Deliverable 4 — The only faithful alternative (feasibility)

**The fix is to change the CONVERTER the `_complete` content channel consumes, not to add a transfer
lemma.** The `_complete` reconstruction must be fed the sub's realizability **with the 4 anchors
`[x1,w,x,t]` PINNED and only the fresh point quantified** — the depth-k, arity-5 analog of the
existing two-anchor carrier:

```lean
-- EXISTS at arity-3 (task 349/321): PriorInterface.lean:60-73
(carrier qnf).holds M atomMap x t ↔ ∃ w, nf_eval_nf M k 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf
--                                    ^ pins x AND t, quantifies only w

-- NEEDED at arity-5 (the missing piece the multi-anchor exterior clause requires):
--   a converter  extF4 : NormalForm sig k 5 → Formula   with correctness
extF4_correct : temporal_truth M atomMap t (extF4 s) ↔
    ∃ y, nf_eval_nf M k 5 (Fin.cons y (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s
--                                    ^^^^^^^^^^^^^^^^^^^^^^^^^^ the 4 anchors PINNED
```

Contrast: `ExistProviders.existF 4 s` gives `∃ env : Fin 4 → M, nf_eval (insertEnv env t) s` — pins
only `t`, quantifies the other 4. The `_complete` direction fundamentally needs the four anchors
`[x1,w,x,t]` pinned; the single-anchor converter cannot supply this, and no post-hoc lemma restores it.

**Where it lives / feasibility:**
- This is a **task-349-level deliverable** (the "resolution (b): richer bundle carrying recursive
  bracket correctness" flagged in `01_team-research.md` Risk table row 2 — the risk teammate E
  downgraded **only for the negation-closure/`_sound` direction (Lemma 7.8)**, which does NOT cover the
  `_complete` reconstruction assessed here). It is the arity-4/5 generalization of the landed
  `bracketEndChar_kvE2_*_two_prior` carrier family (`OuterGate.lean:147-359`,
  `ExteriorBracket.lean:1069`) and `BracketCarrierCorrectVPrior`.
- **It must NOT edit `ExistProviders`'s existing `existF`/`correct` signature, `P.correct`, or the 7
  frozen providers** — it is an **additional, separately-stated multi-anchor converter** (a new
  carrier/bundle field alongside the existing single-anchor one, or direct consumption of task 349's
  arity-4 carrier). It is **NOT additive to 352's `ExteriorFiberK.lean`** (that module only has the
  single-anchor `P` and the reindex bridge; the reindex bridge relabels but does not add anchors).
- **The determinacy engine already exists**: `semantic_prior_UZ`/`SZ` = Rabinovich's infimum existence
  (Lemma 5.3 Case 2), consumed exactly as the frozen k=2 two-anchor carrier consumes them
  (`bracketEndChar_kvE2_complete_two_prior`, `OuterGate.lean:147`). The arity-4/5 build is a
  faithful, feasible generalization of a **landed, green** pattern — Medium confidence on
  feasibility, High confidence that it is the correct and only faithful shape.

**Recommended action:** re-scope the two `_complete` halves as **BLOCKED pending a task-349 arity-4/5
multi-anchor exterior-bracket converter** (`extF4`/`extF4_correct` above). Do **not** re-dispatch
either `_complete` against `ExistProviders` alone; do **not** attempt an additive transfer lemma
(proven impossible). The `_sound` halves and all clause defs (`kvE_futPos`/`kvE_extNegFut`,
`kvE_pastPos`/`kvE_extNegPast`, both `_sound`) remain GREEN and consumer-ready (349 Phase 2 can consume
them now).

---

## Adversarial Self-Verification (H4)

| Claim | Source / Counterexample probe | Verification Method | Confidence |
|---|---|---|---|
| The transfer's obligation reduces exactly to `env4 = env'` | `transfer_probe` at real obligation shape | **`lean_multi_attempt` `convert hocc using 3` → residual `⊢ env4 = env'`; `aesop` fails** | High |
| `nfk_dropFresh` constrains only the depth-0 atom layer | codomain `NormalForm sig 0 n` | Read `NfEFold.lean:578-580` (`nf0_dropFresh sub.atom_assgn`) | High |
| `nf_eval_nf` depth-k is env-dependent (sub at `Fin.cons x env`) | — | `lean_hover_info` on `nf_eval_nf` ("each sub-normal-form … at `Fin.cons x env`") | High |
| `h_UZ`/`h_SZ` = infimum/first-occurrence existence, NOT saturation | Rabinovich Lemma 5.3 Case 2 "such r0 exists by Dedekind completeness" | Read `PriorDefs.lean:22-45` + chunk_0014:19 | High |
| `ExistProviders.existF` quantifies all non-walked anchors (`∃ env`) | — | Read `PriorInterface.lean:40-45` | High |
| A two-anchor **pinned** carrier exists (`BracketCarrierCorrectVPrior`, pins x,t; quantifies w) | — | Read `PriorInterface.lean:60-73` | High |
| Rabinovich pins interior witness as `r0 = inf`, re-anchors to endpoint (no transfer) | Lemma 5.3 Case 2/3 formula (3) `INF(z0,r0,z1,P1) ∧ On(P2,…,Pn,r0,z1)` | Read chunk_0014:19-35 | High |
| Rabinovich point types quantifier-free (env-free realizability) | Lemma 5.1 "αi, βi are quantifier free" | Read chunk_0013:31-33 | High |
| k=2 `SharedWitness` works via quantifier-free point types; does NOT generalize to k≥1 | module doc "quantifier-free / E[Σ]-atom point types ONLY … no bracket-in-bracket" | Read `SharedWitness.lean:1-40` | High |
| Impossibility is F2-boundary (RefutationF2 lifted to env dimension) | `f2_sub_proj_eq` (depth-0-indist/depth-1-distinct), machine-proved in ℤ | Read `RefutationF2.lean:471,582`; structural lift argument | Medium-High |
| Faithful fix = arity-4/5 multi-anchor converter, task-349 level, NOT `ExteriorFiberK`-additive | landed k=2 pattern `bracketEndChar_kvE2_*_two_prior` | Read `OuterGate.lean:147-359`; `PriorInterface.lean:32-73` | Medium-High |

**Contradiction Log.** One contradiction with prior optimistic framing, **resolved**. Report
`01_team-research.md` (teammate E addendum) downgraded the "existF-insufficiency / secretly needs
resolution (b)" risk, concluding `ExistProviders` is faithful. Resolution (precedence: executed lean
tool result + direct source read > prior synthesis judgement): E's downgrade is **correct but scoped to
the negation-closure / `_sound` direction (Lemma 7.8, which consumes only rung-k *formulas*)**. It does
**not** cover the `_complete` **reconstruction** direction (Cor 5.4(1) ⇐), which recurses on bracket
structure and requires anchor-pinned realizability. The two are different obligations; no unresolved
contradiction remains. (The user's own warning — that a prior "no such lemma, grep empty" was a false
negative — was heeded: this NO-GO is backed by an H4 lean obligation reducing to `env4 = env'` and a
concrete counterexample family, not an empty grep.)

**Forbidden-output check:** no "mathlib likely has this" (the object is repo-local and its absence is
proven, not assumed); no sorry/axiom/placeholder recommended; the type-mismatch claim is backed by a
captured `lean_goal`/`lean_multi_attempt` state; the impossibility is grounded in a named counterexample
family (`RefutationF2`) and a source citation (Lemma 5.3), not asserted.

---

## H5 Divergence Note (blocker-convergence audit)

Both `_complete` halves (Future 3.3, Past 4.3) hit the **identical** wall across the reclose dispatches.
This report closes the divergence: the wall is **not** a proof-engineering gap to be re-attempted — it
is a **structural insufficiency of the single-anchor `ExistProviders` channel for the reconstruction
direction**, proven impossible additively. Root cause: the depth-k encoding carries anchor content in
**env-dependent arity-5 subs**, while Rabinovich carries depth in **nested quantifier-free-point
brackets with infimum re-anchoring**. Corrected next target (exact, not a description):
`extF4 : NormalForm sig k 5 → Formula` with `extF4_correct` pinning `[x1,w,x,t]` (Deliverable 4), built
as task 349's arity-4/5 carrier. Any further `_complete` dispatch against `ExistProviders` alone will
re-block identically — stop re-dispatching that shape.

## Files / Anchors

- Fold obligation: `NfEFold.lean:608-613` (`nf_eval_efold_k`), `:627-669` (`nf_eval_nfk_iff_efold`),
  `:578-580` (`nfk_dropFresh`, depth-0 codomain).
- Determinacy: `NormalForm.lean:245` (`nf_eval_unique`, fixed-env only).
- Single-anchor channel (the information loss): `PriorInterface.lean:40-45` (`ExistProviders.existF`).
- The correct pinned shape (arity-3, needs arity-5 analog): `PriorInterface.lean:60-73`
  (`BracketCarrierCorrectVPrior`); landed k=2 carrier `OuterGate.lean:147-359`,
  `ExteriorBracket.lean:1069`.
- `_sound` workhorse (consumer, not producer): `ExteriorNegationPastK.lean:511-533` (`kvE_pastCarry`).
- k=2 non-generalizing template: `SharedWitness.lean:1-40`.
- Impossibility witness family: `RefutationF2.lean:471` (`f2_sub_proj_eq`), `:582` (`f2_carrier_eq`).
- Prior determinacy = infimum existence: `PriorDefs.lean:22,33`.
- Literature: `~/Projects/Literature/sources/rabinovich_2014/` chunk_0013 (Lemma 5.1 / Notation 5.2),
  chunk_0014 (Lemma 5.3 Case 2/3, `INF`, Dedekind-completeness `r0`), chunk_0015 (Cor 5.4 ⇐ proof),
  chunk_0021 (Def 7.5), chunk_0022 (Def 7.7 canonical expansion, Lemma 7.8), chunk_0023/0024 (Def 7.13
  nesting).
- Prior reports/handoffs: `reports/02_reindex-bridge-blocker.md`, `reports/01_team-research.md`,
  `handoffs/phase-3-reclose-handoff-20260712.md`, `handoffs/phase-4-reclose-handoff-20260712.md`.
