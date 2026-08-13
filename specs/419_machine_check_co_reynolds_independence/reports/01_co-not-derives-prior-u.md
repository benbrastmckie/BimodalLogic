# Research Report: Machine-checking CO ⊬ Prior-U (Reynolds gap axioms)

- **Task**: 419 - Machine-check the CO-does-not-derive-Reynolds independence result
- **Started**: 2026-08-12T00:00:00Z
- **Completed**: 2026-08-12T00:00:00Z
- **Effort**: large
- **Dependencies**: 420, 438, 439 (all satisfied for the purposes of this pass; the definitions-of-record lint passes)
- **Sources/Inputs**:
  - Paper anchors (via `specs/paper-definitions-of-record.md`, verified by `scripts/check-paper-definitions.sh`): `def:temporal-order`, `def:task-relation`, `def:directed`, `def:frame` (+ the four sub-anchors), `def:world-history`, `def:BL-model`, `def:BL-semantics`, `def:BLplus-semantics`, `def:BLplus-defined`, `def:frame-validity`, `lem:step`, `lem:constraint`, `CO`, `TMP-CO`
  - `FormalSystem/ProofSystem/Axioms.lean` (Layer 9 prose, `Axiom.prior_U_gap`, `FrameClass`)
  - `FormalSystem/Semantics/TaskFrame.lean`, `Truth.lean`, `TaskModel.lean`, `WorldHistory.lean`, `Validity.lean`
  - `FormalSystem/ProofSystem/Derivation.lean`, `Derivable.lean`, `FormalSystem/Metalogic/Soundness.lean`
  - `FormalSystem/Theorems/DedekindDerived.lean` (`co_derived`), `FormalSystem/Syntax/Formula.lean` (`Formula.co`, `kPlus`)
- **Artifacts**: `specs/419_machine_check_co_reynolds_independence/reports/01_co-not-derives-prior-u.md`
- **Standards**: status-markers.md, artifact-management.md, tasks.md, report-format.md

## Executive Summary

- **The primary open question is RESOLVED, negatively for the risk and positively for the task**: *Spherical* does not threaten the countermodel. The task description's worry rests on a conflation — in the sketch the ℚ is the **temporal order `D`**, whereas the paper's worked non-example (footnoted at `def:world-history`) puts its ℚ in the **world-state carrier `W`**. `def:frame`'s four axioms constrain `W` and `⇒`; `def:temporal-order` requires of `D` only that it be a nontrivial totally ordered abelian group, and ℚ is one. Gappy time is unconstrained by *Spherical*.
- **The sketch's own witness is REFUTED.** The ℚ-flow "with isolated ¬φ points accumulating at an irrational from above" does **not** validate every CO instance. A concrete counter-instance is exhibited below (`ξ := ¬U(¬p,p) ∧ F(U(¬p,p))` defines the cut `{t < √2}` in that very model, and `CO(ξ)` is false there). Three natural repairs are refuted too. The "classical Stavi US-vs-FO phenomenon" framing in `Axioms.lean` is therefore a red herring as well as unnecessary.
- **A frame-level countermodel is impossible in principle.** Frame-validity of CO (per `def:frame-validity`, quantifying over *all* valuations) forces the flow to have no gaps, hence forces Prior-U valid too. The independence witness must be a **model** (fixed valuation) — which is exactly Reynolds' own "definably Dedekind-complete" point, printed p.169, already quoted in `Axioms.lean`.
- **A working countermodel was found and verified by hand**: the **periodic clock frame** — `D = ℚ`, `W = ℚ ⧸ ℤ` (the rational circle), `w ⇒_x u ⟺ u = w + x`. It satisfies all four `def:frame` axioms (*Spherical* trivially: every fiber is a singleton), every total history is forced to be 1-periodic by *Compositionality*/`respects_task` alone, so every formula's truth value is 1-periodic in time, so `Hψ → Gψ` — hence `CO(ψ)` — holds at every point for **every** `ψ`. With the valuation "the arc of the circle within irrational distance `√2/4` of `0`", `Axiom.prior_U_gap p` is **false** at time `0`.
- **Generalized as a reusable Lean lemma**: *any* frame carrying a **looping duration** `π ≠ 0` (one with `TaskRel w π u ↔ u = w`) validates `Hψ → Gψ` and hence all of CO, over any Archimedean `D`. The clock frame is a two-line instance of it.
- **Lean landing is fully mapped and modest in size.** All four frame axioms are already `TaskFrame` fields (including `spherical`); `soundness_dense` gives every Dense-admissible axiom in the countermodel for free; `Derivable`/`¬ Derivable` is the right statement shape, with `not_derivable_nil_bot` as the exact proof template. Estimated 500–800 lines across 5 phases.
- **Section 2 of the task description is already discharged**: `grep` finds **zero** occurrences of `possible_worlds.tex` anywhere in the Lean tree; both `DedekindDerived.lean` and `Formula.lean` already cite `\aitem[CO]{TMP-CO}` verbatim. No re-anchoring work remains.

