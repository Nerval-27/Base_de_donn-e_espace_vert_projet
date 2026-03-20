
## A revoir

Espace verts

F={
nsq_espace_vert -> nom_ev , categorie , adresse_numero, adresse_typevoie adresse_libellevoie, adresse_codepostal,
geom,geo_x_y,id_eqpt,ida3d_enb

id_eqt->ida3d_enb,site_ville, id_Atelier_horticole

id_Atelier_horticole -> id_division

site_ville -> competence

ida3d_enb -> annee_ouverture, annee_renovation,ancien_nom_ev,annee_changement,nb_entites,ouvert_ferme,url_plan,last_edited_user,last_edited_date

geom -> poly_are,surface_totale_reelle,surface_cloture,perimeter

categorie -> type_ev

}

Arbres Parisiens

F={
idbase->typeemplacement,domanialite,idemplacement,genre,espèce,varieoucultivar,circonferenceencm,hauteurenm,stadedeveloppement,remarquable,geo_point_2d

idemplacement,geo_point_2d ->arrondissement,complement_adresse,adresse

genre,espèce -> libellefrancais

}
