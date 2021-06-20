#!/usr/bin/python
import socket
import mimetools
import datetime
import sys
from StringIO import StringIO

rbufsize = -1
wbufsize = 0
#class TestSocket_Robot():

def open_socket(host,port):
		sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
		sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
		sock.bind((host, int(port)))
		sock.listen(5)
		return	sock

def get_one_request(sock_sr,timeout=60):
		sock_sr.settimeout(timeout)
		try:
			req,cl_add=sock_sr.accept()
		except socket.timeout:
			raise Exception("Unable to accept any request within a timeout")
		return req

def read_request_body(req):
		rfile=req.makefile('rb', rbufsize)
		requestline = rfile.readline(65537)
		requestline = requestline.rstrip('\r\n')
		words = requestline.split()
		command, path, version = words
		MessageClass = mimetools.Message
		headers = MessageClass(rfile, 0)
		headers_alone = MessageClass(StringIO(headers))
		con_len=headers.getheader('content-length', 0)
		req_body=rfile.read(int(con_len))
		rfile.close()
		return headers_alone,req_body,version

def sendresponse_code(req,code,message,version):
		version_string="Python/"+sys.version.split()[0]
		Date_string=str(datetime.datetime.now())
		wfile=req.makefile('wb', wbufsize)
		wfile.write("%s %d %s\r\n" %(version, int(code), message))
		wfile.write("%s: %s\r\n" % ('Server', version_string))
		wfile.write("%s: %s\r\n" % ('Date', Date_string))
		wfile.write("%s: %s\r\n" % ('Content-Length',0))
		wfile.write("\r\n")
		wfile.flush()
		wfile.close()

def sendresponse_code_with_data(req,code,message,version):
		version_string="Python/"+sys.version.split()[0]
		Date_string=str(datetime.datetime.now())
		wfile=req.makefile('wb', wbufsize)
		wfile.write("%s %d %s\r\n" %(version, int(code), message))
		wfile.write("%s: %s\r\n" % ('Server', version_string))
		wfile.write("%s: %s\r\n" % ('Date', Date_string))
		wfile.write("%s: %s\r\n" % ('Content-Length', 0))
		wfile.write("\r\n")
		wfile.write("\r\n")
		wfile.write("\r\n")
		wfile.flush()
		wfile.close()

def close_socket(sock_sr):
		sock_sr.close()



