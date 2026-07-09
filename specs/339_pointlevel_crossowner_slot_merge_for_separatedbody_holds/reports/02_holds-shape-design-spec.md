# Phase 1 Design-Spec Gate: `.holds`-shape validation for the point-level slot merge

- **Task**: 339 — Point-level cross-owner slot merge for separated-body holds
- **Phase**: 1 (design gate, NO code edits)
- **Status**: PASS (design captured; merge shape validated against `holds_eq_succ`; no design
  constraint violated). Proceed to Phase 2.
- **Sources read**: `ExistsForallNF.lean:106-204` (`.holds` / `holds_eq_succ`);
  `SharedWitness.lean` KvE2SepSlot (219-253), slot blocks (289-322), `kvE2_sepSlotLe` (455-463),
  weak-order carrier (700-750), `kvE2_sepOrderOwners`/`kvE2_sepSlotsLOf/ROf` (861-876),
  `kvE2_sepMem_orderOwners` (910-917), `kvE2_sepBody`/`_holds_iff` (933-988),
  `kvE2_sepBody_nonvacuous` (1512-1531), `kvE2_sep_index_lt_of_rank_lt` (1944-1958),
  per-owner slot-membership lemmas (1960-1994), `kvE2_sepDisjunct_extract` (2015-2105),
  `kvE2_sepBody_extract` (2163-2195).

## (a) EXACT structural shape `IntervalPattern.holds` requires of the slot list

`kvE2_sepDisjunct` builds one `BracketFormula` whose `pointTypes` list is the concatenation

```
lL.map kvE2_sepSlotType ++ (kvE2_sepPtW :: lR.map kvE2_sepSlotType)
```

with `n+1 = |lL| + 1 + |lR|` point types, and `.holds` reduces (via `holds_eq_succ`,
`ExistsForallNF.lean:188-204`, applied at `SharedWitness.lean:2040`) to the existence of ONE

```
witnesses : Fin (|lL| + |lR| + 1) → M.carrier
```

satisfying, over the FULL concatenated index set:

1. **global strict monotonicity**: `∀ i j, i < j → witnesses i < witnesses j` (line 194 / 117);
2. **range**: each `witnesses i ∈ (x, t)` (line 195);
3. **point types at witnesses**: `(pointTypes[i]).eval_at M atomMap (witnesses i)` (line 196);
4. the α/β segment obligations on the open intervals between consecutive witnesses (lines 197-202).

So the concatenated slot-list ORDER **is** the witness index order: index `i` in the list is
realized at `witnesses i`, and the witnesses are one globally strictly-increasing chain. This is
the single global chain over the union of points (Rabinovich Def 3.1, md:65-74). A list that keeps
each owner's points contiguous (block flatMap) cannot in general host such a global monotone
witness for interleaving honest models (report 04, rank-independent).

### What the 339 ⇒-extraction lemmas actually read off this shape

