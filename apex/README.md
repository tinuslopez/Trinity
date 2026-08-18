# TRINITY Platform — Oracle APEX Application

**Source-controlled Oracle APEX application for TRINITY Platform**

This directory contains the Oracle APEX application source for the current TRINITY Platform v1 engineering baseline.

The application is built on Oracle APEX and uses Oracle Autonomous AI Database 26ai as its data platform. The current implementation provides the administrative content-management layer for Authors, Categories, and Posts, together with authentication, authorization, shared Lists of Values, Dynamic Actions, and automatic DML processes.

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

The export is intentionally stored in source control as an Oracle-generated application artifact.

---

## Application Baseline

| Property | Current implementation |
|---|---|
| Application | TRINITY Platform |
| Application ID | `109` |
| Oracle APEX release | `26.1.3` |
| Parsing schema | `WKSP_TRINITY` |
| Export type | Application Export |
| Exported by | `TRINITY_APP` |
| Pages | 9 |
| Page items | 38 |
| Validations | 1 |
| Processes | 12 |
| Regions | 15 |
| Buttons | 16 |
| Dynamic Actions | 3 |
| Authentication schemes | 1 |
| Authorization schemes | 1 |
| Shared LOVs | 3 |

These values are taken from the current `f109.sql` Oracle APEX export.

---

## Current Application Scope

The current application is primarily an authenticated administrative CMS.

```text
TRINITY Platform
│
├── Global Page
├── Home
│
├── Posts
│   └── Post
│
├── Categories
│   └── Category
│
├── Authors
│   └── Author
│
└── Login Page
```

The public-facing publishing experience is not represented as completed functionality in the current v1 export.

---

## Pages

### Global Page

The Global Page provides application-wide components available across applicable pages.

It is part of the current nine-page application export.

---

### Home

**Alias:** `HOME`

The Home page is the primary landing page for the current Oracle APEX application.

Current page title:

```text
TRINITY Platform
```

---

### Posts

**Alias:** `POSTS`

The Posts page provides the administrative report interface for content records.

Its role in the current CMS is to allow the authenticated administrator to review and navigate to individual post records.

---

### Post

**Alias:** `POST`

**Page mode:** Modal

The Post page provides the administrative form used to create and maintain individual posts.

The form integrates relational values from Authors and Categories and contains the Dynamic Action used to generate URL-friendly slugs from article titles.

Key publishing attributes include:

```text
Title
Slug
Category
Author
Excerpt
Content
Status
Published At
Featured
```

The current publication lifecycle exposed by the application is:

```text
DRAFT
PUBLISHED
ARCHIVED
```

---

### Categories

**Alias:** `CATEGORIES`

The Categories page provides the administrative report for content classifications.

---

### Category

**Alias:** `CATEGORY`

**Page mode:** Modal

The Category page provides the form used to create and maintain category records.

---

### Authors

**Alias:** `AUTHORS`

The Authors page provides the administrative report for publishing identities.

---

### Author

**Alias:** `AUTHOR`

The Author page provides the form used to create and maintain author records.

---

### Login Page

**Alias:** `LOGIN`

The Login page provides authentication entry into the current administrative application.

Current page title:

```text
TRINITY Platform - Log In
```

---

## Authentication

The current export contains one authentication scheme:

```text
Oracle APEX Accounts
```

This provides the authentication mechanism for the current administrative application baseline.

Authentication configuration is part of the Oracle APEX application export and should be reviewed whenever the application is promoted to a different environment.

---

## Authorization

The current export contains one authorization scheme:

```text
Administration Rights
```

Authorization is distinct from authentication:

- **Authentication** establishes who the user is.
- **Authorization** determines whether an authenticated user is permitted to access a protected capability.

The current implementation should continue to be reviewed as TRINITY evolves toward a clearer separation between administrative and public functionality.

---

## Shared Lists of Values

The current application export contains three shared LOV components.

Relevant application LOVs include:

```text
AUTHORS.NAME
CATEGORIES.NAME
BOOLEAN
```

These components support controlled selection and relational integrity in Oracle APEX forms.

### Authors LOV

The Authors LOV allows a post to reference an existing author rather than requiring the administrator to enter a raw database identifier.

Its logical purpose is:

```text
Displayed value  → Author name
Returned value   → Author ID
```

---

### Categories LOV

The Categories LOV allows a post to reference an existing category through a human-readable selection.

Its logical purpose is:

```text
Displayed value  → Category name
Returned value   → Category ID
```

---

### Boolean LOV

The Boolean LOV supports applicable Yes/No-style application states.

---

## Dynamic Actions

The current export contains three Dynamic Actions.

The most significant custom behavior for the current publishing workflow is:

```text
Generate Slug
```

Other Dynamic Actions include report refresh behavior after modal dialog operations.

---

## Automatic Slug Generation

The Post form implements a client-side Dynamic Action that generates a normalized slug when the title changes.

The source logic stored in the APEX export is conceptually:

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

The transformation performs the following sequence:

1. Reads the value of `P3_TITLE`.
2. Normalizes Unicode characters.
3. Removes diacritical marks.
4. Converts the title to lowercase.
5. Trims surrounding whitespace.
6. Replaces non-alphanumeric sequences with hyphens.
7. Removes leading and trailing hyphens.
8. Writes the result to `P3_SLUG`.

Example:

```text
Oracle AI Database 26ai: construyendo Trinity con Oracle APEX
```

becomes:

```text
oracle-ai-database-26ai-construyendo-trinity-con-oracle-apex
```

This behavior is implemented inside the Oracle APEX application source and is not external post-processing.

---

## Form Processing

The application uses Oracle APEX page processes to support CRUD operations.

The export contains 12 processes across the application.

For the administrative form pages, Oracle APEX coordinates the user-interface layer with the underlying relational tables in `WKSP_TRINITY`.

At a high level:

```text
Administrator
      │
      ▼
Oracle APEX Form
      │
      ├── Validation / LOV selection
      ├── Dynamic Action behavior
      │
      ▼
Page Processing
      │
      ▼
WKSP_TRINITY
      │
      ▼
Database audit trigger
```

The database layer remains responsible for automatic audit-column maintenance.

---

## Application and Database Responsibilities

TRINITY intentionally separates responsibilities between Oracle APEX and Oracle Database.

### Oracle APEX

The application layer currently manages:

- Authentication.
- Authorization.
- Administrative navigation.
- Reports.
- Forms.
- LOV-driven relational selection.
- Form validations.
- Page processing.
- Publication-status selection.
- Client-side slug generation.
- Modal page interaction.

### Oracle Database

The database layer currently manages:

- Persistent relational storage.
- Primary keys.
- Foreign keys.
- Identity-generated identifiers.
- Supporting indexes.
- Automatic audit columns.
- Audit triggers.
- Relational integrity defined by the physical schema.

This separation allows the application to use Oracle APEX productivity features without removing database-level ownership of core data integrity.

---

## Current Publishing Workflow

The implemented administrative flow can be summarized as:

```text
Authenticate
    │
    ▼
Open TRINITY administration
    │
    ├── Manage Authors
    ├── Manage Categories
    │
    ▼
Create / Edit Post
    │
    ├── Select Author
    ├── Select Category
    ├── Enter Title
    ├── Generate Slug
    ├── Enter Content
    └── Select Publication Status
    │
    ▼
Submit Form
    │
    ▼
APEX Page Processing
    │
    ▼
POSTS table
    │
    ▼
Automatic database auditing
```

The future public blog layer will consume published content but is not presented here as already completed.

---

## Source-Control Strategy

The standard Oracle APEX export is stored at:

```text
apex/exports/f109.sql
```

The export header explicitly identifies the file as an Oracle APEX generated application export.

The source file should be treated as generated application source.

### Important rule

Do not manually modify `f109.sql` merely to make the export appear cleaner in Git.

Oracle includes a warning in the generated export indicating that manual modification is not supported and may lead to unexpected application or instance behavior.

Application changes should normally be made in Oracle APEX and then reflected by a new controlled export.

---

## Export Workflow

The baseline source-control workflow is:

```text
Develop / validate in Oracle APEX
             │
             ▼
Application Export
             │
             ▼
Standard Export — SQL
             │
             ▼
Review export metadata
             │
             ▼
Security review
             │
             ▼
Replace controlled f109.sql
             │
             ▼
Review Git diff
             │
             ▼
Commit
```

