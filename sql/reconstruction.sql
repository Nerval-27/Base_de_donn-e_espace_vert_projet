-- reconstruction.sql
-- Reconstitution des donnees initiales a partir des tables decomposees
-- Jordan Lengrai, Nerval Gbaguidi

-- Arbres : on reconstitue le jeu de donnees initial par jointures
SELECT a.idbase,
       a.typeemplacement,
       a.domanialite,
       e.arrondissement,
       e.complementadresse,
       e.adresse,
       a.idemplacement,
       enc.libellefrancais,
       a.genre,
       a.espece,
       a.varieteoucultivar,
       a.circonferenceencm,
       a.hauteurenm,
       a.stadedeveloppement,
       a.remarquable,
       a.geo_latitude,
       a.geo_longitude
FROM Arbre a
LEFT JOIN Emplacement e
  ON a.idemplacement = e.idemplacement
  AND a.geo_longitude = e.geo_longitude
  AND a.geo_latitude = e.geo_latitude
LEFT JOIN Encyclopedie enc
  ON a.genre = enc.genre
  AND a.espece = enc.espece;

-- Espaces verts : on reconstitue le jeu de donnees initial par jointures
SELECT ev.nsq_espace_vert,
       ev.nom_ev,
       ev.type_ev,
       ev.categorie,
       ev.adresse_numero,
       ev.adresse_complement,
       ev.adresse_typevoie,
       ev.adresse_libellevoie,
       ev.adresse_codepostal,
       gm.poly_area,
       gm.surface_totale_reelle,
       gm.surface_horticole,
       gm.presence_cloture,
       gm.perimeter,
       h.annee_ouverture,
       h.annee_renovation,
       h.ancien_nom_ev,
       h.annee_changement_nom,
       h.nb_entites,
       h.ouvert_ferme,
       adm.id_division,
       ev.id_atelier_horticole,
       ev.ida3d_enb,
       ev.site_villes,
       ev.id_eqpt,
       adm.competence,
       h.url_plan,
       ev.geo_latitude_ev,
       ev.geo_longitude_ev,
       h.last_edited_user,
       h.last_edited_date
FROM Espace_vert ev
LEFT JOIN Admi adm ON ev.id_eqpt = adm.id_eqpt
LEFT JOIN Historique h ON ev.ida3d_enb = h.ida3d_enb
LEFT JOIN Geom_mesures gm ON ev.id_geom = gm.id_geom;
