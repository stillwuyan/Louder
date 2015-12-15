require 'socket'
require 'uri'
require 'pp'

# Files will be served from this directory
WEB_ROOT = '.'

# Map extensions to their content type
CONTENT_TYPE_MAPPING = {
  'html' => 'text/html',
  'txt' => 'text/plain',
  'png' => 'image/png',
  'jpg' => 'image/jpeg'
}

# Treat as binary data if content type cannot be found
DEFAULT_CONTENT_TYPE = 'application/octet-stream'

# This helper function parses the extension of the
# requested file and then looks up its content type.

def content_type(path)
  ext = File.extname(path).split(".").last
  CONTENT_TYPE_MAPPING.fetch(ext, DEFAULT_CONTENT_TYPE)
end

# This helper function parses the Request-Line and
# generates a path to a file on the server.

def requested_parse(request_data)
  request_uri  = request_data.split(" ")[1]
  path         = URI.unescape(URI(request_uri).path)
  return File.join(WEB_ROOT, path), request_data.split(" ")[0], request_data.split("\r\n\r\n")[1]
end

# Except where noted below, the general approach of
# handling requests and generating responses is
# similar to that of the "Hello World" example
# shown earlier.

server = TCPServer.new('10.1.1.68', 8008)

loop do
  socket       = server.accept
  request_data = socket.recv(1024)

  STDERR.puts request_data

  path, method, data = requested_parse(request_data)
  # Make sure the file exists and is not a directory
  # before attempting to open it.
  if method == "POST" && data && data.size > 0
    socket.print "HTTP/1.1 200 OK\r\n" +
                   "Content-Type: text/plain\r\n" +
                   "Content-Length: #{data.size}\r\n" +
                   "Connection: close\r\n"
    socket.print "\r\n"
    socket.print data
  else
    message = "File not found\n"
  
    # respond with a 404 error code to indicate the file does not exist
    socket.print "HTTP/1.1 404 Not Found\r\n" +
                 "Content-Type: text/plain\r\n" +
                 "Content-Length: #{message.size}\r\n" +
                 "Connection: close\r\n"
    socket.print "\r\n"
    socket.print message
  end
  socket.close
end