module VestalVersions
  # Simply adds a flag to determine whether a model class if versioned.
  module Versioned
    extend ActiveSupport::Concern

    # Overrides the +versioned+ method to first define the +versioned?+ class method before
    # deferring to the original +versioned+.
    module ClassMethods
      def versioned(*args)
        super(*args)

        class << self
          def versioned?
            true
          end
        end
      end

      # For all ActiveRecord::Base models that do not call the +versioned+ method, the +versioned?+
      # method will return false.
      def versioned?
        false
      end
    end

    module InstanceMethods
      def has_previous_version?
        version > versions.minimum(:iteration) - 1
      end

      def has_next_version?
        version < versions.maximum(:iteration)
      end

      def lastest_version?
        ! has_next_version?
      end
    end
  end
end
