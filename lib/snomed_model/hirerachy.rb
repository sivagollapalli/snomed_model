module SnomedModel
  class Hirerachy < ActiveRecord::Base
    ltree :path

    scope :concept_paths, ->(conceptid) { where("path ~ ?", "*.#{conceptid}.*") }
    scope :decedants, lambda { |conceptid|
      select("subpath(path, index(path, '#{conceptid}') + 1, nlevel(path)) as subpath").concept_paths(conceptid)
    }
    scope :ancestors, lambda { |conceptid|
      select("subpath(path, 0, index(path, '#{conceptid}')) as subpath").concept_paths(conceptid)
    }
  end
end