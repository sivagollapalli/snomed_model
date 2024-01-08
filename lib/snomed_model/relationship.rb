module SnomedModel
  class Relationship < ActiveRecord::Base
    IS_A_RELATION = "116680003".freeze

    scope :active, -> { where(active: "1") }
    scope :direct_decedants, lambda { |conceptid|
      where(typeid: IS_A_RELATION, destinationid: conceptid)
    }
    scope :direct_ancestors, lambda { |conceptid|
      where(typeid: IS_A_RELATION, sourceid: conceptid)
    }
  end
end