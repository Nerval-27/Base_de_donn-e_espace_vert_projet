-- table_create.sql
-- Jordan Lengrai, Nerval Gbaguidi

DROP TABLE IF EXISTS Geom_coordonnee CASCADE;
DROP TABLE IF EXISTS Geom_mesures CASCADE;
DROP TABLE IF EXISTS Espace_vert CASCADE;
DROP TABLE IF EXISTS Historique CASCADE;
DROP TABLE IF EXISTS Admi CASCADE;
DROP TABLE IF EXISTS Arbre CASCADE;
DROP TABLE IF EXISTS Emplacement CASCADE;
DROP TABLE IF EXISTS Encyclopedie CASCADE;

-- Encyclopedie
-- cle candidate : (genre, espece)
-- DF : (genre, espece) -> libellefrancais
CREATE TABLE Encyclopedie (
  genre TEXT NOT NULL,
  espece TEXT NOT NULL,
  libellefrancais TEXT,
  PRIMARY KEY (genre, espece)
);

-- Emplacement
-- cle candidate : (idemplacement, geo_longitude, geo_latitude)
-- DF : (idemplacement, geo_longitude, geo_latitude) -> arrondissement, complementadresse, adresse
CREATE TABLE Emplacement (
  idemplacement TEXT NOT NULL,
  geo_longitude DOUBLE PRECISION NOT NULL,
  geo_latitude DOUBLE PRECISION NOT NULL,
  arrondissement TEXT NOT NULL,
  complementadresse TEXT,
  adresse TEXT,
  PRIMARY KEY (idemplacement, geo_longitude, geo_latitude)
);

-- Arbre
-- cle candidate : idbase
-- DF : idbase -> tous les attributs
CREATE TABLE Arbre (
  idbase INTEGER NOT NULL,
  typeemplacement TEXT NOT NULL,
  domanialite TEXT,
  idemplacement TEXT,
  geo_longitude DOUBLE PRECISION,
  geo_latitude DOUBLE PRECISION,
  genre TEXT,
  espece TEXT,
  varieteoucultivar TEXT,
  circonferenceencm INTEGER CHECK (circonferenceencm >= 0),
  hauteurenm INTEGER CHECK (hauteurenm >= 0),
  stadedeveloppement TEXT CHECK (stadedeveloppement IN ('Adulte', 'Jeune (arbre)', 'Mature')),
  remarquable TEXT CHECK (remarquable IN ('OUI', 'NON')),
  PRIMARY KEY (idbase),
  FOREIGN KEY (genre, espece) REFERENCES Encyclopedie (genre, espece)
    ON DELETE SET NULL DEFERRABLE INITIALLY DEFERRED,
  FOREIGN KEY (idemplacement, geo_longitude, geo_latitude)
    REFERENCES Emplacement (idemplacement, geo_longitude, geo_latitude)
    ON DELETE SET NULL DEFERRABLE INITIALLY DEFERRED
);

-- Admi
-- cle candidate : id_eqpt
-- DF : id_eqpt -> id_division, competence
CREATE TABLE Admi (
  id_eqpt TEXT NOT NULL,
  id_division INTEGER,
  competence TEXT,
  PRIMARY KEY (id_eqpt)
);

-- Historique
-- cle candidate : ida3d_enb
-- DF : ida3d_enb -> annee_ouverture, annee_renovation, ancien_nom_ev,
--      annee_changement_nom, nb_entites, ouvert_ferme, url_plan,
--      last_edited_user, last_edited_date
CREATE TABLE Historique (
  ida3d_enb TEXT NOT NULL,
  annee_ouverture INTEGER,
  annee_renovation INTEGER,
  ancien_nom_ev TEXT,
  annee_changement_nom INTEGER,
  nb_entites INTEGER CHECK (nb_entites >= 0),
  ouvert_ferme TEXT,
  url_plan TEXT,
  last_edited_user TEXT,
  last_edited_date TIMESTAMP,
  PRIMARY KEY (ida3d_enb)
);

-- Geom_mesures
-- cle candidate : id_geom (SERIAL justifie par atomisation de geom)
-- DF : id_geom -> geom_type, poly_area, surface_totale_reelle,
--      surface_horticole, presence_cloture, perimeter
CREATE TABLE Geom_mesures (
  id_geom SERIAL NOT NULL,
  geom_type TEXT CHECK (geom_type IN ('Polygon', 'MultiPolygon')),
  poly_area INTEGER CHECK (poly_area >= 0),
  surface_totale_reelle INTEGER CHECK (surface_totale_reelle >= 0),
  surface_horticole INTEGER CHECK (surface_horticole >= 0),
  presence_cloture TEXT,
  perimeter NUMERIC(15, 3) CHECK (perimeter >= 0),
  PRIMARY KEY (id_geom)
);

-- Espace_vert
-- cle candidate : nsq_espace_vert
-- DF : nsq_espace_vert -> tous les attributs directs
CREATE TABLE Espace_vert (
  nsq_espace_vert INTEGER NOT NULL,
  nom_ev TEXT,
  type_ev TEXT,
  categorie TEXT,
  adresse_numero INTEGER,
  adresse_complement TEXT,
  adresse_typevoie TEXT,
  adresse_libellevoie TEXT,
  adresse_codepostal TEXT,
  geo_latitude_ev DOUBLE PRECISION,
  geo_longitude_ev DOUBLE PRECISION,
  site_villes TEXT,
  id_atelier_horticole INTEGER,
  id_eqpt TEXT,
  ida3d_enb TEXT,
  id_geom INTEGER,
  PRIMARY KEY (nsq_espace_vert),
  FOREIGN KEY (id_eqpt) REFERENCES Admi (id_eqpt)
    ON DELETE SET NULL DEFERRABLE INITIALLY DEFERRED,
  FOREIGN KEY (ida3d_enb) REFERENCES Historique (ida3d_enb)
    ON DELETE SET NULL DEFERRABLE INITIALLY DEFERRED,
  FOREIGN KEY (id_geom) REFERENCES Geom_mesures (id_geom)
    ON DELETE SET NULL DEFERRABLE INITIALLY DEFERRED
);

-- Geom_coordonnee
-- cle candidate : (id_geom, ordre)
-- DF : (id_geom, ordre) -> longitude, latitude
CREATE TABLE Geom_coordonnee (
  id_geom INTEGER NOT NULL,
  ordre INTEGER NOT NULL CHECK (ordre >= 0),
  longitude NUMERIC(15, 12) NOT NULL,
  latitude NUMERIC(15, 12) NOT NULL,
  PRIMARY KEY (id_geom, ordre),
  FOREIGN KEY (id_geom) REFERENCES Geom_mesures (id_geom) ON DELETE CASCADE
);
