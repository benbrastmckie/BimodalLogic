# Rabinovich Fidelity / Divergence Audit — Kamp Expressive-Completeness Formalization

**Task**: 375 — kamp_completeness_final_assembly_axiom_audit
**Session**: `sess_1784869380_2459bd` | **Date**: 2026-07-24
**Mode**: `--hard --lit` (H2/H3/H4 + H5 divergence audit active via focus_prompt)
**Arbiter**: `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`
— read directly this session, pp.1–12 (all page citations below are PDF pages). The companion
`.md` conversion was NOT consulted (known corrupt: drops displayed equations, inverts `k ≠ m`).
**Method**: every load-bearing repo claim checked by reading the declaration source
(`Read`/`grep`) or by `lean_verify`; no claim below rests on a declaration name alone.

---

## 1. Executive Verdict

> **ALIGNED. No unmotivated drift found.**
>
> The as-landed structure — the ζ re-wire (`sigE`/`canonExpand`/`nameOf`/`kampArm_zeta`),
> the retirement of the `_k+2` arm, the two residual EANegation sorries, and the carrier
> substitution — is faithful to Rabinovich 2014 at every audited point, **or** deviates in a
> way that is (a) documented in-tree at the deviation site, (b) machine-checked where a
> machine check is possible, and (c) owned by a live follow-up task where work remains.
> Every deviation in the Drift Register (§5) is classified MOTIVATED; none is silent.
>
> Independently re-verified this session: `#print axioms`-equivalent check on
> `Bimodal.Metalogic.BXCanonical.completeness_discrete` returns
> `[propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]` —
> **no `sorryAx`**. Exactly **2** statement-position `sorry`s exist in the live Kamp zone
> (`EANegation.lean:1090`, `:1249`), both zero-consumer and off the proof term. Zero `axiom`
> declarations exist anywhere under `Theories/Bimodal/Metalogic/WeakCanonical/`.

---

## 2. H3 Reference-Grounding Mapping Table

Verdicts: **F** = FAITHFUL, **MD** = MOTIVATED DEVIATION (motivation site cited),
**UD** = UNMOTIVATED DRIFT (none issued).

