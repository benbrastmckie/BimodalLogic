# Records

Shared designs for collaboration. A record states what a line of work is for, how it is
organized, and which decisions are open, so that everyone working on it aims at the same thing.

- **A record concerns what is not yet fully implemented.** It is the place to agree a design
  before and while it is built. What exists is documented under `docs/`.
- **When a design is implemented, `docs/` is revised and the record gives it up.** The work that
  completes a part of a design updates the guides and reference under `docs/` to describe what
  now exists, and cuts that part from the record down to a pointer. A record whose design is
  wholly implemented is removed.
- **A record states the current design.** It does not narrate how the design was reached.
  Rejected alternatives are kept, stated on their own merits.
- **A record names open work by its slug**, the stable name of the unit of work, and never by a
  number.
- **Proposals, drafts and reviews written on the way to a design live under `specs/`**, the
  development record, which is not maintained and which nothing outside `specs/` links to.
- **How to use a tactic or a theorem lives under `docs/`.** A record says why and in what order;
  a guide says how.

| Record | Covers |
|---|---|
| [milestones.md](milestones.md) | The goals the open work serves, the milestones to each, what comes next, and the two channels the work divides into |
| [proof-mode.md](proof-mode.md) | Goals, milestones, gates and dependencies for the derivation proof mode |
| [proof-mode-architecture.md](proof-mode-architecture.md) | How proof-mode rules and tactics are organized: the three tiers, the operator families, and where each contribution sits |
| [semantic-proof-mode.md](semantic-proof-mode.md) | Pointed truth evaluation, its countermodel clients, and its measurement against ordinary Lean |
| [theorem-library.md](theorem-library.md) | `BimodalLib`, the library of theorems, countermodels and conjectures: language fragments, conservativity, the tableau pipeline, diagnostics, and how the library measures the proof mode |
