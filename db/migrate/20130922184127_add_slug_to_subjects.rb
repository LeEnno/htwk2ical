class AddSlugToSubjects < ActiveRecord::Migration
  def change

    add_column :subjects, :slug, :string
  end
end
