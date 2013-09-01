class AddCorrectIdToCoursesSubject < ActiveRecord::Migration
  def change
    remove_column :courses_subjects, :calendar_id
    add_column :courses_subjects, :subject_id, :integer
  end
end
