# linux-containers
A deep dive into linux container networking

## How to deploy 

``` mermaid
flowchart TD;
   A[Deploy to Node 1] --> B{Did the tests succeed?};
   B --> Yes   --> C[Deploy to Node 2!];
   B --> No --> C[fix an run test.sh  again!];
   C ----> E[Deployment complete!];
   D ----> E[Deployment complete!];
```
## [Multipath TCP ](https://www.mptcp.dev/)
MPTCP is an extension to the standard TCP and is described in RFC 8684. It allows a device to make use of multiple interfaces at once to send and receive TCP packets over a single MPTCP connection. MPTCP can aggregate the bandwidth of multiple interfaces or prefer the one with lowest latency, it also allows a fail-over if one path is down, and the traffic is seamlessly reinjected on other paths.

Technically, when a new socket is created with the IPPROTO_MPTCP protocol (Linux-specific), a subflow (or path) is created. This subflow consists of a regular TCP connection that is used to transmit data through one interface. Additional subflows can be negotiated later between the hosts. For the remote host to be able to detect the use of MPTCP, a new field is added to the TCP option field of the underlying TCP subflow. This field contains, amongst other things, a MP_CAPABLE option that tells the other host to use MPTCP if it is supported. If the remote host or any middlebox in between does not support it, the returned SYN+ACK packet will not contain MPTCP options in the TCP option field. In that case, the connection will be “downgraded” to plain TCP, and it will continue with a single path.
