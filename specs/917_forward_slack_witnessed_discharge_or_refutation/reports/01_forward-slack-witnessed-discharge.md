# Research Report: ForwardSlackWitnessed — discharge or refutation

**Task**: 917 - Discharge `ForwardSlackWitnessed` under `ParamsOk`, or compile a refutation
**Started**: 2026-11-11T04:22:20Z
**Completed**: 2026-11-11T05:05:00Z
**Effort**: ~45 min (research only)
**Dependencies**: None blocking. Sibling: the antitone slice of the collision dichotomy (already landed in the tree, see Finding 1).
**Sources/Inputs**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` (schemas, `ForwardSlackWitnessed`)
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` (`HasForwardSlack`, its entry/transport lemmas, the spaced type pigeonhole)
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` (region rigidity, the window dichotomy, pin compatibility, the type-locality lemmas, `CellLEZeroConstOfKappaEq`)
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderPump.lean` (the deletion/splice primitives and their type lemmas)
- `FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean` (`ParamsOk`, `kappa`, `cascadeBound`, `tShort`, `tIdle`, `objCycleLens`)
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` (the recorded refutation of the idle-run-lengthening route)
- Four standalone probe lemmas compiled in-session via `lean_run_code` against the project's own oleans (reproduced verbatim below)
- Literature: not consulted. No literature source is referenced by this task, and the obstruction located here is internal to this formalization's own counter layer. (The corpus entry nearest in kind is `hodkinson_wolter_zakharyaschev_2000`, whose Lemma 17 the deletion type lemma already cites; it supplies no counterpart to the pin layer, which is where this task's obstruction sits.)
**Artifacts**:
- `specs/917_forward_slack_witnessed_discharge_or_refutation/reports/01_forward-slack-witnessed-discharge.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **VERDICT, stated and not tacit: `ForwardSlackWitnessed` is NEITHER DISCHARGED NOR REFUTED by
  this research phase.** Neither admissible outcome the dispatch names was reached, and this
  report claims neither. What it does deliver is a *compiled reduction* that turns the hypothesis
  from an opaque existential over paths into a condition on the OBJECT WALK alone, plus the exact
  location of the one obstruction that blocks both outcomes.
- **THE REDUCTION (compiled).** `HasForwardSlack g z l n` is EXACTLY a bound on the countdown of
  the first region start above `z`'s region: `cntAt` at that region start `≤ n + cntAt g z + I - l`,
  where `I` is the length of the intervening idle run. One direction is the landed
  `hasForwardSlack_of_next_region_cnt_le`; the converse is compiled in this session
  (`next_region_cnt_le_of_hasForwardSlack`, Probe 2). Since the countdown is rigid on the walk
  (`cntAt_eq_of_obj_eq`) and the stab-free realized type is a function of the walk
  (`tpOf_stabFree_eq_of_objAt_eq`), `ForwardSlackWitnessed` says: *every stab-free type realized at
  the state is realized by a walk whose next region is short enough.*
- **AT THE SCHEMAS' OWN INSTANTIATION the condition simplifies and loses `l` entirely.** The
  schemas ask for witnessing at the HIGHER pair, countdown `c + m·(P+1)`, register `n`, amount
  `l = m·(P+1)`. The required bound is then `K ≤ n + c + I` — the LOWER pair's own Lipschitz
  allowance. The hypothesis is precisely: *the register, read at the pin, must not spend the extra
  `m·(P+1)` of room the higher countdown provides.*
- **THE DISCHARGE ROUTE IS IDENTIFIED AND IS SIZED BY `ParamsOk` ITSELF.** Normalize the next
  region by excising type-respecting blocks (`exists_typeBlock_of_spacing` at the next region's
  start, `tpOf_eq_delIdx_of_tpOf_eq` for type preservation) until its countdown is below
  `tShort = Fintype.card (ProdState Q φ)`. Then (K3)'s `2·tShort + tIdle + 2 ≤ Tc ≤ c ≤ n + c + I`
  closes the bound with room to spare. (K3)'s short-region clause appears to have been sized for
  exactly this consumer.
- **THE ONE OBSTRUCTION, located precisely: the FORWARD PIN CASCADE.** The landed deletion
  `exists_deleted_ladderPath_of_pend_past` requires `hpast` — pending at every position at or below
  the deletion point — and that is unavailable inside the NEXT region, because the intervening idle
  run sits below it. Worse than a missing hypothesis: the deletion leaves the intervening pin in
  place while displacing every later pin by `-l`, so pin compatibility
  (`pinCompat_of_ladderPath`: `|K_{j+1} − K_j| ≤ distance`) can FAIL, in a window of width `2l`.
  The governing recurrence is `K_{j+1} ≤ 2·K_j + I + 1` — which is literally (K2)'s
  `cascadeBound = 2 ^ tShort * (tIdle + 2)`, the `iter_doubling` recurrence. So the obstruction and
  its budget are both already named in `ParamsOk`; what is missing is the lemma that spends the
  budget.
