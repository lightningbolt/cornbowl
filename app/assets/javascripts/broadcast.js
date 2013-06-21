

(function() {
	var dispatcher = new WebSocketRails('localhost:3000/websocket');
	var channel = dispatcher.subscribe(location.pathname.match(/games\/(.*)/)[1]);
	channel.bind('tossed', function(data) {
		if(data.score == 3) {
			data.score = data.number == 1 ? '/' : 'X';
		}
		$('.frame[data-id="' + data.frame_id + '"]').find('input').eq(data.number).removeAttr('disabled').val(data.score);
	});
})();
