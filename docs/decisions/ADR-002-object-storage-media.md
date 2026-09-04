# ADR-002: OCI Object Storage for TRINITY Media Assets

**Status:** Accepted<br>
**Date:** 2026-09-04<br>
**Decision owners:** TRINITY Platform<br>
**Scope:** TRINITY Platform media handling<br>
**Architecture domain:** Storage and application integration

---

## 1. Decision Summary

TRINITY will use OCI Object Storage for selected media assets, beginning with featured images associated with Event records.

The Oracle APEX application will not store the image binary in the relational `EVENTS` table.

Instead:

```text
OCI Object Storage object
        │
        ▼
Object URL
        │
        ▼
EVENTS.FEATURED_IMAGE_URL
        │
        ▼
Oracle APEX rendering
```

Oracle APEX and Autonomous AI Database 26ai remain the application and data runtime baseline.

---

## 2. Context

The original TRINITY v1 architecture intentionally avoided infrastructure that was not required by the administrative CMS.

As Events administration was implemented, TRINITY required a practical way to associate photographic evidence and event images with relational Event records.

The current environment does not use a dedicated OCI Compute instance. OCI Object Storage provides a managed Oracle-native way to separate media files from relational metadata.

---

## 3. Decision Drivers

The decision is based on:

- Avoiding BLOB storage in the initial Event implementation.
- Keeping the relational table focused on metadata.
- Reusing OCI-native managed storage.
- Avoiding a dedicated Compute instance.
- Keeping the implementation simple and demonstrable.
- Preserving a path toward a more integrated media workflow later.
- Maintaining clear source-control and architecture boundaries.

---

## 4. Decision

TRINITY will store selected Event image files in OCI Object Storage.

The `EVENTS` table stores the image reference in:

```text
FEATURED_IMAGE_URL VARCHAR2(500)
```

The field is nullable.

Oracle APEX stores and renders the URL through the Events administrative module:

```text
Page 14 — Events
Page 15 — Event
```

The current Object Storage upload step is manual and external to the APEX form.

---

## 5. Current Media Flow

```text
Administrator
     │
     ├── Upload image to OCI Object Storage
     │
     ▼
Object created
     │
     ▼
Object URL obtained
     │
     ▼
Oracle APEX Event form
     │
     ▼
EVENTS.FEATURED_IMAGE_URL
     │
     ▼
Events report
     │
     ▼
Image rendered in browser
```

---

## 6. Database Impact

The schema change is captured as:

```text
database/migrations/001_add_event_featured_image.sql
```

Final column metadata:

```text
COLUMN_NAME   FEATURED_IMAGE_URL
DATA_TYPE     VARCHAR2
DATA_LENGTH   500
NULLABLE      Y
```

No binary image data is stored in the `EVENTS` table.

---

## 7. Application Impact

The Oracle APEX application includes:

```text
P15_FEATURED_IMAGE_URL
```

on the Event form.

The Events report renders the image based on the stored URL.

The APEX application remains responsible for presentation and metadata entry, not media-object persistence.

---

## 8. Consequences

### Positive

- Keeps media outside relational table storage.
- Uses an OCI-native managed service.
- Avoids additional application runtime infrastructure.
- Provides a simple working media path.
- Supports event evidence and visual presentation.
- Keeps the integration easy to inspect and explain.

### Negative

- Upload is currently a manual two-step process.
- The database stores an external URL that must remain valid.
- Object lifecycle and URL accessibility must be managed separately.
- A future production design may require stricter access control, signed URLs, or application-managed upload.

These constraints are accepted for the current development baseline.

---

## 9. Security Position

The repository must not contain:

- OCI credentials.
- Private signing keys.
- Authentication tokens.
- Private access configuration.
- Active session information.
- Sensitive account identifiers unless explicitly required and safe for publication.

Public accessibility of individual media objects should be reviewed according to the intended use of each asset.

---

## 10. Alternatives Considered

### Store image binaries in Oracle Database

Not selected for the initial Event implementation because it would increase database responsibility and require a different APEX image-delivery pattern without a current requirement-driven advantage.

### Dedicated OCI Compute media service

Not selected because it would introduce operating-system and runtime administration solely to solve a simple media-storage requirement.

### External third-party image host

Not selected because OCI Object Storage provides a direct Oracle-native solution aligned with the platform.

---

## 11. Relationship to ADR-001

ADR-001 remains valid for the primary application and database runtime:

```text
Oracle APEX
        +
Autonomous AI Database 26ai
```

This ADR extends the platform with a managed storage service for media assets.

It does **not** introduce dedicated OCI Compute, an independent application runtime, or a custom backend service.

---

## 12. Future Review Triggers

Review this decision when:

- Media upload is moved directly into Oracle APEX.
- Private objects or signed URLs are required.
- A custom domain is introduced for media delivery.
- Object lifecycle policies become necessary.
- Content volume materially increases.
- A CDN or different delivery layer is introduced.
- Public-site requirements change the media security model.

---

## 13. Acceptance Criteria

This decision is correctly implemented while:

- Selected Event images are stored in OCI Object Storage.
- `EVENTS.FEATURED_IMAGE_URL` stores the media reference.
- Oracle APEX renders the referenced image.
- No image binary is required in the Event relational record.
- No dedicated OCI Compute instance is falsely represented as required by the media workflow.
- Credentials and sensitive OCI configuration remain outside the repository.
