module Glass
  SUBSCRIPTION="subscription"

  class Subscription
    class << self
      # The type of resource. This is always mirror#subscription.
      #
      attr_accessor :kind
    end

    @@kind = MIRROR+"#"+SUBSCRIPTION

    # The ID of the subscription.
    #
    attr_accessor :id
    @id

    # The time at which this subscription was last modified, formatted according to RFC 3339.
    #
    attr_accessor :updated
    @updated

    # The collection to subscribe to. Allowed values are:
    #   timeline - Changes in the timeline including insertion, deletion, and updates.
    #   locations - Location updates.
    attr_accessor :collection
    @collection
    TIMELINE="timeline"
    LOCATIONS="locations"

    # A list of operations that should be subscribed to. An empty list indicates that all operations on the collection should be subscribed to. Allowed values are:
    #   UPDATE - The item has been updated.
    #   INSERT - A new item has been inserted.
    #   DELETE - The item has been deleted.
    attr_accessor :operation
    @operation= []

  end

end