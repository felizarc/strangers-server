guard 'livereload' do
  watch(%r{.+\.rb$})
end

guard 'rspec', :version => 2 do
  watch('app.rb') { "spec/app_spec.rb" }
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^models/(.+)\.rb$})  { |m| "spec/models/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
end