## Context & Scope

The goal is a machine-checked witness that the paper's CO principle does not syntactically derive the Reynolds gap axioms, specifically `Axiom.prior_U_gap`. The converse (`co_derived` : Reynolds ⊢ CO, sorry-free, consuming only `Axiom.prior_U_gap` outside the base) is done and is not touched by anything here.

Preflight per section 6 of the task description: `bash scripts/check-paper-definitions.sh` exits `0` silently — **case (a)**, proceed. All paper citations below are by `\label` / `\aitem` key with verbatim text, per that file's contract.

The formulas at issue, verbatim from the tree:

- `Formula.co φ = (Formula.always (φ.allPast.imp φ.allPast.someFuture)).imp (φ.allPast.imp φ.allFuture)`, i.e. `△(Hφ → F(Hφ)) → (Hφ → Gφ)`, with `always ψ = Hψ ∧ ψ ∧ Gψ` (the **temporal** triangle, not `box`).
- `Axiom.prior_U_gap φ : (U(⊤,φ) ∧ F(¬φ)) → U(¬φ ∨ K⁺(¬φ), φ)`, with `kPlus φ = ¬U(⊤, ¬φ)`.
- `untl` is **event-first / guard-second** (`Truth.lean`): `U(A,B)` at `t` iff `∃ s > t`, `A` at `s`, and `B` at every `r ∈ (t,s)`. This matches `def:BLplus-semantics` modulo the argument-order swap the paper itself now flags.

## Findings

### F1. Spherical does not threaten the construction (PRIMARY QUESTION — RESOLVED)

The paper's non-example, footnoted to the world-history sentence (durable anchor `def:world-history`), reads verbatim:

> "Convexity alone does not guarantee extendability: taking D = Q and W = {q in Q : q > 0} with r =>_x r' *iff* |r' - r| <= x yields a structure satisfying every axiom but *Spherical* …"

The gap it exploits lives in **`W`** (the punctured rational half-line as a *state* space). *Spherical* — `\item[\it Spherical:] $\bigcap \mathcal{S} \neq \emptyset$ for any directed family $\mathcal{S}$ of nonempty fibers and segments.` — is a condition on families of subsets of `W` only (`def:task-relation`: `Fib(w,x) ⊆ W`, `[w,v]_x^y ⊆ W`). It says nothing whatsoever about `D`.

The gap this task needs lives in **`D`**. `def:temporal-order` requires of `D` only: `A \textit{temporal order} is a nontrivial totally ordered abelian group $\D = \tuple{D, +, 0, \leq}$ …`. ℚ qualifies. Nothing in `def:frame`, `lem:constraint`, `lem:step`, `thm:extension` or `cor:occurrence` requires `D` to be Dedekind complete — and indeed the tree's own `ValidDedekind` puts the LUB hypothesis on `D` as an *extra* hypothesis, not a frame field.

Two independent confirmations that gappy `D` is orthogonal to *Spherical*:

- **Cheap fix if `W` ever needed to be metric-like**: `W = ℝ` with `D = ℚ` and `w ⇒_x u ⟺ |u - w| ≤ x` satisfies all four axioms (*Spherical* by compactness/FIP on closed bounded real intervals) while `D` stays gappy. The paper's non-example is repaired simply by completing `W`.
- **The construction actually recommended below** sidesteps `W`-completeness entirely: with a deterministic flow every fiber is a **singleton**, so a directed family of nonempty fibers/segments is a family of equal singletons and `⋂₀ 𝒮` is that singleton. *Spherical* is discharged in a few lines.