- **THE REFUTATION ROUTE IS BLOCKED BY A COMPILED FACT.** The natural refutation — an object whose
  region lengths are bounded, forcing the register to climb maximally — is unavailable:
  `fwd` seriality forces every pending state to have a PENDING successor (Probe 3,
  `pend_succ_of_fwd`), so the pending subgraph of any admissible object has out-degree ≥ 1
  everywhere and (on a finite object with a pending state) contains a cycle. Region lengths are
  therefore unbounded in every admissible object, and `objCycleLens` is never empty in the regime,
  so (K1)'s divisibility always bites.
- **SCOPE CORRECTION, load-bearing: discharging `ForwardSlackWitnessed` would NOT land
  `cellLE_zero_const_of_kappa_eq`.** The reserved schema quantifies over EVERY `kappa`-collision.
  Every landed inclusion carries the pending-forever gap `n + 2 ≤ c`, which by
  `pend_past_of_nxtAt_lt` is not a mild side condition but a restriction to paths pending at EVERY
  earlier position (the forward-only-liveness regime). The complementary window regime `c ≤ n + 1`
  — the ordinary one — is covered by no landed inclusion in either direction. The room bounds
  remain as well. See the `user_decision` on `.return-meta.json`.

## Context & Scope

Researched: whether `ForwardSlackWitnessed`
(`LadderCell.lean`, the `def` in `section ForwardSlack`) is derivable from `ParamsOk`, and if not,
what a refutation would have to exhibit.

Constraints honored: no library file was edited; the four probe lemmas were compiled as standalone
snippets through `lean_run_code` and are reproduced here as text, not landed. No sorry, no axiom,
no vacuous definition is proposed anywhere in this report. The forbidden
"use `sorry` and revisit" shape does not appear: where this report cannot settle a question it
says so and routes the work, which is the sanctioned alternative.

Evidence tier: lean-lsp was registered and reachable for the whole session; every `lean_run_code`
result below is a real elaboration against the project's own oleans
(`{"success": true, "diagnostics": []}`). No `lake build` was run — none was needed, since nothing
was written into the library. Blocked tools (`lean_diagnostic_messages`, `lean_file_outline`) were
not called.

## Findings

### Codebase Patterns

**Finding 1 — the starting position, re-verified, with two corrections to the dispatch.**

Verified as stated:

- `cellLE_zero_const_of_kappa_eq` has NO declaration site anywhere under `FormalSystem/`. The
  schema `CellLEZeroConstOfKappaEq` exists as a `def` at `LadderAgree.lean:3326` and is claimed by
  nothing.
- Every landed depth-`0` cell-equality schema carries `ForwardSlackWitnessed` as a hypothesis a
  consumer must supply, and nothing in the tree discharges it.
- `ForwardSlackWitnessed` is existential over paths, which is why
  `ClimbWitness.hasForwardSlack_refuted_unconditional` (which refutes the per-path *state-level*
  regime at amount `1`) does not touch it.

Corrected:

1. **FIVE schemas are landed, not three.** `cellLE_zero_const_of_kappa_eq_of_forwardSlack`
   (equal register), `..._commonShift_of_forwardSlack`, `..._monotone_of_forwardSlack`,
   `..._antitone_of_forwardSlack`, and `..._antitone_bounded_of_forwardSlack`. The antitone pair
   landed since the dispatch's starting position was written; `LadderCell.lean`'s own module
   docstring already records the dichotomy `kappa_collision_monotone_or_antitone_named` as CLOSED
   over the saturated branch. The dispatch's SCOPE note ("the antitone slice belongs to a sibling")
   is therefore satisfied already, and this task's target is the hypothesis alone — as its title
   says.
2. **The stated payoff does not follow.** See Finding 5.

**Finding 2 — THE REDUCTION: `HasForwardSlack` is a condition on the object walk.**

The counter layer forces this. Three landed facts:

- `cntAt_sub_of_pend` + `not_pend_of_count`: inside a pending region the countdown is the distance
  to the region's last pending position, and the region's first idle position sits at distance
  exactly `cntAt + 1`. So a region's length is its start countdown plus one — the countdown is read
  off the walk, not chosen.
