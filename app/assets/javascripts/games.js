(function() {
  var playerIds = [];

  $(document).delegate('.players button', 'click', function(e) {
    e.preventDefault();
    var button = $(this),
      id = button.val(),
      index = playerIds.indexOf(id);

    if(index == -1) {
      playerIds.push(id);
      button.text('x');
    }
    else {
      playerIds.splice(index, 1);
      button.text('+');
    }
  });

  $(document).delegate('form', 'submit', function(e) {
    playerIds.forEach(function(id) {
      $('form').append('<input name="cornbowler_ids[]" type="hidden" value="' + id + '" />');
    });
  });
})();
