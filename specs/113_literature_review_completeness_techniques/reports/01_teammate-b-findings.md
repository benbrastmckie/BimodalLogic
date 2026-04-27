# Teammate B Findings: IRR-Free Techniques and Until/Since Extension

**Task**: Analyze Reynolds 1992 and Xu 1988 for techniques relevant to Phase 2 (Until/Since extension)
of the BX completeness roadmap. Focus on IRR-free methods and expressibility results.

---

## Key Findings

### Finding 1: Xu 1988 — Irreflexivity is NOT U,S-Definable (Theorem 2.9)

**Core result**: Xu proves (Theorem 2.9) that there is no U,S-tense formula defining any of:
- `∀xy ¬(x < y ∧ y < x)` (asymmetry / anti-symmetry)
- `∀x ¬(x < x)` (irreflexivity)
- `∀xy(x < y ∧ y < x → x = y)` (antisymmetry)

**Proof mechanism**: Xu's construction in Section 2 (the K-structure machinery) is explicitly designed
so that the finite sub-frames (T,<) in K satisfy **anti-symmetry but NOT irreflexivity** (condition C1:
`∀xy¬(x<y∧y<x)` = "no symmetric pairs", which forbids 2-cycles but allows x<x). The key step in
Theorem 2.9 is that any countermodel built by the omega-chain construction has the property C1
(anti-symmetric), and since no formula can detect whether C1 holds (the construction works for
the entire class), irreflexivity is not definable.

**Implication for BX**: This result is **decisive**. Since irreflexivity is not U,S-definable:
- The chronicle construction CANNOT be completed purely by adding U,S-axioms
- The binary `g(x,y)` function in the Burgess chronicle is NOT serving primarily as a semantic device
  for encoding irreflexivity — it is instead the mechanism by which the construction forces
  witnesses to exist **within** the constructed domain while maintaining C3 three-way decomposition
- The C4/C4' conditions (which use `g(x,y)` via `burgessR3`) are the indirect mechanism for
  enforcing irreflexive-like behavior at the chronicle level, not via an axiom

**Critical consequence for the codebase**: The 5 `c2'` sorry sites in `CounterexampleElimination.lean`
(lines 786, 824, 864, 902, 938, 970) are NOT blocked by a fundamental mathematical impossibility —
they require **constructing a valid `g(x,y)` assignment for new adjacent pairs** introduced during
point insertion. Xu's result confirms this is engineering work on the `g`-function construction, not
a conceptual gap.

### Finding 2: Reynolds 1992 — The IRR-Free Mechanism

**Core innovation**: Reynolds avoids the IRR rule by replacing the Gabbay-Hodkinson axiom pair
(which relied on unique names from IRR) with two stronger axioms:

- **Prior-U**: `U(⊤, p) ∧ F¬p → U(¬p ∨ K⁺(¬p), p)` — no definable left gaps
- **Prior-S**: mirror for Since
- **Sep**: `K⁺p ∧ ¬K⁺(p ∧ U(p, ¬p)) → K⁺(K⁺p ∧ K⁻p)` — separability (Hodkinson)

**Why IRR was useful**: The original Gabbay-Hodkinson proof used IRR to give each point a "name"
`q ∧ H(¬q)`, making `U` and `S` definable in terms of `F` and `P` via the axiom (UU). This reduced
the harder U/S construction to the simpler F/P construction. Reynolds avoids this by using the
full Burgess-Xu construction (Theorem 1 = their Corollary 1 = strong completeness over linear orders)
as the foundation for finding a rational-flowed model, then applying Doets' theorem to lift to a
real-flowed model.

**The five-step Reynolds strategy**:
1. Use Burgess-Xu strong completeness to find a rational-flowed model with Prior-U/S and Sep valid
2. Use Prior-U/S to show no definable gaps (Theorem 3: U,S expressively complete over Prior structures)
3. Prove that contemporaneous equivalence class boundaries don't coincide with gaps (Theorem 4)
4. Use Sep to ensure density of singleton classes in quotient orders (Theorem 5)
5. Apply Doets' theorem (Theorem 6) to find a real-flowed model