- `cntAt_eq_of_obj_eq`: two ladder paths with the same object walk carry the same countdown
  everywhere. ("The countdown is read off the walk — a replacement argument that changes a countdown
  MUST change the walk.")
- `cntAt_eq_nxtAt_of_idle_pend`: at an idle→pending transition the new region's countdown IS the
  register's value at the idle position.

Composing them: the register value `HasForwardSlack` constrains — `nxtAt g (z + cntAt g z + I)` —
is not free data. It equals the countdown of the first region start above `z`'s region, which
equals that region's length minus one. The regime is therefore equivalent to a bound on that one
number. The `⇐` direction is landed (`hasForwardSlack_of_next_region_cnt_le`); the `⇒` direction is
Probe 2 below.

Consequence, with `tpOf_stabFree_eq_of_objAt_eq` (the stab-free realized type is a function of the
object walk): **`ForwardSlackWitnessed step pend fwd bwd lab φ x z l n` asserts that every
stab-free type realized at `x` is realized by a walk whose first region above `z`'s region is short
enough.** No register freedom remains to exploit — this is the compiled reason route (c) in
Finding 4 is dead.

**Finding 3 — what the hypothesis asks at the schemas' own instantiation.**

Each schema instantiates `ForwardSlackWitnessed` at `x = (q, c + m·(P+1), n)`, `l = m·(P+1)` (the
equal-register and monotone cases; the common-shift case doubles both the amount and the room
bound). Writing `K` for the next region's countdown and `I` for the intervening idle run:

| | required bound |
|---|---|
| free (Lipschitz, `hasForwardSlack_zero`) at the higher pair | `K ≤ n + (c + m·(P+1)) + I` |
| asked by the hypothesis | `K ≤ n + (c + m·(P+1)) + I − m·(P+1) = n + c + I` |

So the amount cancels against the higher countdown, and the hypothesis is exactly: *the register,
read at the pin, stays inside the LOWER pair's Lipschitz allowance.* Two consequences:

- The modulus-inflation freedom (Probe 1) does NOT make the hypothesis harder at this
  instantiation, because `l` cancels. An "inflate `P` until the amount is unsatisfiable" refutation
  therefore cannot reach the schemas, although it does reach the bare predicate (Probe 4).
- Since `Tc ≤ c` and `n + c + I ≥ c ≥ Tc`, the bound to be established is generous — it is
  `≥ Tc ≥ 2·tShort + tIdle + 2` by (K3), and `≥ cascadeBound` by (K2). Both are exactly the
  magnitudes the normalization in Finding 4 needs.

**Finding 4 — the discharge route, and the one place it is blocked.**

Routes, with verdicts:

| Route | Idea | Verdict |
|---|---|---|
| (a) lengthen the idle run `I` | supplies the deficit directly | **REFUTED** already, and recorded: an idle run of length two needs an idle→idle edge in `step`, which an admissible object need not have (`KTypeSummaryAxiomTest.lean`, prototype `idle-gap-lengthening.lean`) |
| (b) lower the register between `z` and the pin | make the register climb less | **DEAD by Finding 2**: the register at the pin is forced equal to the next region's countdown |
| (c) shorten `z`'s own region | reuse the landed deletion | **IRRELEVANT**: the bound is on the NEXT region; shortening `z`'s region lowers `cntAt g z`, which *weakens* the allowance |
| (d) shorten the NEXT region, type-preservingly | excise a type-respecting block from inside it | **LIVE; the recommended route.** Blocked at one named lemma — see below |

Route (d) in detail, naming the landed machinery it reuses:

1. If no region follows, the regime is vacuous — `hasForwardSlack_of_idle_above` already covers it.
2. Otherwise let `s₀` be the first region start above `z`'s region, `K = cntAt g s₀`. If
   `K ≤ n + c + I`, nothing to do.
3. Else `K > n + c + I ≥ Tc ≥ 2·tShort + tIdle + 2 > tShort`. Instantiate the spaced type
   pigeonhole `exists_typeBlock_of_spacing` AT `s₀` (it takes an arbitrary pending position, with
   `hroom` asking only that the sampling window fit inside that position's own region — satisfied
   since `K ≥ tShort`) at `w₀ := s₀`, `s := 1`. It returns `u` and `d` with `0 < d ≤ tShort`,
   `d ≤ cntAt g u`, `objAt g u = objAt g (u + d)` and equal realized types at the two ends.
4. Delete `[u, u + d)`. Type preservation is the landed `tpOf_eq_delIdx_of_tpOf_eq` (HWZ 2000
   Lemma 17 for the stab-free fragment), which needs no pin condition and no `ParamsOk`.
5. Iterate; each pass drops `K` by `d ≥ 1`, so it terminates with `K < tShort < Tc ≤ c ≤ n + c + I`.
6. Re-lift the register with `z`'s value prescribed at `n` via the freed-anchor lift
   `exists_ladderPath_of_walk_nxt_at` — admissible, because the lowered pin `K − d` still satisfies
   `|K − d − n| ≤ cntAt g z + I` (upper from the original Lipschitz bound, lower because `n < c` in
   the pending-forever regime), and there are NO pins below `z` to satisfy (pending-forever).

**The blocker is step 4's admissibility half, not its type half.** The landed
`exists_deleted_ladderPath_of_pend_past` carries
`hpast : ∀ p ≤ a, pend (objAt g p) = true`, and its proof *uses* that hypothesis to show "every
region start of the deleted walk sits above `a`", which is what lets `pinCompat_of_ladderPath` on
the original discharge both pin obligations unchanged. Inside the next region that hypothesis is
false — the intervening idle run lies below `a` — and the failure is substantive, not formal:

- the intervening pin stays at its position with its value lowered to `K − d`;
- every later pin keeps its value but moves DOWN by `d`;
- so a pin-to-pin distance shrinks by `d` while a pin-to-pin difference grows by `d`, and
  `pinCompat` (`|K_{j+1} − K_j| ≤ |s_{j+1} − s_j|`, which `LadderAgree.lean` records as a NECESSARY
  condition on every ladder path, "not a convenience of the lift lemma's shape") can fail — in a
  window of width `2d`.

The governing inequality is `K_{j+1} ≤ 2·K_j + I_{j+1} + 1`. That is, verbatim, the recurrence
`cascadeBound` iterates: `cascadeBound pend φ = 2 ^ Fintype.card (ProdState Q φ) * (tIdle pend + 2)`,
documented as "the `iter_doubling` recurrence `a (k + 1) ≤ 2 * a k + J + 1` iterated over the at
most `Fintype.card (ProdState Q φ)` distinct pinned regions a rigid past can carry before repeating
a class, at idle-run slack `J := tIdle pend`". And (K2) already asserts `cascadeBound ≤ Tc ≤ c`. So
the budget for the cascade is in `ParamsOk`, pointed at this exact recurrence, and unspent. The
missing declaration is a deletion lemma for the first region ABOVE `z`'s region whose pin
obligations are discharged through that budget rather than through `hpast`.

**Finding 5 — SCOPE: the discharge does not land the reserved name.**

`CellLEZeroConstOfKappaEq` (`LadderAgree.lean:3326`) quantifies over `q, c, n, c', n', z` and one
hypothesis only: `kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n')`. It carries no gap, no
threshold, no room bound. Against that:

- **The thresholds ARE nearly free.** `kappa`'s first coordinate is `min c Tc`, so a collision
  either pins `c = c'` or puts both at or above `Tc` — the landed `eq_or_both_ge_of_min_eq` is
  exactly this, and likewise for `n` against `Tn`. So `Tc ≤ c ∧ Tc ≤ c'` costs nothing beyond the
  diagonal.
- **The gap is NOT free, and it is not a mild condition.** `pend_past_of_nxtAt_lt`: a pending
  position with `nxtAt + 2 ≤ cntAt` lies on a path pending at EVERY earlier position. Its
  contrapositive, `cntAt_le_nxtAt_succ_of_idle_past`, is the WINDOW: any pending position with an
  idle position anywhere in its past has `c ≤ n + 1`. So the pending-forever regime the landed
  inclusions work in is the exotic forward-only-liveness regime (the thirteenth wired probe's
  witness), and the ORDINARY regime `c ≤ n + 1` is addressed by no landed inclusion in either
  direction. A grep for coverage on that side returns only `kappa_collision_regimes`' own branch
  statement.
- **The room bounds remain** (`n' + (n' − n) ≤ c` monotone; the doubled `n + 2m·(P+1) ≤ c`
  common-shift), neither implied by nor implying the gap, as the schemas' own docstrings record.

So full success on this task yields: the five schemas lose ONE of their hypotheses. The reserved
name stays unclaimed, and the dispatch's "landing `cellLE_zero_const_of_kappa_eq` at last" does not
follow. This is recorded as a `user_decision` because it changes the value of the work, not its
feasibility.

**Finding 6 — the refutation side, and why it is blocked.**

A refutation must exhibit an object with `ParamsOk`, a state in the regime, and a stab-free type
realized there only by walks whose next region is long. The natural construction — bound the
object's region lengths so the register is forced to climb — is unavailable:

> Probe 3 (`pend_succ_of_fwd`, compiled): under `fwd` seriality, every pending state has a pending
> successor. The ladder state `(q, 1, 0)` is admissible at a pending `q`, and `Count true false 1 0 c'`
> is contradictory, so the successor `fwd` supplies is pending.

Hence the pending subgraph of every admissible object has out-degree at least one everywhere;
on a finite object with a pending state it therefore contains a cycle, so `objCycleLens ≠ ∅` and
region lengths are unbounded. Two consequences: no admissible object bounds its region lengths
(killing the construction), and (K1)'s divisibility always has content in the regime (so a
pump-down by a multiple of `P + 1` is always *arithmetically* available).

