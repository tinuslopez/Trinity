# TRINITY Platform — Oracle APEX Application

**Source-controlled Oracle APEX application for TRINITY Platform**

This directory contains the Oracle APEX application source for the current TRINITY engineering baseline.

The application runs on Oracle APEX with Oracle Autonomous AI Database 26ai as its data platform. The current implementation provides an authenticated administrative CMS for Posts, Categories, Authors, Events, and Certifications.

---

## Directory Contents

```text
apex/
├── README.md
└── exports/
    └── f109.sql
```

| Artifact | Purpose |
|---|---|
| `exports/f109.sql` | Standard Oracle APEX application export for Application 109 |

The export is stored in source control as an Oracle-generated application artifact.

---

## Application Baseline

| Property | Current implementation |
|---|---|
| Application | TRINITY Platform |
| Application ID | `109` |
| Oracle APEX | 26.1.x |
| Parsing schema | `WKSP_TRINITY` |
| Export format | SQL |
| Export type | Standard Export |
| Pages | 13 |
| Source control | Git + GitHub |

The current controlled export was generated after implementation of the Events and Certifications modules.

Current SHA-256:

```text
df3395e3998d8b8117fee4eace859c579902cc69129793ba18dfe4309e4a6fff
```

---

## Current Application Scope

```text
TRINITY Platform
│
├── Global Page
├── Home
├── Posts
│   └── Post
├── Categories
│   └── Category
├── Authors
│   └── Author
├── Events
│   └── Event
├── Certifications
│   └── Certification
└── Login Page
```

The public-facing publishing layer remains in progress.

---

## Current Pages

| Page | Name | Responsibility |
|---:|---|---|
| 0 | Global Page | Application-wide components |
| 1 | Home | Administrative landing page |
| 2 | Posts | Post report |
| 3 | Post | Post create/edit form |
| 8 | Categories | Category report |
| 9 | Category | Category create/edit form |
| 11 | Authors | Author report |
| 12 | Author | Author create/edit form |
| 14 | Events | Event report |
| 15 | Event | Event create/edit form |
| 16 | Certifications | Certification report |
| 17 | Certification | Certification create/edit form |
| 9999 | Login Page | Application authentication |

---

## Posts

The Posts module supports administrative publishing operations.

Key attributes include:

```text
Title
Slug
Category
Author
Excerpt
Content
Featured Image URL
Status
Published At
Featured
```

The current publication lifecycle is:

```text
DRAFT
PUBLISHED
ARCHIVED
```

### Automatic slug generation

The Post form contains a Dynamic Action that derives a URL-friendly slug from the post title.

Conceptual behavior:

```javascript
const title = apex.item("P3_TITLE").getValue();

const slug = title
  .normalize("NFD")
  .replace(/[\u0300-\u036f]/g, "")
  .toLowerCase()
  .trim()
  .replace(/[^a-z0-9]+/g, "-")
  .replace(/^-+|-+$/g, "");

apex.item("P3_SLUG").setValue(slug);
```

---

## Events

The Events module is implemented through:

```text
Page 14 — Events
Page 15 — Event
```

The form manages:

```text
Title
Slug
Description
Event Date
Location
Event URL
Featured Image URL
Status
```

Audit columns are maintained by database triggers and are not intended as primary end-user form fields.

### Event image integration

Event images are currently stored as selected objects in OCI Object Storage.

The Event form stores the resulting object URL in:

```text
P15_FEATURED_IMAGE_URL
        ↓
EVENTS.FEATURED_IMAGE_URL
```

The Events report renders the image from that URL.

Current workflow:

```text
Image
  ↓
OCI Object Storage
  ↓
Object URL
  ↓
Event form
  ↓
EVENTS.FEATURED_IMAGE_URL
  ↓
Events report
```

Image upload itself is currently handled outside the APEX application.

---

## Certifications

The Certifications module is implemented through:

```text
Page 16 — Certifications
Page 17 — Certification
```

The form manages:

```text
Name
Issuer
Credential ID
Credential URL
Issued Date
Expiration Date
Description
Active
```

### Native Boolean active state

`CERTIFICATIONS.ACTIVE_YN` is a native Oracle SQL `BOOLEAN`.

Final database definition:

```text
BOOLEAN
DEFAULT TRUE
NOT NULL
```

The Page 17 item submits native Boolean values that match the database column type.

Application presentation:

```text
TRUE  → Yes
FALSE → No
```

### Credential verification

The Certifications report does not display the full credential URL as raw text.

Instead, the `CREDENTIAL_URL` column is presented as:

```text
Verify
```

The link target uses the stored credential URL.

---

## Authentication

The application uses:

```text
Oracle APEX Accounts
```

