class CreateCalendars < ActiveRecord::Migration
  def change
    create_table :calendars do |t|
      t.string :secret

      t.timestamps
    end
  end
end
