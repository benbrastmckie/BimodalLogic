# Report 37 — Critical Audit of the `--hard` Verdicts (Task 305)

- **Task**: 305 (rabinovich_ea_formula_implementation, lean4)
- **Type**: Critical re-audit (anti-hastiness pass over prior `--hard` strike/gate handoffs)
- **Session**: sess_1782336994_beee6d
- **Agent**: lean-research-agent (+ 2 parallel Explore sub-agents)
- **Date**: 2026-06-24
- **Method**: Lean-MCP probes at the live proof site (`KampPrior.lean:391`), verbatim reading of the
  Rabinovich (2014) source, and ground-truth signature/grep sweeps. Each conclusion was
  adversarially re-checked before being committed.

---

## 1. Executive Summary

| Pillar | Verdict | Confidence | One-line justification |
|---|---|---|---|
| **P1 — "`merge_forward_succ` is a non-theorem"** | **SOUND (as a negative result) but the A′ rescue is HASTY** | **HIGH** | The standalone leaf genuinely is not a theorem; but A′'s premise that "in situ `sub_nf` is the model's characteristic NF" is **factually false** — `sub_nf` is universally quantified and fixed before `M` (`∃A,∀M`), so Obstruction 2 is **relabeled, not dissolved**, and the strict-order zones hit the same depth-(k+1) arity wall (MCP-confirmed type mismatch). |
| **P2 — "Route B is circular"** | **SOUND conclusion, HASTY reason** | **HIGH** | Route B is genuinely non-viable, but NOT because the bridge "reproduces `no_gaps_discrete_model_surgery`" (the obligations differ). The real reason is architectural: `US_expressively_complete_over_Z` is ℤ-locked and no bridge lemma exists; the `over_prior` version already does the job. |
| **P3 — "machinery diverged from Rabinovich"** | **SOUND (verdict still stands)** | **HIGH** | The `:391` obligation is the SAME NF-depth/arity-tower artifact reports 14/15 flagged — the sorry merely moved (`FOToVEA:118` → `KampPrior:154` → `KampPrior:391`) and was buried one recursion layer deeper. Rabinovich has no NF-depth parameter; his arity is capped at 2 by Lemma 3.2(2). |

**Net recommendation (see §6):** Route A′ as currently scoped is **not sound** — it will hit the
arity tower at the strict-order zones. The honest options are (b) re-open nothing on Route B (it is
dead) and (c) **step back to the faithful Rabinovich path** (repurpose ~700–1050 lines of mostly
existing sorry-free assets). The cheapest *correct* exit is the faithful path, not A′.

---

## 2. Pillar 1 — Local soundness of the "non-theorem" verdict (and the A′ rescue)

### 2.1 The actual goal at `KampPrior.lean:391` (MCP ground truth)

`lean_term_goal` at `391:7` returns (abridged), with `sub_nf : NormalForm sig (k+1) (1+1)` **already in
context** before any `M`:

```
⊢ ∃ A, ∀ (M : OrderedMonadicStructure sig),
    semantic_prior_UZ M atomMap → semantic_prior_SZ M atomMap →
      ∀ (t : M.carrier),
        temporal_truth M atomMap t A ↔
        ∃ env, nf_eval_nf M (k + 1) (1 + 1) (insertEnv env t) sub_nf
```

The binder order is decisive: **`A` and `sub_nf` are both fixed before `M` is introduced.** The
formula `A` must be **model-independent**, and `sub_nf` is an **arbitrary, universally-quantified
normal form**.

### 2.2 The strike-3 negative result is SOUND for the abstract leaf

Strike-3 (handoff `v35-phase-1-strike-3.md`) correctly establishes two obstructions to a standalone
`merge_forward_succ`:
- **Obstruction 1** (rename bridge needs bijectivity): verified against the actual code.
  `renameNF_eval_iff` (`NfDepth0Generalized.lean:440`) needs **both** sections `hsec : f∘r=id` and
  `hsec2 : r∘f=id` (lines 446–447); the merge map `skipFin j` is injective-not-surjective, supplying
  only `r∘f=id` (`totalUnskip_skipFin`, line 163). The `roundtrip` at line 564–566 in the `succ` case
  genuinely needs the missing section. **Confirmed correct.**
- **Obstruction 2** (quant `←` manufactures a witness): the depth-`(k+1)` quant layer of `nf_eval_nf`
  (`NormalForm.lean:203–207`) is `∀ sub_nf, (∃x, …) ↔ quant_assignment sub_nf = true`. The `←`
  direction `sub_nf.2 qnf = true → ∃ w, …` indeed has no hypothesis (for an *abstract* `sub_nf`)
  forcing the Bool assignment to be model-realized. **Confirmed correct** as a statement about the
  abstract leaf.

