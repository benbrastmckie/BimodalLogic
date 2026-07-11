# Task 347 — Rabinovich Bracket Faithfulness Review + Revision Adjudication

- **Task**: 347 — faithfulness review of the task-346 `hexclExt` gate against Rabinovich 2014 §5.
- **Dispatch**: hard-mode lean4 research (H2 anti-analysis / H3 reference-grounding / H4 adversarial verification), `--lit` active.
- **Session**: sess_1783792054_45a555
- **Date**: 2026-07-11
- **Ground truth**: `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md` — **full 495-line text present and read directly** (not the 2,721-token corpus summary; the `.md` here is the authoritative full LMCS article). Cited by the article's own page numbers (pp. 7–11 = §5).
- **Deliverable**: adjudication report only. No Lean file edited (research phase).

---

## VERDICT (one line)

**(b) SUBSTANTIVE — with a sharpening that changes the successor's method.** The encoding did **not** drop per-witness ordering content (the order literals are present in the atom layer and the "zone" is a lossless re-encoding of them — verified below). What it dropped is Rabinovich's **bound on the OUTER existential** (`(∃z)^{<z1}_{>z0}`, Cor 5.4): `nf_eval_nf` (`NormalForm.lean:198–207`) quantifies the outer/fresh witness over **all of `M.carrier`** and runs a **full biconditional over all sub-forms**, so the characterized object (`qnf`) globalizes over **exterior-arrangement** subs that Rabinovich's `(z0,z1)`-bracket never characterizes. `hexclExt` is the residue of that globalization — **a phantom obligation with no counterpart in the paper**. It is neither cheap encoding-debt (verdict (a) is false as stated) nor a genuine "prove exterior completeness" theorem (the successor spec's framing is wrong). The faithful fix is Rabinovich's **Prop 4.3 re-flatten** (adjacency composition of a separate exterior bracket), not an exterior-exclusion proof on the interior `(x,t)` bracket.

**Recommendation for `prop43_exterior_completeness`**: **RETIRE the "prove strictly-exterior completeness" framing; UPDATE/REPLACE** with a re-flatten task (details in §7).

---

## H3 Reference-Grounding — Tier 1 (literature-backed: Rabinovich 2014), 5-column

Every load-bearing claim grounded to BOTH a Rabinovich §5 location (full-text page) AND a Lean `file:line` (tree-verified this dispatch; atom-layer facts personally re-read, gate binders confirmed via a read-only sub-scan).

