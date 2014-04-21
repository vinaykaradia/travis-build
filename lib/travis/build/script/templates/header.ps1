RED="\033[31;1m"
GREEN="\033[32;1m"
RESET="\033[0m"

function travis_start($travisStage) {
  $Env:TRAVIS_STAGE = $travisStage
  Write-Host -foregroundColor Red "[travis:${TRAVIS_STAGE}:start]" <%= ">> #{logs[:state]}" if logs[:state] %>
}

function travis_finish($travisStage, $result) {
  Write-Host "[travis:${travisStage}:finish:result=${result}]" <%= ">> #{logs[:state]}" if logs[:state] %>
  sleep 1
}

function travis_assert() {
  $Local:result = $LastExitCode
  if ( $result -ne 0 ) {
    Write-Host -foregroundColor Red "`nThe command ""$Env:TRAVIS_CMD"" failed and exited with $result during $Env:TRAVIS_STAGE.`n"
    Write-Host "Your build has been stopped." <%= "| Out-file #{logs[:log]} -Append" if logs[:log] %>
    travis_terminate 2
  }
}

function travis_result($result) {
  if ($Env:TRAVIS_TEST_RESULT -eq 0) {
    Set-Item Env:TRAVIS_TEST_RESULT $(( ${TRAVIS_TEST_RESULT:-0} | $(($result -ne 0)) ))
  }

  if ( $result -eq 0 ) {
    Write-Host -foregroundColor Green "`nThe command ""$TRAVIS_CMD"" exited with $result."<%= " >> #{logs[:log]}" if logs[:log] %>
  } else {
    Write-Host -foregroundColor Red "`nThe command ""$TRAVIS_CMD"" exited with $result."<%= " >> #{logs[:log]}" if logs[:log] %>
  }
}

function travis_terminate($result) {
  travis_finish build $result
  kill -Force (gwmi win32_process -Filter "processid='$pid'").parentprocessid 2>&1 >$null
  exit $result
}

function travis_wait() {

  if ( $args[0] -match '^[1-9][0-9]*$' ) {
    # looks like an integer, so we assume it's a timeout
    $Local:timeout, $Local:cmd = $args
  } else {
    # default value
    $Local:timeout=20
    $Local:cmd = $args
  }

  $Local:log_file=travis_wait_$$.log

  Invoke-Expression ($cmd -join ' ') | Out-File $log_file
  $Local:cmd_pid=$!

  travis_jigger $! $timeout $cmd &
  local jigger_pid=$!
  local result

  trap {
    wait $cmd_pid 2>/dev/null
    result=$LastExitCode
    ps -p$jigger_pid 2>&1>/dev/null && kill $jigger_pid
  }

  if ( $result -eq 0 ) {
    Write-Host -foregroundColor Green "`nThe command ""$TRAVIS_CMD"" exited with $result."
  } else {
    Write-Host -foregroundColor Red "`nThe command ""$TRAVIS_CMD"" exited with $result."
  }

  Write-Host -foregroundColor Green "`nLog:`n"
  cat $log_file

  return $result
}

function travis_jigger() {
  # helper method for travis_wait()
  $Local:cmd_pid,$Local:timeout,$Local:cmd=$args
  $Local:count=0
  $Local:command_string=$cmd -join ' '

  # clear the line
  echo "`n"

  while ( $count -lt $timeout ) {
    count=$(($count + 1))
    Write-Host -NoNewLine "`rStill running ($count of $timeout): "
    sleep 60
  }

  Write-Host -foregroundColor Red "`nTimeout (${timeout} minutes) reached. Terminating ""$command_string""`n"
  kill -Force $cmd_pid
}

function travis_retry() {
  $Local:result = 0
  $Local:count  = 1
  $Local:cmd_string = $args -join ' '

  while ( $count -le 3 ) {
    if ( $result -ne 0 ) {
      Write-Host -foregroundColor Red "`nThe command ""$cmd_string"" failed. Retrying, $count of 3.`n" >&2
    }
    Invoke-Expression($cmd_string)
    result=$LastExitCode
    if ( $result -eq 0 ) {
      break
    }
    $count=$count + 1
    sleep 1
  }

  if ( $count -eq 3 ) {
    Write-Host -foregroundColor Red "`nThe command ""$cmd_string"" failed 3 times.`n" >&2
  }

  return $result
}

function decrypt() {
  echo $1 | base64 -d | openssl rsautl -decrypt -inkey ~/.ssh/id_rsa.repo
}

mkdir <%= BUILD_DIR %>
cd    <%= BUILD_DIR %>

trap 'travis_finish build 1' TERM
trap 'TRAVIS_CMD=$TRAVIS_NEXT_CMD; TRAVIS_NEXT_CMD=${BASH_COMMAND#travis_retry }' DEBUG

travis_start build
