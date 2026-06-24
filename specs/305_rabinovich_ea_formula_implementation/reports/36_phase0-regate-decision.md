# Report 36 — Phase 0 RE-GATE Decision (post strike-3)

- **Task**: 305 (rabinovich_ea_formula_implementation, lean4, hard mode)
- **Plan**: plans/35_zone-split-gated.md (§"Rollback/Contingency", §"Phase 0" re-gate note line 233)
- **Trigger**: Phase 1 leaf `merge_forward_succ` consumed its H6 3-strike budget with a conclusive
  negative verdict (handoffs/v35-phase-1-strike-3.md). Re-gate required.
- **Date**: 2026-06-24
- **Mode**: blocker-escalation research fork (orchestrator_mode=false, no `.lean` edits)

## (a) DECISION: **Route A′ (revised zone-split — discharge x=t IN SITU)**

Keep the 3-way zone split, but **delete the standalone `merge_forward_succ` obligation** and
discharge the x=t-zone collapse `(y,x,t) → (y,t)` *in situ* at the consumer
`KampPrior.lean:391` (the `match n with | 1 =>` arm of `nf_nvar_exist_all_depths`), where `sub_nf`
is the **model's characteristic NF** so the quant-merge-compatibility that the abstract leaf could
not assume holds **by construction**. Reuse the already-landed `mergeNF_succ` *definition* and
`mergeNF_succ_atom`; do NOT attempt a fourth merge-as-forward-lemma encoding.

**Route B (re-anchor through `US_expressively_complete_over_Z`) is REJECTED — and was already
rejected in the committed Phase-0 gate (v35-gate-decision.md, G1 = circular).** The strike-3 agent's
offhand "evidence favors B" remark is *not* supported once the binding circularity evidence is
re-examined (see (d)); it conflates "A hit a non-theorem at its first leaf" with "B became viable,"
but B's obstruction is structural and untouched by the strike-3 result.

### Why the strike-3 verdict supports A′ rather than overturning A

The strike-3 negative result is precisely a statement about the **abstract leaf**, not about the
in-situ collapse:

- **Obstruction 2 (the decisive one)**: the quant `←` direction
  `sub_nf.2 qnf = true → ∃ w, nf_eval_nf M k (n+3) (Fin.cons w full_val) qnf` is false **because,
  for an arbitrary `sub_nf`, no hypothesis forces `sub_nf.2` to be realized by the model `M`**
  (strike-3 handoff lines 54–63). At `KampPrior.lean:391`, `sub_nf : NormalForm sig (k+1) 2` is the
  characteristic NF of a concrete working structure `M : OrderedMonadicStructure sig` *with*
  `h_UZ : semantic_prior_UZ M atomMap`, `h_SZ`, and a concrete `t : M.carrier` in scope. There the
  `←` witness `w` is supplied by **the model itself** (the actual env value), exactly as depth-0
  `merge_forward` works with only `h_pred`/`h_ord`. The obstruction is dissolved, not worked around.

- **Obstruction 1 (bijectivity of the rename bridge)**: only bites the *standalone* lemma's attempt
  to relate a wide duplicating env to a narrow merged env via `renameNF`. In situ we never form the
  abstract bridge; we use the model's own env and the proven `mpr` half of `renameNF_eval_iff`
  (which needs only `r∘f = id`, which the merge HAS via `totalUnskip_skipFin`).

