# Faithful Rabinovich NF Encoding — Research Report

**Task**: 377 — transcribe_rabinovich_faithful_nf_encoding
**Session**: sess_1784156166_ad146c
**Date**: 2026-07-15
**Mode**: `--hard --lit` (H2 anti-analysis, H3 reference grounding tier=literature, H4 adversarial verification)
**Arbiter**: `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf` — all citations BY PDF PAGE. The companion `.md` was not used.

---

## Summary

> ## THE TASK MUST BE RESCOPED. ITS CENTRAL PREMISE IS FALSE.
>
> **Prop 4.2 did not stall — it is PROVED**, sorry-free and axiom-clean, verified by an actual build. Sections 3-5 are largely already transcribed: the faithful Def 3.1 object (`VecEA2`) is **live and sorry-free**, Prop 3.5's two translations are **live and sorry-free**, and Prop 4.2 needs only un-archiving (`#exit` + 4-line header stripped -> EXIT 0). **Planning the chartered scope — "transcribe sections 3-5" — would rewrite ~1,204 lines of verified proof and never touch the actual gap.**
>
> **The real gap is the `nf_eval_nf -> VecEA2` bridge above depth 0** — where BOTH the live path (`KampPrior.lean:519`) and the archived path (`NegationClosure.lean:1722`) stall, with the same obstruction under two different names. **It is not a Rabinovich step.**

1. **Phase 1 gate: CLEARED.** Machine-checked sorry-free and **axiom-free** (not even `propext`). Report 08's MEDIUM-HIGH routineness rating was pessimistic. Probe: `reports/01_lemma32-anchor-split-probe.lean`.
2. **Encoding ruling: CONFIRMED, mechanism pinned exactly** — plus one correction: the charter states the theorem/non-theorem direction **inverted**.
3. **Open question: ANSWERED — YES**, conditional on Def 3.1's **beta interval layer**. That layer turns out to already exist, live and sorry-free, in `BracketFormula`/`VecEA2`.
4. **Archive: RECOVERABLE WITH MINOR DRIFT — proven by building, not inspecting.** 93-module closure: 74 live, 21 boneyard-resident, **0 absent**. Drift is purely module-path renames.

**The finding that unifies the task**: a natural experiment was already run here, by the same hand, from the same paper, in the same period — and its result was never read.

| File | Built on | `nf_eval_nf` hits | Outcome |
|---|---|---|---|
| `NegationClosureProp42.lean` | `VVecEA2` — the faithful `∃∀` object | **0** | **PROVED**, axiom-clean |
| `NegationClosure.lean` | `nf_eval_nf` — the Hintikka encoding | **42** | **STALLED** |

**The encoding boundary is the proved/stalled boundary, with zero exceptions.** Stay inside the faithful object and Prop 4.2 falls out; route through `nf_eval_nf` and you are forced to name the Feferman-Vaught composition theorem for linear orders — a hard theorem, and precisely the "novel mathematics" the binding user constraint forbids. **Rabinovich never needs it**, because he never converts a type into an `∃∀`-formula. The FV gap is self-inflicted.

Secondary but consequential: **`NfEFold.lean` — which the charter names as stating the correct diagnosis — is itself missing the `beta` layer**, which is exactly why its fold stalls at depth 1. Adopting it as-is would reproduce the stall. `VecEA2` supersedes it.

---

## Q1 — The Phase 1 Feasibility Gate: **CLEARED**

### Verdict

**CLEARED.** Machine-checked sorry-free and axiom-free on the first compile attempt.

```
'Rabinovich377Probe.chain_split' does not depend on any axioms
'Rabinovich377Probe.chain_split_p7_instance' does not depend on any axioms
'Rabinovich377Probe.lt_of_chain_pin' does not depend on any axioms
```

Probe: `specs/377_transcribe_rabinovich_faithful_nf_encoding/reports/01_lemma32-anchor-split-probe.lean`

### The reasoning that settles it

Read Def 3.1's conjunct list (PDF p.4) and classify each conjunct by **how many witnesses it couples**:

| Def 3.1 conjunct (PDF p.4) | Couples |
|---|---|
| `AND_{k=0..m} z_k = x_{i_k}` | unary (one witness + one free var) |
| `x_n > x_{n-1} > ... > x_1 > x_0` | **consecutive pairs only** |
| `AND_{j=0..n} alpha_j(x_j)` | unary |
| `AND_{j=1..n} (forall y)^{<x_j}_{>x_{j-1}} beta_j(y)` | **consecutive pairs only** |
| `(forall y)_{>x_n} beta_{n+1}(y)` | unary (tail) |
| `(forall y)^{<x_0} beta_0(y)` | unary (tail) |

**No conjunct of Def 3.1 joins non-adjacent witnesses.** A Def 3.1 formula's constraint graph is therefore a **path**. Cutting it at any anchor `c` separates it into components sharing only the cut vertex, and because `c` is a *free variable* — a fixed value, shared identically by both sides — the two halves glue back unconditionally. Each cut moves one free variable into its own conjunct; iterating once per free variable is the `m -> m+1` induction, and terminates at `<=2` free variables per conjunct. That is Lemma 3.2(2).

This is why Rabinovich could write "It is clear that" (p.4): the claim is visible in the *shape* of Def 3.1, not in any argument about orders.

### Two falsifiable predictions the probe confirms

The probe was written so that a hidden gap would surface as a needed hypothesis. Neither was needed:

- **No Dedekind completeness.** This matches the paper exactly: Lemma 3.2 (p.4) carries **no** completeness hypothesis, whereas Prop 4.2 (p.6) explicitly says "over Dedekind complete chains". Had the `m -> m+1` step secretly needed completeness, the probe would not have closed over a bare `LinearOrder`. It did.
- **No density, discreteness, or rigidity.** Consistent with report 07's finding that Rabinovich needs no rigidity.

The axiom-free result is stronger than required and is independent corroboration: a gap-hiding step would almost certainly have pulled in `Classical.choice`.

### Correction to the charter's framing

The charter says Rabinovich "PRINTS the interval-split technique for Lemma 3.2(2) at m=1 on p.7". Precisely: **p.7 is the proof of Prop 4.2, not of Lemma 3.2(2).** Inside it, Rabinovich splits a *two*-free-variable `psi(z_0,z_1)` into `psi_0(z_0) AND psi_1(z_1) AND phi(z_0,z_1)` (p.7 items 1-3). That is the same *technique*, applied to refine an already-`<=2`-arity formula rather than to reduce arity. The probe reproduces the p.7 split as `chain_split_p7_instance`, derived as an instance of the general step — so the general step is confirmed to *subsume* the printed one, which is the strongest available evidence that it is the intended argument.

---

## Q4 — The Encoding Ruling

### CONFIRMED against the PDF

- **Def 3.1 (p.4)** has an ordered existential prefix (`x_n > ... > x_0`), point types `alpha_j` at witnesses, **and** interval types `beta_j` on the open segments `(x_{j-1}, x_j)`, plus tails `beta_0` / `beta_{n+1}`. Verified verbatim.
- **`NormalForm sig k n`** (`NormalForm.lean`) has none of these. `nf_eval_nf` (`NormalForm.lean:198-207`) at depth `k+1` reads its quant layer over `sub_nf : NormalForm sig k (n+1)` — **arity grows `n -> n+1` per depth descent**. Verified verbatim.
- **Rabinovich never grows arity**: Def 4.1 (p.5) folds each processed depth into the *signature* as a **unary** `E[Sigma]`-atom (`Sigma ∪ {A | A is a TL(Until,Since)-formula over Sigma}`), interpreted as `{a ∈ M | M,a |= A}`. Depth lives in the atom, never in the arity.

So the charter's core claim holds: the repo's `NormalForm sig k n` is a Hintikka `n`-type, not Def 3.1's object.

### The mechanism, pinned exactly (this is new)

The charter locates the defect at the encoding. Correct — but the *operative* failure is a specific **induction-hypothesis starvation**, and naming it changes what the fix must do:

- `nf_characterizable_temporal_prior` (`KampPrior.lean:565`) targets `nf_eval_nf M k 1 (fun _ => t) nf` — arity 1.
- Its engine `nf_nvar_exist_all_depths` (`KampPrior.lean:346`) recurses **`(k+1, n) -> (k, 1)`** (the call at `KampPrior.lean:407` is at arity **1**). **The recursion does *not* escalate arity.**
- But at `n = 1` the goal is a temporal formula for `∃x, nf_eval_nf M (k+1) 2 [x,t] sub_nf`. Unfolding `nf_eval_nf`'s **definition** at depth `k+1`, arity 2 yields a quant layer over `qnf : NormalForm sig k 3` — **arity 3**.
- The IH supplies arity **2**. The goal needs arity **3**. **That mismatch is the sorry at `KampPrior.lean:519`.**

> **The arity growth is in `nf_eval_nf`'s *definition*, not in the recursion that consumes it.** The recursion is arity-stable and correct; it is *starved* by a definition that demands one more anchor per depth than the IH can supply. Any fix that repairs the recursion while keeping `nf_eval_nf` will fail. **The definition must be replaced.**

