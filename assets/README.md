# TRINITY Platform — Repository Assets

This directory is reserved for curated repository-level visual assets used by TRINITY documentation.

The purpose of this directory is to keep presentation assets separate from executable Oracle APEX and database source.

---

## Intended Content

Appropriate assets may include:

- Repository header graphics.
- Project identity graphics.
- Curated screenshots approved for public publication.
- Reusable documentation illustrations.
- Static visual resources referenced by Markdown documentation.

---

## Architecture Assets

Technical architecture diagrams should normally be stored under:

```text
docs/architecture/
```

rather than in this directory.

Examples:

```text
docs/architecture/current-oci-architecture.png
docs/architecture/logical-architecture.png
docs/architecture/data-model-erd.png
docs/architecture/publishing-flow.png
```

This keeps architectural evidence close to the documentation that explains it.

---

## Publication Rules

Before adding an asset, verify that it does not expose:

- OCI OCIDs.
- User e-mail addresses unless intentionally public.
- Passwords.
- Tokens.
- API signing keys.
- Active Oracle APEX session identifiers.
- Private URLs containing session information.
- Oracle Wallet information.
- Private account details.
- Unredacted confidential data.

Screenshots should be intentionally curated rather than copied directly from local working directories.

---

## Visual Standard

TRINITY visual assets should maintain a restrained, professional presentation.

Architecture visuals should follow the Oracle Cloud Infrastructure architectural style adopted by the project, including appropriate Oracle Redwood colors and official OCI service iconography where applicable.

Visual material should support technical communication rather than serve as decoration.

---

## Source Control

Do not use this directory as a general dump for:

```text
temporary screenshots
draft exports
ZIP files
presentation backups
editor caches
local working files
```

Only assets that have a defined documentation or repository purpose should be committed.

---

## Status

No general-purpose repository assets are required for the initial TRINITY v1 source-code baseline.

This README intentionally preserves the directory and documents its governance until curated assets are added.
