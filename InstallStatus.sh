#!/bin/bash
# Install status script. After that you can run it by simply typing "status" in Terminal

cat > /usr/local/bin/status << EOF
#!/bin/bash
bash <(curl -s https://raw.githubusercontent.com/pbihq/tools/master/Status.sh)
exit 0
EOF

chmod 755 /usr/local/bin/status
exit 0