# Teammate D Findings: Round 43 - Strategic Horizons

**Task**: 93 - Complete BXCanonical embedding
**Date**: 2026-04-19
**Role**: Horizons (strategic direction and long-term architecture)
**Session**: Round 43 team research

---

## Key Findings

### 1. Literature Deep Dive: How Standard Proofs Handle F-Obligation Resolution

After searching for the primary references (Burgess 1982/1984, Reynolds, Goldblatt, GHR 1994,
Hodkinson-Reynolds handbook chapter), I found that PDF access to the key papers is blocked
(compressed/encrypted). However, from secondary sources and paper abstracts, the following
picture emerges:

**Standard Approaches in the Literature**

The completeness literature for Since-Until tense logics uses one of three main strategies:

**Strategy A: The "Step-by-Step" / Constructive Method (Burgess, Verbrugge)**
- Build the canonical chain constructively, one step at a time
- At each step, the seed is CHOSEN to ensure the target eventuality is satisfied
- This avoids the Lindenbaum non-determinism problem by construction
- The resulting chain is NOT a general MCS chain -- it is a purpose-built sequence
- Burgess (1982) describes his completeness proofs as "relatively simple modifications
  of the usual proofs" -- suggesting the key move is exactly this: modify the chain
  construction to control defect resolution
- Key insight: they do NOT prove "F(phi) eventually resolves" as a property of an
  arbitrary MCS chain. Instead, they BUILD a chain where resolution is guaranteed.

