# Teammate D: Strategic Horizons — Long-Term Completeness Architecture

Task: 123 | Date: 2026-05-11 | Round: 02

---

## 1. Completeness Structure: The Three-Way Case Split

`bx_completeness` in `Completeness.lean` proves the theorem by contrapositive:
assume phi is not derivable, build a countermodel. The proof does a
two-level case split on box-formulas in the MCS M:

```
Case 1: □(F'T) ∈ M  →  "dense" — all box-equivalent MCS's are dense
  → dd_countermodel_chronicle_dense (sorry-free, D = Rat)

Case 2: ¬□(F'T) ∈ M, □(U(T,bot)) ∈ M  →  "purely discrete"
  → dd_countermodel_chronicle_discrete (1 sorry: succ_embed_surjective, D = Int)

Case 3: ¬□(F'T) ∈ M, ¬□(U(T,bot)) ∈ M  →  "mixed"
  → dd_countermodel_chronicle_mixed_sorry (sorry, not started)
```

The dense case is fully sorry-free. The discrete case is structurally complete
with one sorry (`succ_embed_surjective`). The mixed case is a stub sorry.

### What dd_countermodel_chronicle_discrete provides

`dd_countermodel_chronicle_discrete` (lines 2495-2522) is the discrete
countermodel. It is ALREADY assembled:

- `cantor_bfmcs_discrete`: BFMCS on Z — sorry-free
- `cantor_bfmcs_discrete_restricted_buc`: backward until/since coherence — sorry-free
- `cantor_bfmcs_discrete_restricted_tc`: temporal coherence — calls `succ_embed_surjective`
- `cantor_bfmcs_discrete_restricted_fuc`: forward until/since coherence — calls `succ_embed_surjective`
- The countermodel theorem itself compiles, with sorry propagated from `succ_embed_surjective`

The dense case structure (Cantor iso → Q-embedding → cantor_bfmcs_dense) informed
the discrete design: succ-based embedding → Z-embedding → cantor_bfmcs_discrete.
Both follow the same pattern: build a strictly monotone embedding into a known
ordered type, transport chronicle coherence through the embedding.

---

## 2. The ROADMAP and Long-Term Goals

From `specs/ROADMAP.md`:

**Phase 1 (current)**: Sorry-free completeness — the primary goal.

**Phase 2** (after sorry-free): Axiom cleanup
- Remove TF axiom (task 124)
- Remove A4a (task 115)
- Redefine G/H/F/P via U/S (task 116)
- Target: primitives reduce to {S, U, □, →, ⊥}

**Phase 3**: Algebraic representation — Jónsson-Tarski for the BAO with binary S/U
and unary □ (task 125), leveraging Venema 1993.

**Phase 4**: Publication quality — verification audit (task 95), genuine `truth_at`
completeness (task 8).

The sorry inventory today is:
- 1 sorry on the critical path: `succ_embed_surjective` in `ChronicleToCountermodel.lean`
- 1 sorry for the mixed case: `dd_countermodel_chronicle_mixed_sorry`
- ~17 dead-code sorries in the abandoned BXCanonical path (task 109, abandoned)

---

## 3. Could the Construction Be Modified to Guarantee Surjectivity?

### The core obstacle

`succ_embed_surjective` requires that the succ-orbit from root is COFINAL in
`LimitDomSubtype`. The omega-chain construction uses `Classical.choose` for new
domain points, producing rationals at arbitrary positions. The C5 (Until-witness)
adding creates points at specific rational coordinates chosen by the oracle.

### Could we choose rationals that guarantee surjectivity?

In principle, if the construction placed new domain points ONLY at positions of
the form `succ^n(existing_point)`, the embedding would be surjective by
construction. But the construction cannot control future insertions by C4
(counterexample elimination), which inserts midpoints at specific positions to
refute counterexamples.

**The mathematical verdict** (per reports 06 and 07): Surjectivity IS true for the
current construction — the single-orbit argument shows it. The obstacle is
formalization, not the choice of rationals. Modifying the construction to use
integer-spaced rationals would make the surjectivity trivially obvious but would
break the sorry-free proofs about C4/C5 interaction that took task 107 (9 phases)
to establish.

**Recommendation**: Do not modify the construction. Prove surjectivity for the
existing construction. The single-orbit argument (Section 6.9 of report 07) is
the most promising path.

---

## 4. Task 122 vs Task 123: Should They Be Consolidated?

### Original scope
- Task 122 was "Build the discrete BFMCS" — the construction and coherence conditions
- Task 123 was "Fix C5 witness bot and prove Icc finiteness" — specific proof obligations

### Current state (per reports 06 and 07)
Task 123 has done essentially ALL the work that was originally task 122:
- Built `succ_embed`, `succ_embed_no_gap`, `succ_embed_squeeze` (all sorry-free)
- Built `cantor_bfmcs_discrete` with all three coherence conditions (sorry-free except surjectivity)
- Built `dd_countermodel_chronicle_discrete` (the BFMCS wiring, compiles with sorry propagation)

