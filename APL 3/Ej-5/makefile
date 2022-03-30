all: buildServidor buildCliente
buildServidor: 
	g++ -g -o servidor servidor.cpp -lpthread -lrt
buildCliente: 
	g++ -g -o cliente cliente.cpp -lpthread	 -lrt
clean:
	rm servidor
	rm cliente