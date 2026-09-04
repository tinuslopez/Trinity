# TRINITY Platform — Database Engineering

**Relational data model, Oracle DDL baseline, and controlled schema migrations**

This directory contains the database source artifacts for TRINITY Platform.

The original v1 relational model was designed with Oracle Quick SQL and implemented on Oracle Autonomous AI Database 26ai. The original generated DDL is preserved as a baseline, while structural changes applied after that baseline are captured as ordered migration scripts.

---

## Directory Contents

```text
database/
├── README.md
├── ddl/
│   └── TRINITY_V1_SCHEMA.sql
├── migrations/
│   ├── 001_add_event_featured_image.sql
│   └── 002_certifications_active_default.sql
└── quicksql/
    └── trinity-v1.quicksql
```

| Artifact | Purpose |
|---|---|
| `quicksql/trinity-v1.quicksql` | Original Quick SQL source model |
| `ddl/TRINITY_V1_SCHEMA.sql` | Original generated and executed Oracle DDL baseline |
| `migrations/001_add_event_featured_image.sql` | Adds event featured-image URL support |
| `migrations/002_certifications_active_default.sql` | Normalizes Certification Boolean state and enforces `DEFAULT TRUE NOT NULL` |

The generated DDL is intentionally preserved rather than rewritten to make it appear as if later changes existed in the original baseline.

---

## Database Baseline

| Property | Current implementation |
|---|---|
| Platform | Oracle Autonomous AI Database 26ai |
| Application integration | Oracle APEX |
| Parsing schema | `WKSP_TRINITY` |
| Tables | 7 |
| Supporting indexes | 4 |
| Audit triggers | 7 |
| Primary-key strategy | Identity-generated `NUMBER` |
| Audit integration | APEX session user with database-user fallback |
| Schema evolution | Ordered SQL migrations |

> `TRINITY_V1_SCHEMA` is the SQL script name. It is **not** the parsing schema. The current APEX parsing schema is `WKSP_TRINITY`.

---

## Relational Model

The database contains seven tables:

```text
AUTHORS
CATEGORIES
POSTS
TAGS
POST_TAGS
EVENTS
CERTIFICATIONS
```

### `AUTHORS`

Stores author identity and publishing-profile information.

Important attributes include `ID`, `NAME`, `SLUG`, `EMAIL`, `BIO`, `AVATAR_URL`, `ACTIVE_YN`, and standard audit columns.

### `CATEGORIES`

Stores content classifications.

Important attributes include `ID`, `NAME`, `SLUG`, `DESCRIPTION`, `ACTIVE_YN`, and standard audit columns.

### `POSTS`

Stores article and publishing content.

Important attributes include:

```text
ID
CATEGORY_ID
AUTHOR_ID
TITLE
SLUG
EXCERPT
CONTENT
FEATURED_IMAGE_URL
STATUS
PUBLISHED_AT
FEATURED_YN
```

Current application publication states:

```text
DRAFT
PUBLISHED
ARCHIVED
```

### `TAGS`

Stores reusable content tags.

### `POST_TAGS`

Implements the many-to-many relationship between Posts and Tags.

### `EVENTS`

Stores technical events and activities.

Current attributes include:

```text
ID
TITLE
SLUG
DESCRIPTION
EVENT_DATE
LOCATION
EVENT_URL
STATUS
FEATURED_IMAGE_URL
```

The post-baseline `FEATURED_IMAGE_URL` column is:

```text
VARCHAR2(500)
NULL allowed
```

The value stores an image reference such as an OCI Object Storage object URL.

### `CERTIFICATIONS`

Stores professional certification records.

Current attributes include:

```text
ID
NAME
ISSUER
CREDENTIAL_ID
CREDENTIAL_URL
ISSUED_DATE
EXPIRATION_DATE
DESCRIPTION
ACTIVE_YN
```

The deployed active-state definition is:

```text
ACTIVE_YN BOOLEAN DEFAULT TRUE NOT NULL
```

This is a native SQL Boolean, not a `VARCHAR2(1)` Y/N flag.

---

## Core Relationships

```text
AUTHORS       1 ───────────< POSTS
                              │
CATEGORIES    1 ───────────<  │
                              │
POSTS         1 ───────< POST_TAGS >─────── 1 TAGS
```

Relational interpretation:

- One Author can own many Posts.
- One Category can classify many Posts.
- Posts and Tags have a many-to-many relationship through `POST_TAGS`.
- `EVENTS` and `CERTIFICATIONS` are standalone entities in the current model.

---

## Original Quick SQL Baseline

The logical source model is stored at:

```text
database/quicksql/trinity-v1.quicksql
```

The original model defines:

```text
authors
categories
posts
tags
post_tags
events
certifications
```

The Quick SQL source provides traceability to the original v1 data-model intent.

---

## Original DDL Baseline

The generated implementation is stored at:

```text
database/ddl/TRINITY_V1_SCHEMA.sql
```

The original baseline contains:

```text
7 CREATE TABLE statements
4 CREATE INDEX statements
7 CREATE OR REPLACE TRIGGER statements
```

This file should remain unchanged unless there is a specific reason to regenerate the complete baseline.

It represents the original physical starting point, not every subsequent schema change.

---

## Migration Strategy

Structural changes made after the original DDL baseline are maintained under:

```text
database/migrations/
```

