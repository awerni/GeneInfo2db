DROP SCHEMA IF EXISTS cellline CASCADE;
DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;
CREATE SCHEMA cellline;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;
GRANT ALL ON SCHEMA cellline TO postgres;
GRANT ALL ON SCHEMA cellline TO public;
COMMENT ON SCHEMA public IS 'standard public schema';
COMMENT ON SCHEMA cellline IS 'cellline schema';
