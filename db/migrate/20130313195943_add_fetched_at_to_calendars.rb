class AddFetchedAtToCalendars < ActiveRecord::Migration
  def change
    add_column :calendars, :fetched_at, :timestamp, :default => nil
  end
end
