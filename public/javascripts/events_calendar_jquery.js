if (typeof jQuery == 'undefined')
  throw("events_calendar_jquery.js requires jQuery");

var ToolTips = {};
var ActiveToolTip = null;

function ToolTip(element, parent, offset_x, offset_y) {
  this.element  = element;
  this.parent   = parent;
  this.offset_x = offset_x;
  this.offset_y = offset_y;

  this.hide = function() {
    ActiveToolTip.hide();
  };

  this.show = function() {
    if ($('#tooltip-data-'+this.element.attr('id')).length == 0) {
      // Copy the contents of the tooltip to the active-tooltip div
      ActiveToolTip.html(this.element.html()).attr('id', 'tooltip-data-'+this.element.attr('id'));
    }

    // Calculate the tooltip size (and prevent overflowing the viewport)
    var max_tooltip_width = $(window).width() - (parseInt(this.element.css('padding-left')) +
                                                 parseInt(this.element.css('padding-right')) +
                                                 2 * Math.abs(this.offset_x));
    var max_tooltip_height = $(window).height() - (parseInt(this.element.css('padding-top')) +
                                                   parseInt(this.element.css('padding-bottom')) +
                                                   2 * Math.abs(this.offset_y));
    ActiveToolTip.
      width(Math.min(this.element.width()), max_tooltip_width).
      height(Math.min(this.element.height()), max_tooltip_height);

    // Calculate the tooltip position
    var parent_offset = this.parent.offset();
    var y = Math.max(Math.abs(this.offset_y) + $(window).scrollTop(),
                     parent_offset.top - this.offset_y - ActiveToolTip.outerHeight() + this.parent.outerHeight());
    var x = parent_offset.left - this.offset_x - ActiveToolTip.outerWidth();
    // If the tooltip doesn't fit on the left, move it to the right
    if (x < 0) {
      x = parent_offset.left + this.offset_x + this.parent.outerWidth();
    }

    // Set the tooltip position and make it visible
    ActiveToolTip.css({ top: y+'px', left: x+'px', visibility: 'visible', overflow: 'hidden' }).show();
  };
}

function makeToolTips() {
  ToolTips = {};

  if (ActiveToolTip == null) {
    $('body').append('<div id="active-tooltip" class="tooltip" style="visibility:hidden;"></div>');
    ActiveToolTip = $('#active-tooltip');
  }

  $('div.calendar-data').each(function() {
    var jd = $(this).attr('id').replace(/\D+(\d+)/, '$1');
    var calendar_cell = $('#day-'+jd);
    ToolTips[jd] = new ToolTip($(this), calendar_cell, 5, 5);
    calendar_cell.hover(function() { ToolTips[jd].show(); }, function() { ToolTips[jd].hide(); });
  });
}

$(function() {
  makeToolTips();
  $('#events-calendar').delegate('.changeMonth a', 'click', function() {
    $.get(this.href, function(data) {
      $('#events-calendar').empty().append($(data).children());
      makeToolTips();
    });
    return false;
  });
});