| Source (Rabinovich 2014) | Prop / Location (full-text verified) | Lean Identifier | Type Signature / Content (tree-verified) | Faithfulness Status |
|---|---|---|---|---|
| **Lemma 5.1** (p.7) | `¬[α0,β1,…,αn](z0,z1)` ≡ ∨⃗∃∀; `αi,βi` **quantifier-free** | `bracketEndChar_kvE2_sound_two_prior_frag` | `OuterGate.lean:245` (soundness half of the bracket↔¬realization gate) | **PARTIAL** — captures interior + boundary; exterior arrangement carried as `hexclExt` residue (not in Lemma 5.1) |
| **Notation 5.2** (p.7) | `[α0,β1,…,αn](z0,z1)` abbreviates the ⃗∃∀ block; witnesses `z0<x1<…<xn<z1` **strictly interior** | `NormalForm sig k n` + `AtomKind.order` | `NormalForm.lean:58–60`, `113–117` (order atoms `env i < env j`) | **FAITHFUL at atom layer** — ordering IS encoded; bound is per-σ, not on the outer ∃ |
| **Lemma 5.3** (p.8, l.225) | `¬∃x1…∃xn (z0<x1<…<xn<z1) ∧ ⋀Pi(xi)` ≡ ∨⃗∃∀ `On`; induction on `n` | `kvE2_sepPosI` (interior index) + `kvE2_sepFragment` | `SharedWitness.lean:211–214`; `OuterGate.lean:200` | **BASIS-ONLY** — interior-singleton = Lemma 5.3 base + one navigation; full `On` induction (n≥2, nested K⁺) absent |
| **Lemma 5.3 Case 2** (p.8, l.231–247) | `r0 = inf{z∈(z0,z1)\|P1(z)}`; subcase `r0=z0` ⟺ **K⁺(P1)(z0)** (endpoint), subcase `r0∈(z0,z1)` interior | `kvE2_sep_zXW3`/`kvE2_sep_zWT3` (strict-interior zones) vs `hexcl` cone `x ≤ x1 ≤ t` (non-strict) | `SharedWitness.lean:79–88` (zones); `:12653–12657`/`OuterGate.lean:274–279` (cone) | **DIVERGENT** — closed cone conflates strict interior with endpoint ties; no separate K⁺/K⁻ atom |
| **Corollary 5.4** (p.8–9, l.257–279) | `¬(∃z)^{<z1}_{>z0}[…](z0,z)` — **outer ∃ is BOUNDED**; ⇐ builds one jointly-ordered interior sequence | `nf_eval_nf` outer/quant layer | `NormalForm.lean:198–207` — `∃ (x : M.carrier)` **UNBOUNDED**; biconditional over **all** `sub_nf` | **DIVERGENT (root cause)** — outer ∃ unbounded ⇒ exterior-arrangement subs in scope ⇒ `hexclExt` |
| **Lemma 5.1 proof, Case 1/2/3** (p.9–11, l.285–335) | cases are interior/boundary only (`x∈(z0,z1)`, `K⁺(¬β1)(z0)`, `β1 on (z0,z1)`); **no exterior case** | `hexclExt` | `SharedWitness.lean:12665–12669`; `OuterGate.lean:280–285`; guard `¬(x ≤ x1 ∧ x1 ≤ t)` | **NO SOURCE COUNTERPART** — the paper never quantifies outside `(z0,z1)` |
| **Prop 4.3 / Fig. 1** (p.6, l.169–181; p.10, l.297–299) | broader intervals via **structural induction / adjacency** `B2(z0,z,z1):=[…](z0,z)∧[…](z,z1)` (re-flatten), using Prop 4.2 negation | (no engine) | — | **MISSING** — the re-flatten that would place exterior witnesses in their own bracket |
| **§7 Lemma 7.6** (p.13, l.413) | compose `(z0,z1)`-∨⃗∃∀ with `(z1,z2)`-∨⃗∃∀ under `(∃z1)^{<z2}_{>z0}` | (no engine) | — | **MISSING** — the adjacency-composition primitive the faithful exterior route needs |

---

## Core Adjudication

### C1. The order literals ARE present — so this is NOT a wholesale "dropped ordering" defect

Personally re-read (`NormalForm.lean`):

- `:58–60` — `AtomKind` has an `order (i j : Fin n) (h : i ≠ j)` constructor alongside `pred`.
- `:113–117` — `atom_eval M env (.order i j _) = (env i < env j)`.
- `:201–207` — `nf_eval_nf` depth-0 clause forces `∀ a, atom_eval M env a ↔ (assignment a = true)`; so a sub-form's order atoms are pinned to the model order of the env points `[x1,w,x,t]`.

Confirmed (read-only gate scan): `ZoneSpec` (`NfEFold.lean:52`) and `nf0_zoneSpec` (`:153–156`) are a **lossless bijective projection of exactly those `.order` atoms** (four round-trip lemmas certify the bijection); `kvE2_sepPosI` (`SharedWitness.lean:211–214`) restricts to interior subs precisely by the **order-literal predicate** `nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ = kvE2_sep_zWT3` (i.e. `x<x1<w ∨ w<x1<t`, strict).

