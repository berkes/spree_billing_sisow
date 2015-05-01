# Helpers to deal with webmock stored fixtures
module WebMockFixtureHelpers
  def stored_response(filename)
    File.new(File.join('spec', 'webmock_files', filename))
  end
end