for the current administrative authentication baseline.

---

## Authorization

The application includes an administrative authorization scheme:

```text
Administration Rights
```

The current administrative application should remain protected while the future public-facing experience is developed separately.

---

## Shared Lists of Values

TRINITY uses shared LOV components to support relational and controlled selections.

Examples include:

```text
AUTHORS.NAME
CATEGORIES.NAME
BOOLEAN
```

Application-specific item configurations may also use direct static values where native Boolean handling is required.

---

## Form Processing

Oracle APEX form pages coordinate the user-interface layer with the underlying tables in `WKSP_TRINITY`.

```text
Administrator
      │
      ▼
Oracle APEX Form
      │
      ├── Item validation
      ├── LOV / Boolean selection
      ├── Dynamic Action behavior
      │
      ▼
APEX Page Processing
      │
      ▼
WKSP_TRINITY
      │
      ▼
Database integrity + audit triggers
```

Core data integrity remains owned by Oracle Database.

---

## Application and Database Responsibilities

### Oracle APEX

- Authentication.
- Authorization.
- Administrative navigation.
- Interactive reports.
- Forms.
- LOV-driven relational selection.
- Form validations.
- Page processing.
- Publication status selection.
- Boolean UI behavior.
- Client-side slug generation.
- Credential verification links.
- Event image URL presentation.

### Oracle Database

- Persistent relational storage.
- Primary keys.
- Foreign keys.
- Identity-generated identifiers.
- Supporting indexes.
- Native Boolean columns.
- Default and `NOT NULL` rules.
- Automatic audit columns.
- Audit triggers.
- Relational integrity.

---

## Source-Control Strategy

The controlled export is:

```text
apex/exports/f109.sql
```

The file must be treated as generated application source.

Do not manually reformat or rewrite the export merely to reduce Git diff size.

Application changes should normally be made in Oracle APEX and then captured through a new Standard Export.

---

## Export Workflow

```text
Develop in Oracle APEX
        ↓
Functional validation
        ↓
Standard Export — SQL
        ↓
Review page/component changes
        ↓
Security scan
        ↓
Replace controlled f109.sql
        ↓
Review Git diff
        ↓
Update related documentation
        ↓
Commit
```

The current export was validated to contain 13 pages and the Events / Certifications page pairs.

---

## Export Validation

Representative validation:

```bash
grep -c "wwv_flow_imp_page.create_page(" apex/exports/f109.sql
```

Current expected result:

```text
13
```

Current page IDs:

```text
14 — Events
15 — Event
16 — Certifications
17 — Certification
```

---

## Dependency on Database Objects

The APEX application depends on the TRINITY database implementation under:

```text
database/
```

Key tables currently used by the administrative application include:

```text
AUTHORS
CATEGORIES
POSTS
EVENTS
CERTIFICATIONS
```

The broader data model also contains:

```text
TAGS
POST_TAGS
```

The application should not be imported into another environment without validating the database baseline and ordered migrations.

---

## Security Review

Before a public Git push, review the APEX export for accidental exposure of:

- Passwords.
- Private keys.
- OCI signing keys.
- Authentication tokens.
- Active APEX session identifiers.
- Oracle Wallet credentials.
- Private connection credentials.
- Sensitive personal information.
- Environment-specific secrets.

The current export received a targeted pattern scan before publication preparation.

---

## Current vs. Planned Scope

### Implemented

- Authenticated Oracle APEX administrative application.
- Posts report and form.
- Categories report and form.
- Authors report and form.
- Events report and form.
- Certifications report and form.
- Event image URL integration.
- Native Boolean Certification active state.
- Credential verification links.
- Authentication and authorization components.
- Dynamic Actions and page processing.
- Integration with `WKSP_TRINITY`.

### In progress

- Public-facing content experience.
- Public Events and Certifications presentation.
- Formal deployment documentation.
- Updated architecture visuals for the latest media integration.
- Additional security review.

### Planned

- Public Home.
- Public Blog / Articles.
- Public Categories.
- Public Events.
- Public Certifications.
- About.
- Contact.
- Tag administration.
- More integrated media-management workflow.
- Production-oriented operational hardening.

---

## Related Source

Database source:

```text
database/
```

Architecture documentation:

```text
docs/architecture/
```

Architecture Decision Records:

```text
docs/decisions/
```

---

## Maintenance Rule

When `f109.sql` is replaced, verify at minimum:

```text
Application ID
Application name
APEX release
Parsing schema
Page count
Authentication
Authorization
New or removed modules
Database dependencies
Sensitive-data exposure
```

In TRINITY, the APEX export is treated as a traceable engineering artifact representing the application at a defined point in development.
