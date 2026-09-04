-- ---------------------------------------------------------------------------
-- TRINITY Platform
-- Database Migration 002
-- Harden Certification active-state defaults and nullability
-- ---------------------------------------------------------------------------

-- The v1 baseline already defines ACTIVE_YN as native Oracle SQL BOOLEAN.
-- Normalize existing null values before enforcing the final constraint.
UPDATE certifications
SET active_yn = TRUE
WHERE active_yn IS NULL;

ALTER TABLE certifications
MODIFY (active_yn DEFAULT TRUE NOT NULL);
