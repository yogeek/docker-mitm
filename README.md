# Man in the Middle Demo in Docker

This is a really simple demo to showcase a Man in the Middle (MitM) via ARP poisoning attack using Docker containers.

The idea is that this example should be really quick to set-up and lightweight.

This small demo was used in the context of [Olicyber.IT](http://olicyber.it), for the Network Security lesson.

## Setup

There are 3 containers, Bob, Alice and Eve.

- **Bob**: is hosting a simple http server, serving the files contained in `bob_files`
- **Alice**: is a container with Firefox running on it. To connect to firefox from the host, visit `http://localhost:5800`.
- **Eve**: is a container meant to be used via bash. To run commands, just run `docker exec -it mitm_eve /bin/bash`. This container has the `eve_files` folder mounted on the container as `/olicyber` (TODO: change this folder's name)

The three containers are connected together with a docker bridge network called `mitm`

## How to run the demo

1. Connect to Alice's Firefox instance and visit `http://bob/`. This should show the actual website served by Bob
2. You may also connect to alice via command line (`docker exec -it mitm_alice /bin/sh`) and see which MAC address corresponds to Bob's IP address
3. Open 2 instances of bash on Eve's container (or, equivalently, use tmux with two splits) and run the `dig` command to discover the IPs of Alice and Bob:

```
$ dig alice
$ dig bob
```

4. With this information, now run arspoof twice, once for each bash instance.

In the first bash window:
```
$ arpspoof -t <alice_ip> <bob_ip>
```

In the second bash window:
```
$ arpspoof -t <bob_ip> <alice_ip>
```

5. Now you may verify in Alice's `sh` instance that `ip neighbor` shows that Bob's IP is now associated to Eve's MAC address, meaning that the ARP spoofing was successful. In any case, reloading the page still shows the normal website, since Eve is not blocking any packets yet.
6. Now run the `add_iptables_rule.sh` script in the `olicyber` folder. This will add a rule to `iptables` to forward every packet with destination port 80 to the proxy
7. You may verify that Alice's browser will give an error when reloading the page. This is because Eve is not blocking the packets in pitables and forwarding them to the proxy. Since the proxy is not active yet, the packets are simply dropped.
8. Now we activate the proxy in passive mode:

```
$ mitmproxy -m transparent
```

9. Reload the browser page: the honest page will show again, but mitmproxy will show that the request passed through Eve
10. Now shut down the proxy and activate it again, this time with the script that modifies the contents of the page:
```
$ mitmproxy -m trasnparent -s /olicyber/proxy.py
```
11. Reload the browser page: the attacker has changed the contents of the website.
12. To shut down everything use the `del_iptables_rul.sh` script in the `olicyber` folder to remove the iptables rule and turn off the two arpspoof instances

