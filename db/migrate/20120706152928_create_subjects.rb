class CreateSubjects < ActiveRecord::Migration
  def change
    create_table :subjects do |t|
      t.string :title
      t.binary :cached_schedule

      t.timestamps
    end
  end
end
