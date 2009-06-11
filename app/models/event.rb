class Event < ActiveRecord::Base
  validates_presence_of :name, :message => 'An event name must be specified'
  validates_presence_of :date, :message => 'A date must be specified'
  validate :ensure_start_time_and_end_time_are_sane

  named_scope :for_date, lambda {|date| { :conditions => [ 'date = ?', date ], :order => 'start_time, name' } }
  named_scope :for_month, lambda {|month, year| { :conditions => [ 'date BETWEEN ? AND ?', Date.civil(year,month,1), Date.civil(year,month,-1) ] } }

  attr_accessor :timezone, :start_time, :end_time

  def timezone=(timezone)
    @timezone = timezone
    @tz = nil # invalidate @tz
  end

  def time(options = {})
    return nil unless start_time.is_a?(Time)

    format = options[:format] || '%H:%M'
    connector = options[:connector] || '-'

    str = start_time.strftime(format)
    str << " #{connector} #{end_time.strftime(format)}" if end_time.is_a?(Time)

    str
  end

  # Return a shortened description.
  # The <tt>:truncate</tt> option truncates the description to the specified number of characters.
  # The <tt>:sentences</tt> options truncates the description to the first N sentences.
  # If no options are specified, the first sentence is returned.
  #
  # A sentence is considered to end with a `.`, `!`, or `?`, followed by one or
  # more whitespace characters. This simple definition means that the string
  # "Good morning Mr. Teabag. A Mr. Pudey is waiting in your office." contains
  # four, not two, sentences.
  def short_description(options = {})
    return nil unless description
    if options[:truncate]
      l = options[:truncate] - 3
      chars = description.mb_chars
      (chars.length > options[:truncate] ? chars[0...l] + '...' : description).to_s
    else
      count = [ options[:sentences].to_i, 1 ].max
      description.split(/([!.?])\s+/, count+1).in_groups_of(2)[0,count].collect{|arr| arr.join}.join(' ')
    end
  end

  protected

    def ensure_start_time_and_end_time_are_sane
      if end_time.is_a?(Time)
        if !start_time.is_a?(Time)
          errors.add(:start_time, "The event's start time must be specified when an end time is specified")
        elsif start_time >= end_time
          errors.add(:start_time, "The event's start time must be earlier than its end time")
        end
      end
    end

    def after_initialize
      @timezone = Radiant::Config['local.timezone'] || 'UTC'
    end

    def after_find
      @timezone   = read_attribute(:timezone)
      @start_time = tz.utc_to_local(read_attribute(:start_time)) if read_attribute(:start_time)
      @end_time   = tz.utc_to_local(read_attribute(:end_time)) if read_attribute(:end_time)
    end

    def before_save
      write_attribute(:timezone, @timezone)
      write_attribute(:start_time, @start_time.is_a?(Time) ? tz.local_to_utc(@start_time) : nil)
      write_attribute(:end_time, @end_time.is_a?(Time) ? tz.local_to_utc(@end_time) : nil)
    end

  private

    def tz
      @tz ||= ActiveSupport::TimeZone.new(timezone) rescue Time.zone
    end

end
