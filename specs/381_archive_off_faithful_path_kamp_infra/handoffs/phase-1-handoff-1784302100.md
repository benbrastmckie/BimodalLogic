# Phase 1 handoff

- **Done**: Phase 0 (baseline 1766, axiom set captured, classification w/ blockers B1/B2) + Phase 1
  (moved 6 not-in-closure files to Kamp/Boneyard/ with headers). Build GREEN 1766, axiom set identical.
- **Next**: Phase 2 — move+rename the 5 task-numbered probe files (358/364/367) to Boneyard, rewrite
  the one intra-set import (ExteriorPinnedProbe358K→Anchor imports ExteriorFiberConsistencyProbeK).
- **Recovery**: last-good = git commit for phase 1. Snapshot stash@{0} + working-progress patch exist.
- **Key decisions**: binding criterion = live import closure of Bimodal.lean (239 modules). Boneyard
  never compiled. Blockers B1 (Phase 4 Fib decls proof-term-consumed by live files) and B2 (Phase 5
  RefutationF2 prune drops job count <1766) will force a partial return.
