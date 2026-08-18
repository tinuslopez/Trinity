# ADR-001: TRINITY Platform Baseline Architecture

**Status:** Accepted<br>
**Date:** 2026-08-17<br>
**Decision owners:** TRINITY Platform<br>
**Scope:** TRINITY Platform v1<br>
**Architecture domain:** Application and data platform

---

## 1. Decision Summary

TRINITY Platform v1 will use the following baseline architecture:

```text
Oracle Cloud Infrastructure
        │
        ▼
Oracle Autonomous AI Database 26ai
APEX workload
        │
        ▼
Oracle APEX
Application 109 — TRINITY Platform
        │
        ▼
Parsing Schema — WKSP_TRINITY
```

The current baseline will **not** introduce a dedicated OCI Compute instance.

The Oracle APEX application and its relational database will remain on the managed Autonomous AI Database APEX workload until a concrete technical requirement justifies additional infrastructure.

---

## 2. Context

TRINITY is being developed as a real Oracle engineering platform rather than as a demonstration-only application.

The v1 implementation requires:

- A managed Oracle Database platform.
- Oracle APEX application development.
- Relational data modeling.
- Administrative content-management capabilities.
- Authentication and authorization.
- Source-controlled application and database artifacts.
- A low operational footprint.
- A deployment model that can evolve without introducing unnecessary infrastructure prematurely.

The current application contains administrative functionality for:

```text
Posts
Authors
Categories
```

The current database model contains:

```text
AUTHORS
CATEGORIES
POSTS
TAGS
POST_TAGS
EVENTS
CERTIFICATIONS
```

The Oracle APEX application uses:

```text
Application ID: 109
Application:    TRINITY Platform
Parsing schema: WKSP_TRINITY
```

The database baseline contains:

```text
7 tables
4 supporting indexes
7 audit triggers
```

---

## 3. Problem Statement

TRINITY needs an application and data platform that supports current requirements without creating operational complexity that provides no immediate engineering benefit.

A dedicated application server or virtual machine would introduce additional responsibilities such as:

- Operating-system administration.
- Runtime installation and maintenance.
- Patch management.
- Process management.
- Additional network configuration.
- Additional deployment procedures.
- Additional monitoring responsibilities.
- Additional security hardening.

Those responsibilities are not currently required to deliver the implemented Oracle APEX application.

The architecture therefore needs to answer the following question:

> What is the minimum production-oriented Oracle platform baseline that supports the current TRINITY application while preserving a credible path for future evolution?

---

## 4. Decision Drivers

The decision is based on the following priorities.

### 4.1 Oracle-native implementation

TRINITY is intended to demonstrate practical use of Oracle technologies.

The baseline should therefore use Oracle Database and Oracle APEX directly rather than adding an unrelated application stack without a requirement.

### 4.2 Database-first engineering

The relational model is a core part of the platform.

The architecture must preserve:

- Primary keys.
- Foreign keys.
- Supporting indexes.
- Identity-generated identifiers.
- Automatic auditing.
- Explicit schema ownership.

### 4.3 Low operational complexity

The current platform should minimize infrastructure administration while the application scope remains compact.

### 4.4 Source-control readiness

The architecture must support the preservation of:

```text
Quick SQL source
Oracle DDL
Oracle APEX application export
Architecture documentation
Architecture Decision Records
```

### 4.5 Clear current-state documentation

The architecture must distinguish between deployed components and future possibilities.

### 4.6 Incremental evolution

Future services should be added only when a real technical or operational requirement justifies them.

---

## 5. Decision

TRINITY Platform v1 will use:

### Cloud platform

```text
Oracle Cloud Infrastructure
```

### Data platform

```text
Oracle Autonomous AI Database 26ai
```

### Workload

```text
APEX
```

### Application platform

```text
Oracle APEX
```

### Application

```text
Application 109 — TRINITY Platform
```

### Parsing schema

```text
WKSP_TRINITY
```

### Runtime model

