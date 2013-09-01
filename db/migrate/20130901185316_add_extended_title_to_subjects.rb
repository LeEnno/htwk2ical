class AddExtendedTitleToSubjects < ActiveRecord::Migration
  def change
    add_column :subjects, :extended_title, :string
  end
end