What survives on the refutation side is narrower and worth recording: the bare predicate has an
AMOUNT CEILING. Probe 4 (`hasForwardSlack_amount_le`) compiles that whenever a region does follow,
`HasForwardSlack g z l n` forces `l ≤ n + cntAt g z + I`; above that amount the regime is
unsatisfiable by every path, so `ForwardSlackWitnessed` is refutable *as a bare predicate at a
freely chosen amount*. Combined with Probe 1 (`ParamsOk` is closed under inflating `P + 1` to any
positive multiple, since (K1) is divisibility INTO `P + 1` and (K2)–(K4) never mention `P`), this
says: an unrestricted "`ForwardSlackWitnessed` follows from `ParamsOk` at every amount" claim is
false. It says NOTHING about the schemas, where `l` cancels (Finding 3) — and that scoping must be
stated if this partial refutation is ever landed, exactly as
`kappa_collision_two_regimes_refuted`'s docstring scopes itself.

### External Resources

Four probe lemmas, each compiled this session via `lean_run_code` with
`{"success": true, "timed_out": false, "diagnostics": []}`. None is landed; each is a candidate for
the plan.

**Probe 1 — `ParamsOk` is closed under modulus inflation.**
```lean
import FormalSystem.Metalogic.Decidability.RaySummary.CounterQuotient
theorem paramsOk_inflate {Q : Type} [Fintype Q] (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B) (j : ℕ) (hj : 0 < j) :
    ParamsOk step pend lab φ Tc Tn (j * (P + 1) - 1) B := by
  obtain ⟨⟨h1, h2, h3⟩, hK2, hK3, hK4⟩ := hp
  have hjP : j * (P + 1) - 1 + 1 = j * (P + 1) := by
    have : 0 < j * (P + 1) := Nat.mul_pos hj (Nat.succ_pos P)
    omega
  refine ⟨⟨?_, ?_, ?_⟩, hK2, hK3, hK4⟩
  · intro l hl; rw [hjP]; exact (h1 l hl).mul_left j
  · intro l hl; rw [hjP]; exact (h2 l hl).mul_left j
  · rw [hjP]; exact h3.mul_left j
```