**Consequence for verdict (a):** for an **interior-marked** σ (a `kvE2_sepPosI` element), an exterior `x1` falsifies an order atom (`x<x1` false when `x1<x`), so `¬ nf_eval_nf … σ` is **free** from the atom layer. So the *interior slice* of `hexclExt` is cheap. **But `hexclExt` as landed quantifies over the GLOBAL `∀ σ, qnf.2 σ = false`** (`SharedWitness.lean:12665–12669`), **not** restricted to interior σ. Its hard content is **exterior-arrangement** σ (those marking `x<x1` false), for which the order atoms give *nothing* — a matching exterior `x1` satisfies them. Hence **(a)'s "cheap to discharge" is FALSE** for the obligation actually stated.

### C2. What was really dropped: the outer-∃ bound (Cor 5.4), not the per-σ order atoms

Rabinovich's bracket witnesses are **strictly interior** (Notation 5.2 / Lemma 5.3: `z0<x1<…<xn<z1`) and the **outer existential is bounded** (Cor 5.4: `(∃z)^{<z1}_{>z0}`). The negation proof (Lemma 5.1, pp.9–11) analyses **only** interior occurrence and endpoint limits (`x∈(z0,z1)`, `K⁺(¬β1)(z0)`, `β1 along (z0,z1)`); **no case ever considers a point outside `(z0,z1)`.** Fig. 1 (p.10) shows broader coverage is obtained by **splitting the interval at an interior `z`** (`B2(z0,z,z1)`), i.e. adjacency, never by extending a single bracket past its endpoints.

The Lean `nf_eval_nf` (`NormalForm.lean:203–207`) instead evaluates the outer/fresh witness as `∃ (x : M.carrier)` — **unbounded** — inside a **full biconditional over every `sub_nf`**. So the characterized `qnf` records realization facts for **every** arrangement of the witness against the anchors, including `x1<x`, `x1>t`, and endpoint ties — arrangements Rabinovich's `(x,t)`-bracket **excludes a priori by its ordering conjunct**. `hexclExt` (the `¬(x ≤ x1 ∧ x1 ≤ t)` slice) is exactly the bookkeeping for those out-of-bracket arrangements. It is an **artifact of globalizing a quantifier Rabinovich keeps bounded**, not a gap in Kamp's theorem.

