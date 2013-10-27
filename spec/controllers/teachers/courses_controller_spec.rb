require 'spec_helper'

describe Teachers::CoursesController do
  let(:course) { FactoryGirl.create :course, students: FactoryGirl.create_list(:student, 5) }
  let(:current_user) { course.teacher }

  def session
    { user_id: current_user.identity.id }
  end

  it 'is scoped to a course' do
    get :attendance, {id: course.id}, session
    response.should be_success
  end

  it 'assigns the students in the course' do
    get :attendance, {id: course.id}, session
    assigns(:students).should match_array(course.students)
  end

  it 'by default, assigns the current month as the date range' do
    get :attendance, {id: course.id}, session
    assigns(:date_range).should eq((Date.today-15.days)..Date.today)
  end

  it 'allows a specified date range via :from => :to params' do
    range = (Date.today - 20.days)..(Date.today + 5.days)
    get :attendance, {id: course.id, from: range.first, to: range.last}, session
    assigns(:date_range).first.should eq(range.first)
    assigns(:date_range).last.should eq(range.last)
  end

  it 'parses text dates from the params' do
    date_params = {from: '2013-10-09', to: '2013-10-24'}
    get :attendance, {id: course.id}.merge(date_params), session
    assigns(:date_range).first.should eq(Date.parse date_params[:from])
    assigns(:date_range).last.should eq(Date.parse date_params[:to])
  end

  describe 'POST #submit_attendance' do
    def attendance_data
      {
        attendances: {
          status_ids: course.students.each_with_object({}) {|student, h| h[student.id] = rand(1..3) }
        }
      }
    end

    it 'succeeds' do
      post :submit_attendance, {id: course.id, format: :js}.merge(attendance_data), session
      response.should be_success
    end

    it 'creates attendance records for all the students in the course' do
      expect {
        post :submit_attendance, {id: course.id, format: :js}.merge(attendance_data), session
      }.to change{Attendance.count}.by(course.students.count)
    end

    it 'updates attendance records if they already exist' do
      post :submit_attendance, {id: course.id, format: :js}.merge(attendance_data), session
      expect {
        post :submit_attendance, {id: course.id, format: :js}.merge(attendance_data), session
      }.to change{Attendance.count}.by(0)
    end

    it 'updates student actions if attendance has already been submitted' do
      post :submit_attendance, {id: course.id, format: :js}.merge(attendance_data), session
      expect {
        post :submit_attendance, {id: course.id, format: :js}.merge(attendance_data), session
      }.to change{StudentAction.count}.by(0)
    end
  end
end