**Probe 2 — the converse of `hasForwardSlack_of_next_region_cnt_le` (THE REDUCTION).**
```lean
import FormalSystem.Metalogic.Decidability.RaySummary.LadderChain
theorem next_region_cnt_le_of_hasForwardSlack (g : ℤ → LadderState Q pend)
    (hg : IsLadderPath step pend g) (z : ℤ) (l n : ℕ)
    (hs : HasForwardSlack g z l n) :
    ∀ I : ℕ, 0 < I →
      (∀ i : ℕ, i < I → pend (objAt g (z + (cntAt g z : ℤ) + 1 + (i : ℤ))) = false) →
      pend (objAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ))) = true →
      (cntAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ)) : ℤ) ≤ (n : ℤ) + cntAt g z + I - l := by
  intro I hI hidle hnx
  have h0 := hidle (I - 1) (by omega)
  have hcast : z + (cntAt g z : ℤ) + 1 + ((I - 1 : ℕ) : ℤ) = z + (cntAt g z : ℤ) + (I : ℤ) := by
    push_cast [Nat.cast_sub (by omega : 1 ≤ I)]; ring
  rw [hcast] at h0
  have h1 : pend (objAt g (z + (cntAt g z : ℤ) + (I : ℤ) + 1)) = true := by
    rw [show z + (cntAt g z : ℤ) + (I : ℤ) + 1 = z + (cntAt g z : ℤ) + 1 + (I : ℤ) by ring]
    exact hnx
  have hpin := cntAt_eq_nxtAt_of_idle_pend g hg _ h0 h1
  have hslack := hs I hI hidle hnx
  rw [show z + (cntAt g z : ℤ) + (I : ℤ) + 1 = z + (cntAt g z : ℤ) + 1 + (I : ℤ) by ring] at hpin
  omega
```

