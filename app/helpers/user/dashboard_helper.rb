module User::DashboardHelper
  def territory_label
    case current_user.territory
    when ISERE
      lbl = " dans le Département de l'Isère."
    when GRAND_LYON
      lbl = " dans le territoire de la Métropole de Lyon."
    when SAUMUR
      lbl = " dans la Communauté d'agglomération Saumur Val de Loire."
    when DLVA
      lbl = " dans l'Agglomération Durance Luberon Verdon."
    else
      lbl = "."
    end
    lbl
  end
end
