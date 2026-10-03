# Phase 3 Handoff — PlusSlicedCertificate/README.md

- **Done**: `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/README.md` written
  (224 lines, 25 table rows). **The gate has flipped**:
  `bash scripts/readme-lint.sh FormalSystem BimodalTools` exits 0 with
  `Missing READMEs: 0`, `Total READMEs found: 75`, `Broken file references: 0`.
  `check-module-invariants.sh --emit-inventory --check` still reports `PASS INV`.
- **Next action**: Phase 4 (audit, largely already run) then Phase 5 — the non-gating parent
  listings. Note one new warning this task introduced:
  `STALE DATE: PlusWitnessFamily/README.md (stamped 2026-09-29, directory last changed
  2026-10-02)`, caused by the two new subdirectory READMEs landing under it; Phase 5 refreshes
  that stamp.
- **Key decisions**: the six-layer route follows the modules' actual `import` lines rather than
  the plan's grouping (`Fixture` imports `Bridge`; `Stable` imports `Fixture`), per the phase's
  own Scope Hypothesis. Proved / refuted / open kept as three explicit headings, with the
  doubly-exponential slice width recorded as a research finding and explicitly not a theorem.
- **Deviations**: layer grouping altered to follow imports; 224 lines against the 160-220 band.
