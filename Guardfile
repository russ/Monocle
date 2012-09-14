guard :rspec, version: 2, all_after_pass: true, all_on_start: false, keep_failed: false, cli: '--tty --color --format nested' do
  watch(%r{^spec/.+_spec\.rb})
  watch(%r{^lib/(.+)\.rb}) { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb') { 'spec' }
end