Under Def 4.1 the starvation vanishes by construction: the `E[Sigma]`-atom is evaluated **at the witness alone** (arity 1, depth `k`) — which is *exactly* the IH. The induction closes.

### Why three seam designs were machine-refuted

The repo has already **machine-proved** the negative half, sorry-free, with axioms exactly `{propext, Classical.choice, Quot.sound}`:

- `endCharN0_correct_world_local_obstruction` (`Base.lean:1839`)
- `endCharN0_correct_infeasible` (`Base.lean:1779` region)
- Verdict recorded verbatim at `Base.lean:1801`: *"this frozen target is **UNPROVABLE**"*.

`Lemma32Reduction.lean:290-306` states the reason correctly: *"when `n >= 3` there is an anchor position outside `{i, j}`, and an arity-3 witness constrained only at the pair `{i, j}` ... need not satisfy the arity-`(n+1)` form's constraints at those other positions"*. In the vocabulary of Q1: `nf_eval_nf`'s quant clause is a **hyperedge over all `n+1` points at once** (`Fin.cons x env` with an arbitrary `(n+1)`-ary `sub_nf`). Its constraint graph has treewidth `n`, not 1. **No anchor split exists, because there is no separator.** Def 3.1 has treewidth 1; that is the entire difference, and it is why the same lemma name is provable on one side and refuted on the other.

### Correction: the charter states the ruling **inverted**

The charter (and the task description) says:

> "Lemma 3.2(2) is a theorem about the repo's encoding and a NON-THEOREM about Rabinovich's"

**This is backwards, and the inversion matters.** The evidence — the repo's own machine-checked `endCharN0_correct_infeasible` on one side, and my axiom-free `chain_split` on the other — establishes the reverse:

- Lemma 3.2(2) is a **THEOREM** about **Rabinovich's** encoding (Def 3.1, treewidth 1) — machine-checked here.
- Lemma 3.2(2) is a **NON-THEOREM** about the **repo's** encoding (`nf_eval_nf`, hyperedge) — machine-checked in-repo as UNPROVABLE.

Read as written, the charter would license *keeping* `nf_eval_nf` and hunting for a Rabinovich-side repair. That is exactly backwards and would burn another cycle. The rest of the charter's reasoning is consistent with the corrected direction, so I read this as a transcription slip in the charter rather than a substantive disagreement — but it must not be propagated into the plan.

### THE RULING

> **The faithful encoding is Def 3.1's object: an ordered chain of witnesses carrying BOTH a point-type layer (`alpha_j`) AND an interval-type layer (`beta_j`) on the open segments between consecutive witnesses, with unbounded-tail types `beta_0` / `beta_{n+1}`. Depth is folded into the signature as a UNARY `E[Sigma]`-atom (Def 4.1, p.5) and NEVER into the arity. `nf_eval_nf` must be replaced on the characterization path, not bridged to.**

### NfEFold is **not** the answer as written — the beta layer is missing

The charter says `NfEFold.lean:14-27` "states the correct diagnosis verbatim and was never adopted". The *diagnosis* is indeed correct and well-cited. **But the file's own encoding does not implement the ruling, and adopting it as-is would reproduce the stall.** Three findings, in increasing severity:

1. **The docstring is stale.** It claims *"Nothing in the existing development imports this file, so it is off the live path"*. False: `NfEFold` is imported by `NfMultiAnchorBridge.lean`, `Base.lean`, `ExteriorBracketK.lean`, `ExteriorFiberK.lean`, `ExteriorFiberConsistencyK.lean`, `CarrierK1V.lean`. It is live.