`kvE2_sepDisjunct_extract` (SW:2015) is the **⇒ (soundness) extraction**. Given `lL/lR` with
- `hmemL : ∀ σ ∈ pos, ∀ s ∈ kvE2_sepSlotsLFor σ, s ∈ lL` (each owner's own slots are present), and
- `hpairL : lL.Pairwise (kvE2_sepSlotLe · · = true)` (a supplied ordering fact),

it reads each owner σ's fresh slot at some index `iσ` and its `zXU` slot at `jχ`, and uses
`kvE2_sep_index_lt_of_rank_lt` (SW:1944) — which needs ONLY, for **same-owner** slots,
`rank a < rank b → index a < index b`, derived from `hpairL` — to place `jχ < iσ`. It never needs
adjacency, never needs cross-owner value facts, and never mentions `kvE2_sepSlotsLOf`. It is
**parametric over `lL/lR`**. Confirmed: statement AND proof preserved (Phase 3 is a re-verify).

The `.holds` **BUILDER** (⇐, `kvE2_sepBody_holds_iff.mpr`) — the direction that must actually
*construct* the global monotone witness and hence genuinely needs point-level interleaving — is
**task 337, explicitly out of 339 scope** (Non-Goals; Postmortem "Do NOT expand scope to 337's
builder"). `kvE2_sepBody_extract` keeps `hpairL/hpairR` as HYPOTHESES (SETTLED boundary); 339 does
NOT discharge them.

## (b) The point-level merge produces that shape and is Rabinovich-faithful

### Design: mergeSort of the block-flatMap union by a composite point-level key

```
kvE2_sepOwnerRank wo σ : ℕ          -- σ's merged-chain rank read from wo (338's rank, as-is)
kvE2_sepSlotMergeLe wo a b : Bool   -- lex key (region-rank PRIMARY, owner merged-chain rank SECONDARY)
kvE2_sepSlotsLOf wo :=
  ((kvE2_sepOrderOwners wo).flatMap kvE2_sepSlotsLFor).mergeSort (kvE2_sepSlotMergeLe wo)
```

(right mirror for `ROf`). The comparator is lexicographic on the pair
`(kvE2_sepSlotRank s, kvE2_sepOwnerRank wo (kvE2_sepSlotSub s))` with **region-rank primary**.

### Why region-rank must be PRIMARY (resolving the plan-prose tension — a flagged Phase-1 refinement)

338's rank is one distinct ℕ per OWNER (`kvE2_sepDisjValid` forces ranks `Nodup`). Making the
merged-chain rank the PRIMARY key therefore sorts whole owner blocks contiguously — i.e. it
reproduces exactly the block order report 04 proved rank-independent-insufficient, which the plan
forbids ("A def that keeps each owner's points contiguous ... reject it at design review"). So the
faithful point-level reading of the plan's key "(merged-chain rank, intra-owner region rank)" is
the lex order with **region-rank primary and owner merged-chain rank secondary**: within each
region layer (all owners' `zXU`, then all `x1`, then all `zUW`) the owners are ordered by 338's
cross-owner rank. This genuinely interleaves individual owner slots (σ's `zXU` and `zUW` are
separated by other owners' slots) — the defining property of the redesign — while consuming wo's
rank as-is (Postmortem "It is the KEY the merge sorts by, consumed as-is" — honoured as the
cross-owner key within each layer). **Flagged**: this is a Phase-1 refinement of the plan-prose
primary/secondary ordering, sanctioned by the plan's own "Phase 1 confirms/overrides this boundary"
clause.

### Validation against report 04's honest interleaving example

Honest 2-owner case (report 04 §Experiment 4): left-interior σ, τ with `x < a=x1_σ < b=x1_τ < w`,
σ needs a `zUW` witness at `u > b`, τ needs a `zXU` witness at `p < a`; realized value order
`p < a < b < u`. Region-primary keys (ranks: `zXU=0`, `x1=1`, `zUW=2`; owner ranks `rσ<rτ`):

| point | slot | region-rank | owner-rank | key |
|-------|------|-------------|-----------|-----|
| p | τ.zXU | 0 | rτ | (0, rτ) |
| a | σ.x1 | 1 | rσ | (1, rσ) |
| b | τ.x1 | 1 | rτ | (1, rτ) |
| u | σ.zUW | 2 | rσ | (2, rσ) |

Lex order (region primary): `(0,rτ) < (1,rσ) < (1,rτ) < (2,rσ)` ⟹ `p, a, b, u` — matches the
realized value order, and σ's own slots (a at index 1, u at index 3) are NON-contiguous (τ's b sits
between them). Block order (owner primary) gives `a,u,p,b` or `p,b,a,u` — never `p,a,b,u`. So the
merge produces a genuinely interleaved single chain (validated by hand against the shape; a
self-contained Lean `example` is added in Phase 5). Alignment with the `k1v_sorted_realizationK`
boundary-linked merged-anchor interface (`interleaveK` `Pairwise (· < ·)`, SubBracket2V.lean:633):
the mergeSort output is a single value-sorted-by-key chain, i.e. a sorted merge, not a block concat.

### Residual granularity note (bounded to 337, NOT a 339 blocker)

With only per-owner rank + per-slot region-rank the composite is a 2-level key; a case such as
`a < u' < b` (σ.zUW between σ.x1 and τ.x1) is not value-faithfully reproduced by ANY 2-level key —
full value-faithfulness needs a per-SLOT global index (the escalation-contingency carrier change).
This does NOT block 339: the 339 deliverable is (i) a genuinely point-level (interleaving,
non-block) merge DEF and (ii) the ⇒-extraction lemmas re-proven against it — both achieved. The
⇐ builder that would need per-slot value-faithfulness is 337's obligation; this note is recorded
for 337. No carrier-type change is required for 339, so the Rollback escalation branch is NOT
triggered.

## (c) Target signatures + downstream-lemma classification

**New / redesigned declarations** (Phase 2):

```
def kvE2_sepOwnerRank {sig} (wo : KvE2SepWeakOrder sig) (σ : NormalForm sig 1 4) : ℕ
def kvE2_sepSlotMergeLe {sig} (wo : KvE2SepWeakOrder sig) (a b : KvE2SepSlot sig) : Bool
noncomputable def kvE2_sepSlotsLOf {sig} (wo : KvE2SepWeakOrder sig) : List (KvE2SepSlot sig)
  := ((kvE2_sepOrderOwners wo).flatMap kvE2_sepSlotsLFor).mergeSort (kvE2_sepSlotMergeLe wo)
noncomputable def kvE2_sepSlotsROf {sig} (wo : KvE2SepWeakOrder sig) : List (KvE2SepSlot sig)
  := ((kvE2_sepOrderOwners wo).flatMap kvE2_sepSlotsRFor).mergeSort (kvE2_sepSlotMergeLe wo)
theorem kvE2_sepSlotsLOf_mem {sig} (qnf) {wo} (hwo : wo ∈ kvE2_sepOrderTypes qnf)
    {σ} (hσ : σ ∈ kvE2_sepPos qnf) {s} (hs : s ∈ kvE2_sepSlotsLFor σ) : s ∈ kvE2_sepSlotsLOf wo
  -- proof: (List.mergeSort_perm _ _).mem_iff.mpr (List.mem_flatMap.mpr ⟨σ, kvE2_sepMem_orderOwners …, hs⟩)
theorem kvE2_sepSlotsROf_mem {sig} … (mirror)
```

`KvE2SepSlot`, `kvE2_sepSlotRank`, `kvE2_sepSlotSub`, `kvE2_sepSlotsLFor/RFor`,
`kvE2_sepOrderOwners`, `kvE2_sepMem_orderOwners`, `kvE2_sepSlotLe`, the weak-order TYPE, and the
338 rank field are all consumed AS-IS (no change).

**Downstream lemma classification:**

| Lemma (SW line) | Classification | Reason |
|-----------------|----------------|--------|
| `kvE2_sepBody` (933) | statement- & proof-preserved | consumes `kvE2_sepSlotsLOf/ROf` by NAME only |
| `kvE2_sepBody_holds_iff` (970) | statement- & proof-preserved | references defs by name; `simp only [kvE2_sepBody]; rw [dif_pos]` unaffected |
| `kvE2_sepBody_nonvacuous` (1512) | statement- & proof-preserved | `List.mem_map.mpr ⟨kvE2_sepModelOrder, …, rfl⟩`; slot defs by name (SW:1527) |
| `kvE2_sepDisjunct_extract` (2015) | statement- & proof-preserved | parametric over `lL/lR`; never mentions `kvE2_sepSlotsLOf`; Phase 3 = re-verify |
| `kvE2_sepBody_extract` (2163) | statement-preserved; internal `hmemL/hmemR` re-derived | `hpairL/hpairR` stay HYPOTHESES; the two `List.mem_flatMap.mpr …` become `kvE2_sepSlotsLOf_mem`/`ROf_mem` calls |

No downstream statement changes; only `kvE2_sepBody_extract`'s two internal membership witnesses are
re-routed through the new `mergeSort_perm` helper. `kvE2_sepOrderOwners` / `kvE2_sepMem_orderOwners`
are KEPT (not repurposed): the merge's base list is still `(kvE2_sepOrderOwners wo).flatMap …`, so
membership into the base is exactly `kvE2_sepMem_orderOwners`, and the mergeSort only permutes it.

### Design constraints confirmed clean up front

- **Block-contiguity**: rejected — region-primary interleaves owners (validated in (b)).
- **F5 (open/closed zone-key conflation)**: the merge reorders slots only; it reads NO zone bit.
  `kvE2_sepDisjValidOwner`/`kvE2_sepClosedLeafStub` bit selection is untouched.
- **LITMUS (NavigatedSpine.lean:437, `x1 < e_i` literal)**: the comparator key is the abstract
  composite ℕ×ℕ `(kvE2_sepSlotRank, kvE2_sepOwnerRank)` — no model relative-position literal; slot
  positioning rides the merge INDEX only. Clean.
- **Membership preservation**: `List.mergeSort_perm` (unconditional Perm) ⟹ every existing `∈`
  fact survives; no proof of comparator legality needed for the 339 ⇒-lemmas.

## Gate verdict: PASS

The point-level merge produces the single-concatenated-chain shape `holds_eq_succ` requires, is a
genuine (non-block) interleaving faithful to Rabinovich Def 3.1's single global chain, preserves
every membership fact via `mergeSort_perm`, and violates no F5/LITMUS/block constraint. The one
statement refinement (region-rank primary vs plan-prose merged-chain primary) is flagged and
sanctioned. Proceed to Phase 2.