**Probe 3 — seriality forces a pending successor.**
```lean
import FormalSystem.Metalogic.Decidability.RaySummary.LadderChain
theorem pend_succ_of_fwd {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y) (q : Q) (hq : pend q = true) :
    ∃ q', step q q' = true ∧ pend q' = true := by
  have hadm : (1 : ℕ) ∈ Adm pend q := by
    intro h; rw [hq] at h; exact absurd h (by simp)
  obtain ⟨y, hy⟩ := fwd 0 ⟨(q, 1, 0), hadm⟩
  obtain ⟨hstep, -, -, hcount⟩ := hy
  refine ⟨y.1.1, hstep, ?_⟩
  by_contra hne
  rw [Bool.not_eq_true] at hne
  simp only [Count, hne, Bool.false_eq_true, if_false] at hcount
  exact absurd (hcount.2 hq) (by omega)
```

**Probe 4 — the amount ceiling.**
```lean
import FormalSystem.Metalogic.Decidability.RaySummary.LadderChain
theorem hasForwardSlack_amount_le (g : ℤ → LadderState Q pend)
    (hg : IsLadderPath step pend g) (z : ℤ) (l n I : ℕ) (hI : 0 < I)
    (hidle : ∀ i : ℕ, i < I → pend (objAt g (z + (cntAt g z : ℤ) + 1 + (i : ℤ))) = false)
    (hnx : pend (objAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ))) = true)
    (hs : HasForwardSlack g z l n) :
    (l : ℤ) ≤ (n : ℤ) + cntAt g z + I := by
  have h0 := hidle (I - 1) (by omega)
  have hcast : z + (cntAt g z : ℤ) + 1 + ((I - 1 : ℕ) : ℤ) = z + (cntAt g z : ℤ) + (I : ℤ) := by
    push_cast [Nat.cast_sub (by omega : 1 ≤ I)]; ring
  rw [hcast] at h0
  have h1 : pend (objAt g (z + (cntAt g z : ℤ) + (I : ℤ) + 1)) = true := by
    rw [show z + (cntAt g z : ℤ) + (I : ℤ) + 1 = z + (cntAt g z : ℤ) + 1 + (I : ℤ) by ring]
    exact hnx
  have hpin := cntAt_eq_nxtAt_of_idle_pend g hg _ h0 h1
  have hslack := hs I hI hidle hnx
  omega
```

### Recommendations

Recommended decomposition for the plan phase, in dependency order. Phases 1–2 are low-risk and
land compiled value even if phase 4 is defeated; phase 3 is the single risk point.

1. **Land the reduction** (`next_region_cnt_le_of_hasForwardSlack`, Probe 2) in `LadderChain.lean`
   beside `hasForwardSlack_of_next_region_cnt_le`, plus a named `iff` restating the regime as the
   next-region bound. This is the finding that makes the hypothesis checkable; it is compiled and
   carries no risk. Record in its docstring that the two directions are exact, so the regime is a
   condition on the WALK.
2. **Land the two scoping records**: Probe 3 (`pend_succ_of_fwd`, with the corollary that
   `objCycleLens` is non-empty whenever a pending state exists, so no admissible object bounds its
   region lengths) and Probe 4 (`hasForwardSlack_amount_le`). Probe 4's docstring MUST scope itself:
   it refutes the bare predicate at a freely chosen amount and says nothing about the schemas, where
   the amount cancels. Probe 1 (`paramsOk_inflate`) belongs in `CounterQuotient.lean` beside
   `paramsOk_params` for the same reason.
3. **The single new primitive: a deletion inside the FIRST REGION ABOVE `z`'s region**, under
   pending-forever at `z`, with the intervening pin lowered and the later pins' compatibility
   re-established against (K2)'s `cascadeBound`. This is the whole risk of the task. Plan it as its
   own phase with an explicit escape: if pin compatibility cannot be re-established within the
   cascade budget, STOP and record the obstruction as a compiled refutation of route (d) — which is
   itself a result of the same kind as `free_register_anchor_clause_monotone_required`, and a
   legitimate terminus. Do NOT weaken the statement to make it go through, and do NOT introduce an
   axiom or a `sorry`-deferred case.
4. **The normalization loop and the discharge**: iterate phase 3's primitive until the next region's
   countdown is below `tShort`, then close with (K3)'s `2·tShort + tIdle + 2 ≤ Tc`, yielding
   `forwardSlackWitnessed_of_paramsOk_of_pend_past` for the regime, and drop the hypothesis from the
   five schemas. The existing overshoot/iterated-splice loop in `LadderChain.lean` is the model for
   the iteration; `exists_typeBlock_of_spacing` and `tpOf_eq_delIdx_of_tpOf_eq` are the engines.
