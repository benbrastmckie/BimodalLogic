# Teammate D Findings: Long-Term Architecture for Multiple Representation Theorems

**Artifact**: 09 | **Role**: Teammate D (Horizons Researcher)
**Task**: 107 — Chain design diagnostics for representation theorem
**Focus**: Long-term architecture for TM+density, TM+discreteness, and TM general completeness

---

## Key Findings

### 1. Literature Standard: One Construction Generalized to Frame-Class Variants

The standard approach in the literature is to prove completeness for the **most general frame class first** (all linear orders), then derive completeness for restricted classes (dense, discrete) by adding frame-specific axioms. This is the explicit structure in both Burgess 1982 and Verbrugge 2004:

- **Burgess 1982**: The base system J₀ is complete for K₀ = all linear orders. Density and discreteness are treated as **optional variants** listed in Section 1.6 with the note that they "follow from adaptation of our work below." The chronicle construction is parameterized by the axiom system: the same construction works for all three variants, with density/discreteness axioms changing what formulas appear in MCSs.

- **Verbrugge 2004**: Separate theorems for Lin (all linear orders), Q (dense), D (discrete), Z (integers), etc. Crucially, the Q proof (Theorem 3) adds **odd-stage density witness insertion** on top of the Lin proof. The discrete case (Theorem 5) adds adequate-set machinery. The architecture is explicitly layered: general completeness is the base, with frame-specific proofs extending it.

**Conclusion**: The literature does NOT use separate, independent constructions. It uses one construction (chronicle/step-by-step) parameterized by the frame class, with the base (all linear orders) being primary and the others being extensions.

### 2. How the Existing Parametric Infrastructure Supports This

The project already has a well-designed parametric architecture in `ParametricRepresentation.lean` that explicitly anticipates all three variants:

**Domain Selection Table (from `ParametricRepresentation.lean` lines 64-68)**:

| Extension | D | Constraint | BFMCS Construction |
|-----------|---|------------|-------------------|
| Base | Int | `AddCommGroup + LinearOrder + IsOrderedAddMonoid` | `temporal_coherent_family_exists_CanonicalMCS` |
| Dense | Rat | `+ DenselyOrdered` | Same, with density axiom in MCSs |
| Discrete | Int | `+ SuccOrder` | Same, with discreteness axiom in MCSs |

The parametric truth lemma (`ParametricTruthLemma.lean`) is already fully parametric over D — it works for any `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`. No changes are needed to the truth lemma for any of the three variants.

The key point: `parametric_algebraic_representation_conditional` (the conditional representation theorem) is **already general** — it takes a `construct_bfmcs` callback that supplies the temporally coherent BFMCS. The three variants differ only in what BFMCS they supply:

- **Base (general)**: BFMCS over Rat (Burgess chronicle) or Int (chain construction)
- **Dense**: BFMCS over Rat with `[DenselyOrdered Rat]` instances used in MCS density
- **Discrete**: BFMCS over Int with `[SuccOrder Int]` instances used in MCS discreteness

