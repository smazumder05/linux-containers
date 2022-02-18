#define _GNU_SOURCE
#include <errno.h>
#include <stdio.h>
#include <sched.h>
#include <string.h>
#include <sys/mount.h>
#include <sys/msg.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

#define STACKSIZE (1024*1024)
static char stack[STACKSIZE];

void print_err(char const * const reason) {
    fprintf(stderr, "Container error: %s: %s\n", reason, strerror(errno));
}

int exec(void *args) {
    //Mount proc
    if (mount("proc","/proc","proc",0,"") != 0) {
        print_err("[Container error:] - mounting proc.");
        return 1;
    }
    //Set a new hostname
    char const *hsname = "sm-container";
    if (sethostname(hsname,strlen(hsname)) != 0) {
        print_err("[Container error:] - Setting hostname.");
        return 1;
    }
    //Set a new message queue
    key_t key = {0};
    if (msgget(key,IPC_CREAT) == -1) {
        print_err("[Container error:] - Creating message queue.");
        return 1;
    }
    //Execute a geven command
    char **const argv = args;
    if (execvp(argv[0],argv) != 0) {
        print_err("[Container error:] - Executing command.");
        return 1;
    }
    return 0;
}

int main(int argc, char **argv) {
   // Provide some feedback about the usage
    if (argc < 2) {
        fprintf(stderr, "No command specified\n");
        return 1;
    }

    // Namespace flags
    const int flags = CLONE_NEWNET | CLONE_NEWUTS | CLONE_NEWNS | CLONE_NEWIPC |
                      CLONE_NEWPID | CLONE_NEWUSER | SIGCHLD;

    // Create a new child process
    pid_t pid = clone(exec, stack + STACKSIZE, flags, &argv[1]);

    if (pid < 0) {
        print_err("calling clone");
        return 1;
    }

    // Wait for the process to finish
    int status = 0;
    if (waitpid(pid, &status, 0) == -1) {
        print_err("waiting for pid");
        return 1;
    }

    // Return the exit code
    return WEXITSTATUS(status);
}
