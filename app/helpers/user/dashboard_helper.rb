module User::DashboardHelper
  include ::ItemConcern

  def territory_label
    case current_user.territory
    when ISERE
      lbl = " dans le Département de l'Isère."
    when GRAND_LYON
      lbl = " dans le territoire de la Métropole de Lyon."
    else
      lbl = "."
    end
    lbl
  end
end
