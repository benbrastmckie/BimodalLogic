# Phase 10a Complete Handoff — `vvecea2_collapse_bridge` landed sorry-free

**Dispatch:** lean-implementation-hard-agent, single-phase focus (Phase 10, hard mode).
**Status:** Phase 10a COMPLETE. The twice-blocked E[Σ] collapse seam is closed as a permitted
conditional orphan. Phase 10b NOT started (a separate large phase, blueprint below).

## What landed this dispatch

All in `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VVecEA2Collapse.lean`, on top of the 5
previously-landed lemmas (unchanged):

1. **`collapseEF`** (def) — the per-tuple endpoint-pinned `ExistsForallFormula sig F 2` for a
   `VecEA2 m` clause and a completion tuple `(τ_L, τ_R, g)`. Fields: `n := m+1`,
   `pin := fun i => if i.val = 0 then 0 else Fin.last (m+1)`,
   `pointType := Fin.cons τ_L (Fin.snoc g τ_R)`,
   `intervalType := Fin.cons intervalTop (Fin.snoc Ss intervalTop)`.
2. **`collapseEF_cap`** — `EndpointPinnedCapTrivial N (collapseEF …)`; the two vacuous caps close via
   `intervalHolds_intervalTop`.
3. **`collapseEF_translate`** — `translateProp42 atomMap h_surj (collapseEF Ss τ_L τ_R g)` reduces to
   the explicit completed `VecEA2` `⟨efPointTP τ_L, efPointTP τ_R, ⟨efPointTP∘g, efIntervalSetTP∘Ss⟩⟩`.
   This is the `Fin.cons`/`Fin.snoc` field reduction the prior handoff flagged as the MAIN RISK — it
   is plumbing, resolved.
4. **`vvecea2_collapse_bridge`** (the GOAL) — the top-level conditional biconditional threading
   `hCapture` at the `IntervalType` level. `choose cap hcap using hCapture`, per-clause
   `transL := (S_L ×ˢ S_R ×ˢ Fintype.piFinset Sp).toList.map (collapseEF Ss …)`, per-tuple
   correctness via `translateProp42_correct` + `collapseEF_translate` + `efPointTP_eval`, 3-way
   `∃`-distribution over the product, `bracket_completion_iff` on the bracket conjunct, `hcap` on the
   two endpoints, concluded through `vvecea2_collapse_of_perClauseList`.

## Verification (DoD met)

- `#print axioms vvecea2_collapse_bridge` = `[propext, Classical.choice, Quot.sound]` — no `sorryAx`.
- `collapseEF_cap`, `collapseEF_translate` axioms identical.
- Module builds green; **full `lake build` EXIT 0 at 1770 jobs** (baseline).
- `#print axioms Bimodal.Metalogic.BXCanonical.completeness_discrete` =
  `[propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]` —
  **byte-identical to baseline** (sole `sorryAx` = pre-existing `KampPrior.lean:562`, Phase 13).
- Off the live import path (grep-audit: no module imports `VVecEA2Collapse`).
- No new `sorry`, no vacuous defs, no new axioms.

## Key findings / deviations (carry forward)

- **List/flatMap vehicle confirmed correct.** The bridge composes through
  `vvecea2_collapse_of_perClauseList`, NOT the single-EF `vvecea2_collapse_of_perClause`: one
  `VecEA2` clause expands into a List of EFs over point completions (a captured truth set is a union
  of complete types). This is the verified plan correction from the prior dispatch, now realized.
- **`h_INF`/`h_SUP` are carried but UNUSED in 10a** (bound as `_h_INF`/`_h_SUP`). `hCapture` captures
  every engine-output formula directly, so the `negFix`/Lemma-5.3 middle-bracket readback the plan
  anticipated is not needed here. They remain in the signature for uniform threading to 10b.
- **`![...]` matrix notation is NOT available in this module** (`!` parses as Bool-not). Use
  `fun i => if i.val = 0 then … else …` for `pin` (as `translateProp42_backward` does), and
  `Fin.cons`/`Fin.snoc` for the tuple fields.
