module AttendanceHelper
  def attendance_class(attendance_value)
    'error' if attendance_value == 'absent'
  end

  def attendance_name(attendance)
    String(attendance)[0].to_s.upcase
  end

  def attendance_value_for_student(attendances, student)
    Attendance::STATUSES[
      @attendance.find {|k, ids| ids.include?(student.id) }.first
    ]
  end
end
