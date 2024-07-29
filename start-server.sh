#! /bin/zsh

set -e


run() {
  install_dependencies
  generate_env
  setup_tunnel
  start_server
}

install_dependencies() {
  echo "Installing project dependencies"

  cd $HOME/cpm
  direnv allow .
  eval "$(direnv export zsh)"

  echo "Done"
  echo
}

generate_env() {
  echo "Generating .env file"

  op signin --account constructable.1password.com
  kamal envify -P

  echo "Done"
  echo
}

setup_tunnel() {
  echo "Setting up development tunnel"

  echo "Login to Cloudflare, search for, and select constructable.dev in your browser"
  rm -f $HOME/.cloudflared/cert.pem
  cloudflared login

  local name=$(whoami)
  local app_host=app-$name.constructable.dev
  local api_host=api-$name.constructable.dev

  if cloudflared tunnel list | grep -q $name; then
    echo "Tunnel $name exists...regenerating"
    cloudflared tunnel delete $name
  fi

  local tunnel=$(cloudflared tunnel create -o json $name | jq -r '.id')

  cat <<EOF > $HOME/.cloudflared/config.yml
tunnel: $tunnel
credentials-file: $HOME/.cloudflared/$tunnel.json

ingress:
  - hostname: $app_host
    service: http://localhost:5173
  - hostname: $api_host
    service: http://localhost:3000
  - service: http_status:404
EOF

  cloudflared --overwrite-dns tunnel route dns $tunnel $app_host
  cloudflared --overwrite-dns tunnel route dns $tunnel $api_host

  op item edit --vault "Developers" "Tunnels" "$name=$tunnel"
  kamal envify -P

  echo "Done"
  echo
}

start_server() {
  echo "Starting server"

  cd $HOME/cpm
  foreman start
}


run
