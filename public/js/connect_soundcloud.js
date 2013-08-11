SC.initialize({
  client_id: 'd4be505a7370c60be1da0a4fba5ee0f6',
  redirect_uri: 'http://monotony.rkn.la/soundcloud_callback.html'
});

$('.soundcloud-connect').click(function() {
  SC.connect(function() {
    $('.connect-view').hide();
    $('input:hidden[name=scToken]').val(SC.accessToken());
    $('.upload-view').show();
  });
});


