class CacheController < ApplicationController
  def index
    Subject.rebuild_cache
  end
end