The Lean tree already carries a worked precedent for exactly this shape: `FormalSystem/Metalogic/Decidability/Verified/Bridge/RegionFrame.lean:174` defines the deterministic clock `regionFrame` (`TaskRel s d s' := s.1 = s'.1 ∧ s'.2 = s.2 + d`) and discharges all four axioms, with `TaskFrame ℚ` instantiations at `:569-571`.

**Verdict**: this risk is retired. It does not require an alternative carrier and does not gate the Lean work.

### F2. The sketch's stated witness does NOT validate CO (REFUTATION)

`Axioms.lean` (Layer 9, immediately above `prior_U_gap`) records:

> "A ℚ-flow carrying isolated `¬φ` points that accumulate at an irrational from above validates every CO instance while refuting Prior-U — the classical Stavi US-vs-FO phenomenon."

Take that model literally: times `T = ℚ`; one atom `p`; `[¬p] = {a_n}` with `a_n ∈ ℚ` strictly decreasing, `a_n > √2`, `a_n → √2`.

*Prior-U does fail* (as claimed): at `t = 0`, `U(⊤,p)` holds (`p` on `(0,1)`), `F(¬p)` holds (at `a_1`); any witness `s` needs `p` throughout `(0,s)`, forcing `s < √2`, where `p(s)` holds and `U(⊤,p)(s)` holds (`p` on `(s,√2)`), so `K⁺(¬p)(s)` fails. No witness.

*But CO also fails*, so the model is not a countermodel at all. Compute:

| formula | truth set |
|---|---|
| `U(¬p, p)` | `(√2, a_1) ∩ ℚ` — for `t < √2` every `(t,a_n)` still contains some `a_m`; for `√2 < t < a_1` the finitely many `a_n > t` have a least element |
| `F(U(¬p,p))` | `{t < a_1}` |
| `ξ := ¬U(¬p,p) ∧ F(U(¬p,p))` | **`{t ∈ ℚ : t < √2}`** |

So `ξ` *defines the cut*. Then `Hξ` has truth set `{t < √2}` as well; `△(Hξ → F Hξ)` holds everywhere (below `√2` pick an intermediate rational, above `√2` the antecedent is false); `Hξ` holds at `0`; but `Gξ` fails at `0` (e.g. at `a_1`). **`CO(ξ)` is false at `0`.** Since CO is a schema, `ξ` is a legitimate instance.

Three natural repairs also fail, for the same structural reason (some U/S-formula recovers the cut):

- `[p] = (0,√2) ∩ ℚ` (φ-region an interval with rational left end): `p ∨ H(¬p)` defines `{t<√2}`.
- `[p] = (c₀,c₁) ∩ ℚ` with **both** endpoints irrational: `H(¬p)` still defines `{t<c₀}`, and `p ∨ H(¬p)` defines `{t<c₁}`.
- `[p]` an interval plus wild past, `p` false above the gap: `F(p)` defines `{t < c}`; if `p` is instead true cofinally above but the pure-φ interval is unique, `U(⊤,p) ∧ ¬U(¬p,p)` isolates that interval and `F(·)` of it defines the cut.

The pattern generalizing all four: **CO fails in a model exactly when some formula's truth set touches a gap** (has the gap as an approached sup or inf). Prior-U's failure *requires* `[¬φ]` to be coinitial above the gap. Any construction that makes those `¬φ` points structurally distinguishable from the rest of the model hands the cut back to the language. The escape is **homogeneity**, not accumulation — see F4.

**Consequence**: the `Axioms.lean` prose must be corrected regardless of outcome. Its claim is not merely unverified; the specific witness it names is wrong.

### F3. No frame-level countermodel exists (structural constraint on the statement)

`def:frame-validity` reads verbatim: `A well-formed sentence $\varphi$ of $\BL$ is \emph{valid over a frame} $\F$ … if and only if $\M,\tau,x \vDash \varphi$ for every model $\M$ …`. Quantifying over **all** valuations, if a frame admits a history realizing arbitrary subsets of `D` (e.g. `W = ℝ`, `D = ℚ`, `τ = inclusion`), then `P := {t : t < c}` for a gap `c` yields `A_P := {s : (-∞,s) ⊆ P} = {s < c}`: downward-closed, bounded, no maximum — and CO fails. Conversely a frame poor enough to block that (e.g. `W` a singleton) makes all formulas constant in time, validating *both* CO and Prior-U vacuously.

