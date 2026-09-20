PROVISION_CMDLINE_FILE="$ROOT_DIR/provision/cmdline.txt"
PROVISION_USER_DATA_FILE="$ROOT_DIR/provision/user-data"
PROVISION_ROOTDEV_PLACEHOLDER='__ROOTDEV__'
PROVISION_PASSWORD_PLACEHOLDER='__ROOT_PASSWORD_HASH__'

provision_rootdev() {
  awk '{
    for (field = 1; field <= NF; field++) {
      if ($field ~ /^root=/) {
        sub(/^root=/, "", $field)
        print $field
        exit
      }
    }
  }' "$PROVISION_CMDLINE_FILE"
}

provision_password_value() {
  awk '/^[[:space:]]*passwd:[[:space:]]*/ {
    sub(/^[[:space:]]*passwd:[[:space:]]*/, "")
    sub(/^"/, "")
    sub(/"$/, "")
    print
    exit
  }' "$PROVISION_USER_DATA_FILE"
}

provision_rootdev_is_set() {
  local rootdev
  rootdev=$(provision_rootdev)
  [ -n "$rootdev" ] && [ "$rootdev" != "$PROVISION_ROOTDEV_PLACEHOLDER" ]
}

provision_password_is_set() {
  local password
  password=$(provision_password_value | tr -d '[:space:]')
  [ -n "$password" ] && [ "$password" != "$PROVISION_PASSWORD_PLACEHOLDER" ]
}

provision_password_hash() {
  printf '%s\n' "$1" | mkpasswd --method=yescrypt --stdin
}

provision_write_rootdev() {
  local rootdev
  local output_file
  rootdev=$1
  output_file=$(mktemp "$PROVISION_CMDLINE_FILE.XXXXXX")
  if ! awk -v rootdev="$rootdev" '
    {
      for (field = 1; field <= NF; field++) {
        if ($field ~ /^root=/) {
          $field = "root=" rootdev
          found = 1
        }
      }
      print
    }
    END { exit (found ? 0 : 1) }
  ' "$PROVISION_CMDLINE_FILE" >"$output_file"; then
    rm -f "$output_file"
    return 1
  fi
  mv "$output_file" "$PROVISION_CMDLINE_FILE"
}

provision_write_password() {
  local password_hash
  local output_file
  password_hash=$1
  output_file=$(mktemp "$PROVISION_USER_DATA_FILE.XXXXXX")
  if ! awk -v password_hash="$password_hash" '
    /^[[:space:]]*passwd:[[:space:]]*/ && !found {
      indent = $0
      sub(/[^[:space:]].*/, "", indent)
      print indent "passwd: \"" password_hash "\""
      found = 1
      next
    }
    { print }
    END { exit (found ? 0 : 1) }
  ' "$PROVISION_USER_DATA_FILE" >"$output_file"; then
    rm -f "$output_file"
    return 1
  fi
  mv "$output_file" "$PROVISION_USER_DATA_FILE"
}

provision_apply() {
  local rootdev
  local password_hash
  rootdev=$1
  password_hash=$2
  provision_write_rootdev "$rootdev"
  provision_write_password "$password_hash"
}

provision_status() {
  local rootdev
  rootdev=$(provision_rootdev)
  if provision_rootdev_is_set; then
    printf 'rootdev: %s\n' "$rootdev"
  else
    printf 'rootdev: unset\n'
  fi
  if provision_password_is_set; then
    printf 'passwd: %s\n' "$(provision_password_value)"
  else
    printf 'passwd: unset\n'
  fi
}
