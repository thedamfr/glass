module Glass
  TIMELINE_ITEM="timelineItem"

  # Each item in the user's timeline is represented as a TimelineItem JSON structure, described below.
  #
  class TimelineItem


    class << self

      # The type of resource. This is always mirror#timelineItem.
      #
      attr_reader :kind


      def get(client, id)
        client.exexute(
            :api_method => client.timeline.get,
            :parameters => {:id => id}
        )
      end

      # Retrieves a list of timeline items for the authenticated user.
      # @param [string] bundleId
      #   If true, tombstone records for deleted items will be returned.
      # @param [boolean] includeDeleted
      #   If true, tombstone records for deleted items will be returned.
      # @param [integer] maxResults
      #   The maximum number of items to include in the response, used for paging.
      # @param [string] orderBy
      #   Controls the order in which timeline items are returned.
      #   Acceptable values are:
      #     "displayTime": Results will be ordered by displayTime (default). This is the same ordering as is used in the timeline on the device.
      #     "writeTime": Results will be ordered by the time at which they were last written to the data store.
      # @param [string] pageToken
      #   Token for the page of results to return.
      # @param [boolean] pinnedOnly
      #   If true, only pinned items will be returned.
      # @param [string] sourceItemId
      #   If provided, only items with the given sourceItemId will be returned.
      #
      def list(client, params={})
        result=[]
        parameters = params
        api_result = client.execute(
            :api_method => mirror.timeline.list,
            :parameters => parameters)
        if api_result.success?
          data = api_result.data
          unless data.items.empty?
            result << data.items
            parameters[:pageToken]= data.next_page_token
            result << list(client, parameters)
          end
        else
          puts "An error occurred: #{result.data['error']['message']}"
        end
        result
      end


    end

    # The ID of the timeline item. This is unique within a user's timeline.
    #
    attr_accessor :id

    # A URL that can be used to retrieve this item.
    #
    attr_accessor :selfLink

    # The time at which this item was created, formatted according to RFC 3339.
    #
    attr_reader :created

    # The time at which this item was last modified, formatted according to RFC 3339.
    #
    attr_accessor :updated

    # The time that should be displayed when this item is viewed in the timeline,
    # formatted according to RFC 3339. This user's timeline is sorted chronologically on display time,
    # so this will also determine where the item is displayed in the timeline.
    # If not set by the service, the display time defaults to the updated time.
    #
    attr_reader :displayTime

    # When true, indicates this item is deleted, and only the ID property is set.
    #
    attr_accessor :isDeleted

    # ETag for this item.
    #
    attr_reader :etag

    # The user or group that created this item.
    #
    attr_accessor :creator

    # If this item was generated as a reply to another item,
    # this field will be set to the ID of the item being replied to.
    # This can be used to attach a reply to the appropriate conversation or post.
    #
    attr_accessor :inReplyTo

    # Text content of this item.
    #
    attr_accessor :text

    # The speakable version of the content of this item.
    # Along with the READ_ALOUD menu item,
    # use this field to provide text that would be clearer when read aloud,
    # or to provide extended information to what is displayed visually on Glass.
    #
    attr_accessor :speakableText

    # A list of media attachments associated with this item.
    #
    attr_accessor :attachments

    # The geographic location associated with this item.
    #
    attr_accessor :location

    # A list of menu items that will be presented to the user when this item is selected in the timeline.
    #
    attr_accessor :menuItems

    # Controls how notifications for this item are presented on the device.
    # If this is missing, no notification will be generated.
    #
    attr_accessor :notification


    # When true, indicates this item is pinned,
    # which means it's grouped alongside "active" items like navigation and hangouts,
    # on the opposite side of the home screen from historical (non-pinned) timeline items.
    #
    attr_accessor :isPinned

    # The title of this item.
    #
    attr_accessor :title

    # HTML content for this item. If both text and html are provided for an item,
    # the html will be rendered in the timeline.
    #
    attr_accessor :html

    # The bundle ID for this item. Services can specify a bundleId to group many items together.
    # They appear under a single top-level item on the device.
    #
    attr_accessor :bundleId

    # Additional pages of HTML content associated with this item.
    # If this field is specified, the item will be displayed as a bundle,
    # with the html field as the cover. It is an error to specify this field without specifying the html field.
    #
    attr_accessor :htmlPages

    # Opaque string you can use to map a timeline item to data in your own service.
    #
    attr_accessor :sourceItemId

    # A canonical URL pointing to the canonical/high quality version of the data represented by the timeline item.
    #
    attr_accessor :canonicalUrl

    # Whether this item is a bundle cover.
    #
    # If an item is marked as a bundle cover,
    # it will be the entry point to the bundle of items that have the same bundleId as that item.
    # It will be shown only on the main timeline — not within the opened bundle.
    #
    # On the main timeline, items that are shown are:
    #   Items that have isBundleCover set to true
    #   Items that do not have a bundleId
    #
    # Items that do not have a bundleId
    #   In a bundle sub-timeline, items that are shown are:
    #   Items that have the bundleId in question AND isBundleCover set to false

    attr_accessor :isBundleCover

    # For pinned items, this determines the order in which the item is displayed in the timeline,
    # with a higher score appearing closer to the clock. Note: setting this field is currently not supported.
    #
    attr_accessor :pinScore

    # A list of contacts or groups that this item has been shared with.
    #
    attr_accessor :recipients

    @@kind= MIRROR+"#"+TIMELINE_ITEM
    @id
    @selfLink
    @created
    @updated
    @displayTime
    @isDeleted
    @etag
    @creator #Todo User and Group
    @inReplyTo
    @text
    @speakableText
    @attachments=[]
    @location
    @menuItems=[]
    @notification
    @isPinned
    @title
    @html
    @bundleId
    @htmlPages[]
    @sourceItemId
    @canonicalUrl
    @isBundleCover
    @pinScore
    @recipients=[]

    # Represents media content, such as a photo, that can be attached to a timeline item.
    #
    class Attachment

      # The ID of the attachment.
      #
      attr_accessor :id

      # The MIME type of the attachment.
      #
      attr_accessor :contentType

      # The URL for the content.
      #
      attr_accessor :contentUrl

      # Indicates that the contentUrl is not available because the attachment content is still being processed.
      # If the caller wishes to retrieve the content, it should try again later.
      #
      attr_accessor :isProcessingContent

      @id
      @contentType
      @contentUrl
      @isProcessingContent
    end

    class Notification

      # Describes how important the notification is. Allowed values are:
      #   DEFAULT - Notifications of default importance. A chime will be played to alert contacts.
      attr_accessor :level

      # The time at which the notification should be delivered.
      #
      attr_accessor :deliveryTime

      @level
      @deliveryTime
    end

    class MenuItems

      # The ID for this menu item. This is generated by the application and is treated as an opaque token.
      #
      attr_accessor :id

      # Controls the behavior when the user picks the menu option. Allowed values are:
      # CUSTOM - Custom action set by the service. When the user selects this menuItem,
      # the API triggers a notification to your callbackUrl with the userActions.type set to CUSTOM and the userActions.payload set to the ID of this menu item.
      # This is the default value.
      # Built-in actions:
      #   REPLY - Initiate a reply to the timeline item using the voice recording UI. The creator attribute must be set in the timeline item for this menu to be available.
      #   REPLY_ALL - Same behavior as REPLY. The original timeline item's recipients will be added to the reply item.
      #   DELETE - Delete the timeline item.
      #   SHARE - Share the timeline item with the available contacts.
      #   READ_ALOUD - Read the timeline item's speakableText aloud; if this field is not set, read the text field; if none of those fields are set, this menu item is ignored.
      #   VOICE_CALL - Initiate a phone call using the timeline item's creator.phone_number attribute as recipient.
      #   NAVIGATE - Navigate to the timeline item's location.
      #   TOGGLE_PINNED - Toggle the isPinned state of the timeline item.
      #
      attr_accessor :actions

      # For CUSTOM items, a list of values controlling the appearance of the menu item in each of its states.
      # A value for the DEFAULT state must be provided.
      # If the PENDING or CONFIRMED states are missing, they will not be shown.
      #
      attr_accessor :values

      # If set to true on a CUSTOM menu item, that item will be removed from the menu after it is selected.
      #
      attr_accessor :removeWhenSelected

      @id
      @actions
      @values=[]
      @removeWhenSelected

      REPLY="REPLY"
      REPLY_ALL="REPLY_ALL"
      DELETE="DELETE"
      SHARE="SHARE"
      READ_ALOUD="READ_ALOUD"
      VOICE_CALL="VOICE_CALL"
      NAVIGATE="NAVIGATE"
      TOGGLE_PINNED="TOOGLE_PINNED"
      CUSTOM="CUSTOM"

      class Values

        # The name to display for the menu item.
        #
        attr_accessor :displayName

        # URL of an icon to display with the menu item.
        #
        attr_accessor :iconURL

        # The state that this value applies to. Allowed values are:
        #   DEFAULT - Default value shown when displayed in the menuItems list.
        #   PENDING - Value shown when the menuItem has been selected by the user but can still be cancelled.
        #   CONFIRMED - Value shown when the menuItem has been selected by the user and can no longer be cancelled.
        attr_accessor :state

        @displayName
        @iconURL
        @state

        DEFAULT="DEFAULT"
        PENDING="PENDING"
        CONFIRMED="CONFIRMED"
      end
    end

  end

end
