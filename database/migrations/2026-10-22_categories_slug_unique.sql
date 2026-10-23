-- TRINITY Platform
-- CMS-001: Automatic Category Slug Generation
-- Date: 2026-10-22
-- Schema: WKSP_TRINITY
--
-- Purpose:
-- Enforce unique normalized category slugs.
--
-- Deployment:
-- Already executed successfully in OCI.
-- Run only once per target database.

CREATE UNIQUE INDEX CATEGORIES_SLUG_UQ
ON CATEGORIES (LOWER(TRIM(SLUG)));
