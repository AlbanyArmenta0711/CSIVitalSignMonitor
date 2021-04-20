server = TCPServer('0.0.0.0',8090,1024,30);
server.connect();
fprintf(server.connection.Status);
server.closeConnection();

fprintf(server.connection.Status);