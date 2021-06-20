#!/usr/bin/python
from BaseHTTPServer import HTTPServer, BaseHTTPRequestHandler
from SocketServer import ThreadingMixIn
import threading

class Handler(BaseHTTPRequestHandler):

    def do_POST(self):
        self.send_response(200)
        self.end_headers()
        message =  threading.currentThread().getName()
        self.wfile.write(message)
        self.wfile.write('\n')
        return

class ThreadedHTTPServer(ThreadingMixIn, HTTPServer):
    """Handle requests in a separate thread."""

if __name__ == '__main__':
    server = ThreadedHTTPServer(('10.10.30.95', 4902), Handler)
   # server = ThreadedHTTPServer(('10.10.30.95', 3801), Handler)
    print 'Starting server, use <Ctrl-C> to stop'
    server.serve_forever()
