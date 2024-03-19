module SnomedModel
  class Hirerachy < ActiveRecord::Base
    ltree :path

    scope :concept_paths, ->(conceptid) { where("path ~ ?", "*.#{conceptid}.*") }
    scope :descendant, lambda { |conceptid|
      select("subpath(path, index(path, '#{conceptid}'), nlevel(path)) as subpath").concept_paths(conceptid)
    }
    scope :ancestors, lambda { |conceptid|
      select("subpath(path, 0, index(path, '#{conceptid}')) as subpath").concept_paths(conceptid)
    }
  end
end