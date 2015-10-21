require 'rspec/expectations'

RSpec::Matchers.define :have_error_json_as do |sample|
  match do |actual|
    expect(actual).to eq({
                           "code" => sample.code,
                           "title" =>  sample.title,
                           "detail" => sample.message,
                           "status" => sample.status,
                         })
  end
end
