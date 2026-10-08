# Research Report: Hit-level completeness, requirement (C) — settling `HitPresented`

**Task**: 745 - Requirement (C) of the ray-product verdict: Hit-level completeness with a computable bound -- settle HitPresented first
**Started**: 2026-10-08T00:00:00Z
**Completed**: 2026-10-08T00:00:00Z
**Effort**: ~550-800 Lean lines across 6 phases (see Recommendations)
**Dependencies**: None (requirement (S) is an independent sibling record; (W) depends on both)
**Sources/Inputs**:
- In-tree declarations, re-resolved BY NAME and verified by compiled `#check` (never by cited line)
- `specs/evidence/seam-gluing-ray-product/presented-not-complete.lean` (`Probe735.not_presented`, 292 lines — the dispatch cites 246; line/size drift confirmed)
- `FormalSystem/Metalogic/Decidability/RaySummary/{Trace,HitOf,Closure,Present,Compose}.lean`
- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/{Family,Basic,Saturation,KTypeFin}.lean`
- `FormalSystem/PlusLanguage/PlusRayFibre.lean`
- Two compiled scratch probes (paths in Appendix)
**Artifacts**:
- `specs/745_hit_level_completeness_computable_bound/reports/01_hit-level-completeness-probe.md`
**Standards**: report-format.md, subagent-return.md, anti-analysis.md, reference-grounding.md, adversarial-verification.md, context-hygiene.md

---

## Executive Summary

- **`HitPresented` is NOT refuted on fixture model A — the opposite: it looks SATISFIABLE, and the
  route is NOT closed.** The dispatch's forward-type crack is real and reaches further than it
  was stated to: at the Hit level the realization demand is a demand on finitely many `k`-type
  triples, not on the trace set, so the pigeonhole/pumping argument that killed `Presented`
  has nothing to bite on. A presentation of `L + 6` states satisfies
  `HitCl MA stayA t Fp k = ↑(hitOf lab step (clNow Fp) k)` for every `k ≥ 1`.
- **The decisive mechanism is a truncation argument that needs NO `k`-type computation at all.**
  `HitCl` is a finite set (`hitCl_finite`, verified). Pick one witnessing splice per member; on
  model A every splice is `stayA` or `jump w`; take `L` = the largest witnessing jump offset.
  Then `HitCl` is already the union of the family triples of the finitely many traces
  `{stayA} ∪ {jump w : t ≤ w ≤ t + L}` — and a finite presentation whose anchored runs have
  EXACTLY those traces gives `hitOf` equal to the same union, by `mem_hitOf_iff`. No saturation
  lemma, no `kTypeOf` evaluation, no `decide` over `KType`.
- **The hardest geometric step is already machine-checked.** The model-A step-path
  classification — time pinning, backward `a`-rigidity, forward `a`/`b` dichotomy, `b`-absorption,
  and the full `∃ w ≥ t` jump classification — compiles clean in ~100 lines
  (`Probe745.path_classify`, Appendix). `HitPresented` itself is statable and
  `Presented → HitPresented` compiles in three lines with axioms
  `[propext, Classical.choice, Quot.sound]`.
- **The bound half is where the route actually stalls, and the stall is sharper than "no bound is
  in sight".** The truncation proof extracts `L` from `Set.Finite.bddAbove` over `HitCl` — i.e.
  from `Classical.choice`. It therefore establishes satisfiability while yielding **no bound at
  all**, not even a bad one, not even on the fixture. An effective bound needs an eventual-periodicity
  lemma for block `k`-types that is **not in the tree**; the entry point that IS in the tree is
  `kTypeOf_listSeg_append_congr` (the composition congruence), which makes block types a morphism
  into a finite semigroup.
- **The fixture result does not generalize, and the report says so.** Model A's splice traces are
  eventually constant in both directions, which is exactly what makes a finite presentation able
  to realize them exactly. For a general regular ℤ-model the splice traces are arbitrary colourings;
  the general construction would have to go through one lasso per triple, and the `⊆` direction
  (no spurious factorization of a lasso) is open. Forward-only throughout.

---

## Context & Scope

Researched: whether the Hit-level hypothesis named in `Probe735.not_presented`'s header —
`HitPresented := HitCl M τ t φ k = ↑(hitOf lab step (clNow φ) k)` — holds at the seam `(t, a)` of
fixture model A (`Fin 3`, `p` at `b` only, steps `a→a, a→b, b→b`, regular through
`ofSlicedStep_isRegular`) on the constant history `stayA` with `φ := Fp`; and, conditional on
non-refutation, what a computable bound would require.

`HitPresented` is **not** a declaration in this tree — confirmed by a repo-wide grep: every
occurrence is in `specs/**` prose (`TODO.md`, `ROADMAP.md`, task 735's artifacts), none in
`FormalSystem/**` or any probe. This report's own compiled definition is the first type-correct
statement of it.

Constraints carried unchanged: `[F.IsRegular]` everywhere; fragment L⁺ (`PlusFormula`); ℤ time
axis, never states (model A's slice is `Fin 3` while its carrier `ℤ × Fin 3` is infinite — the
shape `not_finite_width_fmp` leaves standing, so no finite-width assumption is made or needed);
zero debt (no external Büchi/MSO lemma cited in place of a proof); no complexity bound of any
kind, upper or lower; cslib read-only (not consulted — nothing in this analysis needed it);
forward-only (the `⊡(Pp)` backward side is untouched and this report claims nothing about it).
`Decidable (PlusValidZTime φ)` is not stated here in any form, conditional or otherwise.

**Evidence tier, announced as the readiness context requires.** The lean-lsp MCP tools
(`lean_local_search`, `lean_hover_info`, `lean_leansearch`, `lean_loogle`, `lean_state_search`)
were **not exposed to this dispatch**, despite the dispatch file reporting the server registered
and reachable. All positive declaration evidence was therefore obtained at a *stronger* tier than
hover — compiled `#check` / `#print axioms` / `#eval` through `lake env lean` against the live
build — and two substantive proof fragments were compiled end to end. The one place this degrades
evidence is **negative** existence claims ("X is not in the tree"), which rest on `grep` over
`FormalSystem/**` rather than an `index: consulted` LSP result. Two such claims are made and both
are labelled Medium confidence below.

---

## Findings

### Reference grounding: tier selection

**Tier 2 (documentation-backed)** is the governing tier: the sources of record for this task are
in-tree Lean declarations and their docstrings, not a paper. Tier 1 is *not* claimed and the
`## Literature Proof Structure` section is therefore omitted per contract. For completeness: the
library's own docstrings anchor the trace/quasimodel vocabulary to HWZ 2000 (Definition 6's
`sub_x φ`, Definition 11's run conditions, Theorem 14's `t_a`), and
`hodkinson_wolter_zakharyaschev_2000_decidable_fragments_fotl` is in the repo sub-index; **no
literature chunk was read during this dispatch** and no claim below rests on one.

### Lemma-level source-to-implementation mapping (5-column)

Every row's identifier was re-resolved by name and confirmed by a compiled `#check`; `Status`
records what that compilation established.

| Source (where the obligation comes from) | Prop / Location (by name, never by line) | Lean Identifier | Type Signature (as compiled) | Status |
|---|---|---|---|---|
| Hit-level hypothesis named in `Probe735.not_presented`'s header | not a declaration anywhere in `FormalSystem/**` | `HitPresented` (this report's) | `… (lab : Q → (clSig φ).preds → Bool) (step : Q → Q → Bool) (k : ℕ) : Prop := HitCl M τ t φ k = ↑(hitOf lab step (clNow φ) k)` | **NEW, compiles** — first type-correct statement |
| `Presented` is strictly stronger than the Hit-level hypothesis | `Trace.lean`, `hit_eq_hitOf_of_presented` | `hit_eq_hitOf_of_presented` | `… (k : ℕ), 1 ≤ k → Presented M τ t φ lab step → HitCl M τ t φ k = ↑(hitOf lab step (clNow φ) k)` | VERIFIED; `Presented → HitPresented` compiled, axioms `[propext, Classical.choice, Quot.sound]` |
| `hitOf` is the realized-triple set of the presentation's runs | `HitOf.lean`, `mem_hitOf_iff` | `mem_hitOf_iff` | `… (k : ℕ) (t : ℤ), 1 ≤ k → ∀ x, x ∈ hitOf lab step now k ↔ ∃ ρ, IsRun lab step now t ρ ∧ InFamily sig k x.1 x.2.1 x.2.2 (runTrace lab ρ)` | VERIFIED — this is the hinge of the whole argument |
| `hitOf` in rectangular liveness form (the alternative hinge) | `HitOf.lean`, `mem_hitOf_iff_live` | `mem_hitOf_iff_live` | `… ↔ ∃ q₀ q₁, x.2.1 ∈ pathTypesNow … q₀ q₁ ∧ bwdLiveSep … x.1 q₀ = true ∧ fwdLiveSep … x.2.2 q₁ = true` | VERIFIED (not needed by the recommended route; see Decisions D-3) |
| `HitCl` is a union over the seam's ray pairs | `Trace.lean`, `hitCl_eq_iUnion` | `hitCl_eq_iUnion` | `HitCl M τ t φ k = ⋃ bf, familyTriples (clSig φ) k (clTrace M φ t (spliced τ t bf))` | VERIFIED |
| `HitCl` is finite — the source of the truncation bound | `Trace.lean`, `hitCl_finite` | `hitCl_finite` | `∀ … (k : ℕ), (HitCl M τ t φ k).Finite` | VERIFIED; its proof routes through `finite_family_triples`, i.e. finiteness of the whole triple product, not of the realized part |
| Finiteness of the `k`-type triple product | `KTypeSummary/Basic.lean` | `kType_finite`, `finite_family_triples` | `∀ (sig) [Finite sig.preds] (k), Finite (KType sig k)` / `… Finite (KType sig k × KType sig k × KType sig k)` | VERIFIED |
| Family membership (what a triple means) | `KTypeSummary/Family.lean`, `InFamily` / `SegmentFactorization` | `InFamily` | `… (k : ℕ) → KType sig k → KType sig k → KType sig k → (sig.preds → ℤ → Prop) → Prop` | VERIFIED |
| Seam splices are ray pairs = bi-infinite step paths through the seam state | `PlusRayFibre.lean` | `SeqPair`, `seamOmegaEquiv`, `ZPathFibre`, `pathFibreEquiv` | `SeqPair F s := {bf : BwdSeq F × FwdSeq F // bf.1.1 0 = s ∧ bf.2.1 0 = s}`; `StabFibre F.toTaskFrame t s ≃ SeqPair F s`; `ZPathFibre F t s := {g : ℤ → F.WorldState // IsStepPath F g ∧ g t = s}` | VERIFIED — splices ↔ step paths, which is what makes the classification possible |
| The spliced history | `SeamMulti.lean`, `spliced` | `spliced` | `(τ) → (t : ℤ) → SeqPair F (τ.state t) → WorldHistory F.toTaskFrame` | VERIFIED |
| Frame step shape of the fixture | `IntNormalForm.lean` | `FrameOver.ofSlicedStep_step` | `(ofSlicedStep R fwd bwd).step p q ↔ q.1 = p.1 + 1 ∧ R p.1 p.2 q.2` | VERIFIED — the time component is pinned, which is step 1 of the classification |
| Fixture regularity | `IntNormalForm.lean` | `FrameOver.ofSlicedStep_isRegular` | `(ofSlicedStep R fwd bwd).IsRegular` | VERIFIED |
| Closure alphabet and letter read-out | `Closure.lean` | `clSig`, `clLetter`, `clNow`, `clTrace_letter`, `clTrace_now` | `clSig φ := ⟨{ψ // ψ ∈ (PlusFormula.subformulas φ).toFinset} ⊕ Unit⟩`; `clTrace M φ t σ (clLetter φ h) z ↔ PlusTruthAt M σ z ψ`; `clTrace … (clNow φ) z ↔ z = t` | VERIFIED |
| The alphabet is five letters for `φ := Fp` | `Subformulas.lean`, `plusSubformulaClosure` | — (`#eval`) | `(plusSubformulaClosure Fp).card = 4`, members `{untl ⊤ p, atom p, ⊤ = bot.imp bot, bot}`; plus `clNow` ⇒ 5 preds | VERIFIED by `#eval` |
| The composition congruence — entry point for an EFFECTIVE bound | `Compose.lean` | `kTypeOf_listSeg_append_congr` | `… (h₁ : kTypeOf sig k (listSeg l₁) = kTypeOf sig k (listSeg l₁')) (h₂ : …) : kTypeOf sig k (listSeg (l₁ ++ l₂)) = kTypeOf sig k (listSeg (l₁' ++ l₂'))` | VERIFIED present; the eventual-periodicity consequence is NOT in the tree |
| Mathlib bound tooling for the truncation step | Mathlib | `Set.Finite.bddAbove`, `Set.Finite.toFinset`, `Finset.sup` | `s.Finite → BddAbove s` (needs `[Preorder α] [IsDirectedOrder α] [Nonempty α]`, satisfied by `ℤ`) | VERIFIED by `#check` |
| What the obstruction probe reads (the dispatch's warning, confirmed) | `HitOf.lean` | `fwdLiveSep`, `bwdLiveSep`, `fwdSepGraph`, `bwdSepGraph` | disjoint-segment liveness, `τ ∈ pathTypes … x' y` joined by one `step` | VERIFIED — `Present.lean`'s `fwdLive`/`bwdLive` are a different (shared-endpoint) graph and were NOT used anywhere in this analysis |

### Codebase Patterns

**1. Why the `Presented` refutation genuinely does not transfer — stated precisely.**
`Presented` demands an equality of **trace sets**: every seam splice's closure trace is a run
trace and conversely. `Probe735.not_presented` exploits exactly that: realizing `jump (t + n + 1)`
for arbitrarily large `n` forces a run with an arbitrarily long `p`-false stretch after `t`, hence
(pigeonhole on `Fintype.card Q`) a repeated state, hence — by `pump_isRun` — a run whose trace has
`Fp` at `t` and `p` nowhere after `t`, which `LocalRun.untl` forbids. The contradiction is reached
through `presented_localRun`, i.e. through the trace-set equality.

`HitPresented` demands only an equality of **family-triple sets**. Two consequences, both
load-bearing:

- `presented_localRun` is unavailable, so the pumped run's trace is no longer required to be a
  local run. The refutation's final step has nothing to contradict.
- More decisively, the realization demand is no longer "realize every `jump w`" but "realize every
  `k`-type triple that some `jump w` realizes" — and by `kType_finite` there are only finitely many
  of those. **A finite presentation does not need an unbounded `p`-false stretch**, so the
  pigeonhole has nothing to pigeonhole.

**2. The truncation argument (the recommended route), in full.** Fix `k ≥ 1`.

- `hitCl_eq_iUnion` : `HitCl MA stayA t Fp k = ⋃ bf, familyTriples (clSig Fp) k (clTrace MA Fp t (spliced stayA t bf))`.
- `hitCl_finite` : that set is finite. For each of its finitely many members pick (choice) a
  witnessing `bf`.
- **Classification** (compiled, see below): `spliced stayA t bf` is `stayA` or `jump w` for some
  `w ≥ t`. So each witness carries a natural offset (`0` for `stayA`, `w - t` otherwise).
- `Set.Finite.bddAbove` on the image of those offsets gives `L : ℕ` bounding them all. Hence
  `HitCl = ⋃_{σ ∈ S_L} familyTriples (clTrace MA Fp t σ)` where
  `S_L := {stayA} ∪ {jump w : t ≤ w ≤ t + L}` — a **finite** set of traces. (`⊇` is immediate:
  `S_L` consists of genuine splices.)
- `mem_hitOf_iff` turns `hitOf lab step (clNow Fp) k` into `⋃_{ρ an anchored run} familyTriples (runTrace lab ρ)`.
- So it suffices to exhibit a finite presentation whose anchored-run traces are **exactly** `S_L`'s
  traces. No `kTypeOf` is ever evaluated.

**3. The presentation, explicitly.** `Q := Fin 3 ⊕ Fin (L + 3)`, so `Fintype.card Q = L + 6`.

- *Gadget 1 (`Fin 3`, realizing `stayA`'s trace).* `0 = s_pre`, `1 = s_now`, `2 = s_post`;
  `step : 0→0, 0→1, 1→2, 2→2`. Labels: `now` true only at `1`; `atom p` false, `Fp` false,
  `⊤` true, `bot` false at all three.
- *Gadget 2 (`Fin (L + 3)`, realizing `jump w` for `t ≤ w ≤ t + L`).* `0 = j_pre`, `1 = j_now`,
  `2 … L+1 = j_mid_1 … j_mid_L`, `L+2 = j_post`; `step : 0→0`, `0→1`, `i→i+1` for `1 ≤ i ≤ L+1`,
  `i→L+2` for `1 ≤ i ≤ L+1`, `L+2→L+2`. Labels: `now` true only at `1`; `atom p` true exactly at
  `L+2`; `Fp` true everywhere; `⊤` true, `bot` false.
- No step crosses the two summands.

`IsRun lab step (clNow Fp) t ρ` forces `lab (ρ z) (clNow Fp) = true ↔ z = t`, i.e. `ρ t ∈ {inl 1, inr 1}`,
which pins everything: the only predecessor of `inl 1` is `inl 0` and of `inr 1` is `inr 0`, and
each is its own only predecessor, so `ρ` is constant-`pre` on `(-∞, t)`; forward, gadget 1 admits
one continuation and gadget 2 admits exactly `L + 1` (leave the mid chain after `l` steps,
`0 ≤ l ≤ L`), absorbing at `post`. Run traces are therefore exactly `stayA`'s trace and
`jump (t + l)`'s trace for `0 ≤ l ≤ L` — i.e. `S_L`. A run that never reaches `now` is excluded by
`IsRun`'s own `↔`, which is why no acceptance condition is needed.

Note what this presentation deliberately does NOT satisfy: it is not `Presented` (it realizes only
finitely many of the seam's traces), consistent with `Probe735.not_presented`. The two results sit
side by side without tension.

**4. `lab` may be noncomputable, and that removes the only real encoding risk.**
`hitOf` is a `Finset` but `HitPresented` is a proposition about it; nothing requires `lab` to be
computable. Two viable encodings, in preference order:
(a) an explicit three-flag table `labOf (pF FpF nowF : Bool) : (clSig Fp).preds → Bool` dispatching
on the four closure members (the alphabet is five letters; `(plusSubformulaClosure Fp).card = 4`
was `#eval`-confirmed), with a four-case lemma tying it to `clTrace`;
(b) `lab q ℓ := decide (clTrace MA Fp t (σ q) ℓ (zOf q))` under `Classical.dec`.
(a) is recommended: it keeps the axiom foot minimal and makes the run-trace lemma a rewrite.

**5. Where the bound dies, named exactly.** `L` above comes from `Set.Finite.bddAbove` applied to
`HitCl`, whose finiteness comes from `finite_family_triples` — i.e. from the cardinality of
`KType (clSig Fp) k`, which is `Bool`-valued on depth-`k` normal forms. The argument is
**non-constructive in a way no bookkeeping repairs**: it never exhibits `L`, so it yields no
bound, not even a non-elementary one, and not even on the fixture. The missing ingredient is an
*effective* statement that a long block's `k`-type is already attained by a short one. The tree
has the composition congruence `kTypeOf_listSeg_append_congr` (verified) — which makes
`m ↦ kTypeOf sig k (listSeg (ℓ ::ₘ … m times))` a morphism into a finite semigroup, so eventual
periodicity with threshold + period `≤ card (KType sig k)` is *mathematically* available — but it
has **no eventual-periodicity or threshold lemma** (searched: `KTypeSummary/Saturation.lean`
contains only `kTypeColouring_eq_of_matching_segments`, `kEquiv_zFiber_of_matching_segments`,
`kTypeOf_zFiber_eq_of_sameTriple`, `kTypeOf_zFiber_eq_of_inFamily` — all about ℤ-fibres of a
*given* factorization, none about block length). Medium confidence on this negative claim
(grep-tier, per the announced evidence tier).

**6. The fixture result does not generalize — the honest boundary.** Model A's splices are
eventually constant in both directions (backward into `a` is rigid; forward, `b` absorbs), which
is precisely why a finite presentation can realize finitely many of them *exactly*. For a general
regular ℤ-model the seam's splices are arbitrary step paths and their closure traces are arbitrary
colourings, not ultimately periodic. The general route would instead build one **lasso** per
triple — `word(τneg)^(ω*) · word(τzero) · word(τpos)^ω` using a factorization's segment
representatives (`PathEntry.rep` already stores such a representative) — where `⊇` follows from
the composition congruence but `⊆` requires that **no spurious factorization of a lasso** yields a
triple outside `HitCl`. That is open and is the real content of general (C).

### External Resources

- No web or literature source was consulted. The `<literature-briefing>`'s most relevant entry
  for this task's vocabulary is `hodkinson_wolter_zakharyaschev_2000_decidable_fragments_fotl`
  (quasimodel = time-sliced certificate, splice lemma = pumping, periodic state function with
  bounded period = tail-stability), which the library docstrings already cite; it is flagged
  `[UNVERIFIED - unverified_summary]` in the briefing and nothing here rests on it.
- cslib (`~/Projects/cslib/`) was not consulted: nothing in this analysis needed a Ramsey or
  ω-automata port, and the constraint is read-only regardless.

### Recommendations

A sorry-free path exists. Recommended phasing, each phase one agent run (H8), each ending green
and committed (H9):

| Phase | Content | Est. lines | Risk |
|---|---|---|---|
| 1 | `HitPresented` + `hitPresented_of_presented` into `Trace.lean` beside `Presented` (the definition is general and belongs in the library; both already compile) | 15 | LOW |
| 2 | Model-A step-path classification into a new wired probe: `stepA`, `time_eq`, `bwd_a`, `fwd_dichotomy`, `fwd_absorb`, `path_classify` | ~100 | LOW (already compiled) |
| 3 | Splice→history identification: `spliced stayA t bf = stayA ∨ ∃ w ≥ t, spliced stayA t bf = jump w`, via `pathFibreEquiv`/`seamOmegaEquiv` and `WorldHistory.ext_state`; then trace equality via `clTrace_letter` on the four closure members | 80-120 | LOW-MEDIUM |
| 4 | The truncation bound: `hitCl_finite` → per-member witness → offset → `Set.Finite.bddAbove` → `L`, and `HitCl = ⋃_{σ ∈ S_L} familyTriples (clTrace … σ)` | 60-100 | MEDIUM (choice/`Finset.sup` bookkeeping) |
| 5 | The presentation: `Q := Fin 3 ⊕ Fin (L + 3)`, `labOf` table + its four-case `clTrace` lemma, `step`, and the run characterization (`IsRun` pins `ρ` both directions) | 200-300 | MEDIUM-HIGH |
| 6 | Assembly `hitPresented_modelA : ∀ k, 1 ≤ k → HitCl MA stayA t Fp k = ↑(hitOf lab step (clNow Fp) k)`; `#print axioms` foot; wire into `scripts/check-evidence-probes.sh`; pins in `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`; theorem-index row stating what it does and does not deliver; the recorded bound verdict | 100-150 + docs | LOW-MEDIUM |

**`file_scope` to set at plan time** (deliberately absent from the record; expect overlap with
tasks 733, 734, 739):
`FormalSystem/Metalogic/Decidability/RaySummary/Trace.lean`;
`specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean` (new);
`scripts/check-evidence-probes.sh`;
`Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`;
`FormalSystem/Metalogic/Decidability/RaySummary/README.md`.

**On the bound half.** Do not attempt it in the same batch. The acceptance criterion's third
branch is the reachable one, with one scope note stated plainly: **a negative bound claim cannot
literally be "machine-checked"** — non-existence of a computable bound is not a Lean-statable
property of the development. What CAN be machine-checked, and is what this report recommends
recording, is (i) that the landed satisfiability theorem's axiom foot carries `Classical.choice`
and exhibits no `B`, and (ii) a stated-but-unproved **Challenge signature** for the missing
effective lemma, so the gap is a named obligation rather than prose. Suggested shape:

```
theorem kTypeOf_listSeg_replicate_eventually_periodic (sig) [Fintype sig.preds] (k : ℕ)
    (ℓ : sig.preds → Bool) :
    ∃ m₀ p, 0 < p ∧ ∀ m, m₀ ≤ m →
      kTypeOf sig k (listSeg (List.replicate (m + p) ℓ))
        = kTypeOf sig k (listSeg (List.replicate m ℓ))
```
provable from `kTypeOf_listSeg_append_congr` + `kType_finite` (finite-semigroup idempotence).
This is the single lemma that converts the whole route from non-constructive to effective, and it
is the right unit of work for a successor record.

**Never write** "L⁺ is decidable" unqualified, and do not let the positive outcome drift into a
decidability claim: (C) alone does not deliver `Decidable (PlusValidZTime φ)` — the verdict records
that (C) and (S) together still speak of one seam and that lifting to validity is (W).

---

## Decisions

- **D-1: Report `HitPresented` as SATISFIABLE-looking rather than refuted, and recommend the
  construction.** The dispatch gave a refutation equal standing as a complete outcome; the
  analysis points the other way and the report follows the analysis, not the cheaper outcome.
- **D-2: Recommend the truncation route over the rectangular-liveness route.** `mem_hitOf_iff`
  (run-existence form) needs no `pathTypes`/`fwdLiveSep` reasoning at all, while
  `mem_hitOf_iff_live` would require computing `pathTypesNow`, `bwdLiveSep` and `fwdLiveSep` for
  the gadget and characterizing `HitCl`'s triples as a union of rectangles. Both are sound; the
  first is strictly less work and touches no `KType` evaluation.
- **D-3: Do not characterize `HitCl`'s triples at all.** An earlier line of analysis derived that
  at `k ≥ 1` the seam anchor must lie in the middle segment (via `exists_interp_iff_of_kTypeOf_eq`)
  and that `HitCl` is a union of two rectangles over pairwise-disjoint type sets. That derivation
  is believed correct but is **not needed** by the recommended route and is recorded here only as
  orientation, not as a claim the plan should depend on.
- **D-4: `lab` as an explicit `labOf` table rather than a `decide`-of-`clTrace`.** Keeps the axiom
  foot minimal; the alphabet is four closure letters plus `now`, so the case analysis is small.
- **D-5: Treat the bound half as a separate record, and record the non-existence limitation
  explicitly rather than claiming a machine-checked impossibility.** See Recommendations.
- **D-6: State the fixture result's non-generality in the landed probe's header**, not only here —
  model A's eventually-constant splices are what make the construction work, and the lasso route
  for general models has an open `⊆` direction.
- **D-7: Keep `Present.lean`'s `fwdLive`/`bwdLive` out of the analysis entirely.** The dispatch's
  warning is confirmed: `hitOf` reads `fwdLiveSep`/`bwdLiveSep` (disjoint segments joined by one
  step). The shared-endpoint graph was not reintroduced anywhere.

---

## Adversarial Self-Verification

Every load-bearing claim below was re-challenged after the main analysis. `Verification Method`
uses the lean4 domain values; because the lean-lsp tools were unavailable, `compiled #check` /
`compiled proof` stand in for `lean_hover_info`-confirmed signatures and are a stronger tier,
while `grep sweep` marks the weaker tier the readiness context says to announce.

| Claim | Source / Counterexample considered | Verification Method | Confidence |
|---|---|---|---|
| `HitPresented` is not a declaration in this tree | repo-wide grep: all hits in `specs/**` prose only | grep sweep (no LSP index available) | Medium |
| `HitPresented` is statable at the right type, and `Presented → HitPresented` holds | counterexample sought: an instance/universe mismatch between `Set (KType …)` and `↑(Finset …)` — none; it compiles | compiled proof (`hitPresented_of_presented`, axioms `[propext, Classical.choice, Quot.sound]`) | High |
| `mem_hitOf_iff` converts `hitOf` into "∃ anchored run whose trace has the triple" | challenged: does it need `1 ≤ k`? Yes — carried everywhere below | compiled `#check` | High |
| `hitCl_finite` holds unconditionally on the model | challenged: is finiteness of the *realized* part being assumed? No — it comes from `finite_family_triples` (the whole product is finite), read in source | bounded source read + compiled `#check` | High |
| Every seam splice on model A is `stayA` or `jump w` with `w ≥ t` | challenged three ways: (i) could the time component drift? No — `ofSlicedStep_step` pins `q.1 = p.1 + 1`; (ii) could the unused third slice state `2 : Fin 3` be entered? No — `RA t u 2` forces `u = 2`, and `(g t).2 = a ≠ 2`; (iii) could the backward ray leave `a`? No — `RA t u a` forces `u = a` | compiled proof (`Probe745.path_classify`, zero errors, zero warnings) | High |
| The pumping obstruction does not transfer to the Hit level | challenged: can `presented_localRun` be recovered from `HitPresented`? Its proof uses the trace-set equality in both directions, which `HitPresented` does not provide; and the realization demand becomes finite by `kType_finite`, so the pigeonhole premise ("arbitrarily long `p`-false stretches must be realized") fails | bounded source read of `Presented`, `presented_localRun`, `Probe735.not_presented` + compiled `#check` of `kType_finite` | High |
| The `L + 6`-state presentation's anchored runs have exactly the `S_L` traces | challenged: (i) a run stuck at `pre` forever — excluded by `IsRun`'s `↔` at `z = t`; (ii) a run crossing gadgets — no cross steps; (iii) a run looping in the mid chain — `Fin (L + 3)` has no back edges, `post` absorbs | hand proof against compiled `IsRun`/`runTrace` signatures; **not yet compiled** | Medium |
| The construction yields no computable bound | challenged: could `L` be read off `card (KType (clSig Fp) k)` instead? Only with an effective threshold lemma; `Saturation.lean`'s four declarations are all about ℤ-fibres of a given factorization, none about block length | bounded source read of `Saturation.lean` + grep sweep for a threshold/periodicity lemma | Medium |
| `kTypeOf_listSeg_append_congr` is the entry point for an effective bound | challenged: does it require `DecidableEq sig.preds`? No — that binder was explicitly removed; it needs `[Fintype sig.preds]` only | bounded source read + compiled `#check` | High |
| `Set.Finite.bddAbove` applies over `ℤ` | challenged: its `[IsDirectedOrder α] [Nonempty α]` binders | compiled `#check` | High |
| `(clSig Fp).preds` has five letters (four closure members + `now`) | — | `#eval` of `(plusSubformulaClosure Fp).card` and of the member list | High |
| The fixture result does not generalize to arbitrary regular ℤ-models | challenged: does the truncation argument use anything beyond `hitCl_finite`? Yes — it needs the finitely many witnessing traces to be *exactly realizable* by a finite presentation, which uses model A's two-sided eventual constancy | reasoning over the compiled classification; no counterexample construction attempted | Medium |

**Contradiction Log.**

1. **`Probe735.not_presented` vs. this report's positive reading — RESOLVED, no contradiction.**
   The probe refutes an equality of *trace sets* for every finite presentation; the recommended
   presentation indeed fails `Presented` (it realizes only `S_L`, not every `jump w`). Both hold
   simultaneously, which is exactly the `Presented`/`HitPresented` separation this task exists to
   settle. Precedence: the probe is machine-checked and is not weakened by anything here.
2. **Task 735's report ("Low confidence that `HitPresented` is satisfiable") vs. this report's
   assessment — RESOLVED in favour of this report, with the reason named.** 735 reasoned from the
   *forward type* observation alone (the pumped limit's `τpos` differs from every seam trace's).
   That argument shows the pumping refutation fails but gives no positive construction, hence the
   low confidence. The present report adds the construction and, crucially, the observation that
   the realization demand is finite by `kType_finite`, so no unbounded stretch is required.
   Precedence ranking: a compiled artifact outranks a prior report's confidence estimate; the
   compiled part here is the classification and the signatures, not the full assembly, so the
   claim is carried as "satisfiable-looking, construction specified" and Phase 5's run
   characterization is the one Medium-confidence link.
3. **Dispatch acceptance branch 3 ("the obstruction machine-checked, not argued") vs. what is
   provable — UNRESOLVED CONTRADICTION, stated rather than smoothed over.** A claim that *no*
   computable bound exists is not a Lean-statable property of this development, so it cannot be
   machine-checked in the sense the other two branches use. Downstream risk: a successor dispatch
   could try to satisfy branch 3 literally and either stall or land a true-looking name over a
   proof that does not reach it — precisely the defect task 737 was filed to find. The resolving
   check not yet performed: whether the user accepts the substitute (axiom foot + stated Challenge
   signature for the effective-saturation lemma) as discharging branch 3. Recorded as a
   non-blocking `user_decision`.

**Recommendations modified after verification.** Two. (i) The route was switched from the
rectangular-liveness characterization to the run-existence form of `mem_hitOf_iff` once it became
clear the former forces a full `HitCl` triple characterization (D-2/D-3) — this cut the estimate
by several hundred lines. (ii) The bound half was downgraded from "attempt after phase 1" to
"separate record with one named Challenge lemma", after the verification step established that the
truncation proof is non-constructive by construction rather than incidentally.

---

## Tactic Survey Results

Two scratch files were compiled against the live build (`lake env lean`, build artifacts present
and current). Goal states were read from compiler output only; no raw goal dumps are reproduced.

| Target | Tactic / route tried | Result | Notes |
|---|---|---|---|
| `HitPresented` definition + `Presented → HitPresented` | `hit_eq_hitOf_of_presented M τ t φ lab step k hk hP` | **PASS** | three-line term proof; `#print axioms` = `[propext, Classical.choice, Quot.sound]` |
| time component pinned: `∀ z, (g z).1 = z` | `Int.induction_on` with case names `zero`/`succ`/`pred` | **PASS** | first attempt used `hz`/`hp`/`hn`; this Mathlib pin requires `zero`/`succ`/`pred` |
| backward rigidity `∀ z ≤ t, (g z).2 = a` | `Nat` induction on `t - n` + `push_cast` before the `rw` | **PASS** | ordering matters: `push_cast at h ih ⊢` must precede the `show … by ring` rewrite, else the pattern `t - (↑i + 1) + 1` is absent |
| forward dichotomy / `b`-absorption | `Nat` induction on the `RA` disjunction | **PASS** | `absurd h ab_ne` with `ab_ne : a ≠ b` by `decide` |
| full classification `(∀ z, g z = (z,a)) ∨ ∃ w ≥ t, …` | `by_cases` on `∃ n, (g (t+n)).2 = b`, `Nat.find` + `Nat.find_min`, `Prod.ext`, `omega` for all index arithmetic | **PASS** | zero errors, zero warnings; `simp only [not_exists]` in place of the deprecated `push_neg` |
| `variable (hg : IsStepPath FA g)` auto-inclusion | — | **FAIL** | this toolchain does not auto-include a propositional `variable` in theorem bodies; hypotheses were made explicit per theorem |

Total compiled: ~100 lines of fixture-specific proof plus ~35 `#check`/`#eval`/`#print axioms`
probes, all green.

---

## Context Extension Recommendations

- **Topic**: `k`-type block saturation / eventual periodicity.
  **Gap**: the tree has the composition congruence (`kTypeOf_listSeg_append_congr`) but no lemma
  turning it into a length threshold, which is the single blocker between a non-constructive
  satisfiability result and a computable bound. Nothing in
  `context/project/lean4/**` records that this gap exists or where its entry point is.
  **Recommendation**: add a short note under `context/project/lean4/domain/` naming
  `kTypeOf_listSeg_append_congr` as the entry point and the finite-semigroup idempotence argument
  as the route, so a successor dispatch does not re-derive it.
- **Topic**: evidence tier when lean-lsp is registered but its tools are not exposed.
  **Gap**: the dispatch's `<lean-readiness-context>` covers `index: unavailable|warming|consulted`
  but not "server reachable, tools absent from the agent's tool surface", which is what happened
  here. The fallback (compiled `#check` via `lake env lean`) is a *stronger* tier for positive
  claims and a *weaker* one for negative claims, and that asymmetry is not written down.
  **Recommendation**: extend `context/project/lean4/patterns/mcp-fallback-table.md` with a
  "tools absent" row and the positive/negative asymmetry.

---

## Appendix

**Compiled scratch files** (not part of the repository; reproduce with `lake env lean <path>`):
- `/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/9b704637-8466-49f5-bdeb-3bd3ef0521bb/scratchpad/verify745.lean`
  — 31 `#check`s of the substrate, the `HitPresented` definition, `hitPresented_of_presented`,
  `#eval` of the closure alphabet, `#print axioms`.
- `/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/9b704637-8466-49f5-bdeb-3bd3ef0521bb/scratchpad/rigid745.lean`
  — `Probe745.{stepA, time_eq, bwd_a, fwd_dichotomy, fwd_absorb, path_classify}`, zero errors and
  zero warnings. **Phase 2 should transcribe this file.**

**Searches performed** (all `grep`/`sed`-tier plus compiled probes; no rate-limited search tool was
reachable):
- `HitPresented` across `--include=*.lean --include=*.md` (repo-wide)
- declaration listings of `RaySummary/{HitOf,Trace,Closure,Present,Seam,StabCheck,Compose,SeamMulti}.lean`
- declaration listings of `KTypeSummary/{Basic,Family,Saturation,KTypeFin,Segment}.lean`
- `InFamily`, `SegmentFactorization`, `doets_lemma`, `KEquiv`, `EquivAt`, `IsStepPath`,
  `ext_state`, `someFuture`, `plusSubformulaClosure`, `def top`
- Mathlib: `Set.Finite.bddAbove`, `Set.Finite.toFinset`, `Finset.sup` (by `#check`)

**Line-drift observations** (the dispatch's anchor warning, confirmed):
`presented-not-complete.lean` is 292 lines, not the 246 the record cites; every declaration above
was resolved by name and none by a cited line.

**Not established by this report.** Nothing about `⊡(Pp)`: the fixture is forward-only and there
is still no backward Bool-fixture bridge (the backward side is fixed only by
`Probe719Backward.pastStab_iff_allBwdPathsMeet` on the asymmetric fixture), so this is a
forward-only result and says so. Nothing about models with infinite slices beyond the fixture's own
shape. No complexity bound, upper or lower. No decidability of anything, and in particular
`Decidable (PlusValidZTime φ)` is not stated here in any form. `HitPresented` is **not yet
established** — phase 5's run characterization is the one uncompiled link in the chain, and the
report's claim is "satisfiable-looking with the construction specified", not "satisfiable".
