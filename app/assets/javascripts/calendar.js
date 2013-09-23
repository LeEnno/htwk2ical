$(function () {
  /* CHOOSE COURSES ACTION
   * ---------------------------------------------------------------------------
   */

  // studium generale link
  // -----------------------------------------------------------------------------
  $('#studium_generale_link').on('click', function(e) {
    e.preventDefault();

    // hide link and add input for autocomplete
    $(this).hide().before(
      $('<input>').attr({
        id:    'studium_generale_autocomplete',
        class: 'studium-generale-autocomplete',
        type:  'text'

      // set up autocomplete and give callback
      }).setUpAutocomplete(true, function(event, ui) {
        var sgCourseID    = ui.item.id,
            sgCourseTitle = ui.item.label,
            sgSubjectID   = ui.item.subject_id;
        
        // add inputs before (and give class for easy removing)
        $(this).before(
          $('<input>').attr({
            checked: 'checked',
            id:      'course_ids_' + sgCourseID,
            name:    'course_ids[]',
            type:    'checkbox',
            value:   sgCourseID,
            class:   'input-studium-generale'
          }),
          '&nbsp;',
          $('<input>').attr({
            id:    'course_aliases_' + sgCourseID,
            name:  'course_aliases[' + sgCourseID + ']',
            type:  'text',
            value: sgCourseTitle,
            class: 'input-studium-generale'
          }),
          $('<input>').attr({
            name:  'subject_ids[]',
            type:  'hidden',
            value: sgSubjectID,
            class: 'input-studium-generale'
          })
        ).remove();
      })
    );
  });
   

  // batch selector
  // -----------------------------------------------------------------------------
  
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



  // save changes in cookie when leaving courses page to add another subject
  // ---------------------------------------------------------------------------

  $('#choose-more-subjects-cta').on('click', function(e) {

    // give feedback
    $(this).addClass('disabled');

    // read aliases
    var aliases = [];
    $('.choose-courses').find('input').filter('[name="course_ids[]"]').each(function(i, el) {
      var id = el.value;
      aliases.push({
        id:      id,
        alias:   $('#course_aliases_' + el.value).val(),
        checked: $(el).is(':checked')
      });
    });

    // save aliases in cookie
    $.cookie('aliases', JSON.stringify({aliases: aliases}));
  });

  // apply aliases if we have any
  if ($('.choose-courses').length > 0) {
    var aliases = $.cookie('aliases');
    if (!!aliases) {
      aliases = JSON.parse(aliases).aliases;

      for (var i = 0; i < aliases.length; i++) {
        $('#course_aliases_' + aliases[i].id).val(aliases[i].alias);
        $('#course_ids_' + aliases[i].id).prop('checked', aliases[i].checked);
      }
    }
  }


  /* CHOOSE SUBJECTS ACTION
   * ---------------------------------------------------------------------------
   */

  // create new input field for another subject
  // ---------------------------------------------------------------------------

  $('#add-subject-title').click(function (e) {
    e.preventDefault();

    var subjectCount = $('.subject-title-bg').length,
        subjectMax   = 3,

        // make new inputs' ID and clone present one
        newInputID = 'subject-title-' + (++subjectCount),
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