Railative for Rails >= 2.1 (Rails Plugin)
=========================================

*NOTE:  This documentation will be best understood if read in order.*

This library (Rails Plugin) will aid in the entry, storage, display and update of relative time values.  A specific use case for this functionality would be for setting up a task management system with task due dates that can be dependent upon other task due dates.

The central idea behind this library is to store time intervals as String interval representations (though it has a select field helper that can produce intervals in various formats).  Therefore relative intervals would be stored in the database as '1.year', '-2.months', '4.days, 12.hours', etc.  In doing so, future computations are precise and the natural language intervals stay intact for future updates.


`Time.add_railative_interval`
----------------------------

The library makes it easy to work with these String representations by extending the Time object with the "add_railative_interval" method.  This method computes a new relative Time when passed a String interval representation.  Time.now.add_railative_interval('5.years') would calculate a time object with a year of 2013.  You can also pass negative values such as Time.now.add_railative_interval('-3.days').  You can even pass a list of intervals such as...Time.now.add_railative_interval('2.hours, 30.minutes').  The method will convert the string to an array and add each interval one by one.

Here are a few examples from the console...

    >> t = Time.now
    => Wed Aug 20 16:53:10 -0400 2008

    >> t.add_railative_interval('1.year')
    => Thu Aug 20 16:53:10 -0400 2009

    >> t.add_railative_interval('-1.year')
    => Mon Aug 20 16:53:10 -0400 2007

    >> t.add_railative_interval('2.years, 14.minutes')
    => Fri Aug 20 17:07:10 -0400 2010

    >> t.add_railative_interval('-3.months, -11.minutes')
    => Tue May 20 16:42:10 -0400 2008

    >> t.add_railative_interval('-3.months, -11.minutes').add_railative_interval('3.months, 11.minutes')
    => Wed Aug 20 16:53:10 -0400 2008

