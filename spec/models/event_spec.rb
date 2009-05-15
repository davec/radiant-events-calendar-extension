require File.dirname(__FILE__) + '/../spec_helper'

describe Event do
  before(:each) do
    @event = Event.new(:name => 'A Special Event',
                       :location => 'Some Location',
                       :date => Date.today + 1.week,
                       :description => 'An event for testing',
                       :start_time => Date.today + 1.week + 8.hours,
                       :end_time => Date.today + 1.week + 17.hours,
                       :timezone => 'UTC')
  end

  it 'should be valid' do
    @event.should be_valid
  end

  context 'validations' do
    it 'should require a name' do
      @event.name = nil
      @event.should_not be_valid
      #@event.errors.on(:name).should == I18n.t('activerecord.errors.messages.blank')
      @event.errors.on(:name).should == 'An event name must be specified'
    end

    it 'should require a date' do
      @event.date = nil
      @event.should_not be_valid
      #@event.errors.on(:date).should == I18n.t('activerecord.errors.messages.blank')
      @event.errors.on(:date).should == 'A date must be specified'
    end

    it 'should not require a location' do
      @event.location = nil
      @event.should be_valid
    end

    it 'should not require a description' do
      @event.description = nil
      @event.should be_valid
    end

    it 'should not require a start and end time' do
      @event.start_time = @event.end_time = nil
      @event.should be_valid
    end

    it 'should not require an end time' do
      @event.end_time = nil
      @event.should be_valid
    end

    it 'should not require a timezone' do
      @event.timezone = nil
      @event.should be_valid
    end

    it 'should require a start time with an end time' do
      @event.start_time = nil
      @event.should_not be_valid
      @event.errors.on(:start_time).should == "The event's start time must be specified when an end time is specified"
    end

    it 'should require start time less than end time' do
      @event.start_time, @event.end_time = @event.end_time, @event.start_time
      @event.should_not be_valid
      @event.errors.on(:start_time).should == "The event's start time must be earlier than its end time"
    end

    it 'should not allow start time and end time to be equal' do
      @event.end_time = @event.start_time
      @event.should_not be_valid
      @event.errors.on(:start_time).should == "The event's start time must be earlier than its end time"
    end
  end

  context 'finders' do
    fixtures :events

    it 'should return all events for the current month' do
      events = Event.for_month(Date.today.month, Date.today.year)
      events.should_not be_nil
    end

    it 'should return all events for the current day' do
      events = Event.for_date(Date.today)
      events.should_not be_nil
    end
  end

end