5. **If phase 3 or 4 is defeated**, the honest terminus is the REDUCTION plus a named walk-level
   condition (`NextRegionBounded`, say) proved equivalent to `ForwardSlackWitnessed` in the regime.
   That converts an opaque existential into a checkable statement about region lengths and is worth
   landing on its own. It would NOT be a discharge and must not be presented as one.

Explicitly NOT recommended: any attempt at route (a) (refuted), route (b) (dead by Finding 2), or
any amendment to (K1) — the (K1)-amendment route named in the test file's commentary is orthogonal
to the obstruction located here, which lives in the pin layer, not in the periodicity layer.

## Decisions

1. **Research did not attempt the discharge itself.** The route requires a new deletion primitive
   with a pin-cascade argument — a multi-phase implementation, not a research-phase probe. Decided
   to deliver the reduction plus the located obstruction instead of a half-built construction.
2. **Four probes compiled rather than argued.** Each claim this report leans on that is not already
   a landed lemma was elaborated against the project's oleans. The two claims that remain *argued*
   are flagged as such: that the pending subgraph's out-degree condition yields a CYCLE (an immediate
   pigeonhole on Probe 3, not compiled), and that the pin-compat window has width `2d` (arithmetic
   read off `pinCompat_of_ladderPath`, not compiled).
3. **Route (d) is recommended over a refutation attempt.** Probe 3 removes the only construction
   shape a refutation of the schema-level hypothesis had, while (K2) and (K3) both carry magnitudes
   sized for route (d)'s two steps. The evidence points at discharge.
4. **The scope correction is raised as a `user_decision`, non-blocking.** Whether to spend a
   multi-phase implementation on dropping one hypothesis from five schemas — when the reserved name
   still will not land — is a value judgment the artifacts cannot infer. Proceeding on the
   recommendation (do it, scoped honestly) costs nothing reversible.
5. **No status beyond `researched` is claimed.** This dispatch writes no
   `.orchestrator-handoff.json`; research agents never do.

## Risks & Mitigations

| Risk | Mitigation |
|---|---|
| Phase 3's pin cascade is unbounded in the forward direction, where (K2)'s budget was derived for the backward one | Plan phase 3 with the explicit escape in Recommendation 3: a compiled refutation of route (d) is an acceptable terminus. Do not let the phase run open-ended |
| The normalization loop's termination measure is the next region's countdown, which the deletion lowers by `d ≥ 1` — but a cascade deletion may RAISE a later pin's relative position | State the measure over the first pin only, and prove each pass lowers it; keep later pins' treatment inside phase 3's primitive, not in the loop |
| `exists_typeBlock_of_spacing`'s `hroom` is stated against `cntAt g z` for the position it is instantiated at — re-instantiating at `s₀` must not silently import `z`'s own regime hypotheses | The lemma's only hypotheses are `hz : pend (objAt g s₀) = true` and `hroom`; it carries no gap and no `ParamsOk`. Verified by reading its signature |
| Over-claiming: a landed `forwardSlackWitnessed_of_paramsOk...` could be mistaken for the reserved name's discharge | Finding 5 is to be reproduced in the new declaration's docstring and in the `KTypeSummaryAxiomTest.lean` pin block: the window regime `c ≤ n + 1` is covered by nothing, and the room bounds remain |
| The dispatch's own starting position is stale (3 vs 5 schemas) | Recorded in the issue log; Finding 1 corrects it. The plan must enumerate all five consumers, not three |

## Tactic Survey Results

A tactic survey in the `lean_multi_attempt` sense was not the operative activity here — no open
goal was being closed. The four probes were elaborated whole. Tactic record, for reuse in the plan:

| Goal | Tactic | Result | Premises/Config |
|---|---|---|---|
| `ParamsOk` modulus inflation, three divisibility conjuncts | `rw [hjP]; exact (h l hl).mul_left j` | success | `Dvd.Dvd.mul_left`; the `j * (P+1) - 1 + 1 = j * (P+1)` normalization needs `Nat.mul_pos` + `omega` |
| the `HasForwardSlack` converse, final arithmetic step | `omega` | success | on `hpin` (`cntAt = nxtAt` at the pin) and `hslack` together; the `ℤ`/`ℕ` casts must be normalized by `push_cast [Nat.cast_sub …]; ring` FIRST |
| `Count true false 1 0 c'` is contradictory | `simp only [Count, hne, Bool.false_eq_true, if_false]` then `exact absurd (hcount.2 hq) (by omega)` | success | bare `omega` on the simp'd hypothesis FAILS ("no usable constraints") — the implication must be applied to `hq` by hand first |
| the amount ceiling | `omega` | success | naturality of `cntAt` is what supplies `0 ≤ K`; no extra premise needed |