So as a **negative result about the standalone lemma**, strike-3 is sound. It is *not* an
over-generalization artifact: the leaf was scoped as a self-contained arity-merge lemma, and that
exact lemma is false.

### 2.3 The A′ rescue is HASTY — Obstruction 2 is relabeled, not dissolved

Report 36 (Route A′) rests on one load-bearing claim (36:30–37, restated 36:164–167):

> "At `KampPrior.lean:391`, `sub_nf : NormalForm sig (k+1) 2` is the characteristic NF of a concrete
> working structure `M` … There the `←` witness `w` is supplied by the model itself … The
> obstruction is dissolved, not worked around."

**This claim is false against the actual goal.** Evidence:

1. **`sub_nf` is universally quantified, not characteristic.** The term goal (§2.1) binds `sub_nf`
   before `M`. Tracing the consumer confirms it: `nf_characterizable_temporal_prior` (succ case,
   `KampPrior.lean:455–504`) sets `exist_tl_fn := nf_nvar_exist_all_depths_fn atomMap h_surj k 1`
   and requires it correct for **`∀ (sub_nf : NormalForm sig k 2)`** (line 470). And
   `nf_succ_char_formula` (line 116) maps `exist_tl_fn` over
   **`Finset.univ.toList : List (NormalForm sig k 2)`** — i.e. over **every** normal form of that
   type. There is no point in the live chain where `sub_nf` is instantiated to a model's
   characteristic NF. A′'s central premise contradicts the binder structure.

2. **The candidate single formula captures only the `x=t` zone.** Via `lean_multi_attempt`, the
   witness `⟨char_k1 (mergeNF_succ sub_nf 1 0), …⟩` **type-checks** against the goal (model-independent,
   as required). But semantically `char_k1 (mergeNF_succ sub_nf 1 0)` characterizes only the
   **diagonal** `nf_eval_nf M (k+1) 1 (fun _ => t) (mergeNF_succ sub_nf 1 0)` — the `x=t` collapse.
   It says nothing about witnesses `x ≠ t`. That is exactly why report 36 step (e) builds a **3-way
   disjunction** `A_lt ∨ A_eq ∨ A_gt`, not the merge formula alone.

3. **The strict-order zones hit the depth-(k+1) arity wall — MCP-confirmed.** The `x<t` / `x>t`
   disjuncts must express `∃ x (strictly ordered vs t), nf_eval_nf M (k+1) 2 (Fin.cons x …) sub_nf`
   — an existential over a **depth-(k+1)** arity-2 NF. The only existential engine in scope is
   `ih_exist_1` / `exist_tl_fn_k`, whose `lean_hover_info` signature is
   `… ↔ ∃ x, nf_eval_nf M **k** 2 (Fin.cons x …) sub_nf'` — **depth k, not k+1**. Attempting to feed
   the merge result to it fails with a hard type error (verbatim from `lean_multi_attempt`):

   ```
   Application type mismatch: the argument  mergeNF_succ sub_nf 1 0
   has type      NormalForm sig (k + 1) (0 + 1)
   but is expected to have type  NormalForm sig k 2
   ```

   The depth-(k+1) arity-2 NF's quant layer ranges over `NormalForm sig k 3` (arity 3;
   `NormalForm.lean:203–207` with `n=1` ⇒ `NormalForm k (2+1)`). **No arity-3 / depth-(k+1)
   existential converter exists** (grep over `Theories/.../Kamp/` for arity-3 engines returns
   nothing live). This is precisely the "arity tower" of reports 14/15, surfacing again.

**Adversarial check (did I refute my own conclusion?).** Could the strict zones be built without a
depth-(k+1) engine — e.g. by `mergeNF_succ` to arity 1 then `char_k1`, restricted to a zone via
Since/Until? No: `mergeNF_succ` is only correct on the **diagonal** (`mergeNF_succ_atom` is an
atom-layer statement; its quant correctness is exactly what strike-3 proved false abstractly). For
`x ≠ t` the merge does not preserve the quant layer, so `char_k1 ∘ mergeNF_succ` is the **wrong NF**
off the diagonal. Could a recursive self-call `nf_nvar_exist_all_depths … (k+1) 0` supply a
depth-(k+1) engine? No — the def recurses by `Nat.rec` on `k` (`KampPrior.lean:252`, matching
`| 0 | k+1`); a self-call at depth `k+1` does not structurally decrease and is not available as an
IH. **The refutation attempts fail; the conclusion holds.**

