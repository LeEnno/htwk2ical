$(function () {
  $('#show-instructions').click(function (e) {
    e.preventDefault();
    var pos = $('.choose-app-header, #app-instructions').fadeIn(800).position();
    window.scrollTo(pos.left, pos.top);
  });

  var $appList = $('#app-list');

  $appList.find('a').click(function (e) {
    e.preventDefault();

    var $appListLink = $(this),
        $appListItem = $appListLink.parent();

    if ($appListItem.hasClass('active'))
      return;

    var oldAppListItemPos = $appList.find('li.active')
          .removeClass('active')
          .position().top,
        newAppListItemPos = $appListItem
          .addClass('active')
          .position().top,
        appListItemPosOffset = newAppListItemPos - oldAppListItemPos;

    var $activeContent = $('#instruction-content').find('ol.active'),
        wrapperHeight = $activeContent
          .wrap('<div id="content-wrapper" />')
          .outerHeight(true),
        $wrapper = $('#content-wrapper').css({
          height:   wrapperHeight, // set height to remain after content disappears
          overflow: 'hidden' // make sure we can slide to new content height
        });

    $('#active-app-indicator').css('top', '+=' + appListItemPosOffset);

    $activeContent.fadeOut(0, function () {
      $(this).removeClass('active');

      var target = $appListLink.attr('href'),
          targetEl = $(target)
            .appendTo($wrapper)
            .fadeIn(400, function () {
              $(this).addClass('active'); // must be done *after* fading in
            }),
          newWrapperHeight = targetEl.outerHeight(true);

      $wrapper.animate({height: newWrapperHeight}, 400, 'swing', function () {
        targetEl.unwrap();
      });

    }); // end $activeContent.fadeOut()

  }); // end .click()

}); // end ready