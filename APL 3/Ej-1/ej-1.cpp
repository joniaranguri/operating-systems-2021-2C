/*  APL N2 Ejercicio 1 (Primer entrega)
    Script: ej-1.cpp
    Integrantes:
    ARANGURI JONATHAN ENRIQUE                  40.672.991	
*/

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <semaphore.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdarg.h>
#include <signal.h>
#include <string.h>

#define SEMAFORO "semaforo"

pid_t hijo3();

pid_t hijo2();

pid_t hijo125(pid_t abuelo);

pid_t hijo126(pid_t abuelo);

pid_t hijo127(pid_t abuelo);

pid_t hijo1259(pid_t abuelo, pid_t bisabuelo);

pid_t hijo12710(pid_t abuelo, pid_t bisabuelo);

pid_t  hijo12711(pid_t abuelo, pid_t bisabuelo);

pid_t hijo138(pid_t abuelo);

int soyHijo(int);

sem_t *sem;

void mostrarAyuda() {
    printf("\n Ejemplo de ejecucion: \n ./ejercicio1\n");
}

int main(int arg, char *args[]) {

    if (arg == 2 && (strcmp(args[1], "-h") == 0 || strcmp(args[1], "-help") == 0 || strcmp(args[1], "-?") == 0)) {
        mostrarAyuda();
        return 0;
    }
    if (arg != 1) {
        printf("\n Cantidad de parametros incorrecta, verifique la ayuda\n");
        return 1;
    }

    sem_unlink(SEMAFORO);
    sem = sem_open(SEMAFORO, O_CREAT, 0600, 0);
     printf("Soy el pid: %d, padres -\n", getpid());

    pid_t pid1 = hijo3();
    pid_t pid2;

    if (!soyHijo(pid1)) {
        pid2 = hijo2();
    }

    sem_post(sem);
    sem_close(sem);
    return 0;
}

pid_t hijo3() {
    pid_t pid3 = fork();

    if (soyHijo(pid3)) {
        pid_t myPid = getpid();
        pid_t parentPid = getppid();
        printf("Soy el pid: %d, padres %d\n", myPid, parentPid);
        hijo138(parentPid);
    }else {
        wait(NULL);
    }

    return pid3;
}

pid_t hijo2() {
    pid_t pid2 = fork();

    if (soyHijo(pid2)) {
        pid_t myPid = getpid();
        pid_t parentPid = getppid();
        printf("Soy el pid: %d, padres %d\n", myPid, parentPid);
        hijo125(parentPid); 
    }else{
        wait(NULL);
    }

    return pid2;
}

pid_t hijo125(pid_t abuelo) {
    pid_t pid125 = fork();

    if (soyHijo(pid125)) {
         pid_t myPid = getpid();
        pid_t parentPid = getppid();
        printf("Soy el pid: %d, padres %d, %d\n", myPid, parentPid, abuelo);       
         hijo1259(parentPid, abuelo);

    }else{
        hijo126(abuelo);
        wait(NULL);
    }

    return pid125;
}

pid_t hijo126(pid_t abuelo) {
    pid_t pid126 = fork();

    if (soyHijo(pid126)) {
         pid_t myPid = getpid();
        pid_t parentPid = getppid();
        printf("Soy el pid: %d, padres %d, %d\n", myPid, parentPid, abuelo);       
     }else{
        hijo127(abuelo);
        wait(NULL);
    }

    return pid126;
}

pid_t hijo127(pid_t abuelo) {
    pid_t pid127 = fork();
     if (soyHijo(pid127)) {
         pid_t myPid = getpid();
        pid_t parentPid = getppid();
        printf("Soy el pid: %d, padres %d, %d\n", myPid, parentPid, abuelo);  
        hijo12711(parentPid, abuelo);     
     }else{
        wait(NULL);
    }
    return pid127;
}

pid_t hijo1259(pid_t abuelo, pid_t bisabuelo) {
    pid_t pid1259 = fork();

    if (soyHijo(pid1259)) {
           pid_t myPid = getpid();
        pid_t parentPid = getppid();
        printf("Soy el pid: %d, padres %d, %d, %d\n", myPid, parentPid, abuelo, bisabuelo);  
    }else{
        wait(NULL);
    }
    return pid1259;
}

pid_t hijo12710(pid_t abuelo, pid_t bisabuelo) {
    pid_t pid12710 = fork();

    if (soyHijo(pid12710)) {
           pid_t myPid = getpid();
        pid_t parentPid = getppid();
        printf("Soy el pid: %d, padres %d, %d, %d\n", myPid, parentPid, abuelo, bisabuelo);  
    }else{
        wait(NULL);
    }
    return pid12710;
}

pid_t  hijo12711(pid_t abuelo, pid_t bisabuelo) {
    pid_t pid12711 = fork();

       if (soyHijo(pid12711)) {
           pid_t myPid = getpid();
        pid_t parentPid = getppid();
        printf("Soy el pid: %d, padres %d, %d, %d\n", myPid, parentPid, abuelo, bisabuelo);  
    }else{
        hijo12710(abuelo, bisabuelo);     
        wait(NULL);
    }

    return pid12711;
}

pid_t hijo138(pid_t abuelo) {
    pid_t pid138 = fork();

    if (soyHijo(pid138)) {
        printf("Soy el pid: %d, padres: %d, %d\n", getpid(), getppid(), abuelo);
    }else{
      wait(NULL);  
    }

    return pid138;
}

int soyHijo(int pid) {
    return pid == 0;
}