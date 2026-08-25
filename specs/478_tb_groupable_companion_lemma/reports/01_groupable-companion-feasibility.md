# T-B: The Groupable Companion Lemma — Feasibility Research

**Task type**: lean4 · **Classification**: REAL MODEL THEORY (the chain's risk item) · **Mode**: orchestrator, `--lit`

## 1. Headline

**The risk profile of this task has changed materially, in its favor.** Report 02 §4 (the
governing document) named "KEquiv composition over ordered sums" as *the main new
infrastructure* T-B would have to build. **That infrastructure is already landed, sorry-free,
with clean axioms** — and not only the shared-index composition (sub-phase (1)), but the far
stronger *mixing lemma* (Doets 1987, **3.1.8**, thesis ch. 3 pp. 36–57): cross-index
composition reducing k-equivalence of two ordered sums to k-equivalence of their
*k-type-coloured index orders*. It was built for the dense branch
(`RealModel/ShuffleReal.lean` et al.) and is fully general:

| Declaration | File | Role | `#print axioms` (this session) |
|---|---|---|---|
| `doets_lemma_1_4` | `OrderedSum.lean:46` | shared-index composition (Doets 3.1.7) — **sub-phase (1) is already done** | clean |
| `kEquiv_orderedSum_of_kEquiv_colour` | `MixedSum.lean:543` | **the mixing lemma** (Doets 3.1.8), same depth `k` both sides — no depth loss | clean |
| `BackForth`, `kEquiv_iff_backForth` | `BackAndForth.lean:62,227` | EF-game characterization of `KEquiv` — the engine for proving new k-equivalences by strategy | clean |
| `kEquiv_colourStructure` | `ColourOrders.lean:320` | dense-index coloured-order equivalence (shuffle colourings) | clean |
| `k_equiv_of_iso` | `IntegerModel/GoodStructures.lean:97` | order-iso ⇒ KEquiv | clean |
| `noMaxOrder_of_kEquiv` / `noMinOrder_of_kEquiv` | `RealModel/GoodDense.lean:469,485` | endpoint transfer (T-A's guardrail source) | clean |

(The `OrderedSum.lean` header note calling `doets_lemma_1_5` "still unproved … a documented
strategic sorry" is **stale**: `ShuffleReal.lean`'s header states, and this session confirmed by
`grep` and by `#print axioms`, that it is proved via `kEquiv_orderedSum_of_kEquiv_colour`. The
only bare `sorry` in the tree remains `Transfer.lean:1102` (`countermodel_discrete`).)

On this foundation, this report derives a **complete proof architecture for the companion lemma
in its full generality** (arbitrary countable discrete unbounded `M`, not merely the
chronicle-specific weakening), reduces its remaining mathematical content to four bounded,
classical pieces, and **probe-compiles two of the risk items to completion**:

- `verification/tb_statement_probe.lean` — the entire statement suite of the proposed
  decomposition elaborates against the live codebase, and the Sigma-constant-family /
  `Prod.Lex` bridge (`sumQZOrderIso`: ordered sum of ℤ-fibers over ℚ `≃o` `ℚ ×ₗ ℤ`) is
  **fully proved**, axioms clean.
- `verification/tb_ramsey_probe.lean` — **infinite Ramsey for pairs is absent from Mathlib at
  this pin** (checked: Hindman and Hales-Jewett exist; classical infinite Ramsey does not).
  The probe **proves it from scratch** (117 lines, axioms
  `[propext, Classical.choice, Quot.sound]`), retiring the only external-dependency risk.

`lake build` baseline is green per T-A (2487 jobs); nothing here modified the build tree.

## 2. Literature Proof Structure

**Sources** (all read this session from the corpus; the `doets_1987` index entries carry no
`hazard`/`known_corrections` fields; the Burgess chunk-numbering hazard is noted but Burgess
was not needed beyond the anchors already verified in report 02):

- Doets 1987 thesis, **Chapter 7** (pp. 89–93): the Segerberg ℤ-time completeness proof.
- Doets 1987 thesis, **Chapter 3** (pp. 36–57): condensations and ordered sums — Lemmas
  **3.1.6** (condensation from a transitive relation), **3.1.7** (shared-index sum
  composition), **3.1.8** (the mixing lemma); Theorem **3.3.1** (definably complete →
  complete n-equivalents) exhibits the Claims-1–4 condensation/shuffle pattern the dense
  branch already formalized.
- Doets 1987 thesis, **Chapter 1** (pp. 1–22): EF theory; **1.0.2** (back/forth for linear
  orders), **1.0.3** (i) `m ≡ⁿ ω + ω*` for `m ≥ 2ⁿ − 1`, (ii) `ω ≡ⁿ ω + ζ` — the
  monochromatic discrete completeness family (sub-phase (2)'s exact classical shape).
- Reynolds 1992 §8 (via the landed `DoetsTheorem.lean` chain) — the dense-branch template.

**Strategy**: transfer-not-construction, per report 02 §4.

### Step map (Doets ch. 7, and what each step becomes here)

1. Henkin model + truth lemma — **already the repository's chronicle** (fc-generic, landed).
   [Doets ch. 7 steps 1–8, pp. 89–91]
2. Step 9 (p. 91): replace each `∼`-class by a coloured ζ-block; the countermodel becomes a
   *sum of ζ's and 1's* — **the Base-MCS `limitdomMonadicStructure` is already of this shape**
   (discrete via `box_discrete_gives_discreteness`, so all blocks are ζ; no 1-blocks).
3. Steps 10–11 (pp. 92–93): compress to a single ζ **using the modified Löb axioms** to give
   bounded definable sets maxima — **this is exactly what a Base-MCS lacks** (the z1
   phenomenon). T-B replaces compression-to-ℤ by **inflation-to-`ℚ ×ₗ ℤ`**, which needs no
   Löb: instead of forcing definable sets to attain maxima, the non-Archimedean target
   absorbs the unresolved tails. This is the precise sense in which T-B is "ch. 7 with the
   Löb-free target".

### Dependencies

Step 2's block decomposition feeds the mixing/composition reduction; the inflation step
depends on tail absorption, which depends on Ramsey factorization + monochromatic
completeness; final assembly depends on the ℚ-condensation. See §3.

### Formalization challenges

The tense-logical game of ch. 7 is replaced by the repository's `NormalForm`-based `KEquiv`
plus `BackForth`; no quantifier-relativization gap arises because the repository works
directly with monadic FO structures (Doets's own caveat about the tense-logical formalism,
ch. 7 intro, does not apply at this layer — the truth transfer to temporal formulas is T-C's
already-landed `truth_transfer` machinery).

## 3. The proposed proof architecture

Statement (elaborated verbatim in the probe as `CompanionGeneral`):

```
∀ sig [Fintype sig.preds] [DecidableEq sig.preds] k (M : OrderedMonadicStructure sig)
  [Countable M.carrier] [SuccOrder M.carrier] [PredOrder M.carrier]
  [NoMaxOrder M.carrier] [NoMinOrder M.carrier] [Nonempty M.carrier],
  goodGroupable sig k M
```

The chain, with per-step status:

**(A) Block decomposition** (`BlockDecomposition` in the probe; this is S2, pulled in as
Phase 0 as the task anticipated). Since every point of `M` has both `Order.succ` and
`Order.pred` (Succ/Pred + NoMax/NoMin), the finite-distance equivalence has convex classes,
each order-isomorphic to a coloured ℤ (no ω/ω*/finite blocks can occur), and
`M ≃o Σ_{i∈I} (ℤ, cᵢ)` for a countable nonempty index order `I` — with predicates
transported. *Substance partly landed*: `succ_orbit_convex` and the succ/pred ℤ-action
(`ChronicleToCountermodelBasic.lean:876–1170`, sorry-free, per 422 report 01 §2) prove the
limitdom case; the general abstract version is new but routine, and the dense branch's
quotient order (`IsConvexEquiv.ClassQuot`/`classLt`, `DoetsTheorem.lean:690–843`) is a
direct template for the quotient's `LinearOrder`.

**(B) Per-block inflation** (`TailAbsorption` + its ω* dual in the probe). For each block
`(ℤ, cᵢ)` there is a colouring of `(1+ℚ) ×ₗ ℤ = ℤ + (ℚ ×ₗ ℤ)` with the same k-type: colour
the first fiber by `cᵢ` and absorb the appended `ℚ ×ₗ ℤ` into the block's ω-tail. Reduction
(all reductions at the *same* depth `k`; the mixing lemma loses no depth):
1. Split `(ℤ, cᵢ) = A + B` at 0 (`A` the ω*-part, `B` the ω-part); shared-index composition
   (`doets_lemma_1_4` over a 2-element index) reduces inflation to
   `B ≡ₖ B + (ℚ ×ₗ ℤ, e)` — **tail absorption**.
2. Tail absorption via **Ramsey factorization**: colour pairs `a < b` of ℕ by the k-type of
   the segment `[B_a, B_b)`; infinite Ramsey (now proved, probe 2) yields `n₀ < n₁ < ⋯` with
   all segments of one type `τ` (idempotent by construction, since `[n₀,n₂) = [n₀,n₁)+[n₁,n₂)`
   forces `τ ⊕ τ = τ`). Then `B ≅ prefix + Σ_ω Sⱼ` with every `Sⱼ ≡ₖ S := [n₀,n₁)`, and
   `B + (ℚ ×ₗ ℤ, e) ≅ prefix + Σ_{ω + ℚ×ₗζ} S`-copies, choosing `e` to colour each ℚ-fiber
   ℤ **periodically** by the finite word of `S` (each fiber = `Σ_ζ S`). The mixing lemma
   reduces the two sums to their k-type-coloured index orders `ω` vs `ω + ℚ ×ₗ ζ` — both
   **monochromatic** (all summands share type `τ`), both discrete with min and no max.
3. That final fact is **(C)**.

**(C) Monochromatic discrete completeness at depth k** (`MonoDiscreteNoEnds`,
`MonoDiscreteMinNoMax` + the max-no-min dual in the probe) — sub-phase (2) exactly as the
task stated it, needed for the endpoint profiles {none, min-only, max-only} (the both-ends
case never arises: bounded segments are handled by literal isomorphism). Classical content:
Doets 1.0.2/1.0.3; Th(ℤ,<), Th(ω,<) completeness. Lean route: an explicit Duplicator
strategy through `BackForth`/`kEquiv_iff_backForth`, with the standard truncated-distance
invariant (matched tuples have pairwise succ-distances equal or both `≥ 2^d` at `d` rounds
remaining, likewise distances to the endpoint where one exists). Distance on an abstract
non-Archimedean discrete order is the *partial* function "reachable in `≤ N` succ-steps",
which the threshold invariant only ever needs in truncated form. **This is the hardest single
new proof of the task** and the one substantial piece not probed beyond its statement.

**(D) ℚ-condensation and reassembly** (`CondensationOfQ` in the probe). Every countable
nonempty linear order `I` is a condensation of ℚ: `L := I ×ₗ (1+ℚ)` (with a ℚ prepended into
the minimum fiber when `I` has one, giving that fiber shape `ℚ+1+ℚ`) is countable, dense,
unbounded, hence `≃o ℚ` by Mathlib's **`Order.iso_of_countable_dense`** (verified present).
The fibers give an `I`-indexed convex partition `{Cᵢ}` of ℚ with `Cᵢ ≃o 1+ℚ` (resp.
`ℚ+1+ℚ`), so `Σ_{i∈I} (Cᵢ ×ₗ ℤ) ≃o ℚ ×ₗ ℤ` — the probe's proved `sumQZOrderIso` is the
uniform-fiber special case of this glue, and generalizes to a partition routinely. The
minimum-fiber case consumes the ω*-dual of tail absorption.

**(E) Assembly.**
`M ≃o Σ_I blocks` (A) → `≡ₖ Σ_I inflated-segments` (B, via `doets_lemma_1_4` at shared
index `I`) → `≃o` a colouring of `ℚ ×ₗ ℤ` (D) → `goodGroupable sig k M` via
`k_equiv_of_iso` + `KEquiv.trans` + T-A's `goodGroupable` (definitional; `KEquiv` is `Eq`,
so `trans`/`symm` are free). Instantiation at
`M := limitdomMonadicStructure A h_mcs φ`: all five instance obligations are landed and
fc-generic (`limitdom_monadic_structure_countable`, `…SuccOrder`/`…PredOrder` from
`box_discrete_gives_discreteness` — which takes `h_box` directly, no `Discrete ≤ fc`
hypothesis — `…noMax`/`…noMin`, `zero_mem`-nonempty), mirroring `limitdom_is_good`'s
preamble (`ReynoldsBridge.lean:361–385`) with the Discrete-only links dropped.

**Why the general lemma is now believed reachable**: the previously-open question was the
arbitrary index order `I` (Läuchli–Leonard-strength normal forms seemed needed, which would
blow the budget). The architecture above never classifies `I` at all — `I` is carried
*verbatim* to the target by the ℚ-condensation, and all model theory happens per-block, where
Ramsey factorization + monochromatic completeness suffice. This matches the three worked
witness cases of report 02 §4 (each is the architecture specialized to `I = 1`, `I = 2`,
`I = ℚ+1`-like respectively) and uses the non-Archimedean target exactly where the z1
refutation says it must.

## 4. Probe results (this session, all compiled with `lake env lean`)

`specs/478_tb_groupable_companion_lemma/verification/tb_statement_probe.lean`:
- Statement suite elaborates: `CompanionGeneral`, `CompanionChronicle`, `MonoDiscreteNoEnds`,
  `MonoDiscreteMinNoMax`, `BlockDecomposition`, `CondensationOfQ`, `TailAbsorption`,
  `InfiniteRamseyPairs` — all as `def … : Prop` (no sorries anywhere; statements only).
- **Proved**: `sumQZOrderIso : (orderedSum sig ℚ (fun q => zFiber sig (c q))).carrier ≃o ℚ ×ₗ ℤ`
  — axioms clean. Tactic notes for the implementer: coerce the sigma order via
  `have h : Sigma.Lex (· < ·) (fun _ => (· < ·)) x y := hlt` (defeq), then `cases h with | left … | right …`
  (an `rcases` anonymous pattern hits a dependent-elimination failure on ℤ internals);
  `Prod.Lex.lt_iff` needs the sigma-side target type ascribed to the `orderedSum` carrier or
  the family metavariable does not resolve.
- `#print axioms` on the six landed infrastructure theorems (table in §1): all clean.

`specs/478_tb_groupable_companion_lemma/verification/tb_ramsey_probe.lean`:
- **`infinite_ramsey_pairs` fully proved** (117 lines): descending chain of infinite sets by
  `Exists.choose`, pre-homogeneous sequence, pigeonhole (`Finite.exists_infinite_fiber`),
  monotone enumeration by `Nat.Subtype.ofNat` (NB: `Mathlib.Data.Nat.Nth` is **not built**
  in this project's Mathlib cache — `Nat.nth` is unavailable without a Mathlib rebuild;
  `Mathlib.Logic.Denumerable`'s `Nat.Subtype.ofNat` + `lt_succ_self` is the built
  alternative and works). Also needed: `Mathlib.Data.Set.Finite.Lattice` for
  `Set.finite_iUnion` (not exported by `…Finite.Basic`), and `Set.finite_le_nat` (the
  ℕ-specific finiteness; `Set.finite_Iic` is not available in the built closure here).

## 5. Gap inventory (what the plan must build)

| # | Piece | Status | Est. lines | Risk |
|---|---|---|---|---|
| 0 | Block decomposition (S2, general) | new; limitdom substance + dense `ClassQuot` template exist | 500–700 | low-moderate (plumbing-heavy, no math risk) |
| 1 | Mono discrete completeness, 3 endpoint variants (C) | new; `BackForth` interface landed; classical proof standard | 600–1000 | **moderate — the task's hardest proof**; threshold-invariant bookkeeping |
| 2 | Ramsey + tail absorption + inflation (B) | Ramsey **done** (probe 2); factorization + mixing assembly new | 500–800 | moderate; segment/`subinterval` plumbing + periodic-fiber colouring |
| 3 | ℚ-condensation + glue isos + assembly + chronicle instantiation (D, E) | new; `Order.iso_of_countable_dense` verified present; `sumQZOrderIso` proved | 500–800 | low-moderate; density/unboundedness instances on `ℚ ⊕ₗ (I ×ₗ (1+ℚ))`-shaped orders are fiddly (~100–250 lines) and unprobed |

Total ≈ 2.1–3.3k lines: consistent with the task's 1.5–3k estimate at its upper end, in 3–4
plan phases, **each independently zero-sorry-reachable** (each lands compiling theorems with
no forward dependencies on unproved material).

## 6. Design rulings consumed and honored

- T-A ruling 1 (full carrier, no interval type): the architecture targets the whole
  `ℚ ×ₗ ℤ`; segments appear only as `orderedSum` summands and via `subinterval`, never as a
  new interval type. ✓
- T-A ruling 2 (no `veryGoodGroupable`): nothing above quantifies goodness over closed
  subintervals; the guardrail corollaries are not touched. ✓
- Carried-forward tactic fact: `Prod.Lex.right _ (by simp)` (not `omega`) for unboundedness
  at the carrier — reconfirmed in probe 1's dependencies. ✓
- Non-goals respected: no O1/`succ_cofinal` re-attempt; `countermodel_discrete`,
  `ChronicleConstruction.lean`, `PointInsertion.lean` untouched.

## 7. Escape hatch status

The chronicle-specific weakening (C4/C4'/C5/C5' coherence taming the region structure)
**remains available but is not currently needed**: the general lemma's architecture carries
arbitrary countable `I`. It should be re-invoked only if Phase-1's threshold EF proof or the
Phase-2 assembly stalls; in that event the weakening point is confined to piece (B) (restrict
inflation to the block colourings a Base-MCS chronicle actually produces), and the statement
change must be recorded in the module docstring per the acceptance criteria.

**Falsifiability, restated**: no failure evidence surfaced this session; on the contrary, the
reduction shows a counterexample would have to defeat tail absorption for some ω-word — i.e.
exhibit a colored ω whose depth-k theory changes under appending a `ℚ ×ₗ ℤ` colored
periodically by its own Ramsey segment — which the mixing lemma + monochromatic completeness
argument closes off. A failure would therefore have to invalidate one of the classical steps,
none of which is repository-specific.

## 8. Tactic survey results

The session's proof work was structural; the survey applies to the two proved probes.

| Goal | Tactic | Result | Notes |
|---|---|---|---|
| Sigma-lex → Prod-lex monotone | `cases h with \| left \| right` after defeq `have` | success | `rcases ⟨i,j,h⟩`-style pattern fails (dependent elim on ℤ) |
| Prod-lex → Sigma-lex monotone | `Prod.Lex.lt_iff.mp` + `rw [h1]` + `Sigma.Lex.right` | success | needs type ascription to the `orderedSum` carrier |
| `{x ∈ S \| a < x}` infinite | `Set.Infinite.sdiff (Set.finite_le_nat a)` | success | `Set.finite_Iic` unavailable in built closure; `.diff` deprecated |
| pigeonhole on colours | `Finite.exists_infinite_fiber` + `Set.finite_iUnion` | success | `finite_iUnion` requires importing `…Finite.Lattice` |
| monotone enumeration of infinite `Set ℕ` | `Nat.Subtype.ofNat` + `strictMono_nat_of_lt_succ` + `lt_succ_self` | success | `Nat.nth` module not built — do not plan around it |
| `omega`/`simp`/`aesop` on the above | not applicable | — | goals are structural, not arithmetic |

## 9. Zero-debt compliance

No sorry is recommended anywhere; every plan phase terminates in compiling, sorry-free
theorems. No new axiom: both probes and all six audited infrastructure theorems report
`[propext, Classical.choice, Quot.sound]`. The sole structural sorry remains
`Transfer.lean:1102`, untouched. No `.lean` file in the build tree was modified.

## 10. Session verification log

| Check | Method | Result |
|---|---|---|
| `sum_preservation_proof` / `doets_lemma_1_4` sorry-free | grep + `#print axioms` | clean (stale header comment in `OrderedSum.lean` noted) |
| Mixing lemma landed at same depth k | read `MixedSum.lean:543` + `#print axioms` | confirmed, clean |
| `BackForth` ↔ `KEquiv` both directions | read `BackAndForth.lean` | `kEquiv_iff_backForth`, plus `backForth_symm`/`_pad`/`_mono` helpers |
| Sole bare sorry in WeakCanonical | grep | `Transfer.lean:1102` only |
| Doets ch. 7 step map | corpus read (`doets_1987/sec01`, pp. 89–93) | extracted (§2); Löb enters only at steps 10–11 |
| Doets 3.1.6–3.1.8, 3.3.1, 1.0.2–1.0.3 | corpus read (`sec02`, `sec03`) | anchors for (B),(C),(D) |
| Infinite Ramsey in Mathlib | leansearch + leanfinder + loogle | **absent**; proved locally (probe 2, clean axioms) |
| `Order.iso_of_countable_dense` | loogle | present, `Mathlib.Order.CountableDenseLinearOrder` |
| Statement suite elaborates | `lake env lean` probe 1 | zero errors |
| `sumQZOrderIso` | probe 1, `#print axioms` | proved, clean |
| `infinite_ramsey_pairs` | probe 2, `#print axioms` | proved, clean |
| limitdom instance preamble | read `ReynoldsBridge.lean:60–100, 355–385` | all five instances fc-generic; `box_discrete_gives_discreteness` needs no `Discrete ≤ fc` |
| `lean_run_code` avoidance | per 422 report 01 finding | probes compiled via `lake env lean` only |

## 11. Recommended phase decomposition (for the planner)

- **Phase 0 — block decomposition (S2)**: finite-distance quotient, `LinearOrder` on classes
  (template: `DoetsTheorem.lean` `ClassQuot`), per-block `≃o` coloured ℤ, sigma
  reassembly iso. Lands `BlockDecomposition`.
- **Phase 1 — monochromatic discrete completeness**: truncated-distance `BackForth`
  invariant; master lemma + three endpoint variants; corollaries at `colourSig` for
  constant colourings. Lands `MonoDiscreteNoEnds` + variants. *(The hard phase; if any
  phase needs splitting into two dispatches, this one.)*
- **Phase 2 — inflation**: promote probe 2's Ramsey into the module tree; segment
  factorization of an ω-block; periodic fiber colouring; tail absorption (both duals) via
  mixing + Phase 1; per-block inflation. Lands `TailAbsorption` + `Inflate`.
- **Phase 3 — condensation and assembly**: ℚ-condensation (Cantor via
  `Order.iso_of_countable_dense`; the density/unboundedness instances are this phase's
  fiddle), partition glue iso (generalizing the proved `sumQZOrderIso`), `CompanionGeneral`,
  then `CompanionChronicle` (the `limitdom_is_good` Base analogue, header-documented as the
  deliverable T-C consumes).

Module placement: `GroupModel/` siblings of `GoodGroupable.lean` (e.g. `BlockDecomposition.lean`,
`MonoDiscrete.lean`, `RamseyFactorization.lean`, `GroupableCompanion.lean`), each wired with a
"CI edge only" import in `WeakCanonical.lean` until T-C consumes them (C6), no aggregator (C8),
no task-number citations (C9) — cite Doets thesis pages and the sibling modules instead.
