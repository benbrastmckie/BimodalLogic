# Report 03 — Rabinovich-Faithful Path for the endChar Recursive-Arity Core (task 309)

- **Task**: 309 — offdiag_two_anchor_fi_chain
- **Type**: lean4 (hard-mode literature-grounded research; H2/H3/H4/H5)
- **Session**: sess_1783359214_93fd70
- **Focus**: literature-faithful resolution of the endChar recursive arity core (Phase 8 blocker)
- **Reference grounding tier**: Tier 1 (literature-backed — Rabinovich 2014, full paper read this session)
- **Primary source**: `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`
  (full 12-content-page PDF read directly this session; the `.md` in that dir is a ~2700-token
  editorial summary, NOT the paper — page:§ citations below are to the PDF text).
- **Source assets read this session**: `NormalForm.lean:198-221` (`nf_eval_nf`),
  `NfMultiAnchorBridge.lean` (`endChar0`/`endChar0_correct` :1017-1108, `EndCharCarrier` :1029,
  `seg`/`seg_holds_correct`/`seg_holds_coupled` :1149-1184, `A_diag_correct` :780-808),
  `KampPrior.lean:264-354` (the outer recursion + `:351`/`:354` sorries),
  `VecEADecomp.lean:233-282` (`nf_3var_bracket_xyt(_correct)`), `NfToVecEA.lean:1-142`,
  `VecEATranslation.lean` (Prop 3.5 chain builders), `VecEAClosure.lean:265+`
  (`existsBounded_right`), `EANegation.lean:1040-1090,1240-1249` (the BracketFormula-level
  impossibility notes), plan `plans/02_offdiag-fi-chain-plan.md`, report `reports/02_…`.

## VERDICT

The Phase-8 blocker (arity-4 → arity-3 re-bounding of `nf_eval_nf`'s quant layer) is **NOT inherent
in Rabinovich's proof — it is an artifact of the `endChar : NormalForm sig k 3 → TemporalPred`
carrier choice**, which the codebase itself already proved representationally FALSE in free-anchor
form (`endChar0_correct` deviation note, NfMultiAnchorBridge:1058-1069). Rabinovich never forms a
navigated arity-3 point characteristic and never grows arity with depth. He keeps the free-variable
count at **≤ 2 by construction** (Lemma 3.2(2)) via three devices absent from the `nf_eval_nf`
encoding: (a) **quantifier-free** interval/point types `α_j, β_j` (Def 3.1); (b) the **E[Σ]
expansion** (Def 4.1) that folds each processed quantifier depth into a *monadic* TL-atom before the
next level is decomposed; (c) existential witnesses realized as **Until/Since bracket witnesses**
evaluated with endpoint types pinned at the **fixed** points `z_0, z_1` — never at an interior
existential witness (PDF p.5, Prop 3.5).

**Recommended path: `/revise` to plan v3 — reformulate the recursion carrier from the (false)
arity-1 navigated point characteristic to a two-anchor VecEA2 bracket characteristic, and build the
depth-`k` generalization of the already-sorry-free depth-0 witness-collapse `nf_3var_bracket_xyt`
(VecEADecomp:233), feeding the sorry-free depth-`k` arity-1 point characteristic `char_k1`
(KampPrior:307) as the bracket interval type (the E[Σ]-atom of Def 4.1).** This is the paper's own
Prop 3.5 construction; it dissolves the arity-4 layer at the representation level rather than
re-bounding it with a ~300-500-line brick that fights the encoding. The endChar/seg route
(plan v2 Phases 6-8) is the **least faithful** option and is the 4-strike churn root.

---

## 1. The four critical questions, answered from the paper

### Q1 — How does Rabinovich keep the free-variable count ≤ 2 at an F_i-chain endpoint of depth k?

**Three interlocking mechanisms. None is present in `nf_eval_nf`.**

**(1a) `α_j, β_j` are quantifier-free (Def 3.1, PDF p.4).** Verbatim, an ∃∀-formula is
> `ψ(z_0,…,z_m) := ∃x_n…∃x_1∃x_0 (⋀_{k=0}^m z_k = x_{i_k}) ∧ (x_n > … > x_0) ∧ ⋀_{j=0}^n α_j(x_j) ∧
> ⋀_{j=1}^n [(∀y)^{<x_j}_{>x_{j-1}} β_j(y)] ∧ (∀y)_{>x_n}β_{n+1}(y) ∧ (∀y)^{<x_0}β_0(y)`
> "with … all `α_j, β_j` quantifier free formulas with one variable" (PDF p.4, immediately below
> the display).

The endpoint types `α_j` and interval types `β_j` are **one-variable, quantifier-free**. They carry
no nested quantifier depth. All depth lives in the *number* `n` of existential witnesses and the
Until/Since nesting — **not** in the arity of any sub-evaluation.

**(1b) The F_i chain translates with A_i, B_i that "do not even use Until and Since" (Prop 3.5, PDF
p.5).** Verbatim:
> "Let `A_i` and `B_i` be temporal formulas equivalent to `α_i` and `β_i` (`A_i` and `B_i` do not
> even use Until and Since modalities). It is easy to see that `ψ` is equivalent to the conjunction
> of `A_k ∧ (B_{k+1} Until (A_{k+1} ∧ (B_{k+2} Until … (A_n ∧ □B_{n+1})…))))` and
> `A_k ∧ (B_{k-1} Since (A_{k-1} ∧ (B_{k-2} Since … (A_0 ∧ ⃖□B_0)…)))`." (PDF p.5)