This sharpens — and is fully consistent with — the prior findings: 330 report 01 (REDESIGN / navigated fold + Prop 4.3 re-flatten) and 335 report 07 Refutation 2 ("category mismatch at the inner-bits layer"; "gate-legal tables with unmarked realizable exterior types exist"). The reason `hexclExt` cannot be discharged from model facts (335 Ref 2's satisfiable-set argument) is precisely that it asks a **completeness** question ("no exterior point realizes a `qnf`-false sub") about arrangements the source never brackets. Proving it = proving a hard, unnecessary theorem.

### C3. Why "restore the bound" cannot be a one-liner, and what the faithful move is

`nf_eval_nf` is foundational (it is FOMLO `∃x` semantics; the unbounded ∃ is *correct* as raw semantics). You cannot bound it in place. Rabinovich's device for the unbounded FOMLO `∃x` (Prop 4.3, pp.6; Lemma 3.2(3)) is to **re-flatten**: push `∃x` into a **disjunction over witness arrangements**, each a bounded bracket over an adjacent sub-interval, composed by adjacency (Lemma 7.6). The faithful encoding therefore must **decompose** the single all-arrangement `qnf` characterization into: interior `(x,t)` bracket (landed, 346) + boundary K± + **a separate exterior bracket** (`(t,∞)` / `(−∞,x)`) composed by adjacency — **not** a single monolithic biconditional patched with `hexclExt`.

---

## MUST-CHECK Items

### (1) Strictness — interior brackets + K± vs the boundary-inclusive cone (double-counting check)

Rabinovich: strict interior `z0<x1<…<xn<z1` (Lemma 5.3) with endpoints handled by **K⁺/K⁻ limit operators** (§2.2 (2)(3), p.3: `K⁻(F)` holds at `t` iff `t=sup{t'<t\|F(t')}`; Lemma 5.3 Case 2 subcase `r0=z0` ⟺ `K⁺(P1)(z0)`). Interior is **open**; endpoints are **predicates at the anchor**, never witnesses.

346's gate: `hexcl`/`hexclExt` guard the ambient `x1` by the **non-strict closed cone** `x ≤ x1 ≤ t` (`OuterGate.lean:274–285`), and Phase 4 realizes "boundary positives" as endpoint/witness literals **inside** that cone. But the interior σ-zones `kvE2_sep_zXW3`/`_zWT3` are **strict** (order atoms are strict `<`; `AtomKind` has **no equality atom**, so `x1=x` yields the tie-zone `(false,false)`, distinct from both interior zones). Therefore the closed cone's boundary points `x1∈{x,t}` realize only **tie-zone** σ — Rabinovich's K⁺/K⁻ material — which 346 folds into the same cone rather than isolating as K± atoms.

**Finding**: the trichotomy does **not** map cleanly to "interior-brackets + K±". The boundary-inclusive cone **conflates** strict interior (bracket witnesses) with endpoint ties (K± limit content). This is a strictness-faithfulness divergence (not a numerical double-count of a single point, but a **category conflation**: endpoint-tie content is mis-housed in the interior cone instead of a K± atom). Faithful fix: strict-interior zones + explicit K⁺/K⁻ boundary atoms.

### (2) `hreal` shape vs what §5 induction actually proves (335 provider-obligation match)

Landed `hreal` (`SharedWitness.lean:12648–12652`): `∀ w, x<w → w<t → (kvE2_sepPtW …).eval_at M atomMap w → ∀ σ ∈ **kvE2_sepPos** qnf, ∃ x1, nf_eval_nf M 1 4 [x1,w,x,t] σ`.

Two mismatches with Rabinovich §5:
- **Index**: `hreal` ranges over `kvE2_sepPos` (the **global** positive list, `:193–195`), not the interior `kvE2_sepPosI` the fragment predicate uses. It demands realization of **every** positive, including exterior-zone positives — content Rabinovich's interior bracket never asserts.
- **Shape**: `hreal` asks for **independent, per-σ, unbounded** existentials. Rabinovich's realization (Cor 5.4 ⇐, p.9 l.263–273) constructs **one jointly-ordered interior sequence** `x1<…<xn ∈ (z0,z1)` — the witnesses are *coupled by order*, and *bounded to the open interval*. `hreal` neither bounds `x1` to `(x,t)` nor couples the witnesses.

**Finding**: `hreal` over-asks (global positives, unbounded, decoupled) relative to §5's bounded jointly-ordered interior induction. For the **n=1 interior singleton** the coupling is vacuous, so `hreal` is *accidentally* adequate for the current fragment; it does **not** generalize to `On` (n≥2). The task-335 provider obligation should be re-shaped to "bounded interior + jointly-ordered", matching Cor 5.4 ⇐.

### (3) Interior-singleton `kvE2_sepPosI` vs Lemma 5.3 single-P1 case

`kvE2_sepPosI` restricts to zones `x<x1<w ∨ w<x1<t` (`:211–214`) — the pivot `w` splits `(x,t)` into two strict sub-intervals. This is Lemma 5.3's **basis** (`n=1`: `¬(∃x1)^{<z1}_{>z0}P1(x1) ≡ (∀y)^{<z1}_{>z0}¬P1(y)`, p.8 l.227) **plus one navigation step** (the pivot `w` = Rabinovich's `r0`, the inf that splits the interval, Cor 5.4). `kvE2_sepFragment` demanding `kvE2_sepPosI = [σ0]` = a **single interior positive** = exactly the single-P1 base fragment.

**Finding**: faithful **for the base/one-step case**, and correctly interior (the 335-Refutation-1 mis-formalization — global `kvE2_sepPos` singleton, which is **unrealizable** because a realized `qnf` carries ≥3 positives — was fixed to the interior index in 346). But it captures **only** Lemma 5.3's base + first navigation, **not** the full `On` induction (n≥2, nested `K⁺(P1)` / recursive `r0` navigation, p.8 l.229–247). The interior-bounding that lives in the inductive step is therefore not yet encoded — consistent with the (b) verdict.