The plan **already anticipates this exact re-gate** (line 233: "Route A′ (discharge x=t in situ at
KampPrior:391 using the model's characteristic NF, NOT a standalone forward lemma) vs Route B").
A′ is the corroborated continuation, not a new approach, and does **not** reopen the FORBIDDEN
Approach-5 / mutual char-exist / k+2 NF-disjunction paths.

## (b) Line-count and risk estimate

| Item | Estimate |
|---|---|
| In-situ discharge of the n=1 arm at `KampPrior.lean:391` (3-zone assembly + wiring) | ~250–420 lines |
| New sorry-free obligation | clear `KampPrior.lean:391` (critical-path `sorryAx` source) |
| Reused landed assets (no new lines) | `mergeNF_succ`, `mergeNF_succ_atom`, `renameNF_eval_iff` (mpr), `totalUnskip(_skipFin)`, `char_k1`, `ih_exist_1` |
| Off-path `:394` (n≥2) | leave as documented dead sorry (Phase 4 verification-only; gate-decision bonus finding) |
| **Risk** | **MEDIUM** (building blocks all proven sorry-free; the make-or-break content shifts from "prove a non-theorem" to "assemble proven pieces where the compatibility is free by construction") |

This is consistent with the original blocker estimate (~250–400 lines) and is strictly *less* risky
than the abstract leaf, because the quant-compatibility that strike-3 proved impossible to assume is
now available from the model.

## (c) H3 reference-grounded mapping (sorry-free assets feeding Route A′)

| Asset (exact name) | Location | Role in A′ |
|---|---|---|
| `nf_nvar_exist_all_depths` (k+1, n=1 arm) | KampPrior.lean:387–391 | **Target**: the `sorry` at :391 to be discharged in situ |
| `char_k1` + `char_k1_correct` | KampPrior.lean:347–361 | Depth-(k+1) arity-1 characteristic formula (proven correct); base for zone formulas |
| `ih_exist_1` | KampPrior.lean:305–331 | Depth-k arity-2 existential `∃x, nf_eval_nf M k 2 (cons x …)` (proven); the quant-layer engine |
| `exist_tl_fn_k` + `exist_tl_fn_k_correct` | KampPrior.lean:334–344 | Choice-extracted depth-k arity-2 converter (proven) |
| `mergeNF_succ` | NfDepth0Generalized.lean:572 | Depth-(k+1) merge **definition** (arity n+2→n+1); the x=t zone collapse map |
| `mergeNF_succ_atom` | NfDepth0Generalized.lean:578 | Atom-layer correctness of the merge (`= [propext, Quot.sound]`) |
| `merge_forward` (depth 0) | NfDepth0Generalized.lean:180–293 | **Structural template** for the in-situ duplication argument (the true case at depth 0) |
| `mergeNF` (depth 0) | NfDepth0Generalized.lean:169 | Depth-0 merge map the atom layer reduces to |
| `renameNF_eval_iff` (mpr) | NfDepth0Generalized.lean:424 | Bijection-free half (needs only `r∘f=id`); env transport where needed |
| `totalUnskip`, `totalUnskip_skipFin` | NfDepth0Generalized.lean:158, 163 | The retraction `r` and `r∘f=id` proof the merge supplies |
| `insertEnv` identities (`insertEnv_zero`, the `Fin.cons` rewrite at :317–326) | KampPrior.lean | Env-reindexing glue for the zone assembly |
| `semantic_prior_UZ/SZ`, `prior_UZ_first_transition` | PriorDefs.lean:22; GoodStructuresModelSurgery.lean:116 | Model hypotheses in scope at :391 that supply the `←` witnesses (first-occurrence) |

## (d) H4 adversarial verification

**Chosen route A′ — single most likely failure mode (and why surmountable).**
*Failure mode*: assembling the 3-way zone disjunction (x<t / x=t / t<x) forces a **joint x–t
coupling** — the x=t zone must be glued to the strict-order zones so that the resulting temporal
formula's truth at `t` matches `∃ env : Fin 1, nf_eval_nf M (k+1) 2 (insertEnv env t) sub_nf`.
*Why surmountable*: (i) all three zone engines already exist sorry-free — `char_k1` for the
characteristic content, `ih_exist_1`/`exist_tl_fn_k` for the depth-k quant existential, and the
landed `mergeNF_succ`/`mergeNF_succ_atom` for the x=t collapse; (ii) the dissolved Obstruction 2
means the `←` direction's witness is the model's own carrier element (not synthesized from `Bool`
data), so the only remaining work is *temporal-formula plumbing* (Since/Until chaining over the
zones), which is the same shape as the already-working `nf_succ_char_formula` construction; (iii)
the coupling is bounded — `n = 1` is the only live arity (gate-decision bonus finding; `:394`
is dead), so there is exactly one binder to assemble, not an n-ary family.

**Rejected route B — why it is the strictly weaker choice.**
B's obstruction is **structural and fatal**, not tactical: `US_expressively_complete_over_Z`
(Theorem.lean:357) lives over `IntStructureFromSig sig` (concrete `Int` time, `Separation.int_truth`,
`atomMap : preds→Atom`), while the live call site
(`invariant_formula_constant` in `no_gaps_discrete_model_surgery`, GoodStructuresModelSurgery.lean
:1266–1269) holds an **arbitrary** `M : OrderedMonadicStructure sig` with `temporal_truth`. Bridging
the two requires transferring an arbitrary Prior-structure to a concrete `Int` model — which *is*
the content of `no_gaps_discrete_model_surgery`, the consumer B claims to bypass (**circular**). A
`grep` for any linking lemma (`US_expressively_complete_over_Z` ↔ `OrderedMonadicStructure`/
`temporal_truth`) returns only self-references in its own docstring: **no bridge exists**. The
strike-3 result does nothing to close this gap — it only shows A's *internal leaf decomposition* was
mis-scoped, which A′ fixes without touching B's circularity. Adversarially: any "B is now viable"
claim must produce the missing structure-transfer lemma; none exists and constructing it reproduces
the bypassed surgery. Verdict: **B remains non-viable (HIGH confidence), unchanged from Phase-0.**

## (e) Concrete step-by-step implementation sketch for Route A′

Target: discharge `KampPrior.lean:391` (the `| 1 =>` arm), producing a `Formula A` with
`temporal_truth M atomMap t A ↔ ∃ env : Fin 1 → M.carrier, nf_eval_nf M (k+1) 2 (insertEnv env t) sub_nf`.

1. **Reduce the n=1 existential to a single bound variable `x`.** Use the proven identity
   `insertEnv (fun _ => x) t = Fin.cons x (fun _ => t)` pattern (already established at
   KampPrior.lean:317–331 inside `ih_exist_1`) to rewrite the goal to
   `∃ x : M.carrier, nf_eval_nf M (k+1) 2 (Fin.cons x (insertEnv ∅ t)) sub_nf`, i.e. an
   existential over a single carrier element `x` relative to the anchor `t`.

2. **Trichotomy split on `x` vs `t`** (the 3-way zone split, now done *in situ*): the witness `x`
   satisfies exactly one of `x < t`, `x = t`, `t < x` in the ordered carrier. Build the formula `A`
   as a **disjunction** `A_lt ∨ A_eq ∨ A_gt` where each disjunct characterizes the existential
   restricted to that zone. Discreteness/order hypotheses come from the structure; first-occurrence
   witnesses from `prior_UZ_first_transition` (sorry-free).

3. **x = t zone (the collapsed binder — uses the landed merge).** When `x = t`, the arity-2 NF
   `sub_nf` evaluated at `(x, t) = (t, t)` collapses to the arity-1 merged NF `mergeNF_succ sub_nf …`.
   - Atom layer: discharged by `mergeNF_succ_atom` (proven).
   - Quant layer: discharged **in situ** by the duplication argument templated on depth-0
     `merge_forward` (NfDepth0Generalized.lean:180–293), but here `sub_nf` is the characteristic NF
     of `M`, so the `←` witness is the model's own value (Obstruction 2 dissolved). Where an env
     transport is needed, use the `mpr` half of `renameNF_eval_iff` (needs only `r∘f=id`, supplied by
     `totalUnskip_skipFin`).
   - Resulting formula for this zone: `char_k1 (mergeNF_succ sub_nf …)` (or the appropriate
     characteristic formula of the merged arity-1 NF), proven via `char_k1_correct`.

4. **x < t and t < x zones (strict-order endpoints).** Each is a depth-(k+1) arity-2 existential
   with `x` strictly ordered against `t`. Express via the depth-k arity-2 existential converter
   `exist_tl_fn_k`/`ih_exist_1` wrapped in a Since (`t < x` → future) / Until (`x < t` → past)
   chain — the same Since/Until plumbing already used by `nf_succ_char_formula`. The quant content is
   the proven `exist_tl_fn_k_correct`; only the temporal wrapper is new.

5. **Assemble and prove the iff.** Set `A := A_lt ∨ A_eq ∨ A_gt`. Forward (`→`): each disjunct's
   correctness lemma yields a witness `x` in its zone. Backward (`←`): given `env : Fin 1`, set
   `x := env 0`, trichotomy on `x` vs `t`, route to the matching disjunct. Discharge with the per-zone
   correctness lemmas from steps 3–4.

6. **Verify gates**: `lake build` GREEN (~1700 jobs); `lean_verify completeness_discrete` must lose
   nothing and ideally **drop `sorryAx`** once `:391` is sorry-free and `:394` is confirmed dead
   (off-path); axiom set otherwise unchanged; zero new top-level `axiom`. If `:391` clears,
   `completeness_discrete`'s only remaining sorry source is the dead `:394` arm — Phase 4 then
   confirms it is off-cone (gate-decision bonus finding) and the task reaches a sorry-free
   `completeness_discrete` modulo the documented dead arm.

**H6 guardrails honored**: A′ does not reopen Approach-5 / mutual char-exist / k+2 NF-disjunction;
it does not retry a standalone merge-forward encoding; it commits to a single live route (A′) with
B closed by the unchanged circularity evidence.

---

### Summary

**DECISION: Route A′ (revised zone-split).** Discharge the x=t collapse *in situ* at
`KampPrior.lean:391`, where `sub_nf` is the model's characteristic NF — which dissolves the exact
Obstruction-2 that made the standalone `merge_forward_succ` a non-theorem (the `←` witness now comes
from the model, not from arbitrary `Bool` data) — and reuse the already-landed `mergeNF_succ` /
`mergeNF_succ_atom` plus the proven `char_k1` / `ih_exist_1` engines. Route B (re-anchor through
`US_expressively_complete_over_Z`) stays **rejected**: its Phase-0 circularity (the Z→discrete bridge
*is* the `no_gaps_discrete_model_surgery` consumer it would bypass; no linking lemma exists between
`Separation.int_truth` and `temporal_truth`) is structural and untouched by the strike-3 result, so
the strike-3 agent's "favors B" aside does not survive H4 scrutiny. Estimated **~250–420 lines**,
**MEDIUM risk** (all sub-engines already proven sorry-free; remaining work is temporal-formula
assembly of proven pieces), clearing the critical `sorryAx` source `KampPrior.lean:391`.
