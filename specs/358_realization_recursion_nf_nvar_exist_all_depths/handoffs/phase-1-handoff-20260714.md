# Task 358 — Phase 1 handoff (v04 plan): task-363 interface pin

**Session**: sess_1784045100_2e3ffe · **Date**: 2026-07-14 · **Plan**: plans/04_realizer-recursion-v04.md

## P1 checklist disposition

1. **Predicate signatures pinned** (ExteriorFiberConsistencyK.lean, read verbatim this session):
   - `kvE_fiberElemConsistent : {k n : Nat} → NormalForm sig (k+1) n → NormalForm sig k (n+1) → Bool`
     — depth-0 arm constantly `true`; `(j+1)` arm = (i) atom-layer mate check
     (`mergeNF (e.atom_assgn) ⟨1,_⟩ = s'.atom_assgn` for some σ-marked `s'`) `&&`
     (ii) depth recursion `kvE_fiberElemConsistent s e` on marked inner `e`.
   - `kvE_fiberConsistent σ` — σ-level `.all` over marked fibers.
   - `_zero` lemmas (`rfl`-level), `_of_realized` lemmas (honest-preservation discharge keys),
     `kvE_nf_mem_univ_toList` — all present, signatures exactly per the 363 summary contract.
2. **Exterior conjunct-2 shape pinned**: guard lives INSIDE `kvE_futAdmissible` conjunct-2 body:
   `(decide (nfk_dropFresh s = σ.1) && kvE_fiberElemConsistent σ s) || !(σ.2 s)`.
   Destructor `kvE_futAdmissible_fiber_dichotomy` (ExteriorConverterK.lean:48) reads it via
   `Bool.or_eq_true, Bool.and_eq_true, decide_eq_true_eq` — confirmed; `_onFiber`/`_offFiber`
   siblings intact.
3. **Interior antecedent PAIR pinned**: `EndIntervalConsumerK.lean` m+2 arm (`_hfiberCons` binder
   :128 + per-σ `kvE_fiberConsistent σ = true →` antecedents on `_hreal` :130/`_hexcl` :137) and
   `kampPrior_site_rungK_gate_match` (KampPrior.lean:962/:968/:975) — mirrored verbatim;
   reconstruction pattern at both consumers = modus ponens (`hfiberCons`) + case split
   (`kvE_fiberConsistent_of_realized`).
4. **Re-probe certificates GREEN** (lean_verify, this session, floor axioms
   `[propext, Classical.choice, Quot.sound]`, no sorryAx):
   `kvE_probe363_sigma_inadmissible`, `kvE_probe363_tau_admissible`,
   `kvE_probe363_qnfG1_antecedent_fails`.
5. **Anchor-content gate — PASSED-WITH-ADVERSE-FINDING (machine adjudication routed to P2)**:
   - The interface DOES recurse on `.2` and mate-check the atom layer as contracted, and
     `kvE_fiberConsistent_of_realized` supplies exactly the honest-population discharge.
   - **ADVERSE FINDING (analytical, this session)**: the mate check compares ONLY atom rows and
     imposes NO realizability/consistency-nontriviality on the mate. Candidate residual
     countermodel against G2 rows 8-11 at m = 1 (the frozen `hsliceFut` binder shape):
     `σ'' := τ ⊕ s* ⊕ s'#` where `s'# := (mergeNF (m1eP.atom_assgn) ⟨1,_⟩, fun _ => false)`
     — the atom row of the dropped separating witness `e_P` (the P-point 20 over the
     doppelgänger tail) planted as a const-false-marked INTERIOR-zone fiber.
     Claimed effects (to be machine-checked in P2's probe gate):
     (a) `kvE_fiberElemConsistent σ'' s* = true` — every marked inner of `s*` now has a mate
         (honest fibers for 8 of 9 witness classes; `s'#` for the `P ∧ (w,t)-zone` class);
     (b) `s'#` itself is on-fiber (drop-drop = doppelgänger 4-row = τ.1) and vacuously
         elem-consistent (no inner marks);
     (c) `s'#` is interior-zoned ⇒ all three EXTERIOR zone lists of `σ''` equal `m1sigma`'s ⇒
         the retained semantic fact set (`kvE_probeM1_sliceId_superseded`) carries over verbatim;
     (d) conjuncts 1/3/4 of `kvE_futAdmissible σ''` survive (interior zone order-possible;
         no self-zone contribution) ⇒ `kvE_futAdmissible σ'' = true` under the RESTATED predicate;
     (e) conclusion failure `m1_no_marked_mate` applies unchanged (gap list ∋ s*).
     If (a)-(e) machine-check, rows 8-11 remain FALSE at m ≥ 1 against 363's interface and P2/P3
     are [BLOCKED] pending a strengthened (realizability-anchored / deep) mate check — a new
     363-style interface task.
   - **G1 (rows 5-6) NOT re-broken by this cast** (analytical): the fake ambient
     `qnfG1' := m1qnf ⊕ σ''` now PASSES `hfiberCons`, but `s'#`'s `(zone, projFresh)` pair is
     projection-VISIBLE (P-bit at the fresh atom prefix has no honest counterpart in the cast),
     so `igFoldBit qnfG1' ≠ igFoldBit m1qnf` and the `igPtW` guard for `qnfG1'` is plausibly
     unsatisfiable — the rows-5-6 hypothesis side no longer coincides with the honest ambient's.
     (To be confirmed if/when G1 is attempted.)
6. **Supply-theorem target signatures for P2-P4** (keyed to the pinned interface), contingent on
   the P2 probe gate returning GO:
   - G2-1: `kvE_futSliceId_of_end {m} (P : ExistProviders sig atomMap m) … (qnf : NormalForm sig (m+2) 3) (σ : NormalForm sig (m+1) 4) … ∃ σ', qnf.2 σ' = true ∧ pinned realization ∧ σ'.1 = σ.1 ∧ exterior-zone marking agreement` (mirror of `_zero` at general m) + Past mirror.
   - G2-2: `kvE_futSliceUnique {m}` (mirror of `_zero`).
   - G2-3: four supply theorems, binder text verbatim from EndIntervalConsumerK at `k := m`.
   - G1: `kampPrior_hreal_supply` / `kampPrior_hexcl_supply` matching rungK rows 5-6 binders
     (with the antecedent PAIR), plus `hfiberCons` discharge via `_of_realized` on realized
     ambients.

## Next action

P2 opens with the mandated machine probe (route R2): a new leaf probe module
(`ExteriorPinnedProbe358K.lean`) certifying (a)-(e) above — the GO/NO-GO gate for the whole
G2 build-out. GO ⇒ proceed to kernels; NO-GO(=countermodel lands sorry-free) ⇒ P2 [BLOCKED],
escalate per Rollback/Contingency (spawn interface-refinement task), keep P1 landed.
