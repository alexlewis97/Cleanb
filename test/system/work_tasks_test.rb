require "application_system_test_case"

class WorkTasksTest < ApplicationSystemTestCase
  setup do
    @work_task = work_tasks(:one)
  end

  test "visiting the index" do
    visit work_tasks_url
    assert_selector "h1", text: "Work Tasks"
  end

  test "creating a Work task" do
    visit work_tasks_url
    click_on "New Work Task"

    check "Finished" if @work_task.finished
    fill_in "Task", with: @work_task.task_id
    fill_in "Work day", with: @work_task.work_day_id
    click_on "Create Work task"

    assert_text "Work task was successfully created"
    click_on "Back"
  end

  test "updating a Work task" do
    visit work_tasks_url
    click_on "Edit", match: :first

    check "Finished" if @work_task.finished
    fill_in "Task", with: @work_task.task_id
    fill_in "Work day", with: @work_task.work_day_id
    click_on "Update Work task"

    assert_text "Work task was successfully updated"
    click_on "Back"
  end

  test "destroying a Work task" do
    visit work_tasks_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Work task was successfully destroyed"
  end
end
