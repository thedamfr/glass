module Glass
  LOCATION="location"

  # A geographic location that can be associated with a timeline item.
  #
  class Location

    class << self
      # The type of resource. This is always mirror#location.
      #
      attr_reader :kind
    end

    @@kind


    # The ID of the location.
    #
    attr_reader :id
    @id

    # The time at which this location was captured, formatted according to RFC 3339.
    #
    attr_reader :timestamp
    @timestamp

    # The latitude, in degrees.
    #
    attr_accessor :latitude
    @latitude

    # The longitude, in degrees.
    attr_accessor :longitude
    @longitude

    # The accuracy of the location fix in meters.
    #
    attr_accessor :accuracy
    @accuracy

    # The name to be displayed. This may be a business name or a user-defined place, such as "Home".
    #
    attr_accessor :displayName
    @displayName

    # The full address of the location.
    #
    attr_accessor :address
    @address



  end

end