## Context Extension Recommendations

- **Topic**: The counter layer's rigidity invariants, as a navigable summary.
- **Gap**: `context/project/lean4/` has `dependency-tracing.md` and `metadata-trust-surfaces.md`
  but nothing recording the three facts any work in `RaySummary/` must start from: the countdown is
  read off the walk (`cntAt_eq_of_obj_eq`), the pin value is forced
  (`cntAt_eq_nxtAt_of_idle_pend`), and the gap `n + 2 ≤ c` means pending-at-every-earlier-position
  (`pend_past_of_nxtAt_lt`). Each cost real time to locate in this session, and the third one
  silently inverts how a reader scopes every landed result in the layer.
- **Recommendation**: add `context/project/lean4/domain/ladder-counter-invariants.md` with those
  three named lemmas, the window/pending-forever dichotomy, and the pin-compatibility inequality.
  One page; it is the orientation every `RaySummary/` dispatch re-derives.

## Appendix

Searches run (all local; no rate-limited Mathlib search tool was needed, since every object in
question is project-local):

- `grep -rn "ForwardSlackWitnessed"` over the tree — 35 hits across `LadderCell.lean`,
  `LadderIdle.lean`, `KTypeSummaryAxiomTest.lean`
- `grep` for declaration sites of `cellLE_zero_const_of_kappa_eq*` / `CellLEZeroConstOfKappaEq*` —
  five schema/theorem pairs plus the unclaimed `def`
- `grep -rn "def ParamsOk" / "def objCycleLens" / "def tIdle" / "def tShort" / "def cascadeBound" / "def kappa" / "def clipIdx" / "def Count" / "def Drift" / "def Adm"`
- `grep` for `exists_typeBlock_of_spacing`, `tpOf_eq_spliceIdx_of_tpOf_eq`,
  `tpOf_eq_delIdx_of_tpOf_eq`, `exists_deleted_ladderPath_of_pend_past`, `pinCompat_of_ladderPath`
- `grep -rn "c ≤ n"` / `"n < c"` in `LadderChain.lean` and `LadderCell.lean` — the negative result
  behind Finding 5's window-regime claim: the only hits are inside `kappa_collision_regimes`' own
  branch statement, so no inclusion addresses that side
- four `lean_run_code` elaborations (Probes 1–4), each returning
  `{"success": true, "timed_out": false, "diagnostics": []}`

Declarations read in full (signature and docstring): `ForwardSlackWitnessed`, `HasForwardSlack`,
`hasForwardSlack_zero`, `hasForwardSlack_mono`, `hasForwardSlack_of_next_region_cnt_le`,
`hasForwardSlack_of_idle_above`, `hasForwardSlack_refuted_unconditional`,
`cellAt_subset_of_shift_of_pend_past_rev`, `CellLEZeroConstOfKappaEq`, `kappa`, `clipIdx`,
`kappa_eq_components`, `kappa_collision_regimes`, `kappa_collision_two_regimes_refuted_of_pend_gap`,
`MonotoneCollisionDisplacement`, `Count`, `Drift`, `Rlad`, `Adm`, `cntAt_sub_of_pend`,
`not_pend_of_count`, `cntAt_eq_nxtAt_of_idle_pend`, `cntAt_eq_of_obj_eq`, `nxtAt_lipschitz`,
`nxtAt_lipschitz_two_sided`, `cntAt_le_nxtAt_succ_of_idle_past`, `pend_past_of_nxtAt_lt`,
`pinCompat_of_ladderPath`, `exists_deleted_ladderPath_of_pend_past`, `exists_typeBlock_of_spacing`,
`tpOf_eq_spliceIdx_of_tpOf_eq`, `tpOf_stabFree_eq_of_objAt_eq`, `tpOf_periodic_of_objAt_periodic`,
`paramsOk{K1,K2,K3,K4}`, `ParamsOk`, `paramsOk_params`, `cascadeBound`, `tShort`, `tIdle`, `ell0`,
`objCycleLens`.

Issue-log entries recorded during this dispatch: one `issue` (scope-drift — the dispatch's starting
position is stale on the schema count and asserts a consequence that does not follow) and one `win`
(`lean_run_code` delivered four compiled probes against the warm olean cache with no `lake build`
and no library edit).
