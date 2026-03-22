-- import.sql
-- Import des CSV dans les tables decomposees
-- Jordan Lengrai, Nerval Gbaguidi

-- tables temporaires pour charger les CSV bruts
DROP TABLE IF EXISTS tmp_arbres;
DROP TABLE IF EXISTS tmp_ev;

CREATE TABLE tmp_arbres (
    "IDBASE"                    INTEGER,
    "TYPE EMPLACEMENT"          TEXT,
    "DOMANIALITE"               TEXT,
    "ARRONDISSEMENT"            TEXT,
    "COMPLEMENT ADRESSE"        TEXT,
    "LIEU / ADRESSE"            TEXT,
    "IDEMPLACEMENT"             TEXT,
    "LIBELLE FRANCAIS"          TEXT,
    "GENRE"                     TEXT,
    "ESPECE"                    TEXT,
    "VARIETE OUCULTIVAR"        TEXT,
    "CIRCONFERENCE (cm)"        INTEGER,
    "HAUTEUR (m)"               INTEGER,
    "STADE DE DEVELOPPEMENT"    TEXT,
    "REMARQUABLE"               TEXT,
    "geo_point_2d"              TEXT
);

CREATE TABLE tmp_ev (
    "Identifiant espace vert"       TEXT,
    "Nom de l'espace vert"          TEXT,
    "Typologie d'espace vert"       TEXT,
    "Catégorie"                     TEXT,
    "Adresse - Numéro"              TEXT,
    "Adresse - Complément"          TEXT,
    "Adresse - type voie"           TEXT,
    "Adresse - Libellé voie"        TEXT,
    "Code postal"                   TEXT,
    "Surface calculée"              TEXT,
    "Superficie totale réelle"      TEXT,
    "Surface horticole"             TEXT,
    "Présence cloture"              TEXT,
    "Périmètre"                     TEXT,
    "Année de l'ouverture"          TEXT,
    "Année de rénovation"           TEXT,
    "Ancien nom de l'espace vert"   TEXT,
    "Année de changement de nom"    TEXT,
    "Nombre d'entités"              TEXT,
    "Ouverture 24h"             TEXT,
    "ID_DIVISION"                   TEXT,
    "ID_ATELIER_HORTICOLE"          TEXT,
    "IDA3D_ENB"                     TEXT,
    "SITE_VILLES"                   TEXT,
    "ID_EQPT"                       TEXT,
    "Compétence"                    TEXT,
    "Geo Shape"                     TEXT,
    "URL_PLAN"                      TEXT,
    "Geo point"                     TEXT,
    "last_edited_user"              TEXT,
    "last_edited_date"              TEXT
);

\copy tmp_arbres FROM '../data/les-arbres.csv' WITH (FORMAT csv, DELIMITER ';', HEADER true, ENCODING 'UTF8');
\copy tmp_ev FROM '../data/espaces_verts.csv' WITH (FORMAT csv, DELIMITER ';', HEADER true, ENCODING 'UTF8');


-- =====================
-- Peuplement ARBRES
-- =====================

-- Encyclopedie : on prend le premier libellefrancais par (genre, espece)
INSERT INTO Encyclopedie (genre, espece, libellefrancais)
SELECT DISTINCT ON ("GENRE", "ESPECE")
       "GENRE", "ESPECE", "LIBELLE FRANCAIS"
FROM tmp_arbres
WHERE "GENRE" IS NOT NULL AND "GENRE" <> ''
  AND "ESPECE" IS NOT NULL AND "ESPECE" <> ''
ORDER BY "GENRE", "ESPECE", "LIBELLE FRANCAIS"
ON CONFLICT DO NOTHING;

-- on ajoute aussi les lignes avec genre sans espece
INSERT INTO Encyclopedie (genre, espece, libellefrancais)
SELECT DISTINCT ON ("GENRE", "ESPECE")
       "GENRE", COALESCE(NULLIF("ESPECE", ''), ''), "LIBELLE FRANCAIS"
FROM tmp_arbres
WHERE "GENRE" IS NOT NULL AND "GENRE" <> ''
  AND ("ESPECE" IS NULL OR "ESPECE" = '')
ORDER BY "GENRE", "ESPECE", "LIBELLE FRANCAIS"
ON CONFLICT DO NOTHING;