This keeps the repository aligned with the application actually deployed in the development environment.

---

## Export Metadata

The current source export contains metadata identifying:

```text
Application:   109
Name:          TRINITY Platform
APEX release:  26.1.3
Owner:         WKSP_TRINITY
Exported By:   TRINITY_APP
Export Type:   Application Export
```

Environment-specific metadata may naturally change in later exports. Such changes should be reviewed as part of the Git diff rather than automatically discarded.

---

## Import Considerations

The export contains calls to Oracle APEX import APIs and is intended for use with a compatible Oracle APEX environment.

The export header states that the script should be run using a SQL client connected either:

- as the owner / parsing schema of the application, or
- as a database user with the appropriate APEX administrative role.

A deployment process must account for environment-specific mappings such as:

```text
Workspace
Application ID
Parsing schema
Authentication configuration
Authorization configuration
Supporting database objects
```

Do not assume that importing into another environment is risk-free merely because the SQL file is source controlled.

---

## Dependency on Database Objects

The APEX application depends on the TRINITY database model.

Database source is maintained separately under:

```text
database/
```

Key application tables include:

```text
AUTHORS
CATEGORIES
POSTS
```

The broader database baseline also contains:

```text
TAGS
POST_TAGS
EVENTS
CERTIFICATIONS
```

The application should not be imported into a target environment without validating the required database objects and parsing schema.

---

## Security Considerations

The APEX export is reviewed before publication in this repository.

The following must never be intentionally committed:

- Passwords.
- OCI private keys.
- API signing keys.
- Authentication tokens.
- Active APEX session identifiers.
- Environment secrets.
- Oracle Wallet credentials.
- Private connection credentials.
- Sensitive personal information.

An APEX export may contain application metadata, page source, SQL, PL/SQL, JavaScript, component names, authentication configuration, authorization configuration, and environment identifiers. Every export should therefore receive a security review before a public Git push.

---

## Engineering Change Discipline

Changes to the Oracle APEX application should follow a controlled sequence:

1. Implement the change in the intended Oracle APEX environment.
2. Validate the affected page or component.
3. Validate dependent database behavior.
4. Export the application using the appropriate Oracle APEX source-control export.
5. Review the generated SQL metadata.
6. Review the source for accidental sensitive information.
7. Compare the new export against the previous Git version.
8. Update related documentation when the implementation materially changes.
9. Commit the application source and documentation as one coherent engineering change when appropriate.

---

## Current vs. Planned Scope

### Implemented in the current baseline

- Oracle APEX administrative application.
- Authentication using Oracle APEX Accounts.
- Administration authorization scheme.
- Home page.
- Posts report and Post form.
- Categories report and Category form.
- Authors report and Author form.
- Shared LOVs.
- Dynamic Actions.
- Automatic slug generation.
- APEX page processing.
- Integration with `WKSP_TRINITY`.

### In progress

- Public-facing content experience.
- Formal deployment documentation.
- Extended architecture documentation.
- Additional application-level security review.

### Planned

- Public Home.
- Public Blog.
- Public Article.
- Public Categories.
- About.
- Contact.
- Administrative management for additional model entities.
- Media-management enhancements.
- Production-oriented operational hardening.

This distinction is intentional. The repository documents the system as it exists rather than presenting roadmap items as completed capabilities.

---

## Relationship to TRINITY Architecture

The current application sits within the implemented solution baseline:

```text
Developer / Administrator
           │
        HTTPS
           │
           ▼
      Oracle APEX
    Application 109
           │
           ▼
Autonomous AI Database 26ai
           │
           ▼
      WKSP_TRINITY
```

A separate OCI Compute instance is not required for the current Oracle APEX application baseline.

Future infrastructure components will only be documented as current architecture after they have actually been implemented.

---

## Related Documentation

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

## Maintenance Note

When a new Oracle APEX export replaces `f109.sql`, verify at minimum:

```text
Application ID
Application name
APEX release
Parsing schema
Page count
Authentication
Authorization
Component changes
Sensitive-data exposure
```

A source-control export is not merely a backup file. In TRINITY it is treated as a traceable engineering artifact representing the state of the application at a defined point in development.
