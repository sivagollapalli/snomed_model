module SnomedModel
  class Concept < ActiveRecord::Base
    def direct_decedants
      Description.where(conceptid: Relationship.direct_decedants(id).pluck(:sourceid))
    end
  end
end