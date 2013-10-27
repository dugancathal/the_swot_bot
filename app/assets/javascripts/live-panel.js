function confirmMessage(message) {
  $('<p class="confirm-message">'+message+'</p>').insertBefore('.icon-container').fadeOut(2000, function(){
    $(this).remove();
  });
}

$(document).ready(function() {
  $('.classroom').hide();
  $('.behavior-container').show();

  $('.behavior-container .student-icon').click(function() {
      $(this).toggleClass('active');
      var checkbox = $(this).find('input[type=checkbox]')[0];
      checkbox.checked = checkbox.checked ? false : true;
  });

// ===============IPAD SPECIFIC EVENTS====================

 $('.swipe').addSwipeEvents().
  bind('swiperight', function(evt, swiperight) {
    $('.student-icon').removeClass('active');
    $('.student-icon').addClass('active');
  });

 $('.swipe').addSwipeEvents().
  bind('swipeleft', function(evt, swipeleft) {
    $('.student-icon').removeClass('active');
  });

// ==================OTHER BEHAVIOR ACTIONS========================

  $('#other').click(function() {
    $('.classroom').hide();
    $('.other-function-container').show();
  });

  $('.other-function').click(function(){
    $('.classroom').hide();
    $('.behavior-container').show();
    $('#action-form').append($('<input/>').attr({name: 'commit', value: $(this).text(), id: $(this).attr('id')}));
    $('#action-form').submit();
    $('#action-form #'+ $(this).attr('id')).remove();
  });

// ===============ATTENDANCE ACTIONS===================

  $('#attendance').click(function(){
    $('.behavior-container').hide();
    $('.attendance-container').show();

    $('.attendance-container .student-icon').each(function() {
      var icon = $(this);
      var attendance = icon.data('attendance') || icon.find('option[selected]').text();
      icon.removeClass();
      icon.addClass("student-icon " + attendance);
      icon.data('attendance', attendance);
    });
  });

  function toggleAttendance(currentIcon){
    klasses = {'present': 'tardy', 'tardy': 'absent', 'absent': 'present'};
    var icon = $(currentIcon);
    var select = icon.find('.behavior-select select')[0];
    var attendance = icon.data('attendance');

    icon.removeClass(attendance);
    icon.addClass(klasses[attendance]);
    icon.data('attendance', klasses[attendance]);

    select.selectedIndex = (select.selectedIndex + 1) % select.options.length;
  }

  $('.attendance-container .student-icon').click(function() {
    toggleAttendance(this);
  });

// ===================ASSIGNMENT ACTIONS======================

  $('#assignments').click(function(){

    $('.behavior-container').hide();
    $('.assignments-container').show();
    $('.assignments-container .student-icon').addClass('missing-assignment');
    $('.assignments-container .student-icon').addClass('complete').removeClass('missing-assignment');

    var course_id = $('#course-id data').attr('id');
    var get_url = '/teachers/courses/'+course_id+'/liveclass'

    $.get(get_url, function(response){
      // console.log(response);
      missing_assignments = response.assignments.missing_assignments;
      console.log(missing_assignments);

      function set_class(status_array){
        $.each(status_array, function(i, v){
          icon = $(".assignments-container [data-id='" + v + "']");
          icon.removeClass();
          icon.addClass('student-icon missing-assignment')
        });
      }

      set_class(missing_assignments);
    }, 'json');

    $('.assignments-container .student-icon').click(function() {
      $(this).toggleClass('missing-assignment');
      $(this).toggleClass('complete');
    });

    $('.assignment-button').click(function(){
      // var submit_action = $(this).attr('id');
      var data = [];

      $('.missing-assignment').each(function(){
        data.push($(this).data('id'));
      });
      // console.log(data);
      var url = ('/live_class');
      var course_id = $('#course-id data').attr('id');
      var assignment_id = $(this).parent().find('data').data('assignmentid');
      var dataToSend = {
                        student_ids : data,
                        assignment_id: assignment_id,
                        course_id: course_id
                        }
      // console.log(dataToSend);

      $.post(url, dataToSend);
      confirmMessage("Student Assignments Updated");
      $('.assignments-container').hide();
      $('.grid-container').show();
      $('.behavior-container').show();
      $('.student-icon').removeClass('missing-assignment');
      data = [];
    });
  });

// =====================MASTERY ACTIONS======================

});






