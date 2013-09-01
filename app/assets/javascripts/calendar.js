$(function () {
  // choose courses action
  // ---------------------------------------------------------------------------

  // clicking batch-selector selects all corresponding checkboxes
  $('.batch-selector').change(function () {
    var doCheck = $(this).is(':checked');
    $(this).parent().find('input[type="checkbox"]').each(function () {
      $(this).prop('checked', doCheck);
    });
  });


  // clicking a course-checkbox updates the batch-selector
  var $tooltipInput,
      $chooseCourses = $('.choose-courses')
        .on('change', 'input[type="checkbox"]', function () {
          var $parent      = $(this).parent(),
              numUnchecked = $parent
                .find('input[type="checkbox"]')
                .not('.batch-selector')
                .not(':checked').length;
          $parent.find('.batch-selector').prop('checked', numUnchecked < 1);
        })

        // show tooltip on first hover
        .one('mouseenter', 'input[type="checkbox"]:not(.batch-selector), input[type="text"]', function (e) {
          var $this = $(this);

          // save text-input to apply the tooltip on
          if ($this.is('[type="text"]')) {
            $tooltipInput = $this;

          } else if ($this.is('[type="checkbox"]')) {
            $tooltipInput = $this.next('[type="text"]');

          } else {
            console.log("no fitting input type found for hover");
          }

          // apply tooltip and show it
          $tooltipInput.tooltip({
            title:     'Klicke in das Textfeld und bestimme den Namen des Moduls selbst.',
            trigger:   'manual',
            placement: 'right',
            html:      true
          }).tooltip('show');
        })

        // pulsate tooltip as soon as it's there
        .on('shown', function (e) {
          $('.tooltip').addClass('pulsate');
        });

  // hide tooltip when user focuses an input element
  $chooseCourses.one('focus', 'input[type="text"]', function () {
    $tooltipInput.tooltip('hide');
  });


  // choose subjects action
  // ---------------------------------------------------------------------------

  // create new input field for another subject
  $('#add-subject-title').click(function (e) {
    e.preventDefault();

    var subjectCount = $('.subject-title-bg').length,
        subjectMax   = 3;

    // make new inputs' ID and clone present one
    var newInputID = 'subject-title-' + (++subjectCount),
        $newEl     = $('.subject-title-bg.active')
          .removeClass('active')
          .clone();


    // remove +-icon (we only need it once) and aria-helper, change inputs' id,
    // remove present value and initialize autocomplete
    $newEl
      .find('a, .ui-helper-hidden-accessible')
      .css('background', 'red')
      .remove()
      .end()
      .find('input') // dunno why chaining isn't working
      .attr('id', newInputID)
      .val('')
      .setUpAutocomplete();


    // insert our new input and make it the active one if we haven't reached
    // the maximum of 3 subjects
    $newEl.insertBefore('#submit-link');
    if (subjectCount < subjectMax)
      $newEl.addClass('active');


    // remove +-icon if we have reached maximum of 3 subjects
    var $this = $(this);
    if (subjectCount >= subjectMax)
      $this.fadeOut(400, function () {
        $this.remove();
      });
    // otherwise move it down
    else
      $this.css('top', '+=82');
  });
});