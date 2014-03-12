$(function () {
  $('#show-instructions').click(function (e) {
    e.preventDefault();
    var pos = $('.choose-app-header, #app-instructions').fadeIn(800).position();
    window.scrollTo(pos.left, pos.top);
  });
});