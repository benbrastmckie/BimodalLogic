# Report 08 — Is the arity-4 multi-anchor bridge needed at all?

**Task**: 376 (`arity_general_zone_decomposed_char_engine`)
**Session**: `sess_1784138518_4af6d5`
**Dispatch**: upstream scoping research; focus = "is the arity-4 multi-anchor bridge needed at all"
**Reference grounding tier**: 1 (literature-backed — Rabinovich 2014 PDF is the arbiter)
**Probe**: `reports/08_arity4-necessity-probe.lean` — compiled green, sorry-free, axiom-clean

---

## VERDICT (for the human)

**Task 376 does NOT survive as scoped. The hypothesis is VERIFIED, and more strongly than posed.**

The arity-4 multi-anchor bridge is **100% proof-term dead**. It serves **no goal the live chain
has**. This is not an inference from imports or greps — it is a declaration-level trace of the
built `.olean` environment, walking `ConstantInfo.type ++ value |>.getUsedConstants`
transitively from `completeness_discrete`. Zero arity-4 `charFib` declarations are reachable.

Three independent facts converge:

1. **`charFib` is never instantiated.** In all 7 files that mention it (250 occurrences), every
   single one is a *binder* — `(charFib : (j : Nat) → NormalForm sig j 4 → Formula)`. Nothing in
   the repository ever supplies one. It is a hypothesis nobody discharges.

2. **The live chain's arity requirement is ≤ 2, and it always was.**
   `nf_characterizable_temporal_prior` (`KampPrior.lean:565`) consumes `NormalForm sig k 1`; its
   induction step calls `nf_nvar_exist_all_depths_fn atomMap h_surj k 1` (`KampPrior.lean:597`),
   whose sub-form is `NormalForm sig k 2`. Arity 4 appears nowhere on this path. Both facts are
   pinned by `example`s in the probe that elaborate against the real production types.

3. **The live blocker is not the arity-4 stack.** The only two sorries in `KampPrior.lean` are
   `:519` and `:522`. `:519` is the ambient-`k≥2` arm, and its own in-source note (`:507-518`)
   names its unblock path as the **arity-1** `charF`/`kvExt` gate stack
   (`kampPrior_site_rung2_gate_match` / `kampPrior_site_rungK_gate_match`), *not* the arity-4
   `charFib` stack. The arity-4 machinery is not even the intended supplier for the thing that is
   actually blocking.

**The upstream defect is real, and it is an encoding divergence** (§3): the repo's
`nf_eval_nf` (`NormalForm.lean:198-207`) grows environment arity `n → n+1` at every depth
descent. Rabinovich never grows arity. Arity 4 is simply that growth observed three descents
down from the live chain's arity-1 root. Task 376's premise — "build ONE arity-general,
zone-decomposed char/provider engine" — asks for an object the repo has **already machine-refuted**
(report 06's `anchorMove_refutes_any_charEngine`; this report's `charSeam_forces_slot_locality`
generalizes it to every arity with a free non-slot anchor).

**Headline answer to the (a)/(b) question the coordinator posed: NEITHER — and the news is
good.** Lemma 3.2(2)'s missing proof is **not** where the difficulty lives. The paper's genuine
difficulty is **Proposition 4.2**, and Rabinovich proves it **in full across §5 (pp. 7–13) —
six printed pages**. The project can avoid novel mathematics by faithfulness. See §4.

---

## 1. Why does the arity-4 bridge exist? (Q1)

### 1.1 It is forced by `nf_eval_nf`'s arity growth, not by any design decision

`nf_eval_nf` (`NormalForm.lean:198-207`), verbatim:

```lean
noncomputable def nf_eval_nf {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) :
    (k : Nat) → (n : Nat) → (env : Fin n → M.carrier) → NormalForm sig k n → Prop
  | 0, _, env, assignment =>
    ∀ (a : AtomKind sig _), atom_eval M env a ↔ (assignment a = true)
  | k + 1, _, env, ⟨atom_assignment, quant_assignment⟩ =>
    (∀ (a : AtomKind sig _), atom_eval M env a ↔ (atom_assignment a = true)) ∧
    (∀ (sub_nf : NormalForm sig k (_ + 1)),
      (∃ (x : M.carrier), nf_eval_nf M k (_ + 1) (Fin.cons x env) sub_nf) ↔
        (quant_assignment sub_nf = true))
```

Every depth descent takes `n → n+1`. From the live chain's arity-1 root: arity 1 → step at
arity 2 → the zone machinery pins 3 anchors (`zoneEnv3`, `NfZoneDepthK.lean:207-209`) → `+1`
fresh witness = **arity 4**. There is no ceiling at 4; it is simply where the work stopped.

### 1.2 The repo diagnosed this itself, one module away — and shelved the diagnosis

`NfEFold.lean:14-27` states the defect in its own words:

> `nf_eval_nf` (`NormalForm.lean:198-207`) grows environment arity `n → n+1` at every depth
> descent, coupling a fresh existential witness jointly to *all* fixed endpoints (**the arity-4
> residual that NO-GOed task 309's k=1 gate**). **Rabinovich never grows arity with depth** […]
> The quant-assignment domain `EAtomDom sig k n := ZoneSpec n × NormalForm sig k 1` makes Lemma
> 3.2(2)'s ≤2-cap a **type-level invariant**: there is no slot for a joint `(n+1)`-ary
> sub-evaluation.

That file was authored as the faithful fix (commits `ee40627d1`, `cd08672c5`, `d967091d2`,
`bf170f542`). Its original header line — *"Nothing in the existing development imports this file,
so it is off the live path"* — is now stale (5 bridge modules import it), but the fix it
proposed was never adopted: `nf_eval_nf` is retained unchanged and the bridge was built on it.

### 1.3 The real historical pivot: the faithful path stalled at Prop 4.2 and was archived

`Theories/Bimodal/Boneyard/KampNegationClosure/NegationClosure.lean:1-3`:

```
-- ARCHIVED from Metalogic/WeakCanonical/Kamp/NegationClosure.lean
-- Reason: Dead code — negation closure chain with no live downstream consumers
-- Archived: 2026-06-16 (task 302)
```

Its docstring names exactly what it could not finish:

> P2(k+1): `nf_exist_formula` forward is universal; backward requires Prior axioms +
> composition theorem (**the Rabinovich negation closure content**).

That is Proposition 4.2. It carried 7 sorries and was archived as "dead code". Everything from
task 309 onward — tasks 309/310/331/335/348–368/374/376, and the 47,333 lines of
`NfMultiAnchorBridge/` — is downstream of that abandonment.

**Answer to Q1**: the arity-4 bridge exists because the faithful Def-3.1 path stalled at Prop 4.2
and was archived, and its replacement encoding (`nf_eval_nf`) diverges from Rabinovich by growing
arity with depth. Arity 4 is a *symptom* of that divergence, not a design choice.

---

## 2. Is it discharging Lemma 3.2(2)? (Q2)

**No. It is routing around a statement that is false for the repo's encoding.**

`Lemma32Reduction.lean` (task 351, commit `83a9a437a`) is the module named for it, and its main
theorem `nfEval_le2_reduction` (`:535`) is green and sorry-free. **But it is not Rabinovich's
Lemma 3.2(2).** It factors only the *atom layer* into anchor pairs; the quant layer's recursion
still descends at arity `n+1` (`nfEvalRHS`, `:498-506`). Its own docstring concedes this
(`:477-482`):

> the inner arity `n+1` appears solely as the domain of the recursion (the `∃ w` binder over
> `Fin.cons w env`), never as the anchor arity of an emitted `nf_eval_nf` conjunct.

So `nfEval_le2_reduction` is `Iff.rfl` modulo atom factoring. It caps nothing. It does not
reduce free variables, which is the entire content of Lemma 3.2(2).

Its Phase-3 docstring (`:290-306`) then declares the *real* reduction a **non-theorem**:

> the converse is a **non-theorem** for a FIXED single pair: when `n ≥ 3` there is an anchor
> position outside `{i, j}` […] the arity-3 restriction genuinely FORGETS the other anchors

**That declaration is correct for the repo's encoding, and irrelevant to Rabinovich's** — because
the repo's `NormalForm sig k n` is not the object Lemma 3.2(2) is about. See §3.

**Status note**: `Lemma32Reduction.lean` (549 lines) is **orphaned** — imported by nothing except
one Boneyard file.

---

## 3. The upstream defect: the repo's encoding is not Rabinovich's object

This is the finding that subsumes routes A/B/C.

**Rabinovich Def 3.1 (p.4)** — an ∃⃗∀-formula is *interval-decomposed*:

```
ψ(z_0,…,z_m) := ∃x_n…∃x_1∃x_0 [ (⋀_{k=0..m} z_k = x_{i_k}) ∧ (x_n > x_{n-1} > … > x_0)
                                 ∧ ⋀_{j=0..n} α_j(x_j)                    "α_j holds at x_j"
                                 ∧ ⋀_{j=1..n} (∀y)^{<x_j}_{>x_{j-1}} β_j(y)  "β_j along (x_{j-1},x_j)"
                                 ∧ (∀y)_{>x_n} β_{n+1}(y) ∧ (∀y)^{<x_0} β_0(y) ]
```
with *"all α_j, β_j quantifier free formulas with **one variable** over Σ"*. Every conjunct is
localized to a **point** `x_j` or an **open interval** `(x_{j-1}, x_j)`. The free variables
`z_0..z_m` are dummies — each is *equated* to some existential `x_{i_k}` (p.4: *"m+1 quantifiers
are dummy and are introduced just in order to simplify notations"*).

**The repo's `NormalForm sig k n` / `nf_eval_nf`** is a **Hintikka / Ehrenfeucht–Fraïssé n-type**:
`∀ a : AtomKind sig n, atom_eval M env a ↔ qnf a = true`, plus
`∀ sub, (∃x, nf_eval_nf M k (n+1) (Fin.cons x env) sub) ↔ qnf.2 sub = true`. It has:

- **no ordered existential prefix** (`x_n > … > x_0`),
- **no α_j point-type layer**,
- **no β_j interval-type layer**,
- **no dummy-variable equations**,
- and it **grows arity with depth**, which Def 3.1 structurally cannot.

These are different mathematical objects. Lemma 3.2(2) is a theorem about the first and a
non-theorem about the second. `Lemma32Reduction.lean`'s Phase-3 note discovered exactly this and
misattributed it to the *reduction* rather than to the *encoding*.

### 3.1 What the repo already has of the faithful path

`ExistsForallNF.lean` (339 lines, imported by `KampPrior.lean:1`) **is** a Def 3.1 transcription
in progress:

| Piece | Status |
|---|---|
| `TemporalPred` (`:49`) — Def 3.1's one-variable α_j/β_j | ✅ exists, used tree-wide |
| `IntervalPattern (n)` (`:93`) + `.holds` (`:106`), `holds_zero/succ/of_eq` | ✅ exists |
| `VEF` (`:214`), `VEF.holds` (`:219`), `VEF1` (`:226`), `VEF.disj`/`disj_holds` (`:251`,`:254`) | ✅ exists |
| `buildRight` (`:285`) / `buildLeft` (`:298`) / `translateEF1` (`:311`) — **Prop 3.5's nesting** | ✅ exists, **and proved correct** (`buildRight_correct`, `buildLeft_correct`, `VecEATranslation.lean:213,481`) |
| `VEF.closed_conj` — **Lemma 3.2(1)** | ❌ **advertised at `:21`, never defined** |
| `VEF.closed_ex` — **Lemma 3.4 / 3.2(3)** | ❌ **advertised at `:22`, never defined** |
| `VEF.closed_disj` | ❌ **advertised at `:20`, never defined** |
| **Lemma 3.2(2)** (≤2 free vars) | ❌ absent |
| `VEF.closed_neg` — **Prop 4.2** | ❌ absent (archived, task 302) |
| **Prop 4.3** (structural induction) | ❌ absent |

⚠️ **Honesty flag**: `ExistsForallNF.lean` has 0 sorries *because the hard theorems were never
stated*, not because they were proved. Its "Main Results" docstring (`:20-22`) advertises three
closure theorems that **do not exist as declarations anywhere in the tree**. Do not read that
module's sorry-count as progress.

**`buildRight` is Prop 3.5 verbatim.** Compare `ExistsForallNF.lean:285-296` with the paper (p.5):
`A_k ∧ (B_{k+1}Until(A_{k+1} ∧ (B_{k+2}Until⋯(A_n ∧ (B_n Until(A_n ∧ □B_{n+1}))))))`, plus the
Since mirror. This is the dispatch's "anchor recovery by nesting Until/Since" — **it exists and is
correct**. The repo is not missing Prop 3.5.

---

## 4. Can the closure be discharged at arity 1? — the (a)/(b) determination (Q3)

**Answer: NEITHER (a) nor (b) as posed. The premise of the question is misplaced, and the
correction is good news for the project.**

### 4.1 Lemma 3.2(2) is not where the difficulty is

The coordinator's framing assumed Lemma 3.2(2)'s absent proof might conceal real difficulty.
Reading pp. 4–13 settles this: **it does not, because Rabinovich's difficulty is quarantined in
Proposition 4.2, which he proves in full.**

The architecture of the paper's §§3–5:

| Step | Page | Role | Printed proof? |
|---|---|---|---|
| Lemma 3.2(1) — conj closure | p.4 | easy closure | "It is clear that" |
| **Lemma 3.2(2) — ≤2 free vars** | p.4 | **the arity-cap enforcer** | **"It is clear that" — none** |
| Lemma 3.2(3) — `∃x φ` closure | p.4 | collapses arity back down | "It is clear that" |
| Lemma 3.4 — ∨∃⃗∀ closure | p.5 | by 3.2(1)+(3) | ✅ 1 line |
| Prop 3.5 — **1 free var → TL** | p.5 | the arity-1 cap | ✅ printed |
| **Prop 4.2 — negation closure at ≤2 free vars** | p.6 | **THE hard step** | ✅ **§5, pp. 7–13 (6 pages)** |
| Prop 4.3 — FO → ∨∃⃗∀ | p.6 | structural induction | ✅ printed |
| Thm 4.4 — Kamp | p.6 | assembly | ✅ 3 lines |

**Prop 4.2 is stated only for ≤2 free variables.** That is *why* Lemma 3.2(2) exists: it is the
enabling step that brings arbitrary formulas into Prop 4.2's domain. The two are a matched pair,
and the paper spends its entire §5 on the hard one.

### 4.2 Why Lemma 3.2(2) is genuinely routine — and Rabinovich demonstrates the technique

Def 3.1's body is a conjunction of conditions each localized to a point `x_j` or an open interval
`(x_{j-1}, x_j)`. The free variables sit *at* known positions in the chain (their relative order
is fixed by `i_0..i_m`). Splitting the chain at the free variables yields segment formulas over
**pairwise disjoint intervals glued at shared endpoints** — so the per-segment existential
witnesses cannot interfere, and the merge is free. That is precisely the merge the repo's
`Lemma32Reduction.lean:290-306` found impossible *for arbitrary pairs over a structureless
Hintikka type* — the interval structure is what makes it work, and the repo's encoding discarded
it.

**Rabinovich prints this exact construction on p. 7** (proof of Prop 4.2, case `k ≠ m`). He splits
`ψ(z_0,z_1)` into a conjunction of:

1. `ψ_0(z_0)` — the segment `x_0..x_m` plus everything before `x_0` (**one** free variable);
2. `ψ_1(z_1)` — the segment `x_k..x_n` plus everything after `x_n` (**one** free variable);
3. `φ(z_0,z_1)` — the middle segment `x_m..x_k` (**two** free variables).

and observes:

> The first two formulas are ∃⃗∀-formulas with **one free variable**. Therefore, (by Proposition
> 3.5) they are equivalent to *TL*(Until, Since) formulas (in the signature E[Σ]). Hence, their
> negations are equivalent (over the canonical expansions) to **atomic** (and hence to ∃⃗∀)
> formulas.

This is the whole mechanism in two sentences: **split at the anchors → one-free-variable pieces →
Prop 3.5 → TL formula → absorb into the signature as an E[Σ]-atom (Def 4.1, p.5) → arity is back
to 0 for that piece.** Arity never grows because one-variable pieces keep getting *eaten by the
signature*.

⚠️ **Confidence flag (Medium-High, not High).** p.7's construction is the `m = 1` instance,
executed inside Prop 4.2's proof. Lemma 3.2(2)'s general case (`m+1` free variables → ≤2) is the
same split iterated at each consecutive pair. That generalization is **my reconstruction**, not
Rabinovich's printed text — he genuinely leaves 3.2(2) unproved. What would settle it: transcribe
Def 3.1 as a Lean type and attempt the consecutive-pair split. I judge it routine; I have not
proved it.

### 4.3 The honest bottom line on novel mathematics

- **Lemma 3.2(2)**: unproved in the source, but routine, and the source demonstrates the
  technique at `m=1` on p.7. **Not novel mathematics.** Case (a).
- **Prop 4.2**: the genuinely hard step — and **fully printed**, §5 pp. 7–13 (Lemma 5.1,
  Notation 5.2, Lemma 5.3, Cor 5.4, incl. the Dedekind "anchor factory" `INF(z_0,r_0,z_1,P_1)` at
  p.8 eq. 5.2). **Not novel mathematics — it is 6 pages of transcription.** Substantial, but
  bounded and printed.
- **The project's difficulty is not mathematical. It is that the faithful path was archived
  (task 302) and a divergent encoding was built in its place.**

Report 07's "Dedekind = anchor factory, not model filter" reading is **confirmed** at p.8:
`r_0 := inf{z ∈ (z_0,z_1) | P_1(z)}` *"(such r_0 exists by Dedekind completeness)"* and *"r_0 is
definable by the following ∨∃⃗∀ formula"* (eq. 5.2). Note `INF(z_0,r_0,z_1,P_1)` transiently has
three free points — and is immediately brought back to two by `(∃r_0)^{<z_1}_{>z_0}(…)` (p.8,
clause 3) via Lemma 3.2(3). **This is the arity discipline in miniature: transient growth under an
existential, immediate collapse. Arity 4 appears nowhere in the paper's 16 pages.**

---

## 5. Blast radius (Q4)

Traced at **proof-term granularity** against the built `.olean` environment (walking
`ConstantInfo.type ++ value |>.getUsedConstants` transitively) — not by grep or imports. All four
roots (`nf_nvar_exist_all_depths`, `nf_characterizable_temporal_prior`,
`kamp_prior_expressive_completeness`, `completeness_discrete`) agree exactly.

> **Independent convergence (strong corroboration).** This trace was run for *this* report. A
> **separate, independently-executed** proof-term walk from the task-374 research session
> (`specs/374_retire_kampprior_519_522_residual_arms/reports/01_m2-asset-sufficiency-adjudication.md`)
> reached **identical** conclusions on every quantitative claim below: the 11-file / 13,737-line
> load-bearing tier, the 39-file / 33,596-line reclaimable tier, the zero-consumer result for the
> arity-4 stack, the `endInterval_correct` arity-1 re-bucketing, and the shared-declaration
> `sorryAx` finding. Two independent traces agreeing raises confidence on §5 to **High**. Credit
> to the task-374 adjudication for reaching several of these first; I verified rather than
> inherited them.

### 5.1 The arity-4 `charFib` stack is 100% dead

| Probe declaration | Reachable from `completeness_discrete`? |
|---|---|
| `kampPrior_site_rungKFib_gate_match` (`KampPrior.lean:1058`) | **no** |
| `bracketEndChar_kvExtFib_correct_prior` (`ExteriorGateAssembleK.lean:559`) | **no** |
| `bracketEndChar_kvExtFib` | **no** |
| `bracketEndChar_kvFib_step_correct` (`InteriorGateGeneralK.lean:2311`) | **no** |
| `endInterval_correct` (`EndIntervalConsumerK.lean:268`) | **no** |
| `kampArm_past_k0`/`_k1`, `kampPrior_case1_arm_k0`/`_k1` | **YES** |

Reachable decls matching `kvExt`/`endInterval`: **0**. Matching `Fib`: 7 — all false-positive
substring hits on "**Fib**er" (`extZoneFiber_k1`, `extZoneFiberFut_k1`, 5 private `ext3_zs_ext`
sub-terms). None is `charFib` machinery.

### 5.2 But "NfMultiAnchorBridge is dead" would be FALSE

| Tier | Files | Lines | % |
|---|---|---|---|
| **Proof-term reachable** from `completeness_discrete` | 11 | 13,737 | 29% |
| Compiled but proof-term-dead (in aggregator import closure) | 23 | 27,167 | 57% |
| Orphaned (imported by nothing) | 16 | 6,429 | 14% |

**Reachable (load-bearing, 11)**: `Base`, `CarrierK1V`, `CarrierKv`, `PriorInterface`,
`ExteriorBracket`, `ExteriorFiberKitK1`, `ExteriorNavPastK1`, `ExteriorNavFutK1`,
`AggregateHookDischarge`, `AggregatePointMergeK1`, `AggregateOffDiagK1`. The load-bearing edge is
`KampPrior.lean:504-505` → `kampPrior_case1_arm_k0`/`_k1` → `kampArm_*` in
`AggregateHookDischarge.lean:1686,1708,1729,2087` and `AggregateOffDiagK1.lean:1456,1485`.

Genuinely dead: **39 files / 33,596 lines (71%)**. Largest single reclaimable item:
`SharedWitness.lean` (**12,800 lines**), compiled-but-proof-term-dead.

### 5.3 Report 06's dead-leaf claims — all three VERIFIED

| Declaration | Code consumers |
|---|---|
| `kampPrior_site_rungKFib_gate_match` | **0** ✅ |
| `bracketEndChar_kvFib_step_correct` | **0** ✅ |
| `endInterval_correct` | **0** ✅ |

Every non-definition hit is prose, individually inspected.

⚠️ **Correction to report 06's framing**: `endInterval_correct` is **not** arity-4 `charFib`
machinery. Its provider is `charF : (j : Nat) → NormalForm sig j 1 → Formula` — **arity 1**
(`EndIntervalConsumerK.lean:271`). It is dead, but it belongs to the arity-**1** `charF`/`kvExt`
stack. Deleting it under an "arity-4 charFib" banner would be mis-scoped.

⚠️ **`bracketEndChar_kvExtFib_correct_prior` is not a leaf** — it has exactly one consumer,
`KampPrior.lean:1173`. But that consumer is itself a dead leaf. The pair is a dead 2-node chain.

⚠️ **Deletion hazards** (import ≠ proof-term dependency): reachable files import dead ones
(`AggregateHookDischarge` → `EndIntervalConsumerK`; `ExteriorBracket` → `OuterGate`). Two *live*
files (`CarrierKv.lean:499-576`, `KampPrior.lean:1058-1181`) host dead `charFib` decls — these
need **surgical decl removal, not file deletion**.

### 5.4 The live sorries (`KampPrior.lean:519`, `:522`)

`KampPrior.lean` contains exactly two sorries; all 11 reachable bridge files are tactic-sorry-free.

- **`:519` — the ambient-`k≥2` arm (ON the critical path).** Goal:
  `∃ A, ∀ M h_UZ h_SZ t, temporal_truth M atomMap t A ↔ ∃ env : Fin 1 → M.carrier, nf_eval_nf M (_k+3) 2 (insertEnv env t) sub_nf`.
  Its in-source note (`:507-518`) gates it on the `hrealI`/`hrealB` anchor-content interface gap
  at `OuterGate:374/:380` and names the unblock path as the **arity-1** `charF`/`kvExt` gate stack.
- **`:522` — the `n+2` arm (OFF the critical path).** The main theorem only needs `n = 0, 1`.
  ⚠️ But both sorries live in the **same declaration**, so `sorryAx` **is** in
  `completeness_discrete`'s dependency closure regardless. Fixing `:519` alone will not make the
  chain sorry-free; `:522` must be discharged or the definition restructured.

### 5.5 "Zero consumers" — scaffolding, or unnecessary? (the decisive disambiguation)

Zero proof-term consumers is ambiguous on its own. It could mean **(i)** *not yet wired in* — an
uninstantiated certificate stack built to eventually discharge `:519`/`:522` — or **(ii)**
*unnecessary* — scaffolding for a design that should not exist. The task-374 adjudication raised
this subtlety and correctly declined to resolve it from reachability alone. **It is resolvable,
and it resolves to (ii).** Four independent lines, no one of which relies on the reachability
count:

1. **The intended discharge does not route through arity 4.** `:519`'s own in-source note
   (`KampPrior.lean:507-518`) names its unblock path as the **arity-1** `charF`/`kvExt` gate stack
   (`kampPrior_site_rung2_gate_match` / `kampPrior_site_rungK_gate_match` + the Phase-16
   `ExistProviders` shim). Not `charFib`. Corroborated by the `endInterval_correct` re-bucketing:
   the very lemma the note leans on has an **arity-1** provider
   (`charF : (j : Nat) → NormalForm sig j 1 → Formula`, `EndIntervalConsumerK.lean:271`). So the
   arity-4 stack is not the scaffolding for `:519` — a *different*, arity-1 stack is.

2. **The arity-4 seam is machine-refuted, so it could never be wired in.** Scaffolding is
   provisionally unwired; a **refuted** hypothesis is permanently unwireable. Three independent
   sorry-free refutations: `anchorMove_refutes_any_charEngine` (report 06 — *every* engine at
   arity 4); `seamPair_joint_refutation_int` (`SeamPairRefutationProbe.lean:145` — concrete ℤ, no
   automorphism, verified axiom-clean by me in §7); and `charSeam_forces_slot_locality` (this
   report — every arity with a free non-slot anchor). Wiring `charFib` in would make the chain
   inconsistent, not complete.

3. **The source has no arity-4 counterpart in 16 pages.** Def 3.1 (p.4) caps α_j/β_j at *"one
   variable"*; Def 4.1 (p.5) caps E[Σ] atoms at *"unary"*; Prop 3.5 (p.5) translates only at *"one
   free variable"*; Prop 4.2 (p.6) is stated only at *"at most two free variables"*. Rabinovich's
   sole excursion above 2 — `INF(z_0,r_0,z_1,P_1)` (p.8 eq. 5.2) — is collapsed back by `∃r_0` in
   the same display. Per the binding faithfulness constraint, a construction with no source
   counterpart is presumptively wrong; here the presumption is confirmed by (2).

4. **`charFib` was never instantiated in ~47k lines and ~20 tasks.** All 250 occurrences across 7
   files are binders. A genuine scaffold accretes toward instantiation; this one accreted for
   tasks 309→376 without a single supplier, because (2) guarantees none exists.

**Conclusion: (ii).** The arity-4 stack is scaffolding for a design that should not exist. This
is the report's central claim, and it does **not** rest on the reachability count — reachability
merely makes it cheap to see.

**Answer to Q4**: the arity-4 bridge is load-bearing for **nothing**, and could not become
load-bearing. But the surrounding directory is 29% load-bearing, so the bridge cannot be removed
by deleting the directory.

---

## 6. The compiled probe

`reports/08_arity4-necessity-probe.lean` — built green against the real production context
(`lake build`, 1053/1053), all theorems **sorry-free and axiom-clean** (`propext`,
`Classical.choice`, `Quot.sound`; **no `sorryAx`**).

**`charSeam_forces_slot_locality`** — the arity-general obstruction. For ANY arity `n`, ANY depth
`k`, ANY engine `char : NormalForm sig k n → Formula`, ANY slot:

```lean
theorem charSeam_forces_slot_locality {sig : MonadicSignature} {k n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (char : NormalForm sig k n → Formula) (slot : Fin n)
    (hchar : ∀ (σ : NormalForm sig k n) (env : Fin n → M.carrier),
      temporal_truth M atomMap (env slot) (char σ) ↔ nf_eval_nf M k n env σ) :
    ∀ (σ : NormalForm sig k n) (env env' : Fin n → M.carrier),
      env slot = env' slot →
      (nf_eval_nf M k n env σ ↔ nf_eval_nf M k n env' σ) := by
  intro σ env env' hslot
  rw [← hchar σ env, ← hchar σ env', hslot]
```

The engine is universally quantified and never destructured: a `Formula`'s truth at a point is a
function of that point alone, so it cannot see `env` anywhere but `slot`. This is the
arity-general form of `endCharN0_correct_world_local_obstruction` (`Base.lean:1839`).

- **`arity1_slot_locality_is_vacuous`** — at arity 1 the forced consequence is trivially true
  (`Fin 1` is a subsingleton, so `env slot = env' slot → env = env'`). **No obstruction at arity 1.**
  This is why `nf_characterizable_temporal_prior` is green — and it is exactly Rabinovich Prop 3.5's
  one-free-variable cap (p.5).
- **`free_pos_ge2_slot_locality_has_content`** — with ≥2 free positions the consequence is a real,
  falsifiable constraint, and `endCharN0_correct_infeasible` (`Base.lean:1873`) exhibits a concrete
  model (`Mcex` over `Bool`) refuting it.
- **Two `example`s** that elaborate against production types, pinning the live chain at arity 1 and
  its step at arity 2.

### 6.1 Scope correction this probe forced on itself (adversarial finding)

**The refuted object is NOT "arity 4" as such.** `zoneEnv3_arity_invariant` (`Base.lean:543-553`,
sorry-free) certifies that in `nf_char3_deeper_split` (`Base.lean:603`) the arity-4 env
`[w, y, x, t]` has `w` **bound** by the enclosing `∃ w`:
`Fin.tail (Fin.cons w (zoneEnv3 y x t)) = zoneEnv3 y x t`. **Under an existential, a high-arity env
is faithful** — it is `nf_eval_nf`'s own `succ` clause, and it is Rabinovich Lemma 3.2(3) (p.4)
that licenses collapsing it back. This mirrors `INF`'s transient third point at p.8.

What is refuted is a **seam with FREE non-slot positions**: `charFib`'s seam
`∀ w, render w → ∀ σ u, truth u (charFib σ) ↔ nf_eval [u,w,x,t] σ` leaves `w, x, t` **free**
parameters of the seam. That is what `charSeam_forces_slot_locality` kills.

⚠️ Consequently `Lemma32Reduction.lean:56-57`'s claim that `nf_char3_deeper_split` *"GROWS anchors
to arity-4, the exact failure mode"* is **imprecise and contradicted by `zoneEnv3_arity_invariant`
in the same file's own dependency**. The free-anchor set stays `{x,t}` = 2 across that step. This
does not change the verdict, but a future dispatch must not delete arity-4 code on the strength of
that sentence.

---

## 7. Residual closed: the one unverified link

Report 07's route-C adjudication inherited report 06's unchecked claim about
`seamPair_joint_refutation_int` (`SeamPairRefutationProbe.lean:145`). **Independently verified:**

- `lean_verify` → axioms exactly `[propext, Classical.choice, Quot.sound]`, **no `sorryAx`**, no warnings.
- The file has **0 sorries**.
- Carrier is concrete **ℤ** (`spQnf_render` discharges `(0:ℤ) < 1`, `(1:ℤ) < 2`, `¬((2:ℤ) < 1)`, …);
  anchors `0` and `2`, witness `1`. No automorphism is invoked.
- It derives `False` from the seam pack alone, for **every** `charFib` family and **every** `atomMap`.
- Its `hcharFib` binder matches `KampPrior:1073` exactly.

**Report 06's claim stands. Report 07's route-C adjudication is sound on this link.** ✅

---

## 8. H3 Reference-grounding map (Tier 1 — literature)

| Source | Prop / Location | Lean Identifier | Type Signature | Status |
|---|---|---|---|---|
| Rabinovich 2014 | Def 3.1, p.4 (∃⃗∀ shape: ordered prefix + α_j point types + β_j interval types) | `IntervalPattern` | `structure IntervalPattern (n : Nat)` (`ExistsForallNF.lean:93`) | **PARTIAL** — structure exists; ordered-prefix + α/β conjunct layer not assembled |
| Rabinovich 2014 | Def 3.1, p.4 (α_j, β_j *"quantifier free … one variable"*) | `TemporalPred` | `structure TemporalPred` (`ExistsForallNF.lean:49`) | ✅ **FAITHFUL** — one-variable by construction |
| Rabinovich 2014 | Def 3.1, p.4 (ordering/equality conjuncts) | `ZoneSpec` | `ZoneSpec (n) : Type := Fin n → Bool × Bool` (`NfEFold.lean:44`) | ✅ **FAITHFUL** |
| Rabinovich 2014 | **Lemma 3.2(1), p.4** (conj closure) | `VEF.closed_conj` | *advertised* `ExistsForallNF.lean:21` | ❌ **ABSENT** — docstring only, no declaration |
| Rabinovich 2014 | **Lemma 3.2(2), p.4** (≤2 free vars — no printed proof) | *(none)* | — | ❌ **ABSENT** — `nfEval_le2_reduction` (`Lemma32Reduction.lean:535`) is **misnamed**: atom-layer factoring only, caps nothing; module orphaned |
| Rabinovich 2014 | **Lemma 3.2(3), p.4** (`∃x φ` closure — the arity collapse) | `VEF.closed_ex` | *advertised* `ExistsForallNF.lean:22` | ❌ **ABSENT** — docstring only |
| Rabinovich 2014 | Lemma 3.4, p.5 (∨∃⃗∀ closure) | `VEF.disj` / `disj_holds` | `ExistsForallNF.lean:251,254` | **PARTIAL** — disj only |
| Rabinovich 2014 | **Prop 3.5, p.5** (1 free var → TL, via nested Until/Since) | `buildRight`/`buildLeft`/`translateEF1` | `ExistsForallNF.lean:285,298,311` | ✅ **FAITHFUL & PROVED** (`buildRight_correct`, `buildLeft_correct`, `VecEATranslation.lean:213,481`) |
| Rabinovich 2014 | Def 4.1, p.5 (E[Σ] signature expansion) | `atomMap`/`h_surj`; `EAtomDom` | `Formula → sig.preds` + surjectivity; `ZoneSpec n × NormalForm sig k 1` (`NfEFold.lean:69`) | **PARTIAL** — `EAtomDom` keeps depth `k` instead of folding it into the signature; backs off to full arity `n+1` at `k≥1` (`NfEFold.lean:551-563`) |
| Rabinovich 2014 | **Prop 4.2, p.6 + §5 pp.7–13** (negation closure at ≤2 free vars) | `VEF.closed_neg` | — | ❌ **ABSENT** — archived task 302 (`Boneyard/KampNegationClosure/NegationClosure.lean`, 7 sorries) |
| Rabinovich 2014 | Lemma 5.1 / 5.3 / Cor 5.4, pp.7–9 | *(none)* | — | ❌ **ABSENT** |
| Rabinovich 2014 | p.8 eq. 5.2 (`INF`, Dedekind anchor factory) | *(none)* | — | ❌ **ABSENT** |
| Rabinovich 2014 | Prop 4.3, p.6 (FO → ∨∃⃗∀ structural induction) | *(none)* | — | ❌ **ABSENT** |
| **NO SOURCE** | — | **`charFib`** | `(j : Nat) → NormalForm sig j 4 → Formula` (`KampPrior.lean:1061`) | 🔴 **NO COUNTERPART IN 16 PAGES** — never instantiated; 100% proof-term dead; refuted by report 06 + `seamPair_joint_refutation_int` |
| **NO SOURCE** | — | `nf_eval_nf` arity growth `n → n+1` | `NormalForm.lean:198-207` | 🔴 **DIVERGENT** — Rabinovich never grows arity (`NfEFold.lean:16-19`) |

---

## 9. Recommendation (Q5)

### 9.1 Task 376 should be ABANDONED as scoped

Its goal ("build ONE arity-general, zone-decomposed char/provider engine") asks for an object that
is machine-refuted at every arity with a free non-slot anchor (`charSeam_forces_slot_locality`;
report 06's `anchorMove_refutes_any_charEngine`; `seamPair_joint_refutation_int` in concrete ℤ),
that has **no counterpart in Rabinovich's 16 pages**, and that is **load-bearing for nothing**.
Routes A/B/C are all moot: A and C are refuted, and B ("change the signature") has the right
instinct but the wrong target — the signature to change is **`nf_eval_nf`'s**, not `charFib`'s.

### 9.2 Replacement task — framed as TRANSCRIPTION, not design

> **Title**: Transcribe Rabinovich §§3–5 faithfully: Def 3.1 ∃⃗∀ type + Lemma 3.2 + Prop 4.2

**Definition of Done** — acceptance criteria are the paper's own constructions and page cites:

1. **Def 3.1 (p.4)** transcribed as a Lean type carrying all four channels: ordered existential
   prefix `x_n > … > x_0`; dummy equations `z_k = x_{i_k}`; α_j point types (`TemporalPred`,
   reuse `ExistsForallNF.lean:49`); β_j interval types on `(x_{j-1}, x_j)` plus the two end
   conditions. Reuse `IntervalPattern` (`:93`) and `ZoneSpec` (`NfEFold.lean:44`).
   *Acceptance*: the type admits no slot for a joint `(n+1)`-ary sub-evaluation — the arity cap is
   a **type-level invariant**, as `NfEFold.lean:26` already argued.
2. **Lemma 3.2(1) (p.4)** — `VEF.closed_conj`. *Acceptance*: stated and proved (currently
   advertised-only at `ExistsForallNF.lean:21`).
3. **Lemma 3.2(3) (p.4)** — `VEF.closed_ex`. *Acceptance*: stated and proved (currently
   advertised-only at `:22`). This is the arity-collapse step (cf. `INF`'s `∃r_0`, p.8).
4. **Lemma 3.2(2) (p.4)** — the ≤2-free-variable cap, by splitting the chain at consecutive free
   variables into disjoint interval segments glued at shared endpoints. *Acceptance*: proved
   sorry-free. **Follow the p.7 pattern** (`ψ ≡ ψ_0(z_0) ∧ ψ_1(z_1) ∧ φ(z_0,z_1)`), generalized to
   `m+1` free variables. **This is the one step with no printed proof — attempt it FIRST as the
   feasibility gate.** If it does not close in one dispatch, that is the (b)-signal the coordinator
   asked about and must be escalated immediately.
5. **Prop 4.2 (p.6) via §5 (pp. 7–13)** — Lemma 5.1, Notation 5.2, Lemma 5.3, Cor 5.4, incl. the
   Dedekind anchor factory `INF(z_0,r_0,z_1,P_1)` (p.8 eq. 5.2). *Acceptance*: `VEF.closed_neg`
   sorry-free. **Six pages of printed proof — transcription, not invention.** Un-archive
   `Boneyard/KampNegationClosure/NegationClosure.lean` for salvage.
6. **Prop 4.3 (p.6)** structural induction, then **Thm 4.4 (p.6)**, reusing the already-correct
   Prop 3.5 machinery (`buildRight_correct`/`buildLeft_correct`).

**Sizing**: step 4 is one dispatch (the gate). Step 5 is the bulk — plan ≥4 phases, one per
paper lemma (5.1 / 5.3 / 5.4(1) / 5.4(2) / assembly).

### 9.3 Explicit non-goals, and cleanup cautions if a reclaim task is opened

- **Do NOT delete `NfMultiAnchorBridge/` wholesale** — 11 files / 13,737 lines are load-bearing for
  `completeness_discrete` via `kampArm_*_k0/k1`. Dead code is not urgent; **building more of it is
  the thing to stop.**
- **Do NOT attempt another `charFib`-shaped seam.** Four reports have now refuted it.
- **Any reclaim is a SEPARATE, LATER task.** Cautions below are adopted from the task-374
  adjudication (attributed; I verified (a) and (d), and mark (c) as inherited):
  - **(a) Surgical decl excision, not file deletion** — `CarrierKv.lean` (`bracketEndChar_kvFib`
    `:576`, `kvFib_body` `:499-554`) and `KampPrior.lean` (`kampPrior_site_rungKFib_gate_match`
    `:1058-1181`) are **live files hosting dead decls**. ✅ verified.
  - **(b) Frozen byte-identity surfaces sit inside those same live files** (`CarrierKv:240-249`;
    rfl bridges `IGGK:339-351` / `CarrierKv:294-351`). ⚠️ **inherited, not verified by me** —
    re-check before any excision.
  - **(c) The task-374 caution "do NOT delete the `*Fib` sibling chain while task 376 is open — it
    is the designated re-signature surface"** is **superseded if §9.1 is accepted.** That caution
    presumes task 376 survives and will re-signature the `*Fib` chain. This report recommends
    abandoning that scope, which retires the reason to preserve the chain. **Do not act on either
    reading until the human rules on §9.1** — the two are coupled.
  - **(d) Safe first targets**: the 16-file / 6,429-line orphan tier (zero importers) and
    `SharedWitness.lean` (12,800 lines, compiled-but-proof-term-dead). ✅ verified. But
    **import edges ≠ proof-term edges**: `NfMultiAnchorBridge.lean` directly imports 21 modules
    including dead ones, and live files import dead ones (`AggregateHookDischarge` →
    `EndIntervalConsumerK`; `ExteriorBracket` → `OuterGate`). Removal needs import surgery.

### 9.4 The `existF` all-arity constraint — a finding, not an action

The dispatch's standing constraint ("do not restate `nf_nvar_exist_all_depths` to `n ≤ 1`;
`ExistProviders.existF` is all-arity, `P.existF 4` consumed at 38 sites") was, as the dispatch
itself anticipated, **set when the arity-4 design was assumed correct**. Reporting as a finding,
not acting on it:

`nf_nvar_exist_all_depths`'s all-arity signature is **itself part of the infidelity**. Rabinovich
has no all-arity existential-elimination lemma; he has Lemma 3.2(3) at ≤2 free variables, applied
after Lemma 3.2(2) has capped the arity. The repo's `existF 4` sites exist *because* nothing caps
arity upstream. The `:522` sorry (`n+2` arm) is the direct cost: it is off the critical path but
still poisons `completeness_discrete` with `sorryAx`, because it shares a declaration with `:519`.

Under a faithful Def 3.1 encoding the `n ≥ 2` arm would not exist to be sorried. **I have not acted
on this and recommend no action until the Def 3.1 type of step 1 exists** — at which point the
question answers itself.

---

## Adversarial Self-Verification

Attacking hardest the conclusion that a large existing subsystem is unnecessary — the most
expensive possible error.

| Claim | Source/Counterexample |
|---|---|
| The arity-4 `charFib` stack is proof-term dead | **VERIFIED, High.** Declaration-level trace of the built `.olean` env from 4 roots, walking `ConstantInfo.type ++ value |>.getUsedConstants` transitively; all 4 agree. Reachable `kvExt`/`endInterval` decls: 0. 7 `Fib` hits all false-positive on "Fi**b**er". Not a grep. |
| **ATTACK (the decisive one, raised by the task-374 adjudication): "proof-term dead ≠ unnecessary" — it may be scaffolding not yet wired in** | **REBUTTED, High — full argument in §5.5.** Four independent lines, none relying on reachability: (1) `:519`'s own note (`KampPrior.lean:507-518`) names an **arity-1** unblock path, and `endInterval_correct`'s provider is arity-1 (`EndIntervalConsumerK.lean:271`) — a *different* stack is the scaffolding for `:519`; (2) the arity-4 seam is refuted three times over (report 06; `seamPair_joint_refutation_int` in concrete ℤ, axiom-clean per §7; `charSeam_forces_slot_locality`) — a refuted hypothesis is permanently unwireable, not provisionally unwired; (3) no arity-4 counterpart in 16 pages, and Rabinovich's one excursion above 2 (`INF`, p.8) is collapsed by `∃r_0` in the same display; (4) never instantiated across ~47k lines and ~20 tasks. |
| **ATTACK: my §5 numbers might be an artifact of one tool/one agent** | **REBUTTED, High.** An **independently executed** proof-term walk from the task-374 session reached identical results on every quantitative claim (11/13,737; 39/33,596; zero arity-4 consumers; `endInterval_correct` arity-1; shared-declaration `sorryAx`). Two independent traces converging. |
| **ATTACK: "`charFib` is never instantiated" may be a grep artifact — maybe it's instantiated via a `let`/`obtain`** | **REBUTTED, High.** Two independent methods agree: (a) all 250 occurrences across 7 files are syntactic binders; (b) the proof-term trace finds **zero** reachable `charFib` decls from `completeness_discrete`. If it were instantiated on the live path the trace would show it. |
| **ATTACK: "NfMultiAnchorBridge is redundant" — the expensive error** | **I DO NOT CLAIM THIS. Refuted my own draft framing.** 11 files / 13,737 lines (29%) ARE load-bearing via `KampPrior.lean:504-505` → `kampPrior_case1_arm_k0/_k1` → `kampArm_*` (`AggregateHookDischarge.lean:1686,1708,1729,2087`; `AggregateOffDiagK1.lean:1456,1485`). §9.3 explicitly forbids wholesale deletion. |
| **ATTACK: "arity 4 is the defect"** | **REFUTED MID-DISPATCH — my own overclaim, corrected.** `zoneEnv3_arity_invariant` (`Base.lean:543-553`, sorry-free) proves arity-4 envs under `∃w` keep FREE anchors at 2. Probe §6.1 and the header were rewritten. The defect is **free non-slot anchors in a seam**, not raw arity. Rabinovich does the same transient growth at p.8 (`INF`'s `r_0`). |
| `charSeam_forces_slot_locality` refutes every engine at ≥2 free positions | **VERIFIED, High.** Compiled, sorry-free, axiom-clean (no `sorryAx`). Engine universally quantified, never destructured. Consistent with `endCharN0_correct_world_local_obstruction` (`Base.lean:1839`) which the sub-trace verified independently with the same axiom set. |
| The live chain needs only arity ≤ 2 | **VERIFIED, High.** Two probe `example`s ELABORATE against production types. Corroborated by `KampPrior.lean:597` and the internal recursion at `:407`, both `n = 1`. |
| Lemma 3.2(2) is genuinely routine (case (a)) | **MEDIUM-HIGH — flagged in §4.2 and not upgraded.** p.7 prints the technique at `m=1` only; the `m+1` generalization is **my reconstruction**. Rabinovich genuinely leaves 3.2(2) unproved. Settling move: step 4 of §9.2 as the explicit feasibility gate, with escalation if it does not close. |
| The paper's hard step is Prop 4.2, and it is fully printed | **VERIFIED, High.** §5 spans pp.7–13 (Lemma 5.1, Notation 5.2, Lemma 5.3, Cor 5.4). Prop 4.2 stated on p.6 restricted to *"at most two free variables"* — which is exactly what Lemma 3.2(2) supplies. Read directly from the PDF. |
| `ExistsForallNF.lean` is a faithful Def 3.1 transcription with closures proved | **REFUTED MID-DISPATCH — my own near-overclaim.** `VEF.closed_conj`/`closed_ex`/`closed_disj` are **advertised at `:20-22` and never defined** anywhere in the tree. Its 0-sorry count reflects **unstated** theorems. Caught by grepping for declarations rather than trusting the "Main Results" docstring. §3.1 now carries the flag. |
| `buildRight`/`buildLeft` are Prop 3.5 and are proved correct | **VERIFIED, High.** `ExistsForallNF.lean:285-309` matches p.5's nesting verbatim; `buildRight_correct`/`buildLeft_correct` consumed at `VecEATranslation.lean:213,481`. |
| `seamPair_joint_refutation_int` refutes in concrete ℤ, zero residual (report 07's open link) | **VERIFIED, High — link CLOSED.** `lean_verify`: axioms `[propext, Classical.choice, Quot.sound]`, no `sorryAx`, no warnings. File has 0 sorries. Carrier ℤ (`(0:ℤ)<1` etc.), anchors 0/2, witness 1, no automorphism. |
| `Lemma32Reduction.lean:56-57`'s "GROWS anchors to arity-4" rationale | **CONTRADICTED, High.** Flagged in §6.1. Contradicted by `zoneEnv3_arity_invariant` in its own dependency. Verdict unaffected, but future dispatches must not delete on that sentence's strength. |
| Report 06's three dead-leaf claims | **VERIFIED, High** — 0 code consumers each; every other hit inspected and confirmed prose. ⚠️ One framing correction: `endInterval_correct` is arity-**1** `charF` machinery, not arity-4. |
| **UNVERIFIED (residual)**: that a faithful Def 3.1 path actually closes `completeness_discrete` | **NOT VERIFIED — stated as risk, not fact.** I traced what the chain does *not* need (arity 4) and what the paper *does* provide (§§3–5). I did **not** prove a faithful transcription suffices end-to-end. §9.2 step 4 is the cheap gate that tests this before the §5 investment. |
| `sorryAx` is reachable from `completeness_discrete` (both `:519` and `:522` poison the chain) | **VERIFIED, Medium-High.** Confirmed by the sub-trace's proof-term walk over the built `.olean` env. The `:519`/`:522` shared-declaration argument is independently sound on inspection of `KampPrior.lean:480-525`. I did not personally re-run `#print axioms completeness_discrete`; the delegated verification used the same method that correctly predicted the arity-4 reachability results I did check. |

**Contradiction Log**

1. `Lemma32Reduction.lean:56-57` ("`nf_char3_deeper_split` GROWS anchors to arity-4, the exact
   failure mode") **vs** `zoneEnv3_arity_invariant` (`Base.lean:543-553`, sorry-free: free anchors
   stay `{x,t}`). **Resolved** by precedence: a compiled sorry-free theorem outranks a docstring
   rationale. The docstring is imprecise. Recorded in §6.1; verdict unaffected.
2. `NfEFold.lean:10-11` ("Nothing in the existing development imports this file, so it is off the
   live path") **vs** 5 bridge modules importing it today. **Resolved**: the docstring is stale
   (written at task 310; imports added at task 349). Does not affect the verdict — the *fix*
   NfEFold proposed was never adopted regardless of who imports the file.
3. `ExistsForallNF.lean:20-22` ("Main Results: `VEF.closed_disj`/`closed_conj`/`closed_ex`") **vs**
   the declaration list showing none exist. **Resolved**: docstring overstates the module.
   Recorded as an honesty flag in §3.1 — materially changes the size estimate of the faithful path
   (three closures must be *proved*, not merely wired).

**No unresolved contradictions.**

---

## Memory candidates

1. *(discovery)* In BimodalLogic, `charFib : (j : Nat) → NormalForm sig j 4 → Formula` is never a
   definition — all 250 occurrences across 7 files are binders, and a proof-term trace of the built
   `.olean` env from `completeness_discrete` reaches **zero** arity-4 `charFib` declarations. The
   live chain (`nf_characterizable_temporal_prior`, `KampPrior.lean:565`) consumes
   `NormalForm sig k 1` and steps via `NormalForm sig k 2` only. Arity 4 is `nf_eval_nf`'s `n→n+1`
   growth (`NormalForm.lean:198-207`) observed 3 descents down — not a design choice, and load-bearing
   for nothing. Before ANY further work on an arity-4 seam, run the proof-term trace: import-level and
   grep-level reachability both mislead here (57% of `NfMultiAnchorBridge/` is compiled-but-dead).

2. *(pattern)* **A characteristic-`Formula` engine is possible iff every non-slot position is bound.**
   `truth (env slot) (char σ) ↔ nf_eval M k n env σ` forces `nf_eval` to factor through `env slot`
   (proof: `rw [← hchar σ env, ← hchar σ env', hslot]`) — vacuous at arity 1 (`Fin 1` subsingleton),
   refuted at ≥2 free positions. Raw arity is NOT the criterion: a high-arity env under an `∃` is
   fine (`zoneEnv3_arity_invariant`, `Base.lean:543-553`), matching Rabinovich's own transient
   `INF(z_0,r_0,z_1,P_1)` at p.8 collapsed by `∃r_0` (Lemma 3.2(3)). The invariant is **free**
   non-slot anchors. Corresponds to Rabinovich Prop 3.5's one-free-variable cap (p.5).

3. *(pattern)* **A module's sorry-count measures nothing if the hard theorems were never stated.**
   `ExistsForallNF.lean` advertises `VEF.closed_conj`/`closed_ex`/`closed_disj` in its "Main Results"
   docstring (`:20-22`); none exists as a declaration anywhere in the tree, and the file reports 0
   sorries. When assessing formalization progress against a literature source, grep for
   **declarations**, never trust the module docstring's claims list.