General fact behind this: `A_P` downward-closed with no maximum and bounded above is possible **only at a genuine gap** (if the complement had a minimum `r`, then `A_P = (-∞,r)` forces `(-∞,r) ⊆ P` hence `r ∈ A_P`, contradiction). So *frame*-validity of CO on a dense flow ⟹ Dedekind completeness ⟹ Prior-U valid.

**Therefore**: the theorem must be stated over a **fixed model** `M` (a `TaskModel`, i.e. one valuation), not over a frame class. This aligns with Reynolds' own printed caveat already quoted in `Axioms.lean` p.169 ("definably Dedekind-complete"), and it dictates the Lean statement shape in F6.

### F4. The periodic clock countermodel (POSITIVE RESULT, verified by hand)

**Frame.** `D := ℚ`. `W := ℚ ⧸ AddSubgroup.zmultiples (1:ℚ)` (the rational circle; `AddCircle (1:ℚ)`). `w ⇒_x u :⟺ u = w + ⟦x⟧`.

All obligations of the Lean `TaskFrame` structure:

| field | discharge |
|---|---|
| `nonempty` | `⟦0⟧` |
| `nullity_identity` (`TaskRel w 0 u ↔ w = u`) | `u = w + 0` |
| `comp` (Compositionality, the full biconditional) | `u := w + ⟦x⟧` both ways; deterministic, so interpolation is immediate |
| `converse` | `u = w + ⟦d⟧ ↔ w = u + ⟦-d⟧` |
| `serial` | `u := w + ⟦x⟧`, `v := w - ⟦x⟧` |
| `limit` | if `u ≠ w`, the representative distance `min(d, 1-d) > 0` is a positive rational; take `x` below it |
| `spherical` | every `Fib(w,x)` is a **singleton**; a segment is an intersection of two singletons; directedness of a family of nonempty singletons forces them all equal, so `⋂₀ 𝒮` is that singleton |

**Every total history is 1-periodic — forced by the frame, not assumed.** For a total `τ`, `respects_task` at `(s, s+1)` gives `TaskRel (τ s) 1 (τ (s+1))`, i.e. `τ(s+1) = τ(s) + ⟦1⟧ = τ(s)`, since `⟦1⟧ = 0` in `ℚ ⧸ ℤ`. No characterization of `H_F` is needed.

**Truth is 1-periodic.** By induction on the formula, for every total `τ` and every `t`: `TruthAt M τ t φ ↔ TruthAt M τ (t+1) φ`.
- atom: `τ.states (t+1) = τ.states t` (above); domain conjunct vacuous by totality.
- `bot`, `imp`: immediate.
- `box`: the clause quantifies over **all** total `σ` (`Truth.lean`), and every one of them is 1-periodic, so the IH applies uniformly.
- `untl` / `snce`: reindex the witness and the guard interval by `s ↦ s ± 1` (an order-isomorphism of `D`), then IH.

**Hence `Hψ → Gψ` holds at every point, for every `ψ`.** Given `Hψ` at `t` and any `s > t`, Archimedean ℚ gives `n : ℕ` with `s - n < t`; `ψ` holds there; `n` applications of periodicity move it to `s`.

**Hence every CO instance is true at every point.** `co ψ = A → (Hψ → Gψ)` and the consequent is already valid on `M`.

