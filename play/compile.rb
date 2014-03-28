#!/usr/bin/env ruby

$: << 'lib'
require 'travis/build'

data = eval DATA.read
# require 'yaml'
# data[:config] = YAML.load_file('play/config.yml')

# script = Travis::Build.script(data, logs: { build: false, state: true })
script = Travis::Build.script(data, logs: { build: false, state: true })
script = script.compile
puts script

__END__
{"type"=>"test",
 "platform"=>"windows",
 "build"=>
  {"id"=>21311478,
   "number"=>"4072.2",
   "commit"=>"9e19a3be219675437eb6a21fdbe8f120123272d0",
   "commit_range"=>"068bdd62c92c...9e19a3be2196",
   "commit_message"=>"[Truffle] Annotate specs that also fail in JRuby.",
   "branch"=>"master",
   "ref"=>nil,
   "state"=>"passed",
   "secure_env_enabled"=>true,
   "pull_request"=>false},
 "job"=>
  {"id"=>21311478,
   "number"=>"4072.2",
   "commit"=>"9e19a3be219675437eb6a21fdbe8f120123272d0",
   "commit_range"=>"068bdd62c92c...9e19a3be2196",
   "commit_message"=>"[Truffle] Annotate specs that also fail in JRuby.",
   "branch"=>"master",
   "ref"=>nil,
   "state"=>"passed",
   "secure_env_enabled"=>true,
   "pull_request"=>false},
 "source"=>{"id"=>21311476, "number"=>"4072"},
 "repository"=>
  {"id"=>10075,
   "slug"=>"jruby/jruby",
   "github_id"=>168370,
   "source_url"=>"git://github.com/jruby/jruby.git",
   "api_url"=>"https://api.github.com/repos/jruby/jruby",
   "last_build_id"=>21451782,
   "last_build_number"=>"4076",
   "last_build_started_at"=>"2014-03-24T19:25:29Z",
   "last_build_finished_at"=>"2014-03-24T20:16:31Z",
   "last_build_duration"=>9223,
   "last_build_state"=>"errored",
   "description"=>"JRuby, an implementation of Ruby on the JVM"},
 "config"=>
  {:language=>"java",
   :before_script=>
    ["unset GEM_PATH GEM_HOME IRBRC", "export PATH=`pwd`/bin:$PATH"],
   :jdk=>"oraclejdk7",
   :env=>["TARGET='-Prake -Dtask=test:extended'"],
   :matrix=>
    {:include=>
      [{:env=>"TARGET='-Pdist'", :jdk=>"oraclejdk8"},
       {:env=>"TARGET='-Pjruby-jars'", :jdk=>"oraclejdk7"},
       {:env=>"TARGET='-Pmain'", :jdk=>"oraclejdk7"},
       {:env=>"TARGET='-Pcomplete'", :jdk=>"oraclejdk8"}],
     :fast_finish=>true,
     :allow_failures=>
      [{:env=>"TARGET='-Prake -Dtask=spec:ci_interpreted_ir_travis'"}]},
   :branches=>{:only=>["master", "jruby-1_7", "/^test-.*$/"]},
   :before_install=>
    ["if [[ $TRAVIS_JDK_VERSION = 'oraclejdk8' ]]; then sudo apt-get update; sudo apt-get install oracle-java8-installer; else true; fi"],
   :script=>
    "( mvn install -Pbootstrap | grep -v Down ) && mvn -Dinvoker.skip=false $TARGET",
   :install=>"/bin/true",
   :notifications=>
    {:irc=>
      {:channels=>["irc.freenode.org#jruby"],
       :on_success=>"change",
       :on_failure=>"always",
       :template=>
        ["%{repository} (%{branch}:%{commit} by %{author}): %{message} (%{build_url})"]},
     :webhooks=>
      {:urls=>["https://rubies.travis-ci.org/rebuild/jruby-head"],
       :on_failure=>"never"}},
   :".result"=>"configured"},
 "queue"=>"builds.linux",
 "uuid"=>"121b7523-7629-4800-9a2b-0bc7b122d275"}