---

## §7 — Revision Plan + Implementation Guidance (verdict is (b))

The 346 interior+boundary gate is **sound and worth keeping** — it faithfully encodes Rabinovich's interior `(x,t)` bracket (base case) + boundary. Two revisions, smallest first.

### R1 (small, landable now) — split `hexclExt` by σ-zone; discharge the interior slice from order atoms

`hexclExt` is currently monolithic over `∀ σ, qnf.2 σ = false`. Split on `nf0_zoneSpec σ.1`:
- **Interior-marked σ** (`nf0_zoneSpec σ.1 ∈ {zXW3, zWT3}`): under the `hexclExt` guard `¬(x ≤ x1 ∧ x1 ≤ t)`, some interior order atom of σ is falsified by the exterior `x1`, so `¬ nf_eval_nf … σ` follows from the depth-0 atom clause (`NormalForm.lean:201–202`) — **discharge in-line, no residue**. Lemma shape:
  `∀ σ x1, (nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ = kvE2_sep_zWT3) → ¬(x ≤ x1 ∧ x1 ≤ t) → ¬ nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ` — proof: unfold to the falsified `.order` atom, `omega`/`exact` on the order literal.
- **Exterior-marked σ**: the genuine residue (see R2).

Net effect: the deferred obligation **shrinks from "all `qnf`-false σ" to "exterior-arrangement σ only"**, and the report's characterization "hexclExt = phantom" becomes machine-visible (the interior slice was never a real gap). This is the "smallest revision restoring bracket-semantics faithfulness" the task asked for; it is order-atom-only and should be a short proof.

### R2 (the real faithfulness restoration) — re-flatten the exterior arrangement (Prop 4.3), do NOT prove exterior completeness

Replace the residual exterior-σ `hexclExt` with a **separate exterior bracket composed by adjacency**, per Rabinovich Prop 4.3 (p.6) + Lemma 7.6 (p.13):
- The exterior arrangements `x1<x` and `x1>t` belong to the adjacent intervals `(−∞,x)` and `(t,∞)`, characterized by their **own** brackets (`[…](−∞,x)` / `[…](t,∞)`, §7 Def 7.5 / Lemma 7.10 shapes), composed with the interior `(x,t)` bracket by `(∃z)^{<z2}_{>z0}(φ1∧φ2)` adjacency.
- Landed assets to consume (per 330 report 01 §4 / 335 report 07): `neg_2var_vec_ea` (`EANegationClosure.lean:722`, Prop 4.2 negation closure — the hard step, already proven), the witness-growing carrier `BracketEndCharCarrierV` (`NfMultiAnchorBridge.lean:1872`), the interior closers (task 326). Missing ingredient = the **Prop 4.3 re-flatten / adjacency wiring** (H3 table rows "Prop 4.3", "Lemma 7.6" = MISSING).
- The `Prop43.lean:120–159` uniform-negation blocker named in the 346 successor spec is the **right entry point** for this route — keep it.

**Do NOT** attempt to prove `hexclExt` as a strictly-exterior non-realization/completeness lemma on the `(x,t)` bracket (335 Refutation 2 machine-argues it is inexpressible in the bracket vocabulary; and it has no source counterpart).

### Consumer guidance
- **309 Phases 13.4/14** and **KampPrior.lean:351**: consume an **interior+boundary gate + adjacent exterior bracket**, with the interior/exterior seam at the anchors `x,t`. Do not expect a single all-arrangement `(x,t)` gate.
- **335 Phase D**: re-shape the provider obligation to **bounded interior + jointly-ordered** witnesses (Cor 5.4 ⇐), and route it through `kvE2_sepPosI`, not `kvE2_sepPos`.

---

## Update-or-Retire: `prop43_exterior_completeness` successor spec

**RETIRE the framing; UPDATE/REPLACE the task.**

