if (typeof Prototype == 'undefined')
  throw("events_calendar.js requires the prototype.js library");

var ToolTips = $H();
var ActiveToolTip = null;

var ToolTip = Class.create({
  initialize: function(element, parent_element, offset_x, offset_y) {
    this.element = $(element);
    this.parent = $(parent_element);
    this.offset_x = offset_x;
    this.offset_y = offset_y;
  },

  hide: function() {
    ActiveToolTip.style.visibility = 'hidden';
  },

  show: function() {
    if ($('tooltip-data-'+this.element.id) == null) {
      // Copy the contents of the tooltip to the active-tooltip div
      ActiveToolTip.update(this.element.innerHTML);
      ActiveToolTip.id = 'tooltip-data-'+this.element.id;
    }

    // Calculate the tooltip size (and prevent overflowing the viewport)
    var max_tooltip_width = document.viewport.getWidth() - (parseInt(this.element.getStyle('padding-left')) +
                                                            parseInt(this.element.getStyle('padding-right')) +
                                                            2 * Math.abs(this.offset_x));
    var max_tooltip_height = document.viewport.getHeight() - (parseInt(this.element.getStyle('padding-top')) +
                                                              parseInt(this.element.getStyle('padding-bottom')) +
                                                              2 * Math.abs(this.offset_y));
    ActiveToolTip.style.width  = Math.min(parseInt(this.element.getStyle('width')), max_tooltip_width) + 'px';
    ActiveToolTip.style.height = Math.min(parseInt(this.element.getStyle('height')), max_tooltip_height) + 'px';

    // Calculate the tooltip position
    var viewport_offset = document.viewport.getScrollOffsets();
    var parent_offset = this.parent.cumulativeOffset();
    var y = Math.max(Math.abs(this.offset_y) + viewport_offset.top,
                     parent_offset.top - this.offset_y - ActiveToolTip.getHeight() + this.parent.getHeight());
    var x = parent_offset.left - this.offset_x - ActiveToolTip.getWidth();
    // If the tooltip doesn't fit on the left, move it to the right
    if (x < 0) {
      x = parent_offset.left + this.offset_x + this.parent.getWidth();
    }

    // Set the tooltip position and make it visible
    ActiveToolTip.style.top  = y + 'px';
    ActiveToolTip.style.left = x + 'px';
    ActiveToolTip.style.visibility = 'visible';
    ActiveToolTip.style.overflow = 'hidden';
  }
});

function makeToolTips() {
  ToolTips = $H();

  if (ActiveToolTip == null) {
    new Insertion.Bottom(document.body, '<div id="active-tooltip" class="tooltip" style="visibility:hidden;"></div>');
    ActiveToolTip = $('active-tooltip');
  }

  var use_writeAttribute = typeof ActiveToolTip.onmouseover == 'undefined';

  $$('div.calendar-data').each(function(e){
    var jd = e.id.replace(/\D+(\d+)/, '$1');
    calendar_cell = $('day-'+jd);
    ToolTips[jd] = new ToolTip(e.id, $('day-'+jd), 5, 5);
    if (use_writeAttribute) {
      calendar_cell.writeAttribute({onmouseover:'ToolTips['+jd+'].show()',
                                    onmouseout:'ToolTips['+jd+'].hide()'});
    } else {
      calendar_cell.onmouseover = new Function('ToolTips['+jd+'].show();');
      calendar_cell.onmouseout = new Function('ToolTips['+jd+'].hide();');
    }
  });
}
