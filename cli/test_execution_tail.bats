
load '../test_helpers/bats-support/load'
load '../test_helpers/bats-assert/load'



@test "[TESTCASE SETUP] set stream_output to True" {
	sudo crudini --set /etc/st2/st2.conf actionrunner stream_output True
	assert_success

	sudo st2ctl restart
	assert_success
}

@test "st2 execution tail works correctly for simple actions" {
	run eval "st2 run examples.python_runner_print_to_stdout_and_stderr count=10 sleep_delay=1 -a | grep 'st2 execution tail' | sed 's/ st2 execution tail//'"
	assert_success
	EXECUTION_ID="$output"

	# Run the execution tail command - this may take awhile
	run eval "st2 execution tail $EXECUTION_ID"
	assert_success

	assert_output --partial "stdout -> Line: 6"
	assert_output --partial "stdout -> Line: 10"
	assert_output --partial "stderr -> Line: 7"
	assert_output --partial "stderr -> Line: 9"
}

@test "st2 execution tail works correctly for action chain workflows" {
	run eval "st2 run examples.action_chain_streaming_demo count=5 sleep_delay=1 -a | grep 'st2 execution tail' | sed 's/ st2 execution tail//'"
	assert_success
	EXECUTION_ID="$output"

	# Run the execution tail command - this may take awhile
	run eval "st2 execution tail $EXECUTION_ID"
	assert_success

	assert_output --regexp "Child execution \\(task=task3\\) [0-9a-f]{24} has started\..*"
	assert_output --regexp "Child execution \\(task=task3\\) [0-9a-f]{24} has finished \\(status=succeeded\\)\."
	assert_output --regexp "Child execution \\(task=task10\\) [0-9a-f]{24} has started\..*"
	assert_output --regexp "Child execution \\(task=task10\\) [0-9a-f]{24} has finished \\(status=succeeded\\)\."
	assert_output --regexp "Execution [0-9a-f]{24} has completed \\(status=succeeded\\)."
}

@test "st2 execution tail command works correctly for Mistral workflows" {
	run st2 runner get mistral-v2 > /dev/null
	if [[ "$status" -ne 0 ]]; then
		skip "Mistral not available, skipping tests"
	fi

	run eval "st2 run examples.mistral-streaming-demo count=5 sleep_delay=1 -a | grep 'st2 execution tail' | sed 's/ st2 execution tail//'"
	assert_success
	EXECUTION_ID="$output"

	# Run the execution tail command - this may take awhile
	run eval "st2 execution tail $EXECUTION_ID"
	assert_success

	assert_output --regexp "Child execution \\(task=task3\\) [0-9a-f]{24} has started\..*"
	assert_output --regexp "Child execution \\(task=task3\\) [0-9a-f]{24} has finished \\(status=succeeded\\)\."
	assert_output --regexp "Child execution \\(task=task10\\) [0-9a-f]{24} has started\..*"
	assert_output --regexp "Child execution \\(task=task10\\) [0-9a-f]{24} has finished \\(status=succeeded\\)\."
	assert_output --regexp "Execution [0-9a-f]{24} has completed \\(status=succeeded\\)."
}

@test "st2 execution tail command works correctly for Orquesta workflows" {
	run st2 runner get orquesta > /dev/null
	if [[ "$status" -ne 0 ]]; then
		skip "Orquesta not available, skipping tests"
	fi

	run eval "st2 run examples.orquesta-streaming-demo count=5 sleep_delay=1 -a | grep 'st2 execution tail' | sed 's/ st2 execution tail//'"
	assert_success
	EXECUTION_ID="$output"

	# Run the execution tail command - this may take awhile
	run eval "st2 execution tail $EXECUTION_ID"
	assert_success

	assert_output --regexp "Child execution \\(task=task3\\) [0-9a-f]{24} has started\..*"
	assert_output --regexp "Child execution \\(task=task3\\) [0-9a-f]{24} has finished \\(status=succeeded\\)\."
	assert_output --regexp "Child execution \\(task=task10\\) [0-9a-f]{24} has started\..*"
	assert_output --regexp "Child execution \\(task=task10\\) [0-9a-f]{24} has finished \\(status=succeeded\\)\."
	assert_output --regexp "Execution [0-9a-f]{24} has completed \\(status=succeeded\\)."
}
