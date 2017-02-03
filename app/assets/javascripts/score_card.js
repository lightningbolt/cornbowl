$(document).ready(function() {
  $('.tosses input').focus(function(e) {
    current_input = $(this);
  });
  $('input').keyup(function(e) {
    var game =  $(this).parents('.game');
    validator.setGameScores(this);

    if($(this).val() != '') {
      validator.enableNextToss(game, this);
      validator.advanceFocus(this);
    }

    $.ajax({
      url: '/tosses',
      type: 'POST',
      data: {
        frame_id: $(this).parents('.frame').data('id'),
        number: $(this).data('number'),
        score: $(this).val(),
      }
    });
  });

  function frames(scores) {
    var frames = [], FRAMES = 10;
    card.scores = scores;

    for(var i=0; i<FRAMES; i++) {
      card.frame = i + 1;
      if(card.isFrameBlank()) {
        break;
      }
      frames[i] = {
        number: card.frame,
        accumulated_score: card.sum(),
        frame_score: card.value(),
        tosses: $.map(card.tosses(), function(points, index) { 
          if(!isNaN(points)) {
            return {
              number: index + 1,
              score: points
            };
          }
        })
      };
    }
    return frames;
  }

  $('input:first').focus();
  var current_input = $('input:first');

  $('#miss_button').click( function() { press_score_button( 0 )});
  $('#ace_button').click( function() { press_score_button( 1 )});
  $('#cornhole_button').click( function() { 
    if( current_input.prev().length == 0 ) {
      press_score_button( 'X' );
    } 
    else if (card.frame == 10 && ~['X', '/'].indexOf(current_input.prev().val())) {
      press_score_button( 'X' );
    }
    else {
      press_score_button( '/' );
    }
  });

  var map = {
    'x': 3, 'X': 3,
    '/': 3, '\\': 3,
    '1': 1,
    '0': 0
  }

  function scores(game) {
    return $.map(game.find('input').toArray(), function(e) {
      return parseInt(map[$(e).val()]);
    });
  }

  function press_score_button( score ) {
    current_input.val(score);
    current_input.keyup();
  }

  var validator = {
    enableNextToss: function(game, toss) {
      var tosses = game.find('input'),
        index = tosses.index(toss),
        frame = Math.floor(index/2) + 1;
      if(map[$(toss).val()] == 3 && index % 2 == 0 && frame != 10) {
        index++;
      }
      else if(index == 19 && (map[$(toss).val()] == 1 || map[$(toss).val()] == 0) && (map[$(tosses.eq(18)).val()] != 3)) {
        return;
      }
      index++;
      next = tosses.eq(index);
      if(next) {
        next.removeAttr('disabled');
        return tosses.get(index);
      }
    },
    enableGameTosses: function(game, toss) {
      if($(toss).val() != '') {
        var next = this.enableNextToss(game, toss);
        this.enableGameTosses(game, next);
      }
    },
    selectCurrentToss: function() {
      $('.game input').not('[disabled]').filter(function(e) {
        return $(this).val() == '';
      }).sort(function(a, b) {
        return a.tabIndex - b.tabIndex;
      })[0].focus();
    },
    enableTosses: function() {
      $('.game').each(function(index) {
        var input = $(this).find('input').get(0);
        $(input).removeAttr('disabled');
        validator.enableGameTosses($(this), input);
      });
    },
    setScores: function() {
      $('.game').each(function(index) {
        validator.setGameScores($(this).find('input').get(0));
      });
    },
    setGameScores: function(toss) {
      var game =  $(toss).parents('.game');
      card.scores = scores(game);

      game.find('.score').each(function(index, span) {
        card.frame = index + 1;
        $(span).html(card.isFrameBlank() ? '&nbsp;' : card.sum());
      });
    },
    advanceFocus: function(toss) {
      var tab_index = parseInt($(toss).attr('tabindex'));
      var valid_inputs = $.grep( $('input').toArray(), function(input) {
        return( parseInt($(input).attr('tabindex')) > tab_index && !$(input).attr('disabled')); 
      });
      if( valid_inputs.length > 0 ){
        valid_inputs.sort( function(a,b) {
          return(parseInt($(a).attr('tabindex')) > parseInt($(b).attr('tabindex')));
        });
        valid_inputs[0].focus();
        current_input = $(valid_inputs[0]);
      }
      else {
        var finals = {}, max = 0, tie = 0;
        $('.game').each(function() {
          var game = $(this), 
            cornbowler = game.find('.player').data('id');

          card.scores = scores(game);
          card.frame = 10;
          finals[cornbowler] = card.sum();
          if(max < card.sum()) {
            max = card.sum();
          }
        });

        for(var cornbowler in finals) {
          if(finals[cornbowler] == max) {
            tie++;
          }
        }

        $.ajax({
          url: '/games/' + $('#game-id').val() + '/finish',
          type: 'PUT',
          contentType: 'application/json',
          data: JSON.stringify({
            matchups: $.map($('.game').toArray(), function(game) {
              game = $(game);
              card.scores = scores(game);
              var cornbowlerId = game.find('.player').data('id'),
                hash = {
                  cornbowler_id: cornbowlerId,
                  result: finals[cornbowlerId] == max ? (tie == 1 ? 'wins' : 'ties') : 'losses',
                  final_score: finals[cornbowlerId],
                  frames: $.map(game.find('.frame').toArray(), function(el, index) {
                    var frame = $(el);
                    card.frame = index + 1;
                    return {
                      frame_id: frame.data('id'),
                      frame_score: card.value(),
                      accumulated_score: card.sum()
                    }
                  })
                };
              return hash;
            })
          })
        })
      }
    }
  }

  var card = {
    tosses: function() {
      var index = (this.frame - 1) * 2, size = 2;
      if(this.frame == 10) {
        size = 3;
      }
      return this.scores.slice(index, index + size);
    },
    futureTosses: function(x) {
      var index = this.frame * 2,
          futureTosses = [],
          toss = null;
      
      if(this.frame == 10) {
        index--;
        x = 2;
      }

      for(var i=0; i<4; i++) {
        toss = this.scores[index + i];
        if(!isNaN(toss)) {
          futureTosses.push(toss);
        }
      }
      futureTosses.length = x || 2;
      return futureTosses;
    },
    isStrike: function() {
      return this.scores[(this.frame-1)*2] == 3;
    },
    isSpare: function() {
      return this.scores[((this.frame-1)*2)+1] == 3;
    },
    sum: function() {
      if(this.frame == 0) {
        return 0;
      }
      else {
        var value = this.value(), sum;
        this.frame--;
        sum = this.sum() + value;
        this.frame++;
        return sum;
      }
    },
    value: function() {
      if(this.isStrike()) {
        nextTwoTosses = this.futureTosses(2)
        if (nextTwoTosses[0] == 1 && nextTwoTosses[1] == 3) {
          return 6
        }
        return 3 + this.sumTosses(nextTwoTosses);
      }
      else if(this.isSpare() && this.frame != 10) {
        return 3 + this.sumTosses(this.futureTosses(1));
      }
      else {
        return this.sumTosses(this.tosses());
      }
    },
    sumTosses: function(tosses) {
      return tosses.reduce(function(a, b) {
        return (a || 0) + (b || 0);
      }, 0);
    },
    isFrameBlank: function() {
      var tosses = this.tosses();
      return isNaN(tosses[0]) && isNaN(tosses[1]);
    }
  };


  validator.setScores();
  validator.enableTosses();
  validator.selectCurrentToss();

});
