# Follow-On Task Proposal: `trans_reflexivity_residual_collapse`

This file is a paste-ready `/task` payload plus two documentation-ownership handoffs. Filing the
task is a user `/task` action; no phase of task 699 writes `specs/state.json` or
`specs/TODO.md`, and no phase creates a task.

## Paste-ready `/task` invocation

```
/task "trans_reflexivity_residual_collapse: Task 696's recommended substrate redesign declares trans_refl : forall r in transBack ++ transMid ++ transFwd, forall i, r i i = true as a field of the proposed skeleton (the additive data layer for the trans-based redesign of (C1')'s two temporal conjuncts). With that field, the redesigned (C1') still entails a latent invariance-collapse structurally identical to the one the redesign exists to remove: trans t i j -> (untl g e in L i t <-> untl g e in L j t) and trans (t-1) k i -> (snce g e in L i t <-> snce g e in L k t), both machine-checked in task 699's probe (specs/699_invariance_clause_audit_and_ockhamist_grounding/probes/01_clause_shape_collapse_probe.lean, theorems tUntl_trans_congr and tSnce_trans_congr) against an external trans parameter, using only reflexivity of trans and the shape of the redesigned clause. The invariance is not semantically forced: arrival pruning (trans u i j -> share (u+1) i j) relates the two indices at t + 1, not at t, so the redesigned clause constrains a label row the thread in question never visits at t -- the same category of spurious constraint as the original share-based defect, relocated from share-classes to trans-classes. Both of task 696's gate families set every trans segment to [eq] (trans = eq), making trans t the diagonal, so both theorems are vacuous on them and the gate passes without exhibiting the residual; the residual bites exactly on the hopping families that design T's generality (task 696) exists to admit. Scope: (1) decide whether trans_refl is required, by auditing the approximately 25 term-level Thread.const call sites across PlusWitnessFamily/{Agreement,Basic,Predicates}.lean and Sharing/{Agreement,Predicates,Stability,Thread}.lean (8 files total) against the weaker existential field 'for every i and u there is a thread with idx u = i' -- expected answer: every site consumes only the existential, since the sites need some thread through a position, not the constant one; (2) if so, specify the replacement field and the one substitution lemma, and hand the specification to task 696's Phase 1 so the reflexivity field is never declared; (3) record untl_succ_congr / snce_pred_congr (the common-successor / common-predecessor congruences -- clause_shape_common_witness applied at the flipped relation, already machine-checked as tUntl_common_succ_congr in task 699's probe) as the intended residual once reflexivity is dropped, so the next reader knows the relocation from share-classes to trans-classes is deliberate and bounded -- task 696's report 01 already asks for this record; task 699 supplies the reflexivity-free derivation that makes it exactly the residual and nothing more; (4) optionally, and only if step 1 finds trans_refl genuinely required for some site the existential field cannot supply, construct a hopping countermodel and a target schema that the trans-congruence blocks, turning the residual into a named incompleteness theorem the way not_plusCertifies_stabSnce did for the original defect. Non-goals: no substrate redesign (task 696 owns the redesign in full); no change to plusTruth_iff_mem or plusRefutes_of_certifies (soundness is not in question); no re-conversion of the thomason-1970-indeterminist-time corpus source (optional future work, only if a separate unverified literature claim becomes load-bearing). Ordering constraint: this task should be resolved before task 696 Phase 1 declares trans_refl as a skeleton field, because removing a declared field after code depends on it costs substantially more than not declaring it in the first place -- task 696 Phase 1 is the additive data layer where trans_refl would first appear. Type: formal:logic. Effort estimate: research-first (step 1 is an audit, not a proof); implementation of steps 2-3 belongs to whichever cycle lands task 696 Phase 1."
```

## Evidence backing the defect claim (so the filed task is checkable without the 671-line report open)

Both of the following are machine-checked, axiom-clean (no `sorryAx`), in
`specs/699_invariance_clause_audit_and_ockhamist_grounding/probes/01_clause_shape_collapse_probe.lean`,
verified present in that file at the time of writing:

- **`tUntl_trans_congr`** — proves, from `hrefl : ∀ u i, trans u i i` and the redesigned `untl`
  clause `TUntlClause`, that `∀ i j, trans t i j → (untl g e ∈ S.L i t ↔ untl g e ∈ S.L j t)`.
  This is the defect: the collapse survives the redesign, now across `trans` instead of `share`.