**Prior-U fails.** Valuation: `V(w, p) :⟺ ∃ q : ℚ, ⟦q⟧ = w ∧ |(q:ℝ)| < α`, with `α := √2/4 ≈ 0.3536` (irrational, `0 < α < 1/2`). Along the history `τ₀(t) = ⟦t⟧`, `p` is true at `t` iff `∃ n : ℤ, |t - n| < α`, i.e. `[p] = ⋃_{n∈ℤ} (n-α, n+α) ∩ ℚ`. At `t = 0`:
- `U(⊤,p)`: witness `s = 1/4 < α`; `p` throughout `(0,1/4)`. TRUE.
- `F(¬p)`: witness `s = 1/2` (`|1/2 - n| ≥ 1/2 > α` for every `n`). TRUE.
- Conclusion `U(¬p ∨ K⁺(¬p), p)`: any witness `s` needs `p` throughout `(0,s)`. If `s > α`, density of ℚ gives a rational in `(α, min(s, 1-α))` where `p` fails — so `s < α`. At such `s`: `p(s)` holds, so `¬p(s)` fails; and `U(⊤, ¬¬p)` holds at `s` (take any rational `u ∈ (s,α)`), so `K⁺(¬p)(s)` fails. **No witness — conclusion FALSE.**

So `Axiom.prior_U_gap p` is refuted at `(τ₀, 0)` in a model of every CO instance. The base and density axioms come free from `soundness_dense` (ℚ is `DenselyOrdered`), so no separate check is needed for them.

**Why this works where the Stavi sketch fails**: the countermodel does not try to hide an accumulation point; it makes the flow **homogeneous under a time translation that fixes every world**. That is precisely what the quotient buys — on the un-quotiented line frame (`W = ℚ`, `u = w + x`) the time shift moves worlds (`τ_c ↦ τ_{c-1}`) and the argument collapses; the *torsion* in `ℚ ⧸ ℤ` is load-bearing.

### F5. Generalization: the "looping duration" lemma

Nothing above uses the circle beyond one property. Define: `π : D` is a **looping duration** of `F` iff `π ≠ 0` and `∀ w u, F.TaskRel w π u ↔ u = w`.

**Lemma A** (frame ⟹ history periodicity): if `π` is a looping duration then every total history satisfies `τ.states (x+π) = τ.states x`.
**Lemma B** (truth periodicity): consequently `TruthAt M τ t φ ↔ TruthAt M τ (t+π) φ` for all `M`, total `τ`, `t`, `φ`.
**Lemma C** (CO validity): with `[Archimedean D]`, `F` validates `Hψ → Gψ` and hence `Formula.co ψ`, for every `ψ` and every model on `F`.

Lemma C is the reusable content; the clock frame is one instance. This also yields, for free, the past-mirror (`Gψ → Hψ`), which matters for the `temporal_duality` rule (see F6/R3).

### F6. How this lands in the Lean tree

Verified infrastructure facts:

- `TaskFrame` (`FormalSystem/Semantics/TaskFrame.lean:472`) is over `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]`, with fields `nonempty`, `TaskRel`, `nullity_identity`, `comp`, `converse`, `serial`, `limit`, `spherical`. **All four paper axioms are fields**; `spherical` is real and must be discharged.
- `TruthAt` (`FormalSystem/Semantics/Truth.lean:145`) has no `Ω` parameter; `box` ranges over all `σ` with `σ.IsTotal`; `untl`/`snce` quantify over all of `D`; `TaskModel.valuation : F.WorldState → Atom → Prop` is state-indexed, matching `def:BL-model` (`$\vert{p_i} \subseteq W$`).
- `DerivationTree (fc : FrameClass) : Context → Formula → Type` with `Context = List Formula`; constructors `axiom, assumption, modus_ponens, necessitation, temporal_necessitation, temporal_duality, weakening`. The three rule constructors are **restricted to the empty context**. `Derivable fc Γ φ := Nonempty (DerivationTree fc Γ φ)` is the Prop-level interface.
- `soundness_dense (Γ) (φ) (d : DerivationTree FrameClass.Dense Γ φ) … [DenselyOrdered D] … (h_ctx : ∀ ψ ∈ Γ, TruthAt M τ t ψ) : TruthAt M τ t φ` — exactly the hammer needed, and it hands over every Dense-admissible axiom for free.
- `not_derivable_nil_bot` (`Metalogic/Soundness.lean:1968`) is the proof template: `rintro ⟨d⟩`, apply soundness at a concrete frame, refute the truth claim. There is **no** existing independence result in the tree; this would be the first.
- Module wiring: add `FormalSystem/Metalogic/Independence/CoNotPriorU.lean` plus aggregator `FormalSystem/Metalogic/Independence.lean`, and one `import` line in `FormalSystem/Metalogic.lean`. No lakefile change. Note `autoImplicit := false`.

