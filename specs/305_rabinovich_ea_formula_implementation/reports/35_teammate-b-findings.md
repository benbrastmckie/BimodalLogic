# Teammate B Findings — Alternative Routes for the n=1 Successor-Depth Sorry

- **Task**: 305 — rabinovich_ea_formula_implementation (faithful Kamp/Rabinovich)
- **Role**: Teammate B (Alternative Approaches) — complements Teammate A's deep-dive on the Approach-5 / `nf_succ_char_formula2` / mergeNF_succ path
- **Sole critical sorry**: `KampPrior.lean:391` (n=1 arm of `nf_nvar_exist_all_depths` at depth k+1). Build green otherwise (992 jobs; only sorry = line 252 def warning). Off-path sorry at 394 (n≥2).
- **Mode**: literature-guided (Rabinovich 2014 primary; Gabbay 1994 ch.9, Gabbay 1993 secondary). Research only — no source edits.

---

## Key Findings

1. **The recurring obstruction is specific to the NF-EVALUATION recursion, not to Kamp's theorem.** The codebase formalizes Rabinovich via a normal-form (`NormalForm sig k n`) whose *evaluation* `nf_eval_nf` recurses on depth `k`, with the quantifier layer at `k+1` referencing depth-`k` existentials at arity `n+2`. The n=1 case must bind one witness `x` (env : Fin 1) over an **arity-2** NF whose quantifier clauses are coupled depth-`k` **arity-3** existentials `∃ y, nf_eval M k 3 (y,x,t) qnf`. Every refuted approach (mutual char↔exist, k+2 NF-disjunction, arity-2 char helper) is a different way of building a *characteristic formula at a higher depth*, which is exactly what reintroduces the cycle.

2. **Rabinovich's own paper does NOT have this depth-gap.** Report 14 already identified this (§7): "Our depth-gap problem is an artifact of the NF-based formalization, not present in the EA-formula approach." Rabinovich never evaluates an NF recursively; he works at the **formula level** (Prop 4.3 structural induction over FOMLO; Prop 3.5 maps a *one-free-variable* V-EA formula straight to nested Until/Since). The coupling between the bound witness and the free point is handled by **interval decomposition into bracket formulas with `TemporalPred` labels**, then closure under `∃` (Lemma 3.4) — not by an arity-2 characteristic formula.

3. **Gabbay's Theorem 9.3.1 (separation ⇒ expressive completeness) gives a genuinely different induction organization that structurally cannot produce the self-reference.** It inducts on **quantifier depth m**, and at the `∃z ψ(t,z)` step it (a) fixes `t`, replacing `t<y / t=y / t>y` by three fresh *unary* predicates `R_<, R_=, R_>`; (b) pushes `t` out into a quantifier-free guard: `∃z ψ ≡ ⋁_j [α_j(t) ∧ ∃z ψ_j(z, R_·)]`; (c) applies the IH to each `ψ_j` — which is a formula in the **single free variable z** at quantifier depth **m** (strictly lower than m+1); (d) binds `z` with one "somewhere" operator `Q_∃ A = PA ∨ A ∨ FA`; (e) eliminates the auxiliary `R_·` atoms via **separation**. The IH is invoked at the *same free-arity (one variable)* and *lower quantifier depth* — never at a higher depth, never coupling a bound witness to a free point inside a characteristic formula. **This is the cleanest alternative organization.**

4. **The codebase already contains the sorry-free machinery for a depth-0, single-bound-witness, two-free-point case** (`VecEADecomp.nf_3var_*_correct`, 8 zone theorems + contradiction + tautology, all sorry-free). These characterize `∃ y, nf_eval M 0 3 (y,x,t) ssn` with y bound and *both* x,t free — the exact coupled shape — at depth 0. The obstruction is purely lifting this from depth 0 to depth k+1.

5. **`BracketFormula` / `VecEA_m` point and segment types are full `TemporalPred = ⟨Formula⟩`, not atoms.** (`VecEAFormula.lean:128–132`.) Consequently the **bidirectional, sorry-free single-witness binder `VecEA_m.existClosure` (+`_correct`/`_correct_rev`)** can absorb a witness whose conditions are *arbitrary temporal formulas* — including formulas that encode depth-`k` quantifier conditions. This is the most under-exploited asset for an alternative route (see Recommended Approach B1).

6. **`Nat.rec` depth-indexing is not the blocker.** Mathlib `Nat.rec`/`Nat.rec_add_one` exist and the current `nf_nvar_exist_all_depths` is *already* a depth-indexed (non-mutual) `Nat.rec`-style definition. The report-14 "Nat.rec constructive-eval" idea does not by itself resolve the n=1 case: report 14's own adversarial verification (Challenges 2, §5 DEFINITIVE CONCLUSION) showed the depth recursion **always bottoms out at d=0 needing the Prior axioms**, and the d=0 coupled-witness case is exactly what VecEADecomp already solves. So the depth-indexed approach reduces to "lift VecEADecomp's depth-0 zone result through the depth recursion," i.e. it is a *delivery mechanism* for Approach A/B, not an independent escape.

