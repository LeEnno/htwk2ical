$(function () {

  // Create calendar
  // ---------------------------------------------------------------------------

  // make button disappear and show input instead
  $('#create-calendar-cta').click(function(e){
    e.preventDefault();
    $('#create-calendar-wrapper').slideUp(200);
    $('#subject-title-wrapper').fadeIn(400);
  });


  // Contact/Donate link
  // ---------------------------------------------------------------------------
  $('#contact-mail, #donate-mail').click(function (e) {
    var isDonate = this.id == 'donate-mail',
        address = '@' + 'gmail.com', // weird concatenation stuff for making spam bots' lives a little harder
        subject = 'HTWK2iCal' + (isDonate ? ' unterstützen' : '');
    address = 'mailto:enricoschlag' + address + '?subject=' +
              encodeURIComponent(subject);
    
    if (isDonate) {
      var body = 'Lieber HTWK2iCal-Entwickler bitte teile mir deine ' +
                 'Kontodaten mit, damit ich etwas zum Bestehen von HTWK2iCal ' +
                 'beisteuern kann. Kthxbye!';
      address += '&body=' + encodeURIComponent(body);
    }
      
    $(this).attr('href', address);
  });
});
