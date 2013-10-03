class CreateSubjectCaches < ActiveRecord::Migration
  def change
    create_table :subject_caches do |t|
      t.string :key
      t.text :value

      t.timestamps
    end
  end
end
