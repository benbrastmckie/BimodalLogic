# Task 350 — Phase 7 Handoff (conjFull kit)

Session: sess_1783988294_843145 (hard-mode, per-phase dispatch, phase_number=7)

## Immediate Next Action

Dispatch Phase 8 (B / P2a): `HasAttainedSUP` mirror appended to `PriorINF.lean`
(land + commit FIRST as independent probe, R8), then new `Kamp/EANegationFix.lean`
with `negChainOn` + `negChainOn_iff`. Phase 12 (D / P3-pt) remains file-disjoint
and parallelizable (wave 1).

## Current State

- Phase 7 [COMPLETED]; phases 1-6 previously [COMPLETED]. 7/17 phases done.
- New file `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEAConjFull.lean`
  (577 lines), registered on the root build via an import line in
  `Kamp/NfMultiAnchorBridge.lean` (cycle-free NOTE included).
- Full `lake build` green (1738 jobs). Zero sorries in all task-350 files.
- `lean_verify` on `BracketFormula.conjFull_iff` and `VVecEA2.conjFull_iff`:
  axioms exactly `[propext, Classical.choice, Quot.sound]`.
- Commits: 5c04425b5 (phase 7.1, new module), c7082617b (phase 7.2, aggregator).
- G6 territory respected: no edits to KampPrior.lean or
  ExteriorPinnedConverse{K,PastK}.lean.

## Delivered API (for Phases 8-11 and 16)

| Name | Role |
|------|------|
| `TemporalPred.eval_at_glue` | segment gluing across an interior point |
| `witness_position_trichotomy` | point = witness / before first / after last / between |
| `BracketFormula.front`, `front_eq_leftPart` | drop last witness (= `leftPart` at last index) |
| `BracketFormula.holds_succ_iff` | last-witness decomposition of `holds` (iff) |
| `BracketFormula.snoc`, `snoc_front`, `snoc_pointTypes_last`, `snoc_segmentTypes_last` | append last witness |
| `BracketFormula.snoc_holds_iff` | Probe-1 decomposition (iff) |
| `VBracketFormula.snocAll`, `snocAll_holds_iff` | disjunct-wise snoc (iff) |
| `BracketFormula.conjEverywhere`, `conjEverywhere_holds_iff` | 0-witness base case: conjoin segment type into ALL point/segment types |
| `VBracketFormula.singleton_holds` | singleton disjunct characterization |
| `BracketFormula.conjFull`, `conjFull_iff` | Lemma 3.2(1) full conjunction, iff, order-generic, no model hypotheses |
| `VVecEA2.conjFull`, `conjFull_iff` | Lemma 3.4 lift (Cartesian product, endpoint conj, flattened brackets) |
| `VVecEA2.trivialTrue`, `trivialTrue_holds`, `conjFull_trivialTrue_iff`, `trivialTrue_conjFull_iff` | neutral element for the Phase-16 fold |

## Key Decisions

1. `holds_succ_iff` is proved on top of the delivered splitting kit
   (`leftPart_holds` forward, `splitAt_combine` backward at index
   `⟨n, Nat.lt_succ_self n⟩`), avoiding a from-scratch witness-vector
   construction; `front` is definitionally `leftPart` at the last index
   (`front_eq_leftPart := rfl`).
2. `conjFull` base cases `(0,n)`/`(n,0)` are unified in a single
   `conjEverywhere` operation conjoining the 0-bracket's segment type into
   ALL point types AND all segment types (exactly where the iff-form diverges
   from the forward-only `conjStruct`); its iff uses
   `witness_position_trichotomy` (proved WITHOUT monotonicity of the witness
   vector, by scanning from the last witness down).
3. `conjFull` recursion is well-founded on `n1 + n2` (`termination_by`,
   `decreasing_by all_goals omega`); `conjFull_iff` is a recursive theorem
   with the same measure — recursive `rw [conjFull_iff ...]` calls at the
   three smaller pairs, with the interval shrunk to `(z0, x)`.
4. The bf1-last-greater / bf2-last-greater iff directions reconstruct the
   shorter bracket's `holds` on the full interval by gluing its last segment
   type across the merged point (`eval_at_glue`), consuming the merged point
   type `p.conj s_other` — the Lemma 3.2(1) "ambient segment type on the
   merged point" ingredient.

## Sorry Inventory

`sorry_inventory: []` — no sorries introduced; none inherited from phases 1-6.
(Pre-existing repo baseline outside task-350 scope is unchanged, e.g.
KampPrior.lean:351/354 owned by task 358 this session.)

## References

- Plan: `specs/350_.../plans/02_offdiag-k1-aggregate-discharge.md` (Phase 7
  checklist annotated inline; Phase 8 is the next incomplete phase).
- Grounding: Rabinovich Lemma 3.2(1) (chunk_0009), Lemma 3.4 (chunk_0010),
  per the plan's H3 mapping table (rows now discharged for Phase 7).
