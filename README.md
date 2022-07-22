# Deploy a vpn server to Digital Ocean

## Create stage

### have conf and creds

In conf, have:
- id_rsa
- vault_pass.txt

In src/etc/openvpn/server, have server.key creds made by README-ssl.txt

### create droplet and subdomain

create or check out release branch

    ansible-playbook -i deploy/hosts deploy/deploy_digitalocean_playbook.yml  --vault-password-file=conf/vault_pass.txt

wait for DNS to propagate with "nslookup vpnbox-stage.phu73l.net"

### deploy stage droplet

- ansible-playbook -i deploy/hosts deploy/secure_playbook.yml
- ansible-playbook -i deploy/hosts deploy/playbook.yml --vault-password-file=conf/vault_pass.txt

### test

    Verify that service runs on server:
    ssh -t -F local/ssh_config vpnbox-stage.phu73l.net 'systemctl status openvpn@server.service'
    Verify that local box can contact TCP server:
    nmap -Pn -p 1194 vpnbox-stage.phu73l.net
    Verify that local box can contact UDP server:  
    sudo nmap -Pn -sU -p 1194 vpnbox-stage.phu73l.net
    Verify that client works:
    set up client as directed in futel-vpnclient project
    verify that traffic for client to vpnbox_stage goes through vpnbox_stage
    view connected clients on server in /etc/openvpn/openvpn-status.log
    
## promote stage to prod

There must be at least one prod vpn server running:
- vpnbox-prod-foo.phu73l.net
- vpnbox-prod-bar.phu73l.net
- vpnbox-prod-baz.phu73l.net

We will promote stage to one not currently running. When other servers can serve all clients, we can decomission the currently running one.

### promote stage to a vacant name 

- one of:
  - ansible-playbook -i deploy/hosts deploy/hostname_playbook_foo.yml
  - ansible-playbook -i deploy/hosts deploy/hostname_playbook_bar.yml
  - ansible-playbook -i deploy/hosts deploy/hostname_playbook_baz.yml
- rename vpnbox-stage droplet to new vpnbox-prod-foo|bar|baz.phu73l.net
- one of:
  - ansible-playbook -i deploy/hosts deploy/dns_promote_playbook_foo.yml  --vault-password-file=conf/vault_pass.txt
  - ansible-playbook -i deploy/hosts deploy/dns_promote_playbook_bar.yml  --vault-password-file=conf/vault_pass.txt
  - ansible-playbook -i deploy/hosts deploy/dns_promote_playbook_baz.yml  --vault-password-file=conf/vault_pass.txt
- wait for DNS to propagate with "nslookup vpnbox-prod-foo|bar|baz.phu73l.net"
- refresh iptables on asteriskserver prod: in futel-installation repo,
        ansible-playbook -i deploy/hosts --limit prod deploy/secure_playbook.yml

# Decommission a running prod

- stop openvpn on old vpnbox-prod-foo|bar|baz.phu73l.net
        systemctl stop openvpn-server@server
        systemctl stop openvpn-server@server-tcp
- XXX wait 1-30 minutes for sip peers to become reachable?
- test that new vpnbox-prod-foo|bar|baz.phu73l.net is being used
  - sip show peers on futel-prod
  - service openvpn@server status on new vpnbox-prod-foo|bar|baz.phu73l.net
  - service openvpn@server-tcp status on new vpnbox-prod-foo|bar|baz.phu73l.net  
- cat /etc/openvpn/openvpn-status.log on new vpnbox-prod-foo|bar|baz.phu73l.net
- cat /etc/openvpn/openvpn-status-tcp.log on new vpnbox-prod-foo|bar|baz.phu73l.net  
- make a snapshot of old vpnbox-prod-foo|bar|baz.phu73l.net
- destroy droplet old vpnbox-prod-foo|bar|baz.phu73l.net
- remove A record for vpnbox-prod-foo|bar|baz.phu73l.net
- remove snapshots of vpnbox-prod-foo|bar|baz.phu73l.net except for most recent

# Add a new VPN client to a running installation

The server routes must be updated before adding a new client.
The client LAN must be unique among clients, in the 192.168.0.0/32 subnet.

- Update /etc/openvpn/server/server.conf to route to, and push the new route, e.g.
  - push "route 192.168.100.0 255.255.255.0"
  - route 192.168.100.0 255.255.255.0
  These routes can exist before the client is added, so we just add a swath which should cover the future population.
- Add a client configuration file to /etc/openvpn/server/ccd that matches the route, with a filename which exactly matches the CN of the client, e.g. "client-foo" containing
  - iroute 192.168.100.0 255.255.255.0
- systemctl restart openvpn-server@server

# monitor prod

    ssh -F local/ssh_config vpnbox-prod-bar|baz.phu73l.net
    view connected clients in /etc/openvpn/openvpn-status.log