Two statement strengths are available, and both are worth having:

- **(S1) Context form (cheap, no new soundness machinery)**
  `theorem co_not_derives_prior_U_gap (Γ : Context) (hΓ : ∀ ψ ∈ Γ, ∃ χ, ψ = Formula.co χ) : ¬ Derivable FrameClass.Dense Γ priorUGapFormula`
  Proof: `rintro ⟨d⟩`; `soundness_dense` at the clock model with `h_ctx` from Lemma C; contradict the refutation of F4. Because contexts are finite lists and every derivation is finite, this already says "no finite set of CO instances derives Prior-U over the dense base".
- **(S2) Schema form (the full claim)** — a bespoke `inductive CoDerivation` in the new file with constructors: any `Axiom` at `minFrameClass ≤ .Dense`, `Formula.co χ` for every `χ`, and mirrors of `modus_ponens` / `necessitation` / `temporal_necessitation` / `temporal_duality`. Soundness of this system over the clock model, then `¬ Nonempty (CoDerivation priorUGapFormula)`. S2 is the statement that closes "CO does not **syntactically derive** `prior_U_gap`" without a caveat, because it permits necessitation over CO instances (which S1 cannot, since the rule constructors require `Γ = []`).

S2's only genuine extra obligation is `temporal_duality` (`φ ↦ φ.swapTemporal`), which needs the model to be isomorphic to its own time-reversal. **The symmetric arc chosen in F4 (`|q| < α`, centred at `0`) is exactly what makes this true**: `w ↦ -w` on `ℚ ⧸ ℤ` preserves `V(p)` and reverses durations, so `M ≅ M^rev` via an explicit mirror lemma. (Had the arc been `(β,α)`, this would fail. The symmetric arc was chosen for this reason and should not be "simplified" to an asymmetric one.)

### F7. Ancillary findings

