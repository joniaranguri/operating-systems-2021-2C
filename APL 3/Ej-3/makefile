all: buildServidor buildCliente
buildServidor: 
	g++ -o servidor servidor.cpp -pthread
buildCliente: 
	g++ -o cliente cliente.cpp -pthread
clean:
	rm servidor
	rm cliente