- **`Fin.cons`/`Fin.snoc` reduction recipe** (for reuse in 10b if EF construction recurs): unfold the
  structure with `simp only [collapseEF]` FIRST to expose the field (projections don't unfold against
  a metavariable-headed `Fin.cons`), then `Fin.cons_zero` / `← Fin.succ_last, Fin.cons_succ,
  Fin.snoc_last` / `⟨i.val+1,_⟩ = i.castSucc.succ` then `Fin.cons_succ, Fin.snoc_castSucc`. Ascribe
  raw `⟨i.val+1, by omega⟩` indices to the CONCRETE `Fin (m+2)`/`Fin (m+3)` so omega sees a concrete
  bound (it will not reduce the `(collapseEF …).n` projection). State the `Fin.last` reduction have
  about `Fin.last (collapseEF …).n` (projection form) so the final `simp only` matches the goal.

## Phase 10b blueprint (NOT started — next dispatch)

Target: `efSat_negation_general` (plan 11, lines 890-938), new file
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EFSatNegation.lean`. Signature threads
`atomMap / h_surj / h_INF / h_SUP / hCapture` and `{r} (ψ : ExistsForallFormula sig F r)`, returns
`∃ Φ : VeeExistsForall sig F r, ∀ env, StrictMono env → (¬ efSat N env ψ ↔ veeSat N env Φ)`.

Steps:
1. **LOCATE the De Morgan anchor first.** `augTarget_iff` did not surface by that exact name — grep
   `augTarget`, `pairProject`, `pairwiseProjections`, `existenceSentence`, `pairwiseProjections_sat`
   in `ExistsForallLemmas.lean` (landed Phase 5) and confirm the exact decomposition lemma and its
   statement before writing any code. The plan-09 blocked dispatch reportedly verified only the
   "sound half" of this De Morgan — treat this as the real work of 10b.
2. Per ordered pair `(k,l)`: `prop42_efSat_negation_general` (`Prop42NegationGeneral.lean`,
   `VVecEA2`-valued, gate `env 0 < env 1` — orientation forced by `StrictMono`), then **lift each
   `VVecEA2` to a `VeeExistsForall` disjunct via the now-landed `vvecea2_collapse_bridge`** (the step
   impossible before this dispatch).
3. Trichotomy lemma: `pin k ≠ pin l ⟹ env k ≠ env l`; `pin k = pin l` diagonal routes to the
   1-free-var **Prop 3.5 negation**, NOT the pair engine.
4. Negate the existence sentence (`r = 0`) via same engine + bridge at arity 0/1; flatten all
   `VeeExistsForall` disjuncts via `veeSat_append` (`VeeExistsForall.lean:72`).
5. `hCapture` threaded, NOT discharged (discharge is Phase 10P / ζ). Result is a conditional orphan
   off the live import path. DoD: sorry-free, axioms ⊆ `[propext, Classical.choice, Quot.sound]`,
   full `lake build` EXIT 0, `completeness_discrete` byte-identical.

## Reuse anchors (verified this dispatch)

- `vvecea2_collapse_bridge`, `collapseEF`, `collapseEF_cap`, `collapseEF_translate`,
  `vvecea2_collapse_of_perClauseList`, `bracket_completion_iff`, `intervalHolds_intervalTop`
  (`VVecEA2Collapse.lean`).
- `translateProp42` / `translateProp42_correct` / `EndpointPinnedCapTrivial`,
  `efPointTP_eval` / `efIntervalSetTP_eval` (`Prop42ExistsForall.lean`, `Prop35Assembly.lean`).
- `prop42_efSat_negation_general` (`Prop42NegationGeneral.lean`); `veeSat_append`
  (`VeeExistsForall.lean:72`); `pairProject` / `pairwiseProjections` (`ExistsForallLemmas.lean`).
- Faithfulness: Rabinovich 2014 Def 4.1 (PDF p.5-6) / Prop 4.2 / Prop 4.3 ¬-case. Companion `.md`
  corrupt — cite PDF page.
