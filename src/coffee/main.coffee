require ['config'], ->
  require ['knockout', 'viewmodel'], (ko, ViewModel) ->
    ko.applyBindings new ViewModel()