So this allows you to make use of an interval representation once it already exists, but how do we make it easy to choose an interval in the first place?  One way is to create a select dropdown with various choices of time intervals before and after a depended upon time (we'll call this the median time).  


mirrored_time_options helper
----------------------------

Railative includes a helper, "mirrored_time_options", to produce this select field and to do it "relatively" easily.  The mirrored_time_options helper takes a list of time intervals, computes those intervals off of a supplied median time, mirrors the intervals to before and after time intervals and formats the values and labels.  

    mirrored_time_options(time_intervals = [], options = {})

The helper first takes an array of time intervals.  The recommended format for these intervals would be as a String value ('1.year' rather than 1.year), though other options are discussed below.  A suffix is added to both the "before" and "after" intervals.  The below examples, taken in order, will provide a good overview of the usage of this helper.


### Example 1: String Time Interval ###

This example is quite simple in that there are no relative time computations.  More advanced examples will follow.

    f.select :relative_time, mirrored_time_options(['1.year', '5.days', '1.day', '3.hours', '1.hour'], :median_time => Time.now, :before_suffix => ' before', :after_suffix => ' after')

produces:
    <option value="-1.year">1 year before</option>
    <option value="-5.days">5 days before</option>
    <option value="-1.day">1 day before</option>
    <option value="-3.hours">3 hours before</option>
    <option value="-1.hour">1 hour before</option>
    <option value="0" selected="selected">-- At the same time --</option>
    <option value="1.hour">1 hour after</option>
    <option value="3.hours">3 hours after</option>
    <option value="1.day">1 day after</option>
    <option value="5.days">5 days after</option>
    <option value="1.year">1 year after</option>

  ***Note:** The helper actually only produces an array.  When supplied to the select helper it will produce the options HTML*


  
Example 2: String Time Interval with timestamp label
=====================================================
The helper allows great flexibility in label display.  By simply including the :label_timestamp_format option, you can specify a Time.to_s format that will automatically display the computed timestamp rather than a time interval.  The example below uses the :db format, but you could specify :long, :short, rfc822 or even your own custom format.

=f.select :relative_time, mirrored_time_options(['1.year', '5.days', '1.day', '3.hours', '1.hour'], :median_time => Time.now, :label_timestamp_format => :db)

produces:
  <option value="-1.year">2007-08-20 14:40:23</option>
  <option value="-5.days">2008-08-15 14:40:23</option>
  <option value="-1.day">2008-08-19 14:40:23</option>
  <option value="-3.hours">2008-08-20 11:40:23</option>
  <option value="-1.hour">2008-08-20 13:40:23</option>
  <option value="0" selected="selected">-- At the same time --</option>
  <option value="1.hour">2008-08-20 15:40:23</option>
  <option value="3.hours">2008-08-20 17:40:23</option>
  <option value="1.day">2008-08-21 14:40:23</option>
  <option value="5.days">2008-08-25 14:40:23</option>
  <option value="1.year">2009-08-20 14:40:23</option>  


Example 3: String Time Interval with interval and timestamp label
=====================================================  
Taking this a step further, you can also include the :interval_and_timestamp_label to automatically display both the interval and timestamp relative labels.

=f.select :relative_time, mirrored_time_options(['1.year', '5.days', '1.day', '3.hours', '1.hour'], :median_time => Time.now, :label_timestamp_format => :db, :interval_and_timestamp_label => true)

produces:
  <option value="-1.year">1 year => 2007-08-20 15:37:27</option>
  <option value="-5.days">5 days => 2008-08-15 15:37:27</option>
  <option value="-1.day">1 day => 2008-08-19 15:37:27</option>
  <option value="-3.hours">3 hours => 2008-08-20 12:37:27</option>
  <option value="-1.hour">1 hour => 2008-08-20 14:37:27</option>
  <option value="0" selected="selected">-- At the same time --</option>
  <option value="1.hour">1 hour => 2008-08-20 16:37:27</option>
  <option value="3.hours">3 hours => 2008-08-20 18:37:27</option>
  <option value="1.day">1 day => 2008-08-21 15:37:27</option>
  <option value="5.days">5 days => 2008-08-25 15:37:27</option>
  <option value="1.year">1 year => 2009-08-20 15:37:27</option>  

There are also a number of options to add a prefix and suffix in various parts of this label, as well as specifying an alternate divider symbol between the interval and timestamp.


Example 4: Overriding specific option labels
==========================================
You may have the need to override the label for a specific option.  This is done by simply making that option an array in the format of [label, interval]

f.select :relative_time, mirrored_time_options(['1.year', ['My Overridden Example!', '5.days'], '1.day', '3.hours', '1.hour, 11.minutes'], :median_time => Time.now, :label_timestamp_format => :db)

produces:
  <option value="-1.year">2007-08-20 15:51:05</option>
  <option value="-5.days">My Overridden Example!</option>
  <option value="-1.day">2008-08-19 15:51:05</option>
  <option value="-3.hours">2008-08-20 12:51:05</option>
  <option value="-1.hour, -11.minutes">2008-08-20 14:40:05</option>
  <option value="0" selected="selected">-- At the same time --</option>
  <option value="1.hour, 11.minutes">2008-08-20 17:02:05</option>
  <option value="3.hours">2008-08-20 18:51:05</option>
  <option value="1.day">2008-08-21 15:51:05</option>
  <option value="5.days">My Overridden Example!</option>
  <option value="1.year">2009-08-20 15:51:05</option>
  
Also note that in this example we have specified a two part interval ("1.hour, 11.minutes").  The helper will factor in both values when computing the label's timestamp.
  
  
Example 5: Relative Seconds Example with median time
====================================================

While the central idea behind this library is to store interval representations, this may not be the way you are storing values in your application.  Therefore, there are a number of options to format the value produced for each option.  In the example below we have removed the quotes around each interval value.  As such, the methods (1.year, 5.days, etc) will compute a differential of seconds from the median time.  It is important to note that the helper will compute precise seconds for years and months relative to the median time.  While this is a neat trick, it is not suggested that it is used if the time is to be dependent on another time, as the seconds will be incorrect as soon as the depended upon time is updated in the future.

f.select :relative_time, mirrored_time_options([1.year, 5.days, 1.day, ['Overriden Label', 3.hours], 1.hour], :median_time => Time.now, :before_suffix => ' before', :after_suffix => ' after')

produces:
  <option value="-31622400">1 year before</option>
  <option value="-432000">5 days before</option>
  <option value="-86400">1 day before</option>
  <option value="-10800">Overriden Label</option>
  <option value="-3600">1 hour before</option>
  <option value="0" selected="selected">-- At the same time --</option>
  <option value="3600">1 hour after</option>
  <option value="10800">Overriden Label</option>
  <option value="86400">1 day after</option>
  <option value="432000">5 days after</option>
  <option value="31536000">1 year after</option>

Example 6: Relative Seconds Example without knowing the depended upon time
==========================================================================  

You might have the need to create a dependent task without actually knowing the time that you are depending on.  This is easily achieved by not including the :median_time option.  We can't because we don't know what it is.  This will actually return nearly the same options as the last example, except it will need to use estimates for years and months.  Rails assumes 30 days in a month and 365 days in a year.  This method may be sufficient if your application does not require precise year and month intervals and the ability to retrieve time intervals the same way they were initially entered.

f.select :relative_time, mirrored_time_options([1.year, 5.days, 1.day, ['Overriden Label', 3.hours], 1.hour], :before_suffix => ' before', :after_suffix => ' after')

produces:
  <option value="-31557600">1 year before</option>
  <option value="-432000">5 days before</option>
  <option value="-86400">1 day before</option>
  <option value="-10800">Overriden Label</option>
  <option value="-3600">1 hour before</option>
  <option value="0" selected="selected">-- At the same time --</option>
  <option value="3600">1 hour after</option>
  <option value="10800">Overriden Label</option>
  <option value="86400">1 day after</option>
  <option value="432000">5 days after</option>
  <option value="31557600">1 year after</option>


Example 7: Timestamp Example
============================
The helper can also set the value of the options to a specified timestamp representation rather than a railative string or seconds.  Simply supply the :value_timestamp_format option with a to_s format.  The same formats (:db, :rfc822, :short, :long, custom formats) available to the label are also available for the value portion of the option.  Please note that the array of time intervals supplied to the helper must NOT be string representations to use this functionality.  Also, of course, a median time object must be supplied.

f.select :relative_seconds, mirrored_time_options([1.year, 5.days, 1.day, ['Overriden Label', 3.hours], 1.hour], :before_suffix => ' before', :after_suffix => ' after', :value_timestamp_format => :db, :median_time => Time.now)

produces:
  <option value="2007-08-20 16:00:23">1 year before</option>
  <option value="2008-08-15 16:00:23">5 days before</option>
  <option value="2008-08-19 16:00:23">1 day before</option>
  <option value="2008-08-20 13:00:23">Overriden Label</option>
  <option value="2008-08-20 15:00:23">1 hour before</option>
  <option value="2008-08-20 16:00:23">-- At the same time --</option>
  <option value="2008-08-20 17:00:23">1 hour after</option>
  <option value="2008-08-20 19:00:23">Overriden Label</option>
  <option value="2008-08-21 16:00:23">1 day after</option>
  <option value="2008-08-25 16:00:23">5 days after</option>
  <option value="2009-08-20 16:00:23">1 year after</option>


OPTIONS for mirrored_time_options helper
========================================

You can achieve almost any relative timestamp dropdown by specifying additional options.

:median_time - This is the Time or value that all of the options are relative to. The default is 0 to accommodate instances in which the depended upon timestamp is not available.  A number of options will require that a Time object is supplied to as a median time.
  Examples
    :median_time => @task.due_at
    :median_time => Time.now

Custom Values

  :value_timestamp_format - The default value for options is a number of seconds relative to a given time. However, you may want the value to be representative of the actual calculated date. In this case, you can specify a to_s format for the timestamp. You can use any of the to_s formats supplied by Rails (:db, :long, :short, :rfc822) or even your own to_s formats.  Note that this option will only work when the supplied array of time intervals are NOT strings (i.e. enter 1.year rather than '1.year')
  Examples
    :value_timestamp_format => :db will have values like ‘2008-08-18 13:00′
    :value_timestamp_format => :rfc822

Custom Labels

  :before_prefix - add a prefix to all “before” option labels
    Example: :before_prefix => ‘About ‘

  :before_suffix - add a suffix to all “before” option labels
    Example: :before_suffix => ‘ before’

  :after_prefix - add a prefix to all “after" option labels
    Example: :after_prefix => ‘Sometime ‘

  :after_suffix - add a suffix to all “after” option labels
    Example: :after_suffix => ‘ after’

  :median_time_label - change the label for the depended upon time (Default is “– At the same time –”)
    Examples
      :median_time_label => ‘Same time as other task’
      :median_time_label => 'You have reached the center!'

  :label_timestamp_format - Your labels can automatically show the calculated timestamp rather than the amount of time difference. This will only work if :center is a Time object.  You can specify a to_s format that the label will use to display the time.  Otherwise it will default to the :long format. 
    Examples
      :label_timestamp_format => :db
      :label_timestamp_format => :my_awesome_to_s_format
      :label_timestamp_format => :rfc822
      
  :interval_and_timestamp_label - Specifying this option as true will result in the label including both a time interval and timestamp for each option.  
    Example
      :interval_and_timestamp_label => true produces labels such as "3 hours => 2008-08-20 13:30:44"
  If using the interval_and_timestamp_label, you will also be able to format the label with the following additional options:
  
    :interval_and_timestamp_label_divider - This is the text that will be used to divide the interval and timestamp in the label.  The default text is ' => '
      Example
        :interval_and_timestamp_label_divider => ' @ ' produces labels such as "3 hours @ 2008-08-20 13:30:44"
      
    :before_interval_suffix - Adds a suffix to the time interval portion of the before options
      Example
        :before_interval_suffix => ' before' produces labels such as "3 hours before => 2008-08-20 13:30:44"
      
    :after_interval_suffix - Adds a suffix to the time interval portion of the after options
      Example
        :after_interval_suffix => ' after' produces labels such as "3 hours after => 2008-08-20 13:30:44"

Disabling the Mirror

You can also specify to hide the before, median or after options with these options…

  :display_before_options => boolean
  :display_median_time_options => boolean
  :display_after_options => boolean

    Example
      :display_after_options => false would return options for only times before and and the median time

======================================================================



===========================================
ADDITIONAL HELPERS
===========================================
 
  railative_interval_to_pretty(railative_interval = '', options = {})
  =================================================================== 
   
  Takes a railative String (Example: "1.year,  4.months") and formats it into a "pretty" display format.  There is also an option to strip the negative sign off the front of each interval.  This is helpful for displaying negative intervals already in the database.
  
  Examples
    railative_interval_to_pretty('4.years') # outputs: '4 years'
    railative_interval_to_pretty('4.years, 3.months') # outputs: '4 years, 3 months'
    railative_interval_to_pretty('-4.years, -7.minutes') # outputs: '-4 years, -7 months'
    railative_interval_to_pretty('-4.years, -7.minutes', :strip_negative => true) # outputs: '4 years, 7 months'


  railative_interval_to_db(railative_interval = '', options = {})
  ===============================================================
  
  This helper takes a railative string (Example: "1.year,  4.months") and performs a little cleanup.  It's a good idea to run your Strings through this helper to make sure the whitespace in your railative intervals stored in the database stay consistent.  There is also an option to prepend a negative sign (:prepend_negative) to each time interval in the string.  This option is used by the mirrored_time_options helper to automatically set one side of the options to negative.
  
  Examples
    railative_interval_to_db('4.years') # outputs: '4 years'
    railative_interval_to_db('4.years,    3.months') # outputs: '4 years, 3 months'
    railative_interval_to_db('4.years, 7.minutes', :prepend_negative => true) # outputs: '-4.years, -7.minutes'
    


Copyright (c) 2008 David Baldwin (bilsonrails.wordpress.com / github.com/bilson), released under the MIT license