The Oracle APEX application will use the managed capabilities available with the Autonomous AI Database APEX workload.

No dedicated OCI Compute instance is part of the current v1 baseline.

---

## 6. Current Logical Architecture

```text
┌────────────────────────────────────┐
│ Developer / Administrator          │
│                                    │
│ Browser                            │
│ VS Code                            │
│ Git                                │
│ GitHub                             │
│ OCI CLI                            │
└─────────────────┬──────────────────┘
                  │
                  │ HTTPS
                  ▼
┌────────────────────────────────────┐
│ Oracle APEX                        │
│                                    │
│ Application 109                    │
│ TRINITY Platform                   │
│                                    │
│ Authentication                     │
│ Authorization                      │
│ Reports                            │
│ Forms                              │
│ LOVs                               │
│ Dynamic Actions                    │
│ Page Processing                    │
└─────────────────┬──────────────────┘
                  │
                  ▼
┌────────────────────────────────────┐
│ Autonomous AI Database 26ai        │
│                                    │
│ Parsing Schema: WKSP_TRINITY       │
│                                    │
│ Tables                             │
│ Primary Keys                       │
│ Foreign Keys                       │
│ Indexes                            │
│ Audit Triggers                     │
└────────────────────────────────────┘
```

---

## 7. Current Physical Architecture

The current OCI-hosted runtime is:

```text
Oracle Cloud Infrastructure
Region: mx-monterrey-1
│
└── Autonomous AI Database
    │
    ├── Database version: 26ai
    ├── Workload: APEX
    ├── Service tier: Always Free
    │
    └── Oracle APEX
        │
        └── Application 109
            TRINITY Platform
```

The developer workstation and GitHub repository are external to the OCI runtime boundary.

---

## 8. Application Responsibilities

Oracle APEX currently owns the application-layer responsibilities.

These include:

- Authentication.
- Authorization.
- Navigation.
- Reports.
- Forms.
- Shared Lists of Values.
- Page validations.
- Page processing.
- Dynamic Actions.
- Publication-state selection.
- Client-side slug generation.

The current administrative scope includes:

```text
Home
Posts
Post
Categories
Category
Authors
Author
Login
Global Page
```

---

## 9. Database Responsibilities

Oracle Autonomous AI Database currently owns the persistent data and relational-integrity responsibilities.

These include:

- Table storage.
- Primary keys.
- Foreign keys.
- Identity-generated primary keys.
- Supporting indexes.
- Audit columns.
- Audit triggers.
- Persistent application data.

The current relational model is:

```text
AUTHORS       1 ───────────< POSTS

CATEGORIES    1 ───────────< POSTS

POSTS         1 ───────< POST_TAGS >─────── 1 TAGS
```

`EVENTS` and `CERTIFICATIONS` are currently standalone entities.

---

## 10. Audit Strategy

Each database table contains:

```text
CREATED
CREATED_BY
UPDATED
UPDATED_BY
```

Audit triggers use the Oracle APEX application user when available and fall back to the database user.

Representative logic:

```sql
coalesce(
    sys_context('APEX$SESSION','APP_USER'),
    user
)
```

This keeps audit attribution in the database layer while retaining application context.

---

## 11. Source-Control Strategy

The baseline architecture includes source control as an engineering requirement.

### Database model

```text
database/quicksql/trinity-v1.quicksql
```

### Database implementation

```text
database/ddl/TRINITY_V1_SCHEMA.sql
```

### Oracle APEX application

```text
apex/exports/f109.sql
```

### Architecture documentation

```text
docs/architecture/
```

### Architecture decisions

```text
docs/decisions/
```

Git is used for local history and GitHub is used as the remote source repository.

---

## 12. Why Dedicated OCI Compute Is Not Included

A dedicated OCI Compute instance is not required by the current implementation.

The existing baseline already provides:

- Oracle Database.
- Oracle APEX.
- Application runtime.
- Application-to-database integration.
- Managed cloud hosting for the current application.

