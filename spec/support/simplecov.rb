# coverage report generated only with COVERAGE env variable set
if ENV['COVERAGE']
  require 'simplecov'
  require 'simplecov-rcov'
  SimpleCov.formatter = if ENV['CODECLIMATE_REPO_TOKEN']
    SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::RcovFormatter,
    CodeClimate::TestReporter::Formatter]
  else
    SimpleCov::Formatter::RcovFormatter
  end
end
