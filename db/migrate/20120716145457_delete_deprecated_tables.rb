class DeleteDeprecatedTables < ActiveRecord::Migration
	def self.table_exists?(name)
		ActiveRecord::Base.connection.tables.include?(name)
	end

	def change
		drop_table :subjects_courses if self.table_exists?("subjects_courses")
		drop_table :calendars_courses if self.table_exists?("calendars_courses")
	end
end
