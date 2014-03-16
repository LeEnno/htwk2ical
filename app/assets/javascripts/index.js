$(function () {

  // Create calendar
  // ---------------------------------------------------------------------------

  // make button disappear and show input instead
  $('#create-calendar-cta').click(function(e){
    e.preventDefault();
    $('#create-calendar-wrapper').slideUp(200);
    $('#subject-title-wrapper').fadeIn(400);
  });


  // Contact link
  // ---------------------------------------------------------------------------
  var $contact = $('#contact-mail');
  $contact.click(function (e) {
    // weird concatenation stuff for making spam bots' lives a little harder
    var address = '@' + 'gmail.com',
        subject = 'HTWK2iCal';
    address = 'mailto:enricoschlag' + address;
    $contact.attr('href', address + '?subject=' + subject);
  });

});