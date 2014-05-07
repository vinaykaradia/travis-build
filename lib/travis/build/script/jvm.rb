module Travis
  module Build
    class Script
      class Jvm < Script
        include Jdk

        DEFAULTS = {
          jdk: 'default'
        }

        def install
          self.if_file_exists   'gradlew',      './gradlew assemble', fold: 'install', retry: true
          self.elif_file_exists 'build.gradle', 'gradle assemble', fold: 'install', retry: true
          self.elif_file_exists 'pom.xml',      'mvn install -DskipTests=true -B -V', fold: 'install', retry: true # Otherwise mvn install will run tests which. Suggestion from Charles Nutter. MK.
        end

        def script
          self.if_file_exists   'gradlew',      './gradlew check'
          self.elif_file_exists 'build.gradle', 'gradle check'
          self.elif_file_exists 'pom.xml',      'mvn test -B'
          self.else                    'ant test'
        end
      end
    end
  end
end

