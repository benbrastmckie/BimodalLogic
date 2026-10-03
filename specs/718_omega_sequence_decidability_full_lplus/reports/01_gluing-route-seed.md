# Seed Report — The Gluing Route to Decidability of Full L⁺

**Status**: SEED, not a research deliverable. Written 2026-10-02 by the orchestrating session at
author request, to give later research rounds a verified starting point instead of a blank page.
**Not** the product of a dispatched research round: it claims no route verdict, no ranking, and
no completeness of coverage. The first dispatched round on this task should treat every section
below as a checked premise to build on, and its own report as `02_`.

**Every source claim here was read against the live tree or the paper's clean working tree.**
Claims are tagged `[VERIFIED]` where read directly, `[DERIVED]` where argued from verified
claims, and `[OPEN]` where neither.

---

## 1. The idea, stated precisely

Define a possible world as a way of **gluing** a sequence of next states to a sequence of states
from which to have arrived — taking *all* ways of doing so.

Formally: a world is a pair `(b, f)` of a backward ray and a forward ray agreeing at a seam,
`b 0 = f 0`, giving the two-sided history `w (-n) = b n`, `w n = f n`. The world-set over a seam
state `s` at time `t` is the fibre product

    {backward rays into s}  ×_s  {forward rays out of s}

"All ways of gluing" is exactly the choice of the **full** product — the full bundle, in
branching-time terms. `[DERIVED]`

---

## 2. Three facts that make this a reading of the landed semantics, not a new one

### 2.1 `⊡` already is the re-gluing quantifier `[VERIFIED]`

`FormalSystem/Semantics/TruthClauses.lean`, `StabClause.stab_clause`, verbatim:

    /-- `⊡φ` holds iff `φ` holds at every world history in the same state at the current time. -/
    stab_clause : T M τ t e (stab φ) ↔ ∀ σ : WorldHistory F, τ.state t = σ.state t → T M σ t e φ

The hypothesis `τ.state t = σ.state t` **is** the seam. So `⊡` quantifies over precisely the
re-gluings at the present state, and the gluing construction states structurally what this clause
states as a side condition.

The dual is `dstab_iff` in the same file: `∃ σ, τ.state t = σ.state t ∧ T M σ t φ`.

### 2.2 It is `⊡`, not `□` `[VERIFIED]`

