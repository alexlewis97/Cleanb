require 'test_helper'

class WorkTasksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @work_task = work_tasks(:one)
  end

  test "should get index" do
    get work_tasks_url
    assert_response :success
  end

  test "should get new" do
    get new_work_task_url
    assert_response :success
  end

  test "should create work_task" do
    assert_difference('WorkTask.count') do
      post work_tasks_url, params: { work_task: { finished: @work_task.finished, task_id: @work_task.task_id, work_day_id: @work_task.work_day_id } }
    end

    assert_redirected_to work_task_url(WorkTask.last)
  end

  test "should show work_task" do
    get work_task_url(@work_task)
    assert_response :success
  end

  test "should get edit" do
    get edit_work_task_url(@work_task)
    assert_response :success
  end

  test "should update work_task" do
    patch work_task_url(@work_task), params: { work_task: { finished: @work_task.finished, task_id: @work_task.task_id, work_day_id: @work_task.work_day_id } }
    assert_redirected_to work_task_url(@work_task)
  end

  test "should destroy work_task" do
    assert_difference('WorkTask.count', -1) do
      delete work_task_url(@work_task)
    end

    assert_redirected_to work_tasks_url
  end
end