Adding Compute now would introduce operational responsibilities without providing a required v1 capability.

Therefore:

> Compute will be introduced only when a future application component requires an independent runtime, service, integration layer, background process, or other workload that cannot reasonably remain within the existing managed baseline.

---

## 13. Alternatives Considered

### Alternative A — Dedicated OCI Compute + custom application runtime

Example direction:

```text
OCI Compute
    │
    ├── Java / GraalVM / Quarkus
    │
    └── Custom application service
            │
            ▼
       Oracle Database
```

#### Advantages

- Greater runtime control.
- Suitable for custom services outside Oracle APEX.
- Supports independent API or backend processes.
- Greater flexibility for future non-APEX workloads.

#### Disadvantages for the current baseline

- Additional operating-system administration.
- Runtime patching.
- Deployment-process complexity.
- Additional security hardening.
- Additional observability requirements.
- Additional network design.
- No current v1 requirement justifies the additional operational burden.

#### Decision

Not selected for the v1 baseline.

It remains a valid future option if TRINITY develops requirements that need an independent application runtime.

---

### Alternative B — Non-Oracle application platform

A non-Oracle application framework could be placed in front of an Oracle or non-Oracle database.

#### Advantages

- Broad framework choice.
- Potential portability across cloud providers.
- Large open-source ecosystem.

#### Disadvantages for the current baseline

- Reduces direct use of Oracle APEX.
- Adds application-stack complexity.
- Introduces additional deployment and maintenance concerns.
- Does not provide a clear benefit for the current administrative CMS requirements.

#### Decision

Not selected for the current TRINITY v1 application.

---

### Alternative C — Oracle APEX + Autonomous AI Database

#### Advantages

- Direct alignment with current application requirements.
- Managed application and data platform.
- Strong relational integration.
- Rapid application development.
- Low infrastructure-management burden.
- Supports source-controlled APEX exports.
- Supports Oracle SQL and PL/SQL development.
- Preserves a clear Oracle-focused engineering baseline.

#### Disadvantages

- Application architecture is coupled to Oracle APEX.
- Some application behavior is represented as APEX metadata rather than conventional source files.
- Advanced custom runtime requirements may eventually require additional services.
- Environment promotion still requires disciplined export/import and deployment practices.

#### Decision

Selected.

---

## 14. Consequences

### Positive consequences

The decision provides:

- A small and understandable runtime footprint.
- Direct Oracle technology alignment.
- Reduced operational burden.
- Rapid delivery of administrative functionality.
- Strong integration between application and database.
- Clear relational ownership.
- Straightforward source-artifact organization.
- A disciplined baseline for architecture review, source traceability, and future evolution.
- A credible foundation for further architecture work.

### Negative consequences

The decision also creates constraints:

- Oracle APEX becomes a central application dependency.
- APEX exports are generated source artifacts rather than hand-authored application code.
- Some application logic remains metadata-driven.
- Future requirements outside the APEX model may require architectural expansion.
- Promotion between environments requires disciplined import and validation procedures.

These constraints are accepted for v1.

---

## 15. Risks and Mitigations

### Risk — Future custom-service requirements

TRINITY may eventually require capabilities that do not fit naturally inside the current APEX baseline.

**Mitigation:**

Introduce an independent runtime only after a concrete use case is defined.

---

### Risk — Mixing roadmap and current architecture

Future services could be mistakenly represented as already deployed.

**Mitigation:**

All architecture documentation must explicitly separate:

```text
Current
In Progress
Planned
```

---

### Risk — Application export drift

The GitHub APEX export could diverge from the application currently being developed.

**Mitigation:**

Use a controlled export workflow:

```text
Develop
  ↓
Validate
  ↓
Export
  ↓
Security review
  ↓
Git diff
  ↓
Commit
```

---

### Risk — Database model drift

The Quick SQL source, generated DDL, and deployed schema could become inconsistent.

**Mitigation:**

