CREATE EXTENSION IF NOT EXISTS postgis;

DROP TABLE IF EXISTS Encyclopedie CASCADE;

CREATE TABLE Encyclopedie (
  genre TEXT NOT NULL,
  espece TEXT NOT NULL,
  libellefrancais TEXT,
  PRIMARY KEY (genre, espece)
);

DROP TABLE IF EXISTS Emplacement CASCADE;

CREATE TABLE Emplacement (
  idemplacement TEXT NOT NULL,
  geo_point_2d GEOMETRY(Point, 4326) NOT NULL,
  arrondissement TEXT,
  complementadresse TEXT,
  adresse TEXT,
  PRIMARY KEY (idemplacement, geo_point_2d)
);

DROP TABLE IF EXISTS Arbre CASCADE;

CREATE TABLE Arbre (
  idbase INTEGER PRIMARY KEY,
  typeemplacement TEXT,
  domanialite TEXT,
  varieteoucultivar TEXT,
  circonferenceencm INTEGER,
  hauteurenm INTEGER,
  stadedeveloppement TEXT,
  remarquable TEXT,
  geo_point_2d GEOMETRY(Point, 4326),
  genre TEXT,
  espece TEXT,
  FOREIGN KEY (genre, espece) REFERENCES Encyclopedie (genre, espece),
  idemplacement TEXT,
  FOREIGN KEY (idemplacement, geo_point_2d) REFERENCES Emplacement (idemplacement, geo_point_2d)
);

DROP TABLE IF EXISTS Historique CASCADE;

CREATE TABLE Historique (
  ida3d_enb TEXT PRIMARY KEY,
  annee_ouverture DATE,
  annee_renovation DATE,
  ancien_nom_ev TEXT,
  annee_changement_nom DATE,
  nb_entites INTEGER,
  ouvert_ferme TEXT,
  url_plan TEXT,
  last_edited_user TEXT,
  last_edited_date TIMESTAMP
);

DROP TABLE IF EXISTS Admi CASCADE;

CREATE TABLE Admi (
  id_eqpt TEXT PRIMARY KEY,
  id_division INTEGER,
  competence TEXT
);

DROP TABLE IF EXISTS Geom_mesures CASCADE;

CREATE TABLE Geom_mesures(
  geom GEOMETRY PRIMARY KEY,
  geom_x_y GEOMETRY(Point, 4326),
  poly_area INTEGER,
  surface_totale_reelle INTEGER,
  surface_horticole INTEGER,
  presence_cloture TEXT,
  perimeter NUMERIC(15, 3)
);

DROP TABLE IF EXISTS Espace_vert CASCADE;

CREATE TABLE Espace_vert (
  nsq_espace_vert INTEGER PRIMARY KEY,
  nom_ev TEXT,
  type_ev TEXT,
  categorie TEXT,
  adresse_numero INTEGER,
  adresse_complement TEXT,
  adresse_typevoie TEXT,
  adresse_libellevoie TEXT,
  adresse_codepostal TEXT,
  site_villes TEXT,
  id_atelier_horticole INTEGER,
  ida3d_enb TEXT REFERENCES Historique (ida3d_enb),
  id_eqpt TEXT REFERENCES Admi (id_eqpt),
  geom GEOMETRY REFERENCES Geom_mesures (geom)
);