**Strategy B: Filtration / Finite Model Property**
- Use the FMP to reduce to finite models (Segerberg's standard approach)
- Not available here: the current codebase explicitly rejects this path
  (decidability-based completeness excluded as a path to the representation theorem)

**Strategy C: Quasimodel / Mosaic Method**
- Build finite partial models (mosaics) and piece them together
- The BXCanonical codebase already has this infrastructure (Quasimodel/ directory)
  for the Until/Since truth lemma, but it was not applied to the BFMCS construction

**The Critical Observation**: The Burgess constructive method and the mosaic method
BOTH avoid the control problem by ensuring resolution by construction. The problem this
project has spent 42 rounds on -- "how do we prove F(phi) resolves on an MCS chain where
Lindenbaum is non-constructive" -- may be UNSOLVABLE as stated. Standard proofs avoid
it by building the chain differently.

### 2. The Current Chain Architecture: What Plan v42 Actually Does

Reading the code, Plan v42 has made real progress on this. The `preserving_fwd_step`
function (RootScopedChain.lean:551-560) uses `defect_step_choice_early`, which wraps
`resolving_enriched_fwd_exists`. This guarantees:
- At each step with active defects: at least one defect w is directly resolved (w ∈ M')
- ALL F-obligations for sigma_list formulas are preserved (F(chi) ∈ M' for all chi ∈ sigma_list)
- g_content(M) ⊆ M'

This is EXACTLY the constructive approach! The chain is NOT a round-robin chain --
it uses `defect_step_choice_early` to pick a step that resolves at least one defect
and preserves all others.

The remaining sorry in `fwd_chain_forward_F` (line 1090-1111) is now just about showing
this chain eventually resolves EVERY formula. The comment in the code correctly identifies:
- F(phi) persists forever (by fwd_chain_F_persistent)
- At each step, at least one defect is resolved
- If phi is never resolved, then at every step, some OTHER defect w ≠ phi is resolved

**The termination question**: Does some OTHER defect being resolved eventually lead to
phi being resolved? This is exactly where the argument needs to close.

### 3. The Key Mathematical Insight for fwd_chain_forward_F

**The standard argument in the literature**: The termination argument for defect resolution
typically works by finding a WELL-FOUNDED MEASURE that strictly decreases. In the
finite-Hintikka-point setting, the defect COUNT decreases (old resolved defects never
re-enter). In the MCS setting with reflexive semantics, phi ∈ M → F(phi) ∈ M, so
resolved defects CAN re-enter as defects immediately.

**Why the BX11 fold approach can still work**: The `preserving_fwd_step` with
`defect_step_choice_early` guarantees:
```
∃ w ∈ sigma_list, F(w) ∈ M ∧ w ∈ M'
```
This says: in M', some w is directly present. But since w ∈ M' → F(w) ∈ M',
the defect w immediately re-enters. The defect count (number of formulas in sigma_list
with F-obligations) does NOT decrease.

**The correct termination measure**: Not the defect count, but rather:
the NUMBER OF DISTINCT formulas w from sigma_list that appear directly in the chain
(not just as F-obligations) between steps n and n+m. This count is bounded by
|sigma_list| and each resolved step contributes a new member w to this set.

Wait -- this also fails because w can appear repeatedly (F(w) → F(F(w)) by F-reflexivity,
so w will be re-resolved at each visit).

**The deeper issue**: The comment in the code at line 1511-1541 (the Defect-Driven Forward
Chain section) identifies a crucial strategy:

```
5. If F(ψ) is killed at step s by a resolving step for χ: then F(χ) was also in
   chain(n) (since it was in chain(s) and F-obligations only decrease). After χ's
   resolution, F(χ) may or may not persist, but the total number of other defects
   whose resolving steps could kill F(ψ) in a FUTURE round strictly decreases.
6. By well-founded induction on the number of OTHER active defects at step n,
   ψ is eventually resolved.
```

**Assessment of this argument**: This is the RIGHT structure. The key claim is:
"the number of OTHER active defects that could KILL F(phi) in a future round strictly
decreases." But F(phi) CANNOT be killed with the `preserving_fwd_step` -- it has
F-preservation built in! F(phi) persists at every step (fwd_chain_F_persistent, line 1071).

So the argument simplifies to: F(phi) always persists. At each step, at least one
defect w is resolved (w ∈ chain(n+1)). The question is: is phi eventually chosen as
that defect?

**The key**: `defect_step_choice_early` does NOT guarantee that phi specifically is
resolved -- only that SOME defect w is resolved. To guarantee phi is eventually chosen,
we need to show the chain cannot ALWAYS pick some other w ≠ phi.

### 4. The Termination Gap and Two Viable Approaches

**Approach X: Well-founded induction on a lexicographic measure**

Define the measure at step n as:
```
(number of formulas chi ∈ sigma_list with F(chi) ∈ chain(n) AND chi NOT yet directly
 resolved at any step in [0, n])
```

But this is ill-defined because "not yet resolved" depends on the whole history.

Alternatively: for a given phi, count the number of OTHER defects chi in sigma_list
such that at the current step, `bx11_earlier chain(n) chi phi` (chi is "earlier" than
phi in BX11 ordering). Each time `defect_step_choice_early` resolves a different chi,
this count might decrease -- but the BX11 ordering changes with each step.

This measure is not monotone, so induction fails.

**Approach Y: Direct construction with target forcing (most viable)**

Replace `defect_step_choice_early` (which resolves AN ARBITRARY defect) with a
construction that, for a GIVEN phi, builds a chain that eventually resolves phi.

The key theorem `discharge_single_step` (line 905) already does this:
given F(phi) ∈ M, there exists M' with phi ∈ M' and g_content(M) ⊆ M'.

The only problem with using `discharge_single_step` is: it does NOT preserve other
F-obligations (the seed is just {phi} ∪ g_content(M), without f_carry).

**However**: For `fwd_chain_forward_F`, we only need to show phi is eventually resolved.
We do NOT need to show ALL defects are simultaneously resolved -- that is the job of
the overall chain construction. For the forward_F PROPERTY ALONE, we can construct a
SEPARATE witness chain using repeated `discharge_single_step` calls:

Witness chain construction for phi:
1. Start at M_n = chain(n) where F(phi) ∈ chain(n)
2. Apply `discharge_single_step` to get M' with phi ∈ M'
3. Return m = n+1, take chain(m) = M' for purposes of the witness

But wait -- we need phi ∈ chain(m) where chain is the ACTUAL dd_chain, not a separately
constructed witness chain. The theorem `fwd_chain_forward_F` is about the FIXED chain
`fwd_chain_of_sigma`.

### 5. The Architecture Assessment

After analyzing the code and literature, here is the honest strategic assessment:

**The current `preserving_fwd_step` architecture IS the right approach**, but the
`fwd_chain_forward_F` sorry requires a different argument than what has been tried.

**Concrete path to closing `fwd_chain_forward_F`**:

The `preserving_fwd_step` at each step either:
(a) Uses `defect_step_choice_early`: resolves SOME defect w, preserves ALL F-obligations
(b) Falls through to `fwd_succ` (when no defects): uses round-robin target

In case (a), `defect_step_choice_early` is defined as:
```lean
(defect_step_early h_mcs defects h_nonempty h_F).choose
```

The `defect_step_early` theorem guarantees:
- ∃ w ∈ defects, F(w) ∈ M ∧ w ∈ M'
- ∀ chi ∈ defects, F(chi) ∈ M'

The crucial observation: phi ∈ defects at EVERY step n' ≥ n (because F(phi) persists).
So phi is ALWAYS a member of `defects`. Therefore, `defect_step_choice_early` witnesses
SOME w ∈ defects at each step. But which w?

**The non-determinism**: `.choose` picks ANY M' satisfying the existential. We cannot
control which w gets resolved.

**The fix**: We need a DIFFERENT chain definition where phi gets resolved eventually.
The most principled approach: use `target_stays_direct_in_fold` (which IS already
proved, at line 959) to construct a phi-specific resolution chain.

But `target_stays_direct_in_fold` requires phi to be bx11_earlier than ALL other defects.
This is not guaranteed.

**Alternative fix**: Weaken what we need. The `restricted_temporally_coherent` property
(the target of `dd_bfmcs_restricted_tc`) asks for phi in some FMCS family. The
`dd_bfmcs` has MULTIPLE families -- one per modal-equivalence class. We need phi to
appear in chain(m) for the SPECIFIC family containing chain(0) = M_0.

What if we construct a DIFFERENT BFMCS where, for each phi, there is a family whose
chain specifically resolves phi? This is closer to the standard "step-by-step" approach
from the literature.

### 6. Recommended Architecture Change

**Recommended Approach**: Build a SEPARATE chain for EACH formula that needs to be
resolved, rather than one chain that tries to resolve all formulas.

For each phi ∈ deferralClosure(root), construct a phi-resolving FMCS:
- phi-fmcs(phi) := a chain built by `self_resolving_fwd_step` at step n
  where F(phi) ∈ chain(n), and `fwd_succ` at other steps
- `self_resolving_fwd_step` (line 1594) already constructs exactly this: given F(phi) ∈ M,
  build M' with phi ∈ M' AND F(phi) ∈ M' (the self-resolving seed {phi, F(phi)} ∪ g_content)

Wait -- this collapses back to `restricted_tc` requiring phi ∈ chain(m) for the SAME
chain as M_0.

**The real fix**: The `restricted_temporally_coherent` definition uses a FIXED family
(shifted_dd_fmcs N h_N sigma_list s). All witnesses must come from WITHIN this family.
This is the core constraint.

The standard literature avoids this by having EITHER:
1. A single chain that resolves everything (the constructive approach)
2. A semantic argument that the chain is already a valid model (without proving syntactic
   eventuality resolution)

### 7. Critical Re-examination of fwd_chain_forward_F

**The key question**: Is `fwd_chain_forward_F` actually provable with the current
`preserving_fwd_step` / `defect_step_choice_early` approach?

**YES, here is the argument** (which has not been tried in the code yet):

The argument requires well-founded induction on `(sigma_list.length - number of formulas
in sigma_list resolved within a bounded window)`.

More precisely: let S = sigma_list. Define:
- At step n, phi ∈ S with F(phi) ∈ chain(n)
- At step n+1: `defect_step_choice_early` resolves SOME w ∈ active_defects
- Case 1: w = phi. Done, phi ∈ chain(n+1).
- Case 2: w ≠ phi. Then F(phi) ∈ chain(n+1) (F-preservation). Apply recursion at n+1.

This naive recursion has no termination guarantee. BUT:

**Key new observation from `defect_step_choice_early`**: The resolved w is FIXED by
Classical.choice (it is `(defect_step_early ...).choose`). The SEQUENCE of resolved
formulas at steps n, n+1, n+2, ... is SOME sequence. Since sigma_list is finite and
`defect_step_choice_early` always resolves A member of `active_defects`, in any window
of |sigma_list| steps, at least one member of sigma_list is resolved.

Does phi HAVE TO BE resolved within any window? Not necessarily -- `.choose` could
always pick the same w ≠ phi.

**BUT**: the semantics of Classical.choice is: it picks A FIXED element satisfying the
predicate. For a given M and defects, `defect_step_early h_mcs defects h_nonempty h_F`
returns a specific proof object, and `.choose` extracts the first existential witness.
This FIXED choice could in principle always pick w = phi OR always pick w ≠ phi.

The sorry IS genuinely hard. Classical.choice is the obstruction.

### 8. Conclusion: What the Literature Actually Does

The Burgess "constructive" completeness proof (which his 1982 paper describes as a
"relatively simple modification") CONTROLS which defect gets resolved at each step.
It does not use Lindenbaum's lemma (which is non-constructive) to pick the MCS --
it SPECIFIES the MCS at each step using a DETERMINISTIC seed that resolves the CURRENT
target.

The key move: enumerate the eventualities (F(phi_1), F(phi_2), ..., F(phi_k)) in a
finite list and build the chain by, at step i, ensuring F(phi_{i mod k}) gets resolved
if it was present. This IS a round-robin approach, but the seed at each step is CHOSEN
to include phi_{i mod k} directly, not just via BX11 fold.

The problem with this in the BX canonical setting: at step i, we want phi_{i mod k} ∈ M',
but the seed {phi_{i mod k}} ∪ g_content(M) may not preserve other F-obligations
(seeds that include both phi_target and f_carry(M) are inconsistent in general, as
established in dead end #13 in ROAD_MAP.md).

**The mathematical resolution**: The literature ACCEPTS that the canonical chain resolves
each eventuality INDEPENDENTLY -- it proves for each phi separately that there exists
SOME future point (possibly a different step for each phi) where phi holds. The chain
is not built to simultaneously track all eventualities; instead, for each phi, the proof
finds a step where phi happens to be resolved.

With `preserving_fwd_step`, the chain guarantees:
- F-preservation for ALL sigma_list formulas at EVERY step
- Resolution of AT LEAST ONE defect at each step

This is STRONGER than what Burgess needs. But proving phi is EVENTUALLY the chosen
resolved formula is the gap.

**The simplest fix I can identify**: Change `defect_step_choice_early` to a
DETERMINISTIC function: given M with active defects, pick the FIRST defect in
`active_defects M sigma_list` (in sigma_list order) and resolve it. Then:
- At every step, the FIRST defect in sigma_list order gets resolved (if it has an
  active F-obligation)
- If phi is at position i in sigma_list, after all formulas before phi in sigma_list
  have been resolved at least once, phi becomes the first active defect and gets resolved
- This is a round-robin with GUARANTEED resolution in order

**Critical question**: Can we define `defect_step_choice_early` to resolve the FIRST
defect (in sigma_list order) rather than an ARBITRARY defect? The current code uses
`.choose` on `defect_step_early`, which gives an arbitrary result. If we instead use
`self_resolving_fwd_step` for the FIRST defect (head of active_defects), we get:
1. First defect phi_first ∈ chain(n+1) (by self_resolving_fwd_step_target)
2. F(phi_first) ∈ chain(n+1) (by self_resolving_fwd_step_F_target)
3. g_content(M) ⊆ chain(n+1) (by self_resolving_fwd_step_g_content)
4. F-obligations for OTHER defects: NOT preserved by self_resolving_fwd_step

Problem (4): self_resolving_fwd_step uses seed {phi_first, F(phi_first)} ∪ g_content(M),
which does NOT include f_carry(M). So F-obligations for other defects are lost.

This brings us back to the fundamental tension: can't preserve ALL F-obligations while
DETERMINISTICALLY resolving a specific target.

### 9. Final Strategic Assessment

**The Control Problem is Real**: After 43 rounds, the fundamental issue is clear: it is
IMPOSSIBLE to simultaneously (a) guarantee a specific phi gets resolved, AND (b) preserve
all other F-obligations, using a single Lindenbaum extension from the BX canonical frame.
This is MATHEMATICS, not a Lean implementation issue.

**What the standard literature actually does** (from available secondary sources):
Standard completeness proofs for Since-Until over linear orders use one of:
1. **Finite Hintikka sets** (not full MCS): finite objects where defect COUNT genuinely
   decreases. The BXCanonical codebase uses this for the Until/Since truth lemma
   (Quasimodel/ directory) but NOT for the BFMCS temporal coherence.
2. **Semantic argument**: show the chain is already a valid model by Zorn's lemma or
   König's lemma, not by tracking defects syntactically.
3. **Axiom of Choice with control**: pick MCS extensions that satisfy additional constraints
   beyond just being MCS. This is non-standard and requires additional axioms.

**The viable path forward** (based on code analysis, not literature search):

The current `preserving_fwd_step` / `defect_step_choice_early` approach is CORRECT in
structure. The missing piece for `fwd_chain_forward_F` is a STRONGER CHOICE PRINCIPLE:

Instead of `(defect_step_early h_mcs defects h_nonempty h_F).choose` (arbitrary choice),
we need:
```
defect_step_early_for_phi h_mcs phi h_nonempty h_F
```
which returns M' where SPECIFICALLY phi ∈ M' (not just some arbitrary w).

But this conflicts with F-preservation. Unless:

**The Resolution**: For `restricted_tc`, we only need phi ∈ chain(m) for SOME m > n.
We do NOT need F-preservation at that step. We can:
1. Use F-preservation to bring F(phi) to step n_visit where phi would be first in sigma_list
2. At step n_visit, use `self_resolving_fwd_step` (or `discharge_single_step`) to get
   phi ∈ chain(n_visit + 1)
3. This BREAKS the F-preservation invariant at step n_visit, but that's OK because
   we only need the ONE witness

The chain does not need to be uniform -- we can have DIFFERENT chain constructions for
different purposes: the F-preservation chain for showing F-obligations persist, and a
one-time resolution step for the actual witness.

**Concretely**:
- Prove: F(phi) persists in the preserving chain from step n to step n_visit (using
  fwd_chain_F_persistent, already proved)
- At step n_visit, construct a separate M_witness = `self_resolving_fwd_step chain(n_visit) h phi h_F`
- Show M_witness satisfies the required properties of chain(n_visit + 1) for the
  SINGLE forward_F witness
- The actual chain continues with the preserving step -- M_witness is only used as a
  WITNESS for the existential, not as the actual next chain step

This is a SEMANTIC / EXISTENTIAL argument: we don't change the chain construction;
we CONSTRUCT A WITNESS externally. The existential ∃ m > n, phi ∈ chain(m) does NOT
require phi to be in the actual preserving chain -- it can be in any MCS that satisfies
the shifted_dd_fmcs membership condition.

WAIT: `restricted_temporally_coherent` requires phi ∈ fam.mcs u for the SPECIFIC family
fam. If fam = shifted_dd_fmcs N h_N sigma_list s, then fam.mcs u = dd_chain N h_N
sigma_list (u - s). So the witness MUST come from the specific dd_chain.

**This means**: the witness phi ∈ chain(m) MUST be in the ACTUAL chain, not an
externally constructed M'. This is the fundamental constraint that makes `fwd_chain_forward_F`
hard to prove with the current construction.

### 10. Bottom-Line Recommendation

**The current plan v42 strategy is the correct direction** (use `preserving_fwd_step`
with defect_step_choice_early). The one remaining mathematical gap is:

"Does Classical.choice for defect_step_early eventually pick phi as the resolved formula?"

**The answer, based on 43 rounds of analysis**: Classical.choice is UNCONSTRAINED.
It will pick phi if and only if the proof of `defect_step_early` produces an existential
whose witness happens to have phi ∈ M'. Since the proof uses `resolving_enriched_fwd_exists`
which provides a DISJUNCTIVE result (some w in defects with w ∈ M'), Classical.choice
can legitimately pick any M' that resolves ANY defect.

**The ONLY way to close `fwd_chain_forward_F`** is to use a TIGHTER choice that specifies
WHICH defect gets resolved. This requires:

Option A (modify the chain): Define `preserving_fwd_step` to use a DETERMINISTIC
rule for which defect gets resolved (e.g., always resolve the head of `active_defects M
sigma_list`, which is the first formula in sigma_list with an active F-obligation). Then:
- At each step, sigma_list[0]'s F-obligation is resolved first, then sigma_list[1]'s, etc.
- phi gets resolved at the first step where phi is the head of active_defects
- phi becomes head when all formulas before phi in sigma_list have been resolved
- Problem: need to show formulas before phi eventually get resolved (circular dependency)

Option B (rely on self_resolving_fwd_step): Note that `self_resolving_fwd_step` produces
M' with phi ∈ M' AND F(phi) ∈ M'. This means phi will remain a defect in M'. But we
have ONE step where phi is directly present. This gives the forward_F witness.

**Option B is the key**: Define a modified chain that, for a FIXED target phi, uses
`self_resolving_fwd_step` at EVERY step (not just at phi's scheduled visit). Then:
- phi ∈ chain(n+1) always (because we always resolve phi)
- All other defects: F(psi) persists if and only if psi ∈ phi (by F(phi) propagation)
- But this chain only resolves phi, not other eventualities

This is a PER-FORMULA chain. Restricted_tc can use it: for each phi separately,
construct a phi-specific chain and show phi ∈ chain(n+1). But the BFMCS requires a
SINGLE chain that resolves ALL eventualities simultaneously.

**The correct conclusion**: `restricted_temporally_coherent` requires resolution of
ALL formulas in deferralClosure simultaneously in the SAME chain. No single-chain
Lindenbaum-based construction can guarantee this without control over the choices.

**Ultimate recommendation**: The BX canonical completeness proof should be restructured
to use the QUASIMODEL approach (already in the Quasimodel/ directory) for the BFMCS
temporal coherence, not the MCS scheduling chain. The quasimodel approach works because:
1. Hintikka sets are FINITE -- defect counts genuinely decrease
2. The `Construction.lean` QuasimodelChain already builds chains with guaranteed
   resolution for each defect in sequence
3. The `Realization.lean` lifts these to BXPoint chains

The gap (noted in Dead End #25, ROAD_MAP.md) is the BXPoint-to-Int bridging gap.
But this may be more tractable than the current approach, because the quasimodel chain
is FINITE (over deferralClosure) and can be REPLICATED to cover all Int positions.

---

## Recommended Approach

**Short-term (close fwd_chain_forward_F within plan v42)**:

The most concrete path I can identify is modifying `defect_step_choice_early` to use
`self_resolving_fwd_step` specifically when the FIRST element of `active_defects M
sigma_list` is the target. The round-robin order over sigma_list ensures each formula
becomes head at most |sigma_list| steps after all prior formulas are resolved.

**But**: this creates a circular dependency unless we can show all prior formulas are
eventually resolved. The only escape is:

Use `self_resolving_fwd_step` for ALL steps (not just when phi is the head):
- At step n: M' = self_resolving_fwd_step chain(n) h phi h_F
- phi ∈ M' (by self_resolving_fwd_step_target)
- F(phi) ∈ M' (by self_resolving_fwd_step_F_target)
- g_content(chain(n)) ⊆ M' (by self_resolving_fwd_step_g_content)
- F-obligations for OTHER defects: NOT guaranteed

For `restricted_tc`, we only need ONE phi at a time. For each phi separately, build a
phi-specific chain using `self_resolving_fwd_step`. But `restricted_tc` requires a
SINGLE chain family that works for ALL phi simultaneously.

**Alternative**: Strengthen `restricted_tc` to only require a FAMILY of chains (one
per phi), not a single chain. This would change the BFMCS interface, which is a larger
refactor. However, the existing BFMCS `restricted_temporally_coherent` type is fixed
in `Bundle/UntilSinceCoherence.lean`, so changing it requires updating the truth lemma.

**Long-term (strategic recommendation)**:

The project should seriously consider using the QUASIMODEL infrastructure that is
already proved sorry-free for the temporal coherence of the BFMCS. The path:
1. Use QuasimodelChain (Construction.lean) to build finite chains with guaranteed resolution
2. Embed these finite chains into Int-indexed FMCS via periodic repetition
3. Show the periodic FMCS satisfies all restricted coherence properties

This bypasses the Lindenbaum non-determinism problem entirely, at the cost of additional
wiring between the quasimodel and the BFMCS interface.

---

## Evidence/Examples

**Evidence that `defect_step_choice_early` is the right primitive**: The code at
lines 502-546 provides `defect_step_early` and `defect_step_choice_early_spec` which
guarantee F-preservation for ALL sigma_list formulas. This is mathematically sound and
matches the constructive literature's "resolve at least one, preserve all" principle.

**Evidence that `self_resolving_fwd_step` is the right tool for phi-specific resolution**:
Lines 1594-1629 provide `self_resolving_fwd_step` with all needed lemmas (mcs, target,
F_target, g_content). This construction guarantees phi ∈ M' AND F(phi) ∈ M'.

**Evidence of the fundamental tension**: ROAD_MAP.md dead end #13 confirms that
`{target} ∪ g_content(M) ∪ f_carry(M)` is inconsistent in general. Dead end #23
confirms `F(chi) ∈ M` does not imply `G(F(chi)) ∈ M`. These two dead ends prove that
no SINGLE Lindenbaum extension can simultaneously guarantee target resolution AND
F-preservation.

---

## Confidence Level

- **The Lindenbaum non-determinism is the irreducible obstruction**: HIGH (95%)
- **Standard literature uses constructive / finite approaches that avoid this**: HIGH (90%)
- **Plan v42 `preserving_fwd_step` is architecturally correct**: HIGH (90%)
- **`fwd_chain_forward_F` cannot be closed WITHOUT modifying the chain definition**: HIGH (85%)
- **Self_resolving_fwd_step per-formula chain is a viable path**: MEDIUM (65%)
- **Quasimodel replication approach is viable**: MEDIUM (60%)
- **Plan v42 closes all three sorries as written**: LOW (20%)

---

## Summary Table

| Approach | Closes fwd_chain_forward_F? | Closes restricted_buc/fuc? | Risk | Lines |
|----------|----------------------------|---------------------------|------|-------|
| Current plan v42 (as-is) | Need chain modification | Need enriched bwd seed | HIGH | ~300 |
| self_resolving_fwd_step chain | YES (phi-by-phi, need wiring) | No (separate issue) | MED | ~150 |
| Quasimodel replication | YES (by construction) | YES (by construction) | HIGH | ~500+ |
| Weakened restricted_tc | Avoids question | Avoids question | MED | ~200 |

The most actionable near-term path: use `self_resolving_fwd_step` to prove `fwd_chain_forward_F`
by constructing a SEPARATE witness chain for each phi (not the main preserving chain),
and argue that the `shifted_dd_fmcs` family contains this witness via a modal-equivalence
argument. This requires careful reading of the `restricted_temporally_coherent` definition
to check if the witness can come from a DIFFERENT MCS in the family.
