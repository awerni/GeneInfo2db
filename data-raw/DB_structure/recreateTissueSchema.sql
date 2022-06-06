DROP SCHEMA IF EXISTS tissue CASCADE;
CREATE SCHEMA tissue;
GRANT ALL ON SCHEMA tissue TO postgres;
GRANT ALL ON SCHEMA tissue TO public;
COMMENT ON SCHEMA tissue IS 'tissue schema';