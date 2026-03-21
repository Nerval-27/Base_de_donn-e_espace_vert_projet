Arbres F = {
  idbase -> typeemplacement, domanialite, idemplacement,
            genre, espece, varieteoucultivar,
            circonferenceencm, hauteurenm,
            stadedeveloppement, remarquable,
            geo_point_2d

  idemplacement, geo_point_2d  ->
            arrondissement, complementadresse, adresse

  genre, espece -> libellefrancais
}

Espaces Verts F = {

  nsq_espace_vert -> nom_ev, adresse_numero,
                     adresse_complement, adresse_typevoie,
                     adresse_libellevoie, adresse_codepostal,
                     site_villes, id_atelier_horticole,
                     id_eqpt, ida3d_enb, categorie, type_ev,
                     geom,geom_x_y


  ida3d_enb -> annee_ouverture, annee_renovation,
               ancien_nom_ev, annee_changement_nom,
               nb_entites, ouvert_ferme, url_plan,
               last_edited_user, last_edited_date

  id_eqpt -> id_division, competence
  geom,geom_x_y -> poly_area,surface_totale_reelle,surface_horticole,presence_cloture,perimeter,nb_entites
}
