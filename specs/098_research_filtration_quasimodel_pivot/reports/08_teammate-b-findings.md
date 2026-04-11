# Research Report: Task 98 Phase 4 — Teammate B Findings

**Task**: 98 — research_filtration_quasimodel_pivot
**Round**: Phase 4 architectural gap (08)
**Teammate**: B (Alternatives / Prior Art)
**Session**: sess_1775873649_08b347
**Date**: 2026-04-10

---

## Key Findings

1. **The Phase 4 gap is identical to the gap already surveyed in round 3 teammate-B (`03_teammate-b-findings.md`)**, but applied one layer up: the summary casts it at the `h_{i+1}` HintikkaPoint level, whereas the round 3 survey cast it at the `{¬(φ U ψ)} ∪ g_content(w_i) ∪ h_content(v)` seed level. The recommended literature fix — *independent Hintikka realization* (Burgess-Xu style) — still applies, but the BXCanonical/ architecture has a **local shortcut that all three options in `07_phase4-summary.md` missed**: because `SetConsistent` is defined as "every finite subset is consistent", consistency of any subset of `w.formulas` for an MCS `w` is **free** (one-line application of `w.is_mcs.1`). This changes the decision matrix dramatically.

2. **`HintikkaPoint` as currently defined (HintikkaPoint.lean:43-53) cannot in general underwrite derivation-level consistency**. It has only `locally_consistent` (pairwise), `bot_free`, `locally_maximal`, and `subset_sigma`. There is no propositional closure and no derivation-level witness. This confirms the summary's diagnosis of the gap.

3. **However, `HintikkaStepOracle` (Construction.lean:452) is existential over *arbitrary* `HintikkaPoint Sigma`** — no MCS backing. Consequently `hintikka_chain_exists` produces a `HintikkaRawChain` whose points are **abstract Hintikka points** with no guarantee of being the `sigma_signature` of any BXPoint. This is the structural cause of the gap: Phase 3's output type is too weak to support the Phase 4 reduction.

4. **`BXPoint` (Frame.lean:49) already carries `is_mcs : SetMaximalConsistent formulas`**, and `g_content_set_consistent` (Frame.lean:122) already proves `SetConsistent (g_content S)` for any MCS `S`. Furthermore `enriched_seed_consistent_until` (Realization.lean:226) already proves consistency of `{¬(φ U ψ)} ∪ g_content(w) ∪ h_content(v)` using the fact that every non-neg-until element lies in `w.formulas`, which is the MCS. The existing architecture already knows how to discharge seed consistency by **routing through a backing MCS**, not by propositional saturation of Hintikka points.

5. **Conclusion**: the most economical path is to **tie Hintikka chain points to backing BXPoints from the start**, not post-hoc. This is a refinement of option (3) in the summary, but it does NOT require duplicating Phase 3 at the BXPoint level. It requires adding a single optional witness field `backing_mcs : BXPoint` to `HintikkaPoint` or to `HintikkaRawChain` and proving `h.formulas.toSet ⊆ backing_mcs.formulas`. I call this **Option 4** below.

---

## Prior Art Summary (how do other systems handle this?)

Round 3 teammate-B's literature survey (`03_teammate-b-findings.md`) remains the authoritative prior-art reference. Summarising its conclusions as they apply to the Phase 4 architectural gap:

| Source | Architecture | Does the gap arise? | Resolution |
|--------|-------------|---------------------|------------|
| **Burgess 1984** | Hintikka chain at finite level, then independent Lindenbaum realization per point | No — seed is `h_i.formulas` only, never mixed with `g_content(w_{i-1})` | Post-hoc G-propagation transfer lemma establishes `bx_le w_i w_{i+1}` |
| **Xu 1988** | Same as Burgess; BX axioms (BX4/BX5) designed specifically so the G-propagation transfer lemma is a one-liner | No | Independent realization |
| **Verbrugge 2007** | Omega-chain of Hintikka points is the model itself; no MCS lifting | No — no MCS at all | Semantic evaluation uses Hintikka membership directly |
| **Goldblatt 1992** | Filtration of canonical model; worlds are equivalence classes of MCSes restricted to Sigma | No — works in a quotient | Filtration ordering ≠ `g_content ⊆` |
| **Lichtenstein–Pnueli 2000** | Omega-sequence tableau | No | No MCS lifting step |
| **Reynolds 2003** | Finite Hintikka-quotient model | No | Works entirely at Hintikka level |
| **LIPIcs.ITP.2024.28 (Coalition Logic, Lean 4)** | Filtration of canonical CL model | No | Not applicable (CL is not temporal) |

