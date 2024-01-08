module SnomedModel
  class Description < ActiveRecord::Base
    FSN = "900000000000003001".freeze
    SYNONYM = "900000000000013009".freeze
    PREFERRED = "900000000000548007".freeze

    scope :active, -> { where(active: "1") }
    scope :fsns, -> { where(typeid: FSN) }
    scope :synonyms, -> { where(typeid: SYNONYM) }
    scope :preferred, -> { where(typeid: PREFERRED) }
  end
end