2. **`EAtomDom` has no `beta` slot — the fidelity defect.**
   `EAtomDom sig k n := ZoneSpec n × NormalForm sig k 1` (`NfEFold.lean:69`) carries the **order** (`ZoneSpec`) and the **point type** (`NormalForm sig k 1` = Def 3.1's `alpha_j`) — but **nothing corresponding to Def 3.1's `beta_j`**. The file admits this at `NfEFold.lean:100`: *"Interval types `beta` have no explicit slot — `forall`-content along a segment is carried by `quant_assignment e = false` entries"*.
   **That compensation cannot work.** `zoneHolds M env e.1 x` constrains `x` only relative to the **environment** points. With `env = (t)`, `ZoneSpec 1` can say "no point *below t* has type `tau`" — but it **cannot** say "no point in the open interval `(x,t)` has type `tau`", because `x` is the *bound* variable, not an env point. Def 3.1's `beta_j` lives on `(x_{j-1}, x_j)` — a segment between two *witnesses*. The false-entry device cannot reach it.
   Consequence: `EAtomDom` cannot recover the arity-2 type of `(x,t)` from `(zone, 1-type of x, 1-type of t)`, because the interval content of `(x,t)` is genuinely missing information.

3. **`nf_eval_efold_k` is a mis-named non-fold, and this is where the fold silently died.**
   The genuine Def 4.1 fold (`nf_eval_efold`, `NfEFold.lean:102`, arity-stable) is bridged to `nf_eval_nf` **only at depth 1**, via `nf_eval_nf1_iff_efold` (`NfEFold.lean:490`). At depth `k >= 1` the file substitutes `nf_eval_efold_k` (`NfEFold.lean:608`), whose own docstring says: *"**NO arity-1 collapse**: subs are read at `nf_eval_nf M k (n + 1)`"* — i.e. **it grows arity**. It is not a fold. The section note concedes it: *"at depth `k >= 1` only the full-arity `nf_eval_efold_k` remains faithful"*.
   The name reads as "the general-`k` fold" and is consumed as such: `nf_eval_nfk_iff_efold` (`NfEFold.lean:627`) is the bridge that **`NfMultiAnchorBridge`'s ~13,737 lines are built on** (`ExteriorConverterK.lean:28`, `:209`, `:223`; `ExteriorBracketK.lean:10`, `:322`; `ExteriorPinnedProbeK.lean:528`; `ExteriorGateAssembleK.lean:53`). **The entire bridge is founded on the arity-GROWING decomposition.** That is why it produced arity-4 machinery, and why it can never close `k >= 2`.
   Item 2 explains item 3: the fold *had* to revert to full arity at `k >= 1` **because it lacks the `beta` layer** and therefore cannot express the depth-`k` step arity-stably. The missing `beta` slot is the root cause of the depth-1 ceiling.

### The faithful object already exists in-tree — and was never given its closure theory

`ExistsForallNF.lean:93` defines:

```lean
structure IntervalPattern (n : Nat) where
  alpha : Fin n → TemporalPred        -- point types at witnesses
  beta  : Fin (n + 1) → TemporalPred  -- interval types on the segments
```

with `IntervalPattern.holds` (`:106`) quantifying increasing witnesses and enforcing `alpha` at points and `beta` **on each open segment** — i.e. **Def 3.1's shape, `beta` layer included**. `ExistsForallNF.lean:285-333` (`buildRight` / `buildLeft` / `translateEF1`) is a direct transcription of **Prop 3.5 (p.5)**, both the `Until` and the `Since` mirror. This file is **live** (imported by `KampPrior.lean` itself).

**Two fidelity deltas to verify before building on it** (do not assume):
- `IntervalPattern` places all witnesses **strictly inside** `(z_0, z_1)` with no `alpha` at the endpoints, whereas Rabinovich's Notation 5.2 `[alpha_0, beta_1, ..., beta_n, alpha_n](z_0,z_1)` (p.8) **pins** `z_0 = x_0` and `z_1 = x_n` with point types *at* them. These are inter-translatable (`Notation 5.2 == alpha_0(z_0) AND alpha_n(z_1) AND IntervalPattern(n-1)`), but that is a re-indexing that must be **proved**, not assumed.
- `IntervalPattern` is **bounded** (`(z_0,z_1)`); Def 3.1's `beta_0` / `beta_{n+1}` tails are **unbounded**. Rabinovich's own idiom is to instantiate unused slots with `True` (Lemma 5.3, p.8, is stated exactly for the instance "where `alpha_0`, `alpha_n` and all `beta_i` are equivalent to True"), so the bounded form is the right primitive — but the tails need their own treatment.

**Trap (2) confirmed exactly as the charter warns**: `ExistsForallNF.lean`'s docstring advertises `VEF.closed_conj` (Lemma 3.2(1)), `VEF.closed_ex` (Lemma 3.4), and `VEF.closed_disj` under "Main Results". The file's full declaration list contains **only** `VEF.disj` and `VEF.disj_holds`. **`closed_conj`, `closed_ex`, and `closed_disj` are never defined.** Its zero-sorry count reflects unstated theorems. The faithful object exists; its closure theory does not.

---

## Q3 — Does a faithful transcription close `completeness_discrete`? **YES** (conditional)

### The two sorries are not peers

| Site | Arm | Status |
|---|---|---|
| `KampPrior.lean:519` | `k >= 2` inside the `n = 1` arm | **The real blocker.** IH-starvation (arity 3 needed, arity 2 supplied). Dissolves under Def 4.1. |
| `KampPrior.lean:522` | `n >= 2` | **Mathematically off-path** — but must still go. |

**Why 522 must still go, and why the DoD is right that BOTH are required.** The in-code comment at `:522` ("off the critical path. The main theorem only needs n = 0 and n = 1") is **correct as mathematics**: the recursion resets arity to 1 (`KampPrior.lean:407`) and the live entry from `nf_characterizable_temporal_prior` is `n = 1`, so the `n >= 2` arm is never reached. **But axiom tracking is per-declaration, not per-execution-path.** Both sorries sit inside the single `noncomputable def nf_nvar_exist_all_depths`, so `sorryAx` enters that declaration's proof term — and hence `completeness_discrete`'s closure — regardless of reachability. This independently reproduces the DoD's statement and the two proof-term traces.

**This makes 522 a cheap win, and the plan should treat it as one.** Because the arm is genuinely unreachable, retiring it does **not** require proving the general `n >= 2` case: restructuring so the unreachable arm is not in the same declaration (restricting the definition's domain, or splitting the declaration) discharges it. That is a bounded, mechanical task independent of the encoding work — and it is the *only* one of the two that can be done without the ruling.

### The end-to-end answer

**YES, conditional on the `beta` layer.** The chain
`completeness_discrete` (`Completeness.lean:276`) <- `nf_nvar_exist_all_depths` <- `nf_characterizable_temporal_prior` <- `kamp_prior_expressive_completeness` (`KampPrior.lean:648`)
needs exactly one thing the current encoding cannot give: a temporal characterization of `∃x, nf_eval_nf M (k+1) 2 [x,t] sub_nf` whose induction closes at arity 1.

Def 3.1 + Def 4.1 supply it, **provided** the arity-2 type of `(x,t)` is reconstructible from arity-<=1 data. By Lemma 3.2(2) it is — from (order of `x` vs `t`) + (1-type of `x`) + (1-type of `t`) + (**interval type of `(x,t)`**). Three of those four are in `NfEFold`'s `EAtomDom`. The fourth is not, and it is not optional: it is the `beta` layer, and it is the difference between an induction that closes at arity 1 and one that reverts to full arity at depth 1 — which is empirically what happened.

**Confidence: Medium-High, not High.** The gate (Q1) and the diagnosis (Q4) are machine-checked; this answer is not. The residual risk is concentrated in **Prop 4.2**, and it is the same place the prior faithful path stalled — which is evidence the difficulty is real, not that the route is wrong. The mitigating fact is decisive for scope: **Prop 4.2 is proved IN FULL and IN PRINT across pp.7-11** (Lemma 5.1, Notation 5.2, Lemma 5.3, Cor 5.4, eq 5.2, eq 5.3, Figure 1, and the closing induction). Unlike the Q1 gate, **nothing in section 5 is left to "It is clear that"**. The mathematics is on the page; the task is transcription.

### Section 5's one genuine dependency (fidelity note for the plan)

Dedekind completeness enters section 5 **only** to manufacture `r_0 := inf{z ∈ (z_0,z_1) | P_1(z)}` (p.8, Case 2) and `r_0 := inf{z ∈ (z_0,z_1) | ¬beta_1(z)}` (p.10, Case 3), each then **defined by** an explicit formula — `INF` at eq (5.2) p.8 and `INF^{¬beta_1}` at eq (5.3) p.10. This corroborates report 07's "Dedekind completeness is an **ANCHOR FACTORY**, not a model filter" verbatim: it is used to *produce a definable point*, never to restrict the model class. Footnote 4 (p.10) adds *"We will use only existence and will not use uniqueness"* — a real scope reduction the transcription should exploit.

---

## Q2 — Recoverability of the Archived Faithful Path

> ### THE TASK'S CENTRAL PREMISE IS FALSE.
>
> The task description, report 08, and this report's own charter all state that *"the faithful path stalled at Prop 4.2 and was archived as dead code"*. **Prop 4.2 is finished.** `neg_2var_vec_ea` (`Boneyard/KampNegationClosure/NegationClosureProp42.lean:159-169`) is a real tactic proof, **sorry-free**, and **axiom-clean** — verified by an actual scoped build after restoring it to its pre-archival path (`lake build ...Kamp.NegationClosureProp42` -> EXIT 0; `#print axioms neg_2var_vec_ea` -> `[propext, Classical.choice, Quot.sound]`, **no sorryAx**). `RabinovichNegation.lean` (279 lines, titled "Rabinovich Negation Closure (Proposition 4.2)") is likewise sorry-free.
>
> **A task scoped as "transcribe / redo Prop 4.2" would rewrite ~1,204 lines of already-verified, still-compiling proof.** The archival (commit `82d7bf6f2`) was a pure `git mv`, decided on **reachability** ("no live importers"), never on correctness. Nothing was deleted; nothing rotted.

### The real stall — verified verbatim

`nf_exist_formula_nested_backward` (`Boneyard/KampNegationClosure/NegationClosure.lean:1670-1722`), `sorry` at **:1722**. Its own blocker comment names the missing ingredient:

```
-- BLOCKER on (b): The quantifier part (sub_nf.2) requires a composition argument
-- for non-interval zones. This is the Feferman-Vaught composition theorem for
-- linear orders.
-- Interval zones (zone 3): positive from Since/Until witnesses in formula.
-- Non-interval zones (1,2,4,5): require composition argument.
-- At k=0: depth-0 3-var NFs are purely atomic; the composition reduces
-- to showing 3-var atom existentials are determined by endpoint 1-var NFs.
-- At k>=1: requires full Feferman-Vaught composition for linear orders.
```

Only **4 real tactic-position sorries** exist across the 8 archived files (`NegationClosure.lean:1333` — annotated "NOT on the critical path" — and `:1722`; `RabinovichGeneralized.lean:471`; `RabinovichWiring.lean:365`). A naive `grep -c sorry` returns ~40; nearly all are docstring prose *about* sorry status. **Do not cite that number** — the same trap fires on `NfEFold.lean`, whose single `sorry` hit is the word "sorry-free" in a docstring.

### The two independent stalls are THE SAME OBSTRUCTION

This is the finding that unifies the whole task. The archived path's blocker is a **3-variable** existential (`∃y, nf_eval 3 (y,x,t) ssn` — the comment's own words) that cannot be reduced to endpoint 1-var data at depth `>= 1`. That is **identical** to the live path's `KampPrior.lean:519` defect derived independently in Q4: *the goal needs arity 3, the IH supplies arity 2*.

**The same obstruction was hit twice, in two separate codebases, and given two different names** — "IH starvation / arity-3 read" on the live path, "Feferman-Vaught composition for linear orders" on the archived path. Neither is a Rabinovich step. Both are artifacts of routing through `nf_eval_nf`.

### The natural experiment: the encoding boundary IS the proved/stalled boundary

Both archived files were written by the same hand, from the same paper, in the same period. They differ in exactly one respect:

| File | Built on | `nf_eval_nf` hits | Outcome |
|---|---|---|---|
| `NegationClosureProp42.lean` (**Prop 4.2**) | `VVecEA2` — the faithful `∃∀` object | **0** | **PROVED**, sorry-free, axiom-clean |
| `NegationClosure.lean` | `nf_eval_nf` — the Hintikka encoding | **42** | **STALLED** at `:1722` |

**Zero exceptions.** The file that stayed inside the faithful `∃∀` object proved Prop 4.2 outright. The file that routed through `nf_eval_nf` hit a wall and had to name a hard theorem from the literature to describe it. This is the ruling of Q4, already demonstrated once in this repo, unrecognized.

### The faithful infrastructure is LIVE and SORRY-FREE — 1,902 lines of it

`VecEA2` (`VecEAFormula.lean:252`) is **Rabinovich's Notation 5.2 (p.8) exactly** — `[alpha_0, beta_1, ..., beta_n, alpha_n](z_0,z_1)`:

```lean
structure BracketFormula (n : Nat) where
  pointTypes   : Fin n → TemporalPred        -- alpha
  segmentTypes : Fin (n + 1) → TemporalPred  -- beta

structure VecEA2 (n : Nat) where
  endpointLeft  : TemporalPred   -- alpha_0 AT z_0  (PINNED)
  endpointRight : TemporalPred   -- alpha_n AT z_1  (PINNED)
  bracket       : BracketFormula n
```

| Module | Lines | Tactic sorries | In build? |
|---|---|---|---|
| `Kamp/VecEAFormula.lean` (`VecEA2`, `BracketFormula`, `VVecEA2`) | 769 | **0** | **BUILT** |
| `Kamp/VecEATranslation.lean` (`translateLeft` — Prop 3.5 Until) | 566 | **0** | **BUILT** |
| `Kamp/NfToVecEA.lean` (`translateRight` — Prop 3.5 Since; the nf->VecEA bridge) | 567 | **0** | **BUILT** |

`BracketFormula.toIntervalPattern` (`:135`) already inter-translates with `ExistsForallNF.IntervalPattern`. **`VecEA2` is the better primitive**: it has the **pinned endpoints** that Notation 5.2 requires and `IntervalPattern` lacks — the exact fidelity delta flagged in Q4 is already closed by `VecEA2`.

### Where the gap actually is

**`NfToVecEA.lean` is DEPTH-0 ONLY.** Its docstring: *"Converts `∃ x, nf_eval_nf M 0 2 (Fin.cons x (fun _ => t)) sub_nf` into a `VVecEA2` formula... At depth 0, the NF evaluation is purely atomic, so the existential decomposes by order direction."* Its terminal result is `nf_2var_exist_depth0_tl` (`:503`).

This matches the archived blocker comment line-for-line ("At k=0 ... purely atomic ... At k>=1: requires full Feferman-Vaught composition"). **The `nf -> VecEA` bridge exists at depth 0 and nowhere else, and the general-depth bridge is exactly the FV composition gap that stalls both paths.**

So the honest statement of this task's remaining work is:

> **Everything Rabinovich prints is done or nearly done. The faithful object is live and sorry-free; Prop 4.2 is proved about it; Prop 3.5's two translations are live and sorry-free. The single gap is the `nf_eval_nf -> VecEA2` bridge above depth 0 — and that bridge is NOT a Rabinovich step. It is the cost of a type-first architecture Rabinovich never uses.**

### Recoverability verdict: **RECOVERABLE WITH MINOR DRIFT — proven by building, not by inspection**

The full transitive closure of the archived faithful path is **93 modules: 74 already live, 21 boneyard-resident, 0 absent.** Drift is **purely module-path renames** — every referenced declaration (`VVecEA2`, `VBracketFormula`, `conj_holds_vvecEA2`, `translateLeft_correct`, `semantic_prior_UZ`, `OrderedMonadicStructure`, `nf_eval_nf`, `temporal_truth`, `AtomKind`, `atom_eval`) exists live at unchanged paths. Restoring `NegationClosure5.lean` + `NegationClosureProp42.lean` (header + `#exit` stripped, **no other edit**) builds clean at EXIT 0. Restoring `NegationClosure.lean` additionally pulls the `KampBypassArchive` cluster; total relocation surface ~13,255 lines / 21 files.

### What is and is not verified — the two mechanisms, kept distinct

**None of the archived code is exercised by `lake build`**, by two *independent* mechanisms. But "not in the build target" and "does not compile" are **different facts**, and I initially conflated them:

| Location | Files | Lines | `#exit`? | In lake build? | Verified? |
|---|---|---|---|---|---|
| `Theories/Bimodal/Boneyard/KampNegationClosure/` | `NegationClosure.lean` (1843), `NegationClosure5.lean` (1033), `NegationClosureProp42.lean` (171), `FoToVecEA.lean` (229) | 3,276 | **YES** (~line 5) | `BoneyardArchive` lib — *"Not built by default"* | **NO** |
| `Theories/Bimodal/Boneyard/RabinovichPath/` | `RabinovichGeneralized.lean` (522), `RabinovichWiring.lean` (371), `RabinovichNegation.lean` (279), `RabinovichProp42.lean` (114) | 1,286 | **YES** | same | **NO** |
| `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Boneyard/` | 17 files incl. `ArityReduction.lean` (110), `Prop43.lean` (196), `VecEA_m.lean` (659), `EAVecNegationClosure.lean` (296), `RabinovichTranslation.lean` (302) | ~4,500 | **NO** | **NO — unreachable from the `Bimodal` root** | **NO** |
| `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop43.lean` (**not** in a boneyard) | 1 | — | NO | **NO — unreachable from the root** | **NO** |

**Two independent kill mechanisms, and it is important not to confuse them:**

1. **`#exit`** (45 of 91 boneyard files). Everything below it is never elaborated. `KampNegationClosure/NegationClosure.lean`'s header:
   ```
   -- ARCHIVED from Metalogic/WeakCanonical/Kamp/NegationClosure.lean
   -- Reason: Dead code — negation closure chain with no live downstream consumers
   -- Archived: 2026-06-16 (task 302)
   #exit
   ```
   Reinforced by the lakefile: `lean_lib BoneyardArchive` carries the comment *"Archived dead code. Not built by default."* and globs `Bimodal.Boneyard` submodules only.

2. **Unreachability** — subtler, and the one that would have been missed. `Kamp/Boneyard/*` is **not** under the `Bimodal.Boneyard` glob (its module path is `Bimodal.Metalogic.WeakCanonical.Kamp.Boneyard.*`), and it carries **no `#exit`** — so it *looks* live and reports **0 sorries**. But the default target is `lean_lib Bimodal` with `roots := #[`Bimodal]`, which builds only what is reachable by import from `Theories/Bimodal.lean`. An import-graph walk from that root (234 reachable modules, `#exit`-truncated) puts **every** `Kamp/Boneyard/*` module OUTSIDE the build. `ExistsForallNF` and `NfEFold` are **inside** it — confirming the walk discriminates correctly.

