
CREATE OR REPLACE FUNCTION alphaShape_tester(
    _tbl REGCLASS,
    _geom TEXT,
    alpha FLOAT,
    isEmpty BOOLEAN,
    area FLOAT,
    Npoints BIGINT)
RETURNS SETOF TEXT AS
$BODY$
BEGIN
    EXECUTE format($$
    CREATE TABLE newquery AS
    SELECT pgr_alphaShape1((SELECT array_agg(%2$I) FROM %1$I), %3$s)
    AS geom$$, _tbl, _geom, alpha);

    RETURN QUERY
    SELECT results_eq(
        $$SELECT ST_IsValid(geom) FROM newquery$$,
        $$SELECT true$$,
        'SHOULD BE: valid with spoon radius = ' || alpha);

    RETURN QUERY
    SELECT results_eq(
        $$SELECT ST_Area(geom)::TEXT FROM newquery$$,
        $$SELECT $$ || area || '::TEXT',
        'SHOULD BE: ' || area || ' with spoon radius = ' || alpha);


    RETURN QUERY
    SELECT results_eq(
        $$SELECT ST_IsEmpty(geom) FROM newquery$$,
        $$SELECT $$ || isEmpty,
        'SHOULD BE: ' || isEmpty || ' with spoon radius = ' || alpha);


    RETURN QUERY
    SELECT results_eq(
        $$SELECT ST_Npoints(geom) FROM newquery$$,
        $$SELECT $$ || Npoints,
        'SHOULD BE: ' || Npoints || ' points with spoon radius = ' || alpha);

    DROP TABLE newquery;

END
$BODY$
LANGUAGE plpgsql VOLATILE;
