# Report 10 — Q3 Uniform-k Feasibility Probe (GO/NO-GO gate for carrier 3)

**Task**: 349 — recursive `endChar`/`endInterval` (navigated arity-3 endpoint primitive)
**Role**: GO/NO-GO feasibility probe gating the fourth carrier attempt (carrier 3 = enriched-segment
bracket `bracketEndChar_kvE2Ext`, green at k=2). Settles report 09 §Q3.
**Mode**: lean-research-hard (H2/H3/H4/H5). Reference tier: **Tier 1** (Rabinovich 2014 + live Lean types).
**Session**: sess_1783841542_df767b | Read-only; no edits to tracked source. All verdicts carry
file:line / goal-state / machine-check evidence.

---

## VERDICT: **GO**

**The fold-fiber determinacy that uniform-k correctness requires holds uniformly in `k` at full
arity 4, machine-confirmed. The k=2 green is NOT a low-depth determinacy coincidence, and the
F1/F2 refutation mechanism provably cannot bite carrier 3 at any depth.**

The single question this probe gates — *does the k=2 enriched fold-determinacy generalize uniformly
in k at full arity 4?* — resolves **YES**. The GO criterion stated in the delegation ("determinacy
provably holds at full arity 4 for all k; F1/F2 can't bite full-arity") is met on both clauses, with
machine evidence.

**Honest scope of GO (do not overstate).** GO is on the **determinacy wall** — the mathematical
obstruction that killed carrier 2 and that the synthesis flagged as the sole open risk. What remains
after GO is **index-structural construction** (a general-`k` inside-out fold bridge + `k`-generalized
exterior brackets), for which **every determinacy input is already proved**. That is engineering /
typechecking risk, bounded and isolated to v7 Phase 1 — categorically different from a proved
obstruction (NO-GO) or an unproven determinacy hypothesis (STILL-UNRESOLVED).

---

## The four investigation questions, answered

### 1. Why does the k=2 proof work? (fold/determinacy fact + sub-depth)

`bracketEndChar_kvE2Ext_correct_two_prior_frag` (ExteriorBracket.lean:1069) proves the gate
biconditional for `qnf : NormalForm sig 2 3`. Its interior obligations `hrealI`/`hrealB`/`hexcl`
(lines 1084–1102) are stated at **`nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _=>t)))) σ`**
for `σ : NormalForm sig 1 4` — **full arity 4, depth-1 subs, no projection**. The ⇒-direction (lines
1106–1129) does *not* discharge these from an IH; it **threads them as hypotheses** and discharges only
the *exterior residue* `hexclExt` internally, by splitting each strictly-exterior realizer to its side
and refuting it via the per-side exterior brackets `kvE2_extBracketPast_sound` / `kvE2_extBracketFut_sound`
(lines 1126–1128).

The exact determinacy fact the k=2 proof rides: the exterior-bracket soundness hypothesis `habove`
(ExteriorBracket.lean:463–466) is quantified over `(zs : ZoneSpec 3) (χ : NormalForm sig 0 1)` at
**`nf_eval_nf M 0 1`** — i.e. the determinacy input lives at **depth 0**, and it *lifts* to exclude
depth-1 subs (`σ : NormalForm sig 1 4`, conclusion line 468–470). Concretely: the k=2 exterior bracket
rides the **depth-0 fold engine** `nf_quant_layer_fold_iff` (via the depth-1 whole-evaluation bridge
`nf_eval_nf1_iff_efold`, NfEFold:490), whose off-fiber determinacy step is `nf_eval_unique M 0 n env`
(NfEFold:428).

**So the sub-depth of the k=2 determinacy fact is 0**, lifted one layer to depth-1 subs.

### 2. The fold engine's limit — VERIFIED against the actual statement

`nf_quant_layer_fold_iff` (NfEFold:391) is **general in arity `n`** but folds **depth-0 subs only**:
its signature fixes `q : NormalForm sig 0 (n+1) → Bool`, `r : NormalForm sig 0 n`, and its whole proof
is built from the `nf0_`-layer machinery (`nf0_dropFresh`, `nf0_zoneSpec`, `nf0_projFresh`,
`nf0_assemble`). The synthesis's "depth-0-subs only" reading is **CONFIRMED verbatim** by the D7 docstring
(NfEFold:373–374) *and* by the type. The live tree contains **only** the depth-0 engine and its depth-1
lift (`nf_eval_nf1_iff_efold`:490, `nf_quant_layer_fold_k1_gate`:525). **No depth-2 or general-`k` fold
bridge exists** (grep confirmed: `nf_eval_nf2_iff_efold` / `efold_of_nfk` absent from the live tree).

**But the crux the synthesis under-analyzed:** the fold engine's *off-fiber determinacy step* is
`nf_eval_unique M 0 n env` — and **`nf_eval_unique` is fully depth-general** (NormalForm.lean:245–268,
proved by `induction k generalizing n env`). The engine is hardcoded to depth 0 only in its *index
plumbing* (`nf0_*`), **not in its mathematical content**: at depth `k` the off-fiber step is
`nf_eval_unique M k n env`, which is *already proved*. Therefore the missing general-`k` bridge is
**index-structural transcription with every semantic input available**, exactly as NfEFold:388 asserts
("the proof is index-structural"). It is unbuilt, not blocked.

### 3. The quarantined symbolic-k attempt — the actual blocker

`Boneyard/MergedBracketQuarantine/MergedBracketQuarantine.lean` (`#exit` at line 6, inert) holds
`bracketEndChar_kvE {k}` (:269) — the **plain** general-`k` enriched carrier (interior body only, **no
exterior brackets**). Its Phase-13.3 record (:295–372) is a **machine-checked NO-GO** with an explicit
four-element counterexample (`M = ℤ`, `x=10`, `t=20`, fake sub `σ'' := char [14,16,11,20]` sharing only
`t`; :336–362).

**Decisive finding — the quarantine blocker is NOT the Q3 fold-determinacy wall.** The NO-GO record
diagnoses the failure precisely (:353–357):

> "the carrier's only per-sub joint channel is the `t`-anchored provider literal; a dishonest positive
> sub is carrier-indistinguishable from honest content (same depth-0 fiber, zone, fresh type, and
> `t`-anchored joint truth). **Required behavior**: per-sub joint claims pinned against the honest
> anchor pair — in Rabinovich, by Prop 4.2's uniform negation/exclusion disjunctions."

This is a **single-anchor joint-pinning gap**, and it is **provider-independent** — it is *not* a
determinacy failure (determinacy was never invoked against it). Critically, the record's own
"Required behavior" — *pin against the honest anchor pair* — **is exactly what the live carrier 3
adds**: the two adjacent **exterior brackets** `kvE2_extBracketPast` (at anchor `x`) and
`kvE2_extBracketFut` (at anchor `t`), conjoined by Lemma-7.6 adjacency (`bracketEndChar_kvE2Ext_holds_iff`,
ExteriorBracket.lean:674). Carrier 3 = quarantined `kvE` interior **+ the double-anchor repair the
quarantine record itself prescribed.** The k=2 Ext gate being green (sorry-free) is the machine proof
that the repair defeats the quarantine counterexample.

**Conclusion:** the quarantine `#exit` guards a *superseded, weaker* carrier. Its blocker is
**incidental to carrier 3's v7 plan** — carrier 3 sidesteps it by construction. This is a *materially
different and better* position than the synthesis's cautious "prior symbolic-k attempt was quarantined,
never proved" framing: the prior attempt was quarantined *because it was the un-repaired carrier*, and
its own failure analysis names the repair carrier 3 implements.

### 4. Adversarial (decisive) — attempt to REFUTE uniform-k, F2-style

**Refutation target:** a `k=3` (depth-2 subs) model where fold-fiber determinacy fails — two distinct
`σ₁ ≠ σ₂ : NormalForm sig 2 4` co-satisfied at one arity-4 env, making the enriched bracket lossy.

**Result: the counterexample provably cannot be built.** Machine-checked via `lean_run_code`
(self-contained, zero diagnostics):

```lean
-- Q3 crux type: depth-2 subs, full arity 4 — co-satisfaction FORCES equality
example {sig} (M : OrderedMonadicStructure sig) (env : Fin 4 → M.carrier)
    (sub1 sub2 : NormalForm sig 2 4)
    (h1 : nf_eval_nf M 2 4 env sub1) (h2 : nf_eval_nf M 2 4 env sub2) : sub1 = sub2 :=
  nf_eval_unique M 2 4 env sub1 sub2 h1 h2          -- ✓ typechecks, no sorry

-- Uniformly in symbolic k, at full arity 4
example {sig} (M : OrderedMonadicStructure sig) (k : Nat) (env : Fin 4 → M.carrier)
    (sub1 sub2 : NormalForm sig k 4)
    (h1 : nf_eval_nf M k 4 env sub1) (h2 : nf_eval_nf M k 4 env sub2) : sub1 = sub2 :=
  nf_eval_unique M k 4 env sub1 sub2 h1 h2          -- ✓ typechecks, no sorry
```

Any such counterexample would contradict this proved instantiation. **Fold-fiber determinacy holds at
full arity 4 for every depth `k`.**

**Why F1/F2 cannot bite full arity — confirmed.** F2's refutation of carrier 2 hinges on
`f2_sub_proj_eq : nfk_projFresh f2sub1 = nfk_projFresh f2sub2` (RefutationF2.lean:471): **two distinct
subs made equal under the arity-1 fresh projection `nfk_projFresh`.** That collapse is only possible
*because the projection is lossy* (it forgets all but the fresh coordinate). Carrier 3 reads its
interior at **full arity 4** (`nf_eval_nf M 1 4 … σ`, ExteriorBracket.lean:1084–1102) and never applies
`nfk_projFresh`. At full arity, `nf_eval_unique` forbids the collapse the F2 attack requires. **The F2
mechanism is structurally inapplicable to carrier 3, at every depth.**

**GO confirmed by the delegation's own criterion.**

---

## If GO: the exact lemma v7 Phase 1 must prove, and why it holds at full arity 4

The uniform-`k` **fold-determinacy fact is already proved** — it is `nf_eval_unique M k 4 env`
(NormalForm.lean:245). What Phase 1 must **build** is the general-`k` **fold bridge** that *lifts* this
determinacy into the enriched exclusion discharge — the general-`k` analog of `nf_eval_nf1_iff_efold`
(NfEFold:490). Concretely (statement the plan should target):

```lean
-- general-k inside-out whole-evaluation bridge (the unbuilt "309-R3" iteration)
theorem nf_eval_nfk_iff_efold {sig} (M : OrderedMonadicStructure sig) {k n : Nat}
    (env : Fin n → M.carrier) (qnf : NormalForm sig (k+1) n) :
    nf_eval_nf M (k+1) n env qnf ↔
      (nf_eval_efold_k M (k+1) n env (efold_of_nfk qnf) ∧
       ∀ sub : NormalForm sig k (n+1), nfk_dropFresh sub ≠ qnf.1 → qnf.2 sub = false)
```

whose off-fiber conjunct is discharged by `nf_eval_unique M k n env` (the depth-`k` analog of the
depth-0 step at NfEFold:428), and whose forward direction iterates the **already-general-in-`n`**
`nf_quant_layer_fold_iff` inside-out. Phase 1 then generalizes the k2-specific
`kvE2_extBracket{Past,Fut}_sound/complete` (ExteriorBracket.lean:432/456/583…) so their `habove`
determinacy input reads `NormalForm sig k 1` / `nf_eval_nf M k 1` instead of the frozen depth-0
`NormalForm sig 0 1` — the same shape, one fold-layer deeper, with `nf_eval_unique M k …` supplying
determinacy.

**Why it holds at full arity 4 (contrast the `kv_body` arity-1 projection F2 killed):** the enriched
carrier's exclusion obligation is a statement about the *full* `NormalForm sig k 4` sub, whose
co-satisfiability at a fixed arity-4 env is **unique** (`nf_eval_unique`). Carrier 2 (`kv_body`) read
`qnf.2` through `nfk_projFresh` — a **lossy arity-1 projection** onto `NormalForm sig k 1` — where two
genuinely distinct subs collapse (`f2_sub_proj_eq`), and the honest/dishonest content becomes
indistinguishable. **Full arity 4 has no such collapse**; that is the precise, machine-grounded reason
the determinacy wall recurs for carrier 2 at every depth but provably never for carrier 3.

**Residual construction risk (bounded, non-mathematical):** building `efold_of_nfk` / `nfk_dropFresh` /
`nfk_zoneSpec` and getting the mutual `endInterval` recursion to typecheck / terminate (`Nat.rec`
well-foundedness, the `nf_nvar_exist_all_depths` mutual partner, KampPrior wiring). No new *semantic*
obstruction is introduced. This is exactly the work report 09 §3.5 isolates to Phases 1/3/4.

---

## Claim Verification Table (H4)

| # | Claim | Source / Counterexample | Verification Method | Confidence |
|---|-------|-------------------------|---------------------|:----------:|
| C1 | Fold-fiber determinacy holds at depth 2, arity 4 (co-satisfaction ⇒ equality) | `nf_eval_unique` instantiated at (2,4) | **`lean_run_code` — typechecks, 0 diagnostics** | High |
| C2 | Determinacy holds **uniformly in symbolic `k`** at arity 4 | `nf_eval_unique M k 4 env` | **`lean_run_code` — typechecks, 0 diagnostics** | High |
| C3 | `nf_eval_unique` is depth-general (not a k≤2 artifact) | NormalForm.lean:245–268, `induction k generalizing n env` | Direct proof read | High |
| C4 | F2 refutation requires the **arity-1 projection** collapse | `f2_sub_proj_eq : nfk_projFresh f2sub1 = nfk_projFresh f2sub2` (RefutationF2.lean:471) | Direct statement read | High |
| C5 | Carrier 3 interior reads at **full arity 4**, no `nfk_projFresh` | ExteriorBracket.lean:1084–1102 (`nf_eval_nf M 1 4 … σ`) | Direct statement read | High |
| C6 | k=2 exterior-bracket determinacy input is at **depth 0**, lifted to depth-1 subs | `kvE2_extBracketPast_sound` `habove` = `nf_eval_nf M 0 1` (ExteriorBracket.lean:463–470) | Direct signature read | High |
| C7 | Quarantine NO-GO blocker = **single-anchor joint-pinning gap**, NOT determinacy | MergedBracketQuarantine.lean:353–357 ("`t`-anchored … Required behavior: honest anchor pair") | Direct record read | High |
| C8 | Carrier 3's double-anchor exterior brackets = the repair the NO-GO record prescribed | `bracketEndChar_kvE2Ext_holds_iff` destructures Past(`x`)+Fut(`t`) brackets (ExteriorBracket.lean:674, 1109) | Direct statement read | High |
| C9 | General-`k` fold **bridge** is genuinely unbuilt (construction gap) | grep: only `nf_eval_nf1_iff_efold`, `nf_quant_layer_fold_k1_gate` live; no `nfk`/depth-2 bridge | Repository grep | High |
| C10 | Carrier path (ExteriorBracket.lean) is sorry-free | grep: 0 `sorry` (NfEFold:99 / OuterGate:264–265 hits are in docstrings) | Repository grep | High |
| C11 | `nf_quant_layer_fold_iff` off-fiber step is `nf_eval_unique M 0 n env` (⇒ depth-`k` analog available) | NfEFold:422–428 | Direct proof read | High |

**Contradiction Log.** One tension with report 09's framing, resolved (not unresolved): report 09
§Q3/§5 treats the quarantine as generic evidence *against* uniform-k ("a prior symbolic-`k` enriched
attempt is quarantined … never proved"). Direct reading of the quarantine record (C7/C8) shows the
quarantined object is the **un-repaired plain `kvE`**, and its own failure analysis **names the repair
carrier 3 implements**. Precedence: **machine-checked artifact + primary-source record > synthesis
narrative** → the quarantine is evidence that carrier 3's *design* is correct, not evidence against its
generalization. No unresolved contradiction remains.

---

## Adversarial self-check — the strongest case AGAINST my GO verdict

1. **"GO on determinacy is not GO on the carrier."** True and stated plainly: the general-`k` fold
   bridge and `k`-generalized exterior brackets are **unbuilt** (C9). I have proved the determinacy
   *inputs* are uniform and the refutation mechanism is inapplicable; I have **not** compiled a
   symbolic-`k` `endIntervalStep`. If the bridge construction hits a `Nat.rec` well-foundedness or a
   mutual-recursion typechecking wall, carrier 3 stalls — but that would be a *construction* failure
   with no semantic counterexample, recoverable by re-indexing, **not** the F-D wall that killed
   carrier 2. *Why GO stands:* the delegation defined the gate as the determinacy question, and named
   the alternative outcome (a k=3 fold non-determinacy counterexample) as the NO-GO trigger. That
   counterexample is machine-refuted. The honest verdict is GO **on the question asked**, with the
   construction residual disclosed and bounded.

2. **"Could a deeper joint-pinning gap recur at k≥3 that double-anchor brackets miss?"** The plain-kvE
   gap was a sub honest at `t` but dishonest at `x`. A k≥3 sub honest at *both* anchors but dishonest
   in its **depth-(k-2) interior** is the natural worry. *Rebuttal:* that deep interior is exactly what
   the exterior bracket's own **recursive fold** characterizes (its `habove`/`hbelow` determinacy input,
   one layer deeper), and the determinacy that makes that fold sound is `nf_eval_unique M (k-1) …` —
   uniform (C2). There is no pinning channel below the anchors that escapes both the double-anchor
   brackets *and* the recursive IH characterization, *provided* determinacy holds at each layer — which
   it does. So no new *semantic* gap; only the construction that threads it.

3. **"`lean_run_code` on two 5-line examples is thin evidence."** The examples are not the whole
   result — they are the **exact refutation of the exact NO-GO trigger** the delegation named ("two
   distinct depth-2 subs sharing a fold-fiber"). Their weight is that they instantiate a
   `induction`-proved, depth-general theorem (C3) at the crux type; the generality is in
   `nf_eval_unique`'s proof, not in the examples. Combined with C4–C6 (F2 is arity-1-projection-bound;
   carrier 3 is full-arity), the determinacy question is closed.

**Verdict after adversarial pass: UNCHANGED — GO.** Determinacy is uniform and machine-confirmed; the
F2 wall is structurally inapplicable to full-arity carrier 3; the quarantine blocker is a superseded
single-anchor gap that carrier 3 repairs by construction. Proceed to `/revise 349` v7 onto carrier 3,
**with Phase 1 retained as the construction gate** (build the general-`k` fold bridge + `k`-generalized
exterior brackets; the determinacy inputs are all proved). The residual is engineering, not a wall.

---

## Cross-references (not repeated here)

- Report 09 (`09_carrier-synthesis.md`) §Q3/§3/§5 — carrier decision, phase breakdown, the standing
  reservation this probe resolves. This report **supersedes** §Q3's "Medium / leaning feasible" with
  **GO on determinacy** (C1–C6), and **corrects** §5's read of the quarantine (C7/C8).
- Report 09 teammate C — carrier 2 F2-DEAD; names `kvE` as the faithful repair (consistent with C8).
- Rabinovich 2014: Prop 4.3 innermost ∃-fold (PDF p.6) = `nf_quant_layer_fold_iff`; Lemma 7.6 adjacency
  = the double-anchor exterior-bracket composition; Prop 4.2 uniform negation-closure = the pinning
  channel the plain `kvE` lacked and the exterior brackets supply.