**CORRECTION to my own first-draft claim.** I initially wrote that the `Kamp/Boneyard/*` files were "never type-checked". **That was wrong, and it conflated two independent facts.** A scoped build proves type-check status; the import graph proves *target membership*. They are orthogonal, and Lake resolves any module under `srcDir` on demand:

```
$ lake build Bimodal.Metalogic.WeakCanonical.Kamp.Boneyard.ArityReduction
  ⚠ [1000/1001] Built ...Kamp.Boneyard.NegationIndep (1.5s)
  ⚠ [1001/1001] Built ...Kamp.Boneyard.ArityReduction (1.2s)
  Build completed successfully (1001 jobs).    EXIT: 0
```

Only `unused variable` warnings. **The `Kamp/Boneyard/*` files are green today** — they are simply never exercised by the default build or CI. Their 0-sorry counts are **real**, not artifacts. The `#exit`-ed set is the genuinely-unverified one (`#exit` sits at line 5, *before* the imports at line 7, so Lean parses an empty header and halts) — and even there, drift proved MINOR when actually built.

Correspondingly, **`lake build BoneyardArchive` "passing" is vacuous** and must never be cited as evidence of health: every file it globs halts at `#exit` before elaborating anything.

**One trap worth flagging for the plan:** `Kamp/Prop43.lean` sits **outside** any boneyard directory, has no `#exit`, and imports `Kamp/Boneyard/VecEA_m` + `Kamp/Boneyard/EAVecNegationClosure`. It reads as live code. It is **not built** — an orphan cluster importing an orphan boneyard. Note there are **two distinct** `Prop43.lean` (`Kamp/Prop43.lean`, 9,755 bytes; `Kamp/Boneyard/Prop43.lean`, 8,088 bytes / 196 lines); neither is in the build, and they are easy to conflate. `Kamp/Boneyard` holds **18** `.lean` files, not 17.

**Liveness rule for this tree:** directory location, absence of `#exit`, and a green scoped build are **all** unreliable liveness signals. **Only reachability from `Theories/Bimodal.lean` decides what CI protects.**

---

## Findings — H3 Reference Grounding (tier: **literature**)

Every declaration the transcription needs, mapped to its Rabinovich source BY PDF PAGE.

| Source | Prop/Location | Lean Identifier | Type Signature | Status |
|---|---|---|---|---|
| Rabinovich 2014 | **Def 3.1**, p.4 (exists-forall formula: ordered prefix + `alpha_j` + `beta_j` + tails) | `Rabinovich377Probe.ChainOn` (probe) / `ExistsForallNF.IntervalPattern` | `IntervalPattern (n : Nat) : Type` with `alpha : Fin n → TemporalPred`, `beta : Fin (n+1) → TemporalPred` | **EXISTS, live** — bounded-form delta vs Notation 5.2 UNVERIFIED |
| Rabinovich 2014 | **Def 3.1**, p.4 (semantics) | `ExistsForallNF.IntervalPattern.holds` | `(M : OrderedMonadicStructure sig) → (atomMap : Formula → sig.preds) → IntervalPattern n → M.carrier → M.carrier → Prop` | **EXISTS, live** (`:106`) |
| Rabinovich 2014 | **Lemma 3.2(1)**, p.4 (conjunction -> disjunction) | `VEF.closed_conj` | — | **ADVERTISED, NEVER DEFINED** (trap 2 confirmed) |
| Rabinovich 2014 | **Lemma 3.2(2)**, p.4 (`<=2` free vars) — *the gate* | `Rabinovich377Probe.chain_split` | `(a b c : T) → (alphaC betaMid betaLast : T → Prop) → c < b → ∀ l1 l2, a < c → (ChainOn a (l1 ++ (betaMid, pin c alphaC) :: l2) betaLast b ↔ (ChainOn a l1 betaMid c ∧ alphaC c ∧ ChainOn c l2 betaLast b))` | **PROVED — axiom-free** |
| Rabinovich 2014 | **Lemma 3.2(2)** at m=1, p.7 (`psi_0`/`psi_1`/`phi`) | `Rabinovich377Probe.chain_split_p7_instance` | derived from `chain_split` at `l1 := []` | **PROVED — axiom-free** |
| Rabinovich 2014 | **Lemma 3.2(3)**, p.4 (`∃x phi` closure) | `VEF.closed_ex` | — | **ADVERTISED, NEVER DEFINED** |
| Rabinovich 2014 | **Lemma 3.4**, p.5 (closure: disj/conj/exists) | `VEF.closed_disj` | — | **ADVERTISED, NEVER DEFINED**; only `VEF.disj_holds` exists (`:254`) |
| Rabinovich 2014 | **Prop 3.5**, p.5 (exists-forall -> TL: `A_k AND (B_{k+1} Until (...))` + Since mirror) | `ExistsForallNF.buildRight` / `buildLeft` / `translateEF1` | `buildRight : List (TemporalPred × TemporalPred) → TemporalPred → Formula` | **EXISTS, live** (`:285`, `:298`, `:311`) — correctness UNVERIFIED |
| Rabinovich 2014 | **Def 4.1**, p.5 (`E[Sigma]`-atom fold; depth -> signature) | `NfEFold.EAtomDom` | `ZoneSpec n × NormalForm sig k 1` | **PRESENT but INFIDEL — `beta` slot missing** (the ruling) |
| Rabinovich 2014 | **Def 4.1**, p.5 (fold semantics) | `NfEFold.nf_eval_efold` | `(k n : Nat) → (env : Fin n → M.carrier) → NormalFormEFold sig k n → Prop` | **PROVED but depth-1-ceilinged** (`:102`) |
| Rabinovich 2014 | — (no source counterpart) | `NfEFold.nf_eval_efold_k` | `nf_eval_nf M 0 n env qnf.1 ∧ ∀ sub : NormalForm sig k (n+1), ...` | **NOT A FOLD — grows arity; mis-named. Presumptively WRONG per the acceptance rule** |
| Rabinovich 2014 | **Notation 5.2**, p.8 (`[alpha_0, beta_1, ..., beta_n, alpha_n](z_0,z_1)`) — **the object to adopt** | `VecEAFormula.BracketFormula` + `VecEA2` | `BracketFormula (n) : pointTypes : Fin n → TemporalPred, segmentTypes : Fin (n+1) → TemporalPred`; `VecEA2 (n) : endpointLeft, endpointRight : TemporalPred, bracket : BracketFormula n` | **EXISTS, LIVE, SORRY-FREE** (`:128`, `:252`) — pinned endpoints match Notation 5.2 exactly |
| Rabinovich 2014 | **Def 3.3**, p.4 (`∨exists-forall`) | `VecEAFormula.VVecEA2` | `disjuncts : List (Σ n, VecEA2 n)` | **EXISTS, LIVE, SORRY-FREE** (`:271`) |
| Rabinovich 2014 | **Prop 3.5**, p.5 (Until direction) | `VecEA2.translateLeft` | `VecEATranslation.lean:515` | **LIVE, SORRY-FREE** (0 tactic sorries / 566 lines) |
| Rabinovich 2014 | **Prop 3.5**, p.5 (Since mirror) | `VecEA2.translateRight` / `VVecEA2.translateRight` | `NfToVecEA.lean:413`, `:447` | **LIVE, SORRY-FREE** (`translateRight_correct` `:433`) |
| Rabinovich 2014 | **Prop 4.2**, p.6 (closure under negation over Dedekind complete chains) | `neg_2var_vec_ea` | `(M) (atomMap) (h_UZ : semantic_prior_UZ M atomMap) (v : VVecEA2) (z0 z1 : M.carrier) (h_lt : z0 < z1) (h_neg : ¬v.holds M atomMap z0 z1) : ∃ v' : VVecEA2, v'.holds M atomMap z0 z1` | **PROVED — sorry-free, axiom-clean `[propext, Classical.choice, Quot.sound]`; in boneyard, un-archives to EXIT 0. THE CHARTER'S "STALL" IS FALSE** |
| Rabinovich 2014 | **Section 5 base case**, pp.7-11 (depth-0 `nf -> VecEA` decomposition) | `nf_2var_exist_depth0_tl`, `nf_vecEA2_future/past_correct`, `nf_depth0_existential_decomp` | `NfToVecEA.lean:503`, `:217`, `:259`, `:375` | **LIVE, SORRY-FREE — but DEPTH 0 ONLY** |
| — (**no source counterpart**) | — | `nf_exist_formula_nested_backward` — needs "**the Feferman-Vaught composition theorem for linear orders**" for non-interval zones (1,2,4,5) | `NegationClosure.lean:1670-1722`, `sorry` at `:1722` | **THE REAL GAP.** Not a Rabinovich step — an artifact of routing through `nf_eval_nf`. Same obstruction as `KampPrior.lean:519` |
| Rabinovich 2014 | **Prop 4.2**, p.6 — the live path's face of the same gap | `nf_nvar_exist_all_depths` `k>=2` arm | `KampPrior.lean:519` | **SORRY — same obstruction as `:1722`** |
| Rabinovich 2014 | **Prop 4.3**, p.6 (FO -> disjunction of exists-forall) — **the likely intended route** | `Kamp/Prop43.lean` **and** `Kamp/Boneyard/Prop43.lean` (two distinct files) | — | **BOTH UNBUILT.** Attempted twice, orphaned twice |
| Rabinovich 2014 | **Thm 4.4**, p.6 (Kamp) | `kamp_prior_expressive_completeness` | `KampPrior.lean:648` | **EXISTS, sorry-gated via the above** |
| Rabinovich 2014 | **Lemma 5.1** + **Notation 5.2**, pp.7-8 (`¬[alpha_0,...,alpha_n](z_0,z_1)` is `∨exists-forall`) | `BracketFormula.negFix` / `BracketFormula.negFix_iff` | `EANegationFix/NegFix.lean:454`, `:669` | **CORRECTED — PRESENT, LIVE, SORRY-FREE.** Was `ABSENT` (refuted below) |
| Rabinovich 2014 | **Lemma 5.3**, p.8 (`O_n`; all `beta_i` True; induction on n) | `negChainOn` / `negChainOn_iff` | `EANegationFix/OnBuilder.lean:149`, `:159` | **CORRECTED — PRESENT, LIVE, SORRY-FREE.** Was `ABSENT` (refuted below) |
| Rabinovich 2014 | **eq (5.2)**, p.8 (`INF(z_0,r_0,z_1,P_1)` — anchor factory) | `Kamp/PriorINF.lean` — `HasDefinableINF` (`:108`), `HasAttainedINF` (`:202`) | `Lemma53.lean:282` (`hasDefinableINF_excludes_kplus`) | **CORRECTED — correspondence now VERIFIED, and it FAILS.** `HasDefinableINF` is machine-refuted as strictly stronger than eq (5.2): it deletes the paper's disjunct (2). Faithful carrier still to build |
| Rabinovich 2014 | **Cor 5.4**, p.9 (`F_i := alpha_i ∧ (beta_i Until F_{i+1})`) | `negBoundedRightFix_iff` + Since mirror `negBoundedLeftFix_iff` | `EANegationFix/BoundedFix.lean:449`, `:768` | **CORRECTED — PRESENT, LIVE, SORRY-FREE.** Was `ABSENT` (refuted below) |
| Rabinovich 2014 | **eq (5.3)**, p.10 (`INF^{¬beta_1}`; Case 3) | consumed inside `BracketFormula.negFix_iff`'s Case 3 gate, via the attained pin | `EANegationFix/NegFix.lean:669` | **CORRECTED — PRESENT as the attained pin, not as a named `INF^{¬beta_1}`.** Was `ABSENT`; the *faithful* (non-attained) form is genuinely still absent |
| Rabinovich 2014 | **p.10-11** (`A_i^-/A_i^+/B_i^-/B_i^+`; closing induction) | `negFixList` via `concatPin` + pinned `conjFull` | `EANegationFix/NegFix.lean:424` | **CORRECTED — PRESENT, LIVE, SORRY-FREE.** Was `ABSENT` (refuted below) |
| — (no source counterpart) | — | `nf_eval_nf` | `NormalForm.lean:198-207` | **INFIDEL — arity grows `n -> n+1` per depth; hyperedge quant clause; must be replaced on the characterization path** |

### CORRECTION NOTICE — five `ABSENT` rows were WRONG (recorded in place, not silently rewritten)

The rows above were corrected after the fact. The original text is quoted verbatim here so that a
reader who encountered it sees the refutation rather than a silently-edited table:

