DROP SCHEMA IF EXISTS cellline CASCADE;
CREATE SCHEMA cellline;
GRANT ALL ON SCHEMA cellline TO postgres;
GRANT ALL ON SCHEMA cellline TO public;
COMMENT ON SCHEMA cellline IS 'cellline schema';