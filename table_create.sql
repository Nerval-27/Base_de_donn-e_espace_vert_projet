CREATE TABLE Categorie (
  categorie TEXT PRIMARY KEY,
  type_ev TEXT NOT NULL
);

CREATE TABLE Info_Admi (
  site_villes TEXT PRIMARY KEY,
  competence TEXT
);

CREATE TABLE Info_Maintenance (
  id_atelier_horticole INTEGER PRIMARY KEY,
  id_division INTEGER
);

CREATE TABLE Geom_polygone (
  id_geom INTEGER PRIMARY KEY,
  geom_type TEXT NOT NULL CHECK (geom_type IN ('Polygon', 'MultiPolygon'))
);

CREATE TABLE Geom_mesures (
  id_geom INTEGER PRIMARY KEY REFERENCES Geom_polygone(id_geom),
  poly_area INTEGER,
  surface_totale_reelle INTEGER,
  surface_horticole INTEGER,
  surface_cloture TEXT,
  perimeter NUMERIC(15, 3)
);

CREATE TABLE Geom_coordonnee (
  id_geom INTEGER NOT NULL REFERENCES Geom_polygone(id_geom),
  ordre INTEGER NOT NULL CHECK (ordre >= 0),
  longitude NUMERIC(15, 12) NOT NULL,
  latitude NUMERIC(15, 12) NOT NULL,
  PRIMARY KEY (id_geom, ordre)
);

CREATE TABLE Historique (
  ida3d_enb TEXT PRIMARY KEY,
  annee_ouverture DATE,
  annee_renovation DATE,
  ancien_nom_ev TEXT,
  annee_changement DATE,
  nb_entites INTEGER,
  ouvert_ferme TEXT,
  url_plan TEXT,
  last_edited_user TEXT,
  last_edited_date TIMESTAMP
);

CREATE TABLE Admi_Maintenance (
  id_eqpt TEXT PRIMARY KEY,
  site_villes TEXT REFERENCES Info_Admi(site_villes),
  id_atelier_horticole INTEGER REFERENCES Info_Maintenance(id_atelier_horticole)
);

CREATE TABLE Espace_vert_ID(
  nsq_espace_vert INTEGER PRIMARY KEY,
  nom_ev TEXT,
  adresse_numero INTEGER,
  adresse_complement TEXT,
  adresse_typevoie TEXT,
  adresse_libellevoie TEXT,
  adresse_codepostal TEXT,
  geo_latitude_vert NUMERIC(15, 12),
  geo_longitude_vert NUMERIC(15, 12),
  id_eqpt TEXT REFERENCES Admi_Maintenance(id_eqpt),
  ida3d_enb TEXT REFERENCES Historique(ida3d_enb),
  id_geom INTEGER REFERENCES Geom_polygone(id_geom),
  categorie TEXT REFERENCES Categorie(categorie),
  UNIQUE (geo_latitude_vert, geo_longitude_vert)
);

CREATE TABLE Encyclopedie (
  genre TEXT NOT NULL,
  espece TEXT NOT NULL,
  libellefrancais TEXT,
  PRIMARY KEY (genre, espece)
);

CREATE TABLE Emplacement (
  idemplacement TEXT PRIMARY KEY,
  arrondissement TEXT,
  complementadresse TEXT,
  adresse TEXT
);

CREATE TABLE Arbre (
  idbase INTEGER PRIMARY KEY,
  typeemplacement TEXT,
  domanialite TEXT,
  varieteoucultivar TEXT,
  circonferenceencm INTEGER CHECK (circonferenceencm >= 0),
  hauteurenm INTEGER CHECK (hauteurenm >= 0),
  stadedeveloppement TEXT,
  remarquable TEXT NOT NULL CHECK (remarquable IN ('OUI', 'NON')),
  geo_latitude NUMERIC(15, 12) NOT NULL,
  geo_longitude NUMERIC(15, 12) NOT NULL,
  genre TEXT,
  espece TEXT,
  idemplacement TEXT,
  FOREIGN KEY (genre, espece) REFERENCES Encyclopedie(genre, espece),
  FOREIGN KEY (idemplacement) REFERENCES Emplacement(idemplacement, geo_latitude, geo_longitude),
  UNIQUE(geo_latitude, geo_longitude)
);
