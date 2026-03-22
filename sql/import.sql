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
    "Ouverture 24h_24h"             TEXT,
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

\copy tmp_arbres FROM 'les-arbres.csv' WITH (FORMAT csv, DELIMITER ';', HEADER true, ENCODING 'UTF8');
\copy tmp_ev FROM 'espaces_verts.csv' WITH (FORMAT csv, DELIMITER ';', HEADER true, ENCODING 'UTF8');


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

-- Geom_mesures
INSERT INTO Geom_mesures (geom_type, poly_area, surface_totale_reelle,
                          surface_horticole, presence_cloture, perimeter)
SELECT
       CASE
         WHEN "Geo Shape" LIKE '%MultiPolygon%' THEN 'MultiPolygon'
         WHEN "Geo Shape" LIKE '%Polygon%' THEN 'Polygon'
         ELSE NULL
       END,
       NULLIF("Surface calculée", '')::INTEGER,
       NULLIF("Superficie totale réelle", '')::INTEGER,
       NULLIF("Surface horticole", '')::INTEGER,
       NULLIF("Présence cloture", ''),
       NULLIF("Périmètre", '')::NUMERIC
FROM tmp_ev
WHERE "Identifiant espace vert" IS NOT NULL
  AND "Identifiant espace vert" <> ''
ORDER BY "Identifiant espace vert"::INTEGER;

-- Espace_vert
INSERT INTO Espace_vert (nsq_espace_vert, nom_ev, type_ev, categorie,
                         adresse_numero, adresse_complement,
                         adresse_typevoie, adresse_libellevoie,
                         adresse_codepostal, geo_latitude_ev,
                         geo_longitude_ev, site_villes,
                         id_atelier_horticole, id_eqpt, ida3d_enb,
                         id_geom)
SELECT
       "Identifiant espace vert"::INTEGER,
       NULLIF("Nom de l'espace vert", ''),
       NULLIF("Typologie d'espace vert", ''),
       NULLIF("Catégorie", ''),
       NULLIF("Adresse - Numéro", '')::INTEGER,
       NULLIF("Adresse - Complément", ''),
       NULLIF("Adresse - type voie", ''),
       NULLIF("Adresse - Libellé voie", ''),
       NULLIF("Code postal", ''),
       CASE WHEN "Geo point" <> '' AND "Geo point" IS NOT NULL
            THEN SPLIT_PART("Geo point", ', ', 1)::DOUBLE PRECISION
            ELSE NULL END,
       CASE WHEN "Geo point" <> '' AND "Geo point" IS NOT NULL
            THEN SPLIT_PART("Geo point", ', ', 2)::DOUBLE PRECISION
            ELSE NULL END,
       NULLIF("SITE_VILLES", ''),
       NULLIF("ID_ATELIER_HORTICOLE", '')::INTEGER,
       NULLIF("ID_EQPT", ''),
       NULLIF("IDA3D_ENB", ''),
       gm.id_geom
FROM tmp_ev
JOIN Geom_mesures gm ON gm.id_geom = (
    SELECT COUNT(*)
    FROM tmp_ev t2
    WHERE t2."Identifiant espace vert" IS NOT NULL
      AND t2."Identifiant espace vert" <> ''
      AND t2."Identifiant espace vert"::INTEGER <= tmp_ev."Identifiant espace vert"::INTEGER
)
WHERE "Identifiant espace vert" IS NOT NULL
  AND "Identifiant espace vert" <> ''
ON CONFLICT DO NOTHING;

-- nettoyage
DROP TABLE tmp_arbres;
DROP TABLE tmp_ev;