What remains:
- `succ_embed_surjective` (2 sorry sites in task 123)
- `dd_countermodel_chronicle_mixed_sorry` (mixed case, not assigned to either task)
- `dd_countermodel_chronicle_nondense_sorry` at line 836 is now DEAD CODE (superseded by
  the discrete and mixed stubs)

### Recommendation on consolidation

**Consolidate task 122 into task 123.** The BFMCS construction work that was task 122's
purpose is now substantially complete as part of task 123. What remains is:

1. Prove `succ_embed_surjective` — the cofinality/single-orbit argument
2. Handle the mixed case `dd_countermodel_chronicle_mixed_sorry`

Neither of these fits the original task 122 description ("build the discrete BFMCS"),
but both are needed to close the discrete/mixed branches. Task 122 should be marked
[EXPANDED] or [COMPLETED-PARTIAL] with its remaining work folded into task 123.

---

## 5. The Mixed-Case Sorry: Open Problem or Architecture Artifact?

### What the mixed case is

`dd_countermodel_chronicle_mixed_sorry` handles:
```
¬□(F'T) ∈ M   (not all box-equiv worlds are dense)
¬□(U(T,bot)) ∈ M  (not all box-equiv worlds are discrete)
```

This means: in the MCS M, some box-accessible worlds have density (F'T), and
others have discreteness (U(T,bot)). Different families in any BFMCS would need
different domain types (Q for dense, Z for discrete), but a BFMCS has a single
fixed domain type D.

### Is this a genuine open problem?

**Assessment**: This is a genuine structural difficulty but NOT necessarily an open
mathematical problem. Three angles:

**Angle 1 — The case may not arise.** If BX contains a theorem saying that modal
uniformity forces ¬□(F'T) ∧ ¬□(U(T,bot)) to be inconsistent, the mixed case would
be vacuous. This is worth verifying: is the mixed case actually reachable? If every
MCS with ¬□(F'T) ∈ M necessarily has □(U(T,bot)) ∈ M (or vice versa), then the
case split at line 154-164 in Completeness.lean would reduce to just two cases.

Specifically: in the BX system, does ¬□(F'T) imply □(U(T,bot))? This would mean
"non-dense everywhere implies discrete everywhere." On strict linear orders, this
need not hold (e.g., the order type ω + ω* has neither property globally), so the
mixed case probably arises in principle. But whether it arises in BX models is a
question about the interaction of the uniformity axioms with the order properties.

**Angle 2 — A different case split.** Instead of splitting on □(F'T) vs □(U(T,bot)),
one could split on the order type of the BFMCS domain. The Completeness proof
currently presupposes: dense = Q, discrete = Z, mixed = open. An alternative would
be to build a single BFMCS on an arbitrary countable linear order (the limit domain
itself) and then invoke a more general representation theorem that works for any
countable strict linear order. This would eliminate the need for the Cantor iso
(already eliminated in the dense case by task 117's plans) and the Z-iso, handling
all three cases uniformly.

**Angle 3 — The construction already handles mixed domains.** The underlying
chronicle construction (ChronicleConstruction.lean, sorry-free) does NOT require
pure density or pure discreteness. It works for any MCS. The `LimitDomSubtype` is
a subtype of Q that can be neither dense nor discrete. The sorry arises only in
`ChronicleToCountermodel.lean` where we try to embed this mixed domain into either
Q (requiring density) or Z (requiring discreteness).

**Key insight**: The solution to the mixed case is likely to use the limit domain
DIRECTLY as the model domain, without embedding into Q or Z. The parametric
representation theorem is already parameterized by D (AddCommGroup + LinearOrder);
if D = LimitDomSubtype (or more precisely, Q with the limit_f function extended to
all of Q), the mixed case would be handled automatically.

This is precisely what task 117 was planning (using X ⊂ Q as inclusion rather than
Cantor isomorphism). If task 117 is implemented, the dense case on Q would not need
the Cantor iso, and the same approach would work for the mixed case.

### Recommendation on the mixed case

The mixed case is best addressed by Task 117's approach: use the natural inclusion
X ⊂ Q (limit domain as a subset of Q) instead of any iso. This would:
- Eliminate the need for the Cantor iso (already planned)
- Handle the dense, discrete, and mixed cases uniformly in a single theorem
- Avoid the three-way case split entirely

If Task 117 is implemented correctly, the three-way case split at lines 148-165 of
Completeness.lean should collapse to a single case: "build countermodel on Q (or the
limit domain) using the natural inclusion."

---

## 6. What Would Publication Require?

### Critical-path sorry count

As of 2026-05-11:

| Sorry | File | Status | Path |
|-------|------|--------|------|
| `succ_embed_surjective` (×2) | ChronicleToCountermodel.lean:2060, 2063 | Open | Critical: blocks discrete branch |
| `dd_countermodel_chronicle_mixed_sorry` | ChronicleToCountermodel.lean:2546 | Open | Critical: blocks mixed branch |
| ~17 BXCanonical sorries | RootScopedChain.lean + others | Dead code | Not on critical path |

For `bx_completeness` to be sorry-free, BOTH open critical-path sorries must be closed.

### Minimum viable completeness result

Option A: Prove sorry-free completeness for the **dense case only**. This is already
done (`dd_countermodel_chronicle_dense` is sorry-free). It gives completeness for
dense linear orders, which is a published result (Burgess 1982 Chapter 1, reproved
in Lean 4 with full formal verification).

Option B: Prove sorry-free completeness for **dense + discrete cases**. This requires
closing `succ_embed_surjective`. Per reports 06 and 07, this is mathematically true
and estimated at 80-150 lines via the single-orbit/accumulation approach.

Option C: Prove sorry-free completeness for **all three cases** (full `bx_completeness`).
This additionally requires the mixed case, which may be best handled by task 117.

**For publication**, a sorry-free proof of Option B would already be a substantial
contribution, constituting a machine-verified completeness theorem for the
dense-and-discrete fragment. The mixed case can be noted as future work with
reference to task 117's planned approach.

However, if "mixed" linear orders are rare or absent in practice (e.g., every BX
model is either dense or discrete), and if this can be shown axiomatically (Angle 1
above), then Option B would actually cover all practical completeness.

### The sorry that matters most for near-term progress

`succ_embed_surjective` is the most actionable. It is:
- Mathematically true (verified by 3 rounds of team research, reports 06-07)
- Structurally isolated (2 sorry sites in one function, with full context provided)
- Estimated at 80-150 lines with a known proof strategy
- Not blocked by any other unresolved sorry

The mixed case sorry is mathematically deeper and may require a different
architectural approach (task 117 refactoring) before it can be resolved.

---

## 7. Strategic Recommendations

### Immediate priority

**Prove `succ_embed_surjective`** using the single-orbit argument:

1. Prove `succ_orbit_above_cofinal`: for any w in LimitDomSubtype above root, there
   exists N such that `succ^N(root) >= w`. Proof by contradiction via the interleaving
   argument from report 07, Sections 6.8-6.9.

2. Prove `succ_orbit_below_cofinal`: symmetric for the negative direction.

3. Derive `succ_embed_surjective` from cofinality + `succ_embed_squeeze`.

The key mathematical idea: if the succ-orbit from root does NOT reach w, then
the orbit is bounded above by w. By `succ_le_iff`, all orbit elements stay <=
any limit_dom point above the orbit. The pred-chain from w then descends through
domain points all above the orbit. These two sequences must eventually interleave
(orbit from below, pred-chain from above, both in LimitDomSubtype, both with
no-gap between consecutive elements). The interleaving contradicts the immediate
successor/predecessor no-gap property.

### Medium-term priority

**Reassess the three-way case split** after `succ_embed_surjective` is proved.
If task 117 (natural inclusion X ⊂ Q) can handle the mixed case uniformly, then:
- The discrete case could be folded into task 117's unified approach
- The three-way case split simplifies to one case
- The Z-iso infrastructure becomes legacy code

This would be the cleanest long-term architecture.

### Task sequencing

```
Immediate: close succ_embed_surjective [task 123]
  → closes discrete branch of bx_completeness (Option B)

Parallel: implement task 117 (natural inclusion)
  → closes dense case without Cantor iso
  → provides uniform approach for mixed case
  → may eliminate need for three-way case split entirely

Then: close mixed case [task 122 residual or new task]
  → full sorry-free bx_completeness (Option C)

Then: Phase 2 axiom cleanup [tasks 124, 115, 116]
Then: Phase 3 algebraic representation [task 125]
Then: Phase 4 publication quality [tasks 95, 8]
```

### On task 122 disposition

Mark task 122 as [COMPLETED-PARTIAL] or absorb remaining work into task 123.
The substantive BFMCS construction work is done. What remains is:
- `succ_embed_surjective` (task 123's core remaining obligation)
- The mixed-case sorry (best handled by task 117 refactoring, or a new task)

### On the BXCanonical dead code

The ~17 sorries in the abandoned BXCanonical path (task 109) are dead code.
They should be archived to `Boneyard/BXCanonical/` to reduce cognitive overhead.
This is low-priority but would clean up `#print axioms` output and reduce
confusion about the sorry count.

---

## 8. Summary

| Question | Assessment |
|----------|-----------|
| Remaining sorries on critical path | 2: `succ_embed_surjective` + `mixed_sorry` |
| Is `succ_embed_surjective` true? | YES (mathematically verified, reports 06-07) |
| Is the mixed case a genuine open problem? | Partially — best resolved by task 117 approach |
| Should task 122 be consolidated with task 123? | YES — BFMCS construction is already in 123 |
| Could construction be modified for surjectivity? | Not recommended (breaks sorry-free work) |
| What is the minimum viable completeness result? | Dense + discrete (Option B) — actionable now |
| What is needed for publication? | Either Option B (dense+discrete) or Option C (all cases) |
| What does the ROADMAP say? | Phase 1 = sorry-free completeness; then cleanup, algebra, publication |
| Most impactful next action | Prove `succ_embed_surjective` via single-orbit argument |