**Verdict P1: SOUND negative result; HASTY rescue.** The standalone leaf is genuinely a non-theorem
(HIGH). But A′'s justification ("the model supplies the witness because `sub_nf` is characteristic")
is **false** for the actual `∃A,∀M` obligation — Obstruction 2 reappears in the `←` direction of the
strict-order zones, and the depth-(k+1) arity-2 existential has **no converter**, reproducing the
arity tower. A′ "dissolves" the obstruction only in a verbal reframing, not in the Lean goal.

---

## 3. Pillar 2 — Route B "circular" verdict

(Ground-truth signature/grep sweep; full evidence in the sub-agent trace.)

### 3.1 The two theorems are over different structure types (verbatim)

- `US_expressively_complete_over_Z` (`ExpressiveCompleteness/Theorem.lean:357`) quantifies over
  `M : IntStructureFromSig sig` with **carrier hard-wired to `ℤ`** (`int_to_ordered` sets
  `carrier := Int`, `QuantifierElimination.lean:43`), truth predicate `Separation.int_truth`
  (`Separation/Defs.lean:42`, with the **degenerate** `.box _ ↦ True`), and `atomMap : sig.preds → Atom`
  chosen **by the theorem**.
- `US_expressively_complete_over_prior` (`PriorExpressiveness.lean:346`) quantifies over an
  **arbitrary** `M : OrderedMonadicStructure sig`, carrier `M.carrier`, truth predicate
  `temporal_truth` (non-degenerate `.box φ ↦ M.interp (atomMap (.box φ))`), with `atomMap` supplied
  by the **caller**.

### 3.2 The live call site holds an arbitrary discrete `M`

`invariant_formula_constant` inside `no_gaps_discrete_model_surgery`
(`GoodStructuresModelSurgery.lean:1259–1269`, enclosing sig at :2133) holds an **arbitrary**
`M : OrderedMonadicStructure sig` with only `[SuccOrder][PredOrder][NoMaxOrder][NoMinOrder]` and the
Prior hypotheses, and consumes `US_expressively_complete_over_prior … M h_prior_UZ h_prior_SZ`. It
never constructs `M.carrier ≃o ℤ`.

### 3.3 No bridge lemma exists; the only map goes the wrong way

A full-tree grep for `IntStructureFromSig` / `int_to_ordered` / `to_int_struct` / `int_truth` ↔
`temporal_truth` finds **no** linking lemma. The only map between the worlds is `int_to_ordered :
IntStructureFromSig → OrderedMonadicStructure` (`QuantifierElimination.lean:43`) — the **wrong
direction** for Route B.

### 3.4 What a Route-B bridge would actually have to prove

(B1) classify `M.carrier ≃o ℤ` (countability is **not** assumed at the call site, so this is not
free even with discreteness); **plus** (B2) a truth-transport lemma reconciling the **different
`.box` semantics** (`int_truth` discards box content; `temporal_truth` does not) and the **opposite
`atomMap` direction**.

**This is NOT identical to `no_gaps_discrete_model_surgery`** (which proves a `contemp_equiv`
boundary-existence statement, not ℤ-classification + truth-transport). So the prior handoffs' stated
reason — "the bridge reproduces the surgery" — is **imprecise/incorrect**. But the **conclusion**
holds: once you had the iso, you would just re-run the same expressive-completeness argument that
`US_expressively_complete_over_prior` already provides — so Route B is strictly more work for no
gain, and (B2)'s box-semantics reconciliation fails generically.

**Verdict P2: SOUND conclusion, HASTY/imprecise reason (HIGH).** Route B is genuinely a dead end;
the handoffs reached the right answer via a wrong justification. (This also adjudicates Teammate C's
"the circularity verdict does not survive" remark from report 35: it does survive — the architectural
ℤ-lock + missing bridge + box-semantics mismatch are decisive — but the *original wording* of the
reason should be corrected.)

---

## 4. Pillar 3 — Faithfulness to Rabinovich (does the divergence verdict still stand?)

### 4.1 Rabinovich's actual induction principles (verbatim)

- **Lemma 5.3 / 5.1 — induction on WITNESS COUNT n** (source md:143, 168): *"Proof by induction on
  n … let r_0 = inf{z … P_1(z)} … the problem reduces to a negation on a shorter interval or with
  fewer predicates"*; *"The A_i^- and A_i^+ formulas decompose the interval at a new point z … By
  inductive hypothesis, not A_i is a V-exists-forall formula."*