| # | Repo declaration | Location | Paper anchor (PDF page) | Verdict |
|---|---|---|---|---|
| 1 | `sigE` (`preds := sig.preds ⊕ Formula`) | `Kamp/ESigmaExpansion.lean:70` | Def 4.1, p.5: E[Σ] = Σ ∪ {A \| A a TL(U,S)-formula over Σ}, unary names | **F** (two benign deltas, Drift Reg. #1–2) |
| 2 | `canonExpand` (fresh atom `A` ↦ `{a \| sat A a}`) | `ESigmaExpansion.lean:101` | Def 4.1, p.5: A interpreted as {a \| M,a ⊨ A} | **F** (`sat` parametrized; Drift Reg. #3) |
| 3 | `atom_eval_new` / `atom_eval_old` | `ESigmaExpansion.lean:124/134` | p.6 collapse-to-atom note + Def 4.1 interpretation clause | **F** |
| 4 | `nameLit`/`nameOf`/`hName`; `nameOf (inr A) = A` | `Kamp/PerFormulaRender.lean:82–117`; `ZetaUniformExtract.lean:726` (`zetaNameOf`) | Def 4.1 interpretation equation (p.5) read atom→formula; p.6 note ("…equivalent to an atomic formula in the canonical TL-expansions") | **F** (base-pred leg: Drift Reg. #4) |
| 5 | `unaryToFormulaFin` (+`_correct`) | `PerFormulaRender.lean:127/142` | Prop 3.5's `A_i` (p.5), bounded to the formula's own finite atom syntax (Def 3.1, p.4) | **F** |
| 6 | `translate_uniformFin` (structural induction: atom/lt/not/and/all/ex) | `Kamp/ZetaUniformExtract.lean:588` | Prop 4.3, p.6 (structural induction: Atomic / Disjunction / Negation / ∃) | **F** (∀ as ¬∃¬, which p.6 leaves implicit; tie/gap split: Drift Reg. #5) |
| 7 | `efSat_negation_general_uniformFin` (pairwise 2-var projections) | `ZetaUniformExtract.lean:336` | Prop 4.3 Negation case, p.6: Lemma 3.2(2) (p.4) split into ≤2-free-var conjuncts, then Prop 4.2 per conjunct | **F** — this is where the Lemma 3.2(2) cap is enforced |
| 8 | `VVecEA2.negFix_iff` | `Kamp/EANegationFix/VecEANegFix.lean:177` | Prop 4.2 (p.6), proved Section 5 pp.7–11 | **F in form; carrier restricted** (Drift Reg. #8) |
| 9 | `prop42_contentful_of_attained` | `Kamp/Section5Correspondence.lean:115` | Prop 4.2, p.6 | **MD** — "restricted to attained structures", documented at length in the same file |
| 10 | Section 5 transcription table (`negChainOn_iff`, `BracketFormula.negFix_iff`, `negBoundedRightFix_iff`/`LeftFix_iff`, `negFixList`) | `Section5Correspondence.lean:24–31` (CI-protected) | Lemma 5.3 p.8, Lemma 5.1 pp.9–11, Cor 5.4 p.9, A_i/B_i split pp.10–11 | **F** (per that table; spot-checked `VVecEA2.negFix`/`VecEA2.negFix` this session) |
| 11 | `zetaNameOf_hName`, `canonExpand_atom_named`, `temporal_truth_canonExpand` | `ZetaUniformExtract.lean:737`; `Kamp/ESigmaCapture.lean` | Def 4.1 (p.5) + p.6 note; conservativity of the expansion | **F** |
| 12 | `kampArm_zeta` (general in k) | `ZetaUniformExtract.lean:761` | Thm 4.4, p.6: Prop 4.3 → Prop 3.5 at one free variable, over the canonical expansion | **F** |
| 13 | `nf_nvar_exist_all_depths` `\| _k+2` arm := `(kampArm_zeta …).imp` | `Kamp/KampPrior.lean:493–521` | Same as #12; the arm's iff is kampArm_zeta's statement modulo `insertEnv`/`Fin.cons` reindexing | **F** — no weakening/strengthening (checked line-by-line, §3.1.4) |
| 14 | `NormalForm`/`nf_eval_nf` in intermediate statements (`nf_nvar_exist_all_depths`, `nf_characterizable_temporal_prior`) | `KampPrior.lean:347/574` | **No counterpart** — Def 3.1's object (p.4) is the ∃∀-formula, not a Hintikka type | **MD** (plan-24 recorded resolution; Drift Reg. #6) |
| 15 | `kamp_prior_expressive_completeness` / `US_expressively_complete_over_prior` (statement: `eval M ψ ↔ temporal_truth M A`) | `KampPrior.lean` (tail) / `PriorExpressiveness.lean:346` | Thm 4.4 p.6 / Thm 2.1(2) p.4, relativized from Dedekind complete chains to Prior structures | **F in form; carrier relativized** (Drift Reg. #8) |
| 16 | `neg_bracket_is_vbracket` (sorry `:1090`), `neg_partialBracketExist_is_vbracket` (sorry `:1249`) | `Kamp/EANegation.lean:834/1129` | **Off-paper object**: Lemma 5.1's bracket (5.1), p.7, pins `z₀ = x₀ < … < x_n = z₁` and evaluates α₀ AT `z₀`; the repo bracket evaluates α₀ at an interior existential witness with a β₀ leading segment | **MD** (dead-end, documented, zero consumers; §3.2) |
| 17 | `prior_hasAttainedINF` | `Kamp/PriorINF.lean:224` | Substitute for Dedekind completeness + Lemma 5.3's inf argument (p.8, formula 5.2) on the live carrier | **MD** (documented as deviation at `Section5Correspondence.lean:37–70`) |
| 18 | Deleted finite-alphabet capture (`intervalCapture_of_atomNamed`, `esigmaCapture_canonExpand`, `sigE_fintypePreds`) | deleted; header record in `ESigmaCapture.lean` | Def 4.1's Σ-expansion is **infinite** (p.5) | **F** — deletion moved TOWARD the paper (§3.3.4) |

---

## 3. Per-Item Findings

### 3.1 The ζ wire (scope item 1)

#### 3.1.1 `sigE` vs Def 4.1 (p.5)

Def 4.1 verbatim (p.5): *"We denote by E[Σ] the set of unary predicate names
Σ ∪ { A | A is an TL(Until,Since)-formula over Σ }. The canonical TL(Until,Since)-expansion of
M is an expansion of M to an E[Σ]-chain, where each predicate name A ∈ E[Σ] is interpreted as
{a ∈ M | M,a ⊨ A}."* So: **yes, Def 4.1 indexes expansion atoms by formulas, one unary
predicate name per formula**, over an infinite alphabet.

Repo (`ESigmaExpansion.lean:70`): `sigE sig _F` has `preds := sig.preds ⊕ Formula` — old
names plus one fresh unary name per `Formula`, no membership gate, deliberately **no
`Fintype`** instance (`:84–91`). `canonExpand` (`:101`) inherits carrier and order verbatim
and interprets `inr A` as `{a | sat A a}`. This matches Def 4.1's summand structure exactly.
Two deltas, both benign and both documented in the module header:

- the fresh summand is the **full bimodal `Formula` type**, a superset of "TL(U,S)-formulas
  over Σ". Extra names are inert: the only names the live translate ever emits are
  `translateProp35Fin` outputs (U/S/Boolean formulas), and `sat` is total on `Formula`, so
  the superset adds unused atoms only.
- `F : Finset Formula` survives as a pure type-level stage index (paper has no such
  parameter). Header states the motivation: downstream types (`UnaryTypeFin`,
  `IntervalType`, …) keep their arities. Inert (`_F` unused in `sigE`).

**Verdict: FAITHFUL.**

#### 3.1.2 `nameOf`/`hName` vs the p.6 collapse

The p.6 note verbatim: *"Note that if A is a TL(Until,Since) formula over E[Σ] predicates,
then it is equivalent to a TL(Until,Since) formula over Σ, and hence to an atomic formula in
the canonical TL(Until,Since)-expansions."* So **yes, there is a collapse/naming step on
p.6**, and it is the same biconditional as Def 4.1's interpretation clause:
`interp(P_A)(a) ↔ M,a ⊨ A`.

`nameOf (inr A) = A` (`zetaNameOf`, `ZetaUniformExtract.lean:726–731`) with premise
`hName : temporal_truth N atomMap y (nameOf p) ↔ N.interp p y` is that equation read
atom→formula — a **transcription**, not an extension: the premise is discharged only at the
concrete canonical expansion (`zetaNameOf_hName` ← `canonExpand_atom_named`), which is
exactly where the paper's note holds. The `inl q ↦ chosen atom` leg is not in the paper
because the paper's Σ-atoms *are* atomic propositions; the repo's object language reaches
its predicates through `atomMap`, so a base predicate must be named by a chosen atom — the
pre-existing `h_surj` device, with `nameOfSurj`/`nameOfSurj_hName`
(`PerFormulaRender.lean:106–117`) proving it is the degenerate case. An encoding necessity,
uniformized, proven; no new strength enters (hName is a per-model premise, never an axiom).

**Verdict: FAITHFUL (transcribes p.6/Def 4.1; the base-pred leg is a motivated encoding
device).**

#### 3.1.3 `kampArm_zeta` vs Prop 4.3 / Thm 4.4 (p.6)

Prop 4.3's proof (p.6) is a structural induction on the FO formula: Atomic / Disjunction /
Negation (via Lemma 3.2(2) split to ≤2-free-var conjuncts, then Prop 4.2, then ∨∃∀-closure
Lemma 3.4) / ∃-quantifier (Lemma 3.4). `translate_uniformFin` (`ZetaUniformExtract.lean:588`,
`termination_by φ.size`) matches this case-for-case:

- `.atom` — emitted via the named-formula capture (the p.6 collapse, inlined; comment at
  `:604` says exactly this);
- `.and` — `veeConjFin` (Lemma 3.4 conjunction closure, p.5);
- `.not` — `veeSat_negation_uniformFin` (`:455`) → per-disjunct
  `efSat_negation_general_uniformFin` (`:336`), which splits the ∃∀-formula into **pairwise
  two-variable projections** (`pairProjectFin`), diagonal one-variable projections, and a
  zero-variable existence sentence, negates each through the arity-2 Prop 4.2 engine
  (`prop42_efSat_negation_general_uniformFin` → `VVecEA2.negFix_iff`), and reassembles by
  De Morgan (`efSatFin_negation_demorgan`). **This is the literal Lemma 3.2(2) + Prop 4.2
  route of the paper's Negation case.**
- `.ex` — `ex_closure_translate_uniformFin` (Lemma 3.2(3)/3.4 closure, p.4–5), realized as a
  gap/tie split (`insertPerm` renames for the new point falling strictly between/outside the
  pinned points; `subst0` for ties). Def 3.1 (p.4) handles ties by the `z_k = x_{i_k}`
  equality prefix; the repo's strict-mono pinning discipline plus explicit tie branch is an
  equivalent encoding, adjudicated in `specs/379_*/reports/14_*` and `15_*`.
- `.all` — `¬∃¬` (`not_exists_not`, `:679`); p.6 leaves ∀ implicit, same treatment.

`kampArm_zeta` (`:761`) then follows Thm 4.4's proof shape exactly, as the module's §7
comment states: lift `∃x. nf_to_formula sub_nf` (one free variable) along
`mapPreds oldPred`, apply the uniform Prop 4.3 translate with `zetaNameOf`, instantiate per
`M` at `canonExpand sig ∅ M (temporal_truth M g)` (Def 4.1), read back at one free variable
through `translateVeeProp35Fin` (Prop 3.5, p.5), descend by conservativity
(`temporal_truth_canonExpand`). Processed depth `k` enters only through `nf_to_formula`'s
unfolding into FO syntax — a **single** Prop 4.3 pass handles all depths, as in the paper;
no per-depth iteration, no arity-4 joint object anywhere on this path (all negation
machinery is arity ≤ 2 by type).

**Verdict: FAITHFUL.** One inherited caveat: the per-N premises are
`HasAttainedINF/SUP`, not Dedekind completeness — the Section-5 carrier deviation (§3.3.3),
discharged on Prior structures by `canonExpand_hasAttainedINF/SUP` ← `hUZ`/`hSZ`.

#### 3.1.4 The retirement site (`KampPrior.lean:493–521`)

The `| _k + 2` arm must produce
`temporal_truth M atomMap t A ↔ ∃ env : Fin 1 → M.carrier, nf_eval_nf M (k+2) 2 (insertEnv env t) sub_nf`
under `semantic_prior_UZ/SZ`. `kampArm_zeta` delivers
`… ↔ ∃ x, nf_eval_nf M (k+2) 2 (Fin.cons x (fun _ => t)) sub_nf` under the same two
hypotheses. The `.imp` adapter (`:505–521`) proves `insertEnv env t = Fin.cons (env 0)
(fun _ => t)` by `funext` case analysis and converts the two existentials **in both
directions**. Preconditions identical, conclusion converted by a pure environment
re-indexing. **No weakening or strengthening is smuggled in.** The k=0/k=1 arms retain the
older per-depth route (`kampPrior_case1_arm_k0/_k1`, `:272/:302`) — see Drift Register #7.

### 3.2 The two remaining sorries (scope item 2)

**Paper check (the load-bearing question).** Lemma 5.1's formula (5.1) (p.7):
`∃x₀…∃x_n [ (z₀ = x₀ < ⋯ < x_n = z₁) ∧ ⋀ αⱼ(xⱼ) ∧ ⋀_{j=1..n} (∀y)^{<x_j}_{>x_{j-1}} βⱼ(y) ]`.
The endpoints are **pinned**: `x₀ = z₀` and `x_n = z₁`; α₀ is evaluated **at the fixed
endpoint z₀**; there is **no β₀ segment inside the bracket** (the `(∀y)^{<x₀}β₀(y)` conjunct
of Def 3.1 lives in the one-free-variable component ψ₀(z₀) of the p.7 decomposition (1),
which is negated through the Prop 3.5 / atomic-collapse route, never through Lemma 5.1).
The case analysis on p.9 confirms it: Case 1 is literally "¬α₀(z₀) or K⁺(¬β₁)(z₀)" — α₀ at
`z₀`, first interval type at `z₀`. **Therefore the β₀(r₀) sub-case of the repo's backward
direction has no counterpart in the paper: it never arises**, exactly as the inline
impossibility comment at `EANegation.lean:1047–1089` states ("Rabinovich avoids this by
evaluating alpha_0 at the ENDPOINT z_0 … eliminating the beta_0(r0) case entirely"). The
repo's `BracketFormula` (interior existential x₀, leading β₀ segment `(z₀, x₀)`) is an
off-paper variant; the two sorries (`:1090` β₀(r₀)-case; `:1249` the F-chain mirror in
`neg_partialBracketExist_is_vbracket`) are artifacts of that variant's biconditional being
genuinely false-or-unprovable as stated, per the B.1 adjudication cited in-file.

**Consumers**: repo-wide grep (excluding `EANegation.lean` itself and Boneyard) finds
**zero** references to either theorem. **Axioms**: `completeness_discrete` carries no
`sorryAx` (verified this session), so neither sorry is on the proof term.

**The live replacement.** `VVecEA2.negFix_iff` (`VecEANegFix.lean:177`) states: on
structures with `HasAttainedINF`/`HasAttainedSUP`, `v.negFix.holds M z₀ z₁ ↔ ¬ v.holds M z₀
z₁` for every two-free-variable ∨∃∀ object `v`, with the witness `v.negFix` a function of
`v` alone. Composed as `prop42_contentful_of_attained` (`Section5Correspondence.lean:115`),
the ∃v′ is hoisted **outside** ∀z₀z₁ — the contentful Prop 4.2 form; the all-⊤ escape is
closed by `topVVec_contentful_forces_unsat`. This **is** what Prop 4.2 (p.6) asserts —
negation of a ≤2-free-variable ∃∀ object is again a ∨∃∀ object, uniformly — restricted to
the attained carrier (§3.3.3), not weakened in logical form. Its per-disjunct structure
(three-way split ¬ψ₀ ∨ ¬ψ₁ ∨ ¬bracket; `VecEA2.negFix`, `:61`) mirrors the p.7
decomposition (1)/(2)/(3), and its bracket leg is the delivered Lemma 5.1 recursion —
consistent with the CI-protected correspondence table (`Section5Correspondence.lean:24–31`).

**Verdict**: both sorries are documented dead-ends of an off-paper object, not gaps in the
transcription; the transcription's Prop 4.2 lives elsewhere and is sorry-free. Recommend
Boneyard archival under task 359 (would bring the live Kamp-zone sorry count to 0 without
any mathematical change).

### 3.3 Known structural deviations (scope item 3)

#### 3.3.1 `NormalForm` (Hintikka n-type) vs Def 3.1, and where each evaluator runs

Confirmed: `NormalForm sig k n` is not Def 3.1's object (no existential prefix, no α/β
interval layer; `raw_descent_grows_arity`, `ESigmaExpansion.lean:150`, restates the arity
growth `n → n+1` per depth as a `rfl`). Post-ζ live-chain census:

- **Statements still on `nf_eval_nf`**: `nf_nvar_exist_all_depths` (arity capped at 2 by
  the `hn : n ≤ 1` domain gate, `KampPrior.lean:351`; the `n+2` arm is discharged by the
  gate, explicitly so that no unreachable `sorry` can enter the proof term, `:522–530`) and
  `nf_characterizable_temporal_prior` (arity 1). The Hintikka **type** still embeds arity
  growth in its quantifier layer, but no live proof constructs the growth above arity 2:
  the k≥2 path converts the NF to FO syntax (`nf_to_formula`) at the boundary and runs the
  faithful E[Σ]/∨∃∀ layer inside.
- **Statements free of it**: `kamp_prior_expressive_completeness` and
  `US_expressively_complete_over_prior` are stated purely as
  `eval M (fun _ => t) ψ ↔ temporal_truth M atomMap t A` — the faithful Thm 4.4 / Thm 2.1(2)
  form (pp.4, 6), relativized to Prior structures.
- **Motivation status**: NOT silent. Plan 24 records "Open Scope Question — RESOLVED to
  (b)" (statement/alphabet-level migration **of the exists-forall chain**, meeting the old
  evaluator at the `nf_to_formula` boundary), and the phase-5 completion handoff records
  the deliberate zero-churn wiring ("No consumer re-point needed: … supplied through
  `nf_characterizable_temporal_prior` unchanged"). Roadmap 03 (`:88–91`) had already
  established that the Hintikka object is "part of what the k=2 statement means" for the
  legacy spine. Classification: **MOTIVATED DEVIATION** (interface stability; the paper's
  content is carried by the top-level statements and the faithful engine).
- The top-level assembly (disjunction over "good" NFs via `doets_lemma_1_1`) is likewise a
  proof-route deviation from Thm 4.4's two-line derivation — statement faithful, route
  hybrid, motivated by reuse of the landed Doets machinery (Drift Register #10).

#### 3.3.2 Lemma 3.2(2)'s ≤2-free-variable cap (p.4)

Enforced at exactly the point the paper enforces it — the Negation case:
`efSat_negation_general_uniformFin` (`ZetaUniformExtract.lean:336–448`) decomposes
`¬(∃∀ at arity r)` into pairwise **two-variable** projections (`pairProjectFin ψ k l`,
evaluated at `![env k, env l]`), one-variable diagonals, and a variable-free existence
sentence — then feeds each through the arity-2 Prop 4.2 engine. Additionally the
`VecEA2`/`VVecEA2` negation objects are arity-2 **by type**, and the spine's `hn : n ≤ 1`
gate caps the stated NF arity at 2. Multi-free-variable ∃∀-formulas at other points of the
chain are licensed by Def 3.1 itself (m+1 free variables, p.4) — the cap applies only to
negation, as in the paper. **No live object on the k≥2 path exceeds the cap.** (The k=0/k=1
legacy arms' internal machinery reaches arity 3–4 joint environments; see Drift Register #7.)

#### 3.3.3 Section 5 carrier (attained vs Dedekind)

Confirmed sound-and-documented, fidelity-only. The live chain discharges the negation
engine's premises on Prior structures via `prior_hasAttainedINF` (`PriorINF.lean:224` — read
this session: a genuine proof from `semantic_prior_UZ`, no shortcut), and
`canonExpand_hasAttainedINF/SUP` transfer them to the expansion at the ζ site.
`Section5Correspondence.lean:37–77` documents precisely what `HasAttainedINF` excludes
(structures with non-attained infima, e.g. ℝ with P = (0,∞) at z₀ = 0 — which the paper
covers via the K⁺ disjunct of Lemma 5.3, p.8, formula (5.2)), records the machine-checked
over-strength fact `hasDefinableINF_excludes_kplus` (`Lemma53.lean:282`), and carries a
standing prohibition against re-attempting the bare model-independent backward direction.
What is dropped relative to the paper is exactly the K⁺(P₁)(z₀) disjunct (vacuous on
attained carriers) — the *documented* deviation. Consequence, stated plainly: the repo does
NOT prove Kamp's theorem over all Dedekind complete chains (in particular not over ℝ); it
proves the relativization to Prior structures, which is all `completeness_discrete` needs.
The faithful Dedekind carrier is owned by task **378** (status: not started). **MOTIVATED,
semantically non-load-bearing for the live consumer.**

#### 3.3.4 Deleted finite-alphabet machinery

`ESigmaCapture.lean` survives as a module but the finite-alphabet trio
(`intervalCapture_of_atomNamed` / `intervalCapture_forall_mem` / `esigmaCapture_canonExpand`)
and `sigE_fintypePreds` are **deleted, not ported**; its header records why: the
`Finset.univ.filter` capture witness required `Fintype` on the E[Σ] names, "which the
infinite Def 4.1 alphabet deliberately does not have… on the infinite expansion every
readback IS an atom (`atom_eval_new`)". Verified: `sigE` provides `DecidableEq` only and
deliberately no `Fintype` (`ESigmaExpansion.lean:84–91`). The deletion moved the
formalization **toward** Def 4.1 (infinite Σ), not away from it. **FAITHFUL.**

### 3.4 Axiom hygiene (scope item 4)

Independently re-verified via `lean_verify`:
`Bimodal.Metalogic.BXCanonical.completeness_discrete` depends on
`[propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]` — no
`sorryAx`, matching the phase-5 handoff claim. `Lean.ofReduceBool`/`Lean.trustCompiler`
enter via the single `native_decide` at `Theories/Bimodal/Syntax/Formula.lean:265`
(`| bot => native_decide`). Not a paper-fidelity issue. Optional hardening under task 375:
replace that one `native_decide` with `decide`/a structural proof if the goal is small,
which would shrink the axiom set to the standard `[propext, Classical.choice, Quot.sound]`.

### 3.5 Coverage sweep (scope item 5)

Statement-position `sorry` tokens (grep patterns `^\s*sorry$`, `:= sorry`, `by sorry`),
live files only (Boneyard excluded — its files are `#exit`-style non-compiling by design):

| Zone | Result |
|---|---|
| `WeakCanonical/Kamp/` (task zone) | **Exactly 2**: `EANegation.lean:1090`, `:1249` — the charter anchors (§3.2). The claim "exactly 2 task-zone sorries" is **CONFIRMED**. |
| `WeakCanonical/` outside `Kamp/` | `OrderedSum.lean:57`; `TruthLemma.lean` (6: `:431,:448,:483,:497,:540,:556` — documented non-critical guard-condition sorries); `Transfer.lean:1277` (deprecated `countermodel_discrete`, dead BX pipeline); `EFGames/StaviCompleteness.lean` (3 — the **bypassed** Stavi chain; `PriorExpressiveness.lean` header documents that the live path avoids it entirely); `Expressiveness/CaseAnalysis.lean` (8 — Stavi-side gap-detection chain, same bypass). |
| `axiom` declarations, whole `WeakCanonical/` | **Zero.** |
| `IntegerModel/GoodStructuresModelSurgery.lean` | 15 hits of the word "sorry", **all in comments/docstrings**; no statement-position sorry. |

None of the non-Kamp sorries is on the `completeness_discrete` proof term (no `sorryAx`).
Paper-alignment status of the non-Kamp files: Stavi/EFGames and Expressiveness chains
correspond to the GHR93 game-theoretic route (paper's Related Works, p.12), which the
Rabinovich route was adopted precisely to bypass — their sorries are alignment-irrelevant
to this audit and pre-date it.

---

## 4. H5 Divergence Table (audit targets, churn history, outcome)

| Target | Churn history | Last approach | Outcome |
|---|---|---|---|
| `nf_nvar_exist_all_depths \| _k+2` | 358 → 374 → 376 (abandoned: arity-4 engine = novel math) → 377 (rescope ruling) → 379 v1–v24 | ζ wire (`kampArm_zeta`) | **RETIRED sorry-free**; faithful (§3.1) |
| E[Σ] readback closure (finite F) | 379 reports 16/18/19 (NO-GO on finite-`F` closure; A-vs-B spike) | Option A: infinite alphabet, `sigE := preds ⊕ Formula` | **LANDED**; faithful to Def 4.1 |
| `h_surj` seam at ζ site | phase-5-handoff-20260724 "THE SEAM FINDING" (surjectivity FALSE on expansion) | `nameOf`/`hName` generalization (p.6 collapse inlined) | **CLOSED**; faithful (§3.1.2) |
| `neg_bracket_is_vbracket` B.1 backward | three-strikes adjudicated unfixable at BracketFormula level | none (standing prohibition) | **DEAD-END, kept documented**; paper never needs the case (§3.2) |

Sorry inventory (live task zone): see §3.5 — 2 entries, both in §3.2, both zero-consumer.
No corrected Lean-ready targets are required: no live target is currently failing.

---

## 5. Drift Register

Every known deviation from Rabinovich 2014, with classification. **No entry is UNMOTIVATED.**

| # | Deviation | Class | Motivation / documentation site |
|---|---|---|---|
| 1 | `sigE` fresh summand indexes ALL of `Formula`, not only TL(U,S)-formulas over Σ | MOTIVATED | Single object-language type; extra names inert. `ESigmaExpansion.lean` header |
| 2 | `F : Finset Formula` retained as inert type-level stage index (paper has none) | MOTIVATED | Downstream arity stability; documented `ESigmaExpansion.lean:63–64`. Cleanup candidate → 359 |
| 3 | `canonExpand` parametrized by `sat` instead of fixed ⊨ | MOTIVATED | Proof engineering; only live instantiation is `temporal_truth M g` = Def 4.1's ⊨ (`kampArm_zeta:784`) |
| 4 | `nameOf` base-pred leg (`inl q ↦` chosen atom) has no paper counterpart | MOTIVATED | Object-language encoding of Σ-atoms; degenerate-case proof `nameOfSurj_hName` |
| 5 | StrictMono environment discipline + gap/tie ∃-closure (`insertPerm`/`subst0`) vs Def 3.1's `z_k = x_{i_k}` tie prefix | MOTIVATED | Equivalent encoding; adjudicated `specs/379_*/reports/14_*`, `15_*` |
| 6 | Hintikka `NormalForm`/`nf_eval_nf` in intermediate spine statements (not Def 3.1's object) | MOTIVATED | Plan-24 "Open Scope Question — RESOLVED to (b)"; zero-churn boundary at `nf_to_formula`; top statements paper-faithful (§3.3.1) |
| 7 | k=0/k=1 arms retain the per-depth legacy route (incl. `NfMultiAnchorBridge` tree importing `NfEFold`, internal arity-3/4 machinery) although `kampArm_zeta` is general in k | MOTIVATED | Landed proofs preserved (convergence policing); consolidation + arity-4 apparatus archival owned by **359** |
| 8 | `HasAttainedINF/SUP` carrier instead of Dedekind completeness (Prop 4.2, negation engine, and hence the whole relativized theorem class) | MOTIVATED | Sound on live path (`prior_hasAttainedINF`); exclusions documented + machine-checked (`Section5Correspondence.lean:37–77`); faithful carrier owned by **378** |
| 9 | `BracketFormula` evaluates α₀ at interior witness with leading β₀ segment (vs Lemma 5.1's pinned `x₀ = z₀`, p.7) — root cause of the 2 sorries | MOTIVATED (dead-end, quarantined) | Inline impossibility adjudication `EANegation.lean:1047–1089`; zero consumers; archival → **359** |
| 10 | Top-level assembly via `doets_lemma_1_1` good-NF disjunction instead of Thm 4.4's direct Prop 4.3 + Prop 3.5 two-step | MOTIVATED | Statement faithful; reuses landed Doets machinery; ζ arm internally IS Prop 4.3 + Prop 3.5 |
| 11 | Base signature assumed `[Fintype sig.preds]` throughout (paper's Σ arbitrary) | MOTIVATED (pre-existing, global) | Standing frame of the whole NF formalization; declared in every statement, never silent |

---

## 6. Recommended Follow-ups

| Item | Owner |
|---|---|
| Archive `neg_bracket_is_vbracket` / `neg_partialBracketExist_is_vbracket` (+ their private helpers) to Boneyard → live Kamp-zone sorry count 0 | **359** (boneyard hygiene) — matches phase-5 handoff's assignment |
| Arity-4 apparatus archival (`NfMultiAnchorBridge` tree, `NfEFold` fold evaluator) once k=0/1 arms are (optionally) consolidated onto `kampArm_zeta` | **359**; consolidation itself is optional and should NOT be done casually (plan-compliance: landed proofs) |
| Faithful Dedekind carrier for Section 5 (restore the K⁺ disjunct; un-restrict Prop 4.2) | **378** (charter matches exactly) |
| `native_decide` → `decide` hardening at `Syntax/Formula.lean:265` to drop `Lean.ofReduceBool`/`Lean.trustCompiler` | **375** (this task's final-assembly scope) |
| `F` stage-index removal from `sigE`-downstream types (cosmetic) | **359** or fold into 378; low priority |
| Task **383** (negation-case unblock per adjudication) — verify against this audit whether its blocker is subsumed by the landed ζ path before further work | **383** triage (no new task needed) |

**No new task is required by this audit.** No unmotivated drift exists to assign.

---

## 7. Adversarial Self-Verification

Stance taken: "deviates until shown otherwise." Every load-bearing claim re-checked below.

### Claim Verification Table

| Claim | Source/Counterexample | Verification Method | Confidence |
|---|---|---|---|
| Def 4.1 indexes expansion atoms by formulas, unary, infinite | PDF p.5 read directly this session (Def 4.1 quoted verbatim in §3.1.1) | Primary-PDF read | High |
| `sigE` = `preds ⊕ Formula`, no Fintype, `canonExpand` interprets `inr A` as `{a \| sat A a}` | `ESigmaExpansion.lean:70,101,84–91` read in full | Read (whole file, 193 lines) | High |
| p.6 contains a collapse-to-atom note and `nameOf (inr A) = A` transcribes the Def 4.1 interpretation equation | PDF p.6 note quoted verbatim §3.1.2; `zetaNameOf` source `:726–731`; `zetaNameOf_hName` discharge at `canonExpand_atom_named` | Primary-PDF read + Read | High |
| `translate_uniformFin` is Prop 4.3's structural induction; negation case = Lemma 3.2(2) split + Prop 4.2 engine | `ZetaUniformExtract.lean:588–699` (all six cases read); `:336–448` (`pairProjectFin` 2-var projections read) | Read | High |
| `_k+2` arm proves exactly kampArm_zeta's statement modulo env reindexing, both directions, same preconditions | `KampPrior.lean:493–521` read line-by-line; adapter is `funext` + two-way existential conversion | Read | High |
| Lemma 5.1's bracket pins `x₀ = z₀`, α₀ at the endpoint, no β₀ segment in-bracket; β₀ lives in ψ₀(z₀) | PDF p.7 (formula 5.1 and decomposition (1)–(3)), p.9 (Case 1 "¬α₀(z₀)") read directly | Primary-PDF read | High |
| The two EANegation sorries have zero consumers | repo-wide grep excluding defining file and Boneyard: empty result | grep sweep | High |
| `completeness_discrete` axioms = `[propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]`, no sorryAx | `lean_verify` on `Bimodal.Metalogic.BXCanonical.completeness_discrete`, this session | lean_verify (independent re-check, not the handoff's claim) | High |
| Exactly 2 statement-position sorries in live Kamp zone; 0 `axiom` decls in WeakCanonical | word-boundary/statement-pattern greps, Boneyard excluded; comment-only hits (e.g. `GoodStructuresModelSurgery`, 15 comment hits) separately confirmed non-statements | grep sweep ×2 patterns | High |
| `VVecEA2.negFix_iff` is contentful Prop 4.2 (∃v′ uniform), attained-carrier-restricted, not form-weakened | `VecEANegFix.lean:61–184` read; `Section5Correspondence.lean` read in full (incl. `topVVec_contentful_forces_unsat` escape-closure record) | Read | High |
| Carrier deviation documented + machine-checked over-strength | `Section5Correspondence.lean:37–77`; `hasDefinableINF_excludes_kplus` cited at `Lemma53.lean:282` | Read (citation of the machine-check not re-run — see Contradiction Log note) | Medium-High |
| `nf_eval_nf` retention in spine statements is a recorded decision, not silent | plan 24 `:258–264` ("RESOLVED to (b)") + phase-5-complete handoff ("No consumer re-point needed") read | Read of task artifacts | High |
| Lemma 5.3 (p.8) keeps 2 free variables and shrinks the predicate list — "Rabinovich never grows arity" | PDF p.8 read: `O_{n+1}` reduces to `O_n` over `(z₀,z₁)` or `(r₀,z₁)`, always 2 free vars | Primary-PDF read | High |
| `prior_hasAttainedINF` is a genuine proof from `semantic_prior_UZ` | `PriorINF.lean:224–245` read (proof body, not just statement) | Read | High |

### Contradiction Log

- **Mission text vs repo**: the mission described the sigE summand as "`{A // A ∈ F}` →
  Formula". The landed source has no subtype anywhere in `sigE` — the mission's arrow
  notation reads as "changed FROM subtype TO Formula", which matches the
  `ESigmaCapture.lean` header's history of the flip. Resolved: no contradiction; current
  state verified from source.
- **"report 18 §4"** (mission, for the B.1 adjudication) vs `specs/379_*/reports/18_*`
  (readback rescope, different content): the inline comment at `EANegation.lean:1049` cites
  its own "report 18, Section 4: The B.1 Backward Gap" from an earlier task's report
  series. Resolved by verifying the mathematical content directly against PDF pp.7, 9
  rather than resolving the report provenance; the paper check is independent and decisive.
- **Not re-run**: `hasDefinableINF_excludes_kplus` (cited as machine-checked in the
  CI-protected `Section5Correspondence.lean`, which cannot rot without breaking the build).
  Residual risk low; flagged Medium-High above rather than High.

### Recommendations modified after verification

- Initial draft classified the k=0/k=1 per-depth arm retention as a candidate
  "unaddressed" drift; downgraded to MOTIVATED after locating the explicit in-arm comment
  (`KampPrior.lean:503–504`: "only the k=0/k=1 arms above retain the per-depth route") and
  the 359 ownership note in the phase-5 handoff.
- Initial draft treated the multi-free-variable ∃∀-formulas at arity m in
  `translate_uniformFin` as a possible Lemma 3.2(2) violation; withdrawn after re-reading
  Def 3.1 (p.4): m+1 free variables are licensed by the definition itself, and the ≤2 cap
  is applied by the paper only at the negation step — which is exactly where the repo
  applies it.