So the endpoint of the chain at depth `k` is `A_k` — a **Boolean combination of atoms**, arity 1,
zero recursion. The chain's "depth" is Until/Since nesting over quantifier-free endpoints.

**(1c) The E[Σ] expansion folds each processed depth into a monadic atom (Def 4.1, PDF p.5).**
Verbatim:
> "We denote by `E[Σ]` the set of unary predicate names `Σ ∪ {A | A is a TL(Until,Since)-formula
> over Σ}`. The canonical TL(Until,Since)-expansion of `M` is an expansion of `M` to an `E[Σ]`-chain,
> where each predicate name `A ∈ E[Σ]` is interpreted as `{a ∈ M | M,a ⊨ A}`." (PDF p.5, Def 4.1)

Structural induction (Prop 4.3, PDF p.6) processes one FOMLO quantifier at a time; each *already
translated* inner formula becomes a **monadic** predicate in `E[Σ]`. Hence at every level the
`α_j, β_j` are quantifier-free over the *current* (expanded) signature — the depth-`k` content is a
single monadic atom, **arity 1, evaluated at one point**, never an arity-4 nested existential. The
≤ 2 free-variable cap is then the standing invariant of Lemma 3.2(2) (PDF p.4):
> "Every ∃∀-formula is equivalent to a conjunction of ∃∀-formulas with at most two free variables."

### Q2 — Is `∃x', nf_eval_nf M k 4 (Fin.cons x' (zoneEnv3 w a b)) sub` a faithful transcription?

**No. It is an encoding artifact, on two counts, both traceable to the paper.**

**(2a) Arity growth per depth is absent from the paper.** `nf_eval_nf M (k+1) n`
(NormalForm.lean:203-207) unfolds its quant layer as
`∀ sub : NormalForm sig k (n+1), (∃x, nf_eval_nf M k (n+1) (Fin.cons x env) sub) ↔ quant sub = true`
— arity `n → n+1` at **every** depth descent. Rabinovich's normal form has a **fixed** free-variable
bound (≤ 2, Lemma 3.2(2)) and unbounded *nesting* depth with quantifier-free `α/β`. The two normal
forms are not the same object: `nf_eval_nf` trades Until/Since nesting for arity growth. The
"arity-4 sub-evaluation" is the depth-`(k+1)`, three-anchor (`zoneEnv3 w a b`) instance of this
growth. The paper's corresponding step (Prop 3.5) has an **arity-1** endpoint `A_k`.

**(2b) `zoneEnv3 w a b` elevates the navigated point to a THIRD anchor — the ≤ 2 cap is already
violated at the representation level.** `zoneEnv3 w a b = Fin.cons w (Fin.cons a (fun _ => b))`
puts the current evaluation point `w` into the environment vector alongside the two anchors `a, b`,
giving three fixed environment slots. Rabinovich's evaluation point is *the* point `t_0`
(`M, t_0 ⊨ A`, PDF p.1) — arity-1 semantics — and his ≤ 2 free variables `z_0, z_1` are the two
**interval endpoints**, handled by the bracket structure, not by a shared environment vector with
the navigation point. The codebase already discovered this: `endChar0_correct`'s deviation note
(NfMultiAnchorBridge:1058-1069) proves the free-anchor form
`(endChar0 qnf).eval_at w ↔ nf_eval_nf M 0 3 (zoneEnv3 w a b) qnf` **provably FALSE** because a
closed navigated-`w` `TemporalPred` "depends only on `M` and the navigated witness `w`" and cannot
read the anchor positions `a` (index 1), `b` (index 2). That falseness IS the ≤ 2-cap violation
surfacing: the carrier type asks a one-place predicate to encode a three-place property.

**Therefore the arity-4 quant layer is not what Rabinovich quantifies at that point.** Rabinovich
quantifies `∃x_i` as an Until/Since **bracket witness** (Prop 3.5), with the inner content already a
monadic `E[Σ]`-atom `A_{i}` at that single witness — arity 1, not arity 4.

### Q3 — What is the paper-faithful "witness collapse", and what does it look like over existing assets?

**The paper-faithful witness collapse is Prop 3.5's `∃x_i … → (… Until (A_i ∧ …))`: an existential
witness becomes a bounded Until/Since bracket witness.** In this codebase that collapse **already
exists, sorry-free, at depth 0**: `nf_3var_bracket_xyt_correct` (VecEADecomp:244-257):
> `(nf_3var_bracket_xyt … ssn).holds M atomMap x t ↔ ∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x
> (fun _ => t))) ssn`

i.e. the interior existential `∃y` with `x < y < t` is **collapsed into a bracket witness** of a
`VecEA2 1` whose endpoints are `nf_x_proj3`/`nf_t_proj3` (the anchor point types at `x, t`) and whose
interval type is `nf_y_proj` (the witness point type). This is exactly Rabinovich's `∃x_i` →
`Until`-witness, with the two anchors as the **fixed** bracket endpoints (matching PDF p.5's "endpoint
types at `z_0, z_1`"). The `β_i` interval type here is the `TemporalPred` slot of the bracket — an
`E[Σ]`-atom (Def 4.1).

**What the formalization is missing is the depth-`k` generalization of `nf_3var_bracket_xyt`**, in
which the three `TemporalPred` slots (two endpoint types + one interval type) are supplied not by
depth-0 `nfPred` atoms but by the sorry-free **depth-`k` point characteristics** the outer recursion
already builds. The relevant asset is `char_k1` (KampPrior:307-321), sorry-free:
> `temporal_truth M atomMap t (char_k1 nf') ↔ nf_eval_nf M (k+1) 1 (fun _ => t) nf'`

— the arity-1 point characteristic **at all depths**, which is precisely the Def-4.1 `E[Σ]`-atom. The
`n = 0` arm of `nf_nvar_exist_all_depths` (KampPrior:339-346) is closed sorry-free, so arity-1 point
characteristics are available at every `k`; only the `n = 1` (`:351`) and `n ≥ 2` (`:354`) arms
remain open. The faithful collapse is: lift `nf_3var_bracket_xyt` so its endpoint/interval
`TemporalPred`s are these depth-`k` characteristics, keeping `w` a bracket witness and `{x,t}` the two
fixed endpoints.

### Q4 — Does Kamp 1968 suggest a cleaner seam? (chased only because it disambiguates the carrier)

Not needed for the mechanism — Rabinovich is unambiguous — but the codebase's own
**`EANegation.lean:1077-1080` note independently confirms the fidelity fault line**, quoting the
Rabinovich design decision verbatim in prose:
> "**Root cause**: BracketFormula evaluates `alpha_0` at an INTERIOR existential witness, making the
> case analysis model-dependent. Rabinovich avoids this by evaluating `alpha_0` at the ENDPOINT `z_0`
> (a fixed point), eliminating the `beta_0(r0)` case entirely."

The endChar route's "navigated witness `w`" is exactly the *interior-existential* evaluation
Rabinovich avoids. This is corroborating internal evidence that the faithful carrier pins endpoint
types at fixed points, not at navigated interior witnesses. Kamp 1968 not further consulted (would
not change the recommendation).

---

## 2. H3 Source-to-Implementation Mapping (Tier 1, full F_i-chain pipeline)

| Paper item (Rabinovich 2014) | Paper location (PDF) | Our asset | File:line | Status |
|---|---|---|---|---|
| ∃∀-formula, `α_j/β_j` quantifier-free one-variable | p.4, Def 3.1 | `nf_eval_nf` (arity-growing NF — a *different* normal form) | NormalForm.lean:198-207 | **mismatched** (arity grows with depth; α/β not quantifier-free) |
| Lemma 3.2(2): ≤ 2 free variables | p.4 | guard G2/G4 (enforced by hand, not by the carrier) | — | **missing as an invariant** (carrier `→ TemporalPred` breaks it) |
| Prop 3.5: `∃x_i` → Until/Since bracket witness (depth 0) | p.5 | `nf_3var_bracket_xyt`/`_correct` | VecEADecomp:233/244 | **built, sorry-free** (depth 0) |
| Prop 3.5 chain builders `… Until (A_i ∧ …)` / `… Since …` | p.5 | `bracketBuildLeft/Right`/`_correct` | VecEATranslation:273/50,503/234 | **built, sorry-free** |
| Def 4.1: E[Σ] atom = TL-formula as monadic predicate (depth-`k` fold) | p.5 | depth-`k` arity-1 point char `char_k1`/`_correct` | KampPrior:307/310 | **built, sorry-free** (the E[Σ]-atom) |
| Lemma 3.4: ∨∃∀ closed under `∃x` (bounded) | p.5 | `BracketFormula.existsBounded_right`, `VecEAClosure` | VecEAClosure:265,371 | **built** (parametric over `TemporalPred` interval types) |
| Prop 4.2 / Lemma 5.1: negation closure (model-independent) | p.6-11 | `neg_vecEA2` (model-indep), `neg_interval_formula` (model-dep) | EANegationClosure.lean | **built, sorry-free** per EANegation:1082-1086 note |
| Prop 4.2 backward, BracketFormula biconditional (B.1 case) | p.9-10, Case 3 | `EANegation` B.1 arm | EANegation.lean:1090,1249 | **2 sorries** — documented "interior-witness / does-NOT-block-completeness" |
| Cor 5.4 `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)` past/future arms | p.9 | `A_past`/`A_future`/`_correct` (segment-carrying) | NfZoneFlattenNavigable:335/386 | built P1 (hook-parametric) |
| **Navigated arity-3 endpoint char (the endChar route)** | **no paper counterpart** | `endChar`/`endChar_correct` | NfMultiAnchorBridge (P8) | **UNBUILT — arity-4 blocker; not a paper object** |
| endChar depth-0 base, free-anchor form | no paper counterpart | `endChar0_correct` free-anchor | NfMultiAnchorBridge:1058-1069 | **proven FALSE** (residual-conditional only) |
| Interval `β_i` segment (endChar route) | p.9 (`β_i`) | `seg`/`seg_holds_coupled` | NfMultiAnchorBridge:1149-1184 | built but coupling deferred to `h_endChar` hook (= endChar) |

The two "no paper counterpart" rows are the crux: the endChar primitive that the entire plan-v2
Phases 6-9 depend on **does not correspond to any object in Rabinovich's proof**. It is an artifact
of trying to characterize `nf_eval_nf`'s three-anchor arity-3 evaluation as a one-place navigated
predicate.

---

## 3. Candidate paths — fidelity first, then feasibility, then guard-compliance (H4 adversarial)

### Path A — Build the arity-4 → arity-3 re-bounding brick (plan v2 Phases 6-8, endChar/seg)

- **Fidelity: LOWEST.** Re-imposes, by hand and inside a mismatched encoding, the ≤ 2-cap that
  Rabinovich maintains for free (Lemma 3.2(2) + Def 4.1). The central object `endChar :
  NormalForm sig k 3 → TemporalPred` **has no paper counterpart** (§2), evaluates the endpoint at a
  navigated *interior* witness (the exact thing EANegation:1077-1080 flags as un-Rabinovich), and its
  base case is provably FALSE in the faithful free-anchor form (NfMultiAnchorBridge:1058-1069), only
  salvageable via a residual `h_res` that the enclosing brackets must pin.
- **Feasibility: LOW / unbounded.** Report 02 §4.1/§4.2 estimates ~300-500 lines for the collapse
  core alone; Phase 8 is `[BLOCKED]` with a settled type-level obstruction (the arity-4 quant layer
  cannot be consumed by an arity-3 carrier). No type-correct non-vacuous `endChar` was constructible
  in-dispatch across 4 strikes (305 P11b, 307 P3, 307 P7, 309 P6/P8).
- **Guards: at constant risk of G2/G4 violation.** `nf_char3_deeper_split` (the only extant
  descent) grows anchors `{x,t}→{y,x,t}` (report 02 §4.1). Every dispatch that trusted the false
  "arity ≤3" route-audit comment re-attempted the forbidden tower.
- **Verdict: REFUTE as the primary route.** This is the churn root. It is not what the paper does.

### Path B (RECOMMENDED) — Reformulate the carrier to a VecEA2 bracket; lift `nf_3var_bracket_xyt` to depth `k`

- **Fidelity: HIGHEST.** This *is* Prop 3.5 (PDF p.5): the interior existential collapses to an
  Until/Since bracket witness; the two anchors `{x,t}` are the **fixed** bracket endpoints (matching
  "endpoint types at `z_0,z_1`", never an interior witness — EANegation:1077-1080); the interval type
  is a `TemporalPred` = `E[Σ]`-atom (Def 4.1) supplied by the sorry-free depth-`k` point
  characteristic `char_k1`. Free-variable count is **structurally** ≤ 2 (the two bracket endpoints);
  Lemma 3.2(2) is honored by the carrier type itself rather than by hand-checked guards.
- **Why it dissolves the arity-4 layer.** The recursion carrier becomes
  `NormalForm sig k 3 → VecEA2 …` (a two-endpoint bracket characteristic), **not**
  `→ TemporalPred` (a one-place navigated predicate). The descent is on the bracket **interval
  type** (a `TemporalPred`), for which the sorry-free depth-`k` `char_k1` is the ready `E[Σ]`-atom.
  `zoneEnv3`-as-three-navigated-anchors never appears; `w,x,t` occur as (bracket-witness, endpoint,
  endpoint), so no arity-4 quant layer is ever formed. The depth-0 instance
  (`nf_3var_bracket_xyt_correct`) is already discharged sorry-free — the lift generalizes its three
  `nfPred` slots to depth-`k` characteristics.
- **Feasibility: Medium.** Consumes sorry-free assets (`nf_3var_bracket_xyt`, `bracketBuildLeft/Right`,
  `char_k1`, `existsBounded_right`, the `n=0` arm). The load-bearing new work is the depth-`k` lift of
  `nf_3var_bracket_xyt` and its wiring into the `:351` arm.
- **Guards: G1-G5 respected by construction.** G4 (≤ 2 anchors) is the carrier type; G3 (non-trivial
  segment) is the bracket interval type = real `char_k1`, not `⊤`; G5 (F_i step-by-step) is
  `bracketBuildLeft/Right`; no `nf_char3_deeper_split`.
- **OPEN RISK (Medium-High), stated honestly.** The lift must be checked to not silently re-introduce
  a navigated arity-3 characteristic when the *inner* `nf_eval_nf M k 3 [w,x,t] qnf` (for `k ≥ 1`)
  is expanded: that inner object still has its own quant layer, and the fold to an `E[Σ]`-atom is
  only free if the depth-`(k−1)` IH is threaded as the bracket interval type. The decisive
  de-risking experiment is the **`k = 1`** case (see Phase R2 below): expand
  `nf_eval_nf M 1 3 [w,x,t] qnf` and confirm it reduces via `char_k1` (depth-0 fold) + a `VecEA2`
  bracket **without** an arity-4 residual. If `k = 1` closes, the recursion closes; if it silently
  needs a navigated arity-3 char, Path B degrades to Path C.
- **Verdict: ENDORSE.** Faithful, guard-safe-by-construction, and it converts the blocker from a
  type-level impossibility into a bounded generalization of an already-green lemma.

### Path C — Bridge the `:351` arm wholesale into the VecEA/∃∀ translation track

- **Fidelity: HIGH** (it is literally the paper's Prop 3.5 + Lemma 3.4 + Prop 4.2 pipeline:
  RabinovichTranslation + VecEATranslation + VecEAClosure + EANegationClosure).
- **Feasibility: LOW-Medium, with a known wall.** The VecEA negation track carries the documented
  BracketFormula-level impossibility (`EANegation.lean:1047-1090`): the model-*independent* biconditional
  fails on the B.1 interior-witness case; only the model-*dependent* `neg_interval_formula` /
  `neg_vecEA2` are sorry-free. For the `:351` arm the operation needed is **existential** closure
  (Lemma 3.4), not negation, so the B.1 wall may not be on-path — but establishing that requires the
  same `k=1` probe as Path B, and the bridge from `nf_eval_nf` to `VecEA` presently exists only at
  depth 0 (`NfToVecEA`). So Path C is Path B's assembly viewed one level of abstraction up; it does
  not avoid the depth-`k` lift.
- **Guards: respected** (same track as Path B).
- **Verdict: ENDORSE as Path B's fallback/framing**, not as an independent cheaper route. If the
  depth-`k` lift (Path B) is done at the `VecEA2` layer it *is* Path C. Recommend executing at the
  `nf_3var_bracket_xyt` granularity (Path B) because that lemma is already sorry-free and gives the
  tightest, testable seam.

### Adjustment to the NormalForm encoding itself (Q3(iii), off the live path)?

Considered and **not recommended as the primary fix**. A truly faithful `nf_eval_nf` would fold each
depth into `E[Σ]`-atoms (fixed ≤ 2 arity, Def 4.1) rather than growing arity — but re-encoding the
core normal form is a project-scale change touching every `Nf*` file and would orphan the sorry-free
depth-0/arity-1 assets. Path B achieves faithful behavior **at the point of use** (the `:351` arm)
without disturbing the encoding, by treating `char_k1` as the `E[Σ]`-atom. Flag the encoding
divergence as a documented known-limitation, not a task-309 deliverable.

---

## 4. Recommended path with concrete phase decomposition (ready for `/revise`, plan v3)

**Replace plan v2 Phases 6-9 (endChar0 / seg / recursive endChar / rewire) with the following.**
Keep P1-P5 + P6.1 as landed history (the segment-carrying wrappers remain valid consumers if the
`A_past∨A_diag∨A_future` shape is retained; if v3 routes purely through the `VecEA2` bracket they
become optional and may be bypassed — the reviser decides). All phases inherit guards G1-G5 verbatim,
cite Rabinovich PDF p.4-5 (Def 3.1 / Lemma 3.2(2) / Prop 3.5 / Def 4.1) at each chain step, and forbid
`nf_char3_deeper_split` and any `→ TemporalPred` navigated-arity-3 carrier.

- **Phase R1 — Carrier reformulation + interface (~40-80 lines).** Replace
  `EndCharCarrier := NormalForm sig k 3 → TemporalPred` with the two-anchor bracket carrier
  `EndCharCarrier := NormalForm sig k 3 → VecEA2 1` (or the minimal record capturing two endpoint
  `TemporalPred`s + one interval `TemporalPred`). State the target correctness in the fixed-endpoint
  form `(carrier qnf).holds M atomMap x t ↔ ∃ w, nf_eval_nf M k 3 (Fin.cons w (Fin.cons x (fun _=>t)))
  qnf`, mirroring `nf_3var_bracket_xyt_correct` (VecEADecomp:244). Guards G2/G4 (the type is the
  invariant). No proof obligation beyond typechecking; documents the deviation from v2.

- **Phase R2 — `k = 1` de-risking probe (~60-100 lines, DECISION GATE).** Prove the carrier
  correctness at `k = 1` only: expand `nf_eval_nf M 1 3 [w,x,t] qnf`, fold its depth-0 quant layer via
  the sorry-free depth-0 assets (`nf_3var_bracket_xyt` + `char_k1` at `k=0`), and confirm it closes as
  a `VecEA2` bracket **with no arity-4 residual and no navigated arity-3 characteristic**. This is the
  single experiment that decides Path B viability (the OPEN RISK in §3). If it closes: proceed. If it
  forces a navigated arity-3 char: STOP, mark `[BLOCKED]`, and escalate (the encoding-level divergence
  is then load-bearing and a larger re-scope is required). Guards G3/G4/G5.

- **Phase R3 — depth-`k` lift of `nf_3var_bracket_xyt` (~120-200 lines).** Generalize
  `nf_3var_bracket_xyt` (VecEADecomp:233) so its endpoint types (`nf_x_proj3`/`nf_t_proj3`) and
  interval type (`nf_y_proj`) are the depth-`k` characteristics `char_k1` (KampPrior:307, the
  `E[Σ]`-atom of Def 4.1) instead of depth-0 `nfPred`. Prove
  `(carrier qnf).holds M atomMap x t ↔ ∃ w, nf_eval_nf M k 3 (Fin.cons w (Fin.cons x (fun _=>t))) qnf`
  by recursion on `k` (base = the existing depth-0 `nf_3var_bracket_xyt_correct`; step = fold via
  `char_k1` + `bracketBuildLeft/Right`). Witness `w` is a bracket witness (G4); interval type is a real
  characteristic (G3). If it overruns H8, split at the base-wiring / step-fold seam. Guards G1-G5.

- **Phase R4 — discharge the `:351` arm via bounded ∃-closure (~60-120 lines).** At KampPrior:351,
  the goal is `∃ A, temporal_truth t A ↔ ∃ env:Fin 1, nf_eval_nf M (k+1) 2 (insertEnv env t) sub_nf`.
  Bridge `env:Fin 1` to `∃x` (the existing `h_env_eq` shape, KampPrior:277-291). Decompose
  `nf_eval_nf M (k+1) 2 [x,t]` into its depth-0 atom layer (Phase-2 `nf_char2_atom_offdiag_correct`)
  and, per arity-3 sub `qnf`, the inner existential closed by the Phase-R3 carrier (Lemma 3.4 /
  `existsBounded_right`, VecEAClosure:265). Assemble the TL formula via `bracketBuildLeft/Right`
  (Prop 3.5). Close `:351` (live sorries 2 → 1; `:354` remains, task 305). **Definition of done:**
  full `lake build` GREEN; `#print axioms` on the rewired `nf_nvar_exist_all_depths` live-path theorem
  = exactly `[propext, Classical.choice, Quot.sound]`; new material grep-clean of `sorry`. Guards: D1
  (import edge already landed), final sorry+axiom discipline.

