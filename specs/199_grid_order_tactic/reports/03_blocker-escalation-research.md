# Blocker Escalation Research: Task 199 Grid Order Tactic

**Date**: 2026-07-26
**Session**: sess_1785105935_852a79
**Blocker investigated**: "b_resp vs p_n ordering unprovable from current hypotheses"

## Verdict (summary)

The blocker is **obsolete, not underivable and not a unification bug**. The goals it referred to
no longer exist. `ghr93_case_II` was restructured on 2026-05-28 — two days after this task's last
dispatch — and is now fully proved, sorry-free, and axiom-clean. Every deliverable in this task's
charter is moot.

**Recommendation: (c) abandon as superseded.**

## 1. Root Cause

### 1.1 The original diagnosis was correct at the time

The prior analysis (`reports/02_blocker-analysis.md:33`) claimed the `fan_order` formulation is
provably false, with counterexample `p=0, a=1, b=2, q=0, a'=2, b'=1`. **I verified this
independently**: all six hypotheses hold (`p≤a`, `p≤b`, `q≤a'`, `q≤b'`, and both ordering
conjunctions evaluate to `True ↔ True` / `False ↔ False`), while the conclusion
`(a < b ↔ a' < b')` evaluates to `True ↔ False`. So `fan_order` as stated is refutable, and the
"genuine proof gap" call was sound *given the proof structure that existed then*.

The structural reason was real: no hypothesis in scope related `b_resp` and `p_n` directly
(`reports/02_blocker-analysis.md:84`). `b_resp` came from the tau game, `p_n` from the backward
chain, `e_n` from the big game, and no single game contained both `b_resp` and `p_n`. A fan
(`d ≤ b_resp`, `d ≤ p_n`) carries strictly less information than the linear chain
`pivot_chain_order'` needs, and no abstract order-theoretic lemma can bridge that.

### 1.2 What changed

