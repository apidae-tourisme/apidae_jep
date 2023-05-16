class AddOnboardingToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :onboarding, :boolean
  end
end
