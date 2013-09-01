class CreateCourseAliases < ActiveRecord::Migration
  def change
    create_table :course_aliases, :id => false do |t|
			t.integer :calendar_id
			t.integer :course_id
			t.string :custom_name
    end
  end
end