-- Emplacement
INSERT INTO Emplacement (idemplacement, geo_longitude, geo_latitude,
                         arrondissement, complementadresse, adresse)
SELECT DISTINCT
       "IDEMPLACEMENT",
       SPLIT_PART("geo_point_2d", ', ', 2)::DOUBLE PRECISION,
       SPLIT_PART("geo_point_2d", ', ', 1)::DOUBLE PRECISION,
       "ARRONDISSEMENT",
       NULLIF("COMPLEMENT ADRESSE", ''),
       "LIEU / ADRESSE"
FROM tmp_arbres
WHERE "geo_point_2d" IS NOT NULL AND "geo_point_2d" <> ''
  AND "IDEMPLACEMENT" IS NOT NULL AND "IDEMPLACEMENT" <> ''
ON CONFLICT DO NOTHING;

-- Arbre : on garde seulement le premier en cas de doublon sur idbase
INSERT INTO Arbre (idbase, typeemplacement, domanialite,
                   idemplacement, geo_longitude, geo_latitude,
                   genre, espece, varieteoucultivar,
                   circonferenceencm, hauteurenm,
                   stadedeveloppement, remarquable)
SELECT DISTINCT ON ("IDBASE")
       "IDBASE",
       "TYPE EMPLACEMENT",
       NULLIF("DOMANIALITE", ''),
       "IDEMPLACEMENT",
       SPLIT_PART("geo_point_2d", ', ', 2)::DOUBLE PRECISION,
       SPLIT_PART("geo_point_2d", ', ', 1)::DOUBLE PRECISION,
       NULLIF("GENRE", ''),
       NULLIF("ESPECE", ''),
       NULLIF("VARIETE OUCULTIVAR", ''),
       "CIRCONFERENCE (cm)",
       "HAUTEUR (m)",
       CASE
         WHEN "STADE DE DEVELOPPEMENT" IN ('Adulte', 'Jeune (arbre)', 'Mature')
         THEN "STADE DE DEVELOPPEMENT"
         ELSE NULL
       END,
       NULLIF("REMARQUABLE", '')
FROM tmp_arbres
ORDER BY "IDBASE"
ON CONFLICT DO NOTHING;


-- =====================
-- Peuplement ESPACES VERTS
-- =====================

-- Admi
INSERT INTO Admi (id_eqpt, id_division, competence)
SELECT DISTINCT ON ("ID_EQPT")
       "ID_EQPT",
       NULLIF("ID_DIVISION", '')::INTEGER,
       NULLIF("Compétence", '')
FROM tmp_ev
WHERE "ID_EQPT" IS NOT NULL AND "ID_EQPT" <> ''
ORDER BY "ID_EQPT"
ON CONFLICT DO NOTHING;

-- Historique
INSERT INTO Historique (ida3d_enb, annee_ouverture, annee_renovation,
                        ancien_nom_ev, annee_changement_nom, nb_entites,
                        ouvert_ferme, url_plan, last_edited_user,
                        last_edited_date)
SELECT DISTINCT ON ("IDA3D_ENB")
       "IDA3D_ENB",
       NULLIF("Année de l'ouverture", '')::INTEGER,
       NULLIF("Année de rénovation", '')::INTEGER,
       NULLIF("Ancien nom de l'espace vert", ''),
       NULLIF("Année de changement de nom", '')::INTEGER,
       NULLIF("Nombre d'entités", '')::INTEGER,
       NULLIF("Ouverture 24h_24h", ''),
       NULLIF("URL_PLAN", ''),
       NULLIF("last_edited_user", ''),
       NULLIF("last_edited_date", '')::TIMESTAMP
FROM tmp_ev
WHERE "IDA3D_ENB" IS NOT NULL AND "IDA3D_ENB" <> ''
ORDER BY "IDA3D_ENB"
ON CONFLICT DO NOTHING;

