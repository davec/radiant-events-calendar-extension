if (typeof Prototype == 'undefined')
  throw("events_calendar.js requires the prototype.js library");

var ToolTips = $H();

var ToolTip = Class.create({
  initialize: function(element, parent_element, offset_x, offset_y) {
    this.element = $(element);
    this.parent = $(parent_element);
    this.offset_x = offset_x;
    this.offset_y = offset_y;
  },

  hide: function() {
    this.element.style.visibility = 'hidden';
  },

  show: function() {
    if ((this.element.style.top  == '' || this.element.style.top  == 0) &&
        (this.element.style.left == '' || this.element.style.left == 0)) {

      // need to fixate default size (MSIE problem)
      this.element.style.width  = this.element.offsetWidth  + 'px';
      this.element.style.height = this.element.offsetHeight + 'px';
        
      // Position the bottom right of the tooltip relative to the bottom
      // left of the parent (i.e., the calendar cell) element.
      // TODO: Adjust position to fit in viewport.
      //var pos = this.parent.cumulativeOffset();
      var pos = this.parent.positionedOffset();
      var x = pos[0] - this.offset_x - this.element.getDimensions().width;
      var y = pos[1] - this.offset_y - this.element.getDimensions().height + this.parent.getDimensions().height;
        
      this.element.style.top  = y + 'px';
      this.element.style.left = x + 'px';
    }
    this.element.style.visibility = 'visible';
  }
});

function makeToolTips() {
  ToolTips = $H();
  $$('div.tooltip').each(function(e){
    var jd = e.id.replace(/\D+(\d+)/, '$1');
    calendar_cell = $('day-'+jd);
    ToolTips[jd] = new ToolTip(e.id, $('day-'+jd), 5, 5);
    calendar_cell.writeAttribute({onmouseover:'ToolTips['+jd+'].show()',
                                  onmouseout:'ToolTips['+jd+'].hide()'});
  });
}