**Total: ~280-500 lines over 4 phases** (each one agent run per H8), with **R2 as an explicit
decision gate** so a Path-B failure is detected in one bounded dispatch rather than after another
300-line brick attempt. If R2 fails, the recommendation converts to `/spawn` a dedicated
encoding-level task (the NormalForm E[Σ]-fold), and 309 stays `[BLOCKED]` on the `:351` arm — but
that outcome is now falsifiable in ~100 lines instead of ~500.

**Why `/revise` not `/spawn`:** the fix is a *corrected decomposition* of the existing task (replace
the unfaithful carrier), and it preserves/consumes the landed sorry-free assets in-task; `/spawn` is
the R2-failure fallback only.

---

## Adversarial Self-Verification

Claim Verification Bar applied to every load-bearing claim. Verification methods: `PDF read`
(direct read of the source PDF this session), `source read` (Lean file:line read this session).

| Claim | Source/Counterexample | Verdict |
|---|---|---|
| `α_j, β_j` in Def 3.1 are quantifier-free, one-variable | PDF p.4, Def 3.1 text below the display | Confirmed (PDF read) |
| Prop 3.5's `A_i, B_i` "do not even use Until and Since" (chain endpoint is arity-1 Boolean-of-atoms) | PDF p.5, Prop 3.5 proof | Confirmed (PDF read) |
| E[Σ] folds each processed depth into a *monadic* TL-atom | PDF p.5, Def 4.1 | Confirmed (PDF read) |
| Lemma 3.2(2) caps free variables at ≤ 2 | PDF p.4, Lemma 3.2(2) | Confirmed (PDF read) |
| `nf_eval_nf` quant layer grows arity `n → n+1` per depth | NormalForm.lean:203-207 — source read | Confirmed |
| `zoneEnv3 w a b` places the navigation point `w` as a 3rd env slot with anchors `a,b` | NfMultiAnchorBridge `zoneEnv3` usage; `endChar0` :1017 — source read | Confirmed |
| The free-anchor `endChar0_correct` biconditional is provably FALSE (closed `w`-pred can't read `a,b`) | NfMultiAnchorBridge:1058-1069 — source read (counterexample `qnf(.pred p 1)=true`, `M.interp p a=false`) | Confirmed |
| The arity-4 quant layer is the endChar-arity-3 route's artifact, not a paper object | §2b synthesis: `zoneEnv3`(3 anchors)→arity-4 sub; paper endpoint is arity-1 (Prop 3.5) | Confirmed (analytic, PDF+source) |
| Depth-0 witness collapse `∃y → bracket witness` is built sorry-free | VecEADecomp:244-257 `nf_3var_bracket_xyt_correct` — source read | Confirmed |
| `char_k1` gives a sorry-free arity-1 point characteristic at all depths (the E[Σ]-atom) | KampPrior:307-321 — source read | Confirmed |
| The `n=0` arm of `nf_nvar_exist_all_depths` is closed sorry-free; only `:351`/`:354` open | KampPrior:339-346 (n=0 closed), :351/:354 (sorry) — source read | Confirmed |
| Rabinovich evaluates endpoint types at FIXED points, not interior witnesses (fidelity fault line) | EANegation.lean:1077-1080 verbatim note; corroborated by PDF p.5 Prop 3.5 endpoint form | Confirmed (source + PDF) |
| The VecEA negation track has a documented model-independent B.1 sorry (interior-witness) | EANegation.lean:1047-1090 — source read | Confirmed |
| Model-independent `neg_vecEA2` and model-dependent `neg_interval_formula` are sorry-free | EANegation.lean:1082-1086 note — source read | Confirmed (note); `neg_vecEA2` body not independently re-verified this session |
| `existsBounded_right` (Lemma 3.4 vehicle) is parametric over arbitrary `TemporalPred` interval types | VecEAClosure.lean:265-273 — source read | Confirmed |
| Path A (endChar) has no paper counterpart and is the 4-strike churn root | §2 (no counterpart) + report 02 §5 (4 strikes) — cross-ref | Confirmed |
| Path B `k=1` probe (R2) will close without an arity-4 residual | not yet executed — depends on the depth-0 fold threading through `char_k1` | **Open (flagged R2 decision gate)** |
| Line estimates (~280-500 total) | parity with report 02's own estimate + component sizing | Estimate (Medium) |
| `/revise` preferred over `/spawn` (fix is a corrected decomposition in-task) | §4 rationale + report 02 §4.4 (route a) | Recommendation (Medium-High) |

**Contradiction Log.**
- *Plan v2's premise ("the four hooks reduce to the endChar primitive; build it") vs. this report's
  finding (endChar has no paper counterpart and its free-anchor form is FALSE).* **Resolved** by
  precedence "actual Lean statement + paper text > plan prose": report 02 correctly identified that
  all four hooks reduce to one object, but mis-scoped that object as an arity-1 navigated point
  characteristic; the codebase's own `endChar0_correct` deviation note (NfMultiAnchorBridge:1058-1069)
  proves that object cannot exist in the required form. The reduction target must instead be the
  **two-anchor bracket** characteristic (Path B). No contradiction with report 02's VERDICT (BINDS,
  object must be BUILT) — only with its *shape* for the object. Downstream risk: a v3 that keeps the
  `→ TemporalPred` carrier will re-block; R1 changes the carrier type to prevent this.