`FormalSystem/Semantics/Truth.lean`'s clause table gives `□φ` as `∀ σ : WorldHistory F, TruthAt M
σ t φ` — **no** state-agreement conjunct. `□` is the full S5 history quantifier; `⊡` is the
seam-local one. `SameStateAt` was deleted as a separate notion, so the seam survives only inside
`⊡`'s clause. Any route analysis that conflates the two will go wrong immediately.

### 2.3 Possible worlds already *are* paths, and the finite presentation already exists `[VERIFIED]`

- `FrameOver.mem_HF_iff_adjacent` (`FormalSystem/Semantics/IntNormalForm.lean:348`): over ℤ, `H_F`
  is **exactly the bi-infinite step-paths**.
- `FormalSystem/Metalogic/Decidability/BiLasso/Basic.lean` docstring, verbatim: "A decision
  procedure for a presented ℤ-frame cannot quantify over `H_F` directly: over ℤ that set is
  exactly the bi-infinite step-paths (`FrameOver.mem_HF_iff_adjacent`), and there are uncountably
  many. This module supplies the finite presentation such a procedure enumerates instead."
- A `BiLasso` is three lists — **`back`, `mid`, `fwd`** — decoded into a function `ℤ → Fin P.card`
  that is `mid` on the window, `fwd` repeated rightward, `back` repeated leftward.

That is the gluing, already landed in finitely presented form, and it is the route the **stab-free**
decidability work actually took. The gluing idea is therefore not a new proposal but the
generalisation of a landed, working construction. `[DERIVED]`

---

## 3. The precise open question

The `BiLasso` presentation glues a **single** backward list to a **single** forward list. `⊡`
needs the whole fibre over the seam. And `not_finite_width_fmp` proves no class with finite
per-time fibres is complete, whatever its clauses. `[VERIFIED — machine-checked under task 710's
probe `NoFiniteWidthModel.lean`, sorry-free, axioms [propext, Classical.choice, Quot.sound]]`

So the question is:

> Can `back`/`fwd` range over **path sets** — root paths of a finite class graph — rather than
> single lists, and does the resulting `⊡` check stay decidable?

This is exactly the "infinite fibres (root paths of a finite class graph)" successor shape the
sliced-FMP refutation record demanded. The demand and this idea are **one object**. `[DERIVED]`

Corollary for route ranking: the ω-automata route and the infinite-fibre route are **one route**,
not two. "All root paths" is where a deterministic automaton running along each path buys a finite
summary; that is the only known mechanism. `[DERIVED]`

---

## 4. Why the move to ω-sequences might buy something

Every landed refutation — the compression refutation `not_exists_plusCertifies_pumpTarget` and
`not_finite_width_fmp` — was proved in the **two-sided ℤ-time** setting, where `snce`, the
backward one-sided live sets (`bwdLive`), the backward tail and the mirrored `TailStableMirror`
filter all exist. A forward-only ℕ-indexed basis deletes that half of the structure outright.
`[VERIFIED — the refutations' setting; DERIVED — the consequence]`

**First substantive task**: determine whether each obstruction is *genuinely* two-sided or merely
*stated* two-sidedly, by re-deriving it over ω-sequences or exhibiting exactly where the
re-derivation fails. A negative answer (obstruction survives forward-only) is as valuable as a
positive one and must land as a theorem. `[OPEN]`

Also: `FormalSystem.PlusLanguage.plusValidZTime_iff_plusValidInt` is the landed Step 0 transfer
result. Whether an ω-time analogue exists, is false, or *is* the real content of the move, is
open. `[OPEN]`

---

## 5. The paper: what is live, what is cut

Source: `~/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`, working tree **clean**, so
these reflect committed state. `[VERIFIED]`

| Label | State | Content |
|---|---|---|
| `app:gluing` | **LIVE** | Two convex histories agreeing on a nonempty overlap glue to the **unique** convex history on the union. Full proof: convexity of the union and the task constraint across the seam both discharged. |
| `thm:extension` | **LIVE** | The Extension Theorem. |
| `app:Structure` | **COMMENTED OUT** | The whole presheaf appendix. |
| `app:presheaf-dictionary` | **COMMENTED OUT** | Sheaf, Totality, Directed Gluing, Possible Worlds, Determinism, Reflection clauses. |

**The seam case is written and commented out.** The paper's pasting-principles passage reads:
given `ρ, σ ∈ H_F` with `ρ(z) = σ(z)`, let `ρ ⌢_z σ` agree with `ρ` at all times `y ≤ z` and with
`σ` at all times `y ≥ z`, "which is a possible world by `app:gluing` applied to the restrictions
of `ρ` and `σ` to `(-∞, z]` and `[z, ∞)`". That is this route's construction, with the paper's own
notation `⌢_z`, and its hypothesis `ρ(z) = σ(z)` matches `stab_clause`'s `τ.state t = σ.state t`
on the nose. `[VERIFIED]`

**Consequences for citation discipline.** Cut clauses are the author's own mathematics with the
supporting results promised elsewhere, and this repository is where elsewhere is — task 616's
description records this explicitly. Treat a cut clause as a **specification to implement**, never
as a theorem to cite. In particular the "choice-free" characterisation of the presheaf gluing
appears on a commented-out line; the choice-free character of the **binary** seam gluing
nevertheless follows from the **live** `app:gluing`, whose main statement needs only convexity and
the task constraint, so source it there. `[VERIFIED]`

**The paper also says `app:gluing` is not yet formalised**: "The frame correspondence, determinism,
and soundness results … are formalized in the Lean 4 repository for this paper; `app:gluing` is
not yet among them." `[VERIFIED]`

---

## 6. The binary/directed split — a trap

`app:gluing`'s footnote: gluing along an **upward directed** family of domains rests on
*Saturation* rather than composition alone, routed through `thm:extension`, and it supplies a
counterexample proving Saturation is genuinely required — `D = ℚ`, `W = {q ∈ ℚ : q > 0}`,
`r ⇒ₓ r'` iff `|r' − r| ≤ x`, where the restrictions of `τ(t) = 1 − t` to `(0, b]` for `b < 1`
form an increasing chain whose union admits no value at time 1. `[VERIFIED]`

An ω-ray built by **iterated** gluing is a *directed colimit*, not a binary one. So the forward-ray
construction may land in the Saturation-dependent case rather than the choice-free one. **Do not
assume the binary case transfers.** `[DERIVED]`

Task 564's own existing report (`reports/01_finite-vs-directed-gluing-findings.md`) already
tabulates this split: "two sections at a seam | Compositionality only, choice-free | this task;
`glue_seam` in the 553 probe". `[VERIFIED]`

---

## 7. What already exists to build on

| Asset | Where | State |
|---|---|---|
| `glue_seam` — the composition step for seam gluing | `specs/553_decide_convex_history_layer_collapse/probes/04_presheaf-skeleton.lean` | Proved in a **probe**, not the library |
| Presheaf skeleton: `Beh F l`, restriction, functoriality, Germs | same probe, ~200 lines | Proved sorry-free; task 563 is siting, not discovery |
| `FrameOver.mem_HF_iff_adjacent` | `FormalSystem/Semantics/IntNormalForm.lean:348` | Landed |
| `BiLasso` `back`/`mid`/`fwd` finite presentation | `FormalSystem/Metalogic/Decidability/BiLasso/` | Landed |
| Tier A **effective** extension theorem (bi-lasso case only) | `BiLasso/Orbit.lean:721`; "no Zorn" preserved in `BiLasso/Agreement.lean` | Landed, special-case |
| General Extension Theorem **by Zorn + `Classical.choice`** | `FormalSystem/Semantics/Extension.lean` | Landed, non-constructive |
| Periodicity toolkit: pigeonhole, lasso detection over `IsStepPath` | `FormalSystem/Semantics/Periodicity.lean` | Landed |
| `PartialHistory` with an **arbitrary** `domain : F.Duration → Prop` | `FormalSystem/Semantics/PartialHistory.lean:136-138` | Landed — ray domains already expressible; no new type without first showing this insufficient |
| Forward-primitive frame: `PosRel` on `D.PositiveCone`, two-sided `TaskRel = TaskFrame.reflect PosRel` as a **definition** not a field, reflection law a derived theorem | `FormalSystem/Semantics/TaskFrame.lean:140-144, 329` | Landed — forward generation with the past by reflection is already the architecture |
| `Path(F)` as the **free category on the graph `(W, ⇒₁)`** when `D = ℤ` | Task 618, not started | Filed — this is the "root paths of a finite class graph" presentation |

**The Zorn/choice-free asymmetry is the effectivity opening**: the paper has a choice-free binary
construction where the Lean side has a Zorn extension, and the programme already needed an
effective version badly enough to build one for the bi-lasso case. Generalising it is worth
landing even if decidability stalls. `[DERIVED]`

---

## 8. A route nobody has tried

`JPL/metalogic.tex`'s Finite Model Property subsection records FMP for **TM** as an important open
question; notes FMP would give decidability by exhaustive search over finite models; names
**filtration** as the standard technique; and names the precise obstacle — the quotient
construction must preserve task-coherence, i.e. the induced `⇒` must still satisfy **Nullity and
Compositionality**. It leaves open whether a modified filtration handling task-coherence can be
developed, whether TM lacks FMP entirely, or whether decidability must come by other means such as
translation into a decidable first-order fragment. `[VERIFIED]`

Task-coherence-preserving filtration appears **nowhere** among the routes this programme has tried
or refuted. It must be assessed and ranked as a candidate in its own right. Caveat: the paper's
discussion is about stab-free TM, so carrying it to full L⁺ is additional work, not a transfer.
`[DERIVED]`

---

## 9. What is closed — do not re-attempt

Any proposed route must state the **mechanism** by which it evades each item that bears on it, not
merely that it is differently stated. `[VERIFIED — all machine-checked]`

- The lasso-based `PlusSharingWitnessFamily` class is incomplete: `not_exists_plusCertifies_pumpTarget`,
  at any time, any lasso count, any segment lengths, under **no** hypothesis on succession.
- The finite-graph `PlusGraphCertificate` class was refuted before implementation began.
- The finite-**carrier** FMP for the sliced shape is refuted unconditionally, and **not** rescued
  by restriction to the CTL-like fragment.
- Finite **width** is strictly stronger: `not_finite_width_fmp`. Witness `Φ := θ'` and
  `□(⊡Fp → ¬⊡¬Xp)`. Obstruction: limit closure plus finite fibres contradicts König.
- `exists_tailStable_repr` is **false** (`FixtureStable.lean`) and must not be restated in any
  weakened form.

---

## 10. The caution that must not be dropped

Gluing does **not** shrink the fibre. "All ways" is the **largest** choice, a full product. This
route does not evade `not_finite_width_fmp` by bounding width — it **concedes** infinite fibres and
seeks a finite *presentation* of them, which is the only move the refutation leaves open. `[DERIVED]`

Two consequences:

1. "All ways" is a substantive commitment — the full bundle. A restricted bundle would change which
   `⊡` formulas are valid, so the choice must be argued, not assumed. Prior art exists in this
   repository under "ockhamist grounding". `[DERIVED]`
2. Decidability of the **check** is the whole risk, since `⊡`'s clause becomes a quantification
   over all pairs of root paths through a seam state. `[DERIVED]`

And the programme's standing discipline applies: any route found unworkable must have its
obstruction recorded as a **theorem**, not a placeholder or a prose caveat. Negative results are
deliverables here.

---

## 11. Suggested first probes, in dependency order

1. **The stab-fibre characterisation.** State and prove, or refute, that `stab_clause`'s
   quantification domain is the fibre product of the backward and forward ray sets over the seam
   state. A refutation is the most valuable outcome, since every downstream route assumes it. This
   is the keystone: it is what makes `⊡` a statement about gluings rather than an opaque quantifier.
2. **The ray layer's status.** Colimit of the bounded sections `Beh F l` (hence
   Saturation-dependent) versus separate primitive versus `PartialHistory` with a ray domain.
   Upstream of everything else.