Migration scripts are ordered numerically and should be applied in sequence.

Current migrations:

```text
001_add_event_featured_image.sql
002_certifications_active_default.sql
```

### Migration 001 — Event featured image

Adds:

```sql
ALTER TABLE events
ADD featured_image_url VARCHAR2(500);
```

Final deployed metadata:

```text
COLUMN_NAME  FEATURED_IMAGE_URL
DATA_TYPE    VARCHAR2
DATA_LENGTH  500
NULLABLE     Y
```

### Migration 002 — Certification active-state hardening

The original v1 DDL already defines `CERTIFICATIONS.ACTIVE_YN` as a native Oracle SQL `BOOLEAN`. This migration does **not** change the column data type.

It normalizes existing null values and then enforces the final default and nullability rules:

```text
NULL  → TRUE
TRUE  → TRUE
FALSE → FALSE
```

Final deployed metadata:

```text
COLUMN_NAME   ACTIVE_YN
DATA_TYPE     BOOLEAN
NULLABLE      N
DATA_DEFAULT  TRUE
```

The database therefore guarantees that every Certification has an explicit Boolean active state.

---

## Why Migrations Are Separate

TRINITY distinguishes between:

```text
Original baseline
       │
       ▼
TRINITY_V1_SCHEMA.sql
       │
       ▼
Post-baseline changes
       │
       ▼
database/migrations/
       │
       ▼
Current deployed schema
```

This approach provides historical traceability, reviewable schema evolution, lower risk of silently rewriting generated artifacts, and a repeatable path for future deployments.

---

## Primary Keys

Every table uses an Oracle identity-generated numeric primary key.

Representative pattern:

```sql
id number generated by default on null as identity
```

Identity generation remains a database responsibility.

---

## Foreign Keys

The core publishing model includes:

```text
POSTS.CATEGORY_ID   → CATEGORIES.ID
POSTS.AUTHOR_ID     → AUTHORS.ID
POST_TAGS.POST_ID   → POSTS.ID
POST_TAGS.TAG_ID    → TAGS.ID
```

---

## Supporting Indexes

The original schema contains four explicit supporting indexes:

```text
POSTS_I1       → POSTS(CATEGORY_ID)
POSTS_I2       → POSTS(AUTHOR_ID)
POST_TAGS_I1   → POST_TAGS(POST_ID)
POST_TAGS_I2   → POST_TAGS(TAG_ID)
```

---

## Automatic Auditing

Every entity contains:

```text
CREATED
CREATED_BY
UPDATED
UPDATED_BY
```

Seven `BEFORE INSERT OR UPDATE` triggers maintain these values.

Representative attribution logic:

```sql
coalesce(
    sys_context('APEX$SESSION','APP_USER'),
    user
)
```

This preserves application-aware attribution when an APEX session exists while retaining a database-user fallback.

---

## Native Boolean Usage

TRINITY uses Oracle SQL Boolean columns for applicable state flags.

For Certifications, the current rule is explicit:

```text
ACTIVE_YN BOOLEAN DEFAULT TRUE NOT NULL
```

Application presentation is intentionally separate from storage:

```text
Database TRUE  → APEX Yes
Database FALSE → APEX No
```

Application components should preserve native Boolean session-state behavior for this column.

---

## OCI Object Storage Reference Model

The database does not store Event image binary data.

Instead:

```text
OCI Object Storage object
        │
        ▼
Object URL
        │
        ▼
EVENTS.FEATURED_IMAGE_URL
```

This keeps media content separate from relational metadata.

The current approach stores a URL reference only. A more integrated upload workflow may be introduced later.

---

## Deployment Sequence

A compatible deployment should conceptually follow:

```text
1. Review Quick SQL source
2. Execute original DDL baseline
3. Validate baseline objects
4. Apply migrations in numeric order
5. Validate current schema metadata
6. Import / validate Oracle APEX application
7. Validate application-to-database behavior
```

Do not apply migration scripts blindly to a schema whose current state is unknown.

---

## Representative Validation

### Event featured-image column

```sql
select column_name,
       data_type,
       data_length,
       nullable
from user_tab_columns
where table_name = 'EVENTS'
  and column_name = 'FEATURED_IMAGE_URL';
```

Expected current state:

```text
FEATURED_IMAGE_URL | VARCHAR2 | 500 | Y
```

### Certification Boolean column

```sql
select column_name,
       data_type,
       nullable,
       data_default
from user_tab_columns
where table_name = 'CERTIFICATIONS'
  and column_name = 'ACTIVE_YN';
```

Expected current state:

```text
ACTIVE_YN | BOOLEAN | N | TRUE
```

---

## Engineering Change Discipline

```text
Define change
    ↓
Assess deployed state
    ↓
Create ordered migration
    ↓
Review SQL
    ↓
Apply in development
    ↓
Validate metadata and data
    ↓
Validate dependent APEX behavior
    ↓
Update documentation
    ↓
Commit as one coherent change
```

Do not place credentials, Oracle Wallets, API keys, private connection strings, or environment secrets in this directory.

---

## Related Source

Oracle APEX application source:

```text
apex/exports/f109.sql
```

Architecture documentation:

```text
docs/architecture/
```

Architecture decisions:

```text
docs/decisions/
```

The database directory is intended to remain independently reviewable while preserving traceability to the Oracle APEX application that consumes it.
