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
  if ( !(Test-Path Env:TRAVIS_TEST_RESULT) ) { $Env:TRAVIS_TEST_RESULT = 0 }
  if ( $result -ne 0 ) {
    $Env:TRAVIS_TEST_RESULT = $Env:TRAVIS_TEST_RESULT -bOr 1
  } else {
    $Env:TRAVIS_TEST_RESULT = $Env:TRAVIS_TEST_RESULT -bOr 0
  }
  
  if ( $result -eq 0 ) {
    Write-Host -foregroundColor Green "`nThe command ""$Env:TRAVIS_CMD"" exited with $result."<%= " >> #{logs[:log]}" if logs[:log] %>
  } else {
    Write-Host -foregroundColor Red "`nThe command ""$Env:TRAVIS_CMD"" exited with $result."<%= " >> #{logs[:log]}" if logs[:log] %>
  }
}

function travis_terminate($result) {
  travis_finish build $result
  kill -Force (gwmi win32_process -Filter "processid='$pid'").parentprocessid 2>&1 >$null
  exit $result
}

function travis_retry() {
  $Local:result = 0
  $Local:count  = 1
  $Local:cmd_string = $args -join ' '

  while ( $count -le 3 ) {
    if ( $result -ne 0 ) {
      Write-Host -foregroundColor Red "`nThe command ""$cmd_string"" failed. Retrying, $count of 3.`n" 2>&1
    }
    Invoke-Expression($cmd_string)
    $result = $LastExitCode
    if ( $result -eq 0 ) {
      break
    }
    $count=$count + 1
    sleep 1
  }

  if ( $count -eq 3 ) {
    Write-Host -foregroundColor Red "`nThe command ""$cmd_string"" failed 3 times.`n" 2>&1
  }

  return $result
}

function decrypt($str) {
  [System.Text.Encoding]::UNICODE.GetString([System.Convert]::FromBase64String($str)) | openssl rsautl -decrypt -inkey ~/.ssh/id_rsa.repo
}

mkdir <%= BUILD_DIR %>
cd    <%= BUILD_DIR %>

# Need to replace these with Windows-minded signal processing
# trap 'travis_finish build 1' TERM
# trap 'TRAVIS_CMD=$TRAVIS_NEXT_CMD; TRAVIS_NEXT_CMD=${BASH_COMMAND#travis_retry }' DEBUG

travis_start build