The prior analysis recommended exactly the right fix and predicted it would require proof-level
restructuring rather than tactic work
(`reports/02_blocker-analysis.md:98-117`, options A and C: obtain an *additional game challenge*
so that one game's own `same_order_type` supplies the missing ordering;
`reports/02_blocker-analysis.md:127`: "this should be escalated as a blocked task requiring
mathematical insight into the proof strategy").

That restructuring was subsequently implemented. `ghr93_case_II` now sub-splits Case B on
`b_sp` vs `e_n` (`CaseAnalysis.lean:1805`):

```lean
rcases le_or_gt (extendPoint (sig := sig) (atomMap := atomMap) (r := r) b_sp) e_n with hbe | heb
```

and each branch obtains the `b_resp`/`p_n` ordering **directly from a game**, dissolving the fan:

| Sub-case | Condition | Construction | Ordering obtained | Consumed at |
|----------|-----------|--------------|-------------------|-------------|
| B1 | `b_sp ≤ e_n` | `hwin_left` challenged with `b_sp` (`CaseAnalysis.lean:1809`) | `tau_b_pn` (`:1817`) | `full_b_sel` k=n, `:1916` |
| B2 | `b_sp > e_n` | a *second* tau game, `tau_right` instantiated with all-`p_n` selections (`:1987-1988`), challenged with `b_sp` (`:1989`) | `tau_pn_b` (`:1995`) | `full_b_sel` k=n, `:2104` |

The B2 construction is the decisive one and is precisely option A/C from the prior report:

```lean
obtain ⟨_resp_right_dummy, _, hwin_right⟩ := tau_right
  (fun _ : Fin n => extendPoint p_n) (fun _ => ⟨le_refl _, h_pn_le_y'⟩)   -- :1987-1988
obtain ⟨b_resp, hb_resp_in_R, hcond_right_b⟩ := hwin_right b_sp hb_sp_ey  -- :1989
...
have tau_pn_b : (extendPoint p_n < extendPoint b_resp ↔ e_n < extendPoint b_sp) ∧
                (extendPoint p_n = extendPoint b_resp ↔ e_n = extendPoint b_sp) := by
  have h := hord_right_b ⟨0, by omega⟩ ⟨n + 1, by omega⟩                  -- :2002
  simp_game_tuple at h; exact h
```

Because the selections of that second game are *all* `p_n`, index 0 of its tuple **is** `p_n` and
index `n+1` **is** `b_resp` — so the game's own `same_order_type` yields the ordering as a
first-class hypothesis. No fan, no `fan_order`, no `pivot_chain_order'` on a non-chain.

The old proof was deleted outright — `CaseAnalysis.lean:2163` reads
`/- OLD CASE II PROOF DELETED. See git history for reference. -/`.

### 1.3 Provenance

| Commit | Date | Effect |
|--------|------|--------|
| `79cf48a7f` | 2026-05-26 | This task's last work: closed Goal 3 (sel vs p_n) |
| `5e3d66037` | 2026-05-28 | Restructured Case II with the tau_left/tau_right sub-split |
| `d9f4a33cc` | (after) | Closed the grid dispatch sorries in Cases A, B1, B2 |

The restructuring landed two days after this task's final dispatch and superseded it. This task
has been stale for roughly two months.

## 2. Missing Lemma

Not applicable. The historically-missing fact was an ordering hypothesis directly relating `p_n`
and `b_resp`; it is now supplied by construction at `CaseAnalysis.lean:1817` and `:1995` rather
than by any lemma. No new lemma is needed, and `fan_order` must never be added — it is false.

## 3. Minimum Viable Outcome

No documented `sorry` is needed, because none remains.

Verified state of `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean`:

- **File length**: 2,165 lines (was ~3,000 at the time of the original research).
- **`sorry` tactics**: zero. The single grep hit at `:438` is the word "sorry" inside a comment,
  not a tactic.
- **Build**: `lake build Bimodal.Metalogic.WeakCanonical.Expressiveness.CaseAnalysis` completes
  successfully (1,049 jobs, exit 0).
- **Axioms**: `lean_verify` on `Bimodal.Metalogic.WeakCanonical.ghr93_case_II` returns
  `{propext, Classical.choice, Quot.sound}` with no warnings — no `sorryAx`.
- **`ghr93_case_II` is live**, not dead code: consumed at
  `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean:864`.

Symbols the charter depends on, in the current tree:

| Symbol | Occurrences | Note |
|--------|-------------|------|
| `hab_eq` | 0 | The rewrite whose failure was Goal 3/5's cause — gone entirely |
| `pn_sel_ord` | 0 | Gone |
| `sel_pn_ord` | 1 | Comment only (`:1602`), no longer a `have`-bound obligation |
| `fan_order` | 0 | Never added (correctly — it is false) |
| `grid_order_tac` | 0 | **Never created anywhere in the repository** |

## 4. Verdict on Task Viability

**Recommendation: (c) abandon as superseded.**

Both charter deliverables are moot:

1. *"Create a bespoke `grid_order_tac` tactic that automates the `same_order_type` grid dispatch
   in `ghr93_case_II`"* — that dispatch no longer exists. The restructured proof discharges
   `same_order_type` through the `same_order_type_of_cases` helper
   (`CaseAnalysis.lean:1744`, `:1933`, `:2113`) fed by explicit `full_x_sel` / `full_b_sel` /
   `full_y_sel` / `full_sel_sel` families, not by a `split_ifs` grid needing ~25 goals dispatched.
   There is nothing left for the tactic to automate.

2. *"Apply it to replace the two sorry fallbacks in `ghr93_case_II`"* — there are zero sorries in
   the file, and the theorem is axiom-clean.

Re-scoping to option (b) ("tactic closes the 23 tractable goals, 2 documented sorries remain") is
not available either: there are no remaining goals of any tractability to close.

Pursuing option (a) would mean building automation for a proof shape that has been deleted.

### Bearing on the bespoke-tactic cost question

This task is worth preserving as evidence, and the evidence is sharper than "a bespoke tactic got
stuck." The sequence was: research proposed a helper lemma (`fan_order`); the lemma turned out to
be **mathematically false**; three of six goals were closable by direct impossible-direction
proofs; and the two genuinely blocked goals were resolved not by any tactic but by **restructuring
the surrounding proof so the needed fact became a hypothesis**. The tactic was never written. The
lesson is that the grid goals were a symptom of a proof organized so that necessary orderings were
not in scope — automation would have been the wrong instrument even had it worked.

## 5. Adjacent Observation (out of scope, recorded not acted on)

`same_order_type_grid` and `same_order_type_grid_uh` (`Automation/EFGameTactics.lean:297`, `:315`)
now have **no call sites anywhere** in `Theories/` or `Tests/` outside their own defining file.
They are dead automation and are a cleanup candidate for whoever owns `EFGameTactics.lean`. This
is noted only; it is not part of this task and I made no change.

## Verification Method

- Counterexample re-checked by direct evaluation, not taken from the prior report.
- All structural claims are grounded in file:line references read from the current tree.
- Build and axiom status established by running `lake build` on the module and `lean_verify` on
  the theorem, not inferred.
- Supersession established from `git log -S` on the relevant source strings.
