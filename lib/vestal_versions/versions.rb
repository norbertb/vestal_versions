module VestalVersions
  # An extension module for the +has_many+ association with versions.
  module Versions
    # Returns all versions between (and including) the two given arguments. See documentation for
    # the +at+ extension method for what arguments are valid. If either of the given arguments is
    # invalid, an empty array is returned.
    #
    # The +between+ method preserves returns an array of version records, preserving the order
    # given by the arguments. If the +from+ value represents a version before that of the +to+
    # value, the array will be ordered from earliest to latest. The reverse is also true.
    def between(from, to)
      from_iteration, to_iteration = iteration_at(from), iteration_at(to)
      return [] if from_iteration.nil? || to_iteration.nil?

      condition = (from_iteration == to_iteration) ? to_iteration : Range.new(*[from_iteration, to_iteration].sort)
      all(
        :conditions => {:iteration => condition},
        :order => "#{table_name}.#{connection.quote_column_name('iteration')} #{(from_iteration > to_iteration) ? 'DESC' : 'ASC'}"
      )
    end

    # Returns all version records created before the version associated with the given value.
    def before(value)
      return [] if (iteration = iteration_at(value)).nil?
      all(:conditions => "#{table_name}.#{connection.quote_column_name('iteration')} < #{iteration}")
    end

    # Returns all version records created after the version associated with the given value.
    #
    # This is useful for dissociating records during use of the +reset_to!+ method.
    def after(value)
      return [] if (iteration = iteration_at(value)).nil?
      all(:conditions => "#{table_name}.#{connection.quote_column_name('iteration')} > #{iteration}")
    end

    # Returns a single version associated with the given value. The following formats are valid:
    # * A Date or Time object: When given, +to_time+ is called on the value and the last version
    #   record in the history created before (or at) that time is returned.
    # * A Numeric object: Typically a positive integer, these values correspond to version iterations
    #   and the associated version record is found by a version iteration equal to the given value
    #   rounded down to the nearest integer.
    # * A String: A string value represents a version tag and the associated version is searched
    #   for by a matching tag value. *Note:* Be careful with string representations of iterations.
    # * A Symbol: Symbols represent association class methods on the +has_many+ versions
    #   association. While all of the built-in association methods require arguments, additional
    #   extension modules can be defined using the <tt>:extend</tt> option on the +versioned+
    #   method. See the +versioned+ documentation for more information.
    # * A Version object: If a version object is passed to the +at+ method, it is simply returned
    #   untouched.
    def at(value)
      case value
        when Date, Time then last(:conditions => ["#{aliased_table_name}.created_at <= ?", value.to_time])
        when Numeric then find_by_iteration(value.floor)
        when String then find_by_tag(value)
        when Symbol then respond_to?(value) ? send(value) : nil
        when Version then value
      end
    end

    # Returns the version iteration associated with the given value. In many cases, this involves
    # simply passing the value to the +at+ method and then returning the subsequent version iteration.
    # Hoever, for Numeric values, the version iteration can be returned directly and for Date/Time
    # values, a default value of 1 is given to ensure that times prior to the first version
    # still return a valid version iteration (useful for reversion).
    def iteration_at(value)
      case value
        when Date, Time then (v = at(value)) ? v.iteration : 1
        when Numeric then value.floor
        when String, Symbol then (v = at(value)) ? v.iteration : nil
        when Version then value.iteration
      end
    end
  end
end
