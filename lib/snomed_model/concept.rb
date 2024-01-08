module SnomedModel
  class Concept < ActiveRecord::Base
    scope :active, -> { where(active: "1") }

    def direct_decedants
      Description
        .active
        .where(conceptid: Relationship.active.direct_decedants(id).pluck(:sourceid))
    end

    def direct_ancestors
      Description
        .active
        .where(conceptid: Relationship.active.direct_ancestors(id).pluck(:destinationid))
    end

    def detail
      Description.active.detail(id)
    end
  end
end