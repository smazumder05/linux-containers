# linux-containers
A deep dive into linux container networking

## How to deploy
```mermaid
flowchart TD
   A[Deploy to Node 1] --> B{Did the tests succeed?};
   B -- Yes   --> C[Deploy to Node 2!];
   B -- No --> [fix an run test.sh  again!];
   C ----> E[Deployment complete!];
   D ----> E[Deployment complete!];
```