> \| Rabinovich 2014 \| **Lemma 5.1** + **Notation 5.2**, pp.7-8 (`¬[alpha_0,...,alpha_n](z_0,z_1)` is `∨exists-forall`) \| — \| — \| **ABSENT** \|
> \| Rabinovich 2014 \| **Lemma 5.3**, p.8 (`O_n`; all `beta_i` True; induction on n) \| — \| — \| **ABSENT** \|
> \| Rabinovich 2014 \| **Cor 5.4**, p.9 (`F_i := alpha_i ∧ (beta_i Until F_{i+1})`) \| — \| — \| **ABSENT** \|
> \| Rabinovich 2014 \| **eq (5.3)**, p.10 (`INF^{¬beta_1}`; Case 3) \| — \| — \| **ABSENT** \|
> \| Rabinovich 2014 \| **p.10-11** (`A_i^-/A_i^+/B_i^-/B_i^+`; closing induction) \| — \| — \| **ABSENT** \|
> \| Rabinovich 2014 \| **eq (5.2)**, p.8 (`INF(z_0,r_0,z_1,P_1)` — anchor factory) \| `Kamp/PriorINF.lean` \| — \| **PARTIAL — live file exists; correspondence UNVERIFIED** \|

**Refutation.** Every one of those five `ABSENT` rows was **present, live, and sorry-free** at the
time the claim was written, in `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegationFix/`.
The whole of Section 5 was transcribed roughly thirteen months earlier and was discoverable by
`grep` throughout. The claim was not a close call — it was the entire directory.

**Why it happened, and why it is not merely an erratum.** Nothing in `EANegationFix/` names
Rabinovich, a section, or a lemma number: `negChainOn` does not read as "Lemma 5.3", and
`negBoundedRightFix` does not read as "Cor 5.4". The search was for the paper's vocabulary; the
tree used its own. The cost was real — a plan version was written to build three phases of work
that already existed, and one dispatch was spent re-deriving it.

**The eq (5.2) row is a different error and is corrected differently.** It was not overclaimed
`ABSENT` but underclaimed `UNVERIFIED`. The correspondence has since been *verified and found to
FAIL*: `hasDefinableINF_excludes_kplus` (`Lemma53.lean:282`, axiom-clean) machine-proves that
`HasDefinableINF` is strictly stronger than eq (5.2) because it deletes the paper's disjunct (2).
"Unverified" was hiding a real defect, not a missing checkmark.

**Standing correction to what the present rows do NOT say.** All the `PRESENT, LIVE, SORRY-FREE`
rows above hold at the **attained** carrier (`HasAttainedINF`/`HasAttainedSUP`), which is
strictly stronger than the Dedekind completeness Rabinovich assumes — stronger even than
`HasDefinableINF`. They are therefore Section 5 *restricted to attained structures*, not Section
5. In particular `BracketFormula.negFix_iff` (`NegFix.lean:669`) is INF-anchored and is **not** a
refutation of the ruling that the model-*independent* Prop 4.2 backward direction is unfixable at
the `BracketFormula` level — it confirms that ruling's diagnosis, since the anchors are exactly
what make the direction go through. It must never be cited as license for a further bare attempt.

**Guard.** The correspondence table is now landed in-tree and CI-protected at
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Section5Correspondence.lean`, reachable from
`Theories/Bimodal.lean`. A finding recorded only in a report is a finding that gets re-derived;
that is the failure this notice documents, and an unreachable guard would repeat it.

**Source-coverage note (H3 no-single-source rule)**: every load-bearing claim above is cross-checked against at least two independent sources — the PDF plus either a machine check (probe / in-repo axiom-clean lemma) or a verbatim in-tree declaration read. No claim rests on the PDF alone or on prior reports alone.

---

## Literature Proof Structure (Tier 1)

Rabinovich's route, with what each step costs here:

| Step | PDF | Content | Transcription status |
|---|---|---|---|
| Def 3.1 | p.4 | exists-forall formula: `∃x_n...∃x_0`, ordering, `alpha_j` at points, `beta_j` on segments, tails | object exists (`IntervalPattern`); deltas to verify |
| Lemma 3.2(1) | p.4 | conj of exists-forall == disj of exists-forall | **absent** (harder: merging two chains needs a disjunction over interleavings) |
| **Lemma 3.2(2)** | **p.4** | **every exists-forall == conj of `<=2`-free-var exists-forall** | **GATE CLEARED — axiom-free** |
| Lemma 3.2(3) / 3.4 | pp.4-5 | closure under `∃`, disj, conj | **absent** |
| Prop 3.5 | p.5 | exists-forall (1 free var) -> TL, via nested Until / Since | transcribed (`translateEF1`); correctness unverified |
| Def 4.1 | p.5 | `E[Sigma]` canonical expansion; **depth -> signature, never arity** | **the ruling** — `EAtomDom` needs the `beta` slot |
| **Prop 4.2** | **p.6**, proved **pp.7-11** | **closure under negation over Dedekind complete chains** | **THE WORK.** Fully printed. Prior path stalled here. |
| Prop 4.3 | p.6 | FO -> disj of exists-forall, by structural induction (uses 3.2(2) at the Negation case) | `Kamp/Boneyard/Prop43.lean`, unverified |
| Thm 4.4 | p.6 | Kamp's theorem | exists, sorry-gated |

**Section 5's internal order (pp.7-11) — transcribe in this sequence:**
1. p.7 — split `psi(z_0,z_1)`; case `k = m` (`z_0 = z_1`) vs `k != m` (**PDF is arbiter; the companion `.md` inverts this at md:199**). WLOG `m < k`. Reduce to `psi_0(z_0) AND psi_1(z_1) AND phi(z_0,z_1)`.
2. p.7 — Lemma 5.1 (eq 5.1): the target is `¬[...](z_0,z_1)` is `∨exists-forall`.
3. p.8 — Notation 5.2; Lemma 5.3 (`O_n`, all `beta_i` True), induction on `n`, Case 1 / Case 2, `r_0` via Dedekind, **eq (5.2)** `INF`.
4. p.9 — Cor 5.4: `F_n := alpha_n`, `F_{i-1} := alpha_{i-1} ∧ (beta_i Until F_i)`; (2) is the mirror.
5. pp.9-10 — Lemma 5.1 proper: Cases 1-3; **Figure 1** (p.10); **eq (5.3)** `INF^{¬beta_1}`; footnote 4: **existence only, no uniqueness**.
6. pp.10-11 — `A_i^-/A_i^+/A_i` and `B_i^-/B_i^+/B_i`; the two displayed equivalences (p.11); (a)-(e); closing induction. **Completes Prop 4.2.**

---

## Recommendations (plan-facing)

**The task must be RESCOPED before planning.** It is chartered as "transcribe Rabinovich sections 3-5". Sections 3-5 are, to a first approximation, **already transcribed** — the faithful object is live and sorry-free, Prop 3.5's two translations are live and sorry-free, Prop 4.2 is proved and needs only un-archiving. Planning the chartered scope would rewrite ~1,204 lines of verified proof and never touch the actual gap.

1. **Rescope to the real gap: the `nf_eval_nf -> VecEA2` bridge above depth 0.** This is the one thing missing, it is where **both** the live path (`KampPrior.lean:519`) and the archived path (`NegationClosure.lean:1722`) stall, and it is **not a Rabinovich step** — it is the cost of a type-first architecture. Everything the paper prints is done or recoverable.
2. **Prefer the architectural fix to proving Feferman-Vaught.** The archived path concluded it needed "the Feferman-Vaught composition theorem for linear orders" — a genuinely hard theorem, and exactly the "novel mathematics" the binding user constraint forbids. **Rabinovich never needs it**, because he never converts a Hintikka type into an `∃∀`-formula: Prop 4.3 (p.6) does structural induction over **formulas**, with already-processed depth folded into the signature as a unary `E[Sigma]`-atom (Def 4.1, p.5), so composition is structural (the treewidth-1 fact of Q1) rather than a theorem. **The intended route is formula-first: prove Prop 4.3 by structural induction, then apply it to the depth-`k` 1-type's Hintikka formula — which is itself an FO formula.** Lemma 3.2(2) (gate CLEARED) and Prop 4.2 (proved) are exactly the two ingredients Prop 4.3's Negation case consumes, and both are now in hand. **Confidence: Medium — this is a design judgment, not a machine check, and it is the single most important thing for the plan to probe first.** Note `Kamp/Prop43.lean` and `Kamp/Boneyard/Prop43.lean` both exist and are both unbuilt: Prop 4.3 was attempted twice and orphaned twice.
3. **Adopt `VecEA2` / `BracketFormula` (`VecEAFormula.lean:128,252`) as the Def 3.1 object** — not `EAtomDom`, and not `IntervalPattern`. It is Notation 5.2 (p.8) exactly, **including the pinned endpoints** `IntervalPattern` lacks; it is live; it is sorry-free; and Prop 4.2 is already proved about it. `BracketFormula.toIntervalPattern` (`:135`) bridges to `IntervalPattern` if needed.
4. **Un-archive rather than rewrite.** Restore `NegationClosureProp42.lean` (+ `NegationClosure5.lean`) by stripping the 4-line header and the `#exit` — **verified to build at EXIT 0, axiom-clean, no other edit needed**. Drift across the whole faithful path is purely module-path renames (93 modules: 74 live, 21 boneyard-resident, **0 absent**). Do NOT re-transcribe Prop 4.2.
5. **Do not adopt `NfEFold` as-is.** Its diagnosis is right; its `EAtomDom` is missing Def 3.1's `beta` slot, and `nf_eval_efold_k` is a mis-named arity-growing non-fold. Under the acceptance rule ("anything without a source counterpart is presumptively WRONG"), `nf_eval_efold_k` has **no** source counterpart and should be treated as refuted, exactly as arity-4 `charFib` was. `VecEA2` supersedes it.
6. **Sequence `KampPrior.lean:522` first.** It is mechanically retirable by restructuring the declaration — no encoding work, no Prop 4.2. The only DoD item obtainable independently; it converts the DoD from all-or-nothing into two milestones and yields an early green commit.
7. **Land the probe's `chain_split`** as the reusable Lemma 3.2(2) primitive. The gate is CLEARED and axiom-free — do not re-litigate it. Note it is itself a composition/gluing theorem at a shared anchor over a bare `LinearOrder`, i.e. **structurally the same shape as the "FV composition" the archived path wanted** — plausibly the seed of recommendation 2's route, and worth trying against the non-interval zones (1,2,4,5) before reaching for the literature theorem.
8. **Do not spawn cleanup.** The charter's 29% load-bearing split via `kampArm_*_k0/_k1` and the frozen byte-identity surfaces stand. Any reclamation is surgical decl excision, and only after the faithful path is green. **Do not delete the boneyard**: `Kamp/Boneyard/*` is green-on-demand and `KampNegationClosure` holds a verified Prop 4.2.