- *Report 02 route (c) REFUTED ("no cheaper discharge with existing builders") vs. this report's
  Path B ("lift an existing sorry-free builder").* **Resolved**: report 02's route (c) meant "discharge
  the *arity-3 navigated* hooks with existing builders", which is genuinely refuted (they grow anchors).
  Path B is not route (c): it *changes the carrier* to the bracket form, then lifts a *different*
  existing builder (`nf_3var_bracket_xyt`, which report 02 did not consider as the recursion base). No
  contradiction.

**Forbidden-output check.** No "mathlib likely has this" (all claims cite `file:line` source-read or
`PDF p.N` this session). No `sorry`-deferral or axiom introduction recommended — Path B is a concrete
sorry-free construction targeting axioms `[propext, Classical.choice, Quot.sound]`, with an explicit
`[BLOCKED]`+`/spawn` fallback if the R2 gate fails (not a strategic sorry). Guards G1-G5 carried
forward and, under Path B, enforced by the carrier *type* rather than by hand. The one open claim
(R2 closes without arity-4 residual) is explicitly flagged as a decision gate, not asserted.

**Recommendations modified after verification.** Initial instinct ("build the arity-4→3 collapse
brick per report 02 §4.2") was **refuted** after the PDF read established that Rabinovich never grows
arity and the endChar carrier has no paper counterpart; recommendation switched to the carrier
reformulation (Path B) with the depth-0 `nf_3var_bracket_xyt` as the faithful recursion base.
