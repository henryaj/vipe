ruby << EOF
def send_to_test_server(command)
  fork do
    File.open(File.join(ENV['HOME'], 'test_server_pipe'), 'w+') do |pipe|
      pipe.puts command
      pipe.flush
    end
  end
  print "Sent #{command}"
end
EOF

function! RunScenario(scenario)
ruby << EOF
  buffer = VIM::Buffer.current
  filename = buffer.name
  command = "cucumber #{buffer.name} --name '#{VIM::evaluate('a:scenario')}'"
  send_to_test_server(command)
EOF
endfunction

function! RunTest()
ruby << EOF
  buffer = VIM::Buffer.current
  filename = buffer.name
  extname = File.extname(buffer.name)
  command = if extname.strip == '.feature'
              then "cucumber #{buffer.name}"
            elsif filename =~ /_spec\.rb/
              then "spec #{buffer.name}"
            else
              "spec #{buffer.name.gsub('app/models', 'spec/models').gsub('.rb', '_spec.rb')}"
            end
  send_to_test_server(command)
EOF
endfunction

function! RunExample()
ruby << EOF
  buffer = VIM::Buffer.current
  send_to_test_server("spec -l #{buffer.line_number} #{buffer.name}")
EOF
endfunction

