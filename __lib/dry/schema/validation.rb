module Dry
  # TODO: This is to maintain backward-compatibility in dry-v.
  #       It should be moved over there before first release of dry-schema
  module Validation
    def self.Schema(*args, &block)
      Schema.build(*args, **opts, &block)
    end

    def self.Form(*args, **opts, &block)
      Schema.form(*args, **opts, &block)
    end

    def self.JSON(*args, **opts, &block)
      Schema.json(*args, **opts, &block)
    end
  end
end