**Unifying observation**: *every* mainstream completeness proof avoids the gap either by (a) never mixing MCS data into seeds (Burgess-Xu), or (b) never constructing MCSes at all (Verbrugge, Lichtenstein-Pnueli, Reynolds). **No published proof attempts the combination the current Phase 4 reduction attempts** — namely, proving that an abstract Hintikka chain point's formula set is derivation-consistent using only the G-content of a *different* backing MCS. This is why the reduction fails: it has no precedent in the literature.

### Mathlib patterns surveyed

I searched mathlib and the local codebase for bridge patterns between finitely-generated consistent sets and derivation-level consistency:

- **Mathlib `FirstOrder.Theory.IsSatisfiable` / `Sentence.models`**: works over semantic satisfiability (a model exists), not syntactic derivation-consistency. Not directly applicable — the BX tree is a Hilbert-style system with a `DerivationTree` type, not a first-order theory.
- **Mathlib `IsChain` on lists**: already used by `HintikkaRawChain`. No bridge lemma.
- **Local `set_consistent_mono` / `SetConsistent` subset monotonicity**: `SetConsistent` is defined as "every finite subset ⊆ S is consistent" (Core/README.md:50-51). This means `S ⊆ T ∧ SetConsistent T → SetConsistent S` is **immediate by unfolding** — just take the same finite subset witness and use it in `T`. This is the key observation behind Option 4 (see below).
- **Local `SetMaximalConsistent.closed_under_derivation`** (used extensively in Realization.lean:264, 315): if `L ⊆ w.formulas` and `L ⊢ φ`, then `φ ∈ w.formulas`. This, combined with `w.is_mcs.1`, already lets us transport any derivation-consistency question from a subset of `w.formulas` straight into the MCS.

**Punchline**: The BXCanonical/ infrastructure *already has everything needed* for derivation-level consistency of any subset of an MCS. What it lacks is **a connection from the abstract HintikkaPoint in a chain back to such an MCS**. That connection is the only missing piece.

---

## Alternative Approaches

The summary lists three options. I analyse each briefly and then propose **Option 4**, which I believe the summary missed.

### Option 1 (summary) — Strengthen `HintikkaPoint` with propositional saturation

**Summary verdict**: high cascade risk, requires rebuilding every HintikkaPoint constructor.

**My assessment**: This is round-3 teammate-B's "Alternative C" (prop_saturated). It is *mathematically* the cleanest (it makes HintikkaPoint self-sufficient) but indeed has high refactor cost. Also, it fundamentally **duplicates effort**: propositional saturation over Sigma is derivable from `closed_under_derivation` on the backing MCS, so any proof of prop_saturated for a `sigma_signature` will internally re-traverse the MCS closure argument. Option 4 avoids this duplication.

### Option 2 (summary) — Restrict chain-step lemma to BXPoint-linked `h_{i+1}`

**Summary verdict**: yields a vacuously-true statement.

**My assessment**: Correct — but only because the summary phrases the statement as consistency of the seed. If the statement is rephrased as **"the BXPoint producing `h_{i+1}` satisfies `bx_le v_i v_{i+1}`"**, the statement is no longer vacuous; it is exactly the guard propagation lemma Burgess-Xu prove post-hoc. But this rephrasing shifts the problem from Phase 4 into Phase 5, which is where the summary's option (3) lands.

### Option 3 (summary) — Phase 5-first; build BX-level chain directly with `BXUntilChain`

**Summary verdict**: cleanest mathematically, 8-15h, essentially duplicates Phase 3.

**My assessment**: Correct that this is the cleanest of the three, but the "duplicates Phase 3" characterization is the real cost. The existing Phase 3 `hintikka_chain_exists` and the `HintikkaStepOracle` + `HintikkaRawChain` infrastructure (Construction.lean:452-600) are ~150 LOC; building `BXUntilChain` from scratch with well-founded recursion on `defect_count ∘ sigma_signature` would repeat this effort. The `bigconj_intro` / `bigconj_mem_iff` scaffolding landed in Session 5 would become dead code.

### Option 4 (new) — MCS-Backed Hintikka Chain

**Idea**: Extend `HintikkaRawChain` (not `HintikkaPoint`) with a parallel list of BXPoints witnessing each chain point, and a proof that each chain point IS the `sigma_signature` of its backing BXPoint. Require the oracle / chain constructor to produce this backing as it builds the chain. All subsequent consistency obligations dissolve because the backing MCS witnesses them for free.

**Concrete shape**:

```lean
/-- A Hintikka raw chain together with backing BXPoints. -/
structure MCSBackedHintikkaChain (Sigma : Finset Formula)
    (h_neg_closed : ∀ f ∈ Sigma, Formula.neg f ∈ Sigma) where
  raw : HintikkaRawChain Sigma
  backing : List BXPoint
  length_eq : backing.length = raw.points.length
  signature_agrees : ∀ i : Fin raw.points.length,
    raw.points.get i =
      sigma_signature (backing.get ⟨i.val, length_eq ▸ i.isLt⟩) Sigma h_neg_closed
  bx_le_consecutive : ∀ i : Fin (backing.length - 1),
    bx_le (backing.get ⟨i.val, by omega⟩) (backing.get ⟨i.val + 1, by omega⟩)
```

