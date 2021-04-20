classdef TCPServer < handle
    %This class is the representation of a TCP Server used for CSIVMonitor
    %Developed by Jesus Albany Armenta Garcia
    %April 13, 2021
    properties
        port
        bufferSize
        timeout
        address
        connection
    end
    
    methods
        function obj = TCPServer(address,port,bufferSize,timeout)
            %Constructor
            obj.address = address; 
            obj.port = port;
            obj.bufferSize = bufferSize;
            obj.timeout = timeout;
        end 
        
        function connect(obj)
            %Function to start the server according to the properties'
            %values, requires previous call to constructor
            obj.connection = tcpip(obj.address, obj.port, 'NetworkRole', 'server');
            fprintf("Waiting for connection on port: %d\n",obj.port);
            fopen(obj.connection); 
            fprintf("Established connection with: %s\n",obj.connection.RemoteHost); 
        end
        
        function closeConnection(obj)
            %Function to close the TCP connection once established with a
            %client
            fprintf("Closing connection with: %s\n",obj.connection.RemoteHost);
            fclose(obj.connection);
            %delete(obj.connection);
        end
    end
end

