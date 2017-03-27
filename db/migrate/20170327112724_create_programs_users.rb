class CreateProgramsUsers < ActiveRecord::Migration
  def change
    create_table :programs_users do |t|
      t.integer :program_id
      t.integer :user_id
    end
  end
end
