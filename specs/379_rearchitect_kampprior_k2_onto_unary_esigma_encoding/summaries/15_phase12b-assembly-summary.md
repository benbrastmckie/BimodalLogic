# Phase 12b (δ ex/all closure, ASSEMBLY) — Execution Summary

**Task**: 379 · **Phase**: 12b assembly · **Agent**: lean-implementation-hard-agent · **Status**: PARTIAL
**Build**: `lake build` EXIT 0 @1770 jobs · **Spine**: `completeness_discrete` axiom set unchanged

## What was delivered

Landed the two structural preconditions the prior dispatch named as its residual, plus the gap
eval-bridge — all axiom-clean (`[propext, Classical.choice, Quot.sound]`) and off the live import
path, across 4 green incremental commits (12b.4–12b.7):

| Landed | What | Role |
|---|---|---|
| WF-`size` restructure | `translate_correct` from `induction φ` → `match m, φ` + `termination_by φ.size` + `decreasing_by` | The recursion now fires on the size-smaller, **non-structural** `α.subst0 i` (ties) and `α.rename (insertPerm p)` (gaps). Prior handoff's #1 blocker item, discharged. |
| `insertPerm` | `Equiv.Perm (Fin (m+1))` (0↦p, j+1↦p.succAbove j) via `Equiv.ofBijective` + `Fin.cons_injective_iff`; `insertPerm_zero`/`insertPerm_succ` | The concrete insertion permutation the prior handoff named as a needed last piece. |
| `insertNth_comp_insertPerm`, `cons_comp_insertPerm_symm` | `insertNth p x env ∘ insertPerm p = cons x env` and its `.symm` restatement | Front↔sorted insertion composition identities. |
| `eval_insertNth_rename` | `eval M (insertNth p x env) (α.rename (insertPerm p)) = eval M (cons x env) α` | Gap eval-bridge: moves a gap witness onto the strict-mono sorted chain without changing the eval value. |

The 4 landed δ cases (atom/lt/and/not) were preserved verbatim under the new scaffold; `not`/`and`
IH references were replaced by size-decreasing recursive `translate_correct` calls.

## What remains (the residual strategic sorries)

`translate_correct` still carries its two tracked strategic sorries (`all` :439, `ex` :448). The
residual is the **disjunction assembly**, and the single IRREDUCIBLE open sub-step is the
**forward direction of the gap disjuncts**:

- `veeSat_exists`/`dropPin` produce `∃ a, veeSat N (Fin.insertNth p a env) Ψ_p` **unconditionally**,
  but the recursive translation `Ψ_p ⇒ eval` only under `StrictMono (insertNth p a env)` (i.e. `a`
  genuinely in gap `p`).
- Whether a gap disjunct over-accepts a non-gap witness reduces to ONE question: **does
  `translate`'s output (the `veeSat_negation` branch, for `α` with negations) pin the environment
  at monotone ranks in its `∃∀` internal chain?** If yes → the strict-mono chain forces `a` into
  gap `p` and the current construction closes as-is; if no → each gap disjunct needs an explicit
  `lt`-skeleton order-constraint conjunct (via `veeConj`, before `dropPin`, boundary gaps handled).
- The **tie disjuncts are already clean** (`eval_subst0` gives an exact iff at arity `m`, no
  strict-mono guard). The `all` case is blocked purely on the `ex` closure (`all = ¬∃¬` reuses it).

Recommended next action: a short focused inspection of the `veeSat_negation` /
`efSat_negation_general` pin structure to pick the branch, then the tie/gap disjunction assembly.

## Why deferred (bounded-attempt discipline)

The full disjunction assembly (~250 lines: indexed-family extraction over `Fin m`/`Fin (m+1)`,
list concatenation, two-direction iff, plus the possible order-constraint machinery) hinges on the
unresolved monotone-pinning question — report 14's flagged UNVERIFIED / Medium-risk crux. With the
target's churn counter at 2/3 and recovery discipline forbidding reverting landed work, gambling a
large assembly excursion into RED was not the responsible outcome. The restructure + insertPerm +
bridges were landed and committed incrementally; the residual is narrowed to the exact sub-step
above and handed off precisely.

## Verification

- `sorry_count` = 2 (both tracked strategic, off live path, lines 439/448) · `vacuous_count` = 0 ·
  `axiom_count_new` = 0
- Full `lake build` EXIT 0 @1770 jobs (baseline)
- `completeness_discrete` axioms byte-identical to baseline
  `[propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]`; sole
  on-path `sorryAx` remains `KampPrior.lean:562` (Phase 13)
- Import audit: no module imports `Prop43Translate` (off live path)
- New lemmas verified axiom-clean via `lean_verify`

## Plan deviations

None from the assembly mandate. Landed the WF restructure and `insertPerm` exactly as the prior
handoff's next-action prescribed; the assembly step was deferred (not altered/substituted) per the
bounded-attempt clause. `StrictMono` gate not dropped; BLOCKED `Prop43.lean` not revived; Phase 13 /
`KampPrior:562` untouched; `hCapture`/`hne` threaded, never discharged.