**Relevance to BX**: Reynolds' IRR-free completeness proof is for **pure tense logic** over the
reals — it does not directly address the BX bimodal (S5 + tense) setting. However, the key technical
innovation is the use of **expressive completeness** (Kamp's result / Theorem 3) to translate
first-order properties of the constructed model back into temporal language, enabling the gap-free
argument without relying on named points.

### Finding 3: The Connection Between Reynolds' Technique and the BX Chronicle

Reynolds' approach and the BX chronicle construction are **parallel strategies** for the same
fundamental problem, but at different levels:

| Feature | Reynolds 1992 | BX Chronicle |
|---------|--------------|--------------|
| Base completeness | Burgess-Xu over linear orders | Burgess 1982 over linear orders |
| Irreflexivity handling | Not needed (using IRR-free Prior axioms) | Handled by C4/C4' + binary g |
| Key invariant | Prior structures (no definable gaps) | C0-C5 chronicle conditions |
| Model lifting | Doets' theorem (rational → real) | Cantor isomorphism (limit_dom ≃o ℚ → all ℚ) |
| Expressibility | Kamp's theorem (expressive completeness) | Not used — direct construction |

**Crucially**: Reynolds uses the Burgess-Xu system (the same BX base) as Corollary 1, but extends
to real-number time. The BX chronicle is targeting **dense linear orders** (rational time, then
lifted to ℚ via Cantor). The two approaches address **different completeness questions**:
- Reynolds: completeness over ℝ (a specific flow)
- BX chronicle: completeness over all linear flows (then specializable to ℚ or ℝ)

### Finding 4: Reynolds' Technique Does NOT Offer an Alternative Mechanism for the Chronicle C2' Sorry Sites

**Negative result**: Reynolds' key technique — using expressive completeness to translate first-order
properties into temporal formulas, then applying Prior-U/S — is specific to structures where
Until/Since are **expressively complete**. Prior structures (satisfying Prior-U/S) eliminate definable
gaps, which is the prerequisite for Kamp-style expressive completeness.

The BX chronicle construction works with a **finite sparse domain** (not a Prior structure), building
up the model iteratively. Expressive completeness does not apply at finite stages.

**The gap is clear**: The `c2'` sorries require constructing `g(x,y)` for new adjacent pairs after
point insertion. This is a direct engineering problem about the binary interval function `g`, not
something Reynolds' approach helps with.

### Finding 5: Caleiro-Viganò-Volpe 2013 — Mosaic Approach to S5+Tense

The mosaic method provides completeness for bimodal S5+tense via a different route (mosaic
saturation), but crucially:

1. The mosaic approach handles **non-interacting combinations** cleanly — the modal and temporal
   dimensions are treated as independent mosaics (vertical = temporal, horizontal = S5)
2. For the **non-interacting case** (no BX12/BX12'-style interaction axioms), they get decidability
   and completeness with the standard S5 closure for the modal dimension
3. With interaction (like BX's `modal_future` / `temp_future` axioms), the mosaic approach yields
   only **partial results** — no full decidability in the interacting case

**Implication for BX**: The mosaic approach is NOT a shortcut for the BX completeness project. The
BX axioms `modal_future` (`□φ → □(Gφ)`) and `temp_future` (`□φ → G(□φ)`) are exactly the
"interaction" axioms that make the mosaic approach partial. The chronicle construction is the right
path precisely because it handles the interaction directly through the canonical model structure.

---

## Recommended Approach for the Until/Since Chronicle Sorries

### For `cantor_bfmcs_restricted_fuc` (ChronicleToCountermodel.lean:615-619)

**The blocker** is stated clearly in the comment at line 594-602: the forward Until/Since direction
requires `limit_satisfies_c5_full` (C5 with guard), which in turn requires C3 three-way
decomposition: `g(x,z) ⊆ f(y)` for `x < y < z`.

**Recommended approach** (HIGH CONFIDENCE):
C3 gives `g(x,z) = g(x,y) ∩ f(y) ∩ g(y,z)`, hence `g(x,z) ⊆ f(y)` for all intermediate `y`.
The C5 guard condition `φ ∈ f(r)` for intermediate points `r ∈ (t, s)` follows from:
1. BX5/self_accum_until ensures `φ U ψ ∈ f(t)` propagates to `φ ∧ (φ U ψ) ∈ f(z)` for all
   intermediate domain points `z` (via C2'/burgessR3 + BX5)
2. At the limit, `g(x,z) ⊆ f(y)` for intermediate `y` (from C3)
3. The C5 witness `y` has `ψ ∈ f(y)` (from C5_weak = `limit_satisfies_c5_weak`), and
   the guard `φ` at intermediate points follows from C3 + BX5 propagation

The path forward is to prove `limit_satisfies_c5_full` by showing that the `EliminationResult.c5_forward_witness` already captures the guard information — it is checked in `eliminate_potential_counterexample` (line 728 per the comment) but not surfaced in the result type. Strengthening `EliminationResult` to include the guard in `c5_forward_witness` would unblock this.

### For `c2'` sorries in `CounterexampleElimination.lean` (lines 786, 824, 864, 902, 938, 970)

**All six `c2'` sorry sites** arise from point insertion into a chronicle. Each inserts a new point
that creates new adjacent pairs. The C2' obligation for each new adjacent pair requires constructing
`g(x_new, y_adj)` or `g(x_adj, x_new)` satisfying `burgessR3(f(x), g(x,y), f(y))`.

**Recommended approach** (HIGH CONFIDENCE for cases 1-2, MEDIUM for cases 3-6):
- **C5 forward insertion** (line 786): New point `y` is inserted beyond `x_max`. The adjacent pair
  `(x_max, y)` needs `g`. Construct via Lemma 2.5 (PointInsertion): use `bx_forward_witness` to
  build a DCS `B` with `r3Relation(f(x_max), B, f(y))`. This is exactly what Xu Lemma 2.2 /
  `PointInsertion` provides.
- **C4/C4' insertion** (lines 864, 902, 938, 970): Inserting `z` between `x` and `y` creates
  two new adjacent pairs `(x, z)` and `(z, y)`. The C2' obligation for each pair can be met by
  decomposing the existing `g(x,y)` via C3: `g(x,y) = g(x,z) ∩ f(z) ∩ g(z,y)`. Any consistent
  DCS within `f(x)` cross-`f(z)` satisfying burgessR3 works. Xu's `burgessR3_absorption` lemma
  (if it exists in the codebase) or a direct Lindenbaum extension of `g(x,y) ∩ f(z)` should work.

---

## Evidence/Examples

**From Xu 1988, Theorem 2.9**: The proof works by observing that the K-structure construction
(Section 2) builds frames satisfying C1 (`∀xy ¬(x<y ∧ y<x)`) but NOT necessarily irreflexivity.
Since the completeness theorem (2.8) produces a model from ANY non-theorem, and the construction
only enforces C1 (not irreflexivity), no formula can distinguish "C1 + irreflexive" from
"C1 + some reflexive points." This is an expressibility impossibility result.

**From Reynolds 1992, Section 3**: The comparison with IRR is explicit: "Much use of it is made in
[7]" and Reynolds gives four philosophical reasons why orthodox systems are preferable. The key
technical point is that IRR's usefulness comes not from enforcing irreflexivity (which, by Xu,
cannot be done axiomatically) but from the **naming side effect**: `q ∧ H(¬q)` provides unique
names for points. Reynolds replaces the naming mechanism with Prior-U/S + expressive completeness.

**From ChronicleToCountermodel.lean, line 594-603**: The blocker for `cantor_bfmcs_restricted_fuc`
is explicitly documented: "Requires `limit_satisfies_c5_full` (C5 with guard)" and notes that
"the guard IS checked in `eliminate_potential_counterexample` at line 728 but discarded from the
result type." This is a **known, localized gap** — not a fundamental mathematical impossibility.

**From CounterexampleElimination.lean, EliminationResult structure (lines 728-753)**: The
`c5_forward_witness` field only guarantees `∃ y ∈ val.dom, pc.x < y ∧ pc.η ∈ val.f y` (endpoint
witness), not the guard at intermediate points. Strengthening this to include the guard is the
direct fix needed.

---

## Confidence Level

**HIGH** — the following claims are well-supported by the literature and codebase:

1. Xu 1988 Theorem 2.9 definitively establishes that IRR cannot be added as a U,S-axiom. This
   confirms the chronicle's C4/C4' conditions are the correct mechanism (not an axiom).

2. Reynolds' IRR-free technique is a different solution to a different problem (completeness over ℝ
   vs. all linear orders) and does NOT provide an alternative mechanism for the Chronicle C2'/C5
   sorry sites. The BX project does not need Reynolds' technique for its current sorries.

3. The `cantor_bfmcs_restricted_fuc` sorry (ChronicleToCountermodel.lean:615-619) is unblocked
   by strengthening `EliminationResult.c5_forward_witness` to carry guard information, combined
   with C3's property `g(x,z) ⊆ f(y)` at the limit.

4. The six `c2'` sorry sites in `CounterexampleElimination.lean` are engineering tasks requiring
   `g`-function construction for new adjacent pairs, solvable via the PointInsertion infrastructure
   (Lemma 2.5/2.6) already in place.

**MEDIUM** — the following claim is plausible but not verified against exact codebase signatures:

5. The C4 insertion cases (lines 864, 902, 938, 970) can reuse `g(x,y)` decomposition via C3 to
   construct `g(x,z)` and `g(z,y)` for inserted point `z`. The exact machinery (whether
   `burgessR3_absorption` exists) needs verification.

**LOW** — the following has not been verified:

6. Whether `limit_satisfies_c5_full` can be proved from the existing `omega_chain` infrastructure
   without major additional lemmas. The claim rests on C3 + BX5 propagation being available at
   the limit, which requires checking `limit_forward_G` propagates the BX5 self-accumulation property.
