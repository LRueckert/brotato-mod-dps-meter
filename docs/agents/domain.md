# Domain docs: Single-context layout

This repo uses a **single-context** domain documentation layout. All domain knowledge lives in one place:

- **GLOSSARY.md**: Domain terminology for this codebase  
  - Lives at: `docs/GLOSSARY.md`
  - Use this to define Brotato mod concepts, mechanics, terms, etc.

- **ADRs** (Architecture Decision Records): Key technical decisions  
  - Live in: `docs/adr/`
  - Name them: `NNNN-title.md` (e.g., `0001-damage-calculation-strategy.md`)

## For agents

When an agent skill asks for domain context, it will:

1. Read `docs/GLOSSARY.md` to understand the domain model
2. Read ADRs under `docs/adr/` for context on past decisions
3. Use this knowledge to inform code decisions and suggestions

You can edit these files anytime; re-running the setup skill is not needed unless you want to move to a different layout.
