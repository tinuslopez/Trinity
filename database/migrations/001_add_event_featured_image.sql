-- ---------------------------------------------------------------------------
-- TRINITY Platform
-- Database Migration 001
-- Add featured image support to Events
-- ---------------------------------------------------------------------------

ALTER TABLE events
ADD featured_image_url VARCHAR2(500);
