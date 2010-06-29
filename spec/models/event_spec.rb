# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe Event do
  before(:each) do
    @event = Event.new(:name => 'A Special Event',
                       :location => 'Some Location',
                       :date => Date.today + 1.week,
                       :description => 'An event for testing',
                       :category => "Some Category",
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
      @event.errors.on(:name).should == I18n.t('activerecord.errors.models.event.attributes.name.blank')
      #@event.errors.on(:name).should == 'An event name must be specified'
    end

    it 'should require a date' do
      @event.date = nil
      @event.should_not be_valid
      @event.errors.on(:date).should == I18n.t('activerecord.errors.models.event.attributes.date.blank')
      #@event.errors.on(:date).should == 'A date must be specified'
    end

    it 'should not require a location' do
      @event.location = nil
      @event.should be_valid
    end

    it 'should not require a description' do
      @event.description = nil
      @event.should be_valid
    end

    it 'should not require a category' do
      @event.category = nil
      @event.should be_valid
    end

    it 'should not require a start time and an end time' do
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
      @event.errors.on(:start_time).should == I18n.t('activerecord.errors.models.event.attributes.start_time.blank')
      #@event.errors.on(:start_time).should == "A start time must be specified when an end time is specified"
    end

    it 'should require start time less than end time' do
      @event.start_time, @event.end_time = @event.end_time, @event.start_time
      @event.should_not be_valid
      @event.errors.on(:start_time).should == I18n.t('activerecord.errors.models.event.attributes.start_time.after_end_time')
      #@event.errors.on(:start_time).should == "The start time must be earlier than the end time"
    end

    it 'should not allow start time and end time to be equal' do
      @event.end_time = @event.start_time
      @event.should_not be_valid
      @event.errors.on(:start_time).should == I18n.t('activerecord.errors.models.event.attributes.start_time.after_end_time')
      #@event.errors.on(:start_time).should == "The start time must be earlier than the end time"
    end
  end

  context 'finders' do
    dataset :events

    it 'should return all events for the current month' do
      events = Event.for_month(Date.today.month, Date.today.year)
      events.should_not be_nil
    end

    it 'should return all events for the current day' do
      events = Event.for_date(Date.today)
      events.should_not be_nil
    end
  end

  context 'short description' do

    it 'should return the description when only one sentence' do
      @event.short_description.should == @event.description
    end

    it 'should return nil when description is nil' do
      @event.description = nil
      @event.short_description.should be_nil
    end

    %w(. ! ?).each do |punct|
      it "should return the first sentence of the description (ending with #{punct})" do
        first = "First sentence#{punct}"
        second = "Second sentence."
        @event.description = "#{first}\n\n#{second}"
        @event.short_description.should == first
      end
    end

    it 'should return the first two newline-separated sentences' do
        first = 'This is the first sentence!'
        second = 'Is this the second sentence?'
        third = 'Well, this is the third sentence.'
        @event.description = "#{first}\n\n#{second}\n\n#{third}"
        @event.short_description(:sentences => 2).should == "#{first} #{second}"
    end

    it 'should return the first two space-separated sentences' do
        first = 'This is the first sentence!'
        second = 'Is this the second sentence?'
        third = 'Well, this is the third sentence.'
        @event.description = "#{first} #{second} #{third}"
        @event.short_description(:sentences => 2).should == "#{first} #{second}"
    end

    it 'should truncate the description' do
      @event.description = 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Vivamus vitae risus vitae lorem iaculis placerat. Aliquam sit amet felis.'
      @event.short_description(:truncate => 80).should == @event.description[0...77] + '...'
    end

    it 'should be aware of HTML markup when truncating the description' do
      @event.description = '<strong>Lorem ipsum <i>dolor sit</i> amet</strong>, consectetuer adipiscing elit.'
      @event.short_description(:truncate => 20).should == '<strong>Lorem ipsum <i>dolor</i></strong>...'
    end

    it 'should be multi-byte aware when truncating the description' do
      @event.description = 'Lörem îpsum dołor ßit åmet, çonsectetuer adïpiscing eliţ.'
      @event.short_description(:truncate => 24).should == 'Lörem îpsum dołor ßit...'
    end

    it 'should ignore a non-terminal period' do
      @event.description = 'See a preview of WidgetFu 1.0 in action.'
      @event.short_description.should == @event.description
    end

    it 'should return both sentences' do
      @event.description = 'See a preview of WidgetFu 1.0 in action. Coffee and donuts provided.'
      @event.short_description(:sentences => 2).should == @event.description
    end

  end

  context 'filters' do

    it 'should apply Markdown to the description' do
      @event.description = 'Apply **Markdown** to this description.'
      @event.filter_id = 'Markdown'
      @event.save
      @event.description_html.should =~ %r{\A\s*<p>Apply <(b|strong)>Markdown</\1> to this description.</p>\s*\z}
    end

    it 'should apply Textile to the description' do
      @event.description = 'Apply *Textile* to this description.'
      @event.filter_id = 'Textile'
      @event.save
      @event.description_html.should =~ %r{\A\s*<p>Apply <(b|strong)>Textile</\1> to this description.</p>\s*\z}
    end

    it 'should not apply any filter to the description' do
      @event.description = 'Do not apply any filter to this description.'
      @event.save
      @event.description_html.should =~ %r{\A\s*<p>Do not apply any filter to this description.</p>\s*\z}
    end

  end

end
