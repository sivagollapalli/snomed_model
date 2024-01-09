module SnomedModel
  class Hirerachy < ActiveRecord::Base
    ltree :path
  end
end