---

## Adversarial Self-Verification

Each load-bearing claim below was attacked, not just restated.

| Claim | Source/Counterexample |
|---|---|
| Lemma 3.2(2)'s `m -> m+1` step is routine (GATE CLEARED) | **Attacked**: wrote the probe so a hidden gap would surface as a required hypothesis (completeness / density / rigidity). None appeared; it closed axiom-free over a bare `LinearOrder`. Corroborated by the paper's own hypothesis structure: Lemma 3.2 (p.4) carries NO completeness hypothesis while Prop 4.2 (p.6) does — the probe reproduces that asymmetry rather than assuming it. **Verification: `lake env lean` sorry-free + `#print axioms` = no axioms. Confidence: High.** |
| Residual risk on the gate | **Not fully refuted.** `ChainOn` is my transcription of Def 3.1's shape, not the repo's `IntervalPattern`, and not a syntactic formula class. If `ChainOn` mis-transcribes Def 3.1, the gate result is about the wrong object. Mitigation: `ChainOn`'s conjuncts were checked one-by-one against the p.4 list (table in Q1), and `chain_split_p7_instance` reproduces Rabinovich's *printed* p.7 split — an independent check that the object is his. **Confidence: Medium-High, not High.** |
| The charter states the ruling INVERTED | **Attacked** by trying to read it charitably; could not. The repo's own `endCharN0_correct_infeasible` (`Base.lean:1779`, "UNPROVABLE", axioms exactly `{propext, Classical.choice, Quot.sound}`) proves the repo-side NON-theorem; my axiom-free `chain_split` proves the Rabinovich-side theorem. Both directions machine-checked, on opposite sides from the charter's wording. **Verification: two independent machine checks. Confidence: High.** |
| Arity growth is in `nf_eval_nf`'s DEFINITION, not the recursion | **My first hypothesis was WRONG and I caught it.** I initially claimed the recursion escalates arity `(k+1,n) -> (k,n+1)`. Reading `KampPrior.lean:407` refuted this: the call is `nf_nvar_exist_all_depths ... k 1` — arity RESETS to 1. The true mechanism is IH-starvation: goal needs arity 3 (from unfolding `nf_eval_nf` at depth `k+1` arity 2 -> quant layer over `NormalForm sig k 3`), IH supplies arity 2. **Verification: verbatim read of `NormalForm.lean:198-207` + `KampPrior.lean:346-420`. Confidence: High.** Flagged because the wrong version would have licensed "fix the recursion", which cannot work. |
| `NfEFold`'s `EAtomDom` is missing Def 3.1's `beta` layer | **Attacked** the file's own defense (`NfEFold.lean:100`: `beta` carried by `quant_assignment e = false`). Refuted: `zoneHolds M env e.1 x` constrains `x` only against ENV points; with `env = (t)`, `ZoneSpec 1` cannot express "no point in the open interval `(x,t)` has type `tau`" because `x` is the bound variable. Def 3.1's `beta_j` lives on `(x_{j-1},x_j)` — between two WITNESSES. **Verification: `lean_hover`-equivalent verbatim read of `NfEFold.lean:52-110`; corroborated independently by the file's own retreat to full arity at `k>=1` (`:608`), which is what this defect predicts. Confidence: Medium-High.** |
| `nf_eval_efold_k` is a mis-named non-fold | Its OWN docstring (`NfEFold.lean:608`): *"NO arity-1 collapse: subs are read at `nf_eval_nf M k (n + 1)`"*, and the section note *"at depth `k >= 1` only the full-arity `nf_eval_efold_k` remains faithful"*. **Verification: verbatim. Confidence: High.** |
| `NfMultiAnchorBridge` is founded on the arity-growing bridge | **Verification: 6+ call sites of `nf_eval_nfk_iff_efold` across `ExteriorConverterK.lean:28/:209/:223`, `ExteriorBracketK.lean:10/:322`, `ExteriorPinnedProbeK.lean:528`, `ExteriorGateAssembleK.lean:53`. Confidence: High.** Scope caveat: this does NOT contradict the charter's 29% load-bearing finding — `kampArm_*_k0/_k1` are the `k<=1` arms, exactly where the depth-1 fold DOES work. The two findings are consistent and mutually explanatory. |
| Both sorries must go for axiom cleanliness | Reproduced independently: both sit in the single `noncomputable def nf_nvar_exist_all_depths`; `sorryAx` is tracked per-declaration, not per-path. Matches the DoD's two proof-term traces. **Confidence: High.** |
| `:522` is mathematically off-path (the in-code comment is right) | **Attacked** — I expected to refute this comment and could not. Recursion resets arity to 1 (`:407`); live entry is `n = 1`; `n >= 2` is unreachable. The comment is correct; it is merely irrelevant to axiom tracking. **Confidence: Medium-High** — reachability was established by reading the recursion, not by a machine check. |
| A faithful transcription closes `completeness_discrete` end-to-end | **NOT machine-verified — the weakest load-bearing claim in this report.** It depends on the arity-2 type of `(x,t)` being reconstructible from order + two 1-types + interval type, which is Lemma 3.2(2) applied to the NF encoding — argued, not proved. The prior faithful path stalled at exactly this region. **Confidence: Medium-High. Flagged for the plan as the first thing to probe.** |
| Prop 4.2 is fully printed (pp.7-11) | **Verification: direct PDF read of pp.7-11 — Lemma 5.1, Notation 5.2, Lemma 5.3, Cor 5.4, eq 5.2/5.3, Fig 1, closing induction all present with proofs. No "It is clear that" anywhere in section 5. Confidence: High.** |
| **"The faithful path stalled at Prop 4.2"** (task description, report 08, charter) | **REFUTED — the task's central premise.** `neg_2var_vec_ea` (`NegationClosureProp42.lean:159-169`) is a real tactic proof delegating to `neg_disjunct_list`, sorry-free. **Verification: read verbatim by me, AND independently built after un-archiving — `lake build ...Kamp.NegationClosureProp42` EXIT 0, `#print axioms` = `[propext, Classical.choice, Quot.sound]`, no sorryAx.** The real stall is one level up at `NegationClosure.lean:1722`. **Confidence: High.** Consequence: the chartered scope would rewrite ~1,204 lines of verified proof. |
| The archived and live stalls are the SAME obstruction | **Attacked** by looking for a way they could be different defects. Could not: the archived blocker comment says the gap is `∃y, nf_eval 3 (y,x,t) ssn` at "k>=1", i.e. an arity-3 read; the live `:519` defect I derived independently is "goal needs arity 3, IH supplies arity 2". Same arity, same depth condition, same encoding. Corroborated by `NfToVecEA.lean` being **depth-0 only** — matching the blocker's "At k=0 ... purely atomic / At k>=1 ... requires full FV composition" line-for-line. **Two independent derivations converging. Confidence: High.** |
| The encoding boundary is the proved/stalled boundary | **Verification: `grep -c nf_eval_nf` = 0 in the PROVED file, 42 in the STALLED file; `VecEA2`/`BracketFormula` read verbatim and matched against Notation 5.2 (p.8).** Two files, same author, same paper, same period, differing in encoding and in nothing else material. **Confidence: High** for the correlation. **Medium** for the causal reading — n=2 is a small natural experiment, and I did not re-run either proof under the opposite encoding. The mechanism (Q4's treewidth argument) supplies the causal story independently. |
| FV composition is avoidable via the formula-first route | **NOT verified — the weakest claim in the report, and I am flagging it rather than asserting it.** The argument: Rabinovich's Prop 4.3 (p.6) inducts over FORMULAS with depth folded into the signature (Def 4.1, p.5), so composition is structural (Q1's treewidth-1 fact) and never a theorem. But I did not build it, and the live target `nf_characterizable_temporal_prior` is *stated* against `nf_eval_nf M k 1`, so a bridge is needed somewhere — I claim arity 1 suffices, which is unproven. That `Prop43.lean` exists twice and is unbuilt twice is weak evidence the route was tried and abandoned, though for unknown reasons. **Confidence: Medium. The plan must probe this before investing.** |
| No archived faithful-path code is verified | **PARTIALLY REFUTED — my own first-draft claim, corrected.** I wrote that `Kamp/Boneyard/*` was "never type-checked", conflating **target membership** with **compilability**. A scoped `lake build ...Kamp.Boneyard.ArityReduction` returns **EXIT 0** with only unused-variable warnings: those files are **green today**, their 0-sorry counts are **real**, and Lake resolves any module under `srcDir` on demand. What the import walk actually proves is narrower: they are outside the default target, so CI never exercises them. The `#exit`-ed set is the genuinely-unverified one — and even there, restoring two files and building proved drift MINOR. **Verification: lakefile read + import-graph walk (234 modules) + two actual scoped builds. Confidence: High** for both facts, now kept distinct. |
| `lake build BoneyardArchive` passing means the archive is healthy | **REFUTED, and worth stating because it is an inviting trap.** `#exit` sits at line 5, *before* the imports at line 7 — Lean parses an empty header and halts. The target passes **vacuously**, elaborating nothing. Never cite it as evidence. |
| `grep -c sorry` measures sorry debt | **REFUTED twice.** ~40 grep hits across the archived files reduce to **4** real tactic-position sorries (`NegationClosure.lean:1333` — annotated off-critical-path — and `:1722`; `RabinovichGeneralized.lean:471`; `RabinovichWiring.lean:365`). The rest is docstring prose *about* sorry status. The same trap fired on `NfEFold.lean`, whose single hit is the word "sorry-free" — I caught that one only because the count looked implausible. **Any plan budgeting from grep counts is budgeting from prose.** |
| `Kamp/Prop43.lean` is live | **REFUTED — my own working assumption.** It sits outside any boneyard, has no `#exit`, and imports two `Kamp/Boneyard` modules, so it reads as live. The import walk shows it is **not reachable from the root** and never compiled. Recorded because it demonstrates that in this tree neither directory location nor `#exit` is a reliable liveness signal — only reachability from `Theories/Bimodal.lean` is. **Confidence: High.** |
| Trap (2) confirmed | Full declaration list of `ExistsForallNF.lean` contains `VEF.disj`/`VEF.disj_holds` only; `closed_conj`/`closed_ex`/`closed_disj` appear solely in the docstring. **Confidence: High.** |

