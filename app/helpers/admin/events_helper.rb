module Admin::EventsHelper
  def event_edit_javascripts
    <<-CODE
      var lastFilter = '#{@event.filter_id}';
      var filterWindows = {};
      function loadFilterReference() {
        var filter = $F('event_description_filter_id');
        if (filter != "") {
          if (!filterWindows[filter]) filterWindows[filter] = new Popup.AjaxWindow("#{admin_reference_path('filters')}?filter_name="+encodeURIComponent(filter), {reload: false});
          var window = filterWindows[filter];
          if(lastFilter != filter) {
            window.show();
          } else {
            window.toggle();
          }
          lastFilter = filter;
        } else {
          alert('No documentation for filter.');
        }
        return false;
      }
    CODE
  end
end