- **Prop 4.3 — STRUCTURAL induction on the FO formula** (md:106): atomic / disjunction / negation
  (via Prop 4.2) / existential (via Lemma 3.4). **No depth parameter.**
- **Arity firewall — Lemma 3.2(2)** (md:78): *"Every exists-forall formula is equivalent to a
  conjunction of exists-forall formulas with at most two free variables."* Arity never exceeds 2 in
  the negation closure.

Confirmed: **Rabinovich has no "NF depth" and no "arity tower."** Dedekind completeness is used in
exactly one place (the INF formula 5.2).

### 4.2 The `:391` obligation maps to nothing Rabinovich does directly

"Express `∃x` over a **depth-(k+1)** arity-2 normal form as a U/S formula" is a Lean modeling
artifact (`nf_eval_nf`, `NormalForm`). Rabinovich's `∃x`-elimination is the *existential case of
Prop 4.3*, absorbed by V-EA closure at **fixed arity ≤ 2** — not a recursion descending an NF-depth
index. The depth-(k+1) recursion converts his one-directional structural induction into a
self-referential "iff-at-depth-N needs iff-at-depth-N+1" climb.

### 4.3 The sorry moved, but the architecture did not

| Audit | Sorry site cited | Same divergence? |
|---|---|---|
| Report 14 | `FOToVEA.lean:118` | NF-depth / arity tower |
| Report 15 | `KampPrior.lean:154` | NF-depth / arity tower |
| Report 35 / current | `KampPrior.lean:391` | NF-depth / arity tower |

The `| 1 =>` arm recurses (line 313) into `nf_nvar_exist_all_depths … k 1 sub_nf'` with
`sub_nf' : NormalForm sig k 2` — depth descends `k+1 → k`, arity climbs `1 → 2`. This is the same
`n → n+1` growth the audits named. **Reports 14/15/35's divergence verdict still stands for the
current `:391` obligation** — it was "never corrected, only renamed."

### 4.4 Asset inventory — faithful path is repurpose-and-fill-3-gaps, not from-scratch

Done sorry-free (forward translation infrastructure largely exists): Def 3.1/3.3 types
(`VecEAFormula.lean`); Lemma 3.2(1) conj, Lemma 3.4 ∃-closure incl. **arbitrary-arity**
`VecEA_m.existClosure` (bidirectional); Prop 3.5 `translate_correct`; INF 5.2; Lemma 5.3 biconditional;
Cor 5.4 forward; Lemma 5.1 forward (model-dep and model-indep); Prop 4.2 model-dependent (full).

Missing (the 3 real gaps): **Lemma 3.2(2)** arity firewall (no live identifier); **Prop 4.2
model-independent biconditional** (only forward exists; backward is sorry in `NegationIndep.lean:331`);
**Prop 4.3 structural FO induction** (archived to Boneyard). Note: all faithful negation-closure assets
are currently **OFF the live import path** (`KampPrior.lean` imports only `ExistsForallNF`,
`NfToVecEA`, `NfDepth0Generalized`).

**Verdict P3: SOUND (divergence verdict still stands, HIGH).** The `:391` obligation is the
arity-tower artifact, foreign to Rabinovich. A faithful path is feasible by repurposing ~700–1050
lines of mostly-existing sorry-free assets (consistent with reports 14:62–70 and 15:287–295), filling
3 specified gaps — not a ~2200-line ground-up rebuild.

---

## 5. Overclaim Ledger

Places where a `--hard` verdict was stated more strongly than its evidence supports:

1. **OVERCLAIM (decisive).** Report 36 (Route A′), 36:30–37 & 36:164–167:
   *"at `KampPrior.lean:391`, `sub_nf` … is the characteristic NF of a concrete working structure M
   … the obstruction is dissolved, not worked around."*
   — **False.** `sub_nf` is universally quantified before `M` (term goal §2.1; consumer maps over
   `Finset.univ.toList`, `KampPrior.lean:116`, correctness `∀ sub_nf`, line 470). The witness is
   **not** supplied by a model. Obstruction 2 is relabeled, not dissolved.

2. **OVERCLAIM.** Report 36 (e), 36:131–136: the x=t zone uses `char_k1 (mergeNF_succ …)` and the
   strict zones use `exist_tl_fn`/`ih_exist_1` "wrapped in Since/Until," presented as "temporal-formula
   plumbing … the only remaining work." — **Understated.** The strict zones need a **depth-(k+1)**
   arity-2 existential converter; `ih_exist_1`/`exist_tl_fn_k` are **depth-k** (MCP type mismatch §2.3).
   The "remaining work" is the unbuilt arity-tower engine, not plumbing.

3. **OVERCLAIM (reason, not conclusion).** `v35-gate-decision.md` G1 (48–82) and report 36 (d)
   (96–108): Route B is circular because the bridge "reproduces `no_gaps_discrete_model_surgery`."
   — The conclusion (B non-viable) is correct, but the stated reason is **imprecise**: the bridge
   obligation is ℤ-classification + truth-transport (with a fatal box-semantics mismatch), a
   *different* theorem from the surgery. Right answer, wrong justification.

4. **MINOR OVERCLAIM.** Report 36 risk table (36:50–61) rates A′ **MEDIUM** risk because "all
   building blocks are proven sorry-free." — The building blocks for the **diagonal** zone are proven;
   the **strict-order** zones' engine does not exist (§2.3). Risk is materially higher than MEDIUM
   as scoped.

**Fairness note (not overclaims):** The strike-3 *negative* result itself is **not** overstated — it
is a correct, well-scoped non-theorem proof, and its preserved assets (`renameNF`,
`renameNF_eval_iff` mpr-half, `totalUnskip`, `mergeNF_succ`, `mergeNF_succ_atom`) are genuinely
sorry-free and reusable for the **diagonal** zone. The H6 discipline (descend-only, no
Approach-5 reopen) was honored. The gate-decision's structure-type table (52–58) is accurate. The
"bonus finding" that only `n=1` is live (gate 97–103) is correct and useful.

---

## 6. Recommendation for the Plan Revision

**Do not proceed with Route A′ as scoped.** It will not close: the strict-order zones of the
in-situ 3-way disjunction require a depth-(k+1) arity-2 existential converter that does not exist,
and building it *is* the arity tower (reports 14/15). A′'s soundness rests on a premise about
`sub_nf` that is false for the actual `∃A,∀M` goal (§2.3, overclaim #1).

**Do not re-open Route B.** It is genuinely dead (§3), independent of the imprecise original reason.
Recommend correcting the justification text in `v35-gate-decision.md` and `36_phase0-regate-decision.md`
to the architectural reason (ℤ-lock + missing bridge + `.box`-semantics mismatch), but the route
stays closed.

**Step back to the faithful Rabinovich path (option c).** This is the cheapest *correct* exit:
- **Revive + wire Prop 4.3** (structural FO induction) from Boneyard, replacing the entire
  `nf_nvar_exist_all_depths` depth recursion.
- **Build Lemma 3.2(2)** (the arity firewall) — the one genuinely missing piece that *prevents* the
  tower (~100–200 lines).
- **Complete Prop 4.2 model-independent backward** (`NegationIndep.lean:331`; forward already
  sorry-free) (~100–150 lines).
- **Re-anchor `KampPrior` through Prop 4.3 + Prop 3.5** instead of NF→temporal (~100 lines).
- Reuse the existing sorry-free forward infrastructure (Prop 3.5 `translate_correct`, Lemma 3.4
  `VecEA_m.existClosure` bidirectional, Lemma 5.1/5.3, INF, all V-EA types).
- **Estimated ~700–1050 lines, risk MEDIUM** — bounded because the hardest sub-problem (Prop 4.2
  model-independence) is a *fixed-construction* problem at **arity 2**, unlike the *unbounded* arity
  tower A′ would re-enter.

This restores faithfulness to Rabinovich (the task's overriding aim) and replaces a non-closing
in-situ assembly with a path whose every step Rabinovich specifies explicitly. The `mergeNF_succ` /
`renameNF` assets landed during v35 are not wasted: they remain valid sorry-free infrastructure (and
the diagonal-zone merge may still be reused inside a faithful construction), but they are **not** a
route to closing `:391` on their own.

---

## 7. Verification at this boundary

- No `.lean` files were edited (read-only audit). Baseline preserved: `KampPrior.lean:391/394`
  sorries present and unchanged.
- All Lean claims are backed by `lean_term_goal` / `lean_hover_info` / `lean_multi_attempt` probes at
  the live site, or by verbatim definition reads (`NormalForm.lean:198–207`, `KampPrior.lean:107–504`,
  `NfDepth0Generalized.lean:158–598`).
- The depth/arity wall is confirmed by a hard Lean **type error** from `lean_multi_attempt` (§2.3),
  not by abstract reasoning alone.
- Pillars 2 and 3 corroborated by parallel ground-truth signature/grep sweeps (sub-agents), then
  cross-checked against my own reading where they touched contested claims (Route B viability).