-- table temporaire pour associer chaque espace vert a son id_geom
CREATE TEMP TABLE tmp_geom_map AS
SELECT "Identifiant espace vert"::INTEGER AS nsq_espace_vert,
       CASE
         WHEN "Geo Shape" LIKE '%MultiPolygon%' THEN 'MultiPolygon'
         WHEN "Geo Shape" LIKE '%Polygon%' THEN 'Polygon'
         ELSE NULL
       END AS geom_type,
       NULLIF("Surface calculée", '')::INTEGER AS poly_area,
       NULLIF("Superficie totale réelle", '')::INTEGER AS surface_totale_reelle,
       NULLIF("Surface horticole", '')::INTEGER AS surface_horticole,
       NULLIF("Présence cloture", '') AS presence_cloture,
       NULLIF("Périmètre", '')::NUMERIC AS perimeter,
       "Geo Shape" AS geo_shape_raw
FROM tmp_ev
WHERE "Identifiant espace vert" IS NOT NULL
  AND "Identifiant espace vert" <> '';

ALTER TABLE tmp_geom_map ADD COLUMN id_geom SERIAL;

-- Geom_mesures
INSERT INTO Geom_mesures (id_geom, geom_type, poly_area, surface_totale_reelle,
                          surface_horticole, presence_cloture, perimeter)
SELECT id_geom, geom_type, poly_area, surface_totale_reelle,
       surface_horticole, presence_cloture, perimeter
FROM tmp_geom_map;

SELECT setval('geom_mesures_id_geom_seq', (SELECT MAX(id_geom) FROM Geom_mesures));

-- Geom_coordonnee : on parse les coordonnees du GeoJSON
INSERT INTO Geom_coordonnee (id_geom, ordre, longitude, latitude)
SELECT m.id_geom,
       (ROW_NUMBER() OVER (PARTITION BY m.id_geom ORDER BY t.ordinality)) - 1,
       (t.coord->>0)::NUMERIC,
       (t.coord->>1)::NUMERIC
FROM tmp_geom_map m
CROSS JOIN LATERAL (
    SELECT CASE
        WHEN (m.geo_shape_raw::json)->>'type' = 'MultiPolygon'
        THEN (m.geo_shape_raw::json)->'coordinates'->0->0
        ELSE (m.geo_shape_raw::json)->'coordinates'->0
    END AS ring
) r
CROSS JOIN LATERAL json_array_elements(r.ring) WITH ORDINALITY AS t(coord, ordinality)
WHERE m.geo_shape_raw IS NOT NULL AND m.geo_shape_raw <> '';

-- Espace_vert
INSERT INTO Espace_vert (nsq_espace_vert, nom_ev, type_ev, categorie,
                         adresse_numero, adresse_complement,
                         adresse_typevoie, adresse_libellevoie,
                         adresse_codepostal, geo_latitude_ev,
                         geo_longitude_ev, site_villes,
                         id_atelier_horticole, id_eqpt, ida3d_enb,
                         id_geom)
SELECT
       e."Identifiant espace vert"::INTEGER,
       NULLIF(e."Nom de l'espace vert", ''),
       NULLIF(e."Typologie d'espace vert", ''),
       NULLIF(e."Catégorie", ''),
       NULLIF(e."Adresse - Numéro", '')::INTEGER,
       NULLIF(e."Adresse - Complément", ''),
       NULLIF(e."Adresse - type voie", ''),
       NULLIF(e."Adresse - Libellé voie", ''),
       NULLIF(e."Code postal", ''),
       CASE WHEN e."Geo point" <> '' AND e."Geo point" IS NOT NULL
            THEN SPLIT_PART(e."Geo point", ', ', 1)::DOUBLE PRECISION
            ELSE NULL END,
       CASE WHEN e."Geo point" <> '' AND e."Geo point" IS NOT NULL
            THEN SPLIT_PART(e."Geo point", ', ', 2)::DOUBLE PRECISION
            ELSE NULL END,
       NULLIF(e."SITE_VILLES", ''),
       NULLIF(e."ID_ATELIER_HORTICOLE", '')::INTEGER,
       NULLIF(e."ID_EQPT", ''),
       NULLIF(e."IDA3D_ENB", ''),
       m.id_geom
FROM tmp_ev e
JOIN tmp_geom_map m ON e."Identifiant espace vert"::INTEGER = m.nsq_espace_vert
ON CONFLICT DO NOTHING;

-- nettoyage
DROP TABLE tmp_geom_map;
DROP TABLE tmp_arbres;
DROP TABLE tmp_ev;
