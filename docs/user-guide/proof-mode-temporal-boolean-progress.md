# Strict leads-to composition

The current form is `A → F B`, and the persistent form is `G(A → F B)`. The
past versions use `P` and `H`.

| Command | Obligations |
| --- | --- |
| `lprogress cases` | One persistent guarantee per disjunct |
| `lprogress consequence using h` | Source strengthening and persistent target weakening |
| `lprogress trans using h` | A persistent second step composed with a current or persistent first step |

[Derivation proof mode](derivation-proof-mode.md)
