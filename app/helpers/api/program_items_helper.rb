module Api::ProgramItemsHelper
  def item_town(insee_code)
    Town.find_by_insee_code(insee_code)
  end

  def normalize_list(list)
    list.select {|v| !v.blank?}.map {|v| ALL_REFS[v] || v} if list
  end
end