**Why this closes the Phase 4 gap**:

For `chain_step_seed_consistent` we need to show `h_{i+1}.formulas ∪ g_content(v_i.formulas)` is derivation-consistent. With the MCS backing:

- `h_{i+1}.formulas ⊆ (backing.get (i+1)).formulas` (by `sigma_signature_mem` unfolded).
- `g_content(v_i.formulas) ⊆ (backing.get (i+1)).formulas` (by `bx_le_consecutive`).
- Therefore the entire seed is a subset of an MCS, and `SetConsistent` follows from `backing.get (i+1)).is_mcs.1` by one-line subset witness — the same pattern used in the existing `enriched_seed_consistent_until` proof (Realization.lean:235-276, case `h_neg_in = false`).

**No `bigconj` reasoning needed**. The scaffolding in Session 5 (`bigconj_intro`, `bigconj_mem_iff`) becomes unused for this specific obligation (but remains valid infrastructure for any future syntactic conjunction proof — it can be left in-tree without harm, or retired).

**Why this is *not* Option 3**:

Option 3 builds a brand-new `BXUntilChain` type and re-proves well-founded termination at the BXPoint level. Option 4 **keeps Phase 3's `HintikkaRawChain` as-is** and adds an auxiliary backing list. The existing `hintikka_chain_exists` theorem (Construction.lean:556) produces a `HintikkaRawChain`; we strengthen it (or wrap it) to additionally produce the backing list. The termination argument is unchanged — it still runs on Hintikka `defect_count`.

**Where does the backing come from?**

Two routes:

- **Route 4a (oracle strengthening)**: change `HintikkaStepOracle` (Construction.lean:452) to require that the produced `h'` comes with a backing BXPoint `w'` and a `bx_le` witness from a caller-provided `w`. Thread backing lists through `hintikka_chain_exists`. The oracle instantiation in Phase 5 would use `bx_forward_witness` (Frame.lean:164) to produce both `h'` and `w'` simultaneously, which is exactly what `bx_forward_witness` already does (`∃ v : BXPoint, bx_le w v ∧ ψ ∈ v.formulas`).

  Cost: ~2-4h change to Phase 3 oracle signature and chain construction; all existing Phase 3 proofs remain structurally intact.

- **Route 4b (post-hoc realization)**: leave `hintikka_chain_exists` alone. In Phase 5, when realizing the abstract chain to BXPoints, realize each `h_i` to a `w_i` *together with* `bx_le w_{i-1} w_i`, producing the backing list as output. Each realization step uses the seed consistency of `h_i.formulas.toSet ∪ g_content(w_{i-1}.formulas)` — but now the abstract `h_i` is not backed by an MCS yet, so we still have a consistency obligation at this step.

  Wait — this is the original Phase 4 problem. Route 4b reduces to Option 3.

**Only Route 4a works.** It tightens the oracle to carry the backing through the entire chain, so by the time we reach Phase 4/5, the backing is already there. The Phase 4 seed consistency lemma then becomes a one-line corollary and may not even need to be stated as a separate theorem — it can be inlined into Phase 5's `realize_chain_step`.

### Option 5 (brief mention) — Quasimodel-as-model (Verbrugge route)

Instead of realizing the chain into BXPoints at all, define a new `TMModel` whose worlds are `HintikkaPoint Sigma` and whose `bx_le` is `hintikka_step`-reflexive-transitive-closure. Prove the truth lemma for this model directly, then transfer it to the canonical model via a bisimulation. This is the Verbrugge / Lichtenstein-Pnueli style.

**Cost**: 80-120h (per round 3 teammate-B estimate for the analogous "Option B" in that report). **Not recommended** unless Options 1-4 all fail.

---

## Recommended Option: **Option 4a (MCS-backed oracle)**

### Rationale

1. **Lowest refactor footprint**: adds a backing list to `HintikkaStepOracle` and `hintikka_chain_exists`; does not touch `HintikkaPoint` structure, does not duplicate Phase 3 well-founded recursion, does not add propositional saturation machinery.
2. **Reuses existing infrastructure**: `bx_forward_witness` already produces both the next BXPoint and the `bx_le` witness. Threading this through the chain is structurally straightforward.
3. **Discharges Phase 4 seed consistency in one line**: via subset monotonicity on `SetConsistent`, just like `enriched_seed_consistent_until` does in its `h_neg_in = false` branch.
4. **Aligns with Burgess-Xu prior art**: the "post-hoc G-propagation transfer" step in Burgess-Xu becomes the `bx_le_consecutive` field, which is carried explicitly rather than proved after the fact. This is a more formalization-friendly variant of the Burgess-Xu architecture.
5. **Zero-debt compliant**: no new sorries, no new axioms, no Option-B-style deferral. The path to closing the six Realization.lean sorries and four Frame.lean sorries remains intact; Phase 5 simply consumes the backing list directly.
6. **Retires dead scaffolding cleanly**: `bigconj_intro` / `bigconj_mem_iff` are still structurally valid and can either stay in-tree as public infrastructure or be deleted. Neither choice affects correctness.