- **Retire**: the spec's stated obligation — "discharge `hexclExt` = prove no strictly-exterior point realizes a `qnf`-false sub" — is a **phantom completeness theorem** (no §5 counterpart; the outer-∃ was never meant to be bounded to `(x,t)` and then exterior-completed). Its "Definition of done" ("interior+boundary+exterior = full completeness *on this gate*") mis-locates exterior structure on the interior bracket.
- **Keep / re-use**: its dependency graph (346/335/309), its literature grounding (330/335), and its named **entry problem** `Prop43.lean:120–159` (the uniform-negation re-flatten) — that route is correct.
- **Replace with**: `prop43_exterior_reflatten` (or fold into 335 Phase D / a 321-v6 REDESIGN per 330): "restore interval-bounding faithfulness by re-flattening the exterior witness arrangement (Prop 4.3 + Lemma 7.6 adjacency) into a **separate** exterior bracket composed with the interior `(x,t)` bracket; land R1 first to shrink the residue to exterior-only." Definition of done unchanged at the **309** level (full completeness, `KampPrior:351` retired) but achieved by **re-flatten/adjacency**, not exterior exclusion on one bracket.

This also reconciles the two prior artifacts: 346 summary called the residue a "Prop-4.3 successor" (correct pointer) but framed the *mechanism* as exterior exclusion (wrong); 330/335 already prescribed re-flatten (correct). 347 adjudicates in favour of 330/335's mechanism.

---

## Tactic / Encoding Survey Results

No new tactics were trialled (adjudication task). Encoding facts established by direct read:
- `AtomKind` carries `.order` atoms (`NormalForm.lean:58–60`), evaluated as strict `<` (`:113–117`); **no equality atom** (so endpoint ties are the zone `(false,false)`, distinct from interior zones).
- `nf_eval_nf` outer ∃ is unbounded over `M.carrier` (`:203–207`) — the root-cause read the task asked me to verify **myself**: **CONFIRMED** verbatim.
- Gate binders (`hreal`/`hexcl`/`hexclExt`) confirmed at `SharedWitness.lean:12648–12669` and `OuterGate.lean:268–285`; `hexcl` cone is non-strict `x ≤ x1 ≤ t`; `hexclExt` guard is `¬(x ≤ x1 ∧ x1 ≤ t)` over **global** `qnf.2 σ = false`.

---

## Adversarial Self-Verification (H4, MANDATORY)

I attempted to REFUTE verdict (b) — actively hunting for a reading under which `hexclExt` is benign cheap debt (a), or a legitimate theorem the successor should just prove.

### Claim Verification Table

