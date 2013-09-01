class CreateJoinTables < ActiveRecord::Migration
	def change
		create_table :courses_subjects, :id => false do |t|
			t.integer :calendar_id
			t.integer :course_id
		end

		create_table :calendars_subjects, :id => false do |t|
			t.integer :calendar_id
			t.integer :subject_id
		end
  end
end