---

## Recommended Approach (ranked alternatives)

### A1 — Gabbay separation-style decoupling via auxiliary order-predicates (PRIMARY alternative)
**Idea**: Replace the "build an arity-2 characteristic formula in (x,t)" step with Gabbay 9.3.1's decoupling. For the n=1 goal `∃ x, nf_eval M (k+1) 2 (x,t) sub_nf`, treat `t` as fixed and introduce the three order-relations to `t` (`x<t`, `x=t`, `x>t`) as a 3-way **zone split on x** (exactly the split the depth-0 case `nf_2var_exist_depth0_tl` already performs via the order booleans `h_10/h_01`). Within each zone the bound witness `x` becomes a *one-free-variable* condition, and the depth-`k` quantifier clauses `∃ y, nf_eval M k 3 (y,x,t) qnf` are supplied by the IH **at arity reduced to one free variable** rather than via a higher-depth char.

**Why it avoids the cycle**: the IH is consumed at *lower depth, single free variable*, mirroring Gabbay's "ψ_j(z) at depth m." No characteristic formula at depth k+1 or k+2 is ever built. The t/x coupling is carried by the zone choice (the Lean analogue of `R_<, R_=, R_>`), which is *finite and decidable* (order booleans in the NF), so no separation theorem is needed at the Lean level — the zone is read off `sub_nf` and `qnf`'s order atoms (as `VecEADecomp` already does at depth 0).

**Key Lean signatures / step-to-literature map**:
| Step | Lean handle (existing, sorry-free unless noted) | Rabinovich/Gabbay correspondent |
|---|---|---|
| Decompose `nf_eval M (k+1) 2 (x,t)` into atom + quant layers | `nf_eval_nf` def (NormalForm.lean:198) | Def 3.1 |
| 3-way zone split on x relative to t | order booleans of `sub_nf` (cf. `nf_2var_exist_depth0_tl`, NfToVecEA.lean:702, `h_10/h_01` match) | Gabbay 9.3.1 `R_<,R_=,R_>`; Cor 9.3.3 `⋁(φ[<t]∧φ[t]∧φ[>t])` |
| Quant clause `∃ y, nf_eval M k 3 (y,x,t) qnf` as a condition in (x,t) | **IH `nf_nvar_exist_all_depths atomMap h_surj k 2 qnf`** (depth k, binds y AND x), reduced per-zone to one free var | Lemma 3.4 (∃-closure of V-EA); Prop 3.5 |
| Bind x via one "somewhere" operator within the zone | `nf_2var_exist_depth0_tl` pattern (`translateLeft`/`translateRight` = Until/Since chains) | Gabbay `Q_∃ = P∨·∨F`; Prop 3.5 nested U/S |
| Reassemble disjunction over zones | `formula_conjList` / `VVecEA_m.disj` (sorry-free) | Cor 9.3.3 `⋁_k` |

**Remaining obligation (honest)**: the *quant-layer bridge* — showing that, per zone, the IH at `(k,2)` (which binds **two** variables y,x leaving t free) telescopes with the outer single `∃x` correctly. This is the same `Fin`-telescoping obligation Teammate A's Approach 5 faces (Fin 2 vs Fin 1 `insertEnv` bridge), but A1 confines it inside each zone where x's order relative to t is *already decided*, which removes the unconstrained-coupling difficulty. The bridge lemma exists in-file at Fin 1 (KampPrior.lean:317–331).

