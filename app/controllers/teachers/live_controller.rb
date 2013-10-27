class Teachers::LiveController < Teachers::BaseController

  def classroom
    # @course = Course.find(params[:course_id])
    @course = current_teacher.courses.find(params[:course_id])
    @students = @course.students.includes(:identity).order("identities.first_name")
    @attendance = student_attendance(@students, @course)
    @assignments = student_assignments(@students)
    @assignments_due = @course.assignments.where(:due_date => Date.today)

    respond_to do |format|
      format.json { render json: { attendance: @attendance, assignments: @assignments } }
      format.html
    end
  end


  def create_action
    course_id = params[:course_id]
    student_ids = params[:student_ids]
    assignment_id = params[:assignment_id]
    save_assignments(student_ids, course_id, assignment_id) if assignment_id
    render :json => "SUCCESS!"
  end
end
