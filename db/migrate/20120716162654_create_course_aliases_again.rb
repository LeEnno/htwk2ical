class CreateCourseAliasesAgain < ActiveRecord::Migration
  def change
		drop_table :course_aliases
		create_table :course_aliases do |t|
			t.integer :calendar_id
			t.integer :course_id
			t.string :custom_name
		end
	end
end
