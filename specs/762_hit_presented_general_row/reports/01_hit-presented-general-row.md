# Research Report: Task #762

**Task**: 762 - (C)'s general row: exists_hitPresented with sizeBound φ k a count, for every regular ℤ-model (run-layer phase 3)
**Started**: 2026-10-12T23:55:35Z
**Completed**: 2026-10-13T00:25:44Z
**Effort**: ~30 minutes wall-clock, one dispatch
**Dependencies**: 759 (logical edge, discharged: Hit-level POSITIVE), 761 (serialization edge only)
**Sources/Inputs**:
- Codebase: `FormalSystem/Metalogic/Decidability/RaySummary/{README.md,Trace.lean,HitOf.lean,Present.lean,Compose.lean,Transport.lean}`, `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/{Family.lean,Saturation.lean,README.md}`, `FormalSystem/Metalogic/WeakCanonical/NEquivalence.lean`, `FormalSystem/Metalogic/Expressiveness/{MonadicFO.lean,NormalForm.lean}`, `FormalSystem/ForMathlib/Combinatorics/InfiniteRamseyPairs.lean`, `FormalSystem/Semantics/SlicedFrame.lean`
- Wired probes: `specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` (Probe745), `hit-presented-node.lean` (Probe759)
- Records: `specs/757_lplus_decidability_successor_task_set/followup-scope-spec.md` (Sections B, H5), `specs/759_node_hit_presented_probe/summaries/01_node-hit-presented-probe-summary.md`, `specs/ROADMAP.md`, `specs/state.json`
- Literature (orientation only, via `--lit`): HWZ 2000 Def. 12 / Remark 13 / Theorem 14 (chunks of `hodkinson_wolter_zakharyaschev_2000_decidable_fragments_fotl`, UNVERIFIED-summary provenance per the index), GKWZ 2003 Thm 13.6 (locator only), Thomas 1997 *Languages, Automata, and Logic* §5.1 (cited by the KTypeSummary README)
- lean-lsp MCP: `lean_local_search` (positive hits for every consumed lemma; the index reported `error`, so only the positive hits are evidence)
- A brute-force check of the one delicate lemma (python, scratchpad; 1347 pairs, 0 mismatches)
**Artifacts**: - specs/762_hit_presented_general_row/reports/01_hit-presented-general-row.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **T2's verdict is POSITIVE**, re-derived from `specs/759_node_hit_presented_probe/summaries/01_node-hit-presented-probe-summary.md` and the header of `hit-presented-node.lean`: `Probe759.hitPresented_node` holds at every pre-seam at every `k ≥ 1`. The Stage 0 "statement is false" branch of this record does NOT fire; the record proceeds.
- **The statement as filed re-derives verbatim against the tree** (`HitPresented` in `Trace.lean`, `hitOf`/`mem_hitOf_iff` in `HitOf.lean`, `SegmentFactorization`/`InFamily` in `KTypeSummary/Family.lean`), and `HitPresented` reduces exactly to a combinatorial statement about bi-infinite words over the closure alphabet: *for every family triple of a seam trace there is a bi-ultimately-periodic word realizing it whose own family triples are all seam triples* (statement (★) below). Nothing model-theoretic is left once that is proved; conversely a counterexample to (★) would yield a Hit-level negative on a one-history regular model, so (★) is the whole question.
- **(★) is TRUE at every depth `k ≥ 1`, by an elementary argument** that uses only ingredients of the kind the tree already has: infinite Ramsey for pairs (`Nat.exists_strictMono_const_pair_colour`), the composition congruence `kTypeOf_listSeg_append_congr`, the `k`-type visibility lemmas of `HitOf.lean`, and ONE new finite datum — a "σ-star profile" of a finite word that composes under concatenation. No Büchi/MSO theorem is cited, no cslib, no automata library. The decisive composition law was brute-force verified at depth 1 before being recommended.
- **The literal-segment lasso route of the two fixtures does NOT generalize** (this is the open `⊆` direction Probe745's header names): a periodic repetition of one literal segment can realize family triples the seam trace lacks (the "cut-pair" obstruction, Finding 3). The general route replaces the literal segment by a Ramsey block chosen for a finer finite colouring, and that is exactly what makes the extra triples disappear. The unconditioned transport `↔` (threshold `3·(m₀+p)`) named in the task as possibly needed is NOT needed.
- **A sorry-free path exists with an exhibited count**: `sizeBound φ k := N ^ 3 * (4 * P ^ 2 + 1)` with `N := Nat.card (KType (clSig φ) k)` and `P := Nat.card (Profile (clSig φ) k)` (the profile type, a finite product of `KType`-indexed Bool tables; Finding 6). A count of types and profiles, never a running time.
- **Recommended outcome: proceed to planning**, as a four-layer decomposition (profile monoid; bounded representatives; one-sided periodic transport, both orientations; gadget assembly and headline) in the 2500-3500-line range by the tree's own precedents, with a file-scope decision for the planner: sibling helper modules under `RaySummary/` or one large `HitComplete.lean`. Depth `1 ≤ k` is kept exactly as filed; the landed form is direction-neutral in its combinatorics but bears nothing on `⊡(Pp)` (guardrail (e)).

## Context & Scope

The filed statement (verbatim from the dispatch, matching the README's (C) row and obligation (ii) item 2):

```
theorem exists_hitPresented (M : TaskModel F.toTaskFrame) [F.IsRegular] (τ) (t) (φ) (k) (hk : 1 ≤ k) :
    ∃ (Q : Type) (_ : Fintype Q) (_ : DecidableEq Q) (lab : Q → (clSig φ).preds → Bool) (step : Q → Q → Bool),
      Fintype.card Q ≤ sizeBound φ k ∧ HitPresented M τ t φ lab step k
```

Constraints honoured throughout: (a) the alphabet is `clSig φ`; (b) `M` ranges over all regular `ℤ`-models, no width or fibre hypothesis; (c) `sizeBound` is a count; (d) zero debt, no cslib, no external decidability theorem in place of a proof; (e) nothing bears on `⊡(Pp)`. The research question was whether a general argument exists at all, and if so what it costs; no Lean was written.

Two facts about the substrate fix the shape of everything below, both re-read this session:
- `KType sig k := NormalForm sig k 0 → Bool` (`NEquivalence.lean:62`) over `MonadicFormula` whose only quantifiers are `all`/`ex` over positions (`MonadicFO.lean:81-87`). The types are **first-order** depth-`k` types. There is no set quantifier, so "has a factorization into pieces of type σ" is not a depth-`k'` property for any fixed `k'`. This rules out the obvious transport-by-saturation argument and is why a new finite datum (the profile) is needed.
- `hitOf` is characterized by `mem_hitOf_iff` (`HitOf.lean:795`): `x ∈ hitOf lab step now k ↔ ∃ ρ, IsRun lab step now t ρ ∧ InFamily sig k x.1 x.2.1 x.2.2 (runTrace lab ρ)`, and `HitCl M τ t φ k = ⋃ bf, familyTriples (clSig φ) k (clTrace M φ t (spliced τ t bf))` (`hitCl_eq_iUnion`, `Trace.lean`). Both sides of `HitPresented` are unions of family-triple sets of bi-infinite words.

## Findings

### Codebase Patterns

**1. T2 (task 759) verdict and what it does and does not settle.** `Probe759.hitPresented_node` is positive at every `k ≥ 1`, with `windowN m k + 5` states exhibited (`card_QN_le`); the by-product `presented_node` shows `Node`'s seam fibres are finite (`m + 1` histories) so trace-level `Presented` holds there too. [CARRIED-UNVERIFIED: `specs/759_node_hit_presented_probe/summaries/01_node-hit-presented-probe-summary.md` and the probe header; the probe file was not recompiled this session, but its headline names were grep-confirmed in the file at 1434 lines.] Consequence for this record: no Stage 0 ruling; `Node` is the second positive fixture; neither fixture tests the general `⊆` direction, exactly as the README says. One prose claim in the README and the Probe759 header — "a Hit-level falsifier for (C) needs a seam with infinitely many histories through it" — is a heuristic, not a theorem (a one-history model with an aperiodic valuation also defeats trace-level `Presented`, since a finite presentation's run set is pumping-closed); it is moot now that a general positive argument exists, and nothing should be built on it.

**2. The exact reduction of `HitPresented` to a statement about words.** Write `T(c) := familyTriples (clSig φ) k c` for a colouring `c : (clSig φ).preds → ℤ → Prop`. Two facts, both provable from the landed substrate:
- *Every triple of `hitOf` is realized by a bi-ultimately-periodic anchored run.* From `mem_hitOf_iff` take a run `ρ` and a `SegmentFactorization F` of its trace; the states `ρ (F.W z)` at the positive cuts `z ≥ 1` repeat (`Q` finite), so the block of `ρ` between two equal-state cuts can be repeated forever, and the result is still a run (steps inside the block by `ρ`, across the seam of the repetition by the step `ρ` already takes there) still anchored at `t`, and still carries the same triple (its positive segments are copies of positive segments of `F`). Mirror on the negative side. So `↑(hitOf lab step now k) = ⋃ { T(runTrace lab ρ) : ρ a bi-ultimately-periodic anchored run }`.
- *Every bi-ultimately-periodic word `w^(ω*) · m · v^ω` (one `now` in `m`, at `t`) is the trace of the unique anchored run of a three-piece gadget* (a `|w|`-cycle, a `|m|`-path, a `|v|`-cycle, joined by one step each; the run is predecessor-deterministic before `t` and successor-deterministic after `t`, as in Probe745's gadget confinement at `hit-presented-model-a.lean:1162-1200`), and a disjoint union of gadgets (no cross edges, as `stepOf_no_cross`) has `hitOf` = the union of the gadgets' triple sets.

Hence **`HitPresented M τ t φ lab step k` is satisfiable for some `(Q, lab, step)` iff for every `x ∈ HitCl M τ t φ k` there is a bi-ultimately-periodic `c'` with `x ∈ T(c') ⊆ HitCl M τ t φ k`.** Since `HitCl` is a union of `T(c)` over seam traces `c`, the sufficient (and, on a one-history model, necessary) condition is

> **(★)** for every colouring `c` with `now` exactly at `t` and every `x ∈ T(c)`, there is a bi-ultimately-periodic `c'` with `x ∈ T(c') ⊆ T(c)`.

(★) mentions no model. Any `{a,b}`-word is the closure trace of a one-history regular model for `φ := atom` (slice `Unit` through `FrameOver.ofSlicedStep`, `[Finite Unit]` satisfied, regular by `ofSlicedStep_isRegular` at `SlicedFrame.lean:293`), so (★) is not merely sufficient: a counterexample to (★) at depth `k` would be a Hit-level negative at depth `k`. The record's whole content is (★).

**3. Why the fixtures' route does not generalize (the cut-pair obstruction).** The two probes realize `x` by repeating one literal segment of the seam trace. In general, if `c`'s positive segments are `s₁ s₂ s₃ …` all of `k`-type `τ₊`, then `c' := … s₀ s₁^ω` has, besides `x`, the triples obtained by cutting `s₁^ω` at an interior offset `o` in every copy: positive type `type(s₁[o..]) · type(s₁[..o))`. Transporting that back to `c` needs a cut of the same `k`-type pair in every `s_i`, and `k`-type pairs of cuts are a depth-`(k+1)` datum, not determined by `s_i ≡_k s₁`. Deeper saturation does not close this: a factorization of `s₁^ω` may cut each copy many times, and `m` cuts are a depth-`(k+m)` datum with `m` unbounded. This is precisely the open `⊆` direction Probe745's header records, and it is also why the transport `↔` of `Transport.lean` (one deleted constant run inside one segment) is the wrong tool here.

**4. The general argument for (★): Ramsey over a finite composing profile.** Fix `σ ∈ KType`, write `L_σ` for the nonempty finite words of `k`-type `σ` and `h` for `kTypeOf ∘ listSeg`. For a finite word `w` define the **σ-star profile**

> `g_σ(w) := { (h p, h q) : w = p ++ m ++ q, m ∈ L_σ^* }` (a relation on `KType × KType`; `m` may be empty),

and the **profile** `prof(w) := (h w, (g_σ(w))_σ)`. The one delicate fact — the **composition law** — is that `prof (w₁ ++ w₂)` is a function of `prof w₁` and `prof w₂`:

> `g_σ(w₁w₂) = {(x, y·h w₂) : (x,y) ∈ g_σ w₁} ∪ {(h w₁·x, y) : (x,y) ∈ g_σ w₂} ∪ {(x,y) : (x,u) ∈ g_σ w₁, (v,y) ∈ g_σ w₂, u·v = σ ∨ (u = 1 ∧ v = 1)}`

where `·` is the type product given by `kTypeOf_listSeg_append_congr` and `1` is the type of the empty word (at `k ≥ 1`, `u·v = 1` forces `u = v = 1`, by `nonempty_iff_of_kTypeOf_eq`). Proof: a middle `m ∈ L_σ^*` of `w₁w₂` lies in `w₁`, lies in `w₂`, straddles at a piece boundary (`u = v = 1`), or straddles inside one piece `l = l' l''` with `h l' · h l'' = σ`. This law was brute-force checked this session at depth 1 over `{a,b}` for all 1347 word pairs of total length ≤ 6 and all three `σ`: 0 mismatches. Two membership read-outs: `w ∈ L_σ^+ ↔ w ≠ [] ∧ (1,1) ∈ g_σ w`, and `w ∈ L_α L_σ^* ↔ (α, 1) ∈ g_σ w`. Also record the **cut profile** `CP(w) := {(prof z, prof y) : w = z ++ y}` (finite).

*One-sided transport* (★₊). Let `R` be the forward tail `c[t+1, ∞)` and `(α₀, τ) ∈ FT(R) := {(h p, σ) : R = p · w'', w'' ∈ L_σ^ω}`; the triple `x` supplies `(α₀, τ₊) ∈ FT(R)` with `α₀` the type of `c[t+1, F.W 1)`. Apply `Nat.exists_strictMono_const_pair_colour` to the colouring `(i, j) ↦ (prof, CP)` of the stretch `c[F.W i, F.W j)` for `1 ≤ i < j`: this yields consecutive blocks `B₁ B₂ …` (each a union of consecutive `τ₊`-segments, so `B_a ∈ L_τ₊^+`) with `prof B_a = prof B₁ =: E` and `CP B_a = CP B₁` for all `a`. Put `u := c[t+1, start of B₁)` and `R' := u · B₁^ω`. Then:
- `(α₀, τ₊) ∈ FT(R')`: `u ∈ L_α₀ L_τ₊^*` and `B₁ ∈ L_τ₊^+`.
- `FT(R') ⊆ FT(R)`: let `R' = p · l₁ l₂ …` with `h p = α`, `l_i ∈ L_σ`. Infinitely many cut positions fall in the periodic part, finitely many offsets modulo `|B₁|`, so two cuts share an offset `o`: copies `a₀ < a₀ + s`. With `z := B₁[..o)`, `y := B₁[o..]`: the prefix `u B₁^(a₀-1) z ∈ L_α L_σ^*` and the stretch `y B₁^(s-1) z ∈ L_σ^+`. In `R`, choose in every block a cut `(z_a, y_a)` with `prof z_a = prof z`, `prof y_a = prof y` (equal cut profiles). By the composition law applied block by block, `prof (u B₁ … B_(a₀-1) z_(a₀)) = prof (u B₁^(a₀-1) z)` and `prof (y_a B_(a+1) … B_(a+s-1) z_(a+s)) = prof (y B₁^(s-1) z)`, and membership in `L_α L_σ^*` and `L_σ^+` is read off the profile. The chosen cuts in blocks `a₀, a₀+s, a₀+2s, …` therefore factor `R` as `(L_α L_σ^*) · (L_σ^+)^ω = L_α L_σ^ω`, i.e. `(α, σ) ∈ FT(R)`.
No idempotent and no "all merged stretches equal" strengthening is needed: only equality of profile and cut profile block by block, plus compositionality.

*Mirror* (★₋) on the backward tail, with `BT(L) := {(σ, h q) : L = w'' · q, w'' ∈ ^(ω*)L_σ}`; the tree has no order-reversal transfer for `kTypeOf`, so this is a second Ramsey application in the other orientation, exactly as `exists_zFactorization` (`Family.lean:104`) already applies Ramsey "once per orientation".

*Assembly of (★).* With `c_t` the letter at `t` (the only `now`-position, which is in the middle segment of every factorization at `k ≥ 1` — `live_of_run`'s argument), `T(c) = {(σ₋, β · h c_t · α, σ₊) : (σ₋, β) ∈ BT(c(-∞, t)), (α, σ₊) ∈ FT(c[t+1, ∞))}` (the middle `[W 0, W 1)` splits at `t`; types compose by `kTypeOf_segZ_eq_listSeg` and the append congruence). Take `c' := (left periodic from (★₋)) · c_t · (right periodic from (★₊))`; then `x ∈ T(c') ⊆ T(c)`.

**5. The bound, by pumping on two-sided profile pairs.** A word `w` of length `≥ P² := (Nat.card Profile)²` has two cut positions `i < j` with equal `(prof w[..i), prof w[i..))` pairs; deleting `w[i, j)` preserves `prof` (composition law) and shrinks `CP` (every cut of the shortened word has the same profile pair as a cut of `w`), and preserves nonemptiness (type-visible). So the period `v := B₁` can be replaced by `v'` with `|v'| < P²`, `prof v' = E`, `CP v' ⊆ CP B₁`, and the transport argument goes through verbatim with `v'` (it used only `prof v`, `CP v ⊆ CP B_a`, and `prof u`); likewise `u`, and the left side. Gadget size `≤ |w'| + (|u''| + 1 + |u'|) + |v'| ≤ 4P² + 1`, and there are at most `|HitCl| ≤ N³` gadgets (`N := Nat.card (KType (clSig φ) k)`). Hence the exhibited count

> `sizeBound φ k := N ^ 3 * (4 * P ^ 2 + 1)`, `P := Nat.card (Profile (clSig φ) k)`, `Profile sig k := KType sig k × (KType sig k → KType sig k → KType sig k → Bool)`,

a `Fintype` (via `normalFormFintype`, `NormalForm.lean:199`) with `P = N · 2^(N³)`. This counts types and profiles and times nothing — the disclaimer of `AnchorLayer.lean`, quoted in `Compose.lean:302-320`, applies with "profiles" for "cells". The planner may tighten the constants; the shape is what matters.

**6. Ingredients already in the tree, by name (all `lean_local_search`-confirmed this session).**
- `Nat.exists_strictMono_const_pair_colour` (`ForMathlib/Combinatorics/InfiniteRamseyPairs.lean:134`) — Ramsey, any finite colour type.
- `kTypeOf_listSeg_append_congr` (`Compose.lean:280`), `listSeg`, `labels`, `kTypeOf_segZ_eq_listSeg` (`Compose.lean:172`) — type composition and the segment/list bridge.
- `nonempty_iff_of_kTypeOf_eq`, `exists_interp_iff_of_kTypeOf_eq` (`HitOf.lean:185-196`) — nonemptiness and `now`-visibility at `k ≥ 1`.
- `SegmentFactorization`, `InFamily` (`Family.lean:70,201`), `familyTriples` (`Trace.lean`), `hitCl_eq_iUnion`, `HitPresented` (`Trace.lean`), `mem_hitOf_iff`, `IsRun`, `runTrace` (`HitOf.lean`, `Present.lean:162-166`), `exists_concat`/`isRun_concat`/`kTypeOf_segZ_concat` (`HitOf.lean:320-416`) — the run-from-lists machinery for the gadget's run and its segment types.
- `normalFormFintype` — finiteness of `KType` and hence of `Profile`.
- The seam fibre is used only through `hitCl_eq_iUnion`; `[F.IsRegular]` enters only as `HitCl`'s own hypothesis.
Not needed: `inFamily_of_shrink_run`, `kTypeOf_listSeg_replicate_eventually_periodic_bounded` (the deletion surgery is subsumed by profile pumping), the transport `↔`, any `Presented`-level fact.

### External Resources

- HWZ 2000 Def. 12 / Remark 13 / Theorem 14 (read from the corpus chunks this session; UNVERIFIED-summary provenance per `specs/literature-index.json`, cite as "Def 12 (PDF p.14)"-style per the index's rule): the quasimodel `⟨f, R⟩` with a freely chosen run set, and Remark 13's "any superset of a quasimodel's run set is a quasimodel". As the README records, this semantics has neither choice. The argument above is not HWZ's realisation step at all; it is the Büchi-side fact that a nonempty ω-regular condition has an ultimately periodic witness, re-proved for the specific finitely many conditions `L_α L_σ^ω` without any automata — i.e. the Ramsey/monoid proof of that classical fact (Thomas 1997 §5.1, the reference the KTypeSummary README already carries for its chain). It orients the shape; it sources no claim.
- GKWZ 2003 Theorem 13.6: locator only (the corpus chunk is a reduction to MSO theories of linear orders); not used.
- Mathlib at the pin: no infinite Ramsey for pairs (the tree proves its own, `InfiniteRamseyPairs.lean` header), no `kTypeOf`-style FO-type monoid. Mathlib's `Language`/`DFA`/`NFA` are not needed and should not be introduced (guardrail (d)).

### Recommendations

1. **Plan the positive theorem.** Four layers, each a phase (or, if the planner prefers, each a sibling module under `RaySummary/`):
   - *Layer 1 — Profile.* `starProfile sig k σ (l : List (sig.preds → Bool)) : KType → KType → Prop` (or `Finset (KType × KType)`), `profile`, `cutProfile`; the composition congruence `profile_append_congr` (statement: `profile l₁ = profile l₁' → profile l₂ = profile l₂' → profile (l₁ ++ l₂) = profile (l₁' ++ l₂')`, proved through the explicit law of Finding 4); `mem_starPlus_iff_profile`, `mem_prefixStar_iff_profile`; `Fintype (Profile sig k)` and its card.
   - *Layer 2 — Bounded representatives.* `exists_rep_of_length_lt`: for every `l`, an `l'` with `l'.length < P ^ 2`, `profile l' = profile l`, `cutProfile l' ⊆ cutProfile l` (pigeonhole on `(profile prefix, profile suffix)`, deletion, induction on length).
   - *Layer 3 — Periodic transport.* `FwdTypes`/`BwdTypes` of an ω-/ω*-tail (as colourings on `ℤ` with the tail read from `t`), `exists_periodic_fwd` ((★₊) with the length bounds from Layer 2), its mirror `exists_periodic_bwd`, and the assembly `exists_periodic_subfamily : ∀ c F, ∃ w m v, … InFamily … (periodic w m v) ∧ familyTriples (periodic w m v) ⊆ familyTriples c ∧ bounds`.
   - *Layer 4 — Gadget and headline.* `gadget (w m v)` on `Fin |w| ⊕ Fin |m| ⊕ Fin |v|` with `lab`/`step`, `gadget_run_unique`, `runTrace_gadget_eq`, the disjoint union `Σ x ∈ HitCl, gadget …` (classical choice of `c_x`, `F_x`, `w_x m_x v_x` per triple; the presentation is noncomputable, which the `∃` statement permits), `hitOf_union_eq`, `card_union_le`, `sizeBound`, and `exists_hitPresented` by `mem_hitOf_iff` in both directions.
2. **Keep the filed statement exactly**, including `1 ≤ k` free: the argument is uniform in `k ≥ 1` (it uses `k ≥ 1` only for nonemptiness and `now`-visibility), so no restriction to `k = 1` is needed even though the run layer consumes only `k = 1`.
3. **File scope**: the planner must decide between one large `HitComplete.lean` and sibling modules (`RaySummary/Profile.lean`, `RaySummary/Periodic.lean`); the latter widens `file_scope` (record via `proposed_file_scope`). Either way the shared library set (aggregator, `FormalSystem.lean`, C14 pins in `KTypeSummaryAxiomTest.lean`, `check-module-invariants.sh`, `docs/theorem-index.md`, the README's (C) row and obligation (ii) item 2, `status.typ`) is touched as filed.
4. **Order of work and the honest stop**: Layer 1's composition law is the only lemma with real risk; land it first and gate the rest on it. If it does not close as stated, the fallback within zero debt is to strengthen the profile (carry `h` of the straddling halves explicitly) rather than to weaken the statement; `[BLOCKED]` remains the honest outcome if Layer 3's transport fails to close, with the goal state recorded.
5. **Record in the README** that (C)'s general row is settled positively by a Ramsey-plus-profile argument once landed, retiring the "needs an infinite seam fibre" prose, and that the transport `↔` of `Transport.lean` stays a non-goal.

## Literature Proof Structure

**Source**: HWZ 2000, *Decidable fragments of first-order temporal logics*, Def. 12 (quasimodel), Remark 13, Theorem 14 (PDF pp. 11-14 per the index's citation rule); GKWZ 2003 Thm 13.6 as a locator. Both are orientation only (task description, guardrail (d)).
**Strategy in the source**: realise a satisfiable formula by a quasimodel `⟨f, R⟩` whose run set may be chosen freely (Remark 13), then decide existence of a quasimodel by MSO over the flow (Theorem 15) or by a periodic-quasistate criterion (Section 5).

### Step Map
1. Read the state function and runs off a model — HWZ Thm 14 (⇒); landed as `clTrace_localRun`/`clTrace_anchored` (`Trace.lean`).
2. Choose the run set freely; any superset works — HWZ Remark 13; **unavailable here** (runs are the path set of one time-invariant relation, README "(W): what landed").
3. Realise a quasimodel by a model — HWZ Thm 14 (⇐); this is (S), not this record.
4. Periodicity of the quasistate sequence / ultimately periodic witnesses — HWZ Section 5 and, more directly, Büchi's theorem as presented in Thomas 1997 §5.1; **this record's step**, re-proved for the finitely many conditions `L_α L_σ^ω` by Ramsey over a composing finite profile (Finding 4).

### Dependencies
- Step 4 depends on nothing from steps 2-3; it uses the landed step 1 only through `hitCl_eq_iUnion`.

### Potential Formalization Challenges
- Step 4: the composing profile (Layer 1) is the tree's own construction; the literature proves the ultimately-periodic-witness fact through automata or Wilke algebras, neither of which is to be imported.

## Decisions

- Chose the Ramsey-over-profile route over (i) the fixtures' literal-segment lasso (refuted as a general route by the cut-pair obstruction, Finding 3), (ii) transport by deeper `k`-type saturation (unavailable: types are first-order and cut counts are unbounded), (iii) citing ω-regularity/Büchi (forbidden by guardrail (d) and the contingency clause), (iv) a direct Ramsey on `(k+1)`-types (insufficient for the same reason as (ii)).
- Chose per-block equality of profile and cut profile over an idempotent/"all merged stretches" strengthening: the transport compares `B_(a+1) … B_(a+s-1)` with `B₁^(s-1)` block by block through compositionality, so only Ramsey's monochromatic consecutive pairs are used.
- Chose duplication for the backward half (no reversal transfer exists; `exists_zFactorization` sets the precedent) over adding a `kTypeOf`-reversal lemma; the latter is a reasonable alternative the planner may pick if it prefers one transport proof.
- Chose a noncomputable presentation (classical choice per triple) — admissible for the `∃` statement; the fixtures' `def` presentations were needed only for their `#guard`s.
- Did not set `user_decision`: the outcome is a positive route with no genuine preference, cost, or ambiguity left for the user.

## Risks & Mitigations

- **Composition law of the profile (Layer 1)** — the one lemma with a case analysis that could hide a gap (the straddling case with one empty half). Mitigation: brute-force checked at depth 1 (1347 pairs, 0 mismatches); land it first, state it in the congruence form, and keep the explicit law as the proof's internal statement.
- **Size** — 2500-3500 lines by the precedents (Probe745 at 1595 and Probe759 at 1434 lines, measured this session with `wc -l`); the record may need more than one implementation dispatch. Mitigation: four phases with their own verification, Layer 1 and 2 landed before Layer 3.
- **Backward duplication** — doubles Layer 3. Mitigation: parametrize the transport over an "orientation" where the tree's style allows, or accept the duplication as `Family.lean` does.
- **File scope** — sibling modules widen the filed scope. Mitigation: `proposed_file_scope` in the plan; the admission gate decides.
- **The bound's shape** — `P = N · 2^(N³)` is enormous; it is a count and the task forbids any complexity reading of it. Mitigation: state it, quote the disclaimer, claim no minimality.
- **Guardrail (e)** — the combinatorics is direction-neutral, but nothing here is a backward Bool-fixture bridge; the README text must say the landed form bears nothing on `⊡(Pp)`.

## Tactic Survey Results

- Not applicable (no tactic survey performed): no Lean goal exists yet for this record; the research stayed at the level of statements and a brute-force check of the decisive lemma.

## Context Extension Recommendations

- **Topic**: finite composing profiles for FO-type languages (`L_σ^+`, `L_α L_σ^*`) and the Ramsey-over-profile periodic-witness argument.
- **Gap**: `context/project/lean4/` has no note on why FO `k`-types do not compose under star and what the tree's substitute is; the KTypeSummary README's chain stops at the family cover.
- **Recommendation**: once Layer 1 lands, add a short section to `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/README.md` (or a `RaySummary` README subsection) naming the profile as the chain's "step 6" substitute and pointing at `exists_hitPresented` as its consumer.

## Appendix

- Search queries: `lean_local_search` for `exists_strictMono_const_pair_colour`, `kTypeOf_listSeg_append_congr`, `exists_interp_iff_of_kTypeOf_eq`, `hitCl_eq_iUnion`, `mem_hitOf_iff`, `kTypeOf_segZ_eq_listSeg` (all positive; index field `error`, so only positive hits are evidence); `literature-search.sh "quasimodel run state function Definition 12 Theorem 14"` (degraded, no FTS results; chunks read by grep instead); greps for `reverse|OrderDual` across `WeakCanonical/` and `RaySummary/` (no `kTypeOf`-reversal lemma).
- Brute-force script: scratchpad `gcheck.py` (depth 1, alphabet `{a,b}`, all words of length ≤ 4 paired with total length ≤ 6, three `σ`); output `checked 1347 pairs; mismatches: 0`.
- References: Thomas 1997 *Languages, Automata, and Logic* §5.1 (via the KTypeSummary README); HWZ 2000 (corpus, UNVERIFIED-summary provenance); the RaySummary README sections "The verdict", "The bound: exhibited on the fixture, as a count", "(W): what landed and what did not", "Evidence" (probes six and eleven).