- **`tSnce_trans_congr`** — the `snce`-side mirror, across `trans (t - 1)` read backwards.
- **`tUntl_common_succ_congr`** — what remains once `trans_refl` is dropped: only
  `trans t i j → trans t i' j → (untl g e ∈ S.L i t ↔ untl g e ∈ S.L i' t)`, the
  common-successor congruence task 696's own report 01 already classifies as semantically forced
  and harmless. This is the theorem that shows the repair (dropping `trans_refl`) leaves exactly
  the intended residual and nothing more — it is the target of the proposed task's step 3.

Path (re-verified against the current tree at write time): probe 01 is at
`specs/699_invariance_clause_audit_and_ockhamist_grounding/probes/01_clause_shape_collapse_probe.lean`,
220 lines, and elaborates clean (`lake env lean` exit 0, no `sorryAx` in any of its ten
`#print axioms` lines).

## Handoff item 1 — unowned, this task cannot make it

`FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Incompleteness.lean:51` (re-verified by
`grep -n` at write time; the passage runs 51-54) carries the module docstring:

> "**The `untl` side is defect-free by inspection, not by machine check.** (C1')'s `untl` clause
> quantifies forward along a thread rather than over the `share`-class at the label's own time, so
> the same collapse does not arise there."

Task 699's Part A audit (report row 2, `01_invariance-clause-audit-ockhamist-grounding.md`)
refutes this: the `untl` conjunct collapses in the *same* shape as the `snce` conjunct, not merely
a shifted one — `untl_share_succ_congr` (probe 01) machine-checks
`share (t + 1) i j → (untl g e ∈ S.L i t ↔ untl g e ∈ S.L j t)` directly, with no time shift
involved in the collapse itself.

`Incompleteness.lean` is **not** among task 696's fourteen declared `file_scope` paths (re-checked
at write time via `jq '.active_projects[] | select(.project_number==696) | .file_scope' specs/state.json`
— the fourteen paths are `PlusWitnessFamily/{Agreement,Decide,Fulfil,Predicates,README.md}.lean`,
`WitnessFamily/Sharing/{Agreement,Decide,Fulfil,Predicates,README.md,Skeleton,Specialize}.lean`,
`docs/theorem-index.md`, `scripts/check-module-invariants.sh`). So **no filed task currently owns
this docstring correction**. Task 699 cannot make it either: its plan permits no modification to
any Lean statement or docstring under `FormalSystem/`, and the path is outside task 699's own
`file_scope`. Whoever picks up this proposal (or a separate small task) should correct the
docstring to state that the `untl` side collapses in the same shape as the `snce` side, per row 2
of task 699's report.

## Handoff item 2 — owned by task 696, strengthens its scheduled correction

The same false claim appears twice more, both in files task 696 **does** declare:

- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/README.md:100-102` (re-verified by
  `grep -n` at write time): "**The `untl` side is defect-free by inspection, not by machine
  check.** (C1')'s `untl` clause quantifies forward along a thread rather than over the
  `share`-class at the label's own time, so the same collapse does not arise."
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/README.md:124` (re-verified by
  `grep -n` at write time): "The `untl` half is a genuine repair; the `snce` half collapses
  backward branching, at a completeness price the received account did not record."

Both READMEs are in task 696's declared `file_scope`, and task 696's report 01 already schedules
a related correction for its Phase 0 (the general "any condition quantifying over the
`share`-class at a label's own time forces class agreement" rule of thumb). This is not a new
owner, but a **strengthening of that correction's content**: per task 699's report row 2, the
`untl` collapse is same-shape, not merely shifted, and per rows 3-4 both the `snce` and `untl`
conjuncts collapse on the `Formula` side too (`SharingWitnessFamily.LocalCoherentShare`), which
neither README currently records. Whoever executes task 696's Phase 0 correction should fold this
in rather than writing only the shifted-`untl` / `Formula`-side-silent version.

## Explicit scope statement

Filing the `/task` invocation above is a user action (`/task "..."`), not something any phase of
task 699 performs. No phase of task 699 writes `specs/state.json` or `specs/TODO.md`: sibling
task 698 holds `specs/state.json` as its declared `file_scope` this same `/orchestrate` cycle, and
task 699's plan independently commits to no bookkeeping writes regardless of that overlap.
