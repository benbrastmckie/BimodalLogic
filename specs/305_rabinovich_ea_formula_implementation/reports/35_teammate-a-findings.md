# Task 305 — Teammate A (Primary Angle): The n=1 Obstruction and a Proof Skeleton

- **Task**: 305 — rabinovich_ea_formula_implementation
- **Type**: lean4
- **Agent**: lean-research-hard-agent (H2+H3+H4+H5)
- **Tier**: 1 (literature-backed: Rabinovich 2014, lean4 strict)
- **Artifact**: 35 (teammate-a)
- **Scope**: mathematical/proof-engineering core of the n=1 blocker. NOT file
  organization (Teammate D).

---

## 0. Executive Summary (the one thing that changed)

The recurring blocker is **not** a circularity and **not** an unsolved problem. It is a
**mis-factored helper**. Every prior dispatch (incl. report 18's Approach 5) tried to build a
single temporal `Formula` that "characterises the pair (x,t)" — `nf_succ_char_formula2`. That is
**genuinely impossible** and the latest handoff correctly diagnosed why: *a temporal `Formula` is
evaluated at one point*, so it cannot have a free `x` slot. Report 18 is therefore wrong on its
central recommendation (it proposes exactly the impossible artifact at §4.1, lines 208–217).

**The decisive observation: the depth-0 solution that already works (`nf_2var_exist_depth0_tl`,
`nf_nvar_exist_depth0_tl`) ALSO never builds a pair-characterising formula.** It does the only
thing a one-point logic can do — it **splits on the zone of `x` relative to `t`** (`x<t`, `x=t`,
`t<x`) and inside each zone uses Until/Since, which reach *other* points from `t`. This is exactly
Rabinovich's interval-decomposition (Prop 3.5 / §5). The correct factoring of the n=1 case is to
**lift that zone-split machinery one depth**, not to invent `char2`.

Concretely, the n=1 arm should be built as a **3-way zone disjunction** (future / equal / past),
where each zone's existential `∃x` is discharged by an `Until`/`Since` formula whose interval and
endpoint predicates are themselves depth-(k+1) characteristic formulas supplied by the **already
sorry-free `nf_characterizable_temporal_prior`** plus the in-scope **arity-3 depth-k IH**. No
formula ever needs two free points.

| Claim | Confidence |
|---|---|
| The blocker is a one-point-evaluation factoring error, not a cycle | HIGH |
| `nf_succ_char_formula2` (pair-characterising formula) is impossible and must be abandoned | HIGH |
| Depth-0 already solves the coupled case via zone-split + rank + `translateEF1` | HIGH |
| The lift uses `nf_characterizable_temporal_prior` (sorry-free) + arity-3 IH, no depth k+2 | HIGH |
| The proposed skeleton's hardest piece is the "equal-zone" merge lift (`mergeNF_succ`) | MEDIUM |
| Whole n=1 arm is closable sorry-free with the skeleton below | MEDIUM |

---

## 1. Ground-Truth State (verified, not from stale reports)

Build: `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior` → **exit 0, GREEN**. Live
sorries (full grep of `Theories/.../Kamp` + `EFGames` + `WeakCanonical`, comments excluded):

| # | File:Line | On critical path? | Statement |
|---|-----------|:---:|-----------|
| 1 | `KampPrior.lean:391` | **YES** | `nf_nvar_exist_all_depths` k+1, **n=1** arm |
| 2 | `KampPrior.lean:394` | No | same def, n≥2 arm (main theorem needs n=0,1 only) |

**Stale-report correction (important).** Report 24 says the sole critical sorry is
`nf_characterizable_temporal_prior` (succ) at `KampPrior.lean:158`. That is **out of date**. The
restructure since then made `nf_characterizable_temporal_prior` **sorry-free** (KampPrior.lean
~438–518): its succ arm now calls `nf_nvar_exist_all_depths_fn atomMap h_surj k 1` and bridges
`insertEnv (fun _ => x) t = Fin.cons x (fun _ => t)`. The sorry **moved down** into the n=1 arm of
`nf_nvar_exist_all_depths`. So the critical chain today is:

```
kamp_prior_expressive_completeness
  → nf_characterizable_temporal_prior            (SORRY-FREE now)
      → nf_nvar_exist_all_depths_fn k 1          (= the n=1 case)
          → KampPrior.lean:391  ◄── THE sorry
```

Also verified: the depth-0 `mergeNF`/`merge_forward` machinery is **fully sorry-free**. The
"`sorry`" at `NfDepth0Generalized.lean:436` is **inside a comment block** ("For now, we handle
this with a sorry…"); the actual merge proof at lines 472–585 is complete in both the drop-i and
drop-j branches, and the incompatible branch (586–639) and the strict-total-order branch (640+)
are complete. There is **no live sorry in NfDepth0Generalized.lean**. (This contradicts the
literal grep hit and matters: the depth-0 zone/merge template we want to lift is real and proven.)

### 1.1 The exact n=1 goal (from the def type at the `| 1` arm)

```
∃ (A : Formula), ∀ (M) (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
  (t : M.carrier),
  temporal_truth M atomMap t A
    ↔ ∃ env : Fin 1 → M.carrier, nf_eval_nf M (k+1) 2 (insertEnv env t) sub_nf
```

Since `env : Fin 1`, `insertEnv env t = Fin.cons (env 0) (fun _ => t)` (proved twice in-file,
317–331 and 489–513). Writing `x := env 0`, the RHS is:

```
∃ x, nf_eval_nf M (k+1) 2 (Fin.cons x (fun _ => t)) sub_nf
```

Unfolding `nf_eval_nf` at depth `k+1`, arity `2` (NormalForm.lean:203–207):

```
∃ x,  ( ∀ a : AtomKind sig 2, atom_eval M (x,t) a ↔ sub_nf.1 a = true )           -- (A) atom layer
   ∧  ( ∀ qnf : NormalForm sig k 3,                                               -- (Q) quant layer
          (∃ y, nf_eval_nf M k 3 (Fin.cons y (x,t)) qnf) ↔ sub_nf.2 qnf = true )
```

**This is where everything has gone wrong.** Both prior camps tried to first build a formula `B`
"such that `B` characterises the pair (x,t)" — i.e. `B(x,t) = (A)(x,t) ∧ (Q)(x,t)` — and then
`∃x B`. But `B(x,t)` would need to be true *at a configuration of two points*; a temporal
`Formula` only knows about `t`. There is no `nf_succ_char_formula2`.

---

## 2. Why depth 0 works and what that tells us (the real lever)

The depth-0 arity-2 converter `nf_2var_exist_depth0_tl` (NfToVecEA.lean:702–765) **does not build
a pair formula**. It pattern-matches on the two order booleans of `sub_nf` (i.e. it pre-commits to
the zone of `x` vs `t`) and returns:

- **`t < x` (order 1→0 true):** `(nf_vecEA2_future …).translateLeft` — an **Until**-direction
  formula at `t`. Captures `∃ x>t, …` by looking into `t`'s future. (lines 720–724)
- **`x < t`:** `(nf_vecEA2_past …).translateRight` — a **Since**-direction formula at `t`. (725–729)
- **`x = t`:** `Formula.and (nfPred … (nf_x_proj' sub_nf)) (nfPred … (nf_t_proj sub_nf))` —
  the atoms-at-x conjoined with atoms-at-t, **both evaluated at the single point `t`** because
  `x=t`. (730–764)
- **both orders true:** `Formula.bot` (impossible). (712–719)

The "INDEPENDENT x-/t-projections" the task prompt names live in the **equal zone only**
(`reconstruct_nf_depth0`, NfToVecEA.lean ~387–428): a depth-0 pair NF factors as
`nf_x_proj'` (atoms at position 0) + `nf_t_proj` (atoms at position 1) + the two order booleans.
Atoms at distinct positions are logically independent, so the factoring holds. **The factoring is
not what makes depth 0 work in the `x≠t` zones** — there the work is done by `translateLeft`/
`translateRight` (Until/Since), i.e. Prop 3.5.

The genuinely-coupled, arbitrary-arity version `nf_nvar_exist_depth0_tl_succ`
(NfDepth0Generalized.lean:390+) confirms the recipe at scale. It case-splits:
1. **pair cycle** (a<b ∧ b<a both true) → `Formula.bot`;
2. **NF-equal pair** (both order bools false ⇒ forced equal) → **merge** via `mergeNF`/
   `merge_forward` and recurse with one fewer witness (this is the equal-zone, lifted to arity);
3. **strict total order** → build `nf_rank` (sort the witnesses into a line) and apply
   `translateEF1` (Rabinovich Prop 3.5: ordered points ↦ nested Until/Since). (640+)

**Punchline:** even the coupled multi-witness case is handled with **zero pair formulas** — by
(a) collapsing forced-equal positions (merge) and (b) linearly ordering the rest and applying
the interval-to-U/S map. This is precisely Rabinovich §3/§5. The task's claim that "the technique
does not transfer because the quant clause couples x with t" is **half right**: the *equal-zone
independent-projection* technique does not transfer, but the *zone-split + Until/Since* technique
(the actual engine) does, because it never needed independence in the first place.

---

## 3. What Rabinovich actually does at successor depth (paper, §3 + §5)

Read `~/Projects/Literature/sources/rabinovich_2014/…md` (full). Key points for the n=1 question:

- **There is no "depth k+1 single-witness existential characteristic formula" in the paper.**
  Rabinovich never inducts on quantifier depth. He has exactly two inductions (confirmed §4–§5):
  **(i) induction on n = number of witnesses** (Lemma 5.3, Lemma 5.1), and **(ii) structural
  induction on the FO formula** (Prop 4.3). Quantifier depth is *not* a recursion parameter.
- **`∃x φ` is handled by Lemma 3.4** ("the set of V-∃∀ formulas is closed under … existential
  quantification"), §3 line 85. The closure is *not* "evaluate a 2-point formula"; it is the
  interval-pattern manipulation of Def 3.1 / Prop 3.5.
- **Inserting a new point z into an interval `(z_0,z_1)`** (§5, "Key Insights" §2 lines 213–219):
  the interval type `[α_0,…,α_n](z_0,z_1)` **splits** into a left sub-interval type
  `A_i^-(z_0,z)` and a right sub-interval type `A_i^+(z,z_1)`. The constraint is *which i* the new
  point sits at. This is the formal content of "the bound point couples the two endpoints" — and
  Rabinovich's answer is **split at the point and recurse on each side**, never characterise both
  sides at once with one formula.
- **Dedekind/INF used in exactly one place** (eq 5.2, "Key Insights" §3 line 222): pinning
  `r_0 = inf{z | P(z)}`. The repo encodes this as `prior_hasAttainedINF` + `inf_bracket_formula`
  (both sorry-free per report 24 table). It is **not** needed for the single-witness n=1 case in
  the strict-order zones; it is only needed if a segment type fails inside an interval.

**Conclusion for the Lean encoding:** the apparent self-reference (`exist(k+1,1)` needing
`char(k+2)`) is *purely* an artifact of the NF-by-depth encoding chosen in the Lean port. The
paper's argument has no depth recursion at all. The Lean encoding can mirror the paper by making
the n=1 arm a **zone disjunction whose pieces are depth-(k+1) characteristic formulas of the
*projections/sub-intervals*** — all of which are available without going to depth k+2 (§4 below).

---

## 4. Recommended Approach: the n=1 arm as a zone disjunction (proof skeleton)

**Do not build `nf_succ_char_formula2`.** Mirror `nf_2var_exist_depth0_tl` one depth up. The n=1
goal `∃ x, nf_eval_nf M (k+1) 2 (x,t) sub_nf` is the disjunction over the three mutually-exclusive
zones of `x` vs `t`, each captured by a one-point formula at `t`:

```
A := zoneEqual  ∨  zoneFuture (t<x)  ∨  zonePast (x<t)
```

The order booleans of `sub_nf` are **fixed by `sub_nf`** (they are atoms of the arity-2 NF), so
exactly one zone is feasible — just as in the depth-0 match (NfToVecEA.lean:710–711). So `A` is in
practice a `match` on `sub_nf (.order 0 1)`, `sub_nf (.order 1 0)`, not a literal 3-way `or`.

### 4.0 Two reusable sub-pieces (proved sorry-free already)

| Piece | Lean identifier | Status |
|---|---|---|
| depth-(k+1) arity-1 char of a single point | `nf_characterizable_temporal_prior` | **sorry-free** (KampPrior:~438) |
| depth-k arity-3 existential over `(y, x, t)` | IH `nf_nvar_exist_all_depths atomMap h_surj k 2` | in scope on the k+1 arm |
| order-zone Until builder (Prop 3.5) | `translateEF1` / `translateEF1_correct` | sorry-free (Translation.lean:243) |
| atoms-at-position predicate | `nfPredAtPos` / `nfPredAtPos_correct`, `nfPred` | sorry-free (NfDepth0Generalized:62, NfToVecEA:62) |
| quant clause (±existential) | `nf_quant_clause_tl` / `_correct` | sorry-free (KampPrior:78) |

The IH at `(k,2)` is **strictly smaller in depth** (`k < k+1`); the equation compiler's IH on the
`k+1` arm covers all arities at depth `k`. Its type (verified):

```
nf_nvar_exist_all_depths atomMap h_surj k 2 qnf
  : ∃ A, … temporal_truth M t A ↔ ∃ env : Fin 2, nf_eval_nf M k 3 (insertEnv env t) qnf
```

i.e. it binds **two** witnesses `(env 0, env 1)` over a depth-k arity-3 NF, leaving `t` free.

### 4.1 Helper H1 — depth-(k+1) "atoms+quant at a single labelled point"

The atom layer (A) and quant layer (Q) of `nf_eval_nf M (k+1) 2 (x,t)` each *restricted to one
position* is exactly a depth-(k+1) arity-1 evaluation at that position. Define the two single-point
projections of an arity-2 depth-(k+1) NF and characterise them with the **existing** sorry-free
`nf_characterizable_temporal_prior`.

```lean
-- projection of an arity-2 depth-(k+1) NF onto position `pos`, as an arity-1 depth-(k+1) NF
noncomputable def nfProjSucc {sig} {k}
    (sub_nf : NormalForm sig (k+1) 2) (pos : Fin 2) : NormalForm sig (k+1) 1
-- (atom_assgn restricted to `pos`; quant_assgn pushed through the arity drop)
```

Risk: **MEDIUM** — the quant component of an arity-2 NF ranges over `NormalForm sig k 3`, and
projecting to arity-1 must map those to `NormalForm sig k 2` coherently with `nf_eval_nf`. This is
the arity-drop analogue of `mergeNF` but at depth k+1 and is the **one nontrivial new definition**.
This is where Teammate D's "should mergeNF be generalised to depth k" question lands; see §5.

### 4.2 Helper H2 — equal zone (`x = t`)

When the NF forces `x = t` (both order bools false), `nf_eval_nf M (k+1) 2 (t,t) sub_nf` must be
characterised at the single point `t`. This is the **depth-(k+1) lift of `reconstruct_nf_depth0`'s
equal case** and the lift of `mergeNF`/`merge_forward`. Skeleton:

```lean
-- `mergeNF_succ`: drop a forced-equal position from a depth-(k+1) arity-2 NF → arity-1
noncomputable def mergeNF_succ {sig} {k}
    (sub_nf : NormalForm sig (k+1) 2) (j : Fin 2) : NormalForm sig (k+1) 1

theorem mergeNF_succ_equal_correct {sig} {k}
    (atomMap) (h_surj) (sub_nf : NormalForm sig (k+1) 2)
    (h_eq_forced : sub_nf.1 (.order 0 1 _) = false ∧ sub_nf.1 (.order 1 0 _) = false)
    (M) (h_UZ) (h_SZ) (t) :
    (∃ x, x = t ∧ nf_eval_nf M (k+1) 2 (Fin.cons x (fun _ => t)) sub_nf)
      ↔ nf_eval_nf M (k+1) 1 (fun _ => t) (mergeNF_succ sub_nf 0)
```

Then the equal-zone formula is `nf_characterizable_temporal_prior … (mergeNF_succ sub_nf 0)`.

Risk: **MEDIUM-HIGH.** The depth-0 `merge_forward` proof (NfDepth0Generalized:472–585) is ~110
lines and only handles the **atom/order** layer. At depth k+1 the merge must *also* show the
**quant layers agree** when positions 0 and 1 collapse — i.e. for every `qnf : NF k 3`, the
existential `∃y, nf_eval k 3 (y,t,t) qnf` matches the merged `∃y, nf_eval k 2 (y,t) (mergeNF qnf)`.
This needs the **depth-k `mergeNF` already proven** (it is) applied *inside* the quant layer, plus
the recursion that the collapse commutes with `Fin.cons y`. This is the single largest proof
obligation and the place a residual sorry is most likely to survive a first pass.

### 4.3 Helper H3 — strict zones (`t < x` and `x < t`)

When the NF fixes a strict order, build an Until (future) / Since (past) formula via `translateEF1`
whose **interval predicate** is the depth-(k+1) characteristic formula of `t` (= `nfProjSucc sub_nf
1` characterised by `nf_characterizable_temporal_prior`) and whose **target predicate** is the
depth-(k+1) characteristic formula of `x` (= `nfProjSucc sub_nf 0` characterised likewise),
*conjoined with the quant-coupling clauses*. The quant clauses that genuinely couple `x` and `t`
are discharged by the **arity-3 IH**: for each `qnf : NF k 3`, `nf_quant_clause_tl (existIH qnf)
(sub_nf.2 qnf)` where `existIH qnf` is the formula from `nf_nvar_exist_all_depths_fn k 2 qnf`,
**evaluated at `t`**, asserting `∃ (y,x'), nf_eval k 3 (y,x',t) qnf`. The Until quantifies `x`;
the `x'` of the IH is unified with the Until-witness via the standard `Fin.cons`/`insertEnv` bridge
(lines 489–513 generalised from `Fin 1` to `Fin 2`).

```lean
-- zone formula for t < x (Until direction); symmetric def for x < t (Since)
noncomputable def nf_succ_exist_future {sig} {k}
    (atomMap) (h_surj)
    (charPoint : NormalForm sig (k+1) 1 → Formula)             -- = nf_characterizable_temporal_prior
    (existIH3 : NormalForm sig k 3 → Formula)                  -- = nf_nvar_exist_all_depths_fn k 2
    (sub_nf : NormalForm sig (k+1) 2) : Formula
-- built from translateEF1 over (charPoint (nfProjSucc sub_nf 0)) as target,
-- (charPoint (nfProjSucc sub_nf 1)) as the present, and the conjoined quant clauses.
```

Risk: **MEDIUM.** `translateEF1` is sorry-free and is *exactly* Prop 3.5; the depth-0 future/past
proofs (`nf_vecEA2_future_correct` etc.) are the template. The new content is conjoining the
arity-3-IH quant clauses and threading the Until-witness through the `insertEnv` bridge.

### 4.4 Top-level wiring (replaces the `| 1 => sorry` at KampPrior.lean:391)

```lean
| 1 =>
  -- order bools fixed by sub_nf, exactly like NfToVecEA.lean:710-711
  let existIH3 := nf_nvar_exist_all_depths_fn atomMap h_surj k 2          -- depth-k arity-3 IH
  let charPoint := fun nf' => (nf_characterizable_temporal_prior atomMap h_surj (k+1) nf').1
  match h10 : sub_nf.1 (.order 1 0 _), h01 : sub_nf.1 (.order 0 1 _) with
  | true,  true  => ⟨Formula.bot, …⟩                                       -- impossible
  | true,  false => ⟨nf_succ_exist_future …, …⟩                            -- t < x
  | false, true  => ⟨nf_succ_exist_past   …, …⟩                            -- x < t
  | false, false => ⟨charPoint (mergeNF_succ sub_nf 0), …⟩                 -- x = t  (H2)
```

### 4.5 Dependency order (build incrementally; each step keeps the build green)

1. `nfProjSucc` + `nfProjSucc_correct` (H1) — pure NF surgery, no temporal logic. **Lowest risk.**
2. `mergeNF_succ` + `mergeNF_succ_equal_correct` (H2) — lifts depth-0 merge through the quant
   layer using the existing depth-k `mergeNF`. **Highest risk; do second so failure is isolated.**
3. `nf_succ_exist_future` / `_past` + correctness (H3) — `translateEF1` + arity-3 IH. **Medium.**
4. Wire the `| 1` arm (§4.4). Scoped build; sorry count drops 2 → 1 (only n≥2 off-path).
5. (Optional, off-path) n≥2 arm by the arity-general version of H1–H3 + depth-k `mergeNF`.

Estimated 350–550 lines. The bulk and the risk are concentrated in step 2 (H2).

---

## 5. Direct answer to the prompt's factoring question

**"Is generalising `mergeNF`/`merge_forward` to depth k (`mergeNF_succ`) plus deriving depth-(k+1)
zone endpoints from `char_k1` + the arity-3 IH the right factoring?"** — **Yes, with a
correction:**

- `mergeNF_succ` is the **right** name for the **equal zone only** (H2). It is *not* a generic
  replacement for the depth-0 `mergeNF`; the depth-0 `mergeNF` stays and is **reused inside**
  `mergeNF_succ`'s quant-layer obligation. So you need *both* the existing depth-0 `mergeNF` (kept)
  *and* a new depth-(k+1) `mergeNF_succ` (equal zone). They are not the same lemma.
- "zone endpoints from `char_k1`": almost. The endpoints come from the single-point projections
  `nfProjSucc sub_nf {0,1}` characterised by `nf_characterizable_temporal_prior` (which is exactly
  what the file calls `char_k1`, KampPrior.lean:347, and which is sorry-free). Confirmed available.
- The arity-3 IH (`nf_nvar_exist_all_depths k 2`) supplies the **coupling** quant clauses for the
  strict zones, where independence genuinely fails. Confirmed in scope and strictly smaller depth.

**The single change vs. report 18:** abandon `nf_succ_char_formula2` (a one-formula pair
characteriser — impossible). Replace it with the **zone-split** structure (`nfProjSucc` + zone
formulas), which is the faithful depth-lift of `nf_2var_exist_depth0_tl` and of Rabinovich §3/§5.

---

## 6. H3 Reference-Grounding Table (5-column)

| Rabinovich concept | Paper location | Lean identifier | Type signature (verified) | Status |
|---|---|---|---|---|
| ∃∀ normal form (interval decomposition) | Def 3.1 | `NormalForm sig k n` | `0,n↦AtomKind→Bool`; `k+1,n↦(AtomKind→Bool)×(NF k (n+1)→Bool)` | sorry-free (NormalForm.lean:134) |
| NF satisfaction | Def 3.1 sem. | `nf_eval_nf` | `M→(k n)→(Fin n→carr)→NF k n→Prop`; k+1 = atom-layer ∧ quant-layer | sorry-free (NormalForm.lean:198) |
| Prop 3.5: ordered points ↦ U/S | Prop 3.5 §3 | `translateEF1`/`_correct` | interval pattern ↦ Until/Since chain at t | sorry-free (Translation.lean:243) |
| Lemma 3.4: ∃-closure of V-∃∀ | §3 line 85 | (engine = zone-split, not a single lemma) | — | realised via zone disjunction |
| Insert point ⇒ split `A_i^-`,`A_i^+` | §5 lines 168–171, "Key Insights" 213–219 | `nfProjSucc` (NEW) + zone formulas | `NF (k+1) 2 → Fin 2 → NF (k+1) 1` | **MISSING — H1** |
| Forced-equal collapse (merge) depth 0 | (interval merge) | `mergeNF`/`merge_forward` | `NF 0 (m+1)→Fin (m+1)→NF 0 m`; forward biconditional proven | sorry-free (NfDepth0Generalized:157/168) |
| Forced-equal collapse depth k+1 | (interval merge, lifted) | `mergeNF_succ` (NEW) | `NF (k+1) 2 → Fin 2 → NF (k+1) 1` | **MISSING — H2 (highest risk)** |
| depth-(k+1) arity-1 single-point char | (construction) | `nf_characterizable_temporal_prior` | `NF (k+1) 1 → {A // temporal_truth t A ↔ nf_eval (k+1) 1 (fun _⇒t)}` | **sorry-free** (KampPrior:~438) |
| depth-k arity-3 ∃ over (y,x,t) (the IH) | (coupling) | `nf_nvar_exist_all_depths k 2` | `NF k 3 → ∃A, … ↔ ∃env:Fin 2, nf_eval k 3 (insertEnv env t)` | in scope (k strictly smaller) |
| depth-0 arity-2 ∃ (zone template) | Prop 3.5 base | `nf_2var_exist_depth0_tl` | match on 2 order bools → bot / translateLeft / translateRight / atom-conj | sorry-free (NfToVecEA:702) |
| depth-0 arity-n ∃ (coupled template) | §5 | `nf_nvar_exist_depth0_tl`(`_succ`) | pair-cycle/merge/rank+translateEF1 | sorry-free (NfDepth0Generalized:1267/390) |
| quant clause (±∃) | (construction) | `nf_quant_clause_tl`/`_correct` | `Formula→Bool→Formula`; `… ↔ (P ↔ is_pos)` | sorry-free (KampPrior:78) |
| atoms at position | (construction) | `nfPredAtPos`/`_correct`, `nfPred` | `NF 0 arity → Fin arity → TemporalPred` | sorry-free (NfDepth0Generalized:62) |
| INF / Dedekind (only if segment fails) | eq 5.2 §5 | `inf_bracket_formula`, `prior_hasAttainedINF` | first-occurrence bracket; Prior ⇒ HasAttainedINF | sorry-free (per report 24 §4) — **not needed for n=1 strict zones** |
| Thm 4.4 (target) | §4 line 112 | `kamp_prior_expressive_completeness` | every `MonadicFormula sig 1` ⇒ equivalent `Formula` on Prior | depends only on sorry #1 (KampPrior:391) |

---

## 7. H4 Adversarial Self-Verification

**Challenge 1 — "Is `nf_succ_char_formula2` (report 18's recommendation) really impossible?"**
A temporal `Formula`'s truth is `temporal_truth M atomMap t A` — a predicate of the **single**
point `t` (and the model). To "characterise the pair (x,t)" the formula would need `x` as a second
free index; there is no such slot. Report 18 §4.1 (lines 220–224) writes the spec *with x already
existentially bound* ("AFTER binding x via existClosure"), which silently concedes the formula
cannot mention a free x — and then §4.3 proposes building `char2` "in the pair (x,t)" anyway. That
is the contradiction the latest handoff caught. **VERIFIED impossible as a free-x formula.
Confidence: HIGH.** (This is why every Approach-5 dispatch "could not separate helper from
wiring": the helper it wanted doesn't typecheck against `temporal_truth`.)

**Challenge 2 — "Does the zone-split actually avoid the impossible artifact?"** Each zone formula
is evaluated at `t` only: equal-zone is `charPoint (mergeNF_succ sub_nf 0)` (a single point);
strict zones are `translateEF1`-built Until/Since at `t`. The bound `x` appears **only** as the
Until/Since witness (a runtime ∃ inside the semantics), never as a formula index. This is exactly
how the sorry-free depth-0 case is typed (NfToVecEA:702–765). **VERIFIED. Confidence: HIGH.**

**Challenge 3 — "Could `mergeNF_succ` (H2) be vacuous or false?"** Not vacuous: its correctness
statement (§4.2) has real content — it equates a depth-(k+1) arity-2 evaluation at `(t,t)` with a
depth-(k+1) arity-1 evaluation. Could it be **false**? The danger is the quant layer: collapsing
positions 0,1 must preserve every `∃y` clause. This is true **iff** the depth-0 `mergeNF` applied
inside each `qnf : NF k 3` commutes with `Fin.cons y` — which is a theorem about the *existing*
sorry-free `mergeNF`, so it is provable, but the commutation proof is the **main residual risk**.
**PARTIALLY VERIFIED. Confidence: MEDIUM.** I did not construct the commutation proof; I confirmed
its ingredients (depth-0 `mergeNF` proven; `Fin.cons`/`insertEnv` lemmas present) exist.

**Challenge 4 — "Is the arity-3 IH genuinely in scope and strictly smaller?"** The def recurses by
the equation compiler on `k` (arms `| 0` and `| k+1`, KampPrior.lean:264/268). On the `k+1` arm,
`nf_nvar_exist_all_depths atomMap h_surj k 2` is a call at depth `k < k+1`, any arity — accepted.
Verified by reading the existing in-arm call at line 313 (`… k 1 …`) which already exercises the
IH at a smaller depth. **VERIFIED. Confidence: HIGH.**

**Challenge 5 — "Is `nf_characterizable_temporal_prior` truly sorry-free now (not begging the
question)?"** Read KampPrior.lean ~438–518: the succ arm builds `exist_tl_fn :=
nf_nvar_exist_all_depths_fn k 1` and applies `nf_succ_char_formula_correct`. It depends on the
**n=1** case of `nf_nvar_exist_all_depths` — i.e. on the very sorry we are filling. So
`nf_characterizable_temporal_prior` is sorry-free **as written** but **sorry-tainted via
`sorryAx`** until line 391 is closed. Using it as a *building block for the (k+1)-point char* is
**not circular** because at the (k+1) arm we need the **(k+1) char**, which `nf_characterizable_
temporal_prior atomMap h_surj (k+1)` provides directly — its succ arm uses `exist k 1`, the n=1
case at depth **k+1's predecessor = k**? No: caution — it would use `exist (k) 1` for the *depth-
(k+1)* char, and we are *inside* building `exist (k+1) 1`. **This is a real subtlety.** Using
`nf_characterizable_temporal_prior (k+1)` inside the `exist (k+1) 1` construction would invoke
`exist k 1` (smaller depth, fine) — **no cycle**, because the (k+1)-point char only ever needs the
depth-k existential, not the depth-(k+1) one. **VERIFIED acyclic. Confidence: MEDIUM-HIGH** (the
indices must be checked carefully at implementation time; the zone endpoints need the
**single-point** (k+1) char, whose dependency is `exist k 1`, strictly below us).

**Challenge 6 — "Could the whole skeleton be non-terminating?"** The only recursion is the
equation-compiler recursion of `nf_nvar_exist_all_depths` on `k`. Every helper (H1/H2/H3) is
**non-recursive** in `k` (H1 is NF surgery; H2 uses the *already-defined* depth-0 `mergeNF`; H3
uses `translateEF1` and the *passed-in* IH value). No helper calls back into `exist (k+1) 1`. So
the call graph has a single decreasing edge `k+1 → k`. **VERIFIED terminating. Confidence: HIGH.**
(Contrast report 18 §3, which correctly refuted the *mutual* `char/exist` def; our skeleton is not
mutual.)

**Forbidden-output check (H2 contract):** no "mathlib likely has this"; every identifier verified
by `grep`/Read against source + one scoped `lake build` (exit 0). No `sorry`/axiom deferral
recommended — the recommendation is a concrete sorry-free skeleton. No `simp`/`omega` proposed to
bypass a literature step; the literature step (Prop 3.5 interval ↦ U/S) is realised faithfully via
`translateEF1`. **Clean.**

---

## 8. H5 Divergence Audit (brief — `focus_prompt` did not request "divergence"/"audit")

Root cause of 34 plan versions on one sorry: **a typing error treated as a math problem.** Two
families of dispatches alternated:
1. **NF-depth family** (current): kept reaching for `nf_succ_char_formula2` / k+2 NF-disjunction →
   recreated an apparent cycle. Failure reason: the desired helper (pair-characterising `Formula`)
   does not typecheck against `temporal_truth` (one-point). 
2. **VVecEA2/bracket family** (reports 23/24, EANegation/EndpointNegation): pursued Rabinovich
   §5 negation closure directly; stalled on `neg_partialBracketExist_is_vbracket` and
   `neg_vecEA2_is_vvecEA2`. Now off the active critical path (the code reverted to the NF-depth
   tower; `nf_characterizable_temporal_prior` is the live spine).

The cheapest convergence is **not** to finish the bracket family (800–1200 lines, two open
sorries) but to fill the *one* NF-depth sorry with the zone-split skeleton (§4), reusing the
already-proven depth-0 zone/merge/rank machinery. Corrected lean-ready targets: `nfProjSucc`,
`mergeNF_succ`, `nf_succ_exist_future`/`_past` (exact signatures in §4).

---

## 9. Confidence Summary (per claim)

| Claim | Confidence | Basis |
|---|---|---|
| Blocker is a one-point-formula factoring error, not a cycle | HIGH | `temporal_truth` type + report-18 self-contradiction |
| `nf_succ_char_formula2` must be abandoned | HIGH | typing impossibility (Challenge 1) |
| `nf_characterizable_temporal_prior` is the live spine, KampPrior:391 is THE sorry | HIGH | source read + scoped build |
| depth-0 zone/merge/rank machinery is sorry-free and is the lift template | HIGH | full grep + read of NfDepth0Generalized 390–760 |
| Zone-split skeleton (§4) avoids the impossible artifact | HIGH | each zone formula is one-point (Challenge 2) |
| arity-3 IH in scope + strictly smaller depth | HIGH | equation-compiler arms + existing in-arm call line 313 |
| Skeleton terminates, non-mutual | HIGH | single `k+1→k` edge (Challenge 6) |
| `mergeNF_succ` quant-layer commutation provable | MEDIUM | ingredients exist; commutation proof not constructed |
| Using (k+1)-point char inside is acyclic | MEDIUM-HIGH | dependency is `exist k 1`, below us (Challenge 5) |
| 350–550 line estimate | MEDIUM | depth-0 templates: merge ≈110 lines, zones ≈80 each |
| Whole n=1 arm closable sorry-free first pass | MEDIUM | H2 is the make-or-break |