- **Citation correction (section 2 of the task): already done.** `grep -rn "possible_worlds.tex" --include=*.lean .` returns **0 hits**. `DedekindDerived.lean` and `Formula.lean` both already carry the `\aitem[CO]{TMP-CO}` anchor with verbatim LaTeX and the `△ = Formula.always, not Formula.box` warning. Nothing to re-anchor.
- **Literature acquisition is NOT needed** (task description's "likely needs a /literature acquisition pass for Stavi and Reynolds 1992"). The Stavi US-vs-FO expressiveness gap is not the mechanism of the working countermodel; F2 shows it is not even sufficient for the sketch as stated. Reynolds 1992's printed p.168/p.169 content is already quoted in `Axioms.lean` and is not needed again. Recommend **downgrading** this to optional.
- **Bonus targets, cheap once the machinery exists**: the same model plausibly refutes `Axiom.prior_S_gap` (by the mirror symmetry of the arc) and possibly `Axiom.sep`. Worth one stretch phase, not worth blocking on.
- **Paper-side consequence stands, and is now better supported**: if S1/S2 land, `def:TMplus-c` (whose extra axiom is `\aitem[CO]{TMP-CO}`, verbatim `$\always(\Past\varphi \rightarrow \future\Past\varphi) \rightarrow (\Past\varphi \rightarrow \Future\varphi)$`) is deductively too weak for the completeness corollary, and the fix.md C4 option-2 amendment is warranted. No file under `Philosophy/Papers/` is edited from here (task section 5).

## Decisions

- **D1**: Reject the ℚ-accumulation / Stavi witness named in the `Axioms.lean` Layer 9 prose. It is refuted (F2), not merely unverified.
- **D2**: Adopt the periodic clock frame (`D = ℚ`, `W = ℚ ⧸ ℤ`, deterministic translation flow) with the symmetric irrational arc valuation as the countermodel.
- **D3**: State the result over a fixed `TaskModel`, never over a frame class (F3 shows the frame-level statement is false).
- **D4**: Route the general content through a `LoopingDuration` lemma (F5) so the CO-validity half is reusable and the concrete frame is a thin instance.
- **D5**: Build the countermodel on `ℚ ⧸ AddSubgroup.zmultiples (1:ℚ)` via `QuotientAddGroup` rather than Mathlib's `AddCircle` API, to avoid dragging in the topological instance stack; keep `AddCircle` as a fallback and a hand-rolled `Quotient` as a second fallback.
- **D6**: Do not add an `Axiom.co` constructor. The official Dedekind basis stays the Reynolds triple; the CO system is defined locally in the new file (S2) or supplied as context (S1).
- **D7**: Target `FrameClass.Dense` (the paper's TM⁺_c has no `FrameClass` element — a documented gap). This makes the theorem say precisely "dense base + CO ⊬ Prior-U".

## Recommendations

Prioritized, phrased as an implementation outline. Zero sorries throughout; every phase ends green under `lake build FormalSystem.Metalogic.Independence.CoNotPriorU`.

- **R1 — Phase 1: the clock frame** (new file `FormalSystem/Metalogic/Independence/ClockFrame.lean`, ~180 lines).
  Define `W := ℚ ⧸ AddSubgroup.zmultiples (1:ℚ)`, `clockFrame : TaskFrame ℚ`, discharge all eight `TaskFrame` obligations (F4 table). Add `clockHistory : WorldHistory clockFrame` with `clockHistory_isTotal`. *Verification*: the frame elaborates and `example : Nonempty (TaskFrame ℚ) := ⟨clockFrame⟩` compiles.
- **R2 — Phase 2: the looping-duration lemmas** (`.../LoopingDuration.lean`, ~200 lines).
  `LoopingDuration F π`, Lemma A (history periodicity), Lemma B (truth periodicity, induction on `Formula`, six cases), Lemma C (`Hψ → Gψ`, then `Formula.co ψ`, using `Archimedean D`). *Verification*: `clockFrame` instantiates all three; `∀ ψ M τ t, τ.IsTotal → TruthAt M τ t (Formula.co ψ)` is proved.
- **R3 — Phase 3: the refutation** (`.../CoNotPriorU.lean`, ~200 lines).
  Define the arc valuation `clockModel`, prove the three membership facts (`p` on `(0,1/4)`; `¬p` at `1/2`; no rational `s ≥ α` admits `p` throughout `(0,s)` — this is where `Irrational (√2/4)` and `exists_rat_btwn` are used), then `¬ TruthAt clockModel clockHistory 0 priorUGapFormula`. *Verification*: the negation is proved with no `sorry`.
- **R4 — Phase 4: statement S1** (same file, ~60 lines). `soundness_dense` + R2 + R3. This is the first machine-checked independence result in the tree.
- **R5 — Phase 5: statement S2** (same file, ~200 lines). `CoDerivation` inductive + its soundness over `clockModel`, including the time-reversal mirror lemma for `temporal_duality` (uses the symmetry of the arc). If the mirror lemma proves harder than budgeted, mark the phase `[BLOCKED]` and escalate — do **not** weaken `CoDerivation` by dropping `temporal_duality`, which would silently change what is being claimed.
- **R6 — Phase 6: prose correction** in `FormalSystem/ProofSystem/Axioms.lean` Layer 9. Replace the ℚ-accumulation/Stavi paragraph with: (i) the now-machine-checked statement and a pointer to the new module; (ii) an explicit note that the previous sketch's witness was refuted and why (a formula recovers the cut), so it is not re-attempted; (iii) retain the paper-consequence paragraph unchanged. Also add a short forward pointer from `DedekindDerived.lean`'s `co_derived` docstring ("the converse now has a machine-checked refutation at …").
- **R7 — optional stretch**: refute `Axiom.prior_S_gap` in the same model via the arc's mirror symmetry; probe `Axiom.sep`.
- **R8 — do not** run a `/literature` acquisition pass for Stavi/Reynolds unless R5 stalls (F7).

## Risks & Mitigations

- **Mathlib quotient ergonomics** (`ℚ ⧸ AddSubgroup.zmultiples 1`): decidability and `Quotient.lift` well-definedness may be fiddly. *Mitigation*: the valuation is stated as an existential over representatives (`∃ q, ⟦q⟧ = w ∧ |(q:ℝ)| < α`), which is well-defined by construction and needs no `lift`. Fallbacks: `AddCircle (1:ℚ)`, then a hand-rolled `Quotient` (~30 lines).
- **The `box` case of Lemma B** requires periodicity of *all* total histories, not just the one in play. *Mitigation*: Lemma A is a frame-level fact, so the hypothesis is available uniformly; state Lemma B with `τ` universally quantified inside the induction.
- **`temporal_duality` in S2** (F6). *Mitigation*: the symmetric arc; the mirror lemma is the designated escalation point (R5).
- **Irrationality plumbing**: `∀ q : ℚ, |(q:ℝ)| ≠ √2/4`. *Mitigation*: derive from `irrational_sqrt_two`; keep all cut reasoning in ℝ via casts and `exists_rat_btwn` rather than juggling `2q² ≠ 1` in ℚ.
- **Scope creep into `FrameClass`**: it is tempting to add a `FrameClass` element for the paper's TM⁺_c. *Mitigation*: out of scope; target `.Dense` (D7) and record the gap only.
- **Reviewer objection "the model is degenerate — it validates `Hψ → Gψ`"**: correct and harmless. Independence witnesses are routinely non-intended models; the model is a genuine `TaskFrame` satisfying all four paper axioms, and every base/dense axiom holds in it by `soundness_dense`. The report should state this explicitly in the module docstring so the point is pre-empted.

## Context Extension Recommendations

- **Topic**: independence/underivability proof technique in this tree.
- **Gap**: `not_derivable_nil_bot` is the only precedent and is undocumented as a pattern; three separate prose-only underivability claims exist (`LinearityDerivedFacts.lean`, `dense_indicator`'s conservativity note, the Layer 9 CO note) with no shared method.
- **Recommendation**: after R4 lands, add `.claude/context/project/lean4/patterns/independence-via-countermodel.md` recording the four-step recipe (concrete frame → truth-invariance lemma → axiom-set validity → `soundness_*` + `rintro ⟨d⟩`), and cross-link the three prose-only claims as candidates for the same treatment.

## Appendix — anchors and verbatim text relied on

- `def:temporal-order`: `A \textit{temporal order} is a nontrivial totally ordered abelian group $\D = \tuple{D, +, 0, \leq}$ with \textit{positive cone} $D^+ \coloneq \set{x \in D : x \geq 0}$.` — ℚ qualifies; nothing requires completeness of `D`.
- `def:frame#Spherical`: `\item[\it Spherical:] $\bigcap \mathcal{S} \neq \emptyset$ for any directed family $\mathcal{S}$ of nonempty fibers and segments.`
- `def:task-relation` (Fiber/Cone/Segment) and `def:directed` (`A nonempty family of sets $\mathcal{S}$ is \textit{directed} just in case $S \subseteq S_1 \cap S_2$ for some $S \in \mathcal{S}$ whenever $S_1, S_2 \in \mathcal{S}$.`) — both are conditions on subsets of `W`.
- `def:world-history` and its unlabelled non-example footnote (quoted in F1) — the paper's own `W`-side gap example.
- `def:BL-model`: `$\vert{p_i} \subseteq W$ for every sentence letter` — the valuation is state-indexed, which is what makes the periodicity argument reach atoms.
- `def:BL-semantics` (`$\Past$`/`$\Future$` clauses quantify over `$y \in D$`; `$\Box$` over `$H_{\F}$`) and `def:BLplus-semantics` (`$\since$`/`$\until$`, guard-first in the paper, event-first in the tree).
- `def:frame-validity` — the all-valuations quantifier that makes F3's impossibility argument go through.
- `CO` (`\aitem{CO}`, in `sub:Extension`) and `TMP-CO` (`\aitem[CO]{TMP-CO}`, in `def:TMplus-c`), both verbatim `$\always(\Past\varphi \rightarrow \future\Past\varphi) \rightarrow (\Past\varphi \rightarrow \Future\varphi)$.` — `TMP-CO` is the anchor for the Lean-facing claim.
- Lean anchors: `TaskFrame.lean:472` (structure), `Truth.lean:145` (`TruthAt`), `Derivation.lean:91` (`DerivationTree`), `Soundness.lean:1240` (`soundness_dense`), `Soundness.lean:1968` (`not_derivable_nil_bot`), `DedekindDerived.lean:396` (`co_derived`), `Formula.lean:488` (`Formula.co`), `Axioms.lean:399` (`Axiom.prior_U_gap`), `RegionFrame.lean:174` (deterministic-clock precedent).
