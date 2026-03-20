## Arbres

F = {

idbase -> typeemplacement, domanialite, idemplacement,
genre, espece, varieteoucultivar,
circonferenceencm, hauteurenm,
stadedeveloppement, remarquable,
geo_latitude, geo_longitude

idemplacement ->
arrondissement, complement_adresse, adresse,

genre,espece -> libellefrancais
}

## Espaces Verts

F={
nsq_espace_vert -> nom_ev, adresse_numero,
adresse_typevoie, adresse_codepostal,
geo_latitude_vert, geo_longitude_vert,
id_eqpt, id_geom, ida3d_enb, categorie

categorie -> type_ev

ida3d_enb -> annee_ouverture, annee_renovation,
ancien_nom_ev, annee_changement,
nb_entites, ouvert_ferme, url_plan,
last_edited_user, last_edited_date

id_eqpt -> site_ville, id_Atelier_horticole

site_ville -> competence

id_Atelier_horticole -> id_division

id_geom -> geom_type, poly_area,
surface_totale_reelle,
surface_cloture, perimeter

id_geom, ordre -> longitude, latitude
}
