<%= ERB.new(File.read('lib/travis/build/script/templates/footer.ps1')).result(binding) %>

echo '-- env --'
env
