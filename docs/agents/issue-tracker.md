# Issue tracker: Local markdown

Issues for this repo live as markdown files under `docs/.scratch/` instead of GitHub Issues. This keeps work tracking local and lightweight.

## Creating issues

Use the `to-tickets` skill or manually:

1. Create a `docs/.scratch/<feature>/` directory with a unique slug (e.g., `docs/.scratch/add-damage-display/`)
2. Inside, create `ISSUE.md` with the issue description, acceptance criteria, etc.

When a feature is split into tickets (`to-tickets`), each ticket is its own file at `docs/.scratch/<feature>/issues/<NN>-<slug>.md`, numbered in dependency order. Each ticket lists its blockers and a `Status:` line (e.g. `ready-for-agent`). Work any ticket whose blockers are all done.

## Updating issues

Edit the `docs/.scratch/<feature>/ISSUE.md` file directly and commit changes to this repo.

## Closing issues

Once work is done, move the issue to `docs/.scratch/done/<feature>/` or delete it, then commit.