Maintain traceability between:

```text
Quick SQL
    ↓
DDL
    ↓
Database
    ↓
APEX
```

Structural changes must include model, implementation, and dependent-application review.

---

### Risk — Sensitive data in source control

APEX exports, screenshots, configuration files, or local development artifacts may contain environment information.

**Mitigation:**

Do not commit:

- Passwords.
- Tokens.
- Private keys.
- OCI API signing keys.
- Oracle Wallets.
- Active APEX sessions.
- Private connection credentials.
- Sensitive personal information.

Every public push should receive a security review.

---

## 16. Security Position

The current baseline uses:

```text
Oracle APEX Accounts
```

for application authentication and:

```text
Administration Rights
```

as an application authorization mechanism.

Database integrity remains separate from application access control.

The security model will be reviewed as public-facing functionality is introduced.

No assumption is made in this ADR that the current administrative security configuration represents the final production security architecture.

---

## 17. Availability and Operations Position

The current baseline intentionally relies on the managed behavior of the selected Oracle cloud services rather than introducing custom runtime infrastructure.

Operational documentation will evolve as the project gains:

- Public-facing traffic.
- Deployment environments.
- Domain configuration.
- Media storage.
- Monitoring requirements.
- Recovery procedures.
- Formal release management.

The absence of those additions in this ADR is intentional.

---

## 18. Planned Evolution

Potential future architecture may include:

```text
Public-facing Oracle APEX experience
OCI Object Storage
Custom domain
OCI DNS
Additional administration modules
Expanded observability
Independent application services
```

These are not part of the accepted current-state baseline unless and until separately implemented and documented.

Any material change to the platform baseline should produce either:

- an amendment to this decision, or
- a new Architecture Decision Record.

---

## 19. Decision Boundaries

This ADR decides:

- The v1 Oracle application and data platform baseline.
- The use of Autonomous AI Database 26ai.
- The use of Oracle APEX.
- The exclusion of dedicated OCI Compute from the current baseline.
- The separation of application and database responsibilities.
- The requirement for source-controlled APEX and database artifacts.

This ADR does **not** decide:

- The final public-site information architecture.
- Custom-domain implementation.
- OCI DNS implementation.
- OCI Object Storage implementation.
- Future API architecture.
- Future Java or other independent runtime architecture.
- Production CI/CD tooling.
- Multi-environment deployment topology.
- Final observability architecture.

Those topics require their own decisions when they become active engineering concerns.

---

## 20. Acceptance Criteria

This decision is considered correctly implemented while the following remain true:

- TRINITY runs on Oracle APEX with Autonomous AI Database 26ai.
- Application 109 remains the current source-controlled APEX application.
- `WKSP_TRINITY` remains the current parsing schema unless formally changed.
- Database source remains version controlled.
- Oracle APEX application exports remain version controlled.
- No dedicated Compute instance is presented as part of the current architecture unless actually introduced.
- Architecture documentation clearly labels future components.
- Sensitive credentials are excluded from the repository.

---

## 21. Review Triggers

This ADR should be reviewed when any of the following occurs:

- A dedicated OCI Compute instance is introduced.
- An independent backend service is introduced.
- The application moves away from Oracle APEX.
- The primary database platform changes.
- A separate public application is introduced.
- A new production deployment topology is established.
- Multi-environment deployment becomes formalized.
- A major security-architecture change is introduced.
- A major integration layer is added.

---

## 22. Final Decision Statement

TRINITY Platform v1 adopts **Oracle Autonomous AI Database 26ai with the APEX workload and Oracle APEX as the application platform**.

This architecture satisfies the current functional requirements while maintaining a small operational footprint, strong Oracle technology alignment, explicit relational design, and source-control traceability.

A dedicated OCI Compute instance is intentionally excluded from the current baseline because no implemented v1 requirement justifies the additional operational complexity.

Future infrastructure will be introduced only when supported by a concrete architectural requirement and documented through an explicit engineering decision.