| Claim | Source / Counterexample tried | Verdict |
|---|---|---|
| `nf_eval_nf` line 206 quantifies the fresh witness over ALL `M.carrier`, unbounded | tried: maybe an interval guard sits in the matrix | **CONFIRMED** — personally read `NormalForm.lean:198–207`; `∃ (x : M.carrier)` with no order guard; guard would have to live in `sub_nf` atoms, not the ∃ |
| `AtomKind` carries order literals ⇒ ordering IS encoded ⇒ (a) might hold | tried: (a) — is exterior non-realization derivable from order atoms? | **PARTIAL/REFUTED for (a)** — personally read `:58–60`,`:113–117`: order atoms exist; but they give exterior non-realization ONLY for interior-*marked* σ; `hexclExt` ranges over GLOBAL `qnf`-false σ incl. exterior-marked, where order atoms give nothing → (a) "cheap" is false as stated |
| Rabinovich §5 has NO exterior-completeness direction | tried: scan Lemma 5.1 proof (p.9–11) for any out-of-`(z0,z1)` case | **CONFIRMED** — full-text l.285–335: every case is `x∈(z0,z1)`, `K⁺(¬β1)(z0)`, or `β1 along (z0,z1)`; Cor 5.4 outer ∃ is `(∃z)^{<z1}_{>z0}` (l.257); Fig.1 broadens via interior split, not endpoint extension |
| The dropped thing is the OUTER-∃ bound, not per-σ order atoms | tried: maybe the atoms themselves are lossy | **CONFIRMED** — read-only scan: `nf0_zoneSpec` is a lossless bijection of the `.order` channel (`NfEFold.lean:153–156`, 4 round-trip lemmas); `kvE2_sepPosI` interiority is an order-literal predicate (`SharedWitness.lean:211–214`) |
| `hexclExt` is inexpressible/hard on the `(x,t)` bracket (so "just prove it" is wrong) | tried: is there a model-fact route? | **CONFIRMED via prior machine work** — 335 report 07 Refutation 2 satisfiable-set argument (`da50f596c` probe) + `bracketEndchar_kv_factors` arity-1 inseparability (`CarrierKv.lean:422`). *Confidence: High but INHERITED* (I did not re-run the probe this dispatch) |
| `hexcl` cone is non-strict `x ≤ x1 ≤ t`; interior zones are strict | tried: maybe cone is strict | **CONFIRMED** — gate scan: cone `x ≤ x1 → x1 ≤ t` (`:12653–12657`); zones use strict `.order`; `AtomKind` has no equality constructor (`:58–60`) |
| `hreal` ranges over global `kvE2_sepPos`, not interior `kvE2_sepPosI` | tried: maybe it uses the interior index | **CONFIRMED** — `SharedWitness.lean:12648–12652` reads `∀ σ ∈ kvE2_sepPos qnf` |
| R1 (interior-slice discharge) is actually a short proof | reasoned: exterior `x1` falsifies a strict interior order atom of an interior-marked σ | **Plausible, NOT machine-verified this dispatch** — *Confidence: Medium*; flagged as an implementation-phase check, could hit a `Fin`-index / `decide` wrinkle |
| Full text (not summary) was the source | checked line count / headings / references | **CONFIRMED** — 495 lines incl. §5 proof body l.195–335, References l.473–493; this is the article, not the 2,721-token corpus summary 330 flagged |

### Contradiction Log

**Apparent contradiction (346 summary vs 330/335), RESOLVED by precedence (primary source > prior artifact).** The 346 summary frames `hexclExt` as a genuine "Prop-4.3 exterior-completeness" obligation to be *proved*; 330/335 prescribe *re-flatten* (Prop 4.3 structural induction / adjacency). Rabinovich §5+§7 read directly adjudicates: there is no exterior-completeness lemma; broader coverage is by re-flatten/adjacency (Prop 4.3 p.6, Lemma 7.6 p.13). The two artifacts were describing the same residue with different mechanisms; the source favours 330/335's mechanism. 346's *pointer* ("Prop-4.3 successor") is right; its *mechanism* ("exterior exclusion on this gate") is wrong. **No unresolved contradiction remains.**

**One inherited, not-re-verified item (flagged):** the "`hexclExt` inexpressible" claim rests on 335 report 07's satisfiable-set probe, which I did **not** re-run this dispatch. Downstream risk: if a novel model-independent structural constraint on `qnf.2` exists, a direct discharge might be possible after all. Resolving check not performed: re-run the `da50f596c`-style probe at the `hexclExt` goal for an exterior-marked characteristic σ. **This does not change the verdict** — even a direct discharge would be proving a phantom obligation the faithful (bounded) encoding never incurs.

### Confidence

**High** on the verdict ((b) substantive; outer-∃ bound is the dropped invariant; `hexclExt` is a globalization artifact; successor framing should be retired for re-flatten). **Medium** on R1 being a trivial landing (needs the implementation phase to confirm). **Inherited-High** on the "inexpressible" refutation (not re-run here).

---

## Consumers

- **prop43 successor decision**: RETIRE "prove exterior completeness"; REPLACE with re-flatten (§7 R2). Land R1 first.
- **Task 309 Phases 13.4/14**: consume interior+boundary gate **+ adjacent exterior bracket**; seam at anchors `x,t`.
- **Task 335 Phase D**: re-shape provider obligation to bounded/jointly-ordered interior (Cor 5.4 ⇐) over `kvE2_sepPosI`.
