# bitcoindcashd
Bitcoind with SSL support

## Deploy

### Generate SSL certs

    openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout server.key -out server.crt
    
### Prepare config

    PASSWORD=`pwgen -nB 10 1`
    tee bitcoindcash.conf << EOF
    server=1
    rpcallowip=0.0.0.0/0
    rpcuser=rpcuser
    rpcpassword=$PASSWORD
    EOF

### Create confir files and deploy certs

    kubectl create secret generic bitcoindcashd-conf --from-file=bitcoindcash.conf
    kubectl create secret generic bitcoindcashd-ssl --from-file=server.crt --from-file=server.key
    
    git clone https://github.com/kuberstack/bitcoindcashd
    $EDITOR bitcoindcashd/kubernetes/storage.yaml  # Change volume-ID
    kubectl create -f ./kubernetes/