### Estimated effort

- Change `HintikkaStepOracle` signature (Construction.lean:452): ~30 min.
- Thread backing through `hintikka_chain_exists` (Construction.lean:556): ~3-5h (the well-founded recursion is unchanged; we additionally carry a backing witness at each recursive step).
- Prove the Phase 5 oracle instantiation using `bx_forward_witness`: ~2-3h.
- Inline the seed consistency argument into Phase 5's `realize_chain_step`: ~1-2h.
- **Total: 6-10h**, significantly below Option 3's 8-15h and without duplicating Phase 3.

### Risks

- **Risk 1**: the oracle instantiation for the "defect-decreasing" branch (not the "witness-reached" branch) might need an additional non-trivial BX lemma to produce the backing `w'` with strict defect decrease. **Mitigation**: `bx_forward_witness` on `F(ψ)` already gives `ψ ∈ v'`, which is the witness-reached case; the defect-decrease case uses BX4/BX5 to thread the guard through an intermediate `u` produced by `bx_forward_witness` on something else. Needs detailed design work in a planning phase.
- **Risk 2**: Since-dual requires a symmetric backing list with `bx_le v_{i-1} v_i` replaced by `bx_le v_i v_{i-1}`. **Mitigation**: mirror the Until construction; estimate doubling Phase 5 instantiation time.
- **Risk 3**: `lean_profile_proof` on the refactored `hintikka_chain_exists` may show unexpected elaboration costs when passing a list of BXPoints through the recursion (BXPoint is a structure on a `Set Formula`, which can blow up). **Mitigation**: use `List (Σ w : BXPoint, ...)` or a dedicated structure to keep proofs opaque.

---

## Confidence Level: **Medium-High (75%)**

| Component | Confidence |
|-----------|------------|
| Gap diagnosis (pairwise vs derivation consistency) matches the summary | High (95%) |
| `SetConsistent` subset-monotonicity gives free consistency for sub-MCS sets | High (95%) — verified via Core/README.md:50 |
| `HintikkaStepOracle` currently lacks MCS backing | High (95%) — verified via Construction.lean:452 |
| `bx_forward_witness` produces both witness and `bx_le` simultaneously | High (95%) — verified via Frame.lean:164 |
| Option 4a oracle refactor will close the gap without cascade | Medium (70%) — not yet prototyped; Risk 1 above is real |
| Effort estimate (6-10h) is accurate | Medium (65%) — depends on defect-decrease branch complexity |
| Burgess-Xu literature supports this architecture morally | High (85%) — round-3 teammate-B survey confirms independent realization is standard |

**The uncertainty is concentrated in whether the defect-decrease branch of the oracle can be instantiated from `bx_forward_witness` + BX axioms without requiring a new well-founded recursion at the BXPoint level** (which would reduce Option 4 back to Option 3). A 1-2 hour prototype on one chain step would resolve this.

---

## Files Referenced (all absolute paths)

- /home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/HintikkaPoint.lean (lines 43-53: structure definition; lines 141-151: `sigma_signature`)
- /home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean (lines 45-52: `hintikka_step`; lines 452-457: `HintikkaStepOracle`; lines 464-467: `HintikkaRawChain`; line 556: `hintikka_chain_exists`)
- /home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean (lines 134-215: `bigconj_intro` / `bigconj_mem_iff` scaffolding; lines 226-276: `enriched_seed_consistent_until` — the template for Option 4's one-line discharge)
- /home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Frame.lean (lines 49-55: `BXPoint`; lines 61-62: `bx_le`; lines 122-128: `g_content_set_consistent`; line 164: `bx_forward_witness`)
- /home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Core/README.md (lines 50-51: `SetConsistent` definition — subset monotonicity is free)
- /home/benjamin/Projects/ProofChecker/specs/098_research_filtration_quasimodel_pivot/summaries/07_phase4-summary.md (the gap and three-option analysis being extended here)
- /home/benjamin/Projects/ProofChecker/specs/098_research_filtration_quasimodel_pivot/reports/03_teammate-b-findings.md (round-3 prior-art survey — still authoritative for Burgess/Xu/Verbrugge/Goldblatt/LP/Reynolds/LIPIcs.ITP)