3. **The two-sidedness test.** Re-derive `not_finite_width_fmp` over ω-sequences, or exhibit where
   it fails.
4. **The decidable check.** With the fibre as a path space of a finite class graph, what is a
   decidable `⊡` check, and is determinization required?

---

## 12. Open questions this seed does not answer `[OPEN]`

- Does the ray layer need Saturation? (§6)
- Does the finite-width obstruction survive forward-only? (§4)
- Is there an ω-time analogue of `plusValidZTime_iff_plusValidInt`? (§4)
- Is the stab fibre the fibre product? (§11.1)
- Can a decidable check exist over path sets? (§3)
- Does task-coherence-preserving filtration work, and does it reach L⁺? (§8)
- Does the binary seam gluing generalise the Tier A effective extension theorem? (§7)

## References

- `FormalSystem/Semantics/TruthClauses.lean` — `StabClause.stab_clause`, `dstab_iff`
- `FormalSystem/Semantics/Truth.lean` — the clause table, `box_iff`
- `FormalSystem/Semantics/IntNormalForm.lean` — `mem_HF_iff_adjacent`
- `FormalSystem/Semantics/PartialHistory.lean` — `PartialHistory`, `IsTotal`, `IsConvex`
- `FormalSystem/Semantics/TaskFrame.lean` — `PosRel`, `TaskFrame.reflect`, `reflection`
- `FormalSystem/Semantics/Extension.lean` — the Extension Theorem, by Zorn
- `FormalSystem/Semantics/Periodicity.lean` — the periodicity toolkit
- `FormalSystem/Metalogic/Decidability/BiLasso/` — `Basic.lean`, `Orbit.lean`, `Agreement.lean`
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Limits/NoCertificate.lean`
- `~/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` — `app:gluing`, `thm:extension`
- `~/Philosophy/Papers/PossibleWorlds/JPL/metalogic.tex` — the FMP subsection