### Contradiction Log

| Contradiction | Resolution |
|---|---|
| Charter: "Lemma 3.2(2) is a theorem about the repo's encoding and a NON-THEOREM about Rabinovich's" **vs** two machine checks showing the reverse | **RESOLVED in favor of the machine checks** (precedence: machine-checked artifact > prior-report prose). Read as a transcription slip in the charter — its surrounding reasoning is consistent with the corrected direction. Must not propagate into the plan. |
| Charter: "The LIVE chain needs only arity <=2" **vs** the `k>=2` sorry requiring arity 3 | **RESOLVED, both true of different things.** The chain's *statement* arity is <=2 (`nf_characterizable_temporal_prior` takes `NormalForm sig k 1`, steps via `k 2`) — correct. But `nf_eval_nf`'s *definition* demands arity 3 at depth `k`. The charter describes the interface; the sorry lives in the unfolding. |
| `NfEFold.lean:8` "Nothing in the existing development imports this file" **vs** 6 live importers | **RESOLVED**: docstring is stale. Filesystem wins. |
| `KampPrior.lean:522` "off the critical path" **vs** DoD requiring its retirement | **RESOLVED, both correct.** Off-path mathematically; on-path for per-declaration axiom tracking. |
| **Charter + task description + report 08: "the faithful path stalled at Prop 4.2"** **vs** `neg_2var_vec_ea` being a sorry-free, axiom-clean, still-building proof of Prop 4.2 | **RESOLVED against the charter** (precedence: machine-checked artifact > inherited prose). Prop 4.2 is proved; the stall is `NegationClosure.lean:1722`, one level up, and is not a Rabinovich step. This premise appears to have been inherited unexamined across reports 04-08 and into this task's charter. **It invalidates the chartered scope**, which is why this report leads with a rescope rather than a transcription plan. |
| Charter: "archived as **dead code**" **vs** the archive containing a verified Prop 4.2 | **RESOLVED, both true but the label misleads.** Archival commit `82d7bf6f2` was a pure `git mv` on a **reachability** criterion ("no live importers") — never a correctness criterion. "Dead" meant unreferenced, not broken. Reading it as "broken" is what makes rewriting look necessary. |
| My first draft: `Kamp/Boneyard/*` "never type-checked" **vs** a scoped build returning EXIT 0 | **RESOLVED against my own claim.** Target membership and compilability are independent; Lake resolves any module under `srcDir` on demand. Corrected in Q2. |
| Charter trap (1): `endInterval_correct` is arity-1 charF machinery, mis-bucketed by report 06 | **NOT INDEPENDENTLY VERIFIED this dispatch** — accepted from the charter, not re-checked. Does not bear on any conclusion here. Given that the charter's central premise proved false, its unverified claims should be re-checked before use rather than inherited. |

### Recommendations modified after verification

This report was revised **three times** by its own verification. Recording the sequence, because the final answer is nearly the opposite of the first draft's:

- **Dropped** "adopt `NfEFold` as the faithful encoding" — my working assumption through the first half of the dispatch, and the charter's implied direction. Reversed on finding the missing `beta` slot and the `nf_eval_efold_k` retreat.
- **Then dropped** "adopt `IntervalPattern`" — my *replacement* recommendation — on finding `VecEA2`, which is Notation 5.2 exactly (pinned endpoints included, closing the very fidelity delta I had flagged against `IntervalPattern`), is live, is sorry-free, and already has Prop 4.2 proved about it.
- **Rescoped the entire task** on verifying Prop 4.2 is proved. The first draft accepted the charter's "stalled at Prop 4.2" premise and recommended transcribing section 5 in six phases. That would have rewritten ~1,204 lines of verified proof. The report now leads with the rescope.
- **Corrected** my "never type-checked" claim about `Kamp/Boneyard/*` after a scoped build returned EXIT 0 — I had conflated target membership with compilability.
- **Added** recommendation 2 (formula-first route) — the only recommendation that addresses the actual gap, and the one I am least confident in. Flagged Medium and marked as the plan's first probe rather than presented as settled.
- **Added** recommendation 6 (sequence `:522` first) — from establishing `:522` is unreachable, hence retirable by restructuring rather than proof.

**Process note against my own conclusions**: the two largest corrections both came from *outside* my initial line of attack — the delegated archive measurement produced the premise falsification, and it arrived after I had already written a complete report built on the false premise. Had I not delegated it, or had I accepted the charter's framing as the prior reports did, this dispatch would have produced a confident, well-cited, thoroughly wrong plan. The charter's framing was itself inherited unexamined across reports 04-08.

### UNRESOLVED

**None material to the ruling.** The one open item at first draft — `Kamp/Boneyard/*` build membership — was resolved before submission (lakefile + import-graph walk): **not built**. See Q2.

Two residual items, neither load-bearing:

- **Import drift of the `#exit`-ed files** (CLEAN / MINOR / MAJOR against Lean v4.27.0-rc1) is unmeasured. Now largely moot: since *nothing* in the archive is type-checked, the plan should cost re-elaboration regardless, and the drift grade would only refine an estimate, not change the approach. A parallel measurement was delegated and had not returned at write time.
- **Charter trap (1)** (`endInterval_correct` is arity-1 `charF` machinery, mis-bucketed by report 06) was accepted from the charter and not independently re-checked. It bears on no conclusion here.

---

## References

- Rabinovich, A. (2014). *A Proof of Kamp's Theorem*. PDF pp.3-14 read directly.
  Def 3.1 p.4 · Lemma 3.2 p.4 · Def 3.3 p.4 · Lemma 3.4 p.5 · Prop 3.5 p.5 · Def 4.1 p.5 · Prop 4.2 p.6 · Prop 4.3 p.6 · Thm 4.4 p.6 · Lemma 5.1 p.7 · Notation 5.2 p.8 · Lemma 5.3 p.8 · eq (5.2) p.8 · Cor 5.4 p.9 · Fig 1 p.10 · eq (5.3) p.10 · closing induction pp.10-11
- Probe: `specs/377_transcribe_rabinovich_faithful_nf_encoding/reports/01_lemma32-anchor-split-probe.lean` (compiles sorry-free; axiom-free)
- Prior art: `specs/376_arity_general_zone_decomposed_char_engine/reports/` 04-08 (esp. 07 source-fidelity, 08 charter)
