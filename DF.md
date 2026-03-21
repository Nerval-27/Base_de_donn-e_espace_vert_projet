Arbres F = {
idbase -> typeemplacement, domanialite, idemplacement,
genre, espece, varieteoucultivar,
circonferenceencm, hauteurenm,
stadedeveloppement, remarquable,
geo_longitude,geo_latitude

idemplacement,geo_longitude,geo_latitude->
arrondissement, complementadresse, adresse

genre,espece -> libellefrancais
}

Espaces Verts F = {

nsq_espace_vert -> nom_ev, adresse_numero,
adresse_complement, adresse_typevoie,
adresse_libellevoie, adresse_codepostal,
geo_latitude_ev, geo_longitude_ev,
site_villes, id_atelier_horticole,
id_eqpt, ida3d_enb,
categorie, type_ev,
id_geom

ida3d_enb -> annee_ouverture, annee_renovation,
ancien_nom_ev, annee_changement_nom,
nb_entites, ouvert_ferme,
url_plan, last_edited_user,
last_edited_date

id_eqpt -> id_division, competence

id_geom -> geom_type, poly_area,
surface_totale_reelle, surface_horticole,
presence_cloture, perimeter

(id_geom, ordre) -> longitude, latitude
}
