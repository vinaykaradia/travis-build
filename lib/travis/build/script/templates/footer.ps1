Write-Host "`nDone. Your build exited with $Env:TRAVIS_TEST_RESULT."

travis_terminate $Env:TRAVIS_TEST_RESULT
