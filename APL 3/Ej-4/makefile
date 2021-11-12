all: buildServidor buildCliente
buildServidor: 
	g++ -g -o servidor servidor.cpp -lpthread 
buildCliente: 
	g++ -g -o cliente cliente.cpp -lpthread 
clean:
	rm servidor
	rm cliente