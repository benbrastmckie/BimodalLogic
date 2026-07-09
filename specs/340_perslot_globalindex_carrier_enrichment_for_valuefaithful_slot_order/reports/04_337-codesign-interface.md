# Report 04 — Task-337 Builder + Co-Design Interface (Agent C)

**Task**: 340 — per-slot global-index carrier enrichment; **Agent C role**: task-337 realization
engine + the 340↔337 interface contract.
**Mode**: RESEARCH / VERIFY-ONLY (no edits). All load-bearing claims are grounded in exact
`file:line` source reads (H3).
**Territory**: `SubBracket2V.lean` `k1v_sorted_realizationK` + neighbors; `SharedWitness.lean`
honest bundles / disjunct / bracketN / global-index layer; prior 337 reports 04/06 and plans 02/03.
I do NOT re-derive Rabinovich faithfulness (Agent A) or the SharedWitness carrier-enumeration
internals (Agent B).

---

## Reference Grounding (Tier 3 — implementation-backed; extends landed Lean carrier)

| Source | Location | Lean Identifier | Type Signature (verified) | Status |
|---|---|---|---|---|
| Region engine | `SubBracket2V.lean:633-646` | `k1v_sorted_realizationK` | `(M) (regions : List (M.carrier × M.carrier × List (NF 0 1))) (hpos) (hlink) (hnd) (hreal) → ∃ ps, Forall₂ … ∧ (interleaveK ps).Pairwise (·<·)` | Verified (read) |
| Interleave | `SubBracket2V.lean:453-457` | `interleaveK` | `List (carrier × carrier × List (β × carrier)) → List carrier` | Verified |
| Honest bundle L | `SharedWitness.lean:1471-1504` | `kvE2_sepHonestBundleL` | `… → ∃ x1, x<x1 ∧ x1<w ∧ (∀χ∈zXU, ∃u, x<u<x1 ∧ eval) ∧ (∀χ∈zUW, ∃u, x1<u<w ∧ eval)` | Verified |
| Honest bundle R | `SharedWitness.lean:1523-1565` | `kvE2_sepHonestBundleR` | mirror in `(w,t)` around a `(w,x1,t)` anchor | Verified |
| Global index | `SharedWitness.lean:921-928` | `kvE2_sepSlotGIdx` | `(wo) (s) → ℕ` (owner tuple read at slot's region rank) | Verified |
| Merge key | `SharedWitness.lean:936-938` | `kvE2_sepSlotMergeLe` | `(wo) (a b) → decide (GIdx wo a ≤ GIdx wo b)` (single-level) | Verified |
| Merged slots | `SharedWitness.lean:949-957` | `kvE2_sepSlotsLOf/ROf` | `(wo) → List KvE2SepSlot` (`flatMap … |>.mergeSort mergeLe`) | Verified |
| .holds obligation | `SharedWitness.lean:1104-1114` | `kvE2_sepBody_holds_iff` | `.holds ↔ ∃ wo ∈ kvE2_sepArr', (kvE2_sepDisjunct … (SlotsLOf wo) (SlotsROf wo)).2.holds` | Verified |
| Bracket shape | `SharedWitness.lean:602-608` | `kvE2_sepBracketN` | `pointTypes = lL ++ ptW :: lR`; ONE interior distinguished slot | Verified |
| k=3 bracket match template | `SubBracket2V.lean:807-819` | (inline `holds_eq_succ` use) | witnesses `= usXU ++ x1 :: usUW ++ w :: usWT`, monotone → `.holds` | Verified |

---

## Q1 — `k1v_sorted_realizationK` input/output contract (H3: quoted)

**Signature** (`SubBracket2V.lean:633-646`, verbatim shape):

```lean
theorem k1v_sorted_realizationK {sig} (M : OrderedMonadicStructure sig)
    (regions : List (M.carrier × M.carrier × List (NormalForm sig 0 1)))
    (hpos  : ∀ r ∈ regions, r.1 < r.2.1)                       -- each region non-degenerate (lo<hi)
    (hlink : List.Chain' (fun a b => a.2.1 = b.1) regions)     -- boundary-linked: hiᵢ = loᵢ₊₁
    (hnd   : ∀ r ∈ regions, r.2.2.Nodup)
    (hreal : ∀ r ∈ regions, ∀ χ ∈ r.2.2, ∃ u, r.1 < u ∧ u < r.2.1 ∧ nf_eval_nf M 0 1 (fun _=>u) χ) :
    ∃ ps : List (M.carrier × M.carrier × List (NormalForm sig 0 1 × M.carrier)),
      List.Forall₂ (fun p r => p.1=r.1 ∧ p.2.1=r.2.1 ∧ Perm (p.2.2.map .fst) r.2.2 ∧
        (p.2.2.map .snd).Pairwise (·<·) ∧ (∀ q∈p.2.2, (r.1<q.2 ∧ q.2<r.2.1) ∧ eval)) ps regions ∧
      (interleaveK ps).Pairwise (· < ·)
```

**What it consumes**: a list of **fixed, boundary-linked anchor regions** — a SINGLE linear anchor
chain `a₀ < a₁ < … < a_k` (encoded as `[(a₀,a₁,S₀), …]` with `hlink : hiᵢ = loᵢ₊₁`), where each
region's type list is realized **strictly interior** to that region (`hreal`).

**What it produces**: per-region point lists `ps` (mirroring the region skeleton), and — the payload
337 wants — `(interleaveK ps).Pairwise (· < ·)`: **one globally strictly-monotone chain** whose
`interleaveK` stitches per-region block points, separated by the interior anchors (`interleaveK`
def :453-457 puts `blk.map snd ++ sep :: …`, `sep` = each region's `hi`).

**Decisive answer**: the engine already emits a globally monotone interleaved sequence, **but only
after** it is handed a single boundary-linked anchor chain. It does **not** itself merge multiple
owners. Turning per-owner honest data (each owner has its OWN independent anchor `x1_σ`, Q5) into one
`hlink`-satisfying chain in model order **is exactly the cross-owner merge that 340's global index
encodes**. So: engine = the monotone-sequence realizer; 340's per-slot index = the missing structural
input (the merged anchor chain) the engine's `hlink`/`hreal` preconditions demand. The engine is
**already landed and green** (regression `k1v_sorted_realizationK_regress_k3` :664 passes), so it is a
shared consumable, not something 337 must build.

---

## Q2 — Is the deferred lemma the right interface?

Implementer's proposed contract: `∃ wo ∈ kvE2_sepArr' qnf, kvE2_sepSlotsLOf wo is monotone in M`.

**Verdict: right DIRECTION, but under-specified — must be strengthened.** Two problems:

1. **"monotone in M" is ambiguous and too weak.** 337 does not consume an abstract "the index order
   is monotone" property; via `kvE2_sepBody_holds_iff` (:1104-1114) → `holds_eq_succ` it must exhibit
   a concrete strictly-increasing `witnesses : Fin n → M.carrier` **with each slot's type realized at
   its assigned value** and matched to `kvE2_sepBracketN`'s point types (:602-608). "∃ monotone wo"
   asserts existence of an order; it does not hand over the realized value assignment.

2. **The genuinely useful object is the engine's precondition (or output) bundle, not a predicate.**
   What 337 can immediately use is precisely `k1v_sorted_realizationK`'s inputs for
   `kvE2_sepSlotsLOf/ROf wo`: a boundary-linked region decomposition (`hpos`,`hlink`,`hnd`,`hreal`) in
   genuine M-value order — or, packaged, the engine OUTPUT `∃ ps, Forall₂ … ∧ interleaveK monotone`.

**Corrected interface** (verdict (b) below): the lemma must deliver `wo ∈ kvE2_sepArr'` **plus** a
realized, value-ordered decomposition of `kvE2_sepSlotsLOf/ROf wo` that satisfies the engine's four
hypotheses. That is the difference between "a monotone order exists" and "here is the realizer."

---

## Q3 — Merge vs. keep-separate (with circular-dependency analysis)

**Recommendation: KEEP-SEPARATE, with a strengthened, bracket-independent interface** (a light
re-scope, not a fold).

**(a) No circular dependency exists.** The apparent cycle ("340-P5 needs the monotone wo; 337 needs
it too") is a **shared subgoal**, not a cycle. A cycle would require 340-P5 to consume something 337
produces. 337 produces `kvE2_sepDisjunct … .holds`; 340-P5's "value-faithful completeness witness" is
about the global index equalling model value order — logically **prior to and independent of** `.holds`
and of the bracket. So the dependency is linear `340-P5 → 337`. Moreover the shared heavy machine,
`k1v_sorted_realizationK`, is **already green** (:633), so neither task builds it; both consume it.

**(b) Cleanest single owner of "select honest wo + prove monotone-realizable."** This step is pure
carrier/model reasoning (honest bundles, `kvE2_sepArr'`, `kvE2_sepCoincidentOrder` all live in
`SharedWitness.lean`) and is **bracket-independent**. It belongs in `SharedWitness` as 340's Phase-5
deliverable. Keeping it there preserves the natural boundary at the engine's type signature: 340
produces the engine's INPUTS (value-order-realized region data); 337 runs the engine and matches its
OUTPUT to `kvE2_sepBracketN`.

**Why NOT fold** (this is where the 340↔337 boundary differs from the failed 339→337 one): the 339
handoff was fragile because its interface was an *abstract 2-level key* with **no realizability
content** — 337 could not tell if the order was model-realizable until it tried, and it wasn't
(report 06 Experiment B). The 340 interface, by contrast, is anchored to a **concrete, type-checked,
bracket-independent boundary** — `k1v_sorted_realizationK`'s signature. As long as 340 delivers "wo +
the engine's four hypotheses in model order," the shape is stable and validatable in isolation, so a
task boundary is safe here where it was not before.

**One carve-out already satisfied:** the engine INVOCATION and the `interleaveK ps → kvE2_sepBracketN`
point-type match must stay in 337, because the region decomposition has to be sliced to align with the
bracket's `lL ++ ptW :: lR` split (:602-608) — a bracket-dependent choice. 340 should therefore stop
at the **value-ordered realized slot data** (the engine inputs / raw sorted `(slot, value, proof)`
triples), NOT run the engine itself.

**Escalation clause:** if 340's planner finds the region decomposition cannot be stated without
reference to `kvE2_sepBracketN`'s `lL/ptW/lR` split, THEN fold 340-P5 into 337. Default is
keep-separate because the honest→value-order bridge provably needs no bracket data (Q5).

---

## Q4 — What 340's enriched carrier now gives 337 that it lacked

**Before (339, region-primary 2-level key).** `kvE2_sepSlotMergeLe` was `(region, ownerRank)`
lexicographic with region PRIMARY. A region-2 slot (`lUW`) could never precede a foreign region-1
slot (`lX1`). For the honest below-anchor model `a < u < b` (σ's `lUW` witness `u` below τ's anchor
`b = x1_τ`), the forced list order was `a < b < u`; report 06 Experiment B derives `False` by `omega`.
Hence for that honest input **no monotone witness existed over the fixed 339 order** — 337 had no
tractable path, regardless of `wo` (Experiment C: rank-independent).

**After (340, single global index).** `kvE2_sepSlotGIdx wo s` (:921-928) is a single ℕ per slot;
`kvE2_sepSlotMergeLe` collapses to a one-level compare (:936-938); `kvE2_sepSlotsLOf/ROf` mergeSort by
it (:949-957). Region rank is **no longer primary** — the committed example at :1026-1034 documents a
region-2 slot receiving a strictly smaller index than a foreign region-1 anchor. The enumeration
`kvE2_sepArr'` now ranges over order-consistent **global interleavings** of individual slots (via
`kvE2_sepIdxTuples`, :734).

**The specific new capability 337 consumes:** the merged order `kvE2_sepSlotsLOf wo` can now equal
**any order-consistent interleaving of the union of all owners' points, including cross-region ones**.
Therefore for a given honest model there EXISTS a `wo` whose slot-list order equals the true model
value order — i.e. a single linear anchor chain in model order. That is precisely
`k1v_sorted_realizationK`'s `hlink`+`hreal` precondition, which was unsatisfiable under 339. 337
consumes it by: pick that `wo`, read off the value-order region decomposition (Q2/Q3), feed the
engine, match the output to `kvE2_sepBracketN`. **Membership plumbing survives** (`mergeSort_perm`):
`kvE2_sepSlotsLOf_mem`/`ROf_mem` (:1007-1024) and `kvE2_sepBody_extract` (:2321-2349) still hold, so
the ⇒-direction is undisturbed.

---

## Q5 — Honest-bundle extension: scope

**Current state** (`kvE2_sepHonestBundleL` :1471-1504; `R` :1523-1565): each positive owner σ is
extracted **independently** (`kvE_subBracket2_complete_extract σ` per owner). The bundle yields σ's
fresh anchor `x1` with `x < x1 < w`, and for each region 1-type a witness `u` bounded ONLY
**intra-owner** (`x < u < x1` for zXU; `x1 < u < w` for zUW). There is **no** relation between σ's
points and any other owner τ's anchor/witnesses.

**What a value-faithful global index needs:** the RELATIVE model order of DIFFERENT owners' points
(e.g. is σ's `lUW` witness below or above τ's anchor `x1_τ`) so the global index can equal model
value order.

**Scope of the extension — small, and derivable from M (no new model data, no axioms):**

- `OrderedMonadicStructure.carrier` carries a **LinearOrder** (the engine uses `lt_trichotomy`,
  `lt_asymm`, e.g. `SubBracket2V.lean:2397`). So `<` already **totally orders** the entire union of
  extracted points. The cross-owner comparisons are therefore **free** — no new witnesses required.
- What is genuinely missing is a **packaging/aggregation lemma**, not new data: (1) run the per-owner
  bundle for every σ ∈ `kvE2_sepPos qnf`; (2) collect all `(slot, carrier-value, realization-proof)`
  triples (each owner's `x1_σ` and each region witness `u`); (3) sort the union by M's `<`; (4) prove
  the sorted order **extends each owner's region order** (holds because within an owner
  `x < x1_σ` and the region bounds are respected) and hence **defines a `wo ∈ kvE2_sepArr'`** whose
  `kvE2_sepSlotGIdx` reproduces the sort.
- The extension does NOT change the bundles' witness content; it adds a cross-owner **collect + sort +
  linear-extension** lemma over the existing per-owner outputs. This is exactly the "value-faithful
  completeness witness" of 340 Phase 5, and it is **bracket-independent** (confirming Q3's boundary).

**One caveat for the planner:** the aggregation must respect the coincidence semantics — in the honest
arrangement each owner's fresh type is realized AT its anchor `x1_σ` (closed self-zone bit forced,
`kvE2_sepCoincidentAnchor_discharge` :1610-1620; `kvE2_sepCoincidentOwner_valid_left` :1703-1734), so
anchors are **type-carrying interior points**, not pure separators. The sort must place each `x1_σ` as
a genuine point in the merged chain (an element of `lL`/`lR`), with `w` remaining the single
distinguished `ptW`. This is what forces the engine invocation + bracket slicing to live in 337.

---

## Adversarial Self-Verification (H4)

### Claim Verification Table

| Claim | Source / Counterexample | Verification Method | Confidence |
|---|---|---|---|
| `k1v_sorted_realizationK` consumes a boundary-linked (`hlink`) region chain, emits `interleaveK ps` monotone | `SubBracket2V.lean:633-646` | source read (quoted) | High |
| Engine is landed/green (consumable, not built by 337) | `k1v_sorted_realizationK_regress_k3` :664-708 compiles in-tree | source read | High |
| Honest bundles give per-owner independent `x1_σ`, only intra-owner bounds | `SharedWitness.lean:1471-1504`, `1523-1565` | source read | High |
| M.carrier is a LinearOrder (cross-owner order derivable, no new data) | `lt_trichotomy`/`lt_asymm` used at `SubBracket2V.lean:2397,2403` | source read | High |
| 340 index enables cross-region interleaving 339 forbade | `kvE2_sepSlotGIdx` :921-928, single-level `mergeLe` :936-938, example :1026-1034 | source read | High |
| .holds obligation = build over `SlotsLOf/ROf wo` | `kvE2_sepBody_holds_iff` :1104-1114 | source read | High |
| `kvE2_sepBracketN` has ONE distinguished interior slot (`ptW`), not per-owner separators | :602-608 | source read | High |
| Bracket-match must slice the merged chain to `lL/ptW/lR` (→ engine invocation belongs in 337) | :602-608 vs `interleaveK` multi-separator shape :453-457 | analytic (structural mismatch) | Medium-High |
| No circular 340↔337 dependency (shared subgoal only) | 337 produces `.holds`; 340-P5 is `.holds`-independent | analytic | High |

### Counter-argument (arguing the OPPOSITE of my keep-separate verdict)

*Opposite thesis: FOLD 340-P5 fully into 337 (make 340 deliver only the abstract index, 337 own
everything from wo-selection to `.holds`).* Supporting points: (i) the engine output `interleaveK ps`
does not map 1:1 onto `kvE2_sepBracketN`'s single-`ptW` layout — the region decomposition is
bracket-entangled, so the "bracket-independent boundary" is thinner than claimed; (ii) 337's plans
02 and 03 already tried to own the whole construction — folding matches the established shape;
(iii) report 06 §5 and the spawn analysis warn that "design the index" vs "implement/consume it" splits
recreate 339-style handoff friction, which argues for *fewer* boundaries, i.e. folding.

**Which wins, and why keep-separate (re-scoped) still wins:** The counter-argument correctly kills the
*naive* keep-separate (a standalone "∃ monotone wo" or a standalone full engine-invocation lemma) —
those ARE bracket-entangled. But it over-reaches: the **honest→value-order aggregation** (Q5) is
provably bracket-free (it only uses M's LinearOrder over extracted witnesses; no `kvE2_sepBracketN`
symbol appears). That sub-lemma is a clean, isolable 340 deliverable. The bracket-entangled part (engine
invocation + point-type match) I already assign to 337. So the correct verdict is neither "fold
everything" nor "hand 337 a finished monotone realizer," but the **re-scoped split**: 340 delivers the
bracket-independent value-ordered realized slot data (engine inputs); 337 owns engine + bracket. This
respects the counter-argument's valid core (don't put bracket reasoning in 340) while still extracting
the one genuinely separable, already-blocking piece (the honest cross-owner value order) as 340's
deliverable — which is exactly what unblocks 337.

### Contradiction Log

None unresolved. One nuance surfaced and resolved: whether the engine invocation belongs to 340 or
337. Resolved by the bracket-slice structural mismatch (`kvE2_sepBracketN` single-`ptW` vs
`interleaveK` multi-separator) — invocation belongs to 337; 340 stops at engine inputs.

### Recommendations modified after verification

The initial instinct ("340 hands 337 a finished monotone realizer via `k1v_sorted_realizationK`") was
**downgraded**: 340 should deliver the engine's *inputs* (value-ordered realized region data), not run
the engine, because the region-to-bracket slice is bracket-dependent. The "∃ monotone wo" proposed
interface was strengthened to carry the realized value assignment + wo-membership.

---

## VERDICT

**(a) Fold vs keep-separate:** **KEEP-SEPARATE (light re-scope).** 340 Phase 5 stays a standalone
`SharedWitness` lemma delivering the bracket-independent honest→value-order bridge; 337 owns the engine
invocation and the `kvE2_sepBracketN` point-type match. Do not fold — the boundary is anchored to
`k1v_sorted_realizationK`'s concrete type signature (a stable, realizability-bearing interface), unlike
the abstract 339 key that caused the prior handoff failure. Escalate to fold only if the region
decomposition cannot be stated without bracket symbols.

**(b) Exact interface lemma 337 needs from 340** (strengthen the implementer's proposal): for honest
`qnf` and honest model `(M, w, x, t, h)`,

> `∃ wo ∈ kvE2_sepArr' qnf`, together with, for both `kvE2_sepSlotsLOf wo` and `kvE2_sepSlotsROf wo`,
> a **boundary-linked region decomposition in genuine M-value order** satisfying
> `k1v_sorted_realizationK`'s four hypotheses (`hpos`, `hlink`, `hnd`, `hreal`) — equivalently, the
> aggregated `(slot, carrier-value, realization-proof)` triples sorted by M's `<`, with proof the
> order extends each owner's region order and induces this `wo`'s `kvE2_sepSlotGIdx`.

NOT the weak "∃ wo, `SlotsLOf wo` monotone" (order-existence only), and NOT the full `.holds` (that is
337). The `x1_σ` anchors must appear as type-carrying interior points (coincidence semantics), with `w`
the sole `ptW`.

**(c) Circular dependency:** **None.** 340-P5 → 337 is a linear dependency over a **shared subgoal**
(the model-order realizer). 340-P5 consumes nothing 337 produces; both consume the already-green
`k1v_sorted_realizationK`. Nothing to break — proceed with 340 Phase 5 (honest cross-owner value-order
aggregation), then `/implement 337`. The honest-bundle extension (Q5) is small and derivable from M's
LinearOrder: a collect + sort + linear-extension lemma over the existing per-owner bundles, adding no
new model data or axioms.
