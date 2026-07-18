# Documentation Voice

Shared voice for every `dd:docs` skill — README, CHANGELOG, and any future docs/specs. Read this first; skill-specific rules layer on top of it.

- **Technical tone only** — no marketing language, no buzzwords, no hype. Banned words: revolutionary, powerful, seamless, blazing fast, effortless, cutting-edge.
- **Concise** — say it once, say it clearly, move on. Cut preamble, recaps, and filler.
- **User's perspective** — describe functional impact, not file names or internal mechanics. "Rate limiting for API endpoints", not "Update handler.go".
- **GitHub-flavored markdown** — use `[!NOTE]`, `[!TIP]`, `[!WARNING]`, `[!IMPORTANT]`, `[!CAUTION]` callouts where semantically appropriate. Max 2–3 per document — overuse dilutes urgency and readers start skipping them.
- **Written for humans, not machines** — a person reads this, not an AI. Avoid the tells of machine-written docs: robotic exhaustiveness, hedging, repeated scaffolding, and listing things for completeness' sake. Prefer plain sentences a reader can follow on the first pass.
- **Self-descriptive & scannable** — a reader should grasp the point within 30 seconds. Sequential flow, no jumping around.
- **Preserve human-written content** — when updating an existing doc, only rewrite what's outdated or missing. Don't nuke good prose just to match a template.