**Confidence: MEDIUM-HIGH** that this avoids the cycle (Gabbay's organization provably has no higher-depth char step). **MEDIUM** on Lean effort: the per-zone IH-telescoping is the one real risk; ~200–350 lines. This is the alternative I most recommend the planner evaluate against Teammate A's path, because it removes the "characteristic-formula-at-higher-depth" object entirely rather than generalizing it (`nf_succ_char_formula2`).

### B1 — `existClosure` over `TemporalPred`-valued bracket formulas (SECONDARY alternative)
**Idea**: Exploit finding #5. Because `VecEA_m`/`BracketFormula` point and segment types are full `TemporalPred`, build the (x,t) condition as a `VecEA_m 2` whose endpoint type at the x-slot already *embeds* the depth-`k` quant conditions (supplied by the IH at `(k,2)` as a `Formula`, wrapped in `TemporalPred`), then bind x with the **already-proved bidirectional** `VecEA_m.existClosure` / `existClosure_correct(_rev)` (VecEA_m.lean:208/245/314).

**Why it avoids the cycle**: `existClosure` binds the *rightmost* free variable using only `bracketBuildRight` (a U-chain) over `TemporalPred` labels (VecEATranslation.lean:50/234, sorry-free). It never recurses on NF depth — the depth-`k` content is opaque inside the `TemporalPred`. So binding x introduces **no** new depth obligation.

**Key signatures / map**:
| Step | Lean handle | Correspondent |
|---|---|---|
| Wrap IH formula as endpoint `TemporalPred` | `⟨nf_nvar_exist_all_depths_fn … k 2 qnf⟩ : TemporalPred` | Lemma 3.4 |
| Assemble `VecEA_m 2` for the (x,t) pattern | `VecEA_m.conjStruct` / `VVecEA_m.conj` (sorry-free) | Def 3.1, Lemma 3.2.1 |
| Bind x (rightmost) | `VecEA_m.existClosure` + `existClosure_correct`/`_rev` (BOTH directions sorry-free) | Lemma 3.2.3 / 3.4 ∃-closure |
| `VecEA_m 2 → VecEA2` if needed | `VecEA_m.toVecEA2` + `_correct` (VecEA_m.lean:386/394) | — |

**Obligation/risk**: the bridge `nf_eval M (k+1) 2 (x,t) sub_nf ↔ (VecEA_m 2 with TemporalPred-embedded IH).holds` — i.e. proving that the assembled `VecEA_m` semantics matches the NF evaluation. `existClosure` requires `StrictMono env` (a 2-point monotone env); the t-slot/x-slot ordering must be fixed first, which folds B1 into A1's zone split for the `x<t` vs `x>t` orientations (existClosure binds rightmost, so the `x>t` zone is the natural fit; `x<t` needs the dual/left binder or env reorder). **Confidence: MEDIUM** it works; **the env-monotonicity + orientation handling is the friction.** ~250–400 lines. Strong point: the binder itself is *already fully proved both ways*, which neither A nor Teammate A's `nf_succ_char_formula2` can claim.

### B2 — Depth-0 zone result lifted via depth recursion (delivery variant, LOWER priority)
Report 14's "constructive eval by Nat.rec on depth." Per finding #6 and report 14's own §5 conclusion, this is not an independent escape: it bottoms out at the depth-0 coupled-witness case, which is exactly `VecEADecomp.nf_3var_*` (sorry-free). It would deliver A1/B1's content through an explicit `Nat.rec`. **Confidence: LOW as a distinct route** — recommend only as an *implementation tactic* inside A1, not as a separate plan.

### NOT recommended (literature/codebase-grounded refutations)
- **Full Gabbay separation theorem in Lean** (eliminate `R_<,R_=,R_>` via separation, Thm 9.3.1/9.3.4): faithful but enormous — separation is itself a deep theorem (Gabbay 1993 §6 axiomatisation). The Lean shortcut is the *finite decidable zone split* (A1), which captures the same decoupling without formalizing separation. Avoid the full theorem.
- **Gabbay 1993 gap machinery**: confirmed (§4, Lemma 2/Theorem 3 [GPSS]) that {U,S} expressive completeness holds over our Dedekind-complete/continuous Prior structures, so no extra connectives (`U',S'`, `7*`) are needed. The gap results are *not relevant* to Prior structures and would add irrelevant machinery.
- **Mutual char/exist** and **k+2 NF-disjunction**: independently re-refuted; both build a higher-depth characteristic formula (the cycle source). Consistent with report 18 §3/§6.

---

## Evidence / Examples

### Literature pointers
- **Rabinovich 2014** `specs/literature/sources/rabinovich_2014/…md`: Prop 3.5 (one-free-var V-EA → nested U/S, lines 87–94); Lemma 3.4 (∃-closure, line 84–85); §7 "depth-gap is an NF-artifact" (echoed in report 14 §7). Confirms the formula-level (not NF-eval-level) construction has no successor-depth char.
- **Gabbay 1994 ch.9** `…/gabbay_1994/ch902_93-separation-equals-expressive-complete.md`: Thm 9.3.1 proof (induction on quantifier depth m; `R_<,R_=,R_>` decoupling; `⋁_j[α_j(t)∧∃z ψ_j]`; `Q_∃`); Lemma 9.3.2 / Cor 9.3.3 (interval decomposition `⋁(φ[<t]∧φ[t]∧φ[>t])` — the zone split A1 uses). §9.4 `ch903` generalized separation. **This is the primary alternative organization.**
- **Gabbay 1993** `…/gabbay_1993/sec03_…md` §4: Theorem 3 [GPSS] {U,S,U',S'} complete over all linear time; Lemma 2: over isolated-gap flows {U,S} suffices ⇒ Kamp special case. Confirms {U,S} adequacy for Prior structures; gap connectives irrelevant here.

### Codebase reusable sorry-free assets (verified by read + grep; scoped build green)
- `VecEADecomp.lean` (898 lines, sorry-free in 106–897): `nf_3var_zone_{ytx,tyx,txy,xyt,yxt,xty}_correct`, `nf_3var_eq_{yt,yx}`, `nf_3var_order_contradiction`, `nf_3var_exist_depth0_characterization` (837). **The depth-0 coupled-witness (y bound; x,t free) solution.** Maps each zone to `VecEA2.holds` → U/S.
- `VecEA_m.lean`: `VecEA_m.existClosure` (208), `existClosure_correct` (245), `existClosure_correct_rev` (314) — **bidirectional single-witness binder, sorry-free**; `conjStruct`/`conj` closure; `toVecEA2` (386). `VecEAFormula.lean:128–132` — point/segment types are `TemporalPred` (full formulas), the key leverage for B1.
- `NfToVecEA.lean:702` `nf_2var_exist_depth0_tl` — sorry-free depth-0 arity-2 binder; the order-boolean `match` (710–729) is the concrete zone-split template A1 generalizes to depth k+1.
- `RabinovichTranslation.lean` / `ExistsForallNF.lean`: `translateEF1`(+`_correct`), `buildRight`/`buildLeft`, `ExistsForallSpec.translate_correct` (200) — Prop 3.5 realized, sorry-free; the U/S chain emitters A1/B1 reuse.
- `NegationIndep.lean`: `neg_2var_vec_ea_indep_correct` (319), `neg_vecEA2_indep_correct` (207), `neg_interval_formula_indep_correct` (90) — model-independent Prop 4.2 / Lemma 5.1 negation, sorry-free; available if an alternative needs negation closure.
- `NfDepth0Generalized.lean`: `nf_nvar_exist_depth0_tl` (1267) + `mergeNF`/`merge_forward` (157/168) — **the all-arity depth-0 converter is genuinely sorry-free** (the "sorry" at line 436 is a *stale comment*; no `sorry` token exists in the file — verified). This is the base case any depth-lift (B2) bottoms out on.
- Current state: `KampPrior.lean` builds green (992 jobs), single sorry at 391 (n=1), off-path sorry at 394 (n≥2); the n=0 arm (379–386) is sorry-free via `nf_succ_char_formula`/`char_k1`.

### Mathlib
- `Nat.rec`, `Nat.rec_add_one`, `Nat.rec_zero` (Mathlib.Data.Nat.Init), `Function.Iterate.rec`, `Primrec.nat_rec'` — depth-indexed recursion primitives. Confirm a non-mutual `Nat.rec` formula family is standard; but per finding #6 this is a delivery mechanism, not an independent fix. (No Mathlib "characteristic formula on inductive Formula" prior art found relevant; the construction is domain-specific and lives in this codebase.)

---

## Confidence Level per alternative

| Alternative | Avoids cycle? | Lean feasibility | Est. lines | Overall confidence |
|---|---|---|---|---|
| **A1 — Gabbay zone-decoupling (auxiliary order-preds as finite zone split)** | YES — provably no higher-depth char (different induction axis) | MEDIUM (per-zone IH telescoping is the risk; Fin-bridge exists at Fin 1) | 200–350 | **MEDIUM-HIGH** |
| **B1 — `existClosure` over `TemporalPred` bracket formulas** | YES — binder is depth-agnostic, depth-k content opaque in `TemporalPred` | MEDIUM (env StrictMono + x/t orientation friction) | 250–400 | **MEDIUM** (binder already proved both directions = strong) |
| B2 — depth-0 zone lifted via `Nat.rec` | YES but reduces to A1/B1 at base | MEDIUM | (delivery) | LOW as distinct route |
| Full separation theorem | YES | LOW (separation is its own deep theorem) | very high | NOT recommended |
| Gabbay-1993 gap connectives | N/A | N/A | — | NOT recommended (irrelevant to Prior/Dedekind-complete) |
| Mutual char/exist; k+2 NF-disjunction | NO (rebuild cycle) | — | — | REFUTED (consistent w/ report 18) |

**Bottom line for synthesis/planner**: the two live alternatives to Teammate A's `nf_succ_char_formula2` path are **A1** (replace the higher-depth characteristic object with a finite *zone split* + IH-at-lower-free-arity, mirroring Gabbay 9.3.1's decoupling) and **B1** (use the already-bidirectional `existClosure` binder over `TemporalPred`-valued brackets). Both eliminate the "characteristic-formula-at-higher-depth" object that has been the root of all 34 stalls, rather than generalizing it. A1 is the strongest faithful-to-literature alternative; B1 has the unique advantage that its binder correctness is already fully proved. The shared residual risk across A1, B1, and Teammate A's path is the same `Fin`-telescoping of the inner `∃y` and outer `∃x` against the IH at `(k,2)` — A1 mitigates it by fixing the x–t order per zone before binding.
