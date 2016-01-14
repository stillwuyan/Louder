#!/usr/bin/ruby
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

def receive_more(socket)
    socket.recv(1024)
end

#Process.daemon
exit if fork
Process.setsid
exit if fork
STDIN.reopen '/dev/null'
STDOUT.reopen '/dev/null', 'a'
STDERR.reopen '/dev/null', 'a'

server = TCPServer.new('10.1.1.68', 8008)
listener = {}
temp = 0
loop do
    socket = server.accept
    request_data = socket.recv(1024)
    STDERR.puts request_data

    path, method, data = requested_parse(request_data)
    # IE9 post request header and body separately.
    if method == "POST" && !data
        data = receive_more(socket)
        STDERR.puts "---", data
    end
    # Make sure the file exists and is not a directory
    # before attempting to open it.
    if method == "POST" && data && data.size > 0
        listener.delete_if do |ip, s|
            if ip != socket.peeraddr[3]
                s.print "HTTP/1.1 200 OK\r\n" +
                               "Content-Type: application/json\r\n" +
                               "Content-Length: #{data.size}\r\n" +
                               "Connection: close\r\n" +
                               "Access-Control-Allow-Origin: *\r\n"
                s.print "\r\n"
                s.print data
                s.close
                true
            end
        end
        puts listener
        socket.print "HTTP/1.1 200 OK\r\n" +
                     "Content-Type: application/json\r\n" +
                     "Content-Length: #{0}\r\n" +
                     "Connection: close\r\n" +
                     "Access-Control-Allow-Origin: *\r\n"
        socket.print "\r\n"
        puts socket
        socket.close
    elsif method == "GET"
        puts "add #{socket.peeraddr[3]}=>#{socket}"
        listener.store(socket.peeraddr[3], socket)
    elsif method == "OPTIONS"
        socket.print "HTTP/1.1 200 OK\r\n" +
                     "Connection: close\r\n" +
                     "Access-Control-Allow-Origin: *\r\n" +
                     "Access-Control-Allow-Methods: POST, GET, OPTIONS\r\n" +
                     "Access-Control-Allow-Headers: Accept, Content-Type\r\n"
        socket.print "\r\n"
        socket.close
    else
        message = "File not found\n"
  
        # respond with a 404 error code to indicate the file does not exist
        socket.print "HTTP/1.1 404 Not Found\r\n" +
                 "Content-Type: text/plain\r\n" +
                 "Content-Length: #{message.size}\r\n" +
                 "Connection: close\r\n" +
                 "Access-Control-Allow-Origin: *\r\n"
        socket.print "\r\n"
        socket.print message
        socket.close
    end
end