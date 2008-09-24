module Bilson
  module Railative
    module Helpers
 
 
    
      def railative_interval_to_db(railative_interval = '', options = {})
        options = {
          :prepend_negative => false
        }.merge(options)
        railative_interval = railative_interval.gsub(/\s*/, '').split(',').collect {|i| (options[:prepend_negative] ? '-' : '') + i}.join(", ")
        railative_interval
      end


      def railative_interval_to_pretty(railative_interval = '', options = {})
        options = {
          :strip_negative => false 
        }
        railative_interval = railative_interval.gsub(/\s*/, '').gsub(/\./, ' ').gsub(/\,/, ', ')
        railative_interval = railative_interval.gsub(/\-/, '') if options[:strip_negative]
        railative_interval
      end



      def mirrored_time_options(time_intervals, options = {})
        options = {
          :before_prefix => '',
          :before_suffix => '',

          :before_interval_suffix => '',
          :before_timestamp_prefix => '',
          
          :after_prefix => '',
          :after_suffix => '',
          
          :after_interval_suffix => '',
          :after_timestamp_prefix => '',
          
          :median_time => 0,
          :median_time_label => '-- At the same time --',
          :label_timestamp_format => nil,
          :interval_and_timestamp_label => false,
          :interval_and_timestamp_label_divider => ' => ',
          :value_timestamp_format => nil,
          :display_before_options => true,
          :display_median_time_option => true,
          :display_after_options => true
        }.merge(options)

        times = {
          'before' => {
            :options => time_intervals,
            :operator =>'-'
          },
          'after' => { 
            :options => [], 
            :operator => '+'

          }
        }

        times['before'][:options].reverse.each do |o|
          times['after'][:options] << o
        end

        # iterate over before and after
        times.each do |key, side|
          # iterate through all items of each side
          side[:options].collect! do |item|

            # if the item is an array, this has an overriden label
            # Example ['My overriden label!', 1.year]
            if item.is_a?(Array)
              # set the label value to the first item in this array => 'My overriden label!'
              label_override = item[0]
              # item is either a time interval or a string representation of a time interval          
              item = item[1]
              item_representation = nil
            else
              label_override = nil
              item = item
              item_representation = nil
            end

            # if the item is a String than we know that the time select values will go into the
            # database as interval representations
            if item.is_a?(String)
              # clean up the passed string time interval representation for database
              item_representation = railative_interval_to_db(item, :prepend_negative => (side[:operator] == '-'))
              # take the hardcoded interval representation and pretty it up for display
              # 1.year, 3.months, 4.days becomes 1 year, 3 months, 4 days
              item_label = railative_interval_to_pretty(item)
              # if we have a median time to work with, we can calculate an exact time relative to the median
              # in this case, this is only useful if we are displaying the time in the label
              if options[:median_time].is_a?(Time)          
                calculated_time = options[:median_time].add_railative_interval(item, :prepend_negative => (side[:operator] == '-'))
              end
            end

            # LABEL SETUP

            # if the label is overriden then set the label to the overriden value
            # ['My Overriden Label!', 1.year] => 'My Overriden Label!'
            if !label_override.blank?
              label = label_override
            else
              # start out with either the :before_prefix or :after_prefix
              label = options["#{key}_prefix".to_sym]

              # if there is no timestamp format entered or if we do want the interval and timestamp in the label
              if options[:label_timestamp_format].blank? || options[:interval_and_timestamp_label]

                # if we have an item_representation then we know the label value is already prettified
                if !item_representation.blank?
                  label = label + item_label
                else
                  # if the time interval is not hardcoded as a String and is less than one day, Rails
                  # will show a string representation in seconds rather than hours or minutes
                  # we need to make sure it shows 3 hours instead of 10800 seconds
                  # Note: This is only for one value (i.e. 1.hour rather than 1.hour, 12.minutes)
                  if item.seconds < 86400
                    label = label + case item.seconds
                      when 0..59   then "#{item.seconds} seconds"
                      when 60 then "1 minute"
                      when 61..3599   then "#{item.seconds / 60} minutes"
                      when 3600 then "1 hour"
                      when 3601..7199 then "#{item.seconds / 60} minutes"
                      when 7200..86399 then "#{item.seconds / 3600} hours"
                    end
                  else
                    # Rails will print anything over a day in pretty format by default
                    # 1.day => 1 day
                    label = label + item.inspect
                  end
                end

                # if we the time interval and timestamp are combined we need to be able 
                # to plant text in between the two values
                # Example: if you set :before_interval_suffix => 'before' you would get something like: 
                # 1 year before => 12/25/2008
                if options[:interval_and_timestamp_label]
                  label = label + options["#{key}_interval_suffix".to_sym]
                end
              end

              # if a timestamp format is entered (:rfc, :long, etc) OR we want a mixed label and 
              # the median time is a Time object
              if (!options[:label_timestamp_format].blank? || options[:interval_and_timestamp_label]) && options[:median_time].is_a?(Time)
                
                # if we want a mixed label
                if options[:interval_and_timestamp_label]
                  # option to change the divider between the interval and timestamp
                  # default is ' => '
                  label = label + options[:interval_and_timestamp_label_divider]
                  # option to add a prefix to the timestamp portion of the label
                  # Example: :before_timestamp_prefix => ' around ' might produce:
                  # 1 year => around 12/25/2008
                  label = label + options["#{key}_timestamp_prefix".to_sym]
                end

                # if we have an item_representation then a String representation of the time
                # interval was in the array
                if !item_representation.blank?
                  # we calculated the time from this string representation above
                  label = label + calculated_time.to_s(options[:label_timestamp_format])
                else
                  # calculate the time - add or subtract depending upon whether this is before or after
                  # we can also format timestamp
                  label = label + options[:median_time].send(side[:operator], item).to_s(options[:label_timestamp_format])
                end
              end

              # add a suffix to the label
              label = label + options["#{key}_suffix".to_sym]

            end


            # VALUE SETUP

            # if we have an item_representation then a String representation of the time
            # interval was in the array
            if !item_representation.blank?
              # this String representation was cleaned up for database entry above
              # values will be 1.year, 2.months, etc.
              value = item_representation
            else
              # if the median_time is a Time object...
              if options[:median_time].is_a?(Time)
                # if a specific timestamp format is entered (:rfc, :long, etc)
                if !options[:value_timestamp_format].blank?
                  value = (options[:median_time].send(side[:operator], item)).to_s(options[:value_timestamp_format])
                else
                  new_time = options[:median_time].send(side[:operator], item)
                  if side[:operator] == '-'
                    seconds_difference = options[:median_time] - new_time
                  else
                    seconds_difference = new_time - options[:median_time]
                  end
                  value = (side[:operator] == '-' ? -seconds_difference : seconds_difference).to_i
                end
              else
                value = (side[:operator] == '-' ? -item : item).to_i
                value = options[:median_time].class.to_s
              end
            end


            [label, value]        
          end
        end


        # MEDIAN TIME SETUP

        if options[:median_time].is_a?(Time) && !options[:value_timestamp_format].blank?
          median_time_option = [ options[:median_time_label], options[:median_time].to_s(options[:value_timestamp_format]) ]
        else
          median_time_option = [ options[:median_time_label], 0 ]
        end



        final_array = []
        final_array += times['before'][:options] if options[:display_before_options]
        final_array += [median_time_option] if options[:display_median_time_option]
        final_array += times['after'][:options] if options[:display_after_options]
        final_array
      end
    
    end    
  end   
end