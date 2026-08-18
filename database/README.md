# TRINITY Platform — Database Engineering

**Relational data model and Oracle DDL for TRINITY Platform**

This directory contains the database source artifacts for the TRINITY Platform v1 engineering baseline.

The model was designed with Oracle Quick SQL and implemented on Oracle Autonomous AI Database 26ai. The generated DDL defines the current relational structure, supporting indexes, referential relationships, and automatic audit triggers used by the Oracle APEX application.

---

## Directory Contents

```text
database/
├── README.md
├── ddl/
│   └── TRINITY_V1_SCHEMA.sql
└── quicksql/
    └── trinity-v1.quicksql
```

| Artifact | Purpose |
|---|---|
| `quicksql/trinity-v1.quicksql` | Original Quick SQL source model |
| `ddl/TRINITY_V1_SCHEMA.sql` | Generated and executed Oracle DDL |

The Quick SQL source represents the logical input used to generate the physical database implementation. The DDL is the executable representation of that model.

---

## Database Baseline

| Property | Current baseline |
|---|---|
| Platform | Oracle Autonomous AI Database 26ai |
| Application integration | Oracle APEX |
| Parsing schema | `WKSP_TRINITY` |
| Quick SQL generator | Quick SQL 1.2.9 |
| Tables | 7 |
| Supporting indexes | 4 |
| Audit triggers | 7 |
| Primary-key strategy | Identity-generated `NUMBER` |
| Audit integration | APEX session user with database-user fallback |

> `TRINITY_V1_SCHEMA` is the name of the SQL script artifact. It is **not** the Oracle parsing schema. The current APEX parsing schema is `WKSP_TRINITY`.

---

## Relational Model

The v1 database contains seven tables.

### `AUTHORS`

Stores author identity and profile information for published content.

Key attributes include:

- `ID` — identity-generated primary key.
- `NAME` — required author display name.
- `SLUG` — required URL-oriented identifier.
- `EMAIL` — optional contact attribute.
- `BIO` — long-form author biography.
- `AVATAR_URL` — optional image reference.
- `ACTIVE_YN` — Boolean active-state flag.
- Standard audit columns.

---

### `CATEGORIES`

Stores content classifications.

Key attributes include:

- `ID` — identity-generated primary key.
- `NAME` — required category name.
- `SLUG` — required URL-oriented identifier.
- `DESCRIPTION` — optional category description.
- `ACTIVE_YN` — Boolean active-state flag.
- Standard audit columns.

---

### `POSTS`

Stores the primary publishing content managed by TRINITY.

Key attributes include:

- `ID` — identity-generated primary key.
- `CATEGORY_ID` — foreign key to `CATEGORIES`.
- `AUTHOR_ID` — foreign key to `AUTHORS`.
- `TITLE` — required post title.
- `SLUG` — required URL-oriented identifier.
- `EXCERPT` — short article summary.
- `CONTENT` — long-form article content.
- `FEATURED_IMAGE_URL` — optional image reference.
- `STATUS` — publication lifecycle value.
- `PUBLISHED_AT` — publication timestamp.
- `FEATURED_YN` — Boolean featured-state flag.
- Standard audit columns.

The Oracle APEX application currently manages the publication states:

```text
DRAFT
PUBLISHED
ARCHIVED
```

These values are controlled at the application layer in the current baseline.

---

### `TAGS`

Stores reusable content tags.

Key attributes include:

- `ID` — identity-generated primary key.
- `NAME` — required tag name.
- `SLUG` — required URL-oriented identifier.
- Standard audit columns.

---

### `POST_TAGS`

Implements the many-to-many relationship between posts and tags.

Key attributes include:

- `ID` — identity-generated primary key.
- `POST_ID` — foreign key to `POSTS`.
- `TAG_ID` — foreign key to `TAGS`.
- Standard audit columns.

---

### `EVENTS`

Stores technical events and activities.

Key attributes include:

- `ID` — identity-generated primary key.
- `TITLE` — required event title.
- `SLUG` — required URL-oriented identifier.
- `DESCRIPTION` — long-form event description.
- `EVENT_DATE` — event timestamp.
- `LOCATION` — optional event location.
- `EVENT_URL` — optional external reference.
- `STATUS` — event lifecycle value.
- Standard audit columns.

The source Quick SQL model defines the intended values:

```text
UPCOMING
COMPLETED
CANCELLED
```

---

### `CERTIFICATIONS`

Stores professional certification records.

Key attributes include:

- `ID` — identity-generated primary key.
- `NAME` — required certification name.
- `ISSUER` — certification issuer.
- `CREDENTIAL_ID` — optional credential identifier.
- `CREDENTIAL_URL` — optional credential reference.
- `ISSUED_DATE` — issue date.
- `EXPIRATION_DATE` — expiration date when applicable.
- `DESCRIPTION` — optional long-form description.
- `ACTIVE_YN` — Boolean active-state flag.
- Standard audit columns.

---

## Core Relationships

The primary relational structure is:

```text
AUTHORS       1 ───────────< POSTS
                              │
CATEGORIES    1 ───────────<  │
                              │
                              │
POSTS         1 ───────< POST_TAGS >─────── 1 TAGS
```

In relational terms:

- One author can be associated with many posts.
- One category can be associated with many posts.
- One post can be associated with many tags.
- One tag can be associated with many posts.
- `POST_TAGS` resolves the posts-to-tags many-to-many relationship.
- `EVENTS` and `CERTIFICATIONS` are standalone entities in the current v1 baseline.

---

## Primary Keys

Every table uses an Oracle identity-generated numeric primary key.

Representative implementation:

```sql
id number generated by default on null as identity
   constraint authors_id_pk primary key
```

This allows Oracle Database to generate identifiers while still permitting a supplied value when required by a controlled migration or import process.

---

## Foreign Keys

The current DDL implements four foreign-key relationships:

```text
POSTS.CATEGORY_ID   → CATEGORIES.ID
POSTS.AUTHOR_ID     → AUTHORS.ID
POST_TAGS.POST_ID   → POSTS.ID
POST_TAGS.TAG_ID    → TAGS.ID
```

Representative implementation:

```sql
category_id number
            constraint posts_category_id_fk
            references categories
```

Foreign-key columns are indexed by the generated DDL.

---

## Supporting Indexes

The schema contains four explicit supporting indexes:

```text
POSTS_I1       → POSTS(CATEGORY_ID)
POSTS_I2       → POSTS(AUTHOR_ID)
POST_TAGS_I1   → POST_TAGS(POST_ID)
POST_TAGS_I2   → POST_TAGS(TAG_ID)
```

These indexes support access paths involving the current foreign-key relationships.

---

## Automatic Auditing

Each table contains the following standard audit columns:

```text
CREATED
CREATED_BY
UPDATED
UPDATED_BY
```

Seven `BEFORE INSERT OR UPDATE` triggers maintain these attributes automatically:

```text
AUTHORS_BIU
CATEGORIES_BIU
POSTS_BIU
TAGS_BIU
POST_TAGS_BIU
EVENTS_BIU
CERTIFICATIONS_BIU
```

The trigger logic uses the current Oracle APEX application user when an APEX session exists:

```sql
coalesce(
    sys_context('APEX$SESSION','APP_USER'),
    user
)
```

On insert:

- `CREATED` is populated with `SYSDATE`.
- `CREATED_BY` is populated from the APEX session user or database user.

On both insert and update:

- `UPDATED` is populated with `SYSDATE`.
- `UPDATED_BY` is populated from the APEX session user or database user.

This provides application-aware attribution while preserving a database-user fallback for operations performed outside Oracle APEX.

---

## Quick SQL Source

The source model is stored at:

```text
database/quicksql/trinity-v1.quicksql
```

The model defines:

```text
authors
categories
posts
tags
post_tags
events
certifications
```

The original generation metadata preserved in the exported DDL identifies:

```text
Quick SQL 1.2.9
Generated: 2026-08-13 11:15:51 AM
```

The non-default Quick SQL settings recorded with the source are:

```text
apex      = Y
auditcols = true
db        = 23
pk        = IDENTITY
```

The `db` value above is Quick SQL generation metadata and should not be interpreted as the deployed database service version. The implemented TRINITY environment uses Oracle Autonomous AI Database 26ai.

---

## DDL Artifact

The generated implementation is stored at:

```text
database/ddl/TRINITY_V1_SCHEMA.sql
```

The script contains the current v1 physical database baseline:

```text
7 CREATE TABLE statements
4 CREATE INDEX statements
7 CREATE OR REPLACE TRIGGER statements
```

The source Quick SQL model and its generation metadata are also preserved as a comment at the end of the DDL file, providing traceability from logical definition to generated SQL.

---

## Current Integrity Scope

The current baseline implements:

- Primary-key constraints.
- Foreign-key constraints.
- Required columns where defined by the model.
- Identity-based identifiers.
- Automatic audit maintenance.
- Supporting indexes for foreign-key columns.

Some business rules currently remain at the Oracle APEX application layer rather than being enforced by database constraints. Examples include publication-state selections presented by APEX.

Future hardening may evaluate database-level constraints for rules that should remain valid regardless of the calling application.

---

## Deployment Notes

The DDL should be reviewed before execution in any target environment.

A high-level deployment sequence is:

```text
Quick SQL source
       ↓
Review generated DDL
       ↓
Execute schema objects
       ↓
Validate tables and constraints
       ↓
Validate indexes
       ↓
Validate audit triggers
       ↓
Import / validate Oracle APEX application
```

The target Oracle environment must support the SQL features used by this baseline, including Oracle `BOOLEAN` table columns.

Environment-specific deployment automation is outside the current v1 repository baseline and will be documented as the project evolves.

---

## Validation

After deployment, representative validation queries can include:

```sql
select table_name
from user_tables
order by table_name;
```

```sql
select constraint_name,
       constraint_type,
       table_name,
       status
from user_constraints
where table_name in (
    'AUTHORS',
    'CATEGORIES',
    'POSTS',
    'TAGS',
    'POST_TAGS',
    'EVENTS',
    'CERTIFICATIONS'
)
order by table_name, constraint_type;
```

```sql
select trigger_name,
       table_name,
       status
from user_triggers
order by table_name, trigger_name;
```

These examples inspect the deployed state; they do not replace environment-specific release validation.

---

## Engineering Notes

The database directory is treated as source-controlled engineering material.

Changes to the model should follow this general discipline:

1. Update the logical Quick SQL source when the change originates in the model.
2. Review the generated DDL.
3. Assess migration impact before applying structural changes to an existing environment.
4. Validate database objects after deployment.
5. Validate dependent Oracle APEX functionality.
6. Commit the model, implementation, and relevant documentation together when they represent one logical change.

Do not place credentials, Oracle Wallets, API keys, connection strings containing secrets, or environment-specific private configuration in this directory.

---

## Related Source

Oracle APEX application source is maintained separately at:

```text
apex/exports/f109.sql
```

Architecture and implementation documentation is maintained under:

```text
docs/
```

The separation keeps the database implementation independently reviewable while preserving traceability to the application that consumes it.