**Crucially**: The Burgess chronicle construction over Rat (task 107's current work) is **simultaneously** the construction for the base case (general linear orders). The final chronicle model X ⊆ Q is a countable subset of the rationals, but it need not itself be dense. Burgess's J₀ completeness result (all linear orders) uses Q as an implementation domain without requiring the output model to be dense.

### 3. Current Status: The Chronicle Construction Is the Right Tool for All Three

The existing implementation (`ChronicleToCountermodel.lean`) uses `BFMCS Rat` — the chronicle constructs a countermodel over a countable subset of Rat. This is the **correct** domain for all three cases:

- **Base completeness**: The chronicle over a countable subset of Q suffices (no density of the subset required). Burgess Section 2.11 explicitly defines X = ⋃dom(fₙ) ⊆ Q as the final model, without requiring X to be dense.

- **Dense completeness (task 68)**: Add a density phase to the chronicle construction (Verbrugge-style odd-stage density insertion: for each pair of adjacent domain points t < u in Tₙ, insert a midpoint v). The `valid_dense` semantics requires `[DenselyOrdered D]`, so the countermodel must be dense. The chronicle can be made dense by adding a density-ensuring stage to the omega-chain.

- **Discrete completeness**: NOT directly handled by the chronicle. Discrete completeness requires a `[SuccOrder D]` domain (Int-like), and the Burgess Q-based construction produces a dense or at least non-discrete subset. Discrete completeness needs a separate successor-based construction.

### 4. Axiom System Parameterization

The existing axiom infrastructure already handles this cleanly:

- `Axiom.isDenseCompatible`: All BX axioms are dense-compatible (returns `True`). Adding the density axiom DN would be via a new `Axiom` variant.
- `Axiom.isDiscreteCompatible`: All BX axioms are discrete-compatible (returns `True`).
- `valid_dense` and `valid_discrete` are already defined in `Validity.lean`.
- `DenseSoundness.lean` and `DiscreteSoundness.lean` are already sorry-free.

The recommended approach is **option (a)**: one axiom type with all axioms, with frame-class-specific completeness theorems. This is what the codebase already does. Separate axiom types would be architecturally heavier and would duplicate all the base infrastructure.

The key insight from `Axioms.lean` lines 280-317: `Axiom.frameClass` always returns `.Base` because all current BX axioms are valid over all linear orders. Adding DN or DF as axioms would require adding them to the `Axiom` inductive type with frame class `.Dense` or `.Discrete`.

### 5. Recommended Phasing

**Phase A: Dense completeness (task 107, current work)**

The chronicle construction produces a countermodel over a subset of Q. With the 3 architectural fixes from the team research report, the basic `bx_completeness` (over all linear orders) will be solved.

**Phase B: Dense completeness (task 68)**

Dense completeness (`valid_dense φ → Nonempty (DerivationTree [] φ)`) requires that the countermodel be a **densely ordered** set. The chronicle construction can be extended with a density phase following Verbrugge 2004 Theorem 3:

- At odd stages of the omega-chain, insert midpoints between all consecutive domain point pairs.
- The Burgess r-relation machinery already handles point insertion (Lemmas 2.9-2.10).
- The key needed lemma: `[DenselyOrdered D]` implies that `¬∃ s, t < s ∧ (t, s) = ∅`, i.e., no empty open intervals, which is exactly what makes the dense guard condition non-vacuous.

The boundary between Phase A and Phase B: the density phase requires the midpoint-insertion machinery from Phase A (Lemma 2.9/2.10 for between-point insertion). Phase B cannot proceed until Phase A's Lemma 2.7/2.8 infrastructure is complete.

**Phase C: Discrete completeness (new task)**

Discrete completeness is genuinely separate because:

1. The Burgess Q-based chronicle cannot produce a discrete model (Q is dense by construction).
2. Discrete semantics needs `[SuccOrder D]` — a successor function — which Q lacks.
3. The correct approach for discrete completeness is a separate Z-indexed chain construction.

The Boneyard contains `ChainCompleteness/Algebraic/DeterministicChain.lean` (the deterministic chain for discrete completeness). Under strict semantics, the key is: `⊥ U φ` at t means φ holds at the immediate successor t+1 (the next-step operator X). For discrete completeness, the MCS-based chain should use Int (or Z) with the SuccOrder structure.

**Phase D: General completeness (implicit in Phase A)**

General completeness (`valid φ → Nonempty (DerivationTree [] φ)`) is what `bx_completeness` already states. The Burgess chronicle construction over Q (a countable subset thereof) already gives completeness over all linear orders — the output model is a linear order (a subset of Q), which is an instance of a linear order. There is no separate "Phase C for general completeness" — Phase A IS general completeness.

### 6. Alignment with Project Roadmap

From ROADMAP.md:
- Task 107 (current): "Burgess chronicle construction for BX representation theorem" — this is general (base) completeness
- Task 68 (RESEARCHED): "Prove dense_completeness_fc via Rat canonical model" — this is Phase B above
- Task 95: "#print axioms audit" — verification after Phase A

The roadmap note for task 68 says: "Cannot reduce to completeness_over_Int since Int is not densely ordered." This is correct. The recommended path for task 68 is to extend the chronicle construction with Verbrugge-style density insertion, not to use a separate Int-based construction.

Task 998 (RESEARCHING): "FMP redesign for irreflexive temporal semantics" — the FMP is relevant to decidability but is explicitly NOT a path to the representation theorems (ROADMAP.md: "Decidability-based completeness is explicitly excluded as a path to the representation theorem").

---

## Recommended Approach

### Architecture Decision: One Chronicle Construction, Three Theorems

The recommended long-term architecture is:

1. **One chronicle construction** (`BXCanonical/Chronicle/`) over `Rat` as the implementation domain.

2. **Three completeness theorems** built on top of this one construction:

   | Theorem | Statement | Domain Used | Extra Phase |
   |---------|-----------|-------------|-------------|
   | `bx_completeness` | `valid φ → derivable φ` | Rat (subset) | None — Phase A suffices |
   | `bx_dense_completeness` | `valid_dense φ → derivable φ` | Rat (dense) | Phase B: add density insertion |
   | `bx_discrete_completeness` | `valid_discrete φ → derivable_discrete φ` | Int | Separate construction |

3. **Parametric representation theorem** (`ParametricRepresentation.lean`) remains as the bridge from BFMCS to completeness. No changes needed.

4. **Axiom system** remains as a single inductive type. Dense/discrete completeness are parameterized by `valid_dense`/`valid_discrete` predicates, not by separate axiom types.

### Avoiding Option B (Sorry Deferral)

Per the zero-debt policy:
- Do NOT use `sorry` for Phase B or C with the intent of "fixing later."
- The chronicle construction for Phase A (base completeness) must be complete before attempting Phase B (dense completeness).
- Discrete completeness (Phase C) should be created as a separate task once Phase A is complete, not deferred within task 107.

### Concrete Next Step: Fix the 3 Architectural Gaps

The immediate priority is the 3 architectural gaps from the team research:
1. Add C4/C4' to `ValidChronicle` (missing backward counterexample condition).
2. Fix the non-domain extension in `ChronicleToCountermodel.lean` (use subtype model over `limit_dom`).
3. Fix the C5 insertion strategy (insert between existing points, not beyond all points).

All three must be resolved before the sorry-closing campaign. Dense completeness (task 68) inherits the between-point insertion machinery, so fixing gap #3 also lays the groundwork for Phase B.

---

## Evidence

| Claim | Evidence Source |
|-------|----------------|
| Burgess constructs for all linear orders first | `Burgess 1982 Section 1.1-1.6` (per teammate A findings in `09_teammate-a-findings.md`) |
| Density is an optional add-on variant in Burgess | `Burgess 1982 Section 1.6, explicit table` |
| Verbrugge treats Q/D/Z as separate theorems on same base | `Verbrugge 2004, Theorems 1-7` (per `08_verbrugge-step-by-step.md`) |
| Parametric infrastructure explicitly anticipates three variants | `ParametricRepresentation.lean` lines 64-68, domain selection table |
| Truth lemma is D-parametric already | `ParametricTruthLemma.lean` line 85: `variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` |
| Dense/discrete soundness already sorry-free | ROADMAP.md: "Soundness.lean, DenseSoundness.lean, and DiscreteSoundness.lean are all entirely sorry-free." |
| `valid_dense` and `valid_discrete` definitions exist | `Validity.lean` lines 162-186 |
| Chronicle uses Rat as implementation domain | `ChronicleTypes.lean` imports `Mathlib.Data.Rat.Defs`; `ChronicleToCountermodel.lean` imports `Mathlib.Algebra.Order.Ring.Rat` |
| Discrete completeness needs separate construction | `DiscreteSoundness.lean` uses `[SuccOrder D]`, Q construction cannot produce discrete models |
| Non-domain extension is unprovable under strict semantics | `07_team-research.md` Critical Finding #2; `08_verbrugge-step-by-step.md` Section 3.3 |

---

## Confidence Level

**Architecture claim (one construction, three theorems)**: HIGH (85%). The parametric infrastructure is already designed this way; the literature confirms this is standard; the only uncertainty is whether the subtype-indexed model for Phase A can be cleanly extended to the density phase without breaking the AddCommGroup instance requirements.

**Phase A = Base completeness via chronicle**: HIGH (90%). This is what task 107 is already doing; the team research identified concrete fixes.

**Phase B = Dense completeness via chronicle + density phase**: MEDIUM (70%). The Verbrugge odd-stage density insertion is well-understood theoretically, but implementation depends on Phase A completing the between-point insertion infrastructure. The main technical risk is that the limit_dom subtype may lack a DenselyOrdered instance (since you cannot guarantee a countable dense subset is isomorphic to Q without Cantor's theorem).

**Phase C = Discrete completeness needs separate task**: HIGH (85%). Q-based construction cannot produce discrete models; Int-indexed chain is the correct approach; this is well-understood in the literature (Verbrugge Theorem 6 for Z).
