-- verification_df.sql
-- Jordan Lengrai, Nerval Gbaguidi

DROP TABLE IF EXISTS arbres_brut;
DROP TABLE IF EXISTS ev_brut;

CREATE TABLE arbres_brut (
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

CREATE TABLE ev_brut (
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

\copy arbres_brut FROM 'les-arbres.csv' WITH (FORMAT csv, DELIMITER ';', HEADER true, ENCODING 'UTF8');
\copy ev_brut FROM 'espaces_verts.csv' WITH (FORMAT csv, DELIMITER ';', HEADER true, ENCODING 'UTF8');


-- =======================================================================
-- ARBRES
-- =======================================================================

-- DF1 : idbase -> tous les autres attributs
SELECT "IDBASE",
       COUNT(DISTINCT ROW("TYPE EMPLACEMENT", "DOMANIALITE",
             "IDEMPLACEMENT", "GENRE", "ESPECE", "VARIETE OUCULTIVAR",
             "CIRCONFERENCE (cm)", "HAUTEUR (m)",
             "STADE DE DEVELOPPEMENT", "REMARQUABLE",
             "geo_point_2d")) AS nb
FROM arbres_brut
GROUP BY "IDBASE"
HAVING COUNT(DISTINCT ROW("TYPE EMPLACEMENT", "DOMANIALITE",
             "IDEMPLACEMENT", "GENRE", "ESPECE", "VARIETE OUCULTIVAR",
             "CIRCONFERENCE (cm)", "HAUTEUR (m)",
             "STADE DE DEVELOPPEMENT", "REMARQUABLE",
             "geo_point_2d")) > 1;

-- DF2 : (idemplacement, geo_longitude, geo_latitude) -> arrondissement, complementadresse, adresse
SELECT "IDEMPLACEMENT", geo_lon, geo_lat,
       COUNT(DISTINCT "ARRONDISSEMENT") AS nb_arr,
       COUNT(DISTINCT "LIEU / ADRESSE") AS nb_adr
FROM (
    SELECT "IDEMPLACEMENT",
           SPLIT_PART("geo_point_2d", ', ', 2) AS geo_lon,
           SPLIT_PART("geo_point_2d", ', ', 1) AS geo_lat,
           "ARRONDISSEMENT",
           "LIEU / ADRESSE"
    FROM arbres_brut
    WHERE "geo_point_2d" IS NOT NULL AND "geo_point_2d" <> ''
) t
GROUP BY "IDEMPLACEMENT", geo_lon, geo_lat
HAVING COUNT(DISTINCT "ARRONDISSEMENT") > 1
    OR COUNT(DISTINCT "LIEU / ADRESSE") > 1;

-- DF3 : (genre, espece) -> libellefrancais
SELECT "GENRE", "ESPECE",
       ARRAY_AGG(DISTINCT "LIBELLE FRANCAIS") AS libelles,
       COUNT(DISTINCT "LIBELLE FRANCAIS") AS nb
FROM arbres_brut
WHERE "GENRE" <> '' AND "ESPECE" <> '' AND "LIBELLE FRANCAIS" <> ''
GROUP BY "GENRE", "ESPECE"
HAVING COUNT(DISTINCT "LIBELLE FRANCAIS") > 1;

-- on montre que idemplacement seul ne determine pas arrondissement
SELECT "IDEMPLACEMENT",
       ARRAY_AGG(DISTINCT "ARRONDISSEMENT") AS arrondissements,
       COUNT(DISTINCT "ARRONDISSEMENT") AS nb_arr
FROM arbres_brut
GROUP BY "IDEMPLACEMENT"
HAVING COUNT(DISTINCT "ARRONDISSEMENT") > 1
ORDER BY nb_arr DESC
LIMIT 10;


-- =======================================================================
-- ESPACES VERTS
-- =======================================================================

-- DF4 : nsq_espace_vert -> nom_ev, categorie, type_ev, ...
SELECT "Identifiant espace vert",
       COUNT(DISTINCT "Nom de l'espace vert") AS nb_nom,
       COUNT(DISTINCT "Catégorie") AS nb_cat,
       COUNT(DISTINCT "Typologie d'espace vert") AS nb_type,
       COUNT(DISTINCT "Code postal") AS nb_cp,
       COUNT(DISTINCT "IDA3D_ENB") AS nb_ida3d
FROM ev_brut
WHERE "Identifiant espace vert" IS NOT NULL
  AND "Identifiant espace vert" <> ''
GROUP BY "Identifiant espace vert"
HAVING COUNT(DISTINCT "Nom de l'espace vert") > 1
    OR COUNT(DISTINCT "Catégorie") > 1
    OR COUNT(DISTINCT "Typologie d'espace vert") > 1
    OR COUNT(DISTINCT "Code postal") > 1
    OR COUNT(DISTINCT "IDA3D_ENB") > 1;

-- DF5 : ida3d_enb -> annee_ouverture, nb_entites, ouvert_ferme, ...
-- on exclut '0' et 'JDE' qui sont des valeurs sentinelles
SELECT "IDA3D_ENB",
       COUNT(DISTINCT "Année de l'ouverture") AS nb_ouv,
       COUNT(DISTINCT "Nombre d'entités") AS nb_ent,
       COUNT(DISTINCT "Ouverture 24h_24h") AS nb_of
FROM ev_brut
WHERE "IDA3D_ENB" <> '' AND "IDA3D_ENB" <> '0' AND "IDA3D_ENB" <> 'JDE'
GROUP BY "IDA3D_ENB"
HAVING COUNT(DISTINCT "Année de l'ouverture") > 1
    OR COUNT(DISTINCT "Nombre d'entités") > 1
    OR COUNT(DISTINCT "Ouverture 24h_24h") > 1;

-- DF6 : id_eqpt -> id_division, competence
SELECT "ID_EQPT",
       ARRAY_AGG(DISTINCT "ID_DIVISION") AS divisions,
       ARRAY_AGG(DISTINCT "Compétence") AS competences
FROM ev_brut
WHERE "ID_EQPT" <> '' AND "ID_EQPT" <> '0'
GROUP BY "ID_EQPT"
HAVING COUNT(DISTINCT "ID_DIVISION") > 1
    OR COUNT(DISTINCT "Compétence") > 1;

-- on montre que categorie -> type_ev est faux
SELECT "Catégorie",
       ARRAY_AGG(DISTINCT "Typologie d'espace vert") AS types,
       COUNT(DISTINCT "Typologie d'espace vert") AS nb
FROM ev_brut
WHERE "Catégorie" <> '' AND "Typologie d'espace vert" <> ''
GROUP BY "Catégorie"
HAVING COUNT(DISTINCT "Typologie d'espace vert") > 1
ORDER BY nb DESC;

-- nettoyage
DROP TABLE arbres_brut;
DROP TABLE ev